//! Explicit native inventory refreshed by `decomp index`; matching never contacts IDA.
use crate::{
    inspect::ida,
    util::{array, string, write_changed},
};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use std::{fs, path::Path};

#[derive(Serialize, Deserialize)]
pub struct NativeIndex {
    pub ranges: Value,
    pub snapshot: Value,
}
impl NativeIndex {
    pub fn read(cache: &Path) -> Result<Self> {
        let tracked = cache
            .ancestors()
            .find(|p| p.join("project.toml").is_file())
            .map(|p| p.join("reference/native_ranges.json"));
        let bytes = fs::read(cache.join("native_ranges.json"))
            .or_else(|error| {
                if let Some(path) = tracked {
                    fs::read(path)
                } else {
                    Err(error)
                }
            })
            .context(
                "Native index missing; restore reference/native_ranges.json or run ./decomp index",
            )?;
        serde_json::from_slice(&bytes).context("Native index needs refreshing; run ./decomp index")
    }
    pub fn refresh(root: &Path, db: &Path, cache: &Path) -> Result<usize> {
        let snapshot = ida::run(root, db, "coverage", json!({"chunks":true}))?;
        let functions = array(&snapshot, "functions");
        let ranges: serde_json::Map<String, Value> = functions
            .iter()
            .map(|f| {
                let chunks = array(f, "chunks")
                    .iter()
                    .map(|c| json!({"start":c[0],"end":c[1]}))
                    .collect::<Vec<_>>();
                (
                    f["ea"].to_string(),
                    json!({"name":string(f,"name"),"chunks":chunks}),
                )
            })
            .collect();
        let count = ranges.len();
        write_changed(
            &cache.join("native_ranges.json"),
            &serde_json::to_vec(&Self {
                ranges: Value::Object(ranges),
                snapshot,
            })?,
        )?;
        Ok(count)
    }
}
