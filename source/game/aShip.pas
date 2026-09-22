unit aShip;
// Unit bracket (inferred): .text 0x00747BC4..0x0077F75C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Struct, SE_Space, Windows, aAsteroid, aEFilm, aGalaxy, aGalaxyStruct, aItem, aMyFunction, aPath, aPlanet;

type
  // View of TShip.Hull through DefGenerator ($F8..$114), indexed by item kind.
  // EquipItem / UnequipSlot use Self + ItemType * 4 + $50 in the native code.
  // These are cached pointers; the owning inventory remains a separate list.
  TShipEquipmentCacheView = packed record // @size $118
    Prefix: array[0..$F7] of Byte; // @offset $00
    Slots: array[t_Hull..t_DefGenerator] of TEquipment; // @offset $F8
  end;
  PShipEquipmentCacheView = ^TShipEquipmentCacheView;

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
    soNone = 0, soMove = 1, soLand = 2, soJump = 3,
    soJumpHole = 4, soTakeoff = 5, soFollowShip = 6, soTeleport = 7
  ); // @size 0x1

  TShipStatBonusEntry = record // @size 0x08
    BonusKind: TEquipmentBonusKind; // @offset 0x00
    BonusValue: Integer; // @offset 0x04
  end;
  PShipStatBonusEntry = ^TShipStatBonusEntry;

  TItemDegradationKind = (idkBattle = 0, idkUse = 1, idkForce = 2, idkAfterburner = 3); // @size 0x1

  TCombatStatusEffectType = (
    cseShock = 0, cseAcid = 1, cseMagnetic = 2, cseWeaponBlock = 3,
    cseDroidBlock = 4, cseBWBuff = 5, cseBWRepairDebuff = 6
  ); // @size 0x1

  TCombatStatusEffect = record // @size 0x0C
    EffectType: TCombatStatusEffectType; // @offset 0x00
    Strength: Single; // @offset 0x04
    SourceShipId: Integer; // @offset 0x08  Zero for no source; an ID, not a pointer.
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

  TShip = class(TObjectEx) // @size 0x4D0
  public
    Id: Integer; // @offset 0x04
    Name: WideString; // @offset 0x08
    TypeNameOverrideKey: WideString; // @offset 0x0C
    TypeId: Byte; // @offset 0x10  st* ship codes and TStationType station codes are declared in aGalaxyStruct.
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
    Hull: THull; // @offset 0xF8
    FuelTanks: TFuelTanks; // @offset 0xFC
    Engine: TEngine; // @offset 0x100
    Radar: TRadar; // @offset 0x104
    Scanner: TScaner; // @offset 0x108
    RepairRobot: TRepairRobot; // @offset 0x10C
    CargoHook: TCargoHook; // @offset 0x110
    DefGenerator: TDefGenerator; // @offset 0x114
    Weapons: array[1..5] of TWeapon; // @offset 0x118
    WeaponCount: Byte; // @offset 0x12C
    UsableWeaponCount: Byte; // @offset 0x12D
    BaseSkills: array[TPilotSkill] of Byte; // @offset 0x12E
    CaptainHealth: array[1..24] of TCaptainHealthState; // @offset 0x138  1..12: diseases; 13..24: stimulants.
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
    ChameleonVisualType: Byte; // @offset 0x463  Hull-dependent disguise silhouette.
    ChameleonDisplayCount: Integer; // @offset $464 Serialized counter displayed in active chameleon info ($7100F4); no gameplay update recovered.
    ChameleonDetected: array[0..2] of Boolean; // @offset 0x468  TDominatorSeries order.
    ChameleonCharges: array[0..2] of Integer; // @offset 0x46C  TDominatorSeries order.
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

    constructor Create; // @addr 0x747D08
    destructor Destroy; override; // @addr 0x748168
    procedure SaveToBuffer(Buffer: TBufEC); virtual; // @addr 0x748800 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); virtual; // @addr 0x7496BC @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); virtual; // @addr 0x74D484 @slot 0x08 @note "Converts saved IDs to object references; requires all referenced objects to have been loaded."
    procedure ClearObjectReferences; virtual; // @addr 0x74DAA8 @slot 0x0C @note "Clears navigation, docking and ship references, including item references; preserves CurrentStar, ScriptShip and LiberationGroup."
    procedure SaveToBlock(Block: TBlockParEC); virtual; // @addr 0x74AB50 @slot 0x10 @note "Editable subset; not a full save."
    procedure LoadFromBlock(Block: TBlockParEC); virtual; // @addr 0x74BD2C @slot 0x14 @note "Applies edits to existing state and can append items or issue new orders. Cargo quantities change without updating cost basis."
    procedure NextDay; virtual; // @addr 0x74E3E8 @slot 0x18 @calls "0x7C730A 0x7B07EF"
    procedure NextDayLogic; virtual; // @addr 0x74F058 @slot 0x1C
    procedure ProcessBrokenFuelTankLeak; // @addr 0x74DCD4 @note "Can cancel the player's jump when remaining fuel is insufficient."
    procedure RefreshTechKnowledgeAtLocation; // @addr 0x74DFF4 @note "Can unlock carried equipment use/repair and notify the player."
    procedure DerivedStateCompatibilityHook; // @addr 0x74F0A4 @note "Native no-op, called after loading/editing and refreshing derived stats."
    procedure AssignWeaponTargetsInStar; virtual; // @addr 0x74F064 @slot 0x20 @note "The base implementation clears all weapon targets."

    // Abstract entries in native TShip VMT 0x747C10 share the RTL stub at 0x40358C.
    // Signatures come from verified concrete overrides and their callers.
    function GetName: WideString; virtual; abstract; // @slot 0x24
    function GetFullName(const Separator: WideString): WideString; virtual; abstract; // @slot 0x28 @calls "0x777ECB 0x777EFB 0x777F29"
    function GetGreetingShipCategory: TGreetingShipCategory; virtual; abstract; // @slot 0x30 Category bit in ship-greeting ShipType, ToShipType and ShipBadType filters.
    function GetHomeStar: TStar; virtual; abstract; // @slot 0x34
    function GetDominantCareer: TRangerCareer; virtual; abstract; // @slot 0x38
    function GetStrengthScaledPirateStatus: TPercent; virtual; abstract; // @slot 0x3C
    procedure RefuelAtLocation; virtual; abstract; // @slot 0x48
    procedure RepairBrokenEquipmentAtLocation; virtual; abstract; // @slot 0x60
    procedure BuildReachablePlanetQueue; virtual; abstract; // @slot 0x64
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; virtual; abstract; // @slot 0x68
    procedure SelectEnemyShipInStar; virtual; abstract; // @slot 0x6C
    procedure EngageEnemyShip; virtual; abstract; // @slot 0x70
    function RelationToRanger(Ranger: Pointer): Byte; virtual; abstract; // @slot 0x74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); virtual; abstract; // @slot 0x78
    procedure ReactToAttack(Attacker: TShip); virtual; abstract; // @slot 0x7C
    function RelationToNonRanger(Ship: TShip): Byte; virtual; abstract; // @slot 0x80
    function RecomputeFearState: Boolean; virtual; abstract; // @slot 0x84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; virtual; abstract; // @slot 0x88
    function TrustsAttackRequester(Ship: TShip): Boolean; virtual; abstract; // @slot 0x8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; virtual; abstract; // @slot 0x90 Relation/strength gate for protecting a ship or sparing pickup targets; other dialogue conditions are checked by the caller.
    procedure ProcessCombatDialogue; virtual; abstract; // @slot 0xA0
    procedure ReactToExtortionDemand(Ranger: Pointer); virtual; abstract; // @slot 0xA4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; virtual; abstract; // @slot 0xA8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; virtual; abstract; // @slot 0xAC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; virtual; abstract; // @slot 0xB0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; virtual; abstract; // @slot 0xB4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; virtual; abstract; // @slot 0xB8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; virtual; abstract; // @slot 0xBC

    procedure TransferToStar(Star: TStar); // @addr 0x7522FC @note "Moves Self and docked ships between star lists; does not clear InHyperspace."
    procedure TryRelocateUnseenShip; // @addr 0x7525B4 @note "Can subsidize and queue an unseen NPC for relocation to a peaceful Coalition system; excludes protected quest/script/partner ships."
    procedure LeaveLiberationGroup; // @addr 0x75E3F4 @note "Requires a current liberation group."
    procedure ProcessLiberationGroupRoute; // @addr 0x75DE84 @note "Requires an in-range route index when a group is assigned; may leave the group or issue travel/combat orders."
    procedure ReassignActiveItemSlots(ItemType: TItemType); // @addr 0x7745C0 @note "Repairs duplicate/out-of-range equipped slots; unequips overflow and preserves slot flag bit 7."
    procedure RefreshAssignedItemSlots; // @addr 0x77480C
    procedure RefreshInactiveItemSlotAssignments; // @addr 0x774968
    procedure RepairDuplicateSatelliteTrajectoryIndices; // @addr 0x774A90
    function GetSatelliteTrajectoryIndexLimit: Integer; // @addr 0x774B68 @note "One past the largest carried satellite index, or zero."
    function FindFreeSatelliteTrajectoryIndex: Integer; // @addr 0x774BF8
    function FindSatelliteByTrajectoryIndex(Index: Integer): TSatellite; // @addr 0x774C74
    procedure InsertSatelliteTrajectoryIndex(Index: Integer); // @addr 0x774CEC @note "Shifts indices at or above Index upward."
    procedure RemoveEmptySatelliteTrajectoryIndex(Index: Integer); // @addr 0x774D64 @note "Does nothing if Index is occupied."
    procedure CompactSatelliteTrajectoryIndices; // @addr 0x774DEC
    procedure AssignSatelliteIndicesFromHoldOrder; // @addr 0x774E4C @note "Uses and refreshes global hold-view state."
    procedure ArrangeHoldSatellitesByTrajectoryIndex; // @addr 0x775094 @note "Reorders the satellite entries in the global hold view."
    function UseDominatorTransmitter(Artefact: TArtefactTransmitter): Boolean; // @addr 0x7753E0 @note "Requires minimum charge; records a galaxy event and consumes charge even if no Dominators respond."
    function HasMatchingArtefactOrCustomItem(Item: TItem): Boolean; // @addr 0x7759DC @note "Custom items match by configuration name; generic artefacts also compare names."
    procedure ApplyNanoArtefactRepair; // @addr 0x776890 @note "Prefers installed inventory equipment; selects at most one repairable item and may clear BrokenFlag."
    function CanContactShip(OtherShip: TShip): Boolean; // @addr 0x776B58 @note "Uses Self's radar with a 500-unit minimum and both NoTalk flags; does not test system membership."
    function OpenPlayerConversation(RespectChameleon: Boolean): Boolean; // @addr 0x777128 @note "Turn-worker/UI handshake; waits for conversation completion or shutdown. Requires an active visible-space turn."
    function ShowPlayerDialogue(Kind: TTalkKind; const Text: WideString; Amount: Integer): Byte; // @addr 0x777284 @note "Returns the global dialogue response, or zero when conversation cannot open. Amount only replaces the global amount when positive."
    procedure NotifyMoneyDemand(OtherShip: TShip; Response: WideString; Amount: Integer); // @addr 0x7772E8
    procedure NotifyCargoDemand(OtherShip: TShip; Response: WideString); // @addr 0x777594
    procedure NotifyFearCargoDrop(OtherShip: TShip); // @addr 0x7777F4
    procedure NotifyTruceOffer(OtherShip: TShip; Response: WideString; Amount: Integer); // @addr 0x777AF8
    procedure NotifyAttackRequest(OtherShip: TShip; Response: WideString; Target: TShip); // @addr 0x777DF0
    procedure NotifyPartnershipOffer(OtherShip: TShip; Response: WideString; Amount: Integer); // @addr 0x7780E4
    procedure NotifyPartnerBreak(Leader: TShip); // @addr 0x7783B8
    procedure NotifyPartnershipExpired(Leader: TShip); // @addr 0x7786E0
    procedure NotifyPartnerRebellion(Leader: TShip); // @addr 0x778AF0
    procedure ShowMessageToPlayer(Text: WideString); // @addr 0x778E14
    procedure NotifyPiratePartnerRelationBreak(Leader: TShip); // @addr 0x778F50
    procedure NotifyPiratePartnerRatingBreak(Leader: TShip); // @addr 0x779284
    procedure NotifyPiratePartnershipExpired(Leader: TShip); // @addr 0x7795B4
    procedure NotifyPiratePartnerRebellion(Leader: TShip); // @addr 0x7799BC
    function RefusesFactionNegotiation(OtherShip: TShip): Boolean; virtual; // @addr 0x779CDC @slot 0xC0 @note "Rejects truce, extortion and protection negotiations for faction enemies. Base returns false; warrior/pirate overrides inspect OtherShip.CurrentStanding and system control."
    function CalculatePartnershipMonths(Amount: Integer; OtherShip: TShip): Integer; // @addr 0x779CF4 @note "Payment/wealth and relation determine contract months; a player stimulant can double the result."
    function GetGreetingText: WideString; // @addr 0x779DF0
    procedure InitializeScriptStateOrders; // @addr 0x77A8F8 @note "Requires ScriptShip; clears EndState, applies state orders and refreshes completion/pickup state."
    procedure ApplyScriptStateOrders; // @addr 0x77A934 @note "Requires ScriptShip; may issue travel orders and assign script-selected weapon targets."
    procedure UpdateScriptStateCompletionAndPickups; // @addr 0x77AE70 @note "Requires ScriptShip; updates EndState and queues state-requested pickups."
    function FindScriptFollowTarget: TShip; // @addr 0x77B4B8 @note "Requires ScriptShip; matches the state's group in the current system."
    procedure RemoveExperience(Amount: Integer); // @addr 0x77B73C @note "Subtracts independently from total and free experience, capped at each current balance."
    function CanTrainSkill(Skill: TPilotSkill): Boolean; // @addr 0x77BA18
    function GetRelativeStrengthCategory: Byte; // @addr 0x77BE8C @note "Returns a category from 1 to 5 using StrengthInBestRanger."
    function GetHullConditionCategory: Byte; // @addr 0x77BFF0 @note "Categories 1..5 split rounded hull percentage at 20, 50, 70 and 90."
    function IsFemaleHumanPilot: Boolean; // @addr 0x77D09C @note "Human portrait IDs 25..32 on normal NPC ships; excludes special simulation mode."
    function UsesVeteranHumanRangerAppearance: Boolean; // @addr 0x77D108 @note "Native resource key RangerOldFag; deterministic ID/creation-turn selection, excluding female pilots and the player."
    function SelectInterceptorTarget: TShip; // @addr 0x77D384
    procedure LaunchInterceptors; // @addr 0x77D520 @note "Clears an explicit target before checking energy; successful launch installs source/pass state and a graphic on the target."
    procedure ClearIncomingInterceptors; // @addr 0x77D680 @note "Clears source/pass state and releases the interceptor graphic."
    function CountActiveInterceptorTargets: Integer; // @addr 0x77D6C8 @note "Counts ships referring to Self as interceptor source across all galaxy systems."
    function GetHullEnergyRegeneration: Integer; // @addr 0x77D75C
    function GetInterceptorEnergyCost: Integer; // @addr 0x77D854
    function GetInterceptorPassCount: Byte; // @addr 0x77D87C @note "Hull override or five when zero."
    procedure SetStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer); // @addr 0x77DA18 @note "Zero removes and frees the matching bonus entry; nonzero inserts or replaces it."
    procedure UpdateAfterburnerState; virtual; // @addr 0x77E6D4 @slot 0x9C @note "Native base implementation is a no-op."
    function HasScriptStateText: Boolean; // @addr 0x77E71C
    function CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean; virtual; // @addr 0x77F4D0 @slot 0xCC @note "Base implementation clears Response and returns false."

    procedure ScriptNextDay; // @addr 0x77B05C @note "Requires ScriptShip; script execution can remove the binding."
    function ScriptItemsAct(ActionType: Byte; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x77E910 @note "Returns Param after script handlers modify it; object slots may carry event-specific integer values."
    procedure RefreshCurrentStanding; virtual; // @addr 0x77E6E0 @slot 0xC4 @calls "0x7C72BB 0x7D0336 0x7D03DD"
    function ScanForCollectableItems: Boolean; // @addr 0x76B2F4
    function TryCollectBestFloatingItem(MaximumTravelTurns: Integer): Boolean; // @addr 0x76B490 @note "May queue nearby pickups and issue/cancel a move order; true means a move order remains."
    function AcceptPickupItem(Item: TItem): Boolean; virtual; // @addr 0x76B944 @slot 0x94 @note "Base implementation returns false."
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; virtual; // @addr 0x76BD24 @slot 0x98 @note "Base implementation returns true."
    procedure RemoveInvalidPickupTargets; // @addr 0x76BE58 @note "Frees the target list when it becomes empty."
    function GetPickupApproachPosition(ItemPosition: TPointF): TPointF; // @addr 0x76C1F0
    function GetCurrentPickupItem: TItem; // @addr 0x76C28C
    function GetArrivalPosition(DestinationStar: TStar): TPointF; // @addr 0x76C5D4 @note "Point on the destination map boundary facing the current system."
    function GetMovementPathTurnCount: Integer; // @addr 0x76CEF0 @note "Ceiling of active path-node count times the star's MovementStepScale."
    function IsTravelCompletionPathReady: Boolean; // @addr 0x770FFC @note "Tests landing, jump, hole and teleport completion conditions against the prepared path."
    procedure RepelFollowingShips; // @addr 0x771208 @note "Adjusts RepulsionPosition on Self and nearby following ships using their collision radii."
    procedure RebuildMovePath; // @addr 0x77181C @note "Uses the current turn's step limit; rewrites OrderDestination to the resulting endpoint."
    procedure BuildFullPathTo(Destination: TPointF); // @addr 0x771898 @note "Clears the old path and uses aGroup, a 999999-node limit."
    procedure BuildPlanetLandingPath; // @addr 0x7718EC
    procedure BuildOrderMovementPath(MaximumNodes: Integer); // @addr 0x7719F4 @note "Clears the path, normalizes heading and handles the current order; may commit jump departure or adjust the destination."
    procedure AppendPathToWithTurnPadding(Destination: TPointF; MaximumNodes: Integer); // @addr 0x77288C @note "Turning then straight movement; may pad the player's visible turn to 200 nodes."
    procedure AppendPathTo(Destination: TPointF; MaximumNodes: Integer); // @addr 0x7729A8
    procedure AppendStarAvoidingPathWithTurnPadding(Destination: TPointF; MaximumNodes: Integer); // @addr 0x772A54
    procedure AppendOrbitalPath(MaximumNodes: Integer); // @addr 0x772B60 @note "Appends up to 200 nodes around the system origin, with visible-turn padding."
    procedure AppendTurningPath(Destination: TPointF; AvoidStar: Boolean; MaximumNodes: Integer); // @addr 0x772D04
    procedure AppendStraightPath(Destination: TPointF; MaximumNodes: Integer); // @addr 0x773568
    procedure AppendHyperspaceTransitionPath(Direction: Single); // @addr 0x7738AC @note "Positive/negative Direction selects the outgoing/incoming transition path."
    procedure AppendStarAvoidingPath(Destination: TPointF; MaximumNodes: Integer); // @addr 0x773AB0
    procedure AppendCircularDetour(Destination: TPointF; MaximumNodes: Integer; Radius: Double); // @addr 0x773E38

    procedure PrepareTurnMovement(StartStepIndex: Integer; RecordFilm: Boolean); // @addr 0x76D098
    function ProcessMovementStep(StepIndex: Integer; RecordFilm: Boolean): Boolean; // @addr 0x7700D4 @note "The native result remains false."
    procedure ClearCompletedTakeoffOrHoleOrder(UnusedStepIndex: Integer; UnusedRecordFilm: Boolean); // @addr 0x770FA0
    procedure RefreshDerivedStats(UpdateRelativeRatings: Boolean); // @addr 0x75FF4C
    procedure UpdateBestRangerRelativeRatings; // @addr 0x750258
    procedure UpdateAverageRangerRelativeStrength; // @addr 0x7502E0 @note "Does not guard against zero AverageRangerStrength."
    function GetRangerRatingBand: Byte; // @addr 0x77C100 @note "Zero for non-rangers; otherwise 1..5 from the rounded experience-rank percentile. Uses all galaxy rangers, including excluded entries."
    function GetCaptainPortraitResourceBase: WideString; // @addr 0x750A40 @note "May assign PortraitFaceId lazily. Returns a resource base without the GI prefix or animation suffix."
    function IsInPrison: Boolean; // @addr 0x75CA70
    function GetPrisonTermRemaining: Integer; // @addr 0x75CAE8 @note "Rangers and pirates only; other classes return zero."
    procedure ClearPrisonTerm; // @addr 0x75CB40
    function GetPrisonReleaseCost: Integer; // @addr 0x75CB8C @note "Zero without a positive term; otherwise at least 100, using cached Wealth."
    function CalculateStrength: Double; // @addr 0x7507B4 @note "Updates Strength; calculating the player's strength also refreshes galaxy ranger strength statistics."
    function CalculateAttackStrength: Double; // @addr 0x75046C
    function CalculateDefenseStrength: Double; // @addr 0x750674
    function GetRepairStrengthFactor: Double; // @addr 0x750758
    function GetFullHullRelativeStrengthPercent: Byte; // @addr 0x750820 @note "Temporarily restores hull points. Leaves cached Strength and player galaxy-strength statistics at the full-hull values; byte result is not clamped."
    function GetEstimatedMemoryUsage: Integer; virtual; // @addr 0x74FE50 @slot 0x44 @note "Counts the instance and selected list storage; excludes item objects and managed strings."
    function GetDefaultHullType: Byte; // @addr 0x74F294
    function SelectRandomHullSeries: Integer; // @addr 0x76AF9C @note "Normal ships use PilotRace rather than OwnerId; selects rarity 1..100 through the galaxy RNG."
    function NextRandomInteger(Minimum, Maximum: Integer): Integer; // @addr 0x74F384
    function GetTurnSeedFraction(TurnOffset: Integer): Single; // @addr 0x74FE0C @note "Fractional part of signed Seed divided by CurrentTurn + TurnOffset; denominator must be nonzero. Does not advance RandomState."
    function GetWealthScaledAmount(ScaleIndex: Byte): Integer; // @addr 0x750888 @note "Uses cached Wealth and the configured scale table; no index validation."
    function GetTypeNameKey: WideString; virtual; // @addr 0x74F0B0 @slot 0x2C @calls "0x777F3D 0x730B93"
    function GetLocalizedTypeName: WideString; // @addr 0x74F0D8
    function GetFactionNameKey: WideString; // @addr 0x74F20C
    function GetSpaceInfoText: WideString; // @addr 0x74F3B4 @note "Requires a player; includes current order, hull, speed and relation information."
    function GetShipPortraitImagePath: WideString; // @addr 0x750954 @note "Leaves the result storage unchanged when Graphic is not a supported graphic class."
    procedure RefreshGraphicSize; // @addr 0x7600C4 @note "Requires Graphic; chooses dimensions from ship class, hull and special equipment."
    function GetCargoGoodsWeight: Integer; // @addr 0x76086C
    function CalculateFollowRadius: Integer; // @addr 0x7608A0 @note "Requires a follow order; uses weapon ranges or the ships' collision radii."
    function GetFollowMode: Byte; // @addr 0x760A4C @note "Raises when the current order is not follow."
    function GetEffectiveFollowMode: Byte; // @addr 0x760AB0 @note "Requires a follow order; applies tactical and map-edge adjustments without modifying OrderStateData."
    function NeedsEquipmentType(ItemType: TItemType): Boolean; // @addr 0x760BE4
    function CountCarriedEquipmentByType(ItemType: TItemType): Integer; // @addr 0x760CD0 @note "Skips inventory index zero; any weapon request counts all weapon types."
    function SelectBestUnequippedWeapon: TWeapon; // @addr 0x760D4C
    procedure DropUnequippedItemsAndGoods; // @addr 0x760FC4 @note "Preserves named script items; drops through the normal item/artefact helpers."
    procedure AddItemToPlayerStorage(Item: TItem; Location: TObject; Slot: Integer); // @addr 0x7610A8 @note "Always adds to the player's storage, even when Self is an NPC. Caller must detach the item from its previous owner. Negative Slot allocates a free slot."
    procedure MergeItemIntoPlayerStorage(Item: TItem; Location: TObject; Slot: Integer); // @addr 0x7611A0 @note "Transfers ownership; a successful goods/countable merge frees Item."
    procedure AddGoodsToPlayerStorage(Good: Byte; Quantity, Cost: Integer; Location: TObject; Slot: Integer); // @addr 0x761350 @note "Positive quantities only; Cost is the total cost basis, not a unit price."
    function StoreLooseInventoryAt(Location: TObject): Boolean; // @addr 0x76150C @note "Uses the player's storage filters. Returns true for an eligible location even if nothing was moved."
    function RetrieveStoredItems(Location: TObject): Boolean; // @addr 0x7616F4 @note "Transfers matching player storage entries into Self; returns location eligibility, not whether items were retrieved."
    procedure AutoEquipArtefacts; // @addr 0x761AB8
    function CalculateItemEffectiveness(Item: TItem): Single; // @addr 0x761E54 @note "Temporarily changes weapon installation and disables ChaoticRandom while evaluating equipment; restores them on the normal path."
    function EstimateWeaponDamageAgainstTypicalDefense(Item: TItem): Single; // @addr 0x76283C @note "Returns one for a non-weapon; adjusts weapon damage for galaxy technology and accuracy."
    function GetItemFuelTankCapacity(Item: TItem): Integer; // @addr 0x762D00 @note "Zero unless Item is fuel tanks."
    function GetEquipmentEvaluationSynergyBonus(Item: TEquipment): Single; // @addr 0x763560
    function GetWeaponArtefactDamageFactor(Weapon: TWeapon): Single; // @addr 0x763F98
    procedure RefreshEquipmentEvaluationMetrics; // @addr 0x7642BC
    function EvaluateItem(Item: TItem; PriceMode: Byte): Single; // @addr 0x7645E0
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; virtual; // @addr 0x76461C @slot 0x50 @note "Price modes: 1 negated item cost, 3 resale value, 4 item cost; other modes omit the price term. Mode 0 also omits weight/fragility penalties; the supplied effectiveness is recomputed."
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; virtual; // @addr 0x764AA8 @slot 0x54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; virtual; // @addr 0x7656F8 @slot 0x58
    function EvaluateMicroModuleGain(Item: TEquipment; ModuleIndex: Integer): Single; virtual; // @addr 0x765D28 @slot 0x5C @note "Evaluates a temporary clone; restores NextItemId but leaves LoadedSaveVersion set to CurrentSaveVersion. ModuleIndex is zero-based."
    procedure AutoApplyMicroModules; // @addr 0x765ECC @note "Consumes beneficial carried modules, preferring installed equipment; refreshes derived stats after each application."
    procedure DropCargoUntilNotOverloaded; // @addr 0x766550 @note "Sells at a location or jettisons in space. May flag a long-stranded NPC for destruction when overload cannot be resolved."
    procedure DropRandomCheapItemsOnDestruction(Count: Integer); // @addr 0x766E38
    procedure DropRandomValuableItemsOnDestruction(Count: Integer); // @addr 0x7670BC
    procedure DropItemsForDominatorProgram(Count: Integer); // @addr 0x76711C @note "Requires a Dominator; used by dialogue and Script.DomikProgramm. Attempts at most 100 selections."

    procedure RefreshGraphic; // @addr 0x7517FC @note "ScriptChameleon preserves the assigned graphic while updating GraphDominator."
    procedure CreateNormalGraphic; // @addr 0x75188C
    procedure CreateDominatorGraphic; // @addr 0x752128
    function SelectChameleonVisualType: Byte; // @addr 0x7515F0
    function HasPlayerChameleonCharges: Boolean; // @addr 0x7515B4 @note "Reads the player rather than Self; requires a player."
    function IsPlayerChameleonEffectiveAgainstSelf: Boolean; // @addr 0x7516E4 @note "Requires a player; action-17 script handlers can override the default result."

    // Except OrderJumpHole, new orders respect AbsoluteScriptOrder.
    procedure OrderNone(OverrideScriptOrder: Boolean); // @addr 0x76C434
    procedure OrderMove(Destination: TPointF; Absolute: Boolean); // @addr 0x76C480
    procedure OrderJump(Star: TStar; Absolute: Boolean); // @addr 0x76C6F8
    procedure OrderJumpHole(Hole: THole; Absolute: Boolean); // @addr 0x76C7A0 @note "Does not check AbsoluteScriptOrder."
    procedure OrderLanding(Location: TObject; Absolute: Boolean); // @addr 0x76C8B4 @note "Location is a planet or dockable ship."
    procedure OrderTakeoff; // @addr 0x76C940
    procedure OrderFollowShip(Ship: TShip; FollowMode: Byte; Absolute: Boolean); // @addr 0x76CE94
    procedure OrderTeleport(Star: TStar; Destination: TPointF; TransitionData: Integer; Absolute: Boolean); // @addr 0x76C848
    procedure ClearMovementPath; // @addr 0x774104
    function HasLockedOrFollowOrder: Boolean; // @addr 0x750070 @note "True for OrderAbsolute, AbsoluteScriptOrder, or a follow-ship order."
    procedure CancelInvalidTravelOrder; // @addr 0x752B8C @note "Checks only ships in star space; clears the player auto-follow target when cancelling."
    procedure SynchronizeDockedLocation; // @addr 0x75293C @note "Copies the carrier's star and position, moving star-list membership when necessary. Does nothing without DockedTo."
    procedure OrderRandomFreeFlightMove; // @addr 0x75367C
    function TryMirrorPartnerTravelOrders: Boolean; // @addr 0x752FFC @note "Requires a ranger PartnerShip. True reports handled travel, not necessarily a changed or accepted order."
    function CanEscapePursuer(Pursuer: TShip): Boolean; // @addr 0x753744 @note "AI estimate using range, hull and travel time. Pursuer weapon range is evaluated using Self's bonuses."
    function FindNextStarTowardDestination(Destination: TStar; RequireFuelMargin: Boolean): TStar; // @addr 0x753A90 @note "Returns a borrowed intermediate star or nil. Uses raw full-fuel range and current distance caches; excludes sector 20. A direct reachable destination returns the current star."
    function IsTargetStillPursuable(Target: TShip): Boolean; // @addr 0x7536F0 @note "False only when Target is jumping and its distance is at least twice Self.Speed; does not validate shared star or speed."
    function HasLandablePlanetInStar(Star: TStar): Boolean; // @addr 0x7539DC
    function FindFirstInhabitedPlanetInStar: TPlanet; // @addr 0x752E1C @note "Requires a nonempty planet list; returns the last planet if all are uninhabited."
    function FindNearestDockableStation(StandingMask: TShipStandings): TShip; // @addr 0x752D3C @note "Types 6..13 whose CanDock(Self) succeeds. Zero mask permits every standing; does not independently filter hyperspace/docking."
    function GetFullFuelBaseJumpRange: Integer; // @addr 0x753A44 @note "Minimum of raw tank Capacity and engine JumpRange; requires both items and ignores bonuses/condition."
    function DistanceToNearestShipByTypeMask(ShipTypeMask: TShipTypeMask): Double; // @addr 0x753D58 @note "Excludes Self but includes docked/hyperspace entries; no match returns sqrt(1000000000)."
    function EstimateOrderTravelTurns: Integer; // @addr 0x753E00 @note "Uses rounded distance / (Speed + 1) + 1; unsupported orders return zero."
    function EstimateTravelTurnsToObject(Target: TObject): Integer; // @addr 0x753FC4 @note "Accepts planet, ship or star; a star estimates travel to the current system boundary, excluding hyperspace transit. Other classes return zero."
    function EstimateTravelTurnsToPlanet(Planet: TPlanet): Integer; // @addr 0x75415C @note "Returns -1 for zero speed, nil planet/star, or a different star."
    function CanDock(Ship: TShip): Boolean; virtual; // @addr 0x77F4B8 @slot 0xC8 @note "Base implementation always returns false."
    function CalculateJumpTravelDays(Origin, Destination: TStar): Integer; // @addr 0x76C678 @note "Minimum two days; independent of equipment and fuel."
    function GetJumpDeparturePoint(Destination: TStar): TPointF; // @addr 0x76C4F8

    function LookupTalkText(const Path: WideString): WideString; // @addr 0x776C98 @note "Selects among at most ten contiguous variants using ship seed and turn; substitutes ship names and HomePlanet. Missing text returns an unavailable marker."
    function LookupVisibleTalkText(const Path: WideString; OtherShip: TShip): WideString; // @addr 0x750178 @note "Returns empty unless the player shares CurrentStar. Substitutes OtherShip for <TalkShip>."
    function RelationToShip(Ship: TShip): TPercent; // @addr 0x77F4F4
    function GetRelationLevelToShip(Ship: TShip): TRelationLevel; // @addr 0x75BE58
    function GetRelationLevelTextToShip(Ship: TShip): WideString; // @addr 0x75BEC0 @note "Stations can display their stored ranger relation instead of the effective relation."

    function InNormalSpace: Boolean; // @addr 0x7529F0
    function IsOutsideStarSpace: Boolean; // @addr 0x752A78 @note "True without a current star, while docked/in hyperspace, or with a saved player ruins docking target."
    function IsOnPlanet: Boolean; // @addr 0x752AE0
    function IsDockedToShip: Boolean; // @addr 0x752AFC
    function IsDocked: Boolean; // @addr 0x752B18
    function IsHullDestroyed: Boolean; // @addr 0x74FDEC
    function HasPositiveSpeed: Boolean; // @addr 0x752B44
    procedure UpdateSpeedTrackingMetrics; // @addr 0x764230
    function HasHullDamageOrBrokenEquippedItems: Boolean; // @addr 0x7500B0
    procedure FireWeaponAtAsteroid(Weapon: TWeapon; Target: TObject; RecordFilm: Boolean); // @addr 0x7597E4 @note "Ignores non-asteroid targets. Respawning preserves the target object but invalidates its previous motion and mineral reserve."
    procedure FireWeaponAtMissile(Weapon: TWeapon; Target: TObject; RecordFilm: Boolean); // @addr 0x7571AC @note "Ignores non-missile targets; can free the target and nearby missiles."
    procedure FireWeaponAtShip(Weapon: TWeapon; Target: TShip; RecordFilm: Boolean); // @addr 0x757D20 @note "Can affect additional ships through chained, area or penetrating fire."
    procedure FireWeaponAtItem(Weapon: TWeapon; Target: TItem; RecordFilm: Boolean); // @addr 0x7590FC @note "Weapon may be nil. Script handlers can change the target; a destroyed item may explode and be freed."
    function ApplyDamage(Source: TObject; Damage: Integer; HitRange: Single; out DamageColor: Cardinal; DamageFlags: TDamageFlagSet): Integer; // @addr 0x7544DC @ida "int __userpurge $name@<eax>(TShip *Self@<eax>, TObject *Source@<edx>, int Damage@<ecx>, float HitRange@<^8>, unsigned int *DamageColor@<^4>, unsigned int DamageFlags@<^0>);" @note "Source may be nil, ship or missile. HitRange=-1 selects direct-hit rules; other values select area-hit rules. Returns adjusted damage, zero for rejection, or negative damage for an impulse-shield block; not actual hull loss. May run death handling without freeing Self."
    function ApplyWeaponHit(Source: TShip; Weapon: TWeapon; HitRange: Single; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet; DamageScale: Single; FixedDamage: Integer): Integer; // @addr 0x756768 @note "Returns ApplyDamage's signed result. Positive FixedDamage bypasses the initial roll/armor stage unless weapon flag 0x800 is already set; later effects still apply."
    function ApplyMissileHit(Missile: TObject; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet): Integer; // @addr 0x756E4C @note "Requires a TMissile; returns ApplyDamage's signed result."
    function ApplyInterceptorDamage(out DamageColor: Cardinal): Integer; // @addr 0x759A40 @note "Uses InterceptorSourceShip; absent source gives base damage 25. Returns ApplyDamage's signed result."
    function GetInterceptorDamage: Integer; // @addr 0x77D7F8
    function ApplyShockStatusDamage(out DamageColor: Cardinal): Integer; // @addr 0x759B7C @note "Uses rounded shock strength and nonlethal flag 0x1000; returns ApplyDamage's signed result."
    function ApplyExplosionDamage(SourceShip: TShip; ExplodingObject: TObject; ExtraDamage: Integer; Missile: TObject): Integer; // @addr 0x759F7C @note "ExplodingObject may be an item or ship; SourceShip and Missile may be nil. Returns script-adjusted damage, not actual hull loss; can trigger death handling without freeing Self."
    function ApplyStarHeatDamage: Integer; // @addr 0x75A474 @note "Also refuels up to five units inside the damage radius. Returns script-adjusted damage; Dominator bosses survive with at least one hull point."
    procedure NotifyCompanionDeath; // @addr 0x7541D8 @note "Ranger, pirate or Tranclucator death notification; does not itself check player partnership."
    function ApplyAsteroidImpactDamage(Asteroid: TAsteroid; out DamageColor: Cardinal): Integer; // @addr 0x759BC0 @note "Returns script-adjusted damage, which may exceed actual hull loss. DamageColor uses the current packed pixel format and is zero for nonpositive damage."
    function GetDesiredCargoFreeSpace: Integer; virtual; // @addr 0x74FDD4 @slot 0x40
    procedure ClearPlanetQueue; // @addr 0x752C20
    procedure TruceWithShip(Ship: TShip); // @addr 0x75C22C @note "Cancels reciprocal attacks and pursuers, including wingmen/Tranclucators and missiles. Only the player's TruceShip is set reciprocally."
    procedure SetJointAttackTarget(Ally, Target: TShip); // @addr 0x75B9BC @note "Assigns both ships' enemies and eligible weapons, then issues pursuit orders where possible."
    function IsEnemyPursuingSelf: Boolean; // @addr 0x75BB9C
    function TryExtortShip(Target: TShip): Boolean; // @addr 0x75BF90 @note "Attempts a cargo or money demand through the target's dialogue handler; requires a player."
    procedure RequestAlliesAttackShip(Target: TShip); // @addr 0x75C634 @note "May ask the player or nearby allied NPCs; requires a player."
    procedure SetStoredRangerRelationLevel(Ranger: TShip; Level: TRelationLevel); // @addr 0x75BCBC @note "Requires a non-nil relation list; nonempty lists require a registered ranger. Stores representative values 5, 20, 45, 70 or 90."
    function SelectNearestQueuedPlanet: TPlanet; // @addr 0x752C50 @note "Requires a non-nil queue ordered with current-star planets first; otherwise falls back to the first entry. Empty queue returns nil."
    function NavigateToQueuedPlanet(Absolute: Boolean): TPlanet; // @addr 0x752E88 @note "Can build PlanetQueue and issue a landing or jump order. Result is borrowed and may be nil."
    function NavigateToEscapePlanet(Absolute: Boolean): Boolean; // @addr 0x752F18 @note "Uses the existing PlanetQueue; false means it is nil or empty. True does not guarantee that the order was accepted."
    procedure SetMoney(Value: Integer); // @addr 0x74DC04 @note "Clamps to 0..100000000."
    function CalculateWealth: Integer; // @addr 0x750308 @note "Updates Wealth. Includes player storage and accrued deposit but does not subtract debt; capped at MaxInt."
    function CalculateEquippedItemCostWithoutHull: Integer; // @addr 0x760C28 @note "Includes equipped artefacts."

    function GetHull: THull; // @addr 0x75E62C
    function GetFuelTanks: TFuelTanks; // @addr 0x75E648
    function GetEngine: TEngine; // @addr 0x75E664
    function GetRadar: TRadar; // @addr 0x75E680
    function GetScanner: TScaner; // @addr 0x75E69C
    function GetRepairRobot: TRepairRobot; // @addr 0x75E6B8
    function GetCargoHook: TCargoHook; // @addr 0x75E6D4
    function GetDefGenerator: TDefGenerator; // @addr 0x75E6F0
    function CanUseEquipmentTech(Item: TEquipment): Boolean; // @addr 0x75E7B0
    function CanRepairEquipmentTech(Item: TEquipment): Boolean; // @addr 0x75E880
    function IsEquipmentUsable(Item: TEquipment): Boolean; // @addr 0x75E980 @note "Does not require EquippedFlag."
    procedure RebuildEquipmentCache; // @addr 0x7605F4 @note "Can unequip items whose slots are unavailable."
    procedure EquipItem(Item: TEquipment); // @addr 0x75E9CC @note "Does not add Item to the inventory."
    procedure UnequipSlot(ItemType: TItemType; WeaponIndex: Integer); // @addr 0x75EA9C @note "Direct types 42..49 require a populated slot; weapon types 50..68 require a valid one-based WeaponIndex. Compacts the weapon cache; does not remove/free inventory."
    procedure UnequipItem(Item: TEquipment); // @addr 0x75EB74 @note "Only affects cached installed equipment. Requires non-nil Item."
    function CanRepairArtefactsAtLocation: Boolean; // @addr 0x75E70C @note "Pirate/science bases, licensed station names and the main pirate planet; follows DockedTo recursively."
    function CountEquippedWeapons: TWeaponCount; // @addr 0x75A9C0
    function CountMissileWeapons: TWeaponCount; // @addr 0x75AA2C @note "Counts torpedo/missile/rocket shot types; does not check usability or ammunition."
    function CountDirectFireWeapons: Byte; // @addr 0x75AA80 @note "Complement of CountMissileWeapons over cached equipped weapons."
    function CountWeaponsByDamageFlags(Flags: TDamageFlagSet): TWeaponCount; // @addr 0x75AB5C @note "Counts any intersection; does not check usability or ammunition."
    procedure ClearUnequippedWeaponTargets; // @addr 0x75AAD4
    procedure ClearWeaponTargets(Target: TObject); // @addr 0x75B2A0 @note "Nil clears every cached weapon target; otherwise clears only matches."
    function IsAttackingShip(Target: TShip): Boolean; // @addr 0x75B334 @note "Includes weapon targets, interceptor attribution and shock/acid source IDs; requires non-nil Target."
    function CanSafelyDetonateItem(Item: TItem): Boolean; // @addr 0x75BBFC @note "Rejects bomb/explosive cargo near non-hostile normal-space ships, including Self. Does not test shot range."
    function GetWeaponDamageSummary: WideString; // @addr 0x75ABBC
    function GetManeuverabilitySummary: WideString; // @addr 0x75AED0
    function GetRepairPointsSummary: WideString; // @addr 0x75AF6C
    function HasScannerArtefact(UnusedTarget: TShip): Boolean; // @addr 0x75AFF4 @note "Callers pass the target ship in EDX. This routine ignores it and only checks Self's active scanner artefact count."
    function GetWeaponActionRange(Weapon: TWeapon): Integer; // @addr 0x75B018 @note "Same result as GetWeaponRange in this binary."
    function HasNoUsableWeapons: Boolean; // @addr 0x77D904
    function GetWeaponRange(Weapon: TWeapon): Integer; // @addr 0x762A6C
    function GetWeaponSlotRange(SlotIndex: Integer): Integer; // @addr 0x75B03C @note "Weapon slots are numbered 1..5."
    function GetMaxWeaponRange: Integer; // @addr 0x75B234
    function ChanceToWin(Target: TShip): Double; // @addr 0x75B3CC @note "Returns a combat strength ratio, not a probability."
    function GetWinChancePercent(Target: TShip): TPercent; // @addr 0x75B92C
    function GetWeaponMinDamage(Weapon: TWeapon): Integer; // @addr 0x75B068
    function GetWeaponMaxDamage(Weapon: TWeapon): Integer; // @addr 0x75B0A4
    function GetAttackMultiplier: Integer; // @addr 0x75FE40
    procedure ReloadWeaponAmmo; // @addr 0x768CA4

    function CreateAndEquipHull(Capacity: Word; Level: Byte; Owner: TOwnerId; Series: Integer; PirateBuilt: Boolean): THull; // @addr 0x76AF14
    function CreateAndEquipFuelTanks(Weight: Integer; Level: Byte; Owner: TOwnerId): TFuelTanks; // @addr 0x76B010
    function CreateAndEquipEngine(Weight: Integer; Level: Byte; Owner: TOwnerId): TEngine; // @addr 0x76B06C
    function CreateAndEquipRadar(Weight: Integer; Level: Byte; Owner: TOwnerId): TRadar; // @addr 0x76B0C8
    function CreateAndEquipScanner(Weight: Integer; Level: Byte; Owner: TOwnerId): TScaner; // @addr 0x76B124
    function CreateAndEquipRepairRobot(Weight: Integer; Level: Byte; Owner: TOwnerId): TRepairRobot; // @addr 0x76B180
    function CreateAndEquipCargoHook(Weight: Integer; Level: Byte; Owner: TOwnerId): TCargoHook; // @addr 0x76B1DC
    function CreateAndEquipDefGenerator(Weight: Integer; Level: Byte; Owner: TOwnerId): TDefGenerator; // @addr 0x76B238
    function CreateAndEquipWeapon(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId): TWeapon; // @addr 0x76B294

    function GetEquipmentStatBonus(BonusKind: TEquipmentBonusKind; Item: TEquipment): Integer; // @addr 0x75F5C4
    function GetTotalStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x75F60C
    function GetOwnStatBonus(BonusKind: TEquipmentBonusKind): Integer; // @addr 0x77D998

    function CalculateHullArmor(Hull: THull): Integer; // @addr 0x762C3C
    function CalculateEngineSpeed(Engine: TEngine; ApplyBrokenPenalty: Boolean): Integer; // @addr 0x762D30
    function CalculateEngineJumpRange(Engine: TEngine): Integer; // @addr 0x762EA0
    function CalculateRadarRange(Radar: TRadar): Integer; // @addr 0x762FD8
    function CalculateScannerPower(Scanner: TScaner): Integer; // @addr 0x76308C
    function CalculateRepairPoints(RepairRobot: TRepairRobot): Integer; // @addr 0x763140
    function CalculateCargoHookPower(CargoHook: TCargoHook): Integer; // @addr 0x7631F4
    procedure AutoEquipInventory; // @addr 0x76616C
    function DropCarriedItemAsMovingLoot(Item: TItem): Boolean; // @addr 0x767388 @note "Requires membership in Inventory; honors ship/item NoDrop and rejects the hull. True means accepted, even if a script consumes the drop."
    function DropCarriedArtefactAsMovingLoot(Item: TArtefact): Boolean; // @addr 0x767414 @note "Requires membership in Artefacts; honors ship/item NoDrop."
    procedure DropGuaranteedDeathDropItems; // @addr 0x7674C0
    function CanDropTreasureMap: Boolean; // @addr 0x767544 @note "Deterministic eligibility roll for an ordinary pirate without a script binding or player partnership."
    function SelectTreasureMapPlanet: TPlanet; // @addr 0x7675C0 @note "Searches reachable uninhabited planets with accessible artefact/module loot; excludes maps already carried or stored by the player."
    function TryDropTreasureMap: Boolean; // @addr 0x767844
    function DropItemIntoStar(Item: TItem): Boolean; // @addr 0x7678CC @note "Player drops are placed immediately and may be consumed by scripts or stellar heat. Native artefact branch mistakenly deletes Inventory at the Artefacts index (0x7679AC); preserved here as observed behavior."
    procedure DropAllArtefactsOnDestruction; // @addr 0x767C70
    procedure DropGoodsIntoSpace(Good: Byte; Count: Integer); // @addr 0x767CBC @note "Caller supplies a valid good and quantity; does not itself honor ship NoDrop."
    function JettisonCargoGoodsTowardTargetValue(TargetValue: Integer): Boolean; // @addr 0x767D40
    procedure DropAllCargoGoods; // @addr 0x767EBC
    procedure QueueMovingItemDrop(Item: TItem; DeployTranclucator: Byte); // @addr 0x767F08 @note "Caller detaches Item first. Script action 33 can suppress transfer or free Item; otherwise the moving-drop descriptor takes ownership."
    function SelectLeastValuableInventoryItem: TItem; // @addr 0x768194 @note "Considers protection, essential equipment and value per mass; can return the hull when no alternative qualifies."
    function SelectLeastValuableArtefact: TArtefact; // @addr 0x768320 @note "Native scan starts at index one; an artefact list with one element yields nil."
    function SelectCheapestCargoGood: Byte; // @addr 0x7683FC @note "Returns 255 if no cargo qualifies."
    procedure LiquidateInventoryItem(Item: TItem); // @addr 0x768978 @note "Normally credits resale value and frees Item; eligible NPC node stacks instead feed DepositCarriedNodes and automatic training."
    procedure LiquidateArtefact(Item: TArtefact); // @addr 0x768AA0 @note "Removes and frees Item after crediting resale value."
    procedure ApplyCombatItemDegradation(BaseDurabilityDamage: Double); // @addr 0x768D00
    procedure ApplyArtefactUseDegradation(BaseDurabilityDamage: Double); // @addr 0x768F9C
    procedure ApplyAfterburnerItemDegradation; // @addr 0x769068
    function ApplyItemDegradation(Item: TEquipment; Kind: TItemDegradationKind; DurabilityDamage: Double): Boolean; // @addr 0x769100 @note "True only when the item becomes newly broken. Nil is accepted; script actions 36..39 can modify the damage."
    function CanGenerateMicroModuleForLoadout: Boolean; // @addr 0x7695FC
    function CanGenerateSpecialHullModule: Boolean; // @addr 0x769738 @note "True for the player or when the current hull already has a special module."
    procedure ImproveRandomEquipment(ResolveOverload: Boolean); // @addr 0x76976C
    procedure GenerateAndApplyMicroModule(Item: TEquipment; ResolveOverload: Boolean); // @addr 0x769B68 @note "Selects up to three qualifying candidates within 51 attempts, applies the best positive gain, then auto-equips. Nil Item is accepted."
    procedure GenerateExtraWeapon; // @addr 0x769CD0 @note "Adds a generated weapon, may improve/module it, then auto-equips and optimizes inventory."
    function NeedsMicroModule(ModuleIndexPlusOne: Integer): Boolean; // @addr 0x769F18 @note "Requires an installable target and no carried module of the same index."
    function GetSatelliteLimit: Integer; // @addr 0x76A044
    function IsEssentialInventoryItem(Item: TItem): Boolean; // @addr 0x76A080 @note "Includes protected/script-named items and indispensable installed equipment; nil is false."
    function IsOptionalUtilityEquipment(Item: TItem): Boolean; // @addr 0x76A130 @note "Radar/scanner, or cargo hook on a ship other than a ranger or pirate. Nil is false."

    procedure OptimizeInventory; // @addr 0x768578 @note "Can sell equipment, artefacts and excess cargo; outside a market, excess goods are refunded at their cost basis."
    function RepairHullAtLocation: Boolean; // @addr 0x768B0C @note "Returns whether AI should remain docked; false does not guarantee full repair. Does not charge Money."
    function NeedsEssentialEquipment: Boolean; // @addr 0x76A17C
    procedure RestoreEssentialEquipment; // @addr 0x76A1D4 @note "Can subsidize equipment purchases; does not guarantee success."
    procedure BuyEquipmentAtLocation(ForceGeneratedOffers: Boolean); // @addr 0x76A430
    function CalculateDefGeneratorFactor(DefGenerator: TDefGenerator): Single; // @addr 0x7632A8
    function GetRadarRange: Integer; // @addr 0x75F744
    function GetScannerPower: Integer; // @addr 0x75F7D8
    function CanResolveObjectWithScanner(Target: TObject): Boolean; // @addr 0x75F834 @note "Ignores radar range and Dominator scanner series; non-ship targets require only a usable scanner."
    function GetCargoHookRange: Integer; // @addr 0x75FD0C
    function GetCargoHookMinPullSpeed: Single; // @addr 0x75FB54
    function GetCargoHookMaxPullSpeed: Single; // @addr 0x75FC30
    function GetDefenseDamageFactor: Double; // @addr 0x75FDCC @note "1 means no damage reduction."
    procedure ApplyRepairDroidHealing; // @addr 0x75F8FC
    function GetHullIntegrityPercent: TPercent; // @addr 0x75EEC0 @note "Not clamped to 0..100."
    function GetArmor: Integer; // @addr 0x75EF04
    function GetJumpRange: Integer; // @addr 0x75F27C @note "Ignores fuel; broken engines retain 60% range."
    function GetFuelLimitedJumpRange: Integer; // @addr 0x75F1DC
    function GetCarriedItemWeight: Integer; // @addr 0x7607D0 @note "Excludes the hull."
    function CalculateMass: Integer; // @addr 0x75EC0C @note "Uses cached CargoFreeSpace; includes cargo, artefact and status modifiers."
    function CalculateEquippedMass(ItemForModule: TEquipment): Integer; // @addr 0x75ED40 @note "Excludes cargo and unequipped items. Uses the current hull, adding ItemForModule's micromodule mass bonus when supplied."
    function GetCargoFreeSpace: Integer; // @addr 0x76079C @note "Can be negative."
    function GetCarriedNodeCount: Integer; // @addr 0x750010
    function HasCargoGoods: Boolean; // @addr 0x74FFA0
    function CountCargoGoodsTypes: Byte; // @addr 0x74FFD8 @note "Counts positive cargo quantities."
    function FindCarriedItemById(Id: Cardinal): TItem; // @addr 0x7523C0 @note "Includes artefacts, guaranteed drops, stored Tranclucator inventories and station shop stock; result is borrowed."
    function CanRefuel: Boolean; // @addr 0x750134
    function GetFullRefuelCost: Integer; // @addr 0x75EFA8 @note "Zero without tanks. Uses current planet owner, or owner six off-planet; overfilled tanks can produce a negative cost."
    function GetJumpDestinationDistance: Integer; // @addr 0x75EF58 @note "Truncated map distance for a jump order; zero otherwise."
    function GetAfterburnerWear: Integer; // @addr 0x75F0FC @note "Uses engine owner and current turn; no engine gives one before artefact modifiers."
    function HasLooseNonScriptItemsOrGoods: Boolean; // @addr 0x760ED8
    function GetAverageCargoCost(Good: Byte): Double; // @addr 0x75D390 @note "Returns 0 for an empty cargo entry."
    function GetLocationGoodsEntry(Good: Byte): PGoodsTradePriceEntry; // @addr 0x75CBF4 @note "Result is borrowed; raises when no market is available."
    function ShopGoodsPurchasePrice(Good: Byte; Location: TObject): Integer; // @addr 0x75CEA0 @note "Location is a planet or station; nil selects the current trade context."
    function ShopGoodsSellPrice(Good: Byte; Location: TObject): Integer; // @addr 0x75D0E8 @note "Includes the Trading skill bonus. Location=nil selects the current trade context."
    procedure ConsumeCargoGoods(Good: Byte; Count: Integer); // @addr 0x75D3E0 @note "Count is not clamped; remaining cost basis uses the previous average price."
    procedure BuyGoodsFromLocation(Good: Byte; Count: Integer); // @addr 0x75DBA8 @note "Checks stock and cash, but not free cargo space or negative Count."
    procedure SellGoodsToLocation(Good: Byte; Count: Integer); // @addr 0x75D4F4 @note "Rejects Count above carried stock; does not reject a negative Count. Player trade losses offset later profit before trade experience is awarded."
    function IsCargoGoodIllegalOnCurrentPlanet(Good: Byte): Boolean; // @addr 0x75D45C

    function GetSlotCount(SlotKind: TShipSlotKind): Integer; // @addr 0x77411C
    function GetSlotCountForItemType(ItemType: TItemType): Integer; // @addr 0x774598
    // Slot indices are zero-based.
    function FindEquippedItemInSlot(ItemType: TItemType; SlotIndex: Integer): TEquipment; // @addr 0x774878
    function CountUnequippedItemsInSlot(SlotIndex: Integer): Integer; // @addr 0x7749E8
    function FindFreeUnequippedSlot: Integer; // @addr 0x774A60
    function HasScriptControl: Boolean; // @addr 0x77D8B4
    function HasScriptBindings: Boolean; // @addr 0x750910 @note "For the player, checks the script-binding list; for NPC ships, checks ScriptShip."
    function HasIndependentScriptFaction: Boolean; // @addr 0x77E758 @note "Requires a nonempty faction not beginning with SubFaction. The native substring result is used as Boolean, so absence also returns true."
    function HasNamedScriptFaction: Boolean; // @addr 0x77E7CC @note "Requires a nonempty faction other than the exact SubFactionFixedStanding marker."
    function GetScriptStandingOverrideMode: TScriptStandingOverrideMode; // @addr 0x77E854 @note "0 normal, 1 independent faction, 2 fixed standing. The SubFaction substring test accepts absence as mode one."

    function CountActiveArtefacts(ArtefactType: TItemType): Integer; // @addr 0x775AC8 @note "Uses custom SharedEffect types and excludes broken items. Activation exceptions can count some unequipped artefacts."
    function HasEquippedArtefactOfSameUseGroup(Item: TItem): Boolean; // @addr 0x775B8C @note "Uses custom SharedUse and ConfigBlockName. Includes Item itself if equipped, and does not exclude broken items."
    function CanBoostArtefact(ArtefactType: TItemType; Item: TEquipment; IgnoreArtefactAvailability: Boolean): Boolean; // @addr 0x775D0C @note "Item=nil checks cached installed equipment. A supplied item need not be equipped; eligible equipment types depend on ArtefactType."

    procedure AddPickupTarget(Item: TItem; Prioritize: Boolean); // @addr 0x76BD40 @note "Existing targets keep their position."
    procedure RemovePickupTarget(Item: TItem); // @addr 0x76BDB8
    procedure ClearPickupTargets; // @addr 0x76BE28
    function HasPickupTarget(Item: TItem): Boolean; // @addr 0x76C004
    function GetReservedPickupWeight: Integer; // @addr 0x76B888
    function CountOtherShipsTargetingItem(Item: TItem): Integer; // @addr 0x76C040
    procedure TogglePickupTargets(IgnoreRange: Boolean); // @addr 0x76BF30 @note "Adds missing eligible targets; removes eligible targets only if none were added."
    procedure QueueItemsWithinPickupRange; // @addr 0x76B3D4
    function IsItemInPickupRange(Item: TItem): Boolean; // @addr 0x76B8EC @note "Also checks hook eligibility."
    function GetCargoHookRangeSquared: Integer; // @addr 0x75FD78
    function GetBaseCargoHookPower: Integer; // @addr 0x75FD98 @note "Raw PickupPower; zero without a hook. Does not check usability."
    function GetDefensePercent: TPercent; // @addr 0x75FE18
    function IsMicroModuleRaciallyRestricted(ModuleIndex: Integer): Boolean; // @addr 0x75F2F8 @note "Zero-based template index; true means disallowed. Includes custom faction, Dominator series and pilot-race restrictions."
    procedure AddAward(AwardId: Byte); // @addr 0x75FE78 @note "Rejects ID 255 and appends without deduplication; stops when list count equals 255. Extends the visible prefix only when all previous awards were visible."
    function ShouldPickUpItem(Item: TItem): Boolean; // @addr 0x76B95C
    function CanReachItemBeforeOtherShips(Item: TItem): Boolean; // @addr 0x76C0C4 @note "Ties are allowed; requires positive speed."
    procedure AddRecentlyDroppedItem(Item: TItem); // @addr 0x76C394
    procedure ClearRecentlyDroppedItems; // @addr 0x76C364
    function IsRecentlyDroppedItem(Item: TItem): Boolean; // @addr 0x76C3F4

    function HasActiveDisease: Boolean; // @addr 0x77C23C
    function CountActiveDiseases: Integer; // @addr 0x77C288
    function HasPresentDisease: Boolean; // @addr 0x77C2D0
    function CountPresentDiseases: Integer; // @addr 0x77C31C
    function HasActiveStimulant: Boolean; // @addr 0x77C364
    function CountActiveStimulants: Integer; // @addr 0x77C3B0
    function CountPresentDiseasesAndActiveStimulants: Integer; // @addr 0x77C3F8
    function IsHealthEffectActive(Index: Integer): Boolean; // @addr 0x77C5A0 @note "Captain effect is active only when Progress equals 100."
    function HasRadiationSickness: Boolean; // @addr 0x77CA44
    function HasDiseaseFromCurrentPlanet: Boolean; // @addr 0x77C424
    function HasDiseaseFromCurrentDockedShip: Boolean; // @addr 0x77C4E8
    procedure SimulateNpcHealthEffects; // @addr 0x77C5D8
    procedure ClearCombatStatusEffects; // @addr 0x77DDC0 @note "Frees entries but keeps the list."
    function FindCombatStatusEffect(EffectType: TCombatStatusEffectType): Integer; // @addr 0x77DB28 @note "Returns the list index, or -1."
    procedure AddCombatStatusStrength(EffectType: TCombatStatusEffectType; Strength: Single; Source: TShip); // @addr 0x77DBA4 @note "Scales by hull and existing strength. Always replaces the source ID, including clearing it for nil Source; no sign validation."
    procedure ReduceCombatStatusStrength(EffectType: TCombatStatusEffectType; Amount: Single); // @addr 0x77DD24 @note "Removes only entries reduced below zero; exactly zero remains. Negative Amount increases strength."
    procedure DecayCombatStatusEffects; // @addr 0x77DE1C @note "Daily decay; exactly zero remains until a subsequent reduction."
    function GetShockStatusDecay(Strength: Single): Single; // @addr 0x77DF7C
    function GetAcidStatusDecay(UnusedStrength: Single): Single; // @addr 0x77E030
    function GetMagneticStatusDecay(Strength: Single): Single; // @addr 0x77E0F8
    function GetWeaponBlockStatusDecay(Strength: Single): Single; // @addr 0x77E160
    function GetDroidBlockStatusDecay(Strength: Single): Single; // @addr 0x77E184
    function GetBWBuffStatusDecay(Strength: Single): Single; // @addr 0x77E1A8
    function GetBWRepairDebuffStatusDecay(Strength: Single): Single; // @addr 0x77E1E0
    procedure ClearCombatStatusSourceReferences(Source: TShip); // @addr 0x77E218 @note "Requires non-nil Source; clears matching IDs without changing effect strengths."
    function GetCombatStatusStrength(EffectType: TCombatStatusEffectType): Single; // @addr 0x77E29C @note "Zero when absent."
    function GetCombatStatusSourceId(EffectType: TCombatStatusEffectType): Integer; // @addr 0x77E2E0 @note "Zero when absent or unattributed."
    function GetCombatStatusDescription(out Count: Integer; ShowStrength: Boolean): WideString; // @addr 0x77E43C @note "Includes rounded-positive shock, acid, magnetic, BW buff and custom status entries; omits transient blocking effects."

    function GetBaseSkillLevel(Skill: TPilotSkill): Byte; // @addr 0x77BA78
    function GetEffectiveSkillLevel(Skill: TPilotSkill; IgnoreStatusEffects: Boolean = False): TPilotSkillLevel; // @addr 0x77BAA0 @note "Clamps to 0..6; equipment bonuses still apply when status effects are ignored."
    function CalculateSpeed: Integer; virtual; // @addr 0x77CA70 @slot 0x4C @calls "0x75FF76"
    function CountUnequippedDominatorEquipment: Integer; // @addr 0x769FE0 @note "Skips inventory index 0."
    function TrainSkill(Skill: TPilotSkill): Boolean; // @addr 0x77B8C4
    procedure GainExperience(Amount: Integer; SourceKind: Byte); // @addr 0x77B558 @note "Source kind 0 bypasses diminishing returns."
    procedure DepositCarriedNodes; // @addr 0x77B7B4 @note "Deposits every carried stack and awards experience."
  end;

var
  SimulationContext: ShortInt = 0; // @addr $87C414  Suppresses duplicate Pirate Clan abduction effects during turn simulation.
  DamageScriptActionTypes: array[0..2] of Byte = (7, 8, 9); // @addr $87C418 Energy, splinter and missile hit callbacks.
  TradeGoodsSold: TGoods = nil; // @addr $87C41C Reused script-event payload for the goods leaving the ship.
  TradeGoodsCostBasis: TGoods = nil; // @addr $87C420 Reused payload for the purchased portion of the sale.
  DominatorShipSmallSizes: array[0..2, 0..7] of Integer = ((127, 110, 70, 60, 45, 40, 130, 40), (127, 110, 70, 60, 45, 40, 130, 40), (127, 110, 70, 60, 45, 40, 130, 40)); // @addr $87C424
  DominatorShipLargeSizes: array[0..2, 0..7] of Integer = ((127, 127, 100, 90, 65, 60, 160, 60), (127, 127, 100, 90, 65, 60, 160, 60), (127, 127, 100, 90, 65, 60, 160, 60)); // @addr $87C484
  RangerSmallSizes: array[TOwnerId] of Integer = (50, 50, 50, 50, 50, 50, 50, 50); // @addr $87C4E4
  RangerLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 80, 80, 80, 80, 80); // @addr $87C504
  TransportSmallSizes: array[3..5, TOwnerId] of Integer = ((50, 50, 50, 50, 50, 50, 50, 50), (50, 50, 50, 50, 50, 50, 50, 50), (50, 50, 50, 50, 50, 50, 50, 50)); // @addr $87C524
  TransportLargeSizes: array[3..5, TOwnerId] of Integer = ((90, 90, 90, 90, 90, 90, 90, 90), (90, 90, 90, 90, 90, 90, 90, 90), (90, 90, 90, 90, 90, 90, 90, 90)); // @addr $87C584
  PirateSmallSizes: array[TOwnerId] of Integer = (45, 45, 45, 55, 45, 45, 45, 45); // @addr $87C5E4
  PirateLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 90, 80, 80, 80, 80); // @addr $87C604
  PirateClanSmallSizes: array[TOwnerId] of Integer = (45, 45, 45, 55, 45, 45, 45, 45); // @addr $87C624
  PirateClanLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 90, 80, 80, 80, 80); // @addr $87C644
  WarriorSmallSizes: array[TOwnerId] of Integer = (45, 45, 45, 55, 45, 45, 45, 45); // @addr $87C664
  WarriorLargeSizes: array[TOwnerId] of Integer = (80, 80, 80, 80, 80, 80, 80, 80); // @addr $87C684
  BigWarriorSmallSizes: array[TOwnerId] of Integer = (80, 80, 80, 80, 80, 80, 80, 80); // @addr $87C6A4
  BigWarriorLargeSizes: array[TOwnerId] of Integer = (130, 130, 130, 130, 130, 130, 130, 130); // @addr $87C6C4
  TranclucatorSmallSize: Integer = 40; // @addr $87C6E4
  TranclucatorLargeSize: Integer = 50; // @addr $87C6E8
  SpecialHullSmallSize: Integer = 50; // @addr $87C6EC

var
  SpecialHullLargeSize: Integer = 80; // @addr $87C6F0
  StationSize: Integer = 128; // @addr $87C6F4
  DefaultShipSmallSize: Integer = 50; // @addr $87C6F8
  DefaultShipLargeSize: Integer = 80; // @addr $87C6FC
  SkillBonusEvaluationWeights: array[bonSkill1..bonSkill6] of Integer = (100, 100, 80, 80, 60, 60); // @addr $87C700 bonSkill1..bonSkill6.
  SlotBonusEvaluationWeights: array[bonSlotRadar..bonSlotForsage] of Integer = (100, 100, 200, 100, 200, 75, 10, 30); // @addr $87C718 bonSlotRadar..bonSlotForsage.

function CreateShipByType(ShipType: Byte): TShip; // @addr 0x75E500 @note "Allocates an unregistered instance; caller must initialize or deserialize it."

function CompareShipGroupsStrength(Ships, Opponents: TList): Single; // @addr 0x75E454 @note "Lists contain TShip. Sum of pairwise ChanceToWin divided by Opponents.Count squared; requires nonempty Opponents when Ships is nonempty."
function CalculateFuelCost(Amount: Integer; OwnerId: TOwnerId): Single; // @addr 0x75F034 @note "Owner six skips racial scaling. Uses active galaxy turn and difficulty."
function CalculateRoundedFuelCost(Amount: Integer; OwnerId: TOwnerId): Integer; // @addr 0x75F0D4

var
  KlingCheapDropValueFactors: array[0..7] of Double = (0.1, 0.85, 0.9, 1, 1.2, 1.5, 0.7, 4); // @addr $87C738 Indexed by KlingType.
  KlingValuableDropValueFactors: array[0..7] of Double = (0.1, 0.8, 0.9, 1, 2, 4, 0.7, 8); // @addr $87C778 Indexed by KlingType.

// Nested LookupTalkText helper; the native caller removes its unused static link.

const
  DominatorProgramDropCostFactors: array[0..7] of Double = (0.2, 1.6, 1.8, 2.0, 4.0, 8.0, 1.4, 16.0); // @addr $87C7B8 TKlingType order.

implementation

uses fShip2, aGalaxyEvent, fEquipmentShop, fGoodsShop2, ThreadCalc, EC_Mem, aEFilmEnd, SE_Weapon, fScore, SE_Ruins, Achievements, SE_GAIEffect, Dialogs, SE_Ship2, EC_Str, GR_Main, Globals, GlobalsV, Math, SysUtils, aConst, aKling, aMissile, aNormalShip, aPirate, aPlayer, aRanger, aRuins, aScript, aTranclucator, aTransport, aWarrior;

{ @routine $747D08 TShip_Create }
constructor TShip.Create;
var
  I: Integer;
  Kind: TItemType;
  Skill: TPilotSkill;
  Series: Byte;
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
  for Kind := t_Food to t_Narcotics do
  begin
    CargoGoods[Ord(Kind)].Count := 0;
    CargoGoods[Ord(Kind)].TotalCost := 0;
  end;
  // The contiguous Hull..DefGenerator fields are indexed by native item type.
  for Kind := Low(PShipEquipmentCacheView(Self).Slots) to High(PShipEquipmentCacheView(Self).Slots) do
    PShipEquipmentCacheView(Self).Slots[Kind] := nil;
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
  for I := 1 to 24 do
  begin
    CaptainHealth[I].Progress := 0;
    CaptainHealth[I].AppliedTurn := 0;
    CaptainHealth[I].ExpireTurn := 0;
    CaptainHealth[I].ApplicationCount := 0;
  end;
  for I := 1 to 1 do
  begin
    RadiationHealth[I].Progress := 0;
    RadiationHealth[I].AppliedTurn := 0;
    RadiationHealth[I].ExpireTurn := 0;
    RadiationHealth[I].ApplicationCount := 0;
  end;
  TechKnowledge := 0;
  CustomShipInfos := TList.Create;
  ChameleonActive := False;
  for Series := 0 to 2 do
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
{ @end $747D08 }

{ @routine $748168 TShip_Destroy }
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
  if (GetPlayer <> nil) and (GetPlayer.StorageEntries <> nil) and (TypeId <> stTranclucator) then
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
{ @end $748168 }

{ @routine $748800 TShip_SaveToBuffer }
procedure TShip.SaveToBuffer(Buffer: TBufEC);
var
  Good: Byte;
  Item: TItem;
  I, Count: Integer;
  Award: Byte;
  Skill: TPilotSkill;
  Series: Byte;
  SourceId: Cardinal;
  Info: PCustomShipInfo;
  Reserved: array[0..3] of Byte; // Native unreferenced slot before managed cleanup temporaries.
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
  if Order = soJump then Buffer.AddDWord((OrderTarget as TStar).Id)
  else if Order = soJumpHole then
  begin
    if OrderTarget <> nil then Buffer.AddDWord((OrderTarget as THole).Id)
    else
    begin
      Buffer.AddDWord(0);
      AppendDebugLogLine('Error [t_JumpHole]: Hole not found, id = ' + IntToStr(Cardinal(Id)) + ', Name = ' + Name);
    end;
  end
  else if Order = soTeleport then Buffer.AddDWord((OrderTarget as TStar).Id)
  else if Order = soLand then
  begin
    if OrderTarget is TShip then Buffer.AddDWord((OrderTarget as TShip).Id or OrderTargetShipFlag)
    else Buffer.AddDWord((OrderTarget as TPlanet).Id);
  end
  else if Order = soFollowShip then Buffer.AddDWord((OrderTarget as TShip).Id)
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
  for I := 1 to 24 do
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
  for Series := 0 to 2 do
  begin
    Buffer.AddBoolean(ChameleonDetected[Series]);
    Buffer.AddIntegerValue(ChameleonCharges[Series]);
  end;
  for I := 1 to 1 do
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
{ @end $748800 }

{ @routine $7496BC TShip_LoadFromBuffer }
procedure TShip.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  Good: Byte;
  Item: TItem;
  I, Count: Integer;
  Award: Byte;
  SavedPartner: TShip;
  Skill: TPilotSkill;
  Series: Byte;
  Bonus: PShipStatBonusEntry;
  Effect: PCombatStatusEffect;
  Info: PCustomShipInfo;
  Block: TBlockParEC;
begin
  Id := Buffer.GetUInt32;
  if Cardinal(Id) >= Cardinal(Galaxy.NextShipId) then Galaxy.NextShipId := Id + 1;
  Name := Buffer.ReadWideString;
  if LoadedSaveVersion >= 97 then TypeNameOverrideKey := Buffer.ReadWideString
  else TypeNameOverrideKey := '';
  TypeId := Buffer.GetByte;
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
  else if OwnerId = oiPirate then PilotRace := TOwnerId(Buffer.GetByte)
  else if OwnerId in [oiMaloc..oiGaal] then PilotRace := OwnerToRace(OwnerId)
  else PilotRace := oiMaloc;
  if LoadedSaveVersion < 102 then
  begin
    if TypeId = Byte(rstMedicalBase) then
    begin
      OwnerId := oiGaal;
      PilotRace := oiGaal;
      if PortraitFaceId > 14 then PortraitFaceId := -1;
    end;
    if TypeId = Byte(rstBusinessCenter) then
    begin
      OwnerId := oiHuman;
      PilotRace := oiHuman;
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
        Effect.EffectType := TCombatStatusEffectType(Buffer.GetByte);
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
      if Block = nil then
      begin
        AppendLogLineThreadSafe('Warning! Ship info ' + Info.TypeName + ' not found, deleting.');
        Dispose(Info);
      end
      else
      begin
        CustomShipInfos.Add(Info);
        Info.StatusEffect := Block.CountParams('StatusEffect') > 0;
      end;
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
  for I := 1 to 24 do
  begin
    CaptainHealth[I].Progress := Buffer.GetSingle;
    CaptainHealth[I].AppliedTurn := Buffer.GetInt32;
    CaptainHealth[I].ExpireTurn := Buffer.GetInt32;
    if LoadedSaveVersion >= 54 then CaptainHealth[I].ApplicationCount := Buffer.GetInt32
    else CaptainHealth[I].ApplicationCount := 0;
  end;
  LastProcessedTurn := Buffer.GetInt32;
  UnknownF4 := Buffer.GetInt32;
  ChameleonActive := Buffer.GetBoolean;
  ChameleonSeries := TDominatorSeries(Buffer.GetByte);
  ChameleonVisualType := Buffer.GetByte;
  ChameleonDisplayCount := Buffer.GetInt32;
  for Series := 0 to 2 do
  begin
    ChameleonDetected[Series] := Buffer.GetBoolean;
    ChameleonCharges[Series] := Buffer.GetInt32;
  end;
  for I := 1 to 1 do
  begin
    RadiationHealth[I].Progress := Buffer.GetSingle;
    RadiationHealth[I].AppliedTurn := Buffer.GetInt32;
    RadiationHealth[I].ExpireTurn := Buffer.GetInt32;
    if LoadedSaveVersion >= 54 then RadiationHealth[I].ApplicationCount := Buffer.GetInt32
    else RadiationHealth[I].ApplicationCount := 0;
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
    CurrentStanding := ssUnaligned;
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
{ @end $7496BC }

{ @routine $74AB50 TShip_SaveToBlock }
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
  Text := IntToStr(CargoGoods[Ord(t_Food)].Count);
  for I := 1 to 7 do Text := Text + ',' + IntToStr(CargoGoods[Byte(I)].Count);
  Block.AddParam(DecodeTextW('Gronordos'), Text); // 'Goods'
  Text := IntToStr(BaseSkills[psAccuracy]);
  for I := 1 to 5 do Text := Text + ',' + IntToStr(BaseSkills[TPilotSkill(I)]);
  Block.AddParam(DecodeTextW('SekaiAlalas'), Text); // 'Skills'
  Block.AddParam(DecodeTextW('Mnognoenyj'), IntToStr(Money)); // 'Money'
  Block.AddParam(DecodeTextW('Eoxepl'), IntToStr(TotalExperience)); // 'Exp'
  Block.AddParam(DecodeTextW('FarweyeAETxopa'), IntToStr(FreeExperience)); // 'FreeExp'
  HealthBlock := Block.AddBlockByPath(DecodeTextW('Hrenasletaha')); // 'Health'
  for I := 1 to 24 do
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
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      Item.SaveToBlock(AddBlockByPath(Text));
    end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
  with Block.AddBlockByPath(DecodeTextW('AsrotyseLeidsot')) do // 'ArtsList'
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      Item.SaveToBlock(AddBlockByPath(Text));
    end;
    AddParam(DecodeTextW('AsdediAmrot'), ''); // 'AddArt'
  end;
  with Block.AddBlockByPath(DecodeTextW('DarlokpuLainsata')) do // 'DropList'
  begin
    for I := 0 to GuaranteedDeathDropItems.Count - 1 do
    begin
      Item := GuaranteedDeathDropItems[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      Item.SaveToBlock(AddBlockByPath(Text));
    end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
  if RangerRelations.Count > 0 then
    Block.AddParam(DecodeTextW('Rpe7lyamtgi4oendThokP4lWasyfeKry'), IntToStr(Byte(RangerRelations[0]))); // 'RelationToPlayer'
  Text := DecodeTextW('CrolnatariaOcitaeAddTrogSaheiOppIld'); // 'ContractedToShipId'
  if PartnerShip <> nil then Block.AddParam(Text, IntToStr(Cardinal(PartnerShip.Id)))
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
{ @end $74AB50 }

{ @routine $74BD2C TShip_LoadFromBlock }
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
  for I := 0 to 7 do CargoGoods[Byte(I)].Count := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  Text := Block.GetParam(DecodeTextW('SekaiAlalas')); // 'Skills'
  for I := 0 to 5 do BaseSkills[TPilotSkill(I)] := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  SetMoney(StrToInt(Block.GetParam(DecodeTextW('Mnognoenyj')))); // 'Money'
  TotalExperience := StrToInt(Block.GetParam(DecodeTextW('Eoxepl'))); // 'Exp'
  FreeExperience := StrToInt(Block.GetParam(DecodeTextW('FarweyeAETxopa'))); // 'FreeExp'
  with Block.GetBlockByPath(DecodeTextW('Hrenasletaha')) do // 'Health'
  begin
    for I := 1 to 24 do
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
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      Item.LoadFromBlock(GetBlockByPath(Text));
    end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      for ItemType := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[ItemType] = Part then
        begin
          if (ItemType in [t_Hull..t_Satellite]) and (ItemType <> t_Hull) then
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
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      Item.LoadFromBlock(GetBlockByPath(Text));
    end;
    Text := GetParam(DecodeTextW('AsdediAmrot')); // 'AddArt'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      for ItemType := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[ItemType] = Part then
        begin
          if (ItemTypeNames[ItemType] = Part) and (ItemType in [t_ArtefactHull..t_ArtFastRacks]) then
            Artefacts.Add(CreateConfiguredArtefactByItemType(ItemType, oiUninhabited));
          Break;
        end;
    end;
  end;
  with Block.GetBlockByPath(DecodeTextW('DarlokpuLainsata')) do // 'DropList'
  begin
    for I := 0 to GuaranteedDeathDropItems.Count - 1 do
    begin
      Item := GuaranteedDeathDropItems[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      Item.LoadFromBlock(GetBlockByPath(Text));
    end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, I, ',');
      for ItemType := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[ItemType] = Part then
        begin
          if ((ItemType in [t_Food..t_Narcotics]) or (ItemType in [t_Hull..t_CustomWeapon]) or (ItemType in [t_ArtefactHull..t_ArtFastRacks]) or (ItemType in [t_Protoplasm..t_Satellite])) and (ItemType <> t_Hull) then
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
  else PartnerShip := Galaxy.IdToShip(StrToInt(Text), True);
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
{ @end $74BD2C }

{ @routine $74D484 TShip_ResolveLoadedReferences }
procedure TShip.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  I, Count: Integer;
  Item: TItem;
begin
  Galaxy.LoadedShips.Add(Self);
  TransitOriginStar := TObject(Galaxy.IdToStar(Cardinal(TransitOriginStar))) as TStar;
  CurrentPlanet := TObject(Galaxy.IdToPlanet(Cardinal(CurrentPlanet))) as TPlanet;
  if (Self is TPlayer) and ((Self as TPlayer).RuinsMode > 0) then
    DockedTo := (Self as TPlayer).RuinsProxy
  else DockedTo := TObject(Galaxy.IdToShip(Cardinal(DockedTo), True)) as TShip;
  HomePlanet := TObject(Galaxy.IdToPlanet(Cardinal(HomePlanet))) as TPlanet;
  if (LoadedSaveVersion < 146) and (HomePlanet <> nil) then
    TechKnowledge := Max(TechKnowledge, HomePlanet.InventionLevels[7]);
  if PickupTargets <> nil then
  begin
    Count := PickupTargets.Count;
    for I := 0 to Count - 1 do
      PickupTargets[I] := TObject(Galaxy.IdToItem(Cardinal(PickupTargets[I]), True)) as TItem;
  end;
  EnemyShip := TObject(Galaxy.IdToShip(Cardinal(EnemyShip), False)) as TShip;
  TruceShip := TObject(Galaxy.IdToShip(Cardinal(TruceShip), False)) as TShip;
  PartnerShip := TObject(Galaxy.IdToShip(Cardinal(PartnerShip), False)) as TShip;
  InterceptorSourceShip := TObject(Galaxy.IdToShip(Cardinal(InterceptorSourceShip), False)) as TShip;
  if Order = soJump then OrderTarget := TObject(Galaxy.IdToStar(Cardinal(OrderTarget))) as TStar
  else if Order = soJumpHole then OrderTarget := TObject(Galaxy.IdToHole(Cardinal(OrderTarget))) as THole
  else if Order = soTeleport then OrderTarget := TObject(Galaxy.IdToStar(Cardinal(OrderTarget))) as TStar
  else if Order = soLand then
  begin
    if (Cardinal(OrderTarget) and OrderTargetShipFlag) = OrderTargetShipFlag then
      OrderTarget := TObject(Galaxy.IdToShip(Cardinal(OrderTarget) and TaggedObjectIdMask, True)) as TShip
    else OrderTarget := TObject(Galaxy.IdToPlanet(Cardinal(OrderTarget))) as TPlanet;
  end
  else if Order = soFollowShip then OrderTarget := TObject(Galaxy.IdToShip(Cardinal(OrderTarget), True)) as TShip;
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
  if (LoadedSaveVersion < 85) and (TypeId <> stTranclucator) then RefreshCurrentStanding;
  if (LoadedSaveVersion in [92, 93]) and (Self is TNormalShip) and not (Self is TPlayer) then
  begin
    // Preserve the native legacy portrait exception, including its repeated type test.
    if (PilotRace = oiHuman) and (PortraitFaceId in [25..32]) and (GetPlayer <> Self) and
       (GetPlayer <> nil) and (Self is TNormalShip) then Exit;
    if (Self is TPirate) and (OwnerId = oiPirate) then GetHull.OwnerId := RaceToOwner(PilotRace)
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
{ @end $74D484 }

{ @routine $74DAA8 TShip_ClearObjectReferences }
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
{ @end $74DAA8 }

{ @routine $74DC04 TShip_SetMoney }
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
{ @end $74DC04 }

{ @routine $74DCD4 TShip_ProcessBrokenFuelTankLeak }
procedure TShip.ProcessBrokenFuelTankLeak;
var
  Lost: Integer;
  Roll: Double;
begin
  if (GetFuelTanks = nil) or (GetFuelTanks.BrokenFlag = 0) or (CountActiveArtefacts(t_ArtefactFuel) > 0) then Exit;
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
    AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn, LocalizedText('Items.FuelTanks.LostFuel'), '').Targets[0].ShipId := Id;
  end;
  if (GetPlayer = Self) and InNormalSpace and (Order = soJump) then
    if GetFuelTanks.Fuel < Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
    begin
      AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn,
        FormatText1(LocalizedText('Items.FuelTanks.NoFuelJump'),
          '<color=255,240,100>', '<Star>', (OrderTarget as TStar).Name), '').Targets[0].ShipId := Id;
      OrderMove(OrderDestination, False);
    end;
end;
{ @end $74DCD4 }

{ @routine $74DFF4 TShip_RefreshTechKnowledgeAtLocation }
procedure TShip.RefreshTechKnowledgeAtLocation;
var
  UseList, RepairList: TList;
  I: Integer;
  Item: TEquipment;
  Text: WideString;
begin
  if not (((DockedTo <> nil) and (DockedTo is TRuins)) or
    ((CurrentPlanet <> nil) and (CurrentPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) and (Ord(CurrentPlanet.GetRelationLevelToShip(Self)) <> 0)) or (Self is TRuins)) then Exit;
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
    AddOrUpdatePlayerBubble(pmShipPositive, Galaxy.CurrentTurn, Text, '');
  end;
  if RepairList.Count > 0 then
  begin
    Text := LocalizedText('Items.Equpments.NowCanRepair');
    for I := 0 to RepairList.Count - 1 do
    begin
      Item := RepairList[I];
      Text := Text + #13#10 + '- ' + Item.GetDisplayName;
    end;
    AddOrUpdatePlayerBubble(pmShipPositive, Galaxy.CurrentTurn, Text, '');
  end;
  UseList.Free;
  RepairList.Free;
  GetPlayer.RefreshStorageBubbles;
end;
{ @end $74DFF4 }

{ @routine $74E3E8 TShip_NextDay }
procedure TShip.NextDay;
{ Entire routine is ordinary Pascal, including its exception handler.
  Stage is the native diagnostic checkpoint, not reconstruction scaffolding. }
var
  I: Integer;
  WearFactor: Single;
  Kling: TKling;
  Stage: Integer;
begin
  Stage := 0;
  try
    if EnemyShip = Self then EnemyShip := nil;
    if Order = soFollowShip then
      if GetRelationLevelToShip(TShip(OrderTarget)) > rlHostile then
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
         not ((GetPlayer = Self) and (GlobalsV.CurrentScreenId = screenPlanetQuest)) then
        Inc(ConsecutiveDockedDays)
      else
        ConsecutiveDockedDays := 0;
      Inc(DaysSincePlayerSeen);
      LastProcessedTurn := aGalaxy.Galaxy.CurrentTurn;
      SimulateNpcHealthEffects;
      Stage := 3;
      if (GetPlayer <> Self) and (TypeId <> stTranclucator) then
      begin
        AutoEquipInventory;
        AutoEquipArtefacts;
        if InNormalSpace then DropCargoUntilNotOverloaded;
        if not (Self is TRuins) and (DaysSincePlayerSeen > 100) and
           ((aGalaxy.Galaxy.CurrentTurn + Id) mod 50 = 0) then ReloadWeaponAmmo;
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
              (aConst.FuelArtefactBase + aConst.FuelArtefactBoost * Ord(CanBoostArtefact(t_ArtefactFuel, nil, False))) * CountActiveArtefacts(t_ArtefactFuel),
              GetFuelTanks.Capacity - GetFuelTanks.Fuel));
        if (GetEngine <> nil) and (GetEngine.OutputPercent < 100) then
          Inc(GetEngine.OutputPercent, Min(
            (aConst.EngineArtefactBase + aConst.EngineArtefactBoost * Ord(CanBoostArtefact(t_ArtefactPower, GetEngine, False))) * CountActiveArtefacts(t_ArtefactPower),
            100 - GetEngine.OutputPercent));
        for I := 1 to CountActiveArtefacts(t_ArtefactNano) do ApplyNanoArtefactRepair;
        RefreshDerivedStats(True);
      end;
      Stage := 8;
      if GetPlayer = Self then
      begin
        if InNormalSpace then
        begin
          Stage := 9;
          if IsHealthEffectActive(10) then WearFactor := 3 else WearFactor := 1;
          if Order in [soMove,soLand,soJump,soTakeoff,soFollowShip] then
          begin
            ApplyItemDegradation(GetEngine, idkUse,
              NextRandomUnitFloat(RandomState) * 0.5 *
              RemapClamped(CalculateMass, aConst.WearMassMin, aConst.WearMassMax, 1, 10) * WearFactor);
            ApplyItemDegradation(GetFuelTanks, idkUse, NextRandomUnitFloat(RandomState) * 0.5 * WearFactor);
            if GetEngine <> nil then
              if GetEngine.BrokenFlag <> 0 then
                if Order = soJump then
                  if GetFuelLimitedJumpRange < System.Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
                  begin
                    AddOrUpdatePlayerBubble(pmShipNegative, aGalaxy.Galaxy.CurrentTurn, FormatText1(LocalizedText('Items.Engine.NoPowerJump'), '<color=255,240,100>', '<Star>', (OrderTarget as TStar).Name), '').Targets[0].ShipId := Id;
                    OrderMove(OrderDestination, False);
                  end;
          end;
          if GetRadar <> nil then
            ApplyItemDegradation(GetRadar, idkUse, NextRandomUnitFloat(RandomState) * 0.3 * WearFactor);
          if GetScanner <> nil then
            ApplyItemDegradation(GetScanner, idkUse, NextRandomUnitFloat(RandomState) * 0.3 * WearFactor);
          if GetDefGenerator <> nil then
            ApplyItemDegradation(GetDefGenerator, idkUse, NextRandomUnitFloat(RandomState) * 0.3 * WearFactor);
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
        if (TypeId in [stRanger,stTransport,stPirate]) and (CalculateMass > aConst.WearMassMin) and (Order <> soNone) then
          ApplyItemDegradation(GetEngine, idkUse,
            NextRandomUnitFloat(RandomState) * 0.5 *
            RemapClamped(CalculateMass, aConst.WearMassMin, aConst.WearMassMax, 0, 9) * 0.5);
        if AfterburnerActive then
        begin
          AfterburnerActive := False;
          if Self is TTranclucator then
            AfterburnerActive := (GetSlotCount(sskAfterburner) > 0) and (GetEngine <> nil) and
              (GetEngine.ConditionPercent > 10) and (EstimateOrderTravelTurns > 1);
        end;
        if (Self is TKling) and ((Self as TKling).ActiveProgramAppliedTurn > 0) then
        begin
          Stage := 12;
          Kling := Self as TKling;
          case Kling.ActiveProgramId of
            prgShipwreck: Kling.ActiveProgramAppliedTurn := 0;
            prgWeaponBlocking..prgShock:
              if aGalaxy.Galaxy.CurrentTurn - aConst.ProgramDuration[Kling.ActiveProgramId] > Kling.ActiveProgramAppliedTurn then
                Kling.ActiveProgramAppliedTurn := 0;
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
{ @end $74E3E8 }

{ @routine $74F058 TShip_NextDayLogic }
procedure TShip.NextDayLogic;
begin

end;
{ @end $74F058 }

{ @routine $74F064 TShip_AssignWeaponTargetsInStar }
procedure TShip.AssignWeaponTargetsInStar;
var
  I: Integer;
begin
  for I := 1 to WeaponCount do Weapons[I].Target := nil;
end;
{ @end $74F064 }

{ @routine $74F0A4 TShip_DerivedStateCompatibilityHook }
procedure TShip.DerivedStateCompatibilityHook;
begin

end;
{ @end $74F0A4 }

{ @routine $74F0B0 TShip_GetTypeNameKey }
function TShip.GetTypeNameKey: WideString;
begin
  Result := ShipTypeNames[TypeId].Name;
end;
{ @end $74F0B0 }

{ @routine $74F0D8 TShip_GetLocalizedTypeName }
function TShip.GetLocalizedTypeName: WideString;
begin
  if TypeNameOverrideKey <> '' then
    Result := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey)
  else if (Self is TWarrior) and ((Self as TWarrior).WarriorType = wtFlagship) then
    Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey + 'Big')
  else Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey);
end;
{ @end $74F0D8 }

{ @routine $74F20C TShip_GetFactionNameKey }
function TShip.GetFactionNameKey: WideString;
begin
  if HasNamedScriptFaction then Result := TScriptShip(ScriptShip).StateText
  else if Self is TKling then Result := DominatorSeriesNames[Ord((Self as TKling).DominatorSeries)]
  else Result := OwnerInfo[OwnerId].InternalName;
end;
{ @end $74F20C }

{ @routine $74F294 TShip_GetDefaultHullType }
function TShip.GetDefaultHullType: Byte;
var
  Kind: Byte;
begin
  case TypeId of
    stKling: Kind := htKling;
    stRanger: Kind := htRanger;
    stTransport:
      case (Self as TTransport).TransportType of
        ttTransport: Kind := htTransport;
        ttLiner: Kind := htLiner;
        ttDiplomat: Kind := htDiplomat;
      else Kind := htRanger;
      end;
    stPirate: Kind := htPirate;
    stWarrior:
      case (Self as TWarrior).WarriorType of
        wtRegular: Kind := htWarrior;
        wtFlagship: Kind := htFlagship;
      else Kind := htWarrior;
      end;
    stTranclucator: Kind := htTranclucator;
    Ord(rstRangerCenter)..Ord(rstCustomStation): Kind := htStation;
  else Kind := htRanger;
  end;
  Result := Kind;
end;
{ @end $74F294 }

{ @routine $74F384 TShip_NextRandomInteger }
function TShip.NextRandomInteger(Minimum, Maximum: Integer): Integer;
begin
  Result := NextRandomIntRange(Minimum, Maximum, RandomState);
end;
{ @end $74F384 }

{ @routine $74F3B4 TShip_GetSpaceInfoText }
function TShip.GetSpaceInfoText: WideString;
begin
  Result := GetName;
  case Order of
    soLand:
      if OrderTarget is TPlanet then
        Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.LandingToPlanet'), '<Planet>', (OrderTarget as TPlanet).Name, '<color=255,240,100>')
      else if OrderTarget is TShip then
        Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.LandingToShip'), '<Ship>', (OrderTarget as TShip).Name, '<color=255,240,100>');
    soJump:
      Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.GoToStar'), '<Star>', (OrderTarget as TStar).Name, '<color=255,240,100>');
    soFollowShip:
      if (OrderTarget as TShip).CurrentPlanet = nil then
      begin
        if EnemyShip <> OrderTarget then
          Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.GoToShip'), '<Ship>', (OrderTarget as TShip).GetName, '<color=255,240,100>')
        else
          Result := Result + ' ' + ReplaceColoredToken(LookupLocalizedTextByKey('ShipInfo.Order.GoToShipBad'), '<Ship>', (OrderTarget as TShip).GetName, '<color=255,240,100>');
      end
      else Result := Result + ' ' + LookupLocalizedTextByKey('ShipInfo.Order.None');
    soMove:
      Result := Result + ' ' + LookupLocalizedTextByKey('ShipInfo.Order.Move');
  end;
  Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceSize'), '<color=255,240,100>', '<Size>', IntToStr(GetHull.Weight));
  if GetHull.Weight > GetHull.HullPoints then
    Result := Result + ' ' + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceDamageProc'), '<color=255,240,100>', '<Proc>', IntToStr(Trunc(100 - GetHull.HullPoints / (GetHull.Weight * 0.01))));
  Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceSpeed'), '<color=255,240,100>', '<Speed>', IntToStr(CalculateSpeed));
  Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceDefField'), '<color=255,240,100>', '<Proc>', IntToStr(GetDefensePercent));
  if GetPlayer <> Self then
  begin
    Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('ShipInfo.SpaceRelation'), '<color=255,240,100>', '<Type>', LowerCaseWideString(GetRelationLevelTextToShip(GetPlayer)));
    if GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0 then
      Result := Result + #13#10 + FormatText1(LookupLocalizedTextByKey('Artefacts.Analyzer.TextToRadar'), '<color=255,240,100>', '<ChanceToWin>', IntToStr(GetPlayer.GetWinChancePercent(Self)));
  end;
end;
{ @end $74F3B4 }

{ @routine $74FDD4 TShip_GetDesiredCargoFreeSpace }
function TShip.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $74FDD4 }

{ @routine $74FDEC TShip_IsHullDestroyed }
function TShip.IsHullDestroyed: Boolean;
begin
  Result := GetHull.HullPoints <= 0;
end;
{ @end $74FDEC }

{ @routine $74FE0C TShip_GetTurnSeedFraction }
function TShip.GetTurnSeedFraction(TurnOffset: Integer): Single;
begin
  Result := Frac(Integer(Seed) / (Galaxy.CurrentTurn + TurnOffset));
end;
{ @end $74FE0C }

{ @routine $74FE50 TShip_GetEstimatedMemoryUsage }
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
{ @end $74FE50 }

{ @routine $74FFA0 TShip_HasCargoGoods }
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
{ @end $74FFA0 }

{ @routine $74FFD8 TShip_CountCargoGoodsTypes }
function TShip.CountCargoGoodsTypes: Byte;
var
  Good: Byte;
begin
  Result := 0;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do if CargoGoods[Good].Count > 0 then Inc(Result);
end;
{ @end $74FFD8 }

{ @routine $750010 TShip_GetCarriedNodeCount }
function TShip.GetCarriedNodeCount: Integer;
var
  I: Integer;
  Item: TItem;
begin
  Result := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if Item.ItemType = t_Protoplasm then Inc(Result, Item.Weight);
  end;
end;
{ @end $750010 }

{ @routine $750070 TShip_HasLockedOrFollowOrder }
function TShip.HasLockedOrFollowOrder: Boolean;
begin
  if OrderAbsolute or (AbsoluteScriptOrder > 0) or (Order = soFollowShip) then Result := True
  else Result := False;
end;
{ @end $750070 }

{ @routine $7500B0 TShip_HasHullDamageOrBrokenEquippedItems }
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
{ @end $7500B0 }

{ @routine $750134 TShip_CanRefuel }
function TShip.CanRefuel: Boolean;
begin
  if GetFuelTanks <> nil then Result := GetFuelTanks.Fuel < GetFuelTanks.Capacity
  else Result := False;
end;
{ @end $750134 }

{ @routine $750178 TShip_LookupVisibleTalkText }
function TShip.LookupVisibleTalkText(const Path: WideString; OtherShip: TShip): WideString;
begin
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) then begin
    Result := LookupTalkText(Path);
    ReplaceTextToken(Result, '<TalkShip>', OtherShip.GetName, '<color=255,240,100>');
  end else Result := '';
end;
{ @end $750178 }

{ @routine $750258 TShip_UpdateBestRangerRelativeRatings }
procedure TShip.UpdateBestRangerRelativeRatings;
begin
  if Galaxy.MaxRangerWealth <> 0 then WealthInBestRanger := Wealth / Galaxy.MaxRangerWealth
  else WealthInBestRanger := 0;
  if Galaxy.BestRangerStrength <> 0 then StrengthInBestRanger := Strength / Galaxy.BestRangerStrength
  else StrengthInBestRanger := 0;
end;
{ @end $750258 }

{ @routine $7502E0 TShip_UpdateAverageRangerRelativeStrength }
procedure TShip.UpdateAverageRangerRelativeStrength;
begin
  StrengthInAverageRanger := Strength / Galaxy.AverageRangerStrength;
end;
{ @end $7502E0 }

{ @routine $750308 TShip_CalculateWealth }
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
    Item := TItem(Inventory[I]);
    Inc(Capital, Item.Cost);
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := TItem(Artefacts[I]);
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
{ @end $750308 }

{ @routine $75046C TShip_CalculateAttackStrength }
function TShip.CalculateAttackStrength: Double;
var
  I: Integer;
begin
  Result := 0.0000001;
  for I := 1 to WeaponCount do
    if IsEquipmentUsable(Weapons[I]) then
      Result := Result + RemapClamped(GetEffectiveSkillLevel(psAccuracy), 0, 6,
        (GetWeaponMaxDamage(Weapons[I]) + GetWeaponMinDamage(Weapons[I])) div 2,
        GetWeaponMaxDamage(Weapons[I])) * Weapons[I].GetAttackCount;
  if Self is TKling then
    case (Self as TKling).KlingType of
      ktBoss: Result := Result * 1.5;
      ktBertor: Result := Result + 400;
      ktKlig: Result := Result * 0.33;
    end;
  Result := Max(0.0000001, Result * (UsableWeaponCount + 7) * GetAttackMultiplier);
end;
{ @end $75046C }

{ @routine $750674 TShip_CalculateDefenseStrength }
function TShip.CalculateDefenseStrength: Double;
begin
  Result := GetHull.HullPoints / Max(0.01, GetHull.GetFragilityFactor([])) * (GetArmor + 5) / DefenseDamageFactor;
  if (Self is TKling) and ((Self as TKling).KlingType = ktKlig) then Result := Result * 3;
end;
{ @end $750674 }

{ @routine $750758 TShip_GetRepairStrengthFactor }
function TShip.GetRepairStrengthFactor: Double;
begin
  if (GetHullIntegrityPercent > 50) and IsEquipmentUsable(GetRepairRobot) then
    Result := GetRepairRobot.TechLevel + 5
  else Result := 5;
end;
{ @end $750758 }

{ @routine $7507B4 TShip_CalculateStrength }
function TShip.CalculateStrength: Double;
begin
  Result := CalculateAttackStrength * CalculateDefenseStrength * GetRepairStrengthFactor;
  Strength := Result;
  if (GetPlayer = Self) and (Galaxy <> nil) then Galaxy.RefreshRangerStrengthStats;
end;
{ @end $7507B4 }

{ @routine $750820 TShip_GetFullHullRelativeStrengthPercent }
function TShip.GetFullHullRelativeStrengthPercent: Byte;
var
  HullPoints: Integer;
begin
  HullPoints := GetHull.HullPoints;
  GetHull.HullPoints := GetHull.Weight;
  Result := Round(CalculateStrength * 100 / Galaxy.AverageRangerStrength);
  GetHull.HullPoints := HullPoints;
end;
{ @end $750820 }

{ @routine $750888 TShip_GetWealthScaledAmount }
function TShip.GetWealthScaledAmount(ScaleIndex: Byte): Integer;
var Value: Single;
begin
  Value := Round(Wealth * WealthDemandScales[ScaleIndex]);
  if Value < 5000 then Result := Round(Value)
  else Result := Round((Value - 5000) * 0.3 + 5000);
end;
{ @end $750888 }

{ @routine $750910 TShip_HasScriptBindings }
function TShip.HasScriptBindings: Boolean;
begin
  if Self is TPlayer then Result := TPlayer(Self).ScriptShipBindings.Count > 0
  else Result := ScriptShip <> nil;
end;
{ @end $750910 }

{ @routine $750954 TShip_GetShipPortraitImagePath }
function TShip.GetShipPortraitImagePath: WideString;
begin
  if Graphic is TShip2SE then Result := GameDataConfig.GetParamByPathOrMarker('SE.' + Graphic.GraphKey + '.2ImageP')
  else if Graphic is TRuinsSE then Result := (Graphic as TRuinsSE).StaticImagePath;
end;
{ @end $750954 }

{ @routine $750A40 TShip_GetCaptainPortraitResourceBase }
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
    if (Self as TKling).KlingType = ktBoss then
    begin
      if (Self as TKling).DominatorSeries = dsBlazer then Result := 'Bm.Captain.2BlazerB'
      else if (Self as TKling).DominatorSeries = dsKeller then Result := 'Bm.Captain.2KellerB'
      else if (Self as TKling).DominatorSeries = dsTerron then Result := 'Bm.Captain.2TerronB';
    end
    else
    begin
      if (Self as TKling).DominatorSeries = dsBlazer then Result := 'Bm.Captain.2BlazerN'
      else if (Self as TKling).DominatorSeries = dsKeller then Result := 'Bm.Captain.2KellerN'
      else if (Self as TKling).DominatorSeries = dsTerron then Result := 'Bm.Captain.2TerronN';
    end;
    Exit;
  end;
  Owner := RaceToOwner(PilotRace);
  if PortraitFaceId < 0 then
  begin
    if TypeId = stRanger then Role := 'R'
    else if TypeId = stWarrior then Role := 'W'
    else if TypeId = stPirate then Role := 'P'
    else if TypeId = stTransport then
    begin
      if (Self as TTransport).TransportType = ttTransport then Role := 'T'
      else if (Self as TTransport).TransportType = ttLiner then Role := 'L'
      else if (Self as TTransport).TransportType = ttDiplomat then Role := 'D'
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
        if (Ship.PilotRace <> Self.PilotRace) or (Ship.TypeId = stWarrior) then Continue;
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
{ @end $750A40 }

{ @routine $7515B4 TShip_HasPlayerChameleonCharges }
function TShip.HasPlayerChameleonCharges: Boolean;
var I: Byte;
begin
  Result := False;
  for I := 0 to 2 do
    if GetPlayer.ChameleonCharges[I] > 0 then begin Result := True; Exit; end;
end;
{ @end $7515B4 }

{ @routine $7515F0 TShip_SelectChameleonVisualType }
function TShip.SelectChameleonVisualType: Byte;
var HullSize, AverageSize: Integer; Distance, BestDistance: Double; Kind, BestKind: Byte;
begin
  HullSize := Round(GetHull.Weight / HullCapacityScale);
  BestDistance := -1;
  BestKind := Ord(ktKlig);
  for Kind := Low(DominatorShipDefinitions) to High(DominatorShipDefinitions) do
    if Kind <> Ord(ktBoss) then
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
{ @end $7515F0 }

{ @routine $7516E4 TShip_IsPlayerChameleonEffectiveAgainstSelf }
function TShip.IsPlayerChameleonEffectiveAgainstSelf: Boolean;
begin
  if not GetPlayer.ChameleonActive or (GetPlayer = Self) then begin Result := False; Exit; end;
  Result := (TypeId <> stPirate) and (GetPlayer <> PartnerShip) and
    not ((ScriptShip <> nil) and (TScriptShip(ScriptShip).Script.ScriptFileName = 'Script.PC_fem_rangers') and
      (TScriptShip(ScriptShip).GetGroup.Name = 'GroupFem'));
  Result := GetPlayer.ScriptItemsAct(satOnChameleonConfusion, Self, nil, Ord(Result)) <> 0;
  Result := ScriptItemsAct(satOnChameleonConfusion, nil, nil, Ord(Result)) <> 0;
end;
{ @end $7516E4 }

{ @routine $7517FC TShip_RefreshGraphic }
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
{ @end $7517FC }

{ @routine $75188C TShip_CreateNormalGraphic }
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
  else if GetHull.HullType = htSpecial then
  begin
    if IsFemaleHumanPilot and (TypeId = stRanger) and (GetHull.HullType = htSpecial) and (GetHull.GetSpecialKindGraph = 'J') then
      RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.AkrinFemale.' + GetHull.GetSpecialKindGraph, Classes.Point(0, 0)))
    else
      RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.Akrin.' + GetHull.GetSpecialKindGraph, Classes.Point(0, 0)));
    Graphic.SetAlpha(0);
  end
  else if not (Self is TNormalShip) then
  begin
    if Self is TKling then
    begin
      if (Self as TKling).KlingType = ktBoss then
      begin
        case (Self as TKling).DominatorSeries of
          dsBlazer: RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.Blazer', Classes.Point(0, 0)));
          dsKeller: RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.Keller', Classes.Point(0, 0)));
          dsTerron: RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ruins', 'Ruins.Terron', Classes.Point(0, 0)));
        end;
        CollisionRadius := 74;
        Graphic.SetAlpha(255);
      end
      else
      begin
        RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
        case (Self as TKling).DominatorSeries of
          dsBlazer: BlazerShipTemplates[Ord((Self as TKling).KlingType)].CopyTo(Graphic);
          dsKeller: KellerShipTemplates[Ord((Self as TKling).KlingType)].CopyTo(Graphic);
          dsTerron: TerronShipTemplates[Ord((Self as TKling).KlingType)].CopyTo(Graphic);
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
  else if (Self is TPirate) and (OwnerId = oiPirate) and (TPirate(Self).PirateType <> 0) then
  begin
    RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
    PirateClanShipTemplates[GetHull.OwnerId].CopyTo(Graphic);
    Graphic.SetAlpha(0);
  end
  else if (Self is TWarrior) and ((Self as TWarrior).WarriorType = wtFlagship) then
  begin
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[OwnerId].InternalName + '.WarriorBig', Classes.Point(0, 0)));
    Graphic.SetAlpha(0);
  end
  else if (TypeId = stRanger) and UsesVeteranHumanRangerAppearance then
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
{ @end $75188C }

{ @routine $752128 TShip_CreateDominatorGraphic }
procedure TShip.CreateDominatorGraphic;
var
  Series: TDominatorSeries;
  Kind: Byte;
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
    Divisor := (Id shr 1) mod Divisor;
    Kind := Byte(Divisor) + 1;
    Divisor := 3;
    Series := TDominatorSeries(Id mod Divisor);
  end;
  ReleaseSpaceObject(Graphic);
  RetainSpaceObject(Graphic, TShip2SE.CreateEmpty);
  case Series of
    dsBlazer: BlazerShipTemplates[Kind].CopyTo(Graphic);
    dsKeller: KellerShipTemplates[Kind].CopyTo(Graphic);
    dsTerron: TerronShipTemplates[Kind].CopyTo(Graphic);
  end;
  GraphName := Graphic.GraphKey;
  Graphic.SetPosition(Position);
  Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
  Graphic.SetAlpha(0);
  CollisionRadius := 32;
  GraphDominator := True;
  RefreshGraphicSize;
end;
{ @end $752128 }

{ @routine $7522FC TShip_TransferToStar }
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
{ @end $7522FC }

{ @routine $7523C0 TShip_FindCarriedItemById }
function TShip.FindCarriedItemById(Id: Cardinal): TItem;
var I, Count: Integer; Item: TItem; Station: TRuins;
begin
  Result := nil;
  Count := Inventory.Count;
  for I := 0 to Count - 1 do begin
    Item := Inventory[I];
    if Cardinal(Item.Id) = Id then begin Result := Item; Exit; end;
  end;
  Count := Artefacts.Count;
  for I := 0 to Count - 1 do begin
    Item := Artefacts[I];
    if Cardinal(Item.Id) = Id then begin Result := Item; Exit; end;
    if Item is TArtefactTranclucator then begin
      Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
      if Result <> nil then Exit;
    end;
  end;
  Count := GuaranteedDeathDropItems.Count;
  for I := 0 to Count - 1 do begin
    Item := GuaranteedDeathDropItems[I];
    if Cardinal(Item.Id) = Id then begin Result := Item; Exit; end;
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
      if Cardinal(Item.Id) = Id then begin Result := Item; Exit; end;
    end;
  end;
end;
{ @end $7523C0 }

{ @routine $7525B4 TShip_TryRelocateUnseenShip }
procedure TShip.TryRelocateUnseenShip;
var
  Candidate, Destination: TStar;
  I: Integer;
  Distance, BestDistance: Single;
  Planet: TPlanet;
begin
  if GetPlayer = nil then Exit;
  if GetPlayer.ShouldKeepShipForQuests(Self) then Exit;
  if GetPlayer = PartnerShip then Exit;
  if ScriptShip <> nil then Exit;
  if AbsoluteScriptOrder <> 0 then Exit;
  if DestroyQueued then Exit;
  if NextRandomUnitFloat(RandomState) < 0.002 then Exit;
  if DaysSincePlayerSeen < 20 then Exit;
  if (Galaxy.CountFactionStars(sfCoalition) * 2.5 < Galaxy.CountEligibleRangers) and
    (Self is TRanger) and ((Self as TRanger).PlaceInRating > 10) then Exit;
  if GetPlayer = Self then Exit;
  BestDistance := 1e20;
  Destination := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Candidate := Galaxy.Stars[I];
    if (Candidate <> CurrentStar) and (Candidate.ControlFaction = sfCoalition) and
      (Candidate.Status.CustomFaction = '') and (Candidate.Battle = 0) and (GetPlayer.CurrentStar <> Candidate) and
      (Candidate.ShipTypeCounts[stRanger] < 3) then
    begin
      Distance := PointDistanceSquared(CurrentStar.Position, Candidate.Position);
      if (Distance < BestDistance) and ((Destination = nil) or (NextRandomIntRange(0, 1, RandomState) = 0)) then
      begin
        BestDistance := Distance;
        Destination := Candidate;
      end;
    end;
  end;
  if Destination <> nil then
  begin
    Planet := nil;
    I := 0;
    while I < Destination.Planets.Count do
    begin
      Planet := Destination.Planets[I];
      if Planet.OwnerId in [oiMaloc..oiGaal, oiPirate] then Break;
      Planet := nil;
      Inc(I);
    end;
    if Planet <> nil then
    begin
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
  end;
end;
{ @end $7525B4 }

{ @routine $75293C TShip_SynchronizeDockedLocation }
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
{ @end $75293C }

{ @routine $7529F0 TShip_InNormalSpace }
function TShip.InNormalSpace: Boolean;
begin
  if (GetPlayer <> Self) or (GetPlayer.RuinsMode = 0) then
    Result := (CurrentStar <> nil) and (CurrentPlanet = nil) and (DockedTo = nil) and not InHyperspace
  else Result := (CurrentStar <> nil) and (GetPlayer.RuinsSavedPlanet = nil) and (GetPlayer.RuinsSavedDockedTo = nil);
end;
{ @end $7529F0 }

{ @routine $752A78 TShip_IsOutsideStarSpace }
function TShip.IsOutsideStarSpace: Boolean;
begin
  Result := (CurrentPlanet <> nil) or (DockedTo <> nil) or InHyperspace or (CurrentStar = nil) or
    ((GetPlayer = Self) and ((GetPlayer.RuinsSavedPlanet <> nil) or (GetPlayer.RuinsSavedDockedTo <> nil)));
end;
{ @end $752A78 }

{ @routine $752AE0 TShip_IsOnPlanet }
function TShip.IsOnPlanet: Boolean;
begin
  Result := CurrentPlanet <> nil;
end;
{ @end $752AE0 }

{ @routine $752AFC TShip_IsDockedToShip }
function TShip.IsDockedToShip: Boolean;
begin
  Result := DockedTo <> nil;
end;
{ @end $752AFC }

{ @routine $752B18 TShip_IsDocked }
function TShip.IsDocked: Boolean;
begin
  Result := (DockedTo <> nil) or (CurrentPlanet <> nil);
end;
{ @end $752B18 }

{ @routine $752B44 TShip_HasPositiveSpeed }
function TShip.HasPositiveSpeed: Boolean;
begin
  Result := Speed > 0;
end;
{ @end $752B44 }

{ @routine $752B8C TShip_CancelInvalidTravelOrder }
procedure TShip.CancelInvalidTravelOrder;
  // @nested $752B64 Cancel
  procedure Cancel; // @addr 0x752B64 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship at ParentFrame-4."
  begin
    if GetPlayer = Self then PendingPlayerFollowTarget := nil;
    OrderNone(False);
  end;
begin
  if IsOutsideStarSpace then Exit;
  if (OrderTarget is TShip) and ((OrderTarget as TShip).CurrentStar <> CurrentStar) then
    Cancel;
  if (GetEngine = nil) or (GetFuelTanks = nil) then Cancel;
  if (CalculateSpeed <= 0) and (Order <> soTeleport) then Cancel;
end;
{ @end $752B8C }

{ @routine $752C20 TShip_ClearPlanetQueue }
procedure TShip.ClearPlanetQueue;
begin
  if PlanetQueue <> nil then
  begin
    PlanetQueue.Free;
    PlanetQueue := nil;
  end;
end;
{ @end $752C20 }

{ @routine $752C50 TShip_SelectNearestQueuedPlanet }
function TShip.SelectNearestQueuedPlanet: TPlanet;
var Planet: TPlanet; I: Integer; BestDistance, Distance: Double;
begin
  Result := nil;
  if PlanetQueue.Count <> 0 then begin
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
end;
{ @end $752C50 }

{ @routine $752D3C TShip_FindNearestDockableStation }
function TShip.FindNearestDockableStation(StandingMask: TShipStandings): TShip;
var I: Integer; Ship: TShip; BestDistance, Distance: Double;
begin
  Result := nil;
  BestDistance := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := TShip(CurrentStar.Ships[I]);
    if (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and ((StandingMask = []) or
      (Ship.CurrentStanding in StandingMask)) and Ship.CanDock(Self) then begin
      Distance := PointDistanceSquared(Position, Ship.Position);
      if (Distance < BestDistance) or (Result = nil) then begin Result := Ship; BestDistance := Distance; end;
    end;
  end;
end;
{ @end $752D3C }

{ @routine $752E1C TShip_FindFirstInhabitedPlanetInStar }
function TShip.FindFirstInhabitedPlanetInStar: TPlanet;
var I: Integer;
begin
  Result := TPlanet(CurrentStar.Planets[0]);
  if Result.OwnerId = oiUninhabited then
    for I := 1 to CurrentStar.Planets.Count - 1 do begin
      Result := TPlanet(CurrentStar.Planets[I]);
      if Result.OwnerId <> oiUninhabited then Break;
    end;
end;
{ @end $752E1C }

{ @routine $752E88 TShip_NavigateToQueuedPlanet }
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
{ @end $752E88 }

{ @routine $752F18 TShip_NavigateToEscapePlanet }
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
{ @end $752F18 }

{ @routine $752FFC TShip_TryMirrorPartnerTravelOrders }
function TShip.TryMirrorPartnerTravelOrders: Boolean;
var Star: TStar;
begin
  if Cardinal((PartnerShip as TRanger).PrisonTermRemaining) > 0 then begin Result := False; Exit; end;
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
      if (PartnerShip.OrderTarget is TShip) and (PartnerShip.Order = soLand) and (PartnerShip.EstimateOrderTravelTurns < 5) and
        (not OrderAbsolute or (OrderTarget = PartnerShip)) and TShip(PartnerShip.OrderTarget).CanDock(Self) then begin
        OrderLanding(PartnerShip.OrderTarget, CanRefuel or (OrderTarget = PartnerShip)); Result := True; Exit;
      end;
      if (PartnerShip.Order = soFollowShip) and (PartnerShip.EstimateOrderTravelTurns < 3) and not OrderAbsolute then begin
        OrderFollowShip(PartnerShip.OrderTarget as TShip, 0, False); Result := True; Exit;
      end;
      if (PartnerShip.OrderTarget is TStar) and CanRefuel then begin
        if Self is TPirate then (Self as TPirate).SelectNearestReachableDestination
        else if Self is TRanger then (Self as TRanger).SelectNearestReachableDestination;
        Result := False;
        Exit;
      end else begin
        if OrderTarget = PartnerShip then begin Result := True; Exit; end;
        OrderFollowShip(PartnerShip, 0, False);
        Result := True;
        Exit;
      end;
    end else begin
      if PartnerShip.CurrentPlanet <> nil then begin
        if CanQueueReachablePlanet(PartnerShip.CurrentPlanet) then begin OrderLanding(PartnerShip.CurrentPlanet, True); Result := True; Exit; end;
      end else if (PartnerShip.DockedTo <> nil) and (PartnerShip.DockedTo is TRuins) and
        (PartnerShip.DockedTo as TRuins).CanDock(Self) then begin OrderLanding(PartnerShip.DockedTo, False); Result := True; Exit; end;
    end;
  end else begin
    if PartnerShip.OrderTarget is TStar then Star := PartnerShip.OrderTarget as TStar else Star := nil;
    if (Star <> nil) and (((Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '')) or
      (GetFuelTanks.Fuel div 2 >= PointDistance(CurrentStar.Position, Star.Position))) then begin
      if (Star <> CurrentStar) and
        (((JumpRange * JumpRange) >= PointDistanceSquared(CurrentStar.Position, Star.Position)) or (GetFuelTanks.Fuel = GetFuelTanks.Capacity)) and
        (not (Self is TPirate) or ((Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = ''))) then begin
        OrderJump(Star, True);
        Result := True;
        Exit;
      end;
    end else begin
      Star := PartnerShip.CurrentStar;
      if (((JumpRange * JumpRange) >= PointDistanceSquared(CurrentStar.Position, Star.Position)) or (GetFuelTanks.Fuel = GetFuelTanks.Capacity)) and
        (((Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '')) or
          (GetFuelTanks.Fuel div 2 >= PointDistance(CurrentStar.Position, Star.Position))) and
        (not (Self is TPirate) or ((Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = ''))) then begin
        OrderJump(Star, True);
        Result := True;
        Exit;
      end;
    end;
  end;
  Result := False;
end;
{ @end $752FFC }

{ @routine $75367C TShip_OrderRandomFreeFlightMove }
procedure TShip.OrderRandomFreeFlightMove;
var
  Polar: TPolarPoint;
begin
  Polar.Radius := NextRandomIntRange(CurrentStar.SystemRadius + 300, CurrentStar.ComputeMapDiameter, RandomState);
  Polar.AngleDegrees := NextRandomUnitFloat(RandomState) * 360;
  OrderMove(PolarToPoint(Polar), False);
end;
{ @end $75367C }

{ @routine $7536F0 TShip_IsTargetStillPursuable }
function TShip.IsTargetStillPursuable(Target: TShip): Boolean;
begin
  if (Target.Order <> soJump) or (PointDistance(Position, Target.Position) < Speed * 2) then Result := True
  else Result := False;
end;
{ @end $7536F0 }

{ @routine $753744 TShip_CanEscapePursuer }
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
  if Order = soLand then begin
    if OrderTarget is TShip then begin
      if PointDistance((OrderTarget as TShip).Position, Position) / (Speed + 1) > 3 then begin Result := False; Exit; end;
    end else if PointDistance((OrderTarget as TPlanet).GetPosition, Position) / (Speed + 1) > 3 then begin Result := False; Exit; end;
  end else if (Pursuer.Order = soJump) and (PointDistance(OrderDestination, Position) / (Speed + 1) > 6) then begin Result := False; Exit; end;
end;
{ @end $753744 }

{ @routine $7539DC TShip_HasLandablePlanetInStar }
function TShip.HasLandablePlanetInStar(Star: TStar): Boolean;
var I: Integer; Planet: TPlanet;
begin
  for I := 0 to Star.Planets.Count - 1 do begin
    Planet := TPlanet(Star.Planets[I]);
    if (Planet.OwnerId <> oiUninhabited) and CanQueueReachablePlanet(Planet) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7539DC }

{ @routine $753A44 TShip_GetFullFuelBaseJumpRange }
function TShip.GetFullFuelBaseJumpRange: Integer;
begin
  Result := Min(GetFuelTanks.Capacity, GetEngine.JumpRange);
end;
{ @end $753A44 }

{ @routine $753A90 TShip_FindNextStarTowardDestination }
function TShip.FindNextStarTowardDestination(Destination: TStar; RequireFuelMargin: Boolean): TStar;
const CoalitionShips = [stRanger..stTranclucator];
var I, J, K, RangeSquared, CapacitySquared: Integer; Origin, Star: TStar; Predecessors: TList; Previous: Integer;
begin
  Predecessors := TList.Create;
  Predecessors.Add(nil);
  for I := 1 to Galaxy.Stars.Count - 1 do Predecessors.Add(Pointer(-1));
  RangeSquared := GetFullFuelBaseJumpRange * GetFullFuelBaseJumpRange;
  CapacitySquared := GetFuelTanks.Capacity * GetFuelTanks.Capacity;
  for I := 0 to Galaxy.Stars.Count - 2 do begin
    Origin := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (Origin.Constellation.Id = 20) or (Integer(Predecessors[I]) = -1) then Continue;
    for J := 1 to Galaxy.Stars.Count - 1 do begin
      Star := TObject(Origin.StarDistances[J].Star) as TStar;
      if Star.Constellation.Id = 20 then Continue;
      if (RangeSquared < PointDistanceSquared(Origin.Position, Star.Position)) or
        (RequireFuelMargin and (CapacitySquared < PointDistanceSquared(Origin.Position, Star.Position) * 2)) then Break;
      if Star = Destination then begin
        Previous := Integer(Predecessors[I]);
        Result := Origin;
        while Previous > 1 do begin
          Result := TObject(CurrentStar.StarDistances[Previous - 1].Star) as TStar;
          Previous := Integer(Predecessors[Previous - 1]);
        end;
        Predecessors.Free;
        Exit;
      end;
      if HasLandablePlanetInStar(Star) and (Star.CountShipsByTypeMask(CoalitionShips) <= 20) and (Star.ShipTypeCounts[stRanger] <= 9) then
        for K := 1 to Galaxy.Stars.Count - 1 do
          if (TObject(CurrentStar.StarDistances[K].Star) as TStar) = Star then begin
            if Integer(Predecessors[K]) = -1 then Predecessors[K] := Pointer(I + 1);
            Break;
          end;
    end;
  end;
  Result := nil;
  Predecessors.Free;
end;
{ @end $753A90 }

{ @routine $753D58 TShip_DistanceToNearestShipByTypeMask }
function TShip.DistanceToNearestShipByTypeMask(ShipTypeMask: TShipTypeMask): Double;
var I: Integer; Ship: TShip; BestDistance, Distance: Single;
begin
  BestDistance := 1000000000;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := TShip(CurrentStar.Ships[I]);
    if (Ship.TypeId in ShipTypeMask) and (Ship <> Self) then begin
      Distance := PointDistanceSquared(Position, Ship.Position);
      if Distance < BestDistance then BestDistance := Distance;
    end;
  end;
  Result := Sqrt(BestDistance);
end;
{ @end $753D58 }

{ @routine $753E00 TShip_EstimateOrderTravelTurns }
function TShip.EstimateOrderTravelTurns: Integer;
begin
  case Order of
    soMove: Result := Round(PointDistance(OrderDestination, Position) / (Speed + 1)) + 1;
    soLand:
      if OrderTarget is TPlanet then
        Result := Round(PointDistance((OrderTarget as TPlanet).GetPosition, Position) / (Speed + 1)) + 1
      else Result := Round(PointDistance((OrderTarget as TShip).Position, Position) / (Speed + 1)) + 1;
    soJump: Result := Round(PointDistance(OrderDestination, Position) / (Speed + 1)) + 1;
    soJumpHole: Result := Round(PointDistance(OrderDestination, Position) / (Speed + 1)) + 1;
    soFollowShip: Result := Round(PointDistance((OrderTarget as TShip).Position, Position) / (Speed + 1)) + 1;
  else Result := 0;
  end;
end;
{ @end $753E00 }

{ @routine $753FC4 TShip_EstimateTravelTurnsToObject }
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
{ @end $753FC4 }

{ @routine $75415C TShip_EstimateTravelTurnsToPlanet }
function TShip.EstimateTravelTurnsToPlanet(Planet: TPlanet): Integer;
begin
  if (Speed = 0) or (Planet = nil) or (Planet.CurrentStar = nil) or (Planet.CurrentStar <> CurrentStar) then begin Result := -1; Exit; end;
  Result := Round(PointDistance(Planet.GetPosition, Position) / (Speed + 1)) + 1;
end;
{ @end $75415C }

{ @routine $7541D8 TShip_NotifyCompanionDeath }
procedure TShip.NotifyCompanionDeath;
var
  Text: WideString;
begin
  if Self is TRanger then Text := PickLocalizedTextVariant('GalaxyNews.DeadShip.Partner', Seed + Galaxy.CurrentTurn div 11)
  else if Self is TPirate then Text := PickLocalizedTextVariant('GalaxyNews.DeadShip.Pirate', Seed + Galaxy.CurrentTurn div 11)
  else if Self is TTranclucator then Text := PickLocalizedTextVariant('GalaxyNews.DeadShip.Tranclucator', Seed + Galaxy.CurrentTurn div 11)
  else Exit;
  if Self is TTranclucator then GetPlayer.RefreshStorageBubbles;
  ReplaceTextToken(Text, '<Star>', CurrentStar.Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(-1), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', GetName, '<color=255,240,100>');
  ReplaceTextToken(Text, '<FullName>', GetFullName(' '), '<color=255,240,100>');
  AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, '');
end;
{ @end $7541D8 }

{ @routine $7544DC TShip_ApplyDamage }
function TShip.ApplyDamage(Source: TObject; Damage: Integer; HitRange: Single; out DamageColor: Cardinal; DamageFlags: TDamageFlagSet): Integer;
const
  ScannerDamageFlags = [dkScanBonus..dkDroidBlock];
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
  if (TypeId = stKling) and (Attacker <> nil) and (Attacker.TypeId = stKling) and
    ((Self as TKling).DominatorSeries = (Attacker as TKling).DominatorSeries) and
    not (Attacker as TKling).IsProgramActive(prgInsanity) and
    (HasIndependentScriptFaction = Attacker.HasIndependentScriptFaction) and
    (not HasIndependentScriptFaction or (TScriptShip(ScriptShip).StateText = TScriptShip(Attacker.ScriptShip).StateText)) then
  begin
    Result := 0;
    Exit;
  end;
  if (HitRange <> -1) and ((OwnerId in [oiMaloc..oiGaal, oiPirate]) or (TypeId = stTranclucator)) and
    (Attacker <> nil) and (GetRelationLevelToShip(Attacker) > rlHostile) then
  begin
    Result := 0;
    Exit;
  end;
  if (HitRange <> -1) and (TypeId = stKling) and (GetPlayer = Attacker) and
    (Self as TKling).IsPlayerCamouflageEffective(Attacker) then
  begin
    Result := 0;
    Exit;
  end;
  if (HitRange <> -1) and (Attacker <> nil) and (Attacker.TypeId = stKling) and (GetPlayer = Self) and
    (Attacker as TKling).IsPlayerCamouflageEffective(Self) then
  begin
    Result := 0;
    Exit;
  end;
  if (Attacker <> nil) and (Self <> Attacker) and
    (not (Source is TMissile) or (HitRange = -1) or (GetRelationLevelToShip(Attacker) <= rlHostile)) then
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
    if Dword(DamageFlags) and (1 shl Ord(dkScanBonus)) <> 0 then DamageValue := DamageValue * 1.15;
    if Dword(DamageFlags) and (1 shl Ord(dkBonusToDamaged)) <> 0 then DamageValue := (1 + (1 - GetHull.HullPoints / GetHull.Weight) * 0.33) * DamageValue;
  end;
  if Dword(DamageFlags) and (1 shl Ord(dkEnergy)) <> 0 then
    for J := 1 to CountActiveArtefacts(t_ArtEnergyDef) do
      if NextRandomUnitFloat(RandomState) < 0.3 * (Ord(CanBoostArtefact(t_ArtEnergyDef, nil, False)) + 1) then
      begin
        DamageValue := 0;
        Break;
      end;
  if Dword(DamageFlags) and (1 shl Ord(dkMissile)) <> 0 then
    for J := 1 to CountActiveArtefacts(t_ArtMissileDef) do
      DamageValue := DamageValue / (1 + NextRandomFloatRange(0.1, 0.4, RandomState) *
        (Ord(CanBoostArtefact(t_ArtMissileDef, nil, False)) + 1));
  if (Attacker <> nil) and (GetPlayer = Attacker) then
  begin
    if Attacker.IsHealthEffectActive(10) or Attacker.IsHealthEffectActive(7) or
      Attacker.IsHealthEffectActive(8) then DamageValue := DamageValue * NextRandomUnitFloat(RandomState);
    if TypeId = stKling then (Self as TKling).DetectAttackingPlayer(Attacker);
  end;
  if DamageValue < 1 then
    if NextRandomUnitFloat(RandomState) < 0.5 then DamageValue := 1 else DamageValue := 2;
  if (Self is TKling) and (DamageValue > 0) and ((Self as TKling).DominatorSeries = dsKeller) and
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
  StatusStrength := GetCombatStatusStrength(cseBWBuff);
  if StatusStrength > 0.01 then DamageValue := DamageValue / (1 + StatusStrength * 0.01);
  if Attacker <> nil then StatusStrength := Attacker.GetCombatStatusStrength(cseBWBuff)
  else StatusStrength := 0;
  if StatusStrength > 0.01 then DamageValue := DamageValue * (1 + StatusStrength * 0.01);
  if TypeId = stKling then
  begin
    if (Self as TKling).KlingType = ktBoss then
    begin
      if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then
      begin
        if DaysSincePlayerSeen > 20 then DamageValue := DamageValue * 0.5;
        if Round(DamageValue) >= GetHull.HullPoints then DamageValue := GetHull.HullPoints - 1;
      end;
      if (Round(DamageValue) >= GetHull.HullPoints) and (KellerShip = Self) then DamageValue := GetHull.HullPoints - 1;
    end;
  end
  else if (Attacker <> nil) and (Attacker.TypeId = stKling) and ((Attacker as TKling).KlingType = ktBoss) then
    DamageValue := DamageValue * 2 * Galaxy.InterpolateDifficulty(-1, 0.7, 1, 1.2, 1.5);
  AdjustedDamage := Round(DamageValue);
  if (GetPlayer = Self) and ((Galaxy.GodModEnabled = 1) or (Galaxy.SpecialSimulationMode <> 0)) then AdjustedDamage := 0;
  if (Order = soTeleport) and (OrderTarget <> nil) and (OrderTarget <> CurrentStar) then AdjustedDamage := 0;
  if GetHull.ImpulseShieldsEnabled and (Dword(DamageFlags) and (1 shl Ord(dkUndefendable)) = 0) and
    (NextRandomIntRange(0, 100, RandomState) > GetDefenseDamageFactor * 100) then
  begin
    Result := -AdjustedDamage;
    DamageColor := 0;
    Exit;
  end;
  if Attacker <> nil then AdjustedDamage := Attacker.ScriptItemsAct(satOnDealingDamage, Self, nil, AdjustedDamage);
  AdjustedDamage := ScriptItemsAct(DamageScriptActionTypes[Ord(ClassifyWeaponDamageFlags(DamageFlags))], Source, nil, AdjustedDamage);
  if AdjustedDamage <= 0 then
  begin
    Result := 0;
    DamageColor := 0;
    Exit;
  end;
  ExpectedHullPoints := 0;
  if (GetHull.HullPoints - AdjustedDamage <= 0) and (KellerShip <> Self) and (Dword(DamageFlags) and (1 shl Ord(dkNonLethal)) = 0) then
  begin
    if Attacker <> nil then
    begin
      Attacker.ScriptItemsAct(satOnDealingFatalDamage, Self, nil, 0);
      if Attacker is TNormalShip then (Attacker as TNormalShip).ProcessShipKill(Self);
      if Attacker.TypeId = stRanger then (Attacker as TRanger).ApplyAttackReputationChanges(Self, 1);
      if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = stRanger) then
        (Attacker.PartnerShip as TRanger).ApplyAttackReputationChanges(Self, 0.5);
      if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and
        (TTranclucator(Attacker).OwnerShip.TypeId = stRanger) then
      begin
        ((Attacker as TTranclucator).OwnerShip as TRanger).ApplyAttackReputationChanges(Self, 1);
        if (Attacker as TTranclucator).OwnerShip = GetPlayer then
        begin
          Event := AddGalaxyEvent('PlayerTranclucatorKillsShip');
          Event.AddData(TypeId);
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
          else if Self is TWarrior then Event.AddData((Self as TWarrior).WarriorType)
          else if Self is TPirate then Event.AddData((Self as TPirate).PirateType)
          else Event.AddData(0);
        end;
      end;
    end;
    if Source = nil then ScriptItemsAct(satOnDeath, nil, nil, 0)
    else if Source is TMissile then ScriptItemsAct(satOnDeath, TMissile(Source).OwnerShip, Source, 0)
    else if Source is TShip then ScriptItemsAct(satOnDeath, Source, nil, 0)
    else ScriptItemsAct(satOnDeath, nil, nil, 0);
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
      if OwnerId = oiDominator then Cistern.DominatorSeries := (Self as TKling).DominatorSeries;
      Inventory.Add(Cistern);
      DropCarriedItemAsMovingLoot(Cistern);
    end;
    if Self is TRuins then JettisonCargoGoodsTowardTargetValue(Galaxy.ComputeScaledHugeMoney(oiHuman))
    else if (CurrentStar.Items = nil) or (CurrentStar.Items.Count < 20) or (OwnerId = oiDominator) or HasIndependentScriptFaction then
    begin
      DropRoll := NextRandomUnitFloat(RandomState);
      if (DropRoll < 0.1) and (not (Self is TKling) or (Attacker = nil) or not (Attacker is TKling) or
        (DropRoll < 0.1 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor)) then
        DropRandomValuableItemsOnDestruction(1)
      else
      begin
        if DropRoll < 0.85 then DropCount := 1 else DropCount := 2;
        if (Attacker <> nil) and (Attacker.CountActiveArtefacts(t_ArtefactMiniExpl) > 0) then
        begin
          if NextRandomUnitFloat(RandomState) > 0.6 then Inc(DropCount)
          else if (NextRandomUnitFloat(RandomState) > 0.8 - Attacker.CountActiveArtefacts(t_ArtefactMiniExpl) * 0.2 *
            (Ord(Attacker.CanBoostArtefact(t_ArtefactMiniExpl, nil, False)) + 1)) or
            (ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkMoreDrop)) <> 0) and (NextRandomUnitFloat(RandomState) > 0.9)) then
            DropRandomValuableItemsOnDestruction(1);
        end;
        if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkMoreDrop)) <> 0) and (NextRandomUnitFloat(RandomState) > 0.6) then Inc(DropCount);
        DropRandomCheapItemsOnDestruction(DropCount);
      end;
      if (OwnerId = oiPirate) and (TypeId = stPirate) and ((RandomState + Cardinal(Galaxy.CurrentTurn)) mod 31 = 0) then
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
        Module.DominatorSeries := dsBlazer;
        Module.OwnerId := oiPirate;
        Inventory.Add(Module);
        DropCarriedItemAsMovingLoot(Module);
      end;
      if OwnerId = oiDominator then
      begin
        if ((RandomState + Cardinal(Galaxy.CurrentTurn)) mod 2 = 0) or ((Self as TKling).KlingType = ktBoss) then
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
          Module.OwnerId := oiDominator;
          Inventory.Add(Module);
          DropCarriedItemAsMovingLoot(Module);
        end;
      end
      else if TypeId in [stRanger..stPirate] then JettisonCargoGoodsTowardTargetValue(Galaxy.ComputeScaledAverageMoney(OwnerId));
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
    if ((KellerShip = Self) or (Dword(DamageFlags) and (1 shl Ord(dkNonLethal)) <> 0)) and (GetHull.HullPoints < 1) then GetHull.HullPoints := 1;
    ExpectedHullPoints := GetHull.HullPoints;
    if (AdjustedDamage = 1) and (GetPlayer = Attacker) and (Attacker <> nil) then
    begin
      Inc(PlayerScratchHitsReceived);
      GetPlayer.AchievementStats.CheckScratchDamageAchievement(PlayerScratchHitsReceived);
    end;
    EngineLoss := NextRandomIntRange(0, 2, RandomState);
    if Dword(DamageFlags) and (1 shl Ord(dkDecelerate)) <> 0 then Inc(EngineLoss, NextRandomIntRange(5, 15, RandomState));
    if Dword(DamageFlags) and (1 shl Ord(dkDecelerateA)) <> 0 then Inc(EngineLoss, NextRandomIntRange(5, 15, RandomState));
    if Dword(DamageFlags) and (1 shl Ord(dkDecelerateAEx)) <> 0 then Inc(EngineLoss, NextRandomIntRange(5, 15, RandomState));
    if (EngineLoss > 0) and (GetEngine <> nil) then
      if GetEngine.OutputPercent > EngineLoss then Dec(GetEngine.OutputPercent, EngineLoss)
      else GetEngine.OutputPercent := 0;
    if TypeId <> stTranclucator then
    begin
      if OwnerId <> oiDominator then
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
          if (Self as TWarrior).WarriorType = wtFlagship then Wear := Wear * 0.6;
        end;
        if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkReduceEngine)) <> 0) and (GetEngine <> nil) and (GetEngine.BrokenFlag = 0) then
        begin
          ApplyCombatItemDegradation(0.5 * Wear);
          ApplyItemDegradation(GetEngine, idkBattle, 15 * Wear);
        end
        else ApplyCombatItemDegradation(Wear);
        if Dword(DamageFlags) and (1 shl Ord(dkDestruct)) <> 0 then
        begin
          Wear := NextRandomFloatRange(5, 15, RandomState);
          if Self is TWarrior then Wear := Wear * 0.3
          else if Self is TRanger then
          begin
            if GetPlayer = Self then Wear := Wear
            else Wear := Wear * 0.6;
          end;
          Wear := Wear * 0.1;
          if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkReduceEngine)) <> 0) and (GetEngine <> nil) and (GetEngine.BrokenFlag = 0) then
          begin
            ApplyCombatItemDegradation(0.5 * Wear);
            ApplyItemDegradation(GetEngine, idkBattle, 15 * Wear);
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
        if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkDropCargo)) <> 0) and (NextRandomUnitFloat(RandomState) > 0.95) then
        begin
          Nodes := TProtoplasm.Create;
          Nodes.Init(NextRandomIntRange(NodeReserve div 4, NodeReserve div 2, RandomState) + 1, 1);
          Nodes.DominatorSeries := (Self as TKling).DominatorSeries;
          Inventory.Add(Nodes);
          DropCarriedItemAsMovingLoot(Nodes);
        end;
      end;
    end;
    if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkDropCargo)) <> 0) and (NextRandomUnitFloat(RandomState) > 0.95) then
      JettisonCargoGoodsTowardTargetValue(Galaxy.ComputeScaledMiniMoney(oiHuman));
    if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkBlockWeapon)) <> 0) then AddCombatStatusStrength(cseWeaponBlock, 0.1, Attacker);
    if ScannerEffects and (Dword(DamageFlags) and (1 shl Ord(dkDroidBlock)) <> 0) then AddCombatStatusStrength(cseDroidBlock, 0.1, Attacker);
    if Dword(DamageFlags) and (1 shl Ord(dkShock)) <> 0 then
      if Self is TKling then AddCombatStatusStrength(cseShock, AdjustedDamage * 0.12, Attacker)
      else AddCombatStatusStrength(cseShock, AdjustedDamage * 0.2, Attacker);
    if (Dword(DamageFlags) and (1 shl Ord(dkAcid)) <> 0) and (GetHull.Armor > GetCombatStatusStrength(cseAcid)) then
      if Self is TKling then AddCombatStatusStrength(cseAcid, 0.66, Attacker)
      else AddCombatStatusStrength(cseAcid, 1, Attacker);
    if Dword(DamageFlags) and (1 shl Ord(dkMagnetic)) <> 0 then
      if Self is TKling then AddCombatStatusStrength(cseMagnetic, 0.07 + Max(0, Damage + GetArmor) * 0.075, Attacker)
      else AddCombatStatusStrength(cseMagnetic, 0.1 + Max(0, Damage + GetArmor) * 0.05, Attacker);
  end;
  if GetPlayer = Self then DamageColor := OwnerToFilmColor(RaceToOwner(PilotRace))
  else if HasNamedScriptFaction then DamageColor := CustomFactionToFilmColor(TScriptShip(ScriptShip).StateText)
  else DamageColor := OwnerToFilmColor(OwnerId);
  if AdjustedDamage <= 0 then DamageColor := 0;
  RefreshDerivedStats(True);
  Result := AdjustedDamage;
  if (Dword(DamageFlags) and (1 shl Ord(dkDrain)) <> 0) and (Attacker <> nil) then
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
{ @end $7544DC }

{ @routine $756768 TShip_ApplyWeaponHit }
function TShip.ApplyWeaponHit(Source: TShip; Weapon: TWeapon; HitRange: Single; out DamageColor: Cardinal; out DamageFlags: TDamageFlagSet; DamageScale: Single; FixedDamage: Integer): Integer;
const
  EnergyDamageFlags = [dkEnergy];
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
  if (FixedDamage > 0) and not (dkUndefendable in Flags) then
  begin
    AdjustedDamage := FixedDamage;
    Include(Flags, dkUndefendable);
  end
  else
  begin
    SkillDifference := Source.GetEffectiveSkillLevel(psAccuracy) -
      GetEffectiveSkillLevel(psManeuverability);
    MaxDamage := Source.GetWeaponMaxDamage(Weapon);
    MinDamage := Source.GetWeaponMinDamage(Weapon);
    DamageStep := (MaxDamage - MinDamage) / 12;
    Spread := Round((6 - Abs(SkillDifference)) * DamageStep);
    RolledDamage := Round(RemapClamped(SkillDifference, -6, 6, MinDamage, MaxDamage));
    RolledDamage := NextRandomIntRange(Max(MinDamage, RolledDamage - Spread), Min(MaxDamage, RolledDamage + Spread), RandomState);
    RolledDamage := Round(RolledDamage * DamageScale);
    if (Source is TKling) and ((Source as TKling).DominatorSeries = dsBlazer) then
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
    RolledDamage := Source.ScriptItemsAct(satOnWeaponShot, Self, Weapon, RolledDamage);
    if dkUndefendable in Flags then AdjustedDamage := RolledDamage
    else
    begin
      if not GetHull.ImpulseShieldsEnabled then
        AdjustedDamage := GetDefenseDamageFactor * RolledDamage - GetArmor
      else AdjustedDamage := (GetDefenseDamageFactor * 0.5 + 0.5) * RolledDamage - GetArmor;
    end;
  end;
  if (Source.GetDefGenerator <> nil) and (Source.CountActiveArtefacts(t_ArtDefToEnergy) > 0) and
    (dkEnergy in Weapon.GetWeaponInfo.DamageFlags) then
    AdjustedDamage := (1 + (RemapClamped(Source.CountWeaponsByDamageFlags(EnergyDamageFlags), 1, 5,
      DefenseToEnergyUpperFactor + ShortInt(Source.CanBoostArtefact(t_ArtDefToEnergy, Weapon, False)) * DefenseToEnergyUpperBoost,
      DefenseToEnergyMinimumFactor + ShortInt(Source.CanBoostArtefact(t_ArtDefToEnergy, Weapon, False)) * DefenseToEnergyMinimumBoost) - 1) *
      Source.CountActiveArtefacts(t_ArtDefToEnergy)) * AdjustedDamage;
  if dkEnergy in Weapon.GetWeaponInfo.DamageFlags then
    for I := 1 to Source.CountActiveArtefacts(t_ArtEnergyPulse) do
      if NextRandomUnitFloat(RandomState) < EnergyPulseArtefactChance then
        AdjustedDamage := (EnergyPulseArtefactFactor + ShortInt(Source.CanBoostArtefact(t_ArtEnergyPulse, Weapon, False)) *
          EnergyPulseArtefactBoostFactor) * AdjustedDamage;
  if (Source.CountActiveArtefacts(t_ArtDecelerate) > 0) and (dkSplinter in Weapon.GetWeaponInfo.DamageFlags) then
  begin
    Include(Flags, dkDecelerateA);
    if Source.CanBoostArtefact(t_ArtDecelerate, Weapon, False) or (Source.CountActiveArtefacts(t_ArtDecelerate) > 1) then Include(Flags, dkDecelerateAEx);
  end;
  if dkSplinter in Weapon.GetWeaponInfo.DamageFlags then
    for I := 1 to Source.CountActiveArtefacts(t_ArtSplinter) do
      AdjustedDamage := (SplinterArtefactFactor + ShortInt(Source.CanBoostArtefact(t_ArtSplinter, Weapon, False)) *
        SplinterArtefactBoostFactor) * AdjustedDamage;
  Damage := Round(AdjustedDamage);
  ScriptFlags := Integer(Flags);
  ScriptFlags := Source.ScriptItemsAct(satOnWeaponShot2, Self, Weapon, ScriptFlags);
  ScriptFlags := ScriptItemsAct(satOnGettingWeaponHit, Source, Weapon, ScriptFlags);
  Flags := TDamageFlagSet(ScriptFlags);
  DamageFlags := Flags;
  Result := ApplyDamage(Source, Damage, HitRange, DamageColor, Flags);
  if (GetHull.HullPoints < 1) and (GetPlayer = Source) then
  begin
    if dkSplinter in Weapon.GetWeaponInfo.DamageFlags then TryAddAchievementProgress('SPLINTER', 1);
    if dkEnergy in Weapon.GetWeaponInfo.DamageFlags then TryAddAchievementProgress('ENERGY', 1);
  end;
  if (GetPlayer = Self) and (GetHull.HullPoints < 1) then
  begin
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('KilledByBeamWeapon');
    ScoreScreen.RecordPlayerResult(False);
  end;
end;
{ @end $756768 }

{ @routine $756E4C TShip_ApplyMissileHit }
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
  if Shot.OwnerShip <> nil then ScriptFlags := Shot.OwnerShip.ScriptItemsAct(satOnMissileShot2, Self, Missile, ScriptFlags);
  ScriptFlags := ScriptItemsAct(satOnGettingMissileHit, Shot.OwnerShip, Missile, ScriptFlags);
  Flags := TDamageFlagSet(ScriptFlags);
  DamageFlags := Flags;
  if Shot.OwnerShip = nil then
    SkillDifference := 0 - GetEffectiveSkillLevel(psManeuverability)
  else SkillDifference := Shot.OwnerShip.GetEffectiveSkillLevel(psAccuracy) -
    GetEffectiveSkillLevel(psManeuverability);
  MinDamage := Shot.MinDamage;
  MaxDamage := Shot.MaxDamage;
  DamageStep := (MaxDamage - MinDamage) / 12;
  Spread := Round((6 - Abs(SkillDifference)) * DamageStep);
  RolledDamage := Round(RemapClamped(SkillDifference, -6, 6, MinDamage, MaxDamage));
  RolledDamage := NextRandomIntRange(Max(MinDamage, RolledDamage - Spread), Min(MaxDamage, RolledDamage + Spread), RandomState);
  if dkUndefendable in Flags then AdjustedDamage := RolledDamage
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
{ @end $756E4C }

{ @routine $7571AC TShip_FireWeaponAtMissile }
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
    Hit := ScriptItemsAct(satOnWeaponShot, Shot, Weapon, Byte(Hit)) <> 0;
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
    if (dkEnergy in Info.DamageFlags) and (Info.ShotType = wstSplash) then
    begin
      I := 0;
      while I < Star.Missiles.Count do
      begin
        Other := Star.Missiles[I];
        Inc(I);
        if Shot = Other then Continue;
        if PointDistanceSquared(Shot.Position, Other.Position) > Sqr(Info.SecondaryDamageRadius) then Continue;
        OtherHit := Other.CanBeHit(Self, Weapon);
        OtherHit := ScriptItemsAct(satOnWeaponShot, Other, Weapon, Byte(OtherHit)) <> 0;
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
    else if (dkEnergy in Info.DamageFlags) and (Info.ShotType = wstAreaDamage) then
    begin
      I := 0;
      while I < Star.Missiles.Count do
      begin
        Other := Star.Missiles[I];
        Inc(I);
        if Shot = Other then Continue;
        if PointDistanceSquared(Position, Other.Position) > Sqr(GetWeaponRange(Weapon)) * 1.3 then Continue;
        if (TypeId = stKling) and (Other.OwnerShip <> nil) and (Other.OwnerShip.TypeId = stKling) and
          ((Self as TKling).DominatorSeries = (Other.OwnerShip as TKling).DominatorSeries) then Continue;
        OtherHit := Other.CanBeHit(Self, Weapon);
        OtherHit := ScriptItemsAct(satOnWeaponShot, Other, Weapon, Byte(OtherHit)) <> 0;
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
{ @end $7571AC }

{ @routine $757D20 TShip_FireWeaponAtShip }
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

  // @nested $757790 ApplyChainExplosion
  function ApplyChainExplosion(ExplodingShip: TShip): Integer; // @addr 0x757790 @note "Caller-popped static link; recursively damages nearby hostiles. Returns the accumulated signed damage results."
  var
    I: Integer;
    Ship: TShip;
  begin
    Result := 0;
    for I := 0 to Count - 1 do
    begin
      Ship := Star.Ships[I];
      if (Ship <> ExplodingShip) and (Self <> Ship) and Ship.InNormalSpace and not Ship.IsHullDestroyed then
      begin
        DistanceSquared := PointDistanceSquared(Ship.Position, ExplodingShip.Position);
        if (Sqr(Info.SecondaryDamageRadius) >= DistanceSquared) and (GetRelationLevelToShip(Ship) <= rlHostile) then
          if not (Self is TKling) or not (Self as TKling).IsPlayerCamouflageEffective(Ship) then
            if not (Ship is TKling) or not (Ship as TKling).IsPlayerCamouflageEffective(Self) then
            begin
              Damage := Ship.ApplyWeaponHit(Self, Weapon, Sqrt(DistanceSquared), Color, Flags, 1,
                Round(ExplodingShip.CalculateMass * 0.1));
              if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
    end;
  end;

  // @nested $757B34 FinishChainExplosionFilm
  procedure FinishChainExplosionFilm; // @addr 0x757B34 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; merges repeated targets' damage in the parent's film lists."
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
  if Info.ShotType = wstNormal then
  begin
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
  else if Info.ShotType = wstChain then
  begin
    if ((GetPlayer = Self) and RecordFilm) and (Star.PlayerFilmPath <> nil) then
      Star.PlayerFilmPath.AppendWaypoint(MakePointF((Target.Position.X + Position.X) / 2,
        (Target.Position.Y + Position.Y) / 2), StepIndex + 25);
    RadiusSquared := Sqr(GetWeaponRange(Weapon)) * 1.3;
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
            (GetRelationLevelToShip(Ship) <= rlHostile) then
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
        if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
  else if Info.ShotType = wstSplash then
  begin
    if ((GetPlayer = Self) and RecordFilm) and (Star.PlayerFilmPath <> nil) then
      Star.PlayerFilmPath.AppendWaypoint(MakePointF((Target.Position.X + Position.X) / 2,
        (Target.Position.Y + Position.Y) / 2), StepIndex + 25);
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
          if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
  else if Info.ShotType = wstExploder then
  begin
    if (GetPlayer = Self) and RecordFilm then
      PrimaryFilm.AddCameraEvent(StepIndex, GetPlayer.Position, Target.Position, 1);
    Damage := Target.ApplyWeaponHit(Self, Weapon, -1, Color, Flags, 1, 0);
    if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
      if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
  else if Info.ShotType = wstAreaDamage then
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
          if (dkDrain in Flags) and (Damage > 0) then Inc(DrainedDamage, Damage);
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
  if (PrimaryDamage <> 0) and (Target.CountActiveArtefacts(t_ArtefactDef) > 0) then
  begin
    Reflect := PrimaryDamage < 0;
    if not Reflect then
      for J := 1 to Target.CountActiveArtefacts(t_ArtefactDef) do
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
{ @end $757D20 }

{ @routine $7590FC TShip_FireWeaponAtItem }
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
  ActionResult := ScriptItemsAct(satOnWeaponShot, Target, Weapon, 0);
  if Target.DestroyFlag = 0 then Target.DestroyFlag := 1;
  WasWeaponTarget := (Weapon <> nil) and (Weapon.Target = Target);
  if Target.ScriptItem <> nil then
    ActionResult := TScriptItem(Target.ScriptItem).RunActionCode(satOnItemHit, Self, Weapon, CurrentStar, ActionResult);
  if Target is TEquipmentWithActCode then
    ActionResult := RunItemConfigActionCode(Target, satOnItemHit, Self, Weapon, CurrentStar, ActionResult);
  if WasWeaponTarget and (Weapon.Target <> Target) then Exit;
  Explodes := (Target.ItemType = t_ArtefactBomb) or ((Target is TCistern) and ((Target as TCistern).Fuel > 0)) or
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
      if Ship.InNormalSpace and not Ship.IsHullDestroyed and
        ((GetPlayer <> Ship) or ((Galaxy.GodModEnabled <> 1) and (Galaxy.SpecialSimulationMode = 0))) then
      begin
        DistanceSquared := PointDistanceSquared(Ship.Position, Target.Position);
        if ItemExplosionRadiusSquared >= DistanceSquared then
        begin
          Damage := Ship.ApplyExplosionDamage(Self, Target, ActionResult, nil);
          if Ship.IsHullDestroyed and (GetPlayer <> nil) and (Target.ItemType = t_ArtefactBomb) and (GetPlayer = Self) then
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
    end;
    Count := Star.Items.Count;
    for I := 0 to Count - 1 do
    begin
      Item := Star.Items[I];
      if Item <> Target then
      begin
        DistanceSquared := PointDistanceSquared(Item.Position, Target.Position);
        if ItemExplosionRadiusSquared >= DistanceSquared then
          if 20 - 20 * DistanceSquared / ItemExplosionRadiusSquared >= NextRandomIntRange(1, 100, Star.RandomState) then
          begin
            if Item.DestroyFlag < 0 then Inc(Item.DestroyFlag)
            else Star.ReferencedItems.Add(Item);
          end;
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
{ @end $7590FC }

{ @routine $7597E4 TShip_FireWeaponAtAsteroid }
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
    ScriptItemsAct(satOnWeaponShot, Asteroid, Weapon, 0);
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
{ @end $7597E4 }

{ @routine $759A40 TShip_ApplyInterceptorDamage }
function TShip.ApplyInterceptorDamage(out DamageColor: Cardinal): Integer;
const
  InterceptorDamageFlags = [dkEnergy];
var
  Damage: Integer;
  Event: TGalaxyEvent;
  SourceShip: TShip;
begin
  SourceShip := InterceptorSourceShip;
  if SourceShip = nil then Damage := 25 else Damage := SourceShip.GetInterceptorDamage;
  if (Self is TKling) and (Ord((Self as TKling).KlingType) = 0) then Damage := Max(1, Damage div 2);
  Result := ApplyDamage(SourceShip, Damage, -1, DamageColor, InterceptorDamageFlags);
  if (GetPlayer = Self) and (GetHull.HullPoints < 1) then
  begin
    ScoreScreen.RecordPlayerResult(False);
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('KilledByInterceptor');
  end;
end;
{ @end $759A40 }

{ @routine $759B7C TShip_ApplyShockStatusDamage }
function TShip.ApplyShockStatusDamage(out DamageColor: Cardinal): Integer;
const
  ShockDamageFlags = [dkEnergy, dkNonLethal];
begin
  Result := ApplyDamage(nil, Round(GetCombatStatusStrength(cseShock)), -1, DamageColor, ShockDamageFlags);
end;
{ @end $759B7C }

{ @routine $759BC0 TShip_ApplyAsteroidImpactDamage }
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
      Factor := Max(0, 1 - GetTotalStatBonus(bonResistAsteroid) * 0.01);
      if IsEquipmentUsable(GetDefGenerator) then
        Damage := Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1,
          GetHull.Weight * AsteroidMinDamageFactorWithDefGenerator,
          GetHull.Weight * AsteroidMaxDamageFactorWithDefGenerator) * Factor)
      else
        Damage := Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1,
          GetHull.Weight * AsteroidMinDamageFactor,
          GetHull.Weight * AsteroidMaxDamageFactor) * Factor);
      Damage := ScriptItemsAct(satOnTakingDamage, Asteroid, nil, Damage);
      if (GetHull.HullPoints - Damage <= 0) and (BlazerShip <> Self) and (KellerShip <> Self) and (TerronShip <> Self) then
      begin
        ScriptItemsAct(satOnDeath, nil, Asteroid, 0);
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
{ @end $759BC0 }

{ @routine $759F7C TShip_ApplyExplosionDamage }
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
    if Item.ItemType = t_ArtefactBomb then
      Inc(Damage, Round(RemapClamped(DistanceSquared, 0, ItemExplosionRadiusSquared, BombMaximumDamage, BombMinimumDamage)))
    else if Item is TCistern then Inc(Damage, (Item as TCistern).Fuel);
    if Item.DestroyFlag = 2 then Inc(Damage, ItemExplosionBonusDamage)
    else if Item.DestroyFlag > 2 then Inc(Damage, Item.DestroyFlag);
    if Damage = 0 then Exit;
    if Missile <> nil then Damage := ScriptItemsAct(satOnTakingDamage, Item, Missile, Damage)
    else Damage := ScriptItemsAct(satOnTakingDamage, Item, SourceShip, Damage);
  end
  else if ExplodingObject is TShip then
  begin
    Ship := TShip(ExplodingObject);
    if PointDistanceSquared(Position, Ship.Position) > 22500 then Exit;
    Damage := Ship.GetHull.Weight div 3;
    Damage := Ship.ScriptItemsAct(satOnDealingKamikazeDamage, Self, nil, Damage);
    Damage := ScriptItemsAct(satOnTakingDamage, Ship, nil, Damage);
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
      if Item.ItemType = t_ArtefactBomb then ReactToAttack(SourceShip)
      else if SourceShip is TRanger then
        ChangeRelationToRanger(SourceShip, Round(RemapClamped(Damage, 1, GetHull.HullPoints, -1, -80)));
    end;
    if (GetHull.HullPoints <= Damage) and (Self is TKling) and ((Self as TKling).KlingType = ktBoss) and
      ((KellerShip = Self) or ((GetPlayer <> nil) and (GetPlayer.CurrentStar <> CurrentStar))) then
      GetHull.HullPoints := Damage + 1;
    if (GetHull.HullPoints <= Damage) and (GetPlayer <> nil) then
    begin
      ScriptItemsAct(satOnDeath, SourceShip, ExplodingObject, 0);
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
    if (TypeId = stKling) and (SourceShip <> nil) then (Self as TKling).DetectAttackingPlayer(SourceShip);
    GetHull.HullPoints := Max(GetHull.HullPoints - Damage, 0);
    RefreshDerivedStats(True);
    if IsHullDestroyed then CurrentStar.ClearShipReferences(Self);
  end;
end;
{ @end $759F7C }

{ @routine $75A474 TShip_ApplyStarHeatDamage }
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
    if TypeId = stKling then
      Damage := Max((1 - Sqrt(DistanceSquared) / CurrentStar.DamageRadius) * 30 * Galaxy.GetStarDamageDifficultyScale, 1)
    else
      Damage := Max((1 - Sqrt(DistanceSquared) / CurrentStar.DamageRadius) * 100 * Galaxy.GetStarDamageDifficultyScale, 1);
    for I := 1 to CountActiveArtefacts(t_ArtefactPower) do
      Damage := (1 - StarHeatArtefactReduction - ShortInt(CanBoostArtefact(t_ArtefactPower, GetHull, False)) * StarHeatArtefactBoostReduction) * Damage;
    Damage := ScriptItemsAct(satOnTakingDamage, CurrentStar, nil, Round(Damage));
    Result := Round(Damage);
    GetHull.HullPoints := Max(GetHull.HullPoints - Round(Damage), 0);
    if (GetHull.HullPoints <= 0) and (Self is TKling) and ((Self as TKling).KlingType = ktBoss) then
      GetHull.HullPoints := 1;
    if (GetHull.HullPoints <= 0) and (GetPlayer <> nil) then
    begin
      ScriptItemsAct(satOnDeath, nil, CurrentStar, 0);
      GetPlayer.ProcessShipDestructionQuests(Self);
      if GetRelationLevelToShip(GetPlayer) <= rlHostile then
        if (GetPlayer = OrderTarget) or ((GetPlayer = EnemyShip) and (Order in [soNone, soLand, soJump])) or
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
{ @end $75A474 }

{ @routine $75A9C0 TShip_CountEquippedWeapons }
function TShip.CountEquippedWeapons: TWeaponCount;
var
  I, Count: Integer;
  Item: TEquipment;
begin
  Count := 0;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag <> 0) and (Item.ItemType in [t_Weapon1..t_CustomWeapon]) then Inc(Count);
  end;
  Result := Count;
end;
{ @end $75A9C0 }

{ @routine $75AA2C TShip_CountMissileWeapons }
function TShip.CountMissileWeapons: TWeaponCount;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do
    if (Weapons[I].GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) then Inc(Result);
end;
{ @end $75AA2C }

{ @routine $75AA80 TShip_CountDirectFireWeapons }
function TShip.CountDirectFireWeapons: Byte;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do
    if not (Weapons[I].GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) then Inc(Result);
end;
{ @end $75AA80 }

{ @routine $75AAD4 TShip_ClearUnequippedWeaponTargets }
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
{ @end $75AAD4 }

{ @routine $75AB5C TShip_CountWeaponsByDamageFlags }
function TShip.CountWeaponsByDamageFlags(Flags: TDamageFlagSet): TWeaponCount;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do if (Weapons[I].GetDamageFlags * Flags) <> [] then Inc(Result);
end;
{ @end $75AB5C }

{ @routine $75ABBC TShip_GetWeaponDamageSummary }
function TShip.GetWeaponDamageSummary: WideString;
var
  DifficultyFactor: Extended;
  I, MinimumDamage, MaximumDamage: Integer;
  Weapon: TWeapon;
begin
  Result := '0';
  MinimumDamage := 0;
  MaximumDamage := 0;
  if WeaponCount <> 0 then
  begin
    for I := 1 to WeaponCount do
    begin
      Weapon := Weapons[I];
      if IsEquipmentUsable(Weapon) then
      begin
        if Weapon.GetWeaponInfo.ShotType in [wstMissile..wstRocket] then
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
    if (TypeId = stKling) and (Ord((Self as TKling).KlingType) = 0) then
    begin
      DifficultyFactor := Galaxy.InterpolateDifficulty(-1, 0.7, 1, 1.2, 1.5) * 2;
      MinimumDamage := Round(MinimumDamage * DifficultyFactor);
      MaximumDamage := Round(MaximumDamage * DifficultyFactor);
    end;
    Result := WideString(IntToStr(MinimumDamage)) + WrapTextInColor('-', '<color=127,127,127>') + WideString(IntToStr(MaximumDamage));
    Result := WideString('(' + IntToStr(GetEffectiveSkillLevel(psAccuracy)) + ') ') + Result;
  end;
end;
{ @end $75ABBC }

{ @routine $75AED0 TShip_GetManeuverabilitySummary }
function TShip.GetManeuverabilitySummary: WideString;
begin
  Result := '(' + IntToStr(GetEffectiveSkillLevel(psManeuverability)) + ') ';
end;
{ @end $75AED0 }

{ @routine $75AF6C TShip_GetRepairPointsSummary }
function TShip.GetRepairPointsSummary: WideString;
begin
  Result := '0';
  if GetRepairRobot <> nil then Result := IntToStr(CalculateRepairPoints(GetRepairRobot));
end;
{ @end $75AF6C }

{ @routine $75AFF4 TShip_HasScannerArtefact }
function TShip.HasScannerArtefact(UnusedTarget: TShip): Boolean;
begin
  Result := CountActiveArtefacts(t_ArtefactScaner) > 0;
end;
{ @end $75AFF4 }

{ @routine $75B018 TShip_GetWeaponActionRange }
function TShip.GetWeaponActionRange(Weapon: TWeapon): Integer;
begin
  Result := GetWeaponRange(Weapon);
end;
{ @end $75B018 }

{ @routine $75B03C TShip_GetWeaponSlotRange }
function TShip.GetWeaponSlotRange(SlotIndex: Integer): Integer;
begin
  Result := GetWeaponRange(Weapons[SlotIndex]);
end;
{ @end $75B03C }

{ @routine $75B068 TShip_GetWeaponMinDamage }
function TShip.GetWeaponMinDamage(Weapon: TWeapon): Integer;
begin
  if (Cardinal(Weapon.GetDamageFlags) and DamageNoDeltaMask) <> 0 then Result := GetWeaponMaxDamage(Weapon)
  else Result := Weapon.MinDamage;
end;
{ @end $75B068 }

{ @routine $75B0A4 TShip_GetWeaponMaxDamage }
function TShip.GetWeaponMaxDamage(Weapon: TWeapon): Integer;
var
  BonusKind: TEquipmentBonusKind;
  Bonus, I: Integer;
  Extra: PExtraSpecial;
begin
  Result := Max(Weapon.MaxDamage, Weapon.MinDamage);
  if Weapon.ItemType in [t_Weapon1..t_CustomWeapon] then
  begin
    BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(Weapon.GetWeaponInfo.DamageFlags)].BonusKind;
    Bonus := GetTotalStatBonus(BonusKind);
    if (Weapon.GetWeaponInfo.ShotType in [wstMissile..wstRocket]) and not Galaxy.AreOldMissileBonusesEnabled then
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
end;
{ @end $75B0A4 }

{ @routine $75B234 TShip_GetMaxWeaponRange }
function TShip.GetMaxWeaponRange: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to WeaponCount do
    if IsEquipmentUsable(Weapons[I]) and (GetWeaponSlotRange(I) > Result) then
      Result := GetWeaponSlotRange(I);
end;
{ @end $75B234 }

{ @routine $75B2A0 TShip_ClearWeaponTargets }
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
{ @end $75B2A0 }

{ @routine $75B334 TShip_IsAttackingShip }
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
  if Target.GetCombatStatusSourceId(cseShock) = Id then
  begin
    Result := True;
    Exit;
  end;
  if Target.GetCombatStatusSourceId(cseAcid) = Id then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;
{ @end $75B334 }

{ @routine $75B3CC TShip_ChanceToWin }
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
{ @end $75B3CC }

{ @routine $75B92C TShip_GetWinChancePercent }
function TShip.GetWinChancePercent(Target: TShip): TPercent;
var Value: Double;
begin
  Value := ChanceToWin(Target);
  if Value >= 1 then Result := Round(RemapClamped(Value, 1, 4, 50, 100))
  else Result := Round(RemapClamped(Value, 0, 1, 0, 50));
end;
{ @end $75B92C }

{ @routine $75B9BC TShip_SetJointAttackTarget }
procedure TShip.SetJointAttackTarget(Ally, Target: TShip);
var I: Integer; Weapon: TWeapon;
begin
  EnemyShip := Target;
  for I := 1 to WeaponCount do begin
    Weapon := Weapons[I];
    if not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0) then begin
      if (Sqr(GetWeaponSlotRange(I)) >= PointDistanceSquared(Position, Target.Position)) and IsEquipmentUsable(Weapon) then Weapon.Target := Target;
    end;
  end;
  if HasPositiveSpeed then
    if GetPlayer = Self then begin OrderNone(False); PendingPlayerFollowTarget := Target; end
    else OrderFollowShip(EnemyShip, 1, True);
  Ally.EnemyShip := Target;
  for I := 1 to Ally.WeaponCount do begin
    Weapon := Ally.Weapons[I];
    if not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) or (Weapon.Ammo <> 0) then begin
      if (Sqr(Ally.GetWeaponSlotRange(I)) >= PointDistanceSquared(Ally.Position, Target.Position)) and Ally.IsEquipmentUsable(Weapon) then Weapon.Target := Target;
    end;
  end;
  if Ally.HasPositiveSpeed then
    if GetPlayer = Ally then begin GetPlayer.OrderNone(False); PendingPlayerFollowTarget := Target; end
    else Ally.OrderFollowShip(Ally.EnemyShip, 1, True);
end;
{ @end $75B9BC }

{ @routine $75BB9C TShip_IsEnemyPursuingSelf }
function TShip.IsEnemyPursuingSelf: Boolean;
begin
  if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or not EnemyShip.InNormalSpace then Result := False
  else Result := EnemyShip.OrderTarget = Self;
end;
{ @end $75BB9C }

{ @routine $75BBFC TShip_CanSafelyDetonateItem }
function TShip.CanSafelyDetonateItem(Item: TItem): Boolean;
var I: Integer; Ship: TShip; Distance: Single;
begin
  Result := True;
  if (CurrentStar <> nil) and ((Item.ItemType = t_ArtefactBomb) or (Item is TCistern)) then
    for I := 0 to CurrentStar.Ships.Count - 1 do begin
      Ship := CurrentStar.Ships[I];
      if not Ship.IsOutsideStarSpace then begin
        Distance := PointDistanceSquared(Ship.Position, Item.Position);
        if (ItemExplosionRadiusSquared >= Distance) and (GetRelationLevelToShip(Ship) > rlHostile) then begin Result := False; Exit; end;
      end;
    end;
end;
{ @end $75BBFC }

{ @routine $75BCBC TShip_SetStoredRangerRelationLevel }
procedure TShip.SetStoredRangerRelationLevel(Ranger: TShip; Level: TRelationLevel);
begin
  if RangerRelations.Count < 1 then Exit;
  case Level of
    rlHostile: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(5);
    rlBad: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(20);
    rlNormal: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(45);
    rlGood: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(70);
    rlExcellent: RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(90);
  else RangerRelations[Galaxy.Rangers.IndexOf(Ranger as TRanger)] := Pointer(5);
  end;
end;
{ @end $75BCBC }

{ @routine $75BE58 TShip_GetRelationLevelToShip }
function TShip.GetRelationLevelToShip(Ship: TShip): TRelationLevel;
begin
  case RelationToShip(Ship) of
    0..9: Result := rlHostile;
    10..29: Result := rlBad;
    30..59: Result := rlNormal;
    60..79: Result := rlGood;
    80..100: Result := rlExcellent;
  else Result := rlNormal;
  end;
end;
{ @end $75BE58 }

{ @routine $75BEC0 TShip_GetRelationLevelTextToShip }
function TShip.GetRelationLevelTextToShip(Ship: TShip): WideString;
var Level: TRelationLevel;
begin
  Level := GetRelationLevelToShip(Ship);
  Result := RelationInfo[Level].DisplayName;
  if (Level <> rlHostile) and (Self is TRuins) and (Ship is TRanger) and
     (RangerRelations <> nil) and (RangerRelations.Count > 0) then
  begin
    Level := RelationValueToLevel(Byte(RangerRelations[Galaxy.Rangers.IndexOf(Ship)]));
    if Level <> rlHostile then Result := RelationInfo[Level].DisplayName;
  end;
end;
{ @end $75BEC0 }

{ @routine $75BF90 TShip_TryExtortShip }
function TShip.TryExtortShip(Target: TShip): Boolean;
var Amount: Integer; Response: WideString;
begin
  Result := False;
  if (Target.TypeId in [stRanger..stPirate]) and (Target <> TruceShip) and Target.InNormalSpace and
    ((CurrentStanding <> ssPirateMilitary) or (Target.CurrentStanding <> ssCoalitionMilitary)) and ((Target.CurrentStanding <> ssPirateMilitary) or (CurrentStanding <> ssCoalitionMilitary)) and CanContactShip(Target) then begin
    if TypeId = stRanger then (Self as TRanger).AddPirateCareerActivity(2);
    if (GetPlayer = Target) and not PlayerAutomaticControl then begin
      if Cardinal(ReservedMessageCounter) < 7 then Exit;
      ReservedMessageCounter := 0;
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
{ @end $75BF90 }

{ @routine $75C22C TShip_TruceWithShip }
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
  if (TypeId = stRanger) and (Ship.RelationToRanger(Self) < RelationBadMin) then Ship.ChangeRelationToRanger(Self, 10);
  if Ship.TypeId = stRanger then ChangeRelationToRanger(Ship, 30);
  if (Order = soFollowShip) and ((OrderTarget as TShip) = Ship) then begin
    OrderNone(False);
    if GetPlayer <> Self then NextDay;
    RefreshDerivedStats(True);
  end;
  if (Ship.Order = soFollowShip) and ((Ship.OrderTarget as TShip) = Self) then begin
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
    if Other is TTranclucator then begin
      if (Other as TTranclucator).OwnerShip = Self then Other.TruceWithShip(Ship);
      if (Other as TTranclucator).OwnerShip = Ship then Other.TruceWithShip(Self);
    end;
  end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do begin
    Missile := CurrentStar.Missiles[I];
    if (Missile.OwnerShip = Self) and (Missile.Target = Ship) then Missile.Target := nil;
    if (Missile.OwnerShip = Ship) and (Missile.Target = Self) then Missile.Target := nil;
  end;
end;
{ @end $75C22C }

{ @routine $75C634 TShip_RequestAlliesAttackShip }
procedure TShip.RequestAlliesAttackShip(Target: TShip);
var I, Requests: Integer; Other: TShip; Response: WideString;
begin
  if Target.InNormalSpace then
    if Max(GetRadarRange * GetRadarRange, 250000) >= PointDistanceSquared(Position, Target.Position) then begin
      if TypeId = stRanger then (Self as TRanger).AddWarriorCareerActivity(1);
      Requests := 0;
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Other := CurrentStar.Ships[I];
        if (Other <> Self) and (Other <> Target) and Other.InNormalSpace and
          not (Other.TypeId in NonNegotiatingShipTypes) and (Other.OrderTarget <> Target) and
          ((Other.EnemyShip = nil) or (Other.EnemyShip.CurrentStar <> CurrentStar)) and
          (Other.GetRelationLevelToShip(Self) >= rlGood) and ((GetPlayer <> Other) or (GetRelationLevelToShip(Other) >= rlGood)) and
          ((Other.GetRelationLevelToShip(Target) <= rlNormal) or ((Other is TPirate) and (Self is TPirate))) and
          not (Other.TargetingRestriction in [1, 2]) and not (Target.TargetingRestriction in [1, 2]) and CanContactShip(Other) and
          (Other.PartnerShip <> Target) and (Target.PartnerShip <> Other) and (NextRandomUnitFloat(RandomState) <= 0.9) and
          (not (Other is TWarrior) or ((Other as TWarrior).WarriorType <> wtFlagship)) and
          ((GetPlayer <> Other) or (CurrentStar.ControlFaction <> sfCoalition) or (CurrentStar.Status.CustomFaction <> '') or
            (TypeId <> stWarrior) or (GetPlayer.OwnerId <> oiPirate) or not (Target is TNormalShip) or
            (not (Target.TypeId in [stTransport, stWarrior]) and ((Target.TypeId <> stRanger) or (Target.GetDominantCareer = rcPirate)))) and
          ((GetPlayer <> Other) or (CurrentStar.ControlFaction <> sfPirates) or (CurrentStar.Status.CustomFaction <> '') or
            (TypeId <> stPirate) or (OwnerId <> oiPirate) or (GetPlayer.OwnerId = oiPirate) or not (Target is TNormalShip) or (Target.OwnerId <> oiPirate)) then begin
          if (GetPlayer = Other) and not PlayerAutomaticControl then begin
            if Cardinal(ReservedMessageCounter) < 7 then Continue;
            ReservedMessageCounter := 0;
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
    end;
end;
{ @end $75C634 }

{ @routine $75CA70 TShip_IsInPrison }
function TShip.IsInPrison: Boolean;
begin
  if GetPlayer = Self then
  begin
    Result := GetPlayer.InPrison;
    Exit;
  end;
  case TypeId of
    stRanger: if Cardinal((Self as TRanger).PrisonTermRemaining) > 0 then
       begin Result := True; Exit; end;
    stPirate: if Cardinal((Self as TPirate).PrisonTermRemaining) > 0 then
       begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $75CA70 }

{ @routine $75CAE8 TShip_GetPrisonTermRemaining }
function TShip.GetPrisonTermRemaining: Integer;
begin
  Result := 0;
  case TypeId of
    stRanger: Result := (Self as TRanger).PrisonTermRemaining;
    stPirate: Result := (Self as TPirate).PrisonTermRemaining;
  end;
end;
{ @end $75CAE8 }

{ @routine $75CB40 TShip_ClearPrisonTerm }
procedure TShip.ClearPrisonTerm;
begin
  case TypeId of
    stRanger: (Self as TRanger).PrisonTermRemaining := 0;
    stPirate: (Self as TPirate).PrisonTermRemaining := 0;
  end;
end;
{ @end $75CB40 }

{ @routine $75CB8C TShip_GetPrisonReleaseCost }
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
{ @end $75CB8C }

{ @routine $75CBF4 TShip_GetLocationGoodsEntry }
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
{ @end $75CBF4 }

{ @routine $75CEA0 TShip_ShopGoodsPurchasePrice }
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
{ @end $75CEA0 }

{ @routine $75D0E8 TShip_ShopGoodsSellPrice }
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
  Result := Max(1, Round(TradingSkillSalePercent[GetEffectiveSkillLevel(psTrading)] *
    (Entry.PurchasePrice - Entry.BaseSalePrice) * 0.01 + Entry.BaseSalePrice));
end;
{ @end $75D0E8 }

{ @routine $75D390 TShip_GetAverageCargoCost }
function TShip.GetAverageCargoCost(Good: Byte): Double;
begin
  if CargoGoods[Good].Count > 0 then Result := CargoGoods[Good].TotalCost / CargoGoods[Good].Count
  else Result := 0;
end;
{ @end $75D390 }

{ @routine $75D3E0 TShip_ConsumeCargoGoods }
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
{ @end $75D3E0 }

{ @routine $75D45C TShip_IsCargoGoodIllegalOnCurrentPlanet }
function TShip.IsCargoGoodIllegalOnCurrentPlanet(Good: Byte): Boolean;
begin
  Result := False;
  if (CurrentPlanet <> nil) and not CurrentPlanet.IsMainPiratePlanet then
    if CurrentPlanet.OwnerId = oiPirate then Result := False
    else if not GoodsLegalOnPlanet[Good, CurrentPlanet.RaceId, CurrentPlanet.Government] then Result := True
    else if (Good in [Ord(t_Food)..Ord(t_Medicine)]) and IsHealthEffectActive(12) then Result := True;
end;
{ @end $75D45C }

{ @routine $75D4F4 TShip_SellGoodsToLocation }
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
  Illegal := ScriptItemsAct(satOnShipSellsGoods, TradeGoodsSold, TradeGoodsCostBasis, Ord(Illegal)) <> 0;
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
        if (Self is TNormalShip) and (OwnerId = oiPirate) and Illegal then
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
        ExperienceFactor := 0.0001 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].GoodsEventDurationFactor * Max(0, (Self as TPlayer).CareerStatus[rcTrader] - 50);
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
{ @end $75D4F4 }

{ @routine $75DBA8 TShip_BuyGoodsFromLocation }
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
    Illegal := ScriptItemsAct(satOnShipBuysGoods, TradeGoodsSold, nil, Ord(Illegal)) <> 0;
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
{ @end $75DBA8 }

{ @routine $75DE84 TShip_ProcessLiberationGroupRoute }
procedure TShip.ProcessLiberationGroupRoute;
var Destination: TPointF; I: Integer; Ship: TShip; RouteOrder: TGroupRouteOrder;
begin
  if LiberationGroup = nil then Exit;
  RouteOrder := (LiberationGroup as TGroup).Route[LiberationGroupRouteIndex];
  case RouteOrder.Kind of
  soJump: begin
    if IsOutsideStarSpace then Exit;
    if CurrentStar = RouteOrder.Target then begin
      Inc(LiberationGroupRouteIndex);
      if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
      ProcessLiberationGroupRoute;
      Exit;
    end;
    if (Order = soNone) or (Order = soFollowShip) then OrderJump(RouteOrder.Target as TStar, False);
  end;
  soLand: begin
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
    if (Order = soNone) or (Order = soFollowShip) then OrderLanding(RouteOrder.Target, False);
  end;
  soMove: begin
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
    if (PointDistance(Position, RouteOrder.Destination) < 300) and (RouteOrder.WaitMode in [GroupWaitArrival]) then begin
      Inc(LiberationGroupRouteIndex);
      if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
      Exit;
    end;
    if (RouteOrder.WaitMode in [GroupWaitAssembly]) and (LiberationGroup as TGroup).AreShipsAssembled then begin
      (LiberationGroup as TGroup).AdvanceRouteForShips;
      Exit;
    end;
    if (RouteOrder.WaitMode in [GroupWaitUntilTurn]) and ((LiberationGroup as TGroup).Route[LiberationGroupRouteIndex].WaitUntilTurn <= Galaxy.CurrentTurn) then begin
      Inc(LiberationGroupRouteIndex);
      if LiberationGroupRouteIndex >= Length((LiberationGroup as TGroup).Route) then LeaveLiberationGroup;
      ProcessLiberationGroupRoute;
      Exit;
    end;
    if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace and
      (RouteOrder.WaitMode in [GroupWaitUntilTurn]) and ((LiberationGroup as TGroup).Route[LiberationGroupRouteIndex].WaitUntilTurn > Galaxy.CurrentTurn + 7) then begin
      for I := 0 to CurrentStar.Ships.Count - 1 do begin
        Ship := CurrentStar.Ships[I];
        if Ship.InNormalSpace and (Ship.LiberationGroup = LiberationGroup) and (Ship.EnemyShip = nil) and
          (Ship.TruceShip <> EnemyShip) and (Ship.LiberationGroupRouteIndex = LiberationGroupRouteIndex) then Ship.EnemyShip := EnemyShip;
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
{ @end $75DE84 }

{ @routine $75E3F4 TShip_LeaveLiberationGroup }
procedure TShip.LeaveLiberationGroup;
begin
  (TObject(LiberationGroup) as TGroup).Ships.Delete((TObject(LiberationGroup) as TGroup).Ships.IndexOf(Self));
  LiberationGroup := nil;
  LiberationGroupRouteIndex := 0;
end;
{ @end $75E3F4 }

{ @routine $75E454 CompareShipGroupsStrength }
function CompareShipGroupsStrength(Ships, Opponents: TList): Single;
var I, J, ShipCount, Count: Integer; Ship, Target: TShip; Sum, Chance: Single;
begin
  ShipCount := Ships.Count;
  Count := Opponents.Count;
  Result := 0;
  for I := 0 to ShipCount - 1 do begin
    Ship := TShip(Ships[I]);
    Sum := 0;
    for J := 0 to Count - 1 do begin
      Target := TShip(Opponents[J]);
      Chance := Ship.ChanceToWin(Target);
      Sum := Sum + Chance;
    end;
    Result := Sum / Count / Count + Result;
  end;
end;
{ @end $75E454 }

{ @routine $75E500 CreateShipByType }
function CreateShipByType(ShipType: Byte): TShip;
begin
  Result := nil;
  case ShipType of
    1: Result := TRanger.Create;
    0: Result := TKling.Create;
    2: Result := TTransport.Create;
    3: Result := TPirate.Create;
    4: Result := TWarrior.Create;
    5: Result := TTranclucator.Create;
    6..13: Result := TRuins.Create;
  else
    // The original constructs the exception without raising it.
    Exception.Create('function CreateShipByType(shiptype: tShipType): TShip;');
  end;
end;
{ @end $75E500 }

{ @routine $75E62C TShip_GetHull }
function TShip.GetHull: THull;
begin
  Result := Self.Hull;
  Exit;
end;
{ @end $75E62C }

{ @routine $75E648 TShip_GetFuelTanks }
function TShip.GetFuelTanks: TFuelTanks;
begin
  Result := FuelTanks;
end;
{ @end $75E648 }

{ @routine $75E664 TShip_GetEngine }
function TShip.GetEngine: TEngine;
begin
  Result := Engine;
end;
{ @end $75E664 }

{ @routine $75E680 TShip_GetRadar }
function TShip.GetRadar: TRadar;
begin
  Result := Radar;
end;
{ @end $75E680 }

{ @routine $75E69C TShip_GetScanner }
function TShip.GetScanner: TScaner;
begin
  Result := Scanner;
end;
{ @end $75E69C }

{ @routine $75E6B8 TShip_GetRepairRobot }
function TShip.GetRepairRobot: TRepairRobot;
begin
  Result := RepairRobot;
end;
{ @end $75E6B8 }

{ @routine $75E6D4 TShip_GetCargoHook }
function TShip.GetCargoHook: TCargoHook;
begin
  Result := CargoHook;
end;
{ @end $75E6D4 }

{ @routine $75E6F0 TShip_GetDefGenerator }
function TShip.GetDefGenerator: TDefGenerator;
begin
  Result := DefGenerator;
end;
{ @end $75E6F0 }

{ @routine $75E70C TShip_CanRepairArtefactsAtLocation }
function TShip.CanRepairArtefactsAtLocation: Boolean;
begin
  if TypeId in [Ord(rstPirateBase), Ord(rstScienceBase)] then begin Result := True; Exit; end;
  if (TypeNameOverrideKey <> '') and (FindTextOffsetW(TypeNameOverrideKey, '_licensed') >= 0) then begin Result := True; Exit; end;
  if (CurrentPlanet <> nil) and CurrentPlanet.IsMainPiratePlanet then begin Result := True; Exit; end;
  if DockedTo = nil then Result := False
  else Result := DockedTo.CanRepairArtefactsAtLocation;
end;
{ @end $75E70C }

{ @routine $75E7B0 TShip_CanUseEquipmentTech }
function TShip.CanUseEquipmentTech(Item: TEquipment): Boolean;
var
  Level: Integer;
begin
  if (Galaxy = nil) or Galaxy.IsEquipmentKnowledgeUnrestricted then Result := True
  else if (Self is TTranclucator) and (TTranclucator(Self).OwnerShip <> nil) then
    Result := TTranclucator(Self).OwnerShip.CanUseEquipmentTech(Item)
  else if (Self is TKling) or (Item.OwnerId <> oiDominator) then Result := True
  else
  begin
    if Item is TWeapon then Level := TWeapon(Item).GetWeaponInfo.TechLevel
    else Level := Item.GetLevel;
    Dec(Level, 4);
    Result := TechKnowledge >= Level;
  end;
end;
{ @end $75E7B0 }

{ @routine $75E880 TShip_CanRepairEquipmentTech }
function TShip.CanRepairEquipmentTech(Item: TEquipment): Boolean;
var
  Level: Integer;
begin
  if (Galaxy = nil) or Galaxy.IsEquipmentKnowledgeUnrestricted then Result := True
  else if (Self is TTranclucator) and (TTranclucator(Self).OwnerShip <> nil) then
    Result := TTranclucator(Self).OwnerShip.CanRepairEquipmentTech(Item)
  else if (Item is THull) or (Self is TKling) or (Item.OwnerId <> oiDominator) then Result := True
  else
  begin
    Level := Item.GetLevel;
    if Item is TWeapon then Level := Max(Level, TWeapon(Item).GetWeaponInfo.TechLevel);
    Dec(Level, 2);
    Result := TechKnowledge >= Level;
  end;
end;
{ @end $75E880 }

{ @routine $75E980 TShip_IsEquipmentUsable }
function TShip.IsEquipmentUsable(Item: TEquipment): Boolean;
begin
  Result := (Item <> nil) and
    ((not (Item.ItemType in [t_FuelTanks..t_CustomWeapon, t_Satellite])) or (Item.BrokenFlag = 0)) and CanUseEquipmentTech(Item);
end;
{ @end $75E980 }

{ @routine $75E9CC TShip_EquipItem }
procedure TShip.EquipItem(Item: TEquipment);
begin
  if Item.ItemType in [t_Hull..t_DefGenerator] then
  begin
    if PShipEquipmentCacheView(Self).Slots[Item.ItemType] <> nil then
      PShipEquipmentCacheView(Self).Slots[Item.ItemType].Unequip;
    PShipEquipmentCacheView(Self).Slots[Item.ItemType] := Item;
  end
  else if Item.ItemType in [t_Weapon1..t_CustomWeapon] then
  begin
    if WeaponCount < 5 then Inc(WeaponCount);
    if Weapons[WeaponCount] <> nil then Weapons[WeaponCount].Unequip;
    Weapons[WeaponCount] := Item as TWeapon;
  end;
  Item.Equip;
end;
{ @end $75E9CC }

{ @routine $75EA9C TShip_UnequipSlot }
procedure TShip.UnequipSlot(ItemType: TItemType; WeaponIndex: Integer);
var
  I: Integer;
begin
  if ItemType in [t_Hull..t_DefGenerator] then
  begin
    PShipEquipmentCacheView(Self).Slots[ItemType].Unequip;
    PShipEquipmentCacheView(Self).Slots[ItemType] := nil;
  end
  else if ItemType in [t_Weapon1..t_CustomWeapon] then
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
{ @end $75EA9C }

{ @routine $75EB74 TShip_UnequipItem }
procedure TShip.UnequipItem(Item: TEquipment);
var
  I: Integer;
begin
  if Item is TWeapon then
  begin
    for I := 1 to CountEquippedWeapons do
      if Weapons[I] = Item then
      begin
        UnequipSlot(t_Weapon1, I);
        Break;
      end;
  end
  else if (Item.ItemType in [t_Hull..t_DefGenerator]) and
    (PShipEquipmentCacheView(Self).Slots[Item.ItemType] = Item) then UnequipSlot(Item.ItemType, 0);
end;
{ @end $75EB74 }

{ @routine $75EC0C TShip_CalculateMass }
function TShip.CalculateMass: Integer;
var
  Mass: Double;
  Bonus, I: Integer;
begin
  Mass := GetHull.Weight - CargoFreeSpace + GetHull.CalculateMass;
  if Artefacts.Count > 0 then
    for I := 1 to CountActiveArtefacts(t_ArtefactAntigrav) do
      Mass := Mass * (AntigravityArtefactMassFactor + AntigravityArtefactBoostFactor * ShortInt(CanBoostArtefact(t_ArtefactAntigrav, nil, False)));
  if (PilotRace = oiMaloc) and IsHealthEffectActive(9) then Mass := Mass * 1.2;
  Bonus := GetTotalStatBonus(bonMass);
  if GetHull.MicroModuleIndex <> 0 then Inc(Bonus, MicroModuleTemplates[GetHull.MicroModuleIndex - 1].StatBonuses[bonMass]);
  Mass := Mass * (1 + Bonus / 100);
  Result := Round(Mass);
end;
{ @end $75EC0C }

{ @routine $75ED40 TShip_CalculateEquippedMass }
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
    Item := TEquipment(Inventory[I]);
    if Item.EquippedFlag <> 0 then Mass := Mass + Item.Weight;
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := TEquipment(Artefacts[I]);
    if Item.EquippedFlag <> 0 then Mass := Mass + Item.Weight;
  end;
  Bonus := GetTotalStatBonus(bonMass);
  if (ItemForModule <> nil) and (ItemForModule.SpecialModuleIndex <> 0) then
    Inc(Bonus, MicroModuleTemplates[ItemForModule.SpecialModuleIndex - 1].StatBonuses[bonMass]);
  Mass := Mass * (1 + Bonus / 100);
  if Artefacts.Count > 0 then
    for I := 1 to CountActiveArtefacts(t_ArtefactAntigrav) do
      Mass := Mass * (AntigravityArtefactMassFactor + AntigravityArtefactBoostFactor * ShortInt(CanBoostArtefact(t_ArtefactAntigrav, nil, False)));
  Result := Round(Mass);
end;
{ @end $75ED40 }

{ @routine $75EEC0 TShip_GetHullIntegrityPercent }
function TShip.GetHullIntegrityPercent: TPercent;
begin
  Result := Round(GetHull.HullPoints / GetHull.Weight * 100);
end;
{ @end $75EEC0 }

{ @routine $75EF04 TShip_GetArmor }
function TShip.GetArmor: Integer;
begin
  Result := CalculateHullArmor(GetHull) - Integer(Round(GetCombatStatusStrength(cseAcid)));
  Result := Max(0, Result);
end;
{ @end $75EF04 }

{ @routine $75EF58 TShip_GetJumpDestinationDistance }
function TShip.GetJumpDestinationDistance: Integer;
begin
  if Order = soJump then Result := Trunc(PointDistance(CurrentStar.Position, (OrderTarget as TStar).Position))
  else Result := 0;
end;
{ @end $75EF58 }

{ @routine $75EFA8 TShip_GetFullRefuelCost }
function TShip.GetFullRefuelCost: Integer;
begin
  if GetFuelTanks <> nil then
  begin
    if CurrentPlanet <> nil then Result := Round(CalculateFuelCost(GetFuelTanks.Capacity - GetFuelTanks.Fuel, CurrentPlanet.OwnerId))
    else Result := Round(CalculateFuelCost(GetFuelTanks.Capacity - GetFuelTanks.Fuel, oiUninhabited));
  end
  else Result := 0;
end;
{ @end $75EFA8 }

{ @routine $75F034 CalculateFuelCost }
function CalculateFuelCost(Amount: Integer; OwnerId: TOwnerId): Single;
var Value: Single; BaseCost: Integer;
begin
  BaseCost := Amount;
  Value := BaseCost;
  Value := Value * RemapClamped(Galaxy.CurrentTurn, 1000, 15000, 1, 10);
  if OwnerId <> oiUninhabited then Value := Value * OwnerInfo[OwnerId].FuelPriceFactor;
  Value := Value * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor;
  Result := Value;
end;
{ @end $75F034 }

{ @routine $75F0D4 CalculateRoundedFuelCost }
function CalculateRoundedFuelCost(Amount: Integer; OwnerId: TOwnerId): Integer;
begin
  Result := Round(CalculateFuelCost(Amount, OwnerId));
end;
{ @end $75F0D4 }

{ @routine $75F0FC TShip_GetAfterburnerWear }
function TShip.GetAfterburnerWear: Integer;
var
  I, Count: Integer;
  Factor, Wear: Single;
begin
  if GetEngine <> nil then
    Result := SeededRandomIntRange(OwnerInfo[GetEngine.OwnerId].MinimumAfterburnerWear, OwnerInfo[GetEngine.OwnerId].MaximumAfterburnerWear, Galaxy.CurrentTurn)
  else Result := 1;
  Count := CountActiveArtefacts(t_ArtForsage);
  if Count <> 0 then
  begin
    Factor := AfterburnerArtefactWearFactor;
    if CanBoostArtefact(t_ArtForsage, nil, False) then Factor := Factor + AfterburnerArtefactBoostWearFactor;
    Wear := Result;
    for I := 1 to Count do Wear := Wear * Factor;
    Result := Round(Wear);
  end;
end;
{ @end $75F0FC }

{ @routine $75F1DC TShip_GetFuelLimitedJumpRange }
function TShip.GetFuelLimitedJumpRange: Integer;
begin
  if (GetFuelTanks = nil) or not CanUseEquipmentTech(GetFuelTanks) or (GetEngine = nil) or not CanUseEquipmentTech(GetEngine) then
  begin Result := 0; Exit; end;
  Result := Min(GetFuelTanks.Fuel + GetOwnStatBonus(bonFuel), GetJumpRange);
end;
{ @end $75F1DC }

{ @routine $75F27C TShip_GetJumpRange }
function TShip.GetJumpRange: Integer;
begin
  if GetEngine = nil then begin Result := 0; Exit; end;
  if GetEngine.BrokenFlag <> 0 then Result := Round(CalculateEngineJumpRange(GetEngine) * 0.6)
  else Result := CalculateEngineJumpRange(GetEngine);
end;
{ @end $75F27C }

{ @routine $75F2F8 TShip_IsMicroModuleRaciallyRestricted }
function TShip.IsMicroModuleRaciallyRestricted(ModuleIndex: Integer): Boolean;
const
  AllSeries = [Ord(dsBlazer)..Ord(dsTerron)];
  PlanetOwners = [oiMaloc..oiGaal];
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
    if (Self is TKling) and (oiDominator in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) and
      (Byte((Self as TKling).DominatorSeries) in MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) then Exit;
    if ((Self is TNormalShip) or (Self is TRuins)) and
      ((RaceToOwner(PilotRace) in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) or
       ((OwnerId = oiPirate) and (oiPirate in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask))) then Exit;
    if not (Self is TKling) and
      (MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * PlanetOwners = NoOwners) and
      (OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Exit;
    if (Self is TTranclucator) and (oiUninhabited in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Exit;
    Result := True;
  end;
end;
{ @end $75F2F8 }

{ @routine $75F5C4 TShip_GetEquipmentStatBonus }
function TShip.GetEquipmentStatBonus(BonusKind: TEquipmentBonusKind; Item: TEquipment): Integer;
begin
  if (Item.SpecialModuleIndex <> 0) and
     IsMicroModuleRaciallyRestricted(Item.SpecialModuleIndex - 1) then Result := 0
  else Result := Item.GetStatBonus(BonusKind);
end;
{ @end $75F5C4 }

{ @routine $75F60C TShip_GetTotalStatBonus }
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
  Strength := Round(GetCombatStatusStrength(cseMagnetic));
  if Strength >= 1 then
    case BonusKind of
      bonScan, bonDef: Dec(Result, Strength);
      bonWRadius: Dec(Result, Strength * 10);
      bonRadar: Dec(Result, Strength * 100);
    end;
end;
{ @end $75F60C }

{ @routine $75F744 TShip_GetRadarRange }
function TShip.GetRadarRange: Integer;
begin
  if not IsEquipmentUsable(GetRadar) then Result := 0 else Result := CalculateRadarRange(GetRadar);
  if GetPlayer = Self then
  begin
    if IsHealthEffectActive(21) then Result := Result * 2;
    if Galaxy.UltraScanModEnabled <> 0 then Result := Max(Result, 25000);
  end;
end;
{ @end $75F744 }

{ @routine $75F7D8 TShip_GetScannerPower }
function TShip.GetScannerPower: Integer;
begin
  Result := 0;
  if IsEquipmentUsable(GetScanner) then Result := CalculateScannerPower(GetScanner) + 12 * Ord(IsHealthEffectActive(21));
end;
{ @end $75F7D8 }

{ @routine $75F834 TShip_CanResolveObjectWithScanner }
function TShip.CanResolveObjectWithScanner(Target: TObject): Boolean;
begin
  if not IsEquipmentUsable(GetScanner) then begin Result := False; Exit; end;
  if Target is TShip then
  begin
    if GetPlayer = Self then
      if ((Target as TShip).PartnerShip = GetPlayer) or ((Target as TShip).TypeId = stTranclucator) or ((Target as TShip) = Self) then
      begin Result := True; Exit; end;
    Result := (Target as TShip).GetDefensePercent <= GetScannerPower;
  end
  else Result := True;
end;
{ @end $75F834 }

{ @routine $75F8FC TShip_ApplyRepairDroidHealing }
procedure TShip.ApplyRepairDroidHealing;
var
  Repair: Integer;
begin
  if not IsEquipmentUsable(GetRepairRobot) then Exit;
  if (TypeId = stKling) and (Self as TKling).IsProgramActive(prgDisconnection) then Exit;
  if NextRandomUnitFloat(RandomState) + 0.01 >= GetCombatStatusStrength(cseDroidBlock) then
  begin
    Repair := CalculateRepairPoints(GetRepairRobot);
    Repair := ScriptItemsAct(satOnDroidRepair, nil, nil, Repair);
    if TypeId <> stKling then
    begin
      if CountActiveArtefacts(t_ArtefactDroid) > 0 then
      begin
        if CanBoostArtefact(t_ArtefactDroid, nil, False) then
          ApplyItemDegradation(GetRepairRobot, idkUse, NextRandomUnitFloat(RandomState) * 2 *
            (1 + CountActiveArtefacts(t_ArtefactDroid) * (DroidArtefactWear + DroidArtefactBoostWear)))
        else
          ApplyItemDegradation(GetRepairRobot, idkUse, NextRandomUnitFloat(RandomState) * 2 *
            (1 + CountActiveArtefacts(t_ArtefactDroid) * DroidArtefactWear));
      end
      else ApplyItemDegradation(GetRepairRobot, idkUse, NextRandomUnitFloat(RandomState) * 2);
    end;
  end
  else if CountActiveArtefacts(t_ArtefactDroid) > 0 then
    Repair := CountActiveArtefacts(t_ArtefactDroid) * (DroidArtefactRepair + DroidArtefactBoostRepair * Byte(CanBoostArtefact(t_ArtefactDroid, nil, False)))
  else Exit;
  if Repair > 0 then Inc(GetHull.HullPoints, Min(Repair, GetHull.Weight - GetHull.HullPoints));
end;
{ @end $75F8FC }

{ @routine $75FB54 TShip_GetCargoHookMinPullSpeed }
function TShip.GetCargoHookMinPullSpeed: Single;
begin
  Result := 0;
  if GetCargoHook <> nil then
    Result := Max(0.1, GetCargoHook.MinPullSpeed + CountActiveArtefacts(t_ArtefactHook) * (CargoHookArtefactSpeed + CargoHookArtefactBoostSpeed * Byte(CanBoostArtefact(t_ArtefactHook, nil, False))) + GetTotalStatBonus(bonHookMinSpeed));
end;
{ @end $75FB54 }

{ @routine $75FC30 TShip_GetCargoHookMaxPullSpeed }
function TShip.GetCargoHookMaxPullSpeed: Single;
begin
  Result := 0;
  if GetCargoHook <> nil then
    Result := Max(0.1, GetCargoHook.MaxPullSpeed + CountActiveArtefacts(t_ArtefactHook) * (CargoHookArtefactSpeed + CargoHookArtefactBoostSpeed * Byte(CanBoostArtefact(t_ArtefactHook, nil, False))) + GetTotalStatBonus(bonHookMaxSpeed));
end;
{ @end $75FC30 }

{ @routine $75FD0C TShip_GetCargoHookRange }
function TShip.GetCargoHookRange: Integer;
begin
  Result := 0;
  if GetCargoHook <> nil then
    Result := GetCargoHook.Range + CountActiveArtefacts(t_ArtefactHook) * (CargoHookArtefactRange + CargoHookArtefactBoostRange * Byte(CanBoostArtefact(t_ArtefactHook, nil, False))) + GetTotalStatBonus(bonHookRadius);
end;
{ @end $75FD0C }

{ @routine $75FD78 TShip_GetCargoHookRangeSquared }
function TShip.GetCargoHookRangeSquared: Integer;
begin
  Result := Sqr(GetCargoHookRange);
end;
{ @end $75FD78 }

{ @routine $75FD98 TShip_GetBaseCargoHookPower }
function TShip.GetBaseCargoHookPower: Integer;
begin
  if GetCargoHook <> nil then Result := GetCargoHook.PickupPower
  else Result := 0;
end;
{ @end $75FD98 }

{ @routine $75FDCC TShip_GetDefenseDamageFactor }
function TShip.GetDefenseDamageFactor: Double;
begin
  if not IsEquipmentUsable(GetDefGenerator) then begin Result := 1; Exit; end;
  Result := CalculateDefGeneratorFactor(GetDefGenerator);
end;
{ @end $75FDCC }

{ @routine $75FE18 TShip_GetDefensePercent }
function TShip.GetDefensePercent: TPercent;
begin
  Result := DefenseDamageFactorToPercent(GetDefenseDamageFactor);
end;
{ @end $75FE18 }

{ @routine $75FE40 TShip_GetAttackMultiplier }
function TShip.GetAttackMultiplier: Integer;
begin
  Result := Max(0, 1 + GetOwnStatBonus(bonAttacks));
end;
{ @end $75FE40 }

{ @routine $75FE78 TShip_AddAward }
procedure TShip.AddAward(AwardId: Byte);
begin
  if AwardId = AwardNotFound then RaiseWideMessage('Error RewardNumber=255');
  if AwardIds = nil then AwardIds := TList.Create;
  if AwardIds.Count = 255 then Exit;
  if AwardIds.Count = AwardVisibleCount then Inc(AwardVisibleCount);
  AwardIds.Add(Pointer(AwardId));
  if GetPlayer = Self then GetPlayer.AchievementStats.CheckAllAwardsAchievement;
end;
{ @end $75FE78 }

{ @routine $75FF4C TShip_RefreshDerivedStats }
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
{ @end $75FF4C }

{ @routine $7600C4 TShip_RefreshGraphicSize }
procedure TShip.RefreshGraphicSize;
var
  Size, Small, Large: Integer;
  Kind: Byte;
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
  else if (GetHull.HullType = htSpecial) and not ChameleonActive then
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
      Kind := Ord((Self as TKling).KlingType);
      Series := (Self as TKling).DominatorSeries;
    end;
    Small := DominatorShipSmallSizes[Ord(Series), Kind];
    Large := DominatorShipLargeSizes[Ord(Series), Kind];
  end
  else if Self is TRuins then
  begin
    Small := StationSize;
    Large := StationSize;
  end
  else if (Self is TPirate) and (OwnerId = oiPirate) and ((Self as TPirate).PirateType <> 0) then
  begin
    Small := PirateClanSmallSizes[GetHull.OwnerId];
    Large := PirateClanLargeSizes[GetHull.OwnerId];
  end
  else if (Self is TWarrior) and ((Self as TWarrior).WarriorType = wtFlagship) then
  begin
    Small := BigWarriorSmallSizes[GetHull.OwnerId];
    Large := BigWarriorLargeSizes[GetHull.OwnerId];
  end
  else
    case GetHull.HullType of
      htRanger: begin Small := RangerSmallSizes[GetHull.OwnerId]; Large := RangerLargeSizes[GetHull.OwnerId]; end;
      htTransport..htDiplomat: begin Small := TransportSmallSizes[GetHull.HullType, GetHull.OwnerId]; Large := TransportLargeSizes[GetHull.HullType, GetHull.OwnerId]; end;
      htPirate: begin Small := PirateSmallSizes[GetHull.OwnerId]; Large := PirateLargeSizes[GetHull.OwnerId]; end;
      htWarrior: begin Small := WarriorSmallSizes[GetHull.OwnerId]; Large := WarriorLargeSizes[GetHull.OwnerId]; end;
    else
      Small := DefaultShipSmallSize;
      Large := DefaultShipLargeSize;
    end;
  if (GetHull.HullType = htSpecial) and (GetHull.SpecialModuleIndex <> 0) and not ChameleonActive and not ScriptChameleon then
  begin
    Small := Round(Small * MicroModuleTemplates[GetHull.SpecialModuleIndex - 1].HullGraphSizePercent * 0.01);
    Large := Round(Large * MicroModuleTemplates[GetHull.SpecialModuleIndex - 1].HullGraphSizePercent * 0.01);
  end;
  Size := Round(Ln(Max(1, GetHull.Weight / (HullBaseSize * EquipmentSizeFactors[5]))) * (Large - Small) /
    Ln(2 * EquipmentSizeFactors[1] / EquipmentSizeFactors[5]) + Small);
  if GiResourceVariant = 1 then Size := Round(Size * 0.78125);
  Graphic.SetSize(Classes.Point(Size, Size));
end;
{ @end $7600C4 }

{ @routine $7605F4 TShip_RebuildEquipmentCache }
procedure TShip.RebuildEquipmentCache;
var
  I: Integer;
  Item: TEquipment;
  Kind: TItemType;
begin
  Hull := THull(Inventory[0]);
  for Kind := t_FuelTanks to t_DefGenerator do PShipEquipmentCacheView(Self).Slots[Kind] := nil;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  UsableWeaponCount := 0;
  HasInactiveDirectEquipment := 0;
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := TEquipment(Inventory[I]);
    if (Item.EquippedFlag <> 0) and not (Item.ItemType in [t_FuelTanks..t_Engine]) and
       (GetSlotCountForItemType(Item.ItemType) <= 0) and
       (ItemTypeToSlotKind(Item.ItemType) <> sskUnsupported) then Item.EquippedFlag := 0;
    if Item.EquippedFlag <> 0 then
    begin
      if Item.ItemType in [t_Hull..t_DefGenerator] then PShipEquipmentCacheView(Self).Slots[Item.ItemType] := Item
      else if Item.ItemType in [t_Weapon1..t_CustomWeapon] then
      begin
        Inc(WeaponCount);
        Weapons[WeaponCount] := Item as TWeapon;
        if IsEquipmentUsable(Weapons[WeaponCount]) then Inc(UsableWeaponCount);
      end;
    end
    else if Item.ItemType in [t_Hull..t_DefGenerator] then HasInactiveDirectEquipment := 1;
  end;
  RemoveInvalidPickupTargets;
end;
{ @end $7605F4 }

{ @routine $76079C TShip_GetCargoFreeSpace }
function TShip.GetCargoFreeSpace: Integer;
begin
  Result := GetHull.Weight - GetCarriedItemWeight - GetCargoGoodsWeight;
end;
{ @end $76079C }

{ @routine $7607D0 TShip_GetCarriedItemWeight }
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
{ @end $7607D0 }

{ @routine $76086C TShip_GetCargoGoodsWeight }
function TShip.GetCargoGoodsWeight: Integer;
var
  Good: Byte;
begin
  Result := 0;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do Inc(Result, CargoGoods[Good].Count);
end;
{ @end $76086C }

{ @routine $7608A0 TShip_CalculateFollowRadius }
function TShip.CalculateFollowRadius: Integer;
var Mode: Byte; I: Integer; Target: TShip; Weapon: TWeapon;
begin
  if Order <> soFollowShip then raise Exception.Create('TShip.CalcFollowRadius()');
  Target := OrderTarget as TShip;
  Mode := Byte(OrderStateData);
  case Mode of
    1: begin
         Result := 999999;
         for I := 1 to WeaponCount do
         begin
           Weapon := Weapons[I];
           if IsEquipmentUsable(Weapon) and (GetWeaponRange(Weapon) < Result) then Result := GetWeaponRange(Weapon);
         end;
       end;
    2: begin
         Result := 0;
         for I := 1 to WeaponCount do
         begin
           Weapon := Weapons[I];
           if IsEquipmentUsable(Weapon) and (GetWeaponRange(Weapon) > Result) then Result := GetWeaponRange(Weapon);
         end;
       end;
  else Result := 999999;
  end;
  if (Result > 0) and (Result < 999999) then Result := Round(Result * 0.85)
  else Result := Trunc(CollisionRadius + Target.CollisionRadius) + 15;
end;
{ @end $7608A0 }

{ @routine $760A4C TShip_GetFollowMode }
function TShip.GetFollowMode: Byte;
begin
  if Order <> soFollowShip then raise Exception.Create('TShip.CalcFollowRadius()');
  Result := Byte(OrderStateData);
end;
{ @end $760A4C }

{ @routine $760AB0 TShip_GetEffectiveFollowMode }
function TShip.GetEffectiveFollowMode: Byte;
var Mode: Byte; BoundarySquared, DistanceSquared, TargetDistanceSquared: Single;
begin
  if Order <> soFollowShip then raise Exception.Create('TShip.GetRealFollowType()');
  Result := 0;
  Mode := Byte(OrderStateData);
  if (Mode in [0, 3]) or (WeaponCount <= 0) then Exit;
  if (GetPlayer <> Self) and (SeededRandomIntRange(0, 6, Seed + Galaxy.CurrentTurn) = 0) then Exit;
  BoundarySquared := Sqr(CurrentStar.MapDiameter / 2);
  DistanceSquared := Sqr(Position.X) + Sqr(Position.Y);
  TargetDistanceSquared := Sqr(TShip(OrderTarget).Position.X) + Sqr(TShip(OrderTarget).Position.Y);
  if (DistanceSquared > BoundarySquared) and (TargetDistanceSquared > DistanceSquared) then Exit;
  Result := Mode;
end;
{ @end $760AB0 }

{ @routine $760BE4 TShip_NeedsEquipmentType }
function TShip.NeedsEquipmentType(ItemType: TItemType): Boolean;
begin
  Result := False;
  if ((ItemType in [t_FuelTanks, t_Engine, t_RepairRobot, t_DefGenerator]) or (ItemType in [t_Weapon1..t_CustomWeapon])) and (CountCarriedEquipmentByType(ItemType) <= 0) then Result := True;
end;
{ @end $760BE4 }

{ @routine $760C28 TShip_CalculateEquippedItemCostWithoutHull }
function TShip.CalculateEquippedItemCostWithoutHull: Integer;
var I: Integer; Item: TEquipment; Artefact: TArtefact;
begin
  Result := 0;
  for I := 1 to Inventory.Count - 1 do begin
    Item := TEquipment(Inventory[I]);
    if Item.EquippedFlag <> 0 then Inc(Result, Item.Cost);
  end;
  for I := 0 to Artefacts.Count - 1 do begin
    Artefact := TArtefact(Artefacts[I]);
    if Artefact.EquippedFlag <> 0 then Inc(Result, Artefact.Cost);
  end;
end;
{ @end $760C28 }

{ @routine $760CD0 TShip_CountCarriedEquipmentByType }
function TShip.CountCarriedEquipmentByType(ItemType: TItemType): Integer;
var
  I: Integer;
  Item: TItem;
begin
  Result := 0;
  if ItemType in [t_Hull..t_CustomWeapon] then
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item.ItemType = ItemType) or ((ItemType in [t_Weapon1..t_CustomWeapon]) and (Item.ItemType in [t_Weapon1..t_CustomWeapon])) then Inc(Result);
    end;
end;
{ @end $760CD0 }

{ @routine $760D4C TShip_SelectBestUnequippedWeapon }
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
    if (Candidate.ItemType in [t_Weapon1..t_CustomWeapon]) and (Candidate.EquippedFlag = 0) then
      if Result = nil then Result := Candidate as TWeapon
      else
      begin
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
{ @end $760D4C }

{ @routine $760ED8 TShip_HasLooseNonScriptItemsOrGoods }
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
{ @end $760ED8 }

{ @routine $760FC4 TShip_DropUnequippedItemsAndGoods }
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
{ @end $760FC4 }

{ @routine $7610A8 TShip_AddItemToPlayerStorage }
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
  if Item is TEquipmentWithActCode then RunItemConfigActionCode(Item, satOnMovingItemToStorage, nil, Item, Location, 0);
  if Item.ScriptItem <> nil then TScriptItem(Item.ScriptItem).RunActionCode(satOnMovingItemToStorage, nil, Item, Location, 0);
  ScriptItemsAct(satOnMovingItemToStorage, Item, Location, 0);
end;
{ @end $7610A8 }

{ @routine $7611A0 TShip_MergeItemIntoPlayerStorage }
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
  end else if Item.ItemType in [t_Food..t_Narcotics] then begin
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
{ @end $7611A0 }

{ @routine $761350 TShip_AddGoodsToPlayerStorage }
procedure TShip.AddGoodsToPlayerStorage(Good: Byte; Quantity, Cost: Integer; Location: TObject; Slot: Integer);
var Index, Occupant: Integer; Entry: PStorageEntry;
begin
  if Quantity > 0 then begin
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
      ScriptItemsAct(satOnMovingItemToStorage, Entry.Item, Location, 0);
    end;
  end;
end;
{ @end $761350 }

{ @routine $76150C TShip_StoreLooseInventoryAt }
function TShip.StoreLooseInventoryAt(Location: TObject): Boolean;
var I: Integer; Good: TItemType; Item: TEquipment; Artefact: TArtefact; Goods: TGoods;
begin
  Result := False;
  if Location <> nil then
    if not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [oiMaloc..oiGaal, oiPirate]) then begin
      for I := Inventory.Count - 1 downto 0 do begin
        Item := Inventory[I];
        if (Item.NoDropFlag <= 0) and (Item.EquippedFlag = 0) and (Item.ItemType <> t_Hull) and GetPlayer.CanAccessStoredItem(Item) then begin
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
      for Good := t_Food to t_Narcotics do
        if (CargoGoods[Ord(Good)].Count > 0) and GetPlayer.CanAccessHoldGoods(Byte(Good)) then begin
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
{ @end $76150C }

{ @routine $7616F4 TShip_RetrieveStoredItems }
function TShip.RetrieveStoredItems(Location: TObject): Boolean;
var I, J: Integer; Item: TItem; Entry: PStorageEntry; Stack: TCountableItem;
begin
  Result := False;
  if Location <> nil then
    if not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [oiMaloc..oiGaal, oiPirate]) then begin
      for I := GetPlayer.StorageEntries.Count - 1 downto 0 do begin
        Entry := GetPlayer.StorageEntries[I];
        if (Entry.LocationOwner <> Location) or (Entry.Item.ItemType = t_Hull) then Continue;
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
end;
{ @end $7616F4 }

{ @routine $761AB8 TShip_AutoEquipArtefacts }
procedure TShip.AutoEquipArtefacts;
const
  EnergyFlags = [dkEnergy];
  SplinterFlags = [dkSplinter];
var
  RemainingSlots: Integer;
  I, EnergyCount, SplinterCount: Integer;
  Item: TEquipment;
  HasEnergy, HasSplinter, HasMissiles: Boolean;

  // @nested $7619A0 EquipType
  procedure EquipType(ArtefactType: TItemType); // @addr 0x7619A0 @ida "void __usercall $name(unsigned __int8 ArtefactType@<al>, void *ParentFrame@<^0>);" @note "Caller-popped static link; remaining slots -4, ship -8."
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
        if (Candidate.EquippedFlag = 0) and
           ((Candidate.ItemType = ArtefactType) or
            ((Candidate.ItemType in [t_Artefact..t_Artefact2]) and (TArtefactCustom(Candidate).CountsAsItemType = ArtefactType))) and
           (not HasEquippedArtefactOfSameUseGroup(Candidate) or Galaxy.AreDuplicateArtefactsEnabled) then
        begin
          Score := EvaluateItem(Candidate, 3);
          if (Best = nil) or (Score > BestScore) then
          begin
            Best := Candidate;
            BestScore := Score;
          end;
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
  RemainingSlots := GetSlotCountForItemType(t_Artefact);
  if RemainingSlots <= 0 then Exit;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if (Item.ItemType in [t_Artefact..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtDefToArms1..t_ArtFastRacks]) and
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
    if Weapons[I].GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
    begin
      HasMissiles := True;
      Break;
    end;
  I := 4;
  while (RemainingSlots > 0) and (I > 0) do
  begin
    EquipType(t_ArtefactAntigrav);
    EquipType(t_ArtefactSpeed);
    EquipType(t_ArtefactHull);
    EquipType(t_ArtMissileDef);
    EquipType(t_ArtEnergyDef);
    EquipType(t_ArtPDTurret);
    if HasEnergy then EquipType(t_ArtEnergyPulse);
    if HasSplinter then EquipType(t_ArtSplinter);
    if HasMissiles then EquipType(t_ArtFastRacks);
    if GetDefGenerator <> nil then EquipType(t_ArtefactDef);
    if GetRepairRobot <> nil then EquipType(t_ArtefactDroid);
    if HasSplinter then EquipType(t_ArtDecelerate);
    if (GetDefGenerator <> nil) and HasEnergy then EquipType(t_ArtDefToEnergy);
    if (GetCargoHook <> nil) and not (TypeId in [stKling, stTransport, stWarrior]) then EquipType(t_ArtefactHook);
    if not (TypeId in [stKling, stTransport, stWarrior]) then EquipType(t_ArtefactMiniExpl);
    EquipType(t_ArtefactNano);
    EquipType(t_ArtefactPower);
    EquipType(t_ArtefactRadar);
    EquipType(t_ArtefactScaner);
    EquipType(t_ArtefactFuel);
    EquipType(t_ArtBio);
    if GetSlotCount(sskWeapon) < 5 then EquipType(t_ArtDefToArms1);
    if (GetSlotCount(sskDefGenerator) > 0) and (GetSlotCount(sskWeapon) < 4) then EquipType(t_ArtDefToArms2);
    if GetSlotCount(sskWeapon) > WeaponCount then EquipType(t_ArtWeaponToSpeed);
    if (GetSlotCount(sskAfterburner) > 0) and (TypeId in [stRanger,stPirate..stWarrior]) then EquipType(t_ArtForsage);
    if (GetEngine <> nil) and (GetEngine.JumpRange * 1.2 < HyperJumpArtefactRange) then EquipType(t_ArtGiperJump);
    Dec(I);
  end;
  RefreshDerivedStats(True);
end;
{ @end $761AB8 }

{ @routine $761E54 TShip_CalculateItemEffectiveness }
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
    ((Item as TEquipment).BrokenFlag <> 0) and (Item.ItemType <> t_Engine) then Exit;
  if (Item is TEquipment) and not CanUseEquipmentTech(TEquipment(Item)) then Exit;
  if (CurrentPlanet = nil) and (DockedTo = nil) and (Item is TWeapon) and
    (TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (TWeapon(Item).Ammo <= 0) then Exit;
  if (Item is TEngine) and (TEngine(Item).Speed < 100) and not (Self is TRuins) then Exit;
  if not (Item.ItemType in [t_Hull..t_CustomWeapon]) then
  begin
    if Item is TArtefact then
      Result := 5000 / Max(1, Item.Weight) / Max(0.25, TEquipment(Item).GetFragilityFactor(EmptyDamageFlags))
    else
      Result := Item.Cost / Max(1, Item.Weight);
    Exit;
  end;

  Equipment := Item as TEquipment;
  for I := 1 to 5 do SavedWeapons[I] := nil;
  SavedTarget := nil;
  TemporarilyUnequipped := (Equipment.EquippedFlag <> 0) and (Equipment.ItemType in [t_Weapon1..t_CustomWeapon]);
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
  if Equipment.ItemType in [t_Hull..t_DefGenerator] then
  begin
    case Equipment.ItemType of
      t_Hull: begin
        CandidateHull := THull(Equipment);
        Result := EvaluateStatBonus(bonHull, CalculateHullArmor(CandidateHull));
        if GetHull <> CandidateHull then
          Result := Result +
            EvaluateStatBonus(bonSlotRadar, CandidateHull.GetSlotCount(sskRadar) - GetHull.GetSlotCount(sskRadar)) +
            EvaluateStatBonus(bonSlotScaner, CandidateHull.GetSlotCount(sskScanner) - GetHull.GetSlotCount(sskScanner)) +
            EvaluateStatBonus(bonSlotDroid, CandidateHull.GetSlotCount(sskRepairRobot) - GetHull.GetSlotCount(sskRepairRobot)) +
            EvaluateStatBonus(bonSlotHook, CandidateHull.GetSlotCount(sskCargoHook) - GetHull.GetSlotCount(sskCargoHook)) +
            EvaluateStatBonus(bonSlotDef, CandidateHull.GetSlotCount(sskDefGenerator) - GetHull.GetSlotCount(sskDefGenerator)) +
            EvaluateStatBonus(bonSlotWeapon, CandidateHull.GetSlotCount(sskWeapon) - GetHull.GetSlotCount(sskWeapon)) +
            EvaluateStatBonus(bonSlotArt, CandidateHull.GetSlotCount(sskArtefact) - GetHull.GetSlotCount(sskArtefact)) +
            EvaluateStatBonus(bonSlotForsage, CandidateHull.GetSlotCount(sskAfterburner) - GetHull.GetSlotCount(sskAfterburner)) +
            Round(EvaluateStatBonus(bonMass, CalculateEquippedMass(nil)) -
              EvaluateStatBonus(bonMass, CalculateEquippedMass(nil) + CandidateHull.CalculateMass - GetHull.CalculateMass));
      end;
      t_FuelTanks: Result := EvaluateStatBonus(bonFuel, GetItemFuelTankCapacity(Equipment));
      t_Engine: Result := EvaluateStatBonus(bonSpeed, CalculateEngineSpeed(TEngine(Equipment), InNormalSpace or not CanRepairEquipmentTech(Equipment))) +
        EvaluateStatBonus(bonJump, CalculateEngineJumpRange(TEngine(Equipment)));
      t_Radar: Result := EvaluateStatBonus(bonRadar, CalculateRadarRange(TRadar(Equipment)));
      t_Scaner: if GetRadar <> nil then Result := EvaluateStatBonus(bonScan, CalculateScannerPower(TScaner(Equipment)));
      t_RepairRobot: Result := EvaluateStatBonus(bonDroid, CalculateRepairPoints(TRepairRobot(Equipment)));
      t_CargoHook: Result := EvaluateStatBonus(bonHook, CalculateCargoHookPower(TCargoHook(Equipment)));
      t_DefGenerator: Result := EvaluateStatBonus(bonDef, Round(100 - CalculateDefGeneratorFactor(TDefGenerator(Equipment)) * 100));
    end;
  end
  else if Equipment.ItemType in [t_Weapon1..t_CustomWeapon] then
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
    Result := Result + DamageValue * (1 + EvaluateStatBonus(bonWRadius, Round(WeaponRange)) * 0.002);
    Result := Result + EvaluateStatBonus(bonWRadius, Round((WeaponRange + MinRange) * 0.5)) * 0.5;
    if ((CurrentPlanet <> nil) or (DockedTo <> nil)) and (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) then
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
  else if (Equipment.BrokenFlag <> 0) and (Equipment is TWeapon) and (TWeapon(Equipment).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) then
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
{ @end $761E54 }

{ @routine $76283C TShip_EstimateWeaponDamageAgainstTypicalDefense }
function TShip.EstimateWeaponDamageAgainstTypicalDefense(Item: TItem): Single;
var
  MinimumDamage, MaximumDamage, Level: Integer;
  ItemKind: Byte;
  DefenseFactor, Armor: Single;
begin
  Result := 1;
  ItemKind := Byte(Item.ItemType);
  if ItemKind in [Ord(t_Weapon1)..Ord(t_CustomWeapon)] then
  begin
    if (Cardinal(TWeapon(Item).GetDamageFlags) and (1 shl Ord(dkUndefendable))) <> 0 then
    begin
      MinimumDamage := GetWeaponMinDamage(TWeapon(Item));
      MaximumDamage := GetWeaponMaxDamage(TWeapon(Item));
    end
    else
    begin
      Level := Min(Galaxy.TechLevel + 1, 8);
      DefenseFactor := 1 - DefGeneratorLevelFactors[Level];
      DefenseFactor := 1 - RemapClamped(Galaxy.TechLevel, 1, 8, 0.5, 1.2) * DefenseFactor;
      Armor := RemapClamped(Galaxy.TechLevel, 1, 8, 0.5, 1.5) * HullLevelStats[Level].Armor;
      MinimumDamage := Round(GetWeaponMinDamage(TWeapon(Item)) * DefenseFactor - Armor);
      MaximumDamage := Round(GetWeaponMaxDamage(TWeapon(Item)) * DefenseFactor - Armor);
    end;
    MinimumDamage := Max(1, MinimumDamage);
    MaximumDamage := Max(1, MaximumDamage);
    Result := RemapClamped(GetEffectiveSkillLevel(psAccuracy), 0, 6,
      (3 * MinimumDamage + MaximumDamage) div 4, (MinimumDamage + 3 * MaximumDamage) div 4);
  end;
end;
{ @end $76283C }

{ @routine $762A6C TShip_GetWeaponRange }
function TShip.GetWeaponRange(Weapon: TWeapon): Integer;
var
  Range, I, TemplateRange: Integer;
  Extra: PExtraSpecial;
begin
  if not (Weapon.ItemType in [t_Weapon1..t_CustomWeapon]) then
  begin
    Result := 0;
    Exit;
  end;
  Range := Weapon.Range + GetTotalStatBonus(bonWRadius);
  if Weapon.ExtraSpecials <> nil then
    for I := 0 to Weapon.ExtraSpecials.Count - 1 do
    begin
      Extra := Weapon.ExtraSpecials[I];
      Inc(Range, MicroModuleTemplates[Extra.ModuleIndexPlusOne - 1].StatBonuses[bonWRadius] * Extra.Count);
    end;
  if Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    TemplateRange := Weapon.GetWeaponInfo.MissileRange;
    if (Self is TKling) and (Ord((Self as TKling).KlingType) = 0) then Range := Max(Range, TemplateRange)
    else if Self is TRuins then Range := Max(Range, TemplateRange)
    else if Galaxy.AreMaxRangeMissilesEnabled or (GetPlayer = Self) then Range := Min(GetRadarRange, Max(Range, TemplateRange))
    else Range := Min(GetRadarRange, Range);
  end;
  Result := Max(100, Range);
end;
{ @end $762A6C }

{ @routine $762C3C TShip_CalculateHullArmor }
function TShip.CalculateHullArmor(Hull: THull): Integer;
var
  Bonus, Value: Integer;
begin
  if Hull.ItemType <> t_Hull then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonHull);
  if GetHull <> Hull then
  begin
    Dec(Bonus, GetEquipmentStatBonus(bonHull, GetHull));
    Inc(Bonus, GetEquipmentStatBonus(bonHull, Hull));
  end;
  Value := Hull.Armor + Bonus;
  Value := Value + CountActiveArtefacts(t_ArtefactHull) * (HullArtefactArmor + HullArtefactBoostArmor * Byte(CanBoostArtefact(t_ArtefactHull, Hull, False)));
  Result := Max(0, Value);
end;
{ @end $762C3C }

{ @routine $762D00 TShip_GetItemFuelTankCapacity }
function TShip.GetItemFuelTankCapacity(Item: TItem): Integer;
begin
  if Item.ItemType <> t_FuelTanks then Result := 0
  else Result := TFuelTanks(Item).Capacity;
end;
{ @end $762D00 }

{ @routine $762D30 TShip_CalculateEngineSpeed }
function TShip.CalculateEngineSpeed(Engine: TEngine; ApplyBrokenPenalty: Boolean): Integer;
var
  Bonus, Value, I: Integer;
begin
  if Engine.ItemType <> t_Engine then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonSpeed);
  if (Engine.EquippedFlag = 0) and (Engine.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonSpeed, Engine));
  Value := Engine.Speed;
  if ApplyBrokenPenalty and (Engine.BrokenFlag <> 0) then Value := Round(Value * 0.6);
  Value := Value + CountActiveArtefacts(t_ArtWeaponToSpeed) * (WeaponToSpeedArtefactBonus + WeaponToSpeedArtefactBoost * Byte(CanBoostArtefact(t_ArtWeaponToSpeed, Engine, False)));
  Value := Max(Min(200, Engine.Speed), Value + Bonus);
  for I := 1 to CountActiveArtefacts(t_ArtefactSpeed) do
    Value := Round(Value * (SpeedArtefactFactor + SpeedArtefactBoostFactor * ShortInt(CanBoostArtefact(t_ArtefactSpeed, nil, False))));
  Result := Max(0, Value);
end;
{ @end $762D30 }

{ @routine $762EA0 TShip_CalculateEngineJumpRange }
function TShip.CalculateEngineJumpRange(Engine: TEngine): Integer;
var
  Bonus, Value: Integer;
begin
  if Engine.ItemType <> t_Engine then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonJump);
  if (Engine.EquippedFlag = 0) and (Engine.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonJump, Engine));
  Value := Engine.JumpRange;
  if not CanUseEquipmentTech(Engine) then Value := Value div 2;
  if CountActiveArtefacts(t_ArtGiperJump) > 0 then
    Value := Max(Value, Round(Sqrt(CountActiveArtefacts(t_ArtGiperJump)) *
      (HyperJumpArtefactRange + HyperJumpArtefactBoostRange * Ord(CanBoostArtefact(t_ArtGiperJump, Engine, False)))));
  Result := Max(0, Value + Bonus);
end;
{ @end $762EA0 }

{ @routine $762FD8 TShip_CalculateRadarRange }
function TShip.CalculateRadarRange(Radar: TRadar): Integer;
var
  Bonus, Value: Integer;
begin
  if Radar.ItemType <> t_Radar then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonRadar);
  if (Radar.EquippedFlag = 0) and (Radar.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonRadar, Radar));
  Value := Radar.Range;
  Value := Value + CountActiveArtefacts(t_ArtefactRadar) * (RadarArtefactRange + RadarArtefactBoostRange * Byte(CanBoostArtefact(t_ArtefactRadar, Radar, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $762FD8 }

{ @routine $76308C TShip_CalculateScannerPower }
function TShip.CalculateScannerPower(Scanner: TScaner): Integer;
var
  Bonus, Value: Integer;
begin
  if Scanner.ItemType <> t_Scaner then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonScan);
  if (Scanner.EquippedFlag = 0) and (Scanner.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonScan, Scanner));
  Value := Scanner.ScanPower;
  Value := Value + CountActiveArtefacts(t_ArtefactScaner) * (ScannerArtefactPower + ScannerArtefactBoostPower * Byte(CanBoostArtefact(t_ArtefactScaner, Scanner, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $76308C }

{ @routine $763140 TShip_CalculateRepairPoints }
function TShip.CalculateRepairPoints(RepairRobot: TRepairRobot): Integer;
var
  Bonus, Value: Integer;
begin
  if RepairRobot.ItemType <> t_RepairRobot then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonDroid);
  if (RepairRobot.EquippedFlag = 0) and (RepairRobot.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonDroid, RepairRobot));
  Value := RepairRobot.RepairPoints;
  Value := Value + CountActiveArtefacts(t_ArtefactDroid) * (DroidArtefactRepair + DroidArtefactBoostRepair * Byte(CanBoostArtefact(t_ArtefactDroid, RepairRobot, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $763140 }

{ @routine $7631F4 TShip_CalculateCargoHookPower }
function TShip.CalculateCargoHookPower(CargoHook: TCargoHook): Integer;
var
  Bonus, Value: Integer;
begin
  if CargoHook.ItemType <> t_CargoHook then begin Result := 0; Exit; end;
  Bonus := GetTotalStatBonus(bonHook);
  if (CargoHook.EquippedFlag = 0) and (CargoHook.SpecialModuleIndex <> 0) then
    Inc(Bonus, GetEquipmentStatBonus(bonHook, CargoHook));
  Value := CargoHook.PickupPower;
  Value := Value + CountActiveArtefacts(t_ArtefactHook) * (CargoHookArtefactPower + CargoHookArtefactBoostPower * Byte(CanBoostArtefact(t_ArtefactHook, CargoHook, False)));
  Result := Max(0, Value + Bonus);
end;
{ @end $7631F4 }

{ @routine $7632A8 TShip_CalculateDefGeneratorFactor }
function TShip.CalculateDefGeneratorFactor(DefGenerator: TDefGenerator): Single;
var
  Percent, I: Integer;
  Factor: Single;
begin
  if DefGenerator.ItemType <> t_DefGenerator then begin Result := 0; Exit; end;
  Percent := GetTotalStatBonus(bonDef);
  if (DefGenerator.EquippedFlag = 0) and (DefGenerator.SpecialModuleIndex <> 0) then
    Inc(Percent, GetEquipmentStatBonus(bonDef, DefGenerator));
  Factor := DefGenerator.DamageFactor;
  if Percent <> 0 then Factor := Factor - (1 - DefensePercentToDamageFactor(Percent));
  Factor := Factor - CountActiveArtefacts(t_ArtefactDef) * (DefenseArtefactBonus + DefenseArtefactBoost * ShortInt(CanBoostArtefact(t_ArtefactDef, DefGenerator, False)));
  for I := 1 to CountActiveArtefacts(t_ArtDefToEnergy) do
    Factor := Min(1, Factor + (1 - Factor) * (DefenseToEnergyPenalty + DefenseToEnergyBoostPenalty * ShortInt(CanBoostArtefact(t_ArtDefToEnergy, DefGenerator, False))));
  if (CountActiveArtefacts(t_ArtDefToArms1) > 0) and not CanBoostArtefact(t_ArtDefToArms1, DefGenerator, False) then
    for I := 1 to CountActiveArtefacts(t_ArtDefToArms1) do Factor := Min(1, Factor + (1 - Factor) * DefenseToWeaponPenalty);
  Result := Min(1, Max(0.01, Factor));
end;
{ @end $7632A8 }

{ @routine $763560 TShip_GetEquipmentEvaluationSynergyBonus }
function TShip.GetEquipmentEvaluationSynergyBonus(Item: TEquipment): Single;
var
  Positive, Nonpositive: Single;
  DamageBonus: Single;
  Module: PMicroModuleTemplate;
  I, ModuleIndex: Integer;
  ItemType: TItemType;
  // @nested $763524 AccumulateEquipmentBonus
  procedure AccumulateEquipmentBonus(Value: Single); // @addr 0x763524 @ida "void __usercall $name(float Value@<^0>, void *ParentFrame@<^4>);" @stackpop 0x4 @calls "0x7635F8 0x76361C 0x76363A 0x76366A 0x76369A 0x7636CA 0x763748 0x763766 0x7637F1 0x763827 0x763929 0x763953 0x763971 0x76398F 0x7639AD 0x7639CB 0x7639EC 0x763A1B 0x763A45 0x763A69 0x763A9F 0x763AD5 0x763B0B 0x763B8F 0x763BB3 0x763C4E 0x763C8A 0x763D9E 0x763DCE 0x763DF2 0x763E16 0x763E3A 0x763E5E 0x763E82 0x763EA0 0x763EE2" @note "Adds positive and nonpositive values to separate Single accumulators at ParentFrame-4/-8."
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
        if ItemType <> t_Hull then AccumulateEquipmentBonus(EvaluateStatBonus(bonHull, Module.StatBonuses[bonHull]));
        if ItemType <> t_Engine then
        begin
          AccumulateEquipmentBonus(EvaluateStatBonus(bonSpeed, Module.StatBonuses[bonSpeed]));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonJump, Module.StatBonuses[bonJump]));
        end;
        if (GetRadar <> nil) and (ItemType <> t_Radar) then AccumulateEquipmentBonus(EvaluateStatBonus(bonRadar, Module.StatBonuses[bonRadar]));
        if (GetScanner <> nil) and (ItemType <> t_Scaner) then AccumulateEquipmentBonus(EvaluateStatBonus(bonScan, Module.StatBonuses[bonScan]));
        if (GetRepairRobot <> nil) and (ItemType <> t_RepairRobot) then AccumulateEquipmentBonus(EvaluateStatBonus(bonDroid, Module.StatBonuses[bonDroid]));
        if (GetCargoHook <> nil) and (ItemType <> t_CargoHook) then
        begin
          // Native expression adds raw hook power to the evaluated bonus before subtracting its evaluation.
          AccumulateEquipmentBonus(EvaluateStatBonus(bonHook, Module.StatBonuses[bonHook]) + CalculateCargoHookPower(GetCargoHook) - EvaluateStatBonus(bonHook, CalculateCargoHookPower(GetCargoHook)));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonHookRadius, Module.StatBonuses[bonHookRadius]));
        end;
        if (GetDefGenerator <> nil) and (ItemType <> t_DefGenerator) then
          AccumulateEquipmentBonus(EvaluateStatBonus(bonDef, Module.StatBonuses[bonDef] + Integer(Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100))) -
            EvaluateStatBonus(bonDef, Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonWRadius, Module.StatBonuses[bonWRadius]) * CountEquippedWeapons);
        if not (ItemType in [t_Weapon1..t_CustomWeapon]) then
          for I := 1 to CountEquippedWeapons do
          begin
            DamageBonus := 0;
            if dkEnergy in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonWEnergy, Module.StatBonuses[bonWEnergy]);
            if dkSplinter in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonWSplinter, Module.StatBonuses[bonWSplinter]);
            if dkMissile in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonWMissile, Module.StatBonuses[bonWMissile]);
            if (DamageBonus > 0.001) or (DamageBonus < -0.001) then
              DamageBonus := EvaluateWeaponDamage(Weapons[I], False, DamageBonus);
            AccumulateEquipmentBonus(DamageBonus);
          end;
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill1, Module.StatBonuses[bonSkill1]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill2, Module.StatBonuses[bonSkill2]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill3, Module.StatBonuses[bonSkill3]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill4, Module.StatBonuses[bonSkill4]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill5, Module.StatBonuses[bonSkill5]));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill6, Module.StatBonuses[bonSkill6]));
      end
      else
      begin
        if ItemType <> t_Hull then AccumulateEquipmentBonus(EvaluateStatBonus(bonHull, Item.GetStatBonus(bonHull)));
        if ItemType <> t_Engine then
        begin
          AccumulateEquipmentBonus(EvaluateStatBonus(bonSpeed, Item.GetStatBonus(bonSpeed)));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonJump, Item.GetStatBonus(bonJump)));
        end;
        if (GetRadar <> nil) and (ItemType <> t_Radar) then AccumulateEquipmentBonus(EvaluateStatBonus(bonRadar, Item.GetStatBonus(bonRadar)));
        if (GetScanner <> nil) and (ItemType <> t_Scaner) then AccumulateEquipmentBonus(EvaluateStatBonus(bonScan, Item.GetStatBonus(bonScan)));
        if (GetRepairRobot <> nil) and (ItemType <> t_RepairRobot) then AccumulateEquipmentBonus(EvaluateStatBonus(bonDroid, Item.GetStatBonus(bonDroid)));
        if (GetCargoHook <> nil) and (ItemType <> t_CargoHook) then
        begin
          // Native expression adds raw hook power to the evaluated bonus before subtracting its evaluation.
          AccumulateEquipmentBonus(EvaluateStatBonus(bonHook, Item.GetStatBonus(bonHook)) + CalculateCargoHookPower(GetCargoHook) - EvaluateStatBonus(bonHook, CalculateCargoHookPower(GetCargoHook)));
          AccumulateEquipmentBonus(EvaluateStatBonus(bonHookRadius, Item.GetStatBonus(bonHookRadius)));
        end;
        if (GetDefGenerator <> nil) and (ItemType <> t_DefGenerator) then
          AccumulateEquipmentBonus(EvaluateStatBonus(bonDef, Item.GetStatBonus(bonDef) + Integer(Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100))) -
            EvaluateStatBonus(bonDef, Round(100 - CalculateDefGeneratorFactor(GetDefGenerator) * 100)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonWRadius, Item.GetStatBonus(bonWRadius)) * CountEquippedWeapons);
        if not (ItemType in [t_Weapon1..t_CustomWeapon]) then
          for I := 1 to CountEquippedWeapons do
          begin
            DamageBonus := 0;
            if dkEnergy in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonWEnergy, Item.GetStatBonus(bonWEnergy));
            if dkSplinter in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonWSplinter, Item.GetStatBonus(bonWSplinter));
            if dkMissile in Weapons[I].GetWeaponInfo.DamageFlags then DamageBonus := DamageBonus + EvaluateStatBonus(bonWMissile, Item.GetStatBonus(bonWMissile));
            if (DamageBonus > 0.001) or (DamageBonus < -0.001) then
              DamageBonus := EvaluateWeaponDamage(Weapons[I], False, DamageBonus);
            AccumulateEquipmentBonus(DamageBonus);
          end;
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill1, Item.GetStatBonus(bonSkill1)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill2, Item.GetStatBonus(bonSkill2)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill3, Item.GetStatBonus(bonSkill3)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill4, Item.GetStatBonus(bonSkill4)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill5, Item.GetStatBonus(bonSkill5)));
        AccumulateEquipmentBonus(EvaluateStatBonus(bonSkill6, Item.GetStatBonus(bonSkill6)));
        AccumulateEquipmentBonus(Item.GetStatBonus(bonAIValue));
      end;
      AccumulateEquipmentBonus(EvaluateStatBonus(bonMass, CalculateEquippedMass(Item)) -
        EvaluateStatBonus(bonMass, CalculateEquippedMass(nil)));
      if Item.MicroModuleIndex <> 0 then
      begin
        Positive := Positive + Round(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonExtraAkrinEff] * Positive * 0.0001);
        Nonpositive := Nonpositive + Round(MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonExtraAkrinPenalty] * Nonpositive * 0.0001);
      end;
      Result := Positive + Nonpositive;
    end;
  end;
end;
{ @end $763560 }

{ @routine $763F98 TShip_GetWeaponArtefactDamageFactor }
function TShip.GetWeaponArtefactDamageFactor(Weapon: TWeapon): Single;
const
  EnergyDamageFlags = [dkEnergy];
var
  Flags: TDamageFlagSet;
  I: Integer;
begin
  Result := 1;
  Flags := Weapon.GetWeaponInfo.DamageFlags;
  if dkEnergy in Flags then
    for I := 1 to CountActiveArtefacts(t_ArtEnergyPulse) do
      Result := Result * (1 + (EnergyPulseArtefactFactor + ShortInt(CanBoostArtefact(t_ArtEnergyPulse, Weapon, False)) * EnergyPulseArtefactBoostFactor) * EnergyPulseArtefactChance);
  if (CountActiveArtefacts(t_ArtDefToEnergy) > 0) and (dkEnergy in Flags) and (GetDefGenerator <> nil) then
    Result := Result * (1 + (
      (CountWeaponsByDamageFlags(EnergyDamageFlags) + 1) * RemapClamped(
        CountWeaponsByDamageFlags(EnergyDamageFlags) + 1, 1, 5,
        DefenseToEnergyUpperFactor + ShortInt(CanBoostArtefact(t_ArtDefToEnergy, Weapon, False)) * DefenseToEnergyUpperBoost,
        DefenseToEnergyMinimumFactor + ShortInt(CanBoostArtefact(t_ArtDefToEnergy, Weapon, False)) * DefenseToEnergyMinimumBoost) -
      CountWeaponsByDamageFlags(EnergyDamageFlags) * RemapClamped(
        CountWeaponsByDamageFlags(EnergyDamageFlags), 1, 5,
        DefenseToEnergyUpperFactor + ShortInt(CanBoostArtefact(t_ArtDefToEnergy, Weapon, False)) * DefenseToEnergyUpperBoost,
        DefenseToEnergyMinimumFactor + ShortInt(CanBoostArtefact(t_ArtDefToEnergy, Weapon, False)) * DefenseToEnergyMinimumBoost) - 1) * CountActiveArtefacts(t_ArtDefToEnergy));
  if dkSplinter in Flags then
    for I := 1 to CountActiveArtefacts(t_ArtSplinter) do
      Result := Result * (SplinterArtefactFactor + ShortInt(CanBoostArtefact(t_ArtSplinter, Weapon, False)) * SplinterArtefactBoostFactor);
end;
{ @end $763F98 }

{ @routine $764230 TShip_UpdateSpeedTrackingMetrics }
procedure TShip.UpdateSpeedTrackingMetrics;
begin
  SmoothedSpeed := (29 * SmoothedSpeed + Speed) div 30;
  if (EnemyShip <> nil) and EnemyShip.InNormalSpace and (EnemyShip.CurrentStar = CurrentStar) then
    SmoothedEnemySpeed := (29 * SmoothedEnemySpeed + EnemyShip.Speed) div 30;
end;
{ @end $764230 }

{ @routine $7642BC TShip_RefreshEquipmentEvaluationMetrics }
procedure TShip.RefreshEquipmentEvaluationMetrics;
var
  I, EquippedCount: Integer;
  Item: TEquipment;
  Effectiveness: Single;
  FreeCapacity: Integer;
begin
  if Self.SmoothedWealth = 0 then
    Self.SmoothedWealth := Self.Wealth
  else
    Self.SmoothedWealth := (Self.Wealth + Self.SmoothedWealth) div 2;
  if Self.SmoothedMoneyFraction = 0 then
    Self.SmoothedMoneyFraction := Self.Money / Max(1, Self.Wealth)
  else
    Self.SmoothedMoneyFraction := (Self.Money / Max(1, Self.Wealth) + 4 * Self.SmoothedMoneyFraction) * 0.2;
  EquippedCount := 0;
  Effectiveness := 0;
  FreeCapacity := Self.GetHull.Weight;
  for I := 0 to Self.Inventory.Count - 1 do
  begin
    Item := TEquipment(Self.Inventory[I]);
    if (Item.ItemType <> t_Hull) and (Item.EquippedFlag <> 0) then
    begin
      Inc(EquippedCount);
      Effectiveness := Effectiveness + Self.CalculateItemEffectiveness(TItem(Item));
      Dec(FreeCapacity, Item.Weight);
    end;
  end;
  Effectiveness := Effectiveness / Max(1, EquippedCount);
  for I := 0 to Self.Artefacts.Count - 1 do
  begin
    Item := TEquipment(Self.Artefacts[I]);
    if Item.EquippedFlag <> 0 then Dec(FreeCapacity, Item.Weight);
  end;
  if Self.SmoothedEquipmentEffectiveness = 0 then
    Self.SmoothedEquipmentEffectiveness := Effectiveness
  else
    Self.SmoothedEquipmentEffectiveness := (4 * Self.SmoothedEquipmentEffectiveness + Effectiveness) * 0.2;
  if Self.SmoothedFreeCapacityFraction = 0 then
    Self.SmoothedFreeCapacityFraction := Max(0.0, FreeCapacity / Max(1, Self.GetHull.Weight))
  else
    Self.SmoothedFreeCapacityFraction := (4 * Self.SmoothedFreeCapacityFraction + Max(0.0, FreeCapacity / Max(1, Self.GetHull.Weight))) * 0.2;
end;
{ @end $7642BC }

{ @routine $7645E0 TShip_EvaluateItem }
function TShip.EvaluateItem(Item: TItem; PriceMode: Byte): Single;
begin
  Result := AdjustItemEvaluation(Item, PriceMode, CalculateItemEffectiveness(Item));
end;
{ @end $7645E0 }

{ @routine $76461C TShip_AdjustItemEvaluation }
function TShip.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
const
  NoFlags = [];
var
  MoneyPenalty, EffectivenessScale, WeightPenalty, FragilityScale: Single;
  Price: Integer;
  DesiredFreeFraction, DesiredMoneyFraction, HullValueScale: Single;
begin
  FragilityScale := 1;
  if Item.ItemType in [t_FuelTanks, t_Radar, t_Scaner] then
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
    3: Price := Item.CalculateResaleValue(GetEffectiveSkillLevel(psTrading));
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
  if Item.ItemType <> t_Hull then
    Result := Effectiveness * EffectivenessScale * (1 + (2 - TEquipment(Item).GetFragilityFactor(NoFlags)) * FragilityScale) -
      Item.Weight * WeightPenalty - Price * MoneyPenalty
  else
    Result := (Item.Weight * HullValueScale / Max(0.01, TEquipment(Item).GetFragilityFactor(NoFlags)) + Effectiveness) * EffectivenessScale +
      Item.Weight * WeightPenalty - Price * 0.25 * MoneyPenalty;
end;
{ @end $76461C }

{ @routine $764AA8 TShip_EvaluateStatBonus }
function TShip.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonHull: Result := Value * 200;
    bonFuel: Result := Value * 2.5;
    bonSpeed: Result := Value;
    bonJump: Result := Value * 25;
    bonRadar: Result := Value * 0.05;
    bonScan: Result := Value * 5 + Value * 20 * CountWeaponsByDamageFlags(ScannerFlags);
    bonDroid: Result := Value * 10 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonHook: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.0;
    bonDef: Result := Value * 5 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonWEnergy: Result := Value * 10;
    bonWSplinter: Result := Value * 10;
    bonWMissile: Result := Value * 10 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonWRadius: Result := Value * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonHookRadius: Result := Value * 0.1;
    bonMass: Result := RemapClamped(Value, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 5000;
    bonSlotRadar:
      if (GetSlotCount(sskRadar) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind] - SlotBonusEvaluationWeights[bonSlotWeapon] * CountMissileWeapons
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * SlotBonusEvaluationWeights[bonSlotWeapon]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonSlotHook:
      if (GetSlotCount(sskCargoHook) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(sskCargoHook) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then Result := SlotBonusEvaluationWeights[BonusKind] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(sskWeapon)) * SlotBonusEvaluationWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskWeapon)) * SlotBonusEvaluationWeights[BonusKind];
        if CountEquippedWeapons > Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - (SlotBonusEvaluationWeights[BonusKind] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(sskWeapon)));
      end;
    bonSlotArt:
      begin
        if (GetSlotCount(sskArtefact) < DefaultHullSlotCounts[sskArtefact]) and (Value > 0) then
          Result := Min(Value, DefaultHullSlotCounts[sskArtefact] - GetSlotCount(sskArtefact)) * SlotBonusEvaluationWeights[BonusKind];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskArtefact)) * SlotBonusEvaluationWeights[BonusKind];
        if Artefacts <> nil then
          if Artefacts.Count > Max(Value + GetSlotCount(sskArtefact), 0) then Result := -1000;
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := SlotBonusEvaluationWeights[BonusKind]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -SlotBonusEvaluationWeights[BonusKind];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), Value) * SkillBonusEvaluationWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) > 6) then
          Result := Result + (SkillBonusEvaluationWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), -Value) * -SkillBonusEvaluationWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) < 0) then
          Result := Result + (SkillBonusEvaluationWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]));
      end;
  else Result := 0;
  end;
end;
{ @end $764AA8 }

{ @routine $7656F8 TShip_EvaluateWeaponDamage }
function TShip.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  ShockFlags = [dkShock];
  AcidFlags = [dkAcid];
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
  if dkDestruct in Flags then Result := Result * 1.05;
  if dkDrain in Flags then Result := Result * 1.5;
  if dkShock in Flags then Result := Result * (1.1 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  if dkAcid in Flags then Result := Result * 1.1;
  if dkMagnetic in Flags then Result := Result * 1.1;
  StatusFactor := 1;
  if dkScanBonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkBonusToDamaged in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkReduceEngine in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.05);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if dkDestruct in Flags then Result := Result + 1;
    if dkDecelerate in Flags then Result := Result + 2;
    if (CountActiveArtefacts(t_ArtDecelerate) > 0) and (dkSplinter in Flags) then
      Result := Result + 5 + 5 * Ord(CanBoostArtefact(t_ArtDecelerate, Weapon, False) or (CountActiveArtefacts(t_ArtDecelerate) > 1));
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if dkAcid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
    if dkMoreDrop in Flags then Result := Result + ScannerFactor * 5;
    if dkDropCargo in Flags then Result := Result + ScannerFactor * 5;
    if dkReduceEngine in Flags then Result := Result + ScannerFactor * 1;
    if dkBlockWeapon in Flags then Result := Result + ScannerFactor * 5;
    if dkDroidBlock in Flags then Result := Result + ScannerFactor * 5;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case Weapon.GetWeaponInfo.ShotType of
    wstRocket: Result := Result * 1.0 * Weapon.GetShotCount * (1 + StatusFactor);
    wstMissile: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    wstTorpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor);
    wstChain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    wstSplash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 * SpeedFactor + StatusFactor);
    wstExploder: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.1 * 0.01 * SpeedFactor + StatusFactor);
    wstAreaDamage: Result := Result * (1 + Weapon.Range * 1.3 * 0.01 * SpeedFactor + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
end;
{ @end $7656F8 }

{ @routine $765D28 TShip_EvaluateMicroModuleGain }
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
{ @end $765D28 }

{ @routine $765ECC TShip_AutoApplyMicroModules }
procedure TShip.AutoApplyMicroModules;
var
  Candidate: TEquipment;
  Module: TEquipment;
  I, J: Integer;
  Best: TEquipment;
  Changed: Boolean;
  Score, BestScore: Single;

  // @nested $765DF0 FitsMicroModuleCapacity
  function FitsMicroModuleCapacity: Boolean; // @addr 0x765DF0 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; equipment -4, module item -8, ship -12."
  begin
    if Candidate.ItemType <> t_Hull then
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
          if (Module as TMicroModule).CanInstallOn(Candidate) and ((Candidate.EquippedFlag <> 0) or (Candidate.ItemType = t_Hull)) and FitsMicroModuleCapacity then
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
          if (Module as TMicroModule).CanInstallOn(Candidate) and (Candidate.EquippedFlag = 0) and (Candidate.ItemType <> t_Hull) and FitsMicroModuleCapacity then
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
{ @end $765ECC }

{ @routine $76616C TShip_AutoEquipInventory }
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
    else if (Item.ItemType in [t_FuelTanks..t_DefGenerator]) and
       (PShipEquipmentCacheView(Self).Slots[Item.ItemType] <> Item) then Item.Unequip;
  end;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  if CountCarriedEquipmentByType(t_Weapon1) < GetSlotCount(sskWeapon) then
  begin
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.ItemType in [t_Weapon1..t_CustomWeapon] then EquipItem(Item as TWeapon);
    end;
  end
  else
    for I := 1 to GetSlotCount(sskWeapon) do EquipItem(SelectBestUnequippedWeapon);
  for Kind := t_FuelTanks to t_DefGenerator do
  begin
    if PShipEquipmentCacheView(Self).Slots[Kind] <> nil then PShipEquipmentCacheView(Self).Slots[Kind].Unequip;
    if GetSlotCountForItemType(Kind) > 0 then
    begin
      PShipEquipmentCacheView(Self).Slots[Kind] := nil;
      Best := nil;
      BestScore := 0;
      for I := 1 to Inventory.Count - 1 do
      begin
        Item := Inventory[I];
        if Item.ItemType = Kind then
        begin
          BestProtected := (Best <> nil) and ((Best.NoDropFlag > 0) or
            ((Best.ScriptItem <> nil) and (TScriptItem(Best.ScriptItem).Name <> '')));
          ItemProtected := (Item.NoDropFlag > 0) or
            ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> ''));
          if BestProtected then
            if not ItemProtected then Continue;
          begin
            Score := EvaluateItem(Item, PriceMode);
            if (Kind = t_FuelTanks) and (Best <> nil) and (GetJumpDestinationDistance <= (Best as TFuelTanks).Fuel) and
               (GetJumpDestinationDistance > (Item as TFuelTanks).Fuel) then Continue;
            if ((Score >= 0) or (Kind in [t_FuelTanks..t_Engine]) or
                ((Kind = t_CargoHook) and (TypeId in [stRanger, stPirate]) and (GetSlotCount(sskCargoHook) > 0)) or
                (Item.NoDropFlag > 0) or (Item.ScriptItem <> nil) or
                ((CargoFreeSpace >= 0) and (PriceMode <> 0) and (EvaluateItem(Item, 0) >= 0))) and
               ((Best = nil) or (Score > BestScore) or ((Score = BestScore) and (Best.Weight > Item.Weight)) or
                (ItemProtected and not BestProtected)) then
            begin
              BestScore := Score;
              Best := Item;
            end;
          end;
        end;
      end;
      if Best <> nil then EquipItem(Best);
    end;
  end;
  RefreshDerivedStats(True);
end;
{ @end $76616C }

{ @routine $766550 TShip_DropCargoUntilNotOverloaded }
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
  CanDrop := InNormalSpace and not (TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]);
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
      if (Artefact <> nil) and (ArtefactValue <= ItemValue) then
      begin
        if CanDrop then DropCarriedArtefactAsMovingLoot(Artefact) else LiquidateArtefact(Artefact);
      end
      else if (Item <> nil) and (Item.EquippedFlag = 0) and ((Count = 0) or (Item.Cost < GoodsValue)) then
      begin
        if CanDrop and (Item is TCountableItem) and (Item.Weight + CargoFreeSpace > 0) then
        begin
          Item := (Item as TCountableItem).Split(-CargoFreeSpace);
          Inventory.Add(Item);
          DropCarriedItemAsMovingLoot(Item);
        end
        else if CanDrop then DropCarriedItemAsMovingLoot(Item) else LiquidateInventoryItem(Item);
      end
      else if Count > 0 then
      begin
        if CanDrop then DropGoodsIntoSpace(Good, Count) else SellGoodsToLocation(Good, Count);
      end
      else if Artefact <> nil then
      begin
        if CanDrop then DropCarriedArtefactAsMovingLoot(Artefact) else LiquidateArtefact(Artefact);
      end
      else if (Item <> nil) and not IsEssentialInventoryItem(Item) then
      begin
        if CanDrop then DropCarriedItemAsMovingLoot(Item) else LiquidateInventoryItem(Item);
      end
      else
      begin
        for I := 1 to Inventory.Count - 1 do
        begin
          Candidate := Inventory[I];
          if Candidate.NoDropFlag > 0 then Continue;
          if (Candidate.ItemType in [t_Weapon1..t_CustomWeapon]) and (Candidate.Weight > GetHull.Weight * 0.2) then
          begin
            Item := TEquipment(Candidate);
            Break;
          end;
          if (Candidate.ItemType = t_CargoHook) and (Candidate.Weight > GetHull.Weight * 0.2) then
          begin
            Item := TEquipment(Candidate);
            Break;
          end;
        end;
        if (Item <> nil) and ((Item.ItemType in [t_Weapon1..t_CustomWeapon]) or (Item.ItemType = t_CargoHook)) then
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
end;
{ @end $766550 }

{ @routine $766E38 TShip_DropRandomCheapItemsOnDestruction }
procedure TShip.DropRandomCheapItemsOnDestruction(Count: Integer);
var
  Index, I: Integer;
  Item: TItem;
  // @nested $766C28 SelectCheapItem
  function SelectCheapItem: TItem; // @addr 0x766C28 @ida "TItem *__cdecl $name(void *ParentFrame);" @note "Caller-popped static link; cycling inventory index -4, ship -8."
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
      if Self is TKling then Value := KlingCheapDropValueFactors[Ord((Self as TKling).KlingType)] * Value;
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
{ @end $766E38 }

{ @routine $7670BC TShip_DropRandomValuableItemsOnDestruction }
procedure TShip.DropRandomValuableItemsOnDestruction(Count: Integer);
var
  Index, I: Integer;
  Item: TItem;
  // @nested $766E98 SelectValuableItem
  function SelectValuableItem: TItem; // @addr 0x766E98 @ida "TItem *__cdecl $name(void *ParentFrame);" @note "Caller-popped static link; cycling inventory index -4, ship -8."
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
      if Self is TKling then Value := KlingValuableDropValueFactors[Ord((Self as TKling).KlingType)] * Value;
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
{ @end $7670BC }

{ @routine $76711C TShip_DropItemsForDominatorProgram }
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
    if Item.ItemType in [t_Hull..t_Engine] then Continue;
    if (Item.ItemType in [t_Weapon1..t_CustomWeapon]) and ((WeaponCount <= 1) or (TWeapon(Item).GetWeaponInfo^.ShotType = wstAreaDamage)) then Continue;
    Value := DominatorProgramDropCostFactors[Ord((Self as TKling).KlingType)] *
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
{ @end $76711C }

{ @routine $767388 TShip_DropCarriedItemAsMovingLoot }
function TShip.DropCarriedItemAsMovingLoot(Item: TItem): Boolean;
begin
  Result := False;
  if NoDrop or (Item.NoDropFlag > 0) then Exit;
  if Item.ItemType = t_Hull then
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
{ @end $767388 }

{ @routine $767414 TShip_DropCarriedArtefactAsMovingLoot }
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
{ @end $767414 }

{ @routine $7674C0 TShip_DropGuaranteedDeathDropItems }
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
{ @end $7674C0 }

{ @routine $767544 TShip_CanDropTreasureMap }
function TShip.CanDropTreasureMap: Boolean;
begin
  Result := False;
  if (Self is TPirate) and ((Self as TPirate).PirateType = 0) and
    (GetPlayer <> PartnerShip) and (ScriptShip = nil) then
    if SeededRandomIntRange(1, 100, Seed) <= 15 then Result := True;
end;
{ @end $767544 }

{ @routine $7675C0 TShip_SelectTreasureMapPlanet }
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
    Star := TObject(CurrentStar.StarDistances[Index].Star) as TStar;
    if Star.Constellation.Id = 20 then Continue;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[J];
      if not (Planet.OwnerId in [oiUninhabited]) or (Planet.SurfaceLootEntries = nil) then Continue;
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
{ @end $7675C0 }

{ @routine $767844 TShip_TryDropTreasureMap }
function TShip.TryDropTreasureMap: Boolean;
var
  Item: TItem;
  Planet: TPlanet;
begin
  Result := False;
  if CanDropTreasureMap and not NoDrop then
  begin
    Planet := SelectTreasureMapPlanet;
    if Planet <> nil then
    begin
      Item := TTreasureMap.Create;
      (Item as TTreasureMap).Init(Planet, Self);
      Inventory.Add(Item);
      DropCarriedItemAsMovingLoot(Item);
      Result := True;
    end;
  end;
end;
{ @end $767844 }

{ @routine $7678CC TShip_DropItemIntoStar }
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
    ActionResult := ScriptItemsAct(satOnDropItemFixed, Item, nil, 0);
    if Item is TEquipmentWithActCode then
      ActionResult := RunItemConfigActionCode(Item, satOnDropItemFixed, Self, Item, nil, ActionResult);
    if Item.ScriptItem <> nil then
      ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnDropItemFixed, Self, Item, nil, ActionResult);
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
{ @end $7678CC }

{ @routine $767C70 TShip_DropAllArtefactsOnDestruction }
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
{ @end $767C70 }

{ @routine $767CBC TShip_DropGoodsIntoSpace }
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
{ @end $767CBC }

{ @routine $767D40 TShip_JettisonCargoGoodsTowardTargetValue }
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
{ @end $767D40 }

{ @routine $767EBC TShip_DropAllCargoGoods }
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
{ @end $767EBC }

{ @routine $767F08 TShip_QueueMovingItemDrop }
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
  ActionResult := ScriptItemsAct(satOnDropItem, Item, nil, 0);
  if Item is TEquipmentWithActCode then
    ActionResult := RunItemConfigActionCode(Item, satOnDropItem, Self, Item, nil, ActionResult);
  if Item.ScriptItem <> nil then
    ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnDropItem, Self, Item, nil, ActionResult);
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
{ @end $767F08 }

{ @routine $768194 TShip_SelectLeastValuableInventoryItem }
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
{ @end $768194 }

{ @routine $768320 TShip_SelectLeastValuableArtefact }
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
  end;
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
{ @end $768320 }

{ @routine $7683FC TShip_SelectCheapestCargoGood }
function TShip.SelectCheapestCargoGood: Byte;
var
  BestValue, Value: Double;
  Good: Byte;
begin
  BestValue := 100000;
  Result := 255;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    if CargoGoods[Good].Count <> 0 then
    begin
      Value := GoodsMarket[Good].AveragePrice;
      if Value < BestValue then
      begin
        BestValue := Value;
        Result := Good;
      end;
    end;
end;
{ @end $7683FC }

{ @routine $768578 TShip_OptimizeInventory }
procedure TShip.OptimizeInventory;
var
  Index: Integer;
  Item, Best: TEquipment;
  Done: Boolean;
  CostPerWeight: Double;
  Count: Integer;
  Good: Byte;
  Artefact: TArtefact;

  // @nested $768470 GetRetainedCapacity
  function GetRetainedCapacity: Integer; // @addr 0x768470 @ida "int __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4. Hull capacity minus equipped and protected items."
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
{ @end $768578 }

{ @routine $768978 TShip_LiquidateInventoryItem }
procedure TShip.LiquidateInventoryItem(Item: TItem);
begin
  if (Item.ItemType = t_Protoplasm) and (GetPlayer <> Self) and
    (((Self is TRanger) and (DockedTo <> nil) and (DockedTo.TypeId = Byte(rstRangerCenter))) or
    (DaysSincePlayerSeen > 100) or ((Self is TWarrior) and ((Self as TWarrior).WarriorType = wtFlagship))) then
  begin
    DepositCarriedNodes;
    (Self as TNormalShip).TrainSkillsAutomatically;
  end
  else
  begin
    SetMoney(Money + Item.CalculateResaleValue(GetEffectiveSkillLevel(psTrading)));
    Inventory.Delete(Inventory.IndexOf(Item));
    if (Item is TWeapon) and (CurrentStar <> nil) then CurrentStar.ClearCombatEventWeaponReferences(Item);
    Item.Free;
    RefreshDerivedStats(True);
  end;
end;
{ @end $768978 }

{ @routine $768AA0 TShip_LiquidateArtefact }
procedure TShip.LiquidateArtefact(Item: TArtefact);
begin
  SetMoney(Money + Item.CalculateResaleValue(GetEffectiveSkillLevel(psTrading)));
  Artefacts.Delete(Artefacts.IndexOf(Item));
  Item.Free;
  RefreshDerivedStats(True);
end;
{ @end $768AA0 }

{ @routine $768B0C TShip_RepairHullAtLocation }
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
        if Ship.InNormalSpace and (Ship is TNormalShip) and
          not ((Ship.TypeId = stPirate) and (Ship.OwnerId in PlanetOwnerMasks.Coalition)) and
          (Ship.TypeId <> stKling) and
          ((Ship.OwnerId in PlanetOwnerMasks.Coalition) = (OwnerId in PlanetOwnerMasks.Coalition)) then
          Inc(FriendlyCount);
      end;
      Result := GetHull.HullPoints * 5 div GetHull.Weight < FriendlyCount;
    end
    else Result := True;
  end;
end;
{ @end $768B0C }

{ @routine $768CA4 TShip_ReloadWeaponAmmo }
procedure TShip.ReloadWeaponAmmo;
var
  I: Integer;
  Weapon: TWeapon;
begin
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    if Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then Weapon.Ammo := Weapon.AmmoCapacity;
  end;
end;
{ @end $768CA4 }

{ @routine $768D00 TShip_ApplyCombatItemDegradation }
procedure TShip.ApplyCombatItemDegradation(BaseDurabilityDamage: Double);
const
  WearableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
var
  I: Integer;
  Item, Artefact: TEquipment;
begin
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.BrokenFlag = 0) and (Byte(Item.ItemType) in WearableTypes) then
      if GetDefGenerator = Item then ApplyItemDegradation(Item, idkBattle, BaseDurabilityDamage * 1.3)
      else if GetRepairRobot = Item then ApplyItemDegradation(Item, idkBattle, BaseDurabilityDamage * 1.25)
      else if Item.ItemType in [t_Weapon1..t_CustomWeapon] then ApplyItemDegradation(Item, idkBattle, BaseDurabilityDamage * 1.15)
      else ApplyItemDegradation(Item, idkBattle, BaseDurabilityDamage);
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Artefact := Artefacts[I];
    if (Artefact.BrokenFlag = 0) and (Byte(Artefact.ItemType) in WearableTypes) then
      case NextRandomIntRange(1, 10, RandomState) of
        1..6: Continue;
        7: ApplyItemDegradation(Artefact, idkBattle, BaseDurabilityDamage * 0.3);
        8: ApplyItemDegradation(Artefact, idkBattle, BaseDurabilityDamage * 0.6);
        9: ApplyItemDegradation(Artefact, idkBattle, BaseDurabilityDamage * 0.9);
        10: ApplyItemDegradation(Artefact, idkBattle, BaseDurabilityDamage * 1.2);
      end;
  end;
end;
{ @end $768D00 }

{ @routine $768F9C TShip_ApplyArtefactUseDegradation }
procedure TShip.ApplyArtefactUseDegradation(BaseDurabilityDamage: Double);
const
  WearableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
var
  I: Integer;
  Item: TEquipment;
begin
  if Artefacts.Count = 0 then Exit;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if not (Item.ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks]) then Item.Repair;
    if (Item.BrokenFlag = 0) and (Item.EquippedFlag <> 0) and (Byte(Item.ItemType) in WearableTypes) then
      ApplyItemDegradation(Item, idkUse, BaseDurabilityDamage);
  end;
end;
{ @end $768F9C }

{ @routine $769068 TShip_ApplyAfterburnerItemDegradation }
procedure TShip.ApplyAfterburnerItemDegradation;
var
  I: Integer;
  Item: TEquipment;
begin
  ApplyItemDegradation(GetEngine, idkAfterburner, GetAfterburnerWear);
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := Artefacts[I];
    if (Item.ItemType = t_ArtForsage) and (Item.EquippedFlag <> 0) then
    begin
      ApplyItemDegradation(Item, idkAfterburner, 3);
      Break;
    end;
  end;
end;
{ @end $769068 }

{ @routine $769100 TShip_ApplyItemDegradation }
function TShip.ApplyItemDegradation(Item: TEquipment; Kind: TItemDegradationKind; DurabilityDamage: Double): Boolean;
var
  BeforeScript, AfterScript, AttackCount: Integer;
  NewCondition: Double;
begin
  Result := False;
  if (GetPlayer = Self) and ((Galaxy.TechnicModEnabled = 1) or (Galaxy.SpecialSimulationMode <> 0)) then Exit;
  if Item = nil then Exit;
  if (Item is TArtefact) and not (Item.ItemType in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks]) then Exit;
  if Item.ConditionPercent < -95 then Exit;
  if (Item is TWeapon) and (Kind = idkUse) then
  begin
    AttackCount := GetAttackMultiplier;
    if AttackCount > 1 then DurabilityDamage := DurabilityDamage / AttackCount;
  end;
  if GetPlayer = Self then
  begin
    DurabilityDamage := DurabilityDamage * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[3]].EquipmentWearFactor;
    if IsHealthEffectActive(6) then DurabilityDamage := DurabilityDamage * 2;
    if IsHealthEffectActive(16) then DurabilityDamage := DurabilityDamage * 0.4;
  end;
  if CanUseEquipmentTech(Item) and (GetEffectiveSkillLevel(psTechnical) > 0) then
    DurabilityDamage := DurabilityDamage / (1 + GetEffectiveSkillLevel(psTechnical) * 0.2);
  DurabilityDamage := DurabilityDamage * Item.GetFragilityFactor(EmptyDamageFlags);
  BeforeScript := Round(DurabilityDamage * 1000);
  case Kind of
    idkBattle: AfterScript := ScriptItemsAct(satOnReduceEqBattle, Item, nil, BeforeScript);
    idkUse: AfterScript := ScriptItemsAct(satOnReduceEqUse, Item, nil, BeforeScript);
    idkForce: AfterScript := ScriptItemsAct(satOnReduceEqForce, Item, nil, BeforeScript);
    idkAfterburner: AfterScript := ScriptItemsAct(satOnReduceEqForsage, Item, nil, BeforeScript);
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
      if (TypeId = stWarrior) and (UsableWeaponCount < 3) then
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
        idkBattle: AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn, Item.GetBrokenInBattleText, '').Targets[0].ShipId := Id;
        idkUse, idkAfterburner: AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn, Item.GetBrokenInUseText, '').Targets[0].ShipId := Id;
        idkForce: AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn, Item.GetBrokenByForceText, '').Targets[0].ShipId := Id;
      end;
      PlayerEquipmentBrokenThisTurn := True;
    end;
    if (GetPlayer = Self) and (Item is TSatellite) and ((Item as TSatellite).TargetPlanet <> nil) then
    begin
      AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn, (Item as TSatellite).GetBrokenInUseText, '').Targets[0].ShipId := Id;
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
{ @end $769100 }

{ @routine $7695FC TShip_CanGenerateMicroModuleForLoadout }
function TShip.CanGenerateMicroModuleForLoadout: Boolean;
var I, Equipped, Specials: Integer; Item: TEquipment;
begin
  Result := False;
  if GetPlayer = Self then
  begin
    Result := True;
    Exit;
  end;
  if not (TypeId in [stRanger, stPirate, stWarrior]) then Exit;
  if not (((DockedTo <> nil) and (DockedTo is TRuins)) or
    ((CurrentPlanet <> nil) and (CurrentPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]))) then Exit;
  Equipped := 0;
  Specials := 0;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := TEquipment(Inventory[I]);
    if (not (Item is THull)) and (Item.EquippedFlag <> 0) then
    begin
      Inc(Equipped);
      if Item.SpecialModuleIndex <> 0 then Inc(Specials);
    end;
  end;
  Result := Specials * 100 < RemapClamped(Galaxy.TechLevel, 1, 8, 0, 100) * Equipped;
end;
{ @end $7695FC }

{ @routine $769738 TShip_CanGenerateSpecialHullModule }
function TShip.CanGenerateSpecialHullModule: Boolean;
begin
  Result := (GetPlayer = Self) or (GetHull.SpecialModuleIndex <> 0);
end;
{ @end $769738 }

{ @routine $76976C TShip_ImproveRandomEquipment }
procedure TShip.ImproveRandomEquipment(ResolveOverload: Boolean);
var Index: Integer; Item, Best: TEquipment; BestCost: Integer;
begin
  BestCost := 0;
  Best := nil;
  for Index := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[Index];
    if (NextRandomUnitFloat(RandomState) < 0.5) and IsEquipmentUsable(Item) and
      (Item.ItemType in [t_Hull..t_CustomWeapon]) and
      ((Item.EquippedFlag <> 0) or (Item.ItemType = t_Hull)) and Item.CanImprove and
      (Item.OwnerId in [oiMaloc..oiGaal, oiPirate]) and
      (not (Item is TWeapon) or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and
      (BestCost < Item.Cost) then
    begin BestCost := Item.Cost; Best := Item; end;
  end;
  if Best <> nil then
    if (Galaxy.TechLevel > 6) and (GetPlayer <> nil) and (GetPlayer.StrengthInBestRanger > 0.6) and
      ((StrengthInBestRanger < 0.5) or (NextRandomUnitFloat(RandomState) < 0.4)) then
      Best.Improve(ikMajor)
    else Best.Improve(ikAny);
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
      ((Item.EquippedFlag <> 0) or (Item.ItemType = t_Hull)) and
      (Item.MicroModuleIndex = 0) and (BestCost < Item.Cost) then
    begin BestCost := Item.Cost; Best := Item; end;
  end;
  if (Best <> nil) and (NextRandomUnitFloat(RandomState) < 0.9) then
    GenerateAndApplyMicroModule(Best, ResolveOverload);
end;
{ @end $76976C }

{ @routine $769B68 TShip_GenerateAndApplyMicroModule }
procedure TShip.GenerateAndApplyMicroModule(Item: TEquipment; ResolveOverload: Boolean);
var ModuleIndex, Attempts, Priority, Accepted, BestModule: Integer; Gain, BestGain: Single;

  // @nested $769A28 FitsGeneratedModuleCapacity
  function FitsGeneratedModuleCapacity: Boolean; // @addr 0x769A28 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; equipment -4, zero-based module index -8, ship -12. Uses strict remaining-capacity comparison."
  begin
    if Item.ItemType <> t_Hull then
      Result := (MicroModuleTemplates[ModuleIndex].SizePercent - 100) * Item.Weight * 0.01 < CargoFreeSpace
    else Result := (MicroModuleTemplates[ModuleIndex].SizePercent - 100) * (-Item.Weight) * 0.01 < CargoFreeSpace;
  end;

  // @nested $769AE0 AcceptDuplicate
  function AcceptDuplicate: Boolean; // @addr 0x769AE0 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; module index -8, ship -12. Random rejection for matching installed modules."
  var Index: Integer; Entry: TEquipment;
  begin
    Result := False;
    for Index := 0 to Inventory.Count - 1 do
    begin
      Entry := Inventory[Index];
      if (Entry.EquippedFlag <> 0) and (ModuleIndex + 1 = Entry.MicroModuleIndex) and
        (NextRandomIntRange(0, 100, RandomState) > 65) then Exit;
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
{ @end $769B68 }

{ @routine $769CD0 TShip_GenerateExtraWeapon }
procedure TShip.GenerateExtraWeapon;
var MinimumLevel, MaximumLevel: Integer; Weapon: TWeapon; Info: PWeaponInfo;
begin
  MinimumLevel := 3;
  if NextRandomUnitFloat(RandomState) < 0.05 then MaximumLevel := Galaxy.TechLevel + 1
  else MaximumLevel := Galaxy.TechLevel;
  MaximumLevel := Max(MinimumLevel, Min(MaximumLevel, 8));
  MinimumLevel := Max(1, Min(MinimumLevel, MaximumLevel - 2));
  Info := Galaxy.SelectWeaponInfo(RandomState, [Ord(waFree)], MaximumLevel, MinimumLevel);
  Weapon := CreateGeneratedWeapon(Info,
    NextRandomIntRange(Round(Info.AverageSize * EquipmentSizeFactors[5]),
      Round(Info.AverageSize * EquipmentSizeFactors[3]), RandomState),
    NextRandomIntRange(MinimumLevel, MaximumLevel, RandomState), OwnerId);
  Inventory.Add(Weapon);
  if NextRandomUnitFloat(RandomState) < 0.5 then
    if (Galaxy.TechLevel > 6) and (GetPlayer <> nil) and (GetPlayer.StrengthInBestRanger > 0.6) and
      ((StrengthInBestRanger < 0.5) or (NextRandomUnitFloat(RandomState) < 0.4)) then
      Weapon.Improve(ikMajor)
    else Weapon.Improve(ikAny);
  if NextRandomUnitFloat(RandomState) < 0.5 then GenerateAndApplyMicroModule(Weapon, True);
  AutoEquipInventory;
  OptimizeInventory;
end;
{ @end $769CD0 }

{ @routine $769F18 TShip_NeedsMicroModule }
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
  if Found then
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item is TMicroModule) and (Item.MicroModuleIndex = ModuleIndexPlusOne) then Exit;
    end;
    Result := True;
  end;
end;
{ @end $769F18 }

{ @routine $769FE0 TShip_CountUnequippedDominatorEquipment }
function TShip.CountUnequippedDominatorEquipment: Integer;
var I: Integer; Item: TEquipment;
begin
  Result := 0;
  for I := 1 to Inventory.Count - 1 do begin
    Item := TEquipment(Inventory[I]);
    if (Item.OwnerId = oiDominator) and (Item.EquippedFlag = 0) then Inc(Result);
  end;
end;
{ @end $769FE0 }

{ @routine $76A044 TShip_GetSatelliteLimit }
function TShip.GetSatelliteLimit: Integer;
begin
  Result := TechnicalSkillSatelliteLimits[GetEffectiveSkillLevel(psTechnical)] + GetTotalStatBonus(bonZonds);
end;
{ @end $76A044 }

{ @routine $76A080 TShip_IsEssentialInventoryItem }
function TShip.IsEssentialInventoryItem(Item: TItem): Boolean;
begin
  Result := False;
  if Item = nil then Exit;
  if (Item.NoDropFlag > 0) or ((Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '')) then
  begin
    Result := True;
    Exit;
  end;
  if (TEquipment(Item).EquippedFlag = 0) and (Item.ItemType <> t_Hull) then Exit;
  Result := True;
  if Item.ItemType in [t_Hull..t_Engine] then Exit;
  if (Item.ItemType in [t_Weapon1..t_CustomWeapon]) and (WeaponCount <= 1) then Exit;
  if (Item.ItemType = t_CargoHook) and (TypeId in [stRanger, stPirate]) and (GetSlotCount(sskCargoHook) > 0) then Exit;
  Result := False;
end;
{ @end $76A080 }

{ @routine $76A130 TShip_IsOptionalUtilityEquipment }
function TShip.IsOptionalUtilityEquipment(Item: TItem): Boolean;
begin
  Result := False;
  if Item <> nil then
  begin
    if Item.ItemType in [t_Radar..t_Scaner] then Result := True
    else if (Item.ItemType = t_CargoHook) and not (TypeId in [stRanger, stPirate]) then Result := True;
  end;
end;
{ @end $76A130 }

{ @routine $76A17C TShip_NeedsEssentialEquipment }
function TShip.NeedsEssentialEquipment: Boolean;
begin
  Result := True;
  if (Speed > 0) and (WeaponCount > 0) and
    (not (TypeId in [stRanger, stPirate]) or (GetCargoHook <> nil) or (GetSlotCount(sskCargoHook) <= 0)) then Result := False;
end;
{ @end $76A17C }

{ @routine $76A1D4 TShip_RestoreEssentialEquipment }
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
{ @end $76A1D4 }

{ @routine $76A430 TShip_BuyEquipmentAtLocation }
procedure TShip.BuyEquipmentAtLocation(ForceGeneratedOffers: Boolean);
var
  ReplacementWeapon: TWeapon;
  SavedWeapons: array[1..5] of TWeapon;
  SavedTarget: TObject;
  I, FreeWeight, OriginalMoney: Integer;
  BestItem, OfferItem, OldItem: TEquipment;
  Offers: TList;
  NewScore, OldScore, BestGain, NewEffectiveness, OldEffectiveness: Single;
  RestoreStock, GeneratedBatch, DifferentHullGraph, UseMoney: Boolean;
  SavedNextItemId: Cardinal;
  Bought: Boolean;
  UnusedNativeFrame: array[0..7] of Byte; // EBP-$74..-$6D are never accessed in the native frame; original local types are unknown.

  // @nested $76A290 SelectReplacedWeapon
  function SelectReplacedWeapon: TWeapon; // @addr 0x76A290 @ida "TWeapon *__cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4. Selects the lowest evaluated weapon when all slots are occupied."
  var J, Best: Integer;
  begin
    Result := nil;
    if GetSlotCount(sskWeapon) > WeaponCount then Exit;
    Best := 1;
    for J := 2 to WeaponCount do
      if EvaluateItem(Weapons[Best], 3) > EvaluateItem(Weapons[J], 3) then Best := J;
    Result := Weapons[Best];
  end;

  // @nested $76A350 TemporarilyUnequipWeapon
  procedure TemporarilyUnequipWeapon(Weapon: TWeapon); // @addr 0x76A350 @note "Caller-popped static link; ship -4, fallback weapon -8; saves five weapon pointers and target at -32."
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
    if WeaponIndex <> 0 then
    begin
      SavedTarget := Selected.Target;
      UnequipSlot(Selected.ItemType, WeaponIndex);
    end;
  end;

  // @nested $76A3DC RestoreWeapon
  procedure RestoreWeapon; // @addr 0x76A3DC @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4, weapon -8; restores saved target and weapon pointers."
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
      (not (Self is TWarrior) or ((Self as TWarrior).WarriorType <> wtFlagship)) then
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
      (not (Self is TWarrior) or ((Self as TWarrior).WarriorType <> wtFlagship)) then
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
      OldItem := TEquipment(Inventory[I]);
      if (OldItem.ItemType <> t_Hull) and (OldItem.EquippedFlag <> 0) and
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
    OfferItem := TEquipment(Offers[I]);
    if not (OfferItem.ItemType in [t_Hull..t_CustomWeapon]) or
      ((OfferItem.ScriptItem <> nil) and (TScriptItem(OfferItem.ScriptItem).Name <> '')) or
      (OfferItem.NoDropFlag > 0) or
      (not (OfferItem.ItemType in [t_Hull..t_Engine]) and (GetSlotCountForItemType(OfferItem.ItemType) = 0)) then Continue;
    if OfferItem.ItemType = t_Hull then
    begin
      if (Self is TRuins) or (GetHull.HullType <> (OfferItem as THull).HullType) or
        (GetHull.OwnerId <> OfferItem.OwnerId) or
        (((OfferItem as THull).SpecialModuleIndex = 0) <> (GetHull.SpecialModuleIndex = 0)) then Continue;
      if GetHull.SpecialModuleIndex <> 0 then
      begin
        GetHull.OwnerShip := nil;
        DifferentHullGraph := (OfferItem as THull).GetSpecialKindGraph <> GetHull.GetSpecialKindGraph;
        GetHull.OwnerShip := Self;
        if DifferentHullGraph then Continue;
      end;
    end;
    if OfferItem is TWeapon then OldItem := ReplacementWeapon
    else OldItem := PShipEquipmentCacheView(Self).Slots[OfferItem.ItemType];
    if (OfferItem.ItemType in [t_FuelTanks..t_Engine]) and (OldItem = nil) and
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
      if ((OfferItem.ItemType <> t_Hull) and (FreeWeight + OldItem.Weight - OfferItem.Weight < 0)) or
        ((OfferItem.ItemType = t_Hull) and (FreeWeight - OldItem.Weight + OfferItem.Weight < 0)) or
        ((OldItem.ScriptItem <> nil) and (TScriptItem(OldItem.ScriptItem).Name <> '')) or
        (OldItem.NoDropFlag > 0) then Continue;
      if OldItem is TWeapon then TemporarilyUnequipWeapon(nil)
      else if not (OldItem is THull) then UnequipSlot(OldItem.ItemType, 0);
      OldEffectiveness := CalculateItemEffectiveness(OldItem);
      NewEffectiveness := CalculateItemEffectiveness(OfferItem);
      if TypeId = stRanger then
        if AdjustItemEvaluation(OfferItem, 2, NewEffectiveness) * 1.2 > AdjustItemEvaluation(OldItem, 2, OldEffectiveness) then
          if Money < OfferItem.Cost then EquipmentPriceSensitivity := 0.99 * EquipmentPriceSensitivity + 0.01
          else EquipmentPriceSensitivity := 0.99 * EquipmentPriceSensitivity;
      if UseMoney and (OldItem.CalculateResaleValue(GetEffectiveSkillLevel(psTrading)) + Money - OfferItem.Cost < 0) then
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
  if BestItem <> nil then
  begin
    if BestItem is TWeapon then OldItem := ReplacementWeapon
    else OldItem := PShipEquipmentCacheView(Self).Slots[BestItem.ItemType];
    Offers.Delete(Offers.IndexOf(BestItem));
    Bought := True;
    if OldItem <> nil then
    begin
      if OldItem is TWeapon then TemporarilyUnequipWeapon(nil)
      else UnequipSlot(OldItem.ItemType, 0);
      if UseMoney then SetMoney(OldItem.CalculateResaleValue(GetEffectiveSkillLevel(psTrading)) + Money);
      Inventory.Delete(Inventory.IndexOf(OldItem));
      OldItem.Free;
    end;
    if UseMoney then SetMoney(Money - BestItem.Cost);
    if BestItem is THull then Inventory.Insert(0, BestItem) else Inventory.Add(BestItem);
    EquipItem(BestItem);
    if BestItem is THull then RefreshGraphicSize;
  end;
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
{ @end $76A430 }

{ @routine $76AF14 TShip_CreateAndEquipHull }
function TShip.CreateAndEquipHull(Capacity: Word; Level: Byte; Owner: TOwnerId; Series: Integer; PirateBuilt: Boolean): THull;
var
  Item: THull;
  Kind: Byte;
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
{ @end $76AF14 }

{ @routine $76AF9C TShip_SelectRandomHullSeries }
function TShip.SelectRandomHullSeries: Integer;
begin
  if Self is TNormalShip then Result := Galaxy.SelectHullSeries(RaceToOwner(PilotRace), GetDefaultHullType, 1, 100)
  else Result := Galaxy.SelectHullSeries(OwnerId, GetDefaultHullType, 1, 100);
end;
{ @end $76AF9C }

{ @routine $76B010 TShip_CreateAndEquipFuelTanks }
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
{ @end $76B010 }

{ @routine $76B06C TShip_CreateAndEquipEngine }
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
{ @end $76B06C }

{ @routine $76B0C8 TShip_CreateAndEquipRadar }
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
{ @end $76B0C8 }

{ @routine $76B124 TShip_CreateAndEquipScanner }
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
{ @end $76B124 }

{ @routine $76B180 TShip_CreateAndEquipRepairRobot }
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
{ @end $76B180 }

{ @routine $76B1DC TShip_CreateAndEquipCargoHook }
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
{ @end $76B1DC }

{ @routine $76B238 TShip_CreateAndEquipDefGenerator }
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
{ @end $76B238 }

{ @routine $76B294 TShip_CreateAndEquipWeapon }
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
{ @end $76B294 }

{ @routine $76B2F4 TShip_ScanForCollectableItems }
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
{ @end $76B2F4 }

{ @routine $76B3D4 TShip_QueueItemsWithinPickupRange }
procedure TShip.QueueItemsWithinPickupRange;
var I: Integer; Item: TItem;
begin
  if IsEquipmentUsable(GetCargoHook) and (Speed > 0) then
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if IsItemInPickupRange(Item) and not IsRecentlyDroppedItem(Item) and AcceptPickupItem(Item) and ShouldPickUpItem(Item) then AddPickupTarget(Item, False);
    end;
end;
{ @end $76B3D4 }

{ @routine $76B490 TShip_TryCollectBestFloatingItem }
function TShip.TryCollectBestFloatingItem(MaximumTravelTurns: Integer): Boolean;
var I: Integer; Item, BestItem: TItem; Found: Boolean; Distance, BestDistance: Double; Drop: PMovingDropItemEntry; ItemPosition: TPointF;
begin
  Result := False;
  if IsEquipmentUsable(GetCargoHook) and (Speed >= 1) then begin
    Found := False;
    BestItem := nil;
    BestDistance := 10000;
    for I := 0 to CurrentStar.Items.Count - 1 do begin
      Item := CurrentStar.Items[I];
      if CanCargoHookHandleItem(Item, Self) and not IsRecentlyDroppedItem(Item) and AcceptPickupItem(Item) and ShouldPickUpItem(Item) and
        ((CountOtherShipsTargetingItem(Item) < 2) or CanReachItemBeforeOtherShips(Item)) then begin
        if IsItemInPickupRange(Item) then AddPickupTarget(Item, False)
        else begin
          Distance := PointDistance(Position, Item.Position);
          if (MaximumTravelTurns >= Distance / Speed) and AcceptPickupDistance(Item, Distance) and
            (not OrderAbsolute or (Order = soMove)) and ((BestItem = nil) or
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
      if CanCargoHookHandleItem(Item, Self) and not IsRecentlyDroppedItem(Item) and AcceptPickupItem(Item) and ShouldPickUpItem(Item) then begin
        Distance := PointDistance(Position, Drop.Destination);
        if (MaximumTravelTurns >= Distance / Speed) and AcceptPickupDistance(Item, Distance) and
          (not OrderAbsolute or (Order = soMove)) and ((BestItem = nil) or
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
    if not Found and (Order = soMove) then OrderNone(False);
    if Order = soMove then Result := True;
  end;
end;
{ @end $76B490 }

{ @routine $76B888 TShip_GetReservedPickupWeight }
function TShip.GetReservedPickupWeight: Integer;
var I: Integer; Item: TItem;
begin
  Result := 0;
  if PickupTargets <> nil then
    for I := 0 to PickupTargets.Count - 1 do begin
      Item := TItem(PickupTargets[I]);
      Inc(Result, Item.Weight);
    end;
end;
{ @end $76B888 }

{ @routine $76B8EC TShip_IsItemInPickupRange }
function TShip.IsItemInPickupRange(Item: TItem): Boolean;
begin
  Result := CanCargoHookHandleItem(Item, Self) and
    (PointDistanceSquared(Position, Item.Position) <= GetCargoHookRangeSquared);
end;
{ @end $76B8EC }

{ @routine $76B944 TShip_AcceptPickupItem }
function TShip.AcceptPickupItem(Item: TItem): Boolean;
begin
  Result := False;
end;
{ @end $76B944 }

{ @routine $76B95C TShip_ShouldPickUpItem }
function TShip.ShouldPickUpItem(Item: TItem): Boolean;
var I, EquippedWeight: Integer; Other: TEquipment; EquippedValue: Single; LooseWeight, LooseCost: Integer;
begin
  Result := True;
  if ((PickupTargets <> nil) and (PickupTargets.IndexOf(Item) >= 0) and (CargoFreeSpace > 0)) or
    ((CargoFreeSpace - GetReservedPickupWeight >= Item.Weight) and ((Galaxy.SpecialSimulationMode = 0) or (Item is TMicroModule))) or
    ((Item is TCountableItem) and (CargoFreeSpace - GetReservedPickupWeight > 0) and (Galaxy.SpecialSimulationMode = 0)) or
    ((Item is TGoods) and (CargoFreeSpace - GetReservedPickupWeight > 0) and (Galaxy.SpecialSimulationMode = 0)) then Exit;
  Result := False;
  if (Item.ItemType in [t_Hull..t_DefGenerator]) and IsEquipmentUsable(Item as TEquipment) then begin
    for I := 1 to Inventory.Count - 1 do begin
      Other := Inventory[I];
      if (Item.ItemType = Other.ItemType) and (Other.Weight + CargoFreeSpace > Item.Weight) and (Other.EquippedFlag <> 0) then
        if EvaluateItem(Item, 1) > EvaluateItem(Other, 1) then begin Result := True; Exit; end;
    end;
  end else if (Item.ItemType in [t_Weapon1..t_CustomWeapon]) and IsEquipmentUsable(Item as TEquipment) then begin
    EquippedWeight := 0;
    EquippedValue := 0;
    for I := 1 to Inventory.Count - 1 do begin
      Other := Inventory[I];
      if (Other.ItemType in [t_Weapon1..t_CustomWeapon]) and (Other.EquippedFlag <> 0) then begin
        EquippedValue := EquippedValue + EvaluateItem(Other, 1);
        Inc(EquippedWeight, Other.Weight);
      end;
    end;
    if (EquippedWeight + CargoFreeSpace >= Item.Weight) and
      (EvaluateItem(Item, 1) / Max(1, Item.Weight) > EquippedValue / Max(1, EquippedWeight)) then begin Result := True; Exit; end;
  end;
  if Galaxy.SpecialSimulationMode = 0 then begin
    LooseWeight := 0;
    LooseCost := 0;
    for I := 1 to Inventory.Count - 1 do begin
      Other := Inventory[I];
      if Other.EquippedFlag = 0 then begin Inc(LooseWeight, Other.Weight); Inc(LooseCost, Other.Cost); end;
    end;
    Result := (LooseWeight + CargoFreeSpace >= Item.Weight) and
      (Item.Cost / Max(1, Item.Weight) > LooseCost / Max(1, LooseWeight));
  end;
end;
{ @end $76B95C }

{ @routine $76BD24 TShip_AcceptPickupDistance }
function TShip.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  Result := True;
end;
{ @end $76BD24 }

{ @routine $76BD40 TShip_AddPickupTarget }
procedure TShip.AddPickupTarget(Item: TItem; Prioritize: Boolean);
begin
  if PickupTargets = nil then PickupTargets := TList.Create;
  if PickupTargets.IndexOf(Item) < 0 then
    if Prioritize then PickupTargets.Insert(0, Item) else PickupTargets.Add(Item);
end;
{ @end $76BD40 }

{ @routine $76BDB8 TShip_RemovePickupTarget }
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
{ @end $76BDB8 }

{ @routine $76BE28 TShip_ClearPickupTargets }
procedure TShip.ClearPickupTargets;
begin
  if PickupTargets <> nil then
  begin
    PickupTargets.Free;
    PickupTargets := nil;
  end;
end;
{ @end $76BE28 }

{ @routine $76BE58 TShip_RemoveInvalidPickupTargets }
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
{ @end $76BE58 }

{ @routine $76BF30 TShip_TogglePickupTargets }
procedure TShip.TogglePickupTargets(IgnoreRange: Boolean);
var
  I: Integer;
  Item: TItem;
  Added: Boolean;
// @nested $76BEE4 AcceptPickupTarget
function AcceptPickupTarget(Item: TItem): Boolean; // @addr 0x76BEE4 @note "Caller-popped static link; mode -1, ship -8."
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
    Item := TItem(CurrentStar.Items[I]);
    if AcceptPickupTarget(Item) and not HasPickupTarget(Item) then
    begin
      AddPickupTarget(Item, False);
      Added := True;
    end;
  end;
  if not Added then
    for I := 0 to CurrentStar.Items.Count - 1 do
    begin
      Item := TItem(CurrentStar.Items[I]);
      if AcceptPickupTarget(Item) then RemovePickupTarget(Item);
    end;
end;
{ @end $76BF30 }

{ @routine $76C004 TShip_HasPickupTarget }
function TShip.HasPickupTarget(Item: TItem): Boolean;
begin
  Result := False;
  if PickupTargets <> nil then
    if PickupTargets.IndexOf(Item) >= 0 then Result := True;
end;
{ @end $76C004 }

{ @routine $76C040 TShip_CountOtherShipsTargetingItem }
function TShip.CountOtherShipsTargetingItem(Item: TItem): Integer;
var
  I, Count: Integer;
  Ship: TShip;
begin
  Count := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if (Ship <> Self) and (Ship.PickupTargets <> nil) and (Ship.PickupTargets.IndexOf(Item) >= 0) then Inc(Count);
  end;
  Result := Count;
end;
{ @end $76C040 }

{ @routine $76C0C4 TShip_CanReachItemBeforeOtherShips }
function TShip.CanReachItemBeforeOtherShips(Item: TItem): Boolean;
var I: Integer; Ship: TShip;
begin
  if Speed < 1 then begin Result := False; Exit; end;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship <> Self) and Ship.InNormalSpace and (Ship.Speed >= 1) then
      if (Ship.GetPickupApproachPosition(Item.Position).X = Ship.OrderDestination.X) and
        (Ship.GetPickupApproachPosition(Item.Position).Y = Ship.OrderDestination.Y) then
        if PointDistance(Ship.Position, Item.Position) / Ship.Speed < PointDistance(Position, Item.Position) / Speed then begin Result := False; Exit; end;
  end;
  Result := True;
end;
{ @end $76C0C4 }

{ @routine $76C1F0 TShip_GetPickupApproachPosition }
function TShip.GetPickupApproachPosition(ItemPosition: TPointF): TPointF;
var
  Direction: Integer;
begin
  if ItemPosition.X < Position.X then Direction := -1 else Direction := 1;
  Result.X := ItemPosition.X + (GetCargoHookRange div 2) * Direction;
  if ItemPosition.Y < Position.Y then Direction := -1 else Direction := 1;
  Result.Y := ItemPosition.Y + (GetCargoHookRange div 2) * Direction;
end;
{ @end $76C1F0 }

{ @routine $76C28C TShip_GetCurrentPickupItem }
function TShip.GetCurrentPickupItem: TItem;
var
  I: Integer;
  Item: TItem;
begin
  Result := nil;
  for I := 0 to CurrentStar.Items.Count - 1 do
  begin
    Item := TItem(CurrentStar.Items[I]);
    if (PickupTargets <> nil) and (PickupTargets.IndexOf(Item) >= 0) then
    begin
      Result := Item;
      Exit;
    end;
    if (Order = soMove) and (GetPickupApproachPosition(Item.Position).X = OrderDestination.X) and
      (GetPickupApproachPosition(Item.Position).Y = OrderDestination.Y) then
    begin
      Result := Item;
      Exit;
    end;
  end;
end;
{ @end $76C28C }

{ @routine $76C364 TShip_ClearRecentlyDroppedItems }
procedure TShip.ClearRecentlyDroppedItems;
begin
  if RecentlyDroppedItemIds <> nil then
  begin
    RecentlyDroppedItemIds.Free;
    RecentlyDroppedItemIds := nil;
  end;
end;
{ @end $76C364 }

{ @routine $76C394 TShip_AddRecentlyDroppedItem }
procedure TShip.AddRecentlyDroppedItem(Item: TItem);
begin
  if RecentlyDroppedItemIds = nil then RecentlyDroppedItemIds := TList.Create;
  if RecentlyDroppedItemIds.IndexOf(Pointer(Item.Id)) < 0 then
    RecentlyDroppedItemIds.Add(Pointer(Item.Id));
end;
{ @end $76C394 }

{ @routine $76C3F4 TShip_IsRecentlyDroppedItem }
function TShip.IsRecentlyDroppedItem(Item: TItem): Boolean;
begin
  Result := False;
  if (RecentlyDroppedItemIds <> nil) and (RecentlyDroppedItemIds.IndexOf(Pointer(Item.Id)) >= 0) then Result := True;
end;
{ @end $76C3F4 }

{ @routine $76C434 TShip_OrderNone }
procedure TShip.OrderNone(OverrideScriptOrder: Boolean);
begin
  if (AbsoluteScriptOrder > 0) and not OverrideScriptOrder then Exit;
  OrderAbsolute := False;
  Order := soNone;
  OrderTarget := nil;
  ClearMovementPath;
end;
{ @end $76C434 }

{ @routine $76C480 TShip_OrderMove }
procedure TShip.OrderMove(Destination: TPointF; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := soMove;
  OrderDestination := Destination;
  OrderAbsolute := Absolute;
  OrderTarget := nil;
end;
{ @end $76C480 }

{ @routine $76C4F8 TShip_GetJumpDeparturePoint }
function TShip.GetJumpDeparturePoint(Destination: TStar): TPointF;
var Angle, Radius: Double;
begin
  Angle := HeadingDegreesToRadians(PointBearingDegrees(CurrentStar.Position, Destination.Position) +
    SeededRandomIntRange(-4, 4, (CurrentStar.GenerationSeed + Seed) * Destination.GenerationSeed));
  Radius := CurrentStar.ComputeMapDiameter / 2;
  Result.X := Trunc(Sin(Angle) * Radius);
  Result.Y := Trunc(-Cos(Angle) * Radius);
end;
{ @end $76C4F8 }

{ @routine $76C5D4 TShip_GetArrivalPosition }
function TShip.GetArrivalPosition(DestinationStar: TStar): TPointF;
var
  Angle, Radius: Double;
begin
  Angle := HeadingDegreesToRadians(PointBearingDegrees(DestinationStar.Position, CurrentStar.Position));
  Radius := DestinationStar.ComputeMapDiameter / 2;
  Result.X := Trunc(Sin(Angle) * Radius);
  Result.Y := Trunc(-Cos(Angle) * Radius);
end;
{ @end $76C5D4 }

{ @routine $76C678 TShip_CalculateJumpTravelDays }
function TShip.CalculateJumpTravelDays(Origin, Destination: TStar): Integer;
begin
  Result := Max(2, Round(PointDistance(Origin.Position, Destination.Position) * 0.1) + 1);
end;
{ @end $76C678 }

{ @routine $76C6F8 TShip_OrderJump }
procedure TShip.OrderJump(Star: TStar; Absolute: Boolean);
begin
  if (AbsoluteScriptOrder > 0) or (CurrentStar = Star) then Exit;
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := soJump;
  OrderTarget := Star;
  OrderAbsolute := Absolute;
  OrderDestination := GetJumpDeparturePoint(Star);
  OrderStateData := CalculateJumpTravelDays(CurrentStar, Star);
end;
{ @end $76C6F8 }

{ @routine $76C7A0 TShip_OrderJumpHole }
procedure TShip.OrderJumpHole(Hole: THole; Absolute: Boolean);
begin
  if not HasPositiveSpeed then
  begin
    OrderNone(False);
    Exit;
  end;
  Order := soJumpHole;
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
{ @end $76C7A0 }

{ @routine $76C848 TShip_OrderTeleport }
procedure TShip.OrderTeleport(Star: TStar; Destination: TPointF; TransitionData: Integer; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  Order := soTeleport;
  OrderTarget := Star;
  OrderAbsolute := Absolute;
  OrderDestination := Destination;
  OrderStateData := TransitionData;
end;
{ @end $76C848 }

{ @routine $76C8B4 TShip_OrderLanding }
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
  Order := soLand;
  OrderTarget := Location;
  OrderDestination := MakePointF(0, 0);
  OrderAbsolute := Absolute;
end;
{ @end $76C8B4 }

{ @routine $76C940 TShip_OrderTakeoff }
procedure TShip.OrderTakeoff;
var
  Angle: Double;
  Conflict: Boolean;
  I, Count, Attempt: Integer;
  Ship: TShip;
  DY, DX: Single;
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
    Order := soTakeoff;
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
        Ship := TShip(CurrentStar.Ships[I]);
        if (Ship <> Self) and (Ship.Order = soTakeoff) and (Ship.CurrentPlanet = CurrentPlanet) and
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
    Order := soTakeoff;
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
{ @end $76C940 }

{ @routine $76CE94 TShip_OrderFollowShip }
procedure TShip.OrderFollowShip(Ship: TShip; FollowMode: Byte; Absolute: Boolean);
begin
  if AbsoluteScriptOrder > 0 then Exit;
  OrderNone(False);
  Order := soFollowShip;
  OrderTarget := Ship;
  OrderStateData := FollowMode;
  OrderAbsolute := Absolute;
end;
{ @end $76CE94 }

{ @routine $76CEF0 TShip_GetMovementPathTurnCount }
function TShip.GetMovementPathTurnCount: Integer;
begin
  Result := Ceil(MovementPath.NodeCount * CurrentStar.MovementStepScale);
end;
{ @end $76CEF0 }

{ @routine $76D098 TShip_PrepareTurnMovement }
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
  K: Byte;
  Item: TItem;
  PickupDistance: Single;
  PickupNode: PSPathNode;
  CanLand: Boolean;
  Effect: TObjectSE;
// @nested $76CF2C InitializeFilm
procedure InitializeFilm(Alpha: Byte); // @addr 0x76CF2C @note "Caller-popped static link; step index -4, ship -8."
begin
  TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, FilmObject, Position);
  TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, FilmObject, HeadingDegreesToByte(MovementDirection));
  TEFilm(PrimaryFilm).SetObjectAlpha(StartStepIndex, FilmObject, Alpha);
  TEFilm(PrimaryFilm).AttachObject(StartStepIndex, FilmObject);
  if AuxiliaryFilmObject <> nil then
  begin
    TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, AuxiliaryFilmObject, Position);
    TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, AuxiliaryFilmObject, HeadingDegreesToByte(MovementDirection));
    TEFilm(PrimaryFilm).SetObjectAlpha(StartStepIndex, AuxiliaryFilmObject, AuxiliaryFilmObject.SceneObject.GetAlpha);
    TEFilm(PrimaryFilm).AttachObject(StartStepIndex, AuxiliaryFilmObject);
  end;
end;
begin
  FilmObject := nil;
  AuxiliaryFilmObject := nil;
  PickupPathUpdatesAllowed := InNormalSpace and (Order <> soTeleport);
  if PickupPathUpdatesAllowed and ((Order = soLand) or (Order = soJump) or (Order = soJumpHole)) then
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
  if (GetPlayer = Self) and (Order = soJump) and InNormalSpace then
    if GetFuelTanks.Fuel < Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
    begin
      AddOrUpdatePlayerBubble(pmShipNegative, Galaxy.CurrentTurn,
        FormatText1(LocalizedText('Items.FuelTanks.NoFuelJump'), '<color=255,240,100>', '<Star>', (OrderTarget as TStar).Name), '').Targets[0].ShipId := Id;
      OrderMove(OrderDestination, False);
    end;
  if RecordFilm and ((Order <> soNone) or not IsOnPlanet) and ((Order <> soNone) or not IsDockedToShip) then
  begin
    FilmObject := TEFilm(PrimaryFilm).AddObject(Id, Graphic);
    if Graphic is TShip2SE then
    begin
      if AfterburnerActive then TEFilm(PrimaryFilm).SetShipSizeAndTailMode(StartStepIndex, FilmObject, Graphic.Size, 2)
      else TEFilm(PrimaryFilm).SetShipSizeAndTailMode(StartStepIndex, FilmObject, Graphic.Size, 1);
    end
    else if (Graphic is TRuinsSE) and (Graphic as TRuinsSE).HasTransitionImages then
      TEFilm(PrimaryFilm).SetRuinsState(StartStepIndex, FilmObject, 1);
    if InterceptorGraphic <> nil then AuxiliaryFilmObject := TEFilm(PrimaryFilm).AddObject(Id, InterceptorGraphic);
  end;
  if Order = soNone then
  begin
    if not InHyperspace then if RecordFilm and not IsOnPlanet and not IsDockedToShip then
    begin
      InitializeFilm(255);
      if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
    end;
  end
  else if Order = soMove then
  begin
    FilmAlpha := 255;
    FilmAlphaStep := 0;
    if RecordFilm then
    begin
      InitializeFilm(255);
      if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, OrderDestination, True);
    end;
  end
  else if Order = soLand then
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
          TEFilm(PrimaryFilm).SetObjectAlpha(StartStepIndex, FilmObject, 255);
          if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
        end
        else FilmAlpha := 0;
        AfterburnerActive := False;
        OrderStateData := 1;
      end;
    end
    else if RecordFilm then
    begin
      TEFilm(PrimaryFilm).SetObjectAlpha(StartStepIndex, FilmObject, 255);
      if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, TargetPosition, True);
    end;
  end
  else if Order = soTeleport then
  begin
    if not InHyperspace then
    begin
      if RecordFilm then
      begin
        if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
        if (FilmObject.SceneObject is TRuinsSE) and TRuinsSE(FilmObject.SceneObject).HasTransitionImages then
          TEFilm(PrimaryFilm).SetRuinsState(StartStepIndex, FilmObject, 2)
        else
        begin
          Effect := TGAIEffectSE.Create('Effect.TeleportOut', Classes.Point(0, 0));
          EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Effect);
          TEFilm(PrimaryFilm).SetEffectImagePosition(StartStepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
          FilmAlpha := 510;
          if (OrderStateData <= 0) and (OrderTarget = CurrentStar) then
          begin
            TEFilm(PrimaryFilm).SetEffectDurationScale(StartStepIndex, EffectFilm, 0.5);
            FilmAlphaStep := -7.65;
          end
          else
          begin
            TEFilm(PrimaryFilm).SetEffectDurationScale(StartStepIndex, EffectFilm, 1);
            FilmAlphaStep := -3.825;
          end;
          TEFilm(PrimaryFilm).AttachObject(StartStepIndex + 1, EffectFilm);
          TEFilm(PrimaryFilm).PlayObjectSound(StartStepIndex + 1, FilmObject, 'Sound.TeleportOut');
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
            TEFilm(PrimaryFilm).SetRuinsState(StartStepIndex, FilmObject, 3);
            InitializeFilm(255);
          end
          else
          begin
            Effect := TGAIEffectSE.Create('Effect.TeleportIn', Classes.Point(0, 0));
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Effect);
TEFilm(PrimaryFilm).SetEffectImagePosition(StartStepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
TEFilm(PrimaryFilm).SetEffectDurationScale(StartStepIndex, EffectFilm, 1);
TEFilm(PrimaryFilm).AttachObject(StartStepIndex + 1, EffectFilm);
            TEFilm(PrimaryFilm).PlayObjectSound(StartStepIndex + 1, FilmObject, 'Sound.TeleportIn');
            FilmAlpha := -255;
            FilmAlphaStep := 3.825;
            InitializeFilm(0);
          end;
          if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, True);
          if (Self is TRuins) and (TypeId = Byte(rstDominion)) and (TransitOriginStar = CurrentStar) then TRuins(Self).ReportAbductionOutcome;
        end
        else
        begin
          FilmAlpha := 255;
          FilmAlphaStep := 0;
        end;
      end;
    end;
  end
  else if Order = soJump then
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
        if (CurrentStar.ControlFaction = sfCoalition) and (TStar(OrderTarget).ControlFaction = sfCoalition) then
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            if CurrentStar.StarDistances[I].Distance > 40 then Break;
            Star := CurrentStar.StarDistances[I].Star;
            if (Star.Dominion <> nil) and ((GetPlayer <> Self) or Star.IsConstellationVisible) then TRuins(Star.Dominion).TryAbductDepartingShip(Self);
          end;
        if RecordFilm then
        begin
          if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
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
            if GiResourceVariant = 2 then Gate.Gate.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5)))
else Gate.Gate.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800)));
Gate.Gate.SetPosition(MakePointF(Point.X + Sin(HeadingDegreesToRadians(Angle)) * 180, Point.Y - Cos(HeadingDegreesToRadians(Angle)) * 180));
Gate.Gate.SetAngle(HeadingDegreesToByte(Angle) + 127);
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Gate.Gate);
TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, EffectFilm, Gate.Gate.Position);
TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, EffectFilm, Gate.Gate.GetAngle);
TEFilm(PrimaryFilm).SetGateSize(StartStepIndex, EffectFilm, Gate.Gate.Size.X);
TEFilm(PrimaryFilm).SetGateState(StartStepIndex, EffectFilm, 0);
TEFilm(PrimaryFilm).OpenGate(StartStepIndex, EffectFilm);

            if not (Self is TKling) and not AbductedByPirateClan then
              if GetJumpRange >= Round(PointDistance((OrderTarget as TStar).Position, CurrentStar.Position)) then
                if ((OrderTarget as TStar).Constellation.Id <> 20) or (OrderTarget as TStar).IsConstellationVisible then
                  TEFilm(PrimaryFilm).SetObjectText(StartStepIndex, EffectFilm, (OrderTarget as TStar).Name);
            TEFilm(PrimaryFilm).AttachObject(StartStepIndex, EffectFilm);
            if Gate.Effect = nil then TEFilm(PrimaryFilm).PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJump')
            else
            begin
              TEFilm(PrimaryFilm).PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJumpAbducted');
              if GiResourceVariant = 2 then Gate.Effect.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5)))
else Gate.Effect.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800)));
Gate.Effect.SetPosition(MakePointF(Point.X + Sin(HeadingDegreesToRadians(Angle)) * 180, Point.Y - Cos(HeadingDegreesToRadians(Angle)) * 180));
Gate.Effect.SetAngle(HeadingDegreesToByte(Angle) + 127);
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Gate.Effect);
TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, EffectFilm, Gate.Effect.Position);
TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, EffectFilm, Gate.Effect.GetAngle);
TEFilm(PrimaryFilm).SetGateEffectSize(StartStepIndex, EffectFilm, Gate.Effect.Size.X);

              TEFilm(PrimaryFilm).AttachObject(StartStepIndex, EffectFilm);
            end;

          end;
        end;
      end
      else if RecordFilm and (GetPlayer = Self) then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, OrderDestination, False);
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
          Dec(OrderStateData, Min(CountActiveArtefacts(t_ArtGiperJump) * (Integer(CanBoostArtefact(t_ArtGiperJump, nil, False)) + 1), Cardinal(OrderStateData)));
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
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Effect);
TEFilm(PrimaryFilm).SetEffectImagePosition(StartStepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
TEFilm(PrimaryFilm).SetEffectDurationScale(StartStepIndex, EffectFilm, 0.5);
TEFilm(PrimaryFilm).AttachObject(StartStepIndex + 1, EffectFilm);
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
        Order := soMove;
        AppendHyperspaceTransitionPath(-1);
        if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
        if RecordFilm then
        begin
          FilmAlphaStep := 510 / MovementPath.NodeCount;
          InitializeFilm(0);
          if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, True);
          if PlayerStar = CurrentStar then
          begin
            Distance := PointDistance(Position, OrderDestination);
            Gate := Galaxy.CreateJumpGate(AbductedByPirateClan or ((GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil)));
            if GiResourceVariant = 2 then Gate.Gate.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5)))
else Gate.Gate.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800)));
Gate.Gate.SetPosition(MakePointF(OrderDestination.X + (Position.X - OrderDestination.X) / Distance * 150, OrderDestination.Y + (Position.Y - OrderDestination.Y) / Distance * 150));
Gate.Gate.SetAngle(HeadingDegreesToByte(MovementDirection));
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Gate.Gate);
TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, EffectFilm, Gate.Gate.Position);
TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, EffectFilm, Gate.Gate.GetAngle);
TEFilm(PrimaryFilm).SetGateSize(StartStepIndex, EffectFilm, Gate.Gate.Size.X);
TEFilm(PrimaryFilm).SetGateState(StartStepIndex, EffectFilm, 0);
TEFilm(PrimaryFilm).OpenGate(StartStepIndex, EffectFilm);

            if TransitOriginStar <> nil then
              if not AbductedByPirateClan and not (Self is TKling) then
                if (GetJumpRange >= Round(PointDistance(TransitOriginStar.Position, CurrentStar.Position))) and
                  ((TransitOriginStar.Constellation.Id <> 20) or TransitOriginStar.IsConstellationVisible) then
                  TEFilm(PrimaryFilm).SetObjectText(StartStepIndex, EffectFilm, TransitOriginStar.Name);
            TEFilm(PrimaryFilm).AttachObject(StartStepIndex, EffectFilm);
            TEFilm(PrimaryFilm).PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJump');
            if Gate.Effect <> nil then
            begin
              if GiResourceVariant = 2 then Gate.Effect.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5)))
else Gate.Effect.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800)));
Gate.Effect.SetPosition(MakePointF(OrderDestination.X + (Position.X - OrderDestination.X) / Distance * 150, OrderDestination.Y + (Position.Y - OrderDestination.Y) / Distance * 150));
Gate.Effect.SetAngle(HeadingDegreesToByte(MovementDirection));
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Gate.Effect);
TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, EffectFilm, Gate.Effect.Position);
TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, EffectFilm, Gate.Effect.GetAngle);
TEFilm(PrimaryFilm).SetGateEffectSize(StartStepIndex, EffectFilm, Gate.Effect.Size.X);

              TEFilm(PrimaryFilm).AttachObject(StartStepIndex, EffectFilm);
            end;
          end;
          if GetPlayer = Self then
          begin
            TEFilm(PrimaryFilm).SetViewCenter(StartStepIndex, OrderDestination);
            TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, OrderDestination, False);
            for K := 0 to 2 do GetPlayer.ChameleonDetected[K] := False;
            GetPlayer.ReportIdleSatellites(GetPlayer.CurrentStar);
            TryAddAchievementProgress('JUMPER', 1);
          end;
        end;
        if (GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil) then GetPlayer.QueuedTravelTarget := nil;
      end;
    end;
  end
  else if Order = soJumpHole then
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
            TEFilm(PrimaryFilm).SetObjectAlpha(StartStepIndex, FilmObject, 255);
            if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
          end
          else FilmAlpha := 0;
        end;
      end
      else if RecordFilm then
      begin
        TEFilm(PrimaryFilm).SetObjectAlpha(StartStepIndex, FilmObject, 255);
        if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, OrderDestination, True);
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
            TEFilm(PrimaryFilm).SetViewCenter(StartStepIndex, Position);
            TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
            for K := 0 to 2 do GetPlayer.ChameleonDetected[K] := False;
            GetPlayer.ReportIdleSatellites(GetPlayer.CurrentStar);
          end;
        end;
      end;
    end;
  end
  else if Order = soTakeoff then
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
        TEFilm(PrimaryFilm).SetViewCenter(StartStepIndex, Position);
        TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, Position, False);
      end;
    end;
    if (GetPlayer = Self) and (GetPlayer.QueuedTravelTarget <> nil) then
    begin
      FilmAlphaStep := 5.1;
      OrderNone(True);
      MovementDirection := PointBearingDegrees(CurrentStar.Position, GetPlayer.QueuedTravelTarget.Position);
      AppendHyperspaceTransitionPath(-1);
      if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
      Order := soJump;
      OrderTarget := (Self as TPlayer).QueuedTravelTarget;
      OrderStateData := Max(2, Round(CalculateJumpTravelDays(CurrentStar, (Self as TPlayer).QueuedTravelTarget) * 0.75));
      OrderDestination.X := 0;
      OrderDestination.Y := 0;
      Graphic.SetPosition(Position);
      Graphic.SetAngle(HeadingDegreesToByte(MovementDirection));
      if RecordFilm then TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, FilmObject, HeadingDegreesToByte(MovementDirection));
      Gate := Galaxy.CreateJumpGate(True);
      if GiResourceVariant = 2 then Gate.Gate.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5)))
else Gate.Gate.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800)));
Gate.Gate.SetPosition(MakePointF(Position.X + Sin(HeadingDegreesToRadians(MovementDirection)) * 180, Position.Y - Cos(HeadingDegreesToRadians(MovementDirection)) * 180));
Gate.Gate.SetAngle(HeadingDegreesToByte(MovementDirection) + 127);
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Gate.Gate);
TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, EffectFilm, Gate.Gate.Position);
TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, EffectFilm, Gate.Gate.GetAngle);
TEFilm(PrimaryFilm).SetGateSize(StartStepIndex, EffectFilm, Gate.Gate.Size.X);
TEFilm(PrimaryFilm).SetGateState(StartStepIndex, EffectFilm, 0);
TEFilm(PrimaryFilm).OpenGate(StartStepIndex, EffectFilm);

      TEFilm(PrimaryFilm).AttachObject(StartStepIndex + 1, EffectFilm);
      TEFilm(PrimaryFilm).PlayObjectSound(StartStepIndex + 1, EffectFilm, 'Sound.HyperJump');
      if Gate.Effect <> nil then
      begin
        if GiResourceVariant = 2 then Gate.Effect.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5), Round(Graphic.Size.Y * 1.5)))
else Gate.Effect.SetSize(Classes.Point(Round(Graphic.Size.X * 1.5 * 1024 / 800), Round(Graphic.Size.Y * 1.5 * 1024 / 800)));
Gate.Effect.SetPosition(MakePointF(Position.X + Sin(HeadingDegreesToRadians(MovementDirection)) * 180, Position.Y - Cos(HeadingDegreesToRadians(MovementDirection)) * 180));
Gate.Effect.SetAngle(HeadingDegreesToByte(MovementDirection) + 127);
EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Gate.Effect);
TEFilm(PrimaryFilm).SetObjectPosition(StartStepIndex, EffectFilm, Gate.Effect.Position);
TEFilm(PrimaryFilm).SetObjectAngle(StartStepIndex, EffectFilm, Gate.Effect.GetAngle);
TEFilm(PrimaryFilm).SetGateEffectSize(StartStepIndex, EffectFilm, Gate.Effect.Size.X);

        TEFilm(PrimaryFilm).AttachObject(StartStepIndex + 1, EffectFilm);
      end;
    end;
  end
  else if Order = soFollowShip then
  begin
    FilmAlpha := 255;
    FilmAlphaStep := 0;
    if RecordFilm then
    begin
      InitializeFilm(255);
      if GetPlayer = Self then TEFilm(PrimaryFilm).SetCameraAnchor(StartStepIndex, (OrderTarget as TShip).Position, True);
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
  if RecordFilm and (GetPlayer = Self) then TEFilm(PrimaryFilm).SetRadarCenter(StartStepIndex, Position);
end;
{ @end $76D098 }

{ @routine $7700D4 TShip_ProcessMovementStep }
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
// @nested $76FE54 AdvancePath
procedure AdvancePath; // @addr 0x76FE54 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4, node -8, recording flag -9, step index -16. Removes one path node and updates position, heading and film."
begin
  if (MovementPath <> nil) and (MovementPath.ActiveHead <> nil) then
  begin
    Node := MovementPath.ActiveHead;
    if RecordFilm then
    begin
      Angle := HeadingDegreesToByte(Node.Heading);
      if HeadingDegreesToByte(MovementDirection) <> Angle then TEFilm(PrimaryFilm).SetObjectAngle(StepIndex, FilmObject, Angle);
    end;
    Position := Node.Position;
    MovementDirection := Node.Heading;
    MovementPath.RemoveNode(MovementPath.ActiveHead);
  end;
  if RecordFilm then
  begin
    TEFilm(PrimaryFilm).SetObjectPosition(StepIndex, FilmObject, Position);
    if AuxiliaryFilmObject <> nil then TEFilm(PrimaryFilm).SetObjectPosition(StepIndex, AuxiliaryFilmObject, Position);
    if GetPlayer = Self then TEFilm(PrimaryFilm).SetRadarCenter(StepIndex, Position);
    if FilmAlphaStep <> 0 then
    begin
      FilmAlpha := FilmAlpha + FilmAlphaStep;
      if FilmAlpha <= 0 then TEFilm(PrimaryFilm).SetObjectAlpha(StepIndex, FilmObject, 0)
      else if FilmAlpha >= 255 then TEFilm(PrimaryFilm).SetObjectAlpha(StepIndex, FilmObject, 255)
      else TEFilm(PrimaryFilm).SetObjectAlpha(StepIndex, FilmObject, Round(FilmAlpha));
    end;
  end;
end;
begin
  Result := False;
  if IsHullDestroyed then Exit;
  PickupPathUpdatesAllowed := InNormalSpace and (Order <> soTeleport);
  if PickupPathUpdatesAllowed and ((Order = soLand) or (Order = soJump) or (Order = soJumpHole)) then
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
  if Order = soNone then
  begin
    if FilmObject <> nil then AdvancePath;
  end
  else if Order = soMove then
  begin
    if MovementPath.ActiveHead <> nil then
    begin
      AdvancePath;
      if (Position.X = OrderDestination.X) and (Position.Y = OrderDestination.Y) then OrderNone(False);
    end
    else OrderNone(False);
  end
  else if Order = soLand then
  begin
    if MovementPath.ActiveHead <> nil then
    begin
      AdvancePath;
      if RecordFilm and (GetPlayer = Self) and (OrderStateData = 0) then
      begin
        if OrderTarget is TShip then TEFilm(PrimaryFilm).SetCameraAnchor(StepIndex, (OrderTarget as TShip).Position, True)
        else TEFilm(PrimaryFilm).SetCameraAnchor(StepIndex, (OrderTarget as TPlanet).GetPosition, True);
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
            if CurrentPlanet.OwnerId = oiUninhabited then
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
          TEFilm(PrimaryFilm).DetachObject(StepIndex, FilmObject);
          if AuxiliaryFilmObject <> nil then TEFilm(PrimaryFilm).DetachObject(StepIndex, AuxiliaryFilmObject);
        end;
      end;
    end;
  end
  else if Order = soTeleport then
  begin
    if FilmObject <> nil then
    begin
      AdvancePath;
      if (FilmAlphaStep < 0) and (FilmAlpha <= 0) and ((OrderStateData > 0) or (OrderTarget <> CurrentStar)) then
      begin
        TEFilm(PrimaryFilm).DetachObject(StepIndex, FilmObject);
        if AuxiliaryFilmObject <> nil then TEFilm(PrimaryFilm).DetachObject(StepIndex, AuxiliaryFilmObject);
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
        EffectFilm := TEFilm(PrimaryFilm).AddObject(0, Effect);
        TEFilm(PrimaryFilm).SetEffectImagePosition(StepIndex, EffectFilm, Classes.Point(Round(Position.X), Round(Position.Y)));
        TEFilm(PrimaryFilm).SetEffectDurationScale(StepIndex, EffectFilm, 0.5);
        TEFilm(PrimaryFilm).AttachObject(StepIndex, EffectFilm);
        TEFilm(PrimaryFilm).PlayObjectSound(StepIndex + 1, FilmObject, 'Sound.TeleportIn');
      end
      else
      begin
        FilmAlpha := 255;
        FilmAlphaStep := 0;
      end;
      OrderNone(True);
    end;
  end
  else if Order = soJump then
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
          TEFilm(PrimaryFilm).DetachObject(StepIndex, FilmObject);
          if AuxiliaryFilmObject <> nil then TEFilm(PrimaryFilm).DetachObject(StepIndex, AuxiliaryFilmObject);
        end;
        ClearMovementPath;
        if ((GetPlayer = Self) or (TypeId <> stRanger) or (PartnerShip = nil) or
          ((TStar(OrderTarget).ControlFaction <> sfDominators) and (TStar(OrderTarget).Status.CustomFaction = ''))) and
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
  else if Order = soJumpHole then
  begin
    if (OrderStateData = HoleExitOrderState) and (MovementPath.ActiveHead <> nil) then AdvancePath
    else if not InHyperspace and (MovementPath.ActiveHead <> nil) then
    begin
      AdvancePath;
      if RecordFilm and (FilmAlphaStep = 0) and (GetPlayer = Self) then TEFilm(PrimaryFilm).SetCameraAnchor(StepIndex, OrderDestination, True);
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
          TEFilm(PrimaryFilm).DetachObject(StepIndex, FilmObject);
          if AuxiliaryFilmObject <> nil then TEFilm(PrimaryFilm).DetachObject(StepIndex, AuxiliaryFilmObject);
        end;
        ClearMovementPath;
        Galaxy.ShipsInTransit.Add(Self);
        CurrentStar.HandleObjectLeavingStar(Self);
      end;
    end;
  end
  else if Order = soTakeoff then
  begin
    if MovementPath.ActiveHead <> nil then AdvancePath;
  end
  else if Order = soFollowShip then
  begin
    if MovementPath.ActiveHead <> nil then
    begin
      AdvancePath;
      if RecordFilm and (GetPlayer = Self) then TEFilm(PrimaryFilm).SetCameraAnchor(StepIndex, (OrderTarget as TShip).Position, True);
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
    TEFilm(PrimaryFilm).SetObjectAlpha(StepIndex, AuxiliaryFilmObject, AuxiliaryFilmObject.SceneObject.GetAlpha);
  end;
end;
{ @end $7700D4 }

{ @routine $770FA0 TShip_ClearCompletedTakeoffOrHoleOrder }
procedure TShip.ClearCompletedTakeoffOrHoleOrder(UnusedStepIndex: Integer; UnusedRecordFilm: Boolean);
begin
  if IsHullDestroyed then Exit;
  if Order = soTakeoff then OrderNone(True)
  else if (Order = soJumpHole) and (OrderStateData = HoleExitOrderState) then OrderNone(True);
end;
{ @end $770FA0 }

{ @routine $770FFC TShip_IsTravelCompletionPathReady }
function TShip.IsTravelCompletionPathReady: Boolean;
begin
  Result := True;
  repeat
    if Order = soJump then
    begin
      if not InNormalSpace then Break;
      if MovementPath.ActiveHead = nil then Break;
      if JumpDeparturePathCommitted then Exit;
    end
    else if Order = soJumpHole then
    begin
      if not InNormalSpace then Break;
      if OrderStateData = HoleExitOrderState then Break;
      if MovementPath.ActiveHead = nil then Break;
      if PointDistanceSquared(MovementPath.ActiveTail.Position, OrderDestination) <= 0 then Exit;
    end
    else if Order = soTeleport then
    begin
      if InNormalSpace then Exit;
    end
    else if (Order = soLand) and (OrderTarget is TShip) then
    begin
      if MovementPath.ActiveHead = nil then Break;
      if PointDistanceSquared(AddPointsF((OrderTarget as TShip).Position, OrderDestination), MovementPath.ActiveTail.Position) <= 0 then Exit;
    end
    else if Order = soLand then
    begin
      if MovementPath.ActiveHead = nil then Break;
      if PointDistanceSquared((OrderTarget as TPlanet).PredictPosition(CurrentStar.MovementStepCount), MovementPath.ActiveTail.Position) < Sqr((OrderTarget as TPlanet).GraphicRadius) then Exit;
    end;
  until True;
  Result := False;
end;
{ @end $770FFC }

{ @routine $771208 TShip_RepelFollowingShips }
procedure TShip.RepelFollowingShips;
var
  I, Count: Integer;
  Other: TShip;
  Distance, Overlap, VectorLength, Angle, DeltaY, DeltaX, OffsetY, OffsetX,
    SelfWeight, OtherWeight, Fraction: Single;
begin
  try
    Count := CurrentStar.Ships.Count;
    OffsetX := 0;
    OffsetY := 0;
    SelfWeight := Max(0.01, CalculateSpeed / Max(0.01, PointDistance(RepulsionPosition, Position)));
    repeat
      I := 0;
      while I < Count do
      begin
        Other := CurrentStar.Ships[I];
        if (Self = Other) or (Other.Order <> soFollowShip) then
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
            DeltaX := Sin(Angle) * Overlap;
            DeltaY := -Cos(Angle) * Overlap;
          end
          else
          begin
            Distance := 1 / Distance * Overlap;
            DeltaX := (Other.RepulsionPosition.X - RepulsionPosition.X) * Distance;
            DeltaY := (Other.RepulsionPosition.Y - RepulsionPosition.Y) * Distance;
          end;
          VectorLength := Sqrt(DeltaX * DeltaX + DeltaY * DeltaY);
          if VectorLength < 0.01 then
          begin
            DeltaX := 0.01 * DeltaX / VectorLength;
            DeltaY := 0.01 * DeltaY / VectorLength;
          end;
          Other.RepulsionPosition.X := Other.RepulsionPosition.X + DeltaX * Fraction;
          Other.RepulsionPosition.Y := Other.RepulsionPosition.Y + DeltaY * Fraction;
          OffsetX := OffsetX - (1 - Fraction) * DeltaX;
          OffsetY := OffsetY - (1 - Fraction) * DeltaY;
        end;
        Inc(I);
      end;
    until I >= Count;
    RepulsionPosition.X := RepulsionPosition.X + OffsetX;
    RepulsionPosition.Y := RepulsionPosition.Y + OffsetY;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create(AnsiString('Error in procedure TShip.RepulsionShip ' + Name));
    end;
  end;
end;
{ @end $771208 }

{ @routine $77181C TShip_RebuildMovePath }
procedure TShip.RebuildMovePath;
begin
  ClearMovementPath;
  AppendStarAvoidingPath(OrderDestination, CurrentStar.MovementStepCount);
  if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position
  else OrderDestination := Position;
end;
{ @end $77181C }

{ @routine $771898 TShip_BuildFullPathTo }
procedure TShip.BuildFullPathTo(Destination: TPointF);
begin
  ClearMovementPath;
  if MovementSpeed < 0.001 then Exit;
  AppendStarAvoidingPath(Destination, FullPathNodeLimit);
end;
{ @end $771898 }

{ @routine $7718EC TShip_BuildPlanetLandingPath }
procedure TShip.BuildPlanetLandingPath;
var
  Planet: TPlanet;
  Steps: Integer;
  Destination: TPointF;
begin
  ClearMovementPath;
  if MovementSpeed < 0.001 then Exit;
  if Order <> soLand then Exit;
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
{ @end $7718EC }

{ @routine $7719F4 TShip_BuildOrderMovementPath }
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
  if (TerronShip = Self) and (Order = soMove) and (Galaxy.TerronToStarTurn = 0) then
  begin
    AppendOrbitalPath(MaximumNodes);
    Exit;
  end;
  if (Order = soLand) and (OrderTarget is TShip) then
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
  else if Order = soLand then
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
  else if Order = soJumpHole then
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
  else if Order = soFollowShip then
  begin
    Ship := OrderTarget as TShip;
    Radius := CalculateFollowRadius;
    if Ship.MovementPath.ActiveHead = nil then
    begin
      AppendStarAvoidingPathWithTurnPadding(PointBehindHeading(Ship.Position, Ship.MovementDirection, Radius, Abs(Ship.Seed + Seed)), MaximumNodes);
      if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
    end
    else if Ship.MovementPath.NodeCount <= Steps then
    begin
      AppendStarAvoidingPathWithTurnPadding(PointBehindHeading(Ship.MovementPath.ActiveTail.Position, Ship.MovementPath.ActiveTail.Heading, Radius, Abs(Ship.Seed + Seed)), MaximumNodes);
      if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
    end
    else
    begin
      Node := Ship.MovementPath.GetFollowingNode(Ship.MovementPath.ActiveHead, Steps - 1);
      AppendStarAvoidingPathWithTurnPadding(PointBehindHeading(Node.Position, Node.Heading, Radius, Abs(Ship.Seed + Seed)), MaximumNodes);
      if MovementPath.ActiveTail <> nil then OrderDestination := MovementPath.ActiveTail.Position else OrderDestination := Position;
    end;
  end
  else if Order = soJump then
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
  else if (Order = soMove) or (Order = soJump) or (Order = soTakeoff) then
    AppendStarAvoidingPathWithTurnPadding(OrderDestination, MaximumNodes);
end;
{ @end $7719F4 }

{ @routine $77288C TShip_AppendPathToWithTurnPadding }
procedure TShip.AppendPathToWithTurnPadding(Destination: TPointF; MaximumNodes: Integer);
var
  Step: Single;
begin
  AppendTurningPath(Destination, False, MaximumNodes);
  AppendStraightPath(Destination, MaximumNodes);
  if (PlayerStar = CurrentStar) and (MovementPath.NodeCount < BaseMovementStepsPerTurn) and
    ((GetPlayer.CurrentPlanet = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.Order = soTakeoff))) then
    MovementPath.ResampleBezierRange(MovementPath.ActiveHead, MovementPath.ActiveTail, BaseMovementStepsPerTurn);
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if MovementPath.ActiveHead <> nil then
  begin
    if PointDistanceSquared(MovementPath.ActiveTail.Position, Destination) < Step * Step then
      MovementPath.ActiveTail.Position := Destination;
  end;
end;
{ @end $77288C }

{ @routine $7729A8 TShip_AppendPathTo }
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
{ @end $7729A8 }

{ @routine $772A54 TShip_AppendStarAvoidingPathWithTurnPadding }
procedure TShip.AppendStarAvoidingPathWithTurnPadding(Destination: TPointF; MaximumNodes: Integer);
var
  Step: Single;
begin
  AppendStarAvoidingPath(Destination, MaximumNodes);
  if (PlayerStar = CurrentStar) and (MovementPath.NodeCount < BaseMovementStepsPerTurn) and
    ((GetPlayer.CurrentPlanet = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.Order = soTakeoff))) then
    MovementPath.ResampleBezierRange(MovementPath.ActiveHead, MovementPath.ActiveTail, BaseMovementStepsPerTurn);
  Step := MovementSpeed * BaseMovementStepsPerTurn * CurrentStar.MovementStepScale;
  if MovementPath.ActiveHead <> nil then
  begin
    if PointDistanceSquared(MovementPath.ActiveTail.Position, Destination) < Step * Step then
      MovementPath.ActiveTail.Position := Destination;
  end;
end;
{ @end $772A54 }

{ @routine $772B60 TShip_AppendOrbitalPath }
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
{ @end $772B60 }

{ @routine $772D04 TShip_AppendTurningPath }
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
    if (MovementPath.ActiveHead = nil) and (Order = soJumpHole) then
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
  if (Order = soTakeoff) or ((Order = soJumpHole) and (OrderStateData = HoleExitOrderState)) then
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
{ @end $772D04 }

{ @routine $773568 TShip_AppendStraightPath }
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
  if (Order = soTakeoff) or ((Order = soJumpHole) and (OrderStateData = HoleExitOrderState)) then Step := Min(2, Step / 2);
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
{ @end $773568 }

{ @routine $7738AC TShip_AppendHyperspaceTransitionPath }
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
{ @end $7738AC }

{ @routine $773AB0 TShip_AppendStarAvoidingPath }
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
    Exit;
  end;
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
{ @end $773AB0 }

{ @routine $773E38 TShip_AppendCircularDetour }
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
{ @end $773E38 }

{ @routine $774104 TShip_ClearMovementPath }
procedure TShip.ClearMovementPath;
begin
  MovementPath.Clear;
end;
{ @end $774104 }

{ @routine $77411C TShip_GetSlotCount }
function TShip.GetSlotCount(SlotKind: TShipSlotKind): Integer;
begin
  Result := GetHull.GetSlotCount(SlotKind);
  case SlotKind of
    sskRadar: Inc(Result, GetOwnStatBonus(bonSlotRadar));
    sskScanner: Inc(Result, GetOwnStatBonus(bonSlotScaner));
    sskRepairRobot: Inc(Result, GetOwnStatBonus(bonSlotDroid));
    sskCargoHook: Inc(Result, GetOwnStatBonus(bonSlotHook));
    sskDefGenerator: Inc(Result, GetOwnStatBonus(bonSlotDef));
    sskWeapon: Inc(Result, GetOwnStatBonus(bonSlotWeapon));
    sskArtefact: Inc(Result, GetOwnStatBonus(bonSlotArt));
    sskAfterburner: Inc(Result, GetOwnStatBonus(bonSlotForsage));
  end;
  Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result));
  if Artefacts.Count > 0 then
  begin
    if SlotKind = sskWeapon then
    begin
      if (CountActiveArtefacts(t_ArtWeaponToSpeed) > 0) and not CanBoostArtefact(t_ArtWeaponToSpeed, GetHull, False) then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result - CountActiveArtefacts(t_ArtWeaponToSpeed)));
      if (CountActiveArtefacts(t_ArtDefToArms1) > 0) and (GetDefGenerator <> nil) then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result + CountActiveArtefacts(t_ArtDefToArms1)));
      if (CountActiveArtefacts(t_ArtDefToArms2) > 0) and (GetHull.GetSlotCount(sskDefGenerator) > 0) then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result + 1 + CountActiveArtefacts(t_ArtDefToArms2)));
    end
    else if SlotKind = sskDefGenerator then
    begin
      if CountActiveArtefacts(t_ArtDefToArms2) > 0 then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result - 1));
    end
    else if SlotKind = sskRepairRobot then
    begin
      if CountActiveArtefacts(t_ArtArtefactor) > 0 then
        Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result - 1));
    end
    else if (SlotKind = sskArtefact) and (Result > 0) and (CountActiveArtefacts(t_ArtArtefactor) > 0) and
      (GetHull.GetSlotCount(sskRepairRobot) > 0) then
      Result := Min(DefaultHullSlotCounts[SlotKind], Max(MinimumHullSlotCounts[SlotKind], Result + 3));
  end;
end;
{ @end $77411C }

{ @routine $774598 TShip_GetSlotCountForItemType }
function TShip.GetSlotCountForItemType(ItemType: TItemType): Integer;
begin
  Result := GetSlotCount(ItemTypeToSlotKind(ItemType));
end;
{ @end $774598 }

{ @routine $7745C0 TShip_ReassignActiveItemSlots }
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
  if Kind <> sskArtefact then
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.EquippedFlag <> 0 then
      begin
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
  end
  else
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Item := Artefacts[I];
      if Item.EquippedFlag <> 0 then
      begin
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
end;
{ @end $7745C0 }

{ @routine $77480C TShip_RefreshAssignedItemSlots }
procedure TShip.RefreshAssignedItemSlots;
begin
  ReassignActiveItemSlots(t_FuelTanks);
  ReassignActiveItemSlots(t_Engine);
  ReassignActiveItemSlots(t_Radar);
  ReassignActiveItemSlots(t_Scaner);
  ReassignActiveItemSlots(t_RepairRobot);
  ReassignActiveItemSlots(t_CargoHook);
  ReassignActiveItemSlots(t_DefGenerator);
  ReassignActiveItemSlots(t_Weapon1);
  ReassignActiveItemSlots(t_Artefact);
  RefreshInactiveItemSlotAssignments;
end;
{ @end $77480C }

{ @routine $774878 TShip_FindEquippedItemInSlot }
function TShip.FindEquippedItemInSlot(ItemType: TItemType; SlotIndex: Integer): TEquipment;
var I: Integer; Item: TEquipment; Kind: TShipSlotKind;
begin
  Kind := ItemTypeToSlotKind(ItemType);
  if Kind <> sskArtefact then
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := TEquipment(Inventory[I]);
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
      Item := TEquipment(Artefacts[I]);
      if (Item.EquippedFlag <> 0) and (Integer(Item.AssignedSlotData) and EquipmentSlotIndexMask = SlotIndex) then
      begin
        Result := Item;
        Exit;
      end;
    end;
  Result := nil;
end;
{ @end $774878 }

{ @routine $774968 TShip_RefreshInactiveItemSlotAssignments }
procedure TShip.RefreshInactiveItemSlotAssignments;
var
  I, Count: Integer;
  Item: TEquipment;
begin
  Count := Inventory.Count;
  for I := Count - 1 downto 0 do
  begin
    Item := Inventory[I];
    if (Item.EquippedFlag = 0) and (CountUnequippedItemsInSlot(Item.AssignedSlotData and EquipmentSlotIndexMask) > 1) then
      Item.AssignedSlotData := FindFreeUnequippedSlot or (Item.AssignedSlotData and EquipmentSecondaryFireFlag);
  end;
end;
{ @end $774968 }

{ @routine $7749E8 TShip_CountUnequippedItemsInSlot }
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
{ @end $7749E8 }

{ @routine $774A60 TShip_FindFreeUnequippedSlot }
function TShip.FindFreeUnequippedSlot: Integer;
var
  SlotIndex: Integer;
begin
  SlotIndex := 0;
  while CountUnequippedItemsInSlot(SlotIndex) > 0 do Inc(SlotIndex);
  Result := SlotIndex;
end;
{ @end $774A60 }

{ @routine $774A90 TShip_RepairDuplicateSatelliteTrajectoryIndices }
procedure TShip.RepairDuplicateSatelliteTrajectoryIndices;
var
  I, J, Count: Integer;
  First, Second: TItem;
begin
  Count := Inventory.Count;
  for I := 0 to Count - 1 do
  begin
    First := Inventory[I];
    if First.ItemType = t_Satellite then
      for J := I + 1 to Count - 1 do
      begin
        Second := Inventory[J];
        if (Second.ItemType = t_Satellite) and
          ((Second as TSatellite).TrajectoryIndex = (First as TSatellite).TrajectoryIndex) then
          (Second as TSatellite).TrajectoryIndex := FindFreeSatelliteTrajectoryIndex;
      end;
  end;
end;
{ @end $774A90 }

{ @routine $774B68 TShip_GetSatelliteTrajectoryIndexLimit }
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
    if Item.ItemType = t_Satellite then Result := Max(Result, (Item as TSatellite).TrajectoryIndex + 1);
  end;
end;
{ @end $774B68 }

{ @routine $774BF8 TShip_FindFreeSatelliteTrajectoryIndex }
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
      if (Item.ItemType = t_Satellite) and ((Item as TSatellite).TrajectoryIndex = Result) then Break;
      Inc(I);
    end;
    if I >= Count then Break;
    Inc(Result);
  end;
end;
{ @end $774BF8 }

{ @routine $774C74 TShip_FindSatelliteByTrajectoryIndex }
function TShip.FindSatelliteByTrajectoryIndex(Index: Integer): TSatellite;
var
  I: Integer;
  Item: TItem;
begin
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = t_Satellite) and ((Item as TSatellite).TrajectoryIndex = Index) then
    begin
      Result := TSatellite(Item);
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $774C74 }

{ @routine $774CEC TShip_InsertSatelliteTrajectoryIndex }
procedure TShip.InsertSatelliteTrajectoryIndex(Index: Integer);
var
  I: Integer;
  Item: TItem;
begin
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = t_Satellite) and ((Item as TSatellite).TrajectoryIndex >= Index) then
      Inc((Item as TSatellite).TrajectoryIndex);
  end;
end;
{ @end $774CEC }

{ @routine $774D64 TShip_RemoveEmptySatelliteTrajectoryIndex }
procedure TShip.RemoveEmptySatelliteTrajectoryIndex(Index: Integer);
var
  I: Integer;
  Item: TItem;
begin
  if FindSatelliteByTrajectoryIndex(Index) <> nil then Exit;
  for I := 0 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (Item.ItemType = t_Satellite) and ((Item as TSatellite).TrajectoryIndex >= Index) then
      Dec((Item as TSatellite).TrajectoryIndex);
  end;
end;
{ @end $774D64 }

{ @routine $774DEC TShip_CompactSatelliteTrajectoryIndices }
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
{ @end $774DEC }

{ @routine $774E4C TShip_AssignSatelliteIndicesFromHoldOrder }
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
      if Entry.Kind <> phkEquipment then Continue;
      if Inventory.IndexOf(Entry.Item) < 0 then Continue;
      Item := Entry.Item as TEquipment;
      if Item.ItemType = t_Satellite then begin
        if Next >= Count then RaiseWideMessage('Satellite renom 1');
        (Item as TSatellite).TrajectoryIndex := Indices[Next];
        Inc(Next);
      end;
    end;
    if Count <> Next then RaiseWideMessage('Satellite renom 2');
    Indices := nil;
  end;
end;
{ @end $774E4C }

{ @routine $775094 TShip_ArrangeHoldSatellitesByTrajectoryIndex }
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
      if (Entry <> nil) and (Entry.Kind = phkEquipment) and (Inventory.IndexOf(Entry.Item) >= 0) then begin
          Item := Entry.Item as TEquipment;
          if Item.ItemType = t_Satellite then begin
            Entries[Count] := TPlayerHoldUnit.Create;
            Entries[Count].Kind := Entry.Kind;
            Entries[Count].GoodsIndex := Entry.GoodsIndex;
            Entries[Count].ItemId := Entry.ItemId;
            Entries[Count].Item := Entry.Item;
            Entries[Count].Retained := Entry.Retained;
            Indices[Count] := I;
            Inc(Count);
          end;
        end;
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
{ @end $775094 }

{ @routine $7753E0 TShip_UseDominatorTransmitter }
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
    if (TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerUsesBeacon') and
      (TGalaxyEvent(Galaxy.GalaxyEvents[I]).GetData(0) = Integer(CurrentStar.Id)) and
      (TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + TransmitterSameSystemPenaltyTurns < Galaxy.CurrentTurn) then Inc(Penalty, TransmitterSameSystemPenalty);
  end;
  Event := AddGalaxyEvent('PlayerUsesBeacon');
  Event.AddData(CurrentStar.Id);
  Selected := 0;
  Strength := 0;
  PowerFactor := RemapClamped(Artefact.Power, MinTransmitterPower, MaxTransmitterPower, 1, 3);
  if (CurrentStar.Id <> 71) and (CurrentStar.Id <> 72) then
    for I := 1 to Galaxy.Stars.Count - 1 do begin
      Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
      if (Star.ControlFaction = sfDominators) and (Star.Battle = 0) and (Star.Status.CustomFaction = '') and
        ((Star.DominatorSeries = dsKeller) or ((NextRandomUnitFloat(RandomState) >= 0.8) and (PowerFactor >= 2))) then begin
        Available := 0;
        for J := 0 to Star.Ships.Count - 1 do begin
          Ship := Star.Ships[J];
          if Ship.InNormalSpace and (Ship is TKling) and not Ship.HasIndependentScriptFaction and
            (Ship.Order in [soNone, soMove]) and ((Ship as TKling).KlingType in [ktEquentor..ktShtip]) then Inc(Available);
        end;
        if Available <= 1 then Available := 0
        else Available := Max(1, Available - NextRandomIntRange(2, 5, RandomState));
        if Available > 0 then
          for J := 0 to Star.Ships.Count - 1 do begin
            Ship := Star.Ships[J];
            if Ship.InNormalSpace and (Ship is TKling) and not Ship.HasIndependentScriptFaction and
              (Ship.Order in [soNone, soMove]) and ((Ship as TKling).KlingType in [ktEquentor..ktShtip]) then begin
              if (Star.DominatorSeries = dsKeller) and (1 - Penalty * 0.01 > NextRandomUnitFloat(RandomState)) and
                (KellerShip <> nil) and (Galaxy.KellerLeaveTurn = 0) then Ship.OrderJump(CurrentStar, True);
              if (Star.DominatorSeries = dsBlazer) and (1 - Penalty * 0.01 > NextRandomUnitFloat(RandomState)) and
                (BlazerShip <> nil) then Ship.OrderJump(CurrentStar, True);
              if (Star.DominatorSeries = dsTerron) and (1 - Penalty * 0.01 > NextRandomUnitFloat(RandomState)) and
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
    end;
  Artefact.Power := 0;
  Result := True;
  end else Result := False;
end;
{ @end $7753E0 }

{ @routine $7759DC TShip_HasMatchingArtefactOrCustomItem }
function TShip.HasMatchingArtefactOrCustomItem(Item: TItem): Boolean;
var I: Integer; Other: TEquipment;
begin
  Result := False;
  if Item.ItemType = t_UselessItem then begin
    for I := 0 to Inventory.Count - 1 do begin
      Other := TEquipment(Inventory[I]);
      if (Other.ItemType = t_UselessItem) and (Other.ConfigBlockName = TEquipment(Item).ConfigBlockName) then begin Result := True; Exit; end;
    end;
  end else
    for I := 0 to Artefacts.Count - 1 do begin
      Other := TEquipment(Artefacts[I]);
      if (Item.ItemType = Other.ItemType) and (not (Other.ItemType in [t_Artefact, t_Artefact2]) or
        (Other.ConfigBlockName = TEquipment(Item).ConfigBlockName)) then begin Result := True; Exit; end;
    end;
end;
{ @end $7759DC }

{ @routine $775AC8 TShip_CountActiveArtefacts }
function TShip.CountActiveArtefacts(ArtefactType: TItemType): Integer;
var
  I: Integer;
  Item: TArtefact;
  AllActive: Boolean;
begin
  Result := 0;
  AllActive := False;
  if (ArtefactType in [t_ArtefactRadar, t_ArtefactScaner, t_ArtefactAnalyzer, t_ArtBio]) and (ArtefactType <> t_ArtArtefactor) then
    AllActive := (CountActiveArtefacts(t_ArtArtefactor) > 0) and
      ((not (TurnCalculationPhase in [tcpGalaxyRunning, tcpPlayerStarRunning])) or (CountActiveArtefacts(t_ArtArtefactor) > 1));
  for I := 0 to Artefacts.Count - 1 do
  begin
    Item := TArtefact(Artefacts[I]);
    if (Item.GetEffectiveType = ArtefactType) and (Item.BrokenFlag = 0) and
       ((Item.EquippedFlag or Byte(AllActive)) <> 0) then Inc(Result);
  end;
end;
{ @end $775AC8 }

{ @routine $775B8C TShip_HasEquippedArtefactOfSameUseGroup }
function TShip.HasEquippedArtefactOfSameUseGroup(Item: TItem): Boolean;
var I: Integer; Kind: TItemType; Artefact: TArtefact;
begin
  Result := False;
  if not (Item is TArtefact) then Exit;
  Kind := Item.ItemType;
  if (Kind in [t_Artefact..t_Artefact2]) and TArtefactCustom(Item).SharedUse then
    Kind := TArtefactCustom(Item).CountsAsItemType;
  if not (Kind in [t_Artefact..t_Artefact2]) then
  begin
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := TArtefact(Artefacts[I]);
      if Artefact.EquippedFlag <> 0 then
      begin
        if Artefact.ItemType = Kind then
        begin
          Result := True;
          Exit;
        end;
        if (Artefact.ItemType in [t_Artefact..t_Artefact2]) and
           (TArtefactCustom(Artefact).CountsAsItemType = Kind) and TArtefactCustom(Artefact).SharedUse then
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
      Artefact := TArtefact(Artefacts[I]);
      if (Artefact.EquippedFlag <> 0) and (Artefact.ItemType in [t_Artefact..t_Artefact2]) and
         (Artefact.ConfigBlockName = TEquipment(Item).ConfigBlockName) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;
{ @end $775B8C }

{ @routine $775D0C TShip_CanBoostArtefact }
function TShip.CanBoostArtefact(ArtefactType: TItemType; Item: TEquipment; IgnoreArtefactAvailability: Boolean): Boolean;
var Equipment: TEquipment;

  // @nested $775CD4 IsArtefactBoostEquipment
  function IsArtefactBoostEquipment(Item: TEquipment): Boolean; // @addr $775CD4 @note "Nested in CanBoostArtefact with unused caller-popped static link. OwnerId=6 and empty CustomFaction; nil returns false."
  begin
    Result := (Item <> nil) and (Item.OwnerId = oiUninhabited) and (Item.CustomFaction = '');
  end;

begin
  Result := False;
  if not IgnoreArtefactAvailability and (CountActiveArtefacts(ArtefactType) <= 0) then Exit;
  if not (ArtefactType in [t_ArtefactHull..t_ArtefactDef,
    t_ArtefactMiniExpl, t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump,
    t_ArtDefToArms1, t_ArtPDTurret, t_ArtFastRacks]) then Exit;
  if Item = nil then
  begin
    case ArtefactType of
      t_ArtefactHull: Result := IsArtefactBoostEquipment(GetHull);
      t_ArtefactFuel: Result := IsArtefactBoostEquipment(GetFuelTanks);
      t_ArtefactSpeed: Result := IsArtefactBoostEquipment(GetEngine);
      t_ArtefactPower: Result := IsArtefactBoostEquipment(GetEngine) or IsArtefactBoostEquipment(GetHull);
      t_ArtefactRadar: Result := IsArtefactBoostEquipment(GetRadar);
      t_ArtefactScaner: Result := IsArtefactBoostEquipment(GetScanner);
      t_ArtefactDroid: Result := IsArtefactBoostEquipment(GetRepairRobot);
      t_ArtefactHook: Result := IsArtefactBoostEquipment(GetCargoHook);
      t_ArtefactDef: Result := IsArtefactBoostEquipment(GetDefGenerator);
      t_ArtefactAntigrav: Result := IsArtefactBoostEquipment(GetHull);
      t_ArtDefToEnergy: Result := IsArtefactBoostEquipment(GetDefGenerator);
      t_ArtGiperJump: Result := IsArtefactBoostEquipment(GetEngine);
      t_ArtDefToArms1: Result := IsArtefactBoostEquipment(GetDefGenerator);
      t_ArtForsage: Result := IsArtefactBoostEquipment(GetEngine);
      t_ArtWeaponToSpeed: Result := IsArtefactBoostEquipment(GetEngine) or IsArtefactBoostEquipment(GetHull);
      t_ArtEnergyDef: Result := IsArtefactBoostEquipment(GetHull);
      t_ArtMissileDef: Result := IsArtefactBoostEquipment(GetHull);
      t_ArtefactMiniExpl: Result := IsArtefactBoostEquipment(GetScanner);
      t_ArtPDTurret: Result := IsArtefactBoostEquipment(GetRadar);
    end;
    if ArtefactType = t_ArtefactNano then
      if IsArtefactBoostEquipment(GetEngine) or IsArtefactBoostEquipment(GetFuelTanks) or
        IsArtefactBoostEquipment(GetRadar) or IsArtefactBoostEquipment(GetScanner) or
        IsArtefactBoostEquipment(GetRepairRobot) or IsArtefactBoostEquipment(GetCargoHook) or
        IsArtefactBoostEquipment(GetDefGenerator) or
        IsArtefactBoostEquipment(Weapons[1]) or
        IsArtefactBoostEquipment(Weapons[2]) or
        IsArtefactBoostEquipment(Weapons[3]) or
        IsArtefactBoostEquipment(Weapons[4]) or
        IsArtefactBoostEquipment(Weapons[5]) then Result := True;
    if (ArtefactType = t_ArtDefToEnergy) or (ArtefactType = t_ArtEnergyPulse) then
      if (IsArtefactBoostEquipment(Weapons[1]) and (dkEnergy in Weapons[1].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[2]) and (dkEnergy in Weapons[2].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[3]) and (dkEnergy in Weapons[3].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[4]) and (dkEnergy in Weapons[4].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[5]) and (dkEnergy in Weapons[5].GetWeaponInfo.DamageFlags)) then Result := True;
    if (ArtefactType = t_ArtSplinter) or (ArtefactType = t_ArtDecelerate) then
      if (IsArtefactBoostEquipment(Weapons[1]) and (dkSplinter in Weapons[1].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[2]) and (dkSplinter in Weapons[2].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[3]) and (dkSplinter in Weapons[3].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[4]) and (dkSplinter in Weapons[4].GetWeaponInfo.DamageFlags)) or
        (IsArtefactBoostEquipment(Weapons[5]) and (dkSplinter in Weapons[5].GetWeaponInfo.DamageFlags)) then Result := True;
    if ArtefactType = t_ArtFastRacks then
      if (IsArtefactBoostEquipment(Weapons[1]) and (Weapons[1].GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or
        (IsArtefactBoostEquipment(Weapons[2]) and (Weapons[2].GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or
        (IsArtefactBoostEquipment(Weapons[3]) and (Weapons[3].GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or
        (IsArtefactBoostEquipment(Weapons[4]) and (Weapons[4].GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or
        (IsArtefactBoostEquipment(Weapons[5]) and (Weapons[5].GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) then Result := True;
  end
  else
  begin
    Equipment := Item;
    if not IsArtefactBoostEquipment(Equipment) then Exit;
    case ArtefactType of
      t_ArtefactHull: if not (Equipment is THull) then Exit;
      t_ArtefactFuel: if not (Equipment is TFuelTanks) then Exit;
      t_ArtefactSpeed: if not (Equipment is TEngine) then Exit;
      t_ArtefactPower: if not ((Equipment is TEngine) or (Equipment is THull)) then Exit;
      t_ArtefactRadar: if not (Equipment is TRadar) then Exit;
      t_ArtefactScaner: if not (Equipment is TScaner) then Exit;
      t_ArtefactDroid: if not (Equipment is TRepairRobot) then Exit;
      t_ArtefactDef: if not (Equipment is TDefGenerator) then Exit;
      t_ArtefactAntigrav: if not (Equipment is THull) then Exit;
      t_ArtefactHook: if not (Equipment is TCargoHook) then Exit;
      t_ArtGiperJump: if not (Equipment is TEngine) then Exit;
      t_ArtDefToArms1: if not (Equipment is TDefGenerator) then Exit;
      t_ArtForsage: if not (Equipment is TEngine) then Exit;
      t_ArtEnergyDef: if not (Equipment is THull) then Exit;
      t_ArtMissileDef: if not (Equipment is THull) then Exit;
      t_ArtefactMiniExpl: if not (Equipment is TScaner) then Exit;
      t_ArtPDTurret: if not (Equipment is TRadar) then Exit;
    end;
    if (ArtefactType = t_ArtefactNano) and (Equipment is THull) then Exit;
    if (ArtefactType = t_ArtWeaponToSpeed) and not ((Equipment is THull) or (Equipment is TEngine)) then Exit;
    if (ArtefactType = t_ArtDefToEnergy) and not ((Equipment is TDefGenerator) or
      ((Equipment is TWeapon) and (dkEnergy in TWeapon(Equipment).GetWeaponInfo.DamageFlags))) then Exit;
    if (ArtefactType = t_ArtEnergyPulse) and not ((Equipment is TWeapon) and
      (dkEnergy in TWeapon(Equipment).GetWeaponInfo.DamageFlags)) then Exit;
    if ((ArtefactType = t_ArtSplinter) or (ArtefactType = t_ArtDecelerate)) and not ((Equipment is TWeapon) and
      (dkSplinter in TWeapon(Equipment).GetWeaponInfo.DamageFlags)) then Exit;
    if (ArtefactType = t_ArtFastRacks) and not ((Equipment is TWeapon) and
      (TWeapon(Equipment).GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) then Exit;
    if not (Equipment.ItemType in [t_Hull..t_CustomWeapon]) then Exit;
    Result := True;
  end;
end;
{ @end $775D0C }

{ @routine $776890 TShip_ApplyNanoArtefactRepair }
procedure TShip.ApplyNanoArtefactRepair;
var Item: TEquipment; I, EquippedCount, UnequippedCount: Integer;

  // @nested $776730 SelectOrdinal
  procedure SelectOrdinal(Ordinal: Integer; Equipped: Boolean); // @addr 0x776730 @note "Caller-popped static link; ship -4, selected-item output -8."
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

  // @nested $7767A8 SelectRepairable
  procedure SelectRepairable(Count: Integer; Equipped: Boolean); // @addr 0x7767A8 @note "Caller-popped static link; ship -4, selected-item output -8. At most 30 deterministic selections."
  const RepairableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
  var Attempt: Integer;
  begin
    Attempt := 0;
    repeat
      Inc(Attempt);
      Item := nil;
      if Attempt > 30 then Exit;
      SelectOrdinal(SeededRandomIntRange(1, Count, Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn) + Cardinal(Attempt)), Equipped);
      if Item = nil then Exit;
    until (Byte(Item.ItemType) in RepairableTypes) and (Item.ConditionPercent <= 60) and
      not ((Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = waNotSoldAndNodeRepair)) and
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
    if CanBoostArtefact(t_ArtefactNano, Item, False) then
      Item.ConditionPercent := Item.ConditionPercent + NanoArtefactBoostRepair / OwnerInfo[Item.OwnerId].EquipmentDurabilityFactor;
    if Item.ConditionPercent > 100 then Item.ConditionPercent := 100;
    if (Item.ConditionPercent > 0) and (Item.BrokenFlag <> 0) then
    begin
      Item.BrokenFlag := 0;
      if GetPlayer = Self then
        AddOrUpdatePlayerBubble(pmShipPositive, Galaxy.CurrentTurn, FormatText1(LocalizedText('Artefacts.ArtNano.RepairItem'),
          '<color=255,240,100>', '<Name>', Item.GetDisplayName), '').Targets[0].ShipId := Id;
    end;
  end;
end;
{ @end $776890 }

{ @routine $776B58 TShip_CanContactShip }
function TShip.CanContactShip(OtherShip: TShip): Boolean;
begin
  Result := (Max(GetRadarRange * GetRadarRange, 250000) >= PointDistanceSquared(Position, OtherShip.Position)) and
    not OtherShip.NoTalk and not NoTalk;
end;
{ @end $776B58 }

{ @routine $776C98 TShip_LookupTalkText }
function TShip.LookupTalkText(const Path: WideString): WideString;
var Count, I: Integer; Key: WideString; Variants: array[0..9] of WideString;

  // @nested $776BF0 GetTalkContextPrefix
  function GetTalkContextPrefix(Ship: TShip): WideString; // @addr $776BF0
  begin
    Result := 'Talk.';
    if (Ship.OwnerId = oiPirate) and (Ship is TNormalShip) then Result := Result + 'PirateClan.'
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
    Result := 'String: ' + WrapTextInColor(Key, '<color=255,240,100>') + ' is unavailable';
    Exit;
  end;

  if Count = 1 then Result := Variants[0]
  else
  begin
    Count := SeededRandomIntRange(0, Count - 1, (Galaxy.CurrentTurn + Integer(Seed)) div 10);
    Result := Variants[Count];
  end;
  if HomePlanet <> nil then Result := ReplaceColoredToken(Result, '<HomePlanet>', HomePlanet.Name, '<color=255,240,100>');
  Result := ReplaceColoredToken(Result, '<Ship>', GetName, '<color=255,240,100>');
  Result := ReplaceColoredToken(Result, '<FullShip>', GetFullName(' '), '<color=255,240,100>');
  Result := ReplaceAllWideString(Result, '<clr>', '<color=255,240,100>');
  Result := ReplaceAllWideString(Result, '<clrEnd>', '</color>');
  if (GetPlayer = Self) and (TalkShip <> nil) then
    Result := ReplaceColoredToken(Result, '<TalkShip>', TalkShip.GetName, '<color=255,240,100>');
end;
{ @end $776C98 }

{ @routine $777128 TShip_OpenPlayerConversation }
function TShip.OpenPlayerConversation(RespectChameleon: Boolean): Boolean;
var Handles: array[0..1] of THandle;
begin
  if ExitScreenLoop or not GetPlayer.InNormalSpace or (GetPlayer.CurrentStar <> CurrentStar) or
    (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) or
    (CurrentScreenId <> screenStarMap) or (Galaxy.SpecialSimulationMode <> 0) then begin Result := False; Exit; end;
  if ((Byte(RespectChameleon) and Byte(GetPlayer.ChameleonActive)) <> 0) and IsPlayerChameleonEffectiveAgainstSelf and
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
{ @end $777128 }

{ @routine $777284 TShip_ShowPlayerDialogue }
function TShip.ShowPlayerDialogue(Kind: TTalkKind; const Text: WideString; Amount: Integer): Byte;
begin
  TalkType := Kind;
  if Amount > 0 then TalkAmount := Amount;
  TalkResponse := 0;
  TalkText := Text;
  Result := 0;
  if OpenPlayerConversation(True) then Result := TalkResponse;
end;
{ @end $777284 }

{ @routine $7772E8 TShip_NotifyMoneyDemand }
procedure TShip.NotifyMoneyDemand(OtherShip: TShip; Response: WideString; Amount: Integer);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + OtherShip.GetFullName(' ') + '</color>';
  Request := '- ' + ReplaceColoredToken(LookupTalkText('Talk.Money.Send'), '<Money>', IntToStr(Amount), '<color=255,240,100>');
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $7772E8 }

{ @routine $777594 TShip_NotifyCargoDemand }
procedure TShip.NotifyCargoDemand(OtherShip: TShip; Response: WideString);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + OtherShip.GetFullName(' ') + '</color>';
  Request := '- ' + WrapTextInColor(LookupTalkText('Talk.Goods.Send'), '');
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $777594 }

{ @routine $7777F4 TShip_NotifyFearCargoDrop }
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
        ReplaceTextToken(Request, '<ShipBad>', OtherShip.GetName, '<color=255,240,100>');
        ReplaceTextToken(Request, '<FullShipBad>', OtherShip.GetFullName(' '), '<color=255,240,100>');
        ReplaceTextToken(Request, '<Star>', CurrentStar.Name, '<color=255,240,100>');
        Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + ':';
        Request := '- ' + Request;
        with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + #13#10 + Request, '') do begin
          Targets[0].ShipId := Self.Id;
          Targets[1].ShipId := OtherShip.Id;
        end;
      end;
    end;
  end;
end;
{ @end $7777F4 }

{ @routine $777AF8 TShip_NotifyTruceOffer }
procedure TShip.NotifyTruceOffer(OtherShip: TShip; Response: WideString; Amount: Integer);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  if NoTalk or OtherShip.NoTalk then Exit;
  Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + OtherShip.GetFullName(' ') + '</color>';
  Request := '- ' + ReplaceColoredToken(LookupTalkText('Talk.Truce.' + GetTypeNameKey + 'Send'), '<Money>', IntToStr(Amount), '<color=255,240,100>');
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $777AF8 }

{ @routine $777DF0 TShip_NotifyAttackRequest }
procedure TShip.NotifyAttackRequest(OtherShip: TShip; Response: WideString; Target: TShip);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  if NoTalk or OtherShip.NoTalk then Exit;
  Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + OtherShip.GetFullName(' ') + '</color>';
  Request := '- ' + ReplaceColoredToken(LookupTalkText('Talk.Attack.' + GetTypeNameKey + 'Send'), '<Target>', Target.GetFullName(' '), '<color=255,240,100>');
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
    Targets[2].ShipId := Target.Id;
  end;
end;
{ @end $777DF0 }

{ @routine $7780E4 TShip_NotifyPartnershipOffer }
procedure TShip.NotifyPartnershipOffer(OtherShip: TShip; Response: WideString; Amount: Integer);
var Header, Request: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar <> CurrentStar) or not GetPlayer.InNormalSpace then Exit;
  RadarSquared := Sqr(GetPlayer.GetRadarRange);
  if not ((RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
    (RadarSquared >= PointDistanceSquared(OtherShip.Position, GetPlayer.Position))) then Exit;
  if NoTalk or OtherShip.NoTalk then Exit;
  Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + OtherShip.GetFullName(' ') + '</color>';
  Request := '- ' + FormatText1(LookupTalkText('Talk.Partner.Send'), '<color=255,240,100>', '<Money>', IntToStr(Amount));
  Response := '- ' + Response;
  with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + #13#10 + Request + #13#10 + Response, '') do begin
    Targets[0].ShipId := Self.Id;
    Targets[1].ShipId := OtherShip.Id;
  end;
end;
{ @end $7780E4 }

{ @routine $7783B8 TShip_NotifyPartnerBreak }
procedure TShip.NotifyPartnerBreak(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(tkPartnerBreak, LookupTalkText('Talk.Partner.MateBreak'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateBreak');
          Response := #13#10'- ' + LookupTalkText('Talk.Partner.AnswerLiderBreak');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $7783B8 }

{ @routine $7786E0 TShip_NotifyPartnershipExpired }
procedure TShip.NotifyPartnershipExpired(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      if GetPlayer.GetEffectiveSkillLevel(psLeadership) > GetPlayer.CountWingmen then
        ShowPlayerDialogue(tkPartnerEnd, LookupTalkText('Talk.Partner.MateTheEnd'), 0)
      else ShowPlayerDialogue(tkPartnerEnd, LookupTalkText('Talk.Partner.MateTheEndLowLeadership'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          if (GetPlayer <> Leader) or (GetPlayer.GetEffectiveSkillLevel(psLeadership) > GetPlayer.CountWingmen) then
            Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateTheEnd')
          else Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateTheEndLowLeadership');
          Response := #13#10'- ' + LookupTalkText('Talk.Partner.AnswerLiderTheEnd');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $7786E0 }

{ @routine $778AF0 TShip_NotifyPartnerRebellion }
procedure TShip.NotifyPartnerRebellion(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(tkPartnerRiot, LookupTalkText('Talk.Partner.MateRiot'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          Request := #13#10'- ' + LookupTalkText('Talk.Partner.MateRiot');
          Response := #13#10'- ' + LookupTalkText('Talk.Partner.AnswerLiderRiot');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $778AF0 }

{ @routine $778E14 TShip_ShowMessageToPlayer }
procedure TShip.ShowMessageToPlayer(Text: WideString);
begin
  if not NoTalk and not GetPlayer.NoTalk then
  begin
    TurnsSinceLastShipMessage := 0;
    with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn,
      WrapTextInColor(GetFullName(' '), '<color=255,240,100>') + #13#10 + ' ' + #13#10 + Text, '') do
    begin
      Targets[0].ShipId := Id;
      Targets[1].ShipId := GetPlayer.Id;
    end;
  end;
end;
{ @end $778E14 }

{ @routine $778F50 TShip_NotifyPiratePartnerRelationBreak }
procedure TShip.NotifyPiratePartnerRelationBreak(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(tkPartnerBreak, LookupTalkText('Talk.Pirate.MateBreakRelation'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateBreakRelation');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderBreak');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $778F50 }

{ @routine $779284 TShip_NotifyPiratePartnerRatingBreak }
procedure TShip.NotifyPiratePartnerRatingBreak(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(tkPartnerBreak, LookupTalkText('Talk.Pirate.MateBreakRating'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateBreakRating');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderBreak');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $779284 }

{ @routine $7795B4 TShip_NotifyPiratePartnershipExpired }
procedure TShip.NotifyPiratePartnershipExpired(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      if GetPlayer.GetEffectiveSkillLevel(psLeadership) > GetPlayer.CountWingmen then
        ShowPlayerDialogue(tkPartnerEnd, LookupTalkText('Talk.Pirate.MateTheEnd'), 0)
      else ShowPlayerDialogue(tkPartnerEnd, LookupTalkText('Talk.Pirate.MateTheEndLowLeadership'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          if (GetPlayer <> Leader) or (GetPlayer.GetEffectiveSkillLevel(psLeadership) > GetPlayer.CountWingmen) then
            Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateTheEnd')
          else Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateTheEndLowLeadership');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderTheEnd');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $7795B4 }

{ @routine $7799BC TShip_NotifyPiratePartnerRebellion }
procedure TShip.NotifyPiratePartnerRebellion(Leader: TShip);
var Header, Request, Response: WideString; RadarSquared: Integer;
begin
  if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then begin
    if (GetPlayer = Leader) and not PlayerAutomaticControl and not Leader.NoTalk then begin
      ShowPlayerDialogue(tkPartnerRiot, LookupTalkText('Talk.Pirate.MateRiot'), 0);
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Self, nil, 0);
    end else begin
      RadarSquared := Sqr(GetPlayer.GetRadarRange);
      if (RadarSquared >= PointDistanceSquared(Position, GetPlayer.Position)) or
        (RadarSquared >= PointDistanceSquared(Leader.Position, GetPlayer.Position)) then
        if not NoTalk and (not Leader.NoTalk or (GetPlayer = Leader)) then begin
          Header := '<color=255,240,100>' + GetFullName(' ') + '</color>' + LookupTalkText('Talk.To') + '<color=255,240,100>' + Leader.GetFullName(' ') + '</color>';
          Request := #13#10'- ' + LookupTalkText('Talk.Pirate.MateRiot');
          Response := #13#10'- ' + LookupTalkText('Talk.Pirate.AnswerLiderRiot');
          if Leader.NoTalk then Response := '';
          with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Header + Request + Response, '') do begin
            Targets[0].ShipId := Self.Id;
            Targets[1].ShipId := Leader.Id;
          end;
        end;
    end;
  end;
end;
{ @end $7799BC }

{ @routine $779CDC TShip_RefusesFactionNegotiation }
function TShip.RefusesFactionNegotiation(OtherShip: TShip): Boolean;
begin
  Result := False;
end;
{ @end $779CDC }

{ @routine $779CF4 TShip_CalculatePartnershipMonths }
function TShip.CalculatePartnershipMonths(Amount: Integer; OtherShip: TShip): Integer;
begin
  if Amount < Wealth / 45 then begin Result := 0; Exit; end;
  Result := Round(RemapClamped(Amount, Wealth / 45, Wealth / 8, 8, 36) *
    RemapClamped(RelationToShip(OtherShip), 50, 100, 0.7, 1.5));
  if (GetPlayer = OtherShip) and OtherShip.IsHealthEffectActive(20) then Result := Result * 2;
end;
{ @end $779CF4 }

{ @routine $779DF0 TShip_GetGreetingText }
function TShip.GetGreetingText: WideString;
var Key: WideString; Chameleon: Boolean; Series: Byte;
begin
  Chameleon := GetPlayer.ChameleonActive;
  if Self is TTranclucator then Key := 'Talk.Tranclucator.Greeting'
  else if IsFemaleHumanPilot then begin
    if GetPlayer = PartnerShip then begin
      if Chameleon then Key := 'ShipGreetings.Standart.FemalePartnerChameleon'
      else Key := 'ShipGreetings.Standart.FemalePartner';
    end else if Chameleon then begin
      if GetRelationLevelToShip(GetPlayer) < rlNormal then Key := 'ShipGreetings.Standart.FemaleChameleonWar'
      else Key := 'ShipGreetings.Standart.FemaleChameleon';
    end else begin
      Result := (Self as TNormalShip).SelectSituationalMessage(False);
      if Result <> '' then Exit;
      case Ord(GetRelationLevelToShip(GetPlayer)) of
        0: Key := 'ShipGreetings.Standart.FemaleWar';
        1: Key := 'ShipGreetings.Standart.FemaleBad';
        2: Key := 'ShipGreetings.Standart.FemaleNormal';
        3: Key := 'ShipGreetings.Standart.FemaleGood';
        4: Key := 'ShipGreetings.Standart.FemaleBest';
      end;
    end;
  end else if GetPlayer = PartnerShip then begin
    if Chameleon and (TypeId <> stPirate) then Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'PartnerChameleon'
    else Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Partner';
  end else if Self is TNormalShip then begin
    if Chameleon and (TypeId = stPirate) and (GetRelationLevelToShip(GetPlayer) < rlNormal) then
      Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'ChameleonWar'
    else if Chameleon and ((TypeId = stPirate) or IsPlayerChameleonEffectiveAgainstSelf) then
      Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Chameleon'
    else begin
      if (LiberationGroup <> nil) and (GetRelationLevelToShip(GetPlayer) > rlHostile) then begin
        Result := (TObject(LiberationGroup) as TGroup).GetShipGreeting(Self);
        if Result <> '' then Exit;
      end;
      Result := (Self as TNormalShip).SelectSituationalMessage(False);
      if Result <> '' then Exit;
      case Ord(GetRelationLevelToShip(GetPlayer)) of
        0: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'War';
        1: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Bad';
        2: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Normal';
        3: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Good';
        4: Key := 'ShipGreetings.Standart.' + GetTypeNameKey + 'Best';
      end;
    end;
  end else if Self is TKling then begin
    if not GetPlayer.HasProgram(prgIntercom) or not GetPlayer.CanResolveObjectWithScanner(Self) then Key := 'ShipGreetings.Dominator.Rnd'
    else begin
      if (Self as TKling).ActiveProgramAppliedTurn > 0 then Key := 'ShipGreetings.Dominator.ProgrammRun'
      else begin
        Series := Byte((Self as TKling).DominatorSeries);
        case Series of
          0: Key := 'ShipGreetings.Dominator.' + DominatorSeriesNames[0];
          1: Key := 'ShipGreetings.Dominator.' + DominatorSeriesNames[1];
          2: Key := 'ShipGreetings.Dominator.' + DominatorSeriesNames[2];
        end;
        if Chameleon and (Byte(GetPlayer.ChameleonSeries) = Series) and not GetPlayer.ChameleonDetected[Series] then Key := Key + 'Chameleon';
      end;
    end;
  end else begin Result := 'no greeting'; Exit; end;
  Result := LookupTalkText(Key);
  if (Self is TKling) and ((Self as TKling).ActiveProgramAppliedTurn > 0) then
    ReplaceTextToken(Result, '<Name>', GetPlayer.GetProgramName((Self as TKling).ActiveProgramId), '<color=255,240,100>');
end;
{ @end $779DF0 }

{ @routine $77A8F8 TShip_InitializeScriptStateOrders }
procedure TShip.InitializeScriptStateOrders;
var
  Binding: TScriptShip;
begin
  Binding := ScriptShip as TScriptShip;
  Binding.EndState := False;
  ApplyScriptStateOrders;
  UpdateScriptStateCompletionAndPickups;
end;
{ @end $77A8F8 }

{ @routine $77A934 TShip_ApplyScriptStateOrders }
procedure TShip.ApplyScriptStateOrders;
var
  Binding, OtherBinding: TScriptShip;
  FollowTarget: TShip;
  WeaponTotal, WeaponIndex, BindingIndex, BindingCount, GroupIndex, GroupCount: Integer;
  Weapon: TWeapon;
  Distance, BestDistance: Single;
  State: TScriptState;
  Place: TScriptPlace;
begin
  Binding := ScriptShip as TScriptShip;
  State := Binding.State;
  if InHyperspace or ((BlazerShip = Self) and OrderAbsolute) then Exit;
  if State.StateKind = sskIdle then OrderNone(False)
  else if State.StateKind = sskMoveToPlace then
  begin
    Place := TScriptPlace(State.TargetValue);
    if Place.PlaceKind = spkDockedPlanet then
    begin
      if IsOnPlanet and (TPlanet(Place.TargetValue) = CurrentPlanet) then OrderNone(False)
      else if IsOnPlanet or IsDockedToShip then OrderTakeoff
      else OrderLanding(TObject(Place.TargetValue), False);
    end
    else if Place.PlaceKind = spkScriptItem then
    begin
      if Place.TargetValue = 0 then OrderNone(False)
      else if CurrentStar.Items.IndexOf(TScriptItem(Place.TargetValue).Item) < 0 then OrderNone(False)
      else if IsOnPlanet or IsDockedToShip then OrderTakeoff
      else OrderMove(Place.GetRandomPoint((Seed + CurrentStar.GenerationSeed) * Galaxy.CurrentTurn), False);
    end
    else if IsOnPlanet or IsDockedToShip then OrderTakeoff
    else OrderMove(Place.GetRandomPoint((Seed + CurrentStar.GenerationSeed) * Galaxy.CurrentTurn), False);
  end
  else if State.StateKind = sskFollowGroup then
  begin
    if IsOnPlanet or IsDockedToShip then OrderTakeoff
    else
    begin
      FollowTarget := FindScriptFollowTarget;
      if FollowTarget = nil then OrderNone(False)
      else OrderFollowShip(FollowTarget, 0, False);
    end;
  end
  else if State.StateKind = sskJumpToStar then
  begin
    { Native repeats the planet test; it does not test docking here. }
    if IsOnPlanet or IsOnPlanet then OrderTakeoff
    else if InNormalSpace then OrderJump(TStar(State.TargetValue), False);
  end
  else if State.StateKind = sskLandOnPlanet then
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
    if (State.StateKind <> sskNormalAI) and (Self is TKling) then
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
          if not ((CurrentStar = OtherBinding.Ship.CurrentStar) and OtherBinding.Ship.InNormalSpace) then Continue;
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
{ @end $77A934 }

{ @routine $77AE70 TShip_UpdateScriptStateCompletionAndPickups }
procedure TShip.UpdateScriptStateCompletionAndPickups;
var
  Binding: TScriptShip;
  State: TScriptState;
  I: Integer;
  Item: TItem;
begin
  Binding := ScriptShip as TScriptShip;
  State := Binding.State;
  if State.StateKind = sskIdle then Binding.EndState := True
  else if State.StateKind = sskMoveToPlace then Binding.EndState := TScriptPlace(State.TargetValue).ShipInPlace(Self)
  else if State.StateKind = sskFollowGroup then Binding.EndState := FindScriptFollowTarget = nil
  else if State.StateKind = sskJumpToStar then
  begin
    if InHyperspace then Binding.EndState := False
    else Binding.EndState := CurrentStar = TStar(State.TargetValue);
  end
  else if State.StateKind = sskLandOnPlanet then Binding.EndState := IsOnPlanet and (CurrentPlanet = TPlanet(State.TargetValue));
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
{ @end $77AE70 }

{ @routine $77B05C TShip_ScriptNextDay }
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
{ @end $77B05C }

{ @routine $77B4B8 TShip_FindScriptFollowTarget }
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
{ @end $77B4B8 }

{ @routine $77B558 TShip_GainExperience }
procedure TShip.GainExperience(Amount: Integer; SourceKind: Byte);
var
  Awarded: Integer;
begin
  Awarded := Amount;
  if SourceKind = 0 then
  begin
    Inc(TotalExperience, Amount);
    Inc(FreeExperience, Amount);
  end
  else
  begin
    if GetPlayer = Self then
      case SourceKind of
        1: begin
          Awarded := Round(Awarded / (GetPlayer.ExperienceByDominators * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByDominators, Awarded);
        end;
        2: begin
          Awarded := Round(Awarded / ((GetPlayer.ExperienceByPirates + GetPlayer.ExperienceByNormals) * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByPirates, Awarded);
        end;
        3: begin
          Awarded := Round(Awarded / ((GetPlayer.ExperienceByPirates + GetPlayer.ExperienceByNormals) * 0.000001 + 1));
          Inc(GetPlayer.ExperienceByNormals, Awarded);
        end;
        4: begin
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
{ @end $77B558 }

{ @routine $77B73C TShip_RemoveExperience }
procedure TShip.RemoveExperience(Amount: Integer);
var
  Removed: Integer;
begin
  Removed := Min(Amount, TotalExperience);
  Dec(TotalExperience, Removed);
  Removed := Min(Amount, FreeExperience);
  Dec(FreeExperience, Removed);
end;
{ @end $77B73C }

{ @routine $77B7B4 TShip_DepositCarriedNodes }
procedure TShip.DepositCarriedNodes;
var I: Integer; Item: TItem;
begin
  for I := Inventory.Count - 1 downto 1 do
  begin
    Item := TItem(Inventory[I]);
    if Item.ItemType = t_Protoplasm then
    begin
      Inc(NodeReserve, Item.Weight);
      if (Self is TWarrior) and ((Self as TWarrior).WarriorType = wtFlagship) then GainExperience(Round(Item.Weight * 2.0), 0)
      else GainExperience(Item.Weight, 0);
      if Self is TRanger then Inc((Self as TRanger).BaseNodes, Item.Weight);
      Inventory.Delete(I);
      Item.Free;
    end;
  end;
  RefreshDerivedStats(True);
end;
{ @end $77B7B4 }

{ @routine $77B8C4 TShip_TrainSkill }
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
{ @end $77B8C4 }

{ @routine $77BA18 TShip_CanTrainSkill }
function TShip.CanTrainSkill(Skill: TPilotSkill): Boolean;
begin
  Result := (BaseSkills[Skill] < 6) and
    (SkillTrainingCosts[BaseSkills[Skill] + 1, Skill] <= FreeExperience);
end;
{ @end $77BA18 }

{ @routine $77BA78 TShip_GetBaseSkillLevel }
function TShip.GetBaseSkillLevel(Skill: TPilotSkill): Byte;
begin
  Result := BaseSkills[Skill];
end;
{ @end $77BA78 }

{ @routine $77BAA0 TShip_GetEffectiveSkillLevel }
function TShip.GetEffectiveSkillLevel(Skill: TPilotSkill; IgnoreStatusEffects: Boolean): TPilotSkillLevel;
var
  Level: Integer;
  BonusKind: TEquipmentBonusKind;
begin
  Level := Integer(Self.BaseSkills[Skill]);
  BonusKind := TEquipmentBonusKind(Ord(Skill) + Ord(bonSkill1));
  if not (IgnoreStatusEffects) then
  begin
    if Self.IsHealthEffectActive(1) then
    begin
      if Skill = psAccuracy then Dec(Level, 3);
      if Skill = psManeuverability then Dec(Level, 3);
      if Skill = psTechnical then Dec(Level, 3);
      if Skill = psTrading then Dec(Level, 3);
    end;
    if Self.IsHealthEffectActive(3) then
    begin
      if Skill = psAccuracy then Inc(Level, 1);
      if Skill = psManeuverability then Inc(Level, 1);
      if Skill = psCharisma then Dec(Level, 1);
      if Skill = psLeadership then Inc(Level, 2);
    end;
    if Self.IsHealthEffectActive(5) then
    begin
      if Skill = psAccuracy then Dec(Level, 2);
      if Skill = psCharisma then Inc(Level, 3);
    end;
    if Self.IsHealthEffectActive(6) then
    begin
      if Skill = psAccuracy then Dec(Level, 3);
      if Skill = psManeuverability then Dec(Level, 3);
      if Skill = psTechnical then Dec(Level, 2);
    end;
    if Self.IsHealthEffectActive(7) then
    begin
      if Skill = psAccuracy then Dec(Level, 2);
      if Skill = psManeuverability then Dec(Level, 5);
      if Skill = psTrading then Dec(Level, 10);
    end;
    if Self.IsHealthEffectActive(8) then
    begin
      if Skill = psAccuracy then Dec(Level, 2);
      if Skill = psManeuverability then Dec(Level, 2);
      if Skill = psTechnical then Dec(Level, 2);
      if Skill = psCharisma then Dec(Level, 1);
      if Skill = psLeadership then Dec(Level, 1);
    end;
    if Self.IsHealthEffectActive(9) then
    begin
      if Skill = psLeadership then Inc(Level, 3);
      if Skill = psTrading then Inc(Level, 3);
    end;
    if Self.IsHealthEffectActive(10) then
    begin
      if Skill = psTechnical then Dec(Level, 10);
    end;
    if Self.IsHealthEffectActive(11) then
    begin
      if Skill = psAccuracy then Dec(Level, 1);
      if Skill = psTechnical then Dec(Level, 2);
      if Skill = psTrading then Inc(Level, 2);
    end;
    if Self.IsHealthEffectActive(12) then
    begin
      if Skill = psAccuracy then Inc(Level, 1);
      if Skill = psManeuverability then Inc(Level, 1);
    end;
    if Self.IsHealthEffectActive(13) then
    begin
      if Skill = psAccuracy then Inc(Level, 4);
      if Skill = psManeuverability then Inc(Level, 3);
    end;
    if Self.IsHealthEffectActive(14) then
    begin
      if Skill = psCharisma then Dec(Level, 1);
      if Skill = psLeadership then Dec(Level, 1);
    end;
    if Self.IsHealthEffectActive(15) then
    begin
      if Skill = psAccuracy then Inc(Level, 1);
      if Skill = psManeuverability then Inc(Level, 1);
      if Skill = psTechnical then Inc(Level, 1);
      if Skill = psTrading then Inc(Level, 1);
    end;
    if Self.IsHealthEffectActive(16) then
    begin
      if Skill = psTechnical then Inc(Level, 5);
    end;
    if Self.IsHealthEffectActive(17) then
    begin
      if Skill = psAccuracy then Inc(Level, 4);
      if Skill = psManeuverability then Inc(Level, 2);
    end;
    if Self.IsHealthEffectActive(19) then
    begin
      if Skill = psCharisma then Inc(Level, 10);
    end;
    if Self.IsHealthEffectActive(20) then
    begin
      if Skill = psCharisma then Inc(Level, 1);
      if Skill = psLeadership then Inc(Level, 4);
    end;
    if Self.IsHealthEffectActive(21) then
    begin
      if Skill = psCharisma then Dec(Level, 3);
    end;
    if Self.IsHealthEffectActive(22) then
    begin
      if Skill = psTrading then Inc(Level, 8);
    end;
    if Self.IsHealthEffectActive(23) then
    begin
      if Skill = psAccuracy then Dec(Level, 1);
      if Skill = psManeuverability then Dec(Level, 1);
    end;
    if Self.IsHealthEffectActive(24) then
    begin
      if Skill = psCharisma then Inc(Level, 2);
    end;
    if (Self.TypeId = stKling) then
    begin
      if TKling((Self as TKling)).IsProgramActive(prgShock) then
      begin
        if Skill = psAccuracy then Dec(Level, 4);
        if Skill = psManeuverability then Dec(Level, 4);
        if Skill = psTechnical then Dec(Level, 4);
      end;
    end;
  end;
  Level := (Level + Self.GetTotalStatBonus(BonusKind));
  Result := Max(0, Min(Level, 6));
  Exit;
end;
{ @end $77BAA0 }

{ @routine $77BE8C TShip_GetRelativeStrengthCategory }
function TShip.GetRelativeStrengthCategory: Byte;
var
  Percent: Byte;
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
{ @end $77BE8C }

{ @routine $77BFF0 TShip_GetHullConditionCategory }
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
{ @end $77BFF0 }

{ @routine $77C100 TShip_GetRangerRatingBand }
function TShip.GetRangerRatingBand: Byte;
begin
  Result := 0;
  if TypeId = stRanger then
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
{ @end $77C100 }

{ @routine $77C23C TShip_HasActiveDisease }
function TShip.HasActiveDisease: Boolean;
var I: Integer;
begin
  for I := 1 to 12 do
    if CaptainHealth[I].Progress = 100 then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $77C23C }

{ @routine $77C288 TShip_CountActiveDiseases }
function TShip.CountActiveDiseases: Integer;
var I: Integer;
begin
  Result := 0;
  for I := 1 to 12 do
    if CaptainHealth[I].Progress = 100 then Inc(Result);
end;
{ @end $77C288 }

{ @routine $77C2D0 TShip_HasPresentDisease }
function TShip.HasPresentDisease: Boolean;
var I: Integer;
begin
  for I := 1 to 12 do
    if CaptainHealth[I].Progress > 0 then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $77C2D0 }

{ @routine $77C31C TShip_CountPresentDiseases }
function TShip.CountPresentDiseases: Integer;
var I: Integer;
begin
  Result := 0;
  for I := 1 to 12 do
    if CaptainHealth[I].Progress > 0 then Inc(Result);
end;
{ @end $77C31C }

{ @routine $77C364 TShip_HasActiveStimulant }
function TShip.HasActiveStimulant: Boolean;
var I: Integer;
begin
  for I := 13 to 24 do
    if CaptainHealth[I].Progress = 100 then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $77C364 }

{ @routine $77C3B0 TShip_CountActiveStimulants }
function TShip.CountActiveStimulants: Integer;
var I: Integer;
begin
  Result := 0;
  for I := 13 to 24 do
    if CaptainHealth[I].Progress = 100 then Inc(Result);
end;
{ @end $77C3B0 }

{ @routine $77C3F8 TShip_CountPresentDiseasesAndActiveStimulants }
function TShip.CountPresentDiseasesAndActiveStimulants: Integer;
begin
  Result := CountPresentDiseases + CountActiveStimulants;
end;
{ @end $77C3F8 }

{ @routine $77C424 TShip_HasDiseaseFromCurrentPlanet }
function TShip.HasDiseaseFromCurrentPlanet: Boolean;
var I: Integer;
begin
  for I := 1 to 12 do
    if (CaptainHealth[I].Progress > 0) and (CurrentPlanet <> nil) and (GetPlayer = Self) and
      (CurrentPlanet.GetFullName(' ') = GetPlayer.StatusEffectSourceNames[I]) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $77C424 }

{ @routine $77C4E8 TShip_HasDiseaseFromCurrentDockedShip }
function TShip.HasDiseaseFromCurrentDockedShip: Boolean;
var I: Integer;
begin
  for I := 1 to 12 do
    if (CaptainHealth[I].Progress > 0) and (DockedTo <> nil) and (GetPlayer = Self) and
      (DockedTo.GetName = GetPlayer.StatusEffectSourceNames[I]) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $77C4E8 }

{ @routine $77C5A0 TShip_IsHealthEffectActive }
function TShip.IsHealthEffectActive(Index: Integer): Boolean;
begin
  Result := CaptainHealth[Index].Progress = 100;
end;
{ @end $77C5A0 }

{ @routine $77C5D8 TShip_SimulateNpcHealthEffects }
procedure TShip.SimulateNpcHealthEffects;
var
  Index, I: Integer;
begin
  if GetPlayer = Self then Exit;
  if (ScriptShip <> nil) and IsOnPlanet then RefuelAtLocation;
  if (DaysSincePlayerSeen > 100) and (TypeId in [stRanger..stWarrior]) and
    (CountPresentDiseasesAndActiveStimulants < Integer(Seed) mod 3 + 1) then
  begin
    if (DockedTo <> nil) and (DockedTo.TypeId = Byte(rstMedicalBase)) then
    begin
      for I := 1 to 12 do
        if CaptainHealth[I].Progress <> 0 then
        begin
          CaptainHealth[I].Progress := 0;
          CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn;
        end;
      Index := NextRandomIntRange(13, 24, RandomState);
      if CaptainHealth[Index].Progress > 0 then Index := NextRandomIntRange(13, 24, RandomState);
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
      Index := NextRandomIntRange(1, 24, RandomState);
      if CaptainHealth[Index].Progress > 0 then Index := NextRandomIntRange(1, 24, RandomState);
      if (CaptainHealth[Index].Progress <= 0) and (RaceToOwner(PilotRace) in CaptainHealthDefinitions[Index].AllowedOwners) then
      begin
        CaptainHealth[Index].Progress := 100;
        CaptainHealth[Index].AppliedTurn := Galaxy.CurrentTurn;
        CaptainHealth[Index].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Galaxy.GenerationSeed + Index + Galaxy.CurrentTurn), 0, 1, 0.5, 3) * CaptainHealthDefinitions[Index].Duration);
        Inc(CaptainHealth[Index].ApplicationCount);
      end;
    end;
  end;
  if CountActiveDiseases > 0 then
    for Index := 1 to 12 do
      if (CaptainHealth[Index].Progress <> 0) and (CaptainHealth[Index].ExpireTurn <= Galaxy.CurrentTurn) then CaptainHealth[Index].Progress := 0;
end;
{ @end $77C5D8 }

{ @routine $77CA44 TShip_HasRadiationSickness }
function TShip.HasRadiationSickness: Boolean;
begin
  Result := RadiationHealth[1].Progress > 0;
end;
{ @end $77CA44 }

{ @routine $77CA70 TShip_CalculateSpeed }
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
    if AfterburnerActive and (GetEngine.BrokenFlag = 0) and (GetSlotCount(sskAfterburner) > 0) then
      OldSpeed := OldSpeed * AfterburnerSpeedFactor;
    if GetEngine.BrokenFlag <> 0 then OldSpeed := OldSpeed * 0.6;
    if TypeId = stKling then
    begin
      if (Self as TKling).IsProgramActive(prgInsanity) then OldSpeed := OldSpeed * 0.5;
    end
    else
    begin
      if IsHealthEffectActive(17) then OldSpeed := OldSpeed * 1.3;
      if Artefacts.Count > 0 then
      begin
        if CountActiveArtefacts(t_ArtefactSpeed) > 0 then
          OldSpeed := OldSpeed * Math.Power(SpeedArtefactFactor + SpeedArtefactBoostFactor * ShortInt(CanBoostArtefact(t_ArtefactSpeed, nil, False)), CountActiveArtefacts(t_ArtefactSpeed));
        if CountActiveArtefacts(t_ArtWeaponToSpeed) > 0 then
          OldSpeed := OldSpeed + CountActiveArtefacts(t_ArtWeaponToSpeed) * (WeaponToSpeedArtefactBonus + WeaponToSpeedArtefactBoost * Byte(CanBoostArtefact(t_ArtWeaponToSpeed, GetEngine, False)));
      end;
    end;
    OldSpeed := Max(167.0, OldSpeed + GetTotalStatBonus(bonSpeed));
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
    if TypeId = stKling then
      if (Self as TKling).IsProgramActive(prgInsanity) then CombinedFactor := CombinedFactor + Sqr(Ln(0.5));
    CombinedFactor := Exp(-Sqrt(CombinedFactor + MassPenalty + EnginePenalty));
    if AfterburnerActive and IsEquipmentUsable(GetEngine) and (GetSlotCount(sskAfterburner) > 0) then
      CombinedFactor := CombinedFactor * AfterburnerSpeedFactor;
    if IsHealthEffectActive(17) then CombinedFactor := CombinedFactor * 1.3;
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
{ @end $77CA70 }

{ @routine $77D09C TShip_IsFemaleHumanPilot }
function TShip.IsFemaleHumanPilot: Boolean;
begin
  Result := (PilotRace = oiHuman) and (PortraitFaceId in [25..32]) and (GetPlayer <> Self) and (GetPlayer <> nil) and (Self is TNormalShip) and (Galaxy.SpecialSimulationMode = 0);
end;
{ @end $77D09C }

{ @routine $77D108 TShip_UsesVeteranHumanRangerAppearance }
function TShip.UsesVeteranHumanRangerAppearance: Boolean;
begin
  Result := (TypeId = stRanger) and (PilotRace = oiHuman) and (Cardinal(Id) mod 6 = 0) and (CreationTurn < 666) and (GetPlayer <> Self) and (GetPlayer <> nil) and not IsFemaleHumanPilot and (Galaxy.SpecialSimulationMode = 0);
end;
{ @end $77D108 }

{ @routine $77D384 TShip_SelectInterceptorTarget }
function TShip.SelectInterceptorTarget: TShip;
var
  I: Integer;
  Ship, Current: TShip;
  Strategy: TInterceptorTargetingStrategy;
// @nested $77D188 IsBetterInterceptorTarget
function IsBetterInterceptorTarget(Current, Candidate: TShip; Strategy: TInterceptorTargetingStrategy): Boolean; // @addr 0x77D188 @note "Caller-popped static link; source ship at -4 for distance strategies."
begin
  case Strategy of
    itsMostHullPoints: Result := Candidate.GetHull.HullPoints > Current.GetHull.HullPoints;
    itsFewestHullPoints: Result := Candidate.GetHull.HullPoints < Current.GetHull.HullPoints;
    itsStrongestDefense: Result :=
      RemapClamped(Candidate.GetEffectiveSkillLevel(psManeuverability), 0, 6, 1.5, 0.5) * 50 * Candidate.DefenseDamageFactor - Candidate.GetHull.Armor <
      RemapClamped(Current.GetEffectiveSkillLevel(psManeuverability), 0, 6, 1.5, 0.5) * 50 * Current.DefenseDamageFactor - Current.GetHull.Armor;
    itsGreatestStrength: Result := Candidate.Strength > Current.Strength;
    itsNearest: Result := PointDistanceSquared(Candidate.Position, Position) < PointDistanceSquared(Current.Position, Position);
    itsFarthest: Result := PointDistanceSquared(Candidate.Position, Position) > PointDistanceSquared(Current.Position, Position);
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
  if GetPlayer = Self then Strategy := GetHull.InterceptorTargetingStrategy else Strategy := itsMostHullPoints;
  if Strategy = itsManual then
  begin
    Result := nil;
    Exit;
  end;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if (Ship <> Self) and Ship.InNormalSpace and
      ((GetPlayer = Self) or (GetRelationLevelToShip(Ship) <= rlHostile)) and
      ((GetPlayer <> Self) or (Ship.GetRelationLevelToShip(Self) <= rlHostile) or (EnemyShip = Ship) or (PendingPlayerFollowTarget = Ship)) and
      (Sqr(Ship.Position.X) + Sqr(Ship.Position.Y) >= CurrentStar.DamageRadius * CurrentStar.DamageRadius) and
      (PointDistanceSquared(Position, Ship.Position) <= InterceptorTargetRangeSquared) and
      (Ship.InterceptorPassesRemaining <= 0) and
      ((Current = nil) or IsBetterInterceptorTarget(Current, Ship, Strategy)) then Current := Ship;
  end;
  Result := Current;
end;
{ @end $77D384 }

{ @routine $77D520 TShip_LaunchInterceptors }
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
  if Target.InterceptorGraphic = nil then
  begin
    RetainSpaceObject(Target.InterceptorGraphic, CreateSpaceObjectByName('Ruins', 'Ruins.FighterSwarm', Classes.Point(0, 0)));
    Target.InterceptorGraphic.SetPosition(Target.Position);
    Target.InterceptorGraphic.SetAngle(HeadingDegreesToByte(Target.MovementDirection));
    Target.InterceptorGraphic.SetAlpha(0);
  end;
end;
{ @end $77D520 }

{ @routine $77D680 TShip_ClearIncomingInterceptors }
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
{ @end $77D680 }

{ @routine $77D6C8 TShip_CountActiveInterceptorTargets }
function TShip.CountActiveInterceptorTargets: Integer;
var
  Count, I, J: Integer;
  Star: TStar;
begin
  Count := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
      if TShip(Star.Ships[J]).InterceptorSourceShip = Self then Inc(Count);
  end;
  Result := Count;
end;
{ @end $77D6C8 }

{ @routine $77D75C TShip_GetHullEnergyRegeneration }
function TShip.GetHullEnergyRegeneration: Integer;
begin
  Result := Round(RemapClamped(GetEffectiveSkillLevel(psTechnical), 0, 6, 1, 2) *
    (RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, 0, 1) * 10));
end;
{ @end $77D75C }

{ @routine $77D7F8 TShip_GetInterceptorDamage }
function TShip.GetInterceptorDamage: Integer;
begin
  Result := Round(RemapClamped(GetEffectiveSkillLevel(psTechnical), 0, 6, 1, 2) * 25);
end;
{ @end $77D7F8 }

{ @routine $77D854 TShip_GetInterceptorEnergyCost }
function TShip.GetInterceptorEnergyCost: Integer;
begin
  Result := 5 * GetInterceptorPassCount + 5;
end;
{ @end $77D854 }

{ @routine $77D87C TShip_GetInterceptorPassCount }
function TShip.GetInterceptorPassCount: Byte;
begin
  if GetHull.InterceptorPassCountOverride = 0 then Result := 5
  else Result := GetHull.InterceptorPassCountOverride;
end;
{ @end $77D87C }

{ @routine $77D8B4 TShip_HasScriptControl }
function TShip.HasScriptControl: Boolean;
begin
  Result := ((ScriptShip <> nil) and ((ScriptShip as TScriptShip).State.StateKind <> sskNormalAI)) or (AbsoluteScriptOrder > 0);
end;
{ @end $77D8B4 }

{ @routine $77D904 TShip_HasNoUsableWeapons }
function TShip.HasNoUsableWeapons: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to WeaponCount do
    if (Weapons[I].EquippedFlag <> 0) and
       (not (Weapons[I].GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) or (Weapons[I].Ammo > 0)) and
       IsEquipmentUsable(Weapons[I]) then
    begin
      Result := False;
      Break;
    end;
end;
{ @end $77D904 }

{ @routine $77D998 TShip_GetOwnStatBonus }
function TShip.GetOwnStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  I: Integer;
  Bonus: PShipStatBonusEntry;
begin
  Result := 0;
  if (StatBonuses = nil) or (StatBonuses.Count = 0) then Exit;
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
{ @end $77D998 }

{ @routine $77DA18 TShip_SetStatBonus }
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
{ @end $77DA18 }

{ @routine $77DB28 TShip_FindCombatStatusEffect }
function TShip.FindCombatStatusEffect(EffectType: TCombatStatusEffectType): Integer;
var
  I: Integer;
begin
  Result := -1;
  if CombatStatusEffects = nil then Exit;
  if CombatStatusEffects.Count = 0 then Exit;
  for I := 0 to CombatStatusEffects.Count - 1 do
    if PCombatStatusEffect(CombatStatusEffects[I]).EffectType = EffectType then
    begin
      Result := I;
      Exit;
    end;
end;
{ @end $77DB28 }

{ @routine $77DBA4 TShip_AddCombatStatusStrength }
procedure TShip.AddCombatStatusStrength(EffectType: TCombatStatusEffectType; Strength: Single; Source: TShip);
var
  I: Integer;
  Entry: PCombatStatusEffect;
begin
  if CombatStatusEffects = nil then CombatStatusEffects := TList.Create;
  I := FindCombatStatusEffect(EffectType);
  if I >= 0 then
  begin
    Entry := CombatStatusEffects[I];
    Entry.Strength := Entry.Strength + Strength / (1 + (GetHull.Weight / (HullBaseSize * EquipmentSizeFactors[1]) - 1) * (CombatStatusHullFactors[Ord(EffectType)] * 0.5)) / (1 + CombatStatusAccumulationFactors[Ord(EffectType)] * Entry.Strength);
    if Source <> nil then Entry.SourceShipId := Source.Id else Entry.SourceShipId := 0;
  end
  else
  begin
    New(Entry);
    Entry.EffectType := EffectType;
    Entry.Strength := Strength / (1 + (GetHull.Weight / (HullBaseSize * EquipmentSizeFactors[1]) - 1) * (CombatStatusHullFactors[Ord(EffectType)] * 0.5));
    if Source <> nil then Entry.SourceShipId := Source.Id else Entry.SourceShipId := 0;
    CombatStatusEffects.Add(Entry);
  end;
end;
{ @end $77DBA4 }

{ @routine $77DD24 TShip_ReduceCombatStatusStrength }
procedure TShip.ReduceCombatStatusStrength(EffectType: TCombatStatusEffectType; Amount: Single);
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
{ @end $77DD24 }

{ @routine $77DDC0 TShip_ClearCombatStatusEffects }
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
{ @end $77DDC0 }

{ @routine $77DE1C TShip_DecayCombatStatusEffects }
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
      cseShock: Amount := GetShockStatusDecay(Entry.Strength);
      cseAcid: Amount := GetAcidStatusDecay(Entry.Strength);
      cseMagnetic: Amount := GetMagneticStatusDecay(Entry.Strength);
      cseWeaponBlock: Amount := GetWeaponBlockStatusDecay(Entry.Strength);
      cseDroidBlock: Amount := GetDroidBlockStatusDecay(Entry.Strength);
      cseBWBuff: Amount := GetBWBuffStatusDecay(Entry.Strength);
      cseBWRepairDebuff: Amount := GetBWRepairDebuffStatusDecay(Entry.Strength);
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
{ @end $77DE1C }

{ @routine $77DF7C TShip_GetShockStatusDecay }
function TShip.GetShockStatusDecay(Strength: Single): Single;
var
  I: Integer;
begin
  Result := 0.1 * Strength + 5;
  for I := 1 to CountActiveArtefacts(t_ArtefactHull) do Result := Result * (HullArtefactStatusDecayFactor + ShortInt(CanBoostArtefact(t_ArtefactHull, nil, False)) * HullArtefactBoostStatusDecay);
  if (TypeId = stKling) and (Ord((Self as TKling).KlingType) = 0) then Result := Result * 2;
end;
{ @end $77DF7C }

{ @routine $77E030 TShip_GetAcidStatusDecay }
function TShip.GetAcidStatusDecay(UnusedStrength: Single): Single;
var
  I: Integer;
begin
  Result := 0.2;
  if IsEquipmentUsable(GetRepairRobot) then Result := 0.2 + Result;
  for I := 1 to CountActiveArtefacts(t_ArtefactDroid) do Result := Result * (DroidArtefactStatusDecayFactor + ShortInt(CanBoostArtefact(t_ArtefactDroid, nil, False)) * DroidArtefactBoostStatusDecay);
  if (TypeId = stKling) and (Ord((Self as TKling).KlingType) = 0) then Result := Result * 2;
end;
{ @end $77E030 }

{ @routine $77E0F8 TShip_GetMagneticStatusDecay }
function TShip.GetMagneticStatusDecay(Strength: Single): Single;
begin
  Result := 0.1 * Strength + 5;
  if (TypeId = stKling) and (Ord((Self as TKling).KlingType) = 0) then Result := Result * 2;
end;
{ @end $77E0F8 }

{ @routine $77E160 TShip_GetWeaponBlockStatusDecay }
function TShip.GetWeaponBlockStatusDecay(Strength: Single): Single;
begin
  Result := Strength + 1;
end;
{ @end $77E160 }

{ @routine $77E184 TShip_GetDroidBlockStatusDecay }
function TShip.GetDroidBlockStatusDecay(Strength: Single): Single;
begin
  Result := Strength + 1;
end;
{ @end $77E184 }

{ @routine $77E1A8 TShip_GetBWBuffStatusDecay }
function TShip.GetBWBuffStatusDecay(Strength: Single): Single;
begin
  Result := 0.05 * Strength + 0.5;
end;
{ @end $77E1A8 }

{ @routine $77E1E0 TShip_GetBWRepairDebuffStatusDecay }
function TShip.GetBWRepairDebuffStatusDecay(Strength: Single): Single;
begin
  Result := 0.01 * Strength + 25;
end;
{ @end $77E1E0 }

{ @routine $77E218 TShip_ClearCombatStatusSourceReferences }
procedure TShip.ClearCombatStatusSourceReferences(Source: TShip);
var
  I: Integer;
begin
  if CombatStatusEffects = nil then Exit;
  if CombatStatusEffects.Count = 0 then Exit;
  for I := 0 to CombatStatusEffects.Count - 1 do
    if PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId = Source.Id then
      PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId := 0;
end;
{ @end $77E218 }

{ @routine $77E29C TShip_GetCombatStatusStrength }
function TShip.GetCombatStatusStrength(EffectType: TCombatStatusEffectType): Single;
var
  I: Integer;
begin
  Result := 0;
  I := FindCombatStatusEffect(EffectType);
  if I >= 0 then Result := PCombatStatusEffect(CombatStatusEffects[I]).Strength;
end;
{ @end $77E29C }

{ @routine $77E2E0 TShip_GetCombatStatusSourceId }
function TShip.GetCombatStatusSourceId(EffectType: TCombatStatusEffectType): Integer;
var
  I: Integer;
begin
  Result := 0;
  I := FindCombatStatusEffect(EffectType);
  if I >= 0 then Result := PCombatStatusEffect(CombatStatusEffects[I]).SourceShipId;
end;
{ @end $77E2E0 }

{ @routine $77E43C TShip_GetCombatStatusDescription }
function TShip.GetCombatStatusDescription(out Count: Integer; ShowStrength: Boolean): WideString;
var
  Strength, I: Integer;
  Info: PCustomShipInfo;
// @nested $77E324 AppendStatusLine
procedure AppendStatusLine(TextKey: WideString); // @addr 0x77E324 @note "Caller-popped static link; show-strength flag -1, strength -8, count output -12, string-result output +8."
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
    Strength := Round(GetCombatStatusStrength(cseBWBuff));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISEBWBuff');
    Strength := Round(GetCombatStatusStrength(cseAcid));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISEAcid');
    Strength := Round(GetCombatStatusStrength(cseShock));
    if Strength >= 1 then AppendStatusLine('FormInfo.ISECharged');
    Strength := Round(GetCombatStatusStrength(cseMagnetic));
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
{ @end $77E43C }

{ @routine $77E6D4 TShip_UpdateAfterburnerState }
procedure TShip.UpdateAfterburnerState;
begin
end;
{ @end $77E6D4 }

{ @routine $77E6E0 TShip_RefreshCurrentStanding }
procedure TShip.RefreshCurrentStanding;
var
  StandingMode: TScriptStandingOverrideMode;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then CurrentStanding := ssUnaligned;
end;
{ @end $77E6E0 }

{ @routine $77E71C TShip_HasScriptStateText }
function TShip.HasScriptStateText: Boolean;
begin
  Result := (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '');
end;
{ @end $77E71C }

{ @routine $77E758 TShip_HasIndependentScriptFaction }
function TShip.HasIndependentScriptFaction: Boolean;
begin
  Result := (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '') and
    (FindTextOffsetW(TScriptShip(ScriptShip).StateText, 'SubFaction') <> 0);
end;
{ @end $77E758 }

{ @routine $77E7CC TShip_HasNamedScriptFaction }
function TShip.HasNamedScriptFaction: Boolean;
begin
  Result := (ScriptShip <> nil) and (TScriptShip(ScriptShip).StateText <> '') and
    (TScriptShip(ScriptShip).StateText <> 'SubFactionFixedStanding');
end;
{ @end $77E7CC }

{ @routine $77E854 TShip_GetScriptStandingOverrideMode }
function TShip.GetScriptStandingOverrideMode: TScriptStandingOverrideMode;
begin
  Result := ssmNormal;
  if (Self.ScriptShip = nil) then
  begin
    Exit;
  end
  else if (TScriptShip(Self.ScriptShip).StateText = '') then
  begin
    Exit;
  end
  else if (FindTextOffsetW(TScriptShip(Self.ScriptShip).StateText, 'SubFaction') <> 0) then
  begin
    Result := ssmCustomFaction;
    Exit;
  end
  else if (FindTextOffsetW(TScriptShip(Self.ScriptShip).StateText, 'FixedStanding') >= 0) then
  begin
    Result := ssmFixed;
    Exit;
  end
  else
  begin
    Exit;
  end;
end;
{ @end $77E854 }

{ @routine $77E910 TShip_ScriptItemsAct }
function TShip.ScriptItemsAct(ActionType: Byte; Object1, Object2: TObject; Param: Integer): Integer;
var
  I, NewIndex: Integer;
  Item: TItem;
  Info: PCustomShipInfo;
  Binding: TScriptShip;
  SavedScript: TScript;
  Stage: Integer;
  Reserved: array[0..7] of Byte; // Native keeps eight unused bytes before backend string temporaries.
begin
  Stage := 0;
  if (ActionType = satOnLeavingForm) and (TalkScreen.ParentLoop = nil) then WaitForTurnCalculation;
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
        if IsHullDestroyed and (ActionType <> satOnDeath) then
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
        if IsHullDestroyed and (ActionType <> satOnDeath) then
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
        if IsHullDestroyed and (ActionType <> satOnDeath) then
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
        if Item.ItemType in [t_Weapon1..t_CustomWeapon] then
        begin
          if (ActionType in [1, 2, 10]) and (Object2 <> Item) then
          begin
            Dec(I);
            Continue;
          end;
          if (ActionType in [11, 23]) and (Object2 <> nil) and (TMissile(Object2).WeaponId <> Item.Id) then
          begin
            Dec(I);
            Continue;
          end;
        end;
        Param := TScriptItem(Item.ScriptItem).RunActionCode(ActionType, Self, Object1, Object2, Param);
        if IsHullDestroyed and (ActionType <> satOnDeath) then
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
        if IsHullDestroyed and (ActionType <> satOnDeath) then
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
        if IsHullDestroyed and (ActionType <> satOnDeath) then
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
{ @end $77E910 }

{ @routine $77F4B8 TShip_CanDock }
function TShip.CanDock(Ship: TShip): Boolean;
begin
  Result := False;
end;
{ @end $77F4B8 }

{ @routine $77F4D0 TShip_CheckDockingPermission }
function TShip.CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean;
begin
  Response := '';
  Result := False;
end;
{ @end $77F4D0 }

{ @routine $77F4F4 TShip_RelationToShip }
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
  if (Ship = EnemyShip) or (Ship.EnemyShip = Self) or
    ((CurrentStanding = ssDominator) <> (Ship.CurrentStanding = ssDominator)) or
    ((CurrentStanding = ssCustom) <> (Ship.CurrentStanding = ssCustom)) then Exit;
  if CurrentStanding = ssCustom then
  begin
    if (ScriptShip <> nil) and (Ship.ScriptShip <> nil) and
      (TScriptShip(ScriptShip).StateText = TScriptShip(Ship.ScriptShip).StateText) then Result := 100;
    Exit;
  end;

  if (Ship <> TruceShip) and (Ship.TruceShip <> Self) then
    if ((CurrentStanding = ssCoalitionMilitary) and (Ship.CurrentStanding in [ssPirateActive..ssPirateMilitary])) or
      ((CurrentStanding = ssPirateMilitary) and (Ship.CurrentStanding in [ssCoalitionMilitary..ssCoalitionActive])) then Exit;
  if (CurrentStanding <> ssDominator) and (Ship.TypeId = stKling) and (Ship.CurrentStanding = ssNeutral) then Result := 100
  else if Ship is TRanger then Result := RelationToRanger(Ship)
  else if (Ship is TTranclucator) and ((Ship as TTranclucator).OwnerShip <> nil) then
    Result := RelationToShip((Ship as TTranclucator).OwnerShip)
  else Result := RelationToNonRanger(Ship);
end;
{ @end $77F4F4 }

end.
