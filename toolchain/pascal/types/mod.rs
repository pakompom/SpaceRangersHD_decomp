//! Win32 Delphi storage, inheritance and ABI validation.
use crate::pascal::model::Decl;
use anyhow::{Context, Result, bail, ensure};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
mod abi;
mod build;
mod layout;

pub fn builtin(name: &str) -> Option<(&'static str, i64)> {
    Some(match name.to_lowercase().as_str() {
        "byte" => ("unsigned __int8", 1),
        "shortint" => ("__int8", 1),
        "word" => ("unsigned __int16", 2),
        "smallint" => ("__int16", 2),
        "integer" | "longint" => ("__int32", 4),
        "cardinal" | "longword" | "dword" => ("unsigned __int32", 4),
        "int64" => ("__int64", 8),
        "uint64" => ("unsigned __int64", 8),
        "single" => ("float", 4),
        "double" => ("double", 8),
        "extended" => ("_TBYTE", 10),
        "boolean" => ("bool", 1),
        "longbool" => ("__int32", 4),
        "char" => ("char", 1),
        "widechar" => ("unsigned __int16", 2),
        "pointer" => ("void *", 4),
        "ansistring" => ("char *", 4),
        "widestring" => ("unsigned __int16 *", 4),
        _ => return None,
    })
}

pub struct Compiler {
    pub decls: Vec<Decl>,
    pub types: BTreeMap<String, std::sync::Arc<Decl>>,
    pub type_order: Vec<String>,
    pub names: BTreeSet<String>,
    layouts: BTreeMap<String, std::sync::Arc<Value>>,
    active: BTreeSet<String>,
    slots: BTreeMap<String, BTreeMap<i64, Decl>>,
    slots_active: BTreeSet<String>,
    prototypes: BTreeMap<String, Option<String>>,
}
use crate::util::{array, integer, string, yes};
fn subrange_storage(bounds: &Value) -> Result<(&'static str, i64)> {
    let lower = integer(bounds, "lower")?;
    let upper = integer(bounds, "upper")?;
    ensure!(lower <= upper, "empty/reversed subrange");
    let name = if lower >= 0 {
        if upper <= u8::MAX as i64 {
            "Byte"
        } else if upper <= u16::MAX as i64 {
            "Word"
        } else if upper <= u32::MAX as i64 {
            "Cardinal"
        } else {
            "Int64"
        }
    } else if lower >= i8::MIN as i64 && upper <= i8::MAX as i64 {
        "ShortInt"
    } else if lower >= i16::MIN as i64 && upper <= i16::MAX as i64 {
        "SmallInt"
    } else if lower >= i32::MIN as i64 && upper <= i32::MAX as i64 {
        "Integer"
    } else {
        "Int64"
    };
    Ok(builtin(name).unwrap())
}
fn methods(d: &Decl) -> Result<Vec<Decl>> {
    array(&d.data, "methods")
        .iter()
        .map(|v| Ok(serde_json::from_value(v.clone())?))
        .collect()
}
fn directive(d: &Decl, name: &str) -> bool {
    array(&d.data, "directives")
        .iter()
        .any(|v| v.as_str() == Some(name))
}

