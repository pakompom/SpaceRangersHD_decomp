unit aConst;
// Unit bracket (inferred): .text 0x007DA400..0x007E737A; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x00876A44..0x00876A44; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Windows, aGalaxyStruct;

type
  TOwnerWeaponAvailabilityTable = array[0..7] of TWeaponAvailability;
  POwnerWeaponAvailabilityTable = ^TOwnerWeaponAvailabilityTable;

  // Names and ordinals from the native bon* configuration/script table.
  TEquipmentBonusKind = (
    bonHull = 0,
    bonFuel = 1,
    bonSpeed = 2,
    bonJump = 3,
    bonRadar = 4,
    bonScan = 5,
    bonDroid = 6,
    bonHook = 7,
    bonDef = 8,
    bonWEnergy = 9,
    bonWSplinter = 10,
    bonWMissile = 11,
    bonWRadius = 12,
    bonSlotRadar = 13,
    bonSlotScaner = 14,
    bonSlotDroid = 15,
    bonSlotHook = 16,
    bonSlotDef = 17,
    bonSlotWeapon = 18,
    bonSlotArt = 19,
    bonSlotForsage = 20,
    bonHookRadius = 21,
    bonSkill1 = 22,
    bonSkill2 = 23,
    bonSkill3 = 24,
    bonSkill4 = 25,
    bonSkill5 = 26,
    bonSkill6 = 27,
    bonMass = 28,
    bonExtraAkrinEff = 29,
    bonExtraAkrinPenalty = 30,
    bonAmmo = 31,
    bonShots = 32,
    bonMissileSpeed = 33,
    bonShotSpeed = 34,
    bonHookMaxSpeed = 35,
    bonHookMinSpeed = 36,
    bonStimCapacity = 37,
    bonZonds = 38,
    bonAttacks = 39,
    bonResistAsteroid = 40,
    bonAIValue = 41,
    bonNull = 42
  ); // @size 0x1

  TEquipmentBonuses = array[0..42] of Integer;

  TEquipmentBonusNameTable = array[0..42] of WideString;

  PEquipmentBonusNameTable = ^TEquipmentBonusNameTable;

  TShipSlotKind = (
    sskFuelTanks = 0,
    sskEngine = 1,
    sskRadar = 2,
    sskScanner = 3,
    sskRepairRobot = 4,
    sskCargoHook = 5,
    sskDefGenerator = 6,
    sskWeapon = 7,
    sskArtefact = 8,
    sskAfterburner = 9,
    sskUnsupported = 10
  ); // @size 0x1

  TEquipmentSizeFactorTable = array[1..5] of Single;

  PEquipmentSizeFactorTable = ^TEquipmentSizeFactorTable;

  TEquipmentInventionIndexTable = array[42..49] of Byte;

  PEquipmentInventionIndexTable = ^TEquipmentInventionIndexTable;

  TStationEquipmentOfferQuota = packed record // @size 0x24
    Hulls: Integer; // @offset 0x00
    FuelTanks: Integer; // @offset 0x04
    Engines: Integer; // @offset 0x08
    Radars: Integer; // @offset 0x0C
    Scanners: Integer; // @offset 0x10
    RepairRobots: Integer; // @offset 0x14
    CargoHooks: Integer; // @offset 0x18
    DefGenerators: Integer; // @offset 0x1C
    Weapons: Integer; // @offset 0x20  Shared quota for item types 50..68.
  end;
  TStationEquipmentOfferQuotaTable = array[6..13] of TStationEquipmentOfferQuota;
  PStationEquipmentOfferQuotaTable = ^TStationEquipmentOfferQuotaTable;

  TWeaponRangeLevelFactors = array[1..8] of Single;
  // These helpers copy a byte-aligned set parameter. The separately compiled
  // aGalaxyStruct mask has the same bits but different DCU alignment.
  TItemTypeSelection = set of 0..79; // @size 10
  TScriptActionTypeNames = array[0..61] of WideString;
  TGoodsLegalityTable = array[0..7, 0..4, 0..4] of Boolean;

  TProgramNameTable = array[0..11] of WideString;
  TProgramDurationTable = array[0..11] of Integer;
  THullLevelStats = record // @size $10
    Armor: Byte; // @offset $00
    Fragility: array[0..2] of Single; // @offset $04 Energy, splinter, missile; loaded by $7E1FD0.
  end;
  THullLevelStatsTable = array[1..8] of THullLevelStats;

  TWeaponDamageClass = (wdcEnergy = 0, wdcSplinter = 1, wdcMissile = 2); // @size $01
  TTransportTypeNameTable = array[0..2] of WideString;
  THullShipTypeMask = set of 0..15; // @size $02 ht* hull-category bits, distinct from TShip.TypeId.

var
  // Native WideString defaults: initialization pairs $7E74E0..$7E7634.
  // Native WideString defaults: initialization pairs $7E7BB8..$7E7DA4.

procedure IncrementWordSaturating(var Value: Word); // @addr $7E6E70
function OwnerToSys(OwnerId: Byte): WideString; // @addr $7DD828 @ida "void __usercall $name(unsigned __int8 OwnerId@<al>, unsigned __int16 **Result@<edx>);"
function IsKnownOwnerName(const Name: WideString): Boolean; // @addr $7DDAA0
function MatchesOwnerName(OwnerId: Byte; const Name: WideString): Boolean; // @addr $7DDC88 Unrecognized names act as a wildcard.
function MatchesCareerName(Career: Byte; const Names: WideString): Boolean; // @addr $7DDD1C Case-sensitive substring, Any, or empty string.

procedure LoadArtefactConfiguration; // @addr $7DF314
procedure LoadDamageSkillQuestMarketConfiguration; // @addr $7E17F8
procedure LoadEquipmentConfiguration; // @addr $7E1FD0
procedure LoadWeaponConfiguration; // @addr $7E2B08
procedure LoadMicroModuleConfiguration; // @addr $7E39B0
procedure InitializeCaptainHealthDefinitions; // @addr $7E5054
procedure LoadHullSeriesConfiguration; // @addr $7E60F8

procedure InitializeGameplayConfig; // @addr 0x7DC5B0

function ItemTypeToSlotKind(ItemType: Byte): TShipSlotKind; // @addr 0x7DE6A4
function ClassifyWeaponDamageFlags(Flags: TDamageFlagSet): TWeaponDamageClass; // @addr $7E702C Missile bit takes precedence over splinter; otherwise energy.
function ShipToHullType(Ship: TObject): Byte; // @addr $7DE530 Class/subtype mapping used by hull generation and legacy saves; only TObject RTTI operations precede explicit subclass casts.
function RaceToOwner(RaceId: Byte): TOwnerIndex; // @addr 0x7DD184 @note "Identity conversion for Coalition races 0..4; raises for all other values."
function OwnerFromInternalName(const Name: WideString): Byte; // @addr $7DD974

function OwnerToRace(OwnerId: Byte): Byte; // @addr 0x7DD0F8 @note "Identity conversion for Coalition owners 0..4; raises for all other values."
function RaceToSys(RaceId: Byte): WideString; // @addr 0x7DD210 @ida "void __usercall $name(unsigned __int8 RaceId@<al>, unsigned __int16 **Result@<edx>);" @note "Raises outside Coalition races 0..4."
function NumberToRace(Value: Integer): Byte; // @addr 0x7DDBFC @note "Accepts 0..4; raises otherwise."
function SysToReward(const Name: WideString): Byte; // @addr 0x7DDD7C @note "Case-sensitive lookup; raises for an unknown name."
function SysToShipType(const Name: WideString): Byte; // @addr 0x7DDF24 @note "Case-sensitive lookup among 14 ship types; raises for an unknown name."
function OwnerToFilmColor(OwnerId: ShortInt): Cardinal; // @addr 0x7DD320 @note "Maps owner IDs 0..5 and 7 to fixed RGB colors through CurrentPixelFormat; other values use magenta."
function CustomFactionToFilmColor(Faction: WideString): Cardinal; // @addr $7DD430
function GetCustomFactionPlanetIconNumber(Faction: WideString): Integer; // @addr $7DD6BC @note "Race.PlanetIconNum lookup; returns -1 for an absent entry. Film owner codes offset a nonnegative result by eight."
function SizeTagToLevel(const Tag: WideString): Byte; // @addr $7DE43C @note "Zero, Mini, Small, Average, Big, Huge map to 0..5; unknown tags map to zero."
function GenerateValueForSizeLevel(Level: Byte; Minimum, Maximum: Integer; VariationPercent: Byte; Seed: Cardinal): Integer; // @addr $7DE294 @note "Seeded variation around a size bucket; unknown nonzero levels use the midpoint."
function GetAverageItemSize(ItemType: Byte): Integer; // @addr 0x7DDFA4
function PickRandomItemType(Mask: TItemTypeSelection): Byte; // @addr $7E6E8C @ida "unsigned __int8 __usercall $name@<al>(TItemTypeSelection *Mask@<eax>);"
function PickRandomItemTypeFromSeed(Mask: TItemTypeSelection; var Seed: Cardinal): Byte; // @addr $7E6F08 @ida "unsigned __int8 __usercall $name@<al>(TItemTypeSelection *Mask@<eax>, unsigned int *Seed@<edx>);" @note "Selects a set bit among 0..75 while advancing Seed; an empty mask returns 76."
function CountItemTypesInMask(Mask: TItemTypeSelection): Integer; // @addr 0x7E6F8C @ida "int __usercall $name@<eax>(TItemTypeSelection *Mask@<eax>);" @note "Copies the ten-byte mask, then counts bits 0..75; ignores storage bits 76..79."
function GetItemTypeFromMask(Mask: TItemTypeSelection; Index: Integer): Byte; // @addr 0x7E6FD4 @ida "unsigned __int8 __usercall $name@<al>(TItemTypeSelection *Mask@<eax>, int Index@<edx>);" @note "One-based selected-bit index among types 0..75; returns zero if no index matches."
function PickRandomEquipmentOwner(RandomValue: Dword): Byte; // @addr 0x7DDCF8 @note "Only Coalition manufacturers are eligible."

function LookupNamedColorTag(Name: WideString): WideString; // @addr $7DD580 @ida "void __usercall $name(unsigned __int16 *Name@<eax>, unsigned __int16 **Result@<edx>);"

// Repeated Path values are joined with CRLF; no separator precedes an empty accumulator.
// Missing paths return empty and may create intermediate blocks.
// Both lookups expand <br>, <ll> and <Player>; the player's name is highlighted.
// LocalizedText leaves <clr>/<clrEnd> intact; LocalizedColorText expands them.
function LocalizedText(const Path: WideString): WideString; // @addr 0x7DE730 @ida "void __usercall $name(unsigned __int16 *Path@<eax>, unsigned __int16 **Result@<edx>);"
function LocalizedColorText(const Path: WideString): WideString; // @addr 0x7DE980 @ida "void __usercall $name(unsigned __int16 *Path@<eax>, unsigned __int16 **Result@<edx>);" @note "Also expands <clr> and <clrEnd> to yellow opening and closing color tags."
procedure ExpandLocalizedTextMarkup(var Text: WideString); // @addr 0x7DEC3C @note "Expands <br>, <ll>, <Player>, <clr> and <clrEnd>; leaves <Player> intact when no player exists."
procedure ExpandLocalizedTextMarkupAndPrefixLines(var Text: WideString); // @addr 0x7DEE34 @note "Expands markup, trims outer whitespace, then applies LocalizedTextLinePrefix to the first line and after each CRLF."

// Collects at most ten nonempty variants: Path, then contiguous numeric suffixes
// starting at 1 (0 when the base lookup is empty). A missing suffix prevents reaching later ones.
function PickLocalizedTextVariant(const Path: WideString; SeedOffset: Integer): WideString; // @addr 0x7DF080 @ida "void __usercall $name(unsigned __int16 *Path@<eax>, int SeedOffset@<edx>, unsigned __int16 **Result@<ecx>);" @note "Selection uses (CurrentTurn + SeedOffset) div 10, except in chaotic mode. No variants produces an unavailable-text diagnostic."

var
  // Native managed-string initialization pairs at $7E7ED0, $7E7EC8, $7E7EC0.

function RelationValueToLevel(Value: Byte): TRelationLevel; // @addr $7DE648 Buckets 0..100; out-of-range values map to normal.

function GetFactionEmblemPath(Faction: WideString): WideString; // @addr $7DD794 @ida "void __usercall $name(unsigned __int16 *Faction@<eax>, unsigned __int16 **Result@<edx>);"

function FindMicroModuleTemplateByCustomTag(CustomTag: WideString): Integer; // @addr $7DF284 First matching template; -1 when absent.

var

// Managed declarations follow the verified native finalization order.
var
  IntegrityDataBegin: Cardinal = 0; // @addr $87C25C Four-byte zero boundary marker for the dormant native data checksum; original name unresolved.
var
  CurrentSaveVersion: Integer = 167; // @addr 0x87C260 @note "167 in this binary."
  MinimumLoadableSaveVersion: Integer = 44; // @addr 0x87C264 @note "44 in this binary; enforced by the save-manager load action."
  LocalizedTextLinePrefix: WideString = '    '; // @addr 0x87C268
type
  TEconomyInfo = packed record // @size 0x10
    InternalName: WideString; // @offset 0x00  SaveToBlock/LoadFromBlock economy token.
    DisplayName: WideString; // @offset 0x04
    ShortDisplayName: WideString; // @offset $08 Economy.ShortName localization.
    InventionProgressScale: Single; // @offset 0x0C
  end;

  TPlanetEconomyInfoTable = array[0..2] of TEconomyInfo;

  PPlanetEconomyInfoTable = ^TPlanetEconomyInfoTable;

  // Native record RTTI at $7D9640.
  TRelationTypeInfo = record // @size $0C
    InternalName: WideString; // @offset $00 Native initializer descriptors $7D9674..$7D96B0.
    DisplayName: WideString; // @offset $04 Used by live and recorded object-information panels.
    MinimumValue: Integer; // @offset $08 Native thresholds 0, 10, 30, 60, 80.
  end;

  TRelationInfoTable = array[0..4] of TRelationTypeInfo;

var
  GalaxyStarCount: Integer = 73; // @addr $87C26C Constellations.GalaxyCountStars config; SF_GalaxyPtr('StarCnt') exposes its address.
  GalaxySizeY: Integer = 100; // @addr $87C270 Constellations.GalaxySizeY config; also scales hyperspace route length.
  GalaxySizeX: Integer = 145; // @addr $87C274 Constellations.GalaxySizeX configuration.
const
  MaximumNewGameDifficulty: Byte = 9; // @addr $87C278
