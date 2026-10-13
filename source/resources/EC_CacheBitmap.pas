unit EC_CacheBitmap;

interface

uses Classes, EC_Buf, EC_Cache, GR_GraphBuf;

const
  // Cache paths pass the option after '?' to LoadFromConfigBuffer.
  RgbaImagePathSuffix = '?RGBA';

type
  TCBitmapControlEC = class;
  TCBitmapEC = class;

  TCBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x0048BC8C
    function CreateData: TCacheDataEC; override; // @addr 0x0048BCF8
    function AcquireData: TCacheDataEC; override; // @addr 0x0048BD28
  end;

  TCBitmapEC = class(TCacheDataEC) // @size 0x24
  public
    Bitmap: TGraphBufGR; // @offset 0x20

    constructor Create; // @addr 0x0048BD30
    destructor Destroy; override; // @addr 0x0048BD78
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x0048BDB0 @note "LoadOption accepts RGBA, Gray and RGB; other values select default decoding."
  end;

function AcquireOrCreateBitmap(Control: TCacheControlEC): TCBitmapEC; // @addr 0x0048BD08

implementation

uses GR_Main;

{ @routine $48BC8C TCBitmapControlEC_QueueLoadIfMissing }
procedure TCBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCBitmapEC) <> nil then Exit;
  Control := TCBitmapControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $48BC8C }

{ @routine $48BCF8 TCBitmapControlEC_CreateData }
function TCBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCBitmapEC.Create;
end;
{ @end $48BCF8 }

{ @routine $48BD08 AcquireOrCreateBitmap }
function AcquireOrCreateBitmap(Control: TCacheControlEC): TCBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCBitmapEC) as TCBitmapEC;
end;
{ @end $48BD08 }

{ @routine $48BD28 TCBitmapControlEC_AcquireData }
function TCBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateBitmap(Self);
end;
{ @end $48BD28 }

{ @routine $48BD30 TCBitmapEC_Create }
constructor TCBitmapEC.Create;
begin
  inherited Create;
  Bitmap := TGraphBufGR.Create(False);
end;
{ @end $48BD30 }

{ @routine $48BD78 TCBitmapEC_Destroy }
destructor TCBitmapEC.Destroy;
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  inherited Destroy;
end;
{ @end $48BD78 }

{ @routine $48BDB0 TCBitmapEC_LoadFromConfigBuffer }
procedure TCBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  if LoadOption = 'RGBA' then Bitmap.LoadImageRgba(SourceBuffer)
  else if LoadOption = 'Gray' then Bitmap.LoadImageGrayscale(SourceBuffer)
  else if LoadOption = 'RGB' then Bitmap.LoadImageRgb(SourceBuffer)
  else Bitmap.LoadImage(SourceBuffer);
  ResidentBytes := Bitmap.PitchBytes * Bitmap.Height;
end;
{ @end $48BDB0 }

end.
