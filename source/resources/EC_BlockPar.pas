unit EC_BlockPar;
// Unit bracket (inferred): .text 0x0084665C..0x00849E6E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct;

type
  TBlockParKind = (bpkText = 0, bpkString = 1, bpkBlock = 2); // @size 0x04
  TBlockParEC = class;
  PBlockParEC = ^TBlockParEC;

  TBlockParElEC = class(TObjectEx) // @size 0x2C
  public
    Prev: TBlockParElEC; // @offset 0x04
    Next: TBlockParElEC; // @offset 0x08
    OwnerBlock: TBlockParEC; // @offset 0x0C
    ItemType: TBlockParKind; // @offset 0x10
    Name: WideString; // @offset 0x14
    StringValue: WideString; // @offset 0x18
    Comment: WideString; // @offset 0x1C
    ChildBlock: TBlockParEC; // @offset 0x20
    // Sorted entries group equal names and kinds; GroupCount is valid at the head.
    GroupIndex: Integer; // @offset 0x24
    GroupCount: Integer; // @offset 0x28

    constructor Create; // @addr 0x846794
    destructor Destroy; override; // @addr 0x8467D8
    procedure Clear; // @addr 0x846814 @note "Frees ChildBlock; links and index metadata remain unchanged."
    procedure MakeChildBlock; // @addr 0x846864 @note "Replaces the owned child; caller must update owner counts and index."
    procedure CopyFrom(Source: TBlockParElEC); // @addr 0x8468B4 @note "Deep-copies ChildBlock; links and index metadata remain unchanged."
  end;
  PBlockParElEC = ^TBlockParElEC;

  TBlockParEC = class(TObjectEx) // @size 0x24
  public
    FirstEntry: TBlockParElEC; // @offset 0x04
    LastEntry: TBlockParElEC; // @offset 0x08
    EntryCount: Integer; // @offset 0x0C
    StringParamCount: Integer; // @offset 0x10
    ChildBlockCount: Integer; // @offset 0x14
    UseSortedIndex: Boolean; // @offset 0x18
    // Delphi dynamic array; ordered by case-sensitive name, then kind.
    SortedEntries: array of TBlockParElEC; // @offset 0x1C
    SortedEntryCount: Integer; // @offset 0x20

    constructor Create; // @addr 0x846940
    destructor Destroy; override; // @addr 0x846988
    procedure Clear; // @addr 0x8469C4 @note "Preserves UseSortedIndex."
    procedure CopyFrom(Source: TBlockParEC); // @addr 0x846A40
    function AddEntry: TBlockParElEC; // @addr 0x846ACC @note "Caller must maintain kind counts and the sorted index."
    procedure DeleteEntry(Entry: TBlockParElEC); // @addr 0x846B44 @note "Frees Entry but leaves its sorted-index entry intact."
    function FindEntryByPath(const Path: WideString; RaiseIfMissing: Boolean): TBlockParElEC; // @addr 0x846DB0 @note "Dot, slash and backslash separate components; a :number suffix selects a zero-based occurrence."
    function FindSortedNameRangeStartIndex(const EntryName: WideString): Integer; // @addr 0x84704C @note "Returns -1 when absent."
    function PrepareSortedInsertion(Entry: TBlockParElEC): Integer; // @addr 0x847100 @note "Also updates duplicate-group metadata."
    procedure InsertIntoSortedIndex(Entry: TBlockParElEC); // @addr 0x847234
    procedure RemoveFromSortedIndex(Entry: TBlockParElEC); // @addr 0x8472DC

    // Params are string entries; blocks have separate accessors. ByPath traverses
    // subtrees, while ParamName addresses a direct child. OrMarker returns
    // '[name]' or '[path]' when missing; ordinary getters raise instead.
    function GetParamByPath(const Path: WideString): WideString; // @addr 0x8473FC
    function GetParamByPathOrMarker(const Path: WideString): WideString; // @addr 0x8474C8 @note "Returns a marker containing Path when lookup fails, including caught exceptions."
    function CountParamsByPath(const Path: WideString): Integer; // @addr 0x847580 @note "Creates missing intermediate subtrees."
    function AddParam(const ParamName, ParamValue: WideString): TBlockParElEC; // @addr 0x847650
    procedure SetParam(const ParamName, ParamValue: WideString); // @addr 0x8476B8 @note "Only the first match is affected; raises when absent."
    procedure SetOrAddParam(const ParamName, ParamValue: WideString); // @addr 0x8477BC
    procedure DeleteParam(const ParamName: WideString); // @addr 0x847824 @note "Only the first match is affected; raises when absent."
    procedure DeleteChildBlock(const BlockName: WideString); // @addr 0x847938 @note "Only the first match is affected; raises when absent."
    function GetParam(const ParamName: WideString): WideString; // @addr 0x847A50
    function GetParamOrMarker(const ParamName: WideString): WideString; // @addr 0x847B54
    function GetParamCount: Integer; // @addr 0x847BD8
    function CountParams(const ParamName: WideString): Integer; // @addr 0x847BF4
    // GetParamValue/GetParamName take zero-based string-entry indexes.
    // Kind-specific indexes use sorted order only when all entries have that kind.
    function GetParamValue(Index: Integer): WideString; // @addr 0x847CB8
    function GetParamName(Index: Integer): WideString; // @addr 0x847DC8
    function AddBlockByPath(const Path: WideString): TBlockParEC; // @addr 0x847EDC @note "Nested insertion updates the receiver's index and block count."
    function GetBlockByPath(const Path: WideString): TBlockParEC; // @addr 0x847FE0 @note "Raises when Path is absent or is not a block."
    function FindBlockByPath(const Path: WideString): TBlockParEC; // @addr 0x8480C8
    function GetOrAddBlockByPath(const Path: WideString): TBlockParEC; // @addr 0x84810C
    function AddChildBlock(const BlockName: WideString): TBlockParEC; // @addr 0x848144
    function GetBlock(const BlockName: WideString): TBlockParEC; // @addr 0x84819C @note "Raises when absent."
    function FindBlock(const BlockName: WideString): TBlockParEC; // @addr 0x84829C
    function GetBlockCount: Integer; // @addr 0x8482F8
    function CountBlocks(const BlockName: WideString): Integer; // @addr 0x848314
    function GetBlockByIndex(Index: Integer): TBlockParEC; // @addr 0x8483D8
    function GetBlockNameByIndex(Index: Integer): WideString; // @addr 0x8484DC

    function GetEntryCount: Integer; // @addr 0x8485F0
    // Mixed-kind indexes use the sorted array only when it covers every entry.
    function GetEntryKindByIndex(Index: Integer): TBlockParKind; // @addr 0x84860C
    function GetEntryBlockByIndex(Index: Integer): TBlockParEC; // @addr 0x848708
    function GetEntryStringByIndex(Index: Integer): WideString; // @addr 0x848880
    function GetEntryNameByIndex(Index: Integer): WideString; // @addr 0x8489FC

    // Text writers append at Dest.Position. Sorted applies only with UseSortedIndex.
    procedure WriteWideText(Dest: TBufEC; Indent: Integer; Sorted: Boolean); // @addr 0x848DF8 @note "Uses four spaces per indentation level and CRLF line endings."
    procedure WriteAnsiText(Dest: TBufEC; Indent: Integer; Sorted: Boolean); // @addr 0x84914C @note "Uses tabs for indentation and CRLF line endings."
    procedure WriteTextBuffer(Dest: TBufEC; AnsiText, Sorted: Boolean); // @addr 0x8491C8 @note "Wide output starts with a UTF-16LE BOM."
    procedure SaveTextFile(FileName: PWideChar; AnsiText, Sorted: Boolean); // @addr 0x849214 @note "Creates or truncates FileName."
    // Text parsers append entries; they do not clear the existing tree.
    procedure ParseTextBuffer(Buf: TBufEC; const InitialText: WideString; AnsiText, PreserveComments: Boolean); // @addr 0x8492F8
    procedure LoadFromTextBufferWithEncodingProbe(Buf: TBufEC; PreserveComments: Boolean); // @addr 0x849714 @note "Does nothing with at most two bytes remaining; otherwise consumes a UTF-16LE BOM or parses ANSI text."
    procedure LoadFromTextFileWithEncodingProbe(FileName: PWideChar; PreserveComments: Boolean); // @addr 0x849780
    procedure MergeFrom(Source: TBlockParEC); // @addr 0x8497E8 @note "Replaces all same-name string parameters; matches duplicate child blocks by occurrence and merges them recursively."
    function ConcatenateValues: WideString; // @addr 0x8499BC @note "Omits names and wraps child values in braces; text-only entries are not accepted."
    procedure LoadFromDecodedBuffer(Buf: TBufEC); // @addr 0x849A9C @note "Replaces existing contents; trusts sorted-group metadata from the stream."
    procedure LoadFromEncryptedDatFile(const FileName: WideString); // @addr 0x849C34 @note "An inner checksum mismatch leaves the tree unchanged."
  end;

