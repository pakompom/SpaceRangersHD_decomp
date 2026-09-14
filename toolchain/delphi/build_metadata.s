# Explicit private RTTI names and deterministic resource timestamp callback.
# The names passed to the existing emitter change; compiler symbols do not.
# $44C560 returns a full-word difference mask, despite its recovered bool type.
.intel_syntax noprefix
.code32
.text
.globl type_nm, rs_time
type_nm:
 pushad
 mov edi,[ebx+0x18]
 mov edi,[edi+0x6c]
 add edi,33
 mov esi,eax
 call type_base
type_base:
 pop ebx
 .equ type_rva,HOOK_RVA+type_base-start
 sub ebx,offset type_rva
 .equ key_rva,HOOK_RVA+type_keys-start
 lea ebp,[ebx+key_rva]
type_next:
 mov eax,[ebp]
 test eax,eax
 jz type_done
 add eax,ebx
 mov edx,edi
 dcc_call 0x4c560
 test eax,eax
 jnz type_advance
 mov eax,[ebp+4]
 add eax,ebx
 mov edx,esi
 dcc_call 0x4c560
 test eax,eax
 jnz type_advance
 mov eax,[ebp+8]
 add eax,ebx
 mov [esp+28],eax
 jmp type_done
type_advance:
 add ebp,12
 jmp type_next
type_done:
 popad
 .byte 0xe9
 .long 0x8b564-(HOOK_RVA+(. - start)+4)
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
