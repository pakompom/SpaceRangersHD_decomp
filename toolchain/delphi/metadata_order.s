# Emit the recovered module order through DCC32's ordinary metadata writers.
# Check the full marked unit set; the current root is not yet in the loaded list.
.intel_syntax noprefix
.code32
.text
.globl meta_ini, meta_pkg
.macro dcc_call destination
 .byte 0xe8
 .long \destination-(HOOK_RVA+(. - start)+4)
.endm
meta_ini:
 pushad
 mov ebp,eax
 call ini_base
ini_base:
 pop ebx
 .equ ini_rva,HOOK_RVA+ini_base-start
 sub ebx,offset ini_rva
 call meta_ok
 test eax,eax
 jz ini_fallback
 .equ init_rva,HOOK_RVA+init_keys-start
 lea esi,[ebx+init_rva]
 mov edi,META_COUNT
ini_next:
 mov eax,[esi]
 test eax,eax
 jz ini_zero
 add eax,ebx
 call meta_find
 xor edx,edx
 cmp eax,ebp
 setne dl
 dcc_call 0x14390
 jmp ini_advance
ini_zero:
 xor eax,eax
 dcc_call 0x35468
 xor eax,eax
 dcc_call 0x35468
ini_advance:
 add esi,4
 dec edi
 jnz ini_next
 popad
 ret
ini_fallback:
 popad
 .byte 0xe9
 .long 0x14444-(HOOK_RVA+(. - start)+4)
meta_pkg:
 pushad
 mov ebp,edx
 mov eax,edx
 call pkg_base
pkg_base:
 pop ebx
 .equ pkg_rva,HOOK_RVA+pkg_base-start
 sub ebx,offset pkg_rva
 call meta_ok
 test eax,eax
 jz pkg_fallback
 push META_COUNT
 mov ecx,esp
 mov edx,4
 mov eax,[esp+32]
 dcc_call 0x557b8
 add esp,4
 .equ package_rva,HOOK_RVA+package_keys-start
 lea esi,[ebx+package_rva]
 mov edi,META_COUNT
pkg_next:
 mov eax,[esi]
 add eax,ebx
 call meta_find
 mov edx,eax
 mov eax,[esp+28]
 dcc_call 0x1420c
 add esi,4
 dec edi
 jnz pkg_next
 popad
 ret
pkg_fallback:
 popad
 .byte 0xe9
 .long 0x1430c-(HOOK_RVA+(. - start)+4)
# Check the marked module graph before emitting anything: exactly the known units.
meta_ok:
 push esi
 push edi
 mov eax,[ebp+0x6c]
 mov edx,[eax+33]
 or edx,0x20202020
 cmp edx,0x676e6172
 jne meta_bad
 mov edx,[eax+37]
 or edx,0x00202020
 cmp edx,0x00737265
 jne meta_bad
 mov esi,[ebx+0xddadc]
 mov ecx,1
meta_count:
 test esi,esi
 jz meta_counted
 cmp esi,ebp
 je meta_uncounted
 test byte ptr [esi+20],0x40
 jz meta_uncounted
 inc ecx
meta_uncounted:
 mov esi,[esi+4]
 jmp meta_count
meta_counted:
 cmp ecx,META_COUNT
 jne meta_bad
 .equ verify_rva,HOOK_RVA+package_keys-start
 lea esi,[ebx+verify_rva]
 mov edi,META_COUNT
meta_verify:
 mov eax,[esi]
 add eax,ebx
 call meta_find
 test eax,eax
 jz meta_bad
 test byte ptr [eax+20],0x40
 jz meta_bad
 add esi,4
 dec edi
 jnz meta_verify
 mov eax,1
 jmp meta_return
meta_bad:
 xor eax,eax
meta_return:
 pop edi
 pop esi
 ret
# EAX = name; EBX = compiler image base. Return EAX = loaded context or zero.
meta_find:
 push ecx
 push edx
 push esi
 push edi
 mov edi,eax
 .equ root_rva,HOOK_RVA+meta_u0-start
 lea edx,[ebx+root_rva]
 mov esi,ebp
 cmp edi,edx
 je meta_found
 mov esi,[ebx+0xddadc]
meta_candidate:
 test esi,esi
 jz meta_found
 mov edx,[esi+0x6c]
 add edx,33
 xor ecx,ecx
meta_compare:
 mov al,[edx+ecx]
 test al,al
 jz meta_name_end
 or al,0x20
 mov ah,[edi+ecx]
 or ah,0x20
 cmp al,ah
 jne meta_mismatch
 inc ecx
 jmp meta_compare
meta_name_end:
 cmp byte ptr [edi+ecx],0
 je meta_found
meta_mismatch:
 mov esi,[esi+4]
 jmp meta_candidate
meta_found:
 mov eax,esi
 pop edi
 pop esi
 pop edx
 pop ecx
 ret
