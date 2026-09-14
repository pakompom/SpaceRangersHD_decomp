unit GI_PSWeapon01Laser;
// Native laser particle beam, configurable width, duration and gradient palette.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PBeamLaserParticle = ^TBeamLaserParticle;
  TBeamLaserParticle = record // @size $20
    Prev: PBeamLaserParticle; // @offset $00
    Next: PBeamLaserParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    Velocity: TPointF; // @offset $14
    State: Byte; // @offset $1C
  end;
  TBeamLaserPalette = array[0..8] of Single;
  TBeamLaserPalettes = array of TBeamLaserPalette;

var
  BeamLaserPalettes: array of TBeamLaserPalette; // @addr $889A1C
  BeamLaserWidths: array of Single; // @addr $889A20
  BeamLaserDurations: array of Integer; // @addr $889A24

type
  TPSWeapon01Laser = class(TPSWeaponGI) // @size $164
  public
    HalfWidth: Single; // @offset $130
    FirstParticle: PBeamLaserParticle; // @offset $134
    LastParticle: PBeamLaserParticle; // @offset $138
    ProjectionBounds: TRect; // @offset $13C
    OriginalLength: Double; // @offset $150
    LengthScale: Double; // @offset $158
    PaletteIndex: Integer; // @offset $160

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $500150 @ida "TPSWeapon01Laser *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>, int APaletteIndex@<^0>);"
    destructor Destroy; override; // @addr $500200 @ida "void __usercall $name(TPSWeapon01Laser *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetPosition(Position: TPoint); override; // @addr $50023C @ida "void __usercall $name(TPSWeapon01Laser *Self@<eax>, TPoint *Position@<edx>);"
    procedure SetTargetPoint(Point: TPoint); override; // @addr $500280 @ida "void __usercall $name(TPSWeapon01Laser *Self@<eax>, TPoint *Point@<edx>);"
    procedure UpdateProjectionBounds; // @addr $5002D4
    procedure UpdateHitTestBounds; override; // @addr $50060C
    function GetLocalBounds: TRect; override; // @addr $50066C @ida "void __usercall $name(TPSWeapon01Laser *Self@<eax>, TRect *Result@<edx>);"
    function AddParticle: PBeamLaserParticle; // @addr $5006D0
    procedure RemoveParticle(Particle: PBeamLaserParticle); // @addr $500748
    procedure ClearParticles; // @addr $5007C8
    procedure InvalidateRect(Rect: TRect); override; // @addr $50081C @ida "void __usercall $name(TPSWeapon01Laser *Self@<eax>, TRect *Rect@<edx>);"
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $5008E8
    procedure Draw(ClipRect: TRect); override; // @addr $500FE4 @ida "void __usercall $name(TPSWeapon01Laser *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

procedure LoadBeamLaserPalettes; // @addr $5011FC

implementation

// @unit-initialization $875870
// @unit-finalization $50155C

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $500150 TPSWeapon01Laser_Create }
constructor TPSWeapon01Laser.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := BeamLaserWidths[APaletteIndex];
  LengthScale := 1;
  OriginalLength := 1;
  RemainingTicks := BeamLaserDurations[APaletteIndex];
  UpdateProjectionBounds;
  PaletteIndex := APaletteIndex;
end;
{ @end $500150 }

{ @routine $500200 TPSWeapon01Laser_Destroy }
destructor TPSWeapon01Laser.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $500200 }

{ @routine $50023C TPSWeapon01Laser_SetPosition }
procedure TPSWeapon01Laser.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $50023C }

{ @routine $500280 TPSWeapon01Laser_SetTargetPoint }
procedure TPSWeapon01Laser.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $500280 }

