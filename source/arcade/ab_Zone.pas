unit ab_Zone;
// Unit bracket (inferred): .text 0x0068C938..0x0068DF33; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native zone and link region: $68C954..$68DF34; original unit boundary unresolved.

interface

uses Classes, EC_Buf, EC_Struct, GI_PolyLine, GI_Tail, ab_Global, ab_WorldImage, ab_WorldLine;

type
  TabZoneWorldLines = array of PabWorldLine;
  PabZone = ^TabZone;
  TabZone = record // @size $90
    Prev: PabZone; // @offset $00
    Next: PabZone; // @offset $04
    RouteIndex: Integer; // @offset $08
    Longitude: Double; // @offset $10
    PolarAngle: Double; // @offset $18
    RadiusDegrees: Double; // @offset $20
    Radius: Double; // @offset $28
    Position: TVector3D; // @offset $30
    RouteDistance: Double; // @offset $48
    Routes: TList; // @offset $50
    WorldLines: array of PabWorldLine; // @offset $54
    WorldImage: PabWorldImage; // @offset $58
    Name: WideString; // @offset $5C
    BarrierHealth: Integer; // @offset $60  Initial wall health for kinds 5..8; TfAB.EnterCurrentSpace ($696B68).
    GravityStrength: Integer; // @offset $64  Signed attraction/repulsion strength.
    DamagePerTick: Integer; // @offset $68  Negative values heal.
    BonusFlags: Cardinal; // @offset $6C Low eight bits select bonuses; bit 31 conceals the bonus icon.
    BonusRespawnClass: Integer; // @offset $70 Selects a min/max pair in BonusRespawnSeconds (three intervals).
    NextBonusTick: Integer; // @offset $74 -1 while a spawned bonus is present.
    Kind: Integer; // @offset $78  Native numeric tags retained; <5 participates in route tables.
    Segments: array[0..3] of PPolyLineSegmentGI; // @offset $7C
  end;

  PabZoneLink = ^TabZoneLink;
  TabZoneLink = record // @size $28
    Prev: PabZoneLink; // @offset $00
    Next: PabZoneLink; // @offset $04
    First: PabZone; // @offset $08
    Last: PabZone; // @offset $0C
    Distance: Double; // @offset $10
    BarrierLinkMode: Integer; // @offset $18  Mode 1 creates collidable links between compatible barrier zones ($696B68).
    WorldLine: PabWorldLine; // @offset $1C
    Segments: array[0..1] of PPolyLineSegmentGI; // @offset $20
  end;

procedure ab_Zone_Clear; // @addr $68C954
function ab_Zone_Add: PabZone; // @addr $68C988
procedure ab_Zone_Delete(Zone: PabZone); // @addr $68CA48
procedure ab_Zone_UpdatePosition(Zone: PabZone); // @addr $68CBD0
procedure ab_Zone_UpdateImages(Zone: PabZone); // @addr $68CC60
procedure ab_Zone_ClearImages; // @addr $68D03C
procedure ab_Zone_ClearSegments(Zone: PabZone); // @addr $68D0F4
function ab_Zone_CountKind(Kind: Integer): Integer; // @addr $68D144
function ab_Zone_Get(Index: Integer): PabZone; // @addr $68D184
function ab_Zone_GetKind(Kind, Index: Integer): PabZone; // @addr $68D1C8
procedure ab_ZoneLink_Clear; // @addr $68D21C
function ab_ZoneLink_Add: PabZoneLink; // @addr $68D250
procedure ab_ZoneLink_Delete(Link: PabZoneLink); // @addr $68D314
procedure ab_ZoneLink_UpdateDistance(Link: PabZoneLink); // @addr $68D3C0
procedure ab_ZoneLink_ClearImages; // @addr $68D41C
procedure ab_ZoneLink_ClearSegments(Link: PabZoneLink); // @addr $68D45C
procedure ab_Zone_Load(Buffer: TBufEC); // @addr $68D4AC
function ab_Zone_RandomKind(Kind: Integer): PabZone; // @addr $68D638
function ab_Zone_RandomPosition(Zone: PabZone): TSphericalBearingState; // @addr $68D668 @ida "void __usercall $name(TabZone *Zone@<eax>, TSphericalBearingState *Result@<edx>);"
function ab_Zone_FindContainingOrNearest(Longitude, PolarAngle: Double; var Nearest: PabZone): Boolean; // @addr $68D6E4 @ida "bool __userpurge $name@<al>(double Longitude@<^8>, double PolarAngle@<^0>, TabZone **Nearest@<eax>);"
function ab_Zone_FindNearestOutside(Longitude, PolarAngle: Double): PabZone; // @addr $68D7C4 @ida "TabZone *__userpurge $name@<eax>(double Longitude@<^8>, double PolarAngle@<^0>);"
function ab_Zone_FindNearestEnabled(Longitude, PolarAngle: Double): PabZone; // @addr $68D870 @ida "TabZone *__userpurge $name@<eax>(double Longitude@<^8>, double PolarAngle@<^0>);"
function ab_Zone_IsInsideKind10(Longitude, PolarAngle: Double): Boolean; // @addr $68D940 @ida "bool __userpurge $name@<al>(double Longitude@<^8>, double PolarAngle@<^0>);"

