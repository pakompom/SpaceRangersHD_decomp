unit aTransport;

interface

uses EC_BlockPar, EC_Buf, aGalaxy, aGalaxyStruct, aNormalShip, aPlanet, aShip, aItem;

type
  TTransport = class(TNormalShip) // @size 0x514
  public
    TransportType: TTransportType; // @offset 0x510  Script.ShipSubType.

    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr $5AFD68 @slot $50
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $5B0458 @slot $54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr $5B0D54 @slot $58

    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $5AD51C @slot $74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $5AD550 @slot $78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $5AD674 @slot $7C
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $5AD400 @slot $80
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $5ADC44 @slot $88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $5ADD20 @slot $8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $5ADD38 @slot $90
    procedure ProcessCombatDialogue; override; // @addr $5AE608 @slot $A0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $5AE678 @slot $A4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $5AFCE0 @slot $B8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $5AFD24 @slot $BC

    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $5AE90C @slot $A8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $5AF014 @slot $AC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $5AF3F4 @slot $B0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $5AF7D0 @slot $B4

    destructor Destroy; override; // @addr 0x005AB668
    procedure InitGenerated(Planet: TPlanet; InitialMoney: Integer; SubType: TTransportType; RandomizeSubType: Boolean); // @addr 0x005ABA90 @note "Registers Self with the planet's star; requires a fresh instance."
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x005ABFE4 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x005AC004 @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x005AC024 @slot 0x08

    function GetTypeNameKey: WideString; override; // @addr $5AD144 @slot $2C
    function GetGreetingShipCategory: TGreetingShipCategory; override; // @addr $5AD164 @slot $30
    function GetHomeStar: TStar; override; // @addr $5ACF88 @slot $34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $5AD180 @slot $3C
    function GetDominantCareer: TRangerCareer; override; // @addr 0x005AD17C @slot 0x38 @note "Always career_trader."
    function GetName: WideString; override; // @addr 0x005ACF90 @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x005ACFA4 @slot 0x28

    procedure NextDay; override; // @addr 0x005AC02C @slot 0x18
    procedure NextDayLogic; override; // @addr 0x005AC298 @slot 0x1C
    function SelectRepairOrTradePlanet: TPlanet; // @addr 0x005AC84C @note "May issue a movement order when repairs are needed; result is borrowed and may be nil."
    function SelectTradePlanet: TPlanet; // @addr 0x005AC870 @note "Requires a non-nil PlanetQueue; an empty queue returns nil. Result is borrowed."
    procedure BuildReachablePlanetQueue; override; // @addr 0x005AC8F4 @slot 0x64
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x005ACADC @slot 0x68 @note "AI ownership check only; does not test travel range."
    procedure ProcessTrading; // @addr 0x005ACAE4 @note "Requires CurrentPlanet. Can sell below cost; purchases can exhaust money and cargo space."
    procedure RepairBrokenEquipmentAtLocation; override; // @addr 0x005ACEE8 @slot 0x60 @note "Restores equipment condition without charging Money."
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x005AD184 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x005AD208 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    procedure ProcessUnseenProgression; // @addr 0x005AD230
    function RecomputeFearState: Boolean; override; // @addr 0x005AD6F0 @slot 0x84 @note "Updates InFear and may replace EnemyShip."
    procedure TryOfferRansomToPursuer; // @addr 0x005AD96C
    procedure AssignWeaponTargetsInStar; override; // @addr 0x005ADDC8 @slot 0x20
    procedure SelectEnemyShipInStar; override; // @addr 0x005AE4B8 @slot 0x6C
    procedure EngageEnemyShip; override; // @addr 0x005AE57C @slot 0x70
    procedure RefreshCurrentStanding; override; // @addr 0x005B124C @slot 0xC4
  end;

var
  TransportSkillBonusWeights: array[bonus_accuracy..bonus_leadership] of Integer = (80, 80, 100, 100, 60, 5); // @addr $80EADC
  TransportSlotBonusWeights: array[bonus_radar_slots..bonus_afterburner_slots] of Integer = (200, 0, 150, 0, 150, 50, 0, 0); // @addr $80EAF4 Artefact and afterburner weights are zero.

implementation

uses aGalaxyEvent, aMissile, aAsteroid, aScript, Classes, Math, Windows, SysUtils, aRanger, aTranclucator, GR_Main, Globals, GlobalsV, EC_Str, aItem, aGalaxy, aShip, aConst, aMyFunction;

{ @routine $5AB668 TTransport_Destroy }
destructor TTransport.Destroy;
begin
  Dec(HomePlanet.HomeTransportCount);
  Dec(Galaxy.TransportCount);
  inherited Destroy;
end;
{ @end $5AB668 }

{ @routine $5ABA90 TTransport_InitGenerated }
procedure TTransport.InitGenerated(Planet: TPlanet; InitialMoney: Integer; SubType: TTransportType; RandomizeSubType: Boolean);
var I: Integer; Ranger: TRanger; Good: Byte;
  // @nested $5AB6A0 SelectUniqueName
  procedure SelectUniqueName(Config: TBlockParEC); // @addr $5AB6A0 @note "Nested name-selection helper; caller-popped static link and parent Self at -4."
  var Index, Attempt, I, J, LastIndex, FirstIndex: Integer; Ship: TShip; Star: TStar; Duplicate: Boolean; Block: TBlockParEC;
  begin
    if Config = nil then Exit;
    if Config.CountBlocks('Transport' + TransportTypeNames[TransportType]) > 0 then Block := Config.GetBlock('Transport' + TransportTypeNames[TransportType])
    else if Config.CountBlocks('Transport') > 0 then Block := Config.GetBlock('Transport') else Exit;
    if OwnerId = RaceToOwner(PilotRace) then Block := Block.GetBlock(OwnerToSys(OwnerId))
    else if Block.CountBlocks(OwnerToSys(OwnerId) + OwnerToSys(RaceToOwner(PilotRace))) > 0 then Block := Block.GetBlock(OwnerToSys(OwnerId) + OwnerToSys(RaceToOwner(PilotRace)))
    else if Block.CountBlocks(OwnerToSys(OwnerId)) > 0 then Block := Block.GetBlock(OwnerToSys(OwnerId))
    else if Block.CountBlocks(OwnerToSys(RaceToOwner(PilotRace))) > 0 then Block := Block.GetBlock(OwnerToSys(RaceToOwner(PilotRace)));
    FirstIndex := 0;
    LastIndex := Block.GetParamCount - 1;
    Index := NextRandomIntRange(FirstIndex, LastIndex, RandomState);
    for Attempt := FirstIndex to LastIndex do begin
      Name := Block.GetParamValue(Index);
      Duplicate := False;
      for I := 0 to Galaxy.Stars.Count - 1 do begin
        Star := Galaxy.Stars[I];
        for J := 0 to Star.Ships.Count - 1 do begin
          Ship := Star.Ships[J];
          if (Self <> Ship) and (Ship.TypeId = ship_transport) and ((Ship as TTransport).Name = Name) then begin Duplicate := True; Break; end;
        end;
      end;
      if not Duplicate then Break;
      IncrementWrapped(Index, FirstIndex, LastIndex);
      if Attempt = LastIndex then Name := Name + ' ' + '-' + IntToStr(Id mod 100 + 1) + '-';
    end;
  end;
