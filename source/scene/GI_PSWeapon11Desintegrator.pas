unit GI_PSWeapon11Desintegrator;
// Native Desintegrator beam and screen-brightness-guided impact sparks.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PDesintegratorParticle = ^TDesintegratorParticle;
  TDesintegratorParticle = record // @size $24
    Prev: PDesintegratorParticle; // @offset $00
    Next: PDesintegratorParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    Velocity: TPointF; // @offset $14
    State: Byte; // @offset $1C
    RemainingTicks: Word; // @offset $1E
    BaseAlpha: Integer; // @offset $20
  end;
  TDesintegratorPalette = array[0..0] of Word;
  TDesintegratorPalettes = array of TDesintegratorPalette;

var
  DesintegratorPalettes: array of TDesintegratorPalette; // @addr $88AEDC

type
  TPSWeapon11Desintegrator = class(TPSWeaponGI) // @size $170
  public
    HalfWidth: Integer; // @offset $130
    Wavelength: Integer; // @offset $134
    PhaseMask: Integer; // @offset $138
    FirstParticle: PDesintegratorParticle; // @offset $13C
    LastParticle: PDesintegratorParticle; // @offset $140
    PendingSparkSteps: Integer; // @offset $144
    Color: Word; // @offset $148
    ProjectionBounds: TRect; // @offset $14A
    LengthScale: Double; // @offset $160
    OriginalLength: Double; // @offset $168

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $691EA4
    destructor Destroy; override; // @addr $691F8C
    procedure SetPosition(Position: TPoint); override; // @addr $691FC8
    procedure SetTargetPoint(Point: TPoint); override; // @addr $69200C
    procedure UpdateProjectionBounds; // @addr $692060
    procedure UpdateHitTestBounds; override; // @addr $6923A4
    function GetLocalBounds: TRect; override; // @addr $692410
    function AddParticle: PDesintegratorParticle; // @addr $692474
    procedure RemoveParticle(Particle: PDesintegratorParticle); // @addr $6924EC
    procedure AdvanceImpactSparks(ClipRect: TRect); // @addr $692B24
    procedure ClearParticles; // @addr $692570
    procedure Invalidate; override; // @addr $6925C4 @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $6925D0
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $69269C
    procedure Draw(ClipRect: TRect); override; // @addr $692EB8
  end;

procedure LoadDesintegratorPalettes; // @addr $6931A4

implementation

// @unit-initialization $877934
// @unit-finalization $693468

uses SysUtils, Classes, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $691EA4 TPSWeapon11Desintegrator_Create }
constructor TPSWeapon11Desintegrator.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 4;
  Wavelength := 32;
  LengthScale := 1;
  OriginalLength := 1;
  PhaseMask := Wavelength - 1;
  UpdateProjectionBounds;
  PendingSparkSteps := 0;
  Color := DesintegratorPalettes[APaletteIndex][0];
  RemainingTicks := 50;
  LifetimeTicks := RemainingTicks;
end;
{ @end $691EA4 }

{ @routine $691F8C TPSWeapon11Desintegrator_Destroy }
destructor TPSWeapon11Desintegrator.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $691F8C }

{ @routine $691FC8 TPSWeapon11Desintegrator_SetPosition }
procedure TPSWeapon11Desintegrator.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $691FC8 }

{ @routine $69200C TPSWeapon11Desintegrator_SetTargetPoint }
procedure TPSWeapon11Desintegrator.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $69200C }

{ @routine $692060 TPSWeapon11Desintegrator_UpdateProjectionBounds }
procedure TPSWeapon11Desintegrator.UpdateProjectionBounds;
var
  Angle, Sine, Cosine, Distance, A, B, C, D: Single;
  DY: Integer;
begin
  DY := -(TargetPoint.Y - LocalPosition.Y);
  if DY = 0 then Inc(DY);
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, DY);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
  A := (-HalfWidth * 2) * Cosine - -Distance * Sine;
  B := (HalfWidth * 2) * Cosine - -Distance * Sine;
  C := (-HalfWidth * 2) * Cosine;
  D := (HalfWidth * 2) * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := (-HalfWidth * 2) * Sine + -Distance * Cosine;
  B := (HalfWidth * 2) * Sine + -Distance * Cosine;
  C := (-HalfWidth * 2) * Sine;
  // Native uses Cosine for this final corner as well.
  D := (HalfWidth * 2) * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $692060 }

{ @routine $6923A4 TPSWeapon11Desintegrator_UpdateHitTestBounds }
procedure TPSWeapon11Desintegrator.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X - 32;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y - 32;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X + 32;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y + 32;
end;
{ @end $6923A4 }

{ @routine $692410 TPSWeapon11Desintegrator_GetLocalBounds }
function TPSWeapon11Desintegrator.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $692410 }

