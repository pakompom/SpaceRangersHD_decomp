unit aGalaxyStruct;

interface

uses Windows;

const
  // Shared simulation, economy and targeting limits recovered from their callers.
  GalaxyWarmupTurns = 300;
  TurnsPerYear = 365;
  MaxMonetaryValue = 100000000;
  BaseMovementStepsPerTurn = 200;
  FullPathNodeLimit = 999999;
  AsteroidTargetRangeSquared = 1000000;
  InterceptorTargetRangeSquared = 1000000;
  // TerronToStarTurn packs this transformation marker with a turn number.
  TerronTransformationFlag = $40000000;

  // RelationValueToLevel boundaries; distinct from the relation_level_* category ordinals.
  RelationBadMin = 10;
  RelationNormalMin = 30;
  RelationGoodMin = 60;
  RelationExcellentMin = 80;

  // Common collection-count guard in saved galaxy/ship/planet records.
  MaxSavedListCount = 10000;
  // order_black_hole has finished transit and is following its emergence path.
  HoleExitOrderState = -65536;
  // The landing target and stored-item loader use opposite high-bit tags.
  OrderTargetShipFlag = $80000000;
  StoredItemPlanetFlag = $80000000;
  TaggedObjectIdMask = $7FFFFFFF;

  // Configuration/adverts leave goods unspecified; greetings translate that to a skip marker.
  UnspecifiedGoods = 42;
  NoGreetingGoods = 50;
  // Higher text-quest IDs use PlanetQuestLic rather than standalone completion records.
  FirstLicensedQuestId = 10000;

  // SelectAward returns this sentinel when no individual award qualifies.
  AwardNotFound = $FF;

type
  // Diseases (1..12) and stimulants (13..24); radiation is stored separately.
  TCaptainHealthEffect = Integer;
const
  disease_blindness = 1;
  disease_chekumash = 2;
  disease_holy_fanaticism = 3;
  disease_complex_immunocide = 4;
  disease_mysterious_luatanza = 5;
  disease_drug_addiction = 6;
  disease_whirlwind_concussion = 7;
  disease_pulled_muscle = 8;
  disease_grand_malosausus = 9;
  disease_bitter_pelenosia = 10;
  disease_aka_sezyanka = 11;
  disease_new_molizone = 12;
  stimulant_maloq_sizha = 13;
  stimulant_one_eyed_khamas = 14;
  stimulant_stardust = 15;
  stimulant_super_technician = 16;
  stimulant_gaalian_alacrity = 17;
  stimulant_blood_djogar = 18;
  stimulant_ragobam_whisper = 19;
  stimulant_shakhmandoo_leader = 20;
  stimulant_psychotropic_cache = 21;
  stimulant_business_mark = 22;
  stimulant_doubleplex = 23;
  stimulant_absolute_status = 24;
