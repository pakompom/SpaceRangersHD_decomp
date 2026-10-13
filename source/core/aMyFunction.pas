unit aMyFunction;

interface

uses EC_Struct, Classes, Types;

const
  // Preserve the native angle approximations and random endpoint quantization.
  GamePi = 3.1415926;
  GameTwoPi = 6.2831852;
  RandomFloatResolution = 1000;

  // Complete markup tags. Keep these untyped so they remain string literals.
  // Dialogs remap the standard highlight and equipment colors for light panels.
  TextHighlightColorTag = '<color=255,240,100>';
  DialogHighlightColorTag = '<color=0,50,200>';
  EquipmentBonusColorTag = '<color=255,167,84>';
  DialogEquipmentBonusColorTag = '<color=240,100,30>';
  DialogGreenColorTag = '<color=0,130,0>';
  EndColorTag = '</color>';

  // Shared palette; the same colors serve several unrelated display roles.
  // Exact spelling matters to ReplaceAllWideString; padded RGB tags differ.
  RedColorTag = '<color=255,0,0>';
  GreenColorTag = '<color=0,255,0>';
  GrayColorTag = '<color=127,127,127>';
  YellowColorTag = '<color=255,255,0>';
  BlackColorTag = '<color=0,0,0>';
  MagentaColorTag = '<color=255,0,255>';
  CyanColorTag = '<color=0,255,255>';
  OrangeColorTag = '<color=255,166,0>';
  GoldColorTag = '<color=254,217,7>';
  AzureColorTag = '<color=0,128,255>';
  DarkGreenColorTag = '<color=45,105,45>';
  BrightBlueColorTag = '<color=0,71,234>';

  MicroModuleHighPriorityColorTag = '<color=17,139,255>';
  DefaultInfoNameColorTag = '<color=57,239,255>';
  DefaultInfoHullSeriesColorTag = '<color=82,166,255>';

type
  TPolarPoint = record // @size 0x10  Natural Double alignment is visible in TPlanet.PredictPosition locals.
    AngleDegrees: Double; // @offset 0x00  Clockwise from the negative Y axis.
    Radius: Double; // @offset 0x08
  end;

  TPolarRadiansPoint = record // @size $10 Natural Double alignment is visible in CoordX/CoordY result temporaries.
    AngleRadians: Double; // @offset $00
    Radius: Double; // @offset $08
  end;

var
  // Configured by GI_Main from StyleColor.InfoNameColor / InfoHullSeriesColor.
  InfoNameColorTag: WideString = DefaultInfoNameColorTag; // @addr $8130AC
  InfoHullSeriesColorTag: WideString = DefaultInfoHullSeriesColorTag; // @addr $8130B0

type
  TObjectList = class(TList) // @size 0x10
  public
    destructor Destroy; override; // @addr 0x00801FAC
    procedure FreeItems; // @addr 0x00801FD8 @note "Inherited Clear/Delete do not free objects."
  end;

// Integer ranges include both endpoints and accept either endpoint order.
// Seeded helpers read the supplied seed; Next helpers advance it, except in chaotic mode.
function RandomIntRange(BoundA, BoundB: Integer): Integer; // @addr 0x00802014 @note "Accepts either endpoint order."
function SeededRandomIntRange(BoundA, BoundB: Integer; Seed: Cardinal): Integer; // @addr 0x0080203C @note "Chaotic mode ignores Seed."
function RandomUnitFloat: Single; // @addr 0x008020A4 @note "One of 1000 discrete values from 0.001 through 1.0 inclusive."
function SeededRandomUnitFloat(Seed: Cardinal): Single; // @addr 0x008020D4 @note "Chaotic mode ignores Seed."
function RandomFloatRange(BoundA, BoundB: Double): Double; // @addr 0x00802108 @note "Endpoints are quantized as Trunc(bound*1000+1)/1000; results have 0.001 resolution."
function SeededRandomFloatRange(Seed: Cardinal; BoundA, BoundB: Double): Double; // @addr 0x00802160 @note "Uses RandomFloatRange's endpoint quantization; chaotic mode ignores Seed."
function StepRandomSeed(Seed: Cardinal): Cardinal; // @addr 0x008021BC
function AdvanceRandomSeed(var Seed: Cardinal): Cardinal; // @addr 0x008021C8
function NextRandomIntRange(BoundA, BoundB: Integer; var Seed: Cardinal): Integer; // @addr 0x00802210 @note "Chaotic mode leaves Seed unchanged."
function NextRandomFloatRange(BoundA, BoundB: Double; var Seed: Cardinal): Double; // @addr 0x008022A0 @ida "double __userpurge $name@<st0>(unsigned int *Seed@<eax>, double BoundA@<^8>, double BoundB@<^0>);" @note "Uses RandomFloatRange's endpoint quantization; chaotic mode leaves Seed unchanged."
function NextRandomUnitFloat(var Seed: Cardinal): Double; // @addr 0x0080236C @note "Normally in [0,1). Chaotic mode leaves Seed unchanged and instead yields 0.001..1.001."
function RemapClamped(Value, InMin, InMax, OutMin, OutMax: Double): Double; // @addr 0x00803544

