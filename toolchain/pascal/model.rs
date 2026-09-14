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
