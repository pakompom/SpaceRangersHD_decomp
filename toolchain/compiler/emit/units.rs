use super::*;
use serde::Serialize;
use std::{fs, path::PathBuf};

#[derive(Default, Clone)]
struct Unit {
    name: String,
    types: Vec<String>,
    type_positions: BTreeMap<String, usize>,
    interface: Vec<String>,
    externals: Vec<(usize, String)>,
    implementation: Vec<String>,
    dependencies: BTreeSet<String>,
    imports: BTreeSet<String>,
    interface_imports: Vec<String>,
    implementation_imports: Vec<String>,
    globals: Vec<Decl>,
    constants: Vec<Decl>,
    pointers: IndexMap<String, String>,
    initialization: Vec<String>,
    finalization: Vec<String>,
}
#[derive(Default, Clone, Serialize)]
pub struct Bindings {
    pub constants: BTreeMap<String, i64>,
    pub indirect: BTreeMap<String, u32>,
    pub unimplemented: BTreeMap<u32, String>,
}
#[derive(Serialize)]
pub struct Sources {
    pub entry: PathBuf,
    pub dependency_entry: Option<PathBuf>,
    pub precompiled_units: Vec<String>,
    pub bindings: Bindings,
}
fn unit<'a>(units: &'a mut IndexMap<String, Unit>, name: &str) -> &'a mut Unit {
    units.entry(name.into()).or_insert_with(|| Unit {
        name: name.into(),
        ..Default::default()
    })
}
fn write(path: &Path, text: &str) -> Result<()> {
    crate::util::write_changed(path, text.as_bytes())
}
use crate::util::remove_generated as discard;
fn ordered_imports(
    names: &BTreeSet<String>,
    explicit: &[String],
    known: &BTreeMap<String, String>,
) -> Vec<String> {
    let mut declared = Vec::new();
    for name in explicit {
        let name = known
            .get(&name.to_lowercase())
            .cloned()
            .unwrap_or(name.clone());
        if !declared.contains(&name) {
            declared.push(name);
        }
    }
    let mut result = names
        .iter()
        .filter(|n| !declared.contains(n))
        .cloned()
        .collect::<Vec<_>>();
    result.extend(declared.into_iter().filter(|n| names.contains(n)));
    result
}
fn check_dependencies(units: &IndexMap<String, Unit>) -> Result<()> {
    fn visit(
        name: &str,
        units: &IndexMap<String, Unit>,
        done: &mut BTreeSet<String>,
        stack: &mut Vec<String>,
    ) -> Result<()> {
        if done.contains(name) || !units.contains_key(name) {
            return Ok(());
        }
        ensure!(
            !stack.iter().any(|n| n == name),
            "Circular Delphi interface dependency: {} -> {name}",
            stack.join(" -> ")
        );
        stack.push(name.into());
        for dep in &units[name].dependencies {
            visit(dep, units, done, stack)?;
        }
        stack.pop();
        done.insert(name.into());
        Ok(())
    }
    let (mut done, mut stack) = (BTreeSet::new(), Vec::new());
    for name in units.keys() {
        visit(name, units, &mut done, &mut stack)?;
    }
    Ok(())
}
impl Emitter<'_> {
    fn depend(&mut self, unit: &mut Unit, spec: &Value) -> Result<()> {
        if let Some(values) = spec.as_object() {
            if spec.get("pointer").is_some() {
                let name = self.typ(spec)?;
                unit.pointers
                    .insert(name.clone(), self.pointers[&name].clone());
            } else {
                for value in values.values() {
                    self.depend(unit, value)?;
                }
            }
        }
        for name in type_names(spec, false) {
            if unit
                .types
                .iter()
                .any(|local| local.eq_ignore_ascii_case(&name))
            {
                continue;
            }
            let other = if name.eq_ignore_ascii_case("dword") {
                Some("Windows".into())
            } else {
                self.project
                    .compiler
                    .types
                    .get(&name.to_lowercase())
                    .map(|d| owner(d))
            };
            if let Some(other) = other.filter(|n| *n != unit.name) {
                unit.dependencies.insert(other);
            }
        }
        Ok(())
    }
    fn signature(&mut self, unit: &mut Unit, d: &Decl) -> Result<String> {
        for p in array(&d.data, "params") {
            self.depend(unit, &p["type"])?;
        }
        self.depend(unit, &d.data["result"])?;
        self.heading(d, false, true)
    }
    pub fn write_units(&mut self, directory: &Path, retain_all: bool) -> Result<Sources> {
        self.prepare()?;
        let mut units = IndexMap::<String, Unit>::new();
        let mut symbol_units = BTreeMap::new();
        let mut exports = Vec::new();
        let known: BTreeMap<_, _> = self
            .project
            .documents
            .iter()
            .map(|d| {
                let name = d.path.file_stem().unwrap().to_string_lossy().into_owned();
                (name.to_lowercase(), name)
            })
            .collect();
        let library_units = self.library_units();
        let mut library_sources = BTreeMap::new();
        for path in array(&self.project.settings["compiler"], "library_sources") {
            let path = self
                .project
                .root
                .join(path.as_str().context("library source path")?);
            ensure!(
                path.extension().is_some_and(|e| e == "pas"),
                "Library source must be Pascal: {}",
                path.display()
            );
            let name = path
                .file_stem()
                .context("library unit name")?
                .to_string_lossy()
                .into_owned();
            ensure!(
                library_units.contains(&name.to_lowercase()),
                "Unknown library unit {name}"
            );
            ensure!(
                library_sources
                    .insert(name.clone(), fs::read_to_string(&path)?)
                    .is_none(),
                "Duplicate library source {name}"
            );
        }
        for name in self.ordered_type_names(None)? {
            let d = self.project.compiler.lookup(&name)?;
            let declarations = if d.kind == "alias" {
                self.project
                    .compiler
                    .decls
                    .iter()
                    .filter(|d| d.kind == "alias" && d.name.eq_ignore_ascii_case(&name))
                    .cloned()
                    .collect::<Vec<_>>()
            } else {
                vec![(*d).clone()]
            };
            for d in declarations {
                if d.source
                    .rsplit_once(':')
                    .unwrap()
                    .0
                    .to_lowercase()
                    .ends_with(".dpr")
                {
                    continue;
                }
                let own = owner(&d);
                symbol_units.insert(name.to_lowercase(), own.clone());
                if d.kind == "enum" {
                    for m in array(&d.data, "members") {
                        symbol_units.insert(m[0].as_str().unwrap().to_lowercase(), own.clone());
                    }
                }
                if self.library_types.contains(&name) {
                    continue;
                }
                let unit = unit(&mut units, &own);
                unit.types.push(name.clone());
                unit.type_positions.insert(name.clone(), d.start);
                for dep in self.dependencies.get(&name).cloned().unwrap_or_default() {
                    self.depend(unit, &json!(dep))?;
                }
            }
        }
        for d in self.project.compiler.decls.clone() {
            if d.source
                .rsplit_once(':')
                .unwrap()
                .0
                .to_lowercase()
                .ends_with(".dpr")
            {
                continue;
            }
            let name = d.name.to_lowercase();
            if d.kind == "global"
                && (self.unqualified.contains(&name) || d.data.get("initializer").is_some())
            {
                let own = owner(&d);
                symbol_units.insert(name, own.clone());
                if library_units.contains(&own.to_lowercase()) || d.data["implementation"] == true {
                    continue;
                }
                let unit = unit(&mut units, &own);
                unit.globals.push(d.clone());
                self.depend(unit, &d.data["type"])?;
            }
        }
        for d in self.constant_declarations.clone() {
            let own = owner(&d);
            symbol_units.insert(d.name.to_lowercase(), own.clone());
            if library_units.contains(&own.to_lowercase()) {
                continue;
            }
            let unit = unit(&mut units, &own);
            unit.constants.push(d.clone());
            if !d.data["type"].is_null() {
                self.depend(unit, &d.data["type"])?;
            }
        }
        for d in self.project.compiler.decls.clone() {
            if d.is_inline_helper() {
                let own = owner(&d);
                let unit = unit(&mut units, &own);
                let sig = self.signature(unit, &d)?;
                unit.interface.push(format!("{sig} inline;"));
                symbol_units.insert(d.name.to_lowercase(), own);
            }
        }
        for d in self.stub_declarations.values().cloned().collect::<Vec<_>>() {
            let own = owner(&d);
            let unit = unit(&mut units, &own);
            if let Some(external) = d.data.get("external").and_then(Value::as_str) {
                let sig = self.signature(unit, &d)?;
                unit.externals.push((d.start, format!("{sig} {external};")));
            } else if string(&d.data, "owner").is_empty() {
                let sig = self.signature(unit, &d)?;
                unit.interface.push(sig);
            }
            if d.data.get("external").is_none() {
                unit.implementation.push(self.stub(&d)?);
                unit.imports.insert("RangersSupport".into());
            }
            symbol_units.insert(d.name.to_lowercase(), own);
        }
        for body in self.bodies.clone() {
            if body.parent.is_some() || body.program {
                continue;
            }
            let d = self.project.routine(&format!("{:x}", body.address))?;
            if d.source
                .rsplit_once(':')
                .unwrap()
                .0
                .to_lowercase()
                .ends_with(".dpr")
            {
                continue;
            }
            let own = owner(&d);
            let unit = unit(&mut units, &own);
            symbol_units.insert(body.name.to_lowercase(), own.clone());
            if string(&d.data, "owner").is_empty() {
                let sig = self.signature(unit, &d)?;
                unit.interface.push(sig);
                exports.push(format!("{own}.{}", d.name));
            } else if retain_all {
                let class = string(&d.data, "owner");
                let method = string(&d.data, "method_name");
                let anchor = format!("Address_{}", body.name);
                unit.interface.push(format!("function {anchor}: Pointer;"));
                unit.implementation.push(format!(
                    "function {anchor}: Pointer; begin Result := @{class}.{method}; end;"
                ));
                exports.push(format!("{own}.{anchor}"));
            }
        }
        for (index, document) in self.project.documents.iter().enumerate() {
            let own = document.path.file_stem().unwrap().to_string_lossy();
            let source = &self.facts[index].1;
            let (low, high) = document.implementation()?;
            if crate::pascal::lexer::scan(&document.text[low..high], "implementation")?
                .iter()
                .all(|t| {
                    matches!(
                        t.kind,
                        crate::pascal::lexer::Kind::Comment
                            | crate::pascal::lexer::Kind::Directive
                            | crate::pascal::lexer::Kind::Eof
                    )
                })
            {
                continue;
            }
            let unit = unit(&mut units, &own);
            let implementation = document
                .tree
                .children
                .iter()
                .find(|n| n.kind == "implementation")
                .context("missing implementation tree")?;
            unit.implementation_imports = implementation
                .children
                .iter()
                .filter(|n| n.kind == "uses")
                .flat_map(|n| n.children.iter().filter_map(|n| n.value.clone()))
                .collect();
            unit.imports.extend(unit.implementation_imports.clone());
            let mut code = document.text[low..high].to_owned();
            for node in implementation.children.iter().rev() {
                if matches!(
                    node.kind.as_str(),
                    "uses" | "initialization" | "finalization"
                ) {
                    code.replace_range(node.first.start - low..node.last.end - low, "");
                    let text = document.text[node.first.end..node.last.end].to_owned();
                    if node.kind == "initialization" {
                        unit.initialization.push(text);
                    } else if node.kind == "finalization" {
                        unit.finalization.push(text);
                    }
                }
            }
            unit.implementation.push(code);
            let external_names = source.external_names(&self.project.compiler)?;
            for word in &external_names {
                if let Some(own) = symbol_units.get(word) {
                    unit.imports.insert(own.clone());
                }
            }
            for (base, _) in &source.qualified_names {
                if external_names.contains(base)
                    && let Some(name) = known.get(base)
                {
                    unit.imports.insert(name.clone());
                }
            }
            // An is/as operand may be a class-reference variable. Only type
            // names can be referenced by the unit-level retention procedure.
            let tested_classes = source
                .tested_classes
                .iter()
                .filter(|name| {
                    self.project
                        .compiler
                        .types
                        .contains_key(&name.to_lowercase())
                })
                .collect::<Vec<_>>();
            if !tested_classes.is_empty() {
                let anchor = "LinkRecoveredTypes";
                unit.interface.push(format!("procedure {anchor};"));
                let lines = tested_classes
                    .iter()
                    .map(|n| format!("  {n}.ClassName;"))
                    .collect::<Vec<_>>()
                    .join("\n");
                unit.implementation
                    .push(format!("procedure {anchor};\nbegin\n{lines}\nend;"));
                exports.push(format!("{own}.{anchor}"));
            }
        }
        for unit in units.values_mut() {
            if unit
                .types
                .iter()
                .any(|name| owner(&self.project.compiler.types[&name.to_lowercase()]) != unit.name)
            {
                unit.types = self.ordered_type_names(Some(&unit.name))?;
            }
            for (name, target) in self.pointers.clone() {
                if self
                    .pointer_users
                    .get(&name)
                    .is_some_and(|users| unit.types.iter().any(|t| users.contains(t)))
                {
                    unit.pointers.insert(name, target.clone());
                    self.depend(unit, &json!(target))?;
                }
            }
        }
        let documents: BTreeMap<_, _> = self
            .project
            .documents
            .iter()
            .map(|d| {
                (
                    d.path.file_stem().unwrap().to_string_lossy().into_owned(),
                    d,
                )
            })
            .collect();
        if let Some(program) = &self.project.program {
            for name in program
                .tree
                .children
                .iter()
                .filter(|n| n.kind == "uses")
                .flat_map(|n| n.children.iter().filter_map(|n| n.value.as_ref()))
            {
                if let Some(name) = known.get(&name.to_lowercase())
                    && !library_units.contains(&name.to_lowercase())
                    && !name.eq_ignore_ascii_case("System")
                {
                    unit(&mut units, name);
                }
            }
        }
        let mut pending = units.keys().cloned().collect::<Vec<_>>();
        let mut i = 0;
        while i < pending.len() {
            let own = pending[i].clone();
            i += 1;
            let Some(document) = documents.get(&own) else {
                continue;
            };
            let imports = document
                .tree
                .children
                .iter()
                .filter(|n| n.kind == "uses")
                .flat_map(|n| n.children.iter().filter_map(|n| n.value.clone()))
                .collect::<Vec<_>>();
            for name in imports {
                let dependency = known.get(&name.to_lowercase()).cloned().unwrap_or(name);
                let entry_unit = units.get_mut(&own).unwrap();
                entry_unit.dependencies.insert(dependency.clone());
                entry_unit.interface_imports.push(dependency.clone());
                if documents.contains_key(&dependency)
                    && !units.contains_key(&dependency)
                    && !library_units.contains(&dependency.to_lowercase())
                    && !dependency.eq_ignore_ascii_case("system")
                {
                    unit(&mut units, &dependency);
                    pending.push(dependency);
                }
            }
        }
        check_dependencies(&units)?;
        let names: BTreeMap<_, _> = units
            .keys()
            .map(|n| (n.to_lowercase(), n.clone()))
            .collect();
        let mut precompiled = BTreeSet::new();
        for name in array(&self.project.settings["compiler"], "precompiled_units") {
            let name = name.as_str().context("precompiled unit must be named")?;
            precompiled.insert(
                names
                    .get(&name.to_lowercase())
                    .with_context(|| format!("Unknown precompiled source unit: {name}"))?
                    .clone(),
            );
        }
        for name in &precompiled {
            let u = &units[name];
            for dep in u.dependencies.union(&u.imports) {
                if let Some(dep) = names.get(&dep.to_lowercase()).filter(|d| *d != name) {
                    ensure!(
                        precompiled.contains(dep),
                        "Precompiled unit {name} also requires: {dep}"
                    );
                }
            }
        }
        let dependency_directory = directory.with_file_name(format!(
            "{}-dependencies",
            directory
                .file_name()
                .context("build directory name missing")?
                .to_string_lossy()
        ));
        let mut destinations = vec![(
            directory.to_path_buf(),
            units
                .keys()
                .filter(|n| !precompiled.contains(*n))
                .cloned()
                .collect::<BTreeSet<_>>(),
        )];
        if !precompiled.is_empty() {
            destinations.push((dependency_directory.clone(), precompiled.clone()));
        }
        for (target, names) in &mut destinations {
            for (name, text) in &library_sources {
                ensure!(
                    !names.contains(name),
                    "Library source conflicts with generated unit {name}"
                );
                names.insert(name.clone());
                fs::create_dir_all(&target)?;
                write(&target.join(format!("{name}.pas")), text)?;
            }
        }
        for (target, names) in &destinations {
            fs::create_dir_all(target)?;
            let mut obsolete = Vec::new();
            for entry in fs::read_dir(target)? {
                let path = entry?.path();
                if path.extension().is_some_and(|e| e == "pas")
                    && path.file_stem().is_some_and(|n| {
                        n != "RangersSupport" && !names.contains(&n.to_string_lossy().into_owned())
                    })
                {
                    obsolete.push(path.with_extension("dcu"));
                    obsolete.push(path);
                }
            }
            discard(obsolete)?;
        }
        for unit in units.values() {
            let declarations = unit
                .pointers
                .iter()
                .filter(|(_, target)| !unit.types.contains(target))
                .map(|(name, target)| format!("{name} = ^{target};"))
                .collect::<Vec<_>>();
            let canonical = |names: &BTreeSet<String>| {
                names
                    .iter()
                    .map(|n| known.get(&n.to_lowercase()).cloned().unwrap_or(n.clone()))
                    .collect::<BTreeSet<_>>()
            };
            let own = canonical(&[unit.name.clone(), "System".into()].into());
            let interface_uses = canonical(&unit.dependencies)
                .difference(&own)
                .cloned()
                .collect::<BTreeSet<_>>();
            let implementation_uses = canonical(&unit.imports)
                .difference(&interface_uses)
                .filter(|n| !own.contains(*n))
                .cloned()
                .collect::<BTreeSet<_>>();
            let mut text = vec![
                format!("unit {};", unit.name),
                "{$O-}{$R-}{$Q-}{$B-}{$A8}".into(),
                "interface".into(),
            ];
            if !interface_uses.is_empty() {
                text.push(format!(
                    "uses {};",
                    ordered_imports(&interface_uses, &unit.interface_imports, &known).join(", ")
                ));
            }
            if !declarations.is_empty() {
                text.push("type".into());
                text.push(declarations.join("\n"));
            }
            let mut declarations = unit
                .globals
                .iter()
                .chain(&unit.constants)
                .map(|d| {
                    Ok(if d.kind == "global" {
                        (d.start, "var", self.global(d)?, None)
                    } else {
                        (d.start, "const", self.constant(d)?, None)
                    })
                })
                .collect::<Result<Vec<_>>>()?;
            declarations.extend(
                unit.externals
                    .iter()
                    .map(|(position, text)| (*position, "", text.clone(), None)),
            );
            // Keep complete-type dependencies ahead of their consumers while
            // interleaving public storage at its source position. Parsing a
            // global anonymous array emits RTTI and advances DCC's name counter.
            let mut position = usize::MAX;
            let mut types = Vec::new();
            for name in unit.types.iter().rev() {
                position = position.min(unit.type_positions[name]);
                types.push((position, "type", self.definitions[name].clone(), Some(name)));
            }
            declarations.extend(types.into_iter().rev());
            declarations.sort_by_key(|d| d.0);
            let mut data_section = "";
            for (index, (_, section, declaration, _)) in declarations.iter().enumerate() {
                if *section != data_section {
                    if !section.is_empty() {
                        text.push((*section).into());
                    }
                    data_section = section;
                    if *section == "type" {
                        // Forward pointer targets must resolve before this type
                        // section ends, not across an intervening var/const block.
                        let names = declarations[index..]
                            .iter()
                            .take_while(|d| d.1 == "type")
                            .filter_map(|d| d.3)
                            .collect::<BTreeSet<_>>();
                        for name in &names {
                            if self.classes.contains(*name) {
                                text.push(format!("{name} = class;"));
                            } else if self.interfaces.contains(*name) {
                                text.push(format!("{name} = interface;"));
                            }
                        }
                        for (name, target) in &unit.pointers {
                            if names.contains(target) {
                                text.push(format!("{name} = ^{target};"));
                            }
                        }
                    }
                }
                text.push(declaration.clone());
            }
            text.extend(unit.interface.clone());
            text.push("implementation".into());
            if !implementation_uses.is_empty() {
                text.push(format!(
                    "uses {};",
                    ordered_imports(&implementation_uses, &unit.implementation_imports, &known)
                        .join(", ")
                ));
            }
            text.extend(unit.implementation.clone());
            for (section, fragments) in [
                ("initialization", &unit.initialization),
                ("finalization", &unit.finalization),
            ] {
                if !fragments.is_empty() {
                    text.push(section.into());
                    text.extend(fragments.clone());
                }
            }
            text.push("end.".into());
            let target = if precompiled.contains(&unit.name) {
                &dependency_directory
            } else {
                directory
            };
            write(
                &target.join(format!("{}.pas", unit.name)),
                &(text.join("\n\n") + "\n"),
            )?;
        }
        let support = "unit RangersSupport;\ninterface\nprocedure MissingImplementation(Address: Cardinal; const Captures: array of Pointer);\nimplementation\nuses SysUtils;\nprocedure MissingImplementation(Address: Cardinal; const Captures: array of Pointer);\nbegin raise Exception.Create('Unrecovered native routine: ' + IntToHex(Address, 8)); end;\nend.\n";
        for (target, _) in &destinations {
            write(&target.join("RangersSupport.pas"), support)?;
        }
        let dependency_entry = if precompiled.is_empty() {
            None
        } else {
            let entry = dependency_directory.join("UnitDependencies.dpr");
            write(
                &entry,
                &format!(
                    "program UnitDependencies;\nuses {};\nbegin end.\n",
                    precompiled.iter().cloned().collect::<Vec<_>>().join(", ")
                ),
            )?;
            Some(entry)
        };
        let mut unit_names = units.keys().cloned().collect::<Vec<_>>();
        unit_names.sort();
        write(
            &directory.join("RecoveredUnits.inc"),
            &unit_names.join(",\n"),
        )?;
        write(
            &directory.join("RecoveredExports.inc"),
            &if retain_all {
                format!("exports\n  {};\n", exports.join(",\n  "))
            } else {
                String::new()
            },
        )?;
        let mut entry_text = fs::read_to_string(self.project.path("source")?.join("Rangers.dpr"))?;
        if retain_all && let Some(program) = &self.project.program {
            let clause = program
                .tree
                .children
                .iter()
                .find(|n| n.kind == "uses")
                .context("The recovered program requires an explicit uses clause")?;
            let explicit = clause
                .children
                .iter()
                .filter_map(|n| n.value.clone())
                .collect::<Vec<_>>();
            let declared = explicit
                .iter()
                .map(|n| n.to_lowercase())
                .collect::<BTreeSet<_>>();
            let mut imports = unit_names
                .iter()
                .filter(|n| !declared.contains(&n.to_lowercase()))
                .cloned()
                .collect::<Vec<_>>();
            imports.extend(explicit);
            entry_text.replace_range(
                clause.first.start..clause.last.end,
                &format!("uses {};", imports.join(", ")),
            );
        }
        let entry = directory.join("Rangers.dpr");
        write(&entry, &entry_text)?;
        let mut widths = BTreeMap::<String, BTreeSet<i64>>::new();
        for (unit, facts) in &self.facts {
            for (name, typ) in &facts.constants {
                widths
                    .entry(format!("{unit}.{name}"))
                    .or_default()
                    .insert(self.project.compiler.size(typ)?);
            }
        }
        let constants = widths
            .into_iter()
            .filter_map(|(name, sizes)| {
                if sizes.len() == 1 {
                    Some((name, *sizes.first().unwrap()))
                } else {
                    None
                }
            })
            .collect();
        let mut indirect = BTreeMap::new();
        for unit in units.values() {
            for d in &unit.globals {
                if let Some(address) = d.meta.get("indirect").and_then(Value::as_u64) {
                    indirect.insert(format!("{}.{}", unit.name, d.name), address as u32);
                }
            }
        }
        let mut unimplemented = self.unrecovered.clone();
        unimplemented.extend(
            self.bodies
                .iter()
                .filter(|b| !b.recovered)
                .map(|b| (b.address, b.name.clone())),
        );
        Ok(Sources {
            entry,
            dependency_entry,
            precompiled_units: precompiled.into_iter().collect(),
            bindings: Bindings {
                constants,
                indirect,
                unimplemented,
            },
        })
    }
}