function RoundAndTruncateToTens(Value: Double): Integer; // @addr 0x00802448 @note "Round(Value), then signed integer division by ten and multiplication by ten."

function PointDistanceSquared(PointA, PointB: TPointF): Single; // @addr 0x0080343C
function PolarToPoint(Polar: TPolarPoint): TPointF; // @addr 0x00802530 @note "Copies the 16-byte input; X = sin(angle)*radius, Y = -cos(angle)*radius."
function PointDistance(PointA, PointB: TPointF): Double; // @addr 0x0080348C
function RadiansToHeadingDegrees(Angle: Double): Double; // @addr 0x00802610 @note "Adds 360 only once for negative angles; does not fully normalize arbitrary inputs."
function HeadingDegreesToRadians(Angle: Double): Double; // @addr 0x0080265C @note "Subtracts 360 only once for angles above 180; does not fully normalize arbitrary inputs."
function PointBearingDegrees(PointA, PointB: TPointF): Double; // @addr 0x008026A8 @note "Bearing from A to B: zero points upward and angles increase clockwise in screen coordinates."
function HeadingDifferenceDegrees(FromHeading, ToHeading: Double): Double; // @addr 0x008026FC @note "Signed shortest turn from FromHeading to ToHeading; requires headings normalized to [0,360)."
function WrapHeadingDegrees(Angle: Single): Single; // @addr 0x0080276C @note "Repeatedly adds or subtracts 360 to reach [0,360); requires a finite value small enough for Single-precision steps to change it."

// Original unit ownership of this formatting family (aMyFunction/MessageText) is unresolved.
// ColorTag is a complete opening tag; empty disables coloring. Replacements are
// case-sensitive and append </color> even when the replacement text is empty.
procedure ReplaceTextToken(var Text: WideString; Token, Replacement, ColorTag: WideString); // @addr 0x008035BC
function ReplaceColoredToken(Text, Token, Replacement, ColorTag: WideString): WideString; // @addr 0x00803680
function FormatText1(Text, ColorTag, Token, Replacement: WideString): WideString; // @addr 0x0080373C
// Multiple replacements run in order, including matches in text inserted earlier.
function FormatText2(Text, ColorTag, Token1, Replacement1, Token2, Replacement2: WideString): WideString; // @addr 0x008037F8
function FormatText3(Text, ColorTag, Token1, Replacement1, Token2, Replacement2, Token3, Replacement3: WideString): WideString; // @addr 0x008038FC
function WrapTextInColor(Text, ColorTag: WideString): WideString; // @addr 0x00803A3C @note "Returns Text unchanged when either argument is empty."

function RayIntersectsOriginCircle(StartPoint, ThroughPoint: TPointF; out Intersection: TPointF; Radius: Single): Boolean; // @addr 0x00803030 @note "Normalizes the ray direction, rejects tangencies, and returns whether the selected intersection is ahead of StartPoint. No segment-length bound."

function DecrementWrappedValue(Value, Minimum, Maximum: Integer): Integer; // @addr $803CE0 Returns a decremented value, wrapping below Minimum to Maximum. Value is passed by value.
function IncrementWrapped(var Value: Integer; Minimum, Maximum: Integer): Integer; // @addr 0x00803CCC @note "Increments Value, or resets it to Minimum when Value + 1 exceeds Maximum; returns the updated value."

