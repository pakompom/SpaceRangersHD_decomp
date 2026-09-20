# Deterministic resource timestamp callback.
.intel_syntax noprefix
.code32
.text
.globl rs_time
# cdecl callback(handle, DOS timestamp out, size out): keep normal I/O/errors.
rs_time:
 push dword ptr [esp+12]
 push dword ptr [esp+12]
 push dword ptr [esp+12]
 dcc_call 0x36b60
 add esp,12
 test eax,eax
 jnz time_done
 mov edx,[esp+8]
 mov dword ptr [edx],DOS_TIMESTAMP
time_done:
 ret
