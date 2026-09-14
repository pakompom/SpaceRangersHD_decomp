unit EC_CacheGAI;
// Unit bracket (inferred): .text 0x004780D0..0x00478EE4; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_gi, Types, Direct3D9;

type
  TCGaiControlEC = class;
  TCGaiEC = class;

  TCGaiControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4781D8
    function CreateData: TCacheDataEC; override; // @addr 0x47825C
    function AcquireData: TCacheDataEC; override; // @addr 0x4782A8
  end;

  TCGaiEC = class(TCacheDataEC) // @size 0x3C
  public
    RawGaiData: Pointer; // @offset 0x20
    Header: PGaiHeader; // @offset 0x24
    DecodedFrameGi: TgiGR; // @offset 0x28
    SequenceTableData: PGaiSequenceTableHeader; // @offset 0x2C
    SkipPalettedColorCacheBuild: Boolean; // @offset 0x30
    FrameSurfaceCache: TTextureGR; // @offset 0x34
    CachedFrameOrigins: array of TPoint; // @offset 0x38
    // CachedFrameOrigins has Header.FrameCount entries.

    constructor Create; // @addr 0x4782C4 @ida "TCGaiEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x478320 @ida "void __usercall $name(TCGaiEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetFrameCount: Integer; // @addr 0x4783B0
    function HasPlaybackFlags: Boolean; // @addr 0x4783CC
    function GetBoundsRect: TRect; // @addr 0x4783EC @ida "void __usercall $name(TCGaiEC *Self@<eax>, TRect *Result@<edx>);"
    function GetCanvasSize: TPoint; // @addr 0x478414 @ida "void __usercall $name(TCGaiEC *Self@<eax>, TPoint *Result@<edx>);"
    function GetOrCreateFrameSurface(FrameIndex: Integer): IDirect3DTexture9; // @addr 0x478440 @ida "void __usercall $name(TCGaiEC *Self@<eax>, int FrameIndex@<edx>, IDirect3DTexture9 **Result@<ecx>);"
    function GetFrameOrigin(FrameIndex: Integer): TPoint; // @addr 0x4785D0 @ida "void __usercall $name(TCGaiEC *Self@<eax>, int FrameIndex@<edx>, TPoint *Result@<ecx>);" @note "Requires a valid index and a prior GetOrCreateFrameSurface call."
    function LoadFrameGi(FrameIndex: Integer): TgiGR; // @addr 0x478600 @note "Returns borrowed, reused DecodedFrameGi storage, or nil."
    function IsFrameCompressed(FrameIndex: Integer): Boolean; // @addr 0x478740 @note "Does not validate FrameIndex."
    function GetSequenceCount: Integer; // @addr 0x4787A4 @note "Returns zero when no sequence table exists. Other sequence accessors require a valid table and indexes."
    function GetSequenceFrameCount(SequenceIndex: Integer): Integer; // @addr 0x4787D4
    procedure FillSequenceFrameIndexTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer); // @addr 0x478824
    procedure FillSequenceFrameDelayTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer); // @addr 0x4788E4
    function GetSequenceFrameIndex(SequenceIndex, FrameInSequence: Integer): Integer; // @addr 0x4789A4
    function GetSequenceFrameDelay(SequenceIndex, FrameInSequence: Integer): Integer; // @addr 0x478A04
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x478A68 @note "NoConvertPF disables palette conversion. Only the minimum header size is validated; frame and sequence offsets are trusted."
    procedure ApplyAB2BackgroundFixup(SourceBuffer: TBufEC; const ResourceKey: WideString); // @addr 0x478CD8 @note "Only affects the single-frame Bm.FormAB2.2bg resource; replaces SourceBuffer with RGB565 GI data."
  end;

function AcquireCachedGai(Control: TCacheControlEC): TCGaiEC; // @addr 0x47827C

implementation

uses EC_Mem, EC_Str, EC_Struct, GR_Main, GR_GraphBuf, Windows;

{ @routine $4781D8 TCGaiControlEC_QueueLoadIfMissing }
procedure TCGaiControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCGaiControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCGaiEC) = nil then
  begin
    Control := TCGaiControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $4781D8 }

{ @routine $47825C TCGaiControlEC_CreateData }
function TCGaiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGaiEC.Create;
end;
{ @end $47825C }

