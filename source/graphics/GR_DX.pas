unit GR_DX;

interface

uses Direct3D9, Classes, Types;

const
  RgbWhite = $FFFFFF; // White texture tint; alpha is supplied separately.

type
  TScreenVertexGR = record // @size 28
    X: Single; // @offset 0
    Y: Single; // @offset 4
    Z: Single; // @offset 8
    RHW: Single; // @offset 12
    Color: Cardinal; // @offset 16
    U: Single; // @offset 20
    V: Single; // @offset 24
  end;
  TScreenVerticesGR = array[0..15] of TScreenVertexGR;
  TCircleTableGR = array[0..360] of Single;
  TLineAlphaTableGR = array[0..359] of Byte;

  TTextureGR = class(TObject) // @size 0x14
  public
    LastUseTick: Cardinal; // @offset 0x04
    SurfaceCount: Integer; // @offset 0x08
    // Delphi dynamic array of reference-counted surface interfaces.
    Surfaces: array of IDirect3DTexture9; // @offset 0x0C
    ResidentBytes: Cardinal; // @offset 0x10

    constructor Create; // @addr 0x004CA780
    destructor Destroy; override; // @addr 0x004CA7B0
    procedure Clear; // @addr 0x004CA7DC
    procedure ReleaseSurfaces; // @addr 0x004CA834 @note "Retains the array and SurfaceCount."
    function GetSurface(Index: Integer): IDirect3DTexture9; // @addr 0x004CA868 @note "Returns nil when out of range; successful access refreshes LastUseTick."
    procedure SetSurface(Value: IDirect3DTexture9; Index: Integer); // @addr 0x004CA89C @note "A negative index appends; indexes beyond the end create nil holes."
  end;

var
  TextureManagerDisabled: Boolean = False; // @addr $80B71C @note "DisableTextureManager setting."
  MaxTextureSize: TPoint; // @addr $819F34
  DrawVertices: TScreenVerticesGR; // @addr $819F3C
  PendingPoints: array of TScreenVertexGR; // @addr $81A0FC
  TextureCaches: TList = nil; // @addr 0x0080B720
  AvailableTextureBytes: Cardinal = 0; // @addr $80B724
  CircleCos: TCircleTableGR; // @addr $81A100
  CircleSin: TCircleTableGR; // @addr $81A6A4
  LineAlphaTable: TLineAlphaTableGR; // @addr $81AC48
  ReservedTextureBytes: Cardinal = 0; // @addr 0x0080B728
  TextureIdleSeconds: Integer = 120; // @addr 0x0080B72C
  LastTextureEvictionTick: Cardinal = 0; // @addr 0x0080B730
  PendingPointCount: Integer = 0; // @addr $80B734
  PendingPointCapacity: Integer = 0; // @addr $80B738
  ResidentTextureBytes: Cardinal = 0; // @addr 0x0080B73C

procedure EvictTextureCaches(Force: Boolean); // @addr 0x004CA160
procedure SubtractResidentTextureBytes(ByteCount: Cardinal); // @addr 0x004CC1D8

function CreateTextureCache: TTextureGR; // @addr 0x004CA0BC
function GR_CreateTexture(Width, Height: Integer; Format, Pool: Cardinal): IDirect3DTexture9; // @addr 0x004CA29C @note "Clamps each dimension to at least 16. Returns nil without a device; retries allocation after evicting textures."
procedure FreeTextureCache(Cache: TTextureGR); // @addr 0x004CA0F8 @note "Accepts nil."

procedure ClearTexturePixels(Texture: IDirect3DTexture9); // @addr $4CA6E0

procedure ReleaseAllTextureSurfaces; // @addr $4CA130
function GetTextureByteSize(Texture: IDirect3DTexture9): Cardinal; // @addr $4CC134 @note "Counts level zero only. Native format test repeats A8R8G8B8; X8R8G8B8 is not recognized."
procedure AddResidentTextureBytes(ByteCount: Cardinal); // @addr $4CC1D0
function Color565ToArgb(Color: Cardinal): Cardinal; // @addr $4CC0EC
function ColorWithAlpha(Color, Alpha: Cardinal): Cardinal; // @addr $4CC120
function CreateTextureFromPixels(Width, Height: Integer; Format: Cardinal; Pixels: Pointer; PitchBytes: Integer; Pool: Cardinal): IDirect3DTexture9; // @addr $4CA4F0

