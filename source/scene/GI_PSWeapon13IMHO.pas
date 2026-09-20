unit GI_PSWeapon13IMHO;
// Native TPSWeapon13IMHO and methods; includes its configuration palette loader.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PIMHOParticle = ^TIMHOParticle;
  TIMHOParticle = record // @size $1C
    Kind: Integer; // @offset $00
    Position: TPointF; // @offset $04
    Color: Word; // @offset $0C
    Alpha: Byte; // @offset $0E
    Velocity: TPointF; // @offset $10
    Unknown1A: Byte; // @offset $1A  Initialized to zero; unused by this renderer.
  end;

  TIMHOPalette = array[0..7] of Word;
  TIMHOPalettes = array of TIMHOPalette;

var
  IMHOPalettes: array of TIMHOPalette; // @addr $88AEF0

type
  TPSWeapon13IMHO = class(TPSWeaponGI) // @size $150
  public
    Particles: PIMHOParticle; // @offset $130
    ParticleCount: Integer; // @offset $134
    ParticleCapacity: Integer; // @offset $138
    OriginalLength: Single; // @offset $13C
    Colors: TIMHOPalette; // @offset $140

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $6950A8
    destructor Destroy; override; // @addr $6951DC
    procedure Invalidate; override; // @addr $695218 @note "Native empty override."
    procedure SetPosition(Position: TPoint); override; // @addr $695224
    procedure SetTargetPoint(Point: TPoint); override; // @addr $695260
    procedure UpdateHitTestBounds; override; // @addr $6952AC
    procedure ClearParticles; // @addr $6952E0
    procedure GrowParticles; // @addr $695328
    function AddParticle: PIMHOParticle; // @addr $695360
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $6953B8
    procedure Draw(ClipRect: TRect); override; // @addr $6956D8
  end;

procedure LoadIMHOPalettes; // @addr $69597C

implementation

// @unit-initialization $877944
// @unit-finalization $695C40

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $6950A8 TPSWeapon13IMHO_Create }
constructor TPSWeapon13IMHO.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  RemainingTicks := 55;
  LifetimeTicks := 55;
  Colors[0] := IMHOPalettes[APaletteIndex][0];
  Colors[1] := IMHOPalettes[APaletteIndex][1];
  Colors[2] := IMHOPalettes[APaletteIndex][2];
  Colors[3] := IMHOPalettes[APaletteIndex][3];
  Colors[4] := IMHOPalettes[APaletteIndex][4];
  Colors[5] := IMHOPalettes[APaletteIndex][5];
  Colors[6] := IMHOPalettes[APaletteIndex][6];
  Colors[7] := IMHOPalettes[APaletteIndex][7];
end;
{ @end $6950A8 }

{ @routine $6951DC TPSWeapon13IMHO_Destroy }
destructor TPSWeapon13IMHO.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $6951DC }

{ @routine $695218 TPSWeapon13IMHO_Invalidate }
procedure TPSWeapon13IMHO.Invalidate;
begin
end;
{ @end $695218 }

{ @routine $695224 TPSWeapon13IMHO_SetPosition }
procedure TPSWeapon13IMHO.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
    inherited SetPosition(Position);
end;
{ @end $695224 }

{ @routine $695260 TPSWeapon13IMHO_SetTargetPoint }
procedure TPSWeapon13IMHO.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
    TargetPoint := Point;
end;
{ @end $695260 }

{ @routine $6952AC TPSWeapon13IMHO_UpdateHitTestBounds }
procedure TPSWeapon13IMHO.UpdateHitTestBounds;
begin
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  HitTestBounds.Right := GameScreenWidth;
  HitTestBounds.Bottom := GameScreenHeight;
end;
{ @end $6952AC }

{ @routine $6952E0 TPSWeapon13IMHO_ClearParticles }
procedure TPSWeapon13IMHO.ClearParticles;
begin
  if Particles <> nil then
  begin
    FreeEC(Particles);
    Particles := nil;
  end;
  ParticleCount := 0;
  ParticleCapacity := 0;
end;
{ @end $6952E0 }

{ @routine $695328 TPSWeapon13IMHO_GrowParticles }
procedure TPSWeapon13IMHO.GrowParticles;
begin
  Inc(ParticleCapacity, 100);
  Particles := ReAllocREC(Particles, ParticleCapacity * SizeOf(TIMHOParticle));
end;
{ @end $695328 }

{ @routine $695360 TPSWeapon13IMHO_AddParticle }
function TPSWeapon13IMHO.AddParticle: PIMHOParticle;
begin
  if ParticleCount >= ParticleCapacity then GrowParticles;
  Result := AddPointerOffset(Particles, ParticleCount * SizeOf(TIMHOParticle));
  Inc(ParticleCount);
end;
{ @end $695360 }

{ @routine $6953B8 TPSWeapon13IMHO_Advance }
procedure TPSWeapon13IMHO.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Particle: PIMHOParticle;
  J, I, K, L, M: Integer;
  Speed, PX, PY: Single;
begin
  if RemainingTicks = 55 then
  begin
    OriginalLength := Sqrt(Sqr(LocalPosition.X - TargetPoint.X) + Sqr(LocalPosition.Y - TargetPoint.Y));
    Speed := (OriginalLength + 40.0) / 55.0;
    for I := 0 to 1 do
      for J := 0 to 3 do
      begin
        K := -10;
        while K < 10 do
        begin
          PX := (J * 6 * 10 / OriginalLength + 4.0) * (K / 10.0);
          PY := Sqrt(256 - Sqr(K)) + J * 10 - 40.0 + I + Sin(K * 3 / 10.0 * Pi) * 1.5;
          for L := -1 to 1 do
            for M := -1 to 1 do
            begin
              Particle := AddParticle;
              Particle.Kind := 2;
              Particle.Position.X := L + PX;
              Particle.Position.Y := M + PY;
              Particle.Color := Colors[(Abs(K) * 8) div 11];
              Particle.Alpha := 0;
              Particle.Velocity.X := 6.0 * Particle.Position.X / 4.0 / 55.0;
              Particle.Velocity.Y := Speed;
              Particle.Unknown1A := 0;
            end;
          Inc(K, 10);
        end;
      end;
  end;
  UpdateHitTestBounds;
  I := 0;
  Particle := Particles;
  J := ParticleCount;
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
    Particle := AddPointerOffset(Particles, I * SizeOf(TIMHOParticle));
    Dec(J);
  end;
  if RemainingTicks > 0 then Dec(RemainingTicks);
end;
{ @end $6953B8 }

{ @routine $6956D8 TPSWeapon13IMHO_Draw }
procedure TPSWeapon13IMHO.Draw(ClipRect: TRect);
var
  X, Y: Integer;
  PX, PY, Sine, Cosine, Angle, Scale: Single;
  Particle: PIMHOParticle;
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
      if Particle.Kind >= 2 then
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * Scale;
        X := Trunc(PX * Cosine + PY * Sine) + AbsolutePosition.X;
        Y := Trunc(PX * Sine - PY * Cosine) + AbsolutePosition.Y;
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := AddPointerOffset(Particle, SizeOf(TIMHOParticle));
      Dec(Count);
    end;
    FlushDrawPoints(nil);
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
      Particle := AddPointerOffset(Particle, SizeOf(TIMHOParticle));
      Dec(Count);
    end;
  end;
end;
{ @end $6956D8 }

{ @routine $69597C LoadIMHOPalettes }
procedure LoadIMHOPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.12.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(IMHOPalettes, Count);
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
          IMHOPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $69597C }

end.