{ @routine $47827C AcquireCachedGai }
function AcquireCachedGai(Control: TCacheControlEC): TCGaiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGaiEC) as TCGaiEC;
end;
{ @end $47827C }

{ @routine $4782A8 TCGaiControlEC_AcquireData }
function TCGaiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGai(Self);
end;
{ @end $4782A8 }

{ @routine $4782C4 TCGaiEC_Create }
constructor TCGaiEC.Create;
begin
  inherited Create;
  DecodedFrameGi := TgiGR.Create;
  FrameSurfaceCache := nil;
end;
{ @end $4782C4 }

{ @routine $478320 TCGaiEC_Destroy }
destructor TCGaiEC.Destroy;
begin
  if RawGaiData <> nil then
  begin
    FreeEC(RawGaiData); RawGaiData := nil;
  end;
  DecodedFrameGi.Free;
  if FrameSurfaceCache <> nil then
  begin
    FreeTextureCache(FrameSurfaceCache); FrameSurfaceCache := nil;
    SetLength(CachedFrameOrigins, 0);
  end;
  inherited Destroy;
end;
{ @end $478320 }

{ @routine $4783B0 TCGaiEC_GetFrameCount }
function TCGaiEC.GetFrameCount: Integer;
begin
  Result := Header.FrameCount;
end;
{ @end $4783B0 }

{ @routine $4783CC TCGaiEC_HasPlaybackFlags }
function TCGaiEC.HasPlaybackFlags: Boolean;
begin
  Result := Header.Flags <> 0;
end;
{ @end $4783CC }

{ @routine $4783EC TCGaiEC_GetBoundsRect }
function TCGaiEC.GetBoundsRect: TRect;
begin
  Result := Header.Bounds;
end;
{ @end $4783EC }

{ @routine $478414 TCGaiEC_GetCanvasSize }
function TCGaiEC.GetCanvasSize: TPoint;
begin
  Result := SubtractPoints(Header.Bounds.BottomRight, Header.Bounds.TopLeft);
end;
{ @end $478414 }

{ @routine $478440 TCGaiEC_GetOrCreateFrameSurface }
function TCGaiEC.GetOrCreateFrameSurface(FrameIndex: Integer): IDirect3DTexture9;
var Texture: IDirect3DTexture9; Locked: TD3DLockedRect; FrameSize, Origin: TPoint; Frame: TgiGR;
begin
  if FrameSurfaceCache = nil then FrameSurfaceCache := CreateTextureCache;
  Texture := FrameSurfaceCache.GetSurface(FrameIndex);
  if Texture = nil then
  begin
    Frame := LoadFrameGi(FrameIndex);
    if Frame <> nil then
    begin
      FrameSize := Frame.GetContentSize;
      if (FrameSize.X = 0) or (FrameSize.Y = 0) then
      begin
        Result := nil;
        Exit;
      end;
      if (Frame.Header.Format = 0) and (Frame.Header.AlphaMask = 0) then
        Texture := GR_CreateTexture(FrameSize.X, FrameSize.Y, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
      else Texture := GR_CreateTexture(FrameSize.X, FrameSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
      if Texture <> nil then
      begin
        Texture.LockRect(0, Locked, nil, 0);
        if Locked.Bits <> nil then
        begin
          Frame.DecodeToPixels(Locked.Bits, Locked.Pitch, FrameSize.X, FrameSize.Y, True);
          Texture.UnlockRect(0);
        end;
      end;
      Origin := Frame.GetTopLeft;
      CachedFrameOrigins[FrameIndex].X := Origin.X - Header.Bounds.Left;
      CachedFrameOrigins[FrameIndex].Y := Origin.Y - Header.Bounds.Top;
      FrameSurfaceCache.SetSurface(Texture, FrameIndex);
    end;
  end;
  Result := Texture;
end;
{ @end $478440 }

{ @routine $4785D0 TCGaiEC_GetFrameOrigin }
function TCGaiEC.GetFrameOrigin(FrameIndex: Integer): TPoint;
begin
  Result := CachedFrameOrigins[FrameIndex];
end;
{ @end $4785D0 }

{ @routine $478600 TCGaiEC_LoadFrameGi }
function TCGaiEC.LoadFrameGi(FrameIndex: Integer): TgiGR;
var Offset: Integer;
begin
  Result := nil;
  if (FrameIndex < 0) or (Header.FrameCount <= FrameIndex) then Exit;
  Offset := ReadDWordEC(AddPointerOffset(RawGaiData, FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader)));
  if Offset = 0 then
  begin
    Result := nil;
    Exit;
  end;
  if ReadWordEC(AddPointerOffset(RawGaiData, Offset)) = $4C5A then
  begin
    DecodedFrameGi.LoadCompressedGiBytes(AddPointerOffset(RawGaiData, Offset), ReadDWordEC(AddPointerOffset(RawGaiData, FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader) + 4)));
    if not SkipPalettedColorCacheBuild then DecodedFrameGi.BuildPalettedFormat4ColorCache;
  end
  else DecodedFrameGi.LoadRawGiBytes(AddPointerOffset(RawGaiData, Offset), ReadDWordEC(AddPointerOffset(RawGaiData, FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader) + 4)));
  if not DecodedFrameGi.IsEmpty then Result := DecodedFrameGi;
