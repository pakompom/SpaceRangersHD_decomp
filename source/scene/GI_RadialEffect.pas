unit GI_RadialEffect;
// Native expanding radiation field, hexagonal lattice and palette resources.

interface

uses EC_Struct, GI_MessageLoop, GI_PSWeapon, Types;

type
  PRadiationParticle = ^TRadiationParticle;
  TRadiationParticle = record // @size $50
    Prev: PRadiationParticle; // @offset $00
    Next: PRadiationParticle; // @offset $04
    Position: TPoint; // @offset $08
    Color: Word; // @offset $10
    Alpha: array[0..11] of Byte; // @offset $12
    EdgeDistance: array[0..11] of Integer; // @offset $20
  end;
  TRadiationPalette = array[0..5] of Single;
  TRadiationPalettes = array of TRadiationPalette;
  TAuraAnimationPaths = array of WideString;

var
  AuraAnimationPaths: array of WideString; // @addr $88AF34
  RadiationRadii: array of Integer; // @addr $88AF38
  RadiationPalettes: array of TRadiationPalette; // @addr $88AF3C

type
  TPSRadEffectGI = class(TPSWeaponGI) // @size $164
  public
    FirstParticle: PRadiationParticle; // @offset $130
    LastParticle: PRadiationParticle; // @offset $134
    Color: Word; // @offset $138
    Radius: Integer; // @offset $13C
    Alpha: Byte; // @offset $140
    PaletteIndex: Integer; // @offset $144
    ProjectionBounds: TRect; // @offset $148
    LatticeOffset: TPointF; // @offset $158
    PositionInitialized: Boolean; // @offset $160

    constructor Create(Owner: TObjectGI; APaletteIndex: Integer); // @addr $69B424
    destructor Destroy; override; // @addr $69B4F4
    procedure SetColor(Value: Word); // @addr $69B530
    procedure SetPosition(Position: TPoint); override; // @addr $69B550
    procedure SetTargetPoint(Point: TPoint); override; // @addr $69B740
    procedure UpdateProjectionBounds; // @addr $69B794
    procedure UpdateHitTestBounds; override; // @addr $69B80C
    function GetLocalBounds: TRect; override; // @addr $69B86C
    function AddParticle: PRadiationParticle; // @addr $69B8D0
    procedure ClearParticles; // @addr $69B948
    procedure InvalidateRect(Rect: TRect); override; // @addr $69B99C
    procedure Advance(Timer: PCallbackTimerGI; UserData: Integer); override; // @addr $69BA68
    procedure Draw(ClipRect: TRect); override; // @addr $69C4B0
  end;

procedure LoadRadiationPalettes; // @addr $69C7BC

var
  RadiationEdgeStarts: array[0..23] of TPoint; // @addr $88AF40
  RadiationEdgeEnds: array[0..23] of TPoint; // @addr $88B000
  RadiationHexagon: array[0..5] of TPointF = (
    (X: -0.866025404; Y: 0.5), (X: 0; Y: 1),
    (X: 0.866025404; Y: 0.5), (X: 0.866025404; Y: -0.5),
    (X: 0; Y: -1), (X: -0.866025404; Y: -0.5)); // @addr $87BF40

var
  // Managed globals follow the verified native finalization order.

implementation

// @unit-initialization $877974
// @unit-finalization $69CD04

uses SysUtils, Math, EC_BlockPar, EC_Str, EC_Mem, GR_Main, GR_DX, aMyFunction, Globals;

{ @routine $69B424 TPSRadEffectGI_Create }
constructor TPSRadEffectGI.Create(Owner: TObjectGI; APaletteIndex: Integer);
begin
  inherited Create(Owner);
  RemainingTicks := 340;
  // Native initializes bounds before assigning the requested palette index.
  UpdateProjectionBounds;
  PositionInitialized := False;
  PaletteIndex := APaletteIndex;
  SetColor(CurrentPixelFormat.PackNormalizedRgb(RadiationPalettes[APaletteIndex][0], RadiationPalettes[APaletteIndex][1], RadiationPalettes[APaletteIndex][2]));
end;
{ @end $69B424 }

{ @routine $69B4F4 TPSRadEffectGI_Destroy }
destructor TPSRadEffectGI.Destroy;
begin
  ClearParticles;
  inherited Destroy;
end;
{ @end $69B4F4 }

{ @routine $69B530 TPSRadEffectGI_SetColor }
procedure TPSRadEffectGI.SetColor(Value: Word);
begin
  Color := Value;