const
  BlockDatSeedKey: Cardinal = $B1E8C689; // @addr $88271C
  BlockDatCrcKey1: Cardinal = $7DB6C99D; // @addr $882720
  BlockDatCrcKey2: Cardinal = $C83FCBF3; // @addr $882724

implementation

uses EC_File, aMyFunction, BlockParException, GR_Main, EC_Str, GlobalsV, SysUtils, Windows;

{ @routine $846794 TBlockParElEC_Create }
constructor TBlockParElEC.Create;
begin inherited Create end;
{ @end $846794 }

{ @routine $8467D8 TBlockParElEC_Destroy }
destructor TBlockParElEC.Destroy;
begin Clear; inherited Destroy end;
{ @end $8467D8 }

{ @routine $846814 TBlockParElEC_Clear }
procedure TBlockParElEC.Clear;
begin
  if ChildBlock <> nil then
  begin ChildBlock.Free; ChildBlock := nil end;
  ItemType := bpkText;
  Name := '';
  StringValue := '';
  Comment := '';
end;
{ @end $846814 }

{ @routine $846864 TBlockParElEC_MakeChildBlock }
procedure TBlockParElEC.MakeChildBlock;
begin
  if ChildBlock <> nil then
  begin ChildBlock.Free; ChildBlock := nil end;
  ChildBlock := TBlockParEC.Create;
  ItemType := bpkBlock;
  StringValue := '';
end;
{ @end $846864 }

{ @routine $8468B4 TBlockParElEC_CopyFrom }
procedure TBlockParElEC.CopyFrom(Source: TBlockParElEC);
begin
  Clear;
  ItemType := Source.ItemType;
  Name := Source.Name;
  StringValue := Source.StringValue;
  Comment := Source.Comment;
  ChildBlock := nil;
  if Source.ChildBlock <> nil then
  begin
    ChildBlock := TBlockParEC.Create;
    ChildBlock.CopyFrom(Source.ChildBlock);
  end;
end;
{ @end $8468B4 }

{ @routine $846940 TBlockParEC_Create }
constructor TBlockParEC.Create;
begin inherited Create; UseSortedIndex := True end;
{ @end $846940 }

{ @routine $846988 TBlockParEC_Destroy }
destructor TBlockParEC.Destroy;
begin Clear; inherited Destroy end;
{ @end $846988 }

{ @routine $8469C4 TBlockParEC_Clear }
procedure TBlockParEC.Clear;
var Entry, Removed: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    Removed := Entry;
    Entry := Entry.Next;
    Removed.Free;
  end;
  FirstEntry := nil;
  LastEntry := nil;
  EntryCount := 0;
  StringParamCount := 0;
  ChildBlockCount := 0;
  SortedEntries := nil;
  SortedEntryCount := 0;
end;
{ @end $8469C4 }

{ @routine $846A40 TBlockParEC_CopyFrom }
procedure TBlockParEC.CopyFrom(Source: TBlockParEC);
var Entry, Added: TBlockParElEC;
begin
  Clear;
  UseSortedIndex := Source.UseSortedIndex;
  Entry := Source.FirstEntry;
  while Entry <> nil do
  begin
    Added := AddEntry;
    Added.CopyFrom(Entry);
    if UseSortedIndex then InsertIntoSortedIndex(Added);
    if Entry.ItemType = bpkString then Inc(StringParamCount)
    else if Entry.ItemType = bpkBlock then Inc(ChildBlockCount);
    Entry := Entry.Next;
  end;
end;
{ @end $846A40 }

{ @routine $846ACC TBlockParEC_AddEntry }
function TBlockParEC.AddEntry: TBlockParElEC;
var Entry: TBlockParElEC;
begin
  Entry := TBlockParElEC.Create;
  Entry.OwnerBlock := Self;
  if LastEntry <> nil then LastEntry.Next := Entry;
  Entry.Prev := LastEntry;
  Entry.Next := nil;
  LastEntry := Entry;
  if FirstEntry = nil then FirstEntry := Entry;
  Inc(EntryCount);
  Result := Entry;
end;
{ @end $846ACC }

{ @routine $846B44 TBlockParEC_DeleteEntry }
procedure TBlockParEC.DeleteEntry(Entry: TBlockParElEC);
begin
  if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
  if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
  if LastEntry = Entry then LastEntry := Entry.Prev;
  if FirstEntry = Entry then FirstEntry := Entry.Next;
  Dec(EntryCount);
  if Entry.ItemType = bpkString then Dec(StringParamCount)
  else if Entry.ItemType = bpkBlock then Dec(ChildBlockCount);
  Entry.Free;
