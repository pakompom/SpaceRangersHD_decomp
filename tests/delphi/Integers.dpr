program IntegerControls;
{$APPTYPE CONSOLE}
{$O-}{$R-}{$Q-}

type
  TMask = set of 0..79;
  TByteMask = set of 0..7;
  TRow = record
    Prefix: Integer;
    Values: array[0..2] of Integer;
  end;
  TTable = array[0..3] of TRow;
  PTable = ^TTable;

function Half(Value: Integer): Integer;
begin
  Result := Value div 2;
end;

function ClampLow(Value: Int64): Int64;
begin
  if Value < 2 then Result := 2 else Result := Value;
end;

function Minimum(Left: Integer; Right: Int64): Int64;
begin
  if Left <= Right then Result := Left else Result := Right;
end;

function Contains(Mask, Value: Byte): Boolean;
begin
  Result := Value in [0..7];
  if Result then Result := Mask and (1 shl Value) <> 0;
end;

function Singleton(Value: Byte): TMask;
begin
  Result := [Value];
end;

function TableValue(var Table: TTable; Row, Column: Integer): Integer;
begin
  Result := Table[Row].Values[Column];
end;

function MaskFactor(var Mask: TByteMask; Value: Byte): Integer;
begin
  if Value in Mask then Result := 3 else Result := 1;
end;

function OutsideRange(Value: Byte): Boolean;
begin
  Result := not (Value in [1..2]);
end;

function Threshold: Double;
var
  Chance: Double;
begin
  Chance := 0.03;
  Result := Chance + 1;
end;

var
  Value: Int64;
  Table: TTable;
  Mask: TMask;
  ByteMask: TByteMask;
begin
  if Threshold < 0 then Halt(1);
  Value := Minimum(Half(-5), ClampLow(-4));
  Mask := Singleton(7);
  ByteMask := [7];
  Table[1].Values[2] := 17;
  Writeln(Value, Contains(128, 7), TableValue(Table, 1, 2), 7 in Mask, MaskFactor(ByteMask, 7), OutsideRange(0));
end.
