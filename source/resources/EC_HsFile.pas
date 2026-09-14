unit EC_HsFile;
// Unit bracket (inferred): .text 0x0082AB70..0x0082DE47; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses SyncObjs;

type
  THsFolderEC = class;
  PHsFolderEC = ^THsFolderEC;

  TPackEntryEC = packed record // @size 0x9E
    StoredSize: Cardinal; // @offset 0x00
    DataSize: Cardinal; // @offset 0x04
    UpperName: array[0..62] of AnsiChar; // @offset 0x08
    OriginalName: array[0..62] of AnsiChar; // @offset 0x47
    // Kind 2 is compressed data; kind 3 is a child folder.
    Kind: Integer; // @offset 0x86
    KindCopy: Integer; // @offset 0x8A
    Flags: Cardinal; // @offset 0x8E
    // The four bytes at +0x92 remain unresolved.
    TargetOffset: Cardinal; // @offset 0x96
    ChildFolder: THsFolderEC; // @offset 0x9A
  end;
  PPackEntryEC = ^TPackEntryEC;

  THsFolderEC = class(TObject) // @size 0x24
  public
    UpperName: AnsiString; // @offset 0x04
    OriginalName: AnsiString; // @offset 0x08
    HeaderSize: Cardinal; // @offset 0x0C
    EntryCount: Cardinal; // @offset 0x10
    EntryRecordSize: Cardinal; // @offset 0x14
    Parent: THsFolderEC; // @offset 0x18
    EntryBuffer: PPackEntryEC; // @offset 0x1C
    ChangedFlag: Boolean; // @offset 0x20
    InitializedEmptyFlag: Boolean; // @offset 0x21

    constructor Create(FolderName: AnsiString); // @addr 0x82C758 @ida "THsFolderEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, char *FolderName@<ecx>);"
    constructor CreateChild(FolderName: AnsiString; Parent: THsFolderEC); // @addr 0x82C834 @ida "THsFolderEC *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, char *FolderName@<ecx>, THsFolderEC *Parent);"
    destructor Destroy; override; // @addr 0x82C914 @ida "void __usercall $name(THsFolderEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetEntry(Index: Cardinal): PPackEntryEC; // @addr 0x82C940 @note "Returns nil for an out-of-range index."
    function FindEntry(EntryName: AnsiString): PPackEntryEC; // @addr 0x82C980 @note "Uppercases EntryName and skips entries with nonzero Flags."
    procedure InitializeEmpty; // @addr 0x82CA48 @note "Requires an unloaded folder."
    function Load(FileHandle, SubtreeOffset: Cardinal): Boolean; // @addr 0x82CA90 @note "Returns false when already loaded; flagged child folders are skipped."
    procedure Unload; // @addr 0x82CCCC @note "Marks this folder and its parent changed."
    function ResolveEntryByPath(EntryPath: AnsiString): PPackEntryEC; // @addr 0x82CD90 @note "Accepts slash and backslash separators; returns nil when absent."
    procedure UpdateParentEntry; // @addr 0x82CE74 @note "Invalidates the parent's stored target offset."
  end;

  THashSlotEC = packed record // @size 0x34
    FullHash: Cardinal; // @offset 0x00
    MappedValue: Integer; // @offset 0x04
    HitCount: Cardinal; // @offset 0x08
    Unknown0C: Integer; // @offset 0x0C
    KeySuffix: array[0..31] of AnsiChar; // @offset 0x10
    // +0x0C is set to one on insertion; +0x30 remains unresolved.
  end;
  THashSlotArray = array[0..1023] of THashSlotEC;

  TPackOpenSlotEC = packed record // @size 0x1E
    FileHandle: Cardinal; // @offset 0x00
    IsAvailable: Boolean; // @offset 0x04
    DataStartOffset: Cardinal; // @offset 0x05
    CurrentDataOffset: Cardinal; // @offset 0x09
    DataSize: Cardinal; // @offset 0x0D
    CompressedBlockBuffer: Pointer; // @offset 0x11
    DecompressedBlockBuffer: Pointer; // @offset 0x15
    UsesChainedBlocks: Boolean; // @offset 0x19
    CurrentBlockIndex: Integer; // @offset 0x1A
  end;
  TPackOpenSlotArray = array[0..15] of TPackOpenSlotEC;

  TPackFileEC = class(TObject) // @size 0x210
  public
    NextPack: TPackFileEC; // @offset 0x04
    PrevPack: TPackFileEC; // @offset 0x08
    UseLooseFiles: Boolean; // @offset 0x0C
    PackageHandle: Cardinal; // @offset 0x10
    PackagePath: AnsiString; // @offset 0x14
    RootFolder: THsFolderEC; // @offset 0x18
    OpenSlots: TPackOpenSlotArray; // @offset 0x1C
    RootSubtreeOffset: Cardinal; // @offset 0x1FC
    CollectionIndex: Integer; // @offset 0x20C

    constructor Create; // @addr 0x82AEF8 @ida "TPackFileEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x82AF9C @ida "void __usercall $name(TPackFileEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetPackagePath(NewPackagePath: AnsiString); // @addr 0x82AFD0 @note "Does not close an open package."
    procedure CloseAllOpenEntrySlots; // @addr 0x82B024
    function Open: Boolean; // @addr 0x82B070 @note "Opens the package read/write; loose-file mode creates an empty root folder."
    function Close: Boolean; // @addr 0x82B2DC @note "Invalidates all open slots; returns false when already closed."
    function CloseForDestroy: Boolean; // @addr 0x82B360
    function FindFreeOpenSlotIndex: Integer; // @addr 0x82B3E4 @note "Returns -1 when all sixteen slots are occupied."
    function OpenEntryByPath(EntryPath: AnsiString; DesiredAccess: Cardinal): Integer; // @addr 0x82B428 @note "Returns a slot or -1; DesiredAccess applies only to loose files."
    function CreateLooseFile(FilePath: WideString): Integer; // @addr 0x82B8F0 @note "Creates or truncates a loose file for read/write access; returns a slot or -1."
    function CloseEntrySlot(SlotIndex: Cardinal): Boolean; // @addr 0x82BA3C
    function GetChainedBlockStoredSizeAtIndex(FirstBlockOffset, BlockIndex: Cardinal): Cardinal; // @addr 0x82BCC4 @note "Leaves PackageHandle at the selected payload; I/O errors are unchecked."
    function ReadEntrySlot(SlotIndex: Cardinal; Buffer: Pointer; ByteCount: Cardinal): Boolean; // @addr 0x82BD2C @note "Compressed reads do not enforce logical EOF or report decompressor and short-block failures."
    function WriteEntrySlot(SlotIndex: Cardinal; Buffer: Pointer; ByteCount: Cardinal): Boolean; // @addr 0x82C05C @note "Rejects compressed entries."
    function SeekEntrySlot(SlotIndex, Offset: Cardinal; Origin: Integer): Boolean; // @addr 0x82C294 @note "Origin 1 adds to the current position, 2 subtracts from size, otherwise Offset is absolute. Only compressed entries reject positions beyond DataSize."
    function GetEntrySlotPosition(SlotIndex: Cardinal): Cardinal; // @addr 0x82C524 @note "Returns 0xFFFFFFFF for an unavailable slot or SlotIndex=0xFFFFFFFF."
    function GetEntrySlotSize(SlotIndex: Cardinal): Cardinal; // @addr 0x82C648 @note "Returns 0xFFFFFFFF for an unavailable slot or SlotIndex=0xFFFFFFFF."
  end;
  TPackFileArray = array[0..127] of TPackFileEC;

  THashEC = class(TObject) // @size 0xD01C
  public
    OperationCount: Cardinal; // @offset 0x04
    HitCount: Cardinal; // @offset 0x08
    // Incremented on every hit alongside HitCount; no distinct use recovered.
    HitCountCopy: Cardinal; // @offset 0x0C
    StaleValueCount: Cardinal; // @offset 0x10
    MissCount: Cardinal; // @offset 0x14
    ReservedText: AnsiString; // @offset $18 Native THashEC cleanup owns this otherwise unused field.
    Slots: THashSlotArray; // @offset 0x1C

    constructor Create; // @addr 0x82DA20 @ida "THashEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x82DA64 @ida "void __usercall $name(THashEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function InitializeEmptyTable(BucketCount: Integer): Boolean; // @addr 0x82DD50 @note "Ignores BucketCount; the table has 1024 buckets. Always returns true."
    function ReleaseTable: Boolean; // @addr 0x82DDB0 @note "Returns true without changing the table."
    function ComputeLookupBucketAndFullHash(var Key: AnsiString; out FullHash: Cardinal): Integer; // @addr 0x82DA90 @note "Key is not modified; only its trailing 32 bytes contribute to the hash."
    function FindOrInsertKeySlot(Key: AnsiString): Integer; // @addr 0x82DB2C @note "Returns -1 on failure. Native probing can reach slot 1024; promoted hits return the pre-swap index."
    procedure SetSlotMappedValue(SlotIndex, Value: Integer); // @addr 0x82DD2C
    function GetSlotMappedValue(SlotIndex: Integer): Integer; // @addr 0x82DDC4
    procedure MaybeResetStatistics; // @addr 0x82DDE8
    procedure NoteStaleMappedValue; // @addr 0x82DE38
  end;

  TPackCollectionEC = class(TObject) // @size 0x214
  public
    FirstPack: TPackFileEC; // @offset 0x04
    LastPack: TPackFileEC; // @offset 0x08
    NameToPackIndexHash: THashEC; // @offset 0x0C
    UseFastNameIndex: Boolean; // @offset 0x10
    PackByIndex: TPackFileArray; // @offset 0x14

    constructor Create; // @addr 0x82CFC0 @ida "TPackCollectionEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x82D034 @ida "void __usercall $name(TPackCollectionEC *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Unlinks packs without freeing them."
    procedure Clear(FreePacks: Boolean); // @addr 0x82D064 @note "Frees the name hash even when FreePacks is false."
    // List mutations rebuild PackByIndex and CollectionIndex without clearing the name hash.
    // The fixed array's 128-package capacity is not checked.
    procedure AddPackToFront(Pack: TPackFileEC); // @addr 0x82D0CC
    procedure AddPackToBack(Pack: TPackFileEC); // @addr 0x82D1D4
    procedure RemovePack(Pack: TPackFileEC; FreePack: Boolean); // @addr 0x82D2DC @note "When retained, Pack keeps its old links and CollectionIndex."
    function OpenAllPackages: Boolean; // @addr 0x82D3B8 @note "A false result rolls back previously opened packages."
    function CloseAllPackages: Boolean; // @addr 0x82D468 @note "Returns true regardless of individual close results."
    function GetPackByIndex(PackIndex: Integer): TPackFileEC; // @addr 0x82D4C0 @note "Returns nil when out of range."
    function OpenEntryByPathAcrossPackages(EntryPath: AnsiString; DesiredAccess: Cardinal; FirstPackageOnly: Boolean): Integer; // @addr 0x82D500 @note "Returns package index * 16 + slot, or -1."
    function CreateLooseFile(FilePath: WideString): Integer; // @addr 0x82D698 @note "Uses the first package; truncates existing files. Returns a handle or -1."
    function CloseEntryHandle(Handle: Integer): Boolean; // @addr 0x82D70C
    function ReadEntryHandle(Handle: Integer; var Buffer; ByteCount: Cardinal): Boolean; // @addr 0x82D758
    function WriteEntryHandle(Handle: Integer; var Buffer; ByteCount: Cardinal): Boolean; // @addr 0x82D7B0
    function SeekEntryHandle(Handle: Integer; Offset: Cardinal; Origin: Integer): Boolean; // @addr 0x82D808
    function GetEntryHandlePosition(Handle: Integer): Cardinal; // @addr 0x82D860 @note "Returns 0xFFFFFFFF for an invalid handle."
    function GetEntryHandleSize(Handle: Integer): Cardinal; // @addr 0x82D8B0 @note "Returns 0xFFFFFFFF for an invalid handle."
  end;

