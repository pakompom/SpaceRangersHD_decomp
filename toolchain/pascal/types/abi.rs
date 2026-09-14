static USERCALL_HEAD: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(|| {
    regex::Regex::new(r"(?s)^\s*(.+?)\s*__(?:usercall|userpurge)\s+(\w+)\s*(@<[^>]+>)?\s*\(")
        .unwrap()
});
static SCALAR_RESULT: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(|| {
    regex::Regex::new(r"^(?:(?:signed|unsigned|long|short)\s+)*(?:bool|char|int|long|short|float|double|__int(?:8|16|32|64))$").unwrap()
});
static COUNTED_STACK: std::sync::LazyLock<regex::Regex> =
    std::sync::LazyLock::new(|| regex::Regex::new(r"^(\w+)\s*:\s*(\w+)(?::(caller))?$").unwrap());
static VARIADIC_TAIL: std::sync::LazyLock<regex::Regex> =
    std::sync::LazyLock::new(|| regex::Regex::new(r",\s*\.\.\.\s*\);$").unwrap());
static VMT_HEAD: std::sync::LazyLock<regex::Regex> = std::sync::LazyLock::new(|| {
    regex::Regex::new(r"\b(__(?:usercall|userpurge|cdecl|stdcall|fastcall|thiscall))\s+(\w+)\b")
        .unwrap()
});
use super::*;

