unit GR_GraphBuf;
// Unit bracket (inferred): .text 0x008650D0..0x0086B5DF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses jpeg, EC_Buf, EC_Struct, Direct3D9, Types;

type
  TPixelFormatGR = class(TObject) // @size 0x4C
  public
    RedMask: Cardinal; // @offset 0x04
    GreenMask: Cardinal; // @offset 0x08
    BlueMask: Cardinal; // @offset 0x0C
    AlphaMask: Cardinal; // @offset 0x10
    RedShift: Cardinal; // @offset 0x14
    GreenShift: Cardinal; // @offset 0x18
    BlueShift: Cardinal; // @offset 0x1C
    AlphaShift: Cardinal; // @offset 0x20
    RedLevels: Cardinal; // @offset 0x24
    GreenLevels: Cardinal; // @offset 0x28
    BlueLevels: Cardinal; // @offset 0x2C
    AlphaLevels: Cardinal; // @offset 0x30
    RedBits: Cardinal; // @offset 0x34
    GreenBits: Cardinal; // @offset 0x38
    BlueBits: Cardinal; // @offset 0x3C
    AlphaBits: Cardinal; // @offset 0x40
    BytesPerPixel: Integer; // @offset 0x44
    TotalChannelBits: Cardinal; // @offset 0x48

    function InterpolateRgb(First, Second: Cardinal; Amount: Single): Cardinal; // @addr $86548C
    function UnpackRed(Color: Cardinal): Byte; // @addr $8655A4
    function UnpackGreen(Color: Cardinal): Byte; // @addr $8655D4
    function UnpackBlue(Color: Cardinal): Byte; // @addr $865604
    procedure RebuildChannelMetrics; // @addr 0x865198 @note "Ignores disjoint bits after each mask's first contiguous run; BytesPerPixel is unchanged."
    function PackRgbBytes(Red, Green, Blue: Byte): Cardinal; // @addr 0x865340
    function PackRgb(Red, Green, Blue: Integer): Cardinal; // @addr 0x8653B0
    function PackNormalizedRgb(Red, Green, Blue: Double): Cardinal; // @addr 0x865408 @note "Does not clamp inputs or include alpha."
  end;

  TColorRGBA = packed record // @size 0x04
    R: Byte; // @offset 0x00
    G: Byte; // @offset 0x01
    B: Byte; // @offset 0x02
    A: Byte; // @offset 0x03
  end;
  PColorRGBA = ^TColorRGBA;
  TColorRGBAArray = array[0..0] of TColorRGBA;
  PColorRGBAArray = ^TColorRGBAArray;
  // Screen/texture byte order used by the brightness and grayscale routines.
  TColorBGRA = packed record // @size $04
    B: Byte; // @offset $00
    G: Byte; // @offset $01
    R: Byte; // @offset $02
    A: Byte; // @offset $03
  end;
  PColorBGRA = ^TColorBGRA;
  TPixelWordsGR = array[0..0] of Word;
  PPixelWordsGR = ^TPixelWordsGR;
  TGraphBufGR = class(TObjectEx) // @size 0x2C
  public
    function GetPixel16(X, Y: Integer): Cardinal; // @addr $866370
    procedure SetPixel16(X, Y: Integer; Color: Cardinal); // @addr $8663BC
    function GetBrightness16(X, Y: Integer): Cardinal; // @addr $866408
    function GetPixel32(X, Y: Integer): Cardinal; // @addr $86658C
    procedure DrawHorizontalLine16(X, Y, Count: Integer; Color: Cardinal); // @addr $8665D8
    procedure DrawVerticalLine16(X, Y, Count: Integer; Color: Cardinal); // @addr $86663C
    procedure DrawHorizontalLine16Clipped(X, Y, Count: Integer; Color: Cardinal; Clip: TRect); // @addr $8666B0
    procedure DrawVerticalLine16Clipped(X, Y, Count: Integer; Color: Cardinal; Clip: TRect); // @addr $866754
    procedure ClearPixels; // @addr $8673C4
    procedure FillPixels(Value: Byte); // @addr $8673F4
    procedure FillRect32(Rect: TRect; Color: Cardinal); // @addr $86746C
    procedure BlendPixel16(X, Y: Integer; Color: Cardinal; Alpha: Byte); // @addr $8664D8
    procedure DrawAlphaLine16(X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; Clip: TRect); // @addr $866530
    procedure DrawLine16(First, Last: TPoint; Color: Cardinal); // @addr $8667F8
    procedure DrawAnimatedLine16(First, Last: TPoint; Color: Cardinal; Phase: Integer; Clip: TRect); // @addr $866890
    procedure DrawShadowLine16(First, Last: TPoint; Color: Cardinal; Phase: Integer; Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer); // @addr $8668F4
    procedure DrawAlphaTrapezium16(X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; Alpha: Byte; Clip: TRect); // @addr $866960
    procedure DrawLine16Clipped(First, Last: TPoint; Color: Cardinal; Clip: TRect); // @addr $866A00
    procedure FillPixels16(Color: Word); // @addr $86742C
    procedure ScaleAlpha(Rect: TRect; Alpha: Byte); // @addr $8674FC @ida "void __userpurge $name(TGraphBufGR *Self@<eax>, TRect *Rect@<edx>, unsigned __int8 Alpha@<cl>);"
    procedure FlipHorizontal16; // @addr $8675A8
    procedure RotateLeft16; // @addr $867660
    procedure Stretch16(Width, Height: Cardinal); // @addr $8677D0
    procedure ConvertRgbTo565; // @addr $867880
    procedure Convert565ToRgb; // @addr $8679C0
    procedure ShiftLight16(Shift: Integer; Rect: TRect); // @addr $867A9C @ida "void __userpurge $name(TGraphBufGR *Self@<eax>, int Shift@<edx>, TRect *Rect@<ecx>);"
    procedure DrawCircle16(Center: TPoint; Radius: Integer; OutlineColor, FillColor: Cardinal; Clip: TRect); // @addr $867B0C
    procedure DrawCircle8(Center: TPoint; Radius: Integer; OutlineColor, FillColor: Cardinal; Clip: TRect); // @addr $867BAC
    procedure ApplyOperations(const Operations: WideString); // @addr $867C48
    procedure RescaleRgb(Width, Height: Integer); // @addr $867E08
    procedure RescaleRgba(Width, Height, Filter: Integer); // @addr $867EEC
    procedure RescaleBilinearRgba(Width, Height: Integer); // @addr $867FD4
    procedure FillPolygon32(Points: array of TPoint; Color: Cardinal); // @addr $8682D8
    function GetPixelCentroid: TPoint; // @addr $868600
    procedure CopyRect32(Dest: TPoint; Source: TGraphBufGR; Rect: TRect); // @addr $8686C8
    procedure BlendRect32(Dest: TPoint; Source: TGraphBufGR; Rect: TRect); // @addr $8687A0
    procedure MakeShadow; // @addr $868928
    procedure AdjustBrightness(Percent: Integer); // @addr $869CF0
    procedure ConvertToGrayscale; // @addr $869F20
    function GetTexture: IDirect3DTexture9; // @addr $86A214
    procedure Crop(Rect: TRect); // @addr $869AA8
    procedure DrawNinePatch(X, Y, Width, Height: Integer; Source: TGraphBufGR; SourceRect, Borders: TRect); // @addr $868EB8
    procedure RescaleWithAspect(Width, Height: Cardinal; CropToAspect: Boolean; HorizontalAlign, VerticalAlign, Filter: Integer); // @addr $86918C
    procedure RescaleRGBA_HW(Width, Height: Cardinal; CropToAspect: Boolean; HorizontalAlign, VerticalAlign: Integer); // @addr 0x8694F0 @note "Alignment values: 0=start, 1=center, 2=end."
    procedure LoadFromScreen(UnusedOption: Byte); // @addr $86A450 @note "The byte-sized option is ignored in this build."
    procedure ConvertBgraToRgb24; // @addr $86AAD8
    procedure DrawAntialiasedCircle16(Center: TPoint; Radius: Integer; Color: Cardinal; Clip: TRect); // @addr $86ACE4
    procedure DrawAntialiasedLine16(X1, Y1, X2, Y2: Integer; Color: Cardinal; Alpha: Integer; Clip: TRect); // @addr $86AFE4
    Width: Integer; // @offset 0x04
    Height: Integer; // @offset 0x08
    PitchBytes: Integer; // @offset 0x0C
    // Zero owns software pixels; one borrows them.
    StorageKind: Integer; // @offset $14
    Pixels: Pointer; // @offset 0x10
    BitsPerPixel: Integer; // @offset 0x18
    BytesPerPixel: Integer; // @offset 0x1C
    UseTexture: Boolean; // @offset 0x20
    UsesTextureStorage: Boolean; // @offset 0x21
    // Cleared on allocation and reset; purpose unresolved.
    TextureFlag22: Boolean; // @offset $22
    Texture: IDirect3DTexture9; // @offset 0x24
    TextureLocked: Boolean; // @offset 0x28
    TextureLockedReadOnly: Boolean; // @offset 0x29

    constructor Create(AUseTexture: Boolean); // @addr 0x865620
    destructor Destroy; override; // @addr 0x8656C4
    procedure Clear; // @addr 0x865700
    function GetPixels: Pointer; // @addr 0x86578C @note "Locks texture storage for writing if necessary."
    procedure AllocateNativePitch(Width, Height, PitchBytes: Integer); // @addr $865924
    procedure AttachPixels(Width, Height, PitchBytes: Integer; Data: Pointer); // @addr $865A28
    procedure AllocateNative(Width, Height: Integer); // @addr 0x8657B0 @note "Records 16-bit pixels; software pitch uses CurrentPixelFormat.BytesPerPixel and four-byte alignment."
    procedure AllocateRgbaTight(Width, Height: Integer); // @addr 0x865A98 @note "Software storage uses Width*4 pitch; texture storage uses the returned surface pitch."
    procedure AllocateRgba(Width, Height, PitchBytes: Integer); // @addr 0x865B9C
    procedure AllocateRgbTight(Width, Height: Integer); // @addr 0x865CA0
    procedure AllocateRgb(Width, Height, PitchBytes: Integer); // @addr 0x865D04 @note "Always allocates software storage, even when UseTexture is enabled."
    procedure AllocateGrayscale(Width, Height: Integer); // @addr 0x865D68 @note "Eight-bit software pixels with four-byte-aligned pitch."
    // Decode the entire file payload, ignoring Buffer.Position. Failures raise.
    procedure LoadImage(Buffer: TBufEC); // @addr 0x865E34 @note "Uses CurrentPixelFormat masks and byte width."
    procedure LoadImageRgba(Buffer: TBufEC); // @addr 0x8660AC @note "Produces BGRA byte order, with alpha in the high byte."
    procedure LoadImageRgb(Buffer: TBufEC); // @addr 0x86619C @note "Produces RGB byte order."
    procedure LoadImageGrayscale(Buffer: TBufEC); // @addr 0x866284
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x868998 @note "Replaces Buffer with width, height, pitch and raw pixels. Leaves Position at 12, before the pixel data."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x868A24 @note "Accepts zlib-packed or raw buffer data. Allocates software pixels and leaves Position immediately after the 12-byte image header."
    procedure SavePng(FileName: WideString); // @addr 0x868B0C @note "Assumes four-byte BGRA pixels. Converts FileName to ANSI and ignores the writer's status."
    procedure SaveBmp(FileName: WideString); // @addr 0x868BA0 @note "Assumes 32-bit BGRA pixels; alpha is excluded. Converts FileName to ANSI and ignores the writer's status."
    procedure SaveJpeg(FileName: WideString; Quality: Integer); // @addr 0x868C44 @note "Writes an intermediate BMP to FileName, then replaces it with JPEG. Quality is truncated to one byte; exceptions after the BMP write are swallowed."
    procedure DrawAntialiasedLine(FirstPoint, SecondPoint: TPoint; Color: Cardinal); // @addr 0x866DB0 @note "RGBA pixels; coverage replaces the color alpha. Blending preserves an existing pixel's alpha unless coverage is fully opaque."
    procedure LockTexture(ReadOnly: Boolean); // @addr 0x86A9E8
    procedure UnlockTexture; // @addr 0x86AA8C
  end;

implementation

uses EC_OKGF, EC_Mem, GR_DX, GR_Main, EC_Str, GlobalsV, Math, SysUtils, Classes, Windows, Graphics;

{ @routine $865198 TPixelFormatGR_RebuildChannelMetrics }
procedure TPixelFormatGR.RebuildChannelMetrics;
var Mask: Cardinal;
begin
  RedShift := 0; RedBits := 0; RedLevels := 0;
  GreenShift := 0; GreenBits := 0; GreenLevels := 0;
  BlueShift := 0; BlueBits := 0; BlueLevels := 0;
  AlphaShift := 0; AlphaBits := 0; AlphaLevels := 0;
  if RedMask <> 0 then
  begin
    Mask := RedMask;
    while Mask and 1 = 0 do begin Inc(RedShift); Mask := Mask shr 1; end;
    while Mask and 1 <> 0 do begin Inc(RedBits); Mask := Mask shr 1; end;
    RedLevels := 1 shl RedBits;
  end;
  if GreenMask <> 0 then
  begin
    Mask := GreenMask;
    while Mask and 1 = 0 do begin Inc(GreenShift); Mask := Mask shr 1; end;
    while Mask and 1 <> 0 do begin Inc(GreenBits); Mask := Mask shr 1; end;
    GreenLevels := 1 shl GreenBits;
  end;
  if BlueMask <> 0 then
  begin
    Mask := BlueMask;
    while Mask and 1 = 0 do begin Inc(BlueShift); Mask := Mask shr 1; end;
    while Mask and 1 <> 0 do begin Inc(BlueBits); Mask := Mask shr 1; end;
    BlueLevels := 1 shl BlueBits;
  end;
  if AlphaMask <> 0 then
  begin
    Mask := AlphaMask;
    while Mask and 1 = 0 do begin Inc(AlphaShift); Mask := Mask shr 1; end;
    while Mask and 1 <> 0 do begin Inc(AlphaBits); Mask := Mask shr 1; end;
    AlphaLevels := 1 shl AlphaBits;
  end;
  TotalChannelBits := RedBits + GreenBits + BlueBits + AlphaBits;
