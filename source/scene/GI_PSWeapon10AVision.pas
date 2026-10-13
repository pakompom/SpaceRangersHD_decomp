unit GI_PSWeapon10AVision;
// Native TPSWeapon10AVision and methods; includes its configuration palette loader.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PAVisionParticle = ^TAVisionParticle;
  TAVisionParticle = record // @size $1C
    Kind: Integer; // @offset $00
    Position: TPointF; // @offset $04
    Color: Word; // @offset $0C
    Alpha: Byte; // @offset $0E
    Velocity: TPointF; // @offset $10
    FadeInTicks: Byte; // @offset $18
    InitialFadeInTicks: Byte; // @offset $19
    FadeOutThreshold: Byte; // @offset $1A
  end;

  TAVisionPalette = array[0..3] of Word;
  TAVisionPalettes = array of TAVisionPalette;
  TGAISet = array[0..0] of WideString;
  TAVisionAnimationPaths = array of TGAISet;

var
  AVisionPalettes: array of TAVisionPalette; // @addr $81B1D0
  AVisionAnimationPaths: array of TGAISet; // @addr $81B1D4

type
  TPSWeapon10AVision = class(TPSWeaponGI) // @size $14C
  public
    Unknown130: Integer; // @offset $130  Explicitly zeroed by the constructor.
    Particles: PAVisionParticle; // @offset $134
    ParticleCount: Integer; // @offset $138
    ParticleCapacity: Integer; // @offset $13C
    OriginalLength: Single; // @offset $140
    Colors: TAVisionPalette; // @offset $144

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $4F390C
    destructor Destroy; override; // @addr $4F39B0
    procedure Invalidate; override; // @addr $4F39DC @note "Native empty override."
    procedure SetPosition(Position: TPoint); override; // @addr $4F39E0
    procedure SetTargetPoint(Point: TPoint); override; // @addr $4F3A0C
    procedure UpdateHitTestBounds; override; // @addr $4F3A48
    procedure ClearParticles; // @addr $4F3A6C
    procedure GrowParticles; // @addr $4F3A98
    function AddParticle: PAVisionParticle; // @addr $4F3ABC
    procedure Advance(Timer: TCallbackTimerIdGI; UserData: Cardinal); override; // @addr $4F3AF4
    procedure Draw(ClipRect: TRect); override; // @addr $4F3DDC
  end;

procedure LoadAVisionPalettes; // @addr $4F4030

implementation

// @unit-initialization $80684C
// @unit-finalization $4F4308

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $4F390C TPSWeapon10AVision_Create }
constructor TPSWeapon10AVision.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  RemainingTicks := 40;
  LifetimeTicks := 40;
  Unknown130 := 0;
  Colors[0] := AVisionPalettes[APaletteIndex][0];
  Colors[1] := AVisionPalettes[APaletteIndex][1];
  Colors[2] := AVisionPalettes[APaletteIndex][2];
  Colors[3] := AVisionPalettes[APaletteIndex][3];
end;
{ @end $4F390C }

{ @routine $4F39B0 TPSWeapon10AVision_Destroy }
destructor TPSWeapon10AVision.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $4F39B0 }

{ @routine $4F39DC TPSWeapon10AVision_Invalidate }
procedure TPSWeapon10AVision.Invalidate;
begin
end;
{ @end $4F39DC }

{ @routine $4F39E0 TPSWeapon10AVision_SetPosition }
procedure TPSWeapon10AVision.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
    inherited SetPosition(Position);
end;
{ @end $4F39E0 }

{ @routine $4F3A0C TPSWeapon10AVision_SetTargetPoint }
procedure TPSWeapon10AVision.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
    TargetPoint := Point;
end;
{ @end $4F3A0C }

{ @routine $4F3A48 TPSWeapon10AVision_UpdateHitTestBounds }
procedure TPSWeapon10AVision.UpdateHitTestBounds;
begin
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  HitTestBounds.Right := GameScreenWidth;
  HitTestBounds.Bottom := GameScreenHeight;
end;
{ @end $4F3A48 }

{ @routine $4F3A6C TPSWeapon10AVision_ClearParticles }
procedure TPSWeapon10AVision.ClearParticles;
begin
  if Particles <> nil then
  begin
    FreeEC(Particles);
    Particles := nil;
  end;
  ParticleCount := 0;
  ParticleCapacity := 0;
end;
{ @end $4F3A6C }

{ @routine $4F3A98 TPSWeapon10AVision_GrowParticles }
procedure TPSWeapon10AVision.GrowParticles;
begin
  Inc(ParticleCapacity, 100);
  Particles := ReAllocREC(Particles, ParticleCapacity * SizeOf(TAVisionParticle));
end;
{ @end $4F3A98 }

{ @routine $4F3ABC TPSWeapon10AVision_AddParticle }
function TPSWeapon10AVision.AddParticle: PAVisionParticle;
begin
  if ParticleCount >= ParticleCapacity then GrowParticles;
  Result := AddPointerOffset(Particles, ParticleCount * SizeOf(TAVisionParticle));
  Inc(ParticleCount);
end;
{ @end $4F3ABC }

