program DynamicRecordArrays;
{$APPTYPE CONSOLE}
{$O-}
{$R-}
{$Q-}
type
  TEntry = record
    Kind: Integer;
    Values: array[0..1] of Integer;
    Resource: TObject;
  end;
  TEntries = array of TEntry;
  TEntriesAlias = TEntries;
  THolder = class
    Entries: array of TEntry;
  end;
var
  Entries: TEntries;
function ReadEntry(const Items: TEntriesAlias; Index, Column: Integer): Integer;
begin
  Result := Items[Index].Values[Column];
end;
procedure WriteEntry(Holder: THolder; Index, Value: Integer);
begin
  Holder.Entries[Index].Values[1] := Value;
end;
function FirstResource: TObject;
begin
  Result := Entries[0].Resource;
end;
procedure ClearResource(Index: Integer);
begin
  if Entries[Index].Resource <> nil then
  begin
    Entries[Index].Resource.Free;
    Entries[Index].Resource := nil;
  end;
end;
begin
  Writeln(ReadEntry(Entries, 0, 1));
  WriteEntry(nil, 0, 1);
  Writeln(Integer(FirstResource));
  ClearResource(0);
end.
