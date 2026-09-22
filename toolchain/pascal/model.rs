//! Source tree and declaration interchange schema shared with the Python adapters.
use super::lexer::Token;
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Decl {
    pub name: String,
    pub kind: String,
    pub source: String,
    pub meta: Map<String, Value>,
    pub data: Value,
    pub start: usize,
    pub end: usize,
    pub closing: Option<usize>,
    pub type_span: Option<(usize, usize)>,
}

impl Decl {
    pub fn is_inline_helper(&self) -> bool {
        self.kind == "routine"
            && !self.meta.contains_key("addr")
            && self.data["owner"].is_null()
            && self.data.get("external").is_none()
            && matches!(
                self.data["routine_kind"].as_str(),
                Some("function" | "procedure")
            )
            && self.data["directives"]
                .as_array()
                .is_some_and(|values| values.iter().any(|v| v == "inline"))
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct Node {
    pub kind: String,
    pub first: Token,
    pub last: Token,
    pub children: Vec<Node>,
    pub declaration: Option<Decl>,
    pub value: Option<String>,
}

impl Node {
    pub fn visit(&self, visitor: &mut impl FnMut(&Node)) {
        visitor(self);
        for child in &self.children {
            child.visit(visitor);
        }
    }
}