end;
{ @end $846B44 }

{ @routine $846DB0 TBlockParEC_FindEntryByPath }
function TBlockParEC.FindEntryByPath(const Path: WideString; RaiseIfMissing: Boolean): TBlockParElEC;
var
  Cursor, PathLength, Start, PartLength, Occurrence: Integer;
  Index, Seen: Integer;
  Entry: TBlockParElEC;
  Block: TBlockParEC;

  // @nested $846BE0 NextBlockPathComponent
  function NextBlockPathComponent: Boolean; // @addr 0x846BE0 @ida "bool __cdecl $name(void *ParentFrame);" @note "Nested helper of TBlockParEC.FindEntryByPath."
  var
    Ch: WideChar;
    i: Integer;
  begin
    if Cursor >= PathLength then
    begin Result := False; Exit end;
    Start := Cursor;
    i := Start;
    while PathLength > i do
    begin
      Ch := Path[i + 1];
      if (Ch = '.') or (Ch = '/') or (Ch = '\') then Break;
      Inc(i);
    end;
    PartLength := i - Start;
    Cursor := i + 1;
    Result := True;
  end;

  // @nested $846C74 ParseBlockPathOccurrence
  procedure ParseBlockPathOccurrence; // @addr 0x846C74 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested helper of TBlockParEC.FindEntryByPath."
  var i, Limit: Integer;
      Ch: WideChar;
  begin
    Occurrence := 0;
    i := Start;
    Limit := Start + PartLength;
    while i < Limit do
    begin
      if Path[i + 1] = ':' then
      begin
        PartLength := i - Start;
        Inc(i);
        while i < Limit do
        begin
          Ch := Path[i + 1];
          if (Ch >= '0') and (Ch <= '9') then Occurrence := Occurrence * 10 + (Ord(Ch) - Ord('0'));
          Inc(i);
        end;
        Break;
      end;
      Inc(i);
    end;
  end;

  // @nested $846D24 MatchBlockPathComponent
  function MatchBlockPathComponent(Name: WideString): Boolean; // @addr 0x846D24 @ida "bool __usercall $name@<al>(unsigned __int16 *Name@<eax>, void *ParentFrame);" @note "Nested helper of TBlockParEC.FindEntryByPath; native clones its value parameter."
  begin
    if Length(Name) <> PartLength then Result := False
    else Result := SysUtils.CompareMem(Pointer(PAnsiChar(PWideChar(Path)) + Start * SizeOf(WideChar)), PWideChar(Name), PartLength * 2);
  end;

begin
  PathLength := Length(Path);
  Cursor := 0;
  Block := Self;
  Entry := nil;
  while NextBlockPathComponent do
  begin
    ParseBlockPathOccurrence;
    if Block.UseSortedIndex then
    begin
      Entry := nil;
      Index := Block.FindSortedNameRangeStartIndex(Copy(Path, Start + 1, PartLength));
      if Index >= 0 then
      begin
        Entry := Block.SortedEntries[Index];
        if Occurrence <> 0 then
        begin
          if Occurrence < Entry.GroupCount then Entry := Block.SortedEntries[Index + Occurrence]
          else Entry := nil;
        end;
      end;
    end
    else
    begin
      Entry := Block.FirstEntry;
      Seen := 0;
      while (Seen <= Occurrence) and (Entry <> nil) do
      begin
        while Entry <> nil do
        begin
          if MatchBlockPathComponent(Entry.Name) then
          begin
            if Seen < Occurrence then Entry := Entry.Next;
            Break;
          end;
          Entry := Entry.Next;
        end;
        Inc(Seen);
      end;
    end;
    if Entry = nil then
    begin
      if RaiseIfMissing then raise EBlockPar.Create('GetEl. Path=' + Path, False);
      Result := nil;
      Exit;
    end;
    if Cursor >= PathLength then Break;
    if Entry.ItemType <> bpkBlock then
    begin
      if RaiseIfMissing then raise EBlockPar.Create('GetEl. Path=' + Path, False);
      Result := nil;
      Exit;
    end;
    Block := Entry.ChildBlock;
  end;
  if Entry = nil then
  begin
    if RaiseIfMissing then raise EBlockPar.Create('GetEl. Path=' + Path, False);
    Result := nil;
    Exit;
  end;
  Result := Entry;
end;
{ @end $846DB0 }

{ @routine $84704C TBlockParEC_FindSortedNameRangeStartIndex }
function TBlockParEC.FindSortedNameRangeStartIndex(const EntryName: WideString): Integer;
var Low, High, Middle, Order: Integer;
    Entry: TBlockParElEC;
begin
  if SortedEntryCount < 1 then
  begin Result := -1; Exit end;
  Low := 0;
  High := SortedEntryCount - 1;
  repeat
    Middle := (High - Low) div 2 + Low;
    Entry := SortedEntries[Middle];
    Order := CompareWideChars(PWideChar(EntryName), PWideChar(Entry.Name));
    if Order = 0 then
    begin Result := Middle - Entry.GroupIndex; Exit end;
    if Order < 0 then High := Middle - 1 else Low := Middle + 1;
  until High < Low;
  Result := -1;
end;
{ @end $84704C }

{ @routine $847100 TBlockParEC_PrepareSortedInsertion }
function TBlockParEC.PrepareSortedInsertion(Entry: TBlockParElEC): Integer;
var Low, High, Middle, Order: Integer;
    Existing: TBlockParElEC;
begin
  if SortedEntryCount <= 0 then
  begin
    Result := 0;
    Entry.GroupIndex := 0;
    Entry.GroupCount := 1;
    Exit;
  end;
  Low := 0;
  High := SortedEntryCount - 1;
  repeat
    Middle := (High - Low) shr 1 + Low;
    Existing := SortedEntries[Middle];
    Order := CompareWideChars(PWideChar(Entry.Name), PWideChar(Existing.Name));
    if Order = 0 then Order := Integer(Entry.ItemType) - Integer(Existing.ItemType);
    if Order = 0 then
    begin
      if Existing.GroupIndex <> 0 then
      begin
        Result := Middle - Existing.GroupIndex;
        Existing := SortedEntries[Result];
      end
      else Result := Middle;
      Entry.GroupIndex := Existing.GroupCount;
      Result := Result + Existing.GroupCount;
      Inc(Existing.GroupCount);
      Exit;
    end;
    if Order < 0 then High := Middle - 1 else Low := Middle + 1;
  until High < Low;
  if Order < 0 then Result := Middle else Result := Middle + 1;
  Entry.GroupIndex := 0;
  Entry.GroupCount := 1;
end;
{ @end $847100 }

{ @routine $847234 TBlockParEC_InsertIntoSortedIndex }
procedure TBlockParEC.InsertIntoSortedIndex(Entry: TBlockParElEC);
var Index: Integer;
begin
  SetLength(SortedEntries, SortedEntryCount + 1);
  Index := PrepareSortedInsertion(Entry);
  if Index >= SortedEntryCount then
  begin
    SortedEntries[SortedEntryCount] := Entry;
    Inc(SortedEntryCount);
    Exit;
  end;
  Windows.MoveMemory(@SortedEntries[Index + 1], @SortedEntries[Index], (SortedEntryCount - Index) * SizeOf(SortedEntries[0]));
  SortedEntries[Index] := Entry;
  Inc(SortedEntryCount);
end;
{ @end $847234 }

{ @routine $8472DC TBlockParEC_RemoveFromSortedIndex }
procedure TBlockParEC.RemoveFromSortedIndex(Entry: TBlockParElEC);
var i, Index: Integer;
    Head: TBlockParElEC;
begin
  Index := 0;
  while Index < SortedEntryCount do
  begin
    if SortedEntries[Index] = Entry then
    begin
      Head := SortedEntries[Index - Entry.GroupIndex];
      for i := Index + 1 to Index - Entry.GroupIndex + Head.GroupCount - 1 do
        Dec(SortedEntries[i].GroupIndex);
      Dec(Head.GroupCount);
      if Entry.GroupIndex = 0 then
        if Head.GroupCount > 0 then SortedEntries[Index + 1].GroupCount := Entry.GroupCount;
      if Index < SortedEntryCount - 1 then
        Windows.MoveMemory(@SortedEntries[Index], @SortedEntries[Index + 1], (SortedEntryCount - Index - 1) * SizeOf(SortedEntries[0]));
      Dec(SortedEntryCount);
      SetLength(SortedEntries, SortedEntryCount);
      Exit;
    end;
    Inc(Index);
  end;
end;
{ @end $8472DC }

{ @routine $8473FC TBlockParEC_GetParamByPath }
function TBlockParEC.GetParamByPath(const Path: WideString): WideString;
var Entry: TBlockParElEC;
begin
  Entry := FindEntryByPath(Path, True);
  if Entry.ItemType <> bpkString then raise Exception.Create('Par_Get. Path=' + Path);
  Result := Entry.StringValue;
end;
{ @end $8473FC }

{ @routine $8474C8 TBlockParEC_GetParamByPathOrMarker }
function TBlockParEC.GetParamByPathOrMarker(const Path: WideString): WideString;
var Entry: TBlockParElEC;
begin
  try
    Entry := FindEntryByPath(Path, True);
  except
    Result := '[' + Path + ']';
    Exit;
  end;
  if (Entry <> nil) and (Entry.ItemType = bpkString) then Result := Entry.StringValue
  else Result := '[' + Path + ']';
end;
{ @end $8474C8 }

{ @routine $847580 TBlockParEC_CountParamsByPath }
function TBlockParEC.CountParamsByPath(const Path: WideString): Integer;
var Count: Integer;
    Part: WideString;
    Block: TBlockParEC;
begin
  Count := CountDelimitedPartsW(Path, './\');
  if Count > 1 then
  begin
    Block := GetOrAddBlockByPath(ExtractDelimitedRangeW(Path, 0, Count - 2, './\'));
    Part := ExtractDelimitedPartW(Path, Count - 1, './\');
  end
  else
  begin
    Part := Path;
    Block := Self;
  end;
  Result := Block.CountParams(Part);
end;
{ @end $847580 }

{ @routine $847650 TBlockParEC_AddParam }
function TBlockParEC.AddParam(const ParamName, ParamValue: WideString): TBlockParElEC;
var Entry: TBlockParElEC;
begin
  Entry := AddEntry;
  Entry.ItemType := bpkString;
  Entry.Name := ParamName;
  Entry.StringValue := ParamValue;
  if UseSortedIndex then InsertIntoSortedIndex(Entry);
  Inc(StringParamCount);
  Result := Entry;
end;
{ @end $847650 }

{ @routine $8476B8 TBlockParEC_SetParam }
procedure TBlockParEC.SetParam(const ParamName, ParamValue: WideString);
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = ParamName) and (Entry.ItemType = bpkString) then
    begin
      Entry.StringValue := ParamValue;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  raise Exception.Create('TBlockParEC.Par_Set. name=' + ParamName);
end;
{ @end $8476B8 }

{ @routine $8477BC TBlockParEC_SetOrAddParam }
procedure TBlockParEC.SetOrAddParam(const ParamName, ParamValue: WideString);
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = ParamName) and (Entry.ItemType = bpkString) then
    begin
      Entry.StringValue := ParamValue;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  AddParam(ParamName, ParamValue);
end;
{ @end $8477BC }

{ @routine $847824 TBlockParEC_DeleteParam }
procedure TBlockParEC.DeleteParam(const ParamName: WideString);
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = ParamName) and (Entry.ItemType = bpkString) then
    begin
      if UseSortedIndex then RemoveFromSortedIndex(Entry);
      DeleteEntry(Entry);
      Exit;
    end;
    Entry := Entry.Next;
  end;
  raise Exception.Create('TBlockParEC.Par_Delete. name=' + ParamName);
end;
{ @end $847824 }

{ @routine $847938 TBlockParEC_DeleteChildBlock }
procedure TBlockParEC.DeleteChildBlock(const BlockName: WideString);
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = BlockName) and (Entry.ItemType = bpkBlock) then
    begin
      if UseSortedIndex then RemoveFromSortedIndex(Entry);
      DeleteEntry(Entry);
      Exit;
    end;
    Entry := Entry.Next;
  end;
  raise Exception.Create('TBlockParEC.Block_Delete. name=' + BlockName);
end;
{ @end $847938 }

{ @routine $847A50 TBlockParEC_GetParam }
function TBlockParEC.GetParam(const ParamName: WideString): WideString;
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = ParamName) and (Entry.ItemType = bpkString) then
    begin
      Result := Entry.StringValue;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  raise Exception.Create('TBlockParEC.Par_Get. name=' + ParamName);
