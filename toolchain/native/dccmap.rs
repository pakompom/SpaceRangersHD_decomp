//! DCC32 detailed MAP files: public symbols and linker unit contributions.

use anyhow::{Result, ensure};
use serde::Serialize;
use std::collections::{BTreeMap, BTreeSet};

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize)]
pub struct Symbol {
    pub address: u32,
    pub name: String,
    pub section: u16,
}

#[derive(Debug, Serialize)]
pub struct MapFile {
    pub symbols: Vec<Symbol>,
    pub contributions: Vec<(u32, u32, String)>,
}

impl MapFile {
    pub fn parse(text: &str) -> Result<Self> {
        let mut bases = BTreeMap::new();
        let mut symbols = BTreeSet::new();
        let mut contributions = Vec::new();
        for line in text.lines() {
            let fields: Vec<_> = line.split_whitespace().collect();
            let Some((segment, offset)) = fields.first().and_then(|f| f.split_once(':')) else {
                continue;
            };
            if segment.len() != 4 || offset.len() != 8 {
                continue;
            }
            let (Ok(segment), Ok(offset)) = (
                u16::from_str_radix(segment, 16),
                u32::from_str_radix(offset, 16),
            ) else {
                continue;
            };
            if fields.len() >= 4 && fields[1].ends_with('H') && fields[2].starts_with('.') {
                bases.insert(segment, offset);
            } else if let Some(base) = bases.get(&segment) {
                if fields.len() >= 3 {
                    let attrs: BTreeMap<_, _> = fields[2..]
                        .iter()
                        .filter_map(|p| p.split_once('='))
                        .collect();
                    if attrs.get("C") == Some(&"CODE")
                        && attrs.get("S") == Some(&".text")
                        && let Some(unit) = attrs.get("M")
                    {
                        let low = base + offset;
                        contributions.push((
                            low,
                            low.checked_add(u32::from_str_radix(fields[1], 16)?)
                                .ok_or_else(|| {
                                    anyhow::anyhow!("MAP contribution overflows Win32")
                                })?,
                            (*unit).to_owned(),
                        ));
                    }
                } else if fields.len() == 2
                    && fields[1]
                        .chars()
                        .all(|c| c.is_alphanumeric() || "_.@$".contains(c))
                {
                    symbols.insert(Symbol {
                        address: base + offset,
                        name: fields[1].into(),
                        section: segment,
                    });
                }
            }
        }
        ensure!(!symbols.is_empty(), "No linked symbols in MAP");
        Ok(Self {
            symbols: symbols.into_iter().collect(),
            contributions,
        })
    }

    pub fn unit_at(&self, address: u32) -> Option<&str> {
        self.contributions
            .iter()
            .find(|(low, high, _)| *low <= address && address < *high)
            .map(|(_, _, name)| name.as_str())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn duplicate_publics_and_contributions() -> Result<()> {
        let map = MapFile::parse(
            "0001:00401000 00000200H .text CODE\n0001:00000010 00000020 C=CODE S=.text M=Alpha\n0001:00000010 Alpha.Work\n0001:00000010 Alpha.Work\n0001:00000010 Alpha.Alias\n",
        )?;
        assert_eq!(map.symbols.len(), 2);
        assert_eq!(map.unit_at(0x40102f), Some("Alpha"));
        assert_eq!(map.unit_at(0x401030), None);
        Ok(())
    }
}
