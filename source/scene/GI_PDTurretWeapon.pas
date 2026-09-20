unit GI_PDTurretWeapon;
// Native TPSPDWeaponGI and methods: $69A768..$698ADC.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PPDWeaponParticle = ^TPDWeaponParticle;
  TPDWeaponParticle = record // @size $1C
    Kind: Integer; // @offset $00
    Position: TPointF; // @offset $04
    Color: Word; // @offset $0C
    Alpha: Byte; // @offset $0E
    Velocity: TPointF; // @offset $10
    Unknown1A: Byte; // @offset $1A  Initialized to zero; unused by this renderer.
  end;

  TPSPDWeaponGI = class(TPSWeaponGI) // @size $144
  public
    Particles: PPDWeaponParticle; // @offset $130
    ParticleCount: Integer; // @offset $134
    ParticleCapacity: Integer; // @offset $138
    OriginalLength: Single; // @offset $13C
    ParticleColor: Word; // @offset $140

    constructor Create(Owner: TObjectGI); // @addr $69A898
    destructor Destroy; override; // @addr $69A92C
    procedure Invalidate; override; // @addr $69A968 @note "Native empty override."
    procedure SetPosition(Position: TPoint); override; // @addr $69A974
    procedure SetTargetPoint(Point: TPoint); override; // @addr $69A9B0
    procedure UpdateHitTestBounds; override; // @addr $69A9FC
    procedure SetActive(Enabled: Boolean); override; // @addr $69AA30
    procedure ClearParticles; // @addr $69AA4C
    procedure GrowParticles; // @addr $69AA94
    function AddParticle: PPDWeaponParticle; // @addr $69AACC
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $69AB24
    procedure Draw(ClipRect: TRect); override; // @addr $69ADBC
  end;

implementation

uses Math, EC_Mem, GR_Main, GR_DX;

{ @routine $69A898 TPSPDWeaponGI_Create }
constructor TPSPDWeaponGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  RemainingTicks := 25;
  LifetimeTicks := 25;
  ParticleColor := CurrentPixelFormat.PackNormalizedRgb(1.0, 0.6, 0.6);
end;
{ @end $69A898 }

{ @routine $69A92C TPSPDWeaponGI_Destroy }
destructor TPSPDWeaponGI.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $69A92C }

{ @routine $69A968 TPSPDWeaponGI_Invalidate }
procedure TPSPDWeaponGI.Invalidate;
begin
end;
{ @end $69A968 }

{ @routine $69A974 TPSPDWeaponGI_SetPosition }
procedure TPSPDWeaponGI.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
    inherited SetPosition(Position);
end;
{ @end $69A974 }

{ @routine $69A9B0 TPSPDWeaponGI_SetTargetPoint }
procedure TPSPDWeaponGI.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
    TargetPoint := Point;
end;
{ @end $69A9B0 }

{ @routine $69A9FC TPSPDWeaponGI_UpdateHitTestBounds }
procedure TPSPDWeaponGI.UpdateHitTestBounds;
begin
  HitTestBounds.Left := 0;
  HitTestBounds.Top := 0;
  HitTestBounds.Right := GameScreenWidth;
  HitTestBounds.Bottom := GameScreenHeight;
end;
{ @end $69A9FC }

{ @routine $69AA30 TPSPDWeaponGI_SetActive }
procedure TPSPDWeaponGI.SetActive(Enabled: Boolean);
begin
  inherited SetActive(Enabled);
end;
{ @end $69AA30 }

{ @routine $69AA4C TPSPDWeaponGI_ClearParticles }
procedure TPSPDWeaponGI.ClearParticles;
begin
  if Particles <> nil then
  begin
    FreeEC(Particles);
    Particles := nil;
  end;
  ParticleCount := 0;
  ParticleCapacity := 0;
end;
{ @end $69AA4C }

{ @routine $69AA94 TPSPDWeaponGI_GrowParticles }
procedure TPSPDWeaponGI.GrowParticles;
begin
  Inc(ParticleCapacity, 100);
  Particles := ReAllocREC(Particles, ParticleCapacity * SizeOf(TPDWeaponParticle));
end;
{ @end $69AA94 }

{ @routine $69AACC TPSPDWeaponGI_AddParticle }
function TPSPDWeaponGI.AddParticle: PPDWeaponParticle;
begin
  if ParticleCount >= ParticleCapacity then GrowParticles;
  Result := AddPointerOffset(Particles, ParticleCount * SizeOf(TPDWeaponParticle));
  Inc(ParticleCount);
end;
{ @end $69AACC }

{ @routine $69AB24 TPSPDWeaponGI_Advance }
procedure TPSPDWeaponGI.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Particle: PPDWeaponParticle;
  I, J, K: Integer;
  Speed: Single;
begin
  if RemainingTicks = 25 then
  begin
    OriginalLength := Sqrt(Sqr(LocalPosition.X - TargetPoint.X) + Sqr(LocalPosition.Y - TargetPoint.Y));
    Speed := (OriginalLength + 288.0) / 25.0;
    for I := 0 to 7 do
      for J := 0 to 1 do
        for K := 0 to 5 do
        begin
          Particle := AddParticle;
          Particle.Kind := 2;
          Particle.Position.X := J * 6 - 3;
          Particle.Position.Y := I * 36 - 288 + K;
          Particle.Color := ParticleColor;
          Particle.Alpha := 0;
          Particle.Velocity.X := 0;
          Particle.Velocity.Y := Speed;
          Particle.Unknown1A := 0;
          Particle := AddParticle;
          Particle.Kind := 2;
          Particle.Position.X := J * 8 - 4;
          Particle.Position.Y := I * 36 - 288 + K;
          Particle.Color := ParticleColor;
          Particle.Alpha := 0;
          Particle.Velocity.X := 0;
          Particle.Velocity.Y := Speed;
          Particle.Unknown1A := 0;
        end;
  end;
  K := 0;
  Particle := Particles;
  I := ParticleCount;
  UpdateHitTestBounds;
  while I > 0 do
  begin
    if Particle.Kind = 2 then
    begin
      Particle.Position.X := Particle.Position.X + Particle.Velocity.X;
      Particle.Position.Y := Particle.Position.Y + Particle.Velocity.Y;
      if Particle.Position.Y >= OriginalLength then Particle.Kind := 0;
      if Particle.Position.Y > 0 then
      begin
        if Particle.Alpha < 219 then Inc(Particle.Alpha, 36)
        else Particle.Alpha := 255;
      end;
    end;
    Inc(K);
    Particle := AddPointerOffset(Particles, K * SizeOf(TPDWeaponParticle));
    Dec(I);
  end;
  if RemainingTicks > 0 then Dec(RemainingTicks);
end;
{ @end $69AB24 }

{ @routine $69ADBC TPSPDWeaponGI_Draw }
procedure TPSPDWeaponGI.Draw(ClipRect: TRect);
var
  X, Y: Integer;
  PX, PY, Sine, Cosine, Angle, Scale: Single;
  Particle: PPDWeaponParticle;
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
      Particle := AddPointerOffset(Particle, SizeOf(TPDWeaponParticle));
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
      Particle := AddPointerOffset(Particle, SizeOf(TPDWeaponParticle));
      Dec(Count);
    end;
  end;
end;
{ @end $69ADBC }

end.
