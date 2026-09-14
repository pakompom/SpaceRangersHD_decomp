program ProcVarTypes;
uses A;
type TExternal = function(Value: Integer): Integer; stdcall;
var Typed: TExternal; Raw: Pointer;
function SharedExternal(Value: Integer): Integer; stdcall; external 'probe.dll' name 'SharedExternal';
procedure TypedLocal; begin Typed := SharedExternal; end;
procedure TypedForeign; begin Typed := A.SharedExternal; end;
procedure RawLocal; begin Raw := @SharedExternal; end;
procedure RawForeign; begin Raw := @A.SharedExternal; end;
procedure TypedLocalAddress; begin Typed := @SharedExternal; end;
procedure TypedCast; begin Typed := TExternal(@SharedExternal); end;
exports TypedLocal, TypedForeign, RawLocal, RawForeign, TypedLocalAddress, TypedCast;
begin end.
