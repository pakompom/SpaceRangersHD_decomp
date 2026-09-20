unit aGalaxyStruct;

interface

uses Windows;

const
  // TShip.TypeId names from ShipTypeNames at $87D038 (initialized by the table
  // at $838040) and the subclass initializers.
  // These are distinct from the hull-generation codes returned by ShipToHullType.
  stKling = 0;
  stRanger = 1;
  stTransport = 2;
  stPirate = 3;
  stWarrior = 4;
  stTranclucator = 5;

  // CurrentStanding categories: native GetControlPresence ($7C2538),
  // ResetControlFaction ($7C3B8C), and subclass RefreshCurrentStanding methods.
  // The companion ShipStanding reference uses CoalMilitary/Active/Passive and
  // PirateMilitary/Active/Passive for the same IDs. Keep the stored Byte ABI.
  ssDominator = 0;
  ssUnaligned = 1;
  ssCoalitionMilitary = 2;
  ssCoalitionActive = 3;
  ssCoalitionPassive = 4;
  ssNeutral = 5;
  ssPiratePassive = 6;
  ssPirateActive = 7;
  ssPirateMilitary = 8;
  ssCustom = 9;

  // GetScriptStandingOverrideMode ($77E854); its SubFaction test is preserved.
  ssmNormal = 0;
  ssmCustomFaction = 1;
  ssmFixed = 2;

  // Greeting category bits from InitializeShipGreetingDefinitions ($52E9B4) and
  // TShip virtual slot $30. Transport subtypes and pirate allegiance have
  // separate greeting categories; these values are distinct from TypeId.
  gscTransport = 0;
  gscLiner = 1;
  gscDiplomat = 2;
  gscRanger = 3;
  gscPirate = 4;
  gscWarrior = 5;
  gscKling = 6;
  gscPirateClan = 7;

  // Hull categories from ShipToHullType ($82F1F4), GetDefaultHullType ($74F294),
  // and ApplySpecialMicroModule ($8089D8). They are not TShip.TypeId values.
  htRanger = 0;
  htWarrior = 1;
  htPirate = 2;
  htTransport = 3;
  htLiner = 4;
  htDiplomat = 5;
  htKling = 6;
  htTranclucator = 7;
  htStation = 8;
  htSpecial = 9;
  htFlagship = 10;

  // ProgramNames at $87F5E4 (initializer descriptors $838044..$8380A0).
  // Used by ranger inventory, Dominator effects, and script prog* identifiers.
  prgKellerCall = 0;
  prgLogicalNegation = 1;
  prgDematerial = 2;
  prgEnergotron = 3;
  prgSabCrack = 4;
  prgIntercom = 5;
  prgShipwreck = 6;
  prgWeaponBlocking = 7;
  prgInsanity = 8;
  prgShock = 9;
  prgSelfDestruction = 10;
  prgDisconnection = 11;

  // CoalitionProjectNames ($87F584), investment dispatch ($5C6FBC/$5CA654),
  // and the military-base war operation ($5BD528) share these cooldown indices.
  cpCreateRangerCenter = 0;
  cpCreatePirateBase = 1;
  cpCreateMilitaryBase = 2;
  cpCreateScienceBase = 3;
  cpCreateBusinessCenter = 4;
  cpCreateMedicalBase = 5;
  cpRangersSubsidy = 6;
  cpPiratesSubsidy = 7;
  cpTransportSubsidy = 8;
  cpLostSubsidy = 9;
  cpWarSubsidy = 10;
  cpWarOperation = 11;

  // Conversation IDs shared by ShowPlayerDialogue ($777284),
  // TfTalk.BuildBuiltinChoices ($6D5048), and script Talk* constants.
  tkMoneyDemand = 0;
  tkGoodsDemand = 1;
  tkTruceOffer = 2;
  tkAttack = 3;
  tkPartnerBreak = 4;
  tkPartnerEnd = 5;
  tkPartnerRiot = 6;

  // Award categories from SysToReward ($82EA40); SelectAward returns $FF on failure.
  atLiberation = 0;
  atAccomplishment = 1;
  atSecretMission = 2;
  atCowardice = 3;
  atPerfidy = 4;
  atPlanetBattle = 5;
  AwardNotFound = $FF;

