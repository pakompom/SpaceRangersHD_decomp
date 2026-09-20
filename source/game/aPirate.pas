unit aPirate;
// Unit bracket (inferred): .text 0x005AB398..0x005B5EA6; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, aConst, EC_Buf, aItem, aShip, aGalaxy, aGalaxyStruct, aNormalShip, aPlanet;

type
  TPirate = class(TNormalShip) // @size 0x51C
  public
    PrisonTermRemaining: Cardinal; // @offset 0x510
    PirateType: Byte; // @offset 0x514  Zero denotes an independent pirate; nonzero values select clan variants.
    RaidPressure: Single; // @offset 0x518  AI pressure affecting target selection and departure decisions.

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $005ABECC @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $005ABF1C @slot $04
    procedure AssignWeaponTargetsInStar; override; // @addr $005AFD24 @slot $20
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr $005B3F68 @slot $50 @ida "float __userpurge $name@<st0>(TPirate *Self@<eax>, TItem *Item@<edx>, unsigned __int8 PriceMode@<cl>, float Effectiveness@<^0>);"
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $005B4510 @slot $54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr $005B53B0 @slot $58 @ida "float __userpurge $name@<st0>(TPirate *Self@<eax>, TWeapon *Weapon@<edx>, bool IncludeAdditiveBonuses@<cl>, float BaseDamage@<^0>);"
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $005AD9E0 @slot $60
    procedure BuildReachablePlanetQueue; override; // @addr $005AD0D8 @slot $64
    procedure SelectEnemyShipInStar; override; // @addr $005B0550 @slot $6C
    procedure EngageEnemyShip; override; // @addr $005B112C @slot $70
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $005AEA80 @slot $74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $005AEB24 @slot $78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $005AEC94 @slot $7C
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $005AE64C @slot $80
    function RecomputeFearState: Boolean; override; // @addr $005AEE90 @slot $84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $005AF64C @slot $88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $005AF71C @slot $8C
    function EvaluateAllyRelationAndStrength(Ship: TShip): Boolean; override; // @addr $005AF740 @slot $90
    function AcceptPickupItem(Item: TItem): Boolean; override; // @addr $005B5CF8 @slot $94
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; override; // @addr $005B5D10 @slot $98 @ida "bool __userpurge $name@<al>(TPirate *Self@<eax>, TItem *Item@<edx>, double Distance@<^0>);"
    procedure ProcessCombatDialogue; override; // @addr $005B1328 @slot $A0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $005B147C @slot $A4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $005B1664 @slot $A8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $005B1D44 @slot $AC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $005B228C @slot $B0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $005B2950 @slot $B4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $005B2E78 @slot $B8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $005B3068 @slot $BC
    function UnknownVirtualC0(Argument: Pointer): Boolean; override; // @addr $005B3884 @slot $C0
    procedure RefreshCurrentStanding; override; // @addr $005B5DC4 @slot $C4
    destructor Destroy; override; // @addr $5AB4BC @ida "void __usercall $name(TPirate *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function NavigateToServicePlanet(Absolute: Boolean): Boolean; // @addr $5ACF54
    function SelectServicePlanet: TPlanet; // @addr $5AD018
    procedure TryJumpToNearbyBattle(UnusedMode: Byte); // @addr $5AD2C8 The native entry stores but never reads dl; the sole caller passes zero.
    function TryDockAtStation(Types: TShipTypeMask): Boolean; // @addr $5AD3D4
    procedure MoveToRandomPlanetOrbit; // @addr $5B381C

    procedure TryOfferRansomToPursuer; // @addr $5AF2E4
    function ProcessImprisonment: Boolean; // @addr $5AFB84 True while the current turn is spent in prison.
    procedure ProcessUnseenProgression; // @addr $5ADFB4

    procedure ReviewPartnership; // @addr $5B340C
    procedure SelectIncidentalEnemy; // @addr $5B0C8C
    function TryRetreatFromSystem: Boolean; // @addr $5B3904

    procedure InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: Byte); // @addr 0x5AB820 @note "Sets location, money and PirateType; registers the ship with its star."

    procedure NextDay; override; // @addr 0x5ABFAC @slot 0x18
    procedure NextDayLogic; override; // @addr 0x5AC1CC @slot 0x1C @calls "0x5AC04B"
    function GetGreetingShipCategory: Byte; override; // @addr $5ADE68 @slot $30
    function GetHomeStar: TStar; override; // @addr $5ADC80 @slot $34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $5ADEA0 @slot $3C
    function GetDominantCareer: TRangerCareer; override; // @addr 0x5ADE8C @slot 0x38 @note "Always rcPirate."
    function GetName: WideString; override; // @addr 0x5ADC9C @slot 0x24 @ida "void __usercall $name(TPirate *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x5ADCBC @slot 0x28 @ida "void __usercall $name(TPirate *Self@<eax>, unsigned __int16 *Separator@<edx>, unsigned __int16 **Result@<ecx>);"

    procedure SelectNearestReachableDestination; // @addr $5AD468 Prefers the leader's route, then nearby service locations or reachable non-Dominator stars.
    procedure SellAllCargoGoods; // @addr 0x5AD99C
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x5ADEB4 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x5ADF84 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x5AD288 @slot 0x68 @note "AI ownership check only; does not test travel range."
  end;

