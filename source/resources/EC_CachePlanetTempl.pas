unit EC_CachePlanetTempl;

interface

uses EC_Buf, EC_Cache, Classes;

type
  TCPlanetTemplControlEC = class;
  TCPlanetTemplEC = class;

  TCPlanetTemplControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x0048B1A8
    function CreateData: TCacheDataEC; override; // @addr 0x0048B214
    function AcquireData: TCacheDataEC; override; // @addr 0x0048B244
  end;

  TCPlanetTemplEC = class(TCacheDataEC) // @size 0x28
  public
    TemplateData: Pointer; // @offset 0x20
    ImageHeight: Integer; // @offset 0x24

    constructor Create; // @addr 0x0048B24C
    destructor Destroy; override; // @addr 0x0048B28C
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x0048B2C8
  end;

function AcquireOrCreatePlanetTemplate(Control: TCacheControlEC): TCPlanetTemplEC; // @addr 0x0048B224

implementation

uses EC_CachePalBitmap, EC_Struct, GR_Main, EC_Str, GR_GraphBuf, SysUtils;

{ @routine $48B1A8 TCPlanetTemplControlEC_QueueLoadIfMissing }
procedure TCPlanetTemplControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCPlanetTemplControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCPlanetTemplEC) <> nil then Exit;
  Control := TCPlanetTemplControlEC.Create;
  GlobalCache.ResetControl(Control);
  Control.SetCacheKey(CacheKey);
  PendingLoads.Add(Control);
end;
{ @end $48B1A8 }

{ @routine $48B214 TCPlanetTemplControlEC_CreateData }
function TCPlanetTemplControlEC.CreateData: TCacheDataEC;
begin
  Result := TCPlanetTemplEC.Create;
end;
{ @end $48B214 }

{ @routine $48B224 AcquireOrCreatePlanetTemplate }
function AcquireOrCreatePlanetTemplate(Control: TCacheControlEC): TCPlanetTemplEC;
begin
  Result := Control.AcquireDataFromConfig(TCPlanetTemplEC) as TCPlanetTemplEC;
end;
{ @end $48B224 }

{ @routine $48B244 TCPlanetTemplControlEC_AcquireData }
function TCPlanetTemplControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreatePlanetTemplate(Self);
end;
{ @end $48B244 }

{ @routine $48B24C TCPlanetTemplEC_Create }
constructor TCPlanetTemplEC.Create;
begin
  inherited Create;
  TemplateData := nil;
  ImageHeight := 0;
end;
{ @end $48B24C }

{ @routine $48B28C TCPlanetTemplEC_Destroy }
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
{ @end $48B28C }

{ @routine $48B2C8 TCPlanetTemplEC_LoadFromConfigBuffer }
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
{ @end $48B2C8 }

end.
