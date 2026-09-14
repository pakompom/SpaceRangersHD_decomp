//! Owned x86 instruction facts and local dataflow for relocation analysis.

use anyhow::{Result, bail};
use capstone::arch::x86::{X86Insn, X86Operand, X86OperandType, X86Reg};
use capstone::prelude::*;
use capstone::{InsnGroupType, RegId};
use std::collections::{BTreeMap, HashSet};

#[derive(Debug, Clone)]
pub struct Instruction {
    pub address: u32,
    pub bytes: Vec<u8>,
    pub id: u32,
    pub mnemonic: String,
    pub text: String,
    pub operands: Vec<X86Operand>,
    pub written: Vec<RegId>,
    pub read: Vec<RegId>,
    pub call: bool,
    pub jump: bool,
    pub ret: bool,
    pub imm_offset: u8,
    pub imm_size: u8,
    pub disp_offset: u8,
    pub disp_size: u8,
}

impl Instruction {
    pub fn end(&self) -> u32 {
        self.address + self.bytes.len() as u32
    }
    pub fn is(&self, id: X86Insn) -> bool {
        self.id == id as u32
    }
}

pub struct Decoder(Capstone);

impl Decoder {
    pub fn reg_name(&self, reg: RegId) -> String {
        self.0.reg_name(reg).unwrap_or_default()
    }
    pub fn new() -> Result<Self> {
        Ok(Self(
            Capstone::new()
                .x86()
                .mode(arch::x86::ArchMode::Mode32)
                .detail(true)
                .build()?,
        ))
    }

    pub fn decode(&self, address: u32, bytes: &[u8]) -> Result<Vec<Instruction>> {
        let result = self.decode_prefix(address, bytes)?;
        if result.iter().map(|i| i.bytes.len()).sum::<usize>() != bytes.len() {
            bail!("Incomplete x86 span at {address:#x}");
        }
        Ok(result)
    }

    /// A bounded window may end in the middle of an instruction. The CFG walker
    /// retries that suffix; strict corpus decoding uses `decode` instead.
    pub fn decode_prefix(&self, address: u32, bytes: &[u8]) -> Result<Vec<Instruction>> {
        let decoded = self.0.disasm_all(bytes, address as u64)?;
        let mut result = Vec::with_capacity(decoded.len());
        for instruction in decoded.iter() {
            let detail = self.0.insn_detail(instruction)?;
            let arch = detail.arch_detail();
            let x86 = arch.x86().expect("x86 decoder");
            let encoding = x86.encoding();
            let group = |id| detail.groups().iter().any(|g| g.0 == id as u8);
            result.push(Instruction {
                address: instruction.address() as u32,
                bytes: instruction.bytes().to_vec(),
                id: instruction.id().0,
                mnemonic: instruction.mnemonic().unwrap_or_default().into(),
                text: format!(
                    "{} {}",
                    instruction.mnemonic().unwrap_or_default(),
                    instruction.op_str().unwrap_or_default()
                )
                .trim()
                .into(),
                operands: x86.operands().collect(),
                written: detail.regs_write().to_vec(),
                read: detail.regs_read().to_vec(),
                call: group(InsnGroupType::CS_GRP_CALL),
                jump: group(InsnGroupType::CS_GRP_JUMP),
                ret: group(InsnGroupType::CS_GRP_RET),
                imm_offset: encoding.imm.map_or(0, |s| s.offset),
                imm_size: encoding.imm.map_or(0, |s| s.size),
                disp_offset: encoding.disp.map_or(0, |s| s.offset),
                disp_size: encoding.disp.map_or(0, |s| s.size),
            });
        }
        Ok(result)
    }
}

pub fn family(reg: RegId) -> usize {
    use X86Reg::*;
    let r = reg.0 as u32;
    (match r {
        X86_REG_AL | X86_REG_AH | X86_REG_AX => X86_REG_EAX,
        X86_REG_BL | X86_REG_BH | X86_REG_BX => X86_REG_EBX,
        X86_REG_CL | X86_REG_CH | X86_REG_CX => X86_REG_ECX,
        X86_REG_DL | X86_REG_DH | X86_REG_DX => X86_REG_EDX,
        X86_REG_SI => X86_REG_ESI,
        X86_REG_DI => X86_REG_EDI,
        X86_REG_SP => X86_REG_ESP,
        X86_REG_BP => X86_REG_EBP,
        _ => r,
    }) as usize
}

#[derive(Clone, Copy)]
struct Value {
    origin: (u32, usize),
    factor: i64,
}

fn value(values: &mut [Option<Value>; 256], address: u32, reg: RegId) -> Value {
    let reg = family(reg);
    *values[reg].get_or_insert(Value {
        origin: (address, reg),
        factor: 1,
    })
}