end;
{ @end $847A50 }

{ @routine $847B54 TBlockParEC_GetParamOrMarker }
function TBlockParEC.GetParamOrMarker(const ParamName: WideString): WideString;
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = ParamName) and (Entry.ItemType = bpkString) then
    begin
      Result := Entry.StringValue;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  Result := '[' + ParamName + ']';
end;
{ @end $847B54 }

{ @routine $847BD8 TBlockParEC_GetParamCount }
function TBlockParEC.GetParamCount: Integer;
begin Result := StringParamCount end;
{ @end $847BD8 }

{ @routine $847BF4 TBlockParEC_CountParams }
function TBlockParEC.CountParams(const ParamName: WideString): Integer;
var Entry: TBlockParElEC;
    Count, Index, Limit: Integer;
begin
  if UseSortedIndex then
  begin
    Index := FindSortedNameRangeStartIndex(ParamName);
    Result := 0;
    if Index >= 0 then
    begin
      Limit := SortedEntries[Index].GroupCount + Index;
      while Index < Limit do
      begin
        Entry := SortedEntries[Index];
        if Entry.ItemType = bpkString then Inc(Result);
        Inc(Index);
      end;
    end;
  end
  else
  begin
    Entry := FirstEntry;
    Count := 0;
    while Entry <> nil do
    begin
      if (Entry.ItemType = bpkString) and (Entry.Name = ParamName) then Inc(Count);
      Entry := Entry.Next;
    end;
    Result := Count;
  end;
