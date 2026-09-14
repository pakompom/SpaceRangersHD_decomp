"""Runs inside IDAPython 9.3, through a batch script or the IDA Python console."""
from __future__ import annotations

import json

from .merge import decision

# Persisted IDB storage identity is independent of the Python package path.
NODE = "$ rangers.ida_sync.v1"
BEGIN, END = "[delphi-header]", "[/delphi-header]"


def can_split_inferred_array(addr, imported):
    """Allow a declared boundary inside an unannotated primitive array guess.

    For example, IDA can group a set's last bytes, alignment and the next
    string's length into a dword array. Its bytes remain unchanged when the
    declaration replaces that guess. Scalars, strings, typed/named data,
    references and prior imports still require complete coverage.
    """
    import ida_bytes
    import ida_nalt
    import ida_typeinf
    import idautils

    head = ida_bytes.get_item_head(addr)
    flags = ida_bytes.get_full_flags(head)
    size = ida_bytes.get_item_size(head)
    if (head == addr or not ida_bytes.is_data(flags) or ida_bytes.is_strlit(flags)
            or ida_bytes.has_user_name(flags) or ida_nalt.is_userti(head)):
        return False
    element_size = ida_bytes.get_data_elsize(head, flags)
    if not element_size or size <= element_size:
        return False
    if ida_nalt.get_tinfo(ida_typeinf.tinfo_t(), head):
        return False
    return not any(
        ida_bytes.has_user_name(ida_bytes.get_full_flags(ea))
        or ida_nalt.is_userti(ea)
        or any(ida_bytes.get_cmt(ea, repeat) for repeat in (False, True))
        or any(idautils.XrefsTo(ea, 0))
        or f'prototype:{ea:X}' in imported or f'name:{ea:X}' in imported
        for ea in range(head, head + size))


def normalize_enum_display(snapshot, ordinal_enum):
    """IDA may promote power-of-two ordinal enums to bitmask display after import.

    Preserve that display choice in the IDB, but do not treat it as a source
    change. Declared sets retain their bitmask semantics in the comparison.
    """
    if snapshot is None or not ordinal_enum:
        return snapshot
    declaration = snapshot["declaration"]
    if declaration.startswith("enum __bitmask "):
        return {**snapshot, "declaration": declaration.replace("enum __bitmask ", "enum ", 1)}
    return snapshot


def stack_snapshot(delta, user=True):
    return {"delta": delta, "user": user}


def comment_block(text):
    start = text.find(BEGIN)
    if start < 0:
        return None
    end = text.find(END, start + len(BEGIN))
    return (start, end + len(END)) if end >= 0 else None


def replace_comment(text, new):
    span = comment_block(text)
    if span is None:
        return (text + "\n" + new).lstrip("\n")
    start, end = span
    return text[:start] + new + text[end:]


def prepare_stack_analysis(actions):
    """Invalidate and queue stack analysis before changing call-cleanup inputs.

    FUNC_SP_READY freezes inferred points, including Delphi exception and
    finally continuations. Merely queueing AU_USED does not invalidate it.
    Leave all points in place: the processor owns inferred points and must
    preserve explicit user/call-site deltas while solving the function again.
    """
    import ida_funcs
    import idautils

    targets = set()
    for action in actions:
        kind, item = action["kind"], action["item"]
        if action["status"] == "unchanged":
            continue
        if kind in {"calltype", "callstack"}:
            if "caller" in item:
                targets.add(item["caller"])
        elif kind == "prototype":
            function = ida_funcs.get_func(item["addr"])
            if function is not None:
                targets.add(function.start_ea)
                for ea in idautils.CodeRefsTo(item["addr"], False):
                    caller = ida_funcs.get_func(ea)
                    if caller is not None:
                        targets.add(caller.start_ea)
    for ea in sorted(targets):
        function = ida_funcs.get_func(ea)
        if function is None:
            raise ValueError(f"function disappeared before stack analysis: 0x{ea:X}")
        function.flags &= ~ida_funcs.FUNC_SP_READY
        if not ida_funcs.update_func(function):
            raise ValueError(f"could not invalidate stack analysis for 0x{ea:X}")
        ida_funcs.reanalyze_function(function)
    return len(targets)