function ab_Zone_FindRoute(Source, Target: PabZone): PabZone; // @addr $68DA90
procedure ab_Zone_BuildRoutes(Zone: PabZone); // @addr $68DBB8
procedure ab_Zone_BuildAllRoutes; // @addr $68DC2C
function ab_Zone_GetRoute(Source, Target: PabZone): PabZone; // @addr $68DC78
function ab_Zone_IsHeadingInside(Source: TSphericalBearingState; Zone: PabZone; var BearingDelta, AngularRadius: Double): Boolean; // @addr $68DCB0 @ida "bool __userpurge $name@<al>(TSphericalBearingState *Source@<eax>, TabZone *Zone@<edx>, double *BearingDelta@<ecx>, double *AngularRadius@<^0>);"
function ab_Zone_FindReachableRouteZone(Source: PabZone): PabZone; // @addr $68DD78
function ab_Zone_RandomRoute(Source: PabZone; Steps: Integer): PabZone; // @addr $68DE74

var
  ZoneHeap: Cardinal = 0; // @addr $87B848
  FirstZone: PabZone = nil; // @addr $87B84C
  LastZone: PabZone = nil; // @addr $87B850
  SelectedZone: PabZone = nil; // @addr $87B854
  ZoneLinkHeap: Cardinal = 0; // @addr $87B858
  FirstZoneLink: PabZoneLink = nil; // @addr $87B85C
  LastZoneLink: PabZoneLink = nil; // @addr $87B860
  SelectedZoneLink: PabZoneLink = nil; // @addr $87B864

implementation

uses Windows, SysUtils, Math, EC_Mem, GR_Main, Globals, aMyFunction, ab_StopLine;

{ @routine $68C954 ab_Zone_Clear }
procedure ab_Zone_Clear;
begin
  while not (FirstZone = nil) do ab_Zone_Delete(LastZone);
  if ZoneHeap <> 0 then
  begin
    HeapDestroy(ZoneHeap);
    ZoneHeap := 0;
  end;
end;
{ @end $68C954 }

{ @routine $68C988 ab_Zone_Add }
function ab_Zone_Add: PabZone;
var
  Entry: PabZone;
begin
  if ZoneHeap = 0 then
  begin
    ZoneHeap := HeapCreate(1, $8000, 0);
    if ZoneHeap = 0 then raise Exception.Create('ab_Zone_Add.HeapCreate');
  end;
  Entry := AllocClearFromHeapEC(ZoneHeap, SizeOf(TabZone));
  if LastZone <> nil then LastZone.Next := Entry;
  Entry.Prev := LastZone;
  Entry.Next := nil;
  LastZone := Entry;
  if FirstZone = nil then FirstZone := Entry;
  Result := Entry;
