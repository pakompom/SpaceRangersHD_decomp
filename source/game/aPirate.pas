unit aPirate;
// Unit bracket (inferred): .text 0x0050CB04..0x005175C6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, aConst, EC_Buf, aItem, aShip, aGalaxy, aGalaxyStruct, aNormalShip, aPlanet;

type
  TPirate = class(TNormalShip) // @size 0x51C
  public
    PrisonTermRemaining: Cardinal; // @offset 0x510
    PirateType: Byte; // @offset 0x514  Zero denotes an independent pirate; nonzero values select clan variants.
    RaidPressure: Single; // @offset 0x518  AI pressure affecting target selection and departure decisions.

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $0050D638 @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $0050D688 @slot $04
    procedure AssignWeaponTargetsInStar; override; // @addr $00511490 @slot $20
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr $00515688 @slot $50
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $00515C30 @slot $54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr $00516AD0 @slot $58
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $0050F14C @slot $60
    procedure BuildReachablePlanetQueue; override; // @addr $0050E844 @slot $64
    procedure SelectEnemyShipInStar; override; // @addr $00511CBC @slot $6C
    procedure EngageEnemyShip; override; // @addr $00512898 @slot $70
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $005101EC @slot $74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $00510290 @slot $78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $00510400 @slot $7C
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $0050FDB8 @slot $80
    function RecomputeFearState: Boolean; override; // @addr $005105FC @slot $84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $00510DB8 @slot $88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $00510E88 @slot $8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $00510EAC @slot $90
    function AcceptPickupItem(Item: TItem): Boolean; override; // @addr $00517418 @slot $94
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; override; // @addr $00517430 @slot $98
    procedure ProcessCombatDialogue; override; // @addr $00512A94 @slot $A0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $00512BE8 @slot $A4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $00512DD0 @slot $A8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $005134B0 @slot $AC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $005139F8 @slot $B0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $005140BC @slot $B4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $005145E4 @slot $B8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $005147D4 @slot $BC
    function RefusesFactionNegotiation(OtherShip: TShip): Boolean; override; // @addr $00514FA4 @slot $C0
    procedure RefreshCurrentStanding; override; // @addr $005174E4 @slot $C4
    destructor Destroy; override; // @addr $50CC28
    function NavigateToServicePlanet(Absolute: Boolean): Boolean; // @addr $50E6C0
    function SelectServicePlanet: TPlanet; // @addr $50E784
    procedure TryJumpToNearbyBattle(UnusedMode: Byte); // @addr $50EA34 The native entry stores but never reads dl; the sole caller passes zero.
    function TryDockAtStation(Types: TShipTypeMask): Boolean; // @addr $50EB40
    procedure MoveToRandomPlanetOrbit; // @addr $514F3C

    procedure TryOfferRansomToPursuer; // @addr $510A50
    function ProcessImprisonment: Boolean; // @addr $5112F0 True while the current turn is spent in prison.
    procedure ProcessUnseenProgression; // @addr $50F720

    procedure ReviewPartnership; // @addr $514C58
    procedure SelectIncidentalEnemy; // @addr $5123F8
    function TryRetreatFromSystem: Boolean; // @addr $515024

    procedure InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: Byte); // @addr 0x50CF8C @note "Sets location, money and PirateType; registers the ship with its star."

    procedure NextDay; override; // @addr 0x50D718 @slot 0x18
    procedure NextDayLogic; override; // @addr 0x50D938 @slot 0x1C @calls "0x50D7B7"
    function GetGreetingShipCategory: Byte; override; // @addr $50F5D4 @slot $30
    function GetHomeStar: TStar; override; // @addr $50F3EC @slot $34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $50F60C @slot $3C
    function GetDominantCareer: TRangerCareer; override; // @addr 0x50F5F8 @slot 0x38 @note "Always rcPirate."
    function GetName: WideString; override; // @addr 0x50F408 @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x50F428 @slot 0x28

    procedure SelectNearestReachableDestination; // @addr $50EBD4 Prefers the leader's route, then nearby service locations or reachable non-Dominator stars.
    procedure SellAllCargoGoods; // @addr 0x50F108
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x50F620 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x50F6F0 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x50E9F4 @slot 0x68 @note "AI ownership check only; does not test travel range."
  end;

const
  // Entries 22..27 of the $515C66 dispatch table enter $516662. These reads reload
  // the unchanged BonusKind byte at EBP-5; $87B3B8 is the base biased by -22*4.
  PirateSkillBonusWeights: array[bonSkill1..bonSkill6] of Integer = (90, 90, 90, 90, 30, 5); // @addr $87AD18 @indexrefs "$5166B8,$516732,$51679D,$516815"
  // EvaluateStatBonus dispatch bounds the indexed BonusKind to 13..20.
  PirateSlotBonusWeights: array[bonSlotRadar..bonSlotForsage] of Integer = (100, 150, 150, 400, 150, 100, 20, 100); // @addr $87AD30 @indexrefs "$0051603E,$0051607E,$005160BE,$005160EF,$0051614B,$0051618B,$005161BC,$005161EB,$00516229,$0051625A,$00516289,$005162C7,$005162F8,$00516327,$00516365,$005163C1,$0051640B,$005164A2,$0051651C,$00516578,$00516614,$00516644"

implementation

uses aPlayer, Achievements, aGalaxyEvent, aAsteroid, aMissile, aScript, aRuins, EC_Struct, Classes, Math, Windows, SysUtils, aRanger, aTranclucator, GR_Main, Globals, GlobalsV, EC_Str, aItem, aGalaxy, aShip, aConst, aMyFunction;

{ @routine $50CC28 TPirate_Destroy }
destructor TPirate.Destroy;
begin
  if OwnerId = oiPirate then Dec(Galaxy.PirateClanCount) else Dec(Galaxy.PirateCount);
  inherited;
end;
{ @end $50CC28 }

{ @routine $50CF8C TPirate_InitGenerated }
procedure TPirate.InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: Byte);
var I: Integer; Ranger: TRanger; HasHull: Boolean;
  // @nested $50CC78 SelectUniqueName
  procedure SelectUniqueName(Config: TBlockParEC); // @addr $50CC78 @note "Nested helper with caller-popped static link."
  var Index, Attempt, I, J, LastIndex, FirstIndex: Integer; Duplicate: Boolean; Star: TStar; Ship: TShip; Block: TBlockParEC;
  begin
    if (Config <> nil) and (Config.CountBlocks('Pirate') <> 0) then begin
      Block := Config.GetBlock('Pirate');
      if RaceToOwner(PilotRace) = OwnerId then Block := Block.GetBlock(OwnerToSys(OwnerId))
      else begin
        if Block.CountBlocks(OwnerToSys(OwnerId)) > 0 then Block := Block.GetBlock(OwnerToSys(OwnerId));
        if Block.CountBlocks(OwnerToSys(RaceToOwner(PilotRace))) > 0 then Block := Block.GetBlock(OwnerToSys(RaceToOwner(PilotRace)));
      end;
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
            if (Self <> Ship) and (Ship.TypeId = stPirate) and ((Ship as TPirate).Name = Name) then begin Duplicate := True; Break; end;
          end;
        end;
        if not Duplicate then Break;
        IncrementWrapped(Index, FirstIndex, LastIndex);
        if Attempt = LastIndex then Name := Name + ' ' + '-' + IntToStr(Cardinal(Id) mod 100 + 1) + '-';
      end;
    end;
  end;
begin
  HasHull := GetHull <> nil;
  if HasHull or (Planet.OwnerId = oiPirate) then Inc(Galaxy.PirateClanCount) else Inc(Galaxy.PirateCount);
  HomePlanet := Planet;
  if not HasHull then CurrentPlanet := HomePlanet;
  CurrentStar := HomePlanet.CurrentStar;
  CurrentStar.Ships.Add(Self);
  if HasHull then begin
    OwnerId := oiPirate;
    if GetHull.OwnerId in PlanetOwnerMasks.Coalition then PilotRace := OwnerToRace(GetHull.OwnerId)
    else if HomePlanet.IsMainPiratePlanet then PilotRace := OwnerToRace(PickRandomEquipmentOwner(HomePlanet.RandomState))
    else PilotRace := HomePlanet.RaceId;
  end else begin
    if HomePlanet.IsMainPiratePlanet then PilotRace := OwnerToRace(PickRandomEquipmentOwner(HomePlanet.RandomState))
    else PilotRace := HomePlanet.RaceId;
    if HomePlanet.OwnerId = oiPirate then OwnerId := oiPirate else OwnerId := RaceToOwner(PilotRace);
  end;
  SetMoney(InitialMoney);
  TypeId := stPirate;
  PirateType := Kind;
  Name := '';
  SelectUniqueName(ModShipNameConfig);
  if Length(GetName) = 0 then SelectUniqueName(LanguageDataConfig.GetBlock('ShipName'));
  if GetPlayer <> nil then begin
    Rank := NextRandomIntRange(0, GetPlayer.Rank, RandomState);
    if Rank > 3 then Rank := 3;
    AddRankPoints(NextRandomIntRange(0, CoalitionRankPointThresholds[Rank] div 2, RandomState));
    if not Galaxy.IsZeroStartingExperienceEnabled then GainExperience(Round(RemapClamped(ShortInt(Rank + Byte(0)), 0, 3, TotalSkillTrainingCost div 8, TotalSkillTrainingCost div 2)), 0);
    if OwnerId = oiPirate then begin
      PirateRank := NextRandomIntRange(0, GetPlayer.PirateRank, RandomState);
      if PirateRank > 3 then PirateRank := 3;
      AddPirateRankPoints(NextRandomIntRange(0, PirateRankPointThresholds[PirateRank] div 2, RandomState));
    end;
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  if not HasHull then begin
    if OwnerId = oiPirate then CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), 1, RaceToOwner(PilotRace), SelectRandomHullSeries, True)
    else CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), 1, OwnerId, SelectRandomHullSeries, False);
    CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
    CreateAndEquipEngine(Round(EquipmentSizeFactors[NextRandomIntRange(1, 2, RandomState)] * EngineBaseSize), NextRandomIntRange(1, 2, RandomState), OwnerId);
    if GetSlotCountForItemType(Ord(t_CargoHook)) > 0 then CreateAndEquipCargoHook(CargoHookBaseSize, NextRandomIntRange(1, 2, RandomState), OwnerId);
    if GetSlotCount(sskWeapon) > WeaponCount then CreateAndEquipWeapon(Ord(t_Weapon1), WeaponInfos[t_Weapon1].AverageSize, 1, OwnerId);
    if GetSlotCountForItemType(Ord(t_Radar)) > 0 then CreateAndEquipRadar(Round(EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)] * RadarBaseSize), 1, OwnerId);
  end else RefreshGraphic;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  SmoothedSpeed := Speed;
  SmoothedEnemySpeed := Speed;
  if not HasHull then begin
    BuyEquipmentAtLocation(True);
    BuyEquipmentAtLocation(True);
    BuyEquipmentAtLocation(True);
    if PirateType <> 0 then BuyEquipmentAtLocation(True);
    if PirateType <> 0 then BuyEquipmentAtLocation(True);
  end;
  for I := 0 to Galaxy.Rangers.Count - 1 do begin
    Ranger := Galaxy.Rangers[I];
    RangerRelations.Add(Pointer(Min(50, OwnerRelations[OwnerId, Ranger.OwnerId] - 20)));
  end;
  PrisonTermRemaining := 0;
  RaidPressure := 0;
end;
{ @end $50CF8C }

{ @routine $50D638 TPirate_SaveToBuffer }
procedure TPirate.SaveToBuffer(Buffer: TBufEC);
begin
  inherited;
  Buffer.AddDWord(PrisonTermRemaining);
  Buffer.AddAnsiChar(AnsiChar(PirateType));
  Buffer.AddSingle(RaidPressure);
end;
{ @end $50D638 }

