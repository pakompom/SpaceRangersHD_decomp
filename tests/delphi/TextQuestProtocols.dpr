library TextQuestProtocols;
{$O-}{$R-}{$Q-}{$B-}
uses SysUtils;

function TypedDivide(Value: Integer): Integer;
begin
  try
    Result := 100 div Value;
  except
    on EDivByZero do Result := -7;
  end;
end;

function TypedExit(Value: Integer): Integer;
begin
  Result := 9;
  try
    Result := 100 div Value;
  except
    on EDivByZero do Exit;
  end;
end;

procedure Join(var Dest: WideString; A, B: WideString);
begin
  Dest := A + ' / ' + B;
  Dest := Dest + '!';
end;

function FilterChar(Value: WideChar): Integer;
begin
  Result := 0;
  case Value of
    '^': ; '+': ; '-': ; '*': ; '/': ; '#': ; '%': ; '$': ;
    'c': ; 'b': ; 'e': ; 'f': ; 'g': ; '=': ; '>': ; '<': ;
    '&': ; '|': ; '0'..'9': ; ',': ; '(': ; ')': ; ' ': ;
  else Exit;
  end;
  Result := 1;
end;

exports TypedDivide, TypedExit, Join, FilterChar;
begin
end.
