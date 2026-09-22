unit aWarrior;
// Unit bracket (inferred): .text 0x005175C8..0x00520E39; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Struct, EC_BlockPar, EC_Buf, aItem, aShip, aConst, aGalaxy, aGalaxyStruct, aNormalShip, aPlanet;

const
  // BuyWarrior / BuyFlagship and GetDefaultHullType distinguish these subtypes.
  wtRegular = 0;
  wtFlagship = 1;

type
  TWarrior = class(TNormalShip) // @size 0x514
  public
    WarriorType: Byte; // @offset 0x510  wtRegular / wtFlagship; exposed as Script.ShipSubType.

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $00518304 @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $00518330 @slot $04
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr $0051F580 @slot $50
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $0051FB14 @slot $54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr $00520788 @slot $58
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $00519C7C @slot $60
    procedure BuildReachablePlanetQueue; override; // @addr $00519B50 @slot $64
    procedure SelectEnemyShipInStar; override; // @addr $0051C208 @slot $6C
    procedure EngageEnemyShip; override; // @addr $0051C750 @slot $70
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $0051A33C @slot $74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $0051A384 @slot $78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $0051A4E8 @slot $7C
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $0051A22C @slot $80
    function RecomputeFearState: Boolean; override; // @addr $0051A5C0 @slot $84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $0051A72C @slot $88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $0051A7C8 @slot $8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $0051A7EC @slot $90
    function AcceptPickupItem(Item: TItem): Boolean; override; // @addr $00520CE8 @slot $94
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; override; // @addr $00520D64 @slot $98
    procedure ProcessCombatDialogue; override; // @addr $0051E2F8 @slot $A0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $0051E304 @slot $A4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $0051E370 @slot $A8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $0051E48C @slot $AC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $0051E7CC @slot $B0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $0051EC5C @slot $B4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $0051F300 @slot $B8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $0051F350 @slot $BC
    function RefusesFactionNegotiation(OtherShip: TShip): Boolean; override; // @addr $0051F524 @slot $C0
    procedure RefreshCurrentStanding; override; // @addr $00520E00 @slot $C4
    destructor Destroy; override; // @addr $5176F0
    function FindNearestFriendlyFlagship: TShip; // @addr $51C124
    function NavigateToHomePlanet: Boolean; // @addr $519A4C
    procedure ProcessUnseenProgression; // @addr $51A094
    procedure MoveToRandomPlanetOrbit; // @addr $51F3A0
    procedure ConsumeNodes(Amount: Integer); // @addr $51F450

    procedure InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: Byte); // @addr 0x517804 @note "Sets location, money and WarriorType; registers the ship with its star and home garrison."

    procedure NextDay; override; // @addr 0x51837C @slot 0x18
    procedure NextDayLogic; override; // @addr 0x5185F0 @slot 0x1C @calls "0x51846C"
    procedure ManeuverFlagship; // @addr $51D714
    procedure NextDayFlagshipLogic; // @addr 0x519250 @note "Flagship branch; its diagnostic retains TWarrior.NextDayLogic."
    procedure AssignWeaponTargetsInStar; override; // @addr 0x51A888 @slot 0x20 @note "Native diagnostic name: TWarrior.ArmsToTarget."
    procedure AssignFlagshipWeaponTargets; // @addr 0x51B778 @note "Flagship branch; shares the TWarrior.ArmsToTarget diagnostic."
    function GetTypeNameKey: WideString; override; // @addr $519FDC @slot $2C
    function GetGreetingShipCategory: Byte; override; // @addr $51A010 @slot $30
    function GetHomeStar: TStar; override; // @addr $519D58 @slot $34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $51A038 @slot $3C
    function GetDominantCareer: TRangerCareer; override; // @addr 0x51A024 @slot 0x38 @note "Always rcWarrior."
    function GetName: WideString; override; // @addr 0x519D74 @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x519D94 @slot 0x28

    procedure ReassignFlagshipHomePlanet; // @addr $51DD8C Scores Coalition systems and same-race garrisons; moves the flagship between home rosters without changing its current position.
    procedure MoveToRandomPatrolPoint; // @addr 0x519C1C
    function IsHomePatrolTurn: Boolean; // @addr 0x51F408 @note "Requires the home system and (Id + CurrentTurn) mod 100 < 25."
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x51A04C @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x51A064 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x519BEC @slot 0x68 @note "AI ownership check only; does not test travel range."
  end;

const
  WarriorSkillBonusWeights: array[bonSkill1..bonSkill6] of Integer = (100, 100, 80, 10, 10, 10); // @addr $87AD50
  // EvaluateStatBonus dispatches bonus kinds 13..20 to these slot cases.
  WarriorSlotBonusWeights: array[bonSlotRadar..bonSlotForsage] of Integer = (80, 80, 200, 0, 200, 150, 0, 10); // @addr $87AD68 @indexrefs "$52000A,$52004A,$52008A,$5200BB,$520117,$520157,$520188,$5201B7,$5201F5,$520226,$520255,$520293,$5202EF,$520339,$5203D0,$520406,$520436"

implementation

uses aKling, aAsteroid, aMissile, aScript, aEFilm, SE_Weapon, SE_Space, aPirate, EC_Struct, Classes, Math, Windows, SysUtils, aRanger, aTranclucator, aRuins, GR_Main, Globals, GlobalsV, EC_Str, aItem, aGalaxy, aShip, aConst, aMyFunction;

{ @routine $5176F0 TWarrior_Destroy }
destructor TWarrior.Destroy;
var Index: Integer;
begin
  Index := HomePlanet.Warriors.IndexOf(Self);
  if Index >= 0 then HomePlanet.Warriors.Delete(Index);
  inherited;
end;
{ @end $5176F0 }