end;
{ @end $478600 }

{ @routine $478740 TCGaiEC_IsFrameCompressed }
function TCGaiEC.IsFrameCompressed(FrameIndex: Integer): Boolean;
var Offset: Integer;
begin
  Offset := ReadDWordEC(AddPointerOffset(RawGaiData, FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader)));
  if Offset = 0 then Result := False
  else Result := ReadWordEC(AddPointerOffset(RawGaiData, Offset)) = $4C5A;
end;
{ @end $478740 }

{ @routine $4787A4 TCGaiEC_GetSequenceCount }
function TCGaiEC.GetSequenceCount: Integer;
begin
  if SequenceTableData = nil then Result := 0
  else Result := ReadDWordEC(SequenceTableData);
end;
{ @end $4787A4 }

{ @routine $4787D4 TCGaiEC_GetSequenceFrameCount }
function TCGaiEC.GetSequenceFrameCount(SequenceIndex: Integer): Integer;
// The directory begins after the eight-byte header. Native $4787E6/$4787E9
// add its two dwords separately; the pointer/read helpers below are real calls.
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData, ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4))));
end;
{ @end $4787D4 }

{ @routine $478824 TCGaiEC_FillSequenceFrameIndexTable }
procedure TCGaiEC.FillSequenceFrameIndexTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer);
var Source: Pointer; Index, Count: Integer;
begin
  Source := AddPointerOffset(SequenceTableData, ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4)));
  Count := ReadDWordEC(Source);
  Source := AddPointerOffset(Source, SizeOf(TGaiSequenceDataBlock));
  for Index := 0 to Count - 1 do
  begin
    WriteIntegerEC(DestTable, ReadDWordEC(Source));
    DestTable := AddPointerOffset(DestTable, EntryStride);
    Source := AddPointerOffset(Source, SizeOf(TGaiSequenceFrameEntry));
  end;
end;
{ @end $478824 }

{ @routine $4788E4 TCGaiEC_FillSequenceFrameDelayTable }
procedure TCGaiEC.FillSequenceFrameDelayTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer);
var Source: Pointer; Index, Count: Integer;
begin
  Source := AddPointerOffset(SequenceTableData, ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4)));
  Count := ReadDWordEC(Source);
  Source := AddPointerOffset(Source, SizeOf(TGaiSequenceDataBlock) + SizeOf(Integer));
  for Index := 0 to Count - 1 do
  begin
    WriteIntegerEC(DestTable, ReadDWordEC(Source));
    DestTable := AddPointerOffset(DestTable, EntryStride);
    Source := AddPointerOffset(Source, SizeOf(TGaiSequenceFrameEntry));
  end;
end;
{ @end $4788E4 }

{ @routine $4789A4 TCGaiEC_GetSequenceFrameIndex }
function TCGaiEC.GetSequenceFrameIndex(SequenceIndex, FrameInSequence: Integer): Integer;
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData,
    ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4)) + (FrameInSequence * SizeOf(TGaiSequenceFrameEntry) + 4)));
end;
{ @end $4789A4 }

{ @routine $478A04 TCGaiEC_GetSequenceFrameDelay }
function TCGaiEC.GetSequenceFrameDelay(SequenceIndex, FrameInSequence: Integer): Integer;
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData,
    ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4)) + (FrameInSequence * SizeOf(TGaiSequenceFrameEntry) + 4 + 4)));
end;
{ @end $478A04 }

