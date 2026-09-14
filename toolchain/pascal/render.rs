//! Source spellings from declarations, shared by source generation and declaration export.
use crate::{
    pascal::model::Decl,
    util::{array, string, yes},
};
use anyhow::{Result, bail};
use serde_json::Value;
pub fn heading(
    d: &Decl,
    type_name: &mut impl FnMut(&Value) -> Result<String>,
    qualified: bool,
    defaults: bool,
) -> Result<String> {
    let data = &d.data;
    let name = if qualified && !string(data, "owner").is_empty() {
        format!("{}.{}", string(data, "owner"), string(data, "method_name"))
    } else if !string(data, "method_name").is_empty() {
        string(data, "method_name").into()
    } else {
        d.name.clone()
    };
    let mut params = Vec::new();
    for p in array(data, "params") {
        let mode = string(p, "mode");
        let mut text = format!(
            "{}{}",
            if mode == "value" {
                String::new()
            } else {
                format!("{mode} ")
            },
            string(p, "name")
        );
        if !p["type"].is_null() {
            text += &format!(": {}", type_name(&p["type"])?);
        }
        if defaults && let Some(value) = p["default"].as_str() {
            text += &format!(" = {value}");
        }
        params.push(text);
    }
    let mut result = format!(
        "{}{} {name}",
        if yes(data, "class_method") {
            "class "
        } else {
            ""
        },
        string(data, "routine_kind")
    );
    if !params.is_empty() {
        result += &format!("({})", params.join("; "));
    }
    if !data["result"].is_null() {
        result += &format!(": {}", type_name(&data["result"])?);
    }
    result.push(';');
    if !string(data, "abi").is_empty() {
        result += &format!(" {};", string(data, "abi"));
    }
    if array(data, "directives").iter().any(|v| v == "overload") {
        result += " overload;";
    }
    Ok(result)
}
pub fn spelling(spec: &Value) -> Result<String> {
    if let Some(name) = spec.as_str() {
        return Ok(name.into());
    }
    if let Some(name) = spec["source_type"].as_str() {
        return Ok(name.into());
    }
    if let Some(bounds) = spec.get("subrange") {
        return Ok(format!("{}..{}", bounds["lower"], bounds["upper"]));
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
        let mut text = heading(&d, &mut spelling, false, true)?
            .trim_end_matches(';')
            .to_string();
        if yes(signature, "of_object") {
            let abi = string(signature, "abi");
            if abi.is_empty() {
                text += " of object";
            } else {
                text = text.replace(&format!("; {abi}"), &format!(" of object; {abi}"));
            }
        }
        return Ok(text);
    }
    for (key, prefix) in [
        ("pointer", "^"),
        ("open_array", "array of "),
        ("dynamic_array", "array of "),
        ("classref", "class of "),
    ] {
        if let Some(inner) = spec.get(key) {
            return Ok(format!("{prefix}{}", spelling(inner)?));
        }
    }
    if let Some(inner) = spec.get("array") {
        let low = spec["lower"].as_i64().unwrap_or(0);
        let count = spec["count"].as_i64().unwrap_or(0);
        return Ok(format!(
            "array[{low}..{}] of {}",
            low + count - 1,
            spelling(inner)?
        ));
    }
    if let Some(element) = spec.get("set") {
        return Ok(format!(
            "set of {}",
            if element.is_object() {
                format!("{}..{}", element["lower"], element["upper"])
            } else {
                element.as_str().unwrap_or("").into()
            }
        ));
    }
    bail!("Unsupported Pascal type: {spec}")
}