end;
{ @end $865198 }

{ @routine $865340 TPixelFormatGR_PackRgbBytes }
function TPixelFormatGR.PackRgbBytes(Red, Green, Blue: Byte): Cardinal;
begin
  Result := PackNormalizedRgb(Red / 255, Green / 255, Blue / 255);
end;
{ @end $865340 }

{ @routine $8653B0 TPixelFormatGR_PackRgb }
function TPixelFormatGR.PackRgb(Red, Green, Blue: Integer): Cardinal;
begin
  Result := PackNormalizedRgb(Red / 255, Green / 255, Blue / 255);
end;
{ @end $8653B0 }

{ @routine $865408 TPixelFormatGR_PackNormalizedRgb }
function TPixelFormatGR.PackNormalizedRgb(Red, Green, Blue: Double): Cardinal;
begin
  Result := (Cardinal(Trunc(Red * (RedLevels - 1))) shl RedShift) or
    (Cardinal(Trunc(Green * (GreenLevels - 1))) shl GreenShift) or
    (Cardinal(Trunc(Blue * (BlueLevels - 1))) shl BlueShift);
end;
{ @end $865408 }

{ @routine $86548C TPixelFormatGR_InterpolateRgb }
function TPixelFormatGR.InterpolateRgb(First, Second: Cardinal; Amount: Single): Cardinal;
var R1, G1, B1, R2, G2, B2: Integer;
begin
  R1 := (First shr RedShift) mod RedLevels;
  G1 := (First shr GreenShift) mod GreenLevels;
  B1 := (First shr BlueShift) mod BlueLevels;
  R2 := (Second shr RedShift) mod RedLevels;
  G2 := (Second shr GreenShift) mod GreenLevels;
  B2 := (Second shr BlueShift) mod BlueLevels;
  Result := (Cardinal(Trunc(R1 + (R2 - R1) * Amount)) shl RedShift) or
    (Cardinal(Trunc(G1 + (G2 - G1) * Amount)) shl GreenShift) or
    (Cardinal(Trunc(B1 + (B2 - B1) * Amount)) shl BlueShift);
end;
{ @end $86548C }

{ @routine $8655A4 TPixelFormatGR_UnpackRed }
function TPixelFormatGR.UnpackRed(Color: Cardinal): Byte;
begin
  if TotalChannelBits = 16 then Result := Color shr 8 else Result := Color shr 7;
end;
{ @end $8655A4 }

{ @routine $8655D4 TPixelFormatGR_UnpackGreen }
function TPixelFormatGR.UnpackGreen(Color: Cardinal): Byte;
begin
  if TotalChannelBits = 16 then Result := Color shr 3 else Result := Color shr 2;
end;
{ @end $8655D4 }

{ @routine $865604 TPixelFormatGR_UnpackBlue }
function TPixelFormatGR.UnpackBlue(Color: Cardinal): Byte;
begin
  Result := Byte(Color) shl 3;
end;
{ @end $865604 }

{ @routine $865620 TGraphBufGR_Create }
constructor TGraphBufGR.Create(AUseTexture: Boolean);
begin
  inherited Create;
  Width := 0; Height := 0; PitchBytes := 0; StorageKind := 0;
  BitsPerPixel := 0; BytesPerPixel := 0;
  UseTexture := AUseTexture; UsesTextureStorage := False; TextureFlag22 := False;
  Texture := nil; TextureLocked := False; TextureLockedReadOnly := False;
end;
{ @end $865620 }

{ @routine $8656C4 TGraphBufGR_Destroy }
destructor TGraphBufGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $8656C4 }

{ @routine $865700 TGraphBufGR_Clear }
procedure TGraphBufGR.Clear;
begin
  UnlockTexture;
  if StorageKind = 0 then
  begin
    if not UsesTextureStorage and (Pixels <> nil) then FreeEC(Pixels);
    Pixels := nil;
  end;
  Texture := nil; UsesTextureStorage := False; TextureFlag22 := False;
  Width := 0; Height := 0; PitchBytes := 0; StorageKind := 0;
  BitsPerPixel := 0; BytesPerPixel := 0;
end;
{ @end $865700 }

{ @routine $86578C TGraphBufGR_GetPixels }
function TGraphBufGR.GetPixels: Pointer;
begin
  LockTexture(False);
  Result := Pixels;
end;
{ @end $86578C }

{ @routine $8657B0 TGraphBufGR_AllocateNative }
procedure TGraphBufGR.AllocateNative(Width, Height: Integer);
var Locked: TD3DLockedRect;
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 16; BytesPerPixel := SizeOf(Word);
  if UseTexture then
  begin
    Texture := GR_CreateTexture(Width, Height, D3DFMT_R5G6B5, D3DPOOL_MANAGED);
    if Texture <> nil then
    begin
      Texture.LockRect(0, Locked, nil, D3DLOCK_READONLY);
      Self.PitchBytes := Locked.Pitch;
      Texture.UnlockRect(0);
      UsesTextureStorage := True;
    end;
  end
  else
  begin
  Self.PitchBytes := CurrentPixelFormat.BytesPerPixel * Width;
  if Self.PitchBytes and 3 <> 0 then Self.PitchBytes := Self.PitchBytes + 4 - (Self.PitchBytes and 3);
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
  if (Self.PitchBytes and 3 <> 0) or (Cardinal(Pixels) and 3 <> 0) then raise Exception.Create('TGraphBufGR.CreateN');
  end;
end;
{ @end $8657B0 }

{ @routine $865924 TGraphBufGR_AllocateNativePitch }
procedure TGraphBufGR.AllocateNativePitch(Width, Height, PitchBytes: Integer);
var Locked: TD3DLockedRect;
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 16; BytesPerPixel := SizeOf(Word);
  if UseTexture then
  begin
    Texture := GR_CreateTexture(Width, Height, D3DFMT_R5G6B5, D3DPOOL_MANAGED);
    if Texture <> nil then
    begin
      Texture.LockRect(0, Locked, nil, D3DLOCK_READONLY);
      Self.PitchBytes := Locked.Pitch;
      Texture.UnlockRect(0);
      UsesTextureStorage := True;
    end;
  end
  else
  begin
  Self.PitchBytes := PitchBytes;
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
  end;
end;
{ @end $865924 }

{ @routine $865A28 TGraphBufGR_AttachPixels }
procedure TGraphBufGR.AttachPixels(Width, Height, PitchBytes: Integer; Data: Pointer);
begin
  Clear;
  Pixels := Data; Self.Width := Width; Self.Height := Height; Self.PitchBytes := PitchBytes;
  StorageKind := 1;
  BytesPerPixel := Cardinal(Self.PitchBytes) div Cardinal(Self.Width);
  BitsPerPixel := BytesPerPixel * 8;
end;
{ @end $865A28 }

{ @routine $865A98 TGraphBufGR_AllocateRgbaTight }
procedure TGraphBufGR.AllocateRgbaTight(Width, Height: Integer);
var Locked: TD3DLockedRect;
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 32; BytesPerPixel := SizeOf(TColorRGBA);
  if UseTexture then
  begin
    Texture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    if Texture <> nil then
    begin
      Texture.LockRect(0, Locked, nil, D3DLOCK_READONLY);
      Self.PitchBytes := Locked.Pitch;
      Texture.UnlockRect(0);
      UsesTextureStorage := True;
    end;
  end
  else
  begin
  Self.PitchBytes := Width * SizeOf(TColorRGBA);
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
  end;
end;
{ @end $865A98 }

{ @routine $865B9C TGraphBufGR_AllocateRgba }
procedure TGraphBufGR.AllocateRgba(Width, Height, PitchBytes: Integer);
var Locked: TD3DLockedRect;
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 32; BytesPerPixel := SizeOf(TColorRGBA);
  if UseTexture then
  begin
    Texture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    if Texture <> nil then
    begin
      Texture.LockRect(0, Locked, nil, D3DLOCK_READONLY);
      Self.PitchBytes := Locked.Pitch;
      Texture.UnlockRect(0);
      UsesTextureStorage := True;
    end;
  end
  else
  begin
  Self.PitchBytes := PitchBytes;
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
  end;
end;
{ @end $865B9C }

{ @routine $865CA0 TGraphBufGR_AllocateRgbTight }
procedure TGraphBufGR.AllocateRgbTight(Width, Height: Integer);
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 24; BytesPerPixel := 3;
  Self.PitchBytes := Width * 3;
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
end;
{ @end $865CA0 }

{ @routine $865D04 TGraphBufGR_AllocateRgb }
procedure TGraphBufGR.AllocateRgb(Width, Height, PitchBytes: Integer);
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 24; BytesPerPixel := 3;
  Self.PitchBytes := PitchBytes;
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
end;
{ @end $865D04 }

{ @routine $865D68 TGraphBufGR_AllocateGrayscale }
procedure TGraphBufGR.AllocateGrayscale(Width, Height: Integer);
begin
  Clear;
  Self.Width := Width; Self.Height := Height;
  BitsPerPixel := 8; BytesPerPixel := 1;
  Self.PitchBytes := Width;
  if Self.PitchBytes and 3 <> 0 then Self.PitchBytes := Self.PitchBytes + 4 - (Self.PitchBytes and 3);
  Pixels := AllocEC(Self.PitchBytes * Self.Height);
  if (Self.PitchBytes and 3 <> 0) or (Cardinal(Pixels) and 3 <> 0) then raise Exception.Create('TGraphBufGR.CreateBYTE');
end;
{ @end $865D68 }

{ @routine $865E34 TGraphBufGR_LoadImage }
procedure TGraphBufGR.LoadImage(Buffer: TBufEC);
var Context: POkgfReadContext;
begin
  Clear;
  Context := BeginImageRead(Buffer.Data, Buffer.DataSize, Width, Height);
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBuf. Error load file 1 (buf size=' + IntToWideString(Buffer.DataSize) + ')');
  AllocateNative(Width, Height);
  Context := Pointer(ReadImagePixels(Context, GetPixels, PitchBytes, CurrentPixelFormat.RedMask,
    CurrentPixelFormat.GreenMask, CurrentPixelFormat.BlueMask, CurrentPixelFormat.AlphaMask, CurrentPixelFormat.BytesPerPixel));
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBuf. Error load file 2 (buf size=' + IntToWideString(Buffer.DataSize) + ')');
end;
{ @end $865E34 }

{ @routine $8660AC TGraphBufGR_LoadImageRgba }
procedure TGraphBufGR.LoadImageRgba(Buffer: TBufEC);
var Context: POkgfReadContext;
begin
  Clear;
  Context := BeginImageRead(Buffer.Data, Buffer.DataSize, Width, Height);
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBufRGBA. Error load file');
  AllocateRgbaTight(Width, Height);
  Context := Pointer(ReadImagePixels(Context, GetPixels, PitchBytes, $FF0000, $FF00, $FF, $FF000000, 4));
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBufRGBA. Error load file');
end;
{ @end $8660AC }

{ @routine $86619C TGraphBufGR_LoadImageRgb }
procedure TGraphBufGR.LoadImageRgb(Buffer: TBufEC);
var Context: POkgfReadContext;
begin
  Clear;
  Context := BeginImageRead(Buffer.Data, Buffer.DataSize, Width, Height);
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBufRGB. Error load file');
  AllocateRgbTight(Width, Height);
  Context := Pointer(ReadImagePixels(Context, GetPixels, PitchBytes, $FF, $FF00, $FF0000, 0, 3));
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBufRGB. Error load file');
end;
{ @end $86619C }

{ @routine $866284 TGraphBufGR_LoadImageGrayscale }
procedure TGraphBufGR.LoadImageGrayscale(Buffer: TBufEC);
var Context: POkgfReadContext;
begin
  Clear;
  Context := BeginImageRead(Buffer.Data, Buffer.DataSize, Width, Height);
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBufGrayscale. Error load file');
  AllocateGrayscale(Width, Height);
  Context := Pointer(ReadImagePixels(Context, GetPixels, PitchBytes, $FF, 0, 0, 0, 1));
  if Context = nil then raise Exception.Create('TGraphBufGR.LoadFromBufGrayscale. Error load file');
end;
{ @end $866284 }

{ @routine $866370 TGraphBufGR_GetPixel16 }
function TGraphBufGR.GetPixel16(X, Y: Integer): Cardinal;
var
  Data: PByteArray; Pixel: PWord;
begin
  LockTexture(True);
  Data := Pixels;
  Pixel := @Data^[Y * PitchBytes + X * SizeOf(Word)];
  Result := Pixel^;
end;
{ @end $866370 }