function FractionalQuotient(Numerator, Denominator: Integer): Double; // @addr $8023F8
function RoundAndTruncateToFives(Value: Double): Integer; // @addr $80242C
function RoundAndTruncateToHundreds(Value: Double): Integer; // @addr $802468
function PointFromRadiusAngle(Radius, Angle: Single): TPointF; // @addr $802484 @ida "void __userpurge $name(TPointF *Result@<eax>, float Radius@<^4>, float Angle@<^0>);" @note "Angle is in radians, measured from the positive X axis."
function OffsetPointByRadiusAngle(Origin: TPointF; Radius, Angle: Single): TPointF; // @addr $8024A4 @ida "void __userpurge $name(TPointF *Origin@<eax>, TPointF *Result@<edx>, float Radius@<^4>, float Angle@<^0>);"
function RotateAndTranslatePoint(Point, Translation: TPointF; Angle: Single): TPointF; // @addr $8024DC @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *Translation@<edx>, TPointF *Result@<ecx>, float Angle@<^0>);"
function IntegerPointToPolar(Point: TPoint): TPolarRadiansPoint; // @addr $802568 @note "Angle is ArcTan2(X,Y), measured from positive Y; squared radius uses signed 32-bit integer arithmetic."
function HeadingDegreesToByte(Angle: Double): Byte; // @addr $8025C8
function ByteToHeadingDegrees(Angle: Byte): Double; // @addr $8025EC
function WrapSignedHeadingDegrees(Angle: Single): Single; // @addr $8027C4 @note "Normalizes finite angles to [-180,180)."
function HeadingWithinArc(ArcStart, Heading, ArcEnd: Single): Boolean; // @addr $802820
function PushPointOutsideCircleBand(Point: TPointF; Radius, Margin: Single): TPointF; // @addr $802928 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *Result@<edx>, float Radius@<^4>, float Margin@<^0>);" @note "Within Margin of Radius, scales Point to Radius+Margin; otherwise returns Point."
function RotatePointQuarterTurn(Center, Point: TPointF): TPointF; // @addr $8029A4
function IntersectLines(A1, A2, B1, B2: TPointF; out Intersection: TPointF): Boolean; // @addr $8029DC
function SegmentIntersectsRectEdges(StartPoint, EndPoint, TopLeft, BottomRight: TPointF; out Intersection: TPointF): Boolean; // @addr $802ABC @note "Tests top, bottom, left, then right; returns the first edge hit, not the nearest. Corners must be ordered."
function SegmentIntersectsCircle(StartPoint, EndPoint, Center: TPointF; Radius: Single): Boolean; // @addr $802D6C @note "Accepts a start inside the circle; rejects tangencies."
function SegmentCrossesOriginCircle(StartPoint, EndPoint: TPointF; Radius: Single): Boolean; // @addr $802F40 @note "Requires both endpoints outside and segment length at least the start's distance from the origin."
function CalculateTangentArcOffset(StartPoint, EndPoint: TPointF; Heading, Angle: Double): Double; // @addr $8031A0 @note "Returns sin(Angle) times the radius of the circle through the endpoints tangent to Heading at StartPoint; angles are degrees."
procedure CircleTangentPoints(Point: TPointF; Radius: Single; out LeftPoint, RightPoint: TPointF); // @addr $8032D4 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *LeftPoint@<edx>, TPointF *RightPoint@<ecx>, float Radius@<^0>);"
function PointBehindHeading(Origin: TPointF; Heading, Distance: Double; Seed: Cardinal): TPointF; // @addr $8033AC @ida "void __userpurge $name(TPointF *Origin@<eax>, unsigned int Seed@<edx>, TPointF *Result@<ecx>, double Heading@<^8>, double Distance@<^0>);" @note "Seed selects a heading offset in [90,269] degrees without advancing."
function IntegerPointDistancePlusOne(PointA, PointB: TPoint): Integer; // @addr $8034E8
function MakeFloatPoint(X, Y: Integer): TPointF; // @addr $8035A4
function NormalizeTextHighlightColors(Text: WideString): WideString; // @addr $803AE4

const
  PolarDegreesToRadians: Single = 0.01745329238474369049; // @addr $8130B4

implementation

// @unit-initialization $8079F4
// @unit-finalization $803CF0

uses EC_Str, aGalaxy, Math;

{ @routine $801FAC TObjectList_Destroy }
destructor TObjectList.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;
{ @end $801FAC }

{ @routine $801FD8 TObjectList_FreeItems }
procedure TObjectList.FreeItems;
var
  i: Integer;
  Item: TObject;
begin
  for i := Count - 1 downto 0 do
  begin
    if List^[i] = nil then Continue;
    Item := List^[i];
    Delete(i);
    Item.Free;
  end;
  Clear;
end;
{ @end $801FD8 }

{ @routine $802014 RandomIntRange }
function RandomIntRange(BoundA, BoundB: Integer): Integer;
begin
  if BoundA <= BoundB then Result := Random(BoundB - BoundA + 1) + BoundA
  else Result := Random(BoundA - BoundB + 1) + BoundB;
end;
{ @end $802014 }

{ @routine $80203C SeededRandomIntRange }
function SeededRandomIntRange(BoundA, BoundB: Integer; Seed: Cardinal): Integer;
begin
  if (Galaxy <> nil) and Galaxy.IsChaoticRandomEnabled then
  begin
    if BoundA <= BoundB then Result := Random(BoundB - BoundA + 1) + BoundA
    else Result := Random(BoundA - BoundB + 1) + BoundB;
  end
  else if BoundA < BoundB then Result := Seed mod Cardinal(BoundB - BoundA + 1) + BoundA
  else Result := Seed mod Cardinal(BoundA - BoundB + 1) + BoundB;
end;
{ @end $80203C }

{ @routine $8020A4 RandomUnitFloat }
function RandomUnitFloat: Single;
begin
  Result := RandomIntRange(1, RandomFloatResolution) / RandomFloatResolution;
end;
{ @end $8020A4 }

{ @routine $8020D4 SeededRandomUnitFloat }
function SeededRandomUnitFloat(Seed: Cardinal): Single;
begin
  Result := SeededRandomIntRange(1, RandomFloatResolution, Seed) / RandomFloatResolution;
end;
{ @end $8020D4 }

{ @routine $802108 RandomFloatRange }
function RandomFloatRange(BoundA, BoundB: Double): Double;
begin
  Result := RandomIntRange(Trunc(BoundA * RandomFloatResolution + 1), Trunc(BoundB * RandomFloatResolution + 1)) / RandomFloatResolution;
end;
{ @end $802108 }

