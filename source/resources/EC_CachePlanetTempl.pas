unit EC_CachePlanetTempl;
// Unit bracket (inferred): .text 0x0047C838..0x0047CBB8; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Cache, Classes;

type
  TCPlanetTemplControlEC = class;
  TCPlanetTemplEC = class;

  TCPlanetTemplControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x47C918
    function CreateData: TCacheDataEC; override; // @addr 0x47C99C
    function AcquireData: TCacheDataEC; override; // @addr 0x47C9E8
  end;

  TCPlanetTemplEC = class(TCacheDataEC) // @size 0x28
  public
    TemplateData: Pointer; // @offset 0x20
    ImageHeight: Integer; // @offset 0x24

    constructor Create; // @addr 0x47CA04 @ida "TCPlanetTemplEC *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x47CA58 @ida "void __usercall $name(TCPlanetTemplEC *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x47CAB0
  end;

function AcquireOrCreatePlanetTemplate(Control: TCacheControlEC): TCPlanetTemplEC; // @addr 0x47C9BC

implementation

uses EC_CachePalBitmap, EC_Struct, GR_Main, EC_Str, GR_GraphBuf, SysUtils;

{ @routine $47C918 TCPlanetTemplControlEC_QueueLoadIfMissing }
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
{ @end $47C918 }

{ @routine $47C99C TCPlanetTemplControlEC_CreateData }
function TCPlanetTemplControlEC.CreateData: TCacheDataEC;
begin
  Result := TCPlanetTemplEC.Create;
end;
{ @end $47C99C }

{ @routine $47C9BC AcquireOrCreatePlanetTemplate }
function AcquireOrCreatePlanetTemplate(Control: TCacheControlEC): TCPlanetTemplEC;
begin
  Result := Control.AcquireDataFromConfig(TCPlanetTemplEC) as TCPlanetTemplEC;
end;
{ @end $47C9BC }

{ @routine $47C9E8 TCPlanetTemplControlEC_AcquireData }
function TCPlanetTemplControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreatePlanetTemplate(Self);
end;
{ @end $47C9E8 }

{ @routine $47CA04 TCPlanetTemplEC_Create }
constructor TCPlanetTemplEC.Create;
begin
  inherited Create;
  TemplateData := nil;
  ImageHeight := 0;
end;
{ @end $47CA04 }

{ @routine $47CA58 TCPlanetTemplEC_Destroy }
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
{ @end $47CA58 }

{ @routine $47CAB0 TCPlanetTemplEC_LoadFromConfigBuffer }
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
{ @end $47CAB0 }

end.
