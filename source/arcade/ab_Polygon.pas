unit ab_Polygon;
// Unit bracket (inferred): .text 0x00602C30..0x00603987; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x008758E0..0x008758E7; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native anonymous RTTI and initialization-table evidence identify this unit.
// Ordinary routines occupy $602D2C..$603936; $603938 is compiler finalization.

interface

uses EC_Buf, EC_Struct, ab_StopLine;

type
  TabPolygonVertex = record // @size $08
    Point: PabStopPoint; // @offset $00
    Color: PCardinal; // @offset $04
  end;
  PabPolygon = ^TabPolygon;
  TabPolygon = record // @size $34
    Prev: PabPolygon; // @offset $00
    Next: PabPolygon; // @offset $04
    Vertices: array[0..2] of TabPolygonVertex; // @offset $08
    MapValue30: Integer; // @offset $30  Serialized value; meaning not yet established.
  end;
  PabPolygonGroup = ^TabOptGroup;
  // Native record RTTI at $602C50.
  TabOptGroup = record // @size $68
    Polygons: array of PabPolygon; // @offset $00
    Corners: array[0..3] of TVector3D; // @offset $08
  end;
  PabPolygonCell = ^TabOptUnit;
  // Native record RTTI at $602CBC.
  TabOptUnit = record // @size $08
    Points: array of PabStopPoint; // @offset $00
    Groups: array of PabPolygonGroup; // @offset $04
  end;

procedure ab_Polygon_Clear; // @addr $602D2C
function ab_Polygon_Count: Integer; // @addr $602D5C
procedure ab_Polygon_ClearVisibility; // @addr $602D90
procedure ab_Polygon_LoadVisibility(Buffer: TBufEC); // @addr $602E6C
procedure ab_Polygon_SelectVisibilityCell; // @addr $6032BC
procedure ab_Polygon_ProjectVisiblePoints; // @addr $603368
procedure ab_Polygon_QueueUpdateRects; // @addr $60341C
procedure ab_Polygon_Draw; // @addr $60369C
procedure ab_Polygon_Load(Buffer: TBufEC); // @addr $603838

var
  FirstPolygon: PabPolygon = nil; // @addr $87B6E8
  LastPolygon: PabPolygon = nil; // @addr $87B6EC
  PolygonStorage: PabPolygon; // @addr $889C18
  PolygonGroups: array of TabOptGroup; // @addr $889C1C
  PolygonCells: array of TabOptUnit; // @addr $889C20
  LongitudeCellCount: Integer; // @addr $889C24
  PolarCellCount: Integer; // @addr $889C28
  CurrentPolygonCell: PabPolygonCell; // @addr $889C2C

implementation

// @unit-initialization $8758E0
// @unit-finalization $603938

uses Classes, EC_Mem, GI_Tail, ab_Global, GR_Main, GR_DX, Globals, GlobalsV;

{ @routine $602D2C ab_Polygon_Clear }
procedure ab_Polygon_Clear;
begin
  ab_Polygon_ClearVisibility;
  if PolygonStorage <> nil then
  begin
    FreeEC(PolygonStorage);
    PolygonStorage := nil;
  end;
  FirstPolygon := nil;
  LastPolygon := nil;
end;
{ @end $602D2C }

{ @routine $602D5C ab_Polygon_Count }
function ab_Polygon_Count: Integer;
var
  Polygon: PabPolygon;
begin
  Result := 0;
  Polygon := FirstPolygon;
  while Polygon <> nil do
  begin
    Inc(Result);
    Polygon := Polygon.Next;
  end;
end;
{ @end $602D5C }

{ @routine $602D90 ab_Polygon_ClearVisibility }
procedure ab_Polygon_ClearVisibility;
var
  Index: Integer;
begin
  for Index := 0 to High(PolygonCells) do
  begin
    PolygonCells[Index].Points := nil;
    PolygonCells[Index].Groups := nil;
  end;
  for Index := 0 to High(PolygonGroups) do PolygonGroups[Index].Polygons := nil;
  PolygonGroups := nil;
  PolygonCells := nil;
  CurrentPolygonCell := nil;
end;
{ @end $602D90 }

{ @routine $602E6C ab_Polygon_LoadVisibility }
procedure ab_Polygon_LoadVisibility(Buffer: TBufEC);
var
  Index, ItemIndex, Count: Integer;
  Polygons: array of PabPolygon;
  Polygon: PabPolygon;
  Cursor: Pointer;
  PointIndex: Integer;
  Group: PabPolygonGroup;
