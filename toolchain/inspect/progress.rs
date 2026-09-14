//! objdiff v2 export for decomp.dev, gated on whole-executable verification.
use crate::{matching::session, project::Project};
use anyhow::{Context, Result, ensure};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::{collections::BTreeMap, fs};

fn measures(code: u64, functions: usize, units: usize) -> Value {
    json!({
        "fuzzy_match_percent": 100.0,
        "total_code": code.to_string(), "matched_code": code.to_string(),
        "matched_code_percent": 100.0,
        "complete_code": code.to_string(), "complete_code_percent": 100.0,
        "total_functions": functions, "matched_functions": functions,
        "matched_functions_percent": 100.0,
        "total_units": units, "complete_units": units
    })
}

pub fn generate(project: &Project, executable: &[u8]) -> Result<Value> {
    let expected = project.settings["target"]["sha256"]
        .as_str()
        .context("target.sha256 missing")?;
    ensure!(
        format!("{:x}", Sha256::digest(executable)) == expected,
        "Progress export requires a byte-identical executable"
    );
    let inventory: Value = serde_json::from_slice(&fs::read(
        project.root.join("reference/native_ranges.json"),
    )?)?;
    ensure!(
        inventory["snapshot"]["sha256"] == expected,
        "Progress inventory belongs to a different build"
    );
    let selected = session::select(project, &[])?;
    let mut units = BTreeMap::<String, Vec<Value>>::new();
    let mut spans = Vec::new();
    for routine in selected {
        let ranges = inventory["ranges"][routine.address.to_string()]["chunks"]
            .as_array()
            .with_context(|| format!("Missing native ranges for {}", routine.name))?;
        // IDA can attach shared RTL tails to many callers. Count only the
        // entry chunk; shared tails and out-of-line chunks are outside this metric.
        let entry = ranges
            .iter()
            .find(|c| c["start"].as_u64() == Some(routine.address as u64))
            .with_context(|| format!("Missing entry chunk for {}", routine.name))?;
        let end = u32::try_from(entry["end"].as_u64().context("Invalid chunk end")?)?;
        ensure!(
            end > routine.address,
            "Invalid entry chunk for {}",
            routine.name
        );
        spans.push((routine.address, end));
        let source = routine
            .source
            .strip_prefix(&project.root)?
            .to_str()
            .context("Non-UTF8 source path")?
            .replace('\\', "/");
        units.entry(source).or_default().push(json!({
            "name": routine.name, "size": (end - routine.address).to_string(),
            "fuzzy_match_percent": 100.0,
            "metadata": {"virtual_address": routine.address.to_string()}
        }));
    }
    spans.sort_unstable();
    ensure!(!spans.is_empty(), "No recovered routines to report");
    ensure!(
        spans.windows(2).all(|p| p[0].1 <= p[1].0),
        "Overlapping native entry chunks would double-count progress"
    );
    let mut categories = BTreeMap::<String, (u64, usize, usize)>::new();
    let mut total_code = 0;
    let mut total_functions = 0;
    let units: Vec<_> = units
        .into_iter()
        .map(|(source, mut functions)| {
            functions.sort_by_key(|f| {
                f["metadata"]["virtual_address"]
                    .as_str()
                    .unwrap()
                    .parse::<u32>()
                    .unwrap()
            });
            let code: u64 = functions
                .iter()
                .map(|f| f["size"].as_str().unwrap().parse::<u64>().unwrap())
                .sum();
            let category = source
                .strip_prefix("source/")
                .unwrap_or(&source)
                .split_once('/')
                .map_or("program", |(directory, _)| directory)
                .to_owned();
            let totals = categories.entry(category.clone()).or_default();
            totals.0 += code;
            totals.1 += functions.len();
            totals.2 += 1;
            total_code += code;
            total_functions += functions.len();
            json!({"name": source, "measures": measures(code, functions.len(), 1),
            "functions": functions, "metadata": {"complete": true,
                "source_path": source, "progress_categories": [category]}})
        })
        .collect();
    Ok(json!({"version": 2,
        "measures": measures(total_code, total_functions, units.len()),
        "units": units,
        "categories": categories.into_iter().map(|(id, (code, functions, units))|
            json!({"name": id, "id": id, "measures": measures(code, functions, units)}))
            .collect::<Vec<_>>()
    }))
}
