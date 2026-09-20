unit GI_PSWeapon07Blaster;
// Native blaster particles, curved projectile paths and independent cyclic random pool.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PBlasterParticle = ^TBlasterParticle;
  TBlasterParticle = record // @size $28
    Prev: PBlasterParticle; // @offset $00
    Next: PBlasterParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    Velocity: TPointF; // @offset $14
    State: Byte; // @offset $1C
    Unknown1E: Word; // @offset $1E  Initialized to 30000; unused by the native update.
    BaseX: Single; // @offset $24
  end;
  TBlasterPalette = array[0..1] of Word;
  TBlasterPalettes = array of TBlasterPalette;

var
  BlasterPalettes: array of TBlasterPalette; // @addr $88ACB4

type
  TPSWeapon07Blaster = class(TPSWeaponGI) // @size $150
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PBlasterParticle; // @offset $134
    LastParticle: PBlasterParticle; // @offset $138
    PrimaryColor: Word; // @offset $13C
    SecondaryColor: Word; // @offset $13E
    ProjectionBounds: TRect; // @offset $140

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $68D2B8
    destructor Destroy; override; // @addr $68D364
    procedure SetPosition(Position: TPoint); override; // @addr $68D3A0
    procedure SetTargetPoint(Point: TPoint); override; // @addr $68D3E4
    procedure UpdateProjectionBounds; // @addr $68D438
    procedure UpdateHitTestBounds; override; // @addr $68D77C
    function GetLocalBounds: TRect; override; // @addr $68D7E8
    function AddParticle: PBlasterParticle; // @addr $68D84C
    procedure ClearParticles; // @addr $68D8C4
    procedure Invalidate; override; // @addr $68D9E4 @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $68D918
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $68D9F0
    procedure Draw(ClipRect: TRect); override; // @addr $68E204
  end;

function NextBlasterRandom: Integer; // @addr $68D290
procedure LoadBlasterPalettes; // @addr $68E478

var
  BlasterRandomIndex: Integer = 0; // @addr $87BF3C

implementation

// @unit-initialization $877914
// @unit-finalization $68E760

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

var
  BlasterRandomValues: array[0..127] of Integer; // @addr $88ACBC

{ @routine $68D290 NextBlasterRandom }
function NextBlasterRandom: Integer;
begin
  BlasterRandomIndex := (BlasterRandomIndex + 1) and $7F;
  Result := BlasterRandomValues[BlasterRandomIndex];
end;
{ @end $68D290 }

{ @routine $68D2B8 TPSWeapon07Blaster_Create }
constructor TPSWeapon07Blaster.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 4;
  UpdateProjectionBounds;
  RemainingTicks := 60;
  LifetimeTicks := RemainingTicks;
  PrimaryColor := BlasterPalettes[APaletteIndex][0];
  SecondaryColor := BlasterPalettes[APaletteIndex][1];
end;
{ @end $68D2B8 }

{ @routine $68D364 TPSWeapon07Blaster_Destroy }
destructor TPSWeapon07Blaster.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $68D364 }

{ @routine $68D3A0 TPSWeapon07Blaster_SetPosition }
procedure TPSWeapon07Blaster.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $68D3A0 }

{ @routine $68D3E4 TPSWeapon07Blaster_SetTargetPoint }
procedure TPSWeapon07Blaster.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $68D3E4 }

{ @routine $68D438 TPSWeapon07Blaster_UpdateProjectionBounds }
procedure TPSWeapon07Blaster.UpdateProjectionBounds;
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
{ @end $68D438 }

{ @routine $68D77C TPSWeapon07Blaster_UpdateHitTestBounds }
procedure TPSWeapon07Blaster.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X - 32;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y - 32;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X + 32;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y + 32;
end;
{ @end $68D77C }

{ @routine $68D7E8 TPSWeapon07Blaster_GetLocalBounds }
function TPSWeapon07Blaster.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $68D7E8 }

{ @routine $68D84C TPSWeapon07Blaster_AddParticle }
function TPSWeapon07Blaster.AddParticle: PBlasterParticle;
var
  Particle: PBlasterParticle;