{ @routine $8663BC TGraphBufGR_SetPixel16 }
procedure TGraphBufGR.SetPixel16(X, Y: Integer; Color: Cardinal);
var
  Data: PByteArray; Pixel: PWord;
begin
  LockTexture(False);
  Data := Pixels;
  Pixel := @Data^[Y * PitchBytes + X * SizeOf(Word)];
  Pixel^ := Color;
end;
{ @end $8663BC }

{ @routine $866408 TGraphBufGR_GetBrightness16 }
function TGraphBufGR.GetBrightness16(X, Y: Integer): Cardinal;
var
  Color: Cardinal;
  Data: PByteArray; Pixel: PWord;
begin
  LockTexture(True);
  Result := 0;
  if (X < 0) or (Y < 0) or (Width - 1 < X) or (Height - 1 < Y) then Exit;
  Data := Pixels;
  Pixel := @Data^[Y * PitchBytes + X * SizeOf(Word)];
  Color := Pixel^;
  if CurrentPixelFormat.TotalChannelBits = 16 then
    Result := (Color and 31) + ((Color shr 6) and 31) + ((Color shr 11) and 31)
  else
    Result := (Color and 31) + ((Color shr 5) and 31) + ((Color shr 10) and 31);
end;
{ @end $866408 }

{ @routine $8664D8 TGraphBufGR_BlendPixel16 }
procedure TGraphBufGR.BlendPixel16(X, Y: Integer; Color: Cardinal; Alpha: Byte);
begin
  LockTexture(False);
  GR_Main.BlendPixel16(AddPointerOffset(Pixels, Y * PitchBytes + X * SizeOf(Word)), Color, Alpha);
end;
{ @end $8664D8 }

{ @routine $866530 TGraphBufGR_DrawAlphaLine16 }
procedure TGraphBufGR.DrawAlphaLine16(X1, Y1, X2, Y2: Integer; Color: Word; Alpha: Byte; Clip: TRect);
begin
  LockTexture(False);
  Ex_OKGR_Line_DrawClip_Alpha_16(Pixels, PitchBytes, X1, Y1, X2, Y2, Color, Alpha, Clip);
end;
{ @end $866530 }

{ @routine $86658C TGraphBufGR_GetPixel32 }
function TGraphBufGR.GetPixel32(X, Y: Integer): Cardinal;
begin
  LockTexture(True);
  Result := ReadDWordEC(AddPointerOffset(Pixels, Y * PitchBytes + X * SizeOf(TColorRGBA)));
end;
{ @end $86658C }

{ @routine $8665D8 TGraphBufGR_DrawHorizontalLine16 }
procedure TGraphBufGR.DrawHorizontalLine16(X, Y, Count: Integer; Color: Cardinal);
var Data: Pointer;
begin
  if Count = 0 then Exit;
  if Count < 0 then
  begin
    X := X + Count + 1;
    Count := -Count;
  end;
  LockTexture(False);
  X := Y * PitchBytes + X * SizeOf(Word);
  Data := Pixels;
  // Native bug: EDI is clobbered without saving/restoring it, violating
  // Delphi's callee-save convention. The original function has no outer save.
  // DCC32 18.5 O+ callers can retain a destination pointer in EDI; subsequent
  // writes then use the end of this line instead. Recompiling this routine
  // with O+ still leaves EDI unpreserved.
  asm
    MOV EDI, X
    MOV ECX, Count
    ADD EDI, Data
    MOV EAX, Color
    CLD
    REP STOSW
  end;
end;
{ @end $8665D8 }

{ @routine $86663C TGraphBufGR_DrawVerticalLine16 }
procedure TGraphBufGR.DrawVerticalLine16(X, Y, Count: Integer; Color: Cardinal);
var Data: Pointer; Step: Integer;
begin
  if Count = 0 then Exit;
  if Count < 0 then
  begin
    Y := Y + Count + 1;
    Count := -Count;
  end;
  LockTexture(False);
  X := Y * PitchBytes + X * SizeOf(Word);
  Data := Pixels;
  Step := PitchBytes;
  // Native bug: EDI and EBX are clobbered without saving/restoring them,
  // violating Delphi's callee-save convention; there are no outer saves.
  // DCC32 18.5 O+ callers can retain Self in EBX and a destination in EDI:
  // after this call they may dereference PitchBytes as Self or write through
  // the advanced pixel pointer. O+ recompilation adds an outer EBX save for
  // Pascal's Self register in the probe, but still leaves EDI unpreserved.
  asm
    MOV EDI, X
    MOV ECX, Count
    ADD EDI, Data
    MOV EAX, Color
    MOV EBX, Step
  @@Next:
    MOV [EDI], AX
    ADD EDI, EBX
    LOOP @@Next
  end;
end;
{ @end $86663C }

{ @routine $8666B0 TGraphBufGR_DrawHorizontalLine16Clipped }
procedure TGraphBufGR.DrawHorizontalLine16Clipped(X, Y, Count: Integer; Color: Cardinal; Clip: TRect);
begin
  if Count = 0 then Exit;
  if Count < 0 then begin X := X + Count + 1; Count := -Count; end;
  if (Y < Clip.Top) or (Y >= Clip.Bottom) or (X >= Clip.Right) or (X + Count <= Clip.Left) then Exit;
  if X < Clip.Left then begin Dec(Count, Clip.Left - X); X := Clip.Left; end;
  if X + Count > Clip.Right then Dec(Count, X + Count - Clip.Right);
  DrawHorizontalLine16(X, Y, Count, Color);
end;
{ @end $8666B0 }

{ @routine $866754 TGraphBufGR_DrawVerticalLine16Clipped }
procedure TGraphBufGR.DrawVerticalLine16Clipped(X, Y, Count: Integer; Color: Cardinal; Clip: TRect);
begin
  if Count = 0 then Exit;
  if Count < 0 then begin Y := Y + Count + 1; Count := -Count; end;
  if (X < Clip.Left) or (X >= Clip.Right) or (Y >= Clip.Bottom) or (Y + Count <= Clip.Top) then Exit;
  if Y < Clip.Top then begin Dec(Count, Clip.Top - Y); Y := Clip.Top; end;
  if Y + Count > Clip.Bottom then Dec(Count, Y + Count - Clip.Bottom);
  DrawVerticalLine16(X, Y, Count, Color);
end;
{ @end $866754 }

{ @routine $8667F8 TGraphBufGR_DrawLine16 }
procedure TGraphBufGR.DrawLine16(First, Last: TPoint; Color: Cardinal);
begin
  if First.Y = Last.Y then DrawHorizontalLine16(First.X, First.Y, Last.X - First.X + 1, Color)
  else if First.X = Last.X then DrawVerticalLine16(First.X, First.Y, Last.Y - First.Y + 1, Color)
  else
  begin
    LockTexture(False);
    Ex_OKGR_Line_Draw_WORD(Pixels, PitchBytes, First.X, First.Y, Last.X, Last.Y, Color);
  end;
end;
{ @end $8667F8 }

{ @routine $866890 TGraphBufGR_DrawAnimatedLine16 }
procedure TGraphBufGR.DrawAnimatedLine16(First, Last: TPoint; Color: Cardinal; Phase: Integer; Clip: TRect);
begin
  LockTexture(False);
  Ex_OKGR_AnimLine_Draw_16(Pixels, PitchBytes, First.X, First.Y, Last.X, Last.Y, Color, Phase, Clip);
end;
{ @end $866890 }

{ @routine $8668F4 TGraphBufGR_DrawShadowLine16 }
procedure TGraphBufGR.DrawShadowLine16(First, Last: TPoint; Color: Cardinal; Phase: Integer; Clip: TRect; ShadowPixels: Pointer; ShadowPitch: Integer);
begin
  LockTexture(False);
  Ex_OKGR_AnimShadowLine_Draw_16(Pixels, PitchBytes, First.X, First.Y, Last.X, Last.Y, Color, Phase, Clip, ShadowPixels, ShadowPitch);
end;
{ @end $8668F4 }

{ @routine $866960 TGraphBufGR_DrawAlphaTrapezium16 }
procedure TGraphBufGR.DrawAlphaTrapezium16(X1, Y1, X2, Y2, X3, X4: Integer; Color: Word; Alpha: Byte; Clip: TRect);
begin
  LockTexture(False);
  if Alpha = 64 then Ex_OKGR_Alpha64Trapezium_16(Pixels, PitchBytes, X1, Y1, X2, Y2, X3, X4, Color, Clip)
  else if Alpha = 128 then Ex_OKGR_Alpha128Trapezium_16(Pixels, PitchBytes, X1, Y1, X2, Y2, X3, X4, Color, Clip);
end;
{ @end $866960 }

{ @routine $866A00 TGraphBufGR_DrawLine16Clipped }
procedure TGraphBufGR.DrawLine16Clipped(First, Last: TPoint; Color: Cardinal; Clip: TRect);
var InclusiveClip: TRect;
begin
  if (First.X >= Clip.Left) and (First.Y >= Clip.Top) and (First.X < Clip.Right) and (First.Y < Clip.Bottom) and
    (Last.X >= Clip.Left) and (Last.Y >= Clip.Top) and (Last.X < Clip.Right) and (Last.Y < Clip.Bottom) then
    DrawLine16(First, Last, Color)
  else if First.Y = Last.Y then DrawHorizontalLine16Clipped(First.X, First.Y, Last.X - First.X + 1, Color, Clip)
  else if First.X = Last.X then DrawVerticalLine16Clipped(First.X, First.Y, Last.Y - First.Y + 1, Color, Clip)
  else
  begin
    InclusiveClip.Left := Clip.Left; InclusiveClip.Top := Clip.Top;
    InclusiveClip.Right := Clip.Right - 1; InclusiveClip.Bottom := Clip.Bottom - 1;
    LockTexture(False);
    Ex_OKGR_Line_DrawClip_WORD(Pixels, PitchBytes, First.X, First.Y, Last.X, Last.Y, Color, InclusiveClip);
  end;
end;
{ @end $866A00 }

{ @routine $866DB0 TGraphBufGR_DrawAntialiasedLine }
procedure TGraphBufGR.DrawAntialiasedLine(FirstPoint, SecondPoint: TPoint; Color: Cardinal);
var
  Slope, DX, DY, Gap, EndX, EndY, InterY, Coverage1, Coverage2: Double;
  X, FirstX, LastX, FirstY, LastY: Integer;
  Steep: Boolean;
  Temp, X1, Y1, X2, Y2: Double;

  // @nested $866B20 LineFraction
  function LineFraction(Value: Double): Double; // @addr $866B20 @calls "0x00867012 0x00867056 0x00867070 0x00867182 0x008671CB 0x008671E2 0x008672E3 0x008672FD"
  begin
    Result := Value - Floor(Value);
  end;

  // @nested $866B8C PlotLinePixel
  procedure PlotLinePixel(X, Y: Integer; Color: Cardinal; Alpha: Integer); // @addr $866B8C @calls "0x008670A3 0x008670CA 0x008670F2 0x00867119 0x0086721E 0x00867251 0x00867287 0x008672BC 0x00867330 0x00867357 0x0086737F 0x008673A6"
  var Source, Dest: PColorRGBA; Denominator: Cardinal;

    // @nested $866B4C BlendLineChannel
    function BlendLineChannel(DestColor, DestAlpha, SourceColor, SourceAlpha, Denominator: Cardinal): Cardinal; // @addr $866B4C @calls "0x00866D3F 0x00866D6E 0x00866D9E"
    begin
      Result := ((255 - SourceAlpha) * DestColor * DestAlpha + SourceAlpha * SourceColor * 255) div Denominator;
    end;

  begin
    if (Alpha = 0) or (X < 0) or (Y < 0) or
      (Cardinal(Width) <= Cardinal(X)) or (Cardinal(Height) <= Cardinal(Y)) then Exit;
    Source := @Color;
    Source.A := Alpha;
    Dest := AddPointerOffset(Pixels, PitchBytes * Y + X * SizeOf(TColorRGBA));
    if (Dest.A = 0) or (Source.A = 255) then Dest^ := Source^
    else if Dest.A = 255 then
    begin
      Dest.R := ((255 - Source.A) * Dest.R + Source.R * Source.A) div 255;
      Dest.G := ((255 - Source.A) * Dest.G + Source.G * Source.A) div 255;
      Dest.B := ((255 - Source.A) * Dest.B + Source.B * Source.A) div 255;
    end
    else
    begin
      Denominator := 255 * 255 - (255 - Source.A) * (255 - Dest.A);
      Dest.R := BlendLineChannel(Dest.R, Dest.A, Source.R, Source.A, Denominator);
      Dest.G := BlendLineChannel(Dest.G, Dest.A, Source.G, Source.A, Denominator);
      Dest.B := BlendLineChannel(Dest.B, Dest.A, Source.B, Source.A, Denominator);
    end;
  end;