{ @routine $50D688 TPirate_LoadFromBuffer }
procedure TPirate.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited;
  if LoadedSaveVersion >= 60 then PrisonTermRemaining := Buffer.GetUInt32 else PrisonTermRemaining := Buffer.GetByte;
  PirateType := Buffer.GetByte;
  if LoadedSaveVersion >= 79 then RaidPressure := Buffer.GetSingle else RaidPressure := 0;
end;
{ @end $50D688 }

{ @routine $50D718 TPirate_NextDay }
procedure TPirate.NextDay;
begin
  inherited NextDay;
  try
    if (ScriptShip <> nil) and HasScriptControl then begin
      ScriptNextDay;
      if ScriptShip <> nil then begin
        if PrisonTermRemaining > 0 then ProcessImprisonment;
        Exit;
      end;
    end;
    NextDayLogic;
    if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TPirate.NextDay ' + GetFullName(' '));
    end;
  end;
end;
{ @end $50D718 }

{ @routine $50D938 TPirate_NextDayLogic }
procedure TPirate.NextDayLogic;
var Planet: TPlanet; Station, Ship: TShip; Stage: Integer; ClanShip, Collecting: Boolean; I, Count: Integer;
begin
  Stage := 0;
  try
    ClanShip := (PirateType <> 0) and (OwnerId = oiPirate);
    if CurrentPlanet <> nil then begin
      Stage := 1;
      if not (CurrentPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) or (ClanShip and not (CurrentPlanet.OwnerId in PlanetOwnerMasks.PirateClan)) then begin OrderTakeoff; Exit; end;
      begin
        Stage := 2;
        if not ClanShip then if ProcessImprisonment then Exit;
        LastDockedPlanet := CurrentPlanet;
        RepairBrokenEquipmentAtLocation;
        AutoEquipInventory;
        Stage := 3;
        OptimizeInventory;
        SellAllCargoGoods;
        RefuelAtLocation;
        ReloadWeaponAmmo;
        if RepairHullAtLocation then Exit;
        Stage := 4;
        BuyEquipmentAtLocation(False);
        RestoreEssentialEquipment;
        ProcessUnseenProgression;
        TrainSkillsAutomatically;
        OrderTakeoff;
      end;
      Exit;
    end;
    if DockedTo <> nil then begin
      Stage := 5;
      if not (DockedTo.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) then begin
        if DockedTo.InNormalSpace then OrderTakeoff else OrderNone(False);
        Exit;
      end;
      begin
        SynchronizeDockedLocation;
        RepairBrokenEquipmentAtLocation;
        AutoEquipInventory;
        Stage := 6;
        OptimizeInventory;
        SellAllCargoGoods;
        RefuelAtLocation;
        ReloadWeaponAmmo;
        TrainSkillsAutomatically;
        if RepairHullAtLocation and not ClanShip then Exit;
        Stage := 7;
        BuyEquipmentAtLocation(False);
        RestoreEssentialEquipment;
        ProcessUnseenProgression;
        TrainSkillsAutomatically;
        if DockedTo.InNormalSpace and ((TRuins(DockedTo).FlyToStar = nil) or (TRuins(DockedTo).FlyToStar = CurrentStar)) then OrderTakeoff
        else begin
          if ((TRuins(DockedTo).FlyToStar = nil) or (TRuins(DockedTo).FlyToStar.Dominion <> DockedTo)) and
            ((DockedTo.OrderTarget = nil) or not (DockedTo.OrderTarget is TStar) or (TStar(DockedTo.OrderTarget).Dominion <> DockedTo)) then RaidPressure := 0.05 + RaidPressure;
          OrderNone(False);
        end;
      end;
      Exit;
    end;
    if InNormalSpace then begin
      Stage := 8;
      AutoApplyMicroModules;
      BuildReachablePlanetQueue;
      if RecomputeFearState then TryOfferRansomToPursuer;
      ProcessCombatDialogue;
      Stage := 9;
      AssignWeaponTargetsInStar;
      ReviewPartnership;
      AfterburnerActive := False;
      if ClanShip then begin
        Stage := 10;
        SelectEnemyShipInStar;
        EngageEnemyShip;
        RecomputeFearState;
      end;
      Stage := 11;
      if TryRetreatFromSystem then Exit;
      if InFear and ((CurrentStar.ControlFaction = sfPirates) or not ClanShip) then begin
        Stage := 12;
        if not (Order in [soLand, soJump]) and not OrderAbsolute then begin
          Stage := 13;
          if ClanShip then begin
            Planet := SelectNearestQueuedPlanet;
            if (Planet <> nil) and (Planet.CurrentStar = CurrentStar) then OrderLanding(Planet, True)
            else begin
              Station := FindNearestDockableStation(NonTargetableStationStandingMasks[sfPirates]);
              if Station <> nil then OrderLanding(Station, True) else EngageEnemyShip;
            end;
          end else begin
            if NextRandomUnitFloat(RandomState) > 0.8 then TryDockAtStation([6..13]);
            if Order <> soLand then
              if NextRandomUnitFloat(RandomState) > 0.66 then NavigateToEscapePlanet(True) else NavigateToQueuedPlanet(True);
            if (Order in [soLand, soJump]) and (EstimateOrderTravelTurns > 4) and (EnemyShip <> nil) and
              (EnemyShip.OrderTarget = Self) and (EnemyShip.TypeId in [stRanger, stPirate]) and (EnemyShip.EstimateOrderTravelTurns < 3) and
              (NextRandomUnitFloat(RandomState) < 0.2) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 2 = 0) then
              if JettisonCargoGoodsTowardTargetValue(Max(200, Galaxy.ComputeScaledMiniMoney(OwnerId))) then NotifyFearCargoDrop(EnemyShip);
          end;
        end;
        Stage := 14;
        if Order in [soLand, soJump] then UpdateAfterburnerState
        else if ClanShip then EngageEnemyShip
        else if Order = soNone then begin SelectEnemyShipInStar; EngageEnemyShip; end;
      end else begin
        Stage := 15;
        QueueItemsWithinPickupRange;
        Stage := 16;
        if PartnerShip <> nil then begin
          if not OrderAbsolute then begin
            if TryMirrorPartnerTravelOrders then Exit;
          end else Exit;
        end;
        Stage := 17;
        if not ClanShip then begin
          Stage := 18;
          Collecting := TryCollectBestFloatingItem(50);
          if not Collecting and (GetDesiredCargoFreeSpace > CargoFreeSpace) then
            if NextRandomUnitFloat(RandomState) > 0.8 then TryDockAtStation([6..13]) else NavigateToQueuedPlanet(True);
          Stage := 19;
          if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (EnemyShip.CurrentPlanet <> nil) and (NextRandomUnitFloat(RandomState) < 0.2) then OrderNone(False);
          if not OrderAbsolute and not Collecting then begin
            Stage := 20;
            SelectEnemyShipInStar;
            EngageEnemyShip;
            if (Order = soNone) and not InFear then TryJumpToNearbyBattle(0);
            if Order = soNone then NavigateToServicePlanet(False);
          end;
        end;
      end;
      Stage := 21;
      if ClanShip then begin
        if (Order = soNone) and HasHullDamageOrBrokenEquippedItems then NavigateToServicePlanet(False);
        Stage := 22;
        if (Order = soNone) and not TryCollectBestFloatingItem(50) and
          ((GetDesiredCargoFreeSpace > CargoFreeSpace) or (NextRandomIntRange(1, 10, RandomState) <= 2)) then NavigateToQueuedPlanet(True);
        if (Order = soMove) and (PickupTargets = nil) and (NextRandomIntRange(1, 10, RandomState) <= 3) then TryCollectBestFloatingItem(50);
        Stage := 23;
        if (Order = soNone) and (NextRandomIntRange(1, 10, RandomState) <= 2) then begin
          Station := FindNearestDockableStation(NonTargetableStationStandingMasks[sfPirates]);
          if Station <> nil then OrderLanding(Station, True);
        end;
        Stage := 24;
        if Order = soNone then SelectIncidentalEnemy;
      end;
      Stage := 25;
      if (CurrentStar.Dominion <> nil) and TShip(CurrentStar.Dominion).CanDock(Self) and
        (TRuins(CurrentStar.Dominion).FlyToStar <> nil) and (CurrentStar.Battle = 0) then begin
        Count := 0;
        for I := 0 to CurrentStar.Ships.Count - 1 do begin
          Ship := CurrentStar.Ships[I];
          if not Ship.InHyperspace and (Ship is TPirate) and (Ship.OwnerId = oiPirate) and (Ship.PartnerShip = nil) and
            not Ship.HasScriptControl and (Ship <> Self) and (Ship.DockedTo <> CurrentStar.Dominion) then Inc(Count);
        end;
        Stage := 26;
        if Count >= 3 then begin
          OrderLanding(CurrentStar.Dominion, False);
          if Galaxy.CurrentTurn + EstimateOrderTravelTurns + 1 > TRuins(CurrentStar.Dominion).FlyDate then UpdateAfterburnerState;
        end;
      end;
      Stage := 27;
      if (CurrentStar.Dominion <> nil) and TShip(CurrentStar.Dominion).InNormalSpace and (Order in [soNone, soMove]) then
        for I := 0 to CurrentStar.Ships.Count - 1 do begin
          Ship := CurrentStar.Ships[I];
          if Ship.InHyperspace then if Ship.AbductedByPirateClan then begin
            OrderMove(TShip(CurrentStar.Dominion).Position, False);
            Break;
          end;
        end;
      Stage := 28;
      if Order = soNone then
        if ClanShip then MoveToRandomPlanetOrbit else OrderRandomFreeFlightMove;
      Exit;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TPirate.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $50D938 }

{ @routine $50E6C0 TPirate_NavigateToServicePlanet }
function TPirate.NavigateToServicePlanet(Absolute: Boolean): Boolean;
var Planet: TPlanet;
begin
  Result := False;
  if PirateType <> 0 then begin
    BuildReachablePlanetQueue;
    if PlanetQueue.Count > 0 then begin
      OrderLanding(PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)], False);
      Result := True;
    end;
  end else begin
    Planet := SelectServicePlanet;
    if Planet <> nil then begin
      if CurrentStar = Planet.CurrentStar then OrderLanding(Planet, Absolute) else OrderJump(Planet.CurrentStar, Absolute);
      Result := True;
    end;
  end;
end;
{ @end $50E6C0 }

{ @routine $50E784 TPirate_SelectServicePlanet }
function TPirate.SelectServicePlanet: TPlanet;
begin
  if PlanetQueue.Count > 0 then begin
    Result := TList(Integer(PlanetQueue) + 0)[0];
    if (GetFuelTanks.Fuel < GetFuelTanks.Capacity) or HasHullDamageOrBrokenEquippedItems or (NextRandomUnitFloat(RandomState) < 0.1) then Exit;
    Result := PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)];
  end else Result := nil;
end;
{ @end $50E784 }

{ @routine $50E844 TPirate_BuildReachablePlanetQueue }
procedure TPirate.BuildReachablePlanetQueue;
var I, J: Integer; Planet: TPlanet; Star: TStar;
begin
  ClearPlanetQueue;
  PlanetQueue := TList.Create;
  if Speed = 0 then Exit;
  if PirateType <> 0 then begin
    if CurrentStar.Status.CustomFaction = '' then
      for I := 0 to CurrentStar.Planets.Count - 1 do begin
        Planet := CurrentStar.Planets[I];
        if Planet.OwnerId = OwnerId then PlanetQueue.Add(Planet);
      end;
  end else
    for I := 0 to Galaxy.Stars.Count - 1 do begin
      Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
      if (I > 0) and (CurrentStar.StarDistances[I].Distance > JumpRange) then Break;
      if Star.Constellation.Id <> 20 then begin
        if Star.Status.CustomFaction <> '' then Exit;
        for J := 0 to Star.Planets.Count - 1 do begin
          Planet := Star.Planets[J];
          if (Planet.OwnerId in [oiMaloc..oiGaal, oiPirate]) and CanQueueReachablePlanet(Planet) then PlanetQueue.Add(Planet);
        end;
      end;
    end;
end;
{ @end $50E844 }

