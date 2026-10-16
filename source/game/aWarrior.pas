unit aWarrior;

interface

uses EC_Struct, EC_BlockPar, EC_Buf, aItem, aShip, aConst, aGalaxy, aGalaxyStruct, aNormalShip, aPlanet;

type
  // BuyWarrior / BuyFlagship and GetDefaultHullType distinguish these subtypes.
  TWarriorType = (warrior_regular = 0, warrior_flagship = 1); // @size $01

  TWarrior = class(TNormalShip) // @size 0x514
  public
    WarriorType: TWarriorType; // @offset 0x510  warrior_regular / warrior_flagship; exposed as Script.ShipSubType.

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $5A36EC @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $5A370C @slot $04
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr $5A9EEC @slot $50
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $5AA410 @slot $54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr $5AAEE4 @slot $58
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $5A4E74 @slot $60
    procedure BuildReachablePlanetQueue; override; // @addr $5A4D94 @slot $64
    procedure SelectEnemyShipInStar; override; // @addr $5A6FE4 @slot $6C
    procedure EngageEnemyShip; override; // @addr $5A7470 @slot $70
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $5A5418 @slot $74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $5A5450 @slot $78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $5A557C @slot $7C
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $5A530C @slot $80
    function RecomputeFearState: Boolean; override; // @addr $5A5610 @slot $84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $5A574C @slot $88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $5A57D8 @slot $8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $5A57F0 @slot $90
    function AcceptPickupItem(Item: TItem): Boolean; override; // @addr $5AB42C @slot $94
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; override; // @addr $5AB48C @slot $98
    procedure ProcessCombatDialogue; override; // @addr $5A8DCC @slot $A0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $5A8DD0 @slot $A4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $5A8E2C @slot $A8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $5A8F2C @slot $AC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $5A9218 @slot $B0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $5A9690 @slot $B4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $5A9D00 @slot $B8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $5A9D44 @slot $BC
    function RefusesFactionNegotiation(OtherShip: TShip): Boolean; override; // @addr $5A9EA8 @slot $C0
    procedure RefreshCurrentStanding; override; // @addr $5AB518 @slot $C4
    destructor Destroy; override; // @addr $5A2BEC
    function FindNearestFriendlyFlagship: TShip; // @addr $5A6F18
    function NavigateToHomePlanet: Boolean; // @addr $5A4CD4
    procedure ProcessUnseenProgression; // @addr $5A51B0
    procedure MoveToRandomPlanetOrbit; // @addr $5A9D88
    procedure ConsumeNodes(Amount: Integer); // @addr $5A9E18

    procedure InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: TWarriorType); // @addr 0x005A2CC4 @note "Sets location, money and WarriorType; registers the ship with its star and home garrison."

    procedure NextDay; override; // @addr 0x005A3744 @slot 0x18
    procedure NextDayLogic; override; // @addr 0x005A3994 @slot 0x1C
    procedure ManeuverFlagship; // @addr $5A827C
    procedure NextDayFlagshipLogic; // @addr 0x005A451C @note "Flagship branch; its diagnostic retains TWarrior.NextDayLogic."
    procedure AssignWeaponTargetsInStar; override; // @addr 0x005A5880 @slot 0x20 @note "Native diagnostic name: TWarrior.ArmsToTarget."
    procedure AssignFlagshipWeaponTargets; // @addr 0x005A6624 @note "Flagship branch; shares the TWarrior.ArmsToTarget diagnostic."
    function GetTypeNameKey: WideString; override; // @addr $5A5150 @slot $2C
    function GetGreetingShipCategory: TGreetingShipCategory; override; // @addr $5A5178 @slot $30
    function GetHomeStar: TStar; override; // @addr $5A4F14 @slot $34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $5A5180 @slot $3C
    function GetDominantCareer: TRangerCareer; override; // @addr 0x005A517C @slot 0x38 @note "Always career_warrior."
    function GetName: WideString; override; // @addr 0x005A4F1C @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x005A4F30 @slot 0x28

    procedure ReassignFlagshipHomePlanet; // @addr $5A8868 Scores Coalition systems and same-race garrisons; moves the flagship between home rosters without changing its current position.
    procedure MoveToRandomPatrolPoint; // @addr 0x005A4E18
    function IsHomePatrolTurn: Boolean; // @addr 0x005A9DE4 @note "Requires the home system and (Id + CurrentTurn) mod 100 < 25."
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x005A5184 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x005A5188 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x005A4E04 @slot 0x68 @note "AI ownership check only; does not test travel range."
  end;

const
  WarriorSkillBonusWeights: array[bonus_accuracy..bonus_leadership] of Integer = (100, 100, 80, 10, 10, 10); // @addr $80EAA4
  // EvaluateStatBonus dispatches bonus kinds 13..20 to these slot cases.
  WarriorSlotBonusWeights: array[bonus_radar_slots..bonus_afterburner_slots] of Integer = (80, 80, 200, 0, 200, 150, 0, 10); // @addr $80EABC @indexrefs "0x005AA8AF,0x005AA8E9,0x005AA920,0x005AA94C,0x005AA99E,0x005AA9D5,0x005AAA01,0x005AAA2B,0x005AAA60,0x005AAA8C,0x005AAAB6,0x005AAAEB,0x005AAB30,0x005AAB5E,0x005AABCF,0x005AAC00,0x005AAC2B"

implementation

uses aKling, aAsteroid, aMissile, aScript, aEFilm, SE_Weapon, SE_Space, aPirate, EC_Struct, Classes, Math, Windows, SysUtils, aRanger, aTranclucator, aRuins, GR_Main, Globals, GlobalsV, EC_Str, aItem, aGalaxy, aShip, aConst, aMyFunction;

{ @routine $5A2BEC TWarrior_Destroy }
destructor TWarrior.Destroy;
var Index: Integer;
begin
  Index := HomePlanet.Warriors.IndexOf(Self);
  if Index >= 0 then HomePlanet.Warriors.Delete(Index);
  inherited;
end;
{ @end $5A2BEC }

{ @routine $5A2CC4 TWarrior_InitGenerated }
procedure TWarrior.InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: TWarriorType);
var FirstNameIndex, LastNameIndex: Integer; Ranger: TRanger; TechLevel: Byte; Config: TBlockParEC; Weapon: TWeapon;
  // @nested $5A2C34 SelectTechLevel
  function SelectTechLevel(Minimum, Maximum: Integer): Integer; // @addr $5A2C34 @note "Nested helper with caller-popped static link."
  begin
    Result := Round(RemapClamped(Galaxy.TechLevel, 1, 8, Minimum, Maximum));
    Result := Max(Min(Result + NextRandomIntRange(-2, 2, RandomState), Maximum), Minimum);
  end;
begin
  HomePlanet := Planet;
  CurrentPlanet := HomePlanet;
  CurrentPlanet.Warriors.Add(Self);
  CurrentStar := CurrentPlanet.CurrentStar;
  PilotRace := HomePlanet.RaceId;
  OwnerId := RaceToOwner(PilotRace);
  SetMoney(InitialMoney);
  TypeId := ship_warrior;
  WarriorType := Kind;
  if WarriorType = warrior_flagship then Dec(Galaxy.RangerSpawnQuotas[PilotRace]);
  Name := '';
  if (ModShipNameConfig <> nil) and (ModShipNameConfig.CountBlocks('Warrior') > 0) then begin
    Config := ModShipNameConfig.GetBlock('Warrior');
    if RaceToOwner(PilotRace) = OwnerId then Config := Config.GetBlock(OwnerToSys(OwnerId))
    else begin
      if Config.CountBlocks(OwnerToSys(OwnerId)) > 0 then Config := Config.GetBlock(OwnerToSys(OwnerId));
      if Config.CountBlocks(OwnerToSys(RaceToOwner(PilotRace))) > 0 then Config := Config.GetBlock(OwnerToSys(RaceToOwner(PilotRace)));
    end;
    LastNameIndex := 0;
    FirstNameIndex := Config.GetParamCount - 1;
    Name := Config.GetParamValue(NextRandomIntRange(LastNameIndex, FirstNameIndex, RandomState)) + ' ' + '-' + IntToStr(Id mod 100 + 1) + '-';
  end;
  if Length(GetName) = 0 then begin
    Config := LanguageDataConfig.GetBlock('ShipName').GetBlock('Warrior');
    if RaceToOwner(PilotRace) = OwnerId then Config := Config.GetBlock(OwnerToSys(OwnerId))
    else begin
      if Config.CountBlocks(OwnerToSys(OwnerId)) > 0 then Config := Config.GetBlock(OwnerToSys(OwnerId));
      if Config.CountBlocks(OwnerToSys(RaceToOwner(PilotRace))) > 0 then Config := Config.GetBlock(OwnerToSys(RaceToOwner(PilotRace)));
    end;
    LastNameIndex := 0;
    FirstNameIndex := Config.GetParamCount - 1;
    Name := Config.GetParamValue(NextRandomIntRange(LastNameIndex, FirstNameIndex, RandomState)) + ' ' + '-' + IntToStr(Id mod 100 + 1) + '-';
  end;
  if GetPlayer <> nil then begin
    Rank := NextRandomIntRange(0, Min(5, GetPlayer.Rank + 2), RandomState);
    if Rank > 5 then Rank := 5;
    if WarriorType = warrior_flagship then begin Inc(Rank); if Rank < 4 then Rank := 4; end;
    AddRankPoints(NextRandomIntRange(0, CoalitionRankPointThresholds[Rank] div 2, RandomState));
    if not Galaxy.IsZeroStartingExperienceEnabled then begin
      GainExperience(Round(RemapClamped(Ord(Rank), 0, 1000, TotalSkillTrainingCost div 6, TotalSkillTrainingCost div 2)), experience_unscaled);
      GainExperience(Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, NextRandomIntRange(0, TotalSkillTrainingCost div 2, RandomState))), experience_unscaled);
    end;
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  Ranger := Galaxy.StrongestRanger as TRanger;
  if Ranger = nil then TechLevel := 4 else TechLevel := Ranger.GetHull.TechLevel;
  if WarriorType = warrior_flagship then begin
    CreateAndEquipHull(Round(3 * HullBaseSize * EquipmentSizeFactors[5]), SelectTechLevel(3, 8), RaceToOwner(PilotRace), -1, False);
    CreateAndEquipFuelTanks(Round(2 * FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
    CreateAndEquipEngine(Round(2 * EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
    if GetSlotCount(slot_weapon) > WeaponCount then begin
      Weapon := CreateAndEquipWeapon(item_flux, 2 * WeaponInfos[item_flux].AverageSize, 1, OwnerId);
      Weapon.DetailImprovement := 3;
      Weapon.Improve(upgrade_random);
    end;
    if GetSlotCount(slot_weapon) > WeaponCount then begin
      Weapon := CreateAndEquipWeapon(item_flux, 2 * WeaponInfos[item_flux].AverageSize, 1, OwnerId);
      Weapon.DetailImprovement := 3;
      Weapon.Improve(upgrade_random);
    end;
    if GetSlotCount(slot_weapon) > WeaponCount then begin
      Weapon := CreateAndEquipWeapon(item_flux, 2 * WeaponInfos[item_flux].AverageSize, 1, OwnerId);
      Weapon.DetailImprovement := 3;
      Weapon.Improve(upgrade_random);
    end;
    if GetSlotCountForItemType(item_radar) > 0 then CreateAndEquipRadar(Round(2 * RadarBaseSize * EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)]), 1, OwnerId);
    if GetSlotCountForItemType(item_scanner) > 0 then CreateAndEquipScanner(Round(2 * ScannerBaseSize * EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)]), 1, OwnerId);
  end else begin
    CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), Min(TechLevel, SelectTechLevel(1, 6)), RaceToOwner(PilotRace), SelectRandomHullSeries, False);
    CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
    CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
    if GetSlotCount(slot_weapon) > WeaponCount then CreateAndEquipWeapon(item_industrial_laser, WeaponInfos[item_industrial_laser].AverageSize, 1, OwnerId);
    if GetSlotCount(slot_weapon) > WeaponCount then CreateAndEquipWeapon(item_flux, WeaponInfos[item_flux].AverageSize, 1, OwnerId);
    if GetSlotCountForItemType(item_radar) > 0 then CreateAndEquipRadar(Round(EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)] * RadarBaseSize), 1, OwnerId);
  end;
  if GetCargoFreeSpace < 0 then begin
    GetHull.Weight := GetHull.Weight + Abs(GetCargoFreeSpace) + 10;
    GetHull.HullPoints := GetHull.Weight;
  end;
  TrainSkillsAutomatically;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  SmoothedSpeed := Speed;
  SmoothedEnemySpeed := Speed;
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  if WarriorType = warrior_flagship then begin
    BuyEquipmentAtLocation(True);
    BuyEquipmentAtLocation(True);
    BuyEquipmentAtLocation(True);
  end;