{ @routine $517804 TWarrior_InitGenerated }
procedure TWarrior.InitGenerated(Planet: TPlanet; InitialMoney: Integer; Kind: Byte);
var FirstNameIndex, LastNameIndex: Integer; Ranger: TRanger; TechLevel: Byte; Config: TBlockParEC; Weapon: TWeapon;
  // @nested $517754 SelectTechLevel
  function SelectTechLevel(Minimum, Maximum: Integer): Integer; // @addr $517754 @note "Nested helper with caller-popped static link."
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
  TypeId := stWarrior;
  WarriorType := Kind;
  if WarriorType = wtFlagship then Dec(Galaxy.RangerSpawnQuotas[PilotRace]);
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
    Name := Config.GetParamValue(NextRandomIntRange(LastNameIndex, FirstNameIndex, RandomState)) + ' ' + '-' + IntToStr(Cardinal(Id) mod 100 + 1) + '-';
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
    Name := Config.GetParamValue(NextRandomIntRange(LastNameIndex, FirstNameIndex, RandomState)) + ' ' + '-' + IntToStr(Cardinal(Id) mod 100 + 1) + '-';
  end;
  if GetPlayer <> nil then begin
    Rank := NextRandomIntRange(0, Min(5, GetPlayer.Rank + 2), RandomState);
    if Rank > 5 then Rank := 5;
    if WarriorType = wtFlagship then begin Inc(Rank); if Rank < 4 then Rank := 4; end;
    AddRankPoints(NextRandomIntRange(0, CoalitionRankPointThresholds[Rank] div 2, RandomState));
    if not Galaxy.IsZeroStartingExperienceEnabled then begin
      GainExperience(Round(RemapClamped(Ord(Rank), 0, 1000, TotalSkillTrainingCost div 6, TotalSkillTrainingCost div 2)), 0);
      GainExperience(Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, NextRandomIntRange(0, TotalSkillTrainingCost div 2, RandomState))), 0);
    end;
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  Ranger := Galaxy.StrongestRanger as TRanger;
  if Ranger = nil then TechLevel := 4 else TechLevel := Ranger.GetHull.TechLevel;
  if WarriorType = wtFlagship then begin
    CreateAndEquipHull(Round(3 * HullBaseSize * EquipmentSizeFactors[5]), SelectTechLevel(3, 8), RaceToOwner(PilotRace), -1, False);
    CreateAndEquipFuelTanks(Round(2 * FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
    CreateAndEquipEngine(Round(2 * EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
    if GetSlotCount(sskWeapon) > WeaponCount then begin
      Weapon := CreateAndEquipWeapon(t_Weapon3, 2 * WeaponInfos[t_Weapon3].AverageSize, 1, OwnerId);
      Weapon.DetailImprovement := 3;
      Weapon.Improve(ikAny);
    end;
    if GetSlotCount(sskWeapon) > WeaponCount then begin
      Weapon := CreateAndEquipWeapon(t_Weapon3, 2 * WeaponInfos[t_Weapon3].AverageSize, 1, OwnerId);
      Weapon.DetailImprovement := 3;
      Weapon.Improve(ikAny);
    end;
    if GetSlotCount(sskWeapon) > WeaponCount then begin
      Weapon := CreateAndEquipWeapon(t_Weapon3, 2 * WeaponInfos[t_Weapon3].AverageSize, 1, OwnerId);
      Weapon.DetailImprovement := 3;
      Weapon.Improve(ikAny);
    end;
    if GetSlotCountForItemType(t_Radar) > 0 then CreateAndEquipRadar(Round(2 * RadarBaseSize * EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)]), 1, OwnerId);
    if GetSlotCountForItemType(t_Scaner) > 0 then CreateAndEquipScanner(Round(2 * ScannerBaseSize * EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)]), 1, OwnerId);
  end else begin
    CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), Min(TechLevel, SelectTechLevel(1, 6)), RaceToOwner(PilotRace), SelectRandomHullSeries, False);
    CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
    CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
    if GetSlotCount(sskWeapon) > WeaponCount then CreateAndEquipWeapon(t_Weapon1, WeaponInfos[t_Weapon1].AverageSize, 1, OwnerId);
    if GetSlotCount(sskWeapon) > WeaponCount then CreateAndEquipWeapon(t_Weapon3, WeaponInfos[t_Weapon3].AverageSize, 1, OwnerId);
    if GetSlotCountForItemType(t_Radar) > 0 then CreateAndEquipRadar(Round(EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)] * RadarBaseSize), 1, OwnerId);
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
  if WarriorType = wtFlagship then begin
    BuyEquipmentAtLocation(True);
    BuyEquipmentAtLocation(True);
    BuyEquipmentAtLocation(True);
  end;
end;
{ @end $517804 }

{ @routine $518304 TWarrior_SaveToBuffer }
procedure TWarrior.SaveToBuffer(Buffer: TBufEC);
begin
  inherited;
  Buffer.AddAnsiChar(AnsiChar(WarriorType));
end;
{ @end $518304 }

{ @routine $518330 TWarrior_LoadFromBuffer }
procedure TWarrior.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited;
  if LoadedSaveVersion >= 130 then WarriorType := Buffer.GetByte
  else WarriorType := wtRegular;
end;
{ @end $518330 }

{ @routine $51837C TWarrior_NextDay }
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
    if WarriorType = wtFlagship then SetMoney(Money + Max(1000, Min(5000, Galaxy.MaxRangerWealth div 15)));
    NextDayLogic;
    if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.NextDay ' + GetFullName(' '));
    end;
  end;
end;
{ @end $51837C }

{ @routine $5185F0 TWarrior_NextDayLogic }
procedure TWarrior.NextDayLogic;
const FriendlyStationMask = [2,3];
var Planet: TPlanet; Station: TShip; Stage: Integer;
begin
  Stage := 0;
  if WarriorType = wtFlagship then NextDayFlagshipLogic
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
      if not (DockedTo.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) then begin
        if DockedTo.InNormalSpace then OrderTakeoff else OrderNone(False);
        Exit;
      end;
      begin
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
        if (DockedTo.TypeId = Byte(rstMilitaryBase)) and (TRuins(DockedTo).FlyToStar <> nil) and (TRuins(DockedTo).FlyToStar <> DockedTo.CurrentStar) then Exit;
        if DockedTo.InNormalSpace then OrderTakeoff;
        Stage := 7;
      end;
    end else if InNormalSpace then begin
      Stage := 8;
      RecomputeFearState;
      AssignWeaponTargetsInStar;
      AfterburnerActive := False;
      Stage := 9;
      if InFear then begin
        Stage := 10;
        if (Order = soLand) or (Order = soJump) then UpdateAfterburnerState;
        if Order <> soLand then begin
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
              if Order = soNone then MoveToRandomPatrolPoint;
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
          if Order = soNone then
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
          if (Order = soNone) and not NavigateToHomePlanet then MoveToRandomPatrolPoint;
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
{ @end $5185F0 }

