program RecordAddressTemporaries;
{$APPTYPE CONSOLE}
{$O-}
{$R-}
{$Q-}
type
  TEntry = record
    Kind: Integer;
    Values: array[0..1] of Integer;
    Extra: Integer;
  end;
  PEntry = ^TEntry;
  TEntries = array of TEntry;
var Entries: TEntries;
procedure WriteThroughWith(Index, Value: Integer);
begin
  with Entries[Index] do
  begin
    Kind := Value;
    Values[1] := Kind + 3;
  end;
end;
procedure WriteThroughPointer(Index, Value: Integer);
var Entry: PEntry;
begin
  Entry := @Entries[Index];
  Entry.Kind := Value;
  Entry.Values[1] := Entry.Kind + 5;
end;
procedure WriteInteriorField(Index, Value: Integer);
var Field: ^Integer;
begin
  Field := @Entries[Index].Extra;
  Field^ := Value;
end;
begin
  WriteThroughWith(0, 2);
  WriteThroughPointer(0, 4);
  WriteInteriorField(0, 6);
end.
