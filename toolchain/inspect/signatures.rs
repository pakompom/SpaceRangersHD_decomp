//! Narrow entry-register and stack-cleanup audit; findings are review candidates.
use crate::{
    native::x86::Decoder,
    util::{array, string},
};
use anyhow::Result;
use capstone::arch::x86::X86OperandType::{Mem, Reg};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
fn family(name: &str) -> &str {
    match name {
        "eax" | "ax" | "al" | "ah" => "eax",
        "edx" | "dx" | "dl" | "dh" => "edx",
        "ecx" | "cx" | "cl" | "ch" => "ecx",
        _ => name,
    }
}
pub fn audit(rows: &[Value]) -> Result<Value> {
    let decoder = Decoder::new()?;
    let mut counts = BTreeMap::<&str, usize>::new();
    let mut findings = Vec::new();
    for row in rows {
        *counts.entry("entries").or_default() += 1;
        if row.get("unavailable").is_some() {
            *counts.entry("unavailable").or_default() += 1;
            continue;
        }
        let bytes = crate::util::unhex(string(row, "prefix"))?;
        let ins = decoder.decode_prefix(row["ea"].as_u64().unwrap_or(0) as u32, &bytes)?;
        let framed = ins.len() >= 2 && ins[0].text == "push ebp" && ins[1].text == "mov ebp, esp";
        *counts.entry("ebp_frames").or_default() += usize::from(framed);
        let mut alive = BTreeSet::from(["eax".to_string(), "edx".into(), "ecx".into()]);
        let mut homes = Vec::new();
        if framed {
            for i in ins.iter().skip(2) {
                if i.call || i.jump || i.ret {
                    break;
                }
                if i.mnemonic == "mov"
                    && i.operands.len() == 2
                    && let (Mem(dest), Reg(src)) = (&i.operands[0].op_type, &i.operands[1].op_type)
                {
                    let register = decoder.reg_name(*src);
                    let f = family(&register);
                    if decoder.reg_name(dest.base()) == "ebp"
                        && dest.index().0 == 0
                        && dest.disp() < 0
                        && alive.contains(f)
                    {
                        homes.push(json!({"ea":i.address,"register":register,"family":f,"width":i.operands[1].size,"frame_offset":dest.disp()}));
                    }
                }
                for reg in &i.written {
                    alive.remove(family(&decoder.reg_name(*reg)));
                }
                for op in &i.operands {
                    if op.access.is_some_and(|a| a.is_writable())
                        && let Reg(reg) = op.op_type
                    {
                        alive.remove(family(&decoder.reg_name(reg)));
                    }
                }
            }
        }
        *counts
            .entry("entries_with_observed_register_homes")
            .or_default() += usize::from(!homes.is_empty());
        let cleanup: BTreeSet<_> = array(row, "returns")
            .iter()
            .filter_map(|r| r[1].as_u64())
            .collect();
        *counts.entry("entries_with_one_cleanup_value").or_default() +=
            usize::from(cleanup.len() == 1);
        let Some(signature) = row.get("type") else {
            *counts.entry("without_header_signature").or_default() += 1;
            continue;
        };
        *counts.entry("typed_entries").or_default() += 1;
        let args: BTreeMap<_, _> = array(signature, "args")
            .iter()
            .filter(|a| a["stack"].is_null())
            .map(|a| (family(string(a, "loc")), a))
            .collect();
        let mut problems = Vec::new();
        for home in homes {
            match args.get(string(&home,"family")){
            None=>problems.push(json!({"kind":"undeclared_register","observation":home})),
            Some(arg) if arg["size"]!=home["width"] || ["ah","dh","ch"].contains(&string(&home,"register"))=>problems.push(json!({"kind":"register_width_or_slice","observation":home,"declaration":arg})),_=>(),
        }
        }
        if cleanup.len() == 1 && row["countedstack"] != true {
            let expected = row["stackpop"].as_u64().or_else(|| {
                (signature["callee_cleans"] == true).then(|| {
                    array(signature, "args")
                        .iter()
                        .filter_map(|a| {
                            a["stack"]
                                .as_u64()
                                .map(|s| s + a["size"].as_u64().unwrap_or(0).div_ceil(4).max(1) * 4)
                        })
                        .max()
                        .unwrap_or(0)
                })
            });
            if let Some(expected) = expected
                && Some(&expected) != cleanup.first()
            {
                problems.push(json!({"kind":"stack_cleanup","declared":expected,"observed":cleanup.first(),"returns":row["returns"]}));
            }
        }
        if !problems.is_empty() {
            findings.push(json!({"ea":row["ea"],"name":row["name"],"source":row["source"],"problems":problems}));
        }
    }
    Ok(json!({"counts":counts,"findings":findings}))
}