{ @routine $5002D4 TPSWeapon01Laser_UpdateProjectionBounds }
procedure TPSWeapon01Laser.UpdateProjectionBounds;
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
  A := (-HalfWidth - 12) * Cosine - -Distance * Sine;
  B := (HalfWidth + 12) * Cosine - -Distance * Sine;
  C := (-HalfWidth - 12) * Cosine;
  D := (HalfWidth + 12) * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := (-HalfWidth - 12) * Sine + -Distance * Cosine;
  B := (HalfWidth + 12) * Sine + -Distance * Cosine;
  C := (-HalfWidth - 12) * Sine;
  // Native uses Cosine for this final corner as well.
  D := (HalfWidth + 12) * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $5002D4 }

{ @routine $50060C TPSWeapon01Laser_UpdateHitTestBounds }
procedure TPSWeapon01Laser.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $50060C }

{ @routine $50066C TPSWeapon01Laser_GetLocalBounds }
function TPSWeapon01Laser.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $50066C }

{ @routine $5006D0 TPSWeapon01Laser_AddParticle }
function TPSWeapon01Laser.AddParticle: PBeamLaserParticle;
var
  Particle: PBeamLaserParticle;
begin
  Particle := AllocEC(SizeOf(TBeamLaserParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $5006D0 }

{ @routine $500748 TPSWeapon01Laser_RemoveParticle }
procedure TPSWeapon01Laser.RemoveParticle(Particle: PBeamLaserParticle);
begin
  if Particle.Prev <> nil then Particle.Prev.Next := Particle.Next;
  if Particle.Next <> nil then Particle.Next.Prev := Particle.Prev;
  if LastParticle = Particle then LastParticle := Particle.Prev;
  if FirstParticle = Particle then FirstParticle := Particle.Next;
  FreeEC(Particle);
end;
{ @end $500748 }

{ @routine $5007C8 TPSWeapon01Laser_ClearParticles }
procedure TPSWeapon01Laser.ClearParticles;
var
  Particle, Current: PBeamLaserParticle;
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
{ @end $5007C8 }

{ @routine $50081C TPSWeapon01Laser_InvalidateRect }
procedure TPSWeapon01Laser.InvalidateRect(Rect: TRect);
var
  Target: TPoint;
  Intersection: TRect;
begin
  MessageLoop.UpdateRects.AddScreenClippedRect(HitTestBounds, Parent.ToAbsolutePoint(LocalPosition), Parent.ToAbsolutePoint(TargetPoint));
  Target := Parent.ToAbsolutePoint(TargetPoint);
  Rect.Left := Target.X - 24;
  Rect.Right := Target.X + 24;
  Rect.Top := Target.Y - 24;
  Rect.Bottom := Target.Y + 24;
  if IntersectRects(Intersection, Rect, GameScreenRect) then
    MessageLoop.QueueUpdateRect(Intersection);
end;
{ @end $50081C }

{ @routine $5008E8 TPSWeapon01Laser_Advance }
procedure TPSWeapon01Laser.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  I, Power, FadeThreshold: Integer;
  Distance, Angle: Single;
  Particle, Current, Spark: PBeamLaserParticle;
  Alpha: Byte;
begin
  Invalidate;
  FadeThreshold := BeamLaserDurations[PaletteIndex] * 3 div 5;
  if (FirstParticle = nil) and (RemainingTicks >= FadeThreshold) then
  begin
    I := 0;
    Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
    OriginalLength := Distance;
    if OriginalLength = 0 then OriginalLength := 1;
    LengthScale := 1;
    Angle := 0;
    Alpha := 0;
    while I < Distance do
    begin
      Particle := AddParticle;
      Particle.Position := MakePointF(Sin(Pi * Angle / 180.0) * (HalfWidth - 0.0), I);
      Particle.Color := SampleGradientColor(BeamLaserPalettes[PaletteIndex], I / Distance * 2.0);
      Particle.Alpha := Alpha;
      Particle.Velocity := MakePointF(0, 10);
      Particle.State := 1;
      Particle := AddParticle;
      Particle.Position := MakePointF(Sin((Angle + 90.0) * Pi / 180.0) * (HalfWidth - 0.0), I);
      Particle.Color := SampleGradientColor(BeamLaserPalettes[PaletteIndex], I / Distance * 2.0);
      Particle.Alpha := Alpha;
      Particle.Velocity := MakePointF(0, 10);
      Particle.State := 1;
      Particle := AddParticle;
      Particle.Position := MakePointF(Sin((Angle + 180.0) * Pi / 180.0) * (HalfWidth - 0.0), I);
      Particle.Color := SampleGradientColor(BeamLaserPalettes[PaletteIndex], I / Distance * 2.0);
      Particle.Alpha := Alpha;
      Particle.Velocity := MakePointF(0, 10);
      Particle.State := 1;
      if Alpha + 4 < 255 then Inc(Alpha, 4)
      else Alpha := 255;
      Inc(I);
      Angle := Angle + 10.0;
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
        1:
          begin
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            if Current.Alpha + 4 < 255 then Inc(Current.Alpha, 4)
            else Current.Alpha := 255;
            if Current.Position.Y > Distance then
            begin
              for I := 1 to 1 do
              begin
                Spark := AddParticle;
                Spark.Position.X := Current.Position.X;
                Spark.Position.Y := Current.Position.Y;
                Spark.Color := Current.Color;
                Angle := Random(16) / 8.0 * Pi;
                Power := Random(50);
                Spark.Velocity.X := Sin(Angle) * (Power + 50) / 50.0;
                Spark.Velocity.Y := Cos(Angle) * (Power + 50) / 50.0;
                Spark.State := 2;
                Power := (Current.Alpha shr 1) - Random(100);
                if Power < 0 then Power := 0;
                Spark.Alpha := Power;
              end;
              Current.Position.Y := Current.Position.Y - Distance;
              Current.Alpha := 0;
            end;
            if RemainingTicks < FadeThreshold then RemoveParticle(Current);
          end;
        2:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            Current.Velocity.X := 0.95 * Current.Velocity.X;
            if Current.Alpha < 246 then Inc(Current.Alpha, 16);
            if Current.Alpha > 245 then Current.State := 3;
          end;
        3:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            Current.Velocity.X := 0.95 * Current.Velocity.X;
            if Current.Alpha > 25 then Dec(Current.Alpha, 26);
            if Current.Alpha < 26 then RemoveParticle(Current);
          end;
      end;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $5008E8 }

