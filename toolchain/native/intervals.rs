//! Validated half-open interval arithmetic shared by coverage and size audits.
use crate::inspect::coverage::n;
use anyhow::{Result, ensure};
use serde_json::Value;
pub fn merge(mut ranges: Vec<(u32, u32)>) -> Result<Vec<(u32, u32)>> {
    ranges.sort_unstable();
    let mut out: Vec<(u32, u32)> = Vec::new();
    for (lo, hi) in ranges {
        ensure!(hi > lo, "Empty/reversed interval: {lo:#x}..{hi:#x}");
        if let Some(last) = out.last_mut()
            && lo <= last.1
        {
            last.1 = last.1.max(hi);
            continue;
        }
        out.push((lo, hi));
    }
    Ok(out)
}
pub struct Index {
    pub rows: Vec<Value>,
}
impl Index {
    pub fn new(mut rows: Vec<Value>) -> Result<Self> {
        rows.sort_by_key(|r| n(r, "low"));
        ensure!(
            rows.iter().all(|r| n(r, "high") > n(r, "low")),
            "Empty/reversed ownership interval"
        );
        for pair in rows.windows(2) {
            ensure!(
                n(&pair[1], "low") >= n(&pair[0], "high"),
                "Overlapping ownership intervals: {}, {}",
                pair[0],
                pair[1]
            );
        }
        Ok(Self { rows })
    }
    pub fn at(&self, ea: u32) -> Option<&Value> {
        self.rows
            .get(
                self.rows
                    .partition_point(|r| n(r, "low") <= ea)
                    .wrapping_sub(1),
            )
            .filter(|r| ea < n(r, "high"))
    }
    pub fn subtract(&self, low: u32, high: u32) -> Vec<(u32, u32)> {
        let mut i = self
            .rows
            .partition_point(|r| n(r, "low") <= low)
            .saturating_sub(1);
        let mut cursor = low;
        let mut out = Vec::new();
        while i < self.rows.len() && n(&self.rows[i], "low") < high {
            let r = &self.rows[i];
            if n(r, "high") > cursor {
                if cursor < n(r, "low") {
                    out.push((cursor, high.min(n(r, "low"))));
                }
                cursor = cursor.max(n(r, "high"));
            }
            i += 1;
        }
        if cursor < high {
            out.push((cursor, high));
        }
        out
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    #[test]
    fn overlaps_and_subtraction() -> Result<()> {
        assert!(Index::new(vec![json!({"low":1,"high":4}), json!({"low":3,"high":5})]).is_err());
        let i = Index::new(vec![json!({"low":2,"high":4}), json!({"low":6,"high":8})])?;
        assert_eq!(i.subtract(1, 10), vec![(1, 2), (4, 6), (8, 10)]);
        assert_eq!(merge(vec![(1, 3), (2, 4), (4, 7)])?, vec![(1, 7)]);
        Ok(())
    }
}