var
  GalaxyDifficultyTuning: TGalaxyDifficultyTuningTable = (
    (GoodsEventDurationFactor: 0.7;
      QuestTimeAndExperienceFactor: 0.85;
      EquipmentWearFactor: 0.75;
      InventionProgressScale: 1.1;
      ArcadeRewardScale: 1.3;
      QuestMoneyFactor: 1.2;
      DifficultyValue18: 4000;
      DifficultyValue1C: 8;
      MarketPriceBandSqueeze: -0.2;
      RandomHoleSpawnRollMaximum: 80;
      MaximumDominatorResearchRate: 0.05;
      MaximumResearchMaterialConsumption: 2;
      MaximumQuestProgramRewardCount: 4;
      ArcadeDamageTakenScale: 0.9;
      DifficultyFactor34: 10.0),
    (GoodsEventDurationFactor: 1.0;
      QuestTimeAndExperienceFactor: 1.0;
      EquipmentWearFactor: 1.0;
      InventionProgressScale: 1.0;
      ArcadeRewardScale: 1.0;
      QuestMoneyFactor: 1.0;
      DifficultyValue18: 1300;
      DifficultyValue1C: 12;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 100;
      MaximumDominatorResearchRate: 0.04;
      MaximumResearchMaterialConsumption: 4;
      MaximumQuestProgramRewardCount: 3;
      ArcadeDamageTakenScale: 1.0;
      DifficultyFactor34: 5.0),
    (GoodsEventDurationFactor: 1.2;
      QuestTimeAndExperienceFactor: 1.15;
      EquipmentWearFactor: 1.3;
      InventionProgressScale: 0.9;
      ArcadeRewardScale: 0.6;
      QuestMoneyFactor: 0.7;
      DifficultyValue18: 800;
      DifficultyValue1C: 16;
      MarketPriceBandSqueeze: 0.1;
      RandomHoleSpawnRollMaximum: 130;
      MaximumDominatorResearchRate: 0.03;
      MaximumResearchMaterialConsumption: 5;
      MaximumQuestProgramRewardCount: 2;
      ArcadeDamageTakenScale: 1.7;
      DifficultyFactor34: 2.5),
    (GoodsEventDurationFactor: 1.5;
      QuestTimeAndExperienceFactor: 1.3;
      EquipmentWearFactor: 1.6;
      InventionProgressScale: 0.8;
      ArcadeRewardScale: 0.3;
      QuestMoneyFactor: 0.5;
      DifficultyValue18: 400;
      DifficultyValue1C: 20;
      MarketPriceBandSqueeze: 0.15;
      RandomHoleSpawnRollMaximum: 170;
      MaximumDominatorResearchRate: 0.02;
      MaximumResearchMaterialConsumption: 6;
      MaximumQuestProgramRewardCount: 2;
      ArcadeDamageTakenScale: 2.3;
      DifficultyFactor34: 1.8),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      DifficultyValue18: 0;
      DifficultyValue1C: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      DifficultyFactor34: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      DifficultyValue18: 0;
      DifficultyValue1C: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      DifficultyFactor34: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      DifficultyValue18: 0;
      DifficultyValue1C: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      DifficultyFactor34: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      DifficultyValue18: 0;
      DifficultyValue1C: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      DifficultyFactor34: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      DifficultyValue18: 0;
      DifficultyValue1C: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      DifficultyFactor34: 0.0),
    (GoodsEventDurationFactor: 0.0;
      QuestTimeAndExperienceFactor: 0.0;
      EquipmentWearFactor: 0.0;
      InventionProgressScale: 0.0;
      ArcadeRewardScale: 0.0;
      QuestMoneyFactor: 0.0;
      DifficultyValue18: 0;
      DifficultyValue1C: 0;
      MarketPriceBandSqueeze: 0.0;
      RandomHoleSpawnRollMaximum: 0;
      MaximumDominatorResearchRate: 0.0;
      MaximumResearchMaterialConsumption: 0;
      MaximumQuestProgramRewardCount: 0;
      ArcadeDamageTakenScale: 0.0;
      DifficultyFactor34: 0.0)); // @addr $87C27C
  RelationInfo: array[0..4] of TRelationTypeInfo = (
    (InternalName: 'War'; DisplayName: ''; MinimumValue: 0),
    (InternalName: 'Bad'; DisplayName: ''; MinimumValue: 10),
    (InternalName: 'Normal'; DisplayName: ''; MinimumValue: 30),
    (InternalName: 'Good'; DisplayName: ''; MinimumValue: 60),
    (InternalName: 'Best'; DisplayName: ''; MinimumValue: 80)); // @addr $87C4AC
  PlanetEconomyInfo: array[0..2] of TEconomyInfo = (
    (InternalName: 'Agriculture'; DisplayName: ''; ShortDisplayName: ''; InventionProgressScale: 0.7),
    (InternalName: 'Mixed'; DisplayName: ''; ShortDisplayName: ''; InventionProgressScale: 1.0),
    (InternalName: 'Industrial'; DisplayName: ''; ShortDisplayName: ''; InventionProgressScale: 1.4)); // @addr $87C4E8
type
  TShipTypeInfo = record // @size $04 Native managed-record RTTI at $7D9708.
    Name: WideString; // @offset $00
  end;

  TShipTypeNameTable = array[0..13] of TShipTypeInfo;

  PShipTypeNameTable = ^TShipTypeNameTable;

var
  ShipTypeNames: array[0..13] of TShipTypeInfo = ((Name: 'Kling'), (Name: 'Ranger'), (Name: 'Transport'), (Name: 'Pirate'), (Name: 'Warrior'), (Name: 'Tranclucator'), (Name: 'RC'), (Name: 'PB'), (Name: 'WB'), (Name: 'SB'), (Name: 'BK'), (Name: 'MC'), (Name: 'CB'), (Name: 'UB')); // @addr $87C518
type
  // Native record RTTI at $7D980C.
  TStatusInfo = record // @size $28
    Name: WideString; // @offset $00 Native career identifier.
    MinimumWealthToAverageRatio: Double; // @offset $08 NeedsWealthCatchup ($753618): Wealth / AverageRangerCapital threshold.
    MinimumWealthToBestRatio: Double; // @offset $10 Wealth / MaxRangerWealth threshold in the same catch-up test.
    MinimumStrengthToAverageRatio: Double; // @offset $18 NeedsStrengthCatchup ($7535A8): Strength / AverageRangerStrength threshold.
    MinimumStrengthToBestRatio: Double; // @offset $20 Strength / BestRangerStrength threshold in the same catch-up test.
  end;

  TCareerTuningTable = array[0..2] of TStatusInfo;

var
  StationDefaultStandings: array[6..13] of Byte = (ssCoalitionMilitary, ssPiratePassive, ssCoalitionMilitary, ssCoalitionActive, ssCoalitionActive, ssNeutral, ssPirateMilitary, ssUnaligned); // @addr $87C550 Standing used to gate station spawning by faction, including the custom station.
  NonTargetableStationStandingMasks: TFactionStandingMasks = ($003C, $0001, $01C0); // @addr $87C558 Standing masks used by TPlayer.CanSelectShipTarget.
  FactionStandingMasks: TFactionStandingMasks = ($007C, $0001, $01F0); // @addr $87C560
  CareerTuning: array[0..2] of TStatusInfo = (
    (Name: 'Trader'; MinimumWealthToAverageRatio: 1.5; MinimumWealthToBestRatio: 0.4; MinimumStrengthToAverageRatio: 0.9; MinimumStrengthToBestRatio: 0.3),
    (Name: 'Pirate'; MinimumWealthToAverageRatio: 0.9; MinimumWealthToBestRatio: 0.35; MinimumStrengthToAverageRatio: 1.1; MinimumStrengthToBestRatio: 0.5),
    (Name: 'Warrior'; MinimumWealthToAverageRatio: 0.8; MinimumWealthToBestRatio: 0.25; MinimumStrengthToAverageRatio: 1.2; MinimumStrengthToBestRatio: 0.6)
  ); // @addr $87C568 Names from native initialization pairs $7E7ED8..$7E7EE8.
  TransportTypeNames: array[0..2] of WideString = ('Transport', 'Liner', 'Diplomat'); // @addr $87C5E0

type
  // Native record RTTI at $7D98C0.
  TKlingTypeInfo = record // @size $38
    DisplayNames: array[0..2] of WideString; // @offset $00 Indexed by TDominatorSeries; replaced by localized names during configuration loading.
    MinimumHullSize: Integer; // @offset $0C InitGenerated ($5C7444): random hull-size bounds before HullCapacityScale.
    MaximumHullSize: Integer; // @offset $10 Also averaged by SelectChameleonVisualType ($7015A4).
    InitialWealthScale: Double; // @offset $18 InitializeDominator ($5C6E94): scales Galaxy.MaxRangerWealth.
    BaseNodeReserve: Word; // @offset $20 Base reserve before randomized initialization and applicable difficulty modifiers.
    KillExperience: Word; // @offset $22
    RankPoints: Word; // @offset $24
    PirateRankPoints: Word; // @offset $26
    RankImageIndex: Integer; // @offset $28 Rank graphic selected by scanner and ship screens.
    FactionStrengthWeight: Double; // @offset $30 Multiplies Dominator strength in TStar.GetCachedFactionStrength ($861954).
  end;
  TDominatorShipDefinitions = array[0..7] of TKlingTypeInfo;

const
  DominatorDisplayOrder: array[0..7] of TKlingType = (ktBoss, ktBertor, ktEquentor, ktUrgant, ktSmersh, ktMenok, ktShtip, ktKlig); // @addr $87C5EC
var
  DominatorShipTypeNames: array[0..7] of WideString = ('K0', 'K1', 'K2', 'K3', 'K4', 'K5', 'K6', 'K7'); // @addr $87C5F4
  DominatorShipDefinitions: array[0..7] of TKlingTypeInfo = (
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 0; MaximumHullSize: 0; InitialWealthScale: 10; BaseNodeReserve: 500; KillExperience: 5000; RankPoints: 250; PirateRankPoints: 0; RankImageIndex: 7; FactionStrengthWeight: 10),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 900; MaximumHullSize: 1400; InitialWealthScale: 0.7; BaseNodeReserve: 100; KillExperience: 1000; RankPoints: 48; PirateRankPoints: 16; RankImageIndex: 5; FactionStrengthWeight: 5),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 700; MaximumHullSize: 900; InitialWealthScale: 0.6; BaseNodeReserve: 50; KillExperience: 500; RankPoints: 24; PirateRankPoints: 8; RankImageIndex: 4; FactionStrengthWeight: 3.5),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 500; MaximumHullSize: 700; InitialWealthScale: 0.5; BaseNodeReserve: 30; KillExperience: 300; RankPoints: 12; PirateRankPoints: 4; RankImageIndex: 3; FactionStrengthWeight: 2),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 350; MaximumHullSize: 500; InitialWealthScale: 0.3; BaseNodeReserve: 15; KillExperience: 150; RankPoints: 6; PirateRankPoints: 2; RankImageIndex: 2; FactionStrengthWeight: 1),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 250; MaximumHullSize: 350; InitialWealthScale: 0.2; BaseNodeReserve: 10; KillExperience: 100; RankPoints: 3; PirateRankPoints: 1; RankImageIndex: 1; FactionStrengthWeight: 1),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 1250; MaximumHullSize: 2000; InitialWealthScale: 2; BaseNodeReserve: 200; KillExperience: 2000; RankPoints: 60; PirateRankPoints: 24; RankImageIndex: 7; FactionStrengthWeight: 7.5),
    (DisplayNames: ('Blazer', 'Keller', 'Terron'); MinimumHullSize: 150; MaximumHullSize: 250; InitialWealthScale: 0.15; BaseNodeReserve: 5; KillExperience: 50; RankPoints: 1; PirateRankPoints: 1; RankImageIndex: 1; FactionStrengthWeight: 0)
  ); // @addr $87C614 TKlingType order; native name initializer pairs $7E7DC0..$7E7E78.
var
  DominatorRetreatStrengthByTier: array[0..3] of Double = (2, 2.2, 2.6, 3); // @addr $87C7D4 Minimum reinforced-system strength by constellation distance tier.
  DominatorSeriesNames: array[0..2] of WideString = ('Blazer', 'Keller', 'Terron'); // @addr $87C7F4
var
  DominatorResearchRateMultipliers: array[0..2] of Double = (1.0, 1.2, 0.8); // @addr $87C800 Native Blazer, Keller, Terron research multipliers.
  ResearchProgramCostFactors: array[0..2] of Double = (1, 1.4, 1.8); // @addr $87C818
const
  // Ordinals of the native ScriptActionTypeNames table at $87C830.
  // These ordinary constants preserve the byte API and existing set layout.
  satOnStep = 0;
  satOnWeaponShot = 1;
  satOnMissileShot = 2;
  satOnDealingDamage = 3;
  satOnDealingFatalDamage = 4;
  satOnDealingKamikazeDamage = 5;
  satOnTakingDamage = 6;
  satOnTakingDamageEn = 7;
  satOnTakingDamageSp = 8;
  satOnTakingDamageMi = 9;
  satOnWeaponShot2 = 10;
  satOnMissileShot2 = 11;
  satOnGettingWeaponHit = 12;
  satOnGettingMissileHit = 13;
  satOnDroidRepair = 14;
  satOnItemPickUp = 15;
  satOnScan = 16;
  satOnChameleonConfusion = 17;
  satOnScanPossibility = 18;
  satOnAnotherItem = 19;
  satOnAnotherItem2 = 20;
  satOnAnotherGoods = 21;
  satOnItemHit = 22;
  satOnMissileHittingObject = 23;
  satOnEnteringForm = 24;
  satOnLeavingForm = 25;
  satOnReEnteringForm = 26;
  satOnEnteringOtherShip = 27;
  satOnLeavingOtherShip = 28;
  satOnReEnteringOtherShip = 29;
  satOnPlayerSkillIncrease = 30;
  satOnPlayerTalkedWithShip = 31;
  satOnShipTalkedWithPlayer = 32;
  satOnDropItem = 33;
  satOnDropItemFixed = 34;
  satOnMovingItemToStorage = 35;
  satOnReduceEqBattle = 36;
  satOnReduceEqUse = 37;
  satOnReduceEqForce = 38;
  satOnReduceEqForsage = 39;
  satOnItemDestroy = 40;
  satOnPlayerChangeHull = 41;
  satOnPlayerUseMM = 42;
  satOnPlayerBuyEq = 43;
  satOnItemEquip = 44;
  satOnItemDeEquip = 45;
  satOnTrancPacking = 46;
  satOnShipBuysGoods = 47;
  satOnShipSellsGoods = 48;
  satOnShowingItemInfo = 49;
  satOnShowingShipInfo = 50;
  satOnShowingStarInfo = 51;
  satOnNonStandartEqChange = 52;
  satOnCustomTargetting = 53;
  satOnCustomTargettingCheck = 54;
  satOnStartAB = 55;
  satOnABItemDrop = 56;
  satOnGovItemReward = 57;
  satOnCheckingUsability = 58;
  satOnCheckingUsability2 = 59;
  satOnCheckingUsabilityGoods = 60;
  satOnDeath = 61;
var
  ScriptActionTypeNames: array[0..61] of WideString = (
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
    't_OnCheckingUsabilityGoods', 't_OnDeath'); // @addr $87C830
type
  // Native enum RTTI at $7DA3FC names aConst and all 76 members.
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

  // Native record RTTI at $7DA810.
  SEquipment = record // @size $8
    ItemType: TItemType; // @offset $0
    Name: WideString; // @offset $4
  end;

  TEquipmentSlotLayouts = array[0..7] of SEquipment;

var
  NonNegotiatingShipTypes: TShipTypeMask = [stKling, stTranclucator..Ord(rstCustomStation)]; // @addr $87C928  Excluded from ransom offers and ordinary ally requests.
const
  EquipmentSlotLayouts: array[0..7] of SEquipment = (
    (ItemType: t_FuelTanks; Name: 'FuelTanks'),
    (ItemType: t_Engine; Name: 'Engine'),
    (ItemType: t_Radar; Name: 'Radar'),
    (ItemType: t_Scaner; Name: 'Scaner'),
    (ItemType: t_RepairRobot; Name: 'RepairRobot'),
    (ItemType: t_CargoHook; Name: 'CargoHook'),
    (ItemType: t_DefGenerator; Name: 'DefGenerator'),
    (ItemType: t_Weapon1; Name: 'Weapon')); // @addr $87C92C Name initialization descriptors at $7E7B78..$7E7BB4; used by both the ship inventory and scanner.
var
  ItemTypeNames: array[0..75] of WideString = (
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
    'Cistern', 'Satellite', 'TreasureMap', 'UselessCountableItem'); // @addr 0x87C96C
  ArtefactLootPools: array[0..3] of array of TItemType; // @addr 0x889D30
  CustomArtefactLootPools: array[0..3] of array of WideString; // @addr 0x889D40
  UselessItemLootPools: array[0..3] of array of WideString; // @addr 0x889D50
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
    EconomyFactors: array[0..2] of Single; // @offset 0x20  Agricultural, mixed, industrial.
    PirateEconomyFactor: Single; // @offset 0x2C
  end;

  TGoodsInfoTable = array[0..7] of TGoodsInfo;

  PGoodsInfoTable = ^TGoodsInfoTable;