def is_literal_offset_xref(xref):
    """Ignore an automatic pointer guess over a referenced Delphi wide literal.

    UTF-16 'float' starts with the apparent address 0x006C0066. Require a
    bounded byte length, terminator, printable text, and a native instruction
    referencing the literal itself. Never ignore code or user references.
    """
    import ida_bytes
    import ida_xref
    import idautils

    if (getattr(xref, "user", False) or xref.type != ida_xref.dr_O
            or ida_bytes.is_code(ida_bytes.get_full_flags(xref.frm))):
        return False
    length = ida_bytes.get_dword(xref.frm - 4)
    if not 4 <= length <= 512 or length % 2:
        return False
    data = ida_bytes.get_bytes(xref.frm, length + 2)
    if data is None or len(data) != length + 2 or data[-2:] != b"\0\0":
        return False
    try:
        if not data[:-2].decode("utf-16le").isprintable():
            return False
    except UnicodeDecodeError:
        return False
    return any(x.type == ida_xref.dr_O and ida_bytes.is_code(ida_bytes.get_full_flags(x.frm))
               for x in idautils.XrefsTo(xref.frm, 0))


def function_entry_adjustment(addr, declared_addresses):
    """Recognize a Delphi entry preceded only by misclassified alignment NOPs.

    Never trim executable work, a referenced entry, another declaration, or
    user annotations. This analysis repair is not undone on header removal.
    """
    import ida_bytes
    import ida_funcs
    import ida_nalt
    import idautils

    function = ida_funcs.get_func(addr)
    if function is not None and function.start_ea == addr:
        return None
    error = ValueError(f"0x{addr:X} must be an IDA function entry before sync")
    if function is None:
        raise error
    start = function.start_ea
    if (not 0 < addr - start < 16 or addr % 4 or start in declared_addresses
            or ida_bytes.get_item_head(addr) != addr
            or ida_bytes.get_bytes(addr, 3) != b"\x55\x8b\xec"
            or any(ida_funcs.get_func_cmt(function, repeat) for repeat in (False, True))):
        raise error
    cursor = start
    while cursor < addr:
        if ida_bytes.get_bytes(cursor, 1) == b"\x90":
            size = 1
        elif ida_bytes.get_bytes(cursor, 2) == b"\x8b\xc0":
            size = 2
        else:
            raise error
        if cursor + size > addr or ida_bytes.get_item_size(cursor) != size:
            raise error
        cursor += size
    import ida_xref
    for ea in range(start, addr):
        if (ida_bytes.has_user_name(ida_bytes.get_full_flags(ea)) or ida_nalt.is_userti(ea)
                or any(ida_bytes.get_cmt(ea, repeat) for repeat in (False, True))
                or any(x.type != ida_xref.fl_F and not is_literal_offset_xref(x)
                       for x in idautils.XrefsTo(ea, 0))):
            raise error
    return start


def can_create_function_entry(addr):
    """Accept an unowned, decoded Delphi frame entry with a native call xref.

    Headers supply the entry; IDA still discovers its extent. Do not reinterpret
    data or take bytes from another function/chunk merely because a header exists.
    """
    import ida_bytes
    import ida_funcs
    import ida_xref
    import idautils

    return bool(
        ida_funcs.get_fchunk(addr) is None
        and ida_bytes.get_item_head(addr) == addr
        and ida_bytes.is_code(ida_bytes.get_full_flags(addr))
        and ida_bytes.get_bytes(addr, 3) == b"\x55\x8b\xec"
        and any(x.type in (ida_xref.fl_CN, ida_xref.fl_CF)
                and ida_bytes.is_code(ida_bytes.get_full_flags(x.frm))
                for x in idautils.XrefsTo(addr, 0)))


def declared_code_instructions(item, declared_addresses):
    """Validate an explicit, contiguous missing body before rebuilding code.

    @codeend is reviewed source evidence, not an inferred nearest-unit boundary.
    It permits automatic data guesses inside that body, but no existing chunks,
    manual data annotations, other declarations, or incomplete instructions.
    """
    import ida_bytes
    import ida_funcs
    import ida_nalt
    import ida_segment
    import ida_ua

    start, end = item['addr'], item['codeend']
    segment = ida_segment.getseg(start)
    if not start < end <= segment.end_ea or any(start < ea < end for ea in declared_addresses):
        raise ValueError(f"invalid declared code interval at 0x{start:X}")
    for ea in range(start, end):
        if ida_funcs.get_fchunk(ea) is not None:
            raise ValueError(f"declared code overlaps an existing chunk at 0x{ea:X}")
        if not ida_bytes.is_code(ida_bytes.get_full_flags(ea)):
            head = ida_bytes.get_item_head(ea)
            if (head < start or head + ida_bytes.get_item_size(head) > end
                    or ida_bytes.has_user_name(ida_bytes.get_full_flags(head))
                    or ida_nalt.is_userti(head)
                    or any(ida_bytes.get_cmt(head, repeat) for repeat in (False, True))):
                raise ValueError(f"declared code overlaps annotated data at 0x{ea:X}")
    cursor, instructions = start, []
    while cursor < end:
        insn = ida_ua.insn_t()
        size = ida_ua.decode_insn(insn, cursor)
        if not size or cursor + size > end:
            raise ValueError(f"invalid instruction in declared code at 0x{cursor:X}")
        instructions.append((cursor, size))
        cursor += size
    if insn.get_canon_mnem() != 'retn':
        raise ValueError(f"declared code must end after RET at 0x{end:X}")
    return instructions