procedure QueueDrawPoint(X, Y: Integer; Color: Cardinal; Alpha: Integer); // @addr $4CA994
procedure FlushDrawPoints(ClipRect: PRect); // @addr $4CAA64
procedure DrawAlphaLine(X1, Y1, X2, Y2: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect); // @addr $4CAAD4
procedure DrawGradientLine(X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; ClipRect: PRect); // @addr $4CAB20
procedure DrawColoredTriangle(X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; X3, Y3: Integer; Color3: Cardinal; Filled: Boolean; ClipRect: PRect); // @addr $4CB6AC
procedure DrawColoredRect(X, Y, Width, Height: Integer; Color: Cardinal; Alpha: Integer; Filled: Boolean; ClipRect: PRect); // @addr $4CB790
procedure DrawAntialiasedCircle(X, Y, Radius: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect); // @addr $4CB90C
procedure DrawCircle(X, Y, Radius: Integer; Color: Cardinal; Alpha, Mode: Integer; ClipRect: PRect); // @addr $4CBB20
procedure DrawTexture(Texture: IDirect3DTexture9; X, Y, Alpha: Integer; Color: Cardinal; ClipRect: PRect; UsePreparedVertices, MirrorHorizontal: Boolean); // @addr $4CBE58
procedure DrawTextureSized(Texture: IDirect3DTexture9; X, Y, Width, Height, Alpha: Integer; Color: Cardinal; ClipRect: PRect; UsePreparedVertices, MirrorHorizontal: Boolean); // @addr $4CBEC8

procedure DrawAntialiasedLineDX(StartX, StartY, FinishX, FinishY: Integer; Color: Cardinal; Alpha: Integer; UnusedClipRect: PRect); // @addr $4CABF8 @note "Native routine ignores the supplied clip rectangle."
procedure DrawAnimatedLineDX(StartX, StartY, FinishX, FinishY: Integer; Color: Cardinal; Phase: Integer; UnusedClipRect: PRect); // @addr $4CB124 @note "Uses LineAlphaTable and advances phase by 20 per column. Ignores the supplied clip rectangle."

implementation

// @unit-initialization $8067E0
// @unit-finalization $4CC1F0

uses MMSystem, EC_Mem, GR_Main, EC_Str, Math, Windows;

{ @routine $4CA0BC CreateTextureCache }
function CreateTextureCache: TTextureGR;
var Texture: TTextureGR;
begin
  if TextureCaches = nil then TextureCaches := TList.Create;
  Texture := TTextureGR.Create;
  TextureCaches.Add(Texture);
  Result := Texture;
end;
{ @end $4CA0BC }

{ @routine $4CA0F8 FreeTextureCache }
procedure FreeTextureCache(Cache: TTextureGR);
var Index: Integer;
begin
  if Cache = nil then Exit;
  if TextureCaches <> nil then
  begin
    Index := TextureCaches.IndexOf(Cache);
    if Index >= 0 then TextureCaches.Delete(Index);
  end;
  Cache.Free;
end;
{ @end $4CA0F8 }

{ @routine $4CA130 ReleaseAllTextureSurfaces }
procedure ReleaseAllTextureSurfaces;
var Index: Integer; Texture: TTextureGR;
begin
  if TextureCaches = nil then Exit;
  Index := 0;
  while TextureCaches.Count > Index do
  begin
    Texture := TextureCaches[Index];
    Texture.ReleaseSurfaces;
    Inc(Index);
  end;
end;
{ @end $4CA130 }

{ @routine $4CA160 EvictTextureCaches }
procedure EvictTextureCaches(Force: Boolean);
var
  i: Integer;
  Texture: TObject;
  AvailableBytes: Cardinal;
  LastUsed, NowTick: Cardinal;
begin
  if TextureCaches = nil then Exit;
  if Direct3DDevice = nil then Exit;
  NowTick := timeGetTime;
  if (NowTick - LastTextureEvictionTick < 10) and not Force then Exit;
  LastTextureEvictionTick := NowTick;
  AvailableBytes := Max(0, Integer(Direct3DDevice.GetAvailableTextureMem - ReservedTextureBytes));
  if (ResidentTextureBytes < $10000000) and (AvailableBytes > $1400000) and not Force then Exit;
  i := 0;
  while i < TextureCaches.Count do
  begin
    Texture := TextureCaches[i];
    if Texture is TTextureGR then
    begin
      LastUsed := TTextureGR(Texture).LastUseTick;
      if NowTick - LastUsed > Cardinal(TextureIdleSeconds * 1000) then
        TTextureGR(Texture).ReleaseSurfaces;
    end;
    Inc(i);
  end;
  AvailableBytes := Max(0, Integer(Direct3DDevice.GetAvailableTextureMem - ReservedTextureBytes));
  if (AvailableBytes > 30 * 1024 * 1024.0) and (TextureIdleSeconds < 120) then
    Inc(TextureIdleSeconds, 10);
  if (ResidentTextureBytes > $10000000) or (AvailableBytes < $1400000) then
    if TextureIdleSeconds > 20 then Dec(TextureIdleSeconds, 10);