end;
{ @end $847BF4 }

{ @routine $847CB8 TBlockParEC_GetParamValue }
function TBlockParEC.GetParamValue(Index: Integer): WideString;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = StringParamCount) then Result := SortedEntries[Index].StringValue
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Entry.ItemType = bpkString then
      begin
        if Index = 0 then
        begin Result := Entry.StringValue; Exit end;
        Dec(Index);
      end;
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.Par_Get. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $847CB8 }

{ @routine $847DC8 TBlockParEC_GetParamName }
function TBlockParEC.GetParamName(Index: Integer): WideString;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = StringParamCount) then Result := SortedEntries[Index].Name
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Entry.ItemType = bpkString then
      begin
        if Index = 0 then
        begin Result := Entry.Name; Exit end;
        Dec(Index);
      end;
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.Par_GetName. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $847DC8 }

{ @routine $847EDC TBlockParEC_AddBlockByPath }
function TBlockParEC.AddBlockByPath(const Path: WideString): TBlockParEC;
var Count: Integer;
    Part: WideString;
    Entry: TBlockParElEC;
    Block: TBlockParEC;
begin
  Count := CountDelimitedPartsW(Path, './\');
  if Count > 1 then
  begin
    Block := GetOrAddBlockByPath(ExtractDelimitedRangeW(Path, 0, Count - 2, './\'));
    Part := ExtractDelimitedPartW(Path, Count - 1, './\');
  end
  else
  begin
    Part := Path;
    Block := Self;
  end;
  Entry := Block.AddEntry;
  Entry.MakeChildBlock;
  Entry.Name := Part;
  if UseSortedIndex then InsertIntoSortedIndex(Entry);
  Inc(ChildBlockCount);
  Result := Entry.ChildBlock;
end;
{ @end $847EDC }

{ @routine $847FE0 TBlockParEC_GetBlockByPath }
function TBlockParEC.GetBlockByPath(const Path: WideString): TBlockParEC;
var Entry: TBlockParElEC;
begin
  Entry := FindEntryByPath(Path, True);
  if Entry.ItemType <> bpkBlock then raise Exception.Create('TBlockParEC.BlockPath_Get. Path=' + Path);
  Result := Entry.ChildBlock;
end;
{ @end $847FE0 }

{ @routine $8480C8 TBlockParEC_FindBlockByPath }
function TBlockParEC.FindBlockByPath(const Path: WideString): TBlockParEC;
var Entry: TBlockParElEC;
begin
  Entry := FindEntryByPath(Path, False);
  if (Entry = nil) or (Entry.ItemType <> bpkBlock) then
  begin Result := nil; Exit end;
  Result := Entry.ChildBlock;
end;
{ @end $8480C8 }

{ @routine $84810C TBlockParEC_GetOrAddBlockByPath }
function TBlockParEC.GetOrAddBlockByPath(const Path: WideString): TBlockParEC;
begin
  Result := FindBlockByPath(Path);
  if Result = nil then Result := AddBlockByPath(Path);
end;
{ @end $84810C }

{ @routine $848144 TBlockParEC_AddChildBlock }
function TBlockParEC.AddChildBlock(const BlockName: WideString): TBlockParEC;
var Entry: TBlockParElEC;
begin
  Entry := AddEntry;
  Entry.MakeChildBlock;
  Entry.Name := BlockName;
  if UseSortedIndex then InsertIntoSortedIndex(Entry);
  Inc(ChildBlockCount);
  Result := Entry.ChildBlock;
end;
{ @end $848144 }

{ @routine $84819C TBlockParEC_GetBlock }
function TBlockParEC.GetBlock(const BlockName: WideString): TBlockParEC;
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = BlockName) and (Entry.ItemType = bpkBlock) then
    begin
      Result := Entry.ChildBlock;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  raise Exception.Create('TBlockParEC.Block_Get. name=' + BlockName);
end;
{ @end $84819C }

{ @routine $84829C TBlockParEC_FindBlock }
function TBlockParEC.FindBlock(const BlockName: WideString): TBlockParEC;
var Entry: TBlockParElEC;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if (Entry.Name = BlockName) and (Entry.ItemType = bpkBlock) then
    begin
      Result := Entry.ChildBlock;
      Exit;
    end;
    Entry := Entry.Next;
  end;
  Result := nil;
end;
{ @end $84829C }

{ @routine $8482F8 TBlockParEC_GetBlockCount }
function TBlockParEC.GetBlockCount: Integer;
begin Result := ChildBlockCount end;
{ @end $8482F8 }

{ @routine $848314 TBlockParEC_CountBlocks }
function TBlockParEC.CountBlocks(const BlockName: WideString): Integer;
var Entry: TBlockParElEC;
    Count, Index, Limit: Integer;
begin
  if UseSortedIndex then
  begin
    Index := FindSortedNameRangeStartIndex(BlockName);
    Result := 0;
    if Index >= 0 then
    begin
      Limit := SortedEntries[Index].GroupCount + Index;
      while Index < Limit do
      begin
        Entry := SortedEntries[Index];
        if Entry.ItemType = bpkBlock then Inc(Result);
        Inc(Index);
      end;
    end;
  end
  else
  begin
    Entry := FirstEntry;
    Count := 0;
    while Entry <> nil do
    begin
      if (Entry.ItemType = bpkBlock) and (Entry.Name = BlockName) then Inc(Count);
      Entry := Entry.Next;
    end;
    Result := Count;
  end;
end;
{ @end $848314 }

{ @routine $8483D8 TBlockParEC_GetBlockByIndex }
function TBlockParEC.GetBlockByIndex(Index: Integer): TBlockParEC;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = ChildBlockCount) then Result := SortedEntries[Index].ChildBlock
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Entry.ItemType = bpkBlock then
      begin
        if Index = 0 then
        begin Result := Entry.ChildBlock; Exit end;
        Dec(Index);
      end;
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.Block_Get. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $8483D8 }

{ @routine $8484DC TBlockParEC_GetBlockNameByIndex }
function TBlockParEC.GetBlockNameByIndex(Index: Integer): WideString;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = ChildBlockCount) then Result := SortedEntries[Index].Name
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Entry.ItemType = bpkBlock then
      begin
        if Index = 0 then
        begin Result := Entry.Name; Exit end;
        Dec(Index);
      end;
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.Block_GetName. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $8484DC }

