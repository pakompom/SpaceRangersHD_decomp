unit ab_StopLine;
// Unit bracket (inferred): .text 0x0068A540..0x0068BBE3; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008758E8..0x008758EF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native stop-point/line region: $68A540..$68BBE3, including compiler-managed finalization.

interface

uses EC_Buf, EC_Struct, GI_PolyLine, GI_Tail, ab_Global, ab_WorldImage, ab_WorldLine;

type
  PabStopPoint = ^TabStopPoint;
  TabStopPoint = record // @size $70
    Prev: PabStopPoint; // @offset $00
    Next: PabStopPoint; // @offset $04
    Longitude: Double; // @offset $08
    PolarAngle: Double; // @offset $10
    Radius: Single; // @offset $18
    Position: TVector3D; // @offset $20
    ScreenX: Integer; // @offset $38
    ScreenY: Integer; // @offset $3C
    Projected: Boolean; // @offset $40
    Kind: Integer; // @offset $44  Set to 1 by the latitude-ring builder; wider meaning unresolved.
    WorldImage: PabWorldImage; // @offset $48
    Segments: array[0..3] of PPolyLineSegmentGI; // @offset $54
  end;
  TabStopPointArray = array of PabStopPoint;

  PabStopLine = ^TabStopLine;
  TabStopLine = record // @size $34
    Prev: PabStopLine; // @offset $00
    Next: PabStopLine; // @offset $04
    NextCollision: PabStopLine; // @offset $08
    UserValue: Integer; // @offset $0C
    First: PabStopPoint; // @offset $10
    Last: PabStopPoint; // @offset $14
    FirstColor: PCardinal; // @offset $18
    LastColor: PCardinal; // @offset $1C
    WorldLine: PabWorldLine; // @offset $20
    Collidable: Boolean; // @offset $24
    Visible: Boolean; // @offset $25
    Segments: array[0..1] of PPolyLineSegmentGI; // @offset $28
  end;

procedure ab_StopPoint_Clear; // @addr $68A560
function ab_StopPoint_Add: PabStopPoint; // @addr $68A598 @note "Allocates and links a node owned by the world list."
procedure ab_StopPoint_Delete(Point: PabStopPoint); // @addr $68A66C
procedure ab_StopPoint_UpdatePosition(Point: PabStopPoint); // @addr $68A75C @note "Nil updates every point."
procedure ab_StopPoint_ClearImages; // @addr $68A834
procedure ab_StopPoint_ClearSegments(Point: PabStopPoint); // @addr $68A874
procedure ab_StopPoint_BuildIndex; // @addr $68A8C4
procedure ab_StopPoint_ClearIndex; // @addr $68A92C
function ab_StopPoint_Count: Integer; // @addr $68A940
procedure ab_StopLine_Clear; // @addr $68A974
function ab_StopLine_Add: PabStopLine; // @addr $68A9A8 @note "Allocates and links a node owned by the world list."
procedure ab_StopLine_Delete(Line: PabStopLine); // @addr $68AA84
procedure ab_StopLine_AddLatitude(PolarAngle, Step: Double); // @addr $68AB30 @ida "void __userpurge $name(double PolarAngle@<^8>, double Step@<^0>);"
procedure ab_StopLine_UpdateWorldLines; // @addr $68AC14
procedure ab_StopLine_UpdateColors; // @addr $68ACF8
procedure ab_StopLine_ClearSegments(Line: PabStopLine); // @addr $68AD48
procedure ab_StopLine_PrepareCollision(Line: PabStopLine); // @addr $68AD98 @note "Empty in this native version."
procedure ab_StopLine_BuildCollisionList; // @addr $68ADA4
function ab_StopLine_ReflectMovement(Source, Target: TSphericalBearingState; var HeadingDelta, Speed, UnusedResult: Double): Boolean; // @addr $68AF6C @ida "bool __userpurge $name@<al>(TSphericalBearingState *Source@<eax>, TSphericalBearingState *Target@<edx>, double *HeadingDelta@<ecx>, double *Speed@<^4>, double *UnusedResult@<^0>);"
procedure ab_StopLine_GetDistances(Source: TSphericalBearingState; var ForwardDistance, BackwardDistance: Double); // @addr $68B5CC @ida "void __usercall $name(TSphericalBearingState *Source@<eax>, double *ForwardDistance@<edx>, double *BackwardDistance@<ecx>);"
function ab_StopLine_IsBlocked(SourceLongitude, SourcePolarAngle, TargetLongitude, TargetPolarAngle: Double): Boolean; // @addr $68B9E8 @ida "bool __userpurge $name@<al>(double SourceLongitude@<^24>, double SourcePolarAngle@<^16>, double TargetLongitude@<^8>, double TargetPolarAngle@<^0>);"
procedure ab_StopLine_Load(Buffer: TBufEC); // @addr $68BA60