end;
{ @end $4CA160 }

{ @routine $4CA29C GR_CreateTexture }
function GR_CreateTexture(Width, Height: Integer; Format, Pool: Cardinal): IDirect3DTexture9;
var Texture: IDirect3DTexture9; ErrorCode: Integer;
begin
  if Direct3DDevice = nil then
  begin
    Result := nil;
    Exit;
  end;
  if Width < 16 then Width := 16;
  if Height < 16 then Height := 16;
  ErrorCode := Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
  if ErrorCode = LongInt($8007000E) then
  begin
    AppendLogTextThreadSafe('Failed to create texture, trying to free some textures... ');
    EvictTextureCaches(True);
    ErrorCode := Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
    if ErrorCode = 0 then AppendLogLineThreadSafe('success')
    else
    begin
      AppendLogLineThreadSafe('fail');
      LogMemoryUsage;
      AppendLogLineThreadSafe('GR_CreateTexture()::CreateTexture(' + IntToWideString(Width) + ',' + IntToWideString(Height) + ') error=' + IntToWideString(ErrorCode));
    end;
  end;
  ClearTexturePixels(Texture);
  Result := Texture;
end;
{ @end $4CA29C }

{ @routine $4CA4F0 CreateTextureFromPixels }
function CreateTextureFromPixels(Width, Height: Integer; Format: Cardinal; Pixels: Pointer; PitchBytes: Integer; Pool: Cardinal): IDirect3DTexture9;
var Y: Integer; Staging, Texture: IDirect3DTexture9; Locked: TD3DLockedRect; BytesPerPixel: Integer;
begin
  if Direct3DDevice = nil then
  begin
    Result := nil;
    Exit;
  end;
  if Pool = D3DPOOL_DEFAULT then
  begin
    Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, D3DPOOL_SYSTEMMEM, Staging, nil);
    Staging.LockRect(0, Locked, nil, 0);
    BytesPerPixel := PitchBytes div Width;
    for Y := 0 to Height - 1 do
      CopyMemory(AddPointerOffset(Locked.Bits, Locked.Pitch * Y), AddPointerOffset(Pixels, PitchBytes * Y), Width * BytesPerPixel);
    Staging.UnlockRect(0);
    Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
    Direct3DDevice.UpdateTexture(Staging, Texture);
    Staging := nil;
  end
  else
  begin
    Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
    Texture.LockRect(0, Locked, nil, 0);
    BytesPerPixel := PitchBytes div Width;
    for Y := 0 to Height - 1 do
      CopyMemory(AddPointerOffset(Locked.Bits, Locked.Pitch * Y), AddPointerOffset(Pixels, PitchBytes * Y), Width * BytesPerPixel);
    Texture.UnlockRect(0);
  end;
  Result := Texture;
end;
{ @end $4CA4F0 }

{ @routine $4CA6E0 ClearTexturePixels }
procedure ClearTexturePixels(Texture: IDirect3DTexture9);
var Locked: TD3DLockedRect; Y: Cardinal; Desc: TD3DSurfaceDesc;
begin
  if Texture = nil then Exit;
  Texture.GetLevelDesc(0, Desc);
  Texture.LockRect(0, Locked, nil, 0);
  if Locked.Bits <> nil then
    for Y := 0 to Desc.Height - 1 do
      FillMemory(Integer(Y) * Locked.Pitch + PAnsiChar(Locked.Bits), Locked.Pitch, 0);
  Texture.UnlockRect(0);
end;
{ @end $4CA6E0 }

{ @routine $4CA780 TTextureGR_Create }
constructor TTextureGR.Create;
begin
  SurfaceCount := 0;
  LastUseTick := 0;
  ResidentBytes := 0;
end;
{ @end $4CA780 }

{ @routine $4CA7B0 TTextureGR_Destroy }
destructor TTextureGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $4CA7B0 }

