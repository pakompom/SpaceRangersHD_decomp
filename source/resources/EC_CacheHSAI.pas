unit EC_CacheHSAI;
// Unit bracket (inferred): .text 0x004AEF08..0x004AF417; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, Direct3D9;

type
  THSAIHeaderEC = packed record // @size 0x34
    // The leading dword and format metadata at +0x18..+0x2C remain unresolved.
    Width: Integer; // @offset 0x04
    Height: Integer; // @offset 0x08
    PitchBytes: Integer; // @offset 0x0C
    FrameCount: Cardinal; // @offset 0x10
    FrameStride: Cardinal; // @offset 0x14
    PalettePresent: Cardinal; // @offset 0x30
  end;
  PHSAIHeaderEC = ^THSAIHeaderEC;

  TCHSAIControlEC = class;
  TCHSAIEC = class;

  TCHSAIControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4AEFDC
    function CreateData: TCacheDataEC; override; // @addr 0x4AF060
    function AcquireData: TCacheDataEC; override; // @addr 0x4AF0AC
  end;

  TCHSAIEC = class(TCacheDataEC) // @size 0x34
  public
    BlobData: Pointer; // @offset 0x20
    Header: PHSAIHeaderEC; // @offset 0x24
    Width: Integer; // @offset 0x28
    Height: Integer; // @offset 0x2C
    FrameSurfaceCache: TTextureGR; // @offset 0x30

    constructor Create; // @addr 0x4AF0C8 @ida "TCHSAIEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x4AF114 @ida "void __usercall $name(TCHSAIEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function GetFrameCount: Cardinal; // @addr 0x4AF180
    function GetFrameIndexPlane(FrameIndex: Cardinal): Pointer; // @addr 0x4AF19C @note "Returns nil when FrameIndex is outside the header count."
    function GetFramePalette(FrameIndex: Cardinal): PColorRGBA; // @addr 0x4AF1E8 @note "Returns nil for an invalid frame or absent palette."
    function GetOrCreateFrameSurface(FrameIndex: Cardinal): IDirect3DTexture9; // @addr 0x4AF25C @ida "void __usercall $name(TCHSAIEC *Self@<eax>, unsigned int FrameIndex@<edx>, IDirect3DTexture9 **Result@<ecx>);" @note "Requires a valid frame and palette; uses Width rather than PitchBytes as the source pitch."
    function GetSourcePitchBytes: Integer; // @addr 0x4AF36C
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x4AF388 @note "Only the minimum 0x34-byte header size is validated. Ignores LoadOption."
  end;

function AcquireCachedHSAI(Control: TCacheControlEC): TCHSAIEC; // @addr 0x4AF080

implementation

uses SysUtils, EC_Mem, GR_Main, Windows;

{ @routine $4AEFDC TCHSAIControlEC_QueueLoadIfMissing }
procedure TCHSAIControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCHSAIControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCHSAIEC) = nil then
  begin
    Control := TCHSAIControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $4AEFDC }

{ @routine $4AF060 TCHSAIControlEC_CreateData }
function TCHSAIControlEC.CreateData: TCacheDataEC;
begin
  Result := TCHSAIEC.Create;
end;
{ @end $4AF060 }

{ @routine $4AF080 AcquireCachedHSAI }
function AcquireCachedHSAI(Control: TCacheControlEC): TCHSAIEC;
begin
  Result := Control.AcquireDataFromConfig(TCHSAIEC) as TCHSAIEC;
end;
{ @end $4AF080 }

{ @routine $4AF0AC TCHSAIControlEC_AcquireData }
function TCHSAIControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedHSAI(Self);
end;
{ @end $4AF0AC }

{ @routine $4AF0C8 TCHSAIEC_Create }
constructor TCHSAIEC.Create;
begin
  FrameSurfaceCache := nil;
  inherited Create;
end;
{ @end $4AF0C8 }

{ @routine $4AF114 TCHSAIEC_Destroy }
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
{ @end $4AF114 }

{ @routine $4AF180 TCHSAIEC_GetFrameCount }
function TCHSAIEC.GetFrameCount: Cardinal;
begin
  Result := Header.FrameCount;
end;
{ @end $4AF180 }

{ @routine $4AF19C TCHSAIEC_GetFrameIndexPlane }
function TCHSAIEC.GetFrameIndexPlane(FrameIndex: Cardinal): Pointer;
begin
  if FrameIndex >= Header.FrameCount then Result := nil
  else Result := AddPointerOffset(BlobData, SizeOf(THSAIHeaderEC) + FrameIndex * Header.FrameStride);
end;
{ @end $4AF19C }

{ @routine $4AF1E8 TCHSAIEC_GetFramePalette }
function TCHSAIEC.GetFramePalette(FrameIndex: Cardinal): PColorRGBA;
begin
  if FrameIndex >= Header.FrameCount then Result := nil
  else if Header.PalettePresent = 0 then Result := nil
  else Result := AddPointerOffset(BlobData, SizeOf(THSAIHeaderEC) + FrameIndex * Header.FrameStride + Header.PitchBytes * Header.Height);
end;
{ @end $4AF1E8 }

{ @routine $4AF25C TCHSAIEC_GetOrCreateFrameSurface }
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
{ @end $4AF25C }

{ @routine $4AF36C TCHSAIEC_GetSourcePitchBytes }
function TCHSAIEC.GetSourcePitchBytes: Integer;
begin
  Result := Header.PitchBytes;
end;
{ @end $4AF36C }

{ @routine $4AF388 TCHSAIEC_LoadFromConfigBuffer }
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
{ @end $4AF388 }

end.
