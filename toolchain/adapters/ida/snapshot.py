"""IDA-only collectors. Return plain snapshots; analysis and reports run on the host.

This module is loaded by the batch IDAPython entry point.
"""
import json
from datetime import datetime, timezone

from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]

def signatures(request):
    """Read code independently of types; parse header ABIs in a detached TIL."""
    import ida_bytes
    import ida_funcs
    import ida_ida
    import ida_typeinf as ti
    import ida_ua
    import idautils

    if not ida_ida.inf_is_32bit_exactly() or ida_ida.inf_get_procname() != "metapc":
        raise ValueError("Signature audit requires the Win32 x86 database")
    manifest = request["manifest"]
    scratch = ti.new_til("signature_audit", "Detached header signature audit")
    rows = []
    try:
        scratch.cc = ti.get_idati().cc
        ti.enable_numbered_types(scratch, True)
        header = manifest["forwards"] + "\n" + "\n".join(t["decl"] for t in manifest["types"])
        if ti.parse_decls(scratch, header, None, ti.HTI_DCL | ti.HTI_SEMICOLON):
            raise ValueError("IDA rejected the detached header types")
        for item in manifest["functions"]:
            ea = item["addr"]
            function = ida_funcs.get_func(ea)
            row = {"ea": ea, "name": item["name"], "source": item["source"]}
            rows.append(row)
            if function is None or function.start_ea != ea:
                row["unavailable"] = "No IDA function at the declared entry"
                continue
            row["prefix"] = (ida_bytes.get_bytes(ea, min(160, function.end_ea - ea)) or b"").hex()
            row["returns"] = []
            for address in idautils.FuncItems(ea):
                if ida_bytes.get_byte(address) not in (0xC2, 0xC3):
                    continue
                ins = ida_ua.insn_t()
                if ida_ua.decode_insn(ins, address) and ins.get_canon_mnem() == "retn":
                    row["returns"].append([address, int(ins.ops[0].value) if ins.ops[0].type else 0])
            if not item["decl"]:
                continue
            typ, details = ti.tinfo_t(), ti.func_type_data_t()
            if ti.parse_decl(typ, scratch, item["decl"], ti.PT_SIL) is None or not typ.get_func_details(details):
                raise ValueError(f"IDA rejected header signature {item['name']}")
            row["type"] = {
                "callee_cleans": int(details.get_cc()) in {
                    ti.CM_CC_SPECIALP, ti.CM_CC_STDCALL, ti.CM_CC_PASCAL, ti.CM_CC_FASTCALL},
                "args": [{"name": a.name, "type": a.type.dstr(), "size": a.type.get_size(),
                          "loc": "stack" if a.argloc.is_stkoff() else ti.print_argloc(a.argloc),
                          "stack": int(a.argloc.stkoff()) if a.argloc.is_stkoff() else None}
                         for a in details],
            }
            if "stackpop" in item:
                row["stackpop"] = item["stackpop"]
            if "countedstack" in item:
                row["countedstack"] = True
    finally:
        ti.free_til(scratch)
    return rows


