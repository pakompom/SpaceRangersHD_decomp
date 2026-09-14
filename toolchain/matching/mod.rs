//! Relocation-aware function comparison. Unknown evidence never proves a match.
use crate::{
    matching::symbols::{FlowSymbols, Symbols, hex},
    native::flow,
    native::image::Image,
    native::x86::{Decoder, indexed_operand_scales},
};
use anyhow::{Result, ensure};
use capstone::{RegId, arch::x86::X86OperandType::*};
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
#[path = "compare.rs"]
mod comparison;
pub use comparison::*;
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Reference {
    pub offset: usize,
    pub size: usize,
    pub identity: String,
    pub resolved: bool,
    pub relative: bool,
    pub width: usize,
    pub literal: bool,
    pub index_scale: i64,
    pub indexed_target: Option<u32>,
}
#[derive(Clone, Debug, Serialize)]
pub struct Instruction {
    pub address: u32,
    pub raw: Vec<u8>,
    pub text: String,
    pub token: Value,
    pub fuzzy: Value,
    pub refs: Vec<Reference>,
    pub call: Option<String>,
    pub branch: Option<String>,
    pub writes: Vec<Value>,
    pub constants: Vec<Value>,
    pub reads: Vec<Value>,
}
#[derive(Serialize)]
pub struct Function {
    pub address: u32,
    pub data: Vec<u8>,
    pub instructions: Vec<Instruction>,
    pub issues: Vec<String>,
    pub literal_aliases: Vec<(usize, usize)>,
}
fn register(
    decoder: &Decoder,
    reg: RegId,
    relaxed: bool,
    registers: &mut BTreeMap<String, usize>,
) -> String {
    let name = decoder.reg_name(reg);
    if !relaxed
        || name.is_empty()
        || ["esp", "ebp"].contains(&name.as_str())
        || ["st(", "fp", "xmm"].iter().any(|p| name.starts_with(p))
    {
        return name;
    }
    let family = ['a', 'b', 'c', 'd']
        .into_iter()
        .find(|c| {
            [
                format!("e{c}x"),
                format!("{c}x"),
                format!("{c}l"),
                format!("{c}h"),
            ]
            .contains(&name)
        })
        .map(|c| c.to_string())
        .unwrap_or(name.clone());
    let n = registers.len();
    let index = *registers.entry(family).or_insert(n);
    let width = if name.starts_with('e') {
        32
    } else if name.ends_with(['l', 'h']) {
        8
    } else {
        16
    };
    format!(
        "r{index}:{width}{}",
        if name.ends_with('h') { ":high" } else { "" }
    )
}
pub fn tuple_repr(value: &Value) -> String {
    match value {
        Value::Array(a) => format!(
            "({}{})",
            a.iter().map(tuple_repr).collect::<Vec<_>>().join(", "),
            if a.len() == 1 { "," } else { "" }
        ),
        Value::String(s) => format!("'{}'", s.replace('\\', "\\\\").replace('\'', "\\'")),
        Value::Null => "None".into(),
        _ => value.to_string(),
    }
}
pub fn function(
    image_id: usize,
    start: u32,
    ranges: &[(u32, u32)],
    symbols: &Symbols,
    decoder: &Decoder,
    diagnostics: bool,
) -> Result<Function> {
    let image = symbols.images[image_id];
    let decoded = flow::decode(
        image,
        decoder,
        start,
        ranges,
        &FlowSymbols {
            symbols,
            image: image_id,
        },
    )?;
    let mut issues = decoded.issues;
    ensure!(
        !decoded.instructions.is_empty(),
        "No instructions at {start:#x}"
    );
    let end = decoded.instructions.iter().map(|i| i.end()).max().unwrap();
    if ranges.len() > 1 {
        issues.push("Additional owned chunks need exception/tail validation".into());
    }
    let data = image.read_exact(start, (end - start) as usize)?.to_vec();
    let mut occupied = vec![false; data.len()];
    for (address, size) in decoded
        .instructions
        .iter()
        .map(|i| (i.address, i.bytes.len()))
        .chain(decoded.tables.iter().map(|(a, b)| (*a, b.len())))
        .chain(decoded.cases.iter().map(|(a, t)| (*a, t.bytes.len())))
    {
        for p in address..address.saturating_add(size as u32) {
            if let Some(slot) = p
                .checked_sub(start)
                .and_then(|p| occupied.get_mut(p as usize))
            {
                *slot = true;
            }
        }
    }
    let holes = occupied.iter().filter(|b| !**b).count();
    if holes > 0 {
        issues.push(format!(
            "{holes} internal bytes require table/exception metadata validation"
        ));
    }
    if image_id == 0 && ranges[0].1 > end {
        issues.push(format!(
            "{} indexed trailing bytes are unreachable from the entry",
            ranges[0].1 - end
        ));
    }
    let mut registers = BTreeMap::new();
    let mut slots = BTreeMap::new();
    let labels = decoded
        .instructions
        .iter()
        .enumerate()
        .map(|(i, ins)| (ins.address, i))
        .collect::<BTreeMap<_, _>>();
    let case_names = decoded
        .cases
        .iter()
        .enumerate()
        .map(|(i, (a, t))| (*a, format!("{}:{i}", t.kind)))
        .collect::<BTreeMap<_, _>>();
    let (literal_widths, literal_aliases) =
        literals::arguments(&decoded.instructions, symbols, image_id, decoder);
    let bitset_widths = literals::bitsets(&decoded.instructions, decoder);
    let scales = indexed_operand_scales(&decoded.instructions);
    let unknown = |address: u32| {
        format!(
            "unknown:{}:{address:#x}",
            if image_id == 0 { "native" } else { "rebuilt" }
        )
    };
    let local = |address: u32| labels.get(&address).map(|i| format!("local:{i}"));
    let mut result = Vec::new();
    for ins in decoded.instructions {
        let (mut refs, mut strict, mut relaxed, mut writes, mut constants, mut reads) = (
            Vec::new(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
        );
        let (mut call, mut branch) = (None, None);
        for (index, op) in ins.operands.iter().enumerate() {
            match op.op_type {
                Reg(reg) => {
                    if diagnostics {
                        strict.push(json!([
                            "reg",
                            op.size,
                            register(decoder, reg, false, &mut registers)
                        ]));
                        relaxed.push(json!([
                            "reg",
                            op.size,
                            register(decoder, reg, true, &mut registers)
                        ]));
                    }
                }
                Imm(value) => {
                    let address = value as u32;
                    let operand;
                    if ins.call || ins.jump || image.relocated(ins.address + ins.imm_offset as u32)
                    {
                        let relative = ins.call || ins.jump;
                        let width = if relative {
                            0
                        } else {
                            literal_widths.get(&ins.address).copied().unwrap_or(0)
                        };
                        let ident = local(address)
                            .or_else(|| symbols.identity(image_id, address, width, !relative, 0));
                        let resolved = ident.is_some();
                        let ident = ident.unwrap_or_else(|| unknown(address));
                        refs.push(Reference {
                            offset: ins.imm_offset as usize,
                            size: ins.imm_size as usize,
                            identity: ident.clone(),
                            resolved,
                            relative,
                            width,
                            literal: !relative,
                            index_scale: 0,
                            indexed_target: None,
                        });
                        operand = json!([if relative { "target" } else { "address" }, ident]);
                        if ins.call {
                            call = Some(ident);
                        } else if ins.jump {
                            branch = Some(ins.mnemonic.clone());
                        }
                    } else {
                        operand = json!(["imm", op.size, value]);
                        constants.push(json!([ins.mnemonic, value]));
                    }
                    if diagnostics {
                        strict.push(operand.clone());
                        relaxed.push(operand);
                    }
                }
                Mem(mem) => {
                    let mut displacement = json!(mem.disp());
                    let write = op.access.is_some_and(|a| a.is_writable());
                    if image.relocated(ins.address + ins.disp_offset as u32)
                        || (mem.base().0 == 0 && mem.index().0 == 0 && mem.segment().0 == 0)
                    {
                        let address = mem.disp() as u32;
                        let width = bitset_widths
                            .get(&ins.address)
                            .copied()
                            .unwrap_or(op.size as usize);
                        let scale = scales.get(&(ins.address, index)).copied().unwrap_or(0);
                        let native_site = if image_id == 0 {
                            Some(ins.address)
                        } else {
                            symbols
                                .linked
                                .get(&start)
                                .and_then(|base| base.checked_add(ins.address - start))
                        };
                        let indexed_target = native_site.and_then(|site| {
                            let target = symbols.evidence.indexed_references.get(&site).copied()?;
                            let native_bytes =
                                symbols.images[0].read_exact(site, ins.bytes.len()).ok()?;
                            let displacement = ins.disp_offset as usize
                                ..ins.disp_offset as usize + ins.disp_size as usize;
                            native_bytes
                                .iter()
                                .zip(&ins.bytes)
                                .enumerate()
                                .all(|(i, (a, b))| displacement.contains(&i) || a == b)
                                .then_some(target)
                        });
                        let ident = if let Some(target) = indexed_target {
                            symbols
                                .indexed_identity(image_id, address, width, scale, target, !write)
                        } else {
                            case_names.get(&address).cloned().or_else(|| {
                                symbols.identity(image_id, address, width, !write, scale)
                            })
                        };
                        let resolved = ident.is_some();
                        let ident = ident.unwrap_or_else(|| unknown(address));
                        refs.push(Reference {
                            offset: ins.disp_offset as usize,
                            size: ins.disp_size as usize,
                            identity: ident.clone(),
                            resolved,
                            relative: false,
                            width,
                            literal: !write,
                            index_scale: scale,
                            indexed_target,
                        });
                        displacement = json!(ident);
                    }
                    if !diagnostics {
                        continue;
                    }
                    let mut memory = |relax| {
                        let mut offset = displacement.clone();
                        if relax
                            && decoder.reg_name(mem.base()) == "ebp"
                            && mem.index().0 == 0
                            && offset.as_i64().is_some_and(|n| n < 0)
                        {
                            let count = slots.len();
                            let n = *slots.entry(offset.as_i64().unwrap()).or_insert(count);
                            offset = json!(format!("slot{n}"));
                        }
                        json!([
                            "mem",
                            op.size,
                            decoder.reg_name(mem.segment()),
                            register(decoder, mem.base(), relax, &mut registers),
                            register(decoder, mem.index(), relax, &mut registers),
                            mem.scale(),
                            offset
                        ])
                    };
                    strict.push(memory(false));
                    relaxed.push(memory(true));
                    let stack = ["esp", "ebp"].contains(&decoder.reg_name(mem.base()).as_str());
                    if !write && ins.mnemonic != "lea" && !stack {
                        reads.push(json!([ins.mnemonic, op.size, displacement, mem.scale()]));
                    }
                    if write && !stack {
                        writes.push(json!([ins.mnemonic, op.size, displacement, mem.scale()]));
                    }
                }
                _ => (),
            }
        }
        if ins.call && call.is_none() {
            call = Some(format!("indirect:{}", tuple_repr(&json!(strict))));
        }
        if ins.ret {
            let imm = ins
                .operands
                .first()
                .and_then(|o| {
                    if let Imm(n) = o.op_type {
                        Some(n)
                    } else {
                        None
                    }
                })
                .unwrap_or(0);
            branch = Some(format!("ret:{imm}"));
        }
        for r in &refs {
            if !r.resolved {
                issues.push(format!(
                    "Unresolved reference at {:#x}: {}",
                    ins.address, r.identity
                ));
            }
        }
        strict.insert(0, json!(ins.mnemonic));
        relaxed.insert(0, json!(ins.mnemonic));
        result.push(Instruction {
            address: ins.address,
            raw: ins.bytes,
            text: if diagnostics { ins.text } else { String::new() },
            token: json!(strict),
            fuzzy: json!(relaxed),
            refs,
            call,
            branch,
            writes,
            constants,
            reads,
        });
    }
    for (address, raw) in decoded.tables {
        let mut refs = Vec::new();
        for offset in (4..raw.len()).step_by(4) {
            let value = u32::from_le_bytes(raw[offset..offset + 4].try_into()?);
            let ident = local(value).or_else(|| symbols.identity(image_id, value, 0, false, 0));
            let resolved = ident.is_some();
            if !resolved {
                issues.push(format!(
                    "Unresolved exception table reference at {:#x}",
                    address + offset as u32
                ));
            }
            refs.push(Reference {
                offset,
                size: 4,
                identity: ident.unwrap_or_else(|| format!("unknown:{value:#x}")),
                resolved,
                relative: false,
                width: 0,
                literal: false,
                index_scale: 0,
                indexed_target: None,
            });
        }
        let mut token = vec![
            json!("exception_dispatch"),
            json!(u32::from_le_bytes(raw[..4].try_into()?)),
        ];
        token.extend(refs.iter().map(|r| json!(r.identity)));
        result.push(Instruction {
            address,
            raw,
            text: format!(
                "exception_dispatch {}",
                refs.iter()
                    .map(|r| r.identity.as_str())
                    .collect::<Vec<_>>()
                    .join(", ")
            ),
            token: json!(token),
            fuzzy: json!(token),
            refs,
            call: None,
            branch: None,
            writes: vec![],
            constants: vec![],
            reads: vec![],
        });
    }
    for (address, table) in decoded.cases {
        let mut refs = Vec::new();
        let mut token = vec![json!(table.kind)];
        if table.kind == "case_targets" {
            for offset in (0..table.bytes.len()).step_by(4) {
                let target = u32::from_le_bytes(table.bytes[offset..offset + 4].try_into()?);
                let ident = local(target);
                let resolved = ident.is_some();
                if !resolved {
                    issues.push(format!(
                        "Unresolved case table reference at {:#x}",
                        address + offset as u32
                    ));
                }
                refs.push(Reference {
                    offset,
                    size: 4,
                    identity: ident.unwrap_or_else(|| format!("unknown:{target:#x}")),
                    resolved,
                    relative: false,
                    width: 0,
                    literal: false,
                    index_scale: 0,
                    indexed_target: None,
                });
            }
            token.extend(refs.iter().map(|r| json!(r.identity)));
        } else {
            token.push(json!(hex(&table.bytes)));
        }
        let text = format!("{} {}", table.kind, tuple_repr(&json!(&token[1..])));
        result.push(Instruction {
            address,
            raw: table.bytes,
            text,
            token: json!(token),
            fuzzy: json!(token),
            refs,
            call: None,
            branch: None,
            writes: vec![],
            constants: vec![],
            reads: vec![],
        });
    }
    result.sort_by_key(|i| i.address);
    issues.sort();
    issues.dedup();
    Ok(Function {
        address: start,
        data,
        instructions: result,
        issues,
        literal_aliases: literal_aliases
            .into_iter()
            .map(|(a, b)| ((a - start) as usize, (b - start) as usize))
            .collect(),
    })
}
pub struct Fixup {
    offset: usize,
    instruction_end: usize,
    reference: Reference,
}
pub struct ExactBody {
    data: Vec<u8>,
    references: Vec<Fixup>,
    relocations: Vec<u32>,
    literal_aliases: Vec<(usize, usize)>,
}
impl ExactBody {
    pub fn from_function(original: &Function, image: &Image) -> Option<Self> {
        if !original.issues.is_empty() {
            return None;
        }
        let mut references = Vec::new();
        for i in &original.instructions {
            for r in &i.refs {
                if !r.resolved {
                    return None;
                }
                references.push(Fixup {
                    offset: (i.address - original.address) as usize + r.offset,
                    instruction_end: (i.address - original.address) as usize + i.raw.len(),
                    reference: r.clone(),
                });
            }
        }
        let lo = image.relocations.partition_point(|a| *a < original.address);
        let hi = image
            .relocations
            .partition_point(|a| *a < original.address + original.data.len() as u32);
        Some(Self {
            data: original.data.clone(),
            references,
            relocations: image.relocations[lo..hi]
                .iter()
                .map(|a| a - original.address)
                .collect(),
            literal_aliases: original.literal_aliases.clone(),
        })
    }
    pub fn compare(
        &self,
        name: &str,
        native_start: u32,
        address: u32,
        end: u32,
        symbols: &Symbols,
    ) -> Option<Comparison> {
        let rebuilt = symbols.images[1];
        let size = self.data.len();
        if address.checked_add(size as u32)? > end {
            return None;
        }
        let raw = rebuilt.read_exact(address, size).ok()?;
        if self
            .literal_aliases
            .iter()
            .any(|&(l, r)| raw.get(l..l + 4) != raw.get(r..r + 4))
        {
            return None;
        }
        let lo = rebuilt.relocations.partition_point(|a| *a < address);
        let hi = rebuilt
            .relocations
            .partition_point(|a| *a < address + size as u32);
        if rebuilt.relocations[lo..hi]
            .iter()
            .map(|a| a - address)
            .ne(self.relocations.iter().copied())
        {
            return None;
        }
        let mut adjusted = raw.to_vec();
        for fixup in &self.references {
            let r = fixup.offset..fixup.offset + fixup.reference.size;
            adjusted
                .get_mut(r.clone())?
                .copy_from_slice(self.data.get(r)?);
        }
        if adjusted != self.data {
            return None;
        }
        for f in &self.references {
            let r = &f.reference;
            let left = read_int(self.data.get(f.offset..f.offset + r.size)?, r.relative);
            let right = read_int(raw.get(f.offset..f.offset + r.size)?, r.relative);
            if ["local:", "case_targets:", "case_indices:"]
                .iter()
                .any(|s| r.identity.starts_with(s))
            {
                if r.relative {
                    if left != right {
                        return None;
                    }
                } else if right as u32
                    != address.wrapping_add(left as u32).wrapping_sub(native_start)
                {
                    return None;
                }
            } else {
                let target = if r.relative {
                    address
                        .wrapping_add(f.instruction_end as u32)
                        .wrapping_add(right as u32)
                } else {
                    right as u32
                };
                let identity = if let Some(base) = r.indexed_target {
                    symbols.indexed_identity(1, target, r.width, r.index_scale, base, r.literal)
                } else {
                    symbols.identity(1, target, r.width, r.literal, r.index_scale)
                };
                if identity.as_deref() != Some(r.identity.as_str()) {
                    return None;
                }
            }
        }
        Some(Comparison {
            name: name.into(),
            original_bytes: size,
            rebuilt_bytes: size,
            raw_equal: self.data.iter().zip(raw).filter(|(a, b)| a == b).count(),
            relocated_equal: size,
            instruction_score: 100.,
            fuzzy_score: 100.,
            exact: true,
            signals: vec![],
            unresolved: vec![],
            differences: vec![],
        })
    }
}
fn read_int(data: &[u8], signed: bool) -> i64 {
    let mut value = data
        .iter()
        .enumerate()
        .fold(0u64, |v, (i, b)| v | ((*b as u64) << (i * 8)));
    if signed && !data.is_empty() && data[data.len() - 1] & 0x80 != 0 {
        value |= u64::MAX << (data.len() * 8);
    }
    value as i64
}

#[cfg(test)]
mod proof_tests {
    use super::*;
    use crate::matching::symbols::{Evidence, ImageSymbols};
    fn image(base: u32, literal: u32, opcode: u8, relocated: bool) -> Image {
        let mut data = vec![opcode];
        data.extend((base + 0x20).to_le_bytes());
        data.push(0xc3);
        data.resize(0x20, 0);
        data.extend(literal.to_le_bytes());
        Image::fixture(
            base,
            data,
            if relocated {
                vec![base + 1]
            } else {
                Vec::new()
            },
        )
    }
    fn identities<'a>(native: &'a Image, rebuilt: &'a Image) -> Symbols<'a> {
        Symbols {
            images: [native, rebuilt],
            evidence: Evidence::default(),
            linked: BTreeMap::new(),
            link_names: BTreeMap::new(),
            states: [ImageSymbols::default(), ImageSymbols::default()],
            pending: Vec::new(),
            short_comparisons: BTreeSet::new(),
            short_copies: BTreeSet::new(),
            literal_calls: BTreeSet::new(),
        }
    }
    #[test]
    fn exact_proof_checks_storage_opcodes_and_relocations() -> Result<()> {
        let native = image(0x1000, 0x12345678, 0xa1, true);
        let decoder = Decoder::new()?;
        for (value, opcode, relocated, expected) in [
            (0x12345678, 0xa1, true, true),
            (0x12345679, 0xa1, true, false),
            (0x12345678, 0xa3, true, false),
            (0x12345678, 0xa1, false, false),
        ] {
            let rebuilt = image(0x2000, value, opcode, relocated);
            let symbols = identities(&native, &rebuilt);
            let original = function(0, 0x1000, &[(0x1000, 0x1006)], &symbols, &decoder, false)?;
            let exact =
                ExactBody::from_function(&original, &native).expect("bounded scalar literal");
            assert_eq!(
                exact
                    .compare("Load", 0x1000, 0x2000, 0x2006, &symbols)
                    .is_some(),
                expected
            );
        }
        Ok(())
    }
    #[test]
    fn reviewed_indexed_reference_requires_linked_base_and_complete_data() -> Result<()> {
        let make = |base: u32, displacement: u32, literal: u32, opcode: u8| {
            let mut data = vec![opcode, 0x04, 0x85];
            data.extend(displacement.to_le_bytes());
            data.push(0xc3);
            data.resize(0x40, 0);
            data.extend([0; 8]);
            data.extend(literal.to_le_bytes());
            data.resize(0x60, 0);
            data.extend([0x55; 12]);
            Image::fixture(base, data, vec![base + 3])
        };
        let native = make(0x1000, 0x1040, 123, 0xd9);
        let decoder = Decoder::new()?;
        for (displacement, data, opcode, expected) in [
            (0x2040, 123, 0xd9, true),
            (0x2044, 123, 0xd9, false),
            (0x2040, 124, 0xd9, false),
            (0x2040, 123, 0xdb, false),
        ] {
            let rebuilt = make(0x2000, displacement, data, opcode);
            let mut symbols = identities(&native, &rebuilt);
            // A different array with a biased base explains the same operand.
            symbols
                .evidence
                .arrays
                .extend([(0x1040, (0, 4)), (0x1060, (32, 4))]);
            symbols
                .evidence
                .names
                .extend([(0x1040, "Grades".into()), (0x1060, "Other".into())]);
            symbols
                .linked
                .extend([(0x2000, 0x1000), (0x2040, 0x1040), (0x2060, 0x1060)]);
            symbols.states[0]
                .constants
                .extend([(0x1040, 12), (0x1060, 12)]);
            symbols.states[1]
                .constants
                .extend([(0x2040, 12), (0x2060, 12)]);
            symbols.evidence.indexed_references.insert(0x1000, 0x1040);
            symbols.refresh();
            let body = function(0, 0x1000, &[(0x1000, 0x1008)], &symbols, &decoder, false)?;
            let proof = ExactBody::from_function(&body, &native).unwrap();
            let diagnostic = function(1, 0x2000, &[(0x2000, 0x2008)], &symbols, &decoder, true)?;
            assert_eq!(compare("Grades", &body, &diagnostic).exact, expected);
            assert_eq!(
                proof
                    .compare("Grades", 0x1000, 0x2000, 0x2008, &symbols)
                    .is_some(),
                expected
            );
            assert!(
                symbols
                    .indexed_identity(0, 0x1040, 4, 8, 0x1040, true)
                    .is_none()
            );
        }
        Ok(())
    }
    #[test]
    fn nil_managed_initializers_require_zero_storage_without_relocations() {
        let native = Image::fixture(0x1000, vec![0; 4], vec![]);
        for kind in ["dynamic_array", "interface"] {
            for (value, relocations, expected) in [
                (0u32, vec![], true),
                (1, vec![], false),
                (0, vec![0x2000], false),
                (0, vec![0x2001], false),
            ] {
                let rebuilt = Image::fixture(0x2000, value.to_le_bytes().to_vec(), relocations);
                let mut symbols = identities(&native, &rebuilt);
                symbols.linked.insert(0x2000, 0x1000);
                symbols
                    .evidence
                    .managed
                    .insert(0x1000, vec![(0, kind.into())]);
                symbols.states[0].constants.insert(0x1000, 4);
                symbols.states[1].constants.insert(0x2000, 4);
                let original = symbols.constant_identity(0, 0x1000, 4, 0);
                assert!(original.is_some());
                assert_eq!(
                    symbols.constant_identity(1, 0x2000, 4, 0) == original,
                    expected,
                    "{kind}: {value}"
                );
            }
        }
    }
    #[test]
    fn unknown_call_is_not_exact_evidence() -> Result<()> {
        let native = Image::fixture(0x1000, vec![0xe8, 0xfb, 0x0f, 0, 0, 0xc3], vec![]);
        let symbols = identities(&native, &native);
        let body = function(
            0,
            0x1000,
            &[(0x1000, 0x1006)],
            &symbols,
            &Decoder::new()?,
            false,
        )?;
        assert!(!body.issues.is_empty());
        assert!(ExactBody::from_function(&body, &native).is_none());
        Ok(())
    }
}

mod literals;
pub mod report;
pub mod session;
pub mod symbols;
pub mod unit_entries;
