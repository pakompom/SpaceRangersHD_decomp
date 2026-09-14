use super::*;
impl Compiler {
    fn validate_arrays(&mut self, typ: &Value) -> Result<()> {
        if let Some(element) = typ.get("dynamic_array") {
            self.size(element)?;
        }
        for key in ["array", "dynamic_array", "pointer", "open_array"] {
            if let Some(child) = typ.get(key) {
                self.validate_arrays(child)?;
            }
        }
        Ok(())
    }
    fn dependencies(&self, typ: &Value) -> Result<Vec<Decl>> {
        if typ.is_object() {
            if let Some(signature) = typ.get("callable") {
                let mut result = Vec::new();
                for p in array(signature, "params") {
                    if !p["type"].is_null() {
                        result.extend(self.dependencies(&p["type"])?);
                    }
                }
                if !signature["result"].is_null() {
                    result.extend(self.dependencies(&signature["result"])?);
                }
                return Ok(result);
            }
            if let Some(element) = typ.get("array") {
                return self.dependencies(element);
            }
            if let Some(element) = typ.get("dynamic_array") {
                return self.dependencies(&json!({"pointer":element}));
            }
            if let Some(target) = typ.get("pointer") {
                if let Some(name) = target.as_str().filter(|n| builtin(n).is_none()) {
                    let d = self.lookup(name)?;
                    return Ok(if matches!(d.kind.as_str(), "alias" | "enum") {
                        vec![(*d).clone()]
                    } else {
                        vec![]
                    });
                }
                return self.dependencies(target);
            }
            return Ok(vec![]);
        }
        let Some(name) = typ.as_str() else {
            return Ok(vec![]);
        };
        if builtin(name).is_some() {
            return Ok(vec![]);
        }
        let d = self.lookup(name)?;
        Ok(if matches!(d.kind.as_str(), "class" | "interface") {
            vec![]
        } else {
            vec![(*d).clone()]
        })
    }
    fn visit_type(
        &self,
        d: &Decl,
        active: &mut BTreeSet<String>,
        done: &mut BTreeSet<String>,
        ordered: &mut Vec<Value>,
    ) -> Result<()> {
        if done.contains(&d.name) {
            return Ok(());
        }
        ensure!(
            active.insert(d.name.clone()),
            "cyclic typedef dependency: {}",
            d.name
        );
        let layout = &self.layouts[&d.name];
        let mut types = array(layout, "fields")
            .iter()
            .map(|f| f["type"].clone())
            .collect::<Vec<_>>();
        if d.kind == "alias" {
            types.push(d.data["type"].clone());
        }
        for typ in types {
            for dep in self.dependencies(&typ)? {
                self.visit_type(&dep, active, done, ordered)?;
            }
        }
        active.remove(&d.name);
        done.insert(d.name.clone());
        let mut item = (**layout).clone();
        item["name"] = json!(d.name);
        item["kind"] = json!(d.kind);
        item["source"] = json!(d.source);
        ordered.push(item);
        Ok(())
    }
    pub fn build(&mut self) -> Result<Value> {
        let types: Vec<_> = self
            .type_order
            .iter()
            .map(|n| self.types[n].clone())
            .collect();
        for d in &types {
            self.layout(d)?;
        }
        for d in self.decls.clone() {
            if let Some(typ) = d.data.get("type") {
                self.validate_arrays(typ)?;
            }
            for kind in ["fields", "params"] {
                for member in array(&d.data, kind) {
                    self.validate_arrays(&member["type"])?;
                }
            }
            self.validate_arrays(&d.data["result"])?;
        }
        let (mut ordered, mut active, mut done) = (Vec::new(), BTreeSet::new(), BTreeSet::new());
        for d in &types {
            self.visit_type(d, &mut active, &mut done, &mut ordered)?;
        }
        let mut vmts = Vec::new();
        for d in &types {
            if matches!(d.kind.as_str(), "class" | "interface") {
                let slots = self.virtual_slots(d)?;
                if !slots.is_empty() {
                    vmts.push(self.vmt_layout(d, &slots)?);
                }
            }
        }
        ordered.extend(vmts.clone());
        let (mut functions, mut globals, mut virtual_calls) = (Vec::new(), Vec::new(), Vec::new());
        for d in self.decls.clone() {
            let mut common = Value::Object(d.meta.clone());
            common["name"] = json!(d.name);
            common["source"] = json!(d.source);
            if d.kind == "routine" {
                if yes(&d.data, "interface_method") || directive(&d, "abstract") {
                    if d.meta.contains_key("calls") {
                        common["decl"] = json!(self.prototype(&d)?);
                        virtual_calls.push(common);
                    }
                    continue;
                }
                let prototype = self.prototype(&d)?;
                if d.meta.contains_key("countedstack") {
                    common["countedstack"] = self.counted_stack(&d, prototype.as_deref())?;
                }
                common["decl"] = json!(prototype);
                functions.push(common);
            } else if d.kind == "global" || d.kind == "constant" && d.meta.contains_key("addr") {
                common["decl"] = json!(format!("{};", self.ctype(&d.data["type"], &d.name)?));
                common["size"] = json!(self.size(&d.data["type"])?);
                globals.push(common);
            }
        }
        let mut sorted = globals.iter().collect::<Vec<_>>();
        sorted.sort_by_key(|g| g["addr"].as_u64().unwrap_or(0));
        let mut previous: Option<&Value> = None;
        for item in sorted {
            let addr = integer(item, "addr")?;
            let size = integer(item, "size")?;
            ensure!(
                size > 0 && addr.checked_add(size).is_some_and(|end| end <= 0x100000000),
                "global exceeds the Win32 address space"
            );
            if let Some(previous) = previous {
                ensure!(
                    addr >= integer(previous, "addr")? + integer(previous, "size")?,
                    "global {} overlaps {}",
                    string(item, "name"),
                    string(previous, "name")
                );
            }
            previous = Some(item);
        }
        let mut forwards = types
            .iter()
            .filter(|d| matches!(d.kind.as_str(), "class" | "record" | "interface"))
            .map(|d| format!("struct {};", d.name))
            .collect::<Vec<_>>()
            .join("\n");
        for vmt in vmts {
            forwards.push_str(&format!("\nstruct {};", string(&vmt, "name")));
        }
        Ok(
            json!({"version":1,"image_base":0x400000,"types":ordered,"forwards":forwards,"functions":functions,"globals":globals,"virtual_calls":virtual_calls}),
        )
    }
}
