unit State;
interface
var
  Encoded: Cardinal = $B1CD15D3; // @addr $2000
  Names: array[1..2] of WideString = ('AutoSave.sav', 'QuickSave.sav'); // @addr $2004
function ReadState: Cardinal; // @addr $1000
procedure WriteState(Value: Cardinal); // @addr $1100
implementation
{ @routine $1000 ReadState }
function ReadState: Cardinal;
begin
  Result := Encoded;
end;
{ @end $1000 }
{ @routine $1100 WriteState }
procedure WriteState(Value: Cardinal);
begin
  Encoded := Value;
end;
{ @end $1100 }
end.
