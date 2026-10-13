unit VarUtils;

interface

function BackupVariantChangeTypeEx(var Dest: TVarData; const Source: TVarData; LCID: Integer; wFlags: Word; VarType: Word): HResult; stdcall; // @ida "HResult __stdcall $name(TVarData *Dest, TVarData *Source, __int32 LCID, unsigned __int16 wFlags, unsigned __int16 VarType);"

procedure BackupVarBoolFromStr; // @nameonly

procedure BackupVarBStrFromCy; // @nameonly

function BackupVarBStrFromDate(dateIn: TDateTime; LCID: Integer; dwFlags: Longint; out bstrOut: WideString): HResult; stdcall;

procedure BackupVarBStrFromBool; // @nameonly

function FindProc(const AName: PAnsiChar; ADefault: Pointer): Pointer; // @nameonly

procedure InitializeVarUtils; // @nameonly

implementation
end.
