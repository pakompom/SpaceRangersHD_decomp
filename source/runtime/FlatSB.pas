unit FlatSB;

interface

function FlatSB_SetScrollProp(p1: Cardinal; index: Integer; newValue: Integer; p4: LongBool): LongBool; stdcall;

function InitializeFlatSB(hWnd: Cardinal): LongBool; stdcall;

procedure InitFlatSB;

implementation
end.
