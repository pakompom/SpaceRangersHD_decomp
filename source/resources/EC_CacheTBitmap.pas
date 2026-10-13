unit EC_CacheTBitmap;

interface

uses Types, Classes, EC_Buf, EC_Cache;

type
  TCTBitmapControlEC = class;
  TCTBitmapEC = class;

  TCTBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x0048B9D0
    function CreateData: TCacheDataEC; override; // @addr 0x0048BA3C
    function AcquireData: TCacheDataEC; override; // @addr 0x0048BA6C
  end;
  TCTBitmapEC = class(TCacheDataEC) // @size 0x2C
  public
    TransBuffer: Pointer; // @offset 0x20
    PixelSize: TPoint; // @offset $24  Native controls copy these dimensions as one point.

    constructor Create; // @addr 0x0048BA74
    destructor Destroy; override; // @addr 0x0048BAAC
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x0048BAE4 @note "Applies LoadOption image operations before building the transparent buffer."
  end;

function AcquireCachedTransBitmap(Control: TCacheControlEC): TCTBitmapEC; // @addr 0x0048BA4C

implementation

uses SysUtils, EC_Str, GR_Main, GR_GraphBuf;

{ @routine $48B9D0 TCTBitmapControlEC_QueueLoadIfMissing }
procedure TCTBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCTBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCTBitmapEC) <> nil then Exit;
  Control := TCTBitmapControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $48B9D0 }

{ @routine $48BA3C TCTBitmapControlEC_CreateData }
function TCTBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCTBitmapEC.Create;
end;
{ @end $48BA3C }

{ @routine $48BA4C AcquireCachedTransBitmap }
function AcquireCachedTransBitmap(Control: TCacheControlEC): TCTBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCTBitmapEC) as TCTBitmapEC;
end;
{ @end $48BA4C }

{ @routine $48BA6C TCTBitmapControlEC_AcquireData }
function TCTBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedTransBitmap(Self);
end;
{ @end $48BA6C }

{ @routine $48BA74 TCTBitmapEC_Create }
constructor TCTBitmapEC.Create;
begin
  inherited Create;
end;
{ @end $48BA74 }

{ @routine $48BAAC TCTBitmapEC_Destroy }
destructor TCTBitmapEC.Destroy;
begin
  if TransBuffer <> nil then
  begin
    FreeMem(TransBuffer);
    TransBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $48BAAC }

{ @routine $48BAE4 TCTBitmapEC_LoadFromConfigBuffer }
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
{ @end $48BAE4 }

end.