{ @routine $519250 TWarrior_NextDayFlagshipLogic }
procedure TWarrior.NextDayFlagshipLogic;
const FriendlyStationMask = [2,3]; AnyStationMask = [0..15] - [0..15];
var Planet: TPlanet; Station, Ship: TShip; Stations: TList; I, Stage: Integer;
  // @nested $518C80 RepairHullWithNodes
  procedure RepairHullWithNodes; // @addr $518C80
  var Needed, Available, Restored: Integer; Fraction: Single; Entry: PEFilmEndEntry; Effect: TWeaponSE;
  begin
    if (PilotRace in [oiMaloc, oiPeleng]) and InFear then begin
      Available := GetCarriedNodeCount;
      if Available > 0 then begin
        Needed := Ceil((GetHull.Weight - GetHull.HullPoints) *
          (GetCombatStatusStrength(cseBWRepairDebuff) * 0.002 + 1) / 10 / 2 * RemapClamped(Galaxy.TechLevel, 2, 8, 5, 1));
        if Needed > 0 then begin
          Available := Min(Needed, Available);
          ConsumeNodes(Available);
          Fraction := Available / Needed;
          Restored := Ceil(RemapClamped(Fraction, 0, 1, 0.01, GetHull.Weight - GetHull.HullPoints));
          Inc(GetHull.HullPoints, Restored);
          AddCombatStatusStrength(cseBWRepairDebuff, Restored / 2, nil);
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
      end;
    end;
  end;
  // @nested $518F6C RepairEquipmentWithNodes
  procedure RepairEquipmentWithNodes; // @addr $518F6C
  var I: Integer; Equipment: TEquipment; NeedsRepair: Boolean; TotalCost, Available, Threshold: Integer; Fraction: Single;
  begin
    if PilotRace in [oiFeyan, oiGaal] then begin
      Available := GetCarriedNodeCount;
      if Available > 0 then begin
        NeedsRepair := False;
        TotalCost := 0;
        Threshold := Round(RemapClamped(CargoFreeSpace, 0, GetHull.Weight div 4, 90, 50));
        for I := 1 to Inventory.Count - 1 do begin
          Equipment := Inventory[I];
          if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and
            CanRepairEquipmentTech(Equipment) and (Equipment.ItemType <> t_Hull) and (Equipment.EquippedFlag <> 0) then begin
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
            if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and
              CanRepairEquipmentTech(Equipment) and (Equipment.ItemType <> t_Hull) and (Equipment.EquippedFlag <> 0) then begin
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
      begin
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
        if Galaxy.FindMilitaryBaseInTransit = DockedTo then Exit;
        if DockedTo.InNormalSpace then OrderTakeoff;
        Stage := 7;
      end;
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
        if (Order = soLand) or (Order = soJump) then UpdateAfterburnerState;
        if Order <> soLand then begin
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
          if Order = soNone then begin
            if NextRandomIntRange(1, 100, RandomState) > 80 then begin
              Station := nil;
              Stations := TList.Create;
              for I := 0 to CurrentStar.Ships.Count - 1 do begin
                Ship := CurrentStar.Ships[I];
                if (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and Ship.CanDock(Self) and (Ship.CurrentStanding in [ssCoalitionMilitary..ssNeutral]) then begin
                  if PointDistanceSquared(Position, Ship.Position) >= Sqr(CalculateSpeed) then Stations.Add(Ship);
                end;
              end;
              if Stations.Count > 0 then Station := Stations[NextRandomIntRange(0, Stations.Count - 1, RandomState)];
              Stations.Free;
              if Station <> nil then OrderLanding(Station, False);
            end;
            if Order = soNone then TryCollectBestFloatingItem(50);
            if (Order = soNone) and IsHomePatrolTurn then MoveToRandomPlanetOrbit;
            if (Order = soNone) and not NavigateToHomePlanet then MoveToRandomPatrolPoint;
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
          if Order = soNone then TryCollectBestFloatingItem(50);
          if Order = soNone then begin
            if NextRandomIntRange(1, 100, RandomState) > 40 then begin
              Station := FindNearestDockableStation(AnyStationMask);
              if Station <> nil then OrderLanding(Station, False);
            end;
            if (Order = soNone) and not NavigateToHomePlanet then MoveToRandomPatrolPoint;
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
{ @end $519250 }

{ @routine $519A4C TWarrior_NavigateToHomePlanet }
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
{ @end $519A4C }

{ @routine $519B50 TWarrior_BuildReachablePlanetQueue }
procedure TWarrior.BuildReachablePlanetQueue;
var I: Integer; Planet: TPlanet;
begin
  ClearPlanetQueue;
  PlanetQueue := TList.Create;
  if (Speed <> 0) and (CurrentStar.Status.CustomFaction = '') then
    for I := 0 to CurrentStar.Planets.Count - 1 do begin
      Planet := CurrentStar.Planets[I];
      if Planet.IsCoalitionOwned then PlanetQueue.Add(Planet);
    end;
end;
{ @end $519B50 }

{ @routine $519BEC TWarrior_CanQueueReachablePlanet }
function TWarrior.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := (Planet.OwnerId <> oiDominator) and (Planet.OwnerId <> oiPirate);
end;
{ @end $519BEC }

{ @routine $519C1C TWarrior_MoveToRandomPatrolPoint }
procedure TWarrior.MoveToRandomPatrolPoint;
var Destination: TPointF;
begin
  Destination.X := NextRandomIntRange(-2000, 2000, RandomState);
  Destination.Y := NextRandomIntRange(-2000, 2000, RandomState);
  OrderMove(Destination, False);
end;
{ @end $519C1C }

{ @routine $519C7C TWarrior_RepairBrokenEquipmentAtLocation }
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
{ @end $519C7C }

{ @routine $519D58 TWarrior_GetHomeStar }
function TWarrior.GetHomeStar: TStar;
begin
  Result := HomePlanet.CurrentStar;
end;
{ @end $519D58 }

{ @routine $519D74 TWarrior_GetName }
function TWarrior.GetName: WideString;
begin
  Result := Name;
end;
{ @end $519D74 }

{ @routine $519D94 TWarrior_GetFullName }
function TWarrior.GetFullName(const Separator: WideString): WideString;
var
  Path, Text: WideString;
begin
  if TypeNameOverrideKey = '' then
  begin
    if WarriorType = wtFlagship then
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
{ @end $519D94 }

{ @routine $519FDC TWarrior_GetTypeNameKey }
function TWarrior.GetTypeNameKey: WideString;
begin
  Result := 'Warrior';
end;
{ @end $519FDC }

{ @routine $51A010 TWarrior_GetGreetingShipCategory }
function TWarrior.GetGreetingShipCategory: Byte;
begin
  Result := gscWarrior;
end;
{ @end $51A010 }

{ @routine $51A024 TWarrior_GetDominantCareer }
function TWarrior.GetDominantCareer: TRangerCareer;
begin
  Result := rcWarrior;
end;
{ @end $51A024 }

{ @routine $51A038 TWarrior_GetStrengthScaledPirateStatus }
function TWarrior.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 0;
end;
{ @end $51A038 }

{ @routine $51A04C TWarrior_GetDesiredCargoFreeSpace }
function TWarrior.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $51A04C }

{ @routine $51A064 TWarrior_RefuelAtLocation }
procedure TWarrior.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $51A064 }

{ @routine $51A094 TWarrior_ProcessUnseenProgression }
procedure TWarrior.ProcessUnseenProgression;
var Award: Byte;
begin
  if (DaysSincePlayerSeen >= 60) and (GetPlayer <> nil) then begin
    if NextRandomUnitFloat(RandomState) < 0.05 then GainExperience(SeededRandomIntRange(100, 500, RandomState), 0);
    if (GetPlayer.Rank > Rank) and (NextRandomUnitFloat(RandomState) < 0.01) and ((Rank < 4) or ((WarriorType = wtFlagship) and (Rank < 6))) then begin
      AddRankPoints(NextRandomIntRange(10, 20, RandomState));
      TryPromoteRank;
    end;
    if (NextRandomUnitFloat(RandomState) < 0.02) and (CurrentPlanet <> nil) and ((AwardIds = nil) or (2 * (Rank + 1) > AwardIds.Count)) then begin
      Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment, atSecretMission], [stKling..Ord(rstCustomStation)]);
      if Award <> AwardNotFound then AddAward(Award);
    end;
  end;
end;
{ @end $51A094 }

{ @routine $51A22C TWarrior_RelationToNonRanger }
function TWarrior.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship.TypeId = stPirate then Result := Round(Max(10, Min(20, OwnerRelations[RaceToOwner(PilotRace), Ship.OwnerId] *
    (0.5 * PlanetRaceMarket[PilotRace].PirateRelationFactor))))
  else if Ship.TypeId in [stKling, stTranclucator] then Result := 50 else Result := 100;