begin
  Inc(Galaxy.TransportCount);
  Inc(Planet.HomeTransportCount);
  HomePlanet := Planet;
  CurrentPlanet := HomePlanet;
  CurrentStar := CurrentPlanet.CurrentStar;
  CurrentStar.Ships.Add(Self);
  PilotRace := HomePlanet.RaceId;
  OwnerId := RaceToOwner(PilotRace);
  SetMoney(InitialMoney);
  TypeId := ship_transport;
  if RandomizeSubType then
    case NextRandomIntRange(0, 100, RandomState) of
      0..45: TransportType := transport_standard;
      46..79: TransportType := transport_liner;
      80..100: TransportType := transport_diplomat;
    end
  else TransportType := SubType;
  Name := '';
  SelectUniqueName(ModShipNameConfig);
  if Length(GetName) = 0 then SelectUniqueName(LanguageDataConfig.GetBlock('ShipName'));
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do begin CargoGoods[Good].Count := 0; CargoGoods[Good].TotalCost := 0; end;
  if GetPlayer <> nil then begin
    Rank := NextRandomIntRange(0, GetPlayer.Rank, RandomState);
    if Rank > 3 then Rank := 3;
    AddRankPoints(NextRandomIntRange(0, CoalitionRankPointThresholds[Rank] div 2, RandomState));
    if not Galaxy.IsZeroStartingExperienceEnabled then begin
      GainExperience(Round(RemapClamped(Ord(Rank), 0, 3, TotalSkillTrainingCost div 10, TotalSkillTrainingCost div 4)), experience_unscaled);
      GainExperience(Round(RemapClamped(Galaxy.TechLevel, 3, 8, TotalSkillTrainingCost div 20,
        NextRandomIntRange(TotalSkillTrainingCost div 20, TotalSkillTrainingCost div 3, RandomState))), experience_unscaled);
    end;
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  I := 5;
  case TransportType of transport_standard: I := 3; transport_liner: I := 4; transport_diplomat: I := 5; end;
  CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[I]), 1, OwnerId, SelectRandomHullSeries, HomePlanet.OwnerId = owner_pirate);
  CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, HomePlanet.OwnerId);
  CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 1, HomePlanet.OwnerId);
  if (NextRandomIntRange(1, 10, RandomState) > 9) and (GetSlotCountForItemType(item_cargo_hook) > 0) then
    CreateAndEquipCargoHook(CargoHookBaseSize, NextRandomIntRange(1, 1, RandomState), HomePlanet.OwnerId);
  if GetSlotCount(slot_weapon) > WeaponCount then CreateAndEquipWeapon(item_industrial_laser, WeaponInfos[item_industrial_laser].AverageSize, 1, HomePlanet.OwnerId);
  if GetSlotCountForItemType(item_radar) > 0 then CreateAndEquipRadar(Round(EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)] * RadarBaseSize), 1, HomePlanet.OwnerId);
  TrainSkillsAutomatically;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  SmoothedSpeed := Speed;
  SmoothedEnemySpeed := Speed;
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  for I := 0 to Galaxy.Rangers.Count - 1 do begin
    Ranger := Galaxy.Rangers[I];
    RangerRelations.Add(Pointer(OwnerRelations[OwnerId, Ranger.OwnerId]));
  end;
end;
{ @end $5ABA90 }

{ @routine $5ABFE4 TTransport_SaveToBuffer }
procedure TTransport.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TransportType));
end;
{ @end $5ABFE4 }

{ @routine $5AC004 TTransport_LoadFromBuffer }
procedure TTransport.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TransportType := TTransportType(Buffer.GetByte);
end;
{ @end $5AC004 }

{ @routine $5AC024 TTransport_ResolveLoadedReferences }
procedure TTransport.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
end;
{ @end $5AC024 }

{ @routine $5AC02C TTransport_NextDay }
procedure TTransport.NextDay;
begin
  inherited NextDay;
  try
    if TradeExperience > 0 then begin
      if IsHealthEffectActive(stimulant_business_mark) then GainExperience(Round(TradeExperience * 1.5), experience_trader_career)
      else GainExperience(TradeExperience, experience_trader_career);
      TradeExperience := 0;
    end;
    if (ScriptShip <> nil) and HasScriptControl then begin
      ScriptNextDay;
      if ScriptShip <> nil then Exit;
    end;
    NextDayLogic;
    if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TTransport.NextDay ' + GetFullName(' '));
    end;
  end;
end;
{ @end $5AC02C }

{ @routine $5AC298 TTransport_NextDayLogic }
procedure TTransport.NextDayLogic;
var Destination: TPointF; Planet: TPlanet; Stage: Integer;
begin
  Stage := 0;
  try
    if CurrentPlanet <> nil then begin
      Stage := 1;
      if CurrentPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate] then begin
        Stage := 2;
        RepairBrokenEquipmentAtLocation;
        AutoEquipInventory;
        OptimizeInventory;
        RefuelAtLocation;
        ReloadWeaponAmmo;
        if RepairHullAtLocation then Exit;
        ProcessTrading;
        BuyEquipmentAtLocation(False);
        RestoreEssentialEquipment;
        ProcessUnseenProgression;
        TrainSkillsAutomatically;
        if TransportType = transport_liner then SetMoney(Money + Galaxy.ComputeScaledMiniMoney(CurrentPlanet.OwnerId));
        if TransportType = transport_diplomat then SetMoney(Money + Galaxy.ComputeScaledMiniMoney(CurrentPlanet.OwnerId) * ((Cardinal(GetEffectiveSkillLevel(skill_charisma)) + 1) shr 1));
      end;
      OrderTakeoff;
      Stage := 3;
    end else if DockedTo <> nil then begin
      if DockedTo.InNormalSpace then OrderTakeoff else OrderNone(False);
    end else begin
      Stage := 4;
      if InNormalSpace then begin
        Stage := 5;
        BuildReachablePlanetQueue;
        Stage := 6;
        if RecomputeFearState then TryOfferRansomToPursuer;
        ProcessCombatDialogue;
        AssignWeaponTargetsInStar;
        if not InFear then begin
          Stage := 7;
          SelectEnemyShipInStar;
          EngageEnemyShip;
        end else begin
          Stage := 8;
          if (Order <> order_land) and (Order <> order_jump) then NavigateToEscapePlanet(True);
          if (Order in [order_land, order_jump]) and (EstimateOrderTravelTurns > 4) and (EnemyShip <> nil) and
            (EnemyShip.OrderTarget = Self) and (EnemyShip.TypeId in [ship_ranger, ship_pirate]) and (EnemyShip.EstimateOrderTravelTurns < 3) and
            (NextRandomUnitFloat(RandomState) < 0.2) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 2 = 0) then
            if JettisonCargoGoodsTowardTargetValue(Max(200, Galaxy.ComputeScaledMiniMoney(OwnerId) div 2)) then NotifyFearCargoDrop(EnemyShip);
        end;
        if Order = order_none then begin
          Stage := 9;
          Planet := SelectRepairOrTradePlanet;
          if Planet = nil then begin
            Destination.X := NextRandomIntRange(-2000, 2000, RandomState);
            Destination.Y := NextRandomIntRange(-2000, 2000, RandomState);
            OrderMove(Destination, False);
          end else if CurrentStar = Planet.CurrentStar then OrderLanding(Planet, False)
          else OrderJump(Planet.CurrentStar, False);
        end;
      end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TTransport.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5AC298 }

