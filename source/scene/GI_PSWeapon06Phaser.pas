unit GI_PSWeapon06Phaser;
// Native phaser class and routines: $68C200..$68D0A1. Palette finalizer: $68D0EC.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PPhaserParticle = ^TPhaserParticle;
  TPhaserParticle = record // @size $30
    Next: PPhaserParticle; // @offset $00
    Prev: PPhaserParticle; // @offset $04
    Kind: Byte; // @offset $08
    Position: TPointF; // @offset $0C
    Incoming: Single; // @offset $14
    Displacement: Single; // @offset $18
    Reflected: Single; // @offset $1C
    Color: Word; // @offset $20
    Alpha: Byte; // @offset $22
    Phase: Single; // @offset $24
    PhaseStep: Single; // @offset $28
    PhaseCountdown: Byte; // @offset $2C
  end;
  TPhaserPalette = array[0..8] of Single;
  TPhaserPalettes = array of TPhaserPalette;

var
  PhaserPalettes: array of TPhaserPalette; // @addr $88ACAC

type
  TPSWeapon06Phaser = class(TPSWeaponGI) // @size $144
  public
    Particles: PPhaserParticle; // @offset $130
    ParticleCount: Integer; // @offset $134
    ParticleCapacity: Integer; // @offset $138
    OriginalLength: Single; // @offset $13C
    PaletteIndex: Integer; // @offset $140

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $68C334
    destructor Destroy; override; // @addr $68C3A4
    procedure Invalidate; override; // @addr $68C3E0 @note "Native empty override."
    procedure SetPosition(Position: TPoint); override; // @addr $68C3EC
    procedure SetTargetPoint(Point: TPoint); override; // @addr $68C428
    procedure UpdateHitTestBounds; override; // @addr $68C474
    procedure ClearParticles; // @addr $68C4A8
    procedure GrowParticles; // @addr $68C4F0
    function AddParticle: PPhaserParticle; // @addr $68C5A4
    procedure AdvanceWave; // @addr $68C65C
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $68C86C
    procedure Draw(ClipRect: TRect); override; // @addr $68CB9C
  end;

procedure LoadPhaserPalettes; // @addr $68CE74 @note "Loads SE.Weapon.5.Palettes; native visual numbering differs from the class name."

implementation

// @unit-initialization $87790C
// @unit-finalization $68D0EC

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $68C334 TPSWeapon06Phaser_Create }
constructor TPSWeapon06Phaser.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  RemainingTicks := 60;
  LifetimeTicks := 60;
  PaletteIndex := APaletteIndex;
end;
{ @end $68C334 }

{ @routine $68C3A4 TPSWeapon06Phaser_Destroy }
destructor TPSWeapon06Phaser.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $68C3A4 }

{ @routine $68C3E0 TPSWeapon06Phaser_Invalidate }
procedure TPSWeapon06Phaser.Invalidate;
begin
end;
{ @end $68C3E0 }

{ @routine $68C3EC TPSWeapon06Phaser_SetPosition }
procedure TPSWeapon06Phaser.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
    inherited SetPosition(Position);
end;
{ @end $68C3EC }

{ @routine $68C428 TPSWeapon06Phaser_SetTargetPoint }
procedure TPSWeapon06Phaser.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
    TargetPoint := Point;
end;
{ @end $68C428 }

{ @routine $68C474 TPSWeapon06Phaser_UpdateHitTestBounds }
procedure TPSWeapon06Phaser.UpdateHitTestBounds;
begin
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  HitTestBounds.Right := GameScreenWidth;
  HitTestBounds.Bottom := GameScreenHeight;
end;
{ @end $68C474 }

{ @routine $68C4A8 TPSWeapon06Phaser_ClearParticles }
procedure TPSWeapon06Phaser.ClearParticles;
begin
  if Particles <> nil then
  begin
    FreeEC(Particles);
    Particles := nil;
  end;
  ParticleCount := 0;
  ParticleCapacity := 0;
end;
{ @end $68C4A8 }

{ @routine $68C4F0 TPSWeapon06Phaser_GrowParticles }
procedure TPSWeapon06Phaser.GrowParticles;
var
  Index: Integer;
  Particle, Previous, Following: PPhaserParticle;
begin
  Inc(ParticleCapacity, 100);
  Particles := ReAllocREC(Particles, ParticleCapacity * SizeOf(TPhaserParticle));
  Particle := Particles;
  Previous := nil;
  for Index := 0 to ParticleCount - 1 do
  begin
    if Index < ParticleCount - 1 then Following := AddPointerOffset(Particle, SizeOf(TPhaserParticle))
    else Following := nil;
    Particle.Next := Following;
    Particle.Prev := Previous;
    Previous := Particle;
    Particle := Following;
  end;
end;
{ @end $68C4F0 }

{ @routine $68C5A4 TPSWeapon06Phaser_AddParticle }
function TPSWeapon06Phaser.AddParticle: PPhaserParticle;
var
  Previous, Particle: PPhaserParticle;
begin
  if ParticleCount >= ParticleCapacity then GrowParticles;
  Particle := AddPointerOffset(Particles, ParticleCount * SizeOf(TPhaserParticle));
  if ParticleCount = 0 then Previous := nil
  else Previous := AddPointerOffset(Particles, (ParticleCount - 1) * SizeOf(TPhaserParticle));
  Result := Particle;
  Inc(ParticleCount);
  Particle.Next := nil;
  Particle.Prev := Previous;
  if Previous <> nil then Previous.Next := Particle;
end;
{ @end $68C5A4 }