type
  TPercent = 0..100;
  TProgramIndex = 0..11;

  TGreetingCountMask = set of 0..15; // @size $02 Shared greeting count buckets; bit 10 is Many/Far where supported.

  // Shared scalar configuration identifiers. Managed configuration records live in aConst.

  TWeaponShotType = (
    wstNormal = 0,
    wstChain = 1,
    wstSplash = 2,
    wstExploder = 3,
    wstAreaDamage = 4,
    wstTorpedo = 5,
    wstMissile = 6,
    wstRocket = 7
  ); // @size 0x1

  TShipTypeMask = set of 0..15; // @size $02 Shared ship/station type bits. DCU alignment is visible in CheatRndbase.

  TWeaponAvailabilityMask = set of 0..15; // @size 2

  TWeaponAvailability = (
    waFree = 0,
    waCoalitionOnly = 1,
    waPirateOnly = 2,
    waNotSold = 3,
    waNotSoldAndNodeRepair = 4,
    waMalocOnly = 5,
    waPelengOnly = 6,
    waPeopleOnly = 7,
    waFeiOnly = 8,
    waGaalOnly = 9,
    waSystemOnly = 10
  ); // @size 0x1


  TStationType = (
    rstRangerCenter = 6,
    rstPirateBase = 7,
    rstMilitaryBase = 8,
    rstScienceBase = 9,
    rstBusinessCenter = 10,
    rstMedicalBase = 11,
    rstDominion = 12,
    rstCustomStation = 13
  ); // @size 0x1

  TKlingType = (
    ktBoss = 0, ktEquentor = 1, ktUrgant = 2, ktSmersh = 3,
    ktMenok = 4, ktShtip = 5, ktBertor = 6, ktKlig = 7
  ); // @size 0x1

  // Shared ship career category; non-ranger implementations can return a fixed career.
  TRangerCareer = (rcTrader = 0, rcPirate = 1, rcWarrior = 2); // @size 0x1
  TRangerCareerSet = set of TRangerCareer; // @size 0x1

  TGalaxyDifficultyIndex = 0..7;
  TGalaxyDifficultyLevels = array[0..7] of Byte;

  TPlanetEconomy = (peAgricultural = 0, peMixed = 1, peIndustrial = 2); // @size 0x1
  TPlanetGovernment = (
    pgAnarchy = 0, pgDictatorship = 1, pgMonarchy = 2,
    pgRepublic = 3, pgDemocracy = 4
  ); // @size 0x1
  TShopUpdateMode = (
    sumNormal = 0, sumDisabled = 1, sumEquipmentOnly = 2, sumGoodsOnly = 3
  ); // @size 0x1
  TStarFaction = (sfCoalition = 0, sfDominators = 1, sfPirates = 2); // @size 0x1

  // Raw saved settings. Accessors apply defaults when Enabled is false.
  // Most modifier bytes encode 0.5 + value / 16, rather than percentages.
  TGalaxyCustomRules = packed record // @size 0x27
    Enabled: Boolean; // @offset 0x00
    DominatorStrength: Byte; // @offset 0x01
    DominatorAggression: Byte; // @offset 0x02
    DominatorSpawn: Byte; // @offset 0x03
    PirateAggression: Byte; // @offset 0x04
    CoalitionAggression: Byte; // @offset 0x05
    AsteroidModifier: Byte; // @offset 0x06
    SunDamageModifier: Byte; // @offset 0x07
    ExtraInventions: Byte; // @offset 0x08
    AcrynModifier: Byte; // @offset 0x09
    NodeDropModifier: Byte; // @offset 0x0A
    ArcadeDropValueModifier: Byte; // @offset 0x0B
    DropValueModifier: Byte; // @offset 0x0C
    AgriculturalPlanetWeight: Byte; // @offset 0x0D  If all three economy weights are zero, their getters return one each.
    MixedPlanetWeight: Byte; // @offset 0x0E
    IndustrialPlanetWeight: Byte; // @offset 0x0F
    ExtraRangers: Byte; // @offset 0x10
    ArcadeHitpointsModifier: Byte; // @offset 0x11
    ArcadeDamageModifier: Byte; // @offset 0x12
    AIJunkTolerance: Byte; // @offset 0x13
    ChaoticRandom: Boolean; // @offset 0x14
    UnrestrictedEquipmentKnowledge: Boolean; // @offset 0x15
    StationsNearStars: Boolean; // @offset 0x16
    FullStationTargeting: Boolean; // @offset 0x17
    SpecialShips: Boolean; // @offset 0x18
    ZeroStartingExperience: Boolean; // @offset 0x19
    ArcadeBattleRoyale: Boolean; // @offset 0x1A
    DominatorRacialWeapons: Boolean; // @offset 0x1B
    StartInCenter: Boolean; // @offset 0x1C
    MaxRangeMissiles: Boolean; // @offset 0x1D
    OldHyperspace: Boolean; // @offset 0x1E
    PirateNodes: Boolean; // @offset 0x1F
    AIUseShops: Boolean; // @offset 0x20
    StationsUseShop: Boolean; // @offset 0x21
    DuplicateArtefacts: Boolean; // @offset 0x22
    HullGrowth: Byte; // @offset 0x23
    ArcadeEquipmentChange: Boolean; // @offset 0x24
    OldSpeedCalculation: Boolean; // @offset 0x25
    OldMissileBonuses: Boolean; // @offset 0x26
  end;

  // Prices are from the visiting ship's perspective.
  TGoodsTradePriceEntry = packed record // @size 0x10
    Count: Integer; // @offset 0x00
    PriceState: Single; // @offset 0x04
    PurchasePrice: Integer; // @offset 0x08
    BaseSalePrice: Integer; // @offset 0x0C  Before the ship's Trading skill bonus.
  end;
  PGoodsTradePriceEntry = ^TGoodsTradePriceEntry;

  TGoodsTextOrder = array[0..7] of Byte;
  PGoodsTextOrder = ^TGoodsTextOrder;
  TDominatorSeriesNameTable = array[0..2] of WideString;
  PDominatorSeriesNameTable = ^TDominatorSeriesNameTable;
  // Native record RTTI at $82A354.

  TEngineLevelStats = record // @size $04
    Speed: Word; // @offset $00
    JumpRange: ShortInt; // @offset $02
  end;
  TEngineLevelStatsTable = array[1..8] of TEngineLevelStats;

  TCargoHookLevelStats = record // @size $10
    PickupPower: Integer; // @offset $00
    Range: Integer; // @offset $04
    MinPullSpeed: Single; // @offset $08
    MaxPullSpeed: Single; // @offset $0C
  end;
  TCargoHookLevelStatsTable = array[1..8] of TCargoHookLevelStats;

  // The script singleton constructor proves an enum spanning three bytes.
  // Four-byte masks use bits 0..20; the exact enum upper bound within 19..23 is unresolved.
  // Other enumerator names remain unknown. Bit 19 blocks the repair droid in TShip.ApplyDamage.
  TDamageKind = (dkEnergy = 0, dkSplinter = 1, dkMissile = 2, dkDroidBlock = 19); // @size 1
  TDamageFlagSet = set of TDamageKind; // @size 4 Named sets are rounded to four bytes by DCC32.

