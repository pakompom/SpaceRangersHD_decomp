//! PE resource leaves and Delphi's generated PACKAGEINFO records.
use super::image::Image;
use anyhow::{Context, Result, ensure};
use goblin::pe::PE;
use serde::Serialize;

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Serialize)]
#[serde(untagged)]
pub enum Key {
    Id(u32),
    Name(String),
}

pub struct Resource<'a> {
    pub kind: Key,
    pub name: Key,
    pub language: u32,
    pub data: &'a [u8],
}

fn bytes(data: &[u8], offset: usize, size: usize) -> Result<&[u8]> {
    data.get(
        offset
            ..offset
                .checked_add(size)
                .context("Resource offset overflow")?,
    )
    .context("Truncated resource record")
}
fn word(data: &[u8], offset: usize) -> Result<u16> {
    Ok(u16::from_le_bytes(bytes(data, offset, 2)?.try_into()?))
}
fn dword(data: &[u8], offset: usize) -> Result<u32> {
    Ok(u32::from_le_bytes(bytes(data, offset, 4)?.try_into()?))
}
fn key(data: &[u8], value: u32) -> Result<Key> {
    if value & 0x80000000 == 0 {
        return Ok(Key::Id(value));
    }
    let offset = (value & 0x7fffffff) as usize;
    let count = usize::from(word(data, offset)?);
    let chars = bytes(data, offset + 2, count * 2)?
        .as_chunks::<2>()
        .0
        .iter()
        .map(|b| u16::from_le_bytes(*b))
        .collect::<Vec<_>>();
    Ok(Key::Name(String::from_utf16(&chars)?))
}
fn directory(data: &[u8], offset: usize) -> Result<Vec<(Key, u32)>> {
    let count = usize::from(word(data, offset + 12)?) + usize::from(word(data, offset + 14)?);
    bytes(data, offset + 16, count * 8)?;
    (0..count)
        .map(|i| {
            let row = offset + 16 + i * 8;
            Ok((key(data, dword(data, row)?)?, dword(data, row + 4)?))
        })
        .collect()
}
fn subdirectory(value: u32) -> Result<usize> {
    ensure!(value & 0x80000000 != 0, "Expected a resource directory");
    Ok((value & 0x7fffffff) as usize)
}

pub fn read<'a>(file: &[u8], image: &'a Image) -> Result<Vec<Resource<'a>>> {
    let pe = PE::parse(file)?;
    let Some(table) = pe
        .header
        .optional_header
        .context("PE optional header missing")?
        .data_directories
        .get_resource_table()
        .copied()
        .filter(|d| d.size != 0)
    else {
        return Ok(Vec::new());
    };
    let address = image
        .base
        .checked_add(table.virtual_address)
        .context("Resource RVA overflow")?;
    let data = image.read_exact(address, table.size as usize)?;
    let mut out = Vec::new();
    for (kind, child) in directory(data, 0)? {
        for (name, child) in directory(data, subdirectory(child)?)? {
            for (language, leaf) in directory(data, subdirectory(child)?)? {
                let Key::Id(language) = language else {
                    anyhow::bail!("Named resource language")
                };
                ensure!(
                    leaf & 0x80000000 == 0,
                    "Resource leaf points to a directory"
                );
                let leaf = leaf as usize;
                let rva = dword(data, leaf)?;
                let size = dword(data, leaf + 4)?;
                let address = image
                    .base
                    .checked_add(rva)
                    .context("Resource data RVA overflow")?;
                out.push(Resource {
                    kind: kind.clone(),
                    name: name.clone(),
                    language,
                    data: image.read_exact(address, size as usize)?,
                });
            }
        }
    }
    Ok(out)
}

#[derive(Debug, Serialize)]
pub struct Unit {
    pub name: String,
    pub flags: u8,
}
#[derive(Debug, Serialize)]
pub struct PackageInfo {
    pub flags: u32,
    pub requires: Vec<String>,
    pub units: Vec<Unit>,
}
impl PackageInfo {
    pub fn parse(data: &[u8]) -> Result<Self> {
        // SysUtils.TPackageInfoHeader, TPkgName and TUnitName. The byte before
        // each name is its compiler hash; a unit also carries a flags byte.
        fn name(data: &[u8], offset: &mut usize) -> Result<String> {
            bytes(data, *offset, 1)?;
            *offset += 1;
            let end = data[*offset..]
                .iter()
                .position(|b| *b == 0)
                .context("Unterminated PACKAGEINFO name")?
                + *offset;
            let name = std::str::from_utf8(&data[*offset..end])?.to_owned();
            *offset = end + 1;
            Ok(name)
        }
        let flags = dword(data, 0)?;
        let count = dword(data, 4)? as usize;
        ensure!(
            count <= data.len() / 2,
            "Invalid PACKAGEINFO requires count"
        );
        let mut offset = 8;
        let mut requires = Vec::new();
        for _ in 0..count {
            requires.push(name(data, &mut offset)?);
        }
        let count = dword(data, offset)? as usize;
        offset += 4;
        ensure!(
            count <= (data.len() - offset) / 3,
            "Invalid PACKAGEINFO unit count"
        );
        let mut units = Vec::new();
        for _ in 0..count {
            let flags = bytes(data, offset, 1)?[0];
            offset += 1;
            units.push(Unit {
                name: name(data, &mut offset)?,
                flags,
            });
        }
        ensure!(
            data[offset..].len() < 4 && data[offset..].iter().all(|b| *b == 0),
            "Unexpected PACKAGEINFO trailing data"
        );
        Ok(Self {
            flags,
            requires,
            units,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn package_records_keep_order_flags_and_require_hashes() {
        let data = b"\0\0\x10\xcc\x01\0\0\0\x20rtl\0\x02\0\0\0\x01\x20Root\0\x10\x21Implicit\0\0";
        let info = PackageInfo::parse(data).unwrap();
        assert_eq!(info.requires, ["rtl"]);
        assert_eq!(info.units[0].name, "Root");
        assert_eq!(info.units[1].flags, 0x10);
        assert!(PackageInfo::parse(&data[..data.len() - 3]).is_err());
        assert!(directory(&[0; 15], 0).is_err());
        assert!(key(&[0xff, 0xff], 0x80000000).is_err());
    }
}
