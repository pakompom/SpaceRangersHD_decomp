unit WideStrUtils;
// Unit bracket (inferred): .text 0x0042C7F0..0x0042C836; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses System;

function WStrLCopy(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar; // @note "Copies at most MaxLen UTF-16 code units and appends a zero terminator; Dest needs MaxLen + 1 code units."
function WStrPLCopy(Dest: PWideChar; const Source: WideString; MaxLen: Cardinal): PWideChar; // @addr 0x42C818

implementation
end.
