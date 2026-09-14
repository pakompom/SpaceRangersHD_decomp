//! Source ownership and scoped references used by matching and project generation.
use crate::util::{array, string};
use crate::{
    pascal::types::Compiler,
    pascal::{
        annotations,
        lexer::{self, Kind},
        model::{Decl, Node},
    },
    project::{Document, Project},
};
use anyhow::{Context, Result, ensure};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
    collections::{BTreeMap, BTreeSet},
    path::Path,
};

#[derive(Clone, Serialize, Deserialize)]
pub struct Body {
    pub address: u32,
    pub name: String,
    pub text: String,
    pub parent: Option<u32>,
    pub recovered: bool,
    pub start: usize,
    pub end: usize,
    pub signature: Option<Decl>,
    pub program: bool,
}

impl Document {
    pub fn parse(
        path: std::path::PathBuf,
        text: String,
        source: &str,
        library: &crate::project::library::Library,
    ) -> Result<Self> {
        let mut parser = crate::pascal::parser::Parser::new(&text, source, true, Some(library))?;
        let tree = parser.document(false)?;
        let tokens = parser.into_tokens();
        let mut document = Self {
            path,
            text,
            tree,
            owned_bodies: Vec::new(),
            source_facts: Facts::default(),
        };
        document.owned_bodies = document.collect_bodies(&tokens)?;
        document.source_facts = document.collect_facts(document.tree.kind == "unit", &tokens)?;
        Ok(document)
    }
    pub fn bodies(&self) -> Result<Vec<Body>> {
        Ok(self.owned_bodies.clone())
    }
    pub fn nested_declarations(&self) -> Vec<Decl> {
        fn visit(node: &Node, scope: &str, declarations: &mut Vec<Decl>) {
            let mut scope = scope.to_owned();
            if node.kind == "routine"
                && let Some(d) = &node.declaration
            {
                scope = if scope.is_empty() {
                    d.name.clone()
                } else {
                    format!("{scope}_{}", d.name)
                };
                if d.data["nested"] == true && d.meta.contains_key("addr") {
                    let mut nested = d.clone();
                    nested.data["local_name"] = Value::String(d.name.clone());
                    nested.name = scope.clone();
                    declarations.push(nested);
                }
            }
            for child in &node.children {
                visit(child, &scope, declarations);
            }
        }
        let mut declarations = Vec::new();
        visit(&self.tree, "", &mut declarations);
        declarations
    }
    pub fn facts(&self, implementation: bool) -> Result<Facts> {
        ensure!(
            implementation == (self.tree.kind == "unit"),
            "Source facts requested for a different scope"
        );
        Ok(self.source_facts.clone())
    }