var
  PackageCollection: TPackCollectionEC; // @addr 0x88C278
  PackageFileLock: TCriticalSection; // @addr 0x88C27C
  LooseFileRoot: AnsiString; // @addr 0x88C280

function MatchLookupKeySuffix(var Key: AnsiString; SuffixBytes: Pointer; SuffixLength: Integer): Boolean; // @addr 0x82D900 @note "Ignores SuffixLength; compares up to 32 trailing key bytes without checking stored length. Key is not modified."
procedure CopyLookupKeySuffix(DestSuffixBytes: Pointer; SuffixLength: Integer; var Key: AnsiString); // @addr 0x82D998 @note "Ignores SuffixLength; copies up to 32 trailing key bytes without terminator or padding. Key is not modified."
function AnsiBeforeFirstDelimiter(Text, Delimiters: AnsiString): AnsiString; // @addr 0x82AD34 @ida "void __usercall $name(char *Text@<eax>, char *Delimiters@<edx>, char **Result@<ecx>);" @note "Returns Text when no delimiter occurs."
function AnsiAfterFirstDelimiter(Text, Delimiters: AnsiString): AnsiString; // @addr 0x82AE08 @ida "void __usercall $name(char *Text@<eax>, char *Delimiters@<edx>, char **Result@<ecx>);" @note "Returns an empty string when no delimiter occurs."
function OffsetPackPointer(Data: Pointer; ByteOffset: Cardinal): Pointer; // @addr $82AD18

implementation

uses EC_OKGF, SysUtils, Windows;

const
  // A collection handle combines the package index and its four-bit open slot.
  PackOpenSlotShift = 4;
  PackOpenSlotCount = 1 shl PackOpenSlotShift;
  PackCompressionBlockShift = 16;
  PackCompressionBlockSize = 1 shl PackCompressionBlockShift;
  PackCompressedBufferSize = 72112;
  PackSlotRangeError = 'Номер файла не может быть более ';

{ @routine $82AD18 OffsetPackPointer }
function OffsetPackPointer(Data: Pointer; ByteOffset: Cardinal): Pointer;
begin
  Result := Pointer(PAnsiChar(Data) + ByteOffset);
end;
{ @end $82AD18 }

{ @routine $82AD34 AnsiBeforeFirstDelimiter }
function AnsiBeforeFirstDelimiter(Text, Delimiters: AnsiString): AnsiString;
var i, j: Integer;
begin
  i := 1;
  while i <= Length(Text) do
  begin
    for j := 1 to Length(Delimiters) do
      if Delimiters[j] = Text[i] then
      begin
        Result := Copy(Text, 1, i - 1);
        Exit;
      end;
    Inc(i);
  end;
  Result := Text;
end;
{ @end $82AD34 }

