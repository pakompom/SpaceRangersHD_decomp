//! Owned Win32 image storage. All address arithmetic is bounds checked.

use anyhow::{Context, Result, bail, ensure};
use goblin::pe::PE;
use serde::Serialize;
use std::{collections::BTreeMap, fs, path::Path};

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct Import {
    pub dll: String,
    pub name: ImportName,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
#[serde(untagged)]
pub enum ImportName {
    Name(String),
    Ordinal(u16),
}

#[derive(Debug, Clone, Serialize)]
pub struct Section {
    pub address: u32,
    pub virtual_size: u32,
    pub offset: u32,
    pub raw_size: u32,
    pub flags: u32,
}

#[derive(Debug)]
pub struct Image {
    data: Vec<u8>,
    pub base: u32,
    pub entry: u32,
    pub dll: bool,
    pub sections: Vec<Section>,
    pub imports: BTreeMap<u32, Import>,
    pub relocations: Vec<u32>,
    headers_size: u32,
}

impl Image {
    #[cfg(test)]
    pub(crate) fn fixture(address: u32, data: Vec<u8>, relocations: Vec<u32>) -> Self {
        let size = data.len() as u32;
        Self {
            data,
            base: address,
            entry: address,
            dll: false,
            sections: vec![Section {
                address,
                virtual_size: size,
                offset: 0,
                raw_size: size,
                flags: 0x60000020,
            }],
            imports: BTreeMap::new(),
            relocations,
            headers_size: 0,
        }
    }
    pub fn open(path: &Path) -> Result<Self> {
        Self::parse(fs::read(path).with_context(|| format!("Read {}", path.display()))?)
    }

    pub fn parse(data: Vec<u8>) -> Result<Self> {
        let pe = PE::parse(&data)?;
        ensure!(
            !pe.is_64 && pe.header.coff_header.machine == 0x14c,
            "Expected a Win32 x86 PE image"
        );
        let optional = pe
            .header
            .optional_header
            .context("Missing PE optional header")?;
        let base = u32::try_from(pe.image_base)?;
        let entry = base
            .checked_add(pe.entry as u32)
            .context("PE entry overflow")?;
        let sections = pe
            .sections
            .iter()
            .map(|s| {
                Ok(Section {
                    address: base
                        .checked_add(s.virtual_address)
                        .context("PE section address overflow")?,
                    virtual_size: s.virtual_size,
                    offset: s.pointer_to_raw_data,
                    raw_size: s.size_of_raw_data,
                    flags: s.characteristics,
                })
            })
            .collect::<Result<Vec<_>>>()?;
        let imports = pe
            .imports
            .iter()
            .map(|i| {
                Ok((
                    base.checked_add(i.offset as u32)
                        .context("Import address overflow")?,
                    Import {
                        dll: i.dll.to_lowercase(),
                        name: if i.rva == 0 {
                            ImportName::Ordinal(i.ordinal)
                        } else {
                            ImportName::Name(i.name.to_string())
                        },
                    },
                ))
            })
            .collect::<Result<_>>()?;
        let relocation_directory = optional
            .data_directories
            .get_base_relocation_table()
            .copied();
        let dll = pe.is_lib;
        let mut image = Self {
            data,
            base,
            entry,
            dll,
            sections,
            imports,
            relocations: Vec::new(),
            headers_size: optional.windows_fields.size_of_headers,
        };
        if let Some(directory) = relocation_directory
            && directory.size != 0
        {
            let address = base
                .checked_add(directory.virtual_address)
                .context("Relocation directory overflow")?;
            image.relocations =
                read_relocations(base, image.read_exact(address, directory.size as usize)?)?;
        }
        Ok(image)
    }

    pub fn section(&self, address: u32) -> Option<&Section> {
        self.sections.iter().find(|s| {
            address >= s.address
                && u64::from(address)
                    < u64::from(s.address) + u64::from(s.virtual_size.max(s.raw_size))
        })
    }

    /// Return available file-backed bytes without fabricating zeroed storage.
    pub fn read(&self, address: u32, size: usize) -> &[u8] {
        let (offset, available) = if let Some(section) = self.section(address) {
            let displacement = (address - section.address) as usize;
            (
                section.offset as usize + displacement,
                (section.raw_size as usize).saturating_sub(displacement),
            )
        } else if address >= self.base && address - self.base < self.headers_size {
            (
                (address - self.base) as usize,
                (self.headers_size - (address - self.base)) as usize,
            )
        } else {
            return &[];
        };
        if offset >= self.data.len() {
            return &[];
        }
        &self.data[offset..offset + size.min(available).min(self.data.len() - offset)]
    }

    pub fn read_exact(&self, address: u32, size: usize) -> Result<&[u8]> {
        let data = self.read(address, size);
        ensure!(
            data.len() == size,
            "Truncated image read at {address:#x}: wanted {size}, found {}",
            data.len()
        );
        Ok(data)
    }

    pub fn u32(&self, address: u32) -> Option<u32> {
        self.read(address, 4)
            .try_into()
            .ok()
            .map(u32::from_le_bytes)
    }

    pub fn relocated(&self, address: u32) -> bool {
        self.relocations.binary_search(&address).is_ok()
    }

    pub fn has_relocation(&self, address: u32, size: usize) -> bool {
        let index = self.relocations.partition_point(|a| *a < address);
        self.relocations
            .get(index)
            .is_some_and(|a| u64::from(*a) < u64::from(address) + size as u64)
    }

    pub fn constant_storage(&self, address: u32, executable: bool) -> bool {
        self.section(address)
            .is_some_and(|s| s.flags & 0x80000000 == 0 || executable && s.flags & 0x20000000 != 0)
    }

    pub fn imported_target(&self, address: u32) -> Option<&Import> {
        let raw = self.read(address, 6);
        if raw.len() == 6 && raw[..2] == [0xff, 0x25] {
            self.imports
                .get(&u32::from_le_bytes(raw[2..].try_into().unwrap()))
        } else {
            None
        }
    }

    pub fn classes(&self) -> BTreeMap<u32, Class> {
        let mut classes = BTreeMap::new();
        for &cell in &self.relocations {
            let Some(vmt) = cell.checked_add(76) else {
                continue;
            };
            if cell % 4 != 0 || self.u32(cell) != Some(vmt) {
                continue;
            }
            let Some(size) = self.u32(cell + 36).filter(|s| (4..0x80000000).contains(s)) else {
                continue;
            };
            let Some(name_address) = self.u32(cell + 32) else {
                continue;
            };
            let Some(&length) = self.read(name_address, 1).first() else {
                continue;
            };
            let name = self.read(name_address.saturating_add(1), length as usize);
            if name.len() != length as usize
                || name.is_empty()
                || !(name[0].is_ascii_alphabetic() || name[0] == b'_')
                || !name.iter().all(|c| c.is_ascii_alphanumeric() || *c == b'_')
            {
                continue;
            }
            let parent = self
                .u32(cell + 40)
                .filter(|p| *p != 0)
                .and_then(|p| self.u32(p));
            classes.insert(
                vmt,
                Class {
                    vmt,
                    name: String::from_utf8(name.to_vec()).unwrap(),
                    size,
                    parent,
                },
            );
        }
        classes
    }
}

#[derive(Debug, Serialize)]
pub struct Class {
    pub vmt: u32,
    pub name: String,
    pub size: u32,
    pub parent: Option<u32>,
}

fn read_relocations(base: u32, data: &[u8]) -> Result<Vec<u32>> {
    let mut result = Vec::new();
    let mut offset = 0;
    while offset + 8 <= data.len() {
        let page = u32::from_le_bytes(data[offset..offset + 4].try_into()?);
        let size = u32::from_le_bytes(data[offset + 4..offset + 8].try_into()?) as usize;
        if size == 0 {
            break;
        }
        if size < 8 || !size.is_multiple_of(2) || size > data.len() - offset {
            bail!("Malformed PE relocation block")
        }
        for entry in data[offset + 8..offset + size]
            .as_chunks::<2>()
            .0
            .iter()
            .map(|b| u16::from_le_bytes(*b))
        {
            if entry >> 12 == 3 {
                result.push(
                    base.checked_add(page)
                        .and_then(|a| a.checked_add(u32::from(entry & 0xfff)))
                        .context("Relocation address overflow")?,
                );
            }
        }
        offset += size;
    }
    result.sort_unstable();
    result.dedup();
    Ok(result)
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn relocation_validation() -> Result<()> {
        let mut block = Vec::new();
        block.extend(0x1000u32.to_le_bytes());
        block.extend(12u32.to_le_bytes());
        block.extend(0x3020u16.to_le_bytes());
        block.extend(0x0024u16.to_le_bytes());
        assert_eq!(read_relocations(0x400000, &block)?, vec![0x401020]);
        assert!(read_relocations(0x400000, &block[..10]).is_err());
        block[4] = 7;
        assert!(read_relocations(0x400000, &block).is_err());
        Ok(())
    }
}