{ @routine $8485F0 TBlockParEC_GetEntryCount }
function TBlockParEC.GetEntryCount: Integer;
begin Result := EntryCount end;
{ @end $8485F0 }

{ @routine $84860C TBlockParEC_GetEntryKindByIndex }
function TBlockParEC.GetEntryKindByIndex(Index: Integer): TBlockParKind;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = SortedEntryCount) then
  begin
    Result := SortedEntries[Index].ItemType;
  end
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Index = 0 then
      begin

        Result := Entry.ItemType;
        Exit;
      end;
      Dec(Index);
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.All_GetTip. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $84860C }

{ @routine $848708 TBlockParEC_GetEntryBlockByIndex }
function TBlockParEC.GetEntryBlockByIndex(Index: Integer): TBlockParEC;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = SortedEntryCount) then
  begin
    Entry := SortedEntries[Index];
    if Entry.ItemType <> bpkBlock then raise Exception.Create('TBlockParEC.All_GetBlock. Error tip.');
    Result := Entry.ChildBlock;
  end
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Index = 0 then
      begin
        if Entry.ItemType <> bpkBlock then raise Exception.Create('TBlockParEC.All_GetBlock. Error tip.');
        Result := Entry.ChildBlock;
        Exit;
      end;
      Dec(Index);
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.All_GetBlock. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $848708 }

{ @routine $848880 TBlockParEC_GetEntryStringByIndex }
function TBlockParEC.GetEntryStringByIndex(Index: Integer): WideString;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = SortedEntryCount) then
  begin
    Entry := SortedEntries[Index];
    if Entry.ItemType <> bpkString then raise Exception.Create('TBlockParEC.All_GetPar. Error tip.');
    Result := Entry.StringValue;
  end
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Index = 0 then
      begin
        if Entry.ItemType <> bpkString then raise Exception.Create('TBlockParEC.All_GetPar. Error tip.');
        Result := Entry.StringValue;
        Exit;
      end;
      Dec(Index);
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.All_GetPar. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $848880 }

{ @routine $8489FC TBlockParEC_GetEntryNameByIndex }
function TBlockParEC.GetEntryNameByIndex(Index: Integer): WideString;
var Entry: TBlockParElEC;
begin
  if UseSortedIndex and (EntryCount = SortedEntryCount) then
  begin
    Entry := SortedEntries[Index];
    if (Entry.ItemType <> bpkString) and (Entry.ItemType <> bpkBlock) then raise Exception.Create('TBlockParEC.All_GetName. Error tip.');
    Result := Entry.Name;
  end
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Index = 0 then
      begin
        if (Entry.ItemType <> bpkString) and (Entry.ItemType <> bpkBlock) then raise Exception.Create('TBlockParEC.All_GetName. Error tip.');
        Result := Entry.Name;
        Exit;
      end;
      Dec(Index);
      Entry := Entry.Next;
    end;
    raise Exception.Create('TBlockParEC.All_GetName. no=' + SysUtils.IntToStr(Index));
  end;
end;
{ @end $8489FC }

{ @routine $848DF8 TBlockParEC_WriteWideText }
procedure TBlockParEC.WriteWideText(Dest: TBufEC; Indent: Integer; Sorted: Boolean);
var Entry: TBlockParElEC;
    i: Integer;
  // @nested $848B8C WriteWideBlockEntry
  procedure WriteWideBlockEntry; // @addr 0x848B8C @ida "void __cdecl $name(void *ParentFrame);" @note "Nested helper of TBlockParEC.WriteWideText."
  var j: Integer;
  begin
    if Entry.ItemType = bpkText then
    begin
      if Entry.Comment <> '' then Dest.AddWideStringRaw(Entry.Comment);
      Dest.AddWord(13);
      Dest.AddWord(10);
    end
    else if Entry.ItemType = bpkString then
    begin
      for j := 1 to Indent * 4 do Dest.AddWord(Ord(' '));
      Dest.AddWideStringRaw(Entry.Name);
      Dest.AddWord(Ord('='));
      Dest.AddWideStringRaw(Entry.StringValue);
      if Entry.Comment <> '' then Dest.AddWideStringRaw(Entry.Comment);
      Dest.AddWord(13);
      Dest.AddWord(10);
    end
    else
    begin
      for j := 1 to Indent * 4 do Dest.AddWord(Ord(' '));
      Dest.AddWideStringRaw(Entry.Name);
      Dest.AddWord(Ord(' '));
      if UseSortedIndex then Dest.AddWord(Ord('^')) else Dest.AddWord(Ord('~'));
      Dest.AddWord(Ord('{'));
      Dest.AddWord(13);
      Dest.AddWord(10);
      Entry.ChildBlock.WriteWideText(Dest, Indent + 1, Sorted);
      for j := 1 to Indent * 4 do Dest.AddWord(Ord(' '));
      Dest.AddWord(Ord('}'));
      if Entry.Comment <> '' then Dest.AddWideStringRaw(Entry.Comment);
      Dest.AddWord(13);
      Dest.AddWord(10);
    end;
  end;
begin
  if UseSortedIndex and Sorted then
    for i := 1 to SortedEntryCount do
    begin
      Entry := SortedEntries[i - 1];
      WriteWideBlockEntry;
    end
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      WriteWideBlockEntry;
      Entry := Entry.Next;
    end;
  end;
end;
{ @end $848DF8 }

