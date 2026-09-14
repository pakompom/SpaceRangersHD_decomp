unit EC_CacheAlphaBitmap;
// Unit bracket (inferred): .text 0x00487BC4..0x00488264; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, Classes, EC_Buf, EC_Cache, GR_DX, GR_GraphBuf, Direct3D9;

type
  TCAlphaBitmapControlEC = class;
  TCAlphaBitmapEC = class;

  TCAlphaBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x487CA4
    function CreateData: TCacheDataEC; override; // @addr 0x487D28
    function AcquireData: TCacheDataEC; override; // @addr 0x487D74
  end;

  TCAlphaBitmapEC = class(TCacheDataEC) // @size 0x38
  public
    TransBuf16: Pointer; // @offset 0x20
    TransAlphaBuf16: Pointer; // @offset 0x24
    AlphaBuf: Pointer; // @offset 0x28
    PixelSize: TPoint; // @offset $2C  Native controls copy these dimensions as one point.
    SurfaceCache: TTextureGR; // @offset 0x34

    procedure Draw16(Dest: Pointer; Pitch, X, Y: Integer; Clip: TRect); // @addr $488084 @ida "void __userpurge $name(TCAlphaBitmapEC *Self@<eax>, void *Dest@<edx>, int Pitch@<ecx>, int X@<^8>, int Y@<^4>, TRect *Clip@<^0>);"
    procedure DecodeToGraphBuf(Buffer: TGraphBufGR); // @addr $488118
    function GetTexture: IDirect3DTexture9; // @addr $488190 @ida "void __usercall $name(TCAlphaBitmapEC *Self@<eax>, IDirect3DTexture9 **Result@<edx>);"
    constructor Create; // @addr 0x487D90 @ida "TCAlphaBitmapEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x487DDC @ida "void __usercall $name(TCAlphaBitmapEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x487E80
  end;

function AcquireOrCreateAlphaBitmap(Control: TCacheControlEC): TCAlphaBitmapEC; // @addr 0x487D48

implementation

uses SysUtils, EC_Mem, GR_Main, Windows;

{ @routine $487CA4 TCAlphaBitmapControlEC_QueueLoadIfMissing }
procedure TCAlphaBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCAlphaBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCAlphaBitmapEC) = nil then
  begin
    Control := TCAlphaBitmapControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $487CA4 }

{ @routine $487D28 TCAlphaBitmapControlEC_CreateData }
function TCAlphaBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCAlphaBitmapEC.Create;
end;
{ @end $487D28 }

{ @routine $487D48 AcquireOrCreateAlphaBitmap }
function AcquireOrCreateAlphaBitmap(Control: TCacheControlEC): TCAlphaBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCAlphaBitmapEC) as TCAlphaBitmapEC;
end;
{ @end $487D48 }

{ @routine $487D74 TCAlphaBitmapControlEC_AcquireData }
function TCAlphaBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateAlphaBitmap(Self);
end;
{ @end $487D74 }

{ @routine $487D90 TCAlphaBitmapEC_Create }
constructor TCAlphaBitmapEC.Create;
begin
  SurfaceCache := nil;
  inherited Create;
end;
{ @end $487D90 }

{ @routine $487DDC TCAlphaBitmapEC_Destroy }
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
{ @end $487DDC }

{ @routine $487E80 TCAlphaBitmapEC_LoadFromConfigBuffer }
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
{ @end $487E80 }

{ @routine $488084 TCAlphaBitmapEC_Draw16 }
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
{ @end $488084 }

{ @routine $488118 TCAlphaBitmapEC_DecodeToGraphBuf }
procedure TCAlphaBitmapEC.DecodeToGraphBuf(Buffer: TGraphBufGR);
begin
  Buffer.AllocateRgbaTight(PixelSize.X, PixelSize.Y);
  Buffer.ClearPixels;
  Ex_OKGR_AlphaBuf_Draw_RGBA(Buffer.GetPixels, Buffer.PitchBytes, AlphaBuf);
  Ex_OKGR_TransAlphaBuf_Draw_RGBA(Buffer.GetPixels, Buffer.PitchBytes, TransAlphaBuf16);
  Ex_OKGR_TransBuf_Draw_RGBA(Buffer.GetPixels, Buffer.PitchBytes, TransBuf16);
end;
{ @end $488118 }

{ @routine $488190 TCAlphaBitmapEC_GetTexture }
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
{ @end $488190 }

end.