    pub fn implementation(&self) -> Result<(usize, usize)> {
        let node = self
            .tree
            .children
            .iter()
            .find(|n| n.kind == "implementation")
            .context("missing implementation section")?;
        Ok((node.first.end, node.last.start))
    }
    fn collect_bodies(&self, tokens: &[lexer::Token]) -> Result<Vec<Body>> {
        let mut headings = BTreeMap::new();
        self.tree.visit(&mut |node| {
            if node.kind == "routine"
                && let Some(d) = &node.declaration
            {
                headings.insert(d.name.to_lowercase(), d.clone());
            }
        });
        let (mut result, mut nested, mut opened) =
            (Vec::new(), Vec::new(), None::<(lexer::Token, u32, String)>);
        for comment in tokens.iter().filter(|t| t.kind == Kind::Comment) {
            let parts: Vec<_> = comment.value.split_whitespace().collect();
            let Some(&marker) = parts.first() else {
                continue;
            };
            if !matches!(marker, "@routine" | "@end" | "@nested" | "@unrecovered") {
                continue;
            }
            ensure!(
                parts.len() == if marker == "@end" { 2 } else { 3 },
                "Malformed source ownership marker"
            );
            let address = u32::try_from(annotations::integer(parts[1])?)?;
            if marker == "@routine" {
                ensure!(opened.is_none(), "Source ownership markers cannot overlap");
                opened = Some((comment.clone(), address, parts[2].into()));
                nested.clear();
            } else if marker == "@end" {
                let (start, own, name) =
                    opened.take().context("Unpaired source ownership marker")?;
                ensure!(own == address, "Unpaired source ownership marker");
                let signature = headings
                    .get(&name.to_lowercase())
                    .filter(|d| start.end <= d.start && d.start < comment.start)
                    .cloned();
                result.push(Body {
                    address,
                    name,
                    text: self.text[start.end..comment.start].trim().into(),
                    parent: None,
                    recovered: true,
                    start: start.start,
                    end: comment.end,
                    signature,
                    program: false,
                });
                result.append(&mut nested);
            } else {
                let parent = opened.as_ref().context("Nested routine has no parent")?.1;
                nested.push(Body {
                    address,
                    name: parts[2].into(),
                    text: String::new(),
                    parent: Some(parent),
                    recovered: marker == "@nested",
                    start: comment.start,
                    end: comment.end,
                    signature: None,
                    program: false,
                });
            }
        }
        ensure!(opened.is_none(), "Unclosed source ownership marker");
        let mut seen = BTreeSet::new();
        for body in &result {
            ensure!(
                seen.insert(body.address),
                "Duplicated source ownership markers"
            );
        }
        Ok(result)
    }
    fn collect_facts(&self, implementation: bool, scanned: &[lexer::Token]) -> Result<Facts> {
        let tree = if implementation {
            self.tree
                .children
                .iter()
                .find(|n| n.kind == "implementation")
                .context("missing implementation")?
        } else {
            &self.tree
        };
        let (low, high) = if implementation {
            self.implementation()?
        } else {
            (0, self.text.len())
        };
        let tokens = scanned
            .iter()
            .filter(|t| {
                t.start >= low
                    && t.start < high
                    && !matches!(t.kind, Kind::Comment | Kind::Directive | Kind::Eof)
            })
            .collect::<Vec<_>>();
        let mut facts = Facts::default();
        facts.words.extend(
            tokens
                .iter()
                .filter(|t| t.kind == Kind::Identifier)
                .map(|t| t.value.to_lowercase()),
        );
        for pair in tokens.windows(2) {
            if pair[1].value == "." {
                facts.dotted_names.insert(pair[0].value.to_lowercase());
            }
            if pair[0].kind == Kind::Keyword
                && matches!(pair[0].value.to_lowercase().as_str(), "is" | "as")
                && pair[1].kind == Kind::Identifier
            {
                facts.tested_classes.insert(pair[1].value.clone());
            }
        }
        tree.visit(&mut |n| {
            if n.kind == "member" && n.children[0].kind == "name" {
                facts.qualified_names.insert((
                    n.children[0].value.as_deref().unwrap_or("").to_lowercase(),
                    n.children[1].value.as_deref().unwrap_or("").to_lowercase(),
                ));
            }
            if n.kind == "constant"
                && let Some(d) = &n.declaration
                && d.data["type"].is_string()
            {
                facts
                    .constants
                    .push((d.name.clone(), d.data["type"].clone()));
            }
        });
        facts.references(tree, &self.text, &BTreeSet::new(), &BTreeSet::new())?;
        Ok(facts)
    }
}

pub fn same_signature(a: &Value, b: &Value) -> bool {
    match (a, b) {
        (Value::String(a), Value::String(b)) => a.to_lowercase() == b.to_lowercase(),
        (Value::Array(a), Value::Array(b)) => {
            a.len() == b.len() && a.iter().zip(b).all(|(a, b)| same_signature(a, b))
        }
        (Value::Object(a), Value::Object(b)) => {
            a.len() == b.len()
                && a.iter()
                    .all(|(k, v)| b.get(k).is_some_and(|b| same_signature(v, b)))
        }
        _ => a == b,
    }
}