const
  // Entries 22..27 of the $5B4546 dispatch table enter $5B4F42. These reads reload
  // the unchanged BonusKind byte at EBP-5; $87AAB4 is the base biased by -22*4.
  PirateSkillBonusWeights: array[22..27] of Integer = (90, 90, 90, 90, 30, 5); // @addr $87AB0C @indexrefs "$5B4F98,$5B5012,$5B507D,$5B50F5"
  // EvaluateStatBonus dispatch bounds the indexed BonusKind to 13..20.
  PirateSlotBonusWeights: array[13..20] of Integer = (100, 150, 150, 400, 150, 100, 20, 100); // @addr $87AB24 @indexrefs "$005B491E,$005B495E,$005B499E,$005B49CF,$005B4A2B,$005B4A6B,$005B4A9C,$005B4ACB,$005B4B09,$005B4B3A,$005B4B69,$005B4BA7,$005B4BD8,$005B4C07,$005B4C45,$005B4CA1,$005B4CEB,$005B4D82,$005B4DFC,$005B4E58,$005B4EF4,$005B4F24"

implementation

uses aPlayer, Achievements, aGalaxyEvent, aAsteroid, aMissile, aScript, aRuins, EC_Struct, Classes, Math, Windows, SysUtils, aRanger, aTranclucator, GR_Main, Globals, GlobalsV, EC_Str, aItem, aGalaxy, aShip, aConst, aMyFunction;

{ @routine $5AB4BC TPirate_Destroy }
destructor TPirate.Destroy;
begin
  if OwnerId = Byte(oiPirate) then Dec(Galaxy.PirateClanCount) else Dec(Galaxy.PirateCount);
  inherited;
end;
{ @end $5AB4BC }

{ @routine $5AB820 TPirate_InitGenerated }
procedure TPirate.InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: Byte);
var I: Integer; Ranger: TRanger; HasHull: Boolean;
  // @nested $5AB50C SelectUniqueName
  procedure SelectUniqueName(Config: TBlockParEC); // @addr $5AB50C @ida "void __usercall $name(TBlockParEC *Config@<eax>, void *ParentFrame@<^0>);" @note "Nested helper with caller-popped static link."
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
  if HasHull or (Planet.OwnerId = Byte(oiPirate)) then Inc(Galaxy.PirateClanCount) else Inc(Galaxy.PirateCount);
  HomePlanet := Planet;
  if not HasHull then CurrentPlanet := HomePlanet;
  CurrentStar := HomePlanet.CurrentStar;
  CurrentStar.Ships.Add(Self);
  if HasHull then begin
    OwnerId := Byte(oiPirate);
    if GetHull.OwnerId in TOwnerMask(PlanetOwnerMasks.Coalition) then PilotRace := OwnerToRace(GetHull.OwnerId)
    else if HomePlanet.IsMainPiratePlanet then PilotRace := OwnerToRace(PickRandomEquipmentOwner(HomePlanet.RandomState))
    else PilotRace := HomePlanet.RaceId;
  end else begin
    if HomePlanet.IsMainPiratePlanet then PilotRace := OwnerToRace(PickRandomEquipmentOwner(HomePlanet.RandomState))
    else PilotRace := HomePlanet.RaceId;
    if HomePlanet.OwnerId = Byte(oiPirate) then OwnerId := Byte(oiPirate) else OwnerId := RaceToOwner(PilotRace);
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
    if OwnerId = Byte(oiPirate) then begin
      PirateRank := NextRandomIntRange(0, GetPlayer.PirateRank, RandomState);
      if PirateRank > 3 then PirateRank := 3;
      AddPirateRankPoints(NextRandomIntRange(0, PirateRankPointThresholds[PirateRank] div 2, RandomState));
    end;
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  if not HasHull then begin
    if OwnerId = Byte(oiPirate) then CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), 1, RaceToOwner(PilotRace), SelectRandomHullSeries, True)
    else CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), 1, OwnerId, SelectRandomHullSeries, False);
    CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
    CreateAndEquipEngine(Round(EquipmentSizeFactors[NextRandomIntRange(1, 2, RandomState)] * EngineBaseSize), NextRandomIntRange(1, 2, RandomState), OwnerId);
    if GetSlotCountForItemType(Ord(t_CargoHook)) > 0 then CreateAndEquipCargoHook(CargoHookBaseSize, NextRandomIntRange(1, 2, RandomState), OwnerId);
    if GetSlotCount(sskWeapon) > WeaponCount then CreateAndEquipWeapon(Ord(t_Weapon1), WeaponInfos[Ord(t_Weapon1)].AverageSize, 1, OwnerId);
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
{ @end $5AB820 }

{ @routine $5ABECC TPirate_SaveToBuffer }
procedure TPirate.SaveToBuffer(Buffer: TBufEC);
begin
  inherited;
  Buffer.AddDWord(PrisonTermRemaining);
  Buffer.AddAnsiChar(AnsiChar(PirateType));
  Buffer.AddSingle(RaidPressure);
end;
{ @end $5ABECC }

{ @routine $5ABF1C TPirate_LoadFromBuffer }
procedure TPirate.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited;
  if LoadedSaveVersion >= 60 then PrisonTermRemaining := Buffer.GetUInt32 else PrisonTermRemaining := Buffer.GetByte;
  PirateType := Buffer.GetByte;
  if LoadedSaveVersion >= 79 then RaidPressure := Buffer.GetSingle else RaidPressure := 0;