{ @routine $802160 SeededRandomFloatRange }
function SeededRandomFloatRange(Seed: Cardinal; BoundA, BoundB: Double): Double;
begin
  Result := SeededRandomIntRange(Trunc(BoundA * RandomFloatResolution + 1), Trunc(BoundB * RandomFloatResolution + 1), Seed) / RandomFloatResolution;
end;
{ @end $802160 }

{ @routine $8021BC StepRandomSeed }
function StepRandomSeed(Seed: Cardinal): Cardinal;
begin
  Result := Seed * 7981 + 567;
end;
{ @end $8021BC }

procedure AdvanceIntegerRandomSeed(var Seed: Cardinal); inline;
var OldSeed: Cardinal;
begin
  OldSeed := Seed;
  Seed := Seed * 7981 + 567 + Seed div 7981;
  if Seed = OldSeed then Seed := Seed * 7281 + 517 + Seed div 7181;
end;

{ @routine $8021C8 AdvanceRandomSeed }
function AdvanceRandomSeed(var Seed: Cardinal): Cardinal;
begin
  AdvanceIntegerRandomSeed(Seed);
  Result := Seed;
end;
{ @end $8021C8 }

{ @routine $802210 NextRandomIntRange }
function NextRandomIntRange(BoundA, BoundB: Integer; var Seed: Cardinal): Integer;
begin
  if (Galaxy <> nil) and Galaxy.IsChaoticRandomEnabled then
    Result := RandomIntRange(BoundA, BoundB)
  else
  begin
    AdvanceIntegerRandomSeed(Seed);
    if BoundA < BoundB then Result := Seed mod Cardinal(BoundB - BoundA + 1) + BoundA
    else Result := Seed mod Cardinal(BoundA - BoundB + 1) + BoundB;
  end;
end;
{ @end $802210 }

{ @routine $8022A0 NextRandomFloatRange }
function NextRandomFloatRange(BoundA, BoundB: Double; var Seed: Cardinal): Double;
var OldSeed: Cardinal;
begin
  if (Galaxy <> nil) and Galaxy.IsChaoticRandomEnabled then
    Result := RandomFloatRange(BoundA, BoundB)
  else
  begin
    OldSeed := Seed;
    Seed := Seed * 7981 + 567 + Seed div 7931;
    if Seed = OldSeed then Seed := Seed * 6281 + 317 + Seed div 7311;
    Result := SeededRandomIntRange(Trunc(BoundA * RandomFloatResolution + 1), Trunc(BoundB * RandomFloatResolution + 1), Seed) / RandomFloatResolution;
  end;
end;
{ @end $8022A0 }

{ @routine $80236C NextRandomUnitFloat }
function NextRandomUnitFloat(var Seed: Cardinal): Double;
var OldSeed: Cardinal;
begin
  if (Galaxy <> nil) and Galaxy.IsChaoticRandomEnabled then
    Result := RandomFloatRange(0, 1)
  else
  begin
    OldSeed := Seed;
    Seed := Seed * 7981 + 5671;
    if Seed = OldSeed then Seed := Seed * 5331 + 3417;
    Result := Frac(Seed / 10011001);
  end;
end;
{ @end $80236C }

{ @routine $8023F8 FractionalQuotient }
function FractionalQuotient(Numerator, Denominator: Integer): Double;
begin
  Result := Frac(Numerator / Denominator);
end;
{ @end $8023F8 }

{ @routine $80242C RoundAndTruncateToFives }
function RoundAndTruncateToFives(Value: Double): Integer;
begin
  Result := (Round(Value) div 5) * 5;
end;
{ @end $80242C }

{ @routine $802448 RoundAndTruncateToTens }
function RoundAndTruncateToTens(Value: Double): Integer;
begin
  Result := (Round(Value) div 10) * 10;
end;
{ @end $802448 }

{ @routine $802468 RoundAndTruncateToHundreds }
function RoundAndTruncateToHundreds(Value: Double): Integer;
begin
  Result := (Round(Value) div 100) * 100;
end;
{ @end $802468 }

{ @routine $802484 PointFromRadiusAngle }
function PointFromRadiusAngle(Radius, Angle: Single): TPointF;
begin
  asm
  fld Angle
  fsincos
  mov eax, Result
  fld Radius
  fmul st(1), st(0)
  fmulp st(2), st(0)
  fstp [eax].TPointF.X
  fstp [eax].TPointF.Y
  end;
end;
{ @end $802484 }

{ @routine $8024A4 OffsetPointByRadiusAngle }
function OffsetPointByRadiusAngle(Origin: TPointF; Radius, Angle: Single): TPointF;
begin
  asm
  fld Angle
  fsincos
  mov eax, Result
  fld Radius
  fmul st(1), st(0)
  fmulp st(2), st(0)
  fld Origin.X
  faddp st(1), st(0)
  fstp [eax].TPointF.X
  fld Origin.Y
  faddp st(1), st(0)
  fstp [eax].TPointF.Y
  end;
end;
{ @end $8024A4 }

