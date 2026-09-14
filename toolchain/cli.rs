//! Public command interface; every compiler/matcher path is native Rust.
use crate::{
    compiler::build,
    compiler::worker::Toolchain,
    inspect::coverage,
    inspect::ida,
    matching::report::number,
    matching::session,
    project::Project,
    util::{array, string},
};
use anyhow::{Context, Result, ensure};
use clap::{Args, Parser, Subcommand};
use serde_json::{Value, json};
use std::{
    fs,
    path::{Path, PathBuf},
};
#[derive(Parser)]
#[command(name = "decomp", about = "Space Rangers Delphi reconstruction")]
pub struct Cli {
    #[command(subcommand)]
    command: Command,
}
#[derive(Subcommand)]
enum Command {
    /// Validate recovered declarations and source ownership.
    Check,
    /// Refresh native function ranges from the annotated database.
    Index,
    /// Synchronize declarations with IDA.
    Sync(SyncArgs),
    /// Start, inspect or stop the persistent compiler.
    Worker {
        #[arg(value_parser=["start","status","stop","list"])]
        action: String,
        #[arg(long)]
        worker: Option<String>,
    },
    /// Build the standalone executable.
    Build {
        #[arg(long)]
        worker: Option<String>,
    },
    /// Build and require the expected whole-file SHA-256.
    Verify,
    /// Verify the executable and export an objdiff v2 report for decomp.dev.
    Report {
        #[arg(short, long, default_value = ".local/report.json")]
        output: PathBuf,
    },
    /// Compare physical PE sections, symbol addresses and unit startup order.
    Layout {
        #[arg(long)]
        worker: Option<String>,
        #[arg(long)]
        unit: Option<String>,
        #[arg(long)]
        details: bool,
        #[arg(long)]
        json: bool,
        #[arg(short, long)]
        output: Option<PathBuf>,
    },
    /// Compile standalone Pascal into a private build directory.
    Compile {
        source: PathBuf,
        #[arg(long)]
        units: Vec<PathBuf>,
        #[arg(long)]
        worker: Option<String>,
    },
    /// Compare native bytes, instructions and semantic signals.
    Match {
        source: Vec<String>,
        #[arg(long, conflicts_with = "source")]
        all: bool,
        #[arg(short, long)]
        verbose: bool,
        #[arg(long)]
        details: bool,
        #[arg(long)]
        worker: Option<String>,
    },
    /// Inspect native Delphi VMT metadata.
    Vmt {
        selectors: Vec<String>,
        #[arg(long)]
        db: Option<PathBuf>,
        #[arg(long, conflicts_with = "selectors")]
        all: bool,
        #[arg(long)]
        json: bool,
        #[arg(short, long)]
        output: Option<PathBuf>,
    },
    /// Audit declaration coverage and inferred unit brackets.
    Coverage {
        #[arg(long)]
        db: Option<PathBuf>,
        #[arg(long)]
        unit: Option<String>,
        #[arg(long)]
        json: bool,
        #[arg(short, long)]
        output: Option<PathBuf>,
        #[arg(long)]
        ranges: Option<PathBuf>,
        #[arg(long)]
        limits: Option<PathBuf>,
        #[arg(long)]
        annotate_ranges: bool,
        #[arg(long)]
        from_snapshot: Option<PathBuf>,
    },
    /// Audit entry-register homes and return cleanup.
    Signatures {
        #[arg(long)]
        db: Option<PathBuf>,
        #[arg(long)]
        headers: Option<PathBuf>,
        #[arg(long)]
        include_stdlib: bool,
        #[arg(long)]
        json: bool,
    },
    /// Measure unique native instruction storage.
    Sizes {
        #[arg(long)]
        db: Option<PathBuf>,
        #[arg(short, long)]
        output: PathBuf,
        #[arg(long)]
        save_snapshot: Option<PathBuf>,
        #[arg(long)]
        from_snapshot: Option<PathBuf>,
    },
}
#[derive(Args)]
struct SyncArgs {
    #[arg(value_parser=["check","diff","apply","header"])]
    command: String,
    #[arg(long)]
    headers: Option<PathBuf>,
    #[arg(long)]
    db: Option<PathBuf>,
    #[arg(long)]
    json: bool,
    #[arg(long)]
    details: bool,
    #[arg(long)]
    take_header: Vec<String>,
}
fn output(path: Option<&Path>, text: &str) -> Result<()> {
    if let Some(path) = path {
        fs::write(path, text)?;
    } else {
        print!("{text}");
    }
    Ok(())
}
fn csv(path: &Path, rows: &[Value], fields: &[&str], hex: &[&str]) -> Result<()> {
    let quote = |s: String| {
        if s.contains([',', '"', '\n', '\r']) {
            format!("\"{}\"", s.replace('"', "\"\""))
        } else {
            s
        }
    };
    let mut text = fields.join(",") + "\n";
    for row in rows {
        text += &fields
            .iter()
            .map(|k| {
                if hex.contains(k) {
                    format!("0x{:08X}", coverage::n(row, k))
                } else if let Some(s) = row[k].as_str() {
                    quote(s.into())
                } else if row[*k].is_null() {
                    String::new()
                } else {
                    row[*k].to_string()
                }
            })
            .collect::<Vec<_>>()
            .join(",");
        text.push('\n');
    }
    fs::write(path, text)?;
    Ok(())
}
pub fn run(root: &Path, args: &[String]) -> Result<i32> {
    let cli = Cli::parse_from(std::iter::once("decomp".to_string()).chain(args.iter().cloned()));
    match cli.command {
        Command::Worker { action, worker } => {
            let tc = Toolchain::load(root, worker.as_deref())?;
            if action == "list" {
                let cache = ProjectCache::load(root)?;
                let mut names = vec!["default".to_string()];
                if cache.path.join("workers").is_dir() {
                    for e in fs::read_dir(cache.path.join("workers"))? {
                        let e = e?;
                        if e.file_type()?.is_dir() {
                            names.push(e.file_name().to_string_lossy().into());
                        }
                    }
                }
                names.sort();
                for name in names {
                    let tc = Toolchain::load(root, Some(&name))?;
                    if let Some(state) = tc.status() {
                        print_worker(&tc, &state);
                    }
                }
                return Ok(0);
            }
            if action == "stop" {
                let result = tc.request("stop", json!({}), std::time::Duration::from_secs(5))?;
                println!(
                    "Compiler worker {}: {}",
                    tc.worker,
                    if result["stopped"] == true {
                        "stopped"
                    } else {
                        "stop requested"
                    }
                );
                return Ok(0);
            }
            let status = if action == "start" {
                Some(tc.start()?)
            } else {
                tc.status()
            };
            if let Some(status) = status {
                print_worker(&tc, &status);
                Ok(0)
            } else {
                println!("Compiler worker {} is not running", tc.worker);
                Ok(1)
            }
        }
        Command::Build { worker } => {
            let mut p = Project::open(root)?;
            let tc = Toolchain::load(root, worker.as_deref())?;
            tc.start()?;
            let r = build::layout(&mut p, &tc)?.compilation;
            println!(
                "{}\nCompiler request {:.3}s; {}",
                r.output,
                r.seconds,
                r.executable.display()
            );
            Ok(r.status)
        }
        Command::Layout {
            worker,
            unit,
            details,
            json,
            output: path,
        } => {
            output(
                path.as_deref(),
                &crate::inspect::layout::command(
                    root,
                    worker.as_deref(),
                    details,
                    unit.as_deref(),
                    json,
                )?,
            )?;
            Ok(0)
        }
        Command::Compile {
            source,
            units,
            worker,
        } => {
            let tc = Toolchain::load(root, worker.as_deref())?;
            tc.start()?;
            let r = build::source(&tc, &source, &units, None)?;
            let mut seen = std::collections::BTreeSet::new();
            for line in r
                .output
                .replace('\r', "\n")
                .lines()
                .map(str::trim)
                .filter(|l| {
                    !l.is_empty()
                        && !l.starts_with("Using a 32-bit prefix")
                        && !l.starts_with("Copyright (c)")
                })
            {
                if seen.insert(line) {
                    println!("{line}");
                }
            }
            println!("Compile {:.3}s; {}", r.seconds, r.log.display());
            Ok(r.status)
        }
        Command::Match {
            source,
            all: _,
            verbose,
            details,
            worker,
        } => {
            Toolchain::load(root, worker.as_deref())?.start()?;
            session::command(root, worker.as_deref(), &source, details, verbose)
        }
        Command::Sync(args) => sync(root, args),
        Command::Index => {
            let p = ProjectCache::load(root)?;
            let count = crate::native::index::NativeIndex::refresh(root, &p.database, &p.path)?;
            println!(
                "Indexed {} native functions and their coverage inventory",
                number(count)
            );
            Ok(0)
        }
        Command::Coverage {
            db,
            unit,
            json: as_json,
            output: out,
            ranges,
            limits,
            annotate_ranges,
            from_snapshot,
        } => {
            let mut p = Project::open(root)?;
            let snapshot = if let Some(path) = from_snapshot {
                serde_json::from_slice(&fs::read(path)?)?
            } else {
                ida::run(
                    root,
                    &db.unwrap_or(p.path("database")?),
                    "coverage",
                    json!({}),
                )?
            };
            let evidence =
                serde_json::from_slice(&fs::read(root.join("reference/unit_ownership.json"))?)?;
            let manifest = p.compiler.build()?;
            let report = coverage::report(&snapshot, &evidence, &manifest, &p.compiler.decls)?;
            let valid =
                array(&report, "conflicts").is_empty() && array(&report, "issues").is_empty();
            if let Some(unit) = &unit {
                ensure!(
                    !valid
                        || array(&report, "units")
                            .iter()
                            .any(|r| string(r, "unit").eq_ignore_ascii_case(unit)),
                    "No attributed unit named {unit:?}"
                );
            }
            output(
                out.as_deref(),
                &if as_json || !valid {
                    serde_json::to_string_pretty(&report)? + "\n"
                } else {
                    coverage_text(&report, unit.as_deref())
                },
            )?;
            if !valid {
                return Ok(2);
            }
            if let Some(path) = ranges {
                csv(
                    &path,
                    array(&report, "units"),
                    &[
                        "section",
                        "low",
                        "high",
                        "unit",
                        "category",
                        "total",
                        "declared",
                        "remaining",
                        "unnamed",
                        "named_only",
                        "header_name_only",
                        "bytes",
                        "declared_bytes",
                        "percent",
                        "byte_percent",
                    ],
                    &["low", "high"],
                )?;
            }
            if let Some(path) = limits {
                csv(
                    &path,
                    array(&report, "boundary_limits"),
                    &[
                        "unit",
                        "section",
                        "start_min",
                        "start_max",
                        "end_min",
                        "end_max",
                    ],
                    &["start_min", "start_max", "end_min", "end_max"],
                )?;
            }
            if annotate_ranges {
                let re = regex::Regex::new(r"(?m)^// Unit bracket \(inferred\):.*\n")?;
                for doc in &p.documents {
                    let text = re.replace_all(&doc.text, "");
                    let (first, rest) = text.split_once('\n').context("unit heading missing")?;
                    let mut comments = String::new();
                    for span in array(&report, "units").iter().filter(|r| {
                        doc.path
                            .file_stem()
                            .unwrap()
                            .to_string_lossy()
                            .eq_ignore_ascii_case(string(r, "unit"))
                    }) {
                        comments += &format!(
                            "// Unit bracket (inferred): {} 0x{:08X}..0x{:08X}; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.\n",
                            string(span, "section"),
                            coverage::n(span, "low"),
                            coverage::n(span, "high")
                        );
                    }
                    let updated = format!("{first}\n{comments}{rest}");
                    if updated != doc.text {
                        fs::write(&doc.path, updated)?;
                    }
                }
            }
            Ok(0)
        }
        Command::Check => {
            let mut project = Project::open(root)?;
            let manifest = project.compiler.build()?;
            println!(
                "{} {} recovered bodies validated.",
                header_summary(&manifest),
                project.bodies()?.len()
            );
            Ok(0)
        }
        command @ (Command::Verify | Command::Report { .. }) => {
            let progress_path = match command {
                Command::Report { output } => Some(root.join(output)),
                _ => None,
            };
            if let Some(path) = &progress_path {
                match fs::remove_file(path) {
                    Ok(()) => (),
                    Err(error) if error.kind() == std::io::ErrorKind::NotFound => (),
                    Err(error) => return Err(error).context("Remove previous progress report"),
                }
            }
            use sha2::{Digest, Sha256};
            let mut project = Project::open(root)?;
            let tc = Toolchain::load(root, None)?;
            tc.start()?;
            let built = build::layout(&mut project, &tc)?.compilation;
            ensure!(built.status == 0, "Compilation failed: {}", built.output);
            let expected = project.settings["target"]["sha256"]
                .as_str()
                .context("target.sha256 missing")?;
            let digest = format!("{:x}", Sha256::digest(&built.image_data));
            let identical = digest == expected;
            let original = project.path("binary")?;
            if original.exists() {
                ensure!(
                    fs::read(&original)? == built.image_data,
                    "Provided original differs from the rebuilt executable"
                );
            }
            let report = json!({"build": project.settings["target"]["build"], "bytes": built.image_data.len(), "sha256": digest, "expected_sha256": expected, "identical_file": identical});
            fs::write(
                tc.cache.join("verification.json"),
                serde_json::to_vec_pretty(&report)?,
            )?;
            ensure!(
                identical,
                "Whole-file verification failed: expected {expected}, got {digest}"
            );
            println!(
                "Verified {} bytes: {}",
                built.image_data.len(),
                built.executable.display()
            );
            if let Some(path) = progress_path {
                let report = crate::inspect::progress::generate(&project, &built.image_data)?;
                crate::util::write_changed(&path, &serde_json::to_vec_pretty(&report)?)?;
                println!(
                    "Progress: {} routines in {} source files; {}",
                    report["measures"]["total_functions"],
                    report["measures"]["total_units"],
                    path.display()
                );
            }
            Ok(0)
        }
        Command::Vmt {
            selectors,
            db,
            all,
            json: as_json,
            output: out,
        } => {
            let db = db.unwrap_or(ProjectCache::load(root)?.database);
            let report =
                crate::inspect::vmt::report(root, &db, &selectors, all || !selectors.is_empty())?;
            output(
                out.as_deref(),
                &if as_json {
                    serde_json::to_string_pretty(&report)? + "\n"
                } else {
                    crate::inspect::vmt::text(&report)
                },
            )?;
            Ok(0)
        }
        Command::Signatures {
            db,
            headers,
            include_stdlib,
            json: as_json,
        } => {
            let mut p = Project::with_source(root, headers.as_deref())?;
            let mut manifest = p.compiler.build()?;
            if !include_stdlib {
                manifest["functions"].as_array_mut().unwrap().retain(|f| {
                    coverage::category(&crate::matching::symbols::unit(string(f, "source")))
                        != "stdlib"
                });
            }
            let rows = ida::run(
                root,
                &db.unwrap_or(p.path("database")?),
                "signatures",
                json!({"manifest":manifest}),
            )?;
            let report = crate::inspect::signatures::audit(
                rows.as_array().context("Invalid signature observations")?,
            )?;
            if as_json {
                println!("{}", serde_json::to_string_pretty(&report)?);
            } else {
                println!(
                    "{} review candidates. Entry-home and cleanup checks, not complete ABI validation.",
                    array(&report, "findings").len()
                );
                for f in array(&report, "findings") {
                    println!(
                        "0x{:08X} {}: {}",
                        coverage::n(f, "ea"),
                        string(f, "name"),
                        f["problems"]
                    );
                }
            }
            Ok(0)
        }
        Command::Sizes {
            db,
            output,
            save_snapshot,
            from_snapshot,
        } => crate::inspect::sizes::command(
            root,
            db.as_deref(),
            &output,
            save_snapshot.as_deref(),
            from_snapshot.as_deref(),
        ),
    }
}
struct ProjectCache {
    path: PathBuf,
    database: PathBuf,
}
impl ProjectCache {
    fn load(root: &Path) -> Result<Self> {
        let settings: toml::Value =
            toml::from_str(&fs::read_to_string(root.join("project.toml"))?)?;
        Ok(Self {
            path: root.join(
                settings["project"]["cache"]
                    .as_str()
                    .context("cache missing")?,
            ),
            database: root.join(
                settings["project"]["database"]
                    .as_str()
                    .context("database missing")?,
            ),
        })
    }
}
fn print_worker(tc: &Toolchain, state: &Value) {
    println!(
        "Compiler worker {} PID {}; {}; {} builds; last compile {}",
        tc.worker,
        state["pid"],
        state["prefix"].as_str().unwrap_or(""),
        state["builds"],
        state["last_seconds"]
            .as_f64()
            .map(|n| format!("{n:.3}s"))
            .unwrap_or("—".into())
    );
    println!(
        "Wine warmup: {:.2}s; active: {}",
        state["warmup_seconds"].as_f64().unwrap_or(0.),
        state["active"].as_str().unwrap_or("idle")
    );
}
fn header_summary(manifest: &Value) -> String {
    format!(
        "Headers: {} routines, {} type definitions, {} globals.",
        array(manifest, "functions").len(),
        array(manifest, "types").len(),
        array(manifest, "globals").len()
    )
}
fn sync(root: &Path, args: SyncArgs) -> Result<i32> {
    let mut p = Project::with_source(root, args.headers.as_deref())?;
    let manifest = p.compiler.build()?;
    match args.command.as_str() {
        "header" => {
            println!("{}", string(&manifest, "forwards"));
            for row in array(&manifest, "types")
                .iter()
                .chain(array(&manifest, "functions"))
                .chain(array(&manifest, "globals"))
            {
                if !string(row, "decl").is_empty() {
                    println!("{}", string(row, "decl"));
                }
            }
            return Ok(0);
        }
        "check" => {
            if args.json {
                println!(
                    "{}",
                    json!({"types":array(&manifest,"types").len(),"functions":array(&manifest,"functions").len(),"globals":array(&manifest,"globals").len()})
                );
            } else {
                println!("{} Syntax and layouts OK.", header_summary(&manifest));
            }
            return Ok(0);
        }
        _ => (),
    }
    let db = args.db.unwrap_or(p.path("database")?);
    let mut report = ida::run(
        root,
        &db,
        "sync",
        json!({"manifest":manifest,"apply":args.command=="apply","take_headers":args.take_header}),
    )?;
    if report["applied"] == true {
        report["saved"] = json!(true);
    }
    let entries = array(&report, "entries");
    let conflicts = entries
        .iter()
        .filter(|r| string(r, "status") == "conflict")
        .count();
    if args.json {
        println!("{}", serde_json::to_string_pretty(&report)?);
    } else {
        println!("{}", header_summary(&manifest));
        let changes = entries
            .iter()
            .filter(|r| ["create", "update", "remove"].contains(&string(r, "status")))
            .count();
        if conflicts > 0 {
            println!("Nothing applied: {conflicts} annotation conflicts.");
        } else if changes == 0 {
            println!("No changes needed; all header declarations are synchronized.");
        } else {
            println!(
                "{} {changes} annotation changes.",
                if report["applied"] == true {
                    "Applied"
                } else {
                    "Would apply"
                }
            );
        }
        for row in entries
            .iter()
            .filter(|r| args.details || string(r, "status") == "conflict")
            .take(if args.details { usize::MAX } else { 10 })
        {
            println!("  {:10} {}", string(row, "status"), string(row, "key"));
            if args.details {
                for key in ["baseline", "before", "after"] {
                    if let Some(v) = row.get(key) {
                        println!("    {key}: {v}");
                    }
                }
            }
        }
        if conflicts > 0 {
            println!(
                "Update the headers to keep the IDA edit, or use --take-header KEY to choose the header."
            );
        }
        if report["saved"] == true {
            println!("Saved {}", db.display());
        }
    }
    Ok(if conflicts > 0 { 2 } else { 0 })
}
fn coverage_text(report: &Value, unit: Option<&str>) -> String {
    let total = &report["total"];
    let mut lines = vec![
        "Delphi function coverage (current IDB / maintained headers)".into(),
        format!(
            "{} functions; {} declared ({}%); {} outside headers.",
            number(coverage::n(total, "total") as usize),
            number(coverage::n(total, "declared") as usize),
            total["percent"],
            number(coverage::n(total, "remaining") as usize)
        ),
        "Declared means a maintained interface, not a fully understood implementation.".into(),
        "Unit spans are inclusive evidence brackets, not complete allocation boundaries.".into(),
        "".into(),
        "Category          Total  Declared  Remaining  Unnamed  Coverage".into(),
    ];
    for key in coverage::CATEGORIES {
        let r = &report["categories"][key];
        lines.push(format!(
            "{key:17} {:5} {:9} {:10} {:8} {:8.1}%",
            coverage::n(r, "total"),
            coverage::n(r, "declared"),
            coverage::n(r, "remaining"),
            coverage::n(r, "unnamed"),
            r["percent"].as_f64().unwrap_or(0.)
        ));
    }
    lines
        .push("\nUnit                     Inclusive bracket       Total  Done  Left  Done%".into());
    let mut units = array(report, "units")
        .iter()
        .filter(|r| {
            unit.map_or(string(r, "category") == "game_engine", |u| {
                string(r, "unit").eq_ignore_ascii_case(u)
            })
        })
        .collect::<Vec<_>>();
    units.sort_by_key(|r| std::cmp::Reverse(coverage::n(r, "remaining")));
    for r in units
        .into_iter()
        .take(if unit.is_some() { usize::MAX } else { 40 })
    {
        lines.push(format!(
            "{:24} {:08X}..{:08X} {:5} {:5} {:5} {:5.1}%",
            string(r, "unit"),
            coverage::n(r, "low"),
            coverage::n(r, "high"),
            coverage::n(r, "total"),
            coverage::n(r, "declared"),
            coverage::n(r, "remaining"),
            r["percent"].as_f64().unwrap_or(0.)
        ));
    }
    if let Some(unit) = unit {
        lines.push("\nUnmapped routines by size (address, bytes, direct callers, name):".into());
        let mut rows = array(report, "functions")
            .iter()
            .filter(|r| {
                string(r, "unit").eq_ignore_ascii_case(unit)
                    && !["declared", "name_only"].contains(&string(r, "status"))
                    && r["import_thunk"] != true
            })
            .collect::<Vec<_>>();
        rows.sort_by_key(|r| std::cmp::Reverse(coverage::n(r, "size")));
        for r in rows {
            lines.push(format!(
                "{:08X} {:7} {:5} {}",
                coverage::n(r, "ea"),
                coverage::n(r, "size"),
                coverage::n(r, "callers"),
                string(r, "name")
            ));
        }
    }
    lines.join("\n") + "\n"
}
