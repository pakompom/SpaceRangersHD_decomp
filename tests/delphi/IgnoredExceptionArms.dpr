library IgnoredExceptionArms;
{$O-}{$R-}{$Q-}{$B-}
uses SysUtils;

function IgnoreFirst(Value: Integer): Integer;
begin
  Result := 0;
  try
    Result := 100 div Value;
  except
    on E: EDivByZero do ;
    on E: Exception do Result := -7;
  end;
end;

function IgnoreTwo(Value: Integer): Integer;
begin
  Result := 0;
  try
    Result := 100 div Value;
  except
    on EDivByZero do ;
    on EIntOverflow do ;
    on Exception do Result := -9;
  end;
end;

function KeepObject(Value: Integer): Integer;
begin
  Result := 0;
  try
    Result := 100 div Value;
  except
    on E: EDivByZero do Result := Integer(E);
    on Exception do Result := -7;
  end;
end;

exports IgnoreFirst, IgnoreTwo, KeepObject;
begin
end.
