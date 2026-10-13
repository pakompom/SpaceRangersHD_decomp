unit EC_CacheAlphaBitmap;

interface

uses Types, Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, Direct3D9;

type
  TCAlphaBitmapControlEC = class;
  TCAlphaBitmapEC = class;

  TCAlphaBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x00494994
    function CreateData: TCacheDataEC; override; // @addr 0x00494A00
    function AcquireData: TCacheDataEC; override; // @addr 0x00494A30
  end;

  TCAlphaBitmapEC = class(TCacheDataEC) // @size 0x38
  public
    TransBuf16: Pointer; // @offset 0x20
    TransAlphaBuf16: Pointer; // @offset 0x24
    AlphaBuf: Pointer; // @offset 0x28
    PixelSize: TPoint; // @offset $2C  Native controls copy these dimensions as one point.
    SurfaceCache: TTextureGR; // @offset 0x34

    procedure Draw16(Dest: Pointer; Pitch, X, Y: Integer; Clip: TRect); // @addr $494C60
    procedure DecodeToGraphBuf(Buffer: TGraphBufGR); // @addr $494CE4
    function GetTexture: IDirect3DTexture9; // @addr $494D38
    constructor Create; // @addr 0x00494A38
    destructor Destroy; override; // @addr 0x00494A74
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x00494AE0
  end;

function AcquireOrCreateAlphaBitmap(Control: TCacheControlEC): TCAlphaBitmapEC; // @addr 0x00494A10

implementation

uses SysUtils, EC_Mem, GR_Main, Windows;

{ @routine $494994 TCAlphaBitmapControlEC_QueueLoadIfMissing }
procedure TCAlphaBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCAlphaBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCAlphaBitmapEC) <> nil then Exit;
  Control := TCAlphaBitmapControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $494994 }

{ @routine $494A00 TCAlphaBitmapControlEC_CreateData }
function TCAlphaBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCAlphaBitmapEC.Create;
end;
{ @end $494A00 }

{ @routine $494A10 AcquireOrCreateAlphaBitmap }
function AcquireOrCreateAlphaBitmap(Control: TCacheControlEC): TCAlphaBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCAlphaBitmapEC) as TCAlphaBitmapEC;
end;
{ @end $494A10 }

{ @routine $494A30 TCAlphaBitmapControlEC_AcquireData }
function TCAlphaBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateAlphaBitmap(Self);
end;
{ @end $494A30 }

{ @routine $494A38 TCAlphaBitmapEC_Create }
constructor TCAlphaBitmapEC.Create;
begin
  SurfaceCache := nil;
  inherited Create;
end;
{ @end $494A38 }

{ @routine $494A74 TCAlphaBitmapEC_Destroy }
destructor TCAlphaBitmapEC.Destroy;
begin
  if TransBuf16 <> nil then
  begin
    FreeEC(TransBuf16);
    TransBuf16 := nil;
  end;
  if TransAlphaBuf16 <> nil then
  begin
    FreeEC(TransAlphaBuf16);
    TransAlphaBuf16 := nil;
  end;
  if AlphaBuf <> nil then
  begin
    FreeEC(AlphaBuf);
    AlphaBuf := nil;
  end;
  if SurfaceCache <> nil then
  begin
    FreeTextureCache(SurfaceCache);
    SurfaceCache := nil;
  end;
  inherited Destroy;
end;
{ @end $494A74 }

{ @routine $494AE0 TCAlphaBitmapEC_LoadFromConfigBuffer }
procedure TCAlphaBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var Bitmap: TGraphBufGR; ByteCount: Cardinal;
begin
  Bitmap := TGraphBufGR.Create(False);
  Bitmap.LoadImageRgba(SourceBuffer);
  ResidentBytes := 0;
  ByteCount := Ex_OKGR_TransBuf_BuildFromRGBA_16(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, nil);
  if ByteCount < 1 then raise Exception.Create('TCAlphaBitmapEC.Load. Error load file.');
  TransBuf16 := AllocEC(ByteCount);
  Ex_OKGR_TransBuf_BuildFromRGBA_16(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, TransBuf16);
  Inc(ResidentBytes, ByteCount);
  ByteCount := Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, nil);
  if ByteCount < 1 then raise Exception.Create('TCAlphaBitmapEC.Load. Error load file.');
  TransAlphaBuf16 := AllocEC(ByteCount);
  Ex_OKGR_TransAlphaBuf_BuildFromRGBA_16(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, TransAlphaBuf16);
  Inc(ResidentBytes, ByteCount);
  ByteCount := Ex_OKGR_AlphaBuf_BuildFromRGBA(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, nil);
  if ByteCount < 1 then raise Exception.Create('TCAlphaBitmapEC.Load. Error load file.');
  AlphaBuf := AllocEC(ByteCount);
  Ex_OKGR_AlphaBuf_BuildFromRGBA(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, AlphaBuf);
  Inc(ResidentBytes, ByteCount);
  PixelSize.X := Bitmap.Width;
  PixelSize.Y := Bitmap.Height;
  Bitmap.Free;
end;
{ @end $494AE0 }

{ @routine $494C60 TCAlphaBitmapEC_Draw16 }
procedure TCAlphaBitmapEC.Draw16(Dest: Pointer; Pitch, X, Y: Integer; Clip: TRect);
var InclusiveClip: TRect;
begin
  InclusiveClip.Left := Clip.Left;
  InclusiveClip.Top := Clip.Top;
  InclusiveClip.Right := Clip.Right - 1;
  InclusiveClip.Bottom := Clip.Bottom - 1;
  Ex_OKGR_AlphaBuf_DrawClip_16(Dest, Pitch, X, Y, AlphaBuf, InclusiveClip);
  Ex_OKGR_TransAlphaBuf_DrawClip_WORD(Dest, Pitch, X, Y, TransAlphaBuf16, InclusiveClip);
  Ex_OKGR_TransBuf_DrawClip_WORD(Dest, Pitch, X, Y, TransBuf16, InclusiveClip);
end;
{ @end $494C60 }

{ @routine $494CE4 TCAlphaBitmapEC_DecodeToGraphBuf }
procedure TCAlphaBitmapEC.DecodeToGraphBuf(Buffer: TGraphBufGR);
begin
  Buffer.AllocateRgbaTight(PixelSize.X, PixelSize.Y);
  Buffer.ClearPixels;
  Ex_OKGR_AlphaBuf_Draw_RGBA(Buffer.GetPixels, Buffer.PitchBytes, AlphaBuf);
  Ex_OKGR_TransAlphaBuf_Draw_RGBA(Buffer.GetPixels, Buffer.PitchBytes, TransAlphaBuf16);
  Ex_OKGR_TransBuf_Draw_RGBA(Buffer.GetPixels, Buffer.PitchBytes, TransBuf16);
end;
{ @end $494CE4 }

{ @routine $494D38 TCAlphaBitmapEC_GetTexture }
function TCAlphaBitmapEC.GetTexture: IDirect3DTexture9;
var Buffer: TGraphBufGR; Texture: IDirect3DTexture9;
begin
  if SurfaceCache = nil then SurfaceCache := CreateTextureCache;
  Texture := SurfaceCache.GetSurface(0);
  if Texture = nil then
  begin
    Buffer := TGraphBufGR.Create(False);
    DecodeToGraphBuf(Buffer);
    Texture := CreateTextureFromPixels(Buffer.Width, Buffer.Height, 21, Buffer.GetPixels, Buffer.PitchBytes, 1);
    Buffer.Free;
    SurfaceCache.SetSurface(Texture, 0);
  end;
  Result := Texture;
end;
{ @end $494D38 }

end.
