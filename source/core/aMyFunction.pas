unit aMyFunction;
// Unit bracket (inferred): .text 0x00871184..0x0087319F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, Classes, Types;

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
  InfoNameColorTag: WideString = '<color=57,239,255>'; // @addr $8820AC
  InfoHullSeriesColorTag: WideString = '<color=82,166,255>'; // @addr $8820B0

type
  TObjectList = class(TList) // @size 0x10
  public
    destructor Destroy; override; // @addr 0x8711EC @ida "void __usercall $name(TObjectList *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure FreeItems; // @addr 0x871228 @note "Inherited Clear/Delete do not free objects."
  end;

// Integer ranges include both endpoints and accept either endpoint order.
// Seeded helpers read the supplied seed; Next helpers advance it, except in chaotic mode.
function RandomIntRange(BoundA, BoundB: Integer): Integer; // @addr 0x871288 @note "Accepts either endpoint order."
function SeededRandomIntRange(BoundA, BoundB: Integer; Seed: Cardinal): Integer; // @addr 0x8712CC @note "Chaotic mode ignores Seed."
function RandomUnitFloat: Single; // @addr 0x871368 @note "One of 1000 discrete values from 0.001 through 1.0 inclusive."
function SeededRandomUnitFloat(Seed: Cardinal): Single; // @addr 0x871398 @note "Chaotic mode ignores Seed."
function RandomFloatRange(BoundA, BoundB: Double): Double; // @addr 0x8713D0 @ida "double __userpurge $name@<st0>(double BoundA@<^8>, double BoundB@<^0>);" @note "Endpoints are quantized as Trunc(bound*1000+1)/1000; results have 0.001 resolution."
function SeededRandomFloatRange(Seed: Cardinal; BoundA, BoundB: Double): Double; // @addr 0x871428 @ida "double __userpurge $name@<st0>(unsigned int Seed@<eax>, double BoundA@<^8>, double BoundB@<^0>);" @note "Uses RandomFloatRange's endpoint quantization; chaotic mode ignores Seed."
function StepRandomSeed(Seed: Cardinal): Cardinal; // @addr 0x871484
function AdvanceRandomSeed(var Seed: Cardinal): Cardinal; // @addr 0x8714A4
function NextRandomIntRange(BoundA, BoundB: Integer; var Seed: Cardinal): Integer; // @addr 0x871518 @note "Chaotic mode leaves Seed unchanged."
// Original source calls RndDoubleOut(BoundA, BoundB, FRndOut); see the market_match fixture evidence.
function NextRandomFloatRange(BoundA, BoundB: Double; var Seed: Cardinal): Double; // @addr 0x8715F0 @ida "double __userpurge $name@<st0>(unsigned int *Seed@<eax>, double BoundA@<^8>, double BoundB@<^0>);" @note "Uses RandomFloatRange's endpoint quantization; chaotic mode leaves Seed unchanged."
function NextRandomUnitFloat(var Seed: Cardinal): Double; // @addr 0x8716DC @note "Normally in [0,1). Chaotic mode leaves Seed unchanged and instead yields 0.001..1.001."
function RemapClamped(Value, InMin, InMax, OutMin, OutMax: Double): Double; // @addr 0x8729AC @ida "double __userpurge $name@<st0>(double Value@<^32>, double InMin@<^24>, double InMax@<^16>, double OutMin@<^8>, double OutMax@<^0>);"

function RoundAndTruncateToTens(Value: Double): Integer; // @addr 0x8717D0 @ida "int __userpurge $name@<eax>(double Value@<^0>);" @note "Round(Value), then signed integer division by ten and multiplication by ten."

