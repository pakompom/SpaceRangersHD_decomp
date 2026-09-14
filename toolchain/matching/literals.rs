//! Infer literal bounds only from proved instruction patterns and ABI contracts.
use crate::{
    matching::symbols::Symbols,
    native::image::{Image, Import, ImportName},
    native::x86::{Decoder, Instruction},
};
use capstone::arch::x86::{X86OperandType::*, X86Reg::*};
use std::collections::{BTreeMap, BTreeSet};
pub fn bitsets(decoded: &[Instruction], decoder: &Decoder) -> BTreeMap<u32, usize> {
    let targets = targets(decoded);
    let mut widths = BTreeMap::new();
    for seq in decoded.windows(4) {
        let (bound, guard, mask, ins) = (&seq[0], &seq[1], &seq[2], &seq[3]);
        if ins.mnemonic != "bt" || ins.operands.len() != 2 {
            continue;
        }
        let (Mem(memory), Reg(bit)) = (
            ins.operands[0].op_type.clone(),
            ins.operands[1].op_type.clone(),
        ) else {
            continue;
        };
        if memory.base().0 != 0
            || memory.index().0 != 0
            || memory.segment().0 != 0
            || ins.operands[1].size != 4
        {
            continue;
        }
        if bound.mnemonic != "cmp"
            || guard.mnemonic != "ja"
            || mask.mnemonic != "and"
            || seq.windows(2).any(|p| p[0].end() != p[1].address)
            || targets.range(guard.address..ins.end()).next().is_some()
        {
            continue;
        }
        if bound.operands.len() != 2 || mask.operands.len() != 2 {
            continue;
        }
        let (Reg(low), Imm(maximum), Reg(dest), Imm(index_mask)) = (
            bound.operands[0].op_type.clone(),
            bound.operands[1].op_type.clone(),
            mask.operands[0].op_type.clone(),
            mask.operands[1].op_type.clone(),
        ) else {
            continue;
        };
        if dest != bit
            || mask.operands[0].size != 4
            || !matches!(guard.operands[0].op_type.clone(),Imm(a) if a==ins.end() as i64)
        {
            continue;
        }
        let name = decoder.reg_name(bit);
        if !["eax", "ebx", "ecx", "edx"].contains(&name.as_str()) {
            continue;
        }
        let lowname = decoder.reg_name(low);
        if lowname != name && lowname != format!("{}l", name.chars().nth(1).unwrap()) {
            continue;
        }
        if 0 <= maximum
            && maximum <= index_mask
            && index_mask <= 255
            && index_mask & (index_mask + 1) == 0
        {
            widths.insert(ins.address, ((maximum + 8) / 8) as usize);
        }
    }
    widths
}
fn targets(decoded: &[Instruction]) -> BTreeSet<u32> {
    decoded
        .iter()
        .filter(|i| i.jump)
        .flat_map(|i| {
            i.operands.iter().filter_map(|o| {
                if let Imm(a) = o.op_type.clone() {
                    Some(a as u32)
                } else {
                    None
                }
            })
        })
        .collect()
}
fn import_contract(import: Option<&Import>) -> (Vec<(usize, usize)>, Option<usize>) {
    let Some(Import {
        dll,
        name: ImportName::Name(name),
    }) = import
    else {
        return (Vec::new(), None);
    };
    let (indices, count): (&[usize], usize) = match (dll.as_str(), name.as_str()) {
        (
            "kernel32.dll",
            "LoadLibraryA" | "LoadLibraryW" | "GetModuleHandleA" | "GetModuleHandleW",
        ) => (&[0], 1),
        ("kernel32.dll", "OpenEventA") => (&[2], 3),
        ("kernel32.dll", "CreateEventA") => (&[3], 4),
        ("user32.dll", "MessageBoxA") => (&[1, 2], 4),
        ("kernel32.dll", "GetProcAddress") => (&[1], 2),
        ("kernel32.dll", "CopyFileA" | "CopyFileW") => (&[0, 1], 3),
        ("kernel32.dll", "FindFirstFileA" | "FindFirstFileW") => (&[0], 2),
        ("kernel32.dll", "GetVolumeInformationA" | "GetVolumeInformationW") => (&[0], 8),
        ("user32.dll", "SetWindowTextA" | "SetWindowTextW") => (&[1], 2),
        ("user32.dll", "RegisterWindowMessageA" | "RegisterWindowMessageW") => (&[0], 1),
        ("user32.dll", "LoadIconA" | "LoadIconW") => (&[1], 2),
        ("shell32.dll", "ShellExecuteA" | "ShellExecuteW") => (&[1, 2, 3, 4], 6),
        _ => return (Vec::new(), None),
    };
    let width = if name.ends_with('W') { 2 } else { 1 };
    (indices.iter().map(|i| (*i, width)).collect(), Some(count))
}
fn family(decoder: &Decoder, reg: capstone::RegId) -> String {
    let name = decoder.reg_name(reg);
    for c in ['a', 'b', 'c', 'd'] {
        if [
            format!("e{c}x"),
            format!("{c}x"),
            format!("{c}l"),
            format!("{c}h"),
        ]
        .contains(&name)
        {
            return format!("e{c}x");
        }
    }
    name
}
fn string_width(
    widths: &mut BTreeMap<u32, usize>,
    producers: &BTreeMap<u32, &Instruction>,
    image: &Image,
    producer: Option<u32>,
    character_width: usize,
) {
    let Some(producer) = producer else { return };
    let ins = producers[&producer];
    let Some(Imm(literal)) = ins.operands.last().map(|o| o.op_type.clone()) else {
        return;
    };
    let literal = literal as u32;
    if !image.constant_storage(literal, true) {
        return;
    }
    let data = image.read(literal, 65536);
    for (index, chunk) in data.chunks_exact(character_width).enumerate() {
        if chunk.iter().all(|b| *b == 0) {
            let size = (index + 1) * character_width;
            if !image.has_relocation(literal, size) {
                widths.insert(producer, size);
            }
            return;
        }
    }
}
pub fn arguments(
    decoded: &[Instruction],
    symbols: &Symbols,
    image_id: usize,
    decoder: &Decoder,
) -> (BTreeMap<u32, usize>, Vec<(u32, u32)>) {
    let image = symbols.images[image_id];
    let mut calls = BTreeMap::new();
    for ins in decoded.iter().filter(|i| i.call && !i.operands.is_empty()) {
        let (address, import) = match ins.operands[0].op_type.clone() {
            Imm(a) => (Some(a as u32), image.imported_target(a as u32)),
            Mem(m) if m.base().0 == 0 && m.index().0 == 0 => {
                (None, image.imports.get(&(m.disp() as u32)))
            }
            _ => continue,
        };
        let target = address.and_then(|a| {
            if image_id == 0 {
                Some(a)
            } else {
                symbols.linked.get(&a).copied()
            }
        });
        let (strings, mut stack_count) = import_contract(import);
        if target.is_some_and(|a| symbols.literal_calls.contains(&a)) || !strings.is_empty() {
            if stack_count.is_none()
                && target.is_some_and(|a| symbols.evidence.register_only.contains(&a))
            {
                stack_count = Some(0);
            }
            calls.insert(ins.address, (target, strings, stack_count));
        }
    }
    let mut widths = BTreeMap::new();
    if calls.is_empty() {
        return (widths, Vec::new());
    }
    let targets = targets(decoded);
    let mut pending: BTreeMap<String, u32> = BTreeMap::new();
    let mut stack: Vec<Option<u32>> = Vec::new();
    let producers = decoded
        .iter()
        .map(|i| (i.address, i))
        .collect::<BTreeMap<_, _>>();
    let mut previous = None;
    let mut count = 0;
    for ins in decoded {
        if targets.contains(&ins.address) || previous != Some(ins.address) {
            pending.clear();
            stack.clear();
            count = 0;
        }
        previous = Some(ins.end());
        if ins.call {
            let mut stack_count = None;
            if let Some((target, strings, slots)) = calls.get(&ins.address) {
                stack_count = *slots;
                for &(index, width) in strings {
                    string_width(
                        &mut widths,
                        &producers,
                        image,
                        stack.len().checked_sub(1 + index).and_then(|i| stack[i]),
                        width,
                    );
                }
                if let Some(target) = target {
                    if let Some(strings) = symbols.evidence.strings.get(target) {
                        for (reg, &width) in strings {
                            string_width(
                                &mut widths,
                                &producers,
                                image,
                                pending.get(reg).copied(),
                                width,
                            );
                        }
                    }
                    if let Some(literals) = symbols.evidence.literals.get(target) {
                        for (reg, &width) in literals {
                            if let Some(&producer) = pending.get(reg) {
                                widths.insert(producer, width);
                            }
                        }
                    }
                    if (symbols.short_copies.contains(target)
                        || symbols.short_comparisons.contains(target) && count == 3)
                        && let Some(&producer) = pending.get("edx")
                        && let Imm(literal) = producers[&producer].operands[1].op_type.clone()
                    {
                        let literal = literal as u32;
                        if image.constant_storage(literal, true)
                            && let Some(&n) = image.read(literal, 1).first()
                        {
                            widths.insert(producer, n as usize + 1);
                        }
                    }
                }
            }
            pending.clear();
            if let Some(n) = stack_count.filter(|n| *n <= stack.len()) {
                stack.truncate(stack.len() - n);
            } else {
                stack.clear();
            }
            count = 0;
            continue;
        }
        if ins.jump || ins.ret {
            pending.clear();
            stack.clear();
            count = 0;
            continue;
        }
        let written = ins
            .written
            .iter()
            .map(|r| family(decoder, *r))
            .collect::<BTreeSet<_>>();
        if ins.mnemonic == "push" && ins.operands[0].size == 4 {
            let producer = match ins.operands[0].op_type.clone() {
                Imm(_) if image.relocated(ins.address + ins.imm_offset as u32) => Some(ins.address),
                Reg(r) => pending.get(&family(decoder, r)).copied(),
                _ => None,
            };
            stack.push(producer);
        } else if written.contains("esp") {
            stack.clear();
        }
        let previous_count = count;
        if written.contains("eax") || written.contains("ecx") {
            count = 0;
        }
        if let Some(Reg(reg)) = ins.operands.first().map(|o| o.op_type.clone()) {
            let dest = decoder.reg_name(reg);
            let other = ins.operands.get(1);
            if ins.mnemonic=="xor"&&dest=="ecx"&&other.is_some_and(|o|o.op_type.clone()==Reg(reg)){count=1;}
            else if ["mov","movzx"].contains(&ins.mnemonic.as_str())&&ins.operands.len()==2&&other.is_some_and(|o|o.size==1&&matches!(o.op_type.clone(),Mem(m) if m.base().0 as u32==X86_REG_EAX&&m.index().0==0&&m.disp()==0&&m.segment().0==0))&& (ins.mnemonic=="movzx"&&dest=="ecx"||ins.mnemonic=="mov"&&dest=="cl"&&previous_count==1){count=2;}
            else if ins.mnemonic=="inc"&&dest=="ecx"&&previous_count==2{count=3;}
        }
        for reg in written {
            pending.remove(&reg);
        }
        if ins.mnemonic == "mov"
            && ins.operands.len() == 2
            && ins.operands[0].size == 4
            && image.relocated(ins.address + ins.imm_offset as u32)
            && let (Reg(reg), Imm(_)) = (
                ins.operands[0].op_type.clone(),
                ins.operands[1].op_type.clone(),
            )
        {
            pending.insert(family(decoder, reg), ins.address);
        }
    }
    let mut known: BTreeMap<u32, BTreeSet<usize>> = BTreeMap::new();
    let mut origins = BTreeMap::new();
    let mut aliases = Vec::new();
    for (&producer, &width) in &widths {
        if let Imm(literal) = producers[&producer]
            .operands
            .last()
            .unwrap()
            .op_type
            .clone()
        {
            known.entry(literal as u32).or_default().insert(width);
            origins.entry(literal as u32).or_insert(producer);
        }
    }
    for ins in decoded {
        if let Some(Imm(literal)) = ins.operands.last().map(|o| o.op_type.clone()) {
            let literal = literal as u32;
            if image.relocated(ins.address + ins.imm_offset as u32)
                && !widths.contains_key(&ins.address)
                && let Some(sizes) = known.get(&literal).filter(|v| v.len() == 1)
            {
                widths.insert(ins.address, *sizes.first().unwrap());
                let origin = producers[&origins[&literal]];
                aliases.push((
                    ins.address + ins.imm_offset as u32,
                    origin.address + origin.imm_offset as u32,
                ));
            }
        }
    }
    (widths, aliases)
}