{ @routine $4CA7DC TTextureGR_Clear }
procedure TTextureGR.Clear;
var Index: Integer;
begin
  Index := 0;
  while Index < SurfaceCount do
  begin
    if Surfaces[Index] <> nil then Surfaces[Index] := nil;
    Inc(Index);
  end;
  if ResidentBytes > 0 then SubtractResidentTextureBytes(ResidentBytes);
  ResidentBytes := 0;
  SetLength(Surfaces, 0);
  SurfaceCount := 0;
  LastUseTick := 0;
end;
{ @end $4CA7DC }

{ @routine $4CA834 TTextureGR_ReleaseSurfaces }
procedure TTextureGR.ReleaseSurfaces;
var
  i: Integer;
begin
  i := 0;
  while i < SurfaceCount do
  begin
    Surfaces[i] := nil;
    Inc(i);
  end;
  if ResidentBytes > 0 then SubtractResidentTextureBytes(ResidentBytes);
  ResidentBytes := 0;
  LastUseTick := 0;
end;
{ @end $4CA834 }

{ @routine $4CA868 TTextureGR_GetSurface }
function TTextureGR.GetSurface(Index: Integer): IDirect3DTexture9;
begin
  Result := nil;
  if (Index < 0) or (Index >= SurfaceCount) then Exit;
  LastUseTick := timeGetTime;
  Result := Surfaces[Index];
end;
{ @end $4CA868 }

{ @routine $4CA89C TTextureGR_SetSurface }
procedure TTextureGR.SetSurface(Value: IDirect3DTexture9; Index: Integer);
var i: Integer; ByteCount: Cardinal;
begin
  if (Index < 0) or (Index = SurfaceCount) then
  begin
    Index := SurfaceCount;
    Inc(SurfaceCount);
    SetLength(Surfaces, SurfaceCount);
  end
  else if Index > SurfaceCount then
  begin
    i := SurfaceCount;
    SurfaceCount := Index + 1;
    SetLength(Surfaces, SurfaceCount);
    while i < SurfaceCount do
    begin
      Surfaces[i] := nil;
      Inc(i);
    end;
  end;
  if Surfaces[Index] <> nil then
  begin
    ByteCount := GetTextureByteSize(Surfaces[Index]);
    if ByteCount > 0 then
    begin
      Dec(ResidentBytes, ByteCount);
      SubtractResidentTextureBytes(ByteCount);
    end;
  end;
  ByteCount := GetTextureByteSize(Value);
  Inc(ResidentBytes, ByteCount);
  AddResidentTextureBytes(ByteCount);
  Surfaces[Index] := nil;
  Surfaces[Index] := Value;
end;
{ @end $4CA89C }

{ @routine $4CA994 QueueDrawPoint }
procedure QueueDrawPoint(X, Y: Integer; Color: Cardinal; Alpha: Integer);
var Index: Integer;
begin
  if Alpha = 0 then Exit;
  if PendingPointCount >= PendingPointCapacity then
  begin
    Inc(PendingPointCapacity, 256);
    SetLength(PendingPoints, PendingPointCapacity);
  end;
  Index := PendingPointCount;
  Inc(PendingPointCount);
  PendingPoints[Index].Color := ColorWithAlpha(Color, Alpha);
  PendingPoints[Index].X := X;
  PendingPoints[Index].Y := Y;
  PendingPoints[Index].Z := 1;
  PendingPoints[Index].RHW := 1;
  PendingPoints[Index].U := 0;
  PendingPoints[Index].V := 0;
end;
{ @end $4CA994 }

{ @routine $4CAA64 FlushDrawPoints }
procedure FlushDrawPoints(ClipRect: PRect);
var OldClip: TRect;
begin
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  Direct3DDevice.DrawPrimitiveUP(D3DPT_POINTLIST, PendingPointCount, @PendingPoints[0], SizeOf(TScreenVertexGR));
  PendingPointCount := 0;
  if ClipRect <> nil then Direct3DDevice.SetScissorRect(@OldClip);
end;
{ @end $4CAA64 }

{ @routine $4CAAD4 DrawAlphaLine }
procedure DrawAlphaLine(X1, Y1, X2, Y2: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect);
begin
  DrawGradientLine(X1, Y1, ColorWithAlpha(Color, Alpha), X2, Y2, ColorWithAlpha(Color, Alpha), ClipRect);
end;
{ @end $4CAAD4 }

