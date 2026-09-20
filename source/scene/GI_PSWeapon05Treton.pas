unit GI_PSWeapon05Treton;
// Native Treton particle control and configured two-color palettes.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PTretonParticle = ^TTretonParticle;
  TTretonParticle = record // @size $20
    Prev: PTretonParticle; // @offset $00
    Next: PTretonParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    MaximumAlpha: Byte; // @offset $13
    Velocity: TPointF; // @offset $14
    Countdown: Byte; // @offset $1C
    State: Byte; // @offset $1D
  end;
  TTretonPalette = array[0..1] of Word;
  TTretonPalettes = array of TTretonPalette;

var
  TretonPalettes: array of TTretonPalette; // @addr $88ACA4

type
  TPSWeapon05Treton = class(TPSWeaponGI) // @size $160
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PTretonParticle; // @offset $134
    LastParticle: PTretonParticle; // @offset $138
    PrimaryColor: Word; // @offset $13C
    SecondaryColor: Word; // @offset $13E
    ProjectionBounds: TRect; // @offset $140
    LengthScale: Double; // @offset $150
    OriginalLength: Double; // @offset $158

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $68AFE8
    destructor Destroy; override; // @addr $68B0AC
    procedure SetColors(FirstColor, SecondColor: Word); // @addr $68B0E8
    procedure SetPosition(Position: TPoint); override; // @addr $68B11C
    procedure SetTargetPoint(Point: TPoint); override; // @addr $68B160
    procedure UpdateProjectionBounds; // @addr $68B1B4
    procedure UpdateHitTestBounds; override; // @addr $68B500
    function GetLocalBounds: TRect; override; // @addr $68B560
    function AddParticle: PTretonParticle; // @addr $68B5C4
    procedure ClearParticles; // @addr $68B63C
    procedure Invalidate; override; // @addr $68B690 @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $68B69C
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $68B768
    procedure Draw(ClipRect: TRect); override; // @addr $68BCB0
  end;

procedure LoadTretonPalettes; // @addr $68BED0

implementation

// @unit-initialization $877904
// @unit-finalization $68C194

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $68AFE8 TPSWeapon05Treton_Create }
constructor TPSWeapon05Treton.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 3;
  RemainingTicks := 60;
  LifetimeTicks := 60;
  LengthScale := 1;
  OriginalLength := 1;
  UpdateProjectionBounds;
  SetColors(TretonPalettes[APaletteIndex][0], TretonPalettes[APaletteIndex][1]);
end;
{ @end $68AFE8 }

{ @routine $68B0AC TPSWeapon05Treton_Destroy }
destructor TPSWeapon05Treton.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $68B0AC }

{ @routine $68B0E8 TPSWeapon05Treton_SetColors }
procedure TPSWeapon05Treton.SetColors(FirstColor, SecondColor: Word);
begin
  PrimaryColor := FirstColor;
  SecondaryColor := SecondColor;
end;
{ @end $68B0E8 }

{ @routine $68B11C TPSWeapon05Treton_SetPosition }
procedure TPSWeapon05Treton.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $68B11C }

{ @routine $68B160 TPSWeapon05Treton_SetTargetPoint }
procedure TPSWeapon05Treton.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $68B160 }

{ @routine $68B1B4 TPSWeapon05Treton_UpdateProjectionBounds }
procedure TPSWeapon05Treton.UpdateProjectionBounds;
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
{ @end $68B1B4 }

{ @routine $68B500 TPSWeapon05Treton_UpdateHitTestBounds }
procedure TPSWeapon05Treton.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $68B500 }

{ @routine $68B560 TPSWeapon05Treton_GetLocalBounds }
function TPSWeapon05Treton.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $68B560 }

{ @routine $68B5C4 TPSWeapon05Treton_AddParticle }
function TPSWeapon05Treton.AddParticle: PTretonParticle;
var
  Particle: PTretonParticle;
