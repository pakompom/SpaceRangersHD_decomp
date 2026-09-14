"""Concrete signatures for register-counted, callee-cleaned stack arguments."""
import re


def specialize(prototype, element, count, *, cleanup="callee", order="reverse"):
    if not 1 <= count <= 256:
        raise ValueError(f"counted stack argument count outside 1..256: {count}")
    arguments = ", ".join(f"{element} StackArg{i + 1}@<^{4 * (count - i - 1 if order == 'reverse' else i)}>"
                          for i in range(count))
    return re.sub(r"\.\.\.\s*\);$", arguments + ");",
                  prototype.replace("__usercall", "__userpurge", 1) if cleanup == "callee" else prototype)


def find_count(instructions):
    """Walk backward inside one straight-line block; never cross a clobber."""
    for instruction in instructions:
        if instruction.get("barrier"):
            break
        if "immediate" in instruction:
            count = instruction["immediate"]
            if 1 <= count <= 256:
                return count
            break
        if instruction.get("writes_count"):
            break
    raise ValueError("no positive constant count in the preceding straight-line block")


def native_calls(item):
    import ida_bytes
    import ida_funcs
    import ida_idp
    import ida_ua
    import idautils
    import idc

    register = item["countedstack"]["register"]
    aliases = {"eax": {"eax", "ax", "al", "ah"},
               "edx": {"edx", "dx", "dl", "dh"},
               "ecx": {"ecx", "cx", "cl", "ch"}}[register]

    def preceding(call_ea):
        cursor = call_ea
        owner = ida_funcs.get_func(call_ea)
        if owner is None:
            raise ValueError("call is outside an IDA function")
        for _ in range(16):
            # A branch into this point may bypass an earlier count assignment.
            if next(idautils.CodeRefsTo(cursor, False), None) is not None:
                return
            ea = ida_bytes.prev_head(cursor, 0)
            insn = ida_ua.insn_t()
            parent = ida_funcs.get_func(ea)
            if (parent is None or parent.start_ea != owner.start_ea or
                    not ida_ua.decode_insn(insn, ea) or ea + insn.size != cursor):
                return
            mnemonic = idc.print_insn_mnem(ea).lower()
            if ida_idp.is_call_insn(insn) or mnemonic not in {
                    "mov", "lea", "push", "pop", "nop", "xor", "and", "or",
                    "add", "sub", "inc", "dec", "test", "cmp"}:
                return
            if (mnemonic == "mov" and idc.print_operand(ea, 0) == register and
                    insn.ops[1].type == ida_ua.o_imm):
                yield {"immediate": insn.ops[1].value}
                return
            features = insn.get_canon_feature()
            writes = any(features & getattr(ida_idp, f"CF_CHG{i + 1}") and
                         idc.print_operand(ea, i) in aliases for i in range(6))
            yield {"writes_count": writes}
            if writes:
                return
            cursor = ea

    result = []
    for ea in sorted(set(idautils.CodeRefsTo(item["addr"], False))):
        insn = ida_ua.insn_t()
        if not ida_ua.decode_insn(insn, ea) or not ida_idp.is_call_insn(insn):
            raise ValueError(f"counted stack target has a non-call reference at 0x{ea:X}")
        try:
            count = find_count(preceding(ea))
        except ValueError as exc:
            raise ValueError(f"{item['name']} at 0x{ea:X}: {exc}") from exc
        result.append((ea, specialize(item["decl"], item["countedstack"]["element"], count,
                                      cleanup=item["countedstack"].get("cleanup", "callee"),
                                      order=item["countedstack"].get("order", "reverse"))))
    return result