function PointDistanceSquared(PointA, PointB: TPointF): Single; // @addr 0x8728AC @ida "float __usercall $name@<st0>(TPointF *PointA@<eax>, TPointF *PointB@<edx>);"
function PolarToPoint(Polar: TPolarPoint): TPointF; // @addr 0x8718C8 @ida "void __usercall $name(TPolarPoint *Polar@<eax>, TPointF *Result@<edx>);" @note "Copies the 16-byte input; X = sin(angle)*radius, Y = -cos(angle)*radius."
function PointDistance(PointA, PointB: TPointF): Double; // @addr 0x8728F4 @ida "double __usercall $name@<st0>(TPointF *PointA@<eax>, TPointF *PointB@<edx>);"
function RadiansToHeadingDegrees(Angle: Double): Double; // @addr 0x8719B8 @ida "double __userpurge $name@<st0>(double Angle@<^0>);" @note "Adds 360 only once for negative angles; does not fully normalize arbitrary inputs."
function HeadingDegreesToRadians(Angle: Double): Double; // @addr 0x871A04 @ida "double __userpurge $name@<st0>(double Angle@<^0>);" @note "Subtracts 360 only once for angles above 180; does not fully normalize arbitrary inputs."
function PointBearingDegrees(PointA, PointB: TPointF): Double; // @addr 0x871A50 @ida "double __usercall $name@<st0>(TPointF *PointA@<eax>, TPointF *PointB@<edx>);" @note "Bearing from A to B: zero points upward and angles increase clockwise in screen coordinates."
function HeadingDifferenceDegrees(FromHeading, ToHeading: Double): Double; // @addr 0x871AA0 @ida "double __userpurge $name@<st0>(double FromHeading@<^8>, double ToHeading@<^0>);" @note "Signed shortest turn from FromHeading to ToHeading; requires headings normalized to [0,360)."
function WrapHeadingDegrees(Angle: Single): Single; // @addr 0x871B10 @ida "float __userpurge $name@<st0>(float Angle@<^0>);" @note "Repeatedly adds or subtracts 360 to reach [0,360); requires a finite value small enough for Single-precision steps to change it."

// Original unit ownership of this formatting family (aMyFunction/MessageText) is unresolved.
// ColorTag is a complete opening tag; empty disables coloring. Replacements are
// case-sensitive and append </color> even when the replacement text is empty.
procedure ReplaceTextToken(var Text: WideString; Token, Replacement, ColorTag: WideString); // @addr 0x872A34
function ReplaceColoredToken(Text, Token, Replacement, ColorTag: WideString): WideString; // @addr 0x872AFC @ida "void __userpurge $name(unsigned __int16 *Text@<eax>, unsigned __int16 *Token@<edx>, unsigned __int16 *Replacement@<ecx>, unsigned __int16 *ColorTag@<^4>, unsigned __int16 **Result@<^0>);"
function FormatText1(Text, ColorTag, Token, Replacement: WideString): WideString; // @addr 0x872BB8 @ida "void __userpurge $name(unsigned __int16 *Text@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 *Token@<ecx>, unsigned __int16 *Replacement@<^4>, unsigned __int16 **Result@<^0>);"
// Multiple replacements run in order, including matches in text inserted earlier.
function FormatText2(Text, ColorTag, Token1, Replacement1, Token2, Replacement2: WideString): WideString; // @addr 0x872C74 @ida "void __userpurge $name(unsigned __int16 *Text@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 *Token1@<ecx>, unsigned __int16 *Replacement1@<^12>, unsigned __int16 *Token2@<^8>, unsigned __int16 *Replacement2@<^4>, unsigned __int16 **Result@<^0>);"
function FormatText3(Text, ColorTag, Token1, Replacement1, Token2, Replacement2, Token3, Replacement3: WideString): WideString; // @addr 0x872D78 @ida "void __userpurge $name(unsigned __int16 *Text@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 *Token1@<ecx>, unsigned __int16 *Replacement1@<^20>, unsigned __int16 *Token2@<^16>, unsigned __int16 *Replacement2@<^12>, unsigned __int16 *Token3@<^8>, unsigned __int16 *Replacement3@<^4>, unsigned __int16 **Result@<^0>);"
function WrapTextInColor(Text, ColorTag: WideString): WideString; // @addr 0x872EB8 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, unsigned __int16 *ColorTag@<edx>, unsigned __int16 **Result@<ecx>);" @note "Returns Text unchanged when either argument is empty."

