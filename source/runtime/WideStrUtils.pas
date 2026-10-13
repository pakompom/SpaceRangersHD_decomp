unit WideStrUtils;

interface

uses System;

function WStrLCopy(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar; // @note "Copies at most MaxLen UTF-16 code units and appends a zero terminator; Dest needs MaxLen + 1 code units."
function WStrPLCopy(Dest: PWideChar; const Source: WideString; MaxLen: Cardinal): PWideChar; // @addr 0x0042C818

implementation
end.
