unit aMyFunction;
// Unit bracket (inferred): .text 0x00872154..0x0087416F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

  TPolarRadiansPoint = packed record // @size $10
    AngleRadians: Double; // @offset $00
    Radius: Double; // @offset $08
  end;

var
  // Configured by GI_Main from StyleColor.InfoNameColor / InfoHullSeriesColor.
  InfoNameColorTag: WideString = DefaultInfoNameColorTag; // @addr $8830AC
  InfoHullSeriesColorTag: WideString = DefaultInfoHullSeriesColorTag; // @addr $8830B0

type
  TObjectList = class(TList) // @size 0x10
  public
    destructor Destroy; override; // @addr 0x8721BC
    procedure FreeItems; // @addr 0x8721F8 @note "Inherited Clear/Delete do not free objects."
  end;

// Integer ranges include both endpoints and accept either endpoint order.
// Seeded helpers read the supplied seed; Next helpers advance it, except in chaotic mode.
function RandomIntRange(BoundA, BoundB: Integer): Integer; // @addr 0x872258 @note "Accepts either endpoint order."
function SeededRandomIntRange(BoundA, BoundB: Integer; Seed: Cardinal): Integer; // @addr 0x87229C @note "Chaotic mode ignores Seed."
function RandomUnitFloat: Single; // @addr 0x872338 @note "One of 1000 discrete values from 0.001 through 1.0 inclusive."
function SeededRandomUnitFloat(Seed: Cardinal): Single; // @addr 0x872368 @note "Chaotic mode ignores Seed."
function RandomFloatRange(BoundA, BoundB: Double): Double; // @addr 0x8723A0 @note "Endpoints are quantized as Trunc(bound*1000+1)/1000; results have 0.001 resolution."
function SeededRandomFloatRange(Seed: Cardinal; BoundA, BoundB: Double): Double; // @addr 0x8723F8 @note "Uses RandomFloatRange's endpoint quantization; chaotic mode ignores Seed."
function StepRandomSeed(Seed: Cardinal): Cardinal; // @addr 0x872454
function AdvanceRandomSeed(var Seed: Cardinal): Cardinal; // @addr 0x872474
function NextRandomIntRange(BoundA, BoundB: Integer; var Seed: Cardinal): Integer; // @addr 0x8724E8 @note "Chaotic mode leaves Seed unchanged."
// Original source calls RndDoubleOut(BoundA, BoundB, FRndOut); see the market_match fixture evidence.
function NextRandomFloatRange(BoundA, BoundB: Double; var Seed: Cardinal): Double; // @addr 0x8725C0 @ida "double __userpurge $name@<st0>(unsigned int *Seed@<eax>, double BoundA@<^8>, double BoundB@<^0>);" @note "Uses RandomFloatRange's endpoint quantization; chaotic mode leaves Seed unchanged."
function NextRandomUnitFloat(var Seed: Cardinal): Double; // @addr 0x8726AC @note "Normally in [0,1). Chaotic mode leaves Seed unchanged and instead yields 0.001..1.001."
function RemapClamped(Value, InMin, InMax, OutMin, OutMax: Double): Double; // @addr 0x87397C

function RoundAndTruncateToTens(Value: Double): Integer; // @addr 0x8727A0 @note "Round(Value), then signed integer division by ten and multiplication by ten."

function PointDistanceSquared(PointA, PointB: TPointF): Single; // @addr 0x87387C
function PolarToPoint(Polar: TPolarPoint): TPointF; // @addr 0x872898 @note "Copies the 16-byte input; X = sin(angle)*radius, Y = -cos(angle)*radius."
function PointDistance(PointA, PointB: TPointF): Double; // @addr 0x8738C4
function RadiansToHeadingDegrees(Angle: Double): Double; // @addr 0x872988 @note "Adds 360 only once for negative angles; does not fully normalize arbitrary inputs."
function HeadingDegreesToRadians(Angle: Double): Double; // @addr 0x8729D4 @note "Subtracts 360 only once for angles above 180; does not fully normalize arbitrary inputs."
function PointBearingDegrees(PointA, PointB: TPointF): Double; // @addr 0x872A20 @note "Bearing from A to B: zero points upward and angles increase clockwise in screen coordinates."
function HeadingDifferenceDegrees(FromHeading, ToHeading: Double): Double; // @addr 0x872A70 @note "Signed shortest turn from FromHeading to ToHeading; requires headings normalized to [0,360)."
function WrapHeadingDegrees(Angle: Single): Single; // @addr 0x872AE0 @note "Repeatedly adds or subtracts 360 to reach [0,360); requires a finite value small enough for Single-precision steps to change it."