{ @routine $68C65C TPSWeapon06Phaser_AdvanceWave }
procedure TPSWeapon06Phaser.AdvanceWave;
var
  Particle: PPhaserParticle;
  Count, Index: Integer;
begin
  Index := 0;
  Particle := Particles;
  Count := ParticleCount;
  while Count > 0 do
  begin
    if Particle.Kind = 1 then
    begin
      if Particle.Next <> nil then Particle.Next.Incoming := Particle.Displacement;
      Dec(Particle.PhaseCountdown);
      if Particle.PhaseCountdown = 0 then
      begin
        Particle.PhaseCountdown := 16;
        Particle.PhaseStep := RandomFloatRange(Pi / 25, Pi / 20);
      end;
      Particle.Phase := Particle.Phase + Particle.PhaseStep;
      if 2 * Pi <= Particle.Phase then Particle.Phase := Particle.Phase - 2 * Pi;
      Particle.Displacement := Sin(Particle.Phase) * 2.0 + RandomIntRange(-1, 1);
    end
    else if Particle.Kind = 2 then
    begin
      if Particle.Next <> nil then Particle.Next.Incoming := Particle.Displacement;
      if Particle.Prev <> nil then Particle.Prev.Reflected := Particle.Reflected;
      Particle.Displacement := Particle.Incoming;
    end
    else if Particle.Kind = 4 then
    begin
      if Particle.Next <> nil then Particle.Next.Incoming := Particle.Displacement;
      if Particle.Prev <> nil then Particle.Prev.Reflected := Particle.Reflected;
      Particle.Displacement := -Particle.Incoming;
    end
    else if Particle.Kind = 3 then
    begin
      if Particle.Prev <> nil then Particle.Prev.Reflected := Particle.Reflected;
      Particle.Reflected := -Particle.Incoming;
      Particle.Displacement := Particle.Incoming;
    end;
    Inc(Index);
    Particle := AddPointerOffset(Particles, Index * SizeOf(TPhaserParticle));
    Dec(Count);
  end;
end;
{ @end $68C65C }

{ @routine $68C86C TPSWeapon06Phaser_Advance }
procedure TPSWeapon06Phaser.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Particle: PPhaserParticle;
  Index, Step: Integer;
begin
  if RemainingTicks = 60 then
  begin
    OriginalLength := Sqrt(Sqr(LocalPosition.X - TargetPoint.X) + Sqr(LocalPosition.Y - TargetPoint.Y));
    ClearParticles;
    Particle := AddParticle;
    Particle.Kind := 1;
    Particle.Position := MakePointF(0, 16);
    Particle.Incoming := 0;
    Particle.Displacement := 0;
    Particle.Reflected := 0;
    Particle.Color := CurrentPixelFormat.PackNormalizedRgb(1.0, 0.5, 0.33);
    Particle.Alpha := 0;
    Particle.Phase := 0;
    Particle.PhaseCountdown := 1;
    Particle.PhaseStep := Pi / 8;
    Index := 17;
    while Index < OriginalLength do
    begin
      Particle := AddParticle;
      Particle.Kind := 2;
      Particle.Position := MakePointF(0, Index);
      Particle.Incoming := 0;
      Particle.Displacement := RandomIntRange(-1, 1);
      Particle.Reflected := 0;
      Particle.Color := SampleGradientColor(PhaserPalettes[PaletteIndex], Index / OriginalLength * 15.0);
      if Particle.Position.Y < 32.0 then Particle.Alpha := Trunc(Particle.Position.Y * 255.0) shr 5
      else Particle.Alpha := 255;
      Inc(Index);
    end;
    Particle := AddParticle;
    Particle.Kind := 3;
    Particle.Position := MakePointF(0, OriginalLength);
    Particle.Incoming := 0;
    Particle.Displacement := 0;
    Particle.Reflected := 0;
    Particle.Color := CurrentPixelFormat.PackNormalizedRgb(1.0, 0.5, 0.33);
    if Particle.Position.Y < 32.0 then Particle.Alpha := Trunc(Particle.Position.Y * 255.0) shr 5
    else Particle.Alpha := 255;
    for Step := 1 to Trunc(0.3 * OriginalLength) do AdvanceWave;
  end;
  UpdateHitTestBounds;
  for Step := 1 to 6 do AdvanceWave;
  if RemainingTicks > 0 then Dec(RemainingTicks);
end;
{ @end $68C86C }

{ @routine $68CB9C TPSWeapon06Phaser_Draw }
procedure TPSWeapon06Phaser.Draw(ClipRect: TRect);
var
  Particle: PPhaserParticle;
  X, Y: Integer;
  PX, PY, Sine, Cosine, Angle, Scale: Single;
  Count: Integer;
begin
  if OriginalLength = 0 then Advance(nil, 0);
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
      if (Particle.Kind >= 1) and (Particle.Kind <= 3) then
      begin
        Particle.Position.X := Particle.Displacement;
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Trunc(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Trunc(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TPhaserParticle));
      Dec(Count);
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Count > 0 do
    begin
      if (Particle.Kind >= 1) and (Particle.Kind <= 3) then
      begin
        Particle.Position.X := Particle.Displacement;
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Trunc(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Trunc(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TPhaserParticle));
      Dec(Count);
    end;
  end;
end;
{ @end $68CB9C }

{ @routine $68CE74 LoadPhaserPalettes }
procedure LoadPhaserPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, PartIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.5.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(PhaserPalettes, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 2 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
          for PartIndex := 0 to 2 do
            PhaserPalettes[Index][3 * ColorIndex + PartIndex] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, PartIndex, ','));
        end;
    end;
  end;
end;
{ @end $68CE74 }

end.
