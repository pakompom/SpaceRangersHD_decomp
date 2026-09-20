unit abWall;
// Grouped by TabWall's native VMT; original unit boundary unresolved.

interface

uses Classes, GI_MessageLoop, ab_Object, ab_Hit, ab_StopLine, ab_WorldImage, ab_Zone;

type
  TabWall = class(TabHit) // @size $E0
  public
    Zone: PabZone; // @offset $D0
    WorldImage: PabWorldImage; // @offset $D4
    DirectionFrameCount: Integer; // @offset $D8
    StopPoint: PabStopPoint; // @offset $DC
    constructor Create; // @addr $501618
    destructor Destroy; override; // @addr $50169C
    procedure BindZone(Value: PabZone); // @addr $5016F4
    procedure AttachVisual; // @addr $5018B4 @note "Empty in this native version; called after arena wall setup."
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $5018C0
    procedure ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean); override; // @addr $5018D4
    procedure UpdateState; override; // @addr $5019F0
    procedure Advance; override; // @addr $501A04
    procedure UpdateVisuals; override; // @addr $501A94
  end;

function ab_Wall_FindZone(Zone: PabZone): TabWall; // @addr $501BE4
procedure ab_Wall_BuildBarrierImages; // @addr $501CB4

var
  BarrierColor: Cardinal = $30FFAC00; // @addr $87ACF4
  // Native index local starts at zero and increments at $501E6A to the bound 2.
  BarrierHaloColors: array[0..1] of Cardinal = ($40FFDB00, $20FFAC00); // @addr $87ACF8 @indexrefs "$501E3F,$501E4F"

implementation

uses Math, EC_Str, EC_Struct, GI_Tail, ab_Global, GR_Main;

{ @routine $501618 TabWall_Create }
constructor TabWall.Create;
begin
  inherited Create;
  TurnSpeedScale := 1;
  DisruptUntilTick := 0;
  Health := 200;
  MaxHealth := 200;
  WallCollisionEnabled := True;
end;
{ @end $501618 }

{ @routine $50169C TabWall_Destroy }
destructor TabWall.Destroy;
begin
  if WorldImage <> nil then
  begin
    ab_WorldImage_Delete(WorldImage);
    WorldImage := nil;
  end;
  inherited Destroy;
end;
{ @end $50169C }

{ @routine $5016F4 TabWall_BindZone }
procedure TabWall.BindZone(Value: PabZone);
begin
  Zone := Value;
  if Value.Name <> '' then
  begin
    WorldImage := ab_WorldImage_Create(MakeVector3D(0, 0, 0),
      'GAI,Bm.ABWall.' + GiResourceSuffix + '.' + Value.Name, '', True);
    ab_WorldImage_SetDepth(WorldImage, WorldImageFrontDepth, WorldImageBackDepth);
    DirectionFrameCount := CountDelimitedPartsW(Value.Name, '_');
    DirectionFrameCount := ExtractDigitsToIntW(ExtractDelimitedPartW(Value.Name, DirectionFrameCount - 1, '_'));
  end;
  DirectionFrameCount := 32; // Native overwrites the parsed count above.
  EffectOriginSpread := GiScalePixels(20);
  Mass := 10;
  State.PolarAngleDegrees := 0;
  State.BearingDegrees := 0;
  CollisionRadius := 11;
  ZoneRadius := Value.Radius;
end;
{ @end $5016F4 }

{ @routine $5018B4 TabWall_AttachVisual }
procedure TabWall.AttachVisual;
begin
end;
{ @end $5018B4 }

{ @routine $5018C0 TabWall_QueueImageLoad }
procedure TabWall.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
end;
{ @end $5018C0 }

{ @routine $5018D4 TabWall_ApplyDamage }
procedure TabWall.ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean);
var
  Line, Next, Auxiliary: PabStopLine;
  Changed: Boolean;
begin
  if Health > 0 then
  begin
    inherited ApplyDamage(Amount, Source, Disrupt);
    if (Health <= 0) and (StopPoint <> nil) then
    begin
      Changed := False;
      Line := FirstStopLine;
      while Line <> nil do
      begin
        // The first endpoint bypasses the Collidable test in the native code.
        if (StopPoint = Line.First) or ((StopPoint = Line.Last) and Line.Collidable) then
        begin
          Line.Collidable := False;
          Changed := True;
          Next := FirstStopLine;
          while Next <> nil do
          begin
            Auxiliary := Next;
            Next := Next.Next;
            if Auxiliary.UserValue = Integer(Line) then ab_StopLine_Delete(Auxiliary);
          end;
        end;
        Line := Line.Next;
      end;
      if Changed then ab_StopLine_BuildCollisionList;
    end;
    if Health <= 0 then
    begin
      Zone.DamagePerTick := 0;
      Zone.GravityStrength := 0;
    end;
  end;
