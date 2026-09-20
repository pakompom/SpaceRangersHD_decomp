unit GI_PSWeapon08ECutter;
// Native TPSWeapon08ECutter and methods; includes its configuration palette loader.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PECutterParticle = ^TECutterParticle;
  TECutterParticle = record // @size $1C
    Kind: Integer; // @offset $00
    Position: TPointF; // @offset $04
    Color: Word; // @offset $0C
    Alpha: Byte; // @offset $0E
    Velocity: TPointF; // @offset $10
    Unknown1A: Byte; // @offset $1A  Initialized to zero; unused by this renderer.
  end;

  TECutterPalette = array[0..7] of Word;
  TECutterPalettes = array of TECutterPalette;

var
  ECutterPalettes: array of TECutterPalette; // @addr $88AEBC

type
  TPSWeapon08ECutter = class(TPSWeaponGI) // @size $150
  public
    Particles: PECutterParticle; // @offset $130
    ParticleCount: Integer; // @offset $134
    ParticleCapacity: Integer; // @offset $138
    OriginalLength: Single; // @offset $13C
    Colors: TECutterPalette; // @offset $140

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $68E904
    destructor Destroy; override; // @addr $68EA38
    procedure Invalidate; override; // @addr $68EA74 @note "Native empty override."
    procedure SetPosition(Position: TPoint); override; // @addr $68EA80
    procedure SetTargetPoint(Point: TPoint); override; // @addr $68EABC
    procedure UpdateHitTestBounds; override; // @addr $68EB08
    procedure ClearParticles; // @addr $68EB3C
    procedure GrowParticles; // @addr $68EB84
    function AddParticle: PECutterParticle; // @addr $68EBBC
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $68EC14
    procedure Draw(ClipRect: TRect); override; // @addr $68EEA0
  end;

procedure LoadECutterPalettes; // @addr $68F120

implementation

// @unit-initialization $87791C
// @unit-finalization $68F3E4

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $68E904 TPSWeapon08ECutter_Create }
constructor TPSWeapon08ECutter.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  RemainingTicks := 55;
  LifetimeTicks := 55;
  Colors[0] := ECutterPalettes[APaletteIndex][0];
  Colors[1] := ECutterPalettes[APaletteIndex][1];
  Colors[2] := ECutterPalettes[APaletteIndex][2];
  Colors[3] := ECutterPalettes[APaletteIndex][3];
  Colors[4] := ECutterPalettes[APaletteIndex][4];
  Colors[5] := ECutterPalettes[APaletteIndex][5];
  Colors[6] := ECutterPalettes[APaletteIndex][6];
  Colors[7] := ECutterPalettes[APaletteIndex][7];
end;
{ @end $68E904 }

{ @routine $68EA38 TPSWeapon08ECutter_Destroy }
destructor TPSWeapon08ECutter.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $68EA38 }

{ @routine $68EA74 TPSWeapon08ECutter_Invalidate }
procedure TPSWeapon08ECutter.Invalidate;
begin
end;
{ @end $68EA74 }

{ @routine $68EA80 TPSWeapon08ECutter_SetPosition }
procedure TPSWeapon08ECutter.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
    inherited SetPosition(Position);
end;
{ @end $68EA80 }

{ @routine $68EABC TPSWeapon08ECutter_SetTargetPoint }
procedure TPSWeapon08ECutter.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
    TargetPoint := Point;
end;
{ @end $68EABC }

{ @routine $68EB08 TPSWeapon08ECutter_UpdateHitTestBounds }
procedure TPSWeapon08ECutter.UpdateHitTestBounds;
begin
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  HitTestBounds.Right := GameScreenWidth;
  HitTestBounds.Bottom := GameScreenHeight;
end;
{ @end $68EB08 }

{ @routine $68EB3C TPSWeapon08ECutter_ClearParticles }
procedure TPSWeapon08ECutter.ClearParticles;
begin
  if Particles <> nil then
  begin
    FreeEC(Particles);
    Particles := nil;
  end;
  ParticleCount := 0;
  ParticleCapacity := 0;
end;
{ @end $68EB3C }

{ @routine $68EB84 TPSWeapon08ECutter_GrowParticles }
procedure TPSWeapon08ECutter.GrowParticles;
begin
  Inc(ParticleCapacity, 100);
  Particles := ReAllocREC(Particles, ParticleCapacity * SizeOf(TECutterParticle));
end;
{ @end $68EB84 }

{ @routine $68EBBC TPSWeapon08ECutter_AddParticle }
function TPSWeapon08ECutter.AddParticle: PECutterParticle;
begin
  if ParticleCount >= ParticleCapacity then GrowParticles;
  Result := AddPointerOffset(Particles, ParticleCount * SizeOf(TECutterParticle));
  Inc(ParticleCount);
end;
{ @end $68EBBC }

{ @routine $68EC14 TPSWeapon08ECutter_Advance }
procedure TPSWeapon08ECutter.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Particle: PECutterParticle;
  J, I, K: Integer;
  Speed: Single;
begin
  if RemainingTicks = 55 then
  begin
    OriginalLength := Sqrt(Sqr(LocalPosition.X - TargetPoint.X) + Sqr(LocalPosition.Y - TargetPoint.Y));
    Speed := (OriginalLength + 128.0) / 55.0;
    for I := 0 to 1 do
      for J := 0 to 15 do
        for K := -6 to 6 do
        begin
          Particle := AddParticle;
          Particle.Kind := 2;
          Particle.Position.X := (J * 3 * 8 / OriginalLength + 3.0) * (K / 6.0);
          Particle.Position.Y := Sqrt(144 - Sqr(K)) + J * 8 - 128.0 + I;
          Particle.Color := Colors[(Abs(K) * 8) div 7];
          Particle.Alpha := 0;
          Particle.Velocity.X := 3.0 * Particle.Position.X / 3.0 / 55.0;
          Particle.Velocity.Y := Speed;
          Particle.Unknown1A := 0;
        end;
  end;
  I := 0;
  Particle := Particles;
  J := ParticleCount;
  UpdateHitTestBounds;
  while J > 0 do
  begin
    if Particle.Kind = 2 then
    begin
      Particle.Position.X := Particle.Position.X + Particle.Velocity.X;
      Particle.Position.Y := Particle.Position.Y + Particle.Velocity.Y;
      if Particle.Position.Y >= OriginalLength then Particle.Kind := 0;
      if Particle.Position.Y > 0 then
      begin
        if Particle.Alpha < 231 then Inc(Particle.Alpha, 24)
        else Particle.Alpha := 255;
      end;
    end;
    Inc(I);
    Particle := AddPointerOffset(Particles, I * SizeOf(TECutterParticle));
    Dec(J);
  end;
  if RemainingTicks > 0 then Dec(RemainingTicks);
end;
{ @end $68EC14 }

{ @routine $68EEA0 TPSWeapon08ECutter_Draw }
procedure TPSWeapon08ECutter.Draw(ClipRect: TRect);
var
  X, Y: Integer;
  PX, PY, Sine, Cosine, Angle, Scale: Single;
  Particle: PECutterParticle;
  Count: Integer;
begin
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
      if Particle.Kind >= 2 then
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Trunc(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Trunc(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TECutterParticle));
      Dec(Count);
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Count > 0 do
    begin
      if Particle.Kind >= 2 then
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Trunc(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Trunc(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TECutterParticle));
      Dec(Count);
    end;
  end;
end;
{ @end $68EEA0 }

{ @routine $68F120 LoadECutterPalettes }
procedure LoadECutterPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.7.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(ECutterPalettes, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 7 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
          ECutterPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $68F120 }

end.
