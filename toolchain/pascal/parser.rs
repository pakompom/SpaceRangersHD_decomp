//! Delphi declaration and statement grammar over lossless source tokens.
use super::{
    annotations,
    lexer::{self, Kind, Token},
    model::{Decl, Node},
};
use crate::project::library::Library;
use anyhow::{Result, bail, ensure};
use serde_json::{Map, Value, json};
use std::collections::{BTreeMap, BTreeSet};

pub struct Parser<'a> {
    pub(super) text: &'a str,
    pub(super) source: &'a str,
    pub(super) annotated: bool,
    pub(super) native_annotations: bool,
    pub(super) library: Option<&'a Library>,
    pub(super) tokens: Vec<Token>,
    pub(super) i: usize,
    raw: Vec<Token>,
    raw_i: usize,
    pub(super) comments: Vec<Token>,
    pub(super) used_comments: BTreeSet<usize>,
    pub(super) constants: BTreeMap<String, Value>,
    pub(super) declared: BTreeMap<String, Vec<Decl>>,
    active: bool,
    stack: Vec<(bool, bool)>,
    defines: BTreeSet<String>,
    preprocess: bool,
}

impl<'a> Parser<'a> {
    /// Transfer the original tokens to source-fact extraction after parsing.
    pub fn into_tokens(self) -> Vec<Token> {
        self.raw
    }

