//! Content-validated build state survives worker restarts and incremental errors.
use super::worker::{Host, Toolchain};
use crate::pascal::lexer::{Kind, scan};
use anyhow::Result;
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    path::{Path, PathBuf},
    time::Instant,
};

type Fingerprint = BTreeMap<PathBuf, [u8; 32]>;
#[derive(Serialize, Deserialize)]
struct BuildState {
    version: u32,
    configuration: Value,
    inputs: Fingerprint,
    outputs: Fingerprint,
    result: Value,
}
const STATE_VERSION: u32 = 1;

enum Plan {
    Reuse,
    Incremental(Vec<PathBuf>),
    Rebuild,
}

impl BuildState {
    fn path(source: &Path) -> PathBuf {
        source.with_extension("compiler-state.json")
    }

    fn load(source: &Path, configuration: &Value) -> Option<Self> {
        let state: Self = serde_json::from_slice(&fs::read(Self::path(source)).ok()?).ok()?;
        (state.version == STATE_VERSION && &state.configuration == configuration).then_some(state)
    }

    fn save(&self, source: &Path) -> Result<()> {
        let path = Self::path(source);
        let temporary = path.with_extension("json.tmp");
        fs::write(&temporary, serde_json::to_vec(self)?)?;
        fs::rename(temporary, path)?;
        Ok(())
    }

    fn plan(&self, inputs: &Fingerprint, outputs: &Fingerprint) -> Plan {
        if &self.outputs != outputs {
            return Plan::Rebuild;
        }
        if &self.inputs == inputs && self.result["status"] == 0 {
            return Plan::Reuse;
        }
        let changed = self
            .inputs
            .keys()
            .chain(inputs.keys())
            .filter(|p| self.inputs.get(*p) != inputs.get(*p))
            .cloned()
            .collect::<BTreeSet<_>>();
        if changed
            .iter()
            .all(|p| matches!(ext(p).as_str(), "pas" | "dpr") && inputs.contains_key(p))
        {
            Plan::Incremental(changed.into_iter().filter(|p| ext(p) == "pas").collect())
        } else {
            Plan::Rebuild
        }
    }
}
fn walk(root: &Path, paths: &mut BTreeSet<PathBuf>) -> Result<()> {
    for entry in fs::read_dir(root)? {
        let path = entry?.path();
        if path.is_dir() {
            walk(&path, paths)?;
        } else if path.is_file() {
            paths.insert(path);
        }
    }
    Ok(())
}
fn fingerprint(paths: impl IntoIterator<Item = PathBuf>) -> Result<Fingerprint> {
    paths
        .into_iter()
        .map(|p| Ok((p.clone(), Sha256::digest(fs::read(&p)?).into())))
        .collect()
}
fn ext(path: &Path) -> String {
    path.extension()
        .map(|s| s.to_string_lossy().to_lowercase())
        .unwrap_or_default()
}
impl BuildState {
    fn inputs(
        toolchain: &Toolchain,
        source: &Path,
        directory: &Path,
    ) -> Result<Option<Fingerprint>> {
        let mut paths = BTreeSet::from([toolchain.compiler.clone()]);
        for entry in fs::read_dir(toolchain.compiler.parent().unwrap())? {
            let path = entry?.path();
            if ext(&path) == "dll" {
                paths.insert(path);
            }
        }
        walk(&toolchain.library, &mut paths)?;
        let mut generated = BTreeSet::new();
        walk(directory, &mut generated)?;
        paths.extend(
            generated
                .iter()
                .filter(|p| {
                    matches!(
                        ext(p).as_str(),
                        "pas" | "inc" | "dpr" | "res" | "dfm" | "obj"
                    )
                })
                .cloned(),
        );
        let mut pending = paths
            .iter()
            .filter(|p| matches!(ext(p).as_str(), "pas" | "inc" | "dpr"))
            .cloned()
            .collect::<Vec<_>>();
        let mut visited = BTreeSet::new();
        while let Some(path) = pending.pop() {
            if !visited.insert(path.clone()) {
                continue;
            }
            let text = String::from_utf8_lossy(&fs::read(&path)?).into_owned();
            let tokens = scan(&text, &path.to_string_lossy())?;
            let mut dependencies = Vec::new();
            for pair in tokens.windows(2) {
                if pair[0].value.eq_ignore_ascii_case("in")
                    && pair[1].kind == Kind::String
                    && pair[1].value.to_lowercase().ends_with(".pas")
                {
                    dependencies.push((pair[1].value.clone(), true));
                }
            }
            for token in tokens.iter().filter(|t| t.kind == Kind::Directive) {
                let value = token.value.trim_start_matches('$');
                let Some((command, name)) = value.split_once(char::is_whitespace) else {
                    continue;
                };
                if matches!(
                    command.to_uppercase().as_str(),
                    "I" | "INCLUDE" | "R" | "RESOURCE" | "L" | "LINK"
                ) {
                    dependencies.push((
                        name.trim()
                            .trim_matches(['\'', '"'])
                            .replace('*', &source.file_stem().unwrap().to_string_lossy()),
                        matches!(command.to_uppercase().as_str(), "I" | "INCLUDE"),
                    ));
                }
            }
            for (name, include) in dependencies {
                let target = path.parent().unwrap().join(name.replace('\\', "/"));
                let Ok(target) = target.canonicalize() else {
                    return Ok(None);
                };
                if !target.is_file() {
                    return Ok(None);
                }
                paths.insert(target.clone());
                if include {
                    pending.push(target);
                }
            }
        }
        let source_units = paths
            .iter()
            .filter(|p| ext(p) == "pas")
            .map(|p| p.file_stem().unwrap().to_string_lossy().to_lowercase())
            .collect::<BTreeSet<_>>();
        paths.extend(generated.into_iter().filter(|p| {
            ext(p) == "dcu"
                && !source_units.contains(&p.file_stem().unwrap().to_string_lossy().to_lowercase())
        }));
        Ok(Some(fingerprint(paths)?))
    }
    fn outputs(source: &Path) -> Result<Fingerprint> {
        let mut paths = ["dll", "exe", "map"]
            .map(|s| source.with_extension(s))
            .into_iter()
            .filter(|p| p.is_file())
            .collect::<Vec<_>>();
        for entry in fs::read_dir(source.parent().unwrap())? {
            let path = entry?.path();
            if ext(&path) == "dcu" {
                paths.push(path);
            }
        }
        fingerprint(paths)
    }
}