{ @routine $5AC84C TTransport_SelectRepairOrTradePlanet }
function TTransport.SelectRepairOrTradePlanet: TPlanet;
begin
  if HasHullDamageOrBrokenEquippedItems then Result := NavigateToQueuedPlanet(False) else Result := SelectTradePlanet;
end;
{ @end $5AC84C }

{ @routine $5AC870 TTransport_SelectTradePlanet }
function TTransport.SelectTradePlanet: TPlanet;
var Attempts: Integer;
begin
  if PlanetQueue.Count > 0 then begin
    Attempts := Round(RemapClamped(Galaxy.GetCoalitionToPirateSystemRatio, 0.3, 1, 4, 1));
    repeat
      Result := PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)];
      Dec(Attempts);
    until (Attempts = 0) or Result.IsCoalitionOwned;
  end else Result := nil;
end;
{ @end $5AC870 }

{ @routine $5AC8F4 TTransport_BuildReachablePlanetQueue }
procedure TTransport.BuildReachablePlanetQueue;
var I, J: Integer; Planet: TPlanet; Star: TStar; SmallestShipCount: Integer;
begin
  ClearPlanetQueue;
  PlanetQueue := TList.Create;
  if (HomePlanet <> LastDockedPlanet) and (JumpRange >= PointDistance(HomePlanet.CurrentStar.Position, CurrentStar.Position)) and
    (GetHull.HullPoints > GetHull.Weight * 0.5) and HomePlanet.IsCoalitionOwned then PlanetQueue.Add(HomePlanet)
  else begin
    SmallestShipCount := 100000;
    for I := 0 to Galaxy.Stars.Count - 1 do begin
      Star := CurrentStar.StarDistances[I].Star as TStar;
      if CurrentStar.StarDistances[I].Distance > JumpRange then Continue;
      if (Star.Ships.Count > 15) and (Star.Ships.Count > SmallestShipCount) and (PlanetQueue.Count > 0) then Continue;
      if Star.ControlFaction = faction_dominators then Continue;
      if Star.Constellation.Id = 20 then Continue;
      if Star.Status.CustomFaction <> '' then Continue;
      for J := 0 to Star.Planets.Count - 1 do begin
          Planet := Star.Planets[J];
          if (Planet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) and (Planet <> LastDockedPlanet) and
            ((LastDockedPlanet.CurrentStar = CurrentStar) or (CurrentStar = Star) or (CurrentStar.ControlFaction = faction_dominators) or (CurrentStar.Status.CustomFaction <> '')) then begin
            PlanetQueue.Add(Planet);
            SmallestShipCount := Min(SmallestShipCount, Star.Ships.Count);
          end;
        end;
    end;
  end;
end;
{ @end $5AC8F4 }

{ @routine $5ACADC TTransport_CanQueueReachablePlanet }
function TTransport.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := Planet.OwnerId <> owner_dominator;
end;
{ @end $5ACADC }

{ @routine $5ACAE4 TTransport_ProcessTrading }
procedure TTransport.ProcessTrading;
var Good: Byte; Quantity: Integer;
begin
  case TransportType of
  transport_standard:
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do begin
      if (Good in [Ord(item_food)..Ord(item_narcotics)]) and (CurrentPlanet.Goods[Good].Count > 0) and
        (ShopGoodsPurchasePrice(Good, nil) < GoodsMarket[Good].AveragePrice) and (CargoFreeSpace > 0) then begin
        Quantity := Min(Trunc(Money / ShopGoodsPurchasePrice(Good, nil)), CargoFreeSpace);
        Quantity := Min(Quantity, CurrentPlanet.Goods[Good].Count);
        BuyGoodsFromLocation(Good, Quantity);
      end
      else if CargoGoods[Good].Count > 0 then
        if (ShopGoodsSellPrice(Good, nil) > GetAverageCargoCost(Good)) or (NextRandomUnitFloat(RandomState) < 0.2) then
          SellGoodsToLocation(Good, CargoGoods[Good].Count);
    end;
  transport_liner:
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do begin
      if (Good in [Ord(item_food)..Ord(item_luxury), Ord(item_alcohol), Ord(item_narcotics)]) and (CurrentPlanet.Goods[Good].Count > 0) and
        (ShopGoodsPurchasePrice(Good, nil) < GoodsMarket[Good].AveragePrice) and (CargoFreeSpace > 0) then begin
        Quantity := Min(Trunc(Money / ShopGoodsPurchasePrice(Good, nil)), CargoFreeSpace);
        Quantity := Min(Quantity, CurrentPlanet.Goods[Good].Count);
        BuyGoodsFromLocation(Good, Quantity);
      end
      else if CargoGoods[Good].Count > 0 then
        if (ShopGoodsSellPrice(Good, nil) > GetAverageCargoCost(Good)) or (NextRandomUnitFloat(RandomState) < 0.2) then
          SellGoodsToLocation(Good, CargoGoods[Good].Count);
    end;
  transport_diplomat:
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do begin
      if (Good in [Ord(item_technical_goods), Ord(item_luxury), Ord(item_alcohol)..Ord(item_narcotics)]) and (CurrentPlanet.Goods[Good].Count > 0) and
        (ShopGoodsPurchasePrice(Good, nil) < GoodsMarket[Good].AveragePrice) and (CargoFreeSpace > 0) then begin
        Quantity := Min(Trunc(Money / ShopGoodsPurchasePrice(Good, nil)), CargoFreeSpace);
        Quantity := Min(Quantity, CurrentPlanet.Goods[Good].Count);
        BuyGoodsFromLocation(Good, Quantity);
      end
      else if CargoGoods[Good].Count > 0 then
        if (ShopGoodsSellPrice(Good, nil) > GetAverageCargoCost(Good)) or (NextRandomUnitFloat(RandomState) < 0.2) then
          SellGoodsToLocation(Good, CargoGoods[Good].Count);
    end;
  end;
end;
{ @end $5ACAE4 }

{ @routine $5ACEE8 TTransport_RepairBrokenEquipmentAtLocation }
procedure TTransport.RepairBrokenEquipmentAtLocation;
var I: Integer; Equipment: TEquipment; Artefact: TArtefact;
begin
  for I := 0 to Inventory.Count - 1 do begin
    Equipment := Inventory[I];
    if (Equipment.BrokenFlag <> 0) or (Equipment.ConditionPercent < 20) then Equipment.Repair;
  end;
  if CanRepairArtefactsAtLocation then
    for I := 0 to Artefacts.Count - 1 do begin
      Artefact := Artefacts[I];
      if (Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 20) then
        if Artefact.EquippedFlag <> 0 then Artefact.Repair;
    end;