    pub fn new(
        text: &'a str,
        source: &'a str,
        annotated: bool,
        library: Option<&'a Library>,
    ) -> Result<Self> {
        Ok(Self {
            text,
            source,
            annotated,
            native_annotations: annotated,
            library,
            tokens: Vec::new(),
            i: 0,
            raw: lexer::scan(text, source)?,
            raw_i: 0,
            comments: Vec::new(),
            used_comments: BTreeSet::new(),
            constants: BTreeMap::new(),
            declared: BTreeMap::new(),
            active: true,
            stack: Vec::new(),
            defines: [
                "MSWINDOWS",
                "WIN32",
                "CPU386",
                "VER180",
                "VER185",
                "CONDITIONALEXPRESSIONS",
            ]
            .map(String::from)
            .into(),
            preprocess: true,
        })
    }
    fn fill(&mut self, index: usize) -> Result<()> {
        while self.tokens.len() <= index {
            let token = self
                .raw
                .get(self.raw_i)
                .ok_or_else(|| anyhow::anyhow!("{}: unexpected end of file", self.source))?
                .clone();
            self.raw_i += 1;
            if token.kind == Kind::Directive {
                if self.preprocess {
                    self.directive(&token)?;
                }
                continue;
            }
            if token.kind == Kind::Eof && !self.stack.is_empty() {
                bail!(
                    "{}: unclosed conditional compilation directive",
                    self.source
                )
            }
            if !self.active && token.kind != Kind::Eof {
                continue;
            }
            if token.kind == Kind::Comment {
                self.comments.push(token)
            } else {
                self.tokens.push(token)
            }
        }
        Ok(())
    }
    pub(super) fn current(&mut self) -> Result<Token> {
        self.fill(self.i)?;
        Ok(self.tokens[self.i].clone())
    }
    pub(super) fn ahead(&mut self, n: usize) -> Result<Token> {
        self.fill(self.i + n)?;
        Ok(self.tokens[self.i + n].clone())
    }
    pub(super) fn last(&self) -> Token {
        self.tokens[self.i - 1].clone()
    }
    pub(super) fn value(&mut self) -> Result<String> {
        Ok(self.current()?.value.to_lowercase())
    }
    pub(super) fn peek(&mut self, value: &str) -> Result<bool> {
        let t = self.current()?;
        Ok(
            matches!(t.kind, Kind::Identifier | Kind::Keyword | Kind::Symbol)
                && t.value.eq_ignore_ascii_case(value),
        )
    }
    pub(super) fn accept(&mut self, value: &str) -> Result<bool> {
        if self.peek(value)? {
            self.i += 1;
            Ok(true)
        } else {
            Ok(false)
        }
    }
    pub(super) fn take(&mut self) -> Result<Token> {
        let t = self.current()?;
        ensure!(
            t.kind != Kind::Eof,
            "{}:{}:{}: unexpected end of file",
            self.source,
            t.line,
            t.column
        );
        self.i += 1;
        Ok(t)
    }
    pub(super) fn expect(&mut self, value: &str) -> Result<Token> {
        let t = self.current()?;
        ensure!(
            self.peek(value)?,
            "{}:{}:{}: expected {value:?}, got {:?}",
            self.source,
            t.line,
            t.column,
            t.value
        );
        self.take()
    }
    pub(super) fn ident(&mut self) -> Result<String> {
        let t = self.current()?;
        ensure!(
            t.kind == Kind::Identifier,
            "{}:{}:{}: expected identifier, got {:?}",
            self.source,
            t.line,
            t.column,
            t.value
        );
        Ok(self.take()?.value)
    }
    pub(super) fn qualified(&mut self) -> Result<String> {
        let mut name = self.ident()?;
        while self.accept(".")? {
            name.push('.');
            name.push_str(&self.ident()?)
        }
        Ok(name)
    }
    pub(super) fn integer(&mut self) -> Result<i64> {
        let sign = if self.accept("-")? {
            -1
        } else {
            self.accept("+")?;
            1
        };
        let t = self.take()?;
        ensure!(t.kind == Kind::Number, "expected integer literal");
        Ok(sign * annotations::integer(&t.value)?)
    }
    pub(super) fn node(
        &self,
        kind: &str,
        first: Token,
        children: Vec<Node>,
        declaration: Option<Decl>,
        value: Option<String>,
    ) -> Node {
        Node {
            kind: kind.into(),
            first,
            last: self.last(),
            children,
            declaration,
            value,
        }
    }
    pub(super) fn decl(
        &self,
        start: &Token,
        name: String,
        kind: &str,
        meta: Map<String, Value>,
        data: Value,
    ) -> Decl {
        Decl {
            name,
            kind: kind.into(),
            source: format!("{}:{}", self.source, start.line),
            meta,
            data,
            start: start.start,
            end: self.last().end,
            closing: None,
            type_span: None,
        }
    }
    pub(super) fn meta(
        &mut self,
        start: &Token,
        allowed: &[&str],
        routine: bool,
    ) -> Result<Map<String, Value>> {
        if !self.annotated {
            return Ok(Map::new());
        }
        let end = self.last();
        let following = self.current()?.start;
        let mut result = Map::new();
        for comment in &self.comments {
            if comment.start < start.start
                || comment.start >= following
                || self.used_comments.contains(&comment.start)
            {
                continue;
            }
            if comment.start >= end.end && comment.line != end.line {
                continue;
            }
            let meta = annotations::parse(comment, self.source, routine)?;
            annotations::validate(&meta, allowed)?;
            for (key, value) in meta {
                ensure!(!result.contains_key(&key), "duplicate annotation @{key}");
                result.insert(key, value);
            }
            self.used_comments.insert(comment.start);
        }
        Ok(result)
    }
    pub(super) fn hints(&mut self) -> Result<()> {
        while matches!(
            self.value()?.as_str(),
            "deprecated" | "platform" | "library" | "experimental"
        ) {
            self.take()?;
            if self.current()?.kind == Kind::String {
                self.take()?;
            }
        }
        Ok(())
    }
    fn directive(&mut self, token: &Token) -> Result<()> {
        let parts = token.value[1..].split_once(char::is_whitespace);
        let (command, value) = parts.unwrap_or((&token.value[1..], ""));
        let command = command.to_uppercase();
        let value = value.trim();
        match command.as_str() {
            "IFDEF" | "IFNDEF" | "IF" | "IFOPT" => {
                let condition = if !self.active {
                    false
                } else {
                    match command.as_str() {
                        "IF" => self.condition(value)?,
                        "IFOPT" => matches!(
                            value.to_uppercase().as_str(),
                            "H+" | "J+" | "A+" | "O-" | "R-" | "Q-" | "B-"
                        ),
                        _ => self.defines.contains(&value.to_uppercase()) == (command == "IFDEF"),
                    }
                };
                self.stack.push((self.active, condition));
                self.active = self.active && condition;
            }
            "ELSE" | "ELSEIF" | "ENDIF" | "IFEND" => {
                let &(parent, taken) = self.stack.last().ok_or_else(|| {
                    anyhow::anyhow!("{}:{}: unmatched ${command}", self.source, token.line)
                })?;
                if matches!(command.as_str(), "ENDIF" | "IFEND") {
                    self.active = parent;
                    self.stack.pop();
                } else {
                    let condition =
                        parent && !taken && (command == "ELSE" || self.condition(value)?);
                    self.active = parent && condition;
                    *self.stack.last_mut().unwrap() = (parent, taken || condition);
                }
            }
            "DEFINE" if self.active => {
                self.defines.insert(value.to_uppercase());
            }
            "UNDEF" if self.active => {
                self.defines.remove(&value.to_uppercase());
            }
            _ => (),
        }
        Ok(())
    }
    fn condition(&self, text: &str) -> Result<bool> {
        let mut parser = Parser::new(text, self.source, false, None)?;
        parser.preprocess = false;
        let expression = parser.expression(0)?;
        ensure!(
            parser.current()?.kind == Kind::Eof,
            "unexpected conditional expression token"
        );
        Ok(truth(&constant(
            &expression,
            &self.constants,
            &self.defines,
        )?))
    }
    pub(super) fn expression_list(&mut self, closing: &str) -> Result<Vec<Node>> {
        let mut result = Vec::new();
        if !self.peek(closing)? {
            result.push(self.expression(0)?);
            while self.accept(",")? || self.accept(":")? {
                result.push(self.expression(0)?);
            }
        }
        self.expect(closing)?;
        Ok(result)
    }
    pub fn expression(&mut self, precedence: u8) -> Result<Node> {
        let start = self.current()?;
        let mut left = if matches!(start.kind, Kind::Symbol | Kind::Keyword)
            && matches!(
                start.value.to_lowercase().as_str(),
                "+" | "-" | "@" | "not" | "inherited"
            ) {
            let operator = self.take()?.value.to_lowercase();
            let children = if operator == "inherited"
                && matches!(self.value()?.as_str(), ";" | "end" | "else" | "until")
            {
                vec![]
            } else {
                vec![self.expression(5)?]
            };
            self.node("unary", start.clone(), children, None, Some(operator))
        } else if self.accept("(")? {
            let mut children = Vec::new();
            if !self.peek(")")? {
                children.push(self.expression(0)?);
                while matches!(self.value()?.as_str(), "," | ";" | ":") {
                    let separator = self.take()?.value;
                    if self.peek(")")? && separator == ";" {
                        break;
                    }
                    children.push(self.expression(0)?);
                }
            }
            self.expect(")")?;
            self.node("parenthesized", start.clone(), children, None, None)
        } else if self.accept("[")? {
            let children = self.expression_list("]")?;
            self.node("set", start.clone(), children, None, None)
        } else if self.accept("#")? {
            let child = self.expression(6)?;
            self.node("character", start.clone(), vec![child], None, None)
        } else if matches!(start.kind, Kind::Identifier | Kind::Number | Kind::String)
            || self.peek("nil")?
        {
            let value = self.take()?.value;
            self.node(
                if start.kind == Kind::Identifier {
                    "name"
                } else {
                    "literal"
                },
                start.clone(),
                vec![],
                None,
                Some(value),
            )
        } else {
            bail!(
                "{}:{}:{}: expected expression, got {:?}",
                self.source,
                start.line,
                start.column,
                start.value
            )
        };
        loop {
            let token = self.current()?;
            let operator = if matches!(token.kind, Kind::Keyword | Kind::Symbol) {
                token.value.to_lowercase()
            } else {
                String::new()
            };
            let level = match operator.as_str() {
                ".." => 1,
                "=" | "<>" | "<" | ">" | "<=" | ">=" | "in" | "is" => 2,
                "+" | "-" | "or" | "xor" => 3,
                "*" | "/" | "div" | "mod" | "and" | "shl" | "shr" | "as" => 4,
                _ => 0,
            };
            if matches!(operator.as_str(), "." | "^" | "[" | "(") && precedence <= 6 {
                self.take()?;
                let mut children = vec![left];
                if operator == "." {
                    let token = self.current()?;
                    let name = self.ident()?;
                    children.push(self.node("name", token, vec![], None, Some(name)));
                } else if operator == "[" || operator == "(" {
                    children.extend(self.expression_list(if operator == "[" {
                        "]"
                    } else {
                        ")"
                    })?);
                }
                left = self.node(
                    match operator.as_str() {
                        "." => "member",
                        "^" => "dereference",
                        "[" => "index",
                        _ => "call",
                    },
                    start.clone(),
                    children,
                    None,
                    None,
                );
            } else if level > precedence {
                self.take()?;
                let right = self.expression(level)?;
                left = self.node(
                    "binary",
                    start.clone(),
                    vec![left, right],
                    None,
                    Some(operator),
                );
            } else if token.kind == Kind::String || self.peek("#")? {
                let right = self.expression(6)?;
                left = self.node("string", start.clone(), vec![left, right], None, None);
            } else {
                return Ok(left);
            }
        }
    }
}