begin
  LockTexture(False);
  X1 := FirstPoint.X; Y1 := FirstPoint.Y; X2 := SecondPoint.X; Y2 := SecondPoint.Y;
  DX := X2 - X1; DY := Y2 - Y1;
  if (DX = 0) and (DY = 0) then Exit;
  if Abs(DX) > Abs(DY) then Steep := False
  else
  begin
    Steep := True;
    Temp := X1; X1 := Y1; Y1 := Temp;
    Temp := X2; X2 := Y2; Y2 := Temp;
    Temp := DX; DX := DY; DY := Temp;
  end;
  if X1 > X2 then
  begin
    Temp := X1; X1 := X2; X2 := Temp;
    Temp := Y1; Y1 := Y2; Y2 := Temp;
    DX := X2 - X1; DY := Y2 - Y1;
  end;
  Slope := DY / DX;
  EndX := Floor(X1 + 0.5);
  EndY := Y1 + (EndX - X1) * Slope;
  Gap := 1 - LineFraction(X1 + 0.5);
  FirstX := Floor(X1 + 0.5); FirstY := Floor(EndY);
  Coverage1 := (1 - LineFraction(EndY)) * Gap;
  Coverage2 := LineFraction(EndY) * Gap;
  if Steep then
  begin
    PlotLinePixel(FirstY, FirstX, Color, Ceil(Coverage1 * 255));
    PlotLinePixel(FirstY + 1, FirstX, Color, Ceil(Coverage2 * 255));
  end
  else
  begin
    PlotLinePixel(FirstX, FirstY, Color, Ceil(Coverage1 * 255));
    PlotLinePixel(FirstX, FirstY + 1, Color, Ceil(Coverage2 * 255));
  end;
  X := FirstX + 1;
  InterY := EndY + Slope;
  EndX := Floor(X2 + 0.5);
  EndY := Y2 + (EndX - X2) * Slope;
  Gap := 1 - LineFraction(X2 - 0.5);
  LastX := Floor(X2 + 0.5); LastY := Floor(EndY);
  while LastX - 1 >= X do
  begin
    Coverage1 := 1 - LineFraction(InterY); Coverage2 := LineFraction(InterY);
    if Steep then
    begin
      PlotLinePixel(Floor(InterY), X, Color, Ceil(Coverage1 * 255));
      PlotLinePixel(Floor(InterY) + 1, X, Color, Ceil(Coverage2 * 255));
    end
    else
    begin
      PlotLinePixel(X, Floor(InterY), Color, Ceil(Coverage1 * 255));
      PlotLinePixel(X, Floor(InterY) + 1, Color, Ceil(Coverage2 * 255));
    end;
    InterY := InterY + Slope;
    Inc(X);
  end;
  Coverage1 := (1 - LineFraction(EndY)) * Gap;
  Coverage2 := LineFraction(EndY) * Gap;
  if Steep then
  begin
    PlotLinePixel(LastY, LastX, Color, Ceil(Coverage1 * 255));
    PlotLinePixel(LastY + 1, LastX, Color, Ceil(Coverage2 * 255));
  end
  else
  begin
    PlotLinePixel(LastX, LastY, Color, Ceil(Coverage1 * 255));
    PlotLinePixel(LastX, LastY + 1, Color, Ceil(Coverage2 * 255));
  end;
end;
{ @end $866DB0 }

{ @routine $8673C4 TGraphBufGR_ClearPixels }
procedure TGraphBufGR.ClearPixels;
begin
  LockTexture(False);
  FillChar(Pixels^, PitchBytes * Height, 0);
end;
{ @end $8673C4 }

{ @routine $8673F4 TGraphBufGR_FillPixels }
procedure TGraphBufGR.FillPixels(Value: Byte);
begin
  LockTexture(False);
  FillMemory(Pixels, PitchBytes * Height, Value);
end;
{ @end $8673F4 }

{ @routine $86742C TGraphBufGR_FillPixels16 }
procedure TGraphBufGR.FillPixels16(Color: Word);
begin
  LockTexture(False);
  Ex_OKGR_Fill_WORD(Pixels, PitchBytes, Width, Height, Color);
end;
{ @end $86742C }

{ @routine $86746C TGraphBufGR_FillRect32 }
procedure TGraphBufGR.FillRect32(Rect: TRect; Color: Cardinal);
var Data: Pointer; Rows, Columns, RowSkip: Integer;
begin
  LockTexture(False);
  Columns := Rect.Right - Rect.Left;
  Rows := Rect.Bottom - Rect.Top;
  RowSkip := PitchBytes - Columns * SizeOf(TColorRGBA);
  Data := Pointer(Rect.Top * PitchBytes + Rect.Left * SizeOf(TColorRGBA) + PAnsiChar(Pixels));
  // Native precondition: Columns and Rows must be positive. Neither is checked
  // before writing; zero wraps on DEC and the loop writes beyond the rectangle.
  asm
    PUSH ESI
    PUSH EDI
    PUSH EAX
    PUSH ECX
    PUSH EBX
    PUSH EDX
    MOV EAX, Color
    MOV EDI, Data
    MOV EDX, Rows
    MOV ECX, Columns
    MOV EBX, ECX
    MOV ESI, RowSkip
  @@Pixel:
    MOV [EDI], EAX
    ADD EDI, 4
    DEC ECX
    JNZ @@Pixel
    MOV ECX, EBX
    ADD EDI, ESI
    DEC EDX
    JNZ @@Pixel
    POP EDX
    POP EBX
    POP ECX
    POP EAX
    POP EDI
    POP ESI
  end;
end;
{ @end $86746C }

{ @routine $8674FC TGraphBufGR_ScaleAlpha }
procedure TGraphBufGR.ScaleAlpha(Rect: TRect; Alpha: Byte);
var Data: Pointer; Rows, Columns: Integer; Table: Pointer; RowSkip: Integer;
begin
  LockTexture(False);
  Columns := Rect.Right - Rect.Left; Rows := Rect.Bottom - Rect.Top;
  RowSkip := PitchBytes - Columns * SizeOf(TColorRGBA);
  Data := Pointer(Rect.Top * PitchBytes + Rect.Left * SizeOf(TColorRGBA) + 3 + PAnsiChar(Pixels));
  Table := Pointer(PAnsiChar(Ex_OKGF_MulTable256x256) + Integer(Alpha) shl 8);
  // Native precondition: Columns and Rows must be positive. Neither is checked
  // before writing; zero wraps on DEC and the loop writes beyond the rectangle.
  asm
    PUSH ESI
    PUSH EDI
    PUSH EAX
    PUSH ECX
    PUSH EBX
    PUSH EDX
    MOV EDI, Data
    MOV EDX, Rows
    MOV ECX, Columns
    MOV EBX, ECX
    MOV ESI, Table
  @@Pixel:
    XOR EAX, EAX
    MOV AL, [EDI]
    MOV AL, [ESI + EAX]
    MOV [EDI], AL
    ADD EDI, 4
    DEC ECX
    JNZ @@Pixel
    MOV ECX, EBX
    ADD EDI, RowSkip
    DEC EDX
    JNZ @@Pixel
    POP EDX
    POP EBX
    POP ECX
    POP EAX
    POP EDI
    POP ESI
  end;
end;
{ @end $8674FC }

{ @routine $8675A8 TGraphBufGR_FlipHorizontal16 }
procedure TGraphBufGR.FlipHorizontal16;
var LeftRow, RightRow, LeftPixel, RightPixel: PWord; Temp: Word; X, Y: Integer;
begin
  LockTexture(False);
  LeftRow := Pixels;
  RightRow := Pointer(PAnsiChar(Pixels) + (Width - 1) * SizeOf(Word));
  for Y := 0 to Height - 1 do
  begin
    LeftPixel := LeftRow; RightPixel := RightRow;
    for X := 0 to (Width shr 1) - 1 do
    begin
      Temp := RightPixel^; RightPixel^ := LeftPixel^; PPixelWordsGR(LeftPixel)^[0] := Temp;
      Inc(LeftPixel); Dec(RightPixel);
    end;
    Inc(PByte(LeftRow), PitchBytes); Inc(PByte(RightRow), PitchBytes);
  end;
end;
{ @end $8675A8 }

{ @routine $867660 TGraphBufGR_RotateLeft16 }
procedure TGraphBufGR.RotateLeft16;
var X, Y: Integer; Source: Pointer; DestRows: Integer; Dest, NewPixels: Pointer; NewWidth, NewHeight, NewPitch: Integer;
begin
  if (StorageKind = 1) or (Cardinal(Width) < 1) or (Cardinal(Height) < 1) then Exit;
  NewWidth := Height; NewHeight := Width; NewPitch := NewWidth * SizeOf(Word);
  NewPixels := AllocEC(NewHeight * NewPitch);
  Source := Pixels; Y := Height; DestRows := NewHeight;
  Dest := AddPointerOffset(NewPixels, (NewHeight - 1) * NewPitch);
  while Y > 0 do
  begin
    X := Width;
    while X > 0 do
    begin
      WriteWordEC(Dest, ReadWordEC(Source));
      Dec(DestRows);
      Dest := AddPointerOffset(Dest, -NewPitch);
      if DestRows <= 0 then
      begin
        DestRows := NewHeight;
        Dest := AddPointerOffset(Dest, NewPitch * NewHeight + SizeOf(Word));
      end;
      Source := AddPointerOffset(Source, SizeOf(Word));
      Dec(X);
    end;
    Source := AddPointerOffset(Source, PitchBytes - Width * SizeOf(Word));
    Dec(Y);
  end;
  FreeEC(Pixels);
  Pixels := NewPixels; Width := NewWidth; Height := NewHeight; PitchBytes := NewPitch;
end;
{ @end $867660 }

{ @routine $8677D0 TGraphBufGR_Stretch16 }
procedure TGraphBufGR.Stretch16(Width, Height: Cardinal);
var Data: Pointer;
begin
  if (Width = Cardinal(Self.Width)) and (Height = Cardinal(Self.Height)) then Exit;
  if (Cardinal(Self.Width) < 1) or (Cardinal(Self.Height) < 1) or (Width < 1) or (Height < 1) then Exit;
  Data := AllocEC(Width * Height * SizeOf(Word));
  Ex_OKGR_StretchGdi_WORD(Data, Width, Height, Pixels, Self.Width, Self.Height);
  FreeEC(Pixels);
  Pixels := Data; Self.Width := Width; Self.Height := Height; PitchBytes := Width * SizeOf(Word);
end;
{ @end $8677D0 }

{ @routine $867880 TGraphBufGR_ConvertRgbTo565 }
procedure TGraphBufGR.ConvertRgbTo565;
var Data: Pointer; NewPitch: Integer; NewTexture: IDirect3DTexture9; Locked: TD3DLockedRect;
begin
  if (Cardinal(Width) < 1) or (Cardinal(Height) < 1) then Exit;
  if UseTexture then
  begin
    NewTexture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    NewTexture.LockRect(0, Locked, nil, 0);
    NewPitch := Locked.Pitch; Data := Locked.Bits;
  end
  else
  begin
    NewPitch := Width * SizeOf(Word); Data := AllocEC(Height * NewPitch);
  end;
  Ex_OKGF_ConvertRGBto565(Pixels, Data, NewPitch, Width, Height);
  if (StorageKind = 0) and (Pixels <> nil) then FreeEC(Pixels);
  if UseTexture then
  begin
    NewTexture.UnlockRect(0); Texture := NewTexture;
  end
  else Pixels := Data;
  PitchBytes := NewPitch; BitsPerPixel := 16; BytesPerPixel := SizeOf(Word);
end;
{ @end $867880 }

{ @routine $8679C0 TGraphBufGR_Convert565ToRgb }
procedure TGraphBufGR.Convert565ToRgb;
var Data: Pointer; NewPitch: Integer;
begin
  if (Cardinal(Width) < 1) or (Cardinal(Height) < 1) then Exit;
  LockTexture(True);
  NewPitch := Width * 3; Data := AllocEC(Height * NewPitch);
  Ex_OKGF_Convert565toRGB(Pixels, PitchBytes, Data, NewPitch, Width, Height);
  UnlockTexture;
  if UsesTextureStorage then
  begin Texture := nil; UsesTextureStorage := False; end
  else if (StorageKind = 0) and (Pixels <> nil) then FreeEC(Pixels);
  Pixels := Data; PitchBytes := NewPitch; BitsPerPixel := 24; BytesPerPixel := 3;
end;
{ @end $8679C0 }

{ @routine $867A9C TGraphBufGR_ShiftLight16 }
procedure TGraphBufGR.ShiftLight16(Shift: Integer; Rect: TRect);
begin
  LockTexture(False);
  if Pixels = nil then Exit;
  Ex_OKGR_ShrLight_16(AddPointerOffset(Pixels, Rect.Left * SizeOf(Word) + Rect.Top * PitchBytes), PitchBytes,
    Rect.Right - Rect.Left, Rect.Bottom - Rect.Top, Shift);
end;
{ @end $867A9C }

{ @routine $867B0C TGraphBufGR_DrawCircle16 }
procedure TGraphBufGR.DrawCircle16(Center: TPoint; Radius: Integer; OutlineColor, FillColor: Cardinal; Clip: TRect);
var InclusiveClip: TRect;
begin
  LockTexture(False);
  InclusiveClip.Left := Clip.Left; InclusiveClip.Top := Clip.Top;
  InclusiveClip.Right := Clip.Right - 1; InclusiveClip.Bottom := Clip.Bottom - 1;
  Ex_OKGR_Circle_DrawFillClip_WORD(Pixels, PitchBytes, Center.X, Center.Y, Radius, FillColor, InclusiveClip);
  if OutlineColor <> FillColor then
    Ex_OKGR_Circle_DrawClip_WORD(Pixels, PitchBytes, Center.X, Center.Y, Radius, OutlineColor, InclusiveClip);
end;
{ @end $867B0C }

