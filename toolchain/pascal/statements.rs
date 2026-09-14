//! Statement trees and unit/program sections, including nested Pascal routines.
use super::{
    annotations,
    lexer::Kind,
    model::Node,
    parser::{Parser, constant},
};
use anyhow::{Result, bail, ensure};
use serde_json::{Value, json};

impl Parser<'_> {
    fn statements(&mut self, ending: &[&str]) -> Result<Vec<Node>> {
        let mut result = Vec::new();
        while !ending.contains(&self.value()?.as_str()) {
            result.push(self.statement()?);
            if !self.accept(";")? {
                ensure!(
                    ending.contains(&self.value()?.as_str()),
                    "expected ';' between statements"
                );
                break;
            }
        }
        Ok(result)
    }
    pub(super) fn statement(&mut self) -> Result<Node> {
        let start = self.current()?;
        if self.accept("begin")? {
            let children = self.statements(&["end"])?;
            self.expect("end")?;
            return Ok(self.node("block", start, children, None, None));
        }
        if self.accept("asm")? {
            while !self.peek("end")? {
                self.take()?;
            }
            self.expect("end")?;
            return Ok(self.node("asm", start, vec![], None, None));
        }
        if self.accept("if")? {
            let mut children = vec![self.expression(0)?];
            self.expect("then")?;
            children.push(self.statement()?);
            if self.accept("else")? {
                children.push(self.statement()?);
            }
            return Ok(self.node("if", start, children, None, None));
        }
        if self.accept("while")? || self.accept("with")? {
            let kind = start.value.to_lowercase();
            let mut children = vec![self.expression(0)?];
            while kind == "with" && self.accept(",")? {
                children.push(self.expression(0)?);
            }
            self.expect("do")?;
            children.push(self.statement()?);
            return Ok(self.node(&kind, start, children, None, None));
        }
        if self.accept("for")? {
            let mut children = vec![self.expression(2)?];
            if self.accept("in")? {
                children.push(self.expression(0)?);
                self.expect("do")?;
                children.push(self.statement()?);
                return Ok(self.node("for_in", start, children, None, None));
            }
            self.expect(":=")?;
            children.push(self.expression(0)?);
            ensure!(
                self.accept("to")? || self.accept("downto")?,
                "expected to or downto"
            );
            let direction = self.last().value.to_lowercase();
            children.push(self.expression(0)?);
            self.expect("do")?;
            children.push(self.statement()?);
            return Ok(self.node("for", start, children, None, Some(direction)));
        }
        if self.accept("repeat")? {
            let mut children = self.statements(&["until"])?;
            self.expect("until")?;
            children.push(self.expression(0)?);
            return Ok(self.node("repeat", start, children, None, None));
        }
        if self.accept("case")? {
            let mut children = vec![self.expression(0)?];
            self.expect("of")?;
            while !matches!(self.value()?.as_str(), "else" | "end") {
                let arm = self.current()?;
                let mut labels = vec![self.expression(0)?];
                while self.accept(",")? {
                    labels.push(self.expression(0)?);
                }
                self.expect(":")?;
                labels.push(self.statement()?);
                children.push(self.node("case_arm", arm, labels, None, None));
                if !self.accept(";")? {
                    break;
                }
            }
            if self.accept("else")? {
                children.extend(self.statements(&["end"])?);
            }
            self.expect("end")?;
            return Ok(self.node("case", start, children, None, None));
        }
        if self.accept("try")? {
            let mut children = self.statements(&["except", "finally"])?;
            let handler = self.current()?;
            ensure!(
                self.accept("except")? || self.accept("finally")?,
                "expected except or finally"
            );
            let mut handlers = Vec::new();
            if self.peek("on")? {
                while self.accept("on")? {
                    let on = self.last();
                    let mut name = self.ident()?;
                    if self.accept(":")? {
                        name.push(':');
                        name.push_str(&self.qualified()?);
                    } else {
                        while self.accept(".")? {
                            name.push('.');
                            name.push_str(&self.ident()?);
                        }
                    }
                    self.expect("do")?;
                    let body = self.statement()?;
                    handlers.push(self.node("on", on, vec![body], None, Some(name)));
                    if !self.accept(";")? {
                        break;
                    }
                }
                if self.accept("else")? {
                    handlers.extend(self.statements(&["end"])?);
                }
            } else {
                handlers = self.statements(&["end"])?;
            }
            let kind = handler.value.to_lowercase();
            children.push(self.node(&kind, handler, handlers, None, None));
            self.expect("end")?;
            return Ok(self.node("try", start, children, None, None));
        }
        if self.accept("raise")? {
            let mut children = Vec::new();
            if !matches!(
                self.value()?.as_str(),
                ";" | "end" | "else" | "except" | "finally"
            ) {
                children.push(self.expression(0)?);
                if self.accept("at")? {
                    children.push(self.expression(0)?);
                }
            }
            return Ok(self.node("raise", start, children, None, None));
        }
        if self.accept("goto")? {
            self.take()?;
            return Ok(self.node("goto", start, vec![], None, None));
        }
        if matches!(self.value()?.as_str(), ";" | "end" | "else" | "until") {
            return Ok(Node {
                kind: "empty".into(),
                first: start.clone(),
                last: start,
                children: vec![],
                declaration: None,
                value: None,
            });
        }
        let expression = self.expression(0)?;
        if self.accept(":=")? {
            let right = self.expression(0)?;
            return Ok(self.node("assignment", start, vec![expression, right], None, None));
        }
        if self.accept(":")? {
            let next = self.statement()?;
            return Ok(self.node("label", start, vec![expression, next], None, None));
        }
        Ok(self.node("statement", start, vec![expression], None, None))
    }
    fn source_declarations(
        &mut self,
        ending: &[&str],
        bodies: bool,
        depth: usize,
    ) -> Result<Vec<Node>> {
        let mut nodes = Vec::new();
        let mut section = String::new();
        while self.current()?.kind != Kind::Eof
            && !(self.current()?.kind == Kind::Keyword && ending.contains(&self.value()?.as_str()))
        {
            let start = self.current()?;
            let kind = start.value.to_lowercase();
            if matches!(
                kind.as_str(),
                "type" | "var" | "threadvar" | "const" | "resourcestring" | "label"
            ) {
                section = self.take()?.value.to_lowercase();
            } else if matches!(kind.as_str(), "uses" | "exports") {
                self.take()?;
                let children = self.expression_list(";")?;
                nodes.push(self.node(&kind, start, children, None, None));
                section.clear();
            } else if matches!(
                kind.as_str(),
                "procedure" | "function" | "constructor" | "destructor" | "class"
            ) {
                let mut declaration = self.routine(None, bodies || !self.annotated, false)?;
                let has_body = bodies
                    && !declaration.data["directives"]
                        .as_array()
                        .unwrap()
                        .iter()
                        .any(|v| matches!(v.as_str(), Some("forward" | "external" | "abstract")));
                if has_body {
                    declaration.data["nested"] = json!(depth > 0);
                }
                let heading = self.node(
                    "heading",
                    start.clone(),
                    vec![],
                    Some(declaration.clone()),
                    None,
                );
                let mut children = vec![heading];
                if has_body {
                    let annotated = self.annotated;
                    self.annotated = false;
                    children.extend(self.source_declarations(
                        &["begin", "asm"],
                        true,
                        depth + 1,
                    )?);
                    children.push(self.statement()?);
                    self.expect(";")?;
                    self.annotated = annotated;
                }
                nodes.push(self.node("routine", start, children, Some(declaration), None));
                section.clear();
            } else if section == "type" {
                let declaration = self.type_decl()?;
                nodes.push(self.node("type", start, vec![], Some(declaration), None));
            } else if matches!(
                section.as_str(),
                "var" | "threadvar" | "const" | "resourcestring"
            ) {
                let mut names = vec![self.ident()?];
                while self.accept(",")? {
                    names.push(self.ident()?);
                }
                let typ = if self.accept(":")? {
                    self.type_expr(false)?
                } else {
                    Value::Null
                };
                self.hints()?;
                let initialized = self.accept("=")?;
                let children = if initialized || self.accept("absolute")? {
                    vec![self.expression(0)?]
                } else {
                    vec![]
                };
                if !children.is_empty()
                    && matches!(section.as_str(), "const" | "resourcestring")
                    && let Ok(value) = constant(&children[0], &self.constants, &Default::default())
                {
                    for name in &names {
                        self.constants.insert(name.to_lowercase(), value.clone());
                    }
                }
                self.hints()?;
                self.expect(";")?;
                for name in names {
                    let kind = if matches!(section.as_str(), "const" | "resourcestring") {
                        "constant"
                    } else {
                        "global"
                    };
                    let annotated = self.annotated;
                    if bodies && depth == 0 && kind == "global" {
                        self.annotated = self.native_annotations;
                    }
                    let meta =
                        self.meta(&start, &["addr", "indirect", "indexrefs", "note"], false)?;
                    self.annotated = annotated;
                    ensure!(
                        !self.annotated || kind != "global" || meta.contains_key("addr"),
                        "global {name} needs @addr"
                    );
                    let mut data = json!({"type":typ});
                    if bodies && depth == 0 && !annotated && meta.contains_key("addr") {
                        data["implementation"] = json!(true);
                    }
                    if initialized {
                        data["initializer"] =
                            json!(self.text[children[0].first.start..children[0].last.end]);
                    }
                    let declaration = self.decl(&start, name, kind, meta, data);
                    nodes.push(self.node(
                        kind,
                        start.clone(),
                        children.clone(),
                        Some(declaration),
                        None,
                    ));
                }
            } else if section == "label" {
                let children = self.expression_list(";")?;
                nodes.push(self.node("labels", start, children, None, None));
            } else {
                bail!(
                    "{}:{}:{}: expected type, var, or routine declaration, got {:?}",
                    self.source,
                    start.line,
                    start.column,
                    start.value
                )
            }
        }
        Ok(nodes)
    }
    pub fn document(&mut self, interface_only: bool) -> Result<Node> {
        let start = self.current()?;
        if start.kind == Kind::Keyword
            && matches!(self.value()?.as_str(), "unit" | "program" | "library")
        {
            let kind = self.take()?.value.to_lowercase();
            self.ident()?;
            self.expect(";")?;
            let mut children;
            if kind == "unit" {
                self.expect("interface")?;
                children = self.source_declarations(&["implementation"], false, 0)?;
                let boundary = self.current()?;
                self.expect("implementation")?;
                if self.annotated {
                    for comment in &self.comments {
                        if comment.start >= boundary.start {
                            break;
                        }
                        if !self.used_comments.contains(&comment.start) {
                            ensure!(
                                annotations::parse(comment, self.source, false)?.is_empty(),
                                "{}:{}: unattached annotation",
                                self.source,
                                comment.line
                            );
                        }
                    }
                }
                if interface_only {
                    return Ok(self.node(&kind, start, children, None, None));
                }
                let annotated = self.annotated;
                self.annotated = false;
                let mut implementation = self.source_declarations(
                    &["initialization", "finalization", "begin", "end"],
                    true,
                    0,
                )?;
                if self.peek("begin")? {
                    implementation.push(self.statement()?);
                } else {
                    for section in ["initialization", "finalization"] {
                        if self.accept(section)? {
                            let token = self.last();
                            let statements = self.statements(&["finalization", "end"])?;
                            implementation.push(self.node(section, token, statements, None, None));
                        }
                    }
                    self.expect("end")?;
                }
                let closing = self.last();
                self.expect(".")?;
                children.push(Node {
                    kind: "implementation".into(),
                    first: boundary,
                    last: closing,
                    children: implementation,
                    declaration: None,
                    value: None,
                });
                self.annotated = annotated;
            } else {
                children = self.source_declarations(&["begin"], true, 0)?;
                self.annotated = false;
                children.push(self.statement()?);
                self.expect(".")?;
            }
            ensure!(
                self.current()?.kind == Kind::Eof,
                "unexpected text after unit end"
            );
            return Ok(self.node(&kind, start, children, None, None));
        }
        if self.annotated {
            self.expect("unit")?;
        }
        self.annotated = false;
        let children = self.source_declarations(&[], true, 0)?;
        Ok(self.node("fragment", start, children, None, None))
    }
}
