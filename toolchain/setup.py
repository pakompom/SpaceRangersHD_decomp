#!/usr/bin/env python3
"""Fetch checked compiler inputs and prepare the matching toolchain.

No installer or game executable is run. See docs/development.md for provenance.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import time
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
LOCAL = ROOT / '.local'
INPUTS = json.loads((ROOT / 'toolchain/inputs.json').read_text())


def sha256(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def checked(path, expected):
    actual = sha256(path)
    if actual != expected:
        raise RuntimeError(f'Input checksum failed for {path.name}: expected {expected}, got {actual}')
    return path


def download(spec, name):
    path = LOCAL / 'downloads' / name
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and sha256(path) == spec['sha256']:
        return path
    temporary = path.with_suffix(path.suffix + '.partial')
    print(f'Downloading {name}', flush=True)
    for attempt in range(3):
        try:
            request = urllib.request.Request(spec['url'], headers={'User-Agent': 'SpaceRangersHD-decomp-setup/1'})
            with urllib.request.urlopen(request, timeout=60) as source, temporary.open('wb') as output:
                shutil.copyfileobj(source, output)
            checked(temporary, spec['sha256'])
            temporary.replace(path)
            return path
        except (OSError, RuntimeError):
            if attempt == 2:
                raise
            time.sleep(2)


def run(*args):
    subprocess.run([str(arg) for arg in args], check=True, cwd=ROOT)


def sevenzip():
    for command in ['7zz', '7z']:
        if executable := shutil.which(command):
            return executable
    raise RuntimeError('7-Zip not found; install sevenzip (macOS) or p7zip-full (Linux)')


def decode_media_password(encoded):
    """InstallAware: XOR position, then decode hex with reversed nibbles.

    Recovered from Setup.exe's decoder (December 2007 media: VA 0x58DC18).
    The password is packaged with the installer, independently of user licensing.
    """
    pairs = bytes(value ^ index for index, value in enumerate(encoded)).decode('ascii')
    if len(pairs) % 2:
        raise ValueError('Invalid installer media password')
    return bytes(int(pairs[i:i+2][::-1], 16) for i in range(0, len(pairs), 2)).decode('ascii')


def extract_media(setup, media, component, directory):
    import pefile
    unpacked = directory / 'installer'
    run(sevenzip(), 'x', '-y', '-bso0', '-bsp0', '-o' + str(unpacked), setup, 'Setup.exe')
    executable = (unpacked / 'Setup.exe').read_bytes()
    overlay = pefile.PE(data=executable).get_overlay_data_start_offset()
    lines = executable[overlay:].split(b'\r\n')
    for index, line in enumerate(lines[:-1]):
        if line == component.encode('ascii'):
            try:
                password = decode_media_password(lines[index + 1])
            except (ValueError, UnicodeError):
                continue
            run(sevenzip(), 'x', '-y', '-bso0', '-bsp0', '-p' + password,
                '-o' + str(directory / 'media'), media)
            return directory / 'media'
    raise RuntimeError(f'No media key found for {component}')


def compiler(directory):
    destination = LOCAL / 'toolchains/original'
    destination.mkdir(parents=True, exist_ok=True)
    if directory:
        for name, expected in INPUTS['compiler']['files'].items():
            candidates = [p for p in directory.rglob('*') if p.is_file() and p.name.lower() == name.lower()]
            matched = next((p for p in candidates if sha256(p) == expected), None)
            if not matched:
                raise RuntimeError(f'{name} from Delphi {INPUTS["compiler"]["version"]} not found in supplied directory')
            target = destination / name
            if matched.resolve() != target.resolve():
                shutil.copyfile(matched, target)
    elif 'media' in INPUTS['compiler']:
        setup = download(INPUTS['compiler']['setup'], 'delphi-setup.exe')
        for spec in INPUTS['compiler']['media']:
            media = download(spec, spec['component'] + '.7zip')
            extracted = extract_media(setup, media, spec['component'], LOCAL / 'extract/compiler')
            for name, expected in INPUTS['compiler']['files'].items():
                for p in extracted.rglob('*'):
                    if p.is_file() and p.name.lower() == name.lower() and sha256(p) == expected:
                        shutil.copyfile(p, destination / name)
    for name, expected in INPUTS['compiler']['files'].items():
        if not (destination / name).exists():
            raise RuntimeError('Compiler files were not found in the extracted media. See toolchain/inputs.json for required versions and hashes.')
        checked(destination / name, expected)
    return destination


def libraries():
    import pefile
    package = download(INPUTS['libraries'], 'delphi-update4.exe')
    data = bytearray(package.read_bytes())
    pe = pefile.PE(data=data)
    found = False
    for kind in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        if kind.id != 10:
            continue
        for entry in kind.directory.entries:
            if str(entry.name) != 'PACKAGEINFO':
                continue
            payload = entry.directory.entries[0].data.struct
            offset = pe.get_offset_from_rva(payload.OffsetToData)
            if data[offset:offset+12] != b'rDlPtS\xcd\xe6\xd7{\x0b*':
                raise RuntimeError('Unsupported Inno loader header')
            struct.pack_into('<I', data, entry.struct.get_file_offset(), 11111)
            struct.pack_into('<HH', data, kind.directory.struct.get_file_offset() + 12, 2, 1)
            found = True
    if not found:
        raise RuntimeError('Inno loader header missing')
    extraction = LOCAL / 'extract/update4'
    extraction.mkdir(parents=True, exist_ok=True)
    fixed = extraction / 'package.exe'
    fixed.write_bytes(data)
    run('innoextract', '--silent', '--include', 'app/lib', '--include', 'app/bin/DCC32.EXE',
        '--output-dir', extraction, fixed)
    destination = LOCAL / 'toolchains/lib'
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(extraction / 'app/lib', destination)
    return extraction / 'app/bin/DCC32.EXE'


def resource_compiler(original, update4):
    import pefile
    def dvclal(data):
        pe = pefile.PE(data=data)
        for kind in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if kind.id == 10:
                for entry in kind.directory.entries:
                    if str(entry.name) == 'DVCLAL':
                        resource = entry.directory.entries[0].data.struct
                        if resource.Size != 16:
                            raise RuntimeError('Unexpected DVCLAL length')
                        return pe.get_offset_from_rva(resource.OffsetToData)
        raise RuntimeError('DVCLAL missing')
    data = bytearray((original / 'DCC32.EXE').read_bytes())
    resource = update4.read_bytes()
    at, source = dvclal(data), dvclal(resource)
    data[at:at+16] = resource[source:source+16]
    output = original / 'DCC32-resource.EXE'
    output.write_bytes(data)
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler-dir', type=Path, help='Use checksum-verified original compiler files from an existing directory')
    args = parser.parse_args()
    LOCAL.mkdir(exist_ok=True)
    python = LOCAL / 'python/bin/python3'
    if Path(sys.prefix).resolve() != python.parent.parent.resolve():
        if not python.exists():
            run(sys.executable, '-m', 'venv', python.parent.parent)
        wheel = download(INPUTS['pefile'], INPUTS['pefile']['filename'])
        run(python, '-m', 'pip', 'install', '--disable-pip-version-check', '--no-index', '--no-deps', wheel)
        os.execv(str(python), [str(python), str(Path(__file__)), *sys.argv[1:]])
    for command in ['cargo', 'clang', 'innoextract']:
        if not shutil.which(command):
            raise RuntimeError(f'{command} missing; see docs/development.md#setup')
    if sys.platform == 'darwin' and not os.environ.get('WINE'):
        wine = download(INPUTS['wine_macos'], 'wine-macos.tar.xz')
        destination = LOCAL / 'wine'
        destination.mkdir(exist_ok=True)
        with tarfile.open(wine) as archive:
            archive.extractall(destination, filter='data')
    original = compiler(args.compiler_dir.resolve() if args.compiler_dir else None)
    update4 = libraries()
    source = resource_compiler(original, update4)
    run(python, ROOT / 'toolchain/delphi/prepare_ordered_compiler.py', source,
        LOCAL / 'toolchains/bin/DCC32.EXE')
    run('cargo', 'build', '--locked', '--release', '--bin', 'decomp')
    print('Toolchain ready. Run ./decomp verify', flush=True)


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        sys.exit(f'Setup failed: {error}')