end;
{ @end $5A2CC4 }

{ @routine $5A36EC TWarrior_SaveToBuffer }
procedure TWarrior.SaveToBuffer(Buffer: TBufEC);
begin
  inherited;
  Buffer.AddAnsiChar(AnsiChar(WarriorType));
end;
{ @end $5A36EC }

{ @routine $5A370C TWarrior_LoadFromBuffer }
procedure TWarrior.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited;
  if LoadedSaveVersion >= 130 then WarriorType := TWarriorType(Buffer.GetByte)
  else WarriorType := warrior_regular;
end;
{ @end $5A370C }

{ @routine $5A3744 TWarrior_NextDay }
procedure TWarrior.NextDay;
begin
  inherited NextDay;
  try
    if (ScriptShip <> nil) and HasScriptControl then begin
      ScriptNextDay;
      if ScriptShip <> nil then begin
        Exit;
      end;
    end;
    if WarriorType = warrior_flagship then SetMoney(Money + Max(1000, Min(5000, Galaxy.MaxRangerWealth div 15)));
    NextDayLogic;
    if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.NextDay ' + GetFullName(' '));
    end;
  end;
end;
{ @end $5A3744 }

{ @routine $5A3994 TWarrior_NextDayLogic }
procedure TWarrior.NextDayLogic;
const FriendlyStationMask = [standing_coalition_military, standing_coalition_active];
var Planet: TPlanet; Station: TShip; Stage: Integer;
begin
  Stage := 0;
  if WarriorType = warrior_flagship then NextDayFlagshipLogic
  else try
      if CurrentPlanet <> nil then begin
        Stage := 1;
        if CurrentPlanet.OwnerId in PlanetOwnerMasks.Coalition then begin
          Stage := 2;
          RepairBrokenEquipmentAtLocation;
          AutoEquipInventory;
          OptimizeInventory;
          RefuelAtLocation;
          ReloadWeaponAmmo;
          ProcessUnseenProgression;
          TrainSkillsAutomatically;
          if RepairHullAtLocation then Exit;
          Stage := 3;
          if LiberationGroup <> nil then ProcessLiberationGroupRoute;
          if (CurrentPlanet <> HomePlanet) or (LiberationGroup <> nil) or IsHomePatrolTurn then OrderTakeoff;
        end else OrderTakeoff;
        Stage := 4;
      end else if DockedTo <> nil then begin
        Stage := 5;
        if not (DockedTo.TypeId in [station_ranger_center..station_custom]) then begin
          if DockedTo.InNormalSpace then OrderTakeoff else OrderNone(False);
          Exit;
        end;
        SynchronizeDockedLocation;
        RepairBrokenEquipmentAtLocation;
        AutoEquipInventory;
        OptimizeInventory;
        RefuelAtLocation;
        ReloadWeaponAmmo;
        ProcessUnseenProgression;
        TrainSkillsAutomatically;
        if RepairHullAtLocation then Exit;
        BuyEquipmentAtLocation(False);
        RestoreEssentialEquipment;
        Stage := 6;
        if LiberationGroup <> nil then ProcessLiberationGroupRoute;
        if (DockedTo.TypeId = station_military_base) and (TRuins(DockedTo).FlyToStar <> nil) and (TRuins(DockedTo).FlyToStar <> DockedTo.CurrentStar) then Exit;
        if DockedTo.InNormalSpace then OrderTakeoff;
        Stage := 7;
      end else if InNormalSpace then begin
        Stage := 8;
        RecomputeFearState;
        AssignWeaponTargetsInStar;
        AfterburnerActive := False;
        Stage := 9;
        if InFear then begin
          Stage := 10;
          if (Order = order_land) or (Order = order_jump) then UpdateAfterburnerState;
          if Order <> order_land then begin
            Stage := 11;
            BuildReachablePlanetQueue;
            Planet := SelectNearestQueuedPlanet;
            if (Planet <> nil) and (Planet.CurrentStar = CurrentStar) then begin
              Stage := 12;
              OrderLanding(Planet, True);
              UpdateAfterburnerState;
            end else begin
              Stage := 13;
              Station := FindNearestDockableStation(FriendlyStationMask);
              if Station <> nil then begin
                Stage := 14;
                OrderLanding(Station, True);
                UpdateAfterburnerState;
              end else if LiberationGroup = nil then begin
                Stage := 15;
                SelectEnemyShipInStar;
                EngageEnemyShip;
                if Order = order_none then MoveToRandomPatrolPoint;
              end;
            end;
          end;
          Stage := 16;
        end else begin
          Stage := 17;
          if LiberationGroup = nil then begin
            Stage := 18;
            SelectEnemyShipInStar;
            EngageEnemyShip;
            Stage := 19;
            if Order = order_none then
              if IsHomePatrolTurn then MoveToRandomPlanetOrbit
              else if not NavigateToHomePlanet then MoveToRandomPatrolPoint;
            Stage := 20;
          end;
        end;
        if LiberationGroup <> nil then begin
          Stage := 21;
          AfterburnerActive := False;
          RefreshDerivedStats(True);
          ProcessLiberationGroupRoute;
          Stage := 22;
          if LiberationGroup = nil then begin
            Stage := 23;
            SelectEnemyShipInStar;
            EngageEnemyShip;
            if (Order = order_none) and not NavigateToHomePlanet then MoveToRandomPatrolPoint;
          end;
        end;
      end;
    except
      on E: Exception do begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        raise Exception.Create('Error in procedure TWarrior.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
      end;
    end;
end;
{ @end $5A3994 }

{ @routine $5A451C TWarrior_NextDayFlagshipLogic }
procedure TWarrior.NextDayFlagshipLogic;
const FriendlyStationMask = [standing_coalition_military, standing_coalition_active]; AnyStationMask = [];
var Planet: TPlanet; Station, Ship: TShip; Stations: TList; I, Stage: Integer;
  // @nested $5A3FE4 RepairHullWithNodes
  procedure RepairHullWithNodes; // @addr $5A3FE4
  var Needed, Available, Restored: Integer; Fraction: Single; Entry: PEFilmEndEntry; Effect: TWeaponSE;
  begin
    if not (PilotRace in [owner_maloc, owner_peleng]) or not InFear then Exit;
    Available := GetCarriedNodeCount;
    if Available <= 0 then Exit;
    Needed := Ceil((GetHull.Weight - GetHull.HullPoints) *
      (GetCombatStatusStrength(combat_effect_node_repair_penalty) * 0.002 + 1) / 10 / 2 * RemapClamped(Galaxy.TechLevel, 2, 8, 5, 1));
    if Needed <= 0 then Exit;
    Available := Min(Needed, Available);
    ConsumeNodes(Available);
    Fraction := Available / Needed;
    Restored := Ceil(RemapClamped(Fraction, 0, 1, 0.01, GetHull.Weight - GetHull.HullPoints));
    Inc(GetHull.HullPoints, Restored);
    AddCombatStatusStrength(combat_effect_node_repair_penalty, Restored / 2, nil);
    RefreshDerivedStats(True);
    if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
      Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
      Effect.SetEndpoints(nil, Graphic);
      Effect.SetHit(OwnerToFilmColor(OwnerId), -Restored, False, True);
      if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
      Entry := TrailingFilmEffects.AppendEntry;
      RetainSpaceObject(Entry.SceneObject, Effect);
      RetainSpaceObject(Entry.RelatedObject1, nil);
      Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
    end;
  end;
  // @nested $5A427C RepairEquipmentWithNodes
  procedure RepairEquipmentWithNodes; // @addr $5A427C
  var I: Integer; Equipment: TEquipment; NeedsRepair: Boolean; TotalCost, Available, Threshold: Integer; Fraction: Single;
  begin
    if PilotRace in [owner_feyan, owner_gaal] then begin
      Available := GetCarriedNodeCount;
      if Available > 0 then begin
        NeedsRepair := False;
        TotalCost := 0;
        Threshold := Round(RemapClamped(CargoFreeSpace, 0, GetHull.Weight div 4, 90, 50));
        for I := 1 to Inventory.Count - 1 do begin
          Equipment := Inventory[I];
          if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> availability_not_sold_node_repair)) and
            CanRepairEquipmentTech(Equipment) and (Equipment.ItemType <> item_hull) and (Equipment.EquippedFlag <> 0) then begin
            if Threshold >= Equipment.ConditionPercent then NeedsRepair := True;
            Inc(TotalCost, Round(Equipment.CalculateRepairCost));
          end;
        end;
        if NeedsRepair then begin
          TotalCost := Round(TotalCost * 0.0025 / 2 * RemapClamped(Galaxy.TechLevel, 2, 8, 5, 1));
          if TotalCost = 0 then TotalCost := 1;
          Available := Min(TotalCost, Available);
          Fraction := Available / TotalCost;
          ConsumeNodes(Available);
          for I := 0 to Inventory.Count - 1 do begin
            Equipment := Inventory[I];
            if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> availability_not_sold_node_repair)) and
              CanRepairEquipmentTech(Equipment) and (Equipment.ItemType <> item_hull) and (Equipment.EquippedFlag <> 0) then begin
              Equipment.ConditionPercent := RemapClamped(Fraction, 0, 1, Equipment.ConditionPercent, 100);
              if Equipment.ConditionPercent > 0 then Equipment.BrokenFlag := 0;
            end;
          end;
          RefreshDerivedStats(True);
        end;
      end;
    end;
  end;
