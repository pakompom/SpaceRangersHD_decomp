unit aConst;

interface

uses Windows, aGalaxyStruct;

type
  TSizeLevel = 0..5; // @size $01 Zero, Mini, Small, Average, Big and Huge.

  TOwnerWeaponAvailabilityTable = array[TOwnerId] of TWeaponAvailability;
  POwnerWeaponAvailabilityTable = ^TOwnerWeaponAvailabilityTable;

  // Ordinals follow the native bon* configuration/script table; its keys stay unchanged.
  TEquipmentBonusKind = (
    bonus_armor = 0,
    bonus_fuel_capacity = 1,
    bonus_speed = 2,
    bonus_jump_range = 3,
    bonus_radar_range = 4,
    bonus_scanner_power = 5,
    bonus_repair_points = 6,
    bonus_hook_power = 7,
    bonus_defense = 8,
    bonus_energy_damage = 9,
    bonus_splinter_damage = 10,
    bonus_missile_damage = 11,
    bonus_weapon_range = 12,
    bonus_radar_slots = 13,
    bonus_scanner_slots = 14,
    bonus_repair_robot_slots = 15,
    bonus_cargo_hook_slots = 16,
    bonus_defense_slots = 17,
    bonus_weapon_slots = 18,
    bonus_artefact_slots = 19,
    bonus_afterburner_slots = 20,
    bonus_hook_range = 21,
    bonus_accuracy = 22,
    bonus_maneuverability = 23,
    bonus_technical = 24,
    bonus_trading = 25,
    bonus_charisma = 26,
    bonus_leadership = 27,
    bonus_mass = 28,
    bonus_acryn_effect = 29,
    bonus_acryn_penalty = 30,
    bonus_ammo_capacity = 31,
    bonus_shot_count = 32,
    bonus_missile_speed = 33,
    bonus_shot_delay_reduction = 34,
    bonus_hook_max_speed = 35,
    bonus_hook_min_speed = 36,
    bonus_stimulant_capacity = 37,
    bonus_satellite_limit = 38,
    bonus_attack_count = 39,
    bonus_asteroid_resistance = 40,
    bonus_ai_item_value = 41,
    bonus_none = 42
  ); // @size 0x1

  TEquipmentBonuses = array[TEquipmentBonusKind] of Integer;

  TEquipmentBonusNameTable = array[TEquipmentBonusKind] of WideString;

  PEquipmentBonusNameTable = ^TEquipmentBonusNameTable;

  TShipSlotKind = (
    slot_fuel_tanks = 0,
    slot_engine = 1,
    slot_radar = 2,
    slot_scanner = 3,
    slot_repair_robot = 4,
    slot_cargo_hook = 5,
    slot_defense_generator = 6,
    slot_weapon = 7,
    slot_artefact = 8,
    slot_afterburner = 9,
    slot_unsupported = 10
  ); // @size 0x1

  TEquipmentSizeFactorTable = array[1..5] of Single;

  PEquipmentSizeFactorTable = ^TEquipmentSizeFactorTable;

  TWeaponRangeLevelFactors = array[1..8] of Single;
  TScriptActionTypeNames = array[TScriptEventKind] of WideString;
  TGoodsLegalityTable = array[TGoodsIndex, owner_maloc..owner_gaal, TPlanetGovernment] of Boolean;

  TProgramNameTable = array[TProgramIndex] of WideString;
  TProgramDurationTable = array[TProgramIndex] of Integer;
  TWeaponDamageClass = (damage_class_energy = 0, damage_class_splinter = 1, damage_class_missile = 2); // @size $01

  THullLevelStats = record // @size $10
    Armor: Byte; // @offset $00
    Fragility: array[TWeaponDamageClass] of Single; // @offset $04 Energy, splinter, missile; loaded by $793CC0.
  end;
  THullLevelStatsTable = array[1..8] of THullLevelStats;

  TTransportTypeNameTable = array[TTransportType] of WideString;
  THullShipTypeMask = set of THullType; // @size $02 hull_* category bits, distinct from TShip.TypeId.

procedure IncrementWordSaturating(var Value: Word); // @addr $798758
function OwnerToSys(OwnerId: TOwnerId): WideString; // @addr $78F974
function IsKnownOwnerName(const Name: WideString): Boolean; // @addr $78FBB4
function MatchesOwnerName(OwnerId: TOwnerId; const Name: WideString): Boolean; // @addr $78FD4C Unrecognized names act as a wildcard.
function MatchesCareerName(Career: TRangerCareer; const Names: WideString): Boolean; // @addr $78FDC8 Case-sensitive substring, Any, or empty string.

procedure LoadArtefactConfiguration; // @addr $791100
procedure LoadDamageSkillQuestMarketConfiguration; // @addr $793540
procedure LoadEquipmentConfiguration; // @addr $793CC0
procedure LoadWeaponConfiguration; // @addr $794754
procedure LoadMicroModuleConfiguration; // @addr $7954B8
procedure InitializeCaptainHealthDefinitions; // @addr $7969C0
procedure LoadHullSeriesConfiguration; // @addr $797B2C

procedure InitializeGameplayConfig; // @addr 0x0078E854

function ItemTypeToSlotKind(ItemType: TItemType): TShipSlotKind; // @addr 0x0079057C
function ClassifyWeaponDamageFlags(Flags: TDamageFlagSet): TWeaponDamageClass; // @addr $798884 Missile bit takes precedence over splinter; otherwise energy.
function ShipToHullType(Ship: TObject): THullType; // @addr $790454 Class/subtype mapping used by hull generation and legacy saves; only TObject RTTI operations precede explicit subclass casts.
function RaceToOwner(RaceId: TOwnerId): TOwnerId; // @addr $78F2D8 @note "Identity conversion for Coalition races 0..4; raises for all other values."
function OwnerFromInternalName(const Name: WideString): TOwnerId; // @addr $78FAAC

function OwnerToRace(OwnerId: TOwnerId): TOwnerId; // @addr 0x0078F26C @note "Identity conversion for Coalition owners 0..4; raises for all other values."
function RaceToSys(RaceId: TOwnerId): WideString; // @addr 0x0078F3C8 @note "Raises outside Coalition races 0..4."
function NumberToRace(Value: Integer): TOwnerId; // @addr 0x0078FCE4 @note "Accepts 0..4; raises otherwise."
function SysToReward(const Name: WideString): TAwardKind; // @addr 0x0078FE18 @note "Case-sensitive lookup; raises for an unknown name."
function SysToShipType(const Name: WideString): TShipType; // @addr 0x0078FFA4 @note "Case-sensitive lookup among 14 ship types; raises for an unknown name."
function OwnerToFilmColor(OwnerId: TOwnerId): Cardinal; // @addr 0x0078F4C4 @note "Maps owner IDs 0..5 and 7 to fixed RGB colors through CurrentPixelFormat; other values use magenta."
function CustomFactionToFilmColor(Faction: WideString): Cardinal; // @addr $78F5A0
function GetCustomFactionPlanetIconNumber(Faction: WideString): Integer; // @addr $78F818 @note "Race.PlanetIconNum lookup; returns -1 for an absent entry. Film owner codes offset a nonnegative result by eight."
function SizeTagToLevel(const Tag: WideString): Byte; // @addr $790380 @note "Zero, Mini, Small, Average, Big, Huge map to 0..5; unknown tags map to zero."
function GenerateValueForSizeLevel(Level: TSizeLevel; Minimum, Maximum: Integer; VariationPercent: Byte; Seed: Cardinal): Integer; // @addr $790204 @note "Seeded variation around a size bucket; unknown nonzero levels use the midpoint."
function GetAverageItemSize(ItemType: TItemType): Integer; // @addr 0x0079000C
function PickRandomItemType(Mask: TItemTypeSelection): Byte; // @addr $798764 @ida "unsigned __int8 __usercall $name@<al>(TItemTypeSelection *Mask@<eax>);"
function PickRandomItemTypeFromSeed(Mask: TItemTypeSelection; var Seed: Cardinal): Byte; // @addr $7987BC @ida "unsigned __int8 __usercall $name@<al>(TItemTypeSelection *Mask@<eax>, unsigned int *Seed@<edx>);" @note "Selects a set bit among 0..75 while advancing Seed; an empty mask returns 76."
function CountItemTypesInMask(Mask: TItemTypeSelection): Integer; // @addr 0x00798818 @ida "int __usercall $name@<eax>(TItemTypeSelection *Mask@<eax>);" @note "Copies the ten-byte mask, then counts bits 0..75; ignores storage bits 76..79."
function GetItemTypeFromMask(Mask: TItemTypeSelection; Index: Integer): TItemType; // @addr 0x00798848 @ida "unsigned __int8 __usercall $name@<al>(TItemTypeSelection *Mask@<eax>, int Index@<edx>);" @note "One-based selected-bit index among types 0..75; returns zero if no index matches."
function PickRandomEquipmentOwner(RandomValue: Dword): TOwnerId; // @addr 0x0078FDB4 @note "Only Coalition manufacturers are eligible."

function LookupNamedColorTag(Name: WideString): WideString; // @addr $78F6E0

// Repeated Path values are joined with CRLF; no separator precedes an empty accumulator.
// Missing paths return empty and may create intermediate blocks.
// Both lookups expand <br>, <ll> and <Player>; the player's name is highlighted.
// LocalizedText leaves <clr>/<clrEnd> intact; LocalizedColorText expands them.
function LocalizedText(const Path: WideString): WideString; // @addr 0x007905DC
function LocalizedColorText(const Path: WideString): WideString; // @addr 0x00790804 @note "Also expands <clr> and <clrEnd> to yellow opening and closing color tags."
procedure ExpandLocalizedTextMarkup(var Text: WideString); // @addr 0x00790A94 @note "Expands <br>, <ll>, <Player>, <clr> and <clrEnd>; leaves <Player> intact when no player exists."
procedure ExpandLocalizedTextMarkupAndPrefixLines(var Text: WideString); // @addr 0x00790C74 @note "Expands markup, trims outer whitespace, then applies LocalizedTextLinePrefix to the first line and after each CRLF."

// Collects at most ten nonempty variants: Path, then contiguous numeric suffixes
// starting at 1 (0 when the base lookup is empty). A missing suffix prevents reaching later ones.
function PickLocalizedTextVariant(const Path: WideString; SeedOffset: Integer): WideString; // @addr 0x00790EA4 @note "Selection uses (CurrentTurn + SeedOffset) div 10, except in chaotic mode. No variants produces an unavailable-text diagnostic."

function RelationValueToLevel(Value: TPercent): TRelationLevel; // @addr $790540 Buckets 0..100; out-of-range values map to normal.

function GetFactionEmblemPath(Faction: WideString): WideString; // @addr $78F8E4

function FindMicroModuleTemplateByCustomTag(CustomTag: WideString): Integer; // @addr $791088 First matching template; -1 when absent.

var
  IntegrityDataBegin: Cardinal = 0; // @addr $8101BC Four-byte zero boundary marker for the dormant native data checksum; original name unresolved.
var
  CurrentSaveVersion: Integer = 167; // @addr 0x008101C0 @note "167 in this binary."
  MinimumLoadableSaveVersion: Integer = 44; // @addr 0x008101C4 @note "44 in this binary; enforced by the save-manager load action."
  LocalizedTextLinePrefix: WideString = '    '; // @addr 0x008101C8
type
  TEconomyInfo = packed record // @size 0x10
    InternalName: WideString; // @offset 0x00  SaveToBlock/LoadFromBlock economy token.
    DisplayName: WideString; // @offset 0x04
    ShortDisplayName: WideString; // @offset $08 Economy.ShortName localization.
    InventionProgressScale: Single; // @offset 0x0C
  end;

  TPlanetEconomyInfoTable = array[TPlanetEconomy] of TEconomyInfo;

  PPlanetEconomyInfoTable = ^TPlanetEconomyInfoTable;

  TRelationTypeInfo = record // @size $0C
    InternalName: WideString; // @offset $00
    DisplayName: WideString; // @offset $04 Used by live and recorded object-information panels.
    MinimumValue: Integer; // @offset $08 Native thresholds 0, 10, 30, 60, 80.
  end;

  TRelationInfoTable = array[TRelationLevel] of TRelationTypeInfo;

var
  GalaxyStarCount: Integer = 73; // @addr $8101CC Constellations.GalaxyCountStars config; SF_GalaxyPtr('StarCnt') exposes its address.
  GalaxySizeY: Integer = 100; // @addr $8101D0 Constellations.GalaxySizeY config; also scales hyperspace route length.
  GalaxySizeX: Integer = 145; // @addr $8101D4 Constellations.GalaxySizeX configuration.
const
  MaximumNewGameDifficulty: Byte = 9; // @addr $8101D8
var
  GalaxyDifficultyTuning: TGalaxyDifficultyTuningTable = (
    (GoodsEventDurationFactor: 0.7;
      QuestTimeAndExperienceFactor: 0.85;
      EquipmentWearFactor: 0.75;
      InventionProgressScale: 1.1;
      ArcadeRewardScale: 1.3;
      QuestMoneyFactor: 1.2;
      StartingPlayerMoney: 4000;
      InitialPirateControlPercent: 8;
      MarketPriceBandSqueeze: -0.2;
      RandomHoleSpawnRollMaximum: 80;
      MaximumDominatorResearchRate: 0.05;
      MaximumResearchMaterialConsumption: 2;
      MaximumQuestProgramRewardCount: 4;
      ArcadeDamageTakenScale: 0.9;
      CoalitionToPirateBalanceRatio: 10.0),
    (GoodsEventDurationFactor: 1.0;
      QuestTimeAndExperienceFactor: 1.0;
      EquipmentWearFactor: 1.0;
      InventionProgressScale: 1.0;
      ArcadeRewardScale: 1.0;
      QuestMoneyFactor: 1.0;
      StartingPlayerMoney: 1300;
      InitialPirateControlPercent: 12;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 100;
      MaximumDominatorResearchRate: 0.04;
      MaximumResearchMaterialConsumption: 4;
      MaximumQuestProgramRewardCount: 3;
      ArcadeDamageTakenScale: 1.0;
      CoalitionToPirateBalanceRatio: 5.0),
    (GoodsEventDurationFactor: 1.2;
      QuestTimeAndExperienceFactor: 1.15;
      EquipmentWearFactor: 1.3;
      InventionProgressScale: 0.9;
      ArcadeRewardScale: 0.6;
      QuestMoneyFactor: 0.7;
      StartingPlayerMoney: 800;
      InitialPirateControlPercent: 16;
      MarketPriceBandSqueeze: 0.1;
      RandomHoleSpawnRollMaximum: 130;
      MaximumDominatorResearchRate: 0.03;
      MaximumResearchMaterialConsumption: 5;
      MaximumQuestProgramRewardCount: 2;
      ArcadeDamageTakenScale: 1.7;
      CoalitionToPirateBalanceRatio: 2.5),
    (GoodsEventDurationFactor: 1.5;
      QuestTimeAndExperienceFactor: 1.3;
      EquipmentWearFactor: 1.6;
      InventionProgressScale: 0.8;
      ArcadeRewardScale: 0.3;
      QuestMoneyFactor: 0.5;
      StartingPlayerMoney: 400;
      InitialPirateControlPercent: 20;
      MarketPriceBandSqueeze: 0.15;
      RandomHoleSpawnRollMaximum: 170;
      MaximumDominatorResearchRate: 0.02;
      MaximumResearchMaterialConsumption: 6;
      MaximumQuestProgramRewardCount: 2;
      ArcadeDamageTakenScale: 2.3;
      CoalitionToPirateBalanceRatio: 1.8),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      StartingPlayerMoney: 0;
      InitialPirateControlPercent: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      CoalitionToPirateBalanceRatio: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      StartingPlayerMoney: 0;
      InitialPirateControlPercent: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      CoalitionToPirateBalanceRatio: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      StartingPlayerMoney: 0;
      InitialPirateControlPercent: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      CoalitionToPirateBalanceRatio: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      StartingPlayerMoney: 0;
      InitialPirateControlPercent: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      CoalitionToPirateBalanceRatio: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      StartingPlayerMoney: 0;
      InitialPirateControlPercent: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      CoalitionToPirateBalanceRatio: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      StartingPlayerMoney: 0;
      InitialPirateControlPercent: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      CoalitionToPirateBalanceRatio: 0.0)); // @addr $8101DC
  RelationInfo: array[TRelationLevel] of TRelationTypeInfo = (
    (InternalName: 'War'; DisplayName: ''; MinimumValue: 0),
    (InternalName: 'Bad'; DisplayName: ''; MinimumValue: 10),
    (InternalName: 'Normal'; DisplayName: ''; MinimumValue: 30),
    (InternalName: 'Good'; DisplayName: ''; MinimumValue: 60),
    (InternalName: 'Best'; DisplayName: ''; MinimumValue: 80)); // @addr $81040C
  PlanetEconomyInfo: array[TPlanetEconomy] of TEconomyInfo = (
    (InternalName: 'Agriculture'; DisplayName: ''; ShortDisplayName: ''; InventionProgressScale: 0.7),
    (InternalName: 'Mixed'; DisplayName: ''; ShortDisplayName: ''; InventionProgressScale: 1.0),
    (InternalName: 'Industrial'; DisplayName: ''; ShortDisplayName: ''; InventionProgressScale: 1.4)); // @addr $810448
type
  TShipTypeInfo = record // @size $04
    Name: WideString; // @offset $00
  end;

  TShipTypeNameTable = array[TShipType] of TShipTypeInfo;

  PShipTypeNameTable = ^TShipTypeNameTable;

var
  ShipTypeNames: array[TShipType] of TShipTypeInfo = ((Name: 'Kling'), (Name: 'Ranger'), (Name: 'Transport'), (Name: 'Pirate'), (Name: 'Warrior'), (Name: 'Tranclucator'), (Name: 'RC'), (Name: 'PB'), (Name: 'WB'), (Name: 'SB'), (Name: 'BK'), (Name: 'MC'), (Name: 'CB'), (Name: 'UB')); // @addr $810478
type
  TStatusInfo = record // @size $28
    Name: WideString; // @offset $00 Native career identifier.
    MinimumWealthToAverageRatio: Double; // @offset $08 NeedsWealthCatchup ($713ED0): Wealth / AverageRangerCapital threshold.
    MinimumWealthToBestRatio: Double; // @offset $10 Wealth / MaxRangerWealth threshold in the same catch-up test.
    MinimumStrengthToAverageRatio: Double; // @offset $18 NeedsStrengthCatchup ($713E88): Strength / AverageRangerStrength threshold.
    MinimumStrengthToBestRatio: Double; // @offset $20 Strength / BestRangerStrength threshold in the same catch-up test.
  end;

  TCareerTuningTable = array[TRangerCareer] of TStatusInfo;

var
  StationDefaultStandings: array[TStationType] of TShipStanding = (standing_coalition_military, standing_pirate_passive, standing_coalition_military, standing_coalition_active, standing_coalition_active, standing_neutral, standing_pirate_military, standing_unaligned); // @addr $8104B0 Standing used to gate station spawning by faction, including the custom station.
  NonTargetableStationStandingMasks: TFactionStandingMasks = ([standing_coalition_military..standing_neutral], [standing_dominator], [standing_pirate_passive..standing_pirate_military]); // @addr $8104B8 Standing masks used by TPlayer.CanSelectShipTarget.
  FactionStandingMasks: TFactionStandingMasks = ([standing_coalition_military..standing_pirate_passive], [standing_dominator], [standing_coalition_passive..standing_pirate_military]); // @addr $8104C0
  CareerTuning: array[TRangerCareer] of TStatusInfo = (
    (Name: 'Trader'; MinimumWealthToAverageRatio: 1.5; MinimumWealthToBestRatio: 0.4; MinimumStrengthToAverageRatio: 0.9; MinimumStrengthToBestRatio: 0.3),
    (Name: 'Pirate'; MinimumWealthToAverageRatio: 0.9; MinimumWealthToBestRatio: 0.35; MinimumStrengthToAverageRatio: 1.1; MinimumStrengthToBestRatio: 0.5),
    (Name: 'Warrior'; MinimumWealthToAverageRatio: 0.8; MinimumWealthToBestRatio: 0.25; MinimumStrengthToAverageRatio: 1.2; MinimumStrengthToBestRatio: 0.6)
  ); // @addr $8104C8
  TransportTypeNames: array[TTransportType] of WideString = ('Transport', 'Liner', 'Diplomat'); // @addr $810540

type
  TKlingTypeInfo = record // @size $38
    DisplayNames: array[TDominatorSeries] of WideString; // @offset $00 Replaced by localized ShipType.Dominator names during configuration loading.
    MinimumHullSize: Integer; // @offset $0C InitGenerated ($5B2684): random hull-size bounds before HullCapacityScale.
    MaximumHullSize: Integer; // @offset $10 Also averaged by SelectChameleonVisualType ($6CAE18).
    InitialWealthScale: Double; // @offset $18 InitializeDominator ($5B218C): scales Galaxy.MaxRangerWealth.
    BaseNodeReserve: Word; // @offset $20 Base reserve before randomized initialization and applicable difficulty modifiers.
    KillExperience: Word; // @offset $22
    RankPoints: Word; // @offset $24
    PirateRankPoints: Word; // @offset $26
    RankImageIndex: Integer; // @offset $28 Rank graphic selected by scanner and ship screens.
    FactionStrengthWeight: Double; // @offset $30 Multiplies Dominator strength in TStar.GetCachedFactionStrength ($7F3A90).
  end;
  TDominatorDisplayIndex = 0..7; // @size $01 Position in DominatorDisplayOrder, not a ship type ID.
  TDominatorShipDefinitions = array[TDominatorKind] of TKlingTypeInfo;

const
  DominatorDisplayOrder: array[TDominatorDisplayIndex] of TDominatorKind = (dominator_boss, dominator_bertor, dominator_equantor, dominator_urgant, dominator_smersh, dominator_menoc, dominator_shtip, dominator_klig); // @addr $81054C