fn truth(v: &Value) -> bool {
    match v {
        Value::Bool(b) => *b,
        Value::Number(n) => n.as_f64().unwrap_or(0.) != 0.,
        Value::String(s) => !s.is_empty(),
        Value::Null => false,
        _ => true,
    }
}

fn int(v: &Value) -> Result<i64> {
    if let Some(v) = v.as_i64() {
        Ok(v)
    } else if let Some(v) = v.as_bool() {
        Ok(i64::from(v))
    } else {
        bail!("integer constant expected")
    }
}
fn num(v: &Value) -> Result<f64> {
    v.as_f64()
        .ok_or_else(|| anyhow::anyhow!("numeric constant expected"))
}
pub(super) fn constant(
    node: &Node,
    constants: &BTreeMap<String, Value>,
    defines: &BTreeSet<String>,
) -> Result<Value> {
    let value = node.value.as_deref().unwrap_or("");
    match node.kind.as_str() {
        "parenthesized" if node.children.len() == 1 => {
            constant(&node.children[0], constants, defines)
        }
        "unary" => {
            let v = constant(&node.children[0], constants, defines)?;
            Ok(match value {
                "not" if v.is_boolean() => json!(!truth(&v)),
                "not" => json!(!int(&v)?),
                "+" => v,
                "-" if v.is_i64() => json!(-int(&v)?),
                "-" => json!(-num(&v)?),
                _ => bail!("unsupported unary constant"),
            })
        }
        "binary" => {
            let a = constant(&node.children[0], constants, defines)?;
            let b = constant(&node.children[1], constants, defines)?;
            Ok(match value {
                "=" => json!(a == b || a.is_number() && b.is_number() && num(&a)? == num(&b)?),
                "<>" => json!(!(a == b || a.is_number() && b.is_number() && num(&a)? == num(&b)?)),
                ">" => json!(num(&a)? > num(&b)?),
                "<" => json!(num(&a)? < num(&b)?),
                ">=" => json!(num(&a)? >= num(&b)?),
                "<=" => json!(num(&a)? <= num(&b)?),
                "and" if a.is_boolean() && b.is_boolean() => json!(truth(&a) && truth(&b)),
                "or" if a.is_boolean() && b.is_boolean() => json!(truth(&a) || truth(&b)),
                "xor" if a.is_boolean() && b.is_boolean() => json!(truth(&a) ^ truth(&b)),
                "and" => json!(int(&a)? & int(&b)?),
                "or" => json!(int(&a)? | int(&b)?),
                "xor" => json!(int(&a)? ^ int(&b)?),
                "shl" => json!(
                    int(&a)?
                        .checked_shl(int(&b)? as u32)
                        .ok_or_else(|| anyhow::anyhow!("constant shift overflow"))?
                ),
                "shr" => json!(
                    int(&a)?
                        .checked_shr(int(&b)? as u32)
                        .ok_or_else(|| anyhow::anyhow!("constant shift overflow"))?
                ),
                "div" => json!(
                    int(&a)?
                        .checked_div(int(&b)?)
                        .ok_or_else(|| anyhow::anyhow!("invalid constant division"))?
                ),
                "mod" => json!(
                    int(&a)?
                        .checked_rem(int(&b)?)
                        .ok_or_else(|| anyhow::anyhow!("invalid constant division"))?
                ),
                "+" if a.is_string() && b.is_string() => {
                    json!(format!("{}{}", a.as_str().unwrap(), b.as_str().unwrap()))
                }
                "+" if a.is_i64() && b.is_i64() => json!(
                    int(&a)?
                        .checked_add(int(&b)?)
                        .ok_or_else(|| anyhow::anyhow!("constant overflow"))?
                ),
                "-" if a.is_i64() && b.is_i64() => json!(
                    int(&a)?
                        .checked_sub(int(&b)?)
                        .ok_or_else(|| anyhow::anyhow!("constant overflow"))?
                ),
                "*" if a.is_i64() && b.is_i64() => json!(
                    int(&a)?
                        .checked_mul(int(&b)?)
                        .ok_or_else(|| anyhow::anyhow!("constant overflow"))?
                ),
                "+" => json!(num(&a)? + num(&b)?),
                "-" => json!(num(&a)? - num(&b)?),
                "*" => json!(num(&a)? * num(&b)?),
                "/" => {
                    ensure!(num(&b)? != 0., "division by zero");
                    json!(num(&a)? / num(&b)?)
                }
                _ => bail!("unsupported binary constant"),
            })
        }
        "call"
            if node.children.len() == 2
                && node.children[0]
                    .value
                    .as_deref()
                    .is_some_and(|v| v.eq_ignore_ascii_case("defined")) =>
        {
            Ok(json!(
                defines.contains(
                    &node.children[1]
                        .value
                        .as_deref()
                        .unwrap_or("")
                        .to_uppercase()
                )
            ))
        }
        "name" => Ok(match value.to_lowercase().as_str() {
            "true" => json!(true),
            "false" => json!(false),
            "compilerversion" => json!(18.5),
            "rtlversion" => json!(18),
            name => constants
                .get(name)
                .cloned()
                .ok_or_else(|| anyhow::anyhow!("unknown constant {name}"))?,
        }),
        "literal" => {
            if node.first.kind == Kind::String {
                Ok(json!(value))
            } else {
                Ok(if let Ok(i) = annotations::integer(value) {
                    json!(i)
                } else {
                    json!(value.parse::<f64>()?)
                })
            }
        }
        _ => bail!("constant expression cannot be evaluated: {value}"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn private_global_annotations_do_not_annotate_stack_locals() -> Result<()> {
        let text = "unit X; interface implementation\nvar Hidden: Integer = 0; // @addr $2000\nUnmapped: Integer;\nprocedure Work; var Local: Integer; // @addr $3000\nbegin Local := Hidden; end; end.";
        let tree = Parser::new(text, "X.pas", true, None)?.document(false)?;
        let implementation = tree
            .children
            .iter()
            .find(|n| n.kind == "implementation")
            .unwrap();
        let hidden = implementation.children[0].declaration.as_ref().unwrap();
        assert_eq!(hidden.meta["addr"], 0x2000);
        assert_eq!(hidden.data["implementation"], true);
        let unmapped = implementation.children[1].declaration.as_ref().unwrap();
        assert!(unmapped.meta.is_empty());
        let routine = &implementation.children[2];
        let local = routine
            .children
            .iter()
            .find(|n| n.kind == "global")
            .unwrap();
        assert!(local.declaration.as_ref().unwrap().meta.is_empty());
        Ok(())
    }

    #[test]
    fn conditionals_use_preceding_constants() -> Result<()> {
        let mut parser = Parser::new(
            "unit Example; interface const Width = 4; {$IF Width = 4} type TValue = Integer; {$ELSE} unused_identifier {$IFEND} implementation end.",
            "Example.pas",
            true,
            None,
        )?;
        assert!(parser.document(false).is_ok());
        Ok(())
    }
    #[test]
    fn annotation_errors_and_method_contracts() {
        for source in [
            "unit X; interface var Value: Integer; implementation end.",
            "unit X; interface function Work: Integer; implementation end.",
            "unit X; interface function Work: Integer; inline; // @calls \"0x1000\"\n implementation end.",
            "unit X; interface type T = class // @size 4\n function Work: Integer; inline; end; implementation end.",
            "unit X; interface type T = record Value: Integer; // @offset 0 @offset 4\n end; // @size 4\n implementation end.",
            "unit X; interface procedure Work; // @addr $1000 @slot 4\n implementation end.",
            "unit X; interface procedure Work; // @addr $1000 @mystery 1\n implementation end.",
        ] {
            let result =
                Parser::new(source, "X.pas", true, None).and_then(|mut p| p.document(false));
            assert!(result.is_err(), "{source}");
        }
    }
}
