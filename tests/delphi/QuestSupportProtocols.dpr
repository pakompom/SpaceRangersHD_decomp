library QuestSupportProtocols;
{$O-}{$R-}{$Q-}{$B-}
uses SysUtils;
type TIntegers = array of Integer;

function SameHandlers(Value: Integer): Integer;
begin
  Result := 0;
  try
    Result := 100 div Value;
  except
    on EDivByZero do Result := -7;
    on EIntOverflow do Result := -7;
  end;
end;

function DifferentHandlers(Value: Integer): Integer;
begin
  Result := 0;
  try
    Result := 100 div Value;
  except
    on EDivByZero do Result := -7;
    on EIntOverflow do Result := -8;
  end;
end;

procedure Resize(var Values: TIntegers; A, B: Integer);
begin
  SetLength(Values, A + B);
  Values[0] := 42;
end;

procedure Accumulate(var Total: Integer; Value: Integer);
begin
  Inc(Total, Value);
end;

function FoldedLatch(Count: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Count do
  begin
    if i = 2 then Result := Result + 3;
    Accumulate(Result, i);
  end;
end;

procedure ProtectedResize(var Values: TIntegers; A, B: Integer);
begin
  try
    SetLength(Values, A + B);
  finally
    Values[0] := 42;
  end;
end;

function GetLevel: Integer;
begin
  Result := 3;
end;

function Scale(Level: Integer; BaseValue, Factor: Single): Single;
begin
  Result := BaseValue * Factor + Level;
end;

function StackFloats: Single;
begin
  Result := Scale(GetLevel, 81, 0.333);
end;

exports SameHandlers, DifferentHandlers, Resize, FoldedLatch, ProtectedResize, StackFloats;
begin
end.