{ @routine $50E9F4 TPirate_CanQueueReachablePlanet }
function TPirate.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := (Planet.OwnerId <> oiDominator) and ((PirateType = 0) or (Planet.OwnerId = OwnerId));
end;
{ @end $50E9F4 }

{ @routine $50EA34 TPirate_TryJumpToNearbyBattle }
procedure TPirate.TryJumpToNearbyBattle(UnusedMode: Byte);
var I: Integer; Star: TStar; Good: Byte;
begin
  for Good := 0 to 7 do if CargoGoods[Good].Count > 0 then Exit;
  for I := 1 to Galaxy.Stars.Count - 1 do begin
    if CurrentStar.StarDistances[I].Distance > JumpRange then Break;
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (Star.Battle <> 0) and ((Star.ControlFaction = sfCoalition) or (GetFuelTanks.Fuel div 2 > CurrentStar.StarDistances[I].Distance)) and
      (Star.Ships.Count - 3 >= Star.ShipTypeCounts[stKling]) and (Star.Ships.Count < 13) then begin
      OrderJump(Star, False);
      Exit;
    end;
  end;
end;
{ @end $50EA34 }

{ @routine $50EB40 TPirate_TryDockAtStation }
function TPirate.TryDockAtStation(Types: TShipTypeMask): Boolean;
var I: Integer; Ship: TShip;
begin
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship.TypeId in Types) and Ship.InNormalSpace and Ship.CanDock(Self) then begin
      OrderLanding(Ship, True);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{ @end $50EB40 }

{ @routine $50EBD4 TPirate_SelectNearestReachableDestination }
procedure TPirate.SelectNearestReachableDestination;
var I: Integer; Star: TStar; Planet: TPlanet; Ship: TShip; Turns, CandidateTurns: Integer; Target: TObject; BestTurns: Integer;
begin
  if PartnerShip <> nil then begin
    if PartnerShip.CurrentStar = CurrentStar then begin
      if (Order = soLand) and (PartnerShip.OrderTarget = OrderTarget) then Exit;
      if PartnerShip.Order = soLand then begin
        if CanRefuel or (HasCargoGoods and (GetDesiredCargoFreeSpace > CargoFreeSpace)) or (PartnerShip.OrderTarget is TRuins) or
          (GetHull.Weight - GetDesiredCargoFreeSpace < GetCarriedItemWeight) or (GetHullIntegrityPercent < 70) or HasHullDamageOrBrokenEquippedItems then begin
          if not (PartnerShip.OrderTarget is TRuins) or (PartnerShip.OrderTarget as TRuins).CanDock(Self) then OrderLanding(PartnerShip.OrderTarget, True);
          Exit;
        end;
      end else if PartnerShip.Order = soJump then begin
        Star := PartnerShip.OrderTarget as TStar;
        if (Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '') then begin OrderJump(Star, False); Exit; end;
      end;
    end else if (PartnerShip.Order = soJump) and (PartnerShip.OrderTarget is TStar) and (PartnerShip.OrderTarget <> CurrentStar) then begin
      Star := PartnerShip.OrderTarget as TStar;
      if (Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '') then begin OrderJump(Star, True); Exit; end;
    end else begin
      Star := PartnerShip.CurrentStar;
      if (Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '') then begin OrderJump(Star, True); Exit; end;
    end;
  end;
  if Order in [soLand, soJump, soJumpHole] then begin
    Turns := EstimateOrderTravelTurns;
    Target := OrderTarget;
    BestTurns := Turns;
  end else begin Turns := 1000; Target := nil; BestTurns := Turns; end;
  for I := 0 to CurrentStar.Planets.Count - 1 do begin
    Planet := CurrentStar.Planets[I];
    if CanQueueReachablePlanet(Planet) and (Planet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then begin
      CandidateTurns := EstimateTravelTurnsToObject(Planet);
      if BestTurns > CandidateTurns then begin BestTurns := CandidateTurns; Target := Planet; end;
    end;
  end;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and Ship.CanDock(Self) and (Ship.EnemyShip <> Self) and (EnemyShip <> Ship) then begin
      CandidateTurns := EstimateTravelTurnsToObject(Ship);
      if BestTurns > CandidateTurns then begin BestTurns := CandidateTurns; Target := Ship; end;
    end;
  end;
  if not (Target is TPlanet) and not (Target is TShip) then
    for I := 1 to Galaxy.Stars.Count - 1 do begin
      if CurrentStar.StarDistances[I].Distance > JumpRange then Break;
      Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
      if (Star.ControlFaction <> sfDominators) and (Star.Status.CustomFaction = '') then begin
        CandidateTurns := EstimateTravelTurnsToObject(Star);
        if BestTurns > CandidateTurns then begin BestTurns := CandidateTurns; Target := Star; end;
      end;
    end;
  if (Target <> nil) and (Target <> OrderTarget) then
    if Target is TPlanet then OrderLanding(Target, False)
    else if Target is TShip then OrderLanding(Target, False)
    else if Target is TStar then OrderJump(Target as TStar, False);
end;
{ @end $50EBD4 }

{ @routine $50F108 TPirate_SellAllCargoGoods }
procedure TPirate.SellAllCargoGoods;
var
  Good: Byte;
begin
  for Good := 0 to 7 do
    if CargoGoods[Good].Count > 0 then SellGoodsToLocation(Good, CargoGoods[Good].Count);
end;
{ @end $50F108 }

{ @routine $50F14C TPirate_RepairBrokenEquipmentAtLocation }
procedure TPirate.RepairBrokenEquipmentAtLocation;
var I, Cost: Integer; Equipment: TEquipment; Artefact: TEquipment;
begin
  if PirateType <> 0 then begin
    for I := 1 to Inventory.Count - 1 do begin
      Equipment := Inventory[I];
      if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and CanRepairEquipmentTech(Equipment) and
        ((Equipment.BrokenFlag <> 0) or (Equipment.ConditionPercent < 30)) and (Equipment.EquippedFlag <> 0) then Equipment.Repair;
    end;
    if CanRepairArtefactsAtLocation then
      for I := 0 to Artefacts.Count - 1 do begin
        Artefact := Artefacts[I];
        if (Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 30) then
          if Artefact.EquippedFlag <> 0 then Artefact.Repair;
      end;
  end else begin
    for I := Inventory.Count - 1 downto 0 do begin
      Equipment := Inventory[I];
      if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and CanRepairEquipmentTech(Equipment) and
        ((Equipment.BrokenFlag <> 0) or (Equipment.ConditionPercent < 50)) and (Equipment.EquippedFlag <> 0) then begin
        Cost := Equipment.CalculateRepairCost;
        if Money > Cost then SetMoney(Money - Cost);
        Equipment.Repair;
      end;
    end;
    if CanRepairArtefactsAtLocation then
      for I := 0 to Artefacts.Count - 1 do begin
        Artefact := Artefacts[I];
        if ((Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 50)) and (Artefact.EquippedFlag <> 0) then begin
          Cost := Artefact.CalculateRepairCost;
          if Money > Cost then SetMoney(Money - Cost);
          Artefact.Repair;
        end;
      end;
  end;
end;
{ @end $50F14C }

{ @routine $50F3EC TPirate_GetHomeStar }
function TPirate.GetHomeStar: TStar;
begin
  Result := HomePlanet.CurrentStar;
end;
{ @end $50F3EC }

{ @routine $50F408 TPirate_GetName }
function TPirate.GetName: WideString;
begin
  Result := Name;
end;
{ @end $50F408 }

{ @routine $50F428 TPirate_GetFullName }
function TPirate.GetFullName(const Separator: WideString): WideString;
var
  Path, RaceName, Text: WideString;
begin
  RaceName := OwnerToSys(RaceToOwner(PilotRace));
  if TypeNameOverrideKey <> '' then
  begin
    Path := 'ShipType.' + RaceName + '.' + TypeNameOverrideKey;
    if LanguageDataConfig.CountParamsByPath(Path) > 0 then Text := LocalizedText(Path)
    else Text := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Text <> '' then Result := Text + Separator + Name else Result := Name;
  end
  else Result := LocalizedText('ShipType.' + RaceName + '.' + GetTypeNameKey) + Separator + Name;
end;
{ @end $50F428 }

{ @routine $50F5D4 TPirate_GetGreetingShipCategory }
function TPirate.GetGreetingShipCategory: Byte;
begin
  if OwnerId = oiPirate then Result := gscPirateClan else Result := gscPirate;
end;
{ @end $50F5D4 }

{ @routine $50F5F8 TPirate_GetDominantCareer }
function TPirate.GetDominantCareer: TRangerCareer;
begin
  Result := rcPirate;
end;
{ @end $50F5F8 }

{ @routine $50F60C TPirate_GetStrengthScaledPirateStatus }
function TPirate.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 50;
end;
{ @end $50F60C }

{ @routine $50F620 TPirate_GetDesiredCargoFreeSpace }
function TPirate.GetDesiredCargoFreeSpace: Integer;
begin
  if PirateType <> 0 then
    Result := Trunc(RemapClamped(GetHull.Weight, HullBaseSize * EquipmentSizeFactors[5], HullBaseSize * EquipmentSizeFactors[1], 10, 50))
  else
    Result := Trunc(RemapClamped(GetHull.Weight, HullBaseSize * EquipmentSizeFactors[5], HullBaseSize * EquipmentSizeFactors[1], 30, 150));
end;
{ @end $50F620 }

{ @routine $50F6F0 TPirate_RefuelAtLocation }
procedure TPirate.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $50F6F0 }

{ @routine $50F720 TPirate_ProcessUnseenProgression }
procedure TPirate.ProcessUnseenProgression;
var Award: Byte; ProgressFactor, StrengthFactor: Double;
begin
  if (DaysSincePlayerSeen >= 60) and (GetPlayer <> nil) then
    if (OwnerId = oiPirate) and (PirateType <> 0) then begin
      ProgressFactor := ShortInt(Galaxy.DifficultyLevels[0] + Byte(0)) * 0.2 + 0.6;
      ProgressFactor := RemapClamped(Galaxy.WarDeltaWin[2], -10, 10, 1.3, 0.7) * ProgressFactor;
      StrengthFactor := ShortInt(Galaxy.DifficultyLevels[0] + Byte(0)) * 0.1 + 0.6;
      if (0.1 * ProgressFactor > NextRandomUnitFloat(RandomState)) and
        ((0.4 * StrengthFactor > StrengthInBestRanger) or (NextRandomUnitFloat(RandomState) < 0.1)) then
        if (NextRandomFloatRange(0, 0.7, RandomState) > WealthInBestRanger) and (Money < 25000) then
          SetMoney(Money + Galaxy.ComputeScaledBigMoney(oiHuman))
        else ImproveRandomEquipment(True);
      if (0.05 * ProgressFactor > NextRandomUnitFloat(RandomState)) and
        ((0.3 * StrengthFactor > StrengthInBestRanger) or (0.7 * StrengthFactor > StrengthInAverageRanger) or
        (0.001 * ProgressFactor > NextRandomUnitFloat(RandomState))) then GenerateExtraWeapon;
      if 0.05 * ProgressFactor > NextRandomUnitFloat(RandomState) then GainExperience(SeededRandomIntRange(100, 500, RandomState), 0);
      if (GetPlayer.PirateRank > PirateRank) and (NextRandomUnitFloat(RandomState) < 0.01) and (PirateRank < 4) then begin
        // Native adds Coalition rank points before attempting a pirate promotion.
        AddRankPoints(NextRandomIntRange(16, 32, RandomState));
        TryPromotePirateRank;
      end;
      if (NextRandomUnitFloat(RandomState) < 0.02) and (CurrentPlanet <> nil) and
        ((AwardIds = nil) or (2 * (Rank + 1) > AwardIds.Count)) then begin
        Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment, atSecretMission, atPerfidy], [stKling..Ord(rstCustomStation)]);
        if Award <> AwardNotFound then AddAward(Award);
      end;
    end else begin
      if (NextRandomUnitFloat(RandomState) < 0.2) and
        ((StrengthInBestRanger < 0.7) or (NextRandomUnitFloat(RandomState) < 0.3)) then
        if (NextRandomFloatRange(0, 0.7, RandomState) > WealthInBestRanger) and (Money < 25000) then
          SetMoney(Money + Galaxy.ComputeScaledBigMoney(oiHuman))
        else ImproveRandomEquipment(True);
      if (NextRandomUnitFloat(RandomState) < 0.05) and ((StrengthInBestRanger < 0.5) or (StrengthInAverageRanger < 1) or
        (NextRandomUnitFloat(RandomState) < 0.001)) then GenerateExtraWeapon;
      if NextRandomUnitFloat(RandomState) < 0.2 then GainExperience(NextRandomIntRange(250, 1000, RandomState), 0);
      if (OwnerId = oiPirate) and (GetPlayer.PirateRank > PirateRank) and (NextRandomUnitFloat(RandomState) < 0.01) and (PirateRank < 4) then begin
        AddRankPoints(NextRandomIntRange(16, 32, RandomState));
        TryPromotePirateRank;
      end;
      if (GetPlayer.Rank > Rank) and (NextRandomUnitFloat(RandomState) < 0.1) and (Rank < 4) then begin
        AddRankPoints(NextRandomIntRange(10, 20, RandomState));
        TryPromoteRank;
      end;
      if (NextRandomUnitFloat(RandomState) < 0.03) and (CurrentPlanet <> nil) and
        ((AwardIds = nil) or (2 * (Rank + 1) > AwardIds.Count)) then begin
        Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment..atPerfidy], [stKling..Ord(rstCustomStation)]);
        if Award <> AwardNotFound then AddAward(Award);
      end;
    end;
