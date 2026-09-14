//! Unique instruction storage, excluding verified metadata and accounting for ownership.
use crate::{
    inspect::coverage::{self, n},
    native::image::Image,
    native::intervals::{Index, merge},
    project::Project,
    util::{array, string},
};
use anyhow::{Context, Result, ensure};
use serde_json::{Value, json};
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    path::Path,
};
fn address(v: &Value) -> Result<u32> {
    if let Some(n) = v.as_u64() {
        return Ok(n as u32);
    }
    let s = v.as_str().context("Missing address")?;
    Ok(if let Some(s) = s.strip_prefix("0x") {
        u32::from_str_radix(s, 16)?
    } else {
        s.parse()?
    })
}
fn word(image: &Image, a: u32) -> Result<u16> {
    Ok(u16::from_le_bytes(image.read_exact(a, 2)?.try_into()?))
}
pub fn metadata(root: &Path, snapshot: &mut Value) -> Result<()> {
    let settings: toml::Value = toml::from_str(&fs::read_to_string(root.join("project.toml"))?)?;
    let image = Image::open(
        &root.join(
            settings["project"]["binary"]
                .as_str()
                .context("Missing binary")?,
        ),
    )?;
    let evidence: Value =
        serde_json::from_slice(&fs::read(root.join("reference/unit_ownership.json"))?)?;
    let sizes: Value =
        serde_json::from_slice(&fs::read(root.join("reference/native_code_evidence.json"))?)?;
    ensure!(
        snapshot["sha256"] == sizes["input_sha256"],
        "Native-size evidence belongs to another executable"
    );
    let mut spans = Vec::new();
    let mut guids = BTreeMap::<Vec<u8>, String>::new();
    for t in array(&evidence, "types") {
        let a = address(&t["typeinfo_va"])?;
        let u = address(&t["unit_string_va"])?;
        spans.push(json!([
            a - 4,
            u + 1 + image.read_exact(u, 1)?[0] as u32,
            format!("RTTI {}", string(t, "name"))
        ]));
        if t["kind"] == "Interface" {
            guids.insert(
                image.read_exact(u - 16, 16)?.to_vec(),
                string(t, "name").into(),
            );
        }
    }
    for c in array(snapshot, "classes") {
        let v = n(c, "vmt");
        let h = &c["header"];
        let name = string(c, "name");
        spans.push(json!([
            v - 76,
            v + 4 * array(c, "virtual_methods").len() as u32,
            format!("VMT {name}")
        ]));
        let p = n(h, "ClassName");
        spans.push(json!([
            p,
            p + 1 + image.read_exact(p, 1)?[0] as u32,
            format!("Class name {name}")
        ]));
        let p = n(h, "DynamicTable");
        if p != 0 {
            spans.push(json!([
                p,
                p + 2 + 6 * word(&image, p)? as u32,
                format!("Dynamic method table {name}")
            ]));
        }
        let p = n(h, "IntfTable");
        if p != 0 {
            let count = image.u32(p).context("Unmapped interface table")?;
            ensure!(count <= 100, "Unexpected interface count at {p:#x}");
            spans.push(json!([
                p,
                p + 4 + 28 * count,
                format!("Interface table {name}")
            ]));
            for i in 0..count {
                guids.insert(
                    image.read_exact(p + 4 + 28 * i, 16)?.to_vec(),
                    format!("{name} interface"),
                );
            }
        }
    }
    for row in array(&sizes, "not_code") {
        let low = address(&row["low"])?;
        let high = address(&row["high"])?;
        ensure!(
            image.read_exact(low, (high - low) as usize)?
                == crate::util::unhex(string(row, "bytes"))?,
            "Reviewed non-code bytes changed at {low:#x}"
        );
        spans.push(json!([low, high, row["reason"]]));
    }
    for section in array(snapshot, "sections") {
        let start = n(section, "low");
        let bytes = image.read(start, (n(section, "high") - start) as usize);
        for (guid, name) in &guids {
            if guid.iter().all(|b| *b == 0) {
                continue;
            }
            for (i, window) in bytes.windows(16).enumerate() {
                if window == guid {
                    spans.push(json!([
                        start + i as u32,
                        start + i as u32 + 16,
                        format!("Interface GUID {name}")
                    ]));
                }
            }
        }
    }
    snapshot["metadata"] = json!(spans);
    Ok(())
}
pub fn bucket(unit: &str) -> &'static str {
    let u = unit.to_lowercase();
    let u = u.as_str();
    if "graphics stdctrls extctrls dialogs clipbrd stdactns menus controls imglist actnlist forms helpintfs themes graphutil printers".split_whitespace().any(|s|s==u){"vcl"}
    else if coverage::category(u)=="stdlib"{"rtl"}
    else if ["jpeg","jconsts"].contains(&u){"jpeg"}
    else if ["fgint","fgintrsa"].contains(&u){"bigint"}
    else if u=="vorbisfile"{"vorbis_binding"}
    else if "textquest textquestinterface cpdiapclass textfieldclass valuelistclass sequenceclass locationclass calcparseclass cpvarclass parameterclass eventclass parviewstringclass parameterdeltaclass pathclass".split_whitespace().any(|s|s==u){"quests"}
    else if ["ascript","ascriptfun","ec_expression"].contains(&u){"scripting"}
    else if u.starts_with("ab"){"arcade"}
    else if u.starts_with('f') || u=="robot"{"frontend"}
    else if ["gi_","gr_","se_","ec_cache"].iter().any(|p|u.starts_with(p)) || ["aefilm","aefilmend","aeobjinfo"].contains(&u){"media"}
    else if u=="threadcalc" || u.starts_with('a') && !["amyfunction","amodsinfo","apacket"].contains(&u){"campaign"}
    else{"utilities"}
}
pub fn measure(snapshot: &Value, report: &Value, evidence: &Value) -> Result<Value> {
    ensure!(
        array(report, "conflicts").is_empty() && array(report, "issues").is_empty(),
        "Unresolved ownership conflicts: {} {}",
        report["conflicts"],
        report["issues"]
    );
    let units = Index::new(
        array(report, "units")
            .iter()
            .map(|r| {
                let mut r = r.clone();
                r["high"] = json!(n(&r, "high") + 1);
                r
            })
            .collect(),
    )?;
    let extras = Index::new(
        array(evidence, "ranges")
            .iter()
            .map(|r| {
                let mut r = r.clone();
                r["low"] = json!(address(&r["low"])?);
                r["high"] = json!(address(&r["high"])?);
                Ok(r)
            })
            .collect::<Result<_>>()?,
    )?;
    let imports = Index::new(
        array(snapshot, "functions")
            .iter()
            .filter(|f| f["import_thunk"] == true)
            .map(|f| json!({"low":f["ea"],"high":f["end"]}))
            .collect(),
    )?;
    let excluded = Index::new(
        merge(
            array(snapshot, "metadata")
                .iter()
                .map(|r| Ok((address(&r[0])?, address(&r[1])?)))
                .collect::<Result<_>>()?,
        )?
        .iter()
        .map(|(a, b)| json!({"low":a,"high":b}))
        .collect(),
    )?;
    let owner = |ea| -> (&str, &str, Option<&Value>) {
        if imports.at(ea).is_some() {
            ("imports", "import", None)
        } else if let Some(u) = units.at(ea) {
            (bucket(string(u, "unit")), "unit_span", Some(u))
        } else if let Some(e) = extras.at(ea) {
            (string(e, "bucket"), "inspected_extension", Some(e))
        } else {
            ("unresolved", "unresolved", None)
        }
    };
    let cuts: BTreeSet<_> = units
        .rows
        .iter()
        .chain(&extras.rows)
        .chain(&imports.rows)
        .flat_map(|r| [n(r, "low"), n(r, "high")])
        .collect();
    let mut counts = BTreeMap::<String, BTreeMap<String, u64>>::new();
    let mut by_unit = BTreeMap::<(String, u32, String), u64>::new();
    let mut by_extra = BTreeMap::<u32, u64>::new();
    let mut removed = BTreeSet::new();
    let mut sections = Vec::new();
    let mut retained = Vec::new();
    for sec in array(snapshot, "sections") {
        let mut raw = 0u64;
        let mut excluded_bytes = 0u64;
        let mut code_bytes = 0u64;
        for ins in array(sec, "instructions") {
            let ea = address(&ins[0])?;
            let size = address(&ins[1])?;
            raw += size as u64;
            let pieces = excluded.subtract(ea, ea + size);
            let kept = pieces.iter().map(|(a, b)| (b - a) as u64).sum::<u64>();
            excluded_bytes += size as u64 - kept;
            code_bytes += kept;
            if kept < size as u64 {
                removed.extend((ea..ea + size).filter(|p| excluded.at(*p).is_some()));
            }
            for (low, high) in pieces {
                retained.push((low, high));
                let mut points = vec![low];
                points.extend(cuts.range((low + 1)..high));
                points.push(high);
                for p in points.windows(2) {
                    let (bucket, basis, row) = owner(p[0]);
                    let size = (p[1] - p[0]) as u64;
                    let c = counts.entry(bucket.into()).or_default();
                    *c.entry("bytes".into()).or_default() += size;
                    *c.entry(basis.into()).or_default() += size;
                    if let Some(r) = row {
                        if let Some(unit) = r["unit"].as_str() {
                            *by_unit
                                .entry((string(r, "section").into(), n(r, "low"), unit.into()))
                                .or_default() += size;
                        } else {
                            *by_extra.entry(n(r, "low")).or_default() += size;
                        }
                    }
                }
            }
        }
        sections.push(json!({"name":sec["name"],"raw_instruction_bytes":raw,"raw_instruction_records":array(sec,"instructions").len(),"excluded_metadata_bytes":excluded_bytes,"code_bytes":code_bytes}));
    }
    retained.sort_unstable();
    let chunks = merge(
        array(snapshot, "functions")
            .iter()
            .flat_map(|f| array(f, "chunks"))
            .map(|c| Ok((address(&c[0])?, address(&c[1])?)))
            .collect::<Result<_>>()?,
    )?;
    let in_function = Index::new(
        chunks
            .iter()
            .map(|(a, b)| json!({"low":a,"high":b}))
            .collect(),
    )?;
    let outside: u64 = retained
        .iter()
        .flat_map(|(a, b)| in_function.subtract(*a, *b))
        .map(|(a, b)| (b - a) as u64)
        .sum();
    for f in array(snapshot, "functions") {
        *counts
            .entry(owner(n(f, "ea")).0.into())
            .or_default()
            .entry("ida_entries".into())
            .or_default() += 1;
    }
    let mut gaps = Vec::new();
    for sec in array(snapshot, "sections") {
        let low = n(sec, "low");
        let high = n(sec, "high");
        let mut points = vec![low];
        points.extend(cuts.range((low + 1)..high));
        points.push(high);
        for p in points.windows(2) {
            if owner(p[0]).0 == "unresolved" {
                let bytes: u64 = retained
                    .iter()
                    .filter(|(a, b)| *a < p[1] && *b > p[0])
                    .map(|(a, b)| (b.min(&p[1]) - a.max(&p[0])) as u64)
                    .sum();
                if bytes > 0 {
                    gaps.push(json!({"low":p[0],"high":p[1],"bytes":bytes,"section":sec["name"]}));
                }
            }
        }
    }
    gaps.sort_by_key(|r| std::cmp::Reverse(r["bytes"].as_u64()));
    let mut corrections = Vec::new();
    let mut metadata = array(snapshot, "metadata").to_vec();
    metadata.sort_by_key(|r| r[0].as_u64());
    for row in metadata {
        let low = address(&row[0])?;
        let high = address(&row[1])?;
        let hits: Vec<_> = removed.range(low..high).copied().collect();
        if !hits.is_empty() {
            corrections
                .push(json!({"low":low,"high":high,"label":row[2],"removed_bytes":hits.len()}));
            for h in hits {
                removed.remove(&h);
            }
        }
    }
    let total: u64 = counts
        .values()
        .map(|c| c.get("bytes").copied().unwrap_or(0))
        .sum();
    Ok(
        json!({"counts":counts,"sections":sections,"total_bytes":total,"units":array(report,"units").iter().map(|r|{let mut r=r.clone();r["code_bytes"]=json!(by_unit.get(&(string(&r,"section").into(),n(&r,"low"),string(&r,"unit").into())).copied().unwrap_or(0));r}).collect::<Vec<_>>(),"extensions":extras.rows.iter().map(|r|{let mut r=r.clone();r["added_bytes"]=json!(by_extra.get(&n(&r,"low")).copied().unwrap_or(0));r}).collect::<Vec<_>>(),"gaps":gaps,"metadata_corrections":corrections,"summed_function_bytes":array(snapshot,"functions").iter().map(|f|n(f,"size") as u64).sum::<u64>(),"unique_function_extent_bytes":chunks.iter().map(|(a,b)|(b-a) as u64).sum::<u64>(),"outside_function_code_bytes":outside}),
    )
}
pub fn command(
    root: &Path,
    db: Option<&Path>,
    output: &Path,
    save: Option<&Path>,
    from: Option<&Path>,
) -> Result<i32> {
    let mut p = Project::open(root)?;
    let snapshot: Value = if let Some(path) = from {
        serde_json::from_slice(&fs::read(path)?)?
    } else {
        crate::inspect::ida::run(
            root,
            &db.map(Path::to_path_buf).unwrap_or(p.path("database")?),
            "native_size",
            json!({}),
        )?
    };
    if let Some(path) = save {
        fs::write(path, serde_json::to_vec(&snapshot)?)?;
    }
    let units: Value =
        serde_json::from_slice(&fs::read(root.join("reference/unit_ownership.json"))?)?;
    let evidence: Value =
        serde_json::from_slice(&fs::read(root.join("reference/native_code_evidence.json"))?)?;
    ensure!(
        snapshot["sha256"] == units["input_sha256"]
            && snapshot["sha256"] == evidence["input_sha256"],
        "Snapshot and evidence identities differ"
    );
    let report = coverage::report(&snapshot, &units, &p.compiler.build()?, &p.compiler.decls)?;
    let result = measure(&snapshot, &report, &evidence)?;
    let mut text = format!(
        "# Native instruction storage\n\nInput: {}\n\n{} bytes of unique IDA-recognized instructions after verified metadata exclusions. This is linked code size, not recovered implementation coverage.\n\n| Component | Instruction bytes | IDA entries |\n|---|---:|---:|\n",
        p.path("binary")?.display(),
        result["total_bytes"]
    );
    for (name, c) in result["counts"].as_object().unwrap() {
        text += &format!(
            "| {name} | {} | {} |\n",
            c["bytes"].as_u64().unwrap_or(0),
            c["ida_entries"].as_u64().unwrap_or(0)
        );
    }
    text += &format!(
        "\nSummed function extents: {} bytes. Unique function extents: {} bytes. Instructions outside function extents: {} bytes.\n",
        result["summed_function_bytes"],
        result["unique_function_extent_bytes"],
        result["outside_function_code_bytes"]
    );
    text += "\n## Units\n\n| Unit | Native instruction bytes |\n|---|---:|\n";
    for r in array(&result, "units") {
        text += &format!("| {} | {} |\n", string(r, "unit"), r["code_bytes"]);
    }
    text += "\n## Unclassified regions\n\n| Start | End | Bytes |\n|---|---|---:|\n";
    for r in array(&result, "gaps") {
        text += &format!(
            "| 0x{:08X} | 0x{:08X} | {} |\n",
            n(r, "low"),
            n(r, "high"),
            r["bytes"]
        );
    }
    text += "\n## Metadata corrections\n\n| Evidence | Removed instruction bytes |\n|---|---:|\n";
    for r in array(&result, "metadata_corrections") {
        text += &format!("| {} | {} |\n", string(r, "label"), r["removed_bytes"]);
    }
    fs::write(output, text)?;
    println!(
        "Wrote {}: {} retained instruction bytes",
        output.display(),
        result["total_bytes"]
    );
    Ok(0)
}
