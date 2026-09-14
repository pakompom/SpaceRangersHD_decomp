unit GR_GraphBufPal;
// Unit bracket (inferred): .text 0x0081463C..0x00814AC6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create; // @addr 0x814698 @ida "TGraphBufPalGR *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x8146DC @ida "void __usercall $name(TGraphBufPalGR *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; // @addr 0x814718
    procedure AllocateTight(AWidth, AHeight, APaletteCount: Integer); // @addr 0x81477C @note "Discards existing pixels and palette; uses one byte per pixel with no row padding."
    procedure AllocateBuffer(AWidth, AHeight, APaletteCount, APitchBytes: Integer); // @addr 0x8147E8 @note "Discards existing pixels and palette; rounds pitch up to a multiple of four."
    function GetPaletteColor(Index: Integer): Cardinal; // @addr 0x8148BC @note "Index is unchecked."
    function GetPixelIndex(X, Y: Integer): Byte; // @addr 0x814944 @note "Coordinates are unchecked."
    procedure LoadImage(Buffer: TBufEC); // @addr 0x814978 @note "Decodes the entire payload, ignoring Position; retains the codec's one- or two-byte indexed pixel width. Failures raise."
    procedure SetPalette(Source: PColorRGBA; Count: Integer); // @addr $8148EC
    procedure ClearPixels; // @addr $814A78
    procedure FillPixels(Value: Byte); // @addr 0x814A9C @note "Includes row padding."
  end;

implementation

uses EC_Mem, GR_Main, SysUtils, Windows;

{ @routine $814698 TGraphBufPalGR_Create }
constructor TGraphBufPalGR.Create;
begin
  inherited Create;
end;
{ @end $814698 }

{ @routine $8146DC TGraphBufPalGR_Destroy }
destructor TGraphBufPalGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $8146DC }

{ @routine $814718 TGraphBufPalGR_Clear }
procedure TGraphBufPalGR.Clear;
begin
  if Pixels <> nil then begin FreeEC(Pixels); Pixels := nil; end;
  Width := 0; Height := 0; PitchBytes := 0;
  if Palette <> nil then begin FreeEC(Palette); Palette := nil; end;
  PaletteCount := 0;
end;
{ @end $814718 }

{ @routine $81477C TGraphBufPalGR_AllocateTight }
procedure TGraphBufPalGR.AllocateTight(AWidth, AHeight, APaletteCount: Integer);
begin
  Clear;
  Width := AWidth; Height := AHeight; PitchBytes := AWidth;
  PaletteCount := APaletteCount;
  Pixels := AllocEC(PitchBytes * Height);
  Palette := AllocEC(APaletteCount * SizeOf(Palette^));
end;
{ @end $81477C }

{ @routine $8147E8 TGraphBufPalGR_AllocateBuffer }
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
{ @end $8147E8 }

{ @routine $8148BC TGraphBufPalGR_GetPaletteColor }
function TGraphBufPalGR.GetPaletteColor(Index: Integer): Cardinal;
begin
  Result := PCardinal(AddPointerOffset(Palette, Index * SizeOf(Palette^)))^;
end;
{ @end $8148BC }

{ @routine $8148EC TGraphBufPalGR_SetPalette }
procedure TGraphBufPalGR.SetPalette(Source: PColorRGBA; Count: Integer);
begin
  if PaletteCount <> Count then
  begin
    PaletteCount := Count;
    Palette := ReAllocREC(Palette, PaletteCount * SizeOf(Palette^));
  end;
  CopyMemory(Palette, Source, Count * SizeOf(Source^));
end;
{ @end $8148EC }

{ @routine $814944 TGraphBufPalGR_GetPixelIndex }
function TGraphBufPalGR.GetPixelIndex(X, Y: Integer): Byte;
var Data: PByteArray;
begin
  Data := Pixels;
  Result := Data^[Y * PitchBytes + X];
end;
{ @end $814944 }

{ @routine $814978 TGraphBufPalGR_LoadImage }
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
{ @end $814978 }

{ @routine $814A78 TGraphBufPalGR_ClearPixels }
procedure TGraphBufPalGR.ClearPixels;
begin
  FillChar(Pixels^, PitchBytes * Height, 0);
end;
{ @end $814A78 }

{ @routine $814A9C TGraphBufPalGR_FillPixels }
procedure TGraphBufPalGR.FillPixels(Value: Byte);
begin
  FillMemory(Pixels, PitchBytes * Height, Value);
end;
{ @end $814A9C }

end.
