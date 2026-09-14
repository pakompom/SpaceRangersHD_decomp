//! Private compiler service: warm Wine launcher, content-validated DCC32 builds.
use super::state;
use anyhow::{Context, Result, bail, ensure};
use serde_json::{Value, json};
use std::{
    fs::{self, File, OpenOptions},
    io::{BufRead, BufReader, Read, Write},
    os::unix::{
        fs::PermissionsExt,
        net::{UnixListener, UnixStream},
        process::CommandExt,
    },
    path::{Path, PathBuf},
    process::{Child, ChildStdin, Command, Stdio},
    sync::{
        Arc, Mutex,
        atomic::{AtomicBool, Ordering},
        mpsc::{self, Receiver},
    },
    thread,
    time::{Duration, Instant},
};

fn send_message(writer: &mut impl Write, value: &Value) -> Result<()> {
    let mut data = serde_json::to_vec(value)?;
    data.push(b'\n');
    writer.write_all(&data)?;
    Ok(())
}

#[derive(Clone)]
pub struct Toolchain {
    pub root: PathBuf,
    pub cache: PathBuf,
    pub wine: PathBuf,
    pub prefix: PathBuf,
    pub compiler: PathBuf,
    pub library: PathBuf,
    pub flags: Vec<String>,
    pub worker: String,
}
fn expand(root: &Path, text: &str) -> PathBuf {
    let path = if let Some(rest) = text.strip_prefix("~/") {
        PathBuf::from(std::env::var_os("HOME").unwrap_or_default()).join(rest)
    } else {
        PathBuf::from(text)
    };
    if path.is_absolute() {
        path
    } else {
        root.join(path)
    }
}
pub fn worker_name(name: Option<&str>) -> Result<String> {
    let name = name
        .map(String::from)
        .unwrap_or_else(|| std::env::var("RANGERS_WORKER").unwrap_or("default".into()));
    ensure!(
        !name.is_empty()
            && name.len() <= 24
            && name
                .bytes()
                .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'_' || b == b'-')
            && name.as_bytes()[0].is_ascii_alphanumeric(),
        "Worker name must be 1–24 lowercase letters, digits, underscores or hyphens"
    );
    Ok(name)
}
pub fn winpath(path: &Path) -> String {
    format!("Z:{}", path.to_string_lossy().replace('/', "\\"))
}
use crate::util::write_changed;
fn wait_child(child: &mut Child, timeout: Duration) -> Result<i32> {
    let start = Instant::now();
    loop {
        if let Some(status) = child.try_wait()? {
            return Ok(status.code().unwrap_or(-1));
        }
        if start.elapsed() >= timeout {
            child.kill()?;
            child.wait()?;
            bail!("process timed out after {} seconds", timeout.as_secs())
        }
        thread::sleep(Duration::from_millis(20));
    }
}
impl Toolchain {
    pub fn load(root: &Path, name: Option<&str>) -> Result<Self> {
        let root = root.canonicalize()?;
        let config: toml::Value = toml::from_str(&fs::read_to_string(root.join("project.toml"))?)?;
        let worker = worker_name(name)?;
        let cache = root.join(
            config["project"]["cache"]
                .as_str()
                .context("cache path missing")?,
        );
        let cache = if worker == "default" {
            cache
        } else {
            cache.join("workers").join(&worker)
        };
        let compiler = expand(
            &root,
            config["compiler"]["executable"]
                .as_str()
                .context("compiler path missing")?,
        );
        let compiler = compiler.canonicalize().unwrap_or(compiler);
        let library = config["compiler"]
            .get("library")
            .and_then(toml::Value::as_str)
            .map(|path| expand(&root, path))
            .unwrap_or_else(|| compiler.parent().unwrap().parent().unwrap().join("lib"));
        let library = library.canonicalize().unwrap_or(library);
        let bundled_wine =
            root.join(".local/wine/Wine Stable.app/Contents/Resources/wine/bin/wine");
        let wine_setting = std::env::var("WINE").ok().unwrap_or_else(|| {
            if cfg!(target_os = "macos") && bundled_wine.is_file() {
                bundled_wine.to_string_lossy().into_owned()
            } else {
                config["compiler"]
                    .get("wine")
                    .and_then(toml::Value::as_str)
                    .unwrap_or("wine")
                    .into()
            }
        });
        let wine = if wine_setting.contains('/') {
            expand(&root, &wine_setting)
        } else {
            std::env::split_paths(&std::env::var_os("PATH").unwrap_or_default())
                .map(|p| p.join(&wine_setting))
                .find(|p| p.is_file())
                .with_context(|| {
                    format!("{wine_setting} not found on PATH; install Wine or set WINE")
                })?
        };
        let prefix = root.join(".local/wineprefix");
        let flags = config["compiler"]
            .get("flags")
            .and_then(toml::Value::as_array)
            .map(|v| {
                v.iter()
                    .filter_map(toml::Value::as_str)
                    .map(String::from)
                    .collect()
            })
            .unwrap_or_else(|| ["-$O-", "-$R-", "-$Q-", "-$B-"].map(String::from).to_vec());
        Ok(Self {
            root,
            cache,
            wine,
            prefix,
            compiler,
            library,
            flags,
            worker,
        })
    }
    pub fn state(&self) -> PathBuf {
        self.cache.join("compiler-worker")
    }
    pub fn socket(&self) -> PathBuf {
        self.cache.join("dcc32.sock")
    }
    pub fn configuration(&self) -> Value {
        json!({"wine":self.wine,"compiler":self.compiler,"library":self.library,"prefix":self.prefix,"flags":self.flags})
    }
    pub fn compiler_command(
        &self,
        source: &Path,
        directory: &Path,
        rebuild: bool,
    ) -> Result<Vec<String>> {
        let source = source.canonicalize()?;
        let directory = directory.canonicalize()?;
        let cache = self.cache.canonicalize()?;
        ensure!(
            directory.starts_with(&cache)
                && source.parent() == Some(directory.as_path())
                && source
                    .extension()
                    .is_some_and(|s| s.eq_ignore_ascii_case("dpr"))
                && !(self.worker == "default" && directory.starts_with(cache.join("workers"))),
            "Compiler requests must name a .dpr inside its project cache build directory"
        );
        let mut command = vec![
            winpath(&self.compiler),
            "--no-config".into(),
            if rebuild { "-B" } else { "-M" }.into(),
            "-Q".into(),
            "-GD".into(),
        ];
        command.extend(self.flags.clone());
        command.push(format!(
            "-U{};{}",
            winpath(&directory),
            winpath(&self.library)
        ));
        command.push(format!("-N{}", winpath(&directory)));
        command.push(winpath(&source));
        Ok(command)
    }
    fn command(&self, args: &[String], directory: Option<&Path>) -> Command {
        let mut command = Command::new(&self.wine);
        if let Some(dir) = directory {
            command.current_dir(dir);
        }
        command
            .args(args)
            .env("WINEDEBUG", "-all")
            .env("WINEPREFIX", &self.prefix)
            .env("WINEDLLOVERRIDES", "mscoree,mshtml=");
        command
    }
    fn warm(&self) -> Result<()> {
        for file in [&self.wine, &self.compiler] {
            ensure!(file.is_file(), "Missing compiler tool: {}", file.display());
        }
        let log = File::create(self.state().join("warmup.log"))?;
        let mut child = self
            .command(&["cmd".into(), "/c".into(), "exit".into()], None)
            .stdin(Stdio::null())
            .stdout(log.try_clone()?)
            .stderr(log)
            .spawn()?;
        ensure!(
            wait_child(&mut child, Duration::from_secs(120))? == 0,
            "Wine initialization failed; see warmup.log"
        );
        Ok(())
    }
    pub fn request(&self, action: &str, payload: Value, timeout: Duration) -> Result<Value> {
        let mut socket=UnixStream::connect(self.socket()).with_context(||format!("Compiler worker {} unavailable; run ./decomp worker start --worker {} with host process access",self.worker,self.worker))?;
        socket.set_read_timeout(Some(timeout))?;
        socket.set_write_timeout(Some(timeout))?;
        let mut value = payload;
        value["action"] = json!(action);
        value["configuration"] = self.configuration();
        send_message(&mut socket, &value)?;
        let mut line = String::new();
        BufReader::new(socket)
            .take(8 * 1024 * 1024)
            .read_line(&mut line)?;
        let result: Value = serde_json::from_str(&line)
            .context("compiler worker closed the connection or returned invalid JSON")?;
        if let Some(error) = result.get("error") {
            bail!("{error}")
        }
        Ok(result)
    }
    pub fn status(&self) -> Option<Value> {
        self.request("status", json!({}), Duration::from_secs(1))
            .ok()
    }
    pub fn start(&self) -> Result<Value> {
        if let Some(status) = self.status() {
            return Ok(status);
        }
        fs::create_dir_all(self.state())?;
        let lock = File::create(self.state().join("start.lock"))?;
        lock.lock()?;
        if let Some(status) = self.status() {
            return Ok(status);
        }
        let log = OpenOptions::new()
            .create(true)
            .append(true)
            .open(self.state().join("worker.log"))?;
        let mut child = Command::new(std::env::current_exe()?)
            .arg("worker-serve")
            .arg(&self.root)
            .arg(&self.worker)
            .current_dir(&self.root)
            .stdin(Stdio::null())
            .stdout(log.try_clone()?)
            .stderr(log)
            .process_group(0)
            .spawn()?;
        let start = Instant::now();
        while start.elapsed() < Duration::from_secs(180) {
            if let Some(status) = self.status() {
                return Ok(status);
            }
            if child.try_wait()?.is_some() {
                break;
            }
            thread::sleep(Duration::from_millis(100));
        }
        let _ = child.kill();
        let _ = child.wait();
        let text = fs::read_to_string(self.state().join("worker.log")).unwrap_or_default();
        bail!(
            "Compiler worker failed to start:\n{}",
            text.chars()
                .rev()
                .take(3000)
                .collect::<String>()
                .chars()
                .rev()
                .collect::<String>()
        )
    }
}