impl Compiler {
    pub fn new(declarations: Vec<Decl>) -> Result<Self> {
        let mut decls = Vec::new();
        for d in declarations {
            let children = methods(&d)?;
            decls.push(d);
            decls.extend(children);
        }
        let (mut types, mut order, mut names, mut addresses, mut calls) = (
            BTreeMap::<String, std::sync::Arc<Decl>>::new(),
            Vec::new(),
            BTreeSet::new(),
            BTreeSet::new(),
            BTreeSet::new(),
        );
        for d in &decls {
            let key = d.name.to_lowercase();
            let completes = types.get(&key).is_some_and(|old| {
                old.kind == d.kind
                    && matches!(d.kind.as_str(), "class" | "interface")
                    && yes(&old.data, "opaque")
                    && !yes(&d.data, "opaque")
                    && old.source.rsplit_once(':').map(|p| p.0)
                        == d.source.rsplit_once(':').map(|p| p.0)
            });
            // Equal aliases can share an ABI layout while retaining separate
            // declarations (and RTTI) in their Delphi units.
            let repeated_alias = types.get(&key).is_some_and(|old| {
                old.kind == "alias"
                    && d.kind == "alias"
                    && old.data["type"] == d.data["type"]
                    && old.source.rsplit_once(':').map(|p| p.0)
                        != d.source.rsplit_once(':').map(|p| p.0)
            });
            ensure!(
                (!names.contains(&key) || completes || repeated_alias) && builtin(&key).is_none(),
                "{}: duplicate/reserved name {}",
                d.source,
                d.name
            );
            names.insert(key.clone());
            if matches!(d.kind.as_str(), "routine" | "global" | "constant") {
                ensure!(
                    d.kind != "constant"
                        || !d.meta.contains_key("addr")
                        || !d.data["type"].is_null(),
                    "{}: an addressed constant needs an explicit storage type",
                    d.source
                );
                if !yes(&d.data, "interface_method")
                    && !directive(d, "abstract")
                    && (d.kind != "constant" || d.meta.contains_key("addr"))
                {
                    let addr = d
                        .meta
                        .get("addr")
                        .and_then(Value::as_i64)
                        .context("missing @addr")?;
                    ensure!(
                        (1..=u32::MAX as i64).contains(&addr),
                        "{}: @addr must be a nonzero Win32 address",
                        d.source
                    );
                    ensure!(
                        addresses.insert(addr),
                        "{}: duplicate address {addr:#x}",
                        d.source
                    );
                }
                if let Some(sites) = d.meta.get("calls").and_then(Value::as_array) {
                    for site in sites {
                        ensure!(
                            calls.insert(site.as_u64().context("invalid call site")?),
                            "{}: duplicate call-site address",
                            d.source
                        );
                    }
                }
                let params = array(&d.data, "params");
                let unique: BTreeSet<_> = params
                    .iter()
                    .map(|p| string(p, "name").to_lowercase())
                    .collect();
                ensure!(
                    params.len() == unique.len(),
                    "{}: duplicate parameter name",
                    d.source
                );
            } else {
                if !types.contains_key(&key) {
                    order.push(key.clone());
                }
                types.insert(key, std::sync::Arc::new(d.clone()));
            }
        }
        Ok(Self {
            decls,
            types,
            type_order: order,
            names,
            layouts: BTreeMap::new(),
            active: BTreeSet::new(),
            slots: BTreeMap::new(),
            slots_active: BTreeSet::new(),
            prototypes: BTreeMap::new(),
        })
    }
    pub fn lookup(&self, name: &str) -> Result<std::sync::Arc<Decl>> {
        self.types
            .get(&name.to_lowercase())
            .cloned()
            .with_context(|| format!("unknown type {name}"))
    }
    pub fn member_names(&self, name: &str) -> Result<BTreeSet<String>> {
        let (mut name, mut names, mut seen) = (name.to_owned(), BTreeSet::new(), BTreeSet::new());
        while !name.is_empty() {
            let Some(d) = self.types.get(&name.to_lowercase()) else {
                break;
            };
            ensure!(
                seen.insert(d.name.clone()),
                "recursive class inheritance: {}",
                d.name
            );
            for kind in ["fields", "properties"] {
                names.extend(
                    array(&d.data, kind)
                        .iter()
                        .map(|f| string(f, "name").to_lowercase()),
                );
            }
            names.extend(
                methods(d)?
                    .iter()
                    .map(|m| string(&m.data, "method_name").to_lowercase()),
            );
            name = string(&d.data, "parent").into();
            if name.is_empty() && d.kind == "class" && !d.name.eq_ignore_ascii_case("tobject") {
                name = "TObject".into();
            }
        }
        Ok(names)
    }
    pub fn size(&mut self, typ: &Value) -> Result<i64> {
        if let Some(bounds) = typ.get("subrange") {
            return Ok(subrange_storage(bounds)?.1);
        }
        if let Some(name) = typ.as_str() {
            if let Some((_, size)) = builtin(name) {
                return Ok(size);
            }
            let d = self.lookup(name)?;
            if matches!(d.kind.as_str(), "class" | "interface") {
                return Ok(4);
            }
            if matches!(d.kind.as_str(), "enum" | "alias")
                && let Some(size) = d.meta.get("size").and_then(Value::as_i64)
            {
                return Ok(size);
            }
            ensure!(
                d.kind == "alias"
                    || !yes(&d.data, "opaque")
                        && !d
                            .meta
                            .get("partial")
                            .and_then(Value::as_bool)
                            .unwrap_or(false),
                "{}: incomplete records cannot be embedded or used as array elements",
                d.name
            );
            return self
                .layout(&d)?
                .get("size")
                .and_then(Value::as_i64)
                .with_context(|| {
                    format!(
                        "{}: incomplete records cannot be embedded or used as array elements",
                        d.name
                    )
                });
        }
        if typ.get("callable").is_some() {
            return Ok(if yes(&typ["callable"], "of_object") {
                8
            } else {
                4
            });
        }
        if ["pointer", "classref", "vmt", "dynamic_array"]
            .iter()
            .any(|k| typ.get(k).is_some())
        {
            self.ctype(typ, "")?;
            return Ok(4);
        }
        if let Some(element) = typ.get("array") {
            return self
                .size(element)?
                .checked_mul(integer(typ, "count")?)
                .context("array size overflow");
        }
        bail!("unsized or unsupported field type: {typ}")
    }
    pub fn ctype(&mut self, typ: &Value, name: &str) -> Result<String> {
        if let Some(bounds) = typ.get("subrange") {
            return Ok(format!("{} {name}", subrange_storage(bounds)?.0)
                .trim()
                .into());
        }
        if typ.is_null() {
            return Ok(format!("void {name}").trim().into());
        }
        if let Some(typ) = typ.as_str() {
            if let Some((c, _)) = builtin(typ) {
                return Ok(format!("{c} {name}").trim().into());
            }
            let d = self.lookup(typ)?;
            return Ok(format!(
                "{} {}{name}",
                d.name,
                if matches!(d.kind.as_str(), "class" | "interface") {
                    "*"
                } else {
                    ""
                }
            )
            .trim()
            .into());
        }
        if let Some(data) = typ.get("callable") {
            let mut data = data.clone();
            let abi = string(&data, "abi").to_owned();
            if yes(&data, "of_object") {
                ensure!(
                    abi.is_empty() || abi == "register",
                    "non-register method-pointer ABI requires explicit support"
                );
                data["of_object"] = json!(false);
                let mut params = vec![json!({"name":"Context","type":"Pointer","mode":"value"})];
                params.extend(array(&data, "params").iter().cloned());
                data["params"] = json!(params);
                let code = self.ctype(&json!({"callable":data}), "Code")?;
                return Ok(format!("struct {{ {code}; void *Data; }} {name}")
                    .trim()
                    .into());
            }
            if abi.is_empty() || abi == "register" {
                let mut params = array(&data, "params").to_vec();
                for p in &mut params {
                    if string(p, "mode") == "value"
                        && self.record_value(&p["type"])?
                        && self.size(&p["type"])? > 4
                    {
                        p["type"] = json!({"pointer":p["type"]});
                    }
                }
                data["params"] = json!(params);
            }
            let d = Decl {
                name: "Callback".into(),
                kind: "routine".into(),
                source: "procedural type".into(),
                meta: Default::default(),
                data,
                start: 0,
                end: 0,
                closing: None,
                type_span: None,
            };
            let prototype = self.prototype_raw(&d)?.context("untyped callback")?;
            static CALLBACK_HEAD: std::sync::LazyLock<regex::Regex> =
                std::sync::LazyLock::new(|| {
                    regex::Regex::new(
                        r"\b(__(?:usercall|userpurge|cdecl|stdcall|pascal|safecall)) Callback",
                    )
                    .unwrap()
                });
            let regex = &*CALLBACK_HEAD;
            return Ok(regex
                .replace(prototype.trim_end_matches(';'), |c: &regex::Captures| {
                    format!("({} *{name})", &c[1])
                })
                .into_owned());
        }
        if let Some(vmt) = typ.get("vmt").and_then(Value::as_str) {
            return Ok(format!("{vmt} *{name}").trim().into());
        }
        if let Some(class) = typ.get("classref").and_then(Value::as_str) {
            ensure!(
                self.lookup(class)?.kind == "class",
                "class of {class}: target must be a class"
            );
            return Ok(format!("void *{name}").trim().into());
        }
        if let Some(inner) = typ.get("pointer") {
            return self.ctype(
                inner,
                &if inner.get("array").is_some() {
                    format!("(*{name})")
                } else {
                    format!("*{name}")
                },
            );
        }
        if let Some(inner) = typ.get("dynamic_array") {
            return self.ctype(&json!({"pointer":inner}), name);
        }
        if let Some(inner) = typ.get("array") {
            return self.ctype(inner, &format!("{name}[{}]", integer(typ, "count")?));
        }
        bail!("open arrays are only allowed as routine parameters; sets need a named alias")
    }
    pub fn managed_storage(&mut self, typ: &Value) -> Result<Vec<(i64, String)>> {
        if typ.is_object() {
            if typ.get("dynamic_array").is_some() {
                return Ok(vec![(0, "dynamic_array".into())]);
            }
            if let Some(element) = typ.get("array") {
                let stride = self.size(element)?;
                let slots = self.managed_storage(element)?;
                return Ok((0..integer(typ, "count")?)
                    .flat_map(|i| {
                        slots
                            .iter()
                            .map(move |(off, kind)| (i * stride + off, kind.clone()))
                    })
                    .collect());
            }
            return Ok(vec![]);
        }
        let name = typ.as_str().context("managed storage needs a type")?;
        let lower = name.to_lowercase();
        if matches!(
            lower.as_str(),
            "ansistring" | "widestring" | "variant" | "olevariant"
        ) {
            return Ok(vec![(0, lower)]);
        }
        if builtin(name).is_some() {
            return Ok(vec![]);
        }
        let d = self.lookup(name)?;
        if d.kind == "alias" {
            return self.managed_storage(&d.data["type"]);
        }
        if d.kind == "interface" {
            return Ok(vec![(0, "interface".into())]);
        }
        let mut slots = Vec::new();
        if d.kind == "record" {
            for field in array(&*self.layout(&d)?, "fields") {
                let offset = integer(field, "offset")?;
                slots.extend(
                    self.managed_storage(&field["type"])?
                        .into_iter()
                        .map(|(off, kind)| (offset + off, kind)),
                );
            }
        }
        Ok(slots)
    }
    pub fn scalar(&mut self, typ: &Value) -> Result<bool> {
        if typ.is_object() {
            if let Some(bounds) = typ.get("subrange") {
                return Ok(subrange_storage(bounds)?.1 <= 4);
            }
            if typ.get("callable").is_some() {
                return Ok(!yes(&typ["callable"], "of_object"));
            }
            return Ok(["pointer", "classref", "dynamic_array"]
                .iter()
                .any(|k| typ.get(k).is_some()));
        }
        let name = typ.as_str().context("scalar needs a type")?;
        if builtin(name).is_some() {
            return Ok(!matches!(
                name.to_lowercase().as_str(),
                "double" | "single" | "extended" | "int64" | "uint64"
            ));
        }
        let d = self.lookup(name)?;
        if d.kind == "alias" && d.data["type"].get("set").is_some() {
            return Ok([1, 2, 4].contains(&self.size(typ)?));
        }
        Ok(matches!(d.kind.as_str(), "enum" | "class" | "interface")
            || d.kind == "alias" && self.scalar(&d.data["type"])?)
    }
    fn classify(&self, typ: &Value, category: &str) -> Result<bool> {
        if typ.is_object() {
            if let Some(bounds) = typ.get("subrange") {
                return Ok(category == "wide" && subrange_storage(bounds)?.1 == 8);
            }
            return Ok(match category {
                "managed" => typ.get("dynamic_array").is_some(),
                "method" => typ.get("callable").is_some_and(|d| yes(d, "of_object")),
                _ => false,
            });
        }
        let Some(name) = typ.as_str() else {
            return Ok(false);
        };
        let lower = name.to_lowercase();
        if builtin(name).is_some() {
            return Ok(match category {
                "managed" => matches!(lower.as_str(), "widestring" | "ansistring"),
                "floating" => matches!(lower.as_str(), "single" | "double"),
                "wide" => matches!(lower.as_str(), "int64" | "uint64"),
                _ => false,
            });
        }
        let d = self.lookup(name)?;
        Ok(match (category, d.kind.as_str()) {
            ("record", "record") | ("managed", "interface") => true,
            (_, "alias") => self.classify(&d.data["type"], category)?,
            _ => false,
        })
    }
    pub fn record_value(&self, typ: &Value) -> Result<bool> {
        self.classify(typ, "record")
    }
    pub fn floating(&self, typ: &Value) -> Result<bool> {
        self.classify(typ, "floating")
    }
    pub fn wide_integer(&self, typ: &Value) -> Result<bool> {
        self.classify(typ, "wide")
    }
    pub fn managed_return(&self, typ: &Value) -> Result<bool> {
        self.classify(typ, "managed")
    }
    pub fn method_pointer(&self, typ: &Value) -> Result<bool> {
        self.classify(typ, "method")
    }
    pub fn const_aggregate_reference(&mut self, typ: &Value) -> Result<bool> {
        let aggregate = if let Some(name) = typ.as_str() {
            let Some(d) = self.types.get(&name.to_lowercase()).cloned() else {
                return Ok(false);
            };
            if d.kind == "alias" {
                return self.const_aggregate_reference(&d.data["type"]);
            }
            d.kind == "record"
        } else {
            typ.get("array").is_some()
        };
        Ok(aggregate && ![1, 2, 4].contains(&self.size(typ)?))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::pascal::parser::Parser;
    fn compiler(text: &str) -> Result<Compiler> {
        let tree = Parser::new(text, "X.pas", true, None)?.document(false)?;
        Compiler::new(
            tree.children
                .into_iter()
                .filter_map(|n| n.declaration)
                .collect(),
        )
    }
    #[test]
    fn numeric_subranges_keep_bounds_storage_and_register_abi() -> Result<()> {
        let mut c = compiler(
            "unit X; interface type TPercent = 0..100; TByte = 0..255; TWord = 0..256; TSigned = -128..127; TSmall = -129..127; TCardinal = 0..$FFFFFFFF; TWide = -1..$FFFFFFFF;\nfunction Percent(A: TPercent; B: TSigned; C: TWord): TPercent; // @addr $1000\nimplementation end.",
        )?;
        for (name, size, ctype) in [
            ("TPercent", 1, "unsigned __int8"),
            ("TByte", 1, "unsigned __int8"),
            ("TWord", 2, "unsigned __int16"),
            ("TSigned", 1, "__int8"),
            ("TSmall", 2, "__int16"),
            ("TCardinal", 4, "unsigned __int32"),
            ("TWide", 8, "__int64"),
        ] {
            let d = c.lookup(name)?;
            let layout = c.layout(&d)?;
            assert_eq!(layout["size"], size);
            assert_eq!(layout["decl"], format!("typedef {ctype} {name};"));
        }
        let percent = c.lookup("TPercent")?;
        assert_eq!(
            crate::pascal::render::spelling(&percent.data["type"])?,
            "0..100"
        );
        let routine = c
            .decls
            .iter()
            .find(|d| d.name == "Percent")
            .unwrap()
            .clone();
        assert_eq!(
            c.prototype(&routine)?.as_deref(),
            Some(
                "TPercent __usercall Percent@<al>(TPercent A@<al>, TSigned B@<dl>, TWord C@<cx>);"
            )
        );
        assert!(c.wide_integer(&json!("TWide"))?);
        assert!(compiler("unit X; interface type Bad = 2..1; implementation end.").is_err());
        Ok(())
    }
    #[test]
    fn register_and_stack_abi() -> Result<()> {
        let mut c = compiler(
            "unit X; interface function Work(A: Byte; B: Word; C: Integer; D: Integer): Integer; // @addr $1000\n implementation end.",
        )?;
        let d = c.decls[0].clone();
        assert_eq!(
            c.prototype(&d)?.as_deref(),
            Some(
                "__int32 __userpurge Work@<eax>(unsigned __int8 A@<al>, unsigned __int16 B@<dx>, __int32 C@<ecx>, __int32 D@<^0>);"
            )
        );
        Ok(())
    }
    #[test]
    fn overlapping_fields_and_globals_are_rejected() {
        for text in [
            "unit X; interface type R = record A: Integer; // @offset 0\n B: Integer; // @offset 2\n end; // @size 8\n implementation end.",
            "unit X; interface var A: Integer; // @addr $1000\n B: Integer; // @addr $1002\n implementation end.",
            "unit X; interface function F: Integer; // @addr $1000 @ida \"int __usercall $name(void);\"\n implementation end.",
        ] {
            assert!(
                compiler(text).and_then(|mut c| c.build()).is_err(),
                "{text}"
            );
        }
    }
}