impl Project {
    pub fn routine(&self, selector: &str) -> Result<Decl> {
        let address = u32::from_str_radix(
            selector.trim_start_matches("0x").trim_start_matches('$'),
            16,
        )
        .ok();
        let name = selector.replace('.', "_").to_lowercase();
        let mut found = BTreeSet::<usize>::new();
        if let Some(entries) = address.and_then(|a| self.routines_by_address.get(&a)) {
            found.extend(entries.iter().copied());
        }
        if let Some(entries) = self.routines_by_name.get(&name) {
            found.extend(entries.iter().copied());
        }
        ensure!(
            found.len() == 1,
            "Expected one declared routine for {selector:?}; found {}",
            found.len()
        );
        Ok(self.compiler.decls[*found.first().unwrap()].clone())
    }
    pub fn bodies(&self) -> Result<Vec<Body>> {
        let mut bodies = Vec::new();
        for document in self.documents.iter().chain(self.program.iter()) {
            for mut body in document.bodies()? {
                let d = self.routine(&format!("{:x}", body.address))?;
                let file = d.source.rsplit_once(':').unwrap().0;
                ensure!(
                    Path::new(file).file_stem() == document.path.file_stem(),
                    "{} belongs in {}, not {}",
                    body.name,
                    file,
                    document.path.display()
                );
                ensure!(
                    body.name == d.data["local_name"].as_str().unwrap_or(&d.name),
                    "source name differs from declaration"
                );
                if document.tree.kind == "program"
                    && body.parent.is_none()
                    && body.signature.is_none()
                {
                    let block = document
                        .tree
                        .children
                        .last()
                        .context("missing main block")?;
                    ensure!(
                        array(&d.data, "params").is_empty()
                            && d.data["result"].is_null()
                            && d.data["owner"].is_null()
                            && block.kind == "block"
                            && body.start < block.first.start
                            && block.last.end < body.end,
                        "Program ownership must enclose its parameterless main begin/end block"
                    );
                    body.program = true;
                } else if body.parent.is_none() {
                    let parsed = body
                        .signature
                        .as_ref()
                        .context("expected an implementation signature")?;
                    ensure!(
                        parsed.name.to_lowercase() == d.name.to_lowercase(),
                        "implementation name differs from interface"
                    );
                    for key in ["routine_kind", "params", "result", "class_method", "abi"] {
                        let (mut left, mut right) = (parsed.data[key].clone(), d.data[key].clone());
                        if key == "abi" {
                            if left.is_null() {
                                left = if right.is_null() {
                                    Value::from("register")
                                } else {
                                    right.clone()
                                };
                            }
                            if right.is_null() {
                                right = Value::from("register");
                            }
                        } else if key == "params" {
                            for values in [&mut left, &mut right] {
                                for p in values.as_array_mut().context("invalid parameters")? {
                                    p.as_object_mut().unwrap().remove("default");
                                }
                            }
                        }
                        ensure!(
                            same_signature(&left, &right),
                            "{}: implementation {key} differs from its interface",
                            body.name
                        );
                    }
                }
                bodies.push(body);
            }
        }
        ensure!(
            bodies.iter().filter(|b| b.program).count() == usize::from(self.program.is_some()),
            "The program must own exactly one entry body"
        );
        let mut seen = BTreeSet::new();
        for body in &bodies {
            ensure!(
                seen.insert(body.address),
                "Duplicated source ownership across units"
            );
        }
        Ok(bodies)
    }
}