{ @routine $8024DC RotateAndTranslatePoint }
function RotateAndTranslatePoint(Point, Translation: TPointF; Angle: Single): TPointF;
begin
  asm
  fld Angle
  fsincos
  fxch st(1)
  mov eax, Result
  fld Point.X
  fmul st(0), st(2)
  fld Point.Y
  fmul st(0), st(2)
  fchs
  faddp st(1), st(0)
  fld Translation.X
  faddp st(1), st(0)
  fstp [eax].TPointF.X
  fld Point.Y
  fmulp st(2), st(0)
  fld Point.X
  fmulp st(1), st(0)
  faddp st(1), st(0)
  fld Translation.Y
  faddp st(1), st(0)
  fstp [eax].TPointF.Y
  end;
end;
{ @end $8024DC }

{ @routine $802530 PolarToPoint }
function PolarToPoint(Polar: TPolarPoint): TPointF;
begin
  asm
  fld Polar.AngleDegrees
  fld PolarDegreesToRadians
  fmulp st(1), st(0)
  fsincos
  mov eax, Result
  fld Polar.Radius
  fmul st(1), st(0)
  fmulp st(2), st(0)
  fchs
  fstp [eax].TPointF.Y
  fstp [eax].TPointF.X
  end;
end;
{ @end $802530 }

{ @routine $802568 IntegerPointToPolar }
function IntegerPointToPolar(Point: TPoint): TPolarRadiansPoint;
begin
  Result.Radius := Sqrt(Point.X * Point.X + Point.Y * Point.Y);
  Result.AngleRadians := ArcTan2(Point.X, Point.Y);
end;
{ @end $802568 }

{ @routine $8025C8 HeadingDegreesToByte }
function HeadingDegreesToByte(Angle: Double): Byte;
begin
  Result := Round(Angle * 256 / 360);
end;
{ @end $8025C8 }

{ @routine $8025EC ByteToHeadingDegrees }
function ByteToHeadingDegrees(Angle: Byte): Double;
begin
  Result := Angle * (360 / 256);
end;
{ @end $8025EC }

{ @routine $802610 RadiansToHeadingDegrees }
function RadiansToHeadingDegrees(Angle: Double): Double;
begin
  Result := Angle * (180 / GamePi);
  if Result < 0 then Result := 360 + Result;
end;
{ @end $802610 }

{ @routine $80265C HeadingDegreesToRadians }
function HeadingDegreesToRadians(Angle: Double): Double;
begin
  if Angle > 180 then Angle := Angle - 360;
  Result := Angle * (GamePi / 180);
end;
{ @end $80265C }

{ @routine $8026A8 PointBearingDegrees }
function PointBearingDegrees(PointA, PointB: TPointF): Double;
begin
  Result := RadiansToHeadingDegrees(ArcTan2(PointB.X - PointA.X, -(PointB.Y - PointA.Y)));
end;
{ @end $8026A8 }

{ @routine $8026FC HeadingDifferenceDegrees }
function HeadingDifferenceDegrees(FromHeading, ToHeading: Double): Double;
begin
  Result := ToHeading - FromHeading;
  if FromHeading < 180 then
  begin
    if Result > 180 then Result := Result - 360;
  end
  else if Result < -180 then Result := 360 + Result;
end;
{ @end $8026FC }

{ @routine $80276C WrapHeadingDegrees }
function WrapHeadingDegrees(Angle: Single): Single;
begin
  while Angle >= 360 do Angle := Angle - 360;
  while Angle < 0 do Angle := 360 + Angle;
  Result := Angle;
end;
{ @end $80276C }

{ @routine $8027C4 WrapSignedHeadingDegrees }
function WrapSignedHeadingDegrees(Angle: Single): Single;
begin
  while Angle >= 180 do Angle := Angle - 360;
  while Angle < -180 do Angle := 360 + Angle;
  Result := Angle;
end;
{ @end $8027C4 }

{ @routine $802820 HeadingWithinArc }
function HeadingWithinArc(ArcStart, Heading, ArcEnd: Single): Boolean;
var A, B: Single;
begin
  A := HeadingDifferenceDegrees(ArcStart, Heading);
  B := HeadingDifferenceDegrees(ArcStart, ArcEnd);
  if ((A < 0) and (B > 0)) or ((A > 0) and (B < 0)) then
  begin
    Result := False;
    Exit;
  end;
  A := HeadingDifferenceDegrees(ArcEnd, Heading);
  B := HeadingDifferenceDegrees(ArcEnd, ArcStart);
  if ((A < 0) and (B > 0)) or ((A > 0) and (B < 0)) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
end;
{ @end $802820 }

{ @routine $802928 PushPointOutsideCircleBand }
function PushPointOutsideCircleBand(Point: TPointF; Radius, Margin: Single): TPointF;
var Distance: Single;
begin
  Distance := Sqrt(Point.X * Point.X + Point.Y * Point.Y);
  if Abs(Radius - Distance) <= Margin then
  begin
    Result.X := (Point.X / Distance) * (Radius + Margin);
    Result.Y := (Point.Y / Distance) * (Radius + Margin);
  end
  else Result := Point;
end;
{ @end $802928 }

