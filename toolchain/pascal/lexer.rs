//! Lossless token spans, compiler directives and Delphi inline assembly.

use anyhow::{Result, bail};
use serde::Serialize;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Kind {
    Keyword,
    Identifier,
    Number,
    String,
    Symbol,
    Comment,
    Directive,
    Eof,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct Token {
    pub kind: Kind,
    pub value: String,
    pub line: usize,
    pub column: usize,
    pub start: usize,
    pub end: usize,
}

fn keyword(value: &str) -> bool {
    matches!(
        value,
        "unit"
            | "interface"
            | "implementation"
            | "uses"
            | "type"
            | "var"
            | "packed"
            | "record"
            | "class"
            | "public"
            | "private"
            | "protected"
            | "published"
            | "end"
            | "array"
            | "of"
            | "set"
            | "procedure"
            | "function"
            | "const"
            | "out"
            | "begin"
            | "constructor"
            | "destructor"
            | "is"
            | "as"
            | "asm"
            | "property"
            | "program"
            | "library"
            | "exports"
            | "label"
            | "threadvar"
            | "resourcestring"
            | "initialization"
            | "finalization"
            | "if"
            | "then"
            | "else"
            | "for"
            | "to"
            | "downto"
            | "do"
            | "while"
            | "repeat"
            | "until"
            | "case"
            | "try"
            | "except"
            | "finally"
            | "raise"
            | "with"
            | "goto"
            | "on"
            | "in"
            | "and"
            | "or"
            | "xor"
            | "not"
            | "div"
            | "mod"
            | "shl"
            | "shr"
            | "nil"
            | "object"
            | "inherited"
    )
}

pub fn scan(text: &str, source: &str) -> Result<Vec<Token>> {
    let mut tokens = Vec::new();
    let (mut pos, mut line, mut column, mut assembly) = (0, 1, 1, false);
    while pos < text.len() {
        let rest = &text[pos..];
        let ch = rest.chars().next().unwrap();
        let start = pos;
        let (kind, value, length) = if ch.is_whitespace() || ch == '\u{feff}' && pos == 0 {
            let length = rest
                .char_indices()
                .take_while(|(_, c)| c.is_whitespace() || *c == '\u{feff}' && pos == 0)
                .last()
                .map(|(p, c)| p + c.len_utf8())
                .unwrap();
            advance(&text[pos..pos + length], &mut line, &mut column);
            pos += length;
            continue;
        } else if rest.starts_with("//") {
            let length = rest.find(['\r', '\n']).unwrap_or(rest.len());
            (Kind::Comment, rest[2..length].to_owned(), length)
        } else if ch == '{' || rest.starts_with("(*") {
            let (open, close) = if ch == '{' { (1, "}") } else { (2, "*)") };
            let Some(end) = rest[open..].find(close).map(|i| i + open) else {
                bail!("{source}:{line}:{column}: unterminated comment; expected {close}")
            };
            (
                if rest[open..].starts_with('$') {
                    Kind::Directive
                } else {
                    Kind::Comment
                },
                rest[open..end].to_owned(),
                end + close.len(),
            )
        } else if ch == '\'' || assembly && ch == '"' {
            let quote = ch as u8;
            let mut end = 1;
            loop {
                if end == rest.len() || matches!(rest.as_bytes()[end], b'\r' | b'\n') {
                    bail!("{source}:{line}:{column}: unterminated Pascal string")
                }
                if rest.as_bytes()[end] == quote {
                    if rest.as_bytes().get(end + 1) == Some(&quote) {
                        end += 2;
                        continue;
                    }
                    break;
                }
                end += 1;
            }
            (
                Kind::String,
                rest[1..end].replace(&format!("{ch}{ch}"), &ch.to_string()),
                end + 1,
            )
        } else if assembly
            && rest.starts_with("@@")
            && rest
                .as_bytes()
                .get(2)
                .is_some_and(|c| c.is_ascii_alphanumeric() || *c == b'_')
        {
            let length = 2 + rest[2..]
                .bytes()
                .take_while(|c| c.is_ascii_alphanumeric() || *c == b'_')
                .count();
            (Kind::Identifier, rest[..length].to_owned(), length)
        } else if ch == '_' || ch.is_alphabetic() {
            let length = rest
                .char_indices()
                .take_while(|(_, c)| c.is_alphanumeric() || *c == '_')
                .last()
                .map(|(p, c)| p + c.len_utf8())
                .unwrap();
            let value = &rest[..length];
            (
                if keyword(&value.to_lowercase()) {
                    Kind::Keyword
                } else {
                    Kind::Identifier
                },
                value.to_owned(),
                length,
            )
        } else if ch == '$' || ch.is_ascii_digit() {
            let bytes = rest.as_bytes();
            let mut length;
            if ch == '$' || rest.starts_with("0x") || rest.starts_with("0X") {
                let prefix = if ch == '$' { 1 } else { 2 };
                length = prefix
                    + bytes[prefix..]
                        .iter()
                        .take_while(|c| c.is_ascii_hexdigit())
                        .count();
                if length == prefix {
                    bail!("{source}:{line}:{column}: expected hexadecimal digits")
                }
            } else {
                length = bytes.iter().take_while(|c| c.is_ascii_digit()).count();
                if bytes.get(length) == Some(&b'.') && bytes.get(length + 1) != Some(&b'.') {
                    length += 1;
                    length += bytes[length..]
                        .iter()
                        .take_while(|c| c.is_ascii_digit())
                        .count();
                }
                if matches!(bytes.get(length), Some(b'e' | b'E')) {
                    let mut end = length + 1;
                    if matches!(bytes.get(end), Some(b'+' | b'-')) {
                        end += 1;
                    }
                    let count = bytes[end..]
                        .iter()
                        .take_while(|c| c.is_ascii_digit())
                        .count();
                    if count != 0 {
                        length = end + count;
                    } else if !assembly {
                        bail!("{source}:{line}:{column}: expected exponent digits")
                    }
                }
                if assembly {
                    let end = bytes.iter().take_while(|c| c.is_ascii_hexdigit()).count();
                    if matches!(bytes.get(end), Some(b'h' | b'H')) {
                        length = end + 1;
                    }
                }
            }
            (Kind::Number, rest[..length].to_owned(), length)
        } else {
            let two = rest.as_bytes().get(..2);
            let length = if matches!(two, Some(b".." | b":=" | b"<=" | b">=" | b"<>")) {
                2
            } else if "^()[]:;=,.+*<>@#&-/".contains(ch) {
                1
            } else {
                bail!("{source}:{line}:{column}: unexpected character {ch:?}")
            };
            (Kind::Symbol, rest[..length].to_owned(), length)
        };
        let end = start + length;
        tokens.push(Token {
            kind,
            value: value.clone(),
            line,
            column,
            start,
            end,
        });
        advance(&text[start..end], &mut line, &mut column);
        pos = end;
        if kind == Kind::Keyword {
            if value.eq_ignore_ascii_case("asm") {
                assembly = true
            } else if value.eq_ignore_ascii_case("end") {
                assembly = false
            }
        }
    }
    tokens.push(Token {
        kind: Kind::Eof,
        value: "<eof>".into(),
        line,
        column,
        start: pos,
        end: pos,
    });
    Ok(tokens)
}

fn advance(text: &str, line: &mut usize, column: &mut usize) {
    let lines = text.bytes().filter(|c| *c == b'\n').count();
    if lines > 0 {
        *line += lines;
        *column = text[text.rfind('\n').unwrap() + 1..].chars().count() + 1;
    } else {
        *column += text.chars().count();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn comments_unicode_strings_and_asm() -> Result<()> {
        let text =
            "\u{feff}unit Тест;\n{$O-} // Привет\nasm @@label: db 0FFh, \"a\"\"b\" end; 'it''s'";
        let tokens = scan(text, "test")?;
        for token in &tokens {
            assert!(text.is_char_boundary(token.start) && text.is_char_boundary(token.end));
        }
        assert!(
            tokens
                .iter()
                .any(|t| t.kind == Kind::Identifier && t.value == "@@label")
        );
        assert!(
            tokens
                .iter()
                .any(|t| t.kind == Kind::Number && t.value == "0FFh")
        );
        assert!(
            tokens
                .iter()
                .any(|t| t.kind == Kind::String && t.value == "a\"b")
        );
        assert!(
            tokens
                .iter()
                .any(|t| t.kind == Kind::String && t.value == "it's")
        );
        Ok(())
    }
    #[test]
    fn ranges_and_malformed_tokens() -> Result<()> {
        let tokens = scan("0..9 1.5e-2 0xAB $0F", "test")?;
        assert_eq!(
            tokens[..6]
                .iter()
                .map(|t| t.value.as_str())
                .collect::<Vec<_>>(),
            ["0", "..", "9", "1.5e-2", "0xAB", "$0F"]
        );
        for text in ["'unfinished", "{unfinished", "1e+", "0x", "$"] {
            assert!(scan(text, "test").is_err());
        }
        Ok(())
    }
}