{ @routine $867BAC TGraphBufGR_DrawCircle8 }
procedure TGraphBufGR.DrawCircle8(Center: TPoint; Radius: Integer; OutlineColor, FillColor: Cardinal; Clip: TRect);
var InclusiveClip: TRect;
begin
  LockTexture(False);
  InclusiveClip.Left := Clip.Left; InclusiveClip.Top := Clip.Top;
  InclusiveClip.Right := Clip.Right - 1; InclusiveClip.Bottom := Clip.Bottom - 1;
  Ex_OKGR_Circle_DrawFillClip_BYTE(Pixels, PitchBytes, Center.X, Center.Y, Radius, FillColor, InclusiveClip);
  if OutlineColor <> FillColor then
    Ex_OKGR_Circle_DrawClip_BYTE(Pixels, PitchBytes, Center.X, Center.Y, Radius, OutlineColor, InclusiveClip);
end;
{ @end $867BAC }

{ @routine $867C48 TGraphBufGR_ApplyOperations }
procedure TGraphBufGR.ApplyOperations(const Operations: WideString);
var Count, i: Integer; Part, Value: WideString;
begin
  Count := CountDelimitedPartsW(Operations, '&');
  for i := 0 to Count - 1 do
  begin
    Part := ExtractDelimitedPartW(Operations, i, '&');
    if CountDelimitedPartsW(Part, '=') <= 1 then
    begin
      if Part = '270' then RotateLeft16;
    end
    else
    begin
      Value := ExtractDelimitedPartW(Part, 0, '=');
      if Value = 'Stretch' then
      begin
        Value := ExtractDelimitedPartW(Part, 1, '=');
        if CountDelimitedPartsW(Value, ',') > 1 then
          Stretch16(StrToInt(ExtractDelimitedPartW(Value, 0, ',')), StrToInt(ExtractDelimitedPartW(Value, 1, ',')));
      end;
    end;
  end;
end;
{ @end $867C48 }

{ @routine $867E08 TGraphBufGR_RescaleRgb }
procedure TGraphBufGR.RescaleRgb(Width, Height: Integer);
var Data: Pointer;
begin
  if (Cardinal(Self.Width) < 1) or (Cardinal(Self.Height) < 1) or (Width < 1) or (Height < 1) then Exit;
  if (Self.Width = Width) and (Self.Height = Height) then Exit;
  Data := AllocEC(Width * 3 * Height);
  Ex_OKGF_Rescale(Data, Width, Height, Width * 3, Pixels, Self.Width, Self.Height, PitchBytes, 3, 5);
  if StorageKind = 0 then FreeEC(Pixels);
  StorageKind := 0;
  Pixels := Data; Self.Width := Width; Self.Height := Height; PitchBytes := Width * 3;
end;
{ @end $867E08 }

{ @routine $867EEC TGraphBufGR_RescaleRgba }
procedure TGraphBufGR.RescaleRgba(Width, Height, Filter: Integer);
var Data: Pointer;
begin
  if (Cardinal(Self.Width) < 1) or (Cardinal(Self.Height) < 1) or (Width < 1) or (Height < 1) then Exit;
  if (Self.Width = Width) and (Self.Height = Height) then Exit;
  Data := AllocEC(Width * SizeOf(TColorRGBA) * Height);
  Ex_OKGF_Rescale(Data, Width, Height, Width * SizeOf(TColorRGBA), Pixels, Self.Width, Self.Height, PitchBytes, 4, Filter);
  if StorageKind = 0 then FreeEC(Pixels);
  StorageKind := 0;
  Pixels := Data; Self.Width := Width; Self.Height := Height; PitchBytes := Width * SizeOf(TColorRGBA);
end;
{ @end $867EEC }

{ @routine $867FD4 TGraphBufGR_RescaleBilinearRgba }
procedure TGraphBufGR.RescaleBilinearRgba(Width, Height: Integer);
var
  X, Y, SourceX, YPosition, YStep, XStep, PixelX, FractionX: Integer;
  BottomWeight, TopWeight, TopLeftWeight, TopRightWeight, BottomLeftWeight, BottomRightWeight: Integer;
  TopRow, BottomRow: PColorRGBAArray;
  Dest: PColorRGBA;
  Data: Pointer;
begin
  if (Cardinal(Self.Width) < 1) or (Cardinal(Self.Height) < 1) or (Width < 1) or (Height < 1) then Exit;
  if (Self.Width = Width) and (Self.Height = Height) then Exit;
  Data := AllocEC(Width * SizeOf(TColorRGBA) * Height);
  YPosition := 0;
  XStep := ((Self.Width - 1) shl 16) div Width;
  YStep := ((Self.Height - 1) shl 16) div Height;
  Dest := Data;
  for Y := 0 to Height - 1 do
  begin
    SourceX := YPosition shr 16;
    TopRow := AddPointerOffset(Pixels, PitchBytes * SourceX);
    if Self.Height - 1 > SourceX then Inc(SourceX);
    BottomRow := AddPointerOffset(Pixels, PitchBytes * SourceX);
    SourceX := 0;
    BottomWeight := (YPosition and $FFFF) + 1;
    TopWeight := ((not YPosition) and $FFFF) + 1;
    for X := 0 to Width - 1 do
    begin
      PixelX := SourceX shr 16;
      FractionX := SourceX and $FFFF;
      TopRightWeight := (TopWeight * FractionX) shr 16;
      TopLeftWeight := TopWeight - TopRightWeight;
      BottomRightWeight := (BottomWeight * FractionX) shr 16;
      BottomLeftWeight := BottomWeight - BottomRightWeight;
      Dest.R := (TopRow^[PixelX].R * TopLeftWeight + TopRow^[PixelX + 1].R * TopRightWeight +
        BottomRow^[PixelX].R * BottomLeftWeight + BottomRow^[PixelX + 1].R * BottomRightWeight) shr 16;
      Dest.G := (TopRow^[PixelX].G * TopLeftWeight + TopRow^[PixelX + 1].G * TopRightWeight +
        BottomRow^[PixelX].G * BottomLeftWeight + BottomRow^[PixelX + 1].G * BottomRightWeight) shr 16;
      Dest.B := (TopRow^[PixelX].B * TopLeftWeight + TopRow^[PixelX + 1].B * TopRightWeight +
        BottomRow^[PixelX].B * BottomLeftWeight + BottomRow^[PixelX + 1].B * BottomRightWeight) shr 16;
      Dest.A := (TopRow^[PixelX].A * TopLeftWeight + TopRow^[PixelX + 1].A * TopRightWeight +
        BottomRow^[PixelX].A * BottomLeftWeight + BottomRow^[PixelX + 1].A * BottomRightWeight) shr 16;
      Inc(SourceX, XStep);
      Inc(Dest);
    end;
    Inc(YPosition, YStep);
  end;
  if StorageKind = 0 then FreeEC(Pixels);
  StorageKind := 0;
  Pixels := Data; Self.Width := Width; Self.Height := Height; PitchBytes := Width * SizeOf(TColorRGBA);
end;
{ @end $867FD4 }

{ @routine $8682D8 TGraphBufGR_FillPolygon32 }
procedure TGraphBufGR.FillPolygon32(Points: array of TPoint; Color: Cardinal);
var
  i, Count, Y, NextY, LeftX, NextLeftX, RightX, NextRightX: Integer;
  Top, Bottom, LeftStart, RightStart, LeftEnd, RightEnd: Integer;
  Clip: TRect;
begin
  Count := Length(Points);
  if Count < 3 then Exit;
  Clip := Classes.Rect(0, 0, Width, Height);
  Top := 0; Bottom := 0;
  for i := 1 to Count - 1 do
  begin
    if Points[i].Y < Points[Top].Y then Top := i;
    if Points[i].Y > Points[Bottom].Y then Bottom := i;
  end;
  if Points[Top].Y = Points[Bottom].Y then Exit;
  LeftStart := Top; RightStart := Top; LeftEnd := Top; RightEnd := Top;
  LeftX := Points[Top].X; RightX := LeftX; Y := Points[Top].Y;
  repeat
    if Points[LeftEnd].Y = Y then
    begin
      while Points[LeftEnd].Y = Y do
      begin
        LeftStart := LeftEnd;
        Dec(LeftEnd);
        if LeftEnd < 0 then LeftEnd := Count - 1;
      end;
      if Points[Top].Y = Y then LeftX := Points[LeftStart].X;
    end;
    if Points[RightEnd].Y = Y then
    begin
      while Points[RightEnd].Y = Y do
      begin
        RightStart := RightEnd;
        Inc(RightEnd);
        if RightEnd >= Count then RightEnd := 0;
      end;
      if Points[Top].Y = Y then RightX := Points[RightStart].X;
    end;
    if Points[RightEnd].Y < Points[LeftEnd].Y then
    begin
      NextY := Points[RightEnd].Y;
      NextRightX := Points[RightEnd].X;
      NextLeftX := (Points[RightEnd].Y - Points[LeftStart].Y) *
        (Points[LeftEnd].X - Points[LeftStart].X) div (Points[LeftEnd].Y - Points[LeftStart].Y) + Points[LeftStart].X;
    end
    else
    begin
      NextY := Points[LeftEnd].Y;
      NextLeftX := Points[LeftEnd].X;
      NextRightX := (Points[RightEnd].X - Points[RightStart].X) *
        (Points[LeftEnd].Y - Points[RightStart].Y) div (Points[RightEnd].Y - Points[RightStart].Y) + Points[RightStart].X;
    end;
    if (LeftX < RightX) = (NextLeftX < NextRightX) then
      Ex_OKGR_FillTrapezium_DWORD(Pixels, PitchBytes, RightX, LeftX, Y, NextRightX, NextLeftX, NextY, Color, Clip)
    else
      Ex_OKGR_FillTrapezium_DWORD(Pixels, PitchBytes, LeftX, RightX, Y, NextLeftX, NextRightX, NextY, Color, Clip);
    LeftX := NextLeftX; RightX := NextRightX; Y := NextY;
  until Points[Bottom].Y = Y;
end;
{ @end $8682D8 }

{ @routine $868600 TGraphBufGR_GetPixelCentroid }
function TGraphBufGR.GetPixelCentroid: TPoint;
var X, Y, Count: Integer;
begin
  Result.X := 0; Result.Y := 0; Count := 0;
  for Y := 0 to Height - 1 do
    for X := 0 to Width - 1 do
      if GetPixel32(X, Y) <> 0 then
      begin
        Inc(Result.X, X); Inc(Result.Y, Y); Inc(Count);
      end;
  if Count < 1 then Result := Classes.Point(0, 0)
  else Result := Classes.Point(Result.X div Count, Result.Y div Count);
end;
{ @end $868600 }

{ @routine $8686C8 TGraphBufGR_CopyRect32 }
procedure TGraphBufGR.CopyRect32(Dest: TPoint; Source: TGraphBufGR; Rect: TRect);
var Src, Dst: Pointer; Columns: Integer; Rows, SrcSkip, DstSkip: Integer;
begin
  Src := Pointer(PAnsiChar(Source.GetPixels) + (Rect.Top * Source.PitchBytes + Rect.Left * SizeOf(TColorRGBA)));
  Columns := Rect.Right - Rect.Left; Rows := Rect.Bottom - Rect.Top;
  if (Columns = 0) or (Rows = 0) then Exit;
  SrcSkip := Source.PitchBytes - Columns * SizeOf(TColorRGBA);
  Dst := Pointer(PAnsiChar(GetPixels) + (Dest.Y * PitchBytes + Dest.X * SizeOf(TColorRGBA)));
  DstSkip := PitchBytes - Columns * SizeOf(TColorRGBA);
  asm
    PUSH EAX
    PUSH ECX
    PUSH EBX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    MOV ESI, Src
    MOV EDI, Dst
    MOV ECX, Columns
    MOV EDX, Rows
    MOV EBX, ECX
  @@Pixel:
    MOV EAX, [ESI]
    MOV [EDI], EAX
    ADD ESI, 4
    ADD EDI, 4
    DEC ECX
    JNZ @@Pixel
    MOV ECX, EBX
    ADD ESI, SrcSkip
    ADD EDI, DstSkip
    DEC EDX
    JNZ @@Pixel
    POP EDI
    POP ESI
    POP EDX
    POP EBX
    POP ECX
    POP EAX
  end;
end;
{ @end $8686C8 }

