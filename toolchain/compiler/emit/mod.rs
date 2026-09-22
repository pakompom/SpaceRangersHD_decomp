//! Lower verified Delphi layouts into their original compilation units.
use crate::util::{array, integer, string, yes};
use crate::{
    pascal::model::Decl,
    pascal::types::builtin,
    project::Project,
    project::source::{Body, Facts, type_names},
};
use anyhow::{Context, Result, bail, ensure};
use indexmap::IndexMap;
use serde_json::{Value, json};
use std::{
    collections::{BTreeMap, BTreeSet},
    path::Path,
};
mod units;
pub use units::{Bindings, Sources};

pub fn owner(d: &Decl) -> String {
    Path::new(d.source.rsplit_once(':').map_or(d.source.as_str(), |p| p.0))
        .file_stem()
        .unwrap()
        .to_string_lossy()
        .into_owned()
}
fn methods(d: &Decl) -> Result<Vec<Decl>> {
    array(&d.data, "methods")
        .iter()
        .map(|v| Ok(serde_json::from_value(v.clone())?))
        .collect()
}

pub struct Emitter<'a> {
    pub project: &'a mut Project,
    pub bodies: Vec<Body>,
    pub facts: Vec<(String, Facts)>,
    words: BTreeSet<String>,
    unqualified: BTreeSet<String>,
    imports: BTreeSet<String>,
    definitions: IndexMap<String, String>,
    dependencies: BTreeMap<String, BTreeSet<String>>,
    type_stack: Vec<String>,
    stub_declarations: IndexMap<String, Decl>,
    library_types: BTreeSet<String>,
    pointers: IndexMap<String, String>,
    pointer_users: BTreeMap<String, BTreeSet<String>>,
    classes: BTreeSet<String>,
    interfaces: BTreeSet<String>,
    active: BTreeSet<String>,
    member_bodies: BTreeMap<String, IndexMap<String, Decl>>,
    virtual_sizes: BTreeMap<String, i64>,
    unrecovered: BTreeMap<u32, String>,
    body_names: BTreeSet<String>,
    constant_declarations: Vec<Decl>,
}
impl<'a> Emitter<'a> {
    pub fn new(project: &'a mut Project) -> Result<Self> {
        let bodies = project.bodies()?;
        let mut facts = Vec::new();
        for doc in &project.documents {
            facts.push((
                doc.path.file_stem().unwrap().to_string_lossy().into_owned(),
                doc.facts(true)?,
            ));
        }
        if let Some(program) = &project.program {
            facts.push(("Rangers".into(), program.facts(false)?));
        }
        let mut words = BTreeSet::new();
        let mut unqualified = BTreeSet::new();
        let qualified: BTreeSet<_> = project
            .compiler
            .decls
            .iter()
            .filter(|d| matches!(d.kind.as_str(), "global" | "routine" | "constant"))
            .map(|d| (owner(d).to_lowercase(), d.name.to_lowercase()))
            .collect();
        for (_, f) in &facts {
            words.extend(f.words.clone());
            unqualified.extend(f.external_names(&project.compiler)?);
            for pair in &f.qualified_names {
                if qualified.contains(pair) {
                    unqualified.insert(pair.1.clone());
                }
            }
        }
        for d in project.compiler.types.values() {
            for p in array(&d.data, "properties") {
                if words.contains(&string(p, "name").to_lowercase()) {
                    for access in ["read", "write"] {
                        if let Some(name) = p.get(access).and_then(Value::as_str) {
                            words.insert(name.to_lowercase());
                        }
                    }
                }
            }
        }
        let mut imports: BTreeSet<_> = ["Windows", "SysUtils", "Math"].map(String::from).into();
        let units: BTreeMap<_, _> = array(&project.library.data, "matches")
            .iter()
            .map(|r| {
                (
                    string(r, "unit").to_lowercase(),
                    string(r, "unit").to_owned(),
                )
            })
            .collect();
        for (_, f) in &facts {
            for name in &f.dotted_names {
                if name != "system"
                    && let Some(unit) = units.get(name)
                {
                    imports.insert(unit.clone());
                }
            }
        }
        let body_names = bodies.iter().map(|b| b.name.to_lowercase()).collect();
        let constant_declarations = project
            .compiler
            .decls
            .iter()
            .filter(|d| d.kind == "constant")
            .cloned()
            .collect();
        let mut member_bodies: BTreeMap<String, IndexMap<String, Decl>> = BTreeMap::new();
        for body in &bodies {
            if body.parent.is_some() || body.program {
                continue;
            }
            let mut d = body
                .signature
                .clone()
                .context("missing implementation signature")?;
            let interface = project.routine(&format!("{:x}", body.address))?;
            let defaults: BTreeMap<_, _> = array(&interface.data, "params")
                .iter()
                .filter_map(|p| {
                    p.get("default")
                        .map(|v| (string(p, "name").to_lowercase(), v.clone()))
                })
                .collect();
            for p in d.data["params"].as_array_mut().unwrap() {
                if let Some(value) = defaults.get(&string(p, "name").to_lowercase()) {
                    p["default"] = value.clone();
                }
            }
            if let Some(owner) = d.data["owner"].as_str() {
                member_bodies
                    .entry(owner.to_lowercase())
                    .or_default()
                    .insert(string(&d.data, "method_name").into(), d);
            }
        }
        Ok(Self {
            project,
            bodies,
            facts,
            words,
            unqualified,
            imports,
            definitions: IndexMap::new(),
            dependencies: BTreeMap::new(),
            type_stack: vec![],
            stub_declarations: IndexMap::new(),
            library_types: BTreeSet::new(),
            pointers: IndexMap::new(),
            pointer_users: BTreeMap::new(),
            classes: BTreeSet::new(),
            interfaces: BTreeSet::new(),
            active: BTreeSet::new(),
            member_bodies,
            virtual_sizes: BTreeMap::new(),
            unrecovered: BTreeMap::new(),
            body_names,
            constant_declarations,
        })
    }
    fn heading(&mut self, d: &Decl, qualified: bool, defaults: bool) -> Result<String> {
        crate::pascal::render::heading(d, &mut |spec| self.typ(spec), qualified, defaults)
    }
    fn alignment(&mut self, typ: &Value) -> Result<i64> {
        if typ.is_object() {
            if let Some(inner) = typ.get("array") {
                return self.alignment(inner);
            }
            if typ.get("callable").is_some() {
                return self.project.compiler.size(typ);
            }
            if typ.get("set").is_some() {
                return Ok(1);
            }
            if typ.get("subrange").is_some() {
                return Ok(self.project.compiler.size(typ)?.min(8));
            }
            return Ok(4);
        }
        let name = typ.as_str().context("field type missing")?;
        if let Some((_, size)) = builtin(name) {
            return Ok(size.min(8));
        }
        let d = self.project.compiler.lookup(name)?;
        if d.kind == "alias" {
            return self.alignment(&d.data["type"]);
        }
        if d.kind == "record" {
            if yes(&d.data, "packed") {
                return Ok(1);
            }
            let fields = array(&*self.project.compiler.layout(&d)?, "fields").to_vec();
            let mut alignment = 1;
            for f in fields {
                alignment = alignment.max(self.alignment(&f["type"])?);
            }
            return Ok(alignment);
        }
        if d.kind == "enum" {
            return d.meta["size"].as_i64().context("enum width missing");
        }
        Ok(4)
    }
    pub fn typ(&mut self, spec: &Value) -> Result<String> {
        if spec.is_object() {
            if let Some(bounds) = spec.get("enum_range") {
                let (name, _, _) = self.project.compiler.enum_range(bounds)?;
                self.typ(&json!(name))?;
                return crate::pascal::render::spelling(spec);
            }
            if spec.get("subrange").is_some() {
                return crate::pascal::render::spelling(spec);
            }
            if let Some(signature) = spec.get("callable") {
                let d = Decl {
                    name: String::new(),
                    kind: "routine".into(),
                    source: "procedural type".into(),
                    meta: Default::default(),
                    data: signature.clone(),
                    start: 0,
                    end: 0,
                    closing: None,
                    type_span: None,
                };
                let mut text = self
                    .heading(&d, false, true)?
                    .trim_end_matches(';')
                    .to_owned();
                if yes(signature, "of_object") {
                    let abi = string(signature, "abi");
                    if abi.is_empty() {
                        text.push_str(" of object");
                    } else {
                        text = text.replace(&format!("; {abi}"), &format!(" of object; {abi}"));
                    }
                }
                return Ok(text);
            }
            if let Some(inner) = spec.get("pointer") {
                let inner = self.typ(inner)?;
                let name = format!(
                    "PointerTo{}",
                    inner
                        .chars()
                        .map(|c| if c.is_alphanumeric() { c } else { '_' })
                        .collect::<String>()
                );
                self.pointers.insert(name.clone(), inner);
                if let Some(user) = self.type_stack.last() {
                    self.pointer_users
                        .entry(name.clone())
                        .or_default()
                        .insert(user.clone());
                }
                return Ok(name);
            }
            if let Some(inner) = spec.get("array") {
                if let Some(index) = spec.get("index") {
                    return Ok(format!(
                        "array[{}] of {}",
                        self.typ(index)?,
                        self.typ(inner)?
                    ));
                }
                let lo = integer(spec, "lower")?;
                return Ok(format!(
                    "array[{lo}..{}] of {}",
                    lo + integer(spec, "count")? - 1,
                    self.typ(inner)?
                ));
            }
            if let Some(element) = spec.get("set") {
                return Ok(if element.is_object() {
                    format!(
                        "set of {}..{}",
                        integer(element, "lower")?,
                        integer(element, "upper")?
                    )
                } else {
                    format!("set of {}", self.typ(element)?)
                });
            }
            if let Some(element) = spec.get("open_array") {
                return Ok(format!(
                    "array of {}",
                    if element == "const" {
                        "const".into()
                    } else {
                        self.typ(element)?
                    }
                ));
            }
            if let Some(element) = spec.get("dynamic_array") {
                return Ok(format!("array of {}", self.typ(element)?));
            }
            if spec.get("vmt").is_some() || spec.get("classref").is_some() {
                return Ok("Pointer".into());
            }
            bail!("Unsupported build type: {spec}")
        }
        let requested = spec.as_str().context("missing build type")?;
        let key = requested.to_lowercase();
        if builtin(&key).is_some() {
            if let Some(user) = self.type_stack.last() {
                self.dependencies
                    .entry(user.clone())
                    .or_default()
                    .insert(requested.into());
            }
            return Ok(requested.into());
        }
        let d = self.project.compiler.lookup(requested)?;
        let name = d.name.clone();
        if let Some(user) = self.type_stack.last().filter(|u| **u != name) {
            self.dependencies
                .entry(user.clone())
                .or_default()
                .insert(name.clone());
        }
        if self.active.contains(&key) || self.definitions.contains_key(&name) {
            return Ok(name);
        }
        let unit = owner(&d);
        let qualified = format!("{unit}.{name}").to_lowercase();
        let library_name = ["System.PChar", "System.PWideChar", "System.TextFile"]
            .into_iter()
            .map(String::from)
            .chain(
                array(&self.project.library.data, "types")
                    .iter()
                    .filter_map(Value::as_str)
                    .map(String::from),
            )
            .find(|n| n.to_lowercase() == qualified);
        if let Some(library_name) =
            library_name.filter(|_| self.member_bodies.get(&key).is_none_or(|b| b.is_empty()))
        {
            if !unit.eq_ignore_ascii_case("system") {
                self.imports.insert(unit);
            }
            self.library_types.insert(name.clone());
            self.definitions
                .insert(name.clone(), format!("{name} = {library_name};"));
            if d.kind == "class" {
                let size = self
                    .project
                    .compiler
                    .virtual_slots(&d)?
                    .keys()
                    .map(|s| s + 4)
                    .max()
                    .unwrap_or(0);
                self.virtual_sizes.insert(key, size);
            }
            return Ok(name);
        }
        self.active.insert(key.clone());
        self.type_stack.push(name.clone());
        let text = match d.kind.as_str() {
            "class" | "record" => self.aggregate(&d)?,
            "enum" => {
                let width = d
                    .meta
                    .get("size")
                    .and_then(Value::as_i64)
                    .context("enum @size missing")?;
                ensure!(
                    [1, 2, 4].contains(&width),
                    "Unsupported Pascal enum width: {name}"
                );
                let members = array(&d.data, "members")
                    .iter()
                    .map(|m| format!("{} = {}", m[0].as_str().unwrap(), m[1]))
                    .collect::<Vec<_>>()
                    .join(",\n  ");
                format!("{{$Z{width}}}\n{name} = ({members});")
            }
            "alias" => format!("{name} = {};", self.typ(&d.data["type"])?),
            "interface" => self.interface(&d)?,
            _ => bail!("Unsupported declaration: {name} ({})", d.kind),
        };
        self.definitions.insert(name.clone(), text);
        self.active.remove(&key);
        self.type_stack.pop();
        Ok(name)
    }
    fn aggregate(&mut self, d: &Decl) -> Result<String> {
        let name = &d.name;
        let key = name.to_lowercase();
        if d.kind == "class" {
            self.classes.insert(name.clone());
        }
        let layout = self.project.compiler.layout(d)?;
        let mut parent = if d.kind == "class" {
            string(&d.data, "parent").to_owned()
        } else {
            String::new()
        };
        if d.kind == "class"
            && parent.is_empty()
            && key != "tobject"
            && self.project.compiler.types.contains_key("tobject")
        {
            parent = "TObject".into();
        }
        let base_size = if !parent.is_empty() {
            let pd = self.project.compiler.lookup(&parent)?;
            self.project.compiler.layout(&pd)?["size"]
                .as_i64()
                .context("incomplete parent")?
        } else if d.kind == "class" {
            4
        } else {
            0
        };
        if !parent.is_empty() {
            self.typ(&json!(parent))?;
        }
        if d.kind == "class" {
            let inherited = self
                .virtual_sizes
                .get(&parent.to_lowercase())
                .copied()
                .unwrap_or(0);
            let used = self
                .project
                .compiler
                .virtual_slots(d)?
                .iter()
                .filter(|(_, m)| {
                    self.words
                        .contains(&string(&m.data, "method_name").to_lowercase())
                })
                .map(|(s, _)| s + 4)
                .max()
                .unwrap_or(0);
            self.virtual_sizes.insert(key.clone(), inherited.max(used));
        }
        let parent_text = if parent.is_empty() {
            "System.TObject"
        } else {
            &parent
        };
        let Some(size) = layout["size"].as_i64() else {
            return Ok(if d.kind == "class" {
                format!("{name} = class({parent_text}) end;")
            } else {
                format!("{name} = packed record Opaque: Byte; end;")
            });
        };
        let (mut lines, mut offset) = (Vec::new(), base_size);
        if !parent.is_empty() {
            let pd = self.project.compiler.lookup(&parent)?;
            let fields = array(&*self.project.compiler.layout(&pd)?, "fields").to_vec();
            let mut alignment = 1;
            for field in fields {
                alignment = alignment.max(self.alignment(&field["type"])?);
            }
            offset = (offset + alignment - 1) & -alignment;
        }
        let packed = yes(&d.data, "packed");
        for field in array(&layout, "fields") {
            let off = integer(field, "offset")?;
            if off < base_size {
                continue;
            }
            let alignment = if packed {
                1
            } else {
                self.alignment(&field["type"])?
            };
            let aligned = (offset + alignment - 1) & -alignment;
            ensure!(
                aligned <= off,
                "{name}.{}: field precedes its Delphi alignment",
                string(field, "name")
            );
            if off > aligned {
                lines.push(format!(
                    "Gap{offset:X}: array[0..{}] of Byte;",
                    off - offset - 1
                ));
            }
            lines.push(format!(
                "{}: {};",
                string(field, "name"),
                self.typ(&field["type"])?
            ));
            offset = off + self.project.compiler.size(&field["type"])?;
        }
        // Classes round their VMT instance size to four bytes; records round to
        // their largest field alignment. Packed records and value objects do not.
        let alignment = if d.kind == "class" {
            4
        } else if packed || yes(&d.data, "value_object") {
            1
        } else {
            self.alignment(&json!(name))?
        };
        let aligned = (offset + alignment - 1) & -alignment;
        ensure!(
            aligned <= size,
            "{name}: size precedes its Delphi alignment"
        );
        if size > aligned {
            lines.push(format!(
                "Gap{offset:X}: array[0..{}] of Byte;",
                size - offset - 1
            ));
        }
        let mut implemented = BTreeSet::new();
        if d.kind == "class" {
            let mut slot_end = self
                .virtual_sizes
                .get(&parent.to_lowercase())
                .copied()
                .unwrap_or(0);
            let virtuals = self.project.compiler.virtual_slots(d)?;
            let own = methods(d)?;
            for (&slot, method) in &virtuals {
                if !own.iter().any(|m| m.name == method.name)
                    || !self
                        .words
                        .contains(&string(&method.data, "method_name").to_lowercase())
                {
                    continue;
                }
                while slot_end < slot {
                    lines.push(format!(
                        "procedure MatchReservedSlot{slot_end:X}; virtual; abstract;"
                    ));
                    slot_end += 4;
                }
                let head = self.heading(method, false, true)?;
                let directive = if slot < slot_end {
                    "override"
                } else {
                    "virtual"
                };
                let method_name = string(&method.data, "method_name").to_lowercase();
                let recovered = self.member_bodies.get(&key).and_then(|members| {
                    members
                        .iter()
                        .find(|(name, _)| name.to_lowercase() == method_name)
                        .map(|(_, d)| d.clone())
                });
                if let Some(recovered) = recovered {
                    lines.push(format!(
                        "{} {directive};",
                        self.heading(&recovered, false, true)?
                    ));
                    implemented.insert(method_name);
                } else {
                    lines.push(format!("{head} {directive}; abstract;"));
                }
                slot_end = slot_end.max(slot + 4);
            }
            self.virtual_sizes.insert(key.clone(), slot_end);
            for method in own {
                let method_name = string(&method.data, "method_name");
                let kind = string(&method.data, "routine_kind");
                if self.body_names.contains(&method.name.to_lowercase())
                    || !self.words.contains(&method_name.to_lowercase())
                    || virtuals.values().any(|m| m.name == method.name)
                    || !method.meta.contains_key("addr")
                    || method.meta.contains_key("nameonly")
                    || yes(&method.data, "class_method")
                    || !matches!(
                        kind,
                        "function" | "procedure" | "constructor" | "destructor"
                    )
                {
                    continue;
                }
                lines.push(format!(
                    "{}{}",
                    self.heading(&method, false, true)?,
                    if kind == "destructor" {
                        " override;"
                    } else {
                        ""
                    }
                ));
                self.stub(&method)?;
            }
        }
        let members = self.member_bodies.get(&key).cloned().unwrap_or_default();
        for (member, d) in members {
            if d.kind == "class" && implemented.contains(&member.to_lowercase()) {
                continue;
            }
            if implemented.contains(&member.to_lowercase()) {
                continue;
            }
            lines.push(format!(
                "{}{}",
                self.heading(&d, false, true)?,
                if string(&d.data, "routine_kind") == "destructor" {
                    " override;"
                } else {
                    ""
                }
            ));
        }
        for p in array(&d.data, "properties") {
            if self.words.contains(&string(p, "name").to_lowercase()) {
                lines.push(self.property(p)?);
            }
        }
        let kind = if d.kind == "class" {
            format!("class({parent_text})")
        } else if yes(&d.data, "value_object") {
            "object".into()
        } else if yes(&d.data, "packed") {
            "packed record".into()
        } else {
            "record".into()
        };
        Ok(format!("{name} = {kind}\n  {}\nend;", lines.join("\n  ")))
    }
    fn property(&mut self, p: &Value) -> Result<String> {
        let mut indices = Vec::new();
        for param in array(p, "params") {
            indices.push(format!(
                "{}: {}",
                string(param, "name"),
                self.typ(&param["type"])?
            ));
        }
        let mut head = format!(
            "property {}{}: {}",
            string(p, "name"),
            if indices.is_empty() {
                String::new()
            } else {
                format!("[{}]", indices.join("; "))
            },
            self.typ(&p["type"])?
        );
        for access in ["read", "write"] {
            if let Some(value) = p.get(access).and_then(Value::as_str) {
                head.push_str(&format!(" {access} {value}"));
            }
        }
        head.push(';');
        Ok(head)
    }
    fn interface(&mut self, d: &Decl) -> Result<String> {
        if yes(&d.data, "opaque") {
            return Ok(format!("{} = Pointer;", d.name));
        }
        self.interfaces.insert(d.name.clone());
        let mut parent = string(&d.data, "parent").to_owned();
        if parent.is_empty() && !d.name.eq_ignore_ascii_case("iinterface") {
            parent = "IInterface".into();
        }
        let base = if parent.is_empty() {
            String::new()
        } else {
            format!("({})", self.typ(&json!(parent))?)
        };
        let mut lines = Vec::new();
        if let Some(guid) = d.data.get("guid").and_then(Value::as_str) {
            lines.push(guid.into());
        }
        for method in methods(d)? {
            lines.push(self.heading(&method, false, true)?);
        }
        for property in array(&d.data, "properties") {
            lines.push(self.property(property)?);
        }
        Ok(format!(
            "{} = interface{base}\n  {}\nend;",
            d.name,
            lines.join("\n  ")
        ))
    }
    fn stub(&mut self, d: &Decl) -> Result<String> {
        ensure!(
            !d.meta.contains_key("nameonly"),
            "{}: recover the Delphi signature before using this dependency",
            d.name
        );
        self.stub_declarations.insert(d.name.clone(), d.clone());
        if let Some(external) = d.data.get("external").and_then(Value::as_str) {
            return Ok(format!("{} {external};", self.heading(d, true, true)?));
        }
        let address = d.meta["addr"].as_u64().context("stub address missing")? as u32;
        self.unrecovered.insert(address, d.name.clone());
        Ok(format!(
            "{}\nbegin MissingImplementation(${address:X}, []); end;",
            self.heading(d, true, false)?
        ))
    }
    fn ordered_type_names(&self, unit: Option<&str>) -> Result<Vec<String>> {
        fn emit(
            e: &Emitter,
            declarations: &BTreeMap<String, std::sync::Arc<Decl>>,
            name: &str,
            emitted: &mut BTreeSet<String>,
            visiting: &mut BTreeSet<String>,
            ordered: &mut Vec<String>,
        ) -> Result<()> {
            if emitted.contains(name) {
                return Ok(());
            }
            ensure!(
                visiting.insert(name.into()),
                "Cyclic complete-type dependency in build view: {name}"
            );
            let d = &declarations[&name.to_lowercase()];
            if !e.library_types.contains(name) {
                let parent = string(&d.data, "parent");
                let mut specs = Vec::new();
                if matches!(d.kind.as_str(), "record" | "class" | "interface") {
                    specs.extend(array(&d.data, "fields").iter().map(|f| f["type"].clone()));
                    for method in methods(d)? {
                        if d.kind == "interface"
                            || e.words
                                .contains(&string(&method.data, "method_name").to_lowercase())
                        {
                            specs.extend(
                                array(&method.data, "params")
                                    .iter()
                                    .map(|p| p["type"].clone()),
                            );
                            specs.push(method.data["result"].clone());
                        }
                    }
                } else if d.kind == "alias" {
                    specs.push(d.data["type"].clone());
                }
                specs.push(d.data["parent"].clone());
                let names: BTreeMap<_, _> = e
                    .definitions
                    .keys()
                    .map(|n| (n.to_lowercase(), n.clone()))
                    .collect();
                let dependencies: BTreeSet<_> = specs
                    .iter()
                    .flat_map(|s| type_names(s, true))
                    .map(|n| n.to_lowercase())
                    .filter(|n| names.contains_key(n))
                    .collect();
                for key in dependencies {
                    let dep = &names[&key];
                    if dep == name || owner(&declarations[&dep.to_lowercase()]) != owner(d) {
                        continue;
                    }
                    if !e.classes.contains(dep) && !e.interfaces.contains(dep)
                        || !parent.is_empty() && key == parent.to_lowercase()
                    {
                        emit(e, declarations, dep, emitted, visiting, ordered)?;
                    }
                }
            }
            visiting.remove(name);
            emitted.insert(name.into());
            ordered.push(name.into());
            Ok(())
        }
        let (mut emitted, mut visiting, mut ordered) =
            (BTreeSet::new(), BTreeSet::new(), Vec::new());
        let mut declarations = self.project.compiler.types.clone();
        if let Some(unit) = unit {
            for d in &self.project.compiler.decls {
                if d.kind == "alias" && owner(d) == unit {
                    declarations.insert(d.name.to_lowercase(), std::sync::Arc::new(d.clone()));
                }
            }
        }
        // Parsing order determines VMT placement and anonymous RTTI names.
        // Imported types do not constrain declaration order inside this unit.
        let mut names = self
            .definitions
            .keys()
            .filter(|name| {
                unit.is_none_or(|unit| owner(&declarations[&name.to_lowercase()]) == unit)
            })
            .map(|name| {
                let d = &declarations[&name.to_lowercase()];
                Ok((owner(d), d.start, name))
            })
            .collect::<Result<Vec<_>>>()?;
        names.sort_by(|a, b| (&a.0, a.1).cmp(&(&b.0, b.1)));
        for (_, _, name) in names {
            emit(
                self,
                &declarations,
                name,
                &mut emitted,
                &mut visiting,
                &mut ordered,
            )?;
        }
        Ok(ordered)
    }
    fn library_units(&self) -> BTreeSet<String> {
        let mut library_units: BTreeSet<_> = array(&self.project.library.data, "matches")
            .iter()
            .map(|r| string(r, "unit").to_lowercase())
            .collect();
        // Runtime declaration files also cover DCUs with no attributed routine
        // bodies (for example ActiveX). Do not replace those with empty units.
        if let Some(path) = self.project.settings["compiler"]["library"].as_str() {
            let library = self.project.root.join(path);
            for document in &self.project.documents {
                let name = document.path.file_stem().unwrap().to_string_lossy();
                if document
                    .path
                    .parent()
                    .and_then(Path::file_name)
                    .is_some_and(|p| p == "runtime")
                    && library.join(format!("{name}.dcu")).is_file()
                {
                    library_units.insert(name.to_lowercase());
                }
            }
        }
        library_units
    }
    fn prepare(&mut self) -> Result<()> {
        for d in self.constant_declarations.clone() {
            if !d.data["type"].is_null() {
                self.typ(&d.data["type"])?;
            }
        }
        for name in self.words.clone() {
            if self.project.compiler.types.contains_key(&name) {
                self.typ(&json!(name))?;
            }
        }
        let library_units = self.library_units();
        for d in self.project.compiler.decls.clone() {
            if d.is_inline_helper() {
                for p in array(&d.data, "params") {
                    if !p["type"].is_null() {
                        self.typ(&p["type"])?;
                    }
                }
                if !d.data["result"].is_null() {
                    self.typ(&d.data["result"])?;
                }
                continue;
            }
            let initialized = d.kind == "global" && d.data.get("initializer").is_some();
            if (!self.unqualified.contains(&d.name.to_lowercase())
                || self.body_names.contains(&d.name.to_lowercase()))
                && !initialized
            {
                continue;
            }
            if d.kind == "global" {
                self.typ(&d.data["type"])?;
            } else if d.kind == "routine"
                && !matches!(d.name.to_lowercase().as_str(), "round" | "trunc")
            {
                let unit = owner(&d);
                if library_units.contains(&unit.to_lowercase()) {
                    if !unit.eq_ignore_ascii_case("system") {
                        self.imports.insert(unit);
                    }
                    continue;
                }
                self.stub(&d)?;
            }
        }
        Ok(())
    }
    fn constant(&mut self, d: &Decl) -> Result<String> {
        let storage = if d.data["type"].is_null() {
            String::new()
        } else {
            format!(": {}", self.typ(&d.data["type"])?)
        };
        Ok(format!(
            "{}{storage} = {};",
            d.name,
            string(&d.data, "initializer")
        ))
    }
    fn global(&mut self, d: &Decl) -> Result<String> {
        let init = d
            .data
            .get("initializer")
            .and_then(Value::as_str)
            .map_or(String::new(), |s| format!(" = {s}"));
        Ok(format!("{}: {}{init};", d.name, self.typ(&d.data["type"])?))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::pascal::{parser::Parser, types::Compiler};

    #[test]
    fn imported_type_discovery_preserves_its_units_declaration_order() -> Result<()> {
        let mut declarations = Vec::new();
        for (source, text) in [
            (
                "A.pas",
                "unit A; interface uses B; type TConsumer = TAlias; implementation end.",
            ),
            (
                "B.pas",
                "unit B; interface type ZFirst = array of Byte; TBase = array of Integer; TAlias = TBase; implementation end.",
            ),
        ] {
            declarations.extend(
                Parser::new(text, source, false, None)?
                    .document(false)?
                    .children
                    .into_iter()
                    .filter_map(|n| n.declaration),
            );
        }
        let mut project = Project {
            root: Default::default(),
            settings: json!({}),
            documents: Vec::new(),
            program: None,
            library: Default::default(),
            compiler: Compiler::new(declarations)?,
            routines_by_address: Default::default(),
            routines_by_name: Default::default(),
        };
        let mut emitter = Emitter::new(&mut project)?;
        emitter.typ(&json!("TConsumer"))?;
        emitter.typ(&json!("ZFirst"))?;
        let names = emitter.ordered_type_names(None)?;
        assert_eq!(names, ["TConsumer", "ZFirst", "TBase", "TAlias"]);
        Ok(())
    }
}