{ @routine $692474 TPSWeapon11Desintegrator_AddParticle }
function TPSWeapon11Desintegrator.AddParticle: PDesintegratorParticle;
var
  Particle: PDesintegratorParticle;
begin
  Particle := AllocEC(SizeOf(TDesintegratorParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $692474 }

{ @routine $6924EC TPSWeapon11Desintegrator_RemoveParticle }
procedure TPSWeapon11Desintegrator.RemoveParticle(Particle: PDesintegratorParticle);
begin
  if Particle <> nil then
  begin
  if Particle.Prev <> nil then Particle.Prev.Next := Particle.Next;
  if Particle.Next <> nil then Particle.Next.Prev := Particle.Prev;
  if LastParticle = Particle then LastParticle := Particle.Prev;
  if FirstParticle = Particle then FirstParticle := Particle.Next;
  FreeEC(Particle);
  end;
end;
{ @end $6924EC }

{ @routine $692570 TPSWeapon11Desintegrator_ClearParticles }
procedure TPSWeapon11Desintegrator.ClearParticles;
var
  Particle, Current: PDesintegratorParticle;
begin
  Particle := FirstParticle;
  while Particle <> nil do
  begin
    Current := Particle;
    Particle := Particle.Next;
    FreeEC(Current);
  end;
  FirstParticle := nil;
  LastParticle := nil;
end;
{ @end $692570 }

{ @routine $6925C4 TPSWeapon11Desintegrator_Invalidate }
procedure TPSWeapon11Desintegrator.Invalidate;
begin
end;
{ @end $6925C4 }

{ @routine $6925D0 TPSWeapon11Desintegrator_InvalidateRect }
procedure TPSWeapon11Desintegrator.InvalidateRect(Rect: TRect);
var
  Target: TPoint;
  Intersection: TRect;
begin
  MessageLoop.UpdateRects.AddScreenClippedRect(HitTestBounds, Parent.ToAbsolutePoint(LocalPosition), Parent.ToAbsolutePoint(TargetPoint));
  Target := Parent.ToAbsolutePoint(TargetPoint);
  Rect.Left := Target.X - 32;
  Rect.Right := Target.X + 32;
  Rect.Top := Target.Y - 32;
  Rect.Bottom := Target.Y + 32;
  if IntersectRects(Intersection, Rect, GameScreenRect) then
    MessageLoop.QueueUpdateRect(Intersection);
end;
{ @end $6925D0 }

{ @routine $69269C TPSWeapon11Desintegrator_Advance }
procedure TPSWeapon11Desintegrator.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Y, Distance, Angle: Single;
  Current, Spark, Particle: PDesintegratorParticle;
begin
  if (FirstParticle = nil) and (RemainingTicks > 18) then
  begin
    Y := 0;
    Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
    OriginalLength := Distance;
    // Native comparison is strictly negative, including its zero-length behavior.
    if OriginalLength < 0 then OriginalLength := 1;
    LengthScale := 1;
    while Y < Distance do
    begin
      Particle := AddParticle;
      Angle := Y / Wavelength * 2.0 * Pi;
      Particle.Position.X := 1;
      Particle.Position.Y := Y;
      Particle.Color := Color;
      Particle.BaseAlpha := Trunc(Sin(Angle) * 95.0 + 160.0);
      if Y < 64.0 then Particle.Alpha := Trunc(Particle.BaseAlpha * Y) shr 6
      else Particle.Alpha := Particle.BaseAlpha;
      Particle.Velocity.X := 0;
      Particle.Velocity.Y := 4;
      Particle.State := 1;
      Particle := AddParticle;
      Particle.Position.X := 0;
      Particle.Position.Y := Y;
      Particle.Color := Color;
      Particle.BaseAlpha := Trunc(Sin(Angle) * 95.0 + 160.0);
      if Y < 64.0 then Particle.Alpha := Trunc(Particle.BaseAlpha * Y) shr 6
      else Particle.Alpha := Particle.BaseAlpha;
      Particle.Velocity.X := 0;
      Particle.Velocity.Y := 4;
      Particle.State := 1;
      Y := Y + 1.0;
    end;
  end
  else
  begin
    Distance := OriginalLength;
    LengthScale := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)) / OriginalLength;
    UpdateHitTestBounds;
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      case Current.State of
      1: begin
        Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
        Current.Position.X := Current.Position.X + Current.Velocity.X;
        if Current.Position.Y > Distance then
        begin
          Spark := AddParticle;
          Spark.Position := MakePointF(0, 0);
          Spark.Color := Current.Color;
          Spark.Alpha := Current.BaseAlpha;
          Angle := Random(12) * Pi / 6.0;
          Spark.Velocity := MakePointF(Sin(Angle) * 1.0, Cos(Angle) * 1.0);
          Spark.State := 2;
          Spark.RemainingTicks := 18;
          Current.Position.Y := Current.Position.Y - Distance;
        end;
        if Current.Position.Y < 64.0 then Current.Alpha := Trunc(Current.BaseAlpha * Current.Position.Y) shr 6
        else Current.Alpha := Current.BaseAlpha;
        if RemainingTicks < 18 then RemoveParticle(Current);
      end;
      end;
    end;
  end;
  Inc(PendingSparkSteps);
  Dec(RemainingTicks);