end;
{ @end $5ACEE8 }

{ @routine $5ACF88 TTransport_GetHomeStar }
function TTransport.GetHomeStar: TStar;
begin
  Result := HomePlanet.CurrentStar;
end;
{ @end $5ACF88 }

{ @routine $5ACF90 TTransport_GetName }
function TTransport.GetName: WideString;
begin
  Result := Name;
end;
{ @end $5ACF90 }

{ @routine $5ACFA4 TTransport_GetFullName }
function TTransport.GetFullName(const Separator: WideString): WideString;
var
  Path, Text: WideString;
begin
  if TypeNameOverrideKey = '' then
    Result := LocalizedText('ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + GetTypeNameKey) + Separator + Name
  else
  begin
    Path := 'ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + TypeNameOverrideKey;
    if LanguageDataConfig.CountParamsByPath(Path) > 0 then Text := LocalizedText(Path)
    else Text := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Text <> '' then Result := Text + Separator + Name else Result := Name;
  end;
end;
{ @end $5ACFA4 }

{ @routine $5AD144 TTransport_GetTypeNameKey }
function TTransport.GetTypeNameKey: WideString;
begin
  Result := TransportTypeNames[TransportType];
end;
{ @end $5AD144 }

{ @routine $5AD164 TTransport_GetGreetingShipCategory }
function TTransport.GetGreetingShipCategory: TGreetingShipCategory;
begin
  case TransportType of
    transport_standard: Result := greeting_ship_transport;
    transport_liner: Result := greeting_ship_liner;
  else Result := greeting_ship_diplomat;
  end;
end;
{ @end $5AD164 }

{ @routine $5AD17C TTransport_GetDominantCareer }
function TTransport.GetDominantCareer: TRangerCareer;
begin
  Result := career_trader;
end;
{ @end $5AD17C }

{ @routine $5AD180 TTransport_GetStrengthScaledPirateStatus }
function TTransport.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 0;
end;
{ @end $5AD180 }

{ @routine $5AD184 TTransport_GetDesiredCargoFreeSpace }
function TTransport.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
  case TransportType of
    transport_standard: Result := Trunc(GetHull.Weight * 0.3);
    transport_liner: Result := Integer(Trunc(GetHull.Weight * 0.1)) + 30;
    transport_diplomat: Result := Integer(Trunc(GetHull.Weight * 0.1)) + 10;
  end;
end;
{ @end $5AD184 }

{ @routine $5AD208 TTransport_RefuelAtLocation }
procedure TTransport.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $5AD208 }

{ @routine $5AD230 TTransport_ProcessUnseenProgression }
procedure TTransport.ProcessUnseenProgression;
var Award: Byte;
begin
  if (DaysSincePlayerSeen >= 60) and (GetPlayer <> nil) then begin
    if NextRandomUnitFloat(RandomState) < 0.06 then GainExperience(SeededRandomIntRange(100, 500, Seed + Cardinal(Galaxy.CurrentTurn div 59) + 789), experience_unscaled);
    if (GetPlayer.Rank > Rank) and (NextRandomUnitFloat(RandomState) < 0.03) and (Rank < 4) then begin
      AddRankPoints(NextRandomIntRange(10, 20, RandomState));
      TryPromoteRank;
    end;
    if (NextRandomUnitFloat(RandomState) < 0.01) and ((AwardIds = nil) or (2 * Rank > AwardIds.Count)) then begin
      case TransportType of
        transport_standard: Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [award_accomplishment, award_cowardice], [ship_dominator..station_custom]);
        transport_liner: Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [award_accomplishment], [ship_dominator..station_custom]);
        transport_diplomat: Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [award_accomplishment..award_perfidy], [ship_dominator..station_custom]);
      else Award := AwardNotFound;
      end;
      if Award <> AwardNotFound then AddAward(Award);
    end;
  end;
end;
{ @end $5AD230 }

{ @routine $5AD400 TTransport_RelationToNonRanger }
function TTransport.RelationToNonRanger(Ship: TShip): Byte;
var Value: Integer;
begin
  if Ship.TypeId = ship_transport then begin
    Value := Round((0.7 * PlanetRaceMarket[PilotRace].FriendlyRelationScale) * OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)]);
    if Value > 100 then Value := 100;
    Result := Value;
  end else if Ship.TypeId = ship_pirate then begin
    Value := Round((0.5 * PlanetRaceMarket[PilotRace].PirateRelationFactor) * OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)]);
    // Native's reversed clamp always produces 20, but still performs the calculation.
    Value := Min(20, Max(Value, 70));
    Result := Value;
  end else if Ship.TypeId = station_dominion then Result := 40
  else if Ship.TypeId = station_pirate_base then Result := 50
  else if Ship.TypeId in [ship_dominator, ship_tranclucator] then Result := 50 else Result := 100;
end;
{ @end $5AD400 }

{ @routine $5AD51C TTransport_RelationToRanger }
function TTransport.RelationToRanger(Ranger: Pointer): Byte;
begin Result := Byte(RangerRelations[Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)]); end;
{ @end $5AD51C }

{ @routine $5AD550 TTransport_ChangeRelationToRanger }
procedure TTransport.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var Relation: Byte; Value, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(RangerRelations[Index]);
  if (TShip(Ranger).GetEffectiveSkillLevel(skill_charisma) > 0) and (Amount > 0) then
    Inc(Amount, Round(Amount * (TShip(Ranger).GetEffectiveSkillLevel(skill_charisma)) * 0.2));
  Value := Amount + Relation;
  if Value < 0 then Relation := 0 else if Value > 100 then Relation := 100 else Relation := Value;
  RangerRelations[Index] := Pointer(Relation);
  if (Relation < RelationBadMin) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $5AD550 }

{ @routine $5AD674 TTransport_ReactToAttack }
procedure TTransport.ReactToAttack(Attacker: TShip);
begin
  EnemyShip := Attacker;
  if Attacker.TypeId = ship_ranger then begin
    ChangeRelationToRanger(Attacker, -10);
    if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = ship_ranger) then ChangeRelationToRanger(Attacker.PartnerShip, -5);
    if ((Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil)) and (TTranclucator(Attacker).OwnerShip.TypeId = ship_ranger) then ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10);
  end;
end;
{ @end $5AD674 }