{ @routine $82AE08 AnsiAfterFirstDelimiter }
function AnsiAfterFirstDelimiter(Text, Delimiters: AnsiString): AnsiString;
var i, j: Integer;
begin
  i := 1;
  while i <= Length(Text) do
  begin
    for j := 1 to Length(Delimiters) do
      if Delimiters[j] = Text[i] then
      begin
        Result := Copy(Text, i + 1, Length(Text) - i);
        Exit;
      end;
    Inc(i);
  end;
  Result := '';
end;
{ @end $82AE08 }

{ @routine $82AEF8 TPackFileEC_Create }
constructor TPackFileEC.Create;
var i: Integer;
begin
  PackageHandle := INVALID_HANDLE_VALUE;
  UseLooseFiles := False;
  PackagePath := '';
  RootFolder := nil;
  RootSubtreeOffset := 0;
  NextPack := nil;
  PrevPack := nil;
  CollectionIndex := -1;
  for i := Low(OpenSlots) to High(OpenSlots) do OpenSlots[i].IsAvailable := True;
end;
{ @end $82AEF8 }

{ @routine $82AF9C TPackFileEC_Destroy }
destructor TPackFileEC.Destroy;
begin
  CloseAllOpenEntrySlots;
  CloseForDestroy;
end;
{ @end $82AF9C }

{ @routine $82AFD0 TPackFileEC_SetPackagePath }
procedure TPackFileEC.SetPackagePath(NewPackagePath: AnsiString);
begin
  PackagePath := NewPackagePath;
end;
{ @end $82AFD0 }

{ @routine $82B024 TPackFileEC_CloseAllOpenEntrySlots }
procedure TPackFileEC.CloseAllOpenEntrySlots;
var i: Integer;
begin
  for i := Low(OpenSlots) to High(OpenSlots) do
    if not OpenSlots[i].IsAvailable then
    begin
      CloseEntrySlot(i);
      OpenSlots[i].IsAvailable := True;
    end;
end;
{ @end $82B024 }

