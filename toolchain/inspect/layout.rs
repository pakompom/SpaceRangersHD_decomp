//! Physical PE layout and named startup rows, independent of routine byte matching.
use crate::{
    compiler::{build, worker::Toolchain},
    matching::{
        symbols::{Symbols, unit},
        unit_entries::{self, StartupTable},
    },
    native::{
        dccmap::{MapFile, Symbol},
        image::Image,
        index::NativeIndex,
        resources::{self, Key, PackageInfo},
        x86::Decoder,
    },
    project::Project,
    util::{array, string},
};
use anyhow::{Context, Result, ensure};
use goblin::pe::PE;
use serde::Serialize;
use serde_json::Value;
use std::{
    collections::{BTreeMap, BTreeSet},
    fmt::Write,
    fs,
    path::Path,
};

#[derive(Serialize)]
struct Section {
    name: String,
    address: u32,
    virtual_size: u32,
    file_offset: u32,
    file_size: u32,
    flags: u32,
}
#[derive(Serialize)]
struct PeLayout {
    file_bytes: usize,
    image_base: u64,
    entry: u64,
    timestamp: u32,
    image_size: u32,
    section_alignment: u32,
    file_alignment: u32,
    subsystem: u16,
    sections: Vec<Section>,
    import_slots: usize,
    exports: usize,
    relocation_slots: usize,
}
impl PeLayout {
    fn read(bytes: &[u8], image: &Image) -> Result<Self> {
        let pe = PE::parse(bytes)?;
        let header = pe
            .header
            .optional_header
            .context("PE optional header missing")?;
        Ok(Self {
            file_bytes: bytes.len(),
            image_base: pe.image_base as u64,
            entry: pe.image_base as u64 + pe.entry as u64,
            timestamp: pe.header.coff_header.time_date_stamp,
            image_size: header.windows_fields.size_of_image,
            section_alignment: header.windows_fields.section_alignment,
            file_alignment: header.windows_fields.file_alignment,
            subsystem: header.windows_fields.subsystem,
            sections: pe
                .sections
                .iter()
                .map(|s| {
                    Ok(Section {
                        name: s.name()?.into(),
                        address: image
                            .base
                            .checked_add(s.virtual_address)
                            .context("section address overflow")?,
                        virtual_size: s.virtual_size,
                        file_offset: s.pointer_to_raw_data,
                        file_size: s.size_of_raw_data,
                        flags: s.characteristics,
                    })
                })
                .collect::<Result<_>>()?,
            import_slots: image.imports.len(),
            exports: pe.exports.len(),
            relocation_slots: image.relocations.len(),
        })
    }
}
#[derive(Serialize)]
struct Anchor {
    name: String,
    unit: String,
    native: u32,
    rebuilt: u32,
}
#[derive(Serialize)]
struct UnitLayout {
    unit: String,
    anchors: usize,
    same_address: usize,
    native_first: u32,
    rebuilt_first: u32,
    min_shift: i64,
    max_shift: i64,
    order_preserved: bool,
}
fn units(anchors: &[Anchor]) -> Vec<UnitLayout> {
    let mut grouped: BTreeMap<&str, Vec<&Anchor>> = BTreeMap::new();
    for a in anchors {
        grouped.entry(&a.unit).or_default().push(a);
    }
    let mut out = Vec::new();
    for (unit, mut rows) in grouped {
        rows.sort_by_key(|r| (r.native, r.rebuilt));
        let shifts = rows
            .iter()
            .map(|r| i64::from(r.rebuilt) - i64::from(r.native));
        out.push(UnitLayout {
            unit: unit.into(),
            anchors: rows.len(),
            same_address: rows.iter().filter(|r| r.native == r.rebuilt).count(),
            native_first: rows[0].native,
            rebuilt_first: rows.iter().map(|r| r.rebuilt).min().unwrap(),
            min_shift: shifts.clone().min().unwrap(),
            max_shift: shifts.max().unwrap(),
            order_preserved: rows.windows(2).all(|p| p[0].rebuilt <= p[1].rebuilt),
        });
    }
    out.sort_by_key(|u| u.native_first);
    out
}
#[derive(Serialize)]
struct StartupRow {
    unit: String,
    native_index: usize,
    rebuilt_index: Option<usize>,
    native_init: u32,
    native_fini: u32,
    rebuilt_init: Option<u32>,
    rebuilt_fini: Option<u32>,
}
#[derive(Serialize)]
struct Layout {
    executable: String,
    identical_file: bool,
    native: PeLayout,
    rebuilt: PeLayout,
    native_startup: StartupTable,
    rebuilt_startup: StartupTable,
    startup_rows: Vec<StartupRow>,
    anchors: Vec<Anchor>,
    units: Vec<UnitLayout>,
    native_package: PackageInfo,
    rebuilt_package: PackageInfo,
    resources: Vec<ResourceDifference>,
}

