unit EC_CachePalBitmap;
// Unit bracket (inferred): .text 0x00493254..0x0049350A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, GR_GraphBufPal, EC_Cache, Classes;

type
  TCPalBitmapControlEC = class;
  TCPalBitmapEC = class;

  TCPalBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x493334
    function CreateData: TCacheDataEC; override; // @addr 0x4933B8
    function AcquireData: TCacheDataEC; override; // @addr 0x493404
  end;

  TCPalBitmapEC = class(TCacheDataEC) // @size 0x24
  public
    Bitmap: TGraphBufPalGR; // @offset 0x20

    constructor Create; // @addr 0x493420
    destructor Destroy; override; // @addr 0x493474
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x4934C4
  end;

function AcquireOrCreatePalBitmap(Control: TCacheControlEC): TCPalBitmapEC; // @addr 0x4933D8

implementation

uses GR_Main;

{ @routine $493334 TCPalBitmapControlEC_QueueLoadIfMissing }
procedure TCPalBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCPalBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCPalBitmapEC) = nil then
  begin
    Control := TCPalBitmapControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $493334 }

{ @routine $4933B8 TCPalBitmapControlEC_CreateData }
function TCPalBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCPalBitmapEC.Create;
end;
{ @end $4933B8 }

{ @routine $4933D8 AcquireOrCreatePalBitmap }
function AcquireOrCreatePalBitmap(Control: TCacheControlEC): TCPalBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCPalBitmapEC) as TCPalBitmapEC;
end;
{ @end $4933D8 }

{ @routine $493404 TCPalBitmapControlEC_AcquireData }
function TCPalBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreatePalBitmap(Self);
end;
{ @end $493404 }

{ @routine $493420 TCPalBitmapEC_Create }
constructor TCPalBitmapEC.Create;
begin
  inherited Create;
  Bitmap := TGraphBufPalGR.Create;
end;
{ @end $493420 }

{ @routine $493474 TCPalBitmapEC_Destroy }
destructor TCPalBitmapEC.Destroy;
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  inherited Destroy;
end;
{ @end $493474 }

{ @routine $4934C4 TCPalBitmapEC_LoadFromConfigBuffer }
procedure TCPalBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  Bitmap.LoadImage(SourceBuffer);
  ResidentBytes := Bitmap.PitchBytes * Bitmap.Height + Bitmap.PaletteCount * SizeOf(Bitmap.Palette^);
end;
{ @end $4934C4 }

end.
