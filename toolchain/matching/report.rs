//! Compact per-unit progress; byte similarity and native coverage stay distinct.
use crate::{
    inspect::coverage::{self, n},
    matching::Comparison,
    matching::session::SessionResult,
    native::intervals::{self, Index},
    project::Project,
    util::{array, string, yes},
};
use anyhow::{Result, ensure};
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    path::Path,
};
pub fn number(value: usize) -> String {
    let s = value.to_string();
    let len = s.len();
    s.chars()
        .enumerate()
        .flat_map(|(i, c)| {
            if i > 0 && (len - i).is_multiple_of(3) {
                vec![',', c]
            } else {
                vec![c]
            }
        })
        .collect()
}
pub fn percent(n: usize, d: usize) -> String {
    if d == 0 {
        return "—".into();
    }
    let v = 100. * n as f64 / d as f64;
    if n < d && (v * 100.).round() == 10000. {
        ">99.99%".into()
    } else {
        format!("{v:.2}%")
    }
}
pub fn routine(result: &Comparison) -> String {
    let mut note = if result.exact {
        "exact".into()
    } else {
        format!("{} → {} bytes", result.original_bytes, result.rebuilt_bytes)
    };
    if !result.unresolved.is_empty() {
        note += &format!("; {} unresolved references", result.unresolved.len());
    }
    format!(
        "{:52} {:>7}  {note}",
        result.name.replacen('_', ".", 1),
        percent(result.relocated_equal, result.denominator())
    )
}
pub fn retained(rows: &[(String, u32, Comparison)]) -> String {
    let results = rows.iter().map(|r| &r.2).collect::<Vec<_>>();
    let exact = results.iter().filter(|r| r.exact).count();
    let exact_bytes: usize = results
        .iter()
        .filter(|r| r.exact)
        .map(|r| r.original_bytes)
        .sum();
    let native: usize = results.iter().map(|r| r.original_bytes).sum();
    let denominator: usize = results.iter().map(|r| r.denominator()).sum();
    let equal: usize = results.iter().map(|r| r.relocated_equal).sum();
    format!(
        "Retained bodies: {}/{} exact; {}/{} native bytes in exact bodies ({}).\nByte similarity: {} ({}/{}); weighted over compared bodies, not overall coverage.",
        number(exact),
        number(results.len()),
        number(exact_bytes),
        number(native),
        percent(exact_bytes, native),
        percent(equal, denominator),
        number(equal),
        number(denominator)
    )
}
#[derive(Default, Clone, Serialize, Deserialize)]
pub struct Group {
    pub name: String,
    pub native: usize,
    pub declared: usize,
    pub retained: usize,
    pub exact: usize,
    pub native_bytes: usize,
    pub retained_bytes: usize,
    pub exact_bytes: usize,
}
impl Group {
    fn named(name: &str) -> Self {
        Self {
            name: name.into(),
            ..Default::default()
        }
    }
    fn add(&mut self, function: &Value, result: Option<&Comparison>) {
        self.native += 1;
        self.declared +=
            usize::from(["declared", "name_only"].contains(&string(function, "status")));
        if let Some(r) = result {
            self.retained += 1;
            self.retained_bytes += r.original_bytes;
            if r.exact {
                self.exact += 1;
                self.exact_bytes += r.original_bytes;
            }
        }
    }
}
pub fn byte_ranges(report: &Value) -> Result<Vec<(String, String, usize)>> {
    let spans = Index::new(
        array(report, "units")
            .iter()
            .map(|r| {
                let mut r = r.clone();
                r["high"] = json!(n(&r, "high") + 1);
                r
            })
            .collect(),
    )?;
    let imports = Index::new(
        array(report, "functions")
            .iter()
            .filter(|r| yes(r, "import_thunk"))
            .map(|r| json!({"low":r["ea"],"high":r["end"]}))
            .collect(),
    )?;
    let cuts = spans
        .rows
        .iter()
        .chain(&imports.rows)
        .flat_map(|r| [n(r, "low"), n(r, "high")])
        .collect::<BTreeSet<_>>();
    let ranges = intervals::merge(
        array(report, "functions")
            .iter()
            .flat_map(|r| array(r, "chunks"))
            .map(|r| (r[0].as_u64().unwrap() as u32, r[1].as_u64().unwrap() as u32))
            .collect(),
    )?;
    let mut out = Vec::new();
    for (mut low, high) in ranges {
        while low < high {
            let end = cuts
                .range(low + 1..)
                .next()
                .copied()
                .unwrap_or(high)
                .min(high);
            let (name, category) = if imports.at(low).is_some() {
                ("Import thunks", "imports")
            } else if let Some(span) = spans.at(low) {
                (string(span, "unit"), string(span, "category"))
            } else {
                ("Unattributed", "unresolved")
            };
            out.push((name.into(), category.into(), (end - low) as usize));
            low = end;
        }
    }
    Ok(out)
}
pub const CATEGORIES: [(&str, &str); 5] = [
    ("game_engine", "Game / engine"),
    ("stdlib", "RTL / VCL / API units"),
    ("third_party", "Third-party libraries"),
    ("imports", "Import thunks"),
    ("unresolved", "Unattributed"),
];
pub fn native_groups(
    report: &Value,
    rows: &[(String, u32, Comparison)],
) -> Result<(Vec<Group>, Group, Vec<Group>, Group)> {
    ensure!(
        array(report, "conflicts").is_empty() && array(report, "issues").is_empty(),
        "{} ownership conflicts, {} evidence issues; run ./decomp coverage",
        array(report, "conflicts").len(),
        array(report, "issues").len()
    );
    let compared = rows
        .iter()
        .map(|(_, a, r)| (*a, r))
        .collect::<BTreeMap<_, _>>();
    ensure!(compared.len() == rows.len(), "Duplicate comparison entries");
    let functions = array(report, "functions")
        .iter()
        .map(|r| (n(r, "ea"), r))
        .collect::<BTreeMap<_, _>>();
    let missing = compared
        .keys()
        .filter(|a| !functions.contains_key(a))
        .count();
    ensure!(
        missing == 0,
        "{missing} compared entries absent from current IDA coverage; run ./decomp index"
    );
    let mut units: BTreeMap<String, Group> = BTreeMap::new();
    let mut categories = CATEGORIES
        .into_iter()
        .map(|(key, label)| (key, Group::named(label)))
        .collect::<BTreeMap<_, _>>();
    let mut total = Group::named("All indexed functions");
    for (&address, function) in &functions {
        let result = compared.get(&address).copied();
        if let Some(r) = result {
            ensure!(
                r.original_bytes <= n(function, "size") as usize,
                "Native extent changed for {}; run ./decomp index",
                r.name
            );
        }
        let category = string(function, "category");
        let name = if category == "imports" {
            "Import thunks"
        } else {
            function["unit"].as_str().unwrap_or("Unattributed")
        };
        let group = units
            .entry(name.into())
            .or_insert_with(|| Group::named(name));
        group.add(function, result);
        categories.get_mut(category).unwrap().add(function, result);
        total.add(function, result);
    }
    for (name, category, size) in byte_ranges(report)? {
        units
            .entry(name.clone())
            .or_insert_with(|| Group::named(&name))
            .native_bytes += size;
        categories.get_mut(category.as_str()).unwrap().native_bytes += size;
        total.native_bytes += size;
    }
    ensure!(
        units.values().all(|g| g.retained_bytes <= g.native_bytes),
        "Compared bytes exceed attributed native extents; refresh ./decomp index and inspect ownership"
    );
    let mut active = units
        .values()
        .filter(|g| g.retained > 0)
        .cloned()
        .collect::<Vec<_>>();
    active.sort_by_key(|g| g.name.to_lowercase());
    let inactive = units
        .values()
        .filter(|g| g.retained == 0)
        .collect::<Vec<_>>();
    let untouched = Group {
        name: format!("No retained bodies ({} groups)", inactive.len()),
        native: inactive.iter().map(|g| g.native).sum(),
        declared: inactive.iter().map(|g| g.declared).sum(),
        native_bytes: inactive.iter().map(|g| g.native_bytes).sum(),
        ..Default::default()
    };
    Ok((
        active,
        untouched,
        CATEGORIES
            .iter()
            .map(|(k, _)| categories.remove(k).unwrap())
            .collect(),
        total,
    ))
}
pub fn table(groups: &[Group]) -> String {
    let width = groups
        .iter()
        .map(|g| g.name.len())
        .max()
        .unwrap_or(0)
        .max(24);
    let mut lines = vec![format!(
        "{:width$}  {:>20}  {:>8}  {:>12}  {:>12}  {:>7}  {:>7}",
        "Unit / scope",
        "Exact/kept/native",
        "Declared",
        "Exact bytes",
        "Native bytes",
        "Exact%",
        "Kept%"
    )];
    for g in groups {
        lines.push(format!(
            "{:width$}  {:>20}  {:>8}  {:>12}  {:>12}  {:>7}  {:>7}",
            g.name,
            format!(
                "{}/{}/{}",
                number(g.exact),
                number(g.retained),
                number(g.native)
            ),
            number(g.declared),
            number(g.exact_bytes),
            number(g.native_bytes),
            percent(g.exact_bytes, g.native_bytes),
            percent(g.retained_bytes, g.native_bytes)
        ));
    }
    lines.join("\n")
}
pub fn source_summary(rows: &[(String, u32, Comparison)]) -> String {
    let mut groups: BTreeMap<&str, Vec<&Comparison>> = BTreeMap::new();
    for (unit, _, r) in rows {
        groups.entry(unit).or_default().push(r);
    }
    let mut groups = groups.into_iter().collect::<Vec<_>>();
    groups.sort_by_key(|(n, _)| n.to_lowercase());
    let mut lines =
        vec!["Source unit                    Exact/kept    Exact bytes / kept bytes".into()];
    for (name, rows) in groups {
        let exact = rows.iter().filter(|r| r.exact).count();
        let bytes = rows
            .iter()
            .filter(|r| r.exact)
            .map(|r| r.original_bytes)
            .sum();
        let kept = rows.iter().map(|r| r.original_bytes).sum();
        lines.push(format!(
            "{name:30} {:>10}    {:>11} / {}",
            format!("{}/{}", number(exact), number(rows.len())),
            number(bytes),
            number(kept)
        ));
    }
    lines.join("\n")
}
pub fn overall(project: &mut Project, result: &SessionResult, snapshot: &Value) -> String {
    let full = (|| -> Result<String> {
        let evidence = serde_json::from_slice(&fs::read(
            project.root.join("reference/unit_ownership.json"),
        )?)?;
        let manifest = project.compiler.build()?;
        let report = coverage::report(snapshot, &evidence, &manifest, &project.compiler.decls)?;
        let (mut active, untouched, mut categories, total) = native_groups(&report, &result.rows)?;
        if untouched.native_bytes > 0 {
            active.push(untouched);
        }
        categories.push(total);
        Ok(format!(
            "Native coverage by attributed unit (indexed IDA inventory / maintained headers)\nKept = retained implementations; declared includes name-only entries.\n{}\n\n{}\nExact% / Kept% use native bytes; only fully exact bodies earn exact coverage.\nUnit brackets are evidence spans, not complete original boundaries; gaps remain unattributed.\nNative bytes count unique function ranges, including inline data; shared tails count once at their code location.",
            table(&active),
            table(&categories)
        ))
    })();
    full.unwrap_or_else(|e| {
        format!(
            "Native coverage unavailable: {e}\n{}",
            source_summary(&result.rows)
        )
    })
}
pub fn mismatches(rows: &[(String, u32, Comparison)], reports: &Path) -> String {
    let bad = rows.iter().filter(|r| !r.2.exact).collect::<Vec<_>>();
    if bad.is_empty() {
        return String::new();
    }
    let mut lines = vec![format!("\nNon-exact bodies ({}):", number(bad.len()))];
    for (unit, address, result) in bad.iter().take(10) {
        lines.push(routine(result));
        lines.push(format!(
            "  {}",
            reports
                .join(unit)
                .join(format!("{address:08X}"))
                .join("report.txt")
                .display()
        ));
    }
    if bad.len() > 10 {
        lines.push(format!(
            "  {} more; use --verbose or select a unit. All mismatch reports are saved.",
            number(bad.len() - 10)
        ));
    }
    lines.join("\n")
}