pub(super) struct Host {
    child: Child,
    input: ChildStdin,
    lines: Receiver<Result<String, String>>,
}
impl Host {
    fn new(toolchain: &Toolchain) -> Result<Self> {
        let directory = toolchain.cache.join("build/compiler-host");
        fs::create_dir_all(&directory)?;
        let source = directory.join("CompilerHost.dpr");
        let executable = source.with_extension("exe");
        let maintained = include_bytes!("CompilerHost.dpr");
        if !executable.exists() || !fs::read(&source).is_ok_and(|b| b == maintained) {
            write_changed(&source, maintained)?;
            let log = File::create(directory.join("compiler.log"))?;
            let mut child = toolchain
                .command(
                    &toolchain.compiler_command(&source, &directory, true)?,
                    Some(&directory),
                )
                .stdin(Stdio::null())
                .stdout(log.try_clone()?)
                .stderr(log)
                .spawn()?;
            ensure!(
                wait_child(&mut child, Duration::from_secs(120))? == 0,
                "Compiler host build failed"
            );
        }
        let errors = OpenOptions::new()
            .create(true)
            .append(true)
            .open(toolchain.state().join("host.log"))?;
        let mut child = toolchain
            .command(&[winpath(&executable)], Some(&directory))
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(errors)
            .spawn()?;
        let output = child.stdout.take().unwrap();
        let input = child.stdin.take().unwrap();
        let (tx, lines) = mpsc::channel();
        thread::spawn(move || {
            for line in BufReader::new(output).lines() {
                if tx.send(line.map_err(|e| e.to_string())).is_err() {
                    break;
                }
            }
        });
        let host = Self {
            child,
            input,
            lines,
        };
        ensure!(host.line(15)? == "READY", "Compiler host failed to start");
        Ok(host)
    }
    fn line(&self, seconds: u64) -> Result<String> {
        self.lines
            .recv_timeout(Duration::from_secs(seconds))
            .context("Compiler host response timed out or exited")?
            .map_err(anyhow::Error::msg)
    }
    pub(super) fn compile(
        &mut self,
        toolchain: &Toolchain,
        source: &Path,
        directory: &Path,
        rebuild: bool,
    ) -> Result<i32> {
        let command = toolchain
            .compiler_command(source, directory, rebuild)?
            .iter()
            .map(|s| quote_windows(s))
            .collect::<Vec<_>>()
            .join(" ");
        let fields = [
            winpath(directory),
            command,
            winpath(&directory.join("compiler.log")),
        ];
        ensure!(
            !fields.iter().any(|s| s.contains(['\r', '\n'])),
            "Compiler paths cannot contain line breaks"
        );
        write!(self.input, "{}\r\n", fields.join("\r\n"))?;
        self.input.flush()?;
        Ok(self.line(125)?.trim().parse()?)
    }
}
impl Drop for Host {
    fn drop(&mut self) {
        let _ = self.input.write_all(b"\r\n");
        let _ = wait_child(&mut self.child, Duration::from_secs(3));
    }
}
fn quote_windows(value: &str) -> String {
    let quoted = value.is_empty() || value.contains([' ', '\t']);
    let mut out = String::new();
    if quoted {
        out.push('"');
    }
    let mut slashes = 0;
    for c in value.chars() {
        if c == '\\' {
            slashes += 1;
            continue;
        }
        if c == '"' {
            out.push_str(&"\\".repeat(slashes * 2 + 1));
            out.push(c);
        } else {
            out.push_str(&"\\".repeat(slashes));
            out.push(c);
        }
        slashes = 0;
    }
    out.push_str(&"\\".repeat(slashes * if quoted { 2 } else { 1 }));
    if quoted {
        out.push('"');
    }
    out
}

