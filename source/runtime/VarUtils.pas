unit VarUtils;
// Unit bracket (inferred): .text 0x0040FD7C..0x00410407; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

function BackupVariantChangeTypeEx(var Dest: TVarData; const Source: TVarData; LCID: Integer; wFlags: Word; VarType: Word): HResult; stdcall; // @ida "HResult __stdcall $name(TVarData *Dest, TVarData *Source, __int32 LCID, unsigned __int16 wFlags, unsigned __int16 VarType);" @note "DCC32 MAP VarUtils.BackupVariantChangeTypeEx. Source rtl/sys/VarUtils.pas:1070."

procedure BackupVarBoolFromStr; // @nameonly @note "DCC32 MAP VarUtils.BackupVarBoolFromStr. Source rtl/sys/VarUtils.pas:1146. Prototype pending: source type not found: WordBool."

procedure BackupVarBStrFromCy; // @nameonly @note "DCC32 MAP VarUtils.BackupVarBStrFromCy. Source rtl/sys/VarUtils.pas:1161. Prototype pending: source type not found: Currency."

function BackupVarBStrFromDate(dateIn: TDateTime; LCID: Integer; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall; // @ida "HResult __stdcall $name(TDateTime dateIn, __int32 LCID, __int32 dwFlags, unsigned __int16 * *bstrOut);" @note "DCC32 MAP VarUtils.BackupVarBStrFromDate. Source rtl/sys/VarUtils.pas:1173."

procedure BackupVarBStrFromBool; // @nameonly @note "DCC32 MAP VarUtils.BackupVarBStrFromBool. Source rtl/sys/VarUtils.pas:1185. Prototype pending: source type not found: WordBool."

function FindProc(const AName: PAnsiChar; ADefault: Pointer): Pointer; // @nameonly @note "DCC32 MAP VarUtils.FindProc. Source rtl/sys/VarUtils.pas:2028. Prototype pending: nested routine has a parent-frame parameter."

procedure InitializeVarUtils; // @nameonly @note "DCC32 MAP VarUtils.InitializeVarUtils. Prototype pending: no unique source declaration."

implementation
end.