function RayIntersectsOriginCircle(StartPoint, ThroughPoint: TPointF; out Intersection: TPointF; Radius: Single): Boolean; // @addr 0x872488 @ida "bool __userpurge $name@<al>(TPointF *StartPoint@<eax>, TPointF *ThroughPoint@<edx>, TPointF *Intersection@<ecx>, float Radius@<^0>);" @note "Normalizes the ray direction, rejects tangencies, and returns whether the selected intersection is ahead of StartPoint. No segment-length bound."

function DecrementWrappedValue(Value, Minimum, Maximum: Integer): Integer; // @addr $8731A0 Returns a decremented value, wrapping below Minimum to Maximum. Value is passed by value.
function IncrementWrapped(var Value: Integer; Minimum, Maximum: Integer): Integer; // @addr 0x873168 @note "Increments Value, or resets it to Minimum when Value + 1 exceeds Maximum; returns the updated value."

function FractionalQuotient(Numerator, Denominator: Integer): Double; // @addr $871780
function RoundAndTruncateToFives(Value: Double): Integer; // @addr $8717AC @ida "int __userpurge $name@<eax>(double Value@<^0>);"
function RoundAndTruncateToHundreds(Value: Double): Integer; // @addr $8717F8 @ida "int __userpurge $name@<eax>(double Value@<^0>);"
function PointFromRadiusAngle(Radius, Angle: Single): TPointF; // @addr $87181C @ida "void __userpurge $name(TPointF *Result@<eax>, float Radius@<^4>, float Angle@<^0>);" @note "Angle is in radians, measured from the positive X axis."
function OffsetPointByRadiusAngle(Origin: TPointF; Radius, Angle: Single): TPointF; // @addr $87183C @ida "void __userpurge $name(TPointF *Origin@<eax>, TPointF *Result@<edx>, float Radius@<^4>, float Angle@<^0>);"
function RotateAndTranslatePoint(Point, Translation: TPointF; Angle: Single): TPointF; // @addr $871874 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *Translation@<edx>, TPointF *Result@<ecx>, float Angle@<^0>);"
function IntegerPointToPolar(Point: TPoint): TPolarRadiansPoint; // @addr $871900 @ida "void __usercall $name(TPoint *Point@<eax>, TPolarRadiansPoint *Result@<edx>);" @note "Angle is ArcTan2(X,Y), measured from positive Y; squared radius uses signed 32-bit integer arithmetic."
function HeadingDegreesToByte(Angle: Double): Byte; // @addr $871960 @ida "unsigned __int8 __userpurge $name@<al>(double Angle@<^0>);"
function ByteToHeadingDegrees(Angle: Byte): Double; // @addr $87198C
function WrapSignedHeadingDegrees(Angle: Single): Single; // @addr $871B68 @ida "float __userpurge $name@<st0>(float Angle@<^0>);" @note "Normalizes finite angles to [-180,180)."
function HeadingWithinArc(ArcStart, Heading, ArcEnd: Single): Boolean; // @addr $871BC4 @ida "bool __userpurge $name@<al>(float ArcStart@<^8>, float Heading@<^4>, float ArcEnd@<^0>);"
function PushPointOutsideCircleBand(Point: TPointF; Radius, Margin: Single): TPointF; // @addr $871CD8 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *Result@<edx>, float Radius@<^4>, float Margin@<^0>);" @note "Within Margin of Radius, scales Point to Radius+Margin; otherwise returns Point."
function RotatePointQuarterTurn(Center, Point: TPointF): TPointF; // @addr $871D5C @ida "void __usercall $name(TPointF *Center@<eax>, TPointF *Point@<edx>, TPointF *Result@<ecx>);"
function IntersectLines(A1, A2, B1, B2: TPointF; out Intersection: TPointF): Boolean; // @addr $871D9C @ida "bool __userpurge $name@<al>(TPointF *A1@<eax>, TPointF *A2@<edx>, TPointF *B1@<ecx>, TPointF *B2@<^4>, TPointF *Intersection@<^0>);"
function SegmentIntersectsRectEdges(StartPoint, EndPoint, TopLeft, BottomRight: TPointF; out Intersection: TPointF): Boolean; // @addr $871E90 @ida "bool __userpurge $name@<al>(TPointF *StartPoint@<eax>, TPointF *EndPoint@<edx>, TPointF *TopLeft@<ecx>, TPointF *BottomRight@<^4>, TPointF *Intersection@<^0>);" @note "Tests top, bottom, left, then right; returns the first edge hit, not the nearest. Corners must be ordered."
function SegmentIntersectsCircle(StartPoint, EndPoint, Center: TPointF; Radius: Single): Boolean; // @addr $8721B0 @ida "bool __userpurge $name@<al>(TPointF *StartPoint@<eax>, TPointF *EndPoint@<edx>, TPointF *Center@<ecx>, float Radius@<^0>);" @note "Accepts a start inside the circle; rejects tangencies."
function SegmentCrossesOriginCircle(StartPoint, EndPoint: TPointF; Radius: Single): Boolean; // @addr $872390 @ida "bool __userpurge $name@<al>(TPointF *StartPoint@<eax>, TPointF *EndPoint@<edx>, float Radius@<^0>);" @note "Requires both endpoints outside and segment length at least the start's distance from the origin."
function CalculateTangentArcOffset(StartPoint, EndPoint: TPointF; Heading, Angle: Double): Double; // @addr $872600 @ida "double __userpurge $name@<st0>(TPointF *StartPoint@<eax>, TPointF *EndPoint@<edx>, double Heading@<^8>, double Angle@<^0>);" @note "Returns sin(Angle) times the radius of the circle through the endpoints tangent to Heading at StartPoint; angles are degrees."
procedure CircleTangentPoints(Point: TPointF; Radius: Single; out LeftPoint, RightPoint: TPointF); // @addr $872734 @ida "void __userpurge $name(TPointF *Point@<eax>, TPointF *LeftPoint@<edx>, TPointF *RightPoint@<ecx>, float Radius@<^0>);"
function PointBehindHeading(Origin: TPointF; Heading, Distance: Double; Seed: Cardinal): TPointF; // @addr $872818 @ida "void __userpurge $name(TPointF *Origin@<eax>, unsigned int Seed@<edx>, TPointF *Result@<ecx>, double Heading@<^8>, double Distance@<^0>);" @note "Seed selects a heading offset in [90,269] degrees without advancing."
function IntegerPointDistancePlusOne(PointA, PointB: TPoint): Integer; // @addr $872948 @ida "int __usercall $name@<eax>(TPoint *PointA@<eax>, TPoint *PointB@<edx>);"
function MakeFloatPoint(X, Y: Integer): TPointF; // @addr $872A0C @ida "void __usercall $name(int X@<eax>, int Y@<edx>, TPointF *Result@<ecx>);"
function NormalizeTextHighlightColors(Text: WideString): WideString; // @addr $872F60 @ida "void __usercall $name(unsigned __int16 *Text@<eax>, unsigned __int16 **Result@<edx>);"