var
  GoodsMarket: array[0..7] of TGoodsInfo = (
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
      PirateEconomyFactor: 2.0)); // @addr $87CA9C
var
  GoodsTextOrder: TGoodsTextOrder = (0, 1, 5, 4, 3, 2, 6, 7); // @addr $87CC1C
  MissionTypeNames: array[0..4] of WideString = ('SendLetter', 'KillShip', 'PlanetQuest', 'DefSystem', 'DefShip'); // @addr $87CC24
type
  TOwnerInfo = packed record // @size 0x20
    InternalName: WideString; // @offset 0x00
    DisplayName: WideString; // @offset 0x04
    FuelPriceFactor: Single; // @offset 0x08
    EquipmentDurabilityFactor: Single; // @offset 0x0C  Reciprocal scales equipment wear and nano-artefact condition repair.
    MinimumAfterburnerWear: Integer; // @offset 0x10
    MaximumAfterburnerWear: Integer; // @offset 0x14
    FearThresholdScale: Single; // @offset $18 Scales hull/win-ratio fear and ransom thresholds ($5B8EA0/$5B900C); also transport enemy selection ($5C2D40).
    ColorTag: WideString; // @offset 0x1C
  end;

  TOwnerInfoTable = array[0..7] of TOwnerInfo;

  POwnerInfoTable = ^TOwnerInfoTable;

  TGovermentInfo = record // @size 0xA0
    InternalName: WideString; // @offset 0x00
    DisplayName: WideString; // @offset 0x04
    RevolutionRelationDelta: array[0..2] of ShortInt; // @offset 0x08  TRangerCareer order.
    QuestOfferProbabilities: array[0..4] of Single; // @offset 0x0C  TQuestType order.
    GoodsFactors: array[0..7] of TPlanetGoodsFactors; // @offset 0x20
  end;

  TPlanetGovernmentMarketTable = array[0..4] of TGovermentInfo;

  PPlanetGovernmentMarketTable = ^TPlanetGovernmentMarketTable;

var
  OwnerInfo: array[0..7] of TOwnerInfo = (
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
      ColorTag: '<color=255,255,255>')); // @addr $87CC38
var
  PlanetOwnerMasks: TPlanetOwnerMasks = (Coalition: $1F; Dominators: $20; PirateClan: $80); // @addr $87CD38
  OwnerRelations: TOwnerRelationTable = (
    (100, 80, 70, 40, 60, 0, 0, 30),
    (70, 100, 70, 30, 40, 0, 0, 30),
    (50, 40, 100, 70, 90, 0, 0, 30),
    (40, 30, 80, 100, 70, 0, 0, 30),
    (70, 70, 80, 90, 100, 0, 0, 30),
    (0, 0, 0, 0, 0, 100, 0, 0),
    (0, 0, 0, 0, 0, 0, 100, 0),
    (50, 50, 50, 50, 50, 0, 0, 100)); // @addr $87CD3C
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
      PirateRelationCeiling: 35)); // @addr $87CD7C
  PlanetEquipmentOfferQuotas: TPlanetEquipmentOfferQuotaTable = (
    (3, 2, 2, 2, 1, 2, 2, 2, 6),
    (4, 2, 2, 2, 1, 2, 2, 2, 5),
    (4, 2, 2, 2, 2, 1, 2, 2, 5),
    (3, 2, 2, 1, 1, 2, 2, 1, 4),
    (3, 2, 2, 2, 2, 1, 2, 2, 4)); // @addr $87D0C4
  StationEquipmentOfferQuotas: TStationEquipmentOfferQuotaTable = (
    (Hulls: 4; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4),
    (Hulls: 3; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 3; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4),
    (Hulls: 4; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 6),
    (Hulls: 3; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 2),
    (Hulls: 5; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 2),
    (Hulls: 2; FuelTanks: 1; Engines: 2; Radars: 1; Scanners: 2; RepairRobots: 1; CargoHooks: 2; DefGenerators: 2; Weapons: 1),
    (Hulls: 3; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 3; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4),
    (Hulls: 4; FuelTanks: 2; Engines: 2; Radars: 2; Scanners: 2; RepairRobots: 2; CargoHooks: 2; DefGenerators: 2; Weapons: 4)
  ); // @addr $87D178 Native defaults; aRuins accesses this table through an external-unit reference. Original defining unit is inferred.
  StationGoodsFactors: array[6..13, 0..7] of TPlanetGoodsFactors = (
    ((PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.15), (PriceFactor: 0.8; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.5; StockFactor: 0.01)),
    ((PriceFactor: 0.9; StockFactor: 0.15), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.2), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.15), (PriceFactor: 0.9; StockFactor: 0.2), (PriceFactor: 0.9; StockFactor: 0.3), (PriceFactor: 0.9; StockFactor: 0.2)),
    ((PriceFactor: 1.1; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.4; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.5; StockFactor: 0.01)),
    ((PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.8; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 1.1; StockFactor: 0.05), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.5; StockFactor: 0.01)),
    ((PriceFactor: 0.9; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.9; StockFactor: 0.3), (PriceFactor: 1.1; StockFactor: 0.1), (PriceFactor: 0.8; StockFactor: 0.1), (PriceFactor: 0.9; StockFactor: 0.1), (PriceFactor: 1.0; StockFactor: 0.2), (PriceFactor: 1.1; StockFactor: 0.1)),
    ((PriceFactor: 0.8; StockFactor: 0.2), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 1.0; StockFactor: 0.2), (PriceFactor: 1.0; StockFactor: 0.05), (PriceFactor: 0.8; StockFactor: 0.05), (PriceFactor: 0.9; StockFactor: 0.15), (PriceFactor: 0.9; StockFactor: 0.1), (PriceFactor: 0.7; StockFactor: 0.2)),
    ((PriceFactor: 1.1; StockFactor: 0.05), (PriceFactor: 1.1; StockFactor: 0.05), (PriceFactor: 0.9; StockFactor: 0.25), (PriceFactor: 1.0; StockFactor: 0.1), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.9; StockFactor: 0.3), (PriceFactor: 0.8; StockFactor: 0.3), (PriceFactor: 0.8; StockFactor: 0.25)),
    ((PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01), (PriceFactor: 1.0; StockFactor: 0.01))); // @addr $87D298
  PlanetGovernmentMarket: array[0..4] of TGovermentInfo = (
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
        (PriceFactor: 1.1; StockFactor: 0.6)))); // @addr $87D698
type
  // Native record RTTI at $7DB428.
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
    ((True, False, False, False, False), (True, True, True, True, True), (True, False, True, False, False), (True, True, False, False, False), (True, False, False, False, False))); // @addr $87D9B8 Indexed by goods, native race and government; False marks prohibited goods.
  MedalNames: array[0..5] of WideString = ('ForLiberationSystem', 'ForAccomplishment', 'ForSecretMission', 'ForCowardice', 'ForPerfidy', 'ForPlanetBattle'); // @addr $87DA80
  CoalitionRankNames: array[0..7] of WideString = ('Rookie', 'Cadet', 'Pilot', 'Wingman', 'Leader', 'Ace', 'Commander', 'Admiral'); // @addr $87DA98 Native initialization table.
var
  CoalitionRankPointThresholds: array[0..7] of Word = (100, 250, 450, 700, 1000, 1500, 2000, 0); // @addr $87DAB8 Zero threshold at the maximum rank.
  PirateRankNames: array[0..7] of WideString = ('Noobie', 'Kid', 'Rader', 'Skipper', 'Rough', 'Ataman', 'Khan', 'Baron'); // @addr $87DAC8 Native initialization descriptors at $7E7758..$7E7794.
var
  PirateRankPointThresholds: array[0..7] of Word = (100, 250, 450, 700, 1000, 1500, 3000, 0); // @addr $87DAE8 Zero threshold at the maximum rank.
  SkillConfigNames: array[0..5] of WideString = ('sAccuracy', 'sMobility', 'sTechnical', 'sTrader', 'sCharm', 'sLeadership'); // @addr $87DAF8
var
  RaceSkillEvaluationFactors: array[0..4, 0..5] of Single = (
    (1.2, 1.1, 0.9, 0.8, 1.0, 1.0),
    (1.0, 1.2, 0.8, 1.1, 1.0, 0.9),
    (0.9, 0.8, 1.0, 1.2, 1.0, 1.1),
    (1.1, 1.0, 1.2, 0.8, 0.9, 1.0),
    (0.8, 0.9, 1.1, 1.0, 1.2, 1.0)); // @addr $87DB10 Native race, then TPilotSkill; used by ranger bonus evaluation and character setup.
  PilotSkillEffects: array[0..6, 0..5] of Word = (
    (0, 0, 0, 30, 0, 0), (17, 17, 8, 38, 17, 1),
    (33, 33, 17, 47, 33, 2), (50, 50, 25, 55, 50, 3),
    (67, 67, 33, 63, 67, 4), (83, 83, 42, 72, 83, 5),
    (100, 100, 50, 80, 100, 6)); // @addr $87DB88 Level, then TPilotSkill; Trading supplies the item resale percentage.
  TechnicalSkillSatelliteLimits: array[0..6] of Word = (2, 3, 4, 5, 6, 7, 8); // @addr $87DBDC
  TradingSkillSalePercent: array[0..6] of Word = (0, 8, 16, 25, 33, 41, 50); // @addr $87DBEC Fraction of the purchase/sale spread recovered by the Trading skill.
  LeadershipExperiencePercent: array[0..6] of Word = (0, 5, 10, 15, 20, 25, 30); // @addr $87DBFC
  MaxPlanetNews: Integer = 9; // @addr $87DC0C Loaded from GalaxyNews.MaxCntPlanetNews; caps visible-system economic events.
  SizeTagNames: array[0..5] of WideString = ('Zero', 'Mini', 'Small', 'Average', 'Big', 'Huge'); // @addr $87DC10
type
  // Native record RTTI at $7DB73C.
  TPrimaryDamageTypeInfo = record // @size $08
    Kind: TWeaponDamageClass; // @offset $00
    BonusKind: Byte; // @offset $01
    Name: WideString; // @offset $04
  end;

  TWeaponDamageClassTable = array[0..2] of TPrimaryDamageTypeInfo;

var
  WealthDemandScales: array[0..5] of Single = (0.0, 0.01, 0.0125, 0.016666667, 0.02, 0.025); // @addr $87DC28 Fractions of cached ship wealth used for negotiated amounts.
  MinimumHullSlotCounts: array[0..10] of Integer = (1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0); // @addr $87DC40 Includes the unsupported-slot sentinel.
  DefaultHullSlotCounts: array[0..10] of Integer = (1, 1, 1, 1, 1, 1, 1, 5, 4, 1, 0); // @addr $87DC6C Artefact limit can be overridden by gameplay configuration.
  RangerHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 4, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 3, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $87DC98 Native base slot counts; final column is unsupported kind.
  WarriorHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 1, 0, 0, 1, 5, 1, 0, 0),
    (1, 1, 1, 1, 0, 1, 1, 4, 0, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 4, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 4, 0, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $87DDF8 Native base slot counts; final column is unsupported kind.
  PirateHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 1, 0, 1, 1, 4, 2, 1, 0),
    (1, 1, 1, 1, 1, 1, 0, 5, 3, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 0),
    (1, 1, 1, 1, 1, 1, 0, 3, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $87DF58 Native base slot counts; final column is unsupported kind.
  TransportHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 0, 0, 1, 0, 3, 0, 0, 0),
    (1, 1, 1, 0, 1, 1, 1, 2, 1, 0, 0),
    (1, 1, 1, 0, 1, 1, 0, 2, 0, 0, 0),
    (1, 1, 1, 0, 1, 1, 1, 2, 0, 0, 0),
    (1, 1, 1, 0, 1, 1, 1, 2, 0, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $87E0B8 Native base slot counts; final column is unsupported kind.
  LinerHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 0, 1, 0, 1, 4, 0, 0, 0),
    (1, 1, 1, 0, 1, 0, 1, 4, 0, 0, 0),
    (1, 1, 1, 0, 1, 0, 0, 4, 0, 0, 0),
    (1, 1, 1, 1, 1, 0, 0, 3, 2, 0, 0),
    (1, 1, 1, 1, 0, 0, 0, 3, 2, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $87E218 Native base slot counts; final column is unsupported kind.
  DiplomatHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 4, 1, 0, 0),
    (1, 1, 1, 1, 1, 1, 0, 3, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 2, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 3, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 1, 2, 3, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0),
    (1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0)); // @addr $87E378 Native base slot counts; final column is unsupported kind.
  TranclucatorHullSlots: array[0..10] of Integer = (1, 1, 0, 0, 1, 1, 1, 5, 4, 0, 0); // @addr $87E4D8 Native base slot counts; final column is unsupported kind.
  StationHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0)); // @addr $87E504 Native base slot counts; final column is unsupported kind.
  DominatorHullSlots: array[0..7, 0..10] of Integer = (
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0),
    (1, 1, 1, 1, 1, 1, 1, 5, 4, 1, 0)); // @addr $87E664 Native base slot counts; final column is unsupported kind.
  HullType9Slots: array[0..10] of Integer = (1, 1, 1, 1, 1, 1, 1, 5, 4, 1, 0); // @addr $87E7C4 Native base slot counts; final column is unsupported kind.
  HullType10Slots: array[0..10] of Integer = (1, 1, 1, 1, 1, 1, 1, 5, 4, 0, 0); // @addr $87E7F0 Native base slot counts; final column is unsupported kind.
  HullSlotBonusKinds: array[0..10] of TEquipmentBonusKind = (bonNull, bonNull, bonSlotRadar, bonSlotScaner, bonSlotDroid, bonSlotHook, bonSlotDef, bonSlotWeapon, bonSlotArt, bonSlotForsage, bonNull); // @addr $87E81C
  OwnerWeaponAvailability: TOwnerWeaponAvailabilityTable = (waMalocOnly, waPelengOnly, waPeopleOnly, waFeiOnly, waGaalOnly, waNotSoldAndNodeRepair, waNotSold, waPirateOnly); // @addr $87E828
  WeaponDamageFlagNames: array[0..20] of WideString = (
    'Energy', 'Splinter', 'Missile', 'Decelerate', 'Destruct', 'Drain', 'Shock',
    'Acid', 'Magnetic', 'DecelerateA', 'DecelerateAEx', 'Undefendable', 'NonLethal',
    'ScanBonus', 'BonusToDamaged', 'MoreDrop', 'DropCargo', 'ReduceEngine',
    'BlockWeapon', 'BlockDroid', 'NoDelta'); // @addr $87E830 Native managed-string descriptors.
  WeaponDamageClasses: array[0..2] of TPrimaryDamageTypeInfo = (
    (Kind: wdcEnergy; BonusKind: Ord(bonWEnergy); Name: 'Energy'),
    (Kind: wdcSplinter; BonusKind: Ord(bonWSplinter); Name: 'Splinter'),
    (Kind: wdcMissile; BonusKind: Ord(bonWMissile); Name: 'Missile')
  ); // @addr $87E884 Native scalar values and WideString initializer descriptors.