end;
{ @end $50F720 }

{ @routine $50FDB8 TPirate_RelationToNonRanger }
function TPirate.RelationToNonRanger(Ship: TShip): Byte;
begin
  if CurrentStanding = ssPirateMilitary then
    case Ship.TypeId of
      stTransport: if (CurrentStar.ControlFaction = sfCoalition) and (CurrentStar.Status.CustomFaction = '') and
        (CurrentStar = Ship.CurrentStar) and (TruceShip <> Ship) and (Ship.TruceShip <> Self) and
        not IsHullDestroyed and not AcceptsRansomDemandFrom(Ship) then Result := 0
        else Result := Min(50, Max(20, OwnerRelations[OwnerId, Ship.OwnerId] - 20));
      stPirate: if Ship.OwnerId = oiPirate then Result := Min(100, 100 + SeededRandomIntRange(-20, 20, Seed + Ship.Seed))
        else Result := Max(50, OwnerRelations[OwnerId, Ship.OwnerId]);
      stWarrior: Result := Min(50, Max(10, OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)] - 30));
      stKling, stTranclucator: Result := 50;
      Ord(rstRangerCenter)..Ord(rstCustomStation): if Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive] then Result := 30 else Result := 100;
    else Result := 0;
    end
  else begin
    if (CurrentStanding = ssPirateActive) and (Ship.CurrentStar.ControlFaction = sfPirates) and
      (Ship.CurrentStar.Status.CustomFaction = '') and (Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) then begin Result := 0; Exit; end;
    case Ship.TypeId of
      stTransport: Result := Min(50, Max(20, OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)] - 20));
      stPirate: Result := Max(60, OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)]);
      stWarrior: Result := Min(50, Max(10, OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)] - 30));
      stKling, stTranclucator: Result := 50;
      Ord(rstRangerCenter)..Ord(rstCustomStation): if (Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and (OwnerId = oiPirate) then Result := 30 else Result := 100;
    else Result := 50;
    end;
  end;
end;
{ @end $50FDB8 }

{ @routine $5101EC TPirate_RelationToRanger }
function TPirate.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := Byte(RangerRelations[Galaxy.Rangers.IndexOf(Ranger)]);
  if PirateType <> 0 then
    if (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = oiPirate) then
      Result := Min(Result, MainPiratePlanet.RelationToRanger(Galaxy.Rangers.IndexOf(Ranger)))
    else Result := 0;
end;
{ @end $5101EC }

{ @routine $510290 TPirate_ChangeRelationToRanger }
procedure TPirate.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var Relation: Byte; Value, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(RangerRelations[Index]);
  if (TShip(Ranger).GetEffectiveSkillLevel(psCharisma) > 0) and (Amount > 0) then
    Inc(Amount, Round(Amount * (TShip(Ranger).GetEffectiveSkillLevel(psCharisma)) * 0.2));
  Value := Max(0, Min(100, Amount + Relation));
  Relation := Value;
  RangerRelations[Index] := Pointer(Relation);
  if (Relation < 10) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $510290 }

{ @routine $510400 TPirate_ReactToAttack }
procedure TPirate.ReactToAttack(Attacker: TShip);
var Index, Value: Integer;
begin
  if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and
    (TTranclucator(Attacker).OwnerShip.TypeId = stRanger) then ReactToAttack(TTranclucator(Attacker).OwnerShip);
  EnemyShip := Attacker;
  if Attacker is TRanger then begin
    ChangeRelationToRanger(Attacker, -10);
    if (CurrentStanding in [ssPirateActive, ssPirateMilitary]) and (Attacker.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and
      (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = oiPirate) then begin
      Index := Galaxy.Rangers.IndexOf(Attacker);
      Value := Max(0, Integer(MainPiratePlanet.RangerRelations[Index]) - 3);
      MainPiratePlanet.RangerRelations[Index] := Pointer(Value);
    end;
  end;
  if Attacker.PartnerShip <> nil then
    if Attacker.PartnerShip.TypeId = stRanger then begin
      ChangeRelationToRanger(Attacker.PartnerShip, -5);
      if (CurrentStanding in [ssPirateActive, ssPirateMilitary]) and (Attacker.PartnerShip.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and
        (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = oiPirate) then begin
        Index := Galaxy.Rangers.IndexOf(Attacker.PartnerShip);
        Value := Max(0, Integer(MainPiratePlanet.RangerRelations[Index]) - 1);
      MainPiratePlanet.RangerRelations[Index] := Pointer(Value);
      end;
    end;
end;
{ @end $510400 }

{ @routine $5105FC TPirate_RecomputeFearState }
function TPirate.RecomputeFearState: Boolean;
var Ship: TShip; I, EnemyCount: Integer; Tolerance, Threat: Double;
begin
  if HasNoUsableWeapons and (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then begin
    Result := True;
    InFear := True;
    Exit;
  end;
  if (OwnerId = oiPirate) and (PirateType <> 0) then
    Result := ((GetHull.HullPoints < GetHull.Weight * 0.15) and (GetHull.HullPoints < 100)) or (GetHull.HullPoints < 65) or
      ((GetHull.Weight * 0.25 * OwnerInfo[OwnerId].FearThresholdScale > GetHull.HullPoints) and (EnemyShip <> nil) and
      (EnemyShip.OrderTarget = Self) and (ChanceToWin(EnemyShip) - OwnerInfo[OwnerId].FearThresholdScale / 2 < 0))
  else begin
  Result := (GetHull.HullPoints < GetHull.Weight * 0.2) or ((EnemyShip <> nil) and
    ((EnemyShip.OrderTarget = Self) or (GetPlayer = EnemyShip)) and AcceptsRansomDemandFrom(EnemyShip));
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
          ((Ship.RelationToShip(Self) < 10) and (PointDistanceSquared(Position, Ship.Position) < 250000)) then begin
          Inc(EnemyCount);
          Threat := Ship.ChanceToWin(Self) + Threat;
          if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or EnemyShip.IsOutsideStarSpace then EnemyShip := Ship
          else if (EnemyShip <> Ship) and (OrderTarget <> EnemyShip) then
            if PointDistanceSquared(EnemyShip.Position, Position) > PointDistanceSquared(Ship.Position, Position) then EnemyShip := Ship;
        end;
      end;
    end;
    if (EnemyCount - 1) * Threat * 0.33 + Threat > Tolerance then Result := True;
  end;
  end;
  InFear := Result;
  if InFear then RaidPressure := 0.5 * RaidPressure;
end;
{ @end $5105FC }

{ @routine $510A50 TPirate_TryOfferRansomToPursuer }
procedure TPirate.TryOfferRansomToPursuer;
var Response: WideString; Amount: Integer; LowOffer, HighOffer: Single; Accepted: Boolean; Ship: TShip;
begin
  if InNormalSpace and (EnemyShip <> nil) and (EnemyShip.OrderTarget = Self) and (EnemyShip.TruceShip <> Self) and
    (Money > 100) and not CanEscapePursuer(EnemyShip) and not (EnemyShip.TypeId in NonNegotiatingShipTypes) and
    not NoTalk and not EnemyShip.NoTalk and ((OwnerId <> oiPirate) or (PirateType = 0) or not (EnemyShip.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive])) then
    if (EnemyShip.GetMaxWeaponRange * EnemyShip.GetMaxWeaponRange >= PointDistanceSquared(Position, EnemyShip.Position)) and
      (((Galaxy.CurrentTurn * EnemyShip.Id mod 3 = 0) and (NextRandomUnitFloat(RandomState) > 0.2)) or (GetHullIntegrityPercent < 20)) then begin
      LowOffer := Min(Money, GetWealthScaledAmount(1));
      HighOffer := Min(Money, (GetWealthScaledAmount(3) + EnemyShip.GetWealthScaledAmount(4)) * 0.5);
      Amount := Round(Max(100, RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, HighOffer, LowOffer)));
      Ship := EnemyShip;
      Accepted := Ship.BuildTrucePaymentResponse(Self, Response, Amount);
      if (GetPlayer <> Ship) and (GetPlayer.CurrentStar = CurrentStar) then NotifyTruceOffer(Ship, Response, Amount);
      if Accepted and RecomputeFearState then TryOfferRansomToPursuer;
    end;
end;
{ @end $510A50 }

{ @routine $510DB8 TPirate_AcceptsRansomDemandFrom }
function TPirate.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := (GetHull.Weight * 0.6 * OwnerInfo[OwnerId].FearThresholdScale > GetHull.HullPoints) and
    (OwnerInfo[OwnerId].FearThresholdScale / 2 > ChanceToWin(Ship) * (1 + RaidPressure));
  if Result and (EnemyShip = Ship) then RaidPressure := 0;
end;
{ @end $510DB8 }

{ @routine $510E88 TPirate_TrustsAttackRequester }
function TPirate.TrustsAttackRequester(Ship: TShip): Boolean;
begin Result := RelationToShip(Ship) >= 30; end;
{ @end $510E88 }

{ @routine $510EAC TPirate_AcceptsAppealFrom }
function TPirate.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) +
    RemapClamped(Ship.Strength, 0.9 * Strength, Strength * 3, 0, 100) > 130;
end;
{ @end $510EAC }

{ @routine $5112F0 TPirate_ProcessImprisonment }
function TPirate.ProcessImprisonment: Boolean;
var I: Integer; Ship: TShip;
  // @nested $510F48 Imprison
  procedure Imprison; // @addr $510F48 @note "Nested helper; caller-popped static link."
  var I: Integer; Ship: TShip; Text: WideString;
  begin
    PrisonTermRemaining := NextRandomIntRange(61, 140, RandomState);
    CurrentSystemKills.Normal := 0;
    CurrentSystemKills.Pirate := 0;
    EnemyShip := nil;
    Result := True;
    for I := 0 to CurrentPlanet.Warriors.Count - 1 do begin
      Ship := CurrentPlanet.Warriors[I];
      if Self = Ship.EnemyShip then Ship.EnemyShip := nil;
    end;
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if Self = Ship.EnemyShip then Ship.EnemyShip := nil;
    end;
    Text := PickLocalizedTextVariant('GalaxyNews.GoToPrison.' + GetTypeNameKey, Seed + Cardinal(Galaxy.CurrentTurn div 10));
    ReplaceTextToken(Text, '<Star>', CurrentStar.Name, '<color=255,240,100>');
    ReplaceTextToken(Text, '<Planet>', CurrentPlanet.Name, '<color=255,240,100>');
    ReplaceTextToken(Text, '<Month>', IntToStr(Int64(PrisonTermRemaining div 30)), '<color=255,240,100>');
    ReplaceTextToken(Text, '<Name>', GetName, '<color=255,240,100>');
    ReplaceTextToken(Text, '<FullName>', GetFullName(' '), '<color=255,240,100>');
    if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and (Galaxy.CoalitionDefeatedTurn = 0) then
      AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
  end;
