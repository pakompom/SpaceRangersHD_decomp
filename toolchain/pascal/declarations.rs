//! Declaration grammar and annotation attachment; statements live separately.
use super::{
    lexer::{Kind, Token},
    model::Decl,
    parser::Parser,
};
use anyhow::{Result, ensure};
use serde_json::{Value, json};
use std::path::Path;

impl Parser<'_> {
    pub(super) fn type_expr(&mut self, parameter: bool) -> Result<Value> {
        let start = self.current()?;
        if self.accept("type")? || self.accept("packed")? {
            return self.type_expr(parameter);
        }
        if self.peek("record")? || self.peek("object")? {
            let d = self.aggregate(start.clone(), String::new(), false)?;
            return Ok(json!({"source_type":self.text[start.start..d.end]}));
        }
        if self.accept("class")? {
            self.expect("of")?;
            return Ok(json!({"classref":self.qualified()?}));
        }
        if self.accept("^")? {
            return Ok(json!({"pointer":self.type_expr(false)?}));
        }
        if self.accept("array")? {
            if self.accept("[")? {
                let mut dimensions = Vec::new();
                let mut known = true;
                loop {
                    if self.annotated {
                        let lo = self.integer()?;
                        self.expect("..")?;
                        let hi = self.integer()?;
                        ensure!(hi >= lo, "empty/reversed array range");
                        dimensions.push((lo, hi));
                    } else {
                        let bound = self.expression(0)?;
                        if bound.kind == "binary" && bound.value.as_deref() == Some("..") {
                            match (
                                super::parser::constant(
                                    &bound.children[0],
                                    &self.constants,
                                    &Default::default(),
                                ),
                                super::parser::constant(
                                    &bound.children[1],
                                    &self.constants,
                                    &Default::default(),
                                ),
                            ) {
                                (Ok(lo), Ok(hi)) if lo.is_i64() && hi.is_i64() => {
                                    dimensions.push((lo.as_i64().unwrap(), hi.as_i64().unwrap()))
                                }
                                _ => known = false,
                            }
                        } else {
                            known = false
                        }
                    }
                    if !self.accept(",")? {
                        break;
                    }
                }
                self.expect("]")?;
                self.expect("of")?;
                let mut typ = self.type_expr(false)?;
                if !known {
                    return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
                }
                for (lo, hi) in dimensions.into_iter().rev() {
                    typ = json!({"array":typ,"count":hi-lo+1,"lower":lo});
                }
                return Ok(typ);
            }
            self.expect("of")?;
            return Ok(if parameter {
                json!({"open_array":self.type_expr(parameter)?})
            } else {
                json!({"dynamic_array":self.type_expr(parameter)?})
            });
        }
        if self.accept("set")? {
            self.expect("of")?;
            if !self.annotated && !self.peek("(")? {
                self.expression(0)?;
                return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
            }
            if self.current()?.kind == Kind::Number || self.peek("-")? || self.peek("+")? {
                let lo = self.integer()?;
                self.expect("..")?;
                return Ok(json!({"set":{"lower":lo,"upper":self.integer()?}}));
            }
            if self.accept("(")? {
                self.expression_list(")")?;
                return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
            }
            return Ok(json!({"set":self.qualified()?}));
        }
        if self.peek("procedure")? || self.peek("function")? {
            let kind = self.take()?.value.to_lowercase();
            let params = self.parameters(!self.annotated, "(", ")")?;
            let result = if kind == "function" {
                self.expect(":")?;
                self.type_expr(false)?
            } else {
                Value::Null
            };
            let method = self.accept("of")?;
            if method {
                self.expect("object")?;
            }
            let mut abi = None;
            loop {
                let convention = self.value()?;
                let ahead = if self.peek(";")? {
                    self.ahead(1)?.value.to_lowercase()
                } else {
                    String::new()
                };
                if !is_convention(&convention) && !is_convention(&ahead) {
                    break;
                }
                self.accept(";")?;
                ensure!(abi.is_none(), "duplicate calling convention");
                abi = Some(self.take()?.value.to_lowercase());
            }
            return Ok(
                json!({"callable":{"routine_kind":kind,"params":params,"result":result,"abi":abi,"of_object":method}}),
            );
        }
        if matches!(self.current()?.kind, Kind::Number | Kind::String)
            || self.peek("-")?
            || self.peek("+")?
        {
            let bounds = self.expression(0)?;
            if bounds.kind == "binary" && bounds.value.as_deref() == Some("..") {
                let lower = super::parser::constant(
                    &bounds.children[0],
                    &self.constants,
                    &Default::default(),
                );
                let upper = super::parser::constant(
                    &bounds.children[1],
                    &self.constants,
                    &Default::default(),
                );
                if let (Ok(lower), Ok(upper)) = (lower, upper)
                    && let (Some(lower), Some(upper)) = (lower.as_i64(), upper.as_i64())
                {
                    ensure!(upper >= lower, "empty/reversed subrange");
                    return Ok(json!({"subrange":{"lower":lower,"upper":upper}}));
                }
            }
            return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
        }
        if parameter && self.accept("const")? {
            return Ok(json!("const"));
        }
        let name = self.qualified()?;
        if self.accept("(")? {
            self.expression_list(")")?;
            self.expect("..")?;
            self.expression(0)?;
            return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
        }
        if self.accept("..")? {
            self.expression(0)?;
            return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
        }
        if self.accept("[")? {
            self.expression_list("]")?;
            return Ok(json!({"source_type":self.text[start.start..self.last().end]}));
        }
        Ok(json!(name))
    }
    pub(super) fn parameters(
        &mut self,
        source: bool,
        opening: &str,
        closing: &str,
    ) -> Result<Vec<Value>> {
        let mut params: Vec<Value> = Vec::new();
        if !self.accept(opening)? {
            return Ok(params);
        }
        while !self.peek(closing)? {
            let mode = if matches!(self.value()?.as_str(), "var" | "out" | "const") {
                self.take()?.value.to_lowercase()
            } else {
                "value".into()
            };
            let mut names = vec![self.ident()?];
            while self.accept(",")? {
                names.push(self.ident()?);
            }
            let typ = if matches!(mode.as_str(), "var" | "out" | "const") && !self.peek(":")? {
                Value::Null
            } else if source && !self.peek(":")? {
                json!("Pointer")
            } else {
                self.expect(":")?;
                self.type_expr(true)?
            };
            let default = if self.accept("=")? {
                ensure!(
                    !matches!(mode.as_str(), "var" | "out") && !typ.is_null() && names.len() == 1,
                    "a default requires one typed value or const parameter"
                );
                let start = self.current()?.start;
                self.expression(0)?;
                Some(self.text[start..self.last().end].to_owned())
            } else {
                ensure!(
                    params.last().is_none_or(|p| p.get("default").is_none()),
                    "a required parameter cannot follow a default parameter"
                );
                None
            };
            for name in names {
                let mut row = json!({"name":name,"type":typ,"mode":mode});
                if let Some(default) = &default {
                    row["default"] = json!(default);
                }
                params.push(row);
            }
            if !self.accept(";")? {
                break;
            }
        }
        self.expect(closing)?;
        Ok(params)
    }
    pub(super) fn routine(
        &mut self,
        mut owner: Option<String>,
        implementation: bool,
        interface_method: bool,
    ) -> Result<Decl> {
        let start = self.current()?;
        let class_method = self.accept("class")?;
        ensure!(
            !class_method
                || (owner.is_some() || implementation)
                    && (self.peek("function")? || self.peek("procedure")?),
            "class methods require a function or procedure inside a class"
        );
        let kind = self.take()?.value.to_lowercase();
        let mut name = self.ident()?;
        if implementation && self.accept(".")? {
            owner = Some(name);
            name = self.ident()?;
        } else if !self.annotated {
            while self.accept(".")? {
                name.push('.');
                name.push_str(&self.ident()?);
            }
        }
        let alias = if !self.annotated && self.accept("=")? {
            Some(self.qualified()?)
        } else {
            None
        };
        ensure!(
            !matches!(kind.as_str(), "constructor" | "destructor") || owner.is_some(),
            "constructors and destructors are supported only in classes"
        );
        let mut params = self.parameters(implementation || !self.annotated, "(", ")")?;
        ensure!(
            kind != "destructor" || params.is_empty(),
            "destructors cannot have parameters"
        );
        let mut result = Value::Null;
        if kind == "function" {
            if self.annotated && !implementation {
                self.expect(":")?;
                result = self.type_expr(false)?;
            } else if self.accept(":")? {
                result = self.type_expr(false)?;
            }
        }
        self.hints()?;
        self.accept(";")?;
        let (mut abi, mut directives, mut external) = (None, Vec::<String>::new(), None);
        loop {
            let directive = self.value()?;
            if !(is_routine_directive(&directive)
                || owner.is_some() && is_method_directive(&directive))
            {
                break;
            }
            let ds = self.take()?.start;
            if is_convention(&directive) {
                ensure!(abi.is_none(), "duplicate calling convention");
                abi = Some(directive.clone());
            } else {
                ensure!(
                    !(directives.contains(&directive)
                        || matches!(directive.as_str(), "virtual" | "override")
                            && directives
                                .iter()
                                .any(|d| matches!(d.as_str(), "virtual" | "override"))),
                    "duplicate/incompatible method directive"
                );
                directives.push(directive.clone());
            }
            if matches!(
                directive.as_str(),
                "platform" | "deprecated" | "library" | "experimental"
            ) && self.current()?.kind == Kind::String
            {
                self.take()?;
            }
            if matches!(directive.as_str(), "external" | "message") && !self.peek(";")? {
                self.expression(0)?;
                while self.current()?.kind == Kind::Identifier
                    && matches!(self.value()?.as_str(), "name" | "index")
                {
                    self.take()?;
                    self.expression(0)?;
                }
            }
            if directive == "external" {
                external = Some(self.text[ds..self.last().end].to_owned());
            }
            self.expect(";")?;
        }
        self.hints()?;
        if self.last().value != ";" {
            self.expect(";")?;
        }
        let annotated = self.annotated;
        if implementation {
            self.annotated = self.native_annotations;
        }
        let mut meta = self.meta(
            &start,
            &[
                "addr",
                "codeend",
                "ida",
                "note",
                "nameonly",
                "slot",
                "calls",
                "stackpop",
                "countedstack",
            ],
            true,
        )?;
        self.annotated = annotated;
        if !implementation && let Some(library) = self.library {
            let unit = Path::new(self.source)
                .file_stem()
                .unwrap()
                .to_string_lossy();
            if let Some(address) = library.address(&unit, &name, owner.as_deref()) {
                ensure!(
                    !meta.contains_key("addr") || meta["addr"] == address,
                    "native address conflicts with the matched library inventory"
                );
                meta.insert("addr".into(), json!(address));
            }
        }
        let abstract_method = directives.iter().any(|s| s == "abstract");
        let virtual_method = directives
            .iter()
            .any(|s| matches!(s.as_str(), "virtual" | "override"));
        if self.annotated && !implementation && abstract_method {
            ensure!(
                matches!(kind.as_str(), "function" | "procedure")
                    && virtual_method
                    && meta.contains_key("slot"),
                "abstract methods require a virtual/override function or procedure with @slot"
            );
            ensure!(
                meta.keys()
                    .all(|k| ["slot", "ida", "note", "calls"].contains(&k.as_str())),
                "abstract methods have no native routine address"
            );
        }
        if let Some(end) = meta.get("codeend").and_then(Value::as_i64) {
            ensure!(
                meta.get("addr")
                    .and_then(Value::as_i64)
                    .is_some_and(|a| a < end)
                    && !meta.contains_key("nameonly")
                    && end <= u32::MAX as i64,
                "@codeend requires a typed routine and an exclusive end after @addr"
            );
        }
        if let Some(pop) = meta.get("stackpop").and_then(Value::as_i64) {
            ensure!(
                meta.contains_key("calls")
                    && meta.contains_key("ida")
                    && !meta.contains_key("countedstack")
                    && !meta.contains_key("nameonly"),
                "@stackpop requires @ida and @calls, without @nameonly or @countedstack"
            );
            ensure!(
                (0..=65535).contains(&pop) && pop % 4 == 0,
                "@stackpop must be a nonnegative four-byte-aligned RET byte count"
            );
        }
        if let Some(slot) = meta.get("slot").and_then(Value::as_i64) {
            ensure!(
                owner.is_some() && virtual_method,
                "@slot requires a virtual or override method"
            );
            ensure!(
                slot >= 0 && slot % 4 == 0,
                "@slot must be a nonnegative four-byte-aligned VMT offset"
            );
        }
        ensure!(
            !interface_method
                || !class_method
                    && matches!(kind.as_str(), "function" | "procedure")
                    && !virtual_method
                    && !abstract_method
                    && !meta.contains_key("addr"),
            "interface methods have implicit dispatch slots and no implementation address"
        );
        ensure!(
            !self.annotated
                || implementation
                || interface_method
                || meta.contains_key("addr")
                || abstract_method,
            "routine {name} needs @addr"
        );
        let qualified = owner
            .as_ref()
            .map_or_else(|| name.clone(), |o| format!("{o}_{name}"));
        if implementation
            && params.is_empty()
            && result.is_null()
            && alias.is_none()
            && let Some(candidates) = self
                .declared
                .get(&qualified.to_lowercase())
                .filter(|v| v.len() == 1)
        {
            params = candidates[0].data["params"].as_array().unwrap().clone();
            result = candidates[0].data["result"].clone();
        }
        let mut data = json!({"params":params,"result":result,"abi":abi,"owner":owner,"method_name":if owner.is_some(){Some(name)}else{None},"directives":directives,"routine_kind":kind,"class_method":class_method});
        if let Some(external) = external {
            data["external"] = json!(external);
        }
        if interface_method {
            data["interface_method"] = json!(true);
        }
        let d = self.decl(&start, qualified.clone(), "routine", meta, data);
        if !implementation {
            self.declared
                .entry(qualified.to_lowercase())
                .or_default()
                .push(d.clone());
        }
        Ok(d)
    }
    pub(super) fn record_fields(&mut self, owner: &str) -> Result<Vec<Value>> {
        let start = self.current()?;
        let mut names = vec![self.ident()?];
        while self.accept(",")? {
            names.push(self.ident()?);
        }
        self.expect(":")?;
        let typ = self.type_expr(false)?;
        self.hints()?;
        ensure!(
            self.accept(";")? || self.peek("end")? || self.peek(")")?,
            "expected ';' after field"
        );
        let meta = self.meta(&start, &["offset"], false)?;
        ensure!(
            !self.annotated || meta.contains_key("offset"),
            "{owner}.{} needs @offset",
            names[0]
        );
        Ok(names
            .into_iter()
            .map(|name| {
                let mut row = meta.clone();
                row.insert("name".into(), json!(name));
                row.insert("type".into(), typ.clone());
                Value::Object(row)
            })
            .collect())
    }
    fn variant_fields(&mut self) -> Result<Vec<Value>> {
        self.expect("case")?;
        self.qualified()?;
        if self.accept(":")? {
            self.type_expr(false)?;
        }
        self.expect("of")?;
        let mut fields = Vec::new();
        while !self.peek("end")? && !self.peek(")")? {
            self.expression(0)?;
            while self.accept(",")? {
                self.expression(0)?;
            }
            self.expect(":")?;
            self.expect("(")?;
            while !self.peek(")")? {
                fields.extend(if self.peek("case")? {
                    self.variant_fields()?
                } else {
                    self.record_fields("variant")?
                });
            }
            self.expect(")")?;
            if !self.accept(";")? {
                break;
            }
        }
        Ok(fields)
    }
    fn aggregate(&mut self, start: Token, name: String, terminator: bool) -> Result<Decl> {
        let head_start = self.current()?.start;
        let kind = self.take()?.value.to_lowercase();
        let mut parent = None;
        if self.accept("helper")? {
            if self.accept("(")? {
                self.qualified()?;
                self.expect(")")?;
            }
            self.expect("for")?;
            parent = Some(self.qualified()?);
        }
        if matches!(kind.as_str(), "class" | "interface" | "object") && self.accept("(")? {
            parent = Some(self.qualified()?);
            while self.accept(",")? {
                self.qualified()?;
            }
            self.expect(")")?;
        }
        let (mut guid, mut guid_value) = (None, None);
        if self.peek("[")? {
            let gs = self.take()?.start;
            let values = self.expression_list("]")?;
            guid = Some(self.text[gs..self.last().end].to_owned());
            if kind == "interface" {
                ensure!(values.len() == 1, "expected one GUID");
                let value =
                    super::parser::constant(&values[0], &self.constants, &Default::default())?;
                guid_value =
                    Some(
                        uuid::Uuid::parse_str(value.as_str().ok_or_else(|| {
                            anyhow::anyhow!("interface GUID must be a UUID string")
                        })?)?
                        .to_string(),
                    );
            }
        }
        let head_end = self.last().end;
        let mut meta = self.meta(&start, &["size", "partial"], false)?;
        let (mut fields, mut methods, mut properties) = (Vec::new(), Vec::new(), Vec::new());
        let opaque = self.peek(";")?;
        let mut closing = None;
        if !opaque {
            while !self.peek("end")? {
                if matches!(
                    self.value()?.as_str(),
                    "public" | "private" | "protected" | "published"
                ) {
                    self.take()?;
                    continue;
                }
                if self.peek("class")? && self.ahead(1)?.value.eq_ignore_ascii_case("var") {
                    self.take()?;
                    self.take()?;
                    continue;
                }
                if self.accept("strict")? {
                    continue;
                }
                if self.accept("type")? {
                    while self.current()?.kind == Kind::Identifier && self.ahead(1)?.value == "=" {
                        self.type_decl()?;
                    }
                    continue;
                }
                if self.peek("case")? {
                    fields.extend(self.variant_fields()?);
                    continue;
                }
                if self.accept("property")? {
                    let property_name = self.ident()?;
                    let indices = self.parameters(false, "[", "]")?;
                    let typ = if self.accept(":")? {
                        self.type_expr(false)?
                    } else {
                        Value::Null
                    };
                    let mut property = json!({"name":property_name,"params":indices,"type":typ});
                    while matches!(
                        self.value()?.as_str(),
                        "read"
                            | "write"
                            | "stored"
                            | "default"
                            | "nodefault"
                            | "index"
                            | "implements"
                            | "dispid"
                    ) {
                        let access = self.take()?.value.to_lowercase();
                        if access == "nodefault" {
                            continue;
                        }
                        let value = self.expression(0)?;
                        if access == "read" || access == "write" {
                            property[access] = json!(self.text[value.first.start..value.last.end]);
                        }
                    }
                    self.expect(";")?;
                    if self.accept("default")? {
                        self.expect(";")?;
                    }
                    properties.push(property);
                    continue;
                }
                if matches!(
                    self.value()?.as_str(),
                    "class" | "procedure" | "function" | "constructor" | "destructor"
                ) {
                    ensure!(
                        matches!(kind.as_str(), "class" | "object" | "interface"),
                        "instance methods are supported only in classes"
                    );
                    methods.push(self.routine(Some(name.clone()), false, kind == "interface")?);
                    continue;
                }
                ensure!(
                    kind != "interface",
                    "interfaces cannot contain instance fields"
                );
                fields.extend(self.record_fields(&name)?);
            }
            closing = Some(self.current()?.start);
            self.expect("end")?;
        }
        if terminator {
            self.hints()?;
            self.expect(";")?;
        }
        for (key, value) in self.meta(&start, &["size", "partial"], false)? {
            ensure!(!meta.contains_key(&key), "duplicate aggregate annotation");
            meta.insert(key, value);
        }
        let mut data = json!({"fields":fields,"methods":methods,"properties":properties,"parent":parent,"opaque":opaque});
        if kind == "interface" && guid.is_some() {
            data["guid"] = json!(guid);
            data["guid_value"] = json!(guid_value);
        }
        let mut d = self.decl(&start, name, &kind, meta, data);
        d.closing = closing;
        d.type_span = Some((head_start, head_end));
        Ok(d)
    }
    pub(super) fn type_decl(&mut self) -> Result<Decl> {
        let rhs = self.ahead(2)?.start;
        let start = self.current()?;
        let name = self.ident()?;
        self.expect("=")?;
        let packed = self.accept("packed")?;
        ensure!(
            !packed || !self.annotated || self.peek("record")?,
            "packed is supported only for records"
        );
        let mut d = if self.peek("interface")?
            || self.peek("record")?
            || self.peek("class")? && !self.ahead(1)?.value.eq_ignore_ascii_case("of")
        {
            let mut d = self.aggregate(start, name, true)?;
            if d.kind == "record" {
                d.data["packed"] = json!(packed);
            }
            d
        } else if self.accept("(")? {
            let mut members = Vec::new();
            let mut value = 0i64;
            while !self.peek(")")? {
                let member = self.ident()?;
                if self.accept("=")? {
                    if self.annotated {
                        value = self.integer()?;
                    } else {
                        self.expression(0)?;
                    }
                }
                members.push((member, value));
                value += 1;
                if !self.accept(",")? {
                    break;
                }
            }
            self.expect(")")?;
            self.expect(";")?;
            let meta = self.meta(&start, &["size"], false)?;
            self.decl(&start, name, "enum", meta, json!({"members":members}))
        } else {
            let typ = self.type_expr(false)?;
            self.hints()?;
            self.expect(";")?;
            let meta = self.meta(&start, &["size"], false)?;
            self.decl(&start, name, "alias", meta, json!({"type":typ}))
        };
        d.type_span = Some((rhs, d.type_span.map_or(self.last().start, |(_, end)| end)));
        Ok(d)
    }
}
fn is_convention(s: &str) -> bool {
    matches!(s, "register" | "cdecl" | "stdcall" | "safecall" | "pascal")
}
fn is_routine_directive(s: &str) -> bool {
    is_convention(s)
        || matches!(
            s,
            "overload"
                | "inline"
                | "forward"
                | "external"
                | "assembler"
                | "export"
                | "far"
                | "near"
                | "local"
                | "platform"
                | "deprecated"
                | "library"
                | "experimental"
        )
}
fn is_method_directive(s: &str) -> bool {
    matches!(
        s,
        "virtual" | "override" | "reintroduce" | "abstract" | "dynamic" | "message"
    )
}
