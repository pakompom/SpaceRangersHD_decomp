unit fFilmFile;

interface

uses aEFilm, EC_Buf, EC_Struct, SyncObjs;

type
  PFilmHistoryEntry = ^TFilmHistoryEntry;
  TFilmHistoryEntry = record // @size 0x10
    Prev: PFilmHistoryEntry; // @offset 0x00
    Next: PFilmHistoryEntry; // @offset 0x04
    Turn: Integer; // @offset 0x08
    Buffer: TBufEC; // @offset 0x0C  Owned serialized TEFilm, excluding Turn.
  end;

  TFilmFile = class(TObjectEx) // @size 0x10
  public
    FirstEntry: PFilmHistoryEntry; // @offset 0x04
    LastEntry: PFilmHistoryEntry; // @offset 0x08
    Lock: TCriticalSection; // @offset 0x0C

    constructor Create; // @addr 0x00696258
    destructor Destroy; override; // @addr 0x0069629C
    procedure Clear; // @addr 0x006962DC
    function AppendEntry: PFilmHistoryEntry; // @addr 0x00696304 @note "Caller holds Lock. Appends a zeroed entry owned by this history."
    procedure RemoveEntry(Entry: PFilmHistoryEntry); // @addr 0x00696334 @note "Caller holds Lock. Unlinks Entry and frees its buffer and storage."
    function GetCount: Integer; // @addr 0x00696380
    function GetEntry(Index: Integer): PFilmHistoryEntry; // @addr 0x006963AC @note "Zero-based insertion order. Returns a borrowed entry after releasing Lock; raises for an invalid index."
    procedure AddFilm(Film: TEFilm); // @addr 0x00696424 @note "Copies Film into a new buffer. Evicts entries with the lowest Turn until below FilmHistoryLimit, which must be positive."
    procedure DeleteEntry(Entry: PFilmHistoryEntry); // @addr 0x006964FC @note "Locks and removes an entry belonging to this history."
    procedure LoadFilm(Entry: PFilmHistoryEntry; Film: TEFilm); // @addr 0x00696520 @note "Replaces Film's contents but does not set Film.Turn; caller copies Entry.Turn. Rewinds the stored buffer afterward."
    procedure SaveEntryToBuffer(Entry: PFilmHistoryEntry; Buffer: TBufEC); // @addr 0x0069655C @note "Clears Buffer, then writes Turn and the length-prefixed film payload."
    procedure LoadEntryFromBuffer(Buffer: TBufEC); // @addr 0x00696594 @note "Appends without enforcing FilmHistoryLimit. Reads from the current buffer position."
  end;

implementation

uses EC_Mem, Globals, GlobalsV, SysUtils;


{ @routine $696258 TFilmFile_Create }
constructor TFilmFile.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;
{ @end $696258 }

{ @routine $69629C TFilmFile_Destroy }
destructor TFilmFile.Destroy;
begin
  Clear;
  if Lock <> nil then
  begin
    Lock.Free;
    Lock := nil;
  end;
  inherited Destroy;
end;
{ @end $69629C }

{ @routine $6962DC TFilmFile_Clear }
procedure TFilmFile.Clear;
begin
  Lock.Enter;
  while FirstEntry <> nil do RemoveEntry(LastEntry);
  Lock.Leave;
end;
{ @end $6962DC }

{ @routine $696304 TFilmFile_AppendEntry }
function TFilmFile.AppendEntry: PFilmHistoryEntry;
var Entry: PFilmHistoryEntry;
begin
  Entry := AllocClearEC(SizeOf(TFilmHistoryEntry));
  if LastEntry <> nil then LastEntry.Next := Entry;
  Entry.Prev := LastEntry;
  Entry.Next := nil;
  LastEntry := Entry;
  if FirstEntry = nil then FirstEntry := Entry;
  Result := Entry;
end;
{ @end $696304 }