{ @routine $5AD6F0 TTransport_RecomputeFearState }
function TTransport.RecomputeFearState: Boolean;
var Ship: TShip; I, EnemyCount: Integer; Tolerance, Threat: Double;
begin
  if HasNoUsableWeapons and (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then begin
    Result := True;
    InFear := True;
    Exit;
  end;
  Result := (GetHull.HullPoints < GetHull.Weight * 0.2) or ((EnemyShip <> nil) and
    ((EnemyShip.OrderTarget = Self) or (EnemyShip = GetPlayer)) and AcceptsRansomDemandFrom(EnemyShip));
  if not Result then begin
    Threat := 0;
    EnemyCount := 0;
    Tolerance := RemapClamped(GetHull.HullPoints, 50, GetHull.Weight, 0, 3);
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if Ship.InNormalSpace and (Ship <> Self) then begin
        if Ship = EnemyShip then begin
          Threat := Ship.ChanceToWin(Self) + Threat;
          Inc(EnemyCount);
        end else if ((Ship.EnemyShip = Self) and (Ship.OrderTarget = Self)) or
          ((Ship.RelationToShip(Self) < RelationBadMin) and (PointDistanceSquared(Position, Ship.Position) < 250000)) then begin
          Threat := Ship.ChanceToWin(Self) + Threat;
          if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or EnemyShip.IsOutsideStarSpace then EnemyShip := Ship
          else if (EnemyShip <> Ship) and (OrderTarget <> EnemyShip) then
            if PointDistanceSquared(EnemyShip.Position, Position) > PointDistanceSquared(Ship.Position, Position) then EnemyShip := Ship;
        end;
      end;
    end;
    if (EnemyCount - 1) * Threat * 0.5 + Threat > Tolerance then Result := True;
  end;
  InFear := Result;
end;
{ @end $5AD6F0 }

{ @routine $5AD96C TTransport_TryOfferRansomToPursuer }
procedure TTransport.TryOfferRansomToPursuer;
var Response: WideString; Amount: Integer; LowOffer, HighOffer: Single; Accepted: Boolean; Ship: TShip;
begin
  if InNormalSpace and (EnemyShip <> nil) and (EnemyShip.OrderTarget = Self) and (EnemyShip.TruceShip <> Self) and
    (Money > 100) and not CanEscapePursuer(EnemyShip) and not (EnemyShip.TypeId in NonNegotiatingShipTypes) and
    (EnemyShip.GetMaxWeaponRange * EnemyShip.GetMaxWeaponRange >= PointDistanceSquared(Position, EnemyShip.Position)) and
    (((Galaxy.CurrentTurn * Integer(EnemyShip.Id) mod 3 = 0) and (NextRandomUnitFloat(RandomState) > 0.2)) or (GetHullIntegrityPercent < 20)) and
    not NoTalk and not EnemyShip.NoTalk then begin
    LowOffer := Min(Money, GetWealthScaledAmount(1));
    HighOffer := Min(Money, (GetWealthScaledAmount(4) + EnemyShip.GetWealthScaledAmount(4)) * 0.5);
    Amount := Round(Max(100, RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, HighOffer, LowOffer)));
    Ship := EnemyShip;
    Accepted := Ship.BuildTrucePaymentResponse(Self, Response, Amount);
    if (GetPlayer <> Ship) and (GetPlayer.CurrentStar = CurrentStar) then NotifyTruceOffer(Ship, Response, Amount);
    if Accepted and RecomputeFearState then TryOfferRansomToPursuer;
  end;
end;
{ @end $5AD96C }

{ @routine $5ADC44 TTransport_AcceptsRansomDemandFrom }
function TTransport.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
var LicenseFactor, AbductionFactor: Single;
begin
  if (GetPlayer = Ship) and (GetPlayer.PirateLicenseTicks > 0) then LicenseFactor := 1.2 else LicenseFactor := 1;
  if AbductedByPirateClan then AbductionFactor := 0.5 else AbductionFactor := 1;
  Result := (GetHull.Weight * (0.5 * LicenseFactor * OwnerInfo[OwnerId].FearThresholdScale + 0.2) > GetHull.HullPoints) and
    (LicenseFactor * OwnerInfo[OwnerId].FearThresholdScale > ChanceToWin(Ship) * AbductionFactor);
end;
{ @end $5ADC44 }

{ @routine $5ADD20 TTransport_TrustsAttackRequester }
function TTransport.TrustsAttackRequester(Ship: TShip): Boolean;
begin Result := RelationToShip(Ship) >= RelationNormalMin; end;
{ @end $5ADD20 }

{ @routine $5ADD38 TTransport_AcceptsAppealFrom }
function TTransport.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) +
    RemapClamped(Ship.Strength, 0.9 * Strength, Strength * 3, 0, 100) > 110;
end;
{ @end $5ADD38 }

