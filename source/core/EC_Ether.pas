unit EC_Ether;
// Unit bracket (inferred): .text 0x004EB36C..0x004EB894; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    constructor Create; // @addr $4EB42C @ida "TEther *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $4EB480 @ida "void __usercall $name(TEther *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Native destructor leaves the critical section; it does not free the lock or clear entries."
    procedure Clear; // @addr $4EB4BC
    function AppendEntry: TEtherUnit; // @addr $4EB504
    procedure RemoveEntry(Item: TEtherUnit); // @addr $4EB570 @note "Unlinks and frees the entry without updating SortedItems or Count."
    function GetIndexedEntry(Index: Integer): TEtherUnit; // @addr $4EB5E8 @note "Native assembly restores EAX after loading the entry, returning Self instead of the indexed value."
    procedure SetIndexedEntry(Index: Integer; Item: TEtherUnit); // @addr $4EB5FC
    function FindInsertionIndex(const Name: WideString): Integer; // @addr $4EB610
    procedure Add(const Name: WideString; Value: Integer); // @addr $4EB6C4
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $4EB77C
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr $4EB7D4
    procedure Enter; // @addr $4EB868
    procedure Leave; // @addr $4EB880
  end;

implementation

uses EC_Mem, EC_Str;

{ @routine $4EB42C TEther_Create }
constructor TEther.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;
{ @end $4EB42C }

{ @routine $4EB480 TEther_Destroy }
destructor TEther.Destroy;
begin
  Lock.Leave;
  inherited Destroy;
end;
{ @end $4EB480 }

{ @routine $4EB4BC TEther_Clear }
procedure TEther.Clear;
begin
  while First <> nil do RemoveEntry(Last);
  if SortedItems <> nil then begin FreeEC(SortedItems); SortedItems := nil; end;
  Count := 0;
end;
{ @end $4EB4BC }

{ @routine $4EB504 TEther_AppendEntry }
function TEther.AppendEntry: TEtherUnit;
var Item: TEtherUnit;
begin
  Item := TEtherUnit.Create;
  if Last <> nil then Last.Next := Item;
  Item.Prev := Last; Item.Next := nil; Last := Item;
  if First = nil then First := Item;
  Result := Item;
end;
{ @end $4EB504 }

{ @routine $4EB570 TEther_RemoveEntry }
procedure TEther.RemoveEntry(Item: TEtherUnit);
begin
  if Item.Prev <> nil then Item.Prev.Next := Item.Next;
  if Item.Next <> nil then Item.Next.Prev := Item.Prev;
  if Last = Item then Last := Item.Prev;
  if First = Item then First := Item.Next;
  Item.Free;
end;
{ @end $4EB570 }

{ @routine $4EB5E8 TEther_GetIndexedEntry }
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
{ @end $4EB5E8 }

{ @routine $4EB5FC TEther_SetIndexedEntry }
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
{ @end $4EB5FC }

{ @routine $4EB610 TEther_FindInsertionIndex }
function TEther.FindInsertionIndex(const Name: WideString): Integer;
var Left, Right, Middle, Comparison: Integer; Item: TEtherUnit;
begin
  if Count <= 0 then begin Result := 0; Exit; end;
  Left := 0; Right := Count - 1;
  repeat
    Middle := ((Right - Left) shr 1) + Left;
    Item := GetIndexedEntry(Middle);
    Comparison := CompareWideChars(PWideChar(Name), PWideChar(Item.Name));
    if Comparison = 0 then begin Result := Middle; Exit; end;
    if Comparison < 0 then Right := Middle - 1 else Left := Middle + 1;
  until Right < Left;
  if Comparison < 0 then Result := Middle else Result := Middle + 1;
end;
{ @end $4EB610 }

{ @routine $4EB6C4 TEther_Add }
procedure TEther.Add(const Name: WideString; Value: Integer);
var MoveCount: Integer; Item: TEtherUnit; Index: Integer;
begin
  Enter;
  Item := AppendEntry;
  Item.Name := Name; Item.Value := Value;
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
  SetIndexedEntry(Index, Item);
  Leave;
end;
{ @end $4EB6C4 }

{ @routine $4EB77C TEther_SaveToBuffer }
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
{ @end $4EB77C }

{ @routine $4EB7D4 TEther_LoadFromBuffer }
procedure TEther.LoadFromBuffer(Buffer: TBufEC);
var Name: WideString; Index, ItemCount, Value: Integer;
begin
  Clear;
  ItemCount := Buffer.GetInt32;
  for Index := 0 to ItemCount - 1 do
  begin
    Name := Buffer.ReadWideString; Value := Buffer.GetInt32;
    Add(Name, Value);
  end;
end;
{ @end $4EB7D4 }

{ @routine $4EB868 TEther_Enter }
procedure TEther.Enter;
begin
  Lock.Enter;
end;
{ @end $4EB868 }

{ @routine $4EB880 TEther_Leave }
procedure TEther.Leave;
begin
  Lock.Leave;
end;
{ @end $4EB880 }

end.
