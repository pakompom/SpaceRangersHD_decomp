//! Declaration-backed identities shared by all comparisons in one invocation.
use crate::{
    native::dccmap::Symbol,
    native::image::{Image, Import, ImportName},
    native::x86::Decoder,
    project::Project,
};
use anyhow::{Context, Result, ensure};
use serde_json::Value;
use std::{
    collections::{BTreeMap, BTreeSet},
    path::Path,
};
#[path = "identity.rs"]
mod identity;

pub fn key(name: &str) -> String {
    name.replace('.', "_")
        .to_lowercase()
        .trim_start_matches('_')
        .into()
}
pub fn unit(source: &str) -> String {
    Path::new(source.rsplit_once(':').map_or(source, |p| p.0))
        .file_stem()
        .unwrap_or_default()
        .to_string_lossy()
        .into()
}
pub fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}
pub fn imported(import: &Import) -> String {
    format!(
        "import:{}!{}",
        import.dll,
        match &import.name {
            ImportName::Name(s) => s.clone(),
            ImportName::Ordinal(n) => n.to_string(),
        }
    )
}
pub type Widths = BTreeMap<String, usize>;
pub struct FlowSymbols<'a, 'b> {
    pub symbols: &'a Symbols<'b>,
    pub image: usize,
}
impl crate::native::flow::Resolver for FlowSymbols<'_, '_> {
    fn name(&self, address: u32) -> String {
        let target = if self.image == 0 {
            Some(address)
        } else {
            self.symbols.linked.get(&address).copied()
        };
        target
            .and_then(|t| self.symbols.evidence.names.get(&t))
            .map(|n| n.to_lowercase())
            .unwrap_or_default()
    }
    fn terminal(&self, address: u32) -> bool {
        let target = if self.image == 0 {
            Some(address)
        } else {
            self.symbols.linked.get(&address).copied()
        };
        target.is_some_and(|t| self.symbols.evidence.terminal.contains(&t))
    }
}
#[derive(Default)]
pub struct Evidence {
    pub names: BTreeMap<u32, String>,
    pub aliases: BTreeMap<String, BTreeSet<u32>>,
    pub sizes: BTreeMap<u32, usize>,
    pub arrays: BTreeMap<u32, (i64, i64)>,
    pub array_offsets: BTreeMap<u32, BTreeSet<i64>>,
    pub indexed_references: BTreeMap<u32, u32>,
    pub constants: BTreeMap<u32, usize>,
    pub managed: BTreeMap<u32, Vec<(i64, String)>>,
    pub literals: BTreeMap<u32, Widths>,
    pub strings: BTreeMap<u32, Widths>,
    pub register_only: BTreeSet<u32>,
    pub guids: BTreeSet<Vec<u8>>,
    pub library_units: BTreeSet<String>,
    pub library_constants: BTreeMap<String, usize>,
    pub library_ends: BTreeMap<u32, u32>,
    pub library_owners: BTreeMap<u32, String>,
    pub terminal: BTreeSet<u32>,
    pub wide_initializer: Option<u32>,
}
static REGISTER_ARGUMENT: std::sync::LazyLock<regex::Regex> =
    std::sync::LazyLock::new(|| regex::Regex::new(r"(?i)\b(\w+)@<(eax|edx|ecx)>").unwrap());
static POINTER_ARGUMENT: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(|| {
    regex::Regex::new(r"(?i)\b(\w+)\s*\*\s*(\w+)@<(eax|edx|ecx)>").unwrap()
});