// Original unit ownership of this formatting family (aMyFunction/MessageText) is unresolved.
// ColorTag is a complete opening tag; empty disables coloring. Replacements are
// case-sensitive and append </color> even when the replacement text is empty.
procedure ReplaceTextToken(var Text: WideString; Token, Replacement, ColorTag: WideString); // @addr 0x873A04
function ReplaceColoredToken(Text, Token, Replacement, ColorTag: WideString): WideString; // @addr 0x873ACC
function FormatText1(Text, ColorTag, Token, Replacement: WideString): WideString; // @addr 0x873B88
// Multiple replacements run in order, including matches in text inserted earlier.
function FormatText2(Text, ColorTag, Token1, Replacement1, Token2, Replacement2: WideString): WideString; // @addr 0x873C44
function FormatText3(Text, ColorTag, Token1, Replacement1, Token2, Replacement2, Token3, Replacement3: WideString): WideString; // @addr 0x873D48
function WrapTextInColor(Text, ColorTag: WideString): WideString; // @addr 0x873E88 @note "Returns Text unchanged when either argument is empty."

function RayIntersectsOriginCircle(StartPoint, ThroughPoint: TPointF; out Intersection: TPointF; Radius: Single): Boolean; // @addr 0x873458 @note "Normalizes the ray direction, rejects tangencies, and returns whether the selected intersection is ahead of StartPoint. No segment-length bound."

function DecrementWrappedValue(Value, Minimum, Maximum: Integer): Integer; // @addr $874170 Returns a decremented value, wrapping below Minimum to Maximum. Value is passed by value.
function IncrementWrapped(var Value: Integer; Minimum, Maximum: Integer): Integer; // @addr 0x874138 @note "Increments Value, or resets it to Minimum when Value + 1 exceeds Maximum; returns the updated value."