{ @routine $478A68 TCGaiEC_LoadFromConfigBuffer }
procedure TCGaiEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var FrameIndex: Integer; Frame: TgiGR;
begin
  if LoadOption = 'NoConvertPF' then SkipPalettedColorCacheBuild := True;
  ApplyAB2BackgroundFixup(SourceBuffer, CacheKey);
  try
    RawGaiData := AllocEC(SourceBuffer.DataSize);
    CopyMemory(RawGaiData, SourceBuffer.Data, SourceBuffer.DataSize);
    ResidentBytes := SourceBuffer.DataSize;
  except
    RawGaiData := nil; ResidentBytes := 0;
  end;
  Header := RawGaiData;
  if (SourceBuffer.DataSize < SizeOf(TGaiHeader)) or (RawGaiData = nil) then
  begin
    AppendLogLineThreadSafe('Error Load Gai');
    Header := AllocClearEC(SizeOf(TGaiHeader));
  end;
  if Header.SequenceTableOffset <> 0 then SequenceTableData := AddPointerOffset(RawGaiData, Header.SequenceTableOffset);
  for FrameIndex := 0 to Header.FrameCount - 1 do
    if not IsFrameCompressed(FrameIndex) then
    begin
      Frame := LoadFrameGi(FrameIndex);
      if (Frame <> nil) and not SkipPalettedColorCacheBuild then Frame.BuildPalettedFormat4ColorCache;
    end;
  SetLength(CachedFrameOrigins, Header.FrameCount);
end;
{ @end $478A68 }

{ @routine $478CD8 TCGaiEC_ApplyAB2BackgroundFixup }
procedure TCGaiEC.ApplyAB2BackgroundFixup(SourceBuffer: TBufEC; const ResourceKey: WideString);
var Image: TgiGR; GraphBuf: TGraphBufGR; ByteCount, Offset: Integer; OldHeader: TGaiHeader;

  // @nested $478C20 LogGaiRescaleStart
  procedure LogGaiRescaleStart; // @addr $478C20 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x00478CFF"
  begin
    AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  // @nested $478CBC LogGaiRescaleDone
  procedure LogGaiRescaleDone; // @addr $478CBC @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x00478EDB"
  begin
    AppendLogLineThreadSafe('ok');
  end;

begin
  if FindTextOffsetW(ResourceKey, 'Bm.FormAB2.2bg') = 0 then
  begin
    LogGaiRescaleStart;
    CopyMemory(@OldHeader, SourceBuffer.Data, SizeOf(TGaiHeader));
    if OldHeader.FrameCount <> 1 then Exit;
    Offset := ReadDWordEC(AddPointerOffset(SourceBuffer.Data, SizeOf(TGaiHeader)));
    ByteCount := ReadDWordEC(AddPointerOffset(SourceBuffer.Data, SizeOf(TGaiHeader) + 4));
    if (Offset = 0) or (ByteCount = 0) then Exit;
    Image := TgiGR.Create;
    if ReadWordEC(AddPointerOffset(SourceBuffer.Data, Offset)) = $4C5A then
      Image.LoadCompressedGiBytes(AddPointerOffset(SourceBuffer.Data, Offset), ByteCount)
    else Image.LoadRawGiBytes(AddPointerOffset(SourceBuffer.Data, Offset), ByteCount);
    if Image.IsEmpty then Exit;
    GraphBuf := TGraphBufGR.Create(False);
    GraphBuf.AllocateRgbaTight(Image.GetContentSize.X, Image.GetContentSize.Y);
    Image.DecodeToGraphBuf(GraphBuf, False);
    Image.ClearData;
    GraphBuf.RescaleRGBA_HW(GameScreenWidth, GameScreenHeight, True, 1, 1);
    Image.CreateFromGraphBuf(GraphBuf, 1);
    GraphBuf.Clear;
    OldHeader.Bounds.Right := GameScreenWidth; OldHeader.Bounds.Bottom := GameScreenHeight;
    SourceBuffer.Clear;
    SourceBuffer.AddBytes(@OldHeader, SizeOf(TGaiHeader));
    SourceBuffer.AddDWord(SizeOf(TGaiHeader) + SizeOf(TGaiFrameEntry));
    SourceBuffer.AddDWord(Image.DataSize);
    SourceBuffer.AddBytes(Image.Data, Image.DataSize);
    Image.ClearData;
    Image.Free;
    LogGaiRescaleDone;
  end;
end;
{ @end $478CD8 }

end.
