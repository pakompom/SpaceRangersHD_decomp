unit aShip;

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, SE_Space, Windows, aAsteroid, aEFilm, aGalaxy, aGalaxyStruct, aItem, aMyFunction, aPath, aPlanet;

type
  // Fixed equipment slots occupy the contiguous cache at $F8..$114.
  TShipEquipmentCache = record // @size $20
    case Boolean of
      False: (
        Slots: array[item_hull..item_defense_generator] of TEquipment; // @offset $00
      );
      True: (
        Hull: THull; // @offset $00
        FuelTanks: TFuelTanks; // @offset $04
        Engine: TEngine; // @offset $08
        Radar: TRadar; // @offset $0C
        Scanner: TScaner; // @offset $10
        RepairRobot: TRepairRobot; // @offset $14
        CargoHook: TCargoHook; // @offset $18
        DefGenerator: TDefGenerator // @offset $1C
      );
  end;

  TCustomShipInfo = record // @size 0x28
    TypeName: WideString; // @offset 0x00
    Description: WideString; // @offset 0x04
    Data: array[1..3] of Integer; // @offset 0x08
    TextData1: WideString; // @offset 0x14
    TextData2: WideString; // @offset 0x18
    TextData3: WideString; // @offset 0x1C
    ActionCode: Pointer; // @offset 0x20  Borrowed from the shared script cache.
    StatusEffect: Boolean; // @offset 0x24
    ActionCodeInitialized: Boolean; // @offset 0x25
    DeleteQueued: Boolean; // @offset 0x26
  end;
  PCustomShipInfo = ^TCustomShipInfo;

  TShipOrder = (
    order_none = 0, order_move = 1, order_land = 2, order_jump = 3,
    order_black_hole = 4, order_takeoff = 5, order_follow_ship = 6, order_teleport = 7
  ); // @size 0x1

  // Follow modes in OrderStateData; unknown byte values are preserved.
  TFollowMode = (
    follow_close = 0,
    follow_min_weapon_range = 1,
    follow_max_weapon_range = 2, // No built-in caller.
    follow_kamikaze = 3
  ); // @size $01

  TShipStatBonusEntry = record // @size 0x08
    BonusKind: TEquipmentBonusKind; // @offset 0x00
    BonusValue: Integer; // @offset 0x04
  end;
  PShipStatBonusEntry = ^TShipStatBonusEntry;

  TItemWearKind = (wear_combat = 0, wear_use = 1, wear_external = 2, wear_afterburner = 3); // @size 0x1

  TCombatStatusEffect = record // @size 0x0C
    EffectType: TCombatEffectKind; // @offset 0x00
    Strength: Single; // @offset 0x04
    SourceShipId: Cardinal; // @offset 0x08  Zero for no source; an ID, not a pointer.
  end;
  PCombatStatusEffect = ^TCombatStatusEffect;

  TWeaponCount = 0..5;
  TPilotSkillLevel = 0..6;


  TCargoGoodsEntry = packed record // @size 0x10
    Count: Integer; // @offset 0x00
    TotalCost: Integer; // @offset 0x04
    // Player purchases tracked separately for trade-profit experience.
    PurchasedCount: Integer; // @offset 0x08
    PurchasedTotalCost: Integer; // @offset 0x0C
  end;

  TCaptainHealthState = record // @size 0x18
    Progress: Double; // @offset 0x00  0: absent; 100: active.
    AppliedTurn: Integer; // @offset 0x08
    ExpireTurn: Integer; // @offset 0x0C
    ApplicationCount: Integer; // @offset 0x10
  end;

  TShip = class(TObjectEx) // @size 0x4D0 @methodorder source
  public
    Id: Cardinal; // @offset 0x04
    Name: WideString; // @offset 0x08
    TypeNameOverrideKey: WideString; // @offset 0x0C
    TypeId: TShipType; // @offset 0x10
    OwnerId: TOwnerId; // @offset 0x11
    Position: TPointF; // @offset 0x14
    CurrentPlanet: TPlanet; // @offset 0x1C
    DockedTo: TShip; // @offset 0x20  Includes TRuins stations.
    CurrentStar: TStar; // @offset 0x24
    TransitOriginStar: TStar; // @offset 0x28
    HomePlanet: TPlanet; // @offset 0x2C
    CargoGoods: array[TGoodsIndex] of TCargoGoodsEntry; // @offset 0x30
    Wealth: Integer; // @offset 0xB0
    WealthInBestRanger: Single; // @offset 0xB4
    Strength: Single; // @offset 0xB8
    StrengthInBestRanger: Single; // @offset 0xBC
    StrengthInAverageRanger: Single; // @offset 0xC0
    Speed: Integer; // @offset 0xC4
    JumpRange: Integer; // @offset 0xC8  Cached fuel-limited range.
    DefenseDamageFactor: Double; // @offset 0xD0  1 means no damage reduction.
    HasInactiveDirectEquipment: Byte; // @offset 0xD8
    CargoFreeSpace: Integer; // @offset 0xDC
    Seed: Cardinal; // @offset 0xE0  Stable seed used for repeatable choices.
    RandomState: Cardinal; // @offset 0xE4
    CreationTurn: Integer; // @offset 0xE8
    LastProcessedTurn: Integer; // @offset 0xEC
    Money: Integer; // @offset 0xF0
    UnknownF4: Integer; // @offset $F4 Serialized after LastProcessedTurn; meaning unresolved.
    EquipmentCache: TShipEquipmentCache; // @offset $F8
    Weapons: array[1..5] of TWeapon; // @offset 0x118
    WeaponCount: TWeaponCount; // @offset 0x12C
    UsableWeaponCount: Byte; // @offset 0x12D
    BaseSkills: array[TPilotSkill] of TPilotSkillLevel; // @offset 0x12E
    CaptainHealth: array[disease_blindness..stimulant_absolute_status] of TCaptainHealthState; // @offset 0x138  1..12: diseases; 13..24: stimulants.
    RadiationHealth: array[1..1] of TCaptainHealthState; // @offset 0x378  Same native record as diseases/stimulants.
    CustomShipInfos: TList; // @offset 0x390  Owns PCustomShipInfo records; deletion may be deferred during action callbacks.
    TradeLossBalance: Integer; // @offset 0x394
    TradeExperience: Integer; // @offset 0x398
    ContrabandProfit: Integer; // @offset 0x39C
    TechKnowledge: Byte; // @offset 0x3A0
    NodeReserve: Integer; // @offset 0x3A4
    TotalExperience: Integer; // @offset 0x3A8
    FreeExperience: Integer; // @offset 0x3AC
    DaysSincePlayerSeen: Integer; // @offset 0x3B0  Reset for ships in normal space in the player's current system.
    InFear: Boolean; // @offset 0x3B4
    AfterburnerActive: Boolean; // @offset 0x3B5
    Inventory: TObjectList; // @offset 0x3B8  Owns its items; index 0 holds the hull.
    Artefacts: TObjectList; // @offset 0x3BC
    GuaranteedDeathDropItems: TObjectList; // @offset 0x3C0  Owned TItem entries, transferred to space on destruction.
    StatBonuses: TList; // @offset 0x3C4  PShipStatBonusEntry elements.
    CombatStatusEffects: TList; // @offset 0x3C8  Optional; owns PCombatStatusEffect entries.
    ScriptShip: TObject; // @offset 0x3CC
    LiberationGroup: TObject; // @offset 0x3D0 Borrowed TGroup; native consumers use checked casts.
    LiberationGroupRouteIndex: Integer; // @offset 0x3D4
    PickupTargets: TList; // @offset 0x3D8  TItem entries.
    RecentlyDroppedItemIds: TList; // @offset 0x3DC
    PickupPathUpdatesAllowed: Boolean; // @offset 0x3E0  Suppresses pickup rerouting during final travel approaches unless a queued item lies along the path.
    PlanetQueue: TList; // @offset 0x3E4  TPlanet entries.
    AwardIds: TList; // @offset 0x3E8  Integer medal IDs stored directly in list slots.
    AwardVisibleCount: Integer; // @offset 0x3EC  Prefix displayed in the awards UI.
    RangerRelations: TList; // @offset 0x3F0  Optional byte-valued entries indexed by the galaxy's ranger list.
    EnemyShip: TShip; // @offset 0x3F4
    TruceShip: TShip; // @offset 0x3F8
    PartnerShip: TShip; // @offset 0x3FC
    PartnershipDaysRemaining: Integer; // @offset 0x400
    PortraitFaceId: Integer; // @offset 0x404
    PilotRace: TOwnerId; // @offset 0x408
    MovementSpeed: Double; // @offset 0x410
    MovementTurnRate: Double; // @offset 0x418  Angular increment used by path construction, in degrees.
    MovementDirection: Double; // @offset 0x420  Heading in degrees.
    Order: TShipOrder; // @offset 0x428
    OrderStateData: Integer; // @offset 0x42C  Order-dependent; hole travel packs countdown and endpoint side into the two words.
    OrderTarget: TObject; // @offset 0x430  Planet, ship, star or hole according to Order.
    OrderDestination: TPointF; // @offset 0x434
    OrderAbsolute: Boolean; // @offset 0x43C
    MovementPath: TSPath; // @offset 0x440  Owned; nodes are recycled by the path.
    JumpDeparturePathCommitted: Boolean; // @offset 0x444
    AbductedByPirateClan: Boolean; // @offset 0x445  Pirate Clan station abduction changes the arrival system and jump-gate presentation.
    ConsecutiveDockedDays: Integer; // @offset 0x448  Player text quests reset this counter.
    AbsoluteScriptOrder: Byte; // @offset 0x44C
    Graphic: TObjectSE; // @offset 0x450  Retained space-engine object.
    GraphName: WideString; // @offset 0x454
    GraphDominator: Boolean; // @offset 0x458  Alternate Dominator-style ship representation.
    InHyperspace: Boolean; // @offset 0x459
    CollisionRadius: Single; // @offset 0x45C  Used for follow spacing and ship repulsion.
    DestroyQueued: Boolean; // @offset 0x460  Script.ShipDestroy.
    ChameleonActive: Boolean; // @offset 0x461
    ChameleonSeries: TDominatorSeries; // @offset 0x462
    ChameleonVisualType: TDominatorKind; // @offset 0x463  Hull-dependent disguise silhouette.
    ChameleonDisplayCount: Integer; // @offset $464 Serialized counter displayed in active chameleon info ($6BE86C); no gameplay update recovered.
    ChameleonDetected: array[TDominatorSeries] of Boolean; // @offset 0x468  TDominatorSeries order.
    ChameleonCharges: array[TDominatorSeries] of Integer; // @offset 0x46C  TDominatorSeries order.
    RepulsionPosition: TPointF; // @offset 0x47C  Predicted position adjusted when separating following ships.
    FilmAlpha: Single; // @offset 0x488  May extend beyond 0..255; clamped when emitting film commands.
    FilmAlphaStep: Single; // @offset 0x48C
    EncodedMoney: Dword; // @offset 0x490  Money xor 0xA4A576AD.
    FilmObject: TEFilmObj; // @offset 0x494  Borrowed from the current turn film.
    NoDrop: Boolean; // @offset 0x498
    TargetingRestriction: Byte; // @offset 0x499  Script.NoTargetToShip mode, not a Boolean.
    NoTalk: Boolean; // @offset 0x49A
    NoScan: Boolean; // @offset 0x49B
    ScriptChameleon: Boolean; // @offset 0x49C  Script-assigned appearance; separate from Dominator camouflage.
    PlayerExtortionPactActive: Boolean; // @offset 0x49D  Prevents repeat player money/cargo/truce deals independently of the normal-ship turn cooldown.
    PlayerScratchHitsReceived: Word; // @offset $49E One-point hits from the player; SCRATCHDAMAGE checks for twenty.
    InterceptorPassesRemaining: Integer; // @offset 0x4A0  Incoming passes against this ship.
    InterceptorSourceShip: TShip; // @offset 0x4A4
    InterceptorGraphic: TObjectSE; // @offset 0x4A8  Retained visual for incoming interceptor passes.
    AuxiliaryFilmObject: TEFilmObj; // @offset 0x4AC  Borrowed auxiliary graphic entry.
    CurrentStanding: TShipStanding; // @offset $4B0 ss* faction-combat category, exposed by Script.ShipStanding.
    SmoothedSpeed: Integer; // @offset 0x4B4
    SmoothedEnemySpeed: Integer; // @offset 0x4B8  Retained while EnemyShip is absent or outside this system.

    SmoothedEquipmentEffectiveness: Single; // @offset 0x4BC
    SmoothedWealth: Integer; // @offset 0x4C0
    SmoothedMoneyFraction: Single; // @offset 0x4C4
    SmoothedFreeCapacityFraction: Single; // @offset 0x4C8  Hull capacity less equipped item mass; excludes loose cargo.
    EquipmentPriceSensitivity: Single; // @offset 0x4CC  Smoothed affordability state; ranger item evaluation uses it to scale resale/cost penalties.

    constructor Create; // @addr 0x006C27E4
    destructor Destroy; override; // @addr 0x006C2B18
    procedure SaveToBuffer(Buffer: TBufEC); virtual; // @addr 0x006C30AC @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); virtual; // @addr 0x006C3C14 @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); virtual; // @addr 0x006C73A4 @slot 0x08 @note "Converts saved IDs to object references; requires all referenced objects to have been loaded."
    procedure ClearObjectReferences; virtual; // @addr 0x006C7860 @slot 0x0C @note "Clears navigation, docking and ship references, including item references; preserves CurrentStar, ScriptShip and LiberationGroup."
    procedure SaveToBlock(Block: TBlockParEC); virtual; // @addr 0x006C4CC4 @slot 0x10 @note "Editable subset; not a full save."
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x006C5D9C @slot 0x14 @note "Applies edits to existing state and can append items or issue new orders. Cargo quantities change without updating cost basis."
    procedure NextDay; virtual; // @addr 0x006C8034 @slot 0x18
    procedure NextDayLogic; virtual; // @addr 0x006C8C34 @slot 0x1C
    procedure ProcessBrokenFuelTankLeak; // @addr 0x006C79E0 @note "Can cancel the player's jump when remaining fuel is insufficient."
    procedure RefreshTechKnowledgeAtLocation; // @addr 0x006C7CC8 @note "Can unlock carried equipment use/repair and notify the player."
    procedure DerivedStateCompatibilityHook; // @addr 0x006C8C60 @note "Native no-op, called after loading/editing and refreshing derived stats."
    procedure AssignWeaponTargetsInStar; virtual; // @addr 0x006C8C38 @slot 0x20 @note "The base implementation clears all weapon targets."

    function GetName: WideString; virtual; abstract; // @slot 0x24
    function GetFullName(const Separator: WideString): WideString; virtual; abstract; // @slot 0x28
    function GetTypeNameKey: WideString; virtual; // @addr 0x006C8C64 @slot 0x2C
    function GetGreetingShipCategory: TGreetingShipCategory; virtual; abstract; // @slot 0x30 Category bit in ship-greeting ShipType, ToShipType and ShipBadType filters.
    function GetHomeStar: TStar; virtual; abstract; // @slot 0x34
    function GetDominantCareer: TRangerCareer; virtual; abstract; // @slot 0x38
    function GetStrengthScaledPirateStatus: TPercent; virtual; abstract; // @slot 0x3C
    function GetDesiredCargoFreeSpace: Integer; virtual; // @addr 0x006C9898 @slot 0x40
    function GetEstimatedMemoryUsage: Integer; virtual; // @addr 0x006C98EC @slot 0x44 @note "Counts the instance and selected list storage; excludes item objects and managed strings."
    procedure RefuelAtLocation; virtual; abstract; // @slot 0x48
    function CalculateSpeed: Integer; virtual; // @addr 0x006F10E8 @slot 0x4C
    function CalculateItemEffectiveness(Item: TItem): Single; // @addr 0x006D938C @note "Temporarily changes weapon installation and disables ChaoticRandom while evaluating equipment; restores them on the normal path."
    function EstimateWeaponDamageAgainstTypicalDefense(Item: TWeapon): Single; // @addr 0x006D9D40 @note "Returns one for a non-weapon; adjusts weapon damage for galaxy technology and accuracy."
    function GetItemFuelTankCapacity(Item: TItem): Integer; // @addr 0x006DA0FC @note "Zero unless Item is fuel tanks."
    function GetEquipmentEvaluationSynergyBonus(Item: TEquipment): Single; // @addr 0x006DA7CC
    function GetWeaponArtefactDamageFactor(Weapon: TWeapon): Single; // @addr 0x006DB168
    procedure RefreshEquipmentEvaluationMetrics; // @addr 0x006DB45C
    function EvaluateItem(Item: TItem; PriceMode: Byte): Single; // @addr 0x006DB708
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; virtual; // @addr 0x006DB73C @slot 0x50 @note "Price modes: 1 negated item cost, 3 resale value, 4 item cost; other modes omit the price term. Mode 0 also omits weight/fragility penalties; the supplied effectiveness is recomputed."
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; virtual; // @addr 0x006DBB78 @slot 0x54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; virtual; // @addr 0x006DC5E4 @slot 0x58
    function EvaluateMicroModuleGain(Item: TEquipment; ModuleIndex: Integer): Single; virtual; // @addr 0x006DCBEC @slot 0x5C @note "Evaluates a temporary clone; restores NextItemId but leaves LoadedSaveVersion set to CurrentSaveVersion. ModuleIndex is zero-based."
    property Hull: THull read EquipmentCache.Hull write EquipmentCache.Hull;
    property FuelTanks: TFuelTanks read EquipmentCache.FuelTanks write EquipmentCache.FuelTanks;
    property Engine: TEngine read EquipmentCache.Engine write EquipmentCache.Engine;
    property Radar: TRadar read EquipmentCache.Radar write EquipmentCache.Radar;
    property Scanner: TScaner read EquipmentCache.Scanner write EquipmentCache.Scanner;
    property RepairRobot: TRepairRobot read EquipmentCache.RepairRobot write EquipmentCache.RepairRobot;
    property CargoHook: TCargoHook read EquipmentCache.CargoHook write EquipmentCache.CargoHook;
    property DefGenerator: TDefGenerator read EquipmentCache.DefGenerator write EquipmentCache.DefGenerator;

    procedure RepairBrokenEquipmentAtLocation; virtual; abstract; // @slot 0x60
    procedure BuildReachablePlanetQueue; virtual; abstract; // @slot 0x64
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; virtual; abstract; // @slot 0x68
    procedure SelectEnemyShipInStar; virtual; abstract; // @slot 0x6C
    procedure EngageEnemyShip; virtual; abstract; // @slot 0x70
    function RelationToRanger(Ranger: Pointer): Byte; virtual; abstract; // @slot 0x74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); virtual; abstract; // @slot 0x78
    procedure ReactToAttack(Attacker: TShip); virtual; abstract; // @slot 0x7C
    function RelationToNonRanger(Ship: TShip): Byte; virtual; abstract; // @slot 0x80
    function RelationToShip(Ship: TShip): TPercent; // @addr 0x006F3664
    function GetRelationLevelToShip(Ship: TShip): TRelationLevel; // @addr 0x006D42A4
    function GetRelationLevelTextToShip(Ship: TShip): WideString; // @addr 0x006D42E4 @note "Stations can display their stored ranger relation instead of the effective relation."
    function RecomputeFearState: Boolean; virtual; abstract; // @slot 0x84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; virtual; abstract; // @slot 0x88
    function TrustsAttackRequester(Ship: TShip): Boolean; virtual; abstract; // @slot 0x8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; virtual; abstract; // @slot 0x90 Relation/strength gate for protecting a ship or sparing pickup targets; other dialogue conditions are checked by the caller.

    procedure TransferToStar(Star: TStar); // @addr 0x006CB9A8 @note "Moves Self and docked ships between star lists; does not clear InHyperspace."
    procedure TryRelocateUnseenShip; // @addr 0x006CBBC8 @note "Can subsidize and queue an unseen NPC for relocation to a peaceful Coalition system; excludes protected quest/script/partner ships."
    procedure LeaveLiberationGroup; // @addr 0x006D633C @note "Requires a current liberation group."
    procedure ProcessLiberationGroupRoute; // @addr 0x006D5E78 @note "Requires an in-range route index when a group is assigned; may leave the group or issue travel/combat orders."
    procedure ReassignActiveItemSlots(ItemType: TItemType); // @addr 0x006E9980 @note "Repairs duplicate/out-of-range equipped slots; unequips overflow and preserves slot flag bit 7."
    procedure RefreshAssignedItemSlots; // @addr 0x006E9B74
    procedure RefreshInactiveItemSlotAssignments; // @addr 0x006E9C80
    procedure RepairDuplicateSatelliteTrajectoryIndices; // @addr 0x006E9D44
    function GetSatelliteTrajectoryIndexLimit: Integer; // @addr 0x006E9E0C @note "One past the largest carried satellite index, or zero."
    function FindFreeSatelliteTrajectoryIndex: Integer; // @addr 0x006E9E6C
    function FindSatelliteByTrajectoryIndex(Index: Integer): TSatellite; // @addr 0x006E9EC8
    procedure InsertSatelliteTrajectoryIndex(Index: Integer); // @addr 0x006E9F20 @note "Shifts indices at or above Index upward."
    procedure RemoveEmptySatelliteTrajectoryIndex(Index: Integer); // @addr 0x006E9F80 @note "Does nothing if Index is occupied."
    procedure CompactSatelliteTrajectoryIndices; // @addr 0x006E9FF0
    procedure AssignSatelliteIndicesFromHoldOrder; // @addr 0x006EA040 @note "Uses and refreshes global hold-view state."
    procedure ArrangeHoldSatellitesByTrajectoryIndex; // @addr 0x006EA258 @note "Reorders the satellite entries in the global hold view."
    function UseDominatorTransmitter(Artefact: TArtefactTransmitter): Boolean; // @addr 0x006EA534 @note "Requires minimum charge; records a galaxy event and consumes charge even if no Dominators respond."
    function HasMatchingArtefactOrCustomItem(Item: TItem): Boolean; // @addr 0x006EAAD8 @note "Custom items match by configuration name; generic artefacts also compare names."
    procedure ApplyNanoArtefactRepair; // @addr 0x006EB7B8 @note "Prefers installed inventory equipment; selects at most one repairable item and may clear BrokenFlag."
    function CanContactShip(OtherShip: TShip): Boolean; // @addr 0x006EBA6C @note "Uses Self's radar with a 500-unit minimum and both NoTalk flags; does not test system membership."
    function OpenPlayerConversation(RespectChameleon: Boolean): Boolean; // @addr 0x006EBFAC @note "Turn-worker/UI handshake; waits for conversation completion or shutdown. Requires an active visible-space turn."
    function ShowPlayerDialogue(Kind: TTalkEventKind; const Text: WideString; Amount: Integer): Byte; // @addr 0x006EC0F0 @note "Returns the global dialogue response, or zero when conversation cannot open. Amount only replaces the global amount when positive."
    procedure NotifyMoneyDemand(OtherShip: TShip; Response: WideString; Amount: Integer); // @addr 0x006EC144
    procedure NotifyCargoDemand(OtherShip: TShip; Response: WideString); // @addr 0x006EC3DC
    procedure NotifyFearCargoDrop(OtherShip: TShip); // @addr 0x006EC628
    procedure NotifyTruceOffer(OtherShip: TShip; Response: WideString; Amount: Integer); // @addr 0x006EC908
    procedure NotifyAttackRequest(OtherShip: TShip; Response: WideString; Target: TShip); // @addr 0x006ECBE4
    procedure NotifyPartnershipOffer(OtherShip: TShip; Response: WideString; Amount: Integer); // @addr 0x006ECEBC
    procedure NotifyPartnerBreak(Leader: TShip); // @addr 0x006ED174
    procedure NotifyPartnershipExpired(Leader: TShip); // @addr 0x006ED474
    procedure NotifyPartnerRebellion(Leader: TShip); // @addr 0x006ED858
    procedure ShowMessageToPlayer(Text: WideString); // @addr 0x006EDB54
    procedure NotifyPiratePartnerRelationBreak(Leader: TShip); // @addr 0x006EDC70
    procedure NotifyPiratePartnerRatingBreak(Leader: TShip); // @addr 0x006EDF7C
    procedure NotifyPiratePartnershipExpired(Leader: TShip); // @addr 0x006EE284
    procedure NotifyPiratePartnerRebellion(Leader: TShip); // @addr 0x006EE660
    function AcceptPickupItem(Item: TItem): Boolean; virtual; // @addr 0x006E1C8C @slot 0x94 @note "Base implementation returns false."
    function CalculatePartnershipMonths(Amount: Integer; OtherShip: TShip): Integer; // @addr 0x006EE95C @note "Payment/wealth and relation determine contract months; a player stimulant can double the result."
    function GetGreetingText: WideString; // @addr 0x006EEA48
    procedure InitializeScriptStateOrders; // @addr 0x006EF508 @note "Requires ScriptShip; clears EndState, applies state orders and refreshes completion/pickup state."
    procedure ApplyScriptStateOrders; // @addr 0x006EF530 @note "Requires ScriptShip; may issue travel orders and assign script-selected weapon targets."
    procedure UpdateScriptStateCompletionAndPickups; // @addr 0x006EF9E0 @note "Requires ScriptShip; updates EndState and queues state-requested pickups."
    function FindScriptFollowTarget: TShip; // @addr 0x006EFF94 @note "Requires ScriptShip; matches the state's group in the current system."
    procedure RemoveExperience(Amount: Integer); // @addr 0x006F01B8 @note "Subtracts independently from total and free experience, capped at each current balance."
    function CanTrainSkill(Skill: TPilotSkill): Boolean; // @addr 0x006F03BC
    function GetRelativeStrengthCategory: Byte; // @addr 0x006F0724 @note "Returns a category from 1 to 5 using StrengthInBestRanger."
    function GetHullConditionCategory: Byte; // @addr 0x006F0864 @note "Categories 1..5 split rounded hull percentage at 20, 50, 70 and 90."
    function IsFemaleHumanPilot: Boolean; // @addr 0x006F1728 @note "Human portrait IDs 25..32 on normal NPC ships; excludes special simulation mode."
    function UsesVeteranHumanRangerAppearance: Boolean; // @addr 0x006F1780 @note "Native resource key RangerOldFag; deterministic ID/creation-turn selection, excluding female pilots and the player."
    function SelectInterceptorTarget: TShip; // @addr 0x006F19AC
    procedure LaunchInterceptors; // @addr 0x006F1B1C @note "Clears an explicit target before checking energy; successful launch installs source/pass state and a graphic on the target."
    procedure ClearIncomingInterceptors; // @addr 0x006F1C4C @note "Clears source/pass state and releases the interceptor graphic."
    function CountActiveInterceptorTargets: Integer; // @addr 0x006F1C80 @note "Counts ships referring to Self as interceptor source across all galaxy systems."
    function GetHullEnergyRegeneration: Integer; // @addr 0x006F1D00
    function GetInterceptorEnergyCost: Integer; // @addr 0x006F1DE4
    function GetInterceptorPassCount: Byte; // @addr 0x006F1DFC @note "Hull override or five when zero."
    procedure SetStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer); // @addr 0x006F1F18 @note "Zero removes and frees the matching bonus entry; nonzero inserts or replaces it."
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; virtual; // @addr 0x006E1FE0 @slot 0x98 @note "Base implementation returns true."
    function HasScriptStateText: Boolean; // @addr 0x006F2A20
    procedure UpdateAfterburnerState; virtual; // @addr 0x006F29F4 @slot 0x9C @note "Native base implementation is a no-op."

    procedure ScriptNextDay; // @addr 0x006EFB4C @note "Requires ScriptShip; script execution can remove the binding."
    function ScriptItemsAct(ActionType: TScriptEventKind; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x006F2B98 @note "Returns Param after script handlers modify it; object slots may carry event-specific integer values."
    procedure ProcessCombatDialogue; virtual; abstract; // @slot 0xA0
    function ScanForCollectableItems: Boolean; // @addr 0x006E1720
    function TryCollectBestFloatingItem(MaximumTravelTurns: Integer): Boolean; // @addr 0x006E1860 @note "May queue nearby pickups and issue/cancel a move order; true means a move order remains."
    procedure ReactToExtortionDemand(Ranger: Pointer); virtual; abstract; // @slot 0xA4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; virtual; abstract; // @slot 0xA8
    procedure RemoveInvalidPickupTargets; // @addr 0x006E20A4 @note "Frees the target list when it becomes empty."
    function GetPickupApproachPosition(ItemPosition: TPointF): TPointF; // @addr 0x006E237C
    function GetCurrentPickupItem: TItem; // @addr 0x006E2400
    function GetArrivalPosition(DestinationStar: TStar): TPointF; // @addr 0x006E2694 @note "Point on the destination map boundary facing the current system."
    function GetMovementPathTurnCount: Integer; // @addr 0x006E2E78 @note "Ceiling of active path-node count times the star's MovementStepScale."
    function IsTravelCompletionPathReady: Boolean; // @addr 0x006E69D0 @note "Tests landing, jump, hole and teleport completion conditions against the prepared path."
    procedure RepelFollowingShips; // @addr 0x006E6B84 @note "Adjusts RepulsionPosition on Self and nearby following ships using their collision radii."
    procedure RebuildMovePath; // @addr 0x006E7140 @note "Uses the current turn's step limit; rewrites OrderDestination to the resulting endpoint."
    procedure BuildFullPathTo(Destination: TPointF); // @addr 0x006E7198 @note "Clears the old path and uses aGroup, a 999999-node limit."
    procedure BuildPlanetLandingPath; // @addr 0x006E71E0
    procedure BuildOrderMovementPath(MaximumNodes: Integer); // @addr 0x006E72B4 @note "Clears the path, normalizes heading and handles the current order; may commit jump departure or adjust the destination."
    procedure AppendPathToWithTurnPadding(Destination: TPointF; MaximumNodes: Integer); // @addr 0x006E7FC0 @note "Turning then straight movement; may pad the player's visible turn to 200 nodes."
    procedure AppendPathTo(Destination: TPointF; MaximumNodes: Integer); // @addr 0x006E80A8
    procedure AppendStarAvoidingPathWithTurnPadding(Destination: TPointF; MaximumNodes: Integer); // @addr 0x006E8138
    procedure AppendOrbitalPath(MaximumNodes: Integer); // @addr 0x006E820C @note "Appends up to 200 nodes around the system origin, with visible-turn padding."
    procedure AppendTurningPath(Destination: TPointF; AvoidStar: Boolean; MaximumNodes: Integer); // @addr 0x006E836C
    procedure AppendStraightPath(Destination: TPointF; MaximumNodes: Integer); // @addr 0x006E8B28
    procedure AppendHyperspaceTransitionPath(Direction: Single); // @addr 0x006E8E70 @note "Positive/negative Direction selects the outgoing/incoming transition path."
    procedure AppendStarAvoidingPath(Destination: TPointF; MaximumNodes: Integer); // @addr 0x006E9014
    procedure AppendCircularDetour(Destination: TPointF; MaximumNodes: Integer; Radius: Double); // @addr 0x006E939C

    procedure PrepareTurnMovement(StartStepIndex: Integer; RecordFilm: Boolean); // @addr 0x006E2FD0
    function ProcessMovementStep(StepIndex: Integer; RecordFilm: Boolean): Boolean; // @addr 0x006E5C6C @note "The native result remains false."
    procedure ClearCompletedTakeoffOrHoleOrder(UnusedStepIndex: Integer; UnusedRecordFilm: Boolean); // @addr 0x006E698C
    procedure RefreshDerivedStats(UpdateRelativeRatings: Boolean); // @addr 0x006D798C
    procedure UpdateBestRangerRelativeRatings; // @addr 0x006C9BD8
    procedure UpdateAverageRangerRelativeStrength; // @addr 0x006C9C4C @note "Does not guard against zero AverageRangerStrength."
    function GetRangerRatingBand: Byte; // @addr 0x006F0960 @note "Zero for non-rangers; otherwise 1..5 from the rounded experience-rank percentile. Uses all galaxy rangers, including excluded entries."
    function GetCaptainPortraitResourceBase: WideString; // @addr 0x006CA2E4 @note "May assign PortraitFaceId lazily. Returns a resource base without the GI prefix or animation suffix."
    function IsInPrison: Boolean; // @addr 0x006D4CE4
    function GetPrisonTermRemaining: Integer; // @addr 0x006D4D44 @note "Rangers and pirates only; other classes return zero."
    procedure ClearPrisonTerm; // @addr 0x006D4D84
    function GetPrisonReleaseCost: Integer; // @addr 0x006D4DC4 @note "Zero without a positive term; otherwise at least 100, using cached Wealth."
    function CalculateStrength: Double; // @addr 0x006CA0AC @note "Updates Strength; calculating the player's strength also refreshes galaxy ranger strength statistics."
    function CalculateAttackStrength: Double; // @addr 0x006C9D78
    function CalculateDefenseStrength: Double; // @addr 0x006C9F68
    function GetRepairStrengthFactor: Double; // @addr 0x006CA054
    function GetFullHullRelativeStrengthPercent: Byte; // @addr 0x006CA110 @note "Temporarily restores hull points. Leaves cached Strength and player galaxy-strength statistics at the full-hull values; byte result is not clamped."
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; virtual; abstract; // @slot 0xAC
    function NextRandomInteger(Minimum, Maximum: Integer): Integer; // @addr 0x006C8EE0
    function GetTurnSeedFraction(TurnOffset: Integer): Single; // @addr 0x006C98B0 @note "Fractional part of signed Seed divided by CurrentTurn + TurnOffset; denominator must be nonzero. Does not advance RandomState."
    function GetWealthScaledAmount(ScaleIndex: Byte): Integer; // @addr 0x006CA168 @note "Uses cached Wealth and the configured scale table; no index validation."
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; virtual; abstract; // @slot 0xB0
    function GetLocalizedTypeName: WideString; // @addr 0x006C8C84
    function GetFactionNameKey: WideString; // @addr 0x006C8DA8
    function GetDefaultHullType: THullType; // @addr 0x006C8E20
    function SelectRandomHullSeries: Integer; // @addr 0x006E1440 @note "Normal ships use PilotRace rather than OwnerId; selects rarity 1..100 through the galaxy RNG."
    function GetSpaceInfoText: WideString; // @addr 0x006C8EF0 @note "Requires a player; includes current order, hull, speed and relation information."
    function GetShipPortraitImagePath: WideString; // @addr 0x006CA214 @note "Leaves the result storage unchanged when Graphic is not a supported graphic class."
    procedure RefreshGraphicSize; // @addr 0x006D7ADC @note "Requires Graphic; chooses dimensions from ship class, hull and special equipment."
    function GetCargoGoodsWeight: Integer; // @addr 0x006D8110
    function CalculateFollowRadius: Integer; // @addr 0x006D8128 @note "Requires a follow order; uses weapon ranges or the ships' collision radii."
    function GetFollowMode: TFollowMode; // @addr 0x006D8294 @note "Requires a follow order."
    function GetEffectiveFollowMode: TFollowMode; // @addr 0x006D82E0 @note "Requires a follow order; adjusts the mode for tactics and map boundaries without changing the order."
    function NeedsEquipmentType(ItemType: TItemType): Boolean; // @addr 0x006D83FC
    function CountCarriedEquipmentByType(ItemType: TItemType): Integer; // @addr 0x006D84A0 @note "Skips inventory index zero; any weapon request counts all weapon types."
    function SelectBestUnequippedWeapon: TWeapon; // @addr 0x006D8500
    procedure DropUnequippedItemsAndGoods; // @addr 0x006D86FC @note "Preserves named script items; drops through the normal item/artefact helpers."
    procedure AddItemToPlayerStorage(Item: TItem; Location: TObject; Slot: Integer); // @addr 0x006D87A4 @note "Always adds to the player's storage, even when Self is an NPC. Caller must detach the item from its previous owner. Negative Slot allocates a free slot."
    procedure MergeItemIntoPlayerStorage(Item: TItem; Location: TObject; Slot: Integer); // @addr 0x006D8868 @note "Transfers ownership; a successful goods/countable merge frees Item."
    procedure AddGoodsToPlayerStorage(Good: Byte; Quantity, Cost: Integer; Location: TObject; Slot: Integer); // @addr 0x006D89E4 @note "Positive quantities only; Cost is the total cost basis, not a unit price."
    function StoreLooseInventoryAt(Location: TObject): Boolean; // @addr 0x006D8B64 @note "Uses the player's storage filters. Returns true for an eligible location even if nothing was moved."
    function RetrieveStoredItems(Location: TObject): Boolean; // @addr 0x006D8CD8 @note "Transfers matching player storage entries into Self; returns location eligibility, not whether items were retrieved."
    procedure AutoEquipArtefacts; // @addr 0x006D902C

    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; virtual; abstract; // @slot 0xB4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; virtual; abstract; // @slot 0xB8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; virtual; abstract; // @slot 0xBC
    function RefusesFactionNegotiation(OtherShip: TShip): Boolean; virtual; // @addr 0x006EE958 @slot 0xC0 @note "Rejects truce, extortion and protection negotiations for faction enemies. Base returns false; warrior/pirate overrides inspect OtherShip.CurrentStanding and system control."
    procedure AutoApplyMicroModules; // @addr 0x006DCD88 @note "Consumes beneficial carried modules, preferring installed equipment; refreshes derived stats after each application."
    procedure DropCargoUntilNotOverloaded; // @addr 0x006DD374 @note "Sells at a location or jettisons in space. May flag a long-stranded NPC for destruction when overload cannot be resolved."
    procedure DropRandomCheapItemsOnDestruction(Count: Integer); // @addr 0x006DDB8C
    procedure DropRandomValuableItemsOnDestruction(Count: Integer); // @addr 0x006DDDD4
    procedure DropItemsForDominatorProgram(Count: Integer); // @addr 0x006DDE1C @note "Requires a Dominator; used by dialogue and Script.DomikProgramm. Attempts at most 100 selections."

    procedure RefreshGraphic; // @addr 0x006CAFD0 @note "ScriptChameleon preserves the assigned graphic while updating GraphDominator."
    procedure CreateNormalGraphic; // @addr 0x006CB03C
    procedure CreateDominatorGraphic; // @addr 0x006CB834
    function SelectChameleonVisualType: TDominatorKind; // @addr 0x006CAE18
    function HasPlayerChameleonCharges: Boolean; // @addr 0x006CADE8 @note "Reads the player rather than Self; requires a player."
    function IsPlayerChameleonEffectiveAgainstSelf: Boolean; // @addr 0x006CAEE0 @note "Requires a player; action-17 script handlers can override the default result."

    // Except OrderJumpHole, new orders respect AbsoluteScriptOrder.
    procedure OrderNone(OverrideScriptOrder: Boolean); // @addr 0x006E2534
    procedure OrderMove(Destination: TPointF; Absolute: Boolean); // @addr 0x006E2560
    procedure OrderJump(Star: TStar; Absolute: Boolean); // @addr 0x006E27AC
    procedure OrderJumpHole(Hole: THole; Absolute: Boolean); // @addr 0x006E2828 @note "Does not check AbsoluteScriptOrder."
    procedure OrderLanding(Location: TObject; Absolute: Boolean); // @addr 0x006E28F4 @note "Location is a planet or dockable ship."
    procedure OrderTakeoff; // @addr 0x006E2968
    procedure OrderFollowShip(Ship: TShip; FollowMode: TFollowMode; Absolute: Boolean); // @addr 0x006E2E30
    procedure OrderTeleport(Star: TStar; Destination: TPointF; TransitionData: Integer; Absolute: Boolean); // @addr 0x006E28A0
    procedure ClearMovementPath; // @addr 0x006E9638
    function HasLockedOrFollowOrder: Boolean; // @addr 0x006C9A44 @note "True for OrderAbsolute, AbsoluteScriptOrder, or a follow-ship order."
    procedure CancelInvalidTravelOrder; // @addr 0x006CC054 @note "Checks only ships in star space; clears the player auto-follow target when cancelling."
    procedure SynchronizeDockedLocation; // @addr 0x006CBEC8 @note "Copies the carrier's star and position, moving star-list membership when necessary. Does nothing without DockedTo."
    procedure OrderRandomFreeFlightMove; // @addr 0x006CC900
    function TryMirrorPartnerTravelOrders: Boolean; // @addr 0x006CC3E0 @note "Requires a ranger PartnerShip. True reports handled travel, not necessarily a changed or accepted order."
    function CanEscapePursuer(Pursuer: TShip): Boolean; // @addr 0x006CC9A8 @note "AI estimate using range, hull and travel time. Pursuer weapon range is evaluated using Self's bonuses."
    function FindNextStarTowardDestination(Destination: TStar; RequireFuelMargin: Boolean): TStar; // @addr 0x006CCC70 @note "Returns a borrowed intermediate star or nil. Uses raw full-fuel range and current distance caches; excludes sector 20. A direct reachable destination returns the current star."
    function IsTargetStillPursuable(Target: TShip): Boolean; // @addr 0x006CC96C @note "False only when Target is jumping and its distance is at least twice Self.Speed; does not validate shared star or speed."
    function HasLandablePlanetInStar(Star: TStar): Boolean; // @addr 0x006CCBFC
    function FindFirstInhabitedPlanetInStar: TPlanet; // @addr 0x006CC298 @note "Requires a nonempty planet list; returns the last planet if all are uninhabited."
    function FindNearestDockableStation(StandingMask: TShipStandings): TShip; // @addr 0x006CC1C8 @note "Types 6..13 whose CanDock(Self) succeeds. Zero mask permits every standing; does not independently filter hyperspace/docking."
    function GetFullFuelBaseJumpRange: Integer; // @addr 0x006CCC4C @note "Minimum of raw tank Capacity and engine JumpRange; requires both items and ignores bonuses/condition."
    function DistanceToNearestShipByTypeMask(ShipTypeMask: TShipTypeMask): Double; // @addr 0x006CCF14 @note "Excludes Self but includes docked/hyperspace entries; no match returns sqrt(1000000000)."
    function EstimateOrderTravelTurns: Integer; // @addr 0x006CCFA8 @note "Uses rounded distance / (Speed + 1) + 1; unsupported orders return zero."
    function EstimateTravelTurnsToObject(Target: TObject): Integer; // @addr 0x006CD114 @note "Accepts planet, ship or star; a star estimates travel to the current system boundary, excluding hyperspace transit. Other classes return zero."
    function EstimateTravelTurnsToPlanet(Planet: TPlanet): Integer; // @addr 0x006CD294 @note "Returns -1 for zero speed, nil planet/star, or a different star."
    procedure RefreshCurrentStanding; virtual; // @addr 0x006F29F8 @slot 0xC4
    function CalculateJumpTravelDays(Origin, Destination: TStar): Integer; // @addr 0x006E2734 @note "Minimum two days; independent of equipment and fuel."
    function GetJumpDeparturePoint(Destination: TStar): TPointF; // @addr 0x006E25C0

    function LookupTalkText(const Path: WideString): WideString; // @addr 0x006EBB6C @note "Selects among at most ten contiguous variants using ship seed and turn; substitutes ship names and HomePlanet. Missing text returns an unavailable marker."
    function LookupVisibleTalkText(const Path: WideString; OtherShip: TShip): WideString; // @addr 0x006C9AF8 @note "Returns empty unless the player shares CurrentStar. Substitutes OtherShip for <TalkShip>."

    function InNormalSpace: Boolean; // @addr 0x006CBF48
    function IsOutsideStarSpace: Boolean; // @addr 0x006CBFB0 @note "True without a current star, while docked/in hyperspace, or with a saved player ruins docking target."
    function IsOnPlanet: Boolean; // @addr 0x006CBFFC
    function IsDockedToShip: Boolean; // @addr 0x006CC004
    function IsDocked: Boolean; // @addr 0x006CC00C
    function IsHullDestroyed: Boolean; // @addr 0x006C989C
    function HasPositiveSpeed: Boolean; // @addr 0x006CC020
    procedure UpdateSpeedTrackingMetrics; // @addr 0x006DB3F4
    function HasHullDamageOrBrokenEquippedItems: Boolean; // @addr 0x006C9A68
    procedure FireWeaponAtAsteroid(Weapon: TWeapon; Target: TObject; RecordFilm: Boolean); // @addr 0x006D2138 @note "Ignores non-asteroid targets. Respawning preserves the target object but invalidates its previous motion and mineral reserve."
    procedure FireWeaponAtMissile(Weapon: TWeapon; Target: TObject; RecordFilm: Boolean); // @addr 0x006CFE04 @note "Ignores non-missile targets; can free the target and nearby missiles."
    procedure FireWeaponAtShip(Weapon: TWeapon; Target: TShip; RecordFilm: Boolean); // @addr 0x006D08CC @note "Can affect additional ships through chained, area or penetrating fire."
    procedure FireWeaponAtItem(Weapon: TWeapon; Target: TItem; RecordFilm: Boolean); // @addr 0x006D1B2C @note "Weapon may be nil. Script handlers can change the target; a destroyed item may explode and be freed."
    function ApplyDamage(Source: TObject; Damage: Integer; HitRange: Single; out DamageColor: Cardinal; DamageFlags: TDamageFlagSet): Integer; // @addr 0x006CD5E0 @ida "int __userpurge $name@<eax>(TShip *Self@<eax>, TObject *Source@<edx>, int Damage@<ecx>, float HitRange@<^8>, unsigned int *DamageColor@<^4>, unsigned int DamageFlags@<^0>);" @note "Source may be nil, ship or missile. HitRange=-1 selects direct-hit rules; other values select area-hit rules. Returns adjusted damage, zero for rejection, or negative damage for an impulse-shield block; not actual hull loss. May run death handling without freeing Self."
    function ApplyWeaponHit(Source: TShip; Weapon: TWeapon; HitRange: Single; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet; DamageScale: Single; FixedDamage: Integer): Integer; // @addr 0x006CF4B4 @note "Returns ApplyDamage's signed result. Positive FixedDamage bypasses the initial roll/armor stage unless weapon flag 0x800 is already set; later effects still apply."
    function ApplyMissileHit(Missile: TObject; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet): Integer; // @addr 0x006CFB10 @note "Requires a TMissile; returns ApplyDamage's signed result."
    function ApplyInterceptorDamage(out DamageColor: Cardinal): Integer; // @addr 0x006D2360 @note "Uses InterceptorSourceShip; absent source gives base damage 25. Returns ApplyDamage's signed result."
    function GetInterceptorDamage: Integer; // @addr 0x006F1D94
    function ApplyShockStatusDamage(out DamageColor: Cardinal): Integer; // @addr 0x006D2464 @note "Uses rounded shock strength and nonlethal flag 0x1000; returns ApplyDamage's signed result."
    function ApplyExplosionDamage(SourceShip: TShip; ExplodingObject: TObject; ExtraDamage: Integer; Missile: TObject): Integer; // @addr 0x006D27F4 @note "ExplodingObject may be an item or ship; SourceShip and Missile may be nil. Returns script-adjusted damage, not actual hull loss; can trigger death handling without freeing Self."
    function ApplyStarHeatDamage: Integer; // @addr 0x006D2C58 @note "Also refuels up to five units inside the damage radius. Returns script-adjusted damage; Dominator bosses survive with at least one hull point."
    procedure NotifyCompanionDeath; // @addr 0x006CD2F0 @note "Ranger, pirate or Tranclucator death notification; does not itself check player partnership."
    function ApplyAsteroidImpactDamage(Asteroid: TAsteroid; out DamageColor: Cardinal): Integer; // @addr 0x006D2498 @note "Returns script-adjusted damage, which may exceed actual hull loss. DamageColor uses the current packed pixel format and is zero for nonpositive damage."
    function CanDock(Ship: TShip): Boolean; virtual; // @addr 0x006F3650 @slot 0xC8 @note "Base implementation always returns false."
    procedure ClearPlanetQueue; // @addr 0x006CC0E4
    procedure TruceWithShip(Ship: TShip); // @addr 0x006D45F4 @note "Cancels reciprocal attacks and pursuers, including wingmen/Tranclucators and missiles. Only the player's TruceShip is set reciprocally."
    procedure SetJointAttackTarget(Ally, Target: TShip); // @addr 0x006D3EC8 @note "Assigns both ships' enemies and eligible weapons, then issues pursuit orders where possible."
    function IsEnemyPursuingSelf: Boolean; // @addr 0x006D4060
    function TryExtortShip(Target: TShip): Boolean; // @addr 0x006D4390 @note "Attempts a cargo or money demand through the target's dialogue handler; requires a player."
    procedure RequestAlliesAttackShip(Target: TShip); // @addr 0x006D490C @note "May ask the player or nearby allied NPCs; requires a player."
    procedure SetStoredRangerRelationLevel(Ranger: TShip; Level: TRelationLevel); // @addr 0x006D4144 @note "Requires a non-nil relation list; nonempty lists require a registered ranger. Stores representative values 5, 20, 45, 70 or 90."
    function SelectNearestQueuedPlanet: TPlanet; // @addr 0x006CC100 @note "Requires a non-nil queue ordered with current-star planets first; otherwise falls back to the first entry. Empty queue returns nil."
    function NavigateToQueuedPlanet(Absolute: Boolean): TPlanet; // @addr 0x006CC2E0 @note "Can build PlanetQueue and issue a landing or jump order. Result is borrowed and may be nil."
    function NavigateToEscapePlanet(Absolute: Boolean): Boolean; // @addr 0x006CC344 @note "Uses the existing PlanetQueue; false means it is nil or empty. True does not guarantee that the order was accepted."
    procedure SetMoney(Value: Integer); // @addr 0x006C7938 @note "Clamps to 0..100000000."
    function CalculateWealth: Integer; // @addr 0x006C9C68 @note "Updates Wealth. Includes player storage and accrued deposit but does not subtract debt; capped at MaxInt."
    function CalculateEquippedItemCostWithoutHull: Integer; // @addr 0x006D8438 @note "Includes equipped artefacts."

    function GetHull: THull; // @addr 0x006D6550
    function GetFuelTanks: TFuelTanks; // @addr 0x006D6558
    function GetEngine: TEngine; // @addr 0x006D6560
    function GetRadar: TRadar; // @addr 0x006D6568
    function GetScanner: TScaner; // @addr 0x006D6570
    function GetRepairRobot: TRepairRobot; // @addr 0x006D6578
    function GetCargoHook: TCargoHook; // @addr 0x006D6580
    function GetDefGenerator: TDefGenerator; // @addr 0x006D6588
    function CanUseEquipmentTech(Item: TEquipment): Boolean; // @addr 0x006D6604
    function CanRepairEquipmentTech(Item: TEquipment): Boolean; // @addr 0x006D66A8
    function IsEquipmentUsable(Item: TEquipment): Boolean; // @addr 0x006D6768 @note "Does not require EquippedFlag."
    procedure RebuildEquipmentCache; // @addr 0x006D7F5C @note "Can unequip items whose slots are unavailable."
    procedure EquipItem(Item: TEquipment); // @addr 0x006D67A0 @note "Does not add Item to the inventory."
    procedure UnequipSlot(ItemType: TItemType; WeaponIndex: Integer); // @addr 0x006D6828 @note "Direct types 42..49 require a populated slot; weapon types 50..68 require a valid one-based WeaponIndex. Compacts the weapon cache; does not remove/free inventory."
    procedure UnequipItem(Item: TEquipment); // @addr 0x006D68B0 @note "Only affects cached installed equipment. Requires non-nil Item."
    function CanRepairArtefactsAtLocation: Boolean; // @addr 0x006D6590 @note "Pirate/science bases, licensed station names and the main pirate planet; follows DockedTo recursively."
    function CountEquippedWeapons: TWeaponCount; // @addr 0x006D3138
    function CountMissileWeapons: TWeaponCount; // @addr 0x006D317C @note "Counts torpedo/missile/rocket shot types; does not check usability or ammunition."
    function CountDirectFireWeapons: Byte; // @addr 0x006D31B8 @note "Complement of CountMissileWeapons over cached equipped weapons."
    function CountWeaponsByDamageFlags(Flags: TDamageFlagSet): TWeaponCount; // @addr 0x006D3260 @note "Counts any intersection; does not check usability or ammunition."
    procedure ClearUnequippedWeaponTargets; // @addr 0x006D31F4
    procedure ClearWeaponTargets(Target: TObject); // @addr 0x006D3880 @note "Nil clears every cached weapon target; otherwise clears only matches."
    function IsAttackingShip(Target: TShip): Boolean; // @addr 0x006D38D4 @note "Includes weapon targets, interceptor attribution and shock/acid source IDs; requires non-nil Target."
    function CanSafelyDetonateItem(Item: TItem): Boolean; // @addr 0x006D4098 @note "Rejects bomb/explosive cargo near non-hostile normal-space ships, including Self. Does not test shot range."
    function GetWeaponDamageSummary: WideString; // @addr 0x006D32A8
    function GetManeuverabilitySummary: WideString; // @addr 0x006D358C
    function GetRepairPointsSummary: WideString; // @addr 0x006D3624
    function HasScannerArtefact(UnusedTarget: TShip): Boolean; // @addr 0x006D36A0 @note "Callers pass the target ship in EDX. This routine ignores it and only checks Self's active scanner artefact count."
    function GetWeaponActionRange(Weapon: TWeapon): Integer; // @addr 0x006D36B4 @note "Same result as GetWeaponRange in this binary."
    function HasNoUsableWeapons: Boolean; // @addr 0x006F1E5C
    function GetWeaponRange(Weapon: TEquipment): Integer; // @addr 0x006D9F3C
    function GetWeaponSlotRange(SlotIndex: Integer): Integer; // @addr 0x006D36BC @note "Weapon slots are numbered 1..5."
    function GetMaxWeaponRange: Integer; // @addr 0x006D3830
    function ChanceToWin(Target: TShip): Double; // @addr 0x006D3938 @note "Returns a combat strength ratio, not a probability."
    function GetWinChancePercent(Target: TShip): TPercent; // @addr 0x006D3E4C
    function GetWeaponMinDamage(Weapon: TWeapon): Integer; // @addr 0x006D36CC
    function GetWeaponMaxDamage(Weapon: TWeapon): Integer; // @addr 0x006D36F4
    function GetAttackMultiplier: Integer; // @addr 0x006D78C8
    procedure ReloadWeaponAmmo; // @addr 0x006DF580

    function CreateAndEquipHull(Capacity: Word; Level: Byte; Owner: TOwnerId; Series: Integer; PirateBuilt: Boolean): THull; // @addr 0x006E13D4
    function CreateAndEquipFuelTanks(Weight: Integer; Level: Byte; Owner: TOwnerId): TFuelTanks; // @addr 0x006E149C
    function CreateAndEquipEngine(Weight: Integer; Level: Byte; Owner: TOwnerId): TEngine; // @addr 0x006E14EC
    function CreateAndEquipRadar(Weight: Integer; Level: Byte; Owner: TOwnerId): TRadar; // @addr 0x006E153C
    function CreateAndEquipScanner(Weight: Integer; Level: Byte; Owner: TOwnerId): TScaner; // @addr 0x006E158C
    function CreateAndEquipRepairRobot(Weight: Integer; Level: Byte; Owner: TOwnerId): TRepairRobot; // @addr 0x006E15DC
    function CreateAndEquipCargoHook(Weight: Integer; Level: Byte; Owner: TOwnerId): TCargoHook; // @addr 0x006E162C
    function CreateAndEquipDefGenerator(Weight: Integer; Level: Byte; Owner: TOwnerId): TDefGenerator; // @addr 0x006E167C
    function CreateAndEquipWeapon(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId): TWeapon; // @addr 0x006E16CC

    function GetEquipmentStatBonus(BonusKind: TEquipmentBonusKind; Item: TEquipment): Integer; // @addr 0x006D7158
    function GetTotalStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x006D718C
    function GetOwnStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x006F1EC8

    function CalculateHullArmor(Hull: THull): Integer; // @addr 0x006DA070
    function CalculateEngineSpeed(Engine: TEngine; ApplyBrokenPenalty: Boolean): Integer; // @addr 0x006DA10C
    function CalculateEngineJumpRange(Engine: TEngine): Integer; // @addr 0x006DA224
    function CalculateRadarRange(Radar: TRadar): Integer; // @addr 0x006DA330
    function CalculateScannerPower(Scanner: TScaner): Integer; // @addr 0x006DA3A8
    function CalculateRepairPoints(RepairRobot: TRepairRobot): Integer; // @addr 0x006DA424
    function CalculateCargoHookPower(CargoHook: TCargoHook): Integer; // @addr 0x006DA4A0
    procedure AutoEquipInventory; // @addr 0x006DD014
    function DropCarriedItemAsMovingLoot(Item: TItem): Boolean; // @addr 0x006DE054 @note "Requires membership in Inventory; honors ship/item NoDrop and rejects the hull. True means accepted, even if a script consumes the drop."
    function DropCarriedArtefactAsMovingLoot(Item: TArtefact): Boolean; // @addr 0x006DE0B4 @note "Requires membership in Artefacts; honors ship/item NoDrop."
    procedure DropGuaranteedDeathDropItems; // @addr 0x006DE134
    function CanDropTreasureMap: Boolean; // @addr 0x006DE18C @note "Deterministic eligibility roll for an ordinary pirate without a script binding or player partnership."
    function SelectTreasureMapPlanet: TPlanet; // @addr 0x006DE1F0 @note "Searches reachable uninhabited planets with accessible artefact/module loot; excludes maps already carried or stored by the player."
    function TryDropTreasureMap: Boolean; // @addr 0x006DE430
    function DropItemIntoStar(Item: TItem): Boolean; // @addr 0x006DE49C @note "Player drops are placed immediately and may be consumed by scripts or stellar heat. Native artefact branch mistakenly deletes Inventory at the Artefacts index."
    procedure DropAllArtefactsOnDestruction; // @addr 0x006DE7B8
    procedure DropGoodsIntoSpace(Good: Byte; Count: Integer); // @addr 0x006DE7EC @note "Caller supplies a valid good and quantity; does not itself honor ship NoDrop."
    function JettisonCargoGoodsTowardTargetValue(TargetValue: Integer): Boolean; // @addr 0x006DE85C
    procedure DropAllCargoGoods; // @addr 0x006DE9B4
    procedure QueueMovingItemDrop(Item: TItem; DeployTranclucator: Byte); // @addr 0x006DE9DC @note "Caller detaches Item first. Script action 33 can suppress transfer or free Item; otherwise the moving-drop descriptor takes ownership."
    function SelectLeastValuableInventoryItem: TItem; // @addr 0x006DEC48 @note "Considers protection, essential equipment and value per mass; can return the hull when no alternative qualifies."
    function SelectLeastValuableArtefact: TArtefact; // @addr 0x006DEDA0 @note "Native scan starts at index one; an artefact list with one element yields nil."
    function SelectCheapestCargoGood: Byte; // @addr 0x006DEE44 @note "Returns 255 if no cargo qualifies."
    procedure LiquidateInventoryItem(Item: TItem); // @addr 0x006DF2D0 @note "Normally credits resale value and frees Item; eligible NPC node stacks instead feed DepositCarriedNodes and automatic training."
    procedure LiquidateArtefact(Item: TArtefact); // @addr 0x006DF3C0 @note "Removes and frees Item after crediting resale value."
    procedure ApplyCombatItemDegradation(BaseDurabilityDamage: Double); // @addr 0x006DF5C0
    procedure ApplyArtefactUseDegradation(BaseDurabilityDamage: Double); // @addr 0x006DF824
    procedure ApplyAfterburnerItemDegradation; // @addr 0x006DF8C8
    function ApplyItemDegradation(Item: TEquipment; Kind: TItemWearKind; DurabilityDamage: Double): Boolean; // @addr 0x006DF93C @note "True only when the item becomes newly broken. Nil is accepted; script actions 36..39 can modify the damage."
    function CanGenerateMicroModuleForLoadout: Boolean; // @addr 0x006DFDCC
    function CanGenerateSpecialHullModule: Boolean; // @addr 0x006DFEE0 @note "True for the player or when the current hull already has a special module."
    procedure ImproveRandomEquipment(ResolveOverload: Boolean); // @addr 0x006DFF04
    procedure GenerateAndApplyMicroModule(Item: TEquipment; ResolveOverload: Boolean); // @addr 0x006E028C @note "Selects up to three qualifying candidates within 51 attempts, applies the best positive gain, then auto-equips. Nil Item is accepted."
    procedure GenerateExtraWeapon; // @addr 0x006E03D8 @note "Adds a generated weapon, may improve/module it, then auto-equips and optimizes inventory."
    function NeedsMicroModule(ModuleIndexPlusOne: Integer): Boolean; // @addr 0x006E05B0 @note "Requires an installable target and no carried module of the same index."
    function GetSatelliteLimit: Integer; // @addr 0x006E0698
    function IsEssentialInventoryItem(Item: TItem): Boolean; // @addr 0x006E06C4 @note "Includes protected/script-named items and indispensable installed equipment; nil is false."
    function IsOptionalUtilityEquipment(Item: TItem): Boolean; // @addr 0x006E0744 @note "Radar/scanner, or cargo hook on a ship other than a ranger or pirate. Nil is false."

    procedure OptimizeInventory; // @addr 0x006DEF7C @note "Can sell equipment, artefacts and excess cargo; outside a market, excess goods are refunded at their cost basis."
    function RepairHullAtLocation: Boolean; // @addr 0x006DF418 @note "Returns whether AI should remain docked; false does not guarantee full repair. Does not charge Money."
    function NeedsEssentialEquipment: Boolean; // @addr 0x006E0778
    procedure RestoreEssentialEquipment; // @addr 0x006E07BC @note "Can subsidize equipment purchases; does not guarantee success."
    procedure BuyEquipmentAtLocation(ForceGeneratedOffers: Boolean); // @addr 0x006E09A4
    function CalculateDefGeneratorFactor(DefGenerator: TDefGenerator): Single; // @addr 0x006DA518
    function GetRadarRange: Integer; // @addr 0x006D7288
    function GetScannerPower: Integer; // @addr 0x006D72FC
    function CanResolveObjectWithScanner(Target: TObject): Boolean; // @addr 0x006D7348 @note "Ignores radar range and Dominator scanner series; non-ship targets require only a usable scanner."
    function GetCargoHookRange: Integer; // @addr 0x006D77E4
    function GetCargoHookMinPullSpeed: Single; // @addr 0x006D7614
    function GetCargoHookMaxPullSpeed: Single; // @addr 0x006D76FC
    function GetDefenseDamageFactor: Double; // @addr 0x006D786C @note "1 means no damage reduction."
    procedure ApplyRepairDroidHealing; // @addr 0x006D73F8
    function GetHullIntegrityPercent: TPercent; // @addr 0x006D6B64 @note "Not clamped to 0..100."
    function GetArmor: Integer; // @addr 0x006D6B9C
    function GetJumpRange: Integer; // @addr 0x006D6E6C @note "Ignores fuel; broken engines retain 60% range."
    function GetFuelLimitedJumpRange: Integer; // @addr 0x006D6E00
    function GetCarriedItemWeight: Integer; // @addr 0x006D80B4 @note "Excludes the hull."
    function CalculateMass: Integer; // @addr 0x006D6920 @note "Uses cached CargoFreeSpace; includes cargo, artefact and status modifiers."
    function CalculateEquippedMass(ItemForModule: TEquipment): Integer; // @addr 0x006D6A34 @note "Excludes cargo and unequipped items. Uses the current hull, adding ItemForModule's micromodule mass bonus when supplied."
    function GetCargoFreeSpace: Integer; // @addr 0x006D8090 @note "Can be negative."
    function GetCarriedNodeCount: Integer; // @addr 0x006C9A08
    function HasCargoGoods: Boolean; // @addr 0x006C99CC
    function CountCargoGoodsTypes: Byte; // @addr 0x006C99EC @note "Counts positive cargo quantities."
    function FindCarriedItemById(Id: Cardinal): TItem; // @addr 0x006CBA34 @note "Includes artefacts, guaranteed drops, stored Tranclucator inventories and station shop stock; result is borrowed."
    function CanRefuel: Boolean; // @addr 0x006C9AC4
    function GetFullRefuelCost: Integer; // @addr 0x006D6C04 @note "Zero without tanks. Uses current planet owner, or owner six off-planet; overfilled tanks can produce a negative cost."
    function GetJumpDestinationDistance: Integer; // @addr 0x006D6BCC @note "Truncated map distance for a jump order; zero otherwise."
    function GetAfterburnerWear: Integer; // @addr 0x006D6D30 @note "Uses engine owner and current turn; no engine gives one before artefact modifiers."
    function HasLooseNonScriptItemsOrGoods: Boolean; // @addr 0x006D8658
    function GetAverageCargoCost(Good: TGoodsIndex): Double; // @addr 0x006D5548 @note "Returns 0 for an empty cargo entry."
    function GetLocationGoodsEntry(Good: Byte): PGoodsTradePriceEntry; // @addr 0x006D4E10 @note "Result is borrowed; raises when no market is available."
    function ShopGoodsPurchasePrice(Good: Byte; Location: TObject): Integer; // @addr 0x006D5094 @note "Location is a planet or station; nil selects the current trade context."
    function ShopGoodsSellPrice(Good: Byte; Location: TObject): Integer; // @addr 0x006D52AC @note "Includes the Trading skill bonus. Location=nil selects the current trade context."
    procedure ConsumeCargoGoods(Good: Byte; Count: Integer); // @addr 0x006D557C @note "Count is not clamped; remaining cost basis uses the previous average price."
    procedure BuyGoodsFromLocation(Good: Byte; Count: Integer); // @addr 0x006D5BFC @note "Checks stock and cash, but not free cargo space or negative Count."
    procedure SellGoodsToLocation(Good: Byte; Count: Integer); // @addr 0x006D5638 @note "Rejects Count above carried stock; does not reject a negative Count. Player trade losses offset later profit before trade experience is awarded."
    function IsCargoGoodIllegalOnCurrentPlanet(Good: Byte): Boolean; // @addr 0x006D55C8

    function GetSlotCount(SlotKind: TShipSlotKind): Integer; // @addr 0x006E9644
    function GetSlotCountForItemType(ItemType: TItemType): Integer; // @addr 0x006E9964
    // Slot indices are zero-based.
    function FindEquippedItemInSlot(ItemType: TItemType; SlotIndex: Integer): TEquipment; // @addr 0x006E9BD4
    function CountUnequippedItemsInSlot(SlotIndex: Integer): Integer; // @addr 0x006E9CDC
    function FindFreeUnequippedSlot: Integer; // @addr 0x006E9D28
    function HasScriptControl: Boolean; // @addr 0x006F1E24
    function HasScriptBindings: Boolean; // @addr 0x006CA1E4 @note "For the player, checks the script-binding list; for NPC ships, checks ScriptShip."
    function HasIndependentScriptFaction: Boolean; // @addr 0x006F2A44 @note "Requires a nonempty faction not beginning with SubFaction. The native substring result is used as Boolean, so absence also returns true."
    function HasNamedScriptFaction: Boolean; // @addr 0x006F2A98 @note "Requires a nonempty faction other than the exact SubFactionFixedStanding marker."
    function GetScriptStandingOverrideMode: TStandingOverride; // @addr 0x006F2B00 @note "0 normal, 1 independent faction, 2 fixed standing. The SubFaction substring test accepts absence as mode one."

    function CountActiveArtefacts(ArtefactType: TItemType): Integer; // @addr 0x006EAB98 @note "Uses custom SharedEffect types and excludes broken items. Activation exceptions can count some unequipped artefacts."
    function HasEquippedArtefactOfSameUseGroup(Item: TItem): Boolean; // @addr 0x006EAC4C @note "Uses custom SharedUse and ConfigBlockName. Includes Item itself if equipped, and does not exclude broken items."
    function CanBoostArtefact(ArtefactType: TItemType; Item: TEquipment; IgnoreArtefactAvailability: Boolean): Boolean; // @addr 0x006EAD84 @note "Item=nil checks cached installed equipment. A supplied item need not be equipped; eligible equipment types depend on ArtefactType."

    procedure AddPickupTarget(Item: TItem; Prioritize: Boolean); // @addr 0x006E1FEC @note "Existing targets keep their position."
    procedure RemovePickupTarget(Item: TItem); // @addr 0x006E2048
    procedure ClearPickupTargets; // @addr 0x006E2088
    function HasPickupTarget(Item: TItem): Boolean; // @addr 0x006E21FC
    function GetReservedPickupWeight: Integer; // @addr 0x006E1C0C
    function CountOtherShipsTargetingItem(Item: TItem): Integer; // @addr 0x006E2228
    procedure TogglePickupTargets(IgnoreRange: Boolean); // @addr 0x006E2144 @note "Adds missing eligible targets; removes eligible targets only if none were added."
    procedure QueueItemsWithinPickupRange; // @addr 0x006E17D0
    function IsItemInPickupRange(Item: TItem): Boolean; // @addr 0x006E1C44 @note "Also checks hook eligibility."
    function GetCargoHookRangeSquared: Integer; // @addr 0x006D783C
    function GetBaseCargoHookPower: Integer; // @addr 0x006D784C @note "Raw PickupPower; zero without a hook. Does not check usability."
    function GetDefensePercent: TPercent; // @addr 0x006D78B0
    function IsMicroModuleRaciallyRestricted(ModuleIndex: Integer): Boolean; // @addr 0x006D6ED4 @note "Zero-based template index; true means disallowed. Includes custom faction, Dominator series and pilot-race restrictions."
    procedure AddAward(AwardId: Byte); // @addr 0x006D78E0 @note "Rejects ID 255 and appends without deduplication; stops when list count equals 255. Extends the visible prefix only when all previous awards were visible."
    function ShouldPickUpItem(Item: TItem): Boolean; // @addr 0x006E1C90
    function CanReachItemBeforeOtherShips(Item: TItem): Boolean; // @addr 0x006E228C @note "Ties are allowed; requires positive speed."
    procedure AddRecentlyDroppedItem(Item: TItem); // @addr 0x006E24C4
    procedure ClearRecentlyDroppedItems; // @addr 0x006E24A8
    function IsRecentlyDroppedItem(Item: TItem): Boolean; // @addr 0x006E2508

    function HasActiveDisease: Boolean; // @addr 0x006F0A88
    function CountActiveDiseases: Integer; // @addr 0x006F0AB8
    function HasPresentDisease: Boolean; // @addr 0x006F0AE8
    function CountPresentDiseases: Integer; // @addr 0x006F0B18
    function HasActiveStimulant: Boolean; // @addr 0x006F0B48
    function CountActiveStimulants: Integer; // @addr 0x006F0B78
    function CountPresentDiseasesAndActiveStimulants: Integer; // @addr 0x006F0BA8
    function IsHealthEffectActive(Index: TCaptainHealthEffect): Boolean; // @addr 0x006F0D04 @note "Active when Progress = 100."
    function HasRadiationSickness: Boolean; // @addr 0x006F10CC
    function HasDiseaseFromCurrentPlanet: Boolean; // @addr 0x006F0BC4
    function HasDiseaseFromCurrentDockedShip: Boolean; // @addr 0x006F0C6C
    procedure SimulateNpcHealthEffects; // @addr 0x006F0D24
    procedure ClearCombatStatusEffects; // @addr 0x006F2200 @note "Frees entries but keeps the list."
    function FindCombatStatusEffect(EffectType: TCombatEffectKind): Integer; // @addr 0x006F1FFC @note "Returns the list index, or -1."
    procedure AddCombatStatusStrength(EffectType: TCombatEffectKind; Strength: Single; Source: TShip); // @addr 0x006F204C @note "Scales by hull and existing strength. Always replaces the source ID, including clearing it for nil Source; no sign validation."
    procedure ReduceCombatStatusStrength(EffectType: TCombatEffectKind; Amount: Single); // @addr 0x006F218C @note "Removes only entries reduced below zero; exactly zero remains. Negative Amount increases strength."
    procedure DecayCombatStatusEffects; // @addr 0x006F2244 @note "Daily decay; exactly zero remains until a subsequent reduction."
    function GetShockStatusDecay(Strength: Single): Single; // @addr 0x006F235C
    function GetAcidStatusDecay(UnusedStrength: Single): Single; // @addr 0x006F2400
    function GetMagneticStatusDecay(Strength: Single): Single; // @addr 0x006F24B4
    function GetWeaponBlockStatusDecay(Strength: Single): Single; // @addr 0x006F2514
    function GetDroidBlockStatusDecay(Strength: Single): Single; // @addr 0x006F2534
    function GetBWBuffStatusDecay(Strength: Single): Single; // @addr 0x006F2554
    function GetBWRepairDebuffStatusDecay(Strength: Single): Single; // @addr 0x006F2584
    procedure ClearCombatStatusSourceReferences(Source: TShip); // @addr 0x006F25B4 @note "Requires non-nil Source; clears matching IDs without changing effect strengths."
    function GetCombatStatusStrength(EffectType: TCombatEffectKind): Single; // @addr 0x006F2608 @note "Zero when absent."
    function GetCombatStatusSourceId(EffectType: TCombatEffectKind): Cardinal; // @addr 0x006F263C @note "Zero when absent or unattributed."
    function GetCombatStatusDescription(out Count: Integer; ShowStrength: Boolean): WideString; // @addr 0x006F2780 @note "Includes rounded-positive shock, acid, magnetic, BW buff and custom status entries; omits transient blocking effects."

    function GetBaseSkillLevel(Skill: TPilotSkill): Byte; // @addr 0x006F03F8
    function GetEffectiveSkillLevel(Skill: TPilotSkill; IgnoreStatusEffects: Boolean = False): TPilotSkillLevel; // @addr 0x006F0404 @note "Clamps to 0..6; equipment bonuses still apply when status effects are ignored."
    function CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean; virtual; // @addr 0x006F3654 @slot 0xCC @note "Base implementation clears Response and returns false."
    function CountUnequippedDominatorEquipment: Integer; // @addr 0x006E0658 @note "Skips inventory index 0."
    function TrainSkill(Skill: TPilotSkill): Boolean; // @addr 0x006F02C0
    procedure GainExperience(Amount: Integer; SourceKind: TExperienceSource); // @addr 0x006EFFFC @note "experience_unscaled bypasses diminishing returns."
    procedure DepositCarriedNodes; // @addr 0x006F01E0 @note "Deposits every carried stack and awards experience."



  end;

var
  SimulationContext: ShortInt = 0; // @addr $80FB70  Suppresses duplicate Pirate Clan abduction effects during turn simulation.
  DamageScriptActionTypes: array[TWeaponDamageClass] of TScriptEventKind = (event_take_energy_damage, event_take_splinter_damage, event_take_missile_damage); // @addr $80FB74 Energy, splinter and missile hit callbacks.
  TradeGoodsSold: TGoods = nil; // @addr $80FB78 Reused script-event payload for the goods leaving the ship.
  TradeGoodsCostBasis: TGoods = nil; // @addr $80FB7C Reused payload for the purchased portion of the sale.
  DominatorShipSmallSizes: array[TDominatorSeries, TDominatorKind] of Integer = ((127, 110, 70, 60, 45, 40, 130, 40), (127, 110, 70, 60, 45, 40, 130, 40), (127, 110, 70, 60, 45, 40, 130, 40)); // @addr $80FB80
  DominatorShipLargeSizes: array[TDominatorSeries, TDominatorKind] of Integer = ((127, 127, 100, 90, 65, 60, 160, 60), (127, 127, 100, 90, 65, 60, 160, 60), (127, 127, 100, 90, 65, 60, 160, 60)); // @addr $80FBE0
  RangerSmallSizes: array[TOwnerId] of Integer = (50, 50, 50, 50, 50, 50, 50, 50); // @addr $80FC40
  RangerLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 80, 80, 80, 80, 80); // @addr $80FC60
  TransportSmallSizes: array[hull_transport..hull_diplomat, TOwnerId] of Integer = ((50, 50, 50, 50, 50, 50, 50, 50), (50, 50, 50, 50, 50, 50, 50, 50), (50, 50, 50, 50, 50, 50, 50, 50)); // @addr $80FC80
  TransportLargeSizes: array[hull_transport..hull_diplomat, TOwnerId] of Integer = ((90, 90, 90, 90, 90, 90, 90, 90), (90, 90, 90, 90, 90, 90, 90, 90), (90, 90, 90, 90, 90, 90, 90, 90)); // @addr $80FCE0
  PirateSmallSizes: array[TOwnerId] of Integer = (45, 45, 45, 55, 45, 45, 45, 45); // @addr $80FD40
  PirateLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 90, 80, 80, 80, 80); // @addr $80FD60
  PirateClanSmallSizes: array[TOwnerId] of Integer = (45, 45, 45, 55, 45, 45, 45, 45); // @addr $80FD80
  PirateClanLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 90, 80, 80, 80, 80); // @addr $80FDA0
  WarriorSmallSizes: array[TOwnerId] of Integer = (45, 45, 45, 55, 45, 45, 45, 45); // @addr $80FDC0
  WarriorLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 80, 80, 80, 80, 80); // @addr $80FDE0
  BigWarriorSmallSizes: array[TOwnerId] of Integer = (80, 80, 80, 80, 80, 80, 80, 80); // @addr $80FE00
  BigWarriorLargeSizes: array[TOwnerId] of Integer = (130, 130, 130, 130, 130, 130, 130, 130); // @addr $80FE20
  TranclucatorSmallSize: Integer = 40; // @addr $80FE40
  TranclucatorLargeSize: Integer = 50; // @addr $80FE44
  SpecialHullSmallSize: Integer = 50; // @addr $80FE48

var
  SpecialHullLargeSize: Integer = 80; // @addr $80FE4C
  StationSize: Integer = 128; // @addr $80FE50
  DefaultShipSmallSize: Integer = 50; // @addr $80FE54
  DefaultShipLargeSize: Integer = 80; // @addr $80FE58
  SkillBonusEvaluationWeights: array[bonus_accuracy..bonus_leadership] of Integer = (100, 100, 80, 80, 60, 60); // @addr $80FE5C bonus_accuracy..bonus_leadership.
  SlotBonusEvaluationWeights: array[bonus_radar_slots..bonus_afterburner_slots] of Integer = (100, 100, 200, 100, 200, 75, 10, 30); // @addr $80FE74 bonus_radar_slots..bonus_afterburner_slots.

function CreateShipByType(ShipType: TShipType): TShip; // @addr 0x006D643C @note "Allocates an unregistered instance; caller must initialize or deserialize it."

function CompareShipGroupsStrength(Ships, Opponents: TList): Single; // @addr 0x006D638C @note "Lists contain TShip. Sum of pairwise ChanceToWin divided by Opponents.Count squared; requires nonempty Opponents when Ships is nonempty."
function CalculateFuelCost(Amount: Integer; OwnerId: TOwnerId): Single; // @addr 0x006D6C74 @note "Owner six skips racial scaling. Uses active galaxy turn and difficulty."
function CalculateRoundedFuelCost(Amount: Integer; OwnerId: TOwnerId): Integer; // @addr 0x006D6D18

var
  KlingCheapDropValueFactors: array[TDominatorKind] of Double = (0.1, 0.85, 0.9, 1, 1.2, 1.5, 0.7, 4); // @addr $80FE94 Indexed by KlingType.
  KlingValuableDropValueFactors: array[TDominatorKind] of Double = (0.1, 0.8, 0.9, 1, 2, 4, 0.7, 8); // @addr $80FED4 Indexed by KlingType.

const
  DominatorProgramDropCostFactors: array[TDominatorKind] of Double = (0.2, 1.6, 1.8, 2.0, 4.0, 8.0, 1.4, 16.0); // @addr $80FF14 TDominatorKind order.

implementation

uses fShip2, aGalaxyEvent, fEquipmentShop, fGoodsShop2, ThreadCalc, EC_Mem, aEFilmEnd, SE_Weapon, fScore, SE_Ruins, Achievements, SE_GAIEffect, Dialogs, SE_Ship2, EC_Str, GR_Main, Globals, GlobalsV, Math, SysUtils, aConst, aKling, aMissile, aNormalShip, aPirate, aPlayer, aRanger, aRuins, aScript, aTranclucator, aTransport, aWarrior;

{ @routine $6C27E4 TShip_Create }
constructor TShip.Create;
var
  I: Integer;
  Kind: TItemType;
  Skill: TPilotSkill;
  Series: TDominatorSeries;
begin
  inherited Create;
  PortraitFaceId := -1;
  Money := 0;
  EncodedMoney := Money xor $A4A576AD;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextShipId;
    Inc(Galaxy.NextShipId);
    Seed := NextRandomIntRange(100000, MaxInt, Galaxy.RandomState);
    CreationTurn := Galaxy.CurrentTurn;
  end;
  if Integer(Seed) < 0 then RaiseWideMessage('TShip.Create; - FRnd<0');
  RandomState := Seed;
  for Kind := item_food to item_narcotics do
  begin
    CargoGoods[Ord(Kind)].Count := 0;
    CargoGoods[Ord(Kind)].TotalCost := 0;
  end;
  // The contiguous Hull..DefGenerator fields are indexed by native item type.
  for Kind := Low(EquipmentCache.Slots) to High(EquipmentCache.Slots) do
    EquipmentCache.Slots[Kind] := nil;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do BaseSkills[Skill] := 0;
  MovementPath := TSPath.Create;
  OrderNone(False);
  Inventory := TObjectList.Create;
  Artefacts := TObjectList.Create;
  GuaranteedDeathDropItems := TObjectList.Create;
  StatBonuses := nil;
  CombatStatusEffects := nil;
  MovementTurnRate := 1.2;
  EnemyShip := nil;
  TruceShip := nil;
  PartnerShip := nil;
  PlanetQueue := nil;
  RangerRelations := TList.Create;
  AwardIds := nil;
  NodeReserve := 0;
  TotalExperience := 0;
  FreeExperience := 0;
  DaysSincePlayerSeen := 100;
  LastProcessedTurn := -1;
  LiberationGroup := nil;
  LiberationGroupRouteIndex := 0;
  for I := disease_blindness to stimulant_absolute_status do
  begin
    CaptainHealth[I].Progress := 0;
    CaptainHealth[I].AppliedTurn := 0;
    CaptainHealth[I].ExpireTurn := 0;
    CaptainHealth[I].ApplicationCount := 0;
  end;
  for I := Low(RadiationHealth) to High(RadiationHealth) do
  begin
    RadiationHealth[I].Progress := 0;
    RadiationHealth[I].AppliedTurn := 0;
    RadiationHealth[I].ExpireTurn := 0;
    RadiationHealth[I].ApplicationCount := 0;
  end;
  TechKnowledge := 0;
  CustomShipInfos := TList.Create;
  ChameleonActive := False;
  for Series := Low(TDominatorSeries) to High(TDominatorSeries) do
  begin
    ChameleonDetected[Series] := False;
    ChameleonCharges[Series] := 0;
  end;
  ChameleonDisplayCount := 0;
  AwardVisibleCount := 0;
  PlayerExtortionPactActive := False;
  PlayerScratchHitsReceived := 0;
  InterceptorPassesRemaining := 0;
  InterceptorSourceShip := nil;
  InterceptorGraphic := nil;
  AbductedByPirateClan := False;
  Graphic := nil;
  EquipmentPriceSensitivity := 1.0;
end;
{ @end $6C27E4 }

{ @routine $6C2B18 TShip_Destroy }
destructor TShip.Destroy;
var
  I, J, PartnerIndex: Integer;
  Star: TStar;
  Ship: TShip;
  Binding: TScriptShip;
  Missile: TMissile;
  Storage: PStorageEntry;
  SavedAbsoluteOrder: Byte;
begin
  if PendingPlayerFollowTarget = Self then PendingPlayerFollowTarget := nil;
  if (TerronShip = Self) and not DestroyQueued then Galaxy.TerronLandingLockTurn := 0;
  if ScriptShip <> nil then
  begin
    Binding := ScriptShip as TScriptShip;
    Binding.Script.UnbindShip(Self);
  end;
  if LiberationGroup <> nil then LeaveLiberationGroup;
  if (GetPlayer <> nil) and (GetPlayer.StorageEntries <> nil) and (TypeId <> ship_tranclucator) then
    for I := GetPlayer.StorageEntries.Count - 1 downto 0 do
    begin
      Storage := GetPlayer.StorageEntries[I];
      if Storage.LocationOwner = Self then
      begin
        Storage.LocationOwner := nil;
        if Storage.Item <> nil then Storage.Item.Free;
        Storage.Item := nil;
        GetPlayer.StorageEntries.Delete(I);
        Dispose(Storage);
      end;
    end;
  ClearPlanetQueue;
  I := -1;
  if WingmenPendingLeadershipPenalty <> nil then I := WingmenPendingLeadershipPenalty.IndexOf(Self);
  if I >= 0 then WingmenPendingLeadershipPenalty.Delete(I);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.EnemyShip = Self then Ship.EnemyShip := nil;
      if Ship.TruceShip = Self then Ship.TruceShip := nil;
      if Ship.PartnerShip = Self then Ship.PartnerShip := nil;
      if Ship.DockedTo = Self then Ship.DockedTo := nil;
      if Ship.OrderTarget = Self then
      begin
        SavedAbsoluteOrder := Ship.AbsoluteScriptOrder;
        Ship.AbsoluteScriptOrder := 0;
        Ship.OrderNone(False);
        Ship.AbsoluteScriptOrder := SavedAbsoluteOrder;
        if Star.RecordingTurnFilm and (Ship.FilmObject <> nil) then
        begin
          Ship.FilmAlpha := 255;
          Ship.FilmAlphaStep := 0;
        end;
      end;
      if Ship.GetHull.InterceptorTarget = Self then Ship.GetHull.InterceptorTarget := nil;
      if Ship.InterceptorSourceShip = Self then Ship.InterceptorSourceShip := nil;
      if (Ship is TTranclucator) and ((Ship as TTranclucator).OwnerShip = Self) then
      begin
        (Ship as TTranclucator).OwnerShip := nil;
        (Ship as TTranclucator).FollowOwner := False;
      end;
      if (Ship is TPlayer) and ((Ship as TPlayer).PiratePartners <> nil) then
      begin
        PartnerIndex := (Ship as TPlayer).PiratePartners.IndexOf(Self);
        if PartnerIndex >= 0 then (Ship as TPlayer).PiratePartners.Delete(PartnerIndex);
      end;
    end;
    for J := 0 to Star.Missiles.Count - 1 do
    begin
      Missile := Star.Missiles[J];
      Missile.ClearReferencesTo(Self);
    end;
  end;
  ClearPickupTargets;
  ClearRecentlyDroppedItems;
  if CurrentStar <> nil then
  begin
    I := CurrentStar.Ships.IndexOf(Self);
    if I >= 0 then CurrentStar.Ships.Delete(I);
  end;
  I := Galaxy.ShipsInTransit.IndexOf(Self);
  if I >= 0 then Galaxy.ShipsInTransit.Delete(I);
  if Graphic <> nil then ReleaseSpaceObject(Graphic);
  if InterceptorGraphic <> nil then ReleaseSpaceObject(InterceptorGraphic);
  Inventory.Free;
  Artefacts.Free;
  GuaranteedDeathDropItems.Free;
  if StatBonuses <> nil then
  begin
    for I := StatBonuses.Count - 1 downto 0 do Dispose(Pointer(StatBonuses[I]));
    StatBonuses.Free;
    StatBonuses := nil;
  end;
  if CombatStatusEffects <> nil then
  begin
    for I := CombatStatusEffects.Count - 1 downto 0 do Dispose(Pointer(CombatStatusEffects[I]));
    CombatStatusEffects.Free;
    CombatStatusEffects := nil;
  end;
  if CustomShipInfos <> nil then
  begin
    // Native releases raw records here without finalizing their string fields.
    for I := 0 to CustomShipInfos.Count - 1 do Dispose(Pointer(CustomShipInfos[I]));
    CustomShipInfos.Free;
    CustomShipInfos := nil;
  end;
  MovementPath.Free;
  if GetPlayer = Self then SetPlayer(nil, Galaxy);
  if BlazerShip = Self then BlazerShip := nil;
  if KellerShip = Self then KellerShip := nil;
  if TerronShip = Self then TerronShip := nil;
  RangerRelations.Free;
  if AwardIds <> nil then AwardIds.Free;
  Id := 0;
  inherited Destroy;
end;
{ @end $6C2B18 }

{ @routine $6C30AC TShip_SaveToBuffer }
procedure TShip.SaveToBuffer(Buffer: TBufEC);
var
  Good: Byte;
  Item: TItem;
  I, Count: Integer;
  Award: Byte;
  Skill: TPilotSkill;
  Series: TDominatorSeries;
  Reserved: array[0..3] of Byte; // Native unreferenced slot before managed cleanup temporaries.
  SourceId: Cardinal;
  Info: PCustomShipInfo;
begin
  Buffer.AddDWord(Id);
  Buffer.AddWideStringZ(Name);
  Buffer.AddWideStringZ(TypeNameOverrideKey);
  Buffer.AddAnsiChar(AnsiChar(TypeId));
  Buffer.AddAnsiChar(AnsiChar(OwnerId));
  Buffer.AddSingle(Position.X);
  Buffer.AddSingle(Position.Y);
  if TransitOriginStar = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(TransitOriginStar.Id);
  if CurrentPlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(CurrentPlanet.Id);
  if DockedTo = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(DockedTo.Id);
  if HomePlanet = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(HomePlanet.Id);
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    Buffer.AddDWord(CargoGoods[Good].Count);
    Buffer.AddDWord(CargoGoods[Good].TotalCost);
    Buffer.AddDWord(CargoGoods[Good].PurchasedCount);
    Buffer.AddDWord(CargoGoods[Good].PurchasedTotalCost);
  end;
  Buffer.AddDWord(Money);
  Buffer.AddDWord(Seed);
  Buffer.AddDWord(RandomState);
  Buffer.AddDWord(CreationTurn);
  Buffer.AddIntegerValue(PortraitFaceId);
  Buffer.AddAnsiChar(AnsiChar(PilotRace));
  Count := Inventory.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Item := Inventory[I];
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  Count := Artefacts.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Item := Artefacts[I];
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  Count := GuaranteedDeathDropItems.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Item := GuaranteedDeathDropItems[I];
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  if StatBonuses = nil then Buffer.AddWideChar(#0)
  else
  begin
    Count := StatBonuses.Count;
    Buffer.AddWideChar(WideChar(Count));
    for I := 0 to Count - 1 do
    begin
      Buffer.AddAnsiChar(AnsiChar(PShipStatBonusEntry(StatBonuses[I]).BonusKind));
      Buffer.AddIntegerValue(PShipStatBonusEntry(StatBonuses[I]).BonusValue);
    end;
  end;
  if CombatStatusEffects = nil then Buffer.AddWideChar(#0)
  else
  begin
    Count := CombatStatusEffects.Count;
    Buffer.AddWideChar(WideChar(Count));
    for I := 0 to Count - 1 do
    begin
      Buffer.AddAnsiChar(AnsiChar(PCombatStatusEffect(CombatStatusEffects[I]).EffectType));
      Buffer.AddSingle(PCombatStatusEffect(CombatStatusEffects[I]).Strength);
      SourceId := PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId;
      Buffer.AddDWord(SourceId);
    end;
  end;
  for I := CustomShipInfos.Count - 1 downto 0 do
  begin
    Info := CustomShipInfos[I];
    if Info.DeleteQueued then
    begin
      CustomShipInfos.Delete(I);
      Dispose(Info);
    end;
  end;
  Buffer.AddIntegerValue(CustomShipInfos.Count);
  for I := 0 to CustomShipInfos.Count - 1 do
  begin
    Info := CustomShipInfos[I];
    Buffer.AddWideStringZ(Info.TypeName);
    Buffer.AddWideStringZ(Info.Description);
    Buffer.AddIntegerValue(Info.Data[1]);
    Buffer.AddIntegerValue(Info.Data[2]);
    Buffer.AddIntegerValue(Info.Data[3]);
    Buffer.AddWideStringZ(Info.TextData1);
    Buffer.AddWideStringZ(Info.TextData2);
    Buffer.AddWideStringZ(Info.TextData3);
  end;
  if PickupTargets = nil then Buffer.AddWideChar(#0)
  else
  begin
    Count := PickupTargets.Count;
    Buffer.AddWideChar(WideChar(Count));
    for I := 0 to Count - 1 do
    begin
      Item := PickupTargets[I];
      Buffer.AddDWord(Item.Id);
    end;
  end;
  if RecentlyDroppedItemIds = nil then Buffer.AddWideChar(#0)
  else
  begin
    Count := RecentlyDroppedItemIds.Count;
    Buffer.AddWideChar(WideChar(Count));
    for I := 0 to Count - 1 do Buffer.AddDWord(Cardinal(RecentlyDroppedItemIds[I]));
  end;
  if EnemyShip = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(EnemyShip.Id);
  if TruceShip = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(TruceShip.Id);
  if PartnerShip = nil then Buffer.AddDWord(0)
  else
  begin
    Buffer.AddDWord(PartnerShip.Id);
    Buffer.AddDWord(Max(0, PartnershipDaysRemaining));
  end;
  Buffer.AddBoolean(AfterburnerActive);
  Buffer.AddSingle(MovementDirection);
  Buffer.AddAnsiChar(AnsiChar(Order));
  Buffer.AddDWord(OrderStateData);
  if Order = order_jump then Buffer.AddDWord((OrderTarget as TStar).Id)
  else if Order = order_black_hole then
  begin
    if OrderTarget <> nil then Buffer.AddDWord((OrderTarget as THole).Id)
    else
    begin
      Buffer.AddDWord(0);
      AppendDebugLogLine('Error [t_JumpHole]: Hole not found, id = ' + IntToStr(Id) + ', Name = ' + Name);
    end;
  end
  else if Order = order_teleport then Buffer.AddDWord((OrderTarget as TStar).Id)
  else if Order = order_land then
  begin
    if OrderTarget is TShip then Buffer.AddDWord((OrderTarget as TShip).Id or OrderTargetShipFlag)
    else Buffer.AddDWord((OrderTarget as TPlanet).Id);
  end
  else if Order = order_follow_ship then Buffer.AddDWord((OrderTarget as TShip).Id)
  else Buffer.AddDWord(0);
  Buffer.AddSingle(OrderDestination.X);
  Buffer.AddSingle(OrderDestination.Y);
  Buffer.AddBoolean(OrderAbsolute);
  Buffer.AddBoolean(AbductedByPirateClan);
  Buffer.AddIntegerValue(ConsecutiveDockedDays);
  Buffer.AddAnsiChar(AnsiChar(AbsoluteScriptOrder));
  Buffer.AddBoolean(GraphDominator);
  Buffer.AddWideStringZ(GraphName);
  Buffer.AddAnsiChar(AnsiChar(Graphic.GetAlpha));
  Buffer.AddBoolean(InHyperspace);
  Buffer.AddSingle(CollisionRadius);
  Count := RangerRelations.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do Buffer.AddAnsiChar(AnsiChar(RangerRelations[I]));
  if AwardIds = nil then Buffer.AddAnsiChar(#0)
  else
  begin
    Buffer.AddAnsiChar(AnsiChar(AwardIds.Count));
    for I := 0 to AwardIds.Count - 1 do
    begin
      Award := Byte(AwardIds[I]);
      Buffer.AddAnsiChar(AnsiChar(Award));
    end;
  end;
  Buffer.AddBoolean(DestroyQueued);
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do Buffer.AddAnsiChar(AnsiChar(BaseSkills[Skill]));
  Buffer.AddWideChar(WideChar(NodeReserve));
  Buffer.AddDWord(TotalExperience);
  Buffer.AddDWord(FreeExperience);
  Buffer.AddWideChar(WideChar(DaysSincePlayerSeen));
  Buffer.AddDWord(EncodedMoney);
  Buffer.AddWideChar(WideChar(LiberationGroupRouteIndex));
  for I := disease_blindness to stimulant_absolute_status do
  begin
    Buffer.AddSingle(CaptainHealth[I].Progress);
    Buffer.AddIntegerValue(CaptainHealth[I].AppliedTurn);
    Buffer.AddIntegerValue(CaptainHealth[I].ExpireTurn);
    Buffer.AddIntegerValue(CaptainHealth[I].ApplicationCount);
  end;
  Buffer.AddIntegerValue(LastProcessedTurn);
  Buffer.AddIntegerValue(UnknownF4);
  Buffer.AddBoolean(ChameleonActive);
  Buffer.AddAnsiChar(AnsiChar(ChameleonSeries));
  Buffer.AddAnsiChar(AnsiChar(ChameleonVisualType));
  Buffer.AddIntegerValue(ChameleonDisplayCount);
  for Series := Low(TDominatorSeries) to High(TDominatorSeries) do
  begin
    Buffer.AddBoolean(ChameleonDetected[Series]);
    Buffer.AddIntegerValue(ChameleonCharges[Series]);
  end;
  for I := Low(RadiationHealth) to High(RadiationHealth) do
  begin
    Buffer.AddSingle(RadiationHealth[I].Progress);
    Buffer.AddIntegerValue(RadiationHealth[I].AppliedTurn);
    Buffer.AddIntegerValue(RadiationHealth[I].ExpireTurn);
    Buffer.AddIntegerValue(RadiationHealth[I].ApplicationCount);
  end;
  Buffer.AddAnsiChar(AnsiChar(TechKnowledge));
  Buffer.AddIntegerValue(TradeLossBalance);
  Buffer.AddIntegerValue(TradeExperience);
  Buffer.AddIntegerValue(ContrabandProfit);
  Buffer.AddIntegerValue(AwardVisibleCount);
  Buffer.AddBoolean(NoDrop);
  Buffer.AddAnsiChar(AnsiChar(TargetingRestriction));
  Buffer.AddBoolean(NoTalk);
  Buffer.AddBoolean(NoScan);
  Buffer.AddBoolean(ScriptChameleon);
  Buffer.AddBoolean(PlayerExtortionPactActive);
  Buffer.AddWideChar(WideChar(PlayerScratchHitsReceived));
  Buffer.AddIntegerValue(InterceptorPassesRemaining);
  if InterceptorSourceShip <> nil then Buffer.AddDWord(InterceptorSourceShip.Id)
  else Buffer.AddDWord(0);
  if InterceptorPassesRemaining > 0 then Buffer.AddWideStringZ(InterceptorGraphic.GraphKey);
  Buffer.AddAnsiChar(AnsiChar(CurrentStanding));
  Buffer.AddIntegerValue(SmoothedSpeed);
  Buffer.AddIntegerValue(SmoothedEnemySpeed);
  Buffer.AddSingle(SmoothedEquipmentEffectiveness);
  Buffer.AddIntegerValue(SmoothedWealth);
  Buffer.AddSingle(SmoothedMoneyFraction);
  Buffer.AddSingle(SmoothedFreeCapacityFraction);
  Buffer.AddSingle(EquipmentPriceSensitivity);
end;
{ @end $6C30AC }

{ @routine $6C3C14 TShip_LoadFromBuffer }
procedure TShip.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  Good: Byte;
  Item: TItem;
  I, Count: Integer;
  Award: Byte;
  SavedPartner: TShip;
  Skill: TPilotSkill;
  Series: TDominatorSeries;
  Bonus: PShipStatBonusEntry;
  Effect: PCombatStatusEffect;
  Info: PCustomShipInfo;
  Block: TBlockParEC;
begin
  Id := Buffer.GetUInt32;
  if Id >= Galaxy.NextShipId then Galaxy.NextShipId := Id + 1;
  Name := Buffer.ReadWideString;
  if LoadedSaveVersion >= 97 then TypeNameOverrideKey := Buffer.ReadWideString
  else TypeNameOverrideKey := '';
  TypeId := TShipType(Buffer.GetByte);
  OwnerId := TOwnerId(Buffer.GetByte);
  Position.X := Buffer.GetSingle;
  Position.Y := Buffer.GetSingle;
  TransitOriginStar := TStar(Buffer.GetUInt32);
  CurrentPlanet := TPlanet(Buffer.GetUInt32);
  DockedTo := TShip(Buffer.GetUInt32);
  HomePlanet := TPlanet(Buffer.GetUInt32);
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    CargoGoods[Good].Count := Buffer.GetUInt32;
    CargoGoods[Good].TotalCost := Buffer.GetUInt32;
    CargoGoods[Good].PurchasedCount := Buffer.GetUInt32;
    CargoGoods[Good].PurchasedTotalCost := Buffer.GetUInt32;
  end;
  SetMoney(Buffer.GetUInt32);
  Seed := Buffer.GetUInt32;
  RandomState := Buffer.GetUInt32;
  if Integer(Seed) < 0 then ShowMessage('TShip.Create; - FRnd<0');
  CreationTurn := Buffer.GetUInt32;
  PortraitFaceId := Buffer.GetInt32;
  if LoadedSaveVersion >= 125 then PilotRace := TOwnerId(Buffer.GetByte)
  else if OwnerId = owner_pirate then PilotRace := TOwnerId(Buffer.GetByte)
  else if OwnerId in [owner_maloc..owner_gaal] then PilotRace := OwnerToRace(OwnerId)
  else PilotRace := owner_maloc;
  if LoadedSaveVersion < 102 then
  begin
    if TypeId = station_medical_base then
    begin
      OwnerId := owner_gaal;
      PilotRace := owner_gaal;
      if PortraitFaceId > 14 then PortraitFaceId := -1;
    end;
    if TypeId = station_business_center then
    begin
      OwnerId := owner_human;
      PilotRace := owner_human;
    end;
  end;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Item count in equipment > 10000');
  for I := 0 to Count - 1 do
  begin
    Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
    Inventory.Add(Item);
    Item.LoadFromBuffer(Buffer, Galaxy);
    if Item is THull then THull(Item).OwnerShip := Self;
  end;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Artefacts count > 10000');
  for I := 0 to Count - 1 do
  begin
    Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
    Artefacts.Add(Item);
    Item.LoadFromBuffer(Buffer, Galaxy);
  end;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
    GuaranteedDeathDropItems.Add(Item);
    Item.LoadFromBuffer(Buffer, Galaxy);
  end;
  if LoadedSaveVersion >= 68 then
  begin
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    if Count > 0 then
    begin
      StatBonuses := TList.Create;
      for I := 0 to Count - 1 do
      begin
        New(Bonus);
        Bonus.BonusKind := TEquipmentBonusKind(Buffer.GetByte);
        Bonus.BonusValue := Buffer.GetInt32;
        StatBonuses.Add(Bonus);
      end;
    end;
  end;
  if LoadedSaveVersion >= 77 then
  begin
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    if Count > 0 then
    begin
      CombatStatusEffects := TList.Create;
      for I := 0 to Count - 1 do
      begin
        New(Effect);
        Effect.EffectType := TCombatEffectKind(Buffer.GetByte);
        Effect.Strength := Buffer.GetSingle;
        Effect.SourceShipId := Buffer.GetUInt32;
        CombatStatusEffects.Add(Effect);
      end;
    end;
  end;
  if LoadedSaveVersion >= 104 then
  begin
    Count := Buffer.GetInt32;
    for I := 0 to Count - 1 do
    begin
      New(Info);
      Info.TypeName := Buffer.ReadWideString;
      Info.Description := Buffer.ReadWideString;
      Info.Data[1] := Buffer.GetInt32;
      Info.Data[2] := Buffer.GetInt32;
      Info.Data[3] := Buffer.GetInt32;
      Info.TextData1 := Buffer.ReadWideString;
      Info.TextData2 := Buffer.ReadWideString;
      Info.TextData3 := Buffer.ReadWideString;
      Info.ActionCode := nil;
      Info.ActionCodeInitialized := False;
      Info.DeleteQueued := False;
      Block := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').FindBlock(Info.TypeName);
      if Block = nil then begin
        AppendLogLineThreadSafe('Warning! Ship info ' + Info.TypeName + ' not found, deleting.');
        Dispose(Info);
        Continue;
      end;
      CustomShipInfos.Add(Info);
      Info.StatusEffect := Block.CountParams('StatusEffect') > 0;
    end;
  end;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
  if Count > 0 then
  begin
    if PickupTargets <> nil then PickupTargets.Free;
    PickupTargets := TList.Create;
    for I := 0 to Count - 1 do PickupTargets.Add(Pointer(Buffer.GetUInt32));
  end;
  if LoadedSaveVersion >= 81 then
  begin
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    if Count > 0 then
    begin
      if RecentlyDroppedItemIds <> nil then RecentlyDroppedItemIds.Free;
      RecentlyDroppedItemIds := TList.Create;
      for I := 0 to Count - 1 do RecentlyDroppedItemIds.Add(Pointer(Buffer.GetUInt32));
    end;
  end;
  EnemyShip := TShip(Buffer.GetUInt32);
  TruceShip := TShip(Buffer.GetUInt32);
  SavedPartner := TShip(Buffer.GetUInt32);
  PartnerShip := SavedPartner;
  if Cardinal(SavedPartner) > 0 then PartnershipDaysRemaining := Buffer.GetUInt32;
  AfterburnerActive := Buffer.GetBoolean;
  MovementDirection := Buffer.GetSingle;
  Order := TShipOrder(Buffer.GetByte);
  OrderStateData := Buffer.GetUInt32;
  OrderTarget := TObject(Buffer.GetUInt32);
  OrderDestination.X := Buffer.GetSingle;
  OrderDestination.Y := Buffer.GetSingle;
  OrderAbsolute := Buffer.GetBoolean;
  if LoadedSaveVersion >= 107 then AbductedByPirateClan := Buffer.GetBoolean;
  if LoadedSaveVersion >= 48 then ConsecutiveDockedDays := Buffer.GetInt32
  else ConsecutiveDockedDays := 0;
  AbsoluteScriptOrder := Buffer.GetByte;
  GraphDominator := Buffer.GetBoolean;
  GraphName := Buffer.ReadWideString;
  if GraphName[1] = 'R' then
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', GraphName, Classes.Point(0, 0)))
  else
  begin
    if LoadedSaveVersion <= 66 then
    begin
      GraphName := ReplaceAllWideString(GraphName, 'Adon', 'Akrin');
      GraphName := ReplaceAllWideString(GraphName, 'Custom.1', 'AkrinFemale.J');
    end;
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', GraphName, Classes.Point(0, 0)));
  end;
  Graphic.SetPosition(Position);
  Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
  Graphic.SetAlpha(Buffer.GetByte);
  InHyperspace := Buffer.GetBoolean;
  CollisionRadius := Buffer.GetSingle;
  // Native replaces the constructor-created list without freeing it here.
  RangerRelations := TList.Create;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Error FRelationToRangers not in 0..10000');
  for I := 0 to Count - 1 do RangerRelations.Add(Pointer(Buffer.GetByte));
  AwardIds := nil;
  Count := Buffer.GetByte;
  if (Count < 0) or (Count > 255) then raise EAbort.Create('Error FRewards not in 0..255');
  if Count > 0 then
  begin
    AwardIds := TList.Create;
    for I := 0 to Count - 1 do
    begin
      Award := Buffer.GetByte;
      AwardIds.Add(Pointer(Award));
    end;
    AwardVisibleCount := Count;
  end;
  DestroyQueued := Buffer.GetBoolean;
  for Skill := Low(TPilotSkill) to High(TPilotSkill) do BaseSkills[Skill] := Buffer.GetByte;
  NodeReserve := Buffer.GetWord;
  TotalExperience := Buffer.GetUInt32;
  FreeExperience := Buffer.GetUInt32;
  DaysSincePlayerSeen := Buffer.GetWord;
  EncodedMoney := Buffer.GetUInt32;
  LiberationGroupRouteIndex := Buffer.GetWord;
  for I := disease_blindness to stimulant_absolute_status do
  begin
    CaptainHealth[I].Progress := Buffer.GetSingle;
    CaptainHealth[I].AppliedTurn := Buffer.GetInt32;
    CaptainHealth[I].ExpireTurn := Buffer.GetInt32;
    if LoadedSaveVersion >= 54 then begin
      CaptainHealth[I].ApplicationCount := Buffer.GetInt32;
      Continue;
    end;
    CaptainHealth[I].ApplicationCount := 0
  end;
  LastProcessedTurn := Buffer.GetInt32;
  UnknownF4 := Buffer.GetInt32;
  ChameleonActive := Buffer.GetBoolean;
  ChameleonSeries := TDominatorSeries(Buffer.GetByte);
  ChameleonVisualType := TDominatorKind(Buffer.GetByte);
  ChameleonDisplayCount := Buffer.GetInt32;
  for Series := Low(TDominatorSeries) to High(TDominatorSeries) do
  begin
    ChameleonDetected[Series] := Buffer.GetBoolean;
    ChameleonCharges[Series] := Buffer.GetInt32;
  end;
  for I := Low(RadiationHealth) to High(RadiationHealth) do
  begin
    RadiationHealth[I].Progress := Buffer.GetSingle;
    RadiationHealth[I].AppliedTurn := Buffer.GetInt32;
    RadiationHealth[I].ExpireTurn := Buffer.GetInt32;
    if LoadedSaveVersion >= 54 then begin
      RadiationHealth[I].ApplicationCount := Buffer.GetInt32;
      Continue;
    end;
    RadiationHealth[I].ApplicationCount := 0
  end;
  if LoadedSaveVersion >= 146 then TechKnowledge := Buffer.GetByte
  else TechKnowledge := 3;
  TradeLossBalance := Buffer.GetInt32;
  TradeExperience := Buffer.GetInt32;
  if LoadedSaveVersion >= 58 then ContrabandProfit := Buffer.GetInt32
  else ContrabandProfit := 0;
  AwardVisibleCount := Buffer.GetInt32;
  NoDrop := Buffer.GetBoolean;
  TargetingRestriction := Buffer.GetByte;
  NoTalk := Buffer.GetBoolean;
  NoScan := Buffer.GetBoolean;
  ScriptChameleon := Buffer.GetBoolean;
  PlayerExtortionPactActive := Buffer.GetBoolean;
  if LoadedSaveVersion >= 99 then PlayerScratchHitsReceived := Buffer.GetWord
  else PlayerScratchHitsReceived := 0;
  if LoadedSaveVersion >= 51 then
  begin
    InterceptorPassesRemaining := Buffer.GetInt32;
    InterceptorSourceShip := TShip(Buffer.GetUInt32);
    if InterceptorPassesRemaining > 0 then
    begin
      if PWideChar(PAnsiChar(Buffer.Data) + Buffer.Position)^ = 'R' then
        RetainSpaceObject(InterceptorGraphic, CreateSpaceObjectByName('Ruins', Buffer.ReadWideString, Classes.Point(0, 0)))
      else RetainSpaceObject(InterceptorGraphic, CreateSpaceObjectByName('Ship2', Buffer.ReadWideString, Classes.Point(0, 0)));
      InterceptorGraphic.SetAlpha(255);
      InterceptorGraphic.SetPosition(Position);
      InterceptorGraphic.SetAngle(HeadingDegreesToByte(MovementDirection));
    end
    else InterceptorGraphic := nil;
  end
  else
  begin
    InterceptorPassesRemaining := 0;
    InterceptorSourceShip := nil;
    InterceptorGraphic := nil;
  end;
  if LoadedSaveVersion >= 85 then
  begin
    CurrentStanding := TShipStanding(Buffer.GetByte);
    SmoothedSpeed := Buffer.GetInt32;
    SmoothedEnemySpeed := Buffer.GetInt32;
  end
  else
  begin
    CurrentStanding := standing_unaligned;
    SmoothedSpeed := Speed;
    SmoothedEnemySpeed := Speed;
  end;
  if LoadedSaveVersion >= 90 then
  begin
    SmoothedEquipmentEffectiveness := Buffer.GetSingle;
    SmoothedWealth := Buffer.GetInt32;
    SmoothedMoneyFraction := Buffer.GetSingle;
    SmoothedFreeCapacityFraction := Buffer.GetSingle;
    if LoadedSaveVersion >= 138 then EquipmentPriceSensitivity := Buffer.GetSingle
    else EquipmentPriceSensitivity := 1.0;
  end
  else
  begin
    SmoothedEquipmentEffectiveness := 0;
    SmoothedWealth := 0;
    SmoothedMoneyFraction := 0;
    SmoothedFreeCapacityFraction := 0;
    EquipmentPriceSensitivity := 1.0;
  end;
end;
{ @end $6C3C14 }

{ @routine $6C4CC4 TShip_SaveToBlock }
procedure TShip.SaveToBlock(Block: TBlockParEC);
var
  I, RemainingTurns: Integer;
  Text: WideString;
  Item: TItem;
  HealthBlock: TBlockParEC;
begin
  Block.AddParam(DecodeTextW('ImFluelalaNrahmaet'), GetFullName(' ')); // 'IFullName'
  Block.AddParam(DecodeTextW('InToyAple'), ShipTypeNames[TypeId].Name); // 'IType'
  Block.AddParam(DecodeTextW('Noasmler'), Name); // 'Name'
  Block.AddParam(DecodeTextW('Fiascoee'), IntToStr(PortraitFaceId)); // 'Face'
  if ScriptShip <> nil then
    Block.AddParam(DecodeTextW('IsSacaraiOpit'), // 'IScript'
      TScriptShip(ScriptShip).Script.ScriptFileName + ',' + TScriptShip(ScriptShip).GetGroup.Name + ',' +
      TScriptShip(ScriptShip).State.Name + '(' + IntToStr(TScriptShip(ScriptShip).Script.States.IndexOf(TScriptShip(ScriptShip).State)) + ')');
  if CurrentPlanet <> nil then Block.AddParam(DecodeTextW('ImPolearnBelt'), CurrentPlanet.Name) // 'IPlanet'
  else Block.AddParam(DecodeTextW('ImPolearnBelt'), ''); // 'IPlanet'
  if DockedTo <> nil then Block.AddParam(DecodeTextW('ImRyuWirnas'), DockedTo.Name) // 'IRuins'
  else Block.AddParam(DecodeTextW('ImRyuWirnas'), ''); // 'IRuins'
  Text := IntToStr(CargoGoods[Ord(item_food)].Count);
  for I := 1 to 7 do Text := Text + ',' + IntToStr(CargoGoods[Byte(I)].Count);
  Block.AddParam(DecodeTextW('Gronordos'), Text); // 'Goods'
  Text := IntToStr(BaseSkills[skill_accuracy]);
  for I := 1 to 5 do Text := Text + ',' + IntToStr(BaseSkills[TPilotSkill(I)]);
  Block.AddParam(DecodeTextW('SekaiAlalas'), Text); // 'Skills'
  Block.AddParam(DecodeTextW('Mnognoenyj'), IntToStr(Money)); // 'Money'
  Block.AddParam(DecodeTextW('Eoxepl'), IntToStr(TotalExperience)); // 'Exp'
  Block.AddParam(DecodeTextW('FarweyeAETxopa'), IntToStr(FreeExperience)); // 'FreeExp'
  HealthBlock := Block.AddBlockByPath(DecodeTextW('Hrenasletaha')); // 'Health'
  for I := disease_blindness to stimulant_absolute_status do
  begin
    if IsHealthEffectActive(I) then RemainingTurns := CaptainHealth[I].ExpireTurn - Galaxy.CurrentTurn
    else RemainingTurns := 0;
    Text := CaptainHealthDefinitions[I].Name + ',' + IntToStr(RemainingTurns);
    HealthBlock.AddParam(DecodeTextW('FralcatMoar') + IntToStr(I), Text); // 'Factor'
  end;
  if HasRadiationSickness then RemainingTurns := RadiationHealth[1].ExpireTurn - Galaxy.CurrentTurn
  else RemainingTurns := 0;
  Text := RadiationHealthDefinitions[1].Name + ',' + IntToStr(RemainingTurns);
  HealthBlock.AddParam(DecodeTextW('FralcatMoar') + IntToStr(25), Text); // 'Factor'
  with Block.AddBlockByPath(DecodeTextW('ElqiLoinsato')) do // 'EqList'
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.SaveToBlock(AddBlockByPath(Text));
    end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
  with Block.AddBlockByPath(DecodeTextW('AsrotyseLeidsot')) do // 'ArtsList'
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.SaveToBlock(AddBlockByPath(Text));
    end;
    AddParam(DecodeTextW('AsdediAmrot'), ''); // 'AddArt'
  end;
  with Block.AddBlockByPath(DecodeTextW('DarlokpuLainsata')) do // 'DropList'
  begin
    for I := 0 to GuaranteedDeathDropItems.Count - 1 do
    begin
      Item := GuaranteedDeathDropItems[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.SaveToBlock(AddBlockByPath(Text));
    end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
  if RangerRelations.Count > 0 then
    Block.AddParam(DecodeTextW('Rpe7lyamtgi4oendThokP4lWasyfeKry'), IntToStr(Byte(RangerRelations[0]))); // 'RelationToPlayer'
  Text := DecodeTextW('CrolnatariaOcitaeAddTrogSaheiOppIld'); // 'ContractedToShipId'
  if PartnerShip <> nil then Block.AddParam(Text, IntToStr(PartnerShip.Id))
  else Block.AddParam(Text, '0');
  Block.AddParam(DecodeTextW('CrolnatariaOcitaDiaOyeseLaeAfoto'), IntToStr(PartnershipDaysRemaining)); // 'ContractDaysLeft'
  Text := '';
  if AwardIds <> nil then
    if AwardIds.Count > 0 then
    begin
      Text := IntToStr(Integer(AwardIds[0]));
      for I := 1 to AwardIds.Count - 1 do Text := Text + ',' + IntToStr(Integer(AwardIds[I]));
    end;
  Block.AddParam(DecodeTextW('Mreodlaslis'), Text); // 'Medals'
  Block.AddParam(DecodeTextW('Dreisatarlony'), BoolToWideString(DestroyQueued)); // 'Destroy'
  Block.AddParam(DecodeTextW('GhilvienOrradlehr'), ''); // 'GiveOrder'
  Block.AddParam(DecodeTextW('NaosDireosp'), BoolToWideString(NoDrop)); // 'NoDrop'
  Block.AddParam(DecodeTextW('NoooTraslak'), BoolToWideString(NoTalk)); // 'NoTalk'
  Block.AddParam(DecodeTextW('NtorSickamn'), BoolToWideString(NoScan)); // 'NoScan'
  Block.AddParam(DecodeTextW('Sokoilna'), GraphName); // 'Skin'
end;
{ @end $6C4CC4 }

{ @routine $6C5D9C TShip_LoadFromBlock }
procedure TShip.LoadFromBlock(Block: TBlockParEC);
var
  I, OldTurns, NewTurns: Integer;
  Text, Part: WideString;
  Item: TItem;
  Hole: THole;
  ItemType: TItemType;
  Destination: TPointF;
begin
  Name := Block.GetParam(DecodeTextW('Noasmler')); // 'Name'
  PortraitFaceId := StrToInt(Block.GetParam(DecodeTextW('Fiascoee'))); // 'Face'
  Text := Block.GetParam(DecodeTextW('Gronordos')); // 'Goods'
  for I := 0 to 7 do CargoGoods[TGoodsIndex(I)].Count := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  Text := Block.GetParam(DecodeTextW('SekaiAlalas')); // 'Skills'
  for I := 0 to 5 do BaseSkills[TPilotSkill(I)] := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  SetMoney(StrToInt(Block.GetParam(DecodeTextW('Mnognoenyj')))); // 'Money'
  TotalExperience := StrToInt(Block.GetParam(DecodeTextW('Eoxepl'))); // 'Exp'
  FreeExperience := StrToInt(Block.GetParam(DecodeTextW('FarweyeAETxopa'))); // 'FreeExp'
  with Block.GetBlockByPath(DecodeTextW('Hrenasletaha')) do // 'Health'
  begin
    for I := disease_blindness to stimulant_absolute_status do
    begin
      if IsHealthEffectActive(I) then OldTurns := CaptainHealth[I].ExpireTurn - Galaxy.CurrentTurn
      else OldTurns := 0;
      Text := GetParam(DecodeTextW('FralcatMoar') + IntToStr(I)); // 'Factor'
      NewTurns := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
      if (OldTurns > 0) and (NewTurns = 0) then
      begin
        CaptainHealth[I].Progress := 0;
        CaptainHealth[I].ExpireTurn := 0;
      end;
      if (OldTurns = 0) and (NewTurns > 0) then
      begin
        CaptainHealth[I].Progress := 100;
        CaptainHealth[I].ExpireTurn := NewTurns + Galaxy.CurrentTurn;
      end;
      if (OldTurns > 0) and (NewTurns > 0) then CaptainHealth[I].ExpireTurn := NewTurns + Galaxy.CurrentTurn;
    end;
    if HasRadiationSickness then OldTurns := RadiationHealth[1].ExpireTurn - Galaxy.CurrentTurn
    else OldTurns := 0;
    Text := GetParam(DecodeTextW('FralcatMoar') + IntToStr(25)); // 'Factor'
    NewTurns := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    if (OldTurns > 0) and (NewTurns = 0) then
    begin
      RadiationHealth[1].Progress := 0;
      RadiationHealth[1].ExpireTurn := 0;
    end;
    if (OldTurns = 0) and (NewTurns > 0) then
    begin
      RadiationHealth[1].Progress := 0.5;
      RadiationHealth[1].ExpireTurn := NewTurns + Galaxy.CurrentTurn;
    end;
    if (OldTurns > 0) and (NewTurns > 0) then RadiationHealth[1].ExpireTurn := NewTurns + Galaxy.CurrentTurn;
  end;
  with Block.GetBlockByPath(DecodeTextW('ElqiLoinsato')) do // 'EqList'
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.LoadFromBlock(GetBlockByPath(Text));
    end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      for ItemType := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[ItemType] = Part then
        begin
          if (ItemType in [item_hull..item_satellite]) and (ItemType <> item_hull) then
          begin
            Item := CreateDefaultItemByType(ItemType);
            if Item <> nil then Inventory.Add(Item);
          end;
          Break;
        end;
    end;
  end;
  with Block.GetBlockByPath(DecodeTextW('AsrotyseLeidsot')) do // 'ArtsList'
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.LoadFromBlock(GetBlockByPath(Text));
    end;
    Text := GetParam(DecodeTextW('AsdediAmrot')); // 'AddArt'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      for ItemType := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[ItemType] = Part then
        begin
          if (ItemTypeNames[ItemType] = Part) and (ItemType in [artefact_hull..artefact_extra_missiles]) then
            Artefacts.Add(CreateConfiguredArtefactByItemType(ItemType, owner_uninhabited));
          Break;
        end;
    end;
  end;
  with Block.GetBlockByPath(DecodeTextW('DarlokpuLainsata')) do // 'DropList'
  begin
    for I := 0 to GuaranteedDeathDropItems.Count - 1 do
    begin
      Item := GuaranteedDeathDropItems[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.LoadFromBlock(GetBlockByPath(Text));
    end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      for ItemType := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[ItemType] = Part then
        begin
          if ((ItemType in [item_food..item_narcotics]) or (ItemType in [item_hull..item_custom_weapon]) or (ItemType in [artefact_hull..artefact_extra_missiles]) or (ItemType in [item_nodes..item_satellite])) and (ItemType <> item_hull) then
          begin
            Item := CreateDefaultItemByType(ItemType);
            if Item <> nil then GuaranteedDeathDropItems.Add(Item);
          end;
          Break;
        end;
    end;
  end;
  if RangerRelations.Count > 0 then
    RangerRelations[0] := Pointer(StrToInt(Block.GetParam(DecodeTextW('Rpe7lyamtgi4oendThokP4lWasyfeKry')))); // 'RelationToPlayer'
  Text := Block.GetParam(DecodeTextW('CrolnatariaOcitaeAddTrogSaheiOppIld')); // 'ContractedToShipId'
  if StrToInt(Text) = 0 then PartnerShip := nil
  else PartnerShip := TShip(Galaxy.IdToShip(StrToInt(Text), True));
  PartnershipDaysRemaining := StrToInt(Block.GetParam(DecodeTextW('CrolnatariaOcitaDiaOyeseLaeAfoto'))); // 'ContractDaysLeft'
  Text := Block.GetParam(DecodeTextW('Mreodlaslis')); // 'Medals'
  if AwardIds <> nil then AwardIds.Free;
  AwardVisibleCount := 0;
  AwardIds := nil;
  if Text <> '' then
  begin
    AwardIds := TList.Create;
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      AwardIds.Add(Pointer(StrToInt(Part)));
    end;
    AwardVisibleCount := CountDelimitedPartsW(Text, ',');
  end;
  DestroyQueued := LowerCase(AnsiString(Block.GetParam(DecodeTextW('Dreisatarlony')))) = 'true'; // 'Destroy'
  Text := Block.GetParam(DecodeTextW('GhilvienOrradlehr')); // 'GiveOrder'
  if CountDelimitedPartsW(Text, ',') > 1 then
  begin
    if ExtractDelimitedPartW(Text, 0, ',') = DecodeTextW('JiunmApeThorSitraer') then // 'JumpToStar'
    begin
      if (CurrentPlanet = nil) and (DockedTo = nil) then
      begin
        OrderJump(Galaxy.IdToStar(StrToInt(ExtractDelimitedPartW(Text, 1, ','))), True);
        if CountDelimitedPartsW(Text, ',') > 2 then OrderStateData := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
      end;
    end
    else if ExtractDelimitedPartW(Text, 0, ',') = DecodeTextW('JiunmApeIonsHroelMel') then // 'JumpInHole'
    begin
      Hole := Galaxy.IdToHole(StrToInt(ExtractDelimitedPartW(Text, 1, ',')));
      if (CurrentPlanet = nil) and (DockedTo = nil) and ((Hole.Star1 = CurrentStar) or (Hole.Star2 = CurrentStar)) then
      begin
        OrderJumpHole(Hole, True);
        if CountDelimitedPartsW(Text, ',') > 2 then OrderStateData := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
      end;
    end
    else if (ExtractDelimitedPartW(Text, 0, ',') = DecodeTextW('MiokvaenThor')) and InNormalSpace then // 'MoveTo'
    begin
      Destination.X := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 1, ','));
      Destination.Y := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, 2, ','));
      OrderMove(Destination, True);
    end;
  end;
  NoDrop := LowerCase(AnsiString(Block.GetParam(DecodeTextW('NaosDireosp')))) = 'true'; // 'NoDrop'
  NoTalk := LowerCase(AnsiString(Block.GetParam(DecodeTextW('NoooTraslak')))) = 'true'; // 'NoTalk'
  NoScan := LowerCase(AnsiString(Block.GetParam(DecodeTextW('NtorSickamn')))) = 'true'; // 'NoScan'
  ReleaseSpaceObject(Graphic);
  GraphName := Block.GetParam(DecodeTextW('Sokoilna')); // 'Skin'
  if GraphName[1] = 'R' then RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', GraphName, Classes.Point(0, 0)))
  else RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', GraphName, Classes.Point(0, 0)));
  RefreshDerivedStats(True);
  RefreshGraphicSize;
  DerivedStateCompatibilityHook;
end;
{ @end $6C5D9C }

{ @routine $6C73A4 TShip_ResolveLoadedReferences }
procedure TShip.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  I, Count: Integer;
  Item: TItem;
begin
  Galaxy.LoadedShips.Add(Self);
  TransitOriginStar := TObject(Galaxy.IdToStar(Cardinal(TransitOriginStar))) as TStar;
  CurrentPlanet := Galaxy.IdToPlanet(Cardinal(CurrentPlanet)) as TPlanet;
  if (Self is TPlayer) and ((Self as TPlayer).RuinsMode > 0) then
    DockedTo := (Self as TPlayer).RuinsProxy
  else DockedTo := Galaxy.IdToShip(Cardinal(DockedTo), True) as TShip;
  HomePlanet := Galaxy.IdToPlanet(Cardinal(HomePlanet)) as TPlanet;
  if (LoadedSaveVersion < 146) and (HomePlanet <> nil) then
    TechKnowledge := Max(TechKnowledge, HomePlanet.InventionLevels[research_main_technology]);
  if PickupTargets <> nil then
  begin
    Count := PickupTargets.Count;
    for I := 0 to Count - 1 do
      PickupTargets[I] := TObject(Galaxy.IdToItem(Cardinal(PickupTargets[I]), True)) as TItem;
  end;
  EnemyShip := Galaxy.IdToShip(Cardinal(EnemyShip), False) as TShip;
  TruceShip := Galaxy.IdToShip(Cardinal(TruceShip), False) as TShip;
  PartnerShip := Galaxy.IdToShip(Cardinal(PartnerShip), False) as TShip;
  InterceptorSourceShip := Galaxy.IdToShip(Cardinal(InterceptorSourceShip), False) as TShip;
  if Order = order_jump then OrderTarget := TObject(Galaxy.IdToStar(Cardinal(OrderTarget))) as TStar
  else if Order = order_black_hole then OrderTarget := TObject(Galaxy.IdToHole(Cardinal(OrderTarget))) as THole
  else if Order = order_teleport then OrderTarget := TObject(Galaxy.IdToStar(Cardinal(OrderTarget))) as TStar
  else if Order = order_land then
  begin
    if (Cardinal(OrderTarget) and OrderTargetShipFlag) = OrderTargetShipFlag then
      OrderTarget := Galaxy.IdToShip(Cardinal(OrderTarget) and TaggedObjectIdMask, True) as TShip
    else OrderTarget := Galaxy.IdToPlanet(Cardinal(OrderTarget)) as TPlanet;
  end
  else if Order = order_follow_ship then OrderTarget := Galaxy.IdToShip(Cardinal(OrderTarget), True) as TShip;
  Count := Inventory.Count;
  for I := 0 to Count - 1 do
  begin
    Item := Inventory[I];
    Item.ResolveLoadedReferences(Galaxy);
  end;
  Count := Artefacts.Count;
  for I := 0 to Count - 1 do
  begin
    Item := Artefacts[I];
    Item.ResolveLoadedReferences(Galaxy);
  end;
  Count := GuaranteedDeathDropItems.Count;
  for I := 0 to Count - 1 do
  begin
    Item := GuaranteedDeathDropItems[I];
    Item.ResolveLoadedReferences(Galaxy);
  end;
  if (LoadedSaveVersion < 85) and (TypeId <> ship_tranclucator) then RefreshCurrentStanding;
  if (LoadedSaveVersion in [92, 93]) and (Self is TNormalShip) and not (Self is TPlayer) then
  begin
    // Preserve the native legacy portrait exception, including its repeated type test.
    if (PilotRace = owner_human) and (PortraitFaceId in [25..32]) and (GetPlayer <> Self) and
       (GetPlayer <> nil) and (Self is TNormalShip) then Exit;
    if (Self is TPirate) and (OwnerId = owner_pirate) then GetHull.OwnerId := RaceToOwner(PilotRace)
    else GetHull.OwnerId := OwnerId;
    GetHull.HullType := ShipToHullType(Self);
    GetHull.SpecialModuleIndex := 0;
    if GetHull.HullSeries <> -1 then
      if not (GetHull.OwnerId in HullSeriesDefinitions[GetHull.HullSeries].AllowedOwners) or
         not (GetHull.HullType in HullSeriesDefinitions[GetHull.HullSeries].AllowedShipTypes) then
        GetHull.HullSeries := -1;
    ReleaseSpaceObject(Graphic);
    RefreshGraphic;
  end;
end;
{ @end $6C73A4 }

{ @routine $6C7860 TShip_ClearObjectReferences }
procedure TShip.ClearObjectReferences;
var
  I, Count: Integer;
  Item: TItem;
begin
  TransitOriginStar := nil;
  CurrentPlanet := nil;
  DockedTo := nil;
  HomePlanet := nil;
  if PickupTargets <> nil then PickupTargets.Clear;
  EnemyShip := nil;
  TruceShip := nil;
  PartnerShip := nil;
  InterceptorSourceShip := nil;
  AbsoluteScriptOrder := 0;
  OrderNone(False);
  Count := Inventory.Count;
  for I := 0 to Count - 1 do
  begin
    Item := Inventory[I];
    Item.ClearReferences;
  end;
  Count := Artefacts.Count;
  for I := 0 to Count - 1 do
  begin
    Item := Artefacts[I];
    Item.ClearReferences;
  end;
  Count := GuaranteedDeathDropItems.Count;
  for I := 0 to Count - 1 do
  begin
    Item := GuaranteedDeathDropItems[I];
    Item.ClearReferences;
  end;
end;
{ @end $6C7860 }

{ @routine $6C7938 TShip_SetMoney }
procedure TShip.SetMoney(Value: Integer);
begin
  if Value > MaxMonetaryValue then Value := MaxMonetaryValue
  else if Value < 0 then Value := 0;
  if (Integer(EncodedMoney xor $A4A576AD) <> Money) and not GR_Main.CCInterface.GetTamperDetected then
    GR_Main.CCInterface.SetTamperDetected(True);
  Money := Value;
  if GetPlayer = Self then
  begin
    GetPlayer.AchievementStats.CheckMoneyAchievement;
    SysUtils.Sleep(1);
    if (Money <> Value) and not GR_Main.CCInterface.GetTamperDetected then
      GR_Main.CCInterface.SetTamperDetected(True);
  end;
  EncodedMoney := Value xor $A4A576AD;
end;
{ @end $6C7938 }

{ @routine $6C79E0 TShip_ProcessBrokenFuelTankLeak }
procedure TShip.ProcessBrokenFuelTankLeak;
var
  Lost: Integer;
  Roll: Double;
begin
  if (GetFuelTanks = nil) or (GetFuelTanks.BrokenFlag = 0) or (CountActiveArtefacts(artefact_fuel) > 0) then Exit;
  Roll := NextRandomUnitFloat(RandomState);
  if Roll < 0.1 then Lost := 1
  else if Roll < 0.3 then Lost := 2
  else if Roll < 0.7 then Lost := 3
  else if Roll < 0.9 then Lost := 4
  else Lost := 5;
  if GetFuelTanks.Fuel < Lost then Lost := GetFuelTanks.Fuel;
  Dec(GetFuelTanks.Fuel, Lost);
  if GetPlayer = Self then
  begin
    AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn, LocalizedText('Items.FuelTanks.LostFuel'), '').Targets[0].ShipId := Id;
  end;
  if (GetPlayer = Self) and InNormalSpace and (Order = order_jump) then
    if GetFuelTanks.Fuel < Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
    begin
      AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn,
        FormatText1(LocalizedText('Items.FuelTanks.NoFuelJump'),
          TextHighlightColorTag, '<Star>', (OrderTarget as TStar).Name), '').Targets[0].ShipId := Id;
      OrderMove(OrderDestination, False);
    end;
end;
{ @end $6C79E0 }

{ @routine $6C7CC8 TShip_RefreshTechKnowledgeAtLocation }
procedure TShip.RefreshTechKnowledgeAtLocation;
var
  UseList, RepairList: TList;
  I: Integer;
  Item: TEquipment;
  Text: WideString;
begin
  if ((DockedTo = nil) or not (DockedTo is TRuins)) and
    ((CurrentPlanet = nil) or not (CurrentPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) or
      (CurrentPlanet.GetRelationLevelToShip(Self) = relation_level_hostile)) and not (Self is TRuins) then Exit;
  if GetPlayer <> Self then
  begin
    TechKnowledge := Max(TechKnowledge, Galaxy.TechLevel);
    Exit;
  end;
  UseList := TList.Create;
  RepairList := TList.Create;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if not CanUseEquipmentTech(Item) then UseList.Add(Item);
    if not CanRepairEquipmentTech(Item) then RepairList.Add(Item);
  end;
  TechKnowledge := Max(TechKnowledge, Galaxy.TechLevel);
  for I := UseList.Count - 1 downto 0 do
  begin
    Item := UseList[I];
    if not CanUseEquipmentTech(Item) then UseList.Delete(I);
  end;
  for I := RepairList.Count - 1 downto 0 do
  begin
    Item := RepairList[I];
    if not CanRepairEquipmentTech(Item) then RepairList.Delete(I);
  end;
  if UseList.Count > 0 then
  begin
    Text := LocalizedText('Items.Equpments.NowCanUse');
    for I := 0 to UseList.Count - 1 do
    begin
      Item := UseList[I];
      Text := Text + #13#10 + '- ' + Item.GetDisplayName;
    end;
    AddOrUpdatePlayerBubble(message_ship_positive, Galaxy.CurrentTurn, Text, '');
  end;
  if RepairList.Count > 0 then
  begin
    Text := LocalizedText('Items.Equpments.NowCanRepair');
    for I := 0 to RepairList.Count - 1 do
    begin
      Item := RepairList[I];
      Text := Text + #13#10 + '- ' + Item.GetDisplayName;
    end;
    AddOrUpdatePlayerBubble(message_ship_positive, Galaxy.CurrentTurn, Text, '');
  end;
  UseList.Free;
  RepairList.Free;
  GetPlayer.RefreshStorageBubbles;
end;
{ @end $6C7CC8 }

{ @routine $6C8034 TShip_NextDay }
procedure TShip.NextDay;
var
  I: Integer;
  WearFactor: Single;
  Stage: Integer; // Diagnostic checkpoint included in the exception message.
begin
  Stage := 0;
  try
    if EnemyShip = Self then EnemyShip := nil;
    if Order = order_follow_ship then
      if GetRelationLevelToShip(TShip(OrderTarget)) > relation_level_hostile then
        if PartnerShip <> OrderTarget then
          if not (Self is TTranclucator) or ((Self as TTranclucator).OwnerShip <> OrderTarget) then
            if (GetPlayer <> Self) and not HasScriptControl then OrderNone(False);
    Stage := 1;
    CancelInvalidTravelOrder;
    if InHyperspace or (CurrentPlanet <> nil) then TruceShip := nil;
    if not InNormalSpace then
    begin
      ClearCombatStatusEffects;
      ClearRecentlyDroppedItems;
    end;
    RefreshTechKnowledgeAtLocation;
    Stage := 2;
    if (aGalaxy.Galaxy.CurrentTurn > LastProcessedTurn) or
       ((aGalaxy.Galaxy.StasisModEnabled = 1) and (GetPlayer = Self)) then
    begin
      if ((CurrentPlanet <> nil) or (DockedTo <> nil)) and
         not ((GetPlayer = Self) and (GlobalsV.CurrentScreenId = screen_text_quest)) then
        Inc(ConsecutiveDockedDays)
      else
        ConsecutiveDockedDays := 0;
      Inc(DaysSincePlayerSeen);
      LastProcessedTurn := aGalaxy.Galaxy.CurrentTurn;
      SimulateNpcHealthEffects;
      Stage := 3;
      if (GetPlayer <> Self) and (TypeId <> ship_tranclucator) then
      begin
        AutoEquipInventory;
        AutoEquipArtefacts;
        if InNormalSpace then DropCargoUntilNotOverloaded;
        if not (Self is TRuins) and (DaysSincePlayerSeen > 100) and
           ((aGalaxy.Galaxy.CurrentTurn + Integer(Id)) mod 50 = 0) then ReloadWeaponAmmo;
      end;
      if (PartnerShip <> nil) and (PartnershipDaysRemaining > 0) then
        Dec(PartnershipDaysRemaining);
      Stage := 4;
      if GetHull.Weight > GetHull.HullPoints then ApplyRepairDroidHealing;
      if GetHull.EnergyMax > GetHull.Energy then
        GetHull.Energy := Min(GetHull.EnergyMax, GetHull.Energy + GetHullEnergyRegeneration);
      Stage := 5;
      if (GetEngine <> nil) and (GetEngine.OutputPercent < 100) then
      begin
        RefreshDerivedStats(True);
        if GetEngine.OutputPercent + 10 > 100 then GetEngine.OutputPercent := 100
        else Inc(GetEngine.OutputPercent, 10);
      end;
      Stage := 6;
      ProcessBrokenFuelTankLeak;
      Stage := 7;
      if Artefacts.Count > 0 then
      begin
        if GetFuelTanks <> nil then
          if GetFuelTanks.Fuel < GetFuelTanks.Capacity then
            Inc(GetFuelTanks.Fuel, Min(
              (aConst.FuelArtefactBase + aConst.FuelArtefactBoost * Ord(CanBoostArtefact(artefact_fuel, nil, False))) * CountActiveArtefacts(artefact_fuel),
              GetFuelTanks.Capacity - GetFuelTanks.Fuel));
        if (GetEngine <> nil) and (GetEngine.OutputPercent < 100) then
          Inc(GetEngine.OutputPercent, Min(
            (aConst.EngineArtefactBase + aConst.EngineArtefactBoost * Ord(CanBoostArtefact(artefact_power, GetEngine, False))) * CountActiveArtefacts(artefact_power),
            100 - GetEngine.OutputPercent));
        for I := 1 to CountActiveArtefacts(artefact_nano_repair) do ApplyNanoArtefactRepair;
        RefreshDerivedStats(True);
      end;
      Stage := 8;
      if GetPlayer = Self then
      begin
        if InNormalSpace then
        begin
          Stage := 9;
          if IsHealthEffectActive(disease_bitter_pelenosia) then WearFactor := 3 else WearFactor := 1;
          if Order in [order_move,order_land,order_jump,order_takeoff,order_follow_ship] then
          begin
            ApplyItemDegradation(GetEngine, wear_use,
              NextRandomUnitFloat(RandomState) * 0.5 *
              RemapClamped(CalculateMass, aConst.WearMassMin, aConst.WearMassMax, 1, 10) * WearFactor);
            ApplyItemDegradation(GetFuelTanks, wear_use, NextRandomUnitFloat(RandomState) * 0.5 * WearFactor);
            if GetEngine <> nil then
              if GetEngine.BrokenFlag <> 0 then
                if Order = order_jump then
                  if GetFuelLimitedJumpRange < System.Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
                  begin
                    AddOrUpdatePlayerBubble(message_ship_negative, aGalaxy.Galaxy.CurrentTurn, FormatText1(LocalizedText('Items.Engine.NoPowerJump'), TextHighlightColorTag, '<Star>', (OrderTarget as TStar).Name), '').Targets[0].ShipId := Id;
                    OrderMove(OrderDestination, False);
                  end;
          end;
          if GetRadar <> nil then
            ApplyItemDegradation(GetRadar, wear_use, NextRandomUnitFloat(RandomState) * 0.3 * WearFactor);
          if GetScanner <> nil then
            ApplyItemDegradation(GetScanner, wear_use, NextRandomUnitFloat(RandomState) * 0.3 * WearFactor);
          if GetDefGenerator <> nil then
            ApplyItemDegradation(GetDefGenerator, wear_use, NextRandomUnitFloat(RandomState) * 0.3 * WearFactor);
          ApplyArtefactUseDegradation(NextRandomFloatRange(0.1 * WearFactor, 0.3 * WearFactor, RandomState));
        end;
        if DockedTo <> nil then
        begin
          Stage := 10;
          SynchronizeDockedLocation;
        end;
      end
      else if InNormalSpace then
      begin
        Stage := 11;
        ApplyArtefactUseDegradation(NextRandomFloatRange(0.1, 0.3, RandomState));
        if (TypeId in [ship_ranger,ship_transport,ship_pirate]) and (CalculateMass > aConst.WearMassMin) and (Order <> order_none) then
          ApplyItemDegradation(GetEngine, wear_use,
            NextRandomUnitFloat(RandomState) * 0.5 *
            RemapClamped(CalculateMass, aConst.WearMassMin, aConst.WearMassMax, 0, 9) * 0.5);
        if AfterburnerActive then
        begin
          AfterburnerActive := False;
          if Self is TTranclucator then
            AfterburnerActive := (GetSlotCount(slot_afterburner) > 0) and (GetEngine <> nil) and
              (GetEngine.ConditionPercent > 10) and (EstimateOrderTravelTurns > 1);
        end;
        if Self is TKling then
          if (Self as TKling).ActiveProgramAppliedTurn > 0 then
          begin
            Stage := 12;
            with Self as TKling do
              case ActiveProgramId of
                program_shipwreck: ActiveProgramAppliedTurn := 0;
                program_weapon_blocking..program_shock:
                  if aGalaxy.Galaxy.CurrentTurn - aConst.ProgramDuration[ActiveProgramId] > ActiveProgramAppliedTurn then
                    ActiveProgramAppliedTurn := 0;
              end;
          end;
      end;
      Stage := 13;
      DecayCombatStatusEffects;
      UpdateSpeedTrackingMetrics;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TShip.NextDay ' + GetFullName(' ') + ' label = ' + SysUtils.IntToStr(Stage));
    end;
  end;
end;

procedure EndMarker;
begin end;
{ @end $6C8034 }

{ @routine $6C8C34 TShip_NextDayLogic }
procedure TShip.NextDayLogic;
begin

end;
{ @end $6C8C34 }

{ @routine $6C8C38 TShip_AssignWeaponTargetsInStar }
procedure TShip.AssignWeaponTargetsInStar;
var
  I: Integer;
begin
  for I := 1 to WeaponCount do Weapons[I].Target := nil;
end;
{ @end $6C8C38 }

{ @routine $6C8C60 TShip_DerivedStateCompatibilityHook }
procedure TShip.DerivedStateCompatibilityHook;
begin

end;
{ @end $6C8C60 }

{ @routine $6C8C64 TShip_GetTypeNameKey }
function TShip.GetTypeNameKey: WideString;
begin
  Result := ShipTypeNames[TypeId].Name;
end;
{ @end $6C8C64 }

{ @routine $6C8C84 TShip_GetLocalizedTypeName }
function TShip.GetLocalizedTypeName: WideString;
begin
  if TypeNameOverrideKey <> '' then
    Result := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey)
  else if (Self is TWarrior) and ((Self as TWarrior).WarriorType = warrior_flagship) then
    Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey + 'Big')
  else Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey);
end;
{ @end $6C8C84 }

{ @routine $6C8DA8 TShip_GetFactionNameKey }
function TShip.GetFactionNameKey: WideString;
begin
  if HasNamedScriptFaction then Result := TScriptShip(ScriptShip).StateText
  else if Self is TKling then Result := DominatorSeriesNames[(Self as TKling).DominatorSeries]
  else Result := OwnerInfo[OwnerId].InternalName;
end;
{ @end $6C8DA8 }

{ @routine $6C8E20 TShip_GetDefaultHullType }
function TShip.GetDefaultHullType: THullType;
var
  Kind: THullType;
begin
  case TypeId of
    ship_dominator: Kind := hull_dominator;
    ship_ranger: Kind := hull_ranger;
    ship_transport:
      case (Self as TTransport).TransportType of
        transport_standard: Kind := hull_transport;
        transport_liner: Kind := hull_liner;
        transport_diplomat: Kind := hull_diplomat;
      else Kind := hull_ranger;
      end;
    ship_pirate: Kind := hull_pirate;
    ship_warrior:
      case (Self as TWarrior).WarriorType of
        warrior_regular: Kind := hull_warrior;
        warrior_flagship: Kind := hull_flagship;
      else Kind := hull_warrior;
      end;
    ship_tranclucator: Kind := hull_tranclucator;
    station_ranger_center..station_custom: Kind := hull_station;
  else Kind := hull_ranger;
  end;
  Result := Kind;
end;
{ @end $6C8E20 }

{ @routine $6C8EE0 TShip_NextRandomInteger }
function TShip.NextRandomInteger(Minimum, Maximum: Integer): Integer;
begin
  Result := NextRandomIntRange(Minimum, Maximum, RandomState);
end;
{ @end $6C8EE0 }

{ @routine $6C8EF0 TShip_GetSpaceInfoText }
function TShip.GetSpaceInfoText: WideString;
begin
  Result := GetName;
  case Order of
    order_land:
      if OrderTarget is TPlanet then
        Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.LandingToPlanet'), '<Planet>', (OrderTarget as TPlanet).Name, TextHighlightColorTag)
      else if OrderTarget is TShip then
        Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.LandingToShip'), '<Ship>', (OrderTarget as TShip).Name, TextHighlightColorTag);
    order_jump:
      Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.GoToStar'), '<Star>', (OrderTarget as TStar).Name, TextHighlightColorTag);
    order_follow_ship:
      if (OrderTarget as TShip).CurrentPlanet = nil then
      begin
        if EnemyShip <> OrderTarget then
          Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.GoToShip'), '<Ship>', (OrderTarget as TShip).GetName, TextHighlightColorTag)
        else
          Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.GoToShipBad'), '<Ship>', (OrderTarget as TShip).GetName, TextHighlightColorTag);
      end
      else Result := Result + ' ' + LookupLocalizedTextByKey('ShipInfo.Order.None');
    order_move:
      Result := Result + ' ' + LookupLocalizedTextByKey('ShipInfo.Order.Move');
  end;
  Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceSize'), TextHighlightColorTag, '<Size>', IntToStr(GetHull.Weight));
  if GetHull.Weight > GetHull.HullPoints then
    Result := Result + ' ' + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceDamageProc'), TextHighlightColorTag, '<Proc>', IntToStr(Trunc(100 - GetHull.HullPoints / (GetHull.Weight * 0.01))));
  Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceSpeed'), TextHighlightColorTag, '<Speed>', IntToStr(CalculateSpeed));
  Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceDefField'), TextHighlightColorTag, '<Proc>', IntToStr(GetDefensePercent));
  if GetPlayer <> Self then
  begin
    Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceRelation'), TextHighlightColorTag, '<Type>', LowerCaseWideString(GetRelationLevelTextToShip(GetPlayer)));
    if GetPlayer.CountActiveArtefacts(artefact_analyzer) > 0 then
      Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('Artefacts.Analyzer.TextToRadar'), TextHighlightColorTag, '<ChanceToWin>', IntToStr(GetPlayer.GetWinChancePercent(Self)));
  end;
end;
{ @end $6C8EF0 }

{ @routine $6C9898 TShip_GetDesiredCargoFreeSpace }
function TShip.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $6C9898 }

{ @routine $6C989C TShip_IsHullDestroyed }
function TShip.IsHullDestroyed: Boolean;
begin
  Result := GetHull.HullPoints <= 0;
end;
{ @end $6C989C }

{ @routine $6C98B0 TShip_GetTurnSeedFraction }
function TShip.GetTurnSeedFraction(TurnOffset: Integer): Single;
begin
  Result := Frac(Integer(Seed) / (Galaxy.CurrentTurn + TurnOffset));
end;
{ @end $6C98B0 }

{ @routine $6C98EC TShip_GetEstimatedMemoryUsage }
function TShip.GetEstimatedMemoryUsage: Integer;
begin
  Result := InstanceSize;
  if Inventory <> nil then Result := Result + Inventory.InstanceSize + Inventory.Count * 4;
  if Artefacts <> nil then Result := Result + Artefacts.InstanceSize + Artefacts.Count * 4;
  if GuaranteedDeathDropItems <> nil then Result := Result + GuaranteedDeathDropItems.InstanceSize + GuaranteedDeathDropItems.Count * 4;
  if PickupTargets <> nil then Result := Result + PickupTargets.InstanceSize + PickupTargets.Count * 4;
  if RecentlyDroppedItemIds <> nil then Result := Result + RecentlyDroppedItemIds.InstanceSize + RecentlyDroppedItemIds.Count * 4;
  if PlanetQueue <> nil then Result := Result + PlanetQueue.InstanceSize + PlanetQueue.Count * 4;
end;
{ @end $6C98EC }

{ @routine $6C99CC TShip_HasCargoGoods }
function TShip.HasCargoGoods: Boolean;
var
  Good: Byte;
begin
  Result := False;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    if CargoGoods[Good].Count > 0 then
    begin
      Result := True;
      Break;
    end;
end;
{ @end $6C99CC }

{ @routine $6C99EC TShip_CountCargoGoodsTypes }
function TShip.CountCargoGoodsTypes: Byte;
var
  Good: Byte;
begin
  Result := 0;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do if CargoGoods[Good].Count > 0 then Inc(Result);
end;
{ @end $6C99EC }

{ @routine $6C9A08 TShip_GetCarriedNodeCount }
function TShip.GetCarriedNodeCount: Integer;
var
  I: Integer;
  Item: TItem;
begin
  Result := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if Item.ItemType = item_nodes then Inc(Result, Item.Weight);
  end;
end;
{ @end $6C9A08 }

{ @routine $6C9A44 TShip_HasLockedOrFollowOrder }
function TShip.HasLockedOrFollowOrder: Boolean;
begin
  if OrderAbsolute or (AbsoluteScriptOrder > 0) or (Order = order_follow_ship) then Result := True
  else Result := False;
end;
{ @end $6C9A44 }

{ @routine $6C9A68 TShip_HasHullDamageOrBrokenEquippedItems }
function TShip.HasHullDamageOrBrokenEquippedItems: Boolean;
var
  I: Integer;
  Item: TEquipment;
begin
  Result := GetHull.HullPoints < GetHull.Weight;
  if Result then Exit;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag <> 0) and (Item.BrokenFlag <> 0) then
    begin
      Result := True;
      Break;
    end;
  end;
end;
{ @end $6C9A68 }

{ @routine $6C9AC4 TShip_CanRefuel }
function TShip.CanRefuel: Boolean;
begin
  if GetFuelTanks <> nil then Result := GetFuelTanks.Fuel < GetFuelTanks.Capacity
  else Result := False;
end;
{ @end $6C9AC4 }

{ @routine $6C9AF8 TShip_LookupVisibleTalkText }
function TShip.LookupVisibleTalkText(const Path: WideString; OtherShip: TShip): WideString;
begin
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) then begin
    Result := LookupTalkText(Path);
    ReplaceTextToken(Result, '<TalkShip>', OtherShip.GetName, TextHighlightColorTag);
  end else Result := '';
end;
{ @end $6C9AF8 }

{ @routine $6C9BD8 TShip_UpdateBestRangerRelativeRatings }
procedure TShip.UpdateBestRangerRelativeRatings;
begin
  if Galaxy.MaxRangerWealth <> 0 then WealthInBestRanger := Wealth / Galaxy.MaxRangerWealth
  else WealthInBestRanger := 0;
  if Galaxy.BestRangerStrength <> 0 then StrengthInBestRanger := Strength / Galaxy.BestRangerStrength
  else StrengthInBestRanger := 0;
end;
{ @end $6C9BD8 }

{ @routine $6C9C4C TShip_UpdateAverageRangerRelativeStrength }
procedure TShip.UpdateAverageRangerRelativeStrength;
begin
  StrengthInAverageRanger := Strength / Galaxy.AverageRangerStrength;
end;
{ @end $6C9C4C }

{ @routine $6C9C68 TShip_CalculateWealth }
function TShip.CalculateWealth: Integer;
var
  I: Integer;
  Capital: Int64;
  Item: TItem;
  Good: Byte;
  Entry: PStorageEntry;
begin
  Capital := Money;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    Inc(Capital, Item.Cost);
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    Inc(Capital, Item.Cost);
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do Inc(Capital, CargoGoods[Good].TotalCost);
  if GetPlayer = Self then
  begin
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := PStorageEntry(GetPlayer.StorageEntries[I]);
      Inc(Capital, Entry.Item.Cost);
    end;
    Inc(Capital, GetPlayer.ComputeDepositAccruedValue);
  end;
  if Capital > MaxInt then Result := MaxInt else Result := Capital;
  Wealth := Result;
end;
{ @end $6C9C68 }

{ @routine $6C9D78 TShip_CalculateAttackStrength }
function TShip.CalculateAttackStrength: Double;
var
  I: Integer;
begin
  Result := 0.0000001;
  for I := 1 to WeaponCount do
    if IsEquipmentUsable(Weapons[I]) then
      Result := Result + RemapClamped(GetEffectiveSkillLevel(skill_accuracy), 0, 6,
        (GetWeaponMaxDamage(Weapons[I]) + GetWeaponMinDamage(Weapons[I])) div 2,
        GetWeaponMaxDamage(Weapons[I])) * Weapons[I].GetAttackCount;
  if Self is TKling then
    case (Self as TKling).KlingType of
      dominator_boss: Result := Result * 1.5;
      dominator_bertor: Result := Result + 400;
      dominator_klig: Result := Result * 0.33;
    end;
  Result := Max(0.0000001, Result * (UsableWeaponCount + 7) * GetAttackMultiplier);
end;
{ @end $6C9D78 }

{ @routine $6C9F68 TShip_CalculateDefenseStrength }
function TShip.CalculateDefenseStrength: Double;
begin
  Result := GetHull.HullPoints / Max(0.01, GetHull.GetFragilityFactor([])) * (GetArmor + 5) / DefenseDamageFactor;
  if (Self is TKling) and ((Self as TKling).KlingType = dominator_klig) then Result := Result * 3;
end;
{ @end $6C9F68 }

{ @routine $6CA054 TShip_GetRepairStrengthFactor }
function TShip.GetRepairStrengthFactor: Double;
begin
  if (GetHullIntegrityPercent > 50) and IsEquipmentUsable(GetRepairRobot) then
    Result := GetRepairRobot.TechLevel + 5
  else Result := 5;
end;
{ @end $6CA054 }

{ @routine $6CA0AC TShip_CalculateStrength }
function TShip.CalculateStrength: Double;
begin
  Result := CalculateAttackStrength * CalculateDefenseStrength * GetRepairStrengthFactor;
  Strength := Result;
  if (GetPlayer = Self) and (Galaxy <> nil) then Galaxy.RefreshRangerStrengthStats;
end;
{ @end $6CA0AC }

{ @routine $6CA110 TShip_GetFullHullRelativeStrengthPercent }
function TShip.GetFullHullRelativeStrengthPercent: Byte;
var
  HullPoints: Integer;
begin
  HullPoints := GetHull.HullPoints;
  GetHull.HullPoints := GetHull.Weight;
  Result := Round(CalculateStrength * 100 / Galaxy.AverageRangerStrength);
  GetHull.HullPoints := HullPoints;
end;
{ @end $6CA110 }

{ @routine $6CA168 TShip_GetWealthScaledAmount }
function TShip.GetWealthScaledAmount(ScaleIndex: Byte): Integer;
var Value: Single;
begin
  Value := Round(Wealth * WealthDemandScales[ScaleIndex]);
  if Value < 5000 then Result := Round(Value)
  else Result := Round((Value - 5000) * 0.3 + 5000);
end;
{ @end $6CA168 }

{ @routine $6CA1E4 TShip_HasScriptBindings }
function TShip.HasScriptBindings: Boolean;
begin
  if Self is TPlayer then Result := TPlayer(Self).ScriptShipBindings.Count > 0
  else Result := ScriptShip <> nil;
end;
{ @end $6CA1E4 }

{ @routine $6CA214 TShip_GetShipPortraitImagePath }
function TShip.GetShipPortraitImagePath: WideString;
begin
  if Graphic is TShip2SE then Result := GameDataConfig.GetParamByPathOrMarker('SE.' + Graphic.GraphKey + '.2ImageP')
  else if Graphic is TRuinsSE then Result := (Graphic as TRuinsSE).StaticImagePath;
end;
{ @end $6CA214 }

{ @routine $6CA2E4 TShip_GetCaptainPortraitResourceBase }
function TShip.GetCaptainPortraitResourceBase: WideString;
var
  PlanetIndex, FaceIndex, ShipIndex, I, Limit: Integer;
  Styles: TBlockParEC;
  Role: WideString;
  CandidateCount: Integer;
  Star: TStar;
  Ship: TShip;
  Planet: TPlanet;
  Owner: TOwnerId;
  Faces, Usage: array[0..100] of Integer;
begin
  if GetPlayer = Self then
  begin
    if (Galaxy <> nil) and (Galaxy.SpecialSimulationMode <> 0) then Result := 'Bm.Captain.2Tranclucator'
    else Result := 'Bm.Captain.2' + OwnerInfo[RaceToOwner(PilotRace)].InternalName + IntToStr(PortraitFaceId);
    Exit;
  end;
  if HasScriptStateText and
    CacheDataRoot.FileExistsByPath('Bm.Captain.2' + TScriptShip(ScriptShip).StateText + IntToStr(PortraitFaceId) + 'i') and
    CacheDataRoot.FileExistsByPath('Bm.Captain.2' + TScriptShip(ScriptShip).StateText + IntToStr(PortraitFaceId) + 'a') then
  begin
    Result := 'Bm.Captain.2' + TScriptShip(ScriptShip).StateText + IntToStr(PortraitFaceId);
    Exit;
  end;
  if Self is TTranclucator then
  begin
    if (PortraitFaceId >= 0) and
      CacheDataRoot.FileExistsByPath('Bm.Captain.2Tranclucator' + IntToStr(PortraitFaceId) + 'i') and
      CacheDataRoot.FileExistsByPath('Bm.Captain.2Tranclucator' + IntToStr(PortraitFaceId) + 'a') then
      Result := 'Bm.Captain.2Tranclucator' + IntToStr(PortraitFaceId)
    else Result := 'Bm.Captain.2Tranclucator';
    Exit;
  end;
  if Self is TKling then
  begin
    if (Self as TKling).KlingType = dominator_boss then
    begin
      if (Self as TKling).DominatorSeries = series_blazer then Result := 'Bm.Captain.2BlazerB'
      else if (Self as TKling).DominatorSeries = series_keller then Result := 'Bm.Captain.2KellerB'
      else if (Self as TKling).DominatorSeries = series_terron then Result := 'Bm.Captain.2TerronB';
    end
    else
    begin
      if (Self as TKling).DominatorSeries = series_blazer then Result := 'Bm.Captain.2BlazerN'
      else if (Self as TKling).DominatorSeries = series_keller then Result := 'Bm.Captain.2KellerN'
      else if (Self as TKling).DominatorSeries = series_terron then Result := 'Bm.Captain.2TerronN';
    end;
    Exit;
  end;
  Owner := RaceToOwner(PilotRace);
  if PortraitFaceId < 0 then
  begin
    if TypeId = ship_ranger then Role := 'R'
    else if TypeId = ship_warrior then Role := 'W'
    else if TypeId = ship_pirate then Role := 'P'
    else if TypeId = ship_transport then
    begin
      if (Self as TTransport).TransportType = transport_standard then Role := 'T'
      else if (Self as TTransport).TransportType = transport_liner then Role := 'L'
      else if (Self as TTransport).TransportType = transport_diplomat then Role := 'D'
      else Role := 'L';
    end
    else Role := 'L';
    CandidateCount := 0;
    Styles := GameDataConfig.GetBlockByPath('StyleFace' + OwnerInfo[Owner].InternalName);
    Limit := Min(100, Styles.GetParamCount);
    for I := 0 to Limit - 1 do
      if FindTextOffsetW(Styles.GetParamValue(I), Role) >= 0 then
      begin
        Faces[CandidateCount] := ExtractDigitsToIntW(Styles.GetParamName(I));
        Usage[CandidateCount] := 0;
        if (GetPlayer = nil) or (GetPlayer.PortraitFaceId <> Faces[CandidateCount]) or (GetPlayer.PilotRace <> PilotRace) then Inc(CandidateCount);
      end;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      for ShipIndex := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[ShipIndex];
        if (Ship.PilotRace <> Self.PilotRace) or (Ship.TypeId = ship_warrior) then Continue;
        for FaceIndex := 0 to CandidateCount - 1 do
            if Ship.PortraitFaceId = Faces[FaceIndex] then
            begin
              Inc(Usage[FaceIndex]);
              Break;
            end;
      end;
      for PlanetIndex := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[PlanetIndex];
        for ShipIndex := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[ShipIndex];
          if Ship.PilotRace <> Self.PilotRace then Continue;
          for FaceIndex := 0 to CandidateCount - 1 do
              if Ship.PortraitFaceId = Faces[FaceIndex] then
              begin
                Inc(Usage[FaceIndex]);
                Break;
              end;
        end;
      end;
    end;
    PortraitFaceId := Faces[0];
    ShipIndex := Usage[0];
    for I := 1 to CandidateCount - 1 do
      if Usage[I] < ShipIndex then
      begin
        PortraitFaceId := Faces[I];
        ShipIndex := Usage[I];
      end;
  end;
  Result := 'Bm.Captain.2' + OwnerInfo[Owner].InternalName + IntToStr(PortraitFaceId);
end;
{ @end $6CA2E4 }

{ @routine $6CADE8 TShip_HasPlayerChameleonCharges }
function TShip.HasPlayerChameleonCharges: Boolean;
var I: TDominatorSeries;
begin
  Result := False;
  for I := Low(TDominatorSeries) to High(TDominatorSeries) do
    if GetPlayer.ChameleonCharges[I] > 0 then begin Result := True; Exit; end;
end;
{ @end $6CADE8 }

{ @routine $6CAE18 TShip_SelectChameleonVisualType }
function TShip.SelectChameleonVisualType: TDominatorKind;
var HullSize, AverageSize: Integer; Distance, BestDistance: Double; Kind, BestKind: TDominatorKind;
begin
  HullSize := Round(GetHull.Weight / HullCapacityScale);
  BestDistance := -1;
  BestKind := dominator_klig;
  for Kind := Low(DominatorShipDefinitions) to High(DominatorShipDefinitions) do
    if Kind <> dominator_boss then
    begin
      AverageSize := (DominatorShipDefinitions[Kind].MinimumHullSize + DominatorShipDefinitions[Kind].MaximumHullSize) div 2;
      Distance := Abs(AverageSize - HullSize) / Min(1, AverageSize); // Native uses Min, including its possible zero divisor.
      if (Distance < BestDistance) or (BestDistance < 0) then
      begin
        BestDistance := Distance;
        BestKind := Kind;
      end;
    end;
  Result := BestKind;
end;
{ @end $6CAE18 }

{ @routine $6CAEE0 TShip_IsPlayerChameleonEffectiveAgainstSelf }
function TShip.IsPlayerChameleonEffectiveAgainstSelf: Boolean;
begin
  if not GetPlayer.ChameleonActive or (GetPlayer = Self) then begin Result := False; Exit; end;
  Result := (TypeId <> ship_pirate) and (GetPlayer <> PartnerShip) and
    not ((ScriptShip <> nil) and (TScriptShip(ScriptShip).Script.ScriptFileName = 'Script.PC_fem_rangers') and
      (TScriptShip(ScriptShip).GetGroup.Name = 'GroupFem'));
  Result := GetPlayer.ScriptItemsAct(event_chameleon_confusion, Self, nil, Ord(Result)) <> 0;
  Result := ScriptItemsAct(event_chameleon_confusion, nil, nil, Ord(Result)) <> 0;
end;
{ @end $6CAEE0 }

{ @routine $6CAFD0 TShip_RefreshGraphic }
procedure TShip.RefreshGraphic;
var
  Dominator: Boolean;
begin
  Dominator := ((not (Self is TPlayer)) and Galaxy.GraphDominatorSurfacesEnabled) or ChameleonActive;
  if ScriptChameleon then
  begin
    GraphDominator := Dominator;
    Exit;
  end;
  if (Graphic = nil) or (Dominator <> GraphDominator) then
    if Dominator then CreateDominatorGraphic
    else CreateNormalGraphic;
end;
{ @end $6CAFD0 }

{ @routine $6CB03C TShip_CreateNormalGraphic }
procedure TShip.CreateNormalGraphic;
begin
  if (Graphic <> nil) and not GraphDominator then Exit;
  ReleaseSpaceObject(Graphic);
  CollisionRadius := 32;
  if (GetPlayer = Self) and (Galaxy <> nil) and (Galaxy.SpecialSimulationMode <> 0) then
  begin
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.Tranclucator', Classes.Point(0, 0)));
    Graphic.SetAlpha(0);
  end
  else if GetHull.HullType = hull_special then
  begin
    if IsFemaleHumanPilot and (TypeId = ship_ranger) and (GetHull.HullType = hull_special) and (GetHull.GetSpecialKindGraph = 'J') then
      RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.AkrinFemale.' + GetHull.GetSpecialKindGraph, Classes.Point(0, 0)))
    else
      RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.Akrin.' + GetHull.GetSpecialKindGraph, Classes.Point(0, 0)));
    Graphic.SetAlpha(0);
  end
  else if not (Self is TNormalShip) then
  begin
    if Self is TKling then
    begin
      if (Self as TKling).KlingType = dominator_boss then
      begin
        case (Self as TKling).DominatorSeries of
          series_blazer: RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.Blazer', Classes.Point(0, 0)));
          series_keller: RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.Keller', Classes.Point(0, 0)));
          series_terron: RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.Terron', Classes.Point(0, 0)));
        end;
        CollisionRadius := 74;
        Graphic.SetAlpha(255);
      end
      else
      begin
        RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
        case (Self as TKling).DominatorSeries of
          series_blazer: BlazerShipTemplates[(Self as TKling).KlingType].CopyTo(Graphic);
          series_keller: KellerShipTemplates[(Self as TKling).KlingType].CopyTo(Graphic);
          series_terron: TerronShipTemplates[(Self as TKling).KlingType].CopyTo(Graphic);
        end;
        Graphic.SetAlpha(200);
      end;
    end
    else if Self is TRuins then
    begin
      if TypeNameOverrideKey <> '' then
        RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.' + TypeNameOverrideKey, Classes.Point(0, 0)))
      else
        RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.' + ShipTypeNames[TypeId].Name, Classes.Point(0, 0)));
      CollisionRadius := 0;
      Graphic.SetAlpha(255);
    end
    else if Self is TTranclucator then
    begin
      RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.Tranclucator', Classes.Point(0, 0)));
      Graphic.SetAlpha(255);
    end;
  end
  else if (Self is TPirate) and (OwnerId = owner_pirate) and (TPirate(Self).PirateType <> 0) then
  begin
    RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
    PirateClanShipTemplates[GetHull.OwnerId].CopyTo(Graphic);
    Graphic.SetAlpha(0);
  end
  else if (Self is TWarrior) and ((Self as TWarrior).WarriorType = warrior_flagship) then
  begin
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[OwnerId].InternalName + '.WarriorBig', Classes.Point(0, 0)));
    Graphic.SetAlpha(0);
  end
  else if (TypeId = ship_ranger) and UsesVeteranHumanRangerAppearance then
  begin
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.People.RangerOldFag', Classes.Point(0, 0)));
    Graphic.SetAlpha(0);
  end
  else
  begin
    RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
    RaceShipTemplates[GetHull.OwnerId, GetHull.HullType].CopyTo(Graphic);
    Graphic.SetAlpha(0);
  end;
  GraphName := Graphic.GraphKey;
  Graphic.SetPosition(Position);
  Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
  GraphDominator := False;
  RefreshGraphicSize;
end;
{ @end $6CB03C }

{ @routine $6CB834 TShip_CreateDominatorGraphic }
procedure TShip.CreateDominatorGraphic;
var
  Series: TDominatorSeries;
  Kind: TDominatorKind;
  Divisor: Integer;
begin
  if (Graphic <> nil) and GraphDominator then Exit;
  if not (Self is TNormalShip) then
  begin
    if Graphic = nil then CreateNormalGraphic;
    GraphDominator := True;
    Exit;
  end;
  if ChameleonActive then
  begin
    ChameleonVisualType := SelectChameleonVisualType;
    Series := ChameleonSeries;
    Kind := ChameleonVisualType;
  end
  else
  begin
    Divisor := 7;
    Divisor := (Integer(Id) shr 1) mod Divisor;
    Kind := TDominatorKind(Byte(Divisor) + 1);
    Divisor := 3;
    Series := TDominatorSeries(Integer(Id) mod Divisor);
  end;
  ReleaseSpaceObject(Graphic);
  RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
  case Series of
    series_blazer: BlazerShipTemplates[Kind].CopyTo(Graphic);
    series_keller: KellerShipTemplates[Kind].CopyTo(Graphic);
    series_terron: TerronShipTemplates[Kind].CopyTo(Graphic);
  end;
  GraphName := Graphic.GraphKey;
  Graphic.SetPosition(Position);
  Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
  Graphic.SetAlpha(0);
  CollisionRadius := 32;
  GraphDominator := True;
  RefreshGraphicSize;
end;
{ @end $6CB834 }

{ @routine $6CB9A8 TShip_TransferToStar }
procedure TShip.TransferToStar(Star: TStar);
var
  PreviousStar: TStar;
  I: Integer;
  Ship: TShip;
begin
  if CurrentStar <> Star then TransitOriginStar := CurrentStar;
  PreviousStar := CurrentStar;
  I := PreviousStar.Ships.IndexOf(Self);
  if I >= 0 then PreviousStar.Ships.Delete(I);
  Star.Ships.Add(Self);
  CurrentStar := Star;
  I := PreviousStar.Ships.Count - 1;
  while I >= 0 do
  begin
    Ship := PreviousStar.Ships[I];
    if Ship.DockedTo = Self then
    begin
      Ship.TransferToStar(Star);
      if GetPlayer = Ship then PlayerStar := Star;
    end;
    Dec(I);
  end;
end;
{ @end $6CB9A8 }

{ @routine $6CBA34 TShip_FindCarriedItemById }
function TShip.FindCarriedItemById(Id: Cardinal): TItem;
var I, Count: Integer; Item: TItem; Station: TRuins;
begin
  Result := nil;
  Count := Inventory.Count;
  for I := 0 to Count - 1 do begin
    Item := Inventory[I];
    if Item.Id = Id then begin Result := Item; Exit; end;
  end;
  Count := Artefacts.Count;
  for I := 0 to Count - 1 do begin
    Item := Artefacts[I];
    if Item.Id = Id then begin Result := Item; Exit; end;
    if Item is TArtefactTranclucator then begin
      Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
      if Result <> nil then Exit;
    end;
  end;
  Count := GuaranteedDeathDropItems.Count;
  for I := 0 to Count - 1 do begin
    Item := GuaranteedDeathDropItems[I];
    if Item.Id = Id then begin Result := Item; Exit; end;
    if Item is TArtefactTranclucator then begin
      Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
      if Result <> nil then Exit;
    end;
  end;
  if Self is TRuins then begin
    Station := Self as TRuins;
    Count := Station.EquipmentShop.Count;
  for I := 0 to Count - 1 do begin
      Item := Station.EquipmentShop[I];
      if Item.Id = Id then begin Result := Item; Exit; end;
    end;
  end;
end;
{ @end $6CBA34 }

{ @routine $6CBBC8 TShip_TryRelocateUnseenShip }
procedure TShip.TryRelocateUnseenShip;
var I: Integer; Candidate, Destination: TStar; Planet: TPlanet;
    Distance, BestDistance: Single;
begin
  if GetPlayer = nil then Exit;
  if GetPlayer.ShouldKeepShipForQuests(Self) then Exit;
  if GetPlayer = PartnerShip then Exit;
  if ScriptShip <> nil then Exit;
  if AbsoluteScriptOrder <> 0 then Exit;
  if DestroyQueued then Exit;
  if NextRandomUnitFloat(RandomState) < 0.002 then Exit;
  if DaysSincePlayerSeen < 20 then Exit;
  if (Galaxy.CountFactionStars(faction_coalition) * 2.5 < Galaxy.CountEligibleRangers) and
    (Self is TRanger) and ((Self as TRanger).PlaceInRating > 10) then Exit;
  if GetPlayer = Self then Exit;
  BestDistance := 1e20;
  Destination := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Candidate := Galaxy.Stars[I];
    if (Candidate <> CurrentStar) and (Candidate.ControlFaction = faction_coalition) and
      (Candidate.Status.CustomFaction = '') and (Candidate.Battle = 0) and (GetPlayer.CurrentStar <> Candidate) and
      (Candidate.ShipTypeCounts[ship_ranger] < 3) then
    begin
      Distance := PointDistanceSquared(CurrentStar.Position, Candidate.Position);
      if (Distance < BestDistance) and ((Destination = nil) or (NextRandomIntRange(0, 1, RandomState) = 0)) then
      begin
        BestDistance := Distance;
        Destination := Candidate;
      end;
    end;
  end;
  if Destination = nil then Exit;
  Planet := nil;
  I := 0;
  while I < Destination.Planets.Count do
  begin
    Planet := Destination.Planets[I];
    if Planet.OwnerId in [owner_maloc..owner_gaal, owner_pirate] then Break;
    Planet := nil;
    Inc(I);
  end;
  if Planet = nil then Exit;
  OrderNone(False);
  if GetFuelTanks = nil then CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
  if GetEngine = nil then CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
  CurrentStar.HandleObjectLeavingStar(Self);
  DockedTo := nil;
  CurrentPlanet := Planet;
  OrderTarget := Destination;
  GetHull.HullPoints := GetHull.Weight div 2;
  Galaxy.ShipsInTransit.Add(Self);
  if Galaxy.AverageRangerCapital div 2 > Wealth then
  begin
    SetMoney(Money + (Galaxy.AverageRangerCapital - Wealth) div 2);
    CalculateWealth;
  end;
end;
{ @end $6CBBC8 }

{ @routine $6CBEC8 TShip_SynchronizeDockedLocation }
procedure TShip.SynchronizeDockedLocation;
begin
  if DockedTo = nil then Exit;
  if DockedTo.CurrentStar <> CurrentStar then
  begin
    CurrentStar.Ships.Delete(CurrentStar.Ships.IndexOf(Self));
    CurrentStar := DockedTo.CurrentStar;
    DockedTo.CurrentStar.Ships.Add(Self);
  end;
  if DockedTo.CurrentPlanet = nil then Position := DockedTo.Position
  else Position := DockedTo.CurrentPlanet.GetPosition;
end;
{ @end $6CBEC8 }

{ @routine $6CBF48 TShip_InNormalSpace }
function TShip.InNormalSpace: Boolean;
begin
  if (GetPlayer <> Self) or (GetPlayer.RuinsMode = 0) then
    Result := (CurrentStar <> nil) and (CurrentPlanet = nil) and (DockedTo = nil) and not InHyperspace
  else Result := (CurrentStar <> nil) and (GetPlayer.RuinsSavedPlanet = nil) and (GetPlayer.RuinsSavedDockedTo = nil);
end;
{ @end $6CBF48 }

{ @routine $6CBFB0 TShip_IsOutsideStarSpace }
function TShip.IsOutsideStarSpace: Boolean;
begin
  Result := (CurrentPlanet <> nil) or (DockedTo <> nil) or InHyperspace or (CurrentStar = nil) or
    ((GetPlayer = Self) and ((GetPlayer.RuinsSavedPlanet <> nil) or (GetPlayer.RuinsSavedDockedTo <> nil)));
end;
{ @end $6CBFB0 }

{ @routine $6CBFFC TShip_IsOnPlanet }
function TShip.IsOnPlanet: Boolean;
begin
  Result := CurrentPlanet <> nil;
end;
{ @end $6CBFFC }

{ @routine $6CC004 TShip_IsDockedToShip }
function TShip.IsDockedToShip: Boolean;
begin
  Result := DockedTo <> nil;
end;
{ @end $6CC004 }

{ @routine $6CC00C TShip_IsDocked }
function TShip.IsDocked: Boolean;
begin
  Result := (DockedTo <> nil) or (CurrentPlanet <> nil);
end;
{ @end $6CC00C }

{ @routine $6CC020 TShip_HasPositiveSpeed }
function TShip.HasPositiveSpeed: Boolean;
begin
  Result := Speed > 0;
end;
{ @end $6CC020 }

{ @routine $6CC054 TShip_CancelInvalidTravelOrder }
procedure TShip.CancelInvalidTravelOrder;
  // @nested $6CC02C Cancel
  procedure Cancel; // @addr 0x006CC02C @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship at ParentFrame-4."
  begin
    if GetPlayer = Self then PendingPlayerFollowTarget := nil;
    OrderNone(False);
  end;
begin
  if IsOutsideStarSpace then Exit;
  if (OrderTarget is TShip) and ((OrderTarget as TShip).CurrentStar <> CurrentStar) then
    Cancel;
  if (GetEngine = nil) or (GetFuelTanks = nil) then Cancel;
  if (CalculateSpeed <= 0) and (Order <> order_teleport) then Cancel;
end;
{ @end $6CC054 }

{ @routine $6CC0E4 TShip_ClearPlanetQueue }
procedure TShip.ClearPlanetQueue;
begin
  if PlanetQueue <> nil then
  begin
    PlanetQueue.Free;
    PlanetQueue := nil;
  end;
end;
{ @end $6CC0E4 }

{ @routine $6CC100 TShip_SelectNearestQueuedPlanet }
function TShip.SelectNearestQueuedPlanet: TPlanet;
var Planet: TPlanet; I: Integer; BestDistance, Distance: Double;
begin
  Result := nil;
  if PlanetQueue.Count = 0 then Exit;
  Result := PlanetQueue[0];
  if Result.CurrentStar = CurrentStar then begin
    BestDistance := PointDistanceSquared(Position, Result.GetPosition);
    for I := 1 to PlanetQueue.Count - 1 do begin
      Planet := PlanetQueue[I];
      if Planet.CurrentStar <> CurrentStar then Break;
      Distance := PointDistanceSquared(Position, Planet.GetPosition);
      if Distance < BestDistance then begin Result := Planet; BestDistance := Distance; end;
    end;
  end;
end;
{ @end $6CC100 }

{ @routine $6CC1C8 TShip_FindNearestDockableStation }
function TShip.FindNearestDockableStation(StandingMask: TShipStandings): TShip;
var I: Integer; Ship: TShip; BestDistance, Distance: Double;
begin
  Result := nil;
  BestDistance := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship.TypeId in [station_ranger_center..station_custom]) and ((StandingMask = []) or
      (Ship.CurrentStanding in StandingMask)) and Ship.CanDock(Self) then begin
      Distance := PointDistanceSquared(Position, Ship.Position);
      if (Distance < BestDistance) or (Result = nil) then begin Result := Ship; BestDistance := Distance; end;
    end;
  end;
end;
{ @end $6CC1C8 }

{ @routine $6CC298 TShip_FindFirstInhabitedPlanetInStar }
function TShip.FindFirstInhabitedPlanetInStar: TPlanet;
var I: Integer;
begin
  Result := CurrentStar.Planets[0];
  if Result.OwnerId <> owner_uninhabited then Exit;
  for I := 1 to CurrentStar.Planets.Count - 1 do begin
    Result := CurrentStar.Planets[I];
    if Result.OwnerId <> owner_uninhabited then Break;
  end;
end;
{ @end $6CC298 }

{ @routine $6CC2E0 TShip_NavigateToQueuedPlanet }
function TShip.NavigateToQueuedPlanet(Absolute: Boolean): TPlanet;
var Planet: TPlanet;
begin
  if PlanetQueue = nil then begin
    BuildReachablePlanetQueue;
    if PlanetQueue = nil then begin Result := nil; Exit; end;
  end;
  if PlanetQueue.Count > 0 then begin
  Planet := SelectNearestQueuedPlanet;
  if CurrentStar = Planet.CurrentStar then OrderLanding(Planet, Absolute)
  else OrderJump(Planet.CurrentStar, Absolute);
  Result := Planet;
  end else Result := nil;
end;
{ @end $6CC2E0 }

{ @routine $6CC344 TShip_NavigateToEscapePlanet }
function TShip.NavigateToEscapePlanet(Absolute: Boolean): Boolean;
var Planet: TPlanet;
begin
  if PlanetQueue = nil then begin Result := False; Exit; end;
  if PlanetQueue.Count > 0 then begin
  if (NextRandomUnitFloat(RandomState) > 0.9) or (GetFuelTanks.Fuel = GetFuelTanks.Capacity) then Planet := PlanetQueue[PlanetQueue.Count - 1]
  else Planet := SelectNearestQueuedPlanet;
  if CurrentStar = Planet.CurrentStar then OrderLanding(Planet, Absolute)
  else OrderJump(Planet.CurrentStar, Absolute);
  Result := True;
  end else Result := False;
end;
{ @end $6CC344 }

{ @routine $6CC3E0 TShip_TryMirrorPartnerTravelOrders }
function TShip.TryMirrorPartnerTravelOrders: Boolean;
var Star: TStar;
begin
  if (PartnerShip as TRanger).PrisonTermRemaining > 0 then begin Result := False; Exit; end;
  if PartnerShip.CurrentStar = CurrentStar then begin
    if PartnerShip.InNormalSpace then begin
      if (PartnerShip.OrderTarget is TStar) and (PartnerShip.EstimateOrderTravelTurns < 5) and
        (not OrderAbsolute or (OrderTarget = PartnerShip)) then begin
        OrderJump(PartnerShip.OrderTarget as TStar, False); Result := True; Exit;
      end;
      if (PartnerShip.OrderTarget is TPlanet) and CanQueueReachablePlanet(PartnerShip.OrderTarget as TPlanet) and
        (PartnerShip.EstimateOrderTravelTurns < 5) and (not OrderAbsolute or (OrderTarget = PartnerShip)) then begin
        OrderLanding(PartnerShip.OrderTarget, CanRefuel); Result := True; Exit;
      end;
      if (PartnerShip.OrderTarget is TShip) and (PartnerShip.Order = order_land) and (PartnerShip.EstimateOrderTravelTurns < 5) and
        (not OrderAbsolute or (OrderTarget = PartnerShip)) and TShip(PartnerShip.OrderTarget).CanDock(Self) then begin
        OrderLanding(PartnerShip.OrderTarget, CanRefuel or (OrderTarget = PartnerShip)); Result := True; Exit;
      end;
      if (PartnerShip.Order = order_follow_ship) and (PartnerShip.EstimateOrderTravelTurns < 3) and not OrderAbsolute then begin
        OrderFollowShip(PartnerShip.OrderTarget as TShip, follow_close, False); Result := True; Exit;
      end;
      if (PartnerShip.OrderTarget is TStar) and CanRefuel then begin
        if Self is TPirate then (Self as TPirate).SelectNearestReachableDestination
        else if Self is TRanger then (Self as TRanger).SelectNearestReachableDestination;
        Result := False;
        Exit;
      end else begin
        if OrderTarget = PartnerShip then begin Result := True; Exit; end;
        OrderFollowShip(PartnerShip, follow_close, False);
        Result := True;
        Exit;
      end;
    end else begin
      if PartnerShip.CurrentPlanet <> nil then begin
        if CanQueueReachablePlanet(PartnerShip.CurrentPlanet) then begin OrderLanding(PartnerShip.CurrentPlanet, True); Result := True; Exit; end;
      end else if (PartnerShip.DockedTo <> nil) then
        if (PartnerShip.DockedTo is TRuins) and
          (PartnerShip.DockedTo as TRuins).CanDock(Self) then begin OrderLanding(PartnerShip.DockedTo, False); Result := True; Exit; end;
    end;
  end else begin
    if PartnerShip.OrderTarget is TStar then Star := PartnerShip.OrderTarget as TStar else Star := nil;
    if (Star <> nil) and (((Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = '')) or
      (GetFuelTanks.Fuel div 2 >= PointDistance(CurrentStar.Position, Star.Position))) then begin
      if (Star <> CurrentStar) and
        (((JumpRange * JumpRange) >= PointDistanceSquared(CurrentStar.Position, Star.Position)) or (GetFuelTanks.Fuel = GetFuelTanks.Capacity)) and
        (not (Self is TPirate) or ((Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = ''))) then begin
        OrderJump(Star, True);
        Result := True;
        Exit;
      end;
    end else begin
      Star := PartnerShip.CurrentStar;
      if (((JumpRange * JumpRange) >= PointDistanceSquared(CurrentStar.Position, Star.Position)) or (GetFuelTanks.Fuel = GetFuelTanks.Capacity)) and
        (((Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = '')) or
          (GetFuelTanks.Fuel div 2 >= PointDistance(CurrentStar.Position, Star.Position))) and
        (not (Self is TPirate) or ((Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = ''))) then begin
        OrderJump(Star, True);
        Result := True;
        Exit;
      end;
    end;
  end;
  Result := False;
end;
{ @end $6CC3E0 }

{ @routine $6CC900 TShip_OrderRandomFreeFlightMove }
procedure TShip.OrderRandomFreeFlightMove;
var
  Polar: TPolarPoint;
begin
  Polar.Radius := NextRandomIntRange(CurrentStar.SystemRadius + 300, CurrentStar.ComputeMapDiameter, RandomState);
  Polar.AngleDegrees := NextRandomUnitFloat(RandomState) * 360;
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $6CC900 }

{ @routine $6CC96C TShip_IsTargetStillPursuable }
function TShip.IsTargetStillPursuable(Target: TShip): Boolean;
begin
  if (Target.Order <> order_jump) or (PointDistance(Position, Target.Position) < Speed * 2) then Result := True
  else Result := False;
end;
{ @end $6CC96C }

{ @routine $6CC9A8 TShip_CanEscapePursuer }
function TShip.CanEscapePursuer(Pursuer: TShip): Boolean;
var I: Integer; Weapon: TWeapon; Distance: Double;
begin
  Result := True;
  if ((EstimateOrderTravelTurns = 1) and (GetHull.HullPoints > GetHull.Weight * 0.5)) or
    ((EstimateOrderTravelTurns = 2) and (GetHull.HullPoints > GetHull.Weight * 0.9)) then Exit;
  Distance := PointDistance(Position, Pursuer.Position);
  for I := 1 to Pursuer.WeaponCount do begin
    Weapon := Pursuer.Weapons[I];
    if Pursuer.IsEquipmentUsable(Weapon) and (GetWeaponRange(Weapon) > Distance) then begin Result := False; Exit; end;
  end;
  if (Pursuer.Speed < Speed) and (2 * Pursuer.Speed < Distance) then Exit;
  if 2 * Pursuer.Speed > Distance then begin Result := False; Exit; end;
  if 6 * Pursuer.Speed < Distance then Exit;
  if Order = order_land then begin
    if OrderTarget is TShip then begin
      if PointDistance((OrderTarget as TShip).Position, Position) / (Speed + 1) > 3 then begin Result := False; Exit; end;
    end else if PointDistance((OrderTarget as TPlanet).GetPosition, Position) / (Speed + 1) > 3 then begin Result := False; Exit; end;
  end else if (Pursuer.Order = order_jump) and (PointDistance(OrderDestination, Position) / (Speed + 1) > 6) then begin Result := False; Exit; end;
end;
{ @end $6CC9A8 }

{ @routine $6CCBFC TShip_HasLandablePlanetInStar }
function TShip.HasLandablePlanetInStar(Star: TStar): Boolean;
var I: Integer; Planet: TPlanet;
begin
  for I := 0 to Star.Planets.Count - 1 do begin
    Planet := Star.Planets[I];
    if (Planet.OwnerId <> owner_uninhabited) and CanQueueReachablePlanet(Planet) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $6CCBFC }

{ @routine $6CCC4C TShip_GetFullFuelBaseJumpRange }
function TShip.GetFullFuelBaseJumpRange: Integer;
begin
  Result := Min(GetFuelTanks.Capacity, GetEngine.JumpRange);
end;
{ @end $6CCC4C }

{ @routine $6CCC70 TShip_FindNextStarTowardDestination }
function TShip.FindNextStarTowardDestination(Destination: TStar; RequireFuelMargin: Boolean): TStar;
const CoalitionShips = [ship_ranger..ship_tranclucator];
var I, J, K, RangeSquared, CapacitySquared: Integer; Origin, Star: TStar; Predecessors: TList; Previous: Integer;
begin
  Predecessors := TList.Create;
  Predecessors.Add(nil);
  for I := 1 to Galaxy.Stars.Count - 1 do Predecessors.Add(Pointer(-1));
  RangeSquared := GetFullFuelBaseJumpRange * GetFullFuelBaseJumpRange;
  CapacitySquared := GetFuelTanks.Capacity * GetFuelTanks.Capacity;
  for I := 0 to Galaxy.Stars.Count - 2 do begin
    Origin := CurrentStar.StarDistances[I].Star as TStar;
    if (Origin.Constellation.Id = 20) or (Integer(Predecessors[I]) = -1) then Continue;
    for J := 1 to Galaxy.Stars.Count - 1 do begin
      Star := Origin.StarDistances[J].Star as TStar;
      if Star.Constellation.Id = 20 then Continue;
      if (RangeSquared < PointDistanceSquared(Origin.Position, Star.Position)) or
        (RequireFuelMargin and (CapacitySquared < PointDistanceSquared(Origin.Position, Star.Position) * 2)) then Break;
      if Star = Destination then begin
        Previous := Integer(Predecessors[I]);
        Result := Origin;
        while Previous > 1 do begin
          Result := CurrentStar.StarDistances[Previous - 1].Star as TStar;
          Previous := Integer(Predecessors[Previous - 1]);
        end;
        Predecessors.Free;
        Exit;
      end;
      if not (HasLandablePlanetInStar(Star) and (Star.CountShipsByTypeMask(CoalitionShips) <= 20) and (Star.ShipTypeCounts[ship_ranger] <= 9)) then Continue;
      for K := 1 to Galaxy.Stars.Count - 1 do
        if (CurrentStar.StarDistances[K].Star as TStar) = Star then begin
          if Integer(Predecessors[K]) = -1 then Predecessors[K] := Pointer(I + 1);
          Break;
        end;
    end;
  end;
  Result := nil;
  Predecessors.Free;
end;
{ @end $6CCC70 }

{ @routine $6CCF14 TShip_DistanceToNearestShipByTypeMask }
function TShip.DistanceToNearestShipByTypeMask(ShipTypeMask: TShipTypeMask): Double;
var I: Integer; Ship: TShip; BestDistance, Distance: Single;
begin
  BestDistance := 1000000000;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship.TypeId in ShipTypeMask) and (Ship <> Self) then begin
      Distance := PointDistanceSquared(Position, Ship.Position);
      if Distance < BestDistance then BestDistance := Distance;
    end;
  end;
  Result := Sqrt(BestDistance);
end;
{ @end $6CCF14 }

{ @routine $6CCFA8 TShip_EstimateOrderTravelTurns }
function TShip.EstimateOrderTravelTurns: Integer;
begin
  case Order of
    order_move: Result := Round(PointDistance(OrderDestination, Position) / (Speed + 1)) + 1;
    order_land:
      if OrderTarget is TPlanet then
        Result := Round(PointDistance((OrderTarget as TPlanet).GetPosition, Position) / (Speed + 1)) + 1
      else Result := Round(PointDistance((OrderTarget as TShip).Position, Position) / (Speed + 1)) + 1;
    order_jump: Result := Round(PointDistance(OrderDestination, Position) / (Speed + 1)) + 1;
    order_black_hole: Result := Round(PointDistance(OrderDestination, Position) / (Speed + 1)) + 1;
    order_follow_ship: Result := Round(PointDistance((OrderTarget as TShip).Position, Position) / (Speed + 1)) + 1;
  else Result := 0;
  end;
end;
{ @end $6CCFA8 }

{ @routine $6CD114 TShip_EstimateTravelTurnsToObject }
function TShip.EstimateTravelTurnsToObject(Target: TObject): Integer;
var Angle, Radius: Double; Point: TPointF;
begin
  if Target is TPlanet then Result := Round(PointDistance((Target as TPlanet).GetPosition, Position) / (Speed + 1)) + 1
  else if Target is TShip then Result := Round(PointDistance((Target as TShip).Position, Position) / (Speed + 1)) + 1
  else if Target is TStar then begin
    Angle := HeadingDegreesToRadians(PointBearingDegrees(CurrentStar.Position, (Target as TStar).Position));
    Radius := CurrentStar.ComputeMapDiameter / 2;
    Point.X := Trunc(Sin(Angle) * Radius);
    Point.Y := Trunc(-Cos(Angle) * Radius);
    Result := Round(PointDistance(Point, Position) / (Speed + 1)) + 1;
  end else Result := 0;
end;
{ @end $6CD114 }

{ @routine $6CD294 TShip_EstimateTravelTurnsToPlanet }
function TShip.EstimateTravelTurnsToPlanet(Planet: TPlanet): Integer;
begin
  if (Speed = 0) or (Planet = nil) or (Planet.CurrentStar = nil) or (Planet.CurrentStar <> CurrentStar) then begin Result := -1; Exit; end;
  Result := Round(PointDistance(Planet.GetPosition, Position) / (Speed + 1)) + 1;
end;
{ @end $6CD294 }

{ @routine $6CD2F0 TShip_NotifyCompanionDeath }
procedure TShip.NotifyCompanionDeath;
var
  Text: WideString;
begin
  if Self is TRanger then Text := PickLocalizedTextVariant('GalaxyNews.DeadShip.Partner', Seed + Galaxy.CurrentTurn div 11)
  else if Self is TPirate then Text := PickLocalizedTextVariant('GalaxyNews.DeadShip.Pirate', Seed + Galaxy.CurrentTurn div 11)
  else if Self is TTranclucator then Text := PickLocalizedTextVariant('GalaxyNews.DeadShip.Tranclucator', Seed + Galaxy.CurrentTurn div 11)
  else Exit;
  if Self is TTranclucator then GetPlayer.RefreshStorageBubbles;
  ReplaceTextToken(Text, '<Star>', CurrentStar.Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(-1), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Name>', GetName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<FullName>', GetFullName(' '), TextHighlightColorTag);
  AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, Text, '');
end;
{ @end $6CD2F0 }

{ @routine $6CD5E0 TShip_ApplyDamage }
function TShip.ApplyDamage(Source: TObject; Damage: Integer; HitRange: Single; out DamageColor: Cardinal; DamageFlags: TDamageFlagSet): Integer;
const
  ScannerDamageFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  NoDamageFlags = [];
var
  I, J: Integer;
  Reserved: Integer; { Native keeps an unused scalar between the loop indices and damage local. }
  AdjustedDamage, EngineLoss, DropCount, MinimumPriority, MaximumPriority: Integer;
  DamageValue, Wear, DropRoll: Single;
  Nodes: TProtoplasm;
  Debris: TUselessItem;
  Item: TItem;
  UnusedText: WideString; { Native initializes/finalizes this otherwise unused managed local. }
  Module: TMicroModule;
  Cistern: TCistern;
  Event: TGalaxyEvent;
  ExpectedHullPoints: Integer;
  ScannerEffects: Boolean;
  Attacker: TShip;
  Effect: TEFilmObj;
  SceneObject: TObjectSE;
  StatusStrength: Single;
begin
  Attacker := nil;
  if Source <> nil then
  begin
    if Source is TShip then Attacker := TShip(Source)
    else if Source is TMissile then Attacker := TMissile(Source).OwnerShip;
  end;
  if (HitRange = -1) and (Attacker <> nil) then ReactToAttack(Attacker);
  DamageColor := 0;
  if (TypeId = ship_dominator) and (Attacker <> nil) and (Attacker.TypeId = ship_dominator) and
    ((Self as TKling).DominatorSeries = (Attacker as TKling).DominatorSeries) and
    not (Attacker as TKling).IsProgramActive(program_insanity) and
    (HasIndependentScriptFaction = Attacker.HasIndependentScriptFaction) and
    (not HasIndependentScriptFaction or (TScriptShip(ScriptShip).StateText = TScriptShip(Attacker.ScriptShip).StateText)) then
  begin
    Result := 0;
    Exit;
  end;
  if (HitRange <> -1) and ((OwnerId in [owner_maloc..owner_gaal, owner_pirate]) or (TypeId = ship_tranclucator)) and
    (Attacker <> nil) and (GetRelationLevelToShip(Attacker) > relation_level_hostile) then
  begin
    Result := 0;
    Exit;
  end;
  if (HitRange <> -1) and (TypeId = ship_dominator) and (GetPlayer = Attacker) and
    (Self as TKling).IsPlayerCamouflageEffective(Attacker) then
  begin
    Result := 0;
    Exit;
  end;
  if (HitRange <> -1) and (Attacker <> nil) and (Attacker.TypeId = ship_dominator) and (GetPlayer = Self) and
    (Attacker as TKling).IsPlayerCamouflageEffective(Self) then
  begin
    Result := 0;
    Exit;
  end;
  if (Attacker <> nil) and (Self <> Attacker) and
    (not (Source is TMissile) or (HitRange = -1) or (GetRelationLevelToShip(Attacker) <= relation_level_hostile)) then
  begin
    if (GetPlayer = Self) and (Attacker.ScriptShip <> nil) then TScriptShip(Attacker.ScriptShip).HitPlayer := True;
    if ScriptShip <> nil then
      if (GetPlayer = Attacker) or (GetPlayer = Attacker.PartnerShip) or
        ((Attacker is TTranclucator) and ((Attacker as TTranclucator).OwnerShip = GetPlayer)) then
        TScriptShip(ScriptShip).Hit := True;
  end;
  DamageValue := Damage;
  if (HitRange = -1) and (Attacker <> nil) and (Attacker is TKling) and
    (Attacker.GetScannerPower > GetDefensePercent) and
    (Attacker.GetRadarRange * Attacker.GetRadarRange >= PointDistanceSquared(Position, Attacker.Position)) then
    DamageValue := (1 + (Attacker.GetScannerPower - GetDefensePercent) * 0.01) * DamageValue;
  ScannerEffects := (ScannerDamageFlags * DamageFlags <> NoDamageFlags) and (HitRange = -1) and (Attacker <> nil) and
    Attacker.IsEquipmentUsable(Attacker.GetScanner) and
    (Attacker.GetScannerPower >= GetDefensePercent) and
    (Attacker.GetRadarRange * Attacker.GetRadarRange >= PointDistanceSquared(Position, Attacker.Position));
  if ScannerEffects then
  begin
    if damage_flag_scanner_bonus in DamageFlags then DamageValue := DamageValue * 1.15;
    if damage_flag_bonus_to_damaged_hull in DamageFlags then DamageValue := (1 + (1 - GetHull.HullPoints / GetHull.Weight) * 0.33) * DamageValue;
  end;
  if damage_flag_energy in DamageFlags then
    for J := 1 to CountActiveArtefacts(artefact_energy_defense) do
      if NextRandomUnitFloat(RandomState) < 0.3 * (Ord(CanBoostArtefact(artefact_energy_defense, nil, False)) + 1) then
      begin
        DamageValue := 0;
        Break;
      end;
  if damage_flag_missile in DamageFlags then
    for J := 1 to CountActiveArtefacts(artefact_missile_defense) do
      DamageValue := DamageValue / (1 + NextRandomFloatRange(0.1, 0.4, RandomState) *
        (Ord(CanBoostArtefact(artefact_missile_defense, nil, False)) + 1));
  if (Attacker <> nil) and (GetPlayer = Attacker) then
  begin
    if Attacker.IsHealthEffectActive(disease_bitter_pelenosia) or Attacker.IsHealthEffectActive(disease_whirlwind_concussion) or
      Attacker.IsHealthEffectActive(disease_pulled_muscle) then DamageValue := DamageValue * NextRandomUnitFloat(RandomState);
    if TypeId = ship_dominator then (Self as TKling).DetectAttackingPlayer(Attacker);
  end;
  if DamageValue < 1 then
    if NextRandomUnitFloat(RandomState) < 0.5 then DamageValue := 1 else DamageValue := 2;
  if (Self is TKling) and (DamageValue > 0) and ((Self as TKling).DominatorSeries = series_keller) and
    (Self as TKling).HasNearbyBertorAura then
  begin
    if CurrentStar.RecordingTurnFilm and not (Self as TKling).AuraEffectShownThisTurn then
    begin
      SceneObject := TWeaponSE.Create('Weapon.AuraEffect', Classes.Point(0, 0), 1, -1);
      Effect := PrimaryFilm.AddObject(0, SceneObject);
      PrimaryFilm.SetWeaponEndpoints(CurrentStar.CurrentStepIndex, Effect, FilmObject, FilmObject);
      PrimaryFilm.SetWeaponHit(CurrentStar.CurrentStepIndex, Effect, 0, 0, False, True);
      PrimaryFilm.AttachObject(CurrentStar.CurrentStepIndex, Effect);
      (Self as TKling).AuraEffectShownThisTurn := True;
    end;
    DamageValue := DamageValue * 0.8;
  end;
  DamageValue := DamageValue * GetHull.GetFragilityFactor(DamageFlags);
  StatusStrength := GetCombatStatusStrength(combat_effect_node_boost);
  if StatusStrength > 0.01 then DamageValue := DamageValue / (1 + StatusStrength * 0.01);
  if Attacker <> nil then StatusStrength := Attacker.GetCombatStatusStrength(combat_effect_node_boost)
  else StatusStrength := 0;
  if StatusStrength > 0.01 then DamageValue := DamageValue * (1 + StatusStrength * 0.01);
  if TypeId = ship_dominator then
  begin
    if (Self as TKling).KlingType = dominator_boss then
    begin
      if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then
      begin
        if DaysSincePlayerSeen > 20 then DamageValue := DamageValue * 0.5;
        if Round(DamageValue) >= GetHull.HullPoints then DamageValue := GetHull.HullPoints - 1;
      end;
      if (Round(DamageValue) >= GetHull.HullPoints) and (KellerShip = Self) then DamageValue := GetHull.HullPoints - 1;
    end;
  end
  else if (Attacker <> nil) and (Attacker.TypeId = ship_dominator) and ((Attacker as TKling).KlingType = dominator_boss) then
    DamageValue := DamageValue * 2 * Galaxy.InterpolateDifficulty(-1, 0.7, 1, 1.2, 1.5);
  AdjustedDamage := Round(DamageValue);
  if (GetPlayer = Self) and ((Galaxy.GodModEnabled = 1) or (Galaxy.SpecialSimulationMode <> 0)) then AdjustedDamage := 0;
  if (Order = order_teleport) and (OrderTarget <> nil) and (OrderTarget <> CurrentStar) then AdjustedDamage := 0;
  if GetHull.ImpulseShieldsEnabled and (not (damage_flag_ignore_defenses in DamageFlags)) and
    (NextRandomIntRange(0, 100, RandomState) > GetDefenseDamageFactor * 100) then
  begin
    Result := -AdjustedDamage;
    DamageColor := 0;
    Exit;
  end;
  if Attacker <> nil then AdjustedDamage := Attacker.ScriptItemsAct(event_deal_damage, Self, nil, AdjustedDamage);
  AdjustedDamage := ScriptItemsAct(DamageScriptActionTypes[ClassifyWeaponDamageFlags(DamageFlags)], Source, nil, AdjustedDamage);
  if AdjustedDamage <= 0 then
  begin
    Result := 0;
    DamageColor := 0;
    Exit;
  end;
  ExpectedHullPoints := 0;
  if (GetHull.HullPoints - AdjustedDamage <= 0) and (KellerShip <> Self) and (not (damage_flag_nonlethal in DamageFlags)) then
  begin
    if Attacker <> nil then
    begin
      Attacker.ScriptItemsAct(event_deal_fatal_damage, Self, nil, 0);
      if Attacker is TNormalShip then (Attacker as TNormalShip).ProcessShipKill(Self);
      if Attacker.TypeId = ship_ranger then (Attacker as TRanger).ApplyAttackReputationChanges(Self, 1);
      if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = ship_ranger) then
        (Attacker.PartnerShip as TRanger).ApplyAttackReputationChanges(Self, 0.5);
      if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and
        (TTranclucator(Attacker).OwnerShip.TypeId = ship_ranger) then
      begin
        ((Attacker as TTranclucator).OwnerShip as TRanger).ApplyAttackReputationChanges(Self, 1);
        if (Attacker as TTranclucator).OwnerShip = GetPlayer then
        begin
          Event := AddGalaxyEvent('PlayerTranclucatorKillsShip');
          Event.AddData(Ord(TypeId));
          Event.AddData(CurrentStar.Id);
          Event.AddData(Id);
          Event.AddData(Ord(OwnerId));
          Event.AddTextData(GetName);
          Event.AddData(Attacker.Id);
          Event.AddData(Ord(Attacker.OwnerId));
          Event.AddTextData(Attacker.GetName);
          Event.AddData(GetFullHullRelativeStrengthPercent);
          Event.AddTextData(GetFullName(' '));
          Event.AddTextData(TypeNameOverrideKey);
          if Self is TKling then Event.AddData(Byte((Self as TKling).KlingType))
          else if Self is TTransport then Event.AddData(Byte((Self as TTransport).TransportType))
          else if Self is TWarrior then Event.AddData(Ord((Self as TWarrior).WarriorType))
          else if Self is TPirate then Event.AddData((Self as TPirate).PirateType)
          else Event.AddData(0);
        end;
      end;
    end;
    if Source = nil then ScriptItemsAct(event_death, nil, nil, 0)
    else if Source is TMissile then ScriptItemsAct(event_death, TMissile(Source).OwnerShip, Source, 0)
    else if Source is TShip then ScriptItemsAct(event_death, Source, nil, 0)
    else ScriptItemsAct(event_death, nil, nil, 0);
    DropGuaranteedDeathDropItems;
    GetHull.HullPoints := 0;
    if (GetPlayer = PartnerShip) or ((Self is TTranclucator) and ((Self as TTranclucator).OwnerShip = GetPlayer)) then
      NotifyCompanionDeath;
    CurrentStar.UpdateControlFaction;
    GetPlayer.ProcessShipDestructionQuests(Self);
    if (NextRandomUnitFloat(RandomState) < 0.5) and not HasScriptStateText then
    begin
      Cistern := TCistern.Create;
      I := NextRandomIntRange(10, Round(RemapClamped(GetHull.Weight, 200, 2000, 10, 150)), RandomState);
      Cistern.Init(NextRandomIntRange(1, I, RandomState), RoundAndTruncateToFives(I), OwnerId);
      if OwnerId = owner_dominator then Cistern.DominatorSeries := (Self as TKling).DominatorSeries;
      Inventory.Add(Cistern);
      DropCarriedItemAsMovingLoot(Cistern);
    end;
    if Self is TRuins then JettisonCargoGoodsTowardTargetValue(Galaxy.ComputeScaledHugeMoney(owner_human))
    else if (CurrentStar.Items = nil) or (CurrentStar.Items.Count < 20) or (OwnerId = owner_dominator) or HasIndependentScriptFaction then
    begin
      DropRoll := NextRandomUnitFloat(RandomState);
      if (DropRoll < 0.1) and (not (Self is TKling) or (Attacker = nil) or not (Attacker is TKling) or
        (DropRoll < 0.1 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor)) then
        DropRandomValuableItemsOnDestruction(1)
      else
      begin
        if DropRoll < 0.85 then DropCount := 1 else DropCount := 2;
        if (Attacker <> nil) and (Attacker.CountActiveArtefacts(artefact_extra_loot) > 0) then
        begin
          if NextRandomUnitFloat(RandomState) > 0.6 then Inc(DropCount)
          else if (NextRandomUnitFloat(RandomState) > 0.8 - Attacker.CountActiveArtefacts(artefact_extra_loot) * 0.2 *
            (Ord(Attacker.CanBoostArtefact(artefact_extra_loot, nil, False)) + 1)) or
            (ScannerEffects and (damage_flag_extra_loot in DamageFlags) and (NextRandomUnitFloat(RandomState) > 0.9)) then
            DropRandomValuableItemsOnDestruction(1);
        end;
        if ScannerEffects and (damage_flag_extra_loot in DamageFlags) and (NextRandomUnitFloat(RandomState) > 0.6) then Inc(DropCount);
        DropRandomCheapItemsOnDestruction(DropCount);
      end;
      if OwnerId = owner_pirate then
        if (TypeId = ship_pirate) and ((RandomState + Cardinal(Galaxy.CurrentTurn)) mod 31 = 0) then
      begin
        Module := TMicroModule.Create;
        MinimumPriority := Round(RemapClamped(WealthInBestRanger, 0.5, 2, 10, 0));
        Inc(MinimumPriority, Round(RemapClamped(GetPlayer.PlaceInRating, 1, Galaxy.Rangers.Count, 0, 10)));
        Inc(MinimumPriority, Round(RemapClamped(Ord(GetPlayer.PirateRank), 0, 7, 10, 0)));
        Inc(MinimumPriority, Galaxy.ScaleIntByTechLevel(20, 0));
        Inc(MinimumPriority, SeededRandomIntRange(-10, 10, Id + Trunc(Integer(Galaxy.GenerationSeed))));
        MinimumPriority := Max(1, Min(MinimumPriority, 100));
        MaximumPriority := 100;
        Module.Init(Galaxy.SelectMicroModule(Byte(MinimumPriority), Byte(MaximumPriority),
          Id + Trunc(Integer(Galaxy.GenerationSeed)), Self));
        Module.DominatorSeries := series_blazer;
        Module.OwnerId := owner_pirate;
        Inventory.Add(Module);
        DropCarriedItemAsMovingLoot(Module);
      end;
      if OwnerId = owner_dominator then
      begin
        if ((RandomState + Cardinal(Galaxy.CurrentTurn)) mod 2 = 0) or ((Self as TKling).KlingType = dominator_boss) then
        begin
          Nodes := TProtoplasm.Create;
          Nodes.Init(NodeReserve + 1, 1);
          Nodes.DominatorSeries := (Self as TKling).DominatorSeries;
          Inventory.Add(Nodes);
          DropCarriedItemAsMovingLoot(Nodes);
        end
        else
        begin
          Debris := TUselessItem.Create;
          Debris.Init('Remains', (Self as TKling).DominatorSeries, Seed + Cardinal(Galaxy.CurrentTurn div 10), False);
          Inventory.Add(Debris);
          DropCarriedItemAsMovingLoot(Debris);
        end;
        if (RandomState + Cardinal(Galaxy.CurrentTurn)) mod 47 = 0 then
        begin
          Module := TMicroModule.Create;
          MinimumPriority := Round(RemapClamped(WealthInBestRanger, 0.5, 2, 10, 0));
          Inc(MinimumPriority, Round(RemapClamped(GetPlayer.PlaceInRating, 1, Galaxy.Rangers.Count, 0, 10)));
          Inc(MinimumPriority, Round(RemapClamped(Ord(GetPlayer.Rank), 0, 7, 10, 0)));
          Inc(MinimumPriority, Galaxy.ScaleIntByTechLevel(20, 0));
          Inc(MinimumPriority, SeededRandomIntRange(-10, 10, Id + Trunc(Integer(Galaxy.GenerationSeed))));
          MinimumPriority := Max(1, Min(MinimumPriority, 100));
          MaximumPriority := 100;
          Module.Init(Galaxy.SelectMicroModule(Byte(MinimumPriority), Byte(MaximumPriority),
            Id + Trunc(Integer(Galaxy.GenerationSeed)), Self));
          Module.DominatorSeries := (Self as TKling).DominatorSeries;
          Module.OwnerId := owner_dominator;
          Inventory.Add(Module);
          DropCarriedItemAsMovingLoot(Module);
        end;
      end
      else if TypeId in [ship_ranger..ship_pirate] then JettisonCargoGoodsTowardTargetValue(Galaxy.ComputeScaledAverageMoney(OwnerId));
    end;
    if GetPlayer = Attacker then TryDropTreasureMap;
    if Artefacts.Count > 0 then DropAllArtefactsOnDestruction;
    for I := Inventory.Count - 1 downto 1 do
    begin
      Item := Inventory[I];
      if (Item is TUselessItem) and (Item.DestroyFlag <= 0) then DropCarriedItemAsMovingLoot(Item);
    end;
  end
  else
  begin
    ExpectedHullPoints := GetHull.HullPoints;
    Dec(GetHull.HullPoints, AdjustedDamage);
    if GetHull.HullPoints <> ExpectedHullPoints - AdjustedDamage then GR_Main.CCInterface.SetTamperDetected(True);
    if ((KellerShip = Self) or (damage_flag_nonlethal in DamageFlags)) and (GetHull.HullPoints < 1) then GetHull.HullPoints := 1;
    ExpectedHullPoints := GetHull.HullPoints;
    if (AdjustedDamage = 1) and (GetPlayer = Attacker) and (Attacker <> nil) then
    begin
      Inc(PlayerScratchHitsReceived);
      GetPlayer.AchievementStats.CheckScratchDamageAchievement(PlayerScratchHitsReceived);
    end;
    EngineLoss := NextRandomIntRange(0, 2, RandomState);
    if damage_flag_engine_slow in DamageFlags then Inc(EngineLoss, NextRandomIntRange(5, 15, RandomState));
    if damage_flag_artefact_slow in DamageFlags then Inc(EngineLoss, NextRandomIntRange(5, 15, RandomState));
    if damage_flag_extra_artefact_slow in DamageFlags then Inc(EngineLoss, NextRandomIntRange(5, 15, RandomState));
    if (EngineLoss > 0) and (GetEngine <> nil) then
      if GetEngine.OutputPercent > EngineLoss then Dec(GetEngine.OutputPercent, EngineLoss)
      else GetEngine.OutputPercent := 0;
    if TypeId <> ship_tranclucator then
    begin
      if OwnerId <> owner_dominator then
      begin
        Wear := RemapClamped(AdjustedDamage, 1, GetHull.Weight * 0.1, 0.05, 0.15);
        if Self is TRanger then
        begin
          if GetPlayer = Self then Wear := Wear
          else Wear := Wear * 0.8;
        end
        else if Self is TWarrior then
        begin
          Wear := Wear * 0.5;
          if (Self as TWarrior).WarriorType = warrior_flagship then Wear := Wear * 0.6;
        end;
        if ScannerEffects and (damage_flag_engine_wear in DamageFlags) and (GetEngine <> nil) and (GetEngine.BrokenFlag = 0) then
        begin
          ApplyCombatItemDegradation(0.5 * Wear);
          ApplyItemDegradation(GetEngine, wear_combat, 15 * Wear);
        end
        else ApplyCombatItemDegradation(Wear);
        if damage_flag_equipment_wear in DamageFlags then
        begin
          Wear := NextRandomFloatRange(5, 15, RandomState);
          if Self is TWarrior then Wear := Wear * 0.3
          else if Self is TRanger then
          begin
            if GetPlayer = Self then Wear := Wear
            else Wear := Wear * 0.6;
          end;
          Wear := Wear * 0.1;
          if ScannerEffects and (damage_flag_engine_wear in DamageFlags) and (GetEngine <> nil) and (GetEngine.BrokenFlag = 0) then
          begin
            ApplyCombatItemDegradation(0.5 * Wear);
            ApplyItemDegradation(GetEngine, wear_combat, 15 * Wear);
          end
          else ApplyCombatItemDegradation(Wear);
        end;
      end
      else if TerronShip <> Self then
      begin
        if ((RandomState + Cardinal(Galaxy.CurrentTurn)) mod 4 = 0) and (CurrentStar.Items.Count < 25) then
        begin
          Nodes := TProtoplasm.Create;
          Nodes.Init(NextRandomIntRange(NodeReserve div 8, NodeReserve div 4, RandomState) + 1, 1);
          Nodes.DominatorSeries := (Self as TKling).DominatorSeries;
          Inventory.Add(Nodes);
          DropCarriedItemAsMovingLoot(Nodes);
        end;
        if ScannerEffects and (damage_flag_force_cargo_drop in DamageFlags) and (NextRandomUnitFloat(RandomState) > 0.95) then
        begin
          Nodes := TProtoplasm.Create;
          Nodes.Init(NextRandomIntRange(NodeReserve div 4, NodeReserve div 2, RandomState) + 1, 1);
          Nodes.DominatorSeries := (Self as TKling).DominatorSeries;
          Inventory.Add(Nodes);
          DropCarriedItemAsMovingLoot(Nodes);
        end;
      end;
    end;
    if ScannerEffects and (damage_flag_force_cargo_drop in DamageFlags) and (NextRandomUnitFloat(RandomState) > 0.95) then
      JettisonCargoGoodsTowardTargetValue(Galaxy.ComputeScaledMiniMoney(owner_human));
    if ScannerEffects and (damage_flag_weapon_block in DamageFlags) then AddCombatStatusStrength(combat_effect_weapon_block, 0.1, Attacker);
    if ScannerEffects and (damage_flag_droid_block in DamageFlags) then AddCombatStatusStrength(combat_effect_droid_block, 0.1, Attacker);
    if damage_flag_shock in DamageFlags then
      if Self is TKling then AddCombatStatusStrength(combat_effect_shock, AdjustedDamage * 0.12, Attacker)
      else AddCombatStatusStrength(combat_effect_shock, AdjustedDamage * 0.2, Attacker);
    if (damage_flag_acid in DamageFlags) and (GetHull.Armor > GetCombatStatusStrength(combat_effect_acid)) then
      if Self is TKling then AddCombatStatusStrength(combat_effect_acid, 0.66, Attacker)
      else AddCombatStatusStrength(combat_effect_acid, 1, Attacker);
    if damage_flag_magnetic in DamageFlags then
      if Self is TKling then AddCombatStatusStrength(combat_effect_magnetic, 0.07 + Max(0, Damage + GetArmor) * 0.075, Attacker)
      else AddCombatStatusStrength(combat_effect_magnetic, 0.1 + Max(0, Damage + GetArmor) * 0.05, Attacker);
  end;
  if GetPlayer = Self then DamageColor := OwnerToFilmColor(RaceToOwner(PilotRace))
  else if HasNamedScriptFaction then DamageColor := CustomFactionToFilmColor(TScriptShip(ScriptShip).StateText)
  else DamageColor := OwnerToFilmColor(OwnerId);
  if AdjustedDamage <= 0 then DamageColor := 0;
  RefreshDerivedStats(True);
  Result := AdjustedDamage;
  if (damage_flag_life_steal in DamageFlags) and (Attacker <> nil) then
  begin
    if (GetPlayer = Attacker) and (AdjustedDamage > 0) and (Attacker.GetHull.Weight > Attacker.GetHull.HullPoints) then
    begin
      Inc(GetPlayer.AchievementStats.DrainedHullPoints, Min(Attacker.GetHull.Weight - Attacker.GetHull.HullPoints, AdjustedDamage));
      TrySetAchievementProgress('DRAIN', GetPlayer.AchievementStats.DrainedHullPoints);
    end;
    Attacker.GetHull.HullPoints := Min(Attacker.GetHull.Weight, AdjustedDamage + Attacker.GetHull.HullPoints);
  end;
  if (GetPlayer = Self) and (RandomIntRange(0, 100) = 0) then SysUtils.Sleep(1);
  if (GetHull.HullPoints <> ExpectedHullPoints) and not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
  if IsHullDestroyed then CurrentStar.ClearShipReferences(Self);
end;
{ @end $6CD5E0 }

{ @routine $6CF4B4 TShip_ApplyWeaponHit }
function TShip.ApplyWeaponHit(Source: TShip; Weapon: TWeapon; HitRange: Single; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet; DamageScale: Single; FixedDamage: Integer): Integer;
const
  EnergyDamageFlags = [damage_flag_energy];
var
  I, RolledDamage, Damage, MaxDamage, MinDamage, Spread, SkillDifference: Integer;
  AdjustedDamage, DamageStep: Single;
  Event: TGalaxyEvent;
  Flags: TDamageFlagSet;
  ScriptFlags: Integer;
  Film: TEFilmObj;
  Effect: TObjectSE;
begin
  Flags := Weapon.GetDamageFlags;
  if (FixedDamage > 0) and not (damage_flag_ignore_defenses in Flags) then
  begin
    AdjustedDamage := FixedDamage;
    Include(Flags, damage_flag_ignore_defenses);
  end
  else
  begin
    SkillDifference := Source.GetEffectiveSkillLevel(skill_accuracy) -
      GetEffectiveSkillLevel(skill_maneuverability);
    MaxDamage := Source.GetWeaponMaxDamage(Weapon);
    MinDamage := Source.GetWeaponMinDamage(Weapon);
    DamageStep := (MaxDamage - MinDamage) / 12;
    Spread := Round((6 - Abs(SkillDifference)) * DamageStep);
    RolledDamage := Round(RemapClamped(SkillDifference, -6, 6, MinDamage, MaxDamage));
    RolledDamage := NextRandomIntRange(Max(MinDamage, RolledDamage - Spread), Min(MaxDamage, RolledDamage + Spread), RandomState);
    RolledDamage := Round(RolledDamage * DamageScale);
    if (Source is TKling) and ((Source as TKling).DominatorSeries = series_blazer) then
      if (Source as TKling).HasNearbyBertorAura then
      begin
        if CurrentStar.RecordingTurnFilm and not (Source as TKling).AuraEffectShownThisTurn then
        begin
          Effect := TWeaponSE.Create('Weapon.AuraEffect', Classes.Point(0, 0), 0, -1);
          Film := PrimaryFilm.AddObject(0, Effect);
          PrimaryFilm.SetWeaponEndpoints(CurrentStar.CurrentStepIndex, Film, Source.FilmObject, Source.FilmObject);
          PrimaryFilm.SetWeaponHit(CurrentStar.CurrentStepIndex, Film, 0, 0, False, True);
          PrimaryFilm.AttachObject(CurrentStar.CurrentStepIndex, Film);
          (Source as TKling).AuraEffectShownThisTurn := True;
        end;
        RolledDamage := Round(RolledDamage * 1.25);
      end;
    RolledDamage := Source.ScriptItemsAct(event_weapon_shot, Self, Weapon, RolledDamage);
    if damage_flag_ignore_defenses in Flags then AdjustedDamage := RolledDamage
    else
    begin
      if not GetHull.ImpulseShieldsEnabled then
        AdjustedDamage := GetDefenseDamageFactor * RolledDamage - GetArmor
      else AdjustedDamage := (GetDefenseDamageFactor * 0.5 + 0.5) * RolledDamage - GetArmor;
    end;
  end;
  if (Source.GetDefGenerator <> nil) and (Source.CountActiveArtefacts(artefact_defense_to_energy) > 0) and
    (damage_flag_energy in Weapon.GetWeaponInfo.DamageFlags) then
    AdjustedDamage := (1 + (RemapClamped(Source.CountWeaponsByDamageFlags(EnergyDamageFlags), 1, 5,
      DefenseToEnergyUpperFactor + ShortInt(Source.CanBoostArtefact(artefact_defense_to_energy, Weapon, False)) * DefenseToEnergyUpperBoost,
      DefenseToEnergyMinimumFactor + ShortInt(Source.CanBoostArtefact(artefact_defense_to_energy, Weapon, False)) * DefenseToEnergyMinimumBoost) - 1) *
      Source.CountActiveArtefacts(artefact_defense_to_energy)) * AdjustedDamage;
  if damage_flag_energy in Weapon.GetWeaponInfo.DamageFlags then
    for I := 1 to Source.CountActiveArtefacts(artefact_energy_pulse) do
      if NextRandomUnitFloat(RandomState) < EnergyPulseArtefactChance then
        AdjustedDamage := (EnergyPulseArtefactFactor + ShortInt(Source.CanBoostArtefact(artefact_energy_pulse, Weapon, False)) *
          EnergyPulseArtefactBoostFactor) * AdjustedDamage;
  if (Source.CountActiveArtefacts(artefact_decelerate) > 0) and (damage_flag_splinter in Weapon.GetWeaponInfo.DamageFlags) then
  begin
    Include(Flags, damage_flag_artefact_slow);
    if Source.CanBoostArtefact(artefact_decelerate, Weapon, False) or (Source.CountActiveArtefacts(artefact_decelerate) > 1) then Include(Flags, damage_flag_extra_artefact_slow);
  end;
  if damage_flag_splinter in Weapon.GetWeaponInfo.DamageFlags then
    for I := 1 to Source.CountActiveArtefacts(artefact_splinter) do
      AdjustedDamage := (SplinterArtefactFactor + ShortInt(Source.CanBoostArtefact(artefact_splinter, Weapon, False)) *
        SplinterArtefactBoostFactor) * AdjustedDamage;
  Damage := Round(AdjustedDamage);
  ScriptFlags := Integer(Flags);
  ScriptFlags := Source.ScriptItemsAct(event_weapon_hit_flags, Self, Weapon, ScriptFlags);
  ScriptFlags := ScriptItemsAct(event_receive_weapon_hit, Source, Weapon, ScriptFlags);
  Flags := TDamageFlagSet(ScriptFlags);
  DamageFlags := Flags;
  Result := ApplyDamage(Source, Damage, HitRange, DamageColor, Flags);
  if (GetHull.HullPoints < 1) and (GetPlayer = Source) then
  begin
    if damage_flag_splinter in Weapon.GetWeaponInfo.DamageFlags then TryAddAchievementProgress('SPLINTER', 1);
    if damage_flag_energy in Weapon.GetWeaponInfo.DamageFlags then TryAddAchievementProgress('ENERGY', 1);
  end;
  if (GetPlayer = Self) and (GetHull.HullPoints < 1) then
  begin
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('KilledByBeamWeapon');
    ScoreScreen.RecordPlayerResult(False);
  end;
end;
{ @end $6CF4B4 }

{ @routine $6CFB10 TShip_ApplyMissileHit }
function TShip.ApplyMissileHit(Missile: TObject; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet): Integer;
var
  Shot: TMissile;
  RolledDamage, Damage, MaxDamage, MinDamage, Spread, SkillDifference: Integer;
  AdjustedDamage, DamageStep: Single;
  Event: TGalaxyEvent;
  Flags: TDamageFlagSet;
  ScriptFlags: Integer;
  HitRange: Single;
begin
  Shot := Missile as TMissile;
  Flags := Shot.GetWeaponInfo.DamageFlags;
  if Shot.MicroModuleIndex <> 0 then
    Flags := Flags + MicroModuleTemplates[Shot.MicroModuleIndex - 1].WeaponDamageFlags;
  if Shot.SpecialModuleIndex <> 0 then
    Flags := Flags + MicroModuleTemplates[Shot.SpecialModuleIndex - 1].WeaponDamageFlags;
  ScriptFlags := Integer(Flags);
  if Shot.OwnerShip <> nil then ScriptFlags := Shot.OwnerShip.ScriptItemsAct(event_missile_hit_flags, Self, Missile, ScriptFlags);
  ScriptFlags := ScriptItemsAct(event_receive_missile_hit, Shot.OwnerShip, Missile, ScriptFlags);
  Flags := TDamageFlagSet(ScriptFlags);
  DamageFlags := Flags;
  if Shot.OwnerShip = nil then
    SkillDifference := 0 - GetEffectiveSkillLevel(skill_maneuverability)
  else SkillDifference := Shot.OwnerShip.GetEffectiveSkillLevel(skill_accuracy) -
    GetEffectiveSkillLevel(skill_maneuverability);
  MinDamage := Shot.MinDamage;
  MaxDamage := Shot.MaxDamage;
  DamageStep := (MaxDamage - MinDamage) / 12;
  Spread := Round((6 - Abs(SkillDifference)) * DamageStep);
  RolledDamage := Round(RemapClamped(SkillDifference, -6, 6, MinDamage, MaxDamage));
  RolledDamage := NextRandomIntRange(Max(MinDamage, RolledDamage - Spread), Min(MaxDamage, RolledDamage + Spread), RandomState);
  if damage_flag_ignore_defenses in Flags then AdjustedDamage := RolledDamage
  else
  begin
    if not GetHull.ImpulseShieldsEnabled then AdjustedDamage := GetDefenseDamageFactor * RolledDamage
    else AdjustedDamage := (GetDefenseDamageFactor * 0.5 + 0.5) * RolledDamage;
    AdjustedDamage := AdjustedDamage - GetArmor;
  end;
  if Shot.Target = Self then HitRange := -1 else HitRange := 0;
  Damage := Round(AdjustedDamage);
  Result := ApplyDamage(Shot, Damage, HitRange, DamageColor, DamageFlags);
  if (GetHull.HullPoints < 1) and (Shot.OwnerShip <> nil) and (GetPlayer = Shot.OwnerShip) then
    TryAddAchievementProgress('ROCKET', 1);
  if (GetPlayer = Self) and (GetHull.HullPoints < 1) then
  begin
    ScoreScreen.RecordPlayerResult(False);
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('KilledByMissile');
  end;
end;
{ @end $6CFB10 }

{ @routine $6CFE04 TShip_FireWeaponAtMissile }
procedure TShip.FireWeaponAtMissile(Weapon: TWeapon; Target: TObject; RecordFilm: Boolean);
var
  Star: TStar;
  Shot, Other: TMissile;
  Hit, OtherHit: Boolean;
  StepIndex: Integer;
  Effect: TObjectSE;
  Film: TEFilmObj;
  I: Integer;
  Info: PWeaponInfo;
begin
  if Target is TMissile then
  begin
    Shot := TMissile(Target);
    Star := CurrentStar;
    StepIndex := Star.CurrentStepIndex;
    Hit := Shot.CanBeHit(Self, Weapon);
    Hit := ScriptItemsAct(event_weapon_shot, Shot, Weapon, Byte(Hit)) <> 0;
    Info := Weapon.GetWeaponInfo;
    if RecordFilm then
    begin
      Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Shot.FilmObject);
      PrimaryFilm.SetObjectPosition(StepIndex, Film, Shot.Position);
      PrimaryFilm.SetDestructionEffect(StepIndex, Film, 2);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
      if Hit then
      begin
        Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
        Film := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetObjectPosition(StepIndex, Film, Shot.Position);
        PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
        PrimaryFilm.AttachObject(StepIndex, Film);
      end;
    end;
    if (damage_flag_energy in Info.DamageFlags) and (Info.ShotType = shot_splash) then
    begin
      I := 0;
      while I < Star.Missiles.Count do
      begin
        Other := Star.Missiles[I];
        Inc(I);
        if Shot = Other then Continue;
        if PointDistanceSquared(Shot.Position, Other.Position) > Sqr(Info.SecondaryDamageRadius) then Continue;
        OtherHit := Other.CanBeHit(Self, Weapon);
        OtherHit := ScriptItemsAct(event_weapon_shot, Other, Weapon, Byte(OtherHit)) <> 0;
        if OtherHit then
        begin
          if RecordFilm then
          begin
            Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
            Film := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetObjectPosition(StepIndex, Film, Other.Position);
            PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
            PrimaryFilm.AttachObject(StepIndex, Film);
            PrimaryFilm.DetachObject(StepIndex, Other.FilmObject);
            Star.PendingFilmObjectRemovals.Add(Other.FilmObject);
            ReleaseSpaceObject(Other.Graphic);
          end;
          Star.ClearTargetReferences(Other);
          Other.Free;
        end;
      end;
    end
    else if (damage_flag_energy in Info.DamageFlags) and (Info.ShotType = shot_area_damage) then
    begin
      I := 0;
      while I < Star.Missiles.Count do
      begin
        Other := Star.Missiles[I];
        Inc(I);
        if Shot = Other then Continue;
        if PointDistanceSquared(Position, Other.Position) > Sqr(GetWeaponRange(Weapon)) * 1.3 then Continue;
        if (TypeId = ship_dominator) and (Other.OwnerShip <> nil) and (Other.OwnerShip.TypeId = ship_dominator) and
          ((Self as TKling).DominatorSeries = (Other.OwnerShip as TKling).DominatorSeries) then Continue;
        OtherHit := Other.CanBeHit(Self, Weapon);
        OtherHit := ScriptItemsAct(event_weapon_shot, Other, Weapon, Byte(OtherHit)) <> 0;
        if OtherHit then
        begin
          if RecordFilm then
          begin
            Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
            Film := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetObjectPosition(StepIndex, Film, Other.Position);
            PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
            PrimaryFilm.AttachObject(StepIndex, Film);
            PrimaryFilm.DetachObject(StepIndex, Other.FilmObject);
            Star.PendingFilmObjectRemovals.Add(Other.FilmObject);
            ReleaseSpaceObject(Other.Graphic);
          end;
          Star.ClearTargetReferences(Other);
          Other.Free;
        end;
      end;
    end;
    if Hit then
    begin
      if RecordFilm then
      begin
        PrimaryFilm.DetachObject(StepIndex, Shot.FilmObject);
        Star.PendingFilmObjectRemovals.Add(Shot.FilmObject);
        ReleaseSpaceObject(Shot.Graphic);
      end;
      Star.ClearTargetReferences(Shot);
      Shot.Free;
    end;
  end;
end;
{ @end $6CFE04 }

{ @routine $6D08CC TShip_FireWeaponAtShip }
procedure TShip.FireWeaponAtShip(Weapon: TWeapon; Target: TShip; RecordFilm: Boolean);
var
  Color: Cardinal;
  Flags: TDamageFlagSet;
  Count: Integer;
  Star: TStar;
  DistanceSquared: Single;
  Info: PWeaponInfo;
  Damage, DrainedDamage: Integer;
  Effect: TObjectSE;
  Film: TEFilmObj;
  StepIndex: Integer;
  Ships, Damages, Colors, Films: TList;
  GraphKey: WideString;
  Ship, Nearest: TShip;
  I, PrimaryDamage: Integer;
  RadiusSquared, DamageScale, NearestDistance, CandidateDistance: Single;
  ShotIndex: Integer;
  PlaySound: Boolean;
  DisplayColor: Cardinal;
  J: Integer;
  Reflect: Boolean;

  // @nested $6D0394 ApplyChainExplosion
  function ApplyChainExplosion(ExplodingShip: TShip): Integer; // @addr 0x006D0394 @note "Caller-popped static link; recursively damages nearby hostiles. Returns the accumulated signed damage results."
  var
    I: Integer;
    Ship: TShip;
  begin
    Result := 0;
    for I := 0 to Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship = ExplodingShip then Continue;
      if Self = Ship then Continue;
      if not Ship.InNormalSpace then Continue;
      if Ship.IsHullDestroyed then Continue;
      DistanceSquared := PointDistanceSquared(Ship.Position, ExplodingShip.Position);
      if not (Sqr(Info.SecondaryDamageRadius) >= DistanceSquared) then Continue;
      if GetRelationLevelToShip(Ship) > relation_level_hostile then Continue;
      if Self is TKling then
        if (Self as TKling).IsPlayerCamouflageEffective(Ship) then Continue;
      if Ship is TKling then
        if (Ship as TKling).IsPlayerCamouflageEffective(Self) then Continue;
      Damage := Ship.ApplyWeaponHit(Self, Weapon, Sqrt(DistanceSquared), Color, Flags, 1,
        Round(ExplodingShip.CalculateMass * 0.1));
      if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
      Inc(Result, Damage);
      if RecordFilm then
      begin
        Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
        Film := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, ExplodingShip.FilmObject, Ship.FilmObject);
        Ships.Add(Ship);
        Damages.Add(Pointer(Damage));
        Colors.Add(Pointer(Color));
        Films.Add(Film);
      end;
      if Ship.IsHullDestroyed then
      begin
        GraphKey := Info.AreaSE;
        if GraphKey <> '' then
        begin
          Effect := TWeaponSE.Create(GraphKey, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
          Film := PrimaryFilm.AddObject(0, Effect);
          PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, ExplodingShip.FilmObject, ExplodingShip.FilmObject);
          PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
          PrimaryFilm.AttachObject(StepIndex, Film);
        end;
        Inc(Result, ApplyChainExplosion(Ship));
      end;
    end;
  end;

  // @nested $6D070C FinishChainExplosionFilm
  procedure FinishChainExplosionFilm; // @addr 0x006D070C @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; merges repeated targets' damage in the parent's film lists."
  var
    Damage: Integer;
    Color: Cardinal;
    Ship: TShip;
    Index, I: Integer;
  begin
    Index := Ships.Count - 1;
    while Index >= 0 do
    begin
      Ship := Ships[Index];
      Damage := Integer(Damages[Index]);
      Color := Cardinal(Colors[Index]);
      for I := Index - 1 downto 0 do
        if Ships[I] = Ship then Inc(Damage, Integer(Damages[I]));
      PrimaryFilm.SetWeaponHit(StepIndex, TEFilmObj(Films[Index]), Word(Color), Damage, Ship.IsHullDestroyed, True);
      PrimaryFilm.AttachObject(StepIndex, TEFilmObj(Films[Index]));
      Ships.Delete(Index);
      Damages.Delete(Index);
      Colors.Delete(Index);
      Films.Delete(Index);
      for I := Index - 1 downto 0 do
        if Ships[I] = Ship then
        begin
          PrimaryFilm.SetWeaponHit(StepIndex, TEFilmObj(Films[I]), 0, 0, False, True);
          PrimaryFilm.AttachObject(StepIndex, TEFilmObj(Films[I]));
          Ships.Delete(I);
          Damages.Delete(I);
          Colors.Delete(I);
          Films.Delete(I);
        end;
      Index := Ships.Count - 1;
    end;
  end;

begin
  if Target.IsHullDestroyed then Exit;
  Star := CurrentStar;
  StepIndex := Star.CurrentStepIndex;
  if (GetPlayer = Target) or (GetPlayer = Self) then Star.PlayerCombatOccurred := True;
  if (GetPlayer = Target) and RecordFilm then
    PrimaryFilm.AddCameraEvent(StepIndex, GetPlayer.Position, Position, 1);
  PrimaryDamage := 0;
  DrainedDamage := 0;
  Info := Weapon.GetWeaponInfo;
  if Info.ShotType = shot_single_target then
  begin
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
    PrimaryDamage := Damage;
    if RecordFilm then
    begin
      if (GetPlayer = Self) and RecordFilm then
        PrimaryFilm.AddCameraEvent(StepIndex, GetPlayer.Position, Target.Position, 1);
      Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Target.FilmObject);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, Target.IsHullDestroyed, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
    end;
  end
  else if Info.ShotType = shot_chain then
  begin
    if ((GetPlayer = Self) and RecordFilm) and (Star.PlayerFilmPath <> nil) then
      Star.PlayerFilmPath.AppendWaypoint(MakePointF((Target.Position.X + Position.X) / 2,
        (Target.Position.Y + Position.Y) / 2), StepIndex + 25);
    RadiusSquared := Sqr(GetWeaponRange(Weapon)) * 1.3;
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
    PrimaryDamage := Damage;
    Ships := TList.Create;
    Damages := TList.Create;
    Colors := TList.Create;
    Films := TList.Create;
    Ships.Add(Self);
    Ships.Add(Target);
    Damages.Add(nil);
    Damages.Add(Pointer(Damage));
    Colors.Add(nil);
    Colors.Add(Pointer(Color));
    if not Target.IsHullDestroyed then
    begin
      Count := Star.Ships.Count;
      DamageScale := 1;
      for ShotIndex := 2 to Weapon.GetShotCount do
      begin
        RadiusSquared := RadiusSquared * Weapon.GetShotCount / (Weapon.GetShotCount + 3);
        DamageScale := DamageScale - 1 / (Weapon.GetShotCount + 1);
        if (RadiusSquared <= 0) or (DamageScale <= 0) then Break;
        NearestDistance := 1E30;
        Nearest := nil;
        for I := 0 to Count - 1 do
        begin
          Ship := Star.Ships[I];
          if Ship.InNormalSpace and not Ship.IsHullDestroyed and (Ships.IndexOf(Ship) < 0) and
            (GetRelationLevelToShip(Ship) <= relation_level_hostile) then
            if not (Self is TKling) or not (Self as TKling).IsPlayerCamouflageEffective(Ship) then
              if not (Ship is TKling) or not (Ship as TKling).IsPlayerCamouflageEffective(Self) then
              begin
                CandidateDistance := PointDistanceSquared(Ship.Position, TShip(Ships[Ships.Count - 1]).Position);
                if (CandidateDistance <= RadiusSquared) and (CandidateDistance < NearestDistance) then
                begin
                  NearestDistance := CandidateDistance;
                  Nearest := Ship;
                end;
              end;
        end;
        if Nearest = nil then
        begin
          DamageScale := DamageScale - 1 / (Weapon.GetShotCount + 1);
          Nearest := Ships[Ships.Count - 1];
          Damage := Nearest.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, DamageScale, 0);
          Damages[Damages.Count - 1] := Pointer(Integer(Damages[Damages.Count - 1]) + Damage);
          Break;
        end;
        Damage := Nearest.ApplyWeaponHit(Self, Weapon, 0, Color, Flags, DamageScale, 0);
        if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
        Ships.Add(Nearest);
        Damages.Add(Pointer(Damage));
        Colors.Add(Pointer(Color));
        if Nearest.IsHullDestroyed or (Damage <= 0) then Break;
      end;
    end;
    if RecordFilm then
    begin
      Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Target.FilmObject);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Integer(Damages[1]), Target.IsHullDestroyed, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
      for ShotIndex := 2 to Damages.Count - 1 do
      begin
        Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
        Film := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, TShip(Ships[ShotIndex - 1]).FilmObject, TShip(Ships[ShotIndex]).FilmObject);
        PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Colors[ShotIndex]), Integer(Damages[ShotIndex]), TShip(Ships[ShotIndex]).IsHullDestroyed, False);
        PrimaryFilm.AttachObject(StepIndex, Film);
      end;
    end;
    Ships.Clear;
    Ships.Free;
    Ships := nil;
    Damages.Clear;
    Damages.Free;
    Damages := nil;
    Colors.Clear;
    Colors.Free;
    Colors := nil;
    Films.Clear;
    Films.Free;
    Films := nil;
  end
  else if Info.ShotType = shot_splash then
  begin
    if ((GetPlayer = Self) and RecordFilm) and (Star.PlayerFilmPath <> nil) then
      Star.PlayerFilmPath.AppendWaypoint(MakePointF((Target.Position.X + Position.X) / 2,
        (Target.Position.Y + Position.Y) / 2), StepIndex + 25);
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
    PrimaryDamage := Damage;
    if RecordFilm then
    begin
      Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Target.FilmObject);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, Target.IsHullDestroyed, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
    end;
    Count := Star.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Ship := Star.Ships[I];
      if (Ship <> Self) and (Ship <> Target) and Ship.InNormalSpace and not Ship.IsHullDestroyed then
      begin
        DistanceSquared := PointDistanceSquared(Ship.Position, Target.Position);
        if Sqr(Info.SecondaryDamageRadius) >= DistanceSquared then
        begin
          Damage := Ship.ApplyWeaponHit(Self, Weapon, Sqrt(DistanceSquared), Color, Flags, 1, 0);
          if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
          if RecordFilm then
          begin
            Effect := TWeaponSE.Create(Info.SecondarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
            Film := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, Target.FilmObject, Ship.FilmObject);
            PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, Ship.IsHullDestroyed, True);
            PrimaryFilm.AttachObject(StepIndex, Film);
          end;
        end;
      end;
    end;
  end
  else if Info.ShotType = shot_explode_on_kill then
  begin
    if (GetPlayer = Self) and RecordFilm then
      PrimaryFilm.AddCameraEvent(StepIndex, GetPlayer.Position, Target.Position, 1);
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
    PrimaryDamage := Damage;
    if RecordFilm then
    begin
      Effect := TWeaponSE.Create(Info.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Target.FilmObject);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, Target.IsHullDestroyed, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
    end;
    if Target.IsHullDestroyed then
    begin
      Count := Star.Ships.Count;
      if RecordFilm then
      begin
        GraphKey := Info.AreaSE;
        if GraphKey <> '' then
        begin
          Effect := TWeaponSE.Create(GraphKey, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
          Film := PrimaryFilm.AddObject(0, Effect);
          PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, Target.FilmObject, Target.FilmObject);
          PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
          PrimaryFilm.AttachObject(StepIndex, Film);
        end;
      end;
      Ships := TList.Create;
      Damages := TList.Create;
      Colors := TList.Create;
      Films := TList.Create;
      Damage := ApplyChainExplosion(Target);
      if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
      if RecordFilm then FinishChainExplosionFilm;
      Ships.Clear;
      Ships.Free;
      Ships := nil;
      Damages.Clear;
      Damages.Free;
      Damages := nil;
      Colors.Clear;
      Colors.Free;
      Colors := nil;
      Films.Clear;
      Films.Free;
      Films := nil;
    end;
  end
  else if Info.ShotType = shot_area_damage then
  begin
    PlaySound := True;
    RadiusSquared := Sqr(GetWeaponRange(Weapon)) * 1.3;
    if RecordFilm then
    begin
      GraphKey := Info.AreaSE;
      if GraphKey <> '' then
      begin
        Effect := TWeaponSE.Create(GraphKey, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
        Film := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, FilmObject);
        PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
        PrimaryFilm.AttachObject(StepIndex, Film);
      end;
    end;
    Count := Star.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Ship := Star.Ships[I];
      if (Ship <> Self) and Ship.InNormalSpace and not Ship.IsHullDestroyed then
        if PointDistanceSquared(Ship.Position, Position) <= RadiusSquared then
        begin
          if Target = Ship then Damage := Ship.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0)
          else Damage := Ship.ApplyWeaponHit(Self, Weapon, PointDistance(Position, Ship.Position), Color, Flags, 1, 0);
          if (damage_flag_life_steal in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
          if RecordFilm then
          begin
            Effect := TWeaponSE.Create(Info.SecondarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
            Film := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Ship.FilmObject);
            PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, Ship.IsHullDestroyed, PlaySound);
            PrimaryFilm.AttachObject(StepIndex, Film);
            PlaySound := False;
          end;
        end;
    end;
  end;
  if RecordFilm and (DrainedDamage > 0) then
  begin
    Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
    Film := PrimaryFilm.AddObject(0, Effect);
    PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, FilmObject);
    if GetPlayer = Self then DisplayColor := OwnerToFilmColor(RaceToOwner(PilotRace))
    else if HasNamedScriptFaction then DisplayColor := CustomFactionToFilmColor(TScriptShip(ScriptShip).StateText)
    else DisplayColor := OwnerToFilmColor(OwnerId);
    PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(DisplayColor), -DrainedDamage, False, True);
    PrimaryFilm.AttachObject(StepIndex, Film);
  end;
  if (PrimaryDamage <> 0) and (Target.CountActiveArtefacts(artefact_defense) > 0) then
  begin
    Reflect := PrimaryDamage < 0;
    if not Reflect then
      for J := 1 to Target.CountActiveArtefacts(artefact_defense) do
        if RandomUnitFloat > Target.GetDefenseDamageFactor then
        begin
          Reflect := True;
          Break;
        end;
    if Reflect then
    begin
      Damage := ApplyWeaponHit(Target, Weapon, -1, Color, Flags, 1, Abs(PrimaryDamage));
      if RecordFilm then
      begin
        Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
        Film := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, Target.FilmObject, FilmObject);
        PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, IsHullDestroyed, True);
        PrimaryFilm.AttachObject(StepIndex, Film);
      end;
    end;
  end;
end;
{ @end $6D08CC }

{ @routine $6D1B2C TShip_FireWeaponAtItem }
procedure TShip.FireWeaponAtItem(Weapon: TWeapon; Target: TItem; RecordFilm: Boolean);
var
  Star: TStar;
  StepIndex: Integer;
  Effect: TObjectSE;
  Film: TEFilmObj;
  I, Quantity, Count, ActionResult, Damage: Integer;
  Explodes: Boolean;
  Ship: TShip;
  Item: TItem;
  DistanceSquared: Single;
  Color: Cardinal;
  WasWeaponTarget: Boolean;
begin
  Star := CurrentStar;
  StepIndex := Star.CurrentStepIndex;
  ActionResult := ScriptItemsAct(event_weapon_shot, Target, Weapon, 0);
  if Target.DestroyFlag = 0 then Target.DestroyFlag := 1;
  WasWeaponTarget := (Weapon <> nil) and (Weapon.Target = Target);
  if Target.ScriptItem <> nil then
    ActionResult := TScriptItem(Target.ScriptItem).RunActionCode(event_item_hit, Self, Weapon, CurrentStar, ActionResult);
  if Target is TEquipmentWithActCode then
    ActionResult := RunItemConfigActionCode(Target, event_item_hit, Self, Weapon, CurrentStar, ActionResult);
  if WasWeaponTarget and (Weapon.Target <> Target) then Exit;
  Explodes := (Target.ItemType = artefact_bomb) or ((Target is TCistern) and ((Target as TCistern).Fuel > 0)) or
    (ActionResult > 0) or (Target.DestroyFlag >= 2);
  if RecordFilm then
  begin
    if Weapon <> nil then
    begin
      Effect := TWeaponSE.Create(Weapon.GetWeaponInfo.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, Target.FilmObject);
    end
    else
    begin
      Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, Target.FilmObject, Target.FilmObject);
    end;
    PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, Target.DestroyFlag >= 0, True);
    if Target.DestroyFlag >= 0 then
      if Target.DestroyFlag = 0 then PrimaryFilm.SetDestructionEffect(StepIndex, Film, 6)
      else if Explodes then PrimaryFilm.SetDestructionEffect(StepIndex, Film, 1)
      else PrimaryFilm.SetDestructionEffect(StepIndex, Film, 3);
    PrimaryFilm.AttachObject(StepIndex, Film);
  end;
  if Explodes then
  begin
    Count := Star.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Ship := Star.Ships[I];
      if not (Ship.InNormalSpace and not Ship.IsHullDestroyed and
        ((GetPlayer <> Ship) or ((Galaxy.GodModEnabled <> 1) and (Galaxy.SpecialSimulationMode = 0)))) then Continue;
      DistanceSquared := PointDistanceSquared(Ship.Position, Target.Position);
      if ItemExplosionRadiusSquared >= DistanceSquared then
      begin
        Damage := Ship.ApplyExplosionDamage(Self, Target, ActionResult, nil);
        if Ship.IsHullDestroyed and (GetPlayer <> nil) and (Target.ItemType = artefact_bomb) and (GetPlayer = Self) then
          Inc(GetPlayer.BombKillsThisTurn);
        Color := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
        if RecordFilm and (Damage > 0) then
        begin
          Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
          Film := PrimaryFilm.AddObject(0, Effect);
          PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, Ship.FilmObject, Ship.FilmObject);
          PrimaryFilm.SetWeaponHit(StepIndex, Film, Word(Color), Damage, Ship.IsHullDestroyed, True);
          PrimaryFilm.AttachObject(StepIndex, Film);
        end;
      end;
    end;
    Count := Star.Items.Count;
    for I := 0 to Count - 1 do
    begin
      Item := Star.Items[I];
      if Item = Target then Continue;
      DistanceSquared := PointDistanceSquared(Item.Position, Target.Position);
      if ItemExplosionRadiusSquared >= DistanceSquared then
        if 20 - 20 * DistanceSquared / ItemExplosionRadiusSquared >= NextRandomIntRange(1, 100, Star.RandomState) then
        begin
          if Item.DestroyFlag < 0 then Inc(Item.DestroyFlag)
          else Star.ReferencedItems.Add(Item);
        end;
    end;
  end
  else if (GetPlayer = Self) and (Target is TGoods) and (Target as TGoods).NaturalFlag then
  begin
    Quantity := (Target as TGoods).Quantity;
    if Quantity >= 5 then
      Star.DropMinerals(Trunc(Quantity * 0.8 / Weapon.GetWeaponInfo.MiningFactor), Target.Position, Target.Id * Seed);
  end
  else if (Target is TUselessItem) and (TEquipment(Target).ConfigBlockName = 'ExampleAsteroid') then
    Star.DropMinerals(SeededRandomIntRange(20, 30, Target.Id * Star.GenerationSeed), Target.Position, Target.Id * Star.GenerationSeed);
  if Target.DestroyFlag < 0 then Inc(Target.DestroyFlag)
  else
  begin
    Star.ClearItemReferences(Target);
    if RecordFilm then
    begin
      Star.PendingFilmObjectRemovals.Add(Target.FilmObject);
      ReleaseSpaceObject(Target.GraphObject);
    end;
    Star.Items.Delete(Star.Items.IndexOf(Target));
    Target.Free;
  end;
end;
{ @end $6D1B2C }

{ @routine $6D2138 TShip_FireWeaponAtAsteroid }
procedure TShip.FireWeaponAtAsteroid(Weapon: TWeapon; Target: TObject; RecordFilm: Boolean);
var
  Star: TStar;
  StepIndex: Integer;
  Effect: TObjectSE;
  Film: TEFilmObj;
  Asteroid: TAsteroid;
  Minerals: Integer;
begin
  if Target is TAsteroid then
  begin
    Asteroid := TAsteroid(Target);
    Star := CurrentStar;
    StepIndex := Star.CurrentStepIndex;
    ScriptItemsAct(event_weapon_shot, Asteroid, Weapon, 0);
    if RecordFilm then
    begin
      Effect := TWeaponSE.Create(Weapon.GetWeaponInfo.PrimarySE, Classes.Point(0, 0), Weapon.GetShotPalette, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(StepIndex, Film, FilmObject, nil);
      PrimaryFilm.SetObjectPosition(StepIndex, Film, Asteroid.Position);
      PrimaryFilm.SetDestructionEffect(StepIndex, Film, 2);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
      Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetObjectPosition(StepIndex, Film, Asteroid.Position);
      PrimaryFilm.SetWeaponHit(StepIndex, Film, 0, 0, False, True);
      PrimaryFilm.AttachObject(StepIndex, Film);
    end;
    Star.ClearTargetReferences(Asteroid);
    Minerals := Star.DropMinerals(Trunc(Asteroid.MineralCount / Weapon.GetWeaponInfo.MiningFactor), Asteroid.Position,
      Asteroid.Id * Star.GenerationSeed);
    if GetPlayer = Self then Star.ProcessPlayerAsteroidKill(Minerals, Asteroid.Position, Asteroid.Id);
    Asteroid.Respawn;
    if Galaxy.StasisModEnabled = 1 then Asteroid.AdvanceOrbitStep(StepIndex, RecordFilm);
  end;
end;
{ @end $6D2138 }

{ @routine $6D2360 TShip_ApplyInterceptorDamage }
function TShip.ApplyInterceptorDamage(out DamageColor: Cardinal): Integer;
const
  InterceptorDamageFlags = [damage_flag_energy];
var
  Damage: Integer;
  Event: TGalaxyEvent;
  SourceShip: TShip;
begin
  SourceShip := InterceptorSourceShip;
  if SourceShip = nil then Damage := 25 else Damage := SourceShip.GetInterceptorDamage;
  if (Self is TKling) and ((Self as TKling).KlingType = dominator_boss) then Damage := Max(1, Damage div 2);
  Result := ApplyDamage(SourceShip, Damage, -1, DamageColor, InterceptorDamageFlags);
  if (GetPlayer = Self) and (GetHull.HullPoints < 1) then
  begin
    ScoreScreen.RecordPlayerResult(False);
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('KilledByInterceptor');
  end;
end;
{ @end $6D2360 }

{ @routine $6D2464 TShip_ApplyShockStatusDamage }
function TShip.ApplyShockStatusDamage(out DamageColor: Cardinal): Integer;
const
  ShockDamageFlags = [damage_flag_energy, damage_flag_nonlethal];
begin
  Result := ApplyDamage(nil, Round(GetCombatStatusStrength(combat_effect_shock)), -1, DamageColor, ShockDamageFlags);
end;
{ @end $6D2464 }

{ @routine $6D2498 TShip_ApplyAsteroidImpactDamage }
function TShip.ApplyAsteroidImpactDamage(Asteroid: TAsteroid; out DamageColor: Cardinal): Integer;
var
  Damage: Integer;
  Factor: Single;
  Event: TGalaxyEvent;
begin
  if (ScriptShip <> nil) and not HasScriptStateText then Damage := 0
  else
  begin
    if (GetPlayer = Self) and ((Galaxy.GodModEnabled = 1) or (Galaxy.SpecialSimulationMode <> 0)) then Damage := 0
    else
    begin
      Factor := Max(0, 1 - GetTotalStatBonus(bonus_asteroid_resistance) * 0.01);
      if IsEquipmentUsable(GetDefGenerator) then
        Damage := Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1,
          GetHull.Weight * AsteroidMinDamageFactorWithDefGenerator,
          GetHull.Weight * AsteroidMaxDamageFactorWithDefGenerator) * Factor)
      else
        Damage := Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1,
          GetHull.Weight * AsteroidMinDamageFactor,
          GetHull.Weight * AsteroidMaxDamageFactor) * Factor);
      Damage := ScriptItemsAct(event_take_damage, Asteroid, nil, Damage);
      if (GetHull.HullPoints - Damage <= 0) and (BlazerShip <> Self) and (KellerShip <> Self) and (TerronShip <> Self) then
      begin
        ScriptItemsAct(event_death, nil, Asteroid, 0);
        GetHull.HullPoints := 0;
        if (GetPlayer = PartnerShip) or ((Self is TTranclucator) and ((Self as TTranclucator).OwnerShip = GetPlayer)) then
          NotifyCompanionDeath;
        GetPlayer.ProcessShipDestructionQuests(Self);
      end
      else
      begin
        Dec(GetHull.HullPoints, Damage);
        if GetHull.HullPoints < 1 then GetHull.HullPoints := 1;
      end;
    end;
  end;
  if GetPlayer = Self then DamageColor := OwnerToFilmColor(RaceToOwner(PilotRace))
  else if HasNamedScriptFaction then DamageColor := CustomFactionToFilmColor(TScriptShip(ScriptShip).StateText)
  else DamageColor := OwnerToFilmColor(OwnerId);
  if Damage <= 0 then DamageColor := 0;
  Result := Damage;
  if (GetPlayer = Self) and (GetHull.HullPoints < 1) then
  begin
    ScoreScreen.RecordPlayerResult(False);
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('KilledByAsteroid');
  end;
  if IsHullDestroyed then CurrentStar.ClearShipReferences(Self);
end;
{ @end $6D2498 }

{ @routine $6D27F4 TShip_ApplyExplosionDamage }
function TShip.ApplyExplosionDamage(SourceShip: TShip; ExplodingObject: TObject; ExtraDamage: Integer; Missile: TObject): Integer;
var
  Damage: Integer;
  Item: TItem;
  Ship: TShip;
  DistanceSquared: Single;
  Event: TGalaxyEvent;
begin
  Damage := ExtraDamage;
  Item := nil;
  Result := 0;
  if ExplodingObject is TItem then
  begin
    Item := TItem(ExplodingObject);
    DistanceSquared := PointDistanceSquared(Position, Item.Position);
    if ItemExplosionRadiusSquared < DistanceSquared then Exit;
    if Item.ItemType = artefact_bomb then
      Inc(Damage, Round(RemapClamped(DistanceSquared, 0, ItemExplosionRadiusSquared, BombMaximumDamage, BombMinimumDamage)))
    else if Item is TCistern then Inc(Damage, (Item as TCistern).Fuel);
    if Item.DestroyFlag = 2 then Inc(Damage, ItemExplosionBonusDamage)
    else if Item.DestroyFlag > 2 then Inc(Damage, Item.DestroyFlag);
    if Damage = 0 then Exit;
    if Missile <> nil then Damage := ScriptItemsAct(event_take_damage, Item, Missile, Damage)
    else Damage := ScriptItemsAct(event_take_damage, Item, SourceShip, Damage);
  end
  else if ExplodingObject is TShip then
  begin
    Ship := TShip(ExplodingObject);
    if PointDistanceSquared(Position, Ship.Position) > 22500 then Exit;
    Damage := Ship.GetHull.Weight div 3;
    Damage := Ship.ScriptItemsAct(event_deal_kamikaze_damage, Self, nil, Damage);
    Damage := ScriptItemsAct(event_take_damage, Ship, nil, Damage);
  end;
  if Damage > 0 then
  begin
    Result := Damage;
    if (SourceShip <> nil) and (Self <> SourceShip) and (Item <> nil) then
    begin
      if (Missile = nil) or (TMissile(Missile).Target = Item) then
      begin
        if (GetPlayer = Self) and (SourceShip.ScriptShip <> nil) then TScriptShip(SourceShip.ScriptShip).HitPlayer := True;
        if (GetPlayer = SourceShip) and (ScriptShip <> nil) then TScriptShip(ScriptShip).Hit := True;
      end;
      if Item.ItemType = artefact_bomb then ReactToAttack(SourceShip)
      else if SourceShip is TRanger then
        ChangeRelationToRanger(SourceShip, Round(RemapClamped(Damage, 1, GetHull.HullPoints, -1, -80)));
    end;
    if (GetHull.HullPoints <= Damage) and (Self is TKling) and ((Self as TKling).KlingType = dominator_boss) and
      ((KellerShip = Self) or ((GetPlayer <> nil) and (GetPlayer.CurrentStar <> CurrentStar))) then
      GetHull.HullPoints := Damage + 1;
    if (GetHull.HullPoints <= Damage) and (GetPlayer <> nil) then
    begin
      ScriptItemsAct(event_death, SourceShip, ExplodingObject, 0);
      GetPlayer.ProcessShipDestructionQuests(Self);
      if SourceShip <> nil then
      begin
        if SourceShip is TNormalShip then TNormalShip(SourceShip).ProcessShipKill(Self);
        if SourceShip is TRanger then TRanger(SourceShip).ApplyAttackReputationChanges(Self, 1);
      end;
      if (GetPlayer = PartnerShip) or ((Self is TTranclucator) and ((Self as TTranclucator).OwnerShip = GetPlayer)) then
        NotifyCompanionDeath;
      if GetPlayer = Self then
      begin
        ScoreScreen.RecordPlayerResult(False);
        Event := AddGalaxyEvent('PlayerDeath');
        Event.AddTextData('KilledByExplosion');
      end;
    end;
    if (TypeId = ship_dominator) and (SourceShip <> nil) then (Self as TKling).DetectAttackingPlayer(SourceShip);
    GetHull.HullPoints := Max(GetHull.HullPoints - Damage, 0);
    RefreshDerivedStats(True);
    if IsHullDestroyed then CurrentStar.ClearShipReferences(Self);
  end;
end;
{ @end $6D27F4 }

{ @routine $6D2C58 TShip_ApplyStarHeatDamage }
function TShip.ApplyStarHeatDamage: Integer;
var
  Damage, DistanceSquared: Single;
  Event: TGalaxyEvent;
  FuelAdded, I: Integer;
begin
  Result := 0;
  if CurrentStar = nil then Exit;
  DistanceSquared := Sqr(Position.X) + Sqr(Position.Y);
  if Sqr(CurrentStar.DamageRadius) > DistanceSquared then
  begin
    if TypeId = ship_dominator then
      Damage := Max((1 - Sqrt(DistanceSquared) / CurrentStar.DamageRadius) * 30 * Galaxy.GetStarDamageDifficultyScale, 1)
    else
      Damage := Max((1 - Sqrt(DistanceSquared) / CurrentStar.DamageRadius) * 100 * Galaxy.GetStarDamageDifficultyScale, 1);
    for I := 1 to CountActiveArtefacts(artefact_power) do
      Damage := (1 - StarHeatArtefactReduction - ShortInt(CanBoostArtefact(artefact_power, GetHull, False)) * StarHeatArtefactBoostReduction) * Damage;
    Damage := ScriptItemsAct(event_take_damage, CurrentStar, nil, Round(Damage));
    Result := Round(Damage);
    GetHull.HullPoints := Max(GetHull.HullPoints - Round(Damage), 0);
    if (GetHull.HullPoints <= 0) and (Self is TKling) and ((Self as TKling).KlingType = dominator_boss) then
      GetHull.HullPoints := 1;
    if (GetHull.HullPoints <= 0) and (GetPlayer <> nil) then
    begin
      ScriptItemsAct(event_death, nil, CurrentStar, 0);
      GetPlayer.ProcessShipDestructionQuests(Self);
      if GetRelationLevelToShip(GetPlayer) <= relation_level_hostile then
        if (GetPlayer = OrderTarget) or ((GetPlayer = EnemyShip) and (Order in [order_none, order_land, order_jump])) or
          GetPlayer.IsAttackingShip(Self) then
        begin
          Inc(GetPlayer.AchievementStats.EnemiesDestroyedByStarHeat);
          TrySetAchievementProgress('FRY', GetPlayer.AchievementStats.EnemiesDestroyedByStarHeat);
        end;
      if (GetPlayer = PartnerShip) or ((Self is TTranclucator) and ((Self as TTranclucator).OwnerShip = GetPlayer)) then
        NotifyCompanionDeath;
      if GetPlayer = Self then
      begin
        ScoreScreen.RecordPlayerResult(False);
        Event := AddGalaxyEvent('PlayerDeath');
        Event.AddTextData('KilledBySunDamage');
      end;
    end;
    if GetFuelTanks <> nil then
    begin
      FuelAdded := Max(0, Min(5, GetFuelTanks.Capacity - GetFuelTanks.Fuel));
      Inc(GetFuelTanks.Fuel, FuelAdded);
      if (FuelAdded > 0) and (GetPlayer = Self) then
      begin
        if GetFuelTanks.Id <> GetPlayer.AchievementStats.StarFuelTankId then
          GetPlayer.AchievementStats.StarFuelCollected := 0;
        GetPlayer.AchievementStats.StarFuelTankId := GetFuelTanks.Id;
        Inc(GetPlayer.AchievementStats.StarFuelCollected, FuelAdded);
        GetPlayer.AchievementStats.CheckStarFuelAchievement;
      end;
    end;
    RefreshDerivedStats(True);
    if IsHullDestroyed then CurrentStar.ClearShipReferences(Self);
  end;
end;
{ @end $6D2C58 }

{ @routine $6D3138 TShip_CountEquippedWeapons }
function TShip.CountEquippedWeapons: TWeaponCount;
var
  I, Count: Integer;
  Item: TEquipment;
begin
  Count := 0;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag <> 0) and (Item.ItemType in WeaponItemTypes) then Inc(Count);
  end;
  Result := Count;
end;
{ @end $6D3138 }

{ @routine $6D317C TShip_CountMissileWeapons }
function TShip.CountMissileWeapons: TWeaponCount;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do
    if (Weapons[I].GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) then Inc(Result);
end;
{ @end $6D317C }

{ @routine $6D31B8 TShip_CountDirectFireWeapons }
function TShip.CountDirectFireWeapons: Byte;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do
    if not (Weapons[I].GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) then Inc(Result);
end;
{ @end $6D31B8 }

{ @routine $6D31F4 TShip_ClearUnequippedWeaponTargets }
procedure TShip.ClearUnequippedWeaponTargets;
var
  I: Integer;
  Item: TEquipment;
begin
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag = 0) and (Item is TWeapon) and ((Item as TWeapon).Target <> nil) then
      (Item as TWeapon).Target := nil;
  end;
end;
{ @end $6D31F4 }

{ @routine $6D3260 TShip_CountWeaponsByDamageFlags }
function TShip.CountWeaponsByDamageFlags(Flags: TDamageFlagSet): TWeaponCount;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do if (Weapons[I].GetDamageFlags * Flags) <> [] then Inc(Result);
end;
{ @end $6D3260 }

{ @routine $6D32A8 TShip_GetWeaponDamageSummary }
function TShip.GetWeaponDamageSummary: WideString;
var
  DifficultyFactor: Extended;
  I, MinimumDamage, MaximumDamage: Integer;
  Weapon: TWeapon;
begin
  Result := '0';
  MinimumDamage := 0;
  MaximumDamage := 0;
  if WeaponCount = 0 then Exit;
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    if IsEquipmentUsable(Weapon) then
    begin
      if Weapon.GetWeaponInfo.ShotType in [shot_missile..shot_rocket] then
      begin
        Inc(MinimumDamage, GetWeaponMinDamage(Weapon) * Weapon.GetAttackCount * Weapon.GetShotCount);
        Inc(MaximumDamage, GetWeaponMaxDamage(Weapon) * Weapon.GetAttackCount * Weapon.GetShotCount);
      end
      else
      begin
        Inc(MinimumDamage, GetWeaponMinDamage(Weapon) * Weapon.GetAttackCount);
        Inc(MaximumDamage, GetWeaponMaxDamage(Weapon) * Weapon.GetAttackCount);
      end;
    end;
  end;
  MinimumDamage := MinimumDamage * GetAttackMultiplier;
  MaximumDamage := MaximumDamage * GetAttackMultiplier;
  if (TypeId = ship_dominator) and ((Self as TKling).KlingType = dominator_boss) then
  begin
    DifficultyFactor := Galaxy.InterpolateDifficulty(-1, 0.7, 1, 1.2, 1.5) * 2;
    MinimumDamage := Round(MinimumDamage * DifficultyFactor);
    MaximumDamage := Round(MaximumDamage * DifficultyFactor);
  end;
  Result := WideString(IntToStr(MinimumDamage)) + WrapTextInColor('-', GrayColorTag) + WideString(IntToStr(MaximumDamage));
  Result := WideString('(' + IntToStr(GetEffectiveSkillLevel(skill_accuracy)) + ') ') + Result;
end;
{ @end $6D32A8 }

{ @routine $6D358C TShip_GetManeuverabilitySummary }
function TShip.GetManeuverabilitySummary: WideString;
begin
  Result := '(' + IntToStr(GetEffectiveSkillLevel(skill_maneuverability)) + ') ';
end;
{ @end $6D358C }

{ @routine $6D3624 TShip_GetRepairPointsSummary }
function TShip.GetRepairPointsSummary: WideString;
begin
  Result := '0';
  if GetRepairRobot <> nil then Result := IntToStr(CalculateRepairPoints(GetRepairRobot));
end;
{ @end $6D3624 }

{ @routine $6D36A0 TShip_HasScannerArtefact }
function TShip.HasScannerArtefact(UnusedTarget: TShip): Boolean;
begin
  Result := CountActiveArtefacts(artefact_scanner) > 0;
end;
{ @end $6D36A0 }

{ @routine $6D36B4 TShip_GetWeaponActionRange }
function TShip.GetWeaponActionRange(Weapon: TWeapon): Integer;
begin
  Result := GetWeaponRange(Weapon);
end;
{ @end $6D36B4 }

{ @routine $6D36BC TShip_GetWeaponSlotRange }
function TShip.GetWeaponSlotRange(SlotIndex: Integer): Integer;
begin
  Result := GetWeaponRange(Weapons[SlotIndex]);
end;
{ @end $6D36BC }

{ @routine $6D36CC TShip_GetWeaponMinDamage }
function TShip.GetWeaponMinDamage(Weapon: TWeapon): Integer;
begin
  if (Cardinal(Weapon.GetDamageFlags) and damage_no_spread_mask) <> 0 then Result := GetWeaponMaxDamage(Weapon)
  else Result := Weapon.MinDamage;
end;
{ @end $6D36CC }

{ @routine $6D36F4 TShip_GetWeaponMaxDamage }
function TShip.GetWeaponMaxDamage(Weapon: TWeapon): Integer;
var
  BonusKind: TEquipmentBonusKind;
  Bonus, I: Integer;
  Extra: PExtraSpecial;
begin
  Result := Max(Weapon.MaxDamage, Weapon.MinDamage);
  if not (Weapon.ItemType in WeaponItemTypes) then Exit;
  BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(Weapon.GetWeaponInfo.DamageFlags)].BonusKind;
  Bonus := GetTotalStatBonus(BonusKind);
  if (Weapon.GetWeaponInfo.ShotType in [shot_missile..shot_rocket]) and not Galaxy.AreOldMissileBonusesEnabled then
  begin
    if Weapon.MicroModuleIndex > 0 then
    begin
      Dec(Result, MicroModuleTemplates[Weapon.MicroModuleIndex - 1].StatBonuses[BonusKind]);
      Inc(Bonus, MicroModuleTemplates[Weapon.MicroModuleIndex - 1].StatBonuses[BonusKind]);
    end;
    Bonus := Ceil(Bonus / Weapon.GetShotCount);
  end;
  if Weapon.ExtraSpecials <> nil then
    for I := 0 to Weapon.ExtraSpecials.Count - 1 do
    begin
      Extra := Weapon.ExtraSpecials[I];
      Inc(Bonus, MicroModuleTemplates[Extra.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Extra.Count);
    end;
  Result := Max(Weapon.MinDamage, Result + Bonus);
end;
{ @end $6D36F4 }

{ @routine $6D3830 TShip_GetMaxWeaponRange }
function TShip.GetMaxWeaponRange: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do
    if IsEquipmentUsable(Weapons[I]) and (GetWeaponSlotRange(I) > Result) then
      Result := GetWeaponSlotRange(I);
end;
{ @end $6D3830 }

{ @routine $6D3880 TShip_ClearWeaponTargets }
procedure TShip.ClearWeaponTargets(Target: TObject);
var
  I: Integer;
begin
  if Target = nil then
  begin
    for I := 1 to WeaponCount do Weapons[I].Target := nil;
  end
  else
    for I := 1 to WeaponCount do if Weapons[I].Target = Target then Weapons[I].Target := nil;
end;
{ @end $6D3880 }

{ @routine $6D38D4 TShip_IsAttackingShip }
function TShip.IsAttackingShip(Target: TShip): Boolean;
var I: Integer;
begin
  for I := 1 to WeaponCount do
    if Weapons[I].Target = Target then
    begin
      Result := True;
      Exit;
    end;
  if Target.InterceptorSourceShip = Self then
  begin
    Result := True;
    Exit;
  end;
  if Target.GetCombatStatusSourceId(combat_effect_shock) = Id then
  begin
    Result := True;
    Exit;
  end;
  if Target.GetCombatStatusSourceId(combat_effect_acid) = Id then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;
{ @end $6D38D4 }

{ @routine $6D3938 TShip_ChanceToWin }
function TShip.ChanceToWin(Target: TShip): Double;
var Index: Integer; Damage, OwnDamage, TargetDamage, DefenseFactor, Armor: Double;
begin
  try
    if GetHull.HullPoints < 1 then RaiseWideMessage('ChanceToWin error, hitpoints=0!');
    if Target.GetHull.HullPoints < 1 then begin Result := 100; Exit; end;
    OwnDamage := 0;
    DefenseFactor := Target.GetDefenseDamageFactor;
    Armor := Target.GetArmor;
    for Index := 1 to WeaponCount do
      if IsEquipmentUsable(Weapons[Index]) then
      begin
        Damage := GetWeaponMaxDamage(Weapons[Index]) * DefenseFactor - Armor;
        if Damage > 0 then OwnDamage := OwnDamage + Damage;
      end;
    if OwnDamage = 0 then begin Result := 0; Exit; end;
    TargetDamage := 0;
    DefenseFactor := GetDefenseDamageFactor;
    Armor := GetArmor;
    for Index := 1 to Target.WeaponCount do
      if Target.IsEquipmentUsable(Target.Weapons[Index]) then
      begin
        Damage := Target.GetWeaponMaxDamage(Target.Weapons[Index]) * DefenseFactor - Armor;
        if Damage > 0 then TargetDamage := TargetDamage + Damage;
      end;
    if TargetDamage = 0 then begin Result := 100; Exit; end;
    Result := (GetHull.HullPoints * OwnDamage / Max(0.01, GetHull.GetFragilityFactor([]))) /
      (Target.GetHull.HullPoints * TargetDamage / Max(0.01, Target.GetHull.GetFragilityFactor([])));
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Error in procedure TShip.ChanceToWin ' + GetFullName(' '));
      raise Exception.Create('vs ' + Target.GetFullName(' '));
    end;
  end;
end;
{ @end $6D3938 }

{ @routine $6D3E4C TShip_GetWinChancePercent }
function TShip.GetWinChancePercent(Target: TShip): TPercent;
var Value: Double;
begin
  Value := ChanceToWin(Target);
  if Value >= 1 then Result := Round(RemapClamped(Value, 1, 4, 50, 100))
  else Result := Round(RemapClamped(Value, 0, 1, 0, 50));
end;
{ @end $6D3E4C }

{ @routine $6D3EC8 TShip_SetJointAttackTarget }
procedure TShip.SetJointAttackTarget(Ally, Target: TShip);
var I: Integer; Weapon: TWeapon;
begin
  EnemyShip := Target;
  for I := 1 to WeaponCount do begin
    Weapon := Weapons[I];
    if (Weapon.GetWeaponInfo^.ShotType in [shot_torpedo..shot_rocket]) and (Weapon.Ammo = 0) then Continue;
    if (Sqr(GetWeaponSlotRange(I)) >= PointDistanceSquared(Position, Target.Position)) and IsEquipmentUsable(Weapon) then Weapon.Target := Target;
  end;
  if HasPositiveSpeed then
    if GetPlayer = Self then begin OrderNone(False); PendingPlayerFollowTarget := Target; end
    else OrderFollowShip(EnemyShip, follow_min_weapon_range, True);
  Ally.EnemyShip := Target;
  for I := 1 to Ally.WeaponCount do begin
    Weapon := Ally.Weapons[I];
    if (Weapon.GetWeaponInfo^.ShotType in [shot_torpedo..shot_rocket]) and (Weapon.Ammo = 0) then Continue;
    if (Sqr(Ally.GetWeaponSlotRange(I)) >= PointDistanceSquared(Ally.Position, Target.Position)) and Ally.IsEquipmentUsable(Weapon) then Weapon.Target := Target;
  end;
  if Ally.HasPositiveSpeed then
    if GetPlayer = Ally then begin GetPlayer.OrderNone(False); PendingPlayerFollowTarget := Target; end
    else Ally.OrderFollowShip(Ally.EnemyShip, follow_min_weapon_range, True);
end;
{ @end $6D3EC8 }

{ @routine $6D4060 TShip_IsEnemyPursuingSelf }
function TShip.IsEnemyPursuingSelf: Boolean;
begin
  if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or not EnemyShip.InNormalSpace then Result := False
  else Result := EnemyShip.OrderTarget = Self;
end;
{ @end $6D4060 }

{ @routine $6D4098 TShip_CanSafelyDetonateItem }
function TShip.CanSafelyDetonateItem(Item: TItem): Boolean;
var I: Integer; Ship: TShip; Distance: Single;
begin
  Result := True;
  if (CurrentStar <> nil) and ((Item.ItemType = artefact_bomb) or (Item is TCistern)) then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if not Ship.IsOutsideStarSpace then begin
        Distance := PointDistanceSquared(Ship.Position, Item.Position);
        if (ItemExplosionRadiusSquared >= Distance) and (GetRelationLevelToShip(Ship) > relation_level_hostile) then begin Result := False; Exit; end;
      end;
    end;
end;
{ @end $6D4098 }

{ @routine $6D4144 TShip_SetStoredRangerRelationLevel }
procedure TShip.SetStoredRangerRelationLevel(Ranger: TShip; Level: TRelationLevel);
begin
  if RangerRelations.Count < 1 then Exit;
  case Level of
    relation_level_hostile: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(5);
    relation_level_bad: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(20);
    relation_level_normal: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(45);
    relation_level_good: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(70);
    relation_level_excellent: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(90);
  else RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(5);
  end;
end;
{ @end $6D4144 }

{ @routine $6D42A4 TShip_GetRelationLevelToShip }
function TShip.GetRelationLevelToShip(Ship: TShip): TRelationLevel;
begin
  case RelationToShip(Ship) of
    0..9: Result := relation_level_hostile;
    10..29: Result := relation_level_bad;
    30..59: Result := relation_level_normal;
    60..79: Result := relation_level_good;
    80..100: Result := relation_level_excellent;
  else Result := relation_level_normal;
  end;
end;
{ @end $6D42A4 }

{ @routine $6D42E4 TShip_GetRelationLevelTextToShip }
function TShip.GetRelationLevelTextToShip(Ship: TShip): WideString;
var Level: TRelationLevel;
begin
  Level := GetRelationLevelToShip(Ship);
  Result := RelationInfo[Level].DisplayName;
  if (Level <> relation_level_hostile) and (Self is TRuins) and (Ship is TRanger) and
     (RangerRelations <> nil) and (RangerRelations.Count > 0) then
  begin
    Level := RelationValueToLevel(Byte(RangerRelations[Galaxy.Rangers.IndexOf(Ship)]));
    if Level <> relation_level_hostile then Result := RelationInfo[Level].DisplayName;
  end;
end;
{ @end $6D42E4 }

{ @routine $6D4390 TShip_TryExtortShip }
function TShip.TryExtortShip(Target: TShip): Boolean;
var Amount: Integer; Response: WideString;
begin
  Result := False;
  if (Target.TypeId in [ship_ranger..ship_pirate]) and (Target <> TruceShip) and Target.InNormalSpace and
    ((CurrentStanding <> standing_pirate_military) or (Target.CurrentStanding <> standing_coalition_military)) and ((Target.CurrentStanding <> standing_pirate_military) or (CurrentStanding <> standing_coalition_military)) and CanContactShip(Target) then begin
    if TypeId = ship_ranger then (Self as TRanger).AddPirateCareerActivity(2);
    if (GetPlayer = Target) and not PlayerAutomaticControl then begin
      if TurnsSinceLastRequestToPlayer < 7 then Exit;
      TurnsSinceLastRequestToPlayer := 0;
      Inc(PlayerDialogueRequestCount);
      if PlayerDialogueRequestCount > 1 then Exit;
    end;
    if (GetCargoHook <> nil) and (CargoFreeSpace > 20) and (NextRandomUnitFloat(RandomState) > 0.4) and Target.HasCargoGoods then begin
      if Target.BuildCargoExtortionResponse(Self, Response) then Result := True;
      if (GetPlayer.CurrentStar = CurrentStar) and (Result or (NextRandomUnitFloat(RandomState) > 0.8)) and
        ((GetPlayer <> Target) or PlayerAutomaticControl) then NotifyCargoDemand(Target, Response);
    end else begin
      Amount := Round(Wealth * (1 / 30));
      if Target.BuildMoneyExtortionResponse(Self, Response, Amount) then Result := True;
      if (GetPlayer.CurrentStar = CurrentStar) and (Result or (NextRandomUnitFloat(RandomState) > 0.8)) and
        ((GetPlayer <> Target) or PlayerAutomaticControl) then NotifyMoneyDemand(Target, Response, Amount);
    end;
  end;
end;
{ @end $6D4390 }

{ @routine $6D45F4 TShip_TruceWithShip }
procedure TShip.TruceWithShip(Ship: TShip);
var I: Integer; Weapon: TWeapon; Missile: TMissile; Other: TShip;
begin
  if ((GetPlayer = Ship) and (PendingPlayerFollowTarget = Self)) or ((GetPlayer = Self) and (PendingPlayerFollowTarget = Ship)) then PendingPlayerFollowTarget := nil;
  if EnemyShip = Ship then EnemyShip := nil;
  if Ship.EnemyShip = Self then Ship.EnemyShip := nil;
  TruceShip := Ship;
  if GetPlayer = Ship then GetPlayer.TruceShip := Self;
  for I := 1 to WeaponCount do begin Weapon := Weapons[I]; if Weapon.Target = Ship then Weapon.Target := nil; end;
  for I := 1 to Ship.WeaponCount do begin Weapon := Ship.Weapons[I]; if Weapon.Target = Self then Weapon.Target := nil; end;
  if GetHull.InterceptorTarget = Ship then GetHull.InterceptorTarget := nil;
  if Ship.InterceptorSourceShip = Self then Ship.ClearIncomingInterceptors;
  if Ship.GetHull.InterceptorTarget = Self then Ship.GetHull.InterceptorTarget := nil;
  if InterceptorSourceShip = Ship then ClearIncomingInterceptors;
  if (TypeId = ship_ranger) and (Ship.RelationToRanger(Self) < RelationBadMin) then Ship.ChangeRelationToRanger(Self, 10);
  if Ship.TypeId = ship_ranger then ChangeRelationToRanger(Ship, 30);
  if (Order = order_follow_ship) and ((OrderTarget as TShip) = Ship) then begin
    OrderNone(False);
    if GetPlayer <> Self then NextDay;
    RefreshDerivedStats(True);
  end;
  if (Ship.Order = order_follow_ship) and ((Ship.OrderTarget as TShip) = Self) then begin
    Ship.OrderNone(False);
    if GetPlayer <> Ship then Ship.NextDay;
    Ship.RefreshDerivedStats(True);
  end;
  ClearCombatStatusSourceReferences(Ship);
  Ship.ClearCombatStatusSourceReferences(Self);
  if Self is TPirate then (Self as TPirate).RaidPressure := 0;
  if Ship is TPirate then (Ship as TPirate).RaidPressure := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Other := CurrentStar.Ships[I];
    if Other.PartnerShip = Self then Other.TruceWithShip(Ship);
    if Other.PartnerShip = Ship then Other.TruceWithShip(Self);
    if not (Other is TTranclucator) then Continue;
    if (Other as TTranclucator).OwnerShip = Self then Other.TruceWithShip(Ship);
    if (Other as TTranclucator).OwnerShip = Ship then Other.TruceWithShip(Self);
  end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do begin
    Missile := CurrentStar.Missiles[I];
    if (Missile.OwnerShip = Self) and (Missile.Target = Ship) then Missile.Target := nil;
    if (Missile.OwnerShip = Ship) and (Missile.Target = Self) then Missile.Target := nil;
  end;
end;
{ @end $6D45F4 }

{ @routine $6D490C TShip_RequestAlliesAttackShip }
procedure TShip.RequestAlliesAttackShip(Target: TShip);
var I, Requests: Integer; Other: TShip; Response: WideString;
begin
  if not Target.InNormalSpace then Exit;
  if not (Max(GetRadarRange * GetRadarRange, 250000) >= PointDistanceSquared(Position, Target.Position)) then Exit;
  if TypeId = ship_ranger then (Self as TRanger).AddWarriorCareerActivity(1);
  Requests := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Other := CurrentStar.Ships[I];
    if Other = Self then Continue;
    if Other = Target then Continue;
    if not Other.InNormalSpace then Continue;
    if Other.TypeId in NonNegotiatingShipTypes then Continue;
    if Other.OrderTarget = Target then Continue;
    if (Other.EnemyShip <> nil) and (Other.EnemyShip.CurrentStar = CurrentStar) then Continue;
    if Other.GetRelationLevelToShip(Self) < relation_level_good then Continue;
    if (GetPlayer = Other) and (GetRelationLevelToShip(Other) < relation_level_good) then Continue;
    if (Other.GetRelationLevelToShip(Target) > relation_level_normal) and (not (Other is TPirate) or not (Self is TPirate)) then Continue;
    if Other.TargetingRestriction in [1, 2] then Continue;
    if Target.TargetingRestriction in [1, 2] then Continue;
    if not CanContactShip(Other) then Continue;
    if Other.PartnerShip = Target then Continue;
    if Target.PartnerShip = Other then Continue;
    if not (NextRandomUnitFloat(RandomState) <= 0.9) then Continue;
    if (Other is TWarrior) and ((Other as TWarrior).WarriorType = warrior_flagship) then Continue;
    if not ((GetPlayer <> Other) or (CurrentStar.ControlFaction <> faction_coalition) or (CurrentStar.Status.CustomFaction <> '') or
        (TypeId <> ship_warrior) or (GetPlayer.OwnerId <> owner_pirate) or not (Target is TNormalShip) or
        (not (Target.TypeId in [ship_transport, ship_warrior]) and ((Target.TypeId <> ship_ranger) or (Target.GetDominantCareer = career_pirate)))) then Continue;
    if not ((GetPlayer <> Other) or (CurrentStar.ControlFaction <> faction_pirates) or (CurrentStar.Status.CustomFaction <> '') or
        (TypeId <> ship_pirate) or (OwnerId <> owner_pirate) or (GetPlayer.OwnerId = owner_pirate) or not (Target is TNormalShip) or (Target.OwnerId <> owner_pirate)) then Continue;
    if (GetPlayer = Other) and not PlayerAutomaticControl then begin
      if TurnsSinceLastRequestToPlayer < 7 then Continue;
      TurnsSinceLastRequestToPlayer := 0;
      Inc(PlayerDialogueRequestCount);
      if PlayerDialogueRequestCount > 1 then Continue;
    end;
    if (Other.BuildAttackRequestResponse(Self, Response, Target) or (NextRandomUnitFloat(RandomState) > 0.8)) and
      (GetPlayer.CurrentStar = CurrentStar) and ((GetPlayer <> Other) or PlayerAutomaticControl) then begin
      NotifyAttackRequest(Other, Response, Target);
      Break;
    end;
    Inc(Requests);
    if Requests = 2 then Break;
  end;
end;
{ @end $6D490C }

{ @routine $6D4CE4 TShip_IsInPrison }
function TShip.IsInPrison: Boolean;
begin
  if GetPlayer = Self then
  begin
    Result := GetPlayer.InPrison;
    Exit;
  end;
  case TypeId of
    ship_ranger: if (Self as TRanger).PrisonTermRemaining > 0 then
       begin Result := True; Exit; end;
    ship_pirate: if (Self as TPirate).PrisonTermRemaining > 0 then
       begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $6D4CE4 }

{ @routine $6D4D44 TShip_GetPrisonTermRemaining }
function TShip.GetPrisonTermRemaining: Integer;
begin
  Result := 0;
  case TypeId of
    ship_ranger: Result := (Self as TRanger).PrisonTermRemaining;
    ship_pirate: Result := (Self as TPirate).PrisonTermRemaining;
  end;
end;
{ @end $6D4D44 }

{ @routine $6D4D84 TShip_ClearPrisonTerm }
procedure TShip.ClearPrisonTerm;
begin
  case TypeId of
    ship_ranger: (Self as TRanger).PrisonTermRemaining := 0;
    ship_pirate: (Self as TPirate).PrisonTermRemaining := 0;
  end;
end;
{ @end $6D4D84 }

{ @routine $6D4DC4 TShip_GetPrisonReleaseCost }
function TShip.GetPrisonReleaseCost: Integer;
var Divisor, Term: Integer;
begin
  Result := 0;
  Term := GetPrisonTermRemaining;
  if Term > 0 then begin
    Divisor := 141 - Term;
    if Divisor > 0 then Result := Round(Wealth / Divisor)
    else Result := Wealth;
    if Result < 100 then Result := 100;
  end;
end;
{ @end $6D4DC4 }

{ @routine $6D4E10 TShip_GetLocationGoodsEntry }
function TShip.GetLocationGoodsEntry(Good: Byte): PGoodsTradePriceEntry;
begin
  if IsOnPlanet then Result := @CurrentPlanet.Goods[Good]
  else if (DockedTo <> nil) and (DockedTo is TRuins) then Result := @TRuins(DockedTo).ShopGoods[Good]
  else if Self is TRuins then Result := @TRuins(Self).ShopGoods[Good]
  else if TalkShip <> nil then Result := PGoodsTradePriceEntry(@GoodsShopScreen.TradeRows[Good])
  else
  begin
    AppendLogLineThreadSafe(AnsiString('Error in ShopGoods, ship = ' + GetFullName(' ')));
    if DockedTo = nil then AppendLogLineThreadSafe('FCurShip is nil')
    else AppendLogLineThreadSafe(AnsiString('FCurShip is ' + DockedTo.GetFullName(' ') + ' (' + DockedTo.ClassName + ')'));
    raise Exception.Create('Error in TShip.ShopGoods');
  end;
end;
{ @end $6D4E10 }

{ @routine $6D5094 TShip_ShopGoodsPurchasePrice }
function TShip.ShopGoodsPurchasePrice(Good: Byte; Location: TObject): Integer;
var Entry: PGoodsTradePriceEntry;
begin
  Entry := nil;
  if Location = nil then Entry := GetLocationGoodsEntry(Good)
  else if Location is TPlanet then Entry := @TPlanet(Location).Goods[Good]
  else if Location is TRuins then Entry := @TRuins(Location).ShopGoods[Good];
  if Entry = nil then
  begin
    AppendLogLineThreadSafe(AnsiString('Error in ShopGoodsPurchasePrice, ship = ' + GetFullName(' ')));
    if Location = nil then AppendLogLineThreadSafe('obj is nil')
    else AppendLogLineThreadSafe('obj is ' + Location.ClassName);
    raise Exception.Create('Error in TShip.ShopGoodsPurchasePrice');
  end;
  Result := Max(1, Entry.PurchasePrice);
end;
{ @end $6D5094 }

{ @routine $6D52AC TShip_ShopGoodsSellPrice }
function TShip.ShopGoodsSellPrice(Good: Byte; Location: TObject): Integer;
var Entry: PGoodsTradePriceEntry;
begin
  Entry := nil;
  if Location = nil then Entry := GetLocationGoodsEntry(Good)
  else if Location is TPlanet then Entry := @TPlanet(Location).Goods[Good]
  else if Location is TRuins then Entry := @TRuins(Location).ShopGoods[Good];
  if Entry = nil then
  begin
    AppendLogLineThreadSafe(AnsiString('Error in ShopGoodsSellPrice, ship = ' + GetFullName(' ')));
    if Location = nil then AppendLogLineThreadSafe('obj is nil')
    else AppendLogLineThreadSafe('obj is ' + Location.ClassName);
    raise Exception.Create('Error in TShip.ShopGoodsSellPrice');
  end;
  Result := Max(1, Round(TradingSkillSalePercent[GetEffectiveSkillLevel(skill_trading)] *
    (Entry.PurchasePrice - Entry.BaseSalePrice) * 0.01 + Entry.BaseSalePrice));
end;
{ @end $6D52AC }

{ @routine $6D5548 TShip_GetAverageCargoCost }
function TShip.GetAverageCargoCost(Good: TGoodsIndex): Double;
begin
  if CargoGoods[Good].Count > 0 then Result := CargoGoods[Good].TotalCost / CargoGoods[Good].Count
  else Result := 0;
end;
{ @end $6D5548 }

{ @routine $6D557C TShip_ConsumeCargoGoods }
procedure TShip.ConsumeCargoGoods(Good: Byte; Count: Integer);
begin
  if CargoGoods[Good].Count = Count then
  begin
    CargoGoods[Good].Count := 0;
    CargoGoods[Good].TotalCost := 0;
  end
  else
  begin
    Dec(CargoGoods[Good].TotalCost, Round(GetAverageCargoCost(Good) * Count));
    Dec(CargoGoods[Good].Count, Count);
  end;
end;
{ @end $6D557C }

{ @routine $6D55C8 TShip_IsCargoGoodIllegalOnCurrentPlanet }
function TShip.IsCargoGoodIllegalOnCurrentPlanet(Good: Byte): Boolean;
begin
  Result := False;
  if (CurrentPlanet <> nil) and not CurrentPlanet.IsMainPiratePlanet then
    if CurrentPlanet.OwnerId = owner_pirate then Result := False
    else if not GoodsLegalOnPlanet[Good, CurrentPlanet.RaceId, CurrentPlanet.Government] then Result := True
    else if (Good in [Ord(item_food)..Ord(item_medicine)]) and IsHealthEffectActive(disease_new_molizone) then Result := True;
end;
{ @end $6D55C8 }

{ @routine $6D5638 TShip_SellGoodsToLocation }
procedure TShip.SellGoodsToLocation(Good: Byte; Count: Integer);
var
  PurchasedCount, PurchasedCost, Profit, ProfitableCount, UnitCost: Integer;
  Experience, ExperienceFactor: Single;
  Value, LocationCount, ShipCount: Integer;
  Event: TGalaxyEvent;
  Illegal: Boolean;
begin
  if CargoGoods[Good].Count < Count then
    raise Exception.Create('Error in SaleCurrProduct');
  if TradeGoodsSold = nil then TradeGoodsSold := TGoods.Create;
  if TradeGoodsCostBasis = nil then TradeGoodsCostBasis := TGoods.Create;
  TradeGoodsSold.Init(TItemType(Good), Count);
  TradeGoodsCostBasis.Init(TItemType(Good), Min(Count, CargoGoods[Good].PurchasedCount));
  Value := ShopGoodsSellPrice(Good, nil) * Count;
  TradeGoodsSold.Cost := Value;
  if TradeGoodsCostBasis.Quantity > 0 then
    TradeGoodsCostBasis.Cost := Round(CargoGoods[Good].PurchasedTotalCost / CargoGoods[Good].PurchasedCount) * TradeGoodsCostBasis.Quantity;
  Illegal := IsCargoGoodIllegalOnCurrentPlanet(Good);
  LocationCount := GetLocationGoodsEntry(Good).Count;
  ShipCount := CargoGoods[Good].Count;
  Inc(GetLocationGoodsEntry(Good).Count, Count);
  SetMoney(Money + Value);
  if GetPlayer = Self then
  begin
    if CurrentPlanet <> nil then
    begin
      Event := AddGalaxyEvent('PlayerSellsGoodsToPlanet');
      Event.AddData(Good);
      Event.AddData(Count);
      Event.AddData(Value);
      Event.AddData(CurrentPlanet.Id);
    end;
    TryAddAchievementProgress('DEALER', Value);
  end;
  ConsumeCargoGoods(Good, Count);
  Illegal := ScriptItemsAct(event_ship_sells_goods, TradeGoodsSold, TradeGoodsCostBasis, Ord(Illegal)) <> 0;
  if (GetLocationGoodsEntry(Good).Count <> LocationCount + Count) or
     (CargoGoods[Good].Count <> ShipCount - Count) then GR_Main.CCInterface.SetTamperDetected(True);
  LocationCount := GetLocationGoodsEntry(Good).Count;
  ShipCount := CargoGoods[Good].Count;
  if Self is TRanger then
  begin
    if Illegal then
    begin
      TRanger(Self).ApplyIllegalGoodsTradeRelationsPenalty(ShopGoodsSellPrice(Good, nil) * Count);
      if (GetPlayer = Self) and (Count >= 50) then TryAddAchievementProgress('CONTRABAND', 1);
    end;
    if GetPlayer <> Self then TRanger(Self).AddTraderCareerActivity(2);
    if (GetPlayer = Self) and (Count > 0) and (CargoGoods[Good].PurchasedCount > 0) then
    begin
      if CargoGoods[Good].PurchasedCount < Count then PurchasedCount := CargoGoods[Good].PurchasedCount
      else PurchasedCount := Count;
      UnitCost := Round(CargoGoods[Good].PurchasedTotalCost / CargoGoods[Good].PurchasedCount);
      PurchasedCost := Round(CargoGoods[Good].PurchasedTotalCost / CargoGoods[Good].PurchasedCount * PurchasedCount);
      Profit := Round((ShopGoodsSellPrice(Good, nil) - UnitCost) * PurchasedCount);
      if Profit < 0 then Dec(TradeLossBalance, Profit)
      else
      begin
        if (Self is TNormalShip) and (OwnerId = owner_pirate) and Illegal then
        begin
          Inc(ContrabandProfit, Profit);
          if ContrabandProfit >= 3000 then
          begin
            TNormalShip(Self).AddPirateRankPoints(ContrabandProfit div 3000);
            ContrabandProfit := ContrabandProfit mod 3000;
          end;
        end;
        if TradeLossBalance > 0 then
        begin
          if TradeLossBalance > Profit then
          begin
            Dec(TradeLossBalance, Profit);
            Profit := 0;
          end
          else
          begin
            Dec(Profit, TradeLossBalance);
            TradeLossBalance := 0;
          end;
        end;
        ProfitableCount := Floor(Profit / (ShopGoodsSellPrice(Good, nil) - UnitCost));
        ExperienceFactor := 0.0001 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].GoodsEventDurationFactor * Max(0, (Self as TPlayer).CareerStatus[career_trader] - 50);
        Experience := ProfitableCount * ExperienceFactor * GoodsMarketBase[Good].AveragePrice *
          Min(1.0, (ShopGoodsSellPrice(Good, nil) - UnitCost) * GoodsMarketBase[Good].TradeExperienceFactor / ShopGoodsSellPrice(Good, nil));
        Inc(TradeExperience, Floor(Experience));
        if Profit > 0 then (Self as TRanger).AddTraderCareerActivity(2);
      end;
      Dec(CargoGoods[Good].PurchasedTotalCost, PurchasedCost);
      Dec(CargoGoods[Good].PurchasedCount, PurchasedCount);
    end;
  end;
  RefreshDerivedStats(True);
  if (GetLocationGoodsEntry(Good).Count <> LocationCount) or (CargoGoods[Good].Count <> ShipCount) then
    GR_Main.CCInterface.SetTamperDetected(True);
end;
{ @end $6D5638 }

{ @routine $6D5BFC TShip_BuyGoodsFromLocation }
procedure TShip.BuyGoodsFromLocation(Good: Byte; Count: Integer);
var
  LocationCount, ShipCount, Value: Integer;
  Event: TGalaxyEvent;
  Illegal: Boolean;
begin
  if (GetLocationGoodsEntry(Good).Count < Count) or (ShopGoodsPurchasePrice(Good, nil) * Count > Money) then
    ShowMessage('Не верные параметры покупки')
  else
  begin
    if TradeGoodsSold = nil then TradeGoodsSold := TGoods.Create;
    TradeGoodsSold.Init(TItemType(Good), Count);
    Illegal := IsCargoGoodIllegalOnCurrentPlanet(Good);
    LocationCount := GetLocationGoodsEntry(Good).Count;
    ShipCount := CargoGoods[Good].Count;
    Dec(GetLocationGoodsEntry(Good).Count, Count);
    Value := ShopGoodsPurchasePrice(Good, nil) * Count;
    SetMoney(Money - Value);
    Inc(CargoGoods[Good].Count, Count);
    Inc(CargoGoods[Good].TotalCost, Value);
    Illegal := ScriptItemsAct(event_ship_buys_goods, TradeGoodsSold, nil, Ord(Illegal)) <> 0;
    if (GetLocationGoodsEntry(Good).Count <> LocationCount - Count) or
      (CargoGoods[Good].Count <> ShipCount + Count) then GR_Main.CCInterface.SetTamperDetected(True);
    LocationCount := GetLocationGoodsEntry(Good).Count;
    ShipCount := CargoGoods[Good].Count;
    if Self is TRanger then
    begin
      if Illegal then TRanger(Self).ApplyIllegalGoodsTradeRelationsPenalty(ShopGoodsPurchasePrice(Good, nil) * Count);
      if GetPlayer = Self then
      begin
        if CurrentPlanet <> nil then
        begin
          Event := AddGalaxyEvent('PlayerBuysGoodsFromPlanet');
          Event.AddData(Good);
          Event.AddData(Count);
          Event.AddData(Value);
          Event.AddData(CurrentPlanet.Id);
        end;
        Inc(CargoGoods[Good].PurchasedTotalCost, Value);
        Inc(CargoGoods[Good].PurchasedCount, Count);
      end
      else (Self as TRanger).AddTraderCareerActivity(8);
    end;
    RefreshDerivedStats(True);
    if (GetLocationGoodsEntry(Good).Count <> LocationCount) or
      (CargoGoods[Good].Count <> ShipCount) then GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $6D5BFC }

{ @routine $6D5E78 TShip_ProcessLiberationGroupRoute }
procedure TShip.ProcessLiberationGroupRoute;
var Destination: TPointF; I: Integer; Ship: TShip; RouteOrder: TGroupRouteOrder;
begin
  if LiberationGroup = nil then Exit;
  RouteOrder := (LiberationGroup as TGroup).Route[LiberationGroupRouteIndex];
  case RouteOrder.Kind of
  order_jump: begin
    if IsOutsideStarSpace then Exit;
    if CurrentStar = RouteOrder.Target then begin
      Inc(LiberationGroupRouteIndex);
      if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
      ProcessLiberationGroupRoute;
      Exit;
    end;
    if (Order = order_none) or (Order = order_follow_ship) then OrderJump(RouteOrder.Target as TStar, False);
  end;
  order_land: begin
    if CurrentPlanet = RouteOrder.Target then begin
      Inc(LiberationGroupRouteIndex);
      if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
      Exit;
    end;
    if IsOutsideStarSpace then Exit;
    if (RouteOrder.Target as TPlanet).CurrentStar <> CurrentStar then Exit;
    if not (RouteOrder.Target as TPlanet).IsCoalitionOwned or (CurrentStar.Battle <> 0) then begin
      LeaveLiberationGroup;
      if Self is TWarrior then begin
        (Self as TWarrior).AssignWeaponTargetsInStar;
        (Self as TWarrior).SelectEnemyShipInStar;
        (Self as TWarrior).EngageEnemyShip;
      end;
      Exit;
    end;
    if (Order = order_none) or (Order = order_follow_ship) then OrderLanding(RouteOrder.Target, False);
  end;
  order_move: begin
    if IsOutsideStarSpace then Exit;
    if CurrentStar.Battle <> 0 then begin
      LeaveLiberationGroup;
      if Self is TWarrior then begin
        (Self as TWarrior).AssignWeaponTargetsInStar;
        (Self as TWarrior).SelectEnemyShipInStar;
        (Self as TWarrior).EngageEnemyShip;
      end;
      Exit;
    end;
    if (PointDistance(Position, RouteOrder.Destination) < 300) then
    begin
      if (RouteOrder.WaitMode in [wait_for_arrival]) then
      begin
        Inc(LiberationGroupRouteIndex);
        if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
        Exit;
      end
    end;
    if (RouteOrder.WaitMode in [wait_for_group]) then
    begin
      if ((LiberationGroup as TGroup).AreShipsAssembled) then
      begin
        (LiberationGroup as TGroup).AdvanceRouteForShips;
        Exit;
      end
    end;
    if (RouteOrder.WaitMode in [wait_until_turn]) then
    begin
      if ((LiberationGroup as TGroup).Route[LiberationGroupRouteIndex].WaitUntilTurn <= Galaxy.CurrentTurn) then
      begin
        Inc(LiberationGroupRouteIndex);
        if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
        ProcessLiberationGroupRoute;
        Exit;
      end
    end;
    if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace and
      (RouteOrder.WaitMode in [wait_until_turn]) and ((LiberationGroup as TGroup).Route[LiberationGroupRouteIndex].WaitUntilTurn > Galaxy.CurrentTurn + 7) then begin
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if (Ship.InNormalSpace) then
        begin
          if (Ship.LiberationGroup = LiberationGroup) then
            if (Ship.EnemyShip = nil) then
              if (Ship.TruceShip <> EnemyShip) then
                if (Ship.LiberationGroupRouteIndex = LiberationGroupRouteIndex) then
                  Ship.EnemyShip := EnemyShip
        end;
      end;
      (Self as TWarrior).AssignWeaponTargetsInStar;
      (Self as TWarrior).EngageEnemyShip;
    end else begin
      Destination.X := RouteOrder.Destination.X + NextRandomFloatRange(-100, 100, RandomState);
      Destination.Y := RouteOrder.Destination.Y + NextRandomFloatRange(-100, 100, RandomState);
      OrderMove(Destination, False);
    end;
  end;
  end;
end;
{ @end $6D5E78 }

{ @routine $6D633C TShip_LeaveLiberationGroup }
procedure TShip.LeaveLiberationGroup;
begin
  (LiberationGroup as TGroup).Ships.Delete((LiberationGroup as TGroup).Ships.IndexOf(Self));
  LiberationGroup := nil;
  LiberationGroupRouteIndex := 0;
end;
{ @end $6D633C }

{ @routine $6D638C CompareShipGroupsStrength }
function CompareShipGroupsStrength(Ships, Opponents: TList): Single;
var I, J, ShipCount, Count: Integer; Ship, Target: TShip; Sum, Chance: Single;
begin
  ShipCount := Ships.Count;
  Count := Opponents.Count;
  Result := 0;
  for I := 0 to ShipCount - 1 do begin
    Ship := Ships[I];
    Sum := 0;
    for J := 0 to Count - 1 do begin
      Target := Opponents[J];
      Chance := Ship.ChanceToWin(Target);
      Sum := Sum + Chance;
    end;
    Result := Sum / Count / Count + Result;
  end;
end;
{ @end $6D638C }

{ @routine $6D643C CreateShipByType }
function CreateShipByType(ShipType: TShipType): TShip;
begin
  Result := nil;
  case ShipType of
    ship_ranger: Result := TRanger.Create;
    ship_dominator: Result := TKling.Create;
    ship_transport: Result := TTransport.Create;
    ship_pirate: Result := TPirate.Create;
    ship_warrior: Result := TWarrior.Create;
    ship_tranclucator: Result := TTranclucator.Create;
    station_ranger_center..station_custom: Result := TRuins.Create;
  else
    // The original constructs the exception without raising it.
    Exception.Create('function CreateShipByType(shiptype: tShipType): TShip;');
  end;
end;
{ @end $6D643C }

{ @routine $6D6550 TShip_GetHull }
function TShip.GetHull: THull;
begin
  Result := Self.Hull;
  Exit;
end;
{ @end $6D6550 }

{ @routine $6D6558 TShip_GetFuelTanks }
function TShip.GetFuelTanks: TFuelTanks;
begin
  Result := FuelTanks;
end;
{ @end $6D6558 }

{ @routine $6D6560 TShip_GetEngine }
function TShip.GetEngine: TEngine;
begin
  Result := Engine;
end;
{ @end $6D6560 }

{ @routine $6D6568 TShip_GetRadar }
function TShip.GetRadar: TRadar;
begin
  Result := Radar;
end;
{ @end $6D6568 }

{ @routine $6D6570 TShip_GetScanner }
function TShip.GetScanner: TScaner;
begin
  Result := Scanner;
end;
{ @end $6D6570 }

{ @routine $6D6578 TShip_GetRepairRobot }
function TShip.GetRepairRobot: TRepairRobot;
begin
  Result := RepairRobot;
end;
{ @end $6D6578 }

{ @routine $6D6580 TShip_GetCargoHook }
function TShip.GetCargoHook: TCargoHook;
begin
  Result := CargoHook;
end;
{ @end $6D6580 }

{ @routine $6D6588 TShip_GetDefGenerator }
function TShip.GetDefGenerator: TDefGenerator;
begin
  Result := DefGenerator;
end;
{ @end $6D6588 }

{ @routine $6D6590 TShip_CanRepairArtefactsAtLocation }
function TShip.CanRepairArtefactsAtLocation: Boolean;
begin
  if TypeId in [station_pirate_base, station_science_base] then begin Result := True; Exit; end;
  if (TypeNameOverrideKey <> '') and (FindTextOffsetW(TypeNameOverrideKey, '_licensed') >= 0) then begin Result := True; Exit; end;
  if (CurrentPlanet <> nil) and CurrentPlanet.IsMainPiratePlanet then begin Result := True; Exit; end;
  if DockedTo = nil then
  begin
    Result := False;
    Exit;
  end;
  Result := DockedTo.CanRepairArtefactsAtLocation;
end;
{ @end $6D6590 }

{ @routine $6D6604 TShip_CanUseEquipmentTech }
function TShip.CanUseEquipmentTech(Item: TEquipment): Boolean;
var
  Level: Integer;
begin
  if (Galaxy = nil) or Galaxy.IsEquipmentKnowledgeUnrestricted then begin
    Result := True;
    Exit;
  end;
  if (Self is TTranclucator) and (TTranclucator(Self).OwnerShip <> nil) then begin
    Result := TTranclucator(Self).OwnerShip.CanUseEquipmentTech(Item);
    Exit;
  end;
  if (Self is TKling) or (Item.OwnerId <> owner_dominator) then begin
    Result := True;
    Exit;
  end;
  if Item is TWeapon then Level := TWeapon(Item).GetWeaponInfo.TechLevel
  else Level := Item.GetLevel;
  Dec(Level, 4);
  Result := TechKnowledge >= Level;
end;
{ @end $6D6604 }

{ @routine $6D66A8 TShip_CanRepairEquipmentTech }
function TShip.CanRepairEquipmentTech(Item: TEquipment): Boolean;
var
  Level: Integer;
begin
  if (Galaxy = nil) or Galaxy.IsEquipmentKnowledgeUnrestricted then Result := True
  else if (Self is TTranclucator) and (TTranclucator(Self).OwnerShip <> nil) then
    Result := TTranclucator(Self).OwnerShip.CanRepairEquipmentTech(Item)
  else if (Item is THull) or (Self is TKling) or (Item.OwnerId <> owner_dominator) then Result := True
  else
  begin
    Level := Item.GetLevel;
    if Item is TWeapon then Level := Max(Level, TWeapon(Item).GetWeaponInfo.TechLevel);
    Dec(Level, 2);
    Result := TechKnowledge >= Level;
  end;
end;
{ @end $6D66A8 }

{ @routine $6D6768 TShip_IsEquipmentUsable }
function TShip.IsEquipmentUsable(Item: TEquipment): Boolean;
begin
  Result := (Item <> nil) and
    ((not (Item.ItemType in [item_fuel_tanks..item_custom_weapon, item_satellite])) or (Item.BrokenFlag = 0)) and CanUseEquipmentTech(Item);
end;
{ @end $6D6768 }

{ @routine $6D67A0 TShip_EquipItem }
procedure TShip.EquipItem(Item: TEquipment);
begin
  if Item.ItemType in [item_hull..item_defense_generator] then
  begin
    if EquipmentCache.Slots[Item.ItemType] <> nil then
      EquipmentCache.Slots[Item.ItemType].Unequip;
    EquipmentCache.Slots[Item.ItemType] := Item;
  end
  else if Item.ItemType in WeaponItemTypes then
  begin
    if WeaponCount < 5 then Inc(WeaponCount);
    if Weapons[WeaponCount] <> nil then Weapons[WeaponCount].Unequip;
    Weapons[WeaponCount] := Item as TWeapon;
  end;
  Item.Equip;
end;
{ @end $6D67A0 }

{ @routine $6D6828 TShip_UnequipSlot }
procedure TShip.UnequipSlot(ItemType: TItemType; WeaponIndex: Integer);
var
  I: Integer;
begin
  if ItemType in [item_hull..item_defense_generator] then
  begin
    EquipmentCache.Slots[ItemType].Unequip;
    EquipmentCache.Slots[ItemType] := nil;
  end
  else if ItemType in WeaponItemTypes then
  begin
    Weapons[WeaponIndex].Unequip;
    Weapons[WeaponIndex] := nil;
    if WeaponCount > WeaponIndex then
    begin
      for I := WeaponIndex to WeaponCount - 1 do Weapons[I] := Weapons[I + 1];
      Weapons[WeaponCount] := nil;
    end;
    Dec(WeaponCount);
  end;
end;
{ @end $6D6828 }

{ @routine $6D68B0 TShip_UnequipItem }
procedure TShip.UnequipItem(Item: TEquipment);
var
  I: Integer;
begin
  if Item is TWeapon then
  begin
    for I := 1 to CountEquippedWeapons do
      if Weapons[I] = Item then
      begin
        UnequipSlot(WeaponCategoryItemType, I);
        Break;
      end;
  end
  else if (Item.ItemType in [item_hull..item_defense_generator]) and
    (EquipmentCache.Slots[Item.ItemType] = Item) then UnequipSlot(Item.ItemType, 0);
end;
{ @end $6D68B0 }

{ @routine $6D6920 TShip_CalculateMass }
function TShip.CalculateMass: Integer;
var
  Mass: Double;
  Bonus, I: Integer;
begin
  Mass := GetHull.Weight - CargoFreeSpace + GetHull.CalculateMass;
  if Artefacts.Count > 0 then
    for I := 1 to CountActiveArtefacts(artefact_antigravity) do
      Mass := Mass * (AntigravityArtefactMassFactor + AntigravityArtefactBoostFactor * ShortInt(CanBoostArtefact(artefact_antigravity, nil, False)));
  if (PilotRace = owner_maloc) and IsHealthEffectActive(disease_grand_malosausus) then Mass := Mass * 1.2;
  Bonus := GetTotalStatBonus(bonus_mass);
  if GetHull.MicroModuleIndex <> 0 then Inc(Bonus, MicroModuleTemplates[GetHull.MicroModuleIndex - 1].StatBonuses[bonus_mass]);
  Mass := Mass * (1 + Bonus / 100);
  Result := Round(Mass);
end;
{ @end $6D6920 }

{ @routine $6D6A34 TShip_CalculateEquippedMass }
function TShip.CalculateEquippedMass(ItemForModule: TEquipment): Integer;
var
  I: Integer;
  Item: TEquipment;
  Mass: Double;
  Bonus: Integer;
begin
  Mass := GetHull.CalculateMass;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if Item.EquippedFlag <> 0 then Mass := Mass + Item.Weight;
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if Item.EquippedFlag <> 0 then Mass := Mass + Item.Weight;
  end;
  Bonus := GetTotalStatBonus(bonus_mass);
  if (ItemForModule <> nil) and (ItemForModule.SpecialModuleIndex <> 0) then
    Inc(Bonus, MicroModuleTemplates[ItemForModule.SpecialModuleIndex - 1].StatBonuses[bonus_mass]);
  Mass := Mass * (1 + Bonus / 100);
  if Artefacts.Count > 0 then
    for I := 1 to CountActiveArtefacts(artefact_antigravity) do
      Mass := Mass * (AntigravityArtefactMassFactor + AntigravityArtefactBoostFactor * ShortInt(CanBoostArtefact(artefact_antigravity, nil, False)));
  Result := Round(Mass);
end;
{ @end $6D6A34 }

{ @routine $6D6B64 TShip_GetHullIntegrityPercent }
function TShip.GetHullIntegrityPercent: TPercent;
begin
  Result := Round(GetHull.HullPoints / GetHull.Weight * 100);
end;
{ @end $6D6B64 }

{ @routine $6D6B9C TShip_GetArmor }
function TShip.GetArmor: Integer;
begin
  Result := CalculateHullArmor(GetHull) - Integer(Round(GetCombatStatusStrength(combat_effect_acid)));
  Result := Max(0, Result);
end;
{ @end $6D6B9C }

{ @routine $6D6BCC TShip_GetJumpDestinationDistance }
function TShip.GetJumpDestinationDistance: Integer;
begin
  if Order = order_jump then Result := Trunc(PointDistance(CurrentStar.Position, (OrderTarget as TStar).Position))
  else Result := 0;
end;
{ @end $6D6BCC }

{ @routine $6D6C04 TShip_GetFullRefuelCost }
function TShip.GetFullRefuelCost: Integer;
begin
  if GetFuelTanks <> nil then
  begin
    if CurrentPlanet <> nil then Result := Round(CalculateFuelCost(GetFuelTanks.Capacity - GetFuelTanks.Fuel, CurrentPlanet.OwnerId))
    else Result := Round(CalculateFuelCost(GetFuelTanks.Capacity - GetFuelTanks.Fuel, owner_uninhabited));
  end
  else Result := 0;
end;
{ @end $6D6C04 }

{ @routine $6D6C74 CalculateFuelCost }
function CalculateFuelCost(Amount: Integer; OwnerId: TOwnerId): Single;
var Value: Single; BaseCost: Integer;
begin
  BaseCost := Amount;
  Value := BaseCost;
  Value := Value * RemapClamped(Galaxy.CurrentTurn, 1000, 15000, 1, 10);
  if OwnerId <> owner_uninhabited then Value := Value * OwnerInfo[OwnerId].FuelPriceFactor;
  Value := Value * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor;
  Result := Value;
end;
{ @end $6D6C74 }

{ @routine $6D6D18 CalculateRoundedFuelCost }
function CalculateRoundedFuelCost(Amount: Integer; OwnerId: TOwnerId): Integer;
begin
  Result := Round(CalculateFuelCost(Amount, OwnerId));
end;
{ @end $6D6D18 }

{ @routine $6D6D30 TShip_GetAfterburnerWear }
function TShip.GetAfterburnerWear: Integer;
var
  I, Count: Integer;
  Factor, Wear: Single;
begin
  if GetEngine <> nil then
    Result := SeededRandomIntRange(OwnerInfo[GetEngine.OwnerId].MinimumAfterburnerWear, OwnerInfo[GetEngine.OwnerId].MaximumAfterburnerWear, Galaxy.CurrentTurn)
  else Result := 1;
  Count := CountActiveArtefacts(artefact_afterburner);
  if Count = 0 then Exit;
  Factor := AfterburnerArtefactWearFactor;
  if CanBoostArtefact(artefact_afterburner, nil, False) then Factor := Factor + AfterburnerArtefactBoostWearFactor;
  Wear := Result;
  for I := 1 to Count do Wear := Wear * Factor;
  Result := Round(Wear);
end;
{ @end $6D6D30 }

{ @routine $6D6E00 TShip_GetFuelLimitedJumpRange }
function TShip.GetFuelLimitedJumpRange: Integer;
begin
  if (GetFuelTanks = nil) or not CanUseEquipmentTech(GetFuelTanks) or (GetEngine = nil) or not CanUseEquipmentTech(GetEngine) then
  begin Result := 0; Exit; end;
  Result := Min(GetFuelTanks.Fuel + GetOwnStatBonus(bonus_fuel_capacity), GetJumpRange);
end;
{ @end $6D6E00 }

{ @routine $6D6E6C TShip_GetJumpRange }
function TShip.GetJumpRange: Integer;
begin
  if GetEngine = nil then begin Result := 0; Exit; end;
  if GetEngine.BrokenFlag <> 0 then Result := Round(CalculateEngineJumpRange(GetEngine) * 0.6)
  else Result := CalculateEngineJumpRange(GetEngine);
end;
{ @end $6D6E6C }

{ @routine $6D6ED4 TShip_IsMicroModuleRaciallyRestricted }
function TShip.IsMicroModuleRaciallyRestricted(ModuleIndex: Integer): Boolean;
const
  AllSeries = [series_blazer..series_terron];
  PlanetOwners = [owner_maloc..owner_gaal];
  NoOwners = [];
var
  Position, NameLength: Integer;
begin
  Result := False;
  if MicroModuleTemplates[ModuleIndex].RacialRestriction then
  begin
    if (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '') then
    begin
      Position := Pos(TScriptShip(ScriptShip).StateText, MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions);
      if Position > 1 then
      begin
        NameLength := Length(TScriptShip(ScriptShip).StateText);
        if (MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions[Position - 1] = '<') and
          (Length(MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions) >= Position + NameLength) and
          (MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions[Position + NameLength] = '>') then Exit;
      end;
      if HasIndependentScriptFaction then
      begin
        Result := True;
        Exit;
      end;
      if (Self is TKling) and (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask <> AllSeries) then
      begin
        Result := True;
        Exit;
      end;
      if Self is TTranclucator then
      begin
        Result := True;
        Exit;
      end;
    end;
    if (Self is TKling) and (owner_dominator in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) and
      ((Self as TKling).DominatorSeries in MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) then Exit;
    if ((Self is TNormalShip) or (Self is TRuins)) and
      ((RaceToOwner(PilotRace) in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) or
       ((OwnerId = owner_pirate) and (owner_pirate in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask))) then Exit;
    if not (Self is TKling) and
      (MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * PlanetOwners = NoOwners) and
      (OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Exit;
    if (Self is TTranclucator) and (owner_uninhabited in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Exit;
    Result := True;
  end;
end;
{ @end $6D6ED4 }

{ @routine $6D7158 TShip_GetEquipmentStatBonus }
function TShip.GetEquipmentStatBonus(BonusKind: TEquipmentBonusKind; Item: TEquipment): Integer;
begin
  if (Item.SpecialModuleIndex <> 0) and
     IsMicroModuleRaciallyRestricted(Item.SpecialModuleIndex - 1) then Result := 0
  else Result := Item.GetStatBonus(BonusKind);
end;
{ @end $6D7158 }

{ @routine $6D718C TShip_GetTotalStatBonus }
function TShip.GetTotalStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  Item: TEquipment;
  I, Strength: Integer;
begin
  Result := GetOwnStatBonus(BonusKind);
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if ((I = 0) or (Item.EquippedFlag <> 0)) and IsEquipmentUsable(Item) then
      Inc(Result, GetEquipmentStatBonus(BonusKind, Item));
  end;
  if Artefacts <> nil then
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      if (Item.EquippedFlag <> 0) and (Item.BrokenFlag = 0) then
        Inc(Result, GetEquipmentStatBonus(BonusKind, Item));
    end;
  Strength := Round(GetCombatStatusStrength(combat_effect_magnetic));
  if Strength >= 1 then
    case BonusKind of
      bonus_scanner_power, bonus_defense: Dec(Result, Strength);
      bonus_weapon_range: Dec(Result, Strength * 10);
      bonus_radar_range: Dec(Result, Strength * 100);
    end;
end;
{ @end $6D718C }

{ @routine $6D7288 TShip_GetRadarRange }
function TShip.GetRadarRange: Integer;
begin
  if not IsEquipmentUsable(GetRadar) then Result := 0 else Result := CalculateRadarRange(GetRadar);
  if GetPlayer = Self then
  begin
    if IsHealthEffectActive(stimulant_psychotropic_cache) then Result := Result * 2;
    if Galaxy.UltraScanModEnabled <> 0 then Result := Max(Result, 25000);
  end;
end;
{ @end $6D7288 }

{ @routine $6D72FC TShip_GetScannerPower }
function TShip.GetScannerPower: Integer;
begin
  Result := 0;
  if IsEquipmentUsable(GetScanner) then Result := CalculateScannerPower(GetScanner) + 12 * Ord(IsHealthEffectActive(stimulant_psychotropic_cache));
end;
{ @end $6D72FC }

{ @routine $6D7348 TShip_CanResolveObjectWithScanner }
function TShip.CanResolveObjectWithScanner(Target: TObject): Boolean;
begin
  if not IsEquipmentUsable(GetScanner) then begin Result := False; Exit; end;
  if Target is TShip then
  begin
    if GetPlayer = Self then
      if ((Target as TShip).PartnerShip = GetPlayer) or ((Target as TShip).TypeId = ship_tranclucator) or ((Target as TShip) = Self) then
      begin Result := True; Exit; end;
    Result := (Target as TShip).GetDefensePercent <= GetScannerPower;
  end
  else Result := True;
end;
{ @end $6D7348 }

{ @routine $6D73F8 TShip_ApplyRepairDroidHealing }
procedure TShip.ApplyRepairDroidHealing;
var
  Repair: Integer;
begin
  if not IsEquipmentUsable(GetRepairRobot) then Exit;
  if (TypeId = ship_dominator) and (Self as TKling).IsProgramActive(program_disconnection) then Exit;
  if NextRandomUnitFloat(RandomState) + 0.01 >= GetCombatStatusStrength(combat_effect_droid_block) then
  begin
    Repair := CalculateRepairPoints(GetRepairRobot);
    Repair := ScriptItemsAct(event_robot_repair, nil, nil, Repair);
    if TypeId <> ship_dominator then
    begin
      if CountActiveArtefacts(artefact_repair_robot) > 0 then
      begin
        if CanBoostArtefact(artefact_repair_robot, nil, False) then
          ApplyItemDegradation(GetRepairRobot, wear_use, NextRandomUnitFloat(RandomState) * 2 *
            (1 + CountActiveArtefacts(artefact_repair_robot) * (DroidArtefactWear + DroidArtefactBoostWear)))
        else
          ApplyItemDegradation(GetRepairRobot, wear_use, NextRandomUnitFloat(RandomState) * 2 *
            (1 + CountActiveArtefacts(artefact_repair_robot) * DroidArtefactWear));
      end
      else ApplyItemDegradation(GetRepairRobot, wear_use, NextRandomUnitFloat(RandomState) * 2);
    end;
  end
  else if CountActiveArtefacts(artefact_repair_robot) > 0 then
    Repair := CountActiveArtefacts(artefact_repair_robot) * (DroidArtefactRepair + DroidArtefactBoostRepair * Ord(CanBoostArtefact(artefact_repair_robot, nil, False)))
  else Exit;
  if Repair > 0 then Inc(GetHull.HullPoints, Min(Repair, GetHull.Weight - GetHull.HullPoints));
end;
{ @end $6D73F8 }

{ @routine $6D7614 TShip_GetCargoHookMinPullSpeed }
function TShip.GetCargoHookMinPullSpeed: Single;
begin
  Result := 0;
  if GetCargoHook <> nil then
    Result := Max(0.1, GetCargoHook.MinPullSpeed + CountActiveArtefacts(artefact_cargo_hook) * (CargoHookArtefactSpeed + CargoHookArtefactBoostSpeed * Ord(CanBoostArtefact(artefact_cargo_hook, nil, False))) + GetTotalStatBonus(bonus_hook_min_speed));
end;
{ @end $6D7614 }

{ @routine $6D76FC TShip_GetCargoHookMaxPullSpeed }
function TShip.GetCargoHookMaxPullSpeed: Single;
begin
  Result := 0;
  if GetCargoHook <> nil then
    Result := Max(0.1, GetCargoHook.MaxPullSpeed + CountActiveArtefacts(artefact_cargo_hook) * (CargoHookArtefactSpeed + CargoHookArtefactBoostSpeed * Ord(CanBoostArtefact(artefact_cargo_hook, nil, False))) + GetTotalStatBonus(bonus_hook_max_speed));
end;
{ @end $6D76FC }

{ @routine $6D77E4 TShip_GetCargoHookRange }
function TShip.GetCargoHookRange: Integer;
begin
  Result := 0;
  if GetCargoHook <> nil then
    Result := GetCargoHook.Range + CountActiveArtefacts(artefact_cargo_hook) * (CargoHookArtefactRange + CargoHookArtefactBoostRange * Ord(CanBoostArtefact(artefact_cargo_hook, nil, False))) + GetTotalStatBonus(bonus_hook_range);
end;
{ @end $6D77E4 }

{ @routine $6D783C TShip_GetCargoHookRangeSquared }
function TShip.GetCargoHookRangeSquared: Integer;
begin
  Result := Sqr(GetCargoHookRange);
end;
{ @end $6D783C }

{ @routine $6D784C TShip_GetBaseCargoHookPower }
function TShip.GetBaseCargoHookPower: Integer;
begin
  if GetCargoHook <> nil then Result := GetCargoHook.PickupPower
  else Result := 0;
end;
{ @end $6D784C }

{ @routine $6D786C TShip_GetDefenseDamageFactor }
function TShip.GetDefenseDamageFactor: Double;
begin
  if not IsEquipmentUsable(GetDefGenerator) then begin Result := 1; Exit; end;
  Result := CalculateDefGeneratorFactor(GetDefGenerator);
end;
{ @end $6D786C }

{ @routine $6D78B0 TShip_GetDefensePercent }
function TShip.GetDefensePercent: TPercent;
begin
  Result := DefenseDamageFactorToPercent(GetDefenseDamageFactor);
end;
{ @end $6D78B0 }

{ @routine $6D78C8 TShip_GetAttackMultiplier }
function TShip.GetAttackMultiplier: Integer;
begin
  Result := Max(0, 1 + GetOwnStatBonus(bonus_attack_count));
end;
{ @end $6D78C8 }

{ @routine $6D78E0 TShip_AddAward }
procedure TShip.AddAward(AwardId: Byte);
begin
  if AwardId = AwardNotFound then RaiseWideMessage('Error RewardNumber=255');
  if AwardIds = nil then AwardIds := TList.Create;
  if AwardIds.Count = 255 then Exit;
  if AwardIds.Count = AwardVisibleCount then Inc(AwardVisibleCount);
  AwardIds.Add(Pointer(AwardId));
  if GetPlayer = Self then GetPlayer.AchievementStats.CheckAllAwardsAchievement;
end;
{ @end $6D78E0 }

{ @routine $6D798C TShip_RefreshDerivedStats }
procedure TShip.RefreshDerivedStats(UpdateRelativeRatings: Boolean);
begin
  RebuildEquipmentCache;
  CargoFreeSpace := GetCargoFreeSpace;
  Speed := CalculateSpeed;
  if GetPlayer = Self then
  begin
    GetPlayer.AchievementStats.CheckSpeedAchievement;
    GetPlayer.AchievementStats.CheckBestEquipmentAchievement;
  end;
  JumpRange := GetFuelLimitedJumpRange;
  DefenseDamageFactor := GetDefenseDamageFactor;
  CalculateStrength;
  CalculateWealth;
  if UpdateRelativeRatings then
  begin
    UpdateBestRangerRelativeRatings;
    UpdateAverageRangerRelativeStrength;
  end;
  if GetEngine <> nil then
  begin
    MovementTurnRate := RemapClamped(Speed, EngineLevelStats[1].Speed / 2, EngineLevelStats[8].Speed, 1, 5) * BaseMovementStepsPerTurn * 0.005;
    MovementSpeed := Speed * 0.005;
  end
  else MovementSpeed := 0;
  DerivedStateCompatibilityHook;
end;
{ @end $6D798C }

{ @routine $6D7ADC TShip_RefreshGraphicSize }
procedure TShip.RefreshGraphicSize;
var
  Size, Small, Large: Integer;
  Kind: TDominatorKind;
  Series: TDominatorSeries;
begin
  if (Graphic is TShip2SE) and (TShip2SE(Graphic).SmallSize > 0) and (TShip2SE(Graphic).LargeSize > 0) then
  begin
    Small := TShip2SE(Graphic).SmallSize;
    Large := TShip2SE(Graphic).LargeSize;
  end
  else if Self is TTranclucator then
  begin
    Small := TranclucatorSmallSize;
    Large := TranclucatorLargeSize;
  end
  else if ScriptChameleon then
  begin
    Small := DefaultShipSmallSize;
    Large := DefaultShipLargeSize;
  end
  else if (GetHull.HullType = hull_special) and not ChameleonActive then
  begin
    Small := SpecialHullSmallSize;
    Large := SpecialHullLargeSize;
  end
  else if ChameleonActive or (Self is TKling) then
  begin
    if ChameleonActive then
    begin
      Kind := ChameleonVisualType;
      Series := ChameleonSeries;
    end
    else
    begin
      Kind := (Self as TKling).KlingType;
      Series := (Self as TKling).DominatorSeries;
    end;
    Small := DominatorShipSmallSizes[Series, Kind];
    Large := DominatorShipLargeSizes[Series, Kind];
  end
  else if Self is TRuins then
  begin
    Small := StationSize;
    Large := StationSize;
  end
  else if (Self is TPirate) and (OwnerId = owner_pirate) and ((Self as TPirate).PirateType <> 0) then
  begin
    Small := PirateClanSmallSizes[GetHull.OwnerId];
    Large := PirateClanLargeSizes[GetHull.OwnerId];
  end
  else if (Self is TWarrior) and ((Self as TWarrior).WarriorType = warrior_flagship) then
  begin
    Small := BigWarriorSmallSizes[GetHull.OwnerId];
    Large := BigWarriorLargeSizes[GetHull.OwnerId];
  end
  else
    case GetHull.HullType of
      hull_ranger: begin Small := RangerSmallSizes[GetHull.OwnerId]; Large := RangerLargeSizes[GetHull.OwnerId]; end;
      hull_transport..hull_diplomat: begin Small := TransportSmallSizes[GetHull.HullType, GetHull.OwnerId]; Large := TransportLargeSizes[GetHull.HullType, GetHull.OwnerId]; end;
      hull_pirate: begin Small := PirateSmallSizes[GetHull.OwnerId]; Large := PirateLargeSizes[GetHull.OwnerId]; end;
      hull_warrior: begin Small := WarriorSmallSizes[GetHull.OwnerId]; Large := WarriorLargeSizes[GetHull.OwnerId]; end;
    else
      Small := DefaultShipSmallSize;
      Large := DefaultShipLargeSize;
    end;
  if (GetHull.HullType = hull_special) and (GetHull.SpecialModuleIndex <> 0) and not ChameleonActive and not ScriptChameleon then
  begin
    Small := Round(Small * MicroModuleTemplates[GetHull.SpecialModuleIndex - 1].HullGraphSizePercent * 0.01);
    Large := Round(Large * MicroModuleTemplates[GetHull.SpecialModuleIndex - 1].HullGraphSizePercent * 0.01);
  end;
  Size := Round(Ln(Max(1, GetHull.Weight / (HullBaseSize * EquipmentSizeFactors[5]))) * (Large - Small) /
    Ln(2 * EquipmentSizeFactors[1] / EquipmentSizeFactors[5]) + Small);
  if GiResourceVariant = 1 then Size := Round(Size * 0.78125);
  Graphic.SetSize(Classes.Point(Size, Size));
end;
{ @end $6D7ADC }

{ @routine $6D7F5C TShip_RebuildEquipmentCache }
procedure TShip.RebuildEquipmentCache;
var
  I: Integer;
  Item: TEquipment;
  Kind: TItemType;
begin
  Hull := Inventory[0];
  for Kind := item_fuel_tanks to item_defense_generator do EquipmentCache.Slots[Kind] := nil;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  UsableWeaponCount := 0;
  HasInactiveDirectEquipment := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag <> 0) and not (Item.ItemType in [item_fuel_tanks..item_engine]) and
       (GetSlotCountForItemType(Item.ItemType) <= 0) and
       (ItemTypeToSlotKind(Item.ItemType) <> slot_unsupported) then Item.EquippedFlag := 0;
    if Item.EquippedFlag <> 0 then
    begin
      if Item.ItemType in [item_hull..item_defense_generator] then EquipmentCache.Slots[Item.ItemType] := Item
      else if Item.ItemType in WeaponItemTypes then
      begin
        Inc(WeaponCount);
        Weapons[WeaponCount] := Item as TWeapon;
        if IsEquipmentUsable(Weapons[WeaponCount]) then Inc(UsableWeaponCount);
      end;
    end
    else if Item.ItemType in [item_hull..item_defense_generator] then HasInactiveDirectEquipment := 1;
  end;
  RemoveInvalidPickupTargets;
end;
{ @end $6D7F5C }

{ @routine $6D8090 TShip_GetCargoFreeSpace }
function TShip.GetCargoFreeSpace: Integer;
begin
  Result := GetHull.Weight - GetCarriedItemWeight - GetCargoGoodsWeight;
end;
{ @end $6D8090 }

{ @routine $6D80B4 TShip_GetCarriedItemWeight }
function TShip.GetCarriedItemWeight: Integer;
var
  Item: TItem;
  I, Weight: Integer;
begin
  Weight := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    Inc(Weight, Item.Weight);
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    Inc(Weight, Item.Weight);
  end;
  Result := Weight;
end;
{ @end $6D80B4 }

{ @routine $6D8110 TShip_GetCargoGoodsWeight }
function TShip.GetCargoGoodsWeight: Integer;
var
  Good: Byte;
begin
  Result := 0;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do Inc(Result, CargoGoods[Good].Count);
end;
{ @end $6D8110 }

{ @routine $6D8128 TShip_CalculateFollowRadius }
function TShip.CalculateFollowRadius: Integer;
const NoWeaponRange = 999999;
var Mode: TFollowMode; I: Integer; Target: TShip; Weapon: TWeapon;
begin
  if Order <> order_follow_ship then raise Exception.Create('TShip.CalcFollowRadius()');
  Target := OrderTarget as TShip;
  Mode := TFollowMode(Byte(OrderStateData));
  case Mode of
    follow_min_weapon_range: begin
         Result := NoWeaponRange;
         for I := 1 to WeaponCount do
         begin
           Weapon := Weapons[I];
           if IsEquipmentUsable(Weapon) and (GetWeaponRange(Weapon) < Result) then Result := GetWeaponRange(Weapon);
         end;
       end;
    follow_max_weapon_range: begin
         Result := 0;
         for I := 1 to WeaponCount do
         begin
           Weapon := Weapons[I];
           if IsEquipmentUsable(Weapon) and (GetWeaponRange(Weapon) > Result) then Result := GetWeaponRange(Weapon);
         end;
       end;
  else Result := NoWeaponRange;
  end;
  if (Result > 0) and (Result < NoWeaponRange) then Result := Round(Result * 0.85)
  else Result := Trunc(CollisionRadius + Target.CollisionRadius) + 15;
end;
{ @end $6D8128 }

{ @routine $6D8294 TShip_GetFollowMode }
function TShip.GetFollowMode: TFollowMode;
begin
  if Order <> order_follow_ship then raise Exception.Create('TShip.CalcFollowRadius()');
  Result := TFollowMode(Byte(OrderStateData));
end;
{ @end $6D8294 }

{ @routine $6D82E0 TShip_GetEffectiveFollowMode }
function TShip.GetEffectiveFollowMode: TFollowMode;
var Mode: TFollowMode; BoundarySquared, DistanceSquared, TargetDistanceSquared: Single;
begin
  if Order <> order_follow_ship then raise Exception.Create('TShip.GetRealFollowType()');
  Result := follow_close;
  Mode := TFollowMode(Byte(OrderStateData));
  if (Mode in [follow_close, follow_kamikaze]) or (WeaponCount <= 0) then Exit;
  if (GetPlayer <> Self) and (SeededRandomIntRange(0, 6, Seed + Galaxy.CurrentTurn) = 0) then Exit;
  BoundarySquared := Sqr(CurrentStar.MapDiameter / 2);
  DistanceSquared := Sqr(Position.X) + Sqr(Position.Y);
  TargetDistanceSquared := Sqr(TShip(OrderTarget).Position.X) + Sqr(TShip(OrderTarget).Position.Y);
  if (DistanceSquared > BoundarySquared) and (TargetDistanceSquared > DistanceSquared) then Exit;
  Result := Mode;
end;
{ @end $6D82E0 }

{ @routine $6D83FC TShip_NeedsEquipmentType }
function TShip.NeedsEquipmentType(ItemType: TItemType): Boolean;
begin
  Result := False;
  if ((ItemType in [item_fuel_tanks, item_engine, item_repair_robot, item_defense_generator]) or (ItemType in WeaponItemTypes)) and (CountCarriedEquipmentByType(ItemType) <= 0) then Result := True;
end;
{ @end $6D83FC }

{ @routine $6D8438 TShip_CalculateEquippedItemCostWithoutHull }
function TShip.CalculateEquippedItemCostWithoutHull: Integer;
var I: Integer; Item: TEquipment; Artefact: TArtefact;
begin
  Result := 0;
  for I := 1 to Inventory.Count - 1 do begin
    Item := Inventory[I];
    if Item.EquippedFlag <> 0 then Inc(Result, Item.Cost);
  end;
  for I := 0 to Artefacts.Count - 1 do begin
    Artefact := Artefacts[I];
    if Artefact.EquippedFlag <> 0 then Inc(Result, Artefact.Cost);
  end;
end;
{ @end $6D8438 }

{ @routine $6D84A0 TShip_CountCarriedEquipmentByType }
function TShip.CountCarriedEquipmentByType(ItemType: TItemType): Integer;
var
  I: Integer;
  Item: TItem;
begin
  Result := 0;
  if ItemType in [item_hull..item_custom_weapon] then
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item.ItemType = ItemType) or ((ItemType in WeaponItemTypes) and (Item.ItemType in WeaponItemTypes)) then Inc(Result);
    end;
end;
{ @end $6D84A0 }

{ @routine $6D8500 TShip_SelectBestUnequippedWeapon }
function TShip.SelectBestUnequippedWeapon: TWeapon;
var
  Index: Integer;
  Candidate: TEquipment;
  Weapon: TWeapon;
  CandidateProtected, BestProtected: Boolean;
  PriceMode: Byte;
begin
  Result := nil;
  if IsDocked then PriceMode := 3 else PriceMode := 0;
  for Index := 1 to Inventory.Count - 1 do
  begin
    Candidate := Inventory[Index];
    if (Candidate.ItemType in WeaponItemTypes) and (Candidate.EquippedFlag = 0) then
    begin
      if Result = nil then begin
        Result := Candidate as TWeapon;
        Continue;
      end;
      CandidateProtected := (Candidate.NoDropFlag > 0) or
        ((Candidate.ScriptItem <> nil) and (TScriptItem(Candidate.ScriptItem).Name <> ''));
      BestProtected := (Result.NoDropFlag > 0) or
        ((Result.ScriptItem <> nil) and (TScriptItem(Result.ScriptItem).Name <> ''));
      if CandidateProtected and not BestProtected then Result := Candidate as TWeapon
      else if (BestProtected = False) or (CandidateProtected <> False) then
      begin
        Weapon := Candidate as TWeapon;
        if Weapon.Weight <= GetHull.Weight * 0.25 then
          if EvaluateItem(Result, PriceMode) < EvaluateItem(Weapon, PriceMode) then Result := Weapon;
      end;
    end;
  end;
end;
{ @end $6D8500 }

{ @routine $6D8658 TShip_HasLooseNonScriptItemsOrGoods }
function TShip.HasLooseNonScriptItemsOrGoods: Boolean;
var I: Integer; Item: TEquipment; Artefact: TArtefact;
begin
  for I := 1 to Inventory.Count - 1 do begin
    Item := Inventory[I];
    if (Item.EquippedFlag = 0) and ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) then begin Result := True; Exit; end;
  end;
  if HasCargoGoods then begin Result := True; Exit; end;
  for I := 0 to Artefacts.Count - 1 do begin
    Artefact := Artefacts[I];
    if (Artefact.EquippedFlag = 0) and ((Artefact.ScriptItem = nil) or (TScriptItem(Artefact.ScriptItem).Name = '')) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $6D8658 }

{ @routine $6D86FC TShip_DropUnequippedItemsAndGoods }
procedure TShip.DropUnequippedItemsAndGoods;
var I: Integer; Item: TEquipment; Artefact: TArtefact;
begin
  for I := Inventory.Count - 1 downto 1 do begin
    Item := Inventory[I];
    if (Item.EquippedFlag = 0) and ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) then DropCarriedItemAsMovingLoot(Item);
  end;
  if HasCargoGoods then DropAllCargoGoods;
  for I := Artefacts.Count - 1 downto 0 do begin
    Artefact := Artefacts[I];
    if (Artefact.EquippedFlag = 0) and ((Artefact.ScriptItem = nil) or (TScriptItem(Artefact.ScriptItem).Name = '')) then DropCarriedArtefactAsMovingLoot(Artefact);
  end;
end;
{ @end $6D86FC }

{ @routine $6D87A4 TShip_AddItemToPlayerStorage }
procedure TShip.AddItemToPlayerStorage(Item: TItem; Location: TObject; Slot: Integer);
var Entry: PStorageEntry;
begin
  New(Entry);
  GetPlayer.StorageEntries.Add(Entry);
  Entry.LocationOwner := Location;
  Entry.Item := Item;
  if Slot >= 0 then
  begin
    if GetPlayer.FindStorageIndexByLocationAndSlot(Location, Slot) >= 0 then GetPlayer.ShiftStorageSlotsAtOrAfter(Location, Slot);
    Entry.SlotIndex := Slot;
  end
  else
  begin
    Entry.SlotIndex := -1;
    Entry.SlotIndex := GetPlayer.FindNextStorageSlot(Entry.LocationOwner);
  end;
  if Item is TEquipmentWithActCode then RunItemConfigActionCode(Item, event_move_item_to_storage, nil, Item, Location, 0);
  if Item.ScriptItem <> nil then TScriptItem(Item.ScriptItem).RunActionCode(event_move_item_to_storage, nil, Item, Location, 0);
  ScriptItemsAct(event_move_item_to_storage, Item, Location, 0);
end;
{ @end $6D87A4 }

{ @routine $6D8868 TShip_MergeItemIntoPlayerStorage }
procedure TShip.MergeItemIntoPlayerStorage(Item: TItem; Location: TObject; Slot: Integer);
var Index, Occupant: Integer; Entry: PStorageEntry;
begin
  if Item is TCountableItem then begin
    Index := GetPlayer.FindMergeableStorageItemByLocation(Location, TCountableItem(Item));
    if Index >= 0 then begin
      Entry := GetPlayer.StorageEntries[Index];
      TCountableItem(Entry.Item).Merge(Item);
      if Slot >= 0 then begin
        Occupant := GetPlayer.FindStorageIndexByLocationAndSlot(Location, Slot);
        if (Occupant >= 0) and (Occupant <> Index) then GetPlayer.ShiftStorageSlotsAtOrAfter(Location, Slot);
        Entry.SlotIndex := Slot;
      end;
      Item.Free;
      Exit;
    end;
  end else if Item.ItemType in [item_food..item_narcotics] then begin
    Index := GetPlayer.FindStorageGoodsByLocationAndType(Location, Byte(Item.ItemType));
    if Index >= 0 then begin
      Entry := GetPlayer.StorageEntries[Index];
      Inc((Entry.Item as TGoods).Quantity, TGoods(Item).Quantity);
      Inc((Entry.Item as TGoods).Weight, Item.Weight);
      Inc((Entry.Item as TGoods).Cost, Round(Item.Cost));
      if Slot >= 0 then begin
        Occupant := GetPlayer.FindStorageIndexByLocationAndSlot(Location, Slot);
        if (Occupant >= 0) and (Occupant <> Index) then GetPlayer.ShiftStorageSlotsAtOrAfter(Location, Slot);
        Entry.SlotIndex := Slot;
      end;
      Item.Free;
      Exit;
    end;
  end;
  AddItemToPlayerStorage(Item, Location, Slot);
end;
{ @end $6D8868 }

{ @routine $6D89E4 TShip_AddGoodsToPlayerStorage }
procedure TShip.AddGoodsToPlayerStorage(Good: Byte; Quantity, Cost: Integer; Location: TObject; Slot: Integer);
var Index, Occupant: Integer; Entry: PStorageEntry;
begin
  if Quantity <= 0 then Exit;
  Index := GetPlayer.FindStorageGoodsByLocationAndType(Location, Good);
  if Index >= 0 then begin
    Entry := GetPlayer.StorageEntries[Index];
    Inc((Entry.Item as TGoods).Quantity, Quantity);
    Inc((Entry.Item as TGoods).Weight, Quantity);
    Inc((Entry.Item as TGoods).Cost, Cost);
    if Slot >= 0 then begin
      Occupant := GetPlayer.FindStorageIndexByLocationAndSlot(Location, Slot);
      if (Occupant >= 0) and (Occupant <> Index) then GetPlayer.ShiftStorageSlotsAtOrAfter(Location, Slot);
      Entry.SlotIndex := Slot;
    end;
  end else begin
    New(Entry);
    GetPlayer.StorageEntries.Add(Entry);
    Entry.Item := TGoods.Create;
    (Entry.Item as TGoods).Init(TItemType(Good), Quantity);
    Entry.Item.Cost := Cost;
    Entry.LocationOwner := Location;
    if Slot >= 0 then begin
      Occupant := GetPlayer.FindStorageIndexByLocationAndSlot(Location, Slot);
      if Occupant >= 0 then GetPlayer.ShiftStorageSlotsAtOrAfter(Location, Slot);
      Entry.SlotIndex := Slot;
    end else begin
      Entry.SlotIndex := GetPlayer.FindNextStorageSlot(Entry.LocationOwner);
      Entry.SlotIndex := GetPlayer.FindNextStorageSlot(Entry.LocationOwner);
    end;
    ScriptItemsAct(event_move_item_to_storage, Entry.Item, Location, 0);
  end;
end;
{ @end $6D89E4 }

{ @routine $6D8B64 TShip_StoreLooseInventoryAt }
function TShip.StoreLooseInventoryAt(Location: TObject): Boolean;
var I: Integer; Good: TItemType; Item: TEquipment; Artefact: TArtefact; Goods: TGoods;
begin
  Result := False;
  if Location <> nil then
    if not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then begin
      for I := Inventory.Count - 1 downto 0 do begin
        Item := Inventory[I];
        if (Item.NoDropFlag <= 0) and (Item.EquippedFlag = 0) and (Item.ItemType <> item_hull) and GetPlayer.CanAccessStoredItem(Item) then begin
          MergeItemIntoPlayerStorage(Item, Location, -1);
          Inventory.Delete(I);
        end;
      end;
      for I := Artefacts.Count - 1 downto 0 do begin
        Artefact := Artefacts[I];
        if (Artefact.NoDropFlag <= 0) and (Artefact.EquippedFlag = 0) and GetPlayer.CanAccessStoredItem(Artefact) then begin
          AddItemToPlayerStorage(Artefact, Location, -1);
          Artefacts.Delete(I);
        end;
      end;
      for Good := item_food to item_narcotics do
        begin
          if (CargoGoods[Ord(Good)].Count <= 0) or not GetPlayer.CanAccessHoldGoods(Byte(Good)) then Continue;
          Goods := TGoods.Create;
          Goods.Init(Good, CargoGoods[Ord(Good)].Count);
          Goods.Cost := CargoGoods[Ord(Good)].TotalCost;
          MergeItemIntoPlayerStorage(Goods, Location, -1);
          CargoGoods[Ord(Good)].Count := 0;
          CargoGoods[Ord(Good)].TotalCost := 0;
        end;
      Result := True;
    end;
end;
{ @end $6D8B64 }

{ @routine $6D8CD8 TShip_RetrieveStoredItems }
function TShip.RetrieveStoredItems(Location: TObject): Boolean;
var I, J: Integer; Item: TItem; Entry: PStorageEntry; Stack: TCountableItem;
begin
  Result := False;
  if Location = nil then Exit;
  if (Location is TPlanet) and not ((Location as TPlanet).OwnerId in [owner_maloc..owner_gaal, owner_pirate]) then Exit;
  for I := GetPlayer.StorageEntries.Count - 1 downto 0 do begin
    Entry := GetPlayer.StorageEntries[I];
    if (Entry.LocationOwner <> Location) or (Entry.Item.ItemType = item_hull) then Continue;
    if not GetPlayer.CanAccessStoredItem(Entry.Item) then Continue;
    if (Entry.Item is TEquipment) and ((Entry.Item as TEquipment).EquippedFlag <> 0) then (Entry.Item as TEquipment).EquippedFlag := 0;
    if Entry.Item is TArtefact then Artefacts.Add(Entry.Item)
    else if Entry.Item is TCountableItem then begin
      Stack := nil;
      for J := 0 to Inventory.Count - 1 do begin
        Item := Inventory[J];
        if (Entry.Item as TCountableItem).CanMerge(Item) then begin Stack := Item as TCountableItem; Break; end;
      end;
      if Stack <> nil then begin
        Stack.Merge(Entry.Item as TCountableItem);
        Entry.Item.Free;
      end else Inventory.Add(Entry.Item);
    end else if Entry.Item is TGoods then begin
      Inc(CargoGoods[Ord(Entry.Item.ItemType)].Count, TGoods(Entry.Item).Quantity);
      Inc(CargoGoods[Ord(Entry.Item.ItemType)].TotalCost, Entry.Item.Cost);
      Entry.Item.Free;
    end else if Entry.Item is TEquipment then Inventory.Add(Entry.Item);
    GetPlayer.StorageEntries.Delete(I);
    Dispose(Entry);
  end;
  Result := True;
end;
{ @end $6D8CD8 }

{ @routine $6D902C TShip_AutoEquipArtefacts }
procedure TShip.AutoEquipArtefacts;
const
  EnergyFlags = [damage_flag_energy];
  SplinterFlags = [damage_flag_splinter];
var
  RemainingSlots: Integer;
  I, EnergyCount, SplinterCount: Integer;
  Item: TEquipment;
  HasEnergy, HasSplinter, HasMissiles: Boolean;

  // @nested $6D8F2C EquipType
  procedure EquipType(ArtefactType: TItemType); // @addr 0x006D8F2C @ida "void __usercall $name(unsigned __int8 ArtefactType@<al>, void *ParentFrame@<^0>);" @note "Caller-popped static link; remaining slots -4, ship -8."
  var
    I: Integer;
    Score, BestScore: Single;
    Candidate: TEquipment;
    Best: TEquipment;
  begin
    if RemainingSlots = 0 then Exit;
    while RemainingSlots > 0 do
    begin
      Best := nil;
      BestScore := 0;
      for I := 0 to Artefacts.Count - 1 do
      begin
        Candidate := Artefacts[I];
        if Candidate.EquippedFlag <> 0 then Continue;
        if not ((Candidate.ItemType = ArtefactType) or
          ((Candidate.ItemType in [item_custom_artefact..item_custom_artefact_no_wear]) and (TArtefactCustom(Candidate).CountsAsItemType = ArtefactType))) then Continue;
        if HasEquippedArtefactOfSameUseGroup(Candidate) and not Galaxy.AreDuplicateArtefactsEnabled then Continue;
        Score := EvaluateItem(Candidate, 3);
        if (Best = nil) or (Score > BestScore) then
        begin
          Best := Candidate;
          BestScore := Score;
        end;
      end;
      if Best = nil then Break;
      Best.Equip;
      Dec(RemainingSlots);
    end;
  end;
begin
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    Item.Unequip;
  end;
  RemainingSlots := GetSlotCountForItemType(item_custom_artefact);
  if RemainingSlots <= 0 then Exit;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if (Item.ItemType in [item_custom_artefact..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_defense_to_weapon_slot..artefact_extra_missiles]) and
       ((Item.NoDropFlag > 0) or ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> ''))) then
    begin
      Item.Equip;
      Dec(RemainingSlots);
      if RemainingSlots <= 0 then Exit;
    end;
  end;
  EnergyCount := CountWeaponsByDamageFlags(EnergyFlags);
  SplinterCount := CountWeaponsByDamageFlags(SplinterFlags);
  HasEnergy := EnergyCount > 0;
  HasSplinter := SplinterCount > 0;
  HasMissiles := False;
  for I := 1 to WeaponCount do
    if Weapons[I].GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
    begin
      HasMissiles := True;
      Break;
    end;
  I := 4;
  while (RemainingSlots > 0) and (I > 0) do
  begin
    EquipType(artefact_antigravity);
    EquipType(artefact_speed);
    EquipType(artefact_hull);
    EquipType(artefact_missile_defense);
    EquipType(artefact_energy_defense);
    EquipType(artefact_point_defense);
    if HasEnergy then EquipType(artefact_energy_pulse);
    if HasSplinter then EquipType(artefact_splinter);
    if HasMissiles then EquipType(artefact_extra_missiles);
    if GetDefGenerator <> nil then EquipType(artefact_defense);
    if GetRepairRobot <> nil then EquipType(artefact_repair_robot);
    if HasSplinter then EquipType(artefact_decelerate);
    if (GetDefGenerator <> nil) and HasEnergy then EquipType(artefact_defense_to_energy);
    if (GetCargoHook <> nil) and not (TypeId in [ship_dominator, ship_transport, ship_warrior]) then EquipType(artefact_cargo_hook);
    if not (TypeId in [ship_dominator, ship_transport, ship_warrior]) then EquipType(artefact_extra_loot);
    EquipType(artefact_nano_repair);
    EquipType(artefact_power);
    EquipType(artefact_radar);
    EquipType(artefact_scanner);
    EquipType(artefact_fuel);
    EquipType(artefact_health_protection);
    if GetSlotCount(slot_weapon) < 5 then EquipType(artefact_defense_to_weapon_slot);
    if (GetSlotCount(slot_defense_generator) > 0) and (GetSlotCount(slot_weapon) < 4) then EquipType(artefact_defense_slot_to_weapons);
    if GetSlotCount(slot_weapon) > WeaponCount then EquipType(artefact_weapon_to_speed);
    if (GetSlotCount(slot_afterburner) > 0) and (TypeId in [ship_ranger,ship_pirate..ship_warrior]) then EquipType(artefact_afterburner);
    if (GetEngine <> nil) and (GetEngine.JumpRange * 1.2 < HyperJumpArtefactRange) then EquipType(artefact_hyperjump);
    Dec(I);
  end;
  RefreshDerivedStats(True);
end;
{ @end $6D902C }

{ @routine $6D938C TShip_CalculateItemEffectiveness }
function TShip.CalculateItemEffectiveness(Item: TItem): Single;
var
  Equipment: TEquipment;
  CandidateHull: THull;
  TemporarilyUnequipped: Boolean;
  WeaponIndex, I: Integer;
  SavedTarget: TObject;
  Damage, WeaponRange, OtherRange, MinRange, DamageValue: Single;
  Weapon: TWeapon;
  DamageBonusKind: TEquipmentBonusKind;
  SavedChaoticRandom: Boolean;
  SavedWeapons: array[1..5] of TWeapon;
begin
  Result := 0;
  if (CurrentPlanet = nil) and (DockedTo = nil) and (Item is TEquipment) and
    ((Item as TEquipment).BrokenFlag <> 0) and (Item.ItemType <> item_engine) then Exit;
  if (Item is TEquipment) and not CanUseEquipmentTech(TEquipment(Item)) then Exit;
  if (CurrentPlanet = nil) and (DockedTo = nil) and (Item is TWeapon) and
    (TWeapon(Item).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) and (TWeapon(Item).Ammo <= 0) then Exit;
  if (Item is TEngine) and (TEngine(Item).Speed < 100) and not (Self is TRuins) then Exit;
  if not (Item.ItemType in [item_hull..item_custom_weapon]) then
  begin
    if Item is TArtefact then
      Result := 5000 / Max(1, Item.Weight) / Max(0.25, TEquipment(Item).GetFragilityFactor([]))
    else
      Result := Item.Cost / Max(1, Item.Weight);
    Exit;
  end;

  Equipment := Item as TEquipment;
  for I := 1 to 5 do SavedWeapons[I] := nil;
  SavedTarget := nil;
  TemporarilyUnequipped := (Equipment.EquippedFlag <> 0) and (Equipment.ItemType in WeaponItemTypes);
  if TemporarilyUnequipped then
  begin
    TemporarilyUnequipped := False;
    for WeaponIndex := 1 to WeaponCount do
      if Weapons[WeaponIndex] = Item then
      begin
        for I := 1 to 5 do SavedWeapons[I] := Weapons[I];
        SavedTarget := (Item as TWeapon).Target;
        UnequipSlot(Item.ItemType, WeaponIndex);
        TemporarilyUnequipped := True;
        Break;
      end;
  end;
  SavedChaoticRandom := Galaxy.CustomRules.ChaoticRandom;
  Galaxy.CustomRules.ChaoticRandom := False;
  if Equipment.ItemType in [item_hull..item_defense_generator] then
  begin
    case Equipment.ItemType of
      item_hull: begin
        CandidateHull := THull(Equipment);
        Result := EvaluateStatBonus(bonus_armor, CalculateHullArmor(CandidateHull));
        if GetHull <> CandidateHull then
          Result := Result +
            EvaluateStatBonus(bonus_radar_slots, CandidateHull.GetSlotCount(slot_radar) - GetHull.GetSlotCount(slot_radar)) +
            EvaluateStatBonus(bonus_scanner_slots, CandidateHull.GetSlotCount(slot_scanner) - GetHull.GetSlotCount(slot_scanner)) +
            EvaluateStatBonus(bonus_repair_robot_slots, CandidateHull.GetSlotCount(slot_repair_robot) - GetHull.GetSlotCount(slot_repair_robot)) +
            EvaluateStatBonus(bonus_cargo_hook_slots, CandidateHull.GetSlotCount(slot_cargo_hook) - GetHull.GetSlotCount(slot_cargo_hook)) +
            EvaluateStatBonus(bonus_defense_slots, CandidateHull.GetSlotCount(slot_defense_generator) - GetHull.GetSlotCount(slot_defense_generator)) +
            EvaluateStatBonus(bonus_weapon_slots, CandidateHull.GetSlotCount(slot_weapon) - GetHull.GetSlotCount(slot_weapon)) +
            EvaluateStatBonus(bonus_artefact_slots, CandidateHull.GetSlotCount(slot_artefact) - GetHull.GetSlotCount(slot_artefact)) +
            EvaluateStatBonus(bonus_afterburner_slots, CandidateHull.GetSlotCount(slot_afterburner) - GetHull.GetSlotCount(slot_afterburner)) +
            Round(EvaluateStatBonus(bonus_mass, CalculateEquippedMass(nil)) -
              EvaluateStatBonus(bonus_mass, CalculateEquippedMass(nil) + CandidateHull.CalculateMass - GetHull.CalculateMass));
      end;
      item_fuel_tanks: Result := EvaluateStatBonus(bonus_fuel_capacity, GetItemFuelTankCapacity(Equipment));
      item_engine: Result := EvaluateStatBonus(bonus_speed, CalculateEngineSpeed(TEngine(Equipment), InNormalSpace or not CanRepairEquipmentTech(Equipment))) +
        EvaluateStatBonus(bonus_jump_range, CalculateEngineJumpRange(TEngine(Equipment)));
      item_radar: Result := EvaluateStatBonus(bonus_radar_range, CalculateRadarRange(TRadar(Equipment)));
      item_scanner: if GetRadar <> nil then Result := EvaluateStatBonus(bonus_scanner_power, CalculateScannerPower(TScaner(Equipment)));
      item_repair_robot: Result := EvaluateStatBonus(bonus_repair_points, CalculateRepairPoints(TRepairRobot(Equipment)));
      item_cargo_hook: Result := EvaluateStatBonus(bonus_hook_power, CalculateCargoHookPower(TCargoHook(Equipment)));
      item_defense_generator: Result := EvaluateStatBonus(bonus_defense, Round(100 - CalculateDefGeneratorFactor(TDefGenerator(Equipment)) * 100));
    end;
  end
  else if Equipment.ItemType in WeaponItemTypes then
  begin
    Weapon := TWeapon(Equipment);
    WeaponRange := GetWeaponRange(Weapon);
    Damage := EstimateWeaponDamageAgainstTypicalDefense(Weapon);
    Damage := EvaluateWeaponDamage(Weapon, True, Damage);
    MinRange := WeaponRange;
    for WeaponIndex := 1 to WeaponCount do
    begin
      OtherRange := GetWeaponRange(Weapons[WeaponIndex]);
      if OtherRange < MinRange then MinRange := OtherRange;
    end;
    DamageBonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(Weapon.GetWeaponInfo.DamageFlags)].BonusKind;
    DamageValue := EvaluateStatBonus(DamageBonusKind, Round(Damage));
    Result := Result + DamageValue * (1 + EvaluateStatBonus(bonus_weapon_range, Round(WeaponRange)) * 0.002);
    Result := Result + EvaluateStatBonus(bonus_weapon_range, Round((WeaponRange + MinRange) * 0.5)) * 0.5;
    if ((CurrentPlanet <> nil) or (DockedTo <> nil)) and (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) then
      Result := Result * (RemapClamped(Weapon.AmmoCapacity, 30, 100, 0, 0.5) + RemapClamped(Weapon.AmmoCapacity, 0, 30, 0, 0.5));
  end
  else
  begin
    Result := 1;
    Galaxy.CustomRules.ChaoticRandom := SavedChaoticRandom;
    Exit;
  end;

  Result := Result + GetEquipmentEvaluationSynergyBonus(Equipment);
  Galaxy.CustomRules.ChaoticRandom := SavedChaoticRandom;
  if ((Equipment.ScriptItem <> nil) and (TScriptItem(Equipment.ScriptItem).Name <> '')) or (Equipment.NoDropFlag > 0) then
    Result := Max(Result, 0) * 10
  else if (Equipment.BrokenFlag <> 0) and (Equipment is TWeapon) and (TWeapon(Equipment).GetWeaponInfo.Availability = availability_not_sold_node_repair) then
    Result := 0
  else if (Equipment.BrokenFlag <> 0) and not CanRepairEquipmentTech(Equipment) then
    Result := 0
  else if not CanUseEquipmentTech(Equipment) then
    Result := 0;
  if TemporarilyUnequipped then
  begin
    EquipItem(Equipment);
    (Equipment as TWeapon).Target := SavedTarget;
    for I := 1 to 5 do Weapons[I] := SavedWeapons[I];
  end;
end;
{ @end $6D938C }

{ @routine $6D9D40 TShip_EstimateWeaponDamageAgainstTypicalDefense }
function TShip.EstimateWeaponDamageAgainstTypicalDefense(Item: TWeapon): Single;
var
  MinimumDamage, MaximumDamage, Level: Integer;
  ItemKind: TItemType;
  DefenseFactor, Armor: Single;
begin
  Result := 1;
  ItemKind := Item.ItemType;
  if ItemKind in WeaponItemTypes then
  begin
    if damage_flag_ignore_defenses in Item.GetDamageFlags then
    begin
      MinimumDamage := GetWeaponMinDamage(Item);
      MaximumDamage := GetWeaponMaxDamage(Item);
    end
    else
    begin
      Level := Min(Galaxy.TechLevel + 1, 8);
      DefenseFactor := 1 - DefGeneratorLevelFactors[Level];
      DefenseFactor := 1 - RemapClamped(Galaxy.TechLevel, 1, 8, 0.5, 1.2) * DefenseFactor;
      Armor := RemapClamped(Galaxy.TechLevel, 1, 8, 0.5, 1.5) * HullLevelStats[Level].Armor;
      MinimumDamage := Round(GetWeaponMinDamage(Item) * DefenseFactor - Armor);
      MaximumDamage := Round(GetWeaponMaxDamage(Item) * DefenseFactor - Armor);
    end;
    MinimumDamage := Max(1, MinimumDamage);
    MaximumDamage := Max(1, MaximumDamage);
    Result := RemapClamped(GetEffectiveSkillLevel(skill_accuracy), 0, 6,
      (3 * MinimumDamage + MaximumDamage) div 4, (MinimumDamage + 3 * MaximumDamage) div 4);
  end;
end;
{ @end $6D9D40 }

{ @routine $6D9F3C TShip_GetWeaponRange }
function TShip.GetWeaponRange(Weapon: TEquipment): Integer;
var
  Range, I, TemplateRange: Integer;
  Extra: PExtraSpecial;
begin
  if not (Weapon.ItemType in WeaponItemTypes) then
  begin
    Result := 0;
    Exit;
  end;
  Range := TWeapon(Weapon).Range + GetTotalStatBonus(bonus_weapon_range);
  if Weapon.ExtraSpecials <> nil then
    for I := 0 to Weapon.ExtraSpecials.Count - 1 do
    begin
      Extra := Weapon.ExtraSpecials[I];
      Inc(Range, MicroModuleTemplates[Extra.ModuleIndexPlusOne - 1].StatBonuses[bonus_weapon_range] * Extra.Count);
    end;
  if TWeapon(Weapon).GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then
  begin
    TemplateRange := TWeapon(Weapon).GetWeaponInfo.MissileRange;
    if (Self is TKling) and ((Self as TKling).KlingType = dominator_boss) then Range := Max(Range, TemplateRange)
    else if Self is TRuins then Range := Max(Range, TemplateRange)
    else if Galaxy.AreMaxRangeMissilesEnabled or (GetPlayer = Self) then Range := Min(GetRadarRange, Max(Range, TemplateRange))
    else Range := Min(GetRadarRange, Range);
  end;
  Result := Max(100, Range);
end;
{ @end $6D9F3C }

{ @routine $6DA070 TShip_CalculateHullArmor }
function TShip.CalculateHullArmor(Hull: THull): Integer;
var
  Bonus, Value: Integer;
begin
  if Hull.ItemType <> item_hull then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_armor);
  if GetHull <> Hull then
  begin
    Dec(Bonus, GetEquipmentStatBonus(bonus_armor, GetHull));
    Inc(Bonus, GetEquipmentStatBonus(bonus_armor, Hull));
  end;
  Value := Hull.Armor + Bonus;
  Value := Value + CountActiveArtefacts(artefact_hull) * (HullArtefactArmor + HullArtefactBoostArmor * Ord(CanBoostArtefact(artefact_hull, Hull, False)));
  Result := Max(0, Value);
end;
{ @end $6DA070 }

{ @routine $6DA0FC TShip_GetItemFuelTankCapacity }
function TShip.GetItemFuelTankCapacity(Item: TItem): Integer;
begin
  if Item.ItemType <> item_fuel_tanks then Result := 0
  else Result := TFuelTanks(Item).Capacity;
end;
{ @end $6DA0FC }

{ @routine $6DA10C TShip_CalculateEngineSpeed }
function TShip.CalculateEngineSpeed(Engine: TEngine; ApplyBrokenPenalty: Boolean): Integer;
var
  Bonus, Value, I: Integer;
begin
  if Engine.ItemType <> item_engine then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_speed);
  if (Engine.EquippedFlag = 0) and (Engine.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonus_speed, Engine));
  Value := Engine.Speed;
  if ApplyBrokenPenalty and (Engine.BrokenFlag <> 0) then Value := Round(Value * 0.6);
  Value := Value + CountActiveArtefacts(artefact_weapon_to_speed) * (WeaponToSpeedArtefactBonus + WeaponToSpeedArtefactBoost * Ord(CanBoostArtefact(artefact_weapon_to_speed, Engine, False)));
  Value := Max(Min(200, Engine.Speed), Value + Bonus);
  for I := 1 to CountActiveArtefacts(artefact_speed) do
    Value := Round(Value * (SpeedArtefactFactor + SpeedArtefactBoostFactor * ShortInt(CanBoostArtefact(artefact_speed, nil, False))));
  Result := Max(0, Value);
end;
{ @end $6DA10C }

{ @routine $6DA224 TShip_CalculateEngineJumpRange }
function TShip.CalculateEngineJumpRange(Engine: TEngine): Integer;
var
  Bonus, Value: Integer;
begin
  if Engine.ItemType <> item_engine then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_jump_range);
  if (Engine.EquippedFlag = 0) and (Engine.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonus_jump_range, Engine));
  Value := Engine.JumpRange;
  if not CanUseEquipmentTech(Engine) then Value := Value div 2;
  if CountActiveArtefacts(artefact_hyperjump) > 0 then
    Value := Max(Value, Round(Sqrt(CountActiveArtefacts(artefact_hyperjump)) *
      (HyperJumpArtefactRange + HyperJumpArtefactBoostRange * Ord(CanBoostArtefact(artefact_hyperjump, Engine, False)))));
  Result := Max(0, Value + Bonus);
end;
{ @end $6DA224 }

{ @routine $6DA330 TShip_CalculateRadarRange }
function TShip.CalculateRadarRange(Radar: TRadar): Integer;
var
  Bonus, Value: Integer;
begin
  if Radar.ItemType <> item_radar then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_radar_range);
  if (Radar.EquippedFlag = 0) and (Radar.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonus_radar_range, Radar));
  Value := Radar.Range;
  Value := Value + CountActiveArtefacts(artefact_radar) * (RadarArtefactRange + RadarArtefactBoostRange * Ord(CanBoostArtefact(artefact_radar, Radar, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $6DA330 }

{ @routine $6DA3A8 TShip_CalculateScannerPower }
function TShip.CalculateScannerPower(Scanner: TScaner): Integer;
var
  Bonus, Value: Integer;
begin
  if Scanner.ItemType <> item_scanner then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_scanner_power);
  if (Scanner.EquippedFlag = 0) and (Scanner.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonus_scanner_power, Scanner));
  Value := Scanner.ScanPower;
  Value := Value + CountActiveArtefacts(artefact_scanner) * (ScannerArtefactPower + ScannerArtefactBoostPower * Ord(CanBoostArtefact(artefact_scanner, Scanner, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $6DA3A8 }

{ @routine $6DA424 TShip_CalculateRepairPoints }
function TShip.CalculateRepairPoints(RepairRobot: TRepairRobot): Integer;
var
  Bonus, Value: Integer;
begin
  if RepairRobot.ItemType <> item_repair_robot then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_repair_points);
  if (RepairRobot.EquippedFlag = 0) and (RepairRobot.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonus_repair_points, RepairRobot));
  Value := RepairRobot.RepairPoints;
  Value := Value + CountActiveArtefacts(artefact_repair_robot) * (DroidArtefactRepair + DroidArtefactBoostRepair * Ord(CanBoostArtefact(artefact_repair_robot, RepairRobot, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $6DA424 }

{ @routine $6DA4A0 TShip_CalculateCargoHookPower }
function TShip.CalculateCargoHookPower(CargoHook: TCargoHook): Integer;
var
  Bonus, Value: Integer;
begin
  if CargoHook.ItemType <> item_cargo_hook then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonus_hook_power);
  if (CargoHook.EquippedFlag = 0) and (CargoHook.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonus_hook_power, CargoHook));
  Value := CargoHook.PickupPower;
  Value := Value + CountActiveArtefacts(artefact_cargo_hook) * (CargoHookArtefactPower + CargoHookArtefactBoostPower * Ord(CanBoostArtefact(artefact_cargo_hook, CargoHook, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $6DA4A0 }

{ @routine $6DA518 TShip_CalculateDefGeneratorFactor }
function TShip.CalculateDefGeneratorFactor(DefGenerator: TDefGenerator): Single;
var
  Percent, I: Integer;
  Factor: Single;
begin
  if DefGenerator.ItemType <> item_defense_generator then begin Result := 0; Exit; end;
  Percent := GetTotalStatBonus(bonus_defense);
  if (DefGenerator.EquippedFlag = 0) and (DefGenerator.SpecialModuleIndex <> 0) then
    Inc(Percent, GetEquipmentStatBonus(bonus_defense, DefGenerator));
  Factor := DefGenerator.DamageFactor;
  if Percent <> 0 then Factor := Factor - (1 - DefensePercentToDamageFactor(Percent));
  Factor := Factor - CountActiveArtefacts(artefact_defense) * (DefenseArtefactBonus + DefenseArtefactBoost * ShortInt(CanBoostArtefact(artefact_defense, DefGenerator, False)));
  for I := 1 to CountActiveArtefacts(artefact_defense_to_energy) do
    Factor := Min(1, Factor + (1 - Factor) * (DefenseToEnergyPenalty + DefenseToEnergyBoostPenalty * ShortInt(CanBoostArtefact(artefact_defense_to_energy, DefGenerator, False))));
  if (CountActiveArtefacts(artefact_defense_to_weapon_slot) > 0) and not CanBoostArtefact(artefact_defense_to_weapon_slot, DefGenerator, False) then
    for I := 1 to CountActiveArtefacts(artefact_defense_to_weapon_slot) do Factor := Min(1, Factor + (1 - Factor) * DefenseToWeaponPenalty);
  Result := Min(1, Max(0.01, Factor));
end;
{ @end $6DA518 }

{ @routine $6DA7CC TShip_GetEquipmentEvaluationSynergyBonus }
function TShip.GetEquipmentEvaluationSynergyBonus(Item: TEquipment): Single;
var
  Positive, Nonpositive: Single;
  DamageBonus: Single;
  Module: PMicroModuleTemplate;
  I, ModuleIndex: Integer;
  ItemType: TItemType;
  // @nested $6DA790 AccumulateEquipmentBonus
  procedure AccumulateEquipmentBonus(Value: Single); // @addr 0x006DA790 @calls "0x006DA84D,0x006DA870,0x006DA88D,0x006DA8BB,0x006DA8E9,0x006DA917,0x006DA98A,0x006DA9A7,0x006DAA2B,0x006DAA5F,0x006DAB51,0x006DAB7A,0x006DAB97,0x006DABB4,0x006DABD1,0x006DABEE,0x006DAC0E,0x006DAC3B,0x006DAC63,0x006DAC85,0x006DACB8,0x006DACEB,0x006DAD1E,0x006DAD9A,0x006DADBC,0x006DAE4B,0x006DAE84,0x006DAF85,0x006DAFB3,0x006DAFD5,0x006DAFF7,0x006DB019,0x006DB03B,0x006DB05D,0x006DB07A,0x006DB0B7" @ida "void __usercall $name(float Value@<^0>, void *ParentFrame@<^4>);" @stackpop 0x4 @note "Adds positive and nonpositive values to separate Single accumulators at ParentFrame-4/-8."
  begin
    if Value > 0 then Positive := Positive + Value
    else Nonpositive := Nonpositive + Value;
  end;
begin
  Result := 0;
  if Item.SpecialModuleIndex <> 0 then
  begin
    ModuleIndex := Item.SpecialModuleIndex - 1;
    if not IsMicroModuleRaciallyRestricted(ModuleIndex) then
    begin
      Positive := 0;
      Nonpositive := 0;
      ItemType := Item.ItemType;
      if (Item.ExtraSpecials = nil) or (Item.ExtraSpecials.Count = 0) then
      begin
        Module := @MicroModuleTemplates[ModuleIndex];
        if ItemType <> item_hull then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_armor, Module.StatBonuses[bonus_armor]));
        if ItemType <> item_engine then
        begin
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_speed, Module.StatBonuses[bonus_speed]));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_jump_range, Module.StatBonuses[bonus_jump_range]));
        end;
        if (GetRadar <> nil) and (ItemType <> item_radar) then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_radar_range, Module.StatBonuses[bonus_radar_range]));
        if (GetScanner <> nil) and (ItemType <> item_scanner) then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_scanner_power, Module.StatBonuses[bonus_scanner_power]));
        if (GetRepairRobot <> nil) and (ItemType <> item_repair_robot) then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_repair_points, Module.StatBonuses[bonus_repair_points]));
        if (GetCargoHook <> nil) and (ItemType <> item_cargo_hook) then
        begin
          // Native expression adds raw hook power to the evaluated bonus before subtracting its evaluation.
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_hook_power, Module.StatBonuses[bonus_hook_power]) + CalculateCargoHookPower(GetCargoHook) - EvaluateStatBonus(bonus_hook_power, CalculateCargoHookPower(GetCargoHook)));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_hook_range, Module.StatBonuses[bonus_hook_range]));
        end;
        if (GetDefGenerator <> nil) and (ItemType <> item_defense_generator) then
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_defense, Module.StatBonuses[bonus_defense] + Integer(Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100))) -
            EvaluateStatBonus(bonus_defense, Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_weapon_range, Module.StatBonuses[bonus_weapon_range]) * CountEquippedWeapons);
        if not (ItemType in WeaponItemTypes) then
          for I := 1 to CountEquippedWeapons do
          begin
            DamageBonus := 0;
            if damage_flag_energy in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonus_energy_damage, Module.StatBonuses[bonus_energy_damage]);
            if damage_flag_splinter in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonus_splinter_damage, Module.StatBonuses[bonus_splinter_damage]);
            if damage_flag_missile in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonus_missile_damage, Module.StatBonuses[bonus_missile_damage]);
            if (DamageBonus > 0.001) or (DamageBonus < -0.001) then
              DamageBonus := EvaluateWeaponDamage(Weapons[I], False, DamageBonus);
            AccumulateEquipmentBonus(DamageBonus);
          end;
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_accuracy, Module.StatBonuses[bonus_accuracy]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_maneuverability, Module.StatBonuses[bonus_maneuverability]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_technical, Module.StatBonuses[bonus_technical]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_trading, Module.StatBonuses[bonus_trading]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_charisma, Module.StatBonuses[bonus_charisma]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_leadership, Module.StatBonuses[bonus_leadership]));
      end
      else
      begin
        if ItemType <> item_hull then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_armor, Item.GetStatBonus(bonus_armor)));
        if ItemType <> item_engine then
        begin
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_speed, Item.GetStatBonus(bonus_speed)));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_jump_range, Item.GetStatBonus(bonus_jump_range)));
        end;
        if (GetRadar <> nil) and (ItemType <> item_radar) then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_radar_range, Item.GetStatBonus(bonus_radar_range)));
        if (GetScanner <> nil) and (ItemType <> item_scanner) then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_scanner_power, Item.GetStatBonus(bonus_scanner_power)));
        if (GetRepairRobot <> nil) and (ItemType <> item_repair_robot) then AccumulateEquipmentBonus(EvaluateStatBonus(bonus_repair_points, Item.GetStatBonus(bonus_repair_points)));
        if (GetCargoHook <> nil) and (ItemType <> item_cargo_hook) then
        begin
          // Native expression adds raw hook power to the evaluated bonus before subtracting its evaluation.
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_hook_power, Item.GetStatBonus(bonus_hook_power)) + CalculateCargoHookPower(GetCargoHook) - EvaluateStatBonus(bonus_hook_power, CalculateCargoHookPower(GetCargoHook)));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_hook_range, Item.GetStatBonus(bonus_hook_range)));
        end;
        if (GetDefGenerator <> nil) and (ItemType <> item_defense_generator) then
          AccumulateEquipmentBonus(EvaluateStatBonus(bonus_defense, Item.GetStatBonus(bonus_defense) + Integer(Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100))) -
            EvaluateStatBonus(bonus_defense, Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_weapon_range, Item.GetStatBonus(bonus_weapon_range)) * CountEquippedWeapons);
        if not (ItemType in WeaponItemTypes) then
          for I := 1 to CountEquippedWeapons do
          begin
            DamageBonus := 0;
            if damage_flag_energy in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonus_energy_damage, Item.GetStatBonus(bonus_energy_damage));
            if damage_flag_splinter in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonus_splinter_damage, Item.GetStatBonus(bonus_splinter_damage));
            if damage_flag_missile in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonus_missile_damage, Item.GetStatBonus(bonus_missile_damage));
            if (DamageBonus > 0.001) or (DamageBonus < -0.001) then
              DamageBonus := EvaluateWeaponDamage(Weapons[I], False, DamageBonus);
            AccumulateEquipmentBonus(DamageBonus);
          end;
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_accuracy, Item.GetStatBonus(bonus_accuracy)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_maneuverability, Item.GetStatBonus(bonus_maneuverability)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_technical, Item.GetStatBonus(bonus_technical)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_trading, Item.GetStatBonus(bonus_trading)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_charisma, Item.GetStatBonus(bonus_charisma)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonus_leadership, Item.GetStatBonus(bonus_leadership)));
        AccumulateEquipmentBonus(Item.GetStatBonus(bonus_ai_item_value));
      end;
      AccumulateEquipmentBonus(EvaluateStatBonus(bonus_mass, CalculateEquippedMass(Item)) -
        EvaluateStatBonus(bonus_mass, CalculateEquippedMass(nil)));
      if Item.MicroModuleIndex <> 0 then
      begin
        Positive := Positive + Round(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_acryn_effect] * Positive * 0.0001);
        Nonpositive := Nonpositive + Round(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonus_acryn_penalty] * Nonpositive * 0.0001);
      end;
      Result := Positive + Nonpositive;
    end;
  end;
end;
{ @end $6DA7CC }

{ @routine $6DB168 TShip_GetWeaponArtefactDamageFactor }
function TShip.GetWeaponArtefactDamageFactor(Weapon: TWeapon): Single;
const
  EnergyDamageFlags = [damage_flag_energy];
var
  Flags: TDamageFlagSet;
  I: Integer;
begin
  Result := 1;
  Flags := Weapon.GetWeaponInfo.DamageFlags;
  if damage_flag_energy in Flags then
    for I := 1 to CountActiveArtefacts(artefact_energy_pulse) do
      Result := Result * (1 + (EnergyPulseArtefactFactor + ShortInt(CanBoostArtefact(artefact_energy_pulse, Weapon, False)) * EnergyPulseArtefactBoostFactor) * EnergyPulseArtefactChance);
  if (CountActiveArtefacts(artefact_defense_to_energy) > 0) and (damage_flag_energy in Flags) and (GetDefGenerator <> nil) then
    Result := Result * (1 + (
      (CountWeaponsByDamageFlags(EnergyDamageFlags) + 1) * RemapClamped(
        CountWeaponsByDamageFlags(EnergyDamageFlags) + 1, 1, 5,
        DefenseToEnergyUpperFactor + ShortInt(CanBoostArtefact(artefact_defense_to_energy, Weapon, False)) * DefenseToEnergyUpperBoost,
        DefenseToEnergyMinimumFactor + ShortInt(CanBoostArtefact(artefact_defense_to_energy, Weapon, False)) * DefenseToEnergyMinimumBoost) -
      CountWeaponsByDamageFlags(EnergyDamageFlags) * RemapClamped(
        CountWeaponsByDamageFlags(EnergyDamageFlags), 1, 5,
        DefenseToEnergyUpperFactor + ShortInt(CanBoostArtefact(artefact_defense_to_energy, Weapon, False)) * DefenseToEnergyUpperBoost,
        DefenseToEnergyMinimumFactor + ShortInt(CanBoostArtefact(artefact_defense_to_energy, Weapon, False)) * DefenseToEnergyMinimumBoost) - 1) * CountActiveArtefacts(artefact_defense_to_energy));
  if damage_flag_splinter in Flags then
    for I := 1 to CountActiveArtefacts(artefact_splinter) do
      Result := Result * (SplinterArtefactFactor + ShortInt(CanBoostArtefact(artefact_splinter, Weapon, False)) * SplinterArtefactBoostFactor);
end;
{ @end $6DB168 }

{ @routine $6DB3F4 TShip_UpdateSpeedTrackingMetrics }
procedure TShip.UpdateSpeedTrackingMetrics;
begin
  SmoothedSpeed := (29 * SmoothedSpeed + Speed) div 30;
  if (EnemyShip <> nil) and EnemyShip.InNormalSpace and (EnemyShip.CurrentStar = CurrentStar) then
    SmoothedEnemySpeed := (29 * SmoothedEnemySpeed + EnemyShip.Speed) div 30;
end;
{ @end $6DB3F4 }

{ @routine $6DB45C TShip_RefreshEquipmentEvaluationMetrics }
procedure TShip.RefreshEquipmentEvaluationMetrics;
var
  I, EquippedCount: Integer;
  Item: TEquipment;
  Effectiveness: Single;
  FreeCapacity: Integer;
begin
  if SmoothedWealth = 0 then
    SmoothedWealth := Wealth
  else
    SmoothedWealth := (Wealth + SmoothedWealth) div 2;
  if SmoothedMoneyFraction = 0 then
    SmoothedMoneyFraction := Money / Max(1, Wealth)
  else
    SmoothedMoneyFraction := (Money / Max(1, Wealth) + 4 * SmoothedMoneyFraction) * 0.2;
  EquippedCount := 0;
  Effectiveness := 0;
  FreeCapacity := GetHull.Weight;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = item_hull) or (Item.EquippedFlag = 0) then Continue;
    Inc(EquippedCount);
    Effectiveness := Effectiveness + CalculateItemEffectiveness(Item);
    Dec(FreeCapacity, Item.Weight);
  end;
  Effectiveness := Effectiveness / Max(1, EquippedCount);
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if Item.EquippedFlag = 0 then Continue;
    Dec(FreeCapacity, Item.Weight);
  end;
  if SmoothedEquipmentEffectiveness = 0 then
    SmoothedEquipmentEffectiveness := Effectiveness
  else
    SmoothedEquipmentEffectiveness := (4 * SmoothedEquipmentEffectiveness + Effectiveness) * 0.2;
  if SmoothedFreeCapacityFraction = 0 then
    SmoothedFreeCapacityFraction := Max(0.0, FreeCapacity / Max(1, GetHull.Weight))
  else
    SmoothedFreeCapacityFraction := (4 * SmoothedFreeCapacityFraction + Max(0.0, FreeCapacity / Max(1, GetHull.Weight))) * 0.2;
end;
{ @end $6DB45C }

{ @routine $6DB708 TShip_EvaluateItem }
function TShip.EvaluateItem(Item: TItem; PriceMode: Byte): Single;
begin
  Result := AdjustItemEvaluation(Item, PriceMode, CalculateItemEffectiveness(Item));
end;
{ @end $6DB708 }

{ @routine $6DB73C TShip_AdjustItemEvaluation }
function TShip.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
const
  NoFlags = [];
var
  MoneyPenalty, EffectivenessScale, WeightPenalty, FragilityScale: Single;
  Price: Integer;
  DesiredFreeFraction, DesiredMoneyFraction, HullValueScale: Single;
begin
  FragilityScale := 1;
  if Item.ItemType in [item_fuel_tanks, item_radar, item_scanner] then
    FragilityScale := FragilityScale * 0.5;
  DesiredMoneyFraction := 0.2;
  HullValueScale := 1;
  DesiredFreeFraction := Max(0.01, Min(0.99, GetDesiredCargoFreeSpace / Max(100, GetHull.Weight)));
  MoneyPenalty := Sqr((1 / Max(0.01, SmoothedMoneyFraction) - 1) / (1 / DesiredMoneyFraction - 1)) /
    Max(SmoothedWealth * 0.05, 1000);
  EffectivenessScale := 2 / Max(10, SmoothedEquipmentEffectiveness);
  WeightPenalty := Sqr((1 / Max(0.01, SmoothedFreeCapacityFraction) - 1) / (1 / DesiredFreeFraction - 1)) /
    Max(10, GetHull.Weight * 0.1);
  Effectiveness := CalculateItemEffectiveness(Item);
  case PriceMode of
    4: Price := Item.Cost;
    3: Price := Item.CalculateResaleValue(GetEffectiveSkillLevel(skill_trading));
    1: Price := -Item.Cost;
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
{ @end $6DB73C }

{ @routine $6DBB78 TShip_EvaluateStatBonus }
function TShip.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonus_armor: Result := Value * 200;
    bonus_fuel_capacity: Result := Value * 2.5;
    bonus_speed: Result := Value;
    bonus_jump_range: Result := Value * 25;
    bonus_radar_range: Result := Value * 0.05;
    bonus_scanner_power: Result := Value * 5 + Value * 20 * CountWeaponsByDamageFlags(ScannerFlags);
    bonus_repair_points: Result := Value * 10 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonus_hook_power: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.0;
    bonus_defense: Result := Value * 5 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonus_energy_damage: Result := Value * 10;
    bonus_splinter_damage: Result := Value * 10;
    bonus_missile_damage: Result := Value * 10 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonus_weapon_range: Result := Value * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonus_hook_range: Result := Value * 0.1;
    bonus_mass: Result := RemapClamped(Value, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 5000;
    bonus_radar_slots:
      if (GetSlotCount(slot_radar) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind] - SlotBonusEvaluationWeights[bonus_weapon_slots] * CountMissileWeapons
      else if (GetSlotCount(slot_radar) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonus_scanner_slots:
      if (GetSlotCount(slot_scanner) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * SlotBonusEvaluationWeights[bonus_weapon_slots]
      else if (GetSlotCount(slot_scanner) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonus_repair_robot_slots:
      if (GetSlotCount(slot_repair_robot) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(slot_repair_robot) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonus_cargo_hook_slots:
      if (GetSlotCount(slot_cargo_hook) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(slot_cargo_hook) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonus_defense_slots:
      if (GetSlotCount(slot_defense_generator) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(slot_defense_generator) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonus_weapon_slots:
      begin
        if (GetSlotCount(slot_weapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(slot_weapon)) * SlotBonusEvaluationWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(slot_weapon)) * SlotBonusEvaluationWeights[BonusKind];
        if CountEquippedWeapons > Max(Value + GetSlotCount(slot_weapon), 1) then
          Result := Result - (SlotBonusEvaluationWeights[BonusKind] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(slot_weapon)));
      end;
    bonus_artefact_slots:
      begin
        if (GetSlotCount(slot_artefact) < DefaultHullSlotCounts[slot_artefact]) and (Value > 0) then
          Result := Min(Value, DefaultHullSlotCounts[slot_artefact] - GetSlotCount(slot_artefact)) * SlotBonusEvaluationWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(slot_artefact)) * SlotBonusEvaluationWeights[BonusKind];
        if Artefacts <> nil then
          if Artefacts.Count > Max(Value + GetSlotCount(slot_artefact), 0) then Result := -1000;
      end;
    bonus_afterburner_slots:
      if (GetSlotCount(slot_afterburner) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(slot_afterburner) = 1) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind];
    bonus_accuracy..bonus_leadership:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), Value) * SkillBonusEvaluationWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) > 6) then
          Result := Result + (SkillBonusEvaluationWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), -Value) * -SkillBonusEvaluationWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) < 0) then
          Result := Result + (SkillBonusEvaluationWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]));
      end;
  else Result := 0;
  end;
end;
{ @end $6DBB78 }

{ @routine $6DC5E4 TShip_EvaluateWeaponDamage }
function TShip.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
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
  if damage_flag_equipment_wear in Flags then Result := Result * 1.05;
  if damage_flag_life_steal in Flags then Result := Result * 1.5;
  if damage_flag_shock in Flags then Result := Result * (1.1 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  if damage_flag_acid in Flags then Result := Result * 1.1;
  if damage_flag_magnetic in Flags then Result := Result * 1.1;
  StatusFactor := 1;
  if damage_flag_scanner_bonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if damage_flag_bonus_to_damaged_hull in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if damage_flag_engine_wear in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.05);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if damage_flag_equipment_wear in Flags then Result := Result + 1;
    if damage_flag_engine_slow in Flags then Result := Result + 2;
    if (CountActiveArtefacts(artefact_decelerate) > 0) and (damage_flag_splinter in Flags) then
      Result := Result + 5 + 5 * Ord(CanBoostArtefact(artefact_decelerate, Weapon, False) or (CountActiveArtefacts(artefact_decelerate) > 1));
    Result := Result + CountWeaponsByDamageFlags(AcidFlags) * Weapon.GetShotCount;
    if damage_flag_acid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
    if damage_flag_extra_loot in Flags then Result := Result + ScannerFactor * 5;
    if damage_flag_force_cargo_drop in Flags then Result := Result + ScannerFactor * 5;
    if damage_flag_engine_wear in Flags then Result := Result + ScannerFactor * 1;
    if damage_flag_weapon_block in Flags then Result := Result + ScannerFactor * 5;
    if damage_flag_droid_block in Flags then Result := Result + ScannerFactor * 5;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case Weapon.GetWeaponInfo.ShotType of
    shot_rocket: Result := Result * 1.0 * Weapon.GetShotCount * (1 + StatusFactor);
    shot_missile: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    shot_torpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor);
    shot_chain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    shot_splash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 * SpeedFactor + StatusFactor);
    shot_explode_on_kill: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.1 * 0.01 * SpeedFactor + StatusFactor);
    shot_area_damage: Result := Result * (1 + Weapon.Range * 1.3 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
end;
{ @end $6DC5E4 }

{ @routine $6DCBEC TShip_EvaluateMicroModuleGain }
function TShip.EvaluateMicroModuleGain(Item: TEquipment; ModuleIndex: Integer): Single;
var
  CopyItem: TEquipment;
  SavedNextId: Cardinal;
  Buffer: TBufEC;
  WithModule: Single;
begin
  Buffer := TBufEC.Create;
  SavedNextId := Galaxy.NextItemId;
  CopyItem := TEquipment(CreateItemByType(Item.ItemType));
  Item.SaveToBuffer(Buffer);
  Buffer.SetPosition(0);
  LoadedSaveVersion := CurrentSaveVersion;
  CopyItem.LoadFromBuffer(Buffer, Galaxy);
  ApplyMicroModule(ModuleIndex, CopyItem);
  WithModule := EvaluateItem(CopyItem, 1);
  Result := WithModule - EvaluateItem(Item, 1);
  CopyItem.Free;
  Galaxy.NextItemId := SavedNextId;
  Buffer.Free;
end;
{ @end $6DCBEC }

{ @routine $6DCD88 TShip_AutoApplyMicroModules }
procedure TShip.AutoApplyMicroModules;
var
  Candidate: TEquipment;
  Module: TEquipment;
  I, J: Integer;
  Best: TEquipment;
  Changed: Boolean;
  Score, BestScore: Single;

  // @nested $6DCCB0 FitsMicroModuleCapacity
  function FitsMicroModuleCapacity: Boolean; // @addr 0x006DCCB0 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; equipment -4, module item -8, ship -12."
  begin
    if Candidate.ItemType <> item_hull then
      Result := Candidate.Weight * (MicroModuleTemplates[(Module as TMicroModule).MicroModuleIndex - 1].SizePercent - 100) * 0.01 <= CargoFreeSpace + 1
    else
      Result := -Candidate.Weight * (MicroModuleTemplates[(Module as TMicroModule).MicroModuleIndex - 1].SizePercent - 100) * 0.01 <= CargoFreeSpace + 1;
  end;
begin
  Changed := True;
  while Changed do
  begin
    Changed := False;
    for I := 1 to Inventory.Count - 1 do
    begin
      Module := Inventory[I];
      if Module is TMicroModule then
      begin
        Best := nil;
        BestScore := 0;
        for J := 0 to Inventory.Count - 1 do
        begin
          Candidate := Inventory[J];
          if (Module as TMicroModule).CanInstallOn(Candidate) and ((Candidate.EquippedFlag <> 0) or (Candidate.ItemType = item_hull)) and FitsMicroModuleCapacity then
          begin
            Score := EvaluateMicroModuleGain(Candidate, (Module as TMicroModule).MicroModuleIndex - 1);
            if Score > BestScore then
            begin
              BestScore := Score;
              Best := Candidate;
            end;
          end;
        end;
        if Best <> nil then
        begin
          Changed := True;
          ApplyMicroModule((Module as TMicroModule).MicroModuleIndex - 1, Best);
          Inventory.Delete(Inventory.IndexOf(Module));
          Module.Free;
          RefreshDerivedStats(True);
          Break;
        end;
        for J := 0 to Inventory.Count - 1 do
        begin
          Candidate := Inventory[J];
          if (Module as TMicroModule).CanInstallOn(Candidate) and (Candidate.EquippedFlag = 0) and (Candidate.ItemType <> item_hull) and FitsMicroModuleCapacity then
          begin
            Score := EvaluateMicroModuleGain(Candidate, (Module as TMicroModule).MicroModuleIndex - 1);
            if Score > BestScore then
            begin
              BestScore := Score;
              Best := Candidate;
            end;
          end;
        end;
        if Best <> nil then
        begin
          Changed := True;
          ApplyMicroModule((Module as TMicroModule).MicroModuleIndex - 1, Best);
          Inventory.Delete(Inventory.IndexOf(Module));
          Module.Free;
          RefreshDerivedStats(True);
          Break;
        end;
      end;
      if Changed then Break;
    end;
  end;
end;
{ @end $6DCD88 }

{ @routine $6DD014 TShip_AutoEquipInventory }
procedure TShip.AutoEquipInventory;
var
  I: Integer;
  Item, Best: TEquipment;
  Score, BestScore: Single;
  Kind: TItemType;
  PriceMode: Byte;
  BestProtected, ItemProtected: Boolean;
begin
  if IsDocked or (CargoFreeSpace < 0) then PriceMode := 3 else PriceMode := 0;
  if Self is TTranclucator then PriceMode := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if Item is TWeapon then Item.Unequip
    else if (Item.ItemType in UtilityEquipmentTypes) and
      (EquipmentCache.Slots[Item.ItemType] <> Item) then Item.Unequip;
  end;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  if CountCarriedEquipmentByType(WeaponCategoryItemType) < GetSlotCount(slot_weapon) then
  begin
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.ItemType in WeaponItemTypes then EquipItem(Item as TWeapon);
    end;
  end
  else
    for I := 1 to GetSlotCount(slot_weapon) do EquipItem(SelectBestUnequippedWeapon);
  for Kind := item_fuel_tanks to item_defense_generator do
  begin
    if EquipmentCache.Slots[Kind] <> nil then EquipmentCache.Slots[Kind].Unequip;
    if GetSlotCountForItemType(Kind) <= 0 then Continue;
    EquipmentCache.Slots[Kind] := nil;
    Best := nil;
    BestScore := 0;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.ItemType <> Kind then Continue;
      BestProtected := (Best <> nil) and ((Best.NoDropFlag > 0) or
        ((Best.ScriptItem <> nil) and (TScriptItem(Best.ScriptItem).Name <> '')));
      ItemProtected := (Item.NoDropFlag > 0) or
        ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> ''));
      if BestProtected then
        if not ItemProtected then Continue;
      Score := EvaluateItem(Item, PriceMode);
      if (Kind = item_fuel_tanks) and (Best <> nil) and (GetJumpDestinationDistance <= (Best as TFuelTanks).Fuel) and
        (GetJumpDestinationDistance > (Item as TFuelTanks).Fuel) then Continue;
      if ((Score >= 0) or (Kind in [item_fuel_tanks..item_engine]) or
        ((Kind = item_cargo_hook) and (TypeId in [ship_ranger, ship_pirate]) and (GetSlotCount(slot_cargo_hook) > 0)) or
        (Item.NoDropFlag > 0) or (Item.ScriptItem <> nil) or
        ((CargoFreeSpace >= 0) and (PriceMode <> 0) and (EvaluateItem(Item, 0) >= 0))) and
        ((Best = nil) or (Score > BestScore) or ((Score = BestScore) and (Best.Weight > Item.Weight)) or
        (ItemProtected and not BestProtected)) then
      begin
        BestScore := Score;
        Best := Item;
      end;
    end;
    if Best <> nil then EquipItem(Best);
  end;
  RefreshDerivedStats(True);
end;
{ @end $6DD014 }

{ @routine $6DD374 TShip_DropCargoUntilNotOverloaded }
procedure TShip.DropCargoUntilNotOverloaded;
var
  Count: Integer;
  Item: TEquipment;
  Artefact: TArtefact;
  Good: Byte;
  ItemValue, ArtefactValue, GoodsValue: Double;
  I: Integer;
  Candidate: TItem;
  CanDrop: Boolean;
begin
  CanDrop := InNormalSpace and not (TypeId in [station_ranger_center..station_custom]);
  if (CargoFreeSpace < 0) and NoDrop and CanDrop then
  begin
    if ScriptShip = nil then
      AppendLogLineThreadSafe(AnsiString('Warning! Ship ' + GetFullName(' ') + ' is overloaded but cant drop anything with NoDrop flag'))
    else
      AppendLogLineThreadSafe(AnsiString('Warning! Ship ' + GetFullName(' ') + ' (' + TScriptShip(ScriptShip).Script.ScriptFileName + ' ' + TScriptShip(ScriptShip).State.Name + ') is overloaded but cant drop anything with NoDrop flag'));
  end
  else
    while CargoFreeSpace < 0 do
    begin
      if NoDrop then Item := nil else Item := TEquipment(SelectLeastValuableInventoryItem);
      if Item <> nil then ItemValue := Item.Cost / Item.Weight else ItemValue := 0;
      if NoDrop then Artefact := nil else Artefact := SelectLeastValuableArtefact;
      if Artefact <> nil then
      begin
        ArtefactValue := Artefact.Cost / Artefact.Weight;
        if Artefact.EquippedFlag <> 0 then ArtefactValue := ArtefactValue * 10;
      end
      else ArtefactValue := 0;
      if SelectCheapestCargoGood < 255 then
      begin
        Good := SelectCheapestCargoGood;
        Count := Min(Abs(CargoFreeSpace), CargoGoods[Good].Count);
        GoodsValue := GoodsMarket[Good].AveragePrice * Count;
        if not ((Item <> nil) and (Item.Cost < GoodsValue)) and
          not ((Artefact <> nil) and (Artefact.Cost < GoodsValue)) then
        begin
          if CanDrop then DropGoodsIntoSpace(Good, Count) else SellGoodsToLocation(Good, Count);
          Continue;
        end;
      end
      else
      begin
        Count := 0;
        GoodsValue := 0;
        Good := 0;
      end;
      if (Artefact <> nil) and (ArtefactValue <= ItemValue) then begin
        if CanDrop then DropCarriedArtefactAsMovingLoot(Artefact) else LiquidateArtefact(Artefact);
        Continue;
      end;
      if (Item <> nil) and (Item.EquippedFlag = 0) and ((Count = 0) or (Item.Cost < GoodsValue)) then begin
        if CanDrop and (Item is TCountableItem) and (Item.Weight + CargoFreeSpace > 0) then
        begin
          Item := (Item as TCountableItem).Split(-CargoFreeSpace);
          Inventory.Add(Item);
          DropCarriedItemAsMovingLoot(Item);
        end
        else if CanDrop then DropCarriedItemAsMovingLoot(Item) else LiquidateInventoryItem(Item);
        Continue;
      end;
      if Count > 0 then begin
        if CanDrop then DropGoodsIntoSpace(Good, Count) else SellGoodsToLocation(Good, Count);
        Continue;
      end;
      if Artefact <> nil then begin
        if CanDrop then DropCarriedArtefactAsMovingLoot(Artefact) else LiquidateArtefact(Artefact);
        Continue;
      end;
      if (Item <> nil) and not IsEssentialInventoryItem(Item) then begin
        if CanDrop then DropCarriedItemAsMovingLoot(Item) else LiquidateInventoryItem(Item);
        Continue;
      end;
      for I := 1 to Inventory.Count - 1 do
      begin
        Candidate := Inventory[I];
        if Candidate.NoDropFlag > 0 then Continue;
        if (Candidate.ItemType in WeaponItemTypes) and (Candidate.Weight > GetHull.Weight * 0.2) then
        begin
          Item := TEquipment(Candidate);
          Break;
        end;
        if (Candidate.ItemType = item_cargo_hook) and (Candidate.Weight > GetHull.Weight * 0.2) then
        begin
          Item := TEquipment(Candidate);
          Break;
        end;
      end;
      if (Item <> nil) and ((Item.ItemType in WeaponItemTypes) or (Item.ItemType = item_cargo_hook)) then
      begin
        if CanDrop then DropCarriedItemAsMovingLoot(Item) else LiquidateInventoryItem(Item);
      end
      else
      begin
        if not (Self is TTranclucator) and (ConsecutiveDockedDays > 100) then DestroyQueued := True;
        Break;
      end;
    end;
end;
{ @end $6DD374 }

{ @routine $6DDB8C TShip_DropRandomCheapItemsOnDestruction }
procedure TShip.DropRandomCheapItemsOnDestruction(Count: Integer);
var
  Index, I: Integer;
  Item: TItem;
  // @nested $6DD9A4 SelectCheapItem
  function SelectCheapItem: TItem; // @addr 0x006DD9A4 @ida "TItem *__cdecl $name(void *ParentFrame);" @note "Caller-popped static link; cycling inventory index -4, ship -8."
  var
    Attempt: Integer;
    Candidate: TItem;
    Value: Double;
  begin
    Result := nil;
    Index := NextRandomIntRange(1, Inventory.Count - 1, RandomState);
    for Attempt := 1 to Inventory.Count - 1 do
    begin
      IncrementWrapped(Index, 1, Inventory.Count - 1);
      Candidate := Inventory[Index];
      if (Candidate.DestroyFlag > 0) or (Candidate.NoDropFlag > 0) then Continue;
      Value := Candidate.Cost / Max(Int64(1), Round(Galaxy.GetDropValueModifier * Galaxy.AverageRangerCapital) div 25);
      if Self is TKling then Value := KlingCheapDropValueFactors[(Self as TKling).KlingType] * Value;
      if (Candidate.Cost > 1000) and
        (NextRandomIntRange(1, 100, RandomState) > Round(100 * Exp(2 - 2 * Value))) then Continue;
      if (Result = nil) or (Candidate.Cost < NextRandomFloatRange(0.5, 1, RandomState) * Result.Cost) then
        Result := Candidate;
    end;
  end;
begin
  if NoDrop then Exit;
  for I := 1 to Count do
    if Inventory.Count > 1 then
    begin
      Item := SelectCheapItem;
      if Item <> nil then DropCarriedItemAsMovingLoot(Item);
    end;
end;
{ @end $6DDB8C }

{ @routine $6DDDD4 TShip_DropRandomValuableItemsOnDestruction }
procedure TShip.DropRandomValuableItemsOnDestruction(Count: Integer);
var
  Index, I: Integer;
  Item: TItem;
  // @nested $6DDBD4 SelectValuableItem
  function SelectValuableItem: TItem; // @addr 0x006DDBD4 @ida "TItem *__cdecl $name(void *ParentFrame);" @note "Caller-popped static link; cycling inventory index -4, ship -8."
  var
    Attempt: Integer;
    Candidate: TItem;
    Value: Double;
  begin
    Result := nil;
    if GetPlayer = nil then Exit;
    Index := NextRandomIntRange(1, Inventory.Count - 1, RandomState);
    for Attempt := 1 to Inventory.Count - 1 do
    begin
      IncrementWrapped(Index, 1, Inventory.Count - 1);
      Candidate := Inventory[Index];
      if (Candidate.DestroyFlag > 0) or (Candidate.NoDropFlag > 0) then Continue;
      Value := Candidate.Cost / Max(Int64(1), Round(Galaxy.GetDropValueModifier * Galaxy.AverageRangerCapital) div 12);
      if Self is TKling then Value := KlingValuableDropValueFactors[(Self as TKling).KlingType] * Value;
      if (Candidate.Cost > 1000) and
        (NextRandomIntRange(1, 100, RandomState) > Round(100 * Exp(0.3 - 0.3 * Value))) then Continue;
      if (Result = nil) or (Candidate.Cost > NextRandomFloatRange(0.5, 1, RandomState) * Result.Cost) then
        Result := Candidate;
    end;
  end;
begin
  if NoDrop then Exit;
  for I := 1 to Count do
    if Inventory.Count > 1 then
    begin
      Item := SelectValuableItem;
      if Item <> nil then DropCarriedItemAsMovingLoot(Item);
    end;
end;
{ @end $6DDDD4 }

{ @routine $6DDE1C TShip_DropItemsForDominatorProgram }
procedure TShip.DropItemsForDominatorProgram(Count: Integer);
var I, Attempts, Dropped: Integer; Item, Cheapest: TEquipment; Value: Double;
begin
  if NoDrop then Exit;
  Attempts := 0;
  Dropped := 0;
  Cheapest := nil;
  while True do begin
    Inc(Attempts);
    if Attempts > 100 then Exit;
    I := NextRandomIntRange(1, Inventory.Count - 1, RandomState);
    Item := Inventory[I];
    if Item.NoDropFlag > 0 then Continue;
    if Item.ItemType in [item_hull..item_engine] then Continue;
    if (Item.ItemType in WeaponItemTypes) and ((WeaponCount <= 1) or (TWeapon(Item).GetWeaponInfo^.ShotType = shot_area_damage)) then Continue;
    Value := DominatorProgramDropCostFactors[(Self as TKling).KlingType] *
      (Item.Cost / Max(Int64(1), Round(Galaxy.GetDropValueModifier * Galaxy.AverageRangerCapital) div 12));
    if (Item.Cost > 1000) and (NextRandomIntRange(1, 100, RandomState) > Round(Exp(0.3 - 0.3 * Value) * 100)) then Continue;
    if (Item.Cost > 1000) and (NextRandomIntRange(1, 100, RandomState) > Round(Exp(0.3 - 0.3 * Value * 0.5) * 100)) then begin
      if (Cheapest = nil) or (Cheapest.Cost > Item.Cost) then begin
        Cheapest := Item;
        Continue;
      end else begin
        DropCarriedItemAsMovingLoot(Cheapest);
        Cheapest := nil;
      end;
    end else begin
      DropCarriedItemAsMovingLoot(Item);
      Cheapest := nil;
    end;
    Inc(Dropped);
    if Dropped >= Count then Break;
  end;
end;
{ @end $6DDE1C }

{ @routine $6DE054 TShip_DropCarriedItemAsMovingLoot }
function TShip.DropCarriedItemAsMovingLoot(Item: TItem): Boolean;
begin
  Result := False;
  if NoDrop or (Item.NoDropFlag > 0) then Exit;
  if Item.ItemType = item_hull then
  begin
    Result := False;
    Exit;
  end;
  Item.Position := Position;
  Inventory.Delete(Inventory.IndexOf(Item));
  QueueMovingItemDrop(Item, 0);
  RefreshDerivedStats(True);
  Result := True;
end;
{ @end $6DE054 }

{ @routine $6DE0B4 TShip_DropCarriedArtefactAsMovingLoot }
function TShip.DropCarriedArtefactAsMovingLoot(Item: TArtefact): Boolean;
begin
  Result := False;
  if NoDrop or (Item.NoDropFlag > 0) then Exit;
  if Item is TArtefactTranclucator then
    TTranclucator((Item as TArtefactTranclucator).Ship).OwnerShip := nil;
  Item.Position := Position;
  Artefacts.Delete(Artefacts.IndexOf(Item));
  QueueMovingItemDrop(Item, 0);
  RefreshDerivedStats(True);
  Result := True;
end;
{ @end $6DE0B4 }

{ @routine $6DE134 TShip_DropGuaranteedDeathDropItems }
procedure TShip.DropGuaranteedDeathDropItems;
var
  I, Count: Integer;
  Item: TItem;
begin
  if NoDrop then Exit;
  Count := GuaranteedDeathDropItems.Count;
  for I := 0 to Count - 1 do
  begin
    Item := GuaranteedDeathDropItems[I];
    Item.Position := Position;
    QueueMovingItemDrop(Item, 0);
  end;
  GuaranteedDeathDropItems.Clear;
end;
{ @end $6DE134 }

{ @routine $6DE18C TShip_CanDropTreasureMap }
function TShip.CanDropTreasureMap: Boolean;
begin
  Result := False;
  if (Self is TPirate) and ((Self as TPirate).PirateType = 0) and
    (GetPlayer <> PartnerShip) and (ScriptShip = nil) then
    if SeededRandomIntRange(1, 100, Seed) <= 15 then Result := True;
end;
{ @end $6DE18C }

{ @routine $6DE1F0 TShip_SelectTreasureMapPlanet }
function TShip.SelectTreasureMapPlanet: TPlanet;
var
  I, J, K, Last, Index: Integer;
  Planet: TPlanet;
  Star: TStar;
  Loot: PPlanetSurfaceLootEntry;
  AlreadyMapped: Boolean;
  Item: TItem;
  Storage: PStorageEntry;
begin
  Result := nil;
  Last := High(CurrentStar.StarDistances);
  Index := SeededRandomIntRange(0, Last, Id + Trunc(Integer(Galaxy.GenerationSeed)));
  for I := 0 to Last do
  begin
    IncrementWrapped(Index, 0, Last);
    Star := CurrentStar.StarDistances[Index].Star as TStar;
    if Star.Constellation.Id = 20 then Continue;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[J];
      if not (Planet.OwnerId in [owner_uninhabited]) or (Planet.SurfaceLootEntries = nil) then Continue;
      AlreadyMapped := False;
      for K := 0 to GetPlayer.Inventory.Count - 1 do
      begin
        Item := GetPlayer.Inventory[K];
        if (Item is TTreasureMap) and ((Item as TTreasureMap).TargetPlanet = Planet) then
        begin
          AlreadyMapped := True;
          Break;
        end;
      end;
      if AlreadyMapped then Continue;
      for K := 0 to GetPlayer.StorageEntries.Count - 1 do
      begin
        Storage := GetPlayer.StorageEntries[K];
        Item := Storage.Item;
        if (Item is TTreasureMap) and ((Item as TTreasureMap).TargetPlanet = Planet) then
        begin
          AlreadyMapped := True;
          Break;
        end;
      end;
      if AlreadyMapped then Continue;
      for K := 0 to Planet.SurfaceLootEntries.Count - 1 do
      begin
        Loot := Planet.SurfaceLootEntries[K];
        if (Loot.Item <> nil) and GetPlayer.CanAccessSurfaceLootItem(Loot.Item) and
          ((Loot.Item is TArtefact) or (Loot.Item is TMicroModule)) then
        begin
          Result := Planet;
          Exit;
        end;
      end;
    end;
  end;
end;
{ @end $6DE1F0 }

{ @routine $6DE430 TShip_TryDropTreasureMap }
function TShip.TryDropTreasureMap: Boolean;
var Planet: TPlanet; Item: TItem;
begin
  Result := False;
  if not (CanDropTreasureMap and not NoDrop) then Exit;
  Planet := SelectTreasureMapPlanet;
  if Planet = nil then Exit;
  Item := TTreasureMap.Create;
  (Item as TTreasureMap).Init(Planet, Self);
  Inventory.Add(Item);
  DropCarriedItemAsMovingLoot(Item);
  Result := True;
end;
{ @end $6DE430 }

{ @routine $6DE49C TShip_DropItemIntoStar }
function TShip.DropItemIntoStar(Item: TItem): Boolean;
var
  Angle: Double;
  Effect: TWeaponSE;
  FilmEntry: PEFilmEndEntry;
  ActionResult: Integer;
  Star: TStar;
begin
  if (Item is TEquipment) and (TEquipment(Item).EquippedFlag <> 0) then
    UnequipItem(TEquipment(Item));
  if GetPlayer <> Self then
  begin
    if Item is TArtefact then
    begin
      Result := DropCarriedArtefactAsMovingLoot(TArtefact(Item));
      Exit;
    end;
    Result := DropCarriedItemAsMovingLoot(Item);
    Exit;
  end
  else
  begin
    Star := CurrentStar;
    if Inventory.IndexOf(Item) >= 0 then Inventory.Delete(Inventory.IndexOf(Item))
    else if Artefacts.IndexOf(Item) >= 0 then
      Inventory.Delete(Artefacts.IndexOf(Item)); // Native deletes from Inventory in this branch too.
    Star.Items.Add(Item);
    Angle := SeededRandomIntRange(0, 360, CurrentStar.GenerationSeed * Galaxy.CurrentTurn * Item.Id) * Pi / 180;
    if Item is TWeapon then (Item as TWeapon).Target := nil;
    Item.Position.X := GetPlayer.Position.X + Sin(Angle) * 100;
    Item.Position.Y := GetPlayer.Position.Y - Cos(Angle) * 100;
    ActionResult := ScriptItemsAct(event_drop_stationary_item, Item, nil, 0);
    if Item is TEquipmentWithActCode then
      ActionResult := RunItemConfigActionCode(Item, event_drop_stationary_item, Self, Item, nil, ActionResult);
    if Item.ScriptItem <> nil then
      ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(event_drop_stationary_item, Self, Item, nil, ActionResult);
    if ActionResult = 0 then
    begin
      Item.GetGraphObject.SetPosition(Item.Position);
      if Star.DamageRadius * Star.DamageRadius > Sqr(Item.Position.X) + Sqr(Item.Position.Y) then
      begin
        Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
        Effect.SetEndpoints(nil, Item.GetGraphObject);
        Effect.SetHit(0, 0, True, True);
        if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
        FilmEntry := TrailingFilmEffects.AppendEntry;
        RetainSpaceObject(FilmEntry.SceneObject, Effect);
        RetainSpaceObject(FilmEntry.RelatedObject1, Item.GetGraphObject);
        ReleaseSpaceObject(Item.GraphObject);
        Star.Items.Delete(Star.Items.IndexOf(Item));
        Item.Free;
      end;
    end
    else
    begin
      Star.Items.Delete(Star.Items.IndexOf(Item));
      if ActionResult < 0 then Item.Free;
    end;
    Result := True;
  end;
end;
{ @end $6DE49C }

{ @routine $6DE7B8 TShip_DropAllArtefactsOnDestruction }
procedure TShip.DropAllArtefactsOnDestruction;
var
  Item: TArtefact;
  I: Integer;
begin
  for I := Artefacts.Count - 1 downto 0 do
  begin
    Item := Artefacts[I];
    DropCarriedArtefactAsMovingLoot(Item);
  end;
end;
{ @end $6DE7B8 }

{ @routine $6DE7EC TShip_DropGoodsIntoSpace }
procedure TShip.DropGoodsIntoSpace(Good: Byte; Count: Integer);
var
  Goods: TGoods;
begin
  Goods := TGoods.Create;
  Goods.Init(TItemType(Good), Count);
  Goods.Cost := Round(GetAverageCargoCost(Good) * Count);
  Goods.Position := Position;
  QueueMovingItemDrop(Goods, 0);
  ConsumeCargoGoods(Good, Count);
  RefreshDerivedStats(True);
end;
{ @end $6DE7EC }

{ @routine $6DE85C TShip_JettisonCargoGoodsTowardTargetValue }
function TShip.JettisonCargoGoodsTowardTargetValue(TargetValue: Integer): Boolean;
var
  Good: Byte;
  Pass, Quantity, Value, Drops: Integer;
  Done: Boolean;
  Factor: Single;
begin
  Result := False;
  if NoDrop then Exit;
  Value := 0;
  Done := False;
  Drops := 0;
  for Pass := 1 to 3 do
  begin
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
      if CargoGoods[Good].Count > 0 then
      begin
        Factor := RemapClamped(CargoGoods[Good].Count * GoodsMarket[Good].AveragePrice,
          TargetValue div 3, TargetValue * 3, 1, 7);
        Quantity := Max(1, Round(CargoGoods[Good].Count / Factor));
        Inc(Value, Quantity * GoodsMarket[Good].AveragePrice);
        DropGoodsIntoSpace(Good, Quantity);
        Inc(Drops);
        if (Value > TargetValue) or (Drops > 2) then
        begin
          Done := True;
          Break;
        end;
      end;
    if Done then Break;
  end;
  Result := Drops > 0;
end;
{ @end $6DE85C }

{ @routine $6DE9B4 TShip_DropAllCargoGoods }
procedure TShip.DropAllCargoGoods;
var
  Good: Byte;
  Quantity: Integer;
begin
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    if CargoGoods[Good].Count > 0 then
    begin
      Quantity := CargoGoods[Good].Count;
      DropGoodsIntoSpace(Good, Quantity);
    end;
end;
{ @end $6DE9B4 }

{ @routine $6DE9DC TShip_QueueMovingItemDrop }
procedure TShip.QueueMovingItemDrop(Item: TItem; DeployTranclucator: Byte);
var
  OtherItem: TItem;
  Drop: PMovingDropItemEntry;
  Retry: Boolean;
  Angle, Distance: Single;
  I, Count, Attempts, ActionResult: Integer;
begin
  if Item is TWeapon then
  begin
    (Item as TWeapon).Target := nil;
    CurrentStar.ClearCombatEventWeaponReferences(Item);
  end;
  Drop := AllocEC(SizeOf(TMovingDropItemEntry));
  Drop.Payload := Item;
  Drop.SourceShipId := Id;
  Drop.InsertedIntoStar := False;
  Drop.DeployTranclucator := DeployTranclucator;
  Attempts := 0;
  Retry := True;
  while Retry do
  begin
    Angle := HeadingDegreesToRadians(NextRandomIntRange(0, 360, RandomState));
    Distance := NextRandomIntRange(100, 200, RandomState);
    Drop.Destination.X := Sin(Angle) * Distance + Item.Position.X;
    Drop.Destination.Y := Item.Position.Y - Cos(Angle) * Distance;
    Retry := False;
    Count := CurrentStar.Items.Count;
    for I := 0 to Count - 2 do
    begin
      OtherItem := CurrentStar.Items[I];
      if PointDistanceSquared(Drop.Destination, OtherItem.Position) < 100 then
      begin
        Retry := True;
        Break;
      end;
    end;
    if Attempts > 15 then Break;
    Inc(Attempts);
  end;
  if (Item is TEquipment) and (TEquipment(Item).EquippedFlag <> 0) then
    UnequipItem(TEquipment(Item));
  ActionResult := ScriptItemsAct(event_drop_moving_item, Item, nil, 0);
  if Item is TEquipmentWithActCode then
    ActionResult := RunItemConfigActionCode(Item, event_drop_moving_item, Self, Item, nil, ActionResult);
  if Item.ScriptItem <> nil then
    ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(event_drop_moving_item, Self, Item, nil, ActionResult);
  if ActionResult = 0 then
  begin
    CurrentStar.MovingDropItems.Add(Drop);
    if not ((Self is TKling) and (Item is TProtoplasm)) and (GetPlayer <> Self) then
      AddRecentlyDroppedItem(Item);
  end
  else
  begin
    Drop.Payload := nil;
    FreeEC(Drop);
    if ActionResult < 0 then Item.Free;
  end;
end;
{ @end $6DE9DC }

{ @routine $6DEC48 TShip_SelectLeastValuableInventoryItem }
function TShip.SelectLeastValuableInventoryItem: TItem;
var
  I: Integer;
  BestValue, Value: Double;
  Item, Best: TEquipment;
begin
  Result := nil;
  Best := GetHull;
  BestValue := 100000000;
  while Result <> Best do
  begin
    Result := Best;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item = Best then Continue;
      if IsEssentialInventoryItem(Item) and not IsEssentialInventoryItem(Best) then Continue;
      if (Item.EquippedFlag <> 0) and (Best.EquippedFlag = 0) then Continue;
      if Item.NoDropFlag > 0 then Continue;
      Value := Item.Cost / Item.Weight;
      if IsEssentialInventoryItem(Best) and not IsEssentialInventoryItem(Item) then
      begin
        Best := Item;
        BestValue := Value;
      end
      else if (Best.EquippedFlag <> 0) and (Item.EquippedFlag = 0) then
      begin
        Best := Item;
        BestValue := Value;
      end
      else if not ((Item.EquippedFlag <> 0) and IsOptionalUtilityEquipment(Best) and not IsOptionalUtilityEquipment(Item)) then
        if Value < BestValue then
        begin
          Best := Item;
          BestValue := Value;
        end;
    end;
  end;
end;
{ @end $6DEC48 }

{ @routine $6DEDA0 TShip_SelectLeastValuableArtefact }
function TShip.SelectLeastValuableArtefact: TArtefact;
var
  I: Integer;
  BestValue, Value: Double;
  Item: TArtefact;
begin
  if Artefacts = nil then
  begin
    Result := nil;
    Exit;
  end else
  if Artefacts.Count = 0 then
  begin
    Result := nil;
    Exit;
  end;
  Result := nil;
  BestValue := 0;
  for I := 1 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if Item.NoDropFlag > 0 then Continue;
    Value := Item.Cost / Item.Weight;
    if Item.EquippedFlag <> 0 then Value := Value * 10;
    if (Result = nil) or (Value < BestValue) then
    begin
      Result := Item;
      BestValue := Value;
    end;
  end;
end;
{ @end $6DEDA0 }

{ @routine $6DEE44 TShip_SelectCheapestCargoGood }
function TShip.SelectCheapestCargoGood: Byte;
var
  BestValue, Value: Double;
  Good: Byte;
begin
  BestValue := 100000;
  Result := 255;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    if CargoGoods[Good].Count = 0 then Continue;
    Value := GoodsMarket[Good].AveragePrice;
    if Value < BestValue then
    begin
      BestValue := Value;
      Result := Good;
    end;
  end;
end;
{ @end $6DEE44 }

{ @routine $6DEF7C TShip_OptimizeInventory }
procedure TShip.OptimizeInventory;
var
  Index: Integer;
  Item, Best: TEquipment;
  Done: Boolean;
  CostPerWeight: Double;
  Count: Integer;
  Good: Byte;
  Artefact: TArtefact;

  // @nested $6DEEA8 GetRetainedCapacity
  function GetRetainedCapacity: Integer; // @addr 0x006DEEA8 @ida "int __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4. Hull capacity minus equipped and protected items."
  var Entry: TEquipment; I: Integer;
  begin
    Result := GetHull.Weight;
    for I := 1 to Inventory.Count - 1 do
    begin
      Entry := Inventory[I];
      if (Entry.EquippedFlag <> 0) or (Entry.NoDropFlag > 0) or
        ((Entry.ScriptItem <> nil) and (TScriptItem(Entry.ScriptItem).Name <> '')) then Dec(Result, Entry.Weight);
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Entry := Artefacts[I];
      if (Entry.EquippedFlag <> 0) or (Entry.NoDropFlag > 0) or
        ((Entry.ScriptItem <> nil) and (TScriptItem(Entry.ScriptItem).Name <> '')) then Dec(Result, Entry.Weight);
    end;
  end;

begin
  AutoEquipInventory;
  while GetDesiredCargoFreeSpace > GetRetainedCapacity do
  begin
    CostPerWeight := 0;
    Best := nil;
    for Index := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[Index];
      if (Item.EquippedFlag <> 0) and not IsEssentialInventoryItem(Item) and
        ((Best = nil) or (Item.Cost / Item.Weight < CostPerWeight) or
         (IsOptionalUtilityEquipment(Item) and not IsOptionalUtilityEquipment(Best))) then
      begin Best := Item; CostPerWeight := Item.Cost / Item.Weight; end;
    end;
    if Best = nil then Break;
    LiquidateInventoryItem(Best);
    AutoEquipInventory;
  end;
  AutoEquipArtefacts;
  while (Artefacts.Count > 0) and (GetDesiredCargoFreeSpace > GetRetainedCapacity) do
  begin
    CostPerWeight := 0;
    Artefact := nil;
    for Index := 1 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[Index];
      if (Item.EquippedFlag <> 0) and not IsEssentialInventoryItem(Item) and
        ((Artefact = nil) or (Item.Cost / Item.Weight < CostPerWeight) or
         (IsOptionalUtilityEquipment(Item) and not IsOptionalUtilityEquipment(Artefact))) then
      begin Artefact := TArtefact(Item); CostPerWeight := Item.Cost / Item.Weight; end;
    end;
    if Artefact = nil then Break;
    LiquidateArtefact(Artefact);
    AutoEquipArtefacts;
  end;
  repeat
    Done := True;
    for Index := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[Index];
      if (Item.EquippedFlag = 0) and (Item.NoDropFlag <= 0) and
        ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) then
      begin
        LiquidateInventoryItem(Item);
        Done := False;
        Break;
      end;
    end;
    for Index := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[Index];
      if (Artefact.EquippedFlag = 0) and (Artefact.NoDropFlag <= 0) and
        ((Artefact.ScriptItem = nil) or (TScriptItem(Artefact.ScriptItem).Name = '')) then
      begin
        LiquidateArtefact(Artefact);
        Done := False;
        Break;
      end;
    end;
  until Done;
  if CargoFreeSpace < 0 then
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
      if CargoGoods[Good].Count > 0 then
      begin
        Count := Min(-CargoFreeSpace, CargoGoods[Good].Count);
        if (CurrentPlanet <> nil) or ((DockedTo <> nil) and (DockedTo is TRuins)) then SellGoodsToLocation(Good, Count)
        else
        begin
          SetMoney(Money + Round(GetAverageCargoCost(Good) * Count));
          ConsumeCargoGoods(Good, Count);
          RefreshDerivedStats(True);
        end;
        if CargoFreeSpace >= 0 then Break;
      end;
end;
{ @end $6DEF7C }

{ @routine $6DF2D0 TShip_LiquidateInventoryItem }
procedure TShip.LiquidateInventoryItem(Item: TItem);
begin
  if (Item.ItemType = item_nodes) and (GetPlayer <> Self) and
    (((Self is TRanger) and ((DockedTo <> nil) and (DockedTo.TypeId = station_ranger_center))) or
    (DaysSincePlayerSeen > 100) or ((Self is TWarrior) and ((Self as TWarrior).WarriorType = warrior_flagship))) then
  begin
    DepositCarriedNodes;
    (Self as TNormalShip).TrainSkillsAutomatically;
  end
  else
  begin
    SetMoney(Money + Item.CalculateResaleValue(GetEffectiveSkillLevel(skill_trading)));
    Inventory.Delete(Inventory.IndexOf(Item));
    if (Item is TWeapon) and (CurrentStar <> nil) then CurrentStar.ClearCombatEventWeaponReferences(Item);
    Item.Free;
    RefreshDerivedStats(True);
  end;
end;
{ @end $6DF2D0 }

{ @routine $6DF3C0 TShip_LiquidateArtefact }
procedure TShip.LiquidateArtefact(Item: TArtefact);
begin
  SetMoney(Money + Item.CalculateResaleValue(GetEffectiveSkillLevel(skill_trading)));
  Artefacts.Delete(Artefacts.IndexOf(Item));
  Item.Free;
  RefreshDerivedStats(True);
end;
{ @end $6DF3C0 }

{ @routine $6DF418 TShip_RepairHullAtLocation }
function TShip.RepairHullAtLocation: Boolean;
var
  Repair, FriendlyCount, I: Integer;
  Ship: TShip;
begin
  Result := False;
  if GetHull.HullPoints = GetHull.Weight then Exit;
  Repair := Trunc(GetHull.Weight / 10);
  if Repair + GetHull.HullPoints > GetHull.Weight then
    GetHull.HullPoints := GetHull.Weight
  else
  begin
    Inc(GetHull.HullPoints, Repair);
    if CurrentStar.Battle <> 0 then
    begin
      FriendlyCount := 0;
      for I := 0 to CurrentStar.Ships.Count - 1 do
      begin
        Ship := CurrentStar.Ships[I];
        if not Ship.InNormalSpace then Continue;
        if not (Ship is TNormalShip) then Continue;
        if (Ship.TypeId = ship_pirate) and (Ship.OwnerId in PlanetOwnerMasks.Coalition) then Continue;
        if Ship.TypeId = ship_dominator then Continue;
        if (Ship.OwnerId in PlanetOwnerMasks.Coalition) <> (OwnerId in PlanetOwnerMasks.Coalition) then Continue;
        Inc(FriendlyCount);
      end;
      Result := GetHull.HullPoints * 5 div GetHull.Weight < FriendlyCount;
    end
    else Result := True;
  end;
end;
{ @end $6DF418 }

{ @routine $6DF580 TShip_ReloadWeaponAmmo }
procedure TShip.ReloadWeaponAmmo;
var
  I: Integer;
  Weapon: TWeapon;
begin
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    if Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket] then Weapon.Ammo := Weapon.AmmoCapacity;
  end;
end;
{ @end $6DF580 }

{ @routine $6DF5C0 TShip_ApplyCombatItemDegradation }
procedure TShip.ApplyCombatItemDegradation(BaseDurabilityDamage: Double);
const
  WearableTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
var
  I: Integer;
  Item, Artefact: TEquipment;
begin
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.BrokenFlag = 0) and (Item.ItemType in WearableTypes) then
      if GetDefGenerator = Item then ApplyItemDegradation(Item, wear_combat, BaseDurabilityDamage * 1.3)
      else if GetRepairRobot = Item then ApplyItemDegradation(Item, wear_combat, BaseDurabilityDamage * 1.25)
      else if Item.ItemType in WeaponItemTypes then ApplyItemDegradation(Item, wear_combat, BaseDurabilityDamage * 1.15)
      else ApplyItemDegradation(Item, wear_combat, BaseDurabilityDamage);
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Artefact := Artefacts[I];
    if (Artefact.BrokenFlag <> 0) or not (Artefact.ItemType in WearableTypes) then Continue;
    case NextRandomIntRange(1, 10, RandomState) of
      1..6: Continue;
      7: ApplyItemDegradation(Artefact, wear_combat, BaseDurabilityDamage * 0.3);
      8: ApplyItemDegradation(Artefact, wear_combat, BaseDurabilityDamage * 0.6);
      9: ApplyItemDegradation(Artefact, wear_combat, BaseDurabilityDamage * 0.9);
      10: ApplyItemDegradation(Artefact, wear_combat, BaseDurabilityDamage * 1.2);
    end;
  end;
end;
{ @end $6DF5C0 }

{ @routine $6DF824 TShip_ApplyArtefactUseDegradation }
procedure TShip.ApplyArtefactUseDegradation(BaseDurabilityDamage: Double);
const
  WearableTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
var
  I: Integer;
  Item: TEquipment;
begin
  if Artefacts.Count = 0 then Exit;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if not (Item.ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles]) then Item.Repair;
    if (Item.BrokenFlag = 0) and (Item.EquippedFlag <> 0) and (Item.ItemType in WearableTypes) then
      ApplyItemDegradation(Item, wear_use, BaseDurabilityDamage);
  end;
end;
{ @end $6DF824 }

{ @routine $6DF8C8 TShip_ApplyAfterburnerItemDegradation }
procedure TShip.ApplyAfterburnerItemDegradation;
var
  I: Integer;
  Item: TEquipment;
begin
  ApplyItemDegradation(GetEngine, wear_afterburner, GetAfterburnerWear);
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if (Item.ItemType = artefact_afterburner) and (Item.EquippedFlag <> 0) then
    begin
      ApplyItemDegradation(Item, wear_afterburner, 3);
      Break;
    end;
  end;
end;
{ @end $6DF8C8 }

{ @routine $6DF93C TShip_ApplyItemDegradation }
function TShip.ApplyItemDegradation(Item: TEquipment; Kind: TItemWearKind; DurabilityDamage: Double): Boolean;
var
  BeforeScript, AfterScript, AttackCount: Integer;
  NewCondition: Double;
begin
  Result := False;
  if (GetPlayer = Self) and ((Galaxy.TechnicModEnabled = 1) or (Galaxy.SpecialSimulationMode <> 0)) then Exit;
  if Item = nil then Exit;
  if (Item is TArtefact) and not (Item.ItemType in [item_custom_artefact, artefact_hull..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump, artefact_health_protection..artefact_extra_missiles]) then Exit;
  if Item.ConditionPercent < -95 then Exit;
  if (Item is TWeapon) and (Kind = wear_use) then
  begin
    AttackCount := GetAttackMultiplier;
    if AttackCount > 1 then DurabilityDamage := DurabilityDamage / AttackCount;
  end;
  if GetPlayer = Self then
  begin
    DurabilityDamage := DurabilityDamage * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[3]].EquipmentWearFactor;
    if IsHealthEffectActive(disease_drug_addiction) then DurabilityDamage := DurabilityDamage * 2;
    if IsHealthEffectActive(stimulant_super_technician) then DurabilityDamage := DurabilityDamage * 0.4;
  end;
  if CanUseEquipmentTech(Item) and (GetEffectiveSkillLevel(skill_technical) > 0) then
    DurabilityDamage := DurabilityDamage / (1 + GetEffectiveSkillLevel(skill_technical) * 0.2);
  DurabilityDamage := DurabilityDamage * Item.GetFragilityFactor([]);
  BeforeScript := Round(DurabilityDamage * 1000);
  case Kind of
    wear_combat: AfterScript := ScriptItemsAct(event_equipment_combat_wear, Item, nil, BeforeScript);
    wear_use: AfterScript := ScriptItemsAct(event_equipment_use_wear, Item, nil, BeforeScript);
    wear_external: AfterScript := ScriptItemsAct(event_equipment_external_wear, Item, nil, BeforeScript);
    wear_afterburner: AfterScript := ScriptItemsAct(event_equipment_afterburner_wear, Item, nil, BeforeScript);
  else AfterScript := BeforeScript;
  end;
  if BeforeScript <> AfterScript then DurabilityDamage := AfterScript * 0.001;
  if DurabilityDamage < 0 then DurabilityDamage := 0;
  NewCondition := Item.ConditionPercent - DurabilityDamage;
  Item.ConditionPercent := NewCondition;
  if (Item.ConditionPercent < 0) and (Item.BrokenFlag = 0) then
  begin
    if Item is TWeapon then
    begin
      if (TypeId = ship_warrior) and (UsableWeaponCount < 3) then
      begin
        Item.ConditionPercent := 1;
        Exit;
      end;
      (Item as TWeapon).Target := nil;
    end;
    Result := True;
    Item.BrokenFlag := 1;
    if (GetPlayer = Self) and (Item.EquippedFlag <> 0) then
    begin
      case Kind of
        wear_combat: AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn, Item.GetBrokenInBattleText, '').Targets[0].ShipId := Id;
        wear_use, wear_afterburner: AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn, Item.GetBrokenInUseText, '').Targets[0].ShipId := Id;
        wear_external: AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn, Item.GetBrokenByForceText, '').Targets[0].ShipId := Id;
      end;
      PlayerEquipmentBrokenThisTurn := True;
    end;
    if (GetPlayer = Self) and (Item is TSatellite) and ((Item as TSatellite).TargetPlanet <> nil) then
    begin
      AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn, (Item as TSatellite).GetBrokenInUseText, '').Targets[0].ShipId := Id;
      GetPlayer.RefreshStorageBubbles;
    end;
    RefreshDerivedStats(True);
  end;
  if GetPlayer = Self then
  begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Abs(Item.ConditionPercent - NewCondition) > 0.00001) and not GR_Main.CCInterface.GetTamperDetected then
      GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $6DF93C }

{ @routine $6DFDCC TShip_CanGenerateMicroModuleForLoadout }
function TShip.CanGenerateMicroModuleForLoadout: Boolean;
var I, Equipped, Specials: Integer; Item: TEquipment;
begin
  Result := False;
  if GetPlayer = Self then
  begin
    Result := True;
    Exit;
  end;
  if not (TypeId in [ship_ranger, ship_pirate, ship_warrior]) then Exit;
  if ((DockedTo = nil) or not (DockedTo is TRuins)) and
    ((CurrentPlanet = nil) or not (CurrentPlanet.OwnerId in [owner_maloc..owner_gaal, owner_pirate])) then Exit;
  Equipped := 0;
  Specials := 0;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (not (Item is THull)) and (Item.EquippedFlag <> 0) then
    begin
      Inc(Equipped);
      if Item.SpecialModuleIndex <> 0 then Inc(Specials);
    end;
  end;
  Result := Specials * 100 < RemapClamped(Galaxy.TechLevel, 1, 8, 0, 100) * Equipped;
end;
{ @end $6DFDCC }

{ @routine $6DFEE0 TShip_CanGenerateSpecialHullModule }
function TShip.CanGenerateSpecialHullModule: Boolean;
begin
  Result := (GetPlayer = Self) or (GetHull.SpecialModuleIndex <> 0);
end;
{ @end $6DFEE0 }

{ @routine $6DFF04 TShip_ImproveRandomEquipment }
procedure TShip.ImproveRandomEquipment(ResolveOverload: Boolean);
var Index, Cost: Integer; Item, Best: TEquipment; BestCost: Integer;
begin
  BestCost := 0;
  Best := nil;
  for Index := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[Index];
    if (NextRandomUnitFloat(RandomState) < 0.5) and IsEquipmentUsable(Item) and
      (Item.ItemType in [item_hull..item_custom_weapon]) and
      ((Item.EquippedFlag <> 0) or (Item.ItemType = item_hull)) and Item.CanImprove and
      (Item.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) and
      (not (Item is TWeapon) or (TWeapon(Item).GetWeaponInfo.Availability <> availability_not_sold_node_repair)) then
    begin
      Cost := Item.Cost;
      if Cost > BestCost then begin BestCost := Cost; Best := Item; end;
    end;
  end;
  if Best <> nil then
    if (Galaxy.TechLevel > 6) and (GetPlayer <> nil) and (GetPlayer.StrengthInBestRanger > 0.6) and
      ((StrengthInBestRanger < 0.5) or (NextRandomUnitFloat(RandomState) < 0.4)) then
      Best.Improve(upgrade_major)
    else Best.Improve(upgrade_random);
  if (Best <> nil) and (NextRandomUnitFloat(RandomState) < 0.3) and (Best.MicroModuleIndex = 0) then
  begin
    GenerateAndApplyMicroModule(Best, ResolveOverload);
    Exit;
  end;
  BestCost := 0;
  Best := nil;
  for Index := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[Index];
    if (NextRandomUnitFloat(RandomState) < 0.3) and IsEquipmentUsable(Item) and
      ((Item.EquippedFlag <> 0) or (Item.ItemType = item_hull)) and
      (Item.MicroModuleIndex = 0) then
    begin
      Cost := Item.Cost;
      if Cost > BestCost then begin BestCost := Cost; Best := Item; end;
    end;
  end;
  if (Best <> nil) and (NextRandomUnitFloat(RandomState) < 0.9) then
    GenerateAndApplyMicroModule(Best, ResolveOverload);
end;
{ @end $6DFF04 }

{ @routine $6E028C TShip_GenerateAndApplyMicroModule }
procedure TShip.GenerateAndApplyMicroModule(Item: TEquipment; ResolveOverload: Boolean);
var ModuleIndex, Attempts, Priority, Accepted, BestModule: Integer; Gain, BestGain: Single;

  // @nested $6E0168 FitsGeneratedModuleCapacity
  function FitsGeneratedModuleCapacity: Boolean; // @addr 0x006E0168 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; equipment -4, zero-based module index -8, ship -12. Uses strict remaining-capacity comparison."
  begin
    if Item.ItemType <> item_hull then
      Result := (MicroModuleTemplates[ModuleIndex].SizePercent - 100) * Item.Weight * 0.01 < CargoFreeSpace
    else Result := (MicroModuleTemplates[ModuleIndex].SizePercent - 100) * (-Item.Weight) * 0.01 < CargoFreeSpace;
  end;

  // @nested $6E0218 AcceptDuplicate
  function AcceptDuplicate: Boolean; // @addr 0x006E0218 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; module index -8, ship -12. Random rejection for matching installed modules."
  var Index: Integer; Entry: TEquipment;
  begin
    Result := False;
    for Index := 0 to Inventory.Count - 1 do
    begin
      Entry := Inventory[Index];
      if Entry.EquippedFlag <> 0 then
        if ModuleIndex + 1 = Entry.MicroModuleIndex then
          if NextRandomIntRange(0, 100, RandomState) > 65 then Exit;
    end;
    Result := True;
  end;

begin
  if Item = nil then Exit;
  Attempts := 0;
  Accepted := 0;
  BestModule := -1;
  BestGain := 0;
  repeat
    Priority := Round(RemapClamped(Galaxy.TechLevel, 3, 7, 70, 0));
    ModuleIndex := Galaxy.SelectMicroModuleForEquipment(Priority + Accepted * 5,
      Min(Priority + 40 + Accepted * 20, 100), AdvanceRandomSeed(RandomState), Self, Item);
    if CanInstallMicroModule(ModuleIndex, Item) and FitsGeneratedModuleCapacity and
      AcceptDuplicate then
    begin
      Gain := EvaluateMicroModuleGain(Item, ModuleIndex);
      if Gain > BestGain then begin BestGain := Gain; BestModule := ModuleIndex; end;
      Inc(Accepted);
    end;
    Inc(Attempts);
  until (Attempts > 50) or (Accepted >= 3);
  if BestModule >= 0 then
  begin
    ApplyMicroModule(BestModule, Item);
    AutoEquipInventory;
    if ResolveOverload then DropCargoUntilNotOverloaded;
  end;
end;
{ @end $6E028C }

{ @routine $6E03D8 TShip_GenerateExtraWeapon }
procedure TShip.GenerateExtraWeapon;
var MinimumLevel, MaximumLevel: Integer; Weapon: TWeapon; Info: PWeaponInfo;
begin
  MinimumLevel := 3;
  if NextRandomUnitFloat(RandomState) < 0.05 then MaximumLevel := Galaxy.TechLevel + 1
  else MaximumLevel := Galaxy.TechLevel;
  MaximumLevel := Max(MinimumLevel, Min(MaximumLevel, 8));
  MinimumLevel := Max(1, Min(MinimumLevel, MaximumLevel - 2));
  Info := Galaxy.SelectWeaponInfo(RandomState, [availability_unrestricted], MaximumLevel, MinimumLevel);
  Weapon := CreateGeneratedWeapon(Info,
    NextRandomIntRange(Round(Info.AverageSize * EquipmentSizeFactors[5]),
      Round(Info.AverageSize * EquipmentSizeFactors[3]), RandomState),
    NextRandomIntRange(MinimumLevel, MaximumLevel, RandomState), OwnerId);
  Inventory.Add(Weapon);
  if NextRandomUnitFloat(RandomState) < 0.5 then
    if (Galaxy.TechLevel > 6) and (GetPlayer <> nil) and (GetPlayer.StrengthInBestRanger > 0.6) and
      ((StrengthInBestRanger < 0.5) or (NextRandomUnitFloat(RandomState) < 0.4)) then
      Weapon.Improve(upgrade_major)
    else Weapon.Improve(upgrade_random);
  if NextRandomUnitFloat(RandomState) < 0.5 then GenerateAndApplyMicroModule(Weapon, True);
  AutoEquipInventory;
  OptimizeInventory;
end;
{ @end $6E03D8 }

{ @routine $6E05B0 TShip_NeedsMicroModule }
function TShip.NeedsMicroModule(ModuleIndexPlusOne: Integer): Boolean;
var
  I: Integer;
  Item: TEquipment;
  Found: Boolean;
begin
  Result := False;
  Found := False;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if CanInstallMicroModule(ModuleIndexPlusOne - 1, Item) then
    begin
      Found := True;
      Break;
    end;
  end;
  if not (Found) then Exit;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item is TMicroModule) and (Item.MicroModuleIndex = ModuleIndexPlusOne) then Exit;
  end;
  Result := True;
end;
{ @end $6E05B0 }

{ @routine $6E0658 TShip_CountUnequippedDominatorEquipment }
function TShip.CountUnequippedDominatorEquipment: Integer;
var I: Integer; Item: TEquipment;
begin
  Result := 0;
  for I := 1 to Inventory.Count - 1 do begin
    Item := Inventory[I];
    if (Item.OwnerId = owner_dominator) and (Item.EquippedFlag = 0) then Inc(Result);
  end;
end;
{ @end $6E0658 }

{ @routine $6E0698 TShip_GetSatelliteLimit }
function TShip.GetSatelliteLimit: Integer;
begin
  Result := TechnicalSkillSatelliteLimits[GetEffectiveSkillLevel(skill_technical)] + GetTotalStatBonus(bonus_satellite_limit);
end;
{ @end $6E0698 }

{ @routine $6E06C4 TShip_IsEssentialInventoryItem }
function TShip.IsEssentialInventoryItem(Item: TItem): Boolean;
begin
  Result := False;
  if Item = nil then Exit;
  if (Item.NoDropFlag > 0) or ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '')) then
  begin
    Result := True;
    Exit;
  end;
  if (TEquipment(Item).EquippedFlag = 0) and (Item.ItemType <> item_hull) then Exit;
  Result := True;
  if Item.ItemType in [item_hull..item_engine] then Exit;
  if (Item.ItemType in WeaponItemTypes) and (WeaponCount <= 1) then Exit;
  if (Item.ItemType = item_cargo_hook) and (TypeId in [ship_ranger, ship_pirate]) and (GetSlotCount(slot_cargo_hook) > 0) then Exit;
  Result := False;
end;
{ @end $6E06C4 }

{ @routine $6E0744 TShip_IsOptionalUtilityEquipment }
function TShip.IsOptionalUtilityEquipment(Item: TItem): Boolean;
begin
  Result := False;
  if Item <> nil then
  begin
    if Item.ItemType in [item_radar..item_scanner] then begin
      Result := True;
      Exit;
    end;
    if (Item.ItemType = item_cargo_hook) and not (TypeId in [ship_ranger, ship_pirate]) then begin
      Result := True;
      Exit;
    end;

  end;
end;
{ @end $6E0744 }

{ @routine $6E0778 TShip_NeedsEssentialEquipment }
function TShip.NeedsEssentialEquipment: Boolean;
begin
  Result := True;
  if (Speed > 0) and (WeaponCount > 0) and
    (not (TypeId in [ship_ranger, ship_pirate]) or (GetCargoHook <> nil) or (GetSlotCount(slot_cargo_hook) <= 0)) then Result := False;
end;
{ @end $6E0778 }

{ @routine $6E07BC TShip_RestoreEssentialEquipment }
procedure TShip.RestoreEssentialEquipment;
var Subsidy, OriginalMoney: Integer;
begin
  if NeedsEssentialEquipment then
  begin
    Subsidy := 1000;
    OriginalMoney := Money;
    while NeedsEssentialEquipment and (Subsidy < 1000000) do
    begin
      BuyEquipmentAtLocation(True);
      if not NeedsEssentialEquipment then Break;
      SetMoney(Money + Subsidy);
      CalculateWealth;
      Subsidy := Round(Subsidy * 1.3);
    end;
    if Money > OriginalMoney then SetMoney(OriginalMoney);
    CalculateWealth;
  end;
end;
{ @end $6E07BC }

{ @routine $6E09A4 TShip_BuyEquipmentAtLocation }
procedure TShip.BuyEquipmentAtLocation(ForceGeneratedOffers: Boolean);
label
  InstallNewEquipment, FinishShopping;
var
  ReplacementWeapon: TWeapon;
  SavedWeapons: array[1..5] of TWeapon;
  SavedTarget: TObject;
  I, FreeWeight: Integer;
  // Two unused four-byte locals; original types and purposes are unknown.
  UnknownLocal30: array[0..3] of Byte;
  OriginalMoney: Integer;
  UnknownLocal38: array[0..3] of Byte;
  BestItem, OfferItem, OldItem: TEquipment;
  Offers: TList;
  NewScore, OldScore, BestGain, NewEffectiveness, OldEffectiveness: Single;
  RestoreStock, GeneratedBatch, DifferentHullGraph, UseMoney: Boolean;
  SavedNextItemId: Cardinal;
  Bought: Boolean;

  // @nested $6E0858 SelectReplacedWeapon
  function SelectReplacedWeapon: TWeapon; // @addr 0x006E0858 @ida "TWeapon *__cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4. Selects the lowest evaluated weapon when all slots are occupied."
  var J, Best: Integer;
  begin
    Result := nil;
    if WeaponCount < GetSlotCount(slot_weapon) then Exit;
    Best := 1;
    for J := 2 to WeaponCount do
      if EvaluateItem(Weapons[Best], 3) > EvaluateItem(Weapons[J], 3) then Best := J;
    Result := Weapons[Best];
  end;

  // @nested $6E08F8 TemporarilyUnequipWeapon
  procedure TemporarilyUnequipWeapon(Weapon: TWeapon); // @addr 0x006E08F8 @note "Caller-popped static link; ship -4, fallback weapon -8; saves five weapon pointers and target at -32."
  var WeaponIndex, J: Integer; Selected: TWeapon;
  begin
    Selected := Weapon;
    if Selected = nil then Selected := ReplacementWeapon;
    WeaponIndex := 0;
    for J := 1 to 5 do
    begin
      SavedWeapons[J] := Weapons[J];
      if SavedWeapons[J] = Selected then WeaponIndex := J;
    end;
    if WeaponIndex = 0 then Exit;
    SavedTarget := Selected.Target;
    UnequipSlot(Selected.ItemType, WeaponIndex);
  end;

  // @nested $6E0958 RestoreWeapon
  procedure RestoreWeapon; // @addr 0x006E0958 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4, weapon -8; restores saved target and weapon pointers."
  var J: Integer;
  begin
    EquipItem(ReplacementWeapon);
    ReplacementWeapon.Target := SavedTarget;
    for J := 1 to 5 do Weapons[J] := SavedWeapons[J];
  end;

begin
  RestoreStock := False;
  GeneratedBatch := False;
  UseMoney := True;
  SavedNextItemId := Galaxy.NextItemId;
  Bought := False;
  OriginalMoney := Money;
  if CurrentPlanet <> nil then
  begin
    if (TemporaryShopSlots <> nil) and (TemporaryShopPlanet = CurrentPlanet) then
    begin
      RestoreTemporaryShopStock;
      RestoreStock := True;
    end;
    if Galaxy.IsAIShoppingEnabled and not ForceGeneratedOffers and
      (not (Self is TWarrior) or ((Self as TWarrior).WarriorType <> warrior_flagship)) then
      Offers := CurrentPlanet.EquipmentShop
    else
    begin
      Offers := CurrentPlanet.BuildEquipmentOfferBatch(Self, ForceGeneratedOffers);
      GeneratedBatch := True;
    end;
  end
  else if (DockedTo <> nil) and (DockedTo is TRuins) then
  begin
    if (TemporaryShopSlots <> nil) and (TemporaryShopStation = DockedTo) then
    begin
      RestoreTemporaryShopStock;
      RestoreStock := True;
    end;
    if Galaxy.IsAIShoppingEnabled and not ForceGeneratedOffers and
      (not (Self is TWarrior) or ((Self as TWarrior).WarriorType <> warrior_flagship)) then
      Offers := TRuins(DockedTo).EquipmentShop
    else
    begin
      Offers := TRuins(DockedTo).GenerateEquipmentOfferBatch(Self, ForceGeneratedOffers);
      GeneratedBatch := True;
    end;
  end
  else if (Self is TRuins) and Galaxy.IsStationShopUpdateEnabled then
  begin
    if (TemporaryShopSlots <> nil) and (TemporaryShopStation = Self) then
    begin
      RestoreTemporaryShopStock;
      RestoreStock := True;
    end;
    Offers := TRuins(Self).EquipmentShop;
    UseMoney := False;
  end
  else
  begin
    if (Self is TTranclucator) and (TTranclucator(Self).OwnerShip <> nil) and
      (CurrentStar = nil) and (CurrentPlanet = nil) and (DockedTo = nil) then
    begin
      CurrentStar := TTranclucator(Self).OwnerShip.CurrentStar;
      CurrentPlanet := TTranclucator(Self).OwnerShip.CurrentPlanet;
      DockedTo := TTranclucator(Self).OwnerShip.DockedTo;
      if (CurrentPlanet <> nil) or (DockedTo <> nil) then
      begin
        BuyEquipmentAtLocation(ForceGeneratedOffers);
        CurrentPlanet := nil;
        DockedTo := nil;
      end;
      CurrentStar := nil;
    end;
    Exit;
  end;
  RefreshEquipmentEvaluationMetrics;
  I := Inventory.Count;
  if UseMoney then
    while I > 0 do
    begin
      Dec(I);
      OldItem := Inventory[I];
      if (OldItem.ItemType <> item_hull) and (OldItem.EquippedFlag <> 0) and
        not IsEssentialInventoryItem(OldItem) and (EvaluateItem(OldItem, 2) <= 0) and
        ((OldItem.ScriptItem = nil) or (TScriptItem(OldItem.ScriptItem).Name = '')) and
        (OldItem.NoDropFlag <= 0) then
      begin
        if OldItem is TWeapon then TemporarilyUnequipWeapon(TWeapon(OldItem))
        else UnequipSlot(OldItem.ItemType, 0);
        LiquidateInventoryItem(OldItem);
        I := Inventory.Count;
      end;
    end;
  ReplacementWeapon := SelectReplacedWeapon;
  FreeWeight := CargoFreeSpace - Max(0, GetDesiredCargoFreeSpace - GetCargoGoodsWeight);
  BestGain := 0;
  BestItem := nil;
  for I := 0 to Offers.Count - 1 do
  begin
    OfferItem := Offers[I];
    if not (OfferItem.ItemType in [item_hull..item_custom_weapon]) or
      ((OfferItem.ScriptItem <> nil) and (TScriptItem(OfferItem.ScriptItem).Name <> '')) or
      (OfferItem.NoDropFlag > 0) or
      (not (OfferItem.ItemType in [item_hull..item_engine]) and (GetSlotCountForItemType(OfferItem.ItemType) = 0)) then Continue;
    if OfferItem.ItemType = item_hull then
    begin
      if (Self is TRuins) then Continue;
      if (GetHull.HullType <> (OfferItem as THull).HullType) then Continue;
      if (GetHull.OwnerId <> OfferItem.OwnerId) then Continue;
      if (((OfferItem as THull).SpecialModuleIndex = 0) <> (GetHull.SpecialModuleIndex = 0)) then Continue;
      if GetHull.SpecialModuleIndex <> 0 then
      begin
        GetHull.OwnerShip := nil;
        DifferentHullGraph := (OfferItem as THull).GetSpecialKindGraph <> GetHull.GetSpecialKindGraph;
        GetHull.OwnerShip := Self;
        if DifferentHullGraph then Continue;
      end;
    end;
    if OfferItem is TWeapon then OldItem := ReplacementWeapon
    else OldItem := EquipmentCache.Slots[OfferItem.ItemType];
    if (OfferItem.ItemType in [item_fuel_tanks..item_engine]) and (OldItem = nil) and
      (not UseMoney or (Money >= OfferItem.Cost)) then
    begin
      BestItem := OfferItem;
      Break;
    end;
    OldScore := 0;
    OldEffectiveness := 0;
    NewEffectiveness := 0;
    if OldItem <> nil then
    begin
      if ((OfferItem.ItemType <> item_hull) and (FreeWeight + OldItem.Weight - OfferItem.Weight < 0)) or
        ((OfferItem.ItemType = item_hull) and (FreeWeight - OldItem.Weight + OfferItem.Weight < 0)) or
        ((OldItem.ScriptItem <> nil) and (TScriptItem(OldItem.ScriptItem).Name <> '')) or
        (OldItem.NoDropFlag > 0) then Continue;
      if OldItem is TWeapon then TemporarilyUnequipWeapon(nil)
      else if not (OldItem is THull) then UnequipSlot(OldItem.ItemType, 0);
      OldEffectiveness := CalculateItemEffectiveness(OldItem);
      NewEffectiveness := CalculateItemEffectiveness(OfferItem);
      if TypeId = ship_ranger then
        if AdjustItemEvaluation(OfferItem, 2, NewEffectiveness) * 1.2 > AdjustItemEvaluation(OldItem, 2, OldEffectiveness) then
          if Money < OfferItem.Cost then EquipmentPriceSensitivity := 0.99 * EquipmentPriceSensitivity + 0.01
          else EquipmentPriceSensitivity := 0.99 * EquipmentPriceSensitivity;
      if UseMoney and (OldItem.CalculateResaleValue(GetEffectiveSkillLevel(skill_trading)) + Money - OfferItem.Cost < 0) then
      begin
        if not (OldItem is THull) then
          if OldItem is TWeapon then RestoreWeapon
          else EquipItem(OldItem);
        Continue;
      end;
      OldScore := AdjustItemEvaluation(OldItem, 3, OldEffectiveness);
    end
    else
    begin
      if (FreeWeight - OfferItem.Weight < 0) or (UseMoney and (Money - OfferItem.Cost < 0)) then Continue;
      NewEffectiveness := CalculateItemEffectiveness(OfferItem);
    end;
    if NewEffectiveness < OldEffectiveness then NewEffectiveness := NewEffectiveness - Abs(NewEffectiveness) * 0.1;
    NewScore := AdjustItemEvaluation(OfferItem, 4, NewEffectiveness);
    if (OldItem <> nil) and not (OldItem is THull) then
      if OldItem is TWeapon then RestoreWeapon
      else EquipItem(OldItem);
    if NewScore - OldScore > BestGain then
    begin
      BestGain := NewScore - OldScore;
      BestItem := OfferItem;
    end;
  end;
  if BestItem = nil then goto FinishShopping;
  if BestItem is TWeapon then OldItem := ReplacementWeapon
  else OldItem := EquipmentCache.Slots[BestItem.ItemType];
  Offers.Delete(Offers.IndexOf(BestItem));
  Bought := True;
  if OldItem = nil then goto InstallNewEquipment;
  if OldItem is TWeapon then TemporarilyUnequipWeapon(nil)
  else UnequipSlot(OldItem.ItemType, 0);
  if UseMoney then SetMoney(OldItem.CalculateResaleValue(GetEffectiveSkillLevel(skill_trading)) + Money);
  Inventory.Delete(Inventory.IndexOf(OldItem));
  OldItem.Free;
InstallNewEquipment:
  if UseMoney then SetMoney(Money - BestItem.Cost);
  if BestItem is THull then Inventory.Insert(0, BestItem) else Inventory.Add(BestItem);
  EquipItem(BestItem);
  if BestItem is THull then RefreshGraphicSize;
FinishShopping:
  if RestoreStock then
  begin
    BuildTemporaryShopSlotGrid;
    EquipmentShopScreen.ClearGoodsControls;
    EquipmentShopScreen.BuildGoodsControls;
    EquipmentShopScreen.UpdateScrollButtons;
  end;
  if GeneratedBatch then Offers.Free;
  if GeneratedBatch and not Bought then Galaxy.NextItemId := SavedNextItemId;
  OptimizeInventory;
  RefreshDerivedStats(True);
  if Money > OriginalMoney then BuyEquipmentAtLocation(ForceGeneratedOffers);
end;
{ @end $6E09A4 }

{ @routine $6E13D4 TShip_CreateAndEquipHull }
function TShip.CreateAndEquipHull(Capacity: Word; Level: Byte; Owner: TOwnerId; Series: Integer; PirateBuilt: Boolean): THull;
var
  Item: THull;
  Kind: THullType;
begin
  Item := THull.Create;
  Kind := GetDefaultHullType;
  Item.Init(Capacity, Level, Owner, Kind, Series, PirateBuilt);
  Inventory.Add(Item);
  EquipItem(Item);
  Item.OwnerShip := Self;
  Result := Item;
  RefreshGraphic;
end;
{ @end $6E13D4 }

{ @routine $6E1440 TShip_SelectRandomHullSeries }
function TShip.SelectRandomHullSeries: Integer;
begin
  if Self is TNormalShip then Result := Galaxy.SelectHullSeries(RaceToOwner(PilotRace), GetDefaultHullType, 1, 100)
  else Result := Galaxy.SelectHullSeries(OwnerId, GetDefaultHullType, 1, 100);
end;
{ @end $6E1440 }

{ @routine $6E149C TShip_CreateAndEquipFuelTanks }
function TShip.CreateAndEquipFuelTanks(Weight: Integer; Level: Byte; Owner: TOwnerId): TFuelTanks;
var
  Item: TFuelTanks;
begin
  Item := TFuelTanks.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E149C }

{ @routine $6E14EC TShip_CreateAndEquipEngine }
function TShip.CreateAndEquipEngine(Weight: Integer; Level: Byte; Owner: TOwnerId): TEngine;
var
  Item: TEngine;
begin
  Item := TEngine.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E14EC }

{ @routine $6E153C TShip_CreateAndEquipRadar }
function TShip.CreateAndEquipRadar(Weight: Integer; Level: Byte; Owner: TOwnerId): TRadar;
var
  Item: TRadar;
begin
  Item := TRadar.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E153C }

{ @routine $6E158C TShip_CreateAndEquipScanner }
function TShip.CreateAndEquipScanner(Weight: Integer; Level: Byte; Owner: TOwnerId): TScaner;
var
  Item: TScaner;
begin
  Item := TScaner.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E158C }

{ @routine $6E15DC TShip_CreateAndEquipRepairRobot }
function TShip.CreateAndEquipRepairRobot(Weight: Integer; Level: Byte; Owner: TOwnerId): TRepairRobot;
var
  Item: TRepairRobot;
begin
  Item := TRepairRobot.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E15DC }

{ @routine $6E162C TShip_CreateAndEquipCargoHook }
function TShip.CreateAndEquipCargoHook(Weight: Integer; Level: Byte; Owner: TOwnerId): TCargoHook;
var
  Item: TCargoHook;
begin
  Item := TCargoHook.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E162C }

{ @routine $6E167C TShip_CreateAndEquipDefGenerator }
function TShip.CreateAndEquipDefGenerator(Weight: Integer; Level: Byte; Owner: TOwnerId): TDefGenerator;
var
  Item: TDefGenerator;
begin
  Item := TDefGenerator.Create;
  Item.Init(Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E167C }

{ @routine $6E16CC TShip_CreateAndEquipWeapon }
function TShip.CreateAndEquipWeapon(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId): TWeapon;
var
  Item: TWeapon;
begin
  Item := TWeapon.Create;
  Item.Init(ItemType, Weight, Level, Owner);
  Inventory.Add(Item);
  EquipItem(Item);
  Result := Item;
end;
{ @end $6E16CC }

{ @routine $6E1720 TShip_ScanForCollectableItems }
function TShip.ScanForCollectableItems: Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  if IsEquipmentUsable(GetCargoHook) then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if CanCargoHookHandleItem(Item, Self) and AcceptPickupItem(Item) and ShouldPickUpItem(Item) and
        (CountOtherShipsTargetingItem(Item) <= 0) and AcceptPickupDistance(Item, PointDistance(Position, Item.Position)) then begin Result := True; Exit; end;
    end;
end;
{ @end $6E1720 }

{ @routine $6E17D0 TShip_QueueItemsWithinPickupRange }
procedure TShip.QueueItemsWithinPickupRange;
var I: Integer; Item: TItem;
begin
  if IsEquipmentUsable(GetCargoHook) and (Speed > 0) then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if IsItemInPickupRange(Item) and not IsRecentlyDroppedItem(Item) and AcceptPickupItem(Item) and ShouldPickUpItem(Item) then AddPickupTarget(Item, False);
    end;
end;
{ @end $6E17D0 }

{ @routine $6E1860 TShip_TryCollectBestFloatingItem }
function TShip.TryCollectBestFloatingItem(MaximumTravelTurns: Integer): Boolean;
var I: Integer; Item, BestItem: TItem; Found: Boolean; Distance, BestDistance: Double; Drop: PMovingDropItemEntry; ItemPosition: TPointF;
begin
  Result := False;
  if IsEquipmentUsable(GetCargoHook) then
    if (Speed >= 1) then begin
    Found := False;
    BestItem := nil;
    BestDistance := 10000;
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if CanCargoHookHandleItem(Item, Self) then
        if not IsRecentlyDroppedItem(Item) then
        if AcceptPickupItem(Item) then
        if ShouldPickUpItem(Item) then
        if ((CountOtherShipsTargetingItem(Item) < 2) or CanReachItemBeforeOtherShips(Item)) then begin
        if IsItemInPickupRange(Item) then AddPickupTarget(Item, False)
        else begin
          Distance := PointDistance(Position, Item.Position);
          if (MaximumTravelTurns >= Distance / Speed) then
            if AcceptPickupDistance(Item, Distance) then
            if (not OrderAbsolute or (Order = order_move)) then
            if ((BestItem = nil) or
              ((10 * BestItem.Cost < Item.Cost) and (BestItem.Cost > Wealth * 0.01)) or
              ((1.3 * Distance < BestDistance) and (BestItem.Cost < 2 * Item.Cost))) then begin
            Found := True;
            BestItem := Item;
            BestDistance := Distance;
            ItemPosition := Item.Position;
          end;
        end;
      end;
    end;
    for I := 0 to CurrentStar.MovingDropItems.Count - 1 do begin
      Drop := CurrentStar.MovingDropItems[I];
      Item := TItem(Drop.Payload);
      if CanCargoHookHandleItem(Item, Self) then
        if not IsRecentlyDroppedItem(Item) then
        if AcceptPickupItem(Item) then
        if ShouldPickUpItem(Item) then begin
        Distance := PointDistance(Position, Drop.Destination);
        if (MaximumTravelTurns >= Distance / Speed) then
          if AcceptPickupDistance(Item, Distance) then
          if (not OrderAbsolute or (Order = order_move)) then
          if ((BestItem = nil) or
            ((10 * BestItem.Cost < Item.Cost) and (BestItem.Cost > Wealth * 0.01)) or
            ((1.3 * Distance < BestDistance) and (BestItem.Cost < 2 * Item.Cost))) then begin
          Found := True;
          BestItem := Item;
          BestDistance := Distance;
          ItemPosition := Drop.Destination;
        end;
      end;
    end;
    if BestItem <> nil then OrderMove(GetPickupApproachPosition(ItemPosition), False);
    if not Found then
      if (Order = order_move) then OrderNone(False);
    if Order = order_move then Result := True;
  end;
end;
{ @end $6E1860 }

{ @routine $6E1C0C TShip_GetReservedPickupWeight }
function TShip.GetReservedPickupWeight: Integer;
var I: Integer; Item: TItem;
begin
  Result := 0;
  if PickupTargets <> nil then
    for I := 0 to PickupTargets.Count - 1 do begin
      Item := PickupTargets[I];
      Inc(Result, Item.Weight);
    end;
end;
{ @end $6E1C0C }

{ @routine $6E1C44 TShip_IsItemInPickupRange }
function TShip.IsItemInPickupRange(Item: TItem): Boolean;
begin
  Result := CanCargoHookHandleItem(Item, Self) and
    (PointDistanceSquared(Position, Item.Position) <= GetCargoHookRangeSquared);
end;
{ @end $6E1C44 }

{ @routine $6E1C8C TShip_AcceptPickupItem }
function TShip.AcceptPickupItem(Item: TItem): Boolean;
begin
  Result := False;
end;
{ @end $6E1C8C }

{ @routine $6E1C90 TShip_ShouldPickUpItem }
function TShip.ShouldPickUpItem(Item: TItem): Boolean;
var I, EquippedWeight: Integer; Other: TEquipment; EquippedValue: Single; LooseWeight, LooseCost: Integer;
begin
  Result := True;
  if ((PickupTargets <> nil) and (PickupTargets.IndexOf(Item) >= 0) and (CargoFreeSpace > 0)) or
    ((CargoFreeSpace - GetReservedPickupWeight >= Item.Weight) and ((Galaxy.SpecialSimulationMode = 0) or (Item is TMicroModule))) or
    ((Item is TCountableItem) and (CargoFreeSpace - GetReservedPickupWeight > 0) and (Galaxy.SpecialSimulationMode = 0)) or
    ((Item is TGoods) and (CargoFreeSpace - GetReservedPickupWeight > 0) and (Galaxy.SpecialSimulationMode = 0)) then Exit;
  Result := False;
  if (Item.ItemType in [item_hull..item_defense_generator]) and IsEquipmentUsable(Item as TEquipment) then begin
    for I := 1 to Inventory.Count - 1 do begin
      Other := Inventory[I];
      if (Item.ItemType = Other.ItemType) and (Other.Weight + CargoFreeSpace > Item.Weight) and (Other.EquippedFlag <> 0) then
        if EvaluateItem(Item, 1) > EvaluateItem(Other, 1) then begin Result := True; Exit; end;
    end;
  end else if (Item.ItemType in WeaponItemTypes) and IsEquipmentUsable(Item as TEquipment) then begin
    EquippedWeight := 0;
    EquippedValue := 0;
    for I := 1 to Inventory.Count - 1 do begin
      Other := Inventory[I];
      if (Other.ItemType in WeaponItemTypes) and (Other.EquippedFlag <> 0) then begin
        EquippedValue := EquippedValue + EvaluateItem(Other, 1);
        Inc(EquippedWeight, Other.Weight);
      end;
    end;
    if (EquippedWeight + CargoFreeSpace >= Item.Weight) and
      (EvaluateItem(Item, 1) / Max(1, Item.Weight) > EquippedValue / Max(1, EquippedWeight)) then begin Result := True; Exit; end;
  end;
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  LooseWeight := 0;
  LooseCost := 0;
  for I := 1 to Inventory.Count - 1 do begin
    Other := Inventory[I];
    if Other.EquippedFlag <> 0 then Continue;
    Inc(LooseWeight, Other.Weight);
    Inc(LooseCost, Other.Cost);
  end;
  Result := (LooseWeight + CargoFreeSpace >= Item.Weight) and
    (Item.Cost / Max(1, Item.Weight) > LooseCost / Max(1, LooseWeight));
end;
{ @end $6E1C90 }

{ @routine $6E1FE0 TShip_AcceptPickupDistance }
function TShip.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  Result := True;
end;
{ @end $6E1FE0 }

{ @routine $6E1FEC TShip_AddPickupTarget }
procedure TShip.AddPickupTarget(Item: TItem; Prioritize: Boolean);
begin
  if PickupTargets = nil then PickupTargets := TList.Create;
  if PickupTargets.IndexOf(Item) < 0 then
    if Prioritize then PickupTargets.Insert(0, Item) else PickupTargets.Add(Item);
end;
{ @end $6E1FEC }

{ @routine $6E2048 TShip_RemovePickupTarget }
procedure TShip.RemovePickupTarget(Item: TItem);
var
  I: Integer;
begin
  if PickupTargets = nil then Exit;
  I := PickupTargets.IndexOf(Item);
  if I >= 0 then
  begin
    PickupTargets.Delete(I);
    if PickupTargets.Count < 1 then
    begin
      PickupTargets.Free;
      PickupTargets := nil;
    end;
  end;
end;
{ @end $6E2048 }

{ @routine $6E2088 TShip_ClearPickupTargets }
procedure TShip.ClearPickupTargets;
begin
  if PickupTargets <> nil then
  begin
    PickupTargets.Free;
    PickupTargets := nil;
  end;
end;
{ @end $6E2088 }

{ @routine $6E20A4 TShip_RemoveInvalidPickupTargets }
procedure TShip.RemoveInvalidPickupTargets;
var
  I: Integer;
begin
  if PickupTargets <> nil then
  begin
    I := 0;
    while I < PickupTargets.Count do
      if not CanCargoHookHandleItem(TItem(PickupTargets[I]), Self) then PickupTargets.Delete(I)
      else Inc(I);
    if PickupTargets.Count < 1 then
    begin
      PickupTargets.Free;
      PickupTargets := nil;
    end;
  end;
end;
{ @end $6E20A4 }

{ @routine $6E2144 TShip_TogglePickupTargets }
procedure TShip.TogglePickupTargets(IgnoreRange: Boolean);
var
  I: Integer;
  Item: TItem;
  Added: Boolean;
// @nested $6E2104 AcceptPickupTarget
function AcceptPickupTarget(Item: TItem): Boolean; // @addr 0x006E2104 @note "Caller-popped static link; mode -1, ship -8."
begin
  Result := False;
  if IgnoreRange then
  begin
    if CanCargoHookHandleItem(Item, Self) then Result := True;
  end
  else if IsItemInPickupRange(Item) then Result := True;
end;
begin
  Added := False;
  for I := 0 to CurrentStar.Items.Count - 1 do
  begin
    Item := CurrentStar.Items[I];
    if AcceptPickupTarget(Item) and not HasPickupTarget(Item) then
    begin
      AddPickupTarget(Item, False);
      Added := True;
    end;
  end;
  if not Added then
    for I := 0 to CurrentStar.Items.Count - 1 do
    begin
      Item := CurrentStar.Items[I];
      if AcceptPickupTarget(Item) then RemovePickupTarget(Item);
    end;
end;
{ @end $6E2144 }

{ @routine $6E21FC TShip_HasPickupTarget }
function TShip.HasPickupTarget(Item: TItem): Boolean;
begin
  Result := False;
  if (PickupTargets <> nil) and (PickupTargets.IndexOf(Item) >= 0) then Result := True;
end;
{ @end $6E21FC }

{ @routine $6E2228 TShip_CountOtherShipsTargetingItem }
function TShip.CountOtherShipsTargetingItem(Item: TItem): Integer;
var
  I, Count: Integer;
  Ship: TShip;
begin
  Count := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if (Ship <> Self) and (Ship.PickupTargets <> nil) and (Ship.PickupTargets.IndexOf(Item) >= 0) then Inc(Count);
  end;
  Result := Count;
end;
{ @end $6E2228 }

{ @routine $6E228C TShip_CanReachItemBeforeOtherShips }
function TShip.CanReachItemBeforeOtherShips(Item: TItem): Boolean;
var I: Integer; Ship: TShip;
begin
  if Speed < 1 then begin Result := False; Exit; end;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (((Ship <> Self) and Ship.InNormalSpace and (Ship.Speed >= 1)) and ((Ship.GetPickupApproachPosition(Item.Position).X = Ship.OrderDestination.X) and
        (Ship.GetPickupApproachPosition(Item.Position).Y = Ship.OrderDestination.Y))) and (PointDistance(Ship.Position, Item.Position) / Ship.Speed < PointDistance(Position, Item.Position) / Speed) then begin Result := False; Exit; end;
  end;
  Result := True;
end;
{ @end $6E228C }

{ @routine $6E237C TShip_GetPickupApproachPosition }
function TShip.GetPickupApproachPosition(ItemPosition: TPointF): TPointF;
var
  Direction: Integer;
begin
  if ItemPosition.X < Position.X then Direction := -1 else Direction := 1;
  Result.X := ItemPosition.X + (GetCargoHookRange div 2) * Direction;
  if ItemPosition.Y < Position.Y then Direction := -1 else Direction := 1;
  Result.Y := ItemPosition.Y + (GetCargoHookRange div 2) * Direction;
end;
{ @end $6E237C }

{ @routine $6E2400 TShip_GetCurrentPickupItem }
function TShip.GetCurrentPickupItem: TItem;
var
  I: Integer;
  Item: TItem;
begin
  Result := nil;
  for I := 0 to CurrentStar.Items.Count - 1 do
  begin
    Item := CurrentStar.Items[I];
    if (PickupTargets <> nil) and (PickupTargets.IndexOf(Item) >= 0) then
    begin
      Result := Item;
      Exit;
    end;
    if (Order = order_move) and (GetPickupApproachPosition(Item.Position).X = OrderDestination.X) and
      (GetPickupApproachPosition(Item.Position).Y = OrderDestination.Y) then
    begin
      Result := Item;
      Exit;
    end;
  end;
end;
{ @end $6E2400 }

{ @routine $6E24A8 TShip_ClearRecentlyDroppedItems }
procedure TShip.ClearRecentlyDroppedItems;
begin
  if RecentlyDroppedItemIds <> nil then
  begin
    RecentlyDroppedItemIds.Free;
    RecentlyDroppedItemIds := nil;
  end;
end;
{ @end $6E24A8 }

{ @routine $6E24C4 TShip_AddRecentlyDroppedItem }
procedure TShip.AddRecentlyDroppedItem(Item: TItem);
begin
  if RecentlyDroppedItemIds = nil then RecentlyDroppedItemIds := TList.Create;
  if RecentlyDroppedItemIds.IndexOf(Pointer(Item.Id)) < 0 then
    RecentlyDroppedItemIds.Add(Pointer(Item.Id));
end;
{ @end $6E24C4 }

{ @routine $6E2508 TShip_IsRecentlyDroppedItem }
function TShip.IsRecentlyDroppedItem(Item: TItem): Boolean;
begin
  Result := False;
  if (RecentlyDroppedItemIds <> nil) and (RecentlyDroppedItemIds.IndexOf(Pointer(Item.Id)) >= 0) then Result := True;
end;
{ @end $6E2508 }

{ @routine $6E2534 TShip_OrderNone }
procedure TShip.OrderNone(OverrideScriptOrder: Boolean);
begin
  if (AbsoluteScriptOrder > 0) and not OverrideScriptOrder then Exit;
  OrderAbsolute := False;
  Order := order_none;
  OrderTarget := nil;
  ClearMovementPath;
end;
{ @end $6E2534 }

{ @routine $6E2560 TShip_OrderMove }
procedure TShip.OrderMove(Destination: TPointF; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := order_move;
  OrderDestination := Destination;
  OrderAbsolute := Absolute;
  OrderTarget := nil;
end;
{ @end $6E2560 }

{ @routine $6E25C0 TShip_GetJumpDeparturePoint }
function TShip.GetJumpDeparturePoint(Destination: TStar): TPointF;
var Angle, Radius: Double;
begin
  Angle := HeadingDegreesToRadians(PointBearingDegrees(CurrentStar.Position, Destination.Position) +
    SeededRandomIntRange(-4, 4, (CurrentStar.GenerationSeed + Seed) * Destination.GenerationSeed));
  Radius := CurrentStar.ComputeMapDiameter / 2;
  Result.X := Trunc(Sin(Angle) * Radius);
  Result.Y := Trunc(-Cos(Angle) * Radius);
end;
{ @end $6E25C0 }

{ @routine $6E2694 TShip_GetArrivalPosition }
function TShip.GetArrivalPosition(DestinationStar: TStar): TPointF;
var
  Angle, Radius: Double;
begin
  Angle := HeadingDegreesToRadians(PointBearingDegrees(DestinationStar.Position, CurrentStar.Position));
  Radius := DestinationStar.ComputeMapDiameter / 2;
  Result.X := Trunc(Sin(Angle) * Radius);
  Result.Y := Trunc(-Cos(Angle) * Radius);
end;
{ @end $6E2694 }

{ @routine $6E2734 TShip_CalculateJumpTravelDays }
function TShip.CalculateJumpTravelDays(Origin, Destination: TStar): Integer;
begin
  Result := Max(2, Round(PointDistance(Origin.Position, Destination.Position) * 0.1) + 1);
end;
{ @end $6E2734 }

{ @routine $6E27AC TShip_OrderJump }
procedure TShip.OrderJump(Star: TStar; Absolute: Boolean);
begin
  if (AbsoluteScriptOrder > 0) or (CurrentStar = Star) then Exit;
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := order_jump;
  OrderTarget := Star;
  OrderAbsolute := Absolute;
  OrderDestination := GetJumpDeparturePoint(Star);
  OrderStateData := CalculateJumpTravelDays(CurrentStar, Star);
end;
{ @end $6E27AC }

{ @routine $6E2828 TShip_OrderJumpHole }
procedure TShip.OrderJumpHole(Hole: THole; Absolute: Boolean);
begin
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := order_black_hole;
  OrderTarget := Hole;
  OrderAbsolute := Absolute;
  if CurrentStar = Hole.Star1 then
  begin
    OrderDestination := Hole.Position1;
    OrderStateData := 2;
  end
  else
  begin
    OrderDestination := Hole.Position2;
    OrderStateData := $10002;
  end;
end;
{ @end $6E2828 }

{ @routine $6E28A0 TShip_OrderTeleport }
procedure TShip.OrderTeleport(Star: TStar; Destination: TPointF; TransitionData: Integer; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  Order := order_teleport;
  OrderTarget := Star;
  OrderAbsolute := Absolute;
  OrderDestination := Destination;
  OrderStateData := TransitionData;
end;
{ @end $6E28A0 }

{ @routine $6E28F4 TShip_OrderLanding }
procedure TShip.OrderLanding(Location: TObject; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  if Location = nil then
  begin
    OrderNone(False);
    Exit;
  end;
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := order_land;
  OrderTarget := Location;
  OrderDestination := MakePointF(0, 0);
  OrderAbsolute := Absolute;
end;
{ @end $6E28F4 }

{ @routine $6E2968 TShip_OrderTakeoff }
procedure TShip.OrderTakeoff;
var
  Angle: Double;
  Conflict: Boolean;
  I, Count, Attempt: Integer;
  Ship: TShip;
  DX, DY: Single;
begin
  if AbsoluteScriptOrder > 0 then Exit;
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  OrderNone(False);
  PlayerExtortionPactActive := False;
  if CurrentPlanet <> nil then
  begin
    Order := order_takeoff;
    if Self is TNormalShip then (Self as TNormalShip).LastDockedPlanet := CurrentPlanet;
    Position := CurrentPlanet.GetPosition;
    Conflict := True;
    Attempt := 0;
    while Conflict do
    begin
      Angle := SeededRandomIntRange(0, 360, CurrentPlanet.GenerationSeed * Seed * Galaxy.CurrentTurn * (Attempt + 1)) * Pi / 180;
      OrderDestination.X := Trunc(CurrentPlanet.GetPosition.X + Sin(Angle) * 400);
      OrderDestination.Y := Trunc(CurrentPlanet.GetPosition.Y + -Cos(Angle) * 400);
      DX := OrderDestination.X - Position.X;
      DY := OrderDestination.Y - Position.Y;
      if Odd(Galaxy.CurrentTurn) then
        MovementDirection := RadiansToHeadingDegrees(ArcTan2(0 - DY, -(0 + DX)))
      else
        MovementDirection := RadiansToHeadingDegrees(ArcTan2(0 + DY, -(0 - DX)));
      MovementDirection := WrapHeadingDegrees(MovementDirection + SeededRandomIntRange(-5, 5, CurrentPlanet.GenerationSeed * Seed * Galaxy.CurrentTurn * (Attempt + 3 + 1)));
      Conflict := False;
      Count := CurrentStar.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Ship := CurrentStar.Ships[I];
        if (Ship <> Self) and (Ship.Order = order_takeoff) and (Ship.CurrentPlanet = CurrentPlanet) and
          (Abs(HeadingDifferenceDegrees(MovementDirection, Ship.MovementDirection)) < 20) then
        begin
          Conflict := True;
          Break;
        end;
      end;
      Inc(Attempt);
      if Attempt > 5 then Break;
    end;
  end
  else if DockedTo <> nil then
  begin
    Order := order_takeoff;
    if Self is TRanger then (Self as TRanger).LastDockedNonPlanetLocation := DockedTo;
    if DockedTo.CurrentPlanet = nil then Position := DockedTo.Position
    else Position := DockedTo.CurrentPlanet.GetPosition;
    Angle := SeededRandomIntRange(0, 360, (DockedTo.Seed + Seed) * Galaxy.CurrentTurn) * Pi / 180;
    OrderDestination.X := Trunc(Position.X + Sin(Angle) * 400);
    OrderDestination.Y := Trunc(Position.Y + -Cos(Angle) * 400);
    MovementDirection := RadiansToHeadingDegrees(ArcTan2(-(OrderDestination.X - Position.X), -(-(OrderDestination.Y - Position.Y))));
    MovementDirection := WrapHeadingDegrees(MovementDirection + SeededRandomIntRange(-5, 5, (DockedTo.Seed + Seed + 234) * Galaxy.CurrentTurn * 4));
  end;
end;
{ @end $6E2968 }

{ @routine $6E2E30 TShip_OrderFollowShip }
procedure TShip.OrderFollowShip(Ship: TShip; FollowMode: TFollowMode; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  OrderNone(False);
  Order := order_follow_ship;
  OrderTarget := Ship;
  OrderStateData := Ord(FollowMode);
  OrderAbsolute := Absolute;
end;
{ @end $6E2E30 }

{ @routine $6E2E78 TShip_GetMovementPathTurnCount }
function TShip.GetMovementPathTurnCount: Integer;
begin
  Result := Ceil(MovementPath.NodeCount * CurrentStar.MovementStepScale);
end;
{ @end $6E2E78 }

{ @routine $6E2FD0 TShip_PrepareTurnMovement }
procedure TShip.PrepareTurnMovement(StartStepIndex: Integer; RecordFilm: Boolean);
var
  Distance, Angle: Double;
  Gate: PJumpGateEntry;
  EffectFilm: TEFilmObj;
  Owner: TShip;
  Star: TStar;
  Point, TargetPosition: TPointF;
  Countdown: Integer;
  Node: PSPathNode;
  I, J: Integer;
  K: TDominatorSeries;
  Item: TItem;
  PickupDistance: Single;
  PickupNode: PSPathNode;
  CanLand: Boolean;
  Effect: TObjectSE;
  // @nested $6E2E9C InitializeFilm
  procedure InitializeFilm(Alpha: Byte); // @addr 0x006E2E9C @note "Caller-popped static link; step index -4, ship -8."
  begin
    PrimaryFilm.SetObjectPosition(StartStepIndex, FilmObject, Position);
    PrimaryFilm.SetObjectAngle(StartStepIndex, FilmObject, HeadingDegreesToByte(MovementDirection));
    PrimaryFilm.SetObjectAlpha(StartStepIndex, FilmObject, Alpha);
    PrimaryFilm.AttachObject(StartStepIndex, FilmObject);
    if AuxiliaryFilmObject <> nil then
    begin
      PrimaryFilm.SetObjectPosition(StartStepIndex, AuxiliaryFilmObject, Position);
      PrimaryFilm.SetObjectAngle(StartStepIndex, AuxiliaryFilmObject, HeadingDegreesToByte(MovementDirection));
      PrimaryFilm.SetObjectAlpha(StartStepIndex, AuxiliaryFilmObject, AuxiliaryFilmObject.SceneObject.GetAlpha);
      PrimaryFilm.AttachObject(StartStepIndex, AuxiliaryFilmObject);
    end;
  end;

begin
  FilmObject := nil;
  AuxiliaryFilmObject := nil;
  PickupPathUpdatesAllowed := InNormalSpace and (Order <> order_teleport);
  if PickupPathUpdatesAllowed and ((Order = order_land) or (Order = order_jump) or (Order = order_black_hole)) then
  begin
    PickupPathUpdatesAllowed := False;
    if PickupTargets <> nil then
      for I := 0 to PickupTargets.Count - 1 do
      begin
        Item := PickupTargets[I];
        PickupNode := MovementPath.ActiveHead;
        for J := 1 to MovementPath.NodeCount - 1 do
        begin
          PickupDistance := PointDistance(Item.Position, PickupNode.Position);
          if PickupDistance <= GetCargoHookRange then
          begin
            PickupPathUpdatesAllowed := True;
            Break;
          end;
          PickupNode := PickupNode.Next;
        end;
        if PickupPathUpdatesAllowed then Break;
      end;
  end;
  if (GetPlayer = Self) and (Order = order_jump) and InNormalSpace then
    if GetFuelTanks.Fuel < Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
    begin
      AddOrUpdatePlayerBubble(message_ship_negative, Galaxy.CurrentTurn,
        FormatText1(LocalizedText('Items.FuelTanks.NoFuelJump'), TextHighlightColorTag, '<Star>', (OrderTarget as TStar).Name), '').Targets[0].ShipId := Id;
      OrderMove(OrderDestination, False);
    end;
  if RecordFilm and ((Order <> order_none) or not IsOnPlanet) and ((Order <> order_none) or not IsDockedToShip) then
  begin
    FilmObject := PrimaryFilm.AddObject(Id, Graphic);
    if Graphic is TShip2SE then
    begin
      if AfterburnerActive then PrimaryFilm.SetShipSizeAndTailMode(StartStepIndex, FilmObject, Graphic.Size, 2)
      else PrimaryFilm.SetShipSizeAndTailMode(StartStepIndex, FilmObject, Graphic.Size, 1);
    end
    else if (Graphic is TRuinsSE) and (Graphic as TRuinsSE).HasTransitionImages then
      PrimaryFilm.SetRuinsState(StartStepIndex, FilmObject, 1);
    if InterceptorGraphic <> nil then AuxiliaryFilmObject := PrimaryFilm.AddObject(Id, InterceptorGraphic);
  end;
  if Order = order_none then
  begin
    if not InHyperspace then
      if RecordFilm and not IsOnPlanet and not IsDockedToShip then
      begin
        InitializeFilm(255);
        if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
      end;
  end
  else if Order = order_move then
  begin
    FilmAlpha := 255;
    FilmAlphaStep := 0;
    if RecordFilm then
    begin
      InitializeFilm(255);
      if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, OrderDestination, True);
    end;
  end
  else if Order = order_land then
  begin
    FilmAlpha := 510;
    FilmAlphaStep := 0;
    if RecordFilm then InitializeFilm(255);
    if OrderTarget is TShip then
    begin
      Point := (OrderTarget as TShip).Position;
      TargetPosition := Point;
      if (MovementPath.ActiveHead = nil) or PickupPathUpdatesAllowed then CanLand := False
      else CanLand := PointDistanceSquared(MovementPath.ActiveTail.Position, AddPointsF(Point, OrderDestination)) <= 0;
    end
    else
    begin
      Point := (OrderTarget as TPlanet).PredictPosition(CurrentStar.MovementStepCount);
      TargetPosition := (OrderTarget as TPlanet).GetPosition;
      if (MovementPath.ActiveHead = nil) or PickupPathUpdatesAllowed then CanLand := False
      else CanLand := PointDistanceSquared(MovementPath.ActiveTail.Position, Point) <= Sqr((OrderTarget as TPlanet).GraphicRadius) + 1;
    end;
    OrderStateData := 0;
    if (MovementPath.ActiveHead <> nil) and not PickupPathUpdatesAllowed then
    begin
      if CanLand then
      begin
        if RecordFilm then
        begin
          FilmAlphaStep := -(FilmAlpha / MovementPath.NodeCount);
          PrimaryFilm.SetObjectAlpha(StartStepIndex, FilmObject, 255);
          if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
        end
        else FilmAlpha := 0;
        AfterburnerActive := False;
        OrderStateData := 1;
      end;
    end
    else if RecordFilm then
    begin
      PrimaryFilm.SetObjectAlpha(StartStepIndex, FilmObject, 255);
      if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, TargetPosition, True);
    end;
  end
  else if Order = order_teleport then
  begin
    if not InHyperspace then
    begin
      if RecordFilm then
      begin
        if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
        if (FilmObject.SceneObject is TRuinsSE) and TRuinsSE(FilmObject.SceneObject).HasTransitionImages then
          PrimaryFilm.SetRuinsState(StartStepIndex, FilmObject, 2)
        else
        begin
          Effect := TGAIEffectSE.Create('Effect.TeleportOut', Classes.Point(0, 0));
          EffectFilm := PrimaryFilm.AddObject(0, Effect);
          PrimaryFilm.SetEffectImagePosition(StartStepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
          FilmAlpha := 510;
          if (OrderStateData <= 0) and (OrderTarget = CurrentStar) then
          begin
            PrimaryFilm.SetEffectDurationScale(StartStepIndex, EffectFilm, 0.5);
            FilmAlphaStep := -7.65;
          end
          else
          begin
            PrimaryFilm.SetEffectDurationScale(StartStepIndex, EffectFilm, 1);
            FilmAlphaStep := -3.825;
          end;
          PrimaryFilm.AttachObject(StartStepIndex + 1, EffectFilm);
          PrimaryFilm.PlayObjectSound(StartStepIndex + 1, FilmObject, 'Sound.TeleportOut');
        end;
        InitializeFilm(255);
      end;
      AfterburnerActive := False;
      InHyperspace := (OrderStateData > 0) or (OrderTarget <> CurrentStar);
      AbductedByPirateClan := AbductedByPirateClan and (OrderTarget = CurrentStar);
      ClearMovementPath;
      RefreshDerivedStats(True);
      if OrderTarget <> CurrentStar then
      begin
        Galaxy.ShipsInTransit.Add(Self);
        CurrentStar.HandleObjectLeavingStar(Self);
      end
      else TransitOriginStar := CurrentStar;
    end
    else
    begin
      Dec(OrderStateData);
      if OrderStateData <= 0 then
      begin
        InHyperspace := False;
        Position := OrderDestination;
        OrderNone(True);
        Graphic.SetPosition(Position);
        if RecordFilm then
        begin
          if (FilmObject.SceneObject is TRuinsSE) and TRuinsSE(FilmObject.SceneObject).HasTransitionImages then
          begin
            PrimaryFilm.SetRuinsState(StartStepIndex, FilmObject, 3);
            InitializeFilm(255);
          end
          else
          begin
            Effect := TGAIEffectSE.Create('Effect.TeleportIn', Classes.Point(0, 0));
            EffectFilm := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetEffectImagePosition(StartStepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
            PrimaryFilm.SetEffectDurationScale(StartStepIndex, EffectFilm, 1);
            PrimaryFilm.AttachObject(StartStepIndex + 1, EffectFilm);
            PrimaryFilm.PlayObjectSound(StartStepIndex + 1, FilmObject, 'Sound.TeleportIn');
            FilmAlpha := -255;
            FilmAlphaStep := 3.825;
            InitializeFilm(0);
          end;
          if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, True);
          if (Self is TRuins) and (TypeId = station_dominion) and (TransitOriginStar = CurrentStar) then TRuins(Self).ReportAbductionOutcome;
        end
        else
        begin
          FilmAlpha := 255;
          FilmAlphaStep := 0;
        end;
      end;
    end;
  end
  else if Order = order_jump then
  begin
    if not InHyperspace then
    begin
      FilmAlpha := 510;
      FilmAlphaStep := 0;
      AbductedByPirateClan := False;
      if RecordFilm then InitializeFilm(255);
      if not PickupPathUpdatesAllowed and (MovementPath.ActiveHead = nil) then OrderDestination := GetJumpDeparturePoint(TStar(OrderTarget));
      if not PickupPathUpdatesAllowed and (MovementPath.ActiveHead <> nil) and JumpDeparturePathCommitted then
      begin
        OrderDestination := MakePointF(0, 0);
        AfterburnerActive := False;
        if (CurrentStar.ControlFaction = faction_coalition) and (TStar(OrderTarget).ControlFaction = faction_coalition) then
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            if CurrentStar.StarDistances[I].Distance > 40 then Break;
            Star := TStar(CurrentStar.StarDistances[I].Star);
            if (Star.Dominion <> nil) and ((GetPlayer <> Self) or Star.IsConstellationVisible) then TRuins(Star.Dominion).TryAbductDepartingShip(Self);
          end;
        if RecordFilm then
        begin
          if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
          FilmAlphaStep := -(510 / MovementPath.NodeCount);
          if PlayerStar = CurrentStar then
          begin
            Point := MovementPath.ActiveHead.Position;
            Angle := MovementPath.ActiveHead.Heading;
            Node := MovementPath.ActiveHead.Next;
            while Node <> nil do
            begin
              if Abs(Angle - Node.Heading) < 0.001 then Break;
              Angle := Node.Heading;
              Point := Node.Position;
              Node := Node.Next;
            end;
            Gate := Galaxy.CreateJumpGate(AbductedByPirateClan);
            if GiResourceVariant = 2 then Gate.Gate.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5))
            else Gate.Gate.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800));
            Gate.Gate.Pos := MakePointF(Point.X + Sin(HeadingDegreesToRadians(Angle)) * 180, Point.Y - Cos(HeadingDegreesToRadians(Angle)) * 180);
            Gate.Gate.Angle := HeadingDegreesToByte(Angle) + 127;
            EffectFilm := PrimaryFilm.AddObject(0, Gate.Gate);
            PrimaryFilm.SetObjectPosition(StartStepIndex, EffectFilm, Gate.Gate.Position);
            PrimaryFilm.SetObjectAngle(StartStepIndex, EffectFilm, Gate.Gate.Angle);
            PrimaryFilm.SetGateSize(StartStepIndex, EffectFilm, Gate.Gate.Size.X);
            PrimaryFilm.SetGateState(StartStepIndex, EffectFilm, 0);
            PrimaryFilm.OpenGate(StartStepIndex, EffectFilm);

            if not (Self is TKling) and not AbductedByPirateClan then
              if GetJumpRange >= Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
                if ((OrderTarget as TStar).Constellation.Id <> 20) or (OrderTarget as TStar).IsConstellationVisible then
                  PrimaryFilm.SetObjectText(StartStepIndex, EffectFilm, (OrderTarget as TStar).Name);
            PrimaryFilm.AttachObject(StartStepIndex, EffectFilm);
            if Gate.Effect = nil then PrimaryFilm.PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJump')
            else
            begin
              PrimaryFilm.PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJumpAbducted');
              if GiResourceVariant = 2 then Gate.Effect.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5))
              else Gate.Effect.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800));
              Gate.Effect.Pos := MakePointF(Point.X + Sin(HeadingDegreesToRadians(Angle)) * 180, Point.Y - Cos(HeadingDegreesToRadians(Angle)) * 180);
              Gate.Effect.Angle := HeadingDegreesToByte(Angle) + 127;
              EffectFilm := PrimaryFilm.AddObject(0, Gate.Effect);
              PrimaryFilm.SetObjectPosition(StartStepIndex, EffectFilm, Gate.Effect.Position);
              PrimaryFilm.SetObjectAngle(StartStepIndex, EffectFilm, Gate.Effect.Angle);
              PrimaryFilm.SetGateEffectSize(StartStepIndex, EffectFilm, Gate.Effect.Size.X);

              PrimaryFilm.AttachObject(StartStepIndex, EffectFilm);
            end;

          end;
        end;
      end
      else if RecordFilm and (GetPlayer = Self) then PrimaryFilm.SetCameraAnchor(StartStepIndex, OrderDestination, False);
    end
    else
    begin
      FilmAlpha := -255;
      FilmAlphaStep := 0;
      if (KellerShip <> Self) and (TerronShip <> Self) then
      begin
        Dec(OrderStateData);
        if (Cardinal(OrderStateData) > 1) and not AbductedByPirateClan then
        begin
          Dec(OrderStateData, Min(CountActiveArtefacts(artefact_hyperjump) * (Integer(CanBoostArtefact(artefact_hyperjump, nil, False)) + 1), Cardinal(OrderStateData)));
          OrderStateData := Max(1, Int64(Cardinal(OrderStateData)));
        end;
      end;
      if OrderStateData <= 0 then
      begin
        InHyperspace := False;
        Distance := -(CurrentStar.ComputeMapDiameter / 2 + 0);
        if AbductedByPirateClan then Angle := PointBearingDegrees(CurrentStar.Position, TransitOriginStar.Position)
        else Angle := MovementDirection;
        Angle := HeadingDegreesToRadians(WrapHeadingDegrees(Angle + Abs(CurrentStar.GenerationSeed + Seed) mod 10 - 5));
        if AbductedByPirateClan and (CurrentStar.Dominion <> nil) and TShip(CurrentStar.Dominion).InNormalSpace and
          (TShip(CurrentStar.Dominion).CurrentStar = CurrentStar) then
        begin
          Position.X := TShip(CurrentStar.Dominion).Position.X;
          Position.Y := TShip(CurrentStar.Dominion).Position.Y;
          MovementDirection := -RadiansToHeadingDegrees(Angle);
          if RecordFilm and (SimulationContext = 0) then
          begin
            Effect := TGAIEffectSE.Create('Effect.CBAbductEffect', Classes.Point(0, 0));
            EffectFilm := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetEffectImagePosition(StartStepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
            PrimaryFilm.SetEffectDurationScale(StartStepIndex, EffectFilm, 0.5);
            PrimaryFilm.AttachObject(StartStepIndex + 1, EffectFilm);
            SimulationContext := 1;
          end;
        end
        else
        begin
          Position.X := Sin(Angle) * Distance;
          Position.Y := -Cos(Angle) * Distance;
          MovementDirection := RadiansToHeadingDegrees(ArcTan2(-Position.X, -(-Position.Y)));
        end;
        Graphic.SetPosition(Position);
        Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
        OrderNone(True);
        if (AbductedByPirateClan or ((GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil))) and (GetEngine <> nil) then GetEngine.OutputPercent := 0;
        Order := order_move;
        AppendHyperspaceTransitionPath(-1);
        if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
        if RecordFilm then
        begin
          FilmAlphaStep := 510 / MovementPath.NodeCount;
          InitializeFilm(0);
          if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, True);
          if PlayerStar = CurrentStar then
          begin
            Distance := PointDistance(Position, OrderDestination);
            Gate := Galaxy.CreateJumpGate(AbductedByPirateClan or ((GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil)));
            if GiResourceVariant = 2 then Gate.Gate.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5))
            else Gate.Gate.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800));
            Gate.Gate.Pos := MakePointF(OrderDestination.X + (Position.X - OrderDestination.X) / Distance * 150, OrderDestination.Y + (Position.Y - OrderDestination.Y) / Distance * 150);
            Gate.Gate.Angle := HeadingDegreesToByte(MovementDirection);
            EffectFilm := PrimaryFilm.AddObject(0, Gate.Gate);
            PrimaryFilm.SetObjectPosition(StartStepIndex, EffectFilm, Gate.Gate.Position);
            PrimaryFilm.SetObjectAngle(StartStepIndex, EffectFilm, Gate.Gate.Angle);
            PrimaryFilm.SetGateSize(StartStepIndex, EffectFilm, Gate.Gate.Size.X);
            PrimaryFilm.SetGateState(StartStepIndex, EffectFilm, 0);
            PrimaryFilm.OpenGate(StartStepIndex, EffectFilm);

            if TransitOriginStar <> nil then
              if not AbductedByPirateClan and not (Self is TKling) then
                if (GetJumpRange >= Round(PointDistance(TransitOriginStar.Position, CurrentStar.Position))) and
                  ((TransitOriginStar.Constellation.Id <> 20) or TransitOriginStar.IsConstellationVisible) then
                  PrimaryFilm.SetObjectText(StartStepIndex, EffectFilm, TransitOriginStar.Name);
            PrimaryFilm.AttachObject(StartStepIndex, EffectFilm);
            PrimaryFilm.PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJump');
            if Gate.Effect <> nil then
            begin
              if GiResourceVariant = 2 then Gate.Effect.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5))
              else Gate.Effect.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800));
              Gate.Effect.Pos := MakePointF(OrderDestination.X + (Position.X - OrderDestination.X) / Distance * 150, OrderDestination.Y + (Position.Y - OrderDestination.Y) / Distance * 150);
              Gate.Effect.Angle := HeadingDegreesToByte(MovementDirection);
              EffectFilm := PrimaryFilm.AddObject(0, Gate.Effect);
              PrimaryFilm.SetObjectPosition(StartStepIndex, EffectFilm, Gate.Effect.Position);
              PrimaryFilm.SetObjectAngle(StartStepIndex, EffectFilm, Gate.Effect.Angle);
              PrimaryFilm.SetGateEffectSize(StartStepIndex, EffectFilm, Gate.Effect.Size.X);

              PrimaryFilm.AttachObject(StartStepIndex, EffectFilm);
            end;
          end;
          if GetPlayer = Self then
          begin
            PrimaryFilm.SetViewCenter(StartStepIndex, OrderDestination);
            PrimaryFilm.SetCameraAnchor(StartStepIndex, OrderDestination, False);
            for K := Low(TDominatorSeries) to High(TDominatorSeries) do GetPlayer.ChameleonDetected[K] := False;
            GetPlayer.ReportIdleSatellites(GetPlayer.CurrentStar);
            TryAddAchievementProgress('JUMPER', 1);
          end;
        end;
        if (GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil) then GetPlayer.QueuedTravelTarget := nil;
      end;
    end;
  end
  else if Order = order_black_hole then
  begin
    if not InHyperspace then
    begin
      FilmAlpha := 510;
      FilmAlphaStep := 0;
      if RecordFilm then InitializeFilm(255);
      if (MovementPath.ActiveHead <> nil) and not PickupPathUpdatesAllowed then
      begin
        if PointDistanceSquared(MovementPath.ActiveTail.Position, OrderDestination) <= 0 then
        begin
          AfterburnerActive := False;
          if RecordFilm then
          begin
            FilmAlphaStep := -(FilmAlpha / MovementPath.NodeCount);
            PrimaryFilm.SetObjectAlpha(StartStepIndex, FilmObject, 255);
            if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
          end
          else FilmAlpha := 0;
        end;
      end
      else if RecordFilm then
      begin
        PrimaryFilm.SetObjectAlpha(StartStepIndex, FilmObject, 255);
        if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, OrderDestination, True);
      end;
    end
    else
    begin
      FilmAlpha := 0;
      FilmAlphaStep := 0;
      Countdown := OrderStateData and $FFFF;
      Dec(Countdown);
      OrderStateData := ((OrderStateData shr 16) shl 16) or Countdown;
      if Countdown <= 0 then
      begin
        InHyperspace := False;
        if (OrderStateData shr 16 = 0) and (THole(OrderTarget).Star1 <> THole(OrderTarget).Star2) then Point := THole(OrderTarget).Position2
        else Point := THole(OrderTarget).Position1;
        Position := Point;
        Angle := SeededRandomIntRange(0, 360, (Seed + CurrentStar.GenerationSeed + 1) * Galaxy.CurrentTurn) * Pi / 180;
        OrderDestination.X := Trunc(Point.X + Sin(Angle) * 400);
        OrderDestination.Y := Trunc(Point.Y + -Cos(Angle) * 400);
        MovementDirection := RadiansToHeadingDegrees(ArcTan2(-(OrderDestination.X - Point.X), -(-(OrderDestination.Y - Point.Y))));
        MovementDirection := WrapHeadingDegrees(MovementDirection + SeededRandomIntRange(-5, 5, (CurrentStar.GenerationSeed + Galaxy.CurrentTurn) * Seed * 4));
        OrderStateData := HoleExitOrderState;
        OrderTarget := nil;
        BuildOrderMovementPath(1000);
        if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
        if RecordFilm then
        begin
          FilmAlphaStep := 1.275;
          InitializeFilm(0);
          if GetPlayer = Self then
          begin
            PrimaryFilm.SetViewCenter(StartStepIndex, Position);
            PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
            for K := Low(TDominatorSeries) to High(TDominatorSeries) do GetPlayer.ChameleonDetected[K] := False;
            GetPlayer.ReportIdleSatellites(GetPlayer.CurrentStar);
          end;
        end;
      end;
    end;
  end
  else if Order = order_takeoff then
  begin
    DockedTo := nil;
    CurrentPlanet := nil;
    if RecordFilm then
    begin
      FilmAlpha := 0;
      FilmAlphaStep := 1.33875;
      InitializeFilm(0);
      if GetPlayer = Self then
      begin
        PrimaryFilm.SetViewCenter(StartStepIndex, Position);
        PrimaryFilm.SetCameraAnchor(StartStepIndex, Position, False);
      end;
    end;
    if (GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil) then
    begin
      FilmAlphaStep := 5.1;
      OrderNone(True);
      MovementDirection := PointBearingDegrees(CurrentStar.Position, GetPlayer.QueuedTravelTarget.Position);
      AppendHyperspaceTransitionPath(-1);
      if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
      Order := order_jump;
      OrderTarget := (Self as TPlayer).QueuedTravelTarget;
      OrderStateData := Max(2, Round(CalculateJumpTravelDays(CurrentStar, (Self as TPlayer).QueuedTravelTarget) * 0.75));
      OrderDestination.X := 0;
      OrderDestination.Y := 0;
      Graphic.SetPosition(Position);
      Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
      if RecordFilm then PrimaryFilm.SetObjectAngle(StartStepIndex, FilmObject, HeadingDegreesToByte(MovementDirection));
      Gate := Galaxy.CreateJumpGate(True);
      if GiResourceVariant = 2 then Gate.Gate.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5))
      else Gate.Gate.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800));
      Gate.Gate.Pos := MakePointF(Position.X + Sin(HeadingDegreesToRadians(MovementDirection)) * 180, Position.Y - Cos(HeadingDegreesToRadians(MovementDirection)) * 180);
      Gate.Gate.Angle := HeadingDegreesToByte(MovementDirection) + 127;
      EffectFilm := PrimaryFilm.AddObject(0, Gate.Gate);
      PrimaryFilm.SetObjectPosition(StartStepIndex, EffectFilm, Gate.Gate.Position);
      PrimaryFilm.SetObjectAngle(StartStepIndex, EffectFilm, Gate.Gate.Angle);
      PrimaryFilm.SetGateSize(StartStepIndex, EffectFilm, Gate.Gate.Size.X);
      PrimaryFilm.SetGateState(StartStepIndex, EffectFilm, 0);
      PrimaryFilm.OpenGate(StartStepIndex, EffectFilm);

      PrimaryFilm.AttachObject(StartStepIndex + 1, EffectFilm);
      PrimaryFilm.PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJump');
      if Gate.Effect <> nil then
      begin
        if GiResourceVariant = 2 then Gate.Effect.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5))
        else Gate.Effect.ObjectSize := Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800));
        Gate.Effect.Pos := MakePointF(Position.X + Sin(HeadingDegreesToRadians(MovementDirection)) * 180, Position.Y - Cos(HeadingDegreesToRadians(MovementDirection)) * 180);
        Gate.Effect.Angle := HeadingDegreesToByte(MovementDirection) + 127;
        EffectFilm := PrimaryFilm.AddObject(0, Gate.Effect);
        PrimaryFilm.SetObjectPosition(StartStepIndex, EffectFilm, Gate.Effect.Position);
        PrimaryFilm.SetObjectAngle(StartStepIndex, EffectFilm, Gate.Effect.Angle);
        PrimaryFilm.SetGateEffectSize(StartStepIndex, EffectFilm, Gate.Effect.Size.X);

        PrimaryFilm.AttachObject(StartStepIndex + 1, EffectFilm);
      end;
    end;
  end
  else if Order = order_follow_ship then
  begin
    FilmAlpha := 255;
    FilmAlphaStep := 0;
    if RecordFilm then
    begin
      InitializeFilm(255);
      if GetPlayer = Self then PrimaryFilm.SetCameraAnchor(StartStepIndex, (OrderTarget as TShip).Position, True);
    end;
    if Self is TTranclucator then
      if (Self as TTranclucator).CanFollowOwnerInCurrentStar then
      begin
        Owner := (Self as TTranclucator).OwnerShip;
        if Owner.CurrentPlanet <> nil then TargetPosition := Owner.CurrentPlanet.PredictPosition(CurrentStar.MovementStepCount)
        else if Owner.DockedTo <> nil then TargetPosition := Owner.DockedTo.Position
        else if Owner.MovementPath.ActiveTail = nil then TargetPosition := Owner.Position
        else TargetPosition := Owner.MovementPath.ActiveTail.Position;
        if MovementPath.ActiveTail = nil then Point := Position else Point := MovementPath.ActiveTail.Position;
        if PointDistanceSquared(Point, TargetPosition) < 25 then
        begin
          if RecordFilm then
          begin
            if MovementPath.NodeCount < 1 then
            begin
              FilmAlpha := 0;
              FilmAlphaStep := 0;
            end
            else FilmAlphaStep := -(200 / MovementPath.NodeCount);
          end
          else FilmAlpha := 0;
        end;
      end;
  end
  else raise Exception.Create('Error in TShip.StepDayStart');
  if RecordFilm and (GetPlayer = Self) then PrimaryFilm.SetRadarCenter(StartStepIndex, Position);
end;
{ @end $6E2FD0 }

{ @routine $6E5C6C TShip_ProcessMovementStep }
function TShip.ProcessMovementStep(StepIndex: Integer; RecordFilm: Boolean): Boolean;
var
  Node: PSPathNode;
  Angle: Byte;
  I, J, HalfTurn: Integer;
  Item: TItem;
  Distance: Single;
  Effect: TObjectSE;
  EffectFilm: TEFilmObj;
  Fuel: Integer;
// @nested $6E5A68 AdvancePath
procedure AdvancePath; // @addr 0x006E5A68 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4, node -8, recording flag -9, step index -16. Removes one path node and updates position, heading and film."
begin
  if (MovementPath <> nil) and (MovementPath.ActiveHead <> nil) then
  begin
    Node := MovementPath.ActiveHead;
    if RecordFilm then
    begin
      Angle := HeadingDegreesToByte(Node.Heading);
      if HeadingDegreesToByte(MovementDirection) <> Angle then PrimaryFilm.SetObjectAngle(StepIndex, FilmObject, Angle);
    end;
    Position := Node.Position;
    MovementDirection := Node.Heading;
    MovementPath.RemoveNode(MovementPath.ActiveHead);
  end;
  if RecordFilm then
  begin
    PrimaryFilm.SetObjectPosition(StepIndex, FilmObject, Position);
    if AuxiliaryFilmObject <> nil then PrimaryFilm.SetObjectPosition(StepIndex, AuxiliaryFilmObject, Position);
    if GetPlayer = Self then PrimaryFilm.SetRadarCenter(StepIndex, Position);
    if FilmAlphaStep <> 0 then
    begin
      FilmAlpha := FilmAlpha + FilmAlphaStep;
      if FilmAlpha <= 0 then PrimaryFilm.SetObjectAlpha(StepIndex, FilmObject, 0)
      else if FilmAlpha >= 255 then PrimaryFilm.SetObjectAlpha(StepIndex, FilmObject, 255)
      else PrimaryFilm.SetObjectAlpha(StepIndex, FilmObject, Round(FilmAlpha));
    end;
  end;
end;
begin
  Result := False;
  if IsHullDestroyed then Exit;
  PickupPathUpdatesAllowed := InNormalSpace and (Order <> order_teleport);
  if PickupPathUpdatesAllowed and ((Order = order_land) or (Order = order_jump) or (Order = order_black_hole)) then
  begin
    PickupPathUpdatesAllowed := False;
    if PickupTargets <> nil then
      for I := 0 to PickupTargets.Count - 1 do
      begin
        Item := PickupTargets[I];
        Node := MovementPath.ActiveHead;
        for J := 1 to MovementPath.NodeCount - 1 do
        begin
          Distance := PointDistance(Item.Position, Node.Position);
          if Distance <= GetCargoHookRange then
          begin
            PickupPathUpdatesAllowed := True;
            Break;
          end;
          Node := Node.Next;
        end;
        if PickupPathUpdatesAllowed then Break;
      end;
  end;
  if Order = order_none then
  begin
    if FilmObject <> nil then AdvancePath;
  end
  else if Order = order_move then
  begin
    if MovementPath.ActiveHead <> nil then
    begin
      AdvancePath;
      if (Position.X = OrderDestination.X) and (Position.Y = OrderDestination.Y) then OrderNone(False);
    end
    else OrderNone(False);
  end
  else if Order = order_land then
  begin
    if MovementPath.ActiveHead <> nil then
    begin
      AdvancePath;
      if RecordFilm and (GetPlayer = Self) and (OrderStateData = 0) then
      begin
        if OrderTarget is TShip then PrimaryFilm.SetCameraAnchor(StepIndex, (OrderTarget as TShip).Position, True)
        else PrimaryFilm.SetCameraAnchor(StepIndex, (OrderTarget as TPlanet).GetPosition, True);
      end;
      if ((MovementPath.ActiveHead = nil) or (MovementPath.ActiveHead.Next = nil)) and (OrderStateData = 1) then
      begin
        if GetPlayer = Self then GetPlayer.ProcessCareerActivityAndEminentProgress;
        ClearPickupTargets;
        if OrderTarget is TShip then DockedTo := OrderTarget as TShip
        else
        begin
          CurrentPlanet := OrderTarget as TPlanet;
          AbductedByPirateClan := False;
          if (GetPlayer = Self) and not CurrentPlanet.HasPlayerLanded then
          begin
            CurrentPlanet.HasPlayerLanded := True;
            if CurrentPlanet.OwnerId = owner_uninhabited then
            begin
              TrySetAchievementProgress('EXPLORER', GetPlayer.AchievementStats.UninhabitedPlanetsVisited);
              TryAddAchievementProgress('EXPLORER', 1);
              Inc(GetPlayer.AchievementStats.UninhabitedPlanetsVisited);
            end;
          end;
        end;
        OrderNone(True);
        AfterburnerActive := False;
        RefreshTechKnowledgeAtLocation;
        for I := 1 to Inventory.Count - 1 do
        begin
          Item := Inventory[I];
          if Item is TEngine then (Item as TEngine).OutputPercent := 100;
        end;
        if RecordFilm then
        begin
          PrimaryFilm.DetachObject(StepIndex, FilmObject);
          if AuxiliaryFilmObject <> nil then PrimaryFilm.DetachObject(StepIndex, AuxiliaryFilmObject);
        end;
      end;
    end;
  end
  else if Order = order_teleport then
  begin
    if FilmObject <> nil then
    begin
      AdvancePath;
      if (FilmAlphaStep < 0) and (FilmAlpha <= 0) and ((OrderStateData > 0) or (OrderTarget <> CurrentStar)) then
      begin
        PrimaryFilm.DetachObject(StepIndex, FilmObject);
        if AuxiliaryFilmObject <> nil then PrimaryFilm.DetachObject(StepIndex, AuxiliaryFilmObject);
      end;
    end;
    HalfTurn := CurrentStar.MovementStepCount div 2;
    if (OrderStateData <= 0) and (OrderTarget = CurrentStar) and (StepIndex = HalfTurn) then
    begin
      Position := OrderDestination;
      if RecordFilm then
      begin
        FilmAlpha := -255;
        FilmAlphaStep := 7.65;
        Effect := TGAIEffectSE.Create('Effect.TeleportIn', Classes.Point(0, 0));
        EffectFilm := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetEffectImagePosition(StepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
        PrimaryFilm.SetEffectDurationScale(StepIndex, EffectFilm, 0.5);
        PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        PrimaryFilm.PlayObjectSound(StepIndex + 1, FilmObject, 'Sound.TeleportIn');
      end
      else
      begin
        FilmAlpha := 255;
        FilmAlphaStep := 0;
      end;
      OrderNone(True);
    end;
  end
  else if Order = order_jump then
  begin
    if (GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil) and (StepIndex >= 50) then FilmAlphaStep := -1.785;
    if not InHyperspace and (MovementPath.ActiveHead <> nil) then
    begin
      AdvancePath;
      if (OrderDestination.X = 0) and (OrderDestination.Y = 0) and (MovementPath.ActiveHead = nil) then
      begin
        InHyperspace := True;
        if RecordFilm then
        begin
          PrimaryFilm.DetachObject(StepIndex, FilmObject);
          if AuxiliaryFilmObject <> nil then PrimaryFilm.DetachObject(StepIndex, AuxiliaryFilmObject);
        end;
        ClearMovementPath;
        if ((GetPlayer = Self) or (TypeId <> ship_ranger) or (PartnerShip = nil) or
          ((TStar(OrderTarget).ControlFaction <> faction_dominators) and (TStar(OrderTarget).Status.CustomFaction = ''))) and
          ((GetPlayer <> Self) or ((Galaxy.AmmoModEnabled <> 1) and (GetPlayer.QueuedTravelTarget = nil))) then
        begin
          Fuel := GetFuelTanks.Fuel - Integer(Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)));
          GetFuelTanks.Fuel := Fuel;
          if GetPlayer = Self then
          begin
            SysUtils.Sleep(1);
            if (GetFuelTanks.Fuel <> Fuel) and not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
          end;
        end;
        if GetFuelTanks.Fuel < 0 then GetFuelTanks.Fuel := 0;
        RefreshDerivedStats(True);
        Galaxy.ShipsInTransit.Add(Self);
        CurrentStar.HandleObjectLeavingStar(Self);
      end;
    end;
  end
  else if Order = order_black_hole then
  begin
    if (OrderStateData = HoleExitOrderState) and (MovementPath.ActiveHead <> nil) then AdvancePath
    else if not InHyperspace and (MovementPath.ActiveHead <> nil) then
    begin
      AdvancePath;
      if RecordFilm and (FilmAlphaStep = 0) and (GetPlayer = Self) then PrimaryFilm.SetCameraAnchor(StepIndex, OrderDestination, True);
      if (Position.X = OrderDestination.X) and (Position.Y = OrderDestination.Y) then
      begin
        if THole(OrderTarget).HoleType in [1] then THole(OrderTarget).HoleType := 3;
        if (THole(OrderTarget).HoleType = 4) and (GetPlayer = Self) and
          ((KellerShip = nil) or KellerShip.InHyperspace) and (Galaxy.KellerMissionState = 5) then
          THole(OrderTarget).CreatedTurn := Galaxy.CurrentTurn - 10 - 1;
        InHyperspace := True;
        AbductedByPirateClan := False;
        if RecordFilm then
        begin
          PrimaryFilm.DetachObject(StepIndex, FilmObject);
          if AuxiliaryFilmObject <> nil then PrimaryFilm.DetachObject(StepIndex, AuxiliaryFilmObject);
        end;
        ClearMovementPath;
        Galaxy.ShipsInTransit.Add(Self);
        CurrentStar.HandleObjectLeavingStar(Self);
      end;
    end;
  end
  else if Order = order_takeoff then
  begin
    if MovementPath.ActiveHead <> nil then AdvancePath;
  end
  else if Order = order_follow_ship then
  begin
    if MovementPath.ActiveHead <> nil then
    begin
      AdvancePath;
      if RecordFilm and (GetPlayer = Self) then PrimaryFilm.SetCameraAnchor(StepIndex, (OrderTarget as TShip).Position, True);
    end;
  end
  else raise Exception.Create('Error in TShip.StepDay');
  if RecordFilm and (AuxiliaryFilmObject <> nil) then
  begin
    if (FilmAlphaStep < 0) and (InterceptorPassesRemaining > 1) then InterceptorPassesRemaining := 1;
    if InterceptorPassesRemaining <= 0 then
      AuxiliaryFilmObject.SceneObject.SetAlpha(Min(255, Max(0, Round(Integer(AuxiliaryFilmObject.SceneObject.GetAlpha) - 5.1))))
    else if InterceptorPassesRemaining = 1 then
      AuxiliaryFilmObject.SceneObject.SetAlpha(Min(255, Max(0, Round(Integer(AuxiliaryFilmObject.SceneObject.GetAlpha) - 1.275))))
    else
      AuxiliaryFilmObject.SceneObject.SetAlpha(Min(255, Max(0, Round(Integer(AuxiliaryFilmObject.SceneObject.GetAlpha) + 2.55))));
    PrimaryFilm.SetObjectAlpha(StepIndex, AuxiliaryFilmObject, AuxiliaryFilmObject.SceneObject.GetAlpha);
  end;
end;
{ @end $6E5C6C }

{ @routine $6E698C TShip_ClearCompletedTakeoffOrHoleOrder }
procedure TShip.ClearCompletedTakeoffOrHoleOrder(UnusedStepIndex: Integer; UnusedRecordFilm: Boolean);
begin
  if IsHullDestroyed then Exit;
  if Order = order_takeoff then OrderNone(True)
  else if (Order = order_black_hole) and (OrderStateData = HoleExitOrderState) then OrderNone(True);
end;
{ @end $6E698C }

{ @routine $6E69D0 TShip_IsTravelCompletionPathReady }
function TShip.IsTravelCompletionPathReady: Boolean;
begin
  Result := True;
  repeat
    if Order = order_jump then
    begin
      if not InNormalSpace then Break;
      if MovementPath.ActiveHead = nil then Break;
      if JumpDeparturePathCommitted then Exit;
    end
    else if Order = order_black_hole then
    begin
      if (not InNormalSpace) or
        (OrderStateData = HoleExitOrderState) or
        (MovementPath.ActiveHead = nil) then Break;
      if PointDistanceSquared(MovementPath.ActiveTail.Position, OrderDestination) <= 0 then Exit;
    end
    else if Order = order_teleport then
    begin
      if InNormalSpace then Exit;
    end
    else if (Order = order_land) and (OrderTarget is TShip) then
    begin
      if MovementPath.ActiveHead = nil then Break;
      if PointDistanceSquared(AddPointsF((OrderTarget as TShip).Position, OrderDestination), MovementPath.ActiveTail.Position) <= 0 then Exit;
    end
    else if Order = order_land then
    begin
      if MovementPath.ActiveHead = nil then Break;
      if PointDistanceSquared((OrderTarget as TPlanet).PredictPosition(CurrentStar.MovementStepCount), MovementPath.ActiveTail.Position) < Sqr((OrderTarget as TPlanet).GraphicRadius) then Exit;
    end;
  until True;
  Result := False;
end;
{ @end $6E69D0 }

{ @routine $6E6B84 TShip_RepelFollowingShips }
procedure TShip.RepelFollowingShips;
var
  I, Count: Integer;
  Other: TShip;
  Distance, Overlap, VectorLength, Angle: Single;
  Delta, Offset: TPointF;
  SelfWeight, OtherWeight, Fraction: Single;
begin
  try
    Count := CurrentStar.Ships.Count;
    Offset.X := 0;
    Offset.Y := 0;
    SelfWeight := Max(0.01, CalculateSpeed / Max(0.01, PointDistance(RepulsionPosition, Position)));
    repeat
      I := 0;
      while I < Count do
      begin
        Other := CurrentStar.Ships[I];
        if (Self = Other) or (Other.Order <> order_follow_ship) then
        begin
          Inc(I);
          Continue;
        end;
        OtherWeight := Max(0.01, Other.CalculateSpeed / Max(0.01, PointDistance(Other.RepulsionPosition, Other.Position)));
        Fraction := SeededRandomIntRange(95, 105, Cardinal(Galaxy.CurrentTurn) * (Other.Seed + Seed)) * (SelfWeight / (SelfWeight + OtherWeight)) * 0.01;
        Distance := PointDistance(RepulsionPosition, Other.RepulsionPosition);
        Overlap := Distance - CollisionRadius - Other.CollisionRadius - 5;
        if Overlap < -0.01 then
        begin
          Overlap := -Overlap;
          if Distance <= 1 then
          begin
            Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, Cardinal(Galaxy.CurrentTurn) * (Other.Seed + Seed)));
            Delta.X := Sin(Angle) * Overlap;
            Delta.Y := -Cos(Angle) * Overlap;
          end
          else
          begin
            Distance := 1 / Distance * Overlap;
            Delta.X := (Other.RepulsionPosition.X - RepulsionPosition.X) * Distance;
            Delta.Y := (Other.RepulsionPosition.Y - RepulsionPosition.Y) * Distance;
          end;
          VectorLength := Sqrt(Delta.X * Delta.X + Delta.Y * Delta.Y);
          if VectorLength < 0.01 then
          begin
            Delta.X := 0.01 * Delta.X / VectorLength;
            Delta.Y := 0.01 * Delta.Y / VectorLength;
          end;
          Other.RepulsionPosition.X := Other.RepulsionPosition.X + Delta.X * Fraction;
          Other.RepulsionPosition.Y := Other.RepulsionPosition.Y + Delta.Y * Fraction;
          Offset.X := Offset.X - (1 - Fraction) * Delta.X;
          Offset.Y := Offset.Y - (1 - Fraction) * Delta.Y;
        end;
        Inc(I);
      end;
    until I >= Count;
    RepulsionPosition.X := RepulsionPosition.X + Offset.X;
    RepulsionPosition.Y := RepulsionPosition.Y + Offset.Y;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create(AnsiString('Error in procedure TShip.RepulsionShip ' + Name));
    end;
  end;
end;
{ @end $6E6B84 }

{ @routine $6E7140 TShip_RebuildMovePath }
procedure TShip.RebuildMovePath;
begin
  ClearMovementPath;
  AppendStarAvoidingPath(OrderDestination, CurrentStar.MovementStepCount);
  if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position
  else OrderDestination := Position;
end;
{ @end $6E7140 }

{ @routine $6E7198 TShip_BuildFullPathTo }
procedure TShip.BuildFullPathTo(Destination: TPointF);
begin
  ClearMovementPath;
  if MovementSpeed < 0.001 then Exit;
  AppendStarAvoidingPath(Destination, FullPathNodeLimit);
end;
{ @end $6E7198 }

{ @routine $6E71E0 TShip_BuildPlanetLandingPath }
procedure TShip.BuildPlanetLandingPath;
var
  Planet: TPlanet;
  Steps: Integer;
  Destination: TPointF;
begin
  ClearMovementPath;
  if MovementSpeed < 0.001 then Exit;
  if Order <> order_land then Exit;
  Planet := OrderTarget as TPlanet;
  Steps := 0;
  while True do
  begin
    Inc(Steps, BaseMovementStepsPerTurn);
    if Steps > 10000 then Break;
    Destination := AddPointsF(Planet.PredictPosition(Steps), OrderDestination);
    AppendStarAvoidingPath(Destination, Steps);
    if MovementPath.ActiveTail = nil then Break;
    if PointDistanceSquared(MovementPath.ActiveTail.Position, Destination) < MovementSpeed * MovementSpeed then
    begin
      MovementPath.ActiveTail.Position := Destination;
      Break;
    end;
  end;
end;
{ @end $6E71E0 }

{ @routine $6E72B4 TShip_BuildOrderMovementPath }
procedure TShip.BuildOrderMovementPath(MaximumNodes: Integer);
var
  Planet: TPlanet;
  Hole: THole;
  Point: TPointF;
  Ship: TShip;
  Steps: Integer;
  Angle, Distance, Radius, OuterRadius, InnerRadius, UpperDistance, LowerDistance: Single;
  Node: PSPathNode;
begin
  JumpDeparturePathCommitted := False;
  if (PlayerStar = CurrentStar) and (GetPlayer = Self) then MovementSpeed := Max(0.5, MovementSpeed);
  MovementDirection := WrapHeadingDegrees(MovementDirection);
  ClearMovementPath;
  if MovementSpeed < 0.001 then Exit;
  Steps := CurrentStar.MovementStepCount;
  if (TerronShip = Self) and (Order = order_move) and (Galaxy.TerronToStarTurn = 0) then
    AppendOrbitalPath(MaximumNodes)
  else
  begin
    if (Order = order_land) and (OrderTarget is TShip) then
    begin
      Ship := OrderTarget as TShip;
      Point := Ship.Position;
      if PointDistanceSquared(Point, Position) > Sqr(400.0) then
      begin
        Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, Ship.Id + Seed));
        Distance := 200;
        Point.X := Point.X + Sin(Angle) * Distance;
        Point.Y := Point.Y + -Cos(Angle) * Distance;
        AppendStarAvoidingPathWithTurnPadding(Point, MaximumNodes);
      end
      else
      begin
        AppendStarAvoidingPathWithTurnPadding(AddPointsF(Point, OrderDestination), MaximumNodes);
        if MovementPath.ActiveHead = nil then
        begin
          OrderDestination := MakePointF(RandomIntRange(-5, 5), RandomIntRange(-5, 5));
          AppendStarAvoidingPathWithTurnPadding(AddPointsF(Point, OrderDestination), MaximumNodes);
        end;
      end;
    end
    else if Order = order_land then
    begin
      Planet := OrderTarget as TPlanet;
      OuterRadius := Planet.GraphicRadius + 150;
      InnerRadius := Planet.GraphicRadius + 50;
      if GetPlayer = Self then
      begin
        Point := AddPointsF(Planet.PredictPosition(Steps), OrderDestination);
        if PointDistanceSquared(Position, Planet.GetPosition) > Sqr(OuterRadius) then
          if PointDistanceSquared(Point, Planet.PredictPosition(Steps)) <= Sqr(InnerRadius) then
          begin
            Distance := PointDistance(Point, Position);
            Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(Position, Point)));
            repeat
              Distance := 0.5 * Distance;
              Point := Position;
              Point.X := Point.X + Sin(Angle) * Distance;
              Point.Y := Point.Y - Cos(Angle) * Distance;
            until (PointDistanceSquared(Point, Planet.PredictPosition(Steps)) > Sqr(InnerRadius)) or (Distance <= 30);
            UpperDistance := Distance * 2;
            LowerDistance := Distance;
            while UpperDistance - LowerDistance > 10 do
            begin
              Distance := (UpperDistance + LowerDistance) * 0.5;
              Point := Position;
              Point.X := Point.X + Sin(Angle) * Distance;
              Point.Y := Point.Y - Cos(Angle) * Distance;
              if PointDistanceSquared(Point, Planet.PredictPosition(Steps)) > Sqr(InnerRadius) then LowerDistance := Distance
              else UpperDistance := Distance;
            end;
            Distance := LowerDistance;
            Point := Position;
            Point.X := Point.X + Sin(Angle) * Distance;
            Point.Y := Point.Y - Cos(Angle) * Distance;
          end;
      end
      else
      begin
        Point := Planet.PredictPosition(Steps);
        Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(Planet.GetPosition, Position) + SeededRandomIntRange(-20, 20, Seed + Planet.GenerationSeed)));
        if PointDistanceSquared(Planet.GetPosition, Position) > Sqr(OuterRadius) then Distance := InnerRadius
        else Distance := (Abs(Planet.GenerationSeed + Seed + CurrentStar.GenerationSeed) mod Planet.GraphicRadius) * 0.7;
        Point.X := Point.X + Sin(Angle) * Distance;
        Point.Y := Point.Y + -Cos(Angle) * Distance;
      end;
      if (Position.X <> Point.X) or (Position.Y <> Point.Y) then AppendStarAvoidingPathWithTurnPadding(Point, MaximumNodes);
    end
    else if Order = order_black_hole then
    begin
      if OrderStateData = HoleExitOrderState then AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes)
      else
      begin
        Hole := OrderTarget as THole;
        if OrderStateData shr 16 = 0 then Point := Hole.Position1 else Point := Hole.Position2;
        if PointDistanceSquared(Point, Position) > Sqr(200.0) then
        begin
          Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(Point, Position) + SeededRandomIntRange(-20, 20, Hole.Id + Seed)));
          Distance := 100;
          Point.X := Point.X + Sin(Angle) * Distance;
          Point.Y := Point.Y + -Cos(Angle) * Distance;
          AppendStarAvoidingPathWithTurnPadding(Point, MaximumNodes);
        end
        else AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes);
      end;
    end
    else if Order = order_follow_ship then
    begin
      Ship := OrderTarget as TShip;
      Radius := CalculateFollowRadius;
      if Ship.MovementPath.ActiveHead = nil then
      begin
        AppendStarAvoidingPathWithTurnPadding(PointBehindHeading(Ship.Position, Ship.MovementDirection, Radius, Abs(Ship.Seed + Seed)), MaximumNodes);
        if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
        Exit;
      end;
      if Ship.MovementPath.NodeCount <= Steps then
      begin
        AppendStarAvoidingPathWithTurnPadding(PointBehindHeading(Ship.MovementPath.ActiveTail.Position, Ship.MovementPath.ActiveTail.Heading, Radius, Abs(Ship.Seed + Seed)), MaximumNodes);
        if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
        Exit;
      end;
      Node := Ship.MovementPath.GetFollowingNode(Ship.MovementPath.ActiveHead, Steps - 1);
      AppendStarAvoidingPathWithTurnPadding(PointBehindHeading(Node.Position, Node.Heading, Radius, Abs(Ship.Seed + Seed)), MaximumNodes);
      if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
    end
    else if Order = order_jump then
    begin
      Radius := CurrentStar.ComputeMapDiameter / 2 - 400;
      Radius := Radius * Radius;
      if Position.X * Position.X + Position.Y * Position.Y > Radius then
      begin
        if Abs(HeadingDifferenceDegrees(PointBearingDegrees(CurrentStar.Position, (OrderTarget as TStar).Position), PointBearingDegrees(MakePointF(0, 0), Position))) <= 5 then
        begin
          Angle := Abs(HeadingDifferenceDegrees(MovementDirection, RadiansToHeadingDegrees(ArcTan2(-Position.X, Position.Y))));
          if ((Angle >= 125) and (Speed > 200)) or (Angle >= 175) then
          begin
            if (Angle < 175) and (Speed >= 200) and (PlayerStar = CurrentStar) then
            begin
              Distance := 1 / Sqrt(Position.X * Position.X + Position.Y * Position.Y);
              Point.X := Position.X + Position.X * Distance * 10000;
              Point.Y := Position.Y + Position.Y * Distance * 10000;
              AppendTurningPath(Point, False, MaximumNodes);
            end;
            AppendHyperspaceTransitionPath(1);
            if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
            JumpDeparturePathCommitted := True;
          end
          else
          begin
            Distance := 1 / Sqrt(Position.X * Position.X + Position.Y * Position.Y);
            OrderDestination.X := Position.X + Position.X * Distance * Max(250, Speed * 0.25);
            OrderDestination.Y := Position.Y + Position.Y * Distance * Max(250, Speed * 0.25);
            AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes);
          end;
        end
        else AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes);
      end
      else AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes);
    end
    else if (Order = order_move) or (Order = order_jump) or (Order = order_takeoff) then
      AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes);
  end;
end;
{ @end $6E72B4 }

{ @routine $6E7FC0 TShip_AppendPathToWithTurnPadding }
procedure TShip.AppendPathToWithTurnPadding(Destination: TPointF; MaximumNodes: Integer);
var
  Step: Single;
begin
  AppendTurningPath(Destination, False, MaximumNodes);
  AppendStraightPath(Destination, MaximumNodes);
  if (PlayerStar = CurrentStar) and (MovementPath.NodeCount < BaseMovementStepsPerTurn) and
    ((GetPlayer.CurrentPlanet = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.Order = order_takeoff))) then
    MovementPath.ResampleBezierRange(MovementPath.ActiveHead, MovementPath.ActiveTail, BaseMovementStepsPerTurn);
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if MovementPath.ActiveHead <> nil then
  begin
    if PointDistanceSquared(MovementPath.ActiveTail.Position, Destination) < Step * Step then
      MovementPath.ActiveTail.Position := Destination;
  end;
end;
{ @end $6E7FC0 }

{ @routine $6E80A8 TShip_AppendPathTo }
procedure TShip.AppendPathTo(Destination: TPointF; MaximumNodes: Integer);
var
  Step: Single;
begin
  AppendTurningPath(Destination, False, MaximumNodes);
  AppendStraightPath(Destination, MaximumNodes);
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if MovementPath.ActiveHead <> nil then
  begin
    if PointDistanceSquared(MovementPath.ActiveTail.Position, Destination) < Step * Step then
      MovementPath.ActiveTail.Position := Destination;
  end;
end;
{ @end $6E80A8 }

{ @routine $6E8138 TShip_AppendStarAvoidingPathWithTurnPadding }
procedure TShip.AppendStarAvoidingPathWithTurnPadding(Destination: TPointF; MaximumNodes: Integer);
var
  Step: Single;
begin
  AppendStarAvoidingPath(Destination, MaximumNodes);
  if (PlayerStar = CurrentStar) and (MovementPath.NodeCount < BaseMovementStepsPerTurn) and
    ((GetPlayer.CurrentPlanet = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.Order = order_takeoff))) then
    MovementPath.ResampleBezierRange(MovementPath.ActiveHead, MovementPath.ActiveTail, BaseMovementStepsPerTurn);
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if MovementPath.ActiveHead <> nil then
  begin
    if PointDistanceSquared(MovementPath.ActiveTail.Position, Destination) < Step * Step then
      MovementPath.ActiveTail.Position := Destination;
  end;
end;
{ @end $6E8138 }

{ @routine $6E820C TShip_AppendOrbitalPath }
procedure TShip.AppendOrbitalPath(MaximumNodes: Integer);
var
  Node: PSPathNode;
  I: Integer;
  Radius, Angle, Step: Single;
  Point: TPointF;
begin
  if MaximumNodes > BaseMovementStepsPerTurn then MaximumNodes := BaseMovementStepsPerTurn;
  if MovementPath.ActiveTail = nil then Point := Position
  else Point := MovementPath.ActiveTail.Position;
  Radius := Sqrt(Point.X * Point.X + Point.Y * Point.Y);
  Angle := ArcTan2(Point.X, -Point.Y);
  if Radius = 0 then Step := 0 else Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale / Radius;
  for I := 0 to MaximumNodes - 1 do
  begin
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position.X := Sin(Angle) * Radius;
    Node.Position.Y := -Cos(Angle) * Radius;
    Node.Heading := 0;
    Angle := Angle + Step;
  end;
  if (CurrentStar = PlayerStar) and (MovementPath.NodeCount < BaseMovementStepsPerTurn) then
    MovementPath.ResampleBezierRange(MovementPath.ActiveHead, MovementPath.ActiveTail, BaseMovementStepsPerTurn);
end;
{ @end $6E820C }

{ @routine $6E836C TShip_AppendTurningPath }
procedure TShip.AppendTurningPath(Destination: TPointF; AvoidStar: Boolean; MaximumNodes: Integer);
var
  Node: PSPathNode;
  Point, Output, Center: TPointF;
  TurnStep, Step, Angle, TargetAngle, Difference, TurnSign, TangentStep: Double;
  PreviousRadiusSquared, MiddleRadiusSquared, RadiusSquared: Double;
  StartRadialAngle, EndRadialAngle, ArcStart, ArcEnd: Single;
  TooClose: Boolean;
begin
  if MovementPath.ActiveTail = nil then
  begin
    Point := Position;
    Angle := MovementDirection;
  end
  else
  begin
    Point := MovementPath.ActiveTail.Position;
    Angle := MovementPath.ActiveTail.Heading;
  end;
  if (Point.X = Destination.X) and (Point.Y = Destination.Y) then
  begin
    if (MovementPath.ActiveHead = nil) and (Order = order_black_hole) then
      while MovementPath.NodeCount < MaximumNodes do
      begin
        MovementPath.AppendNode;
        Node := MovementPath.ActiveTail;
        Output.X := Point.X + (Cos(HeadingDegreesToRadians(Angle)) - Cos(HeadingDegreesToRadians(Angle + 360 * MovementPath.NodeCount / MaximumNodes))) * 30;
        Output.Y := Point.Y + (Sin(HeadingDegreesToRadians(Angle)) - Sin(HeadingDegreesToRadians(Angle + 360 * MovementPath.NodeCount / MaximumNodes))) * 30;
        Node.Position := Output;
        Node.Heading := Angle + 360 * MovementPath.NodeCount / MaximumNodes;
      end;
    Exit;
  end;
  TurnStep := MovementTurnRate * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if (Order = order_takeoff) or ((Order = order_black_hole) and (OrderStateData = HoleExitOrderState)) then
  begin
    Step := Step / 2;
    TurnStep := TurnStep / 2;
  end;
  // The native code compares squared distance with the unsquared step here.
  if PointDistanceSquared(Point, Destination) < Step then
  begin
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position := Point;
    Node.Heading := Angle;
    Exit;
  end;
  TargetAngle := RadiansToHeadingDegrees(ArcTan2(-(Point.X - Destination.X), Point.Y - Destination.Y));
  TurnSign := HeadingDifferenceDegrees(Angle, TargetAngle);
  if Abs(TurnSign) < TurnStep then Exit;
  if AvoidStar then
  begin
    StartRadialAngle := RadiansToHeadingDegrees(ArcTan2(Point.X, -Point.Y));
    EndRadialAngle := RadiansToHeadingDegrees(ArcTan2(Destination.X, -Destination.Y));
    if HeadingDifferenceDegrees(StartRadialAngle, EndRadialAngle) <= 0 then
    begin
      ArcStart := RadiansToHeadingDegrees(ArcTan2(-Point.X, Point.Y));
      ArcEnd := RadiansToHeadingDegrees(ArcTan2(Destination.X - Point.X, -(Destination.Y - Point.Y)));
      if HeadingWithinArc(ArcStart, Angle, ArcEnd) then TurnSign := 1 else TurnSign := -1;
    end
    else
    begin
      ArcStart := RadiansToHeadingDegrees(ArcTan2(-Point.X, Point.Y));
      ArcEnd := RadiansToHeadingDegrees(ArcTan2(Destination.X - Point.X, -(Destination.Y - Point.Y)));
      if HeadingWithinArc(ArcStart, Angle, ArcEnd) then TurnSign := -1 else TurnSign := 1;
    end;
  end;
  MiddleRadiusSquared := -1;
  RadiusSquared := -1;
  TangentStep := CalculateTangentArcOffset(Point, Destination, Angle, TurnStep);
  if TangentStep < Step then Step := TangentStep;
  if TurnSign > 0 then TargetAngle := Angle + 90 else TargetAngle := Angle - 90;
  repeat
    Center.X := Point.X + (Step / HeadingDegreesToRadians(TurnStep)) * Sin(HeadingDegreesToRadians(TargetAngle));
    Center.Y := Point.Y - (Step / HeadingDegreesToRadians(TurnStep)) * Cos(HeadingDegreesToRadians(TargetAngle));
    TooClose := PointDistanceSquared(Center, Destination) * 0.95 < PointDistanceSquared(Center, Point);
    if TooClose then Step := Step * 0.9;
  until not TooClose;
  while (Point.X <> Destination.X) or (Point.Y <> Destination.Y) do
  begin
    if AvoidStar then
    begin
      PreviousRadiusSquared := MiddleRadiusSquared;
      MiddleRadiusSquared := RadiusSquared;
      RadiusSquared := Point.X * Point.X + Point.Y * Point.Y;
      if (PreviousRadiusSquared <> -1) and (PreviousRadiusSquared < MiddleRadiusSquared) and (RadiusSquared < MiddleRadiusSquared) then Break;
    end;
    TargetAngle := RadiansToHeadingDegrees(ArcTan2(-(Point.X - Destination.X), Point.Y - Destination.Y));
    Difference := HeadingDifferenceDegrees(Angle, TargetAngle);
    if Abs(Difference) <= TurnStep then Break;
    if TurnSign > 0 then Angle := WrapHeadingDegrees(Angle + TurnStep)
    else Angle := WrapHeadingDegrees(Angle - TurnStep);
    Point.X := Point.X + Sin(HeadingDegreesToRadians(Angle)) * Step;
    Point.Y := Point.Y - Cos(HeadingDegreesToRadians(Angle)) * Step;
    if (Point.X - Destination.X) * (Point.X - Destination.X) + (Point.Y - Destination.Y) * (Point.Y - Destination.Y) <= Step * Step then
      Point := Destination;
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position := Point;
    Node.Heading := Angle;
    if MovementPath.NodeCount >= MaximumNodes then Break;
  end;
end;
{ @end $6E836C }

{ @routine $6E8B28 TShip_AppendStraightPath }
procedure TShip.AppendStraightPath(Destination: TPointF; MaximumNodes: Integer);
var
  UseY: Boolean;
  Distance, Travelled, Slope, Scale, Origin, Heading: Double;
  Output: TPointF;
  Point: TPointF;
  Node: PSPathNode;
  Step: Double;
begin
  if MovementPath.ActiveTail = nil then Point := Position else Point := MovementPath.ActiveTail.Position;
  if (Point.X = Destination.X) and (Point.Y = Destination.Y) then Exit;
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if (Order = order_takeoff) or ((Order = order_black_hole) and (OrderStateData = HoleExitOrderState)) then Step := Min(2, Step / 2);
  Heading := RadiansToHeadingDegrees(ArcTan2(-(Point.X - Destination.X), Point.Y - Destination.Y));
  if Abs(Point.X - Destination.X) < Abs(Point.Y - Destination.Y) then UseY := True else UseY := False;
  Distance := Sqrt((Point.X - Destination.X) * (Point.X - Destination.X) + (Point.Y - Destination.Y) * (Point.Y - Destination.Y));
  if UseY then
  begin
    Slope := (Destination.X - Point.X) / (Destination.Y - Point.Y);
    Scale := 1 / Sqrt(Slope * Slope + 1);
    if Destination.Y - Point.Y < 0 then Scale := -Scale;
    Origin := Point.Y;
  end
  else
  begin
    Slope := (Destination.Y - Point.Y) / (Destination.X - Point.X);
    Scale := 1 / Sqrt(Slope * Slope + 1);
    if Destination.X - Point.X < 0 then Scale := -Scale;
    Origin := Point.X;
  end;
  Travelled := Step;
  if Travelled >= Distance then
  begin
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position := Destination;
    Node.Heading := Heading;
    Exit;
  end;
  while Travelled < Distance do
  begin
    if UseY then
    begin
      Output.Y := Origin + Travelled * Scale;
      Output.X := Point.X + (Output.Y - Point.Y) * Slope;
    end
    else
    begin
      Output.X := Origin + Travelled * Scale;
      Output.Y := Point.Y + (Output.X - Point.X) * Slope;
    end;
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position := Output;
    Node.Heading := Heading;
    if MovementPath.NodeCount >= MaximumNodes then Break;
    Travelled := Travelled + Step;
  end;
end;
{ @end $6E8B28 }

{ @routine $6E8E70 TShip_AppendHyperspaceTransitionPath }
procedure TShip.AppendHyperspaceTransitionPath(Direction: Single);
var
  Point: TPointF;
  Heading, Speed, Increment, SinHeading, CosHeading, Minimum, Maximum: Single;
  Count, I: Integer;
  Node: PSPathNode;
begin
  I := 0;
  if MovementPath.ActiveTail = nil then
  begin
    Point := Position;
    Heading := MovementDirection;
  end
  else
  begin
    Point := MovementPath.ActiveTail.Position;
    Heading := MovementPath.ActiveTail.Heading;
    if PlayerStar = CurrentStar then I := Min(100, MovementPath.NodeCount mod BaseMovementStepsPerTurn);
  end;
  Count := CurrentStar.MovementStepCount;
  Minimum := 1 / (BaseMovementStepsPerTurn * CurrentStar.MovementStepScale);
  Maximum := 300 / (Count - I);
  if Direction > 0 then
  begin
    Speed := Minimum;
    Increment := (Maximum - Minimum) / (Count - I);
  end
  else
  begin
    Speed := Maximum;
    Increment := -((Maximum - Minimum) / (Count - I));
  end;
  SinHeading := Sin(HeadingDegreesToRadians(Heading));
  CosHeading := Cos(HeadingDegreesToRadians(Heading));
  // The native increment is applied once, before the loop.
  Speed := Speed + Increment;
  while I < Count do
  begin
    Point.X := Point.X + SinHeading * Speed;
    Point.Y := Point.Y - CosHeading * Speed;
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position := Point;
    Node.Heading := Heading;
    Inc(I);
  end;
end;
{ @end $6E8E70 }

{ @routine $6E9014 TShip_AppendStarAvoidingPath }
procedure TShip.AppendStarAvoidingPath(Destination: TPointF; MaximumNodes: Integer);
var
  Point: TPointF;
  Radius: Double;
  StartTangent, OtherStartTangent, EndTangent, OtherEndTangent, PreviousTangent: TPointF;
begin
  if MovementPath.ActiveTail = nil then Point := Position else Point := MovementPath.ActiveTail.Position;
  Radius := CurrentStar.SafeRadius;
  Point := PushPointOutsideCircleBand(Point, Radius, 2);
  if not SegmentCrossesOriginCircle(Point, Destination, Radius) then
  begin
    if MaximumNodes < 20 then AppendPathTo(Destination, MaximumNodes)
    else AppendPathToWithTurnPadding(Destination, MaximumNodes);
  end
  else
  begin
    CircleTangentPoints(Point, Radius, StartTangent, OtherStartTangent);
    CircleTangentPoints(Destination, Radius, EndTangent, OtherEndTangent);
    if PointDistanceSquared(StartTangent, OtherEndTangent) < PointDistanceSquared(OtherStartTangent, EndTangent) then
      EndTangent := OtherEndTangent
    else StartTangent := OtherStartTangent;
    if Point.X * Point.X + Point.Y * Point.Y < (Radius * 2) * (Radius * 2) then
    begin
      AppendTurningPath(StartTangent, True, MaximumNodes);
      if MovementPath.NodeCount >= MaximumNodes then Exit;
      if MovementPath.ActiveTail = nil then Point := Position else Point := MovementPath.ActiveTail.Position;
      Point := PushPointOutsideCircleBand(Point, Radius, 2);
      if not SegmentCrossesOriginCircle(Point, Destination, Radius) then
      begin
        AppendPathTo(Destination, MaximumNodes);
        Exit;
      end;
      if Round(Point.X * Point.X + Point.Y * Point.Y) < Round(Radius * Radius) then
      begin
        if MaximumNodes < 20 then AppendPathTo(Destination, MaximumNodes)
        else AppendPathToWithTurnPadding(Destination, MaximumNodes);
        Exit;
      end;
      PreviousTangent := StartTangent;
      CircleTangentPoints(Point, Radius, StartTangent, OtherStartTangent);
      CircleTangentPoints(Destination, Radius, EndTangent, OtherEndTangent);
      if PointDistanceSquared(StartTangent, PreviousTangent) > PointDistanceSquared(OtherStartTangent, PreviousTangent) then
        StartTangent := OtherStartTangent;
      if PointDistanceSquared(StartTangent, OtherEndTangent) < PointDistanceSquared(StartTangent, EndTangent) then
        EndTangent := OtherEndTangent;
      AppendPathTo(StartTangent, MaximumNodes);
      if MovementPath.NodeCount >= MaximumNodes then Exit;
    end
    else
    begin
      AppendPathTo(StartTangent, MaximumNodes);
      if MovementPath.NodeCount >= MaximumNodes then Exit;
    end;
    AppendCircularDetour(EndTangent, MaximumNodes, Radius);
    if MovementPath.NodeCount >= MaximumNodes then Exit;
    AppendStraightPath(Destination, MaximumNodes);
  end;
end;
{ @end $6E9014 }

{ @routine $6E939C TShip_AppendCircularDetour }
procedure TShip.AppendCircularDetour(Destination: TPointF; MaximumNodes: Integer; Radius: Double);
var
  Node: PSPathNode;
  Point: TPointF;
  FromHeading, Heading, ToHeading, Step, Difference, DistancePerStep: Double;
begin
  if MovementPath.ActiveTail = nil then Point := Position else Point := MovementPath.ActiveTail.Position;
  FromHeading := RadiansToHeadingDegrees(ArcTan2(Point.X, -Point.Y));
  ToHeading := RadiansToHeadingDegrees(ArcTan2(Destination.X, -Destination.Y));
  DistancePerStep := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  Step := DistancePerStep * 180 / (GamePi * Radius);
  Difference := HeadingDifferenceDegrees(FromHeading, ToHeading);
  if Difference < 0 then Step := -Step;
  if Abs(Difference) <= 5 then
  begin
    AppendPathTo(Destination, MaximumNodes);
    Exit;
  end;
  while FromHeading <> ToHeading do
  begin
    FromHeading := FromHeading + Step;
    if FromHeading < 0 then FromHeading := 360 + FromHeading;
    if FromHeading >= 360 then FromHeading := FromHeading - 360;
    if Abs(HeadingDifferenceDegrees(FromHeading, ToHeading)) < Abs(Step) then FromHeading := ToHeading;
    Point.X := Sin(HeadingDegreesToRadians(FromHeading)) * Radius;
    Point.Y := -Cos(HeadingDegreesToRadians(FromHeading)) * Radius;
    if Step < 0 then Heading := FromHeading - 90 else Heading := FromHeading + 90;
    if Heading < 0 then Heading := 360 + Heading;
    if Heading >= 360 then Heading := Heading - 360;
    MovementPath.AppendNode;
    Node := MovementPath.ActiveTail;
    Node.Position := Point;
    Node.Heading := Heading;
    if MovementPath.NodeCount >= MaximumNodes then Break;
  end;
end;
{ @end $6E939C }

{ @routine $6E9638 TShip_ClearMovementPath }
procedure TShip.ClearMovementPath;
begin
  MovementPath.Clear;
end;
{ @end $6E9638 }

{ @routine $6E9644 TShip_GetSlotCount }
function TShip.GetSlotCount(SlotKind: TShipSlotKind): Integer;
begin
  Result := GetHull.GetSlotCount(SlotKind);
  case SlotKind of
    slot_radar: Inc(Result, GetOwnStatBonus(bonus_radar_slots));
    slot_scanner: Inc(Result, GetOwnStatBonus(bonus_scanner_slots));
    slot_repair_robot: Inc(Result, GetOwnStatBonus(bonus_repair_robot_slots));
    slot_cargo_hook: Inc(Result, GetOwnStatBonus(bonus_cargo_hook_slots));
    slot_defense_generator: Inc(Result, GetOwnStatBonus(bonus_defense_slots));
    slot_weapon: Inc(Result, GetOwnStatBonus(bonus_weapon_slots));
    slot_artefact: Inc(Result, GetOwnStatBonus(bonus_artefact_slots));
    slot_afterburner: Inc(Result, GetOwnStatBonus(bonus_afterburner_slots));
  end;
  Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result));
  if Artefacts.Count > 0 then
  begin
    if SlotKind = slot_weapon then
    begin
      if (CountActiveArtefacts(artefact_weapon_to_speed) > 0) and not CanBoostArtefact(artefact_weapon_to_speed, GetHull, False) then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result - CountActiveArtefacts(artefact_weapon_to_speed)));
      if (CountActiveArtefacts(artefact_defense_to_weapon_slot) > 0) and (GetDefGenerator <> nil) then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result + CountActiveArtefacts(artefact_defense_to_weapon_slot)));
      if (CountActiveArtefacts(artefact_defense_slot_to_weapons) > 0) and (GetHull.GetSlotCount(slot_defense_generator) > 0) then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result + 1 + CountActiveArtefacts(artefact_defense_slot_to_weapons)));
    end
    else if SlotKind = slot_defense_generator then
    begin
      if CountActiveArtefacts(artefact_defense_slot_to_weapons) > 0 then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result - 1));
    end
    else if SlotKind = slot_repair_robot then
    begin
      if CountActiveArtefacts(artefact_artefactor) > 0 then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result - 1));
    end
    else if (SlotKind = slot_artefact) and (Result > 0) and (CountActiveArtefacts(artefact_artefactor) > 0) and
      (GetHull.GetSlotCount(slot_repair_robot) > 0) then
      Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result + 3));
  end;
end;
{ @end $6E9644 }

{ @routine $6E9964 TShip_GetSlotCountForItemType }
function TShip.GetSlotCountForItemType(ItemType: TItemType): Integer;
begin
  Result := GetSlotCount(ItemTypeToSlotKind(ItemType));
end;
{ @end $6E9964 }

{ @routine $6E9980 TShip_ReassignActiveItemSlots }
procedure TShip.ReassignActiveItemSlots(ItemType: TItemType);
var
  Used: Cardinal;
  Count, I, J, Slot: Integer;
  Item: TEquipment;
  Kind, ItemKind: TShipSlotKind;
  NoFreeSlot: Boolean;
begin
  Used := 0;
  Count := GetSlotCountForItemType(ItemType);
  Kind := ItemTypeToSlotKind(ItemType);
  if Kind <> slot_artefact then
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.EquippedFlag = 0 then Continue;
      ItemKind := ItemTypeToSlotKind(Item.ItemType);
      if Kind = ItemKind then
      begin
        Slot := Item.AssignedSlotData and EquipmentSlotIndexMask;
        if (Slot < 0) or (Slot >= Count) or ((Used shr Slot) and 1 = 1) then
        begin
          NoFreeSlot := True;
          for J := 0 to Count - 1 do
            if (Used shr J) and 1 = 0 then
            begin
              Item.AssignedSlotData := (Item.AssignedSlotData and EquipmentSecondaryFireFlag) or J;
              Used := Used or (1 shl J);
              NoFreeSlot := False;
              Break;
            end;
          if NoFreeSlot then Item.Unequip;
        end
        else Used := Used or (1 shl (Item.AssignedSlotData and EquipmentSlotIndexMask));
      end;
    end;
  end
  else
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      if Item.EquippedFlag = 0 then Continue;
      ItemKind := ItemTypeToSlotKind(Item.ItemType);
      if Kind = ItemKind then
      begin
        Slot := Item.AssignedSlotData and EquipmentSlotIndexMask;
        if (Slot < 0) or (Slot >= Count) or ((Used shr Slot) and 1 = 1) then
        begin
          NoFreeSlot := True;
          for J := 0 to Count - 1 do
            if (Used shr J) and 1 = 0 then
            begin
              Item.AssignedSlotData := (Item.AssignedSlotData and EquipmentSecondaryFireFlag) or J;
              Used := Used or (1 shl J);
              NoFreeSlot := False;
              Break;
            end;
          if NoFreeSlot then Item.Unequip;
        end
        else Used := Used or (1 shl (Item.AssignedSlotData and EquipmentSlotIndexMask));
      end;
    end;
  end;
end;
{ @end $6E9980 }

{ @routine $6E9B74 TShip_RefreshAssignedItemSlots }
procedure TShip.RefreshAssignedItemSlots;
begin
  ReassignActiveItemSlots(item_fuel_tanks);
  ReassignActiveItemSlots(item_engine);
  ReassignActiveItemSlots(item_radar);
  ReassignActiveItemSlots(item_scanner);
  ReassignActiveItemSlots(item_repair_robot);
  ReassignActiveItemSlots(item_cargo_hook);
  ReassignActiveItemSlots(item_defense_generator);
  ReassignActiveItemSlots(WeaponCategoryItemType);
  ReassignActiveItemSlots(item_custom_artefact);
  RefreshInactiveItemSlotAssignments;
end;
{ @end $6E9B74 }

{ @routine $6E9BD4 TShip_FindEquippedItemInSlot }
function TShip.FindEquippedItemInSlot(ItemType: TItemType; SlotIndex: Integer): TEquipment;
var I: Integer; Item: TEquipment; Kind: TShipSlotKind;
begin
  Kind := ItemTypeToSlotKind(ItemType);
  if Kind <> slot_artefact then
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item.EquippedFlag <> 0) and (ItemTypeToSlotKind(Item.ItemType) = Kind) and
         (Integer(Item.AssignedSlotData) and EquipmentSlotIndexMask = SlotIndex) then
      begin
        Result := Item;
        Exit;
      end;
    end;
  end
  else
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      if (Item.EquippedFlag <> 0) and (Integer(Item.AssignedSlotData) and EquipmentSlotIndexMask = SlotIndex) then
      begin
        Result := Item;
        Exit;
      end;
    end;
  Result := nil;
end;
{ @end $6E9BD4 }

{ @routine $6E9C80 TShip_RefreshInactiveItemSlotAssignments }
procedure TShip.RefreshInactiveItemSlotAssignments;
var
  I, Count: Integer;
  Item: TEquipment;
begin
  Count := Inventory.Count;
  for I := Count - 1 downto 0 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag = 0) then
      if (CountUnequippedItemsInSlot(Item.AssignedSlotData and EquipmentSlotIndexMask) > 1) then
      Item.AssignedSlotData := FindFreeUnequippedSlot or (Item.AssignedSlotData and EquipmentSecondaryFireFlag);
  end;
end;
{ @end $6E9C80 }

{ @routine $6E9CDC TShip_CountUnequippedItemsInSlot }
function TShip.CountUnequippedItemsInSlot(SlotIndex: Integer): Integer;
var
  I, Count, Found: Integer;
  Item: TEquipment;
begin
  Found := 0;
  Count := Inventory.Count;
  for I := 0 to Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag = 0) and (Integer(Item.AssignedSlotData and EquipmentSlotIndexMask) = SlotIndex) then Inc(Found);
  end;
  Result := Found;
end;
{ @end $6E9CDC }

{ @routine $6E9D28 TShip_FindFreeUnequippedSlot }
function TShip.FindFreeUnequippedSlot: Integer;
var
  SlotIndex: Integer;
begin
  SlotIndex := 0;
  while CountUnequippedItemsInSlot(SlotIndex) > 0 do Inc(SlotIndex);
  Result := SlotIndex;
end;
{ @end $6E9D28 }

{ @routine $6E9D44 TShip_RepairDuplicateSatelliteTrajectoryIndices }
procedure TShip.RepairDuplicateSatelliteTrajectoryIndices;
var
  I, J, Count: Integer;
  First, Second: TItem;
begin
  Count := Inventory.Count;
  for I := 0 to Count - 1 do
  begin
    First := Inventory[I];
    if First.ItemType = item_satellite then
      for J := I + 1 to Count - 1 do
      begin
        Second := Inventory[J];
        if (Second.ItemType = item_satellite) and
          ((Second as TSatellite).TrajectoryIndex = (First as TSatellite).TrajectoryIndex) then
          (Second as TSatellite).TrajectoryIndex := FindFreeSatelliteTrajectoryIndex;
      end;
  end;
end;
{ @end $6E9D44 }

{ @routine $6E9E0C TShip_GetSatelliteTrajectoryIndexLimit }
function TShip.GetSatelliteTrajectoryIndexLimit: Integer;
var
  I, Count: Integer;
  Item: TItem;
begin
  Result := 0;
  Count := Inventory.Count;
  for I := 0 to Count - 1 do
  begin
    Item := Inventory[I];
    if Item.ItemType = item_satellite then Result := Max(Result, (Item as TSatellite).TrajectoryIndex + 1);
  end;
end;
{ @end $6E9E0C }

{ @routine $6E9E6C TShip_FindFreeSatelliteTrajectoryIndex }
function TShip.FindFreeSatelliteTrajectoryIndex: Integer;
var
  I, Count: Integer;
  Item: TItem;
begin
  Result := 0;
  Count := Inventory.Count;
  while True do
  begin
    I := 0;
    while I < Count do
    begin
      Item := Inventory[I];
      if (Item.ItemType = item_satellite) and ((Item as TSatellite).TrajectoryIndex = Result) then Break;
      Inc(I);
    end;
    if I >= Count then Break;
    Inc(Result);
  end;
end;
{ @end $6E9E6C }

{ @routine $6E9EC8 TShip_FindSatelliteByTrajectoryIndex }
function TShip.FindSatelliteByTrajectoryIndex(Index: Integer): TSatellite;
var
  I: Integer;
  Item: TItem;
begin
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = item_satellite) and ((Item as TSatellite).TrajectoryIndex = Index) then
    begin
      Result := TSatellite(Item);
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $6E9EC8 }

{ @routine $6E9F20 TShip_InsertSatelliteTrajectoryIndex }
procedure TShip.InsertSatelliteTrajectoryIndex(Index: Integer);
var
  I: Integer;
  Item: TItem;
begin
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = item_satellite) and ((Item as TSatellite).TrajectoryIndex >= Index) then
      Inc((Item as TSatellite).TrajectoryIndex);
  end;
end;
{ @end $6E9F20 }

{ @routine $6E9F80 TShip_RemoveEmptySatelliteTrajectoryIndex }
procedure TShip.RemoveEmptySatelliteTrajectoryIndex(Index: Integer);
var
  I: Integer;
  Item: TItem;
begin
  if FindSatelliteByTrajectoryIndex(Index) <> nil then Exit;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = item_satellite) and ((Item as TSatellite).TrajectoryIndex >= Index) then
      Dec((Item as TSatellite).TrajectoryIndex);
  end;
end;
{ @end $6E9F80 }

{ @routine $6E9FF0 TShip_CompactSatelliteTrajectoryIndices }
procedure TShip.CompactSatelliteTrajectoryIndices;
var
  I: Integer;
begin
  I := 0;
  while True do
  begin
    if GetSatelliteTrajectoryIndexLimit <= I then Break;
    if FindSatelliteByTrajectoryIndex(I) = nil then RemoveEmptySatelliteTrajectoryIndex(I)
    else Inc(I);
  end;
end;
{ @end $6E9FF0 }

{ @routine $6EA040 TShip_AssignSatelliteIndicesFromHoldOrder }
procedure TShip.AssignSatelliteIndicesFromHoldOrder;
var Indices: array of Integer; I, Next, Count: Integer; Item: TEquipment; Entry: TPlayerHoldUnit;
begin
  if Inventory.Count > 0 then begin
    RepairDuplicateSatelliteTrajectoryIndices;
    RefreshAssignedItemSlots;
    PlayerHoldShip := Self;
    RefreshPlayerHoldView(True);
    SetLength(Indices, Inventory.Count);
    Count := 0;
    for I := 0 to GetSatelliteTrajectoryIndexLimit - 1 do begin
      Item := FindSatelliteByTrajectoryIndex(I);
      if Item <> nil then begin Indices[Count] := I; Inc(Count); end;
    end;
    Next := 0;
    for I := 0 to PlayerHoldEntries.Count - 1 do begin
      Entry := PlayerHoldEntries[I];
      if Entry = nil then Continue;
      if Entry.Kind <> hold_equipment then Continue;
      if Inventory.IndexOf(Entry.Item) < 0 then Continue;
      Item := Entry.Item as TEquipment;
      if Item.ItemType = item_satellite then begin
        if Next >= Count then RaiseWideMessage('Satellite renom 1');
        (Item as TSatellite).TrajectoryIndex := Indices[Next];
        Inc(Next);
      end;
    end;
    if Count <> Next then RaiseWideMessage('Satellite renom 2');
    Indices := nil;
  end;
end;
{ @end $6EA040 }

{ @routine $6EA258 TShip_ArrangeHoldSatellitesByTrajectoryIndex }
procedure TShip.ArrangeHoldSatellitesByTrajectoryIndex;
var Indices: array of Integer; Entries: array of TPlayerHoldUnit; I, Next, Count: Integer; Item: TEquipment; Entry: TPlayerHoldUnit;
begin
  if Inventory.Count > 0 then begin
    RepairDuplicateSatelliteTrajectoryIndices;
    RefreshAssignedItemSlots;
    PlayerHoldShip := Self;
    RefreshPlayerHoldView(True);
    SetLength(Indices, Inventory.Count);
    SetLength(Entries, Inventory.Count);
    Count := 0;
    for I := 0 to PlayerHoldEntries.Count - 1 do begin
      Entry := PlayerHoldEntries[I];
      if Entry = nil then Continue;
      if Entry.Kind <> hold_equipment then Continue;
      if Inventory.IndexOf(Entry.Item) < 0 then Continue;
      Item := Entry.Item as TEquipment;
      if Item.ItemType <> item_satellite then Continue;
      Entries[Count] := TPlayerHoldUnit.Create;
      Entries[Count].Kind := Entry.Kind;
      Entries[Count].GoodsIndex := Entry.GoodsIndex;
      Entries[Count].ItemId := Entry.ItemId;
      Entries[Count].Item := Entry.Item;
      Entries[Count].Retained := Entry.Retained;
      Indices[Count] := I;
      Inc(Count);
    end;
    Next := 0;
    for I := 0 to GetSatelliteTrajectoryIndexLimit - 1 do begin
      Item := FindSatelliteByTrajectoryIndex(I);
      if Item <> nil then begin
        if Next >= Count then RaiseWideMessage('Satellite renom 3');
        Entry := PlayerHoldEntries[Indices[Next]];
        Entry.Kind := Entries[Next].Kind;
        Entry.GoodsIndex := Entries[Next].GoodsIndex;
        Entry.ItemId := Item.Id;
        Entry.Item := Item;
        Entry.Retained := Entries[Next].Retained;
        Inc(Next);
      end;
    end;
    if Count <> Next then RaiseWideMessage('Satellite renom 4');
    for I := 0 to Count - 1 do begin Entries[I].Item := nil; Entries[I].Free; end;
    Entries := nil;
    Indices := nil;
  end;
end;
{ @end $6EA258 }

{ @routine $6EA534 TShip_UseDominatorTransmitter }
function TShip.UseDominatorTransmitter(Artefact: TArtefactTransmitter): Boolean;
var I, J, Selected, Available, Penalty: Integer; Star: TStar; Ship: TShip;
  Strength, PowerFactor: Single; Event: TGalaxyEvent;
begin
  if Artefact.Power >= MinTransmitterPower then begin
    Penalty := 0;
    for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do begin
      if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + Max(TransmitterSameSystemPenaltyTurns, TransmitterAnySystemPenaltyTurns) < Galaxy.CurrentTurn then Break;
      if (TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerUsesBeacon') and
        (TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TransmitterAnySystemPenaltyTurns < Galaxy.CurrentTurn) then Inc(Penalty, TransmitterAnySystemPenalty);
      if (TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType <> 'PlayerUsesBeacon') or
        (TGalaxyEvent(Galaxy.GalaxyEvents[I]).GetData(0) <> Integer(CurrentStar.Id)) or
        (TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TransmitterSameSystemPenaltyTurns >= Galaxy.CurrentTurn) then Continue;
      Inc(Penalty, TransmitterSameSystemPenalty);
    end;
    Event := AddGalaxyEvent('PlayerUsesBeacon');
    Event.AddData(CurrentStar.Id);
    Selected := 0;
    Strength := 0;
    PowerFactor := RemapClamped(Artefact.Power, MinTransmitterPower, MaxTransmitterPower, 1, 3);
    if (CurrentStar.Id <> 71) and (CurrentStar.Id <> 72) then
      for I := 1 to Galaxy.Stars.Count - 1 do begin
        Star := CurrentStar.StarDistances[I].Star as TStar;
        if (Star.ControlFaction <> faction_dominators) or (Star.Battle <> 0) or (Star.Status.CustomFaction <> '') or
          ((Star.DominatorSeries <> series_keller) and (not (NextRandomUnitFloat(RandomState) >= 0.8) or not (PowerFactor >= 2))) then Continue;
        Available := 0;
        for J := 0 to Star.Ships.Count - 1 do begin
          Ship := Star.Ships[J];
          if Ship.InNormalSpace and (Ship is TKling) and not Ship.HasIndependentScriptFaction and
            (Ship.Order in [order_none, order_move]) and ((Ship as TKling).KlingType in [dominator_equantor..dominator_shtip]) then Inc(Available);
        end;
        if Available <= 1 then Available := 0
        else Available := Max(1, Available - NextRandomIntRange(2, 5, RandomState));
        if Available > 0 then
          for J := 0 to Star.Ships.Count - 1 do begin
            Ship := Star.Ships[J];
            if Ship.InNormalSpace and (Ship is TKling) and not Ship.HasIndependentScriptFaction and
              (Ship.Order in [order_none, order_move]) and ((Ship as TKling).KlingType in [dominator_equantor..dominator_shtip]) then begin
              if (Star.DominatorSeries = series_keller) and (1 - Penalty * 0.01 > NextRandomUnitFloat(RandomState)) and
                (KellerShip <> nil) and (Galaxy.KellerLeaveTurn = 0) then Ship.OrderJump(CurrentStar, True);
              if (Star.DominatorSeries = series_blazer) and (1 - Penalty * 0.01 > NextRandomUnitFloat(RandomState)) and
                (BlazerShip <> nil) then Ship.OrderJump(CurrentStar, True);
              if (Star.DominatorSeries = series_terron) and (1 - Penalty * 0.01 > NextRandomUnitFloat(RandomState)) and
                (TerronShip <> nil) then Ship.OrderJump(CurrentStar, True);
              Dec(Available);
              Inc(Selected);
              Strength := Strength + Ship.StrengthInBestRanger;
              if Available <= 0 then Break;
            end;
          end;
        if (Selected > NextRandomIntRange(10, 12, RandomState) * PowerFactor) or
          ((Selected > 8 * PowerFactor) and (Strength > 8 * PowerFactor)) then Break;
      end;
    Artefact.Power := 0;
    Result := True;
  end else Result := False;
end;
{ @end $6EA534 }

{ @routine $6EAAD8 TShip_HasMatchingArtefactOrCustomItem }
function TShip.HasMatchingArtefactOrCustomItem(Item: TItem): Boolean;
var I: Integer; Other: TEquipment;
begin
  Result := False;
  if Item.ItemType = item_misc then begin
    for I := 0 to Inventory.Count - 1 do begin
      Other := Inventory[I];
      if (Other.ItemType = item_misc) and (Other.ConfigBlockName = TEquipment(Item).ConfigBlockName) then begin Result := True; Exit; end;
    end;
  end else
    for I := 0 to Artefacts.Count - 1 do begin
      Other := Artefacts[I];
      if (Item.ItemType = Other.ItemType) and (not (Other.ItemType in [item_custom_artefact, item_custom_artefact_no_wear]) or
        (Other.ConfigBlockName = TEquipment(Item).ConfigBlockName)) then begin Result := True; Exit; end;
    end;
end;
{ @end $6EAAD8 }

{ @routine $6EAB98 TShip_CountActiveArtefacts }
function TShip.CountActiveArtefacts(ArtefactType: TItemType): Integer;
var
  I: Integer;
  Item: TArtefact;
  AllActive: Boolean;
begin
  Result := 0;
  AllActive := False;
  if (ArtefactType in [artefact_radar, artefact_scanner, artefact_analyzer, artefact_health_protection]) and (ArtefactType <> artefact_artefactor) then
    AllActive := (CountActiveArtefacts(artefact_artefactor) > 0) and
      ((not (TurnCalculationPhase in [turn_galaxy_running, turn_player_star_running])) or (CountActiveArtefacts(artefact_artefactor) > 1));
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if (Item.GetEffectiveType = ArtefactType) and (Item.BrokenFlag = 0) and
       ((Item.EquippedFlag or Byte(AllActive)) <> 0) then Inc(Result);
  end;
end;
{ @end $6EAB98 }

{ @routine $6EAC4C TShip_HasEquippedArtefactOfSameUseGroup }
function TShip.HasEquippedArtefactOfSameUseGroup(Item: TItem): Boolean;
var I: Integer; Kind: TItemType; Artefact: TArtefact;
begin
  Result := False;
  if not (Item is TArtefact) then Exit;
  Kind := Item.ItemType;
  if (Kind in [item_custom_artefact..item_custom_artefact_no_wear]) and TArtefactCustom(Item).SharedUse then
    Kind := TArtefactCustom(Item).CountsAsItemType;
  if not (Kind in [item_custom_artefact..item_custom_artefact_no_wear]) then
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      if Artefact.EquippedFlag <> 0 then
      begin
        if Artefact.ItemType = Kind then
        begin
          Result := True;
          Exit;
        end;
        if (Artefact.ItemType in [item_custom_artefact..item_custom_artefact_no_wear]) then
          if (TArtefactCustom(Artefact).CountsAsItemType = Kind) and TArtefactCustom(Artefact).SharedUse then
          begin
            Result := True;
            Exit;
          end;
      end;
    end;
  end
  else
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      if (Artefact.EquippedFlag <> 0) and (Artefact.ItemType in [item_custom_artefact..item_custom_artefact_no_wear]) and
         (Artefact.ConfigBlockName = TEquipment(Item).ConfigBlockName) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;
{ @end $6EAC4C }

{ @routine $6EAD84 TShip_CanBoostArtefact }
function TShip.CanBoostArtefact(ArtefactType: TItemType; Item: TEquipment; IgnoreArtefactAvailability: Boolean): Boolean;
var Equipment: TEquipment;

  // @nested $6EAD60 IsArtefactBoostEquipment
  function IsArtefactBoostEquipment(Item: TEquipment): Boolean; // @addr $6EAD60 @note "Nested in CanBoostArtefact with unused caller-popped static link. owner_uninhabited owner and empty CustomFaction; nil returns false."
  begin
    Result := (Item <> nil) and (Item.OwnerId = owner_uninhabited) and (Item.CustomFaction = '');
  end;

begin
  Result := False;
  if not IgnoreArtefactAvailability and (CountActiveArtefacts(ArtefactType) <= 0) then Exit;
  if not (ArtefactType in [artefact_hull..artefact_defense,
    artefact_extra_loot, artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump,
    artefact_defense_to_weapon_slot, artefact_point_defense, artefact_extra_missiles]) then Exit;
  if Item = nil then
  begin
    case ArtefactType of
      artefact_hull: Result := IsArtefactBoostEquipment(GetHull);
      artefact_fuel: Result := IsArtefactBoostEquipment(GetFuelTanks);
      artefact_speed: Result := IsArtefactBoostEquipment(GetEngine);
      artefact_power: Result := IsArtefactBoostEquipment(GetEngine) or IsArtefactBoostEquipment(GetHull);
      artefact_radar: Result := IsArtefactBoostEquipment(GetRadar);
      artefact_scanner: Result := IsArtefactBoostEquipment(GetScanner);
      artefact_repair_robot: Result := IsArtefactBoostEquipment(GetRepairRobot);
      artefact_cargo_hook: Result := IsArtefactBoostEquipment(GetCargoHook);
      artefact_defense: Result := IsArtefactBoostEquipment(GetDefGenerator);
      artefact_antigravity: Result := IsArtefactBoostEquipment(GetHull);
      artefact_defense_to_energy: Result := IsArtefactBoostEquipment(GetDefGenerator);
      artefact_hyperjump: Result := IsArtefactBoostEquipment(GetEngine);
      artefact_defense_to_weapon_slot: Result := IsArtefactBoostEquipment(GetDefGenerator);
      artefact_afterburner: Result := IsArtefactBoostEquipment(GetEngine);
      artefact_weapon_to_speed: Result := IsArtefactBoostEquipment(GetEngine) or IsArtefactBoostEquipment(GetHull);
      artefact_energy_defense: Result := IsArtefactBoostEquipment(GetHull);
      artefact_missile_defense: Result := IsArtefactBoostEquipment(GetHull);
      artefact_extra_loot: Result := IsArtefactBoostEquipment(GetScanner);
      artefact_point_defense: Result := IsArtefactBoostEquipment(GetRadar);
    end;
    if ArtefactType = artefact_nano_repair then
      if IsArtefactBoostEquipment(GetEngine) or IsArtefactBoostEquipment(GetFuelTanks) or
        IsArtefactBoostEquipment(GetRadar) or IsArtefactBoostEquipment(GetScanner) or
        IsArtefactBoostEquipment(GetRepairRobot) or IsArtefactBoostEquipment(GetCargoHook) or
        IsArtefactBoostEquipment(GetDefGenerator) or
        IsArtefactBoostEquipment(Weapons[1]) or
        IsArtefactBoostEquipment(Weapons[2]) or
        IsArtefactBoostEquipment(Weapons[3]) or
        IsArtefactBoostEquipment(Weapons[4]) or
        IsArtefactBoostEquipment(Weapons[5]) then Result := True;
    if (ArtefactType = artefact_defense_to_energy) or (ArtefactType = artefact_energy_pulse) then
      if (IsArtefactBoostEquipment(Weapons[1]) and (damage_flag_energy in Weapons[1].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[2]) and (damage_flag_energy in Weapons[2].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[3]) and (damage_flag_energy in Weapons[3].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[4]) and (damage_flag_energy in Weapons[4].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[5]) and (damage_flag_energy in Weapons[5].GetWeaponInfo.DamageFlags)) then Result := True;
    if (ArtefactType = artefact_splinter) or (ArtefactType = artefact_decelerate) then
      if (IsArtefactBoostEquipment(Weapons[1]) and (damage_flag_splinter in Weapons[1].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[2]) and (damage_flag_splinter in Weapons[2].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[3]) and (damage_flag_splinter in Weapons[3].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[4]) and (damage_flag_splinter in Weapons[4].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[5]) and (damage_flag_splinter in Weapons[5].GetWeaponInfo.DamageFlags)) then Result := True;
    if ArtefactType = artefact_extra_missiles then
      if (IsArtefactBoostEquipment(Weapons[1]) and (Weapons[1].GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket])) or
        (IsArtefactBoostEquipment(Weapons[2]) and (Weapons[2].GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket])) or
        (IsArtefactBoostEquipment(Weapons[3]) and (Weapons[3].GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket])) or
        (IsArtefactBoostEquipment(Weapons[4]) and (Weapons[4].GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket])) or
        (IsArtefactBoostEquipment(Weapons[5]) and (Weapons[5].GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket])) then Result := True;
  end
  else
  begin
    Equipment := Item;
    if not IsArtefactBoostEquipment(Equipment) then Exit;
    case ArtefactType of
      artefact_hull: if not (Equipment is THull) then Exit;
      artefact_fuel: if not (Equipment is TFuelTanks) then Exit;
      artefact_speed: if not (Equipment is TEngine) then Exit;
      artefact_power: if not ((Equipment is TEngine) or (Equipment is THull)) then Exit;
      artefact_radar: if not (Equipment is TRadar) then Exit;
      artefact_scanner: if not (Equipment is TScaner) then Exit;
      artefact_repair_robot: if not (Equipment is TRepairRobot) then Exit;
      artefact_defense: if not (Equipment is TDefGenerator) then Exit;
      artefact_antigravity: if not (Equipment is THull) then Exit;
      artefact_cargo_hook: if not (Equipment is TCargoHook) then Exit;
      artefact_hyperjump: if not (Equipment is TEngine) then Exit;
      artefact_defense_to_weapon_slot: if not (Equipment is TDefGenerator) then Exit;
      artefact_afterburner: if not (Equipment is TEngine) then Exit;
      artefact_energy_defense: if not (Equipment is THull) then Exit;
      artefact_missile_defense: if not (Equipment is THull) then Exit;
      artefact_extra_loot: if not (Equipment is TScaner) then Exit;
      artefact_point_defense: if not (Equipment is TRadar) then Exit;
    end;
    if (ArtefactType = artefact_nano_repair) and (Equipment is THull) then Exit;
    if (ArtefactType = artefact_weapon_to_speed) and not ((Equipment is THull) or (Equipment is TEngine)) then Exit;
    if (ArtefactType = artefact_defense_to_energy) and not ((Equipment is TDefGenerator) or
      ((Equipment is TWeapon) and (damage_flag_energy in TWeapon(Equipment).GetWeaponInfo.DamageFlags))) then Exit;
    if (ArtefactType = artefact_energy_pulse) and not ((Equipment is TWeapon) and
      (damage_flag_energy in TWeapon(Equipment).GetWeaponInfo.DamageFlags)) then Exit;
    if ((ArtefactType = artefact_splinter) or (ArtefactType = artefact_decelerate)) and not ((Equipment is TWeapon) and
      (damage_flag_splinter in TWeapon(Equipment).GetWeaponInfo.DamageFlags)) then Exit;
    if (ArtefactType = artefact_extra_missiles) and not ((Equipment is TWeapon) and
      (TWeapon(Equipment).GetWeaponInfo.ShotType in [shot_torpedo, shot_missile, shot_rocket])) then Exit;
    if not (Equipment.ItemType in [item_hull..item_custom_weapon]) then Exit;
    Result := True;
  end;
end;
{ @end $6EAD84 }

{ @routine $6EB7B8 TShip_ApplyNanoArtefactRepair }
procedure TShip.ApplyNanoArtefactRepair;
var Item: TEquipment; I, EquippedCount, UnequippedCount: Integer;

  // @nested $6EB680 SelectOrdinal
  procedure SelectOrdinal(Ordinal: Integer; Equipped: Boolean); // @addr 0x006EB680 @note "Caller-popped static link; ship -4, selected-item output -8."
  var Index, Count: Integer;
  begin
    Count := 0;
    for Index := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[Index];
      if Item.EquippedFlag = Byte(Equipped) then Inc(Count);
      if Count = Ordinal then Exit;
    end;
    Item := nil;
  end;

  // @nested $6EB6EC SelectRepairable
  procedure SelectRepairable(Count: Integer; Equipped: Boolean); // @addr 0x006EB6EC @note "Caller-popped static link; ship -4, selected-item output -8. At most 30 deterministic selections."
  const RepairableTypes = [Low(TItemType)..High(TItemType)] - [item_food..item_narcotics, item_custom_artefact_no_wear, artefact_transmitter..artefact_tranclucator, artefact_black_hole..artefact_artefactor, item_hull, item_nodes..item_fuel_container, item_treasure_map..item_stackable_misc];
  var Attempt: Integer;
  begin
    Attempt := 0;
    repeat
      Inc(Attempt);
      Item := nil;
      if Attempt > 30 then Exit;
      SelectOrdinal(SeededRandomIntRange(1, Count, Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn) + Cardinal(Attempt)), Equipped);
      if Item = nil then Exit;
    until (Item.ItemType in RepairableTypes) and (Item.ConditionPercent <= 60) and
      not ((Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = availability_not_sold_node_repair)) and
      CanRepairEquipmentTech(Item);
  end;

begin
  if Inventory.Count < 1 then RaiseWideMessage('Not equipments in ship ' + GetName);
  EquippedCount := 0;
  UnequippedCount := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if Item.EquippedFlag <> 0 then Inc(EquippedCount) else Inc(UnequippedCount);
  end;
  Item := nil;
  if EquippedCount > 0 then SelectRepairable(EquippedCount, True);
  if (Item = nil) and (UnequippedCount > 0) then SelectRepairable(UnequippedCount, False);
  if Item <> nil then
  begin
    Item.ConditionPercent := Item.ConditionPercent + NanoArtefactRepair / OwnerInfo[Item.OwnerId].EquipmentDurabilityFactor;
    if CanBoostArtefact(artefact_nano_repair, Item, False) then
      Item.ConditionPercent := Item.ConditionPercent + NanoArtefactBoostRepair / OwnerInfo[Item.OwnerId].EquipmentDurabilityFactor;
    if Item.ConditionPercent > 100 then Item.ConditionPercent := 100;
    if (Item.ConditionPercent > 0) and (Item.BrokenFlag <> 0) then
    begin
      Item.BrokenFlag := 0;
      if GetPlayer = Self then
        AddOrUpdatePlayerBubble(message_ship_positive, Galaxy.CurrentTurn, FormatText1(LocalizedText('Artefacts.ArtNano.RepairItem'),
          TextHighlightColorTag, '<Name>', Item.GetDisplayName), '').Targets[0].ShipId := Id;
    end;
  end;
end;
{ @end $6EB7B8 }

{ @routine $6EBA6C TShip_CanContactShip }
function TShip.CanContactShip(OtherShip: TShip): Boolean;
begin
  Result := (Max(GetRadarRange * GetRadarRange, 250000) >= PointDistanceSquared(Position, OtherShip.Position)) and
    not OtherShip.NoTalk and not NoTalk;
end;
{ @end $6EBA6C }

{ @routine $6EBB6C TShip_LookupTalkText }
function TShip.LookupTalkText(const Path: WideString): WideString;
var Count, I: Integer; Key: WideString; Variants: array[0..9] of WideString;

  // @nested $6EBAD8 GetTalkContextPrefix
  function GetTalkContextPrefix(Ship: TShip): WideString; // @addr $6EBAD8
  begin
    Result := 'Talk.';
    if (Ship.OwnerId = owner_pirate) and (Ship is TNormalShip) then Result := Result + 'PirateClan.'
    else if Ship.IsFemaleHumanPilot then Result := Result + 'Female.';
  end;


begin
  if Pos('Talk.', Path) = 1 then
  begin
    if GetPlayer <> Self then Key := ReplaceAllWideString(Path, 'Talk.', GetTalkContextPrefix(Self))
    else if TalkShip <> nil then Key := ReplaceAllWideString(Path, 'Talk.', GetTalkContextPrefix(TalkShip))
    else Key := Path;
  end
  else Key := Path;
  Count := 0;
  Variants[Count] := LocalizedText(Key);
  if Variants[Count] <> '' then Inc(Count);
  I := 1;
  repeat
    Variants[Count] := LocalizedText(Key + IntToStr(Count));
    if Variants[Count] <> '' then Inc(Count);
    Inc(I);
  until I > 9;
  if Count = 0 then
  begin
    Result := 'String: ' + WrapTextInColor(Key, TextHighlightColorTag) + ' is unavailable';
    Exit;
  end;

  if Count = 1 then Result := Variants[0]
  else
  begin
    Count := SeededRandomIntRange(0, Count - 1, (Galaxy.CurrentTurn + Integer(Seed)) div 10);
    Result := Variants[Count];
  end;
  if HomePlanet <> nil then Result := ReplaceColoredToken(Result, '<HomePlanet>', HomePlanet.Name, TextHighlightColorTag);
  Result := ReplaceColoredToken(Result, '<Ship>', GetName, TextHighlightColorTag);
  Result := ReplaceColoredToken(Result, '<FullShip>', GetFullName(' '), TextHighlightColorTag);
  Result := ReplaceAllWideString(Result, '<clr>', TextHighlightColorTag);
  Result := ReplaceAllWideString(Result, '<clrEnd>', EndColorTag);
  if (GetPlayer = Self) and (TalkShip <> nil) then
    Result := ReplaceColoredToken(Result, '<TalkShip>', TalkShip.GetName, TextHighlightColorTag);
end;
{ @end $6EBB6C }

{ @routine $6EBFAC TShip_OpenPlayerConversation }
function TShip.OpenPlayerConversation(RespectChameleon: Boolean): Boolean;
var Handles: array[0..1] of THandle;
begin
  if ExitScreenLoop or not GetPlayer.InNormalSpace or (GetPlayer.CurrentStar <> CurrentStar) or
    (TurnCalculationPhase in [turn_idle, turn_galaxy_finished, turn_player_star_finished, turn_player_star_prepared]) or
    (CurrentScreenId <> screen_star_map) or (Galaxy.SpecialSimulationMode <> 0) then begin Result := False; Exit; end;
  if (GetPlayer.ChameleonActive and RespectChameleon) and IsPlayerChameleonEffectiveAgainstSelf and
    ((ScriptShip = nil) or not HasScriptControl) then begin Result := False; Exit; end;
  TalkShip := Self;
  TalkPlanet := nil;
  TalkScripted := RespectChameleon;
  ResetEvent(TalkCompletedEvent);
  SetEvent(TalkRequestEvent);
  SetEvent(ScriptUiRequestEvent);
  Handles[0] := TalkCompletedEvent;
  Handles[1] := ScriptUiAbortEvent;
  if WaitForMultipleObjects(Length(Handles), @Handles[0], False, INFINITE) <> WAIT_OBJECT_0 then begin
    Result := False;
    TalkScripted := False;
    ResetEvent(TalkRequestEvent);
  end else begin
    ResetEvent(ScriptUiRequestEvent);
    TalkScripted := False;
    SysUtils.Sleep(10);
    Result := True;
  end;
end;
{ @end $6EBFAC }

{ @routine $6EC0F0 TShip_ShowPlayerDialogue }
function TShip.ShowPlayerDialogue(Kind: TTalkEventKind; const Text: WideString; Amount: Integer): Byte;
begin
  TalkType := Kind;
  if Amount > 0 then TalkAmount := Amount;
  TalkResponse := 0;
  TalkText := Text;
  Result := 0;
  if OpenPlayerConversation(True) then Result := TalkResponse;
end;
{ @end $6EC0F0 }

{ @routine $6EC144 TShip_NotifyMoneyDemand }
procedure TShip.NotifyMoneyDemand(OtherShip: TShip; Response: WideString; Amount: Integer);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + OtherShip.GetFullName(' ') + EndColorTag;
  Request := '- ' + ReplaceColoredToken(LookupTalkText('Talk.Money.Send'), '<Money>', IntToStr(Amount), TextHighlightColorTag);
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $6EC144 }

{ @routine $6EC3DC TShip_NotifyCargoDemand }
procedure TShip.NotifyCargoDemand(OtherShip: TShip; Response: WideString);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + OtherShip.GetFullName(' ') + EndColorTag;
  Request := '- ' + WrapTextInColor(LookupTalkText('Talk.Goods.Send'), '');
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $6EC3DC }

{ @routine $6EC628 TShip_NotifyFearCargoDrop }
procedure TShip.NotifyFearCargoDrop(OtherShip: TShip);
var Header: WideString; RadarSquared: Integer; Request: WideString;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    RadarSquared := Sqr(GetPlayer.GetRadarRange);
    if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
      (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position)) then begin
      if ((GetPlayer <> OtherShip) or not GetPlayer.ChameleonActive or not IsPlayerChameleonEffectiveAgainstSelf) and
        not NoTalk and not OtherShip.NoTalk then begin
        Request := LookupVisibleTalkText('Talk.DropGoodsInFear.Drop', OtherShip);
        ReplaceTextToken(Request, '<ShipBad>', OtherShip.GetName, TextHighlightColorTag);
        ReplaceTextToken(Request, '<FullShipBad>', OtherShip.GetFullName(' '), TextHighlightColorTag);
        ReplaceTextToken(Request, '<Star>', CurrentStar.Name, TextHighlightColorTag);
        Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + ':';
        Request := '- ' + Request;
        with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + #13#10 + Request, '') do begin
          Targets[0].ShipId := Self.Id;
          Targets[1].ShipId := OtherShip.Id;
        end;
      end;
    end;
  end;
end;
{ @end $6EC628 }

{ @routine $6EC908 TShip_NotifyTruceOffer }
procedure TShip.NotifyTruceOffer(OtherShip: TShip; Response: WideString; Amount: Integer);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  if NoTalk or OtherShip.NoTalk then Exit;
  Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + OtherShip.GetFullName(' ') + EndColorTag;
  Request := '- ' + ReplaceColoredToken(LookupTalkText('Talk.Truce.' + GetTypeNameKey + 'Send'), '<Money>', IntToStr(Amount), TextHighlightColorTag);
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $6EC908 }

{ @routine $6ECBE4 TShip_NotifyAttackRequest }
procedure TShip.NotifyAttackRequest(OtherShip: TShip; Response: WideString; Target: TShip);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  if NoTalk or OtherShip.NoTalk then Exit;
  Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + OtherShip.GetFullName(' ') + EndColorTag;
  Request := '- ' + ReplaceColoredToken(LookupTalkText('Talk.Attack.' + GetTypeNameKey + 'Send'), '<Target>', Target.GetFullName(' '), TextHighlightColorTag);
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
    Targets[2].ShipId := Target.Id;
  end;
end;
{ @end $6ECBE4 }

{ @routine $6ECEBC TShip_NotifyPartnershipOffer }
procedure TShip.NotifyPartnershipOffer(OtherShip: TShip; Response: WideString; Amount: Integer);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  if NoTalk or OtherShip.NoTalk then Exit;
  Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + OtherShip.GetFullName(' ') + EndColorTag;
  Request := '- ' + FormatText1(LookupTalkText('Talk.Partner.Send'), TextHighlightColorTag, '<Money>', IntToStr(Amount));
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $6ECEBC }

{ @routine $6ED174 TShip_NotifyPartnerBreak }
procedure TShip.NotifyPartnerBreak(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(talk_event_partnership_broken, LookupTalkText('Talk.Partner.MateBreak'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateBreak');
          Response := #13#10'- ' + LookupTalkText('Talk.Partner.AnswerLiderBreak');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6ED174 }

{ @routine $6ED474 TShip_NotifyPartnershipExpired }
procedure TShip.NotifyPartnershipExpired(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      if GetPlayer.GetEffectiveSkillLevel(skill_leadership) > GetPlayer.CountWingmen then
        ShowPlayerDialogue(talk_event_partnership_expired, LookupTalkText('Talk.Partner.MateTheEnd'), 0)
      else ShowPlayerDialogue(talk_event_partnership_expired, LookupTalkText('Talk.Partner.MateTheEndLowLeadership'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          if (GetPlayer <> Leader) or (GetPlayer.GetEffectiveSkillLevel(skill_leadership) > GetPlayer.CountWingmen) then
            Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateTheEnd')
          else Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateTheEndLowLeadership');
          Response := #13#10'- ' + LookupTalkText('Talk.Partner.AnswerLiderTheEnd');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6ED474 }

{ @routine $6ED858 TShip_NotifyPartnerRebellion }
procedure TShip.NotifyPartnerRebellion(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(talk_event_partner_rebellion, LookupTalkText('Talk.Partner.MateRiot'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateRiot');
          Response := #13#10'- ' + LookupTalkText('Talk.Partner.AnswerLiderRiot');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6ED858 }

{ @routine $6EDB54 TShip_ShowMessageToPlayer }
procedure TShip.ShowMessageToPlayer(Text: WideString);
begin
  if not NoTalk and not GetPlayer.NoTalk then
  begin
    TurnsSinceLastShipMessage := 0;
    with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn,
      WrapTextInColor(GetFullName(' '), TextHighlightColorTag) + #13#10 + ' ' + #13#10 + Text, '') do
    begin
      Targets[0].ShipId := Id;
      Targets[1].ShipId := GetPlayer.Id;
    end;
  end;
end;
{ @end $6EDB54 }

{ @routine $6EDC70 TShip_NotifyPiratePartnerRelationBreak }
procedure TShip.NotifyPiratePartnerRelationBreak(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(talk_event_partnership_broken, LookupTalkText('Talk.Pirate.MateBreakRelation'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateBreakRelation');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderBreak');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6EDC70 }

{ @routine $6EDF7C TShip_NotifyPiratePartnerRatingBreak }
procedure TShip.NotifyPiratePartnerRatingBreak(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(talk_event_partnership_broken, LookupTalkText('Talk.Pirate.MateBreakRating'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateBreakRating');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderBreak');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6EDF7C }

{ @routine $6EE284 TShip_NotifyPiratePartnershipExpired }
procedure TShip.NotifyPiratePartnershipExpired(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      if GetPlayer.GetEffectiveSkillLevel(skill_leadership) > GetPlayer.CountWingmen then
        ShowPlayerDialogue(talk_event_partnership_expired, LookupTalkText('Talk.Pirate.MateTheEnd'), 0)
      else ShowPlayerDialogue(talk_event_partnership_expired, LookupTalkText('Talk.Pirate.MateTheEndLowLeadership'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          if (GetPlayer <> Leader) or (GetPlayer.GetEffectiveSkillLevel(skill_leadership) > GetPlayer.CountWingmen) then
            Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateTheEnd')
          else Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateTheEndLowLeadership');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderTheEnd');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6EE284 }

{ @routine $6EE660 TShip_NotifyPiratePartnerRebellion }
procedure TShip.NotifyPiratePartnerRebellion(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(talk_event_partner_rebellion, LookupTalkText('Talk.Pirate.MateRiot'), 0);
      GetPlayer.ScriptItemsAct(event_ship_talked_with_player, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := TextHighlightColorTag + GetFullName(' ') + EndColorTag + LookupTalkText('Talk.To') + TextHighlightColorTag + Leader.GetFullName(' ') + EndColorTag;
          Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateRiot');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderRiot');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $6EE660 }

{ @routine $6EE958 TShip_RefusesFactionNegotiation }
function TShip.RefusesFactionNegotiation(OtherShip: TShip): Boolean;
begin
  Result := False;
end;
{ @end $6EE958 }

{ @routine $6EE95C TShip_CalculatePartnershipMonths }
function TShip.CalculatePartnershipMonths(Amount: Integer; OtherShip: TShip): Integer;
begin
  if Amount < Wealth / 45 then begin Result := 0; Exit; end;
  Result := Round(RemapClamped(Amount, Wealth / 45, Wealth / 8, 8, 36) *
    RemapClamped(RelationToShip(OtherShip), 50, 100, 0.7, 1.5));
  if (GetPlayer = OtherShip) and OtherShip.IsHealthEffectActive(stimulant_shakhmandoo_leader) then Result := Result * 2;
end;
{ @end $6EE95C }

{ @routine $6EEA48 TShip_GetGreetingText }
function TShip.GetGreetingText: WideString;
var Key: WideString; Chameleon: Boolean; Series: TDominatorSeries;
begin
  Chameleon := GetPlayer.ChameleonActive;
  if Self is TTranclucator then Key := 'Talk.Tranclucator.Greeting'
  else if IsFemaleHumanPilot then begin
    if GetPlayer = PartnerShip then begin
      if Chameleon then Key := 'ShipGreetings.Standart.FemalePartnerChameleon'
      else Key := 'ShipGreetings.Standart.FemalePartner';
    end else if Chameleon then begin
      if GetRelationLevelToShip(GetPlayer) < relation_level_normal then Key := 'ShipGreetings.Standart.FemaleChameleonWar'
      else Key := 'ShipGreetings.Standart.FemaleChameleon';
    end else begin
      Result := (Self as TNormalShip).SelectSituationalMessage(False);
      if Result <> '' then Exit;
      case GetRelationLevelToShip(GetPlayer) of
        relation_level_hostile: Key := 'ShipGreetings.Standart.FemaleWar';
        relation_level_bad: Key := 'ShipGreetings.Standart.FemaleBad';
        relation_level_normal: Key := 'ShipGreetings.Standart.FemaleNormal';
        relation_level_good: Key := 'ShipGreetings.Standart.FemaleGood';
        relation_level_excellent: Key := 'ShipGreetings.Standart.FemaleBest';
      end;
    end;
  end else if GetPlayer = PartnerShip then begin
    if Chameleon and (TypeId <> ship_pirate) then Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'PartnerChameleon'
    else Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Partner';
  end else if Self is TNormalShip then begin
    if Chameleon and (TypeId = ship_pirate) and (GetRelationLevelToShip(GetPlayer) < relation_level_normal) then
      Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'ChameleonWar'
    else if Chameleon and ((TypeId = ship_pirate) or IsPlayerChameleonEffectiveAgainstSelf) then
      Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Chameleon'
    else begin
      if (LiberationGroup <> nil) and (GetRelationLevelToShip(GetPlayer) > relation_level_hostile) then begin
        Result := (LiberationGroup as TGroup).GetShipGreeting(Self);
        if Result <> '' then Exit;
      end;
      Result := (Self as TNormalShip).SelectSituationalMessage(False);
      if Result <> '' then Exit;
      case GetRelationLevelToShip(GetPlayer) of
        relation_level_hostile: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'War';
        relation_level_bad: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Bad';
        relation_level_normal: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Normal';
        relation_level_good: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Good';
        relation_level_excellent: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Best';
      end;
    end;
  end else if Self is TKling then begin
    if not GetPlayer.HasProgram(program_intercom) or not GetPlayer.CanResolveObjectWithScanner(Self) then Key := 'ShipGreetings.Dominator.Rnd'
    else begin
      if (Self as TKling).ActiveProgramAppliedTurn > 0 then Key := 'ShipGreetings.Dominator.ProgrammRun'
      else begin
        Series := (Self as TKling).DominatorSeries;
        case Series of
          series_blazer: Key := 'ShipGreetings.Dominator.' + DominatorSeriesNames[series_blazer];
          series_keller: Key := 'ShipGreetings.Dominator.' + DominatorSeriesNames[series_keller];
          series_terron: Key := 'ShipGreetings.Dominator.' + DominatorSeriesNames[series_terron];
        end;
        if Chameleon and (GetPlayer.ChameleonSeries = Series) and not GetPlayer.ChameleonDetected[Series] then Key := Key + 'Chameleon';
      end;
    end;
  end else begin Result := 'no greeting'; Exit; end;
  Result := LookupTalkText(Key);
  if (Self is TKling) and ((Self as TKling).ActiveProgramAppliedTurn > 0) then
    ReplaceTextToken(Result, '<Name>', GetPlayer.GetProgramName((Self as TKling).ActiveProgramId), TextHighlightColorTag);
end;
{ @end $6EEA48 }

{ @routine $6EF508 TShip_InitializeScriptStateOrders }
procedure TShip.InitializeScriptStateOrders;
var
  Binding: TScriptShip;
begin
  Binding := ScriptShip as TScriptShip;
  Binding.EndState := False;
  ApplyScriptStateOrders;
  UpdateScriptStateCompletionAndPickups;
end;
{ @end $6EF508 }

{ @routine $6EF530 TShip_ApplyScriptStateOrders }
procedure TShip.ApplyScriptStateOrders;
var
  Binding, OtherBinding: TScriptShip;
  FollowTarget: TShip;
  WeaponTotal, WeaponIndex, BindingIndex, BindingCount, GroupIndex, GroupCount: Integer;
  Weapon: TWeapon;
  Distance, BestDistance: Single;
  State: TScriptState;
  Place: TScriptPlace;
  ScriptItem: TScriptItem;
begin
  Binding := ScriptShip as TScriptShip;
  State := Binding.State;
  if InHyperspace or ((BlazerShip = Self) and OrderAbsolute) then Exit;
  if State.StateKind = script_ship_idle then OrderNone(False)
  else if State.StateKind = script_ship_move_to_place then
  begin
    Place := TScriptPlace(State.TargetValue);
    if Place.PlaceKind = place_docked_at_planet then
    begin
      if IsOnPlanet and (TPlanet(Place.TargetValue) = CurrentPlanet) then OrderNone(False)
      else if IsOnPlanet or IsDockedToShip then OrderTakeoff
      else OrderLanding(TObject(Place.TargetValue), False);
    end
    else if Place.PlaceKind = place_item_position then
    begin
      ScriptItem := TScriptItem(Place.TargetValue);
      if ScriptItem = nil then OrderNone(False)
      else if CurrentStar.Items.IndexOf(ScriptItem.Item) < 0 then OrderNone(False)
      else if IsOnPlanet or IsDockedToShip then OrderTakeoff
      else OrderMove(Place.GetRandomPoint((Seed + CurrentStar.GenerationSeed) * Galaxy.CurrentTurn), False);
    end
    else if IsOnPlanet or IsDockedToShip then OrderTakeoff
    else OrderMove(Place.GetRandomPoint((Seed + CurrentStar.GenerationSeed) * Galaxy.CurrentTurn), False);
  end
  else if State.StateKind = script_ship_follow_group then
  begin
    if IsOnPlanet or IsDockedToShip then OrderTakeoff
    else
    begin
      FollowTarget := FindScriptFollowTarget;
      if FollowTarget = nil then OrderNone(False)
      else OrderFollowShip(FollowTarget, follow_close, False);
    end;
  end
  else if State.StateKind = script_ship_jump_to_star then
  begin
    { Native repeats the planet test; it does not test docking here. }
    if IsOnPlanet or IsOnPlanet then OrderTakeoff
    else if InNormalSpace then OrderJump(TStar(State.TargetValue), False);
  end
  else if State.StateKind = script_ship_land_on_planet then
  begin
    if IsOnPlanet then
    begin
      if TPlanet(State.TargetValue) = CurrentPlanet then OrderNone(False)
      else OrderTakeoff;
    end
    else if IsDockedToShip then OrderTakeoff
    else OrderLanding(TObject(State.TargetValue), False);
  end;
  if (WeaponCount > 0) and InNormalSpace then
  begin
    if (State.StateKind <> script_ship_normal_ai) and (Self is TKling) then
      for WeaponIndex := 1 to WeaponCount do Weapons[WeaponIndex].Target := nil;
    if HasScriptControl and not (Self is TKling) then AssignWeaponTargetsInStar;
    if State.EnemyGroupIndices <> nil then
    begin
      WeaponTotal := WeaponCount;
      BindingCount := Binding.Script.Ships.Count;
      GroupCount := High(State.EnemyGroupIndices) + 1;
      for WeaponIndex := 1 to WeaponTotal do
      begin
        Weapon := Weapons[WeaponIndex];
        if not IsEquipmentUsable(Weapon) then Continue;
        BestDistance := 1E15;
        for BindingIndex := 0 to BindingCount - 1 do
        begin
          OtherBinding := Binding.Script.Ships[BindingIndex];
          if (CurrentStar <> OtherBinding.Ship.CurrentStar) or not OtherBinding.Ship.InNormalSpace then Continue;
          for GroupIndex := 0 to GroupCount - 1 do
            if State.EnemyGroupIndices[GroupIndex] = OtherBinding.GroupIndex then Break;
          if GroupIndex < GroupCount then
          begin
            Distance := PointDistanceSquared(Position, OtherBinding.Ship.Position);
            if (Sqr(GetWeaponRange(Weapon)) >= Distance) and (Distance < BestDistance) then
            begin
              BestDistance := Distance;
              Weapon.Target := OtherBinding.Ship;
            end;
          end;
        end;
      end;
    end;
  end
  else for WeaponIndex := 1 to WeaponCount do Weapons[WeaponIndex].Target := nil;
end;
{ @end $6EF530 }

{ @routine $6EF9E0 TShip_UpdateScriptStateCompletionAndPickups }
procedure TShip.UpdateScriptStateCompletionAndPickups;
var
  Binding: TScriptShip;
  State: TScriptState;
  I: Integer;
  Item: TItem;
begin
  Binding := ScriptShip as TScriptShip;
  State := Binding.State;
  if State.StateKind = script_ship_idle then Binding.EndState := True
  else if State.StateKind = script_ship_move_to_place then Binding.EndState := TScriptPlace(State.TargetValue).ShipInPlace(Self)
  else if State.StateKind = script_ship_follow_group then Binding.EndState := FindScriptFollowTarget = nil
  else if State.StateKind = script_ship_jump_to_star then
  begin
    if InHyperspace then Binding.EndState := False
    else Binding.EndState := CurrentStar = TStar(State.TargetValue);
  end
  else if State.StateKind = script_ship_land_on_planet then Binding.EndState := IsOnPlanet and (CurrentPlanet = TPlanet(State.TargetValue));
  if InNormalSpace and IsEquipmentUsable(GetCargoHook) then
  begin
    if (State.PickupItem <> nil) and (State.PickupItem.Item <> nil) then
    begin
      Item := State.PickupItem.Item;
      if (CurrentStar.Items.IndexOf(Item) >= 0) and
        (GetCargoHookRangeSquared >= PointDistanceSquared(Item.Position, Position)) then AddPickupTarget(Item, False);
    end;
    if State.PickUpNearbyItems then
      for I := 0 to CurrentStar.Items.Count - 1 do
      begin
        Item := CurrentStar.Items[I];
        if ShouldPickUpItem(Item) and IsItemInPickupRange(Item) then AddPickupTarget(Item, False);
      end;
  end;
end;
{ @end $6EF9E0 }

{ @routine $6EFB4C TShip_ScriptNextDay }
procedure TShip.ScriptNextDay;
var
  Binding: TScriptShip;
  Stage: Integer;
begin
  Binding := ScriptShip as TScriptShip;
  Stage := 0;
  try
    Stage := 1;
    UpdateScriptStateCompletionAndPickups;
    Stage := 2;
    Binding.Script.RunShipState(Binding);
    if ScriptShip = nil then Exit;
    Stage := 3;
    ApplyScriptStateOrders;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      if ScriptShip <> nil then
        raise Exception.Create('Error in procedure TShip.ScriptNextDay ' + GetFullName(' ') +
          ' Id = ' + IntToWideString(Id) + ' script name = ' + TScriptShip(ScriptShip).Script.ScriptFileName +
          ' state type = ' + IntToWideString(TScriptShip(ScriptShip).State.StateKind) +
          ' order = ' + IntToWideString(Ord(Order)) + ' label = ' + SysUtils.IntToStr(Stage))
      else
        raise Exception.Create('Error in procedure TShip.ScriptNextDay ' + GetFullName(' ') +
          ' Id = ' + IntToWideString(Id) + ' not in script now' +
          ' order = ' + IntToWideString(Ord(Order)) + ' label = ' + SysUtils.IntToStr(Stage));
    end;
  end;
end;
{ @end $6EFB4C }

{ @routine $6EFF94 TShip_FindScriptFollowTarget }
function TShip.FindScriptFollowTarget: TShip;
var
  Binding: TScriptShip;
  I, Count: Integer;
  Other: TScriptShip;
  State: TScriptState;
begin
  Binding := ScriptShip as TScriptShip;
  State := Binding.State;
  Count := Binding.Script.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Other := Binding.Script.Ships[I];
    if (State.TargetValue = Cardinal(Other.GroupIndex)) and (Other.Ship.CurrentStar = CurrentStar) then
    begin
      Result := Other.Ship;
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $6EFF94 }

{ @routine $6EFFFC TShip_GainExperience }
procedure TShip.GainExperience(Amount: Integer; SourceKind: TExperienceSource);
var
  Awarded: Integer;
begin
  Awarded := Amount;
  if SourceKind = experience_unscaled then
  begin
    Inc(TotalExperience, Amount);
    Inc(FreeExperience, Amount);
  end
  else
  begin
    if GetPlayer = Self then
      case SourceKind of
        experience_dominators: begin
          Awarded := Round(Awarded / (GetPlayer.ExperienceByDominators * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByDominators, Awarded);
        end;
        experience_pirates: begin
          Awarded := Round(Awarded / ((GetPlayer.ExperienceByPirates + GetPlayer.ExperienceByNormals) * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByPirates, Awarded);
        end;
        experience_normal_ships: begin
          Awarded := Round(Awarded / ((GetPlayer.ExperienceByPirates + GetPlayer.ExperienceByNormals) * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByNormals, Awarded);
        end;
        experience_trader_career: begin
          Awarded := Round(Awarded / (GetPlayer.ExperienceByTraderCareer * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByTraderCareer, Awarded);
        end;
      end
    else Awarded := Round(Awarded / (1 + TotalExperience * 0.000001));
    Inc(TotalExperience, Awarded);
    Inc(FreeExperience, Awarded);
  end;
  if GetPlayer = Self then TryAddAchievementProgress('OLDFAG', Awarded);
end;
{ @end $6EFFFC }

{ @routine $6F01B8 TShip_RemoveExperience }
procedure TShip.RemoveExperience(Amount: Integer);
var
  Removed: Integer;
begin
  Removed := Min(Amount, TotalExperience);
  Dec(TotalExperience, Removed);
  Removed := Min(Amount, FreeExperience);
  Dec(FreeExperience, Removed);
end;
{ @end $6F01B8 }

{ @routine $6F01E0 TShip_DepositCarriedNodes }
procedure TShip.DepositCarriedNodes;
var I: Integer; Item: TItem;
begin
  for I := Inventory.Count - 1 downto 1 do
  begin
    Item := Inventory[I];
    if Item.ItemType = item_nodes then
    begin
      Inc(NodeReserve, Item.Weight);
      if (Self is TWarrior) and ((Self as TWarrior).WarriorType = warrior_flagship) then GainExperience(Round(Item.Weight * 2.0), experience_unscaled)
      else GainExperience(Item.Weight, experience_unscaled);
      if Self is TRanger then Inc((Self as TRanger).BaseNodes, Item.Weight);
      Inventory.Delete(I);
      Item.Free;
    end;
  end;
  RefreshDerivedStats(True);
end;
{ @end $6F01E0 }

{ @routine $6F02C0 TShip_TrainSkill }
function TShip.TrainSkill(Skill: TPilotSkill): Boolean;
var
  Expected: Integer;
begin
  if (BaseSkills[Skill] < 6) and
    (SkillTrainingCosts[BaseSkills[Skill] + 1, Skill] <= FreeExperience) then
  begin
    Inc(BaseSkills[Skill]);
    Expected := FreeExperience;
    Dec(FreeExperience, SkillTrainingCosts[BaseSkills[Skill], Skill]);
    if (Expected - SkillTrainingCosts[BaseSkills[Skill], Skill] <> FreeExperience) and
       not GR_Main.CCInterface.GetTamperDetected then GR_Main.CCInterface.SetTamperDetected(True);
    Expected := FreeExperience;
    Result := True;
    if GetInnermostScreenLoop = ShipScreen then
    begin
      SysUtils.Sleep(1);
      if (Expected <> FreeExperience) and not GR_Main.CCInterface.GetTamperDetected then
        GR_Main.CCInterface.SetTamperDetected(True);
    end;
  end
  else Result := False;
end;
{ @end $6F02C0 }

{ @routine $6F03BC TShip_CanTrainSkill }
function TShip.CanTrainSkill(Skill: TPilotSkill): Boolean;
begin
  Result := (BaseSkills[Skill] < 6) and
    (SkillTrainingCosts[BaseSkills[Skill] + 1, Skill] <= FreeExperience);
end;
{ @end $6F03BC }

{ @routine $6F03F8 TShip_GetBaseSkillLevel }
function TShip.GetBaseSkillLevel(Skill: TPilotSkill): Byte;
begin
  Result := BaseSkills[Skill];
end;
{ @end $6F03F8 }

{ @routine $6F0404 TShip_GetEffectiveSkillLevel }
function TShip.GetEffectiveSkillLevel(Skill: TPilotSkill; IgnoreStatusEffects: Boolean): TPilotSkillLevel;
var
  Level: Integer;
  BonusKind: TEquipmentBonusKind;
begin
  Level := Integer(Self.BaseSkills[Skill]);
  BonusKind := TEquipmentBonusKind(Ord(Skill) + Ord(bonus_accuracy));
  if not (IgnoreStatusEffects) then
  begin
    if Self.IsHealthEffectActive(disease_blindness) then
    begin
      if Skill = skill_accuracy then Dec(Level, 3);
      if Skill = skill_maneuverability then Dec(Level, 3);
      if Skill = skill_technical then Dec(Level, 3);
      if Skill = skill_trading then Dec(Level, 3);
    end;
    if Self.IsHealthEffectActive(disease_holy_fanaticism) then
    begin
      if Skill = skill_accuracy then Inc(Level, 1);
      if Skill = skill_maneuverability then Inc(Level, 1);
      if Skill = skill_charisma then Dec(Level, 1);
      if Skill = skill_leadership then Inc(Level, 2);
    end;
    if Self.IsHealthEffectActive(disease_mysterious_luatanza) then
    begin
      if Skill = skill_accuracy then Dec(Level, 2);
      if Skill = skill_charisma then Inc(Level, 3);
    end;
    if Self.IsHealthEffectActive(disease_drug_addiction) then
    begin
      if Skill = skill_accuracy then Dec(Level, 3);
      if Skill = skill_maneuverability then Dec(Level, 3);
      if Skill = skill_technical then Dec(Level, 2);
    end;
    if Self.IsHealthEffectActive(disease_whirlwind_concussion) then
    begin
      if Skill = skill_accuracy then Dec(Level, 2);
      if Skill = skill_maneuverability then Dec(Level, 5);
      if Skill = skill_trading then Dec(Level, 10);
    end;
    if Self.IsHealthEffectActive(disease_pulled_muscle) then
    begin
      if Skill = skill_accuracy then Dec(Level, 2);
      if Skill = skill_maneuverability then Dec(Level, 2);
      if Skill = skill_technical then Dec(Level, 2);
      if Skill = skill_charisma then Dec(Level, 1);
      if Skill = skill_leadership then Dec(Level, 1);
    end;
    if Self.IsHealthEffectActive(disease_grand_malosausus) then
    begin
      if Skill = skill_leadership then Inc(Level, 3);
      if Skill = skill_trading then Inc(Level, 3);
    end;
    if Self.IsHealthEffectActive(disease_bitter_pelenosia) then
    begin
      if Skill = skill_technical then Dec(Level, 10);
    end;
    if Self.IsHealthEffectActive(disease_aka_sezyanka) then
    begin
      if Skill = skill_accuracy then Dec(Level, 1);
      if Skill = skill_technical then Dec(Level, 2);
      if Skill = skill_trading then Inc(Level, 2);
    end;
    if Self.IsHealthEffectActive(disease_new_molizone) then
    begin
      if Skill = skill_accuracy then Inc(Level, 1);
      if Skill = skill_maneuverability then Inc(Level, 1);
    end;
    if Self.IsHealthEffectActive(stimulant_maloq_sizha) then
    begin
      if Skill = skill_accuracy then Inc(Level, 4);
      if Skill = skill_maneuverability then Inc(Level, 3);
    end;
    if Self.IsHealthEffectActive(stimulant_one_eyed_khamas) then
    begin
      if Skill = skill_charisma then Dec(Level, 1);
      if Skill = skill_leadership then Dec(Level, 1);
    end;
    if Self.IsHealthEffectActive(stimulant_stardust) then
    begin
      if Skill = skill_accuracy then Inc(Level, 1);
      if Skill = skill_maneuverability then Inc(Level, 1);
      if Skill = skill_technical then Inc(Level, 1);
      if Skill = skill_trading then Inc(Level, 1);
    end;
    if Self.IsHealthEffectActive(stimulant_super_technician) then
    begin
      if Skill = skill_technical then Inc(Level, 5);
    end;
    if Self.IsHealthEffectActive(stimulant_gaalian_alacrity) then
    begin
      if Skill = skill_accuracy then Inc(Level, 4);
      if Skill = skill_maneuverability then Inc(Level, 2);
    end;
    if Self.IsHealthEffectActive(stimulant_ragobam_whisper) then
    begin
      if Skill = skill_charisma then Inc(Level, 10);
    end;
    if Self.IsHealthEffectActive(stimulant_shakhmandoo_leader) then
    begin
      if Skill = skill_charisma then Inc(Level, 1);
      if Skill = skill_leadership then Inc(Level, 4);
    end;
    if Self.IsHealthEffectActive(stimulant_psychotropic_cache) then
    begin
      if Skill = skill_charisma then Dec(Level, 3);
    end;
    if Self.IsHealthEffectActive(stimulant_business_mark) then
    begin
      if Skill = skill_trading then Inc(Level, 8);
    end;
    if Self.IsHealthEffectActive(stimulant_doubleplex) then
    begin
      if Skill = skill_accuracy then Dec(Level, 1);
      if Skill = skill_maneuverability then Dec(Level, 1);
    end;
    if Self.IsHealthEffectActive(stimulant_absolute_status) then
    begin
      if Skill = skill_charisma then Inc(Level, 2);
    end;
    if (Self.TypeId = ship_dominator) then
    begin
      if TKling((Self as TKling)).IsProgramActive(program_shock) then
      begin
        if Skill = skill_accuracy then Dec(Level, 4);
        if Skill = skill_maneuverability then Dec(Level, 4);
        if Skill = skill_technical then Dec(Level, 4);
      end;
    end;
  end;
  Level := (Level + Self.GetTotalStatBonus(BonusKind));
  Result := Max(0, Min(Level, 6));
  Exit;
end;
{ @end $6F0404 }

{ @routine $6F0724 TShip_GetRelativeStrengthCategory }
function TShip.GetRelativeStrengthCategory: Byte;
var
  Percent: TPercent;
begin
  Result := 0;
  if StrengthInBestRanger < 1 then Percent := Round(RemapClamped(StrengthInBestRanger, 0.1, 1, 0, 50))
  else Percent := Round(RemapClamped(StrengthInBestRanger, 1, 10, 50, 100));
  case Percent of
    0..20: Result := 1;
    21..40: Result := 2;
    41..60: Result := 3;
    61..80: Result := 4;
    81..100: Result := 5;
  else RaiseWideMessage('function TPlayer.StrengthInStandartCnt:TStandartCnt;');
  end;
end;
{ @end $6F0724 }

{ @routine $6F0864 TShip_GetHullConditionCategory }
function TShip.GetHullConditionCategory: Byte;
begin
  Result := 0;
  case Integer(Round(RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, 0, 100))) of
    0..20: Result := 1;
    21..50: Result := 2;
    51..70: Result := 3;
    71..90: Result := 4;
    91..100: Result := 5;
  else RaiseWideMessage('function TPlayer.StructureInStandartCnt:TStandartCnt;');
  end;
end;
{ @end $6F0864 }

{ @routine $6F0960 TShip_GetRangerRatingBand }
function TShip.GetRangerRatingBand: Byte;
begin
  Result := 0;
  if TypeId <> ship_ranger then Exit;
  case Integer(Round(RemapClamped(Galaxy.Rangers.Count - (Self as TRanger).PlaceInRating,
    0, Galaxy.Rangers.Count - 1, 0, 100))) of
    0..10: Result := 1;
    11..40: Result := 2;
    41..60: Result := 3;
    61..90: Result := 4;
    91..100: Result := 5;
  else RaiseWideMessage('function TShip.RatingInStandartCnt:TStandartCnt;');
  end;
end;
{ @end $6F0960 }

{ @routine $6F0A88 TShip_HasActiveDisease }
function TShip.HasActiveDisease: Boolean;
var I: TCaptainHealthEffect;
begin
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if CaptainHealth[I].Progress = 100 then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $6F0A88 }

{ @routine $6F0AB8 TShip_CountActiveDiseases }
function TShip.CountActiveDiseases: Integer;
var I: TCaptainHealthEffect;
begin
  Result := 0;
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if CaptainHealth[I].Progress = 100 then Inc(Result);
end;
{ @end $6F0AB8 }

{ @routine $6F0AE8 TShip_HasPresentDisease }
function TShip.HasPresentDisease: Boolean;
var I: TCaptainHealthEffect;
begin
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if CaptainHealth[I].Progress > 0 then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $6F0AE8 }

{ @routine $6F0B18 TShip_CountPresentDiseases }
function TShip.CountPresentDiseases: Integer;
var I: TCaptainHealthEffect;
begin
  Result := 0;
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if CaptainHealth[I].Progress > 0 then Inc(Result);
end;
{ @end $6F0B18 }

{ @routine $6F0B48 TShip_HasActiveStimulant }
function TShip.HasActiveStimulant: Boolean;
var I: TCaptainHealthEffect;
begin
  for I := Low(TCaptainStimulant) to High(TCaptainStimulant) do
    if CaptainHealth[I].Progress = 100 then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $6F0B48 }

{ @routine $6F0B78 TShip_CountActiveStimulants }
function TShip.CountActiveStimulants: Integer;
var I: TCaptainHealthEffect;
begin
  Result := 0;
  for I := Low(TCaptainStimulant) to High(TCaptainStimulant) do
    if CaptainHealth[I].Progress = 100 then Inc(Result);
end;
{ @end $6F0B78 }

{ @routine $6F0BA8 TShip_CountPresentDiseasesAndActiveStimulants }
function TShip.CountPresentDiseasesAndActiveStimulants: Integer;
begin
  Result := CountPresentDiseases + CountActiveStimulants;
end;
{ @end $6F0BA8 }

{ @routine $6F0BC4 TShip_HasDiseaseFromCurrentPlanet }
function TShip.HasDiseaseFromCurrentPlanet: Boolean;
var I: TCaptainHealthEffect;
begin
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if (CaptainHealth[I].Progress > 0) and (CurrentPlanet <> nil) and (GetPlayer = Self) and
      (CurrentPlanet.GetFullName(' ') = GetPlayer.StatusEffectSourceNames[I]) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $6F0BC4 }

{ @routine $6F0C6C TShip_HasDiseaseFromCurrentDockedShip }
function TShip.HasDiseaseFromCurrentDockedShip: Boolean;
var I: TCaptainHealthEffect;
begin
  for I := Low(TCaptainDisease) to High(TCaptainDisease) do
    if (CaptainHealth[I].Progress > 0) and (DockedTo <> nil) and (GetPlayer = Self) and
      (DockedTo.GetName = GetPlayer.StatusEffectSourceNames[I]) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $6F0C6C }

{ @routine $6F0D04 TShip_IsHealthEffectActive }
function TShip.IsHealthEffectActive(Index: TCaptainHealthEffect): Boolean;
begin
  Result := CaptainHealth[Index].Progress = 100;
end;
{ @end $6F0D04 }

{ @routine $6F0D24 TShip_SimulateNpcHealthEffects }
procedure TShip.SimulateNpcHealthEffects;
var
  Index, I: Integer;
begin
  if GetPlayer = Self then Exit;
  if (ScriptShip <> nil) and IsOnPlanet then RefuelAtLocation;
  while True do
  begin
    if (DaysSincePlayerSeen <= 100) or not (TypeId in [ship_ranger..ship_warrior]) then Break;
    if CountPresentDiseasesAndActiveStimulants < Integer(Seed) mod 3 + 1 then
    begin
      if (DockedTo <> nil) and (DockedTo.TypeId = station_medical_base) then
      begin
        for I := disease_blindness to disease_new_molizone do
          if CaptainHealth[I].Progress <> 0 then
          begin
            CaptainHealth[I].Progress := 0;
            CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn;
          end;
        Index := NextRandomIntRange(stimulant_maloq_sizha, stimulant_absolute_status, RandomState);
        if CaptainHealth[Index].Progress > 0 then Index := NextRandomIntRange(stimulant_maloq_sizha, stimulant_absolute_status, RandomState);
        if (CaptainHealth[Index].Progress <= 0) and (RaceToOwner(PilotRace) in CaptainHealthDefinitions[Index].AllowedOwners) then
        begin
          CaptainHealth[Index].Progress := 100;
          CaptainHealth[Index].AppliedTurn := Galaxy.CurrentTurn;
          CaptainHealth[Index].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Galaxy.GenerationSeed + Index + Galaxy.CurrentTurn), 0, 1, 0.5, 3) * CaptainHealthDefinitions[Index].Duration);
          Inc(CaptainHealth[Index].ApplicationCount);
        end;
      end
      else if (DaysSincePlayerSeen mod 100 = 0) and (NextRandomUnitFloat(RandomState) <= 0.1) then
      begin
        Index := NextRandomIntRange(disease_blindness, stimulant_absolute_status, RandomState);
        if CaptainHealth[Index].Progress > 0 then Index := NextRandomIntRange(disease_blindness, stimulant_absolute_status, RandomState);
        if (CaptainHealth[Index].Progress <= 0) and (RaceToOwner(PilotRace) in CaptainHealthDefinitions[Index].AllowedOwners) then
        begin
          CaptainHealth[Index].Progress := 100;
          CaptainHealth[Index].AppliedTurn := Galaxy.CurrentTurn;
          CaptainHealth[Index].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Galaxy.GenerationSeed + Index + Galaxy.CurrentTurn), 0, 1, 0.5, 3) * CaptainHealthDefinitions[Index].Duration);
          Inc(CaptainHealth[Index].ApplicationCount);
        end;
      end;
    end;
    Break;
  end;
  if CountActiveDiseases > 0 then
    for Index := disease_blindness to disease_new_molizone do
      if (CaptainHealth[Index].Progress <> 0) and (CaptainHealth[Index].ExpireTurn <= Galaxy.CurrentTurn) then CaptainHealth[Index].Progress := 0;
end;
{ @end $6F0D24 }

{ @routine $6F10CC TShip_HasRadiationSickness }
function TShip.HasRadiationSickness: Boolean;
begin
  Result := RadiationHealth[1].Progress > 0;
end;
{ @end $6F10CC }

{ @routine $6F10E8 TShip_CalculateSpeed }
function TShip.CalculateSpeed: Integer;
var
  MassFactor, OutputFactor, OldSpeed: Double;
  CombinedFactor, MassPenalty, EnginePenalty, NewSpeed: Double;
  MinimumSpeed: Integer;
begin
  Result := 0;
  if GetEngine = nil then Exit;
  if GetFuelTanks = nil then Exit;
  if CargoFreeSpace < 0 then Exit;
  if GetPlayer = Self then
  begin
    if not CanUseEquipmentTech(GetFuelTanks) then Exit;
    if not CanUseEquipmentTech(GetEngine) then Exit;
  end;
  if Galaxy.IsOldSpeedCalculationEnabled then
  begin
    MassFactor := RemapClamped(CalculateMass, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333);
    if GetEngine.OutputPercent = 100 then OutputFactor := 1
    else OutputFactor := RemapClamped(GetEngine.OutputPercent, 0, 100, 0.5, 1);
    OldSpeed := GetEngine.Speed * MassFactor * OutputFactor;
    if AfterburnerActive and (GetEngine.BrokenFlag = 0) and (GetSlotCount(slot_afterburner) > 0) then
      OldSpeed := OldSpeed * AfterburnerSpeedFactor;
    if GetEngine.BrokenFlag <> 0 then OldSpeed := OldSpeed * 0.6;
    if TypeId = ship_dominator then
    begin
      if (Self as TKling).IsProgramActive(program_insanity) then OldSpeed := OldSpeed * 0.5;
    end
    else
    begin
      if IsHealthEffectActive(stimulant_gaalian_alacrity) then OldSpeed := OldSpeed * 1.3;
      if Artefacts.Count > 0 then
      begin
        if CountActiveArtefacts(artefact_speed) > 0 then
          OldSpeed := OldSpeed * Math.Power(SpeedArtefactFactor + SpeedArtefactBoostFactor * ShortInt(CanBoostArtefact(artefact_speed, nil, False)), CountActiveArtefacts(artefact_speed));
        if CountActiveArtefacts(artefact_weapon_to_speed) > 0 then
          OldSpeed := OldSpeed + CountActiveArtefacts(artefact_weapon_to_speed) * (WeaponToSpeedArtefactBonus + WeaponToSpeedArtefactBoost * Ord(CanBoostArtefact(artefact_weapon_to_speed, GetEngine, False)));
      end;
    end;
    OldSpeed := Max(167.0, OldSpeed + GetTotalStatBonus(bonus_speed));
    Result := Round(OldSpeed);
    Exit;
  end
  else
  begin
    CombinedFactor := 0;
    MassPenalty := RemapClamped(CalculateMass, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333);
    MassPenalty := Sqr(Ln(MassPenalty));
    EnginePenalty := Sqr(Ln(RemapClamped(GetEngine.OutputPercent, 0, 100, 0.5, 1)));
    if GetEngine.BrokenFlag <> 0 then EnginePenalty := EnginePenalty + Sqr(Ln(0.6));
    if not CanUseEquipmentTech(GetEngine) then EnginePenalty := EnginePenalty + Sqr(Ln(0.4));
    if TypeId = ship_dominator then
      if (Self as TKling).IsProgramActive(program_insanity) then CombinedFactor := CombinedFactor + Sqr(Ln(0.5));
    CombinedFactor := Exp(-Sqrt(CombinedFactor + MassPenalty + EnginePenalty));
    if AfterburnerActive and IsEquipmentUsable(GetEngine) and (GetSlotCount(slot_afterburner) > 0) then
      CombinedFactor := CombinedFactor * AfterburnerSpeedFactor;
    if IsHealthEffectActive(stimulant_gaalian_alacrity) then CombinedFactor := CombinedFactor * 1.3;
    NewSpeed := CalculateEngineSpeed(GetEngine, False);
    NewSpeed := NewSpeed * CombinedFactor;
    MinimumSpeed := Min(200, GetEngine.Speed);
    if NewSpeed < MinimumSpeed then NewSpeed := MinimumSpeed + (NewSpeed - MinimumSpeed) * 0.2
    else if NewSpeed > 2000 then NewSpeed := 1250 + NewSpeed * 0.2
    else if NewSpeed > 1500 then NewSpeed := 650 + NewSpeed * 0.5
    else if NewSpeed > 1000 then NewSpeed := 200 + NewSpeed * 0.8;
    Result := Round(NewSpeed);
    Exit;
  end;
end;
{ @end $6F10E8 }

{ @routine $6F1728 TShip_IsFemaleHumanPilot }
function TShip.IsFemaleHumanPilot: Boolean;
begin
  Result := (PilotRace = owner_human) and (PortraitFaceId in [25..32]) and (GetPlayer <> Self) and (GetPlayer <> nil) and (Self is TNormalShip) and (Galaxy.SpecialSimulationMode = 0);
end;
{ @end $6F1728 }

{ @routine $6F1780 TShip_UsesVeteranHumanRangerAppearance }
function TShip.UsesVeteranHumanRangerAppearance: Boolean;
begin
  Result := (TypeId = ship_ranger) and (PilotRace = owner_human) and (Id mod 6 = 0) and (CreationTurn < 666) and (GetPlayer <> Self) and (GetPlayer <> nil) and not IsFemaleHumanPilot and (Galaxy.SpecialSimulationMode = 0);
end;
{ @end $6F1780 }

{ @routine $6F19AC TShip_SelectInterceptorTarget }
function TShip.SelectInterceptorTarget: TShip;
var
  I: Integer;
  Ship, Current: TShip;
  Strategy: TInterceptorTargetingStrategy;
// @nested $6F17E4 IsBetterInterceptorTarget
function IsBetterInterceptorTarget(Current, Candidate: TShip; Strategy: TInterceptorTargetingStrategy): Boolean; // @addr 0x006F17E4 @note "Caller-popped static link; source ship at -4 for distance strategies."
begin
  case Strategy of
    interceptor_most_health: Result := Candidate.GetHull.HullPoints > Current.GetHull.HullPoints;
    interceptor_least_health: Result := Candidate.GetHull.HullPoints < Current.GetHull.HullPoints;
    interceptor_best_defense: Result :=
      RemapClamped(Candidate.GetEffectiveSkillLevel(skill_maneuverability), 0, 6, 1.5, 0.5) * 50 * Candidate.DefenseDamageFactor - Candidate.GetHull.Armor <
      RemapClamped(Current.GetEffectiveSkillLevel(skill_maneuverability), 0, 6, 1.5, 0.5) * 50 * Current.DefenseDamageFactor - Current.GetHull.Armor;
    interceptor_strongest: Result := Candidate.Strength > Current.Strength;
    interceptor_nearest: Result := PointDistanceSquared(Candidate.Position, Position) < PointDistanceSquared(Current.Position, Position);
    interceptor_farthest: Result := PointDistanceSquared(Candidate.Position, Position) > PointDistanceSquared(Current.Position, Position);
  else Result := False;
  end;
end;
begin
  if not GetHull.InterceptorsEnabled or not InNormalSpace then
  begin
    Result := nil;
    Exit;
  end;
  Current := nil;
  if GetPlayer = Self then Strategy := GetHull.InterceptorTargetingStrategy else Strategy := interceptor_most_health;
  if Strategy = interceptor_manual then
  begin
    Result := nil;
    Exit;
  end;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if (Ship <> Self) and Ship.InNormalSpace and
      ((GetPlayer = Self) or (GetRelationLevelToShip(Ship) <= relation_level_hostile)) and
      ((GetPlayer <> Self) or (Ship.GetRelationLevelToShip(Self) <= relation_level_hostile) or (EnemyShip = Ship) or (PendingPlayerFollowTarget = Ship)) and
      (Sqr(Ship.Position.X) + Sqr(Ship.Position.Y) >= CurrentStar.DamageRadius * CurrentStar.DamageRadius) and
      (PointDistanceSquared(Position, Ship.Position) <= InterceptorTargetRangeSquared) and
      (Ship.InterceptorPassesRemaining <= 0) and
      ((Current = nil) or IsBetterInterceptorTarget(Current, Ship, Strategy)) then Current := Ship;
  end;
  Result := Current;
end;
{ @end $6F19AC }

{ @routine $6F1B1C TShip_LaunchInterceptors }
procedure TShip.LaunchInterceptors;
var
  Target: TShip;
begin
  if GetHull.InterceptorTarget <> nil then Target := TShip(GetHull.InterceptorTarget)
  else Target := SelectInterceptorTarget;
  if Target = nil then Exit;
  GetHull.InterceptorTarget := nil;
  if GetHull.Energy < GetInterceptorEnergyCost then Exit;
  Dec(GetHull.Energy, GetInterceptorEnergyCost);
  Target.InterceptorSourceShip := Self;
  Target.InterceptorPassesRemaining := GetInterceptorPassCount;
  if Target.InterceptorGraphic <> nil then Exit;
  RetainSpaceObject(Target.InterceptorGraphic, CreateSpaceObjectByName('Ruins', 'Ruins.FighterSwarm', Classes.Point(0, 0)));
  Target.InterceptorGraphic.SetPosition(Target.Position);
  Target.InterceptorGraphic.SetAngle(HeadingDegreesToByte(Target.MovementDirection));
  Target.InterceptorGraphic.SetAlpha(0);
end;
{ @end $6F1B1C }

{ @routine $6F1C4C TShip_ClearIncomingInterceptors }
procedure TShip.ClearIncomingInterceptors;
begin
  InterceptorSourceShip := nil;
  InterceptorPassesRemaining := 0;
  if InterceptorGraphic <> nil then
  begin
    InterceptorGraphic.DetachFromSpace;
    ReleaseSpaceObject(InterceptorGraphic);
  end;
end;
{ @end $6F1C4C }

{ @routine $6F1C80 TShip_CountActiveInterceptorTargets }
function TShip.CountActiveInterceptorTargets: Integer;
var
  Count, I, J: Integer;
  Star: TStar;
begin
  Count := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
      if TShip(Star.Ships[J]).InterceptorSourceShip = Self then Inc(Count);
  end;
  Result := Count;
end;
{ @end $6F1C80 }

{ @routine $6F1D00 TShip_GetHullEnergyRegeneration }
function TShip.GetHullEnergyRegeneration: Integer;
begin
  Result := Round(RemapClamped(GetEffectiveSkillLevel(skill_technical), 0, 6, 1, 2) *
    (RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, 0, 1) * 10));
end;
{ @end $6F1D00 }

{ @routine $6F1D94 TShip_GetInterceptorDamage }
function TShip.GetInterceptorDamage: Integer;
begin
  Result := Round(RemapClamped(GetEffectiveSkillLevel(skill_technical), 0, 6, 1, 2) * 25);
end;
{ @end $6F1D94 }

{ @routine $6F1DE4 TShip_GetInterceptorEnergyCost }
function TShip.GetInterceptorEnergyCost: Integer;
begin
  Result := 5 * GetInterceptorPassCount + 5;
end;
{ @end $6F1DE4 }

{ @routine $6F1DFC TShip_GetInterceptorPassCount }
function TShip.GetInterceptorPassCount: Byte;
begin
  if GetHull.InterceptorPassCountOverride = 0 then Result := 5
  else Result := GetHull.InterceptorPassCountOverride;
end;
{ @end $6F1DFC }

{ @routine $6F1E24 TShip_HasScriptControl }
function TShip.HasScriptControl: Boolean;
begin
  Result := ((ScriptShip <> nil) and ((ScriptShip as TScriptShip).State.StateKind <> script_ship_normal_ai)) or (AbsoluteScriptOrder > 0);
end;
{ @end $6F1E24 }

{ @routine $6F1E5C TShip_HasNoUsableWeapons }
function TShip.HasNoUsableWeapons: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to WeaponCount do
    if (Weapons[I].EquippedFlag <> 0) and
       (not (Weapons[I].GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) or (Weapons[I].Ammo > 0)) and
       IsEquipmentUsable(Weapons[I]) then
    begin
      Result := False;
      Break;
    end;
end;
{ @end $6F1E5C }

{ @routine $6F1EC8 TShip_GetOwnStatBonus }
function TShip.GetOwnStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  I: Integer;
  Bonus: PShipStatBonusEntry;
begin
  Result := 0;
  if (StatBonuses = nil) then Exit;
  if (StatBonuses.Count = 0) then Exit;
  for I := 0 to StatBonuses.Count - 1 do
  begin
    Bonus := StatBonuses[I];
    if Bonus.BonusKind = BonusKind then
    begin
      Result := Bonus.BonusValue;
      Break;
    end;
  end;
end;
{ @end $6F1EC8 }

{ @routine $6F1F18 TShip_SetStatBonus }
procedure TShip.SetStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer);
var
  I: Integer;
  Bonus: PShipStatBonusEntry;
  Found: Boolean;
begin
  Bonus := nil;
  if (StatBonuses = nil) and (Value = 0) then Exit;
  if StatBonuses = nil then StatBonuses := TList.Create;
  Found := False;
  for I := 0 to StatBonuses.Count - 1 do
  begin
    Bonus := StatBonuses[I];
    if Bonus.BonusKind = BonusKind then
    begin
      Found := True;
      Break;
    end;
  end;
  if not Found and (Value = 0) then Exit;
  if Found then
  begin
    if Value = 0 then
    begin
      Dispose(Bonus);
      StatBonuses.Delete(I);
    end
    else Bonus.BonusValue := Value;
  end
  else
  begin
    New(Bonus);
    Bonus.BonusKind := BonusKind;
    Bonus.BonusValue := Value;
    StatBonuses.Add(Bonus);
  end;
end;
{ @end $6F1F18 }

{ @routine $6F1FFC TShip_FindCombatStatusEffect }
function TShip.FindCombatStatusEffect(EffectType: TCombatEffectKind): Integer;
var
  I: Integer;
begin
  Result := -1;
  if CombatStatusEffects = nil then Exit else
  if CombatStatusEffects.Count = 0 then Exit;
  for I := 0 to CombatStatusEffects.Count - 1 do
    if PCombatStatusEffect(CombatStatusEffects[I]).EffectType = EffectType then
    begin
      Result := I;
      Exit;
    end;
end;
{ @end $6F1FFC }

{ @routine $6F204C TShip_AddCombatStatusStrength }
procedure TShip.AddCombatStatusStrength(EffectType: TCombatEffectKind; Strength: Single; Source: TShip);
var
  I: Integer;
  Entry: PCombatStatusEffect;
begin
  if CombatStatusEffects = nil then CombatStatusEffects := TList.Create;
  I := FindCombatStatusEffect(EffectType);
  if I >= 0 then
  begin
    Entry := CombatStatusEffects[I];
    Entry.Strength := Entry.Strength + Strength / (1 + (GetHull.Weight / (HullBaseSize * EquipmentSizeFactors[1]) - 1) * (CombatStatusHullFactors[EffectType] * 0.5)) / (1 + CombatStatusAccumulationFactors[EffectType] * Entry.Strength);
    if Source <> nil then Entry.SourceShipId := Source.Id else Entry.SourceShipId := 0;
  end
  else
  begin
    New(Entry);
    Entry.EffectType := EffectType;
    Entry.Strength := Strength / (1 + (GetHull.Weight / (HullBaseSize * EquipmentSizeFactors[1]) - 1) * (CombatStatusHullFactors[EffectType] * 0.5));
    if Source <> nil then Entry.SourceShipId := Source.Id else Entry.SourceShipId := 0;
    CombatStatusEffects.Add(Entry);
  end;
end;
{ @end $6F204C }

{ @routine $6F218C TShip_ReduceCombatStatusStrength }
procedure TShip.ReduceCombatStatusStrength(EffectType: TCombatEffectKind; Amount: Single);
var
  I: Integer;
  Entry: PCombatStatusEffect;
begin
  if CombatStatusEffects = nil then Exit;
  if CombatStatusEffects.Count = 0 then Exit;
  I := FindCombatStatusEffect(EffectType);
  if I < 0 then Exit;
  Entry := CombatStatusEffects[I];
  Entry.Strength := Entry.Strength - Amount;
  if Entry.Strength < 0 then
  begin
    CombatStatusEffects.Delete(I);
    Dispose(Entry);
  end;
end;
{ @end $6F218C }

{ @routine $6F2200 TShip_ClearCombatStatusEffects }
procedure TShip.ClearCombatStatusEffects;
var
  Entry: PCombatStatusEffect;
begin
  if CombatStatusEffects = nil then Exit;
  while CombatStatusEffects.Count > 0 do
  begin
    Entry := CombatStatusEffects[0];
    CombatStatusEffects.Delete(0);
    Dispose(Entry);
  end;
end;
{ @end $6F2200 }

{ @routine $6F2244 TShip_DecayCombatStatusEffects }
procedure TShip.DecayCombatStatusEffects;
var
  Entry: PCombatStatusEffect;
  Amount: Single;
  I: Integer;
begin
  if CombatStatusEffects = nil then Exit;
  I := CombatStatusEffects.Count - 1;
  while I >= 0 do
  begin
    Entry := CombatStatusEffects[I];
    case Entry.EffectType of
      combat_effect_shock: Amount := GetShockStatusDecay(Entry.Strength);
      combat_effect_acid: Amount := GetAcidStatusDecay(Entry.Strength);
      combat_effect_magnetic: Amount := GetMagneticStatusDecay(Entry.Strength);
      combat_effect_weapon_block: Amount := GetWeaponBlockStatusDecay(Entry.Strength);
      combat_effect_droid_block: Amount := GetDroidBlockStatusDecay(Entry.Strength);
      combat_effect_node_boost: Amount := GetBWBuffStatusDecay(Entry.Strength);
      combat_effect_node_repair_penalty: Amount := GetBWRepairDebuffStatusDecay(Entry.Strength);
    else Amount := 0;
    end;
    Entry.Strength := Entry.Strength - Amount;
    if Entry.Strength < 0 then
    begin
      CombatStatusEffects.Delete(I);
      Dispose(Entry);
    end;
    Dec(I);
  end;
end;
{ @end $6F2244 }

{ @routine $6F235C TShip_GetShockStatusDecay }
function TShip.GetShockStatusDecay(Strength: Single): Single;
var
  I: Integer;
begin
  Result := 0.1 * Strength + 5;
  for I := 1 to CountActiveArtefacts(artefact_hull) do Result := Result * (HullArtefactStatusDecayFactor + ShortInt(CanBoostArtefact(artefact_hull, nil, False)) * HullArtefactBoostStatusDecay);
  if (TypeId = ship_dominator) and ((Self as TKling).KlingType = dominator_boss) then Result := Result * 2;
end;
{ @end $6F235C }

{ @routine $6F2400 TShip_GetAcidStatusDecay }
function TShip.GetAcidStatusDecay(UnusedStrength: Single): Single;
var
  I: Integer;
begin
  Result := 0.2;
  if IsEquipmentUsable(GetRepairRobot) then Result := 0.2 + Result;
  for I := 1 to CountActiveArtefacts(artefact_repair_robot) do Result := Result * (DroidArtefactStatusDecayFactor + ShortInt(CanBoostArtefact(artefact_repair_robot, nil, False)) * DroidArtefactBoostStatusDecay);
  if (TypeId = ship_dominator) and ((Self as TKling).KlingType = dominator_boss) then Result := Result * 2;
end;
{ @end $6F2400 }

{ @routine $6F24B4 TShip_GetMagneticStatusDecay }
function TShip.GetMagneticStatusDecay(Strength: Single): Single;
begin
  Result := 0.1 * Strength + 5;
  if (TypeId = ship_dominator) and ((Self as TKling).KlingType = dominator_boss) then Result := Result * 2;
end;
{ @end $6F24B4 }

{ @routine $6F2514 TShip_GetWeaponBlockStatusDecay }
function TShip.GetWeaponBlockStatusDecay(Strength: Single): Single;
begin
  Result := Strength + 1;
end;
{ @end $6F2514 }

{ @routine $6F2534 TShip_GetDroidBlockStatusDecay }
function TShip.GetDroidBlockStatusDecay(Strength: Single): Single;
begin
  Result := Strength + 1;
end;
{ @end $6F2534 }

{ @routine $6F2554 TShip_GetBWBuffStatusDecay }
function TShip.GetBWBuffStatusDecay(Strength: Single): Single;
begin
  Result := 0.05 * Strength + 0.5;
end;
{ @end $6F2554 }

{ @routine $6F2584 TShip_GetBWRepairDebuffStatusDecay }
function TShip.GetBWRepairDebuffStatusDecay(Strength: Single): Single;
begin
  Result := 0.01 * Strength + 25;
end;
{ @end $6F2584 }

{ @routine $6F25B4 TShip_ClearCombatStatusSourceReferences }
procedure TShip.ClearCombatStatusSourceReferences(Source: TShip);
var
  I: Integer;
begin
  if (CombatStatusEffects = nil) or
    (CombatStatusEffects.Count = 0) then Exit;
  for I := 0 to CombatStatusEffects.Count - 1 do
    if PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId = Source.Id then
      PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId := 0;
end;
{ @end $6F25B4 }

{ @routine $6F2608 TShip_GetCombatStatusStrength }
function TShip.GetCombatStatusStrength(EffectType: TCombatEffectKind): Single;
var
  I: Integer;
begin
  Result := 0;
  I := FindCombatStatusEffect(EffectType);
  if I >= 0 then Result := PCombatStatusEffect(CombatStatusEffects[I]).Strength;
end;
{ @end $6F2608 }

{ @routine $6F263C TShip_GetCombatStatusSourceId }
function TShip.GetCombatStatusSourceId(EffectType: TCombatEffectKind): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  I := FindCombatStatusEffect(EffectType);
  if I >= 0 then Result := PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId;
end;
{ @end $6F263C }

{ @routine $6F2780 TShip_GetCombatStatusDescription }
function TShip.GetCombatStatusDescription(out Count: Integer; ShowStrength: Boolean): WideString;
var
  Strength, I: Integer;
  Info: PCustomShipInfo;
// @nested $6F2668 AppendStatusLine
procedure AppendStatusLine(TextKey: WideString); // @addr 0x006F2668 @note "Caller-popped static link; show-strength flag -1, strength -8, count output -12, string-result output +8."
begin
  if Result <> '' then Result := Result + #13#10 + LocalizedText(TextKey)
  else Result := LocalizedText(TextKey);
  if ShowStrength then Result := Result + ' (' + IntToStr(Strength) + ')';
  Inc(Count);
end;
begin
  Count := 0;
  Result := '';
  if (CombatStatusEffects <> nil) and (CombatStatusEffects.Count > 0) then
  begin
    Strength := Round(GetCombatStatusStrength(combat_effect_node_boost));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISEBWBuff');
    Strength := Round(GetCombatStatusStrength(combat_effect_acid));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISEAcid');
    Strength := Round(GetCombatStatusStrength(combat_effect_shock));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISECharged');
    Strength := Round(GetCombatStatusStrength(combat_effect_magnetic));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISEMagnetic');
  end;
  for I := 0 to CustomShipInfos.Count - 1 do
  begin
    Info := CustomShipInfos[I];
    if Info.StatusEffect and not Info.DeleteQueued then
    begin
      Strength := Info.Data[1];
      if Strength >= 1 then AppendStatusLine('ShipInfo.AddInfo.CustomInfos.' + Info.TypeName + '.StatusEffect');
    end;
  end;
end;
{ @end $6F2780 }

{ @routine $6F29F4 TShip_UpdateAfterburnerState }
procedure TShip.UpdateAfterburnerState;
begin
end;
{ @end $6F29F4 }

{ @routine $6F29F8 TShip_RefreshCurrentStanding }
procedure TShip.RefreshCurrentStanding;
var
  StandingMode: TStandingOverride;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = override_custom_faction then CurrentStanding := standing_custom
  else if StandingMode <> override_fixed then CurrentStanding := standing_unaligned;
end;
{ @end $6F29F8 }

{ @routine $6F2A20 TShip_HasScriptStateText }
function TShip.HasScriptStateText: Boolean;
begin
  Result := (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '');
end;
{ @end $6F2A20 }

{ @routine $6F2A44 TShip_HasIndependentScriptFaction }
function TShip.HasIndependentScriptFaction: Boolean;
begin
  Result := (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '') and
    (FindTextOffsetW(TScriptShip(ScriptShip).StateText, 'SubFaction') <> 0);
end;
{ @end $6F2A44 }

{ @routine $6F2A98 TShip_HasNamedScriptFaction }
function TShip.HasNamedScriptFaction: Boolean;
begin
  Result := (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '') and
    (TScriptShip(ScriptShip).StateText <> 'SubFactionFixedStanding');
end;
{ @end $6F2A98 }

{ @routine $6F2B00 TShip_GetScriptStandingOverrideMode }
function TShip.GetScriptStandingOverrideMode: TStandingOverride;
begin
  Result := override_none;
  if (Self.ScriptShip = nil) or (TScriptShip(Self.ScriptShip).StateText = '') then
  begin
    Exit;
  end
  else if (FindTextOffsetW(TScriptShip(Self.ScriptShip).StateText, 'SubFaction') <> 0) then
  begin
    Result := override_custom_faction;
    Exit;
  end
  else if (FindTextOffsetW(TScriptShip(Self.ScriptShip).StateText, 'FixedStanding') >= 0) then
  begin
    Result := override_fixed;
    Exit;
  end
  else
  begin
    Exit;
  end;
end;
{ @end $6F2B00 }

{ @routine $6F2B98 TShip_ScriptItemsAct }
function TShip.ScriptItemsAct(ActionType: TScriptEventKind; Object1, Object2: TObject; Param: Integer): Integer;
var
  I, NewIndex: Integer;
  Item: TItem;
  Info: PCustomShipInfo;
  Binding: TScriptShip;
  Reserved: array[0..7] of Byte; // Native keeps eight unused bytes before backend string temporaries.
  SavedScript: TScript;
  Stage: Integer;
begin
  Stage := 0;
  if (ActionType = event_leave_form) and (TalkScreen.ParentLoop = nil) then WaitForTurnCalculation;
  Info := nil;
  try
    SavedScript := CurrentScript;
    CurrentScript := nil;
    if GetPlayer = Self then
    begin
      Stage := 1;
      I := GetPlayer.ScriptShipBindings.Count - 1;
      while I >= 0 do
      begin
        Binding := GetPlayer.ScriptShipBindings[I];
        Param := Binding.RunActionCode(ActionType, Self, Object1, Object2, Param);
        if IsHullDestroyed and (ActionType <> event_death) then
        begin
          CurrentScript := SavedScript;
          Result := Param;
          Exit;
        end;
        if (GetPlayer.ScriptShipBindings.Count <= I) or (GetPlayer.ScriptShipBindings[I] <> Binding) then
        begin
          NewIndex := GetPlayer.ScriptShipBindings.IndexOf(Binding);
          if NewIndex < 0 then
          begin
            I := Min(I - 1, GetPlayer.ScriptShipBindings.Count - 1);
            Continue;
          end;
          I := NewIndex;
        end;
        Dec(I);
      end;
    end
    else if ScriptShip <> nil then
    begin
      Stage := 2;
      Param := TScriptShip(ScriptShip).RunActionCode(ActionType, Self, Object1, Object2, Param);
    end;
    for I := 0 to CustomShipInfos.Count - 1 do
    begin
      Info := CustomShipInfos[I];
      Stage := 3;
      if not Info.DeleteQueued then
      begin
        Stage := 4;
        Param := RunCustomShipInfoActionCode(Info, ActionType, Self, Object1, Object2, Param);
        Stage := 5;
        if IsHullDestroyed and (ActionType <> event_death) then
        begin
          CurrentScript := SavedScript;
          Result := Param;
          Exit;
        end;
        Stage := 6;
      end;
    end;
    Stage := 11;
    if ScriptActionTypeStack.Count <= 0 then
      for I := CustomShipInfos.Count - 1 downto 0 do
      begin
        Info := CustomShipInfos[I];
        if Info.DeleteQueued then
        begin
          CustomShipInfos.Delete(I);
          Dispose(Info);
        end;
      end;
    Stage := 12;
    I := Inventory.Count - 1;
    while I >= 0 do
    begin
      Stage := 13;
      Item := Inventory[I];
      if Item is TEquipmentWithActCode then
      begin
        Param := RunItemConfigActionCode(Item, ActionType, Self, Object1, Object2, Param);
        if IsHullDestroyed and (ActionType <> event_death) then
        begin
          CurrentScript := SavedScript;
          Result := Param;
          Exit;
        end;
        if (Inventory.Count <= I) or (Inventory[I] <> Item) then
        begin
          NewIndex := Inventory.IndexOf(Item);
          if NewIndex < 0 then
          begin
            I := Min(I - 1, Inventory.Count - 1);
            Continue;
          end;
          I := NewIndex;
        end;
      end;
      Stage := 14;
      if Item.ScriptItem <> nil then
      begin
        if Item.ItemType in WeaponItemTypes then
        begin
          if (ActionType in [event_weapon_shot, event_missile_shot, event_weapon_hit_flags]) and (Object2 <> Item) then
          begin
            Dec(I);
            Continue;
          end;
          if (ActionType in [event_missile_hit_flags, event_missile_hitting_object]) and (Object2 <> nil) and (TMissile(Object2).WeaponId <> Item.Id) then
          begin
            Dec(I);
            Continue;
          end;
        end;
        Param := TScriptItem(Item.ScriptItem).RunActionCode(ActionType, Self, Object1, Object2, Param);
        if IsHullDestroyed and (ActionType <> event_death) then
        begin
          CurrentScript := SavedScript;
          Result := Param;
          Exit;
        end;
        if (Inventory.Count <= I) or (Inventory[I] <> Item) then
        begin
          NewIndex := Inventory.IndexOf(Item);
          if NewIndex >= 0 then I := NewIndex - 1
          else I := Min(I - 1, Inventory.Count - 1);
          Continue;
        end;
      end;
      Dec(I);
    end;
    Stage := 15;
    I := Artefacts.Count - 1;
    while I >= 0 do
    begin
      Stage := 16;
      Item := Artefacts[I];
      if TEquipment(Item).EquippedFlag <> 0 then
      begin
        Param := RunItemConfigActionCode(Item, ActionType, Self, Object1, Object2, Param);
        if IsHullDestroyed and (ActionType <> event_death) then
        begin
          CurrentScript := SavedScript;
          Result := Param;
          Exit;
        end;
        if (Artefacts.Count <= I) or (Artefacts[I] <> Item) then
        begin
          NewIndex := Artefacts.IndexOf(Item);
          if NewIndex < 0 then
          begin
            I := Min(I - 1, Artefacts.Count - 1);
            Continue;
          end;
          I := NewIndex;
        end;
      end;
      Stage := 17;
      if Item.ScriptItem <> nil then
      begin
        Param := TScriptItem(Item.ScriptItem).RunActionCode(ActionType, Self, Object1, Object2, Param);
        if IsHullDestroyed and (ActionType <> event_death) then
        begin
          CurrentScript := SavedScript;
          Result := Param;
          Exit;
        end;
        if (Artefacts.Count <= I) or (Artefacts[I] <> Item) then
        begin
          NewIndex := Artefacts.IndexOf(Item);
          if NewIndex >= 0 then I := NewIndex - 1
          else I := Min(I - 1, Artefacts.Count - 1);
          Continue;
        end;
      end;
      Dec(I);
    end;
    CurrentScript := SavedScript;
    Result := Param;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Error in procedure TShip.ScriptItemsAct ship=' + GetFullName(' ') +
        ' acttype=' + ScriptActionTypeNames[ActionType] + ' label = ' + SysUtils.IntToStr(Stage));
      if Stage = 4 then AppendLogLineThreadSafe(Info.TypeName);
      AppendLogLineThreadSafe(SysUtils.IntToStr(ScriptActionTypeStack.Count) + ',' +
        SysUtils.IntToStr(ScriptActionObject1Stack.Count) + ',' +
        SysUtils.IntToStr(ScriptActionObject2Stack.Count) + ',' +
        SysUtils.IntToStr(ScriptActionParamStack.Count) + ',' +
        SysUtils.IntToStr(ScriptActionShipStack.Count) + ',' +
        SysUtils.IntToStr(ScriptItemInfoContextStack.Count) + ',' +
        SysUtils.IntToStr(ScriptItemContextStack.Count));
      if ScriptShip <> nil then
      begin
        with ScriptShip as TScriptShip do
        begin
          AppendLogLineThreadSafe('script - ' + Script.ScriptFileName);
          AppendLogLineThreadSafe('state #' + SysUtils.IntToStr(Script.States.IndexOf(State)));
          AppendLogLineThreadSafe('(' + State.Name + ')');
        end;
      end;
      raise;
    end;
  end;
end;
{ @end $6F2B98 }

{ @routine $6F3650 TShip_CanDock }
function TShip.CanDock(Ship: TShip): Boolean;
begin
  Result := False;
end;
{ @end $6F3650 }

{ @routine $6F3654 TShip_CheckDockingPermission }
function TShip.CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean;
begin
  Response := '';
  Result := False;
end;
{ @end $6F3654 }

{ @routine $6F3664 TShip_RelationToShip }
function TShip.RelationToShip(Ship: TShip): TPercent;
begin
  if Ship = Self then
  begin
    Result := 100;
    Exit;
  end;

  if (Self is TTranclucator) and ((Self as TTranclucator).OwnerShip <> nil) then
  begin
    Result := (Self as TTranclucator).OwnerShip.RelationToShip(Ship);
    Exit;
  end;

  if Galaxy.SpecialSimulationMode <> 0 then
  begin
    if (GetPlayer = Ship) or (GetPlayer = Self) then Result := 100 else Result := 0;
    Exit;
  end;

  Result := 0;
  if (Ship = EnemyShip)
  then Exit;
  if (Ship.EnemyShip = Self)
  then Exit;
  if ((CurrentStanding = standing_dominator) <> (Ship.CurrentStanding = standing_dominator))
  then Exit;
  if ((CurrentStanding = standing_custom) <> (Ship.CurrentStanding = standing_custom))
  then Exit;
  if CurrentStanding = standing_custom then
  begin
    if (ScriptShip <> nil) and (Ship.ScriptShip <> nil) and
      (TScriptShip(ScriptShip).StateText = TScriptShip(Ship.ScriptShip).StateText) then Result := 100;
    Exit;
  end;

  if (Ship <> TruceShip) and (Ship.TruceShip <> Self) then
  begin
    if ((CurrentStanding = standing_coalition_military) and (Ship.CurrentStanding in [standing_pirate_active..standing_pirate_military]))
    then Exit;
    if ((CurrentStanding = standing_pirate_military) and (Ship.CurrentStanding in [standing_coalition_military..standing_coalition_active]))
    then Exit;
  end;
  if (CurrentStanding <> standing_dominator) and (Ship.TypeId = ship_dominator) and (Ship.CurrentStanding = standing_neutral) then Result := 100
  else if Ship is TRanger then Result := RelationToRanger(Ship)
  else if (Ship is TTranclucator) and ((Ship as TTranclucator).OwnerShip <> nil) then
    Result := RelationToShip((Ship as TTranclucator).OwnerShip)
  else Result := RelationToNonRanger(Ship);
end;
{ @end $6F3664 }

end.