def named_tail_entry(addr):
    """Name-only declarations may identify an existing shared code-tail entry.

    Keep IDA's chunk ownership intact; attach the source note to the instruction,
    never to one arbitrarily selected parent function.
    """
    import ida_bytes
    import ida_funcs

    get_chunk = getattr(ida_funcs, "get_fchunk", None)
    chunk = get_chunk(addr) if get_chunk is not None else None
    return bool(chunk is not None and chunk.start_ea == addr
                and chunk.flags & ida_funcs.FUNC_TAIL
                and ida_bytes.get_item_head(addr) == addr
                and ida_bytes.is_code(ida_bytes.get_full_flags(addr)))


def synchronize(manifest, apply=False, take_headers=()):
    import ida_auto
    import ida_bytes
    import ida_funcs
    import ida_ida
    import ida_nalt
    import ida_name
    import ida_netnode
    import ida_segment
    import ida_typeinf as ti

    if not ida_ida.inf_is_32bit_exactly() or ida_nalt.get_imagebase() != manifest["image_base"]:
        raise ValueError("sync requires the x86 database at the headers' preferred image base")
    if not ida_auto.auto_wait():
        raise ValueError("IDA analysis was cancelled")
    take_headers = set(take_headers)
    # Read without creating a node: diff does not add project state to the IDB.
    node = ida_netnode.netnode(NODE, 0, False)
    blob = node.getblob(0, "S")
    state = json.loads(blob) if blob else {"version": 1, "entries": {}}
    if state.get("version") != 1:
        raise ValueError("unsupported sync state version")
    old = state["entries"]
    scratch = ti.new_til("rangers_headers", "Delphi header validation")
    if scratch is None:
        raise ValueError("could not allocate temporary type library")

    def type_text(tif, name):
        flags = ti.PRTYPE_MULTI | ti.PRTYPE_TYPE | ti.PRTYPE_DEF
        declaration = ti.print_tinfo("", 0, 0, flags, tif, name, "")
        # Scratch TILs can print callback records as aliases to generated hash
        # names. Expand only that spelling, retaining the complete UDT data.
        import re
        if re.fullmatch(r"typedef struct \$[0-9A-Fa-f]{32} " + re.escape(name) + r"\s*", declaration):
            udt = ti.udt_type_data_t()
            definition = ti.tinfo_t()
            if not tif.get_udt_details(udt) or not definition.create_udt(udt, tif.get_realtype()):
                raise ValueError(f"could not expand structure {name}")
            declaration = ti.print_tinfo("", 0, 0, flags, definition, name, "")
        result = {"declaration": declaration, "size": tif.get_size()}
        udt = ti.udt_type_data_t()
        if tif.get_udt_details(udt):
            # Printed C alone can hide changed physical offsets or member notes.
            result["fields"] = [{"name": m.name, "bit_offset": m.offset, "bit_size": m.size,
                                 "type": str(m.type), "comment": m.cmt} for m in udt]
        return result

    def named_text(name):
        t = ti.tinfo_t()
        return type_text(t, name) if t.get_named_type(None, name) else None

    def prototype_text(item):
        addr = item["addr"]
        t = ti.tinfo_t()
        declaration = str(t) if ida_nalt.get_tinfo(t, addr) else None
        if "size" in item:
            return {"declaration": declaration, "size": ida_bytes.get_item_size(addr)}
        return declaration

    def call_type_text(addr):
        t = ti.tinfo_t()
        return str(t) if ida_nalt.get_op_tinfo(t, addr, 0) else None

    def comment_text(item, function):
        if function:
            native = ida_funcs.get_func(item["addr"])
            return (ida_funcs.get_func_cmt(native, True) or "") if native is not None else ""
        return ida_bytes.get_cmt(item["addr"], True) or ""

    def own_comment(item, function):
        text = comment_text(item, function)
        span = comment_block(text)
        return text[span[0]:span[1]] if span else None

    actions = []
    desired_names = {item["addr"]: item["name"] for group in ("functions", "globals") for item in manifest[group]}
    release_names = set()
    def add(key, desired, current, kind, item, replaceable=False):
        previous = old.get(key)
        if kind == "type" and item["kind"] == "enum":
            desired = normalize_enum_display(desired, True)
            current = normalize_enum_display(current, True)
            if previous is not None:
                previous = {"actual": normalize_enum_display(previous["actual"], True)}
        # A source call-site annotation pins even a matching automatic estimate.
        if kind == "callstack" and current is not None and not current["user"]:
            previous, replaceable = None, True
        status = decision(current, desired, previous, replaceable)
        resolved = status == "conflict" and key in take_headers
        if resolved:
            status = "remove" if desired is None else "update"
        actions.append({"key": key, "status": status, "desired": desired,
                        "current": current, "kind": kind, "item": item, "resolved": resolved,
                        "baseline": previous["actual"] if previous is not None else None})

    def removed_item(key):
        kind, identity = key.split(":", 1)
        if kind == "type":
            # Without its source declaration, do not reinterpret enum/set flags.
            item = {"name": identity, "kind": "removed"}
            return kind, item, named_text(identity)
        addr = int(identity, 16)
        function = ida_funcs.get_func(addr)
        item = {"addr": addr, "function": function is not None and function.start_ea == addr}
        if kind == "name":
            current = ida_name.get_name(addr) if ida_bytes.has_user_name(ida_bytes.get_full_flags(addr)) else None
        elif kind == "prototype":
            baseline = old[key]["actual"]
            if isinstance(baseline, dict):
                item["size"] = baseline["size"]
            current = prototype_text(item) if ida_nalt.is_userti(addr) else None
        elif kind == "comment":
            current = own_comment(item, item["function"])
        elif kind in {"calltype", "callstack"}:
            import ida_frame
            if function is not None:
                item["caller"] = function.start_ea
            item["stack_ea"] = addr + ida_bytes.get_item_size(addr)
            current = call_type_text(addr) if kind == "calltype" else (
                stack_snapshot(ida_frame.get_sp_delta(function, item["stack_ea"]))
                if function is not None and ida_nalt.is_usersp(item["stack_ea"]) else None)
        else:
            raise ValueError(f"unknown managed annotation: {key}")
        return kind, item, current

    def remove(action):
        item, kind = action["item"], action["kind"]
        addr = item.get("addr")
        if kind == "type":
            if not ti.del_named_type(None, item["name"], ti.NTF_TYPE):
                raise ValueError(f"could not remove type {item['name']}")
        elif kind == "name":
            if not ida_name.set_name(addr, "", ida_name.SN_CHECK | ida_name.SN_NOWARN):
                raise ValueError(f"could not clear name at 0x{addr:X}")
        elif kind == "prototype":
            ida_nalt.del_tinfo(addr)
        elif kind == "calltype":
            ida_nalt.del_op_tinfo(addr, 0)
        elif kind == "callstack":
            import ida_frame
            if not ida_frame.del_stkpnt(ida_funcs.get_func(addr), item["stack_ea"]):
                raise ValueError(f"could not remove call stack cleanup at 0x{addr:X}")
        else:
            full = comment_text(item, item["function"])
            new = replace_comment(full, "")
            ok = ida_funcs.set_func_cmt(ida_funcs.get_func(addr), new, True) if item["function"] else ida_bytes.set_cmt(addr, new, True)
            if not ok:
                raise ValueError(f"could not clear comment at 0x{addr:X}")

    try:
        scratch.cc = ti.get_idati().cc
        ti.enable_numbered_types(scratch, True)
        header = manifest["forwards"] + "\n" + "\n".join(t["decl"] for t in manifest["types"])
        if ti.parse_decls(scratch, header, None, ti.HTI_DCL | ti.HTI_SEMICOLON):
            raise ValueError("IDA rejected the generated type declarations")
        for item in manifest["types"]:
            t = ti.tinfo_t()
            if not t.get_named_type(scratch, item["name"]):
                raise ValueError(f"IDA did not create type {item['name']}")
            if item["size"] is not None and t.get_size() != item["size"]:
                raise ValueError(f"IDA size mismatch for {item['name']}: {t.get_size()} != {item['size']}")
            if "fields" in item and item["size"] is not None:
                udt = ti.udt_type_data_t()
                if not t.get_udt_details(udt):
                    raise ValueError(f"not a structure: {item['name']}")
                offsets = {m.name: m.offset for m in udt}
                for field in item["fields"]:
                    if offsets.get(field["name"]) != field["offset"] * 8:
                        raise ValueError(f"IDA offset mismatch: {item['name']}.{field['name']}")
            desired, current = type_text(t, item['name']), named_text(item['name'])
            # Forward targets can print as either `T` or `struct T` in
            # different TILs. Compare named pointer targets and IDA's full
            # type identity, including qualifiers, before treating that
            # spelling difference as a declaration edit.
            live = ti.tinfo_t()
            if (current is not None and t.is_ptr() and live.get_named_type(None, item['name'])
                    and live.is_ptr() and t.equals_to(live)
                    and t.get_pointed_object().get_type_name()
                    and t.get_pointed_object().get_type_name() == live.get_pointed_object().get_type_name()):
                desired['declaration'] = current['declaration']
            add("type:"+item["name"], desired, current, "type", item)

        call_annotations = set()

        # A corrected aggregate can release bytes for other declarations in
        # this same sync. Validate against that planned layout, while retaining
        # the usual protection for aggregates changed independently in IDA.
        released_tails = {}
        for item in manifest['globals']:
            addr = item['addr']
            baseline = old.get(f'prototype:{addr:X}')
            if baseline is not None and baseline['actual'] == prototype_text(item):
                end = addr + ida_bytes.get_item_size(addr)
                if addr + item['size'] < end:
                    released_tails[addr] = (addr + item['size'], end)

        # IDA may infer one primitive item over several independent globals
        # (for example, a qword over adjacent Width and Height integers).
        # Split it only when this manifest covers the entire inferred item,
        # without holes or overlaps. Never reinterpret a prior import or a
        # definite manual/library type this way.
        declared_globals = {item['addr']: item for item in manifest['globals']}
        partitioned_items = {}
        for addr, item in declared_globals.items():
            if (ida_bytes.get_item_head(addr) != addr or
                    ida_bytes.get_item_size(addr) <= item['size'] or
                    f'prototype:{addr:X}' in old or ida_nalt.is_userti(addr)):
                continue
            end = addr + ida_bytes.get_item_size(addr)
            # Auto-created strings can consume the first byte of a following
            # scalar (for example, two Singles inferred as "33S@\0"). Permit
            # its declared end to extend over unowned, untyped items, but not
            # into a partial item or a manually named/typed neighbor.
            inferred_string = (ida_bytes.is_strlit(ida_bytes.get_full_flags(addr)) and
                               not ida_bytes.has_user_name(ida_bytes.get_full_flags(addr)))
            cursor = addr
            boundaries = set()
            while cursor < end and cursor in declared_globals:
                part = declared_globals[cursor]
                next_cursor = cursor + part['size']
                if part['size'] <= 0:
                    break
                if next_cursor > end:
                    if not inferred_string or ida_bytes.get_item_head(next_cursor) != next_cursor:
                        break
                    if any(ida_bytes.is_code(ida_bytes.get_full_flags(a)) or
                           ida_bytes.has_user_name(ida_bytes.get_full_flags(a)) or
                           ida_nalt.is_userti(a) or f'prototype:{a:X}' in old
                           for a in range(end, next_cursor)):
                        break
                    end = next_cursor
                boundaries.add(cursor)
                cursor = next_cursor
            if cursor == end and len(boundaries) > 1:
                partitioned_items[addr] = (end, boundaries)

        def planned_boundary(addr):
            head = ida_bytes.get_item_head(addr)
            if head == addr:
                return True
            partition = partitioned_items.get(head)
            if partition is not None and addr in partition[1]:
                return True
            released = released_tails.get(head)
            return ((released is not None and released[0] <= addr <= released[1])
                    or can_split_inferred_array(addr, old))

        def add_calls(item):
            if item.get("calls") or item.get("countedstack"):
                import ida_frame
                import ida_idp
                import ida_ua
                if item.get("countedstack"):
                    from .counted_stack import native_calls
                    call_declarations = native_calls(item)
                else:
                    call_declarations = [(ea, item["decl"]) for ea in item["calls"]]
                for call_ea, call_decl in call_declarations:
                    if call_ea in call_annotations:
                        raise ValueError(f"duplicate call-site annotation at 0x{call_ea:X}")
                    call_annotations.add(call_ea)
                    call_type = ti.tinfo_t()
                    details = ti.func_type_data_t()
                    if (ti.parse_decl(call_type, scratch, call_decl, ti.PT_SIL) is None or
                            not call_type.get_func_details(details)):
                        raise ValueError(f"call-site annotations need a function type: {item['name']}")
                    delta = int(details.stkargs) if ti.is_purging_cc(call_type.get_cc()) else 0
                    if "stackpop" in item:
                        delta = item["stackpop"]
                        if delta < 0 or delta % 4 or delta > int(details.stkargs):
                            raise ValueError(f"@stackpop exceeds the declared stack argument area or is unaligned: {item['name']}")
                    if delta < 0 or delta > 0xFFFF:
                        raise ValueError(f"unresolved call-site stack cleanup for {item['name']}")
                    insn = ida_ua.insn_t()
                    caller = ida_funcs.get_func(call_ea)
                    call_segment = ida_segment.getseg(call_ea)
                    if (caller is None or call_segment is None or
                            not call_segment.perm & ida_segment.SEGPERM_EXEC or
                            ida_bytes.get_item_head(call_ea) != call_ea or
                            not ida_bytes.is_code(ida_bytes.get_full_flags(call_ea)) or
                            not ida_ua.decode_insn(insn, call_ea) or not ida_idp.is_call_insn(insn)):
                        raise ValueError(f"0x{call_ea:X} must be a call instruction inside an IDA function")
                    next_ea = call_ea + insn.size
                    call_item = {**item, "addr": call_ea, "decl": call_decl, "caller": caller.start_ea,
                                 "stack_ea": next_ea}
                    add(f"calltype:{call_ea:X}", str(call_type), call_type_text(call_ea), "calltype", call_item)
                    add(f"callstack:{call_ea:X}", stack_snapshot(delta),
                        stack_snapshot(ida_frame.get_sp_delta(caller, next_ea), ida_nalt.is_usersp(next_ea)),
                        "callstack", call_item, not ida_nalt.is_usersp(next_ea))

        for function, items in ((True, manifest["functions"]),
                                (False, sorted(manifest["globals"], key=lambda item: item['addr']))):
            for item in items:
                item = dict(item)
                addr = item["addr"]
                segment = ida_segment.getseg(addr)
                if segment is None:
                    raise ValueError(f"unmapped address 0x{addr:X}")
                tail_label = function and not item["decl"] and named_tail_entry(addr)
                if function:
                    create_entry = (bool(item["decl"]) and ida_funcs.get_func(addr) is None
                                    and can_create_function_entry(addr))
                    if create_entry and 'codeend' in item:
                        declared_code_instructions(item, desired_names)
                    start = None if tail_label or create_entry else function_entry_adjustment(addr, desired_names)
                    if create_entry or start is not None:
                        actions.append({"key": f"entry:{addr:X}", "status": "create" if create_entry else "update",
                                        "desired": addr, "current": start, "kind": "entry",
                                        "item": item, "resolved": False, "baseline": None})
                    if not segment.perm & ida_segment.SEGPERM_EXEC:
                        raise ValueError(f"non-executable function address 0x{addr:X}")
                else:
                    size = item["size"]
                    if addr + size > segment.end_ea or any(ida_bytes.is_code(ida_bytes.get_full_flags(a)) for a in range(addr, addr+size)):
                        raise ValueError(f"global overlaps code/unmapped bytes: {item['name']}")
                    baseline = old.get(f"prototype:{addr:X}")
                    owns_layout = baseline is not None and baseline["actual"] == prototype_text(item)
                    shrinking_owned_item = owns_layout and ida_bytes.get_item_head(addr + size) == addr
                    if not planned_boundary(addr) or (not planned_boundary(addr + size) and not shrinking_owned_item):
                        raise ValueError(f"global {item['name']} cuts through an existing item")
                    item["rebuild_size"] = (max(size, ida_bytes.get_item_size(addr))
                                            if owns_layout or addr in partitioned_items else size)
                named_addr = ida_name.get_name_ea(0xFFFFFFFFFFFFFFFF, item["name"])
                if named_addr not in (addr, 0xFFFFFFFFFFFFFFFF):
                    previous_owner = old.get(f"name:{named_addr:X}")
                    managed_owner = previous_owner is not None and previous_owner["actual"] == item["name"]
                    approved_rename = (f"name:{named_addr:X}" in take_headers and
                                       named_addr in desired_names and
                                       desired_names[named_addr] != item["name"])
                    if (not (managed_owner or approved_rename) or
                            desired_names.get(named_addr) == item["name"]):
                        raise ValueError(f"name {item['name']} already belongs to 0x{named_addr:X}")
                    release_names.add(named_addr)
                current_name = ida_name.get_name(addr) or None
                add(f"name:{addr:X}", item["name"], current_name, "name", item,
                    not ida_bytes.has_user_name(ida_bytes.get_full_flags(addr)))
                if item["decl"]:
                    t = ti.tinfo_t()
                    if ti.parse_decl(t, scratch, item["decl"], ti.PT_SIL) is None or t.is_func() != function:
                        raise ValueError(f"IDA rejected declaration for {item['name']}: {item['decl']}")
                    # On first import, analysis/decompiler guesses can be replaced.
                    # Definite user/TIL types and later manual edits remain protected.
                    desired = str(t) if function else {"declaration": str(t), "size": item["size"]}
                    current = prototype_text(item)
                    add(f"prototype:{addr:X}", desired, current, "prototype", item,
                        not ida_nalt.is_userti(addr) or
                        (not function and current["declaration"] == desired["declaration"]))
                    add_calls(item)
                detail = f"{BEGIN}\n{item['source']}"
                if "note" in item:
                    detail += "\n" + item["note"]
                detail += f"\n{END}"
                # IDA returns an aggregate head's comment for its tail bytes.
                # That inherited comment disappears when the owner shrinks.
                released = not function and ida_bytes.get_item_head(addr) != addr and planned_boundary(addr)
                current_comment = None if released else own_comment(item, function and not tail_label)
                add(f"comment:{addr:X}", detail, current_comment, "comment",
                    {**item, "function": function and not tail_label})

        for item in manifest.get("virtual_calls", []):
            add_calls(item)

        present = {a["key"] for a in actions}
        # Remove referring annotations before their named types.
        for key in sorted(old.keys() - present, key=lambda k: (k.startswith("type:"), k)):
            kind, item, current = removed_item(key)
            add(key, None, current, kind, item)
        unknown = take_headers - {a["key"] for a in actions}
        if unknown:
            raise ValueError("unknown --take-header annotation: " + ", ".join(sorted(unknown)))
        entries = [{"key": a["key"], "status": a["status"],
                    **({"before": a["current"], "after": a["desired"]} if a["status"] != "unchanged" else {}),
                    **({"baseline": a["baseline"]} if a["status"] == "conflict" else {}),
                    **({"resolution": "header"} if a["resolved"] else {})}
                   for a in actions]
        report = {"applied": False, "entries": entries}
        if not apply or any(a["status"] == "conflict" for a in actions):
            return report

        # All source declarations and conflicts are checked before mutating the IDB.
        # IDA mutations are not transactional: record successful actions on failure too.
        applied = {}
        changed = [a for a in actions if a["status"] != "unchanged"]
        if not changed and all(a["desired"] is not None and a["baseline"] == a["current"] for a in actions):
            return {**report, "applied": True, "reanalyzed_functions": 0}
        try:
            for action in changed:
                if action["kind"] == "entry":
                    addr = action["item"]["addr"]
                    if action["current"] is None:
                        if not can_create_function_entry(addr):
                            raise ValueError(f"function entry changed during sync: 0x{addr:X}")
                        if 'codeend' in action['item']:
                            import ida_ua
                            instructions = declared_code_instructions(action['item'], desired_names)
                            for ea, size in instructions:
                                if not ida_bytes.is_code(ida_bytes.get_full_flags(ea)):
                                    if (not ida_bytes.del_items(ea, ida_bytes.DELIT_SIMPLE, size)
                                            or ida_ua.create_insn(ea) != size):
                                        raise ValueError(f"could not decode declared code at 0x{ea:X}")
                            created = ida_funcs.add_func(addr, action['item']['codeend'])
                        else:
                            created = ida_funcs.add_func(addr)
                        if not created:
                            raise ValueError(f"could not create declared function at 0x{addr:X}")
                        continue
                    start = function_entry_adjustment(addr, desired_names)
                    if start != action["current"]:
                        raise ValueError(f"function entry changed during sync: 0x{addr:X}")
                    if ida_funcs.set_func_start(start, addr) != ida_funcs.MOVE_FUNC_OK:
                        raise ValueError(f"could not trim alignment before 0x{addr:X}")
            # Failure here precedes all declaration writes. Queued analysis is
            # drained in finally even if a later write only partially succeeds.
            report["reanalyzed_functions"] = prepare_stack_analysis(changed)
            # Release managed names that are moving or swapping addresses.
            # Record each successful clear so a failed later write is retryable.
            for action in changed:
                if action["kind"] == "name" and action["item"]["addr"] in release_names:
                    addr = action["item"]["addr"]
                    if not ida_name.set_name(addr, "", ida_name.SN_CHECK | ida_name.SN_NOWARN):
                        raise ValueError(f"could not release managed name at 0x{addr:X}")
                    applied[action["key"]] = action
            changed_types = [a for a in actions if a["kind"] == "type" and a["status"] != "unchanged"]
            if changed_types:
                # Only absent forward declarations are installed; never redefine existing types here.
                for item in manifest["types"]:
                    if item["kind"] in {"class", "record", "interface"} and named_text(item["name"]) is None:
                        if ti.parse_decls(None, f"struct {item['name']};", None, ti.HTI_DCL | ti.HTI_SEMICOLON):
                            raise ValueError(f"could not forward-declare {item['name']}")
            for action in actions:
                item = action["item"]
                addr = item.get("addr")
                if action["status"] != "unchanged":
                    kind = action["kind"]
                    if kind == "entry":
                        continue
                    if action["desired"] is None:
                        remove(action)
                    elif kind == "type":
                        # parse_decls can succeed while retaining an existing
                        # typedef (notably an array with an old bound). Parse
                        # the replacement value and explicitly install it.
                        t = ti.tinfo_t()
                        if (ti.parse_decl(t, None, item['decl'], ti.PT_TYP | ti.PT_SIL) is None
                                or t.set_named_type(None, item['name'], ti.NTF_REPLACE) != ti.TERR_OK):
                            raise ValueError(f"could not import {item['name']}")
                    elif kind == "name":
                        if not ida_name.set_name(addr, item["name"], ida_name.SN_CHECK | ida_name.SN_NOWARN):
                            raise ValueError(f"could not rename 0x{addr:X}")
                    elif kind == "prototype":
                        t = ti.tinfo_t()
                        if ti.parse_decl(t, None, item["decl"], ti.PT_SIL) is None:
                            raise ValueError(f"could not parse type for 0x{addr:X}")
                        if "size" in item and ida_bytes.get_item_size(addr) != item["size"]:
                            if not ida_bytes.del_items(addr, ida_bytes.DELIT_DELNAMES, item["rebuild_size"]):
                                raise ValueError(f"could not rebuild global {item['name']}")
                        if not ti.apply_tinfo(addr, t, ti.TINFO_DEFINITE):
                            raise ValueError(f"could not type 0x{addr:X}")
                        if "size" in item and ida_bytes.get_item_size(addr) != item["size"]:
                            raise ValueError(f"IDA did not build the declared layout for {item['name']}")
                    elif kind == "calltype":
                        t = ti.tinfo_t()
                        if ti.parse_decl(t, None, item["decl"], ti.PT_SIL) is None or not ida_nalt.set_op_tinfo(addr, 0, t):
                            raise ValueError(f"could not type call at 0x{addr:X}")
                    elif kind == "callstack":
                        import ida_frame
                        if not ida_frame.add_user_stkpnt(item["stack_ea"], action["desired"]["delta"]):
                            raise ValueError(f"could not set call stack cleanup at 0x{addr:X}")
                    else:
                        full = comment_text(item, item["function"])
                        new = replace_comment(full, action["desired"])
                        ok = ida_funcs.set_func_cmt(ida_funcs.get_func(addr), new, True) if item["function"] else ida_bytes.set_cmt(addr, new, True)
                        if not ok:
                            raise ValueError(f"could not comment 0x{addr:X}")
                applied[action["key"]] = action
        finally:
            try:
                if changed:
                    try:
                        import ida_hexrays
                        ida_hexrays.clear_cached_cfuncs()
                    except ImportError:
                        pass
                    if not ida_auto.auto_wait():
                        raise ValueError("stack reanalysis was cancelled")
            finally:
                if applied:
                    # Store only the canonical value actually written. This is
                    # the three-way merge baseline, not a second source of truth.
                    for action in applied.values():
                        item, kind = action["item"], action["kind"]
                        if action["desired"] is None:
                            old.pop(action["key"], None)
                            continue
                        if kind == "type":
                            actual = named_text(item["name"])
                        elif kind == "prototype":
                            actual = prototype_text(item)
                        elif kind == "calltype":
                            actual = call_type_text(item["addr"])
                        elif kind == "callstack":
                            import ida_frame
                            actual = stack_snapshot(
                                ida_frame.get_sp_delta(ida_funcs.get_func(item["addr"]), item["stack_ea"]),
                                ida_nalt.is_usersp(item["stack_ea"]))
                        elif kind == "name":
                            actual = ida_name.get_name(item["addr"])
                        else:
                            actual = own_comment(item, item["function"])
                        old[action["key"]] = {"actual": actual}
                    node = ida_netnode.netnode(NODE, 0, True)
                    if not node.setblob(json.dumps(state).encode(), 0, "S"):
                        raise ValueError("could not save sync baseline in the IDB")
        report["applied"] = True
        return report
    finally:
        ti.free_til(scratch)