type
  // Native record RTTI at $7DB9B0.
  THullTypeInfo = record // @size $64
    Name: WideString; // @offset $00
    Text: WideString; // @offset $04
    AllowedOwners: TOwnerMask; // @offset $08
    AllowedShipTypes: THullShipTypeMask; // @offset $09
    SlotBonuses: array[0..10] of Integer; // @offset $0C Includes the unsupported slot sentinel.
    SizePercent: Integer; // @offset $38 Hull capacity multiplier divided by 100.
    CostPercent: Integer; // @offset $3C Hull price multiplier divided by 100.
    FragilityFactor: Single; // @offset $40 Configured percentage divided by 100.
    FragilityByDamageClass: array[0..2] of Single; // @offset $44 Defaults to FragilityFactor for omitted damage classes.
    Year: Byte; // @offset $50 HullType.Year.
    ProbabilityWeight: Integer; // @offset $54 HullType.Probability, defaults to one.
    SortKey: Integer; // @offset $58 Numeric suffix of the config block name.
    SystemName: WideString; // @offset $5C
    SystemNameCRC: Cardinal; // @offset $60 CRC32 of the UTF-16 config block name.
  end;

  THullSeriesDefinitions = array of THullTypeInfo;

  // Native record RTTI at $7DB9E4.
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
    FragilityFactorByDamageClass: array[0..2] of Single; // @offset 0xCC Energy, splinter and missile wear factors.
    Priority: Byte; // @offset 0xD8
    AllowedHullOwnerMask: Byte; // @offset 0xD9  OwnerId bits; bit 7 also accepts PirateBuilt hulls (IsBonusCompatibleWithHull, $74C430).
    AllowedCustomHullFactions: WideString; // @offset 0xDC
    CustomFaction: WideString; // @offset 0xE0
    AllowedDominatorSeriesMask: Byte; // @offset 0xE4
    AllowedItemTypes: array[0..9] of Byte; // @offset 0xE5  Bitset indexed by item type, covering 0..79.
    AllowedCustomWeaponTypes: WideString; // @offset 0xF0
    OfferStationTypes: Word; // @offset 0xF4  Bitset indexed by station ship type.
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
    WeaponDamageFlags: Dword; // @offset 0x120
  end;

  PMicroModuleTemplate = ^TMicroModuleInfo;

  TMicroModuleTemplates = array of TMicroModuleInfo;

  PMicroModuleTemplates = ^TMicroModuleTemplates;

  TMicroModuleCandidateIndices = array of Integer;

  PMicroModuleCandidateIndices = ^TMicroModuleCandidateIndices;

var
  CombatStatusHullFactors: array[0..6] of Single = (1, 1, 1, 0.3, 0.3, 0, 0); // @addr $87E89C Indexed by TCombatStatusEffectType.
  CombatStatusAccumulationFactors: array[0..6] of Single = (0, 0, 0.1, 0, 0, 0.025, 0); // @addr $87E8B8
  EquipmentBonusNames: array[0..42] of WideString = (
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
    'bonNull'); // @addr $87E8D4
type
  tInventionInfo = record // @size 0x08
    Name: WideString; // @offset $00 Native initialization names the research levels.
    InitialLevel: Byte; // @offset 0x04
    RequiredMainTechLevel: Byte; // @offset 0x05  Compared with InventionLevels[7], not ResearchLevelPercent.
  end;

  TPlanetInventionInfoTable = array[0..19] of tInventionInfo;

  PPlanetInventionInfoTable = ^TPlanetInventionInfoTable;

var
  EquipmentBonusSkills: array[0..5] of Byte = (0, 1, 2, 3, 4, 5); // @addr $87E980 Maps bonSkill1..bonSkill6 to native pilot skills.
  EquipmentSizeFactors: TEquipmentSizeFactorTable = (2.0, 1.5, 1.0, 0.7, 0.5); // @addr $87E988
  WeaponRangeLevelFactors: TWeaponRangeLevelFactors = (0.9, 0.95, 0.95, 1.0, 1.0, 1.05, 1.05, 1.1); // @addr $87E99C Native technology multiplier, immediately after EquipmentSizeFactors.
  PlanetInventionInfo: array[0..19] of tInventionInfo = (
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
    (Name: 'Weapon12 level'; InitialLevel: 1; RequiredMainTechLevel: 8)); // @addr $87E9BC
type
  TWeaponInfo = packed record // @size 0x78
    ItemType: TItemType; // @offset 0x00
    ConfigName: WideString; // @offset 0x04  Custom weapon configuration key.
    TechLevel: Byte; // @offset 0x08
    InventionIndex: Byte; // @offset 0x09  Planetary invention used to determine the available weapon level.
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

  TWeaponInfoTable = array[50..67] of TWeaponInfo;

  PWeaponInfoTable = ^TWeaponInfoTable;

var
  GoodsInflationMin: Single; // @addr $889D60
  GoodsInflationMax: Single; // @addr $889D64
  GoodsStockMin: Single; // @addr $889D68
  GoodsStockMax: Single; // @addr $889D6C
  GoodsInflationStartTurn: Integer; // @addr $889D70
  GoodsInflationEndTurn: Integer; // @addr $889D74
  QuestTuning: TQuestTuningTable; // @addr $889D78
  SkillTrainingCosts: array[0..6, 0..5] of Word; // @addr $889DB4 Levels 1..6 loaded from configuration; level zero is cleared.
  TotalSkillTrainingCost: Integer; // @addr $889E08 Sum of all six levels of all six skills.
  QuestExperience: TQuestExperienceTable; // @addr $889E0C
  HullArtefactArmor: Integer; // @addr $889E20 Config kArtefactHull.
  HullArtefactStatusDecayFactor: Single; // @addr $889E24 Set to 1.5 by native configuration loading.
  FuelArtefactBase: Integer; // @addr $889E28
  SpeedArtefactFactor: Single; // @addr $889E2C Config kArtefactSpeed.
  EngineArtefactBase: Integer; // @addr $889E30
  RadarArtefactRange: Integer; // @addr $889E34 Config kArtefactRadar.
  ScannerArtefactPower: Integer; // @addr $889E38 Config kArtefactScaner.
  DroidArtefactRepair: Integer; // @addr $889E3C Config kArtefactDroid.
  DroidArtefactWear: Single; // @addr $889E40 Config kArtefactDroidWear.
  DroidArtefactStatusDecayFactor: Single; // @addr $889E44 Set to 1.5 by native configuration loading.
  NanoArtefactRepair: Integer; // @addr $889E48 Loaded from Artefacts.NumericValues.
  DefenseArtefactBonus: Single; // @addr $889E4C Config kArtefactDef.
  AntigravityArtefactMassFactor: Single; // @addr $889E50 Config kArtefactAntigrav.
  CargoHookArtefactPower: Integer; // @addr $889E54 Config kArtefactHook.
  CargoHookArtefactRange: Integer; // @addr $889E58 Config kArtefactHookRaduis.
  CargoHookArtefactSpeed: Integer; // @addr $889E5C Config kArtefactHookSpeed.
  WeaponToSpeedArtefactBonus: Integer; // @addr $889E60 Config kArtWeaponToSpeed.
  DefenseToEnergyUpperFactor: Single; // @addr $889E64 Config kArtDefToEnergyUp.
  DefenseToEnergyMinimumFactor: Single; // @addr $889E68 Config kArtDefToEnergyMin.
  DefenseToEnergyPenalty: Single; // @addr $889E6C Config kArtDefToEnergyPenalty.
  DefenseToWeaponPenalty: Single; // @addr $889E70 Config kArtDefToArms1Penalty.
  EnergyPulseArtefactFactor: Single; // @addr $889E74 Config kArtEnergyPulse.
  EnergyPulseArtefactChance: Single; // @addr $889E78 Config kArtEnergyPulseChance.
  SplinterArtefactFactor: Single; // @addr $889E7C Config kArtSplinter.
  HyperJumpArtefactRange: Integer; // @addr $889E80 Config kArtGiperJump.
  StarHeatArtefactReduction: Single; // @addr $889E84 Configured star-heat reduction per active artefact.
  ExtraMissileChance: Single; // @addr $889E88
  AfterburnerArtefactWearFactor: Single; // @addr $889E8C Config kArtForsage.
  HullArtefactBoostArmor: Integer; // @addr $889E90 Config kArtefactHullEx.
  HullArtefactBoostStatusDecay: Single; // @addr $889E94 Set to 0.5 by native configuration loading.
  FuelArtefactBoost: Integer; // @addr $889E98
  SpeedArtefactBoostFactor: Single; // @addr $889E9C Config kArtefactSpeedEx.
  EngineArtefactBoost: Integer; // @addr $889EA0
  RadarArtefactBoostRange: Integer; // @addr $889EA4 Config kArtefactRadarEx.
  ScannerArtefactBoostPower: Integer; // @addr $889EA8 Config kArtefactScanerEx.
  DroidArtefactBoostRepair: Integer; // @addr $889EAC Config kArtefactDroidEx.
  DroidArtefactBoostWear: Single; // @addr $889EB0 Config kArtefactDroidWearEx.
  DroidArtefactBoostStatusDecay: Single; // @addr $889EB4 Set to 0.5 by native configuration loading.
  NanoArtefactBoostRepair: Integer; // @addr $889EB8 Loaded from Artefacts.NumericValues.
  DefenseArtefactBoost: Single; // @addr $889EBC Config kArtefactDefEx.
  AntigravityArtefactBoostFactor: Single; // @addr $889EC0 Config kArtefactAntigravEx.
  CargoHookArtefactBoostPower: Integer; // @addr $889EC4 Config kArtefactHookEx.
  CargoHookArtefactBoostRange: Integer; // @addr $889EC8 Config kArtefactHookRaduisEx.
  CargoHookArtefactBoostSpeed: Integer; // @addr $889ECC Config kArtefactHookSpeedEx.
  WeaponToSpeedArtefactBoost: Integer; // @addr $889ED0 Config kArtWeaponToSpeedEx.
  DefenseToEnergyUpperBoost: Single; // @addr $889ED4 Config kArtDefToEnergyUpEx.
  DefenseToEnergyMinimumBoost: Single; // @addr $889ED8 Config kArtDefToEnergyMinEx.
  DefenseToEnergyBoostPenalty: Single; // @addr $889EDC Config kArtDefToEnergyPenaltyEx.
  EnergyPulseArtefactBoostFactor: Single; // @addr $889EE0 Config kArtEnergyPulseEx.
  SplinterArtefactBoostFactor: Single; // @addr $889EE4 Config kArtSplinterEx.
  HyperJumpArtefactBoostRange: Integer; // @addr $889EE8 Config kArtGiperJumpEx.
  StarHeatArtefactBoostReduction: Single; // @addr $889EEC Boosted additional reduction.
  ExtraMissileBoostChance: Single; // @addr $889EF0 Loaded from Artefacts.NumericValues.
  AfterburnerArtefactBoostWearFactor: Single; // @addr $889EF4 Config kArtForsageEx.
  MinTransmitterPower: Integer; // @addr $889EF8 Loaded from Artefacts.NumericValues.
  AverageTransmitterPower: Integer; // @addr $889EFC Loaded from Artefacts.NumericValues.
  MaxTransmitterPower: Integer; // @addr $889F00 Loaded from Artefacts.NumericValues.
  TransmitterSameSystemPenalty: Integer; // @addr $889F04 Loaded from Artefacts.NumericValues.
  TransmitterAnySystemPenalty: Integer; // @addr $889F08 Loaded from Artefacts.NumericValues.
  TransmitterSameSystemPenaltyTurns: Integer; // @addr $889F0C Loaded from Artefacts.NumericValues.
  TransmitterAnySystemPenaltyTurns: Integer; // @addr $889F10 Loaded from Artefacts.NumericValues.
  SubportalRewardPenalty: Integer; // @addr $889F14
  SubportalRewardPenaltyTurns: Integer; // @addr $889F18
  ItemExplosionBonusDamage: Integer; // @addr $889F1C Added when Item.DestroyFlag is two.
  BombMinimumDamage: Integer; // @addr $889F20 Damage at the blast radius.
  BombMaximumDamage: Integer; // @addr $889F24 Damage at the center.
  BombDamageRadius: Integer; // @addr $889F28
  ItemExplosionRadiusSquared: Integer; // @addr $889F2C Square of configured BombRadius.
  PointDefensePassCount: Integer; // @addr $889F30
  PointDefenseBaseRange: Integer; // @addr $889F34
  PointDefenseBonusRange: Integer; // @addr $889F38
  AsteroidMinDamageFactor: Single; // @addr 0x889F3C @note "Asteroid.kAsteroidMinDamagePercent divided by 100; fraction of hull capacity."
  AsteroidMaxDamageFactor: Single; // @addr 0x889F40 @note "Asteroid.kAsteroidMaxDamagePercent divided by 100."
  AsteroidMinDamageFactorWithDefGenerator: Single; // @addr 0x889F44 @note "Asteroid.kAsteroidMinDamagePercentDef divided by 100."
  AsteroidMaxDamageFactorWithDefGenerator: Single; // @addr 0x889F48 @note "Asteroid.kAsteroidMaxDamagePercentDef divided by 100."
  HullCapacityScale: Single; // @addr $889F4C Hull capacities are multiplied by this configuration value.
  HullBaseSize: Integer; // @addr $889F50
  FuelTanksBaseSize: Integer; // @addr $889F54
  EngineBaseSize: Integer; // @addr $889F58
  RadarBaseSize: Integer; // @addr $889F5C
  ScannerBaseSize: Integer; // @addr $889F60
  RepairRobotBaseSize: Integer; // @addr $889F64
  CargoHookBaseSize: Integer; // @addr $889F68
  DefGeneratorBaseSize: Integer; // @addr $889F6C
  AfterburnerSpeedFactor: Single; // @addr $889F70 Config native equipment configuration.
  FuelCapacityByLevel: array[1..8] of Byte; // @addr $889F74 Loaded from equipment configuration.
  EngineLevelStats: TEngineLevelStatsTable; // @addr $889F7C Loaded by the native equipment configuration initializer.
  HullLevelStats: THullLevelStatsTable; // @addr $889F9C Native per-technology armor table; remaining fields unresolved.
  RepairRobotLevelPoints: array[1..8] of Byte; // @addr $88A01C Loaded from mRepair.
  DefGeneratorLevelFactors: array[1..8] of Single; // @addr $88A024
  RadarLevelRanges: array[1..8] of Word; // @addr $88A044 Loaded from equipment configuration.
  CargoHookLevelStats: TCargoHookLevelStatsTable; // @addr $88A054
  HullFragilityByOwner: array[0..2, 0..7] of Single; // @addr $88A0D4 Damage class, then owner; loaded from mFragilityByOwner*.
  HullFragilityByType: array[0..10] of Single; // @addr $88A134 Loaded from mFragilityByShipType.
  WeaponInfos: array[50..67] of TWeaponInfo; // @addr 0x88A160
var
  EquipmentInventionIndices: TEquipmentInventionIndexTable = (0, 1, 2, 3, 4, 5, 6, 7); // @addr $87EA5C
  CoalitionProjectNames: array[0..11] of WideString = ('CreateRC', 'CreatePB', 'CreateWB', 'CreateSB', 'CreateBK', 'CreateMC', 'RangersSubsidy', 'PiratesSubsidy', 'TransportSubsidy', 'LostSubsidy', 'WarSubsidy', 'WarOperation'); // @addr $87EA64
type
  // Native record RTTI at $7DC35C.
  TIllnessInfo = record // @size $28 Native TIllnessInfo RTTI at $7DC360.
    Name: WideString; // @offset $00
    Text: WideString; // @offset $04
    AllowedLocationOwners: TOwnerMask; // @offset $08
    AllowedOwners: TOwnerMask; // @offset $09
    AllowedRatingBands: TOwnerMask; // @offset $0A
    AllowedRanks: TOwnerMask; // @offset $0B
    AllowedCareers: TOwnerMask; // @offset $0C
    EffectClass0D: Byte; // @offset $0D Native values 1..5; gameplay meaning unresolved.
    DevelopmentRate: Double; // @offset $10 Progress increment factor.
    InfectionChance: Double; // @offset $18
    Locations: TOwnerMask; // @offset $20 Bits 0=planet, 1=ship interior, 2=normal space, 3=combat infection.
    Disabled: Boolean; // @offset $21
    Duration: Integer; // @offset $24
  end;

  TCaptainHealthDefinitions = array[1..24] of TIllnessInfo;

  TRadiationHealthDefinitions = array[1..1] of TIllnessInfo;