begin
  Stage := 0;
  try
    if CurrentPlanet <> nil then begin
      Stage := 1;
      if CurrentPlanet.OwnerId in PlanetOwnerMasks.Coalition then begin
        Stage := 2;
        DepositCarriedNodes;
        RepairBrokenEquipmentAtLocation;
        AutoEquipInventory;
        OptimizeInventory;
        RefuelAtLocation;
        ReloadWeaponAmmo;
        ProcessUnseenProgression;
        TrainSkillsAutomatically;
        if RepairHullAtLocation then Exit;
        Stage := 3;
        if LiberationGroup <> nil then ProcessLiberationGroupRoute;
        if (CurrentPlanet <> HomePlanet) or (LiberationGroup <> nil) or IsHomePatrolTurn then OrderTakeoff;
      end else OrderTakeoff;
      Stage := 4;
    end else if DockedTo <> nil then begin
      Stage := 5;
      SynchronizeDockedLocation;
      DepositCarriedNodes;
      RepairBrokenEquipmentAtLocation;
      AutoEquipInventory;
      OptimizeInventory;
      RefuelAtLocation;
      ReloadWeaponAmmo;
      ProcessUnseenProgression;
      TrainSkillsAutomatically;
      if RepairHullAtLocation then Exit;
      BuyEquipmentAtLocation(False);
      RestoreEssentialEquipment;
      Stage := 6;
      if LiberationGroup <> nil then ProcessLiberationGroupRoute;
      if DockedTo = Galaxy.FindMilitaryBaseInTransit then Exit;
      if DockedTo.InNormalSpace then OrderTakeoff;
      Stage := 7;
    end else if InNormalSpace then begin
      Stage := 8;
      RecomputeFearState;
      RepairHullWithNodes;
      RepairEquipmentWithNodes;
      QueueItemsWithinPickupRange;
      AssignWeaponTargetsInStar;
      AfterburnerActive := False;
      Stage := 9;
      if InFear then begin
        Stage := 10;
        if (Order = order_land) or (Order = order_jump) then UpdateAfterburnerState;
        if Order <> order_land then begin
          Stage := 11;
          BuildReachablePlanetQueue;
          Planet := SelectNearestQueuedPlanet;
          if (Planet <> nil) and (Planet.CurrentStar = CurrentStar) then begin
            Stage := 12;
            OrderLanding(Planet, True);
            UpdateAfterburnerState;
          end else begin
            Stage := 13;
            Station := FindNearestDockableStation(FriendlyStationMask);
            if Station <> nil then begin
              Stage := 14;
              OrderLanding(Station, True);
              UpdateAfterburnerState;
            end else if LiberationGroup = nil then begin
              Stage := 15;
              SelectEnemyShipInStar;
              ManeuverFlagship;
            end;
          end;
        end;
        Stage := 16;
      end else begin
        Stage := 17;
        if LiberationGroup = nil then begin
          Stage := 18;
          SelectEnemyShipInStar;
          ManeuverFlagship;
          Stage := 19;
          if Order = order_none then begin
            if NextRandomIntRange(1, 100, RandomState) > 80 then begin
              Station := nil;
              Stations := TList.Create;
              for I := 0 to CurrentStar.Ships.Count - 1 do begin
                Ship := CurrentStar.Ships[I];
                if (Ship.TypeId in [station_ranger_center..station_custom]) and Ship.CanDock(Self) and (Ship.CurrentStanding in [standing_coalition_military..standing_neutral]) then begin
                  if PointDistanceSquared(Position, Ship.Position) >= Sqr(CalculateSpeed) then Stations.Add(Ship);
                end;
              end;
              if Stations.Count > 0 then Station := Stations[NextRandomIntRange(0, Stations.Count - 1, RandomState)];
              Stations.Free;
              if Station <> nil then OrderLanding(Station, False);
            end;
            if Order = order_none then TryCollectBestFloatingItem(50);
            if (Order = order_none) and IsHomePatrolTurn then MoveToRandomPlanetOrbit;
            if (Order = order_none) and not NavigateToHomePlanet then MoveToRandomPatrolPoint;
          end;
          Stage := 20;
        end;
      end;
      if LiberationGroup <> nil then begin
        Stage := 21;
        AfterburnerActive := False;
        RefreshDerivedStats(True);
        ProcessLiberationGroupRoute;
        Stage := 22;
        if LiberationGroup = nil then begin
          Stage := 23;
          SelectEnemyShipInStar;
          ManeuverFlagship;
          if Order = order_none then TryCollectBestFloatingItem(50);
          if Order = order_none then begin
            if NextRandomIntRange(1, 100, RandomState) > 40 then begin
              Station := FindNearestDockableStation(AnyStationMask);
              if Station <> nil then OrderLanding(Station, False);
            end;
            if (Order = order_none) and not NavigateToHomePlanet then MoveToRandomPatrolPoint;
          end;
        end;
      end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5A451C }

{ @routine $5A4CD4 TWarrior_NavigateToHomePlanet }
function TWarrior.NavigateToHomePlanet: Boolean;
begin
  if HomePlanet.CurrentStar = CurrentStar then begin OrderLanding(HomePlanet, False); Result := True; end
  else if (GetFuelTanks.Fuel = GetFuelTanks.Capacity) or
    (JumpRange * JumpRange >= PointDistanceSquared(HomePlanet.CurrentStar.Position, CurrentStar.Position)) then begin
    OrderJump(HomePlanet.CurrentStar, False); Result := True;
  end else begin
    BuildReachablePlanetQueue;
    if PlanetQueue.Count > 0 then begin
      OrderLanding(PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)], False);
      Result := True;
    end else Result := False;
  end;
end;
{ @end $5A4CD4 }

{ @routine $5A4D94 TWarrior_BuildReachablePlanetQueue }
procedure TWarrior.BuildReachablePlanetQueue;
var I: Integer; Planet: TPlanet;
begin
  ClearPlanetQueue;
  PlanetQueue := TList.Create;
  if (Speed <> 0) then
    if (CurrentStar.Status.CustomFaction = '') then
    for I := 0 to CurrentStar.Planets.Count - 1 do begin
      Planet := CurrentStar.Planets[I];
      if Planet.IsCoalitionOwned then PlanetQueue.Add(Planet);
    end;
end;
{ @end $5A4D94 }

{ @routine $5A4E04 TWarrior_CanQueueReachablePlanet }
function TWarrior.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := (Planet.OwnerId <> owner_dominator) and (Planet.OwnerId <> owner_pirate);
end;
{ @end $5A4E04 }

{ @routine $5A4E18 TWarrior_MoveToRandomPatrolPoint }
procedure TWarrior.MoveToRandomPatrolPoint;
var Destination: TPointF;
begin
  Destination.X := NextRandomIntRange(-2000, 2000, RandomState);
  Destination.Y := NextRandomIntRange(-2000, 2000, RandomState);
  OrderMove(Destination, False);
end;
{ @end $5A4E18 }

{ @routine $5A4E74 TWarrior_RepairBrokenEquipmentAtLocation }
procedure TWarrior.RepairBrokenEquipmentAtLocation;
var I: Integer; Equipment: TEquipment; Artefact: TArtefact;
begin
  for I := 1 to Inventory.Count - 1 do begin
    Equipment := Inventory[I];
    if (Equipment.BrokenFlag <> 0) or (Equipment.ConditionPercent < 30) then Equipment.Repair;
  end;
  if CanRepairArtefactsAtLocation then
    for I := 0 to Artefacts.Count - 1 do begin
      Artefact := Artefacts[I];
      if (Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 30) then
        if Artefact.EquippedFlag <> 0 then Artefact.Repair;
    end;
end;
{ @end $5A4E74 }

{ @routine $5A4F14 TWarrior_GetHomeStar }
function TWarrior.GetHomeStar: TStar;
begin
  Result := HomePlanet.CurrentStar;
end;
{ @end $5A4F14 }

{ @routine $5A4F1C TWarrior_GetName }
function TWarrior.GetName: WideString;
begin
  Result := Name;
end;
{ @end $5A4F1C }

{ @routine $5A4F30 TWarrior_GetFullName }
function TWarrior.GetFullName(const Separator: WideString): WideString;
var
  Path, Text: WideString;
begin
  if TypeNameOverrideKey = '' then
  begin
    if WarriorType = warrior_flagship then
      Result := LocalizedText('ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + GetTypeNameKey + 'Big') + Separator + Name
    else Result := LocalizedText('ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + GetTypeNameKey) + Separator + Name;
  end
  else
  begin
    Path := 'ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + TypeNameOverrideKey;
    if LanguageDataConfig.CountParamsByPath(Path) > 0 then Text := LocalizedText(Path)
    else Text := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Text <> '' then Result := Text + Separator + Name else Result := Name;
  end;
end;
{ @end $5A4F30 }

{ @routine $5A5150 TWarrior_GetTypeNameKey }
function TWarrior.GetTypeNameKey: WideString;
begin
  Result := 'Warrior';
end;
{ @end $5A5150 }

{ @routine $5A5178 TWarrior_GetGreetingShipCategory }
function TWarrior.GetGreetingShipCategory: TGreetingShipCategory;
begin
  Result := greeting_ship_warrior;
end;
{ @end $5A5178 }

{ @routine $5A517C TWarrior_GetDominantCareer }
function TWarrior.GetDominantCareer: TRangerCareer;
begin
  Result := career_warrior;
end;
{ @end $5A517C }

{ @routine $5A5180 TWarrior_GetStrengthScaledPirateStatus }
function TWarrior.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 0;
end;
{ @end $5A5180 }

{ @routine $5A5184 TWarrior_GetDesiredCargoFreeSpace }
function TWarrior.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $5A5184 }

{ @routine $5A5188 TWarrior_RefuelAtLocation }
procedure TWarrior.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $5A5188 }

{ @routine $5A51B0 TWarrior_ProcessUnseenProgression }
procedure TWarrior.ProcessUnseenProgression;
var Award: Byte;
begin
  if (DaysSincePlayerSeen >= 60) and (GetPlayer <> nil) then begin
    if NextRandomUnitFloat(RandomState) < 0.05 then GainExperience(SeededRandomIntRange(100, 500, RandomState), experience_unscaled);
    if (GetPlayer.Rank > Rank) and (NextRandomUnitFloat(RandomState) < 0.01) and ((Rank < 4) or ((WarriorType = warrior_flagship) and (Rank < 6))) then begin
      AddRankPoints(NextRandomIntRange(10, 20, RandomState));
      TryPromoteRank;
    end;
    if (NextRandomUnitFloat(RandomState) < 0.02) and (CurrentPlanet <> nil) and ((AwardIds = nil) or (2 * (Rank + 1) > AwardIds.Count)) then begin
      Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [award_accomplishment, award_secret_mission], [ship_dominator..station_custom]);
      if Award <> AwardNotFound then AddAward(Award);
    end;
  end;