impl Compiler {
    pub fn prototype(&mut self, d: &Decl) -> Result<Option<String>> {
        if let Some(value) = self.prototypes.get(&d.name) {
            return Ok(value.clone());
        }
        let value = self.prototype_raw(d)?;
        self.prototypes.insert(d.name.clone(), value.clone());
        Ok(value)
    }
    pub(super) fn prototype_raw(&mut self, d: &Decl) -> Result<Option<String>> {
        let mut source_params = array(&d.data, "params").to_vec();
        let owner = string(&d.data, "owner");
        if !owner.is_empty() {
            ensure!(
                !source_params
                    .iter()
                    .any(|p| string(p, "name").eq_ignore_ascii_case("self")),
                "{}: Self is implicit in methods",
                d.source
            );
            let typ = if yes(&d.data, "class_method") {
                json!({"classref":owner})
            } else {
                json!(owner)
            };
            source_params.insert(0, json!({"name":"Self","type":typ,"mode":"value"}));
        }
        if d.meta
            .get("nameonly")
            .and_then(Value::as_bool)
            .unwrap_or(false)
        {
            ensure!(
                !d.meta.contains_key("calls"),
                "@calls requires a typed routine"
            );
            ensure!(
                d.data["abi"].is_null() && !d.meta.contains_key("ida"),
                "@nameonly cannot be combined with a calling convention or @ida"
            );
            return Ok(None);
        }
        if let Some(ida) = d.meta.get("ida").and_then(Value::as_str) {
            let text = ida.replace("$name", &d.name);
            ensure!(
                text.contains(&d.name),
                "{}: @ida prototype must contain $name or its qualified name",
                d.name
            );
            let regex = &*USERCALL_HEAD;
            if let Some(head) = regex.captures(&text)
                && head[2] == d.name
                && head.get(3).is_none()
            {
                let result = head[1].trim();
                let scalar = SCALAR_RESULT.is_match(result);
                ensure!(
                    !scalar && !result.contains('*'),
                    "{}: non-void @ida usercall/userpurge return needs an explicit location after the routine name",
                    d.name
                );
            }
            return Ok(Some(format!("{};", text.trim_end_matches(';'))));
        }
        ensure!(
            !matches!(
                string(&d.data, "routine_kind"),
                "constructor" | "destructor"
            ),
            "{}: constructor/destructor hidden ABI needs @ida",
            d.name
        );
        let abi = match string(&d.data, "abi") {
            "" => "register",
            s => s,
        };
        ensure!(
            owner.is_empty() || abi == "register" || yes(&d.data, "interface_method"),
            "{}: non-register method ABI needs @ida",
            d.name
        );
        let mut params = Vec::<(String, Value)>::new();
        for p in source_params {
            let mut typ = p["type"].clone();
            let mode = string(&p, "mode");
            let name = string(&p, "name");
            if let Some(element) = typ.get("open_array") {
                ensure!(
                    matches!(mode, "value" | "const") && abi == "register",
                    "{}: unsupported open array ABI; use @ida",
                    d.name
                );
                let element = if element == "const" {
                    json!("TVarRec")
                } else {
                    element.clone()
                };
                params.push((name.into(), json!({"pointer":element})));
                params.push((format!("{name}_high"), json!("Integer")));
            } else {
                if matches!(mode, "var" | "out")
                    || mode == "const" && (typ.is_null() || self.const_aggregate_reference(&typ)?)
                {
                    typ = json!({"pointer":typ});
                }
                let stack_value = matches!(abi, "cdecl" | "stdcall" | "pascal")
                    && mode == "value"
                    && (self.floating(&typ)? || self.wide_integer(&typ)?)
                    || matches!(abi, "cdecl" | "stdcall")
                        && mode == "value"
                        && self.record_value(&typ)?
                    || abi == "register"
                        && matches!(mode, "value" | "const")
                        && self.method_pointer(&typ)?;
                ensure!(
                    self.scalar(&typ)?
                        || stack_value
                        || abi == "register" && mode == "value" && self.wide_integer(&typ)?,
                    "{}: complex native parameter; use @ida",
                    d.name
                );
                params.push((name.into(), typ));
            }
        }
        let names: BTreeSet<_> = params.iter().map(|(n, _)| n.to_lowercase()).collect();
        ensure!(
            names.len() == params.len(),
            "duplicate parameter after open-array expansion"
        );
        let ret = &d.data["result"];
        let float_return = self.floating(ret)?;
        let wide_return = self.wide_integer(ret)?;
        ensure!(
            ret.is_null()
                || ((self.scalar(ret)? || float_return || wide_return)
                    && !self.managed_return(ret)?),
            "{}: hidden/complex return ABI; use @ida",
            d.name
        );
        let result = self.ctype(ret, "")?;
        if abi == "register" {
            let registers = [
                ["al", "ax", "eax"],
                ["dl", "dx", "edx"],
                ["cl", "cx", "ecx"],
            ];
            let mut locations = BTreeMap::new();
            let mut stack = Vec::new();
            let mut next = 0;
            for (index, (_, typ)) in params.iter().enumerate() {
                let size = self.size(typ)?;
                ensure!(
                    [1, 2, 4].contains(&size)
                        || self.wide_integer(typ)?
                        || self.method_pointer(typ)?,
                    "{}: complex native parameter; use @ida",
                    d.name
                );
                if size <= 4 && next < 3 {
                    locations.insert(
                        index,
                        registers[next][match size {
                            1 => 0,
                            2 => 1,
                            _ => 2,
                        }]
                        .to_owned(),
                    );
                    next += 1;
                } else {
                    stack.push((index, size.max(4)));
                }
            }
            let mut offset = 0;
            for &(index, size) in stack.iter().rev() {
                locations.insert(index, format!("^{offset}"));
                offset += size;
            }
            let mut args = Vec::new();
            for (index, (name, typ)) in params.iter().enumerate() {
                args.push(self.ctype(typ, &format!("{name}@<{}>", locations[&index]))?);
            }
            let mut location = String::new();
            if !ret.is_null() {
                let loc = if float_return {
                    "st0"
                } else if wide_return {
                    "edx:eax"
                } else {
                    match self.size(ret)? {
                        1 => "al",
                        2 => "ax",
                        4 => "eax",
                        _ => bail!("hidden/complex return ABI; use @ida"),
                    }
                };
                location = format!("@<{loc}>");
            }
            let convention = if stack.is_empty() {
                "__usercall"
            } else {
                "__userpurge"
            };
            return Ok(Some(format!(
                "{result} {convention} {}{location}({});",
                d.name,
                if args.is_empty() {
                    "void".into()
                } else {
                    args.join(", ")
                }
            )));
        }
        let args = params
            .iter()
            .map(|(name, typ)| self.ctype(typ, name))
            .collect::<Result<Vec<_>>>()?;
        Ok(Some(format!(
            "{result} __{abi} {}({});",
            d.name,
            if args.is_empty() {
                "void".into()
            } else {
                args.join(", ")
            }
        )))
    }
    pub fn counted_stack(&mut self, d: &Decl, prototype: Option<&str>) -> Result<Value> {
        let spec = &*COUNTED_STACK;
        let captures = spec
            .captures(
                d.meta
                    .get("countedstack")
                    .and_then(Value::as_str)
                    .unwrap_or(""),
            )
            .context("@countedstack needs CountParameter:ElementType[:caller]")?;
        let prototype = prototype.context("@countedstack requires a typed routine")?;
        ensure!(
            !d.meta.contains_key("calls"),
            "@countedstack cannot have @calls"
        );
        let count = array(&d.data, "params")
            .iter()
            .find(|p| string(p, "name") == &captures[1])
            .context("count parameter not found")?;
        let pattern = format!(r"\b{}@<(eax|edx|ecx)>", regex::escape(&captures[1]));
        let regex = regex::Regex::new(&pattern)?;
        let register = regex
            .captures(prototype)
            .context("count must be in EAX/EDX/ECX")?;
        ensure!(
            matches!(string(count, "mode"), "value" | "const")
                && matches!(
                    count["type"].as_str().unwrap_or("").to_lowercase().as_str(),
                    "integer" | "cardinal" | "longint" | "longword" | "dword"
                )
                && prototype.contains("__usercall")
                && VARIADIC_TAIL.is_match(prototype)
                && !prototype.contains("@<^"),
            "@countedstack needs a variadic usercall with no fixed stack arguments"
        );
        let element = json!(&captures[2]);
        ensure!(
            self.scalar(&element)? && self.size(&element)? == 4,
            "@countedstack elements must be four-byte scalars or pointers"
        );
        let mut result = json!({"register":&register[1],"element":self.ctype(&element,"")?});
        if captures.get(3).is_some() {
            result["cleanup"] = json!("caller");
            result["order"] = json!("forward");
        }
        Ok(result)
    }
    pub fn virtual_slots(&mut self, d: &Decl) -> Result<BTreeMap<i64, Decl>> {
        if let Some(slots) = self.slots.get(&d.name) {
            return Ok(slots.clone());
        }
        ensure!(
            self.slots_active.insert(d.name.clone()),
            "recursive class inheritance: {}",
            d.name
        );
        let mut slots = BTreeMap::new();
        let mut parent = string(&d.data, "parent").to_owned();
        if d.kind == "interface"
            && !yes(&d.data, "opaque")
            && parent.is_empty()
            && !d.name.eq_ignore_ascii_case("iinterface")
        {
            parent = "IInterface".into();
        }
        if !parent.is_empty() {
            let parent = self.lookup(&parent)?;
            ensure!(
                parent.kind == d.kind && (d.kind != "interface" || !yes(&parent.data, "opaque")),
                "{}: inheritance needs a defined {}",
                d.name,
                d.kind
            );
            slots = self.virtual_slots(&parent)?;
        }
        let inherited: BTreeMap<_, _> = slots
            .iter()
            .map(|(off, m)| (string(&m.data, "method_name").to_lowercase(), *off))
            .collect();
        for method in methods(d)? {
            let name = string(&method.data, "method_name").to_lowercase();
            let mut offset = method.meta.get("slot").and_then(Value::as_i64);
            if d.kind == "interface" {
                offset = Some(slots.keys().next_back().copied().unwrap_or(-4) + 4);
            }
            if directive(&method, "override")
                && let Some(inherited) = inherited.get(&name)
            {
                ensure!(
                    offset.is_none_or(|off| off == *inherited),
                    "@slot disagrees with inherited slot"
                );
                offset = Some(*inherited);
            }
            let Some(offset) = offset else { continue };
            if let Some(previous) = slots.get(&offset) {
                ensure!(
                    yes(&previous.data, "class_method") == yes(&method.data, "class_method"),
                    "VMT override changes class/instance method kind"
                );
                ensure!(
                    string(&previous.data, "method_name").to_lowercase() == name
                        && directive(&method, "override"),
                    "duplicate/conflicting VMT slot {offset:#x}"
                );
            }
            ensure!(
                !slots.iter().any(
                    |(old, m)| string(&m.data, "method_name").to_lowercase() == name
                        && *old != offset
                ),
                "duplicate VMT member name {name}"
            );
            slots.insert(offset, method);
        }
        self.slots_active.remove(&d.name);
        self.slots.insert(d.name.clone(), slots.clone());
        Ok(slots)
    }
    pub fn vmt_layout(&mut self, d: &Decl, slots: &BTreeMap<i64, Decl>) -> Result<Value> {
        let name = format!("{}_VMT", d.name);
        ensure!(
            !self.names.contains(&name.to_lowercase()),
            "generated VMT name conflicts with {name}"
        );
        let (mut lines, mut fields, mut end) = (Vec::new(), Vec::new(), 0);
        let regex = &*VMT_HEAD;
        for (&offset, method) in slots {
            let proto = self
                .prototype(method)?
                .context("a known VMT slot requires a typed method")?;
            let head = regex
                .captures(&proto)
                .context("unsupported @ida head for a VMT slot")?;
            ensure!(
                head[2] == method.name,
                "unsupported @ida head for a VMT slot"
            );
            let member = string(&method.data, "method_name");
            ensure!(
                !member.starts_with("_gap_"),
                "VMT member names starting _gap_ are reserved"
            );
            let span = head.get(0).unwrap();
            let pointer = format!(
                "{}({} *{member}){}",
                &proto[..span.start()],
                &head[1],
                &proto[span.end()..]
            );
            if offset > end {
                lines.push(format!("unsigned __int8 _gap_{end:X}[{}];", offset - end));
            }
            lines.push(pointer);
            fields.push(json!({"name":member,"type":"Pointer","offset":offset}));
            end = offset + 4;
        }
        Ok(
            json!({"name":name,"kind":"record","source":d.source,"size":end,"fields":fields,"decl":format!("#pragma pack(push, 1)\nstruct {name} {{\n  {}\n}};\n#pragma pack(pop)",lines.join("\n  "))}),
        )
    }
}