var
  StationServiceRepeatPeriods: array[0..11] of Integer = (100, 400, 300, 200, 350, 250, 150, 220, 40, 50, 70, 80); // @addr $87EA94
  ProgramNames: array[0..11] of WideString = (
    'KellerCall', 'LogicalNegation', 'Dematerial', 'Energotron', 'SabCrack', 'Intercom',
    'Shipwreck', 'WeaponBlocking', 'Insanity', 'Shock', 'SelfDestruction', 'Disconnection'); // @addr $87EAC4 Native WideString initializer descriptors at $7E7380..$7E73DC.
var
  ProgramDuration: TProgramDurationTable = (0, 0, 0, 0, 0, 0, 0, 10, 23, 7, 0, 0); // @addr $87EAF4
  PirateProgramBatchSizes: array[0..11] of Integer = (0, 0, 0, 0, 0, 5, 3, 3, 3, 3, 1, 1); // @addr $87EB24
  PirateProgramBaseCosts: array[0..11] of Integer = (0, 0, 0, 0, 0, 500, 1000, 800, 300, 200, 1200, 900); // @addr $87EB54
  GoodsMarketBaseCaptured: Boolean = False; // @addr $87EB84 Set after the one-time localized base-table copy.
  IntegrityDataEnd: Cardinal = 0; // @addr $87EB88 Four-byte zero marker at the exclusive boundary of that native checksum span.
  LastMedicalPolicyTicks: Integer = 0; // @addr $87EB8C Updated by TPlayer.NextDay and read by TfGameEnd.OnOpen; score-related role not fully recovered.
var
  HullMassEvaluationStart: Integer; // @addr $88A9D0 Initialized from HullBaseSize and EquipmentSizeFactors[5].
  HullMassEvaluationEnd: Integer; // @addr $88A9D4 Initialized from HullBaseSize and EquipmentSizeFactors[1].
  WearMassMin: Integer; // @addr $88A9D8
  WearMassMax: Integer; // @addr $88A9DC
  GoodsMarketBase: array[0..7] of TGoodsInfo; // @addr $88A9E0
  MicroModuleTemplates: array of TMicroModuleInfo; // @addr 0x88AB60
var
  MicroModuleTemplateCount: Integer; // @addr 0x88AB64
  HullSeriesDefinitions: array of THullTypeInfo; // @addr $88AB68 Loaded from HullType configuration, sorted by numeric suffix.
var
  HullSeriesCount: Integer; // @addr $88AB6C Native count used by CheatIdeal and hull-series configuration.
  CaptainHealthDefinitions: array[1..24] of TIllnessInfo; // @addr $88AB70 Native disease/stimulant definitions; eligibility and progression fields verified in TPlayer.NextDay.
  RadiationHealthDefinitions: TRadiationHealthDefinitions; // @addr $88AF30 Finalized as one TIllnessInfo alongside the 24 captain effects at $7E733F.
  MicroModuleCandidateIndices: array of Integer; // @addr 0x88AF58 @note "Shared selection scratch, sized to MicroModuleTemplateCount when templates load. Callers track the used prefix separately."

implementation

// @unit-initialization $876A44
// @unit-finalization $7E7058

uses aItem, aShip, Math, CrcUnit, EC_BlockPar, Globals, GlobalsV, EC_Str, GR_Main, SysUtils, aGalaxy, aPlayer, aMyFunction, aRanger, aWarrior, aPirate, aTransport, aKling, aTranclucator, aRuins;

{ @routine $7DC5B0 InitializeGameplayConfig }
procedure InitializeGameplayConfig;
var
  Level, GoodsIndex, Government, Relation, KlingKind, Series, Owner, Economy: Byte;
  Difficulty: ^TGalaxyDifficultyTuning;

  // @nested $7DC538 ExtrapolateLinearDifficulty
  function ExtrapolateLinearDifficulty(Level: Byte; Level2, Level3: Single): Single; // @addr $7DC538 @ida "float __userpurge $name@<st0>(unsigned __int8 Level@<al>, float Level3@<^0>, float Level2@<^4>, void *ParentFrame@<^8>);" @calls "0x7dc708 0x7dc724 0x7dc741 0x7dc77a 0x7dc79b 0x7dc7c6 0x7dc803 0x7dc824" @stackpop 0x8 @note "Nested in InitializeGameplayConfig; unused caller-popped static link."
  var Delta: Integer;
  begin
    Delta := Level - 3;
    Result := Level3 + (Level3 - Level2) * Delta;
  end;

  // @nested $7DC568 ExtrapolateGeometricDifficulty
  function ExtrapolateGeometricDifficulty(Level: Byte; Level2, Level3: Single): Single; // @addr $7DC568 @ida "float __userpurge $name@<st0>(unsigned __int8 Level@<al>, float Level3@<^0>, float Level2@<^4>, void *ParentFrame@<^8>);" @calls "0x7dc841 0x7dc85e 0x7dc87b 0x7dc8a6 0x7dc8c7 0x7dc8e4" @stackpop 0x8 @note "Nested in InitializeGameplayConfig; unused caller-popped static link."
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
    Difficulty.DifficultyValue1C := Round(ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].DifficultyValue1C, GalaxyDifficultyTuning[3].DifficultyValue1C));
    Difficulty.MarketPriceBandSqueeze := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].MarketPriceBandSqueeze, GalaxyDifficultyTuning[3].MarketPriceBandSqueeze);
    Difficulty.RandomHoleSpawnRollMaximum := Round(ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].RandomHoleSpawnRollMaximum, GalaxyDifficultyTuning[3].RandomHoleSpawnRollMaximum));
    Difficulty.MaximumResearchMaterialConsumption := Round(ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].MaximumResearchMaterialConsumption, GalaxyDifficultyTuning[3].MaximumResearchMaterialConsumption));
    Difficulty.ArcadeDamageTakenScale := ExtrapolateLinearDifficulty(Level, GalaxyDifficultyTuning[2].ArcadeDamageTakenScale, GalaxyDifficultyTuning[3].ArcadeDamageTakenScale);
    Difficulty.InventionProgressScale := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].InventionProgressScale, GalaxyDifficultyTuning[3].InventionProgressScale);
    Difficulty.ArcadeRewardScale := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].ArcadeRewardScale, GalaxyDifficultyTuning[3].ArcadeRewardScale);
    Difficulty.QuestMoneyFactor := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].QuestMoneyFactor, GalaxyDifficultyTuning[3].QuestMoneyFactor);
    Difficulty.DifficultyValue18 := Round(ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].DifficultyValue18, GalaxyDifficultyTuning[3].DifficultyValue18));
    Difficulty.MaximumDominatorResearchRate := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].MaximumDominatorResearchRate, GalaxyDifficultyTuning[3].MaximumDominatorResearchRate);
    Difficulty.DifficultyFactor34 := ExtrapolateGeometricDifficulty(Level, GalaxyDifficultyTuning[2].DifficultyFactor34, GalaxyDifficultyTuning[3].DifficultyFactor34);
  end;
  for GoodsIndex := 0 to 7 do GoodsMarket[GoodsIndex].DisplayName := LocalizedText('Items.Goods.Name.' + IntToStr(GoodsIndex + 1));
  for GoodsIndex := 0 to 7 do GoodsMarket[GoodsIndex].TradeName := LocalizedText('Items.Goods.NameBuy.' + IntToStr(GoodsIndex + 1));
  for Government := 0 to 4 do PlanetGovernmentMarket[Government].DisplayName := LocalizedText('Goverment.Type.' + IntToStr(Government));
  for Relation := 0 to 4 do RelationInfo[Relation].DisplayName := LocalizedText('Relations.Type.' + IntToStr(Relation));
  for KlingKind := 0 to 7 do
    for Series := 0 to 2 do
      DominatorShipDefinitions[KlingKind].DisplayNames[Series] := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[Series] + '.' + IntToStr(KlingKind));
  for Owner := 0 to 7 do OwnerInfo[Owner].DisplayName := LookupLocalizedTextByKey('Race.Name.' + OwnerInfo[Owner].InternalName);
  // Both identical localization passes are present in the native initializer.
  for Owner := 0 to 7 do OwnerInfo[Owner].DisplayName := LookupLocalizedTextByKey('Race.Name.' + OwnerInfo[Owner].InternalName);
  for Economy := 0 to 2 do
  begin
    PlanetEconomyInfo[Economy].DisplayName := LookupLocalizedTextByKey('Economy.Name.' + IntToStr(Economy));
    PlanetEconomyInfo[Economy].ShortDisplayName := LookupLocalizedTextByKey('Economy.ShortName.' + IntToStr(Economy));
  end;
  if not GoodsMarketBaseCaptured then
  begin
    for GoodsIndex := 0 to 7 do GoodsMarketBase[GoodsIndex] := GoodsMarket[GoodsIndex];
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
    DefaultHullSlotCounts[8] := Max(4, Min(32, ExtractDigitsToIntW(LanguageDataConfig.GetParamByPath('Artefacts.NumericValues.MaxSlots'))))
  else DefaultHullSlotCounts[8] := 4;
  HullMassEvaluationStart := Round(HullBaseSize * EquipmentSizeFactors[5] * 2);
  HullMassEvaluationEnd := Round(HullBaseSize * EquipmentSizeFactors[1] * 2);
  WearMassMin := Round(HullBaseSize * EquipmentSizeFactors[1] * 5);
  WearMassMax := Round(HullBaseSize * EquipmentSizeFactors[1] * 50);
end;
{ @end $7DC5B0 }

{ @routine $7DD0F8 OwnerToRace }
function OwnerToRace(OwnerId: Byte): Byte;
begin
  case OwnerId of
    Ord(oiMaloc): Result := Byte(oiMaloc);
    Ord(oiPeleng): Result := Byte(oiPeleng);
    Ord(oiHuman): Result := Byte(oiHuman);
    Ord(oiFeyan): Result := Byte(oiFeyan);
    Ord(oiGaal): Result := Byte(oiGaal);
  else
    begin
      raise Exception.Create('Error in OwnerToRace');
      Result := Byte(oiMaloc);
    end;
  end;
end;
{ @end $7DD0F8 }

{ @routine $7DD184 RaceToOwner }
function RaceToOwner(RaceId: Byte): TOwnerIndex;
begin
  case RaceId of
    Ord(oiMaloc): Result := Byte(oiMaloc);
    Ord(oiPeleng): Result := Byte(oiPeleng);
    Ord(oiHuman): Result := Byte(oiHuman);
    Ord(oiFeyan): Result := Byte(oiFeyan);
    Ord(oiGaal): Result := Byte(oiGaal);
  else
    begin
      raise Exception.Create('Error in RaceToOwner');
      Result := Byte(oiMaloc);
    end;
  end;
end;
{ @end $7DD184 }

{ @routine $7DD210 RaceToSys }
function RaceToSys(RaceId: Byte): WideString;
begin
  case RaceId of
    Ord(oiMaloc): Result := 'Maloc';
    Ord(oiPeleng): Result := 'Peleng';
    Ord(oiHuman): Result := 'People';
    Ord(oiFeyan): Result := 'Fei';
    Ord(oiGaal): Result := 'Gaal';
  else
    begin
      raise Exception.Create('Error in RaceToSys');
      Result := '';
    end;
  end;
end;
{ @end $7DD210 }

{ @routine $7DD320 OwnerToFilmColor }
function OwnerToFilmColor(OwnerId: ShortInt): Cardinal;
begin
  case Byte(OwnerId) of
    Ord(oiMaloc): Result := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
    Ord(oiPeleng): Result := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
    Ord(oiHuman): Result := CurrentPixelFormat.PackRgbBytes(0, $47, $EA);
    Ord(oiFeyan): Result := CurrentPixelFormat.PackRgbBytes(255, $93, $F1);
    Ord(oiGaal): Result := CurrentPixelFormat.PackRgbBytes($ED, $F7, $3E);
    Ord(oiDominator): Result := CurrentPixelFormat.PackRgbBytes($61, $A7, $BE);
    Ord(oiPirate): Result := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  else Result := CurrentPixelFormat.PackRgbBytes(255, 0, 255);
  end;
end;
{ @end $7DD320 }

{ @routine $7DD430 CustomFactionToFilmColor }
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
  Result := OwnerToFilmColor(Ord(oiUninhabited));
end;
{ @end $7DD430 }

{ @routine $7DD580 LookupNamedColorTag }
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
{ @end $7DD580 }

{ @routine $7DD6BC GetCustomFactionPlanetIconNumber }
function GetCustomFactionPlanetIconNumber(Faction: WideString): Integer;
var Block: TBlockParEC;
begin
  Block := GameDataConfig.GetBlock('Race').FindBlock('PlanetIconNum');
  if (Block <> nil) and (Block.CountParamsByPath(Faction) > 0) then
    Result := ExtractDigitsToIntW(Block.GetParamByPathOrMarker(Faction))
  else Result := -1;
end;
{ @end $7DD6BC }

{ @routine $7DD794 GetFactionEmblemPath }
function GetFactionEmblemPath(Faction: WideString): WideString;
begin
  Result := GameDataConfig.GetParamByPathOrMarker('Race.Emblem.2' + Faction);
end;
{ @end $7DD794 }

{ @routine $7DD828 OwnerToSys }
function OwnerToSys(OwnerId: Byte): WideString;
begin
  case OwnerId of
    Ord(oiMaloc): Result := 'Maloc';
    Ord(oiPeleng): Result := 'Peleng';
    Ord(oiHuman): Result := 'People';
    Ord(oiFeyan): Result := 'Fei';
    Ord(oiGaal): Result := 'Gaal';
    Ord(oiDominator): Result := 'Kling';
    Ord(oiPirate): Result := 'PirateClan';
  else Result := 'None';
  end;
end;
{ @end $7DD828 }

{ @routine $7DD974 OwnerFromInternalName }
function OwnerFromInternalName(const Name: WideString): Byte;
begin
  if Name = 'Maloc' then begin Result := Byte(oiMaloc); Exit; end;
  if Name = 'Peleng' then begin Result := Byte(oiPeleng); Exit; end;
  if Name = 'People' then begin Result := Byte(oiHuman); Exit; end;
  if Name = 'Fei' then begin Result := Byte(oiFeyan); Exit; end;
  if Name = 'Gaal' then begin Result := Byte(oiGaal); Exit; end;
  if Name = 'Kling' then begin Result := Byte(oiDominator); Exit; end;
  if Name = 'PirateClan' then begin Result := Byte(oiPirate); Exit; end;
  Result := Byte(oiUninhabited);
end;
{ @end $7DD974 }

{ @routine $7DDAA0 IsKnownOwnerName }
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
{ @end $7DDAA0 }

{ @routine $7DDBFC NumberToRace }
function NumberToRace(Value: Integer): Byte;
begin
  case Value of
    0: Result := Byte(oiMaloc);
    1: Result := Byte(oiPeleng);
    2: Result := Byte(oiHuman);
    3: Result := Byte(oiFeyan);
    4: Result := Byte(oiGaal);
  else
    begin
      raise Exception.Create('Error in NumberToRace');
      Result := Byte(oiMaloc);
    end;
  end;
end;
{ @end $7DDBFC }

{ @routine $7DDC88 MatchesOwnerName }
function MatchesOwnerName(OwnerId: Byte; const Name: WideString): Boolean;
begin
  Result := not IsKnownOwnerName(Name) or (Name = OwnerToSys(OwnerId));
end;
{ @end $7DDC88 }

{ @routine $7DDCF8 PickRandomEquipmentOwner }
function PickRandomEquipmentOwner(RandomValue: Dword): Byte;
begin
  Result := SeededRandomIntRange(0, 4, RandomValue);
end;
{ @end $7DDCF8 }

{ @routine $7DDD1C MatchesCareerName }
function MatchesCareerName(Career: Byte; const Names: WideString): Boolean;
begin
  if (Pos(CareerTuning[Career].Name, Names) > 0) or (Names = 'Any') or (Names = '') then Result := True
  else Result := False;
end;
{ @end $7DDD1C }