const
  // Semantic aliases follow WeaponDamageFlagNames at $87F350 and the native
  // TShip.ApplyDamage handlers. They do not claim original enum RTTI names.
  // Keep the enum bounds and four-byte set ABI above unchanged.
  dkDecelerate = TDamageKind(3);
  dkDestruct = TDamageKind(4);
  dkDrain = TDamageKind(5);
  dkShock = TDamageKind(6);
  dkAcid = TDamageKind(7);
  dkMagnetic = TDamageKind(8);
  dkDecelerateA = TDamageKind(9);
  dkDecelerateAEx = TDamageKind(10);
  dkUndefendable = TDamageKind(11);
  dkNonLethal = TDamageKind(12);
  dkScanBonus = TDamageKind(13);
  dkBonusToDamaged = TDamageKind(14);
  dkMoreDrop = TDamageKind(15);
  dkDropCargo = TDamageKind(16);
  dkReduceEngine = TDamageKind(17);
  dkBlockWeapon = TDamageKind(18);
  // Bit 20 fixes minimum damage at the maximum (TShip.GetWeaponMinDamage).
  DamageNoDeltaMask = 1 shl 20;

  // Loading this four-byte set from the DCU keeps it distinct from float zero.
  // The native aShip pools at $762814/$762814 and $7695DC/$7695DC are separate.
  EmptyDamageFlags = [dkEnergy..dkDroidBlock] - [dkEnergy..dkDroidBlock];