end;
{ @end $5A51B0 }

{ @routine $5A530C TWarrior_RelationToNonRanger }
function TWarrior.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship.TypeId = ship_pirate then Result := Round(Max(10, Min(20, (0.5 * PlanetRaceMarket[PilotRace].PirateRelationFactor) *
    OwnerRelations[RaceToOwner(PilotRace), Ship.OwnerId])))
  else if Ship.TypeId in [ship_dominator, ship_tranclucator] then Result := 50 else Result := 100;
end;
{ @end $5A530C }

{ @routine $5A5418 TWarrior_RelationToRanger }
function TWarrior.RelationToRanger(Ranger: Pointer): Byte;
begin Result := Byte(HomePlanet.RangerRelations[Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)]); end;
{ @end $5A5418 }

{ @routine $5A5450 TWarrior_ChangeRelationToRanger }
procedure TWarrior.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var Relation: Byte; Value, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(HomePlanet.RangerRelations[Index]);
  if (TShip(Ranger).GetEffectiveSkillLevel(skill_charisma) > 0) and (Amount > 0) then
    Inc(Amount, Round(Amount * (TShip(Ranger).GetEffectiveSkillLevel(skill_charisma)) * 0.2));
  Value := Amount + Relation;
  if Value < 0 then Relation := 0 else if Value > 100 then Relation := 100 else Relation := Value;
  HomePlanet.RangerRelations[Index] := Pointer(Relation);
  if (Relation < RelationBadMin) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(HomePlanet.RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $5A5450 }

{ @routine $5A557C TWarrior_ReactToAttack }
procedure TWarrior.ReactToAttack(Attacker: TShip);
begin
  EnemyShip := Attacker;
  if (HomePlanet.OwnerId in PlanetOwnerMasks.Coalition) and (Attacker.TypeId = ship_ranger) then begin
    HomePlanet.ChangeRelationToRanger(Attacker, -3);
    if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = ship_ranger) then HomePlanet.ChangeRelationToRanger(Attacker.PartnerShip, -3);
    if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and (TTranclucator(Attacker).OwnerShip.TypeId = ship_ranger) then
      HomePlanet.ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -3);
  end;
end;
{ @end $5A557C }

{ @routine $5A5610 TWarrior_RecomputeFearState }
function TWarrior.RecomputeFearState: Boolean;
begin
  if HasNoUsableWeapons and (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then begin Result := True; InFear := True; end
  else begin
    Result := ((GetHull.HullPoints < GetHull.Weight * 0.3) and (GetHull.HullPoints < 200)) or (GetHull.HullPoints < 130) or
      ((GetHull.Weight * 0.5 * OwnerInfo[OwnerId].FearThresholdScale > GetHull.HullPoints) and (EnemyShip <> nil) and
      (EnemyShip.OrderTarget = Self) and (ChanceToWin(EnemyShip) - OwnerInfo[OwnerId].FearThresholdScale / 2 < 0));
    InFear := Result;
  end;
end;
{ @end $5A5610 }

{ @routine $5A574C TWarrior_AcceptsRansomDemandFrom }
function TWarrior.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := (GetHull.Weight * 0.5 * OwnerInfo[OwnerId].FearThresholdScale > GetHull.HullPoints) and
  (ChanceToWin(Ship) - OwnerInfo[OwnerId].FearThresholdScale / 2 < 0);
end;
{ @end $5A574C }

{ @routine $5A57D8 TWarrior_TrustsAttackRequester }
function TWarrior.TrustsAttackRequester(Ship: TShip): Boolean;
begin Result := RelationToShip(Ship) >= RelationNormalMin; end;
{ @end $5A57D8 }

{ @routine $5A57F0 TWarrior_AcceptsAppealFrom }
function TWarrior.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) +
    RemapClamped(Ship.Strength, 0.9 * Strength, Strength * 3, 0, 100) > 160;
end;
{ @end $5A57F0 }

{ @routine $5A5880 TWarrior_AssignWeaponTargetsInStar }
procedure TWarrior.AssignWeaponTargetsInStar;
const
  MissileShotTypes = [shot_torpedo..shot_rocket];
  AreaOrMissileShotTypes = [shot_area_damage..shot_rocket];
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Distance: Single; Item: TItem; Asteroid: TAsteroid; Missile: TMissile;
  SameRacePlanet: Boolean; Stage: Integer; IgnoreRanger: Boolean;
begin
  Stage := 0;
  if WarriorType = warrior_flagship then AssignFlagshipWeaponTargets
  else try
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; end;
  Assigned := 0;
  Stage := 1;
  if CurrentStar.Battle <> 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship.OwnerId = owner_dominator) and Ship.InNormalSpace then begin
        Distance := PointDistance(Position, Ship.Position);
        for J := 1 to WeaponCount do begin
          Weapon := Weapons[J];
          if ((Weapon.GetWeaponInfo.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
            not IsEquipmentUsable(Weapon) or not (GetWeaponRange(Weapon) >= Distance) then Continue;
          Weapon.Target := Ship;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
      end;
    end;
  Stage := 2;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then begin
    SameRacePlanet := (EnemyShip.OrderTarget is TPlanet) and
      ((EnemyShip.OrderTarget as TPlanet).RaceId = HomePlanet.RaceId) and
      ((EnemyShip.OrderTarget as TPlanet).RelationToShip(EnemyShip) <= RelationToShip(EnemyShip));
    IgnoreRanger := (EnemyShip.TypeId = ship_ranger) and ((EnemyShip.OrderTarget = HomePlanet) or SameRacePlanet) and not EnemyShip.IsAttackingShip(Self);
    if IgnoreRanger then
      for I := 1 to EnemyShip.WeaponCount do
        if (EnemyShip.Weapons[I].Target <> nil) and (EnemyShip.Weapons[I].Target is TShip) and
          not (EnemyShip.Weapons[I].Target is TPirate) then
          if GetRelationLevelToShip(EnemyShip.Weapons[I].Target as TShip) > relation_level_hostile then begin
            IgnoreRanger := False;
            Break;
          end;
    if IgnoreRanger then ClearWeaponTargets(EnemyShip)
    else for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if ((Weapon.GetWeaponInfo.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
        not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
      Weapon.Target := EnemyShip;
      Inc(Assigned);
      if Assigned = WeaponCount then Exit;
    end;
  end;
  Stage := 3;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    Stage := 31;
    if Ship.InNormalSpace and (Ship <> Self) and (EnemyShip <> Ship) then begin
      Stage := 32;
      if (RelationToShip(Ship) < RelationBadMin) or (EnemyShip = Ship) or (Ship.EnemyShip = Self) then begin
        Stage := 33;
        if TruceShip <> Ship then begin
          Stage := 34;
          if LiberationGroup = nil then begin
            Stage := 35;
            for J := 1 to WeaponCount do begin
              Stage := 36;
              Weapon := Weapons[J];
              if (Weapon.GetWeaponInfo.ShotType in MissileShotTypes) and (Weapon.Ammo = 0) then Continue;
              Stage := 37;
              if not (IsEquipmentUsable(Weapon) and (PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)))) then Continue;
              Stage := 38;
              // Native hostile-ship pass can replace an earlier assignment.
              Weapon.Target := Ship;
              Inc(Assigned);
              if Assigned = WeaponCount then Exit;
            end;
          end;
        end;
      end;
    end;
  end;
  Stage := 4;
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
  Stage := 5;
  if CurrentStar = GetPlayer.CurrentStar then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do begin
      Asteroid := CurrentStar.Asteroids[I];
      Distance := PointDistanceSquared(Position, Asteroid.Position);
      if not (Distance <= AsteroidTargetRangeSquared) then Continue;
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
  Stage := 6;
  if CurrentStar.Items.Count > Galaxy.GetAIJunkToleranceLevel * 1.5 then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if ((Item.ItemType <> item_minerals) and (Item.OwnerId <> owner_dominator)) or
        ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '')) then Continue;
      if not ((GetPlayer.CurrentStar <> CurrentStar) or (GetRelationLevelToShip(GetPlayer) <= relation_level_bad) or
        (PointDistance(GetPlayer.Position, Item.Position) >= 800) or
        ((NextRandomUnitFloat(RandomState) <= 0.1) and (PointDistance(GetPlayer.Position, Item.Position) >= 200))) then Continue;
      if not CanSafelyDetonateItem(Item) then Continue;
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if (Weapon.GetWeaponInfo^.ShotType in MissileShotTypes) or (Weapon.Target <> nil) or
          not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
        Weapon.Target := Item;
        Inc(Assigned);
        if Assigned = WeaponCount then Exit;
        Break;
      end;
    end;
  Stage := 7;
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and IsPlayerChameleonEffectiveAgainstSelf then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if ((Weapon.GetWeaponInfo.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
        not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, GetPlayer.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
      Weapon.Target := GetPlayer;
      Inc(Assigned);
      if Assigned = WeaponCount then Exit;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.ArmsToTarget ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5A5880 }

{ @routine $5A6624 TWarrior_AssignFlagshipWeaponTargets }
procedure TWarrior.AssignFlagshipWeaponTargets;
const
  MissileShotTypes = [shot_torpedo..shot_rocket];
  AreaOrMissileShotTypes = [shot_area_damage..shot_rocket];
var Scores: array[1..5] of Single; Assigned, I, J: Integer; Ship: TShip; Weapon: TWeapon; Distance: Single;
  Item: TItem; Asteroid: TAsteroid; Missile: TMissile; SameRacePlanet: Boolean; Stage: Integer; IgnoreRanger: Boolean;
  // @nested $5A64E4 ScoreTarget
  procedure ScoreTarget(Ship: TShip); // @addr $5A64E4
  var J, Range: Integer; Score, Distance: Single; Weapon: TWeapon;
  begin
    Score := 0;
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if not IsEquipmentUsable(Weapon) then Continue;
      if (Weapon.GetWeaponInfo.ShotType in MissileShotTypes) and (Weapon.Ammo <= 0) then Continue;
      Range := GetWeaponRange(Weapon);
      Distance := PointDistance(Position, Ship.Position);
      if not (Range >= Distance) then Continue;
      if Score = 0 then Score := Ship.CalculateAttackStrength / Ship.CalculateDefenseStrength * RemapClamped(Distance, 0, Range, 1.5, 1);
      if (Score > Scores[J]) or (Weapon.Target = nil) then begin
        if Weapon.Target = nil then Inc(Assigned);
        Scores[J] := Score;
        Weapon.Target := Ship;
      end;
    end;
  end;
begin
  Stage := 0;
  try
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; Scores[I] := 0; end;
  Assigned := 0;
  Stage := 1;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then begin
    SameRacePlanet := (EnemyShip.OrderTarget is TPlanet) and
      ((EnemyShip.OrderTarget as TPlanet).RaceId = HomePlanet.RaceId) and
      ((EnemyShip.OrderTarget as TPlanet).RelationToShip(EnemyShip) <= RelationToShip(EnemyShip));
    IgnoreRanger := (EnemyShip.TypeId = ship_ranger) and ((EnemyShip.OrderTarget = HomePlanet) or SameRacePlanet) and not EnemyShip.IsAttackingShip(Self);
    if not IgnoreRanger then ScoreTarget(EnemyShip);
  end;
  Stage := 2;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if Ship.InNormalSpace and (EnemyShip <> Ship) and (TruceShip <> Ship) and (LiberationGroup = nil) and
      (GetRelationLevelToShip(Ship) <= relation_level_hostile) then ScoreTarget(Ship);
  end;
  if Assigned = WeaponCount then Exit;
  Stage := 4;
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
  Stage := 5;
  if CurrentStar = GetPlayer.CurrentStar then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do begin
      Asteroid := CurrentStar.Asteroids[I];
      Distance := PointDistanceSquared(Position, Asteroid.Position);
      if not (Distance <= AsteroidTargetRangeSquared) then Continue;
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
  Stage := 6;
  if CurrentStar.Items.Count > Galaxy.GetAIJunkToleranceLevel * 1.5 then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if ((Item.ItemType <> item_minerals) and (Item.OwnerId <> owner_dominator)) or
        ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '')) or AcceptPickupItem(Item) then Continue;
      if not ((GetPlayer.CurrentStar <> CurrentStar) or (GetRelationLevelToShip(GetPlayer) <= relation_level_bad) or
        (PointDistance(GetPlayer.Position, Item.Position) >= 800) or
        ((NextRandomUnitFloat(RandomState) <= 0.1) and (PointDistance(GetPlayer.Position, Item.Position) >= 200))) then Continue;
      if not CanSafelyDetonateItem(Item) then Continue;
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if (Weapon.GetWeaponInfo^.ShotType in MissileShotTypes) or (Weapon.Target <> nil) or
          not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
        Weapon.Target := Item;
        Inc(Assigned);
        if Assigned = WeaponCount then Exit;
        Break;
      end;
    end;
  Stage := 7;
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and IsPlayerChameleonEffectiveAgainstSelf then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if ((Weapon.GetWeaponInfo.ShotType in MissileShotTypes) and (Weapon.Ammo = 0)) or (Weapon.Target <> nil) or
        not IsEquipmentUsable(Weapon) or not (PointDistanceSquared(Position, GetPlayer.Position) <= Sqr(GetWeaponRange(Weapon))) then Continue;
      Weapon.Target := GetPlayer;
      Inc(Assigned);
      if Assigned = WeaponCount then Exit;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.ArmsToTarget ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5A6624 }