const
  PolarDegreesToRadians: Single = 0.01745329238474369049; // @addr $8820B4

implementation

// @unit-initialization $876AA0
// @unit-finalization $8731D0

uses EC_Str, aGalaxy, Math;

{ @routine $8711EC TObjectList_Destroy }
destructor TObjectList.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;
{ @end $8711EC }

{ @routine $871228 TObjectList_FreeItems }
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
{ @end $871228 }

{ @routine $871288 RandomIntRange }
function RandomIntRange(BoundA, BoundB: Integer): Integer;
begin
  if BoundA <= BoundB then Result := Random(BoundB - BoundA + 1) + BoundA
  else Result := Random(BoundA - BoundB + 1) + BoundB;
end;
{ @end $871288 }

{ @routine $8712CC SeededRandomIntRange }
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
{ @end $8712CC }

{ @routine $871368 RandomUnitFloat }
function RandomUnitFloat: Single;
begin
  Result := RandomIntRange(1, 1000) / 1000;
end;
{ @end $871368 }

{ @routine $871398 SeededRandomUnitFloat }
function SeededRandomUnitFloat(Seed: Cardinal): Single;
begin
  Result := SeededRandomIntRange(1, 1000, Seed) / 1000;
end;
{ @end $871398 }

{ @routine $8713D0 RandomFloatRange }
function RandomFloatRange(BoundA, BoundB: Double): Double;
begin
  Result := RandomIntRange(Trunc(BoundA * 1000 + 1), Trunc(BoundB * 1000 + 1)) / 1000;