{ @routine $82B070 TPackFileEC_Open }
function TPackFileEC.Open: Boolean;
var BytesRead: Cardinal;
begin
  if (PackageHandle <> INVALID_HANDLE_VALUE) or (RootFolder <> nil) then Close;
  if UseLooseFiles then
  begin
    RootSubtreeOffset := 0;
    RootFolder := THsFolderEC.Create('');
    RootFolder.InitializeEmpty;
    Result := True;
    Exit;
  end;

  PackageHandle := Windows.CreateFileA(PAnsiChar(PackagePath), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if PackageHandle = INVALID_HANDLE_VALUE then
  begin
    raise Exception.Create('Error openning package file [READ]:' + PackagePath);
    PackageHandle := INVALID_HANDLE_VALUE;
    Exit;
  end;

  if not Windows.ReadFile(PackageHandle, RootSubtreeOffset, SizeOf(RootSubtreeOffset), BytesRead, nil) then
  begin
    Windows.CloseHandle(PackageHandle);
    raise Exception.Create('Error reading package file:' + PackagePath);
    PackageHandle := INVALID_HANDLE_VALUE;
    Exit;
  end;

  RootFolder := THsFolderEC.Create('');
  if not RootFolder.Load(PackageHandle, RootSubtreeOffset) then
  begin
    RootFolder.Free;
    RootFolder := nil;
    Close;
    raise Exception.Create('Error reading file system of the package file:' + PackagePath);
    Exit;
  end;

  Result := True;
end;
{ @end $82B070 }

{ @routine $82B2DC TPackFileEC_Close }
function TPackFileEC.Close: Boolean;
var Success: Boolean;
begin
  Result := False;
  if (PackageHandle = INVALID_HANDLE_VALUE) and (RootFolder = nil) then Exit;
  CloseAllOpenEntrySlots;
  if RootFolder <> nil then
  begin
    RootFolder.Free;
    RootFolder := nil;
  end;
  if PackageHandle <> INVALID_HANDLE_VALUE then Success := Windows.CloseHandle(PackageHandle)
  else Success := True;
  PackageHandle := INVALID_HANDLE_VALUE;
  if Success then Result := True;
end;
{ @end $82B2DC }

{ @routine $82B360 TPackFileEC_CloseForDestroy }
function TPackFileEC.CloseForDestroy: Boolean;
var Success: Boolean;
begin
  Result := False;
  if (PackageHandle = INVALID_HANDLE_VALUE) and (RootFolder = nil) then Exit;
  CloseAllOpenEntrySlots;
  if RootFolder <> nil then
  begin
    RootFolder.Free;
    RootFolder := nil;
  end;
  if PackageHandle <> INVALID_HANDLE_VALUE then Success := Windows.CloseHandle(PackageHandle)
  else Success := True;
  PackageHandle := INVALID_HANDLE_VALUE;
  if Success then Result := True;
end;
{ @end $82B360 }

{ @routine $82B3E4 TPackFileEC_FindFreeOpenSlotIndex }
function TPackFileEC.FindFreeOpenSlotIndex: Integer;
var i: Integer;
begin
  for i := Low(OpenSlots) to High(OpenSlots) do
    if OpenSlots[i].IsAvailable then begin Result := i; Exit end;
  Result := -1;
end;
{ @end $82B3E4 }

{ @routine $82B428 TPackFileEC_OpenEntryByPath }
function TPackFileEC.OpenEntryByPath(EntryPath: AnsiString; DesiredAccess: Cardinal): Integer;
var Slot: Integer; Entry: PPackEntryEC; Position: Cardinal;
begin
  Result := -1;
  Slot := FindFreeOpenSlotIndex;
  if Slot = -1 then Exit;
  if RootFolder = nil then raise Exception.Create('Package not opened :' + EntryPath);
  if not UseLooseFiles then
  begin
    Entry := RootFolder.ResolveEntryByPath(EntryPath);
    if Entry = nil then Exit;
  end
  else
  begin
    if not SysUtils.FileExists(LooseFileRoot + EntryPath) then Exit;
    OpenSlots[Slot].FileHandle := Windows.CreateFileA(PAnsiChar(LooseFileRoot + EntryPath), DesiredAccess,
      FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if OpenSlots[Slot].FileHandle = INVALID_HANDLE_VALUE then Exit;
    OpenSlots[Slot].DataStartOffset := 0;
    OpenSlots[Slot].CurrentDataOffset := 0;
    OpenSlots[Slot].DataSize := Windows.SetFilePointer(OpenSlots[Slot].FileHandle, 0, nil, FILE_END);
    OpenSlots[Slot].CompressedBlockBuffer := nil;
    OpenSlots[Slot].DecompressedBlockBuffer := nil;
    OpenSlots[Slot].UsesChainedBlocks := False;
    OpenSlots[Slot].CurrentBlockIndex := -1;
    if OpenSlots[Slot].DataSize = $FFFFFFFF then raise Exception.Create('Сбой в файловой системе :' + EntryPath);
    Position := Windows.SetFilePointer(OpenSlots[Slot].FileHandle, 0, nil, FILE_BEGIN);
    if Position = $FFFFFFFF then raise Exception.Create('Сбой в файловой системе:' + EntryPath);
    OpenSlots[Slot].IsAvailable := False;
    Result := Slot;
    Exit;
  end;
  if PackageHandle = INVALID_HANDLE_VALUE then Exit;
  OpenSlots[Slot].FileHandle := PackageHandle;
  OpenSlots[Slot].DataStartOffset := Entry.TargetOffset + 4;
  OpenSlots[Slot].CurrentDataOffset := Entry.TargetOffset + 4;
  OpenSlots[Slot].DataSize := Entry.DataSize;
  OpenSlots[Slot].IsAvailable := False;
  OpenSlots[Slot].UsesChainedBlocks := Entry.Kind = 2;
  OpenSlots[Slot].CurrentBlockIndex := -1;
  if OpenSlots[Slot].UsesChainedBlocks then
  begin
    OpenSlots[Slot].CompressedBlockBuffer := AllocMem(PackCompressedBufferSize);
    OpenSlots[Slot].DecompressedBlockBuffer := AllocMem(PackCompressionBlockSize);
  end
  else
  begin
    OpenSlots[Slot].CompressedBlockBuffer := nil;
    OpenSlots[Slot].DecompressedBlockBuffer := nil;
  end;
  Position := Windows.SetFilePointer(OpenSlots[Slot].FileHandle, OpenSlots[Slot].CurrentDataOffset, nil, FILE_BEGIN);
  if Position = $FFFFFFFF then raise Exception.Create('Сбой в пакетном файле :' + PackagePath + ':' + EntryPath);
  Result := Slot;
end;
{ @end $82B428 }

{ @routine $82B8F0 TPackFileEC_CreateLooseFile }
function TPackFileEC.CreateLooseFile(FilePath: WideString): Integer;
var Slot: Integer;
begin
  Result := -1;
  Slot := FindFreeOpenSlotIndex;
  if Slot = -1 then Exit;
  OpenSlots[Slot].FileHandle := Windows.CreateFileW(PWideChar(FilePath), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if OpenSlots[Slot].FileHandle = INVALID_HANDLE_VALUE then Exit;
  OpenSlots[Slot].DataStartOffset := 0;
  OpenSlots[Slot].CurrentDataOffset := 0;
  OpenSlots[Slot].DataSize := 0;
  OpenSlots[Slot].CompressedBlockBuffer := nil;
  OpenSlots[Slot].DecompressedBlockBuffer := nil;
  OpenSlots[Slot].UsesChainedBlocks := False;
  OpenSlots[Slot].CurrentBlockIndex := -1;
  OpenSlots[Slot].IsAvailable := False;
  Result := Slot;
end;
{ @end $82B8F0 }

{ @routine $82BA3C TPackFileEC_CloseEntrySlot }
function TPackFileEC.CloseEntrySlot(SlotIndex: Cardinal): Boolean;
begin
  Result := False;
  if SlotIndex = $FFFFFFFF then Exit;
  if SlotIndex > High(OpenSlots) then
    raise Exception.Create(PackSlotRangeError + SysUtils.IntToStr(High(OpenSlots)) + ': ' + SysUtils.IntToStr(SlotIndex));
  if OpenSlots[SlotIndex].IsAvailable then Exit;
  Result := True;
  if OpenSlots[SlotIndex].FileHandle = PackageHandle then
  begin
    if OpenSlots[SlotIndex].UsesChainedBlocks then
    begin
      FreeMem(OpenSlots[SlotIndex].CompressedBlockBuffer);
      OpenSlots[SlotIndex].CompressedBlockBuffer := nil;
      FreeMem(OpenSlots[SlotIndex].DecompressedBlockBuffer);
      OpenSlots[SlotIndex].DecompressedBlockBuffer := nil;
    end;
    OpenSlots[SlotIndex].IsAvailable := True;
  end
  else
  begin
    if not Boolean(Windows.CloseHandle(OpenSlots[SlotIndex].FileHandle)) then
      raise Exception.Create('Ошибка закрытия файла : ' + SysUtils.IntToStr(SlotIndex));
    if OpenSlots[SlotIndex].UsesChainedBlocks then
    begin
      FreeMem(OpenSlots[SlotIndex].CompressedBlockBuffer);
      OpenSlots[SlotIndex].CompressedBlockBuffer := nil;
      FreeMem(OpenSlots[SlotIndex].DecompressedBlockBuffer);
      OpenSlots[SlotIndex].DecompressedBlockBuffer := nil;
    end;
    OpenSlots[SlotIndex].IsAvailable := True;
  end;
end;
{ @end $82BA3C }

{ @routine $82BCC4 TPackFileEC_GetChainedBlockStoredSizeAtIndex }
function TPackFileEC.GetChainedBlockStoredSizeAtIndex(FirstBlockOffset, BlockIndex: Cardinal): Cardinal;
var BytesRead, StoredSize, Offset: Cardinal;
begin
  Offset := FirstBlockOffset;
  while True do
  begin
    Windows.SetFilePointer(PackageHandle, Offset, nil, FILE_BEGIN);
    Windows.ReadFile(PackageHandle, StoredSize, SizeOf(StoredSize), BytesRead, nil);
    if BlockIndex = 0 then Break;
    Dec(BlockIndex);
    Offset := Offset + StoredSize + SizeOf(StoredSize);
  end;
  Result := StoredSize;
end;
{ @end $82BCC4 }

{ @routine $82BD2C TPackFileEC_ReadEntrySlot }
function TPackFileEC.ReadEntrySlot(SlotIndex: Cardinal; Buffer: Pointer; ByteCount: Cardinal): Boolean;
var BytesRead, BlockIndex, BlockOffset, ChunkSize, StoredSize, RelativeOffset: Cardinal;
    Decoded, Dest: Pointer;
begin
  Result := False;
  if SlotIndex = $FFFFFFFF then Exit;
  if SlotIndex > High(OpenSlots) then
    raise Exception.Create(PackSlotRangeError + SysUtils.IntToStr(High(OpenSlots)) + ': ' + SysUtils.IntToStr(SlotIndex));
  if OpenSlots[SlotIndex].IsAvailable then Exit;
  if OpenSlots[SlotIndex].UsesChainedBlocks then
  begin
    Decoded := OpenSlots[SlotIndex].DecompressedBlockBuffer;
    Dest := Buffer;
    while ByteCount <> 0 do
    begin
      RelativeOffset := OpenSlots[SlotIndex].CurrentDataOffset - OpenSlots[SlotIndex].DataStartOffset;
      BlockIndex := RelativeOffset shr PackCompressionBlockShift;
      BlockOffset := RelativeOffset - BlockIndex * PackCompressionBlockSize;
      ChunkSize := ByteCount;
      if PackCompressionBlockSize - BlockOffset < ChunkSize then
        ChunkSize := PackCompressionBlockSize - BlockOffset;
      if OpenSlots[SlotIndex].CurrentBlockIndex <> Integer(BlockIndex) then
      begin
        StoredSize := GetChainedBlockStoredSizeAtIndex(OpenSlots[SlotIndex].DataStartOffset, BlockIndex);
        Result := Windows.ReadFile(PackageHandle, OpenSlots[SlotIndex].CompressedBlockBuffer^, StoredSize, BytesRead, nil);
        if not Result then Exit;
        OKGF_ZLib_UnCompress2(OpenSlots[SlotIndex].DecompressedBlockBuffer, PackCompressionBlockSize,
          OpenSlots[SlotIndex].CompressedBlockBuffer, StoredSize);
        OpenSlots[SlotIndex].CurrentBlockIndex := BlockIndex;
      end;
      Move(OffsetPackPointer(Decoded, BlockOffset)^, Dest^, ChunkSize);
      Dest := OffsetPackPointer(Dest, ChunkSize);
      Dec(ByteCount, ChunkSize);
      Inc(OpenSlots[SlotIndex].CurrentDataOffset, ChunkSize);
    end;
    Result := True;
  end
  else
  begin
    Windows.SetFilePointer(OpenSlots[SlotIndex].FileHandle, OpenSlots[SlotIndex].CurrentDataOffset, nil, FILE_BEGIN);
    Result := Windows.ReadFile(OpenSlots[SlotIndex].FileHandle, Buffer^, ByteCount, BytesRead, nil);
    Result := Result and (ByteCount = BytesRead);
    Inc(OpenSlots[SlotIndex].CurrentDataOffset, BytesRead);
  end;
end;
{ @end $82BD2C }

{ @routine $82C05C TPackFileEC_WriteEntrySlot }
function TPackFileEC.WriteEntrySlot(SlotIndex: Cardinal; Buffer: Pointer; ByteCount: Cardinal): Boolean;
var BytesWritten, Size: Cardinal;
begin
  Result := False;
  if SlotIndex = $FFFFFFFF then Exit;
  if SlotIndex > High(OpenSlots) then
    raise Exception.Create(PackSlotRangeError + SysUtils.IntToStr(High(OpenSlots)) + ': ' + SysUtils.IntToStr(SlotIndex));
  if OpenSlots[SlotIndex].IsAvailable then Exit;
  if OpenSlots[SlotIndex].UsesChainedBlocks then raise Exception.Create('Ошибочная операция записи в сжатый файл');
  Windows.SetFilePointer(OpenSlots[SlotIndex].FileHandle, OpenSlots[SlotIndex].CurrentDataOffset, nil, FILE_BEGIN);
  Result := Windows.WriteFile(OpenSlots[SlotIndex].FileHandle, Buffer^, ByteCount, BytesWritten, nil);
  Result := Result and (ByteCount = BytesWritten);
  Inc(OpenSlots[SlotIndex].CurrentDataOffset, BytesWritten);
  Size := OpenSlots[SlotIndex].CurrentDataOffset - OpenSlots[SlotIndex].DataStartOffset;
  if Size > OpenSlots[SlotIndex].DataSize then OpenSlots[SlotIndex].DataSize := Size;
end;
{ @end $82C05C }

{ @routine $82C294 TPackFileEC_SeekEntrySlot }
function TPackFileEC.SeekEntrySlot(SlotIndex, Offset: Cardinal; Origin: Integer): Boolean;
var Position, BlockIndex: Cardinal;
begin
  Result := False;
  if SlotIndex = $FFFFFFFF then Exit;
  if SlotIndex > High(OpenSlots) then
    raise Exception.Create(PackSlotRangeError + SysUtils.IntToStr(High(OpenSlots)) + ': ' + SysUtils.IntToStr(SlotIndex));
  if OpenSlots[SlotIndex].IsAvailable then Exit;
  if Origin = FILE_CURRENT then Offset := OpenSlots[SlotIndex].CurrentDataOffset + Offset - OpenSlots[SlotIndex].DataStartOffset
  else if Origin = FILE_END then Offset := OpenSlots[SlotIndex].DataSize - Offset;
  if OpenSlots[SlotIndex].UsesChainedBlocks then
  begin
    if Offset > OpenSlots[SlotIndex].DataSize then Exit;
    BlockIndex := Offset shr PackCompressionBlockShift;
    if OpenSlots[SlotIndex].CurrentBlockIndex <> Integer(BlockIndex) then OpenSlots[SlotIndex].CurrentBlockIndex := -1;
    OpenSlots[SlotIndex].CurrentDataOffset := OpenSlots[SlotIndex].DataStartOffset + Offset;
  end
  else
  begin
    Position := Windows.SetFilePointer(OpenSlots[SlotIndex].FileHandle, OpenSlots[SlotIndex].DataStartOffset + Offset, nil, FILE_BEGIN);
    if Position = $FFFFFFFF then raise Exception.Create('Ошибка установки указателя в пакетном файле :' + PackagePath);
    OpenSlots[SlotIndex].CurrentDataOffset := Position;
  end;
  Result := True;
end;
{ @end $82C294 }

{ @routine $82C524 TPackFileEC_GetEntrySlotPosition }
function TPackFileEC.GetEntrySlotPosition(SlotIndex: Cardinal): Cardinal;
begin
  Result := $FFFFFFFF;
  if SlotIndex = $FFFFFFFF then Exit;
  if SlotIndex > High(OpenSlots) then
    raise Exception.Create(PackSlotRangeError + SysUtils.IntToStr(High(OpenSlots)) + ': ' + SysUtils.IntToStr(SlotIndex));
  if OpenSlots[SlotIndex].IsAvailable then Exit;
  Result := OpenSlots[SlotIndex].CurrentDataOffset - OpenSlots[SlotIndex].DataStartOffset;
end;
{ @end $82C524 }

{ @routine $82C648 TPackFileEC_GetEntrySlotSize }
function TPackFileEC.GetEntrySlotSize(SlotIndex: Cardinal): Cardinal;
begin
  Result := $FFFFFFFF;
  if SlotIndex = $FFFFFFFF then Exit;
  if SlotIndex > High(OpenSlots) then
    raise Exception.Create(PackSlotRangeError + SysUtils.IntToStr(High(OpenSlots)) + ': ' + SysUtils.IntToStr(SlotIndex));
  if OpenSlots[SlotIndex].IsAvailable then Exit;
  Result := OpenSlots[SlotIndex].DataSize;
end;
{ @end $82C648 }

{ @routine $82C758 THsFolderEC_Create }
constructor THsFolderEC.Create(FolderName: AnsiString);
begin
  EntryBuffer := nil;
  HeaderSize := 12;
  EntryCount := 0;
  EntryRecordSize := SizeOf(TPackEntryEC);
  Parent := nil;
  OriginalName := FolderName;
  UpperName := SysUtils.UpperCase(FolderName);
  ChangedFlag := False;
  InitializedEmptyFlag := False;
end;
{ @end $82C758 }

{ @routine $82C834 THsFolderEC_CreateChild }
constructor THsFolderEC.CreateChild(FolderName: AnsiString; Parent: THsFolderEC);
begin
  EntryBuffer := nil;
  HeaderSize := 12;
  EntryCount := 0;
  EntryRecordSize := SizeOf(TPackEntryEC);
  Self.Parent := Parent;
  OriginalName := FolderName;
  UpperName := SysUtils.UpperCase(FolderName);
  ChangedFlag := False;
  InitializedEmptyFlag := False;
end;
{ @end $82C834 }

{ @routine $82C914 THsFolderEC_Destroy }
destructor THsFolderEC.Destroy;
begin
  Unload;
end;
{ @end $82C914 }

{ @routine $82C940 THsFolderEC_GetEntry }
function THsFolderEC.GetEntry(Index: Cardinal): PPackEntryEC;
begin
  if Index < EntryCount then Result := OffsetPackPointer(EntryBuffer, EntryRecordSize * Index)
  else Result := nil;
end;
{ @end $82C940 }

{ @routine $82C980 THsFolderEC_FindEntry }
function THsFolderEC.FindEntry(EntryName: AnsiString): PPackEntryEC;
var i: Integer; Entry: PPackEntryEC;
begin
  EntryName := SysUtils.UpperCase(EntryName);
  Result := nil;
  for i := 0 to EntryCount - 1 do
  begin
    Entry := GetEntry(i);
    if Entry.Flags = 0 then
      if SysUtils.StrComp(Entry.UpperName, PAnsiChar(EntryName)) = 0 then
      begin
        Result := Entry;
        Break;
      end;
  end;
end;
{ @end $82C980 }

{ @routine $82CA48 THsFolderEC_InitializeEmpty }
procedure THsFolderEC.InitializeEmpty;
begin
  EntryCount := 0;
  EntryRecordSize := SizeOf(TPackEntryEC);
  HeaderSize := EntryRecordSize * EntryCount + 12;
  EntryBuffer := nil;
  InitializedEmptyFlag := True;
  UpdateParentEntry;
end;
{ @end $82CA48 }

{ @routine $82CA90 THsFolderEC_Load }
function THsFolderEC.Load(FileHandle, SubtreeOffset: Cardinal): Boolean;
var BytesRead: Cardinal; Success: Boolean; i: Integer; Entry: PPackEntryEC; Folder: THsFolderEC;
begin
  Result := False;
  if EntryBuffer <> nil then Exit;
  InitializedEmptyFlag := False;
  ChangedFlag := False;
  Windows.SetFilePointer(FileHandle, SubtreeOffset, nil, FILE_BEGIN);
  Success := Windows.ReadFile(FileHandle, HeaderSize, 12, BytesRead, nil);
  if not Success then Exit;
  if BytesRead <> 12 then Exit;
  if EntryRecordSize <> SizeOf(TPackEntryEC) then Exit;
  EntryBuffer := AllocMem(EntryCount * EntryRecordSize);
  for i := 0 to EntryCount - 1 do
  begin
    Success := Windows.ReadFile(FileHandle, GetEntry(i)^, EntryRecordSize, BytesRead, nil);
    if not Success or (BytesRead <> EntryRecordSize) then begin Unload; Exit end;
  end;
  for i := 0 to EntryCount - 1 do
  begin
    Entry := GetEntry(i);
    Entry.ChildFolder := nil;
    Entry.KindCopy := Entry.Kind;
  end;
  for i := 0 to EntryCount - 1 do
  begin
    Entry := GetEntry(i);
    if (Entry.Kind = 3) and (Entry.Flags = 0) then
    begin
      Folder := THsFolderEC.CreateChild(Entry.OriginalName + '', Self);
      Entry.ChildFolder := Folder;
      Success := Folder.Load(FileHandle, Entry.TargetOffset);
      if not Success then begin Unload; Exit end;
    end;
  end;
  Result := True;
end;
{ @end $82CA90 }

{ @routine $82CCCC THsFolderEC_Unload }
procedure THsFolderEC.Unload;
var i: Integer; Entry: PPackEntryEC; Folder: THsFolderEC;
begin
  if EntryBuffer <> nil then
  begin
    for i := 0 to EntryCount - 1 do
    begin
      Entry := GetEntry(i);
      if (Entry.Kind = 3) and (Entry.Flags = 0) then
      begin
        Folder := Entry.ChildFolder;
        if Folder <> nil then Folder.Free;
        Entry.ChildFolder := nil;
      end;
    end;
    FreeMem(EntryBuffer);
    EntryBuffer := nil;
    EntryCount := 0;
    HeaderSize := EntryCount * EntryRecordSize + 12;
    ChangedFlag := True;
    UpdateParentEntry;
  end;
end;
{ @end $82CCCC }

{ @routine $82CD90 THsFolderEC_ResolveEntryByPath }
function THsFolderEC.ResolveEntryByPath(EntryPath: AnsiString): PPackEntryEC;
var Head, Tail: AnsiString; Entry: PPackEntryEC; Folder: THsFolderEC;
begin
  Result := nil;
  Head := AnsiBeforeFirstDelimiter(EntryPath, '/\');
  Tail := AnsiAfterFirstDelimiter(EntryPath, '/\');
  Entry := FindEntry(Head);
  if Entry <> nil then
  begin
    if Entry.Kind = 3 then
    begin
      if Tail = '' then Result := Entry
      else
      begin
        Folder := Entry.ChildFolder;
        Result := Folder.ResolveEntryByPath(Tail);
      end;
    end
    else if Tail = '' then Result := Entry;
  end;
end;
{ @end $82CD90 }

{ @routine $82CE74 THsFolderEC_UpdateParentEntry }
procedure THsFolderEC.UpdateParentEntry;
var Entry: PPackEntryEC;
begin
  if Parent <> nil then
  begin
    Entry := Parent.FindEntry(OriginalName);
    if Entry = nil then raise Exception.Create('Сбой в файловой системе пакетного файла - Folder: ' + UpperName);
    if Entry.Kind <> 3 then raise Exception.Create('Конфликт имен файл/директория: ' + UpperName);
    Entry.StoredSize := HeaderSize;
    Entry.TargetOffset := 0;
    Parent.ChangedFlag := True;
  end;
end;
{ @end $82CE74 }

{ @routine $82CFC0 TPackCollectionEC_Create }
constructor TPackCollectionEC.Create;
var i: Integer;
begin
  NameToPackIndexHash := nil;
  UseFastNameIndex := False;
  LastPack := nil;
  FirstPack := nil;
  for i := Low(PackByIndex) to High(PackByIndex) do PackByIndex[i] := nil;
end;
{ @end $82CFC0 }

{ @routine $82D034 TPackCollectionEC_Destroy }
destructor TPackCollectionEC.Destroy;
begin
  Clear(False);
end;
{ @end $82D034 }

{ @routine $82D064 TPackCollectionEC_Clear }
procedure TPackCollectionEC.Clear(FreePacks: Boolean);
var i: Integer;
begin
  for i := Low(PackByIndex) to High(PackByIndex) do PackByIndex[i] := nil;
  if NameToPackIndexHash <> nil then
  begin
    NameToPackIndexHash.Free;
    NameToPackIndexHash := nil;
  end;
  while FirstPack <> nil do RemovePack(FirstPack, FreePacks);
end;
{ @end $82D064 }

{ @routine $82D0CC TPackCollectionEC_AddPackToFront }
procedure TPackCollectionEC.AddPackToFront(Pack: TPackFileEC);
var Item: TPackFileEC; Count, i: Integer;
begin
  for i := Low(PackByIndex) to High(PackByIndex) do PackByIndex[i] := nil;
  if FirstPack = nil then
  begin
    FirstPack := Pack;
    LastPack := Pack;
    Pack.NextPack := nil;
    Pack.PrevPack := nil;
    Item := FirstPack;
    Count := 0;
    while Item <> nil do
    begin
      Item.CollectionIndex := Count;
      PackByIndex[Count] := Item;
      Inc(Count);
      Item := Item.NextPack;
    end;
  end
  else
  begin
    Pack.PrevPack := nil;
    Pack.NextPack := FirstPack;
    FirstPack.PrevPack := Pack;
    FirstPack := Pack;
    Item := FirstPack;
    Count := 0;
    while Item <> nil do
    begin
      Item.CollectionIndex := Count;
      PackByIndex[Count] := Item;
      Inc(Count);
      Item := Item.NextPack;
    end;
  end;
end;
{ @end $82D0CC }

{ @routine $82D1D4 TPackCollectionEC_AddPackToBack }
procedure TPackCollectionEC.AddPackToBack(Pack: TPackFileEC);
var Item: TPackFileEC; Count, i: Integer;
begin
  for i := Low(PackByIndex) to High(PackByIndex) do PackByIndex[i] := nil;
  if FirstPack = nil then
  begin
    FirstPack := Pack;
    LastPack := Pack;
    Pack.NextPack := nil;
    Pack.PrevPack := nil;
    Item := FirstPack;
    Count := 0;
    while Item <> nil do
    begin
      Item.CollectionIndex := Count;
      PackByIndex[Count] := Item;
      Inc(Count);
      Item := Item.NextPack;
    end;
  end
  else
  begin
    Pack.PrevPack := LastPack;
    Pack.NextPack := nil;
    LastPack.NextPack := Pack;
    LastPack := Pack;
    Item := FirstPack;
    Count := 0;
    while Item <> nil do
    begin
      Item.CollectionIndex := Count;
      PackByIndex[Count] := Item;
      Inc(Count);
      Item := Item.NextPack;
    end;
  end;
end;
{ @end $82D1D4 }

{ @routine $82D2DC TPackCollectionEC_RemovePack }
procedure TPackCollectionEC.RemovePack(Pack: TPackFileEC; FreePack: Boolean);
var Item: TPackFileEC; Count, i: Integer;
begin
  for i := Low(PackByIndex) to High(PackByIndex) do PackByIndex[i] := nil;
  if Pack.PrevPack <> nil then Pack.PrevPack.NextPack := Pack.NextPack;
  if Pack.NextPack <> nil then Pack.NextPack.PrevPack := Pack.PrevPack;
  if FirstPack = Pack then FirstPack := Pack.NextPack;
  if LastPack = Pack then LastPack := Pack.PrevPack;
  if FreePack then Pack.Free;
  Item := FirstPack;
  Count := 0;
  while Item <> nil do
  begin
    Item.CollectionIndex := Count;
    PackByIndex[Count] := Item;
    Inc(Count);
    Item := Item.NextPack;
  end;
end;
{ @end $82D2DC }

{ @routine $82D3B8 TPackCollectionEC_OpenAllPackages }
function TPackCollectionEC.OpenAllPackages: Boolean;
var Pack: TPackFileEC;
begin
  Result := False;
  if UseFastNameIndex then
  begin
    if NameToPackIndexHash <> nil then NameToPackIndexHash.Free;
    NameToPackIndexHash := THashEC.Create;
    NameToPackIndexHash.InitializeEmptyTable(Length(NameToPackIndexHash.Slots));
  end;
  Pack := FirstPack;
  while Pack <> nil do
  begin
    if not Pack.Open then Break;
    Pack := Pack.NextPack;
  end;
  if Pack <> nil then
  begin
    Pack := Pack.PrevPack;
    while Pack <> nil do
    begin
      Pack.Close;
      Pack := Pack.PrevPack;
    end;
    Exit;
  end;
  Result := True;
end;
{ @end $82D3B8 }

{ @routine $82D468 TPackCollectionEC_CloseAllPackages }
function TPackCollectionEC.CloseAllPackages: Boolean;
var Pack: TPackFileEC;
begin
  Pack := FirstPack;
  while Pack <> nil do
  begin
    Pack.Close;
    Pack := Pack.NextPack;
  end;
  if NameToPackIndexHash <> nil then
  begin
    NameToPackIndexHash.Free;
    NameToPackIndexHash := nil;
  end;
  Result := True;
end;
{ @end $82D468 }

{ @routine $82D4C0 TPackCollectionEC_GetPackByIndex }
function TPackCollectionEC.GetPackByIndex(PackIndex: Integer): TPackFileEC;
var Pack: TPackFileEC;
begin
  Pack := FirstPack;
  while Pack <> nil do
  begin
    if PackIndex = 0 then Break;
    Pack := Pack.NextPack;
    Dec(PackIndex);
  end;
  Result := Pack;
end;
{ @end $82D4C0 }

{ @routine $82D500 TPackCollectionEC_OpenEntryByPathAcrossPackages }
function TPackCollectionEC.OpenEntryByPathAcrossPackages(EntryPath: AnsiString; DesiredAccess: Cardinal; FirstPackageOnly: Boolean): Integer;
var Pack: TPackFileEC; Slot, Index, HashSlot, MappedIndex: Integer;
begin
  Result := -1;
  Index := 0;
  Slot := -1;
  if UseFastNameIndex and not FirstPackageOnly then
  begin
    HashSlot := NameToPackIndexHash.FindOrInsertKeySlot(EntryPath);
    if HashSlot <> -1 then
    begin
      MappedIndex := NameToPackIndexHash.GetSlotMappedValue(HashSlot);
      if MappedIndex = -1 then
      begin
        Pack := FirstPack;
        while Pack <> nil do
        begin
          Slot := Pack.OpenEntryByPath(EntryPath, DesiredAccess);
          if Slot <> -1 then Break;
          Pack := Pack.NextPack;
        end;
        if Slot = -1 then Exit;
        MappedIndex := Pack.CollectionIndex;
        NameToPackIndexHash.SetSlotMappedValue(HashSlot, MappedIndex);
      end
      else
      begin
        Pack := PackByIndex[MappedIndex];
        Slot := Pack.OpenEntryByPath(EntryPath, DesiredAccess);
        if Slot = -1 then NameToPackIndexHash.NoteStaleMappedValue;
      end;
      if Slot <> -1 then
      begin
        Result := MappedIndex * PackOpenSlotCount + Slot;
        Exit;
      end;
    end;
  end;
  Pack := FirstPack;
  while Pack <> nil do
  begin
    Slot := Pack.OpenEntryByPath(EntryPath, DesiredAccess);
    if Slot <> -1 then Break;
    if FirstPackageOnly then Exit;
    Pack := Pack.NextPack;
    Inc(Index);
  end;
  if Slot <> -1 then Result := Index * PackOpenSlotCount + Slot;
end;
{ @end $82D500 }

{ @routine $82D698 TPackCollectionEC_CreateLooseFile }
function TPackCollectionEC.CreateLooseFile(FilePath: WideString): Integer;
var Slot: Integer;
begin
  Result := -1;
  if FirstPack <> nil then
  begin
    Slot := FirstPack.CreateLooseFile(FilePath);
    if Slot <> -1 then Result := Slot;
  end;
end;
{ @end $82D698 }

{ @routine $82D70C TPackCollectionEC_CloseEntryHandle }
function TPackCollectionEC.CloseEntryHandle(Handle: Integer): Boolean;
var Pack: TPackFileEC; Index: Integer;
begin
  Result := False;
  Index := Handle shr PackOpenSlotShift;
  Pack := GetPackByIndex(Index);
  if Pack <> nil then Result := Pack.CloseEntrySlot(Handle - Index * PackOpenSlotCount);
end;
{ @end $82D70C }

{ @routine $82D758 TPackCollectionEC_ReadEntryHandle }
function TPackCollectionEC.ReadEntryHandle(Handle: Integer; var Buffer; ByteCount: Cardinal): Boolean;
var Pack: TPackFileEC; Index: Integer;
begin
  Result := False;
  Index := Handle shr PackOpenSlotShift;
  Pack := GetPackByIndex(Index);
  if Pack <> nil then Result := Pack.ReadEntrySlot(Handle - Index * PackOpenSlotCount, @Buffer, ByteCount);
end;
{ @end $82D758 }

{ @routine $82D7B0 TPackCollectionEC_WriteEntryHandle }
function TPackCollectionEC.WriteEntryHandle(Handle: Integer; var Buffer; ByteCount: Cardinal): Boolean;
var Pack: TPackFileEC; Index: Integer;
begin
  Result := False;
  Index := Handle shr PackOpenSlotShift;
  Pack := GetPackByIndex(Index);
  if Pack <> nil then Result := Pack.WriteEntrySlot(Handle - Index * PackOpenSlotCount, @Buffer, ByteCount);
end;
{ @end $82D7B0 }

{ @routine $82D808 TPackCollectionEC_SeekEntryHandle }
function TPackCollectionEC.SeekEntryHandle(Handle: Integer; Offset: Cardinal; Origin: Integer): Boolean;
var Pack: TPackFileEC; Index: Integer;
begin
  Result := False;
  Index := Handle shr PackOpenSlotShift;
  Pack := GetPackByIndex(Index);
  if Pack <> nil then Result := Pack.SeekEntrySlot(Handle - Index * PackOpenSlotCount, Offset, Origin);
end;
{ @end $82D808 }

{ @routine $82D860 TPackCollectionEC_GetEntryHandlePosition }
function TPackCollectionEC.GetEntryHandlePosition(Handle: Integer): Cardinal;
var Pack: TPackFileEC; Index: Integer;
begin
  Result := $FFFFFFFF;
  Index := Handle shr PackOpenSlotShift;
  Pack := GetPackByIndex(Index);
  if Pack <> nil then Result := Pack.GetEntrySlotPosition(Handle - Index * PackOpenSlotCount);
end;
{ @end $82D860 }

{ @routine $82D8B0 TPackCollectionEC_GetEntryHandleSize }
function TPackCollectionEC.GetEntryHandleSize(Handle: Integer): Cardinal;
var Pack: TPackFileEC; Index: Integer;
begin
  Result := $FFFFFFFF;
  Index := Handle shr PackOpenSlotShift;
  Pack := GetPackByIndex(Index);
  if Pack <> nil then Result := Pack.GetEntrySlotSize(Handle - Index * PackOpenSlotCount);
end;
{ @end $82D8B0 }

{ @routine $82D900 MatchLookupKeySuffix }
function MatchLookupKeySuffix(var Key: AnsiString; SuffixBytes: Pointer; SuffixLength: Integer): Boolean;
var i, j, First, KeyLength: Integer;
begin
  KeyLength := Length(Key);
  if KeyLength > 32 then First := KeyLength - 31 else First := 1;
  j := 0;
  Result := True;
  for i := First to KeyLength do
  begin
    if Key[i] <> PAnsiChar(SuffixBytes)[j] then begin Result := False; Break end;
    Inc(j);
  end;
end;
{ @end $82D900 }

{ @routine $82D998 CopyLookupKeySuffix }
procedure CopyLookupKeySuffix(DestSuffixBytes: Pointer; SuffixLength: Integer; var Key: AnsiString);
var i, j, First, KeyLength: Integer;
begin
  KeyLength := Length(Key);
  if KeyLength > 32 then First := KeyLength - 31 else First := 1;
  j := 0;
  for i := First to KeyLength do
  begin
    PAnsiChar(DestSuffixBytes)[j] := Key[i];
    Inc(j);
  end;
end;
{ @end $82D998 }

{ @routine $82DA20 THashEC_Create }
constructor THashEC.Create;
begin
  InitializeEmptyTable(Length(Slots));
end;
{ @end $82DA20 }

{ @routine $82DA64 THashEC_Destroy }
destructor THashEC.Destroy;
begin
  ReleaseTable;
end;
{ @end $82DA64 }

{ @routine $82DA90 THashEC_ComputeLookupBucketAndFullHash }
function THashEC.ComputeLookupBucketAndFullHash(var Key: AnsiString; out FullHash: Cardinal): Integer;
var Hash: Cardinal; i, First, KeyLength: Integer;
begin
  KeyLength := Length(Key);
  if KeyLength > 32 then First := KeyLength - 31 else First := 1;
  Hash := 0;
  for i := First to KeyLength do Hash := Ord(Key[i]) + Hash * 2;
  FullHash := Hash;
  Result := Hash and High(Slots);
end;
{ @end $82DA90 }

{ @routine $82DB2C THashEC_FindOrInsertKeySlot }
function THashEC.FindOrInsertKeySlot(Key: AnsiString): Integer;
var Bucket, Hash, i: Cardinal; Found: Integer; Temp: THashSlotEC;
begin
  Bucket := ComputeLookupBucketAndFullHash(Key, Hash);
  Found := -1;
  for i := Bucket to Bucket + 5 do
  begin
    if Slots[i].MappedValue <> -1 then
    begin
      if (Slots[i].FullHash = Hash) and MatchLookupKeySuffix(Key, @Slots[i].KeySuffix, 32) then
      begin
        Found := i;
        Inc(Slots[i].HitCount);
        Inc(OperationCount);
        Inc(HitCount);
        Inc(HitCountCopy);
        MaybeResetStatistics;
        if (i > Bucket) and (i < Cardinal(Length(Slots))) then
          if Slots[i].HitCount > Slots[i - 1].HitCount then
          begin
            Temp := Slots[i];
            Slots[i] := Slots[i - 1];
            Slots[i - 1] := Temp;
          end;
        Break;
      end;
    end
    else
    begin
      Slots[i].FullHash := Hash;
      Slots[i].HitCount := 1;
      Slots[i].Unknown0C := 1;
      CopyLookupKeySuffix(@Slots[i].KeySuffix, 32, Key);
      Found := i;
      Inc(OperationCount);
      Inc(MissCount);
      MaybeResetStatistics;
      Break;
    end;
    if i > High(Slots) then Break;
  end;
  if Found = -1 then
  begin
    Inc(OperationCount);
    Inc(MissCount);
    MaybeResetStatistics;
  end;
  Result := Found;
end;
{ @end $82DB2C }

{ @routine $82DD2C THashEC_SetSlotMappedValue }
procedure THashEC.SetSlotMappedValue(SlotIndex, Value: Integer);
begin
  Slots[SlotIndex].MappedValue := Value;
end;
{ @end $82DD2C }

{ @routine $82DD50 THashEC_InitializeEmptyTable }
function THashEC.InitializeEmptyTable(BucketCount: Integer): Boolean;
var i: Integer;
begin
  OperationCount := 0;
  HitCount := 0;
  HitCountCopy := 0;
  StaleValueCount := 0;
  MissCount := 0;
  for i := Low(Slots) to High(Slots) do Slots[i].MappedValue := -1;
  Result := True;
end;
{ @end $82DD50 }

{ @routine $82DDB0 THashEC_ReleaseTable }
function THashEC.ReleaseTable: Boolean;
begin
  Result := True;
end;
{ @end $82DDB0 }

{ @routine $82DDC4 THashEC_GetSlotMappedValue }
function THashEC.GetSlotMappedValue(SlotIndex: Integer): Integer;
begin
  Result := Slots[SlotIndex].MappedValue;
end;
{ @end $82DDC4 }

{ @routine $82DDE8 THashEC_MaybeResetStatistics }
procedure THashEC.MaybeResetStatistics;
begin
  if (OperationCount mod 100 = 0) and (OperationCount <> 0) then
  begin
    OperationCount := 0;
    HitCount := 0;
    HitCountCopy := 0;
    StaleValueCount := 0;
    MissCount := 0;
  end;
end;
{ @end $82DDE8 }

{ @routine $82DE38 THashEC_NoteStaleMappedValue }
procedure THashEC.NoteStaleMappedValue;
begin
  Inc(StaleValueCount);
end;
{ @end $82DE38 }

end.