{ @routine $5A6F18 TWarrior_FindNearestFriendlyFlagship }
function TWarrior.FindNearestFriendlyFlagship: TShip;
var BestDistance, Distance: Double; Ship: TShip; I: Integer;
begin
  Result := nil;
  BestDistance := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship <> Self) and (Ship is TWarrior) and ((Ship as TWarrior).WarriorType = warrior_flagship) and Ship.InNormalSpace then
      if Ship.GetRelationLevelToShip(Self) > relation_level_hostile then begin
        Distance := PointDistanceSquared(Position, Ship.Position);
        if (Result = nil) or (Distance < BestDistance) then begin Result := Ship; BestDistance := Distance; end;
      end;
  end;
end;
{ @end $5A6F18 }

{ @routine $5A6FE4 TWarrior_SelectEnemyShipInStar }
procedure TWarrior.SelectEnemyShipInStar;
var I: Integer; Ship, BestShip: TShip; Chance, BestChance, Distance, TravelTime, BestDistance: Double; InFlagshipRange: Boolean;
  Range, MinRange, MaxRange: Integer; Score, BestScore, OwnAttack: Double; Weapon: TWeapon;
begin
  if WarriorType = warrior_flagship then InFlagshipRange := True
  else begin
    Ship := FindNearestFriendlyFlagship;
    InFlagshipRange := (Ship <> nil) and (PointDistanceSquared(Position, Ship.Position) < Sqr(Ship.GetRadarRange));
  end;
  if InFlagshipRange then begin
    BestScore := -1;
    BestShip := nil;
    MinRange := -1;
    MaxRange := -1;
    for I := 1 to WeaponCount do begin
      Weapon := Weapons[I];
      if not (IsEquipmentUsable(Weapon) and (not (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) or (Weapon.Ammo > 0))) then Continue;
      Range := GetWeaponRange(Weapon);
      if (Range < MinRange) or (MinRange < 0) then MinRange := Range;
      if (Range > MaxRange) or (MaxRange < 0) then MaxRange := Range;
    end;
    OwnAttack := CalculateAttackStrength;
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if not (Ship.InNormalSpace and (RelationToShip(Ship) < RelationBadMin) and (TruceShip <> Ship)) then Continue;
      Score := Ship.CalculateAttackStrength * Max(1.0, OwnAttack / Ship.CalculateDefenseStrength);
      Distance := PointDistance(Position, Ship.Position);
      if MaxRange > Distance then Score := Score * RemapClamped(Distance, MinRange, MaxRange, 1.5, 1)
      else Score := Score * Distance / (Speed + 1) * RemapClamped((Speed + 1) / (Ship.Speed + 1), 0.5, 2, 0.25, 1);
      if Ship is TKling then begin
        if (Ship as TKling).KlingType = dominator_bertor then Score := Score * 5;
        if (Ship as TKling).KlingType = dominator_klig then Score := Score * 0.25;
      end;
      if Score > BestScore then begin BestScore := Score; BestShip := Ship; end;
    end;
    if BestShip <> nil then EnemyShip := BestShip;
  end else if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or (EnemyShip.ConsecutiveDockedDays > 3) then
    if UsableWeaponCount <> 0 then begin
      BestChance := -1;
      BestDistance := 1;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if not (Ship.InNormalSpace and (RelationToShip(Ship) < RelationBadMin) and (TruceShip <> Ship)) then Continue;
        if Ship.CurrentStanding in [standing_dominator, standing_pirate_military] then begin
          EnemyShip := Ship;
          if ChanceToWin(Ship) > 1 then Exit;
        end else if (LiberationGroup = nil) or ((GetPlayer = Ship) and (Ship.CurrentStanding = standing_pirate_active)) then begin
          Chance := ChanceToWin(Ship);
          TravelTime := PointDistance(Position, Ship.Position) / (Speed + 1) + 0.1;
          if Chance / TravelTime > BestChance / BestDistance then begin
            EnemyShip := Ship;
            BestChance := Chance;
            BestDistance := TravelTime;
          end;
        end;
      end;
    end;
end;
{ @end $5A6FE4 }

{ @routine $5A7470 TWarrior_EngageEnemyShip }
procedure TWarrior.EngageEnemyShip;
var Ship: TShip; RetreatToFlagship: Boolean;
begin
  if Order = order_follow_ship then OrderNone(False);
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then begin
    Ship := FindNearestFriendlyFlagship;
    RetreatToFlagship := (Ship <> nil) and EnemyShip.InNormalSpace and not EnemyShip.HasNoUsableWeapons and
      (EnemyShip.EnemyShip = Self) and (EnemyShip.OrderTarget = Self) and (EnemyShip.Speed > Speed) and
      (Ship.GetRelationLevelToShip(EnemyShip) <= relation_level_hostile);
    if EnemyShip.InNormalSpace then begin
      if RetreatToFlagship then OrderFollowShip(Ship, follow_close, False) else OrderFollowShip(EnemyShip, follow_min_weapon_range, False);
      if ChanceToWin(EnemyShip) < 0.8 then RequestAlliesAttackShip(EnemyShip);
    end else if ChanceToWin(EnemyShip) > 0.5 then begin
      if EnemyShip.CurrentPlanet <> nil then begin
        if (EnemyShip is TRanger) and ((EnemyShip as TRanger).PrisonTermRemaining > 0) then begin
          EnemyShip := nil;
          OrderNone(False);
          Exit;
        end;
        Ship := EnemyShip;
        if (Ship is TPirate) and ((Ship as TPirate).PrisonTermRemaining > 0) then begin
          EnemyShip := nil;
          OrderNone(False);
          Exit;
        end;
        OrderMove(Ship.CurrentPlanet.GetPosition, False);
      end else if EnemyShip.DockedTo <> nil then OrderMove(EnemyShip.DockedTo.Position, False);
    end;
  end;
end;
{ @end $5A7470 }

