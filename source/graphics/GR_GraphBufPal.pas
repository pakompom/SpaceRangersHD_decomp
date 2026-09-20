unit GR_GraphBufPal;
// Unit bracket (inferred): .text 0x0086B5EC..0x0086BA76; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_OKGF, EC_Buf, EC_Struct, GR_GraphBuf;

type
  TGraphBufPalGR = class(TObjectEx) // @size 0x20
  public
    Width: Integer; // @offset 0x04
    Height: Integer; // @offset 0x08
    PitchBytes: Integer; // @offset 0x0C
    BytesPerPixel: Integer; // @offset 0x10
    Pixels: Pointer; // @offset 0x14
    PaletteCount: Integer; // @offset 0x18
    Palette: PColorRGBA; // @offset 0x1C

    constructor Create; // @addr 0x86B648
    destructor Destroy; override; // @addr 0x86B68C
    procedure Clear; // @addr 0x86B6C8
    procedure AllocateTight(AWidth, AHeight, APaletteCount: Integer); // @addr 0x86B72C @note "Discards existing pixels and palette; uses one byte per pixel with no row padding."
    procedure AllocateBuffer(AWidth, AHeight, APaletteCount, APitchBytes: Integer); // @addr 0x86B798 @note "Discards existing pixels and palette; rounds pitch up to a multiple of four."
    function GetPaletteColor(Index: Integer): Cardinal; // @addr 0x86B86C @note "Index is unchecked."
    function GetPixelIndex(X, Y: Integer): Byte; // @addr 0x86B8F4 @note "Coordinates are unchecked."
    procedure LoadImage(Buffer: TBufEC); // @addr 0x86B928 @note "Decodes the entire payload, ignoring Position; retains the codec's one- or two-byte indexed pixel width. Failures raise."
    procedure SetPalette(Source: PColorRGBA; Count: Integer); // @addr $86B89C
    procedure ClearPixels; // @addr $86BA28
    procedure FillPixels(Value: Byte); // @addr 0x86BA4C @note "Includes row padding."
  end;

implementation

uses EC_Mem, GR_Main, SysUtils, Windows;

{ @routine $86B648 TGraphBufPalGR_Create }
constructor TGraphBufPalGR.Create;
begin
  inherited Create;
end;
{ @end $86B648 }

{ @routine $86B68C TGraphBufPalGR_Destroy }
destructor TGraphBufPalGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $86B68C }

{ @routine $86B6C8 TGraphBufPalGR_Clear }
procedure TGraphBufPalGR.Clear;
begin
  if Pixels <> nil then begin FreeEC(Pixels); Pixels := nil; end;
  Width := 0; Height := 0; PitchBytes := 0;
  if Palette <> nil then begin FreeEC(Palette); Palette := nil; end;
  PaletteCount := 0;
end;
{ @end $86B6C8 }

{ @routine $86B72C TGraphBufPalGR_AllocateTight }
procedure TGraphBufPalGR.AllocateTight(AWidth, AHeight, APaletteCount: Integer);
begin
  Clear;
  Width := AWidth; Height := AHeight; PitchBytes := AWidth;
  PaletteCount := APaletteCount;
  Pixels := AllocEC(PitchBytes * Height);
  Palette := AllocEC(APaletteCount * SizeOf(Palette^));
end;
{ @end $86B72C }

{ @routine $86B798 TGraphBufPalGR_AllocateBuffer }
procedure TGraphBufPalGR.AllocateBuffer(AWidth, AHeight, APaletteCount, APitchBytes: Integer);
begin
  Clear;
  Width := AWidth; Height := AHeight; PitchBytes := APitchBytes;
  if PitchBytes and 3 <> 0 then PitchBytes := PitchBytes + 4 - (PitchBytes and 3);
  PaletteCount := APaletteCount;
  Pixels := AllocEC(PitchBytes * Height);
  Palette := AllocEC(APaletteCount * SizeOf(Palette^));
  if (PitchBytes and 3 <> 0) or (Cardinal(Pixels) and 3 <> 0) then
    raise Exception.Create('TGraphBufPalGR.CreateN');
end;
{ @end $86B798 }

{ @routine $86B86C TGraphBufPalGR_GetPaletteColor }
function TGraphBufPalGR.GetPaletteColor(Index: Integer): Cardinal;
begin
  Result := PCardinal(AddPointerOffset(Palette, Index * SizeOf(Palette^)))^;
end;
{ @end $86B86C }

{ @routine $86B89C TGraphBufPalGR_SetPalette }
procedure TGraphBufPalGR.SetPalette(Source: PColorRGBA; Count: Integer);
begin
  if PaletteCount <> Count then
  begin
    PaletteCount := Count;
    Palette := ReAllocREC(Palette, PaletteCount * SizeOf(Palette^));
  end;
  CopyMemory(Palette, Source, Count * SizeOf(Source^));
end;
{ @end $86B89C }

{ @routine $86B8F4 TGraphBufPalGR_GetPixelIndex }
function TGraphBufPalGR.GetPixelIndex(X, Y: Integer): Byte;
var Data: PByteArray;
begin
  Data := Pixels;
  Result := Data^[Y * PitchBytes + X];
end;
{ @end $86B8F4 }

{ @routine $86B928 TGraphBufPalGR_LoadImage }
procedure TGraphBufPalGR.LoadImage(Buffer: TBufEC);
var Context: POkgfReadContext;
begin
  Clear;
  Context := BeginIndexedImageRead(Buffer.Data, Buffer.DataSize, Width, Height, PaletteCount, BytesPerPixel);
  if Context = nil then raise Exception.Create('TGraphBufPalGR.LoadFromFile. Error load file');
  AllocateBuffer(Width, Height, PaletteCount, Width * BytesPerPixel);
  Context := Pointer(ReadIndexedImagePixels(Context, Pixels, PitchBytes, Palette));
  if Context = nil then raise Exception.Create('TGraphBufPalGR.LoadFromFile. Error load file');
end;
{ @end $86B928 }

{ @routine $86BA28 TGraphBufPalGR_ClearPixels }
procedure TGraphBufPalGR.ClearPixels;
begin
  FillChar(Pixels^, PitchBytes * Height, 0);
end;
{ @end $86BA28 }

{ @routine $86BA4C TGraphBufPalGR_FillPixels }
procedure TGraphBufPalGR.FillPixels(Value: Byte);
begin
  FillMemory(Pixels, PitchBytes * Height, Value);
end;
{ @end $86BA4C }

end.