var
  DominatorShipTypeKeys: array[TDominatorKind] of WideString = ('K0', 'K1', 'K2', 'K3', 'K4', 'K5', 'K6', 'K7'); // @addr $810554 Military-base rank-dialog keys, not display names.
  DominatorShipDefinitions: array[TDominatorKind] of TKlingTypeInfo = (
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 0; MaximumHullSize: 0; InitialWealthScale: 10; BaseNodeReserve: 500; KillExperience: 5000; RankPoints: 250; PirateRankPoints: 0; RankImageIndex: 7; FactionStrengthWeight: 10),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 900; MaximumHullSize: 1400; InitialWealthScale: 0.7; BaseNodeReserve: 100; KillExperience: 1000; RankPoints: 48; PirateRankPoints: 16; RankImageIndex: 5; FactionStrengthWeight: 5),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 700; MaximumHullSize: 900; InitialWealthScale: 0.6; BaseNodeReserve: 50; KillExperience: 500; RankPoints: 24; PirateRankPoints: 8; RankImageIndex: 4; FactionStrengthWeight: 3.5),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 500; MaximumHullSize: 700; InitialWealthScale: 0.5; BaseNodeReserve: 30; KillExperience: 300; RankPoints: 12; PirateRankPoints: 4; RankImageIndex: 3; FactionStrengthWeight: 2),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 350; MaximumHullSize: 500; InitialWealthScale: 0.3; BaseNodeReserve: 15; KillExperience: 150; RankPoints: 6; PirateRankPoints: 2; RankImageIndex: 2; FactionStrengthWeight: 1),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 250; MaximumHullSize: 350; InitialWealthScale: 0.2; BaseNodeReserve: 10; KillExperience: 100; RankPoints: 3; PirateRankPoints: 1; RankImageIndex: 1; FactionStrengthWeight: 1),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 1250; MaximumHullSize: 2000; InitialWealthScale: 2; BaseNodeReserve: 200; KillExperience: 2000; RankPoints: 60; PirateRankPoints: 24; RankImageIndex: 7; FactionStrengthWeight: 7.5),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 150; MaximumHullSize: 250; InitialWealthScale: 0.15; BaseNodeReserve: 5; KillExperience: 50; RankPoints: 1; PirateRankPoints: 1; RankImageIndex: 1; FactionStrengthWeight: 0)
  ); // @addr $810574 TDominatorKind order.
var
  DominatorRetreatStrengthByTier: array[0..3] of Double = (2, 2.2, 2.6, 3); // @addr $810734 Minimum reinforced-system strength by constellation distance tier.
  DominatorSeriesNames: array[TDominatorSeries] of WideString = ('Blazer', 'Keller', 'Terron'); // @addr $810754
var
  DominatorResearchRateMultipliers: array[TDominatorSeries] of Double = (1.0, 1.2, 0.8); // @addr $810760 Native Blazer, Keller, Terron research multipliers.
  ResearchProgramCostFactors: array[TDominatorSeries] of Double = (1, 1.4, 1.8); // @addr $810778
var
  ScriptActionTypeNames: array[TScriptEventKind] of WideString = (
    't_OnStep', 't_OnWeaponShot', 't_OnMissileShot',
    't_OnDealingDamage', 't_OnDealingFatalDamage', 't_OnDealingKamikazeDamage',
    't_OnTakingDamage', 't_OnTakingDamageEn', 't_OnTakingDamageSp',
    't_OnTakingDamageMi', 't_OnWeaponShot2', 't_OnMissileShot2',
    't_OnGettingWeaponHit', 't_OnGettingMissileHit', 't_OnDroidRepair',
    't_OnItemPickUp', 't_OnScan', 't_OnChameleonConfusion',
    't_OnScanPossibility', 't_OnAnotherItem', 't_OnAnotherItem2',
    't_OnAnotherGoods', 't_OnItemHit', 't_OnMissileHittingObject',
    't_OnEnteringForm', 't_OnLeavingForm', 't_OnReEnteringForm',
    't_OnEnteringOtherShip', 't_OnLeavingOtherShip', 't_OnReEnteringOtherShip',
    't_OnPlayerSkillIncrease', 't_OnPlayerTalkedWithShip', 't_OnShipTalkedWithPlayer',
    't_OnDropItem', 't_OnDropItemFixed', 't_OnMovingItemToStorage',
    't_OnReduceEqBattle', 't_OnReduceEqUse', 't_OnReduceEqForce',
    't_OnReduceEqForsage', 't_OnItemDestroy', 't_OnPlayerChangeHull',
    't_OnPlayerUseMM', 't_OnPlayerBuyEq', 't_OnItemEquip',
    't_OnItemDeEquip', 't_OnTrancPacking', 't_OnShipBuysGoods',
    't_OnShipSellsGoods', 't_OnShowingItemInfo', 't_OnShowingShipInfo',
    't_OnShowingStarInfo', 't_OnNonStandartEqChange', 't_OnCustomTargetting',
    't_OnCustomTargettingCheck', 't_OnStartAB', 't_OnABItemDrop',
    't_OnGovItemReward', 't_OnCheckingUsability', 't_OnCheckingUsability2',
    't_OnCheckingUsabilityGoods', 't_OnDeath'); // @addr $810790
type
  TItemType = (
    t_Food = 0,
    t_Medicine = 1,
    t_Technics = 2,
    t_Luxury = 3,
    t_Minerals = 4,
    t_Alcohol = 5,
    t_Arms = 6,
    t_Narcotics = 7,
    t_Artefact = 8,
    t_Artefact2 = 9,
    t_ArtefactHull = 10,
    t_ArtefactFuel = 11,
    t_ArtefactSpeed = 12,
    t_ArtefactPower = 13,
    t_ArtefactRadar = 14,
    t_ArtefactScaner = 15,
    t_ArtefactDroid = 16,
    t_ArtefactNano = 17,
    t_ArtefactHook = 18,
    t_ArtefactDef = 19,
    t_ArtefactAnalyzer = 20,
    t_ArtefactMiniExpl = 21,
    t_ArtefactAntigrav = 22,
    t_ArtefactTransmitter = 23,
    t_ArtefactBomb = 24,
    t_ArtefactTranclucator = 25,
    t_ArtDefToEnergy = 26,
    t_ArtEnergyPulse = 27,
    t_ArtEnergyDef = 28,
    t_ArtSplinter = 29,
    t_ArtDecelerate = 30,
    t_ArtMissileDef = 31,
    t_ArtForsage = 32,
    t_ArtWeaponToSpeed = 33,
    t_ArtGiperJump = 34,
    t_ArtBlackHole = 35,
    t_ArtDefToArms1 = 36,
    t_ArtDefToArms2 = 37,
    t_ArtArtefactor = 38,
    t_ArtBio = 39,
    t_ArtPDTurret = 40,
    t_ArtFastRacks = 41,
    t_Hull = 42,
    t_FuelTanks = 43,
    t_Engine = 44,
    t_Radar = 45,
    t_Scaner = 46,
    t_RepairRobot = 47,
    t_CargoHook = 48,
    t_DefGenerator = 49,
    t_Weapon1 = 50,
    t_Weapon2 = 51,
    t_Weapon3 = 52,
    t_Weapon4 = 53,
    t_Weapon5 = 54,
    t_Weapon6 = 55,
    t_Weapon7 = 56,
    t_Weapon8 = 57,
    t_Weapon9 = 58,
    t_Weapon10 = 59,
    t_Weapon11 = 60,
    t_Weapon12 = 61,
    t_Weapon13 = 62,
    t_Weapon14 = 63,
    t_Weapon15 = 64,
    t_Weapon16 = 65,
    t_Weapon17 = 66,
    t_Weapon18 = 67,
    t_CustomWeapon = 68,
    t_Protoplasm = 69,
    t_UselessItem = 70,
    t_MicroModule = 71,
    t_Cistern = 72,
    t_Satellite = 73,
    t_TreasureMap = 74,
    t_UselessCountableItem = 75
  ); // @size 0x1

  TItemTypeSelection = set of TItemType; // @size 10 Final four bits are storage padding.

const
  // Readable item names for callers; native TItemType spellings above are
  // retained verbatim for RTTI. Weapon names follow Items.Weapon.Name.
  item_food = t_Food;
  item_medicine = t_Medicine;
  item_technical_goods = t_Technics;
  item_luxury = t_Luxury;
  item_minerals = t_Minerals;
  item_alcohol = t_Alcohol;
  item_arms = t_Arms;
  item_narcotics = t_Narcotics;
  item_custom_artefact = t_Artefact;
  item_custom_artefact_no_wear = t_Artefact2;
  artefact_hull = t_ArtefactHull;
  artefact_fuel = t_ArtefactFuel;
  artefact_speed = t_ArtefactSpeed;
  artefact_power = t_ArtefactPower;
  artefact_radar = t_ArtefactRadar;
  artefact_scanner = t_ArtefactScaner;
  artefact_repair_robot = t_ArtefactDroid;
  artefact_nano_repair = t_ArtefactNano;
  artefact_cargo_hook = t_ArtefactHook;
  artefact_defense = t_ArtefactDef;
  artefact_analyzer = t_ArtefactAnalyzer;
  artefact_extra_loot = t_ArtefactMiniExpl;
  artefact_antigravity = t_ArtefactAntigrav;
  artefact_transmitter = t_ArtefactTransmitter;
  artefact_bomb = t_ArtefactBomb;
  artefact_tranclucator = t_ArtefactTranclucator;
  artefact_defense_to_energy = t_ArtDefToEnergy;
  artefact_energy_pulse = t_ArtEnergyPulse;
  artefact_energy_defense = t_ArtEnergyDef;
  artefact_splinter = t_ArtSplinter;
  artefact_decelerate = t_ArtDecelerate;
  artefact_missile_defense = t_ArtMissileDef;
  artefact_afterburner = t_ArtForsage;
  artefact_weapon_to_speed = t_ArtWeaponToSpeed;
  artefact_hyperjump = t_ArtGiperJump;
  artefact_black_hole = t_ArtBlackHole;
  artefact_defense_to_weapon_slot = t_ArtDefToArms1;
  artefact_defense_slot_to_weapons = t_ArtDefToArms2;
  artefact_artefactor = t_ArtArtefactor;
  artefact_health_protection = t_ArtBio;
  artefact_point_defense = t_ArtPDTurret;
  artefact_extra_missiles = t_ArtFastRacks;
  item_hull = t_Hull;
  item_fuel_tanks = t_FuelTanks;
  item_engine = t_Engine;
  item_radar = t_Radar;
  item_scanner = t_Scaner;
  item_repair_robot = t_RepairRobot;
  item_cargo_hook = t_CargoHook;
  item_defense_generator = t_DefGenerator;
  item_industrial_laser = t_Weapon1;
  item_fragmentation_cannon = t_Weapon2;
  item_flux = t_Weapon3;
  item_missile_launcher = t_Weapon4;
  item_treton = t_Weapon5;
  item_wave_phaser = t_Weapon6;
  item_flow_blaster = t_Weapon7;
  item_electronic_cutter = t_Weapon8;
  item_multiresonator = t_Weapon9;
  item_atomic_vision = t_Weapon10;
  item_disintegrator = t_Weapon11;
  item_turbogravitron = t_Weapon12;
  item_imho9000 = t_Weapon13;
  item_vertix = t_Weapon14;
  item_torpedo_tube = t_Weapon15;
  item_esodapher = t_Weapon16;
  item_caphasitor = t_Weapon17;
  item_lirecron = t_Weapon18;
  item_custom_weapon = t_CustomWeapon;
  item_nodes = t_Protoplasm;
  item_misc = t_UselessItem;
  item_micro_module = t_MicroModule;
  item_fuel_container = t_Cistern;
  item_satellite = t_Satellite;
  item_treasure_map = t_TreasureMap;
  item_stackable_misc = t_UselessCountableItem;

  // Equipment slot and shop APIs use the first weapon type to represent all weapons.
  weapon_category = item_industrial_laser;

  WeaponItemTypes = [item_industrial_laser..item_custom_weapon];
  StandardWeaponItemTypes = [item_industrial_laser..item_lirecron];
  UtilityEquipmentTypes = [item_fuel_tanks..item_defense_generator];

type
  TEquipmentInventionIndexTable = array[item_hull..item_defense_generator] of TResearchTrack;

  PEquipmentInventionIndexTable = ^TEquipmentInventionIndexTable;

  SEquipment = record // @size $8
    ItemType: TItemType; // @offset $0
    Name: WideString; // @offset $4
  end;

  // Nine quotas per Coalition race, with every weapon sharing the final category.
  TPlanetEquipmentOfferQuotaRow = array[item_hull..weapon_category] of Integer;
  TPlanetEquipmentOfferQuotaTable = array[owner_maloc..owner_gaal] of TPlanetEquipmentOfferQuotaRow;
  PPlanetEquipmentOfferQuotaTable = ^TPlanetEquipmentOfferQuotaTable;

  // The final item category is shared by every weapon subtype.
  TStationEquipmentOfferQuota = packed record // @size 0x24
    case Boolean of
      False: (
        Hulls: Integer; // @offset 0x00
        FuelTanks: Integer; // @offset 0x04
        Engines: Integer; // @offset 0x08
        Radars: Integer; // @offset 0x0C
        Scanners: Integer; // @offset 0x10
        RepairRobots: Integer; // @offset 0x14
        CargoHooks: Integer; // @offset 0x18
        DefGenerators: Integer; // @offset 0x1C
        Weapons: Integer; // @offset 0x20  Shared quota for item types 50..68.
      );
      True: (
        ByItemCategory: TPlanetEquipmentOfferQuotaRow; // @offset 0x00
      );
  end;
  TStationEquipmentOfferQuotaTable = array[TStationType] of TStationEquipmentOfferQuota;
  PStationEquipmentOfferQuotaTable = ^TStationEquipmentOfferQuotaTable;

  TEquipmentSlotLayouts = array[0..7] of SEquipment;

var
  NonNegotiatingShipTypes: TShipTypeMask = [ship_dominator, ship_tranclucator..station_custom]; // @addr $810888  Excluded from ransom offers and ordinary ally requests.
const
  EquipmentSlotLayouts: array[0..7] of SEquipment = (
    (ItemType: item_fuel_tanks; Name: 'FuelTanks'),
    (ItemType: item_engine; Name: 'Engine'),
    (ItemType: item_radar; Name: 'Radar'),
    (ItemType: item_scanner; Name: 'Scaner'),
    (ItemType: item_repair_robot; Name: 'RepairRobot'),
    (ItemType: item_cargo_hook; Name: 'CargoHook'),
    (ItemType: item_defense_generator; Name: 'DefGenerator'),
    (ItemType: weapon_category; Name: 'Weapon')); // @addr $81088C Used by both the ship inventory and scanner.
var
  ItemTypeNames: array[TItemType] of WideString = (
    'Food', 'Medicine', 'Technics', 'Luxury',
    'Minerals', 'Alcohol', 'Arms', 'Narcotics',
    'Artefact', 'Artefact2', 'ArtHull', 'ArtFuel',
    'ArtSpeed', 'ArtPower', 'ArtRadar', 'ArtScaner',
    'ArtDroid', 'ArtNano', 'ArtHook', 'ArtDef',
    'ArtAnalyzer', 'ArtMiniExpl', 'ArtAntigrav', 'ArtTransmitter',
    'ArtBomb', 'ArtTranclucator', 'ArtDefToEnergy', 'ArtEnergyPulse',
    'ArtEnergyDef', 'ArtSplinter', 'ArtDecelerate', 'ArtMissileDef',
    'ArtForsage', 'ArtWeaponToSpeed', 'ArtGiperJump', 'ArtBlackHole',
    'ArtDefToArms1', 'ArtDefToArms2', 'ArtArtefactor', 'ArtBio',
    'ArtPDTurret', 'ArtFastRacks', 'Hull', 'FuelTanks',
    'Engine', 'Radar', 'Scaner', 'RepairRobot',
    'CargoHook', 'DefGenerator', 'W01', 'W02',
    'W03', 'W04', 'W05', 'W06',
    'W07', 'W08', 'W09', 'W10',
    'W11', 'W12', 'W13', 'W14',
    'W15', 'W16', 'W17', 'W18',
    'CustomWeapon', 'Protoplasm', 'UselessItem', 'Nod',
    'Cistern', 'Satellite', 'TreasureMap', 'UselessCountableItem'); // @addr 0x008108CC
  ArtefactLootPools: array[TItemLootPool] of array of TItemType; // @addr 0x0081B930
  CustomArtefactLootPools: array[TItemLootPool] of array of WideString; // @addr 0x0081B940
  UselessItemLootPools: array[TItemLootPool] of array of WideString; // @addr 0x0081B950
type
  TGoodsInfo = packed record // @size 0x30
    InternalName: WideString; // @offset 0x00  Built-in identifiers such as Food, Technics and Arms.
    DisplayName: WideString; // @offset 0x04  Items.Goods.Name.
    TradeName: WideString; // @offset 0x08  Items.Goods.NameBuy; the form used in trade prompts.
    BaseStock: Integer; // @offset 0x0C
    MinPrice: Integer; // @offset 0x10
    AveragePrice: Integer; // @offset 0x14  Global reference price, not an average of planet quotes.
    MaxPrice: Integer; // @offset 0x18
    TradeExperienceFactor: Single; // @offset 0x1C
    EconomyFactors: array[TPlanetEconomy] of Single; // @offset 0x20  Agricultural, mixed, industrial.
    PirateEconomyFactor: Single; // @offset 0x2C
  end;

  TGoodsInfoTable = array[TGoodsIndex] of TGoodsInfo;

  PGoodsInfoTable = ^TGoodsInfoTable;

var
  GoodsMarket: array[TGoodsIndex] of TGoodsInfo = (
    (InternalName: 'Food';
      DisplayName: '';
      TradeName: '';
      BaseStock: 300;
      MinPrice: 17;
      AveragePrice: 30;
      MaxPrice: 43;
      TradeExperienceFactor: 1.654;
      EconomyFactors: (1.15, 1.0, 0.85);
      PirateEconomyFactor: 0.9),
    (InternalName: 'Medicine';
      DisplayName: '';
      TradeName: '';
      BaseStock: 160;
      MinPrice: 27;
      AveragePrice: 40;
      MaxPrice: 53;
      TradeExperienceFactor: 2.038;
      EconomyFactors: (1.1, 1.0, 0.9);
      PirateEconomyFactor: 0.7),
    (InternalName: 'Technics';
      DisplayName: '';
      TradeName: '';
      BaseStock: 100;
      MinPrice: 62;
      AveragePrice: 80;
      MaxPrice: 98;
      TradeExperienceFactor: 2.722;
      EconomyFactors: (0.85, 1.0, 1.15);
      PirateEconomyFactor: 0.8),
    (InternalName: 'Luxury';
      DisplayName: '';
      TradeName: '';
      BaseStock: 60;
      MinPrice: 160;
      AveragePrice: 200;
      MaxPrice: 240;
      TradeExperienceFactor: 3.0;
      EconomyFactors: (1.0, 1.1, 1.05);
      PirateEconomyFactor: 0.8),
    (InternalName: 'Minerals';
      DisplayName: '';
      TradeName: '';
      BaseStock: 250;
      MinPrice: 8;
      AveragePrice: 12;
      MaxPrice: 16;
      TradeExperienceFactor: 2.0;
      EconomyFactors: (1.15, 1.0, 0.85);
      PirateEconomyFactor: 2.5),
    (InternalName: 'Alcohol';
      DisplayName: '';
      TradeName: '';
      BaseStock: 120;
      MinPrice: 25;
      AveragePrice: 40;
      MaxPrice: 55;
      TradeExperienceFactor: 1.833;
      EconomyFactors: (1.2, 1.0, 0.8);
      PirateEconomyFactor: 1.3),
    (InternalName: 'Arms';
      DisplayName: '';
      TradeName: '';
      BaseStock: 70;
      MinPrice: 75;
      AveragePrice: 100;
      MaxPrice: 125;
      TradeExperienceFactor: 2.5;
      EconomyFactors: (0.85, 1.0, 1.15);
      PirateEconomyFactor: 1.5),
    (InternalName: 'Narcotics';
      DisplayName: '';
      TradeName: '';
      BaseStock: 30;
      MinPrice: 250;
      AveragePrice: 400;
      MaxPrice: 550;
      TradeExperienceFactor: 1.833;
      EconomyFactors: (1.1, 1.0, 0.9);
      PirateEconomyFactor: 2.0)); // @addr $8109FC
var
  GoodsTextOrder: TGoodsTextOrder = (0, 1, 5, 4, 3, 2, 6, 7); // @addr $810B7C
  MissionTypeNames: array[0..4] of WideString = ('SendLetter', 'KillShip', 'PlanetQuest', 'DefSystem', 'DefShip'); // @addr $810B84
type
  TOwnerInfo = packed record // @size 0x20
    InternalName: WideString; // @offset 0x00
    DisplayName: WideString; // @offset 0x04
    FuelPriceFactor: Single; // @offset 0x08
    EquipmentDurabilityFactor: Single; // @offset 0x0C  Reciprocal scales equipment wear and nano-artefact condition repair.
    MinimumAfterburnerWear: Integer; // @offset 0x10
    MaximumAfterburnerWear: Integer; // @offset 0x14
    FearThresholdScale: Single; // @offset $18 Scales hull/win-ratio fear and ransom thresholds ($5A5610/$5A574C); also transport enemy selection ($5AE4B8).
    ColorTag: WideString; // @offset 0x1C
  end;

  TOwnerInfoTable = array[TOwnerId] of TOwnerInfo;

  POwnerInfoTable = ^TOwnerInfoTable;

  TGovermentInfo = record // @size 0xA0
    InternalName: WideString; // @offset 0x00
    DisplayName: WideString; // @offset 0x04
    RevolutionRelationDelta: array[TRangerCareer] of ShortInt; // @offset 0x08  TRangerCareer order.
    QuestOfferProbabilities: array[TQuestKind] of Single; // @offset 0x0C  TQuestKind order.
    GoodsFactors: array[TGoodsIndex] of TPlanetGoodsFactors; // @offset 0x20
  end;

  TPlanetGovernmentMarketTable = array[TPlanetGovernment] of TGovermentInfo;

  PPlanetGovernmentMarketTable = ^TPlanetGovernmentMarketTable;

var
  OwnerInfo: array[TOwnerId] of TOwnerInfo = (
    (InternalName: 'Maloc';
      DisplayName: '';
      FuelPriceFactor: 0.7;
      EquipmentDurabilityFactor: 0.7;
      MinimumAfterburnerWear: 18;
      MaximumAfterburnerWear: 22;
      FearThresholdScale: 0.8;
      ColorTag: '<color=255,000,000>'),
    (InternalName: 'Peleng';
      DisplayName: '';
      FuelPriceFactor: 0.9;
      EquipmentDurabilityFactor: 0.9;
      MinimumAfterburnerWear: 17;
      MaximumAfterburnerWear: 21;
      FearThresholdScale: 0.9;
      ColorTag: '<color=000,255,000>'),
    (InternalName: 'People';
      DisplayName: '';
      FuelPriceFactor: 1.0;
      EquipmentDurabilityFactor: 1.0;
      MinimumAfterburnerWear: 16;
      MaximumAfterburnerWear: 20;
      FearThresholdScale: 1.0;
      ColorTag: '<color=000,148,255>'),
    (InternalName: 'Fei';
      DisplayName: '';
      FuelPriceFactor: 1.15;
      EquipmentDurabilityFactor: 1.15;
      MinimumAfterburnerWear: 14;
      MaximumAfterburnerWear: 17;
      FearThresholdScale: 1.3;
      ColorTag: '<color=255,147,241>'),
    (InternalName: 'Gaal';
      DisplayName: '';
      FuelPriceFactor: 1.3;
      EquipmentDurabilityFactor: 1.3;
      MinimumAfterburnerWear: 14;
      MaximumAfterburnerWear: 16;
      FearThresholdScale: 1.2;
      ColorTag: '<color=237,247,062>'),
    (InternalName: 'Kling';
      DisplayName: '';
      FuelPriceFactor: 1.0;
      EquipmentDurabilityFactor: 1.0;
      MinimumAfterburnerWear: 10;
      MaximumAfterburnerWear: 20;
      FearThresholdScale: 1.0;
      ColorTag: '<color=097,167,190>'),
    (InternalName: 'None';
      DisplayName: '';
      FuelPriceFactor: 1.0;
      EquipmentDurabilityFactor: 1.0;
      MinimumAfterburnerWear: 14;
      MaximumAfterburnerWear: 20;
      FearThresholdScale: 1.0;
      ColorTag: '<color=255,000,255>'),
    (InternalName: 'PirateClan';
      DisplayName: '';
      FuelPriceFactor: 0.8;
      EquipmentDurabilityFactor: 1.0;
      MinimumAfterburnerWear: 16;
      MaximumAfterburnerWear: 20;
      FearThresholdScale: 0.5;
      ColorTag: '<color=255,255,255>')); // @addr $810B98
