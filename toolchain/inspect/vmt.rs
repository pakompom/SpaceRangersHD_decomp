//! Delphi VMT inspection from native storage and IDA's code/name facts.
use crate::{
    inspect::ida,
    native::image::Image,
    util::{array, string},
};
use anyhow::{Context, Result, ensure};
use serde_json::{Value, json};
use std::{
    collections::{BTreeMap, BTreeSet},
    path::Path,
};
pub const HEADER_SIZE: u32 = 76;
pub const HEADER_FIELDS: [&str; 19] = [
    "SelfPtr",
    "IntfTable",
    "AutoTable",
    "InitTable",
    "TypeInfo",
    "FieldTable",
    "MethodTable",
    "DynamicTable",
    "ClassName",
    "InstanceSize",
    "Parent",
    "SafeCallException",
    "AfterConstruction",
    "BeforeDestruction",
    "Dispatch",
    "DefaultHandler",
    "NewInstance",
    "FreeInstance",
    "Destroy",
];
fn scan(
    image: &Image,
    vmt: u32,
    boundaries: &BTreeSet<u32>,
    code: &BTreeSet<u32>,
) -> (Vec<(u32, u32)>, String) {
    if boundaries.contains(&vmt) {
        return (vec![], format!("metadata boundary at 0x{vmt:08X}"));
    }
    let limit = boundaries.range(vmt..).next().copied().unwrap_or(u32::MAX);
    let mut slots = Vec::new();
    let mut cursor = vmt;
    while cursor.saturating_add(4) <= limit {
        let Some(target) = image.u32(cursor) else {
            return (slots, format!("unmapped bytes at 0x{cursor:08X}"));
        };
        if !code.contains(&target) {
            return (
                slots,
                format!("0x{cursor:08X} contains 0x{target:08X}, not defined as code"),
            );
        }
        slots.push((cursor - vmt, target));
        cursor += 4;
    }
    (slots, format!("metadata/segment boundary at 0x{limit:08X}"))
}
pub fn report(root: &Path, db: &Path, selectors: &[String], details: bool) -> Result<Value> {
    let settings: toml::Value =
        toml::from_str(&std::fs::read_to_string(root.join("project.toml"))?)?;
    let binary = root.join(
        settings["project"]["binary"]
            .as_str()
            .context("Missing binary")?,
    );
    let image = Image::open(&binary)?;
    let facts = ida::raw(root, db, "vmt_facts", json!({}))?;
    let code: BTreeSet<u32> = array(&facts, "code")
        .iter()
        .filter_map(Value::as_u64)
        .map(|n| n as u32)
        .collect();
    let names: BTreeMap<u32, String> = serde_json::from_value(facts["names"].clone())?;
    inspect(&image, &facts, &names, &code, selectors, details, db)
}
pub fn inspect(
    image: &Image,
    facts: &Value,
    names: &BTreeMap<u32, String>,
    code: &BTreeSet<u32>,
    selectors: &[String],
    details: bool,
    db: &Path,
) -> Result<Value> {
    let classes = image.classes();
    let mut headers = BTreeMap::new();
    let mut boundaries: BTreeSet<u32> = image
        .sections
        .iter()
        .map(|s| s.address + s.virtual_size)
        .collect();
    for vmt in classes.keys() {
        let mut header = BTreeMap::new();
        boundaries.insert(vmt - HEADER_SIZE);
        for (i, field) in HEADER_FIELDS.iter().enumerate() {
            let value = image
                .u32(vmt - HEADER_SIZE + 4 * i as u32)
                .context("Truncated VMT header")?;
            if (1..9).contains(&i) && value != 0 {
                boundaries.insert(value);
            }
            header.insert(*field, value);
        }
        headers.insert(*vmt, header);
    }
    let mut selected = BTreeSet::new();
    if selectors.is_empty() {
        selected.extend(classes.keys().copied());
    }
    for query in selectors {
        let mut found: Vec<u32> = classes
            .iter()
            .filter(|(_, c)| c.name.eq_ignore_ascii_case(query))
            .map(|(v, _)| *v)
            .collect();
        if found.is_empty() {
            let address =
                if let Some(hex) = query.strip_prefix("0x").or_else(|| query.strip_prefix('$')) {
                    u32::from_str_radix(hex, 16).ok()
                } else {
                    query.parse::<u32>().ok()
                }
                .or_else(|| names.iter().find(|(_, n)| *n == query).map(|(a, _)| *a));
            if let Some(a) = address {
                let v = if classes.contains_key(&a) {
                    Some(a)
                } else {
                    image.u32(a)
                };
                if let Some(v) = v.filter(|v| classes.contains_key(v)) {
                    found.push(v);
                }
            } else {
                found.extend(
                    classes
                        .iter()
                        .filter(|(_, c)| c.name.to_lowercase().contains(&query.to_lowercase()))
                        .map(|(v, _)| *v),
                );
            }
        }
        ensure!(!found.is_empty(), "No Delphi class found for {query:?}");
        selected.extend(found);
    }
    let slots: BTreeMap<_, _> = classes
        .keys()
        .map(|v| (*v, scan(image, *v, &boundaries, code)))
        .collect();
    let mut results = Vec::new();
    for vmt in selected {
        let c = &classes[&vmt];
        let h = &headers[&vmt];
        let mut seen = BTreeSet::from([vmt]);
        let mut parent = c.parent;
        let mut ancestors = Vec::new();
        while let Some(p) = parent {
            if !seen.insert(p) {
                ancestors.push(json!({"vmt":p,"name":"<cycle>"}));
                break;
            }
            let Some(pc) = classes.get(&p) else {
                ancestors.push(json!({"vmt":p,"name":"<unresolved>"}));
                break;
            };
            ancestors.push(json!({"vmt":p,"name":pc.name}));
            parent = pc.parent;
        }
        let mut row =
            json!({"vmt":vmt,"name":c.name,"size":c.size,"parent":c.parent,"ancestors":ancestors});
        if details {
            row["header"] = json!(h);
            row["slot_scan_stop"] = json!(slots[&vmt].1);
            let runtime:Vec<_>=HEADER_FIELDS.iter().enumerate().skip(11).map(|(i,f)|{let a=h[f];json!({"offset":i as i32*4-76,"address":a,"role":f,"name":names.get(&a).map_or("<unnamed>",String::as_str),"inherited":c.parent.and_then(|p|headers.get(&p)).is_some_and(|p|p[f]==a)})}).collect();
            row["runtime_methods"] = json!(runtime);
            row["virtual_methods"]=json!(slots[&vmt].0.iter().map(|(o,a)|json!({"offset":o,"address":a,"name":names.get(a).map_or("<unnamed>",String::as_str),"inherited":c.parent.and_then(|p|slots.get(&p)).is_some_and(|p|p.0.get((*o/4) as usize)==Some(&(*o,*a)))})).collect::<Vec<_>>());
            let table = h["DynamicTable"];
            let count = if table == 0 {
                0
            } else {
                image
                    .read(table, 2)
                    .try_into()
                    .map(u16::from_le_bytes)
                    .unwrap_or(0) as u32
            };
            row["dynamic_methods"] = json!(
                (0..count)
                    .filter_map(|i| image.u32(table + 2 + count * 2 + i * 4))
                    .collect::<Vec<_>>()
            );
        }
        results.push(row);
    }
    Ok(json!({"database":db,"input":facts["input"],"image_base":image.base,"classes":results}))
}
pub fn text(report: &Value) -> String {
    let mut out = format!(
        "Delphi 2007 Win32 VMT reference\nDatabase: {}\nClasses: {}\nVirtual slots are scanned prefixes; stop reasons describe the evidence boundary.\n\n",
        report["database"].as_str().unwrap_or(""),
        array(report, "classes").len()
    );
    for c in array(report, "classes") {
        out += &format!(
            "0x{:08X}  {}  size={}  parent={}\n",
            c["vmt"].as_u64().unwrap_or(0),
            string(c, "name"),
            c["size"],
            array(c, "ancestors")
                .first()
                .map_or("<none>", |a| string(a, "name"))
        );
        if c.get("header").is_some() {
            for (i, f) in HEADER_FIELDS.iter().take(11).enumerate() {
                out += &format!(
                    "  -0x{:02X} {f:18} 0x{:08X}\n",
                    76 - i * 4,
                    c["header"][f].as_u64().unwrap_or(0)
                );
            }
            for slot in array(c, "runtime_methods")
                .iter()
                .chain(array(c, "virtual_methods"))
            {
                out += &format!(
                    "  {:+#05x} 0x{:08X} {} {}{}\n",
                    slot["offset"].as_i64().unwrap_or(0),
                    slot["address"].as_u64().unwrap_or(0),
                    string(slot, "role"),
                    string(slot, "name"),
                    if slot["inherited"] == true {
                        " [inherited]"
                    } else {
                        ""
                    }
                );
            }
            out += &format!("  Scan stopped: {}\n\n", string(c, "slot_scan_stop"));
        }
    }
    out
}