begin
  Result := False;
  if CurrentPlanet = nil then Exit;
  if PrisonTermRemaining > 0 then begin
    if ((CurrentStar.Battle <> 0) and (CurrentStar.LastDominatorPresenceTurn >= Galaxy.CurrentTurn - 1)) or (CurrentPlanet.OwnerId = oiPirate) then begin
      PrisonTermRemaining := 0;
      RefreshCurrentStanding;
      Result := False;
      Exit;
    end;
    Dec(PrisonTermRemaining);
    if PrisonTermRemaining = 0 then begin
      Result := False;
      RefreshCurrentStanding;
    end else Result := True;
  end else if (CurrentPlanet.OwnerId <> oiPirate) and ((CurrentStar.Battle = 0) or (CurrentStar.LastDominatorPresenceTurn < Galaxy.CurrentTurn - 1)) then begin
    for I := 0 to CurrentPlanet.Warriors.Count - 1 do begin
      Ship := CurrentPlanet.Warriors[I];
      if Ship.EnemyShip = Self then begin
        Imprison;
        RefreshCurrentStanding;
        Exit;
      end;
    end;
    if (NextRandomUnitFloat(RandomState) < 0.01) or (CurrentPlanet.GetRelationLevelToShip(Self) = rlHostile) then begin
      Imprison;
      RefreshCurrentStanding;
    end;
  end;
end;
{ @end $5112F0 }

