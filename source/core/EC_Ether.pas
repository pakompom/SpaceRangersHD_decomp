unit EC_Ether;

interface

uses EC_Struct, EC_Buf, SyncObjs;

type
  TEtherUnit = class(TObject) // @size $14
  public
    Prev: TEtherUnit; // @offset $04
    Next: TEtherUnit; // @offset $08
    Value: Integer; // @offset $0C
    Name: WideString; // @offset $10
  end;
  PEtherIndex = ^TEtherIndex;
  TEtherIndex = array[0..$1FFFFFFE] of TEtherUnit;

  TEther = class(TObjectEx) // @size $18
  public
    First: TEtherUnit; // @offset $04
    Last: TEtherUnit; // @offset $08
    Count: Integer; // @offset $0C
    SortedItems: PEtherIndex; // @offset $10
    Lock: TCriticalSection; // @offset $14
    constructor Create; // @addr $4E9838
    destructor Destroy; override; // @addr $4E987C @note "Native destructor leaves the critical section; it does not free the lock or clear entries."
    procedure Clear; // @addr $4E98AC
    function AppendEntry: TEtherUnit; // @addr $4E98DC
    procedure RemoveEntry(Item: TEtherUnit); // @addr $4E9910 @note "Unlinks and frees the entry without updating SortedItems or Count."
    function GetIndexedEntry(Index: Integer): TEtherUnit; // @addr $4E994C @note "Native assembly restores EAX after loading the entry, returning Self instead of the indexed value."
    procedure SetIndexedEntry(Index: Integer; Item: TEtherUnit); // @addr $4E9960
    function FindInsertionIndex(const Name: WideString): Integer; // @addr $4E9974
    procedure Add(const Name: WideString; Value: Integer); // @addr $4E9A08
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $4E9AB4
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr $4E9AEC
    procedure Enter; // @addr $4E9B68
    procedure Leave; // @addr $4E9B74
    property Items[Index: Integer]: TEtherUnit read GetIndexedEntry write SetIndexedEntry; default;
  end;

implementation

uses EC_Mem, EC_Str;

{ @routine $4E9838 TEther_Create }
constructor TEther.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;
{ @end $4E9838 }

{ @routine $4E987C TEther_Destroy }
destructor TEther.Destroy;
begin
  Lock.Leave;
  inherited Destroy;
end;
{ @end $4E987C }

{ @routine $4E98AC TEther_Clear }
procedure TEther.Clear;
begin
  while First <> nil do RemoveEntry(Last);
  if SortedItems <> nil then
  begin
    FreeEC(SortedItems);
    SortedItems := nil;
  end;
  Count := 0;
end;
{ @end $4E98AC }

{ @routine $4E98DC TEther_AppendEntry }
function TEther.AppendEntry: TEtherUnit;
begin
  Result := TEtherUnit.Create;
  if Last <> nil then Last.Next := Result;
  Result.Prev := Last;
  Result.Next := nil;
  Last := Result;
  if First = nil then First := Result;
end;
{ @end $4E98DC }

{ @routine $4E9910 TEther_RemoveEntry }
procedure TEther.RemoveEntry(Item: TEtherUnit);
begin
  if Item.Prev <> nil then Item.Prev.Next := Item.Next;
  if Item.Next <> nil then Item.Next.Prev := Item.Prev;
  if Last = Item then Last := Item.Prev;
  if First = Item then First := Item.Next;
  Item.Free;
end;
{ @end $4E9910 }

{ @routine $4E994C TEther_GetIndexedEntry }
function TEther.GetIndexedEntry(Index: Integer): TEtherUnit;
asm
  PUSH EAX
  PUSH EBX
  MOV EBX, EAX
  MOV EAX, EDX
  SHL EAX, 2
  ADD EAX, [EBX].TEther.SortedItems
  MOV EAX, [EAX]
  POP EBX
  POP EAX
end;
{ @end $4E994C }

{ @routine $4E9960 TEther_SetIndexedEntry }
procedure TEther.SetIndexedEntry(Index: Integer; Item: TEtherUnit);
asm
  PUSH EAX
  PUSH EBX
  MOV EBX, EAX
  MOV EAX, EDX
  SHL EAX, 2
  ADD EAX, [EBX].TEther.SortedItems
  MOV EBX, ECX
  MOV [EAX], EBX
  POP EBX
  POP EAX
end;
{ @end $4E9960 }

{ @routine $4E9974 TEther_FindInsertionIndex }
function TEther.FindInsertionIndex(const Name: WideString): Integer;
var Left, Right, Middle, Comparison: Integer; Item: TEtherUnit;
begin
  if Count <= 0 then
  begin
    Result := 0;
    Exit;
  end;
  Left := 0;
  Right := Count - 1;
  while True do
  begin
    Middle := ((Right - Left) shr 1) + Left;
    Item := Items[Middle];
    Comparison := CompareWideChars(PWideChar(Name), PWideChar(Item.Name));
    if Comparison = 0 then
    begin
      Result := Middle;
      Exit;
    end;
    if Comparison < 0 then Right := Middle - 1 else Left := Middle + 1;
    if Right < Left then Break;
  end;
  if Comparison < 0 then Result := Middle else Result := Middle + 1;
end;
{ @end $4E9974 }

{ @routine $4E9A08 TEther_Add }
procedure TEther.Add(const Name: WideString; Value: Integer);
var MoveCount: Integer; Item: TEtherUnit; Index: Integer;
begin
  Enter;
  Item := AppendEntry;
  Item.Name := Name;
  Item.Value := Value;
  Index := FindInsertionIndex(Name);
  Inc(Count);
  SortedItems := ReAllocREC(SortedItems, Count * SizeOf(TEtherUnit));
  MoveCount := Count - 1 - Index;
  if MoveCount > 0 then
  asm
    PUSH EBX
    PUSH EAX
    PUSH EDX
    MOV EBX, Self
    MOV EDX, [EBX].TEther.Count
    SUB EDX, 1
    SHL EDX, 2
    ADD EDX, [EBX].TEther.SortedItems
    MOV ECX, MoveCount
  @@Move:
    MOV EAX, [EDX - 4]
    MOV [EDX], EAX
    SUB EDX, 4
    DEC ECX
    JNZ @@Move
    POP EDX
    POP EAX
    POP EBX
  end;
  Items[Index] := Item;
  Leave;
end;
{ @end $4E9A08 }

{ @routine $4E9AB4 TEther_SaveToBuffer }
procedure TEther.SaveToBuffer(Buffer: TBufEC);
var Item: TEtherUnit;
begin
  Buffer.AddIntegerValue(Count);
  Item := First;
  while Item <> nil do
  begin
    Buffer.AddWideStringZ(Item.Name); Buffer.AddIntegerValue(Item.Value);
    Item := Item.Next;
  end;
end;
{ @end $4E9AB4 }

{ @routine $4E9AEC TEther_LoadFromBuffer }
procedure TEther.LoadFromBuffer(Buffer: TBufEC);
var Name: WideString; Index, ItemCount, Value: Integer;
begin
  Clear;
  ItemCount := Buffer.GetInt32;
  for Index := 0 to ItemCount - 1 do
  begin
    Name := Buffer.ReadWideString;
    Value := Buffer.GetInt32;
    Add(Name, Value);
  end;
end;
{ @end $4E9AEC }

{ @routine $4E9B68 TEther_Enter }
procedure TEther.Enter;
begin
  Lock.Enter;
end;
{ @end $4E9B68 }

{ @routine $4E9B74 TEther_Leave }
procedure TEther.Leave;
begin
  Lock.Leave;
end;
{ @end $4E9B74 }

end.
