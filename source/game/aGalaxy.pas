unit aGalaxy;
// Unit bracket (inferred): .text 0x0079C19C..0x007D49C1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses aGalaxyStruct, aPath, SE_Space, aConst, GI_Panel, GI_MessageLoop, EC_Buf, EC_Struct, aMyFunction, EC_BlockPar, Classes, Types, aVector;

type
  TDifficultyTier = 0..9;
  TShipPopulationCounts = array[0..13] of Integer; // @size $38
  PShipPopulationCounts = ^TShipPopulationCounts;

  // Applying overrides raises for a missing form; a missing control is logged.
  // Text/image overrides also require a compatible control class.

  TInterfaceStateOverride = class;
  TInterfaceTextOverride = class;
  TInterfaceImageOverride = class;
  TInterfacePosOverride = class;
  TInterfaceSizeOverride = class;
  TStoredItem = class;
  TGalaxy = class;
  TConstellation = class;
  THole = class;
  TCustomSystemInfo = class;
  TStar = class;

  TInterfaceStateOverride = class(TObjectEx) // @size 0x10
  public
    FormName: WideString; // @offset 0x04
    ControlPath: WideString; // @offset 0x08
    State: Byte; // @offset 0x0C  0 inactive, 1 active; graph buttons also accept 2 disabled, 3 enabled.
    OriginalState: Byte; // @offset 0x0D

    constructor Create; // @addr 0x7D0C5C
    destructor Destroy; override; // @addr 0x7D0CA0 @note "Restores the original control value when the control still exists."
    procedure Initialize(FormName, ControlPath: WideString; State: Byte); // @addr 0x7D0D3C @note "Captures the original value before applying the override."
    procedure SetState(State: Byte); // @addr 0x7D0F90
    function GetState: Byte; // @addr 0x7D116C
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D1188
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7D11D0 @note "Loads both values and immediately reapplies the override."
    procedure Reapply; // @addr 0x7D129C
  end;

  TInterfaceTextOverride = class(TObjectEx) // @size 0x14
  public
    FormName: WideString; // @offset 0x04
    ControlPath: WideString; // @offset 0x08
    Text: WideString; // @offset 0x0C
    OriginalText: WideString; // @offset 0x10

    constructor Create; // @addr 0x7D1464
    destructor Destroy; override; // @addr 0x7D14A8 @note "Restores the original control value when the control still exists."
    procedure Initialize(FormName, ControlPath: WideString; Text: WideString); // @addr 0x7D15CC @note "Captures the original value before applying the override."
    procedure SetText(Text: WideString); // @addr 0x7D188C
    function GetText: WideString; // @addr 0x7D1AD8
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D1AF8
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7D1B40 @note "Loads both values and immediately reapplies the override."
    procedure Reapply; // @addr 0x7D1BF4
  end;

  TInterfaceImageOverride = class(TObjectEx) // @size 0x14
  public
    FormName: WideString; // @offset 0x04
    ControlPath: WideString; // @offset 0x08
    ImagePath: WideString; // @offset 0x0C
    OriginalImagePath: WideString; // @offset 0x10

    constructor Create; // @addr 0x7D1E20
    destructor Destroy; override; // @addr 0x7D1E64 @note "Restores the original value when the control still exists; an empty original style is not restored."
    procedure Initialize(FormName, ControlPath: WideString; ImagePath: WideString); // @addr 0x7D20F4 @note "Captures the original value before applying the override."
    procedure SetImagePath(ImagePath: WideString); // @addr 0x7D25C8 @note "Also accepts Style:name for any control. Do not change between image and style modes: they share one original-value slot."
    function GetImagePath: WideString; // @addr 0x7D29A0
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D29C0
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7D2A08 @note "Loads both values and immediately reapplies the override."
    procedure Reapply; // @addr 0x7D2ABC
  end;

  TInterfacePosOverride = class(TObjectEx) // @size 0x30
  public
    FormName: WideString; // @offset 0x04
    ControlPath: WideString; // @offset 0x08
    Position: TPoint; // @offset 0x0C
    Depth: Double; // @offset 0x18
    OriginalPosition: TPoint; // @offset 0x20
    OriginalDepth: Double; // @offset 0x28

    constructor Create; // @addr 0x7D2E74
    destructor Destroy; override; // @addr 0x7D2EB8 @note "Restores the original control value when the control still exists."
    procedure Initialize(FormName, ControlPath: WideString; DeltaX, DeltaY, DeltaDepth: Integer); // @addr 0x7D2F44 @note "Captures the original value before applying the override."
    procedure SetPosition(DeltaX, DeltaY, DeltaDepth: Integer); // @addr 0x7D31A0 @note "Offsets are relative to the captured original position and depth, not the current control values."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D3394
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7D341C @note "Loads both values and immediately reapplies the override."
    procedure Reapply; // @addr 0x7D34F4
  end;

  TInterfaceSizeOverride = class(TObjectEx) // @size 0x1C
  public
    FormName: WideString; // @offset 0x04
    ControlPath: WideString; // @offset 0x08
    Size: TPoint; // @offset 0x0C
    OriginalSize: TPoint; // @offset 0x14

    constructor Create; // @addr 0x7D36B0
    destructor Destroy; override; // @addr 0x7D36F4 @note "Restores the original control value when the control still exists."
    procedure Initialize(FormName, ControlPath: WideString; Width, Height: Integer); // @addr 0x7D3770 @note "Captures the original value before applying the override."
    procedure SetSize(Width, Height: Integer); // @addr 0x7D39B0 @note "Nonpositive dimensions restore the corresponding original dimension."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D3B9C
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7D3C00 @note "Loads both values and immediately reapplies the override."
    procedure Reapply; // @addr 0x7D3CBC
  end;

  TMovingDropItemEntry = record // @size 0x14
    Payload: TObject; // @offset 0x00  TItem, or a spawned TShip during special handling; may be nil.
    Destination: TPointF; // @offset 0x04
    SourceShipId: Integer; // @offset 0x0C  Zero for asteroid mineral drops.
    InsertedIntoStar: Boolean; // @offset 0x10  Payload is registered in Items or, after transformation, Ships.
    DeployTranclucator: Byte; // @offset 0x11 Nonzero releases a stored tranclucator ship instead of dropping its artefact; serialized as Boolean.
  end;
  PMovingDropItemEntry = ^TMovingDropItemEntry;

  TStarCombatEvent = packed record // @size 0x14
    StepIndex: Integer; // @offset 0x00
    CombatGroup: Integer; // @offset 0x04  Zero until connected attacks are grouped for film timing.
    Attacker: TObject; // @offset 0x08
    Target: TObject; // @offset 0x0C  Ship, item, asteroid or missile.
    Weapon: TObject; // @offset 0x10
  end;
  PStarCombatEvent = ^TStarCombatEvent;

  TStarDistanceEntry = packed record // @size 0x08
    Distance: Integer; // @offset 0x00  Rounded Euclidean distance in parsecs, not squared.
    Star: TStar; // @offset 0x04
  end;
  PStarDistanceEntry = ^TStarDistanceEntry;

  TJumpGateEntry = record // @size 0x14
    Gate: TObjectSE; // @offset 0x00  Retained TGateSE reference.
    UsedThisTurn: Boolean; // @offset 0x04
    GateFilmId: Cardinal; // @offset 0x08  Encoded TEFilmObj pointer, not a serialized object ordinal.
    Effect: TObjectSE; // @offset 0x0C  Optional retained TGateEffectSE reference.
    EffectFilmId: Cardinal; // @offset 0x10  Encoded TEFilmObj pointer.
  end;
  PJumpGateEntry = ^TJumpGateEntry;

  TSpaceBackgroundEntry = record // @size 0x60
    ImageIndex: Integer; // @offset 0x00
    OrbitCenter: TVector3D; // @offset $08
    Position: TVector3D; // @offset $20
    Unknown38: TVector3D; // @offset $38 Preserved by fStarMap; purpose unresolved.
    OrbitStepDegrees: Double; // @offset $50
    FrameIndex: Integer; // @offset $58
  end;

  TConstellationBoundaryRaySample = record // @size 0x18
    Position: TPointF; // @offset 0x00
    Direction: TPointF; // @offset 0x08
    Angle: Single; // @offset 0x10  Radians.
    GrowthStopped: Boolean; // @offset 0x14
  end;
  PConstellationBoundaryRaySample = ^TConstellationBoundaryRaySample;

  TMapLineSegment = packed record // @size 0x1C
    StartPoint: TPointF; // @offset 0x00
    EndPoint: TPointF; // @offset 0x08
  end;
  PMapLineSegment = ^TMapLineSegment;

  TConstellationStarLink = record // @size 0x1C
    StartPoint: TPointF; // @offset 0x00
    EndPoint: TPointF; // @offset 0x08
    StartStarIndex: Integer; // @offset 0x10  One-based ConstellationGraphIndex.
    EndStarIndex: Integer; // @offset 0x14
    TraversalMark: Boolean; // @offset 0x18
  end;
  PConstellationStarLink = ^TConstellationStarLink;

  TStoredItem = class(TObjectEx) // @size 0x0C
  public
    Name: WideString; // @offset 0x04
    Item: TObject; // @offset 0x08  Owned; clear before transferring the item elsewhere.

    constructor CreateEmpty; // @addr 0x7D3E68
    constructor Create(Name: WideString; Item: TObject); // @addr 0x7D3EBC
    destructor Destroy; override; // @addr 0x7D3F4C
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7D3F9C @note "Requires a non-nil Item."
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x7D3FD8 @note "Creates the owned item; overwrites a previous Item without freeing it."
  end;

  TGalaxy = class(TObjectEx) // @size 0x1DC
  public
    NextConstellationId: Cardinal; // @offset 0x04
    NextStarId: Cardinal; // @offset 0x08
    NextHoleId: Cardinal; // @offset 0x0C
    NextPlanetId: Cardinal; // @offset 0x10
    NextSputnikId: Cardinal; // @offset 0x14
    NextAsteroidId: Cardinal; // @offset 0x18
    NextShipId: Cardinal; // @offset 0x1C
    NextItemId: Cardinal; // @offset 0x20
    NextMissileId: Cardinal; // @offset 0x24
    PlayerRangerIndex: Integer; // @offset 0x28  Zero-based index into Rangers; -1 when no player is registered.
    Stars: TObjectList; // @offset 0x2C  Owns TStar entries.
    Holes: TObjectList; // @offset 0x30  Owns THole entries.
    StoredItems: TObjectList; // @offset 0x34  Owns TStoredItem entries, addressed by name by scripts.
    Planets: TList; // @offset 0x38  Borrowed TPlanet index; the stars own the planets.
    Rangers: TList; // @offset 0x3C  Borrowed TRanger roster, including the player.
    PirateCount: Integer; // @offset 0x40  Independent pirates; excludes Pirate Clan ships.
    PirateClanCount: Integer; // @offset 0x44
    TransportCount: Integer; // @offset 0x48
    CurrentTurn: Integer; // @offset 0x4C
    DifficultyLevels: TGalaxyDifficultyLevels; // @offset 0x50
    GenerationSeed: Cardinal; // @offset 0x58  Also the XOR key for stored cheat points.
    RandomState: Cardinal; // @offset 0x5C
    AverageRangerCapital: Integer; // @offset 0x60
    MaxRangerWealth: Integer; // @offset 0x64
    AverageRangerStrength: Single; // @offset 0x68
    BestRangerStrength: Single; // @offset 0x6C  May include independent pirates after Coalition defeat.
    StrongestRanger: TObject; // @offset 0x70  Can differ from BestRangerStrength after Coalition defeat.
    WealthiestRanger: TObject; // @offset 0x74
    EminentCareerShips: array[TRangerCareer] of TObject; // @offset 0x78  Trader, pirate, warrior.
    ShipTypeCounts: TShipPopulationCounts; // @offset 0x84  Cached counts indexed by ship type, 0..13.
    NextPlanetNewsId: Cardinal; // @offset 0xBC
    PlanetNews: TList; // @offset 0xC0  Owns PPlanetNewsEntry records.
    CustomWeaponTypes: TList; // @offset 0xC4  Owns PWeaponInfo records.
    KellerTargetStar: TStar; // @offset 0xC8
    KellerMissionState: Integer; // @offset 0xCC
    ChecksumScalarD0: Single; // @offset $D0 Read as Single by the dormant checksum; gameplay meaning unresolved.
    DominatorResearch: array[0..2] of TDominatorResearchEntry; // @offset 0xD4  TDominatorSeries order.
    ChecksumScalarEC: Single; // @offset $EC Read as Single by the dormant checksum; gameplay meaning unresolved.
    TechLevel: Byte; // @offset 0xF0
    WarDeltaWin: array[0..2] of Integer; // @offset 0xF4  Script.DeltaWin faction indices.
    RangerSpawnQuotas: array[oiMaloc..oiGaal] of Integer; // @offset 0x100  Pilot-race indices; may be negative.
    TerronWeaponLockTurn: Integer; // @offset 0x114
    TerronGrowLockTurn: Integer; // @offset 0x118
    TerronLandingLockTurn: Integer; // @offset 0x11C
    TerronToStarTurn: Integer; // @offset 0x120
    KellerLeaveTurn: Integer; // @offset 0x124
    KellerResearchTargetStarId: Cardinal; // @offset 0x128
    BlazerLandingPlanetId: Cardinal; // @offset 0x12C
    BlazerSelfDestructTurn: Integer; // @offset 0x130
    TerronSeriesResolvedTurn: Integer; // @offset 0x134
    KellerSeriesResolvedTurn: Integer; // @offset 0x138
    BlazerSeriesResolvedTurn: Integer; // @offset 0x13C
    PirateWinTurn: Integer; // @offset 0x140  Zero is treated as unresolved by score and Ranger Center dialogue code, even if PirateWinType is nonzero.
    PirateWinType: Integer; // @offset 0x144  Script.PirateWin: 0 initially, endings 1..5. Ending 3 blocks clan attacks/captures, not all pirate-planet production.
    CoalitionDefeatedTurn: Integer; // @offset 0x148
    GraphDominatorSurfacesEnabled: Boolean; // @offset 0x14C
    SpaceEffectKind: Byte; // @offset $14D Selects space-image template kind 10 + value for captain health effect 2.
    Scripts: TList; // @offset 0x150  Owns live TScript instances.
    LiberationGroups: TList; // @offset 0x154  Owns TGroup instances.
    JumpGates: TList; // @offset 0x158  Owns PJumpGateEntry records and their retained graphics.
    ShipsInTransit: TList; // @offset 0x15C  Borrowed TShip entries awaiting transfer between stars.
    ConstellationCount: Integer; // @offset 0x160
    Constellations: TObjectList; // @offset 0x164  Owns TConstellation entries.
    ConstellationOutlineJunctions: TList; // @offset 0x168  Owned point records shared by generated sector borders.
    SpaceBackgroundEntries: array of TSpaceBackgroundEntry; // @offset 0x16C
    SaveCount: Integer; // @offset 0x170
    LoadCount: Integer; // @offset 0x174
    PendingEquipmentPurchasePrice: Integer; // @offset $178 Shop quote after any hull trade-in; included by the dormant checksum.
    IronWill: Boolean; // @offset 0x17C
    DominatorModLevel: Byte; // @offset 0x17D
    TechnicModEnabled: Byte; // @offset 0x17E
    AmmoModEnabled: Byte; // @offset 0x17F
    GodModEnabled: Byte; // @offset 0x180
    UltraScanModEnabled: Byte; // @offset 0x181
    StasisModEnabled: Byte; // @offset 0x182
    CampaignFlag183: Byte; // @offset $183 Reset on campaign creation; other meaning unresolved.
    FinalizationNameEncoded: WideString; // @offset 0x184
    CustomRules: TGalaxyCustomRules; // @offset 0x188
    NextSpecialStationServiceTurn: Integer; // @offset 0x1B0
    GalaxyEvents: TObjectList; // @offset 0x1B4  Owns TGalaxyEvent entries.
    InterfaceStateOverrides: TObjectList; // @offset 0x1B8  Owns TInterfaceStateOverride entries.
    InterfaceTextOverrides: TObjectList; // @offset 0x1BC  Owns TInterfaceTextOverride entries.
    InterfaceImageOverrides: TObjectList; // @offset 0x1C0  Owns TInterfaceImageOverride entries.
    InterfacePositionOverrides: TObjectList; // @offset 0x1C4  Owns TInterfacePosOverride entries.
    InterfaceSizeOverrides: TObjectList; // @offset 0x1C8  Owns TInterfaceSizeOverride entries.
    LoadedShips: TList; // @offset 0x1CC  Borrowed TShip queue for rebuilding caches after deserialization.
    ScoreScreenDismissed: Byte; // @offset 0x1D0  Stops the score-screen wait in TStar.NextDay; cleared after the wait.
    Destroying: Boolean; // @offset 0x1D1  Suppresses UI and gameplay side effects during teardown.
    GenerationMachineHash: Cardinal; // @offset 0x1D4
    SpecialSimulationMode: Byte; // @offset 0x1D8  Nonzero skips CompleteDay and makes RefreshTechLevel return eight; full mode semantics unresolved.
    CheatsDisabled: Boolean; // @offset 0x1D9

    constructor Create; // @addr 0x79C8CC
    destructor Destroy; override; // @addr 0x79D14C
    procedure AssignTextQuestsToPlanets; // @addr 0x7BADE8 @note "Uses quest target-owner filters; leaves planets with an existing quest unchanged."
    procedure RunConfigOnStartHandlers; // @addr 0x7A3960
    procedure RunConfigOnLoadHandlers; // @addr 0x7A3A2C
    procedure RunConfigOnSaveHandlers; // @addr 0x7A3AF8
    procedure InitializeCampaignState; // @addr 0x79D768
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x79D8D8 @note "Increments SaveCount and restores temporary shop stock before serialization."
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x79EE00
    procedure SaveEditableState; // @addr 0x7A2054 @note "Replaces the shared editable-save block, including player, holes and stars. Requires a player."
    procedure ApplyEditableState; // @addr 0x7A2AEC @note "Only runs when FinalizationNameEncoded is empty; consumes and clears the shared editable-save block. Requires a player."
    procedure GenerateGalaxyLayout(PlayerRace: TOwnerId); // @addr 0x7B36A8
    function FindConstellationIndexForStar(Star: TStar): Integer; // @addr 0x7B2954 @note "Uses polygon containment, not Star.Constellation; returns -1 when no polygon contains the star."
    procedure InitializeConstellationDistanceTiers; // @addr 0x7B29C0 @note "Requires a player/home planet and generated outlines. Boss sectors are forced to tier three."
    procedure HideSpecialConstellation; // @addr 0x7B4E44 @note "Requires constellation ID 20 and generated compatible outlines. Merges its visible outline into a neighbor and retains backups for RestoreHiddenForm."
    procedure BuildConstellationOutlineJunctions; // @addr 0x7B2B4C
    function ShouldKeepConstellationOutlineVertex(Point: TPointF): Boolean; // @addr 0x7B2F34
    procedure SimplifyConstellationOutline(ConstellationIndex: Integer); // @addr 0x7B306C
    function BuildConstellationStarGraphs: Boolean; // @addr 0x7B32B0 @note "Attempts every constellation; false means at least one graph is disconnected."
    procedure BuildConstellationPolygonsAndAdjacency(WorkingPolygon: TPolygon2D); // @addr 0x7B330C @note "Requires at least eight constellations."
    function CountVisibleConstellationsWithBoundaryPoints(FirstPoint, SecondPoint: TPointF): Integer; // @addr 0x7B8200
    procedure ShowLocalizedWarning(TextKey: WideString); // @addr 0x7D0BF4 @note "Adds a kind-five player notification using localized text."
    procedure ReapplyInterfaceOverrides; // @addr 0x7A3BC4
    procedure BindScriptImports; // @addr 0x7A3CF4
    procedure RefreshAllShipDerivedState; // @addr 0x7A5504
    procedure RebuildStarDistances; // @addr 0x7A54B4 @note "Refreshes every star's cache; called during generation and loading, not by Script.CoordX/CoordY."
    procedure CompleteDay(UnusedRecordFilm: Boolean); // @addr 0x7A463C
    procedure NextDay; // @addr 0x7A3D3C @note "Processes off-screen stars; the player's star is simulated separately."
    procedure ProcessStationSpawning; // @addr 0x7BDE78
    procedure ReplenishStationType(StationType: TStationType); // @addr 0x7BDF64
    function TryCreateLiberationGroup: Boolean; // @addr 0x7BFA1C @note "Returns BuildLiberationOrders on accepted groups; false for early rejection or disbanding."
    function TryDispatchMilitaryBaseToEnemyStar: Boolean; // @addr 0x7C00DC
    function SelectStarForLiberationAttack(Origin: TStar; FriendlyFaction: TStarFaction): TStar; // @addr 0x7BBBB8 @note "Nil Origin omits the origin-distance penalty. Searches active Galaxy; advances Self.RandomState."
    function FindMilitaryBaseInTransit: Pointer; // @addr 0x7C077C @note "Searches active Galaxy; requires an assigned destination different from the current normal-space star."
    function HasMilitaryBaseAssignedToStar(Star: TStar): Boolean; // @addr 0x7C0854 @note "Searches active Galaxy; includes a base already at its assigned destination."
    function HasLiberationGroupTargetingStar(Star: TStar): Boolean; // @addr 0x7C0914 @note "Tests the fourth order target of each liberation group, unlike TStar.HasLiberationGroupOrder."
    procedure CancelEnemyJumpsToStar(Star: TStar); // @addr 0x7BBA6C @note "Cancels normal-space Dominator and hostile-pirate jumps from other stars, plus assigned Dominion relocations."
    procedure ProcessCoalitionDefeat; // @addr 0x7C0FD0 @note "Can complete pirate ending five, clear eminent ranger titles and publish defeat news."
    procedure ApplyWingmanLeadershipPenalty; // @addr 0x7C0E6C
    procedure TransferShipsInTransit; // @addr 0x7A531C

    function IdToConstellation(Id: Cardinal): TConstellation; // @addr 0x7A5594 @note "Zero returns nil; an unknown nonzero ID raises."
    function IdToStar(Id: Cardinal): TStar; // @addr 0x7A5658 @note "Zero returns nil; an unknown nonzero ID raises."
    function IdToHole(Id: Cardinal): THole; // @addr 0x7A5750 @note "Zero returns nil; an unknown nonzero ID raises."
    function IdToPlanet(Id: Cardinal; RaiseIfMissing: Boolean = True): Pointer; // @addr 0x7A580C @note "Zero always returns nil."
    function IdToShip(Id: Cardinal; RaiseIfMissing: Boolean): Pointer; // @addr 0x7A5968 @note "Zero always returns nil. Includes docked ships and stored Tranclucators."
    function IdToItem(Id: Cardinal; RaiseIfMissing: Boolean): Pointer; // @addr 0x7A5D64 @note "Zero always returns nil. Includes inventories, shops, storage and moving drops."
    function IdToAsteroid(Id: Cardinal): Pointer; // @addr 0x7A63A8 @note "Returns nil when absent."
    function IdToMissile(Id: Cardinal): Pointer; // @addr 0x7A6450 @note "Returns nil when absent."
    function ContainsShipReference(Ship: Pointer): Boolean; // @addr 0x7A64F8
    function ContainsPlanetReference(Planet: Pointer): Boolean; // @addr 0x7A6694
    function FindHoleInStarByKind(Star: TStar; HoleKind: Integer): THole; // @addr 0x7A689C @note "Accepts either endpoint star; returns nil when absent."
    function CreateJumpGate(WithEffect: Boolean): PJumpGateEntry; // @addr 0x7A67BC @note "Registers an owned gate descriptor; returned storage is borrowed until ClearJumpGates."
    procedure ClearJumpGates; // @addr 0x7A6728
    procedure ReleaseItemGraphics; // @addr 0x7A6914 @note "Visits loose items and ship equipment/artifacts; excludes shop stock and stored items."
    procedure GenerateSpaceBackground(BackgroundIndex: Integer); // @addr 0x7A6AE4 @note "Replaces SpaceBackgroundEntries. Requires PlayerStar, a nonempty star list and differing minimum/maximum map diameters."
    procedure EnableDominatorSurfaces; // @addr 0x7A79B0
    procedure DisableDominatorSurfaces; // @addr 0x7A7AB4

    procedure XorProtectedState(Seed: Integer); // @addr 0x7A7E84 @note "Includes the active text quest; applying the same seed twice restores the state."
    procedure ObfuscateProtectedState; // @addr 0x7A8D80 @note "Already-obfuscated state is left unchanged."
    procedure RestoreProtectedState; // @addr 0x7A8DDC
    function ComputeIntegrityChecksum(Mode: Integer): Cardinal; // @addr 0x7A9008 @note "An unconditional jump disables the checksum body; always returns zero in this binary."
    procedure PrimeIntegrityChecksum(StatusCode: Integer); // @addr 0x7A9F40
    procedure CheckIntegrityChecksum(ErrorCode: Integer); // @addr 0x7AA02C @note "A matching checksum clears the integrity status."
    procedure PrimeIntegrityChecksum1(StatusCode: Integer); // @addr 0x7A9F8C
    procedure PrimeIntegrityChecksum2(StatusCode: Integer); // @addr 0x7A9FDC
    procedure CheckIntegrityChecksumAndSetStatus(StatusCode: Integer); // @addr 0x7AA0D0 @note "Channel zero; unlike CheckIntegrityChecksum, a matching checksum stores StatusCode rather than zero."
    procedure CheckIntegrityChecksum1(ErrorCode: Integer); // @addr 0x7AA174
    procedure CheckIntegrityChecksum2(ErrorCode: Integer); // @addr 0x7AA218
    procedure ClearIntegrityStatus; // @addr 0x7AA2BC
    procedure AppendIntegritySnapshot; // @addr 0x7AA2E4 @note "An unconditional jump disables the snapshot body; no-op in this binary."

    function GetStoredItem(Name: WideString; Remove: Boolean): TObject; // @addr 0x7D4364 @note "Returns nil when absent. Remove detaches the item and frees its named entry, transferring ownership to the caller."
    procedure StoreItem(Name: WideString; Item: TObject); // @addr 0x7D4060 @note "Takes ownership. Replacing a name frees the previously stored item; detach Item from its old container first."

    function CanRecordAchievements: Boolean; // @addr $7D4A08 Checks special simulation, cheat points and all protected integrity flags.
    function GetCheatPoints: Integer; // @addr 0x7AAC60
    procedure SetCheatPoints(Value: Integer); // @addr 0x7AAC88
    function HasVisibleScoreModFlags: Boolean; // @addr 0x7AABF0
    function CountEligibleRangers: Integer; // @addr 0x7BA554
    procedure RefreshRangerWealthStats; // @addr 0x7BA5AC
    procedure RefreshRangerStrengthStats; // @addr 0x7BA790
    procedure RefreshRangerRatingPlaces; // @addr 0x7BA96C @note "Assigns one-based positions by descending TotalExperience, including excluded rangers; leaves the Rangers list order unchanged."
    function FindStrongestRanger: Pointer; // @addr 0x7BAB14 @note "Ignores ExcludedFromRating rangers; returns nil if none has positive strength."
    function FindWealthiestRanger: Pointer; // @addr 0x7BAB90 @note "Ignores ExcludedFromRating rangers; returns nil if none has positive wealth."
    function CountFactionStars(Faction: TStarFaction): Integer; // @addr 0x7BAC10 @note "Excludes stars with a custom faction."
    function GetFactionControlPercent(Faction: TStarFaction): TPercent; // @addr 0x7BAC78
    function GetDominatorSeriesControlShare(Series: TDominatorSeries): Single; // @addr 0x7BACBC @note "Active Galaxy only. Fraction of Dominator systems in Series, multiplied by the number of unresolved series; not a percentage."
    function CountStarsInBattle: Integer; // @addr 0x7BAD94
    function TurnToDateTime(Turn: Integer): Double; // @addr 0x7BB330 @note "Delphi TDateTime; -1 selects CurrentTurn."
    function FormatTurnDate(Turn: Integer): WideString; // @addr 0x7BB370 @note "-1 selects CurrentTurn."
    procedure AddPlanetNews(NewsType: Byte; Text: WideString); // @addr 0x7BB598 @note "Rejects empty text; identical existing text suppresses insertion regardless of NewsType."
    procedure AddPlanetNewsWithPlayerBubble(NewsType: Byte; Text: WideString); // @addr 0x7BB524 @note "Adds a player bubble only after turn 300; news insertion still uses duplicate-text suppression."
    function CountPlanetNewsByType(NewsType: Byte): Integer; // @addr 0x7BB6E8
    procedure PrunePlanetNews; // @addr 0x7BB748 @note "Removes entries more than 30 days old."
    procedure UpdateConstellationMilitaryStats; // @addr 0x7BB7FC
    procedure CreateDominatorSpawnProxy(Star: TStar); // @addr 0x7BB7BC @note "Replaces the global spawn-planet pointer without freeing its previous value; does not register the proxy in star or galaxy planet lists."
    function RefreshTechLevel: Byte; // @addr 0x7BB904 @note "Updates TechLevel but normally returns zero. The special mode at +0x1D8 returns 8 without updating it."
    function HasPlayerQuestHistory(QuestType: TQuestType; QuestNumber: Word): Boolean; // @addr 0x7BB2C8
    procedure ComputeGlobalGoodsPriceBands; // @addr 0x7BBD50
    function ScaleGoodsPriceByGalaxyAge(BaseValue: Integer): Integer; // @addr 0x7BBFE8
    function ScaleGoodsStockByGalaxyAge(BaseValue: Integer): Integer; // @addr 0x7BC054
    function GetGoodsPricePercent(GoodsType: Byte; Price: Integer): TPercent; // @addr 0x7BBF78 @note "Maps the global minimum/maximum price band to 0..100 with clamping."
    function ScaleIntByTechLevel(AtLevelTwo, AtLevelSeven: Integer): Integer; // @addr 0x7BC0C0 @note "Clamps TechLevel to 2..7, linearly interpolates the endpoints, then rounds."
    function InterpolateSingleByTechLevel(AtLevelTwo, AtLevelSeven: Single): Single; // @addr 0x7BC11C
    function GetOrCreateCustomWeaponInfo(Name: WideString): PWeaponInfo; // @addr $7D4544 Inserts a new custom template in the case-insensitive sorted pool.
    function RequireCustomWeaponInfo(Name: WideString): PWeaponInfo; // @addr $7D4734 Binary search of CustomWeaponTypes; raises if absent.
    function SelectWeaponInfo(Seed: Cardinal; AvailabilityMask: TWeaponAvailabilityMask; MaximumTechLevel, MinimumTechLevel: Byte): PWeaponInfo; // @addr 0x7BC1D8 @ida "PWeaponInfo __userpurge $name@<eax>(TGalaxy *Self@<eax>, unsigned int Seed@<edx>, unsigned __int16 AvailabilityMask@<cx>, unsigned __int8 MaximumTechLevel@<^4>, unsigned __int8 MinimumTechLevel@<^0>);" @note "Borrowed template. Uses the closest eligible technology when the interval has no match; falls back to the first built-in template when no availability matches."
    function SelectMicroModule(MinimumPriority, MaximumPriority: Byte; Seed: Cardinal; Context: TObject): Integer; // @addr 0x7BC3B0 @note "Zero-based index; Context may be a planet or ship, or nil. Relaxes the priority interval after repeated misses. No termination guarantee when every template fails the context filter."
    function SelectMicroModuleForEquipment(MinimumPriority, MaximumPriority: Byte; Seed: Cardinal; Context: TObject; Item: Pointer): Integer; // @addr 0x7BC7B8 @note "Zero-based index. The final attempt-limit fallback can return an incompatible module; callers must check CanInstallMicroModule. Context rejection can bypass the attempt-limit check."
    function SelectHullSeries(OwnerId: TOwnerId; HullType, MinimumRarity, MaximumRarity: Byte): Integer; // @addr 0x7BCC34 @note "Zero-based series index or -1; advances Self.RandomState."
    function ResolveMoneySizeTag(Tag: WideString; Owner: TOwnerId): Integer; // @addr 0x7BD64C @note "Accepts Zero, Mini, Small, Average, Big and Huge; unknown tags raise. Uses active Galaxy for scaling."

    function GetMiniGoodsQuantity(GoodsType: Byte): Integer; // @addr 0x7BD850
    function GetSmallGoodsQuantity(GoodsType: Byte): Integer; // @addr 0x7BD894
    function GetAverageGoodsQuantity(GoodsType: Byte): Integer; // @addr 0x7BD8D0
    function GetBigGoodsQuantity(GoodsType: Byte): Integer; // @addr 0x7BD908
    function GetHugeGoodsQuantity(GoodsType: Byte): Integer; // @addr 0x7BD944
    function GetGoodsQuantityBySize(Size: Byte; GoodsType: Byte): Integer; // @addr 0x7BD980 @note "Sizes 0..5 select zero through huge; invalid sizes raise."
    function ClassifyGoodsQuantity(Quantity: Integer; GoodsType: Byte): Byte; // @addr 0x7BDAA0 @note "Zero maps to zero; otherwise chooses levels 1..5, with ties favoring the larger level."
    function GetMinimumGoodsPrice(GoodsType: Byte): Integer; // @addr 0x7BDB7C
    function GetLowGoodsPrice(GoodsType: Byte): Integer; // @addr 0x7BDBA8
    function GetAverageGoodsPrice(GoodsType: Byte): Integer; // @addr 0x7BDBF0
    function GetHighGoodsPrice(GoodsType: Byte): Integer; // @addr 0x7BDC1C
    function GetMaximumGoodsPrice(GoodsType: Byte): Integer; // @addr 0x7BDC64
    function GetGoodsPriceByLevel(Level: Byte; GoodsType: Byte): Integer; // @addr 0x7BDC90 @note "Levels 1..5 select minimum through maximum; invalid levels raise."
    function ClassifyGoodsPrice(Price: Integer; GoodsType: Byte): Byte; // @addr 0x7BDD9C @note "Zero maps to zero; otherwise chooses levels 1..5, with ties favoring the larger level."
    function HasUnresolvedDominatorSeries(Series: TDominatorSeriesSet): Boolean; // @addr 0x7BCF04 @note "True if any selected series is unresolved; false for an empty set."
    function IsDominatorSeriesUnresolved(Series: TDominatorSeries): Boolean; // @addr 0x7BCEAC @note "Invalid series values return false."
    function IsDominatorResearchComplete(Series: TDominatorSeriesSet): Boolean; // @addr 0x7BE6B4 @note "Every selected series must have at least 100 progress; the empty set returns true."
    procedure ComputeRangerSpawnQuotas; // @addr 0x7C13E0
    procedure PruneExpiredGalaxyEvents; // @addr 0x7C16E0 @note "Retains the most recent 1825 days."
    function GetCoalitionToPirateSystemRatio: Single; // @addr 0x7C1744 @note "Uses the active Galaxy, not Self; denominator is max(pirate systems - 1, 1)."

    function GetEffectiveDifficultyLevel: Integer; // @addr 0x7C1794 @note "With custom rules disabled, reads the active Galaxy difficulty array rather than Self."
    function GetDifficultyTierIndex: TDifficultyTier; // @addr 0x7C17E4 @note "Returns 0..9; tier boundaries are 6, 14, 22, and subsequent increments of eight."
    function InterpolateDifficulty(Level: Integer; AtZero, AtEight, AtSixteen, AtTwentyFour: Single): Single; // @addr 0x7C1848 @note "A negative Level selects the effective difficulty; values above 24 extrapolate."
    function ScaleDifficultyExponentially(Level: Integer; BaseValue, FactorPerEightLevels: Single): Single; // @addr 0x7C1964 @note "A negative Level selects the effective difficulty."
    function GetTurnsBetweenLiberationGroups: Integer; // @addr 0x7C1A4C
    function GetDominatorBossHullScale: Single; // @addr 0x7C19C4
    function GetDominatorKillExperienceScale: Single; // @addr 0x7C19F8
    function GetInitialDominatorControlPercent: Integer; // @addr 0x7C1AE0

    procedure ProcessDominatorResearchProgress; // @addr 0x7BE398
    function GetDominatorResearchRate(Series: TDominatorSeries): Single; // @addr 0x7BE710 @note "Percentage points per day."
    function GetDominatorResearchEfficiency(Series: TDominatorSeries): TPercent; // @addr 0x7BE78C @note "Returns 20..100 percent."
    procedure ProcessBankDebtAndDeposits; // @addr 0x7BEC1C @note "Debt pauses deposit accrual. Both states are cleared when no business centers remain."
    procedure TryAwardDepositPrize; // @addr 0x7BE89C @note "Eligible only at positive multiples of 365 accrued deposit days."
    function FindStationByTypeAndIndex(Index: Integer; StationType: TStationType): Pointer; // @addr 0x7BE7DC @note "One-based index over active Galaxy star/ship order. Uses Self's cached type count as an early gate; missing entries return nil."
    procedure ProcessRangerCenterNewYearEvent; // @addr 0x7BF428 @note "Also clears the player's deposited nodes when no ranger centers remain."
    procedure ProcessPlayerSatelliteExploration; // @addr 0x7BCF7C @note "Advances deployed probes' terrain exploration and wear; idle completed planets still incur reduced wear."
    function CountExistingSatellites: Integer; // @addr 0x7BD240 @note "Requires a player. Counts deployed/player-storage probes, loose and carried probes in active Galaxy, and Self.StoredItems; excludes shop stock."
    function IsChaoticRandomEnabled: Boolean; // @addr 0x7C1BC0 @note "When enabled, seeded helpers ignore their supplied seed."
    function ComputeScaledMiniMoney(Owner: TOwnerId): Integer; // @addr 0x7BD3CC
    function ComputeScaledSmallMoney(Owner: TOwnerId): Integer; // @addr 0x7BD44C
    function ComputeScaledAverageMoney(Owner: TOwnerId): Integer; // @addr 0x7BD4CC
    function ComputeScaledBigMoney(Owner: TOwnerId): Integer; // @addr 0x7BD54C
    function ComputeScaledHugeMoney(Owner: TOwnerId): Integer; // @addr 0x7BD5CC
    function GetDominatorAggressionLevel: Integer; // @addr 0x7C1B14
    function GetDominatorSpawnLevel: Integer; // @addr 0x7C1B4C
    function GetPirateAggressionLevel: Integer; // @addr 0x7C1B84
    function AreStationsNearStarsEnabled: Boolean; // @addr 0x7C1BF4
    function IsFullStationTargetingEnabled: Boolean; // @addr 0x7C1C28
    function IsEquipmentKnowledgeUnrestricted: Boolean; // @addr 0x7C1C5C
    function GetAsteroidModifier: Single; // @addr 0x7C1C90
    function GetStarDamageDifficultyScale: Single; // @addr 0x7C1CDC
    function AreSpecialShipsEnabled: Boolean; // @addr 0x7C1D2C
    function GetMicroModuleOfferRollThresholdPercent: Single; // @addr 0x7C1D60
    function GetNodeDropModifier: Single; // @addr 0x7C1D98
    function GetArcadeDropValueModifier: Single; // @addr 0x7C1DE4
    function GetDropValueModifier: Single; // @addr 0x7C1E30
    function GetAgriculturalPlanetWeight: Integer; // @addr 0x7C1E7C
    function GetMixedPlanetWeight: Integer; // @addr 0x7C1EDC
    function GetIndustrialPlanetWeight: Integer; // @addr 0x7C1F3C
    function IsZeroStartingExperienceEnabled: Boolean; // @addr 0x7C1F9C
    function GetExtraRangerCount: Integer; // @addr 0x7C1FD0
    function IsArcadeBattleRoyaleEnabled: Boolean; // @addr 0x7C2000
    function GetArcadeHitpointsModifier: Single; // @addr 0x7C2034
    function GetArcadeDamageModifier: Single; // @addr 0x7C2080
    function AreDominatorRacialWeaponsEnabled: Boolean; // @addr 0x7C20CC
    function GetAIJunkToleranceLevel: Integer; // @addr 0x7C2100
    function AreMaxRangeMissilesEnabled: Boolean; // @addr 0x7C2130
    function IsOldHyperspaceEnabled: Boolean; // @addr 0x7C2164
    function ArePirateNodesEnabled: Boolean; // @addr 0x7C2198
    function IsAIShoppingEnabled: Boolean; // @addr 0x7C21CC
    function IsStationShopUpdateEnabled: Boolean; // @addr 0x7C2200
    function AreDuplicateArtefactsEnabled: Boolean; // @addr 0x7C2234
    function GetHullGrowthMod: Byte; // @addr 0x7C2268
    function IsArcadeEquipmentChangeEnabled: Boolean; // @addr 0x7C2298
    function IsOldSpeedCalculationEnabled: Boolean; // @addr 0x7C22CC
    function AreOldMissileBonusesEnabled: Boolean; // @addr 0x7C2300
    procedure AssignSpecialStationService; // @addr 0x7C097C
end;

  TDominatorResearchEntry = packed record // @size 0x08
    Progress: Single; // @offset 0x00
    Material: Integer; // @offset 0x04
  end;

  TDominatorSeriesSet = set of TDominatorSeries; // @size 0x1


  TConstellation = class(TObjectEx) // @size 0x8C
  public
    Id: Cardinal; // @offset 0x04
    HomeDistanceTier: Byte; // @offset 0x08  0 home/adjacent, 1..2 successive border hops, 3 farther or a boss sector.
    Visible: Boolean; // @offset 0x09  Script.SectorVisible.
    MapCenter: TPointF; // @offset 0x0C
    OutlineGrowthStepsRemaining: Integer; // @offset 0x14
    Stars: TList; // @offset 0x18  Borrowed TStar entries.
    AdjacentConstellations: TList; // @offset 0x1C  Borrowed TConstellation entries.
    OutlineSegments: TList; // @offset 0x20  Owns PMapLineSegment entries.
    HiddenOutlineSegmentsBackup: TList; // @offset 0x24  Owns PMapLineSegment entries.
    BoundaryRaySamples: TList; // @offset 0x28  Owns PConstellationBoundaryRaySample entries.
    OutlineBounds: TRect; // @offset 0x2C
    OutlineBoundsSize: TPoint; // @offset 0x3C
    StarLinks: TList; // @offset 0x44  Owns PConstellationStarLink entries.
    ShipTypeCounts: array[0..13] of Integer; // @offset 0x48  Sum of member stars' cached population counts.
    OutlinePolygons: TPolygon2D; // @offset 0x80  Owned polygon chain.
    HiddenOutlinePolygonsBackup: TPolygon2D; // @offset 0x84  Owned polygon chain.
    SerializedValue88: Word; // @offset 0x88  Saved value; meaning unresolved.

    constructor Create; // @addr 0x7B8284
    destructor Destroy; override; // @addr 0x7B83C0
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7B84AC
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x7B8958 @note "Requires a fresh instance; saved object IDs remain unresolved."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr 0x7B8E78
    function GetName: WideString; // @addr 0x7BA27C @note "Localization key uses the current position in Galaxy.Constellations, not Id."

    procedure AddStar(Star: TStar); // @addr 0x7B91F4 @note "Also sets Star.Constellation; does not remove earlier membership."
    procedure ClearStars; // @addr 0x7B931C @note "Clears only the borrowed list; leaves Star.Constellation unchanged."
    procedure AddAdjacentConstellation(Constellation: TConstellation); // @addr 0x7B9220 @note "Suppresses duplicates; does not add the reciprocal relationship."
    procedure ClearAdjacentConstellations; // @addr 0x7B933C
    function HasAdjacentConstellation(Constellation: TConstellation): Boolean; // @addr 0x7B9D14
    function SharesOutlineSegment(Constellation: TConstellation): Boolean; // @addr 0x7B9250 @note "Self compares true; otherwise matches complete segment endpoints in either direction."

    procedure ClearStarLinks; // @addr 0x7B8F1C
    function FindNextClosestStarPair(var FirstStar, SecondStar: TStar; MinimumDistance: Integer): Integer; // @addr 0x7B9380 @note "Resumes equal-distance pairs using the input stars; zero clears both outputs and means no pair remains."
    function HasStarGraphCycle: Boolean; // @addr 0x7B95A4 @note "Changes link traversal marks; returns false without checking when Stars.Count exceeds 100."
    function IsStarGraphConnected: Boolean; // @addr 0x7B97D0 @note "Clears link traversal marks; returns false when Stars.Count exceeds 100."
    function BuildStarGraph: Boolean; // @addr 0x7B9970 @note "Replaces StarLinks; result reports connectivity."

    procedure ClearBoundaryRaySamples; // @addr 0x7B8F70
    procedure GenerateBoundaryRaySamples(Count: Integer); // @addr 0x7B8FC4 @note "Requires a positive Count."
    procedure SetOutlinePolygon(Polygon: TPolygon2D); // @addr 0x7B90E8 @note "Takes ownership and frees the previous polygon chain; do not pass the current chain."
    procedure RebuildOutlineSegments; // @addr 0x7B9128 @note "Replaces the list without freeing its old segment records."
    procedure ClearOutlineSegmentsAndBounds; // @addr 0x7B9164
    procedure ResetGeneratedMapShape; // @addr 0x7B92C4
    procedure RestoreHiddenForm; // @addr 0x7B8188
    function GetOutlineArea: Single; // @addr 0x7B935C
    procedure ExpandOutlineBounds(Point: TPointF); // @addr 0x7B9B18
    procedure RefreshOutlineBounds; // @addr 0x7B9BA4
    function ContainsPoint(Point: TPointF): Boolean; // @addr 0x7B9CC8
    function HasOutlineSegment(FirstPoint, SecondPoint: TPointF): Boolean; // @addr 0x7B9D64 @note "Endpoint matching uses a tolerance and accepts either direction."
    function AreBothPointsOnOutline(FirstPoint, SecondPoint: TPointF): Boolean; // @addr 0x7B9DE0 @note "The points may lie on different outline segments."
    function CalculateLabelPosition: TPointF; // @addr 0x7B9E84 @note "Requires an outline yielding interior samples; the sample mean need not lie inside a concave outline."
    function HasOutlineVertex(Point: TPointF): Boolean; // @addr 0x7BA04C
    function IsPointNearOutline(Point: TPointF): Boolean; // @addr 0x7BA0C4 @note "Tests a distance of at most two map units."
    procedure NormalizeOutlineSegmentOrder; // @addr 0x7BA160

    function HasDominatorPresence: Boolean; // @addr 0x7BA338 @note "Uses member stars' cached population counts."
    function HasPirateClanPresence: Boolean; // @addr 0x7BA390
    function HasBertorOfSeries(Series: TDominatorSeries): Boolean; // @addr 0x7BA43C
    function CountShipsByTypeMask(ShipTypeMask: TShipTypeMask): Integer; // @addr 0x7BA508 @note "Uses cached population counts."
  end;

  THole = class(TObjectEx) // @size 0x34
  public
    Id: Cardinal; // @offset 0x04
    Star1: TStar; // @offset 0x08
    Position1: TPointF; // @offset 0x0C  In-system coordinates, not galaxy-map coordinates.
    Star2: TStar; // @offset 0x14
    Position2: TPointF; // @offset 0x18
    CreatedTurn: Integer; // @offset 0x20
    HoleType: Integer; // @offset 0x24  1 ordinary, 2 Blazer, 4 Keller mission; other internal states exist.
    Graphic: TObjectSE; // @offset 0x28  Retained reference.
    FilmObjectId: Integer; // @offset 0x2C
    ArcadeMapName: WideString; // @offset 0x30  Also accepts SkipAB and NoEntry.

    constructor Create; // @addr 0x7AACB0
    destructor Destroy; override; // @addr 0x7AAD10
    procedure InitializeGraphic(GraphKey: WideString); // @addr 0x7AAD58 @note "Empty GraphKey chooses a seeded Hole template. Clears ArcadeMapName; replacing an existing Graphic does not release the old reference."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7AAE9C @note "Requires both endpoint stars and Graphic."
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x7AAF50 @note "Leaves endpoint IDs unresolved until ResolveLoadedReferences."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr 0x7AB0B4
    procedure SaveToBlock(Block: TBlockParEC); // @addr 0x7AB104 @note "Editable subset; writes remaining lifetime as CreatedTurn + 200 - Galaxy.CurrentTurn."
    procedure LoadFromBlock(Block: TBlockParEC); // @addr 0x7AB520 @note "Updates endpoints, positions, remaining lifetime and ArcadeMapName; preserves Id, HoleType and Graphic."
  end;
  PPlanetNewsEntry = ^TPlanetNews;

  TCustomSystemInfo = class(TObjectEx) // @size 0x18
  public
    Name: WideString; // @offset 0x04
    Icon: WideString; // @offset 0x08
    Info: WideString; // @offset 0x0C
    TypeTag: WideString; // @offset 0x10  Script lookup key.
    Distance: Integer; // @offset 0x14  Ordering position in the system-object list.

    constructor Create; // @addr 0x7AB8A4
    destructor Destroy; override; // @addr 0x7AB8E8
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x7AB91C
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7AB9D4
  end;

  TStar = class(TObject) // @size 0x114
  public
    Id: Cardinal; // @offset 0x04
    GenerationSeed: Cardinal; // @offset 0x08
    RandomState: Cardinal; // @offset 0x0C
    Name: WideString; // @offset 0x10
    Position: TPointF; // @offset 0x14
    SystemRadius: Word; // @offset 0x1C
    MapDiameter: Integer; // @offset 0x20  Cached by RefreshMapDiameterAndStats.
    Planets: TObjectList; // @offset 0x24  TPlanet entries.
    Asteroids: TObjectList; // @offset 0x28  TAsteroid entries.
    Ships: TObjectList; // @offset 0x2C  TShip entries.
    Items: TObjectList; // @offset 0x30  TItem entries.
    MovingDropItems: TList; // @offset 0x34  Owns PMovingDropItemEntry descriptors; payload ownership changes when inserted into the star.
    Missiles: TObjectList; // @offset 0x38  TMissile entries.
    SystemProcessName: WideString; // @offset 0x3C
    Status: TStarStatus; // @offset $40 Native managed-record RTTI at $4DB498.
    property ThreatLevel: Byte read Status.ThreatLevel write Status.ThreatLevel;
    property TrafficLevel: Byte read Status.TrafficLevel write Status.TrafficLevel;
    property ControlFaction: TStarFaction read Status.ControlFaction write Status.ControlFaction;
    property Battle: Byte read Status.Battle write Status.Battle;
    property DominatorSeries: TDominatorSeries read Status.DominatorSeries write Status.DominatorSeries;
    property PreviousControlFaction: TStarFaction read Status.PreviousControlFaction write Status.PreviousControlFaction;
    property FactionStrengthCacheTurn: Integer read Status.FactionStrengthCacheTurn write Status.FactionStrengthCacheTurn;
    SafeRadius: Single; // @offset 0x5C
    DamageRadius: Single; // @offset 0x60
    Reserved64: Integer; // @offset $64 Zeroed by Create; original purpose remains unresolved.
    Radius: Integer; // @offset 0x68
    Graphic: TObjectSE; // @offset 0x6C  Retained reference.
    DaysSincePlayerVisit: Integer; // @offset 0x70
    DaysSinceLastNpcShipSpawn: Integer; // @offset 0x74
    PlayerPresenceLevel: Integer; // @offset 0x78
    BackgroundImage: Integer; // @offset 0x7C  Stored as one byte in saves.
    Flag80: Byte; // @offset $80 Reset during generation; meaning unresolved.
    LastDominatorPresenceTurn: Integer; // @offset $84 Updated by UpdateControlFaction while Dominators are present; recent battles can release imprisoned rangers.
    LastPiratePresenceTurn: Integer; // @offset $88 Updated while Pirate Clan forces are present.
    LastLiberationRewardsTurn: Integer; // @offset 0x8C
    LiberationRewardsPending: Boolean; // @offset 0x90  Consumed after ProcessSystemLiberationRewards.
    StarDistances: array of TStarDistanceEntry; // @offset 0x94  Includes Self; sorted by rounded distance. Coordinate setters do not refresh this cache.
    ShipTypeCounts: array[0..13] of Integer; // @offset 0x98  AI population counts; excludes most docked and hyperspace ships.
    Constellation: TConstellation; // @offset 0xD0
    ConstellationGraphIndex: Word; // @offset 0xD4  One-based temporary index used while building StarLinks.
    NoComeKling: Boolean; // @offset 0xD8  Script.NoComeKlingToStar.
    Dominion: TObject; // @offset 0xDC  Assigned Dominion; relocation transfers this reference before physical arrival.
    MapLabel: WideString; // @offset 0xE0
    CustomSystemInfos: TObjectList; // @offset 0xE4  Owns TCustomSystemInfo entries.
    CurrentStepIndex: Integer; // @offset 0xE8
    SimulationStepCount: Integer; // @offset 0xEC  Captures MovementStepCount for this simulation.
    RecordingTurnFilm: Boolean; // @offset 0xF0
    PlayerCombatOccurred: Boolean; // @offset 0xF1
    InterruptLongTravel: Boolean; // @offset 0xF2
    KeepFilmRunning: Boolean; // @offset 0xF3
    CombatEvents: TList; // @offset 0xF4  Owns PStarCombatEvent records; object references are borrowed.
    PendingFilmObjectRemovals: TList; // @offset 0xF8  Space-engine object IDs.
    ReferencedItems: TList; // @offset 0xFC  Borrowed TItem references.
    PlayerFilmPath: TSPath; // @offset 0x100  Temporary camera path; node Heading stores the step index.
    MovementStepCount: Integer; // @offset 0x104
    MovementStepScale: Extended; // @offset 0x108

    constructor Create; // @addr 0x7ABA2C
    destructor Destroy; override; // @addr 0x7ABBC4
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x7AC8CC @note "Removes empty moving-drop descriptors; includes module-integrity checks."
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x7AD19C @note "Appends owned objects; requires a fresh instance. References are resolved separately."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr 0x7ADB3C
    procedure SaveToBlock(Block: TBlockParEC); // @addr 0x7ADCF8 @note "Editable subset of the system; excludes the player ship."
    procedure LoadFromBlock(Block: TBlockParEC); // @addr 0x7AE54C @note "Updates existing objects and can create stations, planets, items and asteroids. Moves star-link endpoints but does not rebuild distance caches."
    procedure GenerateSystemContents(TerronSystem: Boolean); // @addr 0x7ABD34
    procedure PrepareNextDay; // @addr 0x7B06F8 @note "Daily preparation without movement/combat simulation; the caller tracks whether it has already run."
    procedure NextDay(RecordFilm: Boolean); // @addr 0x7C70CC
    procedure RefreshMovementStepParameters; // @addr 0x7C41A8 @note "200 steps in the player's star, 50 elsewhere; MovementStepScale is the reciprocal."
    procedure RefreshDerivedStats; // @addr 0x7C2450
    procedure RefreshDominatorSeries; // @addr 0x7C2334 @note "Changes the series only when exactly one series has eligible local forces; includes the bosses."
    procedure RefreshMapDiameterAndStats; // @addr 0x7C4188
    function ComputeMapDiameter: Integer; // @addr 0x7C4228 @note "Uses the final planet-list entry when nonempty; otherwise SystemRadius. Does not update MapDiameter."
    procedure UpdateControlFaction; // @addr 0x7C2C18 @note "Can transfer planet ownership and emit capture news. Pirate ending 3 prevents new Pirate Clan captures."
    procedure GetControlPresence(out PlayerPartyPresent, CoalitionPresent, DominatorsPresent, PiratesPresent, CustomPresent: Boolean); // @addr 0x7C25C4 @note "Applies campaign-ending and liberation-contribution rules; not a raw ship-presence query."
    procedure ResetControlFaction; // @addr 0x7C3E1C @note "Reevaluates ownership after clearing a custom faction, resets liberation contributions and can clear NPC prison terms. No-op without a player."
    procedure RefreshShipTypeCounts; // @addr 0x7C44D0
    procedure RebuildStarDistances(Galaxy: TGalaxy); // @addr 0x7C5508
    function IsConstellationVisible: Boolean; // @addr 0x7C5068
    procedure ProcessItemScripts(TurnPhase: Integer); // @addr 0x7B1FB8
    function DropMinerals(Quantity: Integer; Position: TPointF; Seed: Cardinal): Integer; // @addr 0x7AF5EC @note "Returns the sum of the new goods' Cost, not their quantity. Nonpositive Quantity creates no drops and returns zero."
    procedure ProcessPlayerAsteroidKill(MineralValue: Integer; Position: TPointF; AsteroidId: Cardinal); // @addr 0x7AFA44 @note "Requires a player. Achievement progress is independent of eligibility for a planet's reward or complaint."
    procedure ClearTargetReferences(Target: TObject); // @addr 0x7AFE80 @note "Clears weapon, missile and queued attack references; accepts any target class. Nil is a no-op."
    procedure ClearShipReferences(Ship: Pointer); // @addr 0x7B0138 @note "Clears attack, landing and combat-event references without removing or freeing Ship. Nil is a no-op."
    procedure ClearItemReferences(Item: Pointer); // @addr 0x7B0418 @note "Clears targets, pickups, ReferencedItems and moving-drop payload references; does not remove Item from Items or free it."
    procedure ClearCombatEventWeaponReferences(Weapon: Pointer); // @addr 0x7B069C
    procedure HandleObjectLeavingStar(Obj: TObject); // @addr 0x7B0900 @note "Updates followers and targets recursively for docked ships. Does not remove the object from Ships or free it; selected pursuers may receive a jump order."
    procedure AvoidShipPathCollisions; // @addr 0x7B0E78 @note "Trims or clears planned movement paths; does not apply collision damage."
    procedure RebuildShipMovementPaths; // @addr 0x7B12E0 @note "Normal-space ships only; uses MovementStepCount."
    procedure PruneWeaponTargetsAfterTurn; // @addr 0x7AF35C
    procedure MarkConnectedCombatEvents(Events: TList; Target: TObject; Group: Integer); // @addr 0x7AF548 @note "Recursively marks unmarked events sharing an attacker or target. Events contains PStarCombatEvent; Group must be nonzero."
    procedure OpenSpaceScene(MapPanel: TPanelGI; Minimap: TObjectGI; Screen: TMessageLoopGI); // @addr 0x7B133C
    procedure RefreshSpaceObjectPositions; // @addr 0x7B1970
    procedure QueueSpaceImageLoads(PendingLoads: TList; Owner: TObjectGI); // @addr 0x7B1B8C
    procedure QueueHyperspaceShipImageLoads(PendingLoads: TList; Owner: TObjectGI); // @addr 0x7B1E70
    function GetBackgroundImagePath(out Size: Integer): WideString; // @addr 0x7B1ED8 @note "Sets Size to 2000."
    procedure TryGenerateSystemNews; // @addr 0x7C591C @note "Requires a visible peaceful system, no custom faction and an undefeated Coalition."

    function CountPlanetsByOwner(OwnerId: TOwnerId): Integer; // @addr 0x7C4290
    function CountDistinctInhabitedPlanetOwners: Integer; // @addr 0x7C42E8 @note "Counts owners 0..5 and 7; includes Dominators."
    function FindFirstInhabitedPlanet: Pointer; // @addr 0x7C4330 @note "If every planet is uninhabited, returns the last planet; nil only for an empty list."
    function SelectRandomInhabitedPlanet: Pointer; // @addr 0x7C438C @note "Returns nil when no inhabited planet exists; advances the star RNG."
    function FindFastestResearchPlanet: Pointer; // @addr 0x7C4448 @note "Excludes uninhabited planets; first entry wins equal progress rates."
    function CountEligibleRangersInSpace: Integer; // @addr 0x7C4570
    function CountShipsByTypeMask(ShipTypeMask: TShipTypeMask): Integer; // @addr 0x7C45E4 @note "Uses cached population counts."
    function CountDominatorForces(Series: TDominatorSeries; ExcludeAbsoluteOrders, OtherSeries: Boolean; out Strength: Extended): Integer; // @addr 0x7C4634 @note "Excludes bosses, scripted-standing ships and Dominators with a positive ActiveProgramAppliedTurn. Strength is an Extended output."
    function CountStandardDominatorsOfLocalSeries: Integer; // @addr 0x7C4788 @note "Counts normal-space types 1..5; excludes bosses and scripted standing."
    function CountPirateForces(ExcludeAbsoluteOrders: Boolean; out Strength: Extended; IncludeClanVariants, IncludeIndependent: Boolean): Integer; // @addr 0x7C4860 @note "Requires pirate ownership. IncludeIndependent also includes the pirate player."
    function CountCustomFactionForces(ExcludeAbsoluteOrders: Boolean; out Faction: WideString; out Strength: Extended): Integer; // @addr 0x7C49A0
    function CountOtherCustomFactionForces(ExcludeAbsoluteOrders: Boolean; out Faction: WideString; out Strength: Extended): Integer; // @addr 0x7C4A94 @note "Faction is empty when counted ships do not share one nonempty faction tag."
    function CountPirateShips(IncludeOutsideStarSpace: Boolean): Integer; // @addr 0x7C4C20 @note "Includes the pirate player; excludes scripted standing."
    function CountForcesByOwnerGroups(out Strength: Extended; IncludeCoalition, IncludeDominators, IncludePirates, IncludeCustom: Boolean): Integer; // @addr 0x7C4DEC @note "Includes local garrison ships absent from Ships, avoiding duplicate list entries."
    function CountRatedRangersByCareerMask(CareerMask: TRangerCareerSet): Byte; // @addr 0x7C4EF8 @note "Includes docked and hyperspace entries in Ships; excludes ExcludedFromRating. Byte count can wrap."
    function GetRangerNamesByCareerMask(CareerMask: TRangerCareerSet): WideString; // @addr 0x7C4F88 @ida "void __usercall $name(TStar *Self@<eax>, unsigned __int8 CareerMask@<dl>, unsigned __int16 **Result@<ecx>);" @note "Unlike CountRatedRangersByCareerMask, includes ExcludedFromRating entries."
    function GetCachedFactionStrength(FactionGroup: TStarFaction): Single; // @addr 0x7C5088 @note "Group 0 Coalition, 1 Dominators/custom, 2 pirates. Lazily refreshes all three once per active Galaxy.CurrentTurn."
    function SumBestRangerRelativeStrength(ShipTypeMask: TShipTypeMask): Single; // @addr 0x7C5474 @note "Sums StrengthInBestRanger over Ships, excluding the three bosses; no docking/hyperspace filter."
    function FindNearestStarByFaction(Faction: TStarFaction; InBattle: Boolean): TStar; // @addr 0x7C5734 @note "Starts at distance-cache index one and excludes custom factions. Requires a current distance cache."
    function GetBoundaryPointTowardStar(Star: TStar): TPointF; // @addr 0x7C57BC
    function HasLiberationGroupOrder: Boolean; // @addr 0x7C5868 @note "Searches every order target in active Galaxy.LiberationGroups."
    function HasHostilePresenceForScriptBinding: Boolean; // @addr 0x7C56BC @note "Includes any TKling, standing eight, or scripted ship with nonempty faction not beginning with SubFaction. No docking/hyperspace filter; the substring test also accepts absence."
  end;

function ShouldContinuePlayerTravel: Boolean; // @addr 0x7B247C @note "May prepare movement or start black-hole entry; false without a player."
function EstimatePlayerTravelTurns: Single; // @addr 0x7B2624 @note "Uses distance divided by Speed + 1; zero for interrupted travel or unsupported orders."
function GetLocalObjectLink(Obj: TObject; Suppress: Boolean): WideString; // @addr 0x7B27E0 @note "Object markup embeds the native pointer, not an ID. Ships/planets/loose items must be in the player's star. Suppress returns empty; otherwise supported objects require a player."

// Nested in ComputeIntegrityChecksum; caller-popped static link and accumulator at -4.

// Nested in CountForcesByOwnerGroups; caller-popped static link. Captures:
// -04 current ship, -08 Extended strength output, -0C count, -0D Coalition flag;
// +08 custom flag, +0C pirate flag, +10 Dominator flag.

// Nested in XorProtectedState; ParentFrame is the caller-popped static link.

var
  ReservedMessageCounter: Integer = 0; // @addr $87CCE0 Reset by galaxy construction; meaning unresolved.
  TurnsSinceLastShipMessage: Cardinal = 0; // @addr $87CCE4 Reset by ship messages; incremented by Galaxy.NextDay and saved with galaxy state.
  ModuleSizeIntegrityStatus: Integer = 0; // @addr $87CCE8 Startup size-check marker: positive means mismatch; nonpositive is accepted.
  ModuleCrcIntegrityStatus: Byte = 0; // @addr $87CCEC 0 unchecked, 1 accepted, 2 mismatch.
  ModuleCrcFailureValue: Integer = 0; // @addr $87CCF0 Cleared on mismatch while saving star 1; no native readers.
  Galaxy: TGalaxy; // @addr 0x88B0EC
  PlayerStar: TStar; // @addr 0x88B0F0
  PlayerDialogueRequestCount: Byte; // @addr $88B0F4 Incremented when a ship dialogue passes the shared message-delay threshold; only count <= 1 is accepted.
  WingmenPendingLeadershipPenalty: TList; // @addr 0x88B0F8  Borrowed TShip entries.

function GameTurnToDateTime(Turn: Integer): Double; // @addr 0x7B22A0
function FormatGameTurnDate(Turn: Integer): WideString; // @addr 0x7B22C4

var
  CameraSpeed: Integer = 10; // @addr 0x87CCF4 Native initial camera-step limit.
  FastCameraSpeed: Integer = 20; // @addr 0x87CCF8 Native initial camera-step limit.

implementation

uses SE_Garbage, FGInt, FGIntRSA, SE_Sputnik, aEObjInfo, fGov, fGoodsShop2, EC_Expression, ab_Ship, SE_Planet, SE_Gate, ThreadCalc, aCalc, SE_Ruins, aNormalShip, aGroup, aWarrior, aTranclucator, aRuins, aGalaxyEvent, PathClass, ParameterDeltaClass, ParameterClass, LocationClass, TextQuest, SE_Asteroid, aAsteroid, aRanger, EC_CacheBuf, fPlanetQuest, aScript, aItem, aKling, aMissile, aShip, fScore, aPirate, aEFilm, SE_Hole, SE_Process, SE_Ship2, SE_Weapon, Achievements, aPlanet, fShip2, fHangar, fEquipmentShop, aPlayer, GI_GI, GI_GAI, GI_GraphButton, GI_Label, GI_Image, GR_Sound, CrcUnit, EC_Mem, EC_Cache, Globals, fFilmFile, GR_Main, EC_Str, GlobalsV, GR_GraphBuf, Math, SysUtils, Windows;

{ @routine $79C8CC TGalaxy_Create }
constructor TGalaxy.Create;
var
  ModuleName: WideString;
  Template: TScriptTemplUnit;
  TemplateCount, I: Integer;
  DllSuffix, LibraryPrefix: WideString;
  Block: TBlockParEC;

  // @nested $79C724 CheckModuleSize
  procedure CheckModuleSize(EncodedSize: Cardinal); // @addr 0x79C724 @note "Caller-popped static link; filename at ParentFrame-4. Updates the startup integrity marker."
  var Handle: THandle; Size: Cardinal;
  begin
    Handle := FileOpen(AnsiString(ModuleName), 0);
    Size := Windows.GetFileSize(Handle, nil);
    Windows.CloseHandle(Handle);
    if 12345678 - Size <> EncodedSize then
      ModuleSizeIntegrityStatus := RandomIntRange(996345752, 2014356243)
    else if ModuleSizeIntegrityStatus <= 0 then
      ModuleSizeIntegrityStatus := RandomIntRange(-2021352435, -1235457467);
  end;

  // @nested $79C7D4 ParseCheatsDisabledFlag
  function ParseCheatsDisabledFlag(Value: WideString): Boolean; // @addr 0x79C7D4 @note "Nested in TGalaxy.Create; unused caller-popped static link. Accepts exactly Yes, yes, True, true, TRUE or 1; no trimming."
  begin
    if (Value = 'Yes') or (Value = 'yes') or (Value = 'True') or
      (Value = 'true') or (Value = 'TRUE') or (Value = '1') then
      Result := True
    else
      Result := False;
  end;

begin
  inherited Create;
  CheatsDisabled := False;
  Block := MainDataConfig.GetBlock('BV');
  if Block.CountParams('CheatsDisabled') > 0 then
    if ParseCheatsDisabledFlag(TrimWideString(Block.GetParamByPathOrMarker('CheatsDisabled'))) then CheatsDisabled := True;
  // Preserve the native string construction and encoded module-size checks.
  DllSuffix := 'll';
  DllSuffix := '.d' + DllSuffix;
  ModuleName := DecodeTextW('sotoenalm^_^aucah') + DllSuffix; // 'steam_ach'
  if GetModuleHandleW(PWideChar(ModuleName)) <> 0 then CheckModuleSize($BB554E);
  ModuleName := DecodeTextW('sotoenalm^_^aupki') + DllSuffix; // 'steam_api'
  if GetModuleHandleW(PWideChar(ModuleName)) <> 0 then CheckModuleSize($BABDA6);
  ModuleName := DecodeTextW('zoloimba') + DllSuffix; // 'zlib'
  CheckModuleSize($BB734E);
  ModuleName := DecodeTextW('MhastorhinxaGrakmae') + DllSuffix; // 'MatrixGame'
  CheckModuleSize($A4CD4E);
  ModuleName := DecodeTextW('ookogifa') + DllSuffix; // 'okgf'
  CheckModuleSize($B3F14E);
  ModuleName := DecodeTextW('xavriadeccomrie') + DllSuffix; // 'xvidcore'
  CheckModuleSize($B09064);
  LibraryPrefix := 'ib';
  LibraryPrefix := 'l' + LibraryPrefix;
  ModuleName := LibraryPrefix + DecodeTextW('osgaga-10a') + DllSuffix; // 'ogg-0'
  CheckModuleSize($BB50FF);
  ModuleName := LibraryPrefix + DecodeTextW('vrokrablius-->0') + DllSuffix; // 'vorbis-0'
  CheckModuleSize($B99523);
  ModuleName := LibraryPrefix + DecodeTextW('veohrablissufainlae') + DllSuffix; // 'vorbisfile'
  CheckModuleSize($BB8916);
  GameEndReason := gerDefault;
  PlayerRangerIndex := -1;
  for I := 0 to 8 do HangarScreen.ShipSlots[I].ShipId := 0;
  SaveCount := 0;
  LoadCount := 0;
  if not MemorySnapshotActive then GR_Main.CCInterface.Buffer.Clear;
  Randomize;
  GenerationSeed := RandomIntRange(100000, MaxInt);
  SetCheatPoints(0);
  RandomState := GenerationSeed;
  AverageRangerCapital := 3000;
  MaxRangerWealth := 3000;
  AverageRangerStrength := 1;
  BestRangerStrength := 1;
  ConstellationCount := 20;
  Constellations := TObjectList.Create;
  Stars := TObjectList.Create;
  Holes := TObjectList.Create;
  StoredItems := TObjectList.Create;
  Planets := TList.Create;
  Rangers := TList.Create;
  ShipsInTransit := TList.Create;
  Scripts := TList.Create;
  LiberationGroups := TList.Create;
  PlanetNews := TList.Create;
  CustomWeaponTypes := TList.Create;
  if PrimaryFilm <> nil then PrimaryFilm.Clear;
  if SecondaryFilm <> nil then SecondaryFilm.Clear;
  ClearPersistentPlayerMessages;
  JumpGates := TList.Create;
  NextConstellationId := 1;
  NextStarId := 1;
  NextHoleId := 1;
  NextPlanetId := 1;
  NextSputnikId := 1;
  NextAsteroidId := 1;
  NextShipId := 1;
  NextItemId := 1;
  NextMissileId := 1;
  SharedScriptVariables.CopyFrom(GlobalScriptVariables, True);
  TemplateCount := ScriptTemplates.Count;
  for I := 0 to TemplateCount - 1 do
  begin
    Template := ScriptTemplates[I];
    Template.UseCount := 0;
    Template.LastTurn := 0;
    Template.ConditionCode.LinkAll(SharedScriptVariables, False);
    Template.ConditionCode.LinkAll(ScriptFunctionScope, False);
    Template.ConditionCode.ScriptFunLinked := True;
    Template.ActiveScriptIndex := -1;
  end;
  PreviousFilmActivity := 0;
  ShownPlayerTips := 0;
  EminentCareerShips[rcTrader] := nil;
  EminentCareerShips[rcPirate] := nil;
  EminentCareerShips[rcWarrior] := nil;
  ReservedMessageCounter := 0;
  TurnsSinceLastShipMessage := 0;
  IronWill := False;
  DominatorModLevel := 0;
  TechnicModEnabled := 0;
  AmmoModEnabled := 0;
  GodModEnabled := 0;
  UltraScanModEnabled := 0;
  StasisModEnabled := 0;
  NextSpecialStationServiceTurn := 0;
  GalaxyEvents := TObjectList.Create;
  ScoreScreenDismissed := 0;
  Destroying := False;
  InterfaceStateOverrides := TObjectList.Create;
  InterfaceTextOverrides := TObjectList.Create;
  InterfaceImageOverrides := TObjectList.Create;
  InterfacePositionOverrides := TObjectList.Create;
  InterfaceSizeOverrides := TObjectList.Create;
  LoadedShips := TList.Create;
  SpecialSimulationMode := 0;
end;
{ @end $79C8CC }

{ @routine $79D14C TGalaxy_Destroy }
destructor TGalaxy.Destroy;
var
  Point: PPointF;
  I, J: Integer;
  Star: TStar;
  Planet: TPlanet;
  News: PPlanetNewsEntry;
  WeaponInfo: PWeaponInfo;
  Stored: TStoredItem;
  ResourceFailure: Boolean;
begin
  Destroying := True;
  if GR_Main.CCInterface.GetProtectedStateXorSeed <> 0 then RestoreProtectedState;
  if ConstellationOutlineJunctions <> nil then
  begin
    for I := 0 to ConstellationOutlineJunctions.Count - 1 do
    begin
      Point := ConstellationOutlineJunctions[I];
      Dispose(Point);
    end;
    ConstellationOutlineJunctions.Clear;
    ConstellationOutlineJunctions.Free;
    ConstellationOutlineJunctions := nil;
  end;
  for I := 0 to StoredItems.Count - 1 do
  begin
    Stored := TStoredItem(StoredItems[I]);
    if Stored.Item <> nil then Stored.Item.Free;
    Stored.Item := nil;
  end;
  for I := 0 to Stars.Count - 1 do
  begin
    Star := TStar(Stars[I]);
    while Star.Ships.Count > 0 do TObject(Star.Ships[0]).Free;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      while Planet.Warriors.Count > 0 do TObject(Planet.Warriors[0]).Free;
    end;
  end;
  if Scripts <> nil then
  begin
    for I := 0 to Scripts.Count - 1 do TObject(Scripts[I]).Free;
    Scripts.Free;
    Scripts := nil;
  end;
  if LiberationGroups <> nil then
  begin
    for I := 0 to LiberationGroups.Count - 1 do TObject(LiberationGroups[I]).Free;
    LiberationGroups.Free;
    LiberationGroups := nil;
  end;
  ClearTemporaryShopSlotGrid;
  Stars.Free;
  Stars := nil;
  Holes.Free;
  Holes := nil;
  StoredItems.Free;
  StoredItems := nil;
  Planets.Clear;
  Planets.Free;
  Planets := nil;
  Rangers.Clear;
  Rangers.Free;
  Rangers := nil;
  ShipsInTransit.Clear;
  ShipsInTransit.Free;
  ShipsInTransit := nil;
  Constellations.Free;
  Constellations := nil;
  // The original repeats the now-empty liberation-group cleanup.
  if LiberationGroups <> nil then
  begin
    for I := 0 to LiberationGroups.Count - 1 do TObject(LiberationGroups[I]).Free;
    LiberationGroups.Free;
    LiberationGroups := nil;
  end;
  for I := PlanetNews.Count - 1 downto 0 do
  begin
    News := PlanetNews[I];
    PlanetNews.Delete(I);
    Dispose(News);
  end;
  PlanetNews.Clear;
  PlanetNews.Free;
  PlanetNews := nil;
  ClearJumpGates;
  JumpGates.Free;
  JumpGates := nil;
  SetPlayer(nil, Self);
  PlayerStar := nil;
  if DominatorSpawnPlanet <> nil then
  begin
    DominatorSpawnPlanet.Free;
    DominatorSpawnPlanet := nil;
  end;
  ClearPersistentPlayerMessages;
  if PrimaryFilm <> nil then PrimaryFilm.Clear;
  if SecondaryFilm <> nil then SecondaryFilm.Clear;
  SpaceBackgroundEntries := nil;
  GalaxyEvents.Free;
  GalaxyEvents := nil;
  InterfaceStateOverrides.Free;
  InterfaceStateOverrides := nil;
  InterfaceTextOverrides.Free;
  InterfaceTextOverrides := nil;
  InterfaceImageOverrides.Free;
  InterfaceImageOverrides := nil;
  InterfacePositionOverrides.Free;
  InterfacePositionOverrides := nil;
  InterfaceSizeOverrides.Free;
  InterfaceSizeOverrides := nil;
  LoadedShips.Free;
  LoadedShips := nil;
  if not MemorySnapshotActive then
  begin
    ResourceFailure := GR_Main.CCInterface.GetResourceChecksumFailed;
    GR_Main.CCInterface.Reset;
    GR_Main.CCInterface.SetResourceChecksumFailed(ResourceFailure);
  end;
  Destroying := False;
  ClearPendingScriptRequests;
  if CustomWeaponTypes <> nil then
  begin
    for I := 0 to CustomWeaponTypes.Count - 1 do
    begin
      WeaponInfo := CustomWeaponTypes[I];
      Dispose(WeaponInfo);
    end;
    CustomWeaponTypes.Clear;
    CustomWeaponTypes.Free;
    CustomWeaponTypes := nil;
  end;
  inherited Destroy;
end;
{ @end $79D14C }

{ @routine $79D768 TGalaxy_InitializeCampaignState }
procedure TGalaxy.InitializeCampaignState;
var I: Byte;
begin
  CurrentTurn := 0;
  PirateCount := 0;
  TransportCount := 0;
  StarMapWeaponPanelOpen := True;
  ChecksumScalarD0 := 0;
  for I := 0 to 2 do begin
    DominatorResearch[I].Progress := 0;
    case DifficultyLevels[2] of
      0: DominatorResearch[I].Material := 200;
      1: DominatorResearch[I].Material := 100;
      2: DominatorResearch[I].Material := 70;
      3: DominatorResearch[I].Material := 30;
      else DominatorResearch[I].Material := 0;
    end;
  end;
  ChecksumScalarEC := 0;
  WarDeltaWin[1] := 0;
  WarDeltaWin[2] := 0;
  WarDeltaWin[0] := 0;
  RangerSpawnQuotas[oiMaloc] := 0;
  RangerSpawnQuotas[oiPeleng] := 0;
  RangerSpawnQuotas[oiHuman] := 0;
  RangerSpawnQuotas[oiFeyan] := 0;
  RangerSpawnQuotas[oiGaal] := 0;
  ComputeGlobalGoodsPriceBands;
  CampaignFlag183 := 0;
  GR_Main.CCInterface.SetEditableStateApplied(False);
  FinalizationNameEncoded := '';
  SpecialSimulationMode := 0;
end;
{ @end $79D768 }

{ @routine $79D8D8 TGalaxy_SaveToBuffer }
procedure TGalaxy.SaveToBuffer(Buffer: TBufEC);
var I, J, Count: Integer; Star: TStar; Planet: TPlanet; Ranger: TRanger;
  OldQuest: PPlayerOldQuest; Gate: PJumpGateEntry; Constellation: TConstellation;
  Template: TScriptTemplUnit; Script: TScript; Group: TGroup; ShopSlot: TShopSlot;
  Hole: THole; Career: TRangerCareer; News: PPlanetNewsEntry; Series, Difficulty: Byte;
  Stored: TStoredItem; WeaponInfo: PWeaponInfo; Race: TOwnerId;
begin
  if (TemporaryShopSlots <> nil) and (GetPlayer.CurrentPlanet <> TemporaryShopPlanet) and
    (GetPlayer.DockedTo <> TemporaryShopStation) then RestoreTemporaryShopStock;
  RunConfigOnSaveHandlers;
  Buffer.AddWideStringZ(SelectedMods);
  Buffer.AddIntegerValue(GenerationSeed);
  Buffer.AddDWord(RandomState);
  Buffer.AddIntegerValue(AverageRangerCapital);
  Buffer.AddIntegerValue(MaxRangerWealth);
  Buffer.AddSingle(AverageRangerStrength);
  Buffer.AddSingle(BestRangerStrength);
  Buffer.AddBoolean(GR_Main.CCInterface.GetTamperDetected);
  Buffer.AddBoolean(GR_Main.CCInterface.GetFlag0A);
  Buffer.AddIntegerValue(0);
  Buffer.AddIntegerValue(GetCheatPoints);
  Inc(SaveCount);
  Buffer.AddIntegerValue(SaveCount);
  Buffer.AddIntegerValue(LoadCount);
  Count := CustomWeaponTypes.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    WeaponInfo := CustomWeaponTypes[I];
    Buffer.AddWideStringZ(WeaponInfo.ConfigName);
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.TechLevel));
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.InventionIndex));
    Buffer.AddSingle(WeaponInfo.CostFactor);
    Buffer.AddIntegerValue(WeaponInfo.MinDamage);
    Buffer.AddIntegerValue(WeaponInfo.MaxDamage);
    Buffer.AddIntegerValue(WeaponInfo.AverageSize);
    Buffer.AddIntegerValue(WeaponInfo.AverageRange);
    Buffer.AddIntegerValue(WeaponInfo.ShotSpeedPercent);
    Buffer.AddIntegerValue(WeaponInfo.MissileRange);
    Buffer.AddIntegerValue(WeaponInfo.MissileMaxSpeed);
    Buffer.AddIntegerValue(WeaponInfo.MissileMinSpeed);
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.MissileChanceToBeHit));
    Buffer.AddDWord(Dword(WeaponInfo.DamageFlags));
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.ShotType));
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.ShotCount));
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.AttackCount));
    Buffer.AddSingle(WeaponInfo.SecondaryDamageRadius);
    Buffer.AddSingle(WeaponInfo.MiningFactor);
    for J := 1 to 8 do Buffer.AddSingle(WeaponInfo.DamageScaleByLevel[J]);
    if WeaponInfo.PrimarySE = '' then Buffer.AddBoolean(False)
    else begin
      Buffer.AddBoolean(True);
      Buffer.AddWideStringZ(WeaponInfo.PrimarySE);
    end;
    if WeaponInfo.SecondarySE = '' then Buffer.AddBoolean(False)
    else begin
      Buffer.AddBoolean(True);
      Buffer.AddWideStringZ(WeaponInfo.SecondarySE);
    end;
    if WeaponInfo.AreaSE = '' then Buffer.AddBoolean(False)
    else begin
      Buffer.AddBoolean(True);
      Buffer.AddWideStringZ(WeaponInfo.AreaSE);
    end;
    Buffer.AddIntegerValue(WeaponInfo.DefaultPalette);
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.Availability));
    Buffer.AddAnsiChar(AnsiChar(WeaponInfo.ArcadeWeaponType));
  end;
  Count := Constellations.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    Constellation.SaveToBuffer(Buffer);
  end;
  Count := Stars.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Star := TStar(Stars[I]);
    Star.SaveToBuffer(Buffer);
  end;
  Count := Holes.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Hole := THole(Holes[I]);
    Hole.SaveToBuffer(Buffer);
  end;
  Count := StoredItems.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Stored := TStoredItem(StoredItems[I]);
    Stored.SaveToBuffer(Buffer);
  end;
  Count := JumpGates.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Gate := JumpGates[I];
    Buffer.AddSingle(Gate.Gate.Position.X);
    Buffer.AddSingle(Gate.Gate.Position.Y);
    Buffer.AddAnsiChar(AnsiChar(Gate.Gate.GetAngle));
    Buffer.AddWideChar(WideChar(Gate.Gate.Size.X));
    Buffer.AddWideStringZ(Gate.Gate.GetText);
  end;
  Count := Planets.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Planet := Planets[I];
    Buffer.AddDWord(Planet.Id);
  end;
  Count := Rangers.Count;
  Buffer.AddWord(Word(Count));
  for I := 0 to Count - 1 do begin
    Ranger := Rangers[I];
    Buffer.AddDWord(Ranger.Id);
  end;
  for Race := oiMaloc to oiGaal do Buffer.AddIntegerValue(RangerSpawnQuotas[Race]);
  if KellerTargetStar = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(KellerTargetStar.Id);
  Buffer.AddIntegerValue(KellerMissionState);
  Count := 0;
  if TemporaryShopSlots <> nil then Count := TemporaryShopSlots.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    ShopSlot := TemporaryShopSlots[I];
    ShopSlot.SaveToBuffer(Buffer);
  end;
  SharedScriptVariables.SaveToBuffer(Buffer);
  Count := ScriptTemplates.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Template := ScriptTemplates[I];
    Buffer.AddWideStringZ(Template.Name);
    Buffer.AddWideChar(WideChar(Template.UseCount));
    Buffer.AddIntegerValue(Template.LastTurn);
    Buffer.AddIntegerValue(Template.ActiveScriptIndex);
  end;
  Count := Scripts.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Script := Scripts[I];
    Script.SaveState(Buffer);
  end;
  Count := LiberationGroups.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Group := LiberationGroups[I];
    Group.Save(Buffer);
  end;
  Buffer.AddAnsiChar(#0);
  Buffer.AddIntegerValue(0);
  Buffer.AddWideChar(WideChar(PirateCount));
  Buffer.AddWideChar(WideChar(PirateClanCount));
  Buffer.AddWideChar(WideChar(TransportCount));
  Buffer.AddDWord(CurrentTurn);
  for Difficulty := 0 to 7 do Buffer.AddAnsiChar(AnsiChar(DifficultyLevels[Difficulty]));
  Buffer.AddDWord(GetPlayer.Id);
  if PendingPlayerFollowTarget = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(PendingPlayerFollowTarget.Id);
  if BlazerShip = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(BlazerShip.Id);
  if KellerShip = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(KellerShip.Id);
  if TerronShip = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(TerronShip.Id);
  Buffer.AddDWord(PlayerStar.Id);
  Buffer.AddDWord(PieceCreatorTargetStarId);
  for Career := Low(TRangerCareer) to High(TRangerCareer) do begin
    if EminentCareerShips[Career] = nil then Buffer.AddDWord(0)
    else Buffer.AddDWord((EminentCareerShips[Career] as TShip).Id);
  end;
  Count := PlayerOldQuests.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    OldQuest := PlayerOldQuests[I];
    if OldQuest.Planet = nil then Buffer.AddDWord(0)
    else Buffer.AddDWord(OldQuest.Planet.Id);
    Buffer.AddAnsiChar(AnsiChar(OldQuest.QuestType));
    Buffer.AddWideChar(WideChar(OldQuest.QuestNumber));
    Buffer.AddWideStringZ(OldQuest.Description);
    Buffer.AddBoolean(OldQuest.Successful);
    Buffer.AddBoolean(OldQuest.Declined);
  end;
  Count := PlanetNews.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    News := PlanetNews[I];
    Buffer.AddDWord(News.Id);
    Buffer.AddDWord(News.Turn);
    Buffer.AddAnsiChar(AnsiChar(News.NewsType));
    Buffer.AddWideStringZ(News.Text);
  end;
  Buffer.AddDWord(ReservedMessageCounter);
  Buffer.AddDWord(TurnsSinceLastShipMessage);
  Buffer.AddSingle(ChecksumScalarD0);
  for Series := 0 to 2 do begin
    Buffer.AddSingle(DominatorResearch[Series].Progress);
    Buffer.AddDWord(DominatorResearch[Series].Material);
  end;
  Buffer.AddSingle(ChecksumScalarEC);
  Buffer.AddIntegerValue(WarDeltaWin[1]);
  Buffer.AddIntegerValue(WarDeltaWin[2]);
  Buffer.AddIntegerValue(WarDeltaWin[0]);
  Buffer.AddBuffer(GR_Main.CCInterface.Buffer);
  Buffer.AddIntegerValue(High(SpaceBackgroundEntries) + 1);
  for I := 0 to High(SpaceBackgroundEntries) do begin
    Buffer.AddIntegerValue(SpaceBackgroundEntries[I].ImageIndex);
    Buffer.AddSingle(SpaceBackgroundEntries[I].OrbitCenter.X);
    Buffer.AddSingle(SpaceBackgroundEntries[I].OrbitCenter.Y);
    Buffer.AddSingle(SpaceBackgroundEntries[I].OrbitCenter.Z);
    Buffer.AddSingle(SpaceBackgroundEntries[I].Position.X);
    Buffer.AddSingle(SpaceBackgroundEntries[I].Position.Y);
    Buffer.AddSingle(SpaceBackgroundEntries[I].Position.Z);
    Buffer.AddSingle(SpaceBackgroundEntries[I].Unknown38.X);
    Buffer.AddSingle(SpaceBackgroundEntries[I].Unknown38.Y);
    Buffer.AddSingle(SpaceBackgroundEntries[I].Unknown38.Z);
    Buffer.AddSingle(SpaceBackgroundEntries[I].OrbitStepDegrees);
    Buffer.AddIntegerValue(SpaceBackgroundEntries[I].FrameIndex);
  end;
  for I := 0 to 8 do Buffer.AddDWord(HangarScreen.ShipSlots[I].ShipId);
  Buffer.AddIntegerValue(GR_Main.CCInterface.GetValue10);
  Buffer.AddIntegerValue(GR_Main.CCInterface.GetIntegrityStatus);
  Buffer.AddIntegerValue(GR_Main.CCInterface.GetIntegrityError);
  Buffer.AddIntegerValue(GR_Main.CCInterface.GetIntegrityChecksum);
  Buffer.AddWideChar(WideChar(ShipsInTransit.Count));
  for I := 0 to ShipsInTransit.Count - 1 do Buffer.AddDWord(TShip(ShipsInTransit[I]).Id);
  Buffer.AddIntegerValue(TerronWeaponLockTurn);
  Buffer.AddIntegerValue(TerronGrowLockTurn);
  Buffer.AddIntegerValue(TerronLandingLockTurn);
  Buffer.AddIntegerValue(TerronToStarTurn);
  Buffer.AddIntegerValue(KellerLeaveTurn);
  Buffer.AddDWord(KellerResearchTargetStarId);
  Buffer.AddDWord(BlazerLandingPlanetId);
  Buffer.AddIntegerValue(BlazerSelfDestructTurn);
  Buffer.AddIntegerValue(TerronSeriesResolvedTurn);
  Buffer.AddIntegerValue(KellerSeriesResolvedTurn);
  Buffer.AddIntegerValue(BlazerSeriesResolvedTurn);
  Buffer.AddIntegerValue(PirateWinTurn);
  Buffer.AddIntegerValue(PirateWinType);
  Buffer.AddIntegerValue(CoalitionDefeatedTurn);
  Buffer.AddBoolean(GraphDominatorSurfacesEnabled);
  Buffer.AddAnsiChar(AnsiChar(SpaceEffectKind));
  Buffer.AddBoolean(IronWill);
  Buffer.AddAnsiChar(AnsiChar(DominatorModLevel));
  Buffer.AddAnsiChar(AnsiChar(TechnicModEnabled));
  Buffer.AddAnsiChar(AnsiChar(AmmoModEnabled));
  Buffer.AddAnsiChar(AnsiChar(GodModEnabled));
  Buffer.AddAnsiChar(AnsiChar(UltraScanModEnabled));
  Buffer.AddAnsiChar(AnsiChar(StasisModEnabled));
  Buffer.AddDWord(NextPlanetNewsId);
  Buffer.AddIntegerValue(NextSpecialStationServiceTurn);
  Count := GalaxyEvents.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do TGalaxyEvent(GalaxyEvents[I]).SaveToBuffer(Buffer);
  Count := InterfaceStateOverrides.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do TInterfaceStateOverride(InterfaceStateOverrides[I]).SaveToBuffer(Buffer);
  Count := InterfaceTextOverrides.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do TInterfaceTextOverride(InterfaceTextOverrides[I]).SaveToBuffer(Buffer);
  Count := InterfaceImageOverrides.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do TInterfaceImageOverride(InterfaceImageOverrides[I]).SaveToBuffer(Buffer);
  Count := InterfacePositionOverrides.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do TInterfacePosOverride(InterfacePositionOverrides[I]).SaveToBuffer(Buffer);
  Count := InterfaceSizeOverrides.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do TInterfaceSizeOverride(InterfaceSizeOverrides[I]).SaveToBuffer(Buffer);
  Buffer.AddDWord(NextShipId);
  Buffer.AddDWord(NextItemId);
  Buffer.AddDWord(GenerationMachineHash);
  Buffer.AddBoolean(GR_Main.CCInterface.GetEditableStateApplied);
  Buffer.AddWideStringZ(FinalizationNameEncoded);
  Buffer.AddBoolean(CustomRules.Enabled);
  Buffer.AddAnsiChar(AnsiChar(CustomRules.DominatorStrength));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.DominatorAggression));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.DominatorSpawn));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.PirateAggression));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.CoalitionAggression));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.AsteroidModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.SunDamageModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.ExtraInventions));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.AcrynModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.NodeDropModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.ArcadeDropValueModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.DropValueModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.AgriculturalPlanetWeight));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.MixedPlanetWeight));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.IndustrialPlanetWeight));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.ExtraRangers));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.ArcadeHitpointsModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.ArcadeDamageModifier));
  Buffer.AddAnsiChar(AnsiChar(CustomRules.AIJunkTolerance));
  Buffer.AddBoolean(CustomRules.ChaoticRandom);
  Buffer.AddBoolean(CustomRules.UnrestrictedEquipmentKnowledge);
  Buffer.AddBoolean(CustomRules.StationsNearStars);
  Buffer.AddBoolean(CustomRules.FullStationTargeting);
  Buffer.AddBoolean(CustomRules.SpecialShips);
  Buffer.AddBoolean(CustomRules.ZeroStartingExperience);
  Buffer.AddBoolean(CustomRules.ArcadeBattleRoyale);
  Buffer.AddBoolean(CustomRules.DominatorRacialWeapons);
  Buffer.AddBoolean(CustomRules.StartInCenter);
  Buffer.AddBoolean(CustomRules.MaxRangeMissiles);
  Buffer.AddBoolean(CustomRules.OldHyperspace);
  Buffer.AddBoolean(CustomRules.PirateNodes);
  Buffer.AddBoolean(CustomRules.AIUseShops);
  Buffer.AddBoolean(CustomRules.StationsUseShop);
  Buffer.AddBoolean(CustomRules.DuplicateArtefacts);
  Buffer.AddAnsiChar(AnsiChar(CustomRules.HullGrowth));
  Buffer.AddBoolean(CustomRules.ArcadeEquipmentChange);
  Buffer.AddBoolean(CustomRules.OldSpeedCalculation);
  Buffer.AddBoolean(CustomRules.OldMissileBonuses);
  Buffer.AddBoolean(False);
  Buffer.AddBoolean(False);
  Buffer.AddBoolean(False);
  Buffer.AddBoolean(False);
  Buffer.AddBoolean(False);
  if CampaignFlag183 <> 0 then SaveEditableState;
end;
{ @end $79D8D8 }

{ @routine $79EE00 TGalaxy_LoadFromBuffer }
procedure TGalaxy.LoadFromBuffer(Buffer: TBufEC);
var I, J, K, Count, TemplateIndex, ShipCount: Integer; X, Y: Single;
  Star: TStar; Planet: TPlanet; Ship: TShip; OldQuest: PPlayerOldQuest;
  Gate: PJumpGateEntry; Constellation: TConstellation; Template: TScriptTemplUnit;
  Script: TScript; Group: TGroup; ShopSlot: TShopSlot; Hole: THole; Career: TRangerCareer;
  News: PPlanetNewsEntry; Variables: TVarArrayEC; Variable, Existing: TVarEC;
  Series, Difficulty: Byte; LoadedPlanet: TPlanet; SavedRandomState: Cardinal;
  Event: TGalaxyEvent; StateOverride: TInterfaceStateOverride;
  TextOverride: TInterfaceTextOverride; ImageOverride: TInterfaceImageOverride;
  PositionOverride: TInterfacePosOverride; SizeOverride: TInterfaceSizeOverride;
  Stage: Integer; TemplateName, SavedMods: WideString; Stored: TStoredItem;
  WeaponInfo: PWeaponInfo; Crc: Cardinal; Race: TOwnerId;
  // @nested $79EDF8 CompatibilityHook
  procedure CompatibilityHook; // @addr 0x79EDF8 @ida "void __cdecl $name(void *ParentFrame);" @note "Native no-op with an unused caller-popped static link."
  begin
  end;
begin
  Stage := 0;
  try
    if LoadedSaveVersion >= 101 then begin
      SavedMods := Buffer.ReadWideString;
      if SavedMods <> SelectedMods then begin
        LoadedSaveModSet := SavedMods;
        AppendLogLineThreadSafe('Warning! Mod sets mismatch:');
        if SavedMods <> '' then AppendLogLineThreadSafe(AnsiString(' - when this save was made you were using: ' + SavedMods))
        else AppendLogLineThreadSafe(' - when this save was made you were not using mods');
        if SelectedMods <> '' then AppendLogLineThreadSafe(AnsiString(' - and now you are using: ' + SelectedMods))
        else AppendLogLineThreadSafe(' - and now you are not using any mods');
      end;
    end;
    GenerationSeed := Buffer.GetInt32;
    RandomState := Buffer.GetUInt32;
    SavedRandomState := RandomState;
    AverageRangerCapital := Buffer.GetInt32;
    MaxRangerWealth := Buffer.GetInt32;
    AverageRangerStrength := Buffer.GetSingle;
    BestRangerStrength := Buffer.GetSingle;
    GR_Main.CCInterface.SetTamperDetected(Buffer.GetBoolean);
    GR_Main.CCInterface.SetFlag0A(Buffer.GetBoolean);
    if LoadedSaveVersion = 136 then GR_Main.CCInterface.SetFlag0A(False);
    case LoadedSaveVersion of
      136, 140, 142: GR_Main.CCInterface.SetTamperDetected(False);
    end;
    Buffer.GetInt32;
    SetCheatPoints(Buffer.GetInt32);
    SaveCount := Buffer.GetInt32;
    LoadCount := Buffer.GetInt32 + 1;
    if LoadedSaveVersion >= 127 then Count := Buffer.GetWord else Count := 0;
    for I := 0 to Count - 1 do begin
      New(WeaponInfo);
      CustomWeaponTypes.Add(WeaponInfo);
      WeaponInfo.ItemType := t_CustomWeapon;
      WeaponInfo.ConfigName := Buffer.ReadWideString;
      Crc := InitCrc32;
      Crc := UpdateCrc32(Crc, PWideChar(WeaponInfo.ConfigName), Length(WeaponInfo.ConfigName) * 2);
      WeaponInfo.TypeHash := FinishCrc32(Crc);
      WeaponInfo.TechLevel := Buffer.GetByte;
      WeaponInfo.InventionIndex := Buffer.GetByte;
      WeaponInfo.CostFactor := Buffer.GetSingle;
      WeaponInfo.MinDamage := Buffer.GetInt32;
      WeaponInfo.MaxDamage := Buffer.GetInt32;
      WeaponInfo.AverageSize := Buffer.GetInt32;
      WeaponInfo.AverageRange := Buffer.GetInt32;
      WeaponInfo.ShotSpeedPercent := Buffer.GetInt32;
      WeaponInfo.MissileRange := Buffer.GetInt32;
      WeaponInfo.MissileMaxSpeed := Buffer.GetInt32;
      WeaponInfo.MissileMinSpeed := Buffer.GetInt32;
      WeaponInfo.MissileChanceToBeHit := Buffer.GetByte;
      Dword(WeaponInfo.DamageFlags) := Buffer.GetUInt32;
      WeaponInfo.ShotType := TWeaponShotType(Buffer.GetByte);
      WeaponInfo.ShotCount := Buffer.GetByte;
      if LoadedSaveVersion >= 132 then WeaponInfo.AttackCount := Buffer.GetByte else WeaponInfo.AttackCount := 1;
      WeaponInfo.SecondaryDamageRadius := Buffer.GetSingle;
      WeaponInfo.MiningFactor := Buffer.GetSingle;
      for J := 1 to 8 do WeaponInfo.DamageScaleByLevel[J] := Buffer.GetSingle;
      if Buffer.GetBoolean then WeaponInfo.PrimarySE := Buffer.ReadWideString else WeaponInfo.PrimarySE := '';
      if Buffer.GetBoolean then WeaponInfo.SecondarySE := Buffer.ReadWideString else WeaponInfo.SecondarySE := '';
      if Buffer.GetBoolean then WeaponInfo.AreaSE := Buffer.ReadWideString else WeaponInfo.AreaSE := '';
      WeaponInfo.DefaultPalette := Buffer.GetInt32;
      WeaponInfo.Availability := TWeaponAvailability(Buffer.GetByte);
      WeaponInfo.ArcadeWeaponType := Byte(MigrateSavedItemType(Buffer.GetByte));
    end;
    Stage := 1;
    Count := Buffer.GetWord;
    if (Count < 1) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do begin
      Constellation := TConstellation.Create;
      Constellations.Add(Constellation);
      Constellation.LoadFromBuffer(Buffer, Self);
    end;
    CanRecordAchievements;
    MainPiratePlanet := nil;
    Stage := 2;
    Count := Buffer.GetWord;
    if (Count < 1) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do begin
      Star := TStar.Create;
      Stars.Add(Star);
      Star.LoadFromBuffer(Buffer, Self);
    end;
    Stage := 3;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do begin
      Hole := THole.Create;
      Holes.Add(Hole);
      Hole.LoadFromBuffer(Buffer, Self);
    end;
    if LoadedSaveVersion >= 122 then begin
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do begin
        Stored := TStoredItem.CreateEmpty;
        StoredItems.Add(Stored);
        Stored.LoadFromBuffer(Buffer, Self);
      end;
    end;
    Stage := 4;
    ClearJumpGates;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do begin
      Gate := CreateJumpGate(False);
      X := Buffer.GetSingle;
      Y := Buffer.GetSingle;
      Gate.Gate.SetPosition(MakePointF(X, Y));
      Gate.Gate.SetAngle(Buffer.GetByte);
      TemplateIndex := Buffer.GetWord;
      Gate.Gate.SetSize(Classes.Point(TemplateIndex, TemplateIndex));
      Gate.Gate.SetText(Buffer.ReadWideString);
    end;
    Stage := 5;
    Count := Buffer.GetWord;
    if (Count < 1) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do Planets.Add(Pointer(Buffer.GetUInt32));
    for I := 0 to Stars.Count - 1 do begin
      Star := TStar(Stars[I]);
      for J := 0 to Star.Planets.Count - 1 do begin
        LoadedPlanet := TPlanet(Star.Planets[J]);
        if (LoadedPlanet.Id <= Cardinal(Count)) and (Cardinal(Planets[LoadedPlanet.Id - 1]) = LoadedPlanet.Id) then
          Planets[LoadedPlanet.Id - 1] := LoadedPlanet
        else for K := 0 to Planets.Count - 1 do
          if Cardinal(Planets[K]) = LoadedPlanet.Id then begin
            Planets[K] := LoadedPlanet;
            Break;
          end;
      end;
    end;
    Stage := 6;
    Count := Buffer.GetWord;
    if (Count < 1) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do Rangers.Add(Pointer(Buffer.GetUInt32));
    if LoadedSaveVersion >= 133 then
      for Race := oiMaloc to oiGaal do RangerSpawnQuotas[Race] := Buffer.GetInt32;
    if LoadedSaveVersion < 102 then begin
      Stage := 7;
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do Buffer.GetUInt32;
    end;
    KellerTargetStar := TStar(Buffer.GetUInt32);
    KellerMissionState := Buffer.GetInt32;
    Stage := 8;
    ClearTemporaryShopSlotGrid;
    Count := Buffer.GetWord;
    if Count > 0 then begin
      TemporaryShopSlots := TList.Create;
      for I := 0 to Count - 1 do begin
        ShopSlot := TShopSlot.Create;
        TemporaryShopSlots.Add(ShopSlot);
        ShopSlot.LoadFromBuffer(Buffer, Self);
      end;
    end;
    Stage := 9;
    Variables := TVarArrayEC.Create;
    Variables.LoadFromBuffer(Buffer);
    for I := 0 to Variables.Count - 1 do begin
      Variable := Variables.GetItem(I);
      Existing := SharedScriptVariables.GetVarNE(Variable.Name);
      if Existing <> nil then Existing.AssignFrom(Variable, True);
    end;
    Variables.Free;
    Stage := 10;
    Count := ScriptTemplates.Count;
    for I := 0 to Count - 1 do begin
      Template := ScriptTemplates[I];
      Template.UseCount := 0;
      Template.LastTurn := 0;
    end;
    Count := Buffer.GetWord;
    for I := 0 to Count - 1 do begin
      TemplateName := Buffer.ReadWideString;
      TemplateIndex := FindScriptTemplateIndex(TemplateName);
      if TemplateIndex < 0 then begin
        AppendLogLineThreadSafe(AnsiString('Warning: Script not found - ' + TemplateName));
        Buffer.GetWord;
        Buffer.GetInt32;
        Buffer.GetInt32;
      end else begin
        Template := ScriptTemplates[TemplateIndex];
        Template.UseCount := Buffer.GetWord;
        Template.LastTurn := Buffer.GetInt32;
        Template.ActiveScriptIndex := Buffer.GetInt32;
      end;
    end;
    Stage := 11;
    Count := Buffer.GetWord;
    for I := 0 to Count - 1 do begin
      Script := TScript.Create;
      Scripts.Add(Script);
      Script.LoadState(Buffer, Self);
      if (LoadedSaveVersion = 146) and (Script.ScriptFileName = 'Script.PC_part7') then
        if Script.InitCode.LocalVar.GetVar('player_traitor').GetInt = 1 then
          Script.InitCode.LocalVar.GetVar('pirates_killed_init').SetInt(1);
    end;
    Stage := 12;
    Count := Buffer.GetWord;
    for I := 0 to Count - 1 do begin
      Group := TGroup.Create;
      LiberationGroups.Add(Group);
      Group.Load(Buffer, Self);
    end;
    Stage := 13;
    Buffer.GetByte;
    Buffer.GetInt32;
    PirateCount := Buffer.GetWord;
    PirateClanCount := Buffer.GetWord;
    TransportCount := Buffer.GetWord;
    CurrentTurn := Buffer.GetUInt32;
    for Difficulty := 0 to 7 do DifficultyLevels[Difficulty] := Buffer.GetByte;
    PlayerRangerIndex := Buffer.GetUInt32;
    PendingPlayerFollowTarget := TShip(Buffer.GetUInt32);
    BlazerShip := TKling(Buffer.GetUInt32);
    KellerShip := TKling(Buffer.GetUInt32);
    TerronShip := TKling(Buffer.GetUInt32);
    PlayerStar := TStar(Buffer.GetUInt32);
    PieceCreatorTargetStarId := Buffer.GetUInt32;
    Stage := 14;
    for Career := Low(TRangerCareer) to High(TRangerCareer) do EminentCareerShips[Career] := TObject(Buffer.GetUInt32);
    Stage := 15;
    Count := Rangers.Count;
    for I := 0 to Count - 1 do Rangers[I] := TObject(IdToShip(Cardinal(Rangers[I]), True)) as TShip;
    Stage := 16;
    SetPlayer(TObject(IdToShip(PlayerRangerIndex, True)) as TPlayer, Self);
    Stage := 17;
    Count := Constellations.Count;
    for I := 0 to Count - 1 do begin
      Constellation := TConstellation(Constellations[I]);
      Constellation.ResolveLoadedReferences(Self);
    end;
    Stage := 18;
    J := 4;
    Count := Stars.Count;
    for I := 0 to Count - 1 do begin
      Star := TStar(Stars[I]);
      Star.ResolveLoadedReferences(Self);
    end;
    if TemporaryShopSlots <> nil then begin
      if GetPlayer.CurrentPlanet <> nil then TemporaryShopPlanet := GetPlayer.CurrentPlanet
      else if (GetPlayer.DockedTo <> nil) and (GetPlayer.DockedTo is TRuins) then
        TemporaryShopStation := TRuins(GetPlayer.DockedTo)
      else ClearTemporaryShopSlotGrid;
    end;
    Count := StoredItems.Count;
    for I := 0 to Count - 1 do begin
      Stored := TStoredItem(StoredItems[I]);
      TItem(Stored.Item).ResolveLoadedReferences(Self);
    end;
    Stage := 19;
    Count := Holes.Count;
    for I := 0 to Count - 1 do begin
      Hole := THole(Holes[I]);
      Hole.ResolveLoadedReferences(Self);
    end;
    Stage := 22;
    if KellerTargetStar <> nil then KellerTargetStar := TObject(IdToStar(Cardinal(KellerTargetStar))) as TStar;
    Stage := 23;
    PendingPlayerFollowTarget := TObject(IdToShip(Cardinal(PendingPlayerFollowTarget), True)) as TShip;
    BlazerShip := TObject(IdToShip(Cardinal(BlazerShip), True)) as TKling;
    KellerShip := TObject(IdToShip(Cardinal(KellerShip), True)) as TKling;
    TerronShip := TObject(IdToShip(Cardinal(TerronShip), True)) as TKling;
    PlayerStar := TObject(IdToStar(Cardinal(PlayerStar))) as TStar;
    Stage := 24;
    for Career := Low(TRangerCareer) to High(TRangerCareer) do EminentCareerShips[Career] := TObject(IdToShip(Cardinal(EminentCareerShips[Career]), True)) as TRanger;
    Stage := 25;
    if PlayerOldQuests <> nil then begin
      PlayerOldQuests.Free;
      PlayerOldQuests := nil;
    end;
    PlayerOldQuests := TList.Create;
    Count := Buffer.GetWord;
    Stage := 26;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err in PlayerQuests load');
    for I := 0 to Count - 1 do begin
      New(OldQuest);
      PlayerOldQuests.Add(OldQuest);
      OldQuest.Planet := TPlanet(Buffer.GetUInt32);
      OldQuest.Planet := TObject(IdToPlanet(Cardinal(OldQuest.Planet))) as TPlanet;
      OldQuest.QuestType := TQuestType(Buffer.GetByte);
      OldQuest.QuestNumber := Buffer.GetWord;
      OldQuest.Description := Buffer.ReadWideString;
      OldQuest.Successful := Buffer.GetBoolean;
      OldQuest.Declined := Buffer.GetBoolean;
    end;
    Stage := 27;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do begin
      New(News);
      PlanetNews.Add(News);
      News.Id := Buffer.GetUInt32;
      News.Turn := Buffer.GetUInt32;
      News.NewsType := Buffer.GetByte;
      News.Text := Buffer.ReadWideString;
    end;
    Stage := 28;
    ReservedMessageCounter := Buffer.GetUInt32;
    TurnsSinceLastShipMessage := Buffer.GetUInt32;
    ChecksumScalarD0 := Buffer.GetSingle;
    for Series := 0 to 2 do begin
      DominatorResearch[Series].Progress := Buffer.GetSingle;
      DominatorResearch[Series].Material := Buffer.GetUInt32;
    end;
    ChecksumScalarEC := Buffer.GetSingle;
    Stage := 29;
    if LoadedSaveVersion >= 62 then begin
      WarDeltaWin[1] := Buffer.GetInt32;
      WarDeltaWin[2] := Buffer.GetInt32;
      WarDeltaWin[0] := Buffer.GetInt32;
    end else begin
      WarDeltaWin[1] := Buffer.GetInt32 * -1;
      WarDeltaWin[2] := 0;
      WarDeltaWin[0] := 0;
    end;
    Stage := 30;
    Buffer.ReadLengthPrefixedBuffer(GR_Main.CCInterface.Buffer);
    GR_Main.CCInterface.Buffer.Clear;
    Stage := 31;
    Count := Buffer.GetInt32;
    if (Count < 0) or (Count > 1000000) then raise EAbort.Create('Err');
    SetLength(SpaceBackgroundEntries, Count);
    for I := 0 to High(SpaceBackgroundEntries) do begin
      SpaceBackgroundEntries[I].ImageIndex := Buffer.GetInt32;
      SpaceBackgroundEntries[I].OrbitCenter.X := Buffer.GetSingle;
      SpaceBackgroundEntries[I].OrbitCenter.Y := Buffer.GetSingle;
      SpaceBackgroundEntries[I].OrbitCenter.Z := Buffer.GetSingle;
      SpaceBackgroundEntries[I].Position.X := Buffer.GetSingle;
      SpaceBackgroundEntries[I].Position.Y := Buffer.GetSingle;
      SpaceBackgroundEntries[I].Position.Z := Buffer.GetSingle;
      SpaceBackgroundEntries[I].Unknown38.X := Buffer.GetSingle;
      SpaceBackgroundEntries[I].Unknown38.Y := Buffer.GetSingle;
      SpaceBackgroundEntries[I].Unknown38.Z := Buffer.GetSingle;
      SpaceBackgroundEntries[I].OrbitStepDegrees := Buffer.GetSingle;
      SpaceBackgroundEntries[I].FrameIndex := Buffer.GetInt32;
    end;
    Stage := 32;
    for I := 0 to 8 do HangarScreen.ShipSlots[I].ShipId := Buffer.GetUInt32;
    Stage := 33;
    GR_Main.CCInterface.SetValue10(Buffer.GetInt32);
    GR_Main.CCInterface.SetIntegrityStatus(Buffer.GetInt32);
    GR_Main.CCInterface.SetIntegrityError(Buffer.GetInt32);
    GR_Main.CCInterface.SetIntegrityChecksum(Buffer.GetInt32);
    Stage := 34;
    Count := Buffer.GetWord;
    for I := 0 to Count - 1 do ShipsInTransit.Add(IdToShip(Buffer.GetUInt32, True));
    Stage := 35;
    TerronWeaponLockTurn := Buffer.GetInt32;
    TerronGrowLockTurn := Buffer.GetInt32;
    TerronLandingLockTurn := Buffer.GetInt32;
    TerronToStarTurn := Buffer.GetInt32;
    KellerLeaveTurn := Buffer.GetInt32;
    if LoadedSaveVersion >= 47 then KellerResearchTargetStarId := Buffer.GetUInt32;
    BlazerLandingPlanetId := Buffer.GetUInt32;
    BlazerSelfDestructTurn := Buffer.GetInt32;
    TerronSeriesResolvedTurn := Buffer.GetInt32;
    KellerSeriesResolvedTurn := Buffer.GetInt32;
    BlazerSeriesResolvedTurn := Buffer.GetInt32;
    PirateWinTurn := Buffer.GetInt32;
    PirateWinType := Buffer.GetInt32;
    if LoadedSaveVersion >= 46 then CoalitionDefeatedTurn := Buffer.GetInt32;
    GraphDominatorSurfacesEnabled := Buffer.GetBoolean;
    SpaceEffectKind := Buffer.GetByte;
    IronWill := Buffer.GetBoolean;
    Stage := 36;
    if LoadedSaveVersion >= 71 then begin
      DominatorModLevel := Buffer.GetByte;
      TechnicModEnabled := Buffer.GetByte;
      AmmoModEnabled := Buffer.GetByte;
      GodModEnabled := Buffer.GetByte;
      UltraScanModEnabled := Buffer.GetByte;
      StasisModEnabled := Buffer.GetByte;
    end else begin
      DominatorModLevel := Buffer.GetInt32;
      TechnicModEnabled := Buffer.GetInt32;
      AmmoModEnabled := Buffer.GetInt32;
      GodModEnabled := Buffer.GetInt32;
      if LoadedSaveVersion >= 65 then UltraScanModEnabled := Buffer.GetInt32 else UltraScanModEnabled := 0;
      StasisModEnabled := 0;
    end;
    Stage := 37;
    NextPlanetNewsId := Buffer.GetUInt32;
    NextSpecialStationServiceTurn := Buffer.GetInt32;
    Stage := 38;
    Count := Buffer.GetWord;
    for I := 0 to Count - 1 do begin
      Event := TGalaxyEvent.Create('');
      GalaxyEvents.Add(Event);
      Event.LoadFromBuffer(Buffer);
    end;
    if LoadedSaveVersion >= 112 then begin
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do begin
        StateOverride := TInterfaceStateOverride.Create;
        InterfaceStateOverrides.Add(StateOverride);
        StateOverride.LoadFromBuffer(Buffer);
      end;
    end;
    if LoadedSaveVersion >= 117 then begin
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do begin
        TextOverride := TInterfaceTextOverride.Create;
        InterfaceTextOverrides.Add(TextOverride);
        TextOverride.LoadFromBuffer(Buffer);
      end;
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do begin
        ImageOverride := TInterfaceImageOverride.Create;
        InterfaceImageOverrides.Add(ImageOverride);
        ImageOverride.LoadFromBuffer(Buffer);
      end;
    end;
    if LoadedSaveVersion >= 119 then begin
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do begin
        PositionOverride := TInterfacePosOverride.Create;
        InterfacePositionOverrides.Add(PositionOverride);
        PositionOverride.LoadFromBuffer(Buffer);
      end;
    end;
    if LoadedSaveVersion >= 134 then begin
      Count := Buffer.GetWord;
      if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
      for I := 0 to Count - 1 do begin
        SizeOverride := TInterfaceSizeOverride.Create;
        InterfaceSizeOverrides.Add(SizeOverride);
        SizeOverride.LoadFromBuffer(Buffer);
      end;
    end;
    Stage := 39;
    if LoadedSaveVersion >= 70 then begin
      NextShipId := Buffer.GetUInt32;
      NextItemId := Buffer.GetUInt32;
    end;
    Stage := 40;
    if LoadedSaveVersion >= 56 then GenerationMachineHash := Buffer.GetUInt32
    else GenerationMachineHash := ComputeMachineFingerprintCRC;
    Stage := 41;
    Count := Scripts.Count;
    for I := 0 to Count - 1 do begin
      Script := TScript(Scripts[I]);
      Script.ResolveLoadedReferences(Self);
    end;
    Stage := 42;
    Count := LiberationGroups.Count;
    for I := 0 to Count - 1 do begin
      Group := TGroup(LiberationGroups[I]);
      Group.ResolveLoadedReferences(Self);
    end;
    Stage := 43;
    Count := Stars.Count;
    for I := 0 to Count - 1 do begin
      Star := TStar(Stars[I]);
      ShipCount := Star.Ships.Count;
      for TemplateIndex := 0 to ShipCount - 1 do begin
        Ship := TShip(Star.Ships[TemplateIndex]);
        if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet.CurrentStar <> Star) then begin
          AppendLogLineThreadSafe(AnsiString('Warning! ' + Ship.GetFullName(' ') + ' is in system ' + Star.Name +
            ' while landed on planet ' + Ship.CurrentPlanet.Name));
          AppendLogLineThreadSafe('clearing landing state');
          Ship.CurrentPlanet := nil;
        end;
        if Ship.TypeId = stWarrior then Ship.HomePlanet.Warriors.Add(Ship);
        if (Ship.TypeId = stRanger) and (Rangers.IndexOf(Ship) < 0) then (Ship as TRanger).RegisterInGalaxyRelations;
      end;
    end;
    if (LoadedSaveVersion < 121) and (MainPiratePlanet <> nil) then
      for I := 0 to Stars.Count - 1 do begin
        Star := TStar(Stars[I]);
        for J := 0 to Star.Ships.Count - 1 do begin
          Ship := TShip(Star.Ships[J]);
          if (Ship is TPirate) and (Ship.OwnerId = oiPirate) and ((Ship as TPirate).PirateType <> 0) then
            for K := 0 to Rangers.Count - 1 do Ship.RangerRelations[K] := MainPiratePlanet.RangerRelations[K];
        end;
      end;
    Stage := 44;
    ComputeGlobalGoodsPriceBands;
    InitializeConstellationDistanceTiers;
    RebuildStarDistances;
    UpdateConstellationMilitaryStats;
    RefreshRangerWealthStats;
    RefreshRangerRatingPlaces;
    RefreshTechLevel;
    Stage := 45;
    if BlazerShip <> nil then CreateDominatorSpawnProxy(BlazerShip.CurrentStar)
    else if TerronShip <> nil then CreateDominatorSpawnProxy(TerronShip.CurrentStar)
    else if KellerShip <> nil then CreateDominatorSpawnProxy(KellerShip.CurrentStar)
    else CreateDominatorSpawnProxy(nil);
    Stage := 46;
    for I := 0 to Stars.Count - 1 do begin
      Star := TStar(Stars[I]);
      Star.MapDiameter := Star.ComputeMapDiameter;
    end;
    Stage := 47;
    if (TerronToStarTurn and TerronTransformationFlag <> 0) and (TerronShip <> nil) then begin
      ReleaseSpaceObject(TerronShip.CurrentStar.Graphic);
      RetainSpaceObject(TerronShip.CurrentStar.Graphic, CreateSpaceObjectByName('Star', 'Star.TerronAfter', Classes.Point(0, 0)));
    end;
    Stage := 48;
    GetPlayer.CurrentStar.RefreshMovementStepParameters;
    RandomState := SavedRandomState;
    Stage := 49;
    if LoadedSaveVersion >= 61 then begin
      GR_Main.CCInterface.SetEditableStateApplied(Buffer.GetBoolean);
      FinalizationNameEncoded := Buffer.ReadWideString;
    end else begin
      GR_Main.CCInterface.SetEditableStateApplied(False);
      FinalizationNameEncoded := '';
    end;
    Stage := 50;
    if LoadedSaveVersion >= 63 then begin
      CustomRules.Enabled := Buffer.GetBoolean;
      CustomRules.DominatorStrength := Buffer.GetByte;
      CustomRules.DominatorAggression := Buffer.GetByte;
      CustomRules.DominatorSpawn := Buffer.GetByte;
      CustomRules.PirateAggression := Buffer.GetByte;
      CustomRules.CoalitionAggression := Buffer.GetByte;
      CustomRules.AsteroidModifier := Buffer.GetByte;
      CustomRules.SunDamageModifier := Buffer.GetByte;
      if LoadedSaveVersion >= 64 then begin
        CustomRules.ExtraInventions := Buffer.GetByte;
      end else begin
        CustomRules.ExtraInventions := 0;
      end;
      if LoadedSaveVersion >= 64 then begin
        CustomRules.AcrynModifier := Buffer.GetByte;
      end else begin
        CustomRules.AcrynModifier := 16;
      end;
      if LoadedSaveVersion >= 66 then begin
        CustomRules.NodeDropModifier := Buffer.GetByte;
        CustomRules.ArcadeDropValueModifier := Buffer.GetByte;
        CustomRules.DropValueModifier := Buffer.GetByte;
        CustomRules.AgriculturalPlanetWeight := Buffer.GetByte;
        CustomRules.MixedPlanetWeight := Buffer.GetByte;
        CustomRules.IndustrialPlanetWeight := Buffer.GetByte;
        CustomRules.ExtraRangers := Buffer.GetByte;
        CustomRules.ArcadeHitpointsModifier := Buffer.GetByte;
        CustomRules.ArcadeDamageModifier := Buffer.GetByte;
        CustomRules.AIJunkTolerance := Buffer.GetByte;
      end else begin
        CustomRules.NodeDropModifier := 8;
        CustomRules.ArcadeDropValueModifier := 8;
        CustomRules.DropValueModifier := 8;
        CustomRules.AgriculturalPlanetWeight := 1;
        CustomRules.MixedPlanetWeight := 1;
        CustomRules.IndustrialPlanetWeight := 1;
        CustomRules.ExtraRangers := 0;
        CustomRules.ArcadeHitpointsModifier := 8;
        CustomRules.ArcadeDamageModifier := 8;
        CustomRules.AIJunkTolerance := 7;
      end;
      CustomRules.ChaoticRandom := Buffer.GetBoolean;
      CustomRules.UnrestrictedEquipmentKnowledge := Buffer.GetBoolean;
      CustomRules.StationsNearStars := Buffer.GetBoolean;
      CustomRules.FullStationTargeting := Buffer.GetBoolean;
      if LoadedSaveVersion >= 64 then begin
        CustomRules.SpecialShips := Buffer.GetBoolean;
      end else begin
        CustomRules.SpecialShips := False;
      end;
      if LoadedSaveVersion >= 66 then begin
        CustomRules.ZeroStartingExperience := Buffer.GetBoolean;
        if LoadedSaveVersion < 92 then Buffer.GetBoolean;
        CustomRules.ArcadeBattleRoyale := Buffer.GetBoolean;
        CustomRules.DominatorRacialWeapons := Buffer.GetBoolean;
      end else begin
        CustomRules.ZeroStartingExperience := False;
        CustomRules.ArcadeBattleRoyale := False;
        CustomRules.DominatorRacialWeapons := False;
      end;
      if LoadedSaveVersion >= 72 then begin
        CustomRules.StartInCenter := Buffer.GetBoolean;
      end else begin
        CustomRules.StartInCenter := False;
      end;
      if LoadedSaveVersion >= 73 then begin
        CustomRules.MaxRangeMissiles := Buffer.GetBoolean;
      end else begin
        CustomRules.MaxRangeMissiles := False;
      end;
      if LoadedSaveVersion >= 75 then begin
        CustomRules.OldHyperspace := Buffer.GetBoolean;
        CustomRules.PirateNodes := Buffer.GetBoolean;
      end else begin
        CustomRules.OldHyperspace := False;
        CustomRules.PirateNodes := False;
      end;
      if LoadedSaveVersion >= 84 then begin
        CustomRules.AIUseShops := Buffer.GetBoolean;
        CustomRules.StationsUseShop := Buffer.GetBoolean;
      end else begin
        CustomRules.AIUseShops := False;
        CustomRules.StationsUseShop := False;
      end;
      if LoadedSaveVersion >= 136 then begin
        CustomRules.DuplicateArtefacts := Buffer.GetBoolean;
      end else begin
        CustomRules.DuplicateArtefacts := False;
      end;
      if LoadedSaveVersion >= 156 then begin
        CustomRules.HullGrowth := Buffer.GetByte;
      end else begin
        CustomRules.HullGrowth := 0;
      end;
      if LoadedSaveVersion >= 166 then begin
        CustomRules.ArcadeEquipmentChange := Buffer.GetBoolean;
        CustomRules.OldSpeedCalculation := Buffer.GetBoolean;
        CustomRules.OldMissileBonuses := Buffer.GetBoolean;
        Buffer.GetBoolean;
        Buffer.GetBoolean;
        Buffer.GetBoolean;
        Buffer.GetBoolean;
        Buffer.GetBoolean;
      end else begin
        CustomRules.ArcadeEquipmentChange := False;
        CustomRules.OldSpeedCalculation := False;
        CustomRules.OldMissileBonuses := False;
      end;
    end else begin
      CustomRules.Enabled := True;
      case DifficultyLevels[0] of
        0: CustomRules.DominatorStrength := 0;
        1: CustomRules.DominatorStrength := 8;
        2: CustomRules.DominatorStrength := 16;
        3: CustomRules.DominatorStrength := 24;
      end;
      CustomRules.DominatorAggression := CustomRules.DominatorStrength;
      CustomRules.DominatorSpawn := CustomRules.DominatorStrength;
      CustomRules.PirateAggression := CustomRules.DominatorStrength;
      CustomRules.CoalitionAggression := 8;
      CustomRules.AsteroidModifier := 8;
      CustomRules.SunDamageModifier := 8;
      CustomRules.ExtraInventions := 0;
      CustomRules.AcrynModifier := 16;
      CustomRules.NodeDropModifier := 8;
      CustomRules.ArcadeDropValueModifier := 8;
      CustomRules.DropValueModifier := 8;
      CustomRules.AgriculturalPlanetWeight := 1;
      CustomRules.MixedPlanetWeight := 1;
      CustomRules.IndustrialPlanetWeight := 1;
      CustomRules.ExtraRangers := 0;
      CustomRules.ArcadeHitpointsModifier := 8;
      CustomRules.ArcadeDamageModifier := 8;
      CustomRules.AIJunkTolerance := 7;
      CustomRules.ChaoticRandom := False;
      CustomRules.UnrestrictedEquipmentKnowledge := False;
      CustomRules.StationsNearStars := False;
      CustomRules.FullStationTargeting := False;
      CustomRules.SpecialShips := False;
      CustomRules.ZeroStartingExperience := False;
      CustomRules.ArcadeBattleRoyale := False;
      CustomRules.DominatorRacialWeapons := False;
      CustomRules.StartInCenter := False;
      CustomRules.MaxRangeMissiles := False;
      CustomRules.OldHyperspace := False;
      CustomRules.PirateNodes := False;
      CustomRules.AIUseShops := False;
      CustomRules.StationsUseShop := False;
      CustomRules.DuplicateArtefacts := False;
      CustomRules.HullGrowth := 0;
      CustomRules.ArcadeEquipmentChange := False;
      CustomRules.OldSpeedCalculation := False;
      CustomRules.OldMissileBonuses := False;
    end;
    Stage := 51;
    CompatibilityHook;
    Event := AddGalaxyEvent('SaveLoaded', Self);
    ShipCount := CountDelimitedPartsW(SelectedMods, ',');
    for I := 0 to ShipCount - 1 do Event.AddTextData(ExtractDelimitedPartW(SelectedMods, I, ','));
    Event.AddData(Ord(ApplyEditableSaveOnLoad));
    Stage := 52;
    aGalaxy.Galaxy := Self;
    for I := 0 to LoadedShips.Count - 1 do begin
      Ship := TShip(LoadedShips[I]);
      Ship.RefreshDerivedStats(False);
      Ship.RefreshGraphicSize;
      Ship.DerivedStateCompatibilityHook;
    end;
    RefreshRangerStrengthStats;
    for I := 0 to LoadedShips.Count - 1 do begin
      Ship := TShip(LoadedShips[I]);
      Ship.UpdateBestRangerRelativeRatings;
      Ship.UpdateAverageRangerRelativeStrength;
    end;
    LoadedShips.Clear;
    GetPlayer.RefreshStorageBubbles;
    PrimeIntegrityChecksum(101);
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create(AnsiString('Error in procedure ' + DecodeTextW('TAGSallbanxuy..MLFovasdi') + ', label = ' + IntToStr(Stage))); // 'TGalaxy.Load'
    end;
  end;
end;
{ @end $79EE00 }

{ @routine $7A2054 TGalaxy_SaveEditableState }
procedure TGalaxy.SaveEditableState;
var
  i: Integer;
  Name: WideString;
  Star: TStar;
  Hole: THole;
  HoleBlock: TBlockParEC;
begin
  GR_Main.EditableSaveBlock.Clear;
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('FsignsarltiyzaazthikoEnoNiaemaex'), DecodeTextW(Self.FinalizationNameEncoded)); // 'FinalizationName'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('ImDeary'), WideString(SysUtils.IntToStr(Self.CurrentTurn))); // 'IDay'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DeieffPhizroantle'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[0]))); // 'DifPirate'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DuiefsTvrnaSdlej'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[1]))); // 'DifTrade'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DpiffeSscvn'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[2]))); // 'DifScn'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DqirfsRfejpyariSra'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[3]))); // 'DifRepair'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DoitfdTgeecthv'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[4]))); // 'DifTech'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DpiFfsQvueeYsst'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[5]))); // 'DifQuest'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DpiwfsHrojlee'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[6]))); // 'DifHole'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('DpiefdBkarlsaGndcVee'), WideString(SysUtils.IntToStr(Self.DifficultyLevels[7]))); // 'DifBalance'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('KvlsiRnsgTshDdeHljtoaRWdifnG'), WideString(SysUtils.IntToStr(Self.WarDeltaWin[1]))); // 'KlingsDeltaWin'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('PuirreastTerswDVesltt4a6WHidns'), WideString(SysUtils.IntToStr(Self.WarDeltaWin[2]))); // 'PiratesDeltaWin'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('Npo6rdm2aSlfsHDeeyljt4asWCignI'), WideString(SysUtils.IntToStr(Self.WarDeltaWin[0]))); // 'NormalsDeltaWin'
  GR_Main.EditableSaveBlock.AddParam(DecodeTextW('RlehjieScataPSB'), BoolToWideString(GetPlayer.DeclinePlanetBattleOffers)); // 'RejectPB'
  GetPlayer.SaveToBlock(GR_Main.EditableSaveBlock.AddBlockByPath(DecodeTextW('Polearymeir'))); // 'Player'
  HoleBlock := GR_Main.EditableSaveBlock.AddBlockByPath(DecodeTextW('HroslaenLfirs4t')); // 'HoleList'
  for i := 0 to Self.Holes.Count - 1 do
  begin
    Hole := THole(Self.Holes[i]);
    Name := DecodeTextW('Heo4lge5I6dY') + WideString(SysUtils.IntToStr(Int64(Hole.Id))); // 'HoleId'
    Hole.SaveToBlock(HoleBlock.AddBlockByPath(Name));
  end;
  HoleBlock.AddParam(DecodeTextW('CEr2e4aftge4NgehwYHeohlsegs1'), WideString(SysUtils.IntToStr(0))); // 'CreateNewHoles'
  with GR_Main.EditableSaveBlock.AddBlockByPath(DecodeTextW('SatraproLaiAsot')) do // 'StarList'
    for i := 0 to Self.Stars.Count - 1 do
    begin
      Star := TStar(Self.Stars[i]);
      Name := DecodeTextW('S5tTaersIed2') + WideString(SysUtils.IntToStr(Int64(Star.Id))); // 'StarId'
      Star.SaveToBlock(AddBlockByPath(Name));
    end;
end;
{ @end $7A2054 }

{ @routine $7A2AEC TGalaxy_ApplyEditableState }
procedure TGalaxy.ApplyEditableState;
var I: Integer;
  Key: WideString;
  Star: TStar;
  Hole: THole;
  Angle, Radius: Single;
  HoleBlock: TBlockParEC;
begin
  if FinalizationNameEncoded = '' then begin
    GR_Main.CCInterface.SetEditableStateApplied(True);
    FinalizationNameEncoded := EncodeTextW(EditableSaveBlock.GetParam(DecodeTextW('FsignsarltiyzaazthikoEnoNiaemaex'))); // 'FinalizationName'
    if FinalizationNameEncoded <> '' then SetCheatPoints(0);
    DifficultyLevels[0] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DeieffPhizroantle')))))); // 'DifPirate'
    DifficultyLevels[1] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DuiefsTvrnaSdlej')))))); // 'DifTrade'
    DifficultyLevels[2] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DpiffeSscvn')))))); // 'DifScn'
    DifficultyLevels[3] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DqirfsRfejpyariSra')))))); // 'DifRepair'
    DifficultyLevels[4] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DoitfdTgeecthv')))))); // 'DifTech'
    DifficultyLevels[5] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DpiFfsQvueeYsst')))))); // 'DifQuest'
    DifficultyLevels[6] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DpiwfsHrojlee')))))); // 'DifHole'
    DifficultyLevels[7] := Max(0, Min(9, StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('DpiefdBkarlsaGndcVee')))))); // 'DifBalance'
    WarDeltaWin[1] := StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('KvlsiRnsgTshDdeHljtoaRWdifnG')))); // 'KlingsDeltaWin'
    WarDeltaWin[2] := StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('PuirreastTerswDVesltt4a6WHidns')))); // 'PiratesDeltaWin'
    WarDeltaWin[0] := StrToInt(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('Npo6rdm2aSlfsHDeeyljt4asWCignI')))); // 'NormalsDeltaWin'
    GetPlayer.DeclinePlanetBattleOffers := LowerCase(AnsiString(EditableSaveBlock.GetParam(DecodeTextW('RlehjieScataPSB')))) = 'true'; // 'RejectPB'
    GetPlayer.LoadFromBlock(EditableSaveBlock.GetBlockByPath(DecodeTextW('Polearymeir'))); // 'Player'
    HoleBlock := EditableSaveBlock.GetBlockByPath(DecodeTextW('HroslaenLfirs4t')); // 'HoleList'
    for I := 0 to Holes.Count - 1 do begin
      Hole := THole(Holes[I]);
      Key := DecodeTextW('Heo4lge5I6dY') + IntToStr(Int64(Hole.Id)); // 'HoleId'
      Hole.LoadFromBlock(HoleBlock.GetBlockByPath(Key));
    end;
    for I := 0 to StrToInt(AnsiString(HoleBlock.GetParam(DecodeTextW('CEr2e4aftge4NgehwYHeohlsegs1')))) - 1 do begin // 'CreateNewHoles'
      Hole := THole.Create;
      Hole.InitializeGraphic('');
      THoleSE(Hole.Graphic).SetState(1);
      Hole.Star1 := GetPlayer.CurrentStar;
      Hole.Star2 := GetPlayer.CurrentStar;
      Hole.ArcadeMapName := '';
      Angle := HeadingDegreesToRadians(RandomIntRange(0, 359));
      Radius := RandomIntRange(1000, 2000);
      Hole.Position1 := MakePointF(Sin(Angle) * Radius, -Cos(Angle) * Radius);
      Hole.Position2 := MakePointF(Sin(Angle) * Radius, -Cos(Angle) * Radius);
      Hole.CreatedTurn := CurrentTurn;
      Hole.HoleType := 1;
      Holes.Add(Hole);
    end;
    with EditableSaveBlock.GetBlockByPath(DecodeTextW('SatraproLaiAsot')) do // 'StarList'
      for I := 0 to Stars.Count - 1 do begin
        Star := TStar(Stars[I]);
        Key := DecodeTextW('S5tTaersIed2') + IntToStr(Int64(Star.Id)); // 'StarId'
        Star.LoadFromBlock(GetBlockByPath(Key));
      end;
    EditableSaveBlock.Clear;
  end;
end;
{ @end $7A2AEC }

{ @routine $7A3960 TGalaxy_RunConfigOnStartHandlers }
procedure TGalaxy.RunConfigOnStartHandlers;
var Block, Handler: TBlockParEC; I, Count: Integer; Text: WideString;
begin
  Block := MainDataConfig.GetBlock('BV').FindBlockByPath('OnStart');
  if Block <> nil then begin
    Count := Block.GetBlockCount;
    for I := 0 to Count - 1 do begin
      Handler := Block.GetBlockByIndex(I);
      Text := Handler.ConcatenateValues;
      ExecuteScriptText(Text, nil);
    end;
  end;
end;
{ @end $7A3960 }

{ @routine $7A3A2C TGalaxy_RunConfigOnLoadHandlers }
procedure TGalaxy.RunConfigOnLoadHandlers;
var Block, Handler: TBlockParEC; I, Count: Integer; Text: WideString;
begin
  Block := MainDataConfig.GetBlock('BV').FindBlockByPath('OnLoad');
  if Block <> nil then begin
    Count := Block.GetBlockCount;
    for I := 0 to Count - 1 do begin
      Handler := Block.GetBlockByIndex(I);
      Text := Handler.ConcatenateValues;
      ExecuteScriptText(Text, nil);
    end;
  end;
end;
{ @end $7A3A2C }

{ @routine $7A3AF8 TGalaxy_RunConfigOnSaveHandlers }
procedure TGalaxy.RunConfigOnSaveHandlers;
var Block, Handler: TBlockParEC; I, Count: Integer; Text: WideString;
begin
  Block := MainDataConfig.GetBlock('BV').FindBlockByPath('OnSave');
  if Block <> nil then begin
    Count := Block.GetBlockCount;
    for I := 0 to Count - 1 do begin
      Handler := Block.GetBlockByIndex(I);
      Text := Handler.ConcatenateValues;
      ExecuteScriptText(Text, nil);
    end;
  end;
end;
{ @end $7A3AF8 }

{ @routine $7A3BC4 TGalaxy_ReapplyInterfaceOverrides }
procedure TGalaxy.ReapplyInterfaceOverrides;
var I: Integer;
begin
  for I := 0 to InterfaceStateOverrides.Count - 1 do TInterfaceStateOverride(InterfaceStateOverrides[I]).Reapply;
  for I := 0 to InterfaceTextOverrides.Count - 1 do TInterfaceTextOverride(InterfaceTextOverrides[I]).Reapply;
  for I := 0 to InterfaceImageOverrides.Count - 1 do TInterfaceImageOverride(InterfaceImageOverrides[I]).Reapply;
  for I := 0 to InterfacePositionOverrides.Count - 1 do TInterfacePosOverride(InterfacePositionOverrides[I]).Reapply;
  for I := 0 to InterfaceSizeOverrides.Count - 1 do TInterfaceSizeOverride(InterfaceSizeOverrides[I]).Reapply;
end;
{ @end $7A3BC4 }

{ @routine $7A3CF4 TGalaxy_BindScriptImports }
procedure TGalaxy.BindScriptImports;
var I: Integer;
begin
  for I := 0 to Scripts.Count - 1 do TScript(Scripts[I]).BindImportedFunctions;
end;
{ @end $7A3CF4 }

{ @routine $7A3D3C TGalaxy_NextDay }
procedure TGalaxy.NextDay;
var I, J: Integer;
  Ratio: Single;
  Star: TStar;
  Ship: TShip;
  Group: TGroup;
  Script: TScript;
  Bubble: TMessagePlayer;
  PreviousTechLevel: Integer;
  Text: WideString;
  Stage: Integer;
begin
  Stage := 0;
  if GetPlayer <> nil then
    try
      Ratio := GetCoalitionToPirateSystemRatio / GalaxyDifficultyTuning[DifficultyLevels[0]].CoalitionToPirateBalanceRatio;
      // Native applies bitwise NOT before comparison, rather than inequality.
      if ((not PirateWinType) = 3) and
         (((Ratio > 1.25) and (NextRandomIntRange(1, 1000, RandomState) <= 3)) or
          ((Ratio > 1.5) and (NextRandomIntRange(1, 1000, RandomState) <= 10)) or
          ((Ratio > 2) and (NextRandomIntRange(1, 1000, RandomState) <= 30))) then Dec(WarDeltaWin[2]);
      if ((Galaxy.CoalitionDefeatedTurn = 0) and (Ratio < 0.8) and (NextRandomIntRange(1, 1000, RandomState) <= 3)) or
         ((Ratio < 0.66) and (NextRandomIntRange(1, 1000, RandomState) <= 10)) or
         ((Ratio < 0.5) and (NextRandomIntRange(1, 1000, RandomState) <= 30)) then begin
        Inc(WarDeltaWin[2]);
        Dec(WarDeltaWin[0]);
      end;
      Stage := 1;
      if Random(50) = 0 then CheckPlatformModules;
      Stage := 13;
      if ((((CurrentTurn + Integer(GenerationSeed)) mod GetTurnsBetweenLiberationGroups) = 0) and (CurrentTurn >= GalaxyWarmupTurns)) or
         (WarDeltaWin[0] < -5) or ((CountFactionStars(sfCoalition) < 5) and (LiberationGroups.Count = 0)) or
         (CountFactionStars(sfCoalition) = 1) then begin
        Stage := 14;
        if LiberationGroups.Count < 2 then TryCreateLiberationGroup;
      end;
      Stage := 15;
      for I := LiberationGroups.Count - 1 downto 0 do begin Group := TGroup(LiberationGroups[I]); Group.NextDay; end;
      Stage := 16;
      if WingmenPendingLeadershipPenalty = nil then WingmenPendingLeadershipPenalty := TList.Create
      else WingmenPendingLeadershipPenalty.Clear;
      for I := 0 to Stars.Count - 1 do begin
        Star := TStar(Stars[I]);
        if (GetPlayer = nil) or (GetPlayer.CurrentStar <> Star) then Star.NextDay(False);
      end;
      if (GetPlayer = nil) or (GetPlayer.GetHull.HullPoints <= 0) then Exit;
      Stage := 2;
      I := 0;
      while I < Scripts.Count do begin
        Stage := 3;
        Script := TScript(Scripts[I]);
        Script.RunTurnCode;
        Stage := 4;
        if Script.Ships.Count < 1 then begin
          for J := 0 to Script.EtherIds.GetCount - 1 do begin
            Stage := 5;
            Bubble := FindPlayerBubbleByKey(Script.EtherIds.GetTextAt(J), False);
            if (Bubble <> nil) and (Bubble.Kind = 3) then begin Bubble.Kind := 5; Bubble.WasRead := False; end;
          end;
          Stage := 6;
          Scripts.Delete(I);
          try Script.Free;
          except AppendLogLineThreadSafe('Error Galaxy.Script.Free'); end;
          Stage := 7;
          for J := 0 to ScriptTemplates.Count - 1 do
            if TScriptTemplUnit(ScriptTemplates[J]).ActiveScriptIndex = I then TScriptTemplUnit(ScriptTemplates[J]).ActiveScriptIndex := -1
            else if TScriptTemplUnit(ScriptTemplates[J]).ActiveScriptIndex > I then Dec(TScriptTemplUnit(ScriptTemplates[J]).ActiveScriptIndex);
        end else Inc(I);
      end;
      Inc(CurrentTurn);
      Stage := 8; ProcessStationSpawning;
      Stage := 9; UpdateConstellationMilitaryStats;
      Stage := 10;
      PlayerDialogueRequestCount := 0;
      Inc(ReservedMessageCounter);
      Inc(TurnsSinceLastShipMessage);
      if CurrentTurn mod TurnsPerYear = 0 then ComputeGlobalGoodsPriceBands;
      Stage := 11;
      if GetPlayer <> nil then GetPlayer.RebuildEquipmentCache;
      Stage := 12;
      if (CurrentTurn + Integer(GenerationSeed)) mod 7 = 0 then ComputeRangerSpawnQuotas;
      Stage := 17;
      if GetPlayer <> nil then
        if GetPlayer.CurrentStar <> nil then
          for I := GetPlayer.CurrentStar.Ships.Count - 1 downto 0 do begin
            Ship := TShip(GetPlayer.CurrentStar.Ships[I]);
            if (Ship.PartnerShip <> nil) and (Ship.PartnershipDaysRemaining > 0) and
              (WingmenPendingLeadershipPenalty.IndexOf(Ship) < 0) then WingmenPendingLeadershipPenalty.Add(Ship);
          end;
      Stage := 18; ApplyWingmanLeadershipPenalty;
      Stage := 19; PruneExpiredGalaxyEvents;
      Stage := 20;
      PreviousTechLevel := TechLevel;
      RefreshTechLevel;
      if GetPlayer <> nil then
        if GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0 then begin
          Text := '';
          if TechLevel > PreviousTechLevel then Text := LocalizedText('Artefacts.ArtAnalyzer.TechLevelUp');
          if TechLevel < PreviousTechLevel then Text := LocalizedText('Artefacts.ArtAnalyzer.TechLevelDown');
          if Text <> '' then AddOrUpdatePlayerBubble(pmGalaxyNews, CurrentTurn, Text, '');
        end;
      Stage := 21; TryDispatchMilitaryBaseToEnemyStar;
      Stage := 22; RefreshRangerWealthStats;
      Stage := 23; RefreshRangerStrengthStats;
      Stage := 24; RefreshRangerRatingPlaces;
      Stage := 25; PrunePlanetNews;
      Stage := 26; CheckMemoryUsage;
    except
      on E: Exception do begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        raise Exception.Create('Error in procedure TGalaxy.NextDay label = ' + IntToStr(Stage));
      end;
    end;
end;
{ @end $7A3D3C }

{ @routine $7A463C TGalaxy_CompleteDay }
procedure TGalaxy.CompleteDay(UnusedRecordFilm: Boolean);
var
  Hole: THole;
  Ship: TShip;
  i, j, Count: Integer;
  Angle, Radius: Single;
  Star: TStar;
  Missile: TMissile;
begin
  if Self.SpecialSimulationMode <> 0 then Exit;
  if Self.AreSpecialShipsEnabled then AssignSpecialStationService;
  Self.ProcessDominatorResearchProgress;
  ProcessBankDebtAndDeposits;
  Self.ProcessRangerCenterNewYearEvent;
  if (GetPlayer <> nil) and GetPlayer.AfterburnerActive and (GetPlayer.GetEngine <> nil) and
    (GetPlayer.GetEngine.ConditionPercent <= GlobalsV.AfterburnerStopCondition) and (Self.TechnicModEnabled = 0) then
  begin
    GetPlayer.AfterburnerActive := False;
    GetPlayer.RefreshDerivedStats(True);
    PlayerStar.InterruptLongTravel := True;
  end;
  if GetPlayer <> nil then
  begin
    i := 0;
    while i < Self.Holes.Count do
    begin
      Hole := THole(Self.Holes[i]);
      if (Hole.HoleType = 3) or
        ((Hole.HoleType = 4) and (Self.KellerMissionState = 5) and
          (Self.ScaleIntByTechLevel(1, 10) < Self.CurrentTurn - Hole.CreatedTurn)) or
        ((Hole.HoleType = 1) and (Self.CurrentTurn - Hole.CreatedTurn > 200)) or
        ((Hole.HoleType = 4) and (aKling.KellerShip = nil)) then
      begin
        j := 0;
        Count := Hole.Star1.Ships.Count;
        while j < Count do
        begin
          Ship := TShip(Hole.Star1.Ships[j]);
          if (Ship.Order = soJumpHole) and (Ship.OrderTarget = Hole) then Break;
          Inc(j);
        end;
        if j >= Count then
        begin
          j := 0;
          Count := Hole.Star2.Ships.Count;
          while j < Count do
          begin
            Ship := TShip(Hole.Star2.Ships[j]);
            if (Ship.Order = soJumpHole) and (Ship.OrderTarget = Hole) then Break;
            Inc(j);
          end;
          if j >= Count then
          begin
            if Hole.HoleType = 4 then Self.KellerMissionState := 0;
            Self.Holes.Delete(i);
            Hole.Free;
            Dec(i);
          end;
        end;
      end;
      Inc(i);
    end;
  end;
  if (GetPlayer <> nil) and
    (NextRandomIntRange(0, aConst.GalaxyDifficultyTuning[Self.DifficultyLevels[6]].RandomHoleSpawnRollMaximum, Self.RandomState) = 0) and
    (Self.Holes.Count <= 2) and (Self.CurrentTurn > GalaxyWarmupTurns) then
  begin
    Hole := THole.Create;
    Hole.InitializeGraphic('');
    Hole.HoleType := 1;
    Hole.CreatedTurn := Self.CurrentTurn;
    j := 0;
    while True do
    begin
      Inc(j);
      if j > 100 then Break;
      Hole.Star1 := TStar(Self.Stars[NextRandomIntRange(0, Self.Stars.Count - 1, Self.RandomState)]);
      if (Hole.Star1.Constellation.Id <> 20) and (GetPlayer.CurrentStar <> Hole.Star1) and
        TStar(Hole.Star1).IsConstellationVisible and (Hole.Star1.DaysSincePlayerVisit >= 30) and
        (Hole.Star1.ControlFaction <> sfDominators) and (Hole.Star1.Status.CustomFaction = '') then Break;
    end;
    if j > 100 then Hole.Free
    else
    begin
      j := 0;
      while True do
      begin
        Inc(j);
        if j > 100 then Break;
        Hole.Star2 := TStar(Self.Stars[NextRandomIntRange(0, Self.Stars.Count - 1, Self.RandomState)]);
        if (Hole.Star1 <> Hole.Star2) and (Hole.Star2.Constellation.Id <> 20) and
          (GetPlayer.CurrentStar <> Hole.Star2) and TStar(Hole.Star2).IsConstellationVisible and
          (Hole.Star2.DaysSincePlayerVisit >= 30) then Break;
      end;
      if j > 100 then Hole.Free
      else
      begin
        Self.Holes.Add(Hole);
        Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, (Hole.Star1.GenerationSeed + Self.CurrentTurn) * Self.GenerationSeed));
        Radius := SeededRandomIntRange(System.Round(Hole.Star1.MapDiameter * 0.5 * 0.7), System.Round(Hole.Star1.MapDiameter * 0.5 * 0.9), (Hole.Star1.GenerationSeed + Self.CurrentTurn + j) * Self.GenerationSeed);
        Hole.Position1 := MakePointF(System.Sin(Angle) * Radius, -System.Cos(Angle) * Radius);
        Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, (Hole.Star2.GenerationSeed + Self.CurrentTurn) * Self.GenerationSeed));
        Radius := SeededRandomIntRange(System.Round(Hole.Star2.MapDiameter * 0.5 * 0.7), System.Round(Hole.Star2.MapDiameter * 0.5 * 0.9), (Hole.Star2.GenerationSeed + Self.CurrentTurn + j) * Self.GenerationSeed);
        Hole.Position2 := MakePointF(System.Sin(Angle) * Radius, -System.Cos(Angle) * Radius);
        if Self.CoalitionDefeatedTurn = 0 then
          Self.AddPlanetNews(36, FormatText2(PickLocalizedTextVariant('GalaxyNews.BlackHole.Create', (Hole.Star1.GenerationSeed + Self.CurrentTurn) * Self.GenerationSeed), '<color=255,240,100>', '<Star1>', Hole.Star1.Name, '<Star2>', Hole.Star2.Name));
      end;
    end;
  end;
  Self.ProcessPlayerSatelliteExploration;
  if Self.TerronSeriesResolvedTurn = 0 then
  begin
    if aKling.TerronShip = nil then
    begin
      Self.TerronSeriesResolvedTurn := Self.CurrentTurn;
      if (GetPlayer <> nil) and (Self.TerronLandingLockTurn <> 0) then TryUnlockAchievement('TERRONBATTLE');
    end
    else if Self.TerronToStarTurn <> 0 then
    begin
      Self.TerronSeriesResolvedTurn := Self.CurrentTurn;
      if GetPlayer <> nil then TryUnlockAchievement('TERRONSTAR');
    end;
    if Self.TerronSeriesResolvedTurn <> 0 then
    begin
      Self.DominatorResearch[2].Progress := 100;
      if Self.CoalitionDefeatedTurn = 0 then
        AddOrUpdatePlayerBubble(pmQuestActive, Self.TerronSeriesResolvedTurn, ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.AddNews'), '<Date>', FormatGameTurnDate(Self.TerronSeriesResolvedTurn), '<color=255,240,100>'), 'TerronWin');
    end;
  end;
  if Self.KellerSeriesResolvedTurn = 0 then
  begin
    if aKling.KellerShip = nil then
    begin
      Self.KellerSeriesResolvedTurn := Self.CurrentTurn;
      if GetPlayer <> nil then TryUnlockAchievement('KELLERDESTROY');
    end
    else if Self.KellerLeaveTurn <> 0 then
    begin
      Self.KellerSeriesResolvedTurn := Self.CurrentTurn;
      if GetPlayer <> nil then TryUnlockAchievement('KELLERRESEARCH');
    end;
    if Self.KellerResearchTargetStarId <> 0 then Self.KellerSeriesResolvedTurn := Self.CurrentTurn;
    if Self.KellerSeriesResolvedTurn <> 0 then
    begin
      Self.DominatorResearch[1].Progress := 100;
      if Self.CoalitionDefeatedTurn = 0 then
        AddOrUpdatePlayerBubble(pmQuestActive, Self.KellerSeriesResolvedTurn, ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.AddNews'), '<Date>', FormatGameTurnDate(Self.KellerSeriesResolvedTurn), '<color=255,240,100>'), 'KellerWin');
    end;
  end;
  if Self.BlazerSeriesResolvedTurn = 0 then
  begin
    if aKling.BlazerShip = nil then
    begin
      Self.BlazerSeriesResolvedTurn := Self.CurrentTurn;
      if GetPlayer <> nil then
      begin
        if Self.BlazerSelfDestructTurn = 0 then TryUnlockAchievement('TERMINATOR')
        else TryUnlockAchievement('BLAZERPROGRAM');
      end;
    end
    else if Self.BlazerLandingPlanetId <> 0 then
    begin
      Self.BlazerSeriesResolvedTurn := Self.CurrentTurn;
      if GetPlayer <> nil then TryUnlockAchievement('BLAZERPIECE');
    end;
    if Self.BlazerSeriesResolvedTurn <> 0 then
    begin
      Self.DominatorResearch[0].Progress := 100;
      if Self.CoalitionDefeatedTurn = 0 then
        AddOrUpdatePlayerBubble(pmQuestActive, Self.BlazerSeriesResolvedTurn, ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.AddNews'), '<Date>', FormatGameTurnDate(Self.BlazerSeriesResolvedTurn), '<color=255,240,100>'), 'BlazerWin');
      if (Self.BlazerLandingPlanetId <> 0) and (aKling.BlazerShip <> nil) and TShip(aKling.BlazerShip).InNormalSpace then
      begin
        aKling.BlazerShip.EnemyShip := nil;
        Star := aKling.BlazerShip.CurrentStar;
        for j := 0 to Star.Ships.Count - 1 do
        begin
          Ship := TShip(Star.Ships[j]);
          if Ship.EnemyShip = aKling.BlazerShip then Ship.EnemyShip := nil;
          if Ship.TruceShip = aKling.BlazerShip then Ship.TruceShip := nil;
          { Native code compares the order target with the galaxy instance. }
          if Ship.OrderTarget = Self then Ship.OrderNone(False);
        end;
        for j := 0 to Star.Missiles.Count - 1 do
        begin
          Missile := TMissile(Star.Missiles[j]);
          Missile.ClearReferencesTo(Self);
        end;
      end;
    end;
  end;
  Self.ProcessCoalitionDefeat;
  if Self.CurrentTurn mod 30 = 0 then Self.AppendIntegritySnapshot;
end;
{ @end $7A463C }

{ @routine $7A531C TGalaxy_TransferShipsInTransit }
procedure TGalaxy.TransferShipsInTransit;
var I, J, Effect: Integer; Ship: TShip; Hole: THole;
begin
  J := ShipsInTransit.Count;
  for I := 0 to J - 1 do begin
    Ship := ShipsInTransit[I];
    if Ship.OrderTarget <> nil then begin
      if Ship = GetPlayer then begin
        repeat Effect := NextRandomIntRange(0, 2, RandomState) until SpaceEffectKind <> Effect;
        SpaceEffectKind := Effect;
      end;
      if Ship.OrderTarget is TStar then Ship.TransferToStar(Ship.OrderTarget as TStar)
      else begin
        Hole := Ship.OrderTarget as THole;
        if Ship.OrderStateData shr 16 = 0 then Ship.TransferToStar(Hole.Star2)
        else Ship.TransferToStar(Hole.Star1);
      end;
    end;
  end;
  ShipsInTransit.Clear;
  if (KellerMissionState = 1) and (KellerShip <> nil) and (KellerTargetStar <> nil) then begin
    if KellerShip.CurrentStar <> KellerTargetStar then begin
      KellerShip.CurrentStar.HandleObjectLeavingStar(KellerShip);
      KellerShip.TransferToStar(KellerTargetStar);
    end;
    KellerMissionState := 2;
  end;
end;
{ @end $7A531C }

{ @routine $7A54B4 TGalaxy_RebuildStarDistances }
procedure TGalaxy.RebuildStarDistances;
var I, J: Integer; Star: TStar;
begin
  J := Stars.Count;
  for I := 0 to J - 1 do begin
    Star := TStar(Stars[I]);
    Star.RebuildStarDistances(Self);
  end;
end;
{ @end $7A54B4 }

{ @routine $7A5504 TGalaxy_RefreshAllShipDerivedState }
procedure TGalaxy.RefreshAllShipDerivedState;
var I, J, K, L: Integer; Star: TStar; Ship: TShip;
begin
  J := Stars.Count;
  for I := 0 to J - 1 do begin
    Star := TStar(Stars[I]);
    L := Star.Ships.Count;
    for K := 0 to L - 1 do begin
      Ship := TShip(Star.Ships[K]);
      Ship.RefreshDerivedStats(True);
      Ship.RefreshGraphicSize;
    end;
  end;
end;
{ @end $7A5504 }

{ @routine $7A5594 TGalaxy_IdToConstellation }
function TGalaxy.IdToConstellation(Id: Cardinal): TConstellation;
var Item: TConstellation; I: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
  for I := 0 to Constellations.Count - 1 do begin
    Item := TConstellation(Constellations[I]);
    if Item.Id = Id then begin Result := Item; Exit; end;
  end;
  raise Exception.Create('function TGalaxy.IdToConstellation (id: Cardinal): TObject;');
end;
{ @end $7A5594 }

{ @routine $7A5658 TGalaxy_IdToStar }
function TGalaxy.IdToStar(Id: Cardinal): TStar;
var Item: TStar; I, Count: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
    if (Cardinal(Stars.Count) >= Id) and (TStar(Stars[Id - 1]).Id = Id) then begin
      Result := TStar(Stars[Id - 1]);
      Exit;
    end;
  Count := Stars.Count;
  for I := 0 to Count - 1 do begin
    Item := TStar(Stars[I]);
    if Item.Id = Id then begin Result := Item; Exit; end;
  end;
  raise Exception.Create('function TGalaxy.IdToStar (id: Cardinal): TObject;');
end;
{ @end $7A5658 }

{ @routine $7A5750 TGalaxy_IdToHole }
function TGalaxy.IdToHole(Id: Cardinal): THole;
var Item: THole; I, Count: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
  Count := Holes.Count;
  for I := 0 to Count - 1 do begin
    Item := THole(Holes[I]);
    if Item.Id = Id then begin Result := Item; Exit; end;
  end;
  raise Exception.Create('function TGalaxy.IdToHole (id: Cardinal): TObject;');
end;
{ @end $7A5750 }

{ @routine $7A580C TGalaxy_IdToPlanet }
function TGalaxy.IdToPlanet(Id: Cardinal; RaiseIfMissing: Boolean): Pointer;
var Star: TStar; Planet: TPlanet; I, StarCount, J, PlanetCount: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
  if (Cardinal(Planets.Count) >= Id) and (Cardinal(TPlanet(Planets[Id - 1]).Id) = Id) then
  begin
    Result := Planets[Id - 1];
    Exit;
  end;
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do
  begin
    Star := TStar(Stars[I]);
    PlanetCount := Star.Planets.Count;
    for J := 0 to PlanetCount - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      if Cardinal(Planet.Id) = Id then
      begin
        Result := Planet;
        Exit;
      end;
    end;
  end;
  if RaiseIfMissing then raise Exception.Create('function TGalaxy.IdToPlanet (id: Cardinal; exc: boolean = True): TObject;')
  else Result := nil;
end;
{ @end $7A580C }

{ @routine $7A5968 TGalaxy_IdToShip }
function TGalaxy.IdToShip(Id: Cardinal; RaiseIfMissing: Boolean): Pointer;
var
  Star: TStar; Planet: TPlanet; Ship: TShip;
  I, StarCount, J, Count, K, ArtefactCount: Integer;
  Item: TItem; Artefact: TArtefact; Storage: PStorageEntry;
begin
  Result := nil;
  if Id = 0 then Exit;
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do
  begin
    Star := TStar(Stars[I]);
    Count := Star.Ships.Count;
    for J := 0 to Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if Cardinal(Ship.Id) = Id then
      begin
        Result := Ship;
        Exit;
      end;
      ArtefactCount := Ship.Artefacts.Count;
      for K := 0 to ArtefactCount - 1 do
      begin
        Artefact := TArtefact(Ship.Artefacts[K]);
        if (Artefact is TArtefactTranclucator) and
           (Cardinal((TObject((Artefact as TArtefactTranclucator).Ship) as TTranclucator).Id) = Id) then
        begin
          Result := (Artefact as TArtefactTranclucator).Ship;
          Exit;
        end;
      end;
    end;
    Count := Star.Planets.Count;
    for J := 0 to Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      ArtefactCount := Planet.Warriors.Count;
      for K := 0 to ArtefactCount - 1 do
      begin
        Ship := TShip(Planet.Warriors[K]);
        if Cardinal(Ship.Id) = Id then
        begin
          Result := Ship;
          Exit;
        end;
      end;
    end;
    Count := Star.Items.Count;
    for J := 0 to Count - 1 do
    begin
      Item := TItem(Star.Items[J]);
      if (Item is TArtefactTranclucator) and (TArtefactTranclucator(Item).Ship <> nil) and
         (Cardinal((TObject(TArtefactTranclucator(Item).Ship) as TTranclucator).Id) = Id) then
      begin
        Result := TArtefactTranclucator(Item).Ship;
        Exit;
      end;
    end;
    Count := Star.MovingDropItems.Count;
    for J := 0 to Count - 1 do
    begin
      Item := TItem(PMovingDropItemEntry(Star.MovingDropItems[J]).Payload);
      if (Item <> nil) and (Item is TArtefactTranclucator) and (TArtefactTranclucator(Item).Ship <> nil) and
         (Cardinal((TObject(TArtefactTranclucator(Item).Ship) as TTranclucator).Id) = Id) then
      begin
        Result := TArtefactTranclucator(Item).Ship;
        Exit;
      end;
    end;
  end;
  for I := 0 to GetPlayer.StorageEntries.Count - 1 do
  begin
    Storage := GetPlayer.StorageEntries[I];
    Item := Storage.Item;
    if (Item is TArtefactTranclucator) and (TArtefactTranclucator(Item).Ship <> nil) and
       (Cardinal((TObject(TArtefactTranclucator(Item).Ship) as TTranclucator).Id) = Id) then
    begin
      Result := TArtefactTranclucator(Item).Ship;
      Exit;
    end;
  end;
  if RaiseIfMissing then raise Exception.Create('function TGalaxy.IdToShip, id = ' + IntToStr(Id))
  else Result := nil;
end;
{ @end $7A5968 }

{ @routine $7A5D64 TGalaxy_IdToItem }
function TGalaxy.IdToItem(Id: Cardinal; RaiseIfMissing: Boolean): Pointer;
var
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;
  Item: TItem;
  Storage: PStorageEntry;
  Stored: TStoredItem;
  Drop: PMovingDropItemEntry;
  i, StarCount, j, ListCount, k, SubCount: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
  StarCount := Self.Stars.Count;
  for i := 0 to StarCount - 1 do
  begin
    Star := TStar(Self.Stars[i]);
    ListCount := Star.Items.Count;
    for j := 0 to ListCount - 1 do
    begin
      Item := TItem(Star.Items[j]);
      if Cardinal(Item.Id) = Id then
      begin
        Result := Item;
        Exit;
      end;
      if Item is TArtefactTranclucator then
      begin
        Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
        if Result <> nil then Exit;
      end;
    end;
    ListCount := Star.MovingDropItems.Count;
    for j := 0 to ListCount - 1 do
    begin
      Drop := PMovingDropItemEntry(Star.MovingDropItems[j]);
      Item := Drop^.Payload as TItem;
      if Item = nil then Continue;
      if Cardinal(Item.Id) = Id then
      begin
        Result := Item;
        Exit;
      end;
      if Item is TArtefactTranclucator then
      begin
        Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
        if Result <> nil then Exit;
      end;
    end;
    ListCount := Star.Ships.Count;
    for j := 0 to ListCount - 1 do
    begin
      Ship := TShip(Star.Ships[j]);
      Item := Ship.FindCarriedItemById(Id);
      if Item <> nil then
      begin
        Result := Item;
        Exit;
      end;
      if (Ship.TypeId = stRanger) and (Ship is TPlayer) then
        for k := 0 to TPlayer(Ship).StorageEntries.Count - 1 do
        begin
          Storage := PStorageEntry(TPlayer(Ship).StorageEntries[k]);
          Item := Storage^.Item;
          if Cardinal(Item.Id) = Id then
          begin
            Result := Item;
            Exit;
          end;
          if Item is TArtefactTranclucator then
          begin
            Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
            if Result <> nil then Exit;
          end;
        end;
    end;
    ListCount := Star.Planets.Count;
    for j := 0 to ListCount - 1 do
    begin
      Planet := TPlanet(Star.Planets[j]);
      SubCount := Planet.Warriors.Count;
      for k := 0 to SubCount - 1 do
      begin
        Ship := TShip(Planet.Warriors[k]);
        Item := Ship.FindCarriedItemById(Id);
        if Item <> nil then
        begin
          Result := Item;
          Exit;
        end;
      end;
      SubCount := Planet.EquipmentShop.Count;
      for k := 0 to SubCount - 1 do
      begin
        Item := TItem(Planet.EquipmentShop[k]);
        if Cardinal(Item.Id) = Id then
        begin
          Result := Item;
          Exit;
        end;
        if Item is TArtefactTranclucator then
        begin
          Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
          if Result <> nil then Exit;
        end;
      end;
      if Planet.SurfaceLootEntries <> nil then
      begin
        SubCount := Planet.SurfaceLootEntries.Count;
        for k := 0 to SubCount - 1 do
        begin
          if Planet.SurfaceLootEntries[k] = nil then Continue;
          Item := PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[k])^.Item;
          if Cardinal(Item.Id) = Id then
          begin
            Result := Item;
            Exit;
          end;
          if Item is TArtefactTranclucator then
          begin
            Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
            if Result <> nil then Exit;
          end;
        end;
      end;
    end;
  end;
  if fEquipmentShop.TemporaryShopSlots <> nil then
    for i := 0 to fEquipmentShop.TemporaryShopSlots.Count - 1 do
      if TShopSlot(fEquipmentShop.TemporaryShopSlots[i]).Item <> nil then
        if Cardinal(TShopSlot(fEquipmentShop.TemporaryShopSlots[i]).Item.Id) = Id then
        begin
          Result := TShopSlot(fEquipmentShop.TemporaryShopSlots[i]).Item;
          Exit;
        end;
  for k := 0 to Self.StoredItems.Count - 1 do
  begin
    Stored := TStoredItem(Self.StoredItems[k]);
    if Stored.Item = nil then Continue;
    Item := TObject(Stored.Item) as TItem;
    if Cardinal(Item.Id) = Id then
    begin
      Result := Stored.Item;
      Exit;
    end;
    if Item is TArtefactTranclucator then
    begin
      Result := TShip((Item as TArtefactTranclucator).Ship).FindCarriedItemById(Id);
      if Result <> nil then Exit;
    end;
  end;
  if RaiseIfMissing then
  begin
    raise SysUtils.Exception.Create('function TGalaxy.IdToItem, id = ' + SysUtils.IntToStr(Int64(Id)));
    Exit;
  end;
  Result := nil;
end;
{ @end $7A5D64 }

{ @routine $7A63A8 TGalaxy_IdToAsteroid }
function TGalaxy.IdToAsteroid(Id: Cardinal): Pointer;
var Star: TStar; Item: TAsteroid; I, StarCount, J, Count: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do
  begin
    Star := TStar(Stars[I]);
    Count := Star.Asteroids.Count;
    for J := 0 to Count - 1 do
    begin
      Item := TAsteroid(Star.Asteroids[J]);
      if Cardinal(Item.Id) = Id then
      begin
        Result := Item;
        Exit;
      end;
    end;
  end;
end;
{ @end $7A63A8 }

{ @routine $7A6450 TGalaxy_IdToMissile }
function TGalaxy.IdToMissile(Id: Cardinal): Pointer;
var Star: TStar; Item: TMissile; I, StarCount, J, Count: Integer;
begin
  Result := nil;
  if Id = 0 then Exit;
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do
  begin
    Star := TStar(Stars[I]);
    Count := Star.Missiles.Count;
    for J := 0 to Count - 1 do
    begin
      Item := TMissile(Star.Missiles[J]);
      if Cardinal(Item.Id) = Id then
      begin
        Result := Item;
        Exit;
      end;
    end;
  end;
end;
{ @end $7A6450 }

{ @routine $7A64F8 TGalaxy_ContainsShipReference }
function TGalaxy.ContainsShipReference(Ship: Pointer): Boolean;
var Star: TStar; Planet: TPlanet; OtherShip: TShip; I, StarCount, J, ItemCount, K, ChildCount: Integer; Item: TItem;
begin
  Result := True;
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do begin
    Star := TStar(Stars[I]);
    ItemCount := Star.Ships.Count;
    for J := 0 to ItemCount - 1 do begin
      OtherShip := TShip(Star.Ships[J]);
      if OtherShip = Ship then Exit;
      ChildCount := OtherShip.Artefacts.Count;
      for K := 0 to ChildCount - 1 do begin
        Item := TItem(OtherShip.Artefacts[K]);
        if (Item is TArtefactTranclucator) and
          ((TObject((Item as TArtefactTranclucator).Ship) as TTranclucator) = Ship) then Exit;
      end;
    end;
    ItemCount := Star.Planets.Count;
    for J := 0 to ItemCount - 1 do begin
      Planet := TPlanet(Star.Planets[J]);
      ChildCount := Planet.Warriors.Count;
      for K := 0 to ChildCount - 1 do begin
        OtherShip := TShip(Planet.Warriors[K]);
        if OtherShip = Ship then Exit;
      end;
    end;
  end;
  Result := False;
end;
{ @end $7A64F8 }

{ @routine $7A6694 TGalaxy_ContainsPlanetReference }
function TGalaxy.ContainsPlanetReference(Planet: Pointer): Boolean;
var Star: TStar; UnusedPlanet: TPlanet; I, StarCount, J, PlanetCount: Integer;
begin
  Result := True;
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do begin
    Star := TStar(Stars[I]);
    PlanetCount := Star.Planets.Count;
    for J := 0 to PlanetCount - 1 do begin
      UnusedPlanet := TPlanet(Star.Planets[J]);
      if UnusedPlanet = Planet then Exit;
    end;
  end;
  Result := False;
end;
{ @end $7A6694 }

{ @routine $7A6728 TGalaxy_ClearJumpGates }
procedure TGalaxy.ClearJumpGates;
var I: Integer; Entry: PJumpGateEntry;
begin
  for I := 0 to JumpGates.Count - 1 do
  begin
    Entry := JumpGates[I];
    if Entry.Gate <> nil then
    begin
      Entry.Gate.DetachFromSpace;
      ReleaseSpaceObject(Entry.Gate);
    end;
    if Entry.Effect <> nil then
    begin
      Entry.Effect.DetachFromSpace;
      ReleaseSpaceObject(Entry.Effect);
    end;
    FreeEC(Entry);
  end;
  JumpGates.Clear;
end;
{ @end $7A6728 }

{ @routine $7A67BC TGalaxy_CreateJumpGate }
function TGalaxy.CreateJumpGate(WithEffect: Boolean): PJumpGateEntry;
var Entry: PJumpGateEntry;
begin
  Entry := AllocClearEC(SizeOf(TJumpGateEntry));
  JumpGates.Add(Entry);
  Entry.UsedThisTurn := False;
  RetainSpaceObject(Entry.Gate, TGateSE.Create('Gate', Classes.Point(0, 0)));
  if WithEffect then RetainSpaceObject(Entry.Effect, TGateEffectSE.Create('Effect.GateEffect', Classes.Point(0, 0)))
  else Entry.Effect := nil;
  Result := Entry;
end;
{ @end $7A67BC }

{ @routine $7A689C TGalaxy_FindHoleInStarByKind }
function TGalaxy.FindHoleInStarByKind(Star: TStar; HoleKind: Integer): THole;
var I: Integer; Hole: THole;
begin
  for I := 0 to Holes.Count - 1 do
  begin
    Hole := THole(Holes[I]);
    if (Hole.HoleType = HoleKind) and ((Hole.Star1 = Star) or (Hole.Star2 = Star)) then
    begin
      Result := Hole;
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $7A689C }

{ @routine $7A6914 TGalaxy_ReleaseItemGraphics }
procedure TGalaxy.ReleaseItemGraphics;
var Star: TStar; Ship: TShip; Item: TItem; StarCount, ShipCount, ItemCount, I, J, K: Integer;
begin
  StarCount := Stars.Count;
  for I := 0 to StarCount - 1 do
  begin
    Star := TStar(Stars[I]);
    ItemCount := Star.Items.Count;
    for K := 0 to ItemCount - 1 do
    begin
      Item := TItem(Star.Items[K]);
      if Item.GraphObject <> nil then ReleaseSpaceObject(Item.GraphObject);
    end;
    ShipCount := Star.Ships.Count;
    for J := 0 to ShipCount - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      ItemCount := Ship.Inventory.Count;
      for K := 0 to ItemCount - 1 do
      begin
        Item := TItem(Ship.Inventory[K]);
        if Item.GraphObject <> nil then ReleaseSpaceObject(Item.GraphObject);
      end;
      ItemCount := Ship.Artefacts.Count;
      for K := 0 to ItemCount - 1 do
      begin
        Item := TItem(Ship.Artefacts[K]);
        if Item.GraphObject <> nil then ReleaseSpaceObject(Item.GraphObject);
      end;
    end;
  end;
end;
{ @end $7A6914 }

{ @routine $7A6AE4 TGalaxy_GenerateSpaceBackground }
procedure TGalaxy.GenerateSpaceBackground(BackgroundIndex: Integer);
const
  MinGroupCount = 4;
  MaxNearGroupCount = 5;
  MaxFarGroupCount = 6;
var
  EntryIndex, Capacity: Integer;
  I, GroupCount, GroupSize, J, K, ImageKind: Integer;
  OrbitStep, Angle1, Angle2, Radius, Angle, DepthRange: Double;
  MinRadius, MaxRadius, StarRadius: Integer;
  RadiusFraction, Density: Single;
  LayerIndex, OffsetX, OffsetY, Quadrant: Integer;
  NearDepth, FarDepth, DepthScale: Single;
  ImageKindCount: Integer;
  Style: WideString;
  Center: TVector3D;
  ImageKinds: array[0..10] of Integer;

  // @nested $7A6A94 AdvanceEntry
  procedure AdvanceEntry; // @addr 0x7A6A94 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; entry index -4, capacity -8, galaxy -12."
  begin
    Inc(EntryIndex);
    if EntryIndex + 1 > Capacity then
    begin
      Capacity := EntryIndex + 100;
      SetLength(SpaceBackgroundEntries, Capacity);
    end;
  end;

begin
  MinRadius := TStar(Stars[0]).MapDiameter;
  MaxRadius := MinRadius;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    StarRadius := TStar(Stars[I]).MapDiameter;
    MinRadius := Min(MinRadius, StarRadius);
    MaxRadius := Max(MaxRadius, StarRadius);
  end;
  MinRadius := MinRadius div 2;
  MaxRadius := MaxRadius div 2;
  StarRadius := PlayerStar.MapDiameter div 2;
  // The native formula requires differing extrema; retain that assumption.
  RadiusFraction := (PlayerStar.MapDiameter div 2 - MinRadius) / (MaxRadius - MinRadius);
  if SpaceImage <= 1 then Density := 0.5 else Density := 1;
  EntryIndex := 0;
  Capacity := 500;
  NearDepth := RemapClamped(PlayerStar.MapDiameter div 2, MinRadius, MaxRadius, 5.1, 7.1);
  FarDepth := RemapClamped(PlayerStar.MapDiameter div 2, MinRadius, MaxRadius, 7, 10);
  DepthScale := RemapClamped(PlayerStar.MapDiameter div 2, MinRadius, MaxRadius, 1, 1.5);
  SetLength(SpaceBackgroundEntries, Capacity);
  if BackgroundIndex < 10 then Style := GameDataConfig.GetBlockByPath('StyleGarbage').GetParam('0' + IntToStr(BackgroundIndex))
  else Style := GameDataConfig.GetBlockByPath('StyleGarbage').GetParam(IntToStr(BackgroundIndex));
  ImageKindCount := CountDelimitedPartsW(Style, ',');
  for I := 0 to ImageKindCount - 1 do ImageKinds[I] := ExtractDigitsToIntW(ExtractDelimitedPartW(Style, I, ','));
  GroupCount := Round((RadiusFraction * (MaxNearGroupCount - MinGroupCount) + MinGroupCount) * Density);
  Quadrant := 0;
  for I := 0 to GroupCount - 1 do
  begin
    J := Round(RandomFloatRange(0, 1) * (StarRadius * 0.6));
    case Quadrant of
      0: begin
           Center.X := RandomFloatRange(0.1, 0.2) * StarRadius * (RandomIntRange(0, 1) * 2 - 1);
           Center.Y := RandomFloatRange(0.1, 0.2) * StarRadius * (RandomIntRange(0, 1) * 2 - 1);
           Quadrant := RandomIntRange(1, 4);
         end;
      1: begin
           Center.X := RandomFloatRange(0.6, 1.5) * StarRadius;
           Center.Y := -RandomFloatRange(0.6, 1.5) * StarRadius + J;
         end;
      2: begin
           Center.X := RandomFloatRange(0.6, 1.5) * StarRadius - J;
           Center.Y := RandomFloatRange(0.6, 1.5) * StarRadius;
         end;
      3: begin
           Center.X := -RandomFloatRange(0.6, 1.5) * StarRadius;
           Center.Y := RandomFloatRange(0.6, 1.5) * StarRadius - J;
         end;
      4: begin
           Center.X := -RandomFloatRange(0.6, 1.5) * StarRadius + J;
           Center.Y := -RandomFloatRange(0.6, 1.5) * StarRadius;
         end;
    end;
    IncrementWrapped(Quadrant, 1, 4);
    Center.Z := RandomFloatRange(0.9, 1.9);
    ImageKind := ImageKinds[RandomIntRange(0, ImageKindCount - 1)];
    LayerIndex := 0;
    for J := 0 to 5 do
    begin
      OffsetX := Round(RandomIntRange(-100, 100));
      OffsetY := Round(RandomIntRange(-100, 100));
      for K := 0 to 1 do
      begin
        Inc(LayerIndex);
        SpaceBackgroundEntries[EntryIndex].ImageIndex := SelectSpaceImageTemplate(ImageKind + 5 - J);
        SpaceBackgroundEntries[EntryIndex].OrbitCenter := Center;
        SpaceBackgroundEntries[EntryIndex].Position.X := RemapClamped(LayerIndex, 1, 8, 1, 5) * OffsetX * DepthScale + (Center.X + RandomIntRange(-100, 100));
        SpaceBackgroundEntries[EntryIndex].Position.Y := RemapClamped(LayerIndex, 1, 10, 1, 5) * OffsetY * DepthScale + (Center.Y + RandomIntRange(-100, 100));
        SpaceBackgroundEntries[EntryIndex].Position.Z := RemapClamped(LayerIndex, 1, 12, NearDepth, FarDepth);
        SpaceBackgroundEntries[EntryIndex].Unknown38 := MakeVector3D(0, 0, 0);
        SpaceBackgroundEntries[EntryIndex].OrbitStepDegrees := 0;
        SpaceBackgroundEntries[EntryIndex].FrameIndex := RandomIntRange(0, 2000000000);
        AdvanceEntry;
      end;
    end;
  end;
  GroupCount := Round((RadiusFraction * (MaxFarGroupCount - MinGroupCount) + MinGroupCount) * Density);
  for I := 0 to GroupCount - 1 do
  begin
    repeat
      J := Round(PlayerStar.MapDiameter * 0.8);
      Center.X := RandomIntRange(-J, J);
      Center.Y := RandomIntRange(-J, J);
      Center.Z := FarDepth + RandomFloatRange(2.05, 3) * DepthScale;
    until Center.X * Center.X + Center.Y * Center.Y > 25;
    DepthRange := RandomFloatRange(4, 10);
    OrbitStep := RandomFloatRange(0.05, 0.1) * (RandomIntRange(0, 1) * 2 - 1);
    Angle1 := HeadingDegreesToRadians(RandomIntRange(0, 360));
    Angle2 := HeadingDegreesToRadians(RandomIntRange(0, 360));
    GroupSize := RandomIntRange(1, 2);
    for J := 0 to GroupSize - 1 do
    begin
      SpaceBackgroundEntries[EntryIndex].Position.Z := Center.Z + RandomFloatRange(0, DepthRange);
      SpaceBackgroundEntries[EntryIndex].ImageIndex := SelectSpaceImageTemplate(1000 + 5 - Round((SpaceBackgroundEntries[EntryIndex].Position.Z - Center.Z) / DepthRange * 5));
      SpaceBackgroundEntries[EntryIndex].OrbitCenter := Center;
      if RandomIntRange(0, 2) = 0 then
      begin
        Radius := RandomIntRange(100, 250);
        Angle := Angle1 + RandomIntRange(-1, 1) * GamePi / 180;
        SpaceBackgroundEntries[EntryIndex].Position.X := Center.X + Sin(Angle) * Radius;
        SpaceBackgroundEntries[EntryIndex].Position.Y := Center.Y - Cos(Angle) * Radius;
      end
      else if RandomIntRange(0, 2) <> 0 then
      begin
        Radius := RandomIntRange(100, 250);
        Angle := Angle2 + RandomIntRange(-3, 3) * GamePi / 180;
        SpaceBackgroundEntries[EntryIndex].Position.X := Center.X + Sin(Angle) * Radius;
        SpaceBackgroundEntries[EntryIndex].Position.Y := Center.Y - Cos(Angle) * Radius;
      end
      else
      begin
        SpaceBackgroundEntries[EntryIndex].Position.X := Center.X + RandomIntRange(-100, 100);
        SpaceBackgroundEntries[EntryIndex].Position.Y := Center.Y + RandomIntRange(-100, 100);
      end;
      SpaceBackgroundEntries[EntryIndex].Unknown38 := MakeVector3D(0, 0, 0);
      SpaceBackgroundEntries[EntryIndex].OrbitStepDegrees := OrbitStep + RandomFloatRange(0.07, 0.1);
      SpaceBackgroundEntries[EntryIndex].FrameIndex := RandomIntRange(0, 2000000000);
      AdvanceEntry;
    end;
  end;
  SetLength(SpaceBackgroundEntries, EntryIndex);
end;
{ @end $7A6AE4 }

{ @routine $7A79B0 TGalaxy_EnableDominatorSurfaces }
procedure TGalaxy.EnableDominatorSurfaces;
var I, J, K: Integer; Star: TStar; Planet: TPlanet;
begin
  if GraphDominatorSurfacesEnabled then Exit;
  GraphDominatorSurfacesEnabled := True;
  for I := 0 to Stars.Count - 1 do
  begin
    Star := TStar(Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do TShip(Star.Ships[J]).RefreshGraphic;
    for K := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[K]);
      for J := 0 to Planet.Warriors.Count - 1 do TShip(Planet.Warriors[J]).RefreshGraphic;
    end;
  end;
end;
{ @end $7A79B0 }

{ @routine $7A7AB4 TGalaxy_DisableDominatorSurfaces }
procedure TGalaxy.DisableDominatorSurfaces;
var I, J, K: Integer; Star: TStar; Planet: TPlanet;
begin
  if not GraphDominatorSurfacesEnabled then Exit;
  GraphDominatorSurfacesEnabled := False;
  for I := 0 to Stars.Count - 1 do
  begin
    Star := TStar(Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do TShip(Star.Ships[J]).RefreshGraphic;
    for K := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[K]);
      for J := 0 to Planet.Warriors.Count - 1 do TShip(Planet.Warriors[J]).RefreshGraphic;
    end;
  end;
end;
{ @end $7A7AB4 }

{ @routine $7A7E84 TGalaxy_XorProtectedState }
procedure TGalaxy.XorProtectedState(Seed: Integer);
type
  PUInt64 = ^UInt64;
  TUInt64Words = packed record
    Low, High: Cardinal;
  end;
var ExclusionCount: Integer; Exclusions: array[0..10] of Cardinal;
  I, J, K, L: Integer; Star: TStar; Planet: TPlanet; Good: Byte;
  Asteroid: TAsteroid; Ship: TShip; RangerQuest: PQuest; Quest: TTextQuest;
  Parameter: TParameter; Location: TLocation; Change: TParameterDelta; Path: TPath;
  Storage: PStorageEntry; Player: TPlayer;
  UnusedLocalBytes: array[0..7] of Byte; // Native frame retains eight unreferenced bytes.

  // @nested $7A7BB8 NextStateXorMask
  function NextStateXorMask: Cardinal; // @addr 0x7A7BB8 @note "Park-Miller state at ParentFrame-4; returns the updated state minus one."
  begin
    Seed := SeedRngMultiplier * (Seed mod SeedRngQuotient) - SeedRngRemainder * (Seed div SeedRngQuotient);
    if Seed <= 0 then Inc(Seed, SeedRngModulus);
    Result := Seed - 1;
  end;

  // @nested $7A7C14 XorStateUInt64
  procedure XorStateUInt64(var Value: UInt64); // @addr 0x7A7C14
  begin
    PCardinal(@TUInt64Words(Value).Low)^ := PCardinal(@TUInt64Words(Value).Low)^ xor NextStateXorMask;
    PCardinal(@TUInt64Words(Value).High)^ := PCardinal(@TUInt64Words(Value).High)^ xor NextStateXorMask;
  end;

  // @nested $7A7C40 XorStateUInt32
  procedure XorStateUInt32(var Value: Cardinal); // @addr 0x7A7C40
  begin Value := Value xor NextStateXorMask; end;

  // @nested $7A7C5C XorStateByte
  procedure XorStateByte(var Value: Byte); // @addr 0x7A7C5C
  begin Value := Value xor Byte(NextStateXorMask); end;

  // @nested $7A7C78 XorStateWords
  procedure XorStateWords(Data: PWord; Count: Cardinal); // @addr 0x7A7C78
  var I: Integer;
  begin
    I := 0;
    while Cardinal(I) < Count do begin
      Data^ := Data^ xor Word(NextStateXorMask);
      Data := Pointer(Cardinal(Data) + SizeOf(Data^));
      Inc(I);
    end;
  end;

  // @nested $7A7CB4 XorStateBytes
  procedure XorStateBytes(Data: PByte; Count: Cardinal); // @addr 0x7A7CB4
  var I: Integer;
  begin
    I := 0;
    while Cardinal(I) < Count do begin
      Data^ := Data^ xor Byte(NextStateXorMask);
      Data := Pointer(Cardinal(Data) + SizeOf(Data^));
      Inc(I);
    end;
  end;

  // @nested $7A7CEC XorStateObject
  procedure XorStateObject(Instance: TObject); // @addr 0x7A7CEC @note "Preserves the VMT pointer."
  begin
    XorStateBytes(PByte(PAnsiChar(Instance) + 4), Instance.InstanceSize - 4);
  end;

  // @nested $7A7D18 XorStateObjectExceptField
  procedure XorStateObjectExceptField(Instance: TObject; ExcludedField: Pointer); // @addr 0x7A7D18 @note "Preserves the VMT and one four-byte field."
  var Data, Excluded, Limit: Cardinal;
  begin
    Data := Cardinal(Instance) + 4;
    Excluded := Cardinal(ExcludedField);
    Limit := Data + Cardinal(Instance.InstanceSize - 4);
    if (Excluded < Data) or (Excluded + 4 >= Limit) then RaiseWideMessage('-');
    XorStateBytes(PByte(Data), Excluded - Data);
    XorStateBytes(PByte(Excluded + 4), Limit - (Excluded + 4));
  end;

  // @nested $7A7DA0 XorStateObjectExceptFields
  procedure XorStateObjectExceptFields(Instance: TObject); // @addr 0x7A7DA0 @note "Preserves the VMT and sorted four-byte exclusions supplied by the parent frame."
  var I: Integer; Data, Limit: Cardinal;
  begin
    Data := Cardinal(Instance) + 4;
    Limit := Data + Cardinal(Instance.InstanceSize - 4);
    if ExclusionCount < 2 then RaiseWideMessage('-');
    if (Exclusions[0] < Data) or (Exclusions[ExclusionCount - 1] + 4 >= Limit) then RaiseWideMessage('-');
    for I := 0 to ExclusionCount - 1 do begin
      if Exclusions[I] < Data then RaiseWideMessage('-');
      XorStateBytes(PByte(Data), Exclusions[I] - Data);
      Data := Exclusions[I] + 4;
    end;
    XorStateBytes(PByte(Data), Limit - Data);
  end;
begin
  Player := nil;
  XorStateUInt32(PCardinal(@PendingEquipmentPurchasePrice)^);
  XorStateUInt32(PCardinal(@CurrentTurn)^);
  XorStateUInt32(PCardinal(@AverageRangerCapital)^);
  XorStateUInt32(PCardinal(@MaxRangerWealth)^);
  XorStateUInt32(PCardinal(@AverageRangerStrength)^);
  XorStateUInt32(PCardinal(@BestRangerStrength)^);
  XorStateUInt32(PCardinal(@ChecksumScalarD0)^);
  XorStateUInt32(PCardinal(@ChecksumScalarEC)^);
  XorStateByte(PByte(@TechLevel)^);
  for I := 0 to Stars.Count - 1 do begin
    Star := TStar(Stars[I]);
    ExclusionCount := 0;
    Exclusions[ExclusionCount] := Cardinal(@Star.Planets);
    Inc(ExclusionCount);
    Exclusions[ExclusionCount] := Cardinal(@Star.Asteroids);
    Inc(ExclusionCount);
    Exclusions[ExclusionCount] := Cardinal(@Star.Ships);
    Inc(ExclusionCount);
    Exclusions[ExclusionCount] := Cardinal(@Star.Items);
    Inc(ExclusionCount);
    Exclusions[ExclusionCount] := Cardinal(@Star.MovingDropItems);
    Inc(ExclusionCount);
    XorStateObjectExceptFields(Star);
    for J := 0 to Star.Items.Count - 1 do XorStateObject(Star.Items[J]);
    if Star.MovingDropItems <> nil then
      for J := 0 to Star.MovingDropItems.Count - 1 do
        if PMovingDropItemEntry(Star.MovingDropItems[J]).Payload is TItem then
          XorStateObject(PMovingDropItemEntry(Star.MovingDropItems[J]).Payload as TItem);
    for J := 0 to Star.Asteroids.Count - 1 do begin
      Asteroid := TAsteroid(Star.Asteroids[J]);
      XorStateUInt32(PCardinal(@Asteroid.MineralCount)^);
    end;
    for J := 0 to Star.Planets.Count - 1 do begin
      Planet := TPlanet(Star.Planets[J]);
      XorStateObjectExceptField(Planet, @Planet.EquipmentShop);
      for K := 0 to Planet.EquipmentShop.Count - 1 do XorStateObject(Planet.EquipmentShop[K]);
    end;
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := TShip(Star.Ships[J]);
      ExclusionCount := 0;
      Exclusions[ExclusionCount] := Cardinal(@Ship.Inventory);
      Inc(ExclusionCount);
      Exclusions[ExclusionCount] := Cardinal(@Ship.Artefacts);
      Inc(ExclusionCount);
      if Ship is TRuins then begin
        Exclusions[ExclusionCount] := Cardinal(@(Ship as TRuins).EquipmentShop);
        Inc(ExclusionCount);
      end;
      if Ship is TRanger then begin
        Exclusions[ExclusionCount] := Cardinal(@(Ship as TRanger).Quests);
        Inc(ExclusionCount);
      end;
      if Ship is TPlayer then begin
        Exclusions[ExclusionCount] := Cardinal(@TPlayer(Ship).StorageEntries);
        Inc(ExclusionCount);
      end;
      if Ship is TPlayer then begin
        Exclusions[ExclusionCount] := Cardinal(@TPlayer(Ship).Satellites);
        Inc(ExclusionCount);
      end;
      XorStateObjectExceptFields(Ship);
      for K := 0 to Ship.Inventory.Count - 1 do XorStateObject(Ship.Inventory[K]);
      for K := 0 to Ship.Artefacts.Count - 1 do XorStateObject(Ship.Artefacts[K]);
      if Ship is TRuins then
        for K := 0 to (Ship as TRuins).EquipmentShop.Count - 1 do
          XorStateObject(TList((Ship as TRuins).EquipmentShop)[K]);
      if Ship is TRanger then
        if (Ship as TRanger).Quests <> nil then
          for K := 0 to (Ship as TRanger).Quests.Count - 1 do begin
            RangerQuest := (Ship as TRanger).Quests[K];
            if RangerQuest <> nil then begin
              XorStateUInt32(PCardinal(@RangerQuest.DeadlineTurn)^);
              XorStateUInt32(PCardinal(@RangerQuest.RewardMoney)^);
            end;
          end;
      if Ship is TPlayer then begin
        Player := Ship as TPlayer;
        for K := 0 to TPlayer(Ship).StorageEntries.Count - 1 do begin
          Storage := TPlayer(Ship).StorageEntries[K];
          XorStateObject(Storage.Item);
        end;
        for K := 0 to TPlayer(Ship).Satellites.Count - 1 do XorStateObject(TList(TPlayer(Ship).Satellites)[K]);
      end;
    end;
  end;
  if Player <> nil then
    if Player.IsOnPlanet or Player.IsDockedToShip then
      if TemporaryShopSlots <> nil then
        for I := 0 to TemporaryShopSlots.Count - 1 do
          if TShopSlot(TemporaryShopSlots[I]).Item <> nil then
            XorStateObject(TShopSlot(TemporaryShopSlots[I]).Item);
  if Player <> nil then
      if CurrentScreenId = screenPlanetQuest then
      begin
        XorStateUInt32(PCardinal(@PlanetQuestScreen.MoneyLimitComplement)^);
        XorStateUInt32(PCardinal(@PlanetQuestScreen.DaysElapsed)^);
        XorStateUInt32(PCardinal(@PlanetQuestScreen.QuestId)^);
        Quest := PlanetQuestScreen.Quest;
        if Quest <> nil then
        begin
          for J := 1 to Quest.GetParameterCount do
          begin
            Parameter := Quest.GetParameter(J);
            XorStateUInt32(PCardinal(@Parameter.MinValue)^);
            XorStateUInt32(PCardinal(@Parameter.MaxValue)^);
            XorStateUInt32(PCardinal(@Parameter.Value)^);
            XorStateUInt32(PCardinal(@Parameter.CriticalOutcome)^);
            XorStateByte(PByte(@Parameter.Hidden)^);
            XorStateByte(PByte(@Parameter.ShowWhenZero)^);
            XorStateByte(PByte(@Parameter.CriticalAtMinimum)^);
            XorStateByte(PByte(@Parameter.Enabled)^);
            XorStateByte(PByte(@Parameter.IsMoney)^);
          end;
          for J := 1 to Quest.GetLocationCount do
          begin
            Location := Quest.GetLocation(J);
            XorStateWords(PWord(PWideChar(Location.EventExpression.Text)), Length(Location.EventExpression.Text));
            XorStateUInt32(PCardinal(@Location.Days)^);
            XorStateUInt32(PCardinal(@Location.Id)^);
            XorStateByte(PByte(@Location.UseEventExpression)^);
            XorStateUInt32(PCardinal(@Location.NextEventIndex)^);
            XorStateByte(PByte(@Location.IsEmpty)^);
            XorStateByte(PByte(@Location.IsDeath)^);
            XorStateByte(PByte(@Location.IsStart)^);
            XorStateByte(PByte(@Location.IsSuccess)^);
            XorStateByte(PByte(@Location.IsFailure)^);
            XorStateUInt32(PCardinal(@Location.VisitLimit)^);
            XorStateUInt32(PCardinal(@Location.VisitCount)^);
            for K := 1 to Location.GetParameterChangeCount do
            begin
              Change := Location.GetParameterChange(K);
              XorStateWords(PWord(PWideChar(Change.ExpressionText.Text)), Length(Change.ExpressionText.Text));
              for L := 0 to High(Change.ValueConstraint.Values) do XorStateUInt32(PCardinal(@Change.ValueConstraint.Values[L])^);
              for L := 0 to High(Change.MultipleConstraint.Values) do XorStateUInt32(PCardinal(@Change.MultipleConstraint.Values[L])^);
              XorStateUInt32(PCardinal(@Change.MinValue)^);
              XorStateUInt32(PCardinal(@Change.MaxValue)^);
              XorStateUInt32(PCardinal(@Change.ChangeValue)^);
              XorStateByte(PByte(@Change.ChangeByPercent)^);
              XorStateByte(PByte(@Change.SetValue)^);
              XorStateByte(PByte(@Change.UseExpression)^);
              XorStateUInt32(PCardinal(@Change.VisibilityChange)^);
            end;
          end;
          for J := 1 to Quest.GetPathCount do
          begin
            Path := Quest.GetPath(J);
            XorStateWords(PWord(PWideChar(Path.Caption.Text)), Length(Path.Caption.Text));
            XorStateWords(PWord(PWideChar(Path.ConditionExpression.Text)), Length(Path.ConditionExpression.Text));
            XorStateUInt64(PUInt64(@Path.Priority)^);
            XorStateByte(PByte(@Path.IsAutomatic)^);
            XorStateByte(PByte(@Path.AlwaysShow)^);
            XorStateUInt32(PCardinal(@Path.Days)^);
            XorStateUInt32(PCardinal(@Path.DisplayOrder)^);
            XorStateUInt32(PCardinal(@Path.Id)^);
            XorStateUInt32(PCardinal(@Path.TraversalLimit)^);
            XorStateUInt32(PCardinal(@Path.TraversalCount)^);
            XorStateUInt32(PCardinal(@Path.FromLocationId)^);
            XorStateUInt32(PCardinal(@Path.ToLocationId)^);
            for K := 1 to Path.GetParameterChangeCount do
            begin
              Change := Path.GetParameterChange(K);
              XorStateWords(PWord(PWideChar(Change.ExpressionText.Text)), Length(Change.ExpressionText.Text));
              for L := 0 to High(Change.ValueConstraint.Values) do XorStateUInt32(PCardinal(@Change.ValueConstraint.Values[L])^);
              for L := 0 to High(Change.MultipleConstraint.Values) do XorStateUInt32(PCardinal(@Change.MultipleConstraint.Values[L])^);
              XorStateUInt32(PCardinal(@Change.MinValue)^);
              XorStateUInt32(PCardinal(@Change.MaxValue)^);
              XorStateUInt32(PCardinal(@Change.ChangeValue)^);
              XorStateByte(PByte(@Change.ChangeByPercent)^);
              XorStateByte(PByte(@Change.SetValue)^);
              XorStateByte(PByte(@Change.UseExpression)^);
              XorStateUInt32(PCardinal(@Change.VisibilityChange)^);
            end;
          end;
        end;
      end;
  if (CurrentScreenId = screenArcadeBattle) and (PlayerArcadeShip <> nil) then begin
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Health)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.MaxHealth)^);
  for I := 0 to 4 do begin
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].Ammo)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].MaxAmmo)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].RechargePerTick)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].AmmoCost)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].LastFireTick)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].FireIntervalTicks)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Weapons[I].Damage)^);
  end;
  end;
  XorStateUInt32(PCardinal(@ShipScreen.SelectedHoldKind)^);
  XorStateByte(PByte(@ShipScreen.SelectedGoodsIndex)^);
  XorStateUInt32(PCardinal(@ShipScreen.SelectedGoodsQuantity)^);
  XorStateUInt32(PCardinal(@ShipScreen.SelectedGoodsCost)^);
  if (CurrentScreenId = screenShip) and (ShipScreen.SelectedHoldKind in [phkEquipment, phkArtefact]) and
    (ShipScreen.SelectedHoldItem <> nil) then XorStateObject(ShipScreen.SelectedHoldItem);
  XorStateUInt32(PCardinal(@GoodsShopScreen.PartnerCargoLimit)^);
  XorStateUInt32(PCardinal(@GoodsShopScreen.PartnerMoneyLimit)^);
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do begin
  XorStateUInt32(PCardinal(@GoodsShopScreen.TradeRows[Good].Count)^);
  XorStateUInt32(PCardinal(@GoodsShopScreen.TradeRows[Good].MaximumPrice)^);
  XorStateUInt32(PCardinal(@GoodsShopScreen.TradeRows[Good].PurchasePrice)^);
  XorStateUInt32(PCardinal(@GoodsShopScreen.TradeRows[Good].BaseSalePrice)^);
  end;
  XorStateUInt32(PCardinal(@GovernmentScreen.QuestOffer.DeadlineTurn)^);
  XorStateUInt32(PCardinal(@GovernmentScreen.QuestOffer.RewardMoney)^);
  XorStateUInt32(PCardinal(@GovernmentScreen.QuestNegotiationLevel)^);
  XorStateUInt32(PCardinal(@GovernmentScreen.QuestRewardStep)^);
  XorStateUInt32(PCardinal(@GovernmentScreen.QuestDurationStep)^);
  if PlayerArcadeShip <> nil then begin
  XorStateUInt32(PCardinal(@PlayerArcadeShip.Health)^);
  XorStateUInt32(PCardinal(@PlayerArcadeShip.MaxHealth)^);
  end;
  XorStateBytes(@IntegrityDataBegin, Cardinal(@IntegrityDataEnd) - Cardinal(@IntegrityDataBegin));
end;
{ @end $7A7E84 }

{ @routine $7A8D80 TGalaxy_ObfuscateProtectedState }
procedure TGalaxy.ObfuscateProtectedState;
begin
  if GR_Main.CCInterface.GetProtectedStateXorSeed = 0 then begin
    repeat
      GR_Main.CCInterface.SetProtectedStateXorSeed(RandomIntRange(0, 2000000000));
    until GR_Main.CCInterface.GetProtectedStateXorSeed <> 0;
    XorProtectedState(GR_Main.CCInterface.GetProtectedStateXorSeed);
  end;
end;
{ @end $7A8D80 }

{ @routine $7A8DDC TGalaxy_RestoreProtectedState }
procedure TGalaxy.RestoreProtectedState;
begin
  if GR_Main.CCInterface.GetProtectedStateXorSeed <> 0 then
  begin
    XorProtectedState(GR_Main.CCInterface.GetProtectedStateXorSeed);
    GR_Main.CCInterface.SetProtectedStateXorSeed(0);
  end;
end;
{ @end $7A8DDC }

{ @routine $7A9008 TGalaxy_ComputeIntegrityChecksum }
function TGalaxy.ComputeIntegrityChecksum(Mode: Integer): Cardinal;
var
  State: Cardinal;
  I, J, K, L: Integer;
  Star: TStar;
  Planet: TPlanet;
  Good: Byte;
  Asteroid: TAsteroid;
  Ship: TShip;
  Skill: TPilotSkill;
  RangerQuest: PQuest;
  Quest: TTextQuest;
  Parameter: TParameter;
  Location: TLocation;
  Change: TParameterDelta;
  Path: TPath;
  Storage: PStorageEntry;
  UnusedNativeFrame: array[0..3] of Byte; // The native frame has four unreferenced bytes; original type unknown.

  // @nested $7A8E1C AccumulateIntegrityUInt32
  procedure AccumulateIntegrityUInt32(Value: Cardinal); // @addr 0x7A8E1C
  begin
    State := UpdateCrc32(State, @Value, 4);
  end;

  // @nested $7A8E40 AccumulateIntegritySingle
  procedure AccumulateIntegritySingle(Value: Single); // @addr 0x7A8E40 @ida "void __usercall $name(float Value@<^0>, void *ParentFrame@<^4>);" @stackpop 0x4 @calls "0x7A9073 0x7A9080 0x7A9090 0x7A90A0 0x7A9E60"
  begin
    State := UpdateCrc32(State, @Value, 4);
  end;

  // @nested $7A8E60 AccumulateIntegrityDouble
  procedure AccumulateIntegrityDouble(Value: Double); // @addr 0x7A8E60 @ida "void __usercall $name(double Value@<^0>, void *ParentFrame@<^8>);" @stackpop 0x8 @calls "0x7A9BAC"
  begin
    State := UpdateCrc32(State, @Value, 8);
  end;

  // @nested $7A8E80 AccumulateIntegrityByte
  procedure AccumulateIntegrityByte(Value: Byte); // @addr 0x7A8E80
  begin
    State := UpdateCrc32(State, @Value, 1);
  end;

  // @nested $7A8EA4 AccumulateIntegrityBoolean
  procedure AccumulateIntegrityBoolean(Value: Boolean); // @addr 0x7A8EA4
  begin
    State := UpdateCrc32(State, @Value, 1);
  end;

  // @nested $7A8EC8 AccumulateIntegrityWords
  procedure AccumulateIntegrityWords(Data: PWord; Count: Integer); // @addr 0x7A8EC8
  begin
    State := UpdateCrc32(State, Data, Count * 2);
  end;

  // @nested $7A8EF4 AccumulateIntegrityBytes
  procedure AccumulateIntegrityBytes(Data: PByte; Count: Integer); // @addr 0x7A8EF4
  begin
    State := UpdateCrc32(State, Data, Count);
  end;

  // @nested $7A8F1C AccumulateIntegrityObject
  procedure AccumulateIntegrityObject(Instance: TObject); // @addr 0x7A8F1C @note "Excludes the VMT pointer; nil contributes nothing."
  begin
    if Instance <> nil then
      AccumulateIntegrityBytes(PByte(PAnsiChar(Instance) + SizeOf(Pointer)), Instance.InstanceSize - SizeOf(Pointer));
  end;

  // @nested $7A8F4C AccumulateIntegrityItem
  procedure AccumulateIntegrityItem(Item: TItem); // @addr 0x7A8F4C @note "Opaque interface avoids the aItem dependency cycle; the nested body uses TItem. Excludes the VMT and temporarily zeros Graphic plus cached action-code state; nil contributes nothing."
  var SavedGraphic: TObjectSE; SavedCode: Pointer; SavedInitialized: Boolean; Equipment: TEquipmentWithActCode;
  begin
    if Item <> nil then
    begin
      SavedGraphic := Item.GraphObject;
      Item.GraphObject := nil;
      if Item is TEquipmentWithActCode then
      begin
        Equipment := TEquipmentWithActCode(Item);
        SavedCode := Equipment.ActionCode;
        SavedInitialized := Equipment.ActCodeInitialized;
        Equipment.ActionCode := nil;
        Equipment.ActCodeInitialized := False;
        AccumulateIntegrityBytes(PByte(PAnsiChar(Item) + SizeOf(Pointer)), Item.InstanceSize - SizeOf(Pointer));
        Equipment.ActionCode := SavedCode;
        Equipment.ActCodeInitialized := SavedInitialized;
      end
      else AccumulateIntegrityBytes(PByte(PAnsiChar(Item) + SizeOf(Pointer)), Item.InstanceSize - SizeOf(Pointer));
      Item.GraphObject := SavedGraphic;
    end;
  end;

begin
  Result := 0;
  Exit; // Native bypass. The dormant checksum body below is retained and matched.
  State := InitCrc32;
  AccumulateIntegrityUInt32(GetCheatPoints);
  AccumulateIntegrityUInt32(PendingEquipmentPurchasePrice);
  AccumulateIntegrityUInt32(CurrentTurn);
  AccumulateIntegrityUInt32(AverageRangerCapital);
  AccumulateIntegrityUInt32(MaxRangerWealth);
  AccumulateIntegritySingle(AverageRangerStrength);
  AccumulateIntegritySingle(BestRangerStrength);
  AccumulateIntegritySingle(ChecksumScalarD0);
  AccumulateIntegritySingle(ChecksumScalarEC);
  AccumulateIntegrityUInt32(TechLevel);
  AccumulateIntegrityUInt32(TerronSeriesResolvedTurn);
  AccumulateIntegrityUInt32(KellerSeriesResolvedTurn);
  AccumulateIntegrityUInt32(BlazerSeriesResolvedTurn);
  AccumulateIntegrityBoolean(GR_Main.CCInterface.GetTamperDetected);
  AccumulateIntegrityBoolean(GR_Main.CCInterface.GetFlag0A);
  AccumulateIntegrityUInt32(SaveCount);
  AccumulateIntegrityUInt32(LoadCount);
  AccumulateIntegrityBoolean(IronWill);
  AccumulateIntegrityByte(DominatorModLevel);
  AccumulateIntegrityByte(TechnicModEnabled);
  AccumulateIntegrityByte(AmmoModEnabled);
  AccumulateIntegrityByte(GodModEnabled);
  AccumulateIntegrityByte(UltraScanModEnabled);
  AccumulateIntegrityByte(StasisModEnabled);
  AccumulateIntegrityBoolean(CustomRules.Enabled);
  AccumulateIntegrityBoolean(GR_Main.CCInterface.GetEditableStateApplied);
  AccumulateIntegrityBoolean(FinalizationNameEncoded <> '');
  AccumulateIntegrityBytes(@DifficultyLevels, 8);
  for I := 0 to Stars.Count - 1 do
  begin
    Star := TStar(Stars[I]);
    if (Mode = 1) and (Star <> PlayerStar) then Continue;
    if (Mode = 2) and (Star = PlayerStar) then Continue;
    AccumulateIntegrityObject(Star);
    for J := 0 to Star.Items.Count - 1 do AccumulateIntegrityItem(Star.Items[J]);
    if Star.MovingDropItems <> nil then
      for J := 0 to Star.MovingDropItems.Count - 1 do
        if PMovingDropItemEntry(Star.MovingDropItems[J]).Payload is TItem then
          AccumulateIntegrityItem(PMovingDropItemEntry(Star.MovingDropItems[J]).Payload as TItem);
    for J := 0 to Star.Asteroids.Count - 1 do
    begin
      Asteroid := TAsteroid(Star.Asteroids[J]);
      AccumulateIntegrityUInt32(Asteroid.MineralCount);
    end;
    for J := 0 to Star.Missiles.Count - 1 do AccumulateIntegrityObject(TObject(Star.Missiles[J]));
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      AccumulateIntegrityObject(Planet);
      for K := 0 to Planet.EquipmentShop.Count - 1 do AccumulateIntegrityItem(Planet.EquipmentShop[K]);
      if Planet.SurfaceLootEntries <> nil then
        for K := 0 to Planet.SurfaceLootEntries.Count - 1 do
          if PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[K]).Item <> nil then
            AccumulateIntegrityItem(PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[K]).Item);
    end;
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      AccumulateIntegrityObject(Ship);
      for Skill := Low(TPilotSkill) to High(TPilotSkill) do AccumulateIntegrityUInt32(Ship.BaseSkills[Skill]);
      for K := 0 to Ship.Inventory.Count - 1 do AccumulateIntegrityItem(Ship.Inventory[K]);
      for K := 0 to Ship.Artefacts.Count - 1 do AccumulateIntegrityItem(Ship.Artefacts[K]);
      if Ship.GuaranteedDeathDropItems <> nil then
        for K := 0 to Ship.GuaranteedDeathDropItems.Count - 1 do AccumulateIntegrityItem(Ship.GuaranteedDeathDropItems[K]);
      if Ship.StatBonuses <> nil then
        for K := 0 to Ship.StatBonuses.Count - 1 do
        begin
          AccumulateIntegrityUInt32(PShipStatBonusEntry(Ship.StatBonuses[K]).BonusValue);
          AccumulateIntegrityByte(Ord(PShipStatBonusEntry(Ship.StatBonuses[K]).BonusKind));
        end;
      if Ship is TRuins then
        for K := 0 to (Ship as TRuins).EquipmentShop.Count - 1 do
          AccumulateIntegrityItem(TList((Ship as TRuins).EquipmentShop)[K]);
      if Ship is TRanger then
        if (Ship as TRanger).Quests <> nil then
          for K := 0 to (Ship as TRanger).Quests.Count - 1 do
          begin
            RangerQuest := (Ship as TRanger).Quests[K];
            if RangerQuest <> nil then
            begin
              AccumulateIntegrityUInt32(RangerQuest.DeadlineTurn);
              AccumulateIntegrityUInt32(RangerQuest.RewardMoney);
            end;
          end;
      if Ship is TPlayer then
      begin
        for K := 0 to TPlayer(Ship).StorageEntries.Count - 1 do
        begin
          Storage := TPlayer(Ship).StorageEntries[K];
          AccumulateIntegrityItem(Storage.Item);
        end;
        for K := 0 to TPlayer(Ship).Satellites.Count - 1 do AccumulateIntegrityItem(TList(TPlayer(Ship).Satellites)[K]);
      end;
    end;
  end;
  if Mode <> 2 then
    if GetPlayer <> nil then
      if GetPlayer.IsOnPlanet or GetPlayer.IsDockedToShip then
        if TemporaryShopSlots <> nil then
          for I := 0 to TemporaryShopSlots.Count - 1 do
            if TShopSlot(TemporaryShopSlots[I]).Item <> nil then
              AccumulateIntegrityItem(TShopSlot(TemporaryShopSlots[I]).Item);
  if Mode <> 2 then
    if GetPlayer <> nil then
      if CurrentScreenId = screenPlanetQuest then
      begin
        AccumulateIntegrityUInt32(PlanetQuestScreen.MoneyLimitComplement);
        AccumulateIntegrityUInt32(PlanetQuestScreen.DaysElapsed);
        AccumulateIntegrityUInt32(PlanetQuestScreen.QuestId);
        Quest := PlanetQuestScreen.Quest;
        if Quest <> nil then
        begin
          for J := 1 to Quest.GetParameterCount do
          begin
            Parameter := Quest.GetParameter(J);
            AccumulateIntegrityUInt32(Parameter.MinValue);
            AccumulateIntegrityUInt32(Parameter.MaxValue);
            AccumulateIntegrityUInt32(Parameter.Value);
            AccumulateIntegrityUInt32(Cardinal(Parameter.CriticalOutcome));
            AccumulateIntegrityBoolean(Parameter.Hidden);
            AccumulateIntegrityBoolean(Parameter.ShowWhenZero);
            AccumulateIntegrityBoolean(Parameter.CriticalAtMinimum);
            AccumulateIntegrityBoolean(Parameter.Enabled);
            AccumulateIntegrityBoolean(Parameter.IsMoney);
          end;
          for J := 1 to Quest.GetLocationCount do
          begin
            Location := Quest.GetLocation(J);
            AccumulateIntegrityWords(PWord(PWideChar(Location.EventExpression.Text)), Length(Location.EventExpression.Text));
            AccumulateIntegrityUInt32(Location.Days);
            AccumulateIntegrityUInt32(Location.Id);
            AccumulateIntegrityBoolean(Location.UseEventExpression);
            AccumulateIntegrityUInt32(Location.NextEventIndex);
            AccumulateIntegrityBoolean(Location.IsEmpty);
            AccumulateIntegrityBoolean(Location.IsDeath);
            AccumulateIntegrityBoolean(Location.IsStart);
            AccumulateIntegrityBoolean(Location.IsSuccess);
            AccumulateIntegrityBoolean(Location.IsFailure);
            AccumulateIntegrityUInt32(Location.VisitLimit);
            AccumulateIntegrityUInt32(Location.VisitCount);
            for K := 1 to Location.GetParameterChangeCount do
            begin
              Change := Location.GetParameterChange(K);
              AccumulateIntegrityWords(PWord(PWideChar(Change.ExpressionText.Text)), Length(Change.ExpressionText.Text));
              for L := 0 to High(Change.ValueConstraint.Values) do AccumulateIntegrityUInt32(Change.ValueConstraint.Values[L]);
              for L := 0 to High(Change.MultipleConstraint.Values) do AccumulateIntegrityUInt32(Change.MultipleConstraint.Values[L]);
              AccumulateIntegrityUInt32(Change.MinValue);
              AccumulateIntegrityUInt32(Change.MaxValue);
              AccumulateIntegrityUInt32(Change.ChangeValue);
              AccumulateIntegrityBoolean(Change.ChangeByPercent);
              AccumulateIntegrityBoolean(Change.SetValue);
              AccumulateIntegrityBoolean(Change.UseExpression);
              AccumulateIntegrityUInt32(Cardinal(Change.VisibilityChange));
            end;
          end;
          for J := 1 to Quest.GetPathCount do
          begin
            Path := Quest.GetPath(J);
            AccumulateIntegrityWords(PWord(PWideChar(Path.Caption.Text)), Length(Path.Caption.Text));
            AccumulateIntegrityWords(PWord(PWideChar(Path.ConditionExpression.Text)), Length(Path.ConditionExpression.Text));
            AccumulateIntegrityDouble(Path.Priority);
            AccumulateIntegrityBoolean(Path.IsAutomatic);
            AccumulateIntegrityBoolean(Path.AlwaysShow);
            AccumulateIntegrityUInt32(Path.Days);
            AccumulateIntegrityUInt32(Path.DisplayOrder);
            AccumulateIntegrityUInt32(Path.Id);
            AccumulateIntegrityUInt32(Path.TraversalLimit);
            AccumulateIntegrityUInt32(Path.TraversalCount);
            AccumulateIntegrityUInt32(Path.FromLocationId);
            AccumulateIntegrityUInt32(Path.ToLocationId);
            for K := 1 to Path.GetParameterChangeCount do
            begin
              Change := Path.GetParameterChange(K);
              AccumulateIntegrityWords(PWord(PWideChar(Change.ExpressionText.Text)), Length(Change.ExpressionText.Text));
              for L := 0 to High(Change.ValueConstraint.Values) do AccumulateIntegrityUInt32(Change.ValueConstraint.Values[L]);
              for L := 0 to High(Change.MultipleConstraint.Values) do AccumulateIntegrityUInt32(Change.MultipleConstraint.Values[L]);
              AccumulateIntegrityUInt32(Change.MinValue);
              AccumulateIntegrityUInt32(Change.MaxValue);
              AccumulateIntegrityUInt32(Change.ChangeValue);
              AccumulateIntegrityBoolean(Change.ChangeByPercent);
              AccumulateIntegrityBoolean(Change.SetValue);
              AccumulateIntegrityBoolean(Change.UseExpression);
              AccumulateIntegrityUInt32(Cardinal(Change.VisibilityChange));
            end;
          end;
        end;
      end;
  if Mode <> 2 then
  begin
    AccumulateIntegrityUInt32(Cardinal(ShipScreen.SelectedHoldKind));
    AccumulateIntegrityUInt32(ShipScreen.SelectedGoodsIndex);
    AccumulateIntegrityUInt32(ShipScreen.SelectedGoodsQuantity);
    AccumulateIntegrityUInt32(ShipScreen.SelectedGoodsCost);
    if GetInnermostScreenLoop = ShipScreen then
      if ShipScreen.SelectedHoldKind in [phkEquipment, phkArtefact] then
        if ShipScreen.SelectedHoldItem <> nil then AccumulateIntegrityItem(Pointer(ShipScreen.SelectedHoldItem));
    AccumulateIntegrityUInt32(GoodsShopScreen.PartnerCargoLimit);
    AccumulateIntegrityUInt32(GoodsShopScreen.PartnerMoneyLimit);
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    begin
      AccumulateIntegrityUInt32(GoodsShopScreen.TradeRows[Good].Count);
      AccumulateIntegritySingle(GoodsShopScreen.TradeRows[Good].MaximumPrice);
      AccumulateIntegrityUInt32(GoodsShopScreen.TradeRows[Good].PurchasePrice);
      AccumulateIntegrityUInt32(GoodsShopScreen.TradeRows[Good].BaseSalePrice);
    end;
    AccumulateIntegrityUInt32(GovernmentScreen.QuestOffer.DeadlineTurn);
    AccumulateIntegrityUInt32(GovernmentScreen.QuestOffer.RewardMoney);
    AccumulateIntegrityUInt32(GovernmentScreen.QuestNegotiationLevel);
    AccumulateIntegrityUInt32(GovernmentScreen.QuestRewardStep);
    AccumulateIntegrityUInt32(GovernmentScreen.QuestDurationStep);
  end;
  if Mode <> 1 then
    AccumulateIntegrityBytes(@IntegrityDataBegin, Integer(@IntegrityDataEnd) - Integer(@IntegrityDataBegin));
  Result := FinishCrc32(State);
end;
{ @end $7A9008 }

{ @routine $7A9F40 TGalaxy_PrimeIntegrityChecksum }
procedure TGalaxy.PrimeIntegrityChecksum(StatusCode: Integer);
begin
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    WaitForTurnCalculationUI;
    GR_Main.CCInterface.SetIntegrityChecksum(ComputeIntegrityChecksum(0));
    GR_Main.CCInterface.SetIntegrityStatus(StatusCode);
  end;
end;
{ @end $7A9F40 }

{ @routine $7A9F8C TGalaxy_PrimeIntegrityChecksum1 }
procedure TGalaxy.PrimeIntegrityChecksum1(StatusCode: Integer);
begin
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    WaitForTurnCalculationUI;
    GR_Main.CCInterface.SetIntegrityChecksum1(ComputeIntegrityChecksum(1));
    GR_Main.CCInterface.SetIntegrityStatus(StatusCode);
  end;
end;
{ @end $7A9F8C }

{ @routine $7A9FDC TGalaxy_PrimeIntegrityChecksum2 }
procedure TGalaxy.PrimeIntegrityChecksum2(StatusCode: Integer);
begin
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    WaitForTurnCalculationUI;
    GR_Main.CCInterface.SetIntegrityChecksum2(ComputeIntegrityChecksum(2));
    GR_Main.CCInterface.SetIntegrityStatus(StatusCode);
  end;
end;
{ @end $7A9FDC }

{ @routine $7AA02C TGalaxy_CheckIntegrityChecksum }
procedure TGalaxy.CheckIntegrityChecksum(ErrorCode: Integer);
var ResourceError: Integer;
    UnusedNativeFrame: array[0..11] of Byte; // Native reserves these bytes without accessing them; original type is unknown.
begin
  WaitForTurnCalculationUI;
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    if GR_Main.CCInterface.GetResourceChecksumFailed then
    begin
      ResourceError := $1347CC;
      Inc(ResourceError, $B3CB4);
      GR_Main.CCInterface.SetIntegrityError(ResourceError);
    end
    else if GR_Main.CCInterface.GetIntegrityStatus <> 0 then
    begin
      if ComputeIntegrityChecksum(0) <> GR_Main.CCInterface.GetIntegrityChecksum then
        GR_Main.CCInterface.SetIntegrityError(ErrorCode)
      else GR_Main.CCInterface.SetIntegrityStatus(0);
    end;
  end;
end;
{ @end $7AA02C }

{ @routine $7AA0D0 TGalaxy_CheckIntegrityChecksumAndSetStatus }
procedure TGalaxy.CheckIntegrityChecksumAndSetStatus(StatusCode: Integer);
var ResourceError: Integer;
    UnusedNativeFrame: array[0..11] of Byte; // Native reserves these bytes without accessing them; original type is unknown.
begin
  WaitForTurnCalculationUI;
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    if GR_Main.CCInterface.GetResourceChecksumFailed then
    begin
      ResourceError := $1347CC;
      Inc(ResourceError, $B3CB4);
      GR_Main.CCInterface.SetIntegrityError(ResourceError);
    end
    else if GR_Main.CCInterface.GetIntegrityStatus <> 0 then
    begin
      if ComputeIntegrityChecksum(0) <> GR_Main.CCInterface.GetIntegrityChecksum then
        GR_Main.CCInterface.SetIntegrityError(StatusCode)
      else GR_Main.CCInterface.SetIntegrityStatus(StatusCode);
    end;
  end;
end;
{ @end $7AA0D0 }

{ @routine $7AA174 TGalaxy_CheckIntegrityChecksum1 }
procedure TGalaxy.CheckIntegrityChecksum1(ErrorCode: Integer);
var ResourceError: Integer;
begin
  WaitForTurnCalculationUI;
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    if GR_Main.CCInterface.GetResourceChecksumFailed then
    begin
      ResourceError := $1347CC;
      Inc(ResourceError, $B3CB4);
      GR_Main.CCInterface.SetIntegrityError(ResourceError);
    end
    else if GR_Main.CCInterface.GetIntegrityStatus <> 0 then
    begin
      if ComputeIntegrityChecksum(1) <> GR_Main.CCInterface.GetIntegrityChecksum1 then
        GR_Main.CCInterface.SetIntegrityError(ErrorCode)
      else GR_Main.CCInterface.SetIntegrityStatus(0);
    end;
  end;
end;
{ @end $7AA174 }

{ @routine $7AA218 TGalaxy_CheckIntegrityChecksum2 }
procedure TGalaxy.CheckIntegrityChecksum2(ErrorCode: Integer);
var ResourceError: Integer;
begin
  WaitForTurnCalculationUI;
  if GR_Main.CCInterface.GetIntegrityError = 0 then
  begin
    if GR_Main.CCInterface.GetResourceChecksumFailed then
    begin
      ResourceError := $1347CC;
      Inc(ResourceError, $B3CB4);
      GR_Main.CCInterface.SetIntegrityError(ResourceError);
    end
    else if GR_Main.CCInterface.GetIntegrityStatus <> 0 then
    begin
      if ComputeIntegrityChecksum(2) <> GR_Main.CCInterface.GetIntegrityChecksum2 then
        GR_Main.CCInterface.SetIntegrityError(ErrorCode)
      else GR_Main.CCInterface.SetIntegrityStatus(0);
    end;
  end;
end;
{ @end $7AA218 }

{ @routine $7AA2BC TGalaxy_ClearIntegrityStatus }
procedure TGalaxy.ClearIntegrityStatus;
begin
  if GR_Main.CCInterface.GetIntegrityError = 0 then GR_Main.CCInterface.SetIntegrityStatus(0);
end;
{ @end $7AA2BC }

{ @routine $7AA2E4 TGalaxy_AppendIntegritySnapshot }
procedure TGalaxy.AppendIntegritySnapshot;
type
  // Four DWORDs precede the encrypted payload. Size includes this header;
  // Crc32 covers the compressed buffer before encryption. The last word is unresolved.
  TSnapshotHeader = packed record
    Kind: Integer;
    Size: Integer;
    Crc32: Cardinal;
    Unknown0C: Cardinal;
  end;
  PSnapshotHeader = ^TSnapshotHeader;
var Size, StartOffset, Count, I: Integer; Partner: TShip; OldQuest: PPlayerOldQuest;
  CompletedDeliveries, CompletedAssassinations, CompletedTextQuests, CompletedSystemDefenses, CompletedShipDefenses: Word;
  Buffer: TBufEC; Crc: Cardinal; Exponent, Modulus: TFGInt; Bytes: AnsiString; Good: Byte;
begin
  Exit; // Native unconditional bypass; retain the dormant serializer below.
  if GetPlayer = nil then begin end;
  GR_Main.CCInterface.Buffer.SetPosition(GR_Main.CCInterface.Buffer.DataSize);
  StartOffset := GR_Main.CCInterface.Buffer.Position;
  GR_Main.CCInterface.Buffer.AddIntegerValue(13);
  GR_Main.CCInterface.Buffer.AddIntegerValue(0);
  GR_Main.CCInterface.Buffer.AddDWord(0);
  GR_Main.CCInterface.Buffer.AddDWord(0);
  Buffer := TBufEC.Create;
  Buffer.AddIntegerValue(CurrentTurn);
  Buffer.AddBoolean(GR_Main.CCInterface.GetFlag0A);
  Buffer.AddIntegerValue(MaxRangerWealth);
  Buffer.AddSingle(BestRangerStrength);
  Buffer.AddIntegerValue(GetPlayer.Money);
  Buffer.AddIntegerValue(GetPlayer.Wealth);
  Buffer.AddSingle(GetPlayer.Strength);
  Buffer.AddIntegerValue(GetPlayer.NodeReserve);
  Buffer.AddIntegerValue(GetPlayer.TotalExperience);
  Buffer.AddIntegerValue(GetPlayer.ExperienceByDominators);
  Buffer.AddIntegerValue(GetPlayer.ExperienceByPirates);
  Buffer.AddIntegerValue(GetPlayer.ExperienceByNormals);
  Buffer.AddIntegerValue(GetPlayer.ExperienceByTraderCareer);
  Buffer.AddIntegerValue(GetPlayer.FreeExperience);
  Buffer.AddIntegerValue(GetPlayer.CargoFreeSpace);
  Buffer.AddIntegerValue(GetPlayer.Speed);
  Buffer.AddSingle(GetPlayer.DefenseDamageFactor);
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.BaseSkills[psAccuracy]));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.BaseSkills[psManeuverability]));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.BaseSkills[psTechnical]));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.BaseSkills[psTrading]));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.BaseSkills[psCharisma]));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.BaseSkills[psLeadership]));
  Buffer.AddWideChar(WideChar(GetPlayer.PlaceInRating));
  Buffer.AddIntegerValue(GetPlayer.TotalShipKillCount);
  Buffer.AddIntegerValue(GetPlayer.PirateKillCount);
  Buffer.AddIntegerValue(GetPlayer.DominatorKillCount);
  Buffer.AddIntegerValue(GetPlayer.LiberatedSystemCount);
  Buffer.AddWideChar(WideChar(GetPlayer.CurrentSystemKills.Dominator));
  Buffer.AddWideChar(WideChar(GetPlayer.CurrentSystemKills.Pirate));
  Buffer.AddWideChar(WideChar(GetPlayer.CurrentSystemKills.Normal));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.Rank));
  Buffer.AddWideChar(WideChar(GetPlayer.RankPoints));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.PirateClanReal));
  Buffer.AddAnsiChar(AnsiChar(Ord(GetPlayer.OwnerId = oiPirate)));
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.PirateRank));
  Buffer.AddWideChar(WideChar(GetPlayer.PirateRankPoints));
  Buffer.AddIntegerValue(GetPlayer.HyperspaceKillCount);
  Buffer.AddIntegerValue(GetPlayer.BlackHoleKillCount);
  if GetPlayer.AwardIds = nil then Buffer.AddAnsiChar(#0)
  else Buffer.AddAnsiChar(AnsiChar(GetPlayer.AwardIds.Count));
  Buffer.AddAnsiStringZ('TESTBUILD');
  Buffer.AddByte(CountFactionStars(sfCoalition));
  Buffer.AddByte(CountFactionStars(sfPirates));
  Count := 0;
  for I := 0 to Rangers.Count - 1 do begin
    Partner := Rangers[I];
    if (Partner.PartnerShip = GetPlayer) and (Partner.OwnerId in PlanetOwnerMasks.Coalition) then Inc(Count);
  end;
  Buffer.AddAnsiChar(AnsiChar(Count));
  Buffer.AddIntegerValue(GetCheatPoints);
  Buffer.AddIntegerValue(LoadCount);
  CompletedDeliveries := 0;
  CompletedAssassinations := 0;
  CompletedTextQuests := 0;
  CompletedSystemDefenses := 0;
  CompletedShipDefenses := 0;
  if PlayerOldQuests <> nil then
    for I := 0 to PlayerOldQuests.Count - 1 do begin
      OldQuest := PlayerOldQuests[I];
      if OldQuest.Successful then begin
        if OldQuest.QuestType = qtSendLetter then Inc(CompletedDeliveries)
        else if OldQuest.QuestType = qtKillShip then Inc(CompletedAssassinations)
        else if OldQuest.QuestType = qtPlanetQuest then Inc(CompletedTextQuests)
        else if OldQuest.QuestType = qtDefendSystem then Inc(CompletedSystemDefenses)
        else if OldQuest.QuestType = qtDefendShip then Inc(CompletedShipDefenses);
      end;
    end;
  Buffer.AddAnsiChar(AnsiChar(CompletedDeliveries));
  Buffer.AddAnsiChar(AnsiChar(CompletedAssassinations));
  Buffer.AddAnsiChar(AnsiChar(CompletedTextQuests));
  Buffer.AddAnsiChar(AnsiChar(CompletedSystemDefenses));
  Buffer.AddAnsiChar(AnsiChar(CompletedShipDefenses));
  if GR_Main.CCInterface.GetIntegrityError <> 0 then begin
    Buffer.AddIntegerValue(GR_Main.CCInterface.GetValue10);
    Buffer.AddIntegerValue(GR_Main.CCInterface.GetIntegrityStatus);
    Buffer.AddIntegerValue(GR_Main.CCInterface.GetIntegrityError);
  end
  else begin
    Buffer.AddIntegerValue(0);
    Buffer.AddIntegerValue(0);
    Buffer.AddIntegerValue(0);
  end;
  GR_Main.CCInterface.SetValue10(0);
  GR_Main.CCInterface.SetIntegrityStatus(0);
  GR_Main.CCInterface.SetIntegrityError(0);
  Buffer.AddAnsiChar(AnsiChar(GetPlayer.PlanetBattles));
  Buffer.AddAnsiChar(AnsiChar((High(GetPlayer.PlanetBattleHistory) + 1)));
  Buffer.AddWideChar(WideChar(GetPlayer.GetHull.Weight));
  Buffer.AddWideChar(WideChar(GetPlayer.DiseaseContractionCount));
  Buffer.AddWideChar(WideChar(GetPlayer.StimulantPurchaseCount));
  Buffer.AddWideChar(WideChar(GetPlayer.PrisonStaysCompleted));
  Buffer.AddIntegerValue(GetPlayer.SatelliteTilesExplored);
  Buffer.AddWideChar(WideChar(GetPlayer.NationalityChangeCount));
  Buffer.AddWideChar(WideChar(GetPlayer.SideChangeCount));
  Buffer.AddIntegerValue(GetPlayer.UnknownF4);
  for I := 0 to 7 do Buffer.AddAnsiChar(AnsiChar(DifficultyLevels[Byte(I)]));
  Buffer.AddBoolean(GR_Main.CCInterface.GetEditableStateApplied);
  Buffer.AddWideStringZ(FinalizationNameEncoded);
  Buffer.AddBoolean(CustomRules.Enabled);
  for Good := 0 to 7 do Buffer.AddIntegerValue(GetPlayer.DominatorKillsByType[Good]);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.CompressZlibPayloadInPlace(False);
  Crc := Buffer.ComputeCrc32;
  FGIntDecodeBase64('HjwH94fmhClFC1prPy', Bytes);
  FGIntFromBytes(Bytes, Modulus);
  FGIntDecodeBase64('DjAVRGx=', Bytes);
  FGIntFromBytes(Bytes, Exponent);
  SetLength(Bytes, Buffer.DataSize);
  CopyMemory(PAnsiChar(Bytes), Buffer.Data, Buffer.DataSize);
  FGIntEncodeBlocks(Bytes, Exponent, Modulus, Bytes);
  GR_Main.CCInterface.Buffer.AddBytes(PAnsiChar(Bytes), Length(Bytes));
  Size := GR_Main.CCInterface.Buffer.Position - StartOffset;
  PInteger(@PSnapshotHeader(PAnsiChar(GR_Main.CCInterface.Buffer.Data) + StartOffset).Size)^ := Size;
  PCardinal(@PSnapshotHeader(PAnsiChar(GR_Main.CCInterface.Buffer.Data) + StartOffset).Crc32)^ := Crc;
  Buffer.Free;
  FGIntClear(Modulus);
  FGIntClear(Exponent);
end;
{ @end $7AA2E4 }

{ @routine $7AABF0 TGalaxy_HasVisibleScoreModFlags }
function TGalaxy.HasVisibleScoreModFlags: Boolean;
begin
  Result := True;
  if (DominatorModLevel = 0) and (TechnicModEnabled = 0) and (AmmoModEnabled = 0) and
    (GodModEnabled = 0) and (UltraScanModEnabled = 0) and (StasisModEnabled = 0) and
    not GR_Main.CCInterface.GetEditableStateApplied then Result := False;
end;
{ @end $7AABF0 }

{ @routine $7AAC60 TGalaxy_GetCheatPoints }
function TGalaxy.GetCheatPoints: Integer;
begin
  Result := GR_Main.CCInterface.GetEncodedCheatPoints xor GenerationSeed;
end;
{ @end $7AAC60 }

{ @routine $7AAC88 TGalaxy_SetCheatPoints }
procedure TGalaxy.SetCheatPoints(Value: Integer);
begin
  GR_Main.CCInterface.SetEncodedCheatPoints(Value xor GenerationSeed);
end;
{ @end $7AAC88 }

{ @routine $7AACB0 THole_Create }
constructor THole.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextHoleId;
    Inc(Galaxy.NextHoleId);
  end;
end;
{ @end $7AACB0 }

{ @routine $7AAD10 THole_Destroy }
destructor THole.Destroy;
begin
  if Graphic <> nil then ReleaseSpaceObject(Graphic);
  inherited Destroy;
end;
{ @end $7AAD10 }

{ @routine $7AAD58 THole_InitializeGraphic }
procedure THole.InitializeGraphic(GraphKey: WideString);
var
  Block: TBlockParEC;
  Key: WideString;
begin
  Key := GraphKey;
  if Key = '' then
  begin
    Block := GameDataConfig.GetBlockByPath('SE.Hole');
    Key := 'Hole.' + Block.GetBlockNameByIndex(SeededRandomIntRange(0, Block.GetBlockCount - 1, Id + Galaxy.CurrentTurn));
  end;
  RetainSpaceObject(Graphic, CreateSpaceObjectByName('Hole', Key, Classes.Point(0, 0)));
  Graphic.SetPosition(MakePointF(0, 0));
  ArcadeMapName := '';
end;
{ @end $7AAD58 }

{ @routine $7AAE9C THole_SaveToBuffer }
procedure THole.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddDWord(Id);
  Buffer.AddDWord(Star1.Id);
  Buffer.AddSingle(Position1.X);
  Buffer.AddSingle(Position1.Y);
  Buffer.AddDWord(Star2.Id);
  Buffer.AddSingle(Position2.X);
  Buffer.AddSingle(Position2.Y);
  Buffer.AddIntegerValue(CreatedTurn);
  Buffer.AddIntegerValue(HoleType);
  Buffer.AddWideStringZ(Graphic.GraphKey);
  Buffer.AddWideStringZ(ArcadeMapName);
end;
{ @end $7AAE9C }

{ @routine $7AAF50 THole_LoadFromBuffer }
procedure THole.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  Id := Buffer.GetUInt32;
  if Galaxy.NextHoleId <= Id then Galaxy.NextHoleId := Id + 1;
  Star1 := TStar(Buffer.GetUInt32);
  Position1.X := Buffer.GetSingle;
  Position1.Y := Buffer.GetSingle;
  Star2 := TStar(Buffer.GetUInt32);
  Position2.X := Buffer.GetSingle;
  Position2.Y := Buffer.GetSingle;
  CreatedTurn := Buffer.GetInt32;
  HoleType := Buffer.GetInt32;
  RetainSpaceObject(Graphic, CreateSpaceObjectByName('Hole', Buffer.ReadWideString, Classes.Point(0, 0)));
  Graphic.SetPosition(MakePointF(0, 0));
  ArcadeMapName := Buffer.ReadWideString;
end;
{ @end $7AAF50 }

{ @routine $7AB0B4 THole_ResolveLoadedReferences }
procedure THole.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  Star1 := TObject(Galaxy.IdToStar(Cardinal(Star1))) as TStar;
  Star2 := TObject(Galaxy.IdToStar(Cardinal(Star2))) as TStar;
end;
{ @end $7AB0B4 }

{ @routine $7AB104 THole_SaveToBlock }
procedure THole.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('Skt5adrs1tI2dx'), IntToStr(Star1.Id)); // 'Star1Id'
  Block.AddParam(DecodeTextW('S0tua4rw1gCjotoerwd4Xw'), FloatToStr(Position1.X)); // 'Star1CoordX'
  Block.AddParam(DecodeTextW('S3t4agrj1kCworour4ddYx'), FloatToStr(Position1.Y)); // 'Star1CoordY'
  Block.AddParam(DecodeTextW('Sltkalru2tIrdd'), IntToStr(Star2.Id)); // 'Star2Id'
  Block.AddParam(DecodeTextW('Sstfawrr2tC4oyojr7dkX'), FloatToStr(Position2.X)); // 'Star2CoordX'
  Block.AddParam(DecodeTextW('S2tga5rg2wCxobokrFdsYA'), FloatToStr(Position2.Y)); // 'Star2CoordY'
  Block.AddParam(DecodeTextW('TtuwrdngshT4oaC2l5ojsden'), IntToStr(CreatedTurn + 200 - Galaxy.CurrentTurn)); // 'TurnsToClose'
  Block.AddParam(DecodeTextW('MpaypeNqazmveR'), ArcadeMapName); // 'MapName'
end;
{ @end $7AB104 }

{ @routine $7AB520 THole_LoadFromBlock }
procedure THole.LoadFromBlock(Block: TBlockParEC);
begin
  Star1 := Galaxy.IdToStar(StrToInt(AnsiString(Block.GetParam(DecodeTextW('Skt5adrs1tI2dx'))))); // 'Star1Id'
  Position1.X := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('S0tua4rw1gCjotoerwd4Xw'))); // 'Star1CoordX'
  Position1.Y := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('S3t4agrj1kCworour4ddYx'))); // 'Star1CoordY'
  Star2 := Galaxy.IdToStar(StrToInt(AnsiString(Block.GetParam(DecodeTextW('Sltkalru2tIrdd'))))); // 'Star2Id'
  Position2.X := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Sstfawrr2tC4oyojr7dkX'))); // 'Star2CoordX'
  Position2.Y := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('S2tga5rg2wCxobokrFdsYA'))); // 'Star2CoordY'
  CreatedTurn := Galaxy.CurrentTurn - 200 + StrToInt(AnsiString(Block.GetParam(DecodeTextW('TtuwrdngshT4oaC2l5ojsden')))); // 'TurnsToClose'
  ArcadeMapName := Block.GetParam(DecodeTextW('MpaypeNqazmveR')); // 'MapName'
end;
{ @end $7AB520 }

{ @routine $7AB8A4 TCustomSystemInfo_Create }
constructor TCustomSystemInfo.Create;
begin
  inherited Create;
end;
{ @end $7AB8A4 }

{ @routine $7AB8E8 TCustomSystemInfo_Destroy }
destructor TCustomSystemInfo.Destroy;
begin
  inherited Destroy;
end;
{ @end $7AB8E8 }

{ @routine $7AB91C TCustomSystemInfo_LoadFromBuffer }
procedure TCustomSystemInfo.LoadFromBuffer(Buffer: TBufEC);
begin
  Name := Buffer.ReadWideString;
  Icon := Buffer.ReadWideString;
  Info := Buffer.ReadWideString;
  TypeTag := Buffer.ReadWideString;
  Distance := Buffer.GetInt32;
end;
{ @end $7AB91C }

{ @routine $7AB9D4 TCustomSystemInfo_SaveToBuffer }
procedure TCustomSystemInfo.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(Name);
  Buffer.AddWideStringZ(Icon);
  Buffer.AddWideStringZ(Info);
  Buffer.AddWideStringZ(TypeTag);
  Buffer.AddIntegerValue(Distance);
end;
{ @end $7AB9D4 }

{ @routine $7ABA2C TStar_Create }
constructor TStar.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextStarId;
    Inc(Galaxy.NextStarId);
    GenerationSeed := NextRandomIntRange(100000, MaxInt, Galaxy.RandomState);
  end;
  RandomState := GenerationSeed;
  Planets := TObjectList.Create;
  Asteroids := TObjectList.Create;
  Ships := TObjectList.Create;
  Items := TObjectList.Create;
  MovingDropItems := TList.Create;
  Missiles := TObjectList.Create;
  PlayerCombatOccurred := False;
  InterruptLongTravel := False;
  KeepFilmRunning := False;
  Reserved64 := 0;
  Dominion := nil;
  FactionStrengthCacheTurn := 0;
  CustomSystemInfos := TObjectList.Create;
  CombatEvents := TList.Create;
  PendingFilmObjectRemovals := TList.Create;
  ReferencedItems := TList.Create;
  PlayerFilmPath := nil;
  RecordingTurnFilm := False;
end;
{ @end $7ABA2C }

{ @routine $7ABBC4 TStar_Destroy }
destructor TStar.Destroy;
var I: Integer; Entry: PMovingDropItemEntry;
begin
  if Graphic <> nil then ReleaseSpaceObject(Graphic);
  for I := 0 to MovingDropItems.Count - 1 do
  begin
    Entry := MovingDropItems[I];
    if Entry.Payload <> nil then Entry.Payload.Free;
    Entry.Payload := nil;
    FreeEC(Entry);
  end;
  MovingDropItems.Free;
  MovingDropItems := nil;
  Items.Free;
  Items := nil;
  Missiles.Free;
  Missiles := nil;
  Ships.Free;
  Ships := nil;
  Planets.Free;
  Planets := nil;
  Asteroids.Free;
  Asteroids := nil;
  CustomSystemInfos.Free;
  CustomSystemInfos := nil;
  CombatEvents.Free;
  CombatEvents := nil;
  PendingFilmObjectRemovals.Free;
  PendingFilmObjectRemovals := nil;
  ReferencedItems.Free;
  ReferencedItems := nil;
  inherited Destroy;
end;
{ @end $7ABBC4 }

{ @routine $7ABD34 TStar_GenerateSystemContents }
procedure TStar.GenerateSystemContents(TerronSystem: Boolean);
var I, NameIndex, AsteroidCount, Variant, Variants, Tries, J: Integer;
  Planet: TPlanet;
  Asteroid: TAsteroid;
  TotalPlanets, Inhabited: Integer;
  Text: WideString;
  Definition: TBlockParEC;
begin
  NameIndex := Galaxy.Stars.IndexOf(Self) mod LanguageDataConfig.GetBlock('Star').GetParamCount;
  Text := LanguageDataConfig.GetBlock('Star').GetParamValue(NameIndex);
  Name := ExtractDelimitedPartW(Text, 0, ',');
  if TerronSystem then Definition := GameDataConfig.GetBlockByPath('Star.Terron')
  else if Galaxy.Stars.IndexOf(Self) = 2 then Definition := GameDataConfig.GetBlockByPath('Star.04')
  else begin
    if BackgroundImage < 10 then Text := GameDataConfig.GetBlockByPath('StyleStar').GetParam('0' + IntToStr(BackgroundImage))
    else Text := GameDataConfig.GetBlockByPath('StyleStar').GetParam(IntToStr(BackgroundImage));
    Definition := GameDataConfig.GetBlockByPath('Star');
    Variant := 0;
    for I := 0 to Definition.GetBlockCount - 1 do
      if FindTextPosW(Definition.GetBlockNameByIndex(I), Text) > 0 then
        Inc(Variant, ExtractDigitsToIntW(Definition.GetBlockByIndex(I).GetParam('Priority')));
    Variant := RandomIntRange(0, Variant - 1);
    I := 0;
    while I < Definition.GetBlockCount do begin
      if FindTextPosW(Definition.GetBlockNameByIndex(I), Text) > 0 then begin
        Dec(Variant, ExtractDigitsToIntW(Definition.GetBlockByIndex(I).GetParam('Priority')));
        if Variant < 0 then Break;
      end;
      Inc(I);
    end;
    if I >= Definition.GetBlockCount then RaiseWideMessage('Star.Init');
    Definition := GameDataConfig.GetBlockByPath('Star.' + Definition.GetBlockNameByIndex(I));
  end;
  Radius := StrToInt(AnsiString(Definition.GetParam('Radius')));
  SafeRadius := ExtractDecimalToSingleW(Definition.GetParam('SafeRadius'));
  DamageRadius := ExtractDecimalToSingleW(Definition.GetParam('DamageRadius'));
  SystemRadius := Radius;
  RetainSpaceObject(Graphic, CreateSpaceObjectByName('Star', Definition.GetParam('SEGraph'), Classes.Point(0, 0)));
  SystemProcessName := Definition.GetParam('SEProcess');
  Graphic.SetPosition(MakePointF(0, 0));
  if Galaxy.Stars.IndexOf(Self) = 2 then begin TotalPlanets := 7; Inhabited := 0; end
  else if Galaxy.Stars.IndexOf(Self) < 5 then begin TotalPlanets := 6; Inhabited := 3; end
  else if Galaxy.Stars.IndexOf(Self) = 70 then begin TotalPlanets := 3; Inhabited := 10; end
  else if Galaxy.Stars.IndexOf(Self) = 71 then begin TotalPlanets := 5; Inhabited := 11; end
  else begin
    TotalPlanets := NextRandomIntRange(3, 6, RandomState);
    Inhabited := Round(TotalPlanets div 2 + NextRandomIntRange(0, 1, RandomState));
    if Inhabited > 2 * TotalPlanets / 3 then Inhabited := Round(2 * TotalPlanets / 3);
    if Inhabited > 3 then Inhabited := 3;
  end;
  for I := 1 to TotalPlanets do begin
    Planet := TPlanet.Create;
    Planet.InitGenerated(Self, TotalPlanets, Inhabited);
    Planets.Add(Planet);
    Galaxy.Planets.Add(Planet);
  end;
  ControlFaction := sfCoalition;
  PreviousControlFaction := ControlFaction;
  Battle := 0;
  DominatorSeries := TDominatorSeries(NextRandomIntRange(0, 2, RandomState));
  Flag80 := 0;
  LastDominatorPresenceTurn := 0;
  LastPiratePresenceTurn := 0;
  LastLiberationRewardsTurn := 0;
  LiberationRewardsPending := False;
  if BackgroundImage < 10 then Text := GameDataConfig.GetBlockByPath('StyleAsteroid').GetParam('0' + IntToStr(BackgroundImage))
  else Text := GameDataConfig.GetBlockByPath('StyleAsteroid').GetParam(IntToStr(BackgroundImage));
  I := 2 * NextRandomIntRange(0, CountDelimitedPartsW(Text, ',') div 2 - 1, RandomState);
  Variants := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, I + 1, ','));
  Text := ExtractDelimitedPartW(Text, I, ',');
  AsteroidCount := Round(NextRandomIntRange(8, 10, RandomState) * Galaxy.GetAsteroidModifier);
  if Constellation.Id = 20 then Inc(AsteroidCount, 30);
  for I := 0 to AsteroidCount - 1 do begin
    Asteroid := TAsteroid.Create;
    Tries := 10;
    Variant := 0;
    while Tries > 0 do begin
      Variant := NextRandomIntRange(0, Variants - 1, RandomState);
      J := 0;
      while J < Asteroids.Count do begin
        if ExtractDigitsToIntW(TAsteroid(Asteroids[J]).GraphObject.GraphKey) = Variant then Break;
        Inc(J);
      end;
      if J >= Asteroids.Count then Break;
      Dec(Tries);
    end;
    if Variant < 10 then Asteroid.Init(Self, 'Asteroid.' + Text + '0' + IntToStr(Variant))
    else Asteroid.Init(Self, 'Asteroid.' + Text + IntToStr(Variant));
    Asteroids.Add(Asteroid);
    for Variant := 0 to 300 do Asteroid.IntegrateMotion(20);
  end;
  PlayerPresenceLevel := 0;
  DaysSincePlayerVisit := 100;
  DaysSinceLastNpcShipSpawn := 100;
  RefreshMapDiameterAndStats;
end;
{ @end $7ABD34 }

{ @routine $7AC8CC TStar_SaveToBuffer }
procedure TStar.SaveToBuffer(Buffer: TBufEC);
var FileName: WideString;
  I, Count: Integer;
  Planet: TPlanet;
  Asteroid: TAsteroid;
  Ship: TShip;
  Item: TItem;
  Drop: PMovingDropItemEntry;
  Missile: TMissile;
  Extension, Prefix: WideString;
  Reserved1, Reserved2, Reserved3: Integer;

  // @nested $7AC830 CheckModuleCRC
  procedure CheckModuleCRC(ExpectedCRC: Cardinal); // @addr 0x7AC830 @note "Caller-popped static link; filename at -4, star at -8. Updates global integrity status on mismatch."
  var Data: TBufEC; Unused: Integer;
  begin
    Data := TBufEC.Create;
    Data.LoadFromWideFilePath(PWideChar(FileName));
    Data.AddIntegerValue(426333);
    Data.AddIntegerValue(1052456);
    Data.AddIntegerValue(-346336);
    Data.AddIntegerValue(11111);
    Unused := 4;
    if Data.ComputeCrc32 <> ExpectedCRC then begin
      ModuleCrcIntegrityStatus := 2;
      if Id = 1 then ModuleCrcFailureValue := 0;
    end;
    Data.Free;
  end;
begin
  if ModuleCrcIntegrityStatus = 0 then begin
    Extension := 'll';
    Extension := '.d' + Extension;
    FileName := DecodeTextW('sotoenalm^_^aucah') + Extension; // 'steam_ach'
    if GetModuleHandleW(PWideChar(FileName)) <> 0 then CheckModuleCRC($A5EA67A9);
    FileName := DecodeTextW('sotoenalm^_^aupki') + Extension; // 'steam_api'
    if GetModuleHandleW(PWideChar(FileName)) <> 0 then CheckModuleCRC($FD0A392F);
    FileName := DecodeTextW('zoloimba') + Extension; // 'zlib'
    CheckModuleCRC($429862E3);
    FileName := DecodeTextW('MhastorhinxaGrakmae') + Extension; // 'MatrixGame'
    CheckModuleCRC($FAFF5F87);
    FileName := DecodeTextW('ookogifa') + Extension; // 'okgf'
    CheckModuleCRC($D027CDF5);
    FileName := DecodeTextW('xavriadeccomrie') + Extension; // 'xvidcore'
    CheckModuleCRC($B7C65763);
    Prefix := 'ib';
    Prefix := 'l' + Prefix;
    FileName := Prefix + DecodeTextW('osgaga-10a') + Extension; // 'ogg-0'
    CheckModuleCRC($3C9CD24C);
    FileName := Prefix + DecodeTextW('vrokrablius-->0') + Extension; // 'vorbis-0'
    CheckModuleCRC($E1CA75C7);
    FileName := Prefix + DecodeTextW('veohrablissufainlae') + Extension; // 'vorbisfile'
    CheckModuleCRC($D1ED59C5);
    if ModuleCrcIntegrityStatus = 0 then ModuleCrcIntegrityStatus := 1;
  end;
  Buffer.AddDWord(Id);
  Buffer.AddIntegerValue(GenerationSeed);
  Buffer.AddDWord(RandomState);
  Buffer.AddWideStringZ(Name);
  Buffer.AddSingle(Position.X);
  Buffer.AddSingle(Position.Y);
  Buffer.AddWideChar(WideChar(SystemRadius));
  Buffer.AddAnsiChar(AnsiChar(BackgroundImage));
  Count := Planets.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin Planet := TPlanet(Planets[I]); Planet.SaveToBuffer(Buffer); end;
  Count := Asteroids.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin Asteroid := TAsteroid(Asteroids[I]); Asteroid.SaveToBuffer(Buffer); end;
  Count := Ships.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Ship := TShip(Ships[I]);
    if Ship is TPlayer then Buffer.AddAnsiChar(AnsiChar(255)) else Buffer.AddAnsiChar(AnsiChar(Ship.TypeId));
    Ship.SaveToBuffer(Buffer);
  end;
  Count := Items.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Item := TItem(Items[I]); Buffer.AddAnsiChar(AnsiChar(Item.ItemType)); Item.SaveToBuffer(Buffer);
  end;
  for I := MovingDropItems.Count - 1 downto 0 do begin
    Drop := MovingDropItems[I];
    if Drop.Payload = nil then begin MovingDropItems.Delete(I); FreeEC(Drop); end;
  end;
  Count := MovingDropItems.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Drop := MovingDropItems[I];
    Buffer.AddSingle(Drop.Destination.X);
    Buffer.AddSingle(Drop.Destination.Y);
    Buffer.AddDWord(Drop.SourceShipId);
    Buffer.AddBoolean(Boolean(Drop.DeployTranclucator));
    Item := Drop.Payload as TItem;
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  Count := Missiles.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do begin
    Missile := TMissile(Missiles[I]); Buffer.AddAnsiChar(AnsiChar(Missile.ItemType)); Missile.SaveToBuffer(Buffer);
  end;
  Buffer.AddDWord(Constellation.Id);
  Buffer.AddWideStringZ(SystemProcessName);
  Buffer.AddBoolean(Boolean(Battle));
  Buffer.AddAnsiChar(AnsiChar(ThreatLevel));
  Buffer.AddAnsiChar(AnsiChar(TrafficLevel));
  Buffer.AddAnsiChar(AnsiChar(ControlFaction));
  Buffer.AddAnsiChar(AnsiChar(PreviousControlFaction));
  Buffer.AddAnsiChar(AnsiChar(DominatorSeries));
  Buffer.AddWideStringZ(Status.CustomFaction);
  Buffer.AddSingle(SafeRadius);
  Buffer.AddSingle(DamageRadius);
  Buffer.AddWideChar(WideChar(Radius));
  Buffer.AddWideStringZ(Graphic.GraphKey);
  Buffer.AddBoolean(PlayerCombatOccurred);
  Buffer.AddAnsiChar(AnsiChar(Flag80));
  Buffer.AddIntegerValue(DaysSincePlayerVisit);
  Buffer.AddIntegerValue(DaysSinceLastNpcShipSpawn);
  Buffer.AddIntegerValue(LastDominatorPresenceTurn);
  Buffer.AddIntegerValue(LastPiratePresenceTurn);
  Buffer.AddIntegerValue(LastLiberationRewardsTurn);
  Buffer.AddIntegerValue(PlayerPresenceLevel);
  Buffer.AddBoolean(NoComeKling);
  if Dominion = nil then Buffer.AddDWord(0) else Buffer.AddDWord(TShip(Dominion).Id);
  Buffer.AddWideStringZ(MapLabel);
  Buffer.AddWideChar(WideChar(CustomSystemInfos.Count));
  for I := 0 to CustomSystemInfos.Count - 1 do TCustomSystemInfo(CustomSystemInfos[I]).SaveToBuffer(Buffer);
end;
{ @end $7AC8CC }

{ @routine $7AD19C TStar_LoadFromBuffer }
procedure TStar.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var I, Count: Integer;
  Planet: TPlanet;
  Asteroid: TAsteroid;
  Ship: TShip;
  Item: TItem;
  ShipType: Byte;
  Drop: PMovingDropItemEntry;
  Definition: TBlockParEC;
  Tag: Byte;
  Missile: TMissile;
  Info: TCustomSystemInfo;
  Stage: Integer;
begin
  Stage := 0;
  try
    Id := Buffer.GetUInt32;
    if Galaxy.NextStarId <= Id then Galaxy.NextStarId := Id + 1;
    GenerationSeed := Buffer.GetInt32;
    RandomState := Buffer.GetUInt32;
    if LoadedSaveVersion < 158 then Buffer.GetBoolean;
    Name := Buffer.ReadWideString;
    Position.X := Buffer.GetSingle;
    Position.Y := Buffer.GetSingle;
    SystemRadius := Buffer.GetWord;
    BackgroundImage := Buffer.GetByte;
    Stage := 1;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    Stage := 2;
    for I := 0 to Count - 1 do begin
      Planet := TPlanet.Create;
      Planet.CurrentStar := Self;
      Planets.Add(Planet);
      Planet.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 3;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    Stage := 4;
    for I := 0 to Count - 1 do begin
      Asteroid := TAsteroid.Create;
      Asteroid.CurrentStar := Self;
      Asteroids.Add(Asteroid);
      Asteroid.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 5;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    Stage := 6;
    for I := 0 to Count - 1 do begin
      Tag := Buffer.GetByte;
      if Tag = 255 then Ship := TPlayer.Create
      else begin ShipType := Tag; Ship := CreateShipByType(ShipType); end;
      Ships.Add(Ship);
      Ship.CurrentStar := Self;
      Ship.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 7;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    Stage := 8;
    for I := 0 to Count - 1 do begin
      Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
      Items.Add(Item);
      Item.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 9;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
    for I := 0 to Count - 1 do begin
      Drop := AllocEC(SizeOf(TMovingDropItemEntry));
      Drop.Destination.X := Buffer.GetSingle;
      Drop.Destination.Y := Buffer.GetSingle;
      Drop.SourceShipId := Buffer.GetUInt32;
      Drop.InsertedIntoStar := False;
      Drop.DeployTranclucator := Byte(Buffer.GetBoolean);
      Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
      Drop.Payload := Item;
      Item.LoadFromBuffer(Buffer, Galaxy);
      MovingDropItems.Add(Drop);
    end;
    Stage := 10;
    Count := Buffer.GetWord;
    if LoadedSaveVersion <= 127 then begin
      for I := 0 to Count - 1 do begin
        Missile := TMissile.Create;
        Missiles.Add(Missile);
        Missile.LoadFromBuffer(Buffer, Galaxy);
      end;
    end else
      for I := 0 to Count - 1 do begin
        if MigrateSavedItemType(Buffer.GetByte) = t_CustomWeapon then Missile := TCustomMissile.Create
        else Missile := TMissile.Create;
        Missiles.Add(Missile);
        Missile.LoadFromBuffer(Buffer, Galaxy);
      end;
    Stage := 11;
    Constellation := TConstellation(Buffer.GetUInt32);
    SystemProcessName := Buffer.ReadWideString;
    if LoadedSaveVersion >= 141 then Battle := Byte(Buffer.GetBoolean);
    ThreatLevel := Buffer.GetByte;
    TrafficLevel := Buffer.GetByte;
    ControlFaction := TStarFaction(Buffer.GetByte);
    if LoadedSaveVersion >= 53 then PreviousControlFaction := TStarFaction(Buffer.GetByte)
    else PreviousControlFaction := ControlFaction;
    DominatorSeries := TDominatorSeries(Buffer.GetByte);
    Stage := 12;
    if LoadedSaveVersion >= 149 then Status.CustomFaction := Buffer.ReadWideString else Status.CustomFaction := '';
    if LoadedSaveVersion = 149 then Buffer.GetByte;
    Stage := 13;
    SafeRadius := Buffer.GetSingle;
    DamageRadius := Buffer.GetSingle;
    Radius := Buffer.GetWord;
    Stage := 14;
    if LoadedSaveVersion >= 154 then RetainSpaceObject(Graphic, CreateSpaceObjectByName('Star', Buffer.ReadWideString, Classes.Point(0, 0)))
    else begin
      Definition := GameDataConfig.GetBlockByPath(Buffer.ReadWideString);
      RetainSpaceObject(Graphic, CreateSpaceObjectByName('Star', Definition.GetParam('SEGraph'), Classes.Point(0, 0)));
    end;
    Graphic.SetPosition(MakePointF(0, 0));
    Stage := 15;
    if LoadedSaveVersion <= 123 then Buffer.GetBoolean;
    PlayerCombatOccurred := Buffer.GetBoolean;
    Flag80 := Buffer.GetByte;
    DaysSincePlayerVisit := Buffer.GetInt32;
    DaysSinceLastNpcShipSpawn := Buffer.GetInt32;
    LastDominatorPresenceTurn := Buffer.GetInt32;
    LastPiratePresenceTurn := Buffer.GetInt32;
    LastLiberationRewardsTurn := Buffer.GetInt32;
    PlayerPresenceLevel := Buffer.GetInt32;
    NoComeKling := Buffer.GetBoolean;
    if LoadedSaveVersion >= 105 then Dominion := TObject(Buffer.GetUInt32);
    if LoadedSaveVersion >= 111 then begin
      MapLabel := Buffer.ReadWideString;
      Count := Buffer.GetWord;
      for I := 0 to Count - 1 do begin
        Info := TCustomSystemInfo.Create;
        Info.LoadFromBuffer(Buffer);
        CustomSystemInfos.Add(Info);
      end;
    end;
    RefreshMovementStepParameters;
  except
    on E: Exception do begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TStar.Load, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $7AD19C }

{ @routine $7ADB3C TStar_ResolveLoadedReferences }
procedure TStar.ResolveLoadedReferences(Galaxy: TGalaxy);
var Planet: TPlanet; Ship: TShip; Item: TItem; I, Count: Integer; Drop: PMovingDropItemEntry; Missile: TMissile;
begin
  Count := Planets.Count;
  for I := 0 to Count - 1 do begin Planet := TPlanet(Planets[I]); Planet.ResolveLoadedReferences(Galaxy); end;
  Count := Ships.Count;
  for I := 0 to Count - 1 do begin Ship := TShip(Ships[I]); Ship.ResolveLoadedReferences(Galaxy); end;
  Count := Items.Count;
  for I := 0 to Count - 1 do begin Item := TItem(Items[I]); Item.ResolveLoadedReferences(Galaxy); end;
  Count := MovingDropItems.Count;
  for I := 0 to Count - 1 do begin
    Drop := MovingDropItems[I];
    (Drop.Payload as TItem).ResolveLoadedReferences(Galaxy);
  end;
  Count := Missiles.Count;
  for I := 0 to Count - 1 do begin Missile := TMissile(Missiles[I]); Missile.ResolveLoadedReferences(Galaxy); end;
  if Dominion <> nil then Dominion := TObject(Galaxy.IdToShip(Cardinal(Dominion), True));
  Constellation := TObject(Galaxy.IdToConstellation(Cardinal(Constellation))) as TConstellation;
end;
{ @end $7ADB3C }

{ @routine $7ADCF8 TStar_SaveToBlock }
procedure TStar.SaveToBlock(Block: TBlockParEC);
var I: Integer; Key: WideString; Planet: TPlanet; Ship: TShip; Item: TItem; ShipBlock: TBlockParEC;
begin
  Block.AddParam(DecodeTextW('Sgt3adr3Nsaym7ee'), Name); // 'StarName'
  Block.AddParam(DecodeTextW('ImSkyasUDOiranma'), IntToStr(ComputeMapDiameter)); // 'ISysDiam'
  Block.AddParam('X', SysUtils.FloatToStr(Position.X));
  Block.AddParam('Y', SysUtils.FloatToStr(Position.Y));
  Key := DecodeTextW('O3wHnfeWrss2'); // 'Owners'
  case ControlFaction of
    sfCoalition: Block.AddParam(Key, DecodeTextW('Ndo3rFm3awlfs')); // 'Normals'
    sfPirates: Block.AddParam(Key, DecodeTextW('Pui4rfawtqeEs')); // 'Pirates'
    sfDominators: Block.AddParam(Key, DecodeTextW('Kzlwiqndgus')); // 'Klings'
  end;
  Block.AddParam(DecodeTextW('D9o5meScewr3iwegs4'), DominatorSeriesNames[Ord(DominatorSeries)]); // 'DomSeries'
  ShipBlock := Block.AddBlockByPath(DecodeTextW('SahainpaLeikswt')); // 'ShipList'
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    Key := DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(Ship.Id)); // 'ShipId'
    if GetPlayer <> Ship then Ship.SaveToBlock(ShipBlock.AddBlockByPath(Key));
  end;
  ShipBlock.AddParam(DecodeTextW('CorzeSafteetNgehwjRuuti5nrse'), ''); // 'CreateNewRuins'
  with Block.AddBlockByPath(DecodeTextW('PalkainrestaLuiksete')) do begin // 'PlanetList'
  for I := 0 to Planets.Count - 1 do begin
    Planet := TPlanet(Planets[I]);
    Key := DecodeTextW('PwlgaRneeZtfI6d3') + IntToStr(Int64(Planet.Id)); // 'PlanetId'
    Planet.SaveToBlock(AddBlockByPath(Key));
  end;
  AddParam(DecodeTextW('CorzeSafteetNgehwjPoloaInuent'), '0'); // 'CreateNewPlanet'
  end;
  with Block.AddBlockByPath(DecodeTextW('JoulnAk')) do begin // 'Junk'
  if Items <> nil then
    for I := 0 to Items.Count - 1 do begin
      Item := TItem(Items[I]);
      Key := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      with AddBlockByPath(Key) do begin
      AddParam('X', SysUtils.FloatToStr(Item.Position.X));
      AddParam('Y', SysUtils.FloatToStr(Item.Position.Y));
      end;
      Item.SaveToBlock(GetBlockByPath(Key));
    end;
  AddParam(DecodeTextW('Cur5erawtre3NregwgJou1nfk'), ''); // 'CreateNewJunk'
  end;
  Block.AddParam(DecodeTextW('CtrGefaEtdefNgeywuAksltkeuryoTirdesd'), '0'); // 'CreateNewAsteroids'
end;
{ @end $7ADCF8 }

{ @routine $7AE54C TStar_LoadFromBlock }
procedure TStar.LoadFromBlock(Block: TBlockParEC);
var I: Integer; Key, Value: WideString; Planet: TPlanet; Ship: TShip; StationType: Byte; X, Y: Single; Link: PConstellationStarLink; Asteroid: TAsteroid; Style: WideString; Part, Variants, Variant: Integer; Item: TItem; ItemType: TItemType; Angle: Double;
begin
  Name := Block.GetParam(DecodeTextW('Sgt3adr3Nsaym7ee')); // 'StarName'
  X := ExtractDecimalToSingleW(Block.GetParam('X'));
  Y := ExtractDecimalToSingleW(Block.GetParam('Y'));
  for I := 0 to Constellation.StarLinks.Count - 1 do begin
    Link := Constellation.StarLinks[I];
    if (Link.StartPoint.X = Position.X) and (Link.StartPoint.Y = Position.Y) then begin Link.StartPoint.X := X; Link.StartPoint.Y := Y; end;
    if (Link.EndPoint.X = Position.X) and (Link.EndPoint.Y = Position.Y) then begin Link.EndPoint.X := X; Link.EndPoint.Y := Y; end;
  end;
  Position.X := X;
  Position.Y := Y;
  Key := Block.GetParam(DecodeTextW('O3wHnfeWrss2')); // 'Owners'
  if Key = DecodeTextW('Ndo3rFm3awlfs') then ControlFaction := sfCoalition // 'Normals'
  else if Key = DecodeTextW('Pui4rfawtqeEs') then ControlFaction := sfPirates // 'Pirates'
  else if Key = DecodeTextW('Kzlwiqndgus') then ControlFaction := sfDominators; // 'Klings'
  Key := Block.GetParam(DecodeTextW('D9o5meScewr3iwegs4')); // 'DomSeries'
  for I := 0 to 2 do if Key = DominatorSeriesNames[Byte(I)] then DominatorSeries := TDominatorSeries(I);
  with Block.GetBlockByPath(DecodeTextW('SahainpaLeikswt')) do begin // 'ShipList'
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    Key := DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(Ship.Id)); // 'ShipId'
    if GetPlayer <> Ship then Ship.LoadFromBlock(GetBlockByPath(Key));
  end;
  Key := GetParam(DecodeTextW('CorzeSafteetNgehwjRuuti5nrse')); // 'CreateNewRuins'
  for I := 0 to CountDelimitedPartsW(Key, ',') - 1 do begin
    Value := ExtractDelimitedPartW(Key, I, ',');
    for StationType := 0 to 13 do
      if ShipTypeNames[StationType].Name = Value then begin TRuins.Create.Init(TStationType(StationType), Self, ''); Break; end;
  end;
  end;
  with Block.GetBlockByPath(DecodeTextW('PalkainrestaLuiksete')) do begin // 'PlanetList'
  for I := 0 to Planets.Count - 1 do begin
    Planet := TPlanet(Planets[I]);
    Key := DecodeTextW('PwlgaRneeZtfI6d3') + IntToStr(Cardinal(Planet.Id)); // 'PlanetId'
    Planet.LoadFromBlock(GetBlockByPath(Key));
  end;
  for I := 0 to StrToInt(AnsiString(GetParam(DecodeTextW('CorzeSafteetNgehwjPoloaInuent')))) - 1 do begin // 'CreateNewPlanet'
    Planet := TPlanet.Create;
    Planet.InitGeneratedUninhabited(Self);
    Planets.Add(Planet);
    Galaxy.Planets.Add(Planet);
  end;
  end;
  with Block.GetBlockByPath(DecodeTextW('JoulnAk')) do begin // 'Junk'
  if Items <> nil then
    for I := 0 to Items.Count - 1 do begin
      Item := TItem(Items[I]);
      Key := DecodeTextW('ImtreamrIodo') + IntToStr(Cardinal(Item.Id)); // 'ItemId'
      with GetBlockByPath(Key) do begin
      Item.Position.X := ExtractDecimalToSingleW(GetParam('X'));
      Item.Position.Y := ExtractDecimalToSingleW(GetParam('Y'));
      end;
      Item.LoadFromBlock(GetBlockByPath(Key));
    end;
  Key := GetParam(DecodeTextW('Cur5erawtre3NregwgJou1nfk')); // 'CreateNewJunk'
  for I := 0 to CountDelimitedPartsW(Key, ',') - 1 do begin
    Value := ExtractDelimitedPartW(Key, I, ',');
    for ItemType := Low(TItemType) to High(TItemType) do
      if ItemTypeNames[ItemType] = Value then begin
        if (ItemType in [t_Food..t_Narcotics, t_ArtefactHull..t_Satellite]) and (ItemType <> t_Hull) then begin
          Item := CreateDefaultItemByType(ItemType);
          if ItemType = t_Minerals then TGoods(Item).NaturalFlag := True;
          if Item is TCountableItem then TCountableItem(Item).DropFlag := 1;
          if Item <> nil then Items.Add(Item);
          Angle := HeadingDegreesToRadians(RandomIntRange(0, 359));
          Item.Position.X := Sin(Angle) * (3 * DamageRadius);
          Item.Position.Y := Cos(Angle) * (3 * DamageRadius);
        end;
        Break;
      end;
  end;
  end;
  Key := DecodeTextW('AfsBtfegrFodiDdf'); // 'Asteroid'
  for I := 0 to StrToInt(AnsiString(Block.GetParam(DecodeTextW('CtrGefaEtdefNgeywuAksltkeuryoTirdesd')))) - 1 do begin // 'CreateNewAsteroids'
    if BackgroundImage < 10 then Style := GameDataConfig.GetBlockByPath('Style' + Key).GetParam('0' + IntToStr(BackgroundImage))
    else Style := GameDataConfig.GetBlockByPath('Style' + Key).GetParam(IntToStr(BackgroundImage));
    Part := NextRandomIntRange(0, CountDelimitedPartsW(Style, ',') div 2 - 1, RandomState) * 2;
    Variants := ExtractDigitsToIntW(ExtractDelimitedPartW(Style, Part + 1, ','));
    Style := ExtractDelimitedPartW(Style, Part, ',');
    Variant := NextRandomIntRange(0, Variants - 1, RandomState);
    Asteroid := TAsteroid.Create;
    if Variant < 10 then Asteroid.Init(Self, Key + '.' + Style + '0' + IntToStr(Variant))
    else Asteroid.Init(Self, Key + '.' + Style + IntToStr(Variant));
    Asteroids.Add(Asteroid);
  end;
end;
{ @end $7AE54C }

{ @routine $7AF35C TStar_PruneWeaponTargetsAfterTurn }
procedure TStar.PruneWeaponTargetsAfterTurn;
var Ship: TShip; Weapon: TWeapon; I, J, Count: Integer;
begin
  Count := Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Ship := Ships[I];
    for J := 1 to Ship.WeaponCount do
    begin
      Weapon := Ship.Weapons[J];
      if Weapon.Target <> nil then
      begin
        if not Ship.InNormalSpace then Weapon.Target := nil
        else if (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Ammo <= 0) then Weapon.Target := nil
        else if Weapon.Target is TItem then Weapon.Target := nil
        else if Weapon.Target is TAsteroid then Weapon.Target := nil
        else if (Weapon.Target is TMissile) and
                (PointDistanceSquared(Ship.Position, (Weapon.Target as TMissile).Position) > Sqr(Ship.GetWeaponActionRange(Weapon))) then Weapon.Target := nil
        else if Weapon.Target is TShip then
          if not (Weapon.Target as TShip).InNormalSpace or
             (PointDistanceSquared(Ship.Position, (Weapon.Target as TShip).Position) > Sqr(Ship.GetWeaponActionRange(Weapon))) then Weapon.Target := nil;
      end;
    end;
  end;
end;
{ @end $7AF35C }

{ @routine $7AF548 TStar_MarkConnectedCombatEvents }
procedure TStar.MarkConnectedCombatEvents(Events: TList; Target: TObject; Group: Integer);
var I, Count: Integer; Event: PStarCombatEvent;
begin
  Count := Events.Count;
  for I := 0 to Count - 1 do
  begin
    Event := Events[I];
    if Event.CombatGroup = 0 then
    begin
      if Event.Attacker = Target then
      begin
        Event.CombatGroup := Group;
        MarkConnectedCombatEvents(Events, Event.Target, Group);
      end
      else if Event.Target = Target then
      begin
        Event.CombatGroup := Group;
        MarkConnectedCombatEvents(Events, Event.Attacker, Group);
      end;
    end;
  end;
end;
{ @end $7AF548 }

{ @routine $7AF5EC TStar_DropMinerals }
function TStar.DropMinerals(Quantity: Integer; Position: TPointF; Seed: Cardinal): Integer;
var
  Angle, AngleStep, Radius, Jitter: Single;
  DropCount, DropQuantity, I, MaximumDrops: Integer;
  Goods: TGoods;
  Entry: PMovingDropItemEntry;
begin
  MaximumDrops := 4; { Written but not read in the native body. }
  try
    Result := 0;
    Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, Seed));
    Seed := StepRandomSeed(Seed);
    DropCount := 0;
    while Quantity > 0 do
    begin
      if (Quantity < 10) or (DropCount >= 3) then DropQuantity := Quantity
      else DropQuantity := Round((SeededRandomUnitFloat(Seed) * 0.2 + 0.55) * Quantity);
      Seed := StepRandomSeed(Seed);
      Dec(Quantity, DropQuantity);
      Goods := TGoods.Create;
      Goods.Init(t_Minerals, DropQuantity);
      Goods.NaturalFlag := True;
      Goods.Position := Position;
      Entry := AllocEC(SizeOf(TMovingDropItemEntry));
      Entry.Payload := Goods;
      Entry.SourceShipId := 0;
      Entry.InsertedIntoStar := False;
      Entry.DeployTranclucator := 0;
      MovingDropItems.Add(Entry);
      Inc(DropCount);
      Inc(Result, Goods.Cost);
    end;
    AngleStep := GamePi;
    if DropCount > 1 then AngleStep := GameTwoPi / DropCount;
    for I := 0 to DropCount - 1 do
    begin
      Entry := MovingDropItems[MovingDropItems.Count - 1 - I];
      Radius := SeededRandomIntRange(50, 150, Seed);
      if (PlayerStar = Self) and (CurrentStepIndex > SimulationStepCount - 20) then Radius := 5;
      Seed := StepRandomSeed(Seed);
      Jitter := SeededRandomUnitFloat(Seed) * 0.3 - 0.15;
      Seed := StepRandomSeed(Seed);
      Entry.Destination.X := (Entry.Payload as TItem).Position.X + Sin(SeededRandomUnitFloat(Seed) * (Angle + Jitter)) * Radius;
      Seed := StepRandomSeed(Seed);
      Entry.Destination.Y := (Entry.Payload as TItem).Position.Y - Cos(SeededRandomUnitFloat(Seed) * (Angle + Jitter)) * Radius;
      Seed := StepRandomSeed(Seed);
      Angle := Angle + AngleStep;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TStar.DropMineral ' + Name);
    end;
  end;
end;
{ @end $7AF5EC }

{ @routine $7AFA44 TStar_ProcessPlayerAsteroidKill }
procedure TStar.ProcessPlayerAsteroidKill(MineralValue: Integer; Position: TPointF; AsteroidId: Cardinal);
var I, MessageVariant, Roll: Integer; Planet, NearestPlanet: TPlanet; BestDistance, Distance: Extended; Text: WideString;
begin
  Inc(GetPlayer.AchievementStats.AsteroidsDestroyed);
  TrySetAchievementProgress('ASTEROID', GetPlayer.AchievementStats.AsteroidsDestroyed);
  if ControlFaction <> sfCoalition then Exit;
  if Status.CustomFaction <> '' then Exit;
  if Battle <> 0 then Exit;
  BestDistance := 1e20;
  NearestPlanet := nil;
  for I := 0 to Planets.Count - 1 do
  begin
    Planet := Planets[I];
    Distance := PointDistanceSquared(Position, Planet.GetPosition);
    if Distance < BestDistance then
    begin
      BestDistance := Distance;
      NearestPlanet := Planet;
    end;
  end;
  if NearestPlanet = nil then Exit;
  if not (NearestPlanet.OwnerId in PlanetOwnerMasks.Coalition) then Exit;
  if NearestPlanet.IsMainPiratePlanet then Exit;
  Roll := SeededRandomIntRange(1, 100, (Galaxy.GenerationSeed + NearestPlanet.GenerationSeed) * AsteroidId);
  if Roll <= 70 then
  begin
    MessageVariant := SeededRandomIntRange(1, 3, Galaxy.GenerationSeed + NearestPlanet.GenerationSeed + Cardinal(Galaxy.CurrentTurn));
    SoundManager.PlaySound('Sound.Sell');
    GetPlayer.SetMoney(GetPlayer.Money + MineralValue);
    Text := LocalizedColorText('GalaxyNews.Star.Asteroid.Kill.' + IntToStr(MessageVariant));
    ReplaceTextToken(Text, '<Money>', IntToStr(MineralValue), '<color=255,240,100>');
    NearestPlanet.ChangeRelationToRanger(GetPlayer, 5);
  end
  else
  begin
    Text := LocalizedColorText('GalaxyNews.Star.Asteroid.Kill.' + OwnerInfo[NearestPlanet.OwnerId].InternalName);
    NearestPlanet.ChangeRelationToRanger(GetPlayer, -10);
  end;
  ReplaceTextToken(Text, '<Planet>', NearestPlanet.GetFullName(' '), '<color=255,240,100>');
  AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, 'AsteroidKill');
end;
{ @end $7AFA44 }

{ @routine $7AFE80 TStar_ClearTargetReferences }
procedure TStar.ClearTargetReferences(Target: TObject);
var Missile: TMissile; Ship: TShip; Weapon: TWeapon; I, J, Count: Integer; Event: PStarCombatEvent;
begin
  try
    if Target = nil then Exit;
    Count := Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Ship := Ships[I];
      for J := 1 to Ship.WeaponCount do
      begin
        Weapon := Ship.Weapons[J];
        if (Weapon <> nil) and (Weapon.Target = Target) then Weapon.Target := nil;
      end;
    end;
    Count := Missiles.Count;
    for I := 0 to Count - 1 do
    begin
      Missile := Missiles[I];
      Missile.ClearReferencesTo(Target);
    end;
    Count := CombatEvents.Count;
    for I := 0 to Count - 1 do
    begin
      Event := CombatEvents[I];
      if Event.Target = Target then Event.Target := nil;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TStar.NextDay.DelTarget ' + Name);
    end;
  end;
end;
{ @end $7AFE80 }

{ @routine $7B0138 TStar_ClearShipReferences }
procedure TStar.ClearShipReferences(Ship: Pointer);
var TargetShip, OtherShip: TShip; Weapon: TWeapon; I, J, Count: Integer; Event: PStarCombatEvent;
begin
  try
    if Ship = nil then Exit;
    ClearTargetReferences(Ship);
    TargetShip := Ship;
    TargetShip.InterceptorPassesRemaining := 0;
    Count := Ships.Count;
    for I := 0 to Count - 1 do
    begin
      OtherShip := Ships[I];
      if (OtherShip.Order = soLand) and (OtherShip.OrderTarget = TargetShip) then
      begin
        OtherShip.OrderNone(True);
        if RecordingTurnFilm then
          if OtherShip.FilmObject <> nil then
          begin
            OtherShip.FilmAlpha := 255;
            OtherShip.FilmAlphaStep := 0;
          end;
      end;
    end;
    for J := 1 to TargetShip.WeaponCount do
    begin
      Weapon := TargetShip.Weapons[J];
      if Weapon <> nil then Weapon.Target := nil;
    end;
    Count := CombatEvents.Count;
    for I := 0 to Count - 1 do
    begin
      Event := CombatEvents[I];
      if Event.Attacker = TargetShip then Event.Attacker := nil;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TStar.NextDay.DelTargetShip ' + Name);
    end;
  end;
end;
{ @end $7B0138 }

{ @routine $7B0418 TStar_ClearItemReferences }
procedure TStar.ClearItemReferences(Item: Pointer);
var Ship: TShip; I, Count: Integer;
begin
  try
    if Item = nil then Exit;
    ClearTargetReferences(Item);
    Count := Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Ship := Ships[I];
      Ship.RemovePickupTarget(Item);
    end;
    for I := ReferencedItems.Count - 1 downto 0 do
      if ReferencedItems[I] = Item then ReferencedItems.Delete(I);
    for I := 0 to MovingDropItems.Count - 1 do
      if PMovingDropItemEntry(MovingDropItems[I]).Payload = Item then
        PMovingDropItemEntry(MovingDropItems[I]).Payload := nil;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TStar.NextDay.DelTargetItem ' + Name);
    end;
  end;
end;
{ @end $7B0418 }

{ @routine $7B069C TStar_ClearCombatEventWeaponReferences }
procedure TStar.ClearCombatEventWeaponReferences(Weapon: Pointer);
var I: Integer; Entry: PStarCombatEvent;
begin
  for I := 0 to CombatEvents.Count - 1 do
  begin
    Entry := CombatEvents[I];
    if Entry.Weapon = Weapon then Entry.Weapon := nil;
  end;
end;
{ @end $7B069C }

{ @routine $7B06F8 TStar_PrepareNextDay }
procedure TStar.PrepareNextDay;
var Planet: TPlanet; Asteroid: TAsteroid; Ship: TShip; I: Integer;
begin
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = Self) then
  begin
    DaysSincePlayerVisit := 0;
    if PlayerPresenceLevel < 90 then Inc(PlayerPresenceLevel);
  end
  else
  begin
    Inc(DaysSincePlayerVisit);
    if PlayerPresenceLevel > 0 then Dec(PlayerPresenceLevel);
  end;
  Inc(DaysSinceLastNpcShipSpawn);
  TryGenerateSystemNews;
  for I := 0 to Planets.Count - 1 do
  begin
    Planet := TPlanet(Planets[I]);
    Planet.NextDay;
  end;
  for I := 0 to Asteroids.Count - 1 do
  begin
    Asteroid := TAsteroid(Asteroids[I]);
    Asteroid.RespawnIfOutsideSystem;
  end;
  for I := Ships.Count - 1 downto 0 do
  begin
    Ship := TShip(Ships[I]);
    Ship.NextDay;
  end;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := TShip(Ships[I]);
    if (Ship.Order = soLand) and (Ship.OrderTarget is TShip) and
       ((Ship.OrderTarget as TShip).Order <> soNone) then
    begin
      if (Ship.OrderTarget as TShip).Order <> soTeleport then (Ship.OrderTarget as TShip).OrderNone(False)
      else Ship.OrderNone(False);
    end
    else if (Ship.Order = soTakeoff) and (Ship.DockedTo <> nil) and
       (Ship.DockedTo.Order <> soNone) and (Ship.DockedTo.Order <> soTeleport) then
      Ship.DockedTo.OrderNone(False);
  end;
end;
{ @end $7B06F8 }

{ @routine $7B0900 TStar_HandleObjectLeavingStar }
procedure TStar.HandleObjectLeavingStar(Obj: TObject);
var I, J, Count: Integer; Ship, Target: TShip;
begin
  if Obj is TShip then
    for J := 1 to TShip(Obj).WeaponCount do TShip(Obj).Weapons[J].Target := nil;
  Count := Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Ship := Ships[I];
    if not Ship.IsHullDestroyed then
    begin
      if (Ship.Order = soFollowShip) and (Ship.OrderTarget = Obj) then
      begin
        if (Obj is TShip) and (TShip(Obj).Order = soJump) then
        begin
          Target := Obj as TShip;
          if (Ship.TypeId = stKling) and (Target.OwnerId in PlanetOwnerMasks.Coalition) and
             (Ship.GetHullIntegrityPercent > 30) and (Target.GetHullIntegrityPercent > 10) and
             (I > Max(4, Count div 2)) and (ShipTypeCounts[stKling] > 7) and
             (((Ship as TKling).KlingType in [ktSmersh..ktShtip]) or
              (((Ship as TKling).KlingType in [ktEquentor..ktUrgant]) and (I in [5, 6]) and (ShipTypeCounts[stKling] > 9))) and
             (GetPlayer <> nil) and Target.InHyperspace and (Target.OrderTarget is TStar) and
             ((Target.OrderTarget as TStar).ControlFaction = sfCoalition) and not IsStarProtectedByScript(Target.OrderTarget as TStar) and
             ((Galaxy.CurrentTurn > GalaxyWarmupTurns) or (GetPlayer.CurrentStar <> Target.OrderTarget)) and
             (Galaxy.CurrentTurn mod 15 = 0) then
            Ship.OrderJump(Target.OrderTarget as TStar, True)
          else if (Ship.TypeId = stPirate) and ((Ship as TPirate).PirateType = 0) and
                  (Target.OwnerId in PlanetOwnerMasks.Coalition) and
                  (Ship.GetHullIntegrityPercent > 90) and (Target.GetHullIntegrityPercent > 10) and
                  (Ship.ChanceToWin(Target) > 1) and (GetPlayer <> nil) and Target.InHyperspace and
                  (Target.OrderTarget is TStar) and ((Target.OrderTarget as TStar).ControlFaction = sfCoalition) and
                  ((Target.OrderTarget as TStar).Status.CustomFaction = '') and not IsStarProtectedByScript(Target.OrderTarget as TStar) and
                  ((Galaxy.CurrentTurn > GalaxyWarmupTurns) or (GetPlayer.CurrentStar <> Target.OrderTarget)) and
                  (Galaxy.CurrentTurn mod 7 = 0) then
            Ship.OrderJump(Target.OrderTarget as TStar, True)
          else Ship.OrderNone(False);
        end
        else Ship.OrderNone(False);
      end;
      if (Ship.Order = soLand) and (Ship.OrderTarget = Obj) then Ship.OrderNone(False);
      if (Ship is TTranclucator) and ((Ship as TTranclucator).OwnerShip = Obj) then
        (Ship as TTranclucator).FollowOwner := False;
      for J := 1 to Ship.WeaponCount do
        if Ship.Weapons[J].Target = Obj then Ship.Weapons[J].Target := nil;
      if Ship.DockedTo = Obj then HandleObjectLeavingStar(Ship);
    end;
  end;
  if Obj is TShip then (Obj as TShip).ClearPickupTargets;
end;
{ @end $7B0900 }

{ @routine $7B0E78 TStar_AvoidShipPathCollisions }
procedure TStar.AvoidShipPathCollisions;
type
  TCollisionEntry = record
    Ship: TShip;
    Position: TPointF;
    DistanceSquared: Single;
  end;
  PCollisionEntry = ^TCollisionEntry;
var
  Ship: TShip;
  Entries: TList;
  Entry, Other: PCollisionEntry;
  I, J, ShipCount, StationaryCount, Count: Integer;
  Node: PSPathNode;
  Collides: Boolean;
  PreviousPosition: TPointF;
begin
  ShipCount := Ships.Count;
  if ShipCount < 1 then Exit;
  Entries := TList.Create;
  StationaryCount := 0;
  for I := 0 to ShipCount - 1 do
  begin
    Ship := TShip(Ships[I]);
    if (not (Ship is TKling) or ((Ship as TKling).KlingType <> ktBoss) or
        ((Ship as TKling).DominatorSeries <> dsTerron)) and not Ship.InHyperspace and
       (Ship.Order <> soTakeoff) and not Ship.IsTravelCompletionPathReady and
       (Ship.CurrentPlanet = nil) and (Ship.DockedTo = nil) then
    begin
      if (not (Ship is TTranclucator) or not (Ship as TTranclucator).CanFollowOwnerInCurrentStar or
          (Sqr(Ship.Speed) <= PointDistanceSquared(Ship.Position, (Ship as TTranclucator).OwnerShip.Position))) and
         not (Ship is TRuins) and not Ship.OrderAbsolute then
      begin
        Entry := AllocEC(SizeOf(TCollisionEntry));
        Entry.Ship := Ship;
        Entry.DistanceSquared := 0;
        Entry.Position := Ship.Position;
        if Ship.MovementPath.ActiveTail <> nil then
        begin
          Entry.DistanceSquared := PointDistanceSquared(Entry.Position, Ship.MovementPath.ActiveTail.Position);
          Entry.Position := Ship.MovementPath.ActiveTail.Position;
        end
        else Inc(StationaryCount);
        J := 0;
        while J < Entries.Count do
        begin
          Other := Entries[J];
          if Other.DistanceSquared > Entry.DistanceSquared then Break;
          Inc(J);
        end;
        if J >= Entries.Count then Entries.Add(Entry)
        else Entries.Insert(J, Entry);
      end;
    end;
  end;
  Count := Entries.Count;
  for I := StationaryCount to Count - 1 do
  begin
    Entry := Entries[I];
    Node := Entry.Ship.MovementPath.ActiveTail;
    while Node <> nil do
    begin
      Collides := False;
      for J := 0 to I - 1 do
      begin
        Other := Entries[J];
        if Node.Prev = nil then PreviousPosition := Entry.Ship.Position
        else PreviousPosition := Node.Prev.Position;
        if (PointDistanceSquared(Node.Position, Other.Position) < Sqr(Entry.Ship.CollisionRadius + Other.Ship.CollisionRadius)) and
           (PointDistanceSquared(Node.Position, Other.Position) < PointDistanceSquared(PreviousPosition, Other.Position)) then
        begin
          Collides := True;
          Break;
        end;
      end;
      if not Collides then Break;
      Node := Node.Prev;
    end;
    if Node = nil then
    begin
      Entry.Position := Entry.Ship.Position;
      Entry.Ship.ClearMovementPath;
    end
    else
    begin
      Entry.Position := Node.Position;
      if Node.Next <> nil then
      begin
        Entry.Ship.MovementPath.RemoveNodeRange(Node.Next, Entry.Ship.MovementPath.ActiveTail);
        Entry.Ship.MovementPath.ResampleBezierRange(Entry.Ship.MovementPath.ActiveHead, Entry.Ship.MovementPath.ActiveTail, BaseMovementStepsPerTurn);
      end;
    end;
  end;
  Count := Entries.Count;
  for I := 0 to Count - 1 do FreeEC(Entries[I]);
  Entries.Free;
end;
{ @end $7B0E78 }

{ @routine $7B12E0 TStar_RebuildShipMovementPaths }
procedure TStar.RebuildShipMovementPaths;
var I: Integer; Ship: TShip;
begin
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := TShip(Ships[I]);
    if Ship.InNormalSpace then Ship.BuildOrderMovementPath(MovementStepCount);
  end;
end;
{ @end $7B12E0 }

{ @routine $7B133C TStar_OpenSpaceScene }
procedure TStar.OpenSpaceScene(MapPanel: TPanelGI; Minimap: TObjectGI; Screen: TMessageLoopGI);
var
  I, J: Integer;
  Planet: TPlanet;
  Asteroid: TAsteroid;
  Hole: THole;
  Satellite: TSputnik;
  Ship: TShip;
  Item: TItem;
  Gate: PJumpGateEntry;
  Missile: TMissile;
begin
  if GetPlayer <> nil then
  begin
    SpaceProcess.RadarCenter := GetPlayer.Position;
    SpaceProcess.RadarRange := GetPlayer.GetRadarRange;
    SpaceProcess.ActionRange := GetPlayer.GetRadarRange;
    SpaceProcess.ActionColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
  end
  else
  begin
    SpaceProcess.RadarCenter := MakePointF(0, 0);
    SpaceProcess.RadarRange := 0;
    SpaceProcess.ActionRange := 0;
    SpaceProcess.ActionColor := 0;
  end;
  SpaceProcess.SystemRadius := ComputeMapDiameter div 2;
  SpaceProcess.PopulateAmbientObjects(ComputeMapDiameter div 2, BackgroundImage, GenerationSeed);
  SpaceProcess.OpenSpace(MapPanel, Screen);
  SpaceProcess.Space.MinimapScale := Minimap.ClientSize.X / ComputeMapDiameter;
  SpaceProcess.Space.AlphaShift := 0;
  if GetPlayer <> nil then
    if GetPlayer.IsHealthEffectActive(1) then SpaceProcess.Space.AlphaShift := 2;
  SpaceProcess.BindMinimap(Minimap);
  Graphic.AttachToSpace(SpaceProcess.Space);
  for I := 0 to Planets.Count - 1 do
  begin
    Planet := TPlanet(Planets[I]);
    Planet.Graphic.Civilized := Planet.OwnerId <> oiUninhabited;
    Planet.Graphic.SetMinimapOwner(Ord(Planet.OwnerId));
    if Planet.CustomFaction <> '' then
    begin
      J := GetCustomFactionPlanetIconNumber(Planet.CustomFaction);
      if J >= 0 then Planet.Graphic.SetMinimapOwner(J + 1 + 7);
    end;
    Planet.Graphic.SetSurfaceAnimationMask(Planet.GetSurfaceAnimationMask);
    Planet.Graphic.AttachToSpace(SpaceProcess.Space);
    if SputnikShow then
      for J := 0 to Planet.Satellites.Count - 1 do
      begin
        Satellite := TSputnik(Planet.Satellites[J]);
        Satellite.Graphic.OrbitCenter := Planet.GetPosition;
        Satellite.Graphic.AttachToSpace(SpaceProcess.Space);
      end;
  end;
  for I := 0 to Asteroids.Count - 1 do
  begin
    Asteroid := TAsteroid(Asteroids[I]);
    Asteroid.GraphObject.AttachToSpace(SpaceProcess.Space);
  end;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := TShip(Ships[I]);
    if Ship.InNormalSpace then
    begin
      Ship.Graphic.SetAlpha(255);
      if Ship.Graphic is TShip2SE then
      begin
        with TShip2SE(Ship.Graphic) do
          if (ShipTail = 2) or ((ShipTail = 1) and (GetPlayer = Ship)) then SetTailMode(1)
          else SetTailMode(0);
      end
      else if (Ship.Graphic is TRuinsSE) and (Ship.Graphic as TRuinsSE).HasTransitionImages then
        (Ship.Graphic as TRuinsSE).SetState(1);
      Ship.Graphic.AttachToSpace(SpaceProcess.Space);
      if Ship.InterceptorGraphic <> nil then
      begin
        Ship.InterceptorGraphic.SetAlpha(255);
        Ship.InterceptorGraphic.AttachToSpace(SpaceProcess.Space);
      end;
    end;
  end;
  for I := 0 to Items.Count - 1 do
  begin
    Item := TItem(Items[I]);
    Item.GetGraphObject.AttachToSpace(SpaceProcess.Space);
  end;
  for I := 0 to Galaxy.JumpGates.Count - 1 do
  begin
    Gate := Galaxy.JumpGates[I];
    TGateSE(Gate.Gate).SetState(2);
    Gate.Gate.AttachToSpace(SpaceProcess.Space);
  end;
  for I := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := THole(Galaxy.Holes[I]);
    if Hole.Star1 = Self then
    begin
      Hole.Graphic.SetPosition(Hole.Position1);
      THoleSE(Hole.Graphic).SetState(0);
      Hole.Graphic.AttachToSpace(SpaceProcess.Space);
    end
    else if Hole.Star2 = Self then
    begin
      Hole.Graphic.SetPosition(Hole.Position2);
      THoleSE(Hole.Graphic).SetState(0);
      Hole.Graphic.AttachToSpace(SpaceProcess.Space);
    end;
  end;
  for I := 0 to Missiles.Count - 1 do
  begin
    Missile := TMissile(Missiles[I]);
    Missile.GetGraphObject.AttachToSpace(SpaceProcess.Space);
  end;
end;
{ @end $7B133C }

{ @routine $7B1970 TStar_RefreshSpaceObjectPositions }
procedure TStar.RefreshSpaceObjectPositions;
var
  Planet: TPlanet;
  Asteroid: TAsteroid;
  Ship: TShip;
  Item: TItem;
  I, J: Integer;
  Satellite: TSputnik;
  Missile: TMissile;
begin
  for I := 1 to Planets.Count do
  begin
    Planet := TPlanet(Planets[I - 1]);
    Planet.Graphic.SetPosition(PolarToPoint(Planet.Orbit));
    for J := 0 to Planet.Satellites.Count - 1 do
    begin
      Satellite := TSputnik(Planet.Satellites[J]);
      Satellite.Graphic.OrbitCenter := Planet.GetPosition;
      Satellite.Graphic.UpdateOrbitDisplay;
    end;
  end;
  for I := 0 to Asteroids.Count - 1 do
  begin
    Asteroid := TAsteroid(Asteroids[I]);
    Asteroid.GraphObject.SetPosition(Asteroid.Position);
  end;
  for I := 1 to Ships.Count do
  begin
    Ship := TShip(Ships[I - 1]);
    Ship.Graphic.SetPosition(Ship.Position);
    Ship.Graphic.SetAngle(HeadingDegreesToByte(Ship.MovementDirection));
  end;
  for I := 1 to Items.Count do
  begin
    Item := TItem(Items[I - 1]);
    Item.GetGraphObject.SetPosition(Item.Position);
  end;
  for I := 0 to Missiles.Count - 1 do
  begin
    Missile := TMissile(Missiles[I]);
    Missile.GetGraphObject.SetPosition(Missile.Position);
    Missile.GetGraphObject.SetAngle(HeadingDegreesToByte(Missile.Direction));
  end;
end;
{ @end $7B1970 }

{ @routine $7B1B8C TStar_QueueSpaceImageLoads }
procedure TStar.QueueSpaceImageLoads(PendingLoads: TList; Owner: TObjectGI);
var
  Planet: TPlanet;
  Ship: TShip;
  Hole: THole;
  Item: TItem;
  I, J: Integer;
  Satellite: TSputnik;
  Asteroid: TAsteroid;
begin
  Graphic.QueueImageLoad(PendingLoads, Owner);
  if (TerronShip <> nil) and (TerronShip.CurrentStar = Self) and AnimStar then
  begin
    with TgaiGI.Create(Owner) do
    begin
      SetImagePath('Bm.Star.Terron_Transform_a');
      QueueImageLoad(PendingLoads);
      Free;
    end;
    with TgaiGI.Create(Owner) do
    begin
      SetImagePath('Bm.Star.TerronAfter_a');
      QueueImageLoad(PendingLoads);
      Free;
    end;
  end;
  for I := 1 to Planets.Count do
  begin
    Planet := TPlanet(Planets[I - 1]);
    Planet.Graphic.QueueImageLoad(PendingLoads, Owner);
    if SputnikShow then
      for J := 0 to Planet.Satellites.Count - 1 do
      begin
        Satellite := TSputnik(Planet.Satellites[J]);
        Satellite.Graphic.QueueImageLoad(PendingLoads, Owner);
      end;
  end;
  for I := 1 to Ships.Count do
  begin
    Ship := TShip(Ships[I - 1]);
    Ship.Graphic.QueueImageLoad(PendingLoads, Owner);
  end;
  for I := 1 to Items.Count do
  begin
    Item := TItem(Items[I - 1]);
    Item.GetGraphObject.QueueImageLoad(PendingLoads, Owner);
  end;
  for I := 0 to Asteroids.Count - 1 do
  begin
    Asteroid := TAsteroid(Asteroids[I]);
    Asteroid.GraphObject.QueueImageLoad(PendingLoads, Owner);
  end;
  for I := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := THole(Galaxy.Holes[I]);
    if (Hole.Star1 = Self) or (Hole.Star2 = Self) then Hole.Graphic.QueueImageLoad(PendingLoads, Owner);
  end;
end;
{ @end $7B1B8C }

{ @routine $7B1E70 TStar_QueueHyperspaceShipImageLoads }
procedure TStar.QueueHyperspaceShipImageLoads(PendingLoads: TList; Owner: TObjectGI);
var Ship: TShip; I: Integer;
begin
  for I := 1 to Ships.Count do begin
    Ship := TShip(Ships[I - 1]);
    if Ship.InHyperspace then Ship.Graphic.QueueImageLoad(PendingLoads, Owner);
  end;
end;
{ @end $7B1E70 }

{ @routine $7B1ED8 TStar_GetBackgroundImagePath }
function TStar.GetBackgroundImagePath(out Size: Integer): WideString;
begin
  Size := 2000;
  if BackgroundImage < 10 then Result := 'Bm.BGO.bg0' + IntToStr(BackgroundImage)
  else Result := 'Bm.BGO.bg' + IntToStr(BackgroundImage);
end;
{ @end $7B1ED8 }

{ @routine $7B1FB8 TStar_ProcessItemScripts }
procedure TStar.ProcessItemScripts(TurnPhase: Integer);
var I: Integer; Item: TItem; Ship: TShip; Stage: Integer;
begin
  Stage := 0;
  try
    for I := Ships.Count - 1 downto 0 do
      if Ships.Count > I then
      begin
        Ship := Ships[I];
        Stage := 1;
        if not Ship.IsHullDestroyed and ((GetPlayer = Ship) or (Galaxy.StasisModEnabled <> 1)) then
          Ship.ScriptItemsAct(satOnStep, nil, nil, TurnPhase);
        Stage := 2;
      end;
    Stage := 3;
    if Galaxy.StasisModEnabled = 1 then Exit;
    for I := Items.Count - 1 downto 0 do
    begin
      Stage := 4;
      if Items.Count <= I then Continue;
      Item := Items[I];
      if Item.DestroyFlag > 0 then Continue;
      Stage := 5;
      if Item is TEquipmentWithActCode then
      begin
        RunItemConfigActionCode(Item, satOnStep, nil, Self, nil, TurnPhase);
        if (Items.Count <= I) or (Items[I] <> Item) then Continue;
      end;
      Stage := 6;
      if Item.ScriptItem <> nil then TScriptItem(Item.ScriptItem).RunActionCode(satOnStep, nil, Self, nil, TurnPhase);
      Stage := 7;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Error in procedure TStar.ScriptShipsAndItemsAct label = ' + IntToStr(Stage));
      raise;
    end;
  end;
end;
{ @end $7B1FB8 }

{ @routine $7B22A0 GameTurnToDateTime }
function GameTurnToDateTime(Turn: Integer): Double;
begin
  Result := Turn + 511341.5;
end;
{ @end $7B22A0 }

{ @routine $7B22C4 FormatGameTurnDate }
function FormatGameTurnDate(Turn: Integer): WideString;
var
  MonthNumber, MonthName: WideString;
begin
  MonthNumber := FormatDateTime('mm', GameTurnToDateTime(Turn - GalaxyWarmupTurns));
  MonthName := LocalizedText('Month.' + MonthNumber);
  Result := FormatDateTime('d', GameTurnToDateTime(Turn - GalaxyWarmupTurns)) + ' ' + MonthName + ' ' + FormatDateTime('yyyy', GameTurnToDateTime(Turn - GalaxyWarmupTurns));
end;
{ @end $7B22C4 }

{ @routine $7B247C ShouldContinuePlayerTravel }
function ShouldContinuePlayerTravel: Boolean;
begin
  if GetPlayer = nil then
  begin
    Result := False;
    Exit;
  end;
  if PlayerStar.KeepFilmRunning then
  begin
    Result := True;
    Exit;
  end;
  if not HasShownPlayerTip(18) and (GetPlayer.Order = soJumpHole) then
  begin
    ShowPlayerTipOnce(18);
    Result := False;
    Exit;
  end;
  if PlayerEquipmentBrokenThisTurn then
  begin
    Result := False;
    Exit;
  end;
  if (PendingPlayerFollowTarget <> nil) and (GetPlayer.GetHullIntegrityPercent < 25) then
  begin
    Result := False;
    Exit;
  end;
  if PlayerAutomaticControl or ((PendingPlayerFollowTarget <> nil) and not PlayerStar.InterruptLongTravel) then Result := True
  else
  begin
    GetPlayer.BuildOrderMovementPath(BaseMovementStepsPerTurn);
    if not PlayerStar.PlayerCombatOccurred and not PlayerStar.InterruptLongTravel and
       (GetPlayer.GetMovementPathTurnCount > 0) and
       ((GetPlayer.Order <> soMove) or (PointDistanceSquared(GetPlayer.Position, GetPlayer.OrderDestination) > 19600)) then
    begin
      if (GetPlayer.Order = soFollowShip) and
         (PointDistanceSquared(GetPlayer.Position, (GetPlayer.OrderTarget as TShip).Position) < Sqr(GetPlayer.Speed)) then
      begin
        Result := False;
        Exit;
      end;
      Result := True;
    end
    else Result := False;
  end;
end;
{ @end $7B247C }

{ @routine $7B2624 EstimatePlayerTravelTurns }
function EstimatePlayerTravelTurns: Single;
var Destination: TPointF;
begin
  Result := 0;
  if GetPlayer = nil then Exit;
  if PlayerStar.PlayerCombatOccurred or PlayerStar.InterruptLongTravel then Exit;
  if GetPlayer.PickupTargets <> nil then Exit;
  if PendingPlayerFollowTarget <> nil then Destination := PendingPlayerFollowTarget.Position
  else if GetPlayer.Order = soMove then Destination := GetPlayer.OrderDestination
  else if GetPlayer.Order = soJump then Destination := GetPlayer.OrderDestination
  else if (GetPlayer.Order = soJumpHole) and (GetPlayer.OrderStateData <> HoleExitOrderState) then Destination := GetPlayer.OrderDestination
  else if GetPlayer.Order = soLand then
  begin
    if GetPlayer.OrderTarget is TShip then Destination := TShip(GetPlayer.OrderTarget).Position
    else Destination := TPlanet(GetPlayer.OrderTarget).GetPosition;
  end
  else if GetPlayer.Order = soTakeoff then Exit
  else if GetPlayer.Order = soFollowShip then Destination := TShip(GetPlayer.OrderTarget).Position
  else Exit;
  Result := PointDistance(Destination, GetPlayer.Position) / (GetPlayer.Speed + 1);
end;
{ @end $7B2624 }

{ @routine $7B27E0 GetLocalObjectLink }
function GetLocalObjectLink(Obj: TObject; Suppress: Boolean): WideString;
var Local: Boolean;
begin
  if Suppress then begin Result := ''; Exit; end;
  Local := False;
  if not Local and (Obj is TShip) then
    if (Obj as TShip).CurrentStar = GetPlayer.CurrentStar then Local := True;
  if not Local and (Obj is TPlanet) then
    if (Obj as TPlanet).CurrentStar = GetPlayer.CurrentStar then Local := True;
  if not Local and (Obj is TItem) then
    if GetPlayer.CurrentStar.Items.IndexOf(Obj) >= 0 then Local := True;
  if Local then Result := '<Object=' + IntToStr(Cardinal(Obj)) + ',23,17,0>'
  else Result := '';
end;
{ @end $7B27E0 }

{ @routine $7B2954 TGalaxy_FindConstellationIndexForStar }
function TGalaxy.FindConstellationIndexForStar(Star: TStar): Integer;
var I: Integer; Constellation: TConstellation;
begin
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    if Constellation.ContainsPoint(Star.Position) then begin Result := I; Exit; end;
  end;
  Result := -1;
end;
{ @end $7B2954 }

{ @routine $7B29C0 TGalaxy_InitializeConstellationDistanceTiers }
procedure TGalaxy.InitializeConstellationDistanceTiers;
var I, J, Pass: Integer; Constellation, Other: TConstellation; Tier: Byte;
begin
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    if Constellation.SharesOutlineSegment(GetPlayer.HomePlanet.CurrentStar.Constellation) then Constellation.HomeDistanceTier := 0
    else Constellation.HomeDistanceTier := 3;
  end;
  Tier := 0;
  for Pass := 1 to 2 do begin
    for I := 0 to Constellations.Count - 1 do begin
      Constellation := TConstellation(Constellations[I]);
      for J := 0 to Constellations.Count - 1 do begin
        Other := TConstellation(Constellations[J]);
        if Other.SharesOutlineSegment(Constellation) and (Other.HomeDistanceTier = 3) and (Constellation.HomeDistanceTier = Tier) then
          Other.HomeDistanceTier := Tier + 1;
      end;
    end;
    Inc(Tier);
  end;
  if BlazerShip <> nil then BlazerShip.CurrentStar.Constellation.HomeDistanceTier := 3;
  if KellerShip <> nil then KellerShip.CurrentStar.Constellation.HomeDistanceTier := 3;
  if TerronShip <> nil then TerronShip.CurrentStar.Constellation.HomeDistanceTier := 3;
end;
{ @end $7B29C0 }

{ @routine $7B2B4C TGalaxy_BuildConstellationOutlineJunctions }
procedure TGalaxy.BuildConstellationOutlineJunctions;
var I, J, K: Integer; Segment, First, Next: PMapLineSegment; Temp: Pointer; Point: PPointF; Constellation, Other: TConstellation; Edges: TList; Outer: Boolean; TempPoint: TPointF; Distance: Single;
begin
  if ConstellationOutlineJunctions <> nil then begin
    for I := 0 to ConstellationOutlineJunctions.Count - 1 do begin
      Point := ConstellationOutlineJunctions[I];
      Dispose(Point);
    end;
    ConstellationOutlineJunctions.Clear;
  end else ConstellationOutlineJunctions := TList.Create;
  Edges := TList.Create;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    for J := 0 to Constellation.OutlineSegments.Count - 1 do begin
      Segment := Constellation.OutlineSegments[J];
      Outer := True;
      for K := 0 to Constellations.Count - 1 do
        if K <> I then begin
          Other := TConstellation(Constellations[K]);
          if Other.HasOutlineSegment(Segment.StartPoint, Segment.EndPoint) then begin Outer := False; Break; end;
        end;
      if Outer then begin
        GetMem(Next, SizeOf(TMapLineSegment));
        Next.StartPoint := Segment.StartPoint;
        Next.EndPoint := Segment.EndPoint;
        Edges.Add(Next);
      end;
    end;
  end;
  for I := 0 to Edges.Count - 2 do begin
    First := Edges[I];
    J := I + 1;
    while J < Edges.Count do begin
      Next := Edges[J];
      if PointsNearlyEqualF(First.EndPoint, Next.StartPoint) then Break;
      if PointsNearlyEqualF(First.EndPoint, Next.EndPoint) then begin
        TempPoint := Next.StartPoint;
        Next.StartPoint := Next.EndPoint;
        Next.EndPoint := TempPoint;
        Break;
      end;
      Inc(J);
    end;
    if J < Edges.Count then begin
      Temp := Edges[I + 1];
      Edges[I + 1] := Edges[J];
      Edges[J] := Temp;
    end;
  end;
  Distance := 0;
  for I := 0 to Edges.Count - 1 do begin
    Segment := Edges[I];
    Outer := False;
    K := 0;
    for J := 0 to Constellations.Count - 1 do begin
      Constellation := TConstellation(Constellations[J]);
      if Constellation.HasOutlineVertex(Segment.StartPoint) then begin
        Inc(K);
        if K > 1 then begin Outer := True; Break; end;
      end;
    end;
    if (Distance > 0) or (Outer <> False) then begin
      GetMem(Point, SizeOf(TPointF));
      Point^ := Segment.StartPoint;
      ConstellationOutlineJunctions.Add(Point);
      Distance := 0;
    end;
    Distance := PointDistanceF(Segment.StartPoint, Segment.EndPoint) + Distance;
  end;
  for I := 0 to Edges.Count - 1 do begin
    Segment := Edges[I];
    Dispose(Segment);
  end;
  Edges.Clear;
  Edges.Free;
end;
{ @end $7B2B4C }

{ @routine $7B2F34 TGalaxy_ShouldKeepConstellationOutlineVertex }
function TGalaxy.ShouldKeepConstellationOutlineVertex(Point: TPointF): Boolean;
var I, Count: Integer; Constellation: TConstellation; Vertex: PPointF;
begin
  Count := 0;
  if ConstellationOutlineJunctions = nil then begin
    if ScalarsNearlyEqualF(Point.X, 0) then Inc(Count);
    if ScalarsNearlyEqualF(Point.Y, 0) then Inc(Count);
    if ScalarsNearlyEqualF(Point.X, GalaxySizeY) then Inc(Count);
    if ScalarsNearlyEqualF(Point.Y, GalaxySizeY) then Inc(Count);
  end else begin
    for I := 0 to ConstellationOutlineJunctions.Count - 1 do begin
      Vertex := ConstellationOutlineJunctions[I];
      if PointsNearlyEqualF(Vertex^, Point) then begin Result := True; Exit; end;
    end;
  end;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    if Constellation.HasOutlineVertex(Point) then begin
      Inc(Count);
      if Count > 2 then Break;
    end;
  end;
  if Count > 2 then Result := True else Result := False;
end;
{ @end $7B2F34 }

{ @routine $7B306C TGalaxy_SimplifyConstellationOutline }
procedure TGalaxy.SimplifyConstellationOutline(ConstellationIndex: Integer);
var Constellation: TConstellation; I: Integer; Points: TList; Segment: PMapLineSegment; First, Last: PPointF; Polygon: TPolygon2D;
begin
  Constellation := TConstellation(Constellations[ConstellationIndex]);
  if Constellation <> nil then begin
    Points := TList.Create;
    for I := 0 to Constellation.OutlineSegments.Count - 1 do begin
      Segment := Constellation.OutlineSegments[I];
      if ShouldKeepConstellationOutlineVertex(Segment.StartPoint) then begin
        GetMem(First, SizeOf(TPointF));
        First^ := Segment.StartPoint;
        Points.Add(First);
      end;
    end;
    Constellation.ClearOutlineSegmentsAndBounds;
    for I := 0 to Points.Count - 1 do begin
      First := Points[I];
      if I = Points.Count - 1 then Last := Points[0] else Last := Points[I + 1];
      GetMem(Segment, SizeOf(TMapLineSegment));
      Segment.StartPoint := First^;
      Segment.EndPoint := Last^;
      Constellation.OutlineSegments.Add(Segment);
    end;
    Constellation.RefreshOutlineBounds;
    Polygon := nil;
    for I := 0 to Points.Count - 1 do begin
      First := Points[I];
      if I = Points.Count - 1 then Last := Points[0] else Last := Points[I + 1];
      if Polygon = nil then Polygon := TPolygon2D.CreateTriangle(First^, Last^, Constellation.MapCenter)
      else Polygon.Append(TPolygon2D.CreateTriangle(First^, Last^, Constellation.MapCenter));
    end;
    Constellation.SetOutlinePolygon(Polygon);
    for I := 0 to Points.Count - 1 do Dispose(PPointF(Points[I]));
    Points.Free;
  end;
end;
{ @end $7B306C }

{ @routine $7B32B0 TGalaxy_BuildConstellationStarGraphs }
function TGalaxy.BuildConstellationStarGraphs: Boolean;
var I: Integer; Constellation: TConstellation;
begin
  Result := True;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    if not Constellation.BuildStarGraph then Result := False;
  end;
end;
{ @end $7B32B0 }

{ @routine $7B330C TGalaxy_BuildConstellationPolygonsAndAdjacency }
procedure TGalaxy.BuildConstellationPolygonsAndAdjacency(WorkingPolygon: TPolygon2D);
var I, J: Integer; Constellation, Other: TConstellation; Pass, Steps: Integer; Sample: PConstellationBoundaryRaySample; PreviousPoint, Point: TPointF; Step: Single;
begin
  Step := 3;
  WorkingPolygon.ResetChainGroups;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    WorkingPolygon.AssignGroupAtPoint(Constellation.MapCenter, I);
    Constellation.GenerateBoundaryRaySamples(128);
  end;
  Steps := Trunc(GalaxySizeY / Sqrt(Cardinal(ConstellationCount)) / Step * 0.5) + 1;
  for I := 0 to 7 do begin
    Constellation := TConstellation(Constellations[I]);
    Constellation.OutlineGrowthStepsRemaining := Steps + 20;
  end;
  Inc(Steps, 20);
  for I := 8 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    Constellation.OutlineGrowthStepsRemaining := Steps;
  end;
  Pass := -1;
  repeat
    for I := 0 to Constellations.Count - 1 do begin
      Constellation := TConstellation(Constellations[I]);
      if Cardinal(Constellation.OutlineGrowthStepsRemaining) > 0 then begin
        for J := 0 to Constellation.BoundaryRaySamples.Count - 1 do begin
          Sample := Constellation.BoundaryRaySamples[J];
          if not Sample.GrowthStopped then begin
            PreviousPoint := Sample.Position;
            Point := MakePointF(Step * Sample.Direction.X + PreviousPoint.X, Step * Sample.Direction.Y + PreviousPoint.Y);
            if (Point.X < 0) or (GalaxySizeX * 1 <= Point.X) or (Point.Y < 0) or (GalaxySizeY * 1 <= Point.Y) then Point := PreviousPoint;
            Sample.Position := Point;
            Sample.GrowthStopped := not WorkingPolygon.AssignGroupAtPoint(Point, I);
          end;
        end;
        Dec(Constellation.OutlineGrowthStepsRemaining);
      end;
    end;
    Inc(Pass);
  until Pass >= Steps;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    Constellation.SetOutlinePolygon(WorkingPolygon.ExtractFollowingGroup(I));
  end;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := TConstellation(Constellations[I]);
    for J := I + 1 to Constellations.Count - 1 do begin
      Other := TConstellation(Constellations[J]);
      if Constellation.SharesOutlineSegment(Other) then begin
        Constellation.AddAdjacentConstellation(Other);
        Other.AddAdjacentConstellation(Constellation);
      end;
    end;
  end;
end;
{ @end $7B330C }

{ @routine $7B36A8 TGalaxy_GenerateGalaxyLayout }
procedure TGalaxy.GenerateGalaxyLayout(PlayerRace: TOwnerId);
var I, J, UnusedIndex, K, FirstIndex, SecondIndex, N, Attempts: Integer;
  Star, OtherStar, SecondStar: TStar; InvalidLayout: Boolean;
  FuelRange, NearestDistance, Distance: Integer; Reached: array of Boolean;
  Constellation, OtherConstellation: TConstellation; Reserved1, Reserved2: Integer;
  MinimumConstellationDistance, MinimumStarDistance, ConstellationIndex: Integer;
  BoundsSize: TPoint; BestAreaPerStar, AreaPerStar: Double;
  WorkingPolygon, Polygon: TPolygon2D; Reserved3: Integer; Occupied: Boolean;
  MinimumArea, MaximumArea: Single; PlacementAttempts, TotalLinks, AxisLinks: Integer;
  Link: PConstellationStarLink; Coordinate: Single; GenerationAttempts, HumanPosition: Integer;
  // Native unused scalar locals remain explicit; their original purposes are unknown.
  Reserved4A, Reserved4B, Reserved4C: Integer; RaceOrder: array[0..7] of 0..7;
  CoalitionPositions: array[0..4] of Byte;
  Reserved5_0, Reserved5_1, Reserved5_2, Reserved5_3, Reserved5_4, Reserved5_5: Integer;
  Reserved5_6, Reserved5_7, Reserved5_8, Reserved5_9, Reserved5_10, Reserved5_11: Integer;
  Reserved5_12, Reserved5_13, Reserved5_14, Reserved5_15, Reserved5_16, Reserved5_17: Integer;
  Reserved5_18, Reserved5_19, Reserved5_20, Reserved5_21, Reserved5_22, Reserved5_23: Integer;
  Reserved5_24, Reserved5_25, Reserved5_26, Reserved5_27, Reserved5_28, Reserved5_29: Integer;
  Bounds: TRect;
begin
  System.RandSeed := aGalaxy.Galaxy.GenerationSeed;
  Constellations.Clear;
  for I := 1 to ConstellationCount do begin
    Constellation := TConstellation.Create;
    Constellations.Add(Constellation);
  end;
  MinimumConstellationDistance := Round(Sqrt(GalaxySizeY * GalaxySizeY / Cardinal(ConstellationCount)) * 0.75);
  MinimumArea := GalaxySizeX * 0.52 * GalaxySizeY / Cardinal(ConstellationCount);
  MaximumArea := (GalaxySizeX * 1) * 1.5 * (GalaxySizeY * 1) / Cardinal(ConstellationCount);
  GenerationAttempts := 0;
  repeat
    WorkingPolygon := TPolygon2D.Create;
    Polygon := TPolygon2D.Create;
    Polygon.SetRectangle(Classes.Rect(0, 0, GalaxySizeX, GalaxySizeY));
    WorkingPolygon.Append(Polygon);
    Coordinate := 5;
    while Coordinate < GalaxySizeX * 1 do begin
      WorkingPolygon.SplitChainByPoints(MakePointF(Coordinate, 0), MakePointF(Coordinate, GalaxySizeY));
      Coordinate := Coordinate + 5;
    end;
    Coordinate := 5;
    while Coordinate < GalaxySizeY * 1 do begin
      WorkingPolygon.SplitChainByPoints(MakePointF(0, Coordinate), MakePointF(GalaxySizeX, Coordinate));
      Coordinate := Coordinate + 5;
    end;
    for I := 0 to 7 do RaceOrder[I] := I;
    for K := 1 to NextRandomIntRange(0, 3, aGalaxy.Galaxy.RandomState) do
      for I := 0 to 7 do begin
        RaceOrder[I] := DecrementWrappedValue(RaceOrder[I], 0, 7);
        RaceOrder[I] := DecrementWrappedValue(RaceOrder[I], 0, 7);
      end;
    N := 0;
    for I := 0 to 7 do
      if RaceOrder[I] in [0..4] then begin
        CoalitionPositions[N] := I;
        Inc(N);
        if RaceOrder[I] = 2 then HumanPosition := I;
      end;
    N := 0;
    repeat
      repeat
        I := CoalitionPositions[NextRandomIntRange(0, 4, aGalaxy.Galaxy.RandomState)];
        K := CoalitionPositions[NextRandomIntRange(0, 4, aGalaxy.Galaxy.RandomState)];
      until I <> K;
      Attempts := RaceOrder[I];
      RaceOrder[I] := RaceOrder[K];
      RaceOrder[K] := Attempts;
      Inc(N);
    until (N > 3) and (Ord(PlayerRace) = RaceOrder[HumanPosition]);
    Constellation := TConstellation(Constellations[RaceOrder[0]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (MinimumConstellationDistance * 0.6);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (MinimumConstellationDistance * 0.6);
    Constellation := TConstellation(Constellations[RaceOrder[1]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (GalaxySizeX / 2 - 1);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (MinimumConstellationDistance * 0.6);
    Constellation := TConstellation(Constellations[RaceOrder[2]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (GalaxySizeX - MinimumConstellationDistance * 0.6 - 2);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (MinimumConstellationDistance * 0.6);
    Constellation := TConstellation(Constellations[RaceOrder[3]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (GalaxySizeX - MinimumConstellationDistance * 0.4 - 2);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (GalaxySizeY / 2 - 1);
    Constellation := TConstellation(Constellations[RaceOrder[4]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (GalaxySizeX - MinimumConstellationDistance * 0.6 - 2);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (GalaxySizeY - MinimumConstellationDistance * 0.6 - 2);
    Constellation := TConstellation(Constellations[RaceOrder[5]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (GalaxySizeX / 2 - 1);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (GalaxySizeY - MinimumConstellationDistance * 0.6 - 2);
    Constellation := TConstellation(Constellations[RaceOrder[6]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (MinimumConstellationDistance * 0.6);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (GalaxySizeY - MinimumConstellationDistance * 0.6 - 2);
    Constellation := TConstellation(Constellations[RaceOrder[7]]);
    Constellation.ResetGeneratedMapShape;
    Constellation.MapCenter.X := RandomIntRange(0, 2) + (MinimumConstellationDistance * 0.6);
    Constellation.MapCenter.Y := RandomIntRange(0, 2) + (GalaxySizeY / 2 - 1);
    for I := 0 to 7 do if Integer(RaceOrder[I]) = Integer(PlayerRace) then Break;
    OtherConstellation := TConstellation(Constellations[RaceOrder[I]]);
    if OtherConstellation.MapCenter.X < GalaxySizeX * 0.15 then K := 1 else K := -1;
    if OtherConstellation.MapCenter.Y < GalaxySizeY * 0.2 then Attempts := 1 else Attempts := -1;
    if Attempts = 1 then OtherConstellation := TConstellation(Constellations[RaceOrder[1]])
    else OtherConstellation := TConstellation(Constellations[RaceOrder[5]]);
    Constellation := TConstellation(Constellations[Constellations.Count - 1]);
    Constellation.MapCenter := OtherConstellation.MapCenter;
    Constellation.MapCenter.X := Constellation.MapCenter.X + 6 * K;
    Constellation.MapCenter.Y := Constellation.MapCenter.Y - 4 * Attempts;
    OtherConstellation.MapCenter.X := OtherConstellation.MapCenter.X - 4 * K;
    for I := 8 to Constellations.Count - 2 do begin
      Constellation := TConstellation(Constellations[I]);
      Constellation.ResetGeneratedMapShape;
      Constellation.MapCenter.X := 0;
      Constellation.MapCenter.Y := 0;
      PlacementAttempts := 0;
      while True do begin
        Inc(PlacementAttempts);
        if PlacementAttempts > 100 then Break;
        Constellation.MapCenter.X := RandomIntRange(0, GalaxySizeX - 1) + 1;
        Constellation.MapCenter.Y := RandomIntRange(0, GalaxySizeY - 1) + 1;
        if (Constellation.MapCenter.X < MinimumConstellationDistance * 0.4) or
          (Constellation.MapCenter.X > GalaxySizeX - MinimumConstellationDistance * 0.4) or
          (Constellation.MapCenter.Y < MinimumConstellationDistance * 0.4) or
          (Constellation.MapCenter.Y > GalaxySizeY - MinimumConstellationDistance * 0.4) then Continue;
        Occupied := False;
        for K := 0 to I do begin
          if K = I then OtherConstellation := TConstellation(Constellations[Constellations.Count - 1])
          else OtherConstellation := TConstellation(Constellations[K]);
          if WorkingPolygon.FindContainingPolygon(Constellation.MapCenter) =
            WorkingPolygon.FindContainingPolygon(OtherConstellation.MapCenter) then begin
            Occupied := True;
            Break;
          end;
        end;
        if Occupied then Continue;
        NearestDistance := Max(GalaxySizeX, GalaxySizeY);
        for K := 0 to I do begin
          if K = I then OtherConstellation := TConstellation(Constellations[Constellations.Count - 1])
          else OtherConstellation := TConstellation(Constellations[K]);
          Distance := Round(PointDistance(Constellation.MapCenter, OtherConstellation.MapCenter));
          if Distance < NearestDistance then NearestDistance := Distance;
        end;
        if (NearestDistance >= MinimumConstellationDistance) and (NearestDistance >= 7.0) then Break;
      end;
    end;
    BuildConstellationPolygonsAndAdjacency(WorkingPolygon);
    WorkingPolygon.Free;
    InvalidLayout := False;
    for I := 0 to Constellations.Count - 1 do begin
      Constellation := TConstellation(Constellations[I]);
      Constellation.NormalizeOutlineSegmentOrder;
    end;
    BuildConstellationOutlineJunctions;
    for I := 0 to Constellations.Count - 1 do SimplifyConstellationOutline(I);
    TotalLinks := 0;
    AxisLinks := 0;
    for I := 0 to Constellations.Count - 1 do begin
      Constellation := TConstellation(Constellations[I]);
      if (Constellation.OutlinePolygons.GetChainArea < MinimumArea) or
        (Constellation.OutlinePolygons.GetChainArea > MaximumArea) then begin
        InvalidLayout := True;
        Break;
      end;
      if Constellation.OutlinePolygons.ChainSelfIntersects then begin
        InvalidLayout := True;
        Break;
      end;
      Inc(TotalLinks, Constellation.StarLinks.Count);
      for K := 0 to Constellation.StarLinks.Count - 1 do begin
        Link := Constellation.StarLinks[K];
        if (Link.StartPoint.Y = Link.EndPoint.Y) or (Link.StartPoint.X = Link.EndPoint.X) then Inc(AxisLinks);
      end;
      for J := I + 1 to Constellations.Count - 1 do
        if Constellation.OutlinePolygons.IntersectsChain(TConstellation(Constellations[J]).OutlinePolygons) then begin
          InvalidLayout := True;
          Break;
        end;
      if InvalidLayout then Break;
    end;
    if AxisLinks * 7 > TotalLinks then InvalidLayout := True;
    Inc(GenerationAttempts);
  until (GenerationAttempts > 1000) or not InvalidLayout;
  GenerationAttempts := 0;
  repeat
    for I := 0 to Constellations.Count - 1 do begin
      Constellation := TConstellation(Constellations[I]);
      Constellation.ClearStars;
    end;
    for I := 0 to aGalaxy.Galaxy.Stars.Count - 1 do begin
      Star := TStar(aGalaxy.Galaxy.Stars[I]);
      Star.Position.X := 0;
      Star.Position.Y := 0;
    end;
    for I := 0 to aGalaxy.Galaxy.Stars.Count - 1 do begin
      Star := TStar(aGalaxy.Galaxy.Stars[I]);
      if (I = 70) or (I = 71) then ConstellationIndex := Constellations.Count - 1
      else begin
        if I < 65 then ConstellationIndex := I mod 18
        else begin
          ConstellationIndex := 18;
          if I > 68 then ConstellationIndex := I mod (Constellations.Count - 1);
        end;
        if (I > aGalaxy.Galaxy.Stars.Count / 1.46) and (System.Random < 0.6) then begin
          BestAreaPerStar := 0;
          for K := 0 to Constellations.Count - 2 do
            if (I < 65) or (K >= 8) then begin
              Constellation := TConstellation(Constellations[K]);
              if Constellation.Stars.Count = 0 then AreaPerStar := Constellation.GetOutlineArea * 2
              else AreaPerStar := Constellation.GetOutlineArea / Constellation.Stars.Count;
              if AreaPerStar > BestAreaPerStar then begin
                ConstellationIndex := K;
                BestAreaPerStar := AreaPerStar;
              end;
            end;
        end;
      end;
      Constellation := TConstellation(Constellations[ConstellationIndex]);
      Constellation.AddStar(Star);
      Bounds := Constellation.OutlineBounds;
      BoundsSize := Constellation.OutlineBoundsSize;
      MinimumStarDistance := Round(Sqrt(Constellation.GetOutlineArea / (Stars.Count div Constellations.Count)) * 0.5);
      FuelRange := CalculateGeneratedFuelCapacity(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1);
      Attempts := 0;
      while True do begin
        // Separate tests release the conversion temporary between the X/Y bounds.
        while True do begin
          Star.Position.X := Bounds.Left + RandomIntRange(0, Round(BoundsSize.X * 1.0) - 1) + BoundsSize.X * 0.0;
          Star.Position.Y := Bounds.Top + RandomIntRange(0, Round(BoundsSize.Y * 1.0) - 1) + BoundsSize.Y * 0.0;
          if Star.Position.X + 0.5 >= 8.0 then
            if Star.Position.X + 0.5 <= GalaxySizeX - 8 then
              if Star.Position.Y + 0.5 >= 5.0 then
                if Star.Position.Y + 0.5 <= GalaxySizeY - 8 then
                  if Constellation.ContainsPoint(Star.Position) then Break;
        end;
        Inc(Attempts);
        if Attempts > 100 then Break;
        if Constellation.IsPointNearOutline(Star.Position) then Continue;
        NearestDistance := MaxInt;
        for K := 0 to I - 1 do begin
          OtherStar := TStar(aGalaxy.Galaxy.Stars[K]);
          Distance := Round(PointDistance(Star.Position, OtherStar.Position));
          if NearestDistance > Distance then NearestDistance := Distance;
        end;
        if (NearestDistance >= 4) and ((NearestDistance <= FuelRange) or (Ord(PlayerRace) <> ConstellationIndex) or
          (ConstellationCount >= I)) and ((NearestDistance >= MinimumStarDistance) or (Attempts >= 20)) then Break;
      end;
    end;
    InvalidLayout := False;
    SetLength(Reached, aGalaxy.Galaxy.Stars.Count + 1);
    for K := 0 to aGalaxy.Galaxy.Stars.Count - 1 do Reached[K] := False;
    Reached[Ord(PlayerRace)] := True;
    FuelRange := CalculateGeneratedFuelCapacity(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1);
    N := 0;
    for FirstIndex := 0 to aGalaxy.Galaxy.Stars.Count - 1 do begin
      OtherStar := TStar(aGalaxy.Galaxy.Stars[FirstIndex]);
      for SecondIndex := 0 to aGalaxy.Galaxy.Stars.Count - 1 do begin
        SecondStar := TStar(aGalaxy.Galaxy.Stars[SecondIndex]);
        if (FirstIndex <> SecondIndex) and (Abs(OtherStar.Position.X - SecondStar.Position.X) < 7.0) and
          (Abs(OtherStar.Position.Y - SecondStar.Position.Y) < 2.0) then begin
          InvalidLayout := True;
          Break;
        end;
        Distance := Round(PointDistance(OtherStar.Position, SecondStar.Position));
        if (Distance <= FuelRange) and ((Reached[FirstIndex] and not Reached[SecondIndex]) or
          (Reached[SecondIndex] and not Reached[FirstIndex])) then begin
          Reached[FirstIndex] := True;
          Reached[SecondIndex] := True;
          Inc(N);
          if N > 2 then Break;
        end;
      end;
      if InvalidLayout then Break;
    end;
    if N < 3 then InvalidLayout := True;
    if not InvalidLayout then
      if not BuildConstellationStarGraphs then InvalidLayout := True;
    Inc(GenerationAttempts);
  until (GenerationAttempts > 50) or not InvalidLayout;
  SetLength(Reached, 0);
end;
{ @end $7B36A8 }

{ @routine $7B4E44 TGalaxy_HideSpecialConstellation }
procedure TGalaxy.HideSpecialConstellation;
var I, J, K, SegmentIndex, EarIndex, LastIndex, Reserved20, MiddleIndex: Integer;
  Star: TStar; Reserved2C, Reserved30: Integer; ReservedFlag, ContainsStar: Boolean;
  Reserved38: Integer; Current, Candidate, Hidden: TConstellation;
  Reserved48, Reserved4C, Reserved50, Reserved54, Reserved58, Reserved5C, Reserved60, Reserved64: Integer;
  Polygon, SourcePolygon: TPolygon2D;
  Reserved70, Reserved74, Reserved78, Reserved7C, Reserved80, Reserved84: Integer;
  Segment: PMapLineSegment;
  Reserved8C, Reserved90, Reserved94, Reserved98, Reserved9C, ReservedA0: Integer;
  Neighbors, XList, YList, BestX, BestY, WorkX, WorkY: TList;
  AreaAfterUnrestrictedTrim, AreaAfterStarSafeTrim, FullArea: Single; BestScore, Score, CrossEar, CrossMid: Double;
  MidX, MidY: Single; ReservedF4: Integer; AX, BX, CX, AY, BY, CY: Single;
  MaxX, MinX, MaxY, MinY, NewX, NewY, IntersectionX, Determinant: Single;
  Reserved130: Integer; Point: PPointF; SwapList: Pointer; Flag: Byte;
  UnusedLocalBytes: array[0..15] of Byte; // Native gap before backend temporaries.
  // @nested $7B4D48 PointInsideTriangle
  function PointInsideTriangle(PointX, PointY, AX, AY, BX, BY, CX, CY: Single): Boolean; // @addr 0x7B4D48 @ida "bool __usercall $name@<al>(float PointX@<^28>, float PointY@<^24>, float AX@<^20>, float AY@<^16>, float BX@<^12>, float BY@<^8>, float CX@<^4>, float CY@<^0>, void *ParentFrame@<^32>);" @stackpop 0x20 @calls "0x7B5DBF 0x7B6159 0x7B6379 0x7B6717 0x7B6787 0x7B69BD" @note "Strict interior only; excludes edges and degenerate triangles. The caller-popped static link is unused."
  begin
    Result := False;
    if (((BX - AX) * (BY - CY) - (BY - AY) * (BX - CX)) *
      ((BX - AX) * (BY - PointY) - (BY - AY) * (BX - PointX)) > 0) and
      (((CX - BX) * (CY - AY) - (CY - BY) * (CX - AX)) *
      ((CX - BX) * (CY - PointY) - (CY - BY) * (CX - PointX)) > 0) and
      (((AX - CX) * (AY - BY) - (AY - CY) * (AX - BX)) *
      ((AX - CX) * (AY - PointY) - (AY - CY) * (AX - PointX)) > 0) then Result := True;
  end;
begin
  // Delphi's Pointer/Single hard casts preserve bits, including signed zero.
  // The temporary coordinate lists intentionally store those bits in pointer slots.
  Neighbors := TList.Create;
  XList := TList.Create;
  YList := TList.Create;
  BestX := nil;
  BestY := nil;
  Hidden := aGalaxy.Galaxy.IdToConstellation(20);
  for I := 0 to Constellations.Count - 1 do begin
    Current := TConstellation(Constellations[I]);
    if Current <> Hidden then
      for SegmentIndex := 0 to Hidden.OutlineSegments.Count - 1 do
        if Current.HasOutlineSegment(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint,
          PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint) then begin
          Neighbors.Add(Current);
          Break;
        end;
  end;
  BestScore := -1;
  Candidate := nil;
  for I := 0 to Neighbors.Count - 1 do begin
    Current := Neighbors[I];
    XList.Clear;
    YList.Clear;
    for SegmentIndex := 0 to Hidden.OutlineSegments.Count - 1 do
      if Current.HasOutlineSegment(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint,
        PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint) then begin
        XList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.X));
        YList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.Y));
        XList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.X));
        YList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.Y));
      end;
    MaxX := Single(XList[0]);
    MinX := Single(XList[0]);
    MaxY := Single(YList[0]);
    MinY := Single(YList[0]);
    for SegmentIndex := 1 to XList.Count - 1 do begin
      MaxX := Max(MaxX, Single(XList[SegmentIndex]));
      MinX := Min(MinX, Single(XList[SegmentIndex]));
      MaxY := Max(MaxY, Single(YList[SegmentIndex]));
      MinY := Min(MinY, Single(YList[SegmentIndex]));
    end;
    MidX := (MaxX + MinX) * 0.5;
    MidY := (MaxY + MinY) * 0.5;
    XList.Clear;
    YList.Clear;
    SegmentIndex := 0;
    while Current.HasOutlineSegment(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint,
      PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint) do Inc(SegmentIndex);
    XList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.X));
    YList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.Y));
    XList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.X));
    YList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.Y));
    while True do begin
      MiddleIndex := XList.Count;
      for SegmentIndex := 0 to Hidden.OutlineSegments.Count - 1 do
        if not Current.HasOutlineSegment(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint,
          PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint) then begin
          if ((PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.X = Single(XList[XList.Count - 1])) and
          (PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.Y = Single(YList[XList.Count - 1]))) and not
            ((PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.X = Single(XList[XList.Count - 2])) and
          (PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.Y = Single(YList[XList.Count - 2]))) then begin
            XList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.X));
            YList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.Y));
          end else if ((PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.X = Single(XList[XList.Count - 1])) and
          (PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).EndPoint.Y = Single(YList[XList.Count - 1]))) and not
            ((PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.X = Single(XList[XList.Count - 2])) and
          (PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.Y = Single(YList[XList.Count - 2]))) then begin
            XList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.X));
            YList.Add(Pointer(PMapLineSegment(Hidden.OutlineSegments[SegmentIndex]).StartPoint.Y));
          end;
          if (XList[XList.Count - 1] = XList[0]) and (YList[YList.Count - 1] = YList[0]) then Break;
        end;
      if (XList[XList.Count - 1] = XList[0]) and (YList[YList.Count - 1] = YList[0]) then begin
        XList.Delete(XList.Count - 1);
        YList.Delete(YList.Count - 1);
        Break;
      end;
      for SegmentIndex := 0 to Current.OutlineSegments.Count - 1 do
        if not Hidden.HasOutlineSegment(PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint,
          PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint) then begin
          if ((PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint.X = Single(XList[XList.Count - 1])) and
          (PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint.Y = Single(YList[XList.Count - 1]))) and not
            ((PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint.X = Single(XList[XList.Count - 2])) and
          (PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint.Y = Single(YList[XList.Count - 2]))) then begin
            XList.Add(Pointer(PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint.X));
            YList.Add(Pointer(PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint.Y));
          end else if ((PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint.X = Single(XList[XList.Count - 1])) and
          (PMapLineSegment(Current.OutlineSegments[SegmentIndex]).EndPoint.Y = Single(YList[XList.Count - 1]))) and not
            ((PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint.X = Single(XList[XList.Count - 2])) and
          (PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint.Y = Single(YList[XList.Count - 2]))) then begin
            XList.Add(Pointer(PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint.X));
            YList.Add(Pointer(PMapLineSegment(Current.OutlineSegments[SegmentIndex]).StartPoint.Y));
          end;
          if (XList[XList.Count - 1] = XList[0]) and (YList[YList.Count - 1] = YList[0]) then Break;
        end;
      if (XList[XList.Count - 1] = XList[0]) and (YList[YList.Count - 1] = YList[0]) then begin
        XList.Delete(XList.Count - 1);
        YList.Delete(YList.Count - 1);
        Break;
      end;
      if XList.Count = MiddleIndex then Break;
    end;
    Score := 0;
    WorkX := TList.Create;
    WorkY := TList.Create;
    for EarIndex := 0 to XList.Count - 1 do begin
      WorkX.Add(XList[EarIndex]);
      WorkY.Add(YList[EarIndex]);
    end;
    FullArea := 0;
    while WorkX.Count > 2 do
      for EarIndex := 0 to WorkX.Count - 1 do begin
        LastIndex := EarIndex + 2;
        MiddleIndex := EarIndex + 1;
        if LastIndex >= WorkX.Count then Dec(LastIndex, WorkX.Count);
        if MiddleIndex >= WorkX.Count then Dec(MiddleIndex, WorkX.Count);
        AX := Single(WorkX[EarIndex]);
        BX := Single(WorkX[LastIndex]);
        CX := Single(WorkX[MiddleIndex]);
        AY := Single(WorkY[EarIndex]);
        BY := Single(WorkY[LastIndex]);
        CY := Single(WorkY[MiddleIndex]);
        Flag := 0;
        for J := 0 to WorkX.Count - 1 do
          if (J <> EarIndex) and (J <> LastIndex) and (J <> MiddleIndex) then begin
            if PointInsideTriangle(Single(WorkX[J]), Single(WorkY[J]), AX, AY, BX, BY, CX, CY) then Flag := 1;
            if Flag = 1 then Break;
          end;
        if Flag = 1 then Continue;
        CrossEar := (BX - AX) * (BY - CY) - (BY - AY) * (BX - CX);
        CrossMid := (BX - AX) * (BY - MidY) - (BY - AY) * (BX - MidX);
        if (CrossEar * CrossMid <= 0) or (WorkX.Count = 3) then begin
          FullArea := FullArea + Abs(CrossEar * 0.5);
          WorkX.Delete(MiddleIndex);
          WorkY.Delete(MiddleIndex);
          Break;
        end;
      end;
    WorkX.Clear;
    WorkY.Clear;
    for EarIndex := 0 to XList.Count - 1 do begin
      WorkX.Add(XList[EarIndex]);
      WorkY.Add(YList[EarIndex]);
    end;
    AreaAfterUnrestrictedTrim := 0;
    while WorkX.Count > 2 do begin
      Flag := 0;
      for EarIndex := 0 to WorkX.Count - 1 do begin
        LastIndex := EarIndex + 2;
        MiddleIndex := EarIndex + 1;
        if LastIndex >= WorkX.Count then Dec(LastIndex, WorkX.Count);
        if MiddleIndex >= WorkX.Count then Dec(MiddleIndex, WorkX.Count);
        AX := Single(WorkX[EarIndex]);
        BX := Single(WorkX[LastIndex]);
        CX := Single(WorkX[MiddleIndex]);
        AY := Single(WorkY[EarIndex]);
        BY := Single(WorkY[LastIndex]);
        CY := Single(WorkY[MiddleIndex]);
        CrossEar := (BX - AX) * (BY - CY) - (BY - AY) * (BX - CX);
        CrossMid := (BX - AX) * (BY - MidY) - (BY - AY) * (BX - MidX);
        if (CrossEar * CrossMid >= 0) and not PointInsideTriangle(MidX, MidY, AX, AY, BX, BY, CX, CY) then begin
          WorkX.Delete(MiddleIndex);
          WorkY.Delete(MiddleIndex);
          Flag := 1;
          Break;
        end;
      end;
      if Flag <> 0 then Break;
    end;
    while WorkX.Count > 2 do
      for EarIndex := 0 to WorkX.Count - 1 do begin
        LastIndex := EarIndex + 2;
        MiddleIndex := EarIndex + 1;
        if LastIndex >= WorkX.Count then Dec(LastIndex, WorkX.Count);
        if MiddleIndex >= WorkX.Count then Dec(MiddleIndex, WorkX.Count);
        AX := Single(WorkX[EarIndex]);
        BX := Single(WorkX[LastIndex]);
        CX := Single(WorkX[MiddleIndex]);
        AY := Single(WorkY[EarIndex]);
        BY := Single(WorkY[LastIndex]);
        CY := Single(WorkY[MiddleIndex]);
        Flag := 0;
        for J := 0 to WorkX.Count - 1 do
          if (J <> EarIndex) and (J <> LastIndex) and (J <> MiddleIndex) then begin
            if PointInsideTriangle(Single(WorkX[J]), Single(WorkY[J]), AX, AY, BX, BY, CX, CY) then Flag := 1;
            if Flag = 1 then Break;
          end;
        if Flag = 1 then Continue;
        CrossEar := (BX - AX) * (BY - CY) - (BY - AY) * (BX - CX);
        CrossMid := (BX - AX) * (BY - MidY) - (BY - AY) * (BX - MidX);
        if (CrossEar * CrossMid <= 0) or (WorkX.Count = 3) then begin
          AreaAfterUnrestrictedTrim := AreaAfterUnrestrictedTrim + Abs(CrossEar * 0.5);
          WorkX.Delete(MiddleIndex);
          WorkY.Delete(MiddleIndex);
          Break;
        end;
      end;
    WorkX.Clear;
    WorkY.Clear;
    for EarIndex := 0 to XList.Count - 1 do begin
      WorkX.Add(XList[EarIndex]);
      WorkY.Add(YList[EarIndex]);
    end;
    AreaAfterStarSafeTrim := 0;
    while WorkX.Count > 2 do begin
      Flag := 0;
      for EarIndex := 0 to WorkX.Count - 1 do begin
        LastIndex := EarIndex + 2;
        MiddleIndex := EarIndex + 1;
        if LastIndex >= WorkX.Count then Dec(LastIndex, WorkX.Count);
        if MiddleIndex >= WorkX.Count then Dec(MiddleIndex, WorkX.Count);
        AX := Single(WorkX[EarIndex]);
        BX := Single(WorkX[LastIndex]);
        CX := Single(WorkX[MiddleIndex]);
        AY := Single(WorkY[EarIndex]);
        BY := Single(WorkY[LastIndex]);
        CY := Single(WorkY[MiddleIndex]);
        CrossEar := (BX - AX) * (BY - CY) - (BY - AY) * (BX - CX);
        CrossMid := (BX - AX) * (BY - MidY) - (BY - AY) * (BX - MidX);
        if (CrossEar * CrossMid >= 0) and not PointInsideTriangle(MidX, MidY, AX, AY, BX, BY, CX, CY) then begin
          ContainsStar := False;
          for J := 0 to Stars.Count - 1 do begin
            Star := TStar(Stars[J]);
            ContainsStar := PointInsideTriangle(Star.Position.X, Star.Position.Y, AX, AY, BX, BY, CX, CY);
            if ContainsStar then Break;
          end;
          if ContainsStar then Continue;
          WorkX.Delete(MiddleIndex);
          WorkY.Delete(MiddleIndex);
          Flag := 1;
          Break;
        end;
      end;
      if Flag <> 0 then Break;
    end;
    while WorkX.Count > 2 do
      for EarIndex := 0 to WorkX.Count - 1 do begin
        LastIndex := EarIndex + 2;
        MiddleIndex := EarIndex + 1;
        if LastIndex >= WorkX.Count then Dec(LastIndex, WorkX.Count);
        if MiddleIndex >= WorkX.Count then Dec(MiddleIndex, WorkX.Count);
        AX := Single(WorkX[EarIndex]);
        BX := Single(WorkX[LastIndex]);
        CX := Single(WorkX[MiddleIndex]);
        AY := Single(WorkY[EarIndex]);
        BY := Single(WorkY[LastIndex]);
        CY := Single(WorkY[MiddleIndex]);
        Flag := 0;
        for J := 0 to WorkX.Count - 1 do
          if (J <> EarIndex) and (J <> LastIndex) and (J <> MiddleIndex) then begin
            if PointInsideTriangle(Single(WorkX[J]), Single(WorkY[J]), AX, AY, BX, BY, CX, CY) then Flag := 1;
            if Flag = 1 then Break;
          end;
        if Flag = 1 then Continue;
        CrossEar := (BX - AX) * (BY - CY) - (BY - AY) * (BX - CX);
        CrossMid := (BX - AX) * (BY - MidY) - (BY - AY) * (BX - MidX);
        if (CrossEar * CrossMid <= 0) or (WorkX.Count = 3) then begin
          AreaAfterStarSafeTrim := AreaAfterStarSafeTrim + Abs(CrossEar * 0.5);
          WorkX.Delete(MiddleIndex);
          WorkY.Delete(MiddleIndex);
          Break;
        end;
      end;
    WorkX.Clear;
    WorkY.Clear;
    WorkX.Free;
    WorkY.Free;
    Score := ((AreaAfterUnrestrictedTrim - AreaAfterStarSafeTrim) * 0.5 + (AreaAfterStarSafeTrim - FullArea)) / FullArea;
    if (Score < BestScore) or (BestScore < 0) then begin
      BestScore := Score;
      Candidate := Current;
      if BestX <> nil then BestX.Free;
      if BestY <> nil then BestY.Free;
      BestX := XList;
      BestY := YList;
      XList := TList.Create;
      YList := TList.Create;
    end;
  end;
  Current := Candidate;
  for EarIndex := 0 to BestX.Count - 1 do begin
    LastIndex := EarIndex + 2;
    MiddleIndex := EarIndex + 1;
    if LastIndex >= BestX.Count then Dec(LastIndex, BestX.Count);
    if MiddleIndex >= BestX.Count then Dec(MiddleIndex, BestX.Count);
    AX := Single(BestX[EarIndex]);
    BX := Single(BestX[LastIndex]);
    CX := Single(BestX[MiddleIndex]);
    AY := Single(BestY[EarIndex]);
    BY := Single(BestY[LastIndex]);
    CY := Single(BestY[MiddleIndex]);
    CrossEar := (BX - AX) * (BY - CY) - (BY - AY) * (BX - CX);
    if CrossEar <> 0 then
      for I := 0 to Constellations.Count - 1 do begin
        ContainsStar := False;
        Candidate := TConstellation(Constellations[I]);
        if (Candidate <> Current) and (Candidate <> Hidden) and
          Candidate.HasOutlineVertex(MakePointF(AX, AY)) and
          Candidate.HasOutlineVertex(MakePointF(BX, BY)) and
          Candidate.HasOutlineVertex(MakePointF(CX, CY)) then begin
          for J := 0 to Stars.Count - 1 do begin
            Star := TStar(Stars[J]);
            if (((BX - AX) * (BY - CY) - (BY - AY) * (BX - CX)) *
              ((BX - AX) * (BY - Star.Position.Y) - (BY - AY) * (BX - Star.Position.X)) >= 0) and
              (((CX - BX) * (CY - AY) - (CY - BY) * (CX - AX)) *
              ((CX - BX) * (CY - Star.Position.Y) - (CY - BY) * (CX - Star.Position.X)) >= 0) and
              (((AX - CX) * (AY - BY) - (AY - CY) * (AX - BX)) *
              ((AX - CX) * (AY - Star.Position.Y) - (AY - CY) * (AX - Star.Position.X)) >= 0) then ContainsStar := True;
          end;
          if ContainsStar then Continue;
          NewX := AX - (BY - CY);
          NewY := AY + (BX - CX);
          for J := 0 to Hidden.OutlineSegments.Count - 1 do begin
            if (PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.X = AX) and
              (PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.Y = AY) then Continue;
            if (PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.X = BX) and
              (PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.Y = BY) then Continue;
            if (PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.X = AX) and
              (PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.Y = AY) then Continue;
            if (PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.X = BX) and
              (PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.Y = BY) then Continue;
            if (PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.X = CX) and
              (PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.Y = CY) then begin
              NewX := PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.X;
              NewY := PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.Y;
              Break;
            end;
            if (PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.X = CX) and
              (PMapLineSegment(Hidden.OutlineSegments[J]).EndPoint.Y = CY) then begin
              NewX := PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.X;
              NewY := PMapLineSegment(Hidden.OutlineSegments[J]).StartPoint.Y;
              Break;
            end;
          end;
          Determinant := (BY - AY) * (CX - NewX) - (CY - NewY) * (BX - AX);
          if Determinant * Determinant > 0.01 then begin
            IntersectionX := (-BX * AY * CX + BX * AY * NewX - AX * BY * NewX - AX * CX * NewY +
              AX * NewX * CY + BX * CX * NewY - BX * NewX * CY + AX * BY * CX) / Determinant;
            NewY := (NewY * BX * AY - CY * BX * AY - AY * CX * NewY + AY * NewX * CY +
              CY * AX * BY + BY * CX * NewY - BY * NewX * CY - NewY * AX * BY) / Determinant;
            NewX := IntersectionX;
          end else begin
            NewX := (AX + BX) * 0.5;
            NewY := (AY + BY) * 0.5;
          end;
          repeat
            for J := 0 to Candidate.OutlineSegments.Count - 1 do begin
              if (PMapLineSegment(Candidate.OutlineSegments[J]).StartPoint.X = CX) and
                (PMapLineSegment(Candidate.OutlineSegments[J]).StartPoint.Y = CY) then begin
                PMapLineSegment(Candidate.OutlineSegments[J]).StartPoint.X := NewX;
                PMapLineSegment(Candidate.OutlineSegments[J]).StartPoint.Y := NewY;
              end;
              if (PMapLineSegment(Candidate.OutlineSegments[J]).EndPoint.X = CX) and
                (PMapLineSegment(Candidate.OutlineSegments[J]).EndPoint.Y = CY) then begin
                PMapLineSegment(Candidate.OutlineSegments[J]).EndPoint.X := NewX;
                PMapLineSegment(Candidate.OutlineSegments[J]).EndPoint.Y := NewY;
              end;
            end;
            Polygon := nil;
            for J := 0 to Candidate.OutlinePolygons.CountChain - 1 do begin
              if J = 0 then Polygon := Candidate.OutlinePolygons else Polygon := Polygon.Next;
              for K := 0 to Polygon.Points.Count - 1 do
                if (PPointF(Polygon.Points[K]).X = CX) and (PPointF(Polygon.Points[K]).Y = CY) then begin
                  PPointF(Polygon.Points[K]).X := NewX;
                  PPointF(Polygon.Points[K]).Y := NewY;
                end;
            end;
            if Candidate = Hidden then Candidate := nil
            else if Candidate = Current then Candidate := Hidden
            else Candidate := Current;
          until Candidate = nil;
          CX := NewX;
          CY := NewY;
          BestX[MiddleIndex] := Pointer(CX);
          BestY[MiddleIndex] := Pointer(CY);
        end;
      end;
  end;
  Neighbors.Clear;
  XList.Clear;
  YList.Clear;
  BestX.Clear;
  BestY.Clear;
  for I := Hidden.OutlineSegments.Count - 1 downto 0 do begin
    GetMem(Segment, SizeOf(TMapLineSegment));
    Segment.StartPoint.X := PMapLineSegment(Hidden.OutlineSegments[I]).StartPoint.X;
    Segment.StartPoint.Y := PMapLineSegment(Hidden.OutlineSegments[I]).StartPoint.Y;
    Segment.EndPoint.X := PMapLineSegment(Hidden.OutlineSegments[I]).EndPoint.X;
    Segment.EndPoint.Y := PMapLineSegment(Hidden.OutlineSegments[I]).EndPoint.Y;
    Hidden.HiddenOutlineSegmentsBackup.Add(Segment);
  end;
  for I := Current.OutlineSegments.Count - 1 downto 0 do begin
    GetMem(Segment, SizeOf(TMapLineSegment));
    Segment.StartPoint.X := PMapLineSegment(Current.OutlineSegments[I]).StartPoint.X;
    Segment.StartPoint.Y := PMapLineSegment(Current.OutlineSegments[I]).StartPoint.Y;
    Segment.EndPoint.X := PMapLineSegment(Current.OutlineSegments[I]).EndPoint.X;
    Segment.EndPoint.Y := PMapLineSegment(Current.OutlineSegments[I]).EndPoint.Y;
    Current.HiddenOutlineSegmentsBackup.Add(Segment);
  end;
  for I := Hidden.OutlineSegments.Count - 1 downto 0 do
    if Current.HasOutlineSegment(PMapLineSegment(Hidden.OutlineSegments[I]).StartPoint,
      PMapLineSegment(Hidden.OutlineSegments[I]).EndPoint) then begin
      EarIndex := I;
      Dispose(PMapLineSegment(Hidden.OutlineSegments[EarIndex]));
      Hidden.OutlineSegments.Delete(EarIndex);
    end;
  SwapList := Hidden.HiddenOutlineSegmentsBackup;
  Hidden.HiddenOutlineSegmentsBackup := Hidden.OutlineSegments;
  Hidden.OutlineSegments := SwapList;
  for I := Current.OutlineSegments.Count - 1 downto 0 do
    if Hidden.HasOutlineSegment(PMapLineSegment(Current.OutlineSegments[I]).StartPoint,
      PMapLineSegment(Current.OutlineSegments[I]).EndPoint) then begin
      LastIndex := I;
      Dispose(PMapLineSegment(Current.OutlineSegments[LastIndex]));
      Current.OutlineSegments.Delete(LastIndex);
    end;
  SwapList := Hidden.HiddenOutlineSegmentsBackup;
  Hidden.HiddenOutlineSegmentsBackup := Hidden.OutlineSegments;
  Hidden.OutlineSegments := SwapList;
  SwapList := nil;
  while Current.OutlineSegments.Count > 0 do begin
    XList.Add(Current.OutlineSegments[0]);
    Current.OutlineSegments.Delete(0);
  end;
  while Hidden.OutlineSegments.Count > 0 do begin
    XList.Add(Hidden.OutlineSegments[0]);
    Hidden.OutlineSegments.Delete(0);
  end;
  Current.OutlineSegments.Add(XList[0]);
  XList.Delete(0);
  MiddleIndex := 0;
  for SegmentIndex := XList.Count - 1 downto 0 do
    if (PMapLineSegment(XList[SegmentIndex]).StartPoint.X = PMapLineSegment(XList[SegmentIndex]).EndPoint.X) and
      (PMapLineSegment(XList[SegmentIndex]).StartPoint.Y = PMapLineSegment(XList[SegmentIndex]).EndPoint.Y) then begin
      Dispose(PMapLineSegment(XList[SegmentIndex]));
      XList.Delete(SegmentIndex);
    end;
  while XList.Count > 0 do
    for SegmentIndex := XList.Count - 1 downto 0 do begin
      if ((PMapLineSegment(XList[SegmentIndex]).StartPoint.X = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).StartPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).StartPoint.Y = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).StartPoint.Y)) or
        ((PMapLineSegment(XList[SegmentIndex]).StartPoint.X = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).EndPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).StartPoint.Y = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).EndPoint.Y)) or
        ((PMapLineSegment(XList[SegmentIndex]).EndPoint.X = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).StartPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).EndPoint.Y = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).StartPoint.Y)) or
        ((PMapLineSegment(XList[SegmentIndex]).EndPoint.X = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).EndPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).EndPoint.Y = PMapLineSegment(Current.OutlineSegments[MiddleIndex]).EndPoint.Y)) then begin
        Current.OutlineSegments.Add(XList[SegmentIndex]);
        XList.Delete(SegmentIndex);
        Inc(MiddleIndex);
      end else if ((PMapLineSegment(XList[SegmentIndex]).StartPoint.X = PMapLineSegment(Current.OutlineSegments[0]).StartPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).StartPoint.Y = PMapLineSegment(Current.OutlineSegments[0]).StartPoint.Y)) or
        ((PMapLineSegment(XList[SegmentIndex]).StartPoint.X = PMapLineSegment(Current.OutlineSegments[0]).EndPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).StartPoint.Y = PMapLineSegment(Current.OutlineSegments[0]).EndPoint.Y)) or
        ((PMapLineSegment(XList[SegmentIndex]).EndPoint.X = PMapLineSegment(Current.OutlineSegments[0]).StartPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).EndPoint.Y = PMapLineSegment(Current.OutlineSegments[0]).StartPoint.Y)) or
        ((PMapLineSegment(XList[SegmentIndex]).EndPoint.X = PMapLineSegment(Current.OutlineSegments[0]).EndPoint.X) and
          (PMapLineSegment(XList[SegmentIndex]).EndPoint.Y = PMapLineSegment(Current.OutlineSegments[0]).EndPoint.Y)) then begin
        Current.OutlineSegments.Insert(0, XList[SegmentIndex]);
        XList.Delete(SegmentIndex);
        Inc(MiddleIndex);
      end;
    end;
  SourcePolygon := nil;
  for I := 0 to Hidden.OutlinePolygons.CountChain - 1 do begin
    Polygon := TPolygon2D.Create;
    if I = 0 then begin
      Hidden.HiddenOutlinePolygonsBackup := Polygon;
      SourcePolygon := Hidden.OutlinePolygons;
    end else begin
      Hidden.HiddenOutlinePolygonsBackup.Append(Polygon);
      SourcePolygon := SourcePolygon.Next;
    end;
    for J := 0 to SourcePolygon.Points.Count - 1 do begin
      GetMem(Point, SizeOf(TPointF));
      Point.X := PPointF(SourcePolygon.Points[J]).X;
      Point.Y := PPointF(SourcePolygon.Points[J]).Y;
      Polygon.Points.Add(Point);
    end;
    Polygon.Extent.X := SourcePolygon.Extent.X;
    Polygon.Extent.Y := SourcePolygon.Extent.Y;
    Polygon.Bounds.Left := SourcePolygon.Bounds.Left;
    Polygon.Bounds.Top := SourcePolygon.Bounds.Top;
    Polygon.Bounds.Right := SourcePolygon.Bounds.Right;
    Polygon.Bounds.Bottom := SourcePolygon.Bounds.Bottom;
  end;
  for I := 0 to Current.OutlinePolygons.CountChain - 1 do begin
    Polygon := TPolygon2D.Create;
    if I = 0 then begin
      Current.HiddenOutlinePolygonsBackup := Polygon;
      SourcePolygon := Current.OutlinePolygons;
    end else begin
      Current.HiddenOutlinePolygonsBackup.Append(Polygon);
      SourcePolygon := SourcePolygon.Next;
    end;
    for J := 0 to SourcePolygon.Points.Count - 1 do begin
      GetMem(Point, SizeOf(TPointF));
      Point.X := PPointF(SourcePolygon.Points[J]).X;
      Point.Y := PPointF(SourcePolygon.Points[J]).Y;
      Polygon.Points.Add(Point);
    end;
    Polygon.Extent.X := SourcePolygon.Extent.X;
    Polygon.Extent.Y := SourcePolygon.Extent.Y;
    Polygon.Bounds.Left := SourcePolygon.Bounds.Left;
    Polygon.Bounds.Top := SourcePolygon.Bounds.Top;
    Polygon.Bounds.Right := SourcePolygon.Bounds.Right;
    Polygon.Bounds.Bottom := SourcePolygon.Bounds.Bottom;
  end;
  Current.OutlinePolygons.Append(Hidden.OutlinePolygons);
  Hidden.OutlinePolygons := nil;
  Neighbors.Free;
  XList.Free;
  YList.Free;
  BestX.Free;
  BestY.Free;
end;
{ @end $7B4E44 }

{ @routine $7B8188 TConstellation_RestoreHiddenForm }
procedure TConstellation.RestoreHiddenForm;
begin
  if HiddenOutlinePolygonsBackup <> nil then begin
    OutlinePolygons.Free;
    OutlinePolygons := HiddenOutlinePolygonsBackup;
    HiddenOutlinePolygonsBackup := nil;
  end;
  if HiddenOutlineSegmentsBackup.Count <> 0 then begin
    OutlineSegments.Free;
    OutlineSegments := HiddenOutlineSegmentsBackup;
    HiddenOutlineSegmentsBackup := TList.Create;
  end;
end;
{ @end $7B8188 }

{ @routine $7B8200 TGalaxy_CountVisibleConstellationsWithBoundaryPoints }
function TGalaxy.CountVisibleConstellationsWithBoundaryPoints(FirstPoint, SecondPoint: TPointF): Integer;
var
  I, Count: Integer;
  Constellation: TConstellation;
begin
  Result := 0;
  Count := Constellations.Count;
  for I := 0 to Count - 1 do
  begin
    Constellation := TConstellation(Constellations[I]);
    if Constellation.Visible and Constellation.AreBothPointsOnOutline(FirstPoint, SecondPoint) then Inc(Result);
  end;
end;
{ @end $7B8200 }

{ @routine $7B8284 TConstellation_Create }
constructor TConstellation.Create;
begin
  inherited Create;
  if Galaxy <> nil then begin
    Id := Galaxy.NextConstellationId;
    Inc(Galaxy.NextConstellationId);
  end;
  MapCenter := MakePointF(0, 0);
  Stars := TList.Create;
  AdjacentConstellations := TList.Create;
  OutlineBounds := Classes.Rect(0, 0, 0, 0);
  OutlineBoundsSize := Classes.Point(0, 0);
  StarLinks := TList.Create;
  OutlinePolygons := TPolygon2D.Create;
  BoundaryRaySamples := TList.Create;
  OutlineSegments := TList.Create;
  HiddenOutlineSegmentsBackup := TList.Create;
end;
{ @end $7B8284 }

{ @routine $7B83C0 TConstellation_Destroy }
destructor TConstellation.Destroy;
var I: Integer;
begin
  ClearStarLinks;
  ClearOutlineSegmentsAndBounds;
  ClearBoundaryRaySamples;
  StarLinks.Free;
  OutlineSegments.Free;
  for I := 0 to HiddenOutlineSegmentsBackup.Count - 1 do Dispose(PMapLineSegment(HiddenOutlineSegmentsBackup[I]));
  HiddenOutlineSegmentsBackup.Clear;
  HiddenOutlineSegmentsBackup.Free;
  AdjacentConstellations.Free;
  Stars.Free;
  OutlinePolygons.Free;
  HiddenOutlinePolygonsBackup.Free;
  BoundaryRaySamples.Free;
  inherited Destroy;
end;
{ @end $7B83C0 }

{ @routine $7B84AC TConstellation_SaveToBuffer }
procedure TConstellation.SaveToBuffer(Buffer: TBufEC);
var
  i, j: Integer;
  Star: TStar;
  Constellation: TConstellation;
  Segment: PMapLineSegment;
  Polygon: TPolygon2D;
  Point: PPointF;
begin
  Buffer.AddDWord(Self.Id);
  Buffer.AddBoolean(Self.Visible);
  Buffer.AddWideChar(WideChar(Self.SerializedValue88));
  Buffer.AddSingle(Self.MapCenter.X);
  Buffer.AddSingle(Self.MapCenter.Y);
  Buffer.AddWideChar(WideChar(Self.Stars.Count));
  for i := 0 to Self.Stars.Count - 1 do
  begin
    Star := TStar(Self.Stars[i]);
    Buffer.AddDWord(Star.Id);
  end;
  Buffer.AddWideChar(WideChar(Self.AdjacentConstellations.Count));
  for i := 0 to Self.AdjacentConstellations.Count - 1 do
  begin
    Constellation := TConstellation(Self.AdjacentConstellations[i]);
    Buffer.AddDWord(Constellation.Id);
  end;
  Buffer.AddWideChar(WideChar(Self.OutlineSegments.Count));
  for i := 0 to Self.OutlineSegments.Count - 1 do
  begin
    Segment := PMapLineSegment(Self.OutlineSegments[i]);
    Buffer.AddSingle(Segment^.StartPoint.X);
    Buffer.AddSingle(Segment^.StartPoint.Y);
    Buffer.AddSingle(Segment^.EndPoint.X);
    Buffer.AddSingle(Segment^.EndPoint.Y);
  end;
  Buffer.AddWideChar(WideChar(Self.HiddenOutlineSegmentsBackup.Count));
  for i := 0 to Self.HiddenOutlineSegmentsBackup.Count - 1 do
  begin
    Segment := PMapLineSegment(Self.HiddenOutlineSegmentsBackup[i]);
    Buffer.AddSingle(Segment^.StartPoint.X);
    Buffer.AddSingle(Segment^.StartPoint.Y);
    Buffer.AddSingle(Segment^.EndPoint.X);
    Buffer.AddSingle(Segment^.EndPoint.Y);
  end;
  Buffer.AddIntegerValue(Self.OutlineBounds.Left);
  Buffer.AddIntegerValue(Self.OutlineBounds.Top);
  Buffer.AddIntegerValue(Self.OutlineBounds.Right);
  Buffer.AddIntegerValue(Self.OutlineBounds.Bottom);
  Buffer.AddIntegerValue(Self.OutlineBoundsSize.X);
  Buffer.AddIntegerValue(Self.OutlineBoundsSize.Y);
  Buffer.AddWideChar(WideChar(Self.StarLinks.Count));
  for i := 0 to Self.StarLinks.Count - 1 do
  begin
    Segment := PMapLineSegment(Self.StarLinks[i]);
    Buffer.AddSingle(Segment^.StartPoint.X);
    Buffer.AddSingle(Segment^.StartPoint.Y);
    Buffer.AddSingle(Segment^.EndPoint.X);
    Buffer.AddSingle(Segment^.EndPoint.Y);
  end;
  Buffer.AddWideChar(WideChar(TPolygon2D(Self.OutlinePolygons).CountChain));
  Polygon := Self.OutlinePolygons;
  while Polygon <> nil do
  begin
    Buffer.AddWideChar(WideChar(Polygon.Points.Count));
    for j := 0 to Polygon.Points.Count - 1 do
    begin
      Point := PPointF(Polygon.Points[j]);
      Buffer.AddSingle(Point^.X);
      Buffer.AddSingle(Point^.Y);
    end;
    Buffer.AddSingle(Polygon.Extent.X);
    Buffer.AddSingle(Polygon.Extent.Y);
    Buffer.AddSingle(Polygon.Bounds.Left);
    Buffer.AddSingle(Polygon.Bounds.Top);
    Buffer.AddSingle(Polygon.Bounds.Right);
    Buffer.AddSingle(Polygon.Bounds.Bottom);
    Polygon := Polygon.Next;
  end;
  Buffer.AddWideChar(WideChar(TPolygon2D(Self.HiddenOutlinePolygonsBackup).CountChain));
  Polygon := Self.HiddenOutlinePolygonsBackup;
  while Polygon <> nil do
  begin
    Buffer.AddWideChar(WideChar(Polygon.Points.Count));
    for j := 0 to Polygon.Points.Count - 1 do
    begin
      Point := PPointF(Polygon.Points[j]);
      Buffer.AddSingle(Point^.X);
      Buffer.AddSingle(Point^.Y);
    end;
    Buffer.AddSingle(Polygon.Extent.X);
    Buffer.AddSingle(Polygon.Extent.Y);
    Buffer.AddSingle(Polygon.Bounds.Left);
    Buffer.AddSingle(Polygon.Bounds.Top);
    Buffer.AddSingle(Polygon.Bounds.Right);
    Buffer.AddSingle(Polygon.Bounds.Bottom);
    Polygon := Polygon.Next;
  end;
end;
{ @end $7B84AC }

{ @routine $7B8958 TConstellation_LoadFromBuffer }
procedure TConstellation.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  i, j, Count, PointCount: Integer;
  Segment: PMapLineSegment;
  Polygon: TPolygon2D;
  Point: PPointF;
begin
  Self.Id := Buffer.GetUInt32;
  if Galaxy.NextConstellationId <= Self.Id then
    Galaxy.NextConstellationId := Self.Id + 1;
  Self.Visible := Buffer.GetBoolean;
  Self.SerializedValue88 := Buffer.GetWord;
  Self.MapCenter.X := Buffer.GetSingle;
  Self.MapCenter.Y := Buffer.GetSingle;
  Count := Buffer.GetWord;
  for i := 0 to Count - 1 do
    Self.Stars.Add(Pointer(Buffer.GetUInt32));
  Count := Buffer.GetWord;
  for i := 0 to Count - 1 do
    Self.AdjacentConstellations.Add(Pointer(Buffer.GetUInt32));
  Count := Buffer.GetWord;
  for i := 0 to Count - 1 do
  begin
    System.GetMem(Segment, SizeOf(TMapLineSegment));
    Segment^.StartPoint.X := Buffer.GetSingle;
    Segment^.StartPoint.Y := Buffer.GetSingle;
    Segment^.EndPoint.X := Buffer.GetSingle;
    Segment^.EndPoint.Y := Buffer.GetSingle;
    Self.OutlineSegments.Add(Segment);
  end;
  if GlobalsV.LoadedSaveVersion >= 45 then
  begin
    Count := Buffer.GetWord;
    for i := 0 to Count - 1 do
    begin
      System.GetMem(Segment, SizeOf(TMapLineSegment));
      Segment^.StartPoint.X := Buffer.GetSingle;
      Segment^.StartPoint.Y := Buffer.GetSingle;
      Segment^.EndPoint.X := Buffer.GetSingle;
      Segment^.EndPoint.Y := Buffer.GetSingle;
      Self.HiddenOutlineSegmentsBackup.Add(Segment);
    end;
  end;
  Self.OutlineBounds.Left := Buffer.GetInt32;
  Self.OutlineBounds.Top := Buffer.GetInt32;
  Self.OutlineBounds.Right := Buffer.GetInt32;
  Self.OutlineBounds.Bottom := Buffer.GetInt32;
  Self.OutlineBoundsSize.X := Buffer.GetInt32;
  Self.OutlineBoundsSize.Y := Buffer.GetInt32;
  Count := Buffer.GetWord;
  for i := 0 to Count - 1 do
  begin
    System.GetMem(Segment, SizeOf(TMapLineSegment));
    Segment^.StartPoint.X := Buffer.GetSingle;
    Segment^.StartPoint.Y := Buffer.GetSingle;
    Segment^.EndPoint.X := Buffer.GetSingle;
    Segment^.EndPoint.Y := Buffer.GetSingle;
    Self.StarLinks.Add(Segment);
  end;
  Count := Buffer.GetWord;
  for i := 0 to Count - 1 do
  begin
    Polygon := TPolygon2D.Create;
    if i = 0 then
      Self.OutlinePolygons := Polygon
    else
      TPolygon2D(Self.OutlinePolygons).Append(Polygon);
    PointCount := Buffer.GetWord;
    for j := 0 to PointCount - 1 do
    begin
      System.GetMem(Point, SizeOf(TPointF));
      Point^.X := Buffer.GetSingle;
      Point^.Y := Buffer.GetSingle;
      Polygon.Points.Add(Point);
    end;
    Polygon.Extent.X := Buffer.GetSingle;
    Polygon.Extent.Y := Buffer.GetSingle;
    Polygon.Bounds.Left := Buffer.GetSingle;
    Polygon.Bounds.Top := Buffer.GetSingle;
    Polygon.Bounds.Right := Buffer.GetSingle;
    Polygon.Bounds.Bottom := Buffer.GetSingle;
  end;
  if GlobalsV.LoadedSaveVersion >= 45 then
  begin
    Count := Buffer.GetWord;
    for i := 0 to Count - 1 do
    begin
      Polygon := TPolygon2D.Create;
      if i = 0 then
        Self.HiddenOutlinePolygonsBackup := Polygon
      else
        TPolygon2D(Self.HiddenOutlinePolygonsBackup).Append(Polygon);
      PointCount := Buffer.GetWord;
      for j := 0 to PointCount - 1 do
      begin
        System.GetMem(Point, SizeOf(TPointF));
        Point^.X := Buffer.GetSingle;
        Point^.Y := Buffer.GetSingle;
        Polygon.Points.Add(Point);
      end;
      Polygon.Extent.X := Buffer.GetSingle;
      Polygon.Extent.Y := Buffer.GetSingle;
      Polygon.Bounds.Left := Buffer.GetSingle;
      Polygon.Bounds.Top := Buffer.GetSingle;
      Polygon.Bounds.Right := Buffer.GetSingle;
      Polygon.Bounds.Bottom := Buffer.GetSingle;
    end;
  end;
end;
{ @end $7B8958 }

{ @routine $7B8E78 TConstellation_ResolveLoadedReferences }
procedure TConstellation.ResolveLoadedReferences(Galaxy: TGalaxy);
var I: Integer;
begin
  for I := 0 to Stars.Count - 1 do Stars[I] := Galaxy.IdToStar(Cardinal(Stars[I]));
  for I := 0 to AdjacentConstellations.Count - 1 do
    AdjacentConstellations[I] := Galaxy.IdToConstellation(Cardinal(AdjacentConstellations[I]));
end;
{ @end $7B8E78 }

{ @routine $7B8F1C TConstellation_ClearStarLinks }
procedure TConstellation.ClearStarLinks;
var I: Integer;
begin
  for I := 0 to StarLinks.Count - 1 do Dispose(PConstellationStarLink(StarLinks[I]));
  StarLinks.Clear;
end;
{ @end $7B8F1C }

{ @routine $7B8F70 TConstellation_ClearBoundaryRaySamples }
procedure TConstellation.ClearBoundaryRaySamples;
var I: Integer;
begin
  for I := 0 to BoundaryRaySamples.Count - 1 do Dispose(PConstellationBoundaryRaySample(BoundaryRaySamples[I]));
  BoundaryRaySamples.Clear;
end;
{ @end $7B8F70 }

{ @routine $7B8FC4 TConstellation_GenerateBoundaryRaySamples }
procedure TConstellation.GenerateBoundaryRaySamples(Count: Integer);
var Angle, Step: Single; I: Integer; Sample: PConstellationBoundaryRaySample;
begin
  ClearBoundaryRaySamples;
  Step := 2 * Pi / Count;
  Angle := 0;
  for I := 0 to Count - 1 do begin
    GetMem(Sample, SizeOf(TConstellationBoundaryRaySample));
    Sample.Position := MakePointF(Cos(Angle) + MapCenter.X, Sin(Angle) + MapCenter.Y);
    Sample.Direction := MakePointF(Cos(Angle), Sin(Angle));
    Sample.Angle := Angle;
    Sample.GrowthStopped := False;
    BoundaryRaySamples.Add(Sample);
    Angle := Angle + Step;
  end;
end;
{ @end $7B8FC4 }

{ @routine $7B90E8 TConstellation_SetOutlinePolygon }
procedure TConstellation.SetOutlinePolygon(Polygon: TPolygon2D);
begin
  if OutlinePolygons <> nil then OutlinePolygons.Free;
  OutlinePolygons := Polygon;
  RebuildOutlineSegments;
end;
{ @end $7B90E8 }

{ @routine $7B9128 TConstellation_RebuildOutlineSegments }
procedure TConstellation.RebuildOutlineSegments;
begin
  if OutlineSegments <> nil then OutlineSegments.Free;
  OutlineSegments := OutlinePolygons.ExtractBoundaryEdges;
  RefreshOutlineBounds;
end;
{ @end $7B9128 }

{ @routine $7B9164 TConstellation_ClearOutlineSegmentsAndBounds }
procedure TConstellation.ClearOutlineSegmentsAndBounds;
var I: Integer;
begin
  for I := 0 to OutlineSegments.Count - 1 do Dispose(PMapLineSegment(OutlineSegments[I]));
  OutlineSegments.Clear;
  OutlineBounds := Classes.Rect(0, 0, 0, 0);
  OutlineBoundsSize := Classes.Point(0, 0);
end;
{ @end $7B9164 }

{ @routine $7B91F4 TConstellation_AddStar }
procedure TConstellation.AddStar(Star: TStar);
begin
  Stars.Add(Star);
  Star.Constellation := Self;
end;
{ @end $7B91F4 }

{ @routine $7B9220 TConstellation_AddAdjacentConstellation }
procedure TConstellation.AddAdjacentConstellation(Constellation: TConstellation);
begin
  if not HasAdjacentConstellation(Constellation) then AdjacentConstellations.Add(Constellation);
end;
{ @end $7B9220 }

{ @routine $7B9250 TConstellation_SharesOutlineSegment }
function TConstellation.SharesOutlineSegment(Constellation: TConstellation): Boolean;
var I: Integer; Segment: PMapLineSegment;
begin
  if Self = Constellation then begin Result := True; Exit; end;
  for I := 0 to OutlineSegments.Count - 1 do begin
    Segment := OutlineSegments[I];
    if Constellation.HasOutlineSegment(Segment.StartPoint, Segment.EndPoint) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7B9250 }

{ @routine $7B92C4 TConstellation_ResetGeneratedMapShape }
procedure TConstellation.ResetGeneratedMapShape;
begin
  ClearBoundaryRaySamples;
  ClearStarLinks;
  ClearOutlineSegmentsAndBounds;
  ClearStars;
  ClearAdjacentConstellations;
  OutlinePolygons.Free;
  OutlinePolygons := TPolygon2D.Create;
end;
{ @end $7B92C4 }

{ @routine $7B931C TConstellation_ClearStars }
procedure TConstellation.ClearStars;
begin
  if Stars <> nil then Stars.Clear;
end;
{ @end $7B931C }

{ @routine $7B933C TConstellation_ClearAdjacentConstellations }
procedure TConstellation.ClearAdjacentConstellations;
begin
  if AdjacentConstellations <> nil then AdjacentConstellations.Clear;
end;
{ @end $7B933C }

{ @routine $7B935C TConstellation_GetOutlineArea }
function TConstellation.GetOutlineArea: Single;
begin
  Result := OutlinePolygons.GetChainArea;
end;
{ @end $7B935C }

{ @routine $7B9380 TConstellation_FindNextClosestStarPair }
function TConstellation.FindNextClosestStarPair(var FirstStar, SecondStar: TStar; MinimumDistance: Integer): Integer;
var I, J, Distance, BestDistance: Integer; A, B: TStar; StartI, StartJ: Integer;
begin
  BestDistance := MinimumDistance + 1;
  StartI := 0;
  StartJ := -1;
  if FirstStar <> nil then StartI := FirstStar.ConstellationGraphIndex - 1;
  if SecondStar <> nil then StartJ := SecondStar.ConstellationGraphIndex - 1;
  FirstStar := nil;
  SecondStar := nil;
  for I := StartI to Stars.Count - 1 do
    for J := I + 1 to Stars.Count - 1 do
      if (I <> StartI) or ((I = StartI) and (J > StartJ)) then begin
        A := Stars[I];
        B := Stars[J];
        Distance := Round(PointDistance(A.Position, B.Position));
        if (Distance < BestDistance) and (Distance >= MinimumDistance) then begin
          BestDistance := Distance;
          FirstStar := A;
          SecondStar := B;
        end;
      end;
  if FirstStar = nil then begin
    BestDistance := Round(GalaxySizeY * Sqrt(2));
    for I := 0 to Stars.Count - 1 do
      for J := I + 1 to Stars.Count - 1 do begin
        A := Stars[I];
        B := Stars[J];
        Distance := Round(PointDistance(A.Position, B.Position));
        if (Distance < BestDistance) and (Distance > MinimumDistance) then begin
          BestDistance := Distance;
          FirstStar := A;
          SecondStar := B;
        end;
      end;
  end;
  if FirstStar = nil then Result := 0 else Result := BestDistance;
end;
{ @end $7B9380 }

{ @routine $7B95A4 TConstellation_HasStarGraphCycle }
function TConstellation.HasStarGraphCycle: Boolean;
var I: Integer; Link: PConstellationStarLink; Changed: Boolean; Parents: array[1..100] of Integer;
begin
  Result := False;
  if Stars.Count > 100 then Exit;
  for I := 0 to StarLinks.Count - 1 do begin Link := StarLinks[I]; Link.TraversalMark := False; end;
  while True do begin
    for I := 1 to Stars.Count do Parents[I] := -1;
    I := 0;
    Link := nil;
    while I < StarLinks.Count do begin
      Link := StarLinks[I];
      if not Link.TraversalMark then Break;
      Inc(I);
    end;
    if I = StarLinks.Count then Break;
    Parents[Link.StartStarIndex] := Link.EndStarIndex;
    Changed := True;
    while Changed do begin
      Changed := False;
      for I := 0 to StarLinks.Count - 1 do begin
        Link := StarLinks[I];
        if Parents[Link.StartStarIndex] <> -1 then begin
          Link.TraversalMark := True;
          if Parents[Link.EndStarIndex] = -1 then begin
            Changed := True;
            Parents[Link.EndStarIndex] := Link.StartStarIndex;
          end else if (Parents[Link.EndStarIndex] <> Link.StartStarIndex) and
            (Parents[Link.StartStarIndex] <> Link.EndStarIndex) then begin Result := True; Exit; end;
        end else if Parents[Link.EndStarIndex] <> -1 then begin
          Link.TraversalMark := True;
          if Parents[Link.StartStarIndex] = -1 then begin
            Changed := True;
            Parents[Link.StartStarIndex] := Link.EndStarIndex;
          end else if (Parents[Link.StartStarIndex] <> Link.EndStarIndex) and
            (Parents[Link.EndStarIndex] <> Link.StartStarIndex) then begin Result := True; Exit; end;
        end;
      end;
    end;
  end;
end;
{ @end $7B95A4 }

{ @routine $7B97D0 TConstellation_IsStarGraphConnected }
function TConstellation.IsStarGraphConnected: Boolean;
var I, J: Integer; Link: PConstellationStarLink; Stable: Boolean; Parents: array[1..100] of Integer;
begin
  Result := False;
  if Stars.Count > 100 then Exit;
  for I := 0 to StarLinks.Count - 1 do begin Link := StarLinks[I]; Link.TraversalMark := False; end;
  for I := 1 to Stars.Count do Parents[I] := -1;
  Parents[1] := 0;
  for I := 0 to StarLinks.Count - 1 do begin
    Stable := True;
    for J := 0 to StarLinks.Count - 1 do begin
      Link := StarLinks[J];
      if (Parents[Link.StartStarIndex] <> -1) and (Parents[Link.EndStarIndex] = -1) then begin
        Parents[Link.EndStarIndex] := 0;
        Stable := False;
      end else if (Parents[Link.EndStarIndex] <> -1) and (Parents[Link.StartStarIndex] = -1) then begin
        Parents[Link.StartStarIndex] := 0;
        Stable := False;
      end;
    end;
    if Stable then Break;
  end;
  Result := True;
  for I := 1 to Stars.Count do if Parents[I] = -1 then Result := False;
end;
{ @end $7B97D0 }

{ @routine $7B9970 TConstellation_BuildStarGraph }
function TConstellation.BuildStarGraph: Boolean;
var I: Integer; Star, FirstStar, SecondStar: TStar; MinimumDistance: Integer; Link: PConstellationStarLink; Segment: PMapLineSegment; Intersection: TPointF;
begin
  ClearStarLinks;
  for I := 0 to Stars.Count - 1 do begin
    Star := Stars[I];
    Star.ConstellationGraphIndex := I + 1;
  end;
  MinimumDistance := 0;
  FirstStar := nil;
  SecondStar := nil;
  while True do begin
    MinimumDistance := FindNextClosestStarPair(FirstStar, SecondStar, MinimumDistance);
    if MinimumDistance = 0 then Break;
    GetMem(Link, SizeOf(TConstellationStarLink));
    Link.StartPoint := FirstStar.Position;
    Link.EndPoint := SecondStar.Position;
    Link.StartStarIndex := FirstStar.ConstellationGraphIndex;
    Link.EndStarIndex := SecondStar.ConstellationGraphIndex;
    StarLinks.Add(Link);
    if HasStarGraphCycle then begin
      StarLinks.Delete(StarLinks.Count - 1);
      Dispose(Link);
      Continue;
    end;
    for I := 0 to OutlineSegments.Count - 1 do begin
      Segment := OutlineSegments[I];
      if IntersectSegmentsF(Link.StartPoint, Link.EndPoint, Segment.StartPoint, Segment.EndPoint, Intersection) then begin
        StarLinks.Delete(StarLinks.Count - 1);
        Dispose(Link);
        Break;
      end;
    end;
  end;
  Result := IsStarGraphConnected;
end;
{ @end $7B9970 }

{ @routine $7B9B18 TConstellation_ExpandOutlineBounds }
procedure TConstellation.ExpandOutlineBounds(Point: TPointF);
begin
  if OutlineBounds.Left > Point.X then OutlineBounds.Left := Round(Point.X);
  if OutlineBounds.Top > Point.Y then OutlineBounds.Top := Round(Point.Y);
  if OutlineBounds.Right < Point.X then OutlineBounds.Right := Round(Point.X);
  if OutlineBounds.Bottom < Point.Y then OutlineBounds.Bottom := Round(Point.Y);
end;
{ @end $7B9B18 }

{ @routine $7B9BA4 TConstellation_RefreshOutlineBounds }
procedure TConstellation.RefreshOutlineBounds;
var I: Integer; Segment: PMapLineSegment;
begin
  OutlineBounds.TopLeft := Classes.Point(0, 0);
  OutlineBounds.BottomRight := Classes.Point(0, 0);
  if OutlineSegments.Count <> 0 then begin
    Segment := OutlineSegments[0];
    OutlineBounds.Top := Round(Segment.StartPoint.Y);
    OutlineBounds.Left := Round(Segment.StartPoint.X);
    OutlineBounds.Bottom := Round(Segment.StartPoint.Y);
    OutlineBounds.Right := Round(Segment.StartPoint.X);
    for I := 0 to OutlineSegments.Count - 1 do begin
      Segment := OutlineSegments[I];
      ExpandOutlineBounds(Segment.StartPoint);
      ExpandOutlineBounds(Segment.EndPoint);
    end;
    OutlineBoundsSize := Classes.Point(OutlineBounds.Right - OutlineBounds.Left, OutlineBounds.Bottom - OutlineBounds.Top);
  end;
end;
{ @end $7B9BA4 }

{ @routine $7B9CC8 TConstellation_ContainsPoint }
function TConstellation.ContainsPoint(Point: TPointF): Boolean;
begin
  Result := False;
  if OutlinePolygons <> nil then if OutlinePolygons.ChainContainsPoint(Point) then Result := True else Result := False;
end;
{ @end $7B9CC8 }

{ @routine $7B9D14 TConstellation_HasAdjacentConstellation }
function TConstellation.HasAdjacentConstellation(Constellation: TConstellation): Boolean;
var I: Integer;
begin
  Result := True;
  for I := 0 to AdjacentConstellations.Count - 1 do
    if AdjacentConstellations[I] = Constellation then Exit;
  Result := False;
end;
{ @end $7B9D14 }

{ @routine $7B9D64 TConstellation_HasOutlineSegment }
function TConstellation.HasOutlineSegment(FirstPoint, SecondPoint: TPointF): Boolean;
var I: Integer; Segment: PMapLineSegment;
begin
  for I := 0 to OutlineSegments.Count - 1 do begin
    Segment := OutlineSegments[I];
    if SegmentsNearlyEqualF(FirstPoint, SecondPoint, Segment.StartPoint, Segment.EndPoint) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7B9D64 }

{ @routine $7B9DE0 TConstellation_AreBothPointsOnOutline }
function TConstellation.AreBothPointsOnOutline(FirstPoint, SecondPoint: TPointF): Boolean;
var I: Integer; Segment: PMapLineSegment; Classification: Integer; FoundFirst, FoundSecond: Boolean;
begin
  FoundFirst := False;
  FoundSecond := False;
  for I := 0 to OutlineSegments.Count - 1 do begin
    Segment := OutlineSegments[I];
    Classification := ClassifyPointToSegment(Segment.StartPoint, Segment.EndPoint, FirstPoint);
    if Classification >= 5 then FoundFirst := True;
    Classification := ClassifyPointToSegment(Segment.StartPoint, Segment.EndPoint, SecondPoint);
    if Classification >= 5 then FoundSecond := True;
  end;
  Result := FoundFirst and FoundSecond;
end;
{ @end $7B9DE0 }

{ @routine $7B9E84 TConstellation_CalculateLabelPosition }
function TConstellation.CalculateLabelPosition: TPointF;
var
  I: Integer;
  Segment: PMapLineSegment;
  MinPoint, MaxPoint: TPointF;
  X, Y, StepX, StepY, SumX, SumY: Single;
  Count: Integer;
begin
  MinPoint := MakePointF(1.0e20, 1.0e20);
  MaxPoint := MakePointF(-1.0e20, -1.0e20);
  for I := 0 to OutlineSegments.Count - 1 do
  begin
    Segment := OutlineSegments[I];
    MinPoint.X := Min(MinPoint.X, Segment.StartPoint.X);
    MinPoint.Y := Min(MinPoint.Y, Segment.StartPoint.Y);
    MaxPoint.X := Max(MaxPoint.X, Segment.StartPoint.X);
    MaxPoint.Y := Max(MaxPoint.Y, Segment.StartPoint.Y);
  end;
  StepX := (MaxPoint.X - MinPoint.X) / 10;
  StepY := (MaxPoint.Y - MinPoint.Y) / 10;
  SumX := 0;
  SumY := 0;
  Count := 0;
  Y := MinPoint.Y;
  while Y < MaxPoint.Y do
  begin
    X := MinPoint.X;
    while X < MaxPoint.X do
    begin
      if ContainsPoint(MakePointF(X, Y)) then
      begin
        SumX := SumX + X;
        SumY := SumY + Y;
        Inc(Count);
      end;
      X := X + StepX;
    end;
    Y := Y + StepY;
  end;
  Result := MakePointF(SumX / Count, SumY / Count);
end;
{ @end $7B9E84 }

{ @routine $7BA04C TConstellation_HasOutlineVertex }
function TConstellation.HasOutlineVertex(Point: TPointF): Boolean;
var I: Integer; Segment: PMapLineSegment;
begin
  for I := 0 to OutlineSegments.Count - 1 do begin
    Segment := OutlineSegments[I];
    if PointsNearlyEqualF(Segment.StartPoint, Point) or PointsNearlyEqualF(Segment.EndPoint, Point) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7BA04C }

{ @routine $7BA0C4 TConstellation_IsPointNearOutline }
function TConstellation.IsPointNearOutline(Point: TPointF): Boolean;
var I: Integer; Segment: PMapLineSegment; Minimum, Distance: Single;
begin
  Minimum := GalaxySizeX;
  for I := 0 to OutlineSegments.Count - 1 do begin
    Segment := OutlineSegments[I];
    Distance := PointSegmentDistanceF(Segment.StartPoint, Segment.EndPoint, Point);
    if Distance < Minimum then Minimum := Distance;
  end;
  if Minimum <= 2 then Result := True else Result := False;
end;
{ @end $7BA0C4 }

{ @routine $7BA160 TConstellation_NormalizeOutlineSegmentOrder }
procedure TConstellation.NormalizeOutlineSegmentOrder;
var I, J: Integer; First, Next: PMapLineSegment; Temp: Pointer; Point: TPointF;
begin
  for I := 0 to OutlineSegments.Count - 2 do begin
    First := OutlineSegments[I];
    J := I + 1;
    while J < OutlineSegments.Count do begin
      Next := OutlineSegments[J];
      if PointsNearlyEqualF(First.EndPoint, Next.StartPoint) then Break;
      if PointsNearlyEqualF(First.EndPoint, Next.EndPoint) then begin
        Point := Next.StartPoint;
        Next.StartPoint := Next.EndPoint;
        Next.EndPoint := Point;
        Break;
      end;
      Inc(J);
    end;
    if J < OutlineSegments.Count then begin
      Temp := OutlineSegments[I + 1];
      OutlineSegments[I + 1] := OutlineSegments[J];
      OutlineSegments[J] := Temp;
    end;
  end;
end;
{ @end $7BA160 }

{ @routine $7BA27C TConstellation_GetName }
function TConstellation.GetName: WideString;
var Index: Integer;
begin
  Index := Galaxy.Constellations.IndexOf(Self);
  Result := LocalizedText('Constellations.Name.' + IntToStr(Index + 1));
end;
{ @end $7BA27C }

{ @routine $7BA338 TConstellation_HasDominatorPresence }
function TConstellation.HasDominatorPresence: Boolean;
var I: Integer; Star: TStar;
begin
  for I := 0 to Stars.Count - 1 do begin
    Star := Stars[I];
    if Star.ShipTypeCounts[stKling] > 0 then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7BA338 }

{ @routine $7BA390 TConstellation_HasPirateClanPresence }
function TConstellation.HasPirateClanPresence: Boolean;
var I, J: Integer; Star: TStar; Ship: TShip;
begin
  for I := 0 to Stars.Count - 1 do begin
    Star := Stars[I];
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := TShip(Star.Ships[J]);
      if (Ship is TPirate) and (Ship.OwnerId = oiPirate) and (TPirate(Ship).PirateType <> 0) then begin Result := True; Exit; end;
    end;
  end;
  Result := False;
end;
{ @end $7BA390 }

{ @routine $7BA43C TConstellation_HasBertorOfSeries }
function TConstellation.HasBertorOfSeries(Series: TDominatorSeries): Boolean;
var I, J: Integer; Star: TStar; Ship: TShip;
begin
  for I := 0 to Stars.Count - 1 do begin
    Star := Stars[I];
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := TShip(Star.Ships[J]);
      if (Ship is TKling) and ((Ship as TKling).DominatorSeries = Series) and ((Ship as TKling).KlingType = ktBertor) then begin Result := True; Exit; end;
    end;
  end;
  Result := False;
end;
{ @end $7BA43C }

{ @routine $7BA508 TConstellation_CountShipsByTypeMask }
function TConstellation.CountShipsByTypeMask(ShipTypeMask: TShipTypeMask): Integer;
var Count: Integer; I: Byte;
begin
  Count := 0;
  for I := 0 to 13 do
    if I in ShipTypeMask then Inc(Count, ShipTypeCounts[I]);
  Result := Count;
end;
{ @end $7BA508 }

{ @routine $7BA554 TGalaxy_CountEligibleRangers }
function TGalaxy.CountEligibleRangers: Integer;
var Index: Integer; Ranger: TRanger;
begin
  Result := 0;
  for Index := 0 to Rangers.Count - 1 do
  begin
    Ranger := Rangers[Index];
    if not Ranger.ExcludedFromRating then Inc(Result);
  end;
end;
{ @end $7BA554 }

{ @routine $7BA5AC TGalaxy_RefreshRangerWealthStats }
procedure TGalaxy.RefreshRangerWealthStats;
var
  I, J, Count: Integer;
  Total: Int64;
  Ranger: TRanger;
  Ship: TShip;
  Star: TStar;
begin
  if SpecialSimulationMode <> 0 then
  begin
    AverageRangerCapital := 100000000;
    Exit;
  end;
  WealthiestRanger := nil;
  MaxRangerWealth := 0;
  if Rangers.Count = 0 then Exit;
  Total := 0;
  Count := 0;
  for I := 0 to Rangers.Count - 1 do
  begin
    Ranger := TRanger(Rangers[I]);
    if Ranger.ExcludedFromRating then Continue;
    Total := Total + Ranger.CalculateWealth;
    Inc(Count);
    if (MaxRangerWealth < Ranger.Wealth) or (WealthiestRanger = nil) then
    begin
      MaxRangerWealth := Ranger.Wealth;
      WealthiestRanger := Ranger;
    end;
  end;
  if CoalitionDefeatedTurn <> 0 then
    for I := 0 to Stars.Count - 1 do
    begin
      Star := TStar(Stars[I]);
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[J];
        if not ((Ship is TPirate) and ((Ship as TPirate).PirateType = 0) and (Ship.OwnerId = oiPirate)) then Continue;
        Total := Total + Ship.CalculateWealth;
        Inc(Count);
      end;
    end;
  Total := Round(Total / Count); // Native has no guard when all roster entries are excluded.
  if Total > MaxInt then AverageRangerCapital := MaxInt
  else AverageRangerCapital := Total;
end;
{ @end $7BA5AC }

{ @routine $7BA790 TGalaxy_RefreshRangerStrengthStats }
procedure TGalaxy.RefreshRangerStrengthStats;
var I, J, Count: Integer; Ranger: TRanger; Total: Single; Ship: TShip; Star: TStar;
begin
  BestRangerStrength := 0;
  StrongestRanger := nil;
  if Rangers.Count <> 0 then
  begin
    Total := 0;
    Count := 0;
    for I := 0 to Rangers.Count - 1 do
    begin
      Ranger := Rangers[I];
      if not Ranger.ExcludedFromRating then
      begin
        Total := Total + Ranger.Strength;
        if (BestRangerStrength < Ranger.Strength) or (StrongestRanger = nil) then
        begin
          BestRangerStrength := Ranger.Strength;
          StrongestRanger := Ranger;
        end;
        Inc(Count);
      end;
    end;
    if CoalitionDefeatedTurn <> 0 then
      for I := 0 to Stars.Count - 1 do
      begin
        Star := TStar(Stars[I]);
        for J := 0 to Star.Ships.Count - 1 do
        begin
          Ship := TShip(Star.Ships[J]);
          if (Ship is TPirate) and ((Ship as TPirate).PirateType = 0) and (Ship.OwnerId = oiPirate) then
          begin
            Total := Total + Ship.Strength;
            if BestRangerStrength < Ship.Strength then BestRangerStrength := Ship.Strength;
            Inc(Count);
          end;
        end;
      end;
    AverageRangerStrength := Total / Count; // Native has no guard when all roster entries are excluded.
  end;
end;
{ @end $7BA790 }

{ @routine $7BA96C TGalaxy_RefreshRangerRatingPlaces }
procedure TGalaxy.RefreshRangerRatingPlaces;
var I, J: Integer; First, Second: TRanger; Sorted: array of Cardinal; SwapFirst, SwapSecond: Cardinal; // Native RTTI: dynamic Cardinal array storing object addresses.
begin
  SetLength(Sorted, Rangers.Count);
  for I := 0 to Rangers.Count - 1 do
  begin
    First := Rangers[I];
    Sorted[I] := Cardinal(First);
  end;
  for I := 0 to Rangers.Count - 1 do
    for J := I to Rangers.Count - 1 do
    begin
      First := TRanger(Sorted[I]);
      Second := TRanger(Sorted[J]);
      if First.TotalExperience < Second.TotalExperience then
      begin
        SwapFirst := Sorted[I];
        SwapSecond := Sorted[J];
        Sorted[J] := SwapFirst;
        Sorted[I] := SwapSecond;
      end;
    end;
  for I := 0 to Rangers.Count - 1 do
  begin
    First := TRanger(Sorted[I]);
    First.PlaceInRating := I + 1;
  end;
  if (GetPlayer <> nil) and (not Destroying) then GetPlayer.AchievementStats.CheckFirstPlaceRatingAchievement;
end;
{ @end $7BA96C }

{ @routine $7BAB14 TGalaxy_FindStrongestRanger }
function TGalaxy.FindStrongestRanger: Pointer;
var I: Integer; Ranger: TRanger; Best: Single;
begin
  Best := 0;
  Result := nil;
  for I := 0 to Rangers.Count - 1 do begin
    Ranger := Rangers[I];
    if not Ranger.ExcludedFromRating and (Ranger.Strength > Best) then begin
      Result := Ranger;
      Best := Ranger.Strength;
    end;
  end;
end;
{ @end $7BAB14 }

{ @routine $7BAB90 TGalaxy_FindWealthiestRanger }
function TGalaxy.FindWealthiestRanger: Pointer;
var I: Integer; Ranger: TRanger; Best: Single;
begin
  Best := 0;
  Result := nil;
  for I := 0 to Rangers.Count - 1 do begin
    Ranger := Rangers[I];
    if not Ranger.ExcludedFromRating and (Ranger.Wealth > Best) then begin
      Result := Ranger;
      Best := Ranger.Wealth;
    end;
  end;
end;
{ @end $7BAB90 }

{ @routine $7BAC10 TGalaxy_CountFactionStars }
function TGalaxy.CountFactionStars(Faction: TStarFaction): Integer;
var Index: Integer; Star: TStar;
begin
  Result := 0;
  for Index := 0 to Stars.Count - 1 do
  begin
    Star := Stars[Index];
    if (Star.Status.CustomFaction = '') and (Star.ControlFaction = Faction) then Inc(Result);
  end;
end;
{ @end $7BAC10 }

{ @routine $7BAC78 TGalaxy_GetFactionControlPercent }
function TGalaxy.GetFactionControlPercent(Faction: TStarFaction): TPercent;
begin
  Result := Round(CountFactionStars(Faction) / Stars.Count * 100);
end;
{ @end $7BAC78 }

{ @routine $7BACBC TGalaxy_GetDominatorSeriesControlShare }
function TGalaxy.GetDominatorSeriesControlShare(Series: TDominatorSeries): Single;
var I, SeriesStars, DominatorStars, Unresolved: Integer; Star: TStar;
begin
  DominatorStars := 0;
  SeriesStars := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if (Star.ControlFaction = sfDominators) and (Star.Status.CustomFaction = '') then begin
      Inc(DominatorStars);
      if Star.DominatorSeries = Series then Inc(SeriesStars);
    end;
  end;
  if DominatorStars = 0 then DominatorStars := 1;
  Unresolved := 0;
  if Galaxy.KellerSeriesResolvedTurn = 0 then Inc(Unresolved);
  if Galaxy.TerronSeriesResolvedTurn = 0 then Inc(Unresolved);
  if Galaxy.BlazerSeriesResolvedTurn = 0 then Inc(Unresolved);
  Result := (Unresolved * SeriesStars) / DominatorStars;
end;
{ @end $7BACBC }

{ @routine $7BAD94 TGalaxy_CountStarsInBattle }
function TGalaxy.CountStarsInBattle: Integer;
var I: Integer; Star: TStar;
begin
  Result := 0;
  for I := 0 to Stars.Count - 1 do begin
    Star := Stars[I];
    if Star.Battle <> 0 then Inc(Result);
  end;
end;
{ @end $7BAD94 }

{ @routine $7BADE8 TGalaxy_AssignTextQuestsToPlanets }
procedure TGalaxy.AssignTextQuestsToPlanets;
var I, J, Index, Count, QuestId: Integer; Planet: TPlanet; Quest: TTextQuest; Control: TCBufControlEC; Buffer: TCBufEC;
begin
  Count := LanguageDataConfig.GetBlockByPath('PlanetQuest.PlanetQuest').GetParamCount;
  for I := 0 to Count - 1 do
    if IsIntegerTextW(LanguageDataConfig.GetBlockByPath('PlanetQuest.PlanetQuest').GetParamName(I)) then begin
      QuestId := StrToInt(AnsiString(LanguageDataConfig.GetBlockByPath('PlanetQuest.PlanetQuest').GetParamName(I)));
      Quest := TTextQuest.Create;
      Control := nil;
      try
        Control := TCBufControlEC.Create;
        GlobalCache.ResetControl(Control);
        Control.SetCacheKey('PlanetQuest.' + IntToStr(QuestId));
        Buffer := AcquireOrCreateBuffer(Control);
        Quest.LoadFromReader(Buffer.Buffer, True);
      finally
        if Control <> nil then begin Control.Release; Control.Free; end;
      end;
      Index := NextRandomIntRange(0, Planets.Count - 1, RandomState);
      for J := 0 to Planets.Count - 1 do begin
        IncrementWrapped(Index, 0, Planets.Count - 1);
        Planet := Planets[Index];
        if (Planet.CurrentStar.Constellation.Id <> 20) and (Planet.TextQuestId <= -1) and Planet.Graphic.QuestEnabled and
          ((Planet.OwnerId <> oiDominator) or (PointDistance(Planet.CurrentStar.Position, GetPlayer.CurrentStar.Position) <= 80)) and
          ((Planet.LandTiles >= Planet.GetTotalSurfaceTileCount * 0.2) or
            ((Planet.LandTiles >= Planet.GetTotalSurfaceTileCount * 0.1) and (J >= Planets.Count * 0.7))) and
          (((Planet.OwnerId = oiUninhabited) and (qrUninhabited in Quest.TargetRaces)) or
           ((qrMaloc in Quest.TargetRaces) and (Planet.RaceId = oiMaloc) and (Planet.OwnerId <> oiUninhabited)) or
           ((qrPeleng in Quest.TargetRaces) and (Planet.RaceId = oiPeleng) and (Planet.OwnerId <> oiUninhabited)) or
           ((qrHuman in Quest.TargetRaces) and (Planet.RaceId = oiHuman) and (Planet.OwnerId <> oiUninhabited)) or
           ((qrFeyan in Quest.TargetRaces) and (Planet.RaceId = oiFeyan) and (Planet.OwnerId <> oiUninhabited)) or
           ((qrGaal in Quest.TargetRaces) and (Planet.RaceId = oiGaal) and (Planet.OwnerId <> oiUninhabited)) or
           ((Quest.TargetRaces = []) and
            (((qrMaloc in Quest.IssuerRaces) and (Planet.RaceId = oiMaloc) and (Planet.OwnerId <> oiUninhabited)) or
             ((qrPeleng in Quest.IssuerRaces) and (Planet.RaceId = oiPeleng) and (Planet.OwnerId <> oiUninhabited)) or
             ((qrHuman in Quest.IssuerRaces) and (Planet.RaceId = oiHuman) and (Planet.OwnerId <> oiUninhabited)) or
             ((qrFeyan in Quest.IssuerRaces) and (Planet.RaceId = oiFeyan) and (Planet.OwnerId <> oiUninhabited)) or
             ((qrGaal in Quest.IssuerRaces) and (Planet.RaceId = oiGaal) and (Planet.OwnerId <> oiUninhabited))))) then begin
          Planet.TextQuestId := QuestId;
          Break;
        end;
      end;
      Quest.Free;
    end;
end;
{ @end $7BADE8 }

{ @routine $7BB2C8 TGalaxy_HasPlayerQuestHistory }
function TGalaxy.HasPlayerQuestHistory(QuestType: TQuestType; QuestNumber: Word): Boolean;
var I: Integer; Quest: PPlayerOldQuest;
begin
  for I := PlayerOldQuests.Count - 1 downto 0 do begin
    Quest := PlayerOldQuests[I];
    if (QuestType = Quest.QuestType) and (QuestNumber = Quest.QuestNumber) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7BB2C8 }

{ @routine $7BB330 TGalaxy_TurnToDateTime }
function TGalaxy.TurnToDateTime(Turn: Integer): Double;
begin
  if Turn = -1 then Turn := CurrentTurn;
  Result := Turn + 511341.5 - GalaxyWarmupTurns;
end;
{ @end $7BB330 }

{ @routine $7BB370 TGalaxy_FormatTurnDate }
function TGalaxy.FormatTurnDate(Turn: Integer): WideString;
var
  MonthNumber, MonthName: WideString;
begin
  MonthNumber := FormatDateTime('mm', TurnToDateTime(Turn));
  MonthName := LocalizedText('Month.' + MonthNumber);
  Result := FormatDateTime('d', TurnToDateTime(Turn)) + ' ' + MonthName + ' ' + FormatDateTime('yyyy', TurnToDateTime(Turn));
end;
{ @end $7BB370 }

{ @routine $7BB524 TGalaxy_AddPlanetNewsWithPlayerBubble }
procedure TGalaxy.AddPlanetNewsWithPlayerBubble(NewsType: Byte; Text: WideString);
begin
  if CurrentTurn > GalaxyWarmupTurns then AddOrUpdatePlayerBubble(pmGalaxyNews, CurrentTurn, Text, '');
  AddPlanetNews(NewsType, Text);
end;
{ @end $7BB524 }

{ @routine $7BB598 TGalaxy_AddPlanetNews }
procedure TGalaxy.AddPlanetNews(NewsType: Byte; Text: WideString);
var Entry: PPlanetNewsEntry; Index: Integer;
begin
  if Text = '' then raise Exception.Create('Error! Получена пустая планетарная новость');
  if PlanetNews <> nil then
    for Index := 0 to PlanetNews.Count - 1 do
    begin
      Entry := PlanetNews[Index];
      if Entry.Text = Text then Exit;
    end;
  Inc(NextPlanetNewsId);
  New(Entry);
  Entry.Id := NextPlanetNewsId;
  Entry.Turn := CurrentTurn;
  Entry.NewsType := NewsType;
  Entry.Text := Text;
  PlanetNews.Add(Entry);
end;
{ @end $7BB598 }

{ @routine $7BB6E8 TGalaxy_CountPlanetNewsByType }
function TGalaxy.CountPlanetNewsByType(NewsType: Byte): Integer;
var Entry: PPlanetNewsEntry; Index: Integer;
begin
  Result := 0;
  for Index := 0 to PlanetNews.Count - 1 do
  begin
    Entry := PlanetNews[Index];
    if Entry.NewsType = NewsType then Inc(Result);
  end;
end;
{ @end $7BB6E8 }

{ @routine $7BB748 TGalaxy_PrunePlanetNews }
procedure TGalaxy.PrunePlanetNews;
var I: Integer; News: PPlanetNewsEntry;
begin
  for I := PlanetNews.Count - 1 downto 0 do begin
    News := PlanetNews[I];
    if News.Turn < CurrentTurn - 30 then begin
      PlanetNews.Delete(I);
      Dispose(News);
    end;
  end;
end;
{ @end $7BB748 }

{ @routine $7BB7BC TGalaxy_CreateDominatorSpawnProxy }
procedure TGalaxy.CreateDominatorSpawnProxy(Star: TStar);
begin
  DominatorSpawnPlanet := TPlanet.Create;
  DominatorSpawnPlanet.InitDominatorSpawnProxy(TObject(Star) as TStar);
end;
{ @end $7BB7BC }

{ @routine $7BB7FC TGalaxy_UpdateConstellationMilitaryStats }
procedure TGalaxy.UpdateConstellationMilitaryStats;
var I, J: Integer; Constellation: TConstellation; Star: TStar; Kind: Byte;
begin
  // The native cache indexes all fourteen ship types at $84..$B8.
  for Kind := 0 to 13 do ShipTypeCounts[Kind] := 0;
  for I := 0 to Constellations.Count - 1 do begin
    Constellation := Constellations[I];
    for Kind := 0 to 13 do Constellation.ShipTypeCounts[Kind] := 0;
    for J := 0 to Constellation.Stars.Count - 1 do begin
      Star := Constellation.Stars[J];
      Star.RefreshShipTypeCounts;
      for Kind := 0 to 13 do begin
        Inc(Constellation.ShipTypeCounts[Kind], Star.ShipTypeCounts[Kind]);
        Inc(ShipTypeCounts[Kind], Star.ShipTypeCounts[Kind]);
      end;
    end;
  end;
end;
{ @end $7BB7FC }

{ @routine $7BB904 TGalaxy_RefreshTechLevel }
function TGalaxy.RefreshTechLevel: Byte;
var I, HighestLevel, HighestCount, PreviousCount: Integer; Planet: TPlanet;
begin
  if SpecialSimulationMode <> 0 then begin Result := 8; Exit; end;
  Result := 0;
  HighestCount := 0;
  PreviousCount := 0;
  HighestLevel := 0;
  for I := 0 to Planets.Count - 1 do begin
    Planet := Planets[I];
    if Planet.IsCoalitionOwned or (Planet.OwnerId = oiPirate) then begin
      if Planet.InventionLevels[7] > HighestLevel then begin
        if Planet.InventionLevels[7] = HighestLevel + 1 then PreviousCount := HighestCount else PreviousCount := 0;
        HighestCount := 1;
        HighestLevel := Planet.InventionLevels[7];
      end else if Planet.InventionLevels[7] = HighestLevel then Inc(HighestCount)
      else if Planet.InventionLevels[7] = HighestLevel - 1 then Inc(PreviousCount);
    end;
  end;
  if HighestCount >= 5 then TechLevel := Max(1, HighestLevel)
  else if (HighestCount >= 2) or (HighestCount + PreviousCount >= 5) then TechLevel := Max(1, HighestLevel - 1)
  else TechLevel := Max(1, HighestLevel - 2);
end;
{ @end $7BB904 }

{ @routine $7BBA6C TGalaxy_CancelEnemyJumpsToStar }
procedure TGalaxy.CancelEnemyJumpsToStar(Star: TStar);
var I, J: Integer; Other: TStar; Ship: TShip;
begin
  for I := 0 to Stars.Count - 1 do begin
    Other := TStar(Stars[I]);
    if Other <> Star then
      for J := 0 to Other.Ships.Count - 1 do begin
        Ship := TShip(Other.Ships[J]);
        if Ship.InNormalSpace then begin
          if ((Ship is TKling) or (Ship.CurrentStanding = ssPirateMilitary)) and (Ship.Order = soJump) and (Ship.OrderTarget = Star) then Ship.OrderNone(False);
          if (Ship is TRuins) and (Ship.TypeId = Byte(rstDominion)) and ((Ship as TRuins).FlyToStar = Star) then begin
            (Ship as TRuins).FlyToStar := nil;
            (Ship as TRuins).FlyDate := 0;
            Ship.OrderNone(False);
          end;
        end;
      end;
  end;
end;
{ @end $7BBA6C }

{ @routine $7BBBB8 TGalaxy_SelectStarForLiberationAttack }
function TGalaxy.SelectStarForLiberationAttack(Origin: TStar; FriendlyFaction: TStarFaction): TStar;
var I, J, Weight, BestWeight: Integer;
  Star, Other: TStar;
begin
  BestWeight := MaxInt;
  Result := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := TStar(Galaxy.Stars[I]);
    if (Star.ControlFaction <> FriendlyFaction) and (Star.Battle = 0) and (Star.Constellation.Id <> 20) then begin
      Weight := 0;
      for J := 1 to Galaxy.Stars.Count - 1 do begin
        Other := TObject(Star.StarDistances[J].Star) as TStar;
        if (Other.ControlFaction = FriendlyFaction) and (Other.Status.CustomFaction = '') then Inc(Weight, Star.StarDistances[J].Distance);
      end;
      if Origin <> nil then Weight := Round(RemapClamped(PointDistance(Origin.Position, Star.Position), 10, 100, Weight, 100 * Weight));
      Weight := Round(NextRandomFloatRange(Weight, 2 * Weight, RandomState));
      if Weight < BestWeight then begin BestWeight := Weight; Result := Star; end;
    end;
  end;
end;
{ @end $7BBBB8 }

{ @routine $7BBD50 TGalaxy_ComputeGlobalGoodsPriceBands }
procedure TGalaxy.ComputeGlobalGoodsPriceBands;
var
  Good: Byte;
  PriceSpread: Single;
begin
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    aConst.GoodsMarket[Good].MinPrice := Self.ScaleGoodsPriceByGalaxyAge(aConst.GoodsMarketBase[Good].MinPrice);
    aConst.GoodsMarket[Good].AveragePrice := Self.ScaleGoodsPriceByGalaxyAge(aConst.GoodsMarketBase[Good].AveragePrice);
    aConst.GoodsMarket[Good].MaxPrice := Self.ScaleGoodsPriceByGalaxyAge(aConst.GoodsMarketBase[Good].MaxPrice);
    aConst.GoodsMarket[Good].BaseStock := Self.ScaleGoodsStockByGalaxyAge(aConst.GoodsMarketBase[Good].BaseStock);
    PriceSpread := aConst.GoodsMarket[Good].AveragePrice - aConst.GoodsMarket[Good].MinPrice;
    Inc(aConst.GoodsMarket[Good].MinPrice, System.Round(PriceSpread * aConst.GalaxyDifficultyTuning[Self.DifficultyLevels[1]].MarketPriceBandSqueeze));
    if aConst.GoodsMarket[Good].MinPrice >= aConst.GoodsMarket[Good].AveragePrice - 1 then
      aConst.GoodsMarket[Good].MinPrice := aConst.GoodsMarket[Good].AveragePrice - 2;
    Dec(aConst.GoodsMarket[Good].MaxPrice, System.Round(PriceSpread * aConst.GalaxyDifficultyTuning[Self.DifficultyLevels[1]].MarketPriceBandSqueeze));
    if aConst.GoodsMarket[Good].MaxPrice <= aConst.GoodsMarket[Good].AveragePrice + 1 then
      aConst.GoodsMarket[Good].MaxPrice := aConst.GoodsMarket[Good].AveragePrice + 2;
  end;
end;
{ @end $7BBD50 }

{ @routine $7BBF78 TGalaxy_GetGoodsPricePercent }
function TGalaxy.GetGoodsPricePercent(GoodsType: Byte; Price: Integer): TPercent;
begin
  Result := Round(RemapClamped(Price, GoodsMarket[GoodsType].MinPrice, GoodsMarket[GoodsType].MaxPrice, 0, 100));
end;
{ @end $7BBF78 }

{ @routine $7BBFE8 TGalaxy_ScaleGoodsPriceByGalaxyAge }
function TGalaxy.ScaleGoodsPriceByGalaxyAge(BaseValue: Integer): Integer;
begin
  Result := Round(RemapClamped(CurrentTurn, GoodsInflationStartTurn, GoodsInflationEndTurn, BaseValue * GoodsInflationMin, BaseValue * GoodsInflationMax));
end;
{ @end $7BBFE8 }

{ @routine $7BC054 TGalaxy_ScaleGoodsStockByGalaxyAge }
function TGalaxy.ScaleGoodsStockByGalaxyAge(BaseValue: Integer): Integer;
begin
  Result := Round(RemapClamped(CurrentTurn, GoodsInflationStartTurn, GoodsInflationEndTurn, BaseValue * GoodsStockMin, BaseValue * GoodsStockMax));
end;
{ @end $7BC054 }

{ @routine $7BC0C0 TGalaxy_ScaleIntByTechLevel }
function TGalaxy.ScaleIntByTechLevel(AtLevelTwo, AtLevelSeven: Integer): Integer;
begin
  Result := Round(RemapClamped(TechLevel, 2, 7, AtLevelTwo, AtLevelSeven));
end;
{ @end $7BC0C0 }

{ @routine $7BC11C TGalaxy_InterpolateSingleByTechLevel }
function TGalaxy.InterpolateSingleByTechLevel(AtLevelTwo, AtLevelSeven: Single): Single;
begin
  Result := RemapClamped(TechLevel, 2, 7, AtLevelTwo, AtLevelSeven);
end;
{ @end $7BC11C }

{ @routine $7BC1D8 TGalaxy_SelectWeaponInfo }
function TGalaxy.SelectWeaponInfo(Seed: Cardinal; AvailabilityMask: TWeaponAvailabilityMask; MaximumTechLevel, MinimumTechLevel: Byte): PWeaponInfo;
var
  I: Integer;
  Candidates: TList;
  Info, Nearest: PWeaponInfo;
  Distance, NearestDistance: Integer;

  // @nested $7BC170 TechDistance
  function TechDistance(TechLevel: Integer): Integer; // @addr 0x7BC170 @note "Nested helper with caller-popped static link. Minimum/maximum bytes are at ParentFrame+8/+12."
  begin
    Result := 0;
    if TechLevel > MaximumTechLevel then Result := TechLevel - MaximumTechLevel;
    if TechLevel < MinimumTechLevel then Result := Max(Result, MinimumTechLevel - TechLevel);
  end;

begin
  Candidates := TList.Create;
  NearestDistance := 0;
  Nearest := nil;
  for I := 1 to CountItemTypesInMask([Ord(t_Weapon1)..Ord(t_Weapon18)]) do
  begin
    Info := @WeaponInfos[TItemType(GetItemTypeFromMask([Ord(t_Weapon1)..Ord(t_Weapon18)], I))];
    if Byte(Info.Availability) in AvailabilityMask then
    begin
      Distance := TechDistance(Info.TechLevel);
      if Distance > 0 then
      begin
        if (Candidates.Count <= 0) and ((Nearest = nil) or (Distance < NearestDistance)) then
        begin
          Nearest := Info;
          NearestDistance := Distance;
        end;
      end
      else Candidates.Add(Info);
    end;
  end;
  for I := 0 to CustomWeaponTypes.Count - 1 do
  begin
    Info := PWeaponInfo(CustomWeaponTypes[I]);
    if Byte(Info.Availability) in AvailabilityMask then
    begin
      Distance := TechDistance(Info.TechLevel);
      if Distance > 0 then
      begin
        if (Candidates.Count <= 0) and ((Nearest = nil) or (Distance < NearestDistance)) then
        begin
          Nearest := Info;
          NearestDistance := Distance;
        end;
      end
      else Candidates.Add(CustomWeaponTypes[I]);
    end;
  end;
  if Candidates.Count > 0 then Result := PWeaponInfo(Candidates[SeededRandomIntRange(0, Candidates.Count - 1, Seed)])
  else Result := Nearest;
  Candidates.Free;
  if Result = nil then Result := @WeaponInfos;
end;
{ @end $7BC1D8 }

{ @routine $7BC3B0 TGalaxy_SelectMicroModule }
function TGalaxy.SelectMicroModule(MinimumPriority, MaximumPriority: Byte; Seed: Cardinal; Context: TObject): Integer;
type
  TModuleOwnerMasks = array[0..2] of TOwnerMask;
var
  Attempts, ModuleIndex, BestIndex, BestPriority: Integer;
begin
  Attempts := 0;
  BestIndex := -1;
  BestPriority := 100;
  repeat
    Inc(Attempts);
    ModuleIndex := NextRandomIntRange(0, MicroModuleTemplateCount - 1, Seed);
    if aConst.MicroModuleTemplates[ModuleIndex].SpecialOnly then Continue;
    if Context <> nil then
    begin
      if (Context is TKling) and not TShip(Context).HasScriptStateText then
      begin
        if not (Byte((Context as TKling).DominatorSeries) in aConst.MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) then Continue;
        if not (oiDominator in aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Continue;
        if not aConst.MicroModuleTemplates[ModuleIndex].RacialRestriction and
          (aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask <> [oiDominator]) and
          (aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * [oiMaloc..oiDominator, oiPirate] <>
            [oiMaloc..oiDominator, oiPirate]) then Continue;
      end;
      if aConst.MicroModuleTemplates[ModuleIndex].RacialRestriction then
      begin
        if Context is TPlanet then
        begin
          if not (TPlanet(Context).OwnerId in aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Continue;
        end
        else if Context is TRuins then
        begin
          if TRuins(Context).CurrentStanding in aConst.FactionStandingMasks[TRuins(Context).CurrentStar.ControlFaction] then
          begin
            if aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask *
              TModuleOwnerMasks(aConst.PlanetOwnerMasks)[Ord(TRuins(Context).CurrentStar.ControlFaction)] = [] then Continue;
          end
          else
          begin
            if TRuins(Context).CurrentStanding in [ssCoalitionMilitary..ssNeutral] then
              if aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * aConst.PlanetOwnerMasks.Coalition = [] then Continue;
            if TRuins(Context).CurrentStanding in [ssPiratePassive..ssPirateMilitary] then
              if aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * aConst.PlanetOwnerMasks.PirateClan = [] then Continue;
          end;
        end
        else if Context is TNormalShip then
        begin
          if not (RaceToOwner(TNormalShip(Context).PilotRace) in aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Continue;
        end;
      end;
    end;
    if (Context = nil) and aConst.MicroModuleTemplates[ModuleIndex].RacialRestriction then Continue;
    if (aConst.MicroModuleTemplates[ModuleIndex].Priority in [MinimumPriority..MaximumPriority]) then
    begin
      Result := ModuleIndex;
      Exit;
    end;
    if Attempts > 1000 then
    begin
      if BestIndex >= 0 then Result := BestIndex
      else Result := ModuleIndex;
      Exit;
    end;
    if (aConst.MicroModuleTemplates[ModuleIndex].Priority > MaximumPriority) and
      ((BestIndex < 0) or (aConst.MicroModuleTemplates[ModuleIndex].Priority < BestPriority)) then
    begin
      BestIndex := ModuleIndex;
      BestPriority := aConst.MicroModuleTemplates[ModuleIndex].Priority;
    end;
    if Attempts mod 99 = 0 then
    begin
      MinimumPriority := Max(0, MinimumPriority - 10);
      MaximumPriority := Min(100, MaximumPriority + 10);
      if (BestIndex >= 0) and (MaximumPriority >= BestPriority) then
      begin
        Result := BestIndex;
        Exit;
      end;
    end;
  until False;
end;
{ @end $7BC3B0 }

{ @routine $7BC7B8 TGalaxy_SelectMicroModuleForEquipment }
function TGalaxy.SelectMicroModuleForEquipment(MinimumPriority, MaximumPriority: Byte; Seed: Cardinal; Context: TObject; Item: Pointer): Integer;
type
  TModuleOwnerMasks = array[0..2] of TOwnerMask;
var
  Attempts, ModuleIndex, BestIndex, BestPriority: Integer;
  Equipment: TEquipment;
begin
  Attempts := 0;
  Equipment := Item;
  BestIndex := -1;
  BestPriority := 100;
  repeat
    Inc(Attempts);
    ModuleIndex := NextRandomIntRange(0, MicroModuleTemplateCount - 1, Seed);
    if aConst.MicroModuleTemplates[ModuleIndex].SpecialOnly then Continue;
    if Context <> nil then
    begin
      if (Context is TKling) and not TShip(Context).HasScriptStateText then
      begin
        if not (Byte((Context as TKling).DominatorSeries) in aConst.MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) then Continue;
        if not (oiDominator in aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Continue;
        if not aConst.MicroModuleTemplates[ModuleIndex].RacialRestriction and
          (aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask <> [oiDominator]) and
          (aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * [oiMaloc..oiDominator, oiPirate] <>
            [oiMaloc..oiDominator, oiPirate]) then Continue;
      end;
      if aConst.MicroModuleTemplates[ModuleIndex].RacialRestriction then
      begin
        if Context is TPlanet then
        begin
          if not (TPlanet(Context).OwnerId in aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Continue;
        end
        else if Context is TRuins then
        begin
          if TRuins(Context).CurrentStanding in aConst.FactionStandingMasks[TRuins(Context).CurrentStar.ControlFaction] then
          begin
            if aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask *
              TModuleOwnerMasks(aConst.PlanetOwnerMasks)[Ord(TRuins(Context).CurrentStar.ControlFaction)] = [] then Continue;
          end
          else
          begin
            if TRuins(Context).CurrentStanding in [ssCoalitionMilitary..ssNeutral] then
              if aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * aConst.PlanetOwnerMasks.Coalition = [] then Continue;
            if TRuins(Context).CurrentStanding in [ssPiratePassive..ssPirateMilitary] then
              if aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask * aConst.PlanetOwnerMasks.PirateClan = [] then Continue;
          end;
        end
        else if Context is TNormalShip then
        begin
          if not (RaceToOwner(TNormalShip(Context).PilotRace) in aConst.MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask) then Continue;
        end;
      end;
    end;
    if (Context = nil) and aConst.MicroModuleTemplates[ModuleIndex].RacialRestriction then Continue;
    if (aConst.MicroModuleTemplates[ModuleIndex].Priority in [MinimumPriority..MaximumPriority]) and
      ((Equipment = nil) or CanInstallMicroModule(ModuleIndex, Equipment)) then
    begin
      Result := ModuleIndex;
      Exit;
    end;
    if (Attempts > 1000) and (BestIndex >= 0) and
      ((Equipment = nil) or CanInstallMicroModule(BestIndex, Equipment)) then
    begin
      Result := BestIndex;
      Exit;
    end;
    if Attempts > 2000 then
    begin
      Result := ModuleIndex;
      Exit;
    end;
    if (aConst.MicroModuleTemplates[ModuleIndex].Priority > MaximumPriority) and
      ((BestIndex < 0) or (aConst.MicroModuleTemplates[ModuleIndex].Priority < BestPriority)) and
      ((Equipment = nil) or CanInstallMicroModule(ModuleIndex, Equipment)) then
    begin
      BestIndex := ModuleIndex;
      BestPriority := aConst.MicroModuleTemplates[ModuleIndex].Priority;
    end;
    if Attempts mod 99 = 0 then
    begin
      MinimumPriority := Max(0, MinimumPriority - 10);
      MaximumPriority := Min(100, MaximumPriority + 10);
      if (BestIndex >= 0) and (MaximumPriority >= BestPriority) then
      begin
        Result := BestIndex;
        Exit;
      end;
    end;
  until False;
end;
{ @end $7BC7B8 }

{ @routine $7BCC34 TGalaxy_SelectHullSeries }
function TGalaxy.SelectHullSeries(OwnerId: TOwnerId; HullType, MinimumRarity, MaximumRarity: Byte): Integer;
var I, J, Temp: Integer; Indices: array of Integer;
begin
  SetLength(Indices, HullSeriesCount);
  for I := 0 to HullSeriesCount - 1 do
  begin
    Indices[I] := I;
    J := NextRandomIntRange(0, HullSeriesCount - 1, RandomState);
    if J < I then
    begin
      Temp := Indices[J];
      Indices[J] := I;
      Indices[I] := Temp;
    end;
  end;
  for I := 0 to HullSeriesCount - 1 do
    if (OwnerId in HullSeriesDefinitions[Indices[I]].AllowedOwners) and
       (HullType in HullSeriesDefinitions[Indices[I]].AllowedShipTypes) then
      if (HullSeriesDefinitions[Indices[I]].Year <= RemapClamped(TechLevel, 2, 8, 0, 80) + NextRandomIntRange(0, 20, RandomState)) and
         (HullSeriesDefinitions[Indices[I]].ProbabilityWeight >= MinimumRarity) and
         (HullSeriesDefinitions[Indices[I]].ProbabilityWeight <= MaximumRarity) then
        if NextRandomUnitFloat(RandomState) <= 1 / HullSeriesDefinitions[Indices[I]].ProbabilityWeight then
        begin
          Result := Indices[I];
          Exit;
        end;
  Result := -1;
end;
{ @end $7BCC34 }

{ @routine $7BCEAC TGalaxy_IsDominatorSeriesUnresolved }
function TGalaxy.IsDominatorSeriesUnresolved(Series: TDominatorSeries): Boolean;
begin
  case Series of
    dsBlazer: Result := BlazerSeriesResolvedTurn = 0;
    dsKeller: Result := KellerSeriesResolvedTurn = 0;
    dsTerron: Result := TerronSeriesResolvedTurn = 0;
  else Result := False;
  end;
end;
{ @end $7BCEAC }

{ @routine $7BCF04 TGalaxy_HasUnresolvedDominatorSeries }
function TGalaxy.HasUnresolvedDominatorSeries(Series: TDominatorSeriesSet): Boolean;
var I: Byte;
begin
  Result := False;
  for I := 0 to 2 do begin
    if TDominatorSeries(I) in Series then
      case I of
        0: Result := BlazerSeriesResolvedTurn = 0;
        1: Result := KellerSeriesResolvedTurn = 0;
        2: Result := TerronSeriesResolvedTurn = 0;
      end;
    if Result then Break;
  end;
end;
{ @end $7BCF04 }

{ @routine $7BCF7C TGalaxy_ProcessPlayerSatelliteExploration }
procedure TGalaxy.ProcessPlayerSatelliteExploration;
var I, Water, Land, Hill: Integer;
  Satellite: TSatellite;
  Wear: Double;
  Changed: Boolean;
  Amount: Integer;
begin
  if GetPlayer <> nil then begin
    Changed := False;
    for I := 0 to GetPlayer.Satellites.Count - 1 do begin
      Satellite := TSatellite(GetPlayer.Satellites[I]);
      if (Satellite.BrokenFlag = 0) and (Satellite.TargetPlanet <> nil) then begin
        with TObject(Satellite.TargetPlanet) as TPlanet do begin
        Water := WaterExplored;
        Land := LandExplored;
        Hill := HillExplored;
        WaterExplored := Min(WaterTiles, WaterExplored + Satellite.WaterExplorationRate);
        LandExplored := Min(LandTiles, LandExplored + Satellite.LandExplorationRate);
        HillExplored := Min(HillTiles, HillExplored + Satellite.HillExplorationRate);
        Amount := (WaterExplored - Water) + (LandExplored - Land) + (HillExplored - Hill);
        Inc(GetPlayer.SatelliteTilesExplored, Amount);
        TryAddAchievementProgress('ARCHEOLOGY', Amount);
        if (Water < WaterExplored) or (Land < LandExplored) or (Hill < HillExplored) then begin
          Wear := 1;
          if GetPlayer.Satellites.Count > GetPlayer.GetSatelliteLimit then
            Wear := Wear + (GetPlayer.Satellites.Count - GetPlayer.GetSatelliteLimit) * 1.0;
          Changed := True;
        end else Wear := 0.1;
        GetPlayer.ApplyItemDegradation(Satellite, idkUse, NextRandomUnitFloat(RandomState) * Satellite.WearPerTurn * Wear);
        end;
      end;
    end;
    if Changed then GetPlayer.RefreshStorageBubbles;
  end;
end;
{ @end $7BCF7C }

{ @routine $7BD240 TGalaxy_CountExistingSatellites }
function TGalaxy.CountExistingSatellites: Integer;
var I, J, K: Integer; Star: TStar; Ship: TShip; Item: TItem; Stored: TStoredItem;
begin
  Result := GetPlayer.CountStoredItemUnits(nil, t_Satellite) + GetPlayer.Satellites.Count;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Items.Count - 1 do begin
      Item := TItem(Star.Items[J]);
      if Item is TSatellite then Inc(Result);
    end;
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := TShip(Star.Ships[J]);
      for K := 0 to Ship.Inventory.Count - 1 do begin
        Item := TItem(Ship.Inventory[K]);
        if Item is TSatellite then Inc(Result);
      end;
    end;
  end;
  for I := 0 to StoredItems.Count - 1 do begin
    Stored := TStoredItem(StoredItems[I]);
    if (Stored.Item <> nil) and (Stored.Item is TSatellite) then Inc(Result);
  end;
end;
{ @end $7BD240 }

{ @routine $7BD3CC TGalaxy_ComputeScaledMiniMoney }
function TGalaxy.ComputeScaledMiniMoney(Owner: TOwnerId): Integer;
begin
  Result := Round(AverageRangerCapital * 0.01 * OwnerInfo[Owner].FuelPriceFactor);
  if Result > 250 then Result := Round((Result - 250) * 0.3) + 250;
end;
{ @end $7BD3CC }

{ @routine $7BD44C TGalaxy_ComputeScaledSmallMoney }
function TGalaxy.ComputeScaledSmallMoney(Owner: TOwnerId): Integer;
begin
  Result := Round(AverageRangerCapital * (1 / 65) * OwnerInfo[Owner].FuelPriceFactor);
  if Result > 1000 then Result := Round((Result - 1000) * 0.3) + 1000;
end;
{ @end $7BD44C }

{ @routine $7BD4CC TGalaxy_ComputeScaledAverageMoney }
function TGalaxy.ComputeScaledAverageMoney(Owner: TOwnerId): Integer;
begin
  Result := Round(AverageRangerCapital * 0.025 * OwnerInfo[Owner].FuelPriceFactor);
  if Result > 5000 then Result := Round((Result - 5000) * 0.3) + 5000;
end;
{ @end $7BD4CC }

{ @routine $7BD54C TGalaxy_ComputeScaledBigMoney }
function TGalaxy.ComputeScaledBigMoney(Owner: TOwnerId): Integer;
begin
  Result := Round(AverageRangerCapital * 0.04 * OwnerInfo[Owner].FuelPriceFactor);
  if Result > 10000 then Result := Round((Result - 10000) * 0.3) + 10000;
end;
{ @end $7BD54C }

{ @routine $7BD5CC TGalaxy_ComputeScaledHugeMoney }
function TGalaxy.ComputeScaledHugeMoney(Owner: TOwnerId): Integer;
begin
  Result := Round(AverageRangerCapital * (1 / 15) * OwnerInfo[Owner].FuelPriceFactor);
  if Result > 25000 then Result := Round((Result - 25000) * 0.3) + 25000;
end;
{ @end $7BD5CC }

{ @routine $7BD64C TGalaxy_ResolveMoneySizeTag }
function TGalaxy.ResolveMoneySizeTag(Tag: WideString; Owner: TOwnerId): Integer;
begin
  if Tag = 'Zero' then Result := 0
  else if Tag = 'Mini' then Result := Galaxy.ComputeScaledMiniMoney(Owner)
  else if Tag = 'Small' then Result := Galaxy.ComputeScaledSmallMoney(Owner)
  else if Tag = 'Average' then Result := Galaxy.ComputeScaledAverageMoney(Owner)
  else if Tag = 'Big' then Result := Galaxy.ComputeScaledBigMoney(Owner)
  else if Tag = 'Huge' then Result := Galaxy.ComputeScaledHugeMoney(Owner)
  else begin RaiseWideMessage('Error! Указан неправильный формат размера у вещи ' + Tag); Result := -1; end;
end;
{ @end $7BD64C }

{ @routine $7BD850 TGalaxy_GetMiniGoodsQuantity }
function TGalaxy.GetMiniGoodsQuantity(GoodsType: Byte): Integer;
begin
  Result := Round(GoodsMarket[GoodsType].BaseStock * 0.1);
end;
{ @end $7BD850 }

{ @routine $7BD894 TGalaxy_GetSmallGoodsQuantity }
function TGalaxy.GetSmallGoodsQuantity(GoodsType: Byte): Integer;
begin
  Result := Round(GoodsMarket[GoodsType].BaseStock * 0.5);
end;
{ @end $7BD894 }

{ @routine $7BD8D0 TGalaxy_GetAverageGoodsQuantity }
function TGalaxy.GetAverageGoodsQuantity(GoodsType: Byte): Integer;
var Stock: Integer;
begin
  Stock := GoodsMarket[GoodsType].BaseStock;
  Result := Round(Stock);
end;
{ @end $7BD8D0 }

{ @routine $7BD908 TGalaxy_GetBigGoodsQuantity }
function TGalaxy.GetBigGoodsQuantity(GoodsType: Byte): Integer;
begin
  Result := Round(GoodsMarket[GoodsType].BaseStock * 1.5);
end;
{ @end $7BD908 }

{ @routine $7BD944 TGalaxy_GetHugeGoodsQuantity }
function TGalaxy.GetHugeGoodsQuantity(GoodsType: Byte): Integer;
begin
  Result := Round(GoodsMarket[GoodsType].BaseStock * 2.0);
end;
{ @end $7BD944 }

{ @routine $7BD980 TGalaxy_GetGoodsQuantityBySize }
function TGalaxy.GetGoodsQuantityBySize(Size: Byte; GoodsType: Byte): Integer;
begin
  if Size = 0 then Result := 0
  else if Size = 1 then Result := Galaxy.GetMiniGoodsQuantity(GoodsType)
  else if Size = 2 then Result := Galaxy.GetSmallGoodsQuantity(GoodsType)
  else if Size = 3 then Result := Galaxy.GetAverageGoodsQuantity(GoodsType)
  else if Size = 4 then Result := Galaxy.GetBigGoodsQuantity(GoodsType)
  else if Size = 5 then Result := Galaxy.GetHugeGoodsQuantity(GoodsType)
  else begin RaiseWideMessage('Error! Указан неправильный формат количества товара '); Result := -1; end;
end;
{ @end $7BD980 }

{ @routine $7BDAA0 TGalaxy_ClassifyGoodsQuantity }
function TGalaxy.ClassifyGoodsQuantity(Quantity: Integer; GoodsType: Byte): Byte;
var Distance1, Distance2, Distance3, Distance4, Distance5: Integer;
begin
  if Quantity = 0 then begin Result := 0; Exit; end;
  Distance1 := Abs(GetGoodsQuantityBySize(1, GoodsType) - Quantity);
  Distance2 := Abs(GetGoodsQuantityBySize(2, GoodsType) - Quantity);
  Distance3 := Abs(GetGoodsQuantityBySize(3, GoodsType) - Quantity);
  Distance4 := Abs(GetGoodsQuantityBySize(4, GoodsType) - Quantity);
  Distance5 := Abs(GetGoodsQuantityBySize(5, GoodsType) - Quantity);
  if Distance1 < Distance2 then Result := 1
  else if Distance2 < Distance3 then Result := 2
  else if Distance3 < Distance4 then Result := 3
  else if Distance4 < Distance5 then Result := 4
  else Result := 5;
end;
{ @end $7BDAA0 }

{ @routine $7BDB7C TGalaxy_GetMinimumGoodsPrice }
function TGalaxy.GetMinimumGoodsPrice(GoodsType: Byte): Integer;
begin
  Result := GoodsMarket[GoodsType].MinPrice;
end;
{ @end $7BDB7C }

{ @routine $7BDBA8 TGalaxy_GetLowGoodsPrice }
function TGalaxy.GetLowGoodsPrice(GoodsType: Byte): Integer;
begin
  Result := (GoodsMarket[GoodsType].MinPrice + GoodsMarket[GoodsType].AveragePrice) div 2;
end;
{ @end $7BDBA8 }

{ @routine $7BDBF0 TGalaxy_GetAverageGoodsPrice }
function TGalaxy.GetAverageGoodsPrice(GoodsType: Byte): Integer;
begin
  Result := GoodsMarket[GoodsType].AveragePrice;
end;
{ @end $7BDBF0 }

{ @routine $7BDC1C TGalaxy_GetHighGoodsPrice }
function TGalaxy.GetHighGoodsPrice(GoodsType: Byte): Integer;
begin
  Result := (GoodsMarket[GoodsType].AveragePrice + GoodsMarket[GoodsType].MaxPrice) div 2;
end;
{ @end $7BDC1C }

{ @routine $7BDC64 TGalaxy_GetMaximumGoodsPrice }
function TGalaxy.GetMaximumGoodsPrice(GoodsType: Byte): Integer;
begin
  Result := GoodsMarket[GoodsType].MaxPrice;
end;
{ @end $7BDC64 }

{ @routine $7BDC90 TGalaxy_GetGoodsPriceByLevel }
function TGalaxy.GetGoodsPriceByLevel(Level: Byte; GoodsType: Byte): Integer;
begin
  if Level = 1 then Result := Galaxy.GetMinimumGoodsPrice(GoodsType)
  else if Level = 2 then Result := Galaxy.GetLowGoodsPrice(GoodsType)
  else if Level = 3 then Result := Galaxy.GetAverageGoodsPrice(GoodsType)
  else if Level = 4 then Result := Galaxy.GetHighGoodsPrice(GoodsType)
  else if Level = 5 then Result := Galaxy.GetMaximumGoodsPrice(GoodsType)
  else begin RaiseWideMessage('Error! Указан неправильный формат стоимости товара '); Result := -1; end;
end;
{ @end $7BDC90 }

{ @routine $7BDD9C TGalaxy_ClassifyGoodsPrice }
function TGalaxy.ClassifyGoodsPrice(Price: Integer; GoodsType: Byte): Byte;
var Distance1, Distance2, Distance3, Distance4, Distance5: Integer;
begin
  if Price = 0 then begin Result := 0; Exit; end;
  Distance1 := Abs(GetGoodsPriceByLevel(1, GoodsType) - Price);
  Distance2 := Abs(GetGoodsPriceByLevel(2, GoodsType) - Price);
  Distance3 := Abs(GetGoodsPriceByLevel(3, GoodsType) - Price);
  Distance4 := Abs(GetGoodsPriceByLevel(4, GoodsType) - Price);
  Distance5 := Abs(GetGoodsPriceByLevel(5, GoodsType) - Price);
  if Distance1 < Distance2 then Result := 1
  else if Distance2 < Distance3 then Result := 2
  else if Distance3 < Distance4 then Result := 3
  else if Distance4 < Distance5 then Result := 4
  else Result := 5;
end;
{ @end $7BDD9C }

{ @routine $7BDE78 TGalaxy_ProcessStationSpawning }
procedure TGalaxy.ProcessStationSpawning;
var I, Count: Integer; Constellation: TConstellation; Kind: TStationType;
begin
  if NextRandomUnitFloat(RandomState) < 0.3 then Exit;
  for Kind := rstRangerCenter to rstDominion do begin
    Count := 0;
    for I := 0 to Galaxy.Constellations.Count - 1 do begin
      Constellation := TConstellation(Galaxy.Constellations[I]);
      if Constellation.Visible and (Constellation.ShipTypeCounts[Ord(Kind)] > 0) then Inc(Count);
    end;
    if (Count = 0) and (NextRandomUnitFloat(RandomState) < 0.3) then begin ReplenishStationType(Kind); Exit; end;
  end;
  ReplenishStationType(TStationType((CurrentTurn + 100) mod 7 + 6));
end;
{ @end $7BDE78 }

{ @routine $7BDF64 TGalaxy_ReplenishStationType }
procedure TGalaxy.ReplenishStationType(StationType: TStationType);
const
  StationMask = [Ord(rstRangerCenter)..Ord(rstDominion)];
  MilitaryBaseMask = [Ord(rstMilitaryBase)];
  PirateBaseMask = [Ord(rstPirateBase)];
var I, J: Integer; Hostile, Assigned: Boolean; Constellation: TConstellation; Star: TStar; Station: TRuins;
begin
  for I := 0 to Galaxy.Constellations.Count - 1 do begin
    Constellation := TConstellation(Galaxy.Constellations[I]);
    if not ((Constellation.Id <> 20) and (Constellation.ShipTypeCounts[Ord(StationType)] <= 0) and
      (Constellation.CountShipsByTypeMask(StationMask) < Constellation.Stars.Count) and (Constellation.ShipTypeCounts[stKling] <= 0)) then Continue;
    Hostile := False;
    for J := 0 to Constellation.Stars.Count - 1 do begin
      Star := Constellation.Stars[J];
      if (Star.ControlFaction = sfDominators) or (Star.Status.CustomFaction <> '') then Hostile := True;
    end;
    if not Hostile then begin
      Star := Constellation.Stars[NextRandomIntRange(0, Constellation.Stars.Count - 1, RandomState)];
      if not ((Star.Battle = 0) and (StationDefaultStandings[Ord(StationType)] in FactionStandingMasks[Star.ControlFaction]) and
        (GetPlayer.CurrentStar <> Star) and (Star.DaysSincePlayerVisit >= 70) and (Star.CountShipsByTypeMask(StationMask) <= 1) and
        ((StationType <> rstPirateBase) or (Star.CountShipsByTypeMask(MilitaryBaseMask) <= 0)) and
        ((StationType <> rstMilitaryBase) or (Star.CountShipsByTypeMask(PirateBaseMask) <= 0))) then Continue;
      if StationType = rstMilitaryBase then begin
        Assigned := False;
        for J := 0 to Constellation.Stars.Count - 1 do
          if HasMilitaryBaseAssignedToStar(TStar(Constellation.Stars[J])) then begin Assigned := True; Break; end;
        if Assigned then Continue;
      end;
      if StationType = rstDominion then begin
        Assigned := False;
        for J := 0 to Constellation.Stars.Count - 1 do
          if TStar(Constellation.Stars[J]).Dominion <> nil then begin Assigned := True; Break; end;
        if Assigned then Continue;
      end;
      Station := TRuins.Create;
      Station.Init(StationType, Star, '');
      if CoalitionDefeatedTurn = 0 then
        Galaxy.AddPlanetNewsWithPlayerBubble(41,
          FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.' + ShipTypeNames[Ord(StationType)].Name,
            GenerationSeed * (Galaxy.CurrentTurn div 10)), '<color=255,240,100>',
            '<Name>', Station.GetName, '<Star>', Star.Name, '<Sector>', Star.Constellation.GetName));
      Exit;
    end;
  end;
end;
{ @end $7BDF64 }

{ @routine $7BE398 TGalaxy_ProcessDominatorResearchProgress }
procedure TGalaxy.ProcessDominatorResearchProgress;
var Series: TDominatorSeries;
  Progress: Single;
  News: WideString;
begin
  if ((DominatorResearch[0].Progress < 100) or (DominatorResearch[1].Progress < 100) or
      (DominatorResearch[2].Progress < 100)) and (ShipTypeCounts[Ord(rstScienceBase)] > 0) then
    for Series := dsBlazer to dsTerron do
      if DominatorResearch[Ord(Series)].Progress < 100 then begin
        Progress := DominatorResearch[Ord(Series)].Progress + GetDominatorResearchRate(Series);
        if CurrentTurn mod NextRandomIntRange(2, 5, RandomState) = 0 then
          DominatorResearch[Ord(Series)].Material := Max(0, DominatorResearch[Ord(Series)].Material -
            NextRandomIntRange(1, GalaxyDifficultyTuning[DifficultyLevels[2]].MaximumResearchMaterialConsumption, RandomState));
        if Progress >= 100 then begin
          case Series of
            dsBlazer: News := 'Programms.LogicalNegation.GalaxyNews';
            dsKeller: News := 'Programms.Dematerial.GalaxyNews';
            dsTerron: News := 'Programms.Energotron.GalaxyNews';
          end;
          Galaxy.AddPlanetNewsWithPlayerBubble(43, PickLocalizedTextVariant(News, GenerationSeed * (Galaxy.CurrentTurn div 10)));
          Inc(GetPlayer.AchievementStats.CompletedResearchPrograms);
          GetPlayer.AchievementStats.CheckScienceAchievement;
        end;
        DominatorResearch[Ord(Series)].Progress := Min(100, Progress);
      end;
end;
{ @end $7BE398 }

{ @routine $7BE6B4 TGalaxy_IsDominatorResearchComplete }
function TGalaxy.IsDominatorResearchComplete(Series: TDominatorSeriesSet): Boolean;
var I: Byte;
begin
  Result := True;
  for I := 0 to 2 do
    if (TDominatorSeries(I) in Series) and (DominatorResearch[I].Progress < 100) then begin
      Result := False;
      Break;
    end;
end;
{ @end $7BE6B4 }

{ @routine $7BE710 TGalaxy_GetDominatorResearchRate }
function TGalaxy.GetDominatorResearchRate(Series: TDominatorSeries): Single;
var Efficiency: Integer;
begin
  Efficiency := GetDominatorResearchEfficiency(Series);
  Result := RemapClamped(Efficiency, 0, 100, 0.00001, GalaxyDifficultyTuning[DifficultyLevels[2]].MaximumDominatorResearchRate) * DominatorResearchRateMultipliers[Ord(Series)];
end;
{ @end $7BE710 }

{ @routine $7BE78C TGalaxy_GetDominatorResearchEfficiency }
function TGalaxy.GetDominatorResearchEfficiency(Series: TDominatorSeries): TPercent;
begin
  Result := Trunc(RemapClamped(DominatorResearch[Ord(Series)].Material, 0, 300, 20, 100));
end;
{ @end $7BE78C }

{ @routine $7BE7DC TGalaxy_FindStationByTypeAndIndex }
function TGalaxy.FindStationByTypeAndIndex(Index: Integer; StationType: TStationType): Pointer;
var Star: TStar; Ship: TShip; I, J, Number: Integer;
begin
  Result := nil;
  Number := 1;
  if ShipTypeCounts[Ord(StationType)] > 0 then
    for I := 0 to Galaxy.Stars.Count - 1 do begin
      Star := TStar(Galaxy.Stars[I]);
      for J := 0 to Star.Ships.Count - 1 do begin
        Ship := TShip(Star.Ships[J]);
        if Ship.TypeId = Byte(StationType) then begin
          if Number = Index then begin Result := Ship; Exit; end;
          Inc(Number);
        end;
      end;
    end;
end;
{ @end $7BE7DC }

{ @routine $7BE89C TGalaxy_TryAwardDepositPrize }
procedure TGalaxy.TryAwardDepositPrize;
var Deposit, Chance, Roll: Integer;
  Station: TRuins;
  Item: TItem;
  Text: WideString;
begin
  if (GetPlayer.DepositAmount <> 0) and (GetPlayer.DepositDayCount <> 0) and (GetPlayer.DepositDayCount mod TurnsPerYear = 0) then begin
    Station := TObject(FindStationByTypeAndIndex(SeededRandomIntRange(1, ShipTypeCounts[Ord(rstBusinessCenter)],
      Galaxy.GenerationSeed + Galaxy.CurrentTurn div 33), rstBusinessCenter)) as TRuins;
    if Station <> nil then begin
      Text := PickLocalizedTextVariant('GalaxyNews.BK.DepositPrizeLose', Station.Seed * (Galaxy.CurrentTurn div 10));
      Chance := 30 + (GetPlayer.DepositDayCount div TurnsPerYear) * 10;
      Roll := SeededRandomIntRange(1, 100, Station.Seed + Galaxy.CurrentTurn div 7);
      if Roll < Chance then begin
        Deposit := GetPlayer.ComputeDepositAccruedValue;
        Item := Station.FindMostExpensiveShopItem(Round(Deposit * 0.1), Round(Deposit * 1.0));
        if Item <> nil then begin
          Station.EquipmentShop.Delete(Station.EquipmentShop.IndexOf(Item));
          GetPlayer.AddItemToPlayerStorage(Item, Station, -1);
          GetPlayer.RefreshStorageBubbles;
          Text := PickLocalizedTextVariant('GalaxyNews.BK.DepositPrizeWin', Station.Seed * (Galaxy.CurrentTurn div 10));
          ReplaceTextToken(Text, '<Item>', Item.GetDisplayName, '<color=255,240,100>');
        end;
      end;
      ReplaceTextToken(Text, '<BKName>', Station.GetFullName(' '), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Star>', Station.CurrentStar.Name, '<color=255,240,100>');
      AddOrUpdatePlayerBubble(pmGalaxyNews, CurrentTurn, Text, '');
    end;
  end;
end;
{ @end $7BE89C }

{ @routine $7BEC1C TGalaxy_ProcessBankDebtAndDeposits }
procedure TGalaxy.ProcessBankDebtAndDeposits;
const
  AffectedShipTypes = [htPirate];
  AffectedOwners = [oiMaloc..oiPirate];
var
  News: WideString;
  OldDebt, Penalty: Integer;
  Event: TGalaxyEvent;
begin
  if GetPlayer = nil then Exit;
  if Self.ShipTypeCounts[Ord(rstBusinessCenter)] > 0 then
  begin
    if (GetPlayer.DepositAmount > 0) and (GetPlayer.DebtAmount = 0) then
    begin
      Inc(GetPlayer.DepositDayCount);
      Self.TryAwardDepositPrize;
    end;
    if (GetPlayer.DebtAmount > 0) and (GetPlayer.DebtDueTurn <= Galaxy.CurrentTurn) then
    begin
      Inc(GetPlayer.DebtDefaultCount);
      if GetPlayer.DebtDefaultCount = 1 then TryAddAchievementProgress('CREDITOR', 1);
      OldDebt := GetPlayer.DebtAmount;
      Penalty := RoundAndTruncateToTens(Min(GetPlayer.DebtAmount * 0.5 * GetPlayer.DebtDefaultCount, GetPlayer.Wealth div 8));
      GetPlayer.DebtAmount := Min(MaxMonetaryValue, GetPlayer.DebtAmount + Penalty);
      GetPlayer.DebtDueTurn := Galaxy.CurrentTurn + System.Round(RemapClamped(SeededRandomUnitFloat(Galaxy.CurrentTurn div 80), 0, 1, 0.7, 1.5) * 300);
      if GetPlayer.DebtDefaultCount < 3 then
        News := PickLocalizedTextVariant('GalaxyNews.BK.DebtInfo', (Galaxy.CurrentTurn div 10) * Self.GenerationSeed)
      else
      begin
        News := PickLocalizedTextVariant('GalaxyNews.BK.DebtInfoContinue', (Galaxy.CurrentTurn div 10) * Self.GenerationSeed);
        GetPlayer.ChangeGlobalRelations(nil, rcmDecrease, 50, AffectedShipTypes, AffectedOwners);
      end;
      ReplaceTextToken(News, '<OldMoney>', WideString(SysUtils.IntToStr(OldDebt)), '<color=255,240,100>');
      ReplaceTextToken(News, '<Penalty>', WideString(SysUtils.IntToStr(Penalty)), '<color=255,240,100>');
      ReplaceTextToken(News, '<NewMoney>', WideString(SysUtils.IntToStr(GetPlayer.DebtAmount)), '<color=255,240,100>');
      ReplaceTextToken(News, '<NewDate>', Galaxy.FormatTurnDate(GetPlayer.DebtDueTurn), '<color=255,240,100>');
      AddOrUpdatePlayerBubble(pmGalaxyNews, Self.CurrentTurn, News, '');
    end;
  end
  else if (GetPlayer.DebtAmount > 0) or (GetPlayer.DepositAmount > 0) then
  begin
    News := PickLocalizedTextVariant('GalaxyNews.BK.DeadAllBKStart', (Galaxy.CurrentTurn div 10) * Self.GenerationSeed);
    if GetPlayer.DebtAmount > 0 then
    begin
      News := News + #13#10 + FormatText1(PickLocalizedTextVariant('GalaxyNews.BK.DeadAllBKDebt', (Galaxy.CurrentTurn div 10) * Self.GenerationSeed), '<color=255,240,100>', '<Money>', WideString(SysUtils.IntToStr(GetPlayer.DebtAmount)));
      Event := AddGalaxyEvent('PlayerDebtNullified');
      Event.AddData(GetPlayer.DebtAmount);
    end;
    GetPlayer.DebtAmount := 0;
    GetPlayer.DebtDueTurn := 0;
    GetPlayer.DebtDefaultCount := 0;
    if GetPlayer.DepositAmount > 0 then
      News := News + #13#10 + FormatText1(PickLocalizedTextVariant('GalaxyNews.BK.DeadAllBKDeposit', (Galaxy.CurrentTurn div 10) * Self.GenerationSeed), '<color=255,240,100>', '<Money>', WideString(SysUtils.IntToStr(GetPlayer.DepositAmount)));
    GetPlayer.DepositAmount := 0;
    GetPlayer.DepositStartTurn := 0;
    GetPlayer.DepositDayCount := 0;
    GetPlayer.DepositInterestRate := 0;
    AddOrUpdatePlayerBubble(pmGalaxyNews, Self.CurrentTurn, News, '');
  end;
end;
{ @end $7BEC1C }

{ @routine $7BF428 TGalaxy_ProcessRangerCenterNewYearEvent }
procedure TGalaxy.ProcessRangerCenterNewYearEvent;
var Year, Month, Day: Word;
  Text: WideString;
  Station: TRuins;
  Item: TMicroModule;
  Minimum, Maximum: Integer;
  Event: TGalaxyEvent;
begin
  if GetPlayer <> nil then
    if ShipTypeCounts[Ord(rstRangerCenter)] > 0 then begin
      if Galaxy.CurrentTurn > GalaxyWarmupTurns then begin
        DecodeDate(GameTurnToDateTime(Galaxy.CurrentTurn - GalaxyWarmupTurns), Year, Month, Day);
        if (Day = 31) and (Month = 12) then begin
          Station := TObject(FindStationByTypeAndIndex(SeededRandomIntRange(1, ShipTypeCounts[Ord(rstRangerCenter)],
            Galaxy.GenerationSeed + Galaxy.CurrentTurn), rstRangerCenter)) as TRuins;
          if Station <> nil then begin
            Item := TMicroModule.Create;
            Minimum := 70;
            Dec(Minimum, Round(RemapClamped(Year, 3301, 3311, 0, 10)));
            Dec(Minimum, Round(RemapClamped(GetPlayer.PlaceInRating, 1, Galaxy.Rangers.Count, 10, 0)));
            Dec(Minimum, Round(RemapClamped(ShortInt(Ord(GetPlayer.Rank)), 0, 7, 0, 10)));
            Dec(Minimum, Galaxy.ScaleIntByTechLevel(0, 20));
            Inc(Minimum, SeededRandomIntRange(-10, 10, Galaxy.GenerationSeed + Station.Seed));
            Minimum := Max(1, Min(Minimum, 100));
            Maximum := 100;
            Item.Init(SelectMicroModule(Minimum, Maximum, Galaxy.GenerationSeed + Station.Seed + Galaxy.CurrentTurn, Station));
            Item.OwnerId := RaceToOwner(GetPlayer.PilotRace);
            Event := AddGalaxyEvent('PlayerReceivesMMOnNewYear');
            Event.AddData(Item.Id);
            Event.AddData(Item.MicroModuleIndex - 1);
            GetPlayer.AddItemToPlayerStorage(Item, Station, -1);
            GetPlayer.RefreshStorageBubbles;
            Text := PickLocalizedTextVariant('GalaxyNews.RC.NewYear', GenerationSeed * (Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<RCName>', Station.GetFullName(' '), '<color=255,240,100>');
            ReplaceTextToken(Text, '<Star>', Station.CurrentStar.Name, '<color=255,240,100>');
            ReplaceTextToken(Text, '<Year>', IntToStr(Year + 1), '<color=255,240,100>');
            ReplaceTextToken(Text, '<Item>', Item.GetDisplayName, '<color=255,240,100>');
            AddOrUpdatePlayerBubble(pmGalaxyNews, CurrentTurn, Text, '');
          end;
        end;
      end;
    end else if GetPlayer.BaseNodes > 0 then begin
      Text := FormatText1(PickLocalizedTextVariant('GalaxyNews.RC.DeadBaseNod', GenerationSeed * (Galaxy.CurrentTurn div 10)),
        '<color=255,240,100>', '<Nod>', IntToStr(GetPlayer.BaseNodes));
      Event := AddGalaxyEvent('PlayerNodesNullified');
      Event.AddData(GetPlayer.BaseNodes);
      GetPlayer.BaseNodes := 0;
      AddOrUpdatePlayerBubble(pmGalaxyNews, CurrentTurn, Text, '');
    end;
end;
{ @end $7BF428 }

{ @routine $7BFA1C TGalaxy_TryCreateLiberationGroup }
function TGalaxy.TryCreateLiberationGroup: Boolean;
var
  i, Index, j, k, ShipCount: Integer;
  Star: TStar;
  Ship: TShip;
  Planet: TPlanet;
  Group: TGroup;
  Constellation: TConstellation;
  GroupStrength, EnemyStrength: Double;
  HasSubtypeOne: Boolean;
  EmergencyControlPercent: Byte;
begin
  Result := False;
  EmergencyControlPercent := 5;
  if (Galaxy.GetFactionControlPercent(sfCoalition) > 90) and
    (NextRandomUnitFloat(Self.RandomState) < 0.5) and (Galaxy.WarDeltaWin[0] > 3) then Exit;
  if (Galaxy.WarDeltaWin[0] > 5) and (NextRandomUnitFloat(Self.RandomState) < 0.8) then Exit;
  Constellation := nil;
  Index := NextRandomIntRange(0, Self.Constellations.Count - 1, Self.RandomState);
  for i := 0 to Self.Constellations.Count - 1 do
  begin
    IncrementWrapped(Index, 0, Self.Constellations.Count - 1);
    Constellation := TConstellation(Self.Constellations[Index]);
    if not Constellation.HasDominatorPresence and
      not Constellation.HasPirateClanPresence then Break;
  end;
  Group := TGroup.Create;
  Self.LiberationGroups.Add(Group);
  if Group.SelectLiberationTarget then
  begin
    EnemyStrength := 0;
    for i := 0 to Group.TargetStar.Ships.Count - 1 do
    begin
      Ship := TShip(Group.TargetStar.Ships[i]);
      if Ship.IsOutsideStarSpace then Continue;
      if Group.TargetStar.Status.CustomFaction <> '' then
      begin
        if Ship.CurrentStanding <> ssCustom then Continue;
      end
      else if Group.TargetStar.ControlFaction = sfDominators then
      begin
        if Ship.CurrentStanding <> ssDominator then Continue;
      end
      else if Group.TargetStar.ControlFaction = sfPirates then
      begin
        if not (Ship.CurrentStanding in [ssPirateActive..ssPirateMilitary]) then Continue;
      end;
      EnemyStrength := EnemyStrength + Ship.Strength;
    end;
    ShipCount := 0;
    GroupStrength := 0;
    HasSubtypeOne := False;
    Index := NextRandomIntRange(0, Constellation.Stars.Count - 1, Self.RandomState);
    for i := 0 to Constellation.Stars.Count - 1 do
    begin
      IncrementWrapped(Index, 0, Constellation.Stars.Count - 1);
      Star := TStar(Constellation.Stars[Index]);
      if (Star.ControlFaction = sfCoalition) and (Star.Battle = 0) and (Star.Status.CustomFaction = '') and
        (not Star.HasLiberationGroupOrder or
          (Galaxy.GetFactionControlPercent(sfCoalition) <= EmergencyControlPercent)) then
      begin
        for j := 0 to Star.Planets.Count - 1 do
        begin
          Planet := TPlanet(Star.Planets[j]);
          if Planet.IsCoalitionOwned then
            for k := NextRandomIntRange(0, 1, Planet.RandomState) to Planet.Warriors.Count - 1 do
            begin
              Ship := TShip(Planet.Warriors[k]);
              if (Ship.ScriptShip = nil) and (Ship.CurrentPlanet = Planet) and
                (Star.Ships.IndexOf(Ship) < 0) and (Ship.LiberationGroup = nil) then
              begin
                Ship.LiberationGroup := Group;
                Star.Ships.Add(Ship);
                Group.AddShip(Ship);
                Inc(ShipCount);
                if TWarrior(Ship).WarriorType = wtFlagship then
                begin
                  GroupStrength := 0.5 * Ship.Strength + GroupStrength;
                  if not HasSubtypeOne then EnemyStrength := 1.2 * EnemyStrength;
                  HasSubtypeOne := True;
                end
                else GroupStrength := GroupStrength + Ship.Strength;
                if (ShipCount >= 5) and ((GroupStrength >= EnemyStrength) or (ShipCount >= 30)) then
                begin
                  Result := Group.BuildLiberationOrders;
                  Exit;
                end;
              end;
            end;
        end;
      end;
    end;
    if (GroupStrength <= EnemyStrength) and (ShipCount < 30) then
      for i := 0 to Constellation.Stars.Count - 1 do
      begin
        IncrementWrapped(Index, 0, Constellation.Stars.Count - 1);
        Star := TStar(Constellation.Stars[Index]);
        if (Star.ControlFaction = sfCoalition) and (Star.Battle = 0) and (Star.Status.CustomFaction = '') and
          (not Star.HasLiberationGroupOrder or
            (Galaxy.GetFactionControlPercent(sfCoalition) <= EmergencyControlPercent)) then
        begin
          for j := 0 to Star.Ships.Count - 1 do
          begin
            Ship := TShip(Star.Ships[j]);
            if (Ship.TypeId = stWarrior) and (Ship.HomePlanet.CurrentStar = Star) and
              not Ship.IsOutsideStarSpace and (Ship.ScriptShip = nil) and
              (Ship.Order in [soNone, soMove]) and (Ship.AbsoluteScriptOrder = 0) and (Ship.LiberationGroup = nil) then
            begin
              Ship.LiberationGroup := Group;
              Group.AddShip(Ship);
              Inc(ShipCount);
              if TWarrior(Ship).WarriorType = wtFlagship then
              begin
                GroupStrength := 0.5 * Ship.Strength + GroupStrength;
                if not HasSubtypeOne then EnemyStrength := 1.2 * EnemyStrength;
                HasSubtypeOne := True;
              end
              else GroupStrength := GroupStrength + Ship.Strength;
            end;
          end;
        end;
      end;
    if (ShipCount >= 1) and (Galaxy.GetFactionControlPercent(sfCoalition) <= EmergencyControlPercent) then
    begin
      if GetPlayer <> nil then GroupStrength := GetPlayer.Strength * 2 + GroupStrength;
      if (10 * GroupStrength >= NextRandomIntRange(3, 10, Self.RandomState) * EnemyStrength) or
        (NextRandomIntRange(0, 700, Self.RandomState) = 0) then
      begin
        Result := Group.BuildLiberationOrders;
        Exit;
      end;
      Group.Disband;
    end
    else
    begin
      if ShipCount >= 5 then
      begin
        Result := Group.BuildLiberationOrders;
        Exit;
      end;
      Group.Disband;
    end;
  end;
  Result := False;
end;
{ @end $7BFA1C }

{ @routine $7C00DC TGalaxy_TryDispatchMilitaryBaseToEnemyStar }
function TGalaxy.TryDispatchMilitaryBaseToEnemyStar: Boolean;
var I, J, Count: Integer;
  Star, Target: TStar;
  Ship: TShip;
  Station: TRuins;
  Planet: TPlanet;
  Warrior: TWarrior;
  Text: WideString;
  Turn: Integer;
begin
  Result := False;
  if (FindMilitaryBaseInTransit <> nil) or (CurrentTurn < GalaxyWarmupTurns) or (CurrentTurn mod 133 <> 0) then Exit;
  if SeededRandomUnitFloat(GenerationSeed * CurrentTurn + CountStarsInBattle) < 0.5 then Exit;
  Station := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := TStar(Galaxy.Stars[I]);
    if (Star.ShipTypeCounts[Ord(rstMilitaryBase)] <> 0) and (not Star.Constellation.HasDominatorPresence) and
      (SeededRandomUnitFloat((GenerationSeed + I) * CurrentTurn * Star.GenerationSeed) >= 0.2) then begin
      for J := 0 to Star.Ships.Count - 1 do begin
        Ship := TShip(Star.Ships[J]);
        if Ship.TypeId = Byte(rstMilitaryBase) then begin
          Station := Ship as TRuins;
          if Station.FlyToStar <> nil then Station := nil
          else if Station.HasScriptControl then Station := nil;
        end;
        if Station <> nil then Break;
      end;
      if Station <> nil then Break;
    end;
  end;
  if Station = nil then Exit;
  Count := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do Inc(Count, TStar(Galaxy.Stars[I]).ShipTypeCounts[Ord(rstMilitaryBase)]);
  if Count < 2 then Exit;
  Target := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := TStar(Galaxy.Stars[I]);
    if Star.IsConstellationVisible and (Star.Constellation.Id <> 20) and
      (Star.Constellation.ShipTypeCounts[Ord(rstMilitaryBase)] <= 0) and (Star.ControlFaction = sfDominators) and
      (Star.Ships.Count <= Star.ShipTypeCounts[stKling]) and (Star.ShipTypeCounts[stKling] >= 5) and
      (not HasMilitaryBaseAssignedToStar(Star)) and (not HasLiberationGroupTargetingStar(Star)) and
      (SeededRandomUnitFloat((GenerationSeed + I) * CurrentTurn * Star.GenerationSeed) >= 0.7) and
      (PointDistance(Station.CurrentStar.Position, Star.Position) >= ScaleIntByTechLevel(30, 60)) then begin
      Target := Star;
      Break;
    end;
  end;
  if Target = nil then Exit;
  Planet := TObject(Station.CurrentStar.FindFastestResearchPlanet) as TPlanet;
  if not Planet.IsCoalitionOwned then Exit;
  for I := 1 to SeededRandomIntRange(4, 6, CurrentTurn * Planet.GenerationSeed) do begin
    if (I = 1) and (Galaxy.RangerSpawnQuotas[Planet.RaceId] > 0) then Warrior := TObject(Planet.BuyFlagship(200)) as TWarrior
    else Warrior := TObject(Planet.BuyWarrior(200)) as TWarrior;
    Warrior.Position := Station.Position;
    Warrior.CurrentPlanet := nil;
    Warrior.DockedTo := Station;
    Planet.CurrentStar.Ships.Add(Warrior);
  end;
  Turn := CurrentTurn + SeededRandomIntRange(30, 40, CurrentTurn + Planet.GenerationSeed);
  Station.FlyToStar := Target;
  Station.FlyDate := Turn;
  Text := PickLocalizedTextVariant('GalaxyNews.WBGoToEnemyStar.Create', GenerationSeed * (Galaxy.CurrentTurn div 10));
  ReplaceTextToken(Text, '<WB>', Station.Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<WBStar>', Station.CurrentStar.Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<StarEnemy>', Target.Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<WBSector>', Station.CurrentStar.Constellation.GetName, '<color=255,240,100>');
  ReplaceTextToken(Text, '<SectorEnemy>', Target.Constellation.GetName, '<color=255,240,100>');
  ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Turn), '<color=255,240,100>');
  Galaxy.AddPlanetNewsWithPlayerBubble(45, Text);
  Result := True;
end;
{ @end $7C00DC }

{ @routine $7C077C TGalaxy_FindMilitaryBaseInTransit }
function TGalaxy.FindMilitaryBaseInTransit: Pointer;
var I, J: Integer; Star: TStar; Ship: TShip;
begin
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := TShip(Star.Ships[J]);
      if (Ship.TypeId = Byte(rstMilitaryBase)) and ((Ship as TRuins).FlyToStar <> nil) and
        (not Ship.InNormalSpace or ((Ship as TRuins).FlyToStar <> Ship.CurrentStar)) then begin
        Result := Ship;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;
{ @end $7C077C }

{ @routine $7C0854 TGalaxy_HasMilitaryBaseAssignedToStar }
function TGalaxy.HasMilitaryBaseAssignedToStar(Star: TStar): Boolean;
var I, J: Integer; SystemStar: TStar; Ship: TShip;
begin
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    SystemStar := TStar(Galaxy.Stars[I]);
    for J := 0 to SystemStar.Ships.Count - 1 do begin
      Ship := TShip(SystemStar.Ships[J]);
      if (Ship.TypeId = Byte(rstMilitaryBase)) and ((Ship as TRuins).FlyToStar = (TObject(Star) as TStar)) then begin Result := True; Exit; end;
    end;
  end;
  Result := False;
end;
{ @end $7C0854 }

{ @routine $7C0914 TGalaxy_HasLiberationGroupTargetingStar }
function TGalaxy.HasLiberationGroupTargetingStar(Star: TStar): Boolean;
var I: Integer; Group: TGroup;
begin
  for I := LiberationGroups.Count - 1 downto 0 do begin
    Group := LiberationGroups[I];
    if (Group.Route[3].Target as TStar) = Star then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7C0914 }

{ @routine $7C097C TGalaxy_AssignSpecialStationService }
procedure TGalaxy.AssignSpecialStationService;
var
  i, StarCount, j, ShipCount: Integer;
  Star: TStar;
  Ship: TShip;
  Station: TRuins;
  PirateActive, PirateCandidate: TRuins;
  ScienceActive, ScienceCandidate: TRuins;
  MilitaryActive, MilitaryCandidate: TRuins;
  Count: Integer;
  Seed: Cardinal;
  Candidates: array[0..2] of TRuins;
begin
  if Self.CurrentTurn and 15 <> 0 then Exit;
  if Self.NextSpecialStationServiceTurn = 0 then
    Self.NextSpecialStationServiceTurn := SeededRandomIntRange(0, TurnsPerYear, GetPlayer.Id xor Self.GenerationSeed) + 2125;
  if Self.CurrentTurn < Self.NextSpecialStationServiceTurn then Exit;
  Seed := GetPlayer.Id xor Self.GenerationSeed xor Galaxy.CurrentTurn;
  Self.NextSpecialStationServiceTurn := NextRandomIntRange(0, TurnsPerYear, Seed) + (Self.NextSpecialStationServiceTurn + TurnsPerYear);
  PirateActive := nil;
  PirateCandidate := nil;
  ScienceActive := nil;
  ScienceCandidate := nil;
  MilitaryActive := nil;
  MilitaryCandidate := nil;
  StarCount := Self.Stars.Count;
  for i := 0 to StarCount - 1 do
  begin
    Star := TStar(Self.Stars[i]);
    ShipCount := Star.Ships.Count;
    for j := 0 to ShipCount - 1 do
    begin
      Ship := TShip(Star.Ships[j]);
      if Ship.TypeId = Byte(rstPirateBase) then
      begin
        Station := Ship as TRuins;
        if Station.SpecialServiceActive then
          PirateActive := Station
        else if (Station.TypeNameOverrideKey = '') and (Station.ScriptShip = nil) and
          TShip(Station).InNormalSpace and
          ((PirateCandidate = nil) or (NextRandomIntRange(0, 100, Seed) < 50)) then
          PirateCandidate := Station;
      end
      else if Ship.TypeId = Byte(rstScienceBase) then
      begin
        Station := Ship as TRuins;
        if Station.SpecialServiceActive then
          ScienceActive := Station
        else if (Station.TypeNameOverrideKey = '') and (Station.ScriptShip = nil) and
          TShip(Station).InNormalSpace and
          ((ScienceCandidate = nil) or (NextRandomIntRange(0, 100, Seed) < 50)) then
          ScienceCandidate := Station;
      end
      else if Ship.TypeId = Byte(rstMilitaryBase) then
      begin
        Station := Ship as TRuins;
        if Station.SpecialServiceActive then
          MilitaryActive := Station
        else if (Station.TypeNameOverrideKey = '') and (Station.ScriptShip = nil) and
          TShip(Station).InNormalSpace and
          ((MilitaryCandidate = nil) or (NextRandomIntRange(0, 100, Seed) < 50)) then
          MilitaryCandidate := Station;
      end;
    end;
  end;
  Count := 0;
  if (PirateActive = nil) and (PirateCandidate <> nil) then
  begin
    Candidates[Count] := PirateCandidate;
    Inc(Count);
  end;
  if (ScienceActive = nil) and (ScienceCandidate <> nil) then
  begin
    Candidates[Count] := ScienceCandidate;
    Inc(Count);
  end;
  if (MilitaryActive = nil) and (MilitaryCandidate <> nil) then
  begin
    Candidates[Count] := MilitaryCandidate;
    Inc(Count);
  end;
  if Count > 0 then
  begin
    Station := Candidates[NextRandomIntRange(0, Count * 100 - 1, Seed) div 100];
    Station.SpecialServiceActive := True;
    Self.AddPlanetNewsWithPlayerBubble(44, FormatText3(PickLocalizedTextVariant('FormRuins.' + Station.GetTypeNameKey + '.SpecialShip.News', (Galaxy.CurrentTurn div 10) * Self.GenerationSeed), '<color=255,240,100>', '<Name>', Station.GetName, '<Star>', Station.CurrentStar.Name, '<Sector>', TConstellation(Station.CurrentStar.Constellation).GetName));
  end;
end;
{ @end $7C097C }

{ @routine $7C0E6C TGalaxy_ApplyWingmanLeadershipPenalty }
procedure TGalaxy.ApplyWingmanLeadershipPenalty;
var I, Excess: Integer; Leader, Ship: TShip;
begin
  if WingmenPendingLeadershipPenalty <> nil then
    while WingmenPendingLeadershipPenalty.Count > 0 do begin
      Leader := TShip(WingmenPendingLeadershipPenalty[WingmenPendingLeadershipPenalty.Count - 1]).PartnerShip;
      if Leader = nil then WingmenPendingLeadershipPenalty.Delete(WingmenPendingLeadershipPenalty.Count - 1)
      else begin
        Excess := 0;
        for I := WingmenPendingLeadershipPenalty.Count - 1 downto 0 do
          if TShip(WingmenPendingLeadershipPenalty[I]).PartnerShip = Leader then Inc(Excess);
        Excess := Excess - Leader.GetEffectiveSkillLevel(psLeadership);
        for I := WingmenPendingLeadershipPenalty.Count - 1 downto 0 do
          if TShip(WingmenPendingLeadershipPenalty[I]).PartnerShip = Leader then begin
            if Excess > 0 then begin
              Ship := WingmenPendingLeadershipPenalty[I];
              if Ship.PartnershipDaysRemaining > 0 then
                Ship.PartnershipDaysRemaining := Max(1, Ship.PartnershipDaysRemaining - (Excess + 1) div 2);
            end;
            WingmenPendingLeadershipPenalty.Delete(I);
          end;
      end;
    end;
end;
{ @end $7C0E6C }

{ @routine $7C0FD0 TGalaxy_ProcessCoalitionDefeat }
procedure TGalaxy.ProcessCoalitionDefeat;
var I, J: Integer; Ship: TShip; Star: TStar; Text: WideString; Bubble: TMessagePlayer; Contested: Boolean; CoalitionStrength, PirateStrength: Single;
begin
  if (GetPlayer <> nil) and (CountFactionStars(sfCoalition) <= 0) and (GetPlayer.OwnerId = oiPirate) and
    (PirateWinType <> 3) and (CoalitionDefeatedTurn = 0) and
    ((MainPiratePlanet = nil) or (GetPlayer.CurrentStar <> MainPiratePlanet.CurrentStar)) then begin
    for I := 0 to Galaxy.Stars.Count - 1 do begin
      Star := TStar(Galaxy.Stars[I]);
      Contested := False;
      for J := 0 to Star.Ships.Count - 1 do begin
        Ship := TShip(Star.Ships[J]);
        if Ship.CurrentStanding = ssCoalitionMilitary then Exit;
        if not ((Ship.OwnerId in PlanetOwnerMasks.Coalition) and (Ship is TNormalShip) and (Ship.OwnerId <> oiPirate)) then Continue;
        if (Star.ControlFaction = sfDominators) or (Star.Status.CustomFaction <> '') then Exit;
        if Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive] then begin Contested := True; Break; end;
      end;
      if Contested then begin
        CoalitionStrength := 0;
        PirateStrength := 0;
        for J := 0 to Star.Ships.Count - 1 do begin
          Ship := TShip(Star.Ships[J]);
          if Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive] then CoalitionStrength := CoalitionStrength + Ship.Strength;
          if Ship.CurrentStanding in [ssPirateActive, ssPirateMilitary] then PirateStrength := PirateStrength + Ship.Strength;
        end;
        if 3 * CoalitionStrength > PirateStrength then Exit;
      end;
    end;
    Bubble := FindPlayerBubbleByKey('BlazerWin', False);
    if (Bubble <> nil) and (Bubble.Kind = 3) then begin Bubble.Kind := 4; Bubble.WasRead := False; end;
    Bubble := FindPlayerBubbleByKey('TerronWin', False);
    if (Bubble <> nil) and (Bubble.Kind = 3) then begin Bubble.Kind := 4; Bubble.WasRead := False; end;
    Bubble := FindPlayerBubbleByKey('KellerWin', False);
    if (Bubble <> nil) and (Bubble.Kind = 3) then begin Bubble.Kind := 4; Bubble.WasRead := False; end;
    EminentCareerShips[rcTrader] := nil;
    EminentCareerShips[rcPirate] := nil;
    EminentCareerShips[rcWarrior] := nil;
    CoalitionDefeatedTurn := CurrentTurn;
    Galaxy.PirateWinTurn := Galaxy.CurrentTurn;
    Galaxy.PirateWinType := 5;
    TryUnlockAchievement('PIRATEWIN');
    Text := PickLocalizedTextVariant('GalaxyNews.Globals.CoalitionDefeated', Galaxy.CurrentTurn div 23);
    AddOrUpdatePlayerBubble(pmGalaxyNews, CurrentTurn, Text, '').NotificationSoundKind := 1;
    AddPlanetNews(35, Text);
  end;
end;
{ @end $7C0FD0 }

{ @routine $7C13E0 TGalaxy_ComputeRangerSpawnQuotas }
procedure TGalaxy.ComputeRangerSpawnQuotas;
var Race: TOwnerId;
  Ratio, I, J, K: Integer;
  Star: TStar;
  Planet: TPlanet;
  Warrior: TWarrior;
  Total, Extra: Integer;
  Order: array[0..4] of TOwnerId;
  Counts, Recruits: array[oiMaloc..oiGaal] of Integer;
  Reserved: Integer;
  Sorted: array[0..4] of Integer;
begin
  for Race := oiMaloc to oiGaal do begin
    Counts[Race] := 0;
    Recruits[Race] := 0;
    RangerSpawnQuotas[Race] := 0;
    Order[Ord(Race)] := Race;
  end;
  Ratio := Round(18 / (CustomRules.CoalitionAggression * 0.0625 + 0.5));
  for I := 0 to Stars.Count - 1 do begin
    Star := TStar(Stars[I]);
    for J := 0 to Star.Planets.Count - 1 do begin
      Planet := TPlanet(Star.Planets[J]);
      for K := 0 to Planet.Warriors.Count - 1 do begin
        Warrior := TWarrior(Planet.Warriors[K]);
        if Warrior.TypeNameOverrideKey = '' then
          if Warrior.WarriorType = wtFlagship then Inc(Recruits[Warrior.PilotRace])
          else Inc(Counts[Warrior.PilotRace]);
      end;
    end;
  end;
  Total := 0;
  for Race := oiMaloc to oiGaal do Inc(Total, Counts[Race]);
  if Total < 3 then Exit;
  for Race := oiMaloc to oiGaal do begin
    I := Counts[Race] div Ratio;
    RangerSpawnQuotas[Race] := I - Recruits[Race];
    Dec(Counts[Race], I * Ratio);
    Dec(Total, I * Ratio);
  end;
  Extra := Total div Ratio;
  if Total - Extra * Ratio >= 3 then Inc(Extra);
  for Race := oiMaloc to oiGaal do Sorted[Ord(Race)] := Counts[Race];
  for I := 0 to 3 do
    for J := I + 1 to 4 do
      if Sorted[I] < Sorted[J] then begin
        Race := Order[I];
        K := Sorted[I];
        Order[I] := Order[J];
        Sorted[I] := Sorted[J];
        Order[J] := Race;
        Sorted[J] := K;
      end;
  for I := 0 to Min(Extra - 0 - 1, 4) do Inc(RangerSpawnQuotas[Order[I]]);
end;
{ @end $7C13E0 }

{ @routine $7C16E0 TGalaxy_PruneExpiredGalaxyEvents }
procedure TGalaxy.PruneExpiredGalaxyEvents;
begin
  while (GalaxyEvents.Count > 0) and (CurrentTurn - TGalaxyEvent(GalaxyEvents[0]).Turn > 1825) do begin
    TObject(GalaxyEvents[0]).Free;
    GalaxyEvents.Delete(0);
  end;
end;
{ @end $7C16E0 }

{ @routine $7C1744 TGalaxy_GetCoalitionToPirateSystemRatio }
function TGalaxy.GetCoalitionToPirateSystemRatio: Single;
begin
  Result := Galaxy.CountFactionStars(sfCoalition) / Max(1, Galaxy.CountFactionStars(sfPirates) - 1);
end;
{ @end $7C1744 }

{ @routine $7C1794 TGalaxy_GetEffectiveDifficultyLevel }
function TGalaxy.GetEffectiveDifficultyLevel: Integer;
var I: Byte;
begin
  Result := 0;
  if CustomRules.Enabled then Result := CustomRules.DominatorStrength
  else
    for I := 0 to 7 do Inc(Result, Galaxy.DifficultyLevels[I]);
end;
{ @end $7C1794 }

{ @routine $7C17E4 TGalaxy_GetDifficultyTierIndex }
function TGalaxy.GetDifficultyTierIndex: TDifficultyTier;
var Level, Bound, Tier, Step: Integer;
begin
  Level := GetEffectiveDifficultyLevel;
  Bound := 6;
  Tier := 0;
  Step := 8;
  while Level >= Bound do
  begin
    Inc(Bound, Step);
    Inc(Tier);
  end;
  Result := Min(Tier, 9);
end;
{ @end $7C17E4 }

{ @routine $7C1848 TGalaxy_InterpolateDifficulty }
function TGalaxy.InterpolateDifficulty(Level: Integer; AtZero, AtEight, AtSixteen, AtTwentyFour: Single): Single;
var EffectiveLevel: Integer;
begin
  if Level < 0 then EffectiveLevel := GetEffectiveDifficultyLevel else EffectiveLevel := Level;
  if EffectiveLevel <= 0 then Result := AtZero
  else if EffectiveLevel <= 8 then Result := RemapClamped(EffectiveLevel, 0, 8, AtZero, AtEight)
  else if EffectiveLevel <= 16 then Result := RemapClamped(EffectiveLevel, 8, 16, AtEight, AtSixteen)
  else if EffectiveLevel <= 24 then Result := RemapClamped(EffectiveLevel, 16, 24, AtSixteen, AtTwentyFour)
  else Result := AtTwentyFour + (AtTwentyFour - AtSixteen) * (EffectiveLevel - 24) / 8;
end;
{ @end $7C1848 }

{ @routine $7C1964 TGalaxy_ScaleDifficultyExponentially }
function TGalaxy.ScaleDifficultyExponentially(Level: Integer; BaseValue, FactorPerEightLevels: Single): Single;
var EffectiveLevel: Integer;
begin
  if Level < 0 then EffectiveLevel := GetEffectiveDifficultyLevel else EffectiveLevel := Level;
  Result := BaseValue * Exp(Ln(FactorPerEightLevels) * EffectiveLevel * 0.125);
end;
{ @end $7C1964 }

{ @routine $7C19C4 TGalaxy_GetDominatorBossHullScale }
function TGalaxy.GetDominatorBossHullScale: Single;
begin
  Result := InterpolateDifficulty(-1, 0.8, 1, 1.2, 1.5);
end;
{ @end $7C19C4 }

{ @routine $7C19F8 TGalaxy_GetDominatorKillExperienceScale }
function TGalaxy.GetDominatorKillExperienceScale: Single;
begin
  Result := GetEffectiveDifficultyLevel * 0.3 / 24 + 0.9;
end;
{ @end $7C19F8 }

{ @routine $7C1A4C TGalaxy_GetTurnsBetweenLiberationGroups }
function TGalaxy.GetTurnsBetweenLiberationGroups: Integer;
begin
  if CustomRules.Enabled then Result := Round(InterpolateDifficulty(-1, 25, 30, 50, 80) / (0.5 + CustomRules.CoalitionAggression * 0.0625))
  else Result := Round(InterpolateDifficulty(-1, 25, 30, 50, 80));
end;
{ @end $7C1A4C }

{ @routine $7C1AE0 TGalaxy_GetInitialDominatorControlPercent }
function TGalaxy.GetInitialDominatorControlPercent: Integer;
var Level: Integer;
begin
  Level := GetEffectiveDifficultyLevel;
  Result := 45 + Round(Level * 1.25);
end;
{ @end $7C1AE0 }

{ @routine $7C1B14 TGalaxy_GetDominatorAggressionLevel }
function TGalaxy.GetDominatorAggressionLevel: Integer;
begin
  if CustomRules.Enabled then Result := CustomRules.DominatorAggression else Result := GetEffectiveDifficultyLevel;
end;
{ @end $7C1B14 }

{ @routine $7C1B4C TGalaxy_GetDominatorSpawnLevel }
function TGalaxy.GetDominatorSpawnLevel: Integer;
begin
  if CustomRules.Enabled then Result := CustomRules.DominatorSpawn else Result := GetEffectiveDifficultyLevel;
end;
{ @end $7C1B4C }

{ @routine $7C1B84 TGalaxy_GetPirateAggressionLevel }
function TGalaxy.GetPirateAggressionLevel: Integer;
begin
  if CustomRules.Enabled then Result := CustomRules.PirateAggression else Result := 8 * Galaxy.DifficultyLevels[0];
end;
{ @end $7C1B84 }

{ @routine $7C1BC0 TGalaxy_IsChaoticRandomEnabled }
function TGalaxy.IsChaoticRandomEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.ChaoticRandom;
end;
{ @end $7C1BC0 }

{ @routine $7C1BF4 TGalaxy_AreStationsNearStarsEnabled }
function TGalaxy.AreStationsNearStarsEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.StationsNearStars;
end;
{ @end $7C1BF4 }

{ @routine $7C1C28 TGalaxy_IsFullStationTargetingEnabled }
function TGalaxy.IsFullStationTargetingEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.FullStationTargeting;
end;
{ @end $7C1C28 }

{ @routine $7C1C5C TGalaxy_IsEquipmentKnowledgeUnrestricted }
function TGalaxy.IsEquipmentKnowledgeUnrestricted: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.UnrestrictedEquipmentKnowledge;
end;
{ @end $7C1C5C }

{ @routine $7C1C90 TGalaxy_GetAsteroidModifier }
function TGalaxy.GetAsteroidModifier: Single;
begin
  Result := 1;
  if CustomRules.Enabled then Result := 0.5 + CustomRules.AsteroidModifier * 0.0625;
end;
{ @end $7C1C90 }

{ @routine $7C1CDC TGalaxy_GetStarDamageDifficultyScale }
function TGalaxy.GetStarDamageDifficultyScale: Single;
begin
  Result := 1;
  if Galaxy.CustomRules.Enabled then Result := CustomRules.SunDamageModifier * 0.0625 + 0.5;
end;
{ @end $7C1CDC }

{ @routine $7C1D2C TGalaxy_AreSpecialShipsEnabled }
function TGalaxy.AreSpecialShipsEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.SpecialShips;
end;
{ @end $7C1D2C }

{ @routine $7C1D60 TGalaxy_GetMicroModuleOfferRollThresholdPercent }
function TGalaxy.GetMicroModuleOfferRollThresholdPercent: Single;
begin
  Result := 30;
  if CustomRules.Enabled then Result := CustomRules.AcrynModifier;
end;
{ @end $7C1D60 }

{ @routine $7C1D98 TGalaxy_GetNodeDropModifier }
function TGalaxy.GetNodeDropModifier: Single;
begin
  Result := 1;
  if CustomRules.Enabled then Result := 0.5 + CustomRules.NodeDropModifier * 0.0625;
end;
{ @end $7C1D98 }

{ @routine $7C1DE4 TGalaxy_GetArcadeDropValueModifier }
function TGalaxy.GetArcadeDropValueModifier: Single;
begin
  Result := 1;
  if CustomRules.Enabled then Result := 0.5 + CustomRules.ArcadeDropValueModifier * 0.0625;
end;
{ @end $7C1DE4 }

{ @routine $7C1E30 TGalaxy_GetDropValueModifier }
function TGalaxy.GetDropValueModifier: Single;
begin
  Result := 1;
  if CustomRules.Enabled then Result := CustomRules.DropValueModifier * 0.0625 + 0.5;
end;
{ @end $7C1E30 }

{ @routine $7C1E7C TGalaxy_GetAgriculturalPlanetWeight }
function TGalaxy.GetAgriculturalPlanetWeight: Integer;
begin
  Result := 1;
  if CustomRules.Enabled then
    if Integer(CustomRules.AgriculturalPlanetWeight) + CustomRules.MixedPlanetWeight + CustomRules.IndustrialPlanetWeight = 0 then Result := 1
    else Result := CustomRules.AgriculturalPlanetWeight;
end;
{ @end $7C1E7C }

{ @routine $7C1EDC TGalaxy_GetMixedPlanetWeight }
function TGalaxy.GetMixedPlanetWeight: Integer;
begin
  Result := 1;
  if CustomRules.Enabled then
    if Integer(CustomRules.AgriculturalPlanetWeight) + CustomRules.MixedPlanetWeight + CustomRules.IndustrialPlanetWeight = 0 then Result := 1
    else Result := CustomRules.MixedPlanetWeight;
end;
{ @end $7C1EDC }

{ @routine $7C1F3C TGalaxy_GetIndustrialPlanetWeight }
function TGalaxy.GetIndustrialPlanetWeight: Integer;
begin
  Result := 1;
  if CustomRules.Enabled then
    if Integer(CustomRules.AgriculturalPlanetWeight) + CustomRules.MixedPlanetWeight + CustomRules.IndustrialPlanetWeight = 0 then Result := 1
    else Result := CustomRules.IndustrialPlanetWeight;
end;
{ @end $7C1F3C }

{ @routine $7C1F9C TGalaxy_IsZeroStartingExperienceEnabled }
function TGalaxy.IsZeroStartingExperienceEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.ZeroStartingExperience;
end;
{ @end $7C1F9C }

{ @routine $7C1FD0 TGalaxy_GetExtraRangerCount }
function TGalaxy.GetExtraRangerCount: Integer;
begin
  Result := 0;
  if CustomRules.Enabled then Result := CustomRules.ExtraRangers;
end;
{ @end $7C1FD0 }

{ @routine $7C2000 TGalaxy_IsArcadeBattleRoyaleEnabled }
function TGalaxy.IsArcadeBattleRoyaleEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.ArcadeBattleRoyale;
end;
{ @end $7C2000 }

{ @routine $7C2034 TGalaxy_GetArcadeHitpointsModifier }
function TGalaxy.GetArcadeHitpointsModifier: Single;
begin
  Result := 1;
  if CustomRules.Enabled then Result := CustomRules.ArcadeHitpointsModifier * 0.0625 + 0.5;
end;
{ @end $7C2034 }

{ @routine $7C2080 TGalaxy_GetArcadeDamageModifier }
function TGalaxy.GetArcadeDamageModifier: Single;
begin
  Result := 1;
  if CustomRules.Enabled then Result := CustomRules.ArcadeDamageModifier * 0.0625 + 0.5;
end;
{ @end $7C2080 }

{ @routine $7C20CC TGalaxy_AreDominatorRacialWeaponsEnabled }
function TGalaxy.AreDominatorRacialWeaponsEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.DominatorRacialWeapons;
end;
{ @end $7C20CC }

{ @routine $7C2100 TGalaxy_GetAIJunkToleranceLevel }
function TGalaxy.GetAIJunkToleranceLevel: Integer;
begin
  Result := 7;
  if CustomRules.Enabled then Result := CustomRules.AIJunkTolerance;
end;
{ @end $7C2100 }

{ @routine $7C2130 TGalaxy_AreMaxRangeMissilesEnabled }
function TGalaxy.AreMaxRangeMissilesEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.MaxRangeMissiles;
end;
{ @end $7C2130 }

{ @routine $7C2164 TGalaxy_IsOldHyperspaceEnabled }
function TGalaxy.IsOldHyperspaceEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.OldHyperspace;
end;
{ @end $7C2164 }

{ @routine $7C2198 TGalaxy_ArePirateNodesEnabled }
function TGalaxy.ArePirateNodesEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.PirateNodes;
end;
{ @end $7C2198 }

{ @routine $7C21CC TGalaxy_IsAIShoppingEnabled }
function TGalaxy.IsAIShoppingEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.AIUseShops;
end;
{ @end $7C21CC }

{ @routine $7C2200 TGalaxy_IsStationShopUpdateEnabled }
function TGalaxy.IsStationShopUpdateEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.StationsUseShop;
end;
{ @end $7C2200 }

{ @routine $7C2234 TGalaxy_AreDuplicateArtefactsEnabled }
function TGalaxy.AreDuplicateArtefactsEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.DuplicateArtefacts;
end;
{ @end $7C2234 }

{ @routine $7C2268 TGalaxy_GetHullGrowthMod }
function TGalaxy.GetHullGrowthMod: Byte;
begin
  if CustomRules.Enabled then Result := CustomRules.HullGrowth else Result := 0;
end;
{ @end $7C2268 }

{ @routine $7C2298 TGalaxy_IsArcadeEquipmentChangeEnabled }
function TGalaxy.IsArcadeEquipmentChangeEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.ArcadeEquipmentChange;
end;
{ @end $7C2298 }

{ @routine $7C22CC TGalaxy_IsOldSpeedCalculationEnabled }
function TGalaxy.IsOldSpeedCalculationEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.OldSpeedCalculation;
end;
{ @end $7C22CC }

{ @routine $7C2300 TGalaxy_AreOldMissileBonusesEnabled }
function TGalaxy.AreOldMissileBonusesEnabled: Boolean;
begin
  Result := CustomRules.Enabled and CustomRules.OldMissileBonuses;
end;
{ @end $7C2300 }

{ @routine $7C2334 TStar_RefreshDominatorSeries }
procedure TStar.RefreshDominatorSeries;
var Blazers, Kellers, Terrons: Integer; Strength: Extended;
begin
  Blazers := CountDominatorForces(dsBlazer, False, False, Strength);
  Kellers := CountDominatorForces(dsKeller, False, False, Strength);
  Terrons := CountDominatorForces(dsTerron, False, False, Strength);
  if (BlazerShip <> nil) and BlazerShip.InNormalSpace and (BlazerShip.CurrentStar = Self) then Inc(Blazers);
  if (KellerShip <> nil) and KellerShip.InNormalSpace and (KellerShip.CurrentStar = Self) then Inc(Kellers);
  if (TerronShip <> nil) and TerronShip.InNormalSpace and (TerronShip.CurrentStar = Self) then Inc(Terrons);
  if (Blazers > 0) and (Kellers = 0) and (Terrons = 0) then DominatorSeries := dsBlazer;
  if (Blazers = 0) and (Kellers > 0) and (Terrons = 0) then DominatorSeries := dsKeller;
  if (Blazers = 0) and (Kellers = 0) and (Terrons > 0) then DominatorSeries := dsTerron;
end;
{ @end $7C2334 }

{ @routine $7C2450 TStar_RefreshDerivedStats }
procedure TStar.RefreshDerivedStats;
var I, Strength: Integer; Ship: TShip;
begin
  TrafficLevel := Round(RemapClamped(Ships.Count, 3, 13, 0, 100));
  if Ships.Count > 0 then
  begin
    Strength := 0;
    for I := 0 to Ships.Count - 1 do
    begin
      Ship := TShip(Ships[I]);
      Inc(Strength, Ship.GetStrengthScaledPirateStatus);
    end;
    ThreatLevel := Round(RemapClamped(Strength, 0, 500, 0, 100));
  end
  else ThreatLevel := 0;
  UpdateControlFaction;
  RefreshShipTypeCounts;
  RefreshDominatorSeries;
end;
{ @end $7C2450 }

{ @routine $7C25C4 TStar_GetControlPresence }
procedure TStar.GetControlPresence(out PlayerPartyPresent, CoalitionPresent,
  DominatorsPresent, PiratesPresent, CustomPresent: Boolean);
var
  Ship: TShip;
  CoalitionLeaning, NeutralPresent, PirateLeaning: Boolean;
  Index, DefenderIndex: Integer;
  Planet: TPlanet;
  CoalitionMilitaryPresent, PirateMilitaryPresent, PirateActivePresent, CoalitionActivePresent: Boolean;
  PirateKills, CoalitionKills, PirateLeaningKills, CoalitionLeaningKills: Integer;

  // @nested $7C2538 AccumulateControlPresence
  procedure AccumulateControlPresence; // @addr 0x7C2538 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4, Coalition output -8, faction flags -9..-11, other outputs +8..+16."
  begin
    case Ship.CurrentStanding of
      ssDominator: DominatorsPresent := True;
      ssCoalitionMilitary, ssCoalitionActive: CoalitionPresent := True;
      ssCoalitionPassive: CoalitionLeaning := True;
      ssNeutral: NeutralPresent := True;
      ssPiratePassive: PirateLeaning := True;
      ssPirateActive, ssPirateMilitary: PiratesPresent := True;
      ssCustom: CustomPresent := True;
    end;
  end;

begin
  CoalitionPresent := False;
  DominatorsPresent := False;
  PiratesPresent := False;
  CustomPresent := False;
  PlayerPartyPresent := False;
  PirateLeaning := False;
  NeutralPresent := False;
  CoalitionLeaning := False;
  for Index := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[Index];
    if not Ship.InHyperspace and
      ((Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> oiUninhabited)) and
      ((Ship.DockedTo = nil) or (GetPlayer = Ship)) and
      ((GetPlayer <> Ship) or ((Ship.CurrentPlanet = nil) and (Ship.DockedTo = nil)) or
       (Ship.ConsecutiveDockedDays <= 2) or (CurrentScreenId = screenPlanetQuest)) then
    begin
      AccumulateControlPresence;
      if (GetPlayer = Ship) or (GetPlayer = Ship.PartnerShip) then PlayerPartyPresent := True;
    end;
  end;
  if not CoalitionPresent and (ControlFaction = sfCoalition) then
    for Index := 0 to Planets.Count - 1 do
    begin
      Planet := Planets[Index];
      if Planet.IsCoalitionOwned and (Planet.Warriors.Count > 0) then
        for DefenderIndex := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[DefenderIndex];
          if (Ship.CurrentStar = Self) and not Ship.InHyperspace then AccumulateControlPresence;
        end;
    end;
  if (ControlFaction = sfCoalition) and not CoalitionPresent and not PiratesPresent then
    if NeutralPresent or CoalitionLeaning then CoalitionPresent := True
    else if DominatorsPresent and PirateLeaning then CoalitionPresent := True
    else if PirateLeaning then PiratesPresent := True;
  if (ControlFaction = sfPirates) and not CoalitionPresent and not PiratesPresent then
    if NeutralPresent or PirateLeaning then PiratesPresent := True
    else if DominatorsPresent and CoalitionLeaning then PiratesPresent := True
    else if CoalitionLeaning then CoalitionPresent := True;
  if (ControlFaction = sfDominators) or (Status.CustomFaction <> '') then
  begin
    if NeutralPresent then CoalitionPresent := True;
    if PirateLeaning then PiratesPresent := True;
    if CoalitionLeaning then CoalitionPresent := True;
  end;
  if (Galaxy.CoalitionDefeatedTurn <> 0) and (ControlFaction <> sfCoalition) then
  begin
    PiratesPresent := PiratesPresent or CoalitionPresent;
    CoalitionPresent := False;
  end;
  if (Galaxy.PirateWinType = 3) and (ControlFaction <> sfPirates) then
  begin
    CoalitionPresent := PiratesPresent or CoalitionPresent;
    PiratesPresent := False;
  end;
  if not DominatorsPresent and not CoalitionPresent and not PiratesPresent and
    (ControlFaction = sfDominators) and (Status.CustomFaction = '') and
    (((DominatorSeries = dsBlazer) and (Galaxy.BlazerSeriesResolvedTurn <> 0)) or
     ((DominatorSeries = dsTerron) and (Galaxy.TerronSeriesResolvedTurn <> 0))) then
    if Galaxy.CoalitionDefeatedTurn = 0 then CoalitionPresent := True else PiratesPresent := True;
  if (ControlFaction = sfDominators) and CoalitionPresent and PiratesPresent and not DominatorsPresent then
  begin
    CoalitionMilitaryPresent := False;
    PirateMilitaryPresent := False;
    PirateActivePresent := False;
    CoalitionActivePresent := False;
    PirateKills := 0;
    CoalitionKills := 0;
    PirateLeaningKills := 0;
    CoalitionLeaningKills := 0;
    for Index := 0 to Ships.Count - 1 do
    begin
      Ship := Ships[Index];
      if not Ship.InHyperspace and (Ship is TNormalShip) and
        ((GetPlayer <> Ship) or ((Ship.CurrentPlanet = nil) and (Ship.DockedTo = nil)) or
         (Ship.ConsecutiveDockedDays <= 2)) then
        if Ship.CurrentStanding = ssCoalitionMilitary then
        begin
          CoalitionMilitaryPresent := True;
          Inc(CoalitionKills, TNormalShip(Ship).CurrentSystemKills.Dominator);
        end
        else if Ship.CurrentStanding = ssPirateMilitary then
        begin
          PirateMilitaryPresent := True;
          Inc(PirateKills, TNormalShip(Ship).CurrentSystemKills.Dominator);
        end
        else if Ship.CurrentStanding <> ssNeutral then
          if Ship.CurrentStanding in [ssPiratePassive, ssPirateActive] then
          begin
            Inc(PirateKills, TNormalShip(Ship).CurrentSystemKills.Dominator);
            if Ship.CurrentStanding = ssPirateActive then PirateActivePresent := True
            else Inc(PirateLeaningKills, TNormalShip(Ship).CurrentSystemKills.Dominator);
          end
          else if Ship.CurrentStanding in [ssCoalitionActive, ssCoalitionPassive] then
          begin
            Inc(CoalitionKills, TNormalShip(Ship).CurrentSystemKills.Dominator);
            if Ship.CurrentStanding = ssCoalitionActive then CoalitionActivePresent := True
            else Inc(CoalitionLeaningKills, TNormalShip(Ship).CurrentSystemKills.Dominator);
          end;
    end;
    if CoalitionKills < PirateLeaningKills then CoalitionPresent := False
    else if PirateKills < CoalitionLeaningKills then PiratesPresent := False
    else if PirateMilitaryPresent and CoalitionMilitaryPresent then Exit
    else if PirateMilitaryPresent and CoalitionActivePresent then Exit
    else if CoalitionMilitaryPresent and PirateActivePresent then Exit
    else if CoalitionKills > PirateKills then PiratesPresent := False
    else if CoalitionKills < PirateKills then CoalitionPresent := False
    else if PlayerPartyPresent then
      if GetPlayer.OwnerId = oiPirate then CoalitionPresent := False else PiratesPresent := False
    else PiratesPresent := False;
  end;
end;
{ @end $7C25C4 }

{ @routine $7C2C18 TStar_UpdateControlFaction }
procedure TStar.UpdateControlFaction;
var
  Index: Integer;
  Planet: TPlanet;
  CoalitionPresent, CoalitionCaptured, DominatorsPresent, DominatorsCaptured,
    PiratesPresent, PiratesCaptured, CustomPresent, PlayerPartyPresent: Boolean;

  // @nested $7C2B70 RecordFactionVictory
  procedure RecordFactionVictory(Faction: TStarFaction); // @addr 0x7C2B70 @ida "void __usercall $name(unsigned __int8 Faction@<al>, void *ParentFrame@<^0>);" @note "Nested in UpdateControlFaction with unused caller-popped static link. Updates active Galaxy.WarDeltaWin; a losing streak below -1 is halved rather than incremented."
  begin
    if Galaxy.WarDeltaWin[Ord(Faction)] >= -1 then Inc(Galaxy.WarDeltaWin[Ord(Faction)])
    else Galaxy.WarDeltaWin[Ord(Faction)] := Galaxy.WarDeltaWin[Ord(Faction)] div 2;
  end;

  // @nested $7C2BC4 RecordFactionDefeat
  procedure RecordFactionDefeat(Faction: TStarFaction); // @addr 0x7C2BC4 @ida "void __usercall $name(unsigned __int8 Faction@<al>, void *ParentFrame@<^0>);" @note "Nested in UpdateControlFaction with unused caller-popped static link. Updates active Galaxy.WarDeltaWin; a winning streak above 1 is halved rather than decremented."
  begin
    if Galaxy.WarDeltaWin[Ord(Faction)] <= 1 then Dec(Galaxy.WarDeltaWin[Ord(Faction)])
    else Galaxy.WarDeltaWin[Ord(Faction)] := Galaxy.WarDeltaWin[Ord(Faction)] div 2;
  end;

begin
  if GetPlayer = nil then Exit;
  PlayerPartyPresent := False;
  DominatorsPresent := False;
  DominatorsCaptured := False;
  CoalitionPresent := False;
  CoalitionCaptured := False;
  PiratesPresent := False;
  PiratesCaptured := False;
  if ((Constellation.Id = 20) and (Galaxy.PirateWinType <> 3)) or
    (Galaxy.KellerResearchTargetStarId = Id) or NoComeKling or IsStarProtectedByScript(Self) then
  begin Battle := 0; Exit; end;
  GetControlPresence(PlayerPartyPresent, CoalitionPresent, DominatorsPresent, PiratesPresent, CustomPresent);
  if Boolean(Battle) and CoalitionPresent and not DominatorsPresent and (ControlFaction = sfCoalition) and
    (Status.CustomFaction = '') and (Galaxy.CurrentTurn - 1 <= LastDominatorPresenceTurn) and
    IsConstellationVisible and (Galaxy.CountPlanetNewsByType(25) < 2) and (Galaxy.CoalitionDefeatedTurn = 0) then
    Galaxy.AddPlanetNews(25, FormatText1(PickLocalizedTextVariant('GalaxyNews.Star.Kling.Lost',
      (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name));
  if Boolean(Battle) and CoalitionPresent and not PiratesPresent and (ControlFaction = sfCoalition) and
    (Status.CustomFaction = '') and (Galaxy.CurrentTurn - 1 <= LastPiratePresenceTurn) and
    IsConstellationVisible and (Galaxy.CountPlanetNewsByType(28) < 2) and (Galaxy.CoalitionDefeatedTurn = 0) then
    Galaxy.AddPlanetNews(28, FormatText1(PickLocalizedTextVariant('GalaxyNews.Star.Pirates.Lost',
      (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name));
  if DominatorsPresent then LastDominatorPresenceTurn := Galaxy.CurrentTurn;
  if PiratesPresent then LastPiratePresenceTurn := Galaxy.CurrentTurn;
  if DominatorsPresent and CoalitionPresent then
  begin
    if IsConstellationVisible and (Galaxy.CountPlanetNewsByType(24) < 2) and (Battle = 0) and
      (ControlFaction = sfCoalition) and (Status.CustomFaction = '') and (Galaxy.CoalitionDefeatedTurn = 0) then
      Galaxy.AddPlanetNews(24, FormatText1(PickLocalizedTextVariant('GalaxyNews.Star.Kling.Attack',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name));
    Battle := 1;
    Exit;
  end;
  if PiratesPresent and CoalitionPresent then
  begin
    if IsConstellationVisible and (Galaxy.CountPlanetNewsByType(27) < 2) and (Battle = 0) and
      (ControlFaction = sfCoalition) and (Status.CustomFaction = '') and (Galaxy.CoalitionDefeatedTurn = 0) then
      Galaxy.AddPlanetNews(27, FormatText1(PickLocalizedTextVariant('GalaxyNews.Star.Pirates.Attack',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name));
    Battle := 1;
    Exit;
  end;
  if DominatorsPresent and PiratesPresent then begin Battle := 1; Exit; end;
  if CustomPresent and (Status.CustomFaction = '') then begin Battle := 1; Exit; end;
  if Status.CustomFaction <> '' then
  begin
    Battle := Byte(CoalitionPresent or PiratesPresent or DominatorsPresent);
    Exit;
  end;
  if not DominatorsPresent and not PiratesPresent and (ControlFaction = sfCoalition) and (Battle <> 0) then
  begin
    if PlayerPartyPresent and (GetPlayer.OwnerId <> oiPirate) then
    begin
      Inc(GetPlayer.AchievementStats.SystemsDefended);
      TrySetAchievementProgress('DEFENDER', GetPlayer.AchievementStats.SystemsDefended);
    end;
    Battle := 0;
    Exit;
  end;
  if not CoalitionPresent and not PiratesPresent and (ControlFaction = sfDominators) and (Battle <> 0) then
  begin Battle := 0; Exit; end;
  if not CoalitionPresent and not DominatorsPresent and (ControlFaction = sfPirates) and (Battle <> 0) then
  begin
    if PlayerPartyPresent and (GetPlayer.OwnerId = oiPirate) then
    begin
      Inc(GetPlayer.AchievementStats.SystemsDefended);
      TrySetAchievementProgress('DEFENDER', GetPlayer.AchievementStats.SystemsDefended);
    end;
    Battle := 0;
    Exit;
  end;
  if (DominatorsPresent or PiratesPresent) and (ControlFaction = sfCoalition) then
    for Index := 0 to Planets.Count - 1 do
    begin
      Planet := Planets[Index];
      if Planet.IsCoalitionOwned and
        (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * Planet.GenerationSeed * 2311) < 20) then
      begin
        // Native tests the quotient, not the remainder: preserve the early-turn behavior.
        if Galaxy.CurrentTurn div 5 = 0 then Planet.ForceGoodsScarcity(True, [6]);
        if Galaxy.CurrentTurn div 7 = 0 then Planet.ForceGoodsScarcity(True, [1]);
        if Galaxy.CurrentTurn div 3 = 0 then Planet.ForceGoodsScarcity(True, [0]);
        if Galaxy.CurrentTurn div 5 = 0 then Planet.ForceGoodsSurplus(True, [3]);
        if Galaxy.CurrentTurn div 3 = 0 then Planet.ForceGoodsSurplus(True, [5]);
        if Galaxy.CurrentTurn div 11 = 0 then Planet.ForceGoodsSurplus(True, [7]);
      end;
    end;
  if DominatorsPresent and (ControlFaction <> sfDominators) then
  begin
    for Index := 0 to Planets.Count - 1 do
    begin
      Planet := Planets[Index];
      if Planet.OwnerId <> oiUninhabited then
      begin
        Planet.OwnerId := oiDominator;
        Planet.UpdateOwnerFlags;
        DominatorsCaptured := True;
      end;
    end;
    if DominatorsCaptured then
    begin
      if Galaxy.CoalitionDefeatedTurn = 0 then
        if ControlFaction = sfCoalition then
          Galaxy.AddPlanetNewsWithPlayerBubble(33, FormatText2(
            PickLocalizedTextVariant('GalaxyNews.Globals.KlingTakeSystemFromNormals', (Galaxy.CurrentTurn div 10) * GenerationSeed),
            '<color=255,240,100>', '<Star>', Name, '<Sector>', Constellation.GetName))
        else if Galaxy.CoalitionDefeatedTurn = 0 then
          Galaxy.AddPlanetNewsWithPlayerBubble(34, FormatText2(
            PickLocalizedTextVariant('GalaxyNews.Globals.KlingTakeSystemFromPirateClan', (Galaxy.CurrentTurn div 10) * GenerationSeed),
            '<color=255,240,100>', '<Star>', Name, '<Sector>', Constellation.GetName))
        else
          // Retained native branch, despite the outer zero test.
          AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, FormatText2(
            PickLocalizedTextVariant('GalaxyNews.Globals.KlingTakeSystemFromPirateClanAlt', (Galaxy.CurrentTurn div 10) * GenerationSeed),
            '<color=255,240,100>', '<Star>', Name, '<Sector>', Constellation.GetName), '');
      RecordFactionDefeat(ControlFaction);
      PreviousControlFaction := ControlFaction;
      ControlFaction := sfDominators;
      Battle := 0;
      RecordFactionVictory(sfDominators);
    end;
  end
  else if PiratesPresent and (Galaxy.PirateWinType <> 3) and (ControlFaction <> sfPirates) then
  begin
    for Index := 0 to Planets.Count - 1 do
    begin
      Planet := Planets[Index];
      if Planet.OwnerId <> oiUninhabited then
      begin
        Planet.Warriors.Clear;
        Planet.OwnerId := oiPirate;
        Planet.Government := pgAnarchy;
        Planet.UpdateOwnerFlags;
        PiratesCaptured := True;
      end;
    end;
    if PiratesCaptured then
    begin
      RecordFactionDefeat(ControlFaction);
      PreviousControlFaction := ControlFaction;
      ControlFaction := sfPirates;
      Battle := 0;
      if (MainPiratePlanet = nil) or (MainPiratePlanet.CurrentStar <> Self) then LiberationRewardsPending := True;
      RecordFactionVictory(sfPirates);
      for Index := 0 to Ships.Count - 1 do
        if (TObject(Ships[Index]) is TPirate) and not TShip(Ships[Index]).HasScriptControl then
          TPirate(Ships[Index]).PrisonTermRemaining := 0;
      if GetPlayer <> nil then GetPlayer.AchievementStats.CheckAllPirateSystemsAchievement;
      if (PieceCreatorTargetStarId = Id) and (GetPlayer <> nil) then TryUnlockAchievement('PIECECREATOR');
    end;
  end
  else if CoalitionPresent and (Galaxy.CoalitionDefeatedTurn = 0) and (ControlFaction <> sfCoalition) then
  begin
    for Index := 0 to Planets.Count - 1 do
    begin
      Planet := Planets[Index];
      if Planet.OwnerId <> oiUninhabited then
      begin
        if Planet.OwnerId = oiPirate then Planet.Government := TPlanetGovernment(SeededRandomIntRange(0, 4, Planet.RandomState));
        Planet.OwnerId := RaceToOwner(Planet.RaceId);
        Planet.UpdateOwnerFlags;
        Planet.InventionLevels[7] := Max(Integer(Planet.InventionLevels[7]), Galaxy.TechLevel - 2);
        CoalitionCaptured := True;
      end;
    end;
    if CoalitionCaptured then
    begin
      RecordFactionDefeat(ControlFaction);
      PreviousControlFaction := ControlFaction;
      ControlFaction := sfCoalition;
      Battle := 0;
      if (MainPiratePlanet = nil) or (MainPiratePlanet.CurrentStar <> Self) then LiberationRewardsPending := True;
      RecordFactionVictory(sfCoalition);
      for Index := 0 to Ships.Count - 1 do
        if (TObject(Ships[Index]) is TRanger) and not TShip(Ships[Index]).HasScriptControl and
          (TShip(Ships[Index]) <> GetPlayer) then TRanger(Ships[Index]).PrisonTermRemaining := 0;
      if (PieceCreatorTargetStarId = Id) and (GetPlayer <> nil) then TryUnlockAchievement('PIECECREATOR');
    end;
  end;
end;
{ @end $7C2C18 }

{ @routine $7C3E1C TStar_ResetControlFaction }
procedure TStar.ResetControlFaction;
var Ship: TShip;
  DominatorCount, CoalitionCount, CoalitionPassiveCount, NeutralCount, PiratePassiveCount, PirateCount: Integer;
  Planet: TPlanet;
  I: Integer;
  SeriesCounts: array[0..2] of Integer;

  // @nested $7C3B8C CountShipStanding
  procedure CountShipStanding; // @addr 0x7C3B8C @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ship -4, standing counters -8..-28."
  begin
    case Ship.CurrentStanding of
      ssDominator: Inc(DominatorCount);
      ssCoalitionMilitary, ssCoalitionActive: Inc(CoalitionCount);
      ssCoalitionPassive: Inc(CoalitionPassiveCount);
      ssNeutral: Inc(NeutralCount);
      ssPiratePassive: Inc(PiratePassiveCount);
      ssPirateActive, ssPirateMilitary: Inc(PirateCount);
    end;
  end;

  // @nested $7C3BFC SetCoalition
  procedure SetCoalition; // @addr 0x7C3BFC @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; star -32. Also transfers planets and clears eligible NPC ranger prison terms."
  var J: Integer;
  begin
    ControlFaction := sfCoalition;
    PreviousControlFaction := sfCoalition;
    Battle := Byte(PirateCount + DominatorCount > 0);
    for J := 0 to Planets.Count - 1 do begin
      Planet := TPlanet(Planets[J]);
      if Planet.OwnerId <> oiUninhabited then begin
        Planet.OwnerId := RaceToOwner(Planet.RaceId);
        Planet.UpdateOwnerFlags;
      end;
    end;
    for J := 0 to Ships.Count - 1 do begin
      Ship := TShip(Ships[J]);
      if (Ship is TRanger) and not Ship.HasScriptControl and (GetPlayer <> Ship) then TRanger(Ship).PrisonTermRemaining := 0;
    end;
  end;

  // @nested $7C3D18 SetPirates
  procedure SetPirates; // @addr 0x7C3D18 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; star -32. Also transfers planets and clears eligible NPC pirate prison terms."
  var J: Integer;
  begin
    ControlFaction := sfPirates;
    PreviousControlFaction := sfPirates;
    Battle := Byte(CoalitionCount + DominatorCount > 0);
    for J := 0 to Planets.Count - 1 do begin
      Planet := TPlanet(Planets[J]);
      if Planet.OwnerId <> oiUninhabited then begin Planet.OwnerId := oiPirate; Planet.UpdateOwnerFlags; end;
    end;
    for J := 0 to Ships.Count - 1 do begin
      Ship := TShip(Ships[J]);
      if (Ship is TPirate) and not Ship.HasScriptControl then TPirate(Ship).PrisonTermRemaining := 0;
    end;
  end;

begin
  if GetPlayer = nil then Exit;
  DominatorCount := 0;
  CoalitionCount := 0;
  PirateCount := 0;
  CoalitionPassiveCount := 0;
  PiratePassiveCount := 0;
  NeutralCount := 0;
  SeriesCounts[Ord(dsBlazer)] := 0;
  SeriesCounts[Ord(dsTerron)] := 0;
  SeriesCounts[Ord(dsKeller)] := 0;
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    if not Ship.InHyperspace and ((Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> oiUninhabited)) and
      ((Ship.DockedTo = nil) or (GetPlayer = Ship)) and
      ((GetPlayer <> Ship) or ((Ship.CurrentPlanet = nil) and (Ship.DockedTo = nil)) or
       (Ship.ConsecutiveDockedDays <= 2) or (CurrentScreenId = screenPlanetQuest)) then begin
      CountShipStanding;
      if (Ship is TKling) and (Ship.CurrentStanding = ssDominator) then begin
        with Ship as TKling do begin
        Inc(SeriesCounts[Ord(DominatorSeries)]);
        if KlingType = ktBertor then Inc(SeriesCounts[Ord(DominatorSeries)], 3);
        if KlingType = ktBoss then Inc(SeriesCounts[Ord(DominatorSeries)], 10);
        end;
      end;
    end;
  end;
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    if Ship is TNormalShip then begin
      with Ship as TNormalShip do begin
      CurrentSystemKills.Normal := 0;
      CurrentSystemKills.Pirate := 0;
      CurrentSystemKills.Dominator := 0;
      CurrentSystemKills.Custom := 0;
      PendingLiberationCeremonyPlanet := nil;
      PendingLiberationContribution := 0;
      end;
    end;
  end;
  if DominatorCount > CoalitionCount + PirateCount + CoalitionPassiveCount + PiratePassiveCount + NeutralCount then begin
    ControlFaction := sfDominators;
    PreviousControlFaction := sfDominators;
    for I := 0 to Planets.Count - 1 do begin
      Planet := TPlanet(Planets[I]);
      if Planet.OwnerId <> oiUninhabited then begin Planet.OwnerId := oiDominator; Planet.UpdateOwnerFlags; end;
    end;
    if SeriesCounts[Ord(dsBlazer)] >= Max(SeriesCounts[Ord(dsTerron)], SeriesCounts[Ord(dsKeller)]) then DominatorSeries := dsBlazer
    else if SeriesCounts[Ord(dsTerron)] >= Max(SeriesCounts[Ord(dsBlazer)], SeriesCounts[Ord(dsKeller)]) then DominatorSeries := dsTerron
    else DominatorSeries := dsKeller;
    Battle := Byte(CoalitionCount + PirateCount + CoalitionPassiveCount + PiratePassiveCount + NeutralCount > 0);
  end else if Galaxy.CoalitionDefeatedTurn > 0 then SetPirates
  else if Galaxy.PirateWinType = 3 then SetCoalition
  else if CoalitionCount > PirateCount then SetCoalition
  else if PirateCount > CoalitionCount then SetPirates
  else if CoalitionPassiveCount > PiratePassiveCount then SetCoalition
  else if PiratePassiveCount > CoalitionPassiveCount then SetPirates
  else SetCoalition;
end;
{ @end $7C3E1C }

{ @routine $7C4188 TStar_RefreshMapDiameterAndStats }
procedure TStar.RefreshMapDiameterAndStats;
begin
  MapDiameter := ComputeMapDiameter;
  RefreshDerivedStats;
end;
{ @end $7C4188 }

{ @routine $7C41A8 TStar_RefreshMovementStepParameters }
procedure TStar.RefreshMovementStepParameters;
begin
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = Self) then
  begin
    MovementStepCount := BaseMovementStepsPerTurn;
    MovementStepScale := 1 / BaseMovementStepsPerTurn;
  end
  else
  begin
    MovementStepCount := 50;
    MovementStepScale := 1 / 50;
  end;
end;
{ @end $7C41A8 }

{ @routine $7C4228 TStar_ComputeMapDiameter }
function TStar.ComputeMapDiameter: Integer;
var Planet: TPlanet;
begin
  if Planets.Count > 0 then
  begin
    Planet := TPlanet(Planets[Planets.Count - 1]);
    Result := Round(Planet.Orbit.Radius + Planet.Radius + 800) * 2;
  end
  else Result := (SystemRadius + 800) * 2;
end;
{ @end $7C4228 }

{ @routine $7C4290 TStar_CountPlanetsByOwner }
function TStar.CountPlanetsByOwner(OwnerId: TOwnerId): Integer;
var
  I: Integer;
  Planet: TPlanet;
begin
  Result := 0;
  for I := 0 to Planets.Count - 1 do
  begin
    Planet := Planets[I];
    if Planet.OwnerId = OwnerId then Inc(Result);
  end;
end;
{ @end $7C4290 }

{ @routine $7C42E8 TStar_CountDistinctInhabitedPlanetOwners }
function TStar.CountDistinctInhabitedPlanetOwners: Integer;
var OwnerId: TOwnerId;
begin
  Result := 0;
  for OwnerId := oiMaloc to oiDominator do
    if CountPlanetsByOwner(OwnerId) > 0 then Inc(Result);
  if CountPlanetsByOwner(oiPirate) > 0 then Inc(Result);
end;
{ @end $7C42E8 }

{ @routine $7C4330 TStar_FindFirstInhabitedPlanet }
function TStar.FindFirstInhabitedPlanet: Pointer;
var Index: Integer;
begin
  Result := nil;
  for Index := 0 to Planets.Count - 1 do
  begin
    Result := Planets[Index];
    if (TObject(Result) as TPlanet).OwnerId <> oiUninhabited then Break;
  end;
end;
{ @end $7C4330 }

{ @routine $7C438C TStar_SelectRandomInhabitedPlanet }
function TStar.SelectRandomInhabitedPlanet: Pointer;
var I, Remaining: Integer;
begin
  Result := nil;
  Remaining := 0;
  for I := 0 to Planets.Count - 1 do
    if TPlanet(Planets[I]).OwnerId <> oiUninhabited then Inc(Remaining);
  Remaining := NextRandomIntRange(1, Remaining, RandomState);
  for I := 0 to Planets.Count - 1 do
    if TPlanet(Planets[I]).OwnerId <> oiUninhabited then
    begin
      Dec(Remaining);
      if Remaining = 0 then
      begin
        Result := Planets[I];
        Exit;
      end;
    end;
end;
{ @end $7C438C }

{ @routine $7C4448 TStar_FindFastestResearchPlanet }
function TStar.FindFastestResearchPlanet: Pointer;
var I: Integer; Rate, BestRate: Single; Planet, Best: TPlanet;
begin
  Best := nil;
  BestRate := 0;
  for I := 0 to Planets.Count - 1 do begin
    Planet := TPlanet(Planets[I]);
    if Planet.OwnerId <> oiUninhabited then begin
      Rate := Planet.CalculateInventionProgressRate;
      if (Rate > BestRate) or (Best = nil) then begin
        BestRate := Rate;
        Best := Planet;
      end;
    end;
  end;
  Result := Best;
end;
{ @end $7C4448 }

{ @routine $7C44D0 TStar_RefreshShipTypeCounts }
procedure TStar.RefreshShipTypeCounts;
var I: Integer; Ship: TShip; Kind: Byte;
begin
  for Kind := 0 to 13 do ShipTypeCounts[Kind] := 0;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := TShip(Ships[I]);
    if (Dominion = Ship) or Ship.InNormalSpace or ((Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and Ship.InHyperspace) then
      Inc(ShipTypeCounts[Ship.TypeId]);
  end;
end;
{ @end $7C44D0 }

{ @routine $7C4570 TStar_CountEligibleRangersInSpace }
function TStar.CountEligibleRangersInSpace: Integer;
var Index: Integer; Ship: TShip;
begin
  Result := 0;
  for Index := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[Index];
    if not Ship.IsOutsideStarSpace and (Ship is TRanger) and not TRanger(Ship).ExcludedFromRating then Inc(Result);
  end;
end;
{ @end $7C4570 }

{ @routine $7C45E4 TStar_CountShipsByTypeMask }
function TStar.CountShipsByTypeMask(ShipTypeMask: TShipTypeMask): Integer;
var Count: Integer; I: Byte;
begin
  Count := 0;
  for I := 0 to 13 do if I in ShipTypeMask then Inc(Count, ShipTypeCounts[I]);
  Result := Count;
end;
{ @end $7C45E4 }

{ @routine $7C4634 TStar_CountDominatorForces }
function TStar.CountDominatorForces(Series: TDominatorSeries; ExcludeAbsoluteOrders, OtherSeries: Boolean; out Strength: Extended): Integer;
var
  I, OtherCount, MatchCount: Integer;
  OtherStrength, MatchStrength: Single;
  Ship: TShip;
begin
  OtherCount := 0;
  MatchCount := 0;
  OtherStrength := 0;
  MatchStrength := 0;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[I];
    if Ship.IsOutsideStarSpace then Continue;
    if ExcludeAbsoluteOrders and Ship.OrderAbsolute then Continue;
    if (BlazerShip = Ship) or (KellerShip = Ship) or (TerronShip = Ship) then Continue;
    if not (Ship is TKling) then Continue;
    if (Ship as TKling).ActiveProgramAppliedTurn > 0 then Continue;
    if Ship.CurrentStanding = ssCustom then Continue;
    if (Ship as TKling).DominatorSeries = Series then
    begin
      Inc(MatchCount);
      MatchStrength := MatchStrength + Ship.Strength;
    end
    else
    begin
      Inc(OtherCount);
      OtherStrength := OtherStrength + Ship.Strength;
    end;
  end;
  if OtherSeries then
  begin
    Result := OtherCount;
    Strength := OtherStrength;
  end
  else
  begin
    Result := MatchCount;
    Strength := MatchStrength;
  end;
end;
{ @end $7C4634 }

{ @routine $7C4788 TStar_CountStandardDominatorsOfLocalSeries }
function TStar.CountStandardDominatorsOfLocalSeries: Integer;
var I: Integer; Ship: TShip;
begin
  Result := 0;
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    if not Ship.IsOutsideStarSpace and (Ship.CurrentStanding <> ssCustom) and
      (Ship <> BlazerShip) and (Ship <> KellerShip) and (Ship <> TerronShip) and
      (Ship is TKling) and ((Ship as TKling).DominatorSeries = DominatorSeries) and
      ((Ship as TKling).KlingType in [ktEquentor..ktShtip]) then Inc(Result);
  end;
end;
{ @end $7C4788 }

{ @routine $7C4860 TStar_CountPirateForces }
function TStar.CountPirateForces(ExcludeAbsoluteOrders: Boolean; out Strength: Extended; IncludeClanVariants, IncludeIndependent: Boolean): Integer;
var Index, Count: Integer; Ship: TShip;
begin
  Count := 0;
  Strength := 0;
  for Index := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[Index];
    if Ship.IsOutsideStarSpace or (Ship.CurrentStanding = ssCustom) or (ExcludeAbsoluteOrders and Ship.OrderAbsolute) then Continue;
    if (Ship is TPirate) and (Ship.OwnerId = oiPirate) then
    begin
      if (not IncludeClanVariants and ((Ship as TPirate).PirateType <> 0)) or
        (not IncludeIndependent and ((Ship as TPirate).PirateType = 0)) then Continue;
      Inc(Count);
      Strength := Strength + Ship.Strength;
    end;
    if (GetPlayer = Ship) and (GetPlayer.OwnerId = oiPirate) and IncludeIndependent then
    begin
      Inc(Count);
      Strength := Strength + Ship.Strength;
    end;
  end;
  Result := Count;
end;
{ @end $7C4860 }

{ @routine $7C49A0 TStar_CountCustomFactionForces }
function TStar.CountCustomFactionForces(ExcludeAbsoluteOrders: Boolean; out Faction: WideString; out Strength: Extended): Integer;
var
  I: Integer;
  Ship: TShip;
begin
  Faction := Status.CustomFaction;
  Result := 0;
  Strength := 0;
  if Faction <> '' then
    for I := 0 to Ships.Count - 1 do
    begin
      Ship := Ships[I];
      if Ship.IsOutsideStarSpace then Continue;
      if Ship.CurrentStanding <> ssCustom then Continue;
      if Ship.ScriptShip = nil then Continue;
      if TScriptShip(Ship.ScriptShip).StateText <> Faction then Continue;
      if ExcludeAbsoluteOrders and Ship.OrderAbsolute then Continue;
      Inc(Result);
      Strength := Strength + Ship.Strength;
    end;
end;
{ @end $7C49A0 }

{ @routine $7C4A94 TStar_CountOtherCustomFactionForces }
function TStar.CountOtherCustomFactionForces(ExcludeAbsoluteOrders: Boolean; out Faction: WideString; out Strength: Extended): Integer;
var
  I, Count: Integer;
  Ship: TShip;
  ShipFaction, OwnFaction: WideString;
begin
  Count := 0;
  Strength := 0;
  OwnFaction := Status.CustomFaction;
  Faction := '';
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[I];
    if Ship.IsOutsideStarSpace then Continue;
    if Ship.CurrentStanding <> ssCustom then Continue;
    if ExcludeAbsoluteOrders and Ship.OrderAbsolute then Continue;
    if (Ship.ScriptShip = nil) or (TScriptShip(Ship.ScriptShip).StateText = '') then Faction := ''
    else
    begin
      ShipFaction := TScriptShip(Ship.ScriptShip).StateText;
      if ShipFaction = OwnFaction then Continue;
      if Count = 0 then Faction := ShipFaction
      else if Faction <> ShipFaction then Faction := '';
    end;
    Inc(Count);
    Strength := Strength + Ship.Strength;
  end;
  Result := Count;
end;
{ @end $7C4A94 }

{ @routine $7C4C20 TStar_CountPirateShips }
function TStar.CountPirateShips(IncludeOutsideStarSpace: Boolean): Integer;
var I, Count: Integer; Ship: TShip;
begin
  Count := 0;
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    if (not Ship.IsOutsideStarSpace or (IncludeOutsideStarSpace <> False)) and (Ship.CurrentStanding <> ssCustom) then begin
      if (Ship is TPirate) and (Ship.OwnerId = oiPirate) then Inc(Count);
      if (Ship = GetPlayer) and (GetPlayer.OwnerId = oiPirate) then Inc(Count);
    end;
  end;
  Result := Count;
end;
{ @end $7C4C20 }

{ @routine $7C4DEC TStar_CountForcesByOwnerGroups }
function TStar.CountForcesByOwnerGroups(out Strength: Extended; IncludeCoalition, IncludeDominators, IncludePirates, IncludeCustom: Boolean): Integer;
var
  Ship: TShip;
  Count, I, J: Integer;
  Planet: TPlanet;

  // @nested $7C4CC4 AccumulateFactionForces
  procedure AccumulateFactionForces; cdecl; // @addr 0x7C4CC4 @ida "void __cdecl $name(void *ParentFrame);"
  begin
    if Ship.InHyperspace then Exit;
    if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet.OwnerId = oiUninhabited) then Exit;
    if Ship.CurrentStanding = ssCustom then
    begin
      if IncludeCustom then
      begin
        Strength := Strength + Ship.Strength;
        Inc(Count);
      end;
      Exit;
    end;
    begin
      if not IncludeCoalition and (Ship.OwnerId in PlanetOwnerMasks.Coalition) then Exit;
      if not IncludeDominators and (Ship.OwnerId in PlanetOwnerMasks.Dominators) then Exit;
      if not IncludePirates and (Ship.OwnerId in PlanetOwnerMasks.PirateClan) then Exit;
      if (GetPlayer = Ship) and GetPlayer.IsOutsideStarSpace then Exit;
      Strength := Strength + Ship.Strength;
      Inc(Count);
    end;
  end;

begin
  Count := 0;
  Strength := 0;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[I];
    AccumulateFactionForces;
  end;
  for I := 0 to Planets.Count - 1 do
  begin
    Planet := Planets[I];
    if Planet.Warriors <> nil then
      for J := 0 to Planet.Warriors.Count - 1 do
      begin
        Ship := TShip(Planet.Warriors[J]);
        if (Ship.CurrentStar = Self) and (Ships.IndexOf(Ship) < 0) then AccumulateFactionForces;
      end;
  end;
  Result := Count;
end;
{ @end $7C4DEC }

{ @routine $7C4EF8 TStar_CountRatedRangersByCareerMask }
function TStar.CountRatedRangersByCareerMask(CareerMask: TRangerCareerSet): Byte;
var Index: Integer; Ship: TObject; Ranger: TRanger;
begin
  Result := 0;
  for Index := 0 to Ships.Count - 1 do
  begin
    Ship := TObject(Ships[Index]);
    if Ship is TRanger then
    begin
      Ranger := Ship as TRanger;
      if not Ranger.ExcludedFromRating and (Ranger.GetDominantCareer in CareerMask) then Inc(Result);
    end;
  end;
end;
{ @end $7C4EF8 }

{ @routine $7C4F88 TStar_GetRangerNamesByCareerMask }
function TStar.GetRangerNamesByCareerMask(CareerMask: TRangerCareerSet): WideString;
var Index: Integer; Ship: TObject; Ranger: TRanger;
begin
  Result := '';
  for Index := 0 to Ships.Count - 1 do
  begin
    Ship := TObject(Ships[Index]);
    if Ship is TRanger then
    begin
      Ranger := Ship as TRanger;
      if Ranger.GetDominantCareer in CareerMask then
      begin
        if Result <> '' then Result := Result + ',' + ' ' + Ranger.Name
        else Result := Ranger.Name;
      end;
    end;
  end;
end;
{ @end $7C4F88 }

{ @routine $7C5068 TStar_IsConstellationVisible }
function TStar.IsConstellationVisible: Boolean;
begin
  Result := Constellation.Visible;
end;
{ @end $7C5068 }

{ @routine $7C5088 TStar_GetCachedFactionStrength }
function TStar.GetCachedFactionStrength(FactionGroup: TStarFaction): Single;
var I: Integer; Ship: TShip; RelativeScale, Weight, Strength, DominatorAndCustomStrength, CoalitionStrength, PirateStrength, Extra: Single;
begin
  if Galaxy.CurrentTurn = FactionStrengthCacheTurn then Result := Status.CachedFactionStrength[FactionGroup]
  else begin
    FactionStrengthCacheTurn := Galaxy.CurrentTurn;
    DominatorAndCustomStrength := 0;
    CoalitionStrength := 0;
    PirateStrength := 0;
    RelativeScale := 1 / Max(1, Galaxy.AverageRangerStrength);
    for I := 0 to Ships.Count - 1 do begin
      Ship := TShip(Ships[I]);
      Weight := 1;
      if Ship.InHyperspace and (Ship.OrderTarget = Self) then Weight := Weight - 0.25;
      if Ship.InNormalSpace and (Ship.Order = soJump) then Weight := Weight - 0.5;
      if (Ship.DockedTo = nil) or (Ship.Order <> soNone) or not (Ship.DockedTo is TRuins) or
        (TRuins(Ship.DockedTo).FlyToStar = nil) or (TRuins(Ship.DockedTo).FlyToStar = Self) then begin
        if Ship.GetHull.HullPoints < Ship.GetHull.Weight * 0.25 then Weight := Weight - 0.5;
        Strength := Min(10, Max(0.1, Ship.Strength * RelativeScale)) * Weight;
        if Ship is TKling then Strength := DominatorShipDefinitions[Ord((Ship as TKling).KlingType)].FactionStrengthWeight * Strength;
        if Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive] then CoalitionStrength := CoalitionStrength + Strength
        else if Ship.CurrentStanding in [ssPirateActive, ssPirateMilitary] then PirateStrength := PirateStrength + Strength
        else if Ship.CurrentStanding in [ssDominator, ssCustom] then DominatorAndCustomStrength := DominatorAndCustomStrength + Strength;
        if Ship is TNormalShip then begin
          Extra := Sqr((Ship as TNormalShip).CurrentSystemKills.Pirate) * Strength * 0.04;
          CoalitionStrength := CoalitionStrength + Extra;
          Extra := Sqr((Ship as TNormalShip).CurrentSystemKills.Normal) * Strength * 0.04;
          PirateStrength := PirateStrength + Extra;
          Extra := Sqr((Ship as TNormalShip).CurrentSystemKills.Dominator) * Strength * 0.04;
          if Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive] then CoalitionStrength := CoalitionStrength + Extra
          else if Ship.CurrentStanding in [ssPirateActive, ssPirateMilitary] then PirateStrength := PirateStrength + Extra;
        end;
      end;
    end;
    // Native $7C5420/$7C5429/$7C5432 store these in TStar+$4C/$50/$54.
    Status.CachedFactionStrength[sfCoalition] := CoalitionStrength;
    Status.CachedFactionStrength[sfDominators] := DominatorAndCustomStrength;
    Status.CachedFactionStrength[sfPirates] := PirateStrength;
    Result := Status.CachedFactionStrength[FactionGroup];
  end;
end;
{ @end $7C5088 }

{ @routine $7C5474 TStar_SumBestRangerRelativeStrength }
function TStar.SumBestRangerRelativeStrength(ShipTypeMask: TShipTypeMask): Single;
var I: Integer; Ship: TShip;
begin
  Result := 0;
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    if (Ship <> BlazerShip) and (Ship <> KellerShip) and (Ship <> TerronShip) and
      (Ship.TypeId in ShipTypeMask) then Result := Result + Ship.StrengthInBestRanger;
  end;
end;
{ @end $7C5474 }

{ @routine $7C5508 TStar_RebuildStarDistances }
procedure TStar.RebuildStarDistances(Galaxy: TGalaxy);
var Count, I, J, Distance: Integer; Star: TStar;
begin
  Count := Galaxy.Stars.Count;
  StarDistances := nil;
  SetLength(StarDistances, Count);
  for I := 0 to Count - 1 do begin
    Star := TStar(Galaxy.Stars[I]);
    StarDistances[I].Star := Star;
    StarDistances[I].Distance := Round(PointDistance(Position, Star.Position));
  end;
  for I := 0 to Count - 2 do
    for J := I to Count - 1 do
      if StarDistances[J].Distance < StarDistances[I].Distance then begin
        Distance := StarDistances[J].Distance;
        StarDistances[J].Distance := StarDistances[I].Distance;
        StarDistances[I].Distance := Distance;
        Star := TObject(StarDistances[J].Star) as TStar;
        StarDistances[J].Star := StarDistances[I].Star;
        StarDistances[I].Star := Star;
      end;
end;
{ @end $7C5508 }

{ @routine $7C56BC TStar_HasHostilePresenceForScriptBinding }
function TStar.HasHostilePresenceForScriptBinding: Boolean;
var I: Integer; Ship: TShip;
begin
  for I := 0 to Ships.Count - 1 do begin
    Ship := TShip(Ships[I]);
    if (Ship is TKling) or (Ship.CurrentStanding = ssPirateMilitary) or Ship.HasIndependentScriptFaction then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $7C56BC }

{ @routine $7C5734 TStar_FindNearestStarByFaction }
function TStar.FindNearestStarByFaction(Faction: TStarFaction; InBattle: Boolean): TStar;
var I: Integer; Star: TStar;
begin
  for I := 1 to Galaxy.Stars.Count - 1 do begin
    Star := TObject(StarDistances[I].Star) as TStar;
    if (Star.ControlFaction = Faction) and (Star.Battle = Byte(InBattle)) and (Star.Status.CustomFaction = '') then begin
      Result := Star;
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $7C5734 }

{ @routine $7C57BC TStar_GetBoundaryPointTowardStar }
function TStar.GetBoundaryPointTowardStar(Star: TStar): TPointF;
var Angle, Radius: Double;
begin
  Angle := HeadingDegreesToRadians(PointBearingDegrees(Position, Star.Position));
  Radius := ComputeMapDiameter * 0.4;
  Result.X := Trunc(Sin(Angle) * Radius);
  Result.Y := Trunc(-Cos(Angle) * Radius);
end;
{ @end $7C57BC }

{ @routine $7C5868 TStar_HasLiberationGroupOrder }
function TStar.HasLiberationGroupOrder: Boolean;
var I, J: Integer; Group: TGroup; Order: TGroupRouteOrder;
begin
  for I := 0 to Galaxy.LiberationGroups.Count - 1 do begin
    Group := Galaxy.LiberationGroups[I];
    for J := 0 to Length(Group.Route) - 1 do begin
      Order := Group.Route[J];
      if (Order.Target is TStar) and (Order.Target = Self) then begin Result := True; Exit; end;
    end;
  end;
  Result := False;
end;
{ @end $7C5868 }

{ @routine $7C591C TStar_TryGenerateSystemNews }
procedure TStar.TryGenerateSystemNews;
var Chance: Integer; Names: WideString;
begin
  if IsConstellationVisible and (Galaxy.PlanetNews.Count < MaxPlanetNews) and
    (ControlFaction <> sfDominators) and (Battle = 0) and (Status.CustomFaction = '') and
    (Galaxy.CoalitionDefeatedTurn <= 0) and (Constellation.Id <> 20) then
  begin
    Chance := Round(RemapClamped(Galaxy.PlanetNews.Count, 0, MaxPlanetNews, 95, 5));
    if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2111) < Chance) and
      (Galaxy.CountPlanetNewsByType(18) = 0) and (ShipTypeCounts[stTransport] > 9) then
    begin
      Galaxy.AddPlanetNews(18, FormatText1(PickLocalizedTextVariant('GalaxyNews.Star.Transport.Many',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2211) < Chance) and
      (Galaxy.CountPlanetNewsByType(18) = 0) and (ShipTypeCounts[stTransport] > 9) then
    begin
      Galaxy.AddPlanetNews(18, FormatText1(PickLocalizedTextVariant('GalaxyNews.Star.Transport.Many1',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2311) < Chance) and
      (Galaxy.CountPlanetNewsByType(19) < 1) and (DaysSincePlayerVisit > 30) and
      (ShipTypeCounts[stKling] = 0) and (ShipTypeCounts[stPirate] > 4) and (ControlFaction <> sfPirates) then
    begin
      Names := IntToStr(NextRandomIntRange(1, 2, RandomState) + ShipTypeCounts[stPirate]);
      Galaxy.AddPlanetNews(19, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Pirates.Many',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<AttackCount>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2411) < Chance) and
      (Galaxy.CountPlanetNewsByType(20) < 1) and (DaysSincePlayerVisit > 30) and
      (ShipTypeCounts[stKling] = 0) and (ShipTypeCounts[stPirate] > 2) and (ControlFaction <> sfPirates) then
    begin
      Names := IntToStr(NextRandomIntRange(1, 2, RandomState) + ShipTypeCounts[stPirate]);
      Galaxy.AddPlanetNews(20, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Pirates.Some',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<AttackCount>', Names));
    end
    else if (SeededRandomIntRange(50, 100, Galaxy.CurrentTurn * GenerationSeed * 2511) < Chance) and
      (Galaxy.CountPlanetNewsByType(21) < 1) and (DaysSincePlayerVisit > 30) and
      (ShipTypeCounts[stKling] = 0) and (ShipTypeCounts[stPirate] = 0) and (ControlFaction <> sfPirates) then
    begin
      Names := IntToStr(NextRandomIntRange(1, 2, RandomState) + ShipTypeCounts[stPirate]);
      Galaxy.AddPlanetNews(21, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Pirates.None',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<AttackCount>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2611) < 90) and
      (Galaxy.CountPlanetNewsByType(22) = 0) and (ShipTypeCounts[stRanger] >= 4) and
      (CountRatedRangersByCareerMask([rcTrader]) > 4) then
    begin
      Names := GetRangerNamesByCareerMask([rcTrader]);
      Galaxy.AddPlanetNews(22, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Rangers.ManyTrader',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<Names>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2711) < 90) and
      (Galaxy.CountPlanetNewsByType(22) = 0) and (ShipTypeCounts[stRanger] >= 4) and
      (CountRatedRangersByCareerMask([rcPirate]) > 4) then
    begin
      Names := GetRangerNamesByCareerMask([rcPirate]);
      Galaxy.AddPlanetNews(22, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Rangers.ManyPirate',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<Names>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 2811) < 90) and
      (Galaxy.CountPlanetNewsByType(22) = 0) and (ShipTypeCounts[stKling] = 0) and (ShipTypeCounts[stRanger] >= 4) and
      (CountRatedRangersByCareerMask([rcWarrior]) > 4) then
    begin
      Names := GetRangerNamesByCareerMask([rcWarrior]);
      Galaxy.AddPlanetNews(22, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Rangers.ManyWarrior',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<Names>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 3011) < 100) and
      (Galaxy.CountPlanetNewsByType(23) = 0) and (Galaxy.EminentCareerShips[rcTrader] <> nil) and
      (Galaxy.EminentCareerShips[rcTrader] as TRanger).InHyperspace and
      ((Galaxy.EminentCareerShips[rcTrader] as TRanger).CurrentStar = Self) then
    begin
      Names := (Galaxy.EminentCareerShips[rcTrader] as TRanger).Name;
      Galaxy.AddPlanetNews(23, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Rangers.BestTrader',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<Name>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 3111) < 100) and
      (Galaxy.CountPlanetNewsByType(23) = 0) and (Galaxy.EminentCareerShips[rcPirate] <> nil) and
      (Galaxy.EminentCareerShips[rcPirate] as TRanger).InHyperspace and
      ((Galaxy.EminentCareerShips[rcPirate] as TRanger).CurrentStar = Self) then
    begin
      Names := (Galaxy.EminentCareerShips[rcPirate] as TRanger).Name;
      Galaxy.AddPlanetNews(23, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Rangers.BestPirate',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<Name>', Names));
    end
    else if (SeededRandomIntRange(0, 100, Galaxy.CurrentTurn * GenerationSeed * 3211) < 100) and
      (Galaxy.CountPlanetNewsByType(23) = 0) and (Galaxy.EminentCareerShips[rcWarrior] <> nil) and
      (Galaxy.EminentCareerShips[rcWarrior] as TRanger).InHyperspace and
      ((Galaxy.EminentCareerShips[rcWarrior] as TRanger).CurrentStar = Self) then
    begin
      Names := (Galaxy.EminentCareerShips[rcWarrior] as TRanger).Name;
      Galaxy.AddPlanetNews(23, FormatText2(PickLocalizedTextVariant('GalaxyNews.Star.Rangers.BestWarrior',
        (Galaxy.CurrentTurn div 10) * GenerationSeed), '<color=255,240,100>', '<Star>', Name, '<Name>', Names));
    end;
  end;
end;
{ @end $7C591C }

{ @routine $7C70CC TStar_NextDay }
{ Constant arguments preserve evaluation order; computed arguments stay at their call sites. }
procedure CreateFilmEffect(const GraphKey: WideString; ShotVisual: Integer;
  out Effect: TObjectSE; out EffectFilm: TEFilmObj); inline;
begin
  Effect := TWeaponSE.Create(GraphKey, Classes.Point(0, 0), ShotVisual, -1);
  EffectFilm := PrimaryFilm.AddObject(0, Effect);
end;

procedure TStar.NextDay(RecordFilm: Boolean);
var
  { Local order and unused Reserved slots preserve the native DCC32 frame. }
  Item: TItem;
  Ship: TShip;
  Quantity: Integer;
  i: Integer;
  StepIndex: Integer;
  PathStep: Integer;
  Index: Integer;
  AttackRound: Integer;
  ArtefactIndex: Integer;
  Count: Integer;
  EntryIndex: Integer;
  EntryCount: Integer;
  DestinationShipCount: Integer;
  CandidateIndex: Integer;
  CandidateCount: Integer;
  CombatGroup: Integer;
  WorkCount: Integer;
  NodeIndex: Integer;
  ClosestNodeIndex: Integer;
  PulledItemCount: Integer;
  MineralValue: Integer;
  AttackCount: Integer;
  ShotEndMargin: Integer;
  WorkValue: Single;
  WorkScale: Single;
  WearMultiplier: Single;
  Reserved113, Reserved114, Reserved115, Reserved116, Reserved117, Reserved118,
  Reserved119, Reserved120, Reserved121, Reserved122, Reserved123, Reserved124, Reserved125: Byte;
  Planet: TPlanet;
  Asteroid: TAsteroid;
  OwnerShip: TShip;
  GroupLeader: TShip;
  HitShip: TShip;
  NearestShip: TShip;
  OtherItem: TItem;
  NearestItem: TItem;
  Weapon: TWeapon;
  MovingDrop: PMovingDropItemEntry;
  CombatEvent: PStarCombatEvent;
  ExtraAttack: PStarCombatEvent;
  QueuedAttack: PStarCombatEvent;
  DamageColor: Cardinal;
  Damage: Cardinal;
  Reserved189: Byte;
  DrainedDamage: Integer;
  ObjectFilm: TEFilmObj;
  Distance: Single;
  Angle: Single;
  WorkX: Single;
  WorkY: Single;
  ImpactX: Single;
  ImpactY: Single;
  ClosestDistance: Single;
  Point: TPointF;
  Delta: TPointF;
  Node: PSPathNode;
  Effect: TObjectSE;
  EffectFilm: TEFilmObj;
  GateEntry: PJumpGateEntry;
  Target: Pointer;
  StoredTranclucator: Pointer;
  Tranclucator: TTranclucator;
  Reserved273: Byte;
  Hole: THole;
  CanPull: ShortInt;
  Reserved282, Reserved283: Byte;
  StationDestroyed: ShortInt;
  Missile: TMissile;
  InterceptedMissile: TMissile;
  Reserved293, Reserved294, Reserved295, Reserved296, Reserved297: Byte;
  BertorBoost: Boolean;
  RemainingAmmo: Integer;
  PickupIndex: Integer;
  PickupWeight: Integer;
  DeathEvent: Pointer;
  FilmText: WideString;
  NearestMissileDistance: Integer;
  MissileDistance: Integer;
  PointDefenseRangeSquared: Integer;
  BestMissilePriority: Integer;
  MissilePriority: Integer;
  Reserved341, Reserved342, Reserved343, Reserved344, Reserved345: Byte;
  ActionResult: Integer;
  HitFlags: TDamageFlagSet;
  Reserved357: Byte;
  Stage: Integer;
// @nested $7C67E4 CompleteItemPickup
procedure CompleteItemPickup; // @addr 0x7C67E4 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; item -4, ship -8, star -12, film flag -13. Transfers, merges or consumes the completed pickup; may free the item."
var Series: TDominatorSeries; ResearchCount, Index, PickupResult: Integer;
begin
  if Item.DestroyFlag > 0 then Exit;
  Ship.ApplyItemDegradation(Ship.GetCargoHook, idkUse, 3);
  Items.Delete(Items.IndexOf(Item));
  ClearItemReferences(Item);
  if Item is TArtefact then
  begin
    (Item as TEquipment).EquippedFlag := 0;
    Ship.Artefacts.Add(Item);
    if Item is TArtefactTranclucator then
      (TObject((Item as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := Ship;
  end
  else if Item is TCountableItem then
  begin
    TCountableItem(Item).DropFlag := 0;
    if not RecordFilm then Item.ReleaseGraphObject
    else
    begin
      PendingFilmObjectRemovals.Add(Item.FilmObject);
      ReleaseSpaceObject(Item.GraphObject);
    end;
    (Item as TEquipment).EquippedFlag := 0;
    Quantity := Ship.Inventory.Count;
    i := 0;
    while i < Quantity do
    begin
      if (Item as TCountableItem).CanMerge(Ship.Inventory[i]) then Break;
      Inc(i);
    end;
    if i < Quantity then
    begin
      TCountableItem(Ship.Inventory[i]).Merge(Item);
      Item.DestroyFlag := 1;
    end
    else
    begin
      Item.DestroyFlag := 0;
      Ship.Inventory.Add(Item);
    end;
  end
  else if Item is TEquipment then
  begin
    (Item as TEquipment).EquippedFlag := 0;
    if (Ship is TRuins) and (Item.ItemType in [t_Hull..t_CustomWeapon]) then
      (Ship as TRuins).EquipmentShop.Add(Item)
    else if (Ship is TWarrior) and ((Ship as TWarrior).WarriorType = wtFlagship) and
            (Item is TUselessItem) and (Item as TUselessItem).IsDominatorRemains then
    begin
      Series := TDominatorSeries(TEquipment(Item).DominatorSeries);
      if (Galaxy.DominatorResearch[Ord(Series)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Series) then
        Ship.SetMoney(Round(Item.Cost * 3.0) + Ship.Money)
      else Ship.SetMoney(Round(Item.Cost * 2.0) + Ship.Money);
      if (Galaxy.DominatorResearch[Ord(Series)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Series) then
        Inc(Galaxy.DominatorResearch[Ord(Series)].Material, Item.Weight)
      else
      begin
        ResearchCount := 0;
        for Series := dsBlazer to dsTerron do
          if (Galaxy.DominatorResearch[Ord(Series)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Series) then Inc(ResearchCount);
        if ResearchCount > 0 then
          for Series := dsBlazer to dsTerron do
            if (Galaxy.DominatorResearch[Ord(Series)].Progress < 100) and Galaxy.IsDominatorSeriesUnresolved(Series) then
              Inc(Galaxy.DominatorResearch[Ord(Series)].Material, Item.Weight div ResearchCount);
      end;
    end
    else Ship.Inventory.Add(Item);
  end
  else if Item is TGoods then
  begin
    if Ship is TRuins then
      Inc((Ship as TRuins).ShopGoods[Ord((Item as TGoods).ItemType)].Count, (Item as TGoods).Quantity)
    else
    begin
      Inc(Ship.CargoGoods[Ord((Item as TGoods).ItemType)].Count, (Item as TGoods).Quantity);
      Inc(Ship.CargoGoods[Ord((Item as TGoods).ItemType)].TotalCost, (Item as TGoods).Cost);
    end;
  end;
  Ship.RefreshDerivedStats(True);
  PickupResult := Ship.ScriptItemsAct(satOnItemPickUp, Item, nil, 0);
  if PickupResult <> 0 then
  begin
    if Item is TArtefact then
    begin
      Index := Ship.Artefacts.IndexOf(Item);
      if Index >= 0 then Ship.Artefacts.Delete(Index);
    end
    else
    begin
      Index := Ship.Inventory.IndexOf(Item);
      if Index >= 0 then Ship.Inventory.Delete(Index);
    end;
  end;
  if (Ship.CargoFreeSpace < 0) and (GetPlayer <> Ship) then
  begin
    Ship.AutoEquipInventory;
    Ship.ClearUnequippedWeaponTargets;
    Ship.DropCargoUntilNotOverloaded;
    Ship.AutoEquipInventory;
    Ship.ClearUnequippedWeaponTargets;
    if Ship.CargoFreeSpace <= 0 then Ship.ClearPickupTargets;
    Ship.RefreshDerivedStats(True);
  end
  else if (Item.ItemType in [t_FuelTanks..t_CustomWeapon]) and
          (PlayerAutomaticControl or ((GetPlayer <> Ship) and (Ship.TypeId <> stTranclucator))) then
  begin
    Ship.AutoEquipInventory;
    Ship.ClearUnequippedWeaponTargets;
    Ship.RefreshDerivedStats(True);
  end;
  if GetPlayer = Ship then InterruptLongTravel := True;
  if RecordFilm then
  begin
    PrimaryFilm.PlayPickupSound(StepIndex, Item.FilmObject);
    PrimaryFilm.DetachObject(StepIndex, Item.FilmObject);
  end;
  if (PickupResult < 0) or (Item is TGoods) or
     ((Ship is TWarrior) and ((Ship as TWarrior).WarriorType = wtFlagship) and
      (Item is TUselessItem) and (Item as TUselessItem).IsDominatorRemains) then
  begin
    if RecordFilm then PrimaryFilm.ReleaseObject(StepIndex, Item.FilmObject);
    Item.Free;
  end
  else if (Item is TCountableItem) and (Item.DestroyFlag > 0) then Item.Free
  else if RecordFilm and (Item.GraphObject <> nil) then
  begin
    ReleaseSpaceObject(Item.GraphObject);
    PrimaryFilm.ReleaseObject(StepIndex, Item.FilmObject);
  end;
  if Ship.Speed <= 0 then Ship.MovementPath.Clear;
end;
begin
  Stage := 0;
  try
    Self.RefreshMovementStepParameters;
    if (GetPlayer <> nil) and (GetPlayer.CurrentStar = Self) then
    begin
      Self.DaysSincePlayerVisit := 0;
      GetPlayer.BombKillsThisTurn := 0;
      if Self.PlayerPresenceLevel < 90 then
        Inc(Self.PlayerPresenceLevel);
    end
    else
    begin
      Inc(Self.DaysSincePlayerVisit);
      if Self.PlayerPresenceLevel > 0 then
        Dec(Self.PlayerPresenceLevel);
    end;
    if not Globals.PlayerStarDayPrepared then
      Inc(Self.DaysSinceLastNpcShipSpawn);
    Self.RecordingTurnFilm := RecordFilm;
    Self.PlayerCombatOccurred := False;
    Self.InterruptLongTravel := False;
    Self.KeepFilmRunning := False;
    StepIndex := 0;
    Self.CurrentStepIndex := 0;

    Stage := 1;
    if not Globals.PlayerStarDayPrepared then
      Self.TryGenerateSystemNews;

    Stage := 2;
    if not Globals.PlayerStarDayPrepared and (Galaxy.StasisModEnabled <> 1) then
      for Index := 0 to (Self.Asteroids.Count - 1) do
      begin
        Asteroid := Self.Asteroids[Index];
        Asteroid.RespawnIfOutsideSystem;
      end;

    Stage := 3;
    if WingmenPendingLeadershipPenalty = nil then
      WingmenPendingLeadershipPenalty := TList.Create;
    if not Globals.PlayerStarDayPrepared then
    begin
      for Index := (Self.Ships.Count - 1) downto 0 do
      begin
        Ship := Self.Ships[Index];
        Ship.RefreshCurrentStanding;
      end;
      for Index := (Self.Ships.Count - 1) downto 0 do
      begin
        Ship := Self.Ships[Index];
        if (Galaxy.StasisModEnabled <> 1) or (GetPlayer = Ship) then
          Ship.NextDay;
        if (Ship.PartnerShip <> nil)
          and ((Ship.PartnershipDaysRemaining > 0)
          and (WingmenPendingLeadershipPenalty.IndexOf(Ship) < 0)) then
          WingmenPendingLeadershipPenalty.Add(Ship);
      end;
    end;

    Stage := 4;
    Self.ProcessItemScripts(0);

    Stage := 5;
    for Index := 0 to (Self.Ships.Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if (Ship.Order = soLand) and ((TObject(Ship.OrderTarget) is TShip)
        and ((TObject(Ship.OrderTarget) as TShip).Order <> soNone)) then
      begin
        if (TObject(Ship.OrderTarget) as TShip).Order <> soTeleport then
          (TObject(Ship.OrderTarget) as TShip).OrderNone(False)
        else
          Ship.OrderNone(False);
      end
      else
      begin
        if (Ship.Order = soTakeoff) and ((Ship.DockedTo <> nil)
          and ((Ship.DockedTo.Order <> soNone) and (Ship.DockedTo.Order <> soTeleport))) then
          Ship.DockedTo.OrderNone(False);
      end;
    end;

    Stage := 6;
    if RecordFilm then
    begin
      PrimaryFilm.SystemProcessName := WideString(Self.SystemProcessName);
      PrimaryFilm.MapDiameter := Self.ComputeMapDiameter;
      PrimaryFilm.StarGenerationSeed := Self.GenerationSeed;
      PrimaryFilm.BackgroundImage := Cardinal(Self.BackgroundImage);
      PrimaryFilm.Turn := Galaxy.CurrentTurn;
      PrimaryFilm.RadarRange := 0;
      Stage := 60;
      if GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar) then
        PrimaryFilm.RadarRange := GetPlayer.GetRadarRange;
      Stage := 61;
      ObjectFilm := PrimaryFilm.AddObject(Integer(Self.Id), Self.Graphic);
      PrimaryFilm.SetObjectPosition(StepIndex, ObjectFilm, MakePointF(0.0, 0.0));
      PrimaryFilm.AttachObject(StepIndex, ObjectFilm);
      Stage := 62;
      (TObject(PrimaryFilm.ObjectInfo) as TEObjInfo).LoadFromStar(Self);
    end;

    Stage := 7;
    if (Galaxy.KellerMissionState = 2)
      and ((Galaxy.KellerTargetStar = Self)
      and ((aKling.KellerShip <> nil) and ((aKling.KellerShip.CurrentStar = Self) and (Galaxy.StasisModEnabled <> 1)))) then
      aKling.KellerShip.OpenKellerMissionHole;
    if (Galaxy.KellerMissionState = 4)
      and ((aKling.KellerShip <> nil)
      and ((aKling.KellerShip.CurrentStar = Self)
      and ((Ord(aKling.KellerShip.InHyperspace) <> 0) and (Galaxy.StasisModEnabled <> 1)))) then
    begin
      Hole := Galaxy.FindHoleInStarByKind(Self, 4);
      if Hole = nil then
        raise Exception.Create('Hole not found');
      aKling.KellerShip.Order := soJump;
      aKling.KellerShip.OrderTarget := aKling.KellerShip.CurrentStar;
      aKling.KellerShip.OrderAbsolute := False;
      aKling.KellerShip.OrderDestination := MakePointF(0.0, 0.0);
      aKling.KellerShip.OrderStateData := 2;
      Galaxy.KellerMissionState := 5;
    end;

    Stage := 8;
    Count := Self.Ships.Count;
    for Index := 0 to (Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if not Ship.IsOutsideStarSpace and ((Galaxy.StasisModEnabled <> 1) or (GetPlayer = Ship))
        and ((Ship.TypeId <> stKling) or (((Ship as TKling).ActiveProgramAppliedTurn <= 0)
        or not (Byte((Ship as TKling).ActiveProgramId) in [7, 11]))) then
      begin
        for AttackRound := 1 to Ship.GetAttackMultiplier do
        begin
          for EntryIndex := 1 to Ship.WeaponCount do
          begin
            Weapon := Ship.Weapons[EntryIndex];
            if Weapon.Target <> nil then
            begin
              if (TObject(Weapon.Target) is TItem)
                or ((TObject(Weapon.Target) is TAsteroid)
                or ((TObject(Weapon.Target) is TMissile) or (TObject(Weapon.Target) is TShip)
                and (TObject(Weapon.Target) as TShip).InNormalSpace)) then
              begin
                CombatEvent := AllocEC(SizeOf(CombatEvent^));
                CombatEvent^.Attacker := Ship;
                CombatEvent^.Target := Weapon.Target;
                CombatEvent^.Weapon := Weapon;
                CombatEvent^.CombatGroup := 0;
                if Self.MovementStepCount = BaseMovementStepsPerTurn then
                  ShotEndMargin := 30
                else
                  ShotEndMargin := 1;
                CombatEvent^.StepIndex := Integer(System.Round(Weapon.GetShotDelayFactor * (Self.MovementStepCount - ShotEndMargin)));
                if (GetPlayer = Ship) or (GetPlayer = CombatEvent^.Target) then
                  Self.PlayerCombatOccurred := True;
                Quantity := Self.CombatEvents.Count;
                i := 0;
                while i < Quantity do
                begin
                  QueuedAttack := Self.CombatEvents[i];
                  if CombatEvent^.StepIndex < QueuedAttack^.StepIndex then
                    Break;
                  Inc(i);
                end;
                if i >= Quantity then
                begin
                  Self.CombatEvents.Add(CombatEvent);
                  if (Weapon.GetAttackCount > 1)
                    and not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) then
                  begin
                    for CandidateIndex := 2 to Weapon.GetAttackCount do
                    begin
                      ExtraAttack := AllocEC(SizeOf(ExtraAttack^));
                      ExtraAttack^.Attacker := Ship;
                      ExtraAttack^.Target := Weapon.Target;
                      ExtraAttack^.Weapon := Weapon;
                      ExtraAttack^.CombatGroup := 0;
                      ExtraAttack^.StepIndex := CombatEvent^.StepIndex;
                      Self.CombatEvents.Add(ExtraAttack);
                    end;
                  end;
                end
                else
                begin
                  Self.CombatEvents.Insert(i, CombatEvent);
                  if (Weapon.GetAttackCount > 1)
                    and not (Weapon.GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket]) then
                  begin
                    for CandidateIndex := 2 to Weapon.GetAttackCount do
                    begin
                      ExtraAttack := AllocEC(SizeOf(ExtraAttack^));
                      ExtraAttack^.Attacker := Ship;
                      ExtraAttack^.Target := Weapon.Target;
                      ExtraAttack^.Weapon := Weapon;
                      ExtraAttack^.CombatGroup := 0;
                      ExtraAttack^.StepIndex := CombatEvent^.StepIndex;
                      Self.CombatEvents.Insert(i, ExtraAttack);
                    end;
                  end;
                end;
                if Ship.TypeId <> stKling then
                begin
                  if (GetPlayer = Ship) and Ship.IsHealthEffectActive(10) then
                    WearMultiplier := 3.0
                  else
                    WearMultiplier := 1.0;
                  Ship.ApplyItemDegradation(Weapon, idkUse, NextRandomUnitFloat(Ship.RandomState) * 2.0 * WearMultiplier);
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    Stage := 9;
    if RecordFilm then
    begin
      CombatGroup := 0;
      Count := Self.CombatEvents.Count;
      for Index := 0 to (Count - 1) do
      begin
        CombatEvent := Self.CombatEvents[Index];
        if CombatEvent^.CombatGroup = 0 then
        begin
          Inc(CombatGroup);
          CombatEvent^.CombatGroup := CombatGroup;
          Self.MarkConnectedCombatEvents(Self.CombatEvents, TShip(CombatEvent^.Attacker), CombatGroup);
          Self.MarkConnectedCombatEvents(Self.CombatEvents, CombatEvent^.Target, CombatGroup);
        end;
      end;
      for Index := 1 to CombatGroup do
      begin
        Quantity := 0;
        for EntryIndex := 0 to (Count - 1) do
        begin
          CombatEvent := Self.CombatEvents[EntryIndex];
          if CombatEvent^.CombatGroup = Index then
            Inc(Quantity);
        end;
        WorkValue := 5.0;
        WorkScale := 170.0 / Quantity;
        for EntryIndex := 0 to (Count - 1) do
        begin
          CombatEvent := Self.CombatEvents[EntryIndex];
          if CombatEvent^.CombatGroup = Index then
          begin
            CombatEvent^.StepIndex := Integer(System.Round(WorkValue));
            WorkValue := WorkValue + WorkScale;
          end;
        end;
      end;
    end;

    Stage := 10;
    Count := Self.Ships.Count;
    for Index := 0 to (Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if not Ship.InHyperspace then
      begin
        if Ship.Order <> soFollowShip then
          Ship.BuildOrderMovementPath(Self.MovementStepCount)
        else
        begin
          Ship.ClearMovementPath;
          Ship.OrderDestination := Ship.Position;
          if Ship.GetEffectiveFollowMode = 0 then
          begin
            Angle := HeadingDegreesToRadians(Abs(Integer(Cardinal(Galaxy.CurrentTurn) * (Ship.Seed * Cardinal((TObject(Ship.OrderTarget) as TShip).Seed)))) mod 360);
            WorkCount := Ship.CalculateFollowRadius;
            Ship.RepulsionPosition.X := System.Sin(Angle) * WorkCount;
            Ship.RepulsionPosition.Y := System.Cos(Angle) * -WorkCount;
          end;
        end;
      end;
    end;

    Stage := 11;
    Count := Self.MovementStepCount;
    Self.SimulationStepCount := Cardinal(Count);
    EntryCount := Self.Ships.Count;
    for PathStep := 0 to (Count - 1) do
    begin
      for EntryIndex := 0 to (EntryCount - 1) do
      begin
        Ship := Self.Ships[EntryIndex];
        if Ship.Order = soFollowShip then
        begin
          OwnerShip := TObject(Ship.OrderTarget) as TShip;
          PickupWeight := 0;
          if (GetPlayer = OwnerShip) and ((OwnerShip.PickupTargets <> nil) and OwnerShip.InNormalSpace) then
            for PickupIndex := 0 to (OwnerShip.PickupTargets.Count - 1) do
            begin
              if OwnerShip.IsItemInPickupRange(OwnerShip.PickupTargets[PickupIndex]) then
                PickupWeight := PickupWeight + TItem(OwnerShip.PickupTargets[PickupIndex]).Weight;
            end;
          if (OwnerShip.Order <> soFollowShip) or (OwnerShip.CargoFreeSpace < PickupWeight) then
          begin
            if OwnerShip.IsOnPlanet and (OwnerShip.Order = soNone) then
            begin
              if (Ship is TTranclucator)
                and (TTranclucator(Ship).CanFollowOwnerInCurrentStar
                and (TTranclucator(Ship).OwnerShip = OwnerShip)) then
                Point := TPlanet(OwnerShip.CurrentPlanet).PredictPosition(Self.MovementStepCount)
              else
                Point := TPlanet(OwnerShip.CurrentPlanet).GetPosition;
            end
            else
            begin
              if OwnerShip.IsDockedToShip and (OwnerShip.Order = soNone) then
                Point := OwnerShip.DockedTo.Position
              else
              begin
                if (OwnerShip.MovementPath.ActiveTail = nil) or (OwnerShip.CargoFreeSpace < PickupWeight) then
                  Point := OwnerShip.Position
                else
                  Point := OwnerShip.MovementPath.ActiveTail^.Position;
              end;
            end;
          end
          else
            Point := OwnerShip.OrderDestination;
          if (Galaxy.StasisModEnabled = 1) and (GetPlayer = Ship) then
            Point := OwnerShip.Position;
          if (Ship.GetEffectiveFollowMode = 0)
            and ((Ship is TTranclucator)
            and (Ship as TTranclucator).CanFollowOwnerInCurrentStar) then
          begin
            Ship.OrderDestination := Point;
            WorkValue := 0.0;
          end
          else
          begin
            WorkCount := Ship.CalculateFollowRadius;
            WorkScale := Ship.MovementSpeed * 200.0 * Self.MovementStepScale;
            if Ship.GetEffectiveFollowMode = 0 then
            begin
              Point.X := Point.X + Ship.RepulsionPosition.X;
              Point.Y := Point.Y + Ship.RepulsionPosition.Y;
              Distance := PointDistance(Ship.OrderDestination, Point);
              WorkValue := 0.0 - Distance;
            end
            else
            begin
              Distance := PointDistance(Ship.OrderDestination, Point);
              WorkValue := WorkCount - Distance;
            end;
            if Distance <> 0.0 then
            begin
              if WorkValue <= 0.0 then
              begin
                WorkValue := Min(-WorkValue, WorkScale) / Distance;
                Delta.X := (Point.X - Ship.OrderDestination.X) * WorkValue;
                Delta.Y := (Point.Y - Ship.OrderDestination.Y) * WorkValue;
              end
              else
              begin
                WorkValue := Min(WorkValue, WorkScale) / Distance;
                Delta.X := (Ship.OrderDestination.X - Point.X) * WorkValue;
                Delta.Y := (Ship.OrderDestination.Y - Point.Y) * WorkValue;
              end;
              Distance := Self.MapDiameter / 2.0;
              WorkScale := Ship.OrderDestination.X * Ship.OrderDestination.X + Ship.OrderDestination.Y * Ship.OrderDestination.Y;
              if (Sqr(0.7 * Distance) < WorkScale)
                and ((Delta.X * Ship.OrderDestination.X + Delta.Y * Ship.OrderDestination.Y > 0.0)
                and ((TShip(Ship.OrderTarget).Order = soFollowShip)
                and (TShip(Ship.OrderTarget).OrderDestination.X * TShip(Ship.OrderTarget).OrderDestination.X + TShip(Ship.OrderTarget).OrderDestination.Y * TShip(Ship.OrderTarget).OrderDestination.Y <= WorkScale))) then
              begin
                Angle := HeadingDegreesToRadians(RemapClamped(System.Sqrt(WorkScale) - 0.7 * Distance, 0.0, 0.5 * Distance, 0.0, 45.0));
                if Delta.X * Ship.OrderDestination.Y - Delta.Y * Ship.OrderDestination.X > 0.0 then
                  Angle := -Angle;
                Point := Delta;
                WorkX := System.Sin(Angle);
                WorkY := System.Cos(Angle);
                Delta.X := Point.X * WorkY - Point.Y * WorkX;
                Delta.Y := Point.X * WorkX + Point.Y * WorkY;
              end;
              Ship.OrderDestination.X := Ship.OrderDestination.X + Delta.X;
              Ship.OrderDestination.Y := Ship.OrderDestination.Y + Delta.Y;
            end;
          end;
        end;
      end;
    end;

    Stage := 12;

    Stage := 13;
    if RecordFilm then
    begin
      for EntryIndex := 0 to (EntryCount - 1) do
      begin
        Ship := Self.Ships[EntryIndex];
        if Ship.Order = soFollowShip then
          Ship.RepulsionPosition := Ship.Position;
      end;
      for PathStep := 1 to (Count - 1) do
      begin
        for EntryIndex := 0 to (EntryCount - 1) do
        begin
          Ship := Self.Ships[EntryIndex];
          if (Ship.Order in [soMove, soFollowShip])
            and ((not (Ship is TTranclucator) or (Ord(TTranclucator(Ship).FollowOwner) = 0))
            and (not (Ship is TKling)
            or (((Ship as TKling).KlingType <> ktBoss) or ((Ship as TKling).DominatorSeries <> dsTerron)))) then
          begin
            WorkScale := Ship.MovementSpeed;
            if (Galaxy.StasisModEnabled = 1) and (GetPlayer <> Ship) then
              WorkScale := 0.0;
            Distance := PointDistanceSquared(Ship.RepulsionPosition, Ship.OrderDestination);
            if Distance <> 0.0 then
            begin
              if Sqr(WorkScale) >= Distance then
                Ship.RepulsionPosition := Ship.OrderDestination
              else
              begin
                Distance := 1.0 / System.Sqrt(Distance) * WorkScale;
                Ship.RepulsionPosition.X := (Ship.OrderDestination.X - Ship.RepulsionPosition.X) * Distance + Ship.RepulsionPosition.X;
                Ship.RepulsionPosition.Y := (Ship.OrderDestination.Y - Ship.RepulsionPosition.Y) * Distance + Ship.RepulsionPosition.Y;
              end;
              if Galaxy.StasisModEnabled <> 1 then
                Ship.RepelFollowingShips;
            end;
          end;
        end;
      end;
      for EntryIndex := 0 to (EntryCount - 1) do
      begin
        Ship := Self.Ships[EntryIndex];
        if (Ship.Order = soFollowShip) and (not (Ship is TTranclucator)
          or (Ord(TTranclucator(Ship).FollowOwner) = 0))
          and (not (Ship is TKling)
          or (((Ship as TKling).KlingType <> ktBoss) or ((Ship as TKling).DominatorSeries <> dsTerron))) then
          Ship.OrderDestination := Ship.RepulsionPosition;
      end;
    end;

    Stage := 14;
    Count := Self.Ships.Count;
    for Index := 0 to (Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if Ship.Order = soFollowShip then
      begin
        if (Sqr(Ship.Position.X) + Sqr(Ship.Position.Y) > Sqr(Self.SafeRadius))
          and (Sqr(Ship.OrderDestination.X) + Sqr(Ship.OrderDestination.Y) < Sqr(Self.SafeRadius)) then
        begin
          RayIntersectsOriginCircle(Ship.Position, Ship.OrderDestination, Point, Self.SafeRadius);
          WorkValue := PointDistance(Point, Ship.OrderDestination);
          WorkScale := HeadingDegreesToRadians(WorkValue * 360.0 / (2 * Pi * Self.SafeRadius));
          WorkValue := Math.ArcTan2(Point.X, -Point.Y);
          if HeadingDifferenceDegrees(RadiansToHeadingDegrees(WorkValue), RadiansToHeadingDegrees(Math.ArcTan2(Ship.Position.X - Point.X, -(Ship.Position.Y - Point.Y)))) < 0.0 then
            WorkValue := WorkValue + WorkScale
          else
            WorkValue := WorkValue - WorkScale;
          Ship.OrderDestination.X := System.Sin(WorkValue) * (Self.SafeRadius + 0.1);
          Ship.OrderDestination.Y := -System.Cos(WorkValue) * (Self.SafeRadius + 0.1);
        end;
        Ship.RebuildMovePath;
      end;
    end;

    Stage := 15;
    Count := Self.Ships.Count;
    for Index := 0 to (Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if (Ship.Order = soJump) and (Ship.TypeId = stRanger) then
      begin
        if Ship.MovementPath.ActiveHead <> nil then
        begin
          if Sqr(Ship.Speed + 100) < PointDistanceSquared(Ship.MovementPath.ActiveHead^.Position, Ship.MovementPath.ActiveTail^.Position) then
          begin
            GroupLeader := (Ship as TRanger).PartnerShip;
            if GroupLeader = nil then
              GroupLeader := Ship;
            for EntryIndex := 0 to (Count - 1) do
            begin
              OwnerShip := Self.Ships[EntryIndex];
              if (OwnerShip.Order = soJump) and (OwnerShip.OrderTarget = Ship.OrderTarget) and (OwnerShip.TypeId = stRanger)
                and (Ship <> OwnerShip) then
              begin
                if ((OwnerShip as TRanger).PartnerShip = GroupLeader) or (OwnerShip = GroupLeader) then
                begin
                  if (OwnerShip.MovementPath.ActiveHead = nil)
                    or (Sqr(OwnerShip.Speed + 100) >= PointDistanceSquared(OwnerShip.MovementPath.ActiveHead^.Position, OwnerShip.MovementPath.ActiveTail^.Position)) then
                  begin
                    if ((OwnerShip.PickupTargets = nil) or (OwnerShip.PickupTargets.Count <= 0))
                      and (PointDistanceSquared(Ship.Position, OwnerShip.Position) <= 640000.0) then
                    begin
                      Angle := Abs(HeadingDifferenceDegrees(OwnerShip.MovementDirection, RadiansToHeadingDegrees(Math.ArcTan2(-Ship.Position.X, Ship.Position.Y))));
                      if (Angle >= 90.0) and (OwnerShip.Speed >= 200) or (Angle >= 175.0) then
                      begin
                        OwnerShip.ClearMovementPath;
                        if (Angle < 175.0) and ((OwnerShip.Speed >= 200)
                          and (OwnerShip.CurrentStar = PlayerStar)) then
                        begin
                          Distance := 1.0 / System.Sqrt(Ship.Position.X * Ship.Position.X + Ship.Position.Y * Ship.Position.Y);
                          Point.X := Ship.Position.X * Distance * 10000.0 + OwnerShip.Position.X;
                          Point.Y := Ship.Position.Y * Distance * 10000.0 + OwnerShip.Position.Y;
                          OwnerShip.AppendTurningPath(Point, False, BaseMovementStepsPerTurn);
                        end;
                        OwnerShip.AppendHyperspaceTransitionPath(1.0);
                        if OwnerShip.MovementPath.ActiveTail <> nil then
                          OwnerShip.OrderDestination := OwnerShip.MovementPath.ActiveTail^.Position
                        else
                          OwnerShip.OrderDestination := OwnerShip.Position;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    Stage := 16;
    if PlayerStar = Self then
      Self.AvoidShipPathCollisions;

    Stage := 17;
    if RecordFilm then
    begin
      EntryCount := Galaxy.JumpGates.Count;
      for Index := 0 to (EntryCount - 1) do
      begin
        GateEntry := Galaxy.JumpGates[Index];
        GateEntry^.UsedThisTurn := True;
        ObjectFilm := PrimaryFilm.AddObject(0, GateEntry^.Gate);
        GateEntry^.GateFilmId := Cardinal(ObjectFilm);
        PrimaryFilm.SetObjectPosition(StepIndex, ObjectFilm, GateEntry^.Gate.Position);
        PrimaryFilm.SetObjectAngle(StepIndex, ObjectFilm, GateEntry^.Gate.GetAngle);
        PrimaryFilm.SetGateSize(StepIndex, ObjectFilm, GateEntry^.Gate.Size.X);
        PrimaryFilm.SetGateState(StepIndex, ObjectFilm, 2);
        PrimaryFilm.CloseGate(StepIndex, ObjectFilm);
        PrimaryFilm.SetObjectText(StepIndex, ObjectFilm, GateEntry^.Gate.GetText);
        PrimaryFilm.AttachObject(StepIndex, ObjectFilm);
        if (GateEntry^.Effect <> nil) and TObjectSE(GateEntry^.Effect).IsAttachedToSpace then
        begin
          ObjectFilm := PrimaryFilm.AddObject(0, GateEntry^.Effect);
          GateEntry^.EffectFilmId := Cardinal(ObjectFilm);
          PrimaryFilm.SetObjectPosition(StepIndex, ObjectFilm, GateEntry^.Effect.Position);
          PrimaryFilm.SetObjectAngle(StepIndex, ObjectFilm, GateEntry^.Effect.GetAngle);
          PrimaryFilm.SetGateSize(StepIndex, ObjectFilm, GateEntry^.Effect.Size.X);
          PrimaryFilm.AttachObject(StepIndex, ObjectFilm);
        end;
      end;
    end;

    Stage := 18;
    if RecordFilm then
    begin
      for Index := 0 to Galaxy.Holes.Count - 1 do
      begin
        Hole := Galaxy.Holes[Index];
        if Hole.Star1 = Self then
        begin
          EffectFilm := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
          Hole.FilmObjectId := Integer(EffectFilm);
          PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Hole.Position1);
          if Galaxy.CurrentTurn = Hole.CreatedTurn then
            PrimaryFilm.SetHoleState(StepIndex, EffectFilm, 1)
          else PrimaryFilm.SetHoleState(StepIndex, EffectFilm, 0);
          PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        end
        else if Hole.Star2 = Self then
        begin
          EffectFilm := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
          Hole.FilmObjectId := Integer(EffectFilm);
          PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Hole.Position2);
          if Galaxy.CurrentTurn = Hole.CreatedTurn then
            PrimaryFilm.SetHoleState(StepIndex, EffectFilm, 1)
          else PrimaryFilm.SetHoleState(StepIndex, EffectFilm, 0);
          PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        end;
      end;
    end;

    Stage := 19;
    for Index := 0 to (Self.Planets.Count - 1) do
    begin
      Planet := Self.Planets[Index];
      Planet.InitializeFilmState(StepIndex, RecordFilm);
    end;

    Stage := 20;
    for Index := 0 to (Self.Asteroids.Count - 1) do
    begin
      Asteroid := Self.Asteroids[Index];
      Asteroid.PrepareTurnMovement(StepIndex, RecordFilm);
    end;

    Stage := 21;
    for Index := 0 to (Self.Ships.Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if (Galaxy.StasisModEnabled <> 1) or (GetPlayer = Ship) then
      begin
        if Ship.GetHull.InterceptorsEnabled then
          Ship.LaunchInterceptors;
        Ship.GetHull.InterceptorTarget := nil;
        if Ship.AfterburnerActive then
        begin
          if Ship.IsEquipmentUsable(Ship.GetEngine) and (Ship.GetSlotCount(sskAfterburner) > 0) then
            Ship.ApplyAfterburnerItemDegradation;
        end;
      end;
    end;

    Stage := 22;
    for Index := 0 to (Self.Ships.Count - 1) do
      TShip(Self.Ships[Index]).PrepareTurnMovement(StepIndex, RecordFilm);

    Stage := 23;
    for Index := 0 to (Self.Missiles.Count - 1) do
    begin
      Missile := TMissile(Self.Missiles.List^[Index]);
      Missile.PrepareTurnMovement(StepIndex, RecordFilm, False);
    end;

    Stage := 24;
    if RecordFilm then
    begin
      Count := Self.Items.Count;
      for Index := 0 to (Count - 1) do
      begin
        Item := Self.Items[Index];
        Item.FilmObject := PrimaryFilm.AddObject(Item.Id, Item.GetGraphObject);
        PrimaryFilm.SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
        PrimaryFilm.AttachObject(StepIndex, Item.FilmObject);
      end;
    end;

    Stage := 25;
    Count := Self.MovementStepCount;
    PrimaryFilm.AdvanceObjects(StepIndex);
    Inc(StepIndex);
    Self.CurrentStepIndex := StepIndex;

    Stage := 26;
    if RecordFilm then
    begin
      if not Self.PlayerCombatOccurred or (GetPlayer.MovementPath.ActiveTail <> nil)
        and not (GetPlayer.Speed * GetPlayer.Speed + 100 >= PointDistanceSquared(GetPlayer.Position, GetPlayer.MovementPath.ActiveTail^.Position)) or (GetPlayer.Order = soLand)
        and (GetPlayer.FilmAlphaStep <> 0.0) then
        Self.PlayerFilmPath := nil
      else
      begin
        Self.PlayerFilmPath := TSPath.Create;
        TSPath(Self.PlayerFilmPath).AppendWaypoint(GetPlayer.Position, StepIndex);
      end;
    end;

    Stage := 27;
    EntryIndex := 0;
    while Self.Items.Count > EntryIndex do
    begin
      Item := Self.Items[EntryIndex];
      if Self.DamageRadius * Self.DamageRadius > Sqr(Item.Position.X) + Sqr(Item.Position.Y) then
      begin
        Self.ClearItemReferences(Item);
        if RecordFilm then
        begin
          CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
          PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, nil, Item.FilmObject);
          PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, True, True);
          PrimaryFilm.AttachObject(StepIndex, EffectFilm);
          ReleaseSpaceObject(Item.GraphObject);
          Self.PendingFilmObjectRemovals.Add(Item.FilmObject);
        end;
        Self.Items.Delete(EntryIndex);
        Item.Free;
      end
      else
        Inc(EntryIndex);
    end;

    Stage := 28;
    NearestShip := nil;
    NearestItem := nil;
    WorkValue := 1.0e20;
    for Index := 0 to (Self.Ships.Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if Ship.PickupTargets <> nil then
      begin
        if Ship.GetCargoHook = nil then
          Ship.ClearPickupTargets
        else
        begin
          Item := Ship.PickupTargets[0];
          WorkScale := PointDistanceSquared(Ship.Position, Item.Position);
          if WorkScale < WorkValue then
          begin
            WorkValue := WorkScale;
            NearestShip := Ship;
            NearestItem := Item;
          end;
        end;
      end;
    end;

    Stage := 29;
    Self.PlayerCombatOccurred := False;
    for PathStep := 0 to (Count - 1) do
    begin
      EntryIndex := 0;
      Stage := 2900;
      if Galaxy.StasisModEnabled <> 1 then
      begin
        while Self.Missiles.Count > EntryIndex do
        begin
          Missile := TMissile(Self.Missiles.List^[EntryIndex]);
          if Missile.DestroyQueued then
          begin
            Inc(EntryIndex);
            Continue;
          end;
          Stage := 2901;
          Target := Missile.StepDay(StepIndex, RecordFilm);
          if Target = nil then
          begin
            Inc(EntryIndex);
            Continue;
          end;
          HitShip := nil;
          Stage := 2902;
          if (GetPlayer = Missile.OwnerShip)
            and ((TObject(Target) is TGoods) and (Ord((TObject(Target) as TGoods).NaturalFlag) <> 0)) then
          begin
            Item := TObject(Target) as TItem;
            if GetPlayer.ScriptItemsAct(satOnMissileHittingObject, Item, Missile, 1) = 0 then
            begin
              Inc(EntryIndex);
              Continue;
            end;
            if RecordFilm then
            begin
              Effect := TWeaponSE.Create(Missile.GetWeaponInfo^.AreaSE, Classes.Point(0, 0), Missile.GetShotVisual, -1);
              EffectFilm := PrimaryFilm.AddObject(0, Effect);
              PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Item.Position);
              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
              PrimaryFilm.DetachObject(StepIndex, Missile.FilmObject);
              Self.PendingFilmObjectRemovals.Add(Missile.FilmObject);
              ReleaseSpaceObject(Missile.Graphic);
              PrimaryFilm.DetachObject(StepIndex, Item.FilmObject);
            end;
            Self.ClearItemReferences(Item);
            Quantity := (Item as TGoods).Quantity;
            if Quantity >= 5 then
              Self.DropMinerals(Integer(Trunc(Quantity * 0.8 / Missile.GetWeaponInfo^.MiningFactor)),
                Item.Position, Self.GenerationSeed * Cardinal(Item.Id));
            Point := Item.Position;
            if RecordFilm then
            begin
              Self.PendingFilmObjectRemovals.Add(Item.FilmObject);
              ReleaseSpaceObject(Item.GraphObject);
              Self.Items.Delete(Self.Items.IndexOf(Item));
              Item.Free;
            end
            else
            begin
              Self.Items.Delete(Self.Items.IndexOf(Item));
              Item.Free;
            end;
          end
          else
            if TObject(Target) is TItem then
            begin
              Stage := 2903;
              Item := TObject(Target) as TItem;
              if (Missile.OwnerShip <> nil)
                and (Missile.OwnerShip.ScriptItemsAct(satOnMissileHittingObject, Item, Missile, 1) = 0) then
              begin
                Inc(EntryIndex);
                Continue;
              end
              else
              begin
                ActionResult := 0;
                if Item.DestroyFlag = 0 then
                  Item.DestroyFlag := 1;
                if Item.ScriptItem <> nil then
                  ActionResult := TScriptItem(Item.ScriptItem).RunActionCode(satOnItemHit, Missile.OwnerShip, Missile, Self, ActionResult);
                if Item is TEquipmentWithActCode then
                  ActionResult := RunItemConfigActionCode(Item, satOnItemHit, Missile.OwnerShip, Missile, Self, ActionResult);
                if (Item.DestroyFlag < 0) and (Missile.Target <> Item) then
                begin
                  Inc(EntryIndex);
                  Inc(Item.DestroyFlag);
                  Continue;
                end
                else
                begin
                  if RecordFilm then
                  begin
                    Effect := TWeaponSE.Create(Missile.GetWeaponInfo^.AreaSE, Classes.Point(0, 0), Missile.GetShotVisual, -1);
                    EffectFilm := PrimaryFilm.AddObject(0, Effect);
                    PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Item.Position);
                    PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0,
                      (Item.ItemType = t_ArtefactBomb) and (Item.DestroyFlag >= 0), True);
                    if ((Item.ItemType = t_ArtefactBomb) or (Item is TCistern)
                      and ((Item as TCistern).Fuel > 0)) and (Item.DestroyFlag > 0) then
                      PrimaryFilm.SetDestructionEffect(StepIndex, EffectFilm, 1);
                    PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                    PrimaryFilm.DetachObject(StepIndex, Missile.FilmObject);
                    Self.PendingFilmObjectRemovals.Add(Missile.FilmObject);
                    ReleaseSpaceObject(Missile.Graphic);
                  end;
                  Stage := 2904;
                  if Item.DestroyFlag >= 0 then
                  begin
                    if RecordFilm then
                      PrimaryFilm.DetachObject(StepIndex, Item.FilmObject);
                    for i := 0 to (Self.MovingDropItems.Count - 1) do
                    begin
                      MovingDrop := Self.MovingDropItems[i];
                      if MovingDrop^.Payload = Item then
                        MovingDrop^.Payload := nil;
                    end;
                    Self.ClearItemReferences(Item);
                  end;
                  Stage := 2905;
                  if (Item.ItemType = t_ArtefactBomb) or (Item is TCistern)
                    and ((Item as TCistern).Fuel > 0) or (ActionResult <> 0) then
                  begin
                    CandidateCount := Self.Ships.Count;
                    for CandidateIndex := 0 to (CandidateCount - 1) do
                    begin
                      Ship := Self.Ships[CandidateIndex];
                      if Ship.InNormalSpace and (not Ship.IsHullDestroyed
                        and ((GetPlayer <> Ship) or (Galaxy.GodModEnabled <> 1)
                        and (Galaxy.SpecialSimulationMode = 0))) then
                      begin
                        Distance := PointDistanceSquared(Ship.Position, Item.Position);
                        if aConst.ItemExplosionRadiusSquared >= Distance then
                        begin
                          Damage := Cardinal(Ship.ApplyExplosionDamage(Missile.OwnerShip, Item, ActionResult,
                            Missile));
                          if Ship.IsHullDestroyed and ((GetPlayer <> nil)
                            and ((Item.ItemType = t_ArtefactBomb) and (GetPlayer = Missile.OwnerShip))) then
                            Inc(GetPlayer.BombKillsThisTurn);
                          DamageColor := GR_Main.CurrentPixelFormat.PackRgbBytes(255, 0, 0);
                          if RecordFilm then
                          begin
                            CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
                            PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
                            PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                              Word(DamageColor), Integer(Damage), Ship.IsHullDestroyed, True);
                            PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                          end;
                        end;
                      end;
                    end;
                    CandidateCount := Self.Items.Count;
                    for CandidateIndex := 0 to (CandidateCount - 1) do
                    begin
                      OtherItem := Self.Items[CandidateIndex];
                      if OtherItem <> Item then
                      begin
                        Distance := PointDistanceSquared(OtherItem.Position, Item.Position);
                        if aConst.ItemExplosionRadiusSquared >= Distance then
                        begin
                          if 20.0 - 20.0 * Distance / aConst.ItemExplosionRadiusSquared >= NextRandomIntRange(1, 100, Self.RandomState) then
                          begin
                            if OtherItem.DestroyFlag < 0 then
                              Inc(OtherItem.DestroyFlag)
                            else
                              Self.ReferencedItems.Add(OtherItem);
                          end;
                        end;
                      end;
                    end;
                  end
                  else
                  begin
                    if (Item is TUselessItem)
                      and (WideString(TEquipment(Item).ConfigBlockName) = WideString('ExampleAsteroid')) then
                      Self.DropMinerals(SeededRandomIntRange(20, 30, Self.GenerationSeed * Cardinal(Item.Id)), Item.Position,
                        Self.GenerationSeed * Cardinal(Item.Id));
                  end;
                  Point := Item.Position;
                  Stage := 2906;
                  if Item.DestroyFlag >= 0 then
                  begin
                    if RecordFilm then
                    begin
                      Self.PendingFilmObjectRemovals.Add(Item.FilmObject);
                      ReleaseSpaceObject(Item.GraphObject);
                    end;
                    begin
                      Self.Items.Delete(Self.Items.IndexOf(Item));
                      Item.Free;
                    end;
                  end
                  else Inc(Item.DestroyFlag);
                end;
              end;
            end
            else
              if TObject(Target) is TAsteroid then
              begin
                Stage := 2907;
                Asteroid := TObject(Target) as TAsteroid;
                if (Missile.OwnerShip <> nil)
                  and (Missile.OwnerShip.ScriptItemsAct(satOnMissileHittingObject, Asteroid, Missile, 1) = 0) then
                begin
                  Inc(EntryIndex);
                  Continue;
                end
                else
                begin
                  if RecordFilm then
                  begin
                    Effect := TWeaponSE.Create(Missile.GetWeaponInfo^.AreaSE, Classes.Point(0, 0), Missile.GetShotVisual, -1);
                    EffectFilm := PrimaryFilm.AddObject(0, Effect);
                    PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Asteroid.Position);
                    PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
                    PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                    PrimaryFilm.DetachObject(StepIndex, Missile.FilmObject);
                    Self.PendingFilmObjectRemovals.Add(Missile.FilmObject);
                    ReleaseSpaceObject(Missile.Graphic);
                  end;
                  Self.ClearTargetReferences(Asteroid);
                  Stage := 2908;
                  MineralValue := Self.DropMinerals(Integer(Trunc(Asteroid.MineralCount / Missile.GetWeaponInfo^.MiningFactor)), Asteroid.Position, Self.GenerationSeed * Asteroid.Id);
                  if GetPlayer = Missile.OwnerShip then
                    Self.ProcessPlayerAsteroidKill(MineralValue, Asteroid.Position, Asteroid.Id);
                  Asteroid.Respawn;
                  Point := Asteroid.Position;
                end;
              end
              else
              begin
                if TObject(Target) is TShip then
                begin
                  if not (TObject(Target) as TShip).IsHullDestroyed then
                  begin
                    Stage := 29090;
                    HitShip := TObject(Target) as TShip;
                    if GetPlayer = HitShip then
                      Self.PlayerCombatOccurred := True;
                    Stage := 29091;
                    DrainedDamage := 0;
                    Damage := Cardinal(HitShip.ApplyMissileHit(Missile, DamageColor, HitFlags));
                    Stage := 29092;
                    if (dkDrain in HitFlags) and (Integer(Damage) > 0) then
                      DrainedDamage := DrainedDamage + Integer(Damage);
                    if RecordFilm then
                    begin
                      Effect := TWeaponSE.Create(Missile.GetWeaponInfo^.AreaSE, Classes.Point(0, 0), Missile.GetShotVisual, -1);
                      EffectFilm := PrimaryFilm.AddObject(0, Effect);
                      PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, HitShip.Position);
                      PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, nil, HitShip.FilmObject);
                      PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, Word(DamageColor),
                        Integer(Damage), HitShip.IsHullDestroyed, True);
                      PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                      PrimaryFilm.DetachObject(StepIndex, Missile.FilmObject);
                      Self.PendingFilmObjectRemovals.Add(Missile.FilmObject);
                      ReleaseSpaceObject(Missile.Graphic);
                    end;
                    Stage := 29093;
                    Point := HitShip.Position;
                    if Missile.GetWeaponInfo^.ShotType in [wstTorpedo..wstMissile] then
                    begin
                      Stage := 29094;
                      CandidateCount := Self.Ships.Count;
                      for CandidateIndex := 0 to (CandidateCount - 1) do
                      begin
                        Ship := Self.Ships[CandidateIndex];
                        if Ship.InNormalSpace and not Ship.IsHullDestroyed and (Ship <> Target) then
                        begin
                          if PointDistanceSquared(Point, Ship.Position) < Math.Power(Missile.GetWeaponInfo^.SecondaryDamageRadius, 2) then
                          begin
                            Stage := 29095;
                            Damage := Cardinal(Ship.ApplyMissileHit(Missile, DamageColor, HitFlags));
                            if (dkDrain in HitFlags) and (Integer(Damage) > 0) then
                              DrainedDamage := DrainedDamage + Integer(Damage);
                            Stage := 29096;
                            Ship.RefreshDerivedStats(True);
                            if RecordFilm then
                            begin
                              CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
                              PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
                              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                                Word(DamageColor), Integer(Damage), Ship.IsHullDestroyed, True);
                              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                            end;
                          end;
                        end;
                      end;
                    end;
                    Stage := 29097;
                    if (DrainedDamage > 0) and ((Missile.OwnerShip <> nil)
                      and (Missile.OwnerShip.InNormalSpace and (Missile.OwnerShip.CurrentStar = Self))) then
                    begin
                      CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
                      PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm,
                        Missile.OwnerShip.FilmObject, Missile.OwnerShip.FilmObject);
                      if GetPlayer <> Missile.OwnerShip then
                        PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                          Word(OwnerToFilmColor(Missile.OwnerShip.OwnerId)), -DrainedDamage, False, True)
                      else
                        PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                          Word(OwnerToFilmColor(RaceToOwner(Missile.OwnerShip.PilotRace))),
                          -DrainedDamage, False, True);
                      PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                    end;
                  end;
                end;
              end;
          Stage := 29098;
          Missile.Free;
        end;
      end;
      EntryIndex := 0;
      Stage := 2910;
      while Self.Missiles.Count > EntryIndex do
      begin
        Missile := TMissile(Self.Missiles.List^[EntryIndex]);
        if Missile.DestroyQueued then
        begin
          if RecordFilm then
          begin
            ReleaseSpaceObject(Missile.Graphic);
            Self.PendingFilmObjectRemovals.Add(Missile.FilmObject);
          end;
          Missile.Free;
        end
        else
          Inc(EntryIndex);
      end;
      if (Galaxy.StasisModEnabled <> 1) and (PathStep and 3 = 0) then
      begin
        EntryCount := Self.Asteroids.Count;
        for EntryIndex := 0 to (EntryCount - 1) do
        begin
          Asteroid := Self.Asteroids[EntryIndex];
          if Asteroid.Position.X * Asteroid.Position.X + Asteroid.Position.Y * Asteroid.Position.Y < Sqr(Self.Radius * 0.7) then
          begin
            if RecordFilm then
            begin
              CreateFilmEffect('Weapon.Asteroid', 0, Effect, EffectFilm);
              PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Asteroid.Position);
              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
            end;
            Self.ClearTargetReferences(Asteroid);
            Asteroid.Respawn;
          end
          else
          begin
            Planet := nil;
            Quantity := Self.Planets.Count;
            for i := 0 to (Quantity - 1) do
            begin
              Planet := Self.Planets[i];
              Point := Planet.GetPosition;
              WorkX := Point.X;
              WorkY := Point.Y;
              ImpactX := Asteroid.Position.X;
              ImpactY := Asteroid.Position.Y;
              if Planet.GraphicRadius * Planet.GraphicRadius >= (WorkX - ImpactX) * (WorkX - ImpactX) + (WorkY - ImpactY) * (WorkY - ImpactY) then
                Break;
            end;
            if Self.Planets.Count > i then
            begin
              Planet.HandleAsteroidImpact(Asteroid);
              if RecordFilm then
              begin
                CreateFilmEffect('Weapon.Asteroid', 0, Effect, EffectFilm);
                PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Asteroid.Position);
                PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
                PrimaryFilm.AttachObject(StepIndex, EffectFilm);
              end;
              if Self.Items.Count < 8 then
              begin
                Quantity := Integer(Trunc(Asteroid.MineralCount / 5.0));
                Item := TGoods.Create;
                (Item as TGoods).Init(t_Minerals, Quantity);
                (Item as TGoods).NaturalFlag := True;
                Item.Position := Asteroid.Position;
                MovingDrop := AllocEC(SizeOf(MovingDrop^));
                MovingDrop^.Payload := Item;
                MovingDrop^.SourceShipId := 0;
                MovingDrop^.InsertedIntoStar := False;
                MovingDrop^.DeployTranclucator := 0;
                Distance := SeededRandomIntRange(50, 150, Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn) * Cardinal(Item.Id));
                if (PlayerStar = Self) and (Count - 20 < PathStep) then
                  Distance := 5.0;
                Angle := SeededRandomUnitFloat(Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn) * Cardinal(Item.Id)) * 1.2 - 0.6 + Math.ArcTan2(Asteroid.Position.X - Planet.GetPosition().X, -(Asteroid.Position.Y - Planet.GetPosition().Y));
                MovingDrop^.Destination.X := System.Sin(Angle) * Distance + Item.Position.X;
                MovingDrop^.Destination.Y := Item.Position.Y - System.Cos(Angle) * Distance;
                Self.MovingDropItems.Add(MovingDrop);
              end;
              Self.ClearTargetReferences(Asteroid);
              Asteroid.Respawn;
            end
            else
            begin
              Ship := nil;
              Quantity := Self.Ships.Count;
              for i := 0 to (Quantity - 1) do
              begin
                Ship := Self.Ships[i];
                if Ship.InNormalSpace and (not Ship.IsHullDestroyed
                  and ((PointDistanceSquared(Asteroid.Position, Ship.Position) <= 2500.0)
                  and ((GetPlayer = Ship) or ((Ship.ScriptShip = nil) or Ship.HasScriptStateText)))) then
                  Break;
              end;
              if Self.Ships.Count <= i then
                Continue;
              Damage := Cardinal(Ship.ApplyAsteroidImpactDamage(Asteroid, DamageColor));
              if RecordFilm then
              begin
                CreateFilmEffect('Weapon.Asteroid', 0, Effect, EffectFilm);
                PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Asteroid.Position);
                PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, nil, Ship.FilmObject);
                PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, Word(DamageColor),
                  Integer(Damage), Ship.IsHullDestroyed, True);
                PrimaryFilm.AttachObject(StepIndex, EffectFilm);
              end;
              Quantity := Integer(Trunc(Asteroid.MineralCount / 4.0));
              Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, Asteroid.Id * Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn)));
              CandidateCount := 0;
              while Quantity > 0 do
              begin
                if (Quantity < 10) or (CandidateCount >= 3) then
                  WorkCount := Quantity
                else
                  WorkCount := Integer(System.Round((SeededRandomUnitFloat(Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn) * Asteroid.Id) * 0.2 + 0.55) * Quantity));
                Quantity := Quantity - WorkCount;
                Item := TGoods.Create;
                (Item as TGoods).Init(t_Minerals, WorkCount);
                (Item as TGoods).NaturalFlag := True;
                Item.Position := Asteroid.Position;
                MovingDrop := AllocEC(SizeOf(MovingDrop^));
                MovingDrop^.Payload := Item;
                MovingDrop^.SourceShipId := 0;
                MovingDrop^.InsertedIntoStar := False;
                MovingDrop^.DeployTranclucator := 0;
                Self.MovingDropItems.Add(MovingDrop);
                Inc(CandidateCount);
              end;
              WorkValue := 3.1415925;
              if CandidateCount > 1 then
                WorkValue := GameTwoPi / CandidateCount;
              for CandidateIndex := 0 to (CandidateCount - 1) do
              begin
                MovingDrop := Self.MovingDropItems[Self.MovingDropItems.Count - 1 - CandidateIndex];
                Distance := SeededRandomIntRange(50, 150, Cardinal((TObject(MovingDrop^.Payload) as TItem).Id) * (Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn)));
                if (PlayerStar = Self) and (Count - 20 < PathStep) then
                  Distance := 5.0;
                WorkScale := SeededRandomUnitFloat(Cardinal((TObject(MovingDrop^.Payload) as TItem).Id) * (Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn))) * 0.3 - 0.15;
                MovingDrop^.Destination.X := (TObject(MovingDrop^.Payload) as TItem).Position.X + System.Sin(SeededRandomUnitFloat(Cardinal((TObject(MovingDrop^.Payload) as TItem).Id) * (Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn))) * (Angle + WorkScale) * 113.0) * Distance;
                MovingDrop^.Destination.Y := (TObject(MovingDrop^.Payload) as TItem).Position.Y - System.Cos(SeededRandomUnitFloat(Cardinal((TObject(MovingDrop^.Payload) as TItem).Id) * (Self.GenerationSeed * Cardinal(Galaxy.CurrentTurn))) * (Angle + WorkScale) * 517.0) * Distance;
                Angle := Angle + WorkValue;
              end;
              Self.ClearTargetReferences(Asteroid);
              Asteroid.Respawn;
            end;
          end;
        end;
      end;
      Stage := 29300;
      EntryCount := Self.CombatEvents.Count;
      for EntryIndex := 0 to (EntryCount - 1) do
      begin
        Stage := 2930;
        CombatEvent := Self.CombatEvents[EntryIndex];
        if (CombatEvent^.StepIndex = PathStep)
          and ((CombatEvent^.Attacker <> nil)
          and ((CombatEvent^.Target <> nil)
          and (not TShip(CombatEvent^.Attacker).IsHullDestroyed
          and (not TShip(CombatEvent^.Attacker).DestroyQueued
          and ((CombatEvent^.Weapon <> nil) and (TWeapon(CombatEvent^.Weapon).EquippedFlag <> 0)))))) then
        begin
          if not (TShip(CombatEvent^.Attacker).GetCombatStatusStrength(cseWeaponBlock) <= 0.01) then
          begin
            if NextRandomUnitFloat(TShip(CombatEvent^.Attacker).RandomState) < TShip(CombatEvent^.Attacker).GetCombatStatusStrength(cseWeaponBlock) then
            begin
              TShip(CombatEvent^.Attacker).ReduceCombatStatusStrength(cseWeaponBlock, 1.0);
              Continue;
            end;
            TShip(CombatEvent^.Attacker).ReduceCombatStatusStrength(cseWeaponBlock, 1.0);
          end;
          if TWeapon(CombatEvent^.Weapon).GetWeaponInfo^.ShotType in [wstTorpedo..wstRocket] then
          begin
            Stage := 2931;
            if TWeapon(CombatEvent^.Weapon).Ammo > 0 then
            begin
              if TObject(CombatEvent^.Target) is TShip then
                Point := (TObject(CombatEvent^.Target) as TShip).Position
              else
              begin
                if TObject(CombatEvent^.Target) is TAsteroid then
                  Point := (TObject(CombatEvent^.Target) as TAsteroid).Position
                else
                begin
                  if TObject(CombatEvent^.Target) is TItem then
                    Point := (TObject(CombatEvent^.Target) as TItem).Position
                  else
                  begin
                    if TObject(CombatEvent^.Target) is TMissile then
                      Point := (TObject(CombatEvent^.Target) as TMissile).Position
                    else
                      Point := MakePointF(1000000.0, 1000000.0);
                  end;
                end;
              end;
              if Sqr(TShip(CombatEvent^.Attacker).GetWeaponActionRange(TWeapon(CombatEvent^.Weapon)) + 200) > PointDistanceSquared(TShip(CombatEvent^.Attacker).Position, Point) then
              begin
                Quantity := 1;
                AttackCount := TWeapon(CombatEvent^.Weapon).GetAttackCount;
                if TWeapon(CombatEvent^.Weapon).GetWeaponInfo^.ShotType in [wstMissile..wstRocket] then
                  Quantity := TWeapon(CombatEvent^.Weapon).GetShotCount;
                BertorBoost := (CombatEvent^.Attacker is TKling)
                  and ((CombatEvent^.Attacker as TKling).DominatorSeries = dsBlazer)
                  and (CombatEvent^.Attacker as TKling).HasNearbyBertorAura;
                for ArtefactIndex := 1 to ((TWeapon(CombatEvent^.Weapon).GetAttackCount * TShip(CombatEvent^.Attacker).CountActiveArtefacts(t_ArtFastRacks)) * (Integer(TShip(CombatEvent^.Attacker).CanBoostArtefact(t_ArtFastRacks, TWeapon(CombatEvent^.Weapon), False)) + 1)) do
                begin
                  if (NextRandomUnitFloat(TShip(CombatEvent^.Attacker).RandomState) <= aConst.ExtraMissileChance) and (TObject(CombatEvent^.Target) is TShip) then
                    Inc(AttackCount);
                end;
                if TWeapon(CombatEvent^.Weapon).Ammo < AttackCount then
                  AttackCount := Max(1, TWeapon(CombatEvent^.Weapon).Ammo);
                Quantity := Quantity * AttackCount;
                if (TShip(CombatEvent^.Attacker).TypeId <> stKling)
                  and ((GetPlayer <> CombatEvent^.Attacker) or (Galaxy.AmmoModEnabled <> 1)) then
                begin
                  RemainingAmmo := TWeapon(CombatEvent^.Weapon).Ammo - AttackCount;
                  TWeapon(CombatEvent^.Weapon).Ammo := RemainingAmmo;
                  if GetPlayer = CombatEvent^.Attacker then
                  begin
                    SysUtils.Sleep(1);
                    if (TWeapon(CombatEvent^.Weapon).Ammo <> RemainingAmmo)
                      and not GR_Main.CCInterface.GetTamperDetected then
                      GR_Main.CCInterface.SetTamperDetected(True);
                  end;
                end;
                for i := 0 to (Quantity - 1) do
                begin
                  if CombatEvent^.Weapon is TCustomWeapon then
                  begin
                    Missile := TCustomMissile.Create;
                    TCustomMissile(Missile).InitializeShot(Self, TShip(CombatEvent^.Attacker), TWeapon(CombatEvent^.Weapon),
                      CombatEvent^.Target, i + Ord(Quantity mod 2 = 0));
                  end
                  else
                  begin
                    Missile := TMissile.Create;
                    Missile.InitializeShot(Self, TShip(CombatEvent^.Attacker), TWeapon(CombatEvent^.Weapon), CombatEvent^.Target,
                      i + Ord(Quantity mod 2 = 0));
                  end;
                  if BertorBoost then
                  begin
                    if Self.RecordingTurnFilm
                      and (Ord((CombatEvent^.Attacker as TKling).AuraEffectShownThisTurn) = 0) then
                    begin
                      CreateFilmEffect('Weapon.AuraEffect', 0, Effect, EffectFilm);
                      PrimaryFilm.SetWeaponEndpoints(Self.CurrentStepIndex, EffectFilm,
                        TShip(CombatEvent^.Attacker).FilmObject, TShip(CombatEvent^.Attacker).FilmObject);
                      PrimaryFilm.SetWeaponHit(Self.CurrentStepIndex, EffectFilm, 0, 0, False, True);
                      PrimaryFilm.AttachObject(Self.CurrentStepIndex, EffectFilm);
                      (CombatEvent^.Attacker as TKling).AuraEffectShownThisTurn := True;
                    end;
                    Missile.MinDamage := Cardinal(System.Round(Missile.MinDamage * 1.25));
                    Missile.MaxDamage := Cardinal(System.Round(Missile.MaxDamage * 1.25));
                  end;
                  TShip(CombatEvent^.Attacker).ScriptItemsAct(satOnMissileShot, Missile, TWeapon(CombatEvent^.Weapon), 0);
                  Missile.PrepareTurnMovement(StepIndex, RecordFilm, True);
                  if RecordFilm then
                    PrimaryFilm.DetachObject(0, Missile.FilmObject);
                end;
              end;
            end;
          end
          else
          begin
            if TObject(CombatEvent^.Target) is TMissile then
            begin
              Stage := 2932;
              if PointDistanceSquared(TShip(CombatEvent^.Attacker).Position, (TObject(CombatEvent^.Target) as TMissile).Position) < 1.3 * Sqr(TShip(CombatEvent^.Attacker).GetWeaponRange(TWeapon(CombatEvent^.Weapon))) then
                TShip(CombatEvent^.Attacker).FireWeaponAtMissile(TWeapon(CombatEvent^.Weapon), CombatEvent^.Target, RecordFilm);
            end
            else
            begin
              if TObject(CombatEvent^.Target) is TShip then
              begin
                Stage := 2933;
                if PointDistanceSquared(TShip(CombatEvent^.Attacker).Position, (TObject(CombatEvent^.Target) as TShip).Position) < 1.3 * Sqr(TShip(CombatEvent^.Attacker).GetWeaponRange(TWeapon(CombatEvent^.Weapon))) then
                  TShip(CombatEvent^.Attacker).FireWeaponAtShip(TWeapon(CombatEvent^.Weapon), TShip(CombatEvent^.Target), RecordFilm);
              end
              else
              begin
                if TObject(CombatEvent^.Target) is TItem then
                begin
                  Stage := 2934;
                  if PointDistanceSquared(TShip(CombatEvent^.Attacker).Position, (TObject(CombatEvent^.Target) as TItem).Position) < 1.3 * Sqr(TShip(CombatEvent^.Attacker).GetWeaponRange(TWeapon(CombatEvent^.Weapon))) then
                    TShip(CombatEvent^.Attacker).FireWeaponAtItem(TWeapon(CombatEvent^.Weapon), TItem(CombatEvent^.Target), RecordFilm);
                end
                else
                begin
                  if TObject(CombatEvent^.Target) is TAsteroid then
                  begin
                    Stage := 2935;
                    if PointDistanceSquared(TShip(CombatEvent^.Attacker).Position, (TObject(CombatEvent^.Target) as TAsteroid).Position) < 1.3 * Sqr(TShip(CombatEvent^.Attacker).GetWeaponRange(TWeapon(CombatEvent^.Weapon))) then
                      TShip(CombatEvent^.Attacker).FireWeaponAtAsteroid(TWeapon(CombatEvent^.Weapon), CombatEvent^.Target,
                        RecordFilm);
                  end;
                end;
              end;
            end;
          end;
          Continue;
        end;
      end;
      Stage := 2940;
      EntryCount := Self.MovingDropItems.Count;
      for EntryIndex := 0 to (EntryCount - 1) do
      begin
        MovingDrop := Self.MovingDropItems[EntryIndex];
        if MovingDrop^.Payload <> nil then
        begin
          if TObject(MovingDrop^.Payload) is TItem then
          begin
            Item := TObject(MovingDrop^.Payload) as TItem;
            if not MovingDrop^.InsertedIntoStar then
            begin
              if (Item is TArtefactTranclucator) and (MovingDrop^.DeployTranclucator <> 0) then
              begin
                Tranclucator := TObject((Item as TArtefactTranclucator).Ship) as TTranclucator;
                (Item as TArtefactTranclucator).Ship := nil;
                Tranclucator.CurrentStar := Self;
                Self.Ships.Add(Tranclucator);
                Tranclucator.Position := Item.Position;
                Tranclucator.MovementDirection := 0.0;
                Item.Free;
                MovingDrop^.Payload := Tranclucator;
                MovingDrop^.InsertedIntoStar := True;
                if RecordFilm then
                begin
                  Tranclucator.FilmObject := PrimaryFilm.AddObject(Tranclucator.Id, Tranclucator.Graphic);
                  PrimaryFilm.DetachObject(0, Tranclucator.FilmObject);
                  PrimaryFilm.SetObjectPosition(StepIndex, Tranclucator.FilmObject, Self.Position);
                  PrimaryFilm.SetObjectAngle(StepIndex, Tranclucator.FilmObject, 0);
                  PrimaryFilm.SetObjectAlpha(StepIndex, Tranclucator.FilmObject, 255);
                  PrimaryFilm.AttachObject(StepIndex, Tranclucator.FilmObject);
                end;
              end
              else
              begin
                Self.Items.Add(Item);
                MovingDrop^.InsertedIntoStar := True;
                if RecordFilm then
                begin
                  Item.FilmObject := PrimaryFilm.AddObject(Item.Id, Item.GetGraphObject);
                  PrimaryFilm.DetachObject(0, Item.FilmObject);
                  PrimaryFilm.SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
                  PrimaryFilm.AttachObject(StepIndex, Item.FilmObject);
                end;
              end;
            end
            else
            begin
              Item.Position.X := (MovingDrop^.Destination.X - Item.Position.X) / (Count - PathStep) + Item.Position.X;
              Item.Position.Y := (MovingDrop^.Destination.Y - Item.Position.Y) / (Count - PathStep) + Item.Position.Y;
              if RecordFilm then
                PrimaryFilm.SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
              if Self.DamageRadius * Self.DamageRadius > Sqr(Item.Position.X) + Sqr(Item.Position.Y) then
              begin
                if RecordFilm then
                begin
                  CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
                  PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, nil, Item.FilmObject);
                  PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, True, True);
                  PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                  ReleaseSpaceObject(Item.GraphObject);
                  Self.PendingFilmObjectRemovals.Add(Item.FilmObject);
                end;
                Self.Items.Delete(Self.Items.IndexOf(Item));
                Item.Free;
                MovingDrop^.Payload := nil;
              end;
            end;
          end
          else
          begin
            HitShip := TObject(MovingDrop^.Payload) as TShip;
            HitShip.Position.X := (MovingDrop^.Destination.X - HitShip.Position.X) / (Count - PathStep) + HitShip.Position.X;
            HitShip.Position.Y := (MovingDrop^.Destination.Y - HitShip.Position.Y) / (Count - PathStep) + HitShip.Position.Y;
            if RecordFilm then
              PrimaryFilm.SetObjectPosition(StepIndex, HitShip.FilmObject, HitShip.Position);
          end;
        end;
      end;
      Stage := 2950;
      if Galaxy.StasisModEnabled <> 1 then
        for Index := 0 to (Self.Planets.Count - 1) do
        begin
          Planet := Self.Planets[Index];
          Planet.AdvanceOrbitStep(StepIndex, RecordFilm);
        end;
      Stage := 2951;
      if Galaxy.StasisModEnabled <> 1 then
        for Index := 0 to (Self.Asteroids.Count - 1) do
        begin
          Asteroid := Self.Asteroids[Index];
          Asteroid.AdvanceOrbitStep(StepIndex, RecordFilm);
        end;
      Stage := 2952;
      if StepIndex mod (Count div 11) = 0 then
      begin
        if StepIndex div (Count div 11) >= 1 then
        begin
          if StepIndex div (Count div 11) <= 10 then
            Self.ProcessItemScripts(StepIndex div (Count div 11));
        end;
      end;
      Stage := 2960;
      if (PathStep + 1) mod Integer(Cardinal(Count) shr 3) = 0 then
        for Index := 0 to (Self.Ships.Count - 1) do
        begin
          Ship := Self.Ships[Index];
          if Ship.InNormalSpace and ((GetPlayer <> Ship) or (Byte(GlobalsV.CurrentScreenId) = 16)) then
            for i := 0 to (Ship.Inventory.Count - 1) do
            begin
              Item := Ship.Inventory[i];
              if Item.DestroyFlag > 0 then
              begin
                while Ship.DockedTo <> nil do
                  Ship := Ship.DockedTo;
                Ship.DestroyQueued := True;
                Break;
              end;
            end;
          ;
        end;
      Stage := 2961;
      Index := 0;
      while Self.Items.Count > Index do
      begin
        Item := Self.Items[Index];
        if Item.DestroyFlag > 0 then
        begin
          Self.Items.Delete(Index);
          Dec(Index);
          if RecordFilm then
          begin
            CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
            PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Item.FilmObject, Item.FilmObject);
            PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, True, True);
            if Item.DestroyFlag = 1 then
              PrimaryFilm.SetDestructionEffect(StepIndex, EffectFilm, 3)
            else
              PrimaryFilm.SetDestructionEffect(StepIndex, EffectFilm, 1);
            PrimaryFilm.AttachObject(StepIndex, EffectFilm);
          end;
          Self.ClearItemReferences(Item);
          if (Item.DestroyFlag > 1)
            or ((Item.ItemType = t_ArtefactBomb) or (Item is TCistern)
            and ((Item as TCistern).Fuel > 0)) then
          begin
            CandidateCount := Self.Ships.Count;
            for CandidateIndex := 0 to (CandidateCount - 1) do
            begin
              Ship := Self.Ships[CandidateIndex];
              if Ship.InNormalSpace and not Ship.IsHullDestroyed then
              begin
                Distance := PointDistanceSquared(Ship.Position, Item.Position);
                if (Sqr(aConst.BombDamageRadius) >= Distance)
                  and ((GetPlayer <> Ship) or (Galaxy.GodModEnabled <> 1) and (Galaxy.SpecialSimulationMode = 0)) then
                begin
                  Damage := Cardinal(Ship.ApplyExplosionDamage(nil, Item, 0, nil));
                  DamageColor := GR_Main.CurrentPixelFormat.PackRgbBytes(255, 0, 0);
                  if RecordFilm then
                  begin
                    CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
                    PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
                    if Item.DestroyFlag > 0 then
                      PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, Word(DamageColor),
                        Integer(Damage), Ship.IsHullDestroyed, True)
                    else
                      PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, Ship.IsHullDestroyed, True);
                    PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                  end;
                end;
              end;
            end;
            CandidateCount := Self.Items.Count;
            for CandidateIndex := 0 to (CandidateCount - 1) do
            begin
              OtherItem := Self.Items[CandidateIndex];
              Distance := PointDistanceSquared(OtherItem.Position, Item.Position);
              if aConst.ItemExplosionRadiusSquared >= Distance then
              begin
                if 20.0 - 20.0 * Distance / aConst.ItemExplosionRadiusSquared >= NextRandomIntRange(1, 100, Self.RandomState) then
                begin
                  if OtherItem.DestroyFlag < 0 then
                    Inc(OtherItem.DestroyFlag)
                  else
                    Self.ReferencedItems.Add(OtherItem);
                end;
              end;
            end;
          end;
          if RecordFilm then
          begin
            Self.PendingFilmObjectRemovals.Add(Item.FilmObject);
            ReleaseSpaceObject(Item.GraphObject);
          end;
          Item.Free;
        end;
        Inc(Index);
      end;
      Index := 0;
      Stage := 2970;
      while Self.Ships.Count > Index do
      begin
        Ship := Self.Ships[Index];
        if Ship.IsHullDestroyed then
        begin
          Inc(Index);
          Continue;
        end;
        Stage := 2971;
        if Ship.DestroyQueued and ((Cardinal(Cardinal(Count) shr 2) = Cardinal(PathStep))
          and ((GetPlayer <> Ship) or (Byte(GlobalsV.CurrentScreenId) = 16))) then
        begin
          Ship.ScriptItemsAct(satOnDeath, nil, nil, 0);
          Ship.GetHull.HullPoints := 0;
          if GetPlayer <> nil then
            GetPlayer.ProcessShipDestructionQuests(Ship);
          Ship.RefreshDerivedStats(True);
          if RecordFilm and (Ship.FilmObject <> nil) then
          begin
            if Ship.InNormalSpace then
            begin
              CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
              PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, Ship.IsHullDestroyed, True);
              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
            end
            else
              PrimaryFilm.DetachObject(StepIndex, Ship.FilmObject);
          end;
          Self.ClearShipReferences(Ship);
          Inc(Index);
          Continue;
        end;
        Stage := 2972;
        if (StepIndex mod (Count div 5) = 0) and (StepIndex div (Count div 5) >= 1) then
        begin
          if (StepIndex div (Count div 5) <= 3)
            and (not Ship.IsHullDestroyed
            and (Ship.InNormalSpace and ((GetPlayer <> Ship) or (Galaxy.GodModEnabled <> 1)
            and (Galaxy.SpecialSimulationMode = 0))) and ((GetPlayer = Ship) or (Galaxy.StasisModEnabled <> 1))) then
          begin
            Distance := Sqr(Ship.Position.X) + Sqr(Ship.Position.Y);
            if Self.DamageRadius * Self.DamageRadius > Distance then
            begin
              if GetPlayer = Ship then
                Self.PlayerCombatOccurred := True;
              Damage := Cardinal(Ship.ApplyStarHeatDamage);
              if RecordFilm and (Integer(Damage) > 0) then
              begin
                CreateFilmEffect('Weapon.Star', 0, Effect, EffectFilm);
                PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
                PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                  Word(GR_Main.CurrentPixelFormat.PackRgbBytes(255, 255, 255)),
                  Integer(Damage), Ship.IsHullDestroyed, True);
                PrimaryFilm.AttachObject(StepIndex, EffectFilm);
              end;
              Ship.InterceptorPassesRemaining := 0;
              if Ship.IsHullDestroyed then
              begin
                Inc(Index);
                Continue;
              end;
            end;
          end;
        end;
        Stage := 29731;
        if (StepIndex mod (Count div 5) = 0) and (StepIndex div (Count div 5) >= 1) then
        begin
          if (StepIndex div (Count div 5) <= 3)
            and (not Ship.IsHullDestroyed
            and (Ship.InNormalSpace and ((GetPlayer <> Ship) or (Galaxy.GodModEnabled <> 1)
            and (Galaxy.SpecialSimulationMode = 0)))
            and (((GetPlayer = Ship) or (Galaxy.StasisModEnabled <> 1))
            and (Ship.InterceptorPassesRemaining > 0))) then
          begin
            if (GetPlayer = Ship) or (GetPlayer = Ship.InterceptorSourceShip) then
            begin
              Self.PlayerCombatOccurred := True;
              if GetPlayer = Ship.InterceptorSourceShip then
                PrimaryFilm.AddCameraEvent(StepIndex, GetPlayer.Position, Ship.Position, 1);
              if (GetPlayer = Ship) and (Ship.InterceptorSourceShip <> nil) then
                PrimaryFilm.AddCameraEvent(StepIndex, GetPlayer.Position, Ship.InterceptorSourceShip.Position, 1);
            end;
            Damage := Cardinal(Ship.ApplyInterceptorDamage(DamageColor));
            if RecordFilm then
            begin
              CreateFilmEffect('Weapon.Star', 0, Effect, EffectFilm);
              PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, Word(DamageColor),
                Integer(Damage), Ship.IsHullDestroyed, True);
              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
            end;
            if Ship.IsHullDestroyed then
            begin
              Inc(Index);
              Continue;
            end;
          end;
        end;
        Stage := 29732;
        if (Galaxy.StasisModEnabled <> 1)
          and ((4 * (Count div 5) = StepIndex)
          and (not Ship.IsHullDestroyed and (Ship.InNormalSpace and (Ship.InterceptorSourceShip <> nil)))) then
        begin
          if Ship.InterceptorSourceShip.GetHull.Energy >= 3 then
          begin
            Ship.InterceptorSourceShip.GetHull.Energy := Ship.InterceptorSourceShip.GetHull.Energy - 3;
            Dec(Ship.InterceptorPassesRemaining);
          end
          else
          begin
            Ship.InterceptorSourceShip.GetHull.Energy := 0;
            Ship.InterceptorPassesRemaining := 0;
          end;
          if Ship.InterceptorPassesRemaining <= 0 then
            Ship.InterceptorSourceShip := nil;
        end;
        Stage := 29733;
        if 4 * (Count div 5) = StepIndex then
        begin
          if (System.Round(Ship.GetCombatStatusStrength(cseShock)) >= 1)
            and (not Ship.IsHullDestroyed
            and (Ship.InNormalSpace and ((GetPlayer <> Ship) or (Galaxy.GodModEnabled <> 1)
            and (Galaxy.SpecialSimulationMode = 0))) and ((GetPlayer = Ship) or (Galaxy.StasisModEnabled <> 1))) then
          begin
            Damage := Cardinal(Ship.ApplyShockStatusDamage(DamageColor));
            if RecordFilm then
            begin
              CreateFilmEffect('Weapon.Shock', 0, Effect, EffectFilm);
              PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, Word(DamageColor),
                Integer(Damage), Ship.IsHullDestroyed, True);
              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
            end;
          end;
        end;
        if Ship is TKling then
        begin
          if (Ship as TKling).ShouldKamikaze and not Ship.IsHullDestroyed and Ship.InNormalSpace then
          begin
            if Ship.OrderTarget <> nil then
            begin
              if TObject(Ship.OrderTarget) is TShip then
              begin
                if not (TObject(Ship.OrderTarget) as TShip).IsHullDestroyed then
                begin
                  if (TObject(Ship.OrderTarget) as TShip).InNormalSpace then
                  begin
                    if PointDistance(Ship.Position, (TObject(Ship.OrderTarget) as TShip).Position) <= 100.0 then
                    begin
                      Ship.GetHull.HullPoints := 0;
                      Self.ClearShipReferences(Ship);
                      Ship.ScriptItemsAct(satOnDeath, Ship, Ship, 0);
                      if GetPlayer <> nil then
                        GetPlayer.ProcessShipDestructionQuests(Ship);
                      for CandidateIndex := 0 to (Self.Ships.Count - 1) do
                      begin
                        OwnerShip := Self.Ships[CandidateIndex];
                        if not OwnerShip.IsHullDestroyed
                          and (OwnerShip.InNormalSpace
                          and ((PointDistanceSquared(Ship.Position, OwnerShip.Position) <= 22500.0)
                          and ((GetPlayer <> OwnerShip) or (Galaxy.GodModEnabled <> 1)
                          and (Galaxy.SpecialSimulationMode = 0)))) then
                        begin
                          if not (OwnerShip is TKling)
                            or ((OwnerShip as TKling).DominatorSeries <> (Ship as TKling).DominatorSeries) then
                          begin
                            Damage := Cardinal(OwnerShip.ApplyExplosionDamage(nil, Ship, 0, nil));
                            DamageColor := GR_Main.CurrentPixelFormat.PackRgbBytes(255, 0, 0);
                            if RecordFilm then
                            begin
                              CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
                              PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm,
                                OwnerShip.FilmObject, OwnerShip.FilmObject);
                              PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                                Word(DamageColor), Integer(Damage), OwnerShip.IsHullDestroyed, True);
                              PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                            end;
                          end;
                        end;
                      end;
                      if RecordFilm then
                      begin
                        PrimaryFilm.SetObjectAlpha(StepIndex, Ship.FilmObject, 0);
                        CreateFilmEffect('Weapon.Kamikaze', 0, Effect, EffectFilm);
                        PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
                        PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, True, True);
                        PrimaryFilm.SetDestructionEffect(StepIndex, EffectFilm, 5);
                        PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        Stage := 29734;
        if (StepIndex mod (Count div 9) = 0)
          and ((Ship is TKling)
          and (not Ship.IsHullDestroyed and (Ship.InNormalSpace and (Galaxy.StasisModEnabled <> 1)))) then
        begin
          if RecordFilm and (((Ship as TKling).KlingType = ktBertor)
            and (StepIndex div (Count div 9) in [1, 3])) then
          begin
            Effect := TWeaponSE.Create('Weapon.RadialEffect', Classes.Point(0, 0), Integer((Ship as TKling).DominatorSeries), -1);
            EffectFilm := PrimaryFilm.AddObject(0, Effect);
            PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
            PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
            PrimaryFilm.AttachObject(StepIndex, EffectFilm);
          end;
          if (StepIndex div (Count div 9) = 3) and ((Ship as TKling).DominatorSeries = dsTerron) then
          begin
            if (Ship as TKling).HasNearbyBertorAura then
            begin
              Damage := Cardinal(Max(1, System.Round(Ship.GetHull.Weight * 0.05)));
              Ship.GetHull.HullPoints := Min(Ship.GetHull.Weight,
                Integer(Damage) + Ship.GetHull.HullPoints);
              if RecordFilm then
              begin
                CreateFilmEffect('Weapon.AuraEffect', 2, Effect, EffectFilm);
                PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
                PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm,
                  Word(OwnerToFilmColor(Ship.OwnerId)), -Damage, False, True);
                PrimaryFilm.AttachObject(StepIndex, EffectFilm);
              end;
            end;
          end;
          if (StepIndex div (Count div 9) = 3)
            and (((Ship as TKling).KlingType = ktBertor) and (not Ship.IsHullDestroyed and Ship.InNormalSpace)) then
            for CandidateIndex := 0 to (Self.Ships.Count - 1) do
            begin
              OwnerShip := Self.Ships[CandidateIndex];
              if not OwnerShip.IsHullDestroyed and OwnerShip.InNormalSpace and (Ship <> OwnerShip)
                and (not (OwnerShip is TKling)
                or not (Byte((OwnerShip as TKling).KlingType) in [0, 6]))
                and (PointDistance(Ship.Position, OwnerShip.Position) <= 500.0) then
                for EntryIndex := 0 to (OwnerShip.Inventory.Count - 1) do
                begin
                  Item := OwnerShip.Inventory[EntryIndex];
                  if Item.OwnerId = oiDominator then
                  begin
                    if ((Item as TEquipment).DominatorSeries <> (Ship as TKling).DominatorSeries) and ((Item.ItemType in [t_FuelTanks .. t_CustomWeapon, t_Satellite]) and (Item is TEquipment)) then
                    begin
                      if (Item as TEquipment).EquippedFlag <> 0 then
                      begin
                        if (Item as TEquipment).BrokenFlag = 0 then
                        begin
                          if WideString((Item as TEquipment).CustomFaction) = '' then
                            OwnerShip.ApplyItemDegradation(TEquipment(Item), idkForce,
                              NextRandomIntRange(5, 10, Ship.RandomState));
                        end;
                      end;
                    end;
                  end;
                end;
            end;
        end;
        Stage := 29735;
        if StepIndex mod (Count div (aConst.PointDefensePassCount + 2)) = 0 then
        begin
          if StepIndex div (Count div (aConst.PointDefensePassCount + 2)) >= 1 then
          begin
            if (StepIndex div (Count div (aConst.PointDefensePassCount + 2)) <= aConst.PointDefensePassCount)
              and (not Ship.IsHullDestroyed
              and (Ship.InNormalSpace and ((Ship.CountActiveArtefacts(t_ArtPDTurret) > 0)
              and ((GetPlayer = Ship) or (Galaxy.StasisModEnabled <> 1))))) then
            begin
              for ArtefactIndex := 1 to Ship.CountActiveArtefacts(t_ArtPDTurret) do
              begin
                CandidateIndex := 0;
                InterceptedMissile := nil;
                NearestMissileDistance := 0;
                BestMissilePriority := -1;
                MissilePriority := 0;
                PointDefenseRangeSquared := (aConst.PointDefenseBaseRange + aConst.PointDefenseBonusRange) * (aConst.PointDefenseBaseRange + aConst.PointDefenseBonusRange * Ord(Ship.CanBoostArtefact(t_ArtPDTurret, nil, False)));
                while Self.Missiles.Count > CandidateIndex do
                begin
                  Missile := Self.Missiles[CandidateIndex];
                  Inc(CandidateIndex);
                  if (Missile.OwnerShip <> Ship)
                    and (not (Ship is TTranclucator)
                    or ((TTranclucator(Ship).OwnerShip = nil)
                    or ((Missile.OwnerShip = nil) or (TTranclucator(Ship).OwnerShip <> Missile.OwnerShip)
                    and (not (TObject(Missile.OwnerShip) is TTranclucator)
                    or (TTranclucator(Ship).OwnerShip <> TTranclucator(Cardinal(Missile.OwnerShip)).OwnerShip))))) then
                  begin
                    MissileDistance := Integer(System.Round(PointDistanceSquared(Ship.Position, Missile.Position)));
                    if MissileDistance <= PointDefenseRangeSquared then
                    begin
                      if Missile.Target = Ship then
                        MissilePriority := 3
                      else if (Missile.Target <> nil)
                        and (TObject(Missile.Target) is TShip)
                        and (Cardinal(Missile.Target) <> Cardinal(Missile.OwnerShip))
                        and ((TObject(Missile.Target) as TShip).GetRelationLevelToShip(Ship) > rlHostile)
                        and (Ship.GetRelationLevelToShip(TObject(Missile.Target) as TShip) > rlHostile) then
                        MissilePriority := 2
                      else if (Missile.OwnerShip <> nil)
                        and ((Missile.OwnerShip.GetRelationLevelToShip(Ship) <= rlHostile)
                        or (Ship.GetRelationLevelToShip(Missile.OwnerShip) <= rlHostile)) then
                        MissilePriority := 1
                      else Continue;
                      if (MissilePriority >= BestMissilePriority)
                        and ((MissilePriority <> BestMissilePriority)
                        or (MissileDistance <= NearestMissileDistance)) then
                      begin
                        NearestMissileDistance := MissileDistance;
                        BestMissilePriority := MissilePriority;
                        InterceptedMissile := Missile;
                      end;
                    end;
                  end;
                end;
                if InterceptedMissile <> nil then
                begin
                  if RecordFilm then
                  begin
                    CreateFilmEffect('Weapon.PDTurret', 0, Effect, EffectFilm);
                    PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm,
                      Ship.FilmObject, InterceptedMissile.FilmObject);
                    PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
                    PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                    CreateFilmEffect('Weapon.Asteroid', 0, Effect, EffectFilm);
                    PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, InterceptedMissile.Position);
                    PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
                    PrimaryFilm.AttachObject(StepIndex, EffectFilm);
                    PrimaryFilm.DetachObject(StepIndex, InterceptedMissile.FilmObject);
                    Self.PendingFilmObjectRemovals.Add(InterceptedMissile.FilmObject);
                    ReleaseSpaceObject(InterceptedMissile.Graphic);
                  end;
                  InterceptedMissile.Free;
                end;
              end;
            end;
          end;
        end;
        Stage := 2974;
        CanPull := 1;
        if (GetPlayer = Ship) and (Ship.PickupTargets <> nil)
          and (Ship.GetCargoHook <> nil) and (Ship.MovementPath.NodeCount <> 0) then
        begin
          CanPull := 0;
          for CandidateIndex := 0 to (Ship.PickupTargets.Count - 1) do
          begin
            Target := Ship.PickupTargets[CandidateIndex];
            ClosestNodeIndex := 0;
            if Self.Items.IndexOf(Target) >= 0 then
            begin
              Item := TObject(Target) as TItem;
              Node := Ship.MovementPath.ActiveHead;
              ClosestDistance := PointDistance(Item.Position, Node^.Position);
              if Ship.GetCargoHookRange < ClosestDistance then
                Continue;
              ClosestNodeIndex := 0;
              Node := Node^.Next;
              for NodeIndex := 1 to (Ship.MovementPath.NodeCount - 1) do
              begin
                Distance := PointDistance(Item.Position, Node^.Position);
                if Ship.GetCargoHookRange >= Distance then
                begin
                  if Distance >= ClosestDistance then
                    Break;
                  if Distance < ClosestDistance then
                  begin
                    ClosestDistance := Distance;
                    ClosestNodeIndex := NodeIndex;
                    Break;
                  end;
                  Node := Node^.Next;
                end;
              end;
            end;
            if ClosestNodeIndex = 0 then
            begin
              CanPull := 1;
              Break;
            end;
          end;
        end;
        Stage := 2975;
        if not ((Galaxy.StasisModEnabled = 1) and (GetPlayer <> Ship)
          or ((Ship.PickupTargets = nil) or ((Ship.GetCargoHook = nil) or (CanPull = 0)))) then
        begin
          CanPull := 0;
          PulledItemCount := 0;
          for CandidateIndex := (Ship.PickupTargets.Count - 1) downto 0 do
          begin
            Target := Ship.PickupTargets[CandidateIndex];
            if Self.Items.IndexOf(Target) >= 0 then
            begin
              Item := TObject(Target) as TItem;
              Distance := PointDistance(Item.Position, Ship.Position);
              if Ship.GetCargoHookRange < Distance then
                Continue;
              if not Ship.PickupPathUpdatesAllowed then
                Continue;
              if Distance < 5.0 then
                CompleteItemPickup
              else
              begin
                if (Ship <> NearestShip) and (Item = NearestItem) then
                  Distance := Distance - (2.5 - RemapClamped(Distance, 0.0, Ship.GetCargoHookRange, 1.0, 2.0)) - SeededRandomFloatRange(Cardinal(Ship.Id + Integer(Trunc(Galaxy.CurrentTurn))), 0.1, 0.3)
                else
                  Distance := Distance - RemapClamped(Distance, 0.0, Ship.GetCargoHookRange, Ship.GetCargoHookMaxPullSpeed, Ship.GetCargoHookMinPullSpeed) - SeededRandomFloatRange(Cardinal(Ship.Id + Integer(Trunc(Galaxy.CurrentTurn))), 0.1, 0.3);
                if Item.DestroyFlag > 0 then
                  Distance := Max(PointDistance(Item.Position, Ship.Position) * 0.99, Distance);
                if Distance < 1.0 then
                  Distance := 1.0;
                Angle := Math.ArcTan2(Item.Position.X - Ship.Position.X, -(Item.Position.Y - Ship.Position.Y));
                Item.Position := MakePointF(System.Sin(Angle) * Distance + Ship.Position.X, Ship.Position.Y - System.Cos(Angle) * Distance);
                if not (Ship is TRuins) then
                  Ship.Position := MakePointF(System.Sin(Angle) * 0.01 + Ship.Position.X, Ship.Position.Y - System.Cos(Angle) * 0.01);
                if RecordFilm then
                begin
                  PrimaryFilm.SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
                  PrimaryFilm.SetObjectPosition(StepIndex, Ship.FilmObject, Ship.Position);
                end;
                Inc(PulledItemCount);
                if Distance < 5.0 then
                  CompleteItemPickup;
              end;
            end
            else
              Ship.RemovePickupTarget(Target);
            CanPull := 1;
            Break;
          end;
          if CanPull <> 0 then
          begin
            Inc(Index);
            Continue;
          end;
        end;
        Stage := 2976;
        if (Galaxy.StasisModEnabled <> 1) and (Ship.CargoFreeSpace < 0) and (GetPlayer <> Ship) then
        begin
          Ship.AutoEquipInventory;
          Ship.DropCargoUntilNotOverloaded;
          Ship.AutoEquipInventory;
          if Ship.CargoFreeSpace <= 0 then
            Ship.ClearPickupTargets;
        end;
        Stage := 2977;
        if (Galaxy.StasisModEnabled <> 1) or (GetPlayer = Ship) then
        begin
          if not Ship.ProcessMovementStep(StepIndex, RecordFilm) then
            Inc(Index);
        end
        else
          Inc(Index);
        Stage := 2978;
        Continue;
      end;
      Stage := 2980;
      if RecordFilm and (Cardinal(Cardinal(Count) shr 2) = Cardinal(StepIndex)) then
      begin
        EntryIndex := 0;
        while Galaxy.Holes.Count > EntryIndex do
        begin
          Hole := Galaxy.Holes[EntryIndex];
          if (Hole.Star1 <> Self) and (Hole.Star2 <> Self) then
            Inc(EntryIndex)
          else
          begin
            if (Hole.HoleType = 1) and (Galaxy.CurrentTurn - Hole.CreatedTurn > 200)
              or ((Hole.HoleType = 3) or (Hole.HoleType = 4)
              and ((Galaxy.KellerMissionState = 5)
              and (Galaxy.ScaleIntByTechLevel(1, 10) < Galaxy.CurrentTurn - Hole.CreatedTurn))
              or (Hole.HoleType = 4) and (aKling.KellerShip = nil)) then
            begin
              Index := 0;
              DestinationShipCount := Hole.Star1.Ships.Count;
              while Index < DestinationShipCount do
              begin
                Ship := Hole.Star1.Ships[Index];
                if (Ship.Order = soJumpHole) and (Ship.OrderTarget = Hole) then
                  Break;
                Inc(Index);
              end;
              if Index >= DestinationShipCount then
              begin
                Index := 0;
                DestinationShipCount := Hole.Star2.Ships.Count;
                while Index < DestinationShipCount do
                begin
                  Ship := Hole.Star2.Ships[Index];
                  if (Ship.Order = soJumpHole) and (Ship.OrderTarget = Hole) then
                    Break;
                  Inc(Index);
                end;
                if Index >= DestinationShipCount then
                begin
                  if Hole.FilmObjectId <> 0 then
                  begin
                    ReleaseSpaceObject(Hole.Graphic);
                    Self.PendingFilmObjectRemovals.Add(Pointer(Hole.FilmObjectId));
                    PrimaryFilm.SetHoleState(StepIndex, Pointer(Hole.FilmObjectId), 2);
                  end;
                  if Hole.HoleType = 4 then
                    Galaxy.KellerMissionState := 0;
                  Galaxy.Holes.Delete(EntryIndex);
                  Hole.Free;
                  Dec(EntryIndex);
                end;
              end;
            end;
            Inc(EntryIndex);
          end;
        end;
      end;
      Stage := 2990;
      if RecordFilm then
        PrimaryFilm.AdvanceObjects(StepIndex);
      Inc(StepIndex);
      Self.CurrentStepIndex := StepIndex;
      Stage := 2999;
      for Index := 0 to (Self.ReferencedItems.Count - 1) do
      begin
        Item := Self.ReferencedItems[Index];
        if Self.Items.IndexOf(Item) >= 0 then
          Item.DestroyFlag := Max(1, Item.DestroyFlag);
      end;
      Self.ReferencedItems.Clear;
    end;

    Stage := 29999;
    Self.ProcessItemScripts(11);
    EntryIndex := 0;
    while Self.Items.Count > EntryIndex do
    begin
      Item := Self.Items[EntryIndex];
      if Self.DamageRadius * Self.DamageRadius > Sqr(Item.Position.X) + Sqr(Item.Position.Y) then
      begin
        Self.ClearItemReferences(Item);
        if RecordFilm then
        begin
          ReleaseSpaceObject(Item.GraphObject);
          Self.PendingFilmObjectRemovals.Add(Item.FilmObject);
        end;
        Self.Items.Delete(EntryIndex);
        Item.Free;
      end
      else
        Inc(EntryIndex);
    end;
    for Index := 0 to (Self.Ships.Count - 1) do
    begin
      Ship := Self.Ships[Index];
      if Ship.DestroyQueued and (not Ship.IsHullDestroyed
        and ((GetPlayer <> Ship) or (Byte(GlobalsV.CurrentScreenId) = 16))) then
      begin
        Ship.ScriptItemsAct(satOnDeath, nil, nil, 0);
        Ship.GetHull.HullPoints := 0;
        if Ship.IsHullDestroyed and (GetPlayer <> nil) then
          GetPlayer.ProcessShipDestructionQuests(Ship);
        Ship.RefreshDerivedStats(True);
        if RecordFilm and ((Ship.FilmObject <> nil) and ((Ship.CurrentPlanet = nil) and (Ship.DockedTo = nil))) then
        begin
          CreateFilmEffect('Weapon.NoGraph', 0, Effect, EffectFilm);
          PrimaryFilm.SetWeaponEndpoints(StepIndex, EffectFilm, Ship.FilmObject, Ship.FilmObject);
          PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, Ship.IsHullDestroyed, True);
          PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        end;
        Self.ClearShipReferences(Ship);
      end;
    end;

    Stage := 30;
    if RecordFilm and (Self.PlayerFilmPath <> nil) then
    begin
      WorkCount := 0;
      TSPath(Self.PlayerFilmPath).AppendWaypoint(GetPlayer.Position, StepIndex);
      Node := Self.PlayerFilmPath.ActiveHead;
      Point := Node^.Position;
      PathStep := Integer(System.Round(Node^.Heading));
      Node := Node^.Next;
      while (Node <> nil) and not (PathStep < System.Round(Node^.Heading)) do
        Node := Node^.Next;
      while Node <> nil do
      begin
        EntryCount := Integer(System.Round(Node^.Heading)) - PathStep + 1;
        WorkValue := PointDistance(Point, Node^.Position);
        if (WorkValue > 200.0) or (WorkValue > 0.0) and (Self.PlayerFilmPath.ActiveTail = Node) then
        begin
          Delta.X := (Node^.Position.X - Point.X) / WorkValue;
          Delta.Y := (Node^.Position.Y - Point.Y) / WorkValue;
          WorkValue := WorkValue / EntryCount;
          if (WorkCount = 0) or (Self.PlayerFilmPath.ActiveTail = Node) then
          begin
            if FastCameraSpeed < WorkValue then
              WorkValue := FastCameraSpeed;
            if CameraSpeed < WorkValue then
              WorkCount := 1;
          end
          else
          begin
            if CameraSpeed < WorkValue then
              WorkValue := CameraSpeed;
          end;
          Delta.X := Delta.X * WorkValue;
          Delta.Y := Delta.Y * WorkValue;
          for EntryIndex := 0 to (EntryCount - 1) do
          begin
            Point.X := Point.X + Delta.X;
            Point.Y := Point.Y + Delta.Y;
            Inc(PathStep);
          end;
        end;
        Node := Node^.Next;
        while (Node <> nil) and not (PathStep < System.Round(Node^.Heading)) do
          Node := Node^.Next;
      end;
      Self.PlayerFilmPath.Free;
      Self.PlayerFilmPath := nil;
    end;

    Stage := 31;
    for Index := 0 to (Self.Ships.Count - 1) do
    begin
      Ship := Self.Ships[Index];
      Ship.ClearCompletedTakeoffOrHoleOrder(StepIndex, RecordFilm);
      if (Ship.InterceptorGraphic <> nil) and (Ship.InterceptorPassesRemaining = 0) or not Ship.InNormalSpace
        and (Ship.InterceptorPassesRemaining > 0) then
      begin
        if Ship.AuxiliaryFilmObject <> nil then
          PrimaryFilm.DetachObject(StepIndex, Ship.AuxiliaryFilmObject);
        Ship.InterceptorSourceShip := nil;
        Ship.InterceptorPassesRemaining := 0;
      end;
    end;
    if GetPlayer <> nil then
      GetPlayer.AchievementStats.CheckTranclucatorFleetAchievement;

    Stage := 32;
    EntryCount := Self.MovingDropItems.Count;
    for EntryIndex := 0 to (EntryCount - 1) do
    begin
      MovingDrop := Self.MovingDropItems[EntryIndex];
      if not MovingDrop^.InsertedIntoStar and (MovingDrop^.Payload <> nil) then
      begin
        Item := TObject(MovingDrop^.Payload) as TItem;
        if (Item is TArtefactTranclucator) and (MovingDrop^.DeployTranclucator <> 0) then
        begin
          Tranclucator := TObject((Item as TArtefactTranclucator).Ship) as TTranclucator;
          (Item as TArtefactTranclucator).Ship := nil;
          Tranclucator.CurrentStar := Self;
          Self.Ships.Add(Tranclucator);
          Tranclucator.Position := MovingDrop^.Destination;
          Tranclucator.MovementDirection := 0.0;
          Item.Free;
          if RecordFilm then
          begin
            Tranclucator.FilmObject := PrimaryFilm.AddObject(Tranclucator.Id, Tranclucator.Graphic);
            PrimaryFilm.DetachObject(0, Tranclucator.FilmObject);
            PrimaryFilm.SetObjectPosition(StepIndex, Tranclucator.FilmObject, Self.Position);
            PrimaryFilm.SetObjectAngle(StepIndex, Tranclucator.FilmObject, 0);
            PrimaryFilm.SetObjectAlpha(StepIndex, Tranclucator.FilmObject, 255);
            PrimaryFilm.AttachObject(StepIndex, Tranclucator.FilmObject);
          end;
        end
        else
        begin
          Item.Position := MovingDrop^.Destination;
          Self.Items.Add(Item);
          MovingDrop^.InsertedIntoStar := True;
          if RecordFilm then
          begin
            Item.FilmObject := PrimaryFilm.AddObject(Item.Id, Item.GetGraphObject);
            PrimaryFilm.DetachObject(0, Item.FilmObject);
            PrimaryFilm.SetObjectPosition(StepIndex, Item.FilmObject, Self.Position);
            PrimaryFilm.AttachObject(StepIndex, Item.FilmObject);
          end;
        end;
      end;
      FreeEC(MovingDrop);
    end;
    Self.MovingDropItems.Clear;

    Stage := 33;
    if RecordFilm then
    begin
      Inc(StepIndex);
      Self.CurrentStepIndex := StepIndex;
      PrimaryFilm.BeginTrailingEffects(StepIndex);
      Inc(StepIndex);
      Self.CurrentStepIndex := StepIndex;
    end;
    if RecordFilm then
      PrimaryFilm.ReleaseWeaponEffects(StepIndex);

    Stage := 34;
    Count := Self.CombatEvents.Count;
    for Index := 0 to (Count - 1) do
    begin
      CombatEvent := Self.CombatEvents[Index];
      FreeEC(CombatEvent);
    end;
    Self.CombatEvents.Clear;

    Stage := 35;
    if not RecordFilm and ((GetPlayer <> nil) and (GetPlayer.CurrentStar <> Self)) then
    begin
      Index := 0;
      while Self.Ships.Count > Index do
      begin
        Ship := Self.Ships[Index];
        if Ship.IsHullDestroyed and (Ship is TRanger) then
          Ship.TryRelocateUnseenShip;
        Inc(Index);
      end;
    end;

    Stage := 36;
    Index := 0;
    while Self.Ships.Count > Index do
    begin
      Ship := Self.Ships[Index];
      if (Ship.DockedTo <> nil) and Ship.DockedTo.IsHullDestroyed then
      begin
        Ship.ScriptItemsAct(satOnDeath, nil, nil, 0);
        Self.ClearShipReferences(Ship);
        Ship.DockedTo := nil;
        Ship.GetHull.HullPoints := 0;
        if Ship.IsHullDestroyed then
        begin
          if GetPlayer <> nil then
          begin
            GetPlayer.ProcessShipDestructionQuests(Ship);
            if GetPlayer = Ship then
            begin
              Globals.ScoreScreen.RecordPlayerResult(False);
              DeathEvent := AddGalaxyEvent('PlayerDeath');
              TGalaxyEvent(DeathEvent).AddTextData('StationDestroyed');
            end;
          end;
        end;
        Index := 0;
        if RecordFilm and (Ship.FilmObject = nil) then
        begin
          Ship.FilmObject := PrimaryFilm.AddObject(Ship.Id, Ship.Graphic);
          PrimaryFilm.DetachObject(0, Ship.FilmObject);
        end;
      end
      else
        Inc(Index);
    end;

    Stage := 37;
    Index := 0;
    StationDestroyed := 0;
    while Self.Ships.Count > Index do
    begin
      Ship := Self.Ships[Index];
      if Ship.IsHullDestroyed then
      begin
        if RecordFilm then
        begin
          EntryCount := Ship.Inventory.Count;
          for EntryIndex := 0 to (EntryCount - 1) do
          begin
            Item := Ship.Inventory[EntryIndex];
            if PrimaryFilm.ContainsObject(Item.FilmObject) then
            begin
              PrimaryFilm.ReleaseObject(StepIndex, Item.FilmObject);
              ReleaseSpaceObject(Item.GraphObject);
            end;
          end;
          EntryCount := Ship.Artefacts.Count;
          for EntryIndex := 0 to (EntryCount - 1) do
          begin
            Item := Ship.Artefacts[EntryIndex];
            if PrimaryFilm.ContainsObject(Item.FilmObject) then
            begin
              PrimaryFilm.ReleaseObject(StepIndex, Item.FilmObject);
              ReleaseSpaceObject(Item.GraphObject);
            end;
          end;
          if Ship.FilmObject = nil then
          begin
            Ship.FilmObject := PrimaryFilm.AddObject(Ship.Id, Ship.Graphic);
            PrimaryFilm.DetachObject(0, Ship.FilmObject);
          end;
          if Ship.FilmObject <> nil then
          begin
            PrimaryFilm.ReleaseObject(StepIndex, Ship.FilmObject);
            ReleaseSpaceObject(Ship.Graphic);
          end;
          if Ship.AuxiliaryFilmObject <> nil then
          begin
            PrimaryFilm.ReleaseObject(StepIndex, Ship.AuxiliaryFilmObject);
            ReleaseSpaceObject(Ship.InterceptorGraphic);
          end;
        end;
        if Ship is TRuins then
          StationDestroyed := 1;
        if GetPlayer = Ship then
        begin
          Globals.ScoreScreen.RecordPlayerResult(False);
          while ((Byte(GlobalsV.CurrentScreenId) = 19) or (Byte(GlobalsV.CurrentScreenId) = 21))
            and (Galaxy.ScoreScreenDismissed = 0) do
            SysUtils.Sleep(1);
          Galaxy.ScoreScreenDismissed := 0;
        end;
        Self.Ships.Delete(Index);
        Ship.Free;
      end
      else
      begin
        if not Ship.InNormalSpace then
          Ship.InterceptorPassesRemaining := 0;
        if (Ship.InterceptorPassesRemaining <= 0) and (Ship.InterceptorGraphic <> nil) then
        begin
          if RecordFilm and (Ship.AuxiliaryFilmObject <> nil) then
          begin
            PrimaryFilm.ReleaseObject(StepIndex, Ship.AuxiliaryFilmObject);
            ReleaseSpaceObject(Ship.InterceptorGraphic);
          end;
          Ship.ClearIncomingInterceptors;
        end;
        Inc(Index);
      end;
    end;
    if (StationDestroyed <> 0) and (GetPlayer <> nil) then
      GetPlayer.RefreshStorageBubbles;

    Stage := 38;
    Index := 0;
    while Self.Ships.Count > Index do
    begin
      Ship := Self.Ships[Index];
      if (Ship is TTranclucator)
        and ((Ord(TTranclucator(Ship).FollowOwner) <> 0) and (TTranclucator(Ship).OwnerShip <> nil)) then
      begin
        OwnerShip := TTranclucator(Ship).OwnerShip;
        if (OwnerShip.CurrentPlanet <> nil)
          and (PointDistanceSquared(Ship.Position, TPlanet(OwnerShip.CurrentPlanet).GetPosition) < 25.0)
          or ((OwnerShip.DockedTo <> nil)
          and (PointDistanceSquared(Ship.Position, OwnerShip.DockedTo.Position) < 25.0) or OwnerShip.InNormalSpace
          and (PointDistanceSquared(Ship.Position, OwnerShip.Position) < 25.0)) then
        begin
          Self.HandleObjectLeavingStar(Ship);
          Ship.EnemyShip := nil;
          Ship.TruceShip := nil;
          Ship.PartnerShip := nil;
          Ship.OrderNone(False);
          Ship.AfterburnerActive := False;
          for EntryIndex := 1 to Ship.WeaponCount do
            Ship.Weapons[EntryIndex].Target := nil;
          if RecordFilm then
            PrimaryFilm.DetachObject(StepIndex, Ship.FilmObject);
          Self.Ships.Delete(Index);
          Ship.CurrentStar := nil;
          if Ship.ScriptShip <> nil then
            TScript((TObject(Ship.ScriptShip) as TScriptShip).Script).UnbindShip(Ship);
          StoredTranclucator := TArtefactTranclucator.Create;
          TArtefactTranclucator(StoredTranclucator).InitTranclucator(Ship.GetHull.OwnerId, OwnerShip, TTranclucator(Ship));
          if Ship.GetEngine <> nil then
            Ship.GetEngine.OutputPercent := 100;
          TTranclucator(Ship).TransferUnequippedCargo(OwnerShip);
          OwnerShip.Artefacts.Add(StoredTranclucator);
          OwnerShip.RefreshDerivedStats(True);
          TTranclucator(Ship).FollowOwner := False;
          Ship.ScriptItemsAct(satOnTrancPacking, StoredTranclucator, OwnerShip, 0);
          OwnerShip.ScriptItemsAct(satOnTrancPacking, StoredTranclucator, OwnerShip, 0);
        end
        else
          Inc(Index);
      end
      else
        Inc(Index);
    end;

    Stage := 39;
    if RecordFilm then
    begin
      Index := 0;
      while Galaxy.JumpGates.Count > Index do
      begin
        GateEntry := Galaxy.JumpGates[Index];
        if GateEntry^.UsedThisTurn then
        begin
          PrimaryFilm.ReleaseObject(StepIndex, Pointer(GateEntry^.GateFilmId));
          if GateEntry^.EffectFilmId <> 0 then
            PrimaryFilm.ReleaseObject(StepIndex, Pointer(GateEntry^.EffectFilmId));
          Galaxy.JumpGates.Delete(Index);
          if GateEntry^.Gate <> nil then
            ReleaseSpaceObject(GateEntry^.Gate);
          if GateEntry^.Effect <> nil then
            ReleaseSpaceObject(GateEntry^.Effect);
          FreeEC(GateEntry);
        end
        else
          Inc(Index);
      end;
    end;
    Self.PruneWeaponTargetsAfterTurn;

    Stage := 40;
    if RecordFilm then
    begin
      EntryCount := Self.PendingFilmObjectRemovals.Count;
      for EntryIndex := 0 to (EntryCount - 1) do
      begin
        EffectFilm := Self.PendingFilmObjectRemovals[EntryIndex];
        PrimaryFilm.ReleaseObject(StepIndex, EffectFilm);
      end;
      Self.PendingFilmObjectRemovals.Clear;
    end;
    Self.ReferencedItems.Clear;
    PrimaryFilm.PlayerCombatRecorded := RecordFilm and Self.PlayerCombatOccurred;
    for Index := (Self.Ships.Count - 1) downto 0 do
    begin
      Ship := Self.Ships[Index];
      Ship.RefreshCurrentStanding;
    end;
    Self.RefreshDerivedStats;

    Stage := 41;
    if not Globals.PlayerStarDayPrepared and (Galaxy.StasisModEnabled <> 1) then
      for Index := 0 to (Self.Planets.Count - 1) do
      begin
        Planet := Self.Planets[Index];
        TPlanet(Planet).NextDay;
      end;
    for Index := (Self.Ships.Count - 1) downto 0 do
    begin
      Ship := Self.Ships[Index];
      Ship.RefreshCurrentStanding;
    end;
    if (Self.LiberationRewardsPending) and (GetPlayer <> nil) then
    begin
      ProcessSystemLiberationRewards(GetPlayer, Self);
      Self.LastLiberationRewardsTurn := Cardinal(Galaxy.CurrentTurn);
      Self.LiberationRewardsPending := False;
    end;

    Stage := 42;
    if RecordFilm then
    begin
      if Self.PlayerCombatOccurred then
      begin
        PrimaryFilm.InitialActivity := 0;
        PrimaryFilm.FinalActivity := 0;
      end
      else
      begin
        PrimaryFilm.InitialActivity := Integer(Globals.PreviousFilmActivity);
        PrimaryFilm.FinalActivity := PrimaryFilm.InitialActivity;
        WorkValue := EstimatePlayerTravelTurns;
        if Globals.PreviousFilmActivity = 0 then
        begin
          if WorkValue >= 1.0 then
            PrimaryFilm.FinalActivity := 1;
        end
        else
        begin
          if Globals.PreviousFilmActivity = 1 then
          begin
            if WorkValue >= 2.0 then
              PrimaryFilm.FinalActivity := 2;
          end
          else
          begin
            if (Globals.PreviousFilmActivity = 2) and (WorkValue <= 2.0) then
              PrimaryFilm.FinalActivity := 1;
          end;
        end;
        Globals.PreviousFilmActivity := Cardinal(PrimaryFilm.FinalActivity);
      end;
      TFilmFile(FilmHistory).AddFilm(TEFilm(PrimaryFilm));
    end;

    Stage := 43;
    if (Galaxy.TerronToStarTurn > 0) and (Galaxy.TerronToStarTurn < TerronTransformationFlag) then
    begin
      if aKling.TerronShip <> nil then
      begin
        if aKling.TerronShip.CurrentStar = Self then
        begin
          if PointDistanceSquared(MakePointF(-100.0, -100.0), aKling.TerronShip.Position) < 25.0 then
          begin
            Galaxy.TerronToStarTurn := Galaxy.CurrentTurn or TerronTransformationFlag;
            PWideString(@Self.Graphic.GraphKey)^ := WideString('Star.TerronAfter');
            Self.Graphic.LoadTemplate(GR_Main.GameDataConfig.GetBlockByPath('SE.' + WideString(Self.Graphic.GraphKey)));
            if GetPlayer <> nil then
            begin
              if GetPlayer.CurrentStar <> Self then
              begin
                aKling.TerronShip.Order := soJump;
                aKling.TerronShip.OrderTarget := Self;
                aKling.TerronShip.InHyperspace := True;
                aKling.TerronShip.OrderStateData := 2;
                aKling.TerronShip.Position := MakePointF(0.0, 0.0);
              end;
            end;
          end;
        end;
      end;
    end;

    Stage := 44;
    if (GetPlayer <> nil) and ((GetPlayer.CurrentStar = Self)
      and ((aRanger.PendingPlayerFollowTarget <> nil)
      and ((aRanger.PendingPlayerFollowTarget.CurrentStar <> Self)
      or not aRanger.PendingPlayerFollowTarget.InNormalSpace))) then
    begin
      aRanger.PendingPlayerFollowTarget := nil;
      GetPlayer.OrderNone(False);
    end;
    Self.RecordingTurnFilm := False;
    if (GetPlayer <> nil) and (GetPlayer.CurrentStar = Self) then
      GetPlayer.AchievementStats.CheckBomberAchievement(GetPlayer.BombKillsThisTurn);
    aShip.SimulationContext := 0;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(AnsiString(E.ClassName + ' ' + E.Message));
      raise Exception.Create('Error in procedure TStar.NextDay ' + WideString(Self.Name) + ' label = ' + SysUtils.IntToStr(Stage));
    end;
  end;
end;
{ @end $7C70CC }

{ @routine $7D0BF4 TGalaxy_ShowLocalizedWarning }
procedure TGalaxy.ShowLocalizedWarning(TextKey: WideString);
begin
  AddOrUpdatePlayerBubble(pmQuestCancelled, 0, LocalizedColorText(TextKey), '');
end;
{ @end $7D0BF4 }

{ @routine $7D0C5C TInterfaceStateOverride_Create }
constructor TInterfaceStateOverride.Create;
begin
  inherited Create;
end;
{ @end $7D0C5C }

{ @routine $7D0CA0 TInterfaceStateOverride_Destroy }
destructor TInterfaceStateOverride.Destroy;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(FormName);
  if Form <> nil then begin
    Control := Form.FindControlByPath(ControlPath);
    if Control <> nil then begin
      Control.SetActive(OriginalState > 0);
      if (OriginalState > 1) and (Control is TGraphButtonGI) then TGraphButtonGI(Control).SetDisabled(OriginalState = 2);
    end;
  end;
  inherited Destroy;
end;
{ @end $7D0CA0 }

{ @routine $7D0D3C TInterfaceStateOverride_Initialize }
procedure TInterfaceStateOverride.Initialize(FormName, ControlPath: WideString; State: Byte);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.FormName := FormName;
  Self.ControlPath := ControlPath;
  Self.State := State;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceStateOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    OriginalState := Ord(Control.Active);
    Control.SetActive(Self.State > 0);
    if (OriginalState > 0) and (Control is TGraphButtonGI) then OriginalState := 3 - Ord(TGraphButtonGI(Control).Disabled);
    if (Self.State > 1) and (Control is TGraphButtonGI) then TGraphButtonGI(Control).SetDisabled(Self.State = 2);
  end;
end;
{ @end $7D0D3C }

{ @routine $7D0F90 TInterfaceStateOverride_SetState }
procedure TInterfaceStateOverride.SetState(State: Byte);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.State := State;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceStateOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    Control.SetActive(Self.State > 0);
    if (Self.State > 1) and (Control is TGraphButtonGI) then TGraphButtonGI(Control).SetDisabled(Self.State = 2);
  end;
end;
{ @end $7D0F90 }

{ @routine $7D116C TInterfaceStateOverride_GetState }
function TInterfaceStateOverride.GetState: Byte;
begin
  Result := State;
end;
{ @end $7D116C }

{ @routine $7D1188 TInterfaceStateOverride_SaveToBuffer }
procedure TInterfaceStateOverride.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(FormName);
  Buffer.AddWideStringZ(ControlPath);
  Buffer.AddAnsiChar(AnsiChar(State));
  Buffer.AddAnsiChar(AnsiChar(OriginalState));
end;
{ @end $7D1188 }

{ @routine $7D11D0 TInterfaceStateOverride_LoadFromBuffer }
procedure TInterfaceStateOverride.LoadFromBuffer(Buffer: TBufEC);
begin
  FormName := Buffer.ReadWideString;
  ControlPath := Buffer.ReadWideString;
  if LoadedSaveVersion >= 160 then begin
    State := Buffer.GetByte;
    OriginalState := Buffer.GetByte;
  end else begin
    State := Ord(Buffer.GetBoolean);
    OriginalState := Ord(Buffer.GetBoolean);
  end;
  Reapply;
end;
{ @end $7D11D0 }

{ @routine $7D129C TInterfaceStateOverride_Reapply }
procedure TInterfaceStateOverride.Reapply;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceStateOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    Control.SetActive(Self.State > 0);
    if (Self.State > 1) and (Control is TGraphButtonGI) then TGraphButtonGI(Control).SetDisabled(Self.State = 2);
  end;
end;
{ @end $7D129C }

{ @routine $7D1464 TInterfaceTextOverride_Create }
constructor TInterfaceTextOverride.Create;
begin
  inherited Create;
end;
{ @end $7D1464 }

{ @routine $7D14A8 TInterfaceTextOverride_Destroy }
destructor TInterfaceTextOverride.Destroy;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(FormName);
  if Form <> nil then begin
    Control := Form.FindControlByPath(ControlPath);
    if Control <> nil then begin
      if not (Control is TLabelGI) then AppendLogLineThreadSafe(AnsiString('Object is not a label - ' + ControlPath))
      else (Control as TLabelGI).SetText(OriginalText);
    end;
  end;
  inherited Destroy;
end;
{ @end $7D14A8 }

{ @routine $7D15CC TInterfaceTextOverride_Initialize }
procedure TInterfaceTextOverride.Initialize(FormName, ControlPath: WideString; Text: WideString);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.FormName := FormName;
  Self.ControlPath := ControlPath;
  Self.Text := Text;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceTextOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    if not (Control is TLabelGI) then raise Exception.Create(AnsiString('Object is not a label - ' + Self.ControlPath));
    OriginalText := (Control as TLabelGI).GetText;
    (Control as TLabelGI).SetText(Self.Text);
  end;
end;
{ @end $7D15CC }

{ @routine $7D188C TInterfaceTextOverride_SetText }
procedure TInterfaceTextOverride.SetText(Text: WideString);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.Text := Text;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceTextOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    if not (Control is TLabelGI) then raise Exception.Create(AnsiString('Object is not a label - ' + Self.ControlPath));
    (Control as TLabelGI).SetText(Self.Text);
  end;
end;
{ @end $7D188C }

{ @routine $7D1AD8 TInterfaceTextOverride_GetText }
function TInterfaceTextOverride.GetText: WideString;
begin
  Result := Text;
end;
{ @end $7D1AD8 }

{ @routine $7D1AF8 TInterfaceTextOverride_SaveToBuffer }
procedure TInterfaceTextOverride.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(FormName);
  Buffer.AddWideStringZ(ControlPath);
  Buffer.AddWideStringZ(Text);
  Buffer.AddWideStringZ(OriginalText);
end;
{ @end $7D1AF8 }

{ @routine $7D1B40 TInterfaceTextOverride_LoadFromBuffer }
procedure TInterfaceTextOverride.LoadFromBuffer(Buffer: TBufEC);
begin
  FormName := Buffer.ReadWideString;
  ControlPath := Buffer.ReadWideString;
  Text := Buffer.ReadWideString;
  OriginalText := Buffer.ReadWideString;
  Reapply;
end;
{ @end $7D1B40 }

{ @routine $7D1BF4 TInterfaceTextOverride_Reapply }
procedure TInterfaceTextOverride.Reapply;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceTextOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    if not (Control is TLabelGI) then raise Exception.Create(AnsiString('Object is not a label - ' + Self.ControlPath));
    (Control as TLabelGI).SetText(Self.Text);
  end;
end;
{ @end $7D1BF4 }

{ @routine $7D1E20 TInterfaceImageOverride_Create }
constructor TInterfaceImageOverride.Create;
begin
  inherited Create;
end;
{ @end $7D1E20 }

{ @routine $7D1E64 TInterfaceImageOverride_Destroy }
destructor TInterfaceImageOverride.Destroy;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(FormName);
  if Form <> nil then begin
    Control := Form.FindControlByPath(ControlPath);
    if Control <> nil then begin
      if (CountDelimitedPartsW(ImagePath, ':') > 1) and (ExtractDelimitedPartW(ImagePath, 0, ':') = 'Style') then begin
        if OriginalImagePath <> '' then Control.SetConfigPath(OriginalImagePath);
      end else if Control is TgaiGI then begin
        // Native tests the replacement path before restoring the original.
        if CountDelimitedPartsW(ImagePath, '|') < 2 then
          TgaiGI(Control).SetImagePath(OriginalImagePath)
        else
        begin
          TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(OriginalImagePath, 1, '|'));
          TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(OriginalImagePath, 0, '|'));
        end;
        TgaiGI(Control).PrimeImageCaches;
        TgaiGI(Control).SequenceIndex := 0;
        TgaiGI(Control).UpdateAutoGeometry;
        TgaiGI(Control).RestartPlayback;
      end
      else if Control is TgiGI then (Control as TgiGI).SetImagePath(OriginalImagePath)
      else if Control is TImageGI then (Control as TImageGI).SetImagePath(OriginalImagePath)
      else AppendLogLineThreadSafe(AnsiString('Object is not an image - ' + ControlPath));
    end;
  end;
  inherited Destroy;
end;
{ @end $7D1E64 }

{ @routine $7D20F4 TInterfaceImageOverride_Initialize }
procedure TInterfaceImageOverride.Initialize(FormName, ControlPath: WideString; ImagePath: WideString);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.FormName := FormName;
  Self.ControlPath := ControlPath;
  Self.ImagePath := ImagePath;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceImageOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName + ' (' + Self.ImagePath + ')'))
  else begin
    if (CountDelimitedPartsW(Self.ImagePath, ':') > 1) and (ExtractDelimitedPartW(Self.ImagePath, 0, ':') = 'Style') then begin
      OriginalImagePath := Control.ConfigPath;
      Control.SetConfigPath(ExtractDelimitedPartW(Self.ImagePath, 1, ':'));
    end else if Control is TgaiGI then begin
      OriginalImagePath := TgaiGI(Control).GetImagePath;
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        OriginalImagePath := OriginalImagePath + '|' + TgaiGI(Control).GetFirstFrameImagePath;
      if CountDelimitedPartsW(Self.ImagePath, '|') < 2 then
        TgaiGI(Control).SetImagePath(Self.ImagePath)
      else
      begin
        TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(Self.ImagePath, 1, '|'));
        TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(Self.ImagePath, 0, '|'));
      end;
      TgaiGI(Control).PrimeImageCaches;
      TgaiGI(Control).SequenceIndex := 0;
      TgaiGI(Control).UpdateAutoGeometry;
      TgaiGI(Control).RestartPlayback;
    end else if Control is TgiGI then begin
      OriginalImagePath := (Control as TgiGI).GetImagePath;
      (Control as TgiGI).SetImagePath(Self.ImagePath);
    end else if Control is TImageGI then begin
      OriginalImagePath := (Control as TImageGI).GetImagePath;
      (Control as TImageGI).SetImagePath(Self.ImagePath);
    end else raise Exception.Create(AnsiString('Object is not an image - ' + Self.ControlPath));
  end;
end;
{ @end $7D20F4 }

{ @routine $7D25C8 TInterfaceImageOverride_SetImagePath }
procedure TInterfaceImageOverride.SetImagePath(ImagePath: WideString);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.ImagePath := ImagePath;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceImageOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName + ' (' + Self.ImagePath + ')'))
  else begin
    if (CountDelimitedPartsW(Self.ImagePath, ':') > 1) and (ExtractDelimitedPartW(Self.ImagePath, 0, ':') = 'Style') then begin
      Control.SetConfigPath(ExtractDelimitedPartW(Self.ImagePath, 1, ':'));
    end else if Control is TgaiGI then begin
      if CountDelimitedPartsW(Self.ImagePath, '|') < 2 then
        TgaiGI(Control).SetImagePath(Self.ImagePath)
      else
      begin
        TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(OriginalImagePath, 1, '|'));
        TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(OriginalImagePath, 0, '|'));
      end;
      TgaiGI(Control).PrimeImageCaches;
      TgaiGI(Control).SequenceIndex := 0;
      TgaiGI(Control).UpdateAutoGeometry;
      TgaiGI(Control).RestartPlayback;
    end else if Control is TgiGI then begin
      (Control as TgiGI).SetImagePath(Self.ImagePath);
    end else if Control is TImageGI then begin
      (Control as TImageGI).SetImagePath(Self.ImagePath);
    end else raise Exception.Create(AnsiString('Object is not an image - ' + Self.ControlPath));
  end;
end;
{ @end $7D25C8 }

{ @routine $7D29A0 TInterfaceImageOverride_GetImagePath }
function TInterfaceImageOverride.GetImagePath: WideString;
begin
  Result := ImagePath;
end;
{ @end $7D29A0 }

{ @routine $7D29C0 TInterfaceImageOverride_SaveToBuffer }
procedure TInterfaceImageOverride.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(FormName);
  Buffer.AddWideStringZ(ControlPath);
  Buffer.AddWideStringZ(ImagePath);
  Buffer.AddWideStringZ(OriginalImagePath);
end;
{ @end $7D29C0 }

{ @routine $7D2A08 TInterfaceImageOverride_LoadFromBuffer }
procedure TInterfaceImageOverride.LoadFromBuffer(Buffer: TBufEC);
begin
  FormName := Buffer.ReadWideString;
  ControlPath := Buffer.ReadWideString;
  ImagePath := Buffer.ReadWideString;
  OriginalImagePath := Buffer.ReadWideString;
  Reapply;
end;
{ @end $7D2A08 }

{ @routine $7D2ABC TInterfaceImageOverride_Reapply }
procedure TInterfaceImageOverride.Reapply;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceImageOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName + ' (' + Self.ImagePath + ')'))
  else begin
    if (CountDelimitedPartsW(Self.ImagePath, ':') > 1) and (ExtractDelimitedPartW(Self.ImagePath, 0, ':') = 'Style') then begin
      Control.SetConfigPath(ExtractDelimitedPartW(Self.ImagePath, 1, ':'));
    end else if Control is TgaiGI then begin
      if CountDelimitedPartsW(Self.ImagePath, '|') < 2 then
        TgaiGI(Control).SetImagePath(Self.ImagePath)
      else
      begin
        TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(Self.ImagePath, 1, '|'));
        TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(Self.ImagePath, 0, '|'));
      end;
      TgaiGI(Control).PrimeImageCaches;
      TgaiGI(Control).SequenceIndex := 0;
      TgaiGI(Control).UpdateAutoGeometry;
      TgaiGI(Control).RestartPlayback;
    end else if Control is TgiGI then begin
      (Control as TgiGI).SetImagePath(Self.ImagePath);
    end else if Control is TImageGI then begin
      (Control as TImageGI).SetImagePath(Self.ImagePath);
    end else raise Exception.Create(AnsiString('Object is not an image - ' + Self.ControlPath));
  end;
end;
{ @end $7D2ABC }

{ @routine $7D2E74 TInterfacePosOverride_Create }
constructor TInterfacePosOverride.Create;
begin
  inherited Create;
end;
{ @end $7D2E74 }

{ @routine $7D2EB8 TInterfacePosOverride_Destroy }
destructor TInterfacePosOverride.Destroy;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(FormName);
  if Form <> nil then begin
    Control := Form.FindControlByPath(ControlPath);
    if Control <> nil then begin
      Control.SetPosition(Classes.Point(OriginalPosition.X, OriginalPosition.Y));
      Control.SetDepth(OriginalDepth);
    end;
  end;
  inherited Destroy;
end;
{ @end $7D2EB8 }

{ @routine $7D2F44 TInterfacePosOverride_Initialize }
procedure TInterfacePosOverride.Initialize(FormName, ControlPath: WideString; DeltaX, DeltaY, DeltaDepth: Integer);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.FormName := FormName;
  Self.ControlPath := ControlPath;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfacePosOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    OriginalPosition.X := Control.LocalPosition.X;
    OriginalPosition.Y := Control.LocalPosition.Y;
    OriginalDepth := Control.Depth;
    Position.X := DeltaX + OriginalPosition.X;
    Position.Y := DeltaY + OriginalPosition.Y;
    Depth := OriginalDepth + DeltaDepth;
    Control.SetPosition(Classes.Point(Position.X, Position.Y));
    Control.SetDepth(Depth);
  end;
end;
{ @end $7D2F44 }

{ @routine $7D31A0 TInterfacePosOverride_SetPosition }
procedure TInterfacePosOverride.SetPosition(DeltaX, DeltaY, DeltaDepth: Integer);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfacePosOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    Position.X := DeltaX + OriginalPosition.X;
    Position.Y := DeltaY + OriginalPosition.Y;
    Depth := OriginalDepth + DeltaDepth;
    Control.SetPosition(Classes.Point(Position.X, Position.Y));
    Control.SetDepth(Depth);
  end;
end;
{ @end $7D31A0 }

{ @routine $7D3394 TInterfacePosOverride_SaveToBuffer }
procedure TInterfacePosOverride.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(FormName);
  Buffer.AddWideStringZ(ControlPath);
  Buffer.AddIntegerValue(Position.X);
  Buffer.AddIntegerValue(Position.Y);
  Buffer.AddDouble(Depth);
  Buffer.AddIntegerValue(OriginalPosition.X);
  Buffer.AddIntegerValue(OriginalPosition.Y);
  Buffer.AddDouble(OriginalDepth);
end;
{ @end $7D3394 }

{ @routine $7D341C TInterfacePosOverride_LoadFromBuffer }
procedure TInterfacePosOverride.LoadFromBuffer(Buffer: TBufEC);
begin
  FormName := Buffer.ReadWideString;
  ControlPath := Buffer.ReadWideString;
  Position.X := Buffer.GetInt32;
  Position.Y := Buffer.GetInt32;
  Depth := Buffer.GetDouble;
  OriginalPosition.X := Buffer.GetInt32;
  OriginalPosition.Y := Buffer.GetInt32;
  OriginalDepth := Buffer.GetDouble;
  Reapply;
end;
{ @end $7D341C }

{ @routine $7D34F4 TInterfacePosOverride_Reapply }
procedure TInterfacePosOverride.Reapply;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfacePosOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    Control.SetPosition(Classes.Point(Position.X, Position.Y));
    Control.SetDepth(Depth);
  end;
end;
{ @end $7D34F4 }

{ @routine $7D36B0 TInterfaceSizeOverride_Create }
constructor TInterfaceSizeOverride.Create;
begin
  inherited Create;
end;
{ @end $7D36B0 }

{ @routine $7D36F4 TInterfaceSizeOverride_Destroy }
destructor TInterfaceSizeOverride.Destroy;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(FormName);
  if Form <> nil then begin
    Control := Form.FindControlByPath(ControlPath);
    if Control <> nil then begin
      Control.SetSize(Classes.Point(OriginalSize.X, OriginalSize.Y));
    end;
  end;
  inherited Destroy;
end;
{ @end $7D36F4 }

{ @routine $7D3770 TInterfaceSizeOverride_Initialize }
procedure TInterfaceSizeOverride.Initialize(FormName, ControlPath: WideString; Width, Height: Integer);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Self.FormName := FormName;
  Self.ControlPath := ControlPath;
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceSizeOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    OriginalSize.X := Control.ClientSize.X;
    OriginalSize.Y := Control.ClientSize.Y;
    if Width > 0 then Size.X := Width else Size.X := OriginalSize.X;
    if Height > 0 then Size.Y := Height else Size.Y := OriginalSize.Y;
    Control.SetSize(Classes.Point(Size.X, Size.Y));
  end;
end;
{ @end $7D3770 }

{ @routine $7D39B0 TInterfaceSizeOverride_SetSize }
procedure TInterfaceSizeOverride.SetSize(Width, Height: Integer);
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceSizeOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    if Width > 0 then Size.X := Width else Size.X := OriginalSize.X;
    if Height > 0 then Size.Y := Height else Size.Y := OriginalSize.Y;
    Control.SetSize(Classes.Point(Size.X, Size.Y));
  end;
end;
{ @end $7D39B0 }

{ @routine $7D3B9C TInterfaceSizeOverride_SaveToBuffer }
procedure TInterfaceSizeOverride.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(FormName);
  Buffer.AddWideStringZ(ControlPath);
  Buffer.AddIntegerValue(Size.X);
  Buffer.AddIntegerValue(Size.Y);
  Buffer.AddIntegerValue(OriginalSize.X);
  Buffer.AddIntegerValue(OriginalSize.Y);
end;
{ @end $7D3B9C }

{ @routine $7D3C00 TInterfaceSizeOverride_LoadFromBuffer }
procedure TInterfaceSizeOverride.LoadFromBuffer(Buffer: TBufEC);
begin
  FormName := Buffer.ReadWideString;
  ControlPath := Buffer.ReadWideString;
  Size.X := Buffer.GetInt32;
  Size.Y := Buffer.GetInt32;
  OriginalSize.X := Buffer.GetInt32;
  OriginalSize.Y := Buffer.GetInt32;
  Reapply;
end;
{ @end $7D3C00 }

{ @routine $7D3CBC TInterfaceSizeOverride_Reapply }
procedure TInterfaceSizeOverride.Reapply;
var Form: TMessageLoopGI; Control: TObjectGI;
begin
  Form := FindMessageLoop(Self.FormName);
  if Form = nil then raise Exception.Create(AnsiString('ML not found - ' + Self.FormName));
  Control := Form.FindControlByPath(Self.ControlPath);
  if Control = nil then
    AppendLogLineThreadSafe(AnsiString('TInterfaceSizeOverride: object not found - ' + Self.ControlPath + ' on form ' + Self.FormName))
  else begin
    Control.SetSize(Classes.Point(Size.X, Size.Y));
  end;
end;
{ @end $7D3CBC }

{ @routine $7D3E68 TStoredItem_CreateEmpty }
constructor TStoredItem.CreateEmpty;
begin
  inherited Create;
  Name := '';
  Item := nil;
end;
{ @end $7D3E68 }

{ @routine $7D3EBC TStoredItem_Create }
constructor TStoredItem.Create(Name: WideString; Item: TObject);
begin
  inherited Create;
  Self.Name := Name;
  Self.Item := Item;
end;
{ @end $7D3EBC }

{ @routine $7D3F4C TStoredItem_Destroy }
destructor TStoredItem.Destroy;
begin
  if Item <> nil then Item.Free;
  Item := nil;
  inherited Destroy;
end;
{ @end $7D3F4C }

{ @routine $7D3F9C TStoredItem_SaveToBuffer }
procedure TStoredItem.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(Name);
  Buffer.AddAnsiChar(AnsiChar(TItem(Item).ItemType));
  TItem(Item).SaveToBuffer(Buffer);
end;
{ @end $7D3F9C }

{ @routine $7D3FD8 TStoredItem_LoadFromBuffer }
procedure TStoredItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  Name := Buffer.ReadWideString;
  Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
  TItem(Item).LoadFromBuffer(Buffer, Galaxy);
end;
{ @end $7D3FD8 }

{ @routine $7D4060 TGalaxy_StoreItem }
procedure TGalaxy.StoreItem(Name: WideString; Item: TObject);
var Entry: TStoredItem; LowIndex, HighIndex, Middle, Comparison: Integer;
begin
  if Item is THull then begin
    THull(Item).OwnerShip := nil;
    THull(Item).InterceptorTarget := nil;
  end;
  if Item is TWeapon then begin
    TWeapon(Item).Target := nil;
    TWeapon(Item).LoadedTargetKind := wtkNone;
  end;
  if Item is TArtefactTranclucator then TTranclucator(TArtefactTranclucator(Item).Ship).OwnerShip := nil;
  if Item is TSatellite then TSatellite(Item).TargetPlanet := nil;
  if StoredItems.Count < 1 then begin
    Entry := TStoredItem.Create(Name, Item);
    StoredItems.Add(Entry);
    Exit;
  end;
  LowIndex := 0;
  Entry := TStoredItem(StoredItems[0]);
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
  if Comparison = 0 then begin Entry.Item.Free; Entry.Item := Item; Exit; end;
  if Comparison < 0 then begin
    Entry := TStoredItem.Create(Name, Item);
    StoredItems.Insert(0, Entry);
    Exit;
  end;
  HighIndex := StoredItems.Count - 1;
  Entry := TStoredItem(StoredItems[HighIndex]);
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
  if Comparison = 0 then begin Entry.Item.Free; Entry.Item := Item; Exit; end;
  if Comparison > 0 then begin
    Entry := TStoredItem.Create(Name, Item);
    StoredItems.Add(Entry);
  end else begin
    while True do begin
      if HighIndex - LowIndex < 2 then begin
        Entry := TStoredItem.Create(Name, Item);
        StoredItems.Insert(HighIndex, Entry);
        Exit;
      end;
      Middle := (LowIndex + HighIndex) div 2;
      Entry := TStoredItem(StoredItems[Middle]);
      Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
      if Comparison = 0 then begin Entry.Item.Free; Entry.Item := Item; Exit; end;
      if Comparison < 0 then HighIndex := Middle else LowIndex := Middle;
    end;
  end;

end;
{ @end $7D4060 }

{ @routine $7D4364 TGalaxy_GetStoredItem }
function TGalaxy.GetStoredItem(Name: WideString; Remove: Boolean): TObject;
var
  Entry: TStoredItem;
  Index, LowIndex, HighIndex, Comparison: Integer;

  // @nested $7D4318 TakeEntry
  function TakeEntry: TObject; // @addr 0x7D4318 @ida "TObject *__cdecl $name(void *ParentFrame);" @note "Nested in GetStoredItem; caller-popped static link. Entry -4, Remove -5, Self -12, Index -16."
  begin
    Result := Entry.Item;
    if Remove then
    begin
      Entry.Item := nil;
      Entry.Free;
      StoredItems.Delete(Index);
    end;
  end;

begin
  Result := nil;
  if StoredItems.Count < 1 then Exit;
  Index := 0;
  Entry := TStoredItem(StoredItems[Index]);
  if Entry.Name = Name then
  begin
    Result := TakeEntry;
    Exit;
  end;
  Index := StoredItems.Count - 1;
  Entry := TStoredItem(StoredItems[Index]);
  if Entry.Name = Name then
  begin
    Result := TakeEntry;
    Exit;
  end;
  LowIndex := 0;
  HighIndex := StoredItems.Count - 1;
  while True do
  begin
    if HighIndex - LowIndex < 2 then
    begin
      Result := nil;
      Break;
    end;
    Index := (LowIndex + HighIndex) div 2;
    Entry := TStoredItem(StoredItems[Index]);
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
    if Comparison = 0 then
    begin
      Result := TakeEntry;
      Break;
    end;
    if Comparison < 0 then HighIndex := Index else LowIndex := Index;
  end;
end;
{ @end $7D4364 }

{ @routine $7D4544 TGalaxy_GetOrCreateCustomWeaponInfo }
function TGalaxy.GetOrCreateCustomWeaponInfo(Name: WideString): PWeaponInfo;
var
  Info: PWeaponInfo;
  LowIndex, HighIndex, Middle, Comparison: Integer;
  // @nested $7D44C4 Allocate
  procedure Allocate; // @addr $7D44C4 @ida "void __cdecl $name(void *ParentFrame);"
  var State: Cardinal;
  begin
    New(Result);
    Result.ConfigName := Name;
    Result.ItemType := t_CustomWeapon;
    State := InitCrc32;
    State := UpdateCrc32(State, PWideChar(Result.ConfigName), Length(Result.ConfigName) * 2);
    Result.TypeHash := FinishCrc32(State);
  end;
begin
  if CustomWeaponTypes.Count < 1 then
  begin
    Allocate;
    CustomWeaponTypes.Add(Result);
    Exit;
  end;
  LowIndex := 0;
  Info := CustomWeaponTypes[0];
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Info.ConfigName));
  if Comparison = 0 then begin Result := Info; Exit; end;
  if Comparison < 0 then
  begin
    Allocate;
    CustomWeaponTypes.Insert(0, Result);
    Exit;
  end;
  HighIndex := CustomWeaponTypes.Count - 1;
  Info := CustomWeaponTypes[HighIndex];
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Info.ConfigName));
  if Comparison = 0 then begin Result := Info; Exit; end;
  if Comparison > 0 then
  begin
    Allocate;
    CustomWeaponTypes.Add(Result);
    Exit;
  end;
  while True do
  begin
    if HighIndex - LowIndex < 2 then
    begin
      Allocate;
      CustomWeaponTypes.Insert(HighIndex, Result);
      Exit;
    end;
    Middle := (LowIndex + HighIndex) div 2;
    Info := CustomWeaponTypes[Middle];
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Info.ConfigName));
    if Comparison = 0 then begin Result := Info; Exit; end;
    if Comparison < 0 then HighIndex := Middle else LowIndex := Middle;
  end;
end;
{ @end $7D4544 }

{ @routine $7D4734 TGalaxy_RequireCustomWeaponInfo }
function TGalaxy.RequireCustomWeaponInfo(Name: WideString): PWeaponInfo;
var
  Info: PWeaponInfo;
  LowIndex, HighIndex, Middle, Comparison: Integer;
begin
  if CustomWeaponTypes.Count < 1 then raise Exception.Create('Cant find custom weapon info = ' + Name);
  LowIndex := 0;
  Info := CustomWeaponTypes[0];
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Info.ConfigName));
  if Comparison = 0 then
  begin
    Result := Info;
    Exit;
  end;
  if Comparison < 0 then raise Exception.Create('Cant find custom weapon info = ' + Name);
  HighIndex := CustomWeaponTypes.Count - 1;
  Info := CustomWeaponTypes[HighIndex];
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Info.ConfigName));
  if Comparison = 0 then
  begin
    Result := Info;
    Exit;
  end;
  if Comparison > 0 then raise Exception.Create('Cant find custom weapon info = ' + Name);
  while True do
  begin
    if HighIndex - LowIndex < 2 then raise Exception.Create('Cant find custom weapon info = ' + Name);
    Middle := (LowIndex + HighIndex) div 2;
    Info := CustomWeaponTypes[Middle];
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Info.ConfigName));
    if Comparison = 0 then
    begin
      Result := Info;
      Break;
    end;
    if Comparison < 0 then HighIndex := Middle else LowIndex := Middle;
  end;
end;
{ @end $7D4734 }

{ @routine $7D4A08 TGalaxy_CanRecordAchievements }
function TGalaxy.CanRecordAchievements: Boolean;
var ReservedMode, ReservedLimit: Integer;
begin
  if SpecialSimulationMode <> 0 then
  begin
    Result := False;
    Exit;
  end;
  { These unused calculations are present in the original eligibility check. }
  ReservedMode := 4;
  ReservedLimit := TurnsPerYear;
  Inc(ReservedLimit, 107000);
  ReservedLimit := ReservedLimit shl 1;
  Result := (GetCheatPoints = 0) and (GR_Main.CCInterface.GetIntegrityError = 0) and
    not GR_Main.CCInterface.GetFlag0A and not GR_Main.CCInterface.GetTamperDetected and
    not GR_Main.CCInterface.GetEditableStateApplied and not GR_Main.CCInterface.GetResourceChecksumFailed;
end;
{ @end $7D4A08 }

end.
