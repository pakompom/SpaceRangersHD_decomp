unit EC_CachePalBitmap;

interface

uses EC_Buf, GR_GraphBufPal, EC_Cache, Classes;

type
  TCPalBitmapControlEC = class;
  TCPalBitmapEC = class;

  TCPalBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x0048AB6C
    function CreateData: TCacheDataEC; override; // @addr 0x0048ABD8
    function AcquireData: TCacheDataEC; override; // @addr 0x0048AC08
  end;

  TCPalBitmapEC = class(TCacheDataEC) // @size 0x24
  public
    Bitmap: TGraphBufPalGR; // @offset 0x20

    constructor Create; // @addr 0x0048AC10
    destructor Destroy; override; // @addr 0x0048AC54
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x0048AC8C
  end;

function AcquireOrCreatePalBitmap(Control: TCacheControlEC): TCPalBitmapEC; // @addr 0x0048ABE8

implementation

uses GR_Main;

{ @routine $48AB6C TCPalBitmapControlEC_QueueLoadIfMissing }
procedure TCPalBitmapControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCPalBitmapControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCPalBitmapEC) <> nil then Exit;
  Control := TCPalBitmapControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $48AB6C }

{ @routine $48ABD8 TCPalBitmapControlEC_CreateData }
function TCPalBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCPalBitmapEC.Create;
end;
{ @end $48ABD8 }

{ @routine $48ABE8 AcquireOrCreatePalBitmap }
function AcquireOrCreatePalBitmap(Control: TCacheControlEC): TCPalBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCPalBitmapEC) as TCPalBitmapEC;
end;
{ @end $48ABE8 }

{ @routine $48AC08 TCPalBitmapControlEC_AcquireData }
function TCPalBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreatePalBitmap(Self);
end;
{ @end $48AC08 }

{ @routine $48AC10 TCPalBitmapEC_Create }
constructor TCPalBitmapEC.Create;
begin
  inherited Create;
  Bitmap := TGraphBufPalGR.Create;
end;
{ @end $48AC10 }

{ @routine $48AC54 TCPalBitmapEC_Destroy }
destructor TCPalBitmapEC.Destroy;
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  inherited Destroy;
end;
{ @end $48AC54 }

{ @routine $48AC8C TCPalBitmapEC_LoadFromConfigBuffer }
procedure TCPalBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  Bitmap.LoadImage(SourceBuffer);
  ResidentBytes := Bitmap.PitchBytes * Bitmap.Height + Bitmap.PaletteCount * SizeOf(Bitmap.Palette^);
end;
{ @end $48AC8C }

end.
