# Space Rangers HD: A War Apart - Decompilation

*Космические рейнджеры HD: Революция*

A decompilation project recovering the game’s Delphi source code. The recovered
source compiles to a **byte-for-byte identical** `Rangers.exe`.

Both binaries report game version **2.1.2500** (file version `2.1.2500.0`).

| Branch | Build | Distribution | Size (bytes) |
| --- | --- | --- | ---: |
| [`main`](https://github.com/pakompom/SpaceRangersHD_decomp/tree/main) | 2026-08-11 | Prerelease | 4,999,680 |
| [`build-2025-10-13`](https://github.com/pakompom/SpaceRangersHD_decomp/tree/build-2025-10-13) | 2025-10-13 | Steam/GOG release | 4,995,584 |

<details>
<summary>SHA-256 checksums</summary>

Prerelease (2026-08-11):

```text
f00343363043cbb9c2d10c1216e9f4c37b5eaa5e4d58f37a45284cae528fdc1d
```

Steam/GOG release (2025-10-13):

```text
83300344af802bc51e64389c58f047e5afdf195c133048098be3881fae29ed98
```

</details>

**AI disclosure:** This decompilation project was carried out almost entirely by
GPT-6 Astra in Codex, with some human steering.

Install the [prerequisites](docs/development.md#setup), then run:

```sh
./decomp setup
./decomp verify
```

Setup downloads and prepares the Delphi toolchain. Verification checks the whole
executable against the original SHA-256. Game data comes from your installed game.

[Development and progress reports](docs/development.md) ·
[Pascal annotations](docs/declarations.md)

See also:

- [okgf](https://github.com/pakompom/okgf) - a portable C reimplementation of
  the game's `okgf.dll`, useful for ports to other platforms.
- [MatrixGame](https://github.com/twoweeks/MatrixGame) - the published source
  code for the 3D planetary battle engine used by Space Rangers 2, Reboot and
  Revolution.
- [SpaceRangersHD_FPC](https://github.com/pakompom/SpaceRangersHD_FPC/tree/main) - a
  reference Free Pascal port of the recovered source, limited to the fixes needed
  to run the game across operating systems and CPU architectures.
- [SpaceRangersHD_FPC (personal)](https://github.com/pakompom/SpaceRangersHD_FPC/tree/personal) -
  a customised version of the Free Pascal port with performance optimisations
  and extra features.

Unofficial; not affiliated with the game's developers or publisher.
See [rights and attribution](NOTICE.md) and the [tooling license](LICENSE).