end;
{ @end $5ABF1C }

{ @routine $5ABFAC TPirate_NextDay }
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
{ @end $5ABFAC }

{ @routine $5AC1CC TPirate_NextDayLogic }
procedure TPirate.NextDayLogic;
var Planet: TPlanet; Station, Ship: TShip; Stage: Integer; ClanShip, Collecting: Boolean; I, Count: Integer;
begin
  Stage := 0;
  try
    ClanShip := (PirateType <> 0) and (OwnerId = Byte(oiPirate));
    if CurrentPlanet <> nil then begin
      Stage := 1;
      if not (CurrentPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) or (ClanShip and not (CurrentPlanet.OwnerId in TOwnerMask(PlanetOwnerMasks.PirateClan))) then begin OrderTakeoff; Exit; end;
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
              Station := FindNearestDockableStation(TStationStandingMask(NonTargetableStationStandingMasks[Ord(sfPirates)]));
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
          Station := FindNearestDockableStation(TStationStandingMask(NonTargetableStationStandingMasks[Ord(sfPirates)]));
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
          if not Ship.InHyperspace and (Ship is TPirate) and (Ship.OwnerId = Byte(oiPirate)) and (Ship.PartnerShip = nil) and
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
{ @end $5AC1CC }

{ @routine $5ACF54 TPirate_NavigateToServicePlanet }
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
{ @end $5ACF54 }

{ @routine $5AD018 TPirate_SelectServicePlanet }
function TPirate.SelectServicePlanet: TPlanet;
begin
  if PlanetQueue.Count > 0 then begin
    Result := TList(Integer(PlanetQueue) + 0)[0];
    if (GetFuelTanks.Fuel < GetFuelTanks.Capacity) or HasHullDamageOrBrokenEquippedItems or (NextRandomUnitFloat(RandomState) < 0.1) then Exit;
    Result := PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)];
  end else Result := nil;
end;
{ @end $5AD018 }