end;
{ @end $69B530 }

{ @routine $69B550 TPSRadEffectGI_SetPosition }
procedure TPSRadEffectGI.SetPosition(Position: TPoint);
var
  X1, Y1, X2, Y2, Distance1, Distance2: Single;
begin
  if not PositionInitialized then
  begin
    inherited SetPosition(Position);
    PositionInitialized := True;
    X1 := Round(LocalPosition.X / 51.96152424) * 2 * 0.866025404 * 30.0;
    Y1 := Round(LocalPosition.Y / 90.0) * 3 * 30;
    X2 := (Round(LocalPosition.X / 51.96152424 + 0.5) - 0.5) * 2.0 * 0.866025404 * 30.0;
    Y2 := (Round(LocalPosition.Y / 90.0 + 0.5) - 0.5) * 3.0 * 30.0;
    Distance1 := Sqr(X1 - LocalPosition.X) + Sqr(Y1 - LocalPosition.Y);
    Distance2 := Sqr(X2 - LocalPosition.X) + Sqr(Y2 - LocalPosition.Y);
    if Distance1 < Distance2 then
    begin
      LatticeOffset.X := X1 - LocalPosition.X;
      LatticeOffset.Y := Y1 - LocalPosition.Y;
    end
    else
    begin
      LatticeOffset.X := X2 - LocalPosition.X;
      LatticeOffset.Y := Y2 - LocalPosition.Y;
    end;
  end;
  UpdateProjectionBounds;
end;
{ @end $69B550 }

{ @routine $69B740 TPSRadEffectGI_SetTargetPoint }
procedure TPSRadEffectGI.SetTargetPoint(Point: TPoint);
begin
  if (TargetPoint.X <> Point.X) or (TargetPoint.Y <> Point.Y) then
  begin
    TargetPoint := Point;
    UpdateProjectionBounds;
  end;
end;
{ @end $69B740 }

{ @routine $69B794 TPSRadEffectGI_UpdateProjectionBounds }
procedure TPSRadEffectGI.UpdateProjectionBounds;
begin
  ProjectionBounds.Left := -RadiationRadii[PaletteIndex];
  ProjectionBounds.Right := RadiationRadii[PaletteIndex];
  ProjectionBounds.Top := -RadiationRadii[PaletteIndex];
  ProjectionBounds.Bottom := RadiationRadii[PaletteIndex];
end;
{ @end $69B794 }

{ @routine $69B80C TPSRadEffectGI_UpdateHitTestBounds }
procedure TPSRadEffectGI.UpdateHitTestBounds;
begin
  HitTestBounds.Left := ProjectionBounds.Left + AbsolutePosition.X;
  HitTestBounds.Top := ProjectionBounds.Top + AbsolutePosition.Y;
  HitTestBounds.Right := ProjectionBounds.Right + AbsolutePosition.X;
  HitTestBounds.Bottom := ProjectionBounds.Bottom + AbsolutePosition.Y;
end;
{ @end $69B80C }

{ @routine $69B86C TPSRadEffectGI_GetLocalBounds }
function TPSRadEffectGI.GetLocalBounds: TRect;
begin
  Result.Left := ProjectionBounds.Left + LocalPosition.X;
  Result.Top := ProjectionBounds.Top + LocalPosition.Y;
  Result.Right := ProjectionBounds.Right + LocalPosition.X;
  Result.Bottom := ProjectionBounds.Bottom + LocalPosition.Y;
end;
{ @end $69B86C }

{ @routine $69B8D0 TPSRadEffectGI_AddParticle }
function TPSRadEffectGI.AddParticle: PRadiationParticle;
var
  Particle: PRadiationParticle;
begin
  Particle := AllocEC(SizeOf(TRadiationParticle));
  if LastParticle <> nil then LastParticle.Next := Particle;
  Particle.Prev := LastParticle;
  Particle.Next := nil;
  LastParticle := Particle;
  if FirstParticle = nil then FirstParticle := Particle;
  Result := Particle;
end;
{ @end $69B8D0 }

{ @routine $69B948 TPSRadEffectGI_ClearParticles }
procedure TPSRadEffectGI.ClearParticles;
var
  Particle, Current: PRadiationParticle;
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
{ @end $69B948 }

{ @routine $69B99C TPSRadEffectGI_InvalidateRect }
procedure TPSRadEffectGI.InvalidateRect(Rect: TRect);
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
{ @end $69B99C }