{ @routine $5ADDC8 TTransport_AssignWeaponTargetsInStar }
procedure TTransport.AssignWeaponTargetsInStar;
const
  MissileShotTypes = [shot_torpedo..shot_rocket];
  AreaOrMissileShotTypes = [shot_area_damage..shot_rocket];
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Item: TItem; Asteroid: TAsteroid; Distance: Single; Missile: TMissile;
begin
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; end;
  Assigned := 0;
  if CurrentStar.Battle <> 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship.OwnerId <> owner_dominator) or not Ship.InNormalSpace then Continue;
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if ((Weapon.GetWeaponInfo^.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
          not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
        Weapon.Target := Ship;
        Inc(Assigned);
        if Assigned = WeaponCount then Exit;
      end;
    end;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if ((Weapon.GetWeaponInfo^.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
        not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
      Weapon.Target := EnemyShip;
      Inc(Assigned);
      if Assigned = WeaponCount then Exit;
    end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do begin
    Missile := CurrentStar.Missiles[I];
    if (Missile.Target = Self) and (Missile.OwnerShip <> Self) then
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if (Weapon.GetWeaponInfo^.ShotType in MissileShotTypes) or (Weapon.Target <> nil) or
          not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, Missile.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
        Weapon.Target := Missile;
        Inc(Assigned);
        if Assigned = WeaponCount then Exit;
        Break;
      end;
  end;
  if CurrentStar = GetPlayer.CurrentStar then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do begin
      Asteroid := CurrentStar.Asteroids[I];
      Distance := PointDistanceSquared(Position, Asteroid.Position);
      if Distance <= AsteroidTargetRangeSquared then
        for J := 1 to WeaponCount do begin
          Weapon := Weapons[J];
          // Native asteroid targeting can overwrite an existing assignment.
          if (Weapon.GetWeaponInfo^.ShotType in AreaOrMissileShotTypes) or
            not IsEquipmentUsable(Weapon) or not (Sqr(GetWeaponRange(Weapon)) >= Distance) then Continue;
          Weapon.Target := Asteroid;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
          Break;
        end;
    end;
  if CurrentStar.Items.Count > Galaxy.GetAIJunkToleranceLevel then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) and
        ((Item.ItemType = item_minerals) or (2 * Galaxy.GetAIJunkToleranceLevel <= CurrentStar.Items.Count)) and
        ((Item.ItemType = item_minerals) or (Item.OwnerId = owner_dominator)) then
        if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace or (GetRelationLevelToShip(GetPlayer) <= relation_level_bad) or
          (PointDistance(GetPlayer.Position, Item.Position) >= 800) or
          ((NextRandomUnitFloat(RandomState) <= 0.1) and (PointDistance(GetPlayer.Position, Item.Position) >= 200)) then
          if CanSafelyDetonateItem(Item) and not IsRecentlyDroppedItem(Item) then
            for J := 1 to WeaponCount do begin
              Weapon := Weapons[J];
              if (Weapon.GetWeaponInfo^.ShotType in AreaOrMissileShotTypes) or (Weapon.Target <> nil) or
                not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
              Weapon.Target := Item;
              Inc(Assigned);
              if Assigned = WeaponCount then Exit;
              Break;
            end;
    end;
  if GetPlayer <> nil then
    if GetPlayer.CurrentStar = CurrentStar then
      if GetPlayer.InNormalSpace and IsPlayerChameleonEffectiveAgainstSelf then
        for J := 1 to WeaponCount do begin
          Weapon := Weapons[J];
          if ((Weapon.GetWeaponInfo^.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
            not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, GetPlayer.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
          Weapon.Target := GetPlayer;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
end;
{ @end $5ADDC8 }

{ @routine $5AE4B8 TTransport_SelectEnemyShipInStar }
procedure TTransport.SelectEnemyShipInStar;
var I: Integer; Ship: TShip;
begin
  if ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or (EnemyShip.CurrentStanding in [standing_dominator, standing_custom])) then
    if (UsableWeaponCount <> 0) and ((CurrentStar.ControlFaction <> faction_coalition) or (CurrentStar.Status.CustomFaction <> '')) then
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if (Ship.CurrentStanding in [standing_dominator, standing_custom]) and Ship.InNormalSpace then begin
          EnemyShip := Ship;
          if ChanceToWin(Ship) - OwnerInfo[OwnerId].FearThresholdScale > 0 then Break;
        end;
      end;
end;
{ @end $5AE4B8 }

{ @routine $5AE57C TTransport_EngageEnemyShip }
procedure TTransport.EngageEnemyShip;
begin
  if Order = order_follow_ship then OrderNone(False);
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then begin
    if (CurrentStar.ControlFaction <> faction_pirates) or (CurrentStar.Battle <> 0) then OrderFollowShip(EnemyShip, follow_min_weapon_range, False);
    if ChanceToWin(EnemyShip) < 0.9 then RequestAlliesAttackShip(EnemyShip);
  end;
end;
{ @end $5AE57C }

{ @routine $5AE608 TTransport_ProcessCombatDialogue }
procedure TTransport.ProcessCombatDialogue;
begin
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 7 = 0) and
    (ChanceToWin(EnemyShip) < 1.3) and (GetHullIntegrityPercent > 30) then RequestAlliesAttackShip(EnemyShip);
end;
{ @end $5AE608 }

{ @routine $5AE678 TTransport_ReactToExtortionDemand }
procedure TTransport.ReactToExtortionDemand(Ranger: Pointer);
begin
  if (GetPlayer = Ranger) or (NextRandomUnitFloat(RandomState) < 0.05) then begin
    ChangeRelationToRanger(Ranger, -15);
    HomePlanet.ChangeRelationToRanger(Ranger, -2);
    (TObject(Ranger) as TRanger).AddPirateCareerActivity(2);
  end;
end;
{ @end $5AE678 }

{ @routine $5AE90C TTransport_BuildMoneyExtortionResponse }
function TTransport.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
var NextDemandTurn: Integer; LicenseFactor: Single;
  // @nested $5AE6E4 PayDemand
  procedure PayDemand; // @addr $5AE6E4 @note "Nested response helper with caller-popped static link."
  var Event: TGalaxyEvent;
  begin
    AbductedByPirateClan := False;
    if GetPlayer = OtherShip then begin
      LastPlayerExtortionTurn := Galaxy.CurrentTurn;
      Event := AddGalaxyEvent('PlayerExtortsMoney');
      Event.AddData(DemandedAmount);
      Event.AddData(Ord(TypeId));
      Event.AddData(CurrentStar.Id);
      Event.AddData(Id);
      Event.AddData(Ord(OwnerId));
      Event.AddTextData(GetName);
      Event.AddTextData(TypeNameOverrideKey);
      if GetPlayer.PirateLicenseTicks > 0 then begin
        GetPlayer.SetMoney(GetPlayer.Money + Round(DemandedAmount * 0.9));
        Inc(GetPlayer.PendingPirateLicenseCash, Round(DemandedAmount * 0.1));
        if GetPlayer.PendingPirateLicenseCash > MaxMonetaryValue then GetPlayer.PendingPirateLicenseCash := MaxMonetaryValue;
      end else GetPlayer.SetMoney(GetPlayer.Money + DemandedAmount);
    end else OtherShip.SetMoney(OtherShip.Money + DemandedAmount);
    SetMoney(Money - DemandedAmount);
    OtherShip.TruceWithShip(Self);
    if OtherShip.OwnerId = owner_pirate then TNormalShip(OtherShip).AddPirateRankPoints(1);
    if OtherShip is TRanger then (OtherShip as TRanger).ApplyExtortionReputationPenalty(Self);
  end;
begin
  Result := False;
  if (GetPlayer = OtherShip) and (GetPlayer.PirateLicenseTicks > 0) then LicenseFactor := 0.8 else LicenseFactor := 1;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (CurrentStar <> EnemyShip.CurrentStar)) then EnemyShip := OtherShip;
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Money.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Money.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Money.WeAlreadyHavePact', OtherShip)
  else if not AcceptsRansomDemandFrom(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if DemandedAmount > RemapClamped(GetWinChancePercent(OtherShip) * LicenseFactor, 0, 100, GetWealthScaledAmount(4), GetWealthScaledAmount(2)) then
    Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'SumIsVeryBig', OtherShip)
  else if Money < DemandedAmount then Response := LookupVisibleTalkText('Talk.Money.AnswerNotMoney', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'Ok', OtherShip);
    PayDemand;
    Result := True;
  end;
end;
{ @end $5AE90C }

{ @routine $5AF014 TTransport_BuildCargoExtortionResponse }
function TTransport.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
var Forced: Boolean; NextDemandTurn: Integer;
  // @nested $5AED5C DropDemand
  procedure DropDemand; // @addr $5AED5C @note "Nested response helper with caller-popped static link."
  var Good: Byte; Pass, Count, TotalValue, LowValue, HighValue: Integer; Enough: Boolean; Divisor: Single; Event: TGalaxyEvent;
  begin
    AbductedByPirateClan := False;
    TotalValue := 0;
    Enough := False;
    LowValue := GetWealthScaledAmount(1);
    HighValue := GetWealthScaledAmount(4);
    for Pass := 1 to 3 do begin
      for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
        if CargoGoods[Good].Count > 0 then begin
          Divisor := RemapClamped(CargoGoods[Good].Count * GoodsMarket[Good].AveragePrice, LowValue, HighValue, 2, 8);
          Count := Max(Int64(1), Round(CargoGoods[Good].Count / Divisor));
          Inc(TotalValue, Count * GoodsMarket[Good].AveragePrice);
          DropGoodsIntoSpace(Good, Count);
          if TotalValue > HighValue then begin Enough := True; Break; end;
        end;
      if Enough then Break;
    end;
    OtherShip.TruceWithShip(Self);
    if GetPlayer = OtherShip then begin
      LastPlayerExtortionTurn := Galaxy.CurrentTurn;
      Event := AddGalaxyEvent('PlayerExtortsGoods');
      Event.AddData(TotalValue);
      Event.AddData(Ord(TypeId));
      Event.AddData(CurrentStar.Id);
      Event.AddData(Id);
      Event.AddData(Ord(OwnerId));
      Event.AddTextData(GetName);
      Event.AddTextData(TypeNameOverrideKey);
    end;
    OtherShip.OrderMove(Position, True);
    if OtherShip is TRanger then (OtherShip as TRanger).ApplyExtortionReputationPenalty(Self);
    if OtherShip.OwnerId = owner_pirate then TNormalShip(OtherShip).AddPirateRankPoints(1);
  end;
begin
  Result := False;
  Forced := (GetPlayer = OtherShip) and OtherShip.IsHealthEffectActive(stimulant_one_eyed_khamas);
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (CurrentStar <> EnemyShip.CurrentStar)) then EnemyShip := OtherShip;
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if not AcceptsRansomDemandFrom(OtherShip) and not Forced then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) and not Forced then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if not HasCargoGoods then Response := LookupVisibleTalkText('Talk.Goods.AnswerNotGoods', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'Ok', OtherShip);
    DropDemand;
    if GetPlayer = OtherShip then PlayerExtortionPactActive := True;
    Result := True;
  end;