{ @routine $5A827C TWarrior_ManeuverFlagship }
procedure TWarrior.ManeuverFlagship;
var Enemies: TList; SupportWeight: Single; OwnMinRange, OwnMaxRange: Integer; OwnAttack: Single; Allies: TList;
  EnemiesInRange: Integer; AttackWeight, OwnDefense, FearWeight: Single; I: Integer; Ship: TShip;
  Candidate, Destination: TPointF; BestShip: TShip; BestShipScore, BestPositionScore, Score: Single;
  RandomDistance, Angle, AllyAreaScore, EnemyAreaScore: Integer; AllyRepair, EnemyRepair: Single;
  // @nested $5A7668 GetWeaponRangeBounds
  procedure GetWeaponRangeBounds(Ship: TShip; var Minimum, Maximum: Integer); // @addr $5A7668
  var I, Range: Integer; Weapon: TWeapon;
  begin
    Minimum := -1;
    Maximum := -1;
    for I := 1 to Ship.WeaponCount do begin
      Weapon := Ship.Weapons[I];
      // Native uses the flagship's usability check for other ships' weapons.
      if not IsEquipmentUsable(Weapon) then Continue;
      if (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) and (Weapon.Ammo <= 0) then Continue;
      Range := Ship.GetWeaponRange(Weapon);
      if (Minimum > Range) or (Minimum < 0) then Minimum := Range;
      if (Maximum < Range) or (Maximum < 0) then Maximum := Range;
    end;
  end;
  // @nested $5A7700 AreaWeaponScore
  function AreaWeaponScore(Ship: TShip): Integer; // @addr $5A7700
  var I: Integer; Weapon: TWeapon;
  begin
    Result := 0;
    for I := 1 to Ship.WeaponCount do begin
      Weapon := Ship.Weapons[I];
      if IsEquipmentUsable(Weapon) and (not (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) or (Weapon.Ammo > 0)) then
        case Weapon.GetWeaponInfo.ShotType of
          shot_chain: Inc(Result);
          shot_splash, shot_torpedo, shot_missile: Inc(Result, 2);
          shot_area_damage: Inc(Result, 5);
        end;
    end;
    if Ship is TKling then
      case (Ship as TKling).KlingType of
        dominator_bertor: Inc(Result, 12);
        dominator_klig: Inc(Result, 3);
      end;
  end;
  // @nested $5A77CC ProjectOutsideStar
  function ProjectOutsideStar(Point: TPointF): TPointF; // @addr $5A77CC
  var
    RadialValue: Single; // Squared distance, then the outward projection scale.
    Attempts: Integer;
    Radius: Single;
  begin
    RadialValue := Sqr(Point.X) + Sqr(Point.Y);
    Radius := CurrentStar.SafeRadius;
    Attempts := 0;
    if RadialValue < 0.1 then begin
      while True do begin
        Result.X := NextRandomIntRange(Round(-1.3 * Radius), Round(1.3 * Radius), RandomState);
        Result.Y := NextRandomIntRange(Round(-1.3 * Radius), Round(1.3 * Radius), RandomState);
        if Sqr(Result.X) + Sqr(Result.Y) > Sqr(Radius) then Break;
        Inc(Attempts);
        if Attempts > 100 then Exit;
      end;
    end else if Sqr(Radius) >= RadialValue then begin
      RadialValue := (Radius + 1) / Sqrt(RadialValue);
      Result.X := Point.X * RadialValue;
      Result.Y := Point.Y * RadialValue;
    end else Result := Point;
  end;
  // @nested $5A7938 EvaluatePosition
  function EvaluatePosition(Point: TPointF): Single; // @addr $5A7938
  var Ship: TShip; AttackPotential, SupportPotential, IncomingStrength, NodeValue, Benefit, Risk, Threat, BestEnemyPotential: Single;
    Distance, HookRange: Single; Minimum, Maximum: Integer; ShipDistance, Attack: Single; I: Integer; Item: TItem;
  begin
    AttackPotential := 0;
    SupportPotential := 0;
    IncomingStrength := 0;
    NodeValue := 0;
    BestEnemyPotential := 0;
    for I := 0 to Enemies.Count - 1 do begin
      Ship := Enemies[I];
      GetWeaponRangeBounds(Ship, Minimum, Maximum);
      ShipDistance := PointDistance(Point, Ship.Position);
      Attack := Ship.CalculateAttackStrength * (1 + AreaWeaponScore(Ship) * (0.1 * RemapClamped(SupportWeight, 0, 2, 0.1, 1)));
      Threat := Attack * RemapClamped(ShipDistance, Minimum, Maximum, 1, 0);
      if Attack * 0.99 > Threat then Threat := Threat + (Attack - Threat) * Ship.Speed / (Ship.Speed + ShipDistance - Minimum);
      if Ship.OrderTarget = Self then Threat := Threat * RemapClamped(Speed / Max(1, Ship.Speed), 0.5, 1, 0, 1);
      IncomingStrength := IncomingStrength + Threat;
      Threat := Attack * RemapClamped(ShipDistance, OwnMinRange, OwnMaxRange, 1, 0);
      if Attack * 0.99 > Threat then Threat := Threat + (Attack - Threat) * Speed / (Speed + ShipDistance - OwnMinRange);
      Threat := Threat / (Max(OwnAttack, Ship.CalculateDefenseStrength) *
        (1 + Ship.GetRepairStrengthFactor * (0.1 * RemapClamped(SupportWeight, 0, 2, 1, 0.1))));
      if (Ship is TKling) and ((Ship as TKling).KlingType = dominator_bertor) then Threat := 1.5 * Threat;
      if Threat > BestEnemyPotential then BestEnemyPotential := Threat;
      AttackPotential := AttackPotential + 0.1 * Threat;
    end;
    AttackPotential := AttackPotential + BestEnemyPotential;
    for I := 0 to Allies.Count - 1 do begin
      Ship := Allies[I];
      GetWeaponRangeBounds(Ship, Minimum, Maximum);
      ShipDistance := PointDistance(Point, Ship.Position);
      Attack := Ship.CalculateAttackStrength;
      SupportPotential := SupportPotential + Attack * RemapClamped(ShipDistance, OwnMinRange, OwnMaxRange, 1, 0) / Max(OwnAttack, Ship.CalculateDefenseStrength);
      Threat := Attack * RemapClamped(ShipDistance, Minimum, Maximum, 1, 0);
      Attack := Attack - Threat;
      if Attack > Threat * 0.01 then Threat := Threat + Attack * Ship.Speed / (Ship.Speed + ShipDistance - Minimum);
      IncomingStrength := IncomingStrength - 0.5 * Threat;
    end;
    if GetCargoHook <> nil then
      for I := 0 to CurrentStar.Items.Count - 1 do begin
        Item := CurrentStar.Items[I];
        if not (Item is TProtoplasm) then Continue;
        if not CanCargoHookHandleItem(Item, Self) then Continue;
        if IsItemInPickupRange(Item) then Continue;
        Distance := Sqrt(Sqr(Point.X - Item.Position.X) + Sqr(Point.Y - Item.Position.Y));
        HookRange := GetCargoHookRange;
        if Distance <= HookRange then NodeValue := NodeValue + Min((Item as TProtoplasm).StackCount, CargoFreeSpace)
        else NodeValue := NodeValue + Min((Item as TProtoplasm).StackCount, CargoFreeSpace) * RemapClamped(Distance, GetCargoHookRange, 2 * GetCargoHookRange, 0.5, 0);
      end;
    if PilotRace <> owner_feyan then NodeValue := NodeValue * 2;
    if EnemiesInRange > 0 then begin
      Benefit := AttackPotential * AttackWeight + 0.05 * NodeValue + SupportPotential * SupportWeight;
      Risk := IncomingStrength / OwnDefense * FearWeight;
    end else begin
      Benefit := AttackPotential * AttackWeight + 0.05 * NodeValue;
      Risk := 0;
    end;
    Distance := Sqrt(Sqr(Point.X) + Sqr(Point.Y));
    Benefit := Benefit * RemapClamped(Distance, CurrentStar.MapDiameter * 0.7, CurrentStar.MapDiameter * 1.2, 1, 0.5);
    if Distance > CurrentStar.MapDiameter * 1.2 then Benefit := CurrentStar.MapDiameter * Benefit * 1.2 / Distance;
    Result := Benefit - Risk;
  end;
  // @nested $5A8124 BoostWithNodes
  procedure BoostWithNodes; // @addr $5A8124
  var Factor: Single;
  begin
    if (PilotRace in [owner_maloc, owner_human, owner_gaal]) and (EnemiesInRange > 0) then begin
      Factor := RemapClamped(CargoFreeSpace, 0, GetHull.Weight div 4, 0.5, 1) * (3 / (EnemiesInRange + 2)) *
        RemapClamped(GetHull.HullPoints, 0, GetHull.Weight div 2, 0.1, 1);
      while (50 - 90 * Factor > GetCombatStatusStrength(combat_effect_node_boost)) and (GetCarriedNodeCount >= Int64(50)) do begin
        ConsumeNodes(50);
        AddCombatStatusStrength(combat_effect_node_boost, 20, nil);
      end;
      RefreshDerivedStats(True);
    end;
  end;
begin
  if HasNoUsableWeapons then begin EngageEnemyShip; Exit; end;
  Enemies := TList.Create;
  Allies := TList.Create;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship <> Self) and Ship.InNormalSpace then
      if GetRelationLevelToShip(Ship) <= relation_level_hostile then Enemies.Add(Ship)
      else if (GetRelationLevelToShip(Ship) > relation_level_normal) and
        ((Ship is TWarrior) or ((Ship.EnemyShip <> nil) and (GetRelationLevelToShip(Ship.EnemyShip) <= relation_level_hostile))) then Allies.Add(Ship);
  end;
  GetWeaponRangeBounds(Self, OwnMinRange, OwnMaxRange);
  OwnAttack := CalculateAttackStrength;
  OwnDefense := CalculateDefenseStrength;
  if (Enemies.Count <= 2) or (Allies.Count <= 0) or (OwnMaxRange < 300) then begin
    Enemies.Free;
    Allies.Free;
    EngageEnemyShip;
    Exit;
  end;
  EnemyAreaScore := 0;
  AllyAreaScore := AreaWeaponScore(Self);
  EnemyRepair := 0;
  AllyRepair := GetRepairStrengthFactor;
  EnemiesInRange := 0;
  for I := 0 to Enemies.Count - 1 do begin
    Ship := Enemies[I];
    Inc(EnemyAreaScore, AreaWeaponScore(Ship));
    EnemyRepair := EnemyRepair + Ship.GetRepairStrengthFactor;
    if PointDistanceSquared(Position, Ship.Position) < Sqr(OwnMaxRange) then Inc(EnemiesInRange);
  end;
  for I := 0 to Allies.Count - 1 do begin
    Ship := Allies[I];
    Inc(AllyAreaScore, AreaWeaponScore(Ship));
    AllyRepair := AllyRepair + Ship.GetRepairStrengthFactor;
  end;
  BoostWithNodes;
  AttackWeight := 1;
  SupportWeight := RemapClamped(AllyAreaScore * EnemyRepair - EnemyAreaScore * AllyRepair, -100, 100, -2, 2);
  FearWeight := RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, 2, 0.75);
  BestShip := nil;
  BestShipScore := 0;
  for I := 0 to Allies.Count - 1 do begin
    Ship := Allies[I];
    Score := EvaluatePosition(Ship.Position) / (Trunc(PointDistance(Ship.Position, Position) / (Speed + 1)) + 1);
    if (Score > BestShipScore) or (BestShip = nil) then begin BestShipScore := Score; BestShip := Ship; end;
  end;
  for I := 0 to Enemies.Count - 1 do begin
    Ship := Enemies[I];
    Score := EvaluatePosition(Ship.Position) / (Trunc(PointDistance(Ship.Position, Position) / (Speed + 1)) + 1);
    if (Score > BestShipScore) or (BestShip = nil) then begin BestShipScore := Score; BestShip := Ship; end;
  end;
  RandomDistance := NextRandomIntRange(Speed div 3, Speed, RandomState);
  Angle := NextRandomIntRange(0, 360, RandomState);
  Destination.X := Cos(HeadingDegreesToRadians(Angle)) * RandomDistance + Position.X;
  Destination.Y := Sin(HeadingDegreesToRadians(Angle)) * RandomDistance + Position.Y;
  Destination := ProjectOutsideStar(Destination);
  BestPositionScore := EvaluatePosition(Destination);
  for I := 1 to 40 do begin
    RandomDistance := NextRandomIntRange(Speed div 3, Speed, RandomState);
    Angle := NextRandomIntRange(0, 360, RandomState);
    Candidate.X := Cos(HeadingDegreesToRadians(Angle)) * RandomDistance + Position.X;
    Candidate.Y := Sin(HeadingDegreesToRadians(Angle)) * RandomDistance + Position.Y;
    Candidate := ProjectOutsideStar(Candidate);
    Score := EvaluatePosition(Candidate) / (Trunc(PointDistance(Candidate, Position) / (Speed + 1)) + 1);
    if Score > BestPositionScore then begin BestPositionScore := Score; Destination := Candidate; end;
  end;
  Enemies.Free;
  Allies.Free;
  if (BestShip <> nil) and (BestShipScore >= BestPositionScore) then
    if GetRelationLevelToShip(BestShip) > relation_level_hostile then OrderFollowShip(BestShip, follow_close, False) else OrderFollowShip(BestShip, follow_min_weapon_range, False)
  else OrderMove(Destination, False);
