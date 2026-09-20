unit EC_CachePlanetTempl;
// Unit bracket (inferred): .text 0x004A60A0..0x004A6420; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Cache, Classes;

type
  TCPlanetTemplControlEC = class;
  TCPlanetTemplEC = class;

  TCPlanetTemplControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4A6180
    function CreateData: TCacheDataEC; override; // @addr 0x4A6204
    function AcquireData: TCacheDataEC; override; // @addr 0x4A6250
  end;

  TCPlanetTemplEC = class(TCacheDataEC) // @size 0x28
  public
    TemplateData: Pointer; // @offset 0x20
    ImageHeight: Integer; // @offset 0x24

    constructor Create; // @addr 0x4A626C
    destructor Destroy; override; // @addr 0x4A62C0
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x4A6318
  end;

function AcquireOrCreatePlanetTemplate(Control: TCacheControlEC): TCPlanetTemplEC; // @addr 0x4A6224

implementation

uses EC_CachePalBitmap, EC_Struct, GR_Main, EC_Str, GR_GraphBuf, SysUtils;

{ @routine $4A6180 TCPlanetTemplControlEC_QueueLoadIfMissing }
procedure TCPlanetTemplControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCPlanetTemplControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCPlanetTemplEC) = nil then
  begin
    Control := TCPlanetTemplControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $4A6180 }

{ @routine $4A6204 TCPlanetTemplControlEC_CreateData }
function TCPlanetTemplControlEC.CreateData: TCacheDataEC;
begin
  Result := TCPlanetTemplEC.Create;
end;
{ @end $4A6204 }

{ @routine $4A6224 AcquireOrCreatePlanetTemplate }
function AcquireOrCreatePlanetTemplate(Control: TCacheControlEC): TCPlanetTemplEC;
begin
  Result := Control.AcquireDataFromConfig(TCPlanetTemplEC) as TCPlanetTemplEC;
end;
{ @end $4A6224 }

{ @routine $4A6250 TCPlanetTemplControlEC_AcquireData }
function TCPlanetTemplControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreatePlanetTemplate(Self);
end;
{ @end $4A6250 }

{ @routine $4A626C TCPlanetTemplEC_Create }
constructor TCPlanetTemplEC.Create;
begin
  inherited Create;
  TemplateData := nil;
  ImageHeight := 0;
end;
{ @end $4A626C }

{ @routine $4A62C0 TCPlanetTemplEC_Destroy }
destructor TCPlanetTemplEC.Destroy;
begin
  if TemplateData <> nil then
  begin
    Ex_OKGR_Planet2_TemplDel(TemplateData);
    TemplateData := nil;
    ImageHeight := 0;
  end;
  inherited Destroy;
end;
{ @end $4A62C0 }

{ @routine $4A6318 TCPlanetTemplEC_LoadFromConfigBuffer }
procedure TCPlanetTemplEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var Bitmap: TGraphBufGR; TextureWidth, TextureHeight: Integer;
begin
  Bitmap := TGraphBufGR.Create(False);
  Bitmap.LoadImageRgba(SourceBuffer);
  TextureWidth := ExtractDigitsToIntW(ExtractDelimitedPartW(LoadOption, 0, ','));
  TextureHeight := ExtractDigitsToIntW(ExtractDelimitedPartW(LoadOption, 1, ','));
  TemplateData := Ex_OKGR_Planet2_TemplBuild(Bitmap.GetPixels, Bitmap.PitchBytes, Bitmap.Height, TextureWidth, TextureHeight, ResidentBytes);
  if TemplateData = nil then
    raise Exception.Create('TCPlanetTemplEC.Load. Error create template planet.');
  ImageHeight := Bitmap.Height;
  Bitmap.Free;
end;
{ @end $4A6318 }

end.
