use super::*;
use sha2::{Digest, Sha256};
impl Symbols<'_> {
    /// A reviewed native operand selects the array independently of the linked
    /// image. Require its exact linked base and compare the complete constant.
    pub fn indexed_identity(
        &self,
        image: usize,
        address: u32,
        width: usize,
        scale: i64,
        target: u32,
        literal: bool,
    ) -> Option<String> {
        let &(bias, stride) = self.evidence.arrays.get(&target)?;
        if scale != stride || width.max(1) as i64 > stride {
            return None;
        }
        let base = address.wrapping_add(bias as u32);
        if image == 0 {
            if base != target {
                return None;
            }
        } else if self.linked.get(&base) != Some(&target) {
            return None;
        }
        let value = if literal && self.states[image].constants.contains_key(&base) {
            self.constant_identity(image, base, 0, 0)?
        } else {
            self.evidence.names.get(&target)?.clone()
        };
        Some(if bias == 0 {
            value
        } else {
            format!("{value}+{}", signed_hex(-bias))
        })
    }
    pub fn constant_identity(
        &self,
        image: usize,
        base: u32,
        width: usize,
        offset: usize,
    ) -> Option<String> {
        let img = self.images[image];
        let size = *self.states[image].constants.get(&base)?;
        if offset.checked_add(width.max(1))? > size {
            return None;
        }
        let target = if image == 0 {
            Some(base)
        } else {
            self.linked.get(&base).copied()
        };
        let slots = target
            .and_then(|a| self.evidence.managed.get(&a))
            .map(Vec::as_slice)
            .unwrap_or(&[]);
        let data = img.read_exact(base, size).ok()?;
        let mut normalized = data.to_vec();
        let mut strings = Vec::new();
        let mut cursor = 0;
        for (pos, kind) in slots {
            let pos = *pos as usize;
            if pos < cursor
                || pos + 4 > size
                || img.has_relocation(base + cursor as u32, pos - cursor)
            {
                return None;
            }
            let pointer = u32::from_le_bytes(data[pos..pos + 4].try_into().ok()?);
            let text = if kind == "ansistring" {
                let text = if pointer == 0 {
                    if img.has_relocation(base + pos as u32, 4) {
                        return None;
                    }
                    Vec::new()
                } else {
                    let header = img.read_exact(pointer.checked_sub(8)?, 8).ok()?;
                    let length = u32::from_le_bytes(header[4..].try_into().ok()?) as usize;
                    if length == 0 || length >= 65536 {
                        return None;
                    }
                    let text = img.read_exact(pointer, length + 1).ok()?;
                    if !img.relocated(base + pos as u32)
                        || img.has_relocation(base + pos as u32 + 1, 3)
                        || header[..4] != [255; 4]
                        || text[length] != 0
                        || img.has_relocation(pointer - 8, length + 9)
                    {
                        return None;
                    }
                    text[..length].to_vec()
                };
                normalized[pos..pos + 4].fill(0);
                Some(text)
            } else if kind == "widestring"
                && pointer == 0
                && !img.has_relocation(base + pos as u32, 4)
            {
                self.states[image]
                    .initializers
                    .as_ref()?
                    .get(&(base + pos as u32))
                    .cloned()
            } else if matches!(kind.as_str(), "dynamic_array" | "interface")
                && pointer == 0
                && !img.has_relocation(base + pos as u32, 4)
            {
                None
            } else {
                return None;
            };
            strings.push((pos, kind, text));
            cursor = pos + 4;
        }
        if img.has_relocation(base + cursor as u32, size - cursor) {
            return None;
        }
        let value = if slots.is_empty() {
            format!("literal:{size}:{}", hex(data))
        } else {
            let mut digest = Sha256::new();
            digest.update(normalized);
            for (pos, kind, text) in strings {
                digest.update((pos as u32).to_le_bytes());
                digest.update(kind.as_bytes());
                digest.update([0]);
                digest.update(
                    text.as_ref()
                        .map_or(u32::MAX, |t| t.len() as u32)
                        .to_le_bytes(),
                );
                if let Some(t) = text {
                    digest.update(t);
                }
            }
            format!("managed-constant:{size}:{}", hex(&digest.finalize()))
        };
        Some(
            value
                + &if offset == 0 {
                    String::new()
                } else {
                    format!("+{offset:#x}")
                },
        )
    }
    pub fn identity(
        &self,
        image: usize,
        address: u32,
        width: usize,
        literal: bool,
        index_scale: i64,
    ) -> Option<String> {
        let img = self.images[image];
        let state = &self.states[image];
        if index_scale != 0
            && let Some(entries) = state.arrays.get(&address)
        {
            let candidates = entries
                .iter()
                .filter(|c| c.stride == index_scale && width.max(1) as i64 <= c.remaining)
                .collect::<Vec<_>>();
            if candidates.len() > 1 {
                return None;
            }
            if let Some(c) = candidates.first() {
                let value = if literal && state.constants.contains_key(&c.base) {
                    self.constant_identity(image, c.base, 0, 0)?
                } else {
                    self.evidence.names.get(&c.target)?.clone()
                };
                return Some(format!("{value}+{}", signed_hex(c.offset)));
            }
        }
        if literal && state.constants.contains_key(&address) {
            return self.constant_identity(image, address, width, 0);
        }
        if let Some(i) = img
            .imports
            .get(&address)
            .or_else(|| img.imported_target(address))
        {
            return Some(imported(i));
        }
        let target = if image == 0 {
            self.evidence
                .names
                .contains_key(&address)
                .then_some(address)
        } else {
            self.linked.get(&address).copied()
        };
        if let Some(target) = target {
            if let Some(i) = self.images[0]
                .imports
                .get(&target)
                .or_else(|| self.images[0].imported_target(target))
            {
                return Some(imported(i));
            }
            return self.evidence.names.get(&target).cloned();
        }
        let containing = if image == 0 {
            self.evidence
                .sizes
                .range(..=address)
                .next_back()
                .map(|(&a, &n)| (a, a, n))
        } else {
            self.linked
                .range(..=address)
                .next_back()
                .map(|(&a, &t)| (a, t, self.evidence.sizes.get(&t).copied().unwrap_or(0)))
        };
        if let Some((base, target, size)) = containing
            && (address - base) as usize + width.max(1) <= size
        {
            if literal && state.constants.contains_key(&base) {
                return self.constant_identity(image, base, width, (address - base) as usize);
            }
            return Some(format!(
                "{}+{:#x}",
                self.evidence.names.get(&target)?,
                address - base
            ));
        }
        if literal && width == 4 && img.relocated(address) {
            let target = img.u32(address)?;
            if let Some(&(base, offset)) = state.globals.get(&address) {
                if self.states[0].constants.contains_key(&base) {
                    return self
                        .constant_identity(image, target - offset, 0, offset as usize)
                        .map(|v| format!("constant-reference:{v}"));
                }
                return Some(format!(
                    "global-reference:{}+{offset:#x}",
                    self.evidence.names.get(&base)?
                ));
            }
            if target == address + 4
                && let Some(rtti) = self.rtti(image, target, &[])
            {
                return Some(format!("rtti-reference:{rtti}"));
            }
        }
        if literal && width == 0 {
            if !self.evidence.guids.is_empty() && img.constant_storage(address, true) {
                let guid = img.read(address, 16);
                if self.evidence.guids.contains(guid) && !img.has_relocation(address, 16) {
                    return Some(format!("interface-guid:{}", hex(guid)));
                }
            }
            if let Some(rtti) = self.rtti(image, address, &[]) {
                return Some(rtti);
            }
            let header = img.read(address.wrapping_sub(8), 8);
            if header.len() == 8 {
                let length = u32::from_le_bytes(header[4..].try_into().ok()?) as usize;
                if (1..65536).contains(&length) {
                    if header[..4] == [255; 4] {
                        let payload = img.read(address, length + 1);
                        if payload.len() == length + 1 && payload[length] == 0 {
                            return Some(format!("ansistring:{}", hex(payload)));
                        }
                    }
                    let payload = img.read(address, length + 2);
                    if img.constant_storage(address, false)
                        && length.is_multiple_of(2)
                        && payload.len() == length + 2
                        && payload[length..] == [0, 0]
                    {
                        return Some(format!("widestring:{}", hex(payload)));
                    }
                }
            }
        }
        if literal && width > 0 && img.constant_storage(address, true) {
            let data = img.read(address, width);
            if data.len() == width && !img.has_relocation(address, width) {
                return Some(format!("literal:{width}:{}", hex(data)));
            }
        }
        None
    }
    pub fn rtti(&self, image: usize, address: u32, active: &[u32]) -> Option<String> {
        let img = self.images[image];
        if active.contains(&address)
            || active.len() >= 8
            || !img.relocated(address.checked_sub(4)?)
            || img.u32(address - 4) != Some(address)
        {
            return None;
        }
        let header = img.read_exact(address, 2).ok()?;
        let kind = header[0];
        let length = header[1] as u32;
        let data = address + 2 + length;
        img.read_exact(address + 2, length as usize).ok()?;
        let mut active = active.to_vec();
        active.push(address);
        let scalar = match kind {
            1 | 2 | 9 => Some(9),
            4 | 5 => Some(1),
            10 | 11 => Some(0),
            16 => Some(16),
            _ => None,
        };
        if let Some(size) = scalar {
            let raw = img.read_exact(data, size).ok()?;
            return (!img.has_relocation(data, size)).then(|| format!("rtti:{kind}:{}", hex(raw)));
        }
        match kind {
            7 => {
                if !img.relocated(data) {
                    return None;
                }
                let vmt = img.u32(data)?;
                let cell = vmt.checked_sub(76)?;
                if !img.relocated(cell) || img.u32(cell) != Some(vmt) {
                    return None;
                }
                let name = self.identity(image, cell, 0, false, 0)?;
                name.starts_with("class:").then(|| format!("rtti:{name}"))
            }
            13 => {
                img.read_exact(data, 12).ok()?;
                if img.has_relocation(data, 8) || !img.relocated(data + 8) {
                    return None;
                }
                let (size, count, pointer) =
                    (img.u32(data)?, img.u32(data + 4)?, img.u32(data + 8)?);
                if count == 0
                    || count > size
                    || size > 0x100000
                    || size % count != 0
                    || !img.relocated(pointer)
                {
                    return None;
                }
                Some(format!(
                    "rtti:static-array:{size}:{count}:{}",
                    self.rtti(image, img.u32(pointer)?, &active)?
                ))
            }
            14 => {
                img.read_exact(data, 8).ok()?;
                if img.has_relocation(data, 8) {
                    return None;
                }
                let (size, count) = (img.u32(data)?, img.u32(data + 4)?);
                if size == 0 || size > 0x100000 || count == 0 || count > 4096 {
                    return None;
                }
                let mut fields = Vec::new();
                for index in 0..count {
                    let entry = data + 8 + index * 8;
                    let (pointer, offset) = (img.u32(entry)?, img.u32(entry + 4)?);
                    if !img.relocated(entry)
                        || img.has_relocation(entry + 4, 4)
                        || !img.relocated(pointer)
                        || offset >= size
                    {
                        return None;
                    }
                    fields.push(format!(
                        "({offset}, '{}')",
                        self.rtti(image, img.u32(pointer)?, &active)?
                    ));
                }
                Some(format!("rtti:record:{size}:[{}]", fields.join(", ")))
            }
            15 => {
                let raw = img.read_exact(data, 22).ok()?;
                if raw[4] & !7 != 0 {
                    return None;
                }
                let parent = img.u32(data)?;
                let tail = img.read_exact(data + 22, raw[21] as usize + 4).ok()?;
                if tail[tail.len() - 2..] != [255, 255]
                    || img.has_relocation(data + 4, 18 + tail.len())
                {
                    return None;
                }
                let ancestor = if parent == 0 {
                    if img.relocated(data) {
                        return None;
                    }
                    "root".into()
                } else {
                    if !img.relocated(data) || !img.relocated(parent) {
                        return None;
                    }
                    let a = self.rtti(image, img.u32(parent)?, &active)?;
                    if !a.starts_with("rtti:interface:") {
                        return None;
                    }
                    a
                };
                Some(format!(
                    "rtti:interface:{}:{}:{ancestor}",
                    hex(&raw[4..21]),
                    hex(&tail[tail.len() - 4..tail.len() - 2])
                ))
            }
            17 => {
                img.read_exact(data, 16).ok()?;
                let (width, managed, variant, element) = (
                    img.u32(data)?,
                    img.u32(data + 4)?,
                    img.u32(data + 8)?,
                    img.u32(data + 12)?,
                );
                if width == 0
                    || width > 65536
                    || img.has_relocation(data, 4)
                    || img.has_relocation(data + 8, 4)
                    || element == 0 && (managed != 0 || variant != u32::MAX)
                {
                    return None;
                }
                let mut types = Vec::new();
                for (offset, pointer) in [(4, managed), (12, element)] {
                    if pointer == 0 {
                        if img.relocated(data + offset) {
                            return None;
                        }
                        types.push("unmanaged".into());
                        continue;
                    }
                    if !img.relocated(data + offset) || !img.relocated(pointer) {
                        return None;
                    }
                    let target = img.u32(pointer)?;
                    let mut identity = self.rtti(image, target, &active);
                    if identity.is_none() && offset == 12 && managed == 0 && variant == u32::MAX {
                        let header = img.read(target, 2);
                        if header.len() == 2 && header[0] == 3 {
                            let payload = target + 2 + header[1] as u32;
                            let raw = img.read(payload, 13);
                            if raw.len() == 13
                                && img.relocated(target.wrapping_sub(4))
                                && img.u32(target - 4) == Some(target)
                                && img.relocated(payload + 9)
                                && img.u32(payload + 9) == Some(target - 4)
                                && !img.has_relocation(payload, 9)
                            {
                                let storage = match raw[0] {
                                    0 | 1 => 1,
                                    2 | 3 => 2,
                                    4 | 5 => 4,
                                    _ => 0,
                                };
                                let signed = raw[0].is_multiple_of(2);
                                let value = |i| {
                                    let n = u32::from_le_bytes(raw[i..i + 4].try_into().unwrap());
                                    if signed { n as i32 as i64 } else { n as i64 }
                                };
                                if storage == width && value(1) <= value(5) {
                                    identity =
                                        Some(format!("rtti:enum-array-element:{}", hex(&raw[..9])));
                                }
                            }
                        }
                    }
                    types.push(identity?);
                }
                Some(format!(
                    "rtti:array:{width}:{variant}:[{}]",
                    types
                        .iter()
                        .map(|t| format!("'{t}'"))
                        .collect::<Vec<_>>()
                        .join(", ")
                ))
            }
            _ => None,
        }
    }
}
fn signed_hex(n: i64) -> String {
    if n < 0 {
        format!("-{:#x}", -n)
    } else {
        format!("{n:#x}")
    }
}
