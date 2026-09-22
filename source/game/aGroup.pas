unit aGroup;
// Unit bracket (inferred): .text 0x004EE15C..0x004EEEA8; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Buf, EC_Struct, Windows, aGalaxy, aShip;

type
  // Ordinal 1 is unused by the recovered route logic.
  TGroupWaitMode = (GroupWaitArrival = 0, GroupWaitAssembly = 2, GroupWaitUntilTurn = 3); // @size $01

  TGroupRouteOrder = record // @size $18
    Kind: TShipOrder; // @offset $00
    Target: TObject; // @offset $04 Serialized as an object ID until ResolveLoadedReferences.
    Destination: TPointF; // @offset $08
    WaitMode: TGroupWaitMode; // @offset $10
    WaitUntilTurn: Integer; // @offset $14
  end;
  TGroupRoute = array of TGroupRouteOrder;

  TGroup = class(TObjectEx) // @size 0x20
  public
    CreatedTurn: Integer; // @offset 0x04
    GenerationSeed: Cardinal; // @offset 0x08
    RandomState: Cardinal; // @offset 0x0C
    Ships: TList; // @offset 0x10  Borrowed TShip entries.
    Route: array of TGroupRouteOrder; // @offset $14 Owned route; references in each order are borrowed.
    TargetStar: TStar; // @offset 0x18  Destination of the liberation attack.
    AssemblyStar: TStar; // @offset 0x1C  Nearby Coalition staging system.
    function GetShipGreeting(Ship: Pointer): WideString; // @addr $4EF144 @ida "void __usercall $name(TGroup *Self@<eax>, TShip *Ship@<edx>, unsigned __int16 **Result@<ecx>);"
    procedure Save(Buffer: TBufEC); // @addr $4EE310
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr $4EE710 Rebinds ship and route target IDs after Load.
    function AreShipsAssembled: Boolean; // @addr $4EF028 Requires a nonempty member list; same route index, no land/jump order, and within 300 units.
    procedure AdvanceRouteForShips; // @addr $4EF0D8 Advances members in reverse order, detaching completed members.
    function FindCentralMemberStar: TStar; // @addr $4EF3B4 Chooses a member's current star minimizing summed rounded distances to all galaxy planets.
    procedure AddShip(Ship: TShip); // @addr 0x4EE958 @note "Appends Ship, assigns LiberationGroup and resets its order index."
    function SelectLiberationTarget: Boolean; // @addr 0x4EEA70 @note "Chooses TargetStar and a Coalition AssemblyStar within 28 parsecs. Failure disbands and frees Self."
    function BuildLiberationOrders: Boolean; // @addr 0x4EEB84 @note "Builds staging, landing and attack orders and publishes news. May disband and free Self when no suitable staging planet exists."
    constructor Create; // @addr 0x4EE1E0
    destructor Destroy; override; // @addr 0x4EE2C0
    procedure Load(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x4EE4FC @note "Ships initially contains serialized IDs, pending reference resolution. Does not clear existing entries."
    procedure NextDay; // @addr 0x4EE990 @note "May remove and free Self when empty or older than 150 days."
    procedure Disband; // @addr 0x4EE9FC @note "Detaches member ships, removes Self from Galaxy.LiberationGroups, and frees Self."
  end;

implementation

uses SysUtils, Math, aPlanet, aMyFunction, Globals, GlobalsV, aGalaxyStruct;

{ @routine $4EE1E0 TGroup_Create }
constructor TGroup.Create;
begin
  inherited Create;
  if Galaxy <> nil then begin
    CreatedTurn := Galaxy.CurrentTurn;
    GenerationSeed := SeededRandomIntRange(100000, MaxInt, Galaxy.GenerationSeed * Galaxy.CurrentTurn);
    RandomState := GenerationSeed;
  end;
  Ships := TList.Create;
  SetLength(Route, 0);
  Route := nil;
  TargetStar := nil;
  AssemblyStar := nil;
end;
{ @end $4EE1E0 }

{ @routine $4EE2C0 TGroup_Destroy }
destructor TGroup.Destroy;
begin
  if Ships <> nil then begin Ships.Free; Ships := nil; end;
  inherited Destroy;
end;
{ @end $4EE2C0 }

{ @routine $4EE310 TGroup_Save }
procedure TGroup.Save(Buffer: TBufEC);
var I, Count: Integer; Ship: TShip; Order: TGroupRouteOrder;
begin
  Buffer.AddWideChar(WideChar(CreatedTurn));
  Buffer.AddDWord(GenerationSeed);
  Buffer.AddDWord(RandomState);
  Buffer.AddAnsiChar(#0);
  Count := Ships.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin Ship := Ships[I]; Buffer.AddDWord(Ship.Id); end;
  Count := Length(Route);
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Order := Route[I];
    Buffer.AddAnsiChar(AnsiChar(Order.Kind));
    if Order.Kind = soJump then Buffer.AddDWord((Order.Target as TStar).Id)
    else if Order.Kind = soJumpHole then Buffer.AddDWord((Order.Target as THole).Id)
    else if Order.Kind = soLand then begin if Order.Target is TShip then Buffer.AddDWord(Cardinal((Order.Target as TShip).Id) or OrderTargetShipFlag)
         else Buffer.AddDWord((Order.Target as TPlanet).Id);
    end else if Order.Kind = soFollowShip then Buffer.AddDWord((Order.Target as TShip).Id)
    else Buffer.AddDWord(0);
    Buffer.AddSingle(Order.Destination.X);
    Buffer.AddSingle(Order.Destination.Y);
    Buffer.AddAnsiChar(AnsiChar(Order.WaitMode));
    Buffer.AddIntegerValue(Order.WaitUntilTurn);
  end;
end;
{ @end $4EE310 }

{ @routine $4EE4FC TGroup_Load }
procedure TGroup.Load(Buffer: TBufEC; Galaxy: TGalaxy);
var I, Count, OldestTurn: Integer;
begin
  CreatedTurn := Buffer.GetWord;
  OldestTurn := Galaxy.CurrentTurn - 1000;
  while CreatedTurn < OldestTurn do Inc(CreatedTurn, $10000);
  GenerationSeed := Buffer.GetUInt32;
  RandomState := Buffer.GetUInt32;
  Buffer.GetByte;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err TGroup.Load FShips');
  for I := 0 to Count - 1 do Ships.Add(Pointer(Buffer.GetUInt32));
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err TGroup.Load FOrders');
  SetLength(Route, Count);
  for I := 0 to Count - 1 do begin
    Route[I].Kind := TShipOrder(Buffer.GetByte);
    Route[I].Target := TObject(Buffer.GetUInt32);
    Route[I].Destination.X := Buffer.GetSingle;
    Route[I].Destination.Y := Buffer.GetSingle;
    Route[I].WaitMode := TGroupWaitMode(Buffer.GetByte);
    Route[I].WaitUntilTurn := Buffer.GetInt32;
  end;
end;
{ @end $4EE4FC }

{ @routine $4EE710 TGroup_ResolveLoadedReferences }
procedure TGroup.ResolveLoadedReferences(Galaxy: TGalaxy);
var I: Integer; Ship: TShip;
begin
  for I := 0 to Ships.Count - 1 do begin
    Ships[I] := TObject(Galaxy.IdToShip(Cardinal(Ships[I]), True)) as TShip;
    Ship := Ships[I];
    Ship.LiberationGroup := Self;
  end;
  for I := 0 to Length(Route) - 1 do begin
    if Route[I].Kind = soJump then Route[I].Target := TObject(Galaxy.IdToStar(Cardinal(Route[I].Target))) as TStar
    else if Route[I].Kind = soJumpHole then Route[I].Target := TObject(Galaxy.IdToHole(Cardinal(Route[I].Target))) as THole
    else if Route[I].Kind = soLand then begin if Cardinal(Route[I].Target) and OrderTargetShipFlag = OrderTargetShipFlag then
           Route[I].Target := TObject(Galaxy.IdToShip(Cardinal(Route[I].Target) and TaggedObjectIdMask, True)) as TShip
         else Route[I].Target := TObject(Galaxy.IdToPlanet(Cardinal(Route[I].Target))) as TPlanet;
    end else if Route[I].Kind = soFollowShip then Route[I].Target := TObject(Galaxy.IdToShip(Cardinal(Route[I].Target), True)) as TShip
    else Route[I].Target := nil;
    end;
end;
{ @end $4EE710 }

{ @routine $4EE958 TGroup_AddShip }
procedure TGroup.AddShip(Ship: TShip);
begin
  Ships.Add(Ship);
  Ship.LiberationGroup := Self;
  Ship.LiberationGroupRouteIndex := 0;
end;
{ @end $4EE958 }

{ @routine $4EE990 TGroup_NextDay }
procedure TGroup.NextDay;
begin
  if Ships.Count = 0 then begin
    Galaxy.LiberationGroups.Delete(Galaxy.LiberationGroups.IndexOf(Self));
    Free;
  end else if Galaxy.CurrentTurn > CreatedTurn + 150 then Disband;
end;
{ @end $4EE990 }

{ @routine $4EE9FC TGroup_Disband }
procedure TGroup.Disband;
var I: Integer; Ship: TShip;
begin
  for I := Ships.Count - 1 downto 0 do begin Ship := Ships[I]; Ship.LeaveLiberationGroup; end;
  Galaxy.LiberationGroups.Delete(Galaxy.LiberationGroups.IndexOf(Self));
  Free;
end;
{ @end $4EE9FC }

{ @routine $4EEA70 TGroup_SelectLiberationTarget }
function TGroup.SelectLiberationTarget: Boolean;
var Attempts: Integer;
begin
  TargetStar := Galaxy.SelectStarForLiberationAttack(FindCentralMemberStar, sfCoalition);
  Attempts := 0;
  while (TargetStar = nil) or TargetStar.HasLiberationGroupOrder or Galaxy.HasMilitaryBaseAssignedToStar(TargetStar) do begin
    if Attempts > 10 then begin
      TargetStar := nil;
      AssemblyStar := nil;
      Disband;
      Result := False;
      Exit;
    end;
    TargetStar := Galaxy.SelectStarForLiberationAttack(FindCentralMemberStar, sfCoalition);
    Inc(Attempts);
  end;
  AssemblyStar := TargetStar.FindNearestStarByFaction(sfCoalition, False);
  if (AssemblyStar = nil) or (PointDistance(AssemblyStar.Position, TargetStar.Position) > 28) then begin
    TargetStar := nil;
    AssemblyStar := nil;
    Result := False;
    Disband;
  end else Result := True;
end;
{ @end $4EEA70 }

{ @routine $4EEB84 TGroup_BuildLiberationOrders }
function TGroup.BuildLiberationOrders: Boolean;
var Planet: TPlanet; Text: WideString;
begin
  Result := True;
  if not (((TargetStar <> nil) and (AssemblyStar <> nil)) or SelectLiberationTarget) then Exit;
  SetLength(Route, 4);
  with Route[0] do begin Kind := soJump; Target := AssemblyStar; WaitMode := GroupWaitArrival; WaitUntilTurn := 0; end;
  Planet := TObject(AssemblyStar.FindFirstInhabitedPlanet) as TPlanet;
  if Planet = nil then begin Result := False; Disband; Exit; end;
  with Route[1] do begin Kind := soLand; Target := Planet; WaitMode := GroupWaitArrival; WaitUntilTurn := 0; end;
  with Route[2] do begin
    Kind := soMove;
    Target := nil;
    Destination := AssemblyStar.GetBoundaryPointTowardStar(TargetStar);
    WaitMode := GroupWaitUntilTurn;
    WaitUntilTurn := Galaxy.CurrentTurn + NextRandomIntRange(45, 55, RandomState);
  end;
  with Route[3] do begin Kind := soJump; Target := TargetStar; WaitMode := GroupWaitArrival; WaitUntilTurn := 0; end;
  if TargetStar.Status.CustomFaction <> '' then Text := PickLocalizedTextVariant('GalaxyNews.Group.WarriorLiberator.Create' + TargetStar.Status.CustomFaction, RandomState * (Galaxy.CurrentTurn mod 71))
  else if TargetStar.ControlFaction = sfPirates then Text := PickLocalizedTextVariant('GalaxyNews.Group.WarriorLiberator.CreatePirates', RandomState * (Galaxy.CurrentTurn mod 71))
  else Text := PickLocalizedTextVariant('GalaxyNews.Group.WarriorLiberator.Create', RandomState * (Galaxy.CurrentTurn mod 71));
  ReplaceTextToken(Text, '<StarNormal>', AssemblyStar.Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<StarEnemy>', TargetStar.Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<SectorNormal>', AssemblyStar.Constellation.GetName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<SectorEnemy>', TargetStar.Constellation.GetName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Route[2].WaitUntilTurn), TextHighlightColorTag);
  Galaxy.AddPlanetNews(gnLiberationGroupCreated, Text);
end;
{ @end $4EEB84 }

{ @routine $4EF028 TGroup_AreShipsAssembled }
function TGroup.AreShipsAssembled: Boolean;
var I, RouteIndex: Integer; Ship: TShip;
begin
  Ship := Ships[0];
  RouteIndex := Ship.LiberationGroupRouteIndex;
  for I := 0 to Ships.Count - 1 do begin
    Ship := Ships[I];
    if (Ship.LiberationGroupRouteIndex <> RouteIndex) or not (Ship.Order in [soNone, soMove]) or
      (PointDistanceSquared(Ship.Position, Route[RouteIndex].Destination) > 90000) then begin Result := False; Exit; end;
  end;
  Result := True;
end;
{ @end $4EF028 }

{ @routine $4EF0D8 TGroup_AdvanceRouteForShips }
procedure TGroup.AdvanceRouteForShips;
var I: Integer; Ship: TShip;
begin
  for I := Ships.Count - 1 downto 0 do begin
    Ship := Ships[I];
    Inc(Ship.LiberationGroupRouteIndex);
    if Ship.LiberationGroupRouteIndex >= Length(Route) then Ship.LeaveLiberationGroup
    else Ship.ProcessLiberationGroupRoute;
  end;
end;
{ @end $4EF0D8 }

{ @routine $4EF144 TGroup_GetShipGreeting }
function TGroup.GetShipGreeting(Ship: Pointer): WideString;
var Star: TStar;
begin
  Result := '';
  if TShip(Ship).LiberationGroupRouteIndex <> 0 then begin
    Star := Route[3].Target as TStar;
    if Galaxy.CurrentTurn < Route[2].WaitUntilTurn then
      Result := FormatText2(PickLocalizedTextVariant('ShipGreetings.Group.WarriorLiberatorBefore', NextRandomIntRange(100, 1000, RandomState)), TextHighlightColorTag, '<StarEnemy>', Star.Name, '<Date>', Galaxy.FormatTurnDate(Route[2].WaitUntilTurn))
    else Result := FormatText2(PickLocalizedTextVariant('ShipGreetings.Group.WarriorLiberatorAfter', NextRandomIntRange(100, 1000, RandomState)), TextHighlightColorTag, '<StarEnemy>', Star.Name, '<Date>', Galaxy.FormatTurnDate(Route[2].WaitUntilTurn));
  end;
end;
{ @end $4EF144 }

{ @routine $4EF3B4 TGroup_FindCentralMemberStar }
function TGroup.FindCentralMemberStar: TStar;
var I, J, Distance, BestDistance: Integer; Ship: TShip; Planet: TPlanet;
begin
  Result := nil;
  BestDistance := MaxInt;
  for I := Ships.Count - 1 downto 0 do begin
    Ship := Ships[I];
    Distance := 0;
    for J := 0 to Galaxy.Planets.Count - 1 do begin
      Planet := Galaxy.Planets[J];
      Inc(Distance, Round(PointDistance(Ship.CurrentStar.Position, Planet.CurrentStar.Position)));
    end;
    if BestDistance > Distance then begin Result := Ship.CurrentStar; BestDistance := Distance; end;
  end;
end;
{ @end $4EF3B4 }

end.
