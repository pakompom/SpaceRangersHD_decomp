use super::*;
impl Compiler {
    pub fn layout(&mut self, d: &Decl) -> Result<std::sync::Arc<Value>> {
        if let Some(layout) = self.layouts.get(&d.name) {
            return Ok(layout.clone());
        }
        ensure!(
            self.active.insert(d.name.clone()),
            "recursive inline type {}",
            d.name
        );
        let result = if d.kind == "enum" {
            let size = d
                .meta
                .get("size")
                .and_then(Value::as_i64)
                .context("enum needs @size")?;
            ensure!(
                [1, 2, 4, 8].contains(&size),
                "enum needs @size 1, 2, 4, or 8"
            );
            let members = array(&d.data, "members");
            let names: BTreeSet<_> = members
                .iter()
                .map(|m| m[0].as_str().unwrap_or("").to_lowercase())
                .collect();
            ensure!(
                names.len() == members.len(),
                "duplicate enum member in {}",
                d.name
            );
            for member in members {
                let value = member[1].as_i64().context("invalid enum value")?;
                ensure!(
                    value >= 0 && (size == 8 || value < (1i64 << (size * 8))),
                    "enum value outside unsigned {size}-byte storage in {}",
                    d.name
                );
            }
            let body = members
                .iter()
                .map(|m| format!("{} = {}", m[0].as_str().unwrap(), m[1]))
                .collect::<Vec<_>>()
                .join(", ");
            json!({"size":size,"decl":format!("enum {} : unsigned __int{} {{ {body} }};",d.name,size*8)})
        } else if d.kind == "alias" {
            let typ = &d.data["type"];
            let (size, text) = if let Some(set) = typ.get("set") {
                let size = d
                    .meta
                    .get("size")
                    .and_then(Value::as_i64)
                    .context("sets need explicit @size")?;
                let members = if set.is_object() {
                    let lo = integer(set, "lower")?;
                    let hi = integer(set, "upper")?;
                    let mut storage = hi / 8 + 1;
                    if storage == 3 {
                        storage = 4
                    }
                    ensure!(
                        lo == 0 && hi >= lo && hi <= 255 && size == storage,
                        "ordinal sets require a zero-based range fitting @size (at most 32 bytes)"
                    );
                    (lo..=hi)
                        .map(|i| (format!("Bit{i}"), i))
                        .collect::<Vec<_>>()
                } else {
                    let base = self.lookup(set.as_str().context("invalid set element")?)?;
                    ensure!(
                        base.kind == "enum" && [1, 2, 4, 8].contains(&size),
                        "sets require an enum and explicit scalar @size"
                    );
                    array(&base.data, "members")
                        .iter()
                        .map(|m| (m[0].as_str().unwrap().to_owned(), m[1].as_i64().unwrap()))
                        .collect()
                };
                ensure!(
                    members.iter().all(|(_, v)| *v >= 0 && *v < size * 8),
                    "enum ordinal exceeds set storage"
                );
                let text = if [1, 2, 4, 8].contains(&size) {
                    let body = members
                        .iter()
                        .map(|(n, v)| format!("{}_{n} = {}", d.name, 1u128 << v))
                        .collect::<Vec<_>>()
                        .join(", ");
                    format!(
                        "enum __bitmask {} : unsigned __int{} {{ {body} }};",
                        d.name,
                        size * 8
                    )
                } else {
                    format!("typedef unsigned __int8 {}[{size}];", d.name)
                };
                (Some(size), text)
            } else {
                let target = typ
                    .as_str()
                    .and_then(|n| self.types.get(&n.to_lowercase()))
                    .cloned();
                let incomplete = if let Some(target) =
                    target.filter(|d| matches!(d.kind.as_str(), "record" | "alias"))
                {
                    self.layout(&target)?["size"].is_null()
                } else {
                    false
                };
                let size = if incomplete {
                    None
                } else {
                    Some(self.size(typ)?)
                };
                if let Some(stated) = d.meta.get("size").and_then(Value::as_i64) {
                    ensure!(
                        size == Some(stated),
                        "{}: alias @size disagrees with underlying type",
                        d.name
                    );
                }
                (size, format!("typedef {};", self.ctype(typ, &d.name)?))
            };
            json!({"size":size,"decl":text})
        } else if d.kind == "interface" && !yes(&d.data, "opaque") {
            let slots = self.virtual_slots(d)?;
            let fields = if slots.is_empty() {
                vec![]
            } else {
                vec![json!({"name":"Vmt","type":{"vmt":format!("{}_VMT",d.name)},"offset":0})]
            };
            json!({"size":4,"fields":fields,"decl":if slots.is_empty(){format!("struct {};",d.name)}else{format!("struct {} {{ {}_VMT *Vmt; }};",d.name,d.name)}})
        } else if yes(&d.data, "opaque") {
            json!({"size":null,"fields":[],"decl":format!("struct {};",d.name)})
        } else {
            let (mut fields, mut minimum) = (Vec::new(), 0);
            let parent = string(&d.data, "parent");
            if !parent.is_empty() {
                let pd = self.lookup(parent)?;
                ensure!(
                    d.kind == "class" && pd.kind == "class" && !yes(&pd.data, "opaque"),
                    "{}: inheritance needs a defined class prefix",
                    d.name
                );
                let parent = self.layout(&pd)?;
                fields = array(&parent, "fields").to_vec();
                minimum = integer(&parent, "size")?;
            } else if d.kind == "class" {
                fields.push(json!({"name":"Vmt","type":"Pointer","offset":0}));
                minimum = 4;
            }
            if d.kind == "class" && !self.virtual_slots(d)?.is_empty() {
                for field in &mut fields {
                    if string(field, "name") == "Vmt" && field["offset"] == 0 {
                        field["type"] = json!({"vmt":format!("{}_VMT",d.name)});
                    }
                }
            }
            for field in array(&d.data, "fields") {
                ensure!(
                    integer(field, "offset")? >= minimum,
                    "{}: field overlaps inherited prefix or VMT",
                    d.name
                );
                fields.push(field.clone());
            }
            fields.sort_by_key(|f| f["offset"].as_i64().unwrap_or(-1));
            let names: BTreeSet<_> = fields
                .iter()
                .map(|f| string(f, "name").to_lowercase())
                .collect();
            ensure!(
                names.len() == fields.len(),
                "duplicate/inherited field name in {}",
                d.name
            );
            for method in methods(d)? {
                ensure!(
                    !names.contains(&string(&method.data, "method_name").to_lowercase()),
                    "method conflicts with field in {}",
                    d.name
                );
            }
            let (mut lines, mut end) = (Vec::new(), 0);
            for field in &fields {
                let off = integer(field, "offset")?;
                let name = string(field, "name");
                ensure!(
                    !name.starts_with("_gap_"),
                    "field names starting _gap_ are reserved"
                );
                ensure!(off >= end, "{}.{name}: overlapping offset {off:#x}", d.name);
                if off > end {
                    lines.push(format!("unsigned __int8 _gap_{end:X}[{}];", off - end));
                }
                lines.push(format!("{};", self.ctype(&field["type"], name)?));
                end = off + self.size(&field["type"])?;
            }
            let size = if let Some(size) = d.meta.get("size").and_then(Value::as_i64) {
                size
            } else {
                ensure!(
                    d.meta
                        .get("partial")
                        .and_then(Value::as_bool)
                        .unwrap_or(false),
                    "{}: specify @size or @partial",
                    d.name
                );
                end.max(minimum)
            };
            ensure!(
                size >= end && size >= minimum && size > 0,
                "{}: @size does not contain fields/base",
                d.name
            );
            if size > end {
                lines.push(format!("unsigned __int8 _gap_{end:X}[{}];", size - end));
            }
            json!({"size":size,"fields":fields,"decl":format!("#pragma pack(push, 1)\nstruct {} {{\n  {}\n}};\n#pragma pack(pop)",d.name,lines.join("\n  "))})
        };
        let result = std::sync::Arc::new(result);
        self.active.remove(&d.name);
        self.layouts.insert(d.name.clone(), result.clone());
        Ok(result)
    }
}
