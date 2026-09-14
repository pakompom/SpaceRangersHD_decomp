unit EC_CachePalBitmap;
// Unit bracket (inferred): .text 0x0047C0F0..0x0047C3A6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, GR_GraphBufPal, EC_Cache, Classes;

type
  TCPalBitmapControlEC = class;
  TCPalBitmapEC = class;

  TCPalBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47C1D0
    function CreateData: TCacheDataEC; override; // @addr 0x47C254
    function AcquireData: TCacheDataEC; override; // @addr 0x47C2A0
  end;

  TCPalBitmapEC = class(TCacheDataEC) // @size 0x24
  public
    Bitmap: TGraphBufPalGR; // @offset 0x20

    constructor Create; // @addr 0x47C2BC @ida "TCPalBitmapEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x47C310 @ida "void __usercall $name(TCPalBitmapEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x47C360
  end;

function AcquireOrCreatePalBitmap(Control: TCacheControlEC): TCPalBitmapEC; // @addr 0x47C274

implementation

uses GR_Main;

{ @routine $47C1D0 TCPalBitmapControlEC_QueueLoadIfMissing }
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
{ @end $47C1D0 }

{ @routine $47C254 TCPalBitmapControlEC_CreateData }
function TCPalBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCPalBitmapEC.Create;
end;
{ @end $47C254 }

{ @routine $47C274 AcquireOrCreatePalBitmap }
function AcquireOrCreatePalBitmap(Control: TCacheControlEC): TCPalBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCPalBitmapEC) as TCPalBitmapEC;
end;
{ @end $47C274 }

{ @routine $47C2A0 TCPalBitmapControlEC_AcquireData }
function TCPalBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreatePalBitmap(Self);
end;
{ @end $47C2A0 }

{ @routine $47C2BC TCPalBitmapEC_Create }
constructor TCPalBitmapEC.Create;
begin
  inherited Create;
  Bitmap := TGraphBufPalGR.Create;
end;
{ @end $47C2BC }

{ @routine $47C310 TCPalBitmapEC_Destroy }
destructor TCPalBitmapEC.Destroy;
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  inherited Destroy;
end;
{ @end $47C310 }

{ @routine $47C360 TCPalBitmapEC_LoadFromConfigBuffer }
procedure TCPalBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  Bitmap.LoadImage(SourceBuffer);
  ResidentBytes := Bitmap.PitchBytes * Bitmap.Height + Bitmap.PaletteCount * SizeOf(Bitmap.Palette^);
end;
{ @end $47C360 }

end.
