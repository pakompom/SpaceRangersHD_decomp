use super::*;
use std::path::Path;
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Comparison {
    pub name: String,
    pub original_bytes: usize,
    pub rebuilt_bytes: usize,
    pub raw_equal: usize,
    pub relocated_equal: usize,
    pub instruction_score: f64,
    pub fuzzy_score: f64,
    pub exact: bool,
    pub signals: Vec<String>,
    pub unresolved: Vec<String>,
    pub differences: Vec<String>,
}
impl Comparison {
    pub fn denominator(&self) -> usize {
        self.original_bytes.max(self.rebuilt_bytes).max(1)
    }
    pub fn render(&self, limit: usize) -> String {
        let mut lines = vec![
            self.name.clone(),
            format!(
                "  Bytes: original {}, rebuilt {}",
                self.original_bytes, self.rebuilt_bytes
            ),
            format!(
                "  Raw bytes: {:.2}%; relocation-resolved bytes: {:.2}%",
                100. * self.raw_equal as f64 / self.denominator() as f64,
                100. * self.relocated_equal as f64 / self.denominator() as f64
            ),
            format!(
                "  Instructions: {:.2}%; normalized fuzzy: {:.2}%",
                self.instruction_score, self.fuzzy_score
            ),
            format!(
                "  Relocation-resolved exact: {}",
                if self.exact { "YES" } else { "no" }
            ),
        ];
        if !self.unresolved.is_empty() {
            lines.push(format!(
                "  Unresolved evidence ({}):",
                self.unresolved.len()
            ));
            lines.extend(
                self.unresolved
                    .iter()
                    .take(limit)
                    .map(|s| format!("    {s}")),
            );
        }
        lines.push("  Potential semantic divergence (static review signals):".into());
        lines.extend(self.signals.iter().take(limit).map(|s| format!("    {s}")));
        if self.signals.is_empty() {
            lines.push(
                "    No changes detected in calls, branch kinds, memory access or constants."
                    .into(),
            );
        }
        if !self.differences.is_empty() {
            lines.push("  First instruction differences:".into());
            lines.extend(
                self.differences
                    .iter()
                    .take(limit)
                    .map(|s| format!("    {s}")),
            );
        }
        if [&self.unresolved, &self.signals, &self.differences]
            .iter()
            .any(|v| v.len() > limit)
        {
            lines.push(
                "  Remaining details are in the saved report; use --details for the full diff."
                    .into(),
            );
        }
        lines.join("\n")
    }
}
/// Ratcliff/Obershelp alignment with Python's earliest-position tie breaking and
/// no popularity filter. This retains existing diagnostic scores and ordering.
fn matching_blocks(left: &[String], right: &[String]) -> Vec<(usize, usize, usize)> {
    if left == right {
        return vec![(0, 0, left.len()), (left.len(), right.len(), 0)];
    }
    let mut positions: BTreeMap<&str, Vec<usize>> = BTreeMap::new();
    for (i, s) in right.iter().enumerate() {
        positions.entry(s).or_default().push(i);
    }
    let mut pending = vec![(0, left.len(), 0, right.len())];
    let mut blocks = Vec::new();
    while let Some((alo, ahi, blo, bhi)) = pending.pop() {
        let (mut besti, mut bestj, mut bestsize) = (alo, blo, 0);
        let mut previous: BTreeMap<usize, usize> = BTreeMap::new();
        for (i, item) in left.iter().enumerate().take(ahi).skip(alo) {
            let mut next = BTreeMap::new();
            if let Some(indices) = positions.get(item.as_str()) {
                for &j in indices {
                    if j < blo {
                        continue;
                    }
                    if j >= bhi {
                        break;
                    }
                    let n = j
                        .checked_sub(1)
                        .and_then(|j| previous.get(&j))
                        .copied()
                        .unwrap_or(0)
                        + 1;
                    next.insert(j, n);
                    if n > bestsize {
                        (besti, bestj, bestsize) = (i + 1 - n, j + 1 - n, n);
                    }
                }
            }
            previous = next;
        }
        // With no junk elements the search already found the maximal block.
        if bestsize > 0 {
            blocks.push((besti, bestj, bestsize));
            if alo < besti && blo < bestj {
                pending.push((alo, besti, blo, bestj));
            }
            if besti + bestsize < ahi && bestj + bestsize < bhi {
                pending.push((besti + bestsize, ahi, bestj + bestsize, bhi));
            }
        }
    }
    blocks.sort();
    let mut joined: Vec<(usize, usize, usize)> = Vec::new();
    for (i, j, n) in blocks {
        if let Some(last) = joined.last_mut()
            && last.0 + last.2 == i
            && last.1 + last.2 == j
        {
            last.2 += n;
            continue;
        }
        joined.push((i, j, n));
    }
    joined.push((left.len(), right.len(), 0));
    joined
}
fn score(blocks: &[(usize, usize, usize)], a: usize, b: usize) -> f64 {
    if a + b == 0 {
        100.
    } else {
        200. * blocks.iter().map(|t| t.2).sum::<usize>() as f64 / (a + b) as f64
    }
}
pub fn compare(name: &str, original: &Function, rebuilt: &Function) -> Comparison {
    let raw_equal = original
        .data
        .iter()
        .zip(&rebuilt.data)
        .filter(|(a, b)| a == b)
        .count();
    let mut adjusted = rebuilt.data.clone();
    let mut invalid = BTreeSet::new();
    let mut same_references = true;
    let offsets = original
        .instructions
        .iter()
        .map(|i| ((i.address - original.address) as usize, i))
        .collect::<BTreeMap<_, _>>();
    for right in &rebuilt.instructions {
        let offset = (right.address - rebuilt.address) as usize;
        let Some(left) = offsets
            .get(&offset)
            .filter(|i| i.raw.len() == right.raw.len())
        else {
            continue;
        };
        let equal_ref = |a: &Reference, b: &Reference| {
            a.offset == b.offset
                && a.size == b.size
                && a.identity == b.identity
                && a.resolved == b.resolved
        };
        if left.refs.len() != right.refs.len()
            || left
                .refs
                .iter()
                .zip(&right.refs)
                .any(|(a, b)| !equal_ref(a, b))
        {
            same_references = false;
            for r in left.refs.iter().chain(&right.refs) {
                invalid.extend(offset + r.offset..offset + r.offset + r.size);
            }
        }
        for (a, b) in left.refs.iter().zip(&right.refs) {
            if a.resolved
                && b.resolved
                && equal_ref(a, b)
                && (!a.relative || !a.identity.starts_with("local:"))
                && let (Some(dest), Some(source)) = (
                    adjusted.get_mut(offset + b.offset..offset + b.offset + b.size),
                    left.raw.get(a.offset..a.offset + a.size),
                )
            {
                dest.copy_from_slice(source);
            }
        }
    }
    let relocated_equal = original
        .data
        .iter()
        .zip(&adjusted)
        .enumerate()
        .filter(|(i, (a, b))| a == b && !invalid.contains(i))
        .count();
    let left = &original.instructions;
    let right = &rebuilt.instructions;
    let keys = |rows: &[Instruction], fuzzy: bool| {
        rows.iter()
            .map(|i| if fuzzy { &i.fuzzy } else { &i.token })
            .map(Value::to_string)
            .collect::<Vec<_>>()
    };
    let blocks = matching_blocks(&keys(left, false), &keys(right, false));
    let fuzzy_score = score(
        &matching_blocks(&keys(left, true), &keys(right, true)),
        left.len(),
        right.len(),
    );
    let mut differences = Vec::new();
    let (mut l, mut r) = (0, 0);
    for &(lo, ro, n) in &blocks {
        for i in &left[l..lo] {
            differences.push(format!("- {:08X}  {}", i.address, i.text));
        }
        for i in &right[r..ro] {
            differences.push(format!("+ {:08X}  {}", i.address, i.text));
        }
        (l, r) = (lo + n, ro + n);
    }
    for &(lo, ro, n) in &blocks {
        for (a, b) in left[lo..lo + n].iter().zip(&right[ro..ro + n]) {
            let (mut lhs, mut rhs) = (a.raw.clone(), b.raw.clone());
            for r in &a.refs {
                if let Some(v) = lhs.get_mut(r.offset..r.offset + r.size) {
                    v.fill(0);
                }
            }
            for r in &b.refs {
                if let Some(v) = rhs.get_mut(r.offset..r.offset + r.size) {
                    v.fill(0);
                }
            }
            if lhs != rhs {
                for (prefix, i) in [("-", a), ("+", b)] {
                    differences.push(format!(
                        "{prefix} {:08X}  {}  {}",
                        i.address,
                        i.raw
                            .iter()
                            .map(|b| format!("{b:02x}"))
                            .collect::<Vec<_>>()
                            .join(" "),
                        i.text
                    ));
                }
            }
        }
    }
    let mut signals = Vec::new();
    for category in 0..5 {
        let count = |rows: &[Instruction]| {
            let mut counts: BTreeMap<String, usize> = BTreeMap::new();
            for i in rows {
                let values: Vec<String> = match category {
                    0 => i.call.iter().cloned().collect(),
                    1 => i.branch.iter().cloned().collect(),
                    2 => i.reads.iter().map(tuple_repr).collect(),
                    3 => i.writes.iter().map(tuple_repr).collect(),
                    _ => i.constants.iter().map(tuple_repr).collect(),
                };
                for value in values {
                    *counts.entry(value).or_default() += 1;
                }
            }
            counts
        };
        let (a, b) = (count(left), count(right));
        for value in a.keys().chain(b.keys()).collect::<BTreeSet<_>>() {
            let l = a.get(value).copied().unwrap_or(0);
            let r = b.get(value).copied().unwrap_or(0);
            if l != r {
                signals.push(format!(
                    "{} {value}: {l} → {r}",
                    [
                        "call count",
                        "branch/return",
                        "memory read",
                        "memory write",
                        "constant"
                    ][category]
                ));
            }
        }
    }
    if left
        .iter()
        .filter_map(|i| i.call.as_ref())
        .ne(right.iter().filter_map(|i| i.call.as_ref()))
    {
        signals.insert(
            0,
            "Direct/indirect call sequence changed; inspect evaluation order and branch placement."
                .into(),
        );
    }
    let unresolved = original
        .issues
        .iter()
        .map(|i| format!("original: {i}"))
        .chain(rebuilt.issues.iter().map(|i| format!("rebuilt: {i}")))
        .collect::<Vec<_>>();
    Comparison {
        name: name.into(),
        original_bytes: original.data.len(),
        rebuilt_bytes: rebuilt.data.len(),
        raw_equal,
        relocated_equal,
        instruction_score: score(&blocks, left.len(), right.len()),
        fuzzy_score,
        exact: original.data == adjusted && same_references && unresolved.is_empty(),
        signals,
        unresolved,
        differences,
    }
}
pub fn save_report(
    directory: &Path,
    result: &Comparison,
    original: &Function,
    rebuilt: &Function,
) -> Result<()> {
    std::fs::create_dir_all(directory)?;
    std::fs::write(
        directory.join("report.json"),
        serde_json::to_string_pretty(result)? + "\n",
    )?;
    std::fs::write(
        directory.join("report.txt"),
        result.render(usize::MAX) + "\n",
    )?;
    for (name, body) in [("original", original), ("rebuilt", rebuilt)] {
        std::fs::write(
            directory.join(format!("{name}.asm")),
            body.instructions
                .iter()
                .map(|i| format!("{:08X}  {:24}  {}\n", i.address, hex(&i.raw), i.text))
                .collect::<String>(),
        )?;
    }
    Ok(())
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn duplicate_alignment() {
        let v = |s: &str| s.chars().map(|c| c.to_string()).collect::<Vec<_>>();
        assert_eq!(
            matching_blocks(&v("abxcdab"), &v("abycdab")),
            vec![(0, 0, 2), (3, 3, 4), (7, 7, 0)]
        );
        assert_eq!(score(&matching_blocks(&[], &[]), 0, 0), 100.);
    }
}