end;
{ @end $5A827C }

{ @routine $5A8868 TWarrior_ReassignFlagshipHomePlanet }
procedure TWarrior.ReassignFlagshipHomePlanet;
var Score, BestScore: Single; Planet, BestPlanet: TPlanet; Star, NearbyStar, BestStar: TStar;
  I, J, K: Integer; FlagshipFactor, GarrisonStrength, NearbyThreat: Single; Ship: TShip; Warrior: TWarrior;
  RacePlanetCount, WarriorCount, StationCount: Integer;
begin
  BestScore := 0;
  BestStar := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if (Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = '') and (Star.ConstellationGraphIndex <> 20) then begin
      FlagshipFactor := 1;
      GarrisonStrength := 0;
      RacePlanetCount := 0;
      StationCount := 0;
      for J := 0 to Star.Ships.Count - 1 do begin
        Ship := Star.Ships[J];
        if (Ship.TypeId in [station_ranger_center..station_custom]) and (Ship.CurrentStanding in NonTargetableStationStandingMasks[faction_coalition]) then Inc(StationCount);
      end;
      for J := 0 to Star.Planets.Count - 1 do begin
        Planet := Star.Planets[J];
        if not (Planet.OwnerId in PlanetOwnerMasks.Coalition) then Continue;
        if Planet.RaceId = PilotRace then Inc(RacePlanetCount);
        for K := 0 to Planet.Warriors.Count - 1 do begin
          Warrior := Planet.Warriors[K];
          if Warrior = Self then Continue;
          GarrisonStrength := GarrisonStrength + RemapClamped(Warrior.Strength, 0.1 * Strength, 10 * Strength, 0.3, 3);
          if Warrior.WarriorType = warrior_flagship then
            if Warrior.PilotRace = PilotRace then FlagshipFactor := FlagshipFactor * 0.05
            else FlagshipFactor := FlagshipFactor * 0.2;
        end;
      end;
      if (GarrisonStrength <> 0) and (RacePlanetCount <> 0) then begin
        NearbyThreat := 0;
        for J := 1 to Galaxy.Stars.Count div 5 do begin
          NearbyStar := Star.StarDistances[J].Star as TStar;
          if NearbyStar.ConstellationGraphIndex <> 20 then
            if NearbyStar.Status.CustomFaction <> '' then NearbyThreat := NearbyThreat + 5 / (J + 5)
            else case NearbyStar.ControlFaction of
              faction_coalition: ;
              faction_pirates: NearbyThreat := NearbyThreat + 1 / (J + 5);
              faction_dominators: NearbyThreat := NearbyThreat + 5 / (J + 5);
            end;
        end;
        Score := RacePlanetCount * GarrisonStrength * NearbyThreat * FlagshipFactor * (StationCount + 3);
        if HomePlanet.CurrentStar = Star then Score := Score * 1.3;
        if (Score > BestScore) or (BestStar = nil) then begin BestScore := Score; BestStar := Star; end;
      end;
    end;
  end;
  if BestStar <> nil then begin
    BestScore := 0;
    BestPlanet := nil;
    for I := 0 to BestStar.Planets.Count - 1 do begin
      Planet := BestStar.Planets[I];
      if not (Planet.OwnerId in PlanetOwnerMasks.Coalition) or (Planet.RaceId <> PilotRace) then Continue;
      WarriorCount := 0;
      FlagshipFactor := 1;
      for K := 0 to Planet.Warriors.Count - 1 do begin
        Warrior := Planet.Warriors[K];
        if Warrior <> Self then begin
          Inc(WarriorCount);
          if Warrior.WarriorType = warrior_flagship then FlagshipFactor := FlagshipFactor * 0.1;
        end;
      end;
      Score := WarriorCount * FlagshipFactor;
      if HomePlanet = Planet then Score := Score * 1.3;
      if (Score > BestScore) or (BestPlanet = nil) then begin BestScore := Score; BestPlanet := Planet; end;
    end;
    if BestPlanet <> nil then
      if HomePlanet <> BestPlanet then begin
        I := HomePlanet.Warriors.IndexOf(Self);
        if I >= 0 then HomePlanet.Warriors.Delete(I);
        I := BestPlanet.Warriors.IndexOf(Self);
        if I < 0 then BestPlanet.Warriors.Add(Self);
        HomePlanet := BestPlanet;
      end;
  end;
end;
{ @end $5A8868 }

{ @routine $5A8DCC TWarrior_ProcessCombatDialogue }
procedure TWarrior.ProcessCombatDialogue;
begin end;
{ @end $5A8DCC }

{ @routine $5A8DD0 TWarrior_ReactToExtortionDemand }
procedure TWarrior.ReactToExtortionDemand(Ranger: Pointer);
begin
  if (GetPlayer = Ranger) or (NextRandomUnitFloat(RandomState) < 0.05) then begin
    HomePlanet.ChangeRelationToRanger(Ranger, -5);
    (TObject(Ranger) as TRanger).AddPirateCareerActivity(4);
  end;
end;
{ @end $5A8DD0 }

{ @routine $5A8E2C TWarrior_BuildMoneyExtortionResponse }
function TWarrior.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
begin
  Result := False;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := OtherShip;
  Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $5A8E2C }

{ @routine $5A8F2C TWarrior_BuildCargoExtortionResponse }
function TWarrior.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := OtherShip;
  Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $5A8F2C }

{ @routine $5A9218 TWarrior_BuildTrucePaymentResponse }
function TWarrior.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $5A9028 AcceptPayment
  procedure AcceptPayment; // @addr $5A9028 @note "Nested helper with caller-popped static link."
  var I, J: Integer; Ship: TShip; Planet: TPlanet; Weapon: TWeapon;
  begin
    OtherShip.SetMoney(OtherShip.Money - OfferedAmount);
    SetMoney(Money + OfferedAmount);
    TruceWithShip(OtherShip);
    if OtherShip is TNormalShip then TNormalShip(OtherShip).CurrentSystemKills.Normal := 0;
    if OtherShip is TRanger then begin
      (OtherShip as TRanger).AddTraderCareerActivity(1);
      Planet := HomePlanet;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if (Ship is TWarrior) and ((Ship as TWarrior).HomePlanet = Planet) and (Self <> Ship) then begin
          if OtherShip = Ship.EnemyShip then Ship.EnemyShip := nil;
          for J := 1 to Ship.WeaponCount do begin
            Weapon := Ship.Weapons[J];
            if OtherShip = Weapon.Target then Weapon.Target := nil;
          end;
          // Native repeats this check after clearing weapon targets.
          if OtherShip = Ship.EnemyShip then Ship.EnemyShip := nil;
          if OtherShip.EnemyShip = Ship then OtherShip.EnemyShip := nil;
          Ship.ChangeRelationToRanger(OtherShip, 30);
          if (Ship.Order = order_follow_ship) and ((Ship.OrderTarget as TShip) = OtherShip) then begin
            Ship.OrderNone(False);
            Ship.NextDay;
          end;
        end;
      end;
    end;
  end;
begin
  Result := False;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if RefusesFactionNegotiation(OtherShip) then begin
    Response := LookupVisibleTalkText('Talk.Refuse.Warrior', OtherShip); Result := False;
    Exit;
  end;
  if OtherShip.TruceShip = Self then begin
    Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip);
    Exit;
  end;
  if (GetPlayer = OtherShip) and PlayerExtortionPactActive then begin
    Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip);
    Exit;
  end;
  if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then begin
    Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip);
    Exit;
  end;
  if (OtherShip is TNormalShip) and (OtherShip.OwnerId = owner_pirate) and (OtherShip.CurrentStar.ControlFaction = faction_coalition) and
    (TNormalShip(OtherShip).CurrentSystemKills.Normal > 0) then begin
    if 2 * Wealth * (1 / 15) < OfferedAmount then begin
      Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
      AcceptPayment;
      Result := True;
    end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
    Exit;
  end;
  if Wealth * (1 / 15) < OfferedAmount then begin
    Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptPayment;
    Result := True;
    Exit;
  end;
  Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip)
end;
{ @end $5A9218 }

{ @routine $5A9690 TWarrior_BuildAttackRequestResponse }
function TWarrior.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
var I, HostileCount: Integer; Ship: TShip;
  // @nested $5A95B8 AcceptRequest
  procedure AcceptRequest; // @addr $5A95B8 @note "Nested helper with caller-popped static link."
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
  HostileCount := 0;
  if WarriorType = warrior_flagship then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship = Self) or not Ship.InNormalSpace then Continue;
      if GetRelationLevelToShip(Ship) <= relation_level_hostile then Inc(HostileCount);
      if HostileCount > 1 then Break;
    end;
  if (OrderTarget = Target) and (GetRelationLevelToShip(Target) = relation_level_hostile) and (HostileCount <= 1) then AcceptRequest
  else if (LiberationGroup <> nil) and (Requester.LiberationGroup <> LiberationGroup) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else if TruceShip = Target then Response := FormatText1(LookupVisibleTalkText('Talk.Attack.WeAlreadyHavePact', Requester), TextHighlightColorTag, '<Target>', Target.GetName)
  else if RelationToShip(Target) >= RelationNormalMin then begin
    if not (Target is TTranclucator) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriends', Requester)
    else if TTranclucator(Target).OwnerShip = Self then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsMyTranc', Requester)
    else if TTranclucator(Target).OwnerShip = Requester then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsYourTranc', Requester)
    else Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriendsTranc', Requester);
  end else if AcceptsRansomDemandFrom(Target) or RecomputeFearState then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Fear', Requester)
  else if not TrustsAttackRequester(Requester) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Suspect', Requester)
  else if HasLockedOrFollowOrder and (Requester is TNormalShip) and ((Requester as TNormalShip).Rank < Rank) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else if HostileCount > 0 then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else AcceptRequest;
end;
{ @end $5A9690 }

{ @routine $5A9D00 TWarrior_AcceptPartnershipOffer }
function TWarrior.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin Result := False; Response := 'Not supporting'; end;
{ @end $5A9D00 }

{ @routine $5A9D44 TWarrior_BuildPartnershipOfferResponse }
function TWarrior.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin Result := False; Response := 'Not supporting'; end;
{ @end $5A9D44 }

