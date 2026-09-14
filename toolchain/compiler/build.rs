//! Build generated or standalone Delphi sources and capture immutable linked inputs.
use crate::{
    compiler::emit::{Bindings, Emitter},
    compiler::worker::Toolchain,
    pascal::lexer::scan,
    project::Project,
};
use anyhow::{Context, Result, ensure};
use serde::Serialize;
use serde_json::json;
use std::{
    fs::{self, File},
    path::{Path, PathBuf},
    time::Duration,
};

#[derive(Serialize)]
pub struct Build {
    pub directory: PathBuf,
    pub executable: PathBuf,
    pub map: PathBuf,
    pub log: PathBuf,
    pub output: String,
    pub status: i32,
    pub seconds: f64,
    pub reused: bool,
    #[serde(skip)]
    pub image_data: Vec<u8>,
    #[serde(skip)]
    pub map_data: String,
}
pub struct ProjectBuild {
    pub compilation: Build,
    pub bindings: Bindings,
}
use crate::util::write_changed as write;
pub fn source(
    tc: &Toolchain,
    source: &Path,
    units: &[PathBuf],
    directory: Option<&Path>,
) -> Result<Build> {
    let source = source.canonicalize()?;
    let heading = scan(&fs::read_to_string(&source)?, &source.to_string_lossy())?;
    let extension = if heading
        .iter()
        .find(|t| ["program", "library"].contains(&t.value.to_lowercase().as_str()))
        .is_some_and(|t| t.value.to_lowercase() == "library")
    {
        "dll"
    } else {
        "exe"
    };
    let target = directory
        .map(PathBuf::from)
        .unwrap_or_else(|| tc.cache.join("build").join(source.file_stem().unwrap()));
    fs::create_dir_all(&target)?;
    let target = target.canonicalize()?;
    let lock = File::create(target.join("compiler.lock"))?;
    lock.try_lock()
        .context("A compilation in this directory is already running")?;
    let entry = target.join(source.file_name().unwrap());
    if source != entry {
        write(&entry, &fs::read(&source)?)?;
    }
    for dir in std::iter::once(source.parent().unwrap()).chain(units.iter().map(PathBuf::as_path)) {
        for file in fs::read_dir(dir)? {
            let file = file?.path();
            if file
                .extension()
                .is_some_and(|e| e == "pas" || e == "inc" || e == "res")
            {
                let dest = target.join(file.file_name().unwrap());
                if file.canonicalize()? != dest {
                    write(&dest, &fs::read(&file)?)?;
                }
            }
        }
    }
    let result = tc.request(
        "compile",
        json!({"source":entry,"directory":target}),
        Duration::from_secs(150),
    )?;
    let executable = target
        .join(source.file_stem().unwrap())
        .with_extension(extension);
    let map = executable.with_extension("map");
    let status = result["status"]
        .as_i64()
        .context("missing compiler status")? as i32;
    let (image_data, map_data) = if status == 0 {
        (fs::read(&executable)?, fs::read_to_string(&map)?)
    } else {
        (Vec::new(), String::new())
    };
    Ok(Build {
        log: target.join("compiler.log"),
        directory: target,
        executable,
        map,
        output: result["output"].as_str().unwrap_or("").into(),
        status,
        seconds: result["seconds"].as_f64().unwrap_or(0.),
        reused: result["reused"].as_bool().unwrap_or(false),
        image_data,
        map_data,
    })
}
pub fn project(project: &mut Project, tc: &Toolchain) -> Result<ProjectBuild> {
    project_with_retention(project, tc, true)
}

/// A separate link experiment: no generated exports or address trampolines,
/// and only the maintained root uses clause. Never replaces the matching build.
pub fn layout(project: &mut Project, tc: &Toolchain) -> Result<ProjectBuild> {
    project_with_retention(project, tc, false)
}

fn project_with_retention(
    project: &mut Project,
    tc: &Toolchain,
    retain_all: bool,
) -> Result<ProjectBuild> {
    let directory = tc.cache.join(if retain_all {
        "build/project"
    } else {
        "build/layout"
    });
    fs::create_dir_all(&directory)?;
    let lock = File::create(directory.join("project.lock"))?;
    lock.try_lock()
        .context("A project build is already running")?;
    let sources = Emitter::new(project)?.write_units(&directory, retain_all)?;
    for entry in fs::read_dir(project.path("source")?)? {
        let asset = entry?.path();
        if asset.extension().is_some_and(|e| e == "res") {
            write(
                &directory.join(asset.file_name().unwrap()),
                &fs::read(asset)?,
            )?;
        }
    }
    let mut dependency = None;
    if let Some(entry) = &sources.dependency_entry {
        let built = source(tc, entry, &[], entry.parent())?;
        if built.status != 0 {
            return Ok(ProjectBuild {
                compilation: built,
                bindings: sources.bindings,
            });
        }
        for name in &sources.precompiled_units {
            write(
                &directory.join(format!("{name}.dcu")),
                &fs::read(built.directory.join(format!("{name}.dcu")))?,
            )?;
        }
        dependency = Some(built);
    }
    let cached = project.settings["compiler"]["cached_units"]
        .as_array()
        .map(|items| {
            items
                .iter()
                .map(|item| item.as_str().context("cached unit must be named"))
                .collect::<Result<Vec<_>>>()
        })
        .transpose()?
        .unwrap_or_default();
    let mut compilation = if cached.is_empty() {
        source(tc, &sources.entry, &[], Some(&directory))?
    } else {
        // Compile the cyclic interfaces together, then retain only the requested
        // DCUs while rebuilding the other units from source. DCC's loaded-unit
        // ordering differs for a resumed source interface and a cached DCU.
        let seed_directory = directory.with_file_name(format!(
            "{}-cache",
            directory.file_name().unwrap().to_string_lossy()
        ));
        fs::create_dir_all(&seed_directory)?;
        for name in &sources.precompiled_units {
            write(
                &seed_directory.join(format!("{name}.dcu")),
                &fs::read(directory.join(format!("{name}.dcu")))?,
            )?;
        }
        let seed = source(tc, &sources.entry, &[], Some(&seed_directory))?;
        if seed.status != 0 {
            return Ok(ProjectBuild {
                compilation: seed,
                bindings: sources.bindings,
            });
        }
        let held = directory.join("cached-source");
        fs::create_dir_all(&held)?;
        for name in &cached {
            write(
                &directory.join(format!("{name}.dcu")),
                &fs::read(seed.directory.join(format!("{name}.dcu")))?,
            )?;
            fs::rename(
                directory.join(format!("{name}.pas")),
                held.join(format!("{name}.pas")),
            )?;
        }
        if !seed.reused {
            // An incremental final pass would retain more than these DCUs and
            // change the physical layout. Unchanged builds can still be reused.
            fs::write(
                sources.entry.with_extension("compiler-state.json"),
                b"null\n",
            )?;
        }
        let result = source(tc, &sources.entry, &[], Some(&directory));
        for name in &cached {
            fs::rename(
                held.join(format!("{name}.pas")),
                directory.join(format!("{name}.pas")),
            )?;
        }
        let mut built = result?;
        built.seconds += seed.seconds;
        built.reused &= seed.reused;
        built
    };
    if let Some(dep) = dependency {
        compilation.seconds += dep.seconds;
        compilation.reused &= dep.reused;
    }
    ensure!(
        compilation.status != 0 || !compilation.image_data.is_empty(),
        "Compiler produced no PE image"
    );
    Ok(ProjectBuild {
        compilation,
        bindings: sources.bindings,
    })
}