end;
{ @end $51A22C }

{ @routine $51A33C TWarrior_RelationToRanger }
function TWarrior.RelationToRanger(Ranger: Pointer): Byte;
begin Result := Byte(HomePlanet.RangerRelations[Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)]); end;
{ @end $51A33C }

{ @routine $51A384 TWarrior_ChangeRelationToRanger }
procedure TWarrior.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var Relation: Byte; Value, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(HomePlanet.RangerRelations[Index]);
  if (TShip(Ranger).GetEffectiveSkillLevel(psCharisma) > 0) and (Amount > 0) then
    Inc(Amount, Round(Amount * (TShip(Ranger).GetEffectiveSkillLevel(psCharisma)) * 0.2));
  Value := Amount + Relation;
  if Value < 0 then Relation := 0 else if Value > 100 then Relation := 100 else Relation := Value;
  HomePlanet.RangerRelations[Index] := Pointer(Relation);
  if (Relation < 10) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(HomePlanet.RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $51A384 }

{ @routine $51A4E8 TWarrior_ReactToAttack }
procedure TWarrior.ReactToAttack(Attacker: TShip);
begin
  EnemyShip := Attacker;
  if (HomePlanet.OwnerId in PlanetOwnerMasks.Coalition) and (Attacker.TypeId = stRanger) then begin
    HomePlanet.ChangeRelationToRanger(Attacker, -3);
    if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = stRanger) then HomePlanet.ChangeRelationToRanger(Attacker.PartnerShip, -3);
    if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and (TTranclucator(Attacker).OwnerShip.TypeId = stRanger) then
      HomePlanet.ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -3);
  end;
end;
{ @end $51A4E8 }

{ @routine $51A5C0 TWarrior_RecomputeFearState }
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
{ @end $51A5C0 }

{ @routine $51A72C TWarrior_AcceptsRansomDemandFrom }
function TWarrior.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := (GetHull.Weight * 0.5 * OwnerInfo[OwnerId].FearThresholdScale > GetHull.HullPoints) and
  (ChanceToWin(Ship) - OwnerInfo[OwnerId].FearThresholdScale / 2 < 0);
end;
{ @end $51A72C }

{ @routine $51A7C8 TWarrior_TrustsAttackRequester }
function TWarrior.TrustsAttackRequester(Ship: TShip): Boolean;
begin Result := RelationToShip(Ship) >= 30; end;
{ @end $51A7C8 }

{ @routine $51A7EC TWarrior_AcceptsAppealFrom }
function TWarrior.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) +
    RemapClamped(Ship.Strength, 0.9 * Strength, Strength * 3, 0, 100) > 160;
end;
{ @end $51A7EC }

{ @routine $51A888 TWarrior_AssignWeaponTargetsInStar }
procedure TWarrior.AssignWeaponTargetsInStar;
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Distance: Single; Item: TItem; Asteroid: TAsteroid; Missile: TMissile;
  SameRacePlanet: Boolean; Stage: Integer; IgnoreRanger: Boolean;
begin
  Stage := 0;
  if WarriorType = wtFlagship then AssignFlagshipWeaponTargets
  else try
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; end;
  Assigned := 0;
  Stage := 1;
  if CurrentStar.Battle <> 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship.OwnerId = oiDominator) and Ship.InNormalSpace then begin
        Distance := PointDistance(Position, Ship.Position);
        for J := 1 to WeaponCount do begin
          Weapon := Weapons[J];
          if (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and
            (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
            if GetWeaponRange(Weapon) >= Distance then begin
              Weapon.Target := Ship;
              Inc(Assigned);
              if Assigned = WeaponCount then Exit;
            end;
        end;
      end;
    end;
  Stage := 2;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then begin
    SameRacePlanet := (EnemyShip.OrderTarget is TPlanet) and
      ((EnemyShip.OrderTarget as TPlanet).RaceId = HomePlanet.RaceId) and
      ((EnemyShip.OrderTarget as TPlanet).RelationToShip(EnemyShip) <= RelationToShip(EnemyShip));
    IgnoreRanger := (EnemyShip.TypeId = stRanger) and ((EnemyShip.OrderTarget = HomePlanet) or SameRacePlanet) and not EnemyShip.IsAttackingShip(Self);
    if IgnoreRanger then
      for I := 1 to EnemyShip.WeaponCount do
        if (EnemyShip.Weapons[I].Target <> nil) and (EnemyShip.Weapons[I].Target is TShip) and
          not (EnemyShip.Weapons[I].Target is TPirate) then
          if GetRelationLevelToShip(EnemyShip.Weapons[I].Target as TShip) > rlHostile then begin
            IgnoreRanger := False;
            Break;
          end;
    if IgnoreRanger then ClearWeaponTargets(EnemyShip)
    else for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and
        (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
          Weapon.Target := EnemyShip;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
    end;
  end;
  Stage := 3;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    Stage := 31;
    if Ship.InNormalSpace and (Ship <> Self) and (EnemyShip <> Ship) then begin
      Stage := 32;
      if (RelationToShip(Ship) < 10) or (EnemyShip = Ship) or (Ship.EnemyShip = Self) then begin
        Stage := 33;
        if TruceShip <> Ship then begin
          Stage := 34;
          if LiberationGroup = nil then begin
            Stage := 35;
            for J := 1 to WeaponCount do begin
              Stage := 36;
              Weapon := Weapons[J];
              if not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0) then begin
                Stage := 37;
                if IsEquipmentUsable(Weapon) then
                  if PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
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
    end;
  end;
  Stage := 4;
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
  Stage := 5;
  if GetPlayer.CurrentStar = CurrentStar then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do begin
      Asteroid := CurrentStar.Asteroids[I];
      Distance := PointDistanceSquared(Position, Asteroid.Position);
      if Distance <= AsteroidTargetRangeSquared then
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
  Stage := 6;
  if Galaxy.GetAIJunkToleranceLevel * 1.5 < CurrentStar.Items.Count then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if ((Item.ItemType = t_Minerals) or (Item.OwnerId = oiDominator)) and
        ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) then
        if (GetPlayer.CurrentStar <> CurrentStar) or (GetRelationLevelToShip(GetPlayer) <= rlBad) or
          (PointDistance(GetPlayer.Position, Item.Position) >= 800) or
          ((NextRandomUnitFloat(RandomState) <= 0.1) and (PointDistance(GetPlayer.Position, Item.Position) >= 200)) then
          if CanSafelyDetonateItem(Item) then
            for J := 1 to WeaponCount do begin
              Weapon := Weapons[J];
              if not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
                if PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
                  Weapon.Target := Item;
                  Inc(Assigned);
                  if Assigned = WeaponCount then Exit;
                  Break;
                end;
            end;
    end;
  Stage := 7;
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and IsPlayerChameleonEffectiveAgainstSelf then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and
        (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, GetPlayer.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
          Weapon.Target := GetPlayer;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.ArmsToTarget ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $51A888 }

{ @routine $51B778 TWarrior_AssignFlagshipWeaponTargets }
procedure TWarrior.AssignFlagshipWeaponTargets;
var Scores: array[1..5] of Single; Assigned, I, J: Integer; Ship: TShip; Weapon: TWeapon; Distance: Single;
  Item: TItem; Asteroid: TAsteroid; Missile: TMissile; SameRacePlanet: Boolean; Stage: Integer; IgnoreRanger: Boolean;
  // @nested $51B618 ScoreTarget
  procedure ScoreTarget(Ship: TShip); // @addr $51B618
  var J, Range: Integer; Score, Distance: Single; Weapon: TWeapon;
  begin
    Score := 0;
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if IsEquipmentUsable(Weapon) and (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo > 0)) then begin
        Range := GetWeaponRange(Weapon);
        Distance := PointDistance(Position, Ship.Position);
        if Range >= Distance then begin
          if Score = 0 then Score := Ship.CalculateAttackStrength / Ship.CalculateDefenseStrength * RemapClamped(Distance, 0, Range, 1.5, 1);
          if (Score > Scores[J]) or (Weapon.Target = nil) then begin
            if Weapon.Target = nil then Inc(Assigned);
            Scores[J] := Score;
            Weapon.Target := Ship;
          end;
        end;
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
    IgnoreRanger := (EnemyShip.TypeId = stRanger) and ((EnemyShip.OrderTarget = HomePlanet) or SameRacePlanet) and not EnemyShip.IsAttackingShip(Self);
    if not IgnoreRanger then ScoreTarget(EnemyShip);
  end;
  Stage := 2;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if Ship.InNormalSpace and (EnemyShip <> Ship) and (TruceShip <> Ship) and (LiberationGroup = nil) and
      (GetRelationLevelToShip(Ship) <= rlHostile) then ScoreTarget(Ship);
  end;
  if Assigned = WeaponCount then Exit;
  Stage := 4;
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
  Stage := 5;
  if GetPlayer.CurrentStar = CurrentStar then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do begin
      Asteroid := CurrentStar.Asteroids[I];
      Distance := PointDistanceSquared(Position, Asteroid.Position);
      if Distance <= AsteroidTargetRangeSquared then
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
  Stage := 6;
  if Galaxy.GetAIJunkToleranceLevel * 1.5 < CurrentStar.Items.Count then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if ((Item.ItemType = t_Minerals) or (Item.OwnerId = oiDominator)) and
        ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) and not AcceptPickupItem(Item) then
        if (GetPlayer.CurrentStar <> CurrentStar) or (GetRelationLevelToShip(GetPlayer) <= rlBad) or
          (PointDistance(GetPlayer.Position, Item.Position) >= 800) or
          ((NextRandomUnitFloat(RandomState) <= 0.1) and (PointDistance(GetPlayer.Position, Item.Position) >= 200)) then
          if CanSafelyDetonateItem(Item) then
            for J := 1 to WeaponCount do begin
              Weapon := Weapons[J];
              if not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
                if PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
                  Weapon.Target := Item;
                  Inc(Assigned);
                  if Assigned = WeaponCount then Exit;
                  Break;
                end;
            end;
    end;
  Stage := 7;
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and IsPlayerChameleonEffectiveAgainstSelf then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0)) and
        (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, GetPlayer.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
          Weapon.Target := GetPlayer;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TWarrior.ArmsToTarget ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $51B778 }