{ @routine $69BA68 TPSRadEffectGI_Advance }
procedure TPSRadEffectGI.Advance(Timer: PCallbackTimerGI; UserData: Integer);
var
  Column, Row, Edge, X, Y, Columns, Rows, RingOffset, FadeAlpha: Integer;
  Particle, Current: PRadiationParticle;
begin
  Invalidate;
  if (FirstParticle = nil) and (RemainingTicks >= 24) then
  begin
    Radius := 0;
    Columns := Ceil(RadiationRadii[PaletteIndex] / 25.98076212) + 1;
    Rows := Ceil(RadiationRadii[PaletteIndex] / 90.0) + 1;
    for Column := -Columns to Columns do
      for Row := -2 * Rows to 2 * Rows do
      begin
        Particle := AddParticle;
        Particle.Color := Color;
        Particle.Position.X := Round((Row mod 2 * 0.5 + Column) * 30.0 * 2.0 * 0.866025404 + LatticeOffset.X);
        Particle.Position.Y := Round((30 * Row) * 1.5 + LatticeOffset.Y);
        for Edge := Low(Particle.Alpha) to High(Particle.Alpha) do
        begin
          Particle.Alpha[Edge] := 0;
          X := Particle.Position.X + (RadiationEdgeStarts[Edge].X + RadiationEdgeEnds[Edge].X) div 2;
          Y := Particle.Position.Y + (RadiationEdgeStarts[Edge].Y + RadiationEdgeEnds[Edge].Y) div 2;
          Particle.EdgeDistance[Edge] := Round(Sqrt(X * X + Y * Y));
        end;
      end;
  end
  else
  begin
    Inc(Radius, Math.Max(1, Round((RadiationRadii[PaletteIndex] * 4) / 500.0)));
    Alpha := Round(255.0 - Sqr(Radius / RadiationRadii[PaletteIndex]) * 255.0);
    RingOffset := Radius;
    FadeAlpha := Alpha;
    RingOffset := Round(RingOffset - 30.0 - 2.0);
    FadeAlpha := Round(FadeAlpha * 0.7);
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      Current := Particle;
      Particle := Particle.Next;
      for Edge := Low(Current.EdgeDistance) to High(Current.EdgeDistance) do
        if Current.EdgeDistance[Edge] > RingOffset then
          Current.Alpha[Edge] := Math.Max(0, FadeAlpha - Sqr((Current.EdgeDistance[Edge] - RingOffset) div 2))
        else
          Current.Alpha[Edge] := Round(Math.Max(0, FadeAlpha - Abs(Current.EdgeDistance[Edge] - RingOffset) * Math.Max(0.1, 1.0 - Math.Max(RingOffset, 0) / RadiationRadii[PaletteIndex])));
    end;
    UpdateHitTestBounds;
  end;
  Dec(RemainingTicks);
  if RadiationRadii[PaletteIndex] < Radius then RemainingTicks := 0;
end;
{ @end $69BA68 }

{ @routine $69C4B0 TPSRadEffectGI_Draw }
procedure TPSRadEffectGI.Draw(ClipRect: TRect);
var
  DistanceSquared, FadeRadius, CenterX, CenterY: Integer;

  // @nested $69BF88 RadiationRingColor
  function RadiationRingColor(Value: Integer): Cardinal; // @addr $69BF88 @calls "0x0069C3A2, 0x0069C198"
  begin
    Result := SampleGradientColor(RadiationPalettes[PaletteIndex], Sqr(Value / 255.0));
  end;

  // @nested $69BFDC RadiationRingAlpha
  function RadiationRingAlpha(Distance: Single): Integer; // @addr $69BFDC @calls "0x0069C388, 0x0069C17E"
  begin
    if Distance > 0 then Result := Round(Math.Max(0, Alpha - Sqr(Distance) * 10.0))
    else if Distance > -10.0 then Result := Round(Math.Max(0, 10.0 * Distance + Alpha))
    else Result := Round(Math.Max(0, (Distance + 10.0) * 3.0 + (Alpha - 100)));
  end;

  // @nested $69C148 QueueRadiationOctants
  procedure QueueRadiationOctants(X, Y: Integer); // @addr $69C148 @calls "0x0069C65F"
  var
    PixelColor: Cardinal;
    PixelAlpha: Integer;
    Distance: Single;
  begin
    Distance := Sqrt(DistanceSquared);
    PixelAlpha := RadiationRingAlpha(Distance - FadeRadius);
    if PixelAlpha > 0 then
    begin
      PixelColor := Color565ToArgb(RadiationRingColor(PixelAlpha));
      QueueDrawPoint(X + CenterX, Y + CenterY, PixelColor, PixelAlpha);
      QueueDrawPoint(-X + CenterX, -Y + CenterY, PixelColor, PixelAlpha);
      if (X > 0) and (Y > 0) then
      begin
        QueueDrawPoint(-X + CenterX, Y + CenterY, PixelColor, PixelAlpha);
        QueueDrawPoint(X + CenterX, -Y + CenterY, PixelColor, PixelAlpha);
      end;
      if X <> Y then
      begin
        QueueDrawPoint(Y + CenterX, X + CenterY, PixelColor, PixelAlpha);
        QueueDrawPoint(-Y + CenterX, -X + CenterY, PixelColor, PixelAlpha);
        if (X > 0) and (Y > 0) then
        begin
          QueueDrawPoint(-Y + CenterX, X + CenterY, PixelColor, PixelAlpha);
          QueueDrawPoint(Y + CenterX, -X + CenterY, PixelColor, PixelAlpha);
        end;
      end;
    end;
  end;