begin
  Particle := AllocEC(SizeOf(TTretonParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $68B5C4 }

{ @routine $68B63C TPSWeapon05Treton_ClearParticles }
procedure TPSWeapon05Treton.ClearParticles;
var
  Particle, Current: PTretonParticle;
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
{ @end $68B63C }

{ @routine $68B690 TPSWeapon05Treton_Invalidate }
procedure TPSWeapon05Treton.Invalidate;
begin
end;
{ @end $68B690 }

{ @routine $68B69C TPSWeapon05Treton_InvalidateRect }
procedure TPSWeapon05Treton.InvalidateRect(Rect: TRect);
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
{ @end $68B69C }

{ @routine $68B768 TPSWeapon05Treton_Advance }
procedure TPSWeapon05Treton.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Y, I: Integer;
  Distance: Single;
  Particle, Current: PTretonParticle;
  DelayScale: Single;
begin
  if (FirstParticle = nil) and (RemainingTicks = 60) then
  begin
    Y := 0;
    Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
    OriginalLength := Distance;
    if OriginalLength = 0 then OriginalLength := 1;
    LengthScale := 1;
    if Distance > 300.0 then DelayScale := 20.0
    else DelayScale := 20.0 * Distance / 300.0;
    while Y < Distance do
    begin
      for I := -HalfWidth to HalfWidth do
      begin
        Particle := AddParticle;
        Particle.Position := MakePointF(I, Y + 2 - I);
        Particle.Color := PrimaryColor;
        Particle.MaximumAlpha := 255 - (212 * Abs(I)) div HalfWidth;
        if Y < 64 then Particle.Alpha := (Particle.MaximumAlpha * Trunc(Y)) shr 6
        else Particle.Alpha := Particle.MaximumAlpha;
        Particle.Velocity := MakePointF(0, -2);
        Particle.State := 0;
        Particle.Countdown := Trunc(Particle.Position.Y / Distance * DelayScale);
      end;
      for I := 0 to 7 do
      begin
        Particle := AddParticle;
        Particle.Position := MakePointF(0, Y + I);
        Particle.Color := SecondaryColor;
        Particle.MaximumAlpha := 255 - Trunc(Sin(I / 8.0 * Pi) * 192.0);
        if Y < 64 then Particle.Alpha := (Particle.MaximumAlpha * Trunc(Y)) shr 6
        else Particle.Alpha := Particle.MaximumAlpha;
        Particle.Velocity := MakePointF(0, -2);
        Particle.State := 0;
        Particle.Countdown := Trunc(Particle.Position.Y / Distance * DelayScale);
      end;
      Inc(Y, 12);
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
        0:
          if Current.Countdown = 0 then
          begin
            Current.Countdown := RemainingTicks + 21 - 60;
            if Current.Position.Y < 64.0 then Current.Alpha := (Current.MaximumAlpha * Trunc(Current.Position.Y)) shr 6
            else Current.Alpha := Current.MaximumAlpha;
            Current.State := 2;
          end
          else Dec(Current.Countdown);
        1:
          begin
            Current.Position.X := Current.Position.X + Current.Velocity.X;
            Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
            if Current.Position.Y > Distance then Current.Position.Y := Current.Position.Y - Distance;
            if Current.Position.Y < 0 then Current.Position.Y := Current.Position.Y + Distance;
            if Current.Position.Y < 64.0 then Current.Alpha := (Current.MaximumAlpha * Trunc(Current.Position.Y)) shr 6
            else Current.Alpha := Current.MaximumAlpha;
          end;
        2:
          if Current.Countdown = 0 then Current.State := 1
          else Dec(Current.Countdown);
      end;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $68B768 }

{ @routine $68BCB0 TPSWeapon05Treton_Draw }
procedure TPSWeapon05Treton.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Single;
  X, Y: Integer;
  Particle: PTretonParticle;
begin
  Y := -(TargetPoint.Y - LocalPosition.Y);
  if Y = 0 then Y := 1;
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, Y);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Particle := FirstParticle;
  if HardwareRenderingEnabled then
  begin
    while Particle <> nil do
    begin
      if Particle.State >= 1 then
      begin
        PX := Particle.Position.X;
        PY := -Particle.Position.Y * LengthScale;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      if Particle.State >= 1 then
      begin
        PX := Particle.Position.X;
        PY := -Particle.Position.Y * LengthScale;
        X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
        Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
        if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
          ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      end;
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $68BCB0 }

{ @routine $68BED0 LoadTretonPalettes }
procedure LoadTretonPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.4.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(TretonPalettes, Count);
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
          TretonPalettes[Index][ColorIndex] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
    end;
  end;
end;
{ @end $68BED0 }

end.
