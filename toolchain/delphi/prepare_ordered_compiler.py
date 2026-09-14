"""Prepare DCC32 with recovered layout, private metadata names and build date.

Usage: python3 prepare_ordered_compiler.py input.exe output.exe
This modifies linker behavior; it is not the stock compiler. See docs/development.md#inputs-and-reproduction.
"""

from pathlib import Path
import json
import shutil
import struct
import subprocess
import sys
import os

import pefile

# Original PE UTC timestamp and its local DOS representation in resource headers.
PE_TIMESTAMP = 1760349254
DOS_TIMESTAMP = 0x5B4D66C7


def align(value, alignment):
    return (value + alignment - 1) & -alignment


def prepare(source, output):
    assert source.resolve() != output.resolve()
    data = bytearray(source.read_bytes())
    pe = pefile.PE(data=data)
    site = pe.get_offset_from_rva(0x32d2b)
    assert data[site:site + 5] == bytes.fromhex("e8 ac f5 ff ff"), "Unsupported compiler"
    assert pe.OPTIONAL_HEADER.ImageBase == 0x400000
    assert all(s.Name.rstrip(b"\0") != b".lnkord" for s in pe.sections)
    rva = align(pe.sections[-1].VirtualAddress + pe.sections[-1].Misc_VirtualSize,
                pe.OPTIONAL_HEADER.SectionAlignment)
    raw = align(len(data), pe.OPTIONAL_HEADER.FileAlignment)
    here = Path(__file__).resolve().parent
    names = [line.split()[1] for line in (here / "native-unit-order.tsv").read_text().splitlines()
             if line and not line.startswith("#")]
    references = [int(line.split()[0], 16)
                  for line in (here / "native-reference-order.tsv").read_text().splitlines()
                  if line and not line.startswith("#")]
    assert len(set(references)) == len(references)
    assembly = (here / "unit_order.s").read_text().replace("HOOK_RVA", str(rva))
    assembly += "".join(" .asciz " + json.dumps(name) + "\n" for name in names) + " .byte 0\n"
    assembly += (here / "reference_order.s").read_text().replace("HOOK_RVA", str(rva)).replace(
        "REF_COUNT", str(len(references))).replace("REF_BYTES", str(4 * len(references)))
    assembly += "".join(f" .long 0x{target:08x}\n" for target in references) + " .long 0\n"
    metadata = [line.split() for line in (here / "native-metadata-order.tsv").read_text().splitlines()
                if line and not line.startswith("#")]
    initializers = [None] * len(metadata)
    for i, (index, name) in enumerate(metadata):
        if index != "-":
            initializers[int(index)] = i
    assembly += (here / "metadata_order.s").read_text().replace("HOOK_RVA", str(rva)).replace(
        "META_COUNT", str(len(metadata)))
    assembly += "\npackage_keys:\n" + "".join(
        f" .long {rva}+meta_u{i}-start\n" for i in range(len(metadata)))
    assembly += "init_keys:\n" + "".join(
        " .long 0\n" if i is None else f" .long {rva}+meta_u{i}-start\n" for i in initializers)
    assembly += "".join(f"meta_u{i}: .asciz " + json.dumps(name) + "\n"
                        for i, (index, name) in enumerate(metadata))
    type_names = [line.split() for line in (here / "native-type-names.tsv").read_text().splitlines()
                  if line and not line.startswith("#")]
    assembly += (here / "build_metadata.s").read_text().replace("HOOK_RVA", str(rva)).replace(
        "DOS_TIMESTAMP", str(DOS_TIMESTAMP))
    assembly += "type_keys:\n" + "".join(
        " .long " + ",".join(f"{rva}+tn_{i}_{j}-start" for j in range(3)) + "\n"
        for i in range(len(type_names))) + " .long 0\n"
    assembly += "".join(f"tn_{i}_{j}: .asciz " + json.dumps(name) + "\n"
                        for i, row in enumerate(type_names) for j, name in enumerate(row))
    output.parent.mkdir(parents=True, exist_ok=True)
    asm = output.parent / "unit_order.s"
    obj = output.parent / "unit_order.obj"
    asm.write_text(assembly)
    clang = os.environ.get("CLANG") or shutil.which("clang")
    if not clang:
        raise RuntimeError("clang not found; install Clang or set CLANG")
    subprocess.run([str(clang), "-target", "i686-pc-windows-msvc", "-c", str(asm),
                    "-o", str(obj)], check=True)
    # Extract the COFF .text payload, not the object header.
    coff = obj.read_bytes()
    header = 20 + struct.unpack_from("<H", coff, 16)[0]
    assert coff[header:header + 8].rstrip(b"\0") == b".text"
    assert struct.unpack_from("<H", coff, header + 32)[0] == 0, "Unresolved hook relocation"
    length, pointer = struct.unpack_from("<II", coff, header + 16)
    code = coff[pointer:pointer + length]
    symbol_table, symbol_count = struct.unpack_from("<II", coff, 8)
    hooks = {}
    for i in range(symbol_count):
        entry = symbol_table + 18 * i
        name = coff[entry:entry + 8].rstrip(b"\0")
        if name in (b"ref_sort", b"ref_put", b"meta_ini", b"meta_pkg", b"type_nm", b"rs_time"):
            hooks[name] = struct.unpack_from("<I", coff, entry + 8)[0]
    size = align(len(code), pe.OPTIONAL_HEADER.FileAlignment)
    section = pe.sections[-1].get_file_offset() + 40
    assert section + 40 <= pe.sections[0].PointerToRawData
    data[section:section + 40] = struct.pack("<8sIIIIIIHHI", b".lnkord\0", len(code),
                                           rva, size, raw, 0, 0, 0, 0, 0x60000020)
    struct.pack_into("<H", data, pe.FILE_HEADER.get_field_absolute_offset("NumberOfSections"),
                     pe.FILE_HEADER.NumberOfSections + 1)
    for field, value in [("SizeOfImage", align(rva + len(code), pe.OPTIONAL_HEADER.SectionAlignment)),
                         ("SizeOfCode", pe.OPTIONAL_HEADER.SizeOfCode + size)]:
        struct.pack_into("<I", data, pe.OPTIONAL_HEADER.get_field_absolute_offset(field), value)
    data[site:site + 5] = b"\xe8" + struct.pack("<i", rva - (0x32d2b + 5))
    # Keep bucket lookup intact. Only cell offsets and the offset-aware write change.
    for site_rva, expected, hook in [(0x316bc, "e8 d7 f7 ff ff", b"ref_sort"),
                                     (0x30f01, "89 16 8b d7 83 c6 04", b"ref_put"),
                                     (0x148bd, "e8 82 fb ff ff", b"meta_ini"),
                                     (0x149c1, "e8 46 f9 ff ff", b"meta_pkg"),
                                     (0x8c585, "e8 da ef ff ff", b"type_nm")]:
        expected = bytes.fromhex(expected)
        offset = pe.get_offset_from_rva(site_rva)
        assert data[offset:offset + len(expected)] == expected, "Unsupported compiler"
        data[offset:offset + len(expected)] = (
            b"\xe8" + struct.pack("<i", rva + hooks[hook] - site_rva - 5)
            + b"\x90" * (len(expected) - 5))
    timestamp = pe.get_offset_from_rva(0x33906)
    assert data[timestamp:timestamp + 5] == bytes.fromhex("e8 cd f0 06 00")
    data[timestamp:timestamp + 5] = b"\xb8" + struct.pack("<I", PE_TIMESTAMP)
    callback = pe.get_offset_from_rva(0x36cca)
    assert struct.unpack_from("<I", data, callback)[0] == 0x436b60
    # This callback pointer already has a HIGHLOW relocation in the input PE.
    assert any(e.type == 3 and e.rva == 0x36cca
               for block in pe.DIRECTORY_ENTRY_BASERELOC for e in block.entries)
    struct.pack_into("<I", data, callback, 0x400000 + rva + hooks[b"rs_time"])
    data.extend(bytes(raw - len(data)))
    data.extend(code)
    data.extend(bytes(size - len(code)))
    output.write_bytes(data)
    shutil.copy2(source.parent / "rlink32.dll", output.parent / "rlink32.dll")
    print(f"Prepared {output}: {len(names)} unit contributions, {len(references)} reference cells, "
          f"{len(metadata)} metadata entries, {len(type_names)} private type names, fixed build date")


if __name__ == "__main__":
    prepare(*map(Path, sys.argv[1:]))