var
  Edge: Integer;

  // @nested $69C338 BlendRadiationOctants
  procedure BlendRadiationOctants(X, Y: Integer); // @addr $69C338 @calls "0x0069C7A9"
  var
    PixelColor: Cardinal;
    PixelAlpha: Integer;

    // @nested $69C2D0 BlendRadiationPoint
    procedure BlendRadiationPoint(X, Y: Integer); // @addr $69C2D0 @calls "0x0069C3C6, 0x0069C3E3, 0x0069C40A, 0x0069C425, 0x0069C446, 0x0069C463, 0x0069C48A, 0x0069C4A5"
    begin
      if (ClipRect.Left <= X) and (ClipRect.Right > X) and (ClipRect.Top <= Y) and (ClipRect.Bottom > Y) then
        ScreenRenderBuffer.BlendPixel16(X, Y, PixelColor, PixelAlpha);
    end;

  var
    Distance: Single;
  begin
    Distance := Sqrt(DistanceSquared);
    PixelAlpha := RadiationRingAlpha(Round(Distance) - FadeRadius);
    if PixelAlpha > 0 then
    begin
      PixelColor := RadiationRingColor(PixelAlpha);
      Edge := 0;
      BlendRadiationPoint(X + CenterX, Y + CenterY);
      BlendRadiationPoint(-X + CenterX, -Y + CenterY);
      if (X > 0) and (Y > 0) then
      begin
        BlendRadiationPoint(-X + CenterX, Y + CenterY);
        BlendRadiationPoint(X + CenterX, -Y + CenterY);
      end;
      if X <> Y then
      begin
        BlendRadiationPoint(Y + CenterX, X + CenterY);
        BlendRadiationPoint(-Y + CenterX, -X + CenterY);
        if (X > 0) and (Y > 0) then
        begin
          BlendRadiationPoint(-Y + CenterX, X + CenterY);
          BlendRadiationPoint(Y + CenterX, -X + CenterY);
        end;
      end;
    end;
  end;

var
  Particle: PRadiationParticle;
  OuterRadius, InnerRadius, OuterSquared, InnerSquared, X, Y: Integer;
