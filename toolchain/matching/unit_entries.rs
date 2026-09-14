//! Compiler-owned initialization/finalization selected explicitly for matching.
use crate::{
    matching::symbols::Symbols, native::dccmap::Symbol, native::image::Image, native::x86::Decoder,
    project::Project,
};
use anyhow::{Context, Result, bail, ensure};
use capstone::arch::x86::{X86OperandType::*, X86Reg::*};
use std::{collections::BTreeSet, path::PathBuf};
#[derive(Clone)]
pub struct Entry {
    pub address: u32,
    pub unit: String,
    pub section: String,
    pub source: PathBuf,
    pub linked_unit: Option<String>,
}
impl Entry {
    pub fn name(&self) -> String {
        format!("{}.{}", self.unit, self.section)
    }
}
pub fn entries(project: &Project) -> Result<Vec<Entry>> {
    let pattern = regex::Regex::new(
        r"(?im)^\s*// @unit-(initialization|finalization) (\$[0-9a-f]+|0x[0-9a-f]+)\s*$",
    )?;
    let mut out = Vec::new();
    let mut seen = BTreeSet::new();
    for doc in project.documents.iter().chain(project.program.iter()) {
        let mut kinds = BTreeSet::new();
        let linked_unit = if doc.tree.kind == "program" {
            let tokens = crate::pascal::lexer::scan(&doc.text, &doc.path.to_string_lossy())?;
            let header = tokens
                .windows(2)
                .find(|p| p[0].value.eq_ignore_ascii_case("program"))
                .context("missing program heading")?;
            Some(header[1].value.clone())
        } else {
            None
        };
        for capture in pattern.captures_iter(&doc.text) {
            let section = capture[1].to_lowercase();
            let value = capture[2].trim_start_matches('$').trim_start_matches("0x");
            let address = u32::from_str_radix(value, 16)?;
            ensure!(
                kinds.insert(section.clone()) && seen.insert(address),
                "Duplicate unit entry in {}",
                doc.path.display()
            );
            out.push(Entry {
                address,
                unit: doc.path.file_stem().unwrap().to_string_lossy().into(),
                section,
                source: doc.path.clone(),
                linked_unit: linked_unit.clone(),
            });
        }
    }
    Ok(out)
}
#[derive(Debug, serde::Serialize)]
pub struct StartupTable {
    pub address: u32,
    pub table: u32,
    pub pairs: Vec<(u32, u32)>,
}
pub fn startup_table(image: &Image, linked: &[Symbol], decoder: &Decoder) -> Result<StartupTable> {
    let targets = linked
        .iter()
        .filter(|s| s.name.eq_ignore_ascii_case("sysinit.@initexe"))
        .map(|s| s.address)
        .collect::<BTreeSet<_>>();
    ensure!(
        !targets.is_empty() && !image.dll,
        "Unit initialization matching requires a Delphi executable with SysInit.@InitExe"
    );
    let mut argument = None;
    for ins in decoder.decode_prefix(image.entry, image.read(image.entry, 128))? {
        if ins.mnemonic == "mov"
            && ins.operands.len() == 2
            && matches!(ins.operands[0].op_type,Reg(r) if r.0 as u32==X86_REG_EAX)
        {
            argument = if let Imm(a) = ins.operands[1].op_type {
                Some(a as u32)
            } else {
                None
            };
        }
        if ins.mnemonic == "call" {
            if matches!(ins.operands[0].op_type,Imm(a) if targets.contains(&(a as u32)))
                && let Some(a) = argument
            {
                let count = image.u32(a).context("startup count")?;
                let table = image.u32(a + 4).context("startup table")?;
                ensure!(
                    count > 0 && count <= 4096,
                    "Invalid compiled startup count: {count}"
                );
                let raw = image.read_exact(table, count as usize * 8)?;
                let pairs = raw
                    .as_chunks::<8>()
                    .0
                    .iter()
                    .map(|r| {
                        (
                            u32::from_le_bytes(r[..4].try_into().unwrap()),
                            u32::from_le_bytes(r[4..].try_into().unwrap()),
                        )
                    })
                    .collect();
                return Ok(StartupTable {
                    address: a,
                    table,
                    pairs,
                });
            }
            argument = None;
        }
    }
    bail!("Cannot locate the InitExe table argument in the compiled entry")
}
pub fn startup_pairs(
    image: &Image,
    linked: &[Symbol],
    decoder: &Decoder,
) -> Result<Vec<(u32, u32)>> {
    Ok(startup_table(image, linked, decoder)?.pairs)
}
pub fn candidates(entry: &Entry, linked: &[Symbol], pairs: &[(u32, u32)]) -> Vec<u32> {
    let name = format!(
        "{}.finalization",
        entry.linked_unit.as_ref().unwrap_or(&entry.unit)
    );
    let finalizers = linked
        .iter()
        .filter(|s| s.name.eq_ignore_ascii_case(&name))
        .map(|s| s.address)
        .collect::<BTreeSet<_>>();
    if entry.section == "finalization" {
        finalizers.into_iter().collect()
    } else {
        pairs
            .iter()
            .filter(|(i, f)| *i != 0 && finalizers.contains(f))
            .map(|(i, _)| *i)
            .collect::<BTreeSet<_>>()
            .into_iter()
            .collect()
    }
}
pub fn reference_counter(
    image: &Image,
    address: u32,
    section: &str,
    decoder: &Decoder,
) -> Result<Option<u32>> {
    let instructions = decoder.decode_prefix(address, image.read(address, 256))?;
    let init = section == "initialization";
    for (index, ins) in instructions.iter().enumerate() {
        if ins.mnemonic == "call" || ins.mnemonic == "ret" {
            break;
        }
        let subtract_one = init
            && ins.mnemonic == "sub"
            && ins.operands.len() == 2
            && matches!(ins.operands[1].op_type, Imm(1));
        if !subtract_one
            && (ins.mnemonic != if init { "dec" } else { "inc" } || ins.operands.len() != 1)
        {
            continue;
        }
        if let Mem(m) = ins.operands[0].op_type
            && ins.operands[0].size == 4
            && m.base().0 == 0
            && m.index().0 == 0
            && instructions.get(index + 1).is_some_and(|i| {
                if init {
                    ["jne", "je", "jae", "ret"].contains(&i.mnemonic.as_str())
                } else {
                    ["jne", "je"].contains(&i.mnemonic.as_str())
                }
            })
        {
            return Ok(Some(m.disp() as u32));
        }
    }
    Ok(None)
}
pub fn unindexed_chunks(image: &Image, address: u32, decoder: &Decoder) -> Result<Vec<(u32, u32)>> {
    let mut branches = Vec::new();
    let mut end = None;
    for ins in decoder.decode_prefix(address, image.read(address, 4096))? {
        if ins.mnemonic.starts_with('j') {
            if let Some(Imm(a)) = ins.operands.first().map(|o| o.op_type.clone()) {
                if ins.operands.len() != 1 {
                    break;
                }
                branches.push(a as u32);
            } else {
                break;
            }
        }
        if ins.mnemonic == "ret" {
            end = Some(ins.end());
            break;
        }
        if ["int3", "ud2"].contains(&ins.mnemonic.as_str()) {
            break;
        }
    }
    let end = end
        .filter(|e| branches.iter().all(|a| (address..*e).contains(a)))
        .with_context(|| format!("Unit entry {address:#x} needs a native range index"))?;
    Ok(vec![(address, end)])
}
fn descriptors(
    image: &Image,
    address: u32,
    helpers: &BTreeSet<u32>,
    decoder: &Decoder,
) -> Result<Vec<u32>> {
    let decoded = decoder.decode_prefix(address, image.read(address, 4096))?;
    let mut out = Vec::new();
    for (i, ins) in decoded.iter().enumerate() {
        if i > 0
            && ins.mnemonic == "call"
            && matches!(ins.operands[0].op_type,Imm(a) if helpers.contains(&(a as u32)))
        {
            let prev = &decoded[i - 1];
            if prev.mnemonic == "mov"
                && prev.operands.len() == 2
                && matches!(prev.operands[0].op_type,Reg(r) if r.0 as u32==X86_REG_EAX)
                && let Imm(a) = prev.operands[1].op_type
            {
                out.push(a as u32);
            }
        }
        if ins.mnemonic == "ret" {
            break;
        }
    }
    Ok(out)
}
fn descriptor_identity(
    symbols: &Symbols,
    image: usize,
    table: u32,
) -> Option<Vec<(String, Vec<u8>)>> {
    let img = symbols.images[image];
    let count = img.u32(table)?;
    if count == 0 || count > 65536 {
        return None;
    }
    img.read_exact(table + 4, count as usize * 8).ok()?;
    let mut out = Vec::new();
    for index in 0..count {
        let entry = table + 4 + index * 8;
        let dest = img.u32(entry)?;
        let source = img.u32(entry + 4)?;
        if !img.relocated(entry) || !img.relocated(entry + 4) || img.u32(dest) != Some(0) {
            return None;
        }
        let identity = symbols.identity(image, dest, 0, false, 0)?;
        if identity.contains("unknown:") {
            return None;
        }
        let size = img.u32(source.checked_sub(4)?)? as usize;
        if !size.is_multiple_of(2) || size > 1 << 24 {
            return None;
        }
        let value = img.read_exact(source, size + 2).ok()?;
        if value[size..] != [0, 0] {
            return None;
        }
        out.push((identity, value.to_vec()));
    }
    Some(out)
}
pub fn bind_initializers(
    entry: &Entry,
    address: u32,
    symbols: &mut Symbols,
    decoder: &Decoder,
) -> Result<()> {
    let Some(helper) = symbols
        .evidence
        .wide_initializer
        .filter(|_| entry.section == "initialization")
    else {
        return Ok(());
    };
    let old = descriptors(
        symbols.images[0],
        entry.address,
        &BTreeSet::from([helper]),
        decoder,
    )?;
    let new = descriptors(
        symbols.images[1],
        address,
        &symbols
            .linked
            .iter()
            .filter(|(_, t)| **t == helper)
            .map(|(a, _)| *a)
            .collect(),
        decoder,
    )?;
    if old.len() == new.len() {
        for (index, (left, right)) in old.into_iter().zip(new).enumerate() {
            let expected = descriptor_identity(symbols, 0, left);
            if expected.is_some() && expected == descriptor_identity(symbols, 1, right) {
                symbols.bind(
                    right,
                    left,
                    Some(&format!("{}.WideStringInitializers{index}", entry.unit)),
                )?;
            }
        }
    }
    Ok(())
}