begin
  ab_Polygon_ClearVisibility;
  Count := ab_Polygon_Count;
  SetLength(Polygons, Count);
  Index := 0;
  Polygon := FirstPolygon;
  while Polygon <> nil do
  begin
    Polygons[Index] := Polygon;
    Inc(Index);
    Polygon := Polygon.Next;
  end;
  LongitudeCellCount := Buffer.GetInt32;
  PolarCellCount := Buffer.GetInt32;
  SetLength(PolygonCells, LongitudeCellCount * PolarCellCount);
  SetLength(PolygonGroups, Buffer.GetInt32);
  for Index := 0 to High(PolygonGroups) do
  begin
    Group := @PolygonGroups[Index];
    Count := Buffer.GetWord;
    SetLength(Group.Polygons, Count);
    Cursor := Pointer(PAnsiChar(Buffer.Data) + Buffer.Position);
    for ItemIndex := 0 to High(Group.Polygons) do
    begin
      Group.Polygons[ItemIndex] := Polygons[PWord(Cursor)^];
      Cursor := Pointer(PAnsiChar(Cursor) + 2);
    end;
    Buffer.SetPosition(Buffer.Position + Count * 2);
    Cursor := Pointer(PAnsiChar(Buffer.Data) + Buffer.Position);
    Group.Corners[0].X := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[0].Y := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[0].Z := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[1].X := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[1].Y := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[1].Z := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[2].X := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[2].Y := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[2].Z := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[3].X := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[3].Y := PSingle(Cursor)^;
    Cursor := Pointer(PAnsiChar(Cursor) + 4);
    Group.Corners[3].Z := PSingle(Cursor)^;
    Buffer.SetPosition(Buffer.Position + 48);
  end;
  for Index := 0 to LongitudeCellCount * PolarCellCount - 1 do
  begin
    CurrentPolygonCell := @PolygonCells[Index];
    Count := Buffer.GetWord;
    SetLength(CurrentPolygonCell.Points, Count);
    Cursor := Pointer(PAnsiChar(Buffer.Data) + Buffer.Position);
    for ItemIndex := 0 to Count - 1 do
    begin
      PointIndex := PWord(Cursor)^;
      CurrentPolygonCell.Points[ItemIndex] := StopPointIndex[PointIndex];
      Cursor := Pointer(PAnsiChar(Cursor) + 2);
    end;
    Buffer.SetPosition(Buffer.Position + Count * 2);
    Count := Buffer.GetWord;
    SetLength(CurrentPolygonCell.Groups, Count);
    Cursor := Pointer(PAnsiChar(Buffer.Data) + Buffer.Position);
    for ItemIndex := 0 to Count - 1 do
    begin
      CurrentPolygonCell.Groups[ItemIndex] := @PolygonGroups[PWord(Cursor)^];
      Cursor := Pointer(PAnsiChar(Cursor) + 2);
    end;
    Buffer.SetPosition(Buffer.Position + Count * 2);
  end;
  Polygons := nil;
  CurrentPolygonCell := nil;
end;
{ @end $602E6C }

{ @routine $6032BC ab_Polygon_SelectVisibilityCell }
procedure ab_Polygon_SelectVisibilityCell;
var
  LongitudeIndex, PolarIndex: Integer;
begin
  LongitudeIndex := Round(SphereViewState.LongitudeDegrees / 360 * LongitudeCellCount);
  if LongitudeIndex >= LongitudeCellCount then LongitudeIndex := 0;
  PolarIndex := Round(SphereViewState.PolarAngleDegrees / 180 * (PolarCellCount - 1));
  if PolarIndex >= PolarCellCount then RaiseWideMessage('ab_OptCur');
  CurrentPolygonCell := @PolygonCells[LongitudeIndex * PolarCellCount + PolarIndex];
end;
{ @end $6032BC }

{ @routine $603368 ab_Polygon_ProjectVisiblePoints }
procedure ab_Polygon_ProjectVisiblePoints;
var
  Index, Count: Integer;
  Point: PabStopPoint;
  Projected: TVector3D;
begin
  if CurrentPolygonCell = nil then Exit;
  if CurrentPolygonCell.Points = nil then Exit;
  Count := High(CurrentPolygonCell.Points) + 1;
  for Index := 0 to Count - 1 do
  begin
    Point := CurrentPolygonCell.Points[Index];
    Projected := ProjectPointByMatrix(SphereProjectionMatrix, Point.Position);
    Point.Projected := True;
    Point.ScreenX := ArcadeBattleScreen.WorldCenterX + Round(Projected.X);
    Point.ScreenY := ArcadeBattleScreen.WorldCenterY + Round(Projected.Y);
  end;
end;
{ @end $603368 }

{ @routine $60341C ab_Polygon_QueueUpdateRects }
procedure ab_Polygon_QueueUpdateRects;
var
  Index, Count: Integer;
  Group: PabPolygonGroup;
  MinX, MaxX, MinY, MaxY: Double;
  CenterX, CenterY: Integer;
  Projected: TVector3D;