{ @routine $511490 TPirate_AssignWeaponTargetsInStar }
procedure TPirate.AssignWeaponTargetsInStar;
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Item: TItem; Asteroid: TAsteroid; Distance: Single; Missile: TMissile;
begin
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; end;
  Assigned := 0;
  if CurrentStar.Battle <> 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship.OwnerId = oiDominator) and Ship.InNormalSpace then
        for J := 1 to WeaponCount do begin
          Weapon := Weapons[J];
          if (not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and
            (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
            if PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
              Weapon.Target := Ship;
              Inc(Assigned);
              if Assigned = WeaponCount then Exit;
            end;
        end;
    end;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if (not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and
        (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
          Weapon.Target := EnemyShip;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
    end;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if Ship.InNormalSpace and (Ship <> Self) and
      ((RelationToShip(Ship) < 10) or (Ship = EnemyShip) or (Ship.EnemyShip = Self)) and (TruceShip <> Ship) then
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        // Native hostile-ship pass can replace an earlier weapon target.
        if (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and IsEquipmentUsable(Weapon) then
          if PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
            Weapon.Target := Ship;
            Inc(Assigned);
            if Assigned = WeaponCount then Exit;
          end;
      end;
  end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do begin
    Missile := CurrentStar.Missiles[I];
    if (Missile.Target = Self) and (Missile.OwnerShip <> Self) then
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
          if PointDistanceSquared(Position, Missile.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
            Weapon.Target := Missile;
            Inc(Assigned);
            if Assigned = WeaponCount then Exit;
            Break;
          end;
      end;
  end;
  if IsEquipmentUsable(GetCargoHook) and not OrderAbsolute then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do begin
      Asteroid := CurrentStar.Asteroids[I];
      if Asteroid.MineralCount > CargoFreeSpace then Continue;
      Distance := PointDistanceSquared(Position, Asteroid.Position);
      if Distance <= 1000000 then
        for J := 1 to WeaponCount do begin
          Weapon := Weapons[J];
          // Native asteroid targeting can overwrite an existing assignment.
          if not (Weapon.GetWeaponInfo^.ShotType in [wstAreaDamage..wstRocket]) and IsEquipmentUsable(Weapon) then
            if Sqr(GetWeaponRange(Weapon)) >= Distance then begin
              Weapon.Target := Asteroid;
              Inc(Assigned);
              if Assigned = WeaponCount then Exit;
              Break;
            end;
        end;
    end;
  if Galaxy.GetAIJunkToleranceLevel < CurrentStar.Items.Count then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if ((Item.ItemType = t_Minerals) or not (Item.ItemType in [t_Food..t_Narcotics])) and
        ((Item.ItemType <> t_Minerals) or not IsRecentlyDroppedItem(Item)) and
        ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) and not CanCargoHookHandleItem(Item, Self) then
        if (GetPlayer.CurrentStar <> CurrentStar) or (GetRelationLevelToShip(GetPlayer) <= rlBad) or
          (PointDistance(GetPlayer.Position, Item.Position) >= 600) or
          ((NextRandomUnitFloat(RandomState) <= 0.2) and (PointDistance(GetPlayer.Position, Item.Position) >= 200)) then
          if CanSafelyDetonateItem(Item) then
            for J := 1 to WeaponCount do begin
              Weapon := Weapons[J];
              if not (Weapon.GetWeaponInfo^.ShotType in [wstAreaDamage..wstRocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
                if PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
                  Weapon.Target := Item;
                  Inc(Assigned);
                  if Assigned = WeaponCount then Exit;
                  Break;
                end;
            end;
    end;
end;
{ @end $511490 }

{ @routine $511CBC TPirate_SelectEnemyShipInStar }
procedure TPirate.SelectEnemyShipInStar;
var I: Integer; Ship, PreviousEnemy: TShip; Chance, BestChance, Distance, BestDistance: Double; PriorityTargetFound: Boolean;
begin
  if ((GetCargoHook <> nil) or (PirateType <> 0)) and
    ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or ((EnemyShip.ConsecutiveDockedDays > 3) and (PirateType <> 0))) and
    (UsableWeaponCount <> 0) then begin
    if GetPlayer.QuestTargetDefendShip <> nil then
      if (PirateType = 0) and (GetPlayer.QuestTargetDefendShip.CurrentStar = CurrentStar) and
        (GetPlayer.QuestTargetDefendShip <> Self) and GetPlayer.QuestTargetDefendShip.InNormalSpace and
        (GetPlayer.QuestTargetDefendShip <> TruceShip) and (GetPlayer.QuestTargetDefendShip.ScriptShip = nil) then begin
        EnemyShip := GetPlayer.QuestTargetDefendShip;
        AssignWeaponTargetsInStar;
        Exit;
      end;
    PriorityTargetFound := False;
    if PirateType = 0 then begin
      PreviousEnemy := EnemyShip;
      EnemyShip := nil;
      BestChance := 0;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if PriorityTargetFound and (Ship.TargetingRestriction <> 6) then Continue;
        if (Ship.TargetingRestriction in [1..3, 5]) or (Ship = Self) or not Ship.InNormalSpace or (TruceShip = Ship) or (Ship.TruceShip = Self) or
          ((GetPlayer = Ship) and (GetPlayer.TruceShip = Self)) or (Ship.LiberationGroup <> nil) or (GetPlayer.QuestTargetKillShip = Ship) or
          ((Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and ((OwnerId <> oiPirate) or (CurrentStar.Battle = 0) or (Ship.CurrentStanding in [ssNeutral..ssPirateMilitary]))) or (Ship.TypeId = stTranclucator) then Continue;
        if (CurrentStar.ControlFaction = sfDominators) or (CurrentStar.Status.CustomFaction <> '') or
          ((CurrentStar.ControlFaction = sfPirates) and (OwnerId = oiPirate) and (Galaxy.CoalitionDefeatedTurn = 0)) then begin
          if not (Ship is TNormalShip) or ((OwnerId = oiPirate) and (Ship.OwnerId <> oiPirate)) then begin
            EnemyShip := Ship;
            if ChanceToWin(Ship) > 0.5 then Exit;
          end;
        end else begin
          if (Ship.TargetingRestriction = 6) and not PriorityTargetFound then begin
            BestChance := ChanceToWin(Ship);
            PriorityTargetFound := True;
            EnemyShip := Ship;
          end else begin
            if (NextRandomIntRange(0, 30, RandomState) + 60 < RelationToShip(Ship)) and not Ship.AbductedByPirateClan then Continue;
            Chance := ChanceToWin(Ship);
            if GetPlayer = Ship then begin
              if (Galaxy.CurrentTurn < 100 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor + 300) or
                (NextRandomIntRange(0, 100, RandomState) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor < 40) then Continue;
              Chance := Chance * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor;
            end else if GetPlayer.QuestTargetDefendShip = Ship then Chance := Chance * 5;
            if (Chance < 0.3) and (StrengthInAverageRanger < 0.7) then Continue;
            if (Chance < 1.5) and (Ship.TypeId = stRanger) and (Ship.GetDominantCareer <> rcPirate) then Continue;
            if (Chance < 3.5) and (Ship.TypeId = stRanger) and (Ship.GetDominantCareer = rcPirate) then Continue;
            if (Chance < 3.5) and (Ship.TypeId = stPirate) then Continue;
            if not IsTargetStillPursuable(Ship) and (GetPlayer <> Ship) and (GetPlayer.QuestTargetDefendShip <> Ship) then Continue;
            if Chance > BestChance then begin
              EnemyShip := Ship;
              BestChance := Chance;
              if GetPlayer = EnemyShip then Break;
            end;
          end;
        end;
      end;
      if EnemyShip <> nil then begin
        if (EnemyShip.TargetingRestriction = 6) or not CanContactShip(EnemyShip) then begin AssignWeaponTargetsInStar; Exit; end;
        if not TryExtortShip(EnemyShip) then begin AssignWeaponTargetsInStar; Exit; end;
      end;
      EnemyShip := PreviousEnemy;
    end else if UsableWeaponCount <> 0 then begin
      EnemyShip := nil;
      BestDistance := 100000;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if Ship.InNormalSpace and (TruceShip <> Ship) and (Ship.TruceShip <> Self) and
          (not (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) or not (Ship.CurrentStanding in [ssNeutral..ssPirateMilitary])) and
          ((RelationToShip(Ship) < 10) or Ship.AbductedByPirateClan) then begin
          Distance := PointDistance(Position, Ship.Position);
          if NextRandomFloatRange(0.3, 3, RandomState) * BestDistance > Distance then begin EnemyShip := Ship; BestDistance := Distance; end;
        end;
      end;
    end;
  end;
end;
{ @end $511CBC }

{ @routine $5123F8 TPirate_SelectIncidentalEnemy }
procedure TPirate.SelectIncidentalEnemy;
var I: Integer; Ship: TShip; Distance, BestDistance: Double; Aggression: Integer;
begin
  EnemyShip := nil;
  BestDistance := 100000;
  Aggression := Round(RemapClamped(Galaxy.GetCoalitionToPirateSystemRatio, 0.5, 1, 100, -200));
  if NextRandomIntRange(1, 100, RandomState) < RemapClamped(CurrentStar.CountPirateShips(True), 30, 60, 0, 100) * (1 + RaidPressure * 0.1) then Aggression := 100;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if Ship.InNormalSpace and (TruceShip <> Ship) and not (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Ship.TypeId <> stTranclucator) and (Ship <> Self) and
      not (Ship.TargetingRestriction in [1..3, 5]) and not AcceptsRansomDemandFrom(Ship) and
      ((RelationToShip(Ship) < 80) or (NextRandomIntRange(1, 100, RandomState) <= Aggression - 1)) and
      ((RelationToShip(Ship) < 60) or (NextRandomIntRange(1, 100, RandomState) <= Aggression + 33)) and
      ((RelationToShip(Ship) < 30) or (NextRandomIntRange(1, 100, RandomState) <= Aggression + 66)) and
      ((RelationToShip(Ship) < 10) or (NextRandomIntRange(1, 100, RandomState) <= Aggression + 100)) and
      ((not (Ship is TPirate) and (GetPlayer <> Ship) and ((Ship.OwnerId <> oiPirate) or not (Ship is TNormalShip))) or
      (((Ship.OwnerId <> oiPirate) or (Ship.PilotRace <> PilotRace) or (NextRandomIntRange(1, 100, RandomState) <= 50)) and
      ((ShortInt((Ship as TNormalShip).PirateRank) <= ShortInt(PirateRank + Byte(0))) or (NextRandomIntRange(1, 100, RandomState) <= 70)) and
      (((Ship as TNormalShip).PirateRank <= Integer(PirateRank) + 1) or (NextRandomIntRange(1, 100, RandomState) <= 70)) and
      (((Ship as TNormalShip).PirateRank <= Integer(PirateRank) + 2) or (NextRandomIntRange(1, 100, RandomState) <= 70)) and
      (((Ship as TNormalShip).PirateRank <> 7) or (NextRandomIntRange(1, 100, RandomState) <= 50)))) then begin
      Distance := PointDistance(Position, Ship.Position);
      if NextRandomFloatRange(0.3, 3, RandomState) * BestDistance > Distance then begin EnemyShip := Ship; BestDistance := Distance; end;
    end;
  end;
  if EnemyShip = nil then RaidPressure := Max(Aggression, 0) * 0.001 + RaidPressure;
end;
{ @end $5123F8 }

{ @routine $512898 TPirate_EngageEnemyShip }
procedure TPirate.EngageEnemyShip;
begin
  if Order = soFollowShip then OrderNone(False);
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then
    if EnemyShip.InNormalSpace then begin
      OrderFollowShip(EnemyShip, 1, False);
      if ChanceToWin(EnemyShip) < 0.8 then RequestAlliesAttackShip(EnemyShip);
    end else if (ChanceToWin(EnemyShip) > 2) and (GetHullIntegrityPercent > 70) and (EnemyShip.GetHullIntegrityPercent > 70) then
      if EnemyShip.CurrentPlanet <> nil then begin
        if (EnemyShip is TRanger) and (Cardinal((EnemyShip as TRanger).PrisonTermRemaining) > 0) then begin
          EnemyShip := nil;
          OrderNone(False);
        end else if (EnemyShip is TPirate) and (Cardinal((EnemyShip as TPirate).PrisonTermRemaining) > 0) then begin
          EnemyShip := nil;
          OrderNone(False);
        end else OrderMove(EnemyShip.CurrentPlanet.GetPosition, False);
      end else if EnemyShip.DockedTo <> nil then OrderMove(EnemyShip.DockedTo.Position, False);
end;
{ @end $512898 }

{ @routine $512A94 TPirate_ProcessCombatDialogue }
procedure TPirate.ProcessCombatDialogue;
begin
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 5 = 0) and
    not AcceptsRansomDemandFrom(EnemyShip) then TryExtortShip(EnemyShip);
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 4 = 0) and
    (((ChanceToWin(EnemyShip) < 1.1) and (GetHullIntegrityPercent > 30)) or
    ((OwnerId = oiPirate) and (CurrentStar.ControlFaction = sfPirates) and (CurrentStar.Status.CustomFaction = '') and (ChanceToWin(EnemyShip) < 2))) then
    RequestAlliesAttackShip(EnemyShip);
end;
{ @end $512A94 }

{ @routine $512BE8 TPirate_ReactToExtortionDemand }
procedure TPirate.ReactToExtortionDemand(Ranger: Pointer);
begin
  if (GetPlayer = Ranger) or (NextRandomUnitFloat(RandomState) < 0.05) then begin
    ChangeRelationToRanger(Ranger, -15);
    HomePlanet.ChangeRelationToRanger(Ranger, -1);
    (TObject(Ranger) as TRanger).AddPirateCareerActivity(1);
  end;
end;
{ @end $512BE8 }

{ @routine $512DD0 TPirate_BuildMoneyExtortionResponse }
function TPirate.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $512C64 PayDemand
  procedure PayDemand; // @addr $512C64 @note "Nested helper with caller-popped static link."
  var Event: TGalaxyEvent;
  begin
    OtherShip.SetMoney(OtherShip.Money + DemandedAmount);
    SetMoney(Money - DemandedAmount);
    OtherShip.TruceWithShip(Self);
    if GetPlayer = OtherShip then begin
      LastPlayerExtortionTurn := Galaxy.CurrentTurn;
      Event := AddGalaxyEvent('PlayerExtortsMoney');
      Event.AddData(DemandedAmount);
      Event.AddData(TypeId);
      Event.AddData(CurrentStar.Id);
      Event.AddData(Id);
      Event.AddData(Ord(OwnerId));
      Event.AddTextData(GetName);
      Event.AddTextData(TypeNameOverrideKey);
    end;
  end;
begin
  Result := False;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (CurrentStar <> EnemyShip.CurrentStar)) then EnemyShip := OtherShip;
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Money.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Money.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Money.WeAlreadyHavePact', OtherShip)
  else if RefusesFactionNegotiation(OtherShip) or not AcceptsRansomDemandFrom(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if DemandedAmount > RemapClamped(GetWinChancePercent(OtherShip), 0, 100, GetWealthScaledAmount(4), GetWealthScaledAmount(2)) then
    Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'SumIsVeryBig', OtherShip)
  else if Money < DemandedAmount then Response := LookupVisibleTalkText('Talk.Money.AnswerNotMoney', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'Ok', OtherShip);
    PayDemand;
    Result := True;
  end;
end;
{ @end $512DD0 }

{ @routine $5134B0 TPirate_BuildCargoExtortionResponse }
function TPirate.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
var Forced: Boolean; NextDemandTurn: Integer;
  // @nested $513218 DropDemand
  procedure DropDemand; // @addr $513218 @note "Nested helper with caller-popped static link."
  var Good: Byte; Pass, Count, TotalValue, LowValue, HighValue: Integer; Enough: Boolean; Divisor: Single; Event: TGalaxyEvent;
  begin
    TotalValue := 0;
    Enough := False;
    LowValue := GetWealthScaledAmount(2);
    HighValue := GetWealthScaledAmount(4);
    for Pass := 1 to 3 do begin
      for Good := 0 to 7 do
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
      Event.AddData(TypeId);
      Event.AddData(CurrentStar.Id);
      Event.AddData(Id);
      Event.AddData(Ord(OwnerId));
      Event.AddTextData(GetName);
      Event.AddTextData(TypeNameOverrideKey);
    end;
    OtherShip.OrderMove(Position, True);
  end;
begin
  Result := False;
  Forced := (GetPlayer = OtherShip) and OtherShip.IsHealthEffectActive(14);
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (CurrentStar <> EnemyShip.CurrentStar)) then EnemyShip := OtherShip;
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if RefusesFactionNegotiation(OtherShip) or not (AcceptsRansomDemandFrom(OtherShip) or Forced) then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) and not Forced then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if not HasCargoGoods then Response := LookupVisibleTalkText('Talk.Goods.AnswerNotGoods', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'Ok', OtherShip);
    DropDemand;
    if GetPlayer = OtherShip then PlayerExtortionPactActive := True;
    Result := True;
  end;
end;
{ @end $5134B0 }

{ @routine $5139F8 TPirate_BuildTrucePaymentResponse }
function TPirate.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $513860 AcceptPayment
  procedure AcceptPayment; // @addr $513860 @note "Nested helper with caller-popped static link."
  var I: Integer; Ship: TShip;
  begin
    OtherShip.AbductedByPirateClan := False;
    if (OwnerId = oiPirate) and (CurrentStar.ControlFaction = sfPirates) and (CurrentStar.Status.CustomFaction = '') and (OtherShip is TNormalShip) then
      if TNormalShip(OtherShip).CurrentSystemKills.Pirate > 0 then begin
        TNormalShip(OtherShip).CurrentSystemKills.Pirate := 0;
        for I := 0 to CurrentStar.Ships.Count - 1 do begin
          Ship := CurrentStar.Ships[I];
          if (Ship is TNormalShip) and (Ship.OwnerId = oiPirate) then Ship.TruceWithShip(OtherShip);
        end;
      end;
    if OtherShip is TRanger then begin
      if (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = oiPirate) then MainPiratePlanet.ChangeRelationToRanger(OtherShip, 10);
      (OtherShip as TRanger).AddTraderCareerActivity(1);
    end;
    OtherShip.SetMoney(OtherShip.Money - OfferedAmount);
    SetMoney(Money + OfferedAmount);
    TruceWithShip(OtherShip);
  end;
begin
  if RefusesFactionNegotiation(OtherShip) then begin
    Response := LookupVisibleTalkText('Talk.Refuse.Pirate', OtherShip);
    Result := False;
    Exit;
  end;

  if (GetPlayer = PartnerShip) and (GetPlayer.CurrentStar = CurrentStar) then begin
    Response := LookupVisibleTalkText('Talk.Pirate.TalkWithParent', OtherShip);
    Result := GetPlayer.BuildTrucePaymentResponse(OtherShip, Response, OfferedAmount);
    Exit;
  end;

  Result := False;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (OwnerId = oiPirate) and (OtherShip is TNormalShip) and (OtherShip.OwnerId <> oiPirate) and
    (OtherShip.CurrentStar.ControlFaction = sfPirates) and (OtherShip.CurrentStar.Status.CustomFaction = '') and
    (TNormalShip(OtherShip).CurrentSystemKills.Pirate > 0) then begin
    if 2 * Wealth * (1 / 15) < OfferedAmount then begin
      Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
      AcceptPayment;
      Result := True;
    end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
  end else if RecomputeFearState or ((ChanceToWin(OtherShip) < 1) and (GetHullIntegrityPercent < 40) and AcceptsRansomDemandFrom(OtherShip)) or ((ChanceToWin(OtherShip) < 0.2) and AcceptsRansomDemandFrom(OtherShip)) or
    (OfferedAmount > RemapClamped(GetWinChancePercent(OtherShip), 0, 100, GetWealthScaledAmount(1), GetWealthScaledAmount(5))) then begin
    Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptPayment;
    Result := True;
  end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $5139F8 }

{ @routine $5140BC TPirate_BuildAttackRequestResponse }
function TPirate.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
  // @nested $513F48 AcceptRequest
  procedure AcceptRequest; // @addr $513F48 @note "Nested helper with caller-popped static link."
  begin
    Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Ok', Requester);
    SetJointAttackTarget(Requester, Target);
    Result := True;
  end;
  // @nested $514020 FriendsPreferred
  function FriendsPreferred: Boolean; // @addr $514020 @note "Nested helper with caller-popped static link."
  var UnusedLocal: Integer; // Native gap before the floating-point temporaries.
  begin
    Result := Cardinal(RelationToShip(Target)) >= Round(RelationToShip(Requester) *
      RemapClamped(Galaxy.GetCoalitionToPirateSystemRatio, 0.33, 1, 1.3, 0));
  end;
begin
  Result := False;
  if Requester is TRanger then begin
    if Target.TypeId in [stRanger..stPirate] then Target.ChangeRelationToRanger(Requester, -20);
    if (Target.OwnerId = oiDominator) or (Target.TypeId = stPirate) then (Requester as TRanger).AddWarriorCareerActivity(1)
    else (Requester as TRanger).AddPirateCareerActivity(1);
  end;
  if (OrderTarget = Target) and (GetRelationLevelToShip(Target) = rlHostile) then AcceptRequest
  else if TruceShip = Target then Response := FormatText1(LookupVisibleTalkText('Talk.Attack.WeAlreadyHavePact', Requester), '<color=255,240,100>', '<Target>', Target.GetName)
  else if (RelationToShip(Target) >= 60) and FriendsPreferred then begin
    if not (Target is TTranclucator) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriends', Requester)
    else if TTranclucator(Target).OwnerShip = Self then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsMyTranc', Requester)
    else if TTranclucator(Target).OwnerShip = Requester then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsYourTranc', Requester)
    else Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriendsTranc', Requester);
  end else if AcceptsRansomDemandFrom(Target) or InFear then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Fear', Requester)
  else if not TrustsAttackRequester(Requester) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Suspect', Requester)
  else if HasLockedOrFollowOrder then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else AcceptRequest;
end;
{ @end $5140BC }

{ @routine $5145E4 TPirate_AcceptPartnershipOffer }
function TPirate.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  if BuildPartnershipOfferResponse(OtherShip, Response, PaymentAmount) then begin
    PartnershipDaysRemaining := 30 * CalculatePartnershipMonths(PaymentAmount, OtherShip);
    Response := FormatText2(LookupVisibleTalkText('Talk.Pirate.Ok', OtherShip), '<color=255,240,100>',
      '<Month>', IntToStr(CalculatePartnershipMonths(PaymentAmount, OtherShip)), '<Ranger>', (OtherShip as TRanger).Name);
    PartnerShip := OtherShip;
    OrderAbsolute := False;
    Result := True;
    SetMoney(Money + PaymentAmount);
    OtherShip.SetMoney(OtherShip.Money - PaymentAmount);
    if GetPlayer = OtherShip then GetPlayer.AchievementStats.CheckMasterAchievement;
  end else Result := False;
end;
{ @end $5145E4 }

{ @routine $5147D4 TPirate_BuildPartnershipOfferResponse }
function TPirate.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  if PartnerShip = OtherShip then begin Result := True; Exit; end;
  Result := False;
  if RelationToShip(OtherShip) < 45 then Response := LookupVisibleTalkText('Talk.Pirate.Suspect', OtherShip)
  else if PartnerShip <> nil then Response := FormatText1(LookupVisibleTalkText('Talk.Pirate.AlreadyHavePartner', OtherShip), '<color=255,240,100>', '<Partner>', (PartnerShip as TRanger).Name)
  else if ((OtherShip is TPlayer) and (TPlayer(OtherShip).GetMaxPiratePartners <= TPlayer(OtherShip).PiratePartners.Count)) or
    ((OwnerId = oiPirate) and (GetPlayer.PirateRank < PirateRank)) then Response := LookupVisibleTalkText('Talk.Pirate.NeedPirate', OtherShip)
  else if (OtherShip is TRanger) and (OtherShip.GetEffectiveSkillLevel(psLeadership) <= (OtherShip as TRanger).CountWingmen) then
    Response := LookupVisibleTalkText('Talk.Partner.NeedLeadership', OtherShip)
  else if CalculatePartnershipMonths(PaymentAmount, OtherShip) = 0 then Response := LookupVisibleTalkText('Talk.Pirate.SmallMoney', OtherShip)
  else Result := True;
  Response := FormatText1(Response, '<color=255,240,100>', '<Ranger>', (OtherShip as TRanger).Name);
end;
{ @end $5147D4 }

{ @routine $514C58 TPirate_ReviewPartnership }
procedure TPirate.ReviewPartnership;
var Leader: TShip; Longest, I: Integer;
  function CanNotifyPartner: Boolean; // @addr $514B78 @ida "unsigned __int8 __usercall $name@<al>(void *ParentFrame@<^0>);" @calls "0x514c7f 0x514d07 0x514dba 0x514e2d" @stackpop 0 @note "Nested in the partnership check; caller-popped static link."
  begin
    if (CurrentStar <> PartnerShip.CurrentStar) or not InNormalSpace or not PartnerShip.InNormalSpace then
      Result := False
    else if CanContactShip(PartnerShip) then
      Result := True
    else if not PartnerShip.NoTalk or (GetPlayer <> PartnerShip) then
      Result := False
    else
    begin
      PartnerShip.NoTalk := False;
      Result := CanContactShip(PartnerShip);
      PartnerShip.NoTalk := True;
    end;
  end;

begin
  if PartnerShip <> nil then
    if PartnershipDaysRemaining < 1 then begin
      if CanNotifyPartner then begin
        Leader := PartnerShip;
        if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
        GetPlayer.PiratePartners.Remove(Self);
        PartnerShip := nil;
        NotifyPiratePartnershipExpired(Leader);
      end;
    end else if RelationToShip(PartnerShip) < 30 then begin
      if CanNotifyPartner then begin
        Leader := PartnerShip;
        if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
        GetPlayer.PiratePartners.Remove(Self);
        PartnerShip := nil;
        NotifyPiratePartnerRelationBreak(Leader);
      end;
    end else if (EnemyShip <> nil) and (EnemyShip.PartnerShip <> nil) and (EnemyShip.PartnerShip = PartnerShip) then begin
      if CanNotifyPartner then begin
        Leader := PartnerShip;
        if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
        GetPlayer.PiratePartners.Remove(Self);
        PartnerShip := nil;
        NotifyPiratePartnerRebellion(Leader);
      end;
    end else if CanNotifyPartner then
      if GetPlayer.GetMaxDominionShips < GetPlayer.PiratePartners.Count then begin
        Longest := PartnershipDaysRemaining;
        for I := 0 to GetPlayer.PiratePartners.Count - 1 do
          if TShip(GetPlayer.PiratePartners[I]).PartnershipDaysRemaining > Longest then Longest := TShip(GetPlayer.PiratePartners[I]).PartnershipDaysRemaining;
        if Longest >= PartnershipDaysRemaining then begin
          Leader := PartnerShip;
          if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
          GetPlayer.PiratePartners.Remove(Self);
          PartnerShip := nil;
          NotifyPiratePartnerRatingBreak(Leader);
        end;
      end;
end;
{ @end $514C58 }

{ @routine $514F3C TPirate_MoveToRandomPlanetOrbit }
procedure TPirate.MoveToRandomPlanetOrbit;
var Planet: TPlanet; Polar: TPolarPoint;
begin
  Planet := CurrentStar.Planets[0];
  Polar := Planet.Orbit;
  Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $514F3C }

