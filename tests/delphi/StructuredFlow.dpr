program StructuredFlow;
{$APPTYPE CONSOLE}
{$O-}{$R-}{$Q-}{$B-}

{ Compile-only DCC32 controls: each Raw/structured pair emits identical bytes.
  Keep loop-tail advancement outside the single-pass eligibility block. }

procedure RawLoop(P: PInteger; Count: Integer);
label NextItem;
var I: Integer;
begin
  I := 0;
  while I < Count do
  begin
    if P^ = 0 then begin Inc(I); goto NextItem end;
    P^ := P^ - 1;
    Inc(I);
  NextItem: ;
  end;
end;
procedure ContinueLoop(P: PInteger; Count: Integer);
var I: Integer;
begin
  I := 0;
  while I < Count do
  begin
    if P^ = 0 then begin Inc(I); Continue end;
    P^ := P^ - 1;
    Inc(I);
  end;
end;
procedure RawFilter(P: PInteger; Count: Integer);
label NextItem;
var I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if P^ < 0 then goto NextItem;
    if P^ > 10 then goto NextItem;
    P^ := P^ + 1;
  NextItem:
    P := Pointer(PAnsiChar(P) + SizeOf(Integer));
  end;
end;
procedure BlockFilter(P: PInteger; Count: Integer);
var I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    repeat
      if P^ < 0 then Break;
      if P^ > 10 then Break;
      P^ := P^ + 1;
    until True;
    P := Pointer(PAnsiChar(P) + SizeOf(Integer));
  end;
end;
function RawFallback(P: PInteger; Minimum: Integer): Integer;
label Fallback;
begin
  if P = nil then goto Fallback;
  if P^ < Minimum then goto Fallback;
  Result := P^;
  Exit;
Fallback:
  Result := -1;
end;
function NestedFallback(P: PInteger; Minimum: Integer): Integer;
begin
  if P <> nil then
    if P^ >= Minimum then
    begin
      Result := P^;
      Exit;
    end;
  Result := -1;
end;
var Value: Integer;
begin
  RawLoop(@Value, 1); ContinueLoop(@Value, 1);
  RawFilter(@Value, 1); BlockFilter(@Value, 1);
  Writeln(RawFallback(@Value, 1), NestedFallback(@Value, 1));
end.
