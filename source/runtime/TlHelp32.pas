unit TlHelp32;

interface

type
  TModuleEntry32 = packed record // @size $224
    dwSize: Cardinal; // @offset $00
    th32ModuleID: Cardinal; // @offset $04
    th32ProcessID: Cardinal; // @offset $08
    GlblcntUsage: Cardinal; // @offset $0C
    ProccntUsage: Cardinal; // @offset $10
    modBaseAddr: PByte; // @offset $14
    modBaseSize: Cardinal; // @offset $18
    hModule: Cardinal; // @offset $1C
    szModule: array[0..255] of AnsiChar; // @offset $20
    szExePath: array[0..259] of AnsiChar; // @offset $120
  end;
  TCreateToolhelp32Snapshot = function(Flags, ProcessId: Cardinal): Cardinal; stdcall;
  TModule32First = function(Snapshot: Cardinal; var Entry: TModuleEntry32): LongBool; stdcall;
  TModule32Next = function(Snapshot: Cardinal; var Entry: TModuleEntry32): LongBool; stdcall;

// Resolves Toolhelp exports from the loaded kernel32.dll. The retained callers
// use CreateToolhelp32Snapshot, Module32First and Module32Next through its slots.
function InitToolHelp: Boolean;
function CreateToolhelp32Snapshot(Flags, ProcessId: Cardinal): Cardinal; // @addr $482784
function Module32First(Snapshot: Cardinal; var Entry: TModuleEntry32): LongBool; // @addr $4827A4
function Module32Next(Snapshot: Cardinal; var Entry: TModuleEntry32): LongBool; // @addr $4827C4

var
  // Verified GetProcAddress destinations in InitToolHelp; SDK private names
  // retained to identify the corresponding linked RTL slots.
  _CreateToolhelp32Snapshot: TCreateToolhelp32Snapshot; // @addr $819E70
  _Module32First: TModule32First; // @addr $819EA0
  _Module32Next: TModule32Next; // @addr $819EA4

implementation
end.