{ @routine $84914C TBlockParEC_WriteAnsiText }
procedure TBlockParEC.WriteAnsiText(Dest: TBufEC; Indent: Integer; Sorted: Boolean);
var Entry: TBlockParElEC;
    i: Integer;
  // @nested $848E74 WriteAnsiBlockEntry
  procedure WriteAnsiBlockEntry; // @addr 0x848E74 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested helper of TBlockParEC.WriteAnsiText."
  var j: Integer;
  begin
    if Entry.ItemType = bpkText then
    begin
      if Entry.Comment <> '' then Dest.AddAnsiStringRaw(WideCharToString(PWideChar(Entry.Comment)));
      Dest.AddByte(13);
      Dest.AddByte(10);
    end
    else if Entry.ItemType = bpkString then
    begin
      for j := 1 to Indent do Dest.AddByte(9);
      Dest.AddAnsiStringRaw(WideCharToString(PWideChar(Entry.Name)));
      Dest.AddByte(Ord('='));
      Dest.AddAnsiStringRaw(WideCharToString(PWideChar(Entry.StringValue)));
      if Entry.Comment <> '' then Dest.AddAnsiStringRaw(WideCharToString(PWideChar(Entry.Comment)));
      Dest.AddByte(13);
      Dest.AddByte(10);
    end
    else
    begin
      for j := 1 to Indent do Dest.AddByte(9);
      Dest.AddAnsiStringRaw(WideCharToString(PWideChar(Entry.Name)));
      Dest.AddByte(Ord(' '));
      if UseSortedIndex then Dest.AddByte(Ord('^')) else Dest.AddByte(Ord('~'));
      Dest.AddByte(Ord('{'));
      Dest.AddByte(13);
      Dest.AddByte(10);
      Entry.ChildBlock.WriteAnsiText(Dest, Indent + 1, Sorted);
      for j := 1 to Indent do Dest.AddByte(9);
      Dest.AddByte(Ord('}'));
      if Entry.Comment <> '' then Dest.AddAnsiStringRaw(WideCharToString(PWideChar(Entry.Comment)));
      Dest.AddByte(13);
      Dest.AddByte(10);
    end;
  end;
begin
  if UseSortedIndex and Sorted then
    for i := 1 to SortedEntryCount do
    begin
      Entry := SortedEntries[i - 1];
      WriteAnsiBlockEntry;
    end
  else
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      WriteAnsiBlockEntry;
      Entry := Entry.Next;
    end;
  end;
end;
{ @end $84914C }

{ @routine $8491C8 TBlockParEC_WriteTextBuffer }
procedure TBlockParEC.WriteTextBuffer(Dest: TBufEC; AnsiText, Sorted: Boolean);
begin
  if not AnsiText then
  begin
    Dest.AddWord($FEFF);
    WriteWideText(Dest, 0, Sorted);
  end
  else WriteAnsiText(Dest, 0, Sorted);
end;
{ @end $8491C8 }

{ @routine $849214 TBlockParEC_SaveTextFile }
procedure TBlockParEC.SaveTextFile(FileName: PWideChar; AnsiText, Sorted: Boolean);
var FileObj: TFileEC;
    Buf: TBufEC;
begin
  FileObj := TFileEC.Create;
  Buf := TBufEC.Create;
  try
    WriteTextBuffer(Buf, AnsiText, Sorted);
    FileObj.SetFileName(WideString(FileName));
    FileObj.CreateNew;
    FileObj.WriteBuffer(Buf.Data, Buf.DataSize);
    FileObj.ReleaseHandle;
  finally
    FileObj.Free;
    Buf.Free;
  end;
end;
{ @end $849214 }

{ @routine $8492F8 TBlockParEC_ParseTextBuffer }
procedure TBlockParEC.ParseTextBuffer(Buf: TBufEC; const InitialText: WideString; AnsiText, PreserveComments: Boolean);
var Text, Name, IncludeFile, Comment: WideString;
    Child: TBlockParEC;
    PartCount: Integer;
    Entry: TBlockParElEC;
    ChildSorted: Boolean;
begin
  Text := TrimWideString(InitialText);
  while not Buf.IsAtEnd do
  begin
    if Text = '' then
      if AnsiText then Text := TrimWideString(WideString(Buf.ReadAnsiTextLine))
      else Text := TrimWideString(Buf.ReadWideTextLine);
    Comment := ExtractLineCommentW(Text);
    Text := TrimWideString(RemoveLineCommentW(Text));
    PartCount := CountDelimitedPartsW(Text, '{');
    if PartCount > 1 then
    begin
      Name := TrimWideString(ExtractDelimitedPartW(Text, 0, '{'));
      if Name = '' then raise Exception.Create('TBlockParEC.LoadFromBuf_r. tstr=' + Text);
      ChildSorted := Name[Length(Name)] = '^';
      if ChildSorted then
      begin
        SetLength(Name, Length(Name) - 1);
        Name := TrimWideString(Name);
      end
      else
      begin
        ChildSorted := Name[Length(Name)] <> '~';
        if not ChildSorted then
        begin
          SetLength(Name, Length(Name) - 1);
          Name := TrimWideString(Name);
        end;
      end;
      IncludeFile := '';
      if CountDelimitedPartsW(Name, '=') = 2 then
      begin
        IncludeFile := TrimWideString(ExtractDelimitedPartW(Name, 1, '='));
        Name := TrimWideString(ExtractDelimitedPartW(Name, 0, '='));
      end;
      Child := AddChildBlock(Name);
      Child.UseSortedIndex := ChildSorted;
      Name := TrimWideString(ExtractDelimitedRangeW(Text, 1, PartCount - 1, '{'));
      Child.ParseTextBuffer(Buf, Name, AnsiText, PreserveComments);
      if IncludeFile <> '' then Child.LoadFromTextFileWithEncodingProbe(PWideChar(IncludeFile), False);
    end
    else
    begin
      if CountDelimitedPartsW(Text, '}') > 1 then Break;
      PartCount := CountDelimitedPartsW(Text, '=');
      if PartCount > 1 then
      begin
        Name := TrimWideString(ExtractDelimitedPartW(Text, 0, '='));
        IncludeFile := ExtractDelimitedRangeW(Text, 1, PartCount - 1, '=');
        if PreserveComments then AddParam(Name, IncludeFile).Comment := Comment
        else AddParam(Name, IncludeFile);
      end
      else if PreserveComments then
      begin
        Entry := AddEntry;
        Entry.ItemType := bpkText;
        Entry.Comment := Comment;
      end;
    end;
    Text := '';
  end;
end;
{ @end $8492F8 }

{ @routine $849714 TBlockParEC_LoadFromTextBufferWithEncodingProbe }
procedure TBlockParEC.LoadFromTextBufferWithEncodingProbe(Buf: TBufEC; PreserveComments: Boolean);
begin
  if Buf.DataSize - Buf.Position <= 2 then Exit;
  if Buf.GetWord <> $FEFF then
  begin
    Buf.SetPosition(Buf.Position - 2);
    ParseTextBuffer(Buf, '', True, PreserveComments);
  end
  else ParseTextBuffer(Buf, '', False, PreserveComments);
end;
{ @end $849714 }

{ @routine $849780 TBlockParEC_LoadFromTextFileWithEncodingProbe }
procedure TBlockParEC.LoadFromTextFileWithEncodingProbe(FileName: PWideChar; PreserveComments: Boolean);
var Buf: TBufEC;
begin
  Buf := TBufEC.Create;
  try
    Buf.LoadFromWideFilePath(FileName);
    LoadFromTextBufferWithEncodingProbe(Buf, PreserveComments);
  finally
    Buf.Free;
  end;