{ @routine $514FA4 TPirate_RefusesFactionNegotiation }
function TPirate.RefusesFactionNegotiation(OtherShip: TShip): Boolean;
begin
  Result := False;
  // The final Pointer cast preserves native operand loading after typing OtherShip.
  if (PirateType <> 0) and (OtherShip.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and
    ((CurrentStar.ControlFaction <> sfPirates) or (CurrentStar.Status.CustomFaction <> '') or
    (MainPiratePlanet = nil) or (MainPiratePlanet.OwnerId <> oiPirate) or (TShip(Pointer(OtherShip)).CurrentStar = MainPiratePlanet.CurrentStar)) then Result := True;
end;
{ @end $514FA4 }

{ @routine $515024 TPirate_TryRetreatFromSystem }
function TPirate.TryRetreatFromSystem: Boolean;
var I: Integer; Ship: TShip;
  DominatorAndCustomStrength, CoalitionStrength, PirateStrength, RetreatFactor, StrengthScale: Single;
  Star, PirateStar, AnyStar: TStar; Angle, PirateAngle, AnyAngle: Single;
  Station: TRuins; Urgent, PirateSystem, HostileSystem: Boolean;
begin
  Result := False;
  if CurrentStar.Constellation.Id = 20 then Exit;
  PirateSystem := (CurrentStar.ControlFaction = sfPirates) and (CurrentStar.Status.CustomFaction = '');
  HostileSystem := (CurrentStar.ControlFaction = sfDominators) or (CurrentStar.Status.CustomFaction <> '');
  Station := nil;
  if not PirateSystem then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship is TRuins) and (Ship.TypeId = Byte(rstDominion)) and (CurrentStar.Dominion <> Ship) and Ship.InNormalSpace and Ship.CanDock(Self) and
        ((TRuins(Ship).FlyToStar = nil) or (TRuins(Ship).FlyToStar = CurrentStar)) then begin Station := TRuins(Ship); Break; end;
    end;
  RetreatFactor := (100 + SeededRandomIntRange(-15, 15, Seed + Id)) * 0.02;
  if (EnemyShip = nil) or (EnemyShip.OrderTarget <> Self) or (EnemyShip.EstimateOrderTravelTurns > 2) then RetreatFactor := RetreatFactor * 0.5;
  if Station = nil then RetreatFactor := RemapClamped(RaidPressure, 0, 15, 1, 0.1) * RetreatFactor;
  if InFear and not PirateSystem then RetreatFactor := 1.4 * RetreatFactor;
  if (OwnerId = oiPirate) or (HostileSystem and (Station <> nil)) then begin
    if (OwnerId = oiPirate) and not PirateSystem then RetreatFactor := RetreatFactor * 0.25;
    DominatorAndCustomStrength := CurrentStar.GetCachedFactionStrength(sfDominators);
    CoalitionStrength := CurrentStar.GetCachedFactionStrength(sfCoalition);
    PirateStrength := CurrentStar.GetCachedFactionStrength(sfPirates);
    StrengthScale := 1 / Max(1, Galaxy.AverageRangerStrength);
    if TransitOriginStar <> nil then
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if (Ship.CurrentStanding in [ssPirateActive, ssPirateMilitary]) and (Ship.OrderTarget = CurrentStar) then
          PirateStrength := Min(10, Max(0.1, Ship.Strength * StrengthScale)) * 0.75 + PirateStrength;
      end;
    if (Abs(CoalitionStrength - 2.5 * DominatorAndCustomStrength) * RetreatFactor >= PirateStrength) or (HasNoUsableWeapons and not PirateSystem) then begin
      Urgent := InFear and (EnemyShip <> nil) and (EnemyShip.OrderTarget = Self) and (EnemyShip.EstimateOrderTravelTurns <= 2);
      if Order = soJump then begin
        if Urgent then UpdateAfterburnerState;
        Result := True;
        Exit;
      end else if Station <> nil then begin
        OrderLanding(Station, False);
        if Urgent or (Galaxy.CurrentTurn + EstimateOrderTravelTurns + 1 > Station.FlyDate) then UpdateAfterburnerState;
        Result := True;
        Exit;
      end else begin
        I := 1;
        PirateStar := nil;
        PirateAngle := 0;
        AnyStar := nil;
        AnyAngle := 0;
        while (Galaxy.Stars.Count > I) and (CurrentStar.StarDistances[I].Distance <= JumpRange) do begin
          Star := CurrentStar.StarDistances[I].Star;
          Inc(I);
          Angle := PointBearingDegrees(CurrentStar.Position, Star.Position) - PointBearingDegrees(MakeFloatPoint(0, 0), Position);
          Angle := WrapSignedHeadingDegrees(Angle);
          if (AnyStar = nil) or (Abs(Angle) < AnyAngle) then begin AnyStar := Star; AnyAngle := Abs(Angle); end;
          if (Star.ControlFaction = sfPirates) and (Star.Status.CustomFaction = '') and ((PirateStar = nil) or (Abs(Angle) < PirateAngle)) then begin
            PirateStar := Star;
            PirateAngle := Abs(Angle);
          end;
        end;
        if InFear and (2 * RetreatFactor * PirateStrength < Abs(CoalitionStrength - DominatorAndCustomStrength)) and
          (NextRandomIntRange(0, 9, RandomState) < 5) then PirateStar := AnyStar;
        if PirateStar <> nil then begin
          if OrderTarget <> PirateStar then OrderJump(PirateStar, False);
          Result := True;
          if Urgent then UpdateAfterburnerState;
        end;
      end;
    end;
  end;
end;
{ @end $515024 }

{ @routine $515688 TPirate_AdjustItemEvaluation }
function TPirate.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
const
  NoFlags = [];
var
  MoneyPenalty, EffectivenessScale, WeightPenalty, FragilityScale: Single;
  Price: Integer;
  DesiredFreeFraction, DesiredMoneyFraction, HullValueScale: Single;