var
  StopPointHeap: Cardinal = 0; // @addr $87B80C
  FirstStopPoint: PabStopPoint = nil; // @addr $87B810
  LastStopPoint: PabStopPoint = nil; // @addr $87B814
  SelectedStopPoint: PabStopPoint = nil; // @addr $87B818
  StopLineHeap: Cardinal = 0; // @addr $87B81C
  FirstStopLine: PabStopLine = nil; // @addr $87B820
  LastStopLine: PabStopLine = nil; // @addr $87B824
  SelectedStopLine: PabStopLine = nil; // @addr $87B828
  FirstCollisionLine: PabStopLine = nil; // @addr $87B82C
  StopPointIndex: array of PabStopPoint; // @addr $889CD8

implementation

// @unit-initialization $8758E8
// @unit-finalization $68BBA4

uses Windows, SysUtils, Math, EC_Mem, Globals, GlobalsV;

{ @routine $68A560 ab_StopPoint_Clear }
procedure ab_StopPoint_Clear;
begin
  ab_StopPoint_ClearIndex;
  while not (FirstStopPoint = nil) do ab_StopPoint_Delete(LastStopPoint);
  if StopPointHeap <> 0 then
  begin
    HeapDestroy(StopPointHeap);
    StopPointHeap := 0;
  end;
end;
{ @end $68A560 }

{ @routine $68A598 ab_StopPoint_Add }
function ab_StopPoint_Add: PabStopPoint;
var
  Entry: PabStopPoint;
begin
  if StopPointHeap = 0 then
  begin
    StopPointHeap := HeapCreate(1, $8000, 0);
    if StopPointHeap = 0 then raise Exception.Create('ab_StopPoint_Add.HeapCreate');
  end;
  Entry := AllocClearFromHeapEC(StopPointHeap, SizeOf(TabStopPoint));
  Entry.Radius := SphereRadius;
  if LastStopPoint <> nil then LastStopPoint.Next := Entry;
  Entry.Prev := LastStopPoint;
  Entry.Next := nil;
  LastStopPoint := Entry;
  if FirstStopPoint = nil then FirstStopPoint := Entry;
  Result := Entry;
end;
{ @end $68A598 }

{ @routine $68A66C ab_StopPoint_Delete }
procedure ab_StopPoint_Delete(Point: PabStopPoint);
var
  Line, NextLine: PabStopLine;
begin
  if Point.Prev <> nil then Point.Prev.Next := Point.Next;
  if Point.Next <> nil then Point.Next.Prev := Point.Prev;
  if LastStopPoint = Point then LastStopPoint := Point.Prev;
  if FirstStopPoint = Point then FirstStopPoint := Point.Next;
  Line := FirstStopLine;
  while Line <> nil do
  begin
    NextLine := Line;
    Line := Line.Next;
    if (NextLine.First = Point) or (NextLine.Last = Point) then ab_StopLine_Delete(NextLine);
  end;
  if Point.WorldImage <> nil then
  begin
    ab_WorldImage_Delete(Point.WorldImage);
    Point.WorldImage := nil;
  end;
  ab_StopPoint_ClearSegments(Point);
  if SelectedStopPoint = Point then SelectedStopPoint := nil;
  if StopPointHeap <> 0 then FreeFromHeapEC(StopPointHeap, Point);