{ @routine $5AD0D8 TPirate_BuildReachablePlanetQueue }
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
          if (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and CanQueueReachablePlanet(Planet) then PlanetQueue.Add(Planet);
        end;
      end;
    end;
end;
{ @end $5AD0D8 }

{ @routine $5AD288 TPirate_CanQueueReachablePlanet }
function TPirate.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := (Planet.OwnerId <> Byte(oiDominator)) and ((PirateType = 0) or (Planet.OwnerId = OwnerId));
end;
{ @end $5AD288 }

{ @routine $5AD2C8 TPirate_TryJumpToNearbyBattle }
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
{ @end $5AD2C8 }

{ @routine $5AD3D4 TPirate_TryDockAtStation }
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
{ @end $5AD3D4 }

{ @routine $5AD468 TPirate_SelectNearestReachableDestination }
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
    if CanQueueReachablePlanet(Planet) and (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then begin
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
{ @end $5AD468 }

{ @routine $5AD99C TPirate_SellAllCargoGoods }
procedure TPirate.SellAllCargoGoods;
var
  Good: Byte;
begin
  for Good := 0 to 7 do
    if CargoGoods[Good].Count > 0 then SellGoodsToLocation(Good, CargoGoods[Good].Count);
end;
{ @end $5AD99C }

{ @routine $5AD9E0 TPirate_RepairBrokenEquipmentAtLocation }
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
{ @end $5AD9E0 }

{ @routine $5ADC80 TPirate_GetHomeStar }
function TPirate.GetHomeStar: TStar;
begin
  Result := HomePlanet.CurrentStar;
end;
{ @end $5ADC80 }

{ @routine $5ADC9C TPirate_GetName }
function TPirate.GetName: WideString;
begin
  Result := Name;
end;
{ @end $5ADC9C }

{ @routine $5ADCBC TPirate_GetFullName }
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
{ @end $5ADCBC }

{ @routine $5ADE68 TPirate_GetGreetingShipCategory }
function TPirate.GetGreetingShipCategory: Byte;
begin
  if OwnerId = Byte(oiPirate) then Result := gscPirateClan else Result := gscPirate;
end;
{ @end $5ADE68 }

{ @routine $5ADE8C TPirate_GetDominantCareer }
function TPirate.GetDominantCareer: TRangerCareer;
begin
  Result := rcPirate;
end;
{ @end $5ADE8C }

{ @routine $5ADEA0 TPirate_GetStrengthScaledPirateStatus }
function TPirate.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 50;
end;
{ @end $5ADEA0 }

{ @routine $5ADEB4 TPirate_GetDesiredCargoFreeSpace }
function TPirate.GetDesiredCargoFreeSpace: Integer;
begin
  if PirateType <> 0 then
    Result := Trunc(RemapClamped(GetHull.Weight, HullBaseSize * EquipmentSizeFactors[5], HullBaseSize * EquipmentSizeFactors[1], 10, 50))
  else
    Result := Trunc(RemapClamped(GetHull.Weight, HullBaseSize * EquipmentSizeFactors[5], HullBaseSize * EquipmentSizeFactors[1], 30, 150));
end;
{ @end $5ADEB4 }

{ @routine $5ADF84 TPirate_RefuelAtLocation }
procedure TPirate.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $5ADF84 }

{ @routine $5ADFB4 TPirate_ProcessUnseenProgression }
procedure TPirate.ProcessUnseenProgression;
var Award: Byte; ProgressFactor, StrengthFactor: Double;
begin
  if (DaysSincePlayerSeen >= 60) and (GetPlayer <> nil) then
    if (OwnerId = Byte(oiPirate)) and (PirateType <> 0) then begin
      ProgressFactor := ShortInt(Galaxy.DifficultyLevels[0] + Byte(0)) * 0.2 + 0.6;
      ProgressFactor := RemapClamped(Galaxy.WarDeltaWin[2], -10, 10, 1.3, 0.7) * ProgressFactor;
      StrengthFactor := ShortInt(Galaxy.DifficultyLevels[0] + Byte(0)) * 0.1 + 0.6;
      if (0.1 * ProgressFactor > NextRandomUnitFloat(RandomState)) and
        ((0.4 * StrengthFactor > StrengthInBestRanger) or (NextRandomUnitFloat(RandomState) < 0.1)) then
        if (NextRandomFloatRange(0, 0.7, RandomState) > WealthInBestRanger) and (Money < 25000) then
          SetMoney(Money + Galaxy.ComputeScaledBigMoney(2))
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
          SetMoney(Money + Galaxy.ComputeScaledBigMoney(2))
        else ImproveRandomEquipment(True);
      if (NextRandomUnitFloat(RandomState) < 0.05) and ((StrengthInBestRanger < 0.5) or (StrengthInAverageRanger < 1) or
        (NextRandomUnitFloat(RandomState) < 0.001)) then GenerateExtraWeapon;
      if NextRandomUnitFloat(RandomState) < 0.2 then GainExperience(NextRandomIntRange(250, 1000, RandomState), 0);
      if (OwnerId = Byte(oiPirate)) and (GetPlayer.PirateRank > PirateRank) and (NextRandomUnitFloat(RandomState) < 0.01) and (PirateRank < 4) then begin
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
{ @end $5ADFB4 }

{ @routine $5AE64C TPirate_RelationToNonRanger }
function TPirate.RelationToNonRanger(Ship: TShip): Byte;
begin
  if CurrentStanding = ssPirateMilitary then
    case Ship.TypeId of
      stTransport: if (CurrentStar.ControlFaction = sfCoalition) and (CurrentStar.Status.CustomFaction = '') and
        (CurrentStar = Ship.CurrentStar) and (TruceShip <> Ship) and (Ship.TruceShip <> Self) and
        not IsHullDestroyed and not AcceptsRansomDemandFrom(Ship) then Result := 0
        else Result := Min(50, Max(20, OwnerRelations[OwnerId, Ship.OwnerId] - 20));
      stPirate: if Ship.OwnerId = Byte(oiPirate) then Result := Min(100, 100 + SeededRandomIntRange(-20, 20, Seed + Ship.Seed))
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
      Ord(rstRangerCenter)..Ord(rstCustomStation): if (Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and (OwnerId = Byte(oiPirate)) then Result := 30 else Result := 100;
    else Result := 50;
    end;
  end;
end;
{ @end $5AE64C }

{ @routine $5AEA80 TPirate_RelationToRanger }
function TPirate.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := Byte(RangerRelations[Galaxy.Rangers.IndexOf(Ranger)]);
  if PirateType <> 0 then
    if (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = Byte(oiPirate)) then
      Result := Min(Result, MainPiratePlanet.RelationToRanger(Galaxy.Rangers.IndexOf(Ranger)))
    else Result := 0;
end;
{ @end $5AEA80 }

{ @routine $5AEB24 TPirate_ChangeRelationToRanger }
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
{ @end $5AEB24 }

{ @routine $5AEC94 TPirate_ReactToAttack }
procedure TPirate.ReactToAttack(Attacker: TShip);
var Index, Value: Integer;
begin
  if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and
    (TTranclucator(Attacker).OwnerShip.TypeId = stRanger) then ReactToAttack(TTranclucator(Attacker).OwnerShip);
  EnemyShip := Attacker;
  if Attacker is TRanger then begin
    ChangeRelationToRanger(Attacker, -10);
    if (CurrentStanding in [ssPirateActive, ssPirateMilitary]) and (Attacker.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and
      (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = Byte(oiPirate)) then begin
      Index := Galaxy.Rangers.IndexOf(Attacker);
      Value := Max(0, Integer(MainPiratePlanet.RangerRelations[Index]) - 3);
      MainPiratePlanet.RangerRelations[Index] := Pointer(Value);
    end;
  end;
  if Attacker.PartnerShip <> nil then
    if Attacker.PartnerShip.TypeId = stRanger then begin
      ChangeRelationToRanger(Attacker.PartnerShip, -5);
      if (CurrentStanding in [ssPirateActive, ssPirateMilitary]) and (Attacker.PartnerShip.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and
        (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = Byte(oiPirate)) then begin
        Index := Galaxy.Rangers.IndexOf(Attacker.PartnerShip);
        Value := Max(0, Integer(MainPiratePlanet.RangerRelations[Index]) - 1);
      MainPiratePlanet.RangerRelations[Index] := Pointer(Value);
      end;
    end;
end;
{ @end $5AEC94 }

{ @routine $5AEE90 TPirate_RecomputeFearState }
function TPirate.RecomputeFearState: Boolean;
var Ship: TShip; I, EnemyCount: Integer; Tolerance, Threat: Double;
begin
  if HasNoUsableWeapons and (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then begin
    Result := True;
    InFear := True;
    Exit;
  end;
  if (OwnerId = Byte(oiPirate)) and (PirateType <> 0) then
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
{ @end $5AEE90 }

{ @routine $5AF2E4 TPirate_TryOfferRansomToPursuer }
procedure TPirate.TryOfferRansomToPursuer;
var Response: WideString; Amount: Integer; LowOffer, HighOffer: Single; Accepted: Boolean; Ship: TShip;
begin
  if InNormalSpace and (EnemyShip <> nil) and (EnemyShip.OrderTarget = Self) and (EnemyShip.TruceShip <> Self) and
    (Money > 100) and not CanEscapePursuer(EnemyShip) and not (EnemyShip.TypeId in NonNegotiatingShipTypes) and
    not NoTalk and not EnemyShip.NoTalk and ((OwnerId <> Byte(oiPirate)) or (PirateType = 0) or not (EnemyShip.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive])) then
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
{ @end $5AF2E4 }

{ @routine $5AF64C TPirate_AcceptsRansomDemandFrom }
function TPirate.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := (GetHull.Weight * 0.6 * OwnerInfo[OwnerId].FearThresholdScale > GetHull.HullPoints) and
    (OwnerInfo[OwnerId].FearThresholdScale / 2 > ChanceToWin(Ship) * (1 + RaidPressure));
  if Result and (EnemyShip = Ship) then RaidPressure := 0;
end;
{ @end $5AF64C }

{ @routine $5AF71C TPirate_TrustsAttackRequester }
function TPirate.TrustsAttackRequester(Ship: TShip): Boolean;
begin Result := RelationToShip(Ship) >= 30; end;
{ @end $5AF71C }

{ @routine $5AF740 TPirate_EvaluateAllyRelationAndStrength }
function TPirate.EvaluateAllyRelationAndStrength(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) +
    RemapClamped(Ship.Strength, 0.9 * Strength, Strength * 3, 0, 100) > 130;
end;
{ @end $5AF740 }

{ @routine $5AFB84 TPirate_ProcessImprisonment }
function TPirate.ProcessImprisonment: Boolean;
var I: Integer; Ship: TShip;
  // @nested $5AF7DC Imprison
  procedure Imprison; // @addr $5AF7DC @ida "void __usercall $name(void *ParentFrame@<^0>);" @note "Nested helper; caller-popped static link."
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
    if ((CurrentStar.Battle <> 0) and (CurrentStar.LastDominatorPresenceTurn >= Galaxy.CurrentTurn - 1)) or (CurrentPlanet.OwnerId = Byte(oiPirate)) then begin
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
  end else if (CurrentPlanet.OwnerId <> Byte(oiPirate)) and ((CurrentStar.Battle = 0) or (CurrentStar.LastDominatorPresenceTurn < Galaxy.CurrentTurn - 1)) then begin
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
{ @end $5AFB84 }

{ @routine $5AFD24 TPirate_AssignWeaponTargetsInStar }
procedure TPirate.AssignWeaponTargetsInStar;
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Item: TItem; Asteroid: TAsteroid; Distance: Single; Missile: TMissile;
begin
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; end;
  Assigned := 0;
  if CurrentStar.Battle <> 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship.OwnerId = Byte(oiDominator)) and Ship.InNormalSpace then
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
      if ((Item.ItemType = t_Minerals) or not (Byte(Item.ItemType) in [Ord(t_Food)..Ord(t_Narcotics)])) and
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
{ @end $5AFD24 }

{ @routine $5B0550 TPirate_SelectEnemyShipInStar }
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
          ((Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and ((OwnerId <> Byte(oiPirate)) or (CurrentStar.Battle = 0) or (Ship.CurrentStanding in [ssNeutral..ssPirateMilitary]))) or (Ship.TypeId = stTranclucator) then Continue;
        if (CurrentStar.ControlFaction = sfDominators) or (CurrentStar.Status.CustomFaction <> '') or
          ((CurrentStar.ControlFaction = sfPirates) and (OwnerId = Byte(oiPirate)) and (Galaxy.CoalitionDefeatedTurn = 0)) then begin
          if not (Ship is TNormalShip) or ((OwnerId = Byte(oiPirate)) and (Ship.OwnerId <> Byte(oiPirate))) then begin
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
{ @end $5B0550 }

{ @routine $5B0C8C TPirate_SelectIncidentalEnemy }
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
      ((not (Ship is TPirate) and (GetPlayer <> Ship) and ((Ship.OwnerId <> Byte(oiPirate)) or not (Ship is TNormalShip))) or
      (((Ship.OwnerId <> Byte(oiPirate)) or (Ship.PilotRace <> PilotRace) or (NextRandomIntRange(1, 100, RandomState) <= 50)) and
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
{ @end $5B0C8C }

{ @routine $5B112C TPirate_EngageEnemyShip }
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
{ @end $5B112C }

{ @routine $5B1328 TPirate_ProcessCombatDialogue }
procedure TPirate.ProcessCombatDialogue;
begin
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 5 = 0) and
    not AcceptsRansomDemandFrom(EnemyShip) then TryExtortShip(EnemyShip);
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 4 = 0) and
    (((ChanceToWin(EnemyShip) < 1.1) and (GetHullIntegrityPercent > 30)) or
    ((OwnerId = Byte(oiPirate)) and (CurrentStar.ControlFaction = sfPirates) and (CurrentStar.Status.CustomFaction = '') and (ChanceToWin(EnemyShip) < 2))) then
    RequestAlliesAttackShip(EnemyShip);
end;
{ @end $5B1328 }

{ @routine $5B147C TPirate_ReactToExtortionDemand }
procedure TPirate.ReactToExtortionDemand(Ranger: Pointer);
begin
  if (GetPlayer = Ranger) or (NextRandomUnitFloat(RandomState) < 0.05) then begin
    ChangeRelationToRanger(Ranger, -15);
    HomePlanet.ChangeRelationToRanger(Ranger, -1);
    (TObject(Ranger) as TRanger).AddPirateCareerActivity(1);
  end;
end;
{ @end $5B147C }

{ @routine $5B1664 TPirate_BuildMoneyExtortionResponse }
function TPirate.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $5B14F8 PayDemand
  procedure PayDemand; // @addr $5B14F8 @ida "void __usercall $name(void *ParentFrame@<^0>);" @note "Nested helper with caller-popped static link."
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
      Event.AddData(OwnerId);
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
  else if UnknownVirtualC0(OtherShip) or not AcceptsRansomDemandFrom(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'No', OtherShip)
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
{ @end $5B1664 }

{ @routine $5B1D44 TPirate_BuildCargoExtortionResponse }
function TPirate.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
var Forced: Boolean; NextDemandTurn: Integer;
  // @nested $5B1AAC DropDemand
  procedure DropDemand; // @addr $5B1AAC @ida "void __usercall $name(void *ParentFrame@<^0>);" @note "Nested helper with caller-popped static link."
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
      Event.AddData(OwnerId);
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
  else if UnknownVirtualC0(OtherShip) or not (AcceptsRansomDemandFrom(OtherShip) or Forced) then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) and not Forced then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if not HasCargoGoods then Response := LookupVisibleTalkText('Talk.Goods.AnswerNotGoods', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'Ok', OtherShip);
    DropDemand;
    if GetPlayer = OtherShip then PlayerExtortionPactActive := True;
    Result := True;
  end;
end;
{ @end $5B1D44 }

{ @routine $5B228C TPirate_BuildTrucePaymentResponse }
function TPirate.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $5B20F4 AcceptPayment
  procedure AcceptPayment; // @addr $5B20F4 @ida "void __usercall $name(void *ParentFrame@<^0>);" @note "Nested helper with caller-popped static link."
  var I: Integer; Ship: TShip;
  begin
    OtherShip.AbductedByPirateClan := False;
    if (OwnerId = Byte(oiPirate)) and (CurrentStar.ControlFaction = sfPirates) and (CurrentStar.Status.CustomFaction = '') and (OtherShip is TNormalShip) then
      if TNormalShip(OtherShip).CurrentSystemKills.Pirate > 0 then begin
        TNormalShip(OtherShip).CurrentSystemKills.Pirate := 0;
        for I := 0 to CurrentStar.Ships.Count - 1 do begin
          Ship := CurrentStar.Ships[I];
          if (Ship is TNormalShip) and (Ship.OwnerId = Byte(oiPirate)) then Ship.TruceWithShip(OtherShip);
        end;
      end;
    if OtherShip is TRanger then begin
      if (MainPiratePlanet <> nil) and (MainPiratePlanet.OwnerId = Byte(oiPirate)) then MainPiratePlanet.ChangeRelationToRanger(OtherShip, 10);
      (OtherShip as TRanger).AddTraderCareerActivity(1);
    end;
    OtherShip.SetMoney(OtherShip.Money - OfferedAmount);
    SetMoney(Money + OfferedAmount);
    TruceWithShip(OtherShip);
  end;
begin
  if UnknownVirtualC0(OtherShip) then begin
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
  else if (OwnerId = Byte(oiPirate)) and (OtherShip is TNormalShip) and (OtherShip.OwnerId <> Byte(oiPirate)) and
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
{ @end $5B228C }

{ @routine $5B2950 TPirate_BuildAttackRequestResponse }
function TPirate.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
  // @nested $5B27DC AcceptRequest
  procedure AcceptRequest; // @addr $5B27DC @ida "void __usercall $name(void *ParentFrame@<^0>);" @note "Nested helper with caller-popped static link."
  begin
    Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Ok', Requester);
    SetJointAttackTarget(Requester, Target);
    Result := True;
  end;
  // @nested $5B28B4 FriendsPreferred
  function FriendsPreferred: Boolean; // @addr $5B28B4 @ida "bool __usercall $name@<al>(void *ParentFrame@<^0>);" @note "Nested helper with caller-popped static link."
  var UnusedLocal: Integer; // Native gap before the floating-point temporaries.
  begin
    Result := Cardinal(RelationToShip(Target)) >= Round(RelationToShip(Requester) *
      RemapClamped(Galaxy.GetCoalitionToPirateSystemRatio, 0.33, 1, 1.3, 0));
  end;
begin
  Result := False;
  if Requester is TRanger then begin
    if Target.TypeId in [stRanger..stPirate] then Target.ChangeRelationToRanger(Requester, -20);
    if (Target.OwnerId = Byte(oiDominator)) or (Target.TypeId = stPirate) then (Requester as TRanger).AddWarriorCareerActivity(1)
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
{ @end $5B2950 }

{ @routine $5B2E78 TPirate_AcceptPartnershipOffer }
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
{ @end $5B2E78 }

{ @routine $5B3068 TPirate_BuildPartnershipOfferResponse }
function TPirate.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  if PartnerShip = OtherShip then begin Result := True; Exit; end;
  Result := False;
  if RelationToShip(OtherShip) < 45 then Response := LookupVisibleTalkText('Talk.Pirate.Suspect', OtherShip)
  else if PartnerShip <> nil then Response := FormatText1(LookupVisibleTalkText('Talk.Pirate.AlreadyHavePartner', OtherShip), '<color=255,240,100>', '<Partner>', (PartnerShip as TRanger).Name)
  else if ((OtherShip is TPlayer) and (TPlayer(OtherShip).GetMaxPiratePartners <= TPlayer(OtherShip).PiratePartners.Count)) or
    ((OwnerId = Byte(oiPirate)) and (GetPlayer.PirateRank < PirateRank)) then Response := LookupVisibleTalkText('Talk.Pirate.NeedPirate', OtherShip)
  else if (OtherShip is TRanger) and (OtherShip.GetEffectiveSkillLevel(psLeadership) <= (OtherShip as TRanger).CountWingmen) then
    Response := LookupVisibleTalkText('Talk.Partner.NeedLeadership', OtherShip)
  else if CalculatePartnershipMonths(PaymentAmount, OtherShip) = 0 then Response := LookupVisibleTalkText('Talk.Pirate.SmallMoney', OtherShip)
  else Result := True;
  Response := FormatText1(Response, '<color=255,240,100>', '<Ranger>', (OtherShip as TRanger).Name);
end;
{ @end $5B3068 }

{ @routine $5B340C TPirate_ReviewPartnership }
procedure TPirate.ReviewPartnership;
var Leader: TShip; Longest, I: Integer;
begin
  if PartnerShip <> nil then
    if PartnershipDaysRemaining < 1 then begin
      if (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then begin
        Leader := PartnerShip;
        if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
        GetPlayer.PiratePartners.Remove(Self);
        PartnerShip := nil;
        NotifyPiratePartnershipExpired(Leader);
      end;
    end else if RelationToShip(PartnerShip) < 30 then begin
      if (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then begin
        Leader := PartnerShip;
        if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
        GetPlayer.PiratePartners.Remove(Self);
        PartnerShip := nil;
        NotifyPiratePartnerRelationBreak(Leader);
      end;
    end else if (EnemyShip <> nil) and (EnemyShip.PartnerShip <> nil) and (EnemyShip.PartnerShip = PartnerShip) then begin
      if (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then begin
        Leader := PartnerShip;
        if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
        GetPlayer.PiratePartners.Remove(Self);
        PartnerShip := nil;
        NotifyPiratePartnerRebellion(Leader);
      end;
    end else if (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then
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
{ @end $5B340C }

{ @routine $5B381C TPirate_MoveToRandomPlanetOrbit }
procedure TPirate.MoveToRandomPlanetOrbit;
var Planet: TPlanet; Polar: TPolarPoint;
begin
  Planet := CurrentStar.Planets[0];
  Polar := Planet.Orbit;
  Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $5B381C }

{ @routine $5B3884 TPirate_UnknownVirtualC0 }
function TPirate.UnknownVirtualC0(Argument: Pointer): Boolean;
begin
  Result := False;
  if (PirateType <> 0) and (TShip(Argument).CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) and
    ((CurrentStar.ControlFaction <> sfPirates) or (CurrentStar.Status.CustomFaction <> '') or
    (MainPiratePlanet = nil) or (MainPiratePlanet.OwnerId <> Byte(oiPirate)) or (TShip(Argument).CurrentStar = MainPiratePlanet.CurrentStar)) then Result := True;
end;
{ @end $5B3884 }

{ @routine $5B3904 TPirate_TryRetreatFromSystem }
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
  if (OwnerId = Byte(oiPirate)) or (HostileSystem and (Station <> nil)) then begin
    if (OwnerId = Byte(oiPirate)) and not PirateSystem then RetreatFactor := RetreatFactor * 0.25;
    DominatorAndCustomStrength := CurrentStar.GetCachedFactionStrength(Ord(sfDominators));
    CoalitionStrength := CurrentStar.GetCachedFactionStrength(Ord(sfCoalition));
    PirateStrength := CurrentStar.GetCachedFactionStrength(Ord(sfPirates));
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
{ @end $5B3904 }

{ @routine $5B3F68 TPirate_AdjustItemEvaluation }
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
{ @end $5B3F68 }

{ @routine $5B4510 TPirate_EvaluateStatBonus }
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
      if (GetSlotCount(sskRadar) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[Ord(BonusKind)] - PirateSlotBonusWeights[18] * CountMissileWeapons
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[Ord(BonusKind)] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * PirateSlotBonusWeights[18]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotHook:
      if (GetSlotCount(sskCargoHook) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskCargoHook) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -PirateSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(sskWeapon)) * PirateSlotBonusWeights[Ord(BonusKind)];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskWeapon)) * PirateSlotBonusWeights[Ord(BonusKind)];
        if CountEquippedWeapons > Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - (PirateSlotBonusWeights[Ord(BonusKind)] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(sskWeapon)));
      end;
    bonSlotArt:
      begin
        if (GetSlotCount(sskArtefact) < DefaultHullSlotCounts[8]) and (Value > 0) then
          Result := Min(Value, DefaultHullSlotCounts[8] - GetSlotCount(sskArtefact)) * PirateSlotBonusWeights[Ord(BonusKind)];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskArtefact)) * PirateSlotBonusWeights[Ord(BonusKind)];
        if Artefacts <> nil then
          if Artefacts.Count > Max(Value + GetSlotCount(sskArtefact), 0) then Result := -1000;
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := PirateSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -PirateSlotBonusWeights[Ord(BonusKind)];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])), Value) * PirateSkillBonusWeights[Ord(BonusKind)];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])) > 6) then
          Result := Result + (PirateSkillBonusWeights[Ord(BonusKind)] * 0.05) * (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])), -Value) * -PirateSkillBonusWeights[Ord(BonusKind)];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])) < 0) then
          Result := Result + (PirateSkillBonusWeights[Ord(BonusKind)] * 0.03) * (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])));
      end;
  else Result := 0;
  end;
  if (PirateType = 0) and (BonusKind in [bonSlotForsage, bonMass]) then Result := Result * 1.3;
  if (PirateType = 0) and (BonusKind in [bonSpeed]) then Result := Result * 1.2 * Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed);
  if (PirateType = 1) and (BonusKind in [bonHull, bonSpeed, bonDroid, bonDef..bonWMissile]) then Result := Result * 1.3;
  if (PirateType = 2) and (BonusKind in [bonScan, bonWEnergy..bonWRadius]) then Result := Result * 1.3;
  if (PirateType = 3) and (BonusKind in [bonSpeed, bonRadar, bonDroid, bonWRadius, bonMass]) then Result := Result * 1.3;
  if (PirateType = 3) and (BonusKind in [bonWEnergy..bonWMissile]) then Result := Result * 0.7;
  if BonusKind in [bonSkill1..bonSkill6] then Result := Result * 0.01 * (100 + SeededRandomIntRange(-75, 75, Seed + 131 * Ord(BonusKind))) * RaceSkillEvaluationFactors[PilotRace, EquipmentBonusSkills[Ord(BonusKind) - 22]]
  else Result := Result * 0.01 * (100 + SeededRandomIntRange(-25, 25, Seed + 131 * Ord(BonusKind)));