function FractionalQuotient(Numerator, Denominator: Integer): Double; // @addr $872750
function RoundAndTruncateToFives(Value: Double): Integer; // @addr $87277C
function RoundAndTruncateToHundreds(Value: Double): Integer; // @addr $8727C8
function PointFromRadiusAngle(Radius, Angle: Single): TPointF; // @addr $8727EC @ida "void __userpurge $name(TPointF *Result@<eax>, float Radius@<^4>, float Angle@<^0>);" @note "Angle is in radians, measured from the positive X axis."
function OffsetPointByRadiusAngle(Origin: TPointF; Radius, Angle: Single): TPointF; // @addr $87280C @ida "void __userpurge $name(TPointF *Origin@<eax>, TPointF *Result@<edx>, float Radius@<^4>, float Angle@<^0>);"
function RotateAndTranslatePoint(Point, Translation: TPointF; Angle: Single): TPointF; // @addr $872844 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *Translation@<edx>, TPointF *Result@<ecx>, float Angle@<^0>);"
function IntegerPointToPolar(Point: TPoint): TPolarRadiansPoint; // @addr $8728D0 @note "Angle is ArcTan2(X,Y), measured from positive Y; squared radius uses signed 32-bit integer arithmetic."
function HeadingDegreesToByte(Angle: Double): Byte; // @addr $872930
function ByteToHeadingDegrees(Angle: Byte): Double; // @addr $87295C
function WrapSignedHeadingDegrees(Angle: Single): Single; // @addr $872B38 @note "Normalizes finite angles to [-180,180)."
function HeadingWithinArc(ArcStart, Heading, ArcEnd: Single): Boolean; // @addr $872B94
function PushPointOutsideCircleBand(Point: TPointF; Radius, Margin: Single): TPointF; // @addr $872CA8 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *Result@<edx>, float Radius@<^4>, float Margin@<^0>);" @note "Within Margin of Radius, scales Point to Radius+Margin; otherwise returns Point."
function RotatePointQuarterTurn(Center, Point: TPointF): TPointF; // @addr $872D2C
function IntersectLines(A1, A2, B1, B2: TPointF; out Intersection: TPointF): Boolean; // @addr $872D6C
function SegmentIntersectsRectEdges(StartPoint, EndPoint, TopLeft, BottomRight: TPointF; out Intersection: TPointF): Boolean; // @addr $872E60 @note "Tests top, bottom, left, then right; returns the first edge hit, not the nearest. Corners must be ordered."
function SegmentIntersectsCircle(StartPoint, EndPoint, Center: TPointF; Radius: Single): Boolean; // @addr $873180 @note "Accepts a start inside the circle; rejects tangencies."
function SegmentCrossesOriginCircle(StartPoint, EndPoint: TPointF; Radius: Single): Boolean; // @addr $873360 @note "Requires both endpoints outside and segment length at least the start's distance from the origin."
function CalculateTangentArcOffset(StartPoint, EndPoint: TPointF; Heading, Angle: Double): Double; // @addr $8735D0 @note "Returns sin(Angle) times the radius of the circle through the endpoints tangent to Heading at StartPoint; angles are degrees."
procedure CircleTangentPoints(Point: TPointF; Radius: Single; out LeftPoint, RightPoint: TPointF); // @addr $873704 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *LeftPoint@<edx>, TPointF *RightPoint@<ecx>, float Radius@<^0>);"
function PointBehindHeading(Origin: TPointF; Heading, Distance: Double; Seed: Cardinal): TPointF; // @addr $8737E8 @ida "void __userpurge $name(TPointF *Origin@<eax>, unsigned int Seed@<edx>, TPointF *Result@<ecx>, double Heading@<^8>, double Distance@<^0>);" @note "Seed selects a heading offset in [90,269] degrees without advancing."
function IntegerPointDistancePlusOne(PointA, PointB: TPoint): Integer; // @addr $873918
function MakeFloatPoint(X, Y: Integer): TPointF; // @addr $8739DC
function NormalizeTextHighlightColors(Text: WideString): WideString; // @addr $873F30

const
  PolarDegreesToRadians: Single = 0.01745329238474369049; // @addr $8830B4

implementation

// @unit-initialization $877AA8
// @unit-finalization $8741A0

uses EC_Str, aGalaxy, Math;

{ @routine $8721BC TObjectList_Destroy }
destructor TObjectList.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;
{ @end $8721BC }

{ @routine $8721F8 TObjectList_FreeItems }
procedure TObjectList.FreeItems;
var
  i: Integer;
  Item: TObject;
begin
  for i := Count - 1 downto 0 do
    if List^[i] <> nil then
    begin
      Item := TObject(List^[i]);
      Delete(i);
      Item.Free;
    end;
  Clear;
end;
{ @end $8721F8 }

{ @routine $872258 RandomIntRange }
function RandomIntRange(BoundA, BoundB: Integer): Integer;
begin
  if BoundA <= BoundB then Result := Random(BoundB - BoundA + 1) + BoundA
  else Result := Random(BoundA - BoundB + 1) + BoundB;
end;
{ @end $872258 }

{ @routine $87229C SeededRandomIntRange }
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
{ @end $87229C }

{ @routine $872338 RandomUnitFloat }
function RandomUnitFloat: Single;
begin
  Result := RandomIntRange(1, RandomFloatResolution) / RandomFloatResolution;
end;
{ @end $872338 }

{ @routine $872368 SeededRandomUnitFloat }
function SeededRandomUnitFloat(Seed: Cardinal): Single;
begin
  Result := SeededRandomIntRange(1, RandomFloatResolution, Seed) / RandomFloatResolution;