end;
{ @end $68A66C }

{ @routine $68A75C ab_StopPoint_UpdatePosition }
procedure ab_StopPoint_UpdatePosition(Point: PabStopPoint);
begin
  if Point = nil then
  begin
    Point := FirstStopPoint;
    while Point <> nil do
    begin
      Point.Position := SphericalToVector3D(HeadingDegreesToRadians(Point.Longitude), HeadingDegreesToRadians(Point.PolarAngle), Point.Radius);
      Point := Point.Next;
    end;
  end
  else Point.Position := SphericalToVector3D(HeadingDegreesToRadians(Point.Longitude), HeadingDegreesToRadians(Point.PolarAngle), Point.Radius);
end;
{ @end $68A75C }

{ @routine $68A834 ab_StopPoint_ClearImages }
procedure ab_StopPoint_ClearImages;
var
  Point: PabStopPoint;
begin
  Point := FirstStopPoint;
  while Point <> nil do
  begin
    if Point.WorldImage <> nil then
    begin
      ab_WorldImage_Delete(Point.WorldImage);
      Point.WorldImage := nil;
    end;
    Point := Point.Next;
  end;
end;
{ @end $68A834 }

{ @routine $68A874 ab_StopPoint_ClearSegments }
procedure ab_StopPoint_ClearSegments(Point: PabStopPoint);
var
  Index: Integer;
begin
  for Index := 0 to 3 do
    if Point.Segments[Index] <> nil then
    begin
      ArcadeBattleScreen.WorldLines.RetireSegment(Point.Segments[Index]);
      Point.Segments[Index] := nil;
    end;
end;
{ @end $68A874 }

{ @routine $68A8C4 ab_StopPoint_BuildIndex }
procedure ab_StopPoint_BuildIndex;
var
  Index, Count: Integer;
  Point: PabStopPoint;
begin
  ab_StopPoint_ClearIndex;
  Count := ab_StopPoint_Count;
  SetLength(StopPointIndex, Count);
  Index := 0;
  Point := FirstStopPoint;
  while Point <> nil do
  begin
    StopPointIndex[Index] := Point;
    Inc(Index);
    Point := Point.Next;
  end;
end;
{ @end $68A8C4 }

{ @routine $68A92C ab_StopPoint_ClearIndex }
procedure ab_StopPoint_ClearIndex;
begin
  StopPointIndex := nil;
end;
{ @end $68A92C }

{ @routine $68A940 ab_StopPoint_Count }
function ab_StopPoint_Count: Integer;
var
  Point: PabStopPoint;
begin
  Result := 0;
  Point := FirstStopPoint;
  while Point <> nil do
  begin
    Inc(Result);
    Point := Point.Next;
  end;
end;
{ @end $68A940 }

{ @routine $68A974 ab_StopLine_Clear }
procedure ab_StopLine_Clear;
begin
  while not (FirstStopLine = nil) do ab_StopLine_Delete(LastStopLine);
  if StopLineHeap <> 0 then
  begin
    HeapDestroy(StopLineHeap);
    StopLineHeap := 0;
  end;
end;
{ @end $68A974 }

{ @routine $68A9A8 ab_StopLine_Add }
function ab_StopLine_Add: PabStopLine;
var
  Entry: PabStopLine;
begin
  if StopLineHeap = 0 then
  begin
    StopLineHeap := HeapCreate(1, $8000, 0);
    if StopLineHeap = 0 then raise Exception.Create('ab_StopLine_Add.HeapCreate');
  end;
  Entry := AllocClearFromHeapEC(StopLineHeap, SizeOf(TabStopLine));
  if LastStopLine <> nil then LastStopLine.Next := Entry;
  Entry.Prev := LastStopLine;
  Entry.Next := nil;
  LastStopLine := Entry;
  if FirstStopLine = nil then FirstStopLine := Entry;
  Entry.Collidable := True;
  Entry.Visible := True;
  Entry.UserValue := 0;
  Result := Entry;
end;
{ @end $68A9A8 }

