unit ab_StopLine;
// Unit bracket (inferred): .text 0x00554FD8..0x0055667B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00877868..0x0087786F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native stop-point/line region: $554FD8..$55667B, including compiler-managed finalization.

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

procedure ab_StopPoint_Clear; // @addr $554FF8
function ab_StopPoint_Add: PabStopPoint; // @addr $555030 @note "Allocates and links a node owned by the world list."
procedure ab_StopPoint_Delete(Point: PabStopPoint); // @addr $555104
procedure ab_StopPoint_UpdatePosition(Point: PabStopPoint); // @addr $5551F4 @note "Nil updates every point."
procedure ab_StopPoint_ClearImages; // @addr $5552CC
procedure ab_StopPoint_ClearSegments(Point: PabStopPoint); // @addr $55530C
procedure ab_StopPoint_BuildIndex; // @addr $55535C
procedure ab_StopPoint_ClearIndex; // @addr $5553C4
function ab_StopPoint_Count: Integer; // @addr $5553D8
procedure ab_StopLine_Clear; // @addr $55540C
function ab_StopLine_Add: PabStopLine; // @addr $555440 @note "Allocates and links a node owned by the world list."
procedure ab_StopLine_Delete(Line: PabStopLine); // @addr $55551C
procedure ab_StopLine_AddLatitude(PolarAngle, Step: Double); // @addr $5555C8
procedure ab_StopLine_UpdateWorldLines; // @addr $5556AC
procedure ab_StopLine_UpdateColors; // @addr $555790
procedure ab_StopLine_ClearSegments(Line: PabStopLine); // @addr $5557E0
procedure ab_StopLine_PrepareCollision(Line: PabStopLine); // @addr $555830 @note "Empty in this native version."
procedure ab_StopLine_BuildCollisionList; // @addr $55583C
function ab_StopLine_ReflectMovement(Source, Target: TSphericalBearingState; var HeadingDelta, Speed, UnusedResult: Double): Boolean; // @addr $555A04
procedure ab_StopLine_GetDistances(Source: TSphericalBearingState; var ForwardDistance, BackwardDistance: Double); // @addr $556064
function ab_StopLine_IsBlocked(SourceLongitude, SourcePolarAngle, TargetLongitude, TargetPolarAngle: Double): Boolean; // @addr $556480
procedure ab_StopLine_Load(Buffer: TBufEC); // @addr $5564F8

var
  StopPointHeap: Cardinal = 0; // @addr $87AF30
  FirstStopPoint: PabStopPoint = nil; // @addr $87AF34
  LastStopPoint: PabStopPoint = nil; // @addr $87AF38
  SelectedStopPoint: PabStopPoint = nil; // @addr $87AF3C
  StopLineHeap: Cardinal = 0; // @addr $87AF40
  FirstStopLine: PabStopLine = nil; // @addr $87AF44
  LastStopLine: PabStopLine = nil; // @addr $87AF48
  SelectedStopLine: PabStopLine = nil; // @addr $87AF4C
  FirstCollisionLine: PabStopLine = nil; // @addr $87AF50
  StopPointIndex: array of PabStopPoint; // @addr $88A804

implementation

// @unit-initialization $877868
// @unit-finalization $55663C

uses Windows, SysUtils, Math, EC_Mem, Globals, GlobalsV;

{ @routine $554FF8 ab_StopPoint_Clear }
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
{ @end $554FF8 }

{ @routine $555030 ab_StopPoint_Add }
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
{ @end $555030 }

{ @routine $555104 ab_StopPoint_Delete }
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
{ @end $555104 }

{ @routine $5551F4 ab_StopPoint_UpdatePosition }
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
{ @end $5551F4 }

{ @routine $5552CC ab_StopPoint_ClearImages }
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
{ @end $5552CC }

{ @routine $55530C ab_StopPoint_ClearSegments }
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
{ @end $55530C }

{ @routine $55535C ab_StopPoint_BuildIndex }
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
{ @end $55535C }