{ @routine $8029A4 RotatePointQuarterTurn }
function RotatePointQuarterTurn(Center, Point: TPointF): TPointF;
begin
  Result.X := Center.X - (Point.Y - Center.Y);
  Result.Y := Point.X - Center.X + Center.Y;
end;
{ @end $8029A4 }

{ @routine $8029DC IntersectLines }
function IntersectLines(A1, A2, B1, B2: TPointF; out Intersection: TPointF): Boolean;
var AX, AY, BX, BY, Divisor: Double;
begin
  AX := A2.X - A1.X;
  AY := A2.Y - A1.Y;
  BX := B2.X - B1.X;
  BY := B2.Y - B1.Y;
  Divisor := AY * BX - BY * AX;
  if Divisor = 0 then
  begin
    Result := False;
    Exit;
  end;
  Intersection.X := ((B1.Y - A1.Y) * AX * BX + AY * BX * A1.X - BY * AX * B1.X) / Divisor;
  if AX <> 0 then Intersection.Y := (Intersection.X - A1.X) * AY / AX + A1.Y
  else Intersection.Y := (Intersection.X - B1.X) * BY / BX + B1.Y;
  Result := True;
end;
{ @end $8029DC }

{ @routine $802ABC SegmentIntersectsRectEdges }
function SegmentIntersectsRectEdges(StartPoint, EndPoint, TopLeft, BottomRight: TPointF; out Intersection: TPointF): Boolean;
var A, B: TPointF;
begin
  A.X := TopLeft.X;
  A.Y := TopLeft.Y;
  B.X := BottomRight.X;
  B.Y := TopLeft.Y;
  if IntersectLines(StartPoint, EndPoint, A, B, Intersection) then
    if (Intersection.X >= A.X) and (Intersection.X <= B.X) and
      (Intersection.Y >= Min(StartPoint.Y, EndPoint.Y)) and
      (Intersection.Y <= Max(StartPoint.Y, EndPoint.Y)) then
    begin
      Result := True;
      Exit;
    end;
  A.X := TopLeft.X;
  A.Y := BottomRight.Y;
  B.X := BottomRight.X;
  B.Y := BottomRight.Y;
  if IntersectLines(StartPoint, EndPoint, A, B, Intersection) then
    if (Intersection.X >= A.X) and (Intersection.X <= B.X) and
      (Intersection.Y >= Min(StartPoint.Y, EndPoint.Y)) and
      (Intersection.Y <= Max(StartPoint.Y, EndPoint.Y)) then
    begin
      Result := True;
      Exit;
    end;
  A.X := TopLeft.X;
  A.Y := TopLeft.Y;
  B.X := TopLeft.X;
  B.Y := BottomRight.Y;
  if IntersectLines(StartPoint, EndPoint, A, B, Intersection) then
    if (Intersection.Y >= A.Y) and (Intersection.Y <= B.Y) and
      (Intersection.X >= Min(StartPoint.X, EndPoint.X)) and
      (Intersection.X <= Max(StartPoint.X, EndPoint.X)) then
    begin
      Result := True;
      Exit;
    end;
  A.X := BottomRight.X;
  A.Y := TopLeft.Y;
  B.X := BottomRight.X;
  B.Y := BottomRight.Y;
  if IntersectLines(StartPoint, EndPoint, A, B, Intersection) then
    if (Intersection.Y >= A.Y) and (Intersection.Y <= B.Y) and
      (Intersection.X >= Min(StartPoint.X, EndPoint.X)) and
      (Intersection.X <= Max(StartPoint.X, EndPoint.X)) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $802ABC }

{ @routine $802D6C SegmentIntersectsCircle }
function SegmentIntersectsCircle(StartPoint, EndPoint, Center: TPointF; Radius: Single): Boolean;
var DX, DY, T1, T2, CX, CY, Projection, Discriminant, CenterDistanceSquared, SegmentLength: Single;
begin
  if Sqr(StartPoint.X - Center.X) + Sqr(StartPoint.Y - Center.Y) < Radius * Radius then
  begin
    Result := True;
    Exit;
  end;
  DX := EndPoint.X - StartPoint.X;
  DY := EndPoint.Y - StartPoint.Y;
  T1 := Sqrt(DX * DX + DY * DY);
  if T1 = 0 then
  begin
    Result := False;
    Exit;
  end;
  T1 := 1 / T1;
  DX := DX * T1;
  DY := DY * T1;
  CX := Center.X - StartPoint.X;
  CY := Center.Y - StartPoint.Y;
  CenterDistanceSquared := CX * CX + CY * CY;
  Projection := CX * DX + CY * DY;
  Discriminant := Sqr(Radius) - CenterDistanceSquared + Projection * Projection;
  if Discriminant <= 0 then
  begin
    Result := False;
    Exit;
  end;
  Discriminant := Sqrt(Discriminant);
  if Projection < Discriminant then
  begin
    T1 := Projection + Discriminant;
    T2 := Projection - Discriminant;
  end
  else
  begin
    T1 := Projection - Discriminant;
    T2 := Projection + Discriminant;
  end;
  SegmentLength := Sqrt(Sqr(StartPoint.X - EndPoint.X) + Sqr(StartPoint.Y - EndPoint.Y));
  Result := ((T1 >= 0) and (T1 <= SegmentLength)) or ((T2 >= 0) and (T2 <= SegmentLength));