end;
{ @end $8713D0 }

{ @routine $871428 SeededRandomFloatRange }
function SeededRandomFloatRange(Seed: Cardinal; BoundA, BoundB: Double): Double;
begin
  Result := SeededRandomIntRange(Trunc(BoundA * 1000 + 1), Trunc(BoundB * 1000 + 1), Seed) / 1000;
end;
{ @end $871428 }

{ @routine $871484 StepRandomSeed }
function StepRandomSeed(Seed: Cardinal): Cardinal;
begin
  Result := Seed * 7981 + 567;
end;
{ @end $871484 }

{ @routine $8714A4 AdvanceRandomSeed }
function AdvanceRandomSeed(var Seed: Cardinal): Cardinal;
var OldSeed: Cardinal;
begin
    OldSeed := Seed;
    Seed := Seed * 7981 + 567 + Seed div 7981;
    if Seed = OldSeed then Seed := Seed * 7281 + 517 + Seed div 7181;
    Result := Seed;
end;
{ @end $8714A4 }

{ @routine $871518 NextRandomIntRange }
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
{ @end $871518 }

{ @routine $8715F0 NextRandomFloatRange }
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
    Result := SeededRandomIntRange(Trunc(BoundA * 1000 + 1), Trunc(BoundB * 1000 + 1), Seed) / 1000;
  end;
end;
{ @end $8715F0 }

{ @routine $8716DC NextRandomUnitFloat }
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
{ @end $8716DC }

{ @routine $871780 FractionalQuotient }
function FractionalQuotient(Numerator, Denominator: Integer): Double;
begin
  Result := Frac(Numerator / Denominator);
end;
{ @end $871780 }

{ @routine $8717AC RoundAndTruncateToFives }
function RoundAndTruncateToFives(Value: Double): Integer;
begin
  Result := (Round(Value) div 5) * 5;
end;
{ @end $8717AC }

{ @routine $8717D0 RoundAndTruncateToTens }
function RoundAndTruncateToTens(Value: Double): Integer;
begin
  Result := (Round(Value) div 10) * 10;
end;
{ @end $8717D0 }

{ @routine $8717F8 RoundAndTruncateToHundreds }
function RoundAndTruncateToHundreds(Value: Double): Integer;
begin
  Result := (Round(Value) div 100) * 100;
end;
{ @end $8717F8 }

{ @routine $87181C PointFromRadiusAngle }
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
{ @end $87181C }

{ @routine $87183C OffsetPointByRadiusAngle }
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
{ @end $87183C }

{ @routine $871874 RotateAndTranslatePoint }
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
{ @end $871874 }

{ @routine $8718C8 PolarToPoint }
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
{ @end $8718C8 }

{ @routine $871900 IntegerPointToPolar }
function IntegerPointToPolar(Point: TPoint): TPolarRadiansPoint;
begin
  Result.Radius := Sqrt(Point.X * Point.X + Point.Y * Point.Y);
  Result.AngleRadians := ArcTan2(Point.X, Point.Y);
end;
{ @end $871900 }

{ @routine $871960 HeadingDegreesToByte }
function HeadingDegreesToByte(Angle: Double): Byte;
begin
  Result := Round(Angle * 256 / 360);
end;
{ @end $871960 }

{ @routine $87198C ByteToHeadingDegrees }
function ByteToHeadingDegrees(Angle: Byte): Double;
begin
  Result := Angle * (360 / 256);
end;
{ @end $87198C }

