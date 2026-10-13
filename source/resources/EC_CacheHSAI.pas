unit EC_CacheHSAI;

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, Direct3D9;

type
  THSAIHeaderEC = packed record // @size 0x34
    // HSAI/HAI disk header shared with OKGF; indexed ship frames use 1024 palette bytes.
    Magic: Cardinal; // @offset 0x00 $04210420.
    Width: Integer; // @offset 0x04
    Height: Integer; // @offset 0x08
    PitchBytes: Integer; // @offset 0x0C
    FrameCount: Cardinal; // @offset 0x10
    FrameStride: Cardinal; // @offset 0x14
    HasPalette: Cardinal; // @offset 0x18
    BitsPerPixel: Cardinal; // @offset 0x1C
    RedMask: Cardinal; // @offset 0x20
    GreenMask: Cardinal; // @offset 0x24
    BlueMask: Cardinal; // @offset 0x28
    AlphaMask: Cardinal; // @offset 0x2C
    PaletteBytes: Cardinal; // @offset 0x30 Byte count, tested for zero by GetFramePalette.
  end;
  PHSAIHeaderEC = ^THSAIHeaderEC;

  TCHSAIControlEC = class;
  TCHSAIEC = class;

  TCHSAIControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x004B8600
    function CreateData: TCacheDataEC; override; // @addr 0x004B866C
    function AcquireData: TCacheDataEC; override; // @addr 0x004B869C
  end;

  TCHSAIEC = class(TCacheDataEC) // @size 0x34
  public
    BlobData: Pointer; // @offset 0x20
    Header: PHSAIHeaderEC; // @offset 0x24
    Width: Integer; // @offset 0x28
    Height: Integer; // @offset 0x2C
    FrameSurfaceCache: TTextureGR; // @offset 0x30

    constructor Create; // @addr 0x004B86A4
    destructor Destroy; override; // @addr 0x004B86E0
    function GetFrameCount: Cardinal; // @addr 0x004B8728
    function GetFrameIndexPlane(FrameIndex: Integer): Pointer; // @addr 0x004B8730 @note "Returns nil when FrameIndex is outside the header count."
    function GetFramePalette(FrameIndex: Integer): PColorRGBA; // @addr 0x004B875C @note "Returns nil for an invalid frame or absent palette."
    function GetOrCreateFrameSurface(FrameIndex: Cardinal): IDirect3DTexture9; // @addr 0x004B879C @note "Requires a valid frame and palette; uses Width rather than PitchBytes as the source pitch."
    function GetSourcePitchBytes: Integer; // @addr 0x004B8884
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x004B888C @note "Only the minimum 0x34-byte header size is validated. Ignores LoadOption."
  end;

function AcquireCachedHSAI(Control: TCacheControlEC): TCHSAIEC; // @addr 0x004B867C

implementation

uses SysUtils, EC_Mem, GR_Main, Windows;

{ @routine $4B8600 TCHSAIControlEC_QueueLoadIfMissing }
procedure TCHSAIControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCHSAIControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCHSAIEC) <> nil then Exit;
  Control := TCHSAIControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $4B8600 }

{ @routine $4B866C TCHSAIControlEC_CreateData }
function TCHSAIControlEC.CreateData: TCacheDataEC;
begin
  Result := TCHSAIEC.Create;
end;
{ @end $4B866C }

{ @routine $4B867C AcquireCachedHSAI }
function AcquireCachedHSAI(Control: TCacheControlEC): TCHSAIEC;
begin
  Result := Control.AcquireDataFromConfig(TCHSAIEC) as TCHSAIEC;
end;
{ @end $4B867C }

{ @routine $4B869C TCHSAIControlEC_AcquireData }
function TCHSAIControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedHSAI(Self);
end;
{ @end $4B869C }

{ @routine $4B86A4 TCHSAIEC_Create }
constructor TCHSAIEC.Create;
begin
  FrameSurfaceCache := nil;
  inherited Create;
end;
{ @end $4B86A4 }

{ @routine $4B86E0 TCHSAIEC_Destroy }
destructor TCHSAIEC.Destroy;
begin
  if BlobData <> nil then
  begin
    FreeEC(BlobData);
    BlobData := nil;
  end;
  if FrameSurfaceCache <> nil then
  begin
    FreeTextureCache(FrameSurfaceCache);
    FrameSurfaceCache := nil;
  end;
  inherited Destroy;
end;
{ @end $4B86E0 }

{ @routine $4B8728 TCHSAIEC_GetFrameCount }
function TCHSAIEC.GetFrameCount: Cardinal;
begin
  Result := Header.FrameCount;
end;
{ @end $4B8728 }

{ @routine $4B8730 TCHSAIEC_GetFrameIndexPlane }
function TCHSAIEC.GetFrameIndexPlane(FrameIndex: Integer): Pointer;
begin
  if Header.FrameCount <= Cardinal(FrameIndex) then Result := nil
  else Result := AddPointerOffset(BlobData, SizeOf(THSAIHeaderEC) + Cardinal(FrameIndex) * Header.FrameStride);
end;
{ @end $4B8730 }

{ @routine $4B875C TCHSAIEC_GetFramePalette }
function TCHSAIEC.GetFramePalette(FrameIndex: Integer): PColorRGBA;
begin
  if Header.FrameCount <= Cardinal(FrameIndex) then Result := nil
  else if Header.PaletteBytes = 0 then Result := nil
  else Result := AddPointerOffset(BlobData, SizeOf(THSAIHeaderEC) + Cardinal(FrameIndex) * Header.FrameStride + Header.PitchBytes * Header.Height);
end;
{ @end $4B875C }

{ @routine $4B879C TCHSAIEC_GetOrCreateFrameSurface }
function TCHSAIEC.GetOrCreateFrameSurface(FrameIndex: Cardinal): IDirect3DTexture9;
var Texture: IDirect3DTexture9; Locked: TD3DLockedRect;
begin
  if FrameSurfaceCache = nil then FrameSurfaceCache := CreateTextureCache;
  Texture := FrameSurfaceCache.GetSurface(FrameIndex);
  if Texture = nil then
  begin
    Texture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    if Texture <> nil then
    begin
      Texture.LockRect(0, Locked, nil, 0);
      if Locked.Bits <> nil then
      begin
        ExpandPaletteToBgra(Locked.Bits, Locked.Pitch, Width, Height, GetFrameIndexPlane(FrameIndex), Width, GetFramePalette(FrameIndex));
        Texture.UnlockRect(0);
      end;
    end;
    FrameSurfaceCache.SetSurface(Texture, FrameIndex);
  end;
  Result := Texture;
end;
{ @end $4B879C }

{ @routine $4B8884 TCHSAIEC_GetSourcePitchBytes }
function TCHSAIEC.GetSourcePitchBytes: Integer;
begin
  Result := Header.PitchBytes;
end;
{ @end $4B8884 }

{ @routine $4B888C TCHSAIEC_LoadFromConfigBuffer }
procedure TCHSAIEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  if SourceBuffer.DataSize < SizeOf(THSAIHeaderEC) then raise Exception.Create('Error Load HSAI');
  BlobData := AllocEC(SourceBuffer.DataSize);
  CopyMemory(BlobData, SourceBuffer.Data, SourceBuffer.DataSize);
  ResidentBytes := SourceBuffer.DataSize;
  Header := BlobData;
  Width := Header.Width;
  Height := Header.Height;
end;
{ @end $4B888C }

end.