{ @routine $7DDD7C SysToReward }
function SysToReward(const Name: WideString): Byte;
begin
  if Name = 'ForLiberationSystem' then Result := atLiberation
  else if Name = 'ForAccomplishment' then Result := atAccomplishment
  else if Name = 'ForSecretMission' then Result := atSecretMission
  else if Name = 'ForCowardice' then Result := atCowardice
  else if Name = 'ForPerfidy' then Result := atPerfidy
  else if Name = 'ForPlanetBattle' then Result := atPlanetBattle
  else begin RaiseWideMessage('Error in SysToReward'); Result := atPerfidy; end;
end;
{ @end $7DDD7C }

{ @routine $7DDF24 SysToShipType }
function SysToShipType(const Name: WideString): Byte;
var Kind: Byte;
begin
  for Kind := 0 to 13 do
    if ShipTypeNames[Kind].Name = Name then begin Result := Kind; Exit; end;
  RaiseWideMessage('Error in SysToShipType');
  Result := 0;
end;
{ @end $7DDF24 }

{ @routine $7DDFA4 GetAverageItemSize }
function GetAverageItemSize(ItemType: Byte): Integer;
begin
  case ItemType of
    Ord(t_ArtefactHull): Result := 12;
    Ord(t_ArtefactFuel): Result := 4;
    Ord(t_ArtefactSpeed): Result := 12;
    Ord(t_ArtefactPower): Result := 7;
    Ord(t_ArtefactRadar): Result := 10;
    Ord(t_ArtefactScaner): Result := 8;
    Ord(t_ArtefactDroid): Result := 10;
    Ord(t_ArtefactNano): Result := 3;
    Ord(t_ArtefactHook): Result := 3;
    Ord(t_ArtefactDef): Result := 12;
    Ord(t_ArtefactAnalyzer): Result := 5;
    Ord(t_ArtefactMiniExpl): Result := 10;
    Ord(t_ArtefactAntigrav): Result := 20;
    Ord(t_ArtefactTransmitter): Result := 3;
    Ord(t_ArtefactBomb): Result := 5;
    Ord(t_ArtefactTranclucator): Result := 50;
    Ord(t_ArtDefToEnergy): Result := 5;
    Ord(t_ArtEnergyPulse): Result := 8;
    Ord(t_ArtEnergyDef): Result := 5;
    Ord(t_ArtSplinter): Result := 10;
    Ord(t_ArtDecelerate): Result := 5;
    Ord(t_ArtMissileDef): Result := 6;
    Ord(t_ArtForsage): Result := 6;
    Ord(t_ArtWeaponToSpeed): Result := 7;
    Ord(t_ArtGiperJump): Result := 5;
    Ord(t_ArtBlackHole): Result := 3;
    Ord(t_ArtDefToArms1): Result := 9;
    Ord(t_ArtDefToArms2): Result := 7;
    Ord(t_ArtArtefactor): Result := 3;
    Ord(t_ArtBio): Result := 2;
    Ord(t_ArtPDTurret): Result := 15;
    Ord(t_ArtFastRacks): Result := 10;
    Ord(t_Hull): Result := HullBaseSize;
    Ord(t_FuelTanks): Result := FuelTanksBaseSize;
    Ord(t_Engine): Result := EngineBaseSize;
    Ord(t_Radar): Result := RadarBaseSize;
    Ord(t_Scaner): Result := ScannerBaseSize;
    Ord(t_RepairRobot): Result := RepairRobotBaseSize;
    Ord(t_CargoHook): Result := CargoHookBaseSize;
    Ord(t_DefGenerator): Result := DefGeneratorBaseSize;
  else
    if ItemType in [Ord(t_Weapon1)..Ord(t_CustomWeapon)] then Result := WeaponInfos[ItemType].AverageSize
    else
    begin
      Exception.Create('Error ItemAverageSize'); // Native allocates the exception without raising it.
      Result := 0;
    end;
  end;
end;
{ @end $7DDFA4 }

{ @routine $7DE294 GenerateValueForSizeLevel }
function GenerateValueForSizeLevel(Level: Byte; Minimum, Maximum: Integer; VariationPercent: Byte; Seed: Cardinal): Integer;
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
  if SeededRandomUnitFloat(Seed + Cardinal(Center)) < 0.5 then
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
{ @end $7DE294 }

{ @routine $7DE43C SizeTagToLevel }
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
{ @end $7DE43C }

{ @routine $7DE530 ShipToHullType }
function ShipToHullType(Ship: TObject): Byte;
begin
  Result := htRanger;
  if Ship is TRanger then Result := htRanger
  else if Ship is TWarrior then Result := htWarrior
  else if Ship is TPirate then Result := htPirate
  else if Ship is TTransport then
  begin
    if TTransport(Ship).TransportType = ttTransport then Result := htTransport
    else if TTransport(Ship).TransportType = ttLiner then Result := htLiner
    else Result := htDiplomat;
  end
  else if Ship is TKling then Result := htKling
  else if Ship is TTranclucator then Result := htTranclucator
  else if Ship is TRuins then Result := htStation
  else RaiseWideMessage('ShipToSShipType');
end;
{ @end $7DE530 }

{ @routine $7DE648 RelationValueToLevel }
function RelationValueToLevel(Value: Byte): TRelationLevel;
begin
  case Value of
    0..9: Result := rlHostile;
    10..29: Result := rlBad;
    30..59: Result := rlNormal;
    60..79: Result := rlGood;
    80..100: Result := rlExcellent;
  else
    Result := rlNormal;
  end;
end;
{ @end $7DE648 }

{ @routine $7DE6A4 ItemTypeToSlotKind }
function ItemTypeToSlotKind(ItemType: Byte): TShipSlotKind;
begin
  case ItemType of
    Ord(t_FuelTanks): Result := sskFuelTanks;
    Ord(t_Engine): Result := sskEngine;
    Ord(t_Radar): Result := sskRadar;
    Ord(t_Scaner): Result := sskScanner;
    Ord(t_RepairRobot): Result := sskRepairRobot;
    Ord(t_CargoHook): Result := sskCargoHook;
    Ord(t_DefGenerator): Result := sskDefGenerator;
  else
    if ItemType in [Ord(t_Weapon1)..Ord(t_CustomWeapon)] then Result := sskWeapon
    else if ItemType in [Ord(t_Artefact)..Ord(t_ArtFastRacks)] then Result := sskArtefact
    else Result := sskUnsupported;
  end;
end;
{ @end $7DE6A4 }

{ @routine $7DE730 LocalizedText }
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
      Result := ReplaceAllWideString(Result, '<Player>', '<color=255,240,100>' + GetPlayer.Name + '</color>');
  end;
end;
{ @end $7DE730 }

{ @routine $7DE980 LocalizedColorText }
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
      Result := ReplaceAllWideString(Result, '<Player>', '<color=255,240,100>' + GetPlayer.Name + '</color>');
    Result := ReplaceAllWideString(Result, '<clr>', '<color=255,240,100>');
    Result := ReplaceAllWideString(Result, '<clrEnd>', '</color>');
  end;
end;
{ @end $7DE980 }

{ @routine $7DEC3C ExpandLocalizedTextMarkup }
procedure ExpandLocalizedTextMarkup(var Text: WideString);
begin
  if FindTextPosW('<', Text) > 0 then
  begin
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Text := ReplaceAllWideString(Text, '<Player>', '<color=255,240,100>' + GetPlayer.Name + '</color>');
    Text := ReplaceAllWideString(Text, '<clr>', '<color=255,240,100>');
    Text := ReplaceAllWideString(Text, '<clrEnd>', '</color>');
  end;
end;
{ @end $7DEC3C }

{ @routine $7DEE34 ExpandLocalizedTextMarkupAndPrefixLines }
procedure ExpandLocalizedTextMarkupAndPrefixLines(var Text: WideString);
begin
  if FindTextPosW('<', Text) > 0 then
  begin
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Text := ReplaceAllWideString(Text, '<Player>', '<color=255,240,100>' + GetPlayer.Name + '</color>');
    Text := ReplaceAllWideString(Text, '<clr>', '<color=255,240,100>');
    Text := ReplaceAllWideString(Text, '<clrEnd>', '</color>');
  end;
  Text := LocalizedTextLinePrefix + TrimWideString(Text);
  Text := ReplaceAllWideString(Text, #13#10, #13#10 + LocalizedTextLinePrefix);
end;
{ @end $7DEE34 }

{ @routine $7DF080 PickLocalizedTextVariant }
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
    Result := 'String: ' + WrapTextInColor(Path, '<color=255,240,100>') + ' is unavailable'
  else if Count = 1 then Result := Variants[0]
  else
  begin
    Count := SeededRandomIntRange(0, Count - 1, (Galaxy.CurrentTurn + SeedOffset) div 10);
    Result := Variants[Count];
  end;
end;
{ @end $7DF080 }

{ @routine $7DF284 FindMicroModuleTemplateByCustomTag }
function FindMicroModuleTemplateByCustomTag(CustomTag: WideString): Integer;
var I: Integer;
begin
  for I := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[I].CustomTag = CustomTag then begin Result := I; Exit; end;
  Result := -1;
end;
{ @end $7DF284 }

{ @routine $7DF314 LoadArtefactConfiguration }
procedure LoadArtefactConfiguration;
const ArtefactTypes = [0..79] - [0..9] - [42..79];
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
    Kind := TItemType(GetItemTypeFromMask([0..79] - [0..9] - [42..79], Index));
    Block := Config.GetBlock(ItemTypeNames[Ord(Kind)]);
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
  SetLength(ArtefactLootPools[0], ABDropCount);
  SetLength(ArtefactLootPools[1], TreasureCount);
  SetLength(ArtefactLootPools[2], RewardCount);
  SetLength(ArtefactLootPools[3], AnyCount);
  ABDropCount := 0;
  TreasureCount := 0;
  RewardCount := 0;
  AnyCount := 0;
  for Index := 1 to CountItemTypesInMask(ArtefactTypes) do
  begin
    Kind := TItemType(GetItemTypeFromMask([0..79] - [0..9] - [42..79], Index));
    Block := Config.GetBlock(ItemTypeNames[Ord(Kind)]);
    CanBeABDrop := (Block.CountParams('CanBeABDrop') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeABDrop')) > 0);
    CanBeTreasure := (Block.CountParams('CanBeTreasure') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeTreasure')) > 0);
    CanBeReward := (Block.CountParams('CanBeReward') <= 0) or (ExtractDigitsToIntW(Block.GetParam('CanBeReward')) > 0);
    if CanBeABDrop or CanBeTreasure or CanBeReward then
    begin
      if CanBeABDrop then
      begin
        ArtefactLootPools[0][ABDropCount] := Kind;
        Inc(ABDropCount);
      end;
      if CanBeTreasure then
      begin
        ArtefactLootPools[1][TreasureCount] := Kind;
        Inc(TreasureCount);
      end;
      if CanBeReward then
      begin
        ArtefactLootPools[2][RewardCount] := Kind;
        Inc(RewardCount);
      end;
      ArtefactLootPools[3][AnyCount] := Kind;
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
  SetLength(CustomArtefactLootPools[0], ABDropCount);
  SetLength(CustomArtefactLootPools[1], TreasureCount);
  SetLength(CustomArtefactLootPools[2], RewardCount);
  SetLength(CustomArtefactLootPools[3], AnyCount);
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
        CustomArtefactLootPools[0][ABDropCount] := ItemName;
        Inc(ABDropCount);
      end;
      if CanBeTreasure then
      begin
        CustomArtefactLootPools[1][TreasureCount] := ItemName;
        Inc(TreasureCount);
      end;
      if CanBeReward then
      begin
        CustomArtefactLootPools[2][RewardCount] := ItemName;
        Inc(RewardCount);
      end;
      CustomArtefactLootPools[3][AnyCount] := ItemName;
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
  SetLength(UselessItemLootPools[0], ABDropCount);
  SetLength(UselessItemLootPools[1], TreasureCount);
  SetLength(UselessItemLootPools[2], RewardCount);
  SetLength(UselessItemLootPools[3], AnyCount);
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
        UselessItemLootPools[0][ABDropCount] := ItemName;
        Inc(ABDropCount);
      end;
      if CanBeTreasure then
      begin
        UselessItemLootPools[1][TreasureCount] := ItemName;
        Inc(TreasureCount);
      end;
      if CanBeReward then
      begin
        UselessItemLootPools[2][RewardCount] := ItemName;
        Inc(RewardCount);
      end;
      UselessItemLootPools[3][AnyCount] := ItemName;
      Inc(AnyCount);
    end;
  end;
end;
{ @end $7DF314 }

{ @routine $7E17F8 LoadDamageSkillQuestMarketConfiguration }
procedure LoadDamageSkillQuestMarketConfiguration;
var
  Level, Cost: Integer;
  Block: TBlockParEC;
  Values: WideString;
  QuestKind, Skill: Byte;
begin
  Block := LanguageDataConfig.GetBlockByPath('Asteroid');
  AsteroidMinDamageFactor := StrToInt(AnsiString(Block.GetParam('kAsteroidMinDamagePercent'))) * 0.01;
  AsteroidMaxDamageFactor := StrToInt(AnsiString(Block.GetParam('kAsteroidMaxDamagePercent'))) * 0.01;
  AsteroidMinDamageFactorWithDefGenerator := StrToInt(AnsiString(Block.GetParam('kAsteroidMinDamagePercentDef'))) * 0.01;
  AsteroidMaxDamageFactorWithDefGenerator := StrToInt(AnsiString(Block.GetParam('kAsteroidMaxDamagePercentDef'))) * 0.01;
  TotalSkillTrainingCost := 0;
  for Skill := 0 to 5 do
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
  for QuestKind := 0 to 4 do QuestExperience[QuestKind] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, QuestKind - 0, ',')));
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestTurns');
  for QuestKind := 0 to 4 do QuestTuning[QuestKind].BaseDuration := StrToInt(AnsiString(ExtractDelimitedPartW(Values, QuestKind - 0, ',')));
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestMoneyBase');
  for QuestKind := 0 to 4 do QuestTuning[QuestKind].BaseRewardMoney := StrToInt(AnsiString(ExtractDelimitedPartW(Values, QuestKind - 0, ',')));
  Values := LanguageDataConfig.GetBlockByPath('Quest').GetParam('QuestMoneyPerc');
  for QuestKind := 0 to 4 do QuestTuning[QuestKind].RewardCapitalPercent := StrToInt(AnsiString(ExtractDelimitedPartW(Values, QuestKind - 0, ',')));
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
{ @end $7E17F8 }