end;
{ @end $5AF014 }

{ @routine $5AF3F4 TTransport_BuildTrucePaymentResponse }
function TTransport.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $5AF3A4 AcceptPayment
  procedure AcceptPayment; // @addr $5AF3A4 @note "Nested response helper with caller-popped static link."
  begin
    OtherShip.SetMoney(OtherShip.Money - OfferedAmount);
    SetMoney(Money + OfferedAmount);
    TruceWithShip(OtherShip);
  end;
begin
  Result := False;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then (OtherShip as TRanger).AddTraderCareerActivity(1);
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if RecomputeFearState or ((ChanceToWin(OtherShip) < 1) and (GetHullIntegrityPercent < 40)) or (ChanceToWin(OtherShip) < 0.2) or
    (OfferedAmount > RemapClamped(GetWinChancePercent(OtherShip), 0, 100, GetWealthScaledAmount(1), GetWealthScaledAmount(4))) then begin
    Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptPayment;
    Result := True;
  end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $5AF3F4 }

{ @routine $5AF7D0 TTransport_BuildAttackRequestResponse }
function TTransport.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
  // @nested $5AF6F8 AcceptRequest
  procedure AcceptRequest; // @addr $5AF6F8 @note "Nested response helper with caller-popped static link."
  begin
    Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Ok', Requester);
    SetJointAttackTarget(Requester, Target);
    Result := True;
  end;
begin
  Result := False;
  if Requester is TRanger then begin
    if Target.TypeId in [ship_ranger..ship_pirate] then Target.ChangeRelationToRanger(Requester, -20);
    if (Target.OwnerId = owner_dominator) or (Target.TypeId = ship_pirate) then (Requester as TRanger).AddWarriorCareerActivity(1)
    else (Requester as TRanger).AddPirateCareerActivity(8);
  end;
  if (OrderTarget = Target) and (GetRelationLevelToShip(Target) = relation_level_hostile) then AcceptRequest
  else if TruceShip = Target then Response := FormatText1(LookupVisibleTalkText('Talk.Attack.WeAlreadyHavePact', Requester), TextHighlightColorTag, '<Target>', Target.GetName)
  else if RelationToShip(Target) >= RelationNormalMin then begin
    if not (Target is TTranclucator) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriends', Requester)
    else if TTranclucator(Target).OwnerShip = Self then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsMyTranc', Requester)
    else if TTranclucator(Target).OwnerShip = Requester then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsYourTranc', Requester)
    else Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriendsTranc', Requester);
  end else if not TrustsAttackRequester(Requester) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Suspect', Requester)
  else if InFear or AcceptsRansomDemandFrom(Target) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Fear', Requester)
  else if HasLockedOrFollowOrder then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else AcceptRequest;
end;
{ @end $5AF7D0 }

{ @routine $5AFCE0 TTransport_AcceptPartnershipOffer }
function TTransport.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin Result := False; Response := 'Not supporting'; end;
{ @end $5AFCE0 }

{ @routine $5AFD24 TTransport_BuildPartnershipOfferResponse }
function TTransport.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin Result := False; Response := 'Not supporting'; end;
{ @end $5AFD24 }

{ @routine $5AFD68 TTransport_AdjustItemEvaluation }
function TTransport.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
const
  NoFlags = [];
var
  MoneyPenalty, EffectivenessScale, WeightPenalty, FragilityScale: Single;
  Price: Integer;
  DesiredFreeFraction, DesiredMoneyFraction, HullValueScale: Single;
begin
  case TransportType of
    transport_standard: begin DesiredMoneyFraction := 0.2; FragilityScale := 0.8; HullValueScale := 0.1; end;
    transport_liner: begin DesiredMoneyFraction := 0.14; FragilityScale := 1; HullValueScale := 0.5; end;
    transport_diplomat: begin DesiredMoneyFraction := 0.1; FragilityScale := 1.2; HullValueScale := 1; end;
  else DesiredMoneyFraction := 1; FragilityScale := 1; HullValueScale := 1;
  end;
  if Item.ItemType in [item_fuel_tanks, item_radar, item_scanner, item_cargo_hook] then FragilityScale := FragilityScale * 0.5;
  if StrengthInAverageRanger < 0.3 then DesiredMoneyFraction := DesiredMoneyFraction * 0.7;
  if StrengthInAverageRanger > 0.9 then DesiredMoneyFraction := DesiredMoneyFraction * 1.5;
  DesiredMoneyFraction := Min(0.99, Max(0.01, (Galaxy.CountFactionStars(faction_coalition) /
    (Galaxy.CountFactionStars(faction_coalition) + 1 + Galaxy.CountFactionStars(faction_pirates)) + 0.1) * DesiredMoneyFraction));
  DesiredFreeFraction := Max(0.01, Min(0.99, GetDesiredCargoFreeSpace / Max(100, GetHull.Weight)));
  MoneyPenalty := Sqr((1 / Max(0.01, SmoothedMoneyFraction) - 1) / (1 / DesiredMoneyFraction - 1)) /
    Max(SmoothedWealth * 0.05, 1000);
  EffectivenessScale := 2 / Max(10, SmoothedEquipmentEffectiveness);
  WeightPenalty := Sqr((1 / Max(0.01, SmoothedFreeCapacityFraction) - 1) / (1 / DesiredFreeFraction - 1)) /
    Max(10, GetHull.Weight * 0.1);
  if (Item.OwnerId = OwnerId) and (TransportType = transport_diplomat) then EffectivenessScale := EffectivenessScale * 1.1;
  MoneyPenalty := MoneyPenalty * 0.01 * (100 + SeededRandomIntRange(-15, 15, Id + Seed));
  EffectivenessScale := EffectivenessScale * 0.01 * (100 + SeededRandomIntRange(-15, 15, Seed + 3 * Id));
  WeightPenalty := WeightPenalty * 0.01 * (100 + SeededRandomIntRange(-15, 15, Seed + 5 * Id));
  case PriceMode of
    4: Price := Item.Cost;
    3: Price := Item.CalculateResaleValue(GetEffectiveSkillLevel(skill_trading));
    1: Price := -Item.Cost;
    2: Price := 0;
    0: begin
      Price := 0;
      WeightPenalty := 0;
      FragilityScale := 0;
    end;
  else
    Price := 0;
    WeightPenalty := 0;
  end;
  if Item.ItemType <> item_hull then
    Result := Effectiveness * EffectivenessScale * (1 + (2 - TEquipment(Item).GetFragilityFactor(NoFlags)) * FragilityScale) -
      Item.Weight * WeightPenalty - Price * MoneyPenalty
  else
    Result := (Item.Weight * HullValueScale / Max(0.01, TEquipment(Item).GetFragilityFactor(NoFlags)) + Effectiveness) * EffectivenessScale +
      Item.Weight * WeightPenalty - Price * 0.25 * MoneyPenalty;