end;
{ @end $872368 }

{ @routine $8723A0 RandomFloatRange }
function RandomFloatRange(BoundA, BoundB: Double): Double;
begin
  Result := RandomIntRange(Trunc(BoundA * RandomFloatResolution + 1), Trunc(BoundB * RandomFloatResolution + 1)) / RandomFloatResolution;
end;
{ @end $8723A0 }

{ @routine $8723F8 SeededRandomFloatRange }
function SeededRandomFloatRange(Seed: Cardinal; BoundA, BoundB: Double): Double;
begin
  Result := SeededRandomIntRange(Trunc(BoundA * RandomFloatResolution + 1), Trunc(BoundB * RandomFloatResolution + 1), Seed) / RandomFloatResolution;
end;
{ @end $8723F8 }

{ @routine $872454 StepRandomSeed }
function StepRandomSeed(Seed: Cardinal): Cardinal;
begin
  Result := Seed * 7981 + 567;
end;
{ @end $872454 }

{ @routine $872474 AdvanceRandomSeed }
function AdvanceRandomSeed(var Seed: Cardinal): Cardinal;
var OldSeed: Cardinal;
begin
    OldSeed := Seed;
    Seed := Seed * 7981 + 567 + Seed div 7981;
    if Seed = OldSeed then Seed := Seed * 7281 + 517 + Seed div 7181;
    Result := Seed;
end;
{ @end $872474 }

{ @routine $8724E8 NextRandomIntRange }
function NextRandomIntRange(BoundA, BoundB: Integer; var Seed: Cardinal): Integer;
var OldSeed: Cardinal;
begin
  if (Galaxy <> nil) and Galaxy.IsChaoticRandomEnabled then
    Result := RandomIntRange(BoundA, BoundB)
  else
  begin
    OldSeed := Seed;
    Seed := Seed * 7981 + 567 + Seed div 7981;
    if Seed = OldSeed then Seed := Seed * 7281 + 517 + Seed div 7181;
    if BoundA < BoundB then Result := Seed mod Cardinal(BoundB - BoundA + 1) + BoundA
    else Result := Seed mod Cardinal(BoundA - BoundB + 1) + BoundB;
  end;
end;
{ @end $8724E8 }

{ @routine $8725C0 NextRandomFloatRange }
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
{ @end $8725C0 }

{ @routine $8726AC NextRandomUnitFloat }
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
{ @end $8726AC }

{ @routine $872750 FractionalQuotient }
function FractionalQuotient(Numerator, Denominator: Integer): Double;
begin
  Result := Frac(Numerator / Denominator);
end;
{ @end $872750 }

{ @routine $87277C RoundAndTruncateToFives }
function RoundAndTruncateToFives(Value: Double): Integer;
begin
  Result := (Round(Value) div 5) * 5;
end;
{ @end $87277C }

{ @routine $8727A0 RoundAndTruncateToTens }
function RoundAndTruncateToTens(Value: Double): Integer;
begin
  Result := (Round(Value) div 10) * 10;
end;
{ @end $8727A0 }

{ @routine $8727C8 RoundAndTruncateToHundreds }
function RoundAndTruncateToHundreds(Value: Double): Integer;
begin
  Result := (Round(Value) div 100) * 100;
end;
{ @end $8727C8 }

{ @routine $8727EC PointFromRadiusAngle }
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
{ @end $8727EC }

{ @routine $87280C OffsetPointByRadiusAngle }
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
{ @end $87280C }

{ @routine $872844 RotateAndTranslatePoint }
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
{ @end $872844 }

{ @routine $872898 PolarToPoint }
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
{ @end $872898 }

{ @routine $8728D0 IntegerPointToPolar }
function IntegerPointToPolar(Point: TPoint): TPolarRadiansPoint;
begin
  Result.Radius := Sqrt(Point.X * Point.X + Point.Y * Point.Y);
  Result.AngleRadians := ArcTan2(Point.X, Point.Y);
end;
{ @end $8728D0 }

