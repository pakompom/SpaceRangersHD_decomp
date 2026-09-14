use anyhow::Result;
use std::path::Path;

fn main() -> Result<()> {
    let args: Vec<_> = std::env::args().collect();
    if args.get(1).map(String::as_str) == Some("worker-serve") && args.len() == 4 {
        return rangers_tools::compiler::worker::serve(
            rangers_tools::compiler::worker::Toolchain::load(Path::new(&args[2]), Some(&args[3]))?,
        );
    }
    let status = rangers_tools::cli::run(&std::env::current_dir()?, &args[1..])?;
    std::process::exit(status);
}