{ @routine $8719B8 RadiansToHeadingDegrees }
function RadiansToHeadingDegrees(Angle: Double): Double;
begin
  Result := Angle * (180 / 3.1415926);
  if Result < 0 then Result := 360 + Result;
end;
{ @end $8719B8 }

{ @routine $871A04 HeadingDegreesToRadians }
function HeadingDegreesToRadians(Angle: Double): Double;
begin
  if Angle > 180 then Angle := Angle - 360;
  Result := Angle * (3.1415926 / 180);
end;
{ @end $871A04 }

{ @routine $871A50 PointBearingDegrees }
function PointBearingDegrees(PointA, PointB: TPointF): Double;
begin
  Result := RadiansToHeadingDegrees(ArcTan2(PointB.X - PointA.X, -(PointB.Y - PointA.Y)));
end;
{ @end $871A50 }

{ @routine $871AA0 HeadingDifferenceDegrees }
function HeadingDifferenceDegrees(FromHeading, ToHeading: Double): Double;
begin
  Result := ToHeading - FromHeading;
  if FromHeading < 180 then
  begin
    if Result > 180 then Result := Result - 360;
  end
  else if Result < -180 then Result := 360 + Result;
end;
{ @end $871AA0 }

{ @routine $871B10 WrapHeadingDegrees }
function WrapHeadingDegrees(Angle: Single): Single;
begin
  while Angle >= 360 do Angle := Angle - 360;
  while Angle < 0 do Angle := 360 + Angle;
  Result := Angle;
end;
{ @end $871B10 }

{ @routine $871B68 WrapSignedHeadingDegrees }
function WrapSignedHeadingDegrees(Angle: Single): Single;
begin
  while Angle >= 180 do Angle := Angle - 360;
  while Angle < -180 do Angle := 360 + Angle;
  Result := Angle;
end;
{ @end $871B68 }

{ @routine $871BC4 HeadingWithinArc }
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
{ @end $871BC4 }

{ @routine $871CD8 PushPointOutsideCircleBand }
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
{ @end $871CD8 }

{ @routine $871D5C RotatePointQuarterTurn }
function RotatePointQuarterTurn(Center, Point: TPointF): TPointF;
begin
  Result.X := Center.X - (Point.Y - Center.Y);
  Result.Y := Point.X - Center.X + Center.Y;
end;
{ @end $871D5C }

{ @routine $871D9C IntersectLines }
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
{ @end $871D9C }

{ @routine $871E90 SegmentIntersectsRectEdges }
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
{ @end $871E90 }

{ @routine $8721B0 SegmentIntersectsCircle }
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
{ @end $8721B0 }

{ @routine $872390 SegmentCrossesOriginCircle }
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
{ @end $872390 }

{ @routine $872488 RayIntersectsOriginCircle }
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
{ @end $872488 }

{ @routine $872600 CalculateTangentArcOffset }
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
{ @end $872600 }

{ @routine $872734 CircleTangentPoints }
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
{ @end $872734 }

{ @routine $872818 PointBehindHeading }
function PointBehindHeading(Origin: TPointF; Heading, Distance: Double; Seed: Cardinal): TPointF;
begin
  Heading := HeadingDegreesToRadians(WrapHeadingDegrees(Heading + 180 + (Integer(Seed mod 180) - 90)));
  Result.X := Sin(Heading) * Distance + Origin.X;
  Result.Y := Origin.Y - Cos(Heading) * Distance;
end;
{ @end $872818 }

{ @routine $8728AC PointDistanceSquared }
function PointDistanceSquared(PointA, PointB: TPointF): Single;
var X, Y: Single;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := X * X + Y * Y;
end;
{ @end $8728AC }

{ @routine $8728F4 PointDistance }
function PointDistance(PointA, PointB: TPointF): Double;
var X, Y: Single;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := Sqrt(X * X + Y * Y);
end;
{ @end $8728F4 }

