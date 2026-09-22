unit aKling;
// Unit bracket (inferred): .text 0x005E8168..0x005EFCA8; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses aConst, EC_Buf, aItem, aGalaxy, aGalaxyStruct, aPlanet, aShip;

type
  TKling = class(TShip) // @size 0x4DC
  public
    KlingType: TKlingType; // @offset 0x4D0  Script.ShipSubType.
    DominatorSeries: TDominatorSeries; // @offset 0x4D1
    ActiveProgramAppliedTurn: Integer; // @offset 0x4D4  Zero means inactive.
    ActiveProgramId: TProgramIndex; // @offset 0x4D8
    AuraEffectShownThisTurn: Boolean; // @offset 0x4D9

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $005EA15C @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $005EA1BC @slot $04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr $005EA238 @slot $08
    procedure AssignWeaponTargetsInStar; override; // @addr $005EEBD4 @slot $20
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $005EE51C @slot $60
    procedure BuildReachablePlanetQueue; override; // @addr $005EC094 @slot $64
    procedure SelectEnemyShipInStar; override; // @addr $005EF408 @slot $6C
    procedure EngageEnemyShip; override; // @addr $005EF630 @slot $70
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $005EEADC @slot $74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $005EEB04 @slot $78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $005EEB18 @slot $7C
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $005EEA78 @slot $80
    function RecomputeFearState: Boolean; override; // @addr $005EEB6C @slot $84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $005EEB80 @slot $88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $005EEB98 @slot $8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $005EEBB0 @slot $90
    procedure UpdateAfterburnerState; override; // @addr $005EF6F4 @slot $9C
    procedure ProcessCombatDialogue; override; // @addr $005EF758 @slot $A0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $005EF764 @slot $A4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $005EF774 @slot $A8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $005EF790 @slot $AC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $005EF7AC @slot $B0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $005EF7C8 @slot $B4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $005EF7E4 @slot $B8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $005EF834 @slot $BC
    procedure RefreshCurrentStanding; override; // @addr $005EFC48 @slot $C4
    destructor Destroy; override; // @addr $5E828C
    function LandOnRandomFriendlyPlanet(OverrideScriptOrder: Boolean): Boolean; // @addr $5EC024
    function RetreatToReinforcedStar: Boolean; // @addr $5EC180
    function RetreatIfHullCritical: Boolean; // @addr $5EC358
    procedure MoveToRandomPatrolPoint; // @addr $5EE370
    procedure MoveNearKellerMissionHole; // @addr $5EE430
    procedure SetInventoryDominatorOwner; // @addr $5EE884
    procedure ImproveStandardEquipment; // @addr $5EE8E0
    procedure RefreshCombatSkills; // @addr $5EF884

    procedure InitBlazer(Star: TStar); // @addr $5E831C
    procedure InitKeller(Star: TStar); // @addr $5E87D8
    procedure InitTerron(Star: TStar); // @addr $5E8C20
    procedure InitializeDominator(Kind: TKlingType; Planet: TPlanet; Series: TDominatorSeries); // @addr $5E91DC
    procedure InitGenerated(Kind: TKlingType; Planet: TPlanet; Series: TDominatorSeries); // @addr 0x5E978C @note "Initializes type/series and location through 0x5E91DC, then builds the generated loadout. Series occupies one four-byte stack slot."

    function SelectBertorLeader: TShip; // @addr $5EBD14
    function RelocateBertorWithinConstellation: Boolean; // @addr $5ED070
    function SpawnEscortShips(Kind: TKlingType; DesiredCount: Integer): Integer; // @addr $5ED2E4
    procedure CoordinateSeriesInvasions(Series: TDominatorSeries); // @addr $5EDEC0
    function FindKellerAttackTarget: TStar; // @addr $5EC3B0
    function FindKellerReinforcementTarget: TStar; // @addr $5EC6FC
    procedure SelectKellerMission; // @addr $5EC8B4
    procedure SelectKellerReinforcementMission; // @addr $5ECB34
    procedure MiniBossNextDayLogic; // @addr 0x5EABD0
    procedure BlazerNextDayLogic; // @addr 0x5EB140
    procedure KellerNextDayLogic; // @addr 0x5EB568
    procedure TerronNextDayLogic; // @addr 0x5EB9F0
    procedure NextDay; override; // @addr 0x5EA254 @slot 0x18
    procedure NextDayLogic; override; // @addr 0x5EA50C @slot 0x1C @calls "0x5EA36A 0x5EA38A"
    function GetGreetingShipCategory: TGreetingShipCategory; override; // @addr $5EE7C8 @slot $30
    function GetHomeStar: TStar; override; // @addr $5EE5A8 @slot $34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $5EE7F0 @slot $3C
    function GetDominantCareer: TRangerCareer; override; // @addr 0x5EE7DC @slot 0x38 @note "Always rcWarrior."
    function GetName: WideString; override; // @addr 0x5EE5C0 @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x5EE5E0 @slot 0x28

    function IsProgramActive(ProgramId: TProgramIndex): Boolean; // @addr 0x5EE81C @note "Checks the stored active flag and ID; expiration is handled by the daily ship update."
    function ShouldKamikaze: Boolean; // @addr 0x5EBF40 @note "Requires a live enemy in the same star and KlingType=ktKlig. Existing kamikaze mode bypasses the proximity/strength test."
    procedure OpenKellerMissionHole; // @addr 0x5ECD28 @note "Advances mission state 2 to 3, creates the type-4 hole and sends Keller through it with generated reinforcements."
    procedure DetectAttackingPlayer(Attacker: TShip); // @addr $5EF1F4 Marks this series as aware of the player's camouflage and reports a matching active disguise.
    function HasNearbyBertorAura: Boolean; // @addr 0x5EFB34

    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x5EE804 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x5EE854 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CalculateSpeed: Integer; override; // @addr 0x5EFAE8 @slot 0x4C @note "Bosses have a minimum calculated speed of 350."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x5EC160 @slot 0x68 @note "AI ownership check only; does not test travel range."
    function IsPlayerCamouflageEffective(Ship: TShip): Boolean; // @addr 0x5EF330 @note "Can mark the player's camouflage as detected by this Dominator series. Returns false for non-player ships."
  end;

var
  DominatorEquipmentSizeIndices: array[TKlingType, 0..1] of Integer = ((1, 1), (1, 3), (2, 4), (3, 4), (3, 5), (4, 5), (1, 1), (4, 5)); // @addr $87B420 Maximum-size index followed by minimum-size index.
  DominatorWeaponDistributionByTier: array[1..7] of Integer = (1, 1, 2, 2, 3, 3, 4); // @addr $87B460
  DominatorWeaponWeights: array[1..4, TKlingType, t_IndustrialLaser..t_TorpedoTube] of Integer = (
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 30, 5, 30, 5, 25, 5),
     (0, 0, 0, 30, 0, 0, 0, 0, 25, 5, 5, 0, 30, 0, 5),
     (0, 0, 0, 0, 10, 0, 20, 30, 0, 0, 0, 0, 0, 0, 40),
     (0, 20, 0, 20, 0, 30, 30, 0, 0, 0, 0, 0, 0, 0, 0),
     (25, 0, 50, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (15, 0, 50, 0, 25, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0)),
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 30, 5, 30, 5, 25, 5),
     (0, 0, 0, 30, 0, 0, 0, 0, 25, 5, 5, 0, 30, 0, 5),
     (0, 0, 0, 0, 10, 0, 20, 30, 0, 0, 0, 0, 0, 0, 40),
     (0, 20, 0, 20, 0, 30, 30, 0, 0, 0, 0, 0, 0, 0, 0),
     (5, 0, 30, 0, 10, 0, 0, 0, 0, 5, 50, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 10, 0, 40, 0, 15, 30, 5, 0, 0, 0, 0, 0, 0)),
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 30, 5, 30, 5, 25, 5),
     (0, 0, 0, 30, 0, 0, 0, 0, 25, 5, 5, 0, 30, 0, 5),
     (0, 0, 0, 0, 5, 0, 5, 20, 0, 10, 10, 0, 0, 0, 50),
     (0, 5, 0, 5, 0, 30, 20, 0, 15, 0, 0, 25, 0, 0, 0),
     (5, 0, 30, 0, 10, 0, 0, 0, 0, 5, 50, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 10, 0, 40, 0, 15, 30, 5, 0, 0, 0, 0, 0, 0)),
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 30, 15, 35, 10),
     (0, 0, 0, 10, 0, 0, 0, 0, 25, 10, 0, 10, 30, 0, 15),
     (0, 0, 0, 0, 5, 0, 5, 20, 0, 10, 10, 0, 0, 0, 50),
     (0, 5, 0, 5, 0, 30, 20, 0, 15, 0, 0, 25, 0, 0, 0),
     (5, 0, 30, 0, 10, 0, 0, 0, 0, 5, 50, 0, 0, 0, 0),
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 25, 50),
     (0, 0, 10, 0, 40, 0, 15, 30, 5, 0, 0, 0, 0, 0, 0))
  ); // @addr $87B47C
  DominatorGenerationTuning: array[1..7, 1..19] of Integer = (
    (65, 1, 3, 1, 3, 1, 3, 1, 3, 1, 5, 1, 2, 5, 25, 5, 20, 0, 10),
    (75, 1, 5, 1, 5, 1, 5, 1, 5, 2, 6, 1, 3, 15, 50, 10, 40, 0, 20),
    (85, 2, 7, 2, 7, 2, 7, 2, 7, 3, 7, 2, 4, 30, 75, 20, 60, 15, 40),
    (95, 3, 8, 3, 8, 3, 8, 3, 8, 4, 8, 2, 5, 45, 95, 30, 80, 30, 80),
    (95, 4, 8, 4, 8, 4, 8, 4, 8, 6, 8, 3, 5, 50, 95, 50, 95, 40, 95),
    (95, 6, 8, 6, 8, 6, 8, 6, 8, 7, 8, 4, 5, 75, 95, 75, 95, 70, 95),
    (95, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 5, 95, 95, 95, 95, 95, 95)
  ); // @addr $87BBFC Control threshold and paired equipment/weapon generation bounds.

var
  BlazerShip: TKling; // @addr $88A9F0
  KellerShip: TKling; // @addr $88A9F4
  TerronShip: TKling; // @addr $88A9F8
var
  PieceCreatorTargetStarId: Cardinal; // @addr $88A9FC @note "PIECECREATOR target selected during new-game generation and persisted with the galaxy."
var

  DominatorSpawnPlanet: TPlanet; // @addr $88AA00

implementation

// @unit-initialization $8778C4
// @unit-finalization $5EFCAC

uses SE_Hole, SysUtils, aAsteroid, aMissile, aScript, Classes, aRanger, aMyFunction, Globals, GlobalsV, EC_Str, Math, EC_Struct, aPlayer;

const
  // Native ANSI exception text contains UTF-8 bytes; ordinary Russian literals
  // compile to Windows-1251. Text: Клинг выпустился со скоростью 0
  DominatorZeroSpeedError =
    #$D0#$9A#$D0#$BB#$D0#$B8#$D0#$BD#$D0#$B3#$20#$D0#$B2#$D1#$8B#$D0#$BF#$D1#$83#$D1#$81#$D1#$82#$D0#$B8#$D0#$BB#$D1#$81#$D1#$8F#$20#$D1#$81#$D0#$BE#$20#$D1#$81#$D0#$BA#$D0#$BE#$D1#$80#$D0#$BE#$D1#$81#$D1#$82#$D1#$8C#$D1#$8E#$20#$30;

{ @routine $5E828C TKling_Destroy }
destructor TKling.Destroy;
var I: Integer; Ranger: TRanger;
begin
  if KlingType = ktBoss then
    for I := 0 to Galaxy.Rangers.Count - 1 do begin
      Ranger := Galaxy.Rangers[I];
      if Ranger.LastDockedNonPlanetLocation = Self then Ranger.LastDockedNonPlanetLocation := nil;
    end;
  inherited;
end;
{ @end $5E828C }

