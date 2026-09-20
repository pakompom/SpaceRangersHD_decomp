unit EC_CacheTBitmap;
// Unit bracket (inferred): .text 0x004744FC..0x00474830; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, Classes, EC_Buf, EC_Cache;

type
  TCTBitmapControlEC = class;
  TCTBitmapEC = class;

  TCTBitmapControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4745D4
    function CreateData: TCacheDataEC; override; // @addr 0x474658
    function AcquireData: TCacheDataEC; override; // @addr 0x4746A4
  end;
  TCTBitmapEC = class(TCacheDataEC) // @size 0x2C
  public
    TransBuffer: Pointer; // @offset 0x20
    PixelSize: TPoint; // @offset $24  Native controls copy these dimensions as one point.

    constructor Create; // @addr 0x4746C0
    destructor Destroy; override; // @addr 0x474704
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x474754 @note "Applies LoadOption image operations before building the transparent buffer."
  end;

function AcquireCachedTransBitmap(Control: TCacheControlEC): TCTBitmapEC; // @addr 0x474678

implementation

uses SysUtils, EC_Str, GR_Main, GR_GraphBuf;

{ @routine $4745D4 TCTBitmapControlEC_QueueLoadIfMissing }
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
{ @end $4745D4 }

{ @routine $474658 TCTBitmapControlEC_CreateData }
function TCTBitmapControlEC.CreateData: TCacheDataEC;
begin
  Result := TCTBitmapEC.Create;
end;
{ @end $474658 }

{ @routine $474678 AcquireCachedTransBitmap }
function AcquireCachedTransBitmap(Control: TCacheControlEC): TCTBitmapEC;
begin
  Result := Control.AcquireDataFromConfig(TCTBitmapEC) as TCTBitmapEC;
end;
{ @end $474678 }

{ @routine $4746A4 TCTBitmapControlEC_AcquireData }
function TCTBitmapControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedTransBitmap(Self);
end;
{ @end $4746A4 }

{ @routine $4746C0 TCTBitmapEC_Create }
constructor TCTBitmapEC.Create;
begin
  inherited Create;
end;
{ @end $4746C0 }

{ @routine $474704 TCTBitmapEC_Destroy }
destructor TCTBitmapEC.Destroy;
begin
  if TransBuffer <> nil then
  begin
    FreeMem(TransBuffer);
    TransBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $474704 }

{ @routine $474754 TCTBitmapEC_LoadFromConfigBuffer }
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
{ @end $474754 }

end.
