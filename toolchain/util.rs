//! Small shared I/O and binary representation helpers.
use anyhow::{Context, Result, ensure};
pub fn unhex(text: &str) -> Result<Vec<u8>> {
    ensure!(text.len().is_multiple_of(2), "Odd hexadecimal byte string");
    (0..text.len())
        .step_by(2)
        .map(|i| Ok(u8::from_str_radix(&text[i..i + 2], 16)?))
        .collect()
}

pub fn write_changed(path: &std::path::Path, bytes: &[u8]) -> Result<()> {
    if !std::fs::read(path).is_ok_and(|old| old == bytes) {
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        std::fs::write(path, bytes)?;
    }
    Ok(())
}
/// Remove obsolete generated files and directories without following symlinks.
pub fn remove_generated(paths: impl IntoIterator<Item = std::path::PathBuf>) -> Result<()> {
    for path in paths {
        let metadata = match std::fs::symlink_metadata(&path) {
            Ok(metadata) => metadata,
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => continue,
            Err(error) => return Err(error).with_context(|| format!("Inspect {}", path.display())),
        };
        let result = if metadata.is_dir() {
            std::fs::remove_dir_all(&path)
        } else {
            std::fs::remove_file(&path)
        };
        result.with_context(|| format!("Remove generated output {}", path.display()))?;
    }
    Ok(())
}

pub(crate) fn array<'a>(value: &'a serde_json::Value, key: &str) -> &'a [serde_json::Value] {
    value
        .get(key)
        .and_then(serde_json::Value::as_array)
        .map_or(&[], |a| a)
}
pub(crate) fn string<'a>(value: &'a serde_json::Value, key: &str) -> &'a str {
    value
        .get(key)
        .and_then(serde_json::Value::as_str)
        .unwrap_or("")
}
pub(crate) fn yes(value: &serde_json::Value, key: &str) -> bool {
    value
        .get(key)
        .and_then(serde_json::Value::as_bool)
        .unwrap_or(false)
}
pub(crate) fn integer(value: &serde_json::Value, key: &str) -> Result<i64> {
    value
        .get(key)
        .and_then(serde_json::Value::as_i64)
        .with_context(|| format!("missing integer {key}"))
}