{ @routine $4CAB20 DrawGradientLine }
procedure DrawGradientLine(X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; ClipRect: PRect);
var OldClip: TRect;
begin
  DrawVertices[0].Color := Color1;
  DrawVertices[0].X := X1;
  DrawVertices[0].Y := Y1;
  DrawVertices[1].Color := Color2;
  DrawVertices[1].X := X2;
  DrawVertices[1].Y := Y2;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  Direct3DDevice.DrawPrimitiveUP(D3DPT_LINESTRIP, 1, @DrawVertices, SizeOf(TScreenVertexGR));
  if ClipRect <> nil then Direct3DDevice.SetScissorRect(@OldClip);
end;
{ @end $4CAB20 }

{ @routine $4CABF8 DrawAntialiasedLineDX }
procedure DrawAntialiasedLineDX(StartX, StartY, FinishX, FinishY: Integer; Color: Cardinal; Alpha: Integer; UnusedClipRect: PRect);
var
  Slope, DX, DY, Gap, EndX, EndY, InterY, Coverage1, Coverage2: Double;
  X, FirstX, LastX, FirstY, LastY: Integer;
  Steep: Boolean;
  Temp, X1, Y1, X2, Y2: Double;

  // @nested $4CABCC LineFractionDX
  function LineFractionDX(Value: Double): Double; // @addr $4CABCC @calls "0x004CADA1,0x004CADDE,0x004CADF6,0x004CAED2,0x004CAF15,0x004CAF2A,0x004CB00B,0x004CB023"
  begin
    Result := Value - Floor(Value);
  end;

