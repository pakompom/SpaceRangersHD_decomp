unit EC_CacheBitmap;
// Unit bracket (inferred): .text 0x0047D560..0x0047D861; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Cache, GR_GraphBuf;

type
  TCBitmapControlEC = class;
  TCBitmapEC = class;

  TCBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47D638
    function CreateData: TCacheDataEC; override; // @addr 0x47D6BC
    function AcquireData: TCacheDataEC; override; // @addr 0x47D708
  end;

  TCBitmapEC = class(TCacheDataEC) // @size 0x24
  public
    Bitmap: TGraphBufGR; // @offset 0x20

    constructor Create; // @addr 0x47D724 @ida "TCBitmapEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x47D77C @ida "void __usercall $name(TCBitmapEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x47D7CC @note "LoadOption accepts RGBA, Gray and RGB; other values select default decoding."
  end;

function AcquireOrCreateBitmap(Control: TCacheControlEC): TCBitmapEC; // @addr 0x47D6DC

implementation

uses GR_Main;

{ @routine $47D638 TCBitmapControlEC_QueueLoadIfMissing }
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
{ @end $47D638 }

{ @routine $47D6BC TCBitmapControlEC_CreateData }
function TCBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCBitmapEC.Create;
end;
{ @end $47D6BC }

{ @routine $47D6DC AcquireOrCreateBitmap }
function AcquireOrCreateBitmap(Control: TCacheControlEC): TCBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCBitmapEC) as TCBitmapEC;
end;
{ @end $47D6DC }

{ @routine $47D708 TCBitmapControlEC_AcquireData }
function TCBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateBitmap(Self);
end;
{ @end $47D708 }

{ @routine $47D724 TCBitmapEC_Create }
constructor TCBitmapEC.Create;
begin
  inherited Create;
  Bitmap := TGraphBufGR.Create(False);
end;
{ @end $47D724 }

{ @routine $47D77C TCBitmapEC_Destroy }
destructor TCBitmapEC.Destroy;
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  inherited Destroy;
end;
{ @end $47D77C }

{ @routine $47D7CC TCBitmapEC_LoadFromConfigBuffer }
procedure TCBitmapEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  if LoadOption = 'RGBA' then Bitmap.LoadImageRgba(SourceBuffer)
  else if LoadOption = 'Gray' then Bitmap.LoadImageGrayscale(SourceBuffer)
  else if LoadOption = 'RGB' then Bitmap.LoadImageRgb(SourceBuffer)
  else Bitmap.LoadImage(SourceBuffer);
  ResidentBytes := Bitmap.PitchBytes * Bitmap.Height;
end;
{ @end $47D7CC }

end.