var
  PlanetOwnerMasks: TPlanetOwnerMasks = (Coalition: [owner_maloc..owner_gaal]; Dominators: [owner_dominator]; PirateClan: [owner_pirate]); // @addr $810C98
  OwnerRelations: TOwnerRelationTable = (
    (100, 80, 70, 40, 60, 0, 0, 30),
    (70, 100, 70, 30, 40, 0, 0, 30),
    (50, 40, 100, 70, 90, 0, 0, 30),
    (40, 30, 80, 100, 70, 0, 0, 30),
    (70, 70, 80, 90, 100, 0, 0, 30),
    (0, 0, 0, 0, 0, 100, 0, 0),
    (0, 0, 0, 0, 0, 0, 100, 0),
    (50, 50, 50, 50, 50, 0, 0, 100)); // @addr $810C9C
var
  PlanetRaceMarket: TPlanetRaceMarketTable = (
    (InventionProgressScale: 0.85;
      InitialInventionBoostCount: 5;
      GoodsFactors: (
        (PriceFactor: 0.85; StockFactor: 1.1),
        (PriceFactor: 1.1; StockFactor: 1.1),
        (PriceFactor: 1.15; StockFactor: 0.5),
        (PriceFactor: 0.85; StockFactor: 0.4),
        (PriceFactor: 0.87; StockFactor: 0.7),
        (PriceFactor: 1.1; StockFactor: 0.1),
        (PriceFactor: 1.2; StockFactor: 0.5),
        (PriceFactor: 0.8; StockFactor: 0.2));
      GovernmentRollThresholds: (10, 30, 50, 90, 95);
      RevolutionChance: 0.002;
      FriendlyRelationScale: 0.7;
      PirateRelationFactor: 1.1;
      UnknownFactor9C: 1.5;
      PirateRelationCeiling: 60),
    (InventionProgressScale: 0.95;
      InitialInventionBoostCount: 6;
      GoodsFactors: (
        (PriceFactor: 0.95; StockFactor: 1.2),
        (PriceFactor: 1.05; StockFactor: 1.0),
        (PriceFactor: 1.07; StockFactor: 0.9),
        (PriceFactor: 1.15; StockFactor: 1.2),
        (PriceFactor: 0.95; StockFactor: 0.8),
        (PriceFactor: 1.05; StockFactor: 1.1),
        (PriceFactor: 1.1; StockFactor: 0.8),
        (PriceFactor: 0.95; StockFactor: 0.6));
      GovernmentRollThresholds: (20, 40, 70, 85, 90);
      RevolutionChance: 0.006;
      FriendlyRelationScale: 1.1;
      PirateRelationFactor: 1.5;
      UnknownFactor9C: 0.8;
      PirateRelationCeiling: 80),
    (InventionProgressScale: 1.0;
      InitialInventionBoostCount: 7;
      GoodsFactors: (
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.5),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 0.8),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0));
      GovernmentRollThresholds: (10, 30, 40, 60, 80);
      RevolutionChance: 0.004;
      FriendlyRelationScale: 1.0;
      PirateRelationFactor: 0.9;
      UnknownFactor9C: 1.2;
      PirateRelationCeiling: 45),
    (InventionProgressScale: 1.1;
      InitialInventionBoostCount: 8;
      GoodsFactors: (
        (PriceFactor: 1.05; StockFactor: 0.7),
        (PriceFactor: 0.85; StockFactor: 0.9),
        (PriceFactor: 0.87; StockFactor: 1.4),
        (PriceFactor: 1.0; StockFactor: 0.8),
        (PriceFactor: 1.15; StockFactor: 0.5),
        (PriceFactor: 1.15; StockFactor: 0.4),
        (PriceFactor: 0.9; StockFactor: 0.4),
        (PriceFactor: 1.1; StockFactor: 0.5));
      GovernmentRollThresholds: (5, 10, 15, 30, 70);
      RevolutionChance: 0.003;
      FriendlyRelationScale: 1.1;
      PirateRelationFactor: 0.7;
      UnknownFactor9C: 1.0;
      PirateRelationCeiling: 35),
    (InventionProgressScale: 1.15;
      InitialInventionBoostCount: 9;
      GoodsFactors: (
        (PriceFactor: 1.1; StockFactor: 0.5),
        (PriceFactor: 0.8; StockFactor: 0.5),
        (PriceFactor: 0.8; StockFactor: 0.8),
        (PriceFactor: 0.85; StockFactor: 0.5),
        (PriceFactor: 1.1; StockFactor: 0.3),
        (PriceFactor: 0.9; StockFactor: 0.3),
        (PriceFactor: 0.84; StockFactor: 0.1),
        (PriceFactor: 1.15; StockFactor: 0.4));
      GovernmentRollThresholds: (5, 8, 10, 30, 60);
      RevolutionChance: 0.002;
      FriendlyRelationScale: 1.3;
      PirateRelationFactor: 0.6;
      UnknownFactor9C: 0.9;
      PirateRelationCeiling: 35)); // @addr $810CDC
  PlanetEquipmentOfferQuotas: TPlanetEquipmentOfferQuotaTable = (
    (3, 2, 2, 2, 1, 2, 2, 2, 6),
    (4, 2, 2, 2, 1, 2, 2, 2, 5),
    (4, 2, 2, 2, 2, 1, 2, 2, 5),
    (3, 2, 2, 1, 1, 2, 2, 1, 4),
    (3, 2, 2, 2, 2, 1, 2, 2, 4)); // @addr $811024
  StationEquipmentOfferQuotas: TStationEquipmentOfferQuotaTable = (
    (Hulls: 4; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4),
    (Hulls: 3; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 3; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4),
    (Hulls: 4; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 6),
    (Hulls: 3; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 2),
    (Hulls: 5; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 2),
    (Hulls: 2; FuelTanks: 1; Engines: 2; Radars: 1; Scanners: 2; RepairRobots: 1; CargoHooks: 2; DefGenerators: 2; Weapons: 1),
    (Hulls: 3; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 3; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4),
    (Hulls: 4; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4)
  ); // @addr $8110D8 Native defaults; aRuins accesses this table through an external-unit reference. Original defining unit is inferred.
  StationGoodsFactors: array[TStationType, TGoodsIndex] of TPlanetGoodsFactors = (
    ((PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.15), (PriceFactor: 0.8; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.5; StockFactor: 0.01)),
    ((PriceFactor: 0.9; StockFactor: 0.15), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.2), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.15), (PriceFactor: 0.9; StockFactor: 0.2), (PriceFactor: 0.9; StockFactor: 0.3), (PriceFactor: 0.9; StockFactor: 0.2)),
    ((PriceFactor: 1.1; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.4; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.5; StockFactor: 0.01)),
    ((PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.8; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.1; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.5; StockFactor: 0.01)),
    ((PriceFactor: 0.9; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.9; StockFactor: 0.3), (PriceFactor: 1.1; StockFactor: 0.1), (PriceFactor: 0.8; StockFactor: 0.1), (PriceFactor: 0.9; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.2), (PriceFactor: 1.1; StockFactor: 0.1)),
    ((PriceFactor: 0.8; StockFactor: 0.2), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 1.0; StockFactor: 0.2), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.05), (PriceFactor: 0.9; StockFactor: 0.15), (PriceFactor: 0.9; StockFactor: 0.1), (PriceFactor: 0.7; StockFactor: 0.2)),
    ((PriceFactor: 1.1; StockFactor: 0.05), (PriceFactor: 1.1; StockFactor: 0.05), (PriceFactor: 0.9; StockFactor: 0.25), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.9; StockFactor: 0.3), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.8; StockFactor: 0.25)),
    ((PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01))); // @addr $8111F8
  PlanetGovernmentMarket: array[TPlanetGovernment] of TGovermentInfo = (
    (InternalName: 'Anarchy';
      DisplayName: '';
      RevolutionRelationDelta: (-30, 30, 0);
      QuestOfferProbabilities: (0.2, 0.6, 0.8, 0.1, 0.3);
      GoodsFactors: (
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.1; StockFactor: 1.0),
        (PriceFactor: 0.8; StockFactor: 0.8),
        (PriceFactor: 0.8; StockFactor: 1.0),
        (PriceFactor: 1.1; StockFactor: 1.0),
        (PriceFactor: 0.9; StockFactor: 1.0))),
    (InternalName: 'Dictatorship';
      DisplayName: '';
      RevolutionRelationDelta: (-40, 20, 20);
      QuestOfferProbabilities: (0.2, 0.7, 0.8, 0.2, 0.5);
      GoodsFactors: (
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 0.9; StockFactor: 1.0),
        (PriceFactor: 0.9; StockFactor: 0.9),
        (PriceFactor: 1.0; StockFactor: 0.9),
        (PriceFactor: 0.9; StockFactor: 0.9))),
    (InternalName: 'Monarchy';
      DisplayName: '';
      RevolutionRelationDelta: (-10, 0, 10);
      QuestOfferProbabilities: (0.2, 0.5, 0.8, 0.5, 0.8);
      GoodsFactors: (
        (PriceFactor: 1.0; StockFactor: 0.9),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 0.8),
        (PriceFactor: 1.0; StockFactor: 0.8),
        (PriceFactor: 1.0; StockFactor: 0.8))),
    (InternalName: 'Republic';
      DisplayName: '';
      RevolutionRelationDelta: (10, -20, 0);
      QuestOfferProbabilities: (0.2, 0.3, 0.8, 0.7, 0.9);
      GoodsFactors: (
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.1; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 0.8),
        (PriceFactor: 1.0; StockFactor: 0.7),
        (PriceFactor: 1.1; StockFactor: 0.7))),
    (InternalName: 'Democracy';
      DisplayName: '';
      RevolutionRelationDelta: (15, -30, 0);
      QuestOfferProbabilities: (0.2, 0.3, 0.8, 0.7, 0.9);
      GoodsFactors: (
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 1.0),
        (PriceFactor: 1.1; StockFactor: 1.0),
        (PriceFactor: 1.0; StockFactor: 0.8),
        (PriceFactor: 1.0; StockFactor: 0.5),
        (PriceFactor: 1.1; StockFactor: 0.6)))); // @addr $8115F8
type
  TRewardInfo = record // @size 0x0C
    AwardId: Byte; // @offset 0x00
    Name: WideString; // @offset 0x04
    Text: WideString; // @offset 0x08
  end;

var
  GoodsLegalOnPlanet: TGoodsLegalityTable = (
    ((True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True)),
    ((True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True)),
    ((True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True)),
    ((True, False, True, False, False), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True)),
    ((True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, True)),
    ((True, False, False, True, True), (True, True, True, True, True), (True, True, True, True, True), (True, True, True, False, False), (True, False, False, True, True)),
    ((True, True, True, True, True), (True, True, True, True, True), (True, True, True, True, False), (True, True, False, False, False), (True, True, False, False, False)),
    ((True, False, False, False, False), (True, True, True, True, True), (True, False, True, False, False), (True, True, False, False, False), (True, False, False, False, False))); // @addr $811918 Indexed by goods, native race and government; False marks prohibited goods.
  MedalNames: array[0..5] of WideString = ('ForLiberationSystem', 'ForAccomplishment', 'ForSecretMission', 'ForCowardice', 'ForPerfidy', 'ForPlanetBattle'); // @addr $8119E0
  CoalitionRankNames: array[TShipRank] of WideString = ('Rookie', 'Cadet', 'Pilot', 'Wingman', 'Leader', 'Ace', 'Commander', 'Admiral'); // @addr $8119F8 Native initialization table.
var
  CoalitionRankPointThresholds: array[TShipRank] of Word = (100, 250, 450, 700, 1000, 1500, 2000, 0); // @addr $811A18 Zero threshold at the maximum rank.
  PirateRankNames: array[TShipRank] of WideString = ('Noobie', 'Kid', 'Rader', 'Skipper', 'Rough', 'Ataman', 'Khan', 'Baron'); // @addr $811A28
var
  PirateRankPointThresholds: array[TShipRank] of Word = (100, 250, 450, 700, 1000, 1500, 3000, 0); // @addr $811A48 Zero threshold at the maximum rank.
  SkillConfigNames: array[TPilotSkill] of WideString = ('sAccuracy', 'sMobility', 'sTechnical', 'sTrader', 'sCharm', 'sLeadership'); // @addr $811A58
var
  RaceSkillEvaluationFactors: array[owner_maloc..owner_gaal, TPilotSkill] of Single = (
    (1.2, 1.1, 0.9, 0.8, 1.0, 1.0),
    (1.0, 1.2, 0.8, 1.1, 1.0, 0.9),
    (0.9, 0.8, 1.0, 1.2, 1.0, 1.1),
    (1.1, 1.0, 1.2, 0.8, 0.9, 1.0),
    (0.8, 0.9, 1.1, 1.0, 1.2, 1.0)); // @addr $811A70 Native race, then TPilotSkill; used by ranger bonus evaluation and character setup.
  PilotSkillEffects: array[0..6, TPilotSkill] of Word = (
    (0, 0, 0, 30, 0, 0), (17, 17, 8, 38, 17, 1),
    (33, 33, 17, 47, 33, 2), (50, 50, 25, 55, 50, 3),
    (67, 67, 33, 63, 67, 4), (83, 83, 42, 72, 83, 5),
    (100, 100, 50, 80, 100, 6)); // @addr $811AE8 Level, then TPilotSkill; Trading supplies the item resale percentage.
  TechnicalSkillSatelliteLimits: array[0..6] of Word = (2, 3, 4, 5, 6, 7, 8); // @addr $811B3C
  TradingSkillSalePercent: array[0..6] of Word = (0, 8, 16, 25, 33, 41, 50); // @addr $811B4C Fraction of the purchase/sale spread recovered by the Trading skill.
  LeadershipExperiencePercent: array[0..6] of Word = (0, 5, 10, 15, 20, 25, 30); // @addr $811B5C
  MaxPlanetNews: Integer = 9; // @addr $811B6C Loaded from GalaxyNews.MaxCntPlanetNews; caps visible-system economic events.
  SizeTagNames: array[0..5] of WideString = ('Zero', 'Mini', 'Small', 'Average', 'Big', 'Huge'); // @addr $811B70
type
  TPrimaryDamageTypeInfo = record // @size $08
    Kind: TWeaponDamageClass; // @offset $00
    BonusKind: TEquipmentBonusKind; // @offset $01
    Name: WideString; // @offset $04
  end;

  TWeaponDamageClassTable = array[TWeaponDamageClass] of TPrimaryDamageTypeInfo;