begin
  case PirateType of
    0: begin FragilityScale := 1.2; HullValueScale := 1; end;
    1: begin FragilityScale := 0.8; HullValueScale := 2; end;
    2: begin FragilityScale := 1; HullValueScale := 1.5; end;
    3: begin FragilityScale := 1.2; HullValueScale := 0.5; end;
  else FragilityScale := 1; HullValueScale := 1;
  end;
  if Item.ItemType in [t_FuelTanks, t_Radar, t_Scaner] then FragilityScale := FragilityScale * 0.5;
  DesiredMoneyFraction := 0.1;
  DesiredFreeFraction := Max(0.01, Min(0.99, GetDesiredCargoFreeSpace / Max(100, GetHull.Weight)));
  MoneyPenalty := Sqr((1 / Max(0.01, SmoothedMoneyFraction) - 1) / (1 / DesiredMoneyFraction - 1)) /
    Max(SmoothedWealth * 0.05, 1000);
  EffectivenessScale := 2 / Max(10, SmoothedEquipmentEffectiveness);
  WeightPenalty := Sqr((1 / Max(0.01, SmoothedFreeCapacityFraction) - 1) / (1 / DesiredFreeFraction - 1)) /
    Max(10, GetHull.Weight * 0.1);
  MoneyPenalty := MoneyPenalty * 0.01 * (100 + SeededRandomIntRange(-25, 25, Id + Seed));
  EffectivenessScale := EffectivenessScale * 0.01 * (100 + SeededRandomIntRange(-25, 25, Seed + 3 * Id));
  WeightPenalty := WeightPenalty * 0.01 * (100 + SeededRandomIntRange(-25, 25, Seed + 5 * Id));
  case PriceMode of
    4: Price := Item.Cost;
    3: Price := Item.CalculateResaleValue(GetEffectiveSkillLevel(psTrading));
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
  if Item.ItemType <> t_Hull then
    Result := Effectiveness * EffectivenessScale * (1 + (2 - TEquipment(Item).GetFragilityFactor(NoFlags)) * FragilityScale) -
      Item.Weight * WeightPenalty - Price * MoneyPenalty
  else
    Result := (Item.Weight * HullValueScale / Max(0.01, TEquipment(Item).GetFragilityFactor(NoFlags)) + Effectiveness) * EffectivenessScale +
      Item.Weight * WeightPenalty - Price * 0.25 * MoneyPenalty;
end;
{ @end $515688 }

{ @routine $515C30 TPirate_EvaluateStatBonus }
function TPirate.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonHull: Result := Value * 150;
    bonFuel: Result := Value * 2;
    bonSpeed: Result := Value * 1.2;
    bonJump: Result := Value * 20;
    bonRadar: Result := Value * 0.05;
    bonScan: Result := Value * 10 + Value * 35 * CountWeaponsByDamageFlags(ScannerFlags);
    bonDroid: Result := Value * 10 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonHook: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.3;
    bonDef: Result := Value * 5 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonWEnergy: Result := Value * 12;
    bonWSplinter: Result := Value * 12;
    bonWMissile: Result := Value * 12 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonWRadius: Result := Value * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonHookRadius: Result := Value * 0.1;
    bonMass: Result := RemapClamped(Value + GetHull.Weight * 0.1, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 6000;
    bonSlotRadar:
      if (GetSlotCount(sskRadar) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[BonusKind] - PirateSlotBonusWeights[bonSlotWeapon] * CountMissileWeapons
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[BonusKind] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[BonusKind] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[BonusKind] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * PirateSlotBonusWeights[bonSlotWeapon]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[BonusKind] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[BonusKind] * -0.3;
    bonSlotHook:
      if (GetSlotCount(sskCargoHook) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[BonusKind] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskCargoHook) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[BonusKind] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[BonusKind] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(sskWeapon)) * PirateSlotBonusWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskWeapon)) * PirateSlotBonusWeights[BonusKind];
        if CountEquippedWeapons > Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - (PirateSlotBonusWeights[BonusKind] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(sskWeapon)));
      end;
    bonSlotArt:
      begin
        if (GetSlotCount(sskArtefact) < DefaultHullSlotCounts[sskArtefact]) and (Value > 0) then
          Result := Min(Value, DefaultHullSlotCounts[sskArtefact] - GetSlotCount(sskArtefact)) * PirateSlotBonusWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskArtefact)) * PirateSlotBonusWeights[BonusKind];
        if Artefacts <> nil then
          if Artefacts.Count > Max(Value + GetSlotCount(sskArtefact), 0) then Result := -1000;
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -PirateSlotBonusWeights[BonusKind];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), Value) * PirateSkillBonusWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) > 6) then
          Result := Result + (PirateSkillBonusWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), -Value) * -PirateSkillBonusWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) < 0) then
          Result := Result + (PirateSkillBonusWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]));
      end;
  else Result := 0;
  end;
  if (PirateType = 0) and (BonusKind in [bonSlotForsage, bonMass]) then Result := Result * 1.3;
  if (PirateType = 0) and (BonusKind in [bonSpeed]) then Result := Result * 1.2 * Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed);
  if (PirateType = 1) and (BonusKind in [bonHull, bonSpeed, bonDroid, bonDef..bonWMissile]) then Result := Result * 1.3;
  if (PirateType = 2) and (BonusKind in [bonScan, bonWEnergy..bonWRadius]) then Result := Result * 1.3;
  if (PirateType = 3) and (BonusKind in [bonSpeed, bonRadar, bonDroid, bonWRadius, bonMass]) then Result := Result * 1.3;
  if (PirateType = 3) and (BonusKind in [bonWEnergy..bonWMissile]) then Result := Result * 0.7;
  if BonusKind in [bonSkill1..bonSkill6] then Result := Result * 0.01 * (100 + SeededRandomIntRange(-75, 75, Seed + 131 * Ord(BonusKind))) * RaceSkillEvaluationFactors[PilotRace, EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]]
  else Result := Result * 0.01 * (100 + SeededRandomIntRange(-25, 25, Seed + 131 * Ord(BonusKind)));
end;
{ @end $515C30 }

{ @routine $516AD0 TPirate_EvaluateWeaponDamage }
function TPirate.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  ShockFlags = [dkShock];
  AcidFlags = [dkAcid];
  DisablingFlags = [dkDecelerate, dkDestruct, dkMagnetic];
var
  ScannerFactor, StatusFactor: Single;
  Flags: TDamageFlagSet;
  SlowFactor, DisruptionFactor, TotalDisruption, SpeedFactor: Single;
  I, ShotTotal: Integer;
begin
  Flags := Weapon.GetDamageFlags;
  if (Flags * ScannerFlags <> []) and (GetScanner <> nil) and (GetRadar <> nil) then
    ScannerFactor := RemapClamped(GetScannerPower - DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(Galaxy.TechLevel)) + 1, -5, 10, 0.1, 2)
  else ScannerFactor := 0;
  Result := BaseDamage * GetWeaponArtefactDamageFactor(Weapon);
  if dkDrain in Flags then
    case PirateType of 1: Result := Result * 1.7; else Result := Result * 1.5; end;
  if dkShock in Flags then
    case PirateType of 2: Result := Result * (1.3 + CountWeaponsByDamageFlags(ShockFlags) * 0.15);
    else Result := Result * (1.2 + CountWeaponsByDamageFlags(ShockFlags) * 0.05); end;
  if dkMagnetic in Flags then
    case PirateType of
      2: Result := Result * 1.8;
      3: Result := Result * 3;
    else Result := Result * 1.4;
    end;
  if dkDestruct in Flags then SlowFactor := 1 else SlowFactor := 0;
  if dkReduceEngine in Flags then SlowFactor := 1 + 2 * SlowFactor;
  DisruptionFactor := 0;
  if dkDecelerate in Flags then DisruptionFactor := DisruptionFactor + 1;
  if (CountActiveArtefacts(Ord(t_ArtDecelerate)) > 0) and (dkSplinter in Flags) then
    DisruptionFactor := DisruptionFactor + CountActiveArtefacts(Ord(t_ArtDecelerate)) * ((Ord(CanBoostArtefact(Ord(t_ArtDecelerate), Weapon, False)) * 1) + 1);
  TotalDisruption := DisruptionFactor;
  for I := 1 to CountEquippedWeapons do begin
    if dkDecelerate in Weapons[I].GetDamageFlags then TotalDisruption := TotalDisruption + 1;
    if (CountActiveArtefacts(Ord(t_ArtDecelerate)) > 0) and (dkSplinter in Weapons[I].GetDamageFlags) then
      // The native loop tests each equipped weapon but boosts the candidate.
      TotalDisruption := TotalDisruption + CountActiveArtefacts(Ord(t_ArtDecelerate)) * ((Ord(CanBoostArtefact(Ord(t_ArtDecelerate), Weapon, False)) * 1) + 1);
  end;
  DisruptionFactor := DisruptionFactor / Max(TotalDisruption, 1) * RemapClamped(TotalDisruption, 1, 3, 1, 2);
  if SlowFactor > 0.01 then
    case PirateType of
      2: Result := Result * (1 + SlowFactor * 0.1);
      3: Result := Result * (1 + SlowFactor * 0.5);
    else Result := Result * (1 + SlowFactor * 0.05);
    end;
  StatusFactor := 1;
  if dkScanBonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkBonusToDamaged in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.2);
  StatusFactor := StatusFactor - 1;
  if PirateType = 3 then Result := (300 + Result) * 0.5;
  if IncludeAdditiveBonuses then
  begin
    if DisruptionFactor > 0.01 then
      case PirateType of
        2: Result := Result + 5 * DisruptionFactor;
        3: Result := Result + 50 * DisruptionFactor;
      else Result := Result + 10 * DisruptionFactor;
      end;
    if SlowFactor > 0.01 then
      case PirateType of
        2: Result := Result + 2 * SlowFactor;
        3: Result := Result + 10 * SlowFactor;
      else Result := Result + 1 * SlowFactor;
      end;
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if dkAcid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      case PirateType of 1: Result := Result + ShotTotal * 5; else Result := Result + ShotTotal * 3; end;
    end;
    if dkMoreDrop in Flags then Result := Result + ScannerFactor * 15;
    if dkDropCargo in Flags then Result := Result + ScannerFactor * 15;
    if dkBlockWeapon in Flags then Result := Result + ScannerFactor * 5;
    if dkDroidBlock in Flags then Result := Result + ScannerFactor * 5;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case Weapon.GetWeaponInfo.ShotType of
    wstRocket: Result := Result * 0.9 * Weapon.GetShotCount * (1 + StatusFactor);
    wstMissile: Result := Result * (0.9 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    wstTorpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor);
    wstChain: Result := Result * (1.3 + (Weapon.GetShotCount - 1) * 0.1) * (1 + StatusFactor);
    wstSplash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.4 * 0.01 * SpeedFactor + StatusFactor);
    wstAreaDamage: Result := Result * (1 + Weapon.Range * 0.3 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
  if (PirateType = 3) and (Flags * DisablingFlags <> []) and (CountWeaponsByDamageFlags(Flags * DisablingFlags) = 0) then Result := Result * 4
  else if dkMissile in Flags then Result := Result * 1.2;
end;
{ @end $516AD0 }

{ @routine $517418 TPirate_AcceptPickupItem }
function TPirate.AcceptPickupItem(Item: TItem): Boolean;
begin Result := True; end;
{ @end $517418 }

{ @routine $517430 TPirate_AcceptPickupDistance }
function TPirate.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  if Speed < 1 then begin Result := False; Exit; end;
  Result := (Item.ItemType in [t_Technics, t_Luxury, t_Alcohol..t_Narcotics]) or (2 * Speed >= Distance) or
    (Item.Cost >= RemapClamped(Distance / Speed, 1, 10, 0.01, 0.05) * Wealth);
end;
{ @end $517430 }

{ @routine $5174E4 TPirate_RefreshCurrentStanding }
procedure TPirate.RefreshCurrentStanding;
var Owner: TOwnerId; StandingMode: Integer;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then begin
    if (GetPlayer <> nil) and (GetPlayer = PartnerShip) then Owner := GetPlayer.OwnerId else Owner := OwnerId;
    if IsInPrison or ((PirateType = 0) and (Owner <> oiPirate)) then CurrentStanding := ssNeutral
    else if (Owner = oiPirate) and (PirateType <> 0) then CurrentStanding := ssPirateMilitary
    else if (Owner = oiPirate) and ((CurrentSystemKills.Normal > 0) or (CurrentStar.ControlFaction = sfPirates)) then CurrentStanding := ssPirateActive
    else CurrentStanding := ssPiratePassive;
  end;
end;
{ @end $5174E4 }

end.
