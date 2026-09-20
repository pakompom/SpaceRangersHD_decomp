unit EC_CacheLightPal;
// Unit bracket (inferred): .text 0x004A5AA4..0x004A6024; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Windows, Classes, EC_Buf, EC_Cache;

type
  TCLightPalControlEC = class;
  TCLightPalEC = class;

  TCLightPalControlEC = class(TCacheControlEC) // @size 0x18
  public
    procedure QueueLoadIfMissing(PendingLoads: TList); override; // @addr 0x4A5B80
    function CreateData: TCacheDataEC; override; // @addr 0x4A5C04
    function AcquireData: TCacheDataEC; override; // @addr 0x4A5C50
  end;

  TCLightPalEC = class(TCacheDataEC) // @size 0x24
  public
    PaletteData: PWord; // @offset 0x20

    constructor Create; // @addr 0x4A5E9C
    destructor Destroy; override; // @addr 0x4A5EE8
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override; // @addr 0x4A5F38
  end;

function AcquireOrCreateLightPalette(Control: TCacheControlEC): TCLightPalEC; // @addr 0x4A5C24

procedure GetLightPaletteMaskInfo(Mask: Cardinal; Shift, BitCount, LevelCount: PCardinal); // @addr $4A5C6C
function BuildLightPalette(Palette: PCardinal; ColorCount: Integer; RedMask, GreenMask, BlueMask: Cardinal): PWord; // @addr $4A5CD0 @note "Returns 64 packed 16-bit brightness levels per source color."
procedure FreeLightPalette(Palette: PWord); // @addr $4A5E84

implementation

uses GR_Main, GR_GraphBufPal, EC_Mem, SysUtils;

{ @routine $4A5B80 TCLightPalControlEC_QueueLoadIfMissing }
procedure TCLightPalControlEC.QueueLoadIfMissing(PendingLoads: TList);
var Control: TCLightPalControlEC;
begin
  if RetainCount > 0 then Exit;
  if BoundData <> nil then Exit;
  if HasEmptyCacheKey then Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCLightPalEC) = nil then
  begin
    Control := TCLightPalControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;
{ @end $4A5B80 }

{ @routine $4A5C04 TCLightPalControlEC_CreateData }
function TCLightPalControlEC.CreateData: TCacheDataEC;
begin
  Result := TCLightPalEC.Create;
end;
{ @end $4A5C04 }

{ @routine $4A5C24 AcquireOrCreateLightPalette }
function AcquireOrCreateLightPalette(Control: TCacheControlEC): TCLightPalEC;
begin
  Result := Control.AcquireDataFromConfig(TCLightPalEC) as TCLightPalEC;
end;
{ @end $4A5C24 }

{ @routine $4A5C50 TCLightPalControlEC_AcquireData }
function TCLightPalControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireOrCreateLightPalette(Self);
end;
{ @end $4A5C50 }

{ @routine $4A5C6C GetLightPaletteMaskInfo }
procedure GetLightPaletteMaskInfo(Mask: Cardinal; Shift, BitCount, LevelCount: PCardinal);
begin
  Shift^ := 0; BitCount^ := 0; LevelCount^ := 0;
  if Mask <> 0 then
  begin
    while Mask and 1 = 0 do
    begin
      Inc(Shift^); Mask := Mask shr 1;
    end;
    while Mask and 1 <> 0 do
    begin
      Inc(BitCount^); Mask := Mask shr 1;
    end;
    LevelCount^ := 1 shl BitCount^;
  end;
end;
{ @end $4A5C6C }

{ @routine $4A5CD0 BuildLightPalette }
function BuildLightPalette(Palette: PCardinal; ColorCount: Integer; RedMask, GreenMask, BlueMask: Cardinal): PWord;
const
  BrightnessBits = 6;
  BrightnessLevels = 1 shl BrightnessBits;
var RShift, RBits, RLevels, RDiscard, GShift, GBits, GLevels, GDiscard, BShift, BBits, BLevels, BDiscard: Cardinal;
  First, Dest: PWord;
  Red, Green, Blue: Double;
  ColorIndex, Brightness: Integer;
  R, G, B: Cardinal;
  Factor: Double;
begin
  GetLightPaletteMaskInfo(RedMask, @RShift, @RBits, @RLevels); RDiscard := 8 - RBits;
  GetLightPaletteMaskInfo(GreenMask, @GShift, @GBits, @GLevels); GDiscard := 8 - GBits;
  GetLightPaletteMaskInfo(BlueMask, @BShift, @BBits, @BLevels); BDiscard := 8 - BBits;
  First := AllocEC((ColorCount shl BrightnessBits) * SizeOf(First^));
  Dest := First;
  for ColorIndex := 0 to ColorCount - 1 do
  begin
    Red := Palette^ and $FF;
    Green := (Palette^ shr 8) and $FF;
    Blue := (Palette^ shr 16) and $FF;
    Brightness := 0;
    repeat
      Factor := Brightness / (BrightnessLevels - 1);
      R := Trunc(Red * Factor); G := Trunc(Green * Factor); B := Trunc(Blue * Factor);
      Dest^ := (Word(R shr RDiscard) shl RShift) or (Word(G shr GDiscard) shl GShift) or (Word(B shr BDiscard) shl BShift);
      Dest := PWord(PAnsiChar(Dest) + SizeOf(Word));
      Inc(Brightness);
    until Brightness = BrightnessLevels;
    Palette := PCardinal(PAnsiChar(Palette) + SizeOf(Cardinal));
  end;
  Result := First;
end;
{ @end $4A5CD0 }

{ @routine $4A5E84 FreeLightPalette }
procedure FreeLightPalette(Palette: PWord);
begin
  if Palette <> nil then FreeEC(Palette);
end;
{ @end $4A5E84 }

{ @routine $4A5E9C TCLightPalEC_Create }
constructor TCLightPalEC.Create;
begin
  inherited Create;
  PaletteData := nil;
end;
{ @end $4A5E9C }

{ @routine $4A5EE8 TCLightPalEC_Destroy }
destructor TCLightPalEC.Destroy;
begin
  if PaletteData <> nil then
  begin
    FreeLightPalette(PaletteData);
    PaletteData := nil;
  end;
  inherited Destroy;
end;
{ @end $4A5EE8 }

{ @routine $4A5F38 TCLightPalEC_LoadFromConfigBuffer }
procedure TCLightPalEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
var Bitmap: TGraphBufPalGR;
begin
  Bitmap := nil;
  try
    Bitmap := TGraphBufPalGR.Create;
    Bitmap.LoadImage(SourceBuffer);
    if (Bitmap.PaletteCount < 1) or (Bitmap.PaletteCount > 256) or (Bitmap.Palette = nil) then
      raise Exception.Create('TCLightPalEC.Load. In error create light palette. ');
    PaletteData := BuildLightPalette(PCardinal(Bitmap.Palette), Bitmap.PaletteCount, CurrentPixelFormat.RedMask, CurrentPixelFormat.GreenMask, CurrentPixelFormat.BlueMask);
    if PaletteData = nil then
      raise Exception.Create('TCLightPalEC.Load. Out error create light palette.');
  finally
    if Bitmap <> nil then Bitmap.Free;
  end;
end;
{ @end $4A5F38 }

end.
