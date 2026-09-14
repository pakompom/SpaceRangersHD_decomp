//! Comparison of a single immutable project build.
use crate::{
    compiler::build,
    compiler::worker::Toolchain,
    matching::symbols::{Symbols, key, unit},
    matching::unit_entries::{self, Entry},
    matching::{self, Comparison, ExactBody},
    native::dccmap::{MapFile, Symbol},
    native::image::Image,
    native::x86::Decoder,
    project::Project,
};
use anyhow::{Context, Result, ensure};
use serde_json::json;
use std::{
    collections::BTreeMap,
    fs,
    path::{Path, PathBuf},
    time::Instant,
};
#[derive(Clone)]
pub struct Selection {
    pub address: u32,
    pub name: String,
    pub unit: String,
    pub source: PathBuf,
    pub program: bool,
    pub entry: Option<Entry>,
}
pub fn select(project: &Project, selectors: &[String]) -> Result<Vec<Selection>> {
    let mut available = Vec::new();
    for body in project.bodies()?.into_iter().filter(|b| b.recovered) {
        let declaration = project.routine(&format!("{:x}", body.address))?;
        let source = project
            .root
            .join(declaration.source.rsplit_once(':').unwrap().0);
        available.push(Selection {
            address: body.address,
            name: body.name,
            unit: unit(&declaration.source),
            source,
            program: body.program,
            entry: None,
        });
    }
    if selectors.is_empty() {
        return Ok(available);
    }
    let entries = unit_entries::entries(project)?
        .into_iter()
        .map(|e| (e.name().to_lowercase(), e))
        .collect::<BTreeMap<_, _>>();
    let mut selected = indexmap::IndexMap::new();
    for selector in selectors {
        let path = Path::new(selector);
        let candidates = if path.exists() {
            let path = path.canonicalize()?;
            let directory = path.is_dir();
            available
                .iter()
                .filter(|b| {
                    let mut owners = vec![b.source.clone()];
                    if b.program {
                        owners.push(project.path("source").unwrap().join("Rangers.dpr"));
                    }
                    owners
                        .iter()
                        .any(|p| *p == path || directory && p.starts_with(&path))
                })
                .cloned()
                .collect::<Vec<_>>()
        } else if let Some(entry) = entries.get(&selector.to_lowercase()) {
            vec![Selection {
                address: entry.address,
                name: entry.name(),
                unit: entry.unit.clone(),
                source: entry.source.clone(),
                program: false,
                entry: Some(entry.clone()),
            }]
        } else {
            let declaration = project.routine(selector)?;
            available
                .iter()
                .filter(|b| declaration.meta.get("addr") == Some(&json!(b.address)))
                .cloned()
                .collect()
        };
        ensure!(
            !candidates.is_empty(),
            "No recovered source bodies for {selector}"
        );
        for body in candidates {
            selected.insert(body.address, body);
        }
    }
    Ok(selected.into_values().collect())
}
pub struct SessionResult {
    pub rows: Vec<(String, u32, Comparison)>,
    pub linked: BTreeMap<u32, u32>,
    pub symbol_seconds: f64,
    pub compare_seconds: f64,
}
pub fn compare(
    project: &mut Project,
    build: &build::ProjectBuild,
    index: &crate::native::index::NativeIndex,
    selected: &[Selection],
    reports: Option<&Path>,
    details: bool,
) -> Result<SessionResult> {
    let start = Instant::now();
    let native = Image::open(&project.path("binary")?)?;
    let rebuilt = Image::parse(build.compilation.image_data.clone())?;
    let linked = MapFile::parse(&build.compilation.map_data)?.symbols;
    let bindings = &build.bindings;
    let decoder = Decoder::new()?;
    let mut symbols = Symbols::new(project, &native, &rebuilt, &linked, &decoder, &index.ranges)?;
    let names = linked
        .iter()
        .map(|s| (s.name.as_str(), s.address))
        .collect::<BTreeMap<_, _>>();
    for (name, &width) in &bindings.constants {
        let found = linked
            .iter()
            .filter(|s| s.section != 1 && s.name == *name)
            .collect::<Vec<_>>();
        ensure!(!found.is_empty(), "Missing linked constant {name}");
        for symbol in found {
            symbols.states[1]
                .constants
                .insert(symbol.address, width as usize);
        }
    }
    for (name, &address) in &bindings.indirect {
        symbols.bind_indirect(
            name,
            *names
                .get(name.as_str())
                .with_context(|| format!("Missing separately linked variable {name}"))?,
            address,
        )?;
    }
    symbols.resolve_overloads(&linked, &decoder)?;
    let ranges = &index.ranges;
    let mut routines: BTreeMap<(String, String), Vec<&Symbol>> = BTreeMap::new();
    let mut code = Vec::new();
    for symbol in &linked {
        if symbol.section == 1 {
            if let Some((unit, name)) = symbol.name.split_once('.') {
                routines
                    .entry((unit.to_lowercase(), key(name)))
                    .or_default()
                    .push(symbol);
            }
            code.push(symbol.address);
        }
    }
    code.sort_unstable();
    code.dedup();
    let mut candidates = Vec::new();
    let pairs = if selected.iter().any(|s| {
        s.entry
            .as_ref()
            .is_some_and(|e| e.section == "initialization")
    }) {
        unit_entries::startup_pairs(&rebuilt, &linked, &decoder)?
    } else {
        Vec::new()
    };
    for body in selected {
        let owner = body.unit.clone();
        let address = if let Some(entry) = &body.entry {
            let found = unit_entries::candidates(entry, &linked, &pairs);
            ensure!(
                found.len() == 1,
                "{}: expected one linked unit entry; found {:?}",
                body.name,
                found
            );
            found[0]
        } else if body.program {
            ensure!(
                !rebuilt.dll && body.address == native.entry,
                "Program body requires native and rebuilt executable entry points"
            );
            rebuilt.entry
        } else {
            let candidates = routines
                .get(&(owner.to_lowercase(), key(&body.name)))
                .cloned()
                .unwrap_or_default();
            ensure!(
                candidates.len() == 1,
                "{}: expected one linked symbol; found {:?}",
                body.name,
                candidates
                    .iter()
                    .map(|s| s.name.as_str())
                    .collect::<Vec<_>>()
            );
            candidates[0].address
        };
        if let Some(entry) = &body.entry {
            symbols.bind(address, body.address, Some(&body.name))?;
            if let (Some(old), Some(new)) = (
                unit_entries::reference_counter(&native, body.address, &entry.section, &decoder)?,
                unit_entries::reference_counter(&rebuilt, address, &entry.section, &decoder)?,
            ) {
                symbols.bind(
                    new,
                    old,
                    Some(&format!("{}.UnitReferenceCount", entry.unit)),
                )?;
            }
            unit_entries::bind_initializers(entry, address, &mut symbols, &decoder)?;
        } else {
            symbols.bind(address, body.address, None)?;
        }
        candidates.push((owner, address));
    }
    symbols.refresh();
    let symbol_seconds = start.elapsed().as_secs_f64();
    let start = Instant::now();
    let mut rows = Vec::new();
    for (body, (owner, address)) in selected.iter().zip(candidates) {
        let owned = if let Some(chunks) = ranges[body.address.to_string()]["chunks"].as_array() {
            chunks
                .iter()
                .map(|c| {
                    Ok((
                        c["start"].as_u64().context("chunk start")? as u32,
                        c["end"].as_u64().context("chunk end")? as u32,
                    ))
                })
                .collect::<Result<Vec<_>>>()?
        } else {
            ensure!(
                body.entry.is_some(),
                "No native range for {:#x}; refresh ./decomp index",
                body.address
            );
            unit_entries::unindexed_chunks(&native, body.address, &decoder)?
        }
        .into_iter()
        .filter(|(a, _)| {
            let name = symbols
                .identity(0, *a, 0, false, 0)
                .unwrap_or_default()
                .to_lowercase();
            !["handleonexception", "handlefinally", "handleanyexception"]
                .iter()
                .any(|s| name.contains(s))
        })
        .collect::<Vec<_>>();
        let following = code
            .get(code.partition_point(|a| *a <= address))
            .copied()
            .unwrap_or(rebuilt.section_end(address)?);
        let mut original =
            matching::function(0, body.address, &owned, &symbols, &decoder, details)?;
        let fast = if details {
            None
        } else {
            ExactBody::from_function(&original, &native)
                .and_then(|b| b.compare(&body.name, body.address, address, following, &symbols))
        };
        let result = if let Some(result) = fast {
            result
        } else {
            if !details {
                original = matching::function(0, body.address, &owned, &symbols, &decoder, true)?;
            }
            let recovered = matching::function(
                1,
                address,
                &[(address, following)],
                &symbols,
                &decoder,
                true,
            )?;
            let result = matching::compare(&body.name, &original, &recovered);
            if let Some(reports) = reports {
                matching::save_report(
                    &reports.join(&owner).join(format!("{:08X}", body.address)),
                    &result,
                    &original,
                    &recovered,
                )?;
            }
            result
        };
        rows.push((owner, body.address, result));
    }
    Ok(SessionResult {
        rows,
        linked: symbols.linked,
        symbol_seconds,
        compare_seconds: start.elapsed().as_secs_f64(),
    })
}
pub fn command(
    root: &Path,
    worker: Option<&str>,
    selectors: &[String],
    details: bool,
    verbose: bool,
) -> Result<i32> {
    let started = Instant::now();
    let mut project = Project::open(root)?;
    let tc = Toolchain::load(root, worker)?;
    let selected = select(&project, selectors)?;
    let index = crate::native::index::NativeIndex::read(&project.path("cache")?)?;
    let load = started.elapsed().as_secs_f64();
    fs::create_dir_all(&tc.cache)?;
    let lock = fs::File::create(tc.cache.join("match.lock"))?;
    lock.try_lock()
        .context("A match is already running for this worker")?;
    let time = Instant::now();
    let built = build::project(&mut project, &tc)?;
    let build_seconds = time.elapsed().as_secs_f64();
    let built_bytes = &built.compilation;
    if built_bytes.status != 0 {
        println!(
            "{}\nCompilation failed; {}",
            built_bytes.output,
            built_bytes.log.display()
        );
        return Ok(2);
    }
    let reports = tc.cache.join("match");
    let results = compare(
        &mut project,
        &built,
        &index,
        &selected,
        Some(&reports),
        details,
    )?;
    let folders = selectors.iter().any(|s| Path::new(s).is_dir());
    let show_routines = (!selectors.is_empty() && !folders) || verbose || details;
    let mut obsolete = Vec::new();
    for (unit, address, result) in &results.rows {
        let report = reports.join(unit).join(format!("{address:08X}"));
        if details {
            println!("{}", result.render(usize::MAX));
        } else if show_routines {
            println!("{}", crate::matching::report::routine(result));
        }
        if details || show_routines && !result.exact {
            println!("  {}", report.join("report.txt").display());
        }
        if !details && result.exact && report.exists() {
            obsolete.push(report);
        }
    }
    crate::util::remove_generated(obsolete)?;
    println!(
        "Build: {}{}",
        built_bytes.executable.display(),
        if built_bytes.reused { " (reused)" } else { "" }
    );
    if selectors.is_empty() {
        println!(
            "{}",
            crate::matching::report::overall(&mut project, &results, &index.snapshot)
        );
    } else if folders {
        println!("{}", crate::matching::report::source_summary(&results.rows));
    }
    if !show_routines {
        let text = crate::matching::report::mismatches(&results.rows, &reports);
        if !text.is_empty() {
            println!("{text}");
        }
    }
    println!("{}", crate::matching::report::retained(&results.rows));
    println!(
        "Load {load:.2}s; build {build_seconds:.2}s (compiler {:.2}s); symbols {:.2}s; compare {:.2}s; total {:.2}s.",
        built_bytes.seconds,
        results.symbol_seconds,
        results.compare_seconds,
        started.elapsed().as_secs_f64()
    );
    Ok(0)
}