end;
{ @end $68C988 }

{ @routine $68CA48 ab_Zone_Delete }
procedure ab_Zone_Delete(Zone: PabZone);
var
  Index: Integer;
  Link, NextLink: PabZoneLink;
begin
  if Zone.Prev <> nil then Zone.Prev.Next := Zone.Next;
  if Zone.Next <> nil then Zone.Next.Prev := Zone.Prev;
  if LastZone = Zone then LastZone := Zone.Prev;
  if FirstZone = Zone then FirstZone := Zone.Next;
  Link := FirstZoneLink;
  while Link <> nil do
  begin
    NextLink := Link;
    Link := Link.Next;
    if (NextLink.First = Zone) or (NextLink.Last = Zone) then ab_ZoneLink_Delete(NextLink);
  end;
  if Zone.WorldLines <> nil then
  begin
    for Index := 0 to High(Zone.WorldLines) do
      if Zone.WorldLines[Index] <> nil then
      begin
        ab_WorldLine_Delete(Zone.WorldLines[Index]);
        Zone.WorldLines[Index] := nil;
      end;
    Zone.WorldLines := nil;
  end;
  if Zone.WorldImage <> nil then
  begin
    ab_WorldImage_Delete(Zone.WorldImage);
    Zone.WorldImage := nil;
  end;
  ab_Zone_ClearSegments(Zone);
  if Zone.Routes <> nil then
  begin
    Zone.Routes.Free;
    Zone.Routes := nil;
  end;
  if SelectedZone = Zone then SelectedZone := nil;
  Zone.WorldImage := nil;
  Zone.Name := '';
  if ZoneHeap <> 0 then FreeFromHeapEC(ZoneHeap, Zone);
end;
{ @end $68CA48 }

{ @routine $68CBD0 ab_Zone_UpdatePosition }
procedure ab_Zone_UpdatePosition(Zone: PabZone);
begin
  Zone.Radius := Pi * SphereRadius * Zone.RadiusDegrees / 180;
  Zone.Position := SphericalToVector3D(HeadingDegreesToRadians(Zone.Longitude), HeadingDegreesToRadians(Zone.PolarAngle), SphereRadius);
end;
{ @end $68CBD0 }

{ @routine $68CC60 ab_Zone_UpdateImages }
procedure ab_Zone_UpdateImages(Zone: PabZone);
var
  Index: Integer;
  Bearing, Step: Double;
  Color: Cardinal;
  Last, First: TVector3D;
  FirstState, LastState: TSphericalBearingState;
