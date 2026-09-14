//! JSON requests executed by IDA's own batch IDAPython interface.
use anyhow::{Context, Result, ensure};
use serde_json::{Value, json};
use std::{
    fs,
    path::Path,
    process::{Command, Stdio},
    time::{Duration, Instant},
};

pub fn raw(root: &Path, db: &Path, operation: &str, arguments: Value) -> Result<Value> {
    let db = db.canonicalize().context(
        "Database missing; open the original executable in IDA and save its database first",
    )?;
    let directory = root.join(".local/ida");
    fs::create_dir_all(&directory)?;
    let stem = format!("{}-{}", std::process::id(), operation);
    let request_path = directory.join(format!("{stem}.request.json"));
    let response_path = directory.join(format!("{stem}.response.json"));
    let log = directory.join(format!("{stem}.log"));
    let mut request = arguments;
    request["operation"] = json!(operation);
    request["database"] = json!(db);
    request["response"] = json!(response_path);
    fs::write(&request_path, serde_json::to_vec(&request)?)?;
    if response_path.exists() {
        crate::util::remove_generated([response_path.clone()])?;
    }
    let executable = std::env::var_os("IDA").unwrap_or_else(|| "idat".into());
    let entry = root.join("toolchain/adapters/ida/entry.py");
    let mut child = Command::new(executable)
        .arg("-A")
        .arg(format!("-S\"{}\"", entry.display()))
        .arg(format!("-L{}", log.display()))
        .arg(db)
        .env("SRHD_IDA_REQUEST", &request_path)
        .env("QT_QPA_PLATFORM", "offscreen")
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .context(
            "Could not launch IDA; set IDA to the IDA batch executable (see docs/development.md)",
        )?;
    let start = Instant::now();
    let status = loop {
        if let Some(status) = child.try_wait()? {
            break status;
        }
        if start.elapsed() > Duration::from_secs(180) {
            child.kill()?;
            child.wait()?;
            anyhow::bail!("IDA timed out; see {}", log.display());
        }
        std::thread::sleep(Duration::from_millis(100));
    };
    let mut response: Value = serde_json::from_slice(
        &fs::read(&response_path)
            .with_context(|| format!("IDA produced no response; see {}", log.display()))?,
    )?;
    ensure!(
        status.success() && response["ok"] == true,
        "IDA request failed: {} (log: {})",
        response,
        log.display()
    );
    Ok(response["result"].take())
}

pub fn run(root: &Path, db: &Path, operation: &str, mut arguments: Value) -> Result<Value> {
    if ["coverage", "native_size"].contains(&operation) {
        arguments["classes"] = crate::inspect::vmt::report(root, db, &[], true)?["classes"].take();
    }
    let mut result = raw(root, db, operation, arguments)?;
    if operation == "native_size" {
        crate::inspect::sizes::metadata(root, &mut result)?;
    }
    Ok(result)
}