end;
{ @end $5AFD68 }

{ @routine $5B0458 TTransport_EvaluateStatBonus }
function TTransport.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonus_armor: Result := Value * 150;
    bonus_fuel_capacity: Result := Value * 3.5;
    bonus_speed: Result := Value * 1.1;
    bonus_jump_range: Result := Value * 30;
    bonus_radar_range: Result := Value * 0.07;
    bonus_scanner_power: Result := Value * 3 + Value * 20 * CountWeaponsByDamageFlags(ScannerFlags);
    bonus_repair_points: Result := Value * 8 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonus_defense: Result := Value * 6 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonus_energy_damage: Result := Value * 9;
    bonus_splinter_damage: Result := Value * 9;
    bonus_missile_damage: Result := Value * 9 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonus_weapon_range: Result := Value * 1.2 * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonus_mass: Result := RemapClamped(Value + GetHull.Weight * 0.2, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 5500;
    bonus_radar_slots:
      if (GetSlotCount(slot_radar) = 0) and (Value > 0) then Result := TransportSlotBonusWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -TransportSlotBonusWeights[BonusKind] - TransportSlotBonusWeights[bonus_weapon_slots] * CountMissileWeapons
      else if (GetSlotCount(slot_radar) = 1) and (Value < 0) then Result := TransportSlotBonusWeights[BonusKind] * -0.3;
    bonus_repair_robot_slots:
      if (GetSlotCount(slot_repair_robot) = 0) and (Value > 0) then Result := TransportSlotBonusWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -TransportSlotBonusWeights[BonusKind]
      else if (GetSlotCount(slot_repair_robot) = 1) and (Value < 0) then Result := TransportSlotBonusWeights[BonusKind] * -0.3;
    bonus_defense_slots:
      if (GetSlotCount(slot_defense_generator) = 0) and (Value > 0) then Result := TransportSlotBonusWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -TransportSlotBonusWeights[BonusKind]
      else if (GetSlotCount(slot_defense_generator) = 1) and (Value < 0) then Result := TransportSlotBonusWeights[BonusKind] * -0.3;
    bonus_weapon_slots:
      begin
        if (GetSlotCount(slot_weapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(slot_weapon)) * TransportSlotBonusWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(slot_weapon)) * TransportSlotBonusWeights[BonusKind];
        if CountEquippedWeapons > Max(Value + GetSlotCount(slot_weapon), 1) then
          Result := Result - (TransportSlotBonusWeights[BonusKind] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(slot_weapon)));
      end;
    bonus_accuracy..bonus_leadership:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), Value) * TransportSkillBonusWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) > 6) then
          Result := Result + (TransportSkillBonusWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), -Value) * -TransportSkillBonusWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) < 0) then
          Result := Result + (TransportSkillBonusWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]));
      end;
  else Result := 0;
  end;
  if (TransportType = transport_diplomat) and (BonusKind in [bonus_speed, bonus_energy_damage..bonus_weapon_range, bonus_weapon_slots, bonus_charisma, bonus_mass]) then Result := Result * 1.3;
  if (TransportType = transport_standard) and (BonusKind in [bonus_fuel_capacity, bonus_jump_range]) then Result := Result * 1.3;
  if (TransportType = transport_liner) and (BonusKind in [bonus_armor, bonus_radar_range, bonus_repair_points, bonus_defense]) then Result := Result * 1.3;
  if BonusKind in [bonus_accuracy..bonus_leadership] then Result := Result * 0.01 * (100 + SeededRandomIntRange(-50, 50, Seed + 131 * Ord(BonusKind))) * RaceSkillEvaluationFactors[PilotRace, EquipmentBonusSkills[BonusKind]]
  else Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + 131 * Ord(BonusKind)));
end;
{ @end $5B0458 }

{ @routine $5B0D54 TTransport_EvaluateWeaponDamage }
function TTransport.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  ShockFlags = [damage_flag_shock];
  AcidFlags = [damage_flag_acid];
var
  ScannerFactor, StatusFactor: Single;
  Flags: TDamageFlagSet;
  SpeedFactor: Single;
  I, ShotTotal: Integer;
begin
  Flags := Weapon.GetDamageFlags;
  if (Flags * ScannerFlags <> []) and (GetScanner <> nil) and (GetRadar <> nil) then
    ScannerFactor := RemapClamped(GetScannerPower - DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(Galaxy.TechLevel)) + 1, -5, 10, 0.1, 2)
  else ScannerFactor := 0;
  Result := BaseDamage * GetWeaponArtefactDamageFactor(Weapon);
  if damage_flag_equipment_wear in Flags then Result := Result * 1.1;
  if damage_flag_life_steal in Flags then Result := Result * 1.5;
  if damage_flag_shock in Flags then Result := Result * (1.1 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  StatusFactor := 1;
  if damage_flag_scanner_bonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if damage_flag_bonus_to_damaged_hull in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if damage_flag_engine_wear in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if damage_flag_engine_wear in Flags then Result := Result + ScannerFactor * 10;
    if damage_flag_weapon_block in Flags then Result := Result + ScannerFactor * 10;
    Result := Result + CountWeaponsByDamageFlags(AcidFlags) * Weapon.GetShotCount;
    if damage_flag_acid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case Weapon.GetWeaponInfo.ShotType of
    shot_rocket: Result := Result * 1.0 * Weapon.GetShotCount * (1 + StatusFactor);
    shot_missile: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    shot_torpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor);
    shot_chain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    shot_splash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 * SpeedFactor + StatusFactor);
    shot_area_damage: Result := Result * (1 + Weapon.Range * 0.16 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
end;
{ @end $5B0D54 }

{ @routine $5B124C TTransport_RefreshCurrentStanding }
procedure TTransport.RefreshCurrentStanding;
var
  StandingMode: TStandingOverride;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = override_custom_faction then CurrentStanding := standing_custom
  else if StandingMode <> override_fixed then
  begin
    if (CurrentSystemKills.Pirate > 0) and (Galaxy.CoalitionDefeatedTurn = 0) then CurrentStanding := standing_coalition_active
    else CurrentStanding := standing_coalition_passive;
  end;
end;
{ @end $5B124C }

end.
