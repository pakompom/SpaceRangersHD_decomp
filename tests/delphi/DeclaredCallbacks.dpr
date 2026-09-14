program DeclaredCallbacks;
{$O-}
type
  TNotify = procedure(Value: Integer); cdecl;
  TQuery = function(A, B: Integer): Integer; cdecl;
  TAdjust = function(Value: Integer; var Total: Integer): Boolean; stdcall;
var
  Notify: TNotify;
  Query: TQuery;
  Adjust: TAdjust;
  Total: Integer;
procedure InvokeCallbacks(Value: Integer);
var Saved: Integer;
begin
  Saved := Value + 3;
  Notify(17);
  Total := Query(Saved, Value);
  if Adjust(9, Total) then Total := Total + Saved;
end;
begin
  InvokeCallbacks(5);
end.