{ @routine $7E1FD0 LoadEquipmentConfiguration }
procedure LoadEquipmentConfiguration;
var Level: Byte; Block: TBlockParEC; Values: WideString; DamageKind, Owner, HullKind: Byte;
begin
  Block := LanguageDataConfig.GetBlockByPath('Items.Hull');
  HullBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  HullCapacityScale := HullBaseSize / 500;
  Values := Block.GetParam('mAlloy');
  for Level := 1 to 8 do HullLevelStats[Level].Armor := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  for DamageKind := 0 to 2 do
  begin
    Values := Block.GetParam('mFragilityByLevel' + WeaponDamageClasses[DamageKind].Name);
    for Level := 1 to 8 do HullLevelStats[Level].Fragility[DamageKind] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - 1, ','));
    Values := Block.GetParam('mFragilityByOwner' + WeaponDamageClasses[DamageKind].Name);
    for Owner := 0 to 7 do HullFragilityByOwner[DamageKind, Owner] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Owner - 0, ','));
  end;
  Values := Block.GetParam('mFragilityByShipType');
  for HullKind := 0 to 10 do HullFragilityByType[HullKind] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, HullKind - 0, ','));
  Block := LanguageDataConfig.GetBlockByPath('Items.FuelTanks');
  FuelTanksBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mCapacity');
  for Level := 1 to 8 do FuelCapacityByLevel[Level] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.Engine');
  EngineBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mSpeed');
  for Level := 1 to 8 do EngineLevelStats[Level].Speed := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  Values := Block.GetParam('mJump');
  for Level := 1 to 8 do EngineLevelStats[Level].JumpRange := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  AfterburnerSpeedFactor := ExtractDecimalToSingleW(Block.GetParam('ForsageCoef'));
  Block := LanguageDataConfig.GetBlockByPath('Items.RepairRobot');
  RepairRobotBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mRepair');
  for Level := 1 to 8 do RepairRobotLevelPoints[Level] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.DefGenerator');
  DefGeneratorBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mDef');
  for Level := 1 to 8 do DefGeneratorLevelFactors[Level] := 1 - ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - 1, ','));
  Block := LanguageDataConfig.GetBlockByPath('Items.Radar');
  RadarBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mRadius');
  for Level := 1 to 8 do RadarLevelRanges[Level] := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  Block := LanguageDataConfig.GetBlockByPath('Items.Scaner');
  ScannerBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Block := LanguageDataConfig.GetBlockByPath('Items.CargoHook');
  CargoHookBaseSize := StrToInt(AnsiString(Block.GetParam('AverageSize')));
  Values := Block.GetParam('mMass');
  for Level := 1 to 8 do CargoHookLevelStats[Level].PickupPower := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  Values := Block.GetParam('mRadius');
  for Level := 1 to 8 do CargoHookLevelStats[Level].Range := StrToInt(AnsiString(ExtractDelimitedPartW(Values, Level - 1, ',')));
  Values := Block.GetParam('mSpeedFar');
  for Level := 1 to 8 do CargoHookLevelStats[Level].MinPullSpeed := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - 1, ','));
  Values := Block.GetParam('mSpeedClose');
  for Level := 1 to 8 do CargoHookLevelStats[Level].MaxPullSpeed := ExtractDecimalToSingleW(ExtractDelimitedPartW(Values, Level - 1, ','));
end;
{ @end $7E1FD0 }

{ @routine $7E2B08 LoadWeaponConfiguration }
procedure LoadWeaponConfiguration;
const WeaponTypes = [0..79] - [0..49,68..79];
var
  Level, Index: Integer;
  Block: TBlockParEC;
  Values: WideString;
  Kind, DamageKind: Byte;
begin
  for Index := 1 to CountItemTypesInMask(WeaponTypes) do
  begin
    Kind := GetItemTypeFromMask(WeaponTypes, Index);
    Block := LanguageDataConfig.GetBlockByPath('Items.Weapon.Stats.' + IntToStr(Kind + 1 - 50));
    with WeaponInfos[Kind] do
    begin
      ItemType := TItemType(Kind);
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
      ArcadeWeaponType := Kind;
      Availability := waFree;
      DamageFlags := [];
      Values := Block.GetParam('DamageSet');
      for DamageKind := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
        if not (DamageKind in [Ord(dkDecelerateA), Ord(dkDecelerateAEx), Ord(dkNonLethal)]) and (Pos(WeaponDamageFlagNames[DamageKind], Values) > 0) then
          Include(DamageFlags, TDamageKind(DamageKind));
      ShotType := wstNormal;
      ShotCount := 1;
      Values := Block.GetParam('ShotType');
      if Pos('Normal', Values) > 0 then
      begin
      end
      else if Pos('Splash', Values) > 0 then ShotType := wstSplash
      else if Pos('Exploder', Values) > 0 then ShotType := wstExploder
      else if Pos('AreaDamage', Values) > 0 then ShotType := wstAreaDamage
      else if Pos('Torpedo', Values) > 0 then ShotType := wstTorpedo
      else if Pos('Missile', Values) > 0 then ShotType := wstMissile
      else if Pos('Rocket', Values) > 0 then ShotType := wstRocket
      else if Pos('Chain', Values) > 0 then ShotType := wstChain;
      if ShotType in [wstChain, wstMissile, wstRocket] then ShotCount := ExtractDigitsToIntW(Values);
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
  for Level := 1 to CountItemTypesInMask(WeaponTypes) do
  begin
    Kind := GetItemTypeFromMask(WeaponTypes, Level);
    WeaponInfos[Kind].PrimarySE := 'Weapon.' + IntToStr(Kind - 50);
    WeaponInfos[Kind].SecondarySE := 'Weapon.NoGraph';
    if WeaponInfos[Kind].ShotType in [wstTorpedo, wstMissile, wstRocket] then
      WeaponInfos[Kind].AreaSE := 'Weapon.MissileHit'
    else WeaponInfos[Kind].AreaSE := '';
    WeaponInfos[Kind].DefaultPalette := 0;
    WeaponInfos[Kind].TypeHash := Kind * 171;
  end;
  WeaponInfos[Ord(t_Weapon9)].SecondarySE := 'Weapon.Nine';
  WeaponInfos[Ord(t_Weapon13)].SecondarySE := 'Weapon.12';
  WeaponInfos[Ord(t_Weapon14)].AreaSE := 'Weapon.13';
  WeaponInfos[Ord(t_Weapon1)].InventionIndex := 8;
  WeaponInfos[Ord(t_Weapon2)].InventionIndex := 9;
  WeaponInfos[Ord(t_Weapon3)].InventionIndex := 10;
  WeaponInfos[Ord(t_Weapon4)].InventionIndex := 11;
  WeaponInfos[Ord(t_Weapon5)].InventionIndex := 12;
  WeaponInfos[Ord(t_Weapon6)].InventionIndex := 13;
  WeaponInfos[Ord(t_Weapon7)].InventionIndex := 14;
  WeaponInfos[Ord(t_Weapon8)].InventionIndex := 15;
  WeaponInfos[Ord(t_Weapon9)].InventionIndex := 16;
  WeaponInfos[Ord(t_Weapon10)].InventionIndex := 17;
  WeaponInfos[Ord(t_Weapon11)].InventionIndex := 18;
  WeaponInfos[Ord(t_Weapon12)].InventionIndex := 19;
  WeaponInfos[Ord(t_Weapon13)].InventionIndex := 19;
  WeaponInfos[Ord(t_Weapon14)].InventionIndex := 19;
  WeaponInfos[Ord(t_Weapon15)].InventionIndex := 19;
  WeaponInfos[Ord(t_Weapon16)].InventionIndex := 16;
  WeaponInfos[Ord(t_Weapon17)].InventionIndex := 10;
  WeaponInfos[Ord(t_Weapon18)].InventionIndex := 11;
  WeaponInfos[Ord(t_Weapon13)].Availability := waNotSoldAndNodeRepair;
  WeaponInfos[Ord(t_Weapon14)].Availability := waNotSoldAndNodeRepair;
  WeaponInfos[Ord(t_Weapon15)].Availability := waNotSoldAndNodeRepair;
  WeaponInfos[Ord(t_Weapon16)].Availability := waPirateOnly;
  WeaponInfos[Ord(t_Weapon17)].Availability := waPirateOnly;
  WeaponInfos[Ord(t_Weapon18)].Availability := waPirateOnly;
end;
{ @end $7E2B08 }

