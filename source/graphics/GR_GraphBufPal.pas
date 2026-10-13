unit GR_GraphBufPal;

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

    constructor Create; // @addr 0x007B1698
    destructor Destroy; override; // @addr 0x007B16D0
    procedure Clear; // @addr 0x007B16FC
    procedure AllocateTight(AWidth, AHeight, APaletteCount: Integer); // @addr 0x007B1738 @note "Discards existing pixels and palette; uses one byte per pixel with no row padding."
    procedure AllocateBuffer(AWidth, AHeight, APaletteCount, APitchBytes: Integer); // @addr 0x007B1784 @note "Discards existing pixels and palette; rounds pitch up to a multiple of four."
    function GetPaletteColor(Index: Integer): TColorRGBA; // @addr 0x007B1828 @note "Index is unchecked."
    function GetPixelIndex(X, Y: Integer): Byte; // @addr 0x007B188C @note "Coordinates are unchecked."
    procedure LoadImage(Buffer: TBufEC); // @addr 0x007B189C @note "Decodes the entire payload, ignoring Position; retains the codec's one- or two-byte indexed pixel width. Failures raise."
    procedure SetPalette(Source: PColorRGBA; Count: Integer); // @addr $7B1850
    procedure ClearPixels; // @addr $7B1964
    procedure FillPixels(Value: Byte); // @addr 0x007B1978 @note "Includes row padding."
  end;

implementation

uses EC_Mem, GR_Main, SysUtils, Windows;

{ @routine $7B1698 TGraphBufPalGR_Create }
constructor TGraphBufPalGR.Create;
begin
  inherited Create;
end;
{ @end $7B1698 }

{ @routine $7B16D0 TGraphBufPalGR_Destroy }
destructor TGraphBufPalGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $7B16D0 }

{ @routine $7B16FC TGraphBufPalGR_Clear }
procedure TGraphBufPalGR.Clear;
begin
  if Pixels <> nil then begin FreeEC(Pixels); Pixels := nil; end;
  Width := 0; Height := 0; PitchBytes := 0;
  if Palette <> nil then begin FreeEC(Palette); Palette := nil; end;
  PaletteCount := 0;
end;
{ @end $7B16FC }

{ @routine $7B1738 TGraphBufPalGR_AllocateTight }
procedure TGraphBufPalGR.AllocateTight(AWidth, AHeight, APaletteCount: Integer);
begin
  Clear;
  Width := AWidth; Height := AHeight; PitchBytes := AWidth;
  PaletteCount := APaletteCount;
  Pixels := AllocEC(PitchBytes * Height);
  Palette := AllocEC(APaletteCount * SizeOf(Palette^));
end;
{ @end $7B1738 }

{ @routine $7B1784 TGraphBufPalGR_AllocateBuffer }
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
{ @end $7B1784 }

{ @routine $7B1828 TGraphBufPalGR_GetPaletteColor }
function TGraphBufPalGR.GetPaletteColor(Index: Integer): TColorRGBA;
begin
  Result := PColorRGBA(AddPointerOffset(Palette, Index * SizeOf(TColorRGBA)))^;
end;
{ @end $7B1828 }

{ @routine $7B1850 TGraphBufPalGR_SetPalette }
procedure TGraphBufPalGR.SetPalette(Source: PColorRGBA; Count: Integer);
begin
  if PaletteCount <> Count then
  begin
    PaletteCount := Count;
    Palette := ReAllocREC(Palette, PaletteCount * SizeOf(Palette^));
  end;
  CopyMemory(Palette, Source, Count * SizeOf(Source^));
end;
{ @end $7B1850 }

{ @routine $7B188C TGraphBufPalGR_GetPixelIndex }
function TGraphBufPalGR.GetPixelIndex(X, Y: Integer): Byte;
var Data: PByteArray;
begin
  Data := Pixels;
  Result := Data^[Y * PitchBytes + X];
end;
{ @end $7B188C }

{ @routine $7B189C TGraphBufPalGR_LoadImage }
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
{ @end $7B189C }

{ @routine $7B1964 TGraphBufPalGR_ClearPixels }
procedure TGraphBufPalGR.ClearPixels;
begin
  FillChar(Pixels^, PitchBytes * Height, 0);
end;
{ @end $7B1964 }

{ @routine $7B1978 TGraphBufPalGR_FillPixels }
procedure TGraphBufPalGR.FillPixels(Value: Byte);
begin
  FillMemory(Pixels, PitchBytes * Height, Value);
end;
{ @end $7B1978 }

end.