end;
{ @end $802D6C }

{ @routine $802F40 SegmentCrossesOriginCircle }
function SegmentCrossesOriginCircle(StartPoint, EndPoint: TPointF; Radius: Single): Boolean;
var Delta: TPointF;
  StartDistanceSquared, Projection, LengthSquared, RadiusSquared: Single;
begin
  Result := False;
  RadiusSquared := Radius * Radius;
  StartDistanceSquared := StartPoint.X * StartPoint.X + StartPoint.Y * StartPoint.Y;
  if StartDistanceSquared < RadiusSquared then Exit;
  if EndPoint.X * EndPoint.X + EndPoint.Y * EndPoint.Y < RadiusSquared then Exit;
  Delta.X := EndPoint.X - StartPoint.X;
  Delta.Y := EndPoint.Y - StartPoint.Y;
  LengthSquared := Delta.X * Delta.X + Delta.Y * Delta.Y;
  if LengthSquared < StartDistanceSquared then Exit;
  Projection := (-StartPoint.X * Delta.X - StartPoint.Y * Delta.Y) / Sqrt(LengthSquared);
  if Projection < 0 then Result := False
  else Result := StartDistanceSquared - Projection * Projection < Radius * Radius;
end;
{ @end $802F40 }

{ @routine $803030 RayIntersectsOriginCircle }
function RayIntersectsOriginCircle(StartPoint, ThroughPoint: TPointF; out Intersection: TPointF; Radius: Single): Boolean;
var DX, DY, T1, T2, CX, CY, Projection, Discriminant, CenterDistanceSquared: Single;
begin
  DX := ThroughPoint.X - StartPoint.X;
  DY := ThroughPoint.Y - StartPoint.Y;
  T1 := 1 / Sqrt(DX * DX + DY * DY);
  DX := DX * T1;
  DY := DY * T1;
  CX := -StartPoint.X;
  CY := -StartPoint.Y;
  CenterDistanceSquared := CX * CX + CY * CY;
  Projection := CX * DX + CY * DY;
  Discriminant := Sqr(Radius) - CenterDistanceSquared + Projection * Projection;
  if Discriminant <= 0 then
  begin
    Result := False;
    Exit;
  end;
  Discriminant := Sqrt(Discriminant);
  if Projection < Discriminant then
  begin
    T1 := Projection + Discriminant;
    T2 := Projection - Discriminant;
  end
  else
  begin
    T1 := Projection - Discriminant;
    T2 := Projection + Discriminant;
  end;
  if Abs(T1) < 0.001 then T1 := T2;
  Intersection.X := DX * T1 + StartPoint.X;
  Intersection.Y := DY * T1 + StartPoint.Y;
  Result := T1 > 0.001;
end;
{ @end $803030 }

{ @routine $8031A0 CalculateTangentArcOffset }
function CalculateTangentArcOffset(StartPoint, EndPoint: TPointF; Heading, Angle: Double): Double;
var
  Center, Normal, Midpoint: TPointF;
  Radians, Radius, CentralAngle: Double;
begin
  Radians := HeadingDegreesToRadians(Heading);
  Normal.X := Sin(Radians) * 100 + StartPoint.X;
  Normal.Y := StartPoint.Y - Cos(Radians) * 100;
  Normal := RotatePointQuarterTurn(StartPoint, Normal);
  Midpoint.X := (StartPoint.X + EndPoint.X) / 2;
  Midpoint.Y := (StartPoint.Y + EndPoint.Y) / 2;
  if not IntersectLines(StartPoint, Normal, Midpoint, RotatePointQuarterTurn(Midpoint, StartPoint), Center) then
  begin
    Result := 0;
    Exit;
  end;
  Radius := PointDistance(StartPoint, Center);
  CentralAngle := 180 - (90 - Angle) * 2;
  Result := Sin(HeadingDegreesToRadians(CentralAngle / 2)) * Radius;
end;
{ @end $8031A0 }

{ @routine $8032D4 CircleTangentPoints }
procedure CircleTangentPoints(Point: TPointF; Radius: Single; out LeftPoint, RightPoint: TPointF);
var Angle, Spread, Distance: Single;
begin
  Distance := Sqrt(Point.X * Point.X + Point.Y * Point.Y);
  Spread := ArcCos(Radius / Distance);
  Angle := ArcTan2(Point.X, -Point.Y);
  LeftPoint.X := Sin(Angle + Spread) * Radius;
  LeftPoint.Y := -Cos(Angle + Spread) * Radius;
  RightPoint.X := Sin(Angle - Spread) * Radius;
  RightPoint.Y := -Cos(Angle - Spread) * Radius;
end;
{ @end $8032D4 }

