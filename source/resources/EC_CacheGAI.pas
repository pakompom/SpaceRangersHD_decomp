unit EC_CacheGAI;
// Unit bracket (inferred): .text 0x0047C680..0x0047D494; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_gi, Types, Direct3D9;

type
  TCGaiControlEC = class;
  TCGaiEC = class;

  TCGaiControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47C788
    function CreateData: TCacheDataEC; override; // @addr 0x47C80C
    function AcquireData: TCacheDataEC; override; // @addr 0x47C858
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

    constructor Create; // @addr 0x47C874
    destructor Destroy; override; // @addr 0x47C8D0
    function GetFrameCount: Integer; // @addr 0x47C960
    function HasPlaybackFlags: Boolean; // @addr 0x47C97C
    function GetBoundsRect: TRect; // @addr 0x47C99C
    function GetCanvasSize: TPoint; // @addr 0x47C9C4
    function GetOrCreateFrameSurface(FrameIndex: Integer): IDirect3DTexture9; // @addr 0x47C9F0
    function GetFrameOrigin(FrameIndex: Integer): TPoint; // @addr 0x47CB80 @note "Requires a valid index and a prior GetOrCreateFrameSurface call."
    function LoadFrameGi(FrameIndex: Integer): TgiGR; // @addr 0x47CBB0 @note "Returns borrowed, reused DecodedFrameGi storage, or nil."
    function IsFrameCompressed(FrameIndex: Integer): Boolean; // @addr 0x47CCF0 @note "Does not validate FrameIndex."
    function GetSequenceCount: Integer; // @addr 0x47CD54 @note "Returns zero when no sequence table exists. Other sequence accessors require a valid table and indexes."
    function GetSequenceFrameCount(SequenceIndex: Integer): Integer; // @addr 0x47CD84
    procedure FillSequenceFrameIndexTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer); // @addr 0x47CDD4
    procedure FillSequenceFrameDelayTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer); // @addr 0x47CE94
    function GetSequenceFrameIndex(SequenceIndex, FrameInSequence: Integer): Integer; // @addr 0x47CF54
    function GetSequenceFrameDelay(SequenceIndex, FrameInSequence: Integer): Integer; // @addr 0x47CFB4
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x47D018 @note "NoConvertPF disables palette conversion. Only the minimum header size is validated; frame and sequence offsets are trusted."
    procedure ApplyAB2BackgroundFixup(SourceBuffer: TBufEC; const ResourceKey: WideString); // @addr 0x47D288 @note "Only affects the single-frame Bm.FormAB2.2bg resource; replaces SourceBuffer with RGB565 GI data."
  end;

function AcquireCachedGai(Control: TCacheControlEC): TCGaiEC; // @addr 0x47C82C

implementation

uses EC_Mem, EC_Str, EC_Struct, GR_Main, GR_GraphBuf, Windows;

{ @routine $47C788 TCGaiControlEC_QueueLoadIfMissing }
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
{ @end $47C788 }

{ @routine $47C80C TCGaiControlEC_CreateData }
function TCGaiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGaiEC.Create;
end;
{ @end $47C80C }

{ @routine $47C82C AcquireCachedGai }
function AcquireCachedGai(Control: TCacheControlEC): TCGaiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGaiEC) as TCGaiEC;
end;
{ @end $47C82C }

{ @routine $47C858 TCGaiControlEC_AcquireData }
function TCGaiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGai(Self);
end;
{ @end $47C858 }

{ @routine $47C874 TCGaiEC_Create }
constructor TCGaiEC.Create;
begin
  inherited Create;
  DecodedFrameGi := TgiGR.Create;
  FrameSurfaceCache := nil;
end;
{ @end $47C874 }

{ @routine $47C8D0 TCGaiEC_Destroy }
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
{ @end $47C8D0 }

{ @routine $47C960 TCGaiEC_GetFrameCount }
function TCGaiEC.GetFrameCount: Integer;
begin
  Result := Header.FrameCount;
end;
{ @end $47C960 }

{ @routine $47C97C TCGaiEC_HasPlaybackFlags }
function TCGaiEC.HasPlaybackFlags: Boolean;
begin
  Result := Header.Flags <> 0;