{ @routine $51C124 TWarrior_FindNearestFriendlyFlagship }
function TWarrior.FindNearestFriendlyFlagship: TShip;
var BestDistance, Distance: Double; Ship: TShip; I: Integer;
begin
  Result := nil;
  BestDistance := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship <> Self) and (Ship is TWarrior) and ((Ship as TWarrior).WarriorType = wtFlagship) and Ship.InNormalSpace then
      if Ship.GetRelationLevelToShip(Self) > rlHostile then begin
        Distance := PointDistanceSquared(Position, Ship.Position);
        if (Result = nil) or (Distance < BestDistance) then begin Result := Ship; BestDistance := Distance; end;
      end;
  end;
end;
{ @end $51C124 }

{ @routine $51C208 TWarrior_SelectEnemyShipInStar }
procedure TWarrior.SelectEnemyShipInStar;
var I: Integer; Ship, BestShip: TShip; Chance, BestChance, Distance, TravelTime, BestDistance: Double; InFlagshipRange: Boolean;
  Range, MinRange, MaxRange: Integer; Score, BestScore, OwnAttack: Double; Weapon: TWeapon;
begin
  if WarriorType = wtFlagship then InFlagshipRange := True
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
      if IsEquipmentUsable(Weapon) and (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo > 0)) then begin
        Range := GetWeaponRange(Weapon);
        if (Range < MinRange) or (MinRange < 0) then MinRange := Range;
        if (Range > MaxRange) or (MaxRange < 0) then MaxRange := Range;
      end;
    end;
    OwnAttack := CalculateAttackStrength;
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if Ship.InNormalSpace and (RelationToShip(Ship) < 10) and (TruceShip <> Ship) then begin
        Score := Ship.CalculateAttackStrength * Max(1.0, OwnAttack / Ship.CalculateDefenseStrength);
        Distance := PointDistance(Position, Ship.Position);
        if MaxRange > Distance then Score := Score * RemapClamped(Distance, MinRange, MaxRange, 1.5, 1)
        else Score := Score * Distance / (Speed + 1) * RemapClamped((Speed + 1) / (Ship.Speed + 1), 0.5, 2, 0.25, 1);
        if Ship is TKling then begin
          if (Ship as TKling).KlingType = ktBertor then Score := Score * 5;
          if (Ship as TKling).KlingType = ktKlig then Score := Score * 0.25;
        end;
        if Score > BestScore then begin BestScore := Score; BestShip := Ship; end;
      end;
    end;
    if BestShip <> nil then EnemyShip := BestShip;
  end else if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or (EnemyShip.ConsecutiveDockedDays > 3) then
    if UsableWeaponCount <> 0 then begin
      BestChance := -1;
      BestDistance := 1;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if Ship.InNormalSpace and (RelationToShip(Ship) < 10) and (TruceShip <> Ship) then begin
          if Ship.CurrentStanding in [ssDominator, ssPirateMilitary] then begin
            EnemyShip := Ship;
            if ChanceToWin(Ship) > 1 then Exit;
          end else if (LiberationGroup = nil) or ((GetPlayer = Ship) and (Ship.CurrentStanding = ssPirateActive)) then begin
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
end;
{ @end $51C208 }