{ @routine $5553C4 ab_StopPoint_ClearIndex }
procedure ab_StopPoint_ClearIndex;
begin
  StopPointIndex := nil;
end;
{ @end $5553C4 }

{ @routine $5553D8 ab_StopPoint_Count }
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
{ @end $5553D8 }

{ @routine $55540C ab_StopLine_Clear }
procedure ab_StopLine_Clear;
begin
  while not (FirstStopLine = nil) do ab_StopLine_Delete(LastStopLine);
  if StopLineHeap <> 0 then
  begin
    HeapDestroy(StopLineHeap);
    StopLineHeap := 0;
  end;
end;
{ @end $55540C }

{ @routine $555440 ab_StopLine_Add }
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
{ @end $555440 }

{ @routine $55551C ab_StopLine_Delete }
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
{ @end $55551C }

{ @routine $5555C8 ab_StopLine_AddLatitude }
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
{ @end $5555C8 }

{ @routine $5556AC ab_StopLine_UpdateWorldLines }
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
{ @end $5556AC }

{ @routine $555790 ab_StopLine_UpdateColors }
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
{ @end $555790 }

{ @routine $5557E0 ab_StopLine_ClearSegments }
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
{ @end $5557E0 }

{ @routine $555830 ab_StopLine_PrepareCollision }
procedure ab_StopLine_PrepareCollision(Line: PabStopLine);
begin
end;
{ @end $555830 }

{ @routine $55583C ab_StopLine_BuildCollisionList }
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
{ @end $55583C }

{ @routine $555A04 ab_StopLine_ReflectMovement }
function ab_StopLine_ReflectMovement(Source, Target: TSphericalBearingState; var HeadingDelta, Speed, UnusedResult: Double): Boolean;
var
  InverseLengthSquared, LineLength: Single;
  Line: PabStopLine;
  Factor, CenterDepth, FirstT, SecondT, OriginalHeading, Distance: Double;
  LengthSquared: Single;
  Matrix: TMatrix4D;
  Normal, A, B, Direction, Movement: TVector3D;

  // @nested $5558A8 IntersectCollisionParameters
  function IntersectCollisionParameters(A, B, C, D: TVector3D; var FirstT, SecondT: Double): Boolean; // @addr $5558A8 @calls "0x555d81"
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

  // @nested $555998 CollisionLineDistance
  function CollisionLineDistance(A, B, Point: TVector3D): Double; // @addr $555998 @calls "0x555cf2"
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
{ @end $555A04 }

{ @routine $556064 ab_StopLine_GetDistances }
procedure ab_StopLine_GetDistances(Source: TSphericalBearingState; var ForwardDistance, BackwardDistance: Double);
var
  CenterDepth: Double;
  Line: PabStopLine;
  Matrix, View, Rotation: TMatrix4D;
  A, B, Hit: TVector3D;

  // @nested $555F4C IntersectCollisionLines
  function IntersectCollisionLines(A, B, C, D: TVector3D; var Hit: TVector3D): Boolean; // @addr $555F4C @calls "0x556302"
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
{ @end $556064 }

{ @routine $556480 ab_StopLine_IsBlocked }
function ab_StopLine_IsBlocked(SourceLongitude, SourcePolarAngle, TargetLongitude, TargetPolarAngle: Double): Boolean;
var
  BearingDelta, Distance, ForwardDistance, BackwardDistance: Double;
begin
  ComputeSphericalBearingAndDistance(BearingDelta, Distance, SourceLongitude, SourcePolarAngle, 0, TargetLongitude, TargetPolarAngle, SphereRadius);
  ab_StopLine_GetDistances(MakeSphericalBearingState(SourceLongitude, SourcePolarAngle, BearingDelta), ForwardDistance, BackwardDistance);
  Result := ForwardDistance < Distance;
end;
{ @end $556480 }

{ @routine $5564F8 ab_StopLine_Load }
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
{ @end $5564F8 }

end.