begin
  OuterRadius := Radius;
  InnerRadius := Math.Max(OuterRadius - 100, 0);
  FadeRadius := Math.Max(OuterRadius - 10, 0);
  OuterSquared := Sqr(OuterRadius);
  InnerSquared := Sqr(InnerRadius);
  CenterX := AbsolutePosition.X;
  CenterY := AbsolutePosition.Y;
  if HardwareRenderingEnabled then
  begin
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      for Edge := Low(Particle.Alpha) to High(Particle.Alpha) do
        if Particle.Alpha[Edge] > 0 then
          DrawAlphaLine(AbsolutePosition.X + Particle.Position.X + RadiationEdgeStarts[Edge].X,
            AbsolutePosition.Y + Particle.Position.Y + RadiationEdgeStarts[Edge].Y,
            AbsolutePosition.X + Particle.Position.X + RadiationEdgeEnds[Edge].X,
            AbsolutePosition.Y + Particle.Position.Y + RadiationEdgeEnds[Edge].Y,
            Color565ToArgb(Particle.Color), Particle.Alpha[Edge], @ClipRect);
      Particle := Particle.Next;
    end;
    Y := 0;
    X := 0;
    while True do
    begin
      DistanceSquared := Sqr(X) + Sqr(Y);
      if DistanceSquared < InnerSquared then
      begin
        Inc(X);
        Continue;
      end;
      if DistanceSquared > OuterSquared then
      begin
        Inc(Y);
        X := Y;
        DistanceSquared := Sqr(X) + Sqr(Y);
        if DistanceSquared > OuterSquared then Break;
        Continue;
      end;
      QueueRadiationOctants(X, Y);
      Inc(X);
    end;
    FlushDrawPoints(@ClipRect);
  end
  else
  begin
    Particle := FirstParticle;
    while Particle <> nil do
    begin
      for Edge := Low(Particle.Alpha) to High(Particle.Alpha) do
        if Particle.Alpha[Edge] > 0 then
          // The native software path retains this second, identical test.
          if Particle.Alpha[Edge] > 0 then
            ScreenRenderBuffer.DrawAntialiasedLine16(
              AbsolutePosition.X + Particle.Position.X + RadiationEdgeStarts[Edge].X,
              AbsolutePosition.Y + Particle.Position.Y + RadiationEdgeStarts[Edge].Y,
              AbsolutePosition.X + Particle.Position.X + RadiationEdgeEnds[Edge].X,
              AbsolutePosition.Y + Particle.Position.Y + RadiationEdgeEnds[Edge].Y,
              Particle.Color, Particle.Alpha[Edge], ClipRect);
      Particle := Particle.Next;
    end;
    Y := 0;
    X := 0;
    while True do
    begin
      DistanceSquared := Sqr(X) + Sqr(Y);
      if DistanceSquared < InnerSquared then
      begin
        Inc(X);
        Continue;
      end;
      if DistanceSquared > OuterSquared then
      begin
        Inc(Y);
        X := Y;
        DistanceSquared := Sqr(X) + Sqr(Y);
        if DistanceSquared > OuterSquared then Break;
        Continue;
      end;
      BlendRadiationOctants(X, Y);
      Inc(X);
    end;
  end;
end;
{ @end $69C4B0 }

{ @routine $69C7BC LoadRadiationPalettes }
procedure LoadRadiationPalettes;
var
  Block, PaletteBlock: TBlockParEC;
  Index, ColorIndex, PartIndex, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.RadialEffect.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(RadiationPalettes, Count);
  SetLength(RadiationRadii, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      for ColorIndex := 0 to 1 do
      begin
        Text := PaletteBlock.GetParam('Color' + IntToStr(ColorIndex));
        for PartIndex := 0 to 2 do
          RadiationPalettes[Index][3 * ColorIndex + PartIndex] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, PartIndex, ','));
      end;
      if PaletteBlock.CountParams('Radius') > 0 then
        RadiationRadii[Index] := ExtractDigitsToIntW(PaletteBlock.GetParam('Radius'))
      else RadiationRadii[Index] := 500;
    end;
  end;
  for Index := Low(RadiationHexagon) to High(RadiationHexagon) do
    for ColorIndex := 0 to 3 do
    begin
      RadiationEdgeStarts[Index * 4 + ColorIndex].X := Round(((4 - ColorIndex) * RadiationHexagon[Index].X + ColorIndex * RadiationHexagon[(Index + 1) mod Length(RadiationHexagon)].X) * 30.0 / 4.0);
      RadiationEdgeStarts[Index * 4 + ColorIndex].Y := Round(((4 - ColorIndex) * RadiationHexagon[Index].Y + ColorIndex * RadiationHexagon[(Index + 1) mod Length(RadiationHexagon)].Y) * 30.0 / 4.0);
    end;
  for Index := Low(RadiationEdgeEnds) to High(RadiationEdgeEnds) do
  begin
    RadiationEdgeEnds[Index].X := RadiationEdgeStarts[(Index + 1) mod Length(RadiationEdgeStarts)].X;
    RadiationEdgeEnds[Index].Y := RadiationEdgeStarts[(Index + 1) mod Length(RadiationEdgeStarts)].Y;
  end;
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.AuraEffect.Palettes');
  ColorIndex := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to ColorIndex - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(AuraAnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      if PaletteBlock.CountParams('GAI') > 0 then
        AuraAnimationPaths[Index] := PaletteBlock.GetParam('GAI');
    end;
  end;
end;
{ @end $69C7BC }

end.
