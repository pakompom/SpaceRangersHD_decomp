unit GI_PSEyes;
// Unit bracket (inferred): .text 0x006989F4..0x0069A767; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native eye/lightning effect, particles and dormant line-list storage.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PEyesParticle = ^TEyesParticle;
  TEyesParticle = record // @size $2C
    Prev: PEyesParticle; // @offset $00
    Next: PEyesParticle; // @offset $04
    Origin: TPointF; // @offset $08
    Position: TPointF; // @offset $10
    Color: Word; // @offset $18
    Alpha: Byte; // @offset $1A
    Velocity: TPointF; // @offset $1C
    State: Byte; // @offset $24
    Countdown: Integer; // @offset $28
  end;
  PEyesLine = ^TEyesLine;
  TEyesLine = packed record // @size $1C
    Next: PEyesLine; // @offset $00
    First: TPoint; // @offset $08
    Last: TPoint; // @offset $10
    Color: Word; // @offset $18
    // Other native line-cache fields are unused by this renderer.
    Alpha: Byte; // @offset $1B
  end;

  TEyesPalette = array[0..1] of Word;

var
  EyesPalettes: array of TEyesPalette; // @addr $88AF14
  EyesWidths: array of Integer; // @addr $88AF18
  EyesSegmentLengths: array of Integer; // @addr $88AF1C
  EyesDispersions: array of Integer; // @addr $88AF20
  EyesStartingAlphas: array of Integer; // @addr $88AF24

type
  TPSEyesGI = class(TPSWeaponGI) // @size $168
  public
    HalfWidth: Integer; // @offset $130
    SegmentLength: Integer; // @offset $134
    Dispersion: Integer; // @offset $138
    StartingAlpha: Integer; // @offset $13C
    FirstParticle: PEyesParticle; // @offset $140
    LastParticle: PEyesParticle; // @offset $144
    FirstLine: PEyesLine; // @offset $148
    LastLine: PEyesLine; // @offset $14C
    ProjectionBounds: TRect; // @offset $150
    PrimaryColor: Word; // @offset $160
    SecondaryColor: Word; // @offset $162
    BeamTicks: Integer; // @offset $164

    constructor Create(Owner: TObjectGI; PaletteIndex: Integer); // @addr $698BD4
    destructor Destroy; override; // @addr $698CE4
    procedure SetPosition(Position: TPoint); override; // @addr $698D38
    procedure SetTargetPoint(Point: TPoint); override; // @addr $698D7C
    procedure UpdateProjectionBounds; // @addr $698DD0
    procedure UpdateHitTestBounds; override; // @addr $6990EC
    function GetLocalBounds: TRect; override; // @addr $69914C
    function AddParticle: PEyesParticle; // @addr $6991B0
    procedure ClearParticles; // @addr $699228
    procedure ClearLines; // @addr $69927C
    procedure EmitBurst(Point: TPoint; Radius: Integer); // @addr $6993C0
    procedure Invalidate; override; // @addr $6992D0 @note "Native empty override."
    procedure InvalidateRect(Rect: TRect); override; // @addr $6992DC
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $6995B8
    procedure Draw(ClipRect: TRect); override; // @addr $6997E8
  end;

procedure LoadEyesPalettes; // @addr $69A068

implementation

// @unit-initialization $877964
// @unit-finalization $69A6E8

uses SysUtils, Classes, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $698BD4 TPSEyesGI_Create }
constructor TPSEyesGI.Create(Owner: TObjectGI; PaletteIndex: Integer);
begin
  inherited Create(Owner);
  HalfWidth := EyesWidths[PaletteIndex];
  SegmentLength := EyesSegmentLengths[PaletteIndex];
  Dispersion := EyesDispersions[PaletteIndex];
  RemainingTicks := 60;
  LifetimeTicks := RemainingTicks;
  PrimaryColor := EyesPalettes[PaletteIndex][0];
  SecondaryColor := EyesPalettes[PaletteIndex][1];
  BeamTicks := 20;
  UpdateProjectionBounds;
  FirstLine := nil;
  LastLine := nil;
  StartingAlpha := EyesStartingAlphas[PaletteIndex];
end;
{ @end $698BD4 }

