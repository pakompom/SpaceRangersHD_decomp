//! Static references and compiler metadata; no execution of image contents.
use crate::{native::image::Image, native::x86::Decoder};
use anyhow::{Context, Result};
use capstone::arch::x86::{X86Insn, X86OperandType};
use std::collections::{BTreeMap, BTreeSet};
impl Image {
    pub fn section_end(&self, address: u32) -> Result<u32> {
        let section = self
            .section(address)
            .context("address outside PE sections")?;
        Ok(section.address + section.virtual_size)
    }
    pub fn references_to(&self, address: u32) -> Vec<u32> {
        self.relocations
            .iter()
            .copied()
            .filter(|a| self.u32(*a) == Some(address))
            .collect()
    }
    pub fn global_references(&self, sizes: &BTreeMap<u32, usize>) -> BTreeMap<u32, (u32, u32)> {
        let mut out = BTreeMap::new();
        for &cell in &self.relocations {
            let Some(target) = self.u32(cell) else {
                continue;
            };
            let Some((&base, &size)) = sizes.range(..=target).next_back() else {
                continue;
            };
            if (target - base) as usize >= size {
                continue;
            }
            if sizes
                .range(..=cell)
                .next_back()
                .is_some_and(|(&b, &s)| ((cell - b) as usize) < s)
            {
                continue;
            }
            if self
                .section(cell)
                .is_some_and(|s| s.flags & 0x20000000 == 0)
            {
                out.insert(cell, (base, target - base));
            }
        }
        out
    }
    pub fn prefix(
        &self,
        decoder: &Decoder,
        address: u32,
        minimum_bytes: usize,
        minimum_instructions: usize,
    ) -> Result<Option<Vec<u8>>> {
        let mut out = Vec::new();
        let (mut masked, mut count) = (0, 0);
        for ins in decoder.decode_prefix(address, self.read(address, 112))? {
            let mut raw = ins.bytes.clone();
            for &relocation in
                &self.relocations[self.relocations.partition_point(|a| *a < ins.address)
                    ..self
                        .relocations
                        .partition_point(|a| *a < ins.end().saturating_sub(3))]
            {
                let offset = (relocation - ins.address) as usize;
                raw[offset..offset + 4].fill(0);
                masked += 4;
            }
            let transfer = ins.call || ins.is(X86Insn::X86_INS_JMP);
            if transfer && ins.imm_size > 0 {
                raw[ins.imm_offset as usize..(ins.imm_offset + ins.imm_size) as usize].fill(0);
                masked += ins.imm_size as usize;
            }
            out.extend(raw);
            count += 1;
            if ins.ret || out.len() >= 96 {
                break;
            }
            if ins.is(X86Insn::X86_INS_JMP)
                && (ins.imm_size == 0
                    || !matches!(ins.operands[0].op_type,X86OperandType::Imm(a) if (address as i64..address as i64+512).contains(&a)))
            {
                break;
            }
        }
        Ok(
            (count >= minimum_instructions && out.len().saturating_sub(masked) >= minimum_bytes)
                .then_some(out),
        )
    }
    pub fn wide_string_initializers(
        &self,
        helpers: &BTreeSet<u32>,
    ) -> Option<BTreeMap<u32, Vec<u8>>> {
        let mut out = BTreeMap::new();
        if helpers.is_empty() {
            return Some(out);
        }
        for section in self.sections.iter().filter(|s| s.flags & 0x20000000 != 0) {
            let code = self.read(section.address, section.virtual_size as usize);
            for (pos, &b) in code.iter().enumerate() {
                if b != 0xb8 || pos + 10 > code.len() || code[pos + 5] != 0xe8 {
                    continue;
                }
                let pc = section.address + pos as u32;
                if !self.relocated(pc + 1)
                    || !helpers.contains(
                        &(pc + 10).wrapping_add(u32::from_le_bytes(
                            code[pos + 6..pos + 10].try_into().ok()?,
                        )),
                    )
                {
                    continue;
                }
                let table = self.u32(pc + 1)?;
                let count = self.u32(table)?;
                if count == 0 || count > 65536 {
                    return None;
                }
                self.read_exact(table + 4, count as usize * 8).ok()?;
                for i in 0..count {
                    let entry = table + 4 + i * 8;
                    let dest = self.u32(entry)?;
                    let source = self.u32(entry + 4)?;
                    if !self.relocated(entry)
                        || !self.relocated(entry + 4)
                        || self.u32(dest) != Some(0)
                        || !self.constant_storage(source, false)
                    {
                        return None;
                    }
                    let length = self.u32(source.checked_sub(4)?)? as usize;
                    if !length.is_multiple_of(2) || length > 1 << 24 {
                        return None;
                    }
                    let data = self.read_exact(source, length + 2).ok()?;
                    if data[length..] != [0, 0] || self.has_relocation(source, length + 2) {
                        return None;
                    }
                    if out
                        .get(&dest)
                        .is_some_and(|old: &Vec<u8>| old != &data[..length])
                    {
                        return None;
                    }
                    out.insert(dest, data[..length].to_vec());
                }
            }
        }
        Some(out)
    }
}