begin
  if Zone.Kind = 1 then Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255)
  else if Zone.Kind = 2 then Color := CurrentPixelFormat.PackRgbBytes(255, 0, 0)
  else if Zone.Kind = 3 then Color := CurrentPixelFormat.PackRgbBytes(0, 255, 0)
  else if Zone.Kind = 4 then Color := CurrentPixelFormat.PackRgbBytes(0, 0, 255)
  else if Zone.Kind = 5 then Color := CurrentPixelFormat.PackRgbBytes(0, 155, 155)
  else if Zone.Kind = 6 then Color := CurrentPixelFormat.PackRgbBytes(0, 255, 255)
  else if Zone.Kind = 20 then Color := CurrentPixelFormat.PackRgbBytes(255, 255, 0)
  else Color := CurrentPixelFormat.PackRgbBytes(200, 200, 0);
  if Zone.WorldLines = nil then
  begin
    SetLength(Zone.WorldLines, 32);
    for Index := 0 to High(Zone.WorldLines) do Zone.WorldLines[Index] := nil;
  end;
  for Index := 0 to High(Zone.WorldLines) do
    if Zone.WorldLines[Index] = nil then
      Zone.WorldLines[Index] := ab_WorldLine_Create(MakeVector3D(0, 0, 0), MakeVector3D(0, 0, 0), 1, Color, 0, False);
  Step := 360 / ((High(Zone.WorldLines) + 1) - 1);
  Bearing := -Step;
  FirstState := AdvanceSphericalStateOnCurrentSphere(MakeSphericalBearingState(Zone.Longitude, Zone.PolarAngle, Bearing), Zone.Radius);
  First := SphericalToVector3D(HeadingDegreesToRadians(FirstState.LongitudeDegrees), HeadingDegreesToRadians(FirstState.PolarAngleDegrees), SphereRadius);
  for Index := 0 to High(Zone.WorldLines) do
  begin
    Bearing := Bearing + Step;
    LastState := AdvanceSphericalStateOnCurrentSphere(MakeSphericalBearingState(Zone.Longitude, Zone.PolarAngle, Bearing), Zone.Radius);
    Last := SphericalToVector3D(HeadingDegreesToRadians(LastState.LongitudeDegrees), HeadingDegreesToRadians(LastState.PolarAngleDegrees), SphereRadius);
    ab_WorldLine_Set(Zone.WorldLines[Index], First, Last, 1, Color, 0, False);
    First := Last;
  end;
  if Zone.Kind <> 20 then
  begin
    if Zone.WorldImage = nil then
      Zone.WorldImage := ab_WorldImage_Create(Zone.Position, 'GI,Bm.PI.Path4', '', False)
    else
      ab_WorldImage_Set(Zone.WorldImage, Zone.Position, 'GI,Bm.PI.Path4', '');
  end;
end;
{ @end $68CC60 }

{ @routine $68D03C ab_Zone_ClearImages }
procedure ab_Zone_ClearImages;
var
  Zone: PabZone;
  Index: Integer;
begin
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Zone.WorldLines <> nil then
    begin
      for Index := 0 to High(Zone.WorldLines) do
        if Zone.WorldLines[Index] <> nil then
        begin
          ab_WorldLine_Delete(Zone.WorldLines[Index]);
          Zone.WorldLines[Index] := nil;
        end;
      Zone.WorldLines := nil;
    end;
    if Zone.WorldImage <> nil then
    begin
      ab_WorldImage_Delete(Zone.WorldImage);
      Zone.WorldImage := nil;
    end;
    Zone := Zone.Next;
  end;
end;
{ @end $68D03C }

{ @routine $68D0F4 ab_Zone_ClearSegments }
procedure ab_Zone_ClearSegments(Zone: PabZone);
var
  Index: Integer;
begin
  for Index := 0 to 3 do
    if Zone.Segments[Index] <> nil then
    begin
      ArcadeBattleScreen.WorldLines.RetireSegment(Zone.Segments[Index]);
      Zone.Segments[Index] := nil;
    end;
end;
{ @end $68D0F4 }

{ @routine $68D144 ab_Zone_CountKind }
function ab_Zone_CountKind(Kind: Integer): Integer;
var
  Zone: PabZone;
begin
  Result := 0;
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Zone.Kind = Kind then Inc(Result);
    Zone := Zone.Next;
  end;
end;
{ @end $68D144 }

{ @routine $68D184 ab_Zone_Get }
function ab_Zone_Get(Index: Integer): PabZone;
var
  Zone: PabZone;
begin
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Index = 0 then
    begin
      Result := Zone;
      Exit;
    end;
    Dec(Index);
    Zone := Zone.Next;
  end;
  Result := nil;
end;
{ @end $68D184 }

{ @routine $68D1C8 ab_Zone_GetKind }
function ab_Zone_GetKind(Kind, Index: Integer): PabZone;
var
  Zone: PabZone;
begin
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Zone.Kind = Kind then
    begin
      if Index = 0 then
      begin
        Result := Zone;
        Exit;
      end;
      Dec(Index);
    end;
    Zone := Zone.Next;
  end;
  Result := nil;
