//! Evidence-bracket ownership and declaration coverage, independent of IDA transport.
use crate::{
    matching::symbols::unit,
    pascal::model::Decl,
    util::{array, string, yes},
};
use anyhow::{Result, ensure};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
pub const CATEGORIES: [&str; 5] = [
    "game_engine",
    "stdlib",
    "third_party",
    "imports",
    "unresolved",
];
pub const STDLIB: &str = "system sysinit types windows sysutils sysconst rtlconsts consts classes typinfo variants varutils registry helpintfs graphics stdctrls extctrls dialogs clipbrd stdactns menus controls imglist actnlist forms math dateutils strutils widestrutils inifiles syncobjs messages activex imagehlp uxtheme commctrl dwmapi themes contnrs imm multimon shlobj urlmon wininet regstr shellapi dlgs graphutil printers winspool commdlg flatsb mmsystem direct3d9 directsound vfw tlhelp32 psapi accctrl aclapi directdraw";
pub fn category(unit: &str) -> &'static str {
    let unit = unit.to_lowercase();
    if STDLIB.split_whitespace().any(|s| s == unit) {
        "stdlib"
    } else if ["jpeg", "jconsts", "fgint", "fgintrsa", "vorbisfile"].contains(&unit.as_str()) {
        "third_party"
    } else {
        "game_engine"
    }
}
pub fn n(row: &Value, key: &str) -> u32 {
    row[key].as_u64().unwrap_or(0) as u32
}
fn addr(value: &Value) -> Result<u32> {
    if let Some(a) = value.as_u64() {
        return Ok(a as u32);
    }
    let text = value.as_str().unwrap_or("");
    Ok(u32::from_str_radix(
        text.trim_start_matches("0x").trim_start_matches('$'),
        16,
    )?)
}
#[derive(Clone)]
struct Interval {
    low: u32,
    high: u32,
    labels: BTreeSet<String>,
}
fn merge(mut rows: Vec<Interval>) -> Vec<Interval> {
    rows.sort_by_key(|r| (r.low, r.high));
    let mut out: Vec<Interval> = Vec::new();
    for row in rows {
        if let Some(last) = out.last_mut()
            && row.low <= last.high
        {
            last.high = last.high.max(row.high);
            last.labels.extend(row.labels);
            continue;
        }
        out.push(row);
    }
    out
}
pub fn infer(
    snapshot: &Value,
    evidence: &Value,
    manifest: &Value,
    declarations: &[Decl],
) -> Result<(Vec<Value>, Vec<Value>, Vec<String>)> {
    let section = |ea: u32| {
        array(snapshot, "sections")
            .iter()
            .find(|s| n(s, "low") <= ea && ea < n(s, "high"))
            .map(|s| string(s, "name").to_string())
    };
    let functions = array(snapshot, "functions")
        .iter()
        .map(|f| (n(f, "ea"), f))
        .collect::<BTreeMap<_, _>>();
    let modules = array(evidence, "modules")
        .iter()
        .filter_map(Value::as_str)
        .map(|u| (u.to_lowercase(), u.to_string()))
        .collect::<BTreeMap<_, _>>();
    let classes = array(snapshot, "classes")
        .iter()
        .map(|c| (string(c, "name").to_string(), c))
        .collect::<BTreeMap<_, _>>();
    let mut points: BTreeMap<(String, String), Vec<u32>> = BTreeMap::new();
    let mut intervals: BTreeMap<String, Vec<Interval>> = BTreeMap::new();
    let mut seeds = BTreeMap::new();
    for row in array(evidence, "classes") {
        let name = string(row, "name");
        let c = classes.get(name);
        ensure!(
            c.is_some_and(
                |c| n(c, "vmt").saturating_sub(76) == addr(&row["vmt_header_va"]).unwrap_or(0)
            ),
            "Class evidence no longer matches: {name}"
        );
        seeds.insert(name.to_string(), string(row, "unit").to_string());
    }
    let anchor = |points: &mut BTreeMap<(String, String), Vec<u32>>, ea: u32, unit: &str| {
        if let Some(sec) = section(ea) {
            let end = functions.get(&ea).map_or(ea + 1, |f| n(f, "end"));
            points
                .entry((sec, unit.into()))
                .or_default()
                .extend([ea, end - 1]);
        }
    };
    let mut issues = Vec::new();
    let mut header_units = BTreeMap::new();
    let mut present_units = declarations
        .iter()
        .map(|d| unit(&d.source).to_lowercase())
        .collect::<BTreeSet<_>>();
    present_units.extend(
        array(manifest, "functions")
            .iter()
            .map(|f| unit(string(f, "source")).to_lowercase()),
    );
    for row in array(evidence, "header_units") {
        let name = string(row, "header_unit");
        let native = row["native_unit"].as_str();
        if header_units.contains_key(&name.to_lowercase()) {
            issues.push(format!("{name}: duplicate header unit mapping"));
        }
        if !present_units.contains(&name.to_lowercase()) {
            issues.push(format!(
                "{name}: header unit mapping no longer matches a source unit"
            ));
        }
        if let Some(native) = native
            && !modules.contains_key(&native.to_lowercase())
        {
            issues.push(format!("{name}: mapped native unit {native} is not linked"));
        }
        header_units.insert(
            name.to_lowercase(),
            native.and_then(|n| modules.get(&n.to_lowercase())).cloned(),
        );
    }
    let header_unit = |source: &str, issues: &mut Vec<String>| {
        let name = unit(source).to_lowercase();
        if let Some(mapped) = header_units.get(&name) {
            return mapped.clone();
        }
        if !modules.contains_key(&name) {
            issues.push(format!("{source}: {} is not a linked unit", unit(source)));
        }
        modules.get(&name).cloned()
    };
    for t in array(evidence, "types") {
        anchor(&mut points, addr(&t["typeinfo_va"])?, string(t, "unit"));
    }
    for row in array(evidence, "anchors") {
        if !array(evidence, "modules").contains(&row["unit"]) {
            issues.push(format!("Invalid reviewed anchor: {row}"));
            continue;
        }
        for address in array(row, "functions") {
            let ea = addr(address)?;
            if !functions.contains_key(&ea) {
                issues.push(format!(
                    "Reviewed routine anchor is not a function entry: {}",
                    address.as_str().unwrap_or("")
                ));
            } else {
                anchor(&mut points, ea, string(row, "unit"));
            }
        }
    }
    for row in array(&evidence["startup"], "entries") {
        if !array(evidence, "modules").contains(&row["unit"]) {
            issues.push(format!("Invalid startup ownership: {row}"));
            continue;
        }
        for key in ["init", "fini"] {
            let ea = addr(&row[key])?;
            if ea != 0 {
                anchor(&mut points, ea, string(row, "unit"));
            }
        }
    }
    let mut excluded = BTreeMap::new();
    for row in array(evidence, "header_ownership_exclusions") {
        let ea = addr(&row["address"])?;
        if excluded.insert(ea, row).is_some() {
            issues.push(format!("{ea:#x}: duplicate header ownership exclusion"));
        }
    }
    let present = array(manifest, "functions")
        .iter()
        .map(|f| (n(f, "addr"), f))
        .collect::<BTreeMap<_, _>>();
    for (&ea, row) in &excluded {
        if present.get(&ea).is_none_or(|f| {
            !unit(string(f, "source")).eq_ignore_ascii_case(string(row, "header_unit"))
        }) {
            issues.push(format!(
                "{ea:#x}: ownership exclusion no longer matches its declared header"
            ));
        }
    }
    for d in declarations {
        if d.kind != "class" || yes(&d.data, "opaque") || !classes.contains_key(&d.name) {
            continue;
        }
        let Some(owner) = header_unit(&d.source, &mut issues) else {
            continue;
        };
        if let Some(old) = seeds.get(&d.name).filter(|s| **s != owner) {
            issues.push(format!(
                "{}: {} is in {owner}, evidence says {old}",
                d.source, d.name
            ));
        }
        seeds.insert(d.name.clone(), owner);
    }
    for f in array(manifest, "functions") {
        let ea = n(f, "addr");
        if excluded.contains_key(&ea) || functions.get(&ea).is_some_and(|f| yes(f, "import_thunk"))
        {
            continue;
        }
        if let Some(owner) = header_unit(string(f, "source"), &mut issues) {
            anchor(&mut points, ea, &owner);
        }
    }
    let mut targets: BTreeMap<u32, BTreeSet<String>> = BTreeMap::new();
    for c in classes.values() {
        let name = string(c, "name");
        for target in array(c, "runtime_methods")
            .iter()
            .chain(array(c, "virtual_methods"))
            .filter(|s| !yes(s, "inherited"))
            .map(|s| n(s, "address"))
            .chain(
                array(c, "dynamic_methods")
                    .iter()
                    .filter_map(Value::as_u64)
                    .map(|a| a as u32),
            )
        {
            targets.entry(target).or_default().insert(name.into());
        }
    }
    let mut own_points: BTreeMap<String, Vec<u32>> = BTreeMap::new();
    for (target, owners) in targets {
        if owners.len() == 1 {
            own_points
                .entry(owners.first().unwrap().clone())
                .or_default()
                .extend([
                    target,
                    functions.get(&target).map_or(target + 1, |f| n(f, "end")) - 1,
                ]);
        }
    }
    for (name, c) in &classes {
        let mut by_section: BTreeMap<String, Vec<u32>> = BTreeMap::new();
        let mut metadata = vec![n(c, "vmt") - 76];
        if let Some(a) = c["header"]["ClassName"].as_u64().filter(|a| *a != 0) {
            metadata.push(a as u32 + name.len() as u32);
        }
        metadata.extend(own_points.get(name).into_iter().flatten());
        for ea in metadata {
            if let Some(sec) = section(ea) {
                by_section.entry(sec).or_default().push(ea);
            }
        }
        for (sec, addresses) in by_section {
            let low = *addresses.iter().min().unwrap();
            let high = *addresses.iter().max().unwrap();
            intervals.entry(sec.clone()).or_default().push(Interval {
                low,
                high,
                labels: BTreeSet::new(),
            });
            if let Some(owner) = seeds.get(name) {
                points
                    .entry((sec, owner.clone()))
                    .or_default()
                    .extend(addresses);
            }
        }
    }
    for ((sec, owner), addresses) in points {
        intervals.entry(sec).or_default().push(Interval {
            low: *addresses.iter().min().unwrap(),
            high: *addresses.iter().max().unwrap(),
            labels: BTreeSet::from([owner]),
        });
    }
    let (mut spans, mut conflicts) = (Vec::new(), Vec::new());
    for (sec, rows) in intervals {
        for row in merge(rows) {
            if row.labels.len() > 1 {
                conflicts
                    .push(json!({"section":sec,"low":row.low,"high":row.high,"units":row.labels}));
            } else if let Some(owner) = row.labels.first() {
                spans.push(json!({"section":sec,"low":row.low,"high":row.high,"unit":owner}));
            }
        }
    }
    spans.sort_by_key(|s| n(s, "low"));
    issues.sort();
    issues.dedup();
    Ok((spans, conflicts, issues))
}
pub fn summarize(rows: &[&Value]) -> Value {
    let total = rows.len();
    let declared = rows
        .iter()
        .filter(|r| ["declared", "name_only"].contains(&string(r, "status")))
        .count();
    let size: u64 = rows.iter().map(|r| n(r, "size") as u64).sum();
    let declared_size: u64 = rows
        .iter()
        .filter(|r| ["declared", "name_only"].contains(&string(r, "status")))
        .map(|r| n(r, "size") as u64)
        .sum();
    let count = |status| {
        rows.iter()
            .filter(|r| string(r, "status") == status)
            .count()
    };
    json!({"total":total,"declared":declared,"remaining":total-declared,"unnamed":count("unnamed"),"named_only":count("db_named"),"header_name_only":count("name_only"),"bytes":size,"declared_bytes":declared_size,"percent":if total>0{(1000.*declared as f64/total as f64).round()/10.}else{0.},"byte_percent":if size>0{(1000.*declared_size as f64/size as f64).round()/10.}else{0.}})
}
fn add(base: &Value, fields: Value) -> Value {
    let mut out = base.clone();
    out.as_object_mut()
        .unwrap()
        .extend(fields.as_object().unwrap().clone());
    out
}
pub fn boundary_limits(spans: &[Value], sections: &[Value]) -> Vec<Value> {
    let mut out = Vec::new();
    for section in sections {
        let rows = spans
            .iter()
            .filter(|s| s["section"] == section["name"])
            .collect::<Vec<_>>();
        for (i, row) in rows.iter().enumerate() {
            out.push(json!({"unit":row["unit"],"section":row["section"],"start_min":if i>0{n(rows[i-1],"high")+1}else{n(section,"low")},"start_max":row["low"],"end_min":n(row,"high")+1,"end_max":rows.get(i+1).map_or(n(section,"high"),|r|n(r,"low"))}));
        }
    }
    out
}
pub fn report(
    snapshot: &Value,
    evidence: &Value,
    manifest: &Value,
    declarations: &[Decl],
) -> Result<Value> {
    let (spans, conflicts, issues) = infer(snapshot, evidence, manifest, declarations)?;
    if !conflicts.is_empty() || !issues.is_empty() {
        return Ok(json!({"conflicts":conflicts,"issues":issues}));
    }
    let header = array(manifest, "functions")
        .iter()
        .map(|f| (n(f, "addr"), f))
        .collect::<BTreeMap<_, _>>();
    let default = regex::Regex::new(r"(?i)^(?:sub|loc|locret|nullsub|unknown_libname|unk|off|j)_")?;
    let mut rows = Vec::new();
    let mut mismatches = Vec::new();
    for f in array(snapshot, "functions") {
        let ea = n(f, "ea");
        let status = if let Some(d) = header.get(&ea) {
            if f["name"] != d["name"] {
                mismatches.push(format!(
                    "{ea:#x}: {} != {}",
                    string(f, "name"),
                    string(d, "name")
                ));
            }
            if !string(d, "decl").is_empty() {
                "declared"
            } else {
                "name_only"
            }
        } else if yes(f, "user_name")
            && !string(f, "name").is_empty()
            && !default.is_match(string(f, "name"))
        {
            "db_named"
        } else {
            "unnamed"
        };
        let span = spans
            .get(spans.partition_point(|s| n(s, "low") <= ea).wrapping_sub(1))
            .filter(|s| ea <= n(s, "high"));
        let category = if yes(f, "import_thunk") {
            "imports"
        } else {
            span.map_or("unresolved", |s| category(string(s, "unit")))
        };
        rows.push(add(
            f,
            json!({"status":status,"unit":span.map(|s|&s["unit"]),"category":category}),
        ));
    }
    let present = rows.iter().map(|r| n(r, "ea")).collect::<BTreeSet<_>>();
    let missing = array(manifest, "functions")
        .iter()
        .filter(|f| !present.contains(&n(f, "addr")))
        .map(|f| f["name"].clone())
        .collect::<Vec<_>>();
    let categories = CATEGORIES
        .into_iter()
        .map(|c| {
            (
                c.to_string(),
                summarize(
                    &rows
                        .iter()
                        .filter(|r| string(r, "category") == c)
                        .collect::<Vec<_>>(),
                ),
            )
        })
        .collect::<serde_json::Map<_, _>>();
    let units = spans
        .iter()
        .map(|s| {
            let selected = rows
                .iter()
                .filter(|r| {
                    n(s, "low") <= n(r, "ea")
                        && n(r, "ea") <= n(s, "high")
                        && !yes(r, "import_thunk")
                })
                .collect::<Vec<_>>();
            add(
                &add(s, json!({"category":category(string(s,"unit"))})),
                summarize(&selected),
            )
        })
        .collect::<Vec<_>>();
    let mut gaps = Vec::new();
    for section in array(snapshot, "sections") {
        let mut cursor = n(section, "low");
        let mut previous = Value::Null;
        let sentinel = json!({"low":section["high"],"high":section["high"],"unit":null});
        for s in spans
            .iter()
            .filter(|s| s["section"] == section["name"])
            .chain(std::iter::once(&sentinel))
        {
            let selected = rows
                .iter()
                .filter(|r| {
                    cursor <= n(r, "ea")
                        && n(r, "ea") < n(s, "low")
                        && string(r, "category") == "unresolved"
                })
                .collect::<Vec<_>>();
            if !selected.is_empty() {
                gaps.push(add(&json!({"low":cursor,"high":n(s,"low")-1,"before":previous,"after":s["unit"],"section":section["name"]}),summarize(&selected)));
            }
            cursor = n(s, "high") + 1;
            previous = s["unit"].clone();
        }
    }
    Ok(
        json!({"database":snapshot.get("database").cloned().unwrap_or(Value::Null),"sha256":snapshot["sha256"],"total":summarize(&rows.iter().collect::<Vec<_>>()),"categories":categories,"units":units,"gaps":gaps,"boundary_limits":boundary_limits(&spans,array(snapshot,"sections")),"library_flags":rows.iter().filter(|r|yes(r,"library")).count(),"header_ownership_exclusions":evidence.get("header_ownership_exclusions").cloned().unwrap_or(json!([])),"header_units":evidence.get("header_units").cloned().unwrap_or(json!([])),"name_mismatches":mismatches,"missing_declarations":missing,"functions":rows,"conflicts":[],"issues":[]}),
    )
}
