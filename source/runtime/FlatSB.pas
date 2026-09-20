unit FlatSB;
// Unit bracket (inferred): .text 0x004307E0..0x0043099C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

function FlatSB_SetScrollProp(p1: Cardinal; index: Integer; newValue: Integer; p4: LongBool): LongBool; stdcall; // @note "DCC32 MAP FlatSB.FlatSB_SetScrollProp. Source rtl/win/FlatSB.pas:73."

function InitializeFlatSB(hWnd: Cardinal): LongBool; stdcall; // @note "DCC32 MAP FlatSB.InitializeFlatSB. Source rtl/win/FlatSB.pas:80."

procedure InitFlatSB; // @note "DCC32 MAP FlatSB.InitFlatSB. Source rtl/win/FlatSB.pas:90."

implementation
end.