end;
{ @end $5B4510 }

{ @routine $5B53B0 TPirate_EvaluateWeaponDamage }
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
  case Byte(Weapon.GetWeaponInfo.ShotType) of
    Ord(wstRocket): Result := Result * 0.9 * Weapon.GetShotCount * (1 + StatusFactor);
    Ord(wstMissile): Result := Result * (0.9 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    Ord(wstTorpedo): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor);
    Ord(wstChain): Result := Result * (1.3 + (Weapon.GetShotCount - 1) * 0.1) * (1 + StatusFactor);
    Ord(wstSplash): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.4 * 0.01 * SpeedFactor + StatusFactor);
    Ord(wstAreaDamage): Result := Result * (1 + Weapon.Range * 0.3 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
  if (PirateType = 3) and (Flags * DisablingFlags <> []) and (CountWeaponsByDamageFlags(Flags * DisablingFlags) = 0) then Result := Result * 4
  else if dkMissile in Flags then Result := Result * 1.2;
end;
{ @end $5B53B0 }

{ @routine $5B5CF8 TPirate_AcceptPickupItem }
function TPirate.AcceptPickupItem(Item: TItem): Boolean;
begin Result := True; end;
{ @end $5B5CF8 }

{ @routine $5B5D10 TPirate_AcceptPickupDistance }
function TPirate.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  if Speed < 1 then begin Result := False; Exit; end;
  Result := (Byte(Item.ItemType) in [Ord(t_Technics), Ord(t_Luxury), Ord(t_Alcohol)..Ord(t_Narcotics)]) or (2 * Speed >= Distance) or
    (Item.Cost >= RemapClamped(Distance / Speed, 1, 10, 0.01, 0.05) * Wealth);
end;
{ @end $5B5D10 }

{ @routine $5B5DC4 TPirate_RefreshCurrentStanding }
procedure TPirate.RefreshCurrentStanding;
var Owner: Byte; StandingMode: Integer;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then begin
    if (GetPlayer <> nil) and (GetPlayer = PartnerShip) then Owner := GetPlayer.OwnerId else Owner := OwnerId;
    if IsInPrison or ((PirateType = 0) and (Owner <> 7)) then CurrentStanding := ssNeutral
    else if (Owner = 7) and (PirateType <> 0) then CurrentStanding := ssPirateMilitary
    else if (Owner = 7) and ((CurrentSystemKills.Normal > 0) or (CurrentStar.ControlFaction = sfPirates)) then CurrentStanding := ssPirateActive
    else CurrentStanding := ssPiratePassive;
  end;
end;
{ @end $5B5DC4 }

end.