end;
{ @end $68D1C8 }

{ @routine $68D21C ab_ZoneLink_Clear }
procedure ab_ZoneLink_Clear;
begin
  while not (FirstZoneLink = nil) do ab_ZoneLink_Delete(LastZoneLink);
  if ZoneLinkHeap <> 0 then
  begin
    HeapDestroy(ZoneLinkHeap);
    ZoneLinkHeap := 0;
  end;
end;
{ @end $68D21C }

{ @routine $68D250 ab_ZoneLink_Add }
function ab_ZoneLink_Add: PabZoneLink;
var
  Entry: PabZoneLink;
begin
  if ZoneLinkHeap = 0 then
  begin
    ZoneLinkHeap := HeapCreate(1, $8000, 0);
    if ZoneLinkHeap = 0 then raise Exception.Create('ab_ZoneLink_Add.HeapCreate');
  end;
  Entry := AllocClearFromHeapEC(ZoneLinkHeap, SizeOf(TabZoneLink));
  if LastZoneLink <> nil then LastZoneLink.Next := Entry;
  Entry.Prev := LastZoneLink;
  Entry.Next := nil;
  LastZoneLink := Entry;
  if FirstZoneLink = nil then FirstZoneLink := Entry;
  Result := Entry;
end;
{ @end $68D250 }

{ @routine $68D314 ab_ZoneLink_Delete }
procedure ab_ZoneLink_Delete(Link: PabZoneLink);
begin
  if Link.Prev <> nil then Link.Prev.Next := Link.Next;
  if Link.Next <> nil then Link.Next.Prev := Link.Prev;
  if LastZoneLink = Link then LastZoneLink := Link.Prev;
  if FirstZoneLink = Link then FirstZoneLink := Link.Next;
  if Link.WorldLine <> nil then
  begin
    ab_WorldLine_Delete(Link.WorldLine);
    Link.WorldLine := nil;
  end;
  ab_ZoneLink_ClearSegments(Link);
  if SelectedZoneLink = Link then SelectedZoneLink := nil;
  if ZoneLinkHeap <> 0 then FreeFromHeapEC(ZoneLinkHeap, Link);
end;
{ @end $68D314 }

{ @routine $68D3C0 ab_ZoneLink_UpdateDistance }
procedure ab_ZoneLink_UpdateDistance(Link: PabZoneLink);
var
  Bearing: Double;
begin
  ComputeSphericalBearingAndDistance(Bearing, Link.Distance, Link.First.Longitude, Link.First.PolarAngle, 0, Link.Last.Longitude, Link.Last.PolarAngle, SphereRadius);
end;
{ @end $68D3C0 }

{ @routine $68D41C ab_ZoneLink_ClearImages }
procedure ab_ZoneLink_ClearImages;
var
  Link: PabZoneLink;
begin
  Link := FirstZoneLink;
  while Link <> nil do
  begin
    if Link.WorldLine <> nil then
    begin
      ab_WorldLine_Delete(Link.WorldLine);
      Link.WorldLine := nil;
    end;
    Link := Link.Next;
  end;
end;
{ @end $68D41C }

{ @routine $68D45C ab_ZoneLink_ClearSegments }
procedure ab_ZoneLink_ClearSegments(Link: PabZoneLink);
var
  Index: Integer;
begin
  for Index := 0 to 1 do
    if Link.Segments[Index] <> nil then
    begin
      ArcadeBattleScreen.WorldLines.RetireSegment(Link.Segments[Index]);
      Link.Segments[Index] := nil;
    end;
end;
{ @end $68D45C }

{ @routine $68D4AC ab_Zone_Load }
procedure ab_Zone_Load(Buffer: TBufEC);
var
  Index, Count: Integer;
  Zone: PabZone;
  Link: PabZoneLink;