{ @routine $872930 HeadingDegreesToByte }
function HeadingDegreesToByte(Angle: Double): Byte;
begin
  Result := Round(Angle * 256 / 360);
end;
{ @end $872930 }

{ @routine $87295C ByteToHeadingDegrees }
function ByteToHeadingDegrees(Angle: Byte): Double;
begin
  Result := Angle * (360 / 256);
end;
{ @end $87295C }

{ @routine $872988 RadiansToHeadingDegrees }
function RadiansToHeadingDegrees(Angle: Double): Double;
begin
  Result := Angle * (180 / GamePi);
  if Result < 0 then Result := 360 + Result;
end;
{ @end $872988 }

{ @routine $8729D4 HeadingDegreesToRadians }
function HeadingDegreesToRadians(Angle: Double): Double;
begin
  if Angle > 180 then Angle := Angle - 360;
  Result := Angle * (GamePi / 180);
end;
{ @end $8729D4 }

{ @routine $872A20 PointBearingDegrees }
function PointBearingDegrees(PointA, PointB: TPointF): Double;
begin
  Result := RadiansToHeadingDegrees(ArcTan2(PointB.X - PointA.X, -(PointB.Y - PointA.Y)));
end;
{ @end $872A20 }

{ @routine $872A70 HeadingDifferenceDegrees }
function HeadingDifferenceDegrees(FromHeading, ToHeading: Double): Double;
begin
  Result := ToHeading - FromHeading;
  if FromHeading < 180 then
  begin
    if Result > 180 then Result := Result - 360;
  end
  else if Result < -180 then Result := 360 + Result;
end;
{ @end $872A70 }

{ @routine $872AE0 WrapHeadingDegrees }
function WrapHeadingDegrees(Angle: Single): Single;
begin
  while Angle >= 360 do Angle := Angle - 360;
  while Angle < 0 do Angle := 360 + Angle;
  Result := Angle;
end;
{ @end $872AE0 }

{ @routine $872B38 WrapSignedHeadingDegrees }
function WrapSignedHeadingDegrees(Angle: Single): Single;
begin
  while Angle >= 180 do Angle := Angle - 360;
  while Angle < -180 do Angle := 360 + Angle;
  Result := Angle;
end;
{ @end $872B38 }

{ @routine $872B94 HeadingWithinArc }
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
{ @end $872B94 }

{ @routine $872CA8 PushPointOutsideCircleBand }
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
{ @end $872CA8 }

{ @routine $872D2C RotatePointQuarterTurn }
function RotatePointQuarterTurn(Center, Point: TPointF): TPointF;
begin
  Result.X := Center.X - (Point.Y - Center.Y);
  Result.Y := Point.X - Center.X + Center.Y;
end;
{ @end $872D2C }

{ @routine $872D6C IntersectLines }
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
{ @end $872D6C }

{ @routine $872E60 SegmentIntersectsRectEdges }
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
{ @end $872E60 }

{ @routine $873180 SegmentIntersectsCircle }
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
{ @end $873180 }

{ @routine $873360 SegmentCrossesOriginCircle }
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
{ @end $873360 }

{ @routine $873458 RayIntersectsOriginCircle }
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
{ @end $873458 }

{ @routine $8735D0 CalculateTangentArcOffset }
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
{ @end $8735D0 }

{ @routine $873704 CircleTangentPoints }
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
{ @end $873704 }

{ @routine $8737E8 PointBehindHeading }
function PointBehindHeading(Origin: TPointF; Heading, Distance: Double; Seed: Cardinal): TPointF;
begin
  Heading := HeadingDegreesToRadians(WrapHeadingDegrees(Heading + 180 + (Integer(Seed mod 180) - 90)));
  Result.X := Sin(Heading) * Distance + Origin.X;
  Result.Y := Origin.Y - Cos(Heading) * Distance;
end;
{ @end $8737E8 }

{ @routine $87387C PointDistanceSquared }
function PointDistanceSquared(PointA, PointB: TPointF): Single;
var X, Y: Single;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := X * X + Y * Y;
end;
{ @end $87387C }