pub fn serve(toolchain: Toolchain) -> Result<()> {
    fs::create_dir_all(toolchain.state())?;
    let start = Instant::now();
    toolchain.warm()?;
    let host = Host::new(&toolchain)?;
    let state = Arc::new(Mutex::new(
        json!({"pid":std::process::id(),"worker":toolchain.worker,"prefix":toolchain.prefix,"warmup_seconds":start.elapsed().as_secs_f64(),"builds":0,"active":null,"last_seconds":null,"implementation":"rust"}),
    ));
    let core = Arc::new(Mutex::new(host));
    let stopped = Arc::new(AtomicBool::new(false));
    if toolchain.socket().exists() {
        fs::remove_file(toolchain.socket())?;
    }
    let listener = UnixListener::bind(toolchain.socket())?;
    fs::set_permissions(toolchain.socket(), fs::Permissions::from_mode(0o600))?;
    listener.set_nonblocking(true)?;
    while !stopped.load(Ordering::Relaxed) {
        match listener.accept() {
            Ok((mut stream, _)) => {
                let (toolchain, state, core, stopped) = (
                    toolchain.clone(),
                    state.clone(),
                    core.clone(),
                    stopped.clone(),
                );
                thread::spawn(move || {
                    let result = (|| -> Result<Value> {
                        // Accepted sockets inherit O_NONBLOCK on macOS. Responses can
                        // exceed the socket buffer; a partial write must not truncate JSON.
                        stream.set_nonblocking(false)?;
                        stream.set_read_timeout(Some(Duration::from_secs(5)))?;
                        let mut line = String::new();
                        BufReader::new(stream.try_clone()?)
                            .take(65536)
                            .read_line(&mut line)?;
                        let request: Value = serde_json::from_str(&line)?;
                        match request["action"].as_str() {
                            Some("status") => Ok(state.lock().unwrap().clone()),
                            Some("stop") => {
                                ensure!(
                                    state.lock().unwrap()["active"].is_null(),
                                    "A compilation is active; stop after it finishes"
                                );
                                stopped.store(true, Ordering::Relaxed);
                                Ok(json!({"stopped":true}))
                            }
                            Some("compile") => {
                                ensure!(
                                    request["configuration"] == toolchain.configuration(),
                                    "Compiler configuration changed; restart the worker"
                                );
                                let mut core = core
                                    .try_lock()
                                    .map_err(|_| anyhow::anyhow!("Compiler worker is busy"))?;
                                let source = PathBuf::from(
                                    request["source"].as_str().context("source missing")?,
                                )
                                .canonicalize()?;
                                let directory = PathBuf::from(
                                    request["directory"].as_str().context("directory missing")?,
                                )
                                .canonicalize()?;
                                toolchain.compiler_command(&source, &directory, true)?;
                                state.lock().unwrap()["active"] = json!(source);
                                let result =
                                    state::compile(&mut core, &toolchain, &source, &directory);
                                let mut state = state.lock().unwrap();
                                state["active"] = Value::Null;
                                if let Ok(result) = &result
                                    && result["reused"] != true
                                {
                                    state["builds"] =
                                        json!(state["builds"].as_u64().unwrap_or(0) + 1);
                                    state["last_seconds"] = result["seconds"].clone();
                                }
                                result
                            }
                            _ => bail!("Supported worker actions: status, compile, stop"),
                        }
                    })()
                    .unwrap_or_else(|e| json!({"error":format!("{e:#}")}));
                    if let Err(error) = send_message(&mut stream, &result) {
                        eprintln!("worker response: {error}");
                    }
                });
            }
            Err(e) if e.kind() == std::io::ErrorKind::WouldBlock => {
                thread::sleep(Duration::from_millis(20))
            }
            Err(e) => return Err(e.into()),
        }
    }
    drop(listener);
    fs::remove_file(toolchain.socket())?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn library_selection_changes_search_and_build_identity() -> Result<()> {
        let root = std::env::temp_dir().join(format!("dcc-library-{}", std::process::id()));
        fs::create_dir_all(root.join("cache"))?;
        let config = "[project]\ncache = 'cache'\n[compiler]\nexecutable = 'bin/dcc32.exe'\nwine = '/usr/bin/true'\n";
        fs::write(root.join("project.toml"), config)?;
        let default = Toolchain::load(&root, None)?;
        assert_eq!(default.library, default.root.join("lib"));
        fs::write(
            root.join("project.toml"),
            format!("{config}library = 'updated/lib'\n"),
        )?;
        let updated = Toolchain::load(&root, None)?;
        assert_ne!(default.configuration(), updated.configuration());
        let source = root.join("cache/Probe.dpr");
        fs::write(&source, "program Probe; begin end.")?;
        let args = updated.compiler_command(&source, &updated.cache, true)?;
        assert!(args.contains(&format!(
            "-U{};{}",
            winpath(&updated.cache),
            winpath(&updated.root.join("updated/lib"))
        )));
        assert!(!args.iter().any(|a| a.ends_with(&winpath(&default.library))));
        Ok(())
    }

    #[test]
    fn large_worker_reply_is_complete() -> Result<()> {
        let (mut sender, receiver) = UnixStream::pair()?;
        let value = json!({"output":"compiler line\r\n".repeat(65536)});
        let expected = value.clone();
        let thread = thread::spawn(move || send_message(&mut sender, &value));
        let mut text = String::new();
        BufReader::new(receiver).read_line(&mut text)?;
        thread.join().unwrap()?;
        assert_eq!(serde_json::from_str::<Value>(&text)?, expected);
        Ok(())
    }
    #[test]
    fn windows_quoting() {
        assert_eq!(
            quote_windows("C:\\Program Files\\x.exe"),
            "\"C:\\Program Files\\x.exe\""
        );
        assert_eq!(quote_windows("a\\\"b"), "a\\\\\\\"b");
        assert_eq!(quote_windows(""), "\"\"");
    }
    #[test]
    fn names_are_scoped() {
        assert!(worker_name(Some("a")).is_ok());
        for name in ["../a", "", "A", "-x", "a/b"] {
            assert!(worker_name(Some(name)).is_err());
        }
    }
}