begin
  X1 := StartX; Y1 := StartY; X2 := FinishX; Y2 := FinishY;
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
  Gap := 1 - LineFractionDX(X1 + 0.5);
  FirstX := Floor(X1 + 0.5); FirstY := Floor(EndY);
  Coverage1 := (1 - LineFractionDX(EndY)) * Gap;
  Coverage2 := LineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(FirstY, FirstX, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(FirstY + 1, FirstX, Color, Ceil(Alpha * Coverage2));
  end
  else
  begin
    QueueDrawPoint(FirstX, FirstY, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(FirstX, FirstY + 1, Color, Ceil(Alpha * Coverage2));
  end;
  X := FirstX + 1;
  InterY := EndY + Slope;
  EndX := Floor(X2 + 0.5);
  EndY := Y2 + (EndX - X2) * Slope;
  Gap := 1 - LineFractionDX(X2 - 0.5);
  LastX := Floor(X2 + 0.5); LastY := Floor(EndY);
  while LastX - 1 >= X do
  begin
    Coverage1 := 1 - LineFractionDX(InterY); Coverage2 := LineFractionDX(InterY);
    if Steep then
    begin
      QueueDrawPoint(Floor(InterY), X, Color, Ceil(Alpha * Coverage1));
      QueueDrawPoint(Floor(InterY) + 1, X, Color, Ceil(Alpha * Coverage2));
    end
    else
    begin
      QueueDrawPoint(X, Floor(InterY), Color, Ceil(Alpha * Coverage1));
      QueueDrawPoint(X, Floor(InterY) + 1, Color, Ceil(Alpha * Coverage2));
    end;
    InterY := InterY + Slope;
    Inc(X);
  end;
  Coverage1 := (1 - LineFractionDX(EndY)) * Gap;
  Coverage2 := LineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(LastY, LastX, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(LastY + 1, LastX, Color, Ceil(Alpha * Coverage2));
  end
  else
  begin
    QueueDrawPoint(LastX, LastY, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(LastX, LastY + 1, Color, Ceil(Alpha * Coverage2));
  end;
  FlushDrawPoints(nil);
end;
{ @end $4CABF8 }

{ @routine $4CB124 DrawAnimatedLineDX }
procedure DrawAnimatedLineDX(StartX, StartY, FinishX, FinishY: Integer; Color: Cardinal; Phase: Integer; UnusedClipRect: PRect);
var
  Slope, DX, DY, Gap, EndX, EndY, InterY, Coverage1, Coverage2: Double;
  X, FirstX, LastX, FirstY, LastY: Integer;
  Steep: Boolean;
  Temp, X1, Y1, X2, Y2: Double;

  // @nested $4CB0D4 AnimatedLineFractionDX
  function AnimatedLineFractionDX(Value: Double): Double; // @addr $4CB0D4 @calls "0x004CB2CD,0x004CB30A,0x004CB322,0x004CB439,0x004CB47C,0x004CB491,0x004CB5AD,0x004CB5C5"
  begin
    Result := Value - Floor(Value);
  end;

  // @nested $4CB100 AdvanceLinePhase
  procedure AdvanceLinePhase; // @addr $4CB100 @calls "0x004CB3E7,0x004CB58B"
  begin
    Inc(Phase, 20);
    if Phase >= 360 then Dec(Phase, 360);
  end;

begin
  X1 := StartX; Y1 := StartY; X2 := FinishX; Y2 := FinishY;
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
  Gap := 1 - AnimatedLineFractionDX(X1 + 0.5);
  FirstX := Floor(X1 + 0.5); FirstY := Floor(EndY);
  Coverage1 := (1 - AnimatedLineFractionDX(EndY)) * Gap;
  Coverage2 := AnimatedLineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(FirstY, FirstX, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(FirstY + 1, FirstX, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end
  else
  begin
    QueueDrawPoint(FirstX, FirstY, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(FirstX, FirstY + 1, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end;
  AdvanceLinePhase;
  X := FirstX + 1;
  InterY := EndY + Slope;
  EndX := Floor(X2 + 0.5);
  EndY := Y2 + (EndX - X2) * Slope;
  Gap := 1 - AnimatedLineFractionDX(X2 - 0.5);
  LastX := Floor(X2 + 0.5); LastY := Floor(EndY);
  while LastX - 1 >= X do
  begin
    Coverage1 := 1 - AnimatedLineFractionDX(InterY); Coverage2 := AnimatedLineFractionDX(InterY);
    if Steep then
    begin
      QueueDrawPoint(Floor(InterY), X, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
      QueueDrawPoint(Floor(InterY) + 1, X, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
    end
    else
    begin
      QueueDrawPoint(X, Floor(InterY), Color, Ceil(LineAlphaTable[Phase] * Coverage1));
      QueueDrawPoint(X, Floor(InterY) + 1, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
    end;
    AdvanceLinePhase;
    InterY := InterY + Slope;
    Inc(X);
  end;
  Coverage1 := (1 - AnimatedLineFractionDX(EndY)) * Gap;
  Coverage2 := AnimatedLineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(LastY, LastX, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(LastY + 1, LastX, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end
  else
  begin
    QueueDrawPoint(LastX, LastY, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(LastX, LastY + 1, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end;
  FlushDrawPoints(nil);
end;
{ @end $4CB124 }

{ @routine $4CB6AC DrawColoredTriangle }
procedure DrawColoredTriangle(X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; X3, Y3: Integer; Color3: Cardinal; Filled: Boolean; ClipRect: PRect);
var OldClip: TRect;
begin
  DrawVertices[0].Color := Color1; DrawVertices[0].X := X1; DrawVertices[0].Y := Y1;
  DrawVertices[1].Color := Color2; DrawVertices[1].X := X2; DrawVertices[1].Y := Y2;
  DrawVertices[2].Color := Color3; DrawVertices[2].X := X3; DrawVertices[2].Y := Y3;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  if not Filled then Direct3DDevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
  Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST, 1, @DrawVertices, SizeOf(TScreenVertexGR));
  Direct3DDevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
  if ClipRect <> nil then Direct3DDevice.SetScissorRect(@OldClip);
end;
{ @end $4CB6AC }

{ @routine $4CB790 DrawColoredRect }
procedure DrawColoredRect(X, Y, Width, Height: Integer; Color: Cardinal; Alpha: Integer; Filled: Boolean; ClipRect: PRect);
var OldClip: TRect;
begin
  DrawVertices[0].Color := ColorWithAlpha(Color, Alpha); DrawVertices[0].X := X - 0.5; DrawVertices[0].Y := Y - 0.5;
  DrawVertices[1].Color := DrawVertices[0].Color; DrawVertices[1].X := X + Width - 0.5; DrawVertices[1].Y := Y - 0.5;
  DrawVertices[2].Color := DrawVertices[0].Color; DrawVertices[2].X := X + Width - 0.5; DrawVertices[2].Y := Y + Height - 0.5;
  DrawVertices[3].Color := DrawVertices[0].Color; DrawVertices[3].X := X - 0.5; DrawVertices[3].Y := Y + Height - 0.5;
  DrawVertices[4].Color := DrawVertices[0].Color; DrawVertices[4].X := X - 0.5; DrawVertices[4].Y := Y - 0.5;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  if Filled then Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 4, @DrawVertices, SizeOf(TScreenVertexGR))
  else Direct3DDevice.DrawPrimitiveUP(D3DPT_LINESTRIP, 4, @DrawVertices, SizeOf(TScreenVertexGR));
  if ClipRect <> nil then Direct3DDevice.SetScissorRect(@OldClip);
end;
{ @end $4CB790 }

{ @routine $4CB90C DrawAntialiasedCircle }
procedure DrawAntialiasedCircle(X, Y, Radius: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect);
var DX, DY, SX, SY, Quadrant: Integer; PreviousCoverage, Coverage: Single; PreviousDX: Integer;
begin
  DX := Radius; PreviousDX := Radius; DY := 0; PreviousCoverage := 0;
  Quadrant := 0;
  while Quadrant < 4 do
  begin
    SX := (Quadrant mod 2) * 2 - 1;
    SY := ((Quadrant div 2) mod 2) * 2 - 1;
    QueueDrawPoint(SX * DX + X, SY * DY + Y, Color, Alpha);
    QueueDrawPoint(SX * DY + X, SY * DX + Y, Color, Alpha);
    Inc(Quadrant);
  end;
  while DX > DY do
  begin
    Inc(DY);
    Coverage := Sqrt(Sqr(Radius) - Sqr(DY));
    Coverage := Ceil(Coverage) - Coverage;
    if Coverage < PreviousCoverage then Dec(DX);
    if DX < DY then Break;
    if (DX = DY) and (PreviousDX = DX) then Break;
    Quadrant := 0;
    while Quadrant < 4 do
    begin
      SX := (Quadrant mod 2) * 2 - 1;
      SY := ((Quadrant div 2) mod 2) * 2 - 1;
      QueueDrawPoint(SX * DX + X, SY * DY + Y, Color, Trunc((1 - Coverage) * Alpha));
      QueueDrawPoint(SX * DY + X, SY * DX + Y, Color, Trunc((1 - Coverage) * Alpha));
      if DX - 1 >= DY then
      begin
        QueueDrawPoint((DX - 1) * SX + X, SY * DY + Y, Color, Trunc(Alpha * Coverage));
        QueueDrawPoint(SX * DY + X, (DX - 1) * SY + Y, Color, Trunc(Alpha * Coverage));
      end;
      Inc(Quadrant);
    end;
    PreviousCoverage := Coverage;
    PreviousDX := DX;
  end;
  FlushDrawPoints(ClipRect);
end;
{ @end $4CB90C }

{ @routine $4CBB20 DrawCircle }
procedure DrawCircle(X, Y, Radius: Integer; Color: Cardinal; Alpha, Mode: Integer; ClipRect: PRect);
var Index: Integer; Vertices: array[0..4] of TScreenVertexGR; OldClip: TRect;
begin
  for Index := 0 to 4 do
  begin
    Vertices[Index].Color := ColorWithAlpha(Color, Alpha);
    Vertices[Index].X := X; Vertices[Index].Y := Y;
    Vertices[Index].Z := 1; Vertices[Index].RHW := 1;
  end;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  if Mode = 0 then DrawAntialiasedCircle(X, Y, Radius, Color, Alpha, ClipRect)
  else if Mode = 1 then
  begin
    for Index := 0 to 359 do
    begin
      Vertices[0].X := Radius * CircleCos[Index] + X;
      Vertices[0].Y := Radius * CircleSin[Index] + Y;
      Vertices[1].X := Radius * CircleCos[Index + 1] + X;
      Vertices[1].Y := Radius * CircleSin[Index + 1] + Y;
      Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST, 1, @Vertices, SizeOf(TScreenVertexGR));
    end;
  end
  else if Mode = 2 then
  begin
    for Index := 0 to 359 do
    begin
      Vertices[1].X := X + Trunc(Radius * CircleCos[Index + 1]);
      Vertices[1].Y := Y + Trunc(Radius * CircleSin[Index + 1]);
      Vertices[2].X := X + Trunc(Radius * CircleCos[Index]);
      Vertices[2].Y := Y + Trunc(Radius * CircleSin[Index]);
      if Index < 90 then
      begin
        Vertices[0].X := X + Radius; Vertices[0].Y := Y + Radius;
      end
      else if Index < 180 then
      begin
        Vertices[0].X := X - Radius; Vertices[0].Y := Y + Radius;
      end
      else if Index < 270 then
      begin
        Vertices[0].X := X - Radius; Vertices[0].Y := Y - Radius;
      end
      else
      begin
        Vertices[0].X := X + Radius; Vertices[0].Y := Y - Radius;
      end;
      Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST, 1, @Vertices, SizeOf(TScreenVertexGR));
    end;
  end;
  if ClipRect <> nil then Direct3DDevice.SetScissorRect(@OldClip);
end;
{ @end $4CBB20 }

{ @routine $4CBE58 DrawTexture }
procedure DrawTexture(Texture: IDirect3DTexture9; X, Y, Alpha: Integer; Color: Cardinal; ClipRect: PRect; UsePreparedVertices, MirrorHorizontal: Boolean);
begin
  DrawTextureSized(Texture, X, Y, 0, 0, Alpha, Color, ClipRect, UsePreparedVertices, MirrorHorizontal);
end;
{ @end $4CBE58 }

{ @routine $4CBEC8 DrawTextureSized }
procedure DrawTextureSized(Texture: IDirect3DTexture9; X, Y, Width, Height, Alpha: Integer; Color: Cardinal; ClipRect: PRect; UsePreparedVertices, MirrorHorizontal: Boolean);
var Desc: TD3DSurfaceDesc; OldClip: TRect;
begin
  if Texture = nil then Exit;
  if not UsePreparedVertices then
  begin
    Texture.GetLevelDesc(0, Desc);
    if Width = 0 then Width := Desc.Width;
    if Height = 0 then Height := Desc.Height;
    DrawVertices[0].Color := ColorWithAlpha(Color, Alpha); DrawVertices[0].X := X - 0.5; DrawVertices[0].Y := Y - 0.5;
    DrawVertices[0].U := 0 + Integer(MirrorHorizontal); DrawVertices[0].V := 0;
    DrawVertices[1].Color := DrawVertices[0].Color; DrawVertices[1].X := X + Width - 0.5; DrawVertices[1].Y := Y - 0.5;
    DrawVertices[1].U := 1 - Integer(MirrorHorizontal); DrawVertices[1].V := 0;
    DrawVertices[2].Color := DrawVertices[0].Color; DrawVertices[2].X := X + Width - 0.5; DrawVertices[2].Y := Y + Height - 0.5;
    DrawVertices[2].U := 1 - Integer(MirrorHorizontal); DrawVertices[2].V := 1;
    DrawVertices[3].Color := DrawVertices[0].Color; DrawVertices[3].X := X - 0.5; DrawVertices[3].Y := Y + Height - 0.5;
    DrawVertices[3].U := 0 + Integer(MirrorHorizontal); DrawVertices[3].V := 1;
  end;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  Direct3DDevice.SetTexture(0, Texture);
  Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @DrawVertices, SizeOf(TScreenVertexGR));
  Direct3DDevice.SetTexture(0, nil);
  if ClipRect <> nil then Direct3DDevice.SetScissorRect(@OldClip);
end;
{ @end $4CBEC8 }

{ @routine $4CC0EC Color565ToArgb }
function Color565ToArgb(Color: Cardinal): Cardinal;
begin
  Result := ((Color shl 3) and $F8) or (((Color shr 3) and $FC) shl 8) or (((Color shr 8) and $F8) shl 16) or $FF000000;
end;
{ @end $4CC0EC }

{ @routine $4CC120 ColorWithAlpha }
function ColorWithAlpha(Color, Alpha: Cardinal): Cardinal;
begin
  Result := (Color and $FFFFFF) or ((Alpha and $FF) shl 24);
end;
{ @end $4CC120 }

{ @routine $4CC134 GetTextureByteSize }
function GetTextureByteSize(Texture: IDirect3DTexture9): Cardinal;
var ByteCount: Cardinal; Desc: TD3DSurfaceDesc;
begin
  ByteCount := 0;
  if Texture <> nil then
  begin
    Texture.GetLevelDesc(0, Desc);
    if (Desc.Format = D3DFMT_A8R8G8B8) or (Desc.Format = D3DFMT_A8R8G8B8) then ByteCount := 4
    else if Desc.Format = D3DFMT_R8G8B8 then ByteCount := 3
    else if Desc.Format = D3DFMT_R5G6B5 then ByteCount := 2
    else if Desc.Format = D3DFMT_A8 then ByteCount := 1;
    ByteCount := Desc.Width * Desc.Height * ByteCount;
  end;
  Result := ByteCount;
end;
{ @end $4CC134 }

{ @routine $4CC1D0 AddResidentTextureBytes }
procedure AddResidentTextureBytes(ByteCount: Cardinal);
begin
  Inc(ResidentTextureBytes, ByteCount);
end;
{ @end $4CC1D0 }

{ @routine $4CC1D8 SubtractResidentTextureBytes }
procedure SubtractResidentTextureBytes(ByteCount: Cardinal);
begin
  if ResidentTextureBytes > ByteCount then
  begin
    Dec(ResidentTextureBytes, ByteCount);
    Exit;
  end;
  ResidentTextureBytes := 0;
end;
{ @end $4CC1D8 }

end.