{ @routine $5A9D88 TWarrior_MoveToRandomPlanetOrbit }
procedure TWarrior.MoveToRandomPlanetOrbit;
var Planet: TPlanet; Polar: TPolarPoint;
begin
  Planet := CurrentStar.Planets[0];
  Polar := Planet.Orbit;
  Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $5A9D88 }

{ @routine $5A9DE4 TWarrior_IsHomePatrolTurn }
function TWarrior.IsHomePatrolTurn: Boolean;
begin
  Result := (GetHomeStar = CurrentStar) and ((Integer(Id) + Galaxy.CurrentTurn) mod 100 < 25);
end;
{ @end $5A9DE4 }

{ @routine $5A9E18 TWarrior_ConsumeNodes }
procedure TWarrior.ConsumeNodes(Amount: Integer);
var I, RemainingWeight: Integer; Item: TItem;
begin
  for I := Inventory.Count - 1 downto 1 do begin
    Item := Inventory[I];
    if Item.ItemType = item_nodes then begin
      if Amount < Item.Weight then begin
        RemainingWeight := Item.Weight - Amount;
        Dec((Item as TProtoplasm).StackCount, Amount);
        Item.Cost := Round(Item.Cost / Item.Weight * RemainingWeight);
        Item.Weight := RemainingWeight;
        Amount := 0;
      end else begin
        Dec(Amount, Item.Weight);
        Inventory.Delete(I);
        Item.Free;
      end;
    end;
    if Amount = 0 then Break;
  end;
end;
{ @end $5A9E18 }

{ @routine $5A9EA8 TWarrior_RefusesFactionNegotiation }
function TWarrior.RefusesFactionNegotiation(OtherShip: TShip): Boolean;
begin
  Result := False;
  if OtherShip.CurrentStanding = standing_pirate_military then begin Result := True; Exit; end;
  if ((CurrentStar.ControlFaction <> faction_coalition) or (CurrentStar.Status.CustomFaction <> '')) and
    (OtherShip.CurrentStanding in [standing_pirate_active, standing_pirate_military]) then begin Result := True; Exit; end;
end;
{ @end $5A9EA8 }

{ @routine $5A9EEC TWarrior_AdjustItemEvaluation }
function TWarrior.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
const
  NoFlags = [];
var
  MoneyPenalty, EffectivenessScale, WeightPenalty, FragilityScale: Single;
  Price: Integer;
  DesiredFreeFraction, DesiredMoneyFraction, HullValueScale: Single;
begin
  DesiredMoneyFraction := 0.1;
  FragilityScale := 1.5;
  if Item.ItemType in [item_fuel_tanks, item_radar, item_cargo_hook] then FragilityScale := FragilityScale * 0.5;
  HullValueScale := 2;
  DesiredFreeFraction := Max(0.01, Min(0.99, GetDesiredCargoFreeSpace / Max(100, GetHull.Weight)));
  MoneyPenalty := Sqr((1 / Max(0.01, SmoothedMoneyFraction) - 1) / (1 / DesiredMoneyFraction - 1)) /
    Max(SmoothedWealth * 0.05, 1000);
  EffectivenessScale := 2 / Max(10, SmoothedEquipmentEffectiveness);
  WeightPenalty := Sqr((1 / Max(0.01, SmoothedFreeCapacityFraction) - 1) / (1 / DesiredFreeFraction - 1)) /
    Max(10, GetHull.Weight * 0.1);
  if OwnerId = Item.OwnerId then EffectivenessScale := EffectivenessScale * 1.1;
  MoneyPenalty := MoneyPenalty * 0.01 * (100 + SeededRandomIntRange(-10, 10, Id + Seed));
  EffectivenessScale := EffectivenessScale * 0.01 * (100 + SeededRandomIntRange(-10, 10, Seed + 3 * Id));
  WeightPenalty := WeightPenalty * 0.01 * (100 + SeededRandomIntRange(-10, 10, Seed + 5 * Id));
  if WarriorType = warrior_flagship then EffectivenessScale := 2 * EffectivenessScale;
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
    Result := (HullValueScale * Item.Weight / Max(0.01, TEquipment(Item).GetFragilityFactor(NoFlags)) + Effectiveness) * EffectivenessScale +
      Item.Weight * WeightPenalty - Price * 0.25 * MoneyPenalty;
end;
{ @end $5A9EEC }

{ @routine $5AA410 TWarrior_EvaluateStatBonus }
function TWarrior.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonus_armor: Result := Value * 200;
    bonus_fuel_capacity: Result := (0.5 * Value) * (1 - ShortInt(WarriorType = warrior_flagship) * 0.5);
    bonus_speed: Result := Value * 0.2;
    bonus_jump_range: Result := Value * 5;
    bonus_radar_range: Result := (0.025 * Value) * (1 + ShortInt(WarriorType = warrior_flagship) * 0.5);
    bonus_scanner_power: Result := Value * 3 + Value * 30 * CountWeaponsByDamageFlags(ScannerFlags);
    bonus_repair_points: Result := Value * 10 / Max(0.1, GetHull.GetFragilityFactor(NoFlags)) * (1 + ShortInt(WarriorType = warrior_flagship) * 0.5);
    bonus_hook_power: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.3 * ShortInt(WarriorType = warrior_flagship);
    bonus_defense: Result := Value * 5 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonus_energy_damage: Result := Value * 12;
    bonus_splinter_damage: Result := Value * 12;
    bonus_missile_damage: Result := Value * 12 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9) * (1 - Ord(WarriorType = warrior_flagship));
    bonus_weapon_range: if WarriorType = warrior_flagship then Result := Value * 3 else Result := Value * 1.5 * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonus_hook_range: Result := Value * 1.0 * ShortInt(WarriorType = warrior_flagship);
    bonus_mass: Result := RemapClamped(Value, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 1000;
    bonus_radar_slots:
      if (GetSlotCount(slot_radar) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind] - WarriorSlotBonusWeights[bonus_weapon_slots] * CountMissileWeapons
      else if (GetSlotCount(slot_radar) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonus_scanner_slots:
      if (GetSlotCount(slot_scanner) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * WarriorSlotBonusWeights[bonus_weapon_slots]
      else if (GetSlotCount(slot_scanner) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonus_repair_robot_slots:
      if (GetSlotCount(slot_repair_robot) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(slot_repair_robot) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonus_defense_slots:
      if (GetSlotCount(slot_defense_generator) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(slot_defense_generator) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonus_weapon_slots:
      begin
        if (GetSlotCount(slot_weapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(slot_weapon)) * WarriorSlotBonusWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(slot_weapon)) * WarriorSlotBonusWeights[BonusKind];
        if CountEquippedWeapons > Max(Value + GetSlotCount(slot_weapon), 1) then
          Result := Result - (WarriorSlotBonusWeights[BonusKind] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(slot_weapon)));
      end;
    bonus_afterburner_slots:
      if (GetSlotCount(slot_afterburner) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(slot_afterburner) = 1) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind];
    bonus_accuracy..bonus_leadership:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), Value) * WarriorSkillBonusWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) > 6) then
          Result := Result + (WarriorSkillBonusWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), -Value) * -WarriorSkillBonusWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) < 0) then
          Result := Result + (WarriorSkillBonusWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]));
      end;
  else Result := 0;
  end;
  if BonusKind in [bonus_accuracy..bonus_leadership] then Result := Result * 0.01 * (100 + SeededRandomIntRange(-30, 30, Seed + 131 * Ord(BonusKind))) * RaceSkillEvaluationFactors[PilotRace, EquipmentBonusSkills[BonusKind]]
  else Result := Result * 0.01 * (100 + SeededRandomIntRange(-10, 10, Seed + 131 * Ord(BonusKind)));
end;
{ @end $5AA410 }

{ @routine $5AAEE4 TWarrior_EvaluateWeaponDamage }
function TWarrior.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  ShockFlags = [damage_flag_shock];
  AcidFlags = [damage_flag_acid];
var
  ScannerFactor, StatusFactor: Single;
  Flags: TDamageFlagSet;
  I, ShotTotal: Integer;
  SpeedFactor: Single;
begin
  Flags := Weapon.GetDamageFlags;
  if (Flags * ScannerFlags <> []) and (GetScanner <> nil) and (GetRadar <> nil) then
    ScannerFactor := RemapClamped(GetScannerPower - DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(Galaxy.TechLevel)) + 1, -5, 10, 0.1, 2)
  else ScannerFactor := 0;
  Result := BaseDamage * GetWeaponArtefactDamageFactor(Weapon);
  if damage_flag_life_steal in Flags then Result := Result * (1.5 - ShortInt(WarriorType = warrior_flagship) * 0.4);
  if damage_flag_shock in Flags then Result := Result * (1.05 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  if damage_flag_acid in Flags then Result := Result * 1.05;
  StatusFactor := 1;
  if damage_flag_scanner_bonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if damage_flag_bonus_to_damaged_hull in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if damage_flag_weapon_block in Flags then Result := Result + ScannerFactor * 5;
    if damage_flag_droid_block in Flags then Result := Result + ScannerFactor * 5;
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if damage_flag_acid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case Weapon.GetWeaponInfo.ShotType of
    shot_rocket: Result := Result * 1.1 * Weapon.GetShotCount * (1 + StatusFactor);
    shot_missile: Result := Result * (1.1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    shot_torpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 + StatusFactor);
    shot_chain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    shot_splash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.5 * 0.01 * SpeedFactor + StatusFactor);
    shot_explode_on_kill: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.8 * 0.01 * SpeedFactor + StatusFactor);
    shot_area_damage: Result := Result * (1 + Weapon.Range * 2.2 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
end;
{ @end $5AAEE4 }

{ @routine $5AB42C TWarrior_AcceptPickupItem }
function TWarrior.AcceptPickupItem(Item: TItem): Boolean;
begin
  Result := False;
  if WarriorType = warrior_flagship then begin
    if (Item.ItemType = item_nodes) and (CargoFreeSpace > 0) then begin Result := True; Exit; end
    else if (PilotRace in [owner_peleng..owner_feyan]) and (Item is TUselessItem) then
      if (Item as TUselessItem).IsDominatorRemains then begin Result := True; Exit; end;
  end;
end;
{ @end $5AB42C }

{ @routine $5AB48C TWarrior_AcceptPickupDistance }
function TWarrior.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  if Speed < 1 then begin Result := False; Exit; end;
  Result := (30 * Speed >= Distance) or
    (Item.Cost >= RemapClamped(Distance / Speed, 1, 10, 0.01, 0.05) * Wealth);
end;
{ @end $5AB48C }

{ @routine $5AB518 TWarrior_RefreshCurrentStanding }
procedure TWarrior.RefreshCurrentStanding;
var StandingMode: TStandingOverride;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = override_custom_faction then CurrentStanding := standing_custom
  else if StandingMode <> override_fixed then CurrentStanding := standing_coalition_military;
end;
{ @end $5AB518 }

end.