{ @routine $51C750 TWarrior_EngageEnemyShip }
procedure TWarrior.EngageEnemyShip;
var Ship: TShip; RetreatToFlagship: Boolean;
begin
  if Order = soFollowShip then OrderNone(False);
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then begin
    Ship := FindNearestFriendlyFlagship;
    RetreatToFlagship := (Ship <> nil) and EnemyShip.InNormalSpace and not EnemyShip.HasNoUsableWeapons and
      (EnemyShip.EnemyShip = Self) and (EnemyShip.OrderTarget = Self) and (EnemyShip.Speed > Speed) and
      (Ship.GetRelationLevelToShip(EnemyShip) <= rlHostile);
    if EnemyShip.InNormalSpace then begin
      if RetreatToFlagship then OrderFollowShip(Ship, 0, False) else OrderFollowShip(EnemyShip, 1, False);
      if ChanceToWin(EnemyShip) < 0.8 then RequestAlliesAttackShip(EnemyShip);
    end else if ChanceToWin(EnemyShip) > 0.5 then begin
      if EnemyShip.CurrentPlanet <> nil then begin
        if (EnemyShip is TRanger) and (Cardinal((EnemyShip as TRanger).PrisonTermRemaining) > 0) then begin
          EnemyShip := nil;
          OrderNone(False);
          Exit;
        end;
        if (EnemyShip is TPirate) and (Cardinal((EnemyShip as TPirate).PrisonTermRemaining) > 0) then begin
          EnemyShip := nil;
          OrderNone(False);
          Exit;
        end;
        OrderMove(EnemyShip.CurrentPlanet.GetPosition, False);
      end else if EnemyShip.DockedTo <> nil then OrderMove(EnemyShip.DockedTo.Position, False);
    end;
  end;
end;
{ @end $51C750 }

{ @routine $51D714 TWarrior_ManeuverFlagship }
procedure TWarrior.ManeuverFlagship;
var Enemies: TList; SupportWeight: Single; OwnMinRange, OwnMaxRange: Integer; OwnAttack: Single; Allies: TList;
  EnemiesInRange: Integer; AttackWeight, OwnDefense, FearWeight: Single; I: Integer; Ship: TShip;
  Candidate, Destination: TPointF; BestShip: TShip; BestShipScore, BestPositionScore, Score: Single;
  RandomDistance, Angle, AllyAreaScore, EnemyAreaScore: Integer; AllyRepair, EnemyRepair: Single;
  // @nested $51C9D4 GetWeaponRangeBounds
  procedure GetWeaponRangeBounds(Ship: TShip; var Minimum, Maximum: Integer); // @addr $51C9D4
  var I, Range: Integer; Weapon: TWeapon;
  begin
    Minimum := -1;
    Maximum := -1;
    for I := 1 to Ship.WeaponCount do begin
      Weapon := Ship.Weapons[I];
      // Native uses the flagship's usability check for other ships' weapons.
      if IsEquipmentUsable(Weapon) and (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo > 0)) then begin
        Range := Ship.GetWeaponRange(Weapon);
        if (Minimum > Range) or (Minimum < 0) then Minimum := Range;
        if (Maximum < Range) or (Maximum < 0) then Maximum := Range;
      end;
    end;
  end;
  // @nested $51CAA0 AreaWeaponScore
  function AreaWeaponScore(Ship: TShip): Integer; // @addr $51CAA0
  var I: Integer; Weapon: TWeapon;
  begin
    Result := 0;
    for I := 1 to Ship.WeaponCount do begin
      Weapon := Ship.Weapons[I];
      if IsEquipmentUsable(Weapon) and (not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo > 0)) then
        case Weapon.GetWeaponInfo.ShotType of
          wstChain: Inc(Result);
          wstSplash, wstTorpedo, wstMissile: Inc(Result, 2);
          wstAreaDamage: Inc(Result, 5);
        end;
    end;
    if Ship is TKling then
      case (Ship as TKling).KlingType of
        ktBertor: Inc(Result, 12);
        ktKlig: Inc(Result, 3);
      end;
  end;
  // @nested $51CB78 ProjectOutsideStar
  function ProjectOutsideStar(Point: TPointF): TPointF; // @addr $51CB78
  var SquaredDistance: Single; Attempts: Integer; Radius: Single;
  begin
    SquaredDistance := Sqr(Point.X) + Sqr(Point.Y);
    Radius := CurrentStar.SafeRadius;
    Attempts := 0;
    if SquaredDistance < 0.1 then begin
      while True do begin
        Result.X := NextRandomIntRange(Round(-1.3 * Radius), Round(1.3 * Radius), RandomState);
        Result.Y := NextRandomIntRange(Round(-1.3 * Radius), Round(1.3 * Radius), RandomState);
        if Sqr(Result.X) + Sqr(Result.Y) > Sqr(Radius) then Break;
        Inc(Attempts);
        if Attempts > 100 then Exit;
      end;
    end else if Sqr(Radius) >= SquaredDistance then begin
      SquaredDistance := (Radius + 1) / Sqrt(SquaredDistance);
      Result.X := Point.X * SquaredDistance;
      Result.Y := Point.Y * SquaredDistance;
    end else Result := Point;
  end;
  // @nested $51CCFC EvaluatePosition
  function EvaluatePosition(Point: TPointF): Single; // @addr $51CCFC
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
      if (Ship is TKling) and ((Ship as TKling).KlingType = ktBertor) then Threat := 1.5 * Threat;
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
        if (Item is TProtoplasm) and CanCargoHookHandleItem(Item, Self) and not IsItemInPickupRange(Item) then begin
          Distance := Sqrt(Sqr(Point.X - Item.Position.X) + Sqr(Point.Y - Item.Position.Y));
          HookRange := GetCargoHookRange;
          if Distance <= HookRange then NodeValue := NodeValue + Min((Item as TProtoplasm).StackCount, CargoFreeSpace)
          else NodeValue := NodeValue + Min((Item as TProtoplasm).StackCount, CargoFreeSpace) * RemapClamped(Distance, GetCargoHookRange, 2 * GetCargoHookRange, 0.5, 0);
        end;
      end;
    if PilotRace <> oiFeyan then NodeValue := NodeValue * 2;
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
  // @nested $51D5A0 BoostWithNodes
  procedure BoostWithNodes; // @addr $51D5A0
  var Factor: Single;
  begin
    if (PilotRace in [oiMaloc, oiHuman, oiGaal]) and (EnemiesInRange > 0) then begin
      Factor := RemapClamped(CargoFreeSpace, 0, GetHull.Weight div 4, 0.5, 1) * (3 / (EnemiesInRange + 2)) *
        RemapClamped(GetHull.HullPoints, 0, GetHull.Weight div 2, 0.1, 1);
      while (50 - 90 * Factor > GetCombatStatusStrength(cseBWBuff)) and (GetCarriedNodeCount >= Int64(50)) do begin
        ConsumeNodes(50);
        AddCombatStatusStrength(cseBWBuff, 20, nil);
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
      if GetRelationLevelToShip(Ship) <= rlHostile then Enemies.Add(Ship)
      else if (GetRelationLevelToShip(Ship) > rlNormal) and
        ((Ship is TWarrior) or ((Ship.EnemyShip <> nil) and (GetRelationLevelToShip(Ship.EnemyShip) <= rlHostile))) then Allies.Add(Ship);
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
    if GetRelationLevelToShip(BestShip) > rlHostile then OrderFollowShip(BestShip, 0, False) else OrderFollowShip(BestShip, 1, False)
  else OrderMove(Destination, False);
end;
{ @end $51D714 }

{ @routine $51DD8C TWarrior_ReassignFlagshipHomePlanet }
procedure TWarrior.ReassignFlagshipHomePlanet;
var Score, BestScore: Single; Planet, BestPlanet: TPlanet; Star, NearbyStar, BestStar: TStar;
  I, J, K: Integer; FlagshipFactor, GarrisonStrength, NearbyThreat: Single; Ship: TShip; Warrior: TWarrior;
  RacePlanetCount, WarriorCount, StationCount: Integer;
