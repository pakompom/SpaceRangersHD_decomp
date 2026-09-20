unit GI_PSWeapon03Lezka;
// Native Lezka beam and its two configured gradient palettes.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PLezkaParticle = ^TLezkaParticle;
  TLezkaParticle = record // @size $24
    Prev: PLezkaParticle; // @offset $00
    Next: PLezkaParticle; // @offset $04
    Position: TPointF; // @offset $08
    Color: Word; // @offset $10
    Alpha: Byte; // @offset $12
    MaximumAlpha: Byte; // @offset $13
    AlphaStep: Integer; // @offset $14
    Velocity: TPointF; // @offset $18
    State: Byte; // @offset $20
  end;
  TLezkaPalette = array[0..8] of Single;
  TLezkaPalettes = array of TLezkaPalette;

var
  LezkaPrimaryPalettes: array of TLezkaPalette; // @addr $88AC98
  LezkaSecondaryPalettes: array of TLezkaPalette; // @addr $88AC9C

type
  TPSWeapon03Lezka = class(TPSWeaponGI) // @size $164
  public
    HalfWidth: Integer; // @offset $130
    FirstParticle: PLezkaParticle; // @offset $134
    LastParticle: PLezkaParticle; // @offset $138
    ProjectionBounds: TRect; // @offset $13C
    LengthScale: Double; // @offset $150
    OriginalLength: Double; // @offset $158
    PaletteIndex: Integer; // @offset $160

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $689B54
    destructor Destroy; override; // @addr $689C08
    procedure SetPosition(Position: TPoint); override; // @addr $689C44
    procedure SetTargetPoint(Point: TPoint); override; // @addr $689C88
    procedure SetActive(Enabled: Boolean); override; // @addr $689CDC
    procedure UpdateProjectionBounds; // @addr $689D04
    procedure UpdateHitTestBounds; override; // @addr $68A050
    function GetLocalBounds: TRect; override; // @addr $68A0B0
    function AddParticle: PLezkaParticle; // @addr $68A114
    procedure ClearParticles; // @addr $68A18C
    procedure Invalidate; override; // @addr $68A2AC @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $68A1E0
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $68A2B8
    procedure Draw(ClipRect: TRect); override; // @addr $68A840
  end;

procedure LoadLezkaPalettes; // @addr $68AAAC

implementation

// @unit-initialization $8778FC
// @unit-finalization $68AE38

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $689B54 TPSWeapon03Lezka_Create }
constructor TPSWeapon03Lezka.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := 3;
  RemainingTicks := 38;
  LifetimeTicks := RemainingTicks;
  LengthScale := 1;
  OriginalLength := 1;
  UpdateProjectionBounds;
  PaletteIndex := APaletteIndex;
end;
{ @end $689B54 }

{ @routine $689C08 TPSWeapon03Lezka_Destroy }
destructor TPSWeapon03Lezka.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $689C08 }

{ @routine $689C44 TPSWeapon03Lezka_SetPosition }
procedure TPSWeapon03Lezka.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $689C44 }

{ @routine $689C88 TPSWeapon03Lezka_SetTargetPoint }
procedure TPSWeapon03Lezka.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $689C88 }

{ @routine $689CDC TPSWeapon03Lezka_SetActive }
procedure TPSWeapon03Lezka.SetActive(Enabled: Boolean);
begin
  if Active <> Enabled then inherited SetActive(Enabled);
end;
{ @end $689CDC }

{ @routine $689D04 TPSWeapon03Lezka_UpdateProjectionBounds }
procedure TPSWeapon03Lezka.UpdateProjectionBounds;
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
{ @end $689D04 }

{ @routine $68A050 TPSWeapon03Lezka_UpdateHitTestBounds }
procedure TPSWeapon03Lezka.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $68A050 }

{ @routine $68A0B0 TPSWeapon03Lezka_GetLocalBounds }
function TPSWeapon03Lezka.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $68A0B0 }

{ @routine $68A114 TPSWeapon03Lezka_AddParticle }
function TPSWeapon03Lezka.AddParticle: PLezkaParticle;
var
  Particle: PLezkaParticle;
