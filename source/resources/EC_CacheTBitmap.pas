unit EC_CacheTBitmap;
// Unit bracket (inferred): .text 0x0047D1FC..0x0047D530; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, Classes, EC_Buf, EC_Cache;

type
  TCTBitmapControlEC = class;
  TCTBitmapEC = class;

  TCTBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47D2D4
    function CreateData: TCacheDataEC; override; // @addr 0x47D358
    function AcquireData: TCacheDataEC; override; // @addr 0x47D3A4
  end;
  TCTBitmapEC = class(TCacheDataEC) // @size 0x2C
  public
    TransBuffer: Pointer; // @offset 0x20
    PixelSize: TPoint; // @offset $24  Native controls copy these dimensions as one point.

    constructor Create; // @addr 0x47D3C0 @ida "TCTBitmapEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x47D404 @ida "void __usercall $name(TCTBitmapEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x47D454 @note "Applies LoadOption image operations before building the transparent buffer."
  end;

function AcquireCachedTransBitmap(Control: TCacheControlEC): TCTBitmapEC; // @addr 0x47D378

implementation

uses SysUtils, EC_Str, GR_Main, GR_GraphBuf;

{ @routine $47D2D4 TCTBitmapControlEC_QueueLoadIfMissing }
procedure TCTBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCTBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCTBitmapEC) = nil then
  begin
    Control := TCTBitmapControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $47D2D4 }

{ @routine $47D358 TCTBitmapControlEC_CreateData }
function TCTBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCTBitmapEC.Create;
end;
{ @end $47D358 }

{ @routine $47D378 AcquireCachedTransBitmap }
function AcquireCachedTransBitmap(Control: TCacheControlEC): TCTBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCTBitmapEC) as TCTBitmapEC;
end;
{ @end $47D378 }

{ @routine $47D3A4 TCTBitmapControlEC_AcquireData }
function TCTBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedTransBitmap(Self);
end;
{ @end $47D3A4 }

{ @routine $47D3C0 TCTBitmapEC_Create }
constructor TCTBitmapEC.Create;
begin
  inherited Create;
end;
{ @end $47D3C0 }

{ @routine $47D404 TCTBitmapEC_Destroy }
destructor TCTBitmapEC.Destroy;
begin
  if TransBuffer <> nil then
  begin
    FreeMem(TransBuffer);
    TransBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $47D404 }

{ @routine $47D454 TCTBitmapEC_LoadFromConfigBuffer }
procedure TCTBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var Bitmap: TGraphBufGR; ByteCount: Cardinal;
begin
  Bitmap := TGraphBufGR.Create(False);
  Bitmap.LoadImage(SourceBuffer);
  Bitmap.ApplyOperations(LoadOption);
  ByteCount := Ex_OKGR_TransBuf_Build_WORD(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, nil, 0);
  if ByteCount < 1 then raise Exception.Create('TCTBitmapEC.Load. Error load file.');
  GetMem(TransBuffer, ByteCount);
  Ex_OKGR_TransBuf_Build_WORD(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Width, Bitmap.Height, TransBuffer, 0);
  ResidentBytes := ByteCount;
  PixelSize.X := Bitmap.Width;
  PixelSize.Y := Bitmap.Height;
  Bitmap.Free;
end;
{ @end $47D454 }

end.