type
  TCaptainDisease = disease_blindness..disease_new_molizone;
  TCaptainStimulant = stimulant_maloq_sizha..stimulant_absolute_status;

  // ShipTypeNames and subclass initializers share this ship/station domain.
  TShipType = (
    ship_dominator = 0,
    ship_ranger = 1,
    ship_transport = 2,
    ship_pirate = 3,
    ship_warrior = 4,
    ship_tranclucator = 5,
    station_ranger_center = 6,
    station_pirate_base = 7,
    station_military_base = 8,
    station_science_base = 9,
    station_business_center = 10,
    station_medical_base = 11,
    station_dominion = 12,
    station_custom = 13
  ); // @size $01
  TStationType = station_ranger_center..station_custom;

  // Hull categories differ from TShip.TypeId; transports have three hull kinds.
  THullType = (
    hull_ranger = 0,
    hull_warrior = 1,
    hull_pirate = 2,
    hull_transport = 3,
    hull_liner = 4,
    hull_diplomat = 5,
    hull_dominator = 6,
    hull_tranclucator = 7,
    hull_station = 8,
    hull_special = 9,
    hull_flagship = 10
  ); // @size $01

  // ScriptActionTypeNames ($810790), action masks and ship/item dispatch.
  TScriptEventKind = (
    event_step = 0,
    event_weapon_shot = 1,
    event_missile_shot = 2,
    event_deal_damage = 3,
    event_deal_fatal_damage = 4,
    event_deal_kamikaze_damage = 5,
    event_take_damage = 6,
    event_take_energy_damage = 7,
    event_take_splinter_damage = 8,
    event_take_missile_damage = 9,
    event_weapon_hit_flags = 10,
    event_missile_hit_flags = 11,
    event_receive_weapon_hit = 12,
    event_receive_missile_hit = 13,
    event_robot_repair = 14,
    event_item_pickup = 15,
    event_scan = 16,
    event_chameleon_confusion = 17,
    event_can_scan = 18,
    event_use_on_item = 19,
    event_item_used_on = 20,
    event_goods_used_on = 21,
    event_item_hit = 22,
    event_missile_hitting_object = 23,
    event_enter_form = 24,
    event_leave_form = 25,
    event_reenter_form = 26,
    event_enter_other_ship = 27,
    event_leave_other_ship = 28,
    event_reenter_other_ship = 29,
    event_player_skill_increase = 30,
    event_player_talked_with_ship = 31,
    event_ship_talked_with_player = 32,
    event_drop_moving_item = 33,
    event_drop_stationary_item = 34,
    event_move_item_to_storage = 35,
    event_equipment_combat_wear = 36,
    event_equipment_use_wear = 37,
    event_equipment_external_wear = 38,
    event_equipment_afterburner_wear = 39,
    event_item_destroy = 40,
    event_player_change_hull = 41,
    event_player_use_micromodule = 42,
    event_player_buy_equipment = 43,
    event_item_equip = 44,
    event_item_unequip = 45,
    event_pack_tranclucator = 46,
    event_ship_buys_goods = 47,
    event_ship_sells_goods = 48,
    event_show_item_info = 49,
    event_show_ship_info = 50,
    event_show_star_info = 51,
    event_nonstandard_equipment_change = 52,
    event_custom_targeting = 53,
    event_check_custom_targeting = 54,
    event_arcade_start = 55,
    event_arcade_item_drop = 56,
    event_government_item_reward = 57,
    event_can_use_on_item = 58,
    event_can_accept_item = 59,
    event_can_accept_goods = 60,
    event_death = 61
  ); // @size $01

  // CurrentStanding categories: GetControlPresence ($7F1538),
  // ResetControlFaction ($7F2918), and subclass RefreshCurrentStanding methods.
  TShipStanding = (
    standing_dominator = 0,
    standing_unaligned = 1,
    standing_coalition_military = 2,
    standing_coalition_active = 3,
    standing_coalition_passive = 4,
    standing_neutral = 5,
    standing_pirate_passive = 6,
    standing_pirate_active = 7,
    standing_pirate_military = 8,
    standing_custom = 9
  ); // @size $01

  // Award categories from SysToReward ($78FE18); distinct from individual award IDs.
  TAwardKind = (
    award_liberation = 0,
    award_accomplishment = 1,
    award_secret_mission = 2,
    award_cowardice = 3,
    award_perfidy = 4,
    award_planet_battle = 5
  ); // @size $01

  // GetScriptStandingOverrideMode ($6F2B00) and its callers use a 32-bit ordinal.
  TStandingOverride = (override_none = 0, override_custom_faction = 1, override_fixed = 2); // @size $04

  // InitializeShipGreetingDefinitions ($7A6F0C) and TShip virtual slot $30.
  // Transport subtypes and pirate allegiance have distinct greeting categories.
  TGreetingShipCategory = (
    greeting_ship_transport = 0,
    greeting_ship_liner = 1,
    greeting_ship_diplomat = 2,
    greeting_ship_ranger = 3,
    greeting_ship_pirate = 4,
    greeting_ship_warrior = 5,
    greeting_ship_dominator = 6,
    greeting_ship_clan_pirate = 7
  ); // @size $01

  // CoalitionProjectNames ($8129C4), investment dispatch ($576ACC/$579DC4),
  // and the military-base war operation ($56D664) share these cooldown indices.
  TCoalitionProject = (
    project_build_ranger_center = 0,
    project_build_pirate_base = 1,
    project_build_military_base = 2,
    project_build_science_base = 3,
    project_build_business_center = 4,
    project_build_medical_base = 5,
    project_fund_rangers = 6,
    project_fund_pirates = 7,
    project_fund_transports = 8,
    project_lost_subsidy = 9,
    project_fund_planet_defense = 10,
    project_liberation_operation = 11
  ); // @size $01

  // ShowPlayerDialogue ($6EC0F0), TfTalk.BuildBuiltinChoices ($5ED6DC),
  // and the script Talk* constants share these conversation categories.
  TTalkEventKind = (
    talk_event_demand_money = 0,
    talk_event_demand_goods = 1,
    talk_event_offer_truce = 2,
    talk_event_attack = 3,
    talk_event_partnership_broken = 4,
    talk_event_partnership_expired = 5,
    talk_event_partner_rebellion = 6
  ); // @size $01

  // GainExperience applies separate diminishing returns to these sources.
  TExperienceSource = (
    experience_unscaled = 0, experience_dominators = 1, experience_pirates = 2,
    experience_normal_ships = 3, experience_trader_career = 4
  ); // @size $01

  TPercent = 0..100;
  TShipRank = 0..7; // @size $01 Shared ordinal range; Coalition and pirate titles differ.

  TPilotSkill = (
    skill_accuracy = 0,
    skill_maneuverability = 1,
    skill_technical = 2,
    skill_trading = 3,
    skill_charisma = 4,
    skill_leadership = 5
  ); // @size 0x1

  // ProgramNames,
  // ranger inventory, Dominator effects and script prog* IDs.
  TProgramIndex = (
    program_keller_call = 0,
    program_logical_negation = 1,
    program_dematerial = 2,
    program_energotron = 3,
    program_sab_crack = 4,
    program_intercom = 5,
    program_shipwreck = 6,
    program_weapon_blocking = 7,
    program_insanity = 8,
    program_shock = 9,
    program_self_destruction = 10,
    program_disconnection = 11
  ); // @size $01

  // MatrixGame's SRobotGameState / CGame.SaveResult ABI, also stored in battle history.
  TPlanetBattleStatistics = record // @size $18
    SignedTimeMs: Integer; // @offset $00 Elapsed milliseconds; MatrixGame negates the winning side's time.
    RobotsBuilt: Integer; // @offset $04
    RobotsDestroyed: Integer; // @offset $08
    TurretsBuilt: Integer; // @offset $0C
    TurretsDestroyed: Integer; // @offset $10
    BuildingsDestroyed: Integer; // @offset $14
  end;
  PPlanetBattleStatistics = ^TPlanetBattleStatistics;

  TGreetingCountMask = set of 0..15; // @size $02 Shared greeting count buckets; bit 10 is Many/Far where supported.

  // Shared scalar configuration identifiers. Managed configuration records live in aConst.

  TTransportType = (transport_standard = 0, transport_liner = 1, transport_diplomat = 2); // @size 0x1

  TCombatEffectKind = (
    combat_effect_shock = 0, combat_effect_acid = 1, combat_effect_magnetic = 2, combat_effect_weapon_block = 3,
    combat_effect_droid_block = 4, combat_effect_node_boost = 5, combat_effect_node_repair_penalty = 6
  ); // @size 0x1

  TWeaponShotType = (
    shot_single_target = 0,
    shot_chain = 1,
    shot_splash = 2,
    shot_explode_on_kill = 3,
    shot_area_damage = 4,
    shot_torpedo = 5,
    shot_missile = 6,
    shot_rocket = 7
  ); // @size 0x1

  TShipTypeMask = set of TShipType; // @size $02 Shared ship/station type bits.

  TWeaponAvailability = (
    availability_unrestricted = 0,
    availability_coalition_only = 1,
    availability_pirate_only = 2,
    availability_not_sold = 3,
    availability_not_sold_node_repair = 4,
    availability_maloc_only = 5,
    availability_peleng_only = 6,
    availability_human_only = 7,
    availability_feyan_only = 8,
    availability_gaal_only = 9,
    availability_system_only = 10
  ); // @size 0x1
  TWeaponAvailabilityMask = set of TWeaponAvailability; // @size $02


  // English ShipType.Dominator entries name the same seven ordinary types in every series.
  // Type zero selects the series boss: Blazer, Keller or Terron.
  TDominatorKind = (
    dominator_boss = 0, dominator_equantor = 1, dominator_urgant = 2, dominator_smersh = 3,
    dominator_menoc = 4, dominator_shtip = 5, dominator_bertor = 6, dominator_klig = 7
  ); // @size 0x1

  TDominatorSeries = (series_blazer = 0, series_keller = 1, series_terron = 2); // @size 0x1

  // Shared ship career category; non-ranger implementations can return a fixed career.
  TRangerCareer = (career_trader = 0, career_pirate = 1, career_warrior = 2); // @size 0x1
  TRangerCareerSet = set of TRangerCareer; // @size 0x1

  // PlanetInventionInfo ($81291C) and EquipmentInventionIndices ($8129BC).
  // Research-track IDs are distinct from item types and numeric technology levels.
  // Weapon tracks use English Items.Weapon.Name names; later weapons can share a track.
  TResearchTrack = (
    research_hull = 0,
    research_fuel_tanks = 1,
    research_engine = 2,
    research_radar = 3,
    research_scanner = 4,
    research_repair_robot = 5,
    research_cargo_hook = 6,
    research_main_technology = 7,
    research_industrial_laser = 8,
    research_fragmentation_cannon = 9,
    research_flux = 10,
    research_missile_launcher = 11,
    research_treton = 12,
    research_wave_phaser = 13,
    research_flow_blaster = 14,
    research_electronic_cutter = 15,
    research_multiresonator = 16,
    research_atomic_vision = 17,
    research_disintegrator = 18,
    research_turbogravitron = 19
  ); // @size $01

  TGalaxyDifficultyIndex = 0..7;
  TDifficultyLevel = 0..9; // @size $01
  TGalaxyDifficultyLevels = array[0..7] of TDifficultyLevel;

  TPlanetEconomy = (economy_agricultural = 0, economy_mixed = 1, economy_industrial = 2); // @size 0x1
  TPlanetEconomies = set of TPlanetEconomy; // @size $01
  TPlanetGovernment = (
    government_anarchy = 0, government_dictatorship = 1, government_monarchy = 2,
    government_republic = 3, government_democracy = 4
  ); // @size 0x1
  TPlanetGovernments = set of TPlanetGovernment; // @size $01
  TShopUpdateMode = (
    shop_update_all = 0, shop_update_disabled = 1, shop_update_equipment = 2, shop_update_goods = 3
  ); // @size 0x1
  TStarFaction = (faction_coalition = 0, faction_dominators = 1, faction_pirates = 2); // @size 0x1

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

  // Numeric goods-table indices correspond to item_food..item_narcotics in aConst.
  TGoodsIndex = 0..7;
  TGoodsTextOrder = array[TGoodsIndex] of TGoodsIndex;
  PGoodsTextOrder = ^TGoodsTextOrder;
  TDominatorSeriesNameTable = array[TDominatorSeries] of WideString;
  PDominatorSeriesNameTable = ^TDominatorSeriesNameTable;

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

  // Four-byte damage masks use bits 0..20, including the separate NoDelta flag.
  // The original upper enum bound within 19..23 is unresolved; this domain ends at 19.
  TDamageFlag = (
    damage_flag_energy = 0,
    damage_flag_splinter = 1,
    damage_flag_missile = 2,
    damage_flag_engine_slow = 3,
    damage_flag_equipment_wear = 4,
    damage_flag_life_steal = 5,
    damage_flag_shock = 6,
    damage_flag_acid = 7,
    damage_flag_magnetic = 8,
    damage_flag_artefact_slow = 9,
    damage_flag_extra_artefact_slow = 10,
    damage_flag_ignore_defenses = 11,
    damage_flag_nonlethal = 12,
    damage_flag_scanner_bonus = 13,
    damage_flag_bonus_to_damaged_hull = 14,
    damage_flag_extra_loot = 15,
    damage_flag_force_cargo_drop = 16,
    damage_flag_engine_wear = 17,
    damage_flag_weapon_block = 18,
    damage_flag_droid_block = 19
  ); // @size 1
  TDamageFlagSet = set of TDamageFlag; // @size 4 Named sets are rounded to four bytes by DCC32.