begin
  Particle := AllocEC(SizeOf(TLezkaParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $68A114 }

{ @routine $68A18C TPSWeapon03Lezka_ClearParticles }
procedure TPSWeapon03Lezka.ClearParticles;
var
  Particle, Current: PLezkaParticle;
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
{ @end $68A18C }

{ @routine $68A1E0 TPSWeapon03Lezka_InvalidateRect }
procedure TPSWeapon03Lezka.InvalidateRect(Rect: TRect);
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
{ @end $68A1E0 }

{ @routine $68A2AC TPSWeapon03Lezka_Invalidate }
procedure TPSWeapon03Lezka.Invalidate;
begin
end;
{ @end $68A2AC }

{ @routine $68A2B8 TPSWeapon03Lezka_Advance }
procedure TPSWeapon03Lezka.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Y: Integer;
  Distance, Phase: Single;
  Particle, Current: PLezkaParticle;
  UnusedAlpha: Byte;
begin
  if (FirstParticle = nil) and (RemainingTicks >= 2) then
  begin
    Y := 0;
    Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
    OriginalLength := Distance;
    if OriginalLength = 0 then OriginalLength := 1;
    LengthScale := 1;
    UnusedAlpha := 0;
    while Y < Distance do
    begin
      Phase := Y / Distance;
      Particle := AddParticle;
      Particle.Position := MakePointF(Random(HalfWidth * 2) - HalfWidth, Y);
      case Random(3) of
        0: Particle.Color := SampleGradientColor(LezkaPrimaryPalettes[PaletteIndex], Phase * 8.0);
        1: Particle.Color := SampleGradientColor(LezkaSecondaryPalettes[PaletteIndex], Phase * 8.0);
        2: Particle.Color := SampleGradientColor(LezkaPrimaryPalettes[PaletteIndex], Phase * 8.0);
      end;
      Particle.MaximumAlpha := Random(250);
      if Y < 64 then Particle.Alpha := Trunc(Particle.MaximumAlpha * Y) shr 6
      else Particle.Alpha := Particle.MaximumAlpha;
      Particle.AlphaStep := Random(10) + 10;
      Particle.Velocity := MakePointF(0, 3);
      Particle.State := 1 + Random(2);
      // Retained native accumulator, although it does not feed a particle field.
      if UnusedAlpha + 4 < 255 then Inc(UnusedAlpha, 4)
      else UnusedAlpha := 255;
      Inc(Y);
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
          if Distance + 16.0 < Current.Position.Y then
        begin
            Current.Position.Y := Current.Position.Y - Distance;
            Current.Position.X := Random(HalfWidth * 2) - HalfWidth;
            Current.Velocity := MakePointF(0, 3);
        end;
        if Current.MaximumAlpha > 254 - Current.AlphaStep then Current.MaximumAlpha := 255
        else Inc(Current.MaximumAlpha, Current.AlphaStep);
        if Current.Position.Y < 64.0 then Current.Alpha := Trunc(Current.MaximumAlpha * Current.Position.Y) shr 6
        else Current.Alpha := Current.MaximumAlpha;
        if Current.MaximumAlpha = 255 then Current.State := 2;
        end;
        2:
        begin
          Current.Position.X := Current.Position.X + Current.Velocity.X;
          Current.Position.Y := Current.Position.Y + Current.Velocity.Y;
          if Distance + 16.0 < Current.Position.Y then
        begin
            Current.Position.Y := Current.Position.Y - Distance;
            Current.Position.X := Random(HalfWidth * 2) - HalfWidth;
            Current.Velocity := MakePointF(0, 3);
        end;
        if Current.MaximumAlpha < Current.AlphaStep then Current.MaximumAlpha := 0
        else Dec(Current.MaximumAlpha, Current.AlphaStep);
        if Current.Position.Y < 64.0 then Current.Alpha := Trunc(Current.MaximumAlpha * Current.Position.Y) shr 6
        else Current.Alpha := Current.MaximumAlpha;
        if Current.MaximumAlpha = 0 then Current.State := 1;
        end;
      end;
    end;
  end;
  Dec(RemainingTicks);
end;
{ @end $68A2B8 }

{ @routine $68A840 TPSWeapon03Lezka_Draw }
procedure TPSWeapon03Lezka.Draw(ClipRect: TRect);
var
  Angle, Sine, Cosine, PX, PY: Single;
  X, Y: Integer;
  Particle: PLezkaParticle;
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
      PX := Particle.Position.X;
      PY := -Particle.Position.Y * LengthScale;
      X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
      Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
      QueueDrawPoint(X, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      QueueDrawPoint(X - 1, Y, Color565ToArgb(Particle.Color), Particle.Alpha);
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    while Particle <> nil do
    begin
      PX := Particle.Position.X;
      PY := -Particle.Position.Y * LengthScale;
      X := Round(PX * Cosine - PY * Sine + AbsolutePosition.X);
      Y := Round(PX * Sine + PY * Cosine + AbsolutePosition.Y);
      if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      Dec(X);
      if (X >= ClipRect.Left) and (X < ClipRect.Right) and (Y >= ClipRect.Top) and (Y < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(X, Y, Particle.Color, Particle.Alpha);
      Particle := Particle.Next;
    end;
  end;
end;
{ @end $68A840 }

{ @routine $68AAAC LoadLezkaPalettes }
procedure LoadLezkaPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, PartIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.2.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(LezkaPrimaryPalettes, Count);
  SetLength(LezkaSecondaryPalettes, Count);
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
            LezkaPrimaryPalettes[Index][3 * ColorIndex + PartIndex] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, PartIndex, ','));
        end;
      for ColorIndex := 0 to 2 do
        if PaletteBlock.CountParams('Color' + IntToStr(ColorIndex + 3)) > 0 then
        begin
          Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex + 3));
          for PartIndex := 0 to 2 do
            LezkaSecondaryPalettes[Index][3 * ColorIndex + PartIndex] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, PartIndex, ','));
        end;
    end;
  end;
end;
{ @end $68AAAC }

end.