{ @routine $8738C4 PointDistance }
function PointDistance(PointA, PointB: TPointF): Double;
var X, Y: Single;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := Sqrt(X * X + Y * Y);
end;
{ @end $8738C4 }

{ @routine $873918 IntegerPointDistancePlusOne }
function IntegerPointDistancePlusOne(PointA, PointB: TPoint): Integer;
var X, Y: Integer;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := Trunc(Sqrt(X * X + Y * Y) + 1);
end;
{ @end $873918 }

{ @routine $87397C RemapClamped }
function RemapClamped(Value: Double; InMin: Double; InMax: Double; OutMin: Double; OutMax: Double): Double;
begin
  if not ((Value > InMin)) then
  begin
    Result := OutMin;
    Exit;
  end
  else if not ((Value < InMax)) then
  begin
    Result := OutMax;
    Exit;
  end
  else
  begin
    Result := ((((Value - InMin) / (InMax - InMin)) * (OutMax - OutMin)) + OutMin);
    Exit;
  end;
end;
{ @end $87397C }

{ @routine $8739DC MakeFloatPoint }
function MakeFloatPoint(X, Y: Integer): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;
{ @end $8739DC }

{ @routine $873A04 ReplaceTextToken }
procedure ReplaceTextToken(var Text: WideString; Token, Replacement, ColorTag: WideString);
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + EndColorTag;
  Text := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $873A04 }

{ @routine $873ACC ReplaceColoredToken }
function ReplaceColoredToken(Text, Token, Replacement, ColorTag: WideString): WideString;
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + EndColorTag;
  Result := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $873ACC }

{ @routine $873B88 FormatText1 }
function FormatText1(Text, ColorTag, Token, Replacement: WideString): WideString;
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + EndColorTag;
  Result := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $873B88 }

{ @routine $873C44 FormatText2 }
function FormatText2(Text, ColorTag, Token1, Replacement1, Token2, Replacement2: WideString): WideString;
begin
  if ColorTag <> '' then
  begin
    Replacement1 := ColorTag + Replacement1 + EndColorTag;
    Replacement2 := ColorTag + Replacement2 + EndColorTag;
  end;
  Result := ReplaceAllWideString(ReplaceAllWideString(Text, Token1, Replacement1), Token2, Replacement2);
end;
{ @end $873C44 }

{ @routine $873D48 FormatText3 }
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
{ @end $873D48 }

{ @routine $873E88 WrapTextInColor }
function WrapTextInColor(Text, ColorTag: WideString): WideString;
begin
  if (ColorTag <> '') and (Text <> '') then Result := ColorTag + Text + EndColorTag
  else Result := Text;
end;
{ @end $873E88 }

{ @routine $873F30 NormalizeTextHighlightColors }
function NormalizeTextHighlightColors(Text: WideString): WideString;
begin
  Result := FormatText1(Text, '', MicroModuleHighPriorityColorTag, TextHighlightColorTag);
  Result := FormatText1(Result, '', GrayColorTag, TextHighlightColorTag);
  Result := FormatText1(Result, '', '<color=191,185,128>', TextHighlightColorTag);
  Result := FormatText1(Result, '', InfoNameColorTag, TextHighlightColorTag);
  Result := FormatText1(Result, '', '<color=39,172,177>', TextHighlightColorTag);
  Result := FormatText1(Result, '', InfoHullSeriesColorTag, TextHighlightColorTag);
end;
{ @end $873F30 }

{ @routine $874138 IncrementWrapped }
function IncrementWrapped(var Value: Integer; Minimum, Maximum: Integer): Integer;
begin
  if Value + 1 > Maximum then Value := Minimum
  else Inc(Value);
  Result := Value;
end;
{ @end $874138 }

{ @routine $874170 DecrementWrappedValue }
function DecrementWrappedValue(Value, Minimum, Maximum: Integer): Integer;
begin
  if Value - 1 < Minimum then Value := Maximum
  else Dec(Value);
  Result := Value;
end;
{ @end $874170 }

end.