{ @routine $4F3AF4 TPSWeapon10AVision_Advance }
procedure TPSWeapon10AVision.Advance(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  Particle: PAVisionParticle;
  Count, I: Integer;
  Y: Single;
begin
  if RemainingTicks = 40 then
  begin
    OriginalLength := Sqrt(Sqr(LocalPosition.X - TargetPoint.X) + Sqr(LocalPosition.Y - TargetPoint.Y));
    for I := 0 to 3 do
    begin
      Y := 0;
      while Y < OriginalLength do
      begin
        Particle := AddParticle;
        if Random(2) = 0 then Particle.Position.X := -I
        else Particle.Position.X := I;
        Particle.Position.Y := Y;
        Particle.Kind := 1;
        Particle.Alpha := 0;
        Particle.InitialFadeInTicks := 11 - I;
        Particle.FadeInTicks := Particle.InitialFadeInTicks;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := 7.0 - I * 2;
        Particle.FadeOutThreshold := Trunc(Sin(Pi * Y / 40.0) * 8.0 + 20.0);
        Particle.Color := Colors[I];
        Y := Y + 1.5 + I;
      end;
    end;
  end;
  Particle := Particles;
  Count := ParticleCount;
  I := 0;
  UpdateHitTestBounds;
  while Count > 0 do
  begin
    if Particle.Kind = 1 then
    begin
      Particle.Position.X := Particle.Position.X + Particle.Velocity.X;
      Particle.Position.Y := Particle.Position.Y + Particle.Velocity.Y;
      if Particle.Position.Y > OriginalLength then
      begin
        Particle.Position.Y := Particle.Position.Y - OriginalLength;
        Particle.Alpha := 0;
        Particle.FadeInTicks := Particle.InitialFadeInTicks;
      end
      else
      begin
        Inc(Particle.Alpha, 20);
        Dec(Particle.FadeInTicks);
        if Particle.FadeInTicks = 0 then
        begin
          Particle.FadeInTicks := 100;
          Particle.Kind := 2;
        end;
      end;
      if RemainingTicks < Particle.FadeOutThreshold then Particle.Kind := 3;
    end
    else if Particle.Kind = 2 then
    begin
      Particle.Position.X := Particle.Position.X + Particle.Velocity.X;
      Particle.Position.Y := Particle.Position.Y + Particle.Velocity.Y;
      if OriginalLength - 32.0 < Particle.Position.Y then
      begin
        if Particle.Alpha < 245 then Inc(Particle.Alpha, 10)
        else Particle.Alpha := 255;
      end;
      if Particle.Position.Y > OriginalLength then
      begin
        Particle.Position.Y := Particle.Position.Y - OriginalLength;
        Particle.Alpha := 0;
        Particle.FadeInTicks := Particle.InitialFadeInTicks;
        Particle.Kind := 1;
      end;
      if RemainingTicks < Particle.FadeOutThreshold then Particle.Kind := 3;
    end
    else if Particle.Kind = 3 then
    begin
      Particle.Position.X := Particle.Position.X + Particle.Velocity.X;
      Particle.Position.Y := Particle.Position.Y + Particle.Velocity.Y;
      if Particle.Position.Y > OriginalLength then
      begin
        Particle.Position.Y := Particle.Position.Y - OriginalLength;
        Particle.Alpha := 0;
      end;
      if Particle.Alpha > 12 then Dec(Particle.Alpha, 12)
      else Particle.Alpha := 0;
    end;
    Inc(I);
    Particle := AddPointerOffset(Particles, I * SizeOf(TAVisionParticle));
    Dec(Count);
  end;
  Dec(RemainingTicks);
end;
{ @end $4F3AF4 }

{ @routine $4F3DDC TPSWeapon10AVision_Draw }
procedure TPSWeapon10AVision.Draw(ClipRect: TRect);
var
  X, Y: Integer;
  PX, PY, Sine, Cosine, Angle, Scale: Single;
  Particle: PAVisionParticle;
  Count: Integer;
begin
  if OriginalLength = 0 then OriginalLength := 1;
  Scale := Sqrt(Sqr(LocalPosition.X - TargetPoint.X) + Sqr(LocalPosition.Y - TargetPoint.Y)) / OriginalLength;
  PY := -(TargetPoint.Y - LocalPosition.Y);
  if PY = 0 then PY := 1;
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, PY);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Particle := Particles;
  Count := ParticleCount;
  if HardwareRenderingEnabled then
  begin
    while Count > 0 do
    begin
      if Particle.Kind >= 1 then
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Round(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Round(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TAVisionParticle));
      Dec(Count);
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Count > 0 do
    begin
      if Particle.Kind >= 1 then
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Round(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Round(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TAVisionParticle));
      Dec(Count);
    end;
  end;
end;
{ @end $4F3DDC }

{ @routine $4F4030 LoadAVisionPalettes }
procedure LoadAVisionPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.9.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(AVisionPalettes, Count);
  SetLength(AVisionAnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) = 0 then Continue;
    PaletteBlock := Block.GetBlockByPath(Text);
    for ColorIndex := Low(TAVisionPalette) to High(TAVisionPalette) do
      if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
      begin
        Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
        AVisionPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
          ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
          ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
          ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
      end;
    if PaletteBlock.CountParams('GAI') > 0 then
      AVisionAnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
  end;
end;
{ @end $4F4030 }

end.