begin
  ab_ZoneLink_Clear;
  ab_Zone_Clear;
  Count := Buffer.GetInt32;
  for Index := 0 to Count - 1 do
  begin
    Zone := ab_Zone_Add;
    Zone.Longitude := Buffer.GetSingle;
    Zone.PolarAngle := Buffer.GetSingle;
    Zone.RadiusDegrees := Buffer.GetSingle;
    Zone.Kind := Buffer.GetInt32;
    Zone.Name := Buffer.ReadWideString;
    Zone.BarrierHealth := Buffer.GetInt32;
    Zone.GravityStrength := Buffer.GetInt32;
    Zone.DamagePerTick := Buffer.GetInt32;
    Zone.BonusFlags := Buffer.GetUInt32;
    Zone.BonusRespawnClass := Buffer.GetInt32;
    ab_Zone_UpdatePosition(Zone);
  end;
  Count := Buffer.GetInt32;
  for Index := 0 to Count - 1 do
  begin
    Link := ab_ZoneLink_Add;
    Link.First := ab_Zone_Get(Buffer.GetInt32);
    Link.Last := ab_Zone_Get(Buffer.GetInt32);
    Link.BarrierLinkMode := Buffer.GetInt32;
    ab_ZoneLink_UpdateDistance(Link);
  end;
end;
{ @end $68D4AC }

{ @routine $68D638 ab_Zone_RandomKind }
function ab_Zone_RandomKind(Kind: Integer): PabZone;
begin
  Result := ab_Zone_GetKind(Kind, RandomIntRange(0, ab_Zone_CountKind(Kind) - 1));
end;
{ @end $68D638 }

{ @routine $68D668 ab_Zone_RandomPosition }
function ab_Zone_RandomPosition(Zone: PabZone): TSphericalBearingState;
begin
  Result := AdvanceSphericalStateOnCurrentSphere(MakeSphericalBearingState(Zone.Longitude, Zone.PolarAngle, RandomIntRange(0, 360)), Random * Zone.Radius / 2 + Zone.Radius / 4);
end;
{ @end $68D668 }

{ @routine $68D6E4 ab_Zone_FindContainingOrNearest }
function ab_Zone_FindContainingOrNearest(Longitude, PolarAngle: Double; var Nearest: PabZone): Boolean;
var
  Zone: PabZone;
  Distance, BestDistance: Double;
begin
  Result := False;
  Nearest := nil;
  if FirstZone <> nil then
  begin
    BestDistance := 1e20;
    Zone := FirstZone;
    while Zone <> nil do
    begin
      if Zone.Kind < 5 then
      begin
        ComputeSphericalDistance(Distance, Zone.Longitude, Zone.PolarAngle, 0, Longitude, PolarAngle, SphereRadius);
        if Distance < Zone.Radius then
        begin
          Result := True;
          Nearest := Zone;
          Exit;
        end;
        if Distance - Zone.Radius < BestDistance then
        begin
          BestDistance := Distance - Zone.Radius;
          Nearest := Zone;
        end;
      end;
      Zone := Zone.Next;
    end;
  end;
end;
{ @end $68D6E4 }

{ @routine $68D7C4 ab_Zone_FindNearestOutside }
function ab_Zone_FindNearestOutside(Longitude, PolarAngle: Double): PabZone;
var
  Zone: PabZone;
  Distance, BestDistance: Double;
begin
  BestDistance := 1e20;
  Result := nil;
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Zone.Kind <= 1 then
    begin
      ComputeSphericalDistance(Distance, Zone.Longitude, Zone.PolarAngle, 0, Longitude, PolarAngle, SphereRadius);
      if (Distance > Zone.Radius) and (Distance < BestDistance) then
      begin
        BestDistance := Distance;
        Result := Zone;
      end;
    end;
    Zone := Zone.Next;
  end;
end;
{ @end $68D7C4 }

