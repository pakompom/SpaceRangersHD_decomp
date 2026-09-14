//! Pascal source handling. Source spans are UTF-8 byte offsets throughout Rust.
pub mod annotations;
mod declarations;
pub mod lexer;
pub mod model;
pub mod parser;
pub mod render;
mod statements;

pub mod types;