#[derive(Default, Clone)]
pub struct Facts {
    pub words: BTreeSet<String>,
    pub scoped: BTreeMap<Vec<String>, BTreeSet<String>>,
    pub qualified_names: BTreeSet<(String, String)>,
    pub dotted_names: BTreeSet<String>,
    pub tested_classes: BTreeSet<String>,
    pub constants: Vec<(String, Value)>,
    pub indexed_offsets: BTreeMap<(Vec<String>, String), BTreeSet<i64>>,
}
pub fn type_names(typ: &Value, complete: bool) -> Vec<String> {
    if let Some(name) = typ.as_str() {
        return vec![name.into()];
    }
    let mut result = Vec::new();
    if let Some(signature) = typ.get("callable") {
        for p in array(signature, "params") {
            result.extend(type_names(&p["type"], complete));
        }
        result.extend(type_names(&signature["result"], complete));
        return result;
    }
    if let Some(values) = typ.as_object() {
        if complete
            && ["pointer", "classref", "vmt"]
                .iter()
                .any(|k| values.contains_key(*k))
        {
            return result;
        }
        for v in values.values() {
            result.extend(type_names(v, complete));
        }
    }
    result
}
pub fn declaration_type_names(d: &Decl) -> Vec<String> {
    let mut names = Vec::new();
    for key in ["type", "result", "parent", "owner"] {
        names.extend(type_names(&d.data[key], false));
    }
    for key in ["params", "fields", "properties"] {
        for member in array(&d.data, key) {
            names.extend(type_names(&member["type"], false));
            for p in array(member, "params") {
                names.extend(type_names(&p["type"], false));
            }
        }
    }
    for method in array(&d.data, "methods") {
        if let Ok(method) = serde_json::from_value(method.clone()) {
            names.extend(declaration_type_names(&method));
        }
    }
    names
}
impl Facts {
    pub fn external_names(&self, compiler: &Compiler) -> Result<BTreeSet<String>> {
        let mut result = BTreeSet::new();
        for (owners, names) in &self.scoped {
            let mut members = BTreeSet::new();
            for owner in owners {
                members.extend(compiler.member_names(owner)?);
            }
            result.extend(names.difference(&members).cloned());
        }
        Ok(result)
    }
    fn references(
        &mut self,
        node: &Node,
        text: &str,
        bound: &BTreeSet<String>,
        owners: &BTreeSet<String>,
    ) -> Result<()> {
        let key = owners.iter().cloned().collect::<Vec<_>>();
        self.scoped.entry(key.clone()).or_default();
        if node.kind != "heading"
            && let Some(d) = &node.declaration
        {
            self.scoped.get_mut(&key).unwrap().extend(
                declaration_type_names(d)
                    .into_iter()
                    .map(|n| n.to_lowercase())
                    .filter(|n| !bound.contains(n)),
            );
        }
        // Most AST nodes inherit scope unchanged; only lexical scopes need owned sets.
        let mut bound = std::borrow::Cow::Borrowed(bound);
        let mut owners = std::borrow::Cow::Borrowed(owners);
        if matches!(
            node.kind.as_str(),
            "unit" | "program" | "library" | "fragment" | "implementation" | "routine"
        ) {
            bound.to_mut().extend(
                node.children
                    .iter()
                    .filter_map(|c| c.declaration.as_ref())
                    .map(|d| d.name.to_lowercase()),
            );
            if node.kind == "routine" {
                let d = node.declaration.as_ref().unwrap();
                bound.to_mut().extend(
                    array(&d.data, "params")
                        .iter()
                        .map(|p| string(p, "name").to_lowercase()),
                );
                bound.to_mut().insert("self".into());
                bound.to_mut().insert("result".into());
                let owner = string(&d.data, "owner");
                if !owner.is_empty() {
                    owners.to_mut().insert(owner.into());
                }
            }
        } else if node.kind == "on" {
            let value = node.value.as_deref().unwrap_or("");
            let (variable, typ) = value
                .split_once(':')
                .map_or((value, None), |(v, t)| (v, Some(t)));
            self.scoped
                .entry(vec![])
                .or_default()
                .insert(typ.unwrap_or(variable).to_lowercase());
            if typ.is_some() {
                bound.to_mut().insert(variable.to_lowercase());
            }
        }
        if node.kind == "index" && node.children.len() == 2 {
            let (base, index) = (&node.children[0], &node.children[1]);
            let name = base.value.as_deref().unwrap_or("").to_lowercase();
            if base.kind == "name"
                && !bound.contains(&name)
                && index.kind == "binary"
                && matches!(index.value.as_deref(), Some("+" | "-"))
                && index.children[0].kind == "name"
                && index.children[1].kind == "literal"
                && index.children[1].first.kind == Kind::Number
            {
                let value = annotations::integer(index.children[1].value.as_deref().unwrap_or(""))?;
                let value = if index.value.as_deref() == Some("-") {
                    -value
                } else {
                    value
                };
                self.indexed_offsets
                    .entry((owners.iter().cloned().collect(), name))
                    .or_default()
                    .insert(value);
            }
        }
        if node.kind == "name" {
            let name = node.value.as_deref().unwrap_or("").to_lowercase();
            if !bound.contains(&name) {
                self.scoped.get_mut(&key).unwrap().insert(name);
            }
        } else if node.kind == "member" {
            self.references(&node.children[0], text, &bound, &owners)?;
        } else if node.kind == "asm" {
            let tokens = lexer::scan(&text[node.first.start..node.last.end], "asm")?;
            for (i, t) in tokens.iter().enumerate() {
                if t.kind == Kind::Identifier
                    && !bound.contains(&t.value.to_lowercase())
                    && (i == 0 || !matches!(tokens[i - 1].value.as_str(), "." | "@"))
                    // ST(n) is an x87 register operand, not FGInt's St enum member.
                    && !(t.value.eq_ignore_ascii_case("st")
                        && tokens.get(i + 1).is_some_and(|next| next.value == "("))
                {
                    self.scoped
                        .get_mut(&key)
                        .unwrap()
                        .insert(t.value.to_lowercase());
                }
            }
        } else {
            for child in &node.children {
                self.references(child, text, &bound, &owners)?;
            }
        }
        Ok(())
    }
}