var
  WealthDemandScales: array[0..5] of Single = (0.0, 0.01, 0.0125, 0.016666667, 0.02, 0.025); // @addr $811B88 Fractions of cached ship wealth used for negotiated amounts.
  MinimumHullSlotCounts: array[TShipSlotKind] of Integer = (1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0); // @addr $811BA0 Includes the unsupported-slot sentinel.
  DefaultHullSlotCounts: array[TShipSlotKind] of Integer = (1, 1, 1, 1, 1, 1, 1, 5, 4, 1, 0); // @addr $811BCC Artefact limit can be overridden by gameplay configuration.
  RangerHullSlots: array[TOwnerId, TShipSlotKind] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 4, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 3, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $811BF8 Native base slot counts; final column is unsupported kind.
  WarriorHullSlots: array[TOwnerId, TShipSlotKind] of Integer = (
    (1, 1, 1, 1, 0, 0, 1, 5, 1, 0, 0),
    (1, 1, 1, 1, 0, 1, 1, 4, 0, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 4, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 4, 0, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $811D58 Native base slot counts; final column is unsupported kind.
  PirateHullSlots: array[TOwnerId, TShipSlotKind] of Integer = (
    (1, 1, 1, 1, 0, 1, 1, 4, 2, 1, 0),
    (1, 1, 1, 1, 1, 1, 0, 5, 3, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 0),
    (1, 1, 1, 1, 1, 1, 0, 3, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $811EB8 Native base slot counts; final column is unsupported kind.
  TransportHullSlots: array[TOwnerId, TShipSlotKind] of Integer = (
    (1, 1, 1, 0, 0, 1, 0, 3, 0, 0, 0),
    (1, 1, 1, 0, 1, 1, 1, 2, 1, 0, 0),
    (1, 1, 1, 0, 1, 1, 0, 2, 0, 0, 0),
    (1, 1, 1, 0, 1, 1, 1, 2, 0, 0, 0),
    (1, 1, 1, 0, 1, 1, 1, 2, 0, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $812018 Native base slot counts; final column is unsupported kind.
  LinerHullSlots: array[TOwnerId, TShipSlotKind] of Integer = (
    (1, 1, 1, 0, 1, 0, 1, 4, 0, 0, 0),
    (1, 1, 1, 0, 1, 0, 1, 4, 0, 0, 0),
    (1, 1, 1, 0, 1, 0, 0, 4, 0, 0, 0),
    (1, 1, 1, 1, 1, 0, 0, 3, 2, 0, 0),
    (1, 1, 1, 1, 0, 0, 0, 3, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $812178 Native base slot counts; final column is unsupported kind.
  DiplomatHullSlots: array[TOwnerId, TShipSlotKind] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 4, 1, 0, 0),
    (1, 1, 1, 1, 1, 1, 0, 3, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 2, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 3, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 2, 3, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $8122D8 Native base slot counts; final column is unsupported kind.
  TranclucatorHullSlots: array[TShipSlotKind] of Integer = (1, 1, 0, 0, 1, 1, 1, 5, 4, 0, 0); // @addr $812438 Native base slot counts; final column is unsupported kind.
  StationHullSlots: array[TStationType, TShipSlotKind] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0)); // @addr $812464 Native base slot counts; final column is unsupported kind.
  DominatorHullSlots: array[TDominatorKind, TShipSlotKind] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 1, 0)); // @addr $8125C4 Native base slot counts; final column is unsupported kind.
  SpecialHullSlots: array[TShipSlotKind] of Integer = (1, 1, 1, 1, 1, 1, 1, 5, 4, 1, 0); // @addr $812724 Native base slot counts; final column is unsupported kind.
  FlagshipHullSlots: array[TShipSlotKind] of Integer = (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0); // @addr $812750 Native base slot counts; final column is unsupported kind.
  HullSlotBonusKinds: array[TShipSlotKind] of TEquipmentBonusKind = (bonus_none, bonus_none, bonus_radar_slots, bonus_scanner_slots, bonus_repair_robot_slots, bonus_cargo_hook_slots, bonus_defense_slots, bonus_weapon_slots, bonus_artefact_slots, bonus_afterburner_slots, bonus_none); // @addr $81277C
  OwnerWeaponAvailability: TOwnerWeaponAvailabilityTable = (availability_maloc_only, availability_peleng_only, availability_human_only, availability_feyan_only, availability_gaal_only, availability_not_sold_node_repair, availability_not_sold, availability_pirate_only); // @addr $812788
  WeaponDamageFlagNames: array[0..20] of WideString = (
    'Energy', 'Splinter', 'Missile', 'Decelerate', 'Destruct', 'Drain', 'Shock',
    'Acid', 'Magnetic', 'DecelerateA', 'DecelerateAEx', 'Undefendable', 'NonLethal',
    'ScanBonus', 'BonusToDamaged', 'MoreDrop', 'DropCargo', 'ReduceEngine',
    'BlockWeapon', 'BlockDroid', 'NoDelta'); // @addr $812790 Native managed-string descriptors.
  WeaponDamageClasses: array[TWeaponDamageClass] of TPrimaryDamageTypeInfo = (
    (Kind: damage_class_energy; BonusKind: bonus_energy_damage; Name: 'Energy'),
    (Kind: damage_class_splinter; BonusKind: bonus_splinter_damage; Name: 'Splinter'),
    (Kind: damage_class_missile; BonusKind: bonus_missile_damage; Name: 'Missile')
  ); // @addr $8127E4 Native scalar values and WideString initializer descriptors.
type
  THullTypeInfo = record // @size $64
    Name: WideString; // @offset $00
    Text: WideString; // @offset $04
    AllowedOwners: TOwnerMask; // @offset $08
    AllowedShipTypes: THullShipTypeMask; // @offset $09
    SlotBonuses: array[TShipSlotKind] of Integer; // @offset $0C Includes the unsupported slot sentinel.
    SizePercent: Integer; // @offset $38 Hull capacity multiplier divided by 100.
    CostPercent: Integer; // @offset $3C Hull price multiplier divided by 100.
    FragilityFactor: Single; // @offset $40 Configured percentage divided by 100.
    FragilityByDamageClass: array[TWeaponDamageClass] of Single; // @offset $44 Defaults to FragilityFactor for omitted damage classes.
    Year: Byte; // @offset $50 HullType.Year.
    ProbabilityWeight: Integer; // @offset $54 HullType.Probability, defaults to one.
    SortKey: Integer; // @offset $58 Numeric suffix of the config block name.
    SystemName: WideString; // @offset $5C
    SystemNameCRC: Cardinal; // @offset $60 CRC32 of the UTF-16 config block name.
  end;

  THullSeriesDefinitions = array of THullTypeInfo;

  TMicroModuleInfo = record // @size 0x124
    SpecialOnly: Boolean; // @offset 0x00
    BlocksMicroModuleSlot: Boolean; // @offset 0x01
    BlocksSpecialSlot: Boolean; // @offset 0x02
    Name: WideString; // @offset 0x04
    NamePrefix: WideString; // @offset 0x08
    Color: WideString; // @offset 0x0C  Configured color text without the enclosing markup.
    TextReplace: WideString; // @offset 0x10
    StatBonuses: TEquipmentBonuses; // @offset 0x14
    CostPercent: Integer; // @offset 0xC0  100 leaves the base cost unchanged.
    SizePercent: Integer; // @offset 0xC4  100 leaves the base weight unchanged.
    FragilityFactor: Single; // @offset 0xC8
    FragilityFactorByDamageClass: array[TWeaponDamageClass] of Single; // @offset 0xCC Energy, splinter and missile wear factors.
    Priority: Byte; // @offset 0xD8
    AllowedHullOwnerMask: TOwnerMask; // @offset 0xD9  OwnerId bits; bit 7 also accepts PirateBuilt hulls (IsBonusCompatibleWithHull, $70D6C0).
    AllowedCustomHullFactions: WideString; // @offset 0xDC
    CustomFaction: WideString; // @offset 0xE0
    AllowedDominatorSeriesMask: TDominatorSeriesMask; // @offset 0xE4
    AllowedItemTypes: TItemTypeSelection; // @offset 0xE5  Item-type set, including four trailing storage bits.
    AllowedCustomWeaponTypes: WideString; // @offset 0xF0
    OfferStationTypes: TShipTypeMask; // @offset 0xF4  Bitset indexed by station ship type.
    OfferStationNames: WideString; // @offset 0xF8  Bracketed Ruins configuration tokens.
    OnPlanets: Boolean; // @offset 0xFC
    RacialRestriction: Boolean; // @offset 0xFD
    SeparatedNumbers: Boolean; // @offset 0xFE
    ConfigNumber: Integer; // @offset 0x100  Legacy numeric key used by older saves.
    ConfigName: WideString; // @offset 0x104
    ConfigNameHash: Cardinal; // @offset 0x108  Stable identifier used to resolve saved template indices.
    KindGraph: WideString; // @offset 0x10C
    MissileGraph: WideString; // @offset 0x110
    ShotVisual: Integer; // @offset 0x114  -1 uses the weapon template's DefaultPalette.
    HullGraphSizePercent: Integer; // @offset 0x118
    CustomTag: WideString; // @offset 0x11C
    WeaponDamageFlags: TDamageFlagSet; // @offset 0x120
  end;

  PMicroModuleTemplate = ^TMicroModuleInfo;

  TMicroModuleTemplates = array of TMicroModuleInfo;

  PMicroModuleTemplates = ^TMicroModuleTemplates;

  TMicroModuleCandidateIndices = array of Integer;

  PMicroModuleCandidateIndices = ^TMicroModuleCandidateIndices;

var
  CombatStatusHullFactors: array[TCombatEffectKind] of Single = (1, 1, 1, 0.3, 0.3, 0, 0); // @addr $8127FC Indexed by TCombatEffectKind.
  CombatStatusAccumulationFactors: array[TCombatEffectKind] of Single = (0, 0, 0.1, 0, 0, 0.025, 0); // @addr $812818
  EquipmentBonusNames: array[TEquipmentBonusKind] of WideString = (
    'bonHull', 'bonFuel', 'bonSpeed',
    'bonJump', 'bonRadar', 'bonScan',
    'bonDroid', 'bonHook', 'bonDef',
    'bonWEnergy', 'bonWSplinter', 'bonWMissile',
    'bonWRadius', 'bonSlotRadar', 'bonSlotScaner',
    'bonSlotDroid', 'bonSlotHook', 'bonSlotDef',
    'bonSlotWeapon', 'bonSlotArt', 'bonSlotForsage',
    'bonHookRadius', 'bonSkill1', 'bonSkill2',
    'bonSkill3', 'bonSkill4', 'bonSkill5',
    'bonSkill6', 'bonMass', 'bonExtraAkrinEff',
    'bonExtraAkrinPenalty', 'bonAmmo', 'bonShots',
    'bonMissileSpeed', 'bonShotSpeed', 'bonHookMaxSpeed',
    'bonHookMinSpeed', 'bonStimCapacity', 'bonZonds',
    'bonAttacks', 'bonResistAsteroid', 'bonAIValue',
    'bonNull'); // @addr $812834
type
  tInventionInfo = record // @size 0x08
    Name: WideString; // @offset $00 Native initialization names the research levels.
    InitialLevel: Byte; // @offset 0x04
    RequiredMainTechLevel: Byte; // @offset 0x05  Compared with InventionLevels[research_main_technology], not ResearchLevelPercent.
  end;

  TPlanetInventionInfoTable = array[TResearchTrack] of tInventionInfo;

  PPlanetInventionInfoTable = ^TPlanetInventionInfoTable;

var
  EquipmentBonusSkills: array[bonus_accuracy..bonus_leadership] of TPilotSkill = (skill_accuracy, skill_maneuverability, skill_technical, skill_trading, skill_charisma, skill_leadership); // @addr $8128E0 Maps bonus_accuracy..bonus_leadership to native pilot skills.
  EquipmentSizeFactors: TEquipmentSizeFactorTable = (2.0, 1.5, 1.0, 0.7, 0.5); // @addr $8128E8
  WeaponRangeLevelFactors: TWeaponRangeLevelFactors = (0.9, 0.95, 0.95, 1.0, 1.0, 1.05, 1.05, 1.1); // @addr $8128FC Native technology multiplier, immediately after EquipmentSizeFactors.
  PlanetInventionInfo: array[TResearchTrack] of tInventionInfo = (
    (Name: 'Hull level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'FuelTanks level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'Engine level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'Radar level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'Scaner level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'RepairRobot level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'CargoHook level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'Tech level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'Weapon1 level'; InitialLevel: 1; RequiredMainTechLevel: 1),
    (Name: 'Weapon2 level'; InitialLevel: 1; RequiredMainTechLevel: 2),
    (Name: 'Weapon3 level'; InitialLevel: 1; RequiredMainTechLevel: 3),
    (Name: 'Weapon4 level'; InitialLevel: 1; RequiredMainTechLevel: 4),
    (Name: 'Weapon5 level'; InitialLevel: 1; RequiredMainTechLevel: 4),
    (Name: 'Weapon6 level'; InitialLevel: 1; RequiredMainTechLevel: 5),
    (Name: 'Weapon7 level'; InitialLevel: 1; RequiredMainTechLevel: 5),
    (Name: 'Weapon8 level'; InitialLevel: 1; RequiredMainTechLevel: 6),
    (Name: 'Weapon9 level'; InitialLevel: 1; RequiredMainTechLevel: 6),
    (Name: 'Weapon10 level'; InitialLevel: 1; RequiredMainTechLevel: 7),
    (Name: 'Weapon11 level'; InitialLevel: 1; RequiredMainTechLevel: 7),
    (Name: 'Weapon12 level'; InitialLevel: 1; RequiredMainTechLevel: 8)); // @addr $81291C
type
  TWeaponInfo = record // @size 0x78
    ItemType: TItemType; // @offset 0x00
    ConfigName: WideString; // @offset 0x04  Custom weapon configuration key.
    TechLevel: Byte; // @offset 0x08
    InventionIndex: TResearchTrack; // @offset 0x09  Planetary invention used to determine the available weapon level.
    CostFactor: Single; // @offset 0x0C
    MinDamage: Integer; // @offset 0x10
    MaxDamage: Integer; // @offset 0x14
    AverageSize: Integer; // @offset 0x18
    AverageRange: Integer; // @offset 0x1C
    ShotSpeedPercent: Integer; // @offset 0x20
    MissileRange: Integer; // @offset 0x24
    MissileMaxSpeed: Integer; // @offset 0x28
    MissileMinSpeed: Integer; // @offset 0x2C
    MissileChanceToBeHit: Byte; // @offset 0x30
    DamageFlags: TDamageFlagSet; // @offset 0x31
    ShotType: TWeaponShotType; // @offset 0x35
    ShotCount: Byte; // @offset 0x36
    AttackCount: Byte; // @offset 0x37
    SecondaryDamageRadius: Single; // @offset 0x38
    MiningFactor: Single; // @offset 0x3C  Divisor of recoverable asteroid minerals; smaller values preserve more. Must be positive for mining.
    DamageScaleByLevel: array[1..8] of Single; // @offset 0x40
    PrimarySE: WideString; // @offset 0x60
    SecondarySE: WideString; // @offset 0x64
    AreaSE: WideString; // @offset 0x68
    DefaultPalette: Integer; // @offset 0x6C
    Availability: TWeaponAvailability; // @offset 0x70
    ArcadeWeaponType: Byte; // @offset 0x71
    TypeHash: Cardinal; // @offset 0x74  Built-in templates use 171 * ItemType; custom templates use CRC32 of the UTF-16 configuration name.
  end;

  PWeaponInfo = ^TWeaponInfo;

  TWeaponInfoTable = array[item_industrial_laser..item_lirecron] of TWeaponInfo;

  PWeaponInfoTable = ^TWeaponInfoTable;

var
  GoodsInflationMin: Single; // @addr $81B960
  GoodsInflationMax: Single; // @addr $81B964
  GoodsStockMin: Single; // @addr $81B968
  GoodsStockMax: Single; // @addr $81B96C
  GoodsInflationStartTurn: Integer; // @addr $81B970
  GoodsInflationEndTurn: Integer; // @addr $81B974
  QuestTuning: TQuestTuningTable; // @addr $81B978
  SkillTrainingCosts: array[0..6, TPilotSkill] of Word; // @addr $81B9B4 Levels 1..6 loaded from configuration; level zero is cleared.
  TotalSkillTrainingCost: Integer; // @addr $81BA08 Sum of all six levels of all six skills.
  QuestExperience: TQuestExperienceTable; // @addr $81BA0C
  HullArtefactArmor: Integer; // @addr $81BA20 Config kArtefactHull.
  HullArtefactStatusDecayFactor: Single; // @addr $81BA24 Set to 1.5 by native configuration loading.
  FuelArtefactBase: Integer; // @addr $81BA28
  SpeedArtefactFactor: Single; // @addr $81BA2C Config kArtefactSpeed.
  EngineArtefactBase: Integer; // @addr $81BA30
  RadarArtefactRange: Integer; // @addr $81BA34 Config kArtefactRadar.
  ScannerArtefactPower: Integer; // @addr $81BA38 Config kArtefactScaner.
  DroidArtefactRepair: Integer; // @addr $81BA3C Config kArtefactDroid.
  DroidArtefactWear: Single; // @addr $81BA40 Config kArtefactDroidWear.
  DroidArtefactStatusDecayFactor: Single; // @addr $81BA44 Set to 1.5 by native configuration loading.
  NanoArtefactRepair: Integer; // @addr $81BA48 Loaded from Artefacts.NumericValues.
  DefenseArtefactBonus: Single; // @addr $81BA4C Config kArtefactDef.
  AntigravityArtefactMassFactor: Single; // @addr $81BA50 Config kArtefactAntigrav.
  CargoHookArtefactPower: Integer; // @addr $81BA54 Config kArtefactHook.
  CargoHookArtefactRange: Integer; // @addr $81BA58 Config kArtefactHookRaduis.
  CargoHookArtefactSpeed: Integer; // @addr $81BA5C Config kArtefactHookSpeed.
  WeaponToSpeedArtefactBonus: Integer; // @addr $81BA60 Config kArtWeaponToSpeed.
  DefenseToEnergyUpperFactor: Single; // @addr $81BA64 Config kArtDefToEnergyUp.
  DefenseToEnergyMinimumFactor: Single; // @addr $81BA68 Config kArtDefToEnergyMin.
  DefenseToEnergyPenalty: Single; // @addr $81BA6C Config kArtDefToEnergyPenalty.
  DefenseToWeaponPenalty: Single; // @addr $81BA70 Config kArtDefToArms1Penalty.
  EnergyPulseArtefactFactor: Single; // @addr $81BA74 Config kArtEnergyPulse.
  EnergyPulseArtefactChance: Single; // @addr $81BA78 Config kArtEnergyPulseChance.
  SplinterArtefactFactor: Single; // @addr $81BA7C Config kArtSplinter.
  HyperJumpArtefactRange: Integer; // @addr $81BA80 Config kArtGiperJump.
  StarHeatArtefactReduction: Single; // @addr $81BA84 Configured star-heat reduction per active artefact.
  ExtraMissileChance: Single; // @addr $81BA88
  AfterburnerArtefactWearFactor: Single; // @addr $81BA8C Config kArtForsage.
  HullArtefactBoostArmor: Integer; // @addr $81BA90 Config kArtefactHullEx.
  HullArtefactBoostStatusDecay: Single; // @addr $81BA94 Set to 0.5 by native configuration loading.
  FuelArtefactBoost: Integer; // @addr $81BA98
  SpeedArtefactBoostFactor: Single; // @addr $81BA9C Config kArtefactSpeedEx.
  EngineArtefactBoost: Integer; // @addr $81BAA0
  RadarArtefactBoostRange: Integer; // @addr $81BAA4 Config kArtefactRadarEx.
  ScannerArtefactBoostPower: Integer; // @addr $81BAA8 Config kArtefactScanerEx.
  DroidArtefactBoostRepair: Integer; // @addr $81BAAC Config kArtefactDroidEx.
  DroidArtefactBoostWear: Single; // @addr $81BAB0 Config kArtefactDroidWearEx.
  DroidArtefactBoostStatusDecay: Single; // @addr $81BAB4 Set to 0.5 by native configuration loading.
  NanoArtefactBoostRepair: Integer; // @addr $81BAB8 Loaded from Artefacts.NumericValues.
  DefenseArtefactBoost: Single; // @addr $81BABC Config kArtefactDefEx.
  AntigravityArtefactBoostFactor: Single; // @addr $81BAC0 Config kArtefactAntigravEx.
  CargoHookArtefactBoostPower: Integer; // @addr $81BAC4 Config kArtefactHookEx.
  CargoHookArtefactBoostRange: Integer; // @addr $81BAC8 Config kArtefactHookRaduisEx.
  CargoHookArtefactBoostSpeed: Integer; // @addr $81BACC Config kArtefactHookSpeedEx.
  WeaponToSpeedArtefactBoost: Integer; // @addr $81BAD0 Config kArtWeaponToSpeedEx.
  DefenseToEnergyUpperBoost: Single; // @addr $81BAD4 Config kArtDefToEnergyUpEx.
  DefenseToEnergyMinimumBoost: Single; // @addr $81BAD8 Config kArtDefToEnergyMinEx.
  DefenseToEnergyBoostPenalty: Single; // @addr $81BADC Config kArtDefToEnergyPenaltyEx.
  EnergyPulseArtefactBoostFactor: Single; // @addr $81BAE0 Config kArtEnergyPulseEx.
  SplinterArtefactBoostFactor: Single; // @addr $81BAE4 Config kArtSplinterEx.
  HyperJumpArtefactBoostRange: Integer; // @addr $81BAE8 Config kArtGiperJumpEx.
  StarHeatArtefactBoostReduction: Single; // @addr $81BAEC Boosted additional reduction.
  ExtraMissileBoostChance: Single; // @addr $81BAF0 Loaded from Artefacts.NumericValues.
  AfterburnerArtefactBoostWearFactor: Single; // @addr $81BAF4 Config kArtForsageEx.
  MinTransmitterPower: Integer; // @addr $81BAF8 Loaded from Artefacts.NumericValues.
  AverageTransmitterPower: Integer; // @addr $81BAFC Loaded from Artefacts.NumericValues.
  MaxTransmitterPower: Integer; // @addr $81BB00 Loaded from Artefacts.NumericValues.
  TransmitterSameSystemPenalty: Integer; // @addr $81BB04 Loaded from Artefacts.NumericValues.
  TransmitterAnySystemPenalty: Integer; // @addr $81BB08 Loaded from Artefacts.NumericValues.
  TransmitterSameSystemPenaltyTurns: Integer; // @addr $81BB0C Loaded from Artefacts.NumericValues.
  TransmitterAnySystemPenaltyTurns: Integer; // @addr $81BB10 Loaded from Artefacts.NumericValues.
  SubportalRewardPenalty: Integer; // @addr $81BB14
  SubportalRewardPenaltyTurns: Integer; // @addr $81BB18
  ItemExplosionBonusDamage: Integer; // @addr $81BB1C Added when Item.DestroyFlag is two.
  BombMinimumDamage: Integer; // @addr $81BB20 Damage at the blast radius.
  BombMaximumDamage: Integer; // @addr $81BB24 Damage at the center.
  BombDamageRadius: Integer; // @addr $81BB28
  ItemExplosionRadiusSquared: Integer; // @addr $81BB2C Square of configured BombRadius.
  PointDefensePassCount: Integer; // @addr $81BB30
  PointDefenseBaseRange: Integer; // @addr $81BB34
  PointDefenseBonusRange: Integer; // @addr $81BB38
  AsteroidMinDamageFactor: Single; // @addr 0x0081BB3C @note "Asteroid.kAsteroidMinDamagePercent divided by 100; fraction of hull capacity."
  AsteroidMaxDamageFactor: Single; // @addr 0x0081BB40 @note "Asteroid.kAsteroidMaxDamagePercent divided by 100."
  AsteroidMinDamageFactorWithDefGenerator: Single; // @addr 0x0081BB44 @note "Asteroid.kAsteroidMinDamagePercentDef divided by 100."
  AsteroidMaxDamageFactorWithDefGenerator: Single; // @addr 0x0081BB48 @note "Asteroid.kAsteroidMaxDamagePercentDef divided by 100."
  HullCapacityScale: Single; // @addr $81BB4C Hull capacities are multiplied by this configuration value.
  HullBaseSize: Integer; // @addr $81BB50
  FuelTanksBaseSize: Integer; // @addr $81BB54
  EngineBaseSize: Integer; // @addr $81BB58
  RadarBaseSize: Integer; // @addr $81BB5C
  ScannerBaseSize: Integer; // @addr $81BB60
  RepairRobotBaseSize: Integer; // @addr $81BB64
  CargoHookBaseSize: Integer; // @addr $81BB68
  DefGeneratorBaseSize: Integer; // @addr $81BB6C
  AfterburnerSpeedFactor: Single; // @addr $81BB70 Config native equipment configuration.
  FuelCapacityByLevel: array[1..8] of Byte; // @addr $81BB74 Loaded from equipment configuration.
  EngineLevelStats: TEngineLevelStatsTable; // @addr $81BB7C Loaded by the native equipment configuration initializer.
  HullLevelStats: THullLevelStatsTable; // @addr $81BB9C Per-technology armor and energy/splinter/missile fragility, used by THull getters.
  RepairRobotLevelPoints: array[1..8] of Byte; // @addr $81BC1C Loaded from mRepair.
  DefGeneratorLevelFactors: array[1..8] of Single; // @addr $81BC24
  RadarLevelRanges: array[1..8] of Word; // @addr $81BC44 Loaded from equipment configuration.
  CargoHookLevelStats: TCargoHookLevelStatsTable; // @addr $81BC54
  HullFragilityByOwner: array[TWeaponDamageClass, TOwnerId] of Single; // @addr $81BCD4 Damage class, then owner; loaded from mFragilityByOwner*.
  HullFragilityByType: array[THullType] of Single; // @addr $81BD34 Loaded from mFragilityByShipType.
  WeaponInfos: array[item_industrial_laser..item_lirecron] of TWeaponInfo; // @addr 0x0081BD60
var
  EquipmentInventionIndices: TEquipmentInventionIndexTable = (research_hull, research_fuel_tanks, research_engine, research_radar, research_scanner, research_repair_robot, research_cargo_hook, research_main_technology); // @addr $8129BC
  CoalitionProjectNames: array[TCoalitionProject] of WideString = ('CreateRC', 'CreatePB', 'CreateWB', 'CreateSB', 'CreateBK', 'CreateMC', 'RangersSubsidy', 'PiratesSubsidy', 'TransportSubsidy', 'LostSubsidy', 'WarSubsidy', 'WarOperation'); // @addr $8129C4
type
  // Locations where captain health effects can be acquired.
  THealthLocation = (
    health_on_planet = 0,
    health_docked = 1,
    health_in_space = 2,
    health_in_combat = 3
  ); // @size $01
  THealthLocations = set of THealthLocation; // @size $01

  TIllnessInfo = record // @size $28
    Name: WideString; // @offset $00
    Text: WideString; // @offset $04
    AllowedLocationOwners: TOwnerMask; // @offset $08
    AllowedOwners: TOwnerMask; // @offset $09
    AllowedRatingBands: TByteMask; // @offset $0A
    AllowedRanks: TByteMask; // @offset $0B
    AllowedCareers: TRangerCareerSet; // @offset $0C
    MedicalPriceSizeLevel: Byte; // @offset $0D Mini..Huge (1..5); GenerateValueForSizeLevel bucket for treatment and stimulation prices.
    DevelopmentRate: Double; // @offset $10 Progress increment factor.
    InfectionChance: Double; // @offset $18
    Locations: THealthLocations; // @offset $20
    Disabled: Boolean; // @offset $21
    Duration: Integer; // @offset $24
  end;

  TCaptainHealthDefinitions = array[disease_blindness..stimulant_absolute_status] of TIllnessInfo;

  TRadiationHealthDefinitions = array[1..1] of TIllnessInfo;

var
  StationServiceRepeatPeriods: array[TCoalitionProject] of Integer = (100, 400, 300, 200, 350, 250, 150, 220, 40, 50, 70, 80); // @addr $8129F4
  ProgramNames: array[TProgramIndex] of WideString = (
    'KellerCall', 'LogicalNegation', 'Dematerial', 'Energotron', 'SabCrack', 'Intercom',
    'Shipwreck', 'WeaponBlocking', 'Insanity', 'Shock', 'SelfDestruction', 'Disconnection'); // @addr $812A24
var
  ProgramDuration: TProgramDurationTable = (0, 0, 0, 0, 0, 0, 0, 10, 23, 7, 0, 0); // @addr $812A54
  PirateProgramBatchSizes: array[TProgramIndex] of Integer = (0, 0, 0, 0, 0, 5, 3, 3, 3, 3, 1, 1); // @addr $812A84
  PirateProgramBaseCosts: array[TProgramIndex] of Integer = (0, 0, 0, 0, 0, 500, 1000, 800, 300, 200, 1200, 900); // @addr $812AB4
  GoodsMarketBaseCaptured: Boolean = False; // @addr $812AE4 Set after the one-time localized base-table copy.
  IntegrityDataEnd: Cardinal = 0; // @addr $812AE8 Four-byte zero marker at the exclusive boundary of that native checksum span.
  LastMedicalPolicyTicks: Integer = 0; // @addr $812AEC Updated by TPlayer.NextDay and read by TfGameEnd.OnOpen; score-related role not fully recovered.
var
  HullMassEvaluationStart: Integer; // @addr $81C5D0 Initialized from HullBaseSize and EquipmentSizeFactors[5].
  HullMassEvaluationEnd: Integer; // @addr $81C5D4 Initialized from HullBaseSize and EquipmentSizeFactors[1].
  WearMassMin: Integer; // @addr $81C5D8
  WearMassMax: Integer; // @addr $81C5DC
  GoodsMarketBase: array[TGoodsIndex] of TGoodsInfo; // @addr $81C5E0
  MicroModuleTemplates: array of TMicroModuleInfo; // @addr 0x0081C760
var
  MicroModuleTemplateCount: Integer; // @addr 0x0081C764
  HullSeriesDefinitions: array of THullTypeInfo; // @addr $81C768 Loaded from HullType configuration, sorted by numeric suffix.
var
  HullSeriesCount: Integer; // @addr $81C76C Native count used by CheatIdeal and hull-series configuration.
  CaptainHealthDefinitions: array[disease_blindness..stimulant_absolute_status] of TIllnessInfo; // @addr $81C770 Disease and stimulant definitions.
  RadiationHealthDefinitions: TRadiationHealthDefinitions; // @addr $81CB30 Finalized as one TIllnessInfo alongside the 24 captain effects.
  MicroModuleCandidateIndices: array of Integer; // @addr 0x0081CB58 @note "Shared selection scratch, sized to MicroModuleTemplateCount when templates load. Callers track the used prefix separately."

implementation

// @unit-initialization $8079AC
// @unit-finalization $7988A0

uses aItem, aShip, Math, CrcUnit, EC_BlockPar, Globals, GlobalsV, EC_Str, GR_Main, SysUtils, aGalaxy, aPlayer, aMyFunction, aRanger, aWarrior, aPirate, aTransport, aKling, aTranclucator, aRuins;

{ @routine $78E854 InitializeGameplayConfig }
procedure InitializeGameplayConfig;
var
  Level, GoodsIndex: Byte;
  Government: TPlanetGovernment;
  Relation: TRelationLevel;
  KlingKind: TDominatorKind; Series: TDominatorSeries; Owner: TOwnerId;
  Economy: TPlanetEconomy;
  Difficulty: ^TGalaxyDifficultyTuning;

  // @nested $78E7E4 ExtrapolateLinearDifficulty
  function ExtrapolateLinearDifficulty(Level: TDifficultyLevel; Level2, Level3: Single): Single; // @addr $78E7E4 @calls "0x0078E9A0,0x0078E9B3,0x0078E9C7,0x0078E9FA,0x0078EA15,0x0078EA3A,0x0078EA71,0x0078EA8C" @ida "float __userpurge $name@<st0>(unsigned __int8 Level@<al>, float Level3@<^0>, float Level2@<^4>, void *ParentFrame@<^8>);" @stackpop 0x8 @note "Nested in InitializeGameplayConfig; unused caller-popped static link."
  var Delta: Integer;
  begin
    Delta := Level - 3;
    Result := Level3 + (Level3 - Level2) * Delta;
  end;

  // @nested $78E810 ExtrapolateGeometricDifficulty
  function ExtrapolateGeometricDifficulty(Level: Byte; Level2, Level3: Single): Single; // @addr $78E810 @calls "0x0078EAA0,0x0078EAB7,0x0078EACE,0x0078EAF3,0x0078EB0E,0x0078EB25" @ida "float __userpurge $name@<st0>(unsigned __int8 Level@<al>, float Level3@<^0>, float Level2@<^4>, void *ParentFrame@<^8>);" @stackpop 0x8 @note "Nested in InitializeGameplayConfig; unused caller-popped static link."
  var Delta: Integer;
  begin
    Delta := Level - 3;
    Result := Level3 * Exp(Ln(Level3 / Level2) * Delta);
  end;

begin
  if LanguageDataConfig.CountParamsByPath('Constellations.GalaxyCountStars') > 0 then
    GalaxyStarCount := ExtractDigitsToIntW(LanguageDataConfig.GetParamByPath('Constellations.GalaxyCountStars'))
  else GalaxyStarCount := 73;
  if LanguageDataConfig.CountParamsByPath('Constellations.GalaxySizeY') > 0 then
    GalaxySizeY := ExtractDigitsToIntW(LanguageDataConfig.GetParamByPath('Constellations.GalaxySizeY'))
  else GalaxySizeY := 100;
  if LanguageDataConfig.CountParamsByPath('Constellations.GalaxySizeX') > 0 then
    GalaxySizeX := ExtractDigitsToIntW(LanguageDataConfig.GetParamByPath('Constellations.GalaxySizeX'))
  else GalaxySizeX := 145;
  if LanguageDataConfig.CountParamsByPath('GalaxyNews.MaxCntPlanetNews') > 0 then
    MaxPlanetNews := ExtractDigitsToIntW(LanguageDataConfig.GetParamByPath('GalaxyNews.MaxCntPlanetNews'))
  else MaxPlanetNews := 9;
  for Level := 4 to 9 do
  begin
    Difficulty := @GalaxyDifficultyTuning[Level];
    Difficulty.MaximumQuestProgramRewardCount := 1;
    Difficulty.GoodsEventDurationFactor := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].GoodsEventDurationFactor, GalaxyDifficultyTuning[3].GoodsEventDurationFactor);
    Difficulty.QuestTimeAndExperienceFactor := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].QuestTimeAndExperienceFactor, GalaxyDifficultyTuning[3].QuestTimeAndExperienceFactor);
    Difficulty.EquipmentWearFactor := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].EquipmentWearFactor, GalaxyDifficultyTuning[3].EquipmentWearFactor);
    Difficulty.InitialPirateControlPercent := Round(ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].InitialPirateControlPercent, GalaxyDifficultyTuning[3].InitialPirateControlPercent));
    Difficulty.MarketPriceBandSqueeze := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].MarketPriceBandSqueeze, GalaxyDifficultyTuning[3].MarketPriceBandSqueeze);
    Difficulty.RandomHoleSpawnRollMaximum := Round(ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].RandomHoleSpawnRollMaximum, GalaxyDifficultyTuning[3].RandomHoleSpawnRollMaximum));
    Difficulty.MaximumResearchMaterialConsumption := Round(ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].MaximumResearchMaterialConsumption, GalaxyDifficultyTuning[3].MaximumResearchMaterialConsumption));
    Difficulty.ArcadeDamageTakenScale := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].ArcadeDamageTakenScale, GalaxyDifficultyTuning[3].ArcadeDamageTakenScale);
    Difficulty.InventionProgressScale := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].InventionProgressScale, GalaxyDifficultyTuning[3].InventionProgressScale);
    Difficulty.ArcadeRewardScale := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].ArcadeRewardScale, GalaxyDifficultyTuning[3].ArcadeRewardScale);
    Difficulty.QuestMoneyFactor := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].QuestMoneyFactor, GalaxyDifficultyTuning[3].QuestMoneyFactor);
    Difficulty.StartingPlayerMoney := Round(ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].StartingPlayerMoney, GalaxyDifficultyTuning[3].StartingPlayerMoney));
    Difficulty.MaximumDominatorResearchRate := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].MaximumDominatorResearchRate, GalaxyDifficultyTuning[3].MaximumDominatorResearchRate);
    Difficulty.CoalitionToPirateBalanceRatio := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].CoalitionToPirateBalanceRatio, GalaxyDifficultyTuning[3].CoalitionToPirateBalanceRatio);
  end;
  for GoodsIndex := Low(TGoodsIndex) to High(TGoodsIndex) do GoodsMarket[GoodsIndex].DisplayName := LocalizedText('Items.Goods.Name.' + IntToStr(GoodsIndex + 1));
  for GoodsIndex := Low(TGoodsIndex) to High(TGoodsIndex) do GoodsMarket[GoodsIndex].TradeName := LocalizedText('Items.Goods.NameBuy.' + IntToStr(GoodsIndex + 1));
  for Government := Low(TPlanetGovernment) to High(TPlanetGovernment) do PlanetGovernmentMarket[Government].DisplayName := LocalizedText('Goverment.Type.' + IntToStr(Ord(Government)));
  for Relation := Low(TRelationLevel) to High(TRelationLevel) do RelationInfo[Relation].DisplayName := LocalizedText('Relations.Type.' + IntToStr(Ord(Relation)));
  for KlingKind := Low(TDominatorKind) to High(TDominatorKind) do
    for Series := Low(TDominatorSeries) to High(TDominatorSeries) do
      DominatorShipDefinitions[KlingKind].DisplayNames[Series] := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[Series] + '.' + IntToStr(Ord(KlingKind)));
  for Owner := owner_maloc to owner_pirate do OwnerInfo[Owner].DisplayName := LookupLocalizedTextByKey('Race.Name.' + OwnerInfo[Owner].InternalName);
  // Both identical localization passes are present in the native initializer.
  for Owner := owner_maloc to owner_pirate do OwnerInfo[Owner].DisplayName := LookupLocalizedTextByKey('Race.Name.' + OwnerInfo[Owner].InternalName);
  for Economy := Low(TPlanetEconomy) to High(TPlanetEconomy) do
  begin
    PlanetEconomyInfo[Economy].DisplayName := LookupLocalizedTextByKey('Economy.Name.' + IntToStr(Ord(Economy)));
    PlanetEconomyInfo[Economy].ShortDisplayName := LookupLocalizedTextByKey('Economy.ShortName.' + IntToStr(Ord(Economy)));
  end;
  if not GoodsMarketBaseCaptured then
  begin
    for GoodsIndex := Low(TGoodsIndex) to High(TGoodsIndex) do GoodsMarketBase[GoodsIndex] := GoodsMarket[GoodsIndex];
    GoodsMarketBaseCaptured := True;
  end;
  InitializeWeaponVisualResources;
  LoadEquipmentConfiguration;
  LoadWeaponConfiguration;
  LoadArtefactConfiguration;
  LoadDamageSkillQuestMarketConfiguration;
  LoadMicroModuleConfiguration;
  InitializeCaptainHealthDefinitions;
  LoadHullSeriesConfiguration;
  if LanguageDataConfig.CountParamsByPath('Artefacts.NumericValues.MaxSlots') > 0 then
    DefaultHullSlotCounts[slot_artefact] := Max(4, Min(32, ExtractDigitsToIntW(LanguageDataConfig.GetParamByPath('Artefacts.NumericValues.MaxSlots'))))
  else DefaultHullSlotCounts[slot_artefact] := 4;
  HullMassEvaluationStart := Round(HullBaseSize * EquipmentSizeFactors[5] * 2);
  HullMassEvaluationEnd := Round(HullBaseSize * EquipmentSizeFactors[1] * 2);
  WearMassMin := Round(HullBaseSize * EquipmentSizeFactors[1] * 5);
  WearMassMax := Round(HullBaseSize * EquipmentSizeFactors[1] * 50);