begin
  Particle := AllocEC(SizeOf(TBlasterParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $68D84C }

{ @routine $68D8C4 TPSWeapon07Blaster_ClearParticles }
procedure TPSWeapon07Blaster.ClearParticles;
var
  Particle, Current: PBlasterParticle;
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
{ @end $68D8C4 }

{ @routine $68D918 TPSWeapon07Blaster_InvalidateRect }
procedure TPSWeapon07Blaster.InvalidateRect(Rect: TRect);
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
{ @end $68D918 }

{ @routine $68D9E4 TPSWeapon07Blaster_Invalidate }
procedure TPSWeapon07Blaster.Invalidate;
begin
end;
{ @end $68D9E4 }

{ @routine $68D9F0 TPSWeapon07Blaster_Advance }
procedure TPSWeapon07Blaster.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Y: Single;
  I, J: Integer;
  Distance: Single;
  Current, Spark, Particle: PBlasterParticle;
  Speed: Single;
begin
  if (FirstParticle = nil) and (RemainingTicks > 20) then
  begin
    Y := 0;
    Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
    Speed := 4.1;
    if Distance / Speed > 38.0 then Speed := Distance / 38.0;
    while (Y < Distance) and (Y < 2.0) do
    begin
      for J := 0 to 1 do
      begin
        Particle := AddParticle;
        I := Random(HalfWidth * 2 + 1) - HalfWidth;
        Particle.BaseX := (Y * 2.0 - 1.0) * (J + 1);
        Particle.Position.X := I + J;
        Particle.Position.Y := Y;
        Particle.Color := SecondaryColor;
        if Y < 32.0 then Particle.Alpha := Trunc(255.0 * Y) shr 5;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := Speed;
        Particle.State := 1;
        Particle.Unknown1E := 30000;
        Particle := AddParticle;
        Particle.BaseX := (Y * 2.0 - 1.0) * (J + 1);
        Particle.Position.X := I + J;
        Particle.Position.Y := Y + 1.0;
        Particle.Color := SecondaryColor;
        if Y < 32.0 then Particle.Alpha := Trunc(255.0 * Y) shr 5;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := Speed;
        Particle.State := 1;
        Particle.Unknown1E := 30000;
        Particle := AddParticle;
        Particle.BaseX := (Y * 2.0 - 1.0) * (J + 1);
        Particle.Position.X := I + J;
        Particle.Position.Y := Y + 2.0;
        Particle.Color := SecondaryColor;
        if Y < 32.0 then Particle.Alpha := Trunc(255.0 * Y) shr 5;
        Particle.Velocity.X := 0;
        Particle.Velocity.Y := Speed;
        Particle.State := 1;
        Particle.Unknown1E := 30000;
      end;
      Y := Y + 1.0;
    end;
  end
  else
  begin
    Distance := Trunc(Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y)));
    UpdateHitTestBounds;
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      case Current.State of
        1:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            if Current.BaseX >= 0 then
              Current.Position.X := Sin((Current.Position.Y + Current.Velocity.Y) * Pi / Distance) * 15.0 + Current.BaseX
            else
              Current.Position.X := Sin((Current.Position.Y + Current.Velocity.Y) * Pi / Distance) * -15.0 + Current.BaseX;
            if Current.Position.Y > Distance then
            begin
              Current.State := 255;
              RemainingTicks := 20;
            end
            else
            begin
              if Current.Position.Y < 32.0 then Current.Alpha := Trunc(Current.Position.Y * 255.0) shr 5
              else Current.Alpha := 255;
              if NextBlasterRandom < 17 then
              begin
                Spark := AddParticle;
                Spark.Position.X := Current.Position.X + NextBlasterRandom / 100.0 - 0.5;
                Spark.Position.Y := Current.Position.Y - 1.0;
                Spark.Color := PrimaryColor;
                Spark.Velocity.X := (Spark.Position.X - Current.Position.X) * 0.5;
                Spark.Velocity.Y := Current.Velocity.Y * 0.75;
                Spark.State := 2;
                Spark.Unknown1E := 30000;
                I := Current.Alpha - Random(128);
                if I > 255 then I := 255
                else if I < 0 then I := 0;
                Spark.Alpha := I;
              end;
            end;
          end;
        2: Inc(Current.State);
        3:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            if Current.Alpha > 8 then Dec(Current.Alpha, 9);
            if Current.Alpha < 15 then
            begin
              Current.State := 255;
              Current := nil;
            end;
            if (Current <> nil) and (NextBlasterRandom < 14) then
            begin
              Spark := AddParticle;
              Spark.Position.X := Current.Position.X + NextBlasterRandom / 400.0 - 0.125;
              Spark.Position.Y := Current.Position.Y - 1.0;
              Spark.Color := Current.Color;
              Spark.Velocity.X := Spark.Position.X - Current.Position.X + Current.Velocity.X;
              Spark.Velocity.Y := 0.7 * Current.Velocity.Y;
              Spark.State := 2;
              Spark.Unknown1E := 30000;
              I := Current.Alpha + Random(60) - 32;
              if I > 255 then I := 255
              else if I < 0 then I := 0;
              Spark.Alpha := I;
            end;
          end;
        4:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            Current.Velocity.X := 0.95 * Current.Velocity.X;
            if Current.Alpha < 246 then Inc(Current.Alpha, 10);
            if Current.Alpha > 245 then Current.State := 5;
          end;
        5:
          begin
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Velocity.Y := 0.95 * Current.Velocity.Y;
            Current.Velocity.X := 0.95 * Current.Velocity.X;
            if Current.Alpha > 25 then Dec(Current.Alpha, 26);
            if Current.Alpha < 26 then Current.State := 255;
          end;
      end;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $68D9F0 }

{ @routine $68E204 TPSWeapon07Blaster_Draw }
procedure TPSWeapon07Blaster.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Double;
  Particle: PBlasterParticle;
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
      if Particle.State <> 255 then
      begin
        PX := Particle.Position.X;
        PY := -Particle.Position.Y;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
        QueueDrawPoint(X - 1, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      if Particle.State <> 255 then
      begin
        PX := Particle.Position.X;
        PY := -Particle.Position.Y;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
        Dec(X);
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $68E204 }

{ @routine $68E478 LoadBlasterPalettes }
procedure LoadBlasterPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  for Index := Low(BlasterRandomValues) to High(BlasterRandomValues) do BlasterRandomValues[Index] := Random(100);
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.6.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(BlasterPalettes, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 1 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
          BlasterPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $68E478 }

end.