pub(super) fn compile(
    host: &mut Host,
    toolchain: &Toolchain,
    source: &Path,
    directory: &Path,
) -> Result<Value> {
    let inputs = BuildState::inputs(toolchain, source, directory)?;
    let outputs = BuildState::outputs(source)?;
    let configuration = toolchain.configuration();
    let previous = BuildState::load(source, &configuration);
    let plan = match (&previous, &inputs) {
        (Some(before), Some(inputs)) => before.plan(inputs, &outputs),
        _ => Plan::Rebuild,
    };
    let rebuild = match plan {
        Plan::Reuse => {
            let mut result = previous.unwrap().result;
            result["seconds"] = json!(0.0);
            result["reused"] = json!(true);
            return Ok(result);
        }
        Plan::Incremental(changed) => {
            // Delphi stores two-second DOS timestamps. Removing the changed units'
            // DCUs makes even immediate edits/reverts unambiguous to -M.
            crate::util::remove_generated(
                changed
                    .into_iter()
                    .map(|p| directory.join(p.file_stem().unwrap()).with_extension("dcu")),
            )?;
            false
        }
        Plan::Rebuild => true,
    };
    // An interrupted compile must not leave a reusable pre-attempt record.
    fs::write(BuildState::path(source), b"null\n")?;
    let start = Instant::now();
    let status = host.compile(toolchain, source, directory, rebuild)?;
    let seconds = start.elapsed().as_secs_f64();
    let output = String::from_utf8_lossy(&fs::read(directory.join("compiler.log"))?).into_owned();
    let result =
        json!({"status":status,"output":output,"seconds":seconds,"rebuild":rebuild,"reused":false});
    // Normal incremental diagnostics leave complete DCUs usable by the next -M.
    // Record the attempted inputs too: reverting an edit must invalidate those DCUs.
    // A failed full rebuild or killed compiler has no such trustworthy baseline.
    if (status == 0 || (status == 1 && !rebuild))
        && let Some(inputs) = inputs
    {
        BuildState {
            version: STATE_VERSION,
            configuration,
            inputs,
            outputs: BuildState::outputs(source)?,
            result: result.clone(),
        }
        .save(source)?;
    }
    Ok(result)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn state() -> BuildState {
        BuildState {
            version: STATE_VERSION,
            configuration: json!({"flags":["-$O-"]}),
            inputs: [
                ("Unit.pas".into(), [1; 32]),
                ("Test.dpr".into(), [2; 32]),
                ("Layout.inc".into(), [3; 32]),
            ]
            .into(),
            outputs: [("Unit.dcu".into(), [4; 32]), ("Test.exe".into(), [5; 32])].into(),
            result: json!({"status":0}),
        }
    }

    #[test]
    fn restart_reuses_only_matching_configuration_and_files() -> Result<()> {
        let source = std::env::temp_dir().join(format!("dcc-state-{}.dpr", std::process::id()));
        let original = state();
        original.save(&source)?;
        let loaded = BuildState::load(&source, &original.configuration).unwrap();
        assert!(matches!(
            loaded.plan(&original.inputs, &original.outputs),
            Plan::Reuse
        ));
        assert!(BuildState::load(&source, &json!({"flags":["-$O+"]})).is_none());
        let mut outputs = original.outputs.clone();
        outputs.insert("Unit.dcu".into(), [9; 32]);
        assert!(matches!(
            loaded.plan(&original.inputs, &outputs),
            Plan::Rebuild
        ));
        outputs.remove(Path::new("Unit.dcu"));
        assert!(matches!(
            loaded.plan(&original.inputs, &outputs),
            Plan::Rebuild
        ));
        fs::write(BuildState::path(&source), b"null\n")?;
        assert!(BuildState::load(&source, &original.configuration).is_none());
        crate::util::remove_generated([BuildState::path(&source)])?;
        Ok(())
    }

    #[test]
    fn edits_invalidate_units_but_program_edits_only_need_relinking() {
        let state = state();
        for extension in ["pas", "dpr"] {
            let mut inputs = state.inputs.clone();
            let path = PathBuf::from(if extension == "pas" {
                "Unit.pas"
            } else {
                "Test.dpr"
            });
            inputs.insert(path.clone(), [8; 32]);
            let Plan::Incremental(changed) = state.plan(&inputs, &state.outputs) else {
                panic!("expected incremental")
            };
            assert_eq!(
                changed,
                if extension == "pas" {
                    vec![path]
                } else {
                    vec![]
                }
            );
        }
        let mut inputs = state.inputs.clone();
        inputs.insert("Layout.inc".into(), [8; 32]);
        assert!(matches!(state.plan(&inputs, &state.outputs), Plan::Rebuild));
        inputs = state.inputs.clone();
        inputs.remove(Path::new("Unit.pas"));
        assert!(matches!(state.plan(&inputs, &state.outputs), Plan::Rebuild));
    }

    #[test]
    fn failed_incremental_build_retries_and_reverts_invalidate_attempted_units() {
        let mut state = state();
        let original = state.inputs.clone();
        state.inputs.insert("Unit.pas".into(), [8; 32]);
        state.result["status"] = json!(1);
        assert!(matches!(
            state.plan(&state.inputs, &state.outputs),
            Plan::Incremental(_)
        ));
        let Plan::Incremental(changed) = state.plan(&original, &state.outputs) else {
            panic!("expected incremental")
        };
        assert_eq!(changed, vec![PathBuf::from("Unit.pas")]);
    }
}