{ @routine $68AA84 ab_StopLine_Delete }
procedure ab_StopLine_Delete(Line: PabStopLine);
begin
  if Line.Prev <> nil then Line.Prev.Next := Line.Next;
  if Line.Next <> nil then Line.Next.Prev := Line.Prev;
  if LastStopLine = Line then LastStopLine := Line.Prev;
  if FirstStopLine = Line then FirstStopLine := Line.Next;
  if Line.WorldLine <> nil then
  begin
    ab_WorldLine_Delete(Line.WorldLine);
    Line.WorldLine := nil;
  end;
  ab_StopLine_ClearSegments(Line);
  if SelectedStopLine = Line then SelectedStopLine := nil;
  if StopLineHeap <> 0 then FreeFromHeapEC(StopLineHeap, Line);
end;
{ @end $68AA84 }

{ @routine $68AB30 ab_StopLine_AddLatitude }
procedure ab_StopLine_AddLatitude(PolarAngle, Step: Double);
var
  Longitude: Double;
  Line: PabStopLine;
  Point, Previous, First: PabStopPoint;
begin
  First := ab_StopPoint_Add;
  First.Longitude := 0;
  First.PolarAngle := PolarAngle;
  First.Kind := 1;
  ab_StopPoint_UpdatePosition(First);
  Previous := First;
  Longitude := Step;
  while Longitude < 360 do
  begin
    Point := ab_StopPoint_Add;
    Point.Longitude := Longitude;
    Point.PolarAngle := PolarAngle;
    Point.Kind := 1;
    ab_StopPoint_UpdatePosition(Point);
    Line := ab_StopLine_Add;
    Line.First := Previous;
    Line.Last := Point;
    Previous := Point;
    Longitude := Longitude + Step;
  end;
  Line := ab_StopLine_Add;
  Line.First := Previous;
  Line.Last := First;
end;
{ @end $68AB30 }

{ @routine $68AC14 ab_StopLine_UpdateWorldLines }
procedure ab_StopLine_UpdateWorldLines;
var
  Line: PabStopLine;
begin
  Line := FirstStopLine;
  while Line <> nil do
  begin
    if Line.Visible then
    begin
      if Line.WorldLine = nil then
      begin
        Line.WorldLine := ab_WorldLine_Create(Line.First.Position, Line.Last.Position, 4, Line.FirstColor^, $80FFFFFF, False);
        Line.WorldLine.FrontEndColor := Line.LastColor^;
        Line.WorldLine.BackEndColor := $80FFFFFF;
      end
      else
      begin
        ab_WorldLine_Set(Line.WorldLine, Line.First.Position, Line.Last.Position, 4, Line.FirstColor^, $80FFFFFF, False);
        Line.WorldLine.FrontEndColor := Line.LastColor^;
        Line.WorldLine.BackEndColor := $80FFFFFF;
      end;
    end;
    Line := Line.Next;
  end;
end;
{ @end $68AC14 }

{ @routine $68ACF8 ab_StopLine_UpdateColors }
procedure ab_StopLine_UpdateColors;
var
  Line: PabStopLine;
begin
  Line := FirstStopLine;
  while Line <> nil do
  begin
    if Line.WorldLine <> nil then
    begin
      Line.WorldLine.FrontColor := Line.FirstColor^;
      Line.WorldLine.FrontEndColor := Line.LastColor^;
    end;
    Line := Line.Next;
  end;
end;
{ @end $68ACF8 }

{ @routine $68AD48 ab_StopLine_ClearSegments }
procedure ab_StopLine_ClearSegments(Line: PabStopLine);
var
  Index: Integer;
begin
  for Index := 0 to 1 do
    if Line.Segments[Index] <> nil then
    begin
      ArcadeBattleScreen.WorldLines.RetireSegment(Line.Segments[Index]);
      Line.Segments[Index] := nil;
    end;
end;
{ @end $68AD48 }

{ @routine $68AD98 ab_StopLine_PrepareCollision }
procedure ab_StopLine_PrepareCollision(Line: PabStopLine);
begin
end;
{ @end $68AD98 }

{ @routine $68ADA4 ab_StopLine_BuildCollisionList }
procedure ab_StopLine_BuildCollisionList;
var
  Line, Previous: PabStopLine;