{ @routine $500FE4 TPSWeapon01Laser_Draw }
procedure TPSWeapon01Laser.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Single;
  Particle: PBeamLaserParticle;
  X, Y: Integer;
begin
  Y := -(TargetPoint.Y - LocalPosition.Y);
  if Y = 0 then Inc(Y);
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, Y);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Particle := FirstParticle;
  if HardwareRenderingEnabled then
  begin
    while Particle <> nil do
    begin
      PX := Particle.Position.X * LengthScale;
      PY := -Particle.Position.Y * LengthScale;
      X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
      Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
      QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      PX := Particle.Position.X * LengthScale;
      PY := -Particle.Position.Y * LengthScale;
      X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
      Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
      if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $500FE4 }

{ @routine $5011FC LoadBeamLaserPalettes }
procedure LoadBeamLaserPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, PartIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.0.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(BeamLaserPalettes, Count);
  SetLength(BeamLaserWidths, Count);
  SetLength(BeamLaserDurations, Count);
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
            BeamLaserPalettes[Index][3 * ColorIndex + PartIndex] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, PartIndex, ','));
        end;
      if PaletteBlock.CountParams('Width') > 0 then
        BeamLaserWidths[Index] := ExtractDecimalToSingleW(PaletteBlock.GetParam('Width'))
      else BeamLaserWidths[Index] := 2.0;
      if PaletteBlock.CountParams('Time') > 0 then
        BeamLaserDurations[Index] := ExtractDigitsToIntW(PaletteBlock.GetParam('Time'))
      else BeamLaserDurations[Index] := 40;
    end;
  end;
end;
{ @end $5011FC }

end.
