library FinallyTransfers;
{$O-}{$R-}{$Q-}{$B-}

procedure BreakInFinally(var Total: Integer; Limit: Integer);
var Index: Integer;
begin
  Index := 0;
  while True do
  begin
    try
      if Index >= Limit then Break;
      Inc(Index);
    finally
      Inc(Total);
    end;
  end;
  Inc(Total, 10);
end;

function ExitInFinally(Value: Integer): Integer;
begin
  Result := Value;
  try
    if Value < 0 then Exit;
    Inc(Result, 2);
  finally
    Inc(Result, 3);
  end;
  Inc(Result, 10);
end;

procedure EndOfControls;
begin
end;
exports BreakInFinally, ExitInFinally, EndOfControls;
begin
end.
