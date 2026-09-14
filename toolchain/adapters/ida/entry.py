"""Run directly with IDA -A -S, or import run() in the IDAPython console."""
import importlib
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


def reload_modules(*names):
    for name in names:
        importlib.reload(importlib.import_module(name))


def run(request):
    if sys.version_info < (3, 9):
        raise RuntimeError("The IDA worker requires Python 3.9 or newer")
    operation = request["operation"]
    if operation == 'vmt_facts':
        import ida_bytes, ida_nalt, ida_segment, idautils
        return {'input': ida_nalt.get_input_file_path(), 'names': dict(idautils.Names()),
                'code': [ea for start in idautils.Segments()
                         for ea in idautils.Heads(start, ida_segment.getseg(start).end_ea)
                         if ida_bytes.is_code(ida_bytes.get_full_flags(ea))]}
    if operation != "sync":
        reload_modules("toolchain.adapters.ida.snapshot")
        from toolchain.adapters.ida import snapshot as ida_snapshot
        collectors = {"coverage": ida_snapshot.coverage,
                      "native_size": ida_snapshot.native_size,
                      "signatures": ida_snapshot.signatures}
        if operation not in collectors:
            raise ValueError(f"Unknown IDA operation: {operation}")
        return collectors[operation](request)
    for name in ("merge", "counted_stack", "ida_backend"):
        importlib.reload(importlib.import_module("toolchain.adapters.ida." + name))
    from toolchain.adapters.ida.ida_backend import synchronize
    return synchronize(request["manifest"], apply=request.get("apply", False),
                       take_headers=request.get("take_headers", []))


if __name__ == "__main__":
    import json
    import os
    import traceback
    import ida_auto
    import ida_loader
    import ida_pro
    import idc

    request_file = os.environ.get("SRHD_IDA_REQUEST")
    if not request_file:
        raise RuntimeError("Set SRHD_IDA_REQUEST to a request JSON file, or import run() in the console")
    request = json.loads(Path(request_file).read_text())
    try:
        ida_auto.auto_wait()
        result = run(request)
        if request.get("operation") == "sync" and result.get("applied"):
            if not ida_loader.save_database(idc.get_idb_path(), 0):
                raise RuntimeError("IDA could not save the database")
            result["saved"] = True
        response = {"ok": True, "result": result}
        status = 0
    except Exception:
        response = {"ok": False, "error": traceback.format_exc()}
        status = 1
    Path(request["response"]).write_text(json.dumps(response))
    ida_pro.qexit(status)