{ @routine $7E39B0 LoadMicroModuleConfiguration }
procedure LoadMicroModuleConfiguration;
const WeaponTypes = [0..79] - [0..49] - [68..79];
var
  Block: TBlockParEC;
  Tokens: WideString;
  Index, Position, Part: Integer;
  Value, CustomName: WideString;
  Kind, DamageKind, BonusKind, DamageClass, StationKind: Byte;
  BlockIndices: array of Integer;
  SortKeys: array of Integer;

  // @nested $7E376C ReadMicroModuleParam
  function ReadMicroModuleParam(ParamName: WideString): WideString; // @addr $7E376C @ida "void __usercall $name(unsigned __int16 *ParamName@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @note "Nested in LoadMicroModuleConfiguration; reads its current Block through the caller-popped static link."
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

  // @nested $7E3920 ConsumeMicroModuleToken
  function ConsumeMicroModuleToken(Token: WideString): Boolean; // @addr $7E3920 @ida "bool __usercall $name@<al>(unsigned __int16 *Token@<eax>, void *ParentFrame@<^0>);" @note "Nested in LoadMicroModuleConfiguration; removes every occurrence of Token from its remaining-token string."
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
        else if BonusKind in [Ord(bonExtraAkrinEff), Ord(bonExtraAkrinPenalty)] then StatBonuses[BonusKind] := Round(ExtractDecimalToSingleW(Value) * 100)
        else StatBonuses[BonusKind] := StrToInt(AnsiString(Value));
      end;
      Value := ReadMicroModuleParam('Cost');
      if Value = '' then CostPercent := 100 else CostPercent := StrToInt(AnsiString(Value));
      Value := ReadMicroModuleParam('Size');
      if Value = '' then SizePercent := 100 else SizePercent := StrToInt(AnsiString(Value));
      Value := ReadMicroModuleParam('Fragility');
      if Value = '' then FragilityFactor := 1 else FragilityFactor := StrToInt(AnsiString(Value)) * 0.01;
      for DamageClass := 0 to 2 do
      begin
        Value := ReadMicroModuleParam('Fragility' + WeaponDamageClasses[DamageClass].Name);
        if Value = '' then FragilityFactorByDamageClass[DamageClass] := FragilityFactor
        else FragilityFactorByDamageClass[DamageClass] := StrToInt(AnsiString(Value)) * 0.01;
      end;
      Value := ReadMicroModuleParam('Owner');
      if (Value = '') or (Value = 'Any') then
      begin
        if SpecialOnly then TOwnerMask(AllowedHullOwnerMask) := [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]
        else TOwnerMask(AllowedHullOwnerMask) := [Ord(oiMaloc)..Ord(oiDominator), Ord(oiPirate)];
        TDominatorSeriesMask(AllowedDominatorSeriesMask) := [Ord(dsBlazer)..Ord(dsTerron)];
        AllowedCustomHullFactions := '';
      end
      else
      begin
        TOwnerMask(AllowedHullOwnerMask) := [];
        TDominatorSeriesMask(AllowedDominatorSeriesMask) := [];
        Tokens := ReplaceAllWideString(Value, ' ', '');
        Tokens := '<' + ReplaceAllWideString(Tokens, ',', '>,<') + '>';
        if ConsumeMicroModuleToken('<Maloc>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiMaloc));
        if ConsumeMicroModuleToken('<Peleng>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiPeleng));
        if ConsumeMicroModuleToken('<People>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiHuman));
        if ConsumeMicroModuleToken('<Fei>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiFeyan));
        if ConsumeMicroModuleToken('<Gaal>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiGaal));
        if ConsumeMicroModuleToken('<PirateClan>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiPirate));
        if ConsumeMicroModuleToken('<None>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiUninhabited));
        if SpecialOnly then
        begin
          if ConsumeMicroModuleToken('<Kling>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiDominator));
          ConsumeMicroModuleToken('<NonKling>');
        end
        else
        begin
          if not ConsumeMicroModuleToken('<NonKling>') then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiDominator));
          ConsumeMicroModuleToken('<Kling>');
        end;
        if ConsumeMicroModuleToken('<Blazer>') then
        begin
          Include(TDominatorSeriesMask(AllowedDominatorSeriesMask), Ord(dsBlazer));
          if SpecialOnly then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiDominator));
        end;
        if ConsumeMicroModuleToken('<Terron>') then
        begin
          Include(TDominatorSeriesMask(AllowedDominatorSeriesMask), Ord(dsTerron));
          if SpecialOnly then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiDominator));
        end;
        if ConsumeMicroModuleToken('<Keller>') then
        begin
          Include(TDominatorSeriesMask(AllowedDominatorSeriesMask), Ord(dsKeller));
          if SpecialOnly then Include(TOwnerMask(AllowedHullOwnerMask), Ord(oiDominator));
        end;
        if TDominatorSeriesMask(AllowedDominatorSeriesMask) = [] then TDominatorSeriesMask(AllowedDominatorSeriesMask) := [Ord(dsBlazer)..Ord(dsTerron)];
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
        TItemTypeSelection(AllowedItemTypes) := [Ord(t_Hull)..Ord(t_CustomWeapon)];
        AllowedCustomWeaponTypes := 'Any';
      end
      else
      begin
        TItemTypeSelection(AllowedItemTypes) := [];
        AllowedCustomWeaponTypes := '';
        Tokens := ReplaceAllWideString(Value, ' ', '');
        Tokens := '<' + ReplaceAllWideString(Tokens, ',', '>,<') + '>';
        if ConsumeMicroModuleToken('<Hull>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_Hull));
        if ConsumeMicroModuleToken('<FuelTank>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_FuelTanks));
        if ConsumeMicroModuleToken('<Engine>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_Engine));
        if ConsumeMicroModuleToken('<Radar>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_Radar));
        if ConsumeMicroModuleToken('<Scaner>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_Scaner));
        if ConsumeMicroModuleToken('<Droid>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_RepairRobot));
        if ConsumeMicroModuleToken('<Hook>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_CargoHook));
        if ConsumeMicroModuleToken('<DefGenerator>') then Include(TItemTypeSelection(AllowedItemTypes), Ord(t_DefGenerator));
        for Part := 1 to CountItemTypesInMask(WeaponTypes) do
        begin
          Kind := GetItemTypeFromMask([Ord(t_Food)..79] - [Ord(t_Food)..Ord(t_DefGenerator)] - [Ord(t_CustomWeapon)..79], Part);
          if ConsumeMicroModuleToken('<' + ItemTypeNames[Kind] + '>') then
            Include(TItemTypeSelection(AllowedItemTypes), Kind)
          else if (Pos('<WMissile>', Tokens) > 0) and (dkMissile in WeaponInfos[Kind].DamageFlags) then
            Include(TItemTypeSelection(AllowedItemTypes), Kind)
          else if (Pos('<WSplinter>', Tokens) > 0) and (dkSplinter in WeaponInfos[Kind].DamageFlags) then
            Include(TItemTypeSelection(AllowedItemTypes), Kind)
          else if (Pos('<WEnergy>', Tokens) > 0) and (dkEnergy in WeaponInfos[Kind].DamageFlags) then
            Include(TItemTypeSelection(AllowedItemTypes), Kind);
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
      TShipTypeMask(OfferStationTypes) := [];
      OfferStationNames := ReplaceAllWideString(Value, ' ', '');
      OfferStationNames := '<' + ReplaceAllWideString(OfferStationNames, ',', '>,<') + '>';
      if Value = 'Any' then TShipTypeMask(OfferStationTypes) := [Ord(rstRangerCenter)..Ord(rstDominion)]
      else if Value <> '' then
        for StationKind := Ord(rstRangerCenter) to Ord(rstDominion) do
          if Pos(ShipTypeNames[StationKind].Name, Value) > 0 then Include(TShipTypeMask(OfferStationTypes), StationKind);
      OnPlanets := ExtractDigitsToIntW(ReadMicroModuleParam('OnPlanets')) <> 0;
      Value := ReadMicroModuleParam('WeaponMods');
      TDamageFlagSet(WeaponDamageFlags) := [];
      if Value <> '' then
        for DamageKind := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
          if not (DamageKind in [Ord(dkEnergy)..Ord(dkMissile)]) and not (DamageKind in [Ord(dkDecelerateA), Ord(dkDecelerateAEx), Ord(dkNonLethal)]) and (Pos(WeaponDamageFlagNames[DamageKind], Value) > 0) then
            Include(TDamageFlagSet(WeaponDamageFlags), TDamageKind(DamageKind));
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
{ @end $7E39B0 }

{ @routine $7E5054 InitializeCaptainHealthDefinitions }
procedure InitializeCaptainHealthDefinitions;
var I: Integer; Path, Value: WideString;
begin
  CaptainHealthDefinitions[1].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[1].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[1].AllowedRatingBands := [2, 3, 4, 5];
  CaptainHealthDefinitions[1].AllowedRanks := [2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[1].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[1].EffectClass0D := 2;
  CaptainHealthDefinitions[1].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[1].InfectionChance := 1.0;
  CaptainHealthDefinitions[1].Locations := [3];
  CaptainHealthDefinitions[1].Duration := 150;
  CaptainHealthDefinitions[2].AllowedLocationOwners := [1];
  CaptainHealthDefinitions[2].AllowedOwners := [1, 2, 3, 4];
  CaptainHealthDefinitions[2].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[2].AllowedRanks := [3, 4, 5];
  CaptainHealthDefinitions[2].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[2].EffectClass0D := 4;
  CaptainHealthDefinitions[2].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[2].InfectionChance := 1.0;
  CaptainHealthDefinitions[2].Locations := [0];
  CaptainHealthDefinitions[2].Duration := 555;
  CaptainHealthDefinitions[3].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[3].AllowedOwners := [0, 1, 2];
  CaptainHealthDefinitions[3].AllowedRatingBands := [3, 4, 5];
  CaptainHealthDefinitions[3].AllowedRanks := [3, 4, 5, 6, 7];
  CaptainHealthDefinitions[3].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[3].EffectClass0D := 3;
  CaptainHealthDefinitions[3].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[3].InfectionChance := 1.0;
  CaptainHealthDefinitions[3].Locations := [3];
  CaptainHealthDefinitions[3].Duration := 200;
  CaptainHealthDefinitions[4].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[4].AllowedOwners := [1, 2, 3, 4];
  CaptainHealthDefinitions[4].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[4].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[4].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[4].EffectClass0D := 5;
  CaptainHealthDefinitions[4].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[4].InfectionChance := 1.0;
  CaptainHealthDefinitions[4].Locations := [2];
  CaptainHealthDefinitions[4].Duration := 1000;
  CaptainHealthDefinitions[5].AllowedLocationOwners := [4];
  CaptainHealthDefinitions[5].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[5].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[5].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[5].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[5].EffectClass0D := 1;
  CaptainHealthDefinitions[5].DevelopmentRate := 10.0;
  CaptainHealthDefinitions[5].InfectionChance := 1.0;
  CaptainHealthDefinitions[5].Locations := [0, 1];
  CaptainHealthDefinitions[5].Duration := 170;
  CaptainHealthDefinitions[6].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[6].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[6].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[6].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[6].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[6].EffectClass0D := 4;
  CaptainHealthDefinitions[6].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[6].InfectionChance := 1.0;
  CaptainHealthDefinitions[6].Locations := [];
  CaptainHealthDefinitions[6].Duration := 1000;
  CaptainHealthDefinitions[7].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[7].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[7].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[7].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[7].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[7].EffectClass0D := 2;
  CaptainHealthDefinitions[7].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[7].InfectionChance := 1.0;
  CaptainHealthDefinitions[7].Locations := [3];
  CaptainHealthDefinitions[7].Duration := 130;
  CaptainHealthDefinitions[8].AllowedLocationOwners := [1, 2, 3, 4];
  CaptainHealthDefinitions[8].AllowedOwners := [1, 2, 3, 4];
  CaptainHealthDefinitions[8].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[8].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[8].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[8].EffectClass0D := 1;
  CaptainHealthDefinitions[8].DevelopmentRate := 100.0;
  CaptainHealthDefinitions[8].InfectionChance := 1.0;
  CaptainHealthDefinitions[8].Locations := [3];
  CaptainHealthDefinitions[8].Duration := 100;
  CaptainHealthDefinitions[9].AllowedLocationOwners := [0];
  CaptainHealthDefinitions[9].AllowedOwners := [0];
  CaptainHealthDefinitions[9].AllowedRatingBands := [2, 3, 4, 5];
  CaptainHealthDefinitions[9].AllowedRanks := [2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[9].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[9].EffectClass0D := 2;
  CaptainHealthDefinitions[9].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[9].InfectionChance := 1.0;
  CaptainHealthDefinitions[9].Locations := [0, 1, 2];
  CaptainHealthDefinitions[9].Duration := 180;
  CaptainHealthDefinitions[10].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[10].AllowedOwners := [1];
  CaptainHealthDefinitions[10].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[10].AllowedRanks := [1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[10].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[10].EffectClass0D := 2;
  CaptainHealthDefinitions[10].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[10].InfectionChance := 1.0;
  CaptainHealthDefinitions[10].Locations := [0, 1, 2];
  CaptainHealthDefinitions[10].Duration := 122;
  CaptainHealthDefinitions[11].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[11].AllowedOwners := [3];
  CaptainHealthDefinitions[11].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[11].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[11].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[11].EffectClass0D := 4;
  CaptainHealthDefinitions[11].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[11].InfectionChance := 1.0;
  CaptainHealthDefinitions[11].Locations := [0, 1];
  CaptainHealthDefinitions[11].Duration := 164;
  CaptainHealthDefinitions[12].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[12].AllowedOwners := [4];
  CaptainHealthDefinitions[12].AllowedRatingBands := [2, 3, 4, 5];
  CaptainHealthDefinitions[12].AllowedRanks := [2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[12].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[12].EffectClass0D := 2;
  CaptainHealthDefinitions[12].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[12].InfectionChance := 0.5;
  CaptainHealthDefinitions[12].Locations := [0, 1, 2];
  CaptainHealthDefinitions[12].Duration := 88;
  RadiationHealthDefinitions[1].AllowedLocationOwners := [0, 1, 2, 3, 4];
  RadiationHealthDefinitions[1].AllowedOwners := [0, 1, 2, 3, 4];
  RadiationHealthDefinitions[1].AllowedRatingBands := [1, 2, 3, 4, 5];
  RadiationHealthDefinitions[1].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  RadiationHealthDefinitions[1].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  RadiationHealthDefinitions[1].EffectClass0D := 4;
  RadiationHealthDefinitions[1].DevelopmentRate := 100.0;
  RadiationHealthDefinitions[1].InfectionChance := 0.0;
  RadiationHealthDefinitions[1].Locations := [];
  RadiationHealthDefinitions[1].Duration := 30;
  CaptainHealthDefinitions[13].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[13].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[13].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[13].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[13].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[13].EffectClass0D := 2;
  CaptainHealthDefinitions[13].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[13].InfectionChance := 0.9;
  CaptainHealthDefinitions[13].Duration := 140;
  CaptainHealthDefinitions[14].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[14].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[14].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[14].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[14].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[14].EffectClass0D := 2;
  CaptainHealthDefinitions[14].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[14].InfectionChance := 0.9;
  CaptainHealthDefinitions[14].Duration := 130;
  CaptainHealthDefinitions[15].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[15].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[15].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[15].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[15].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[15].EffectClass0D := 2;
  CaptainHealthDefinitions[15].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[15].InfectionChance := 0.8;
  CaptainHealthDefinitions[15].Duration := 140;
  CaptainHealthDefinitions[16].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[16].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[16].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[16].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[16].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[16].EffectClass0D := 2;
  CaptainHealthDefinitions[16].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[16].InfectionChance := 0.4;
  CaptainHealthDefinitions[16].Duration := 120;
  CaptainHealthDefinitions[17].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[17].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[17].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[17].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[17].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[17].EffectClass0D := 2;
  CaptainHealthDefinitions[17].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[17].InfectionChance := 0.9;
  CaptainHealthDefinitions[17].Duration := 90;
  CaptainHealthDefinitions[18].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[18].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[18].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[18].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[18].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[18].EffectClass0D := 2;
  CaptainHealthDefinitions[18].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[18].InfectionChance := 0.8;
  CaptainHealthDefinitions[18].Duration := 300;
  CaptainHealthDefinitions[19].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[19].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[19].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[19].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[19].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[19].EffectClass0D := 2;
  CaptainHealthDefinitions[19].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[19].InfectionChance := 0.9;
  CaptainHealthDefinitions[19].Duration := 140;
  CaptainHealthDefinitions[20].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[20].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[20].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[20].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[20].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[20].EffectClass0D := 2;
  CaptainHealthDefinitions[20].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[20].InfectionChance := 0.9;
  CaptainHealthDefinitions[20].Duration := 200;
  CaptainHealthDefinitions[21].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[21].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[21].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[21].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[21].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[21].EffectClass0D := 2;
  CaptainHealthDefinitions[21].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[21].InfectionChance := 0.9;
  CaptainHealthDefinitions[21].Duration := 200;
  CaptainHealthDefinitions[22].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[22].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[22].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[22].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[22].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[22].EffectClass0D := 2;
  CaptainHealthDefinitions[22].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[22].InfectionChance := 0.25;
  CaptainHealthDefinitions[22].Duration := 150;
  CaptainHealthDefinitions[23].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[23].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[23].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[23].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[23].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[23].EffectClass0D := 2;
  CaptainHealthDefinitions[23].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[23].InfectionChance := 0.15;
  CaptainHealthDefinitions[23].Duration := 90;
  CaptainHealthDefinitions[24].AllowedLocationOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[24].AllowedOwners := [0, 1, 2, 3, 4];
  CaptainHealthDefinitions[24].AllowedRatingBands := [1, 2, 3, 4, 5];
  CaptainHealthDefinitions[24].AllowedRanks := [0, 1, 2, 3, 4, 5, 6, 7];
  CaptainHealthDefinitions[24].AllowedCareers := [Ord(rcTrader), Ord(rcPirate), Ord(rcWarrior)];
  CaptainHealthDefinitions[24].EffectClass0D := 2;
  CaptainHealthDefinitions[24].DevelopmentRate := 1.0;
  CaptainHealthDefinitions[24].InfectionChance := 0.2;
  CaptainHealthDefinitions[24].Duration := 120;
  for I := 1 to 12 do
    with CaptainHealthDefinitions[I] do
    begin
      Path := 'Illness.Illness.' + IntToStr(I - 1);
      Name := LocalizedText(Path + '.Name');
      Text := LocalizedText(Path + '.Text');
      Disabled := False;
      Value := LocalizedText(Path + '.Time');
      if Value <> '' then Duration := StrToInt(AnsiString(Value));
    end;
  for I := 1 to 1 do
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
{ @end $7E5054 }

{ @routine $7E60F8 LoadHullSeriesConfiguration }
procedure LoadHullSeriesConfiguration;
var
  Block: TBlockParEC;
  Index, Position, Temp: Integer;
  Value: WideString;
  DamageKind: Byte;
  BlockIndices: array of Integer;
  SortKeys: array of Integer;

  // @nested $7E5F44 ReadHullSeriesParam
  function ReadHullSeriesParam(ParamName: WideString): WideString; // @addr $7E5F44 @ida "void __usercall $name(unsigned __int16 *ParamName@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @note "Nested in LoadHullSeriesConfiguration; reads its current Block through the caller-popped static link."
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
      if (Value = '') or (Value = 'Any') then AllowedOwners := [0..4]
      else
      begin
        if Pos('Maloc', Value) > 0 then Include(AllowedOwners, 0);
        if Pos('Peleng', Value) > 0 then Include(AllowedOwners, 1);
        if Pos('People', Value) > 0 then Include(AllowedOwners, 2);
        if Pos('Fei', Value) > 0 then Include(AllowedOwners, 3);
        if Pos('Gaal', Value) > 0 then Include(AllowedOwners, 4);
      end;
      Value := ReadHullSeriesParam('ShipType');
      AllowedShipTypes := [];
      if (Value = '') or (Value = 'Any') then AllowedShipTypes := [htRanger..htDiplomat]
      else
      begin
        if Pos('Transport', Value) > 0 then Include(AllowedShipTypes, htTransport);
        if Pos('Liner', Value) > 0 then Include(AllowedShipTypes, htLiner);
        if Pos('Diplomat', Value) > 0 then Include(AllowedShipTypes, htDiplomat);
        if Pos('Ranger', Value) > 0 then Include(AllowedShipTypes, htRanger);
        if Pos('Pirate', Value) > 0 then Include(AllowedShipTypes, htPirate);
        if Pos('Warrior', Value) > 0 then Include(AllowedShipTypes, htWarrior);
        if Pos('Flagman', Value) > 0 then Include(AllowedShipTypes, htFlagship);
      end;
      SlotBonuses[0] := 0;
      SlotBonuses[1] := 0;
      SlotBonuses[10] := 0;
      Value := ReadHullSeriesParam('Radar');
      if Value = '' then SlotBonuses[2] := 0
      else SlotBonuses[2] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Scaner');
      if Value = '' then SlotBonuses[3] := 0
      else SlotBonuses[3] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Droid');
      if Value = '' then SlotBonuses[4] := 0
      else SlotBonuses[4] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Hook');
      if Value = '' then SlotBonuses[5] := 0
      else SlotBonuses[5] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Def');
      if Value = '' then SlotBonuses[6] := 0
      else SlotBonuses[6] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Weapon');
      if Value = '' then SlotBonuses[7] := 0
      else SlotBonuses[7] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Artefact');
      if Value = '' then SlotBonuses[8] := 0
      else SlotBonuses[8] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Forsage');
      if Value = '' then SlotBonuses[9] := 0
      else SlotBonuses[9] := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Size');
      if Value = '' then SizePercent := 100
      else SizePercent := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Cost');
      if Value = '' then CostPercent := 100
      else CostPercent := StrToInt(AnsiString(Value));
      Value := ReadHullSeriesParam('Fragility');
      if Value = '' then FragilityFactor := 1
      else FragilityFactor := StrToInt(AnsiString(Value)) * 0.01;
      for DamageKind := 0 to 2 do
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
{ @end $7E60F8 }

{ @routine $7E6E70 IncrementWordSaturating }
procedure IncrementWordSaturating(var Value: Word);
begin
  if Value < High(Word) then Inc(Value);
end;
{ @end $7E6E70 }

{ @routine $7E6E8C PickRandomItemType }
function PickRandomItemType(Mask: TItemTypeSelection): Byte;
var
  ItemType: Byte;
  Count: Integer;
begin
  Count := 0;
  for ItemType := Ord(Low(TItemType)) to Ord(High(TItemType)) do
    if ItemType in Mask then Inc(Count);
  Count := RandomIntRange(1, Count);
  for ItemType := Ord(Low(TItemType)) to Ord(High(TItemType)) do
    if ItemType in Mask then
    begin
      Dec(Count);
      if Count = 0 then Break;
    end;
  Result := ItemType;
end;
{ @end $7E6E8C }

{ @routine $7E6F08 PickRandomItemTypeFromSeed }
function PickRandomItemTypeFromSeed(Mask: TItemTypeSelection; var Seed: Cardinal): Byte;
var
  ItemType: Byte;
  Count: Integer;
begin
  Count := 0;
  for ItemType := Ord(Low(TItemType)) to Ord(High(TItemType)) do
    if ItemType in Mask then Inc(Count);
  Count := NextRandomIntRange(1, Count, Seed);
  for ItemType := Ord(Low(TItemType)) to Ord(High(TItemType)) do
    if ItemType in Mask then
    begin
      Dec(Count);
      if Count = 0 then Break;
    end;
  Result := ItemType;
end;
{ @end $7E6F08 }

{ @routine $7E6F8C CountItemTypesInMask }
function CountItemTypesInMask(Mask: TItemTypeSelection): Integer;
var
  ItemType: Byte;
  Count: Integer;
begin
  Count := 0;
  for ItemType := Ord(Low(TItemType)) to Ord(High(TItemType)) do
    if ItemType in Mask then Inc(Count);
  Result := Count;
end;
{ @end $7E6F8C }

{ @routine $7E6FD4 GetItemTypeFromMask }
function GetItemTypeFromMask(Mask: TItemTypeSelection; Index: Integer): Byte;
var
  ItemType: Byte;
  Count: Integer;
begin
  Count := 0;
  Result := 0;
  for ItemType := Ord(Low(TItemType)) to Ord(High(TItemType)) do
  begin
    if ItemType in Mask then Inc(Count);
    if Count = Index then
    begin
      Result := ItemType;
      Exit;
    end;
  end;
end;
{ @end $7E6FD4 }

{ @routine $7E702C ClassifyWeaponDamageFlags }
function ClassifyWeaponDamageFlags(Flags: TDamageFlagSet): TWeaponDamageClass;
begin
  if dkMissile in Flags then Result := wdcMissile
  else if dkSplinter in Flags then Result := wdcSplinter
  else Result := wdcEnergy;
end;
{ @end $7E702C }

end.
