//! Explicit library identities from the maintained native-match catalog.
use anyhow::Result;
use serde_json::Value;
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    path::Path,
};

#[derive(Default)]
pub struct Library {
    pub data: Value,
    pub declarations: BTreeMap<String, BTreeSet<u32>>,
}
impl Library {
    pub fn open(path: &Path) -> Result<Self> {
        let data: Value = if path.exists() {
            serde_json::from_slice(&fs::read(path)?)?
        } else {
            serde_json::json!({})
        };
        let mut declarations: BTreeMap<String, BTreeSet<u32>> = BTreeMap::new();
        if let Some(records) = data["matches"].as_array() {
            for row in records {
                let name = row["declaration"]
                    .as_str()
                    .or_else(|| row["symbol"].as_str())
                    .unwrap_or_default()
                    .to_lowercase();
                let address = row["address"]
                    .as_str()
                    .unwrap_or_default()
                    .trim_start_matches("0x");
                declarations
                    .entry(name)
                    .or_default()
                    .insert(u32::from_str_radix(address, 16)?);
            }
        }
        Ok(Self { data, declarations })
    }
    pub fn address(&self, unit: &str, name: &str, owner: Option<&str>) -> Option<u32> {
        let qualified = format!(
            "{unit}.{}{name}",
            owner.map_or(String::new(), |o| format!("{o}."))
        )
        .to_lowercase();
        self.declarations
            .get(&qualified)
            .filter(|v| v.len() == 1)
            .and_then(|v| v.first().copied())
    }
}