impl Project {
    pub fn store_body(
        &self,
        declaration: &Decl,
        text: &str,
        replace: bool,
    ) -> Result<std::path::PathBuf> {
        let address = declaration.meta["addr"]
            .as_u64()
            .context("Routine has no address")? as u32;
        ensure!(
            !self
                .bodies()?
                .iter()
                .any(|b| b.program && b.address == address),
            "Edit program bodies directly in Rangers.dpr"
        );
        let source = declaration
            .source
            .rsplit_once(':')
            .map_or(declaration.source.as_str(), |(p, _)| p);
        let path = self.root.join(source);
        let existing = std::fs::read_to_string(&path)?;
        let parse = |text: &str| {
            Document::parse(
                path.clone(),
                text.into(),
                &path.to_string_lossy(),
                &self.library,
            )
        };
        let document = parse(&existing)?;
        let body = format!(
            "{{ @routine ${address:X} {} }}\n{}\n{{ @end ${address:X} }}",
            declaration.name,
            text.trim_end()
        );
        let updated =
            if let Some(previous) = document.bodies()?.iter().find(|b| b.address == address) {
                ensure!(
                    replace,
                    "{} already has a body; use --replace",
                    declaration.name
                );
                ensure!(
                    previous.parent.is_none(),
                    "Replace nested routines through their parent"
                );
                format!(
                    "{}{}{}",
                    &existing[..previous.start],
                    body,
                    &existing[previous.end..]
                )
            } else {
                let (_, end) = document.implementation()?;
                format!(
                    "{}\n\n{body}\n\n{}",
                    existing[..end].trim_end(),
                    &existing[end..]
                )
            };
        parse(&updated)?.bodies()?;
        std::fs::write(&path, updated)?;
        Ok(path)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn x87_stack_operands_do_not_import_pascal_symbols() {
        let document = Document::parse(
            "Probe.pas".into(),
            "unit Probe; interface procedure F; { @addr $401000 } \
             implementation procedure F; \
             asm fld Value; fmul st(1), st(0); call Helper; end; end."
                .into(),
            "Probe.pas",
            &crate::project::library::Library::default(),
        )
        .unwrap();
        let names: BTreeSet<_> = document
            .facts(true)
            .unwrap()
            .scoped
            .into_values()
            .flatten()
            .collect();
        assert!(!names.contains("st"));
        assert!(names.contains("value"));
        assert!(names.contains("helper"));
    }
}