{ @routine $8033AC PointBehindHeading }
function PointBehindHeading(Origin: TPointF; Heading, Distance: Double; Seed: Cardinal): TPointF;
begin
  Heading := HeadingDegreesToRadians(WrapHeadingDegrees(Heading + 180 + (Integer(Seed mod 180) - 90)));
  Result.X := Sin(Heading) * Distance + Origin.X;
  Result.Y := Origin.Y - Cos(Heading) * Distance;
end;
{ @end $8033AC }

{ @routine $80343C PointDistanceSquared }
function PointDistanceSquared(PointA, PointB: TPointF): Single;
var X, Y: Single;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := X * X + Y * Y;
end;
{ @end $80343C }

{ @routine $80348C PointDistance }
function PointDistance(PointA, PointB: TPointF): Double;
var X, Y: Single;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := Sqrt(X * X + Y * Y);
end;
{ @end $80348C }

{ @routine $8034E8 IntegerPointDistancePlusOne }
function IntegerPointDistancePlusOne(PointA, PointB: TPoint): Integer;
var X, Y: Integer;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := Trunc(Sqrt(X * X + Y * Y) + 1);
end;
{ @end $8034E8 }

{ @routine $803544 RemapClamped }
function RemapClamped(Value: Double; InMin: Double; InMax: Double; OutMin: Double; OutMax: Double): Double;
begin
  if not (Value > InMin) then
  begin
    Result := OutMin;
    Exit;
  end;
  if not (Value < InMax) then
  begin
    Result := OutMax;
    Exit;
  end;
  Result := (Value - InMin) / (InMax - InMin) * (OutMax - OutMin) + OutMin;
end;
{ @end $803544 }

{ @routine $8035A4 MakeFloatPoint }
function MakeFloatPoint(X, Y: Integer): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;
{ @end $8035A4 }

{ @routine $8035BC ReplaceTextToken }
procedure ReplaceTextToken(var Text: WideString; Token, Replacement, ColorTag: WideString);
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + EndColorTag;
  Text := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $8035BC }

{ @routine $803680 ReplaceColoredToken }
function ReplaceColoredToken(Text, Token, Replacement, ColorTag: WideString): WideString;
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + EndColorTag;
  Result := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $803680 }

{ @routine $80373C FormatText1 }
function FormatText1(Text, ColorTag, Token, Replacement: WideString): WideString;
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + EndColorTag;
  Result := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $80373C }

{ @routine $8037F8 FormatText2 }
function FormatText2(Text, ColorTag, Token1, Replacement1, Token2, Replacement2: WideString): WideString;
begin
  if ColorTag <> '' then
  begin
    Replacement1 := ColorTag + Replacement1 + EndColorTag;
    Replacement2 := ColorTag + Replacement2 + EndColorTag;
  end;
  Result := ReplaceAllWideString(ReplaceAllWideString(Text, Token1, Replacement1), Token2, Replacement2);
end;
{ @end $8037F8 }

{ @routine $8038FC FormatText3 }
function FormatText3(Text, ColorTag, Token1, Replacement1, Token2, Replacement2, Token3, Replacement3: WideString): WideString;
begin
  if ColorTag <> '' then
  begin
    Replacement1 := ColorTag + Replacement1 + EndColorTag;
    Replacement2 := ColorTag + Replacement2 + EndColorTag;
    Replacement3 := ColorTag + Replacement3 + EndColorTag;
  end;
  Result := ReplaceAllWideString(ReplaceAllWideString(ReplaceAllWideString(Text, Token1, Replacement1), Token2, Replacement2), Token3, Replacement3);
end;
{ @end $8038FC }

{ @routine $803A3C WrapTextInColor }
function WrapTextInColor(Text, ColorTag: WideString): WideString;
begin
  if (ColorTag <> '') and (Text <> '') then Result := ColorTag + Text + EndColorTag
  else Result := Text;
end;
{ @end $803A3C }

{ @routine $803AE4 NormalizeTextHighlightColors }
function NormalizeTextHighlightColors(Text: WideString): WideString;
begin
  Result := FormatText1(Text, '', MicroModuleHighPriorityColorTag, TextHighlightColorTag);
  Result := FormatText1(Result, '', GrayColorTag, TextHighlightColorTag);
  Result := FormatText1(Result, '', '<color=191,185,128>', TextHighlightColorTag);
  Result := FormatText1(Result, '', InfoNameColorTag, TextHighlightColorTag);
  Result := FormatText1(Result, '', '<color=39,172,177>', TextHighlightColorTag);
  Result := FormatText1(Result, '', InfoHullSeriesColorTag, TextHighlightColorTag);
end;
{ @end $803AE4 }

{ @routine $803CCC IncrementWrapped }
function IncrementWrapped(var Value: Integer; Minimum, Maximum: Integer): Integer;
begin
  if Value + 1 > Maximum then Value := Minimum
  else Inc(Value);
  Result := Value;
end;
{ @end $803CCC }

{ @routine $803CE0 DecrementWrappedValue }
function DecrementWrappedValue(Value, Minimum, Maximum: Integer): Integer;
begin
  if Value - 1 < Minimum then Value := Maximum
  else Dec(Value);
  Result := Value;
end;
{ @end $803CE0 }

end.