{ @routine $5E831C TKling_InitBlazer }
procedure TKling.InitBlazer(Star: TStar);
begin
  TypeId := stKling;
  OwnerId := oiDominator;
  KlingType := ktBoss;
  DominatorSeries := dsBlazer;
  SetMoney(MaxInt);
  NodeReserve := Round(NextRandomFloatRange(0.8, 1.2, RandomState) * DominatorShipDefinitions[KlingType].BaseNodeReserve * Galaxy.GetNodeDropModifier);
  Position.X := 0;
  Position.Y := 0;
  CurrentStar := Star;
  CurrentStar.Ships.Add(Self);
  CurrentStar.DominatorSeries := DominatorSeries;
  HomePlanet := nil;
  CurrentPlanet := nil;
  Inc(CurrentStar.ShipTypeCounts[stKling]);
  Name := DominatorShipDefinitions[KlingType].DisplayNames[DominatorSeries];
  RefreshCombatSkills;
  ActiveProgramAppliedTurn := 0;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  CreateAndEquipHull(RoundAndTruncateToHundreds((HullCapacityScale * 6000) * Galaxy.GetDominatorBossHullScale * NextRandomFloatRange(0.9, 1.1, RandomState)), 8, oiDominator, -1, False);
  CreateAndEquipFuelTanks(100, 8, oiDominator);
  CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 8, oiDominator);
  CreateAndEquipWeapon(t_TorpedoTube, Round(WeaponInfos[t_TorpedoTube].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_TorpedoTube, Round(WeaponInfos[t_TorpedoTube].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_IMHO9000, Round(WeaponInfos[t_IMHO9000].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_Disintegrator, Round(WeaponInfos[t_Disintegrator].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  if Galaxy.GetDifficultyTierIndex > 0 then
    CreateAndEquipWeapon(t_Turbogravitron, Round(WeaponInfos[t_Turbogravitron].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipDefGenerator(Round(DefGeneratorBaseSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipRepairRobot(Round(RepairRobotBaseSize * EquipmentSizeFactors[5]), Round(RemapClamped(Galaxy.GetEffectiveDifficultyLevel, 0, 24, 4, 8)), OwnerId);
  SetInventoryDominatorOwner;
  if GetDefGenerator <> nil then begin
    GetDefGenerator.DamageFactor := Max(0.14, 0.7 - Galaxy.GetEffectiveDifficultyLevel * 0.01);
    GetHull.Armor := Round(Galaxy.GetEffectiveDifficultyLevel / 8) + 11;
  end;
  ImproveStandardEquipment;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  if Speed = 0 then raise Exception.Create(DominatorZeroSpeedError);
end;
{ @end $5E831C }

{ @routine $5E87D8 TKling_InitKeller }
procedure TKling.InitKeller(Star: TStar);
begin
  TypeId := stKling;
  OwnerId := oiDominator;
  KlingType := ktBoss;
  DominatorSeries := dsKeller;
  SetMoney(MaxInt);
  NodeReserve := Round(NextRandomFloatRange(0.8, 1.2, RandomState) * DominatorShipDefinitions[KlingType].BaseNodeReserve);
  Position.X := 0;
  Position.Y := 0;
  CurrentStar := Star;
  CurrentStar.Ships.Add(Self);
  CurrentStar.DominatorSeries := DominatorSeries;
  HomePlanet := nil;
  CurrentPlanet := nil;
  Inc(CurrentStar.ShipTypeCounts[stKling]);
  Name := DominatorShipDefinitions[KlingType].DisplayNames[DominatorSeries];
  RefreshCombatSkills;
  ActiveProgramAppliedTurn := 0;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  CreateAndEquipHull(RoundAndTruncateToHundreds((HullCapacityScale * 4000) * Galaxy.GetDominatorBossHullScale * NextRandomFloatRange(0.9, 1.1, RandomState)), 8, oiDominator, -1, False);
  CreateAndEquipFuelTanks(100, 8, oiDominator);
  CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 8, oiDominator);
  CreateAndEquipWeapon(t_TorpedoTube, Round(WeaponInfos[t_TorpedoTube].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_Vertix, Round(WeaponInfos[t_Vertix].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_IMHO9000, Round(WeaponInfos[t_IMHO9000].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_Multiresonator, Round(WeaponInfos[t_Multiresonator].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  if Galaxy.GetDifficultyTierIndex > 0 then
    CreateAndEquipWeapon(t_AtomicVision, Round(WeaponInfos[t_AtomicVision].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipDefGenerator(Round(DefGeneratorBaseSize * EquipmentSizeFactors[5]), 8, oiDominator);
  Inc(CreateAndEquipRepairRobot(Round(RepairRobotBaseSize * EquipmentSizeFactors[5]), Round(RemapClamped(Galaxy.GetEffectiveDifficultyLevel, 0, 24, 4, 8)), OwnerId).RepairPoints, Galaxy.GetEffectiveDifficultyLevel);
  SetInventoryDominatorOwner;
  if (GetDefGenerator <> nil) and GetDefGenerator.HasStandardStats then
    case Galaxy.GetDifficultyTierIndex of
      0: ;
      1: GetDefGenerator.Improve(ikMinor);
      2: GetDefGenerator.Improve(ikMedium);
      else GetDefGenerator.Improve(ikMajor);
    end;
  ImproveStandardEquipment;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  if Speed = 0 then raise Exception.Create(DominatorZeroSpeedError);
end;
{ @end $5E87D8 }

{ @routine $5E8C20 TKling_InitTerron }
procedure TKling.InitTerron(Star: TStar);
var I: Integer; Planet: TPlanet; Weapon: TWeapon;
begin
  TypeId := stKling;
  OwnerId := oiDominator;
  KlingType := ktBoss;
  DominatorSeries := dsTerron;
  SetMoney(MaxInt);
  NodeReserve := Round(NextRandomFloatRange(0.8, 1.2, RandomState) * DominatorShipDefinitions[KlingType].BaseNodeReserve);
  Position.X := 1000;
  Position.Y := 0;
  CurrentStar := Star;
  CurrentStar.Name := LookupLocalizedTextByKey('Star.' + DominatorSeriesNames[DominatorSeries]);
  for I := 0 to Star.Planets.Count - 1 do begin
    Planet := Star.Planets[I];
    if Planet.OwnerId in [oiMaloc..oiGaal, oiPirate] then begin
      Planet.OwnerId := oiMaloc;
      Planet.RaceId := oiMaloc;
    end;
  end;
  CurrentStar.Ships.Add(Self);
  CurrentStar.DominatorSeries := DominatorSeries;
  HomePlanet := nil;
  CurrentPlanet := nil;
  Inc(CurrentStar.ShipTypeCounts[stKling]);
  Name := DominatorShipDefinitions[KlingType].DisplayNames[DominatorSeries];
  RefreshCombatSkills;
  ActiveProgramAppliedTurn := 0;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  Inc(CreateAndEquipHull(RoundAndTruncateToHundreds((HullCapacityScale * 10000) * Galaxy.GetDominatorBossHullScale * NextRandomFloatRange(0.9, 1.1, RandomState)), 8, oiDominator, -1, False).Armor, Galaxy.GetEffectiveDifficultyLevel div 4);
  CreateAndEquipFuelTanks(100, 8, oiDominator);
  CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 8, oiDominator);
  Weapon := CreateAndEquipWeapon(t_IMHO9000, Round(WeaponInfos[t_IMHO9000].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  Inc(Weapon.Range, 5 * Galaxy.GetEffectiveDifficultyLevel);
  Inc(Weapon.MaxDamage, Galaxy.GetEffectiveDifficultyLevel div 2);
  CreateAndEquipWeapon(t_MissileLauncher, Round(WeaponInfos[t_MissileLauncher].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipWeapon(t_MissileLauncher, Round(WeaponInfos[t_MissileLauncher].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  Weapon := CreateAndEquipWeapon(t_Multiresonator, Round(WeaponInfos[t_Multiresonator].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  Inc(Weapon.Range, 5 * Galaxy.GetEffectiveDifficultyLevel);
  Inc(Weapon.MaxDamage, Galaxy.GetEffectiveDifficultyLevel div 2);
  if Galaxy.GetDifficultyTierIndex > 1 then
    CreateAndEquipWeapon(t_TorpedoTube, Round(WeaponInfos[t_TorpedoTube].AverageSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipDefGenerator(Round(DefGeneratorBaseSize * EquipmentSizeFactors[5]), 8, oiDominator);
  CreateAndEquipRepairRobot(Round(RepairRobotBaseSize * EquipmentSizeFactors[5]), Round(RemapClamped(Galaxy.GetEffectiveDifficultyLevel, 0, 24, 4, 8)), OwnerId);
  SetInventoryDominatorOwner;
  if (GetDefGenerator <> nil) and GetDefGenerator.HasStandardStats then
    case Galaxy.GetDifficultyTierIndex of
      0: ;
      1: GetDefGenerator.Improve(ikMinor);
      2: GetDefGenerator.Improve(ikMedium);
      else GetDefGenerator.Improve(ikMajor);
    end;
  GetHull.Armor := Round(Galaxy.GetEffectiveDifficultyLevel / 8) + 11;
  ImproveStandardEquipment;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  if Speed = 0 then raise Exception.Create(DominatorZeroSpeedError);
end;
{ @end $5E8C20 }

{ @routine $5E91DC TKling_InitializeDominator }
procedure TKling.InitializeDominator(Kind: TKlingType; Planet: TPlanet; Series: TDominatorSeries);
begin
  TypeId := stKling;
  OwnerId := oiDominator;
  KlingType := Kind;
  DominatorSeries := Series;
  SetMoney(Round(Galaxy.MaxRangerWealth * DominatorShipDefinitions[Kind].InitialWealthScale));
  NodeReserve := Round((NextRandomUnitFloat(RandomState) + 0.5) * DominatorShipDefinitions[Kind].BaseNodeReserve);
  if KlingType <> ktBoss then begin
    CurrentStar := Planet.CurrentStar;
    CurrentStar.Ships.Add(Self);
    HomePlanet := nil;
    CurrentPlanet := Planet;
  end;
  Inc(CurrentStar.ShipTypeCounts[stKling]);
  Name := '';
  if (ModShipNameConfig <> nil) and (ModShipNameConfig.CountBlocks('Dominator') > 0) then
    Name := ModShipNameConfig.GetBlock('Dominator').GetParamValue(
      NextRandomIntRange(0, ModShipNameConfig.GetBlock('Dominator').GetParamCount - 1, RandomState)) +
      ' ' + '-' + IntToStr(Cardinal(Id) mod 100 + 1) + '-';
  if Length(GetName) = 0 then
    Name := LanguageDataConfig.GetBlock('ShipName').GetBlock('Kling').GetParamValue(
      NextRandomIntRange(0, LanguageDataConfig.GetBlock('ShipName').GetBlock('Kling').GetParamCount - 1, RandomState)) +
      ' ' + '-' + IntToStr(Cardinal(Id) mod 100 + 1) + '-';
  ActiveProgramAppliedTurn := 0;
  RefreshCombatSkills;
end;
{ @end $5E91DC }

{ @routine $5E978C TKling_InitGenerated }
procedure TKling.InitGenerated(Kind: TKlingType; Planet: TPlanet; Series: TDominatorSeries);
var
  ControlPercent, MinimumControl, MiddleControl, Tier, MaximumControl: Integer;
  MaximumSizeIndex, MinimumSizeIndex, Rating, WarRating, DistanceRating, Distribution: Integer;
  Roll, I, WeightSum, WeaponCount, TechLevel, ImprovementChance, Attempts: Integer;
  Equipment: TEquipment;
  WeaponType: TItemType;
  Chosen, Accepted: Boolean;
  // @nested $5E9514 RandomInteger
  function RandomInteger(BoundA, BoundB: Integer): Integer; // @addr $5E9514
  begin
    Result := NextRandomIntRange(BoundA, BoundB, RandomState);
  end;
  // @nested $5E9544 RandomEquipmentSize
  function RandomEquipmentSize(BaseSize, MinimumSizeIndex, MaximumSizeIndex: Integer): Integer; // @addr $5E9544
  begin
    Result := RandomInteger(Round(BaseSize * EquipmentSizeFactors[MinimumSizeIndex] * 0.9),
      Round(BaseSize * EquipmentSizeFactors[MaximumSizeIndex]));
  end;
  // @nested $5E95A8 SizeForKind
  function SizeForKind(BaseSize: Integer): Integer; // @addr $5E95A8
  begin
    Result := RandomEquipmentSize(BaseSize, DominatorEquipmentSizeIndices[KlingType, 1],
      DominatorEquipmentSizeIndices[KlingType, 0]);
  end;
  // @nested $5E95F0 RandomTuning
  function RandomTuning(MinimumColumn, MaximumColumn: Integer): Integer; // @addr $5E95F0
  var A, B: Integer;
  begin
    A := Round(RemapClamped(ControlPercent, MinimumControl, MiddleControl,
      DominatorGenerationTuning[Tier, MaximumColumn], DominatorGenerationTuning[Tier, MinimumColumn]));
    B := Round(RemapClamped(ControlPercent, MiddleControl, MaximumControl,
      DominatorGenerationTuning[Tier, MaximumColumn], DominatorGenerationTuning[Tier, MinimumColumn]));
    A := Min(A, B);
    Result := RandomInteger(A, B);
  end;
  // @nested $5E970C InterpolatedTuning
  function InterpolatedTuning(MinimumColumn, MaximumColumn: Integer): Integer; // @addr $5E970C
  begin
    Result := Round(RemapClamped(ControlPercent, MinimumControl, MaximumControl,
      DominatorGenerationTuning[Tier, MaximumColumn], DominatorGenerationTuning[Tier, MinimumColumn]));
  end;

begin
  InitializeDominator(Kind, Planet, Series);
  ControlPercent := Galaxy.GetFactionControlPercent(sfDominators);
  Rating := Round(125 * Galaxy.GetEffectiveDifficultyLevel + RemapClamped(Galaxy.CurrentTurn, GalaxyWarmupTurns, 22200, 0, 3000));
  WarRating := -150 * Galaxy.WarDeltaWin[1];
  DistanceRating := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
    if (CurrentStar.StarDistances[I].Star.ControlFaction <> sfDominators) or
      (CurrentStar.StarDistances[I].Star.Status.CustomFaction <> '') then begin
      DistanceRating := 40 * I;
      Break;
    end;
  if WarRating > 0 then Rating := Rating + WarRating + DistanceRating div 4
  else if WarRating + DistanceRating < 0 then Rating := Rating + WarRating + DistanceRating
  else Inc(Rating, (WarRating + DistanceRating) div 4);
  Rating := Max(0, Rating);
  Tier := Rating div 1000 + 1;
  if NextRandomIntRange(0, 1000, RandomState) < Rating mod 1000 then Inc(Tier);
  if Kind = ktBertor then Inc(Tier);
  if Kind = ktKlig then Dec(Tier);
  Tier := Max(1, Min(Tier, 7));
  if Galaxy.CurrentTurn >= 666 then
    if Galaxy.DominatorModLevel = 1 then Tier := Max(Tier, 5)
    else if Galaxy.DominatorModLevel = 2 then Tier := Max(Tier, 6)
    else if Galaxy.DominatorModLevel = 3 then Tier := Max(Tier, 7);
  MinimumControl := 1;
  MaximumControl := DominatorGenerationTuning[Tier, 1];
  MiddleControl := Round(RemapClamped(Galaxy.CurrentTurn, GalaxyWarmupTurns, 11250, MaximumControl div 4, 3 * MaximumControl div 4));
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  CreateAndEquipHull(Round(RandomInteger(DominatorShipDefinitions[KlingType].MinimumHullSize,
    DominatorShipDefinitions[KlingType].MaximumHullSize) * HullCapacityScale), RandomTuning(2, 3), oiDominator, -1, False);
  CreateAndEquipEngine(SizeForKind(EngineBaseSize), RandomTuning(10, 11), oiDominator);
  if RandomInteger(1, 100) <= InterpolatedTuning(14, 15) then
    CreateAndEquipRepairRobot(SizeForKind(RepairRobotBaseSize), RandomTuning(4, 5), oiDominator);
  if RandomInteger(1, 100) <= InterpolatedTuning(16, 17) then
    CreateAndEquipDefGenerator(SizeForKind(DefGeneratorBaseSize), RandomTuning(6, 7), oiDominator);
  TechLevel := Galaxy.TechLevel;
  CreateAndEquipFuelTanks(SizeForKind(FuelTanksBaseSize), RandomInteger(1, TechLevel), oiDominator);
  CreateAndEquipRadar(SizeForKind(RadarBaseSize), RandomInteger(1, TechLevel), oiDominator);
  CreateAndEquipScanner(SizeForKind(ScannerBaseSize), RandomInteger(1, TechLevel), oiDominator);
  CreateAndEquipCargoHook(SizeForKind(CargoHookBaseSize), RandomInteger(1, Min(TechLevel, 7)), oiDominator);
  Distribution := DominatorWeaponDistributionByTier[Tier];
  WeaponCount := RandomTuning(12, 13);
  for I := 1 to WeaponCount do begin
    Accepted := False;
    Attempts := 0;
    repeat
      Inc(Attempts);
      if Attempts > 1000 then Break;
      WeaponType := t_IndustrialLaser;
      Roll := RandomInteger(1, 100);
      Chosen := False;
      WeightSum := 0;
      while (WeaponType <= t_TorpedoTube) and not Chosen do begin
        Inc(WeightSum, DominatorWeaponWeights[Distribution, KlingType, WeaponType]);
        if Roll <= WeightSum then begin
          MaximumSizeIndex := DominatorEquipmentSizeIndices[KlingType, 0];
          MinimumSizeIndex := DominatorEquipmentSizeIndices[KlingType, 1];
          if WeaponInfos[WeaponType].ShotType = wstAreaDamage then begin
            MaximumSizeIndex := 2;
            MinimumSizeIndex := 1;
          end;
          Accepted := not Galaxy.AreDominatorRacialWeaponsEnabled or
            (((DominatorSeries <> dsBlazer) or not (WeaponType in [t_IMHO9000, t_Vertix])) and
             ((DominatorSeries <> dsTerron) or not (WeaponType in [t_Vertix, t_TorpedoTube])) and
             ((DominatorSeries <> dsKeller) or not (WeaponType in [t_IMHO9000, t_TorpedoTube])));
          if Accepted then CreateAndEquipWeapon(WeaponType,
            RandomEquipmentSize(WeaponInfos[WeaponType].AverageSize, MaximumSizeIndex, MinimumSizeIndex), RandomTuning(8, 9), oiDominator);
          Chosen := True;
        end;
        Inc(WeaponType);
      end;
    until Accepted;
  end;
  Roll := GetCargoFreeSpace;
  if Roll < 0 then begin
    Inc(GetHull.Weight, Abs(Roll));
    if GetEngine <> nil then GetEngine.Improve(ikAny);
  end;
  GetHull.HullPoints := GetHull.Weight;
  RefreshGraphicSize;
  RefreshDerivedStats(True);
  if (GetScanner <> nil) and (RandomInteger(1, 100) > ControlPercent) then GetScanner.Improve(ikAny);
  if (GetRadar <> nil) and (RandomInteger(1, 100) > ControlPercent) then GetRadar.Improve(ikAny);
  if (GetCargoHook <> nil) and (RandomInteger(1, 100) > ControlPercent) then GetCargoHook.Improve(ikAny);
  if (GetFuelTanks <> nil) and (RandomInteger(1, 100) > ControlPercent) then GetFuelTanks.Improve(ikAny);
  ImprovementChance := RandomTuning(18, 19);
  if ImprovementChance > 0 then
    case DominatorSeries of
      dsBlazer: for I := 1 to 5 do
        if (Weapons[I] <> nil) and (RandomInteger(1, 100) <= ImprovementChance) then Weapons[I].Improve(ikAny);
      dsKeller: if (GetDefGenerator <> nil) and (RandomInteger(1, 100) <= ImprovementChance) then GetDefGenerator.Improve(ikAny);
      dsTerron: if (GetRepairRobot <> nil) and (RandomInteger(1, 100) <= ImprovementChance) then GetRepairRobot.Improve(ikAny);
    end;
  for I := 1 to Inventory.Count - 1 do begin
    Equipment := Inventory[I];
    Equipment.ConditionPercent := NextRandomIntRange(5, 100, RandomState);
  end;
  SetInventoryDominatorOwner;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
end;
{ @end $5E978C }

{ @routine $5EA15C TKling_SaveToBuffer }
procedure TKling.SaveToBuffer(Buffer: TBufEC);
begin
  inherited;
  Buffer.AddAnsiChar(AnsiChar(KlingType));
  Buffer.AddAnsiChar(AnsiChar(DominatorSeries));
  Buffer.AddIntegerValue(ActiveProgramAppliedTurn);
  Buffer.AddAnsiChar(AnsiChar(ActiveProgramId));
end;
{ @end $5EA15C }

{ @routine $5EA1BC TKling_LoadFromBuffer }
procedure TKling.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited;
  KlingType := TKlingType(Buffer.GetByte);
  DominatorSeries := TDominatorSeries(Buffer.GetByte);
  ActiveProgramAppliedTurn := Buffer.GetInt32;
  ActiveProgramId := TProgramIndex(Buffer.GetByte);
  if LoadedSaveVersion <= 147 then ClearRecentlyDroppedItems;
end;
{ @end $5EA1BC }

{ @routine $5EA238 TKling_ResolveLoadedReferences }
procedure TKling.ResolveLoadedReferences(Galaxy: TGalaxy);
begin inherited; end;
{ @end $5EA238 }

{ @routine $5EA254 TKling_NextDay }
procedure TKling.NextDay;
begin
  try
    if (Integer(Seed) + Galaxy.CurrentTurn) mod 100 = 0 then CalculateStrength;
    AuraEffectShownThisTurn := False;
    inherited;
    if (ScriptShip <> nil) and HasScriptControl then begin
      ScriptNextDay;
      if (ScriptShip <> nil) and (KlingType <> ktBoss) then Exit;
    end;
    if KlingType = ktBoss then begin
      if Self = BlazerShip then BlazerNextDayLogic
      else if Self = KellerShip then KellerNextDayLogic
      else if Self = TerronShip then TerronNextDayLogic
      else NextDayLogic;
    end else if KlingType = ktBertor then MiniBossNextDayLogic else NextDayLogic;
    if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TKling.NextDay ' + GetFullName(' '));
    end;
  end;
end;
{ @end $5EA254 }

{ @routine $5EA50C TKling_NextDayLogic }
procedure TKling.NextDayLogic;
var Stage: Integer; Ship: TShip;

begin
  Stage := 0;
  try
    if CurrentPlanet <> nil then begin
      Stage := 1;
      RepairBrokenEquipmentAtLocation;
      RefuelAtLocation;
      RefreshDerivedStats(True);
      OrderTakeoff;
    end else if ((BlazerShip <> nil) and (DockedTo = BlazerShip)) or ((KellerShip <> nil) and (DockedTo = KellerShip)) then OrderTakeoff
    else if (TerronShip <> nil) and (DockedTo = TerronShip) then DestroyQueued := True
    else if InNormalSpace then begin
      Stage := 2;
      if IsProgramActive(prgDisconnection) then Exit;
      AssignWeaponTargetsInStar;
      if IsProgramActive(prgInsanity) then begin MoveToRandomPatrolPoint; Exit; end;
      if (DominatorSeries = dsTerron) and (TerronShip <> nil) and not HasIndependentScriptFaction and (Galaxy.TerronToStarTurn >= TerronTransformationFlag) then begin
        if CurrentStar <> TerronShip.CurrentStar then OrderJump(TerronShip.CurrentStar, False)
        else OrderLanding(TerronShip, False);
      end else begin
        Stage := 3;
        if (Order = soFollowShip) and (OrderTarget <> nil) and (OrderTarget is TShip) and (OrderTarget <> EnemyShip) and
          not (TShip(OrderTarget).Order in [soMove, soJump]) then OrderNone(False);
        if (PartnerShip <> nil) and (PartnerShip.CurrentStar <> CurrentStar) then OrderJump(PartnerShip.CurrentStar, True)
        else if (PartnerShip <> nil) and PartnerShip.InNormalSpace and (PartnerShip.Order = soJump) and (PartnerShip.EstimateOrderTravelTurns <= 3) then
          OrderFollowShip(PartnerShip, fmFollowNear, True)
        else if (not OrderAbsolute or not (OrderTarget is TShip)) and (not (OrderTarget is TStar) or (EstimateOrderTravelTurns >= 3)) then begin
          Stage := 4;
          SelectEnemyShipInStar;
          Stage := 5;
          EngageEnemyShip;
          Stage := 6;
          UpdateAfterburnerState;
          Stage := 7;
          if (Order = soNone) and HasHullDamageOrBrokenEquippedItems then LandOnRandomFriendlyPlanet(False);
          Stage := 8;
          if (Order = soNone) and (CurrentStar.Id = Galaxy.KellerResearchTargetStarId) and (KellerShip <> nil) and
            (NextRandomIntRange(0, 99, RandomState) < 20) and not HasIndependentScriptFaction then LandOnRandomFriendlyPlanet(False);
          Stage := 9;
          if (Order = soNone) and (KellerShip <> nil) and (CurrentStar = KellerShip.CurrentStar) and KellerShip.InNormalSpace and
            (NextRandomIntRange(0, 99, RandomState) < 20) then OrderMove(KellerShip.Position, False);
          Stage := 10;
          if Order in [soNone..soMove] then begin
            Stage := 11;
            Ship := SelectBertorLeader;
            if Ship <> nil then
              if Sqrt(Sqr(Ship.Position.X) + Sqr(Ship.Position.Y)) > Min(8 * Ship.Speed, 2 * Speed) then begin
                Stage := 12;
                OrderFollowShip(Ship, fmMinWeaponRange, False);
              end;
          end;
          Stage := 13;
          if Order = soNone then MoveToRandomPatrolPoint;
        end;
      end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TKling.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5EA50C }

{ @routine $5EABD0 TKling_MiniBossNextDayLogic }
procedure TKling.MiniBossNextDayLogic;
var Stage: Integer;
begin
  Stage := 0;
  try
    if CurrentPlanet <> nil then begin
      Stage := 1;
      RepairBrokenEquipmentAtLocation;
      RefuelAtLocation;
      RefreshDerivedStats(True);
      OrderTakeoff;
      Exit;
    end else if (TerronShip <> nil) and (DockedTo = TerronShip) then begin DestroyQueued := True; Exit; end
    else if DockedTo <> nil then begin OrderTakeoff; Exit; end
    else begin
      if not InNormalSpace then Exit;
      Stage := 2;
      AssignWeaponTargetsInStar;
      if (DominatorSeries = dsTerron) and (TerronShip <> nil) and (Galaxy.TerronToStarTurn >= TerronTransformationFlag) then begin
        if CurrentStar <> TerronShip.CurrentStar then OrderJump(TerronShip.CurrentStar, False)
        else OrderLanding(TerronShip, False);
        Exit;
      end else begin
        Stage := 3;
        if (OrderAbsolute and (OrderTarget is TShip)) or ((OrderTarget is TStar) and (EstimateOrderTravelTurns < 3)) then Exit;
        begin
          Stage := 4;
          SelectEnemyShipInStar;
          EngageEnemyShip;
          if (Order = soNone) and HasHullDamageOrBrokenEquippedItems then LandOnRandomFriendlyPlanet(False);
          if (Order = soNone) and (CurrentStar.Id = Galaxy.KellerResearchTargetStarId) and (KellerShip <> nil) and
            (NextRandomIntRange(0, 99, RandomState) < 20) then LandOnRandomFriendlyPlanet(False);
          if (Order = soNone) and (KellerShip <> nil) and (CurrentStar = KellerShip.CurrentStar) and KellerShip.InNormalSpace and
            (NextRandomIntRange(0, 99, RandomState) < 20) then OrderMove(KellerShip.Position, False);
          Stage := 5;
          if (Order in [soNone..soMove]) and ((CurrentStar.Id <> Galaxy.KellerResearchTargetStarId) or (KellerShip = nil)) then
            if (Galaxy.CurrentTurn + Integer(Seed)) mod (200 - 20 * Round(Galaxy.GetEffectiveDifficultyLevel / 8)) = 0 then RelocateBertorWithinConstellation;
          if Order = soNone then MoveToRandomPatrolPoint;
          Stage := 6;
          if Order <> soJump then
            if SpawnEscortShips(ktKlig, 5) > 0 then OrderNone(False);
        end;
      end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TKling.MiniBossNextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5EABD0 }

{ @routine $5EB140 TKling_BlazerNextDayLogic }
procedure TKling.BlazerNextDayLogic;
var Stage: Integer;
begin
  Stage := 0;
  try
    if CurrentStar.ShipTypeCounts[stKling] = CurrentStar.Ships.Count then begin
      Stage := 1;
      RepairBrokenEquipmentAtLocation;
      GetHull.HullPoints := GetHull.Weight;
      RefuelAtLocation;
      RefreshDerivedStats(True);
    end else if GetPlayer.CurrentStar <> CurrentStar then begin
      Stage := 2;
      RepairBrokenEquipmentAtLocation;
      GetHull.HullPoints := Max(GetHull.HullPoints, GetHull.Weight div 4);
      RefuelAtLocation;
    end;
    if InNormalSpace then begin
      Stage := 3;
      if Galaxy.BlazerLandingPlanetId > 0 then begin
        Stage := 4;
        OrderLanding(Galaxy.IdToPlanet(Galaxy.BlazerLandingPlanetId), False);
      end else begin
        Stage := 5;
        CoordinateSeriesInvasions(dsBlazer);
        if not OrderAbsolute then begin
          Stage := 6;
          if DaysSincePlayerSeen > 3 then
            if ((Galaxy.CurrentTurn + Integer(Seed)) mod (10 - Round(Galaxy.GetEffectiveDifficultyLevel / 8)) = 0) and
              (CurrentStar.ShipTypeCounts[stKling] >= 1) then RetreatToReinforcedStar;
          if Order = soNone then MoveToRandomPatrolPoint;
        end;
        Stage := 7;
        AssignWeaponTargetsInStar;
        if not RetreatIfHullCritical and (GetPlayer.CurrentStar = CurrentStar) then begin
          SelectEnemyShipInStar;
          EngageEnemyShip;
        end;
      end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TKling.BlazerNextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5EB140 }

{ @routine $5EB568 TKling_KellerNextDayLogic }
procedure TKling.KellerNextDayLogic;
var IntervalBonus: Integer; Hole: THole; Stage: Integer;
begin
  Stage := 0;
  try
    RepairBrokenEquipmentAtLocation;
    RefuelAtLocation;
    if GetPlayer.CurrentStar <> CurrentStar then GetHull.HullPoints := Max(GetHull.HullPoints, GetHull.Weight div 2);
    Stage := 1;
    SelectKellerMission;
    SelectKellerReinforcementMission;
    if InNormalSpace then begin
      CoordinateSeriesInvasions(dsKeller);
      if (Galaxy.CountFactionStars(sfDominators) < 2) and (GetPlayer <> nil) and
        (GetPlayer.IsOutsideStarSpace or (GetPlayer.CurrentStar <> CurrentStar)) then IntervalBonus := 30
      else IntervalBonus := 1;
      if ((Galaxy.KellerResearchTargetStarId <> 0) and (Galaxy.KellerResearchTargetStarId <> CurrentStar.Id)) or
        (Galaxy.CurrentTurn mod Galaxy.ScaleIntByTechLevel(5, IntervalBonus + 30) = 0) or (GetHull.HullPoints < 1300) or
        ((GetPlayer <> nil) and ((GetPlayer.CurrentStar = CurrentStar) or (GetPlayer.OrderTarget = CurrentStar)) and
        (Galaxy.TechLevel < 7) and (Galaxy.GetFactionControlPercent(sfCoalition) < 70)) then begin
        Stage := 2;
        Hole := Galaxy.FindHoleInStarByKind(CurrentStar, 4);
        if Hole <> nil then
          if ((Hole.CreatedTurn + 3 <= Galaxy.CurrentTurn) and ((Galaxy.KellerResearchTargetStarId = 0) or (GetHull.HullPoints < 700))) or
            ((Galaxy.KellerResearchTargetStarId <> 0) and (Galaxy.KellerResearchTargetStarId <> CurrentStar.Id)) then begin
            OrderJumpHole(Hole, False);
            Galaxy.KellerMissionState := 4;
          end;
      end;
      Stage := 3;
      if Order = soNone then MoveNearKellerMissionHole;
      AssignWeaponTargetsInStar;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TKling.KellerNextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5EB568 }

{ @routine $5EB9F0 TKling_TerronNextDayLogic }
procedure TKling.TerronNextDayLogic;
var Stage: Integer;
begin
  Stage := 0;
  try
    RepairBrokenEquipmentAtLocation;
    RefuelAtLocation;
    if GetPlayer.CurrentStar <> CurrentStar then GetHull.HullPoints := Max(GetHull.HullPoints, GetHull.Weight div 4);
    if InNormalSpace then begin
      if Galaxy.TerronToStarTurn > 0 then OrderMove(MakePointF(-100, -100), False)
      else begin
        Stage := 1;
        CoordinateSeriesInvasions(dsTerron);
        OrderMove(MakePointF(0, 0), False);
        Stage := 2;
        if Galaxy.TerronWeaponLockTurn = 0 then AssignWeaponTargetsInStar;
        if GetPlayer.CurrentStar = CurrentStar then SelectEnemyShipInStar;
      end;
    end;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TKling.TerronNextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5EB9F0 }

{ @routine $5EBD14 TKling_SelectBertorLeader }
function TKling.SelectBertorLeader: TShip;
var Ship: TShip; I: Integer; Count: Cardinal; PlayerIsBertor: Boolean;
begin
  Result := nil;
  Count := 0;
  PlayerIsBertor := (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and
    IsPlayerCamouflageEffective(GetPlayer) and GetPlayer.ChameleonActive and (GetPlayer.ChameleonVisualType in [ktBertor]);
  if PlayerIsBertor then begin Result := GetPlayer; Inc(Count); end;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if Ship.InNormalSpace and (Ship is TKling) and ((Ship as TKling).KlingType in [ktBertor]) and
      ((Ship as TKling).DominatorSeries = DominatorSeries) then begin
      if Ship = PartnerShip then begin Result := Ship; Exit; end;
      if Count = 0 then Result := Ship else Result := nil;
      Inc(Count);
    end;
  end;
  if Count > 1 then begin
    Count := (Seed + CurrentStar.GenerationSeed) mod Count;
    if PlayerIsBertor then begin
      if Count = 0 then begin Result := GetPlayer; Exit; end;
      Dec(Count);
    end;
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if Ship.InNormalSpace and (Ship is TKling) and ((Ship as TKling).KlingType in [ktBertor]) and
        ((Ship as TKling).DominatorSeries = DominatorSeries) then begin
        if Count = 0 then begin Result := Ship; Exit; end;
        Dec(Count);
      end;
    end;
  end;
end;
{ @end $5EBD14 }

{ @routine $5EBF40 TKling_ShouldKamikaze }
function TKling.ShouldKamikaze: Boolean;
begin
  Result := False;
  if KlingType <> ktKlig then Exit;
  if EnemyShip = nil then Exit;
  if not EnemyShip.InNormalSpace then Exit;
  if EnemyShip.CurrentStar <> CurrentStar then Exit;
  if EnemyShip.IsHullDestroyed then Exit;
  if AfterburnerActive then
  begin
    Result := True;
    Exit;
  end;
  if PointDistance(Position, EnemyShip.Position) > Speed * 1.5 then Exit;
  if ChanceToWin(EnemyShip) <= 0.2 then Result := True;
end;
{ @end $5EBF40 }

{ @routine $5EC024 TKling_LandOnRandomFriendlyPlanet }
function TKling.LandOnRandomFriendlyPlanet(OverrideScriptOrder: Boolean): Boolean;
begin
  BuildReachablePlanetQueue;
  if PlanetQueue.Count > 0 then begin
    OrderLanding(PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)], OverrideScriptOrder);
    Result := True;
  end else Result := False;
end;
{ @end $5EC024 }

{ @routine $5EC094 TKling_BuildReachablePlanetQueue }
procedure TKling.BuildReachablePlanetQueue;
var I: Integer; Planet: TPlanet;
begin
  ClearPlanetQueue;
  PlanetQueue := TList.Create;
  if (Speed <> 0) and (CurrentStar.Status.CustomFaction = '') then
    for I := 0 to CurrentStar.Planets.Count - 1 do begin
      Planet := CurrentStar.Planets[I];
      if (Planet.OwnerId = oiDominator) or ((Planet.CurrentStar.Id = Galaxy.KellerResearchTargetStarId) and (Planet.OwnerId <> oiUninhabited) and (KellerShip <> nil)) then PlanetQueue.Add(Planet);
    end;
end;
{ @end $5EC094 }

{ @routine $5EC160 TKling_CanQueueReachablePlanet }
function TKling.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := Planet.OwnerId = oiDominator;
end;
{ @end $5EC160 }

{ @routine $5EC180 TKling_RetreatToReinforcedStar }
function TKling.RetreatToReinforcedStar: Boolean;
const DominatorShipMask = [stKling];
var I: Integer; Star: TStar; Stars: TList;
begin
  Result := False;
  Stars := TList.Create;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if (Star <> CurrentStar) and (Star.Constellation.Id <> 20) and not IsStarProtectedByScript(Star) and
      ((Star.ShipTypeCounts[stKling] >= 10) or (Star.SumBestRangerRelativeStrength(DominatorShipMask) >= DominatorRetreatStrengthByTier[Star.Constellation.HomeDistanceTier])) and
      (Star.ShipTypeCounts[stKling] >= 6) and
      ((KellerShip = nil) or not KellerShip.InNormalSpace or (KellerShip.CurrentStar <> Star)) and
      ((TerronShip = nil) or not TerronShip.InNormalSpace or (TerronShip.CurrentStar <> Star)) and
      (Star.ControlFaction = sfDominators) and (Star.DominatorSeries = DominatorSeries) and (Star.Status.CustomFaction = '') and (Star.Battle = 0) then Stars.Add(Star);
  end;
  if Stars.Count > 2 then begin
    I := Stars.IndexOf(TransitOriginStar);
    if I > 0 then Stars.Delete(I); // Native retains the previous system when it occupies index zero.
  end;
  if Stars.Count > 0 then begin
    OrderJump(Stars[NextRandomIntRange(0, Stars.Count - 1, RandomState)], True);
    Result := True;
  end;
  Stars.Free;
end;
{ @end $5EC180 }

{ @routine $5EC358 TKling_RetreatIfHullCritical }
function TKling.RetreatIfHullCritical: Boolean;
begin
  Result := False;
  if GetHull.HullPoints <= GetHull.Weight div 3 then begin
    Result := True;
    if (Order <> soJump) and not RetreatToReinforcedStar then Result := False;
  end;
end;
{ @end $5EC358 }

{ @routine $5EC3B0 TKling_FindKellerAttackTarget }
function TKling.FindKellerAttackTarget: TStar;
const CoalitionShipMask = [stRanger..stTranclucator];
var I, J, Score, BestScore, Index: Integer; BestStar, Star, Neighbor: TStar;
begin
  BestScore := MaxInt;
  BestStar := nil;
  Index := SeededRandomIntRange(0, Galaxy.Stars.Count - 1, Cardinal(Galaxy.CurrentTurn) + Galaxy.GenerationSeed);
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    IncrementWrapped(Index, 0, Galaxy.Stars.Count - 1);
    Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
    if (Star.Constellation.Id <> 20) and ((BlazerShip = nil) or (BlazerShip.CurrentStar <> Star)) and
      ((TerronShip = nil) or (TerronShip.CurrentStar <> Star)) and ((Star.ControlFaction <> sfDominators) or (Star.Battle <> 0)) then
      if (Galaxy.CurrentTurn > GalaxyWarmupTurns) or (PointDistanceSquared(Star.Position, GetPlayer.CurrentStar.Position) >= Sqr((1 - Galaxy.CurrentTurn / GalaxyWarmupTurns) * 70 + 35)) then
        if ((Star.Battle = 0) or (Star.DominatorSeries <> dsKeller) or (Star.ShipTypeCounts[stKling] <= 6)) and not IsStarProtectedByScript(Star) then begin
          Score := 0;
          for J := 1 to Galaxy.Stars.Count - 1 do begin
            Neighbor := TObject(Star.StarDistances[J].Star) as TStar;
            if (Neighbor.ControlFaction = sfCoalition) and (Neighbor.Status.CustomFaction = '') then Inc(Score, Star.StarDistances[J].Distance)
            else if Neighbor.Battle <> 0 then Inc(Score, 2 * Star.StarDistances[J].Distance);
          end;
          if (Star.Battle <> 0) and (Star.DominatorSeries <> dsKeller) then Score := Round(2 * Score);
          Score := Round(Score * RemapClamped(Star.CountShipsByTypeMask(CoalitionShipMask), 1, 10, 2, 10));
          Score := Round(Score * NextRandomFloatRange(1, 3, RandomState));
          if (GetPlayer.HomePlanet.CurrentStar = Star) and (Galaxy.CurrentTurn < Galaxy.InterpolateDifficulty(-1, 1.2, 1, 0.7, 0.5) * 800 + GalaxyWarmupTurns) then Score := MaxInt - 1;
          if Score < BestScore then begin BestScore := Score; BestStar := Star; end;
        end;
  end;
  Result := BestStar;
end;
{ @end $5EC3B0 }

{ @routine $5EC6FC TKling_FindKellerReinforcementTarget }
function TKling.FindKellerReinforcementTarget: TStar;
var I, J, Score, BestScore, Index: Integer; BestStar, Star: TStar; Ship: TShip;
begin
  BestScore := MaxInt;
  BestStar := nil;
  Index := SeededRandomIntRange(0, Galaxy.Stars.Count - 1, Cardinal(Galaxy.CurrentTurn) + Galaxy.GenerationSeed);
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    IncrementWrapped(Index, 0, Galaxy.Stars.Count - 1);
    Star := Galaxy.Stars[Index];
    if (Star.Constellation.Id <> 20) and ((BlazerShip = nil) or (BlazerShip.CurrentStar <> Star)) and
      ((TerronShip = nil) or (TerronShip.CurrentStar <> Star)) and (Star.ControlFaction = sfDominators) and
      ((Star.DominatorSeries <> dsKeller) or (Star.Status.CustomFaction <> '')) and not IsStarProtectedByScript(Star) then begin
      Score := 0;
      for J := 0 to Star.Ships.Count - 1 do begin
        Ship := Star.Ships[J];
        if not Ship.InHyperspace and (Ship is TKling) then
          if (Ship as TKling).DominatorSeries = dsKeller then Dec(Score) else Inc(Score);
      end;
      if (Score >= 0) and (Score < BestScore) then begin BestScore := Score; BestStar := Star; end;
    end;
  end;
  Result := BestStar;
end;
{ @end $5EC6FC }

{ @routine $5EC8B4 TKling_SelectKellerMission }
procedure TKling.SelectKellerMission;
var Text: WideString;
begin
  if (Galaxy.KellerMissionState = 0) and (Galaxy.KellerLeaveTurn = 0) then
    if (Galaxy.CurrentTurn mod (NextRandomIntRange(60, 80, RandomState) + Galaxy.ScaleIntByTechLevel(20, 0)) = 0) or
      (Galaxy.CurrentTurn mod 230 = 0) or
      ((Galaxy.CurrentTurn mod NextRandomIntRange(5, 10, RandomState) = 0) and (Galaxy.CountFactionStars(sfDominators) < 2)) or
      (Galaxy.KellerResearchTargetStarId <> 0) then begin
      if Galaxy.KellerResearchTargetStarId = 0 then Galaxy.KellerTargetStar := FindKellerAttackTarget
      else Galaxy.KellerTargetStar := Galaxy.IdToStar(Galaxy.KellerResearchTargetStarId);
      if Galaxy.KellerTargetStar <> nil then begin
        Galaxy.KellerMissionState := 1;
        if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) then begin
          Text := FormatText1(LocalizedColorText('Artefacts.ArtAnalyzer.KellerHole'), TextHighlightColorTag, '<Star>', Galaxy.KellerTargetStar.Name);
          if Text <> '' then AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, '');
        end;
      end;
    end;
end;
{ @end $5EC8B4 }

{ @routine $5ECB34 TKling_SelectKellerReinforcementMission }
procedure TKling.SelectKellerReinforcementMission;
begin
  if (Galaxy.KellerMissionState = 0) and (Galaxy.KellerResearchTargetStarId = 0) and (Galaxy.KellerLeaveTurn = 0) and
    (NextRandomIntRange(0, 1000, RandomState) + 1000 <= Galaxy.CurrentTurn) then
    if NextRandomIntRange(0, 10000, RandomState) <
      Galaxy.GetFactionControlPercent(sfDominators) * (100 - Galaxy.GetFactionControlPercent(sfDominators)) then
      if NextRandomIntRange(0, 1000, RandomState) > RemapClamped(Galaxy.GetDominatorSeriesControlShare(dsKeller), 0.7, 1.2, 0, 1000) then begin
        Galaxy.KellerTargetStar := FindKellerReinforcementTarget;
        if Galaxy.KellerTargetStar <> nil then Galaxy.KellerMissionState := 1;
      end;
end;
{ @end $5ECB34 }

{ @routine $5ECD28 TKling_OpenKellerMissionHole }
procedure TKling.OpenKellerMissionHole;
var Ship: TKling; Hole: THole; Angle, Radius: Single; I, Count, Threshold, RandomMaximum: Integer; Series: TDominatorSeries;
  // @nested $5ECC94 SpawnReinforcement
  procedure SpawnReinforcement(OrderData: Integer); // @addr $5ECC94
  begin
    Ship := TObject(DominatorSpawnPlanet.SpawnWeightedDominatorShip) as TKling;
    Ship.Order := soJumpHole;
    Ship.OrderTarget := Hole;
    if OrderData = 0 then Ship.OrderStateData := DominatorSpawnPlanet.CurrentStar.ShipTypeCounts[stKling] or $10000
    else Ship.OrderStateData := OrderData;
    Ship.InHyperspace := True;
    Ship.CurrentPlanet := nil;
  end;
begin
  if Galaxy.KellerMissionState = 2 then begin
    Galaxy.KellerMissionState := 3;
    for I := 0 to Galaxy.Holes.Count - 1 do begin
      Hole := Galaxy.Holes[I];
      if Hole.HoleType = 0 then Hole.HoleType := 3;
    end;
    Hole := THole.Create;
    Hole.InitializeGraphic('');
    THoleSE(Hole.Graphic).SetState(1);
    Hole.Star1 := Galaxy.KellerTargetStar;
    Hole.Star2 := Hole.Star1;
    Hole.HoleType := 4;
    Hole.CreatedTurn := Galaxy.CurrentTurn;
    Angle := HeadingDegreesToRadians(NextRandomIntRange(0, 359, RandomState));
    Radius := NextRandomIntRange(2000, 3000, RandomState);
    Hole.Position1.X := Sin(Angle) * Radius;
    Hole.Position1.Y := Cos(Angle) * Radius;
    Hole.Position2.X := 100000;
    Hole.Position2.Y := 100000;
    Galaxy.Holes.Add(Hole);
    KellerShip.OrderNone(False);
    KellerShip.Order := soJumpHole;
    KellerShip.OrderTarget := Hole;
    KellerShip.OrderStateData := $10003;
    KellerShip.InHyperspace := True;
    DominatorSpawnPlanet.CurrentStar := Hole.Star1;
    Series := Hole.Star1.DominatorSeries;
    Hole.Star1.DominatorSeries := dsKeller;
    Threshold := Round(Galaxy.GetDominatorAggressionLevel * 1.25) + 60;
    RandomMaximum := Round(Galaxy.GetDominatorAggressionLevel * 0.125) + 1;
    Count := NextRandomIntRange(1, RandomMaximum, RandomState) + Round(RemapClamped(Galaxy.GetFactionControlPercent(sfDominators), 0, Threshold, 12, 2));
    if Galaxy.CurrentTurn >= 666 then
      if Galaxy.DominatorModLevel = 1 then Count := 15
      else if Galaxy.DominatorModLevel = 2 then Count := 17
      else if Galaxy.DominatorModLevel = 3 then Count := 19;
    DominatorSpawnPlanet.GenerationSeed := Seed;
    DominatorSpawnPlanet.RandomState := RandomState;
    for I := 1 to Count do SpawnReinforcement(I + 1);
    Hole.Star1.DominatorSeries := Series;
  end;
end;
{ @end $5ECD28 }

{ @routine $5ED070 TKling_RelocateBertorWithinConstellation }
function TKling.RelocateBertorWithinConstellation: Boolean;
var I: Integer; Star: TStar; Stars: TList; Constellation: TConstellation; EscortCount: Integer; Ship: TShip;
begin
  Result := False;
  Constellation := CurrentStar.Constellation;
  if Constellation.Id = 20 then Exit;
  EscortCount := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if not Ship.InNormalSpace then Continue;
    if not (Ship is TKling) then begin
      if not IsPlayerCamouflageEffective(Ship) then Exit;
    end else begin
      if TKling(Ship).DominatorSeries <> DominatorSeries then Exit;
      if (TKling(Ship).KlingType in [ktEquantor..ktShtip]) and (Ship <> Self) then Inc(EscortCount);
    end;
  end;
  if EscortCount < 2 then Exit;
  Stars := TList.Create;
  for I := 0 to Constellation.Stars.Count - 1 do begin
    Star := Constellation.Stars[I];
    if (Star <> CurrentStar) and not IsStarProtectedByScript(Star) and (Star.ShipTypeCounts[stKling] >= 6) and
      ((KellerShip = nil) or not KellerShip.InNormalSpace or (KellerShip.CurrentStar <> Star)) and
      ((TerronShip = nil) or not TerronShip.InNormalSpace or (TerronShip.CurrentStar <> Star)) and
      ((BlazerShip = nil) or not BlazerShip.InNormalSpace or (BlazerShip.CurrentStar <> Star)) and
      (Star.ControlFaction in [sfDominators]) and (Star.DominatorSeries = DominatorSeries) and (Star.Battle = 0) and (Star.Status.CustomFaction = '') then Stars.Add(Star);
  end;
  if Stars.Count > 2 then begin
    I := Stars.IndexOf(TransitOriginStar);
    if I >= 0 then Stars.Delete(I);
  end;
  if Stars.Count > 0 then begin
    OrderJump(Stars[NextRandomIntRange(0, Stars.Count - 1, RandomState)], True);
    Result := True;
  end;
  Stars.Free;
end;
{ @end $5ED070 }

{ @routine $5ED2E4 TKling_SpawnEscortShips }
function TKling.SpawnEscortShips(Kind: TKlingType; DesiredCount: Integer): Integer;
var Series: TDominatorSeries; I, EscortCount, SpawnTimer: Integer; Ship: TShip;
begin
  Result := 0;
  if DesiredCount < 1 then Exit;
  EscortCount := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
    if TShip(CurrentStar.Ships[I]).PartnerShip = Self then Inc(EscortCount);
  if TransitOriginStar <> nil then
    for I := 0 to TransitOriginStar.Ships.Count - 1 do
      if TShip(TransitOriginStar.Ships[I]).PartnerShip = Self then Inc(EscortCount);
  if NextRandomIntRange(0, 2 * DesiredCount, RandomState) < DesiredCount - EscortCount then Exit;
  DominatorSpawnPlanet.CurrentStar := CurrentStar;
  Series := CurrentStar.DominatorSeries;
  CurrentStar.DominatorSeries := DominatorSeries;
  SpawnTimer := CurrentStar.DaysSinceLastNpcShipSpawn;
  DominatorSpawnPlanet.GenerationSeed := Seed;
  DominatorSpawnPlanet.RandomState := Seed;
  while Result + EscortCount < DesiredCount do begin
    Ship := DominatorSpawnPlanet.SpawnDominatorShip(Kind);
    if Ship = nil then Break;
    Inc(Result);
    Ship.PartnerShip := Self;
    Ship.Position.X := Position.X;
    Ship.Position.Y := Position.Y;
    Ship.CurrentPlanet := nil;
    Ship.DockedTo := Self;
    Ship.OrderTakeoff;
    Ship.MovementDirection := PointBearingDegrees(Ship.Position, Ship.OrderDestination);
  end;
  CurrentStar.DominatorSeries := Series;
  CurrentStar.DaysSinceLastNpcShipSpawn := SpawnTimer;
end;
{ @end $5ED2E4 }

// Native diagnostic literal pool precedes the invasion helpers. These stored
// strings contain UTF-8 decoded as Windows-1251, then widened to UTF-16.
// Numeric escapes preserve the native code points; comments show the decoded Russian.
var
  DominatorDebugMessages: array[0..6] of WideString = (
    // Decoded text: Ахтунг! Босс Террон атакован!
    #1056#1106#1057#8230#1057#8218#1057#1107#1056#1029#1056#1110#33#32#1056#8216#1056#1109#1057#1027#1057#1027#32#1056#1118#1056#181#1057#1026#1057#1026#1056#1109#1056#1029#32#1056#176#1057#8218#1056#176#1056#1108#1056#1109#1056#1030#1056#176#1056#1029#33,
    // Decoded text: Меняем боевую позицию
    #1056#1114#1056#181#1056#1029#1057#1039#1056#181#1056#1112#32#1056#177#1056#1109#1056#181#1056#1030#1057#1107#1057#1035#32#1056#1111#1056#1109#1056#183#1056#1105#1057#8224#1056#1105#1057#1035,
    // Decoded text: Срочно подкрепление!
    #1056#1038#1057#1026#1056#1109#1057#8225#1056#1029#1056#1109#32#1056#1111#1056#1109#1056#1169#1056#1108#1057#1026#1056#181#1056#1111#1056#187#1056#181#1056#1029#1056#1105#1056#181#33,
    // Decoded text: Пора потеснить соседей
    #1056#1119#1056#1109#1057#1026#1056#176#32#1056#1111#1056#1109#1057#8218#1056#181#1057#1027#1056#1029#1056#1105#1057#8218#1057#1034#32#1057#1027#1056#1109#1057#1027#1056#181#1056#1169#1056#181#1056#8470,
    // Decoded text: Солдаты на фронт
    #1056#1038#1056#1109#1056#187#1056#1169#1056#176#1057#8218#1057#8249#32#1056#1029#1056#176#32#1057#8222#1057#1026#1056#1109#1056#1029#1057#8218,
    // Decoded text: Надо расширять границы
    #1056#1116#1056#176#1056#1169#1056#1109#32#1057#1026#1056#176#1057#1027#1057#8364#1056#1105#1057#1026#1057#1039#1057#8218#1057#1034#32#1056#1110#1057#1026#1056#176#1056#1029#1056#1105#1057#8224#1057#8249,
    ''
  ); // @addr $87BE10 Unused Terron AI diagnostics; preserves the native UTF-16 mojibake.

{ @routine $5EDEC0 TKling_CoordinateSeriesInvasions }
procedure TKling.CoordinateSeriesInvasions(Series: TDominatorSeries);
var TargetStar: TStar; TargetCount, NonDominatorCount, OtherSeriesCount, Action: Integer; Origin: TStar;
  NearbyRange, OriginCount: Integer; TargetStrength, NonDominatorStrength, OtherSeriesStrength, OriginStrength: Extended;
  SendCount, SendIndex, Sent: Integer; Ship: TShip; ControlPercent: Byte; Chance, MinimumPopulation, I, Attempts, NearbyIndex: Integer;
  Strength: Extended; BaseChance, ControlThreshold: Integer;
  // @nested $5ED6CC NonDominatorDistanceIndex
  function NonDominatorDistanceIndex(Star: TStar): Integer; // @addr $5ED6CC
  var I: Integer;
  begin
    Result := 1000;
    for I := 0 to Galaxy.Stars.Count - 1 do
      if (Star.StarDistances[I].Star.ControlFaction <> sfDominators) and (Star.StarDistances[I].Star.Status.CustomFaction = '') then begin
        Result := I;
        Exit;
      end;
  end;
  // @nested $5ED744 OtherSeriesDistanceIndex
  function OtherSeriesDistanceIndex(Star: TStar): Integer; // @addr $5ED744
  var I: Integer; OtherStar: TStar;
  begin
    Result := 1000;
    for I := 0 to Galaxy.Stars.Count - 1 do begin
      OtherStar := Star.StarDistances[I].Star;
      if (OtherStar.ControlFaction <> sfDominators) or (Series <> OtherStar.DominatorSeries) or (OtherStar.Status.CustomFaction <> '') then begin
        Result := I;
        Exit;
      end;
    end;
  end;
  // @nested $5ED7F4 ChooseAction
  procedure ChooseAction; // @addr $5ED7F4
    // @nested $5ED7C4 TargetIsNotTerron
    function TargetIsNotTerron: Boolean; // @addr $5ED7C4
    begin
      Result := True;
      if (TerronShip <> nil) and (TerronShip.CurrentStar = TargetStar) then Result := False;
    end;
  begin
    // Actions 1/3 reinforce; 2/7 rebalance; 4/6 invade; 5 supports an existing foothold.
    if (Series = dsTerron) and (TerronShip.CurrentStar = TargetStar) and
      ((TargetCount < NonDominatorCount) or (TargetCount < OtherSeriesCount)) then Action := 1
    else if TargetStar.ControlFaction = sfDominators then begin
      if (TargetStar.DominatorSeries = Series) and (TargetStar.Status.CustomFaction = '') then begin
        if OtherSeriesDistanceIndex(Origin) > NearbyRange then
          if (OtherSeriesDistanceIndex(Origin) > OtherSeriesDistanceIndex(TargetStar)) and
            (OtherSeriesCount = 0) and (TargetCount > 0) and (OriginCount > TargetCount * 0.8) then Action := 7;
        if (OtherSeriesCount = 0) and (TargetCount > 0) and (OriginCount > 4 * TargetCount) then Action := 2;
        if (TargetCount < NonDominatorCount) or (TargetStrength < NonDominatorStrength) then Action := 3;
        if ((TargetCount < OtherSeriesCount) or (TargetStrength < OtherSeriesStrength)) and
          (NextRandomIntRange(0, 1000, RandomState) + 1000 < Galaxy.CurrentTurn) then
          if NextRandomIntRange(0, 1000, RandomState) > Galaxy.GetDominatorSeriesControlShare(Series) * 1000 then Action := 3;
      end else begin
        if (TargetCount > 0) and ((TargetCount < OtherSeriesCount) or (TargetStrength < OtherSeriesStrength)) then Action := 5;
        if (Series <> dsKeller) and TargetIsNotTerron and (TargetCount = 0) and
          ((OriginCount > 3 * OtherSeriesCount) or ((NonDominatorDistanceIndex(Origin) > NearbyRange) and
          (OriginCount > OtherSeriesCount * 0.6))) and (NextRandomIntRange(0, 1000, RandomState) + 1000 < Galaxy.CurrentTurn) then
          if NextRandomIntRange(0, 1400, RandomState) > Galaxy.GetDominatorSeriesControlShare(Series) * 1000 then Action := 4;
      end;
    end else begin
      if (TargetCount > 0) and ((TargetCount < NonDominatorCount) or (TargetStrength < NonDominatorStrength)) then Action := 5;
      if (Series <> dsKeller) and (TargetCount = 0) and (OtherSeriesCount = 0) and
        ((NonDominatorCount < OriginCount) or (NonDominatorStrength < OriginStrength)) then Action := 6;
    end;
  end;
  // @nested $5EDBC4 SendShips
  procedure SendShips; // @addr $5EDBC4
  var Text: WideString;
  begin
    if Action = 2 then SendCount := OriginCount div 4
    else if Action = 7 then SendCount := OriginCount div 6
    else SendCount := OriginCount - OriginCount div 4;
    SendIndex := 0;
    Sent := 0;
    // Native <= deliberately permits one more ship than SendCount.
    while (SendIndex < Origin.Ships.Count) and (Sent <= SendCount) and (SendCount > 0) do begin
      Ship := Origin.Ships[SendIndex];
      Inc(SendIndex);
      if (Ship is TKling) and ((Ship as TKling).DominatorSeries = Series) and not Ship.OrderAbsolute and
        not Ship.IsOutsideStarSpace and (Ship <> BlazerShip) and (Ship <> KellerShip) and (Ship <> TerronShip) and
        ((Ship as TKling).KlingType in [ktEquantor..ktShtip]) and ((Ship as TKling).ActiveProgramAppliedTurn <= 0) then begin
        Ship.OrderJump(TargetStar, True);
        Inc(Sent);
      end;
    end;
    if (Action = 6) and (Sent > 0) and (TargetStar.ControlFaction <> sfDominators) and (TargetStar.Status.CustomFaction = '') then
      if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) then begin
        Text := FormatText1(LocalizedText('Artefacts.ArtAnalyzer.AttackDomik'), TextHighlightColorTag, '<Star>', TargetStar.Name);
        if Text <> '' then AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, '');
      end;
  end;
begin
  if GetPlayer = nil then Exit;
  ControlPercent := Galaxy.GetFactionControlPercent(sfDominators);
  BaseChance := Round(Galaxy.ScaleDifficultyExponentially(Galaxy.GetDominatorAggressionLevel, 10, 2));
  ControlThreshold := Round(5 * Galaxy.GetDominatorAggressionLevel / 8) + 80;
  Chance := Round(RemapClamped(ControlPercent, 1, ControlThreshold, BaseChance, 0));
  Chance := Round(Chance * RemapClamped(Galaxy.WarDeltaWin[1], 0, 10, 1, 0.3));
  if Galaxy.CurrentTurn >= 666 then
    if Galaxy.DominatorModLevel = 1 then Chance := 400
    else if Galaxy.DominatorModLevel = 2 then Chance := 600
    else if Galaxy.DominatorModLevel = 3 then Chance := 800;
  if Chance = 0 then Exit;
  case Series of
    dsKeller: NearbyRange := 9;
    dsBlazer: NearbyRange := 8;
    dsTerron: NearbyRange := 7;
  end;
  case Series of
    dsKeller: MinimumPopulation := 11;
    dsBlazer: MinimumPopulation := 9;
    dsTerron: MinimumPopulation := 7;
  end;
  I := 0;
  while I <= Galaxy.Stars.Count - 1 do begin
    Origin := Galaxy.Stars[I];
    Inc(I);
    if (Origin.ControlFaction = sfDominators) and (Origin.Battle = 0) and (Origin.DominatorSeries = Series) and (Origin.Status.CustomFaction = '') then
      if (NextRandomIntRange(1, 1000, Galaxy.RandomState) <= Chance) and
        (Origin.CountForcesByOwnerGroups(Strength, True, False, True, True) <= 0) and
        (Origin.CountDominatorForces(Series, False, True, Strength) <= 0) then begin
        OriginCount := Origin.CountDominatorForces(Series, True, False, OriginStrength);
        if OriginCount >= MinimumPopulation then begin
          Action := 0;
          Attempts := NearbyRange;
          NearbyIndex := NextRandomIntRange(1, NearbyRange, Galaxy.RandomState);
          while (Attempts > 0) and (Action = 0) do begin
            TargetStar := TObject(Origin.StarDistances[NearbyIndex].Star) as TStar;
            NearbyIndex := IncrementWrapped(NearbyIndex, 1, NearbyRange);
            Dec(Attempts);
            if (TargetStar.Constellation.Id <> 20) and (TargetStar <> Origin) and not IsStarProtectedByScript(TargetStar) then
              if (Galaxy.CurrentTurn > GalaxyWarmupTurns) or ((GetPlayer.CurrentStar <> TargetStar) and
                (PointDistanceSquared(TargetStar.Position, GetPlayer.CurrentStar.Position) >= Sqr((1 - Galaxy.CurrentTurn / GalaxyWarmupTurns) * 70 + 35))) then
                if (BlazerShip = nil) or (Galaxy.BlazerLandingPlanetId = 0) or (BlazerShip.CurrentStar <> TargetStar) then begin
                  TargetCount := TargetStar.CountDominatorForces(Series, False, False, TargetStrength);
                  OtherSeriesCount := TargetStar.CountDominatorForces(Series, False, True, OtherSeriesStrength);
                  NonDominatorCount := TargetStar.CountForcesByOwnerGroups(NonDominatorStrength, True, False, True, True);
                  ChooseAction;
                  if ((Action <> 6) and (Action <> 5) and (Action <> 3)) or (NextRandomIntRange(1, 60, RandomState) > TargetStar.PlayerPresenceLevel) then
                    if Action <> 0 then SendShips;
                end;
          end;
        end;
      end;
  end;
end;
{ @end $5EDEC0 }

{ @routine $5EE370 TKling_MoveToRandomPatrolPoint }
procedure TKling.MoveToRandomPatrolPoint;
var Planet: TPlanet; Polar: TPolarPoint;
begin
  Planet := CurrentStar.Planets[0];
  Polar := Planet.Orbit;
  Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
  if (NextRandomIntRange(0, 50, RandomState) = 0) and (4 * Galaxy.GetAIJunkToleranceLevel < CurrentStar.Items.Count) then
    Polar.Radius := CurrentStar.ComputeMapDiameter / 2;
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $5EE370 }

{ @routine $5EE430 TKling_MoveNearKellerMissionHole }
procedure TKling.MoveNearKellerMissionHole;
var Destination: TPointF; Hole: THole; Angle, Radius: Single;
begin
  Hole := Galaxy.FindHoleInStarByKind(CurrentStar, 4);
  if Hole <> nil then begin
    if Hole.Star1 = CurrentStar then Destination := Hole.Position1 else Destination := Hole.Position2;
    Angle := HeadingDegreesToRadians(NextRandomIntRange(0, 359, RandomState));
    Radius := NextRandomIntRange(100, 150, RandomState);
    Destination.X := Destination.X + Sin(Angle) * Radius;
    Destination.Y := Destination.Y - Cos(Angle) * Radius;
    OrderMove(Destination, False);
  end;
end;
{ @end $5EE430 }

{ @routine $5EE51C TKling_RepairBrokenEquipmentAtLocation }
procedure TKling.RepairBrokenEquipmentAtLocation;
var I: Integer; Equipment: TEquipment;
begin
  if CurrentPlanet <> nil then GetHull.HullPoints := GetHull.Weight;
  for I := 1 to Inventory.Count - 1 do begin
    Equipment := Inventory[I];
    if (Equipment.BrokenFlag <> 0) or (Equipment.ConditionPercent < 10) then Equipment.Repair;
  end;
end;
{ @end $5EE51C }

{ @routine $5EE5A8 TKling_GetHomeStar }
function TKling.GetHomeStar: TStar;
begin
  Result := nil;
end;
{ @end $5EE5A8 }

{ @routine $5EE5C0 TKling_GetName }
function TKling.GetName: WideString;
begin
  Result := Name;
end;
{ @end $5EE5C0 }

{ @routine $5EE5E0 TKling_GetFullName }
function TKling.GetFullName(const Separator: WideString): WideString;
var
  Path, Text: WideString;
begin
  if TypeNameOverrideKey <> '' then
  begin
    Path := 'ShipType.Dominator.' + DominatorSeriesNames[DominatorSeries] + '.' + TypeNameOverrideKey;
    if LanguageDataConfig.CountParamsByPath(Path) > 0 then Text := LocalizedText(Path)
    else Text := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Text <> '' then Result := Text + Separator + Name else Result := Name;
  end
  else if KlingType = ktBoss then Result := DominatorShipDefinitions[KlingType].DisplayNames[DominatorSeries]
  else Result := DominatorShipDefinitions[KlingType].DisplayNames[DominatorSeries] + Separator + Name;
end;
{ @end $5EE5E0 }

{ @routine $5EE7C8 TKling_GetGreetingShipCategory }
function TKling.GetGreetingShipCategory: TGreetingShipCategory;
begin
  Result := gscKling;
end;
{ @end $5EE7C8 }

{ @routine $5EE7DC TKling_GetDominantCareer }
function TKling.GetDominantCareer: TRangerCareer;
begin
  Result := rcWarrior;
end;
{ @end $5EE7DC }

{ @routine $5EE7F0 TKling_GetStrengthScaledPirateStatus }
function TKling.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 100;
end;
{ @end $5EE7F0 }

{ @routine $5EE804 TKling_GetDesiredCargoFreeSpace }
function TKling.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $5EE804 }

{ @routine $5EE81C TKling_IsProgramActive }
function TKling.IsProgramActive(ProgramId: TProgramIndex): Boolean;
begin
  Result := (ActiveProgramAppliedTurn > 0) and (ProgramId = ActiveProgramId);
end;
{ @end $5EE81C }

{ @routine $5EE854 TKling_RefuelAtLocation }
procedure TKling.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $5EE854 }

{ @routine $5EE884 TKling_SetInventoryDominatorOwner }
procedure TKling.SetInventoryDominatorOwner;
var I: Integer; Equipment: TEquipment;
begin
  for I := 0 to Inventory.Count - 1 do begin
    Equipment := Inventory[I];
    Equipment.OwnerId := oiDominator;
    Equipment.DominatorSeries := DominatorSeries;
  end;
end;
{ @end $5EE884 }

{ @routine $5EE8E0 TKling_ImproveStandardEquipment }
procedure TKling.ImproveStandardEquipment;
var I: Integer; Equipment: TEquipment;
begin
  for I := 0 to Inventory.Count - 1 do begin
    Equipment := Inventory[I];
    if Equipment.HasStandardStats and (NextRandomUnitFloat(RandomState) < 0.25) then
      case Galaxy.GetDifficultyTierIndex of
        0: if NextRandomUnitFloat(RandomState) < 0.8 then Equipment.Improve(ikMinor) else Equipment.Improve(ikAny);
        1: if NextRandomUnitFloat(RandomState) < 0.6 then Equipment.Improve(ikMinor) else Equipment.Improve(ikAny);
        2: if NextRandomUnitFloat(RandomState) < 0.6 then Equipment.Improve(ikMedium) else Equipment.Improve(ikAny);
        3: if NextRandomUnitFloat(RandomState) < 0.6 then Equipment.Improve(ikMajor) else Equipment.Improve(ikAny);
      else Equipment.Improve(ikMajor);
      end;
  end;
end;
{ @end $5EE8E0 }

{ @routine $5EEA78 TKling_RelationToNonRanger }
function TKling.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship is TKling then
    if (Ship as TKling).DominatorSeries = DominatorSeries then Result := 100 else Result := 40
  else Result := 0;
  if CurrentStanding = ssNeutral then Result := 100;
end;
{ @end $5EEA78 }

{ @routine $5EEADC TKling_RelationToRanger }
function TKling.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := 0;
  if CurrentStanding = ssNeutral then Result := 100;
end;
{ @end $5EEADC }

{ @routine $5EEB04 TKling_ChangeRelationToRanger }
procedure TKling.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
begin end;
{ @end $5EEB04 }

{ @routine $5EEB18 TKling_ReactToAttack }
procedure TKling.ReactToAttack(Attacker: TShip);
begin
  if Attacker.OwnerId <> oiDominator then EnemyShip := Attacker
  else if (Attacker as TKling).DominatorSeries <> DominatorSeries then EnemyShip := Attacker;
end;
{ @end $5EEB18 }

{ @routine $5EEB6C TKling_RecomputeFearState }
function TKling.RecomputeFearState: Boolean;
begin Result := False; end;
{ @end $5EEB6C }

{ @routine $5EEB80 TKling_AcceptsRansomDemandFrom }
function TKling.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin Result := False; end;
{ @end $5EEB80 }

{ @routine $5EEB98 TKling_TrustsAttackRequester }
function TKling.TrustsAttackRequester(Ship: TShip): Boolean;
begin Result := False; end;
{ @end $5EEB98 }

{ @routine $5EEBB0 TKling_AcceptsAppealFrom }
function TKling.AcceptsAppealFrom(Ship: TShip): Boolean;
begin Result := Ship.OwnerId = OwnerId; end;
{ @end $5EEBB0 }

{ @routine $5EEBD4 TKling_AssignWeaponTargetsInStar }
procedure TKling.AssignWeaponTargetsInStar;
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Item: TItem; Asteroid: TAsteroid; Distance: Single; Missile: TMissile;
begin
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; Weapon.Target := nil; end;
  Assigned := 0;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
    for J := 1 to WeaponCount do begin
      Weapon := Weapons[J];
      if (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
          Weapon.Target := EnemyShip;
          Inc(Assigned);
          if (Assigned = WeaponCount) and not (KlingType in [ktBoss..ktUrgant, ktBertor]) then Exit;
        end;
    end;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if Ship.InNormalSpace and (Ship <> Self) and ((RelationToShip(Ship) <= 50) or IsProgramActive(prgInsanity)) and not IsPlayerCamouflageEffective(Ship) then
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if ((Weapon.Target = nil) or (Weapon.GetWeaponInfo.ShotType = wstAreaDamage)) and IsEquipmentUsable(Weapon) then
          if PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
            if Weapon.Target = nil then begin
              Weapon.Target := Ship;
              Inc(Assigned);
              if (Assigned = WeaponCount) and not (KlingType in [ktBoss..ktUrgant, ktBertor]) then Exit;
            end else if TShip(Weapon.Target).GetHull.HullPoints < Ship.GetHull.HullPoints then Weapon.Target := Ship;
          end;
      end;
  end;
  if Assigned >= WeaponCount then Exit;
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
  for I := 0 to CurrentStar.Items.Count - 1 do begin
    Item := CurrentStar.Items[I];
    if ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) and CanSafelyDetonateItem(Item) then
      for J := 1 to WeaponCount do begin
        Weapon := Weapons[J];
        if not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
          if PointDistanceSquared(Position, Item.Position) <= Sqr(GetWeaponRange(Weapon)) then begin
            Weapon.Target := Item;
            Inc(Assigned);
            if Assigned = WeaponCount then Exit;
            Break;
          end;
      end;
  end;
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
end;
{ @end $5EEBD4 }

{ @routine $5EF1F4 TKling_DetectAttackingPlayer }
procedure TKling.DetectAttackingPlayer(Attacker: TShip);
begin
  if (GetPlayer = Attacker) and (Attacker.CurrentStar = CurrentStar) and
    not TPlayer(Attacker).ChameleonDetected[DominatorSeries] and
    (GetPlayer.ChameleonLogic[DominatorSeries] < 2) and not HasIndependentScriptFaction then
  begin
    TPlayer(Attacker).ChameleonDetected[DominatorSeries] := True;
    if TPlayer(Attacker).ChameleonActive and (TPlayer(Attacker).ChameleonSeries = DominatorSeries) then
      AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn,
        LocalizedText('ShipInfo.AddInfo.Chameleon.Detect'), '');
  end;
end;
{ @end $5EF1F4 }

{ @routine $5EF330 TKling_IsPlayerCamouflageEffective }
function TKling.IsPlayerCamouflageEffective(Ship: TShip): Boolean;
begin
  Result := False;
  if (GetPlayer <> nil) and (GetPlayer = Ship) and not HasIndependentScriptFaction and not Ship.IsOutsideStarSpace and
    (not TPlayer(Ship).ChameleonDetected[DominatorSeries] or (GetPlayer.ChameleonLogic[DominatorSeries] >= 2)) then begin
    if (not TPlayer(Ship).ChameleonActive or (TPlayer(Ship).ChameleonSeries <> DominatorSeries)) and (GetPlayer.ChameleonLogic[DominatorSeries] = 0) then
      TPlayer(Ship).ChameleonDetected[DominatorSeries] := True
    else Result := True;
  end;
end;
{ @end $5EF330 }

{ @routine $5EF408 TKling_SelectEnemyShipInStar }
procedure TKling.SelectEnemyShipInStar;
var I: Integer; Ship: TShip; Distance, BestDistance: Double;
begin
  if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or
    (Speed * Speed < PointDistanceSquared(Position, EnemyShip.Position)) or
    (not EnemyShip.InNormalSpace and (not EnemyShip.IsDocked or (EnemyShip.ConsecutiveDockedDays >= 2))) then
    if UsableWeaponCount <> 0 then begin
      EnemyShip := nil;
      BestDistance := 100000;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if Ship.InNormalSpace then begin
          if HasIndependentScriptFaction then begin
            if Ship.HasIndependentScriptFaction and (TScriptShip(ScriptShip).StateText = TScriptShip(Ship.ScriptShip).StateText) then Continue;
          end else if ((Ship.OwnerId = oiDominator) and ((Ship as TKling).DominatorSeries = DominatorSeries) and (Ship.CurrentStanding <> ssCustom)) or IsPlayerCamouflageEffective(Ship) then Continue;
          if (EnemyShip = nil) or not (Ship.TypeId in [rstRangerCenter..rstCustomStation]) or (EnemyShip.TypeId in [rstRangerCenter..rstCustomStation]) then begin
            Distance := PointDistance(Position, Ship.Position);
            if NextRandomFloatRange(0.3, 3, RandomState) * BestDistance > Distance then begin
              EnemyShip := Ship;
              BestDistance := Distance;
            end;
          end;
        end;
      end;
    end;
end;
{ @end $5EF408 }

{ @routine $5EF630 TKling_EngageEnemyShip }
procedure TKling.EngageEnemyShip;
begin
  if Order = soFollowShip then OrderNone(False);
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then
    if EnemyShip.InNormalSpace then
      if ShouldKamikaze then OrderFollowShip(EnemyShip, fmKamikaze, False) else OrderFollowShip(EnemyShip, fmMinWeaponRange, False)
    else if EnemyShip.CurrentPlanet <> nil then OrderMove(EnemyShip.CurrentPlanet.GetPosition, False);
end;
{ @end $5EF630 }

{ @routine $5EF6F4 TKling_UpdateAfterburnerState }
procedure TKling.UpdateAfterburnerState;
begin
  AfterburnerActive := ShouldKamikaze and (GetSlotCount(sskAfterburner) > 0) and (GetEngine <> nil) and (GetEngine.ConditionPercent > 10);
  RefreshDerivedStats(True);
end;
{ @end $5EF6F4 }

{ @routine $5EF758 TKling_ProcessCombatDialogue }
procedure TKling.ProcessCombatDialogue;
begin end;
{ @end $5EF758 }

{ @routine $5EF764 TKling_ReactToExtortionDemand }
procedure TKling.ReactToExtortionDemand(Ranger: Pointer);
begin end;
{ @end $5EF764 }

{ @routine $5EF774 TKling_BuildMoneyExtortionResponse }
function TKling.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
begin
  Result := False;
end;
{ @end $5EF774 }

{ @routine $5EF790 TKling_BuildCargoExtortionResponse }
function TKling.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
end;
{ @end $5EF790 }

{ @routine $5EF7AC TKling_BuildTrucePaymentResponse }
function TKling.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
begin
  Result := False;
end;
{ @end $5EF7AC }

{ @routine $5EF7C8 TKling_BuildAttackRequestResponse }
function TKling.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
begin
  Result := False;
end;
{ @end $5EF7C8 }

{ @routine $5EF7E4 TKling_AcceptPartnershipOffer }
function TKling.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $5EF7E4 }

{ @routine $5EF834 TKling_BuildPartnershipOfferResponse }
function TKling.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $5EF834 }

{ @routine $5EF884 TKling_RefreshCombatSkills }
procedure TKling.RefreshCombatSkills;
var Percent: Byte; Lower, Upper, Maximum, Minimum, Threshold, StartPercent, MidPercent: Integer;
begin
  if KlingType = ktBoss then begin
    BaseSkills[psAccuracy] := 6;
    BaseSkills[psManeuverability] := 6;
    BaseSkills[psLeadership] := 6;
  end else begin
    FreeExperience := Galaxy.CurrentTurn;
    Minimum := 0;
    Maximum := Round(Galaxy.InterpolateDifficulty(-1, 2, 3, 4, 6));
    Maximum := Min(Maximum, 6);
    Threshold := Round(Galaxy.GetEffectiveDifficultyLevel * 1.25) + 65;
    if Galaxy.CurrentTurn >= 666 then
      if Galaxy.DominatorModLevel = 1 then begin Maximum := 6; Minimum := 1; Threshold := 100; end
      else if Galaxy.DominatorModLevel = 2 then begin Maximum := 6; Minimum := 3; Threshold := 100; end
      else if Galaxy.DominatorModLevel = 3 then begin Maximum := 6; Minimum := 5; Threshold := 100; end;
    StartPercent := 1;
    MidPercent := Threshold div 2;
    Percent := Galaxy.GetFactionControlPercent(sfDominators);
    Lower := Round(RemapClamped(Percent, StartPercent, MidPercent, Maximum, Minimum));
    Upper := Round(RemapClamped(Percent, MidPercent, Threshold, Maximum, Minimum));
    Lower := Min(Lower, Upper);
    BaseSkills[psAccuracy] := NextRandomIntRange(Lower, Upper, RandomState);
    BaseSkills[psManeuverability] := NextRandomIntRange(Lower, Upper, RandomState);
    BaseSkills[psTechnical] := 6;
  end;
  TechKnowledge := 8;
end;
{ @end $5EF884 }

{ @routine $5EFAE8 TKling_CalculateSpeed }
function TKling.CalculateSpeed: Integer;
var
  Speed: Integer;
begin
  Speed := inherited CalculateSpeed;
  if KlingType = ktBoss then Speed := Max(350, Speed);
  Result := Speed;
end;
{ @end $5EFAE8 }

{ @routine $5EFB34 TKling_HasNearbyBertorAura }
function TKling.HasNearbyBertorAura: Boolean;
var
  I: Integer;
  Ship: TShip;
begin
  Result := False;
  if KlingType = ktBoss then Exit;
  if KlingType = ktBertor then Exit;
  if HasIndependentScriptFaction then Exit;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if (Ship is TKling) and ((Ship as TKling).KlingType = ktBertor) and
      ((Ship as TKling).DominatorSeries = DominatorSeries) and (Ship <> Self) and
      Ship.InNormalSpace and not Ship.IsHullDestroyed and
      (PointDistance(Position, Ship.Position) <= 500) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;
{ @end $5EFB34 }

{ @routine $5EFC48 TKling_RefreshCurrentStanding }
procedure TKling.RefreshCurrentStanding;
var StandingMode: TScriptStandingOverrideMode;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then
    if (Self = BlazerShip) and (Galaxy.BlazerLandingPlanetId <> 0) then CurrentStanding := ssNeutral
    else CurrentStanding := ssDominator;
end;
{ @end $5EFC48 }

end.