end;
{ @end $78E854 }

{ @routine $78F26C OwnerToRace }
function OwnerToRace(OwnerId: TOwnerId): TOwnerId;
begin
  case OwnerId of
    owner_maloc: Result := owner_maloc;
    owner_peleng: Result := owner_peleng;
    owner_human: Result := owner_human;
    owner_feyan: Result := owner_feyan;
    owner_gaal: Result := owner_gaal;
  else
    begin
      raise Exception.Create('Error in OwnerToRace');
      Result := owner_maloc;
    end;
  end;
end;
{ @end $78F26C }

{ @routine $78F2D8 RaceToOwner }
function RaceToOwner(RaceId: TOwnerId): TOwnerId;
begin
  case RaceId of
    owner_maloc: Result := owner_maloc;
    owner_peleng: Result := owner_peleng;
    owner_human: Result := owner_human;
    owner_feyan: Result := owner_feyan;
    owner_gaal: Result := owner_gaal;
  else
    begin
      raise Exception.Create('Error in RaceToOwner ' + IntToWideString(Ord(RaceId)));
      Result := owner_maloc;
    end;
  end;
end;
{ @end $78F2D8 }

{ @routine $78F3C8 RaceToSys }
function RaceToSys(RaceId: TOwnerId): WideString;
begin
  case RaceId of
    owner_maloc: Result := 'Maloc';
    owner_peleng: Result := 'Peleng';
    owner_human: Result := 'People';
    owner_feyan: Result := 'Fei';
    owner_gaal: Result := 'Gaal';
  else
    begin
      raise Exception.Create('Error in RaceToSys');
      Result := '';
    end;
  end;
end;
{ @end $78F3C8 }

{ @routine $78F4C4 OwnerToFilmColor }
function OwnerToFilmColor(OwnerId: TOwnerId): Cardinal;
begin
  case OwnerId of
    owner_maloc: Result := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
    owner_peleng: Result := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
    owner_human: Result := CurrentPixelFormat.PackRgbBytes(0, $47, $EA);
    owner_feyan: Result := CurrentPixelFormat.PackRgbBytes(255, $93, $F1);
    owner_gaal: Result := CurrentPixelFormat.PackRgbBytes($ED, $F7, $3E);
    owner_dominator: Result := CurrentPixelFormat.PackRgbBytes($61, $A7, $BE);
    owner_pirate: Result := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  else Result := CurrentPixelFormat.PackRgbBytes(255, 0, 255);
  end;
end;
{ @end $78F4C4 }

{ @routine $78F5A0 CustomFactionToFilmColor }
function CustomFactionToFilmColor(Faction: WideString): Cardinal;
var
  Block: TBlockParEC;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlock('Race').FindBlock('Color');
  if Block <> nil then
    if Block.CountParamsByPath(Faction) > 0 then
    begin
      Text := Block.GetParamByPathOrMarker(Faction);
      if CountDelimitedPartsW(Text, ',') >= 3 then
      begin
        Result := CurrentPixelFormat.PackRgb(
          ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ',')),
          ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, ',')),
          ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 2, ',')));
        Exit;
      end;
    end;
  Result := OwnerToFilmColor(owner_uninhabited);
end;
{ @end $78F5A0 }

{ @routine $78F6E0 LookupNamedColorTag }
function LookupNamedColorTag(Name: WideString): WideString;
var
  Block: TBlockParEC;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlock('Race').FindBlock('Color');
  if Block <> nil then
    if Block.CountParamsByPath(Name) > 0 then
    begin
      Text := Block.GetParam(Name);
      if CountDelimitedPartsW(Text, ',') >= 3 then
      begin
        Result := '<color=' + Text + '>';
        Exit;
      end;
    end;
  Result := '<color=255,000,255>';
end;
{ @end $78F6E0 }

{ @routine $78F818 GetCustomFactionPlanetIconNumber }
function GetCustomFactionPlanetIconNumber(Faction: WideString): Integer;
var Block: TBlockParEC;
begin
  Block := GameDataConfig.GetBlock('Race').FindBlock('PlanetIconNum');
  if (Block <> nil) and (Block.CountParamsByPath(Faction) > 0) then
    Result := ExtractDigitsToIntW(Block.GetParamByPathOrMarker(Faction))
  else Result := -1;
end;
{ @end $78F818 }

{ @routine $78F8E4 GetFactionEmblemPath }
function GetFactionEmblemPath(Faction: WideString): WideString;
begin
  Result := GameDataConfig.GetParamByPathOrMarker('Race.Emblem.2' + Faction);
end;
{ @end $78F8E4 }

{ @routine $78F974 OwnerToSys }
function OwnerToSys(OwnerId: TOwnerId): WideString;
begin
  case OwnerId of
    owner_maloc: Result := 'Maloc';
    owner_peleng: Result := 'Peleng';
    owner_human: Result := 'People';
    owner_feyan: Result := 'Fei';
    owner_gaal: Result := 'Gaal';
    owner_dominator: Result := 'Kling';
    owner_pirate: Result := 'PirateClan';
  else Result := 'None';
  end;
end;
{ @end $78F974 }

{ @routine $78FAAC OwnerFromInternalName }
function OwnerFromInternalName(const Name: WideString): TOwnerId;
begin
  if Name = 'Maloc' then Result := owner_maloc
  else if Name = 'Peleng' then Result := owner_peleng
  else if Name = 'People' then Result := owner_human
  else if Name = 'Fei' then Result := owner_feyan
  else if Name = 'Gaal' then Result := owner_gaal
  else if Name = 'Kling' then Result := owner_dominator
  else if Name = 'PirateClan' then Result := owner_pirate
  else Result := owner_uninhabited;
end;
{ @end $78FAAC }

{ @routine $78FBB4 IsKnownOwnerName }
function IsKnownOwnerName(const Name: WideString): Boolean;
begin
  Result := False;
  if not Result then Result := Name = 'Maloc';
  if not Result then Result := Name = 'Peleng';
  if not Result then Result := Name = 'People';
  if not Result then Result := Name = 'Fei';
  if not Result then Result := Name = 'Gaal';
  if not Result then Result := Name = 'Kling';
  if not Result then Result := Name = 'None';
  if not Result then Result := Name = 'PirateClan';
end;
{ @end $78FBB4 }

{ @routine $78FCE4 NumberToRace }
function NumberToRace(Value: Integer): TOwnerId;
begin
  case Value of
    0: Result := owner_maloc;
    1: Result := owner_peleng;
    2: Result := owner_human;
    3: Result := owner_feyan;
    4: Result := owner_gaal;
  else
    begin
      raise Exception.Create('Error in NumberToRace');
      Result := owner_maloc;
    end;
  end;
end;
{ @end $78FCE4 }

{ @routine $78FD4C MatchesOwnerName }
function MatchesOwnerName(OwnerId: TOwnerId; const Name: WideString): Boolean;
begin
  Result := not IsKnownOwnerName(Name) or (Name = OwnerToSys(OwnerId));
end;
{ @end $78FD4C }

{ @routine $78FDB4 PickRandomEquipmentOwner }
function PickRandomEquipmentOwner(RandomValue: Dword): TOwnerId;
begin
  Result := TOwnerId(SeededRandomIntRange(0, 4, RandomValue));
end;
{ @end $78FDB4 }

{ @routine $78FDC8 MatchesCareerName }
function MatchesCareerName(Career: TRangerCareer; const Names: WideString): Boolean;
begin
  if (Pos(CareerTuning[Career].Name, Names) > 0) or (Names = 'Any') or (Names = '') then Result := True
  else Result := False;
end;
{ @end $78FDC8 }

{ @routine $78FE18 SysToReward }
function SysToReward(const Name: WideString): TAwardKind;
begin
  if Name = 'ForLiberationSystem' then Result := award_liberation
  else if Name = 'ForAccomplishment' then Result := award_accomplishment
  else if Name = 'ForSecretMission' then Result := award_secret_mission
  else if Name = 'ForCowardice' then Result := award_cowardice
  else if Name = 'ForPerfidy' then Result := award_perfidy
  else if Name = 'ForPlanetBattle' then Result := award_planet_battle
  else begin RaiseWideMessage('Error in SysToReward'); Result := award_perfidy; end;
end;
{ @end $78FE18 }

{ @routine $78FFA4 SysToShipType }
function SysToShipType(const Name: WideString): TShipType;
var Kind: TShipType;
begin
  for Kind := Low(TShipType) to High(TShipType) do
    if ShipTypeNames[Kind].Name = Name then begin Result := Kind; Exit; end;
  RaiseWideMessage('Error in SysToShipType');
  Result := ship_dominator;
end;
{ @end $78FFA4 }

{ @routine $79000C GetAverageItemSize }
function GetAverageItemSize(ItemType: TItemType): Integer;
begin
  case ItemType of
    artefact_hull: Result := 12;
    artefact_fuel: Result := 4;
    artefact_speed: Result := 12;
    artefact_power: Result := 7;
    artefact_radar: Result := 10;
    artefact_scanner: Result := 8;
    artefact_repair_robot: Result := 10;
    artefact_nano_repair: Result := 3;
    artefact_cargo_hook: Result := 3;
    artefact_defense: Result := 12;
    artefact_analyzer: Result := 5;
    artefact_extra_loot: Result := 10;
    artefact_antigravity: Result := 20;
    artefact_transmitter: Result := 3;
    artefact_bomb: Result := 5;
    artefact_tranclucator: Result := 50;
    artefact_defense_to_energy: Result := 5;
    artefact_energy_pulse: Result := 8;
    artefact_energy_defense: Result := 5;
    artefact_splinter: Result := 10;
    artefact_decelerate: Result := 5;
    artefact_missile_defense: Result := 6;
    artefact_afterburner: Result := 6;
    artefact_weapon_to_speed: Result := 7;
    artefact_hyperjump: Result := 5;
    artefact_black_hole: Result := 3;
    artefact_defense_to_weapon_slot: Result := 9;
    artefact_defense_slot_to_weapons: Result := 7;
    artefact_artefactor: Result := 3;
    artefact_health_protection: Result := 2;
    artefact_point_defense: Result := 15;
    artefact_extra_missiles: Result := 10;
    item_hull: Result := HullBaseSize;
    item_fuel_tanks: Result := FuelTanksBaseSize;
    item_engine: Result := EngineBaseSize;
    item_radar: Result := RadarBaseSize;
    item_scanner: Result := ScannerBaseSize;
    item_repair_robot: Result := RepairRobotBaseSize;
    item_cargo_hook: Result := CargoHookBaseSize;
    item_defense_generator: Result := DefGeneratorBaseSize;
  else
    if ItemType in WeaponItemTypes then Result := WeaponInfos[ItemType].AverageSize
    else
    begin
      Exception.Create('Error ItemAverageSize'); // Native allocates the exception without raising it.
      Result := 0;
    end;
  end;
end;
{ @end $79000C }

{ @routine $790204 GenerateValueForSizeLevel }
function GenerateValueForSizeLevel(Level: TSizeLevel; Minimum, Maximum: Integer; VariationPercent: Byte; Seed: Cardinal): Integer;
var Center, Bound: Integer;
begin
  case Level of
    0: begin Result := 0; Exit end;
    1: Center := Minimum;
    2: Center := ((Minimum + Maximum) div 2 + Minimum) div 2;
    3: Center := (Minimum + Maximum) div 2;
    4: Center := ((Minimum + Maximum) div 2 + Maximum) div 2;
    5: Center := Maximum;
  else Center := (Minimum + Maximum) div 2;
  end;
  if SeededRandomUnitFloat(Seed + Center) < 0.5 then
  begin
    Bound := Min(Maximum, Round(Center / 100 * VariationPercent + Center));
    Result := SeededRandomIntRange(Center, Bound, Seed);
  end
  else
  begin
    Bound := Max(Minimum, Round(Center - Center / 100 * VariationPercent));
    Result := SeededRandomIntRange(Bound, Center, Seed);
  end;
end;
{ @end $790204 }

{ @routine $790380 SizeTagToLevel }
function SizeTagToLevel(const Tag: WideString): Byte;
begin
  if Tag = 'Zero' then Result := 0
  else if Tag = 'Mini' then Result := 1
  else if Tag = 'Small' then Result := 2
  else if Tag = 'Average' then Result := 3
  else if Tag = 'Big' then Result := 4
  else if Tag = 'Huge' then Result := 5
  else Result := 0;
end;
{ @end $790380 }

{ @routine $790454 ShipToHullType }
function ShipToHullType(Ship: TObject): THullType;
begin
  Result := hull_ranger;
  if Ship is TRanger then Result := hull_ranger
  else if Ship is TWarrior then Result := hull_warrior
  else if Ship is TPirate then Result := hull_pirate
  else if Ship is TTransport then
  begin
    if TTransport(Ship).TransportType = transport_standard then Result := hull_transport
    else if TTransport(Ship).TransportType = transport_liner then Result := hull_liner
    else Result := hull_diplomat;
  end
  else if Ship is TKling then Result := hull_dominator
  else if Ship is TTranclucator then Result := hull_tranclucator
  else if Ship is TRuins then Result := hull_station
  else RaiseWideMessage('ShipToSShipType');
end;
{ @end $790454 }

{ @routine $790540 RelationValueToLevel }
function RelationValueToLevel(Value: TPercent): TRelationLevel;
begin
  case Value of
    0..RelationBadMin - 1: Result := relation_level_hostile;
    RelationBadMin..RelationNormalMin - 1: Result := relation_level_bad;
    RelationNormalMin..RelationGoodMin - 1: Result := relation_level_normal;
    RelationGoodMin..RelationExcellentMin - 1: Result := relation_level_good;
    RelationExcellentMin..100: Result := relation_level_excellent;
  else
    Result := relation_level_normal;
  end;