{ @routine $696334 TFilmFile_RemoveEntry }
procedure TFilmFile.RemoveEntry(Entry: PFilmHistoryEntry);
begin
  if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
  if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
  if LastEntry = Entry then LastEntry := Entry.Prev;
  if FirstEntry = Entry then FirstEntry := Entry.Next;
  if Entry.Buffer <> nil then
  begin
    Entry.Buffer.Free;
    Entry.Buffer := nil;
  end;
  FreeEC(Entry);
end;
{ @end $696334 }

{ @routine $696380 TFilmFile_GetCount }
function TFilmFile.GetCount: Integer;
var
  Entry: PFilmHistoryEntry;
  Count: Integer;
begin
  Lock.Enter;
  Count := 0;
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    Inc(Count);
    Entry := Entry.Next;
  end;
  Result := Count;
  Lock.Leave;
end;
{ @end $696380 }

{ @routine $6963AC TFilmFile_GetEntry }
function TFilmFile.GetEntry(Index: Integer): PFilmHistoryEntry;
var Entry: PFilmHistoryEntry;
begin
  Lock.Enter;
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if Index = 0 then
    begin
      Result := Entry;
      Lock.Leave;
      Exit;
    end;
    Dec(Index);
    Entry := Entry.Next;
  end;
  Lock.Leave;
  raise Exception.Create('Error in TFilmFile.InfoGet');
end;
{ @end $6963AC }

{ @routine $696424 TFilmFile_AddFilm }
procedure TFilmFile.AddFilm(Film: TEFilm);
var
  Entry, Oldest: PFilmHistoryEntry;
  Turn: Integer;
  Buffer: TBufEC;
begin
  Lock.Enter;
  while GetCount >= FilmHistoryLimit do
  begin
    Oldest := FirstEntry;
    Turn := Oldest.Turn;
    Entry := Oldest.Next;
    while Entry <> nil do
    begin
      if Entry.Turn < Turn then
      begin
        Turn := Entry.Turn;
        Oldest := Entry;
      end;
      Entry := Entry.Next;
    end;
    DeleteEntry(Oldest);
  end;
  Buffer := TBufEC.Create;
  Film.SaveToBuffer(Buffer);
  Buffer.SetPosition(0);
  if Buffer.DataSize < 1 then
  begin
    Lock.Leave;
    raise Exception.Create('Error in TFilmFile.FilmAdd');
  end;
  Entry := AppendEntry;
  Entry.Turn := Film.Turn;
  Entry.Buffer := Buffer;
  Lock.Leave;
end;
{ @end $696424 }

{ @routine $6964FC TFilmFile_DeleteEntry }
procedure TFilmFile.DeleteEntry(Entry: PFilmHistoryEntry);
begin
  Lock.Enter;
  RemoveEntry(Entry);
  Lock.Leave;
end;
{ @end $6964FC }

{ @routine $696520 TFilmFile_LoadFilm }
procedure TFilmFile.LoadFilm(Entry: PFilmHistoryEntry; Film: TEFilm);
begin
  Lock.Enter;
  Entry.Buffer.SetPosition(0);
  Film.LoadFromBuffer(Entry.Buffer);
  Entry.Buffer.SetPosition(0);
  Lock.Leave;
end;
{ @end $696520 }

{ @routine $69655C TFilmFile_SaveEntryToBuffer }
procedure TFilmFile.SaveEntryToBuffer(Entry: PFilmHistoryEntry; Buffer: TBufEC);
begin
  Buffer.Clear;
  Lock.Enter;
  Buffer.AddIntegerValue(Entry.Turn);
  Buffer.AddBuffer(Entry.Buffer);
  Lock.Leave;
end;
{ @end $69655C }

{ @routine $696594 TFilmFile_LoadEntryFromBuffer }
procedure TFilmFile.LoadEntryFromBuffer(Buffer: TBufEC);
var Entry: PFilmHistoryEntry;
begin
  Lock.Enter;
  Entry := AppendEntry;
  Entry.Turn := Buffer.GetInt32;
  Entry.Buffer := TBufEC.Create;
  Buffer.ReadLengthPrefixedBuffer(Entry.Buffer);
  Lock.Leave;
end;
{ @end $696594 }

end.