{ @routine $8687A0 TGraphBufGR_BlendRect32 }
procedure TGraphBufGR.BlendRect32(Dest: TPoint; Source: TGraphBufGR; Rect: TRect);
var Src, Dst: Pointer; Columns: Integer; Table: Pointer; SrcSkip, DstSkip, Rows: Integer;
begin
  Src := Pointer(PAnsiChar(Source.GetPixels) + (Rect.Top * Source.PitchBytes + Rect.Left * SizeOf(TColorRGBA)));
  Columns := Rect.Right - Rect.Left; Rows := Rect.Bottom - Rect.Top;
  SrcSkip := Source.PitchBytes - Columns * SizeOf(TColorRGBA);
  Dst := Pointer(PAnsiChar(GetPixels) + (Dest.Y * PitchBytes + Dest.X * SizeOf(TColorRGBA)));
  DstSkip := PitchBytes - Columns * SizeOf(TColorRGBA);
  Table := Ex_OKGF_MulTable256x256;
  // Native precondition: Columns and Rows must be positive. Neither is checked
  // before access; zero wraps on DEC and the loop overruns the rectangle buffers.
  asm
    PUSH EAX
    PUSH ECX
    PUSH EBX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    MOV ESI, Src
    MOV EDI, Dst
    MOV EDX, Columns
  @@Pixel:
    MOV EAX, [ESI]
    MOV EBX, EAX
    SHR EBX, 24
    AND EAX, $FF
    SHL EAX, 8
    ADD EAX, EBX
    ADD EAX, Table
    MOV AL, [EAX]
    MOV ECX, [EDI]
    AND ECX, $FF
    SHL ECX, 8
    ADD ECX, $FF
    SUB ECX, EBX
    ADD ECX, Table
    MOV CL, [ECX]
    ADD EAX, ECX
    MOV [EDI], AL
    MOV EAX, [ESI]
    MOV EBX, EAX
    SHR EBX, 24
    SHR EAX, 8
    AND EAX, $FF
    SHL EAX, 8
    ADD EAX, EBX
    ADD EAX, Table
    MOV AL, [EAX]
    MOV ECX, [EDI]
    SHR ECX, 8
    AND ECX, $FF
    SHL ECX, 8
    ADD ECX, $FF
    SUB ECX, EBX
    ADD ECX, Table
    MOV CL, [ECX]
    ADD EAX, ECX
    MOV [EDI + 1], AL
    MOV EAX, [ESI]
    MOV EBX, EAX
    SHR EBX, 24
    SHR EAX, 16
    AND EAX, $FF
    SHL EAX, 8
    ADD EAX, EBX
    ADD EAX, Table
    MOV AL, [EAX]
    MOV ECX, [EDI]
    SHR ECX, 16
    AND ECX, $FF
    SHL ECX, 8
    ADD ECX, $FF
    SUB ECX, EBX
    ADD ECX, Table
    MOV CL, [ECX]
    ADD EAX, ECX
    MOV [EDI + 2], AL
    MOV AL, [ESI + 3]
    ADD AL, [EDI + 3]
    JNC @@Alpha
    MOV AL, $FF
  @@Alpha:
    MOV [EDI + 3], AL
    ADD ESI, 4
    ADD EDI, 4
    DEC EDX
    JNZ @@Pixel
    MOV EDX, Columns
    ADD ESI, SrcSkip
    ADD EDI, DstSkip
    DEC Rows
    JNZ @@Pixel
    POP EDI
    POP ESI
    POP EDX
    POP EBX
    POP ECX
    POP EAX
  end;
end;
{ @end $8687A0 }

{ @routine $868928 TGraphBufGR_MakeShadow }
procedure TGraphBufGR.MakeShadow;
var Data: Pointer; Columns, RowSkip, Rows: Integer;
begin
  Data := GetPixels; Columns := Width; Rows := Height;
  RowSkip := PitchBytes - Columns * SizeOf(TColorRGBA);
  // Native precondition: Width and Height must be positive. Neither is checked
  // before access; zero wraps on DEC and the loop overruns the pixel buffer.
  asm
    PUSH EAX
    PUSH ECX
    PUSH EBX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    MOV ESI, Data
    MOV EDX, Columns
  @@Pixel:
    MOV EAX, [ESI]
    SHR EAX, 2
    AND EAX, $FF000000
    MOV [ESI], EAX
    ADD ESI, 4
    ADD EDI, 4
    DEC EDX
    JNZ @@Pixel
    MOV EDX, Columns
    ADD ESI, RowSkip
    DEC Rows
    JNZ @@Pixel
    POP EDI
    POP ESI
    POP EDX
    POP EBX
    POP ECX
    POP EAX
  end;
end;
{ @end $868928 }

{ @routine $868998 TGraphBufGR_SaveToBuffer }
procedure TGraphBufGR.SaveToBuffer(Buffer: TBufEC);
var Size: Integer;
begin
  Buffer.Clear;
  Buffer.AddDWord(Width); Buffer.AddDWord(Height); Buffer.AddDWord(PitchBytes);
  Size := PitchBytes * Height;
  Buffer.SetSize(Buffer.DataSize + Size);
  CopyMemory(AddPointerOffset(Buffer.Data, Buffer.Position), GetPixels, Size);
end;
{ @end $868998 }

{ @routine $868A24 TGraphBufGR_LoadFromBuffer }
procedure TGraphBufGR.LoadFromBuffer(Buffer: TBufEC);
var Size: Integer;
begin
  Clear;
  Buffer.ExpandZlibPayloadInPlace;
  Width := Buffer.GetUInt32; Height := Buffer.GetUInt32; PitchBytes := Buffer.GetUInt32;
  Size := PitchBytes * Height;
  if Buffer.DataSize - Buffer.Position < Size then RaiseWideMessage('load bin');
  Pixels := AllocEC(Size);
  CopyMemory(GetPixels, AddPointerOffset(Buffer.Data, Buffer.Position), Size);
  BytesPerPixel := Cardinal(PitchBytes) div Cardinal(Width);
  BitsPerPixel := BytesPerPixel * 8;
end;
{ @end $868A24 }

{ @routine $868B0C TGraphBufGR_SavePng }
procedure TGraphBufGR.SavePng(FileName: WideString);
begin
  LockTexture(True);
  WritePngFile(PAnsiChar(AnsiString(FileName)), GetPixels, PitchBytes, Width, Height, 1, 1);
end;
{ @end $868B0C }

{ @routine $868BA0 TGraphBufGR_SaveBmp }
procedure TGraphBufGR.SaveBmp(FileName: WideString);
begin
  LockTexture(True);
  WriteBmpFile(PAnsiChar(AnsiString(FileName)), GetPixels, PitchBytes, 32, $FF0000, $FF00, $FF, 0, Width, Height);
end;
{ @end $868BA0 }

{ @routine $868C44 TGraphBufGR_SaveJpeg }
procedure TGraphBufGR.SaveJpeg(FileName: WideString; Quality: Integer);
var Bitmap: TBitmap; Image: TJPEGImage;
begin
  SaveBmp(FileName);
  try
    Image := TJPEGImage.Create;
    try
      Bitmap := TBitmap.Create;
      try
        Bitmap.LoadFromFile(FileName);
        Image.Assign(Bitmap);
      finally
        Bitmap.Free;
      end;
      Image.CompressionQuality := Quality;
      Image.Compress;
      Image.SaveToFile(FileName);
    finally
      Image.Free;
    end;
  except
  end;
end;
{ @end $868C44 }

{ @routine $868EB8 TGraphBufGR_DrawNinePatch }
procedure TGraphBufGR.DrawNinePatch(X, Y, Width, Height: Integer; Source: TGraphBufGR; SourceRect, Borders: TRect);
var TileRect: TRect;

  // @nested $868D90 TilePatch
  procedure TilePatch(X, Y, Width, Height: Integer; Rect: TRect); // @addr $868D90 @calls "0x869065 0x8690AB 0x8690EB 0x869131 0x86917D"
  var TileX, TileY, TileWidth, TileHeight: Integer;
  begin
    TileWidth := Rect.Right - Rect.Left;
    if TileWidth <= 0 then Exit;
    TileHeight := Rect.Bottom - Rect.Top;
    if TileHeight <= 0 then Exit;
    TileY := 0;
    while TileY < Height do
    begin
      if TileY + TileHeight > Height then Rect.Bottom := Height - TileY + Rect.Top;
      TileX := 0;
      while TileX < Width do
      begin
        if TileX + TileWidth > Width then
          CopyRect32(Classes.Point(X + TileX, Y + TileY), Source,
            Classes.Rect(Rect.Left, Rect.Top, Width - TileX + Rect.Left, Rect.Bottom))
        else CopyRect32(Classes.Point(X + TileX, Y + TileY), Source, Rect);
        Inc(TileX, TileWidth);
      end;
      Inc(TileY, TileHeight);
    end;
  end;

begin
  if Width <= 0 then Width := Self.Width - X;
  if Height <= 0 then Height := Self.Height - Y;
  if SourceRect.Right <= SourceRect.Left then SourceRect.Right := Source.Width;
  if SourceRect.Bottom <= SourceRect.Top then SourceRect.Bottom := Source.Height;
  TileRect := Classes.Rect(SourceRect.Left, SourceRect.Top, SourceRect.Left + Borders.Left, SourceRect.Top + Borders.Top);
  CopyRect32(Classes.Point(X, Y), Source, TileRect);
  TileRect := Classes.Rect(SourceRect.Right - Borders.Right, SourceRect.Top, SourceRect.Right, SourceRect.Top + Borders.Top);
  CopyRect32(Classes.Point(X + Width - Borders.Right, Y), Source, TileRect);
  TileRect := Classes.Rect(SourceRect.Left, SourceRect.Bottom - Borders.Bottom, SourceRect.Left + Borders.Left, SourceRect.Bottom);
  CopyRect32(Classes.Point(X, Y + Height - Borders.Bottom), Source, TileRect);
  TileRect := Classes.Rect(SourceRect.Right - Borders.Right, SourceRect.Bottom - Borders.Bottom, SourceRect.Right, SourceRect.Bottom);
  CopyRect32(Classes.Point(X + Width - Borders.Right, Y + Height - Borders.Bottom), Source, TileRect);
  TileRect := Classes.Rect(SourceRect.Left + Borders.Left, SourceRect.Top, SourceRect.Right - Borders.Right, SourceRect.Top + Borders.Top);
  TilePatch(X + Borders.Left, Y, Width - Borders.Left - Borders.Right, Borders.Top, TileRect);
  TileRect := Classes.Rect(SourceRect.Left + Borders.Left, SourceRect.Bottom - Borders.Bottom, SourceRect.Right - Borders.Right, SourceRect.Bottom);
  TilePatch(X + Borders.Left, Y + Height - Borders.Bottom, Width - Borders.Left - Borders.Right, Borders.Bottom, TileRect);
  TileRect := Classes.Rect(SourceRect.Left, SourceRect.Top + Borders.Top, SourceRect.Left + Borders.Left, SourceRect.Bottom - Borders.Bottom);
  TilePatch(X, Y + Borders.Top, Borders.Left, Height - Borders.Top - Borders.Bottom, TileRect);
  TileRect := Classes.Rect(SourceRect.Right - Borders.Right, SourceRect.Top + Borders.Top, SourceRect.Right, SourceRect.Bottom - Borders.Bottom);
  TilePatch(X + Width - Borders.Right, Y + Borders.Top, Borders.Right, Height - Borders.Top - Borders.Bottom, TileRect);
  TileRect := Classes.Rect(SourceRect.Left + Borders.Left, SourceRect.Top + Borders.Top, SourceRect.Right - Borders.Right, SourceRect.Bottom - Borders.Bottom);
  TilePatch(X + Borders.Left, Y + Borders.Top, Width - Borders.Left - Borders.Right, Height - Borders.Top - Borders.Bottom, TileRect);
end;
{ @end $868EB8 }

{ @routine $86918C TGraphBufGR_RescaleWithAspect }
procedure TGraphBufGR.RescaleWithAspect(Width, Height: Cardinal; CropToAspect: Boolean; HorizontalAlign, VerticalAlign, Filter: Integer);
var
  Left, Top, CropWidth, CropHeight: Cardinal;
  Source, Dest: Pointer;
  SourcePitch, DestPitch: Integer;
  NewTexture: IDirect3DTexture9;
  Locked: TD3DLockedRect;
begin
  if (Width = Cardinal(Self.Width)) and (Height = Cardinal(Self.Height)) then Exit;
  Left := 0; Top := 0;
  if CropToAspect then
  begin
    CropWidth := Self.Width;
    CropHeight := Round((Height / Width) * Cardinal(Self.Width));
    if CropHeight > Cardinal(Self.Height) then
    begin
      CropWidth := Round((Width / Height) * Cardinal(Self.Height));
      CropHeight := Self.Height;
    end;
    if HorizontalAlign = 1 then Left := (Cardinal(Self.Width) - CropWidth) shr 1
    else if HorizontalAlign = 2 then Left := Cardinal(Self.Width) - CropWidth
    else Left := 0;
    if VerticalAlign = 1 then Top := (Cardinal(Self.Height) - CropHeight) shr 1
    else if VerticalAlign = 2 then Top := Cardinal(Self.Height) - CropHeight
    else Top := 0;
    if ((Width = Cardinal(Self.Width)) and (Height < Cardinal(Self.Height))) or
      ((Height = Cardinal(Self.Height)) and (Width < Cardinal(Self.Width))) then
    begin
      Crop(Classes.Rect(Left, Top, Left + CropWidth, Top + CropHeight));
      Exit;
    end;
  end
  else
  begin
    CropWidth := Self.Width; CropHeight := Self.Height;
  end;
  if UseTexture and (BitsPerPixel = 32) then
  begin
    NewTexture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    NewTexture.LockRect(0, Locked, nil, 0);
    Dest := Locked.Bits; DestPitch := Locked.Pitch;
  end
  else
  begin
    DestPitch := Width * BytesPerPixel;
    Dest := AllocEC(Height * DestPitch);
  end;
  if UsesTextureStorage and (Texture <> nil) then
  begin
    Texture.LockRect(0, Locked, nil, D3DLOCK_READONLY);
    Source := Locked.Bits; SourcePitch := Locked.Pitch;
  end
  else
  begin
    Source := Pixels; SourcePitch := PitchBytes;
  end;
  Ex_OKGF_Rescale(Dest, Width, Height, DestPitch,
    AddPointerOffset(Source, Top * SourcePitch + Left * BytesPerPixel), CropWidth, CropHeight, SourcePitch, BytesPerPixel, Filter);
  if UseTexture and (BitsPerPixel = 32) then
  begin
    if not TextureFlag22 then Texture := nil;
    NewTexture.UnlockRect(0); Texture := NewTexture;
    TextureLocked := False; UsesTextureStorage := True; Pixels := nil;
  end
  else
  begin
    if StorageKind = 0 then FreeEC(Pixels);
    StorageKind := 0; Pixels := Dest; Texture := nil;
  end;
  Self.Width := Width; Self.Height := Height; PitchBytes := DestPitch;