end;
{ @end $790540 }

{ @routine $79057C ItemTypeToSlotKind }
function ItemTypeToSlotKind(ItemType: TItemType): TShipSlotKind;
begin
  case ItemType of
    item_fuel_tanks: Result := slot_fuel_tanks;
    item_engine: Result := slot_engine;
    item_radar: Result := slot_radar;
    item_scanner: Result := slot_scanner;
    item_repair_robot: Result := slot_repair_robot;
    item_cargo_hook: Result := slot_cargo_hook;
    item_defense_generator: Result := slot_defense_generator;
  else
    if ItemType in WeaponItemTypes then Result := slot_weapon
    else if ItemType in [item_custom_artefact..artefact_extra_missiles] then Result := slot_artefact
    else Result := slot_unsupported;
  end;
end;
{ @end $79057C }

{ @routine $7905DC LocalizedText }
function LocalizedText(const Path: WideString): WideString;
var
  I, Count: Integer;
begin
  Result := '';
  Count := LanguageDataConfig.CountParamsByPath(Path);
  for I := 0 to Count - 1 do
  begin
    if Result <> '' then Result := Result + #13#10;
    Result := Result + LanguageDataConfig.GetParamByPath(Path + ':' + IntToStr(I));
  end;
  if FindTextPosW('<', Result) > 0 then
  begin
    Result := ReplaceAllWideString(Result, '<br>', #13#10);
    Result := ReplaceAllWideString(Result, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Result := ReplaceAllWideString(Result, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
  end;
end;
{ @end $7905DC }

{ @routine $790804 LocalizedColorText }
function LocalizedColorText(const Path: WideString): WideString;
var
  I, Count: Integer;
begin
  Result := '';
  Count := LanguageDataConfig.CountParamsByPath(Path);
  for I := 0 to Count - 1 do
  begin
    if Result <> '' then Result := Result + #13#10;
    Result := Result + LanguageDataConfig.GetParamByPath(Path + ':' + IntToStr(I));
  end;
  if FindTextPosW('<', Result) > 0 then
  begin
    Result := ReplaceAllWideString(Result, '<br>', #13#10);
    Result := ReplaceAllWideString(Result, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Result := ReplaceAllWideString(Result, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
    Result := ReplaceAllWideString(Result, '<clr>', TextHighlightColorTag);
    Result := ReplaceAllWideString(Result, '<clrEnd>', EndColorTag);
  end;
end;
{ @end $790804 }

{ @routine $790A94 ExpandLocalizedTextMarkup }
procedure ExpandLocalizedTextMarkup(var Text: WideString);
begin
  if FindTextPosW('<', Text) > 0 then
  begin
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Text := ReplaceAllWideString(Text, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
    Text := ReplaceAllWideString(Text, '<clr>', TextHighlightColorTag);
    Text := ReplaceAllWideString(Text, '<clrEnd>', EndColorTag);
  end;
end;
{ @end $790A94 }

{ @routine $790C74 ExpandLocalizedTextMarkupAndPrefixLines }
procedure ExpandLocalizedTextMarkupAndPrefixLines(var Text: WideString);
begin
  if FindTextPosW('<', Text) > 0 then
  begin
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Text := ReplaceAllWideString(Text, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
    Text := ReplaceAllWideString(Text, '<clr>', TextHighlightColorTag);
    Text := ReplaceAllWideString(Text, '<clrEnd>', EndColorTag);
  end;
  Text := LocalizedTextLinePrefix + TrimWideString(Text);
  Text := ReplaceAllWideString(Text, #13#10, #13#10 + LocalizedTextLinePrefix);
end;
{ @end $790C74 }

{ @routine $790EA4 PickLocalizedTextVariant }
function PickLocalizedTextVariant(const Path: WideString; SeedOffset: Integer): WideString;
var
  Count, I: Integer;
  Variants: array[0..9] of WideString;
begin
  Count := 0;
  Variants[Count] := LocalizedColorText(Path);
  if Variants[Count] <> '' then Inc(Count);
  I := 1;
  repeat
    Variants[Count] := LocalizedColorText(Path + IntToStr(Count));
    if Variants[Count] <> '' then Inc(Count);
    Inc(I);
  until I > 9;
  if Count = 0 then
    Result := 'String: ' + WrapTextInColor(Path, TextHighlightColorTag) + ' is unavailable'
  else if Count = 1 then Result := Variants[0]
  else
  begin
    Count := SeededRandomIntRange(0, Count - 1, (Galaxy.CurrentTurn + SeedOffset) div 10);
    Result := Variants[Count];
  end;
end;
{ @end $790EA4 }

{ @routine $791088 FindMicroModuleTemplateByCustomTag }
function FindMicroModuleTemplateByCustomTag(CustomTag: WideString): Integer;
var I: Integer;
begin
  for I := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[I].CustomTag = CustomTag then begin Result := I; Exit; end;
  Result := -1;
end;
{ @end $791088 }

{ @routine $791100 LoadArtefactConfiguration }
procedure LoadArtefactConfiguration;
const ArtefactTypes = [artefact_hull..artefact_extra_missiles];
var
  Index: Integer;
  Config, Block: TBlockParEC;
  ItemName: WideString;
  Kind: TItemType;
  CanBeABDrop, CanBeTreasure, CanBeReward: Boolean;
  ABDropCount, TreasureCount, RewardCount, AnyCount: Integer;
begin
  Config := LanguageDataConfig.GetBlockByPath('Artefacts.NumericValues');
  HullArtefactArmor := StrToInt(AnsiString(Config.GetParam('kArtefactHull')));
  HullArtefactStatusDecayFactor := 1.5;
  FuelArtefactBase := StrToInt(AnsiString(Config.GetParam('kArtefactFuel')));
  SpeedArtefactFactor := ExtractDecimalToSingleW(Config.GetParam('kArtefactSpeed'));
  EngineArtefactBase := StrToInt(AnsiString(Config.GetParam('kArtefactPower')));
  RadarArtefactRange := StrToInt(AnsiString(Config.GetParam('kArtefactRadar')));
  ScannerArtefactPower := StrToInt(AnsiString(Config.GetParam('kArtefactScaner')));
  DroidArtefactRepair := StrToInt(AnsiString(Config.GetParam('kArtefactDroid')));
  DroidArtefactWear := ExtractDecimalToSingleW(Config.GetParam('kArtefactDroidWear'));
  DroidArtefactStatusDecayFactor := 1.5;
  NanoArtefactRepair := StrToInt(AnsiString(Config.GetParam('kArtefactNano')));
  DefenseArtefactBonus := ExtractDecimalToSingleW(Config.GetParam('kArtefactDef'));
  AntigravityArtefactMassFactor := ExtractDecimalToSingleW(Config.GetParam('kArtefactAntigrav'));
  CargoHookArtefactPower := StrToInt(AnsiString(Config.GetParam('kArtefactHook')));
  CargoHookArtefactRange := StrToInt(AnsiString(Config.GetParam('kArtefactHookRaduis')));
  CargoHookArtefactSpeed := StrToInt(AnsiString(Config.GetParam('kArtefactHookSpeed')));
  WeaponToSpeedArtefactBonus := StrToInt(AnsiString(Config.GetParam('kArtWeaponToSpeed')));
  DefenseToEnergyUpperFactor := ExtractDecimalToSingleW(Config.GetParam('kArtDefToEnergyUp'));
  DefenseToEnergyMinimumFactor := ExtractDecimalToSingleW(Config.GetParam('kArtDefToEnergyMin'));
  DefenseToEnergyPenalty := ExtractDecimalToSingleW(Config.GetParam('kArtDefToEnergyPenalty'));
  DefenseToWeaponPenalty := ExtractDecimalToSingleW(Config.GetParam('kArtDefToArms1Penalty'));
  EnergyPulseArtefactFactor := ExtractDecimalToSingleW(Config.GetParam('kArtEnergyPulse'));
  EnergyPulseArtefactChance := ExtractDecimalToSingleW(Config.GetParam('kArtEnergyPulseChance'));
  SplinterArtefactFactor := ExtractDecimalToSingleW(Config.GetParam('kArtSplinter'));
  HyperJumpArtefactRange := StrToInt(AnsiString(Config.GetParam('kArtGiperJump')));
  StarHeatArtefactReduction := ExtractDecimalToSingleW(Config.GetParam('kArtPowerSunProtection'));
  ExtraMissileChance := ExtractDecimalToSingleW(Config.GetParam('kArtFastRacksChance'));
  AfterburnerArtefactWearFactor := ExtractDecimalToSingleW(Config.GetParam('kArtForsage'));
  PointDefensePassCount := StrToInt(AnsiString(Config.GetParam('kPDTurretCountShots')));
  PointDefenseBaseRange := StrToInt(AnsiString(Config.GetParam('kPDTurretRange')));
  HullArtefactBoostArmor := StrToInt(AnsiString(Config.GetParam('kArtefactHullEx')));
  HullArtefactBoostStatusDecay := 0.5;
  FuelArtefactBoost := StrToInt(AnsiString(Config.GetParam('kArtefactFuelEx')));
  SpeedArtefactBoostFactor := ExtractDecimalToSingleW(Config.GetParam('kArtefactSpeedEx'));
  EngineArtefactBoost := StrToInt(AnsiString(Config.GetParam('kArtefactPowerEx')));
  RadarArtefactBoostRange := StrToInt(AnsiString(Config.GetParam('kArtefactRadarEx')));
  ScannerArtefactBoostPower := StrToInt(AnsiString(Config.GetParam('kArtefactScanerEx')));
  DroidArtefactBoostRepair := StrToInt(AnsiString(Config.GetParam('kArtefactDroidEx')));
  DroidArtefactBoostWear := ExtractDecimalToSingleW(Config.GetParam('kArtefactDroidWearEx'));
  DroidArtefactBoostStatusDecay := 0.5;
  NanoArtefactBoostRepair := StrToInt(AnsiString(Config.GetParam('kArtefactNanoEx')));
  DefenseArtefactBoost := ExtractDecimalToSingleW(Config.GetParam('kArtefactDefEx'));
  AntigravityArtefactBoostFactor := ExtractDecimalToSingleW(Config.GetParam('kArtefactAntigravEx'));
  CargoHookArtefactBoostPower := StrToInt(AnsiString(Config.GetParam('kArtefactHookEx')));
  CargoHookArtefactBoostRange := StrToInt(AnsiString(Config.GetParam('kArtefactHookRaduisEx')));
  CargoHookArtefactBoostSpeed := StrToInt(AnsiString(Config.GetParam('kArtefactHookSpeedEx')));
  WeaponToSpeedArtefactBoost := StrToInt(AnsiString(Config.GetParam('kArtWeaponToSpeedEx')));
  DefenseToEnergyUpperBoost := ExtractDecimalToSingleW(Config.GetParam('kArtDefToEnergyUpEx'));
  DefenseToEnergyMinimumBoost := ExtractDecimalToSingleW(Config.GetParam('kArtDefToEnergyMinEx'));
  DefenseToEnergyBoostPenalty := ExtractDecimalToSingleW(Config.GetParam('kArtDefToEnergyPenaltyEx'));
  EnergyPulseArtefactBoostFactor := ExtractDecimalToSingleW(Config.GetParam('kArtEnergyPulseEx'));
  SplinterArtefactBoostFactor := ExtractDecimalToSingleW(Config.GetParam('kArtSplinterEx'));
  HyperJumpArtefactBoostRange := StrToInt(AnsiString(Config.GetParam('kArtGiperJumpEx')));
  StarHeatArtefactBoostReduction := ExtractDecimalToSingleW(Config.GetParam('kArtPowerSunProtectionEx'));
  ExtraMissileBoostChance := ExtractDecimalToSingleW(Config.GetParam('kArtFastRacksChanceEx'));
  AfterburnerArtefactBoostWearFactor := ExtractDecimalToSingleW(Config.GetParam('kArtForsageEx'));
  PointDefenseBonusRange := StrToInt(AnsiString(Config.GetParam('kPDTurretRangeEx')));
  MinTransmitterPower := StrToInt(AnsiString(Config.GetParam('MinTransmitterPower')));
  AverageTransmitterPower := StrToInt(AnsiString(Config.GetParam('AverageTransmitterPower')));
  MaxTransmitterPower := StrToInt(AnsiString(Config.GetParam('MaxTransmitterPower')));
  TransmitterSameSystemPenalty := StrToInt(AnsiString(Config.GetParam('kTransmitterPenaltySameSystem')));
  TransmitterAnySystemPenalty := StrToInt(AnsiString(Config.GetParam('kTransmitterPenaltyAnySystem')));
  TransmitterSameSystemPenaltyTurns := StrToInt(AnsiString(Config.GetParam('kTransmitterPenaltySameSystemDuration')));
  TransmitterAnySystemPenaltyTurns := StrToInt(AnsiString(Config.GetParam('kTransmitterPenaltyAnySystemDuration')));
  SubportalRewardPenalty := StrToInt(AnsiString(Config.GetParam('kSubportalPenalty')));
  SubportalRewardPenaltyTurns := StrToInt(AnsiString(Config.GetParam('kSubportalPenaltyDuration')));
  ItemExplosionBonusDamage := StrToInt(AnsiString(Config.GetParam('BombPower')));
  BombMinimumDamage := StrToInt(AnsiString(Config.GetParam('BombPowerMin')));
  BombMaximumDamage := StrToInt(AnsiString(Config.GetParam('BombPowerMax')));
  BombDamageRadius := StrToInt(AnsiString(Config.GetParam('BombRadius')));
  ItemExplosionRadiusSquared := (BombDamageRadius * BombDamageRadius);
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  Config := LanguageDataConfig.GetBlockByPath('Artefacts');
  for Index := 1 to CountItemTypesInMask(ArtefactTypes) do
  begin
    Kind := GetItemTypeFromMask([artefact_hull..artefact_extra_missiles], Index);
    Block := Config.GetBlock(ItemTypeNames[Kind]);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      if CanBeABDrop then Inc(ABDropCount);
      if CanBeTreasure then Inc(TreasureCount);
      if CanBeReward then Inc(RewardCount);
      Inc(AnyCount);
    end;
  end;
  SetLength(ArtefactLootPools[loot_arcade_battle], ABDropCount);
  SetLength(ArtefactLootPools[loot_treasure], TreasureCount);
  SetLength(ArtefactLootPools[loot_reward], RewardCount);
  SetLength(ArtefactLootPools[loot_any_available], AnyCount);
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  for Index := 1 to CountItemTypesInMask(ArtefactTypes) do
  begin
    Kind := GetItemTypeFromMask([artefact_hull..artefact_extra_missiles], Index);
    Block := Config.GetBlock(ItemTypeNames[Kind]);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      if CanBeABDrop then
      begin
        ArtefactLootPools[loot_arcade_battle][ABDropCount] := Kind;
        Inc(ABDropCount);
      end;
      if CanBeTreasure then
      begin
        ArtefactLootPools[loot_treasure][TreasureCount] := Kind;
        Inc(TreasureCount);
      end;
      if CanBeReward then
      begin
        ArtefactLootPools[loot_reward][RewardCount] := Kind;
        Inc(RewardCount);
      end;
      ArtefactLootPools[loot_any_available][AnyCount] := Kind;
      Inc(AnyCount);
    end;
  end;
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  Config := LanguageDataConfig.GetBlockByPath('Artefacts.CustomArtefacts');
  for Index := 0 to Config.GetBlockCount - 1 do
  begin
    Block := Config.GetBlockByIndex(Index);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      if CanBeABDrop then Inc(ABDropCount);
      if CanBeTreasure then Inc(TreasureCount);
      if CanBeReward then Inc(RewardCount);
      Inc(AnyCount);
    end;
  end;
  SetLength(CustomArtefactLootPools[loot_arcade_battle], ABDropCount);
  SetLength(CustomArtefactLootPools[loot_treasure], TreasureCount);
  SetLength(CustomArtefactLootPools[loot_reward], RewardCount);
  SetLength(CustomArtefactLootPools[loot_any_available], AnyCount);
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  for Index := 0 to Config.GetBlockCount - 1 do
  begin
    Block := Config.GetBlockByIndex(Index);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      ItemName := Config.GetBlockNameByIndex(Index);
      if CanBeABDrop then
      begin
        CustomArtefactLootPools[loot_arcade_battle][ABDropCount] := ItemName;
        Inc(ABDropCount);
      end;
      if CanBeTreasure then
      begin
        CustomArtefactLootPools[loot_treasure][TreasureCount] := ItemName;
        Inc(TreasureCount);
      end;
      if CanBeReward then
      begin
        CustomArtefactLootPools[loot_reward][RewardCount] := ItemName;
        Inc(RewardCount);
      end;
      CustomArtefactLootPools[loot_any_available][AnyCount] := ItemName;
      Inc(AnyCount);
    end;
  end;
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  Config := LanguageDataConfig.GetBlockByPath('UselessItems');
  for Index := 0 to Config.GetBlockCount - 1 do
  begin
    Block := Config.GetBlockByIndex(Index);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      if CanBeABDrop then Inc(ABDropCount);
      if CanBeTreasure then Inc(TreasureCount);
      if CanBeReward then Inc(RewardCount);
      Inc(AnyCount);
    end;
  end;
  SetLength(UselessItemLootPools[loot_arcade_battle], ABDropCount);
  SetLength(UselessItemLootPools[loot_treasure], TreasureCount);
  SetLength(UselessItemLootPools[loot_reward], RewardCount);
  SetLength(UselessItemLootPools[loot_any_available], AnyCount);
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  for Index := 0 to Config.GetBlockCount - 1 do
  begin
    Block := Config.GetBlockByIndex(Index);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') > 0) and (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      ItemName := Config.GetBlockNameByIndex(Index);
      if CanBeABDrop then
      begin
        UselessItemLootPools[loot_arcade_battle][ABDropCount] := ItemName;
        Inc(ABDropCount);
      end;
      if CanBeTreasure then
      begin
        UselessItemLootPools[loot_treasure][TreasureCount] := ItemName;
        Inc(TreasureCount);
      end;
      if CanBeReward then
      begin
        UselessItemLootPools[loot_reward][RewardCount] := ItemName;
        Inc(RewardCount);
      end;
      UselessItemLootPools[loot_any_available][AnyCount] := ItemName;
      Inc(AnyCount);
    end;
  end;
end;
{ @end $791100 }

{ @routine $793540 LoadDamageSkillQuestMarketConfiguration }
procedure LoadDamageSkillQuestMarketConfiguration;
var
  Level, Cost: Integer;
  Block: TBlockParEC;
  Values: WideString;
  QuestKind: TQuestKind;
  Skill: TPilotSkill;
begin
  Block := LanguageDataConfig.GetBlockByPath('Asteroid');
  AsteroidMinDamageFactor := StrToInt(AnsiString(Block.GetParam('kAsteroidMinDamagePercent'))) * 0.01;
  AsteroidMaxDamageFactor := StrToInt(AnsiString(Block.GetParam('kAsteroidMaxDamagePercent'))) * 0.01;
  AsteroidMinDamageFactorWithDefGenerator := StrToInt(AnsiString(Block.GetParam('kAsteroidMinDamagePercentDef'))) * 0.01;
  AsteroidMaxDamageFactorWithDefGenerator := StrToInt(AnsiString(Block.GetParam('kAsteroidMaxDamagePercentDef'))) * 0.01;
  TotalSkillTrainingCost := 0;
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do
  begin
    SkillTrainingCosts[0, Skill] := 0;
    Values := LanguageDataConfig.GetBlockByPath('Skills.' + SkillConfigNames[Skill]).GetParam('Points');
    for Level := 1 to 6 do
    begin
      Cost := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
      SkillTrainingCosts[Level, Skill] := Cost;
      Inc(TotalSkillTrainingCost, Cost);
    end;
  end;
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestPoints');
  for QuestKind := Low(TQuestKind) to High(TQuestKind) do QuestExperience[QuestKind] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Ord(QuestKind) - Ord(Low(TQuestKind)), ',')));
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestTurns');
  for QuestKind := Low(TQuestKind) to High(TQuestKind) do QuestTuning[QuestKind].BaseDuration := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Ord(QuestKind) - Ord(Low(TQuestKind)), ',')));
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestMoneyBase');
  for QuestKind := Low(TQuestKind) to High(TQuestKind) do QuestTuning[QuestKind].BaseRewardMoney := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Ord(QuestKind) - Ord(Low(TQuestKind)), ',')));
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestMoneyPerc');
  for QuestKind := Low(TQuestKind) to High(TQuestKind) do QuestTuning[QuestKind].RewardCapitalPercent := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Ord(QuestKind) - Ord(Low(TQuestKind)), ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.Goods');
  GoodsInflationMin := ExtractDecimalToSingleW(Block.GetParam('kInflationMin'));
  GoodsInflationMax := ExtractDecimalToSingleW(Block.GetParam('kInflationMax'));
  GoodsStockMin := ExtractDecimalToSingleW(Block.GetParam('kStockMin'));
  GoodsStockMax := ExtractDecimalToSingleW(Block.GetParam('kStockMax'));
  if Block.CountParams('InflationStartTurn') > 0 then
    GoodsInflationStartTurn := ExtractDigitsToIntW(Block.GetParam('InflationStartTurn'))
  else GoodsInflationStartTurn := 1000;
  if Block.CountParams('InflationEndTurn') > 0 then
    GoodsInflationEndTurn := ExtractDigitsToIntW(Block.GetParam('InflationEndTurn'))
  else GoodsInflationEndTurn := 10000;
end;
{ @end $793540 }