end;
{ @end $47C97C }

{ @routine $47C99C TCGaiEC_GetBoundsRect }
function TCGaiEC.GetBoundsRect: TRect;
begin
  Result := Header.Bounds;
end;
{ @end $47C99C }

{ @routine $47C9C4 TCGaiEC_GetCanvasSize }
function TCGaiEC.GetCanvasSize: TPoint;
begin
  Result := SubtractPoints(Header.Bounds.BottomRight, Header.Bounds.TopLeft);
end;
{ @end $47C9C4 }

{ @routine $47C9F0 TCGaiEC_GetOrCreateFrameSurface }
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
{ @end $47C9F0 }

{ @routine $47CB80 TCGaiEC_GetFrameOrigin }
function TCGaiEC.GetFrameOrigin(FrameIndex: Integer): TPoint;
begin
  Result := CachedFrameOrigins[FrameIndex];
end;
{ @end $47CB80 }

{ @routine $47CBB0 TCGaiEC_LoadFrameGi }
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
{ @end $47CBB0 }

{ @routine $47CCF0 TCGaiEC_IsFrameCompressed }
function TCGaiEC.IsFrameCompressed(FrameIndex: Integer): Boolean;
var Offset: Integer;
begin
  Offset := ReadDWordEC(AddPointerOffset(RawGaiData, FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader)));
  if Offset = 0 then Result := False
  else Result := ReadWordEC(AddPointerOffset(RawGaiData, Offset)) = $4C5A;
end;
{ @end $47CCF0 }

{ @routine $47CD54 TCGaiEC_GetSequenceCount }
function TCGaiEC.GetSequenceCount: Integer;
begin
  if SequenceTableData = nil then Result := 0
  else Result := ReadDWordEC(SequenceTableData);
end;
{ @end $47CD54 }

{ @routine $47CD84 TCGaiEC_GetSequenceFrameCount }
function TCGaiEC.GetSequenceFrameCount(SequenceIndex: Integer): Integer;
// The directory begins after the eight-byte header. Native $47CD96/$47CD99
// add its two dwords separately; the pointer/read helpers below are real calls.
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData, ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4))));
end;
{ @end $47CD84 }

{ @routine $47CDD4 TCGaiEC_FillSequenceFrameIndexTable }
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
{ @end $47CDD4 }

{ @routine $47CE94 TCGaiEC_FillSequenceFrameDelayTable }
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
{ @end $47CE94 }

{ @routine $47CF54 TCGaiEC_GetSequenceFrameIndex }
function TCGaiEC.GetSequenceFrameIndex(SequenceIndex, FrameInSequence: Integer): Integer;
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData,
    ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4)) + (FrameInSequence * SizeOf(TGaiSequenceFrameEntry) + 4)));
end;
{ @end $47CF54 }

{ @routine $47CFB4 TCGaiEC_GetSequenceFrameDelay }
function TCGaiEC.GetSequenceFrameDelay(SequenceIndex, FrameInSequence: Integer): Integer;
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData,
    ReadDWordEC(AddPointerOffset(SequenceTableData, SequenceIndex * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4)) + (FrameInSequence * SizeOf(TGaiSequenceFrameEntry) + 4 + 4)));
end;
{ @end $47CFB4 }

{ @routine $47D018 TCGaiEC_LoadFromConfigBuffer }
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
{ @end $47D018 }

{ @routine $47D288 TCGaiEC_ApplyAB2BackgroundFixup }
procedure TCGaiEC.ApplyAB2BackgroundFixup(SourceBuffer: TBufEC; const ResourceKey: WideString);
var Image: TgiGR; GraphBuf: TGraphBufGR; ByteCount, Offset: Integer; OldHeader: TGaiHeader;

  // @nested $47D1D0 LogGaiRescaleStart
  procedure LogGaiRescaleStart; // @addr $47D1D0 @calls "0x0047D2AF"
  begin
    AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  // @nested $47D26C LogGaiRescaleDone
  procedure LogGaiRescaleDone; // @addr $47D26C @calls "0x0047D48B"
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
{ @end $47D288 }

end.