#[derive(Serialize)]
struct ResourceDifference {
    kind: Key,
    name: Key,
    language: u32,
    native_bytes: Option<usize>,
    rebuilt_bytes: Option<usize>,
    identical: bool,
}
fn resource_evidence(
    original: &[u8],
    native: &Image,
    file: &[u8],
    rebuilt: &Image,
) -> Result<(PackageInfo, PackageInfo, Vec<ResourceDifference>)> {
    let a = resources::read(original, native)?;
    let b = resources::read(file, rebuilt)?;
    let package = |rows: &[resources::Resource<'_>]| {
        let data = rows
            .iter()
            .find(|r| r.kind == Key::Id(10) && r.name == Key::Name("PACKAGEINFO".into()))
            .context("Missing PACKAGEINFO resource")?;
        PackageInfo::parse(data.data)
    };
    let keys = a
        .iter()
        .chain(&b)
        .map(|r| (&r.kind, &r.name, r.language))
        .collect::<BTreeSet<_>>();
    let mut differences = Vec::new();
    for (kind, name, language) in keys {
        let find = |rows: &[resources::Resource<'_>]| {
            rows.iter()
                .position(|r| &r.kind == kind && &r.name == name && r.language == language)
        };
        let x = find(&a).map(|i| a[i].data);
        let y = find(&b).map(|i| b[i].data);
        differences.push(ResourceDifference {
            kind: kind.clone(),
            name: name.clone(),
            language,
            native_bytes: x.map(<[u8]>::len),
            rebuilt_bytes: y.map(<[u8]>::len),
            identical: x == y,
        });
    }
    Ok((package(&a)?, package(&b)?, differences))
}
fn address(row: &Value, field: &str) -> Result<u32> {
    let text = row[field]
        .as_str()
        .with_context(|| format!("Missing {field} address"))?;
    Ok(u32::from_str_radix(text.trim_start_matches("0x"), 16)?)
}
fn startup_rows(
    evidence: &Value,
    native: &StartupTable,
    rebuilt: &StartupTable,
    linked: &[Symbol],
    project: &Project,
) -> Result<Vec<StartupRow>> {
    let entries = unit_entries::entries(project)?;
    let mut out = Vec::new();
    for row in array(&evidence["startup"], "entries") {
        let name = string(row, "unit");
        let init = address(row, "init")?;
        let fini = address(row, "fini")?;
        let positions = native
            .pairs
            .iter()
            .enumerate()
            .filter(|(_, p)| **p == (init, fini))
            .map(|(i, _)| i)
            .collect::<Vec<_>>();
        ensure!(
            positions.len() == 1,
            "Native startup evidence for {name} is not unique or no longer matches the binary"
        );
        // The root's maintained filename and actual program name can differ.
        let linked_name = entries
            .iter()
            .find(|e| e.address == fini)
            .and_then(|e| e.linked_unit.as_deref())
            .unwrap_or(name);
        let finalizers: BTreeSet<_> = linked
            .iter()
            .filter(|s| {
                s.name
                    .eq_ignore_ascii_case(&format!("{linked_name}.finalization"))
            })
            .map(|s| s.address)
            .collect();
        let candidates = rebuilt
            .pairs
            .iter()
            .enumerate()
            .filter(|(_, (_, f))| *f != 0 && finalizers.contains(f))
            .collect::<Vec<_>>();
        let found = if candidates.len() == 1 {
            Some(candidates[0])
        } else {
            None
        };
        out.push(StartupRow {
            unit: name.into(),
            native_index: positions[0],
            rebuilt_index: found.map(|r| r.0),
            native_init: init,
            native_fini: fini,
            rebuilt_init: found.map(|r| r.1.0),
            rebuilt_fini: found.map(|r| r.1.1),
        });
    }
    out.sort_by_key(|r| r.native_index);
    Ok(out)
}
impl Layout {
    fn text(&self, details: bool, selected: Option<&str>) -> String {
        let mut out = String::new();
        let _ = writeln!(out, "Physical executable layout (native → rebuilt)");
        let _ = writeln!(
            out,
            "Build: {} (smart linked; no matching exports or address trampolines)",
            self.executable
        );
        let _ = writeln!(
            out,
            "Files: {} → {} bytes; byte-identical: {}",
            self.native.file_bytes, self.rebuilt.file_bytes, self.identical_file
        );
        let _ = writeln!(
            out,
            "Image base: {:08X} → {:08X}; entry: {:08X} → {:08X}",
            self.native.image_base, self.rebuilt.image_base, self.native.entry, self.rebuilt.entry
        );
        let _ = writeln!(
            out,
            "Imports: {} → {}; exports: {} → {}; relocations: {} → {}",
            self.native.import_slots,
            self.rebuilt.import_slots,
            self.native.exports,
            self.rebuilt.exports,
            self.native.relocation_slots,
            self.rebuilt.relocation_slots
        );
        let _ = writeln!(
            out,
            "Section       Native VA    Rebuilt VA      Virtual bytes       File bytes"
        );
        let names = self
            .native
            .sections
            .iter()
            .chain(&self.rebuilt.sections)
            .map(|s| s.name.as_str())
            .collect::<BTreeSet<_>>();
        for name in names {
            let a = self.native.sections.iter().find(|s| s.name == name);
            let b = self.rebuilt.sections.iter().find(|s| s.name == name);
            let _ = writeln!(
                out,
                "{name:12} {:>9} → {:<9} {:>8} → {:<8} {:>8} → {}",
                a.map_or("—".into(), |s| format!("{:08X}", s.address)),
                b.map_or("—".into(), |s| format!("{:08X}", s.address)),
                a.map_or(0, |s| s.virtual_size),
                b.map_or(0, |s| s.virtual_size),
                a.map_or(0, |s| s.file_size),
                b.map_or(0, |s| s.file_size)
            );
        }
        let live = |t: &StartupTable| t.pairs.iter().filter(|p| **p != (0, 0)).count();
        let same_rows = self
            .startup_rows
            .iter()
            .filter(|r| r.rebuilt_index == Some(r.native_index))
            .count();
        let _ = writeln!(
            out,
            "Startup: {} → {} rows; {} → {} live; {}/{} named rows at the same index",
            self.native_startup.pairs.len(),
            self.rebuilt_startup.pairs.len(),
            live(&self.native_startup),
            live(&self.rebuilt_startup),
            same_rows,
            self.startup_rows.len()
        );
        let _ = writeln!(
            out,
            "Zero pairs remain anonymous; PACKAGEINFO order does not identify startup rows."
        );
        let names = |p: &PackageInfo| {
            p.units
                .iter()
                .map(|u| u.name.to_lowercase())
                .collect::<BTreeSet<_>>()
        };
        let native_names = names(&self.native_package);
        let rebuilt_names = names(&self.rebuilt_package);
        let _ = writeln!(
            out,
            "PACKAGEINFO: {} → {} modules; {} native-only, {} rebuilt-only",
            self.native_package.units.len(),
            self.rebuilt_package.units.len(),
            native_names.difference(&rebuilt_names).count(),
            rebuilt_names.difference(&native_names).count()
        );
        let _ = writeln!(
            out,
            "Resources: {}/{} leaves byte-identical (including generated metadata)",
            self.resources.iter().filter(|r| r.identical).count(),
            self.resources.len()
        );
        if details {
            for (label, package, other) in [
                ("Native-only modules", &self.native_package, &rebuilt_names),
                ("Rebuilt-only modules", &self.rebuilt_package, &native_names),
            ] {
                let missing = package
                    .units
                    .iter()
                    .filter(|u| !other.contains(&u.name.to_lowercase()))
                    .map(|u| u.name.as_str())
                    .collect::<Vec<_>>();
                let _ = writeln!(out, "  {label}: {}", missing.join(", "));
            }
        }
        let rows = self
            .startup_rows
            .iter()
            .filter(|r| selected.is_none_or(|u| r.unit.eq_ignore_ascii_case(u)))
            .filter(|r| details || r.rebuilt_index != Some(r.native_index));
        for r in rows.take(if details || selected.is_some() {
            usize::MAX
        } else {
            10
        }) {
            let _ = writeln!(
                out,
                "  {:24} row {:3} → {}",
                r.unit,
                r.native_index,
                r.rebuilt_index
                    .map_or("unresolved".into(), |i| i.to_string())
            );
        }
        let same = self
            .anchors
            .iter()
            .filter(|r| r.native == r.rebuilt)
            .count();
        let _ = writeln!(
            out,
            "Code symbols: {same}/{} at native addresses; {}/{} units retain the order of their known code symbols",
            self.anchors.len(),
            self.units.iter().filter(|u| u.order_preserved).count(),
            self.units.len()
        );
        let _ = writeln!(
            out,
            "Unit                     Symbols Native first Rebuilt first     Address shift range"
        );
        for u in self
            .units
            .iter()
            .filter(|u| selected.is_none_or(|s| u.unit.eq_ignore_ascii_case(s)))
            .take(if details || selected.is_some() {
                usize::MAX
            } else {
                15
            })
        {
            let _ = writeln!(
                out,
                "{:24} {:7}     {:08X}      {:08X} {:+10} .. {:+10}{}",
                u.unit,
                u.anchors,
                u.native_first,
                u.rebuilt_first,
                u.min_shift,
                u.max_shift,
                if u.order_preserved { "" } else { " reordered" }
            );
        }
        let _ = writeln!(
            out,
            "Symbol anchors do not establish full unit boundaries. Use --details or --unit NAME; --json includes every anchor and startup pair."
        );
        out
    }
}
pub fn command(
    root: &Path,
    worker: Option<&str>,
    details: bool,
    selected: Option<&str>,
    json: bool,
) -> Result<String> {
    let mut project = Project::open(root)?;
    let tc = Toolchain::load(root, worker)?;
    tc.start()?;
    let built = build::layout(&mut project, &tc)?.compilation;
    ensure!(
        built.status == 0,
        "Compilation failed; {}\n{}",
        built.log.display(),
        built
            .output
            .lines()
            .filter(|l| l.contains("Error:") || l.contains("Fatal:"))
            .collect::<Vec<_>>()
            .join("\n")
    );
    let original = fs::read(project.path("binary")?)?;
    let native = Image::parse(original.clone())?;
    let rebuilt = Image::parse(built.image_data.clone())?;
    let (native_package, rebuilt_package, resources) =
        resource_evidence(&original, &native, &built.image_data, &rebuilt)?;
    let map = MapFile::parse(&built.map_data)?;
    let index = NativeIndex::read(&project.path("cache")?)?;
    let decoder = Decoder::new()?;
    let mut symbols = Symbols::new(
        &mut project,
        &native,
        &rebuilt,
        &map.symbols,
        &decoder,
        &index.ranges,
    )?;
    symbols.resolve_overloads(&map.symbols, &decoder)?;
    let native_symbols = array(&project.library.data, "matches")
        .iter()
        .map(|r| {
            Ok(Symbol {
                address: address(r, "address")?,
                name: string(r, "symbol").into(),
                section: 1,
            })
        })
        .collect::<Result<Vec<_>>>()?;
    let native_startup = unit_entries::startup_table(&native, &native_symbols, &decoder)?;
    let rebuilt_startup = unit_entries::startup_table(&rebuilt, &map.symbols, &decoder)?;
    let evidence: Value =
        serde_json::from_slice(&fs::read(root.join("reference/unit_ownership.json"))?)?;
    let startup_rows = startup_rows(
        &evidence,
        &native_startup,
        &rebuilt_startup,
        &map.symbols,
        &project,
    )?;
    let owners: BTreeMap<_, _> = project
        .compiler
        .decls
        .iter()
        .filter(|d| d.kind == "routine")
        .filter_map(|d| {
            d.meta
                .get("addr")?
                .as_u64()
                .map(|a| (a as u32, unit(&d.source)))
        })
        .collect();
    let mut seen = BTreeSet::new();
    let anchors: Vec<_> = map
        .symbols
        .iter()
        .filter(|s| s.section == 1)
        .filter_map(|s| {
            let &native = symbols.linked.get(&s.address)?;
            index.ranges.get(native.to_string())?;
            // An external declaration can reside in any consumer unit; it does
            // not establish which native unit emitted the DLL import thunk.
            if symbols.images[0].imported_target(native).is_some() {
                return None;
            }
            let owner = symbols
                .evidence
                .library_owners
                .get(&native)
                .or_else(|| owners.get(&native))?;
            let linked_owner = map.unit_at(s.address)?;
            // MAP aliases folded onto another unit's code do not establish
            // the aliasing unit's physical contribution.
            if !owner.eq_ignore_ascii_case(linked_owner) {
                return None;
            }
            if !seen.insert((native, s.address)) {
                return None;
            }
            Some(Anchor {
                name: s.name.clone(),
                unit: linked_owner.into(),
                native,
                rebuilt: s.address,
            })
        })
        .collect();
    let result = Layout {
        executable: built.executable.display().to_string(),
        identical_file: original == built.image_data,
        native: PeLayout::read(&original, &native)?,
        rebuilt: PeLayout::read(&built.image_data, &rebuilt)?,
        native_startup,
        rebuilt_startup,
        startup_rows,
        units: units(&anchors),
        anchors,
        native_package,
        rebuilt_package,
        resources,
    };
    if json {
        Ok(serde_json::to_string_pretty(&result)? + "\n")
    } else {
        Ok(result.text(details, selected))
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn uniform_shift_is_distinct_from_reordering() {
        let anchors = [(10, 30), (20, 40), (50, 15), (60, 5)]
            .into_iter()
            .map(|(native, rebuilt)| Anchor {
                name: String::new(),
                unit: if native < 50 { "A" } else { "B" }.into(),
                native,
                rebuilt,
            })
            .collect::<Vec<_>>();
        let groups = units(&anchors);
        assert!(groups[0].order_preserved);
        assert_eq!((groups[0].min_shift, groups[0].max_shift), (20, 20));
        assert!(!groups[1].order_preserved);
        assert_eq!(groups[1].same_address, 0);
    }
}