end;
{ @end $5018D4 }

{ @routine $5019F0 TabWall_UpdateState }
procedure TabWall.UpdateState;
begin
  inherited UpdateState;
end;
{ @end $5019F0 }

{ @routine $501A04 TabWall_Advance }
procedure TabWall.Advance;
begin
  if Health = 0 then
  begin
    Velocity := MakePointF(0, 0);
    Thrust := 0;
    if WorldImage <> nil then
    begin
      ab_WorldImage_Delete(WorldImage);
      WorldImage := nil;
    end;
  end
  else if WorldImage <> nil then
    ab_WorldImage_SetPosition(WorldImage, GetWorldPosition);
end;
{ @end $501A04 }

{ @routine $501A94 TabWall_UpdateVisuals }
procedure TabWall.UpdateVisuals;
var
  Frame: Integer;
  Value: Single;
  Position: TVector3D;
begin
  inherited UpdateVisuals;
  if (WorldImage <> nil) and (WorldImage.Image.GaiImageControl <> nil) then
  begin
    Position := GetWorldPosition;
    Position := ProjectPointByMatrix(SphereProjectionMatrix, Position);
    Value := RadiansToHeadingDegrees(ArcTan2(Position.X, -Position.Y));
    Frame := Round(Value / 360 * DirectionFrameCount);
    if Frame >= DirectionFrameCount then Frame := 0;
    Value := Sqrt(Sqr(Position.X) + Sqr(Position.Y)) / SphereProjectedRadius;
    Inc(Frame, Round((WorldImage.Image.GaiImageControl.SequenceFrameCount / DirectionFrameCount - 1) * Value) * DirectionFrameCount);
    WorldImage.Image.GaiImageControl.SetSequenceFrame(Frame);
  end;
end;
{ @end $501A94 }

{ @routine $501BE4 ab_Wall_FindZone }
function ab_Wall_FindZone(Zone: PabZone): TabWall;
var
  Obj: TabObject;
begin
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if (Obj is TabWall) and (TabWall(Obj).Zone = Zone) then
    begin
      Result := Obj as TabWall;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Result := nil;
end;
{ @end $501BE4 }

{ @routine $501CB4 ab_Wall_BuildBarrierImages }
procedure ab_Wall_BuildBarrierImages;
var
  Line, ImageLine: PabStopLine;
  First, Last: PabStopPoint;
  Index: Integer;

  // @nested $501C4C FindStopPoint
  function FindStopPoint(Point: PabStopPoint): TabWall; // @addr $501C4C @calls "0x501ce2,0x501CF7"
  var
    Obj: TabObject;
  begin
    Obj := FirstArcadeObject;
    while Obj <> nil do
    begin
      if (Obj is TabWall) and (TabWall(Obj).StopPoint = Point) then
      begin
        Result := Obj as TabWall;
        Exit;
      end;
      Obj := Obj.Next;
    end;
    Result := nil;
  end;

begin
  Line := FirstStopLine;
  while Line <> nil do
  begin
    if Line.Collidable and (FindStopPoint(Line.First) <> nil) and (FindStopPoint(Line.Last) <> nil) then
    begin
      ImageLine := ab_StopLine_Add;
      ImageLine.UserValue := Integer(Line);
      ImageLine.First := Line.First;
      ImageLine.Last := Line.Last;
      ImageLine.FirstColor := @BarrierColor;
      ImageLine.LastColor := @BarrierColor;
      ImageLine.Collidable := False;
      ImageLine.Visible := True;
      for Index := 0 to 1 do
      begin
        First := ab_StopPoint_Add;
        First.Radius := (Index + 1) * 20 + SphereRadius;
        First.Longitude := ImageLine.First.Longitude;
        First.PolarAngle := ImageLine.First.PolarAngle;
        First.Kind := 1;
        ab_StopPoint_UpdatePosition(First);
        Last := ab_StopPoint_Add;
        Last.Radius := (Index + 1) * 20 + SphereRadius;
        Last.Longitude := ImageLine.Last.Longitude;
        Last.PolarAngle := ImageLine.Last.PolarAngle;
        Last.Kind := 1;
        ab_StopPoint_UpdatePosition(Last);
        ImageLine := ab_StopLine_Add;
        ImageLine.UserValue := Integer(Line);
        ImageLine.First := First;
        ImageLine.Last := Last;
        ImageLine.FirstColor := @BarrierHaloColors[Index];
        ImageLine.LastColor := @BarrierHaloColors[Index];
        ImageLine.Collidable := False;
        ImageLine.Visible := True;
      end;
    end;
    Line := Line.Next;
  end;
end;
{ @end $501CB4 }

end.