type

  TItemTypeMask = set of 0..79; // @size 10

  // OwnerToSys ($82E4EC) and RaceToSys ($82DED4) establish these IDs.
  // RaceId and PilotRace use the same Coalition values 0..4.
  TOwnerIndex = 0..7;

  TOwnerId = (oiMaloc = 0, oiPeleng = 1, oiHuman = 2, oiFeyan = 3,
    oiGaal = 4, oiDominator = 5, oiUninhabited = 6, oiPirate = 7); // @size $01 OwnerInfo and native planet/ship owner numbering.

  TPlanetGoodsFactors = record // @size 0x10
    PriceFactor: Double; // @offset 0x00
    StockFactor: Double; // @offset 0x08
  end;
  TPlanetRaceMarketInfo = record // @size 0xA8
    InventionProgressScale: Single; // @offset 0x00  Used by TPlanet.CalculateInventionProgressRate.
    InitialInventionBoostCount: Integer; // @offset 0x04
    GoodsFactors: array[0..7] of TPlanetGoodsFactors; // @offset 0x08
    GovernmentRollThresholds: array[0..4] of Byte; // @offset 0x88  Cumulative thresholds indexed by TPlanetGovernment.
    RevolutionChance: Single; // @offset 0x90
    FriendlyRelationScale: Single; // @offset $94 Scales transport-to-transport relations ($720764) and partner-gift gains ($6DD9D8/$6E1A8C).
    PirateRelationFactor: Single; // @offset 0x98  Multiplies owner-table relations for pirates at Coalition planets.
    UnknownFactor9C: Single; // @offset $9C Native race factor; gameplay meaning unresolved.
    PirateRelationCeiling: Byte; // @offset 0xA0  Upper bound before the fixed minimum relation of 30.
  end;
  TPlanetRaceMarketTable = array[0..4] of TPlanetRaceMarketInfo;
  PPlanetRaceMarketTable = ^TPlanetRaceMarketTable;

  // Native record RTTI at $82CB64.

  // Native record RTTI at $82A25C.

  // Nine quotas per Coalition race: types 42..49, then the shared weapon bucket 50.
  TPlanetEquipmentOfferQuotaRow = array[0..8] of Integer;
  TPlanetEquipmentOfferQuotaTable = array[0..4] of TPlanetEquipmentOfferQuotaRow;
  PPlanetEquipmentOfferQuotaTable = ^TPlanetEquipmentOfferQuotaTable;

  TPlanetOwnerMasks = packed record // @size 0x03
    Coalition: Byte; // @offset 0x00  OwnerId bits 0..4 (0x1F).
    Dominators: Byte; // @offset 0x01  OwnerId bit 5 (0x20).
    PirateClan: Byte; // @offset 0x02  OwnerId bit 7 (0x80).
  end;
  PPlanetOwnerMasks = ^TPlanetOwnerMasks;
  TOwnerMask = set of 0..7; // @size 0x01
  TOwnerRelationRow = array[0..7] of Byte;
  TOwnerRelationTable = array[0..7] of TOwnerRelationRow;
  POwnerRelationTable = ^TOwnerRelationTable;
  TFactionStandingMasks = array[0..2] of Word;
  PFactionStandingMasks = ^TFactionStandingMasks;
  TQuestType = (qtSendLetter = 0, qtKillShip = 1, qtPlanetQuest = 2,
    qtDefendSystem = 3, qtDefendShip = 4); // @size 0x1
  TQuestTypes = set of TQuestType; // @size 0x1

  TQuestTuning = record // @size 0x0C
    RewardCapitalPercent: Byte; // @offset 0x00
    BaseDuration: Integer; // @offset 0x04
    BaseRewardMoney: Integer; // @offset 0x08
  end;
  TQuestTuningTable = array[0..4] of TQuestTuning;
  PQuestTuningTable = ^TQuestTuningTable;
  TQuestExperienceTable = array[0..4] of Integer;
  PQuestExperienceTable = ^TQuestExperienceTable;

  TRelationLevel = (rlHostile = 0, rlBad = 1, rlNormal = 2,
    rlGood = 3, rlExcellent = 4); // @size 0x1

  // Native record RTTI at $82BDE0.

  TGalaxyDifficultyTuning = record // @size 0x38
    GoodsEventDurationFactor: Single; // @offset 0x00  Also scales fuel prices.
    QuestTimeAndExperienceFactor: Single; // @offset 0x04
    EquipmentWearFactor: Single; // @offset 0x08  Player equipment degradation, indexed by DifficultyLevels[3].
    InventionProgressScale: Single; // @offset 0x0C
    ArcadeRewardScale: Single; // @offset $10 Indexed by DifficultyLevels[7].
    QuestMoneyFactor: Single; // @offset 0x14
    DifficultyValue18: Integer; // @offset $18 Extrapolated geometrically; gameplay meaning unresolved.
    DifficultyValue1C: Byte; // @offset $1C Extrapolated linearly and rounded; gameplay meaning unresolved.
    MarketPriceBandSqueeze: Single; // @offset 0x20
    RandomHoleSpawnRollMaximum: Integer; // @offset 0x24  Roll 0..maximum; zero creates a hole when other conditions allow.
    MaximumDominatorResearchRate: Single; // @offset 0x28  Before the per-series multiplier.
    MaximumResearchMaterialConsumption: Byte; // @offset 0x2C  Inclusive random upper bound per consumption event.
    MaximumQuestProgramRewardCount: Byte; // @offset 0x2D  Upper end before owned-program scaling.
    ArcadeDamageTakenScale: Single; // @offset $30 Indexed by DifficultyLevels[6].
    DifficultyFactor34: Single; // @offset $34 Extrapolated geometrically; gameplay meaning unresolved.
  end;
  TGalaxyDifficultyTuningTable = array[0..9] of TGalaxyDifficultyTuning;
  PGalaxyDifficultyTuningTable = ^TGalaxyDifficultyTuningTable;

  TDominatorSeries = (dsBlazer = 0, dsKeller = 1, dsTerron = 2); // @size 0x1
  TFactionStrengthValues = array[0..2] of Single;

  TStarStatus = record // @size $1C
    ThreatLevel: Byte; // @offset $00  0..100.
    TrafficLevel: Byte; // @offset $01  0..100.
    ControlFaction: TStarFaction; // @offset $02  Script.StarOwner.
    CustomFaction: WideString; // @offset $04
    Battle: Byte; // @offset $08  Script.StarBattle.
    DominatorSeries: TDominatorSeries; // @offset $09  Script.StarSeries.
    PreviousControlFaction: TStarFaction; // @offset $0A
    CachedFactionStrength: TFactionStrengthValues; // @offset $0C  Coalition, Dominators/custom, pirates; indexed by Ord(TStarFaction).
    FactionStrengthCacheTurn: Integer; // @offset $18
  end;

  // Native record RTTI at $4DB4BC.
  TPlanetNews = record // @size 0x10
    Id: Cardinal; // @offset 0x00
    Turn: Integer; // @offset 0x04
    NewsType: Byte; // @offset 0x08
    Text: WideString; // @offset 0x0C
  end;

implementation
end.