{ @routine $793CC0 LoadEquipmentConfiguration }
procedure LoadEquipmentConfiguration;
var Level: Byte; Block: TBlockParEC; Values: WideString; DamageKind: TWeaponDamageClass; Owner: TOwnerId; HullKind: THullType;
begin
  Block := LanguageDataConfig.GetBlockByPath('Items.Hull');
  HullBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  HullCapacityScale := HullBaseSize / 500;
  Values := Block.GetParam('mAlloy');
  for Level := Low(HullLevelStats) to High(HullLevelStats) do
    HullLevelStats[Level].Armor := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(HullLevelStats), ',')));
  for DamageKind := Low(TWeaponDamageClass) to High(TWeaponDamageClass) do
  begin
    Values := Block.GetParam('mFragilityByLevel' + WeaponDamageClasses[DamageKind].Name);
    for Level := Low(HullLevelStats) to High(HullLevelStats) do
      HullLevelStats[Level].Fragility[DamageKind] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - Low(HullLevelStats), ','));
    Values := Block.GetParam('mFragilityByOwner' + WeaponDamageClasses[DamageKind].Name);
    for Owner := Low(TOwnerId) to High(TOwnerId) do
      HullFragilityByOwner[DamageKind, Owner] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Ord(Owner) - Ord(Low(TOwnerId)), ','));
  end;
  Values := Block.GetParam('mFragilityByShipType');
  for HullKind := Low(HullFragilityByType) to High(HullFragilityByType) do
    HullFragilityByType[HullKind] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Ord(HullKind) - Ord(Low(HullFragilityByType)), ','));
  Block := LanguageDataConfig.GetBlockByPath('Items.FuelTanks');
  FuelTanksBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mCapacity');
  for Level := Low(FuelCapacityByLevel) to High(FuelCapacityByLevel) do
    FuelCapacityByLevel[Level] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(FuelCapacityByLevel), ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.Engine');
  EngineBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mSpeed');
  for Level := Low(EngineLevelStats) to High(EngineLevelStats) do
    EngineLevelStats[Level].Speed := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(EngineLevelStats), ',')));
  Values := Block.GetParam('mJump');
  for Level := Low(EngineLevelStats) to High(EngineLevelStats) do
    EngineLevelStats[Level].JumpRange := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(EngineLevelStats), ',')));
  AfterburnerSpeedFactor := ExtractDecimalToSingleW(Block.GetParam('ForsageCoef'));
  Block := LanguageDataConfig.GetBlockByPath('Items.RepairRobot');
  RepairRobotBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mRepair');
  for Level := Low(RepairRobotLevelPoints) to High(RepairRobotLevelPoints) do
    RepairRobotLevelPoints[Level] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(RepairRobotLevelPoints), ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.DefGenerator');
  DefGeneratorBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mDef');
  for Level := Low(DefGeneratorLevelFactors) to High(DefGeneratorLevelFactors) do
    DefGeneratorLevelFactors[Level] := 1 - ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - Low(DefGeneratorLevelFactors), ','));
  Block := LanguageDataConfig.GetBlockByPath('Items.Radar');
  RadarBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mRadius');
  for Level := Low(RadarLevelRanges) to High(RadarLevelRanges) do
    RadarLevelRanges[Level] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(RadarLevelRanges), ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.Scaner');
  ScannerBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Block := LanguageDataConfig.GetBlockByPath('Items.CargoHook');
  CargoHookBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mMass');
  for Level := Low(CargoHookLevelStats) to High(CargoHookLevelStats) do
    CargoHookLevelStats[Level].PickupPower := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(CargoHookLevelStats), ',')));
  Values := Block.GetParam('mRadius');
  for Level := Low(CargoHookLevelStats) to High(CargoHookLevelStats) do
    CargoHookLevelStats[Level].Range := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - Low(CargoHookLevelStats), ',')));
  Values := Block.GetParam('mSpeedFar');
  for Level := Low(CargoHookLevelStats) to High(CargoHookLevelStats) do
    CargoHookLevelStats[Level].MinPullSpeed := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - Low(CargoHookLevelStats), ','));
  Values := Block.GetParam('mSpeedClose');
  for Level := Low(CargoHookLevelStats) to High(CargoHookLevelStats) do
    CargoHookLevelStats[Level].MaxPullSpeed := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - Low(CargoHookLevelStats), ','));
end;
{ @end $793CC0 }

{ @routine $794754 LoadWeaponConfiguration }
procedure LoadWeaponConfiguration;
var
  Level, Index: Integer;
  Block: TBlockParEC;
  Values: WideString;
  Kind: TItemType;
  DamageKind: Byte;
begin
  for Index := 1 to CountItemTypesInMask(StandardWeaponItemTypes) do
  begin
    Kind := GetItemTypeFromMask(StandardWeaponItemTypes, Index);
    Block := LanguageDataConfig.GetBlockByPath('Items.Weapon.Stats.' + IntToStr(Ord(Kind) + 1 - 50));
    with WeaponInfos[Kind] do
    begin
      ItemType := Kind;
      ConfigName := ItemTypeNames[Kind];
      TechLevel := StrToInt(AnsiString(Block.GetParam('TechLevel')));
      CostFactor := ExtractDecimalToSingleW(Block.GetParam('kCost'));
      MinDamage := StrToInt(AnsiString(Block.GetParam('MinDamage')));
      MaxDamage := StrToInt(AnsiString(Block.GetParam('MaxDamage')));
      AverageSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
      AverageRange := StrToInt(AnsiString(Block.GetParam('AverageRadius')));
      ShotSpeedPercent := StrToInt(AnsiString(Block.GetParam('Speed')));
      if Block.CountParams('SecondaryDamageRadius') > 0 then
        SecondaryDamageRadius := StrToInt(AnsiString(Block.GetParam('SecondaryDamageRadius')))
      else SecondaryDamageRadius := 0;
      MiningFactor := StrToFloat(AnsiString(Block.GetParam('MiningFactor')));
      ArcadeWeaponType := Ord(Kind);
      Availability := availability_unrestricted;
      DamageFlags := [];
      Values := Block.GetParam('DamageSet');
      for DamageKind := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
        if not (DamageKind in [Ord(damage_flag_artefact_slow), Ord(damage_flag_extra_artefact_slow), Ord(damage_flag_nonlethal)]) and (Pos(WeaponDamageFlagNames[DamageKind], Values) > 0) then
          Include(DamageFlags, TDamageFlag(DamageKind));
      ShotType := shot_single_target;
      ShotCount := 1;
      Values := Block.GetParam('ShotType');
      if Pos('Normal', Values) > 0 then
      begin
      end
      else if Pos('Splash', Values) > 0 then ShotType := shot_splash
      else if Pos('Exploder', Values) > 0 then ShotType := shot_explode_on_kill
      else if Pos('AreaDamage', Values) > 0 then ShotType := shot_area_damage
      else if Pos('Torpedo', Values) > 0 then ShotType := shot_torpedo
      else if Pos('Missile', Values) > 0 then ShotType := shot_missile
      else if Pos('Rocket', Values) > 0 then ShotType := shot_rocket
      else if Pos('Chain', Values) > 0 then ShotType := shot_chain;
      if ShotType in [shot_chain, shot_missile, shot_rocket] then ShotCount := ExtractDigitsToIntW(Values);
      AttackCount := 1;
      if Block.CountParams('AttackCount') > 0 then AttackCount := StrToInt(AnsiString(Block.GetParam('AttackCount')));
      MissileRange := 0;
      MissileMaxSpeed := 0;
      MissileMinSpeed := 0;
      MissileChanceToBeHit := 0;
      if Block.CountParams('MissileRadius') > 0 then MissileRange := StrToInt(AnsiString(Block.GetParam('MissileRadius')));
      if Block.CountParams('MissileMaxSpeed') > 0 then MissileMaxSpeed := StrToInt(AnsiString(Block.GetParam('MissileMaxSpeed')));
      if Block.CountParams('MissileMinSpeed') > 0 then MissileMinSpeed := StrToInt(AnsiString(Block.GetParam('MissileMinSpeed')));
      if Block.CountParams('MissileChanceToBeHit') > 0 then MissileChanceToBeHit := StrToInt(AnsiString(Block.GetParam('MissileChanceToBeHit')));
      Values := Block.GetParam('mWeaponDamage');
      for Level := 1 to 8 do DamageScaleByLevel[Level] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - 1, ','));
    end;
  end;
  for Level := 1 to CountItemTypesInMask(StandardWeaponItemTypes) do
  begin
    Kind := GetItemTypeFromMask(StandardWeaponItemTypes, Level);
    WeaponInfos[Kind].PrimarySE := 'Weapon.' + IntToStr(Ord(Kind) - 50);
    WeaponInfos[Kind].SecondarySE := 'Weapon.NoGraph';
    if WeaponInfos[Kind].ShotType in [shot_torpedo, shot_missile, shot_rocket] then
      WeaponInfos[Kind].AreaSE := 'Weapon.MissileHit'
    else WeaponInfos[Kind].AreaSE := '';
    WeaponInfos[Kind].DefaultPalette := 0;
    WeaponInfos[Kind].TypeHash := Ord(Kind) * 171;
  end;
  WeaponInfos[item_multiresonator].SecondarySE := 'Weapon.Nine';
  WeaponInfos[item_imho9000].SecondarySE := 'Weapon.12';
  WeaponInfos[item_vertix].AreaSE := 'Weapon.13';
  WeaponInfos[item_industrial_laser].InventionIndex := research_industrial_laser;
  WeaponInfos[item_fragmentation_cannon].InventionIndex := research_fragmentation_cannon;
  WeaponInfos[item_flux].InventionIndex := research_flux;
  WeaponInfos[item_missile_launcher].InventionIndex := research_missile_launcher;
  WeaponInfos[item_treton].InventionIndex := research_treton;
  WeaponInfos[item_wave_phaser].InventionIndex := research_wave_phaser;
  WeaponInfos[item_flow_blaster].InventionIndex := research_flow_blaster;
  WeaponInfos[item_electronic_cutter].InventionIndex := research_electronic_cutter;
  WeaponInfos[item_multiresonator].InventionIndex := research_multiresonator;
  WeaponInfos[item_atomic_vision].InventionIndex := research_atomic_vision;
  WeaponInfos[item_disintegrator].InventionIndex := research_disintegrator;
  WeaponInfos[item_turbogravitron].InventionIndex := research_turbogravitron;
  WeaponInfos[item_imho9000].InventionIndex := research_turbogravitron;
  WeaponInfos[item_vertix].InventionIndex := research_turbogravitron;
  WeaponInfos[item_torpedo_tube].InventionIndex := research_turbogravitron;
  WeaponInfos[item_esodapher].InventionIndex := research_multiresonator;
  WeaponInfos[item_caphasitor].InventionIndex := research_flux;
  WeaponInfos[item_lirecron].InventionIndex := research_missile_launcher;
  WeaponInfos[item_imho9000].Availability := availability_not_sold_node_repair;
  WeaponInfos[item_vertix].Availability := availability_not_sold_node_repair;
  WeaponInfos[item_torpedo_tube].Availability := availability_not_sold_node_repair;
  WeaponInfos[item_esodapher].Availability := availability_pirate_only;
  WeaponInfos[item_caphasitor].Availability := availability_pirate_only;
  WeaponInfos[item_lirecron].Availability := availability_pirate_only;
end;
{ @end $794754 }

{ @routine $7954B8 LoadMicroModuleConfiguration }
procedure LoadMicroModuleConfiguration;
var
  Block: TBlockParEC;
  Tokens: WideString;
  Index, Position, Part: Integer;
  Value, CustomName: WideString;
  Kind: TItemType;
  DamageKind: Byte;
  BonusKind: TEquipmentBonusKind;
  DamageClass: TWeaponDamageClass;
  StationKind: TStationType;
  BlockIndices: array of Integer;
  SortKeys: array of Integer;

  // @nested $7952AC ReadMicroModuleParam
  function ReadMicroModuleParam(ParamName: WideString): WideString; // @addr $7952AC @note "Nested in LoadMicroModuleConfiguration; reads its current Block through the caller-popped static link."
  var I, Count: Integer;
  begin
    Result := '';
    Count := Block.CountParams(ParamName);
    for I := 0 to Count - 1 do
    begin
      if Result <> '' then Result := Result + #13#10;
      Result := Result + Block.GetParamByPath(ParamName + ':' + WideString(IntToStr(I)));
    end;
    if FindTextPosW('<', Result) > 0 then
    begin
      Result := ReplaceAllWideString(Result, '<br>', #13#10);
      Result := ReplaceAllWideString(Result, '<ll>', #13#10' '#13#10);
    end;
  end;

  // @nested $795430 ConsumeMicroModuleToken
  function ConsumeMicroModuleToken(Token: WideString): Boolean; // @addr $795430 @note "Nested in LoadMicroModuleConfiguration; removes every occurrence of Token from its remaining-token string."
  begin
    if Pos(Token, Tokens) > 0 then
    begin
      Result := True;
      Tokens := ReplaceAllWideString(Tokens, Token, '');
    end
    else Result := False;
  end;

begin
  Block := LanguageDataConfig.GetBlock('MicroModuls');
  MicroModuleTemplateCount := Block.GetBlockCount;
  SetLength(MicroModuleTemplates, MicroModuleTemplateCount);
  SetLength(MicroModuleCandidateIndices, MicroModuleTemplateCount);
  SetLength(BlockIndices, MicroModuleTemplateCount);
  SetLength(SortKeys, MicroModuleTemplateCount);
  for Index := 0 to MicroModuleTemplateCount - 1 do
  begin
    BlockIndices[Index] := Index;
    SortKeys[Index] := ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index));
  end;
  for Index := 0 to MicroModuleTemplateCount - 2 do
    for Position := MicroModuleTemplateCount - 1 downto Index + 1 do
      if SortKeys[Position - 1] > SortKeys[Position] then
      begin
        Part := SortKeys[Position - 1];
        SortKeys[Position - 1] := SortKeys[Position];
        SortKeys[Position] := Part;
        Part := BlockIndices[Position - 1];
        BlockIndices[Position - 1] := BlockIndices[Position];
        BlockIndices[Position] := Part;
      end;
  for Index := 0 to MicroModuleTemplateCount - 1 do
  begin
    Block := LanguageDataConfig.GetBlock('MicroModuls');
    with MicroModuleTemplates[Index] do
    begin
      ConfigNumber := SortKeys[Index];
      ConfigName := Block.GetBlockNameByIndex(BlockIndices[Index]);
      ConfigNameHash := InitCrc32;
      ConfigNameHash := UpdateCrc32(ConfigNameHash, PWideChar(ConfigName), Length(ConfigName) * 2);
      ConfigNameHash := FinishCrc32(ConfigNameHash);
      Block := Block.GetBlockByIndex(BlockIndices[Index]);
      SpecialOnly := ExtractDigitsToIntW(ReadMicroModuleParam('Special')) <> 0;
      BlocksMicroModuleSlot := ExtractDigitsToIntW(ReadMicroModuleParam('BlockMM')) <> 0;
      BlocksSpecialSlot := ExtractDigitsToIntW(ReadMicroModuleParam('BlockImp')) <> 0;
      RacialRestriction := ExtractDigitsToIntW(ReadMicroModuleParam('RacialRestriction')) <> 0;
      SeparatedNumbers := ExtractDigitsToIntW(ReadMicroModuleParam('SeparatedNumbers')) <> 0;
      Name := ReadMicroModuleParam('Name');
      NamePrefix := ReadMicroModuleParam('NamePrefix');
      Color := ReadMicroModuleParam('Color');
      TextReplace := ReadMicroModuleParam('TextReplace');
      for BonusKind := Low(StatBonuses) to High(StatBonuses) do
      begin
        Value := ReadMicroModuleParam(EquipmentBonusNames[BonusKind]);
        if Value = '' then StatBonuses[BonusKind] := 0
        else if BonusKind in [bonus_acryn_effect, bonus_acryn_penalty] then StatBonuses[BonusKind] := Round(ExtractDecimalToSingleW(Value) * 100)
        else StatBonuses[BonusKind] := StrToInt(AnsiString(Value));
      end;
      Value := ReadMicroModuleParam('Cost');
      if Value = '' then CostPercent := 100 else CostPercent := StrToInt(AnsiString(Value));
      Value := ReadMicroModuleParam('Size');
      if Value = '' then SizePercent := 100 else SizePercent := StrToInt(AnsiString(Value));
      Value := ReadMicroModuleParam('Fragility');
      if Value = '' then FragilityFactor := 1 else FragilityFactor := StrToInt(AnsiString(Value)) * 0.01;
      for DamageClass := Low(TWeaponDamageClass) to High(TWeaponDamageClass) do
      begin
        Value := ReadMicroModuleParam('Fragility' + WeaponDamageClasses[DamageClass].Name);
        if Value = '' then FragilityFactorByDamageClass[DamageClass] := FragilityFactor
        else FragilityFactorByDamageClass[DamageClass] := StrToInt(AnsiString(Value)) * 0.01;
      end;
      Value := ReadMicroModuleParam('Owner');
      if (Value = '') or (Value = 'Any') then
      begin
        if SpecialOnly then AllowedHullOwnerMask := [owner_maloc..owner_gaal, owner_pirate]
        else AllowedHullOwnerMask := [owner_maloc..owner_dominator, owner_pirate];
        AllowedDominatorSeriesMask := [series_blazer..series_terron];
        AllowedCustomHullFactions := '';
      end
      else
      begin
        AllowedHullOwnerMask := [];
        AllowedDominatorSeriesMask := [];
        Tokens := ReplaceAllWideString(Value, ' ', '');
        Tokens := '<' + ReplaceAllWideString(Tokens, ',', '>,<') + '>';
        if ConsumeMicroModuleToken('<Maloc>') then Include(AllowedHullOwnerMask, owner_maloc);
        if ConsumeMicroModuleToken('<Peleng>') then Include(AllowedHullOwnerMask, owner_peleng);
        if ConsumeMicroModuleToken('<People>') then Include(AllowedHullOwnerMask, owner_human);
        if ConsumeMicroModuleToken('<Fei>') then Include(AllowedHullOwnerMask, owner_feyan);
        if ConsumeMicroModuleToken('<Gaal>') then Include(AllowedHullOwnerMask, owner_gaal);
        if ConsumeMicroModuleToken('<PirateClan>') then Include(AllowedHullOwnerMask, owner_pirate);
        if ConsumeMicroModuleToken('<None>') then Include(AllowedHullOwnerMask, owner_uninhabited);
        if SpecialOnly then
        begin
          if ConsumeMicroModuleToken('<Kling>') then Include(AllowedHullOwnerMask, owner_dominator);
          ConsumeMicroModuleToken('<NonKling>');
        end
        else
        begin
          if not ConsumeMicroModuleToken('<NonKling>') then Include(AllowedHullOwnerMask, owner_dominator);
          ConsumeMicroModuleToken('<Kling>');
        end;
        if ConsumeMicroModuleToken('<Blazer>') then
        begin
          Include(AllowedDominatorSeriesMask, series_blazer);
          if SpecialOnly then Include(AllowedHullOwnerMask, owner_dominator);
        end;
        if ConsumeMicroModuleToken('<Terron>') then
        begin
          Include(AllowedDominatorSeriesMask, series_terron);
          if SpecialOnly then Include(AllowedHullOwnerMask, owner_dominator);
        end;
        if ConsumeMicroModuleToken('<Keller>') then
        begin
          Include(AllowedDominatorSeriesMask, series_keller);
          if SpecialOnly then Include(AllowedHullOwnerMask, owner_dominator);
        end;
        if AllowedDominatorSeriesMask = [] then AllowedDominatorSeriesMask := [series_blazer..series_terron];
        AllowedCustomHullFactions := '';
        for Part := 0 to CountDelimitedPartsW(Tokens, ',') - 1 do
        begin
          CustomName := TrimWideString(ExtractDelimitedPartW(Tokens, Part, ','));
          if CustomName <> '' then
            if AllowedCustomHullFactions <> '' then AllowedCustomHullFactions := AllowedCustomHullFactions + ',' + CustomName
            else AllowedCustomHullFactions := CustomName;
        end;
      end;
      CustomFaction := ReadMicroModuleParam('CustomFaction');
      Value := ReadMicroModuleParam('Priority');
      if Value = '' then Priority := 100 else Priority := StrToInt(AnsiString(Value));
      Value := ReadMicroModuleParam('Equipments');
      if (Value = '') or (Value = 'Any') then
      begin
        AllowedItemTypes := [item_hull..item_custom_weapon];
        AllowedCustomWeaponTypes := 'Any';
      end
      else
      begin
        AllowedItemTypes := [];
        AllowedCustomWeaponTypes := '';
        Tokens := ReplaceAllWideString(Value, ' ', '');
        Tokens := '<' + ReplaceAllWideString(Tokens, ',', '>,<') + '>';
        if ConsumeMicroModuleToken('<Hull>') then Include(AllowedItemTypes, item_hull);
        if ConsumeMicroModuleToken('<FuelTank>') then Include(AllowedItemTypes, item_fuel_tanks);
        if ConsumeMicroModuleToken('<Engine>') then Include(AllowedItemTypes, item_engine);
        if ConsumeMicroModuleToken('<Radar>') then Include(AllowedItemTypes, item_radar);
        if ConsumeMicroModuleToken('<Scaner>') then Include(AllowedItemTypes, item_scanner);
        if ConsumeMicroModuleToken('<Droid>') then Include(AllowedItemTypes, item_repair_robot);
        if ConsumeMicroModuleToken('<Hook>') then Include(AllowedItemTypes, item_cargo_hook);
        if ConsumeMicroModuleToken('<DefGenerator>') then Include(AllowedItemTypes, item_defense_generator);
        for Part := 1 to CountItemTypesInMask(StandardWeaponItemTypes) do
        begin
          Kind := GetItemTypeFromMask(StandardWeaponItemTypes, Part);
          if ConsumeMicroModuleToken('<' + ItemTypeNames[Kind] + '>') then
            Include(AllowedItemTypes, Kind)
          else if (Pos('<WMissile>', Tokens) > 0) and (damage_flag_missile in WeaponInfos[Kind].DamageFlags) then
            Include(AllowedItemTypes, Kind)
          else if (Pos('<WSplinter>', Tokens) > 0) and (damage_flag_splinter in WeaponInfos[Kind].DamageFlags) then
            Include(AllowedItemTypes, Kind)
          else if (Pos('<WEnergy>', Tokens) > 0) and (damage_flag_energy in WeaponInfos[Kind].DamageFlags) then
            Include(AllowedItemTypes, Kind);
        end;
        for Part := 0 to CountDelimitedPartsW(Tokens, ',') - 1 do
        begin
          CustomName := TrimWideString(ExtractDelimitedPartW(Tokens, Part, ','));
          if CustomName <> '' then
            if AllowedCustomWeaponTypes <> '' then AllowedCustomWeaponTypes := AllowedCustomWeaponTypes + ',' + CustomName
            else AllowedCustomWeaponTypes := CustomName;
        end;
      end;
      Value := ReadMicroModuleParam('Ruins');
      OfferStationTypes := [];
      OfferStationNames := ReplaceAllWideString(Value, ' ', '');
      OfferStationNames := '<' + ReplaceAllWideString(OfferStationNames, ',', '>,<') + '>';
      if Value = 'Any' then OfferStationTypes := [station_ranger_center..station_dominion]
      else if Value <> '' then
        for StationKind := station_ranger_center to station_dominion do
          if Pos(ShipTypeNames[StationKind].Name, Value) > 0 then Include(OfferStationTypes, StationKind);
      OnPlanets := ExtractDigitsToIntW(ReadMicroModuleParam('OnPlanets')) <> 0;
      Value := ReadMicroModuleParam('WeaponMods');
      WeaponDamageFlags := [];
      if Value <> '' then
        for DamageKind := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
          if not (DamageKind in [Ord(damage_flag_energy)..Ord(damage_flag_missile)]) and not (DamageKind in [Ord(damage_flag_artefact_slow), Ord(damage_flag_extra_artefact_slow), Ord(damage_flag_nonlethal)]) and (Pos(WeaponDamageFlagNames[DamageKind], Value) > 0) then
            Include(WeaponDamageFlags, TDamageFlag(DamageKind));
      KindGraph := ReadMicroModuleParam('KindGraph');
      MissileGraph := ReadMicroModuleParam('MissileGraph');
      Value := ReadMicroModuleParam('ShotVisual');
      if Value = '' then ShotVisual := -1 else ShotVisual := StrToInt(AnsiString(Value));
      Value := ReadMicroModuleParam('HullGraphSize');
      if Value = '' then HullGraphSizePercent := 100 else HullGraphSizePercent := StrToInt(AnsiString(Value));
      CustomTag := ReadMicroModuleParam('CustomTag');
    end;
  end;
  BlockIndices := nil;
  SortKeys := nil;