end;
{ @end $86918C }

{ @routine $8694F0 TGraphBufGR_RescaleRGBA_HW }
procedure TGraphBufGR.RescaleRGBA_HW(Width, Height: Cardinal; CropToAspect: Boolean; HorizontalAlign, VerticalAlign: Integer);
var
  Left, Top, CropWidth, CropHeight: Cardinal;
  Dest: Pointer; DestPitch: Integer;
  Staging, DeviceTexture: IDirect3DTexture9;
  SourceSurface, TargetSurface: IDirect3DSurface9;
  Locked: TD3DLockedRect;
  SourceRect: TRect;
begin
  if (Width = Cardinal(Self.Width)) and (Height = Cardinal(Self.Height)) then Exit;
  if CropToAspect then
  begin
    CropWidth := Self.Width;
    CropHeight := Round((Height / Width) * Cardinal(Self.Width));
    if CropHeight > Cardinal(Self.Height) then
    begin
      CropWidth := Round((Width / Height) * Cardinal(Self.Height));
      CropHeight := Self.Height;
    end;
    if HorizontalAlign = 1 then Left := (Cardinal(Self.Width) - CropWidth) shr 1
    else if HorizontalAlign = 2 then Left := Cardinal(Self.Width) - CropWidth
    else Left := 0;
    if VerticalAlign = 1 then Top := (Cardinal(Self.Height) - CropHeight) shr 1
    else if VerticalAlign = 2 then Top := Cardinal(Self.Height) - CropHeight
    else Top := 0;
    SourceRect := Classes.Rect(Left, Top, Left + CropWidth, Top + CropHeight);
    if ((Width = Cardinal(Self.Width)) and (Height < Cardinal(Self.Height))) or
      ((Height = Cardinal(Self.Height)) and (Width < Cardinal(Self.Width))) then
    begin
      Crop(SourceRect);
      Exit;
    end;
  end
  else SourceRect := Classes.Rect(0, 0, Self.Width, Self.Height);
  LockTexture(True);
  Direct3DDevice.CreateTexture(Self.Width, Self.Height, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, Staging, nil);
  Staging.LockRect(0, Locked, nil, 0);
  CopyMemory(Locked.Bits, Pixels, Self.Height * PitchBytes);
  Staging.UnlockRect(0);
  UnlockTexture;
  if UsesTextureStorage and (Texture <> nil) then Texture.UnlockRect(0);
  Direct3DDevice.CreateTexture(Self.Width, Self.Height, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, DeviceTexture, nil);
  if Direct3DDevice.UpdateTexture(Staging, DeviceTexture) <> 0 then AppendLogLineThreadSafe('TGraphBufGR.RescaleRGBA_HW(...)::UpdateTexture fail');
  Staging := nil;
  Direct3DDevice.CreateRenderTarget(Width, Height, D3DFMT_A8R8G8B8, D3DMULTISAMPLE_NONE, 0, False, TargetSurface, nil);
  DeviceTexture.GetSurfaceLevel(0, SourceSurface);
  if Direct3DDevice.StretchRect(SourceSurface, @SourceRect, TargetSurface, nil, D3DTEXF_LINEAR) <> 0 then AppendLogLineThreadSafe('TGraphBufGR.RescaleRGBA_HW(...)::StretchRect fail');
  SourceSurface := nil; DeviceTexture := nil;
  Direct3DDevice.CreateTexture(Width, Height, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, Staging, nil);
  Staging.GetSurfaceLevel(0, SourceSurface);
  if Direct3DDevice.GetRenderTargetData(TargetSurface, SourceSurface) <> 0 then AppendLogLineThreadSafe('TGraphBufGR.RescaleRGBA_HW(...)::GetRenderTargetData fail');
  SourceSurface := nil; TargetSurface := nil;
  if UseTexture then
  begin
    if not TextureFlag22 then Texture := nil;
    Texture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    Texture.LockRect(0, Locked, nil, 0);
    Dest := Locked.Bits; DestPitch := Locked.Pitch; UsesTextureStorage := True;
  end
  else
  begin
    DestPitch := Width * SizeOf(TColorRGBA);
    Dest := AllocEC(Height * DestPitch);
  end;
  Staging.LockRect(0, Locked, nil, D3DLOCK_READONLY);
  CopyMemory(Dest, Locked.Bits, Height * DestPitch);
  Staging.UnlockRect(0); Staging := nil;
  if UsesTextureStorage then
  begin
    Texture.UnlockRect(0); TextureLocked := False;
  end;
  if not UseTexture then
  begin
    if StorageKind = 0 then FreeEC(Pixels);
    StorageKind := 0; Pixels := Dest;
  end;
  Self.Width := Width; Self.Height := Height; PitchBytes := DestPitch;
end;
{ @end $8694F0 }

{ @routine $869AA8 TGraphBufGR_Crop }
procedure TGraphBufGR.Crop(Rect: TRect);
var Y, NewWidth, NewHeight: Integer; Source, Dest: Pointer; NewPitch: Integer;
  NewTexture: IDirect3DTexture9; Locked: TD3DLockedRect;