begin
  Previous := nil;
  FirstCollisionLine := nil;
  Line := FirstStopLine;
  while Line <> nil do
  begin
    ab_StopLine_PrepareCollision(Line);
    Line.NextCollision := nil;
    if Line.Collidable then
    begin
      if Previous = nil then FirstCollisionLine := Line
      else Previous.NextCollision := Line;
      Previous := Line;
    end;
    Line := Line.Next;
  end;
end;
{ @end $68ADA4 }

{ @routine $68AF6C ab_StopLine_ReflectMovement }
function ab_StopLine_ReflectMovement(Source, Target: TSphericalBearingState; var HeadingDelta, Speed, UnusedResult: Double): Boolean;
var
  InverseLengthSquared, LineLength: Single;
  Line: PabStopLine;
  Factor, CenterDepth, FirstT, SecondT, OriginalHeading, Distance: Double;
  LengthSquared: Single;
  Matrix: TMatrix4D;
  Normal, A, B, Direction, Movement: TVector3D;

  // @nested $68AE10 IntersectCollisionParameters
  function IntersectCollisionParameters(A, B, C, D: TVector3D; var FirstT, SecondT: Double): Boolean; // @addr $68AE10 @ida "bool __userpurge $name@<al>(TVector3D *A@<eax>, TVector3D *B@<edx>, TVector3D *C@<ecx>, TVector3D *D@<^8>, double *FirstT@<^4>, double *SecondT@<^0>, void *ParentFrame@<^12>);" @stackpop 12 @calls "0x68b2e9"
  begin
    FirstT := (B.X - A.X) * (D.Y - C.Y) - (B.Y - A.Y) * (D.X - C.X);
    if FirstT = 0 then
    begin
      Result := False;
      Exit;
    end;
    FirstT := 1 / FirstT;
    SecondT := ((A.Y - C.Y) * (B.X - A.X) - (A.X - C.X) * (B.Y - A.Y)) * FirstT;
    FirstT := ((A.Y - C.Y) * (D.X - C.X) - (A.X - C.X) * (D.Y - C.Y)) * FirstT;
    Result := True;
  end;

  // @nested $68AF00 CollisionLineDistance
  function CollisionLineDistance(A, B, Point: TVector3D): Double; // @addr $68AF00 @ida "double __usercall $name@<st0>(TVector3D *A@<eax>, TVector3D *B@<edx>, TVector3D *Point@<ecx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x68b25a"
  var
    Cross: Double;
  begin
    Cross := (A.Y - Point.Y) * (B.X - A.X) - (A.X - Point.X) * (B.Y - A.Y);
    Result := Cross * InverseLengthSquared * LineLength;
  end;