{ @routine $68D870 ab_Zone_FindNearestEnabled }
function ab_Zone_FindNearestEnabled(Longitude, PolarAngle: Double): PabZone;
var
  Zone: PabZone;
  Bearing, Distance, BestDistance: Double;
begin
  Result := nil;
  if FirstZone <> nil then
  begin
    BestDistance := 1e20;
    Zone := FirstZone;
    while Zone <> nil do
    begin
      if Zone.GravityStrength <> 0 then
      begin
        ComputeSphericalBearingAndDistance(Bearing, Distance, Zone.Longitude, Zone.PolarAngle, 0, Longitude, PolarAngle, SphereRadius);
        if Distance < Zone.Radius then
        begin
          Result := Zone;
          Exit;
        end;
        if Distance - Zone.Radius < BestDistance then
        begin
          BestDistance := Distance - Zone.Radius;
          Result := Zone;
        end;
      end;
      Zone := Zone.Next;
    end;
  end;
end;
{ @end $68D870 }

{ @routine $68D940 ab_Zone_IsInsideKind10 }
function ab_Zone_IsInsideKind10(Longitude, PolarAngle: Double): Boolean;
var
  Zone: PabZone;
  Distance: Double;
begin
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Zone.Kind = 10 then
    begin
      ComputeSphericalDistance(Distance, Zone.Longitude, Zone.PolarAngle, 0, Longitude, PolarAngle, SphereRadius);
      if Distance < Zone.Radius then
      begin
        Result := True;
        Exit;
      end;
    end;
    Zone := Zone.Next;
  end;
  Result := False;
end;
{ @end $68D940 }

{ @routine $68DA90 ab_Zone_FindRoute }
function ab_Zone_FindRoute(Source, Target: PabZone): PabZone;
var
  Zone: PabZone;
  Link: PabZoneLink;
  BestDistance: Double;

  // @nested $68D9C4 PropagateZoneDistances
  procedure PropagateZoneDistances(Zone: PabZone); // @addr $68D9C4 @ida "void __usercall $name(TabZone *Zone@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x68da25,0x68da73,0x68db01"
  var
    Link: PabZoneLink;
  begin
    Link := FirstZoneLink;
    while Link <> nil do
    begin
      if Link.First = Zone then
      begin
        if Zone.RouteDistance + Link.Distance < Link.Last.RouteDistance then
        begin
          Link.Last.RouteDistance := Zone.RouteDistance + Link.Distance;
          PropagateZoneDistances(Link.Last);
        end;
      end
      else if Link.Last = Zone then
        if Zone.RouteDistance + Link.Distance < Link.First.RouteDistance then
        begin
          Link.First.RouteDistance := Zone.RouteDistance + Link.Distance;
          PropagateZoneDistances(Link.First);
        end;
      Link := Link.Next;
    end;
  end;

begin
  if (FirstZone = LastZone) or (FirstZoneLink = nil) or (Source = Target) then
  begin
    Result := nil;
    Exit;
  end;
  Zone := FirstZone;
  while Zone <> nil do
  begin
    Zone.RouteDistance := 1e20;
    Zone := Zone.Next;
  end;
  Target.RouteDistance := 0;
  PropagateZoneDistances(Target);
  Result := nil;
  BestDistance := 1e20;
  Link := FirstZoneLink;
  while Link <> nil do
  begin
    if Link.First = Source then
    begin
      if Link.Last.RouteDistance < BestDistance then
      begin
        BestDistance := Link.Last.RouteDistance;
        Result := Link.Last;
      end;
    end
    else if Link.Last = Source then
      if Link.First.RouteDistance < BestDistance then
      begin
        BestDistance := Link.First.RouteDistance;
        Result := Link.First;
      end;
    Link := Link.Next;
  end;
end;
{ @end $68DA90 }

{ @routine $68DBB8 ab_Zone_BuildRoutes }
procedure ab_Zone_BuildRoutes(Zone: PabZone);
var
  Target: PabZone;
