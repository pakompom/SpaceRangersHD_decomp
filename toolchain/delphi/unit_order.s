# DCC32 11.0.2963.11001: called instead of promote_system_unit_context_to_loaded_head.
# Reorder loaded contexts before reachability/layout, preserving unlisted units.
# No game bytes or symbol addresses are emitted here. See docs/development.md#inputs-and-reproduction.
 .intel_syntax noprefix
.code32
.text
start:
 pushfd
 pushad
 sub esp,16
 call image_base
image_base:
 pop ebx
 .equ image_rva,HOOK_RVA+image_base-start
 sub ebx,offset image_rva
 mov [esp+12],ebx
 mov eax,[ebx+0xddadc]
 mov [esp+8],eax
 mov dword ptr [esp],0
 mov dword ptr [esp+4],0
 .equ names_rva,HOOK_RVA+names-start
 lea ebx,[ebx+names_rva]
next_name:
 cmp byte ptr [ebx],0
 je finished
 lea esi,[esp+8]
next_node:
 mov eax,[esi]
 test eax,eax
 jz advance_name
 mov edi,[eax+0x6c]
 add edi,33
 push eax
 xor ecx,ecx
compare_name:
 movzx eax,byte ptr [edi+ecx]
 movzx edx,byte ptr [ebx+ecx]
 test eax,eax
 jz name_end
 or eax,0x20
 or edx,0x20
 cmp eax,edx
 jne mismatch
 inc ecx
 jmp compare_name
name_end:
 test edx,edx
 jnz mismatch
 pop eax
 mov ecx,[eax+4]
 mov [esi],ecx
 mov dword ptr [eax+4],0
 mov edx,[esp+4]
 test edx,edx
 jz first_node
 mov [edx+4],eax
 jmp set_tail
first_node:
 mov [esp],eax
set_tail:
 mov [esp+4],eax
 jmp advance_name
mismatch:
 pop eax
 lea esi,[eax+4]
 jmp next_node
advance_name:
 cmp byte ptr [ebx],0
 lea ebx,[ebx+1]
 jne advance_name
 jmp next_name
finished:
 mov eax,[esp+8]
 mov edx,[esp+4]
 test edx,edx
 jz no_sorted_nodes
 mov [edx+4],eax
 mov eax,[esp]
no_sorted_nodes:
 mov ecx,[esp+12]
 mov [ecx+0xddadc],eax
 test eax,eax
 jz store_tail
walk_tail:
 mov edx,[eax+4]
 test edx,edx
 jz store_tail
 mov eax,edx
 jmp walk_tail
store_tail:
 mov [ecx+0xddae0],eax
 add esp,16
 popad
 popfd
 .byte 0xe9
 .long 0x322dc-(HOOK_RVA+(. - start)+4)
names:
