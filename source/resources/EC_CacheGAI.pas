unit EC_CacheGAI;

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_gi, Types, Direct3D9;

type
  TCGaiControlEC = class;
  TCGaiEC = class;

  TCGaiControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x004876AC
    function CreateData: TCacheDataEC; override; // @addr 0x00487718
    function AcquireData: TCacheDataEC; override; // @addr 0x00487748
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

    constructor Create; // @addr 0x00487750
    destructor Destroy; override; // @addr 0x0048779C
    function GetFrameCount: Integer; // @addr 0x00487804
    function HasPlaybackFlags: Boolean; // @addr 0x0048780C
    function GetBoundsRect: TRect; // @addr 0x00487818
    function GetCanvasSize: TPoint; // @addr 0x0048782C
    function GetOrCreateFrameSurface(FrameIndex: Integer): IDirect3DTexture9; // @addr 0x00487848
    function GetFrameOrigin(FrameIndex: Integer): TPoint; // @addr 0x004879AC @note "Requires a valid index and a prior GetOrCreateFrameSurface call."
    function LoadFrameGi(FrameIndex: Integer): TgiGR; // @addr 0x004879C0 @note "Returns borrowed, reused DecodedFrameGi storage, or nil."
    function IsFrameCompressed(FrameIndex: Integer): Boolean; // @addr 0x00487AC0 @note "Does not validate FrameIndex."
    function GetSequenceCount: Integer; // @addr 0x00487B10 @note "Returns zero when no sequence table exists. Other sequence accessors require a valid table and indexes."
    function GetSequenceFrameCount(SequenceIndex: Integer): Integer; // @addr 0x00487B24
    procedure FillSequenceFrameIndexTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer); // @addr 0x00487B64
    procedure FillSequenceFrameDelayTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer); // @addr 0x00487BF8
    function GetSequenceFrameIndex(SequenceIndex, FrameInSequence: Integer): Integer; // @addr 0x00487C8C
    function GetSequenceFrameDelay(SequenceIndex, FrameInSequence: Integer): Integer; // @addr 0x00487CDC
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x00487D30 @note "NoConvertPF disables palette conversion. Only the minimum header size is validated; frame and sequence offsets are trusted."
    procedure ApplyAB2BackgroundFixup(SourceBuffer: TBufEC; const ResourceKey: WideString); // @addr 0x00487F78 @note "Only affects the single-frame Bm.FormAB2.2bg resource; replaces SourceBuffer with RGB565 GI data."
  end;

function AcquireCachedGai(Control: TCacheControlEC): TCGaiEC; // @addr 0x00487728

implementation

uses EC_Mem, EC_Str, EC_Struct, GR_Main, GR_GraphBuf, Windows;

const
  GaiFrameDataSizeOffset = SizeOf(Integer); // TGaiFrameEntry.DataSize follows DataOffset.
  GaiSequenceFrameDelayOffset = SizeOf(Integer); // TGaiSequenceFrameEntry.FrameDelay follows SourceFrameIndex.

// The directory follows SequenceCount and one unresolved header dword.
function ReadGaiSequenceOffset(const Table: PGaiSequenceTableHeader; const Index: Integer): Cardinal; inline;
begin
  Result := ReadDWordEC(AddPointerOffset(Table,
    Index * SizeOf(TGaiSequenceDirectoryEntry) + 4 + 4));
end;

{ @routine $4876AC TCGaiControlEC_QueueLoadIfMissing }
procedure TCGaiControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCGaiControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCGaiEC) <> nil then Exit;
  Control := TCGaiControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $4876AC }

{ @routine $487718 TCGaiControlEC_CreateData }
function TCGaiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGaiEC.Create;
end;
{ @end $487718 }

{ @routine $487728 AcquireCachedGai }
function AcquireCachedGai(Control: TCacheControlEC): TCGaiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGaiEC) as TCGaiEC;
end;
{ @end $487728 }

{ @routine $487748 TCGaiControlEC_AcquireData }
function TCGaiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGai(Self);
end;
{ @end $487748 }

{ @routine $487750 TCGaiEC_Create }
constructor TCGaiEC.Create;
begin
  inherited Create;
  DecodedFrameGi := TgiGR.Create;
  FrameSurfaceCache := nil;
end;
{ @end $487750 }

{ @routine $48779C TCGaiEC_Destroy }
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
{ @end $48779C }

{ @routine $487804 TCGaiEC_GetFrameCount }
function TCGaiEC.GetFrameCount: Integer;
begin
  Result := Header.FrameCount;
end;
{ @end $487804 }

{ @routine $48780C TCGaiEC_HasPlaybackFlags }
function TCGaiEC.HasPlaybackFlags: Boolean;
begin
  Result := Header.Flags <> 0;
end;
{ @end $48780C }

{ @routine $487818 TCGaiEC_GetBoundsRect }
function TCGaiEC.GetBoundsRect: TRect;
begin
  Result := Header.Bounds;
end;
{ @end $487818 }

{ @routine $48782C TCGaiEC_GetCanvasSize }
function TCGaiEC.GetCanvasSize: TPoint;
begin
  Result := SubtractPoints(Header.Bounds.BottomRight, Header.Bounds.TopLeft);
end;
{ @end $48782C }

{ @routine $487848 TCGaiEC_GetOrCreateFrameSurface }
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
{ @end $487848 }

{ @routine $4879AC TCGaiEC_GetFrameOrigin }
function TCGaiEC.GetFrameOrigin(FrameIndex: Integer): TPoint;
begin
  Result := CachedFrameOrigins[FrameIndex];
end;
{ @end $4879AC }

{ @routine $4879C0 TCGaiEC_LoadFrameGi }
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
    DecodedFrameGi.LoadCompressedGiBytes(AddPointerOffset(RawGaiData, Offset),
      ReadDWordEC(AddPointerOffset(RawGaiData,
        FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader) + GaiFrameDataSizeOffset)));
    if not SkipPalettedColorCacheBuild then DecodedFrameGi.BuildPalettedFormat4ColorCache;
  end
  else DecodedFrameGi.LoadRawGiBytes(AddPointerOffset(RawGaiData, Offset),
    ReadDWordEC(AddPointerOffset(RawGaiData,
      FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader) + GaiFrameDataSizeOffset)));
  if not DecodedFrameGi.IsEmpty then Result := DecodedFrameGi;
end;
{ @end $4879C0 }

{ @routine $487AC0 TCGaiEC_IsFrameCompressed }
function TCGaiEC.IsFrameCompressed(FrameIndex: Integer): Boolean;
var Offset: Integer;
begin
  Offset := ReadDWordEC(AddPointerOffset(RawGaiData, FrameIndex * SizeOf(TGaiFrameEntry) + SizeOf(TGaiHeader)));
  if Offset = 0 then Result := False
  else Result := ReadWordEC(AddPointerOffset(RawGaiData, Offset)) = $4C5A;
end;
{ @end $487AC0 }

{ @routine $487B10 TCGaiEC_GetSequenceCount }
function TCGaiEC.GetSequenceCount: Integer;
begin
  if SequenceTableData = nil then Result := 0
  else Result := ReadDWordEC(@SequenceTableData.SequenceCount);
end;
{ @end $487B10 }

{ @routine $487B24 TCGaiEC_GetSequenceFrameCount }
function TCGaiEC.GetSequenceFrameCount(SequenceIndex: Integer): Integer;
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData, ReadGaiSequenceOffset(SequenceTableData, SequenceIndex)));
end;
{ @end $487B24 }

{ @routine $487B64 TCGaiEC_FillSequenceFrameIndexTable }
procedure TCGaiEC.FillSequenceFrameIndexTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer);
var Source: Pointer; Index, Count: Integer;
begin
  Source := AddPointerOffset(SequenceTableData, ReadGaiSequenceOffset(SequenceTableData, SequenceIndex));
  Count := ReadDWordEC(Source);
  Source := AddPointerOffset(Source, SizeOf(TGaiSequenceDataBlock));
  for Index := 0 to Count - 1 do
  begin
    WriteIntegerEC(DestTable, ReadDWordEC(Source));
    DestTable := AddPointerOffset(DestTable, EntryStride);
    Source := AddPointerOffset(Source, SizeOf(TGaiSequenceFrameEntry));
  end;
end;
{ @end $487B64 }

{ @routine $487BF8 TCGaiEC_FillSequenceFrameDelayTable }
procedure TCGaiEC.FillSequenceFrameDelayTable(SequenceIndex: Integer; DestTable: Pointer; EntryStride: Integer);
var Source: Pointer; Index, Count: Integer;
begin
  Source := AddPointerOffset(SequenceTableData, ReadGaiSequenceOffset(SequenceTableData, SequenceIndex));
  Count := ReadDWordEC(Source);
  Source := AddPointerOffset(Source, SizeOf(TGaiSequenceDataBlock) + SizeOf(Integer));
  for Index := 0 to Count - 1 do
  begin
    WriteIntegerEC(DestTable, ReadDWordEC(Source));
    DestTable := AddPointerOffset(DestTable, EntryStride);
    Source := AddPointerOffset(Source, SizeOf(TGaiSequenceFrameEntry));
  end;
end;
{ @end $487BF8 }

{ @routine $487C8C TCGaiEC_GetSequenceFrameIndex }
function TCGaiEC.GetSequenceFrameIndex(SequenceIndex, FrameInSequence: Integer): Integer;
begin
  // SourceFrameIndex is the first field after the block's FrameCount.
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData,
    ReadGaiSequenceOffset(SequenceTableData, SequenceIndex) +
    (FrameInSequence * SizeOf(TGaiSequenceFrameEntry) + SizeOf(TGaiSequenceDataBlock))));
end;
{ @end $487C8C }

{ @routine $487CDC TCGaiEC_GetSequenceFrameDelay }
function TCGaiEC.GetSequenceFrameDelay(SequenceIndex, FrameInSequence: Integer): Integer;
begin
  Result := ReadDWordEC(AddPointerOffset(SequenceTableData,
    ReadGaiSequenceOffset(SequenceTableData, SequenceIndex) +
    (FrameInSequence * SizeOf(TGaiSequenceFrameEntry) + SizeOf(TGaiSequenceDataBlock) + GaiSequenceFrameDelayOffset)));
end;
{ @end $487CDC }

{ @routine $487D30 TCGaiEC_LoadFromConfigBuffer }
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
{ @end $487D30 }

{ @routine $487F78 TCGaiEC_ApplyAB2BackgroundFixup }
procedure TCGaiEC.ApplyAB2BackgroundFixup(SourceBuffer: TBufEC; const ResourceKey: WideString);
var Image: TgiGR; GraphBuf: TGraphBufGR; ByteCount, Offset: Integer; OldHeader: TGaiHeader;

  // @nested $487EC4 LogGaiRescaleStart
  procedure LogGaiRescaleStart; // @addr $487EC4 @calls "0x00487F9E"
  begin
    AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  // @nested $487F60 LogGaiRescaleDone
  procedure LogGaiRescaleDone; // @addr $487F60 @calls "0x0048813C"
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
{ @end $487F78 }

end.