const
  // Bit 20 fixes minimum damage at the maximum (TShip.GetWeaponMinDamage).
  damage_no_spread_mask = 1 shl 20;

type

  TItemTypeMask = set of 0..79; // @size 10

  TItemLootPool = (
    loot_arcade_battle = 0,
    loot_treasure = 1,
    loot_reward = 2,
    loot_any_available = 3
  ); // @size 0x1

  // OwnerToSys ($78F974) and RaceToSys ($78F3C8) establish these IDs.
  // RaceId and PilotRace use the same Coalition values 0..4.
  TOwnerId = (owner_maloc = 0, owner_peleng = 1, owner_human = 2, owner_feyan = 3,
    owner_gaal = 4, owner_dominator = 5, owner_uninhabited = 6, owner_pirate = 7); // @size $01 OwnerInfo and native planet/ship owner numbering.

  TPlanetGoodsFactors = record // @size 0x10
    PriceFactor: Double; // @offset 0x00
    StockFactor: Double; // @offset 0x08
  end;
  TPlanetRaceMarketInfo = record // @size 0xA8
    InventionProgressScale: Single; // @offset 0x00  Used by TPlanet.CalculateInventionProgressRate.
    InitialInventionBoostCount: Integer; // @offset 0x04
    GoodsFactors: array[TGoodsIndex] of TPlanetGoodsFactors; // @offset 0x08
    GovernmentRollThresholds: array[TPlanetGovernment] of Byte; // @offset 0x88  Cumulative thresholds indexed by TPlanetGovernment.
    RevolutionChance: Single; // @offset 0x90
    FriendlyRelationScale: Single; // @offset $94 Scales transport-to-transport relations ($5AD400) and partner-gift gains ($5F59A8/$5F96C4).
    PirateRelationFactor: Single; // @offset 0x98  Multiplies owner-table relations for pirates at Coalition planets.
    UnknownFactor9C: Single; // @offset $9C Native race factor; gameplay meaning unresolved.
    PirateRelationCeiling: Byte; // @offset 0xA0  Upper bound before the fixed minimum relation of 30.
  end;
  TPlanetRaceMarketTable = array[owner_maloc..owner_gaal] of TPlanetRaceMarketInfo;
  PPlanetRaceMarketTable = ^TPlanetRaceMarketTable;



  TByteMask = set of 0..7; // @size $01
  TOwnerMask = set of TOwnerId; // @size $01
  TShipStandings = set of TShipStanding; // @size $02 Faction and station-search filters; an empty station filter accepts every standing.
  // Series filters retain the native one-byte set storage and membership checks.
  TDominatorSeriesMask = set of TDominatorSeries; // @size $01

  TPlanetOwnerMasks = packed record // @size 0x03
    case Boolean of
      False: (
        Coalition: TOwnerMask; // @offset 0x00 Coalition owner IDs 0..4.
        Dominators: TOwnerMask; // @offset 0x01 Dominator owner ID 5.
        PirateClan: TOwnerMask; // @offset 0x02 Pirate Clan owner ID 7.
      );
      True: (
        ByFaction: array[TStarFaction] of TOwnerMask; // @offset 0x00
      );
  end;
  PPlanetOwnerMasks = ^TPlanetOwnerMasks;
  TOwnerRelationRow = array[TOwnerId] of Byte;
  TOwnerRelationTable = array[TOwnerId] of TOwnerRelationRow;
  POwnerRelationTable = ^TOwnerRelationTable;
  TFactionStandingMasks = array[TStarFaction] of TShipStandings;
  PFactionStandingMasks = ^TFactionStandingMasks;
  TQuestKind = (quest_kind_deliver_letter = 0, quest_kind_destroy_ship = 1, quest_kind_text_adventure = 2,
    quest_kind_defend_system = 3, quest_kind_protect_ship = 4); // @size 0x1
  TQuestTypes = set of TQuestKind; // @size 0x1

  TQuestTuning = record // @size 0x0C
    RewardCapitalPercent: Byte; // @offset 0x00
    BaseDuration: Integer; // @offset 0x04
    BaseRewardMoney: Integer; // @offset 0x08
  end;
  TQuestTuningTable = array[TQuestKind] of TQuestTuning;
  PQuestTuningTable = ^TQuestTuningTable;
  TQuestExperienceTable = array[TQuestKind] of Integer;
  PQuestExperienceTable = ^TQuestExperienceTable;

  TRelationLevel = (relation_level_hostile = 0, relation_level_bad = 1, relation_level_normal = 2,
    relation_level_good = 3, relation_level_excellent = 4); // @size 0x1
  TRelationLevels = set of TRelationLevel; // @size $01


  TGalaxyDifficultyTuning = record // @size 0x38
    GoodsEventDurationFactor: Single; // @offset 0x00  Also scales fuel prices.
    QuestTimeAndExperienceFactor: Single; // @offset 0x04
    EquipmentWearFactor: Single; // @offset 0x08  Player equipment degradation, indexed by DifficultyLevels[3].
    InventionProgressScale: Single; // @offset 0x0C
    ArcadeRewardScale: Single; // @offset $10 Indexed by DifficultyLevels[7].
    QuestMoneyFactor: Single; // @offset 0x14
    StartingPlayerMoney: Integer; // @offset $18 DifficultyLevels[1]; passed to InitializePlayerAtPlanet and ApplyCharacterPreset.
    InitialPirateControlPercent: Byte; // @offset $1C DifficultyLevels[0]; sets the initial pirate-system selection count before placement exclusions.
    MarketPriceBandSqueeze: Single; // @offset 0x20
    RandomHoleSpawnRollMaximum: Integer; // @offset 0x24  Roll 0..maximum; zero creates a hole when other conditions allow.
    MaximumDominatorResearchRate: Single; // @offset 0x28  Before the per-series multiplier.
    MaximumResearchMaterialConsumption: Byte; // @offset 0x2C  Inclusive random upper bound per consumption event.
    MaximumQuestProgramRewardCount: Byte; // @offset 0x2D  Upper end before owned-program scaling.
    ArcadeDamageTakenScale: Single; // @offset $30 Indexed by DifficultyLevels[6].
    CoalitionToPirateBalanceRatio: Single; // @offset $34 DifficultyLevels[0]; normalizes the system-count ratio for daily WarDeltaWin adjustments.
  end;
  TGalaxyDifficultyTuningTable = array[0..9] of TGalaxyDifficultyTuning;
  PGalaxyDifficultyTuningTable = ^TGalaxyDifficultyTuningTable;

  TFactionStrengthValues = array[TStarFaction] of Single;

  TStarStatus = record // @size $1C
    ThreatLevel: Byte; // @offset $00  0..100.
    TrafficLevel: Byte; // @offset $01  0..100.
    ControlFaction: TStarFaction; // @offset $02  Script.StarOwner.
    CustomFaction: WideString; // @offset $04
    Battle: Byte; // @offset $08  Script.StarBattle.
    DominatorSeries: TDominatorSeries; // @offset $09  Script.StarSeries.
    PreviousControlFaction: TStarFaction; // @offset $0A
    CachedFactionStrength: TFactionStrengthValues; // @offset $0C  Coalition, Dominators/custom, pirates; indexed by TStarFaction.
    FactionStrengthCacheTurn: Integer; // @offset $18
  end;

  // GalaxyNews producers and CountPlanetNewsByType ($7EB698) share these IDs.
  // Distinct from message_* player-message presentation kinds.
  TGalaxyNewsKind = (
    news_script = 0,
    news_revolution_anarchy = 1,
    news_revolution_dictatorship = 2,
    news_revolution_monarchy = 3,
    news_revolution_republic = 4,
    news_revolution_democracy = 5,
    news_mineral_deposit = 6,
    news_mineral_shortage = 7,
    news_arms_surplus = 8,
    news_arms_shortage = 9,
    news_technical_goods_surplus = 10,
    news_food_surplus = 11,
    news_food_shortage = 12,
    news_medicine_surplus = 13,
    news_luxury_surplus = 14,
    news_luxury_shortage = 15,
    news_alcohol_surplus = 16,
    news_alcohol_shortage = 17,
    news_heavy_transport_traffic = 18,
    news_high_pirate_activity = 19,
    news_pirate_activity = 20,
    news_no_pirates = 21,
    news_many_rangers = 22,
    news_eminent_ranger_location = 23,
    news_dominator_attack = 24,
    news_dominator_attack_repelled = 25,
    news_liberation_group_created = 26,
    news_pirate_attack = 27,
    news_pirate_attack_repelled = 28,
    news_coalition_takes_dominator_system = 29,
    news_coalition_takes_pirate_system = 30,
    news_pirates_take_dominator_system = 31,
    news_pirates_take_coalition_system = 32,
    news_dominators_take_coalition_system = 33,
    news_dominators_take_pirate_system = 34,
    news_coalition_defeated = 35,
    news_wormhole_created = 36,
    news_eminent_warrior = 37,
    news_eminent_trader = 38,
    news_eminent_pirate = 39,
    news_imprisonment = 40,
    news_station_created = 41,
    news_coalition_investment = 42,
    news_dominator_research_completed = 43,
    news_station_special_ship = 44,
    news_military_base_operation = 45
  ); // @size $01

  TPlanetNews = record // @size 0x10
    Id: Cardinal; // @offset 0x00
    Turn: Integer; // @offset 0x04
    NewsType: TGalaxyNewsKind; // @offset 0x08
    Text: WideString; // @offset 0x0C
  end;

implementation
end.