begin
  Result := False;
  if FirstStopLine <> nil then
  begin
    UnusedResult := 0;
    A := SphericalToVector3D(HeadingDegreesToRadians(Source.LongitudeDegrees), HeadingDegreesToRadians(Source.PolarAngleDegrees), SphereCameraDistance);
    B := MakeVector3D(0, 0, 0);
    Direction := SphericalToVector3D(HeadingDegreesToRadians(Source.LongitudeDegrees), HeadingDegreesToRadians(WrapHeadingDegrees(Source.PolarAngleDegrees + 90)), SphereCameraDistance);
    Matrix := BuildLookAtMatrix(A, B, Direction);
    Movement := SphericalToVector3D(HeadingDegreesToRadians(Target.LongitudeDegrees), HeadingDegreesToRadians(Target.PolarAngleDegrees), SphereRadius);
    Movement := ProjectPointByMatrix(Matrix, Movement);
    OriginalHeading := RadiansToHeadingDegrees(Math.ArcTan2(Movement.X, -Movement.Y));
    A := MakeVector3D(0, 0, 0);
    A := ProjectPointByMatrix(Matrix, A);
    CenterDepth := A.Z;
    Line := FirstCollisionLine;
    while Line <> nil do
    begin
      A := ProjectPointByMatrix(Matrix, Line.First.Position);
      B := ProjectPointByMatrix(Matrix, Line.Last.Position);
      if not ((A.Z < CenterDepth) and (B.Z < CenterDepth)) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      Direction.X := B.X - A.X;
      Direction.Y := B.Y - A.Y;
      LengthSquared := Sqr(Direction.X) + Sqr(Direction.Y);
      LineLength := Sqrt(LengthSquared);
      InverseLengthSquared := 1 / LengthSquared;
      Distance := Abs(CollisionLineDistance(A, B, MakeVector3D(0, 0, 0)));
      if not (Distance <= 11) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      Factor := 1 / LineLength;
      Direction.X := Direction.X * Factor;
      Direction.Y := Direction.Y * Factor;
      if not IntersectCollisionParameters(A, B, MakeVector3D(0, 0, 0), Movement, FirstT, SecondT) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      if not ((FirstT >= -0.0001) and (FirstT <= 1.0001)) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      if not (SecondT >= 0) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      Normal.X := -Direction.Y;
      Normal.Y := Direction.X;
      Factor := -Movement.X * Normal.X + -Movement.Y * Normal.Y;
      Movement.X := (Normal.X * Factor * 2 + Movement.X) * 0.8;
      Movement.Y := (Normal.Y * Factor * 2 + Movement.Y) * 0.8;
      Result := True;
      Break;
      // The native compiler retained this unreachable list advance after Break.
      Line := Line.NextCollision;
    end;
    if Result then
    begin
      HeadingDelta := HeadingDifferenceDegrees(OriginalHeading, RadiansToHeadingDegrees(Math.ArcTan2(Movement.X, -Movement.Y)));
      Speed := Sqrt(Sqr(Movement.X) + Sqr(Movement.Y));
    end;
  end;
end;
{ @end $68AF6C }

{ @routine $68B5CC ab_StopLine_GetDistances }
procedure ab_StopLine_GetDistances(Source: TSphericalBearingState; var ForwardDistance, BackwardDistance: Double);
var
  CenterDepth: Double;
  Line: PabStopLine;
  Matrix, View, Rotation: TMatrix4D;
  A, B, Hit: TVector3D;

  // @nested $68B4B4 IntersectCollisionLines
  function IntersectCollisionLines(A, B, C, D: TVector3D; var Hit: TVector3D): Boolean; // @addr $68B4B4 @ida "bool __userpurge $name@<al>(TVector3D *A@<eax>, TVector3D *B@<edx>, TVector3D *C@<ecx>, TVector3D *D@<^4>, TVector3D *Hit@<^0>, void *ParentFrame@<^8>);" @stackpop 8 @calls "0x68b86a"
  var
    DX1, DY1, DX2, DY2, Denominator: Double;
  begin
    DX1 := B.X - A.X;
    DY1 := B.Y - A.Y;
    DX2 := D.X - C.X;
    DY2 := D.Y - C.Y;
    Denominator := DY1 * DX2 - DY2 * DX1;
    if Denominator = 0 then
    begin
      Result := False;
      Exit;
    end;
    Hit.X := ((C.Y - A.Y) * DX1 * DX2 + DY1 * DX2 * A.X - DY2 * DX1 * C.X) / Denominator;
    if DX1 <> 0 then Hit.Y := (Hit.X - A.X) * DY1 / DX1 + A.Y
    else Hit.Y := (Hit.X - C.X) * DY2 / DX2 + C.Y;
    Result := True;
  end;