begin
  NewWidth := Rect.Right - Rect.Left; NewHeight := Rect.Bottom - Rect.Top;
  if (NewWidth <= 0) or (NewHeight <= 0) or (Rect.Left < 0) or (Rect.Left >= Width) or
    (Rect.Right > Width) or (Rect.Top < 0) or (Rect.Top >= Height) or (Rect.Bottom > Height) then Exit;
  if UseTexture then
  begin
    if BitsPerPixel = 16 then NewTexture := GR_CreateTexture(NewWidth, NewHeight, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
    else if BitsPerPixel = 32 then NewTexture := GR_CreateTexture(NewWidth, NewHeight, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
    NewTexture.LockRect(0, Locked, nil, 0);
    Dest := Locked.Bits; NewPitch := Locked.Pitch;
  end
  else
  begin
    NewPitch := NewWidth * BytesPerPixel;
    Dest := AllocEC(NewHeight * NewPitch);
  end;
  LockTexture(True);
  Source := AddPointerOffset(Pixels, Rect.Top * PitchBytes + Rect.Left * BytesPerPixel);
  Y := 0;
  while Y < NewHeight do
  begin
    CopyMemory(AddPointerOffset(Dest, Y * NewPitch), AddPointerOffset(Source, Y * PitchBytes), NewWidth * BytesPerPixel);
    Inc(Y);
  end;
  UnlockTexture;
  if UseTexture then
  begin
    NewTexture.UnlockRect(0);
    if not TextureFlag22 then Texture := nil;
    Texture := NewTexture;
  end
  else
  begin
    if StorageKind = 0 then FreeEC(Pixels);
    StorageKind := 0; Pixels := Dest;
  end;
  Width := NewWidth; Height := NewHeight; PitchBytes := NewPitch;
end;
{ @end $869AA8 }

{ @routine $869CF0 TGraphBufGR_AdjustBrightness }
procedure TGraphBufGR.AdjustBrightness(Percent: Integer);
var X, Y, C, B, G, R: Integer; Pixel: PByte; Table: array[0..255] of SmallInt;
begin
  for C := Low(Table) to High(Table) do
  begin
    Table[C] := (Percent + 100) * C div 100;
    Table[C] := Max(0, Min(255, Table[C]));
  end;
  if BitsPerPixel = 16 then
  begin
    for Y := 0 to Height - 1 do
    begin
      Pixel := Pointer(PAnsiChar(GetPixels) + PitchBytes * Y);
      for X := 0 to Width - 1 do
      begin
        C := PWord(Pixel)^;
        B := (C and 31) shl 3; G := (C shr 3) and $FC; R := (C shr 8) and $F8;
        B := Table[B]; G := Table[G]; R := Table[R];
        C := (B shr 3) or ((G shr 2) shl 5) or ((R shr 3) shl 11);
        PWord(Pixel)^ := C;
        Inc(Pixel, SizeOf(Word));
      end;
    end;
  end
  else if BitsPerPixel = 32 then
  begin
    for Y := 0 to Height - 1 do
    begin
      Pixel := Pointer(PAnsiChar(GetPixels) + PitchBytes * Y);
      for X := 0 to Width - 1 do
      begin
        PColorBGRA(Pixel).B := Table[PColorBGRA(Pixel).B];
        PByte(@PColorBGRA(Pixel).G)^ := Table[PByte(@PColorBGRA(Pixel).G)^];
        PByte(@PColorBGRA(Pixel).R)^ := Table[PByte(@PColorBGRA(Pixel).R)^];
        Inc(Pixel, SizeOf(TColorRGBA));
      end;
    end;
  end;
end;
{ @end $869CF0 }

{ @routine $869F20 TGraphBufGR_ConvertToGrayscale }
procedure TGraphBufGR.ConvertToGrayscale;
var X, Y: Integer; Pixel: PByte; C, R, G, B, RWeight, GWeight, BWeight: Cardinal;
begin
  if BitsPerPixel = 16 then
  begin
    RWeight := 19595; GWeight := 38469; BWeight := 7471;
    for Y := 0 to Height - 1 do
    begin
      Pixel := Pointer(PAnsiChar(GetPixels) + PitchBytes * Y);
      for X := 0 to Width - 1 do
      begin
        C := PWord(Pixel)^;
        R := (C shr 11) and 31; G := ((C shr 5) and 63) shr 1; B := C and 31;
        R := (R * RWeight + G * GWeight + B * BWeight) shr 16;
        G := R * 2; B := R;
        C := (R shl 11) or (G shl 5) or B;
        PWord(Pixel)^ := C;
        Inc(Pixel, SizeOf(Word));
      end;
    end;
  end
  else if BitsPerPixel = 32 then
  begin
    for Y := 0 to Height - 1 do
    begin
      Pixel := Pointer(PAnsiChar(GetPixels) + PitchBytes * Y);
      for X := 0 to Width - 1 do
      begin
        B := PColorBGRA(Pixel).B;
        G := PByte(@PColorBGRA(Pixel).G)^;
        R := PByte(@PColorBGRA(Pixel).R)^;
        C := Trunc(R * 0.299 + G * 0.587 + B * 0.114);
        PColorBGRA(Pixel).B := C;
        PByte(@PColorBGRA(Pixel).G)^ := C;
        PByte(@PColorBGRA(Pixel).R)^ := C;
        Inc(Pixel, SizeOf(TColorRGBA));
      end;
    end;
  end;
end;
{ @end $869F20 }

{ @routine $86A214 TGraphBufGR_GetTexture }
function TGraphBufGR.GetTexture: IDirect3DTexture9;
var Locked: TD3DLockedRect; Y: Cardinal; RowBytes: Integer;

  // @nested $86A154 CopyRgbToOpaqueRgba
  procedure CopyRgbToOpaqueRgba(Dest: Pointer; DestPitch: Integer; Source: Pointer; SourcePitch, Width, Height: Integer); // @addr $86A154 @calls "0x86A2BE"
  var X, Y: Integer;
  begin
    Y := 0;
    while Y < Height do
    begin
      X := 0;
      while X < Width do
      begin
        CopyMemory(AddPointerOffset(Dest, X * SizeOf(TColorRGBA)), AddPointerOffset(Source, X * 3), 3);
        PByte(AddPointerOffset(Dest, X * SizeOf(TColorRGBA) + 3))^ := 255;
        Inc(X);
      end;
      Dest := AddPointerOffset(Dest, DestPitch);
      Source := AddPointerOffset(Source, SourcePitch);
      Inc(Y);
    end;
  end;

begin
  if not UsesTextureStorage and (Texture = nil) then
  begin
    if BitsPerPixel = 24 then
    begin
      Texture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
      Texture.LockRect(0, Locked, nil, 0);
      CopyRgbToOpaqueRgba(Locked.Bits, Locked.Pitch, Pixels, PitchBytes, Width, Height);
      Texture.UnlockRect(0);
    end
    else
    begin
      if BitsPerPixel = 16 then Texture := GR_CreateTexture(Width, Height, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
      else if BitsPerPixel = 32 then Texture := GR_CreateTexture(Width, Height, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
      Texture.LockRect(0, Locked, nil, 0);
      RowBytes := Width * BytesPerPixel;
      Y := 0;
      while Y < Cardinal(Height) do
      begin
        CopyMemory(AddPointerOffset(Locked.Bits, Locked.Pitch * Y), AddPointerOffset(Pixels, PitchBytes * Y), RowBytes);
        Inc(Y);
      end;
      Texture.UnlockRect(0);
    end;
  end;
  UnlockTexture;
  Result := Texture;
end;
{ @end $86A214 }

{ @routine $86A450 TGraphBufGR_LoadFromScreen }
procedure TGraphBufGR.LoadFromScreen(UnusedOption: Byte);
var
  Offscreen, RenderTarget: IDirect3DSurface9;
  Locked: TD3DLockedRect;
  Y: Cardinal;
  ErrorCode: Integer;
  Desc: TD3DSurfaceDesc;

  // @nested $86A400 SetRowAlpha
  procedure SetRowAlpha(Pixels: Pointer; Count, Alpha: Integer); // @addr $86A400
  var X: Integer;
  begin
    Alpha := Alpha and $FF;
    for X := 0 to Count - 1 do PByte(AddPointerOffset(Pixels, X * SizeOf(TColorRGBA) + 3))^ := Alpha;
  end;

begin
  try
    if HardwareRenderingEnabled then
    begin
      ErrorCode := Direct3DDevice.GetRenderTarget(0, RenderTarget);
      if ErrorCode = 0 then
      begin
        ErrorCode := RenderTarget.GetDesc(Desc);
        if ErrorCode = 0 then
        begin
          ErrorCode := Direct3DDevice.CreateOffscreenPlainSurface(Desc.Width, Desc.Height, Desc.Format, D3DPOOL_SYSTEMMEM, Offscreen, nil);
          if ErrorCode = 0 then
          begin
            ErrorCode := Direct3DDevice.GetRenderTargetData(RenderTarget, Offscreen);
            if ErrorCode = 0 then
            begin
              Clear;
              Width := Desc.Width; Height := Desc.Height;
              BitsPerPixel := 32; BytesPerPixel := SizeOf(TColorRGBA);
              if UseTexture then
              begin
                Texture := GR_CreateTexture(GameScreenWidth, GameScreenHeight, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
                UsesTextureStorage := True; LockTexture(False);
              end
              else
              begin
                PitchBytes := Width * SizeOf(TColorRGBA);
                Pixels := AllocEC(Height * PitchBytes);
              end;
              if Pixels <> nil then
              begin
                Offscreen.LockRect(Locked, nil, 0);
                for Y := 0 to Cardinal(Height) - 1 do
                begin
                  CopyMemory(AddPointerOffset(Pixels, PitchBytes * Y), AddPointerOffset(Locked.Bits, Locked.Pitch * Y), Width * SizeOf(TColorRGBA));
                  SetRowAlpha(AddPointerOffset(Pixels, PitchBytes * Y), Width, 255);
                end;
                Offscreen.UnlockRect;
              end;
              UnlockTexture;
            end
            else raise Exception.Create('TGraphBufGR.LoadFromScreen()::GetRenderTargetData fail (' + IntToStr(ErrorCode) + ')');
            Offscreen := nil;
          end
          else raise Exception.Create('TGraphBufGR.LoadFromScreen()::CreateOffscreenPlainSurface fail (' + IntToStr(ErrorCode) + ')');
        end
        else raise Exception.Create('TGraphBufGR.LoadFromScreen()::GetDesc fail (' + IntToStr(ErrorCode) + ')');
        RenderTarget := nil;
      end
      else raise Exception.Create('TGraphBufGR.LoadFromScreen()::GetRenderTarget fail (' + IntToStr(ErrorCode) + ')');
    end
    else
    begin
      AllocateNative(GameScreenWidth, GameScreenHeight);
      try
        Ex_OKGR_Copy_XY_XY_WORD(GetPixels, PitchBytes, 0, 0, ScreenRenderBuffer.GetPixels,
          ScreenRenderBuffer.PitchBytes, 0, 0, GameScreenWidth, GameScreenHeight);
      except
        raise Exception.Create('Error in TGraphBufGR.LoadFromScreen()::OKGR_Copy_XY_XY_WORD');
      end;
    end;
  except
    Clear;
    AllocateNative(GameScreenWidth, GameScreenHeight);
  end;
end;
{ @end $86A450 }

{ @routine $86A9E8 TGraphBufGR_LockTexture }
procedure TGraphBufGR.LockTexture(ReadOnly: Boolean);
var Locked: TD3DLockedRect;
begin
  if TextureLockedReadOnly and not ReadOnly then UnlockTexture;
  if not TextureLocked then
  begin
    if not UsesTextureStorage or (Texture = nil) then
    begin
      TextureLocked := False;
      Exit;
    end;
    if ReadOnly then Texture.LockRect(0, Locked, nil, D3DLOCK_READONLY)
    else Texture.LockRect(0, Locked, nil, 0);
    Pixels := Locked.Bits; PitchBytes := Locked.Pitch;
    TextureLockedReadOnly := ReadOnly; TextureLocked := True;
  end;
end;
{ @end $86A9E8 }

{ @routine $86AA8C TGraphBufGR_UnlockTexture }
procedure TGraphBufGR.UnlockTexture;
begin
  if TextureLocked then
  begin
    TextureLocked := False; TextureLockedReadOnly := False;
    if UsesTextureStorage and (Texture <> nil) then
    begin
      Pixels := nil;
      Texture.UnlockRect(0);
    end;
  end;
end;
{ @end $86AA8C }

{ @routine $86AAD8 TGraphBufGR_ConvertBgraToRgb24 }
procedure TGraphBufGR.ConvertBgraToRgb24;
var NewPixels, Dest, Source: Pointer; NewPitch: Integer; X, Y: Cardinal;
begin
  if Cardinal(Width) < 1 then Exit;
  if Cardinal(Height) < 1 then Exit;
  LockTexture(True);
  NewPitch := Width * 3;
  NewPixels := AllocEC(NewPitch * Height);
  Dest := NewPixels;
  Source := Pixels;
  Y := 0;
  while Y < Cardinal(Height) do
  begin
    X := 0;
    while X < Cardinal(Width) do
    begin
      PByte(AddPointerOffset(Dest, X * 3))^ := PByte(AddPointerOffset(Source, X * SizeOf(TColorRGBA) + 2))^;
      PByte(AddPointerOffset(Dest, X * 3 + 1))^ := PByte(AddPointerOffset(Source, X * SizeOf(TColorRGBA) + 1))^;
      PByte(AddPointerOffset(Dest, X * 3 + 2))^ := PByte(AddPointerOffset(Source, X * SizeOf(TColorRGBA)))^;
      Inc(X);
    end;
    Dest := AddPointerOffset(Dest, NewPitch);
    Source := AddPointerOffset(Source, PitchBytes);
    Inc(Y);
  end;
  UnlockTexture;
  if UsesTextureStorage then
  begin
    Texture := nil;
    UsesTextureStorage := False;
  end
  else if StorageKind = 0 then
  begin
    if Pixels <> nil then FreeEC(Pixels);
  end;
  Pixels := NewPixels;
  PitchBytes := NewPitch;
  BitsPerPixel := 24;
  BytesPerPixel := 3;
end;
{ @end $86AAD8 }

{ @routine $86ACE4 TGraphBufGR_DrawAntialiasedCircle16 }
procedure TGraphBufGR.DrawAntialiasedCircle16(Center: TPoint; Radius: Integer; Color: Cardinal; Clip: TRect);
var X, Y, SignX, SignY, Quadrant: Integer; PreviousCoverage, Coverage: Single; PreviousX: Integer;

  // @nested $86AC88 PlotCirclePixel16
  procedure PlotCirclePixel16(X, Y, Alpha: Integer); // @addr $86AC88 @calls "0x86ad6f 0x86ad8f 0x86ae87 0x86aeb8 0x86AEED 0x86AF19"
  begin
    if (X >= Clip.Left) and (X < Clip.Right) and (Y >= Clip.Top) and (Y < Clip.Bottom) then
      BlendPixel16(X, Y, Color, Alpha);
  end;

begin
  X := Radius;
  PreviousX := Radius;
  Y := 0;
  PreviousCoverage := 0;
  Quadrant := 0;
  while Quadrant < 4 do
  begin
    SignX := 2 * (Quadrant mod 2) - 1;
    SignY := 2 * (Quadrant div 2 mod 2) - 1;
    PlotCirclePixel16(Center.X + SignX * X, Center.Y + SignY * Y, 255);
    PlotCirclePixel16(Center.X + SignX * Y, Center.Y + SignY * X, 255);
    Inc(Quadrant);
  end;
  while X > Y do
  begin
    Inc(Y);
    Coverage := Sqrt(Sqr(Radius) - Sqr(Y));
    Coverage := Ceil(Coverage) - Coverage;
    if Coverage < PreviousCoverage then Dec(X);
    if X < Y then Break;
    if (X = Y) and (PreviousX = X) then Break;
    Quadrant := 0;
    while Quadrant < 4 do
    begin
      SignX := 2 * (Quadrant mod 2) - 1;
      SignY := 2 * (Quadrant div 2 mod 2) - 1;
      PlotCirclePixel16(Center.X + SignX * X, Center.Y + SignY * Y, Trunc((1 - Coverage) * 255));
      PlotCirclePixel16(Center.X + SignX * Y, Center.Y + SignY * X, Trunc((1 - Coverage) * 255));
      if X - 1 >= Y then
      begin
        PlotCirclePixel16(Center.X + (X - 1) * SignX, Center.Y + SignY * Y, Trunc(255 * Coverage));
        PlotCirclePixel16(Center.X + SignX * Y, Center.Y + (X - 1) * SignY, Trunc(255 * Coverage));
      end;
      Inc(Quadrant);
    end;
    PreviousCoverage := Coverage;
    PreviousX := X;
  end;
end;
{ @end $86ACE4 }

{ @routine $86AFE4 TGraphBufGR_DrawAntialiasedLine16 }
procedure TGraphBufGR.DrawAntialiasedLine16(X1, Y1, X2, Y2: Integer; Color: Cardinal; Alpha: Integer; Clip: TRect);
var
  Slope, DX, DY, Gap, EndX, EndY, InterY, Coverage1, Coverage2: Double;
  X, FirstX, LastX, FirstY, LastY: Integer;
  Steep: Boolean;
  Temp, StartX, StartY, FinishX, FinishY: Double;

  // @nested $86AF54 LineFraction16
  function LineFraction16(Value: Double): Double; // @addr $86AF54 @calls "0x86b27a 0x86b2be 0x86B2D8 0x86B3D6 0x86b41f 0x86B436 0x86b523 0x86B53D"
  begin
    Result := Value - Floor(Value);
  end;

  // @nested $86AF80 PlotLinePixel16
  procedure PlotLinePixel16(X, Y, Alpha: Integer); // @addr $86AF80 @calls "0x86B306 0x86B328 0x86B34B 0x86B36D 0x86B46D 0x86b49b 0x86b4cc 0x86B4FC 0x86B56B 0x86b58d 0x86b5b0 0x86b5d2"
  begin
    if (X >= Clip.Left) and (X < Clip.Right) and (Y >= Clip.Top) and (Y < Clip.Bottom) and (Alpha > 0) then
      BlendPixel16(X, Y, Color, Alpha);
  end;

begin
  StartX := X1; StartY := Y1; FinishX := X2; FinishY := Y2;
  DX := FinishX - StartX; DY := FinishY - StartY;
  if (DX = 0) and (DY = 0) then Exit;
  if Abs(DX) > Abs(DY) then Steep := False
  else
  begin
    Steep := True;
    Temp := StartX; StartX := StartY; StartY := Temp;
    Temp := FinishX; FinishX := FinishY; FinishY := Temp;
    Temp := DX; DX := DY; DY := Temp;
  end;
  if StartX > FinishX then
  begin
    Temp := StartX; StartX := FinishX; FinishX := Temp;
    Temp := StartY; StartY := FinishY; FinishY := Temp;
    DX := FinishX - StartX; DY := FinishY - StartY;
  end;
  Slope := DY / DX;
  EndX := Floor(StartX + 0.5);
  EndY := StartY + (EndX - StartX) * Slope;
  Gap := 1 - LineFraction16(StartX + 0.5);
  FirstX := Floor(StartX + 0.5); FirstY := Floor(EndY);
  Coverage1 := (1 - LineFraction16(EndY)) * Gap;
  Coverage2 := LineFraction16(EndY) * Gap;
  if Steep then
  begin
    PlotLinePixel16(FirstY, FirstX, Ceil(Alpha * Coverage1));
    PlotLinePixel16(FirstY + 1, FirstX, Ceil(Alpha * Coverage2));
  end
  else
  begin
    PlotLinePixel16(FirstX, FirstY, Ceil(Alpha * Coverage1));
    PlotLinePixel16(FirstX, FirstY + 1, Ceil(Alpha * Coverage2));
  end;
  X := FirstX + 1;
  InterY := EndY + Slope;
  EndX := Floor(FinishX + 0.5);
  EndY := FinishY + (EndX - FinishX) * Slope;
  Gap := 1 - LineFraction16(FinishX - 0.5);
  LastX := Floor(FinishX + 0.5); LastY := Floor(EndY);
  while LastX - 1 >= X do
  begin
    Coverage1 := 1 - LineFraction16(InterY); Coverage2 := LineFraction16(InterY);
    if Steep then
    begin
      PlotLinePixel16(Floor(InterY), X, Ceil(Alpha * Coverage1));
      PlotLinePixel16(Floor(InterY) + 1, X, Ceil(Alpha * Coverage2));
    end
    else
    begin
      PlotLinePixel16(X, Floor(InterY), Ceil(Alpha * Coverage1));
      PlotLinePixel16(X, Floor(InterY) + 1, Ceil(Alpha * Coverage2));
    end;
    InterY := InterY + Slope;
    Inc(X);
  end;
  Coverage1 := (1 - LineFraction16(EndY)) * Gap;
  Coverage2 := LineFraction16(EndY) * Gap;
  if Steep then
  begin
    PlotLinePixel16(LastY, LastX, Ceil(Alpha * Coverage1));
    PlotLinePixel16(LastY + 1, LastX, Ceil(Alpha * Coverage2));
  end
  else
  begin
    PlotLinePixel16(LastX, LastY, Ceil(Alpha * Coverage1));
    PlotLinePixel16(LastX, LastY + 1, Ceil(Alpha * Coverage2));
  end;
end;
{ @end $86AFE4 }

end.