{ @routine $698CE4 TPSEyesGI_Destroy }
destructor TPSEyesGI.Destroy;
begin
  InvalidateRect(HitTestBounds);
  ClearLines;
  ClearParticles;
  inherited Destroy;
end;
{ @end $698CE4 }

{ @routine $698D38 TPSEyesGI_SetPosition }
procedure TPSEyesGI.SetPosition(Position: TPoint);
begin
  if (LocalPosition.X <> Position.X) or (LocalPosition.Y <> Position.Y) then
  begin
    inherited SetPosition(Position);
    UpdateProjectionBounds;
  end;
end;
{ @end $698D38 }

{ @routine $698D7C TPSEyesGI_SetTargetPoint }
procedure TPSEyesGI.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $698D7C }

{ @routine $698DD0 TPSEyesGI_UpdateProjectionBounds }
procedure TPSEyesGI.UpdateProjectionBounds;
var
  Distance, Angle, Sine, Cosine, A, B, C, D: Single;
  DY: Integer;
begin
  DY := -(TargetPoint.Y - LocalPosition.Y);
  if DY = 0 then Inc(DY);
  Angle := ArcTan2(TargetPoint.X - LocalPosition.X, DY);
  Sine := Sin(Angle);
  Cosine := Cos(Angle);
  Distance := Sqrt(Sqr(TargetPoint.X - LocalPosition.X) + Sqr(TargetPoint.Y - LocalPosition.Y));
  A := -HalfWidth * Cosine - -Distance * Sine;
  B := HalfWidth * Cosine - -Distance * Sine;
  C := -HalfWidth * Cosine;
  D := HalfWidth * Cosine;
  ProjectionBounds.Left := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Right := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
  A := -HalfWidth * Sine + -Distance * Cosine;
  B := HalfWidth * Sine + -Distance * Cosine;
  C := -HalfWidth * Sine;
  // Native uses Cosine for this final corner as well.
  D := HalfWidth * Cosine;
  ProjectionBounds.Top := Floor(Math.Min(Math.Min(Math.Min(A, B), C), D));
  ProjectionBounds.Bottom := Ceil(Math.Max(Math.Max(Math.Max(A, B), C), D));
end;
{ @end $698DD0 }

{ @routine $6990EC TPSEyesGI_UpdateHitTestBounds }
procedure TPSEyesGI.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $6990EC }

{ @routine $69914C TPSEyesGI_GetLocalBounds }
function TPSEyesGI.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $69914C }

{ @routine $6991B0 TPSEyesGI_AddParticle }
function TPSEyesGI.AddParticle: PEyesParticle;
var
  Particle: PEyesParticle;