def coverage(request):
    import ida_bytes
    import ida_funcs
    import ida_nalt
    import ida_segment
    import idautils
    import idc

    evidence = json.loads((ROOT / "reference/unit_ownership.json").read_text())
    digest = ida_nalt.retrieve_input_file_sha256().hex()
    if digest != evidence["input_sha256"]:
        raise ValueError("Unit evidence belongs to a different input executable")

    def short(ea):
        n = ida_bytes.get_byte(ea)
        return (ida_bytes.get_bytes(ea + 1, n) or b"").decode("ascii")

    for t in evidence["types"]:
        ea = int(t["typeinfo_va"], 16)
        if (ida_bytes.get_dword(ea - 4) != ea or short(ea + 1) != t["name"]
                or short(int(t["unit_string_va"], 16)) != t["unit"]):
            raise ValueError(f"RTTI evidence no longer matches at {ea:#x}")

    startup = evidence.get("startup")
    if startup:
        table, pairs = int(startup["address"], 0), int(startup["pairs"], 0)
        if (ida_bytes.get_dword(table) != startup["count"]
                or ida_bytes.get_dword(table + 4) != pairs):
            raise ValueError("Startup table no longer matches unit evidence")
        seen = set()
        for row in startup["entries"]:
            index = row["index"]
            if index in seen or not 0 <= index < startup["count"]:
                raise ValueError(f"Invalid or duplicate startup entry: {index}")
            seen.add(index)
            for offset, key in ((0, "init"), (4, "fini")):
                if ida_bytes.get_dword(pairs + 8 * index + offset) != int(row[key], 0):
                    raise ValueError(f"Startup entry {index} no longer matches")

    classes = request['classes']
    functions = []
    for ea in idautils.Functions():
        f = ida_funcs.get_func(ea)
        flags = ida_bytes.get_full_flags(ea)
        thunk = bool(f.flags & ida_funcs.FUNC_THUNK)
        target = ida_funcs.calc_thunk_func_target(f)[0] if thunk else None
        seg = ida_segment.getseg(target) if target is not None else None
        import_thunk = bool(seg and (seg.type == ida_segment.SEG_XTRN
                                    or ida_segment.get_segm_name(seg) == ".idata"))
        callers = {parent.start_ea for ref in idautils.CodeRefsTo(ea, False)
                   if (parent := ida_funcs.get_func(ref)) is not None}
        functions.append({"ea": ea, "end": f.end_ea, "size": ida_funcs.calc_func_size(f),
                              "name": idc.get_name(ea), "thunk": thunk, "import_thunk": import_thunk,
                              "library": bool(f.flags & ida_funcs.FUNC_LIB),
                              "user_name": ida_bytes.has_user_name(flags),
                              "auto_name": ida_bytes.has_auto_name(flags),
                              "user_type": bool(ida_nalt.is_userti(ea)), "callers": len(callers)})
        if request.get("chunks"):
            functions[-1]["chunks"] = list(idautils.Chunks(ea))
        if request.get("instructions"):
            functions[-1]["instructions"] = [
                [address - ea, ida_bytes.get_item_size(address)]
                for address in idautils.Heads(ea, f.end_ea)
                if ida_bytes.is_code(ida_bytes.get_full_flags(address))]
            # Include returns in out-of-line chunks when checking the ABI.
            functions[-1]["returns"] = sorted({
                idc.get_operand_value(address, 0) if idc.get_operand_type(address, 0) else 0
                for address in idautils.FuncItems(ea)
                if idc.print_insn_mnem(address).lower() in {"ret", "retn"}})
    sections = []
    for start in idautils.Segments():
        s = ida_segment.getseg(start)
        if s.type == ida_segment.SEG_CODE:
            sections.append({"name": ida_segment.get_segm_name(s), "low": start, "high": s.end_ea})
    result = {"sha256": digest, "functions": functions, "classes": classes, "sections": sections}
    if request.get("instructions"):
        result["names"] = {name: address for address, name in idautils.Names()}
    return result


def native_size(request):
    import ida_bytes
    import ida_nalt
    import ida_segment
    import idautils

    snapshot = coverage(request)
    for f in snapshot["functions"]:
        f["chunks"] = list(idautils.Chunks(f["ea"]))
    snapshot["input_path"] = ida_nalt.get_input_file_path()
    snapshot["import_modules"] = sorted({ida_nalt.get_import_module_name(i)
        for i in range(ida_nalt.get_import_module_qty())})
    for section in snapshot['sections']:
        section['instructions'] = [[ea, ida_bytes.get_item_size(ea)]
            for ea in idautils.Heads(section['low'], section['high'])
            if ida_bytes.is_code(ida_bytes.get_full_flags(ea))]
    snapshot['measured_utc'] = datetime.now(timezone.utc).isoformat(timespec='seconds')
    return snapshot
