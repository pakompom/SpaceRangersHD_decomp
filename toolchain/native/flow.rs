//! Native control-flow ownership, Delphi EH tables and dormant O− code.
//!
//! The walk proves which bytes are instructions or metadata. It never treats
//! successful disassembly alone as evidence that an indirect target is valid.

use crate::{
    native::image::Image,
    native::x86::{Decoder, Instruction},
};
use anyhow::Result;
use capstone::{
    RegId,
    arch::x86::{X86Insn::*, X86Operand, X86OperandType::*, X86Reg::*},
};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};

#[derive(Default, Deserialize)]
pub struct Symbols {
    pub names: BTreeMap<u32, String>,
    pub terminal_calls: BTreeSet<u32>,
}

pub trait Resolver {
    fn name(&self, address: u32) -> String;
    fn terminal(&self, address: u32) -> bool;
}
impl Resolver for Symbols {
    fn terminal(&self, address: u32) -> bool {
        self.terminal_calls.contains(&address)
    }
    fn name(&self, address: u32) -> String {
        self.names
            .get(&address)
            .map(|n| n.to_lowercase())
            .unwrap_or_default()
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Table {
    pub kind: String,
    pub bytes: Vec<u8>,
}

pub struct Flow {
    pub instructions: Vec<Instruction>,
    pub issues: Vec<String>,
    pub tables: BTreeMap<u32, Vec<u8>>,
    pub cases: BTreeMap<u32, Table>,
}

fn imm(ins: &Instruction) -> Option<u32> {
    match ins.operands.first()?.op_type {
        Imm(a) => Some(a as u32),
        _ => None,
    }
}
fn reg(op: &X86Operand, r: u32) -> bool {
    matches!(op.op_type, Reg(id) if id.0 as u32 == r)
}
fn low_byte(r: RegId) -> Option<u32> {
    match r.0 as u32 {
        X86_REG_EAX => Some(X86_REG_AL),
        X86_REG_EBX => Some(X86_REG_BL),
        X86_REG_ECX => Some(X86_REG_CL),
        X86_REG_EDX => Some(X86_REG_DL),
        _ => None,
    }
}
fn one(decoder: &Decoder, image: &Image, address: u32) -> Result<Option<Instruction>> {
    Ok(decoder
        .decode_prefix(address, image.read(address, 5))?
        .into_iter()
        .next())
}

/// DCC32 keeps the body after an unconditional source Exit even in an
/// optimized, frameless routine. Prove the entry jump skips to the matching
/// callee-save epilogue; a decodable gap or an arbitrary forward jump alone
/// does not establish dormant Pascal ownership.
fn frameless_entry_exit(start: u32, skip: &Instruction, seen: &BTreeMap<u32, Instruction>) -> bool {
    if !skip.is(X86_INS_JMP) {
        return false;
    }
    let Some(mut epilogue) = imm(skip).filter(|target| *target > skip.end()) else {
        return false;
    };
    let mut saved = Vec::new();
    let mut assigned = BTreeSet::new();
    let mut cursor = start;
    while cursor < skip.address {
        let Some(ins) = seen.get(&cursor) else {
            return false;
        };
        if ins.is(X86_INS_PUSH) && assigned.is_empty() {
            let Some(Reg(register)) = ins.operands.first().map(|op| &op.op_type) else {
                return false;
            };
            if ![X86_REG_EBX, X86_REG_ESI, X86_REG_EDI].contains(&(register.0 as u32))
                || saved.contains(register)
            {
                return false;
            }
            saved.push(*register);
        } else if ins.is(X86_INS_MOV) && ins.operands.len() == 2 {
            let (Reg(destination), Reg(source)) =
                (&ins.operands[0].op_type, &ins.operands[1].op_type)
            else {
                return false;
            };
            if !saved.contains(destination)
                || ![X86_REG_EAX, X86_REG_EDX, X86_REG_ECX].contains(&(source.0 as u32))
                || !assigned.insert(destination.0)
            {
                return false;
            }
        } else {
            return false;
        }
        cursor = ins.end();
    }
    if cursor != skip.address || saved.is_empty() || assigned.is_empty() {
        return false;
    }
    for register in saved.iter().rev() {
        let Some(ins) = seen.get(&epilogue) else {
            return false;
        };
        if !ins.is(X86_INS_POP)
            || !ins
                .operands
                .first()
                .is_some_and(|op| reg(op, register.0 as u32))
        {
            return false;
        }
        epilogue = ins.end();
    }
    seen.get(&epilogue)
        .is_some_and(|ins| ins.ret && ins.bytes == [0xc3])
}

/// A frameless Delphi routine can keep disabled statements after an Exit in
/// the middle of its body. Its callee-save prologue and fixed local allocation
/// must agree exactly with the skipped-to restore sequence before ownership of
/// that dormant island can be considered.
fn frameless_local_frame_exit(
    start: u32,
    skip: &Instruction,
    seen: &BTreeMap<u32, Instruction>,
) -> bool {
    if !skip.is(X86_INS_JMP) {
        return false;
    }
    let Some(mut epilogue) = imm(skip).filter(|target| *target > skip.end()) else {
        return false;
    };
    let mut saved = Vec::new();
    let mut cursor = start;
    while let Some(ins) = seen.get(&cursor) {
        if !ins.is(X86_INS_PUSH) {
            break;
        }
        let Some(Reg(register)) = ins.operands.first().map(|op| &op.op_type) else {
            return false;
        };
        if ![X86_REG_EBX, X86_REG_ESI, X86_REG_EDI].contains(&(register.0 as u32))
            || saved.contains(register)
        {
            return false;
        }
        saved.push(*register);
        cursor = ins.end();
    }
    let Some(allocation) = seen.get(&cursor) else {
        return false;
    };
    if saved.is_empty()
        || allocation.operands.len() != 2
        || !reg(&allocation.operands[0], X86_REG_ESP)
    {
        return false;
    }
    let Imm(value) = allocation.operands[1].op_type else {
        return false;
    };
    let value = value as i32 as i64;
    let locals = if allocation.is(X86_INS_ADD) {
        -value
    } else if allocation.is(X86_INS_SUB) {
        value
    } else {
        return false;
    };
    if !(4..=4096).contains(&locals) || locals % 4 != 0 || allocation.end() > skip.address {
        return false;
    }
    let mut remaining = locals;
    while remaining > 0 {
        let Some(ins) = seen.get(&epilogue) else {
            return false;
        };
        if ins.is(X86_INS_ADD)
            && ins.operands.len() == 2
            && reg(&ins.operands[0], X86_REG_ESP)
            && matches!(ins.operands[1].op_type, Imm(n) if n == remaining)
        {
            remaining = 0;
        } else if ins.is(X86_INS_POP)
            && ins
                .operands
                .first()
                .is_some_and(|op| reg(op, X86_REG_ECX) || reg(op, X86_REG_EDX))
        {
            remaining -= 4;
        } else {
            return false;
        }
        epilogue = ins.end();
    }
    for register in saved.iter().rev() {
        let Some(ins) = seen.get(&epilogue) else {
            return false;
        };
        if !ins.is(X86_INS_POP)
            || !ins
                .operands
                .first()
                .is_some_and(|op| reg(op, register.0 as u32))
        {
            return false;
        }
        epilogue = ins.end();
    }
    seen.get(&epilogue)
        .is_some_and(|ins| ins.ret && ins.bytes == [0xc3])
}

fn loop_test_targets(seen: &BTreeMap<u32, Instruction>, mut test: u32, target: u32) -> bool {
    // Follow one already decoded condition block, including calls used by the test.
    for _ in 0..128 {
        let Some(ins) = seen.get(&test) else {
            return false;
        };
        if ins.jump {
            return !ins.is(X86_INS_JMP) && imm(ins) == Some(target);
        }
        if ins.ret {
            return false;
        }
        test = ins.end();
    }
    false
}

fn case_dispatch(
    image: &Image,
    jump: &Instruction,
    seen: &BTreeMap<u32, Instruction>,
    contains: impl Fn(u32) -> bool,
) -> Option<(BTreeMap<u32, Table>, Vec<u32>)> {
    if !jump.is(X86_INS_JMP) {
        return None;
    }
    let Mem(targets) = jump.operands.first()?.op_type else {
        return None;
    };
    let previous: BTreeMap<_, _> = seen.values().map(|i| (i.end(), i)).collect();
    let load = previous.get(&jump.address).copied();
    let low = low_byte(targets.index());
    let indexed = load.is_some_and(|i| {
        i.operands.len() == 2
            && ((i.is(X86_INS_MOV) && low.is_some_and(|r| reg(&i.operands[0], r)))
                || (i.is(X86_INS_MOVZX)
                    && reg(&i.operands[0], targets.index().0 as u32)
                    && i.operands[0].size == 4))
            && matches!(i.operands[1].op_type, Mem(_))
            && i.operands[1].size == 1
    });
    let guard = if indexed {
        load.and_then(|i| previous.get(&i.address).copied())
    } else {
        load
    }?;
    let bound = previous.get(&guard.address)?;
    if !guard.is(X86_INS_JA)
        || !bound.is(X86_INS_CMP)
        || bound.operands.len() != 2
        || !reg(&bound.operands[0], targets.index().0 as u32)
    {
        return None;
    }
    let Imm(maximum @ 0..=255) = bound.operands[1].op_type else {
        return None;
    };
    if targets.base().0 != 0 || targets.scale() != 4 || targets.segment().0 != 0 {
        return None;
    }
    let count = maximum as usize + 1;
    let start = jump.end();
    let mut data = BTreeMap::new();
    let size = if indexed {
        let load = load?;
        let Mem(source) = load.operands[1].op_type else {
            return None;
        };
        if source.base() != targets.index()
            || source.index().0 != 0
            || source.segment().0 != 0
            || source.disp() != start as i64
            || targets.disp() != start as i64 + count as i64
        {
            return None;
        }
        let indices = image.read(start, count);
        if indices.len() != count {
            return None;
        }
        let size = 4 * (*indices.iter().max()? as usize + 1);
        data.insert(
            start,
            Table {
                kind: "case_indices".into(),
                bytes: indices.to_vec(),
            },
        );
        size
    } else {
        if targets.disp() != start as i64 {
            return None;
        }
        4 * count
    };
    let address = targets.disp() as u32;
    let end = address.checked_add(size as u32)?;
    let raw = image.read(address, size);
    if raw.len() != size || !contains(end - 1) {
        return None;
    }
    let entries: Vec<_> = raw
        .as_chunks::<4>()
        .0
        .iter()
        .map(|c| u32::from_le_bytes(*c))
        .collect();
    if entries
        .iter()
        .any(|a| !contains(*a) || start <= *a && *a < end)
        || (0..size)
            .step_by(4)
            .any(|i| !image.relocated(address + i as u32))
    {
        return None;
    }
    data.insert(
        address,
        Table {
            kind: "case_targets".into(),
            bytes: raw.to_vec(),
        },
    );
    Some((data, entries))
}

fn local(op: &X86Operand) -> Option<i64> {
    if let Mem(m) = op.op_type
        && op.size == 4
        && m.base().0 as u32 == X86_REG_EBP
        && m.index().0 == 0
        && m.segment().0 == 0
        && m.disp() < 0
    {
        return Some(m.disp());
    }
    None
}

pub fn case_regions(
    image: &Image,
    decoded: &[Instruction],
    ranges: &[(u32, u32)],
) -> BTreeMap<u32, (u32, Vec<u32>)> {
    let seen = decoded
        .iter()
        .map(|i| (i.address, i.clone()))
        .collect::<BTreeMap<_, _>>();
    let previous = decoded
        .iter()
        .map(|i| (i.end(), i))
        .collect::<BTreeMap<_, _>>();
    fn dead(address: u32, seen: &BTreeMap<u32, Instruction>, visited: &BTreeSet<u32>) -> bool {
        if visited.contains(&address) || visited.len() >= 256 {
            return false;
        }
        let Some(ins) = seen.get(&address).filter(|i| !i.call && !i.ret) else {
            return false;
        };
        if ins.read.iter().any(|r| {
            matches!(
                r.0 as u32,
                X86_REG_EAX | X86_REG_AX | X86_REG_AL | X86_REG_AH
            )
        }) {
            return false;
        }
        if ins.written.iter().any(|r| r.0 as u32 == X86_REG_EAX) {
            return true;
        }
        let mut visited = visited.clone();
        visited.insert(address);
        if ins.jump {
            if !imm(ins).is_some_and(|a| dead(a, seen, &visited)) {
                return false;
            }
            if ins.is(X86_INS_JMP) {
                return true;
            }
        }
        dead(ins.end(), seen, &visited)
    }
    let mut out = BTreeMap::new();
    for ins in decoded {
        if !ins.is(X86_INS_JMP)
            || !matches!(ins.operands[0].op_type,Mem(m) if m.index().0 as u32==X86_REG_EAX)
        {
            continue;
        }
        let Some((tables, entries)) = case_dispatch(image, ins, &seen, |a| {
            ranges.iter().any(|(lo, hi)| *lo <= a && a < *hi)
        }) else {
            continue;
        };
        let indices = tables.values().find(|t| t.kind == "case_indices");
        if indices.is_some() && !entries.iter().all(|a| dead(*a, &seen, &BTreeSet::new())) {
            continue;
        }
        let start = if indices.is_some() {
            previous[&ins.address].address
        } else {
            ins.address
        };
        if decoded
            .iter()
            .any(|b| b.jump && imm(b).is_some_and(|a| a == start || a == ins.address))
        {
            continue;
        }
        let end = tables
            .iter()
            .map(|(a, t)| *a + t.bytes.len() as u32)
            .max()
            .unwrap();
        let targets = if let Some(indices) = indices {
            indices.bytes.iter().map(|i| entries[*i as usize]).collect()
        } else {
            entries
        };
        out.insert(start, (end, targets));
    }
    out
}

fn heap_code_transfer(
    jump: u32,
    instructions: &[Instruction],
    symbols: &impl Resolver,
    table_targets: &BTreeSet<u32>,
) -> bool {
    let Some(index) = instructions
        .iter()
        .position(|i| i.address == jump)
        .filter(|i| *i >= 4)
    else {
        return false;
    };
    let sequence = &instructions[index - 4..=index];
    if sequence
        .windows(2)
        .any(|pair| pair[0].end() != pair[1].address)
    {
        return false;
    }
    let (call, store, reload, write, branch) = (
        &sequence[0],
        &sequence[1],
        &sequence[2],
        &sequence[3],
        &sequence[4],
    );
    let name = imm(call)
        .map(|a| symbols.name(a).replace('.', "_"))
        .unwrap_or_default();
    if !call.is(X86_INS_CALL)
        || !matches!(name.trim_start_matches('_'), "allocec" | "ec_mem_allocec")
    {
        return false;
    }
    if [store, reload, write]
        .iter()
        .any(|i| !i.is(X86_INS_MOV) || i.operands.len() != 2)
    {
        return false;
    }
    let Some(slot) = local(&store.operands[0]) else {
        return false;
    };
    if !reg(&store.operands[1], X86_REG_EAX)
        || !reg(&reload.operands[0], X86_REG_EAX)
        || local(&reload.operands[1]) != Some(slot)
    {
        return false;
    }
    let Mem(dest) = write.operands[0].op_type else {
        return false;
    };
    if write.operands[0].size != 4
        || dest.base().0 as u32 != X86_REG_EAX
        || dest.index().0 != 0
        || dest.segment().0 != 0
        || dest.disp() != 0
        || !matches!(write.operands[1].op_type, Imm(_))
        || !branch.is(X86_INS_JMP)
        || local(&branch.operands[0]) != Some(slot)
    {
        return false;
    }
    !table_targets
        .iter()
        .copied()
        .chain(instructions.iter().filter(|i| i.jump).filter_map(imm))
        .any(|a| store.address <= a && a <= branch.address)
}

pub fn decode(
    image: &Image,
    decoder: &Decoder,
    start: u32,
    ranges: &[(u32, u32)],
    symbols: &impl Resolver,
) -> Result<Flow> {
    let contains = |a| ranges.iter().any(|(lo, hi)| *lo <= a && a < *hi);
    let mut pending = vec![start];
    let mut seen = BTreeMap::<u32, Instruction>::new();
    let (mut issues, mut tables, mut cases) = (Vec::new(), BTreeMap::new(), BTreeMap::new());
    let (mut indirect, mut table_targets) = (Vec::new(), BTreeSet::new());
    while let Some(mut address) = pending.pop() {
        if seen.contains_key(&address) || !contains(address) {
            continue;
        }
        let end = ranges
            .iter()
            .find(|(lo, hi)| *lo <= address && address < *hi)
            .unwrap()
            .1;
        let batch_start = address;
        let mut stopped = false;
        for ins in decoder.decode_prefix(
            address,
            image.read(address, (end - address).min(128) as usize),
        )? {
            if seen.contains_key(&ins.address) {
                stopped = true;
                break;
            }
            seen.insert(address, ins.clone());
            let following = ins.end();
            if ins.is(X86_INS_PUSH)
                && let Some(target) = imm(&ins).filter(|a| {
                    contains(*a) && image.relocated(ins.address + ins.imm_offset as u32)
                })
            {
                if let Some(previous) = address.checked_sub(3).and_then(|a| seen.get(&a))
                    && previous.is(X86_INS_MOV)
                    && matches!(previous.operands.first().map(|o| &o.op_type), Some(Mem(m)) if m.segment().0 as u32 == X86_REG_FS)
                {
                    pending.push(target);
                }
                if let Some(handler) = one(decoder, image, target)?.filter(|i| i.is(X86_INS_JMP))
                    && let Some(target_name) = imm(&handler).map(|a| symbols.name(a))
                    && ["handlefinally", "handleonexception", "handleanyexception"]
                        .iter()
                        .any(|name| target_name.contains(name))
                {
                    pending.push(target);
                }
            }
            if ins.call
                && let Some(target) = imm(&ins)
            {
                if contains(target) {
                    pending.push(target);
                }
                if symbols.terminal(target) {
                    stopped = true;
                    break;
                }
            }
            if ins.ret {
                stopped = true;
                break;
            }
            if ins.jump {
                if ins.is(X86_INS_JMP)
                    && contains(following)
                    && let Some(cleanup) =
                        one(decoder, image, following)?.filter(|i| i.is(X86_INS_CALL))
                    && imm(&cleanup).is_some_and(|a| symbols.name(a).contains("doneexcept"))
                {
                    pending.push(following);
                }
                if let Some(target) = imm(&ins) {
                    let runtime = symbols.name(target);
                    if ins.is(X86_INS_JMP)
                        && runtime.contains("handleanyexception")
                        && contains(following)
                    {
                        pending.push(following);
                    }
                    if ins.is(X86_INS_JMP) && runtime.contains("handlefinally") {
                        let continuation = one(decoder, image, following)?;
                        if continuation
                            .as_ref()
                            .is_some_and(|i| i.is(X86_INS_JMP) && imm(i).is_some_and(&contains))
                        {
                            pending.push(following);
                        } else {
                            issues.push(format!(
                                "Unrecognized finally continuation at {following:#x}"
                            ));
                        }
                    }
                    if ins.is(X86_INS_JMP) && runtime.contains("handleonexception") {
                        let count = image.u32(following).unwrap_or(0);
                        let length = 4 + count as usize * 8;
                        let raw = if (1..=256).contains(&count) {
                            image.read(following, length)
                        } else {
                            &[]
                        };
                        if !(1..=256).contains(&count)
                            || raw.len() != length
                            || !following
                                .checked_add(length as u32 - 1)
                                .is_some_and(&contains)
                        {
                            issues.push(format!(
                                "Invalid exception dispatch table at {following:#x}"
                            ));
                        } else {
                            let handlers: Vec<_> = raw[4..]
                                .as_chunks::<8>()
                                .0
                                .iter()
                                .map(|b| u32::from_le_bytes(b[4..].try_into().unwrap()))
                                .collect();
                            if handlers.iter().any(|a| !contains(*a)) {
                                issues.push(format!(
                                    "Exception handler outside routine at {following:#x}"
                                ));
                            } else {
                                tables.insert(following, raw.to_vec());
                                // An empty typed handler plus an else block
                                // leaves a dormant skip directly after the
                                // table. Prove its target is the typed handler's
                                // DoneExcept and a sibling handler starts
                                // exactly after the skip. A typed sibling needs
                                // a relocated class pointer, while a catch-all
                                // needs a nonrelocated nil class pointer.
                                let end = following + length as u32;
                                if let Some(skip) = one(decoder, image, end)?
                                    .filter(|i| i.is(X86_INS_JMP) && contains(i.end() - 1))
                                    && let Some(target) = imm(&skip)
                                    && let Some(cleanup) =
                                        one(decoder, image, target)?.filter(|i| i.is(X86_INS_CALL))
                                    && imm(&cleanup)
                                        .is_some_and(|a| symbols.name(a).contains("doneexcept"))
                                    && raw[4..].as_chunks::<8>().0.iter().enumerate().any(
                                        |(index, row)| {
                                            u32::from_le_bytes(row[..4].try_into().unwrap()) != 0
                                                && handlers[index] == target
                                                && image.relocated(following + 4 + index as u32 * 8)
                                        },
                                    )
                                    && raw[4..].as_chunks::<8>().0.iter().enumerate().any(
                                        |(index, row)| {
                                            handlers[index] == skip.end()
                                                && if row[..4] == [0; 4] {
                                                    !image.has_relocation(
                                                        following + 4 + index as u32 * 8,
                                                        4,
                                                    )
                                                } else {
                                                    image
                                                        .relocated(following + 4 + index as u32 * 8)
                                                }
                                        },
                                    )
                                {
                                    pending.push(end);
                                }
                                pending.extend(handlers);
                            }
                        }
                    }
                    if contains(target) {
                        pending.push(target);
                    } else if !ins.is(X86_INS_JMP) {
                        issues.push(format!(
                            "Conditional branch leaves owned ranges at {address:#x}"
                        ));
                    }
                } else if let Some((data, targets)) = case_dispatch(image, &ins, &seen, contains) {
                    cases.extend(data);
                    pending.extend(&targets);
                    table_targets.extend(targets);
                } else {
                    indirect.push(ins.address);
                }
                if ins.is(X86_INS_JMP) {
                    stopped = true;
                    break;
                }
            }
            if ins.is(X86_INS_INT3) || ins.is(X86_INS_UD2) {
                issues.push(format!("Trap at {address:#x}"));
                stopped = true;
                break;
            }
            address = following;
        }
        if !stopped && address < end {
            if address == batch_start {
                issues.push(format!("Cannot decode {address:#x}"));
            } else {
                pending.push(address);
            }
        }
    }
    let mut instructions: Vec<_> = seen.values().cloned().collect();
    for jump in indirect {
        if !heap_code_transfer(jump, &instructions, symbols, &table_targets) {
            issues.push(format!("Indirect branch/table at {jump:#x}"));
        }
    }
    let metadata: Vec<_> = tables
        .iter()
        .map(|(a, raw)| (*a, *a + raw.len() as u32))
        .chain(
            cases
                .iter()
                .map(|(a, table)| (*a, *a + table.bytes.len() as u32)),
        )
        .collect();
    let mut retained = Vec::new();
    let framed = image.read(start, 3) == [0x55, 0x8b, 0xec];
    if framed {
        for (address, table) in &cases {
            let following = *address + table.bytes.len() as u32;
            if table.kind != "case_targets" || seen.contains_key(&following) || !contains(following)
            {
                continue;
            }
            if let Some(branch) = one(decoder, image, following)?
                && branch.is(X86_INS_JMP)
                && seen.contains_key(&branch.end())
                && imm(&branch).is_some_and(|a| seen.contains_key(&a))
            {
                retained.push(branch);
            }
        }
    }
    for pair in instructions.windows(2) {
        let (before, after) = (&pair[0], &pair[1]);
        let (lo, hi) = (before.end(), after.address);
        if lo >= hi
            || !(before.is(X86_INS_JMP) || before.ret)
            || metadata.iter().any(|(start, end)| lo < *end && *start < hi)
        {
            continue;
        }
        let island = decoder.decode_prefix(lo, image.read(lo, (hi - lo) as usize))?;
        if island.last().is_none_or(|i| i.end() != hi) {
            continue;
        }
        let boundaries: BTreeSet<_> = seen
            .keys()
            .copied()
            .chain(island.iter().map(|i| i.address))
            .collect();
        let skip_target = if before.is(X86_INS_JMP) {
            imm(before)
        } else {
            None
        };
        // DCC32 O- can enter a nested while directly at its test, leaving the
        // inner loop's original entry jump dormant. Both loop back-edges prove
        // the skipped jump's role and target; arbitrary decodable gaps do not.
        if framed
            && island.len() == 1
            && island[0].is(X86_INS_JMP)
            && let (Some(outer), Some(inner)) = (skip_target, imm(&island[0]))
            && hi < inner
            && inner < outer
            && loop_test_targets(&seen, inner, hi)
            && loop_test_targets(&seen, outer, inner)
        {
            retained.extend(island);
            continue;
        }
        let unlink = &[0x33, 0xc0, 0x5a, 0x59, 0x59, 0x64, 0x89, 0x10];
        if framed
            && skip_target.is_some_and(|a| seen.contains_key(&a))
            && before.is(X86_INS_JMP)
            && image.read(lo, (hi - lo) as usize) == unlink
            && before
                .address
                .checked_sub(8)
                .is_some_and(|a| image.read(a, 8) == unlink)
            && after.is(X86_INS_JMP)
            && imm(after).is_some_and(|a| symbols.name(a).contains("handleonexception"))
            && tables.contains_key(&after.end())
        {
            retained.extend(island);
            continue;
        }
        let loop_branch = seen.get(&after.end());
        let skips_loop_test = (after.is(X86_INS_CMP) || after.is(X86_INS_TEST))
            && loop_branch.is_some_and(|i| {
                i.jump
                    && !i.is(X86_INS_JMP)
                    && imm(i)
                        .is_some_and(|a| seen.contains_key(&a) && start < a && a <= before.address)
                    && skip_target == Some(i.end())
            });
        if (framed
            || frameless_entry_exit(start, before, &seen)
            || frameless_local_frame_exit(start, before, &seen))
            && before.is(X86_INS_JMP)
            && (skip_target == Some(hi) || skips_loop_test)
            && !island
                .iter()
                .any(|i| i.ret || i.is(X86_INS_INT3) || i.is(X86_INS_UD2) || i.is(X86_INS_INT))
            && island
                .iter()
                .filter(|i| i.jump)
                .all(|i| imm(i).is_some_and(|a| boundaries.contains(&a)))
            && island
                .iter()
                .filter(|i| i.call)
                .all(|i| imm(i).is_none_or(|a| !contains(a) || boundaries.contains(&a)))
        {
            retained.extend(island);
            continue;
        }
        if island.iter().any(|i| i.jump || i.ret) {
            continue;
        }
        let terminator = island.last().unwrap();
        if terminator.call
            && imm(terminator).is_some_and(|a| {
                matches!(
                    symbols.name(a).replace('.', "_").trim_start_matches('_'),
                    "raiseexceptionobject"
                        | "raiseagain"
                        | "system_@raiseexcept"
                        | "system_@raiseagain"
                )
            })
        {
            retained.extend(island);
        }
    }
    instructions.extend(retained);
    instructions.sort_by_key(|i| i.address);
    if instructions.windows(2).any(|p| p[0].end() > p[1].address) {
        issues.push("Overlapping instruction streams".into());
    }
    Ok(Flow {
        instructions,
        issues,
        tables,
        cases,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    fn bytes(text: &str) -> Vec<u8> {
        (0..text.len())
            .step_by(2)
            .map(|i| u8::from_str_radix(&text[i..i + 2], 16).unwrap())
            .collect()
    }
    #[test]
    fn compact_movzx_case_table_requires_matching_guard_and_relocations() -> Result<()> {
        let decoder = Decoder::new()?;
        // CMP EDX,3 / JA default / MOVZX EDX,byte[EDX+indices] /
        // JMP [EDX*4+targets], followed immediately by four byte indices and
        // two relocated DWORD targets. This is DCC32 O+'s compact switch.
        let raw = bytes(
            "83fa0377260fb69213100000ff249517100000000100011f10000025100000b801000000c3b802000000c3b803000000c3",
        );
        for invalid in 0..5 {
            let mut code = raw.clone();
            let mut relocations = vec![0x1008, 0x100f, 0x1017, 0x101b];
            match invalid {
                1 => code[7] = 0x8a, // MOVZX ECX disagrees with indexed EDX
                2 => {
                    relocations.pop();
                } // every target needs relocation
                3 => code[6] = 0xbe, // signed extension cannot bound the index
                4 => code[15] += 1,  // table must adjoin the complete byte map
                _ => {}
            }
            let image = Image::fixture(0x1000, code, relocations);
            let result = decode(
                &image,
                &decoder,
                0x1000,
                &[(0x1000, 0x1031)],
                &Symbols::default(),
            )?;
            assert_eq!(result.cases.len(), if invalid == 0 { 2 } else { 0 });
            assert_eq!(result.issues.is_empty(), invalid == 0);
            if invalid == 0 {
                assert_eq!(result.instructions.iter().filter(|ins| ins.ret).count(), 3);
            }
        }
        Ok(())
    }
    #[test]
    fn frameless_exit_requires_matching_register_save_epilogue() -> Result<()> {
        let decoder = Decoder::new()?;
        // PUSH EBX/ESI; preserve Self/Sender; Exit; disabled conditional body;
        // POP ESI/EBX; RET. Both sides of the body's condition join the epilogue.
        let code = bytes("53568bf28bd8eb0b85f674028bceb8010000005e5bc3");
        for invalid in 0..7 {
            let mut candidate = code.clone();
            match invalid {
                1 => candidate[20] = 0x5e, // duplicate POP fails to restore EBX
                2 => candidate[3] = 0xfa,  // MOV EDI,EDX writes an unsaved register
                3 => candidate[1] = 0x53,  // duplicate PUSH is not a callee-save set
                4 => candidate[21] = 0x90, // no proven return after the restores
                5 => candidate[11] = 0x7f, // dormant branch escapes the routine
                6 => candidate[2] = 0x03,  // arithmetic is not parameter preservation
                _ => {}
            }
            let end = 0x1000 + candidate.len() as u32;
            let image = Image::fixture(0x1000, candidate, vec![]);
            let result = decode(
                &image,
                &decoder,
                0x1000,
                &[(0x1000, end)],
                &Symbols::default(),
            )?;
            assert_eq!(
                result.instructions.iter().any(|i| i.address == 0x1008),
                invalid == 0,
                "invalid variant {invalid}"
            );
        }
        Ok(())
    }
    #[test]
    fn frameless_exit_also_accepts_a_near_entry_skip() -> Result<()> {
        let code = bytes("53568bd8e905000000b82a0000005e5bc3");
        let end = 0x1000 + code.len() as u32;
        let image = Image::fixture(0x1000, code, vec![]);
        let result = decode(
            &image,
            &Decoder::new()?,
            0x1000,
            &[(0x1000, end)],
            &Symbols::default(),
        )?;
        assert!(result.issues.is_empty());
        assert!(result.instructions.iter().any(|i| i.address == 0x1009));
        Ok(())
    }
    #[test]
    fn frameless_mid_body_exit_requires_the_complete_local_frame_restore() -> Result<()> {
        // Fixed two-DWORD local allocation, conditional work, then an Exit
        // before dormant MOV EAX,42. The epilogue drops the two locals and
        // restores exactly the entry's callee-save registers.
        let raw = bytes("535683c4f88b042485c0750bc6042400eb05b82a000000595a5e5bc3");
        for invalid in 0..6 {
            let mut code = raw.clone();
            match invalid {
                1 => code[26] = 0x5e, // wrong callee-save restore
                2 => code[4] = 0xf4,  // twelve local bytes cannot unwind as eight
                3 => code[24] = 0x5e, // locals must not consume a saved-register POP
                4 => code[27] = 0x90, // no final RET
                5 => code[18..23].copy_from_slice(&[0xe9, 0, 1, 0, 0]), // island branch escapes
                _ => {}
            }
            let image = Image::fixture(0x1000, code, vec![]);
            let result = decode(
                &image,
                &Decoder::new()?,
                0x1000,
                &[(0x1000, 0x101c)],
                &Symbols::default(),
            )?;
            assert_eq!(
                result.instructions.iter().any(|ins| ins.address == 0x1012),
                invalid == 0,
                "invalid variant {invalid}"
            );
        }
        Ok(())
    }
    #[test]
    fn empty_typed_handler_retains_only_its_proven_post_table_skip() -> Result<()> {
        let decoder = Decoder::new()?;
        let code = bytes(
            "558bec33c055681f10000064ff306489209033c05a5959648910e92f000000e9dc0f0000020000000040000044100000000000003a100000eb0ae8c13f0000e90a000000e8b71f0000e9000000005dc3",
        );
        for invalid in 0..4 {
            let mut candidate = code.clone();
            let mut relocations = vec![0x1007, 0x1028, 0x102c, 0x1034];
            match invalid {
                1 => candidate[57] = 0, // skip must reach typed cleanup
                2 => {
                    relocations.remove(1);
                } // typed class needs relocation
                3 => candidate[48] = 1, // sibling must be nil catch-all
                _ => {}
            }
            let image = Image::fixture(0x1000, candidate, relocations);
            let symbols = Symbols {
                names: BTreeMap::from([
                    (0x2000, "System.@HandleOnException".into()),
                    (0x3000, "System.@DoneExcept".into()),
                ]),
                ..Symbols::default()
            };
            let result = decode(&image, &decoder, 0x1000, &[(0x1000, 0x1050)], &symbols)?;
            assert_eq!(
                result.instructions.iter().any(|i| i.address == 0x1038),
                invalid == 0
            );
            assert_eq!(result.tables[&0x1024].len(), 20);
        }
        Ok(())
    }
    #[test]
    fn empty_typed_handler_can_precede_another_relocated_typed_handler() -> Result<()> {
        let mut code = bytes(
            "558bec33c055681f10000064ff306489209033c05a5959648910e92f000000e9dc0f0000020000000040000044100000000000003a100000eb0ae8c13f0000e90a000000e8b71f0000e9000000005dc3",
        );
        code[48..52].copy_from_slice(&0x5000u32.to_le_bytes());
        for relocated_sibling in [true, false] {
            let mut relocations = vec![0x1007, 0x1028, 0x102c, 0x1034];
            if relocated_sibling {
                relocations.push(0x1030);
                relocations.sort_unstable();
            }
            let image = Image::fixture(0x1000, code.clone(), relocations);
            let symbols = Symbols {
                names: BTreeMap::from([
                    (0x2000, "System.@HandleOnException".into()),
                    (0x3000, "System.@DoneExcept".into()),
                ]),
                ..Symbols::default()
            };
            let result = decode(
                &image,
                &Decoder::new()?,
                0x1000,
                &[(0x1000, 0x1050)],
                &symbols,
            )?;
            assert_eq!(
                result.instructions.iter().any(|ins| ins.address == 0x1038),
                relocated_sibling
            );
        }
        Ok(())
    }
    #[test]
    fn relocated_case_table_and_missing_evidence() -> Result<()> {
        let decoder = Decoder::new()?;
        // CMP register,2 / JA default / JMP [register*4+table].
        // ESI is used by SR1 SF_ShipGoods; unlike EAX it has no x86 byte view.
        for (compare, sib) in [(0xf8, 0x85), (0xfd, 0xad), (0xfe, 0xb5), (0xff, 0xbd)] {
            for (relocated, matching_guard) in [(true, true), (false, true), (true, false)] {
                let mut code = bytes("83f802771fff2485");
                code[1] = if matching_guard { compare } else { 0xfa }; // EDX
                code[7] = sib;
                for address in [0x100cu32, 0x1018, 0x101e, 0x1024] {
                    code.extend(address.to_le_bytes());
                }
                code.extend(bytes("b80b000000c3b816000000c3b821000000c3"));
                let image = Image::fixture(
                    0x1000,
                    code.clone(),
                    if relocated {
                        vec![0x1008, 0x100c, 0x1010, 0x1014]
                    } else {
                        vec![]
                    },
                );
                let result = decode(
                    &image,
                    &decoder,
                    0x1000,
                    &[(0x1000, 0x102a)],
                    &Symbols::default(),
                )?;
                let proven = relocated && matching_guard;
                assert_eq!(result.cases.len(), usize::from(proven));
                assert_eq!(result.issues.is_empty(), proven);
            }
        }
        Ok(())
    }
    #[test]
    fn exit_keeps_skipped_pascal_instructions() -> Result<()> {
        let code = bytes("558beceb05b82a0000005dc3");
        let image = Image::fixture(0x1000, code, vec![]);
        let result = decode(
            &image,
            &Decoder::new()?,
            0x1000,
            &[(0x1000, 0x100c)],
            &Symbols::default(),
        )?;
        assert!(result.issues.is_empty());
        assert!(
            result
                .instructions
                .iter()
                .any(|i| i.address == 0x1005 && i.is(X86_INS_MOV))
        );
        Ok(())
    }
    #[test]
    fn nested_while_keeps_only_the_proven_dormant_entry_jump() -> Result<()> {
        let decoder = Decoder::new()?;
        for (offset, retained) in [(2, true), (1, false)] {
            let mut code = bytes("558beceb0aeb02909085c075fa909085d275f65dc3");
            code[6] = offset;
            let image = Image::fixture(0x1000, code, vec![]);
            let result = decode(
                &image,
                &decoder,
                0x1000,
                &[(0x1000, 0x1015)],
                &Symbols::default(),
            )?;
            assert_eq!(
                result.instructions.iter().any(|i| i.address == 0x1005),
                retained
            );
        }
        Ok(())
    }
    #[test]
    fn unknown_indirect_jump_is_not_proof() -> Result<()> {
        let image = Image::fixture(0x1000, bytes("ffe0"), vec![]);
        let result = decode(
            &image,
            &Decoder::new()?,
            0x1000,
            &[(0x1000, 0x1002)],
            &Symbols::default(),
        )?;
        assert_eq!(result.issues, ["Indirect branch/table at 0x1000"]);
        Ok(())
    }
}