begin
  if Zone.Routes = nil then Zone.Routes := TList.Create;
  Zone.Routes.Clear;
  Target := FirstZone;
  while Target <> nil do
  begin
    if Target.Kind < 5 then Zone.Routes.Add(ab_Zone_FindRoute(Zone, Target));
    Target := Target.Next;
  end;
end;
{ @end $68DBB8 }

{ @routine $68DC2C ab_Zone_BuildAllRoutes }
procedure ab_Zone_BuildAllRoutes;
var
  Zone: PabZone;
  Index: Integer;
begin
  Index := 0;
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if Zone.Kind < 5 then
    begin
      Zone.RouteIndex := Index;
      ab_Zone_BuildRoutes(Zone);
      Inc(Index);
    end;
    Zone := Zone.Next;
  end;
end;
{ @end $68DC2C }

{ @routine $68DC78 ab_Zone_GetRoute }
function ab_Zone_GetRoute(Source, Target: PabZone): PabZone;
begin
  if Target.Kind >= 5 then Result := nil
  else Result := Source.Routes[Target.RouteIndex];
end;
{ @end $68DC78 }

{ @routine $68DCB0 ab_Zone_IsHeadingInside }
function ab_Zone_IsHeadingInside(Source: TSphericalBearingState; Zone: PabZone; var BearingDelta, AngularRadius: Double): Boolean;
var
  Bearing, Distance: Double;
begin
  ComputeSphericalBearingAndDistance(Bearing, Distance, Source.LongitudeDegrees, Source.PolarAngleDegrees, Source.BearingDegrees, Zone.Longitude, Zone.PolarAngle, SphereRadius);
  if Zone.Radius >= Distance then
  begin
    Result := True;
    BearingDelta := 0;
  end
  else
  begin
    AngularRadius := RadiansToHeadingDegrees(Math.ArcSin(Zone.Radius / Distance));
    Result := Abs(Bearing) < AngularRadius;
    BearingDelta := Bearing;
  end;
end;
{ @end $68DCB0 }

{ @routine $68DD78 ab_Zone_FindReachableRouteZone }
function ab_Zone_FindReachableRouteZone(Source: PabZone): PabZone;
var
  Zone: PabZone;
  BestDistance, Distance: Double;
begin
  if Source.Kind < 5 then
  begin
    Result := Source;
    Exit;
  end;
  Result := nil;
  BestDistance := 1e20;
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if (Zone <> Source) and (Zone.Kind < 5) then
    begin
      ComputeSphericalDistance(Distance, Source.Longitude, Source.PolarAngle, 0, Zone.Longitude, Zone.PolarAngle, SphereRadius);
      if (Distance < BestDistance) and not ab_StopLine_IsBlocked(Source.Longitude, Source.PolarAngle, Zone.Longitude, Zone.PolarAngle) then
      begin
        Result := Zone;
        BestDistance := Distance;
      end;
    end;
    Zone := Zone.Next;
  end;
end;
{ @end $68DD78 }

{ @routine $68DE74 ab_Zone_RandomRoute }
function ab_Zone_RandomRoute(Source: PabZone; Steps: Integer): PabZone;
var
  Current, Candidate: PabZone;
  Attempts: Integer;
begin
  Result := nil;
  if (Source.Routes = nil) or (Source.Routes.Count < 1) then Exit;
  Current := Source;
  while Steps > 0 do
  begin
    Dec(Steps);
    Attempts := 5;
    while Attempts > 0 do
    begin
      Dec(Attempts);
      Candidate := Current.Routes[RandomIntRange(0, Current.Routes.Count - 1)];
      if (Candidate <> nil) and (Candidate.Routes <> nil) and (Candidate.Routes.Count >= 1) and (Candidate <> Source) and (Candidate <> Current) then
      begin
        Current := Candidate;
        Break;
      end;
    end;
    if Attempts <= 0 then Exit;
  end;
  Result := Current;
end;
{ @end $68DE74 }

end.