end;
{ @end $69269C }

{ @routine $692B24 TPSWeapon11Desintegrator_AdvanceImpactSparks }
procedure TPSWeapon11Desintegrator.AdvanceImpactSparks(ClipRect: TRect);
var
  TargetX, TargetY, X, Y: Integer;
  Particle, Current: PDesintegratorParticle;
  DX, DY: Double;
  Minimum, Brightness: Integer;
  Uniform: Boolean;
begin
  TargetX := TargetPoint.X - LocalPosition.X + AbsolutePosition.X;
  TargetY := TargetPoint.Y - LocalPosition.Y + AbsolutePosition.Y;
  Particle := FirstParticle;
  while Particle <> nil do
  begin
    Current := Particle;
    Particle := Particle.Next;
    if Current.State = 2 then
    begin
      if Current.Alpha > 96 then Dec(Current.Alpha, 4);
      Current.Position.X := Current.Position.X + Current.Velocity.X;
      Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
      X := Round(TargetX + Current.Position.X);
      Y := Round(TargetY + Current.Position.Y);
      DX := 0;
      DY := 0;
      Minimum := 94;
      Uniform := True;
      if HardwareRenderingEnabled then
      begin
        DX := -0.25;
        DY := 0;
      end
      else
      begin
        Brightness := ScreenRenderBuffer.GetBrightness16(X - 1, Y);
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := -0.25;
          DY := 0;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X - 1, Y - 1);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := -0.25;
          DY := -0.25;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X - 1, Y - 1);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := 0;
          DY := -0.25;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X + 1, Y - 1);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := 0.25;
          DY := -0.25;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X + 1, Y);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := 0.25;
          DY := 0;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X + 1, Y + 1);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := 0.25;
          DY := 0.25;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X, Y + 1);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          Minimum := Brightness;
          DX := 0;
          DY := 0.25;
        end;
        Brightness := ScreenRenderBuffer.GetBrightness16(X - 1, Y + 1);
        if Brightness <> Minimum then Uniform := False;
        if Brightness < Minimum then
        begin
          DX := -0.25;
          DY := 0.25;
        end;
      end;
      if Uniform then
      begin
        DX := 0;
        DY := 0;
      end;
      Current.Velocity.X := Current.Velocity.X + DX;
      Current.Velocity.Y := Current.Velocity.Y + DY;
      Dec(Current.RemainingTicks);
      if Current.RemainingTicks = 0 then RemoveParticle(Current);
    end;
  end;
end;
{ @end $692B24 }

{ @routine $692EB8 TPSWeapon11Desintegrator_Draw }
procedure TPSWeapon11Desintegrator.Draw(ClipRect: TRect);
var
  PX, PY, Sine, Cosine, Angle: Single;
  TargetX, X, Y, TargetY: Integer;
  Particle: PDesintegratorParticle;
  I: Integer;
begin
  for I := 1 to PendingSparkSteps do
    AdvanceImpactSparks(Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight));
  PendingSparkSteps := 0;
  TargetX := TargetPoint.X - LocalPosition.X + AbsolutePosition.X;
  TargetY := TargetPoint.Y - LocalPosition.Y + AbsolutePosition.Y;
  PY := -(TargetPoint.Y - LocalPosition.Y);
  if PY = 0 then PY := 1;
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, PY);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Particle := FirstParticle;
  if HardwareRenderingEnabled then
  begin
    while Particle <> nil do
    begin
      if Particle.State = 2 then
      begin
        X := TargetX + Trunc(Particle.Position.X);
        Y := TargetY + Trunc(Particle.Position.Y);
      end
      else
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * LengthScale;
        X := AbsolutePosition.X + Trunc(PX * Cosine + PY * Sine);
        Y := AbsolutePosition.Y + Trunc(PX * Sine - PY * Cosine);
      end;
      QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      if Particle.State = 2 then
      begin
        X := TargetX + Trunc(Particle.Position.X);
        Y := TargetY + Trunc(Particle.Position.Y);
      end
      else
      begin
        PX := Particle.Position.X;
        PY := Particle.Position.Y * LengthScale;
        X := AbsolutePosition.X + Trunc(PX * Cosine + PY * Sine);
        Y := AbsolutePosition.Y + Trunc(PX * Sine - PY * Cosine);
      end;
      if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $692EB8 }

{ @routine $6931A4 LoadDesintegratorPalettes }
procedure LoadDesintegratorPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.10.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(DesintegratorPalettes, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 0 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
          DesintegratorPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $6931A4 }

end.