begin
  BestScore := 0;
  BestStar := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if (Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '') and (Star.ConstellationGraphIndex <> 20) then begin
      FlagshipFactor := 1;
      GarrisonStrength := 0;
      RacePlanetCount := 0;
      StationCount := 0;
      for J := 0 to Star.Ships.Count - 1 do begin
        Ship := Star.Ships[J];
        if (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Ship.CurrentStanding in NonTargetableStationStandingMasks[sfCoalition]) then Inc(StationCount);
      end;
      for J := 0 to Star.Planets.Count - 1 do begin
        Planet := Star.Planets[J];
        if Planet.OwnerId in PlanetOwnerMasks.Coalition then begin
          if Planet.RaceId = PilotRace then Inc(RacePlanetCount);
          for K := 0 to Planet.Warriors.Count - 1 do begin
            Warrior := Planet.Warriors[K];
            if Warrior = Self then Continue;
            GarrisonStrength := GarrisonStrength + RemapClamped(Warrior.Strength, 0.1 * Strength, 10 * Strength, 0.3, 3);
            if Warrior.WarriorType = wtFlagship then
              if Warrior.PilotRace = PilotRace then FlagshipFactor := FlagshipFactor * 0.05
              else FlagshipFactor := FlagshipFactor * 0.2;
          end;
        end;
      end;
      if (GarrisonStrength <> 0) and (RacePlanetCount <> 0) then begin
        NearbyThreat := 0;
        for J := 1 to Galaxy.Stars.Count div 5 do begin
          NearbyStar := TObject(Star.StarDistances[J].Star) as TStar;
          if NearbyStar.ConstellationGraphIndex <> 20 then
            if NearbyStar.Status.CustomFaction <> '' then NearbyThreat := NearbyThreat + 5 / (J + 5)
            else case NearbyStar.ControlFaction of
              sfCoalition: ;
              sfPirates: NearbyThreat := NearbyThreat + 1 / (J + 5);
              sfDominators: NearbyThreat := NearbyThreat + 5 / (J + 5);
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
      if (Planet.OwnerId in PlanetOwnerMasks.Coalition) and (Planet.RaceId = PilotRace) then begin
        WarriorCount := 0;
        FlagshipFactor := 1;
        for K := 0 to Planet.Warriors.Count - 1 do begin
          Warrior := Planet.Warriors[K];
          if Warrior <> Self then begin
            Inc(WarriorCount);
            if Warrior.WarriorType = wtFlagship then FlagshipFactor := FlagshipFactor * 0.1;
          end;
        end;
        Score := WarriorCount * FlagshipFactor;
        if HomePlanet = Planet then Score := Score * 1.3;
        if (Score > BestScore) or (BestPlanet = nil) then begin BestScore := Score; BestPlanet := Planet; end;
      end;
    end;
    if (BestPlanet <> nil) and (BestPlanet <> HomePlanet) then begin
      I := HomePlanet.Warriors.IndexOf(Self);
      if I >= 0 then HomePlanet.Warriors.Delete(I);
      I := BestPlanet.Warriors.IndexOf(Self);
      if I < 0 then BestPlanet.Warriors.Add(Self);
      HomePlanet := BestPlanet;
    end;
  end;
end;
{ @end $51DD8C }

{ @routine $51E2F8 TWarrior_ProcessCombatDialogue }
procedure TWarrior.ProcessCombatDialogue;
begin end;
{ @end $51E2F8 }

{ @routine $51E304 TWarrior_ReactToExtortionDemand }
procedure TWarrior.ReactToExtortionDemand(Ranger: Pointer);
begin
  if (GetPlayer = Ranger) or (NextRandomUnitFloat(RandomState) < 0.05) then begin
    HomePlanet.ChangeRelationToRanger(Ranger, -5);
    (TObject(Ranger) as TRanger).AddPirateCareerActivity(4);
  end;
end;
{ @end $51E304 }

{ @routine $51E370 TWarrior_BuildMoneyExtortionResponse }
function TWarrior.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
begin
  Result := False;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := OtherShip;
  Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $51E370 }

{ @routine $51E48C TWarrior_BuildCargoExtortionResponse }
function TWarrior.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if (GetPlayer <> OtherShip) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := OtherShip;
  Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $51E48C }

{ @routine $51E7CC TWarrior_BuildTrucePaymentResponse }
function TWarrior.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
var NextDemandTurn: Integer;
  // @nested $51E5A4 AcceptPayment
  procedure AcceptPayment; // @addr $51E5A4 @note "Nested helper with caller-popped static link."
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
          if (Ship.Order = soFollowShip) and ((Ship.OrderTarget as TShip) = OtherShip) then begin
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
  if RefusesFactionNegotiation(OtherShip) then begin Response := LookupVisibleTalkText('Talk.Refuse.Warrior', OtherShip); Result := False; end
  else if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (OtherShip is TNormalShip) and (OtherShip.OwnerId = oiPirate) and (OtherShip.CurrentStar.ControlFaction = sfCoalition) and
    (TNormalShip(OtherShip).CurrentSystemKills.Normal > 0) then begin
    if 2 * Wealth * (1 / 15) < OfferedAmount then begin
      Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
      AcceptPayment;
      Result := True;
    end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
  end else if Wealth * (1 / 15) < OfferedAmount then begin
    Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptPayment;
    Result := True;
  end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $51E7CC }

{ @routine $51EC5C TWarrior_BuildAttackRequestResponse }
function TWarrior.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
var I, HostileCount: Integer; Ship: TShip;
  // @nested $51EB84 AcceptRequest
  procedure AcceptRequest; // @addr $51EB84 @note "Nested helper with caller-popped static link."
  begin
    Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Ok', Requester);
    SetJointAttackTarget(Requester, Target);
    Result := True;
  end;
begin
  Result := False;
  if Requester is TRanger then begin
    if Target.TypeId in [stRanger..stPirate] then Target.ChangeRelationToRanger(Requester, -20);
    if (Target.OwnerId = oiDominator) or (Target.TypeId = stPirate) then (Requester as TRanger).AddWarriorCareerActivity(1)
    else (Requester as TRanger).AddPirateCareerActivity(8);
  end;
  HostileCount := 0;
  if WarriorType = wtFlagship then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if (Ship <> Self) and Ship.InNormalSpace then begin
        if GetRelationLevelToShip(Ship) <= rlHostile then Inc(HostileCount);
        if HostileCount > 1 then Break;
      end;
    end;
  if (OrderTarget = Target) and (GetRelationLevelToShip(Target) = rlHostile) and (HostileCount <= 1) then AcceptRequest
  else if (LiberationGroup <> nil) and (Requester.LiberationGroup <> LiberationGroup) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else if TruceShip = Target then Response := FormatText1(LookupVisibleTalkText('Talk.Attack.WeAlreadyHavePact', Requester), '<color=255,240,100>', '<Target>', Target.GetName)
  else if RelationToShip(Target) >= 30 then begin
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
{ @end $51EC5C }

{ @routine $51F300 TWarrior_AcceptPartnershipOffer }
function TWarrior.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin Result := False; Response := 'Not supporting'; end;
{ @end $51F300 }

