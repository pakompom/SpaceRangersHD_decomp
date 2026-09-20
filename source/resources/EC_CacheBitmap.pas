unit EC_CacheBitmap;
// Unit bracket (inferred): .text 0x0083D9B0..0x0083DCB1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_GraphBuf;

type
  TCBitmapControlEC = class;
  TCBitmapEC = class;

  TCBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x83DA88
    function CreateData: TCacheDataEC; override; // @addr 0x83DB0C
    function AcquireData: TCacheDataEC; override; // @addr 0x83DB58
  end;

  TCBitmapEC = class(TCacheDataEC) // @size 0x24
  public
    Bitmap: TGraphBufGR; // @offset 0x20

    constructor Create; // @addr 0x83DB74
    destructor Destroy; override; // @addr 0x83DBCC
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x83DC1C @note "LoadOption accepts RGBA, Gray and RGB; other values select default decoding."
  end;

function AcquireOrCreateBitmap(Control: TCacheControlEC): TCBitmapEC; // @addr 0x83DB2C

implementation

uses GR_Main;

{ @routine $83DA88 TCBitmapControlEC_QueueLoadIfMissing }
procedure TCBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCBitmapEC) = nil then
  begin
    Control := TCBitmapControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $83DA88 }

{ @routine $83DB0C TCBitmapControlEC_CreateData }
function TCBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCBitmapEC.Create;
end;
{ @end $83DB0C }

{ @routine $83DB2C AcquireOrCreateBitmap }
function AcquireOrCreateBitmap(Control: TCacheControlEC): TCBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCBitmapEC) as TCBitmapEC;
end;
{ @end $83DB2C }

{ @routine $83DB58 TCBitmapControlEC_AcquireData }
function TCBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateBitmap(Self);
end;
{ @end $83DB58 }

{ @routine $83DB74 TCBitmapEC_Create }
constructor TCBitmapEC.Create;
begin
  inherited Create;
  Bitmap := TGraphBufGR.Create(False);
end;
{ @end $83DB74 }

{ @routine $83DBCC TCBitmapEC_Destroy }
destructor TCBitmapEC.Destroy;
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  inherited Destroy;
end;
{ @end $83DBCC }

{ @routine $83DC1C TCBitmapEC_LoadFromConfigBuffer }
procedure TCBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  if LoadOption = 'RGBA' then Bitmap.LoadImageRgba(SourceBuffer)
  else if LoadOption = 'Gray' then Bitmap.LoadImageGrayscale(SourceBuffer)
  else if LoadOption = 'RGB' then Bitmap.LoadImageRgb(SourceBuffer)
  else Bitmap.LoadImage(SourceBuffer);
  ResidentBytes := Bitmap.PitchBytes * Bitmap.Height;
end;
{ @end $83DC1C }

end.