begin
  Particle := AllocEC(SizeOf(TEyesParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $6991B0 }

{ @routine $699228 TPSEyesGI_ClearParticles }
procedure TPSEyesGI.ClearParticles;
var
  Particle, Current: PEyesParticle;
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
{ @end $699228 }

{ @routine $69927C TPSEyesGI_ClearLines }
procedure TPSEyesGI.ClearLines;
var
  Particle, Current: PEyesLine;
begin
  Particle := FirstLine;
  while Particle <> nil do
  begin
    Current := Particle;
    Particle := Particle.Next;
    FreeEC(Current);
  end;
  FirstLine := nil;
  LastLine := nil;
end;
{ @end $69927C }

{ @routine $6992D0 TPSEyesGI_Invalidate }
procedure TPSEyesGI.Invalidate;
begin
end;
{ @end $6992D0 }

{ @routine $6992DC TPSEyesGI_InvalidateRect }
procedure TPSEyesGI.InvalidateRect(Rect: TRect);
var
  Target: TPoint;
  Intersection: TRect;
begin
  MessageLoop.UpdateRects.AddScreenClippedRect(HitTestBounds, Parent.ToAbsolutePoint(LocalPosition), Parent.ToAbsolutePoint(TargetPoint));
  Target := Parent.ToAbsolutePoint(TargetPoint);
  Rect.Left := Target.X - HalfWidth;
  Rect.Right := Target.X + HalfWidth;
  Rect.Top := Target.Y - HalfWidth;
  Rect.Bottom := Target.Y + HalfWidth;
  if IntersectRects(Intersection, Rect, GameScreenRect) then
    MessageLoop.QueueUpdateRect(Intersection);
end;
{ @end $6992DC }

{ @routine $6993C0 TPSEyesGI_EmitBurst }
procedure TPSEyesGI.EmitBurst(Point: TPoint; Radius: Integer);
var
  X, Y: Integer;
  Particle: PEyesParticle;
begin
  for Y := -Radius to Radius do
    for X := -Radius + Abs(Y) to Radius - Abs(Y) do
    begin
      Particle := AddParticle;
      Particle.Origin := MakePointF(Point.X, Point.Y);
      Particle.Position := Particle.Origin;
      Particle.Color := PrimaryColor;
      Particle.Alpha := 255;
      Particle.State := 1;
      Particle.Countdown := 7;
      Particle.Velocity := MakePointF(X / Radius * 1.1, Y / Radius * 1.1);
      if Particle.Velocity.X < 0 then Particle.Velocity.X := Particle.Velocity.X - Random(11) / 16.0
      else Particle.Velocity.X := Particle.Velocity.X + Random(11) / 16.0;
      if Particle.Velocity.Y < 0 then Particle.Velocity.Y := Particle.Velocity.Y - Random(11) / 16.0
      else Particle.Velocity.Y := Particle.Velocity.Y + Random(11) / 16.0;
    end;
end;
{ @end $6993C0 }

{ @routine $6995B8 TPSEyesGI_Advance }
procedure TPSEyesGI.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Particle, Current: PEyesParticle;
begin
  if (FirstParticle = nil) and (RemainingTicks >= 20) then
  begin
    EmitBurst(Classes.Point(-6, -6), 8);
    EmitBurst(Classes.Point(6, 0), 8);
    EmitBurst(Classes.Point(0, 6), 8);
    EmitBurst(Classes.Point(-6, 1), 8);
    BeamTicks := 20;
  end
  else
  begin
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      case Current.State of
        2:
        begin
          Current.Position := MakePointF(Current.Position.X + Current.Velocity.X, Current.Position.Y + Current.Velocity.Y);
          Current.Velocity.X := 0.95 * Current.Velocity.X;
          Current.Velocity.Y := 0.95 * Current.Velocity.Y;
          Dec(Current.Countdown);
          if Current.Countdown = 0 then
        begin
            Current.State := 3;
            Current.Countdown := 50;
        end;
        end;
        3:
        begin
          Current.Position := MakePointF(Current.Position.X + Current.Velocity.X, Current.Position.Y + Current.Velocity.Y);
          Current.Velocity.X := 0.95 * Current.Velocity.X;
          Current.Velocity.Y := 0.95 * Current.Velocity.Y;
          if Current.Alpha > 10 then Dec(Current.Alpha, 4);
          Dec(Current.Countdown);
        end;
      end;
    end;
  end;
  Dec(RemainingTicks);
  Dec(BeamTicks);
end;
{ @end $6995B8 }

{ @routine $6997E8 TPSEyesGI_Draw }
procedure TPSEyesGI.Draw(ClipRect: TRect);
var
  Particle: PEyesParticle;
  DX, DY, X, Y, Progress, Distance, Step: Integer;
  P: TPoint;
  Line, Shadow: TEyesLine;
begin
  X := TargetPoint.X - LocalPosition.X + AbsolutePosition.X;
  Y := TargetPoint.Y - LocalPosition.Y + AbsolutePosition.Y;
  Particle := FirstParticle;
  if HardwareRenderingEnabled then
  begin
    while Particle <> nil do
    begin
      DX := Round(Particle.Position.X) + X;
      DY := Round(Particle.Position.Y) + Y;
      QueueDrawPoint(DX, DY, Color565ToArgb(Particle.Color), Particle.Alpha);
      Particle := Particle.Next;
    end;
    FlushDrawPoints(@ClipRect);
    X := AbsolutePosition.X;
    Y := AbsolutePosition.Y;
    DX := TargetPoint.X - LocalPosition.X;
    DY := TargetPoint.Y - LocalPosition.Y;
    if Abs(DX) > Abs(DY) then Distance := Abs(DX)
    else Distance := Abs(DY);
    if Distance = 0 then Distance := 1;
    Progress := 0;
    Step := Distance div 4;
    if Step < 1 then Step := 1;
    if Step > SegmentLength then Step := SegmentLength;
    if BeamTicks > 0 then
    begin
      P := Classes.Point(X, Y);
      while Distance - Progress > Step do
      begin
        Line.First := P;
        P := Classes.Point(X + (Progress + Step) * DX div Distance + RandomIntRange(-Dispersion, Dispersion),
          Y + (Progress + Step) * DY div Distance + RandomIntRange(-Dispersion, Dispersion));
        Line.Last := P;
        Line.Alpha := (255 - StartingAlpha) * (Progress + Step) div Distance + StartingAlpha;
        Line.Color := SecondaryColor;
        if Abs(DX) > Abs(DY) then
        begin
          Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
          Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
        end
        else
        begin
          Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
          Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
        end;
        Shadow.Alpha := Line.Alpha;
        Shadow.Color := PrimaryColor;
        Inc(Progress, Step);
        DrawAntialiasedLineDX(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Color565ToArgb(Line.Color), Line.Alpha, @ClipRect);
        DrawAntialiasedLineDX(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Color565ToArgb(Shadow.Color), Line.Alpha, @ClipRect);
      end;
      Line.First := P;
      Line.Last := Classes.Point(X + DX, Y + DY);
      Line.Alpha := 255;
      Line.Color := PrimaryColor;
      if Abs(DX) > Abs(DY) then
      begin
        Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
        Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
      end
      else
      begin
        Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
        Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
      end;
      Shadow.Alpha := Line.Alpha;
      Shadow.Color := PrimaryColor;
      DrawAntialiasedLineDX(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Color565ToArgb(Line.Color), Line.Alpha, @ClipRect);
      DrawAntialiasedLineDX(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Color565ToArgb(Shadow.Color), Line.Alpha, @ClipRect);
    end;
  end
  else
  begin
    while Particle <> nil do
    begin
      DX := Round(Particle.Position.X) + X;
      DY := Round(Particle.Position.Y) + Y;
      if (DX >= ClipRect.Left) and (DX < ClipRect.Right) and (DY >= ClipRect.Top) and (DY < ClipRect.Bottom) then
        ScreenRenderBuffer.BlendPixel16(DX, DY, Particle.Color, Particle.Alpha);
      Particle := Particle.Next;
    end;
    X := AbsolutePosition.X;
    Y := AbsolutePosition.Y;
    DX := TargetPoint.X - LocalPosition.X;
    DY := TargetPoint.Y - LocalPosition.Y;
    if Abs(DX) > Abs(DY) then Distance := Abs(DX)
    else Distance := Abs(DY);
    if Distance = 0 then Distance := 1;
    Progress := 0;
    Step := Distance div 4;
    if Step < 1 then Step := 1;
    if Step > SegmentLength then Step := SegmentLength;
    if BeamTicks > 0 then
    begin
      P := Classes.Point(X, Y);
      while Distance - Progress > Step do
      begin
        Line.First := P;
        P := Classes.Point(X + (Progress + Step) * DX div Distance + RandomIntRange(-Dispersion, Dispersion),
          Y + (Progress + Step) * DY div Distance + RandomIntRange(-Dispersion, Dispersion));
        Line.Last := P;
        Line.Alpha := (255 - StartingAlpha) * (Progress + Step) div Distance + StartingAlpha;
        Line.Color := SecondaryColor;
        if Abs(DX) > Abs(DY) then
        begin
          Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
          Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
        end
        else
        begin
          Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
          Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
        end;
        Shadow.Alpha := Line.Alpha;
        Shadow.Color := PrimaryColor;
        Inc(Progress, Step);
        ScreenRenderBuffer.DrawAlphaLine16(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Line.Color, Line.Alpha, ClipRect);
        ScreenRenderBuffer.DrawAlphaLine16(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Shadow.Color, Line.Alpha, ClipRect);
      end;
      Line.First := P;
      Line.Last := Classes.Point(X + DX, Y + DY);
      Line.Alpha := 255;
      Line.Color := PrimaryColor;
      if Abs(DX) > Abs(DY) then
      begin
        Shadow.First := Classes.Point(Line.First.X, Line.First.Y - 1);
        Shadow.Last := Classes.Point(Line.Last.X, Line.Last.Y - 1);
      end
      else
      begin
        Shadow.First := Classes.Point(Line.First.X - 1, Line.First.Y);
        Shadow.Last := Classes.Point(Line.Last.X - 1, Line.Last.Y);
      end;
      Shadow.Alpha := Line.Alpha;
      Shadow.Color := PrimaryColor;
      ScreenRenderBuffer.DrawAlphaLine16(Line.First.X, Line.First.Y, Line.Last.X, Line.Last.Y, Line.Color, Line.Alpha, ClipRect);
      ScreenRenderBuffer.DrawAlphaLine16(Shadow.First.X, Shadow.First.Y, Shadow.Last.X, Shadow.Last.Y, Shadow.Color, Line.Alpha, ClipRect);
    end;
  end;
end;
{ @end $6997E8 }

{ @routine $69A068 LoadEyesPalettes }
procedure LoadEyesPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, BlockCount, Count: Integer;
  Text: WideString;
  UnusedNativeFrame: Integer; // Native retains one unreferenced four-byte slot.
begin
  Block := GameDataConfig.FindBlockByPath('SE.Weapon.Eyes.Palettes');
  Count := 0;
  if Block <> nil then
  begin
    BlockCount := Block.GetBlockCount;
    for Index := 0 to BlockCount - 1 do
      Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  end;
  if (Block = nil) or (Count = 0) then
  begin
    SetLength(EyesPalettes, 1);
    SetLength(EyesWidths, 1);
    SetLength(EyesSegmentLengths, 1);
    SetLength(EyesDispersions, 1);
    SetLength(EyesStartingAlphas, 1);
    EyesPalettes[0][0] := CurrentPixelFormat.PackNormalizedRgb(0.9, 0.7, 1.0);
    EyesPalettes[0][1] := CurrentPixelFormat.PackNormalizedRgb(0.25, 0.15, 0.6);
    EyesWidths[0] := 32;
    EyesSegmentLengths[0] := 32;
    EyesDispersions[0] := 5;
    EyesStartingAlphas[0] := 64;
  end
  else
  begin
    SetLength(EyesPalettes, Count);
    SetLength(EyesWidths, Count);
    SetLength(EyesSegmentLengths, Count);
    SetLength(EyesDispersions, Count);
    SetLength(EyesStartingAlphas, Count);
    for Index := 0 to Count - 1 do
    begin
      EyesPalettes[Index][0] := CurrentPixelFormat.PackNormalizedRgb(0.9, 0.7, 1.0);
      EyesPalettes[Index][1] := CurrentPixelFormat.PackNormalizedRgb(0.25, 0.15, 0.6);
      EyesWidths[Index] := 32;
      EyesSegmentLengths[Index] := 32;
      EyesDispersions[Index] := 5;
      EyesStartingAlphas[Index] := 64;
      Text := IntToStr(Index);
      if Block.CountBlocks(Text) <> 0 then
      begin
        PaletteBlock := Block.GetBlockByPath(Text);
        if PaletteBlock.CountParams('Color') > 0 then
        begin
          Text := PaletteBlock.GetParam('Color');
          EyesPalettes[Index][0] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
        if PaletteBlock.CountParams('ColorDark') > 0 then
        begin
          Text := PaletteBlock.GetParam('ColorDark');
          EyesPalettes[Index][1] := CurrentPixelFormat.PackNormalizedRgb(
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 0, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ',')),
            ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ',')));
        end;
        if PaletteBlock.CountParams('Width') > 0 then
          EyesWidths[Index] := ExtractDigitsToIntW(PaletteBlock.GetParam('Width'));
        if PaletteBlock.CountParams('SegmentLength') > 0 then
          EyesSegmentLengths[Index] := ExtractDigitsToIntW(PaletteBlock.GetParam('SegmentLength'));
        if PaletteBlock.CountParams('Dispersion') > 0 then
          EyesDispersions[Index] := ExtractDigitsToIntW(PaletteBlock.GetParam('Dispersion'));
        if PaletteBlock.CountParams('StartingAlpha') > 0 then
          EyesStartingAlphas[Index] := ExtractDigitsToIntW(PaletteBlock.GetParam('StartingAlpha'));
      end;
    end;
  end;
end;
{ @end $69A068 }

end.