{ @routine $51F350 TWarrior_BuildPartnershipOfferResponse }
function TWarrior.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin Result := False; Response := 'Not supporting'; end;
{ @end $51F350 }

{ @routine $51F3A0 TWarrior_MoveToRandomPlanetOrbit }
procedure TWarrior.MoveToRandomPlanetOrbit;
var Planet: TPlanet; Polar: TPolarPoint;
begin
  Planet := CurrentStar.Planets[0];
  Polar := Planet.Orbit;
  Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $51F3A0 }

{ @routine $51F408 TWarrior_IsHomePatrolTurn }
function TWarrior.IsHomePatrolTurn: Boolean;
begin
  Result := (GetHomeStar = CurrentStar) and ((Id + Galaxy.CurrentTurn) mod 100 < 25);
end;
{ @end $51F408 }

{ @routine $51F450 TWarrior_ConsumeNodes }
procedure TWarrior.ConsumeNodes(Amount: Integer);
var I, RemainingWeight: Integer; Item: TItem;
begin
  for I := Inventory.Count - 1 downto 1 do begin
    Item := Inventory[I];
    if Item.ItemType = t_Protoplasm then begin
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
{ @end $51F450 }

{ @routine $51F524 TWarrior_RefusesFactionNegotiation }
function TWarrior.RefusesFactionNegotiation(OtherShip: TShip): Boolean;
begin
  Result := False;
  if OtherShip.CurrentStanding = ssPirateMilitary then begin Result := True; Exit; end;
  if ((CurrentStar.ControlFaction <> sfCoalition) or (CurrentStar.Status.CustomFaction <> '')) and
    (OtherShip.CurrentStanding in [ssPirateActive, ssPirateMilitary]) then begin Result := True; Exit; end;
end;
{ @end $51F524 }

{ @routine $51F580 TWarrior_AdjustItemEvaluation }
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
  if Item.ItemType in [t_FuelTanks, t_Radar, t_CargoHook] then FragilityScale := FragilityScale * 0.5;
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
  if WarriorType = wtFlagship then EffectivenessScale := 2 * EffectivenessScale;
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
{ @end $51F580 }

{ @routine $51FB14 TWarrior_EvaluateStatBonus }
function TWarrior.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonHull: Result := Value * 200;
    bonFuel: Result := (0.5 * Value) * (1 - ShortInt(WarriorType = wtFlagship) * 0.5);
    bonSpeed: Result := Value * 0.2;
    bonJump: Result := Value * 5;
    bonRadar: Result := (0.025 * Value) * (1 + ShortInt(WarriorType = wtFlagship) * 0.5);
    bonScan: Result := Value * 3 + Value * 30 * CountWeaponsByDamageFlags(ScannerFlags);
    bonDroid: Result := Value * 10 / Max(0.1, GetHull.GetFragilityFactor(NoFlags)) * (1 + ShortInt(WarriorType = wtFlagship) * 0.5);
    bonHook: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.3 * ShortInt(WarriorType = wtFlagship);
    bonDef: Result := Value * 5 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonWEnergy: Result := Value * 12;
    bonWSplinter: Result := Value * 12;
    bonWMissile: Result := Value * 12 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9) * (1 - Ord(WarriorType = wtFlagship));
    bonWRadius: if WarriorType = wtFlagship then Result := Value * 3 else Result := Value * 1.5 * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonHookRadius: Result := Value * 1.0 * ShortInt(WarriorType = wtFlagship);
    bonMass: Result := RemapClamped(Value, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 1000;
    bonSlotRadar:
      if (GetSlotCount(sskRadar) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind] - WarriorSlotBonusWeights[bonSlotWeapon] * CountMissileWeapons
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * WarriorSlotBonusWeights[bonSlotWeapon]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then Result := WarriorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(sskWeapon)) * WarriorSlotBonusWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskWeapon)) * WarriorSlotBonusWeights[BonusKind];
        if CountEquippedWeapons > Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - (WarriorSlotBonusWeights[BonusKind] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(sskWeapon)));
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := WarriorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -WarriorSlotBonusWeights[BonusKind];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), Value) * WarriorSkillBonusWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) > 6) then
          Result := Result + (WarriorSkillBonusWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), -Value) * -WarriorSkillBonusWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) < 0) then
          Result := Result + (WarriorSkillBonusWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]));
      end;
  else Result := 0;
  end;
  if BonusKind in [bonSkill1..bonSkill6] then Result := Result * 0.01 * (100 + SeededRandomIntRange(-30, 30, Seed + 131 * Ord(BonusKind))) * RaceSkillEvaluationFactors[PilotRace, EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]]
  else Result := Result * 0.01 * (100 + SeededRandomIntRange(-10, 10, Seed + 131 * Ord(BonusKind)));
end;
{ @end $51FB14 }

{ @routine $520788 TWarrior_EvaluateWeaponDamage }
function TWarrior.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  ShockFlags = [dkShock];
  AcidFlags = [dkAcid];
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
  if dkDrain in Flags then Result := Result * (1.5 - ShortInt(WarriorType = wtFlagship) * 0.4);
  if dkShock in Flags then Result := Result * (1.05 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  if dkAcid in Flags then Result := Result * 1.05;
  StatusFactor := 1;
  if dkScanBonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkBonusToDamaged in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if dkBlockWeapon in Flags then Result := Result + ScannerFactor * 5;
    if dkDroidBlock in Flags then Result := Result + ScannerFactor * 5;
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if dkAcid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case Weapon.GetWeaponInfo.ShotType of
    wstRocket: Result := Result * 1.1 * Weapon.GetShotCount * (1 + StatusFactor);
    wstMissile: Result := Result * (1.1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    wstTorpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 + StatusFactor);
    wstChain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    wstSplash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.5 * 0.01 * SpeedFactor + StatusFactor);
    wstExploder: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.8 * 0.01 * SpeedFactor + StatusFactor);
    wstAreaDamage: Result := Result * (1 + Weapon.Range * 2.2 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
end;
{ @end $520788 }

{ @routine $520CE8 TWarrior_AcceptPickupItem }
function TWarrior.AcceptPickupItem(Item: TItem): Boolean;
begin
  Result := False;
  if WarriorType = wtFlagship then begin
    if (Item.ItemType = t_Protoplasm) and (CargoFreeSpace > 0) then begin Result := True; Exit; end
    else if (PilotRace in [oiPeleng..oiFeyan]) and (Item is TUselessItem) then
      if (Item as TUselessItem).IsDominatorRemains then begin Result := True; Exit; end;
  end;
end;
{ @end $520CE8 }

{ @routine $520D64 TWarrior_AcceptPickupDistance }
function TWarrior.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  if Speed < 1 then begin Result := False; Exit; end;
  Result := (30 * Speed >= Distance) or
    (Item.Cost >= RemapClamped(Distance / Speed, 1, 10, 0.01, 0.05) * Wealth);
end;
{ @end $520D64 }

{ @routine $520E00 TWarrior_RefreshCurrentStanding }
procedure TWarrior.RefreshCurrentStanding;
var StandingMode: Integer;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then CurrentStanding := ssCoalitionMilitary;
end;
{ @end $520E00 }

end.