end;
{ @end $7954B8 }

{ @routine $7969C0 InitializeCaptainHealthDefinitions }
procedure InitializeCaptainHealthDefinitions;
var I: Integer; Path, Value: WideString;
begin
  CaptainHealthDefinitions[disease_blindness].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_blindness].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_blindness].AllowedRatingBands := [2, 3, 4, 5];
  CaptainHealthDefinitions[disease_blindness].AllowedRanks := [2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_blindness].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_blindness].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[disease_blindness].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[disease_blindness].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_blindness].Locations := [health_in_combat];
  CaptainHealthDefinitions[disease_blindness].Duration := 150;

  CaptainHealthDefinitions[disease_chekumash].AllowedLocationOwners := [owner_peleng];
  CaptainHealthDefinitions[disease_chekumash].AllowedOwners := [owner_peleng, owner_human, owner_feyan, owner_gaal];
  CaptainHealthDefinitions[disease_chekumash].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_chekumash].AllowedRanks := [3, 4, 5];
  CaptainHealthDefinitions[disease_chekumash].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_chekumash].MedicalPriceSizeLevel := 4;
  CaptainHealthDefinitions[disease_chekumash].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[disease_chekumash].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_chekumash].Locations := [health_on_planet];
  CaptainHealthDefinitions[disease_chekumash].Duration := 555;

  CaptainHealthDefinitions[disease_holy_fanaticism].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_holy_fanaticism].AllowedOwners := [owner_maloc, owner_peleng, owner_human];
  CaptainHealthDefinitions[disease_holy_fanaticism].AllowedRatingBands := [3, 4, 5];
  CaptainHealthDefinitions[disease_holy_fanaticism].AllowedRanks := [3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_holy_fanaticism].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_holy_fanaticism].MedicalPriceSizeLevel := 3;
  CaptainHealthDefinitions[disease_holy_fanaticism].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[disease_holy_fanaticism].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_holy_fanaticism].Locations := [health_in_combat];
  CaptainHealthDefinitions[disease_holy_fanaticism].Duration := 200;

  CaptainHealthDefinitions[disease_complex_immunocide].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_complex_immunocide].AllowedOwners := [owner_peleng, owner_human, owner_feyan, owner_gaal];
  CaptainHealthDefinitions[disease_complex_immunocide].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_complex_immunocide].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_complex_immunocide].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_complex_immunocide].MedicalPriceSizeLevel := 5;
  CaptainHealthDefinitions[disease_complex_immunocide].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[disease_complex_immunocide].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_complex_immunocide].Locations := [health_in_space];
  CaptainHealthDefinitions[disease_complex_immunocide].Duration := 1000;

  CaptainHealthDefinitions[disease_mysterious_luatanza].AllowedLocationOwners := [owner_gaal];
  CaptainHealthDefinitions[disease_mysterious_luatanza].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_mysterious_luatanza].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_mysterious_luatanza].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_mysterious_luatanza].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_mysterious_luatanza].MedicalPriceSizeLevel := 1;
  CaptainHealthDefinitions[disease_mysterious_luatanza].DevelopmentRate := 10.0;
  CaptainHealthDefinitions[disease_mysterious_luatanza].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_mysterious_luatanza].Locations := [health_on_planet, health_docked];
  CaptainHealthDefinitions[disease_mysterious_luatanza].Duration := 170;

  CaptainHealthDefinitions[disease_drug_addiction].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_drug_addiction].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_drug_addiction].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_drug_addiction].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_drug_addiction].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_drug_addiction].MedicalPriceSizeLevel := 4;
  CaptainHealthDefinitions[disease_drug_addiction].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[disease_drug_addiction].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_drug_addiction].Locations := [];
  CaptainHealthDefinitions[disease_drug_addiction].Duration := 1000;

  CaptainHealthDefinitions[disease_whirlwind_concussion].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_whirlwind_concussion].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_whirlwind_concussion].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_whirlwind_concussion].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_whirlwind_concussion].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_whirlwind_concussion].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[disease_whirlwind_concussion].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[disease_whirlwind_concussion].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_whirlwind_concussion].Locations := [health_in_combat];
  CaptainHealthDefinitions[disease_whirlwind_concussion].Duration := 130;

  CaptainHealthDefinitions[disease_pulled_muscle].AllowedLocationOwners := [owner_peleng, owner_human, owner_feyan, owner_gaal];
  CaptainHealthDefinitions[disease_pulled_muscle].AllowedOwners := [owner_peleng, owner_human, owner_feyan, owner_gaal];
  CaptainHealthDefinitions[disease_pulled_muscle].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_pulled_muscle].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_pulled_muscle].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_pulled_muscle].MedicalPriceSizeLevel := 1;
  CaptainHealthDefinitions[disease_pulled_muscle].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[disease_pulled_muscle].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_pulled_muscle].Locations := [health_in_combat];
  CaptainHealthDefinitions[disease_pulled_muscle].Duration := 100;

  CaptainHealthDefinitions[disease_grand_malosausus].AllowedLocationOwners := [owner_maloc];
  CaptainHealthDefinitions[disease_grand_malosausus].AllowedOwners := [owner_maloc];
  CaptainHealthDefinitions[disease_grand_malosausus].AllowedRatingBands := [2, 3, 4, 5];
  CaptainHealthDefinitions[disease_grand_malosausus].AllowedRanks := [2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_grand_malosausus].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_grand_malosausus].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[disease_grand_malosausus].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[disease_grand_malosausus].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_grand_malosausus].Locations := [health_on_planet, health_docked, health_in_space];
  CaptainHealthDefinitions[disease_grand_malosausus].Duration := 180;

  CaptainHealthDefinitions[disease_bitter_pelenosia].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_bitter_pelenosia].AllowedOwners := [owner_peleng];
  CaptainHealthDefinitions[disease_bitter_pelenosia].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_bitter_pelenosia].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_bitter_pelenosia].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_bitter_pelenosia].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[disease_bitter_pelenosia].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[disease_bitter_pelenosia].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_bitter_pelenosia].Locations := [health_on_planet, health_docked, health_in_space];
  CaptainHealthDefinitions[disease_bitter_pelenosia].Duration := 122;

  CaptainHealthDefinitions[disease_aka_sezyanka].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_aka_sezyanka].AllowedOwners := [owner_feyan];
  CaptainHealthDefinitions[disease_aka_sezyanka].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[disease_aka_sezyanka].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_aka_sezyanka].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_aka_sezyanka].MedicalPriceSizeLevel := 4;
  CaptainHealthDefinitions[disease_aka_sezyanka].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[disease_aka_sezyanka].InfectionChance := 1.0;
  CaptainHealthDefinitions[disease_aka_sezyanka].Locations := [health_on_planet, health_docked];
  CaptainHealthDefinitions[disease_aka_sezyanka].Duration := 164;

  CaptainHealthDefinitions[disease_new_molizone].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[disease_new_molizone].AllowedOwners := [owner_gaal];
  CaptainHealthDefinitions[disease_new_molizone].AllowedRatingBands := [2, 3, 4, 5];
  CaptainHealthDefinitions[disease_new_molizone].AllowedRanks := [2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[disease_new_molizone].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[disease_new_molizone].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[disease_new_molizone].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[disease_new_molizone].InfectionChance := 0.5;
  CaptainHealthDefinitions[disease_new_molizone].Locations := [health_on_planet, health_docked, health_in_space];
  CaptainHealthDefinitions[disease_new_molizone].Duration := 88;

  RadiationHealthDefinitions[1].AllowedLocationOwners := [owner_maloc..owner_gaal];
  RadiationHealthDefinitions[1].AllowedOwners := [owner_maloc..owner_gaal];
  RadiationHealthDefinitions[1].AllowedRatingBands := [1, 2, 3, 4, 5];
  RadiationHealthDefinitions[1].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  RadiationHealthDefinitions[1].AllowedCareers := [career_trader, career_pirate, career_warrior];
  RadiationHealthDefinitions[1].MedicalPriceSizeLevel := 4;
  RadiationHealthDefinitions[1].DevelopmentRate := 100.0;
  RadiationHealthDefinitions[1].InfectionChance := 0.0;
  RadiationHealthDefinitions[1].Locations := [];
  RadiationHealthDefinitions[1].Duration := 30;

  CaptainHealthDefinitions[stimulant_maloq_sizha].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_maloq_sizha].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_maloq_sizha].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_maloq_sizha].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_maloq_sizha].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_maloq_sizha].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_maloq_sizha].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_maloq_sizha].InfectionChance := 0.9;
  CaptainHealthDefinitions[stimulant_maloq_sizha].Duration := 140;

  CaptainHealthDefinitions[stimulant_one_eyed_khamas].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].InfectionChance := 0.9;
  CaptainHealthDefinitions[stimulant_one_eyed_khamas].Duration := 130;

  CaptainHealthDefinitions[stimulant_stardust].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_stardust].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_stardust].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_stardust].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_stardust].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_stardust].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_stardust].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_stardust].InfectionChance := 0.8;
  CaptainHealthDefinitions[stimulant_stardust].Duration := 140;

  CaptainHealthDefinitions[stimulant_super_technician].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_super_technician].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_super_technician].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_super_technician].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_super_technician].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_super_technician].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_super_technician].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_super_technician].InfectionChance := 0.4;
  CaptainHealthDefinitions[stimulant_super_technician].Duration := 120;

  CaptainHealthDefinitions[stimulant_gaalian_alacrity].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].InfectionChance := 0.9;
  CaptainHealthDefinitions[stimulant_gaalian_alacrity].Duration := 90;

  CaptainHealthDefinitions[stimulant_blood_djogar].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_blood_djogar].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_blood_djogar].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_blood_djogar].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_blood_djogar].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_blood_djogar].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_blood_djogar].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_blood_djogar].InfectionChance := 0.8;
  CaptainHealthDefinitions[stimulant_blood_djogar].Duration := 300;

  CaptainHealthDefinitions[stimulant_ragobam_whisper].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_ragobam_whisper].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_ragobam_whisper].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_ragobam_whisper].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_ragobam_whisper].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_ragobam_whisper].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_ragobam_whisper].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_ragobam_whisper].InfectionChance := 0.9;
  CaptainHealthDefinitions[stimulant_ragobam_whisper].Duration := 140;

  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].InfectionChance := 0.9;
  CaptainHealthDefinitions[stimulant_shakhmandoo_leader].Duration := 200;

  CaptainHealthDefinitions[stimulant_psychotropic_cache].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_psychotropic_cache].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_psychotropic_cache].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_psychotropic_cache].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_psychotropic_cache].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_psychotropic_cache].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_psychotropic_cache].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_psychotropic_cache].InfectionChance := 0.9;
  CaptainHealthDefinitions[stimulant_psychotropic_cache].Duration := 200;

  CaptainHealthDefinitions[stimulant_business_mark].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_business_mark].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_business_mark].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_business_mark].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_business_mark].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_business_mark].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_business_mark].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_business_mark].InfectionChance := 0.25;
  CaptainHealthDefinitions[stimulant_business_mark].Duration := 150;

  CaptainHealthDefinitions[stimulant_doubleplex].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_doubleplex].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_doubleplex].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_doubleplex].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_doubleplex].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_doubleplex].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_doubleplex].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_doubleplex].InfectionChance := 0.15;
  CaptainHealthDefinitions[stimulant_doubleplex].Duration := 90;

  CaptainHealthDefinitions[stimulant_absolute_status].AllowedLocationOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_absolute_status].AllowedOwners := [owner_maloc..owner_gaal];
  CaptainHealthDefinitions[stimulant_absolute_status].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[stimulant_absolute_status].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[stimulant_absolute_status].AllowedCareers := [career_trader, career_pirate, career_warrior];
  CaptainHealthDefinitions[stimulant_absolute_status].MedicalPriceSizeLevel := 2;
  CaptainHealthDefinitions[stimulant_absolute_status].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[stimulant_absolute_status].InfectionChance := 0.2;
  CaptainHealthDefinitions[stimulant_absolute_status].Duration := 120;

  for I := disease_blindness to disease_new_molizone do
    with CaptainHealthDefinitions[I] do
    begin
      Path := 'Illness.Illness.' + IntToStr(I - 1);
      Name := LocalizedText(Path + '.Name');
      Text := LocalizedText(Path + '.Text');
      Disabled := False;
      Value := LocalizedText(Path + '.Time');
      if Value <> '' then Duration := StrToInt(AnsiString(Value));
    end;

  for I := Low(RadiationHealthDefinitions) to High(RadiationHealthDefinitions) do
    with RadiationHealthDefinitions[I] do
    begin
      Path := 'Illness.ExtraIllness.' + IntToStr(I);
      Name := LocalizedText(Path + '.Name');
      Text := LocalizedText(Path + '.Text');
      Disabled := False;
      Value := LocalizedText(Path + '.Time');
      if Value <> '' then Duration := StrToInt(AnsiString(Value));
    end;

  for I := 1 to 12 do
    with CaptainHealthDefinitions[12 + I] do
    begin
      Path := 'Illness.Stimulant.' + IntToStr(I - 1);
      Name := LocalizedText(Path + '.Name');
      Text := LocalizedText(Path + '.Text');
      Disabled := False;
      Value := LocalizedText(Path + '.Time');
      if Value <> '' then Duration := StrToInt(AnsiString(Value));
    end;
end;
{ @end $7969C0 }

{ @routine $797B2C LoadHullSeriesConfiguration }
procedure LoadHullSeriesConfiguration;
var
  Block: TBlockParEC;
  Index, Position, Temp: Integer;
  Value: WideString;
  DamageKind: TWeaponDamageClass;
  BlockIndices: array of Integer;
  SortKeys: array of Integer;

  // @nested $7979A8 ReadHullSeriesParam
  function ReadHullSeriesParam(ParamName: WideString): WideString; // @addr $7979A8 @note "Nested in LoadHullSeriesConfiguration; reads its current Block through the caller-popped static link."
  var I, Count: Integer;
  begin
    Result := '';
    Count := Block.CountParams(ParamName);
    for I := 0 to Count - 1 do
    begin
      if Result <> '' then Result := Result + #13#10;
      Result := Result + Block.GetParamByPath(ParamName + ':' + WideString(IntToStr(I)));
    end;
    if FindTextPosW('<', Result) > 0 then
    begin
      Result := ReplaceAllWideString(Result, '<br>', #13#10);
      Result := ReplaceAllWideString(Result, '<ll>', #13#10' '#13#10);
    end;
  end;

begin
  Block := LanguageDataConfig.GetBlock('HullType');
  HullSeriesCount := Block.GetBlockCount;
  SetLength(BlockIndices, HullSeriesCount);
  SetLength(SortKeys, HullSeriesCount);
  Position := 0;
  for Index := 0 to HullSeriesCount - 1 do
    if Block.GetBlockNameByIndex(Index) <> 'HullOldfag' then
    begin
      BlockIndices[Position] := Index;
      SortKeys[Position] := ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index));
      Inc(Position);
    end;
  HullSeriesCount := Position;
  SetLength(BlockIndices, HullSeriesCount);
  SetLength(SortKeys, HullSeriesCount);
  SetLength(HullSeriesDefinitions, HullSeriesCount);
  for Index := 0 to HullSeriesCount - 2 do
    for Position := HullSeriesCount - 1 downto Index + 1 do
      if SortKeys[Position - 1] > SortKeys[Position] then
      begin
        Temp := SortKeys[Position - 1];
        SortKeys[Position - 1] := SortKeys[Position];
        SortKeys[Position] := Temp;
        Temp := BlockIndices[Position - 1];
        BlockIndices[Position - 1] := BlockIndices[Position];
        BlockIndices[Position] := Temp;
      end;
  for Index := 0 to HullSeriesCount - 1 do
  begin
    Block := LanguageDataConfig.GetBlock('HullType');
    with HullSeriesDefinitions[Index] do
    begin
      SortKey := SortKeys[Index];
      SystemName := Block.GetBlockNameByIndex(BlockIndices[Index]);
      SystemNameCRC := InitCrc32;
      SystemNameCRC := UpdateCrc32(SystemNameCRC, PWideChar(SystemName), Length(SystemName) * 2);
      SystemNameCRC := FinishCrc32(SystemNameCRC);
      Block := Block.GetBlockByIndex(BlockIndices[Index]);
      Name := ReadHullSeriesParam('Name');
      Text := ReadHullSeriesParam('Text');
      Value := ReadHullSeriesParam('Race');
      AllowedOwners := [];
      if (Value = '') or (Value = 'Any') then AllowedOwners := [owner_maloc..owner_gaal]
      else
      begin
        if Pos('Maloc', Value) > 0 then Include(AllowedOwners, owner_maloc);
        if Pos('Peleng', Value) > 0 then Include(AllowedOwners, owner_peleng);
        if Pos('People', Value) > 0 then Include(AllowedOwners, owner_human);
        if Pos('Fei', Value) > 0 then Include(AllowedOwners, owner_feyan);
        if Pos('Gaal', Value) > 0 then Include(AllowedOwners, owner_gaal);
      end;
      Value := ReadHullSeriesParam('ShipType');
      AllowedShipTypes := [];
      if (Value = '') or (Value = 'Any') then AllowedShipTypes := [hull_ranger..hull_diplomat]
      else
      begin
        if Pos('Transport', Value) > 0 then Include(AllowedShipTypes, hull_transport);
        if Pos('Liner', Value) > 0 then Include(AllowedShipTypes, hull_liner);
        if Pos('Diplomat', Value) > 0 then Include(AllowedShipTypes, hull_diplomat);
        if Pos('Ranger', Value) > 0 then Include(AllowedShipTypes, hull_ranger);
        if Pos('Pirate', Value) > 0 then Include(AllowedShipTypes, hull_pirate);
        if Pos('Warrior', Value) > 0 then Include(AllowedShipTypes, hull_warrior);
        if Pos('Flagman', Value) > 0 then Include(AllowedShipTypes, hull_flagship);
      end;
      SlotBonuses[slot_fuel_tanks] := 0;
      SlotBonuses[slot_engine] := 0;
      SlotBonuses[slot_unsupported] := 0;
      Value := ReadHullSeriesParam('Radar');
      if Value = '' then SlotBonuses[slot_radar] := 0
      else SlotBonuses[slot_radar] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Scaner');
      if Value = '' then SlotBonuses[slot_scanner] := 0
      else SlotBonuses[slot_scanner] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Droid');
      if Value = '' then SlotBonuses[slot_repair_robot] := 0
      else SlotBonuses[slot_repair_robot] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Hook');
      if Value = '' then SlotBonuses[slot_cargo_hook] := 0
      else SlotBonuses[slot_cargo_hook] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Def');
      if Value = '' then SlotBonuses[slot_defense_generator] := 0
      else SlotBonuses[slot_defense_generator] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Weapon');
      if Value = '' then SlotBonuses[slot_weapon] := 0
      else SlotBonuses[slot_weapon] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Artefact');
      if Value = '' then SlotBonuses[slot_artefact] := 0
      else SlotBonuses[slot_artefact] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Forsage');
      if Value = '' then SlotBonuses[slot_afterburner] := 0
      else SlotBonuses[slot_afterburner] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Size');
      if Value = '' then SizePercent := 100
      else SizePercent := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Cost');
      if Value = '' then CostPercent := 100
      else CostPercent := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Fragility');
      if Value = '' then FragilityFactor := 1
      else FragilityFactor := StrToInt(AnsiString(Value)) * 0.01;
      for DamageKind := Low(TWeaponDamageClass) to High(TWeaponDamageClass) do
      begin
        Value := ReadHullSeriesParam('Fragility' + WeaponDamageClasses[DamageKind].Name);
        if Value = '' then FragilityByDamageClass[DamageKind] := FragilityFactor
      else FragilityByDamageClass[DamageKind] := StrToInt(AnsiString(Value)) * 0.01;
      end;
      Value := ReadHullSeriesParam('Year');
      if Value = '' then Year := 0
      else Year := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Probability');
      if Value = '' then ProbabilityWeight := 1
      else ProbabilityWeight := StrToInt(AnsiString(Value));
    end;
  end;
end;
{ @end $797B2C }

{ @routine $798758 IncrementWordSaturating }
procedure IncrementWordSaturating(var Value: Word);
begin
  if Value < High(Word) then Inc(Value);
end;
{ @end $798758 }

{ @routine $798764 PickRandomItemType }
function PickRandomItemType(Mask: TItemTypeSelection): Byte;
var
  ItemType: TItemType;
  Count: Integer;
begin
  Count := 0;
  for ItemType := Low(TItemType) to High(TItemType) do
    if ItemType in Mask then Inc(Count);
  Count := RandomIntRange(1, Count);
  for ItemType := Low(TItemType) to High(TItemType) do
    if ItemType in Mask then
    begin
      Dec(Count);
      if Count = 0 then Break;
    end;
  Result := Ord(ItemType);
end;
{ @end $798764 }

{ @routine $7987BC PickRandomItemTypeFromSeed }
function PickRandomItemTypeFromSeed(Mask: TItemTypeSelection; var Seed: Cardinal): Byte;
var
  ItemType: TItemType;
  Count: Integer;
begin
  Count := 0;
  for ItemType := Low(TItemType) to High(TItemType) do
    if ItemType in Mask then Inc(Count);
  Count := NextRandomIntRange(1, Count, Seed);
  for ItemType := Low(TItemType) to High(TItemType) do
    if ItemType in Mask then
    begin
      Dec(Count);
      if Count = 0 then Break;
    end;
  Result := Ord(ItemType);
end;
{ @end $7987BC }

{ @routine $798818 CountItemTypesInMask }
function CountItemTypesInMask(Mask: TItemTypeSelection): Integer;
var
  ItemType: TItemType;
  Count: Integer;
begin
  Count := 0;
  for ItemType := Low(TItemType) to High(TItemType) do
    if ItemType in Mask then Inc(Count);
  Result := Count;
end;
{ @end $798818 }

{ @routine $798848 GetItemTypeFromMask }
function GetItemTypeFromMask(Mask: TItemTypeSelection; Index: Integer): TItemType;
var
  ItemType: TItemType;
  Count: Integer;
begin
  Count := 0;
  Result := item_food;
  for ItemType := Low(TItemType) to High(TItemType) do
  begin
    if ItemType in Mask then Inc(Count);
    if Count = Index then
    begin
      Result := ItemType;
      Exit;
    end;
  end;
end;
{ @end $798848 }

{ @routine $798884 ClassifyWeaponDamageFlags }
function ClassifyWeaponDamageFlags(Flags: TDamageFlagSet): TWeaponDamageClass;
begin
  if damage_flag_missile in Flags then Result := damage_class_missile
  else if damage_flag_splinter in Flags then Result := damage_class_splinter
  else Result := damage_class_energy;
end;
{ @end $798884 }

end.
