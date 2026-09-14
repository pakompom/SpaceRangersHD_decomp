//! A fresh source snapshot for one invocation, with stable unit discovery order.
use crate::{pascal::model::Node, pascal::types::Compiler, project::library::Library};
use anyhow::{Context, Result, ensure};
use serde_json::Value;
use std::{
    collections::{BTreeMap, BTreeSet},
    fs,
    path::{Path, PathBuf},
};

pub struct Document {
    pub path: PathBuf,
    pub text: String,
    pub tree: Node,
    pub(crate) owned_bodies: Vec<source::Body>,
    pub(crate) source_facts: source::Facts,
}
pub struct Project {
    pub root: PathBuf,
    pub settings: Value,
    pub documents: Vec<Document>,
    pub program: Option<Document>,
    pub library: Library,
    pub compiler: Compiler,
    pub(crate) routines_by_address: BTreeMap<u32, Vec<usize>>,
    pub(crate) routines_by_name: BTreeMap<String, Vec<usize>>,
}

pub fn pascal_paths(root: &Path) -> Result<Vec<PathBuf>> {
    fn walk(root: &Path, paths: &mut Vec<PathBuf>) -> Result<()> {
        for entry in fs::read_dir(root)? {
            let path = entry?.path();
            if path.is_dir() {
                walk(&path, paths)?;
            } else if path.extension().is_some_and(|e| e == "pas") {
                paths.push(path);
            }
        }
        Ok(())
    }
    let mut paths = Vec::new();
    walk(root, &mut paths)?;
    paths.sort_by(|a, b| a.file_name().cmp(&b.file_name()));
    let mut names = BTreeSet::new();
    for path in &paths {
        ensure!(
            names.insert(path.file_stem().unwrap().to_string_lossy().to_lowercase()),
            "Duplicate Pascal unit {}",
            path.display()
        );
    }
    Ok(paths)
}
impl Project {
    pub fn open(root: &Path) -> Result<Self> {
        Self::with_source(root, None)
    }
    pub fn with_source(root: &Path, source: Option<&Path>) -> Result<Self> {
        let root = root.canonicalize()?;
        let config: toml::Value = toml::from_str(&fs::read_to_string(root.join("project.toml"))?)?;
        let mut settings = serde_json::to_value(config)?;
        if let Some(source) = source {
            settings["project"]["source"] = serde_json::json!(source.canonicalize()?);
        }
        let directory = root.join(
            settings["project"]["source"]
                .as_str()
                .context("project source directory missing")?,
        );
        let library = Library::open(&root.join("reference/library_matches.json"))?;
        let mut declarations = Vec::new();
        let mut documents = Vec::new();
        for path in pascal_paths(&directory)? {
            let text = fs::read_to_string(&path)?
                .replace("\r\n", "\n")
                .replace('\r', "\n");
            let source = directory.file_name().unwrap().to_string_lossy().to_string()
                + "/"
                + &path.strip_prefix(&directory)?.to_string_lossy();
            let document = Document::parse(path, text, &source, &library)?;
            declarations.extend(
                document
                    .tree
                    .children
                    .iter()
                    .filter_map(|n| n.declaration.clone()),
            );
            declarations.extend(
                document
                    .tree
                    .children
                    .iter()
                    .filter(|n| n.kind == "implementation")
                    .flat_map(|n| &n.children)
                    .filter_map(|n| n.declaration.clone())
                    .filter(|d| d.kind == "global" && d.meta.contains_key("addr")),
            );
            declarations.extend(document.nested_declarations());
            documents.push(document);
        }
        ensure!(
            !documents.is_empty(),
            "no .pas headers in {}",
            directory.display()
        );
        let path = directory.join("Rangers.dpr");
        let program = if path.exists() {
            let text = fs::read_to_string(&path)?
                .replace("\r\n", "\n")
                .replace('\r', "\n");
            let source = format!(
                "{}/Rangers.dpr",
                directory.file_name().unwrap().to_string_lossy()
            );
            if crate::pascal::lexer::scan(&text, &source)?.iter().any(|t| {
                t.kind == crate::pascal::lexer::Kind::Comment
                    && t.value.split_whitespace().next() == Some("@routine")
            }) {
                let document = Document::parse(path, text, &source, &library)?;
                let tree = &document.tree;
                ensure!(
                    tree.kind == "program",
                    "An owned executable entry requires a program, not a library"
                );
                declarations.extend(
                    tree.children
                        .iter()
                        .filter_map(|n| n.declaration.clone())
                        .filter(|d|
                    // Program method bodies share the declarations already
                    // collected from their classes, just like unit methods.
                    d.kind != "routine" || d.data["owner"].is_null()),
                );
                declarations.extend(document.nested_declarations());
                Some(document)
            } else {
                None
            }
        } else {
            None
        };
        let compiler = Compiler::new(declarations)?;
        let mut routines_by_address = BTreeMap::<u32, Vec<usize>>::new();
        let mut routines_by_name = BTreeMap::<String, Vec<usize>>::new();
        for (index, d) in compiler.decls.iter().enumerate() {
            if d.kind == "routine"
                && let Some(a) = d.meta.get("addr").and_then(Value::as_u64)
            {
                routines_by_address.entry(a as u32).or_default().push(index);
                routines_by_name
                    .entry(d.name.to_lowercase())
                    .or_default()
                    .push(index);
            }
        }
        Ok(Self {
            routines_by_address,
            routines_by_name,
            root,
            settings,
            documents,
            program,
            library,
            compiler,
        })
    }
    pub fn path(&self, name: &str) -> Result<PathBuf> {
        Ok(self.root.join(
            self.settings["project"][name]
                .as_str()
                .with_context(|| format!("missing project path {name}"))?,
        ))
    }
}

pub mod library;
pub mod source;