begin
  ForwardDistance := 1e20;
  BackwardDistance := 1e20;
  if FirstStopLine <> nil then
  begin
    A := SphericalToVector3D(HeadingDegreesToRadians(Source.LongitudeDegrees), HeadingDegreesToRadians(Source.PolarAngleDegrees), SphereCameraDistance);
    B := MakeVector3D(0, 0, 0);
    Hit := SphericalToVector3D(HeadingDegreesToRadians(Source.LongitudeDegrees), HeadingDegreesToRadians(Source.PolarAngleDegrees + 90), SphereCameraDistance);
    View := BuildLookAtMatrix(A, B, Hit);
    Rotation := BuildZAxisRotationMatrix(HeadingDegreesToRadians(Source.BearingDegrees));
    Matrix := MultiplyMatrix4D(Rotation, View);
    A := MakeVector3D(0, 0, 0);
    A := ProjectPointByMatrix(Matrix, A);
    CenterDepth := A.Z;
    Line := FirstCollisionLine;
    while Line <> nil do
    begin
      A := ProjectPointByMatrix(Matrix, Line.First.Position);
      B := ProjectPointByMatrix(Matrix, Line.Last.Position);
      if not ((A.Z < CenterDepth) and (B.Z < CenterDepth)) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      if not (((A.X >= 0) or (B.X >= 0)) and ((A.X <= 0) or (B.X <= 0))) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      if not IntersectCollisionLines(A, B, MakeVector3D(0, 0, 0), MakeVector3D(0, 1, 0), Hit) then
      begin
        Line := Line.NextCollision;
        Continue;
      end;
      if (Hit.Y <= 0) and (-Hit.Y < ForwardDistance) then ForwardDistance := -Hit.Y;
      if (Hit.Y >= 0) and (BackwardDistance > Hit.Y) then BackwardDistance := Hit.Y;
      Line := Line.NextCollision;
    end;
    if (ForwardDistance < 1e15) and (ForwardDistance <> 0) then
      ForwardDistance := RadiansToHeadingDegrees(Math.ArcSin(ForwardDistance / SphereRadius)) * (Pi * SphereRadius / 180);
    if (BackwardDistance < 1e15) and (BackwardDistance <> 0) then
      BackwardDistance := RadiansToHeadingDegrees(Math.ArcSin(BackwardDistance / SphereRadius)) * (Pi * SphereRadius / 180);
  end;
end;
{ @end $68B5CC }

{ @routine $68B9E8 ab_StopLine_IsBlocked }
function ab_StopLine_IsBlocked(SourceLongitude, SourcePolarAngle, TargetLongitude, TargetPolarAngle: Double): Boolean;
var
  BearingDelta, Distance, ForwardDistance, BackwardDistance: Double;
begin
  ComputeSphericalBearingAndDistance(BearingDelta, Distance, SourceLongitude, SourcePolarAngle, 0, TargetLongitude, TargetPolarAngle, SphereRadius);
  ab_StopLine_GetDistances(MakeSphericalBearingState(SourceLongitude, SourcePolarAngle, BearingDelta), ForwardDistance, BackwardDistance);
  Result := ForwardDistance < Distance;
end;
{ @end $68B9E8 }

{ @routine $68BA60 ab_StopLine_Load }
procedure ab_StopLine_Load(Buffer: TBufEC);
var
  Index, Count, FirstIndex, LastIndex: Integer;
  Point: PabStopPoint;
  Line: PabStopLine;
begin
  ab_StopLine_Clear;
  ab_StopPoint_Clear;
  Count := Buffer.GetInt32;
  for Index := 0 to Count - 1 do
  begin
    Point := ab_StopPoint_Add;
    Point.Longitude := Buffer.GetSingle;
    Point.PolarAngle := Buffer.GetSingle;
    Point.Radius := Buffer.GetSingle;
    ab_StopPoint_UpdatePosition(Point);
  end;
  ab_StopPoint_BuildIndex;
  Count := Buffer.GetInt32;
  for Index := 0 to Count - 1 do
  begin
    Line := ab_StopLine_Add;
    FirstIndex := Buffer.GetInt32;
    LastIndex := Buffer.GetInt32;
    Line.First := StopPointIndex[FirstIndex];
    Line.Last := StopPointIndex[LastIndex];
    Line.Visible := Buffer.GetBoolean;
    Line.Collidable := Buffer.GetBoolean;
    if Line.Visible then
    begin
      Line.FirstColor := PCardinal(PAnsiChar(ArcadeMapColorBuffer.Data) + Buffer.GetInt32);
      Line.LastColor := PCardinal(PAnsiChar(ArcadeMapColorBuffer.Data) + Buffer.GetInt32);
    end;
  end;
end;
{ @end $68BA60 }

end.