{ @routine $872948 IntegerPointDistancePlusOne }
function IntegerPointDistancePlusOne(PointA, PointB: TPoint): Integer;
var X, Y: Integer;
begin
  X := PointA.X - PointB.X;
  Y := PointA.Y - PointB.Y;
  Result := Trunc(Sqrt(X * X + Y * Y) + 1);
end;
{ @end $872948 }

{ @routine $8729AC RemapClamped }
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
{ @end $8729AC }

{ @routine $872A0C MakeFloatPoint }
function MakeFloatPoint(X, Y: Integer): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;
{ @end $872A0C }

{ @routine $872A34 ReplaceTextToken }
procedure ReplaceTextToken(var Text: WideString; Token, Replacement, ColorTag: WideString);
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + '</color>';
  Text := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $872A34 }

{ @routine $872AFC ReplaceColoredToken }
function ReplaceColoredToken(Text, Token, Replacement, ColorTag: WideString): WideString;
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + '</color>';
  Result := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $872AFC }

{ @routine $872BB8 FormatText1 }
function FormatText1(Text, ColorTag, Token, Replacement: WideString): WideString;
begin
  if ColorTag <> '' then Replacement := ColorTag + Replacement + '</color>';
  Result := ReplaceAllWideString(Text, Token, Replacement);
end;
{ @end $872BB8 }

{ @routine $872C74 FormatText2 }
function FormatText2(Text, ColorTag, Token1, Replacement1, Token2, Replacement2: WideString): WideString;
begin
  if ColorTag <> '' then
  begin
    Replacement1 := ColorTag + Replacement1 + '</color>';
    Replacement2 := ColorTag + Replacement2 + '</color>';
  end;
  Result := ReplaceAllWideString(ReplaceAllWideString(Text, Token1, Replacement1), Token2, Replacement2);
end;
{ @end $872C74 }

{ @routine $872D78 FormatText3 }
function FormatText3(Text, ColorTag, Token1, Replacement1, Token2, Replacement2, Token3, Replacement3: WideString): WideString;
begin
  if ColorTag <> '' then
  begin
    Replacement1 := ColorTag + Replacement1 + '</color>';
    Replacement2 := ColorTag + Replacement2 + '</color>';
    Replacement3 := ColorTag + Replacement3 + '</color>';
  end;
  Result := ReplaceAllWideString(ReplaceAllWideString(ReplaceAllWideString(Text, Token1, Replacement1), Token2, Replacement2), Token3, Replacement3);
end;
{ @end $872D78 }

{ @routine $872EB8 WrapTextInColor }
function WrapTextInColor(Text, ColorTag: WideString): WideString;
begin
  if (ColorTag <> '') and (Text <> '') then Result := ColorTag + Text + '</color>'
  else Result := Text;
end;
{ @end $872EB8 }

{ @routine $872F60 NormalizeTextHighlightColors }
function NormalizeTextHighlightColors(Text: WideString): WideString;
begin
  Result := FormatText1(Text, '', '<color=17,139,255>', '<color=255,240,100>');
  Result := FormatText1(Result, '', '<color=127,127,127>', '<color=255,240,100>');
  Result := FormatText1(Result, '', '<color=191,185,128>', '<color=255,240,100>');
  Result := FormatText1(Result, '', InfoNameColorTag, '<color=255,240,100>');
  Result := FormatText1(Result, '', '<color=39,172,177>', '<color=255,240,100>');
  Result := FormatText1(Result, '', InfoHullSeriesColorTag, '<color=255,240,100>');
end;
{ @end $872F60 }

{ @routine $873168 IncrementWrapped }
function IncrementWrapped(var Value: Integer; Minimum, Maximum: Integer): Integer;
begin
  if Value + 1 > Maximum then Value := Minimum
  else Inc(Value);
  Result := Value;
end;
{ @end $873168 }

{ @routine $8731A0 DecrementWrappedValue }
function DecrementWrappedValue(Value, Minimum, Maximum: Integer): Integer;
begin
  if Value - 1 < Minimum then Value := Maximum
  else Dec(Value);
  Result := Value;
end;
{ @end $8731A0 }

end.
