# Development

## Setup

Python 3.11+, Rust 1.90+, Clang, 7-Zip and innoextract are required.
Linux needs Wine with 32-bit support. macOS setup downloads a pinned Wine build;
Apple Silicon also needs Rosetta 2.

Ubuntu 24.04 (x86-64):

```sh
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install --no-install-recommends build-essential clang python3 python3-venv innoextract p7zip-full wine wine32:i386 xvfb xauth
```

macOS, with Homebrew and the command-line developer tools:

```sh
xcode-select --install
brew install python rust innoextract sevenzip
```

Install Rust through [rustup](https://www.rust-lang.org/tools/install) if needed,
then run `./decomp setup`. This downloads the pinned inputs, prepares Delphi and
builds the tooling. Downloads and generated files go under `.local/`; Cargo uses
`target/`. Both directories are excluded from Git.

`WINE=/path/to/wine` selects an existing Wine install.
`./decomp setup --compiler-dir /path/to/original/bin` accepts the compiler and
linker pinned in `toolchain/inputs.json`; other inputs still download.

## Build and match

```sh
./decomp check
./decomp verify
```

`check` validates declarations and recovered bodies. `verify` builds
`.local/build/layout/Rangers.exe` and checks the whole file's SHA-256 against
`project.toml`, recording the result in `.local/verification.json`.
If `game/Rangers.exe` exists, it must also match byte for byte. Verification
requires no game installation or IDA database and does not execute the game.
On headless Linux, use `xvfb-run -a ./decomp verify`.

For per-function diagnostics, place the original at `game/Rangers.exe` and run
`./decomp match --all`. Narrow the selection with a source path or routine name,
for example `./decomp match source/quests`. Matching uses a separate build that
exports routines for inspection. Two startup metadata references remain
unresolved in that build; use `verify` to check the final executable.

The compiler worker starts automatically. Run `./decomp worker stop` after
changing compiler inputs or Wine so the next command starts a new worker.
Use separate checkouts and `.local/` directories for the two branches.
The current build uses `-B` to preserve shared-set alignment; the older build
precompiles `aGalaxyStruct` to reproduce its DCU alignment.

## Progress reports

`./decomp report` verifies the executable and writes `.local/report.json` in
[objdiff report v2 format](https://github.com/encounter/objdiff/blob/main/objdiff-core/protos/report.proto).
Use `-o PATH` to change the destination. A failed build or verification removes
any prior report there and produces no replacement.

The treemap groups recovered routines by source file and directory. Sizes count
native entry chunks, excluding shared tails, out-of-line chunks, precompiled
libraries, compiler-generated routines and data. Percentages cover these recovered
routines only. Reports require a complete match and do not track partial progress.

## Source and changes

`source/` groups annotated Delphi units by subsystem. Unit names share one
namespace; generated units use a flat directory. Folder grouping is independent
of the original unit boundaries.

Preserve native behavior, including bugs, and base interpretations on native code
evidence. Keep uncertain meanings explicit. Run `check` and `verify` after source
changes. See [declarations.md](declarations.md) for source structure and annotations.
Compiler controls live under `tests/delphi/`; compile one with `./decomp compile PATH`.
`./decomp --help` lists the available commands.

## Inputs and reproduction

`toolchain/inputs.json` pins download URLs and SHA-256 hashes, checked before reuse.
The code generator and resource linker come from the
[December 2007 RAD Studio media](https://archive.org/details/code-gear-radstudio-2007-dec-2007),
using compiler **11.0.2963.11001**. Setup fetches the installer and two component
archives directly from the archived ISO.

The runtime libraries and compiler DVCLAL resource come from the
[Delphi 2007 Update 4 distribution](https://archive.org/details/codegear-delphi-2007-lite-1.4).
Setup extracts these files without running the installers or Delphi IDE.

Preparation replaces the compiler's 16-byte DVCLAL resource with Update 4's value
and applies the hooks in `toolchain/delphi/`:

- `unit_order.s`: physical unit contribution order.
- `reference_order.s`: native reference-cell order.
- `metadata_order.s`: startup and PACKAGEINFO order.
- `build_metadata.s`: original build timestamps.

The adjacent TSV files hold settings for each build. RTTI names are not patched.
Two field-only `object` declarations reproduce the anonymous-type numbering;
their original spelling and placement remain uncertain. This compiler reproduces
the binary layout; the original build environment and some source spellings
remain unknown. Arithmetic identities in some bodies preserve argument-load order.

Matching changes belong in the recovered Pascal or compiler metadata layer;
avoid replacing Pascal with assembly or patching executable bytes to force a match.
Compiler preparation uses no target game binary, and the compiled executable is
not post-processed. `source/Rangers.res` supplies the application icons and version
resource; Delphi generates the runtime resources and PACKAGEINFO.

## Optional IDA integration

IDA 9.x with IDAPython supports native inspection and annotation updates.
Open the original executable in IDA, wait for analysis, and save the database to
`.local/Rangers.i64` (or set `project.database`). Close it before using batch mode.
Set `IDA` to IDA's batch executable, such as `idat`, or place it on PATH.

```sh
./decomp sync check
./decomp sync diff
./decomp sync apply
./decomp index
```

`diff` previews changes; `apply` saves them. For conflict handling and annotation
rules, see [Synchronizing with IDA](declarations.md#synchronizing-with-ida).
The tool runs `toolchain/adapters/ida/entry.py` through IDA's `-A` and `-S` options.
Requests, replies and logs go under `.local/ida/`. The adapter's `run(request)`
function can also be called from the IDAPython console.

`index` writes `.local/native_ranges.json`, which takes precedence over the bundled
reference. Review inventory changes before copying them into `reference/`.