impl Evidence {
    pub fn new(project: &mut Project, native: &Image, ranges: &Value) -> Result<Self> {
        let mut e = Self::default();
        for d in project.compiler.decls.clone() {
            if d.kind == "interface"
                && let Some(guid) = d.data["guid_value"].as_str()
            {
                e.guids
                    .insert(uuid::Uuid::parse_str(guid)?.to_bytes_le().to_vec());
            }
            let Some(addr) = d
                .meta
                .get("addr")
                .and_then(Value::as_u64)
                .filter(|a| *a != 0)
                .map(|a| a as u32)
            else {
                continue;
            };
            if !["routine", "global", "constant"].contains(&d.kind.as_str()) {
                continue;
            }
            e.names.insert(addr, d.name.clone());
            for alias in [
                key(&d.name),
                key(&format!("{}.{}", unit(&d.source), d.name)),
            ] {
                e.aliases.entry(alias).or_default().insert(addr);
            }
            if let Some(local_name) = d.data["local_name"].as_str() {
                // DCC32's map omits the enclosing routine for nested helpers.
                e.aliases
                    .entry(key(&format!("{}.{}", unit(&d.source), local_name)))
                    .or_default()
                    .insert(addr);
            }
            if d.kind == "routine" {
                let proto = project.compiler.prototype(&d)?.unwrap_or_default();
                if proto.contains("__usercall")
                    && !proto.contains("@<^")
                    && !proto.contains("...")
                    && !d.meta.contains_key("countedstack")
                {
                    e.register_only.insert(addr);
                }
                let locations: BTreeMap<_, _> = REGISTER_ARGUMENT
                    .captures_iter(&proto)
                    .map(|m| (m[1].to_lowercase(), m[2].to_lowercase()))
                    .collect();
                let pointer_types: BTreeMap<_, _> = POINTER_ARGUMENT
                    .captures_iter(&proto)
                    .map(|m| (m[2].to_lowercase(), m[1].to_lowercase()))
                    .collect();
                for p in d.data["params"].as_array().into_iter().flatten() {
                    let name = p["name"].as_str().unwrap_or("");
                    let spec = p["type"].as_str().unwrap_or("");
                    let mode = p["mode"].as_str().unwrap_or("");
                    let loc = locations.get(&name.to_lowercase()).cloned();
                    if let Some(loc) = loc {
                        if ["value", "const"].contains(&mode) {
                            let width = match spec.to_lowercase().as_str() {
                                "pchar" | "pansichar" => 1,
                                "pwidechar" => 2,
                                _ => 0,
                            };
                            if width > 0 {
                                e.strings
                                    .entry(addr)
                                    .or_default()
                                    .insert(loc.clone(), width);
                            }
                        }
                        let is_set = project
                            .compiler
                            .types
                            .get(&spec.to_lowercase())
                            .is_some_and(|t| {
                                t.kind == "alias" && t.data["type"].get("set").is_some()
                            });
                        if mode == "value" && is_set {
                            let size = project.compiler.size(&p["type"])? as usize;
                            if size > 4
                                && pointer_types
                                    .get(&name.to_lowercase())
                                    .is_some_and(|t| t.eq_ignore_ascii_case(spec))
                            {
                                e.literals.entry(addr).or_default().insert(loc, size);
                            }
                        }
                    }
                }
            }
            if d.kind == "global" {
                e.sizes
                    .insert(addr, project.compiler.size(&d.data["type"])? as usize);
            }
            if d.kind == "global" || d.kind == "constant" {
                let mut spec = d.data["type"].clone();
                let mut seen = BTreeSet::new();
                while let Some(name) = spec.as_str() {
                    let name = name.to_lowercase();
                    if !seen.insert(name.clone()) {
                        break;
                    }
                    let Some(alias) = project
                        .compiler
                        .types
                        .get(&name)
                        .filter(|t| t.kind == "alias")
                    else {
                        break;
                    };
                    spec = alias.data["type"].clone();
                }
                if let Some(array) = spec.get("array") {
                    let stride = project.compiler.size(array)?;
                    e.arrays
                        .insert(addr, (spec["lower"].as_i64().unwrap_or(0) * stride, stride));
                }
            }
            if d.kind == "constant" || d.kind == "global" && d.data.get("initializer").is_some() {
                let size = project.compiler.size(&d.data["type"])? as usize;
                e.constants.insert(addr, size);
                e.sizes.insert(addr, size);
                e.managed
                    .insert(addr, project.compiler.managed_storage(&d.data["type"])?);
            }
        }
        let decoder = Decoder::new()?;
        for d in &project.compiler.decls {
            for site in d
                .meta
                .get("indexrefs")
                .and_then(Value::as_array)
                .into_iter()
                .flatten()
            {
                let site = site.as_u64().context("invalid @indexrefs address")? as u32;
                let base = d
                    .meta
                    .get("addr")
                    .and_then(Value::as_u64)
                    .context("@indexrefs needs @addr")? as u32;
                let &(bias, stride) = e
                    .arrays
                    .get(&base)
                    .context("@indexrefs needs a static array")?;
                let code = decoder.decode_prefix(site, native.read(site, 15))?;
                let ins = code.first().context("@indexrefs needs an instruction")?;
                let matching = ins
                    .operands
                    .iter()
                    .filter(|op| {
                        if let capstone::arch::x86::X86OperandType::Mem(m) = op.op_type {
                            m.base().0 == 0
                                && m.index().0 != 0
                                && m.segment().0 == 0
                                && m.scale() as i64 == stride
                                && op.size as i64 <= stride
                                && m.disp() as u32 == base.wrapping_sub(bias as u32)
                                && native.relocated(site + ins.disp_offset as u32)
                        } else {
                            false
                        }
                    })
                    .count();
                ensure!(
                    matching == 1,
                    "{}: @indexrefs {site:#x} is not the declared array's indexed base",
                    d.name
                );
                ensure!(
                    e.indexed_references.insert(site, base).is_none(),
                    "duplicate @indexrefs {site:#x}"
                );
            }
        }
        for doc in &project.documents {
            let arrays = doc
                .tree
                .children
                .iter()
                .filter_map(|n| n.declaration.as_ref())
                .filter(|d| ["global", "constant"].contains(&d.kind.as_str()))
                .filter_map(|d| {
                    d.meta
                        .get("addr")
                        .and_then(Value::as_u64)
                        .map(|a| (d.name.to_lowercase(), a as u32))
                })
                .filter(|(_, a)| e.arrays.contains_key(a))
                .collect::<BTreeMap<_, _>>();
            for ((owners, name), offsets) in doc.facts(true)?.indexed_offsets {
                let Some(addr) = arrays.get(&name) else {
                    continue;
                };
                let mut shadowed = false;
                for owner in owners {
                    if project.compiler.member_names(&owner)?.contains(&name) {
                        shadowed = true;
                        break;
                    }
                }
                if !shadowed {
                    e.array_offsets.entry(*addr).or_default().extend(offsets);
                }
            }
        }
        if let Some(constants) = project.library.data["constants"].as_object() {
            for (name, size) in constants {
                if let Some(n) = size.as_u64() {
                    e.library_constants.insert(name.clone(), n as usize);
                }
            }
        }
        for row in project.library.data["matches"]
            .as_array()
            .into_iter()
            .flatten()
        {
            let addr = u32::from_str_radix(
                row["address"]
                    .as_str()
                    .context("library address")?
                    .trim_start_matches("0x"),
                16,
            )?;
            let end = u32::from_str_radix(
                row["end"]
                    .as_str()
                    .context("library end")?
                    .trim_start_matches("0x"),
                16,
            )?;
            let name = row["symbol"].as_str().context("library name")?;
            let owner = row["unit"].as_str().context("library unit")?.to_lowercase();
            e.library_units.insert(owner.clone());
            e.library_owners.insert(addr, owner);
            e.library_ends.insert(addr, end);
            e.aliases.entry(key(name)).or_default().insert(addr);
            e.names.entry(addr).or_insert(name.into());
            if name == "System.@Halt0" {
                e.terminal.insert(addr);
            }
            if name == "System.@InitWideStrings" {
                e.wide_initializer = Some(addr);
            }
        }
        for d in &project.compiler.decls {
            let owner = unit(&d.source).to_lowercase();
            if d.kind == "routine"
                && e.library_units.contains(&owner)
                && let Some(addr) = d.meta.get("addr").and_then(Value::as_u64)
                && let Some(end) = ranges[addr.to_string()]["chunks"][0]["end"].as_u64()
            {
                e.library_ends.entry(addr as u32).or_insert(end as u32);
                // Reviewed declarations supersede historical equal-body probes.
                e.library_owners.insert(addr as u32, owner);
            }
        }
        for (vmt, class) in native.classes() {
            let addr = vmt - 76;
            e.names.insert(addr, format!("class:{}", class.name));
            for alias in [key(&format!("ClassRef_{}", class.name)), key(&class.name)] {
                e.aliases.entry(alias).or_default().insert(addr);
            }
        }
        Ok(e)
    }
}
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ArrayBase {
    pub base: u32,
    pub target: u32,
    pub offset: i64,
    pub remaining: i64,
    pub stride: i64,
}
#[derive(Default)]
pub struct ImageSymbols {
    pub constants: BTreeMap<u32, usize>,
    pub arrays: BTreeMap<u32, Vec<ArrayBase>>,
    pub globals: BTreeMap<u32, (u32, u32)>,
    pub initializers: Option<BTreeMap<u32, Vec<u8>>>,
}
pub struct Symbols<'a> {
    pub images: [&'a Image; 2],
    pub evidence: Evidence,
    pub linked: BTreeMap<u32, u32>,
    pub link_names: BTreeMap<u32, String>,
    pub states: [ImageSymbols; 2],
    pub pending: Vec<(Symbol, BTreeSet<u32>)>,
    pub short_comparisons: BTreeSet<u32>,
    pub short_copies: BTreeSet<u32>,
    pub literal_calls: BTreeSet<u32>,
}
impl<'a> Symbols<'a> {
    pub fn resolve_overloads(&mut self, linked: &[Symbol], decoder: &Decoder) -> Result<()> {
        use crate::matching::{ExactBody, function};
        let mut sections: BTreeMap<u16, Vec<u32>> = BTreeMap::new();
        for symbol in linked {
            sections
                .entry(symbol.section)
                .or_default()
                .push(symbol.address);
        }
        for addresses in sections.values_mut() {
            addresses.sort_unstable();
        }
        let mut pending = std::mem::take(&mut self.pending);
        while !pending.is_empty() {
            let mut remaining = Vec::new();
            let mut progress = false;
            for (symbol, candidates) in pending {
                let mut exact = Vec::new();
                for &address in &candidates {
                    let Some(&end) = self.evidence.library_ends.get(&address) else {
                        continue;
                    };
                    let size = end - address;
                    let addresses = &sections[&symbol.section];
                    let next = addresses.partition_point(|a| *a <= symbol.address);
                    if addresses
                        .get(next)
                        .is_some_and(|a| *a < symbol.address + size)
                    {
                        continue;
                    }
                    let saved = self.states[0].constants.clone();
                    let rebuilt = self.images[1];
                    let native = self.images[0];
                    for &relocation in &rebuilt.relocations[rebuilt
                        .relocations
                        .partition_point(|a| *a < symbol.address)
                        ..rebuilt
                            .relocations
                            .partition_point(|a| *a < symbol.address + size)]
                    {
                        if let Some(width) = rebuilt
                            .u32(relocation)
                            .and_then(|v| self.states[1].constants.get(&v))
                            .copied()
                        {
                            let counterpart = address + relocation - symbol.address;
                            if native.relocated(counterpart)
                                && let Some(target) = native.u32(counterpart)
                                && !self.evidence.names.contains_key(&target)
                            {
                                self.states[0].constants.insert(target, width);
                            }
                        }
                    }
                    let original = function(0, address, &[(address, end)], self, decoder, false)?;
                    if ExactBody::from_function(&original, native)
                        .and_then(|body| {
                            body.compare(
                                &symbol.name,
                                address,
                                symbol.address,
                                symbol.address + size,
                                self,
                            )
                        })
                        .is_some()
                    {
                        exact.push((address, self.states[0].constants.clone()));
                    }
                    self.states[0].constants = saved;
                }
                if exact.len() == 1 {
                    let (address, constants) = exact.pop().unwrap();
                    self.states[0].constants = constants;
                    self.linked.insert(symbol.address, address);
                    progress = true;
                } else {
                    remaining.push((symbol, candidates));
                }
            }
            pending = remaining;
            if !progress {
                break;
            }
        }
        self.pending = pending;
        self.refresh();
        Ok(())
    }
    pub fn new(
        project: &mut Project,
        native: &'a Image,
        rebuilt: &'a Image,
        linked: &[Symbol],
        decoder: &Decoder,
        ranges: &Value,
    ) -> Result<Self> {
        let e = Evidence::new(project, native, ranges)?;
        let mut helper_aliases: BTreeMap<String, BTreeSet<u32>> = BTreeMap::new();
        for (name, targets) in &e.aliases {
            helper_aliases
                .entry(name.replace('@', ""))
                .or_default()
                .extend(targets);
        }
        let mut s = Self {
            images: [native, rebuilt],
            evidence: e,
            linked: BTreeMap::new(),
            link_names: linked.iter().map(|s| (s.address, s.name.clone())).collect(),
            states: Default::default(),
            pending: Vec::new(),
            short_comparisons: BTreeSet::new(),
            short_copies: BTreeSet::new(),
            literal_calls: BTreeSet::new(),
        };
        for (&a, n) in &s.evidence.names {
            if ["astrcmp", "system_@astrcmp"].contains(&key(n).as_str()) {
                s.short_comparisons.insert(a);
            }
            if ["pstrcpy", "pstrncat", "system_@pstrcpy", "system_@pstrncat"]
                .contains(&key(n).as_str())
            {
                s.short_copies.insert(a);
            }
        }
        s.literal_calls.extend(s.evidence.literals.keys());
        s.literal_calls.extend(s.evidence.strings.keys());
        s.literal_calls.extend(&s.evidence.register_only);
        s.literal_calls.extend(&s.short_comparisons);
        s.literal_calls.extend(&s.short_copies);
        let mut counts: BTreeMap<&str, usize> = BTreeMap::new();
        for sym in linked.iter().filter(|s| s.section == 1) {
            *counts.entry(&sym.name).or_default() += 1;
        }
        let mut prefixes: BTreeMap<(String, Vec<u8>), BTreeSet<u32>> = BTreeMap::new();
        for &a in s.evidence.library_ends.keys() {
            if let Some(p) = native.prefix(decoder, a, 1, 1)? {
                prefixes
                    .entry((s.evidence.library_owners[&a].clone(), p))
                    .or_default()
                    .insert(a);
            }
        }
        for sym in linked {
            if let Some(&width) = s.evidence.library_constants.get(&sym.name) {
                s.states[1].constants.insert(sym.address, width);
            }
            let parts = sym.name.split('.').collect::<Vec<_>>();
            for i in 0..parts.len() {
                let spelling = key(&parts[i..].join("."));
                let mut targets = s
                    .evidence
                    .aliases
                    .get(&spelling)
                    .cloned()
                    .unwrap_or_default();
                if targets.is_empty()
                    && spelling.contains('@')
                    && let Some(f) = helper_aliases
                        .get(spelling.replace('@', "").trim_start_matches('_'))
                        .filter(|v| v.len() == 1)
                {
                    targets = f.clone();
                }
                if targets.is_empty() {
                    continue;
                }
                if targets.len() == 1 && counts.get(sym.name.as_str()).copied().unwrap_or(0) <= 1 {
                    s.linked.insert(sym.address, *targets.first().unwrap());
                } else if sym.section == 1 {
                    let signature = rebuilt.prefix(decoder, sym.address, 1, 1)?;
                    let mut valid = BTreeSet::new();
                    for a in targets {
                        if native.prefix(decoder, a, 1, 1)? == signature {
                            valid.insert(a);
                        }
                    }
                    if let Some(p) = signature
                        && let Some(c) = prefixes.get(&(parts[0].to_lowercase(), p))
                    {
                        valid.extend(c);
                    }
                    s.pending.push((sym.clone(), valid));
                }
                break;
            }
        }
        for sym in linked {
            if sym.section == 1
                && !s.linked.contains_key(&sym.address)
                && !s.pending.iter().any(|(p, _)| p == sym)
                && s.evidence
                    .library_units
                    .contains(&sym.name.split('.').next().unwrap().to_lowercase())
                && let Some(p) = rebuilt.prefix(decoder, sym.address, 1, 1)?
                && let Some(c) =
                    prefixes.get(&(sym.name.split('.').next().unwrap().to_lowercase(), p))
            {
                s.pending.push((sym.clone(), c.clone()));
            }
        }
        s.states[0].constants = s.evidence.constants.clone();
        for (&base, &target) in &s.linked {
            if let Some(&width) = s.evidence.constants.get(&target) {
                s.states[1].constants.insert(base, width);
            }
        }
        s.refresh();
        Ok(s)
    }
    pub fn refresh(&mut self) {
        for image in 0..2 {
            let bases: Vec<_> = if image == 0 {
                self.evidence.arrays.keys().map(|a| (*a, *a)).collect()
            } else {
                self.linked
                    .iter()
                    .filter(|(_, t)| self.evidence.arrays.contains_key(t))
                    .map(|(a, t)| (*a, *t))
                    .collect()
            };
            self.states[image].arrays.clear();
            for (base, target) in bases {
                let (bias, stride) = self.evidence.arrays[&target];
                let mut offsets = self
                    .evidence
                    .array_offsets
                    .get(&target)
                    .cloned()
                    .unwrap_or_default();
                offsets.insert(0);
                for offset in offsets {
                    let adjustment = offset * stride - bias;
                    if adjustment == 0 {
                        continue;
                    }
                    for field in 0..stride {
                        let address = base.wrapping_add((adjustment + field) as u32);
                        let candidate = ArrayBase {
                            base,
                            target,
                            offset: field + adjustment,
                            remaining: stride - field,
                            stride,
                        };
                        let candidates = self.states[image].arrays.entry(address).or_default();
                        if !candidates.contains(&candidate) {
                            candidates.push(candidate);
                        }
                    }
                }
            }
            let sizes = if image == 0 {
                self.evidence.sizes.clone()
            } else {
                self.linked
                    .iter()
                    .filter_map(|(a, t)| self.evidence.sizes.get(t).map(|n| (*a, *n)))
                    .collect()
            };
            self.states[image].globals = self.images[image]
                .global_references(&sizes)
                .into_iter()
                .map(|(cell, (base, offset))| {
                    (
                        cell,
                        (if image == 0 { base } else { self.linked[&base] }, offset),
                    )
                })
                .collect();
            let helpers = if image == 0 {
                self.evidence.wide_initializer.into_iter().collect()
            } else {
                self.linked
                    .iter()
                    .filter(|(_, t)| Some(**t) == self.evidence.wide_initializer)
                    .map(|(a, _)| *a)
                    .collect()
            };
            self.states[image].initializers = self.images[image].wide_string_initializers(&helpers);
        }
    }
    pub fn bind(&mut self, address: u32, target: u32, name: Option<&str>) -> Result<()> {
        if let Some(n) = name {
            self.evidence.names.entry(target).or_insert(n.into());
        }
        if let Some(old) = self.linked.insert(address, target) {
            ensure!(
                old == target,
                "Conflicting native identities for {address:#x}"
            );
        }
        Ok(())
    }
    pub fn bind_indirect(&mut self, name: &str, address: u32, native: u32) -> Result<()> {
        let cells = self.images[1].references_to(address);
        ensure!(
            cells.len() == 1,
            "Expected one cross-unit reference cell for {name}, found {}",
            cells.len()
        );
        let target = self.images[0]
            .u32(native)
            .context("native cross-unit pointer")?;
        ensure!(
            self.linked.get(&address).is_none_or(|t| *t == target),
            "Cross-unit reference {name} has wrong target"
        );
        self.bind(cells[0], native, Some(name))
    }
    pub fn flow(&self, image: usize) -> crate::native::flow::Symbols {
        crate::native::flow::Symbols {
            names: if image == 0 {
                self.evidence.names.clone()
            } else {
                self.linked
                    .iter()
                    .filter_map(|(a, t)| self.evidence.names.get(t).map(|n| (*a, n.clone())))
                    .collect()
            },
            terminal_calls: if image == 0 {
                self.evidence.terminal.clone()
            } else {
                self.linked
                    .iter()
                    .filter(|(_, t)| self.evidence.terminal.contains(t))
                    .map(|(a, _)| *a)
                    .collect()
            },
        }
    }
}