end;
{ @end $849780 }

{ @routine $8497E8 TBlockParEC_MergeFrom }
procedure TBlockParEC.MergeFrom(Source: TBlockParEC);
var Incoming, Removed, Cursor, Existing: TBlockParElEC;
    Child: TBlockParEC;
    Occurrence, Seen: Integer;
begin
  Incoming := Source.FirstEntry;
  while Incoming <> nil do
  begin
    if Incoming.ItemType <> bpkText then
      if Incoming.ItemType = bpkString then
      begin
        Cursor := FirstEntry;
        while Cursor <> nil do
        begin
          Removed := Cursor;
          Cursor := Cursor.Next;
          if (Removed.ItemType = Incoming.ItemType) and (Removed.Name = Incoming.Name) then
          begin
            if UseSortedIndex then RemoveFromSortedIndex(Removed);
            DeleteEntry(Removed);
          end;
        end;
      end
      else if Incoming.ItemType = bpkBlock then
      begin
        Occurrence := 0;
        Cursor := Source.FirstEntry;
        while Cursor <> Incoming do
        begin
          if (Cursor.ItemType = bpkBlock) and (Cursor.Name = Incoming.Name) then Inc(Occurrence);
          Cursor := Cursor.Next;
        end;
        Inc(Occurrence);
        Seen := 0;
        Existing := FirstEntry;
        while Existing <> nil do
        begin
          if (Existing.ItemType = bpkBlock) and (Existing.Name = Incoming.Name) then Inc(Seen);
          if Seen = Occurrence then Break;
          Existing := Existing.Next;
        end;
        if Seen = Occurrence then
        begin
          Child := Existing.ChildBlock;
          Child.MergeFrom(Incoming.ChildBlock);
        end
        else
        begin
          Child := AddChildBlock(Incoming.Name);
          Child.CopyFrom(Incoming.ChildBlock);
        end;
      end;
    Incoming := Incoming.Next;
  end;
  Incoming := Source.FirstEntry;
  while Incoming <> nil do
  begin
    if Incoming.ItemType = bpkString then AddParam(Incoming.Name, Incoming.StringValue);
    Incoming := Incoming.Next;
  end;
end;
{ @end $8497E8 }

{ @routine $8499BC TBlockParEC_ConcatenateValues }
function TBlockParEC.ConcatenateValues: WideString;
var i: Integer;
begin
  Result := '';
  for i := 0 to GetEntryCount - 1 do
    if GetEntryKindByIndex(i) = bpkBlock then
      Result := Result + '{' + GetEntryBlockByIndex(i).ConcatenateValues + '}'
    else Result := Result + GetEntryStringByIndex(i);
end;
{ @end $8499BC }

{ @routine $849A9C TBlockParEC_LoadFromDecodedBuffer }
procedure TBlockParEC.LoadFromDecodedBuffer(Buf: TBufEC);
var i, Count: Integer;
    Entry: TBlockParElEC;
begin
  Clear;
  UseSortedIndex := Buf.GetBoolean;
  Count := Buf.GetInt32;
  if UseSortedIndex then
  begin
    SortedEntryCount := Count;
    SetLength(SortedEntries, Count);
  end;
  for i := 0 to Count - 1 do
  begin
    Entry := AddEntry;
    if UseSortedIndex then
    begin
      Entry.GroupIndex := Buf.GetInt32;
      Entry.GroupCount := Buf.GetInt32;
    end;
    Entry.ItemType := TBlockParKind(Buf.GetByte);
    Entry.Name := Buf.ReadWideString;
    if Entry.ItemType = bpkString then
    begin
      Entry.StringValue := Buf.ReadWideString;
      Inc(StringParamCount);
      if UseSortedIndex then SortedEntries[i] := Entry;
    end
    else if Entry.ItemType = bpkBlock then
    begin
      Entry.MakeChildBlock;
      if UseSortedIndex then SortedEntries[i] := Entry;
      Inc(ChildBlockCount);
      Entry.ChildBlock.LoadFromDecodedBuffer(Buf);
    end;
  end;
end;
{ @end $849A9C }

{ @routine $849C34 TBlockParEC_LoadFromEncryptedDatFile }
procedure TBlockParEC.LoadFromEncryptedDatFile(const FileName: WideString);
var Buf: TBufEC;
    FileObj: TFileEC;
    Crc: Cardinal;
    Seed: Integer;
    ByteCount: Integer;
    ExpectedOuter, Position: Cardinal;
begin
  FileObj := TFileEC.Create;
  FileObj.SetFileName(WideString(PWideChar(FileName)));
  FileObj.AcquireReadHandle(False);
  Position := FileObj.GetPointer;
  FileObj.ReadBuffer(@ByteCount, SizeOf(ByteCount));
  FileObj.ReadBuffer(@ExpectedOuter, SizeOf(ExpectedOuter));
  ByteCount := ByteCount xor (BlockDatCrcKey1 xor BlockDatCrcKey2);
  if FileObj.GetSize - FileObj.GetPointer = Cardinal(ByteCount) then
  begin
    Buf := TBufEC.Create;
    Buf.SetSize(ByteCount + 4);
    Position := FileObj.GetPointer;
    FileObj.ReadBuffer(Pointer(PAnsiChar(Buf.Data) + 4), Buf.DataSize - 4);
    Crc := Buf.ComputeCrc32Range(4, Buf.DataSize) xor BlockDatCrcKey1;
    PCardinal(Buf.Data)^ := Crc;
    Crc := Buf.ComputeCrc32 xor BlockDatCrcKey2;
    Buf.Free;
    if Crc <> ExpectedOuter then GR_Main.CCInterface.SetResourceChecksumFailed(True);
  end
  else GR_Main.CCInterface.SetResourceChecksumFailed(True);
  FileObj.SetPointer(Position, FILE_BEGIN);
  ByteCount := FileObj.GetSize - FileObj.GetPointer;
  FileObj.ReadBuffer(@Crc, SizeOf(Crc));
  FileObj.ReadBuffer(@Seed, SizeOf(Seed));
  Seed := Seed xor BlockDatSeedKey;
  Buf := TBufEC.Create;
  Buf.SetSize(ByteCount - 4 - 4);
  FileObj.ReadBuffer(Buf.Data, Buf.DataSize);
  Buf.ApplyDatXorCipher(Seed);
  if Buf.ComputeCrc32 = Crc then
  begin
    Buf.ExpandZlibPayloadInPlace;
    Buf.SetPosition(0);
    LoadFromDecodedBuffer(Buf);
  end;
  Buf.Free;
  FileObj.Free;
end;
{ @end $849C34 }

end.
