program Exceptions;
{$APPTYPE CONSOLE}{$O-}{$R-}{$Q-}{$B-}

function ExternalValue(Value: Integer): Integer;
begin
  Result := Value div 2;
end;

function CatchValue(Value: Integer): Integer;
begin
  try
    Result := ExternalValue(Value);
  except
    Result := -1;
  end;
end;

procedure FinallyIncrement(var Value: Integer);
begin
  try
    Value := ExternalValue(Value);
  finally
    Inc(Value);
  end;
end;

function TwoHandlers(Value: Integer): Integer;
begin
  try
    Value := ExternalValue(Value);
  except
    Value := 0;
  end;
  try
    Result := ExternalValue(Value);
  except
    Result := -1;
  end;
end;

var
  TestValue: Integer;
begin
  Writeln(CatchValue(4), TwoHandlers(4));
  TestValue := 4;
  FinallyIncrement(TestValue);
end.