begin
  if CurrentPolygonCell = nil then Exit;
  if CurrentPolygonCell.Groups = nil then Exit;
  CenterX := ArcadeBattleScreen.WorldCenterX;
  CenterY := ArcadeBattleScreen.WorldCenterY;
  Count := High(CurrentPolygonCell.Groups) + 1;
  for Index := 0 to Count - 1 do
  begin
    Group := CurrentPolygonCell.Groups[Index];
    Projected := ProjectPointByMatrix(SphereProjectionMatrix, Group.Corners[0]);
    MinX := Projected.X;
    MaxX := Projected.X;
    MinY := Projected.Y;
    MaxY := Projected.Y;
    Projected := ProjectPointByMatrix(SphereProjectionMatrix, Group.Corners[1]);
    if Projected.X < MinX then MinX := Projected.X
    else if Projected.X > MaxX then MaxX := Projected.X;
    if Projected.Y < MinY then MinY := Projected.Y
    else if Projected.Y > MaxY then MaxY := Projected.Y;
    Projected := ProjectPointByMatrix(SphereProjectionMatrix, Group.Corners[2]);
    if Projected.X < MinX then MinX := Projected.X
    else if Projected.X > MaxX then MaxX := Projected.X;
    if Projected.Y < MinY then MinY := Projected.Y
    else if Projected.Y > MaxY then MaxY := Projected.Y;
    Projected := ProjectPointByMatrix(SphereProjectionMatrix, Group.Corners[3]);
    if Projected.X < MinX then MinX := Projected.X
    else if Projected.X > MaxX then MaxX := Projected.X;
    if Projected.Y < MinY then MinY := Projected.Y
    else if Projected.Y > MaxY then MaxY := Projected.Y;
    ArcadeBattleScreen.QueueUpdateRect(Classes.Rect(CenterX + Round(MinX), CenterY + Round(MinY), CenterX + Round(MaxX) + 1, CenterY + Round(MaxY) + 1));
  end;
end;
{ @end $60341C }

{ @routine $60369C ab_Polygon_Draw }
procedure ab_Polygon_Draw;
var
  GroupIndex, GroupCount, PolygonIndex, PolygonCount: Integer;
  Group: PabPolygonGroup;
  Polygon: PabPolygon;
begin
  if CurrentPolygonCell = nil then Exit;
  if CurrentPolygonCell.Groups = nil then Exit;
  GroupCount := High(CurrentPolygonCell.Groups) + 1;
  for GroupIndex := 0 to GroupCount - 1 do
  begin
    Group := CurrentPolygonCell.Groups[GroupIndex];
    PolygonCount := High(Group.Polygons) + 1;
    for PolygonIndex := 0 to PolygonCount - 1 do
    begin
      Polygon := Group.Polygons[PolygonIndex];
      if HardwareRenderingEnabled then
        DrawColoredTriangle(Polygon.Vertices[0].Point.ScreenX, Polygon.Vertices[0].Point.ScreenY, Polygon.Vertices[0].Color^,
          Polygon.Vertices[1].Point.ScreenX, Polygon.Vertices[1].Point.ScreenY, Polygon.Vertices[1].Color^,
          Polygon.Vertices[2].Point.ScreenX, Polygon.Vertices[2].Point.ScreenY, Polygon.Vertices[2].Color^, True, @GameScreenRect)
      else
        TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
          Polygon.Vertices[0].Point.ScreenX, Polygon.Vertices[0].Point.ScreenY, Polygon.Vertices[0].Color^,
          Polygon.Vertices[1].Point.ScreenX, Polygon.Vertices[1].Point.ScreenY, Polygon.Vertices[1].Color^,
          Polygon.Vertices[2].Point.ScreenX, Polygon.Vertices[2].Point.ScreenY, Polygon.Vertices[2].Color^, @GameScreenRect);
    end;
  end;
end;
{ @end $60369C }

{ @routine $603838 ab_Polygon_Load }
procedure ab_Polygon_Load(Buffer: TBufEC);
var
  Index, Count, Vertex: Integer;
  Polygon: PabPolygon;
begin
  ab_Polygon_Clear;
  Count := Buffer.GetInt32;
  if Count < 1 then Exit;
  PolygonStorage := AllocClearEC(Count * SizeOf(TabPolygon));
  Polygon := PolygonStorage;
  for Index := 0 to Count - 1 do
  begin
    if LastPolygon <> nil then LastPolygon.Next := Polygon;
    Polygon.Prev := LastPolygon;
    Polygon.Next := nil;
    LastPolygon := Polygon;
    if FirstPolygon = nil then FirstPolygon := Polygon;
    Polygon.MapValue30 := Buffer.GetInt32;
    for Vertex := 0 to 2 do
    begin
      Polygon.Vertices[Vertex].Point := StopPointIndex[Buffer.GetInt32];
      Polygon.Vertices[Vertex].Color := Pointer(PAnsiChar(ArcadeMapColorBuffer.Data) + Buffer.GetInt32);
    end;
    Polygon := Pointer(PAnsiChar(Polygon) + SizeOf(TabPolygon));
  end;
end;
{ @end $603838 }

end.