/// Track register origins and multiplication inside proven straight-line spans.
pub fn indexed_operand_scales(decoded: &[Instruction]) -> BTreeMap<(u32, usize), i64> {
    use X86Insn::*;
    use X86OperandType::*;
    let targets: HashSet<u32> = decoded
        .iter()
        .filter(|i| i.jump)
        .flat_map(|i| &i.operands)
        .filter_map(|op| {
            if let Imm(a) = op.op_type {
                Some(a as u32)
            } else {
                None
            }
        })
        .collect();
    let mut values = [None; 256];
    let mut scales = BTreeMap::new();
    let mut previous_end = None;
    for ins in decoded {
        if targets.contains(&ins.address) || Some(ins.address) != previous_end {
            values.fill(None);
        }
        for (index, op) in ins.operands.iter().enumerate() {
            if let Mem(mem) = op.op_type {
                if mem.segment().0 != 0 {
                    continue;
                }
                let scale = if mem.index().0 != 0 && mem.base().0 == 0 {
                    Some(mem.scale() as i64 * value(&mut values, ins.address, mem.index()).factor)
                } else if mem.base().0 != 0 && mem.index().0 == 0 {
                    Some(value(&mut values, ins.address, mem.base()).factor)
                } else {
                    None
                };
                if let Some(scale) = scale {
                    scales.insert((ins.address, index), scale);
                }
            }
        }
        let mut derived = None;
        let ops = &ins.operands;
        if let Some(X86Operand {
            op_type: Reg(dest),
            size: 4,
            ..
        }) = ops.first()
        {
            let current = value(&mut values, ins.address, *dest);
            if let Some(rhs) = ops.get(1) {
                match rhs.op_type {
                    Reg(reg) if rhs.size == 4 => {
                        if ins.is(X86_INS_MOV) {
                            derived = Some(value(&mut values, ins.address, reg));
                        } else if ins.is(X86_INS_ADD) || ins.is(X86_INS_SUB) {
                            let other = value(&mut values, ins.address, reg);
                            if current.origin == other.origin {
                                derived = Some(Value {
                                    origin: current.origin,
                                    factor: current.factor
                                        + other.factor * if ins.is(X86_INS_ADD) { 1 } else { -1 },
                                });
                            }
                        } else if ins.is(X86_INS_IMUL)
                            && ops.len() == 3
                            && let Imm(multiplier) = ops[2].op_type
                        {
                            let current = value(&mut values, ins.address, reg);
                            derived = Some(Value {
                                factor: current.factor * multiplier,
                                ..current
                            });
                        }
                    }
                    Imm(count) if ins.is(X86_INS_SHL) || ins.is(X86_INS_SAL) => {
                        derived = Some(Value {
                            factor: current.factor * (1i64 << (count & 31)),
                            ..current
                        });
                    }
                    Mem(mem)
                        if ins.is(X86_INS_LEA)
                            && mem.disp() == 0
                            && mem.segment().0 == 0
                            && mem.index().0 != 0 =>
                    {
                        let current = value(&mut values, ins.address, mem.index());
                        if mem.base().0 == 0 {
                            derived = Some(Value {
                                factor: current.factor * mem.scale() as i64,
                                ..current
                            });
                        } else {
                            let other = value(&mut values, ins.address, mem.base());
                            if current.origin == other.origin {
                                derived = Some(Value {
                                    factor: current.factor * mem.scale() as i64 + other.factor,
                                    ..current
                                });
                            }
                        }
                    }
                    _ => {}
                }
            }
        }
        for &reg in &ins.written {
            values[family(reg)] = None;
        }
        if let Some(derived) = derived.filter(|v| v.factor > 0 && v.factor <= u32::MAX as i64)
            && let Reg(reg) = ops[0].op_type
        {
            values[family(reg)] = Some(derived);
        }
        if ins.call || ins.jump || ins.ret {
            values.fill(None);
        }
        previous_end = Some(ins.end());
    }
    scales
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
    fn copied_origins_and_clobbers() -> Result<()> {
        let decoder = Decoder::new()?;
        for (middle, expected) in [
            ("89c2c1e00429d0", 120),
            ("89c2c1e00401d0", 136),
            ("89c2c1e00429c8", 8),
            ("89c2c1e004b20129d0", 8),
            ("89c2c1e0048b142429d0", 8),
            ("89c2c1e004e80000000029d0", 8),
            ("89c2c1e004eb0029d0", 8),
            ("89c28d0442", 24),
            ("8d044a", 8),
        ] {
            let instructions =
                decoder.decode(0x1000, &bytes(&format!("{middle}8b04c500200000c3")))?;
            let load = &instructions[instructions.len() - 2];
            assert_eq!(
                indexed_operand_scales(&instructions)[&(load.address, 1)],
                expected,
                "{middle}"
            );
        }
        Ok(())
    }

    #[test]
    fn discontinuous_spans_do_not_share_register_proofs() -> Result<()> {
        let decoder = Decoder::new()?;
        let mut instructions = decoder.decode(0x1000, &bytes("01d2"))?;
        instructions.extend(decoder.decode(0x1010, &bytes("8b04d500200000c3"))?);
        assert_eq!(indexed_operand_scales(&instructions)[&(0x1010, 1)], 8);
        Ok(())
    }
}
