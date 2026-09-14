//! Checked native-address annotations embedded in ordinary Pascal comments.
use super::lexer::Token;
use anyhow::{Result, ensure};
use serde_json::{Map, Value, json};

pub fn integer(text: &str) -> Result<i64> {
    if let Some(hex) = text.strip_prefix('$') {
        Ok(i64::from_str_radix(hex, 16)?)
    } else if text.starts_with("0x") || text.starts_with("0X") {
        Ok(i64::from_str_radix(&text[2..], 16)?)
    } else {
        Ok(text.parse()?)
    }
}

pub fn parse(comment: &Token, source: &str, routine: bool) -> Result<Map<String, Value>> {
    let text = &comment.value;
    let mut pos = 0;
    let mut result = Map::new();
    let fail = |msg: String| anyhow::anyhow!("{source}:{}:{}: {msg}", comment.line, comment.column);
    while pos < text.len() {
        let ch = text[pos..].chars().next().unwrap();
        if ch != '@' || pos > 0 && !text[..pos].chars().next_back().unwrap().is_whitespace() {
            pos += ch.len_utf8();
            continue;
        }
        pos += 1;
        let start = pos;
        while pos < text.len()
            && text[pos..]
                .chars()
                .next()
                .is_some_and(|c| c.is_alphanumeric() || c == '_')
        {
            pos += text[pos..].chars().next().unwrap().len_utf8();
        }
        let key = &text[start..pos];
        if !matches!(
            key,
            "addr"
                | "codeend"
                | "indirect"
                | "offset"
                | "size"
                | "slot"
                | "calls"
                | "indexrefs"
                | "stackpop"
                | "countedstack"
                | "partial"
                | "nameonly"
                | "ida"
                | "note"
        ) {
            return Err(fail(format!("unknown annotation @{key}")));
        }
        if result.contains_key(key) {
            return Err(fail(format!("duplicate annotation @{key}")));
        }
        if matches!(key, "partial" | "nameonly") {
            result.insert(key.into(), json!(true));
            continue;
        }
        while pos < text.len() && text[pos..].chars().next().unwrap().is_whitespace() {
            pos += text[pos..].chars().next().unwrap().len_utf8();
        }
        if pos == text.len() || text[pos..].starts_with('@') {
            return Err(fail(format!("missing value for @{key}")));
        }
        let value = if text[pos..].starts_with('"') {
            pos += 1;
            let mut value = String::new();
            while pos < text.len() && !text[pos..].starts_with('"') {
                if text[pos..].starts_with('\\')
                    && text
                        .as_bytes()
                        .get(pos + 1)
                        .is_some_and(|c| matches!(c, b'\\' | b'"'))
                {
                    pos += 1;
                }
                let ch = text[pos..].chars().next().unwrap();
                value.push(ch);
                pos += ch.len_utf8();
            }
            if pos == text.len() {
                return Err(fail(format!("unterminated quoted value for @{key}")));
            }
            pos += 1;
            value
        } else {
            let start = pos;
            while pos < text.len() && !text[pos..].chars().next().unwrap().is_whitespace() {
                pos += text[pos..].chars().next().unwrap().len_utf8();
            }
            text[start..pos].into()
        };
        let value = if matches!(
            key,
            "addr" | "codeend" | "indirect" | "offset" | "size" | "slot" | "stackpop"
        ) {
            let parsed = if routine && key == "addr" && value.to_lowercase().starts_with("sub_") {
                i64::from_str_radix(&value[4..], 16).map_err(anyhow::Error::from)
            } else {
                integer(&value)
            };
            json!(parsed.map_err(|_| fail(format!("expected 0xHEX, $HEX, or decimal for @{key}")))?)
        } else if key == "calls" || key == "indexrefs" {
            let values = value
                .split(|c: char| c.is_whitespace() || c == ',')
                .filter(|v| !v.is_empty())
                .map(integer)
                .collect::<Result<Vec<_>>>()?;
            if values.is_empty() || values.iter().any(|v| !(1..=u32::MAX as i64).contains(v)) {
                return Err(fail(format!(
                    "@{key} needs at least one nonzero Win32 address"
                )));
            }
            json!(values)
        } else {
            json!(value)
        };
        result.insert(key.into(), value);
    }
    Ok(result)
}

pub fn validate(meta: &Map<String, Value>, allowed: &[&str]) -> Result<()> {
    for key in meta.keys() {
        ensure!(
            allowed.contains(&key.as_str()),
            "@{key} is not valid on this declaration"
        );
    }
    Ok(())
}
