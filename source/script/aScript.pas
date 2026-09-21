unit aScript;
// Unit bracket (inferred): .text 0x0064C170..0x0065C568; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Ether, EC_Expression, EC_Str, EC_Struct, EC_Thread, Windows, aGalaxy, aGalaxyStruct, aItem, aMyFunction, aPlanet, aShip;

const
  // Serialized PlaceKind IDs, decoded by TScriptPlace.GetPoint ($64FBA0)
  // and ShipInPlace ($6501B4). Keep the stored field as a 32-bit integer.
  spkPolar = 0;
  spkPlanetPosition = 1;
  spkDockedPlanet = 2;
  spkStarDirection = 3;
  spkScriptItem = 4;
  spkGroupCentroid = 5;
  spkCoordinates = 6;

  // TShip.ApplyScriptStateOrders ($77A934), state completion ($77AE70),
  // and HasScriptControl ($77D8B4) establish these serialized StateKind IDs.
  sskIdle = 0;
  sskMoveToPlace = 1;
  sskFollowGroup = 2;
  sskJumpToStar = 3;
  sskLandOnPlanet = 4;
  sskNormalAI = 5;

type

  TScriptActionTypeSet = set of 0..61; // @size $08
  TScriptStepTypeSet = set of 0..11; // @size $02
  TScriptShipTypeMask = set of 0..15; // @size 0x02
  TScriptDominatorMasks = array[0..7] of TDominatorSeriesMask; // TKlingType index; TDominatorSeries bits.

  TScriptStar = class;
  TScriptConstellation = class;
  TScriptShip = class;
  TScriptPlace = class;
  TScriptItem = class;
  TScriptGroup = class;
  TScriptState = class;
  TScriptDialog = class;
  TScriptDialogMsg = class;
  TScriptDialogAnswer = class;
  TScript = class;
  TScriptThread = class;
  TScriptCacheUnit = class;
  TScriptCache = class;
  TScriptGICacheUnit = class;
  TScriptGICache = class;
  TLibraryHandler = class;
  TLibraryCache = class;

  TScriptStarConstraint = record // @size 0x10
    OtherStar: TScriptStar; // @offset 0x00
    MinDistance: Integer; // @offset 0x04
    MaxDistance: Integer; // @offset 0x08
    RequireBlackHole: Boolean; // @offset 0x0C
  end;

  // Native record RTTI at $64C094.
  TDialogOverride = packed record // @size $10
    DialogName: WideString; // @offset $00
    Priority: Integer; // @offset $04
    Script: TScript; // @offset $08 Borrowed.
    AnswerData: Cardinal; // @offset $0C
  end;
  PScriptPlanetBinding = ^TScriptPlanet;

  PScriptShipRequirement = ^TScriptShipOtb;
  // Native record RTTI at $64C0BC.
  TDialogInject = record // @size $24
    Script: TScript; // @offset $00 Borrowed dialogue owner.
    DialogName: WideString; // @offset $04
    Text: WideString; // @offset $08
    Answer: WideString; // @offset $0C
    Priority: Integer; // @offset $10
    AnswerData: Cardinal; // @offset $14
    ReplaceGreeting: Boolean; // @offset $18
    ActionCode: WideString; // @offset $1C
    ActionScript: TScript; // @offset $20 Borrowed action-code owner.
  end;

  TScriptGroupRelation = packed record // @size 0x18
    Group1: Integer; // @offset 0x00
    Group2: Integer; // @offset 0x04
    Relation1To2: Integer; // @offset 0x08  5 leaves the relation unchanged.
    Relation2To1: Integer; // @offset 0x0C  5 leaves the relation unchanged.
    MinCombatBalance: Single; // @offset 0x10
    MaxCombatBalance: Single; // @offset 0x14
  end;

  // Native record RTTI at $64C0F8.
  TDialogBlock = record // @size $0C
    Text: WideString; // @offset $00
    Script: TScript; // @offset $04 Borrowed owner.
    Mode: Byte; // @offset $08 Zero enables, one disables, two or more suppress matching choices.
  end;

  // Native record RTTI at $64C11C.
  TScriptPlanet = packed record // @size 0x18
    Name: WideString; // @offset 0x00
    RaceMask: TOwnerMask; // @offset 0x04
    OwnerMask: TOwnerMask; // @offset 0x05
    EconomyMask: TPlanetEconomies; // @offset 0x06
    GovernmentMask: TPlanetGovernments; // @offset 0x07
    MinOrbitPercent: Integer; // @offset 0x08
    MaxOrbitPercent: Integer; // @offset 0x0C
    DialogChoiceText: WideString; // @offset 0x10  Planet dialog choice text; CollectScriptDialogChoices attaches the owning TScript as its data.
    Planet: TPlanet; // @offset 0x14
  end;

  // Native record RTTI at $64C148.
  TScriptShipOtb = packed record // @size 0x48
    Count: Integer; // @offset 0x00
    OwnerMask: TOwnerMask; // @offset 0x04
    ShipTypeMask: TScriptShipTypeMask; // @offset 0x05  Logical ship-type bits, including station bit 8.
    PlayerOnly: Boolean; // @offset 0x07
    MinSpeed: Integer; // @offset 0x08
    MaxSpeed: Integer; // @offset 0x0C
    WeaponRequirement: Integer; // @offset 0x10  1 requires weapons; 2 requires none.
    MinCargoHookLevel: Integer; // @offset 0x14
    MinFreeCargoSpace: Integer; // @offset 0x18
    MinTraderStatus: Integer; // @offset 0x1C
    MaxTraderStatus: Integer; // @offset 0x20
    MinWarriorStatus: Integer; // @offset 0x24
    MaxWarriorStatus: Integer; // @offset 0x28
    MinPirateStatus: Integer; // @offset 0x2C
    MaxPirateStatus: Integer; // @offset 0x30
    MinStrength: Single; // @offset 0x34
    MaxStrength: Single; // @offset 0x38
    StationNames: WideString; // @offset 0x3C
    DominatorMasks: TScriptDominatorMasks; // @offset 0x40
  end;

  TScriptStar = class(TObjectEx) // @size 0x20
  public
    Name: WideString; // @offset 0x04
    ConstellationIndex: Integer; // @offset 0x08
    RejectHostilePresence: Boolean; // @offset 0x0C
    ProtectStar: Boolean; // @offset 0x0D
    Constraints: array of TScriptStarConstraint; // @offset 0x10
    Planets: array of TScriptPlanet; // @offset 0x14
    ShipRequirements: array of TScriptShipOtb; // @offset 0x18
    Star: TStar; // @offset 0x1C

    constructor Create; // @addr 0x64F91C
    destructor Destroy; override; // @addr 0x64F990
  end;

  TScriptConstellation = class(TObjectEx) // @size 0x8
  public
    Constellation: TConstellation; // @offset 0x04

    constructor Create; // @addr 0x64F9F4
    destructor Destroy; override; // @addr 0x64FA38
  end;

  TScriptShip = class(TObjectEx) // @size 0x2C
  public
    Script: TScript; // @offset 0x04
    GroupIndex: Integer; // @offset 0x08
    Ship: TShip; // @offset 0x0C  Borrowed; destruction invalidates the backlink.
    Data: array[0..3] of Dword; // @offset 0x10
    State: TScriptState; // @offset 0x20
    StateText: WideString; // @offset 0x24 Custom faction name exposed by ShipCustomFaction; changing it refreshes ship standing.
    EndState: Boolean; // @offset 0x28
    Hit: Boolean; // @offset 0x29
    HitPlayer: Boolean; // @offset 0x2A
    function GetGroup: TScriptGroup; // @addr 0x64FB00
    function RunActionCode(ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x65B30C @note "Returns the event parameter after script changes. Object slots can carry event-specific integers."

    constructor Create; // @addr 0x64FA6C
    destructor Destroy; override; // @addr 0x64FAB0
  end;

  TScriptPlace = class(TObjectEx) // @size 0x34
  public
    Script: TScript; // @offset 0x04
    Name: WideString; // @offset 0x08
    OriginVarName: WideString; // @offset 0x0C
    OriginStar: TStar; // @offset 0x10
    PlaceKind: Integer; // @offset 0x14  spk* serialized place ID.
    AngleOffset: Single; // @offset 0x18
    DistanceScale: Single; // @offset 0x1C
    Radius: Integer; // @offset 0x20
    TargetVarName: WideString; // @offset 0x24
    TargetValue: Dword; // @offset 0x28  Kinds 1/2: TPlanet; 3: TStar; 4: TScriptItem; 5: group index; 6: TVarEC for X.
    TargetVarName2: WideString; // @offset 0x2C
    TargetValue2: TVarEC; // @offset 0x30  Second coordinate variable for spkCoordinates.
    function GetPoint: TPointF; // @addr 0x64FBA0
    function GetRandomPoint(Seed: Cardinal): TPointF; // @addr 0x65004C
    function ShipInPlace(Ship: TShip): Boolean; // @addr 0x6501B4 @note "Kind 2 requires docking at the bound planet; other kinds require normal space."

    constructor Create; // @addr 0x64FB28
    destructor Destroy; override; // @addr 0x64FB6C
  end;

  TScriptItem = class(TObjectEx) // @size 0x64
  public
    Name: WideString; // @offset 0x04
    LocationVarName: WideString; // @offset 0x08  Group index, planet, or place variable.
    DefinitionKind: Integer; // @offset 0x0C
    DefinitionType: Integer; // @offset 0x10  Kind-dependent definition index, not a native TItemType.
    Weight: Integer; // @offset 0x14
    Level: Integer; // @offset 0x18
    DefinitionValue1C: Integer; // @offset $1C Read from the definition; not consulted by LoadFromBuffer item creation.
    OwnerId: Byte; // @offset 0x20
    ConfigName: WideString; // @offset $24 TUselessItem configuration key for definition kind 4.
    Item: TItem; // @offset 0x28  Borrowed; destruction invalidates the backlink.
    CanSell: Boolean; // @offset 0x2C
    Data: array[1..3] of Integer; // @offset 0x30
    TextData1: WideString; // @offset $3C
    TextData2: WideString; // @offset $40
    TextData3: WideString; // @offset $44
    OnUseText: WideString; // @offset 0x48
    OnActionText: WideString; // @offset 0x4C
    ActionCode: TCodeEC; // @offset 0x50  Owned.
    ActionTypeMask: TScriptActionTypeSet; // @offset 0x54
    StepTypeMask: TScriptStepTypeSet; // @offset 0x5C
    ActionCodeInitialized: Boolean; // @offset 0x5E
    Script: TScript; // @offset 0x60
    procedure CompileActionCode; // @addr 0x65ABC4 @note "Requires nonempty OnActionText and an empty ActionCode slot."
    function RunActionCode(ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x65AF44 @note "Returns the event parameter after script changes. Object slots can carry event-specific integers."
    function FormatDataText(Text, ColorTag: WideString): WideString; // @addr 0x65C114

    constructor Create; // @addr 0x650228
    destructor Destroy; override; // @addr 0x650280
  end;

  TScriptGroup = class(TObjectEx) // @size 0x70
  public
    Name: WideString; // @offset 0x04
    PlanetVarName: WideString; // @offset 0x08
    Planet: TPlanet; // @offset 0x0C
    InitialStateIndex: Integer; // @offset 0x10
    OwnerMask: TOwnerMask; // @offset 0x14
    ShipTypeMask: TScriptShipTypeMask; // @offset 0x15
    MinCount: Integer; // @offset 0x18
    MaxCount: Integer; // @offset 0x1C
    MinSpeed: Integer; // @offset 0x20
    MaxSpeed: Integer; // @offset 0x24
    WeaponRequirement: Integer; // @offset 0x28  1 requires weapons; 2 requires none.
    MinCargoHookLevel: Integer; // @offset 0x2C
    MinFreeCargoSpace: Integer; // @offset 0x30
    IncludePlayer: Boolean; // @offset 0x34
    StationNames: WideString; // @offset 0x38
    DominatorMasks: TScriptDominatorMasks; // @offset 0x3C
    MinStrength: Single; // @offset 0x44
    MaxStrength: Single; // @offset 0x48
    MinTraderStatus: Integer; // @offset 0x4C
    MaxTraderStatus: Integer; // @offset 0x50
    MinWarriorStatus: Integer; // @offset 0x54
    MaxWarriorStatus: Integer; // @offset 0x58
    MinPirateStatus: Integer; // @offset 0x5C
    MaxPirateStatus: Integer; // @offset 0x60
    MaxDistanceFromPlanet: Integer; // @offset 0x64  10000 disables the distance filter.
    StationDialogVariable: WideString; // @offset 0x68 Dialog-index variable used by TfRuinsTalk when docking at a scripted station.
    Ships: TList; // @offset 0x6C  Owned container for group creation.

    constructor Create; // @addr 0x6502EC
    destructor Destroy; override; // @addr 0x650330
  end;

  TScriptState = class(TObjectEx) // @size 0x4C
  public
    Name: WideString; // @offset 0x04
    StateKind: Integer; // @offset 0x08  ssk* serialized state ID.
    TargetVarName: WideString; // @offset 0x0C
    TargetValue: Dword; // @offset 0x10  Place, star, planet, or group index according to StateKind.
    EnemyGroupNames: array of WideString; // @offset 0x14
    EnemyGroupIndices: array of Integer; // @offset 0x18
    PickupItemVarName: WideString; // @offset 0x1C
    PickupItem: TScriptItem; // @offset 0x20
    PickUpNearbyItems: Boolean; // @offset 0x24
    DialogTextOrVariable: WideString; // @offset 0x28 Dialog-index variable name or inline dialogue source, selected by TfTalk.CodeMsgOut.
    DialogCode: TCodeEC; // @offset 0x2C  Owned when DialogTextOrVariable is compiled.
    OnActionText: WideString; // @offset 0x30
    ActionCode: TCodeEC; // @offset 0x34  Owned.
    ActionTypeMask: TScriptActionTypeSet; // @offset 0x38
    StepTypeMask: TScriptStepTypeSet; // @offset 0x40
    EntryCode: TCodeEC; // @offset 0x44
    StateCode: TCodeEC; // @offset 0x48
    // EntryCode runs before CurShip/EndState refresh; StateCode sees the new context.

    constructor Create; // @addr 0x650380
    destructor Destroy; override; // @addr 0x6503DC
  end;

  TScriptDialog = class(TObjectEx) // @size 0xC
  public
    Name: WideString; // @offset 0x04
    Code: TCodeEC; // @offset 0x08

    constructor Create; // @addr 0x6504A0
    destructor Destroy; override; // @addr 0x6504F4
  end;

  TScriptDialogMsg = class(TObjectEx) // @size 0xC
  public
    Name: WideString; // @offset 0x04
    Code: TCodeEC; // @offset 0x08

    constructor Create; // @addr 0x650544
    destructor Destroy; override; // @addr 0x650598
  end;

  TScriptDialogAnswer = class(TObjectEx) // @size 0x10
  public
    Name: WideString; // @offset 0x04
    AnswerCode: TCodeEC; // @offset 0x08
    ActionCode: TCodeEC; // @offset 0x0C

    constructor Create; // @addr 0x6505E8
    destructor Destroy; override; // @addr 0x650650
  end;

  TScript = class(TObjectEx) // @size 0x60
  public
    ClassId: Integer; // @offset 0x04  Script.GAllCntRun filter.
    ScriptFileName: WideString; // @offset 0x08
    Constellations: TList; // @offset 0x0C  Owns TScriptConstellation entries.
    Stars: TList; // @offset 0x10  Owns TScriptStar entries.
    Places: TList; // @offset 0x14  Owns TScriptPlace entries.
    Items: TList; // @offset 0x18  Owns TScriptItem wrappers, not their live items.
    Groups: TList; // @offset 0x1C  Owns TScriptGroup entries.
    Ships: TList; // @offset 0x20  Owns TScriptShip bindings, not ships.
    States: TList; // @offset 0x24  Owns TScriptState entries.
    Dialogs: TList; // @offset 0x28  Owns TScriptDialog entries.
    DialogMessages: TList; // @offset 0x2C  Owns TScriptDialogMsg entries.
    DialogAnswers: TList; // @offset 0x30  Owns TScriptDialogAnswer entries.
    InitCode: TCodeEC; // @offset 0x34
    TurnCode: TCodeEC; // @offset 0x38
    DialogCode: TCodeEC; // @offset 0x3C Owned dialogue-hook code; run while building ship, government and station dialogue choices.
    Ether: TEther; // @offset $40  Owned script-local named integer store; created, cleared and freed with the script.
    CurrentShip: TShip; // @offset 0x44
    CurrentDialog: Integer; // @offset 0x48
    CurrentAnswer: Integer; // @offset 0x4C  -1 outside answer generation.
    SkipGreeting: Boolean; // @offset 0x50
    GroupRelations: array of TScriptGroupRelation; // @offset 0x54
    AnchorPlanet: TPlanet; // @offset 0x58  Optional first planet binding when starting a script.
    EtherIds: TStringsEC; // @offset 0x5C
    procedure Clear; // @addr 0x650A18 @note "Frees owned entries but retains list and code containers."
    procedure PublishShipContext(Binding: TScriptShip); // @addr 0x650D84 @note "Changes the global CurrentScript context."
    procedure PublishCurrentShip(Ship: TShip); // @addr 0x650E14
    function GetStar(Name: WideString): TScriptStar; // @addr 0x650E68 @note "Raises when absent."
    function GetPlanetBinding(Name: WideString): PScriptPlanetBinding; // @addr 0x650F8C @note "Raises when absent."
    function GetItem(Name: WideString): TScriptItem; // @addr 0x6510F4 @note "Raises when absent."
    procedure RunShipState(Binding: TScriptShip); // @addr 0x651210
    procedure RunTurnCode; // @addr 0x651490
    procedure RunDialogCode; // @addr 0x651630
    procedure CallDialog(Index: Integer); // @addr 0x6517D4
    procedure CallDialogByVariable(Name: WideString); // @addr 0x651A9C
    procedure CallDialogMessage(Index: Integer); // @addr 0x651BA8
    procedure BuildDialogAnswer(Index: Integer); // @addr 0x651E58
    procedure ExecuteDialogAnswer(Index: Integer); // @addr 0x652118 @note "Index -1 is ignored."
    procedure BindShip(GroupIndex: Integer; Ship: TShip); // @addr 0x6523C8 @note "The player may have multiple script bindings; ordinary ships have one."
    procedure UnbindShip(Ship: TShip); // @addr 0x65247C
    procedure ClearShipBindings; // @addr 0x65256C
    procedure ChangeState(Binding: TScriptShip; StateIndex: Integer); // @addr 0x652660
    procedure SetGroupRelation(SourceGroup, TargetGroup: Integer; Level: TRelationLevel); // @addr 0x6526F8 @note "Changes source ships' relations to ranger members of the target group."
    procedure SetPlanetRelation(GroupIndex: Integer; Planet: TPlanet; Level: TRelationLevel); // @addr 0x6527C4
    function TryBindStars(StarIndex: Integer): Boolean; // @addr 0x65283C @note "Recursively assigns remaining stars and their planets; earlier star bindings must already exist."
    function LoadFromBuffer(Buffer: TBufEC; AnchorStar: TStar; FirstPlanet: TPlanet; CreateObjects: Boolean): Boolean; // @addr 0x653660 @note "Accepts script-definition versions 5 through 8."
    function LoadFromFile(FileName: WideString; AnchorStar: TStar; FirstPlanet: TPlanet; CreateObjects: Boolean): Boolean; // @addr 0x656D1C
    procedure SaveState(Buffer: TBufEC); // @addr 0x656E90 @note "Compiled instructions are excluded."
    procedure LoadState(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x657690 @note "Requires the original script-definition file. Resolves star, planet and item IDs through Galaxy; ship IDs are deferred."
    procedure BindImportedFunctions; // @addr 0x6583F4
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr 0x658658 @note "Resolves saved ship IDs and restores ship, place, and state bindings after LoadState."

    constructor Create; // @addr 0x6506BC
    destructor Destroy; override; // @addr 0x650818
  end;

  TScriptThread = class(TThreadEC) // @size 0x2C
  public
    constructor Create; // @addr 0x64D8B4
    procedure Execute; override; // @addr 0x64D8F8 @slot 0x00
  end;

  TScriptCacheUnit = class(TObject) // @size 0x1C
  public
    Name: WideString; // @offset 0x04
    SourceText: WideString; // @offset 0x08
    Code: TCodeEC; // @offset 0x0C  Owned.
    ActionTypeMask: TScriptActionTypeSet; // @offset 0x10  Native 62-bit action-type set.
    StepTypeMask: TScriptStepTypeSet; // @offset 0x18  Native 12-bit step-type set.
    procedure Initialize(Name, SourceText, ActionTypes, StepTypes: WideString); // @addr 0x65A350

    constructor Create; // @addr 0x65A2B4
    destructor Destroy; override; // @addr 0x65A300
  end;

  TScriptCache = class(TObject) // @size 0x8
  public
    Entries: TObjectList; // @offset 0x04  Owns TScriptCacheUnit entries sorted by Name.
    function GetOrCompile(Name: WideString; Config: TBlockParEC): TScriptCacheUnit; // @addr 0x65A058 @note "Returns nil for absent or empty OnActCode."

    constructor Create; // @addr 0x659BB8
    destructor Destroy; override; // @addr 0x659C60
  end;

  TScriptGICacheUnit = class(TObject) // @size 0x10
  public
    Block: TBlockParEC; // @offset 0x04  Borrowed cache key.
    SourceText: WideString; // @offset 0x08
    Code: TCodeEC; // @offset 0x0C  Owned.
    procedure Initialize(Block: TBlockParEC; SourceText: WideString); // @addr 0x65A678

    constructor Create; // @addr 0x65A5DC
    destructor Destroy; override; // @addr 0x65A628
  end;

  TScriptQuestStatus = (sqsNone = 0, sqsQueued = 1, sqsSuccess = 2, sqsFailure = 3); // @size 0x04

  TScriptGICache = class(TObject) // @size 0x8
  public
    Entries: TObjectList; // @offset 0x04  Owns entries sorted by Block pointer.
    function GetOrCompile(Block: TBlockParEC): TScriptGICacheUnit; // @addr 0x659D70 @note "Returns nil for empty source."

    constructor Create; // @addr 0x659C0C
    destructor Destroy; override; // @addr 0x659CA4
  end;
  PScriptABRequest = ^TScriptABRequest;

  TLibraryHandler = class(TObject) // @size 0x10
  public
    LibraryName: WideString; // @offset 0x04
    ModuleHandle: Cardinal; // @offset 0x08  Owned Win32 module handle.
    DefinitionBlock: TBlockParEC; // @offset 0x0C  Borrowed ScriptLibs.<name> block.
    constructor Create(LibraryName: WideString; ModuleHandle: Cardinal; DefinitionBlock: TBlockParEC); // @addr 0x6589F4
    procedure InitFunction(Cell: TVarEC); // @addr 0x658AFC
    procedure InitAllFunctions(Scope: TVarArrayEC); // @addr 0x658FE4

    destructor Destroy; override; // @addr 0x658A90
  end;
  PScriptPBRequest = ^TScriptPBRequest;

  TLibraryCache = class(TObject) // @size 0x8
  public
    Libraries: TObjectList; // @offset 0x04  Owns TLibraryHandler entries sorted by LibraryName.
    function GetLib(Name: WideString): TLibraryHandler; // @addr 0x659300
    procedure InitFunction(Cell: TVarEC); // @addr 0x6594E0

    constructor Create; // @addr 0x659114
    destructor Destroy; override; // @addr 0x659168
  end;
  PScriptVDRequest = ^TScriptVDRequest;

  // Native record RTTI at $64CA64.
  TScriptTQRequest = packed record // @size 0x10
    Name: WideString; // @offset 0x00
    SuccessCaption: WideString; // @offset 0x04
    FailureCaption: WideString; // @offset 0x08
    Script: TScript; // @offset 0x0C // Borrowed.
  end;
  PQueuedTextQuest = ^TScriptTQRequest;

  TScriptABRequest = packed record // @size 0x14
    MapName: WideString; // @offset 0x00
    Ships: TObjectList; // @offset 0x04  Owned arcade ships transferred from the staging list.
    BackgroundId: Integer; // @offset 0x08
    BackgroundMapName: WideString; // @offset 0x0C
    Script: TScript; // @offset 0x10  Borrowed.
  end;
  PScriptDialogOverride = ^TDialogOverride;

  TScriptPBRequest = packed record // @size 0x18
    MapName: WideString; // @offset 0x00
    StartText: WideString; // @offset 0x04  Includes the supplied prefix, or 621 by default.
    SuccessText: WideString; // @offset 0x08
    FailureText: WideString; // @offset 0x0C
    PlaceText: WideString; // @offset 0x10
    Script: TScript; // @offset 0x14  Borrowed.
  end;
  PScriptDialogInjection = ^TDialogInject;

  TScriptVDRequest = packed record // @size 0x0C
    Video: WideString; // @offset 0x00
    Soundtrack: WideString; // @offset 0x04
    Script: TScript; // @offset 0x08  Borrowed.
  end;
  PScriptDialogBlock = ^TDialogBlock;

  TScriptContextSnapshot = record // @size 0x0C
    Script: TScript; // @offset 0x00
    CurrentShip: TShip; // @offset 0x04
    EndState: Boolean; // @offset 0x08
  end;

var
  CurrentScript: TScript; // @addr 0x88AA10
  QueuedArcadeBattles: TList; // @addr 0x88AA14  Owns PScriptABRequest records.
  QueuedPlanetaryBattles: TList; // @addr 0x88AA18  Owns PScriptPBRequest records.
  QueuedTextQuests: TList; // @addr 0x88AA1C // Owns PQueuedTextQuest records.
  QueuedVideos: TList; // @addr 0x88AA20  Owns PScriptVDRequest records.
  ResumingScript: TScript = nil; // @addr 0x87BE48
  StagedArcadeShipScript: TScript = nil; // @addr $87BE4C
  ScriptArcadeReturnScreenId: Byte = 0; // @addr $87BE50 Direct stores in TryShowQueuedArcadeBattle establish ownership.
  ScriptTakeoffRequested: Boolean = False; // @addr 0x87BE54
  StagedArcadeShips: TObjectList; // @addr $88AA24  Owns ships waiting for an arcade request.
  ScriptEndTurnRequested: Boolean = False; // @addr 0x87BE58
  ScriptFunctionScope: TVarArrayEC; // @addr 0x88AA28
  ScriptProcess: TCodeProcessEC; // @addr 0x88AA2C
  ScriptDialogOverrides: TObjectList; // @addr 0x88AA30  Record entries are freed explicitly before clearing.
  ScriptLibraryCache: TLibraryCache = nil; // @addr 0x87BE5C
  ArtefactScriptCache: TScriptCache = nil; // @addr $87BE60 @note "Named artifact action code via TArtefact.GetActionCode."
  ArtefactKindScriptCache: TScriptCache = nil; // @addr $87BE64 @note "Item-type artifact action code; item types 8 and 9 use the named artifact cache instead."
  UselessItemScriptCache: TScriptCache = nil; // @addr $87BE68
  CustomShipInfoScriptCache: TScriptCache = nil; // @addr $87BE6C
  GameplayUiScriptCache: TScriptGICache = nil; // @addr 0x87BE70
  CurrentScriptState: TScriptState = nil; // @addr 0x87BE74
  ScriptDialogInjections: TObjectList; // @addr 0x88AA34
  ScriptDialogBlocks: TObjectList; // @addr 0x88AA38
  ScriptRequestThread: TScriptThread; // @addr 0x88AA3C

procedure LogScriptCallHistory; // @addr 0x64CB44
procedure ClearPendingScriptRequests; // @addr 0x64CE38
function HasPendingScriptRequests: Boolean; // @addr 0x64CF34
function TryShowQueuedArcadeBattle: Boolean; // @addr 0x64CF88
function TryShowQueuedTextQuest: Boolean; // @addr 0x64D034
function TryRunQueuedPlanetaryBattle: Boolean; // @addr 0x64D0C4
function TryShowQueuedVideo: Boolean; // @addr 0x64D33C
function TryDispatchScriptTakeoff: Boolean; // @addr 0x64D4F0
function TryDispatchScriptEndTurn: Boolean; // @addr 0x64D580
function TryDispatchResumingScriptRequest: Boolean; // @addr 0x64D648 @note "Moves the first request belonging to ResumingScript to its queue's front."
function DispatchPendingScriptRequests: Boolean; // @addr 0x64D818
procedure StartScriptRequestThread; // @addr 0x64D890
procedure CompleteQueuedArcadeBattle(Status: Integer); // @addr 0x64D9CC @note "Requires a nonempty queue. Clears ResumingScript when no requests remain; preserves GABStatus changed by the script."
procedure CompleteQueuedTextQuest(Status: TScriptQuestStatus); // @addr 0x64DABC @note "Requires a nonempty queue. Clears ResumingScript when no requests remain; preserves GQuestStatus changed by the script."
procedure CompleteQueuedPlanetaryBattle(Status: Integer); // @addr 0x64DB9C @note "Requires a nonempty queue. Clears ResumingScript when no requests remain; preserves GRobotStatus changed by the script."
procedure CompleteQueuedVideo(Status: Integer); // @addr 0x64DC7C @note "Requires a nonempty queue when a player exists. Clears ResumingScript when no requests remain; preserves GVideoStatus changed by the script."
procedure LogScriptStepCount(ExpressionCount: Integer); // @addr 0x64DD6C

procedure InitializeScriptEngine; // @addr 0x64DE3C
procedure FinalizeScriptEngine; // @addr 0x64DE80
procedure RunGlobalScriptsForContext(Star: TStar; RunFrom: Integer); // @addr 0x64DEB8
function TryStartScriptByName(AnchorStar: TStar; AnchorPlanet: TPlanet; Name: WideString): Boolean; // @addr 0x64E138
function TryStartScriptInstanceFromTemplate(AnchorStar: TStar; AnchorPlanet: TPlanet; TemplateIndex: Integer): Boolean; // @addr 0x64E1AC
function TryRestartScript(Script: TScript; AnchorStar: TStar; AnchorPlanet: TPlanet): Boolean; // @addr 0x64E29C @note "Replaces and frees Script on success; retains it on failure. Requires an existing Galaxy.Scripts entry."
procedure CompileScriptTemplateCondition(TemplateIndex: Integer); // @addr 0x64E428
function IsStarProtectedByScript(Star: TStar): Boolean; // @addr 0x64E6A4
function ScriptDefinitionBit(Value: Cardinal; BitIndex: Integer): Boolean; // @addr 0x64E75C
function DecodeScriptRaceMask(Value: Cardinal): TOwnerMask; // @addr 0x64E780
function DecodeScriptOwnerMask(Value: Cardinal): TOwnerMask; // @addr 0x64E85C @note "Bit 9 also selects the player's current owner ID."
function DecodeScriptEconomyMask(Value: Cardinal): TPlanetEconomies; // @addr 0x64E9CC
function DecodeScriptGovernmentMask(Value: Cardinal): TPlanetGovernments; // @addr 0x64EA64
function DecodeScriptShipTypeMask(Value: Cardinal): TScriptShipTypeMask; // @addr 0x64EB40
function DecodeScriptDominatorMask(Value: Cardinal; KlingType: Byte): TDominatorSeriesMask; // @addr 0x64ECA8
function DecodeScriptItemOwner(Value: Integer): Byte; // @addr 0x64F000 @note "Values outside 0..7 become owner 6."
function DecodeScriptRelationLevel(Value: Integer): TRelationLevel; // @addr 0x64F074 @note "Values outside 0..4 become hostile."
function ScriptShipMatchesType(Ship: TShip; ShipTypeMask: TScriptShipTypeMask; StationNames: WideString; DominatorMasks: array of TDominatorSeriesMask): Boolean; // @addr 0x64F0C4 @note "DominatorMasks requires eight entries indexed by TKlingType. StationNames is a comma-separated filter when ship-type bit 8 is set."
function CollectScriptCandidateShips(Star: TStar): TList; // @addr 0x64F294 @note "Caller owns the list; ship references are borrowed."
function FindScriptGroupCandidate(Candidates: TList; Group: TScriptGroup): TShip; // @addr 0x64F5BC @note "Returns the first match or nil; leaves Candidates unchanged."
function GetScriptShipBindingForContext(Ship: TShip; Script: TScript): TScriptShip; // @addr 0x64F89C @note "The player may have multiple bindings; ordinary ships have one."
procedure ClearScriptDialogRules; // @addr 0x6588C8
procedure ExecuteScriptText(SourceText: WideString; Scope: TVarArrayEC); // @addr 0x659564 @note "Nil Scope temporarily clears CurrentScript. Compiled code is freed after execution."
function CompileScriptText(SourceText: WideString): TCodeEC; // @addr 0x6597F0 @note "Caller owns the returned code."
procedure RunScriptCode(ContextName: WideString; Code, ParentCode: TCodeEC); // @addr 0x659968
function GetCachedActionCode(var Cache: TScriptCache; Name: WideString; Config: TBlockParEC): TScriptCacheUnit; // @addr 0x65A6E4
procedure ExecuteGameplayUiCode(Block: TBlockParEC; VirtualKey: Cardinal); // @addr 0x65A764 @note "Runs with CurrentScript nil. VirtualKey=0 leaves KEY and KEYMOD unchanged."
procedure ScriptSnap(out Snapshot: TScriptContextSnapshot); // @addr 0x65AABC @note "When CurrentScript is nil, only Snapshot.Script is written."
procedure ScriptUnSnap(Snapshot: TScriptContextSnapshot); // @addr 0x65AB28
function RunItemUseCode(Item: TItem; Ship: TShip): Integer; // @addr 0x65B66C @note "Returns ScriptItemActParam, initially zero."
function RunItemConfigActionCode(Item: TItem; ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x65B880 @note "Uses artifact or useless-item configuration code. Object slots can carry event-specific integers."
function RunCustomShipInfoActionCode(Info: PCustomShipInfo; ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x65BC78 @note "Returns the event parameter after script changes. Object slots can carry event-specific integers."
function GetScriptContextDescription: WideString; // @addr 0x65C308

implementation

uses GI_MessageLoop, GI_MessageBox, GI_XviD, MMSystem, Robot, fPanelMain, fShip2, fStarMap, BreakMessageGIException, EC_Cache, EC_CacheBuf, GR_Main, Globals, SysUtils, GlobalsV, aConst, aKling, aPlayer, aRanger, aRuins, aScriptFun, aTranclucator, aWarrior;

{ @routine $64CB44 LogScriptCallHistory }
procedure LogScriptCallHistory;
var
  I, Position, Count: Integer;
  Cell: TVarEC;
begin
  Count := ScriptCallTraceCount;
  Position := (ScriptCallTracePosition - 1 + 20) mod 20;
  Cell := ScriptCallTrace[Position];
  while (Cell <> nil) and (Cell.RealVType = vkFunction) do
  begin
    Dec(Count);
    if Count <= 0 then
    begin
      AppendLogLineThreadSafe(AnsiString('Non-function error at beginning or after return from user function ' + Cell.Name));
      Exit;
    end;
    AppendLogLineThreadSafe(AnsiString('Error in user function ' + Cell.Name));
    Position := (Position - 1 + 20) mod 20;
    Cell := ScriptCallTrace[Position];
  end;
  AppendLogLineThreadSafe('function call history:');
  Position := (ScriptCallTracePosition - ScriptCallTraceCount + 20) mod 20;
  for I := 1 to Count do
  begin
    if ScriptCallTrace[Position] <> nil then
      AppendLogLineThreadSafe(AnsiString(ScriptCallTrace[Position].Name));
    Position := (Position + 1) mod 20;
  end;
  if Galaxy <> nil then AppendLogLineThreadSafe(AnsiString('current turn is ' + IntToWideString(Galaxy.CurrentTurn)));
end;
{ @end $64CB44 }

{ @routine $64CE38 ClearPendingScriptRequests }
procedure ClearPendingScriptRequests;
begin
  ResumingScript := nil;
  while QueuedTextQuests.Count > 0 do
  begin
    Dispose(PQueuedTextQuest(QueuedTextQuests[0]));
    QueuedTextQuests.Delete(0);
  end;
  while QueuedArcadeBattles.Count > 0 do
  begin
    PScriptABRequest(QueuedArcadeBattles[0]).Ships.Free;
    Dispose(PScriptABRequest(QueuedArcadeBattles[0]));
    QueuedArcadeBattles.Delete(0);
  end;
  while QueuedPlanetaryBattles.Count > 0 do
  begin
    Dispose(PScriptPBRequest(QueuedPlanetaryBattles[0]));
    QueuedPlanetaryBattles.Delete(0);
  end;
  while QueuedVideos.Count > 0 do
  begin
    Dispose(PScriptVDRequest(QueuedVideos[0]));
    QueuedVideos.Delete(0);
  end;
  ScriptTakeoffRequested := False;
  ScriptEndTurnRequested := False;
  StagedArcadeShips.Clear;
  StagedArcadeShipScript := nil;
end;
{ @end $64CE38 }

{ @routine $64CF34 HasPendingScriptRequests }
function HasPendingScriptRequests: Boolean;
begin
  Result := (QueuedArcadeBattles.Count > 0) or (QueuedTextQuests.Count > 0) or
    (QueuedPlanetaryBattles.Count > 0) or (QueuedVideos.Count > 0) or
    ScriptTakeoffRequested or ScriptEndTurnRequested;
end;
{ @end $64CF34 }

{ @routine $64CF88 TryShowQueuedArcadeBattle }
function TryShowQueuedArcadeBattle: Boolean;
var
  Request: PScriptABRequest;
begin
  Result := False;
  if QueuedArcadeBattles.Count > 0 then
  begin
    Request := PScriptABRequest(QueuedArcadeBattles[0]);
    ArcadeBattleScreen.SelectedMapName := Request.MapName;
    case CurrentScreenId of
      screenEquipmentShop, screenGovernment, screenInfo, screenGoodsShop:
        if GetPlayer.CurrentPlanet <> nil then ScriptArcadeReturnScreenId := Ord(screenPlanet)
        else ScriptArcadeReturnScreenId := Ord(screenRuinsTalk);
    else ScriptArcadeReturnScreenId := Ord(CurrentScreenId);
    end;
    RequestedScreenId := screenArcadeBattle;
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
    Result := True;
  end;
end;
{ @end $64CF88 }

{ @routine $64D034 TryShowQueuedTextQuest }
function TryShowQueuedTextQuest: Boolean;
begin
  Result := False;
  if QueuedTextQuests.Count > 0 then
  begin
    StandaloneQuestMode := False;
    case CurrentScreenId of
      screenEquipmentShop, screenGovernment, screenInfo, screenGoodsShop:
        if GetPlayer.CurrentPlanet <> nil then QuestReturnScreenId := screenPlanet
        else QuestReturnScreenId := screenRuinsTalk;
    else QuestReturnScreenId := CurrentScreenId;
    end;
    RequestedScreenId := screenPlanetQuest;
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
    Result := True;
  end;
end;
{ @end $64D034 }

{ @routine $64D0C4 TryRunQueuedPlanetaryBattle }
function TryRunQueuedPlanetaryBattle: Boolean;
var
  Request: PScriptPBRequest;
  Status: Integer;
  Failed: Boolean;
begin
  Result := False;
  if QueuedPlanetaryBattles.Count > 0 then
  begin
    Status := 0;
    Request := PScriptPBRequest(QueuedPlanetaryBattles[0]);
    try
      Failed := False;
      Status := FRun(Request.MapName, Request.StartText, Request.SuccessText, Request.FailureText, Request.PlaceText);
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        Failed := True;
      end;
    end;
    if Failed then
    begin
      if ShowMessageBoxGI(TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]), LocalizedColorText('FormGov.BattlePlanetQuestCrashed'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        Status := 3
      else raise Exception.Create('Error in Matrix.dll');
    end;
    if Status = 0 then Exit;
    if Status = 1 then
    begin
      RequestedScreenId := screenMainMenu;
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
      Exit;
    end;
    if Status = 3 then Status := 2
    else Status := 3;
    RequestedScreenId := CurrentScreenId;
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
    CompleteQueuedPlanetaryBattle(Status);
    Result := True;
  end;
end;
{ @end $64D0C4 }

{ @routine $64D33C TryShowQueuedVideo }
function TryShowQueuedVideo: Boolean;
var
  Request: PScriptVDRequest;
  Video: TxvidGI;
begin
  Result := False;
  if QueuedVideos.Count > 0 then
  begin
    Request := PScriptVDRequest(QueuedVideos[0]);
    if not SkipVideo and (TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]) = RuinsTalkScreen) then
    begin
      Video := TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).GetByName('Film') as TxvidGI;
      Video.SetActive(True);
      if Video.ImageOpen(Request.Video, False) then
      begin
        if MusicEnabled then
        begin
          MusicManager.StopImmediately;
          while MusicManager.IsPlaying do SysUtils.Sleep(1);
        end;
        if MusicEnabled then
        begin
          MusicManager.PlayCategory(Request.Soundtrack);
          while not MusicManager.IsPlaying do SysUtils.Sleep(1);
        end;
        RuinsTalkScreen.ScriptVideoStartedAt := timeGetTime;
        if RuinsTalkScreen.ScriptVideoTimer <> nil then
        begin
          RuinsTalkScreen.CancelCallbackTimer(RuinsTalkScreen.ScriptVideoTimer);
          RuinsTalkScreen.ScriptVideoTimer := nil;
        end;
        RuinsTalkScreen.ScriptVideoTimer := RuinsTalkScreen.ScheduleCallbackTimer(5, 5, RuinsTalkScreen.AdvanceScriptVideo);
      end
      else CompleteQueuedVideo(3);
    end
    else CompleteQueuedVideo(3);
    Result := True;
  end;
end;
{ @end $64D33C }

{ @routine $64D4F0 TryDispatchScriptTakeoff }
function TryDispatchScriptTakeoff: Boolean;
begin
  Result := False;
  if ScriptTakeoffRequested then
  begin
    ScriptTakeoffRequested := False;
    if (GetPlayer.CurrentPlanet <> nil) or (GetPlayer.DockedTo <> nil) then
    begin
      GetPlayer.OrderTakeoff;
      Galaxy.PrimeIntegrityChecksum(212);
      if GetPlayer.Order = soTakeoff then
      begin
        HangarScreen.TryTakeOff;
        ScriptEndTurnRequested := False;
        TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
        Result := True;
      end;
    end;
  end;
end;
{ @end $64D4F0 }

{ @routine $64D580 TryDispatchScriptEndTurn }
function TryDispatchScriptEndTurn: Boolean;
begin
  Result := False;
  if ScriptEndTurnRequested then
  begin
    ScriptEndTurnRequested := False;
    if CurrentScreenId = screenRuinsTalk then
      TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)])).MainPanel.EndTurnClicked(nil)
    else if CurrentScreenId = screenPlanet then
      TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)])).MainPanel.EndTurnClicked(nil)
    else if CurrentScreenId = screenPlanetNO then
      TMessageLoopGIWithMainPanel(TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)])).MainPanel.EndTurnClicked(nil)
    else if CurrentScreenId = screenStarMap then
      TfStarMap(TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)])).EndTurnAfterOpen := True;
    Result := True;
  end;
end;
{ @end $64D580 }

{ @routine $64D648 TryDispatchResumingScriptRequest }
function TryDispatchResumingScriptRequest: Boolean;
var
  I: Integer;
  Quest, Arcade, Planetary, Video: PQueuedTextQuest;
begin
  Result := False;
  if ResumingScript = nil then Exit;
  // Native code uses the text-quest record view for all four queues. The
  // $0C comparison is therefore not the Script field of the other records;
  // for video requests it even reads beyond their declared $0C allocation.
  for I := 0 to QueuedVideos.Count - 1 do
  begin
    Video := PQueuedTextQuest(QueuedVideos[I]);
    if Video.Script = ResumingScript then
    begin
      if I > 0 then
      begin
        QueuedVideos.Delete(I);
        QueuedVideos.Insert(0, Video);
      end;
      TryShowQueuedVideo;
      Result := True;
      Exit;
    end;
  end;
  for I := 0 to QueuedTextQuests.Count - 1 do
  begin
    Quest := PQueuedTextQuest(QueuedTextQuests[I]);
    if Quest.Script = ResumingScript then
    begin
      if I > 0 then
      begin
        QueuedTextQuests.Delete(I);
        QueuedTextQuests.Insert(0, Quest);
      end;
      TryShowQueuedTextQuest;
      Result := True;
      Exit;
    end;
  end;
  for I := 0 to QueuedArcadeBattles.Count - 1 do
  begin
    Arcade := PQueuedTextQuest(QueuedArcadeBattles[I]);
    if Arcade.Script = ResumingScript then
    begin
      if I > 0 then
      begin
        QueuedArcadeBattles.Delete(I);
        QueuedArcadeBattles.Insert(0, Arcade);
      end;
      TryShowQueuedArcadeBattle;
      Result := True;
      Exit;
    end;
  end;
  for I := 0 to QueuedPlanetaryBattles.Count - 1 do
  begin
    Planetary := PQueuedTextQuest(QueuedPlanetaryBattles[I]);
    if Planetary.Script = ResumingScript then
    begin
      if I > 0 then
      begin
        QueuedPlanetaryBattles.Delete(I);
        QueuedPlanetaryBattles.Insert(0, Planetary);
      end;
      TryRunQueuedPlanetaryBattle;
      Result := True;
      Exit;
    end;
  end;
end;
{ @end $64D648 }

{ @routine $64D818 DispatchPendingScriptRequests }
function DispatchPendingScriptRequests: Boolean;
begin
  Result := True;
  if (TurnCalculationThread <> nil) and TurnCalculationThread.IsRunning then
    TurnCalculationThread.WaitForIdle(INFINITE);
  if TryDispatchResumingScriptRequest then Exit;
  if TryShowQueuedArcadeBattle then Exit;
  if TryShowQueuedTextQuest then Exit;
  if TryRunQueuedPlanetaryBattle then Exit;
  if TryShowQueuedVideo then Exit;
  if TryDispatchScriptTakeoff then Exit;
  TryDispatchScriptEndTurn;
  Result := False;
end;
{ @end $64D818 }

{ @routine $64D890 StartScriptRequestThread }
procedure StartScriptRequestThread;
begin
  if ScriptRequestThread <> nil then
    if not ScriptRequestThread.IsRunning then ScriptRequestThread.Start;
end;
{ @end $64D890 }

{ @routine $64D8B4 TScriptThread_Create }
constructor TScriptThread.Create;
begin
  inherited Create;
end;
{ @end $64D8B4 }

{ @routine $64D8F8 TScriptThread_Execute }
procedure TScriptThread.Execute;
begin
  if (TurnCalculationThread <> nil) and TurnCalculationThread.IsRunning then
    TurnCalculationThread.WaitForIdle(INFINITE);
  if HasPendingScriptRequests then
  begin
    if CurrentScreenId = screenShip then
    begin
      ShipReturnScreenId := screenStarMap;
      TfShip2(TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)])).CloseClicked(nil);
      Exit;
    end;
    if GetPlayer.DockedTo <> nil then RequestedScreenId := screenRuinsTalk
    else if GetPlayer.CurrentPlanet <> nil then
    begin
      if GetPlayer.CurrentPlanet.OwnerId = Byte(oiUninhabited) then RequestedScreenId := screenPlanetNO
      else RequestedScreenId := screenPlanet;
    end
    else RequestedScreenId := screenStarMap;
    TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
  end;
end;
{ @end $64D8F8 }

{ @routine $64D9CC CompleteQueuedArcadeBattle }
procedure CompleteQueuedArcadeBattle(Status: Integer);
var
  Request: PScriptABRequest;
begin
  Request := PScriptABRequest(QueuedArcadeBattles[0]);
  QueuedArcadeBattles.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.GetVar('GABStatus').SetInt(Status);
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.GetVar('GABStatus').GetInt = Status then
      Request.Script.InitCode.LocalVar.GetVar('GABStatus').SetInt(0);
  end;
  Request.Ships.Clear;
  Request.Ships.Free;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $64D9CC }

{ @routine $64DABC CompleteQueuedTextQuest }
procedure CompleteQueuedTextQuest(Status: TScriptQuestStatus);
var
  Request: PQueuedTextQuest;
begin
  Request := PQueuedTextQuest(QueuedTextQuests[0]);
  QueuedTextQuests.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.GetVar('GQuestStatus').SetInt(Integer(Status));
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.GetVar('GQuestStatus').GetInt = Integer(Status) then
      Request.Script.InitCode.LocalVar.GetVar('GQuestStatus').SetInt(0);
  end;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $64DABC }

{ @routine $64DB9C CompleteQueuedPlanetaryBattle }
procedure CompleteQueuedPlanetaryBattle(Status: Integer);
var
  Request: PScriptPBRequest;
begin
  Request := PScriptPBRequest(QueuedPlanetaryBattles[0]);
  QueuedPlanetaryBattles.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.GetVar('GRobotStatus').SetInt(Status);
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.GetVar('GRobotStatus').GetInt = Status then
      Request.Script.InitCode.LocalVar.GetVar('GRobotStatus').SetInt(0);
  end;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $64DB9C }

{ @routine $64DC7C CompleteQueuedVideo }
procedure CompleteQueuedVideo(Status: Integer);
var
  Request: PScriptVDRequest;
begin
  if GetPlayer = nil then Exit;
  Request := PScriptVDRequest(QueuedVideos[0]);
  QueuedVideos.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.GetVar('GVideoStatus').SetInt(Status);
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.GetVar('GVideoStatus').GetInt = Status then
      Request.Script.InitCode.LocalVar.GetVar('GVideoStatus').SetInt(0);
  end;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $64DC7C }

{ @routine $64DD6C LogScriptStepCount }
procedure LogScriptStepCount(ExpressionCount: Integer);
begin
  AppendLogLineThreadSafe(AnsiString(GetScriptContextDescription + ' code expressions count ' + IntToWideString(ExpressionCount)));
  if ExpressionCount > 200000 then LogScriptCallHistory;
end;
{ @end $64DD6C }

{ @routine $64DE3C InitializeScriptEngine }
procedure InitializeScriptEngine;
begin
  ScriptProcess := TCodeProcessEC.Create;
  CurrentScript := nil;
  ScriptFunctionScope := TVarArrayEC.Create;
  InitializeScriptBuiltinsAndConstants(ScriptFunctionScope);
  SetScriptStepCallback(LogScriptStepCount, 100000);
end;
{ @end $64DE3C }

{ @routine $64DE80 FinalizeScriptEngine }
procedure FinalizeScriptEngine;
begin
  if ScriptFunctionScope <> nil then
  begin
    ScriptFunctionScope.Free;
    ScriptFunctionScope := nil;
  end;
  if ScriptProcess <> nil then
  begin
    ScriptProcess.Free;
    ScriptProcess := nil;
  end;
end;
{ @end $64DE80 }

{ @routine $64DEB8 RunGlobalScriptsForContext }
procedure RunGlobalScriptsForContext(Star: TStar; RunFrom: Integer);
var
  Template: TScriptTemplUnit;
  Candidates: TList;
  I: Integer;
begin
  SharedScriptVariables.GetVar('GRunFrom').SetInt(RunFrom);
  SharedScriptVariables.GetVar('GRunStar').SetDword(Cardinal(Star));
  Candidates := TList.Create;
  CollectInactiveScriptTemplates(Candidates);
  for I := 0 to Candidates.Count - 1 do
  begin
    Template := TScriptTemplUnit(Candidates[I]);
    ScriptTemplateStartRequested := False;
    try
      Template.ConditionCode.Run(ScriptProcess);
    except
      on E: EBreakMessageGI do ;
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        LogScriptCallHistory;
        raise Exception.Create(AnsiString('Error in global code of script ' + Template.FileName));
      end;
    end;
    if ScriptTemplateStartRequested then
      TryStartScriptInstanceFromTemplate(Star, nil, ScriptTemplates.IndexOf(Template));
  end;
  Candidates.Free;
end;
{ @end $64DEB8 }

{ @routine $64E138 TryStartScriptByName }
function TryStartScriptByName(AnchorStar: TStar; AnchorPlanet: TPlanet; Name: WideString): Boolean;
var
  Index: Integer;
begin
  Index := FindScriptTemplateIndex(Name);
  if Index < 0 then Result := False
  else Result := TryStartScriptInstanceFromTemplate(AnchorStar, AnchorPlanet, Index);
end;
{ @end $64E138 }

{ @routine $64E1AC TryStartScriptInstanceFromTemplate }
function TryStartScriptInstanceFromTemplate(AnchorStar: TStar; AnchorPlanet: TPlanet; TemplateIndex: Integer): Boolean;
var
  Template: TScriptTemplUnit;
  Script: TScript;
  Index: Integer;
begin
  Template := TScriptTemplUnit(ScriptTemplates[TemplateIndex]);
  Script := TScript.Create;
  Galaxy.Scripts.Add(Script);
  Template.ActiveScriptIndex := Galaxy.Scripts.Count - 1;
  Script.ClassId := Template.ClassId;
  if Script.LoadFromFile(Template.FileName, AnchorStar, AnchorPlanet, True) then
  begin
    Template.LastTurn := Galaxy.CurrentTurn;
    Inc(Template.UseCount);
    Result := True;
  end
  else
  begin
    Index := Galaxy.Scripts.IndexOf(Script);
    if Index >= 0 then
    begin
      Galaxy.Scripts.Delete(Index);
      Script.Free;
    end;
    Template.ActiveScriptIndex := -1;
    Result := False;
  end;
end;
{ @end $64E1AC }

{ @routine $64E29C TryRestartScript }
function TryRestartScript(Script: TScript; AnchorStar: TStar; AnchorPlanet: TPlanet): Boolean;
var
  Template: TScriptTemplUnit;
  NewScript: TScript;
  Index, I: Integer;
  Message: TMessagePlayer;
begin
  Result := False;
  if Script = nil then Exit;
  Index := FindScriptTemplateIndex(Script.ScriptFileName);
  if Index < 0 then Exit;
  Template := TScriptTemplUnit(ScriptTemplates[Index]);
  I := Galaxy.Scripts.IndexOf(Script);
  NewScript := TScript.Create;
  Galaxy.Scripts[I] := NewScript;
  NewScript.ClassId := Template.ClassId;
  if NewScript.LoadFromFile(Template.FileName, AnchorStar, AnchorPlanet, True) then
  begin
    Template.LastTurn := Galaxy.CurrentTurn;
    Inc(Template.UseCount);
    Result := True;
    for I := 0 to Script.EtherIds.GetCount - 1 do
    begin
      Message := FindPlayerBubbleByKey(Script.EtherIds.GetTextAt(I), False);
      if (Message <> nil) and (Message.Kind = 3) then
      begin
        Message.Kind := 5;
        Message.WasRead := False;
      end;
    end;
    Script.Free;
  end
  else
  begin
    Galaxy.Scripts[I] := Script;
    NewScript.Free;
  end;
end;
{ @end $64E29C }

{ @routine $64E428 CompileScriptTemplateCondition }
procedure CompileScriptTemplateCondition(TemplateIndex: Integer);
var
  Template: TScriptTemplUnit;
  Control: TCBufControlEC;
  CachedBuffer: TCBufEC;
  Buffer: TBufEC;
  Analyzer: TCodeAnalyzerEC;
  ErrorText: WideString;
  Version: Cardinal;
begin
  Template := TScriptTemplUnit(ScriptTemplates[TemplateIndex]);
  Control := nil;
  try
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Template.FileName);
    CachedBuffer := AcquireOrCreateBuffer(Control);
    Buffer := CachedBuffer.Buffer;
    Version := Buffer.GetUInt32;
    if (Version < 5) or (Version > 8) then
    begin
      RaiseWideMessage('Script file incorrect version');
      Exit;
    end;
    Buffer.GetUInt32;
    GlobalScriptVariables.AppendFromBuffer(Buffer);
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    Template.ConditionCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('ScriptFirstLoad.Compiler. Error=' + ErrorText);
    Template.ConditionCode.LocalVar.Add('GScriptName', vkString).SetString(Template.Name);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $64E428 }

{ @routine $64E6A4 IsStarProtectedByScript }
function IsStarProtectedByScript(Star: TStar): Boolean;
var
  I, J: Integer;
  Script: TScript;
  Binding: TScriptStar;
begin
  if Star.NoComeKling then
  begin
    Result := True;
    Exit;
  end;
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Script := TScript(Galaxy.Scripts[I]);
    for J := 0 to Script.Stars.Count - 1 do
    begin
      Binding := TScriptStar(Script.Stars[J]);
      if Binding.ProtectStar and (Binding.Star = Star) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
  Result := False;
end;
{ @end $64E6A4 }

{ @routine $64E75C ScriptDefinitionBit }
function ScriptDefinitionBit(Value: Cardinal; BitIndex: Integer): Boolean;
begin
  Result := Boolean((Value shr BitIndex) and 1);
end;
{ @end $64E75C }

{ @routine $64E780 DecodeScriptRaceMask }
function DecodeScriptRaceMask(Value: Cardinal): TOwnerMask;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [0..4];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [0];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [1];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [2];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [3];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [4];
end;
{ @end $64E780 }

{ @routine $64E85C DecodeScriptOwnerMask }
function DecodeScriptOwnerMask(Value: Cardinal): TOwnerMask;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [0..7];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [0];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [1];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [2];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [3];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [4];
  if ScriptDefinitionBit(Value, 6) then Result := Result + [5];
  if ScriptDefinitionBit(Value, 7) then Result := Result + [6];
  if ScriptDefinitionBit(Value, 8) then Result := Result + [7];
  if ScriptDefinitionBit(Value, 9) and (GetPlayer <> nil) then Result := Result + [GetPlayer.OwnerId];
end;
{ @end $64E85C }

{ @routine $64E9CC DecodeScriptEconomyMask }
function DecodeScriptEconomyMask(Value: Cardinal): TPlanetEconomies;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [peAgricultural..peIndustrial];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [peAgricultural];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [peIndustrial];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [peMixed];
end;
{ @end $64E9CC }

{ @routine $64EA64 DecodeScriptGovernmentMask }
function DecodeScriptGovernmentMask(Value: Cardinal): TPlanetGovernments;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [pgAnarchy..pgDemocracy];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [pgAnarchy];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [pgDictatorship];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [pgMonarchy];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [pgRepublic];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [pgDemocracy];
end;
{ @end $64EA64 }

{ @routine $64EB40 DecodeScriptShipTypeMask }
function DecodeScriptShipTypeMask(Value: Cardinal): TScriptShipTypeMask;
var
  I: Integer;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [0..8];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [0];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [1];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [2];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [3];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [4];
  if ScriptDefinitionBit(Value, 6) then Result := Result + [5];
  if ScriptDefinitionBit(Value, 25) then Result := Result + [7];
  for I := 7 to 24 do
    if ScriptDefinitionBit(Value, I) then
    begin
      Result := Result + [6];
      Break;
    end;
end;
{ @end $64EB40 }

{ @routine $64ECA8 DecodeScriptDominatorMask }
function DecodeScriptDominatorMask(Value: Cardinal; KlingType: Byte): TDominatorSeriesMask;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [0..2];
    Exit;
  end;
  Result := [];
  case KlingType of
    0:
      begin
        if ScriptDefinitionBit(Value, 7) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 13) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 19) then Result := Result + [2];
      end;
    1:
      begin
        if ScriptDefinitionBit(Value, 8) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 14) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 20) then Result := Result + [2];
      end;
    2:
      begin
        if ScriptDefinitionBit(Value, 9) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 15) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 21) then Result := Result + [2];
      end;
    3:
      begin
        if ScriptDefinitionBit(Value, 10) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 16) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 22) then Result := Result + [2];
      end;
    4:
      begin
        if ScriptDefinitionBit(Value, 11) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 17) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 23) then Result := Result + [2];
      end;
    5:
      begin
        if ScriptDefinitionBit(Value, 12) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 18) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 24) then Result := Result + [2];
      end;
    6:
      begin
        if ScriptDefinitionBit(Value, 26) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 28) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 30) then Result := Result + [2];
      end;
    7:
      begin
        if ScriptDefinitionBit(Value, 27) then Result := Result + [0];
        if ScriptDefinitionBit(Value, 29) then Result := Result + [1];
        if ScriptDefinitionBit(Value, 31) then Result := Result + [2];
      end;
  end;
end;
{ @end $64ECA8 }

{ @routine $64F000 DecodeScriptItemOwner }
function DecodeScriptItemOwner(Value: Integer): Byte;
begin
  if Value = 0 then Result := 0
  else if Value = 1 then Result := 1
  else if Value = 2 then Result := 2
  else if Value = 3 then Result := 3
  else if Value = 4 then Result := 4
  else if Value = 5 then Result := 5
  else if Value = 6 then Result := 6
  else if Value = 7 then Result := 7
  else Result := 6;
end;
{ @end $64F000 }

{ @routine $64F074 DecodeScriptRelationLevel }
function DecodeScriptRelationLevel(Value: Integer): TRelationLevel;
begin
  if Value = 0 then Result := rlHostile
  else if Value = 1 then Result := rlBad
  else if Value = 2 then Result := rlNormal
  else if Value = 3 then Result := rlGood
  else if Value = 4 then Result := rlExcellent
  else Result := rlHostile;
end;
{ @end $64F074 }

{ @routine $64F0C4 ScriptShipMatchesType }
function ScriptShipMatchesType(Ship: TShip; ShipTypeMask: TScriptShipTypeMask; StationNames: WideString; DominatorMasks: array of TDominatorSeriesMask): Boolean;
var
  Name: WideString;
  I, Count: Integer;
begin
  Result := False;
  if not (ShipToHullType(Ship) in ShipTypeMask) then Exit;
  if (Ship is TRuins) and (8 in ShipTypeMask) then
  begin
    Name := '';
    if not (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) then Exit;
    if TRuins(Ship).NoLanding then Exit;
    if Ship.TypeNameOverrideKey <> '' then Name := Ship.TypeNameOverrideKey
    else Name := ShipTypeNames[Ship.TypeId].Name;
    Count := CountDelimitedPartsW(StationNames, ',');
    I := 0;
    while I < Count do
    begin
      if ExtractDelimitedPartW(StationNames, I, ',') = Name then Break;
      Inc(I);
    end;
    if I >= Count then Exit;
  end;
  if Ship is TKling then
    if not (Byte((Ship as TKling).DominatorSeries) in DominatorMasks[Ord((Ship as TKling).KlingType)]) then Exit;
  Result := True;
end;
{ @end $64F0C4 }

{ @routine $64F294 CollectScriptCandidateShips }
function CollectScriptCandidateShips(Star: TStar): TList;
var
  Ship, OtherShip: TShip;
  Planet: TPlanet;
  Candidates: TList;
  I, J, K, ShipCount, PlanetCount: Integer;
  Strict: Boolean;
begin
  Candidates := TList.Create;
  ShipCount := Star.Ships.Count;
  for I := 0 to ShipCount - 1 do
  begin
    Ship := TShip(Star.Ships[I]);
    if Ship.LiberationGroup <> nil then Continue;
    Strict := (GetPlayer <> Ship) and (not (Ship is TKling) or ((Ship as TKling).KlingType <> ktBoss));
    if Ship.ScriptShip <> nil then Continue;
    if Ship.AbsoluteScriptOrder > 0 then Continue;
    if (Ship is TTranclucator) and (TTranclucator(Ship).OwnerShip <> nil) then Continue;
    if Strict and Ship.InHyperspace then Continue;
    if Strict and not (Ship is TRuins) and (Ship.EnemyShip <> nil) and (Ship.EnemyShip.CurrentStar = Ship.CurrentStar) then Continue;
    if Strict and not (Ship is TRuins) and (Ship.PartnerShip <> nil) then Continue;
    if Strict and not (Ship is TRuins) and (Ship.GetHull.HullPoints < Ship.GetHull.Weight div 2) then Continue;
    if Strict and Ship.InNormalSpace and (Sqr(Star.SafeRadius) > PointDistanceSquared(Ship.Position, MakePointF(0, 0))) then Continue;
    if Strict then
    begin
      for J := 0 to ShipCount - 1 do
      begin
        OtherShip := TShip(Star.Ships[J]);
        if OtherShip = Ship then Continue;
        if (OtherShip.EnemyShip = Ship) or (OtherShip.PartnerShip = Ship) then Break;
      end;
      if J < ShipCount then Continue;
    end;
    Candidates.Add(Ship);
  end;
  PlanetCount := Star.Planets.Count;
  for K := 0 to PlanetCount - 1 do
  begin
    Planet := TPlanet(Star.Planets[K]);
    ShipCount := Planet.Warriors.Count;
    for I := 0 to ShipCount - 1 do
    begin
      Ship := TShip(Planet.Warriors[I]);
      if Ship.ScriptShip <> nil then Continue;
      if Ship.AbsoluteScriptOrder > 0 then Continue;
      if Candidates.IndexOf(Ship) >= 0 then Continue;
      if Ship.GetHull.HullPoints < Ship.GetHull.Weight div 2 then Continue;
      Candidates.Add(Ship);
    end;
  end;
  Result := Candidates;
end;
{ @end $64F294 }

{ @routine $64F5BC FindScriptGroupCandidate }
function FindScriptGroupCandidate(Candidates: TList; Group: TScriptGroup): TShip;
var
  I: Integer;
  Ship: TShip;
  Point: TPointF;
  DistanceSquared: Single;
begin
  for I := 0 to Candidates.Count - 1 do
  begin
    Ship := TShip(Candidates[I]);
    if Ship.LiberationGroup <> nil then Continue;
    if not (Ship.OwnerId in Group.OwnerMask) then Continue;
    if not ScriptShipMatchesType(Ship, Group.ShipTypeMask, Group.StationNames, Group.DominatorMasks) then Continue;
    if GetPlayer = Ship then Continue;
    if (BlazerShip <> Ship) and (KellerShip <> Ship) and (TerronShip <> Ship) then
    begin
      if Ship.Speed < Group.MinSpeed then Continue;
      if Ship.Speed > Group.MaxSpeed then Continue;
    end;
    if (Group.WeaponRequirement = 1) and (Ship.WeaponCount <= 0) then Continue;
    if (Group.WeaponRequirement = 2) and (Ship.WeaponCount > 0) then Continue;
    if Group.MinCargoHookLevel > 0 then
    begin
      if Ship.GetCargoHook = nil then Continue;
      if Ship.GetCargoHook.GetLevel < Group.MinCargoHookLevel then Continue;
    end;
    if Ship.CargoFreeSpace < Group.MinFreeCargoSpace then Continue;
    if Ship is TRanger then
    begin
      if TRanger(Ship).CareerStatus[Ord(rcTrader)] < Group.MinTraderStatus then Continue;
      if TRanger(Ship).CareerStatus[Ord(rcTrader)] > Group.MaxTraderStatus then Continue;
      if TRanger(Ship).CareerStatus[Ord(rcWarrior)] < Group.MinWarriorStatus then Continue;
      if TRanger(Ship).CareerStatus[Ord(rcWarrior)] > Group.MaxWarriorStatus then Continue;
      if TRanger(Ship).CareerStatus[Ord(rcPirate)] < Group.MinPirateStatus then Continue;
      if TRanger(Ship).CareerStatus[Ord(rcPirate)] > Group.MaxPirateStatus then Continue;
    end;
    if (Group.MaxDistanceFromPlanet < 10000) and (Ship.CurrentPlanet <> Group.Planet) then
    begin
      Point := Group.Planet.GetPosition;
      if Ship.CurrentPlanet <> nil then DistanceSquared := PointDistanceSquared(Point, Ship.CurrentPlanet.GetPosition)
      else DistanceSquared := PointDistanceSquared(Point, Ship.Position);
      if DistanceSquared > Sqr(Group.MaxDistanceFromPlanet) then Continue;
    end;
    if (Group.MinStrength <> 0) or (Group.MaxStrength <> 0) then
    begin
      if Ship.StrengthInBestRanger < Group.MinStrength then Continue;
      if Ship.StrengthInBestRanger > Group.MaxStrength then Continue;
    end;
    Result := Ship;
    Exit;
  end;
  Result := nil;
end;
{ @end $64F5BC }

{ @routine $64F89C GetScriptShipBindingForContext }
function GetScriptShipBindingForContext(Ship: TShip; Script: TScript): TScriptShip;
var
  I: Integer;
begin
  Result := nil;
  if Ship is TPlayer then
  begin
    for I := 0 to TPlayer(Ship).ScriptShipBindings.Count - 1 do
    begin
      Result := TScriptShip(TPlayer(Ship).ScriptShipBindings[I]);
      if Result.Script = Script then Break;
      Result := nil;
    end;
  end
  else Result := TScriptShip(Ship.ScriptShip);
end;
{ @end $64F89C }

{ @routine $64F91C TScriptStar_Create }
constructor TScriptStar.Create;
begin
  inherited Create;
  Constraints := nil;
  Planets := nil;
  ShipRequirements := nil;
end;
{ @end $64F91C }

{ @routine $64F990 TScriptStar_Destroy }
destructor TScriptStar.Destroy;
begin
  ShipRequirements := nil;
  Planets := nil;
  Constraints := nil;
  inherited Destroy;
end;
{ @end $64F990 }

{ @routine $64F9F4 TScriptConstellation_Create }
constructor TScriptConstellation.Create;
begin
  inherited Create;
end;
{ @end $64F9F4 }

{ @routine $64FA38 TScriptConstellation_Destroy }
destructor TScriptConstellation.Destroy;
begin
  inherited Destroy;
end;
{ @end $64FA38 }

{ @routine $64FA6C TScriptShip_Create }
constructor TScriptShip.Create;
begin
  inherited Create;
end;
{ @end $64FA6C }

{ @routine $64FAB0 TScriptShip_Destroy }
destructor TScriptShip.Destroy;
begin
  if Ship <> nil then
  begin
    Ship.ScriptShip := nil;
    Ship := nil;
  end;
  inherited Destroy;
end;
{ @end $64FAB0 }

{ @routine $64FB00 TScriptShip_GetGroup }
function TScriptShip.GetGroup: TScriptGroup;
begin
  Result := TScriptGroup(Script.Groups[GroupIndex]);
end;
{ @end $64FB00 }

{ @routine $64FB28 TScriptPlace_Create }
constructor TScriptPlace.Create;
begin
  inherited Create;
end;
{ @end $64FB28 }

{ @routine $64FB6C TScriptPlace_Destroy }
destructor TScriptPlace.Destroy;
begin
  inherited Destroy;
end;
{ @end $64FB6C }

{ @routine $64FBA0 TScriptPlace_GetPoint }
function TScriptPlace.GetPoint: TPointF;
var
  Distance, Angle: Single;
  I, Count: Integer;
  Binding: TScriptShip;
  Center: TPointF;
begin
  if PlaceKind = spkPolar then
  begin
    Angle := HeadingDegreesToRadians(AngleOffset);
    Distance := OriginStar.MapDiameter / 2 * DistanceScale;
    Result.X := System.Sin(Angle) * Distance;
    Result.Y := System.Cos(Angle) * -Distance;
  end
  else if PlaceKind = spkPlanetPosition then Result := TPlanet(TargetValue).GetPosition
  else if PlaceKind = spkDockedPlanet then Result := MakePointF(0, 0)
  else if PlaceKind = spkStarDirection then
  begin
    Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(OriginStar.Position, TStar(TargetValue).Position) + AngleOffset));
    Distance := OriginStar.MapDiameter / 2 * DistanceScale;
    Result.X := System.Sin(Angle) * Distance;
    Result.Y := System.Cos(Angle) * -Distance;
  end
  else if PlaceKind = spkScriptItem then
  begin
    if TScriptItem(TargetValue).Item = nil then Result := MakePointF(0, 0)
    else Result := TScriptItem(TargetValue).Item.Position;
  end
  else if PlaceKind = spkGroupCentroid then
  begin
    Count := 0;
    Center := MakePointF(0, 0);
    for I := 0 to Script.Ships.Count - 1 do
    begin
      Binding := TScriptShip(Script.Ships[I]);
      if Binding.GroupIndex = Integer(TargetValue) then
      begin
        Center := AddPointsF(Center, Binding.Ship.Position);
        Inc(Count);
      end;
    end;
    if Count < 1 then Result := MakePointF(0, 0)
    else
    begin
      Center.X := Center.X / Count;
      Center.Y := Center.Y / Count;
      Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(Center, MakePointF(0, 0)) + AngleOffset));
      Distance := OriginStar.MapDiameter / 2 * DistanceScale;
      Result.X := System.Sin(Angle) * Distance + Center.X;
      Result.Y := Center.Y - System.Cos(Angle) * Distance;
    end;
  end
  else if PlaceKind = spkCoordinates then
  begin
    Center := MakePointF(TVarEC(TargetValue).GetFloat, TargetValue2.GetFloat);
    Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(Center, MakePointF(0, 0)) + AngleOffset));
    Distance := OriginStar.MapDiameter / 2 * DistanceScale;
    Result.X := System.Sin(Angle) * Distance + Center.X;
    Result.Y := Center.Y - System.Cos(Angle) * Distance;
  end;
  if PlaceKind in [spkScriptItem, spkGroupCentroid] then
    if Result.X * Result.X + Result.Y * Result.Y < 0.0001 then
    begin
      Angle := HeadingDegreesToRadians(0);
      Result.X := System.Sin(Angle) * (OriginStar.SafeRadius * 1.5);
      Result.Y := System.Cos(Angle) * (OriginStar.SafeRadius * 1.5);
    end
    else
      while Result.X * Result.X + Result.Y * Result.Y < 2 * OriginStar.SafeRadius * OriginStar.SafeRadius do
      begin
        Result.X := Result.X * 1.05;
        Result.Y := Result.Y * 1.05;
      end;
end;
{ @end $64FBA0 }

{ @routine $65004C TScriptPlace_GetRandomPoint }
function TScriptPlace.GetRandomPoint(Seed: Cardinal): TPointF;
var
  Angle: Single;
begin
  Result := GetPoint;
  if Radius <> 0 then
  begin
    Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 360, Seed));
    Result.X := Result.X + System.Sin(Angle) * (Radius * 0.9);
    Result.Y := Result.Y + -System.Cos(Angle) * (Radius * 0.9);
    if (PlaceKind in [spkScriptItem, spkGroupCentroid]) and (Result.X * Result.X + Result.Y * Result.Y < 2 * OriginStar.SafeRadius * OriginStar.SafeRadius) then
    begin
      Result.X := Result.X - System.Sin(Angle) * (Radius * 1.8);
      Result.Y := Result.Y - -System.Cos(Angle) * (Radius * 1.8);
    end;
  end;
end;
{ @end $65004C }

{ @routine $6501B4 TScriptPlace_ShipInPlace }
function TScriptPlace.ShipInPlace(Ship: TShip): Boolean;
begin
  if PlaceKind = spkDockedPlanet then Result := Ship.CurrentPlanet = TPlanet(TargetValue)
  else if not Ship.InNormalSpace then Result := False
  else Result := PointDistanceSquared(GetPoint, Ship.Position) <= Sqr(Radius);
end;
{ @end $6501B4 }

{ @routine $650228 TScriptItem_Create }
constructor TScriptItem.Create;
begin
  inherited Create;
  ActionCode := nil;
  ActionCodeInitialized := False;
  Script := nil;
end;
{ @end $650228 }

{ @routine $650280 TScriptItem_Destroy }
destructor TScriptItem.Destroy;
begin
  if Item <> nil then
  begin
    Item.ScriptItem := nil;
    Item := nil;
  end;
  if ActionCode <> nil then ActionCode.Free;
  ActionCode := nil;
  inherited Destroy;
end;
{ @end $650280 }

{ @routine $6502EC TScriptGroup_Create }
constructor TScriptGroup.Create;
begin
  inherited Create;
end;
{ @end $6502EC }

{ @routine $650330 TScriptGroup_Destroy }
destructor TScriptGroup.Destroy;
begin
  if Ships <> nil then
  begin
    Ships.Free;
    Ships := nil;
  end;
  inherited Destroy;
end;
{ @end $650330 }

{ @routine $650380 TScriptState_Create }
constructor TScriptState.Create;
begin
  inherited Create;
  StateCode := TCodeEC.Create;
  ActionCode := nil;
end;
{ @end $650380 }

{ @routine $6503DC TScriptState_Destroy }
destructor TScriptState.Destroy;
begin
  EnemyGroupNames := nil;
  EnemyGroupIndices := nil;
  if StateCode <> nil then
  begin
    StateCode.Free;
    StateCode := nil;
  end;
  if DialogCode <> nil then
  begin
    DialogCode.Free;
    DialogCode := nil;
  end;
  if ActionCode <> nil then
  begin
    ActionCode.Free;
    ActionCode := nil;
  end;
  if EntryCode <> nil then
  begin
    EntryCode.Free;
    EntryCode := nil;
  end;
  inherited Destroy;
end;
{ @end $6503DC }

{ @routine $6504A0 TScriptDialog_Create }
constructor TScriptDialog.Create;
begin
  inherited Create;
  Code := TCodeEC.Create;
end;
{ @end $6504A0 }

{ @routine $6504F4 TScriptDialog_Destroy }
destructor TScriptDialog.Destroy;
begin
  if Code <> nil then
  begin
    Code.Free;
    Code := nil;
  end;
  inherited Destroy;
end;
{ @end $6504F4 }

{ @routine $650544 TScriptDialogMsg_Create }
constructor TScriptDialogMsg.Create;
begin
  inherited Create;
  Code := TCodeEC.Create;
end;
{ @end $650544 }

{ @routine $650598 TScriptDialogMsg_Destroy }
destructor TScriptDialogMsg.Destroy;
begin
  if Code <> nil then
  begin
    Code.Free;
    Code := nil;
  end;
  inherited Destroy;
end;
{ @end $650598 }

{ @routine $6505E8 TScriptDialogAnswer_Create }
constructor TScriptDialogAnswer.Create;
begin
  inherited Create;
  AnswerCode := TCodeEC.Create;
  ActionCode := TCodeEC.Create;
end;
{ @end $6505E8 }

{ @routine $650650 TScriptDialogAnswer_Destroy }
destructor TScriptDialogAnswer.Destroy;
begin
  if AnswerCode <> nil then
  begin
    AnswerCode.Free;
    AnswerCode := nil;
  end;
  if ActionCode <> nil then
  begin
    ActionCode.Free;
    ActionCode := nil;
  end;
  inherited Destroy;
end;
{ @end $650650 }

{ @routine $6506BC TScript_Create }
constructor TScript.Create;
begin
  inherited Create;
  InitCode := TCodeEC.Create;
  TurnCode := TCodeEC.Create;
  DialogCode := TCodeEC.Create;
  Constellations := TList.Create;
  Stars := TList.Create;
  Places := TList.Create;
  Items := TList.Create;
  Groups := TList.Create;
  Ships := TList.Create;
  States := TList.Create;
  Dialogs := TList.Create;
  DialogMessages := TList.Create;
  DialogAnswers := TList.Create;
  Ether := TEther.Create;
  EtherIds := TStringsEC.Create;
  CurrentAnswer := -1;
end;
{ @end $6506BC }

{ @routine $650818 TScript_Destroy }
destructor TScript.Destroy;
begin
  if CurrentScript = Self then CurrentScript := nil;
  Clear;
  if Constellations <> nil then
  begin
    Constellations.Free;
    Constellations := nil;
  end;
  if Groups <> nil then
  begin
    Groups.Free;
    Groups := nil;
  end;
  if Items <> nil then
  begin
    Items.Free;
    Items := nil;
  end;
  if Places <> nil then
  begin
    Places.Free;
    Places := nil;
  end;
  if Stars <> nil then
  begin
    Stars.Free;
    Stars := nil;
  end;
  if States <> nil then
  begin
    States.Free;
    States := nil;
  end;
  if Ships <> nil then
  begin
    Ships.Free;
    Ships := nil;
  end;
  if Dialogs <> nil then
  begin
    Dialogs.Free;
    Dialogs := nil;
  end;
  if DialogMessages <> nil then
  begin
    DialogMessages.Free;
    DialogMessages := nil;
  end;
  if DialogAnswers <> nil then
  begin
    DialogAnswers.Free;
    DialogAnswers := nil;
  end;
  if TurnCode <> nil then
  begin
    TurnCode.Free;
    TurnCode := nil;
  end;
  if DialogCode <> nil then
  begin
    DialogCode.Free;
    DialogCode := nil;
  end;
  if InitCode <> nil then
  begin
    InitCode.Free;
    InitCode := nil;
  end;
  if Ether <> nil then
  begin
    Ether.Free;
    Ether := nil;
  end;
  if EtherIds <> nil then
  begin
    EtherIds.Free;
    EtherIds := nil;
  end;
  GroupRelations := nil;
  inherited Destroy;
end;
{ @end $650818 }

{ @routine $650A18 TScript_Clear }
procedure TScript.Clear;
var
  I: Integer;
  StateCount: Integer;
  State: TScriptState;
  Binding: TScriptShip;
  Dialog: TScriptDialog;
begin
  if States <> nil then
  begin
    StateCount := States.Count;
    for I := 0 to StateCount - 1 do
    begin
      State := TScriptState(States[I]);
      State.Free;
    end;
    States.Clear;
  end;
  if Groups <> nil then
  begin
    for I := 0 to Groups.Count - 1 do TObject(Groups[I]).Free;
    Groups.Clear;
  end;
  if Items <> nil then
  begin
    for I := 0 to Items.Count - 1 do TObject(Items[I]).Free;
    Items.Clear;
  end;
  if Places <> nil then
  begin
    for I := 0 to Places.Count - 1 do TObject(Places[I]).Free;
    Places.Clear;
  end;
  if Stars <> nil then
  begin
    for I := 0 to Stars.Count - 1 do TObject(Stars[I]).Free;
    Stars.Clear;
  end;
  if Constellations <> nil then
  begin
    for I := 0 to Constellations.Count - 1 do TObject(Constellations[I]).Free;
    Constellations.Clear;
  end;
  if Ships <> nil then
  begin
    for I := 0 to Ships.Count - 1 do
    begin
      Binding := TScriptShip(Ships[I]);
      Binding.Free;
    end;
    Ships.Clear;
  end;
  if Dialogs <> nil then
  begin
    for I := 0 to Dialogs.Count - 1 do
    begin
      Dialog := TScriptDialog(Dialogs[I]);
      Dialog.Free;
    end;
    Dialogs.Clear;
  end;
  if DialogMessages <> nil then
  begin
    for I := 0 to DialogMessages.Count - 1 do TObject(DialogMessages[I]).Free;
    DialogMessages.Clear;
  end;
  if DialogAnswers <> nil then
  begin
    for I := 0 to DialogAnswers.Count - 1 do TObject(DialogAnswers[I]).Free;
    DialogAnswers.Clear;
  end;
  if Ether <> nil then Ether.Clear;
  if InitCode <> nil then InitCode.Clear;
  if TurnCode <> nil then TurnCode.Clear;
  if DialogCode <> nil then DialogCode.Clear;
  if EtherIds <> nil then EtherIds.Clear;
  GroupRelations := nil;
end;
{ @end $650A18 }

{ @routine $650D84 TScript_PublishShipContext }
procedure TScript.PublishShipContext(Binding: TScriptShip);
begin
  CurrentShip := Binding.Ship;
  CurrentScript := Self;
  InitCode.LocalVar.GetVar('EndState').SetInt(Ord(Binding.EndState));
  InitCode.LocalVar.GetVar('CurShip').SetDword(Cardinal(CurrentShip));
end;
{ @end $650D84 }

{ @routine $650E14 TScript_PublishCurrentShip }
procedure TScript.PublishCurrentShip(Ship: TShip);
begin
  CurrentShip := Ship;
  CurrentScript := Self;
  InitCode.LocalVar.GetVar('CurShip').SetDword(Cardinal(CurrentShip));
end;
{ @end $650E14 }

{ @routine $650E68 TScript_GetStar }
function TScript.GetStar(Name: WideString): TScriptStar;
var
  I, Count: Integer;
  Star: TScriptStar;
begin
  Count := Stars.Count;
  for I := 0 to Count - 1 do
  begin
    Star := TScriptStar(Stars[I]);
    if Name = Star.Name then
    begin
      Result := Star;
      Exit;
    end;
  end;
  raise Exception.Create(AnsiString('Error.Script. Not found star =' + Name));
end;
{ @end $650E68 }

{ @routine $650F8C TScript_GetPlanetBinding }
function TScript.GetPlanetBinding(Name: WideString): PScriptPlanetBinding;
var
  I, Count, J: Integer;
  Star: TScriptStar;
begin
  Count := Stars.Count;
  for I := 0 to Count - 1 do
  begin
    Star := TScriptStar(Stars[I]);
    if Star.Planets <> nil then
      for J := 0 to High(Star.Planets) do
        if Name = Star.Planets[J].Name then
        begin
          Result := @Star.Planets[J];
          Exit;
        end;
  end;
  raise Exception.Create(AnsiString('Error.Script. Not found planet =' + Name));
end;
{ @end $650F8C }

{ @routine $6510F4 TScript_GetItem }
function TScript.GetItem(Name: WideString): TScriptItem;
var
  Item: TScriptItem;
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
  begin
    Item := TScriptItem(Items[I]);
    if Item.Name = Name then
    begin
      Result := Item;
      Exit;
    end;
  end;
  raise Exception.Create(AnsiString('Error.Script. Not found item =' + Name));
end;
{ @end $6510F4 }

{ @routine $651210 TScript_RunShipState }
procedure TScript.RunShipState(Binding: TScriptShip);
var
  SavedScript: TScript;
  SavedState, State: TScriptState;
begin
  State := Binding.State;
  try
    if (State <> nil) and (State.StateCode <> nil) then
    begin
      SavedScript := CurrentScript;
      CurrentScript := Self;
      PublishShipContext(Binding);
      SavedState := CurrentScriptState;
      CurrentScriptState := State;
      State.StateCode.Run(ScriptProcess);
      CurrentScriptState := SavedState;
      CurrentScript := SavedScript;
    end;
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in state code of script ' + ScriptFileName +
        ' state #' + WideString(IntToStr(States.IndexOf(State))) + '(' + State.Name + ')'));
    end;
  end;
end;
{ @end $651210 }

{ @routine $651490 TScript_RunTurnCode }
procedure TScript.RunTurnCode;
begin
  try
    CurrentScript := Self;
    TurnCode.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in turn code of script ' + ScriptFileName));
    end;
  end;
end;
{ @end $651490 }

{ @routine $651630 TScript_RunDialogCode }
procedure TScript.RunDialogCode;
begin
  try
    CurrentScript := Self;
    DialogCode.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in dialog code of script ' + ScriptFileName));
    end;
  end;
end;
{ @end $651630 }

{ @routine $6517D4 TScript_CallDialog }
procedure TScript.CallDialog(Index: Integer);
begin
  if (Index < 0) or (Index >= Dialogs.Count) then
    raise Exception.Create(AnsiString('Error.Script.CallDialog ' + IntToWideString(Index) + ' ' + ScriptFileName));
  CurrentScript := Self;
  CurrentDialog := Index;
  SkipGreeting := False;
  ScriptDialogIndex := -1;
  try
    TScriptDialog(Dialogs[Index]).Code.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in call dialog code of script ' + ScriptFileName + ' (' +
        TScriptDialog(Dialogs[Index]).Name + ')'));
    end;
  end;
end;
{ @end $6517D4 }

{ @routine $651A9C TScript_CallDialogByVariable }
procedure TScript.CallDialogByVariable(Name: WideString);
var
  Cell: TVarEC;
begin
  Cell := InitCode.LocalVar.GetVarNE(Name);
  if Cell = nil then raise Exception.Create(AnsiString('Dialog ' + Name + ' not found in script ' + ScriptFileName));
  CallDialog(Cell.GetInt);
end;
{ @end $651A9C }

{ @routine $651BA8 TScript_CallDialogMessage }
procedure TScript.CallDialogMessage(Index: Integer);
begin
  if (Index < 0) or (Index >= DialogMessages.Count) then
    raise Exception.Create(AnsiString('Error.Script.CallDialogMsg ' + ScriptFileName));
  try
    TScriptDialogMsg(DialogMessages[Index]).Code.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in call dialog message code of script ' + ScriptFileName +
        ' (message ' + IntToWideString(Index) + ')'));
    end;
  end;
end;
{ @end $651BA8 }

{ @routine $651E58 TScript_BuildDialogAnswer }
procedure TScript.BuildDialogAnswer(Index: Integer);
begin
  if (Index < 0) or (Index >= DialogAnswers.Count) then
    raise Exception.Create(AnsiString('Error.Script.CallDialogAnswerAnswer ' + ScriptFileName));
  CurrentAnswer := Index;
  try
    TScriptDialogAnswer(DialogAnswers[Index]).AnswerCode.Run(ScriptProcess);
    CurrentAnswer := -1;
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in call answer code of script ' + ScriptFileName +
        ' (answer ' + IntToWideString(Index) + ')'));
    end;
  end;
end;
{ @end $651E58 }

{ @routine $652118 TScript_ExecuteDialogAnswer }
procedure TScript.ExecuteDialogAnswer(Index: Integer);
begin
  if Index = -1 then Exit;
  if (Index < 0) or (Index >= DialogAnswers.Count) then
    raise Exception.Create(AnsiString('Error.Script.CallDialogAnswerCode ' + ScriptFileName));
  try
    TScriptDialogAnswer(DialogAnswers[Index]).ActionCode.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      raise Exception.Create(AnsiString('Error in add answer code of script ' + ScriptFileName +
        ' (answer ' + IntToWideString(Index) + ')'));
    end;
  end;
end;
{ @end $652118 }

{ @routine $6523C8 TScript_BindShip }
procedure TScript.BindShip(GroupIndex: Integer; Ship: TShip);
var
  Binding: TScriptShip;
begin
  Binding := TScriptShip.Create;
  Ships.Add(Binding);
  Binding.GroupIndex := GroupIndex;
  Binding.Script := Self;
  Binding.Ship := Ship;
  if Ship is TPlayer then TPlayer(Ship).ScriptShipBindings.Add(Binding)
  else Ship.ScriptShip := Binding;
  if (Ship is TWarrior) and (Ship.CurrentStar.Ships.IndexOf(Ship) = -1) then
    Ship.CurrentStar.Ships.Add(Ship);
end;
{ @end $6523C8 }

{ @routine $65247C TScript_UnbindShip }
procedure TScript.UnbindShip(Ship: TShip);
var
  I, Index: Integer;
  Binding: TScriptShip;
begin
  if Ship is TPlayer then
  begin
    I := 0;
    while I < TPlayer(Ship).ScriptShipBindings.Count do
    begin
      Index := Ships.IndexOf(TPlayer(Ship).ScriptShipBindings[I]);
      if Index >= 0 then
      begin
        Binding := TScriptShip(Ships[Index]);
        Binding.Free;
        Ships.Delete(Index);
        TPlayer(Ship).ScriptShipBindings.Delete(I);
      end
      else Inc(I);
    end;
  end
  else
  begin
    Index := Ships.IndexOf(Ship.ScriptShip);
    if Index >= 0 then
    begin
      Binding := TScriptShip(Ships[Index]);
      Binding.Free;
      Ships.Delete(Index);
    end;
    Ship.ScriptShip := nil;
  end;
end;
{ @end $65247C }

{ @routine $65256C TScript_ClearShipBindings }
procedure TScript.ClearShipBindings;
var
  I, Index: Integer;
  Binding: TScriptShip;
  Ship: TShip;
begin
  if GetPlayer <> nil then
    for I := GetPlayer.ScriptShipBindings.Count - 1 downto 0 do
    begin
      Index := Ships.IndexOf(GetPlayer.ScriptShipBindings[I]);
      if Index >= 0 then
      begin
        Binding := TScriptShip(Ships[Index]);
        Binding.Free;
        Ships.Delete(Index);
        GetPlayer.ScriptShipBindings.Delete(I);
      end;
    end;
  for I := Ships.Count - 1 downto 0 do
  begin
    Binding := TScriptShip(Ships[I]);
    Ship := Binding.Ship;
    Binding.Free;
    Ships.Delete(I);
    Ship.ScriptShip := nil;
  end;
end;
{ @end $65256C }

{ @routine $652660 TScript_ChangeState }
procedure TScript.ChangeState(Binding: TScriptShip; StateIndex: Integer);
begin
  if Binding = nil then Exit;
  Binding.State := TScriptState(States[StateIndex]);
  if Binding.State.EntryCode <> nil then Binding.State.EntryCode.Run(ScriptProcess);
  if not (Binding.Ship is TPlayer) then Binding.Ship.InitializeScriptStateOrders;
  if Binding.State.StateCode <> nil then
  begin
    PublishShipContext(Binding);
    Binding.State.StateCode.Run(ScriptProcess);
  end;
end;
{ @end $652660 }

{ @routine $6526F8 TScript_SetGroupRelation }
procedure TScript.SetGroupRelation(SourceGroup, TargetGroup: Integer; Level: TRelationLevel);
var
  Source, Target: TScriptShip;
  I, J: Integer;
begin
  if SourceGroup = TargetGroup then Exit;
  for I := 0 to Ships.Count - 1 do
  begin
    Source := TScriptShip(Ships[I]);
    if Source.GroupIndex = SourceGroup then
      for J := 0 to Ships.Count - 1 do
      begin
        Target := TScriptShip(Ships[J]);
        if (Target.GroupIndex = TargetGroup) and (Target.Ship is TRanger) then
          Source.Ship.SetStoredRangerRelationLevel(TRanger(Target.Ship), Level);
      end;
  end;
end;
{ @end $6526F8 }

{ @routine $6527C4 TScript_SetPlanetRelation }
procedure TScript.SetPlanetRelation(GroupIndex: Integer; Planet: TPlanet; Level: TRelationLevel);
var
  Binding: TScriptShip;
  I: Integer;
begin
  for I := 0 to Ships.Count - 1 do
  begin
    Binding := TScriptShip(Ships[I]);
    if (Binding.GroupIndex = GroupIndex) and (Binding.Ship is TRanger) then
      Planet.SetRelationLevelToRanger(TRanger(Binding.Ship), Level);
  end;
end;
{ @end $6527C4 }

{ @routine $65283C TScript_TryBindStars }
function TScript.TryBindStars(StarIndex: Integer): Boolean;
var
  Binding: TScriptStar;
  Star: TStar;
  J, K, I, Count, DistanceSquared: Integer;
  Bearing: Single;
  Candidates: TList;
  Hole: THole;
  ConstellationBinding: TScriptConstellation;
  Constellation: TConstellation;
  MinOrbitSquared, MaxOrbitSquared, OrbitSquared: Single;
  Planet: TPlanet;
  Ship: TShip;
  Requirement: PScriptShipRequirement;
  Indent: WideString;
  Constraint: TScriptStarConstraint;
begin
  Indent := '';
  for J := 0 to StarIndex - 1 do Indent := Indent + '    ';
  Result := False;
  Binding := TScriptStar(Stars[StarIndex]);
  Star := Binding.Star;
  if Binding.RejectHostilePresence and Star.HasHostilePresenceForScriptBinding then Exit;
  if StarIndex < 2 then Bearing := 0
  else Bearing := PointBearingDegrees(TScriptStar(Stars[0]).Star.Position, TScriptStar(Stars[1]).Star.Position);
  for J := 0 to High(Binding.Constraints) do
  begin
    Constraint := Binding.Constraints[J];
    with Constraint do
    begin
      if RequireBlackHole then
      begin
        Count := aGalaxy.Galaxy.Holes.Count;
        K := 0;
        while K < Count do
        begin
          Hole := THole(aGalaxy.Galaxy.Holes[K]);
          if (Hole.Star1 = Star) and (Hole.Star2 = OtherStar.Star) then Break;
          if (Hole.Star1 = OtherStar.Star) and (Hole.Star2 = Star) then Break;
          Inc(K);
        end;
        if K >= Count then Exit;
      end;
      if (MinDistance > 0) or (MaxDistance < 150) then
      begin
        DistanceSquared := Round(PointDistanceSquared(Star.Position, OtherStar.Star.Position));
        if (DistanceSquared < Sqr(MinDistance)) or (DistanceSquared > Sqr(MaxDistance)) then Exit;
      end;
    end;
  end;
  if Binding.Planets <> nil then
  begin
    Count := High(Binding.Planets) + 1;
    for K := 0 to Count - 1 do
    begin
      if (StarIndex = 0) and (K = 0) and (AnchorPlanet <> nil) then Binding.Planets[0].Planet := AnchorPlanet
      else
      begin
        if Star.Status.CustomFaction <> '' then Exit;
        MinOrbitSquared := Sqr(Binding.Planets[K].MinOrbitPercent / 100 * (Star.MapDiameter / 2));
        MaxOrbitSquared := Sqr(Binding.Planets[K].MaxOrbitPercent / 100 * (Star.MapDiameter / 2));
        Binding.Planets[K].Planet := nil;
        for J := 0 to Star.Planets.Count - 1 do
        begin
          Planet := TPlanet(Star.Planets[J]);
          if Planet.NoLanding then Continue;
          if not (Planet.RaceId in Binding.Planets[K].RaceMask) then Continue;
          if not (Planet.OwnerId in Binding.Planets[K].OwnerMask) then Continue;
          if not (Planet.Economy in Binding.Planets[K].EconomyMask) then Continue;
          if not (Planet.Government in Binding.Planets[K].GovernmentMask) then Continue;
          I := 0;
          while I < K do
          begin
            if Binding.Planets[I].Planet = Planet then Break;
            Inc(I);
          end;
          if I < K then Continue;
          OrbitSquared := PointDistanceSquared(Planet.GetPosition, MakePointF(0, 0));
          if OrbitSquared < MinOrbitSquared then Continue;
          // Native search stops at the first eligible orbit beyond the upper bound.
          if OrbitSquared > MaxOrbitSquared then Break;
          Binding.Planets[K].Planet := Planet;
          Break;
        end;
        if Binding.Planets[K].Planet = nil then Exit;
      end;
    end;
  end;
  if Binding.ShipRequirements <> nil then
  begin
    Candidates := CollectScriptCandidateShips(Star);
    Count := High(Binding.ShipRequirements) + 1;
    // The original early rejection leaves Candidates allocated here.
    if Candidates.Count < Count then Exit;
    for K := 0 to Count - 1 do
    begin
      Requirement := @Binding.ShipRequirements[K];
      for J := 0 to Requirement.Count - 1 do
      begin
        I := 0;
        while I < Candidates.Count do
        begin
          Ship := TShip(Candidates[I]);
          Inc(I);
          if Requirement.PlayerOnly and (GetPlayer <> Ship) then Continue;
          if Ship.LiberationGroup <> nil then Continue;
          if not (Ship.OwnerId in Requirement.OwnerMask) then Continue;
          if not ScriptShipMatchesType(Ship, Requirement.ShipTypeMask, Requirement.StationNames, Requirement.DominatorMasks) then Continue;
          if Ship.Speed < Requirement.MinSpeed then Continue;
          if Ship.Speed > Requirement.MaxSpeed then Continue;
          if (Requirement.WeaponRequirement = 1) and (Ship.WeaponCount <= 0) then Continue;
          if (Requirement.WeaponRequirement = 2) and (Ship.WeaponCount > 0) then Continue;
          if Requirement.MinCargoHookLevel > 0 then
          begin
            if Ship.GetCargoHook = nil then Continue;
            if Ship.GetCargoHook.GetLevel < Requirement.MinCargoHookLevel then Continue;
          end;
          if (Ship.CargoFreeSpace < Requirement.MinFreeCargoSpace) and (GetPlayer <> Ship) then Continue;
          if (Ship.CargoFreeSpace < Requirement.MinFreeCargoSpace) and (Requirement.MinFreeCargoSpace > 0) then Continue;
          if Ship is TRanger then
          begin
            if TRanger(Ship).CareerStatus[Ord(rcTrader)] < Requirement.MinTraderStatus then Continue;
            if TRanger(Ship).CareerStatus[Ord(rcTrader)] > Requirement.MaxTraderStatus then Continue;
            if TRanger(Ship).CareerStatus[Ord(rcWarrior)] < Requirement.MinWarriorStatus then Continue;
            if TRanger(Ship).CareerStatus[Ord(rcWarrior)] > Requirement.MaxWarriorStatus then Continue;
            if TRanger(Ship).CareerStatus[Ord(rcPirate)] < Requirement.MinPirateStatus then Continue;
            if TRanger(Ship).CareerStatus[Ord(rcPirate)] > Requirement.MaxPirateStatus then Continue;
          end;
          if (Requirement.MinStrength <> 0) or (Requirement.MaxStrength <> 0) then
          begin
            if Ship.StrengthInBestRanger < Requirement.MinStrength then Continue;
            if Ship.StrengthInBestRanger > Requirement.MaxStrength then Continue;
          end;
          Dec(I);
          Break;
        end;
        if I >= Candidates.Count then
        begin
          Candidates.Free;
          Exit;
        end;
        Candidates.Delete(I);
      end;
    end;
    Candidates.Free;
  end;
  Inc(StarIndex);
  if StarIndex >= Stars.Count then
  begin
    Result := True;
    Exit;
  end;
  Binding := TScriptStar(Stars[StarIndex]);
  if Binding.ConstellationIndex = -1 then
  begin
    Count := aGalaxy.Galaxy.Stars.Count;
    for K := 0 to Count - 1 do
    begin
      Star := TScriptStar(Stars[0]).Star.StarDistances[K].Star;
      if Binding.RejectHostilePresence and Star.HasHostilePresenceForScriptBinding then Continue;
      J := 0;
      while J < StarIndex do
      begin
        if TScriptStar(Stars[J]).Star = Star then Break;
        Inc(J);
      end;
      if J < StarIndex then Continue;
      Binding.Star := Star;
      Result := TryBindStars(StarIndex);
      if Result then Exit;
    end;
  end
  else if (Binding.ConstellationIndex >= 0) and
    (TScriptConstellation(Constellations[Binding.ConstellationIndex]).Constellation = nil) then
  begin
    Count := aGalaxy.Galaxy.Stars.Count;
    for K := 0 to Count - 1 do
    begin
      Star := TStar(aGalaxy.Galaxy.Stars[K]);
      if Binding.RejectHostilePresence and Star.HasHostilePresenceForScriptBinding then Continue;
      J := 0;
      while J < StarIndex do
      begin
        if TScriptStar(Stars[J]).Star = Star then Break;
        Inc(J);
      end;
      if J < StarIndex then Continue;
      J := 0;
      while J < Constellations.Count do
      begin
        ConstellationBinding := TScriptConstellation(Constellations[J]);
        if ConstellationBinding.Constellation <> nil then
          if ConstellationBinding.Constellation = Star.Constellation then Break;
        Inc(J);
      end;
      if J < Constellations.Count then Continue;
      ConstellationBinding := TScriptConstellation(Constellations[Binding.ConstellationIndex]);
      ConstellationBinding.Constellation := Star.Constellation;
      Binding.Star := Star;
      Result := TryBindStars(StarIndex);
      if Result then Exit;
      ConstellationBinding.Constellation := nil;
    end;
  end
  else if Binding.ConstellationIndex >= 0 then
  begin
    if TScriptConstellation(Constellations[Binding.ConstellationIndex]).Constellation <> nil then
    begin
      Constellation := TScriptConstellation(Constellations[Binding.ConstellationIndex]).Constellation;
      Count := Constellation.Stars.Count;
      for K := 0 to Count - 1 do
      begin
        Star := TStar(Constellation.Stars[K]);
        if Binding.RejectHostilePresence and Star.HasHostilePresenceForScriptBinding then Continue;
        J := 0;
        while J < StarIndex do
        begin
          if TScriptStar(Stars[J]).Star = Star then Break;
          Inc(J);
        end;
        if J < StarIndex then Continue;
        Binding.Star := Star;
        Result := TryBindStars(StarIndex);
        if Result then Exit;
      end;
    end;
  end;
  Result := False;
end;
{ @end $65283C }

{ @routine $653660 TScript_LoadFromBuffer }
function TScript.LoadFromBuffer(Buffer: TBufEC; AnchorStar: TStar; FirstPlanet: TPlanet; CreateObjects: Boolean): Boolean;
var
  Candidates: TList;
  I, Count, J, SubCount, K: Integer;
  Balance, Radius: Single;
  // The native frame retains and finalizes an otherwise unused WideString at EBP-$38.
  Text, UnusedText, ErrorText: WideString;
  Constellation: TScriptConstellation;
  Star: TScriptStar;
  PlanetBinding: PScriptPlanetBinding;
  Place: TScriptPlace;
  ScriptItem: TScriptItem;
  Group: TScriptGroup;
  Ship: TShip;
  State: TScriptState;
  Binding: TScriptShip;
  Dialog: TScriptDialog;
  DialogMessage: TScriptDialogMsg;
  DialogAnswer: TScriptDialogAnswer;
  Analyzer: TCodeAnalyzerEC;
  Item, OtherItem: TItem;
  Planet: TPlanet;
  Version, Mask: Cardinal;
  KlingType: Byte;

  // @nested $6532F0 CompileStateActionCode
  procedure CompileStateActionCode(State: TScriptState); // @addr 0x6532F0 @note "Nested helper; captures Self at ParentFrame-4. Caller removes ParentFrame."
  var
    SourceText, ActionTypes, StepTypes: WideString;
    I, Count: Integer;
    Step: Cardinal;
    Action: Byte;
  begin
    if State.OnActionText[1] = '[' then
    begin
      I := FindTextPosW(']', State.OnActionText);
      SourceText := CopyWideStringUnchecked(State.OnActionText, I + 1, Length(State.OnActionText) - I);
      ActionTypes := CopyWideStringUnchecked(State.OnActionText, 2, I - 2);
      StepTypes := ExtractDelimitedPartW(ActionTypes, 1, '|');
      ActionTypes := ExtractDelimitedPartW(ActionTypes, 0, '|');
      State.ActionCode := CompileScriptText(SourceText);
      if ((ActionTypes = '') and (StepTypes = '')) or (ActionTypes = 'Any') then State.ActionTypeMask := [satOnStep..satOnDeath]
      else if ActionTypes = '' then State.ActionTypeMask := [satOnStep]
      else
      begin
        if StepTypes <> '' then State.ActionTypeMask := [satOnStep]
        else State.ActionTypeMask := [];
        ActionTypes := ',' + ActionTypes + ',';
        for Action := Low(ScriptActionTypeNames) to High(ScriptActionTypeNames) do
          if Pos(',' + ScriptActionTypeNames[Action] + ',', ActionTypes) > 0 then
            Include(State.ActionTypeMask, Action);
      end;
      if (StepTypes = '') or (StepTypes = 'Any') then State.StepTypeMask := [0..11]
      else
      begin
        State.StepTypeMask := [];
        Count := CountDelimitedPartsW(StepTypes, ',');
        for I := 0 to Count - 1 do
        begin
          Step := ExtractDigitsToIntW(ExtractDelimitedPartW(StepTypes, I, ','));
          if Step in [0..11] then Include(State.StepTypeMask, Step);
        end;
      end;
    end
    else
    begin
      State.ActionCode := CompileScriptText(State.OnActionText);
      State.ActionTypeMask := [satOnStep..satOnDeath];
      State.StepTypeMask := [0..11];
    end;
    State.ActionCode.LinkAll(ScriptFunctionScope, False);
    State.ActionCode.LinkAll(SharedScriptVariables, False);
    State.ActionCode.LinkAll(InitCode.LocalVar, False);
    State.ActionCode.ScriptFunLinked := True;
  end;

begin
  Clear;
  AnchorPlanet := FirstPlanet;
  Result := False;
  Version := Buffer.GetUInt32;
  if (Version < 5) or (Version > 8) then
  begin
    RaiseWideMessage('Script file incorrect version');
    Exit;
  end;
  Buffer.SetPosition(Buffer.GetWord);
  CurrentScript := Self;
  InitCode.LocalVar.AppendFromBuffer(Buffer);
  Text := 'ScriptLibs.' + ExtractDelimitedPartW(ScriptFileName, 1, '.');
  if GameDataConfig.CountParamsByPath(Text) > 0 then
  begin
    if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
    Text := GameDataConfig.GetParamByPath(Text);
    Count := CountDelimitedPartsW(Text, ',');
    for I := 0 to Count - 1 do
      ScriptLibraryCache.GetLib(ExtractDelimitedPartW(Text, I, ',')).InitAllFunctions(InitCode.LocalVar);
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Constellation := TScriptConstellation.Create;
    Constellations.Add(Constellation);
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Star := TScriptStar.Create;
    Stars.Add(Star);
    Star.Name := Buffer.ReadWideString;
    Star.ConstellationIndex := Buffer.GetInt32;
    if Version < 7 then Buffer.GetBoolean;
    Star.RejectHostilePresence := Buffer.GetBoolean;
    Star.ProtectStar := Buffer.GetBoolean;
    SubCount := Buffer.GetInt32;
    if SubCount > 0 then
    begin
      SetLength(Star.Constraints, SubCount);
      if Version >= 7 then
        for J := 0 to SubCount - 1 do
        begin
          Star.Constraints[J].OtherStar := TScriptStar(Stars[Buffer.GetInt32]);
          Star.Constraints[J].MinDistance := Buffer.GetInt32;
          Star.Constraints[J].MaxDistance := Buffer.GetInt32;
          Star.Constraints[J].RequireBlackHole := Buffer.GetBoolean;
        end
      else
        for J := 0 to SubCount - 1 do
        begin
          Star.Constraints[J].OtherStar := TScriptStar(Stars[Buffer.GetInt32]);
          Buffer.GetInt32;
          Star.Constraints[J].MinDistance := Buffer.GetInt32;
          Star.Constraints[J].MaxDistance := Buffer.GetInt32;
          Buffer.GetInt32;
          Buffer.GetInt32;
          Buffer.GetInt32;
          Star.Constraints[J].RequireBlackHole := Buffer.GetBoolean;
        end;
    end;
    SubCount := Buffer.GetInt32;
    if SubCount > 0 then
    begin
      SetLength(Star.Planets, SubCount);
      for J := 0 to SubCount - 1 do
      begin
        Star.Planets[J].Name := Buffer.ReadWideString;
        Star.Planets[J].RaceMask := DecodeScriptRaceMask(Buffer.GetUInt32);
        Star.Planets[J].OwnerMask := DecodeScriptOwnerMask(Buffer.GetUInt32);
        Star.Planets[J].EconomyMask := DecodeScriptEconomyMask(Buffer.GetUInt32);
        Star.Planets[J].GovernmentMask := DecodeScriptGovernmentMask(Buffer.GetUInt32);
        Star.Planets[J].MinOrbitPercent := Buffer.GetInt32;
        Star.Planets[J].MaxOrbitPercent := Buffer.GetInt32;
        Star.Planets[J].DialogChoiceText := Buffer.ReadWideString;
      end;
    end;
    SubCount := Buffer.GetInt32;
    if SubCount > 0 then
    begin
      SetLength(Star.ShipRequirements, SubCount);
      for J := 0 to SubCount - 1 do
      begin
        Star.ShipRequirements[J].Count := Buffer.GetInt32;
        Star.ShipRequirements[J].OwnerMask := DecodeScriptOwnerMask(Buffer.GetUInt32);
        Mask := Buffer.GetUInt32;
        Star.ShipRequirements[J].ShipTypeMask := DecodeScriptShipTypeMask(Mask);
        for KlingType := 0 to 7 do Star.ShipRequirements[J].DominatorMasks[KlingType] := DecodeScriptDominatorMask(Mask, KlingType);
        Star.ShipRequirements[J].PlayerOnly := Buffer.GetBoolean;
        Star.ShipRequirements[J].MinSpeed := Buffer.GetInt32;
        Star.ShipRequirements[J].MaxSpeed := Buffer.GetInt32;
        Star.ShipRequirements[J].WeaponRequirement := Buffer.GetInt32;
        Star.ShipRequirements[J].MinCargoHookLevel := Buffer.GetInt32;
        Star.ShipRequirements[J].MinFreeCargoSpace := Buffer.GetInt32;
        if Version < 7 then
        begin
          Buffer.GetInt32;
          Buffer.GetInt32;
        end;
        Star.ShipRequirements[J].MinTraderStatus := Buffer.GetInt32;
        Star.ShipRequirements[J].MaxTraderStatus := Buffer.GetInt32;
        Star.ShipRequirements[J].MinWarriorStatus := Buffer.GetInt32;
        Star.ShipRequirements[J].MaxWarriorStatus := Buffer.GetInt32;
        Star.ShipRequirements[J].MinPirateStatus := Buffer.GetInt32;
        Star.ShipRequirements[J].MaxPirateStatus := Buffer.GetInt32;
        if Version < 7 then
        begin
          Buffer.GetInt32;
          Buffer.GetInt32;
        end;
        Star.ShipRequirements[J].MinStrength := Buffer.GetSingle;
        Star.ShipRequirements[J].MaxStrength := Buffer.GetSingle;
        Star.ShipRequirements[J].StationNames := TrimWideString(Buffer.ReadWideString);
        if Star.ShipRequirements[J].StationNames <> '' then Star.ShipRequirements[J].ShipTypeMask := Star.ShipRequirements[J].ShipTypeMask + [8];
      end;
    end;
  end;
  if CreateObjects then
  begin
    Star := TScriptStar(Stars[0]);
    Star.Star := AnchorStar;
    if Star.ConstellationIndex >= 0 then
    begin
      Constellation := TScriptConstellation(Constellations[Star.ConstellationIndex]);
      Constellation.Constellation := AnchorStar.Constellation;
    end;
    if not TryBindStars(0) then Exit;
    for I := 0 to Stars.Count - 1 do
    begin
      Star := TScriptStar(Stars[I]);
      InitCode.LocalVar.GetVar(Star.Name).SetDword(Cardinal(Star.Star));
      if Star.Planets <> nil then
        for J := 0 to High(Star.Planets) do
        begin
          PlanetBinding := @Star.Planets[J];
          InitCode.LocalVar.GetVar(PlanetBinding.Name).SetDword(Cardinal(PlanetBinding.Planet));
        end;
    end;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Place := TScriptPlace.Create;
    Places.Add(Place);
    Place.Script := Self;
    Place.Name := Buffer.ReadWideString;
    Place.OriginVarName := Buffer.ReadWideString;
    Place.PlaceKind := Buffer.GetInt32;
    if Place.PlaceKind = spkPolar then
    begin
      Place.AngleOffset := Buffer.GetSingle;
      Place.DistanceScale := Buffer.GetSingle;
      Place.Radius := Buffer.GetInt32;
    end
    else if Place.PlaceKind = spkPlanetPosition then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.Radius := Buffer.GetInt32;
    end
    else if Place.PlaceKind = spkDockedPlanet then Place.TargetVarName := Buffer.ReadWideString
    else if Place.PlaceKind = spkStarDirection then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.DistanceScale := Buffer.GetSingle;
      Place.Radius := Buffer.GetInt32;
      Place.AngleOffset := Buffer.GetSingle;
    end
    else if Place.PlaceKind = spkScriptItem then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.Radius := Buffer.GetInt32;
    end
    else if Place.PlaceKind = spkGroupCentroid then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.DistanceScale := Buffer.GetSingle;
      Place.Radius := Buffer.GetInt32;
      Place.AngleOffset := Buffer.GetSingle;
    end
    else if Place.PlaceKind = spkCoordinates then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.TargetVarName2 := Buffer.ReadWideString;
      Place.Radius := Buffer.GetInt32;
    end
    else RaiseWideMessage('Script.Place.Type');
    if CreateObjects then InitCode.LocalVar.GetVar(Place.Name).SetDword(Cardinal(Place));
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    ScriptItem := TScriptItem.Create;
    ScriptItem.Script := Self;
    Items.Add(ScriptItem);
    ScriptItem.Name := Buffer.ReadWideString;
    ScriptItem.LocationVarName := Buffer.ReadWideString;
    ScriptItem.DefinitionKind := Buffer.GetInt32;
    ScriptItem.DefinitionType := Buffer.GetInt32;
    ScriptItem.Weight := Buffer.GetInt32;
    ScriptItem.Level := Buffer.GetInt32;
    ScriptItem.DefinitionValue1C := Buffer.GetInt32;
    ScriptItem.OwnerId := DecodeScriptItemOwner(Buffer.GetInt32);
    ScriptItem.ConfigName := Buffer.ReadWideString;
    ScriptItem.CanSell := False;
    ScriptItem.Data[1] := 0;
    ScriptItem.Data[2] := 0;
    ScriptItem.Data[3] := 0;
    ScriptItem.TextData1 := '';
    ScriptItem.TextData2 := '';
    ScriptItem.TextData3 := '';
    ScriptItem.OnUseText := '';
    ScriptItem.OnActionText := '';
    InitCode.LocalVar.GetVar(ScriptItem.Name).SetDword(Cardinal(ScriptItem));
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Group := TScriptGroup.Create;
    Groups.Add(Group);
    Group.Name := Buffer.ReadWideString;
    Group.PlanetVarName := Buffer.ReadWideString;
    Group.InitialStateIndex := Buffer.GetInt32;
    Group.OwnerMask := DecodeScriptOwnerMask(Buffer.GetUInt32);
    Mask := Buffer.GetUInt32;
    Group.ShipTypeMask := DecodeScriptShipTypeMask(Mask);
    for KlingType := 0 to 7 do Group.DominatorMasks[KlingType] := DecodeScriptDominatorMask(Mask, KlingType);
    Group.MinCount := Buffer.GetInt32;
    Group.MaxCount := Buffer.GetInt32;
    Group.MinSpeed := Buffer.GetInt32;
    Group.MaxSpeed := Buffer.GetInt32;
    Group.WeaponRequirement := Buffer.GetInt32;
    Group.MinCargoHookLevel := Buffer.GetInt32;
    Group.MinFreeCargoSpace := Buffer.GetInt32;
    if Version < 7 then Buffer.GetInt32;
    Group.IncludePlayer := Buffer.GetBoolean;
    if Version < 7 then
    begin
      Buffer.GetInt32;
      Buffer.GetInt32;
      Buffer.GetInt32;
      Buffer.GetInt32;
    end;
    Group.MinTraderStatus := Buffer.GetInt32;
    Group.MaxTraderStatus := Buffer.GetInt32;
    Group.MinWarriorStatus := Buffer.GetInt32;
    Group.MaxWarriorStatus := Buffer.GetInt32;
    Group.MinPirateStatus := Buffer.GetInt32;
    Group.MaxPirateStatus := Buffer.GetInt32;
    Group.MaxDistanceFromPlanet := Buffer.GetInt32;
    Group.StationDialogVariable := Buffer.ReadWideString;
    Group.MinStrength := Buffer.GetSingle;
    Group.MaxStrength := Buffer.GetSingle;
    Group.StationNames := TrimWideString(Buffer.ReadWideString);
    if Group.StationNames <> '' then Group.ShipTypeMask := Group.ShipTypeMask + [8];
  end;
  Count := Buffer.GetInt32;
  if Count > 0 then
  begin
    SetLength(GroupRelations, Count);
    for I := 0 to Count - 1 do
    begin
      GroupRelations[I].Group1 := Buffer.GetInt32;
      GroupRelations[I].Group2 := Buffer.GetInt32;
      GroupRelations[I].Relation1To2 := Buffer.GetInt32;
      GroupRelations[I].Relation2To1 := Buffer.GetInt32;
      GroupRelations[I].MinCombatBalance := Buffer.GetSingle;
      GroupRelations[I].MaxCombatBalance := Buffer.GetSingle;
    end;
  end;
  if CreateObjects then
  begin
    for I := 0 to Groups.Count - 1 do
    begin
      Group := TScriptGroup(Groups[I]);
      Group.Ships := TList.Create;
      Group.Planet := TPlanet(InitCode.LocalVar.GetVar(Group.PlanetVarName).GetDword);
      Candidates := CollectScriptCandidateShips(Group.Planet.CurrentStar);
      SubCount := Group.MinCount;
      if Group.IncludePlayer then Dec(SubCount);
      for J := 0 to SubCount - 1 do
      begin
        Ship := FindScriptGroupCandidate(Candidates, Group);
        if Ship = nil then
        begin
          Ship := TObject(Group.Planet.GenerateShipForScriptGroup(Group)) as TShip;
          if Ship = nil then
          begin
            Candidates.Free;
            Exit;
          end;
        end;
        BindShip(I, Ship);
        Group.Ships.Add(Ship);
        if Candidates.IndexOf(Ship) >= 0 then Candidates.Delete(Candidates.IndexOf(Ship));
      end;
      if Group.IncludePlayer then BindShip(I, GetPlayer);
      Candidates.Free;
    end;
    while True do
    begin
      I := 0;
      Group := nil;
      while I <= High(GroupRelations) do
      begin
        if (GroupRelations[I].MinCombatBalance > 0) or (GroupRelations[I].MaxCombatBalance < 1000) then
        begin
          Balance := CompareShipGroupsStrength(TScriptGroup(Groups[GroupRelations[I].Group1]).Ships,
            TScriptGroup(Groups[GroupRelations[I].Group2]).Ships);
          if Balance < GroupRelations[I].MinCombatBalance then
          begin
            Group := TScriptGroup(Groups[GroupRelations[I].Group1]);
            if Group.Ships.Count < Group.MaxCount then Break;
          end
          else if Balance > GroupRelations[I].MaxCombatBalance then
          begin
            Group := TScriptGroup(Groups[GroupRelations[I].Group2]);
            if Group.Ships.Count < Group.MaxCount then Break;
          end;
          Group := nil;
        end;
        Inc(I);
      end;
      if Group = nil then Break;
      Candidates := CollectScriptCandidateShips(Group.Planet.CurrentStar);
      Ship := FindScriptGroupCandidate(Candidates, Group);
      if Ship = nil then
      begin
        Ship := TObject(Group.Planet.GenerateShipForScriptGroup(Group)) as TShip;
        if Ship = nil then
        begin
          Candidates.Free;
          Exit;
        end;
      end;
      BindShip(Groups.IndexOf(Group), Ship);
      Group.Ships.Add(Ship);
      Candidates.Free;
    end;
    for I := 0 to High(GroupRelations) do
      if (GroupRelations[I].MinCombatBalance > 0) or (GroupRelations[I].MaxCombatBalance < 1000) then
      begin
        Balance := CompareShipGroupsStrength(TScriptGroup(Groups[GroupRelations[I].Group1]).Ships,
          TScriptGroup(Groups[GroupRelations[I].Group2]).Ships);
        if (Balance < GroupRelations[I].MinCombatBalance) or (Balance > GroupRelations[I].MaxCombatBalance) then Exit;
      end;
  end;
  if CreateObjects then
    for I := 0 to High(GroupRelations) do
    begin
      if GroupRelations[I].Relation1To2 <> 5 then
        SetGroupRelation(GroupRelations[I].Group1, GroupRelations[I].Group2, DecodeScriptRelationLevel(GroupRelations[I].Relation1To2));
      if GroupRelations[I].Relation2To1 <> 5 then
        SetGroupRelation(GroupRelations[I].Group2, GroupRelations[I].Group1, DecodeScriptRelationLevel(GroupRelations[I].Relation2To1));
    end;
  Analyzer := TCodeAnalyzerEC.Create;
  Analyzer.Tokenize(Buffer.ReadWideString);
  Analyzer.RemoveComments;
  Analyzer.RemoveNewlines;
  Analyzer.RemoveWhitespace;
  Analyzer.ValidateDelimiters;
  InitCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
  Analyzer.Free;
  if ErrorText <> '' then RaiseWideMessage('CodeInit.Compiler. Error=' + ErrorText);
  InitCode.LocalVar.Add('EndState', vkInt).SetInt(0);
  InitCode.LocalVar.Add('CurShip', vkDword).SetInt(0);
  InitCode.LocalVar.Add('GABStatus', vkInt).SetInt(0);
  InitCode.LocalVar.Add('GQuestStatus', vkInt).SetInt(0);
  InitCode.LocalVar.Add('GRobotStatus', vkInt).SetInt(0);
  InitCode.LocalVar.Add('GVideoStatus', vkInt).SetInt(0);
  InitCode.LocalVar.Add('GAnswerData', vkDword).SetInt(0);
  InitCode.LinkAll(ScriptFunctionScope, False);
  InitCode.LinkAll(SharedScriptVariables, False);
  InitCode.LinkAll(InitCode.LocalVar, False);
  InitCode.ScriptFunLinked := True;
  if CreateObjects then
    try
      InitCode.Run(ScriptProcess);
    except
      on E: EBreakMessageGI do ;
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        LogScriptCallHistory;
        raise Exception.Create(AnsiString('Error in init code of script ' + ScriptFileName));
      end;
    end;
  Analyzer := TCodeAnalyzerEC.Create;
  Analyzer.Tokenize(Buffer.ReadWideString);
  Analyzer.RemoveComments;
  Analyzer.RemoveNewlines;
  Analyzer.RemoveWhitespace;
  Analyzer.ValidateDelimiters;
  TurnCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
  Analyzer.Free;
  if ErrorText <> '' then RaiseWideMessage('CodeTurn.Compiler. Error=' + ErrorText);
  TurnCode.LinkAll(ScriptFunctionScope, False);
  TurnCode.LinkAll(SharedScriptVariables, False);
  TurnCode.LinkAll(InitCode.LocalVar, False);
  TurnCode.ScriptFunLinked := True;
  if Version > 5 then
  begin
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    DialogCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('CodeTurn.Compiler. Error=' + ErrorText);
    DialogCode.LinkAll(ScriptFunctionScope, False);
    DialogCode.LinkAll(SharedScriptVariables, False);
    DialogCode.LinkAll(InitCode.LocalVar, False);
    DialogCode.ScriptFunLinked := True;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    State := TScriptState.Create;
    States.Add(State);
    State.Name := Buffer.ReadWideString;
    State.StateKind := Buffer.GetInt32;
    if (State.StateKind <> sskIdle) and (State.StateKind <> sskNormalAI) then State.TargetVarName := Buffer.ReadWideString;
    SubCount := Buffer.GetInt32;
    if SubCount > 0 then
    begin
      SetLength(State.EnemyGroupNames, SubCount);
      SetLength(State.EnemyGroupIndices, SubCount);
      for J := 0 to SubCount - 1 do State.EnemyGroupNames[J] := Buffer.ReadWideString;
    end;
    State.PickupItemVarName := Buffer.ReadWideString;
    if State.PickupItemVarName <> '' then State.PickupItem := TScriptItem(InitCode.LocalVar.GetVar(State.PickupItemVarName).GetDword);
    State.PickUpNearbyItems := Buffer.GetBoolean;
    State.DialogTextOrVariable := Buffer.ReadWideString;
    if (State.DialogTextOrVariable <> '') and (InitCode.LocalVar.GetVarNE(State.DialogTextOrVariable) = nil) then
    begin
      State.DialogCode := TCodeEC.Create;
      Analyzer := TCodeAnalyzerEC.Create;
      Analyzer.Tokenize(State.DialogTextOrVariable);
      Analyzer.RemoveComments;
      Analyzer.RemoveNewlines;
      Analyzer.RemoveWhitespace;
      Analyzer.ValidateDelimiters;
      State.DialogCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
      Analyzer.Free;
      if ErrorText <> '' then RaiseWideMessage('StateCodeText.Compiler. Error=' + ErrorText + ' State=' + State.Name);
      State.DialogCode.LinkAll(ScriptFunctionScope, False);
      State.DialogCode.LinkAll(SharedScriptVariables, False);
      State.DialogCode.LinkAll(InitCode.LocalVar, False);
      State.DialogCode.ScriptFunLinked := True;
    end;
    State.OnActionText := Buffer.ReadWideString;
    if (State.OnActionText <> '') and (Length(State.OnActionText) < 32) and
      (InitCode.LocalVar.GetVarNE(State.DialogTextOrVariable) <> nil) then State.OnActionText := '';
    if State.OnActionText <> '' then CompileStateActionCode(State);
    Text := Buffer.ReadWideString;
    if Text <> '' then
    begin
      State.EntryCode := TCodeEC.Create;
      Analyzer := TCodeAnalyzerEC.Create;
      Analyzer.Tokenize(Text);
      Analyzer.RemoveComments;
      Analyzer.RemoveNewlines;
      Analyzer.RemoveWhitespace;
      Analyzer.ValidateDelimiters;
      State.EntryCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
      Analyzer.Free;
      if ErrorText <> '' then RaiseWideMessage('StateCodeEther.Compiler. Error=' + ErrorText + ' State=' + State.Name);
      State.EntryCode.LinkAll(ScriptFunctionScope, False);
      State.EntryCode.LinkAll(SharedScriptVariables, False);
      State.EntryCode.LinkAll(InitCode.LocalVar, False);
      State.EntryCode.ScriptFunLinked := True;
    end;
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    State.StateCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('StateTurn.Compiler. Error=' + ErrorText + ' State=' + State.Name);
    State.StateCode.LinkAll(ScriptFunctionScope, False);
    State.StateCode.LinkAll(SharedScriptVariables, False);
    State.StateCode.LinkAll(InitCode.LocalVar, False);
    State.StateCode.ScriptFunLinked := True;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Dialog := TScriptDialog.Create;
    Dialogs.Add(Dialog);
    Dialog.Name := Buffer.ReadWideString;
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    Dialog.Code.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('Dialog.Code.Compiler. Error=' + ErrorText + ' State=' + Dialog.Name);
    Dialog.Code.LinkAll(ScriptFunctionScope, False);
    Dialog.Code.LinkAll(SharedScriptVariables, False);
    Dialog.Code.LinkAll(InitCode.LocalVar, False);
    Dialog.Code.ScriptFunLinked := True;
    InitCode.LocalVar.GetVar(Dialog.Name).SetInt(I);
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    DialogMessage := TScriptDialogMsg.Create;
    DialogMessages.Add(DialogMessage);
    DialogMessage.Name := Buffer.ReadWideString;
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    DialogMessage.Code.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('DialogMsg.Code.Compiler. Error=' + ErrorText + ' State=' + DialogMessage.Name);
    DialogMessage.Code.LinkAll(ScriptFunctionScope, False);
    DialogMessage.Code.LinkAll(SharedScriptVariables, False);
    DialogMessage.Code.LinkAll(InitCode.LocalVar, False);
    DialogMessage.Code.ScriptFunLinked := True;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    DialogAnswer := TScriptDialogAnswer.Create;
    DialogAnswers.Add(DialogAnswer);
    DialogAnswer.Name := Buffer.ReadWideString;
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    DialogAnswer.AnswerCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('DialogAnswer.CodeAnswer.Compiler. Error=' + ErrorText + ' State=' + DialogAnswer.Name);
    DialogAnswer.AnswerCode.LinkAll(ScriptFunctionScope, False);
    DialogAnswer.AnswerCode.LinkAll(SharedScriptVariables, False);
    DialogAnswer.AnswerCode.LinkAll(InitCode.LocalVar, False);
    DialogAnswer.AnswerCode.ScriptFunLinked := True;
    Analyzer := TCodeAnalyzerEC.Create;
    Analyzer.Tokenize(Buffer.ReadWideString);
    Analyzer.RemoveComments;
    Analyzer.RemoveNewlines;
    Analyzer.RemoveWhitespace;
    Analyzer.ValidateDelimiters;
    DialogAnswer.ActionCode.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('DialogAnswer.Code.Compiler. Error=' + ErrorText + ' State=' + DialogAnswer.Name);
    DialogAnswer.ActionCode.LinkAll(ScriptFunctionScope, False);
    DialogAnswer.ActionCode.LinkAll(SharedScriptVariables, False);
    DialogAnswer.ActionCode.LinkAll(InitCode.LocalVar, False);
    DialogAnswer.ActionCode.ScriptFunLinked := True;
  end;
  if CreateObjects then
  begin
    for I := 0 to States.Count - 1 do
    begin
      State := TScriptState(States[I]);
      if State.TargetVarName <> '' then State.TargetValue := InitCode.LocalVar.GetVar(State.TargetVarName).GetDword;
      if State.EnemyGroupIndices <> nil then
        for J := 0 to High(State.EnemyGroupIndices) do
          State.EnemyGroupIndices[J] := InitCode.LocalVar.GetVar(State.EnemyGroupNames[J]).GetInt;
    end;
    for I := 0 to Places.Count - 1 do
    begin
      Place := TScriptPlace(Places[I]);
      if Place.OriginVarName <> '' then Place.OriginStar := TStar(InitCode.LocalVar.GetVar(Place.OriginVarName).GetDword);
      if Place.PlaceKind = spkCoordinates then
      begin
        if Place.TargetVarName <> '' then Place.TargetValue := Cardinal(InitCode.LocalVar.GetVar(Place.TargetVarName));
        if Place.TargetVarName2 <> '' then Place.TargetValue2 := InitCode.LocalVar.GetVar(Place.TargetVarName2);
      end
      else if Place.TargetVarName <> '' then Place.TargetValue := InitCode.LocalVar.GetVar(Place.TargetVarName).GetDword;
    end;
    for I := 0 to Items.Count - 1 do
    begin
      ScriptItem := TScriptItem(Items[I]);
      if ScriptItem.Name = '' then Continue;
      Item := nil;
      if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 0) then
      begin
        Item := TFuelTanks.Create;
        (Item as TFuelTanks).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 1) then
      begin
        Item := TEngine.Create;
        (Item as TEngine).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 2) then
      begin
        Item := TRadar.Create;
        (Item as TRadar).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 3) then
      begin
        Item := TScaner.Create;
        (Item as TScaner).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 4) then
      begin
        Item := TRepairRobot.Create;
        (Item as TRepairRobot).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 5) then
      begin
        Item := TCargoHook.Create;
        (Item as TCargoHook).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = 0) and (ScriptItem.DefinitionType = 6) then
      begin
        Item := TDefGenerator.Create;
        (Item as TDefGenerator).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if ScriptItem.DefinitionKind = 0 then RaiseWideMessage('Script unknow item type')
      else if (ScriptItem.DefinitionKind = 1) and (ScriptItem.DefinitionType >= 0) and
        (ScriptItem.DefinitionType < CountItemTypesInMask([Ord(t_Weapon1)..Ord(t_Weapon18)])) then
      begin
        Item := TWeapon.Create;
        (Item as TWeapon).Init(TItemType(GetItemTypeFromMask([Ord(t_Weapon1)..Ord(t_Weapon18)], ScriptItem.DefinitionType + 1)), ScriptItem.Weight,
          ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if ScriptItem.DefinitionKind = 1 then RaiseWideMessage('Script unknow item type')
      else if (ScriptItem.DefinitionKind = 2) and (ScriptItem.DefinitionType >= 0) and (ScriptItem.DefinitionType <= 8) then
      begin
        Item := TGoods.Create;
        (Item as TGoods).Init(TItemType(Byte(ScriptItem.DefinitionType) - Byte(ScriptItem.DefinitionType > 4)), ScriptItem.Weight);
        (Item as TGoods).NaturalFlag := ScriptItem.DefinitionType = 5;
      end
      else if (ScriptItem.DefinitionKind = 2) and (ScriptItem.DefinitionType = 9) then RaiseWideMessage('Script. Protoplasm not support')
      else if ScriptItem.DefinitionKind = 2 then RaiseWideMessage('Script unknow item type')
      else if (ScriptItem.DefinitionKind = 3) and (ScriptItem.DefinitionType >= 0) and
        (ScriptItem.DefinitionType < CountItemTypesInMask([10..41])) then
        Item := CreateConfiguredArtefactByItemType(TItemType(GetItemTypeFromMask([10..41], ScriptItem.DefinitionType + 1)), ScriptItem.OwnerId)
      else if ScriptItem.DefinitionKind = 3 then RaiseWideMessage('Script unknow item type')
      else if ScriptItem.DefinitionKind = 4 then
      begin
        Item := TUselessItem.Create;
        (Item as TUselessItem).Init(ScriptItem.ConfigName, dsBlazer, 0, False);
      end
      else if ScriptItem.DefinitionKind = 5 then Continue
      else RaiseWideMessage('Script unknow item type');
      Item.ScriptItem := ScriptItem;
      if InitCode.LocalVar.GetVar(ScriptItem.LocationVarName).GetDword < 255 then
      begin
        Group := TScriptGroup(Groups[InitCode.LocalVar.GetVar(ScriptItem.LocationVarName).GetDword]);
        J := 0;
        while J < Group.Ships.Count do
        begin
          Ship := TShip(Group.Ships[J]);
          if Ship.CargoFreeSpace >= Item.Weight then Break;
          Inc(J);
        end;
        if J < Group.Ships.Count then
        begin
          Ship := TShip(Group.Ships[J]);
          if Item is TGoods then
          begin
            Inc(Ship.CargoGoods[Ord(Item.ItemType)].Count, TGoods(Item).Quantity);
            Item.Free;
            Item := nil;
          end
          else if Item is TArtefact then
          begin
            Ship.Artefacts.Add(Item);
            if Item is TArtefactTranclucator then
              (TObject((Item as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := Ship;
          end
          else
          begin
            Ship.Inventory.Add(Item);
            Ship.EquipItem(Item as TEquipment);
          end;
          Ship.RefreshDerivedStats(True);
        end
        else if Item is TGoods then
        begin
          for J := 0 to Group.Ships.Count - 1 do
          begin
            Ship := TShip(Group.Ships[J]);
            if Ship.CargoFreeSpace < TGoods(Item).Quantity then
            begin
              Inc(Ship.CargoGoods[Ord(Item.ItemType)].Count, Ship.CargoFreeSpace);
              // Native code adds free space to the remaining quantity here.
              Inc(TGoods(Item).Quantity, Ship.CargoFreeSpace);
              Ship.RefreshDerivedStats(True);
            end
            else
            begin
              Inc(Ship.CargoGoods[Ord(Item.ItemType)].Count, TGoods(Item).Quantity);
              TGoods(Item).Quantity := 0;
              Ship.RefreshDerivedStats(True);
              Break;
            end;
          end;
          if TGoods(Item).Quantity > 0 then
          begin
            Ship := TShip(Group.Ships[0]);
            Inc(Ship.CargoGoods[Ord(Item.ItemType)].Count, TGoods(Item).Quantity);
          end;
          Item.Free;
          Item := nil;
        end
        else
        begin
          Ship := TShip(Group.Ships[0]);
          if Item is TArtefact then Ship.Artefacts.Add(Item)
          else
          begin
            Ship.Inventory.Add(Item);
            Ship.EquipItem(Item as TEquipment);
          end;
          Ship.RefreshDerivedStats(True);
        end;
      end
      else if TObject(InitCode.LocalVar.GetVar(ScriptItem.LocationVarName).GetDword) is TPlanet then
      begin
        Planet := TPlanet(InitCode.LocalVar.GetVar(ScriptItem.LocationVarName).GetDword);
        Planet.EquipmentShop.Add(Item);
      end
      else
      begin
        Place := TScriptPlace(InitCode.LocalVar.GetVar(ScriptItem.LocationVarName).GetDword);
        if (Place.PlaceKind <> spkPolar) and (Place.PlaceKind <> spkPlanetPosition) and (Place.PlaceKind <> spkStarDirection) and (Place.PlaceKind <> spkGroupCentroid) then RaiseWideMessage('Script error place type');
        Item.Position := Place.GetPoint;
        for K := 0 to 3 do
        begin
          SubCount := Place.OriginStar.Items.Count;
          J := 0;
          while J < SubCount do
          begin
            OtherItem := TItem(Place.OriginStar.Items[J]);
            if PointDistanceSquared(Item.Position, OtherItem.Position) < 16 - 2 * K then Break;
            Inc(J);
          end;
          if J >= SubCount then Break;
          Balance := HeadingDegreesToRadians(SeededRandomIntRange(0, 360,
            aGalaxy.Galaxy.GenerationSeed * aGalaxy.Galaxy.CurrentTurn * (I + K + 1)));
          Radius := SeededRandomIntRange(0, Place.Radius,
            aGalaxy.Galaxy.GenerationSeed * aGalaxy.Galaxy.CurrentTurn * (I + K + 1 + 457) * 341);
          Item.Position := Place.GetPoint;
          Item.Position.X := Item.Position.X + Sin(Balance) * Radius;
          Item.Position.Y := Item.Position.Y - Cos(Balance) * Radius;
        end;
        Place.OriginStar.Items.Add(Item);
      end;
      ScriptItem.Item := Item;
    end;
    for I := Ships.Count - 1 downto 0 do
    begin
      Binding := TScriptShip(Ships[I]);
      ChangeState(Binding, TScriptGroup(Groups[Binding.GroupIndex]).InitialStateIndex);
    end;
    for I := 0 to Stars.Count - 1 do
    begin
      Star := TScriptStar(Stars[I]);
      if Star.ProtectStar then aGalaxy.Galaxy.CancelEnemyJumpsToStar(Star.Star);
    end;
  end;
  Result := True;
end;
{ @end $653660 }

{ @routine $656D1C TScript_LoadFromFile }
function TScript.LoadFromFile(FileName: WideString; AnchorStar: TStar; FirstPlanet: TPlanet; CreateObjects: Boolean): Boolean;
var
  Control: TCBufControlEC;
  CachedBuffer: TCBufEC;
  Failed: Boolean;
begin
  Control := nil;
  ScriptFileName := FileName;
  Failed := True;
  try
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(FileName);
    CachedBuffer := AcquireOrCreateBuffer(Control);
    Result := LoadFromBuffer(CachedBuffer.Buffer, AnchorStar, FirstPlanet, CreateObjects);
    Failed := False;
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.EvictData(TCBufEC);
      Control.Free;
    end;
    if Failed then AppendLogLineThreadSafe(AnsiString('Failed to load script: ' + FileName));
  end;
end;
{ @end $656D1C }

{ @routine $656E90 TScript_SaveState }
procedure TScript.SaveState(Buffer: TBufEC);
var
  I, J, Count: Integer;
  Binding: TScriptShip;
  Cell: TVarEC;
  Kind: TVarKind;
  Star: TScriptStar;
  ScriptItem: TScriptItem;
begin
  Buffer.AddWideStringZ(ScriptFileName);
  Ether.SaveToBuffer(Buffer);
  Count := InitCode.LocalVar.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Cell := InitCode.LocalVar.GetItem(I);
    Kind := Cell.Kind;
    if Kind = vkEmpty then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end
    else if Kind = vkInt then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddIntegerValue(Cell.GetInt);
    end
    else if Kind = vkDword then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDWord(Cell.GetDword);
    end
    else if Kind = vkFloat then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDouble(Cell.GetFloat);
    end
    else if Kind = vkString then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.GetString);
    end
    else if Kind = vkArray then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Cell.GetArray.SaveToBuffer(Buffer);
    end
    else if (Kind = vkLibraryFun) and (Cell.GetString <> '') then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.GetString);
    end
    else
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Kind := vkEmpty;
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end;
  end;
  Count := TurnCode.LocalVar.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Cell := TurnCode.LocalVar.GetItem(I);
    Kind := Cell.Kind;
    if Kind = vkEmpty then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end
    else if Kind = vkInt then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddIntegerValue(Cell.GetInt);
    end
    else if Kind = vkDword then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDWord(Cell.GetDword);
    end
    else if Kind = vkFloat then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDouble(Cell.GetFloat);
    end
    else if Kind = vkString then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.GetString);
    end
    else if Kind = vkArray then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Cell.GetArray.SaveToBuffer(Buffer);
    end
    else if (Kind = vkLibraryFun) and (Cell.GetString <> '') then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.GetString);
    end
    else
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Kind := vkEmpty;
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end;
  end;
  Buffer.AddIntegerValue(Stars.Count);
  for I := 0 to Stars.Count - 1 do
  begin
    Star := TScriptStar(Stars[I]);
    Buffer.AddWideStringZ(Star.Name);
    Buffer.AddDWord(Star.Star.Id);
    if Star.Planets = nil then Buffer.AddIntegerValue(0)
    else
    begin
      Buffer.AddIntegerValue(High(Star.Planets) + 1);
      for J := 0 to High(Star.Planets) do
      begin
        Buffer.AddWideStringZ(Star.Planets[J].Name);
        Buffer.AddDWord(Star.Planets[J].Planet.Id);
      end;
    end;
    Buffer.AddIntegerValue(0);
  end;
  Count := 0;
  for I := 0 to Items.Count - 1 do
  begin
    ScriptItem := TScriptItem(Items[I]);
    if (ScriptItem.Name <> '') or (ScriptItem.Item <> nil) then Inc(Count);
  end;
  Buffer.AddIntegerValue(Count);
  for I := 0 to Items.Count - 1 do
  begin
    ScriptItem := TScriptItem(Items[I]);
    if (ScriptItem.Name <> '') or (ScriptItem.Item <> nil) then
    begin
      Buffer.AddWideStringZ(ScriptItem.Name);
      Buffer.AddBoolean(ScriptItem.CanSell);
      Buffer.AddIntegerValue(ScriptItem.Data[1]);
      Buffer.AddIntegerValue(ScriptItem.Data[2]);
      Buffer.AddIntegerValue(ScriptItem.Data[3]);
      Buffer.AddWideStringZ(ScriptItem.TextData1);
      Buffer.AddWideStringZ(ScriptItem.TextData2);
      Buffer.AddWideStringZ(ScriptItem.TextData3);
      Buffer.AddWideStringZ(ScriptItem.OnUseText);
      Buffer.AddWideStringZ(ScriptItem.OnActionText);
      if ScriptItem.Item = nil then Buffer.AddDWord(0)
      else Buffer.AddDWord(ScriptItem.Item.Id);
    end;
  end;
  Count := Ships.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip(Ships[I]);
    Buffer.AddIntegerValue(Binding.GroupIndex);
    Buffer.AddDWord(Binding.Ship.Id);
    Buffer.AddDWord(Binding.Data[0]);
    Buffer.AddDWord(Binding.Data[1]);
    Buffer.AddDWord(Binding.Data[2]);
    Buffer.AddDWord(Binding.Data[3]);
    Buffer.AddIntegerValue(States.IndexOf(Binding.State));
    Buffer.AddWideStringZ(Binding.StateText);
    Buffer.AddBoolean(Binding.Hit);
    Buffer.AddBoolean(Binding.HitPlayer);
  end;
  Buffer.AddWideChar(WideChar(EtherIds.GetCount));
  for I := 0 to EtherIds.GetCount - 1 do Buffer.AddWideStringZ(EtherIds.GetTextAt(I));
end;
{ @end $656E90 }

{ @routine $657690 TScript_LoadState }
procedure TScript.LoadState(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, J, K, Count, SubCount, StateIndex: Integer;
  Binding: TScriptShip;
  Name: WideString;
  Cell: TVarEC;
  TemporaryCell: Boolean;
  Kind: TVarKind;
  Star: TScriptStar;
  PlanetBinding: PScriptPlanetBinding;
  ScriptItem: TScriptItem;
begin
  if not LoadFromFile(Buffer.ReadWideString, nil, nil, False) then
    raise Exception.Create('Error. Script.GameLoad');
  Ether.LoadFromBuffer(Buffer);
  TemporaryCell := False;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do
  begin
    Name := Buffer.ReadWideString;
    Cell := InitCode.LocalVar.GetVarNE(Name);
    if Cell = nil then
    begin
      Cell := TVarEC.Create(vkEmpty);
      TemporaryCell := True;
      AppendLogLineThreadSafe(AnsiString('Warning.Script.GameLoad variable not found: ' + Name + ' (' + ScriptFileName + ')'));
    end;
    Kind := TVarKind(Buffer.GetByte);
    // Definition-owned dialog/group handles must not be overwritten by saved pointers.
    if (Kind = vkDword) and not TemporaryCell then
    begin
      for J := 0 to Dialogs.Count - 1 do
        if TScriptDialog(Dialogs[J]).Name = Name then
        begin
          Cell := TVarEC.Create(vkEmpty);
          TemporaryCell := True;
          Break;
        end;
      if not TemporaryCell then
        for J := 0 to Groups.Count - 1 do
          if TScriptGroup(Groups[J]).Name = Name then
          begin
            Cell := TVarEC.Create(vkEmpty);
            TemporaryCell := True;
            Break;
          end;
    end;
    if (Kind = vkLibraryFun) and not TemporaryCell then
    begin
      Cell := TVarEC.Create(vkEmpty);
      TemporaryCell := True;
    end;
    if Kind = vkEmpty then
    begin
    end
    else if Kind = vkInt then Cell.SetInt(Buffer.GetInt32)
    else if Kind = vkDword then Cell.SetDword(Buffer.GetUInt32)
    else if Kind = vkFloat then Cell.SetFloat(Buffer.GetDouble)
    else if Kind = vkString then Cell.SetString(Buffer.ReadWideString)
    else if Kind = vkArray then
    begin
      Cell.SetArray(TVarArrayEC.Create);
      Cell.GetArray.LoadFromBuffer(Buffer);
    end
    else if Kind = vkLibraryFun then
    begin
      Cell.ConvertToKind(vkLibraryFun);
      Name := Buffer.ReadWideString;
      Cell.SetString(Name);
      if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
      try
        ScriptLibraryCache.InitFunction(Cell);
      except
        AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Name));
        Cell.ConvertToKind(vkEmpty);
      end;
    end
    else
    begin
      if TemporaryCell then Cell.Free;
      raise Exception.Create('Error. Script. Unknown variable format.');
    end;
    if TemporaryCell then
    begin
      Cell.Free;
      TemporaryCell := False;
    end;
  end;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do
  begin
    Name := Buffer.ReadWideString;
    Cell := TurnCode.LocalVar.GetVarNE(Name);
    if Cell = nil then
    begin
      Cell := TVarEC.Create(vkEmpty);
      TemporaryCell := True;
      AppendLogLineThreadSafe(AnsiString('Warning.Script.GameLoad variable not found: ' + Name + ' (' + ScriptFileName + ')'));
    end;
    Kind := TVarKind(Buffer.GetByte);
    if (Kind = vkLibraryFun) and not TemporaryCell then
    begin
      Cell := TVarEC.Create(vkEmpty);
      TemporaryCell := True;
    end;
    if Kind = vkEmpty then
    begin
    end
    else if Kind = vkInt then Cell.SetInt(Buffer.GetInt32)
    else if Kind = vkDword then Cell.SetDword(Buffer.GetUInt32)
    else if Kind = vkFloat then Cell.SetFloat(Buffer.GetDouble)
    else if Kind = vkString then Cell.SetString(Buffer.ReadWideString)
    else if Kind = vkArray then
    begin
      Cell.SetArray(TVarArrayEC.Create);
      Cell.GetArray.LoadFromBuffer(Buffer);
    end
    else if Kind = vkLibraryFun then
    begin
      Cell.ConvertToKind(vkLibraryFun);
      Name := Buffer.ReadWideString;
      Cell.SetString(Name);
      if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
      try
        ScriptLibraryCache.InitFunction(Cell);
      except
        AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Name));
        Cell.ConvertToKind(vkEmpty);
      end;
    end
    else
    begin
      if TemporaryCell then Cell.Free;
      raise Exception.Create('Error. Script. Unknown variable format.');
    end;
    if TemporaryCell then
    begin
      Cell.Free;
      TemporaryCell := False;
    end;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Name := Buffer.ReadWideString;
    Star := GetStar(Name);
    Star.Star := TObject(Galaxy.IdToStar(Buffer.GetUInt32)) as TStar;
    InitCode.LocalVar.GetVar(Star.Name).SetDword(Cardinal(Star.Star));
    SubCount := Buffer.GetInt32;
    for K := 0 to SubCount - 1 do
    begin
      Name := Buffer.ReadWideString;
      PlanetBinding := GetPlanetBinding(Name);
      PlanetBinding.Planet := TObject(Galaxy.IdToPlanet(Buffer.GetUInt32)) as TPlanet;
      InitCode.LocalVar.GetVar(PlanetBinding.Name).SetDword(Cardinal(PlanetBinding.Planet));
    end;
    Buffer.GetInt32;
  end;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Name := Buffer.ReadWideString;
    if Name = '' then
    begin
      ScriptItem := TScriptItem.Create;
      ScriptItem.Script := Self;
      Items.Add(ScriptItem);
    end
    else ScriptItem := GetItem(Name);
    if LoadedSaveVersion >= 162 then ScriptItem.CanSell := Buffer.GetBoolean;
    if LoadedSaveVersion >= 123 then
    begin
      ScriptItem.Data[1] := Buffer.GetInt32;
      ScriptItem.Data[2] := Buffer.GetInt32;
      ScriptItem.Data[3] := Buffer.GetInt32;
      ScriptItem.TextData1 := Buffer.ReadWideString;
      ScriptItem.TextData2 := Buffer.ReadWideString;
      ScriptItem.TextData3 := Buffer.ReadWideString;
    end;
    if LoadedSaveVersion >= 69 then ScriptItem.OnUseText := Buffer.ReadWideString
    else ScriptItem.OnUseText := '';
    if LoadedSaveVersion >= 87 then ScriptItem.OnActionText := Buffer.ReadWideString
    else ScriptItem.OnActionText := '';
    if Name <> '' then InitCode.LocalVar.GetVar(Name).SetDword(Cardinal(ScriptItem));
    try
      ScriptItem.Item := TObject(Galaxy.IdToItem(Buffer.GetUInt32, True)) as TItem;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        raise Exception.Create(AnsiString('Failed to load script item <' + Name + '> for script ' + ScriptFileName));
      end;
    end;
    if ScriptItem.Item <> nil then ScriptItem.Item.ScriptItem := ScriptItem;
  end;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip.Create;
    Ships.Add(Binding);
    Binding.Script := Self;
    Binding.GroupIndex := Buffer.GetInt32;
    // Kept as an ID until ResolveLoadedReferences runs after ship loading.
    Binding.Ship := TShip(Buffer.GetUInt32);
    Binding.Data[0] := Buffer.GetUInt32;
    Binding.Data[1] := Buffer.GetUInt32;
    Binding.Data[2] := Buffer.GetUInt32;
    Binding.Data[3] := Buffer.GetUInt32;
    StateIndex := Buffer.GetInt32;
    if StateIndex >= 0 then Binding.State := TScriptState(States[StateIndex])
    else Binding.State := nil;
    if LoadedSaveVersion >= 149 then
    begin
      Binding.StateText := Buffer.ReadWideString;
      if LoadedSaveVersion < 151 then Buffer.GetByte;
    end
    else Binding.StateText := '';
    Binding.Hit := Buffer.GetBoolean;
    Binding.HitPlayer := Buffer.GetBoolean;
  end;
  EtherIds.Clear;
  Count := Buffer.GetWord;
  for I := 0 to Count - 1 do EtherIds.Add(Buffer.ReadWideString);
end;
{ @end $657690 }

{ @routine $6583F4 TScript_BindImportedFunctions }
procedure TScript.BindImportedFunctions;
var
  I: Integer;
  Cell: TVarEC;
begin
  for I := 0 to InitCode.LocalVar.Count - 1 do
  begin
    Cell := InitCode.LocalVar.GetItemByNameOrder(I);
    if (Cell.RealVType = vkLibraryFun) and (Cell.GetString <> '') then
    begin
      if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
      try
        ScriptLibraryCache.InitFunction(Cell);
      except
        AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Cell.Name));
        Cell.ConvertToKind(vkEmpty);
      end;
    end;
  end;
  for I := 0 to TurnCode.LocalVar.Count - 1 do
  begin
    Cell := TurnCode.LocalVar.GetItemByNameOrder(I);
    if (Cell.RealVType = vkLibraryFun) and (Cell.GetString <> '') then
    begin
      if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
      try
        ScriptLibraryCache.InitFunction(Cell);
      except
        AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Cell.Name));
        Cell.ConvertToKind(vkEmpty);
      end;
    end;
  end;
end;
{ @end $6583F4 }

{ @routine $658658 TScript_ResolveLoadedReferences }
procedure TScript.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  I, J, Count: Integer;
  Binding: TScriptShip;
  State: TScriptState;
  Place: TScriptPlace;
begin
  Count := Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := TScriptShip(Ships[I]);
    Binding.Ship := TObject(Galaxy.IdToShip(Cardinal(Binding.Ship), True)) as TShip;
    if Binding.Ship is TPlayer then TPlayer(Binding.Ship).ScriptShipBindings.Add(Binding)
    else Binding.Ship.ScriptShip := Binding;
  end;
  for I := 0 to Places.Count - 1 do
  begin
    Place := TScriptPlace(Places[I]);
    InitCode.LocalVar.GetVar(Place.Name).SetDword(Cardinal(Place));
    if Place.OriginVarName <> '' then Place.OriginStar := TStar(InitCode.LocalVar.GetVar(Place.OriginVarName).GetDword);
    if Place.PlaceKind = spkCoordinates then
    begin
      if Place.TargetVarName <> '' then Place.TargetValue := Cardinal(InitCode.LocalVar.GetVar(Place.TargetVarName));
      if Place.TargetVarName2 <> '' then Place.TargetValue2 := InitCode.LocalVar.GetVar(Place.TargetVarName2);
    end
    else if Place.TargetVarName <> '' then Place.TargetValue := InitCode.LocalVar.GetVar(Place.TargetVarName).GetDword;
  end;
  for I := 0 to States.Count - 1 do
  begin
    State := TScriptState(States[I]);
    if State.TargetVarName <> '' then State.TargetValue := InitCode.LocalVar.GetVar(State.TargetVarName).GetDword;
    if State.EnemyGroupIndices <> nil then
      for J := 0 to High(State.EnemyGroupIndices) do
        State.EnemyGroupIndices[J] := InitCode.LocalVar.GetVar(State.EnemyGroupNames[J]).GetInt;
  end;
end;
{ @end $658658 }

{ @routine $6588C8 ClearScriptDialogRules }
procedure ClearScriptDialogRules;
var
  I, Count: Integer;
begin
  // Native untyped Dispose: these records have no managed-field finalization.
  if ScriptDialogOverrides <> nil then
  begin
    Count := ScriptDialogOverrides.Count;
    for I := 0 to Count - 1 do Dispose(Pointer(ScriptDialogOverrides[I]));
    ScriptDialogOverrides.Clear;
  end
  else ScriptDialogOverrides := TObjectList.Create;
  if ScriptDialogInjections <> nil then
  begin
    Count := ScriptDialogInjections.Count;
    for I := 0 to Count - 1 do Dispose(Pointer(ScriptDialogInjections[I]));
    ScriptDialogInjections.Clear;
  end
  else ScriptDialogInjections := TObjectList.Create;
  if ScriptDialogBlocks <> nil then
  begin
    Count := ScriptDialogBlocks.Count;
    for I := 0 to Count - 1 do Dispose(Pointer(ScriptDialogBlocks[I]));
    ScriptDialogBlocks.Clear;
  end
  else ScriptDialogBlocks := TObjectList.Create;
end;
{ @end $6588C8 }

{ @routine $6589F4 TLibraryHandler_Create }
constructor TLibraryHandler.Create(LibraryName: WideString; ModuleHandle: Cardinal; DefinitionBlock: TBlockParEC);
begin
  inherited Create;
  Self.LibraryName := LibraryName;
  Self.ModuleHandle := ModuleHandle;
  Self.DefinitionBlock := DefinitionBlock;
end;
{ @end $6589F4 }

{ @routine $658A90 TLibraryHandler_Destroy }
destructor TLibraryHandler.Destroy;
begin
  if ModuleHandle <> 0 then FreeLibrary(ModuleHandle);
  inherited Destroy;
end;
{ @end $658A90 }

{ @routine $658AFC TLibraryHandler_InitFunction }
procedure TLibraryHandler.InitFunction(Cell: TVarEC);
var
  Name, Text, Kind: WideString;
  I, Count: Integer;
  Proc: Pointer;
  Signature: array of Dword;
begin
  Text := Cell.GetString;
  Name := ExtractDelimitedPartW(Text, 1, ',');
  Text := DefinitionBlock.GetParam(Name);
  Count := CountDelimitedPartsW(Text, ',');
  if Count < 2 then
    raise Exception.Create(AnsiString('Failed to init library function ' + Name + ' from ' + LibraryName));
  Proc := GetProcAddress(ModuleHandle, PAnsiChar(AnsiString(ExtractDelimitedPartW(Text, 1, ','))));
  if Proc = nil then
    raise Exception.Create(AnsiString('Failed to find library function ' + Name + ' in ' + LibraryName));
  SetLength(Signature, Count);
  Kind := ExtractDelimitedPartW(Text, 0, ',');
  if Kind = 'int' then Signature[0] := Ord(lvInt)
  else if Kind = 'dword' then Signature[0] := Ord(lvDword)
  else if Kind = 'float' then Signature[0] := Ord(lvFloat)
  else if Kind = 'str' then Signature[0] := Ord(lvString)
  else Signature[0] := Ord(lvVoid);
  Signature[1] := Cardinal(Proc);
  for I := 2 to Count - 1 do
  begin
    Kind := ExtractDelimitedPartW(Text, I, ',');
    if Kind = 'int' then Signature[I] := Ord(lvInt)
    else if Kind = 'dword' then Signature[I] := Ord(lvDword)
    else if Kind = 'float' then Signature[I] := Ord(lvFloat)
    else if Kind = 'str' then Signature[I] := Ord(lvString)
    else if Kind = 'ref' then Signature[I] := Ord(lvRef)
    else if Kind = 'code' then Signature[I] := Ord(lvCode)
    else raise Exception.Create(AnsiString('Failed to init library function ' + Name + ' from ' + LibraryName + ' - unknown type ' + Kind));
  end;
  Cell.SetLibrarySignature(Signature);
  SetLength(Signature, 0);
end;
{ @end $658AFC }

{ @routine $658FE4 TLibraryHandler_InitAllFunctions }
procedure TLibraryHandler.InitAllFunctions(Scope: TVarArrayEC);
var
  I, Count: Integer;
  Name: WideString;
  Cell: TVarEC;
begin
  Count := DefinitionBlock.GetParamCount;
  for I := 0 to Count - 1 do
  begin
    Name := DefinitionBlock.GetParamName(I);
    if Name = 'Path' then Continue;
    Cell := Scope.GetVarNE(Name);
    if Cell = nil then
    begin
      Cell := TVarEC.Create(vkLibraryFun);
      Cell.Name := Name;
      Scope.AddItem(Cell);
    end;
    if Cell.RealVType = vkLibraryFun then
    begin
      Cell.SetString(LibraryName + ',' + Name);
      InitFunction(Cell);
    end;
  end;
end;
{ @end $658FE4 }

{ @routine $659114 TLibraryCache_Create }
constructor TLibraryCache.Create;
begin
  inherited Create;
  Libraries := TObjectList.Create;
end;
{ @end $659114 }

{ @routine $659168 TLibraryCache_Destroy }
destructor TLibraryCache.Destroy;
begin
  Libraries.Free;
  inherited Destroy;
end;
{ @end $659168 }

{ @routine $659300 TLibraryCache_GetLib }
function TLibraryCache.GetLib(Name: WideString): TLibraryHandler;
var
  LowIndex, HighIndex, Middle, Comparison: Integer;
  Entry: TLibraryHandler;

  // @nested $6591A4 LoadHandler
  function LoadHandler: TLibraryHandler; // @addr 0x6591A4 @ida "TLibraryHandler *__cdecl $name(void *ParentFrame);" @note "Nested helper; captures the library name at ParentFrame-4. Returns nil when its ScriptLibs block is absent."
  var
    Module: Cardinal;
    Definition: TBlockParEC;
  begin
    Result := nil;
    Definition := GameDataConfig.FindBlockByPath('ScriptLibs.' + Name);
    if Definition = nil then Exit;
    Module := LoadLibraryW(PWideChar(Definition.GetParam('Path')));
    if Module = 0 then raise Exception.Create(AnsiString('Failed to load library ' + Name));
    Result := TLibraryHandler.Create(Name, Module, Definition);
  end;

begin
  if Libraries.Count < 1 then
  begin
    Result := LoadHandler;
    Libraries.Add(Result);
    Exit;
  end;
  LowIndex := 0;
  Entry := TLibraryHandler(Libraries[0]);
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.LibraryName));
  if Comparison = 0 then
  begin
    Result := Entry;
    Exit;
  end;
  if Comparison < 0 then
  begin
    Result := LoadHandler;
    Libraries.Insert(0, Result);
    Exit;
  end;
  HighIndex := Libraries.Count - 1;
  Entry := TLibraryHandler(Libraries[HighIndex]);
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.LibraryName));
  if Comparison = 0 then
  begin
    Result := Entry;
    Exit;
  end;
  if Comparison > 0 then
  begin
    Result := LoadHandler;
    Libraries.Add(Result);
    Exit;
  end;
  while True do
  begin
    if HighIndex - LowIndex < 2 then
    begin
      Result := LoadHandler;
      Libraries.Insert(HighIndex, Result);
      Exit;
    end;
    Middle := (LowIndex + HighIndex) div 2;
    Entry := TLibraryHandler(Libraries[Middle]);
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.LibraryName));
    if Comparison = 0 then
    begin
      Result := Entry;
      Exit;
    end;
    if Comparison < 0 then HighIndex := Middle
    else LowIndex := Middle;
  end;
end;
{ @end $659300 }

{ @routine $6594E0 TLibraryCache_InitFunction }
procedure TLibraryCache.InitFunction(Cell: TVarEC);
begin
  GetLib(ExtractDelimitedPartW(Cell.GetString, 0, ',')).InitFunction(Cell);
end;
{ @end $6594E0 }

{ @routine $659564 ExecuteScriptText }
procedure ExecuteScriptText(SourceText: WideString; Scope: TVarArrayEC);
var
  Code: TCodeEC;
  SavedScript: TScript;
  ScriptScope: TVarArrayEC;
begin
  Code := CompileScriptText(SourceText);
  SavedScript := CurrentScript;
  if Scope = nil then CurrentScript := nil;
  Code.LinkAll(SharedScriptVariables, False);
  Code.LinkAll(ScriptFunctionScope, False);
  Code.ScriptFunLinked := True;
  if Scope <> nil then Code.LinkAll(Scope, False);
  if CurrentScript <> nil then
  begin
    ScriptScope := CurrentScript.InitCode.LocalVar;
    if ScriptScope <> Scope then Code.LinkAll(ScriptScope, False);
  end;
  try
    Code.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      AppendLogLineThreadSafe('Error while executing code from string: ');
      if Length(SourceText) <= 256 then AppendLogLineThreadSafe(AnsiString(SourceText))
      else AppendLogLineThreadSafe(AnsiString(Copy(SourceText, 1, 256) + ' ...'));
      raise;
    end;
  end;
  CurrentScript := SavedScript;
  Code.Free;
end;
{ @end $659564 }

{ @routine $6597F0 CompileScriptText }
function CompileScriptText(SourceText: WideString): TCodeEC;
var
  Analyzer: TCodeAnalyzerEC;
  ErrorText, DelimiterError: WideString;
begin
  Analyzer := TCodeAnalyzerEC.Create;
  Analyzer.Tokenize(SourceText);
  Analyzer.RemoveComments;
  Analyzer.RemoveNewlines;
  Analyzer.RemoveWhitespace;
  DelimiterError := Analyzer.ValidateDelimiters;
  Result := TCodeEC.Create;
  Result.Compile(Analyzer, nil, nil, nil, nil, ErrorText);
  if ErrorText <> '' then
  begin
    AppendLogLineThreadSafe(AnsiString('Compiler. Error=' + ErrorText));
    AppendLogLineThreadSafe('');
    AppendLogLineThreadSafe(AnsiString(SourceText));
    AppendLogLineThreadSafe('');
    RaiseWideMessage('Compiler. Error=' + ErrorText);
  end;
  Analyzer.Free;
end;
{ @end $6597F0 }

{ @routine $659968 RunScriptCode }
procedure RunScriptCode(ContextName: WideString; Code, ParentCode: TCodeEC);
begin
  Code.LinkAll(SharedScriptVariables, False);
  if not Code.ScriptFunLinked then
  begin
    Code.LinkAll(ScriptFunctionScope, False);
    Code.ScriptFunLinked := True;
  end;
  if ParentCode <> nil then Code.LinkAll(ParentCode.LocalVar, False);
  try
    Code.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      AppendLogLineThreadSafe('Error while executing code from string: ');
      if Length(ContextName) <= 128 then AppendLogLineThreadSafe(AnsiString(ContextName))
      else AppendLogLineThreadSafe(AnsiString(Copy(ContextName, 1, 128) + ' ...'));
      raise Exception.Create('');
    end;
  end;
end;
{ @end $659968 }

{ @routine $659BB8 TScriptCache_Create }
constructor TScriptCache.Create;
begin
  inherited Create;
  Entries := TObjectList.Create;
end;
{ @end $659BB8 }

{ @routine $659C0C TScriptGICache_Create }
constructor TScriptGICache.Create;
begin
  inherited Create;
  Entries := TObjectList.Create;
end;
{ @end $659C0C }

{ @routine $659C60 TScriptCache_Destroy }
destructor TScriptCache.Destroy;
begin
  Entries.Free;
  Entries := nil;
  inherited Destroy;
end;
{ @end $659C60 }

{ @routine $659CA4 TScriptGICache_Destroy }
destructor TScriptGICache.Destroy;
begin
  Entries.Free;
  Entries := nil;
  inherited Destroy;
end;
{ @end $659CA4 }

{ @routine $659D70 TScriptGICache_GetOrCompile }
function TScriptGICache.GetOrCompile(Block: TBlockParEC): TScriptGICacheUnit;
var
  LowIndex, HighIndex, Middle: Integer;
  Key: Cardinal;
  Entry: TScriptGICacheUnit;

  // @nested $659CE8 CreateUiCacheEntry
  function CreateUiCacheEntry: TScriptGICacheUnit; // @addr $659CE8 @ida "TScriptGICacheUnit *__cdecl $name(void *ParentFrame);" @note "Nested helper; captures Block at ParentFrame-4."
  var
    Text: WideString;
  begin
    Result := nil;
    if Block = nil then Exit;
    Text := Block.ConcatenateValues;
    if Text = '' then Exit;
    Result := TScriptGICacheUnit.Create;
    Result.Initialize(Block, Text);
  end;


begin
  Result := nil;
  if Entries.Count < 1 then
  begin
    Entry := CreateUiCacheEntry;
    if Entry <> nil then
    begin
      Entries.Add(Entry);
      Result := Entry;
    end;
    Exit;
  end;
  Key := Cardinal(Block);
  LowIndex := 0;
  Entry := TScriptGICacheUnit(Entries[0]);
  if Entry.Block = Block then
  begin
    Result := Entry;
    Exit;
  end;
  if Key < Cardinal(Entry.Block) then
  begin
    Entry := CreateUiCacheEntry;
    if Entry <> nil then
    begin
      Entries.Insert(0, Entry);
      Result := Entry;
    end;
    Exit;
  end;
  HighIndex := Entries.Count - 1;
  Entry := TScriptGICacheUnit(Entries[HighIndex]);
  if Entry.Block = Block then
  begin
    Result := Entry;
    Exit;
  end;
  if Key > Cardinal(Entry.Block) then
  begin
    Entry := CreateUiCacheEntry;
    if Entry <> nil then
    begin
      Entries.Add(Entry);
      Result := Entry;
    end;
    Exit;
  end;
  while True do
  begin
    if HighIndex - LowIndex < 2 then
    begin
      Entry := CreateUiCacheEntry;
      if Entry <> nil then
      begin
        Entries.Insert(HighIndex, Entry);
        Result := Entry;
      end;
      Exit;
    end;
    Middle := (LowIndex + HighIndex) div 2;
    Entry := TScriptGICacheUnit(Entries[Middle]);
    if Entry.Block = Block then
    begin
      Result := Entry;
      Exit;
    end;
    if Key < Cardinal(Entry.Block) then HighIndex := Middle
    else LowIndex := Middle;
  end;
end;
{ @end $659D70 }

{ @routine $65A058 TScriptCache_GetOrCompile }
function TScriptCache.GetOrCompile(Name: WideString; Config: TBlockParEC): TScriptCacheUnit;
var
  LowIndex, HighIndex, Middle, Comparison: Integer;
  Entry: TScriptCacheUnit;
  SourceBlock: TBlockParEC;

  // @nested $659F20 CreateEntry
  function CreateEntry: TScriptCacheUnit; // @addr 0x659F20 @ida "TScriptCacheUnit *__cdecl $name(void *ParentFrame);" @note "Nested helper; captures source block, config, and name at ParentFrame-4, -8, and -12. Caller owns a non-nil result."
  var
    Text, ActionTypes, StepTypes: WideString;
  begin
    Result := nil;
    Text := SourceBlock.ConcatenateValues;
    if Text = '' then Exit;
    Result := TScriptCacheUnit.Create;
    if Config.CountParams('OnActCodeTypes') > 0 then ActionTypes := Config.GetParam('OnActCodeTypes')
    else ActionTypes := '';
    if Config.CountParams('OnActStepTypes') > 0 then StepTypes := Config.GetParam('OnActStepTypes')
    else StepTypes := '';
    Result.Initialize(Name, Text, ActionTypes, StepTypes);
  end;

begin
  Result := nil;
  SourceBlock := Config.FindBlock('OnActCode');
  if SourceBlock = nil then Exit;
  if Entries.Count < 1 then
  begin
    Entry := CreateEntry;
    if Entry <> nil then
    begin
      Entries.Add(Entry);
      Result := Entry;
    end;
    Exit;
  end;
  LowIndex := 0;
  Entry := TScriptCacheUnit(Entries[0]);
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
  if Comparison = 0 then
  begin
    Result := Entry;
    Exit;
  end;
  if Comparison < 0 then
  begin
    Entry := CreateEntry;
    if Entry <> nil then
    begin
      Entries.Insert(0, Entry);
      Result := Entry;
    end;
    Exit;
  end;
  HighIndex := Entries.Count - 1;
  Entry := TScriptCacheUnit(Entries[HighIndex]);
  Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
  if Comparison = 0 then
  begin
    Result := Entry;
    Exit;
  end;
  if Comparison > 0 then
  begin
    Entry := CreateEntry;
    if Entry <> nil then
    begin
      Entries.Add(Entry);
      Result := Entry;
    end;
    Exit;
  end;
  while True do
  begin
    if HighIndex - LowIndex < 2 then
    begin
      Entry := CreateEntry;
      if Entry <> nil then
      begin
        Entries.Insert(HighIndex, Entry);
        Result := Entry;
      end;
      Exit;
    end;
    Middle := (LowIndex + HighIndex) div 2;
    Entry := TScriptCacheUnit(Entries[Middle]);
    Comparison := CompareScriptNames(PWideChar(Name), PWideChar(Entry.Name));
    if Comparison = 0 then
    begin
      Result := Entry;
      Exit;
    end;
    if Comparison < 0 then HighIndex := Middle
    else LowIndex := Middle;
  end;
end;
{ @end $65A058 }

{ @routine $65A2B4 TScriptCacheUnit_Create }
constructor TScriptCacheUnit.Create;
begin
  inherited Create;
  Code := nil;
end;
{ @end $65A2B4 }

{ @routine $65A300 TScriptCacheUnit_Destroy }
destructor TScriptCacheUnit.Destroy;
begin
  if Code <> nil then Code.Free;
  Code := nil;
  inherited Destroy;
end;
{ @end $65A300 }

{ @routine $65A350 TScriptCacheUnit_Initialize }
procedure TScriptCacheUnit.Initialize(Name, SourceText, ActionTypes, StepTypes: WideString);
var
  Action: Byte;
  I: Integer;
  Step: Cardinal;
  Count: Integer;
begin
  Self.Name := Name;
  Self.SourceText := SourceText;
  Code := CompileScriptText(SourceText);
  if ((ActionTypes = '') and (StepTypes = '')) or (ActionTypes = 'Any') then ActionTypeMask := [satOnStep..satOnDeath]
  else if ActionTypes = '' then ActionTypeMask := [satOnStep]
  else
  begin
    if StepTypes <> '' then ActionTypeMask := [satOnStep]
    else ActionTypeMask := [];
    ActionTypes := ',' + ActionTypes + ',';
    for Action := Low(ScriptActionTypeNames) to High(ScriptActionTypeNames) do
      if Pos(',' + ScriptActionTypeNames[Action] + ',', ActionTypes) > 0 then Include(ActionTypeMask, Action);
  end;
  if (StepTypes = '') or (StepTypes = 'Any') then StepTypeMask := [0..11]
  else
  begin
    StepTypeMask := [];
    Count := CountDelimitedPartsW(StepTypes, ',');
    for I := 0 to Count - 1 do
    begin
      Step := ExtractDigitsToIntW(ExtractDelimitedPartW(StepTypes, I, ','));
      if Step in [0..11] then Include(StepTypeMask, Step);
    end;
  end;
end;
{ @end $65A350 }

{ @routine $65A5DC TScriptGICacheUnit_Create }
constructor TScriptGICacheUnit.Create;
begin
  inherited Create;
  Code := nil;
end;
{ @end $65A5DC }

{ @routine $65A628 TScriptGICacheUnit_Destroy }
destructor TScriptGICacheUnit.Destroy;
begin
  if Code <> nil then Code.Free;
  Code := nil;
  inherited Destroy;
end;
{ @end $65A628 }

{ @routine $65A678 TScriptGICacheUnit_Initialize }
procedure TScriptGICacheUnit.Initialize(Block: TBlockParEC; SourceText: WideString);
begin
  Self.Block := Block;
  Self.SourceText := SourceText;
  Code := CompileScriptText(SourceText);
end;
{ @end $65A678 }

{ @routine $65A6E4 GetCachedActionCode }
function GetCachedActionCode(var Cache: TScriptCache; Name: WideString; Config: TBlockParEC): TScriptCacheUnit;
begin
  Result := nil;
  if Config = nil then Exit;
  if Cache = nil then Cache := TScriptCache.Create;
  Result := Cache.GetOrCompile(Name, Config);
end;
{ @end $65A6E4 }

{ @routine $65A764 ExecuteGameplayUiCode }
procedure ExecuteGameplayUiCode(Block: TBlockParEC; VirtualKey: Cardinal);
var
  Entry: TScriptGICacheUnit;
  Code: TCodeEC;
  SavedScript: TScript;
  Text: WideString;
  Cell: TVarEC;
  KeyModifiers: Cardinal;
begin
  if Block = nil then Exit;
  if GameplayUiScriptCache = nil then GameplayUiScriptCache := TScriptGICache.Create;
  Entry := GameplayUiScriptCache.GetOrCompile(Block);
  if Entry = nil then Exit;
  Code := Entry.Code;
  Code.LinkAll(SharedScriptVariables, False);
  Code.LinkAll(ScriptFunctionScope, False);
  Code.ScriptFunLinked := True;
  SavedScript := CurrentScript;
  CurrentScript := nil;
  try
    if VirtualKey <> 0 then
    begin
      Cell := Code.LocalVar.GetVarNE('KEY');
      if Cell <> nil then Cell.SetDword(VirtualKey)
      else Code.LocalVar.Add('KEY', vkDword).SetDword(VirtualKey);
      KeyModifiers := Ord(IsVirtualKeyDown(VK_SHIFT)) + Ord(IsVirtualKeyDown(VK_CONTROL)) * 2 + Ord(IsVirtualKeyDown(VK_MENU)) * 4;
      Cell := Code.LocalVar.GetVarNE('KEYMOD');
      if Cell <> nil then Cell.SetDword(KeyModifiers)
      else Code.LocalVar.Add('KEYMOD', vkDword).SetDword(KeyModifiers);
    end;
    Code.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do ;
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      LogScriptCallHistory;
      AppendLogLineThreadSafe('Error while executing GI code:');
      Text := Entry.SourceText;
      if Length(Text) <= 256 then AppendLogLineThreadSafe(AnsiString(Text))
      else AppendLogLineThreadSafe(AnsiString(Copy(Text, 1, 256) + ' ...'));
      raise;
    end;
  end;
  CurrentScript := SavedScript;
end;
{ @end $65A764 }

{ @routine $65AABC ScriptSnap }
procedure ScriptSnap(out Snapshot: TScriptContextSnapshot);
begin
  Snapshot.Script := CurrentScript;
  if CurrentScript <> nil then
  begin
    Snapshot.CurrentShip := CurrentScript.CurrentShip;
    Snapshot.EndState := CurrentScript.InitCode.LocalVar.GetVar('EndState').GetInt <> 0;
  end;
end;
{ @end $65AABC }

{ @routine $65AB28 ScriptUnSnap }
procedure ScriptUnSnap(Snapshot: TScriptContextSnapshot);
begin
  CurrentScript := Snapshot.Script;
  if CurrentScript <> nil then
  begin
    CurrentScript.CurrentShip := Snapshot.CurrentShip;
    CurrentScript.InitCode.LocalVar.GetVar('CurShip').SetDword(Cardinal(Snapshot.CurrentShip));
    CurrentScript.InitCode.LocalVar.GetVar('EndState').SetInt(Ord(Snapshot.EndState));
  end;
end;
{ @end $65AB28 }

{ @routine $65ABC4 TScriptItem_CompileActionCode }
procedure TScriptItem.CompileActionCode;
var
  I: Integer;
  Step: Cardinal;
  Count: Integer;
  Action: Byte;
  SourceText, ActionTypes, StepTypes: WideString;
begin
  ActionCodeInitialized := True;
  if OnActionText[1] = '[' then
  begin
    I := FindTextPosW(']', OnActionText);
    SourceText := CopyWideStringUnchecked(OnActionText, I + 1, Length(OnActionText) - I);
    ActionTypes := CopyWideStringUnchecked(OnActionText, 2, I - 2);
    StepTypes := ExtractDelimitedPartW(ActionTypes, 1, '|');
    ActionTypes := ExtractDelimitedPartW(ActionTypes, 0, '|');
    ActionCode := CompileScriptText(SourceText);
    ActionCode.LinkAll(ScriptFunctionScope, False);
    ActionCode.LinkAll(SharedScriptVariables, False);
    if Script <> nil then ActionCode.LinkAll(Script.InitCode.LocalVar, False);
    ActionCode.ScriptFunLinked := True;
    if ((ActionTypes = '') and (StepTypes = '')) or (ActionTypes = 'Any') then ActionTypeMask := [satOnStep..satOnDeath]
    else if ActionTypes = '' then ActionTypeMask := [satOnStep]
    else
    begin
      if StepTypes <> '' then ActionTypeMask := [satOnStep]
      else ActionTypeMask := [];
      ActionTypes := ',' + ActionTypes + ',';
      for Action := Low(ScriptActionTypeNames) to High(ScriptActionTypeNames) do
        if Pos(',' + ScriptActionTypeNames[Action] + ',', ActionTypes) > 0 then Include(ActionTypeMask, Action);
    end;
    if (StepTypes = '') or (StepTypes = 'Any') then StepTypeMask := [0..11]
    else
    begin
      StepTypeMask := [];
      Count := CountDelimitedPartsW(StepTypes, ',');
      for I := 0 to Count - 1 do
      begin
        Step := ExtractDigitsToIntW(ExtractDelimitedPartW(StepTypes, I, ','));
        if Step in [0..11] then Include(StepTypeMask, Step);
      end;
    end;
  end
  else
  begin
    ActionCode := CompileScriptText(OnActionText);
    ActionTypeMask := [satOnStep..satOnDeath];
    StepTypeMask := [0..11];
  end;
end;
{ @end $65ABC4 }

{ @routine $65AF44 TScriptItem_RunActionCode }
function TScriptItem.RunActionCode(ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
var
  Snapshot: TScriptContextSnapshot;
begin
  Result := Param;
  if (ActionCode <> nil) and not ActionCodeInitialized then
  begin
    ActionCode.Free;
    ActionCode := nil;
  end;
  if OnActionText <> '' then
    try
      if ActionCode = nil then CompileActionCode;
      if not (ActionType in ActionTypeMask) then Exit;
      if (ActionType = satOnStep) and not (Param in StepTypeMask) then Exit;
      if Script <> nil then
      begin
        ScriptSnap(Snapshot);
        Script.PublishCurrentShip(Ship);
        ScriptItemContextStack.Add(Item);
        ScriptItemInfoContextStack.Add(nil);
        ScriptActionTypeStack.Add(Pointer(ActionType));
        ScriptActionObject1Stack.Add(Object1);
        ScriptActionObject2Stack.Add(Object2);
        ScriptActionParamStack.Add(Pointer(Param));
        ScriptActionShipStack.Add(Ship);
        RunScriptCode(OnActionText, ActionCode, Script.InitCode);
        ScriptUnSnap(Snapshot);
        Result := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
        ScriptActionTypeStack.Delete(ScriptActionTypeStack.Count - 1);
        ScriptActionObject1Stack.Delete(ScriptActionObject1Stack.Count - 1);
        ScriptActionObject2Stack.Delete(ScriptActionObject2Stack.Count - 1);
        ScriptActionParamStack.Delete(ScriptActionParamStack.Count - 1);
        ScriptActionShipStack.Delete(ScriptActionShipStack.Count - 1);
        ScriptItemInfoContextStack.Delete(ScriptItemInfoContextStack.Count - 1);
        ScriptItemContextStack.Delete(ScriptItemContextStack.Count - 1);
        Exit;
      end;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        AppendLogLineThreadSafe('Error in script item actcode, item=');
        AppendLogLineThreadSafe(AnsiString(Item.GetDisplayName + ', script name - ' + Name));
        raise;
      end;
    end;
end;
{ @end $65AF44 }

{ @routine $65B30C TScriptShip_RunActionCode }
function TScriptShip.RunActionCode(ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
var
  Snapshot: TScriptContextSnapshot;
begin
  Result := Param;
  if (State <> nil) and (State.OnActionText <> '') then
    if ActionType in State.ActionTypeMask then
      if (ActionType <> satOnStep) or (Param in State.StepTypeMask) then
        try
          ScriptSnap(Snapshot);
          Script.PublishCurrentShip(Ship);
          ScriptItemContextStack.Add(nil);
          ScriptItemInfoContextStack.Add(nil);
          ScriptActionTypeStack.Add(Pointer(ActionType));
          ScriptActionObject1Stack.Add(Object1);
          ScriptActionObject2Stack.Add(Object2);
          ScriptActionParamStack.Add(Pointer(Param));
          ScriptActionShipStack.Add(Ship);
          RunScriptCode(State.OnActionText, State.ActionCode, Script.InitCode);
          ScriptUnSnap(Snapshot);
          Result := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
          ScriptActionTypeStack.Delete(ScriptActionTypeStack.Count - 1);
          ScriptActionObject1Stack.Delete(ScriptActionObject1Stack.Count - 1);
          ScriptActionObject2Stack.Delete(ScriptActionObject2Stack.Count - 1);
          ScriptActionParamStack.Delete(ScriptActionParamStack.Count - 1);
          ScriptActionShipStack.Delete(ScriptActionShipStack.Count - 1);
          ScriptItemInfoContextStack.Delete(ScriptItemInfoContextStack.Count - 1);
          ScriptItemContextStack.Delete(ScriptItemContextStack.Count - 1);
          // Native Exit leaves the compiler's dormant normal SEH unlink.
          Exit;
        except
          on E: Exception do
          begin
            AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
            AppendLogLineThreadSafe('Error in script ship actcode');
            AppendLogLineThreadSafe(AnsiString(State.Name + ', script - ' + Script.ScriptFileName));
            raise;
          end;
        end;
end;
{ @end $65B30C }

{ @routine $65B66C RunItemUseCode }
function RunItemUseCode(Item: TItem; Ship: TShip): Integer;
var
  Binding: TScriptItem;
  SavedScript, Script: TScript;
  Text: WideString;
  ParentCode: TCodeEC;
begin
  Result := 0;
  if Item = nil then Exit;
  ScriptUseItem := Item;
  Binding := Item.ScriptItem as TScriptItem;
  SavedScript := CurrentScript;
  CurrentScript := nil;
  ParentCode := nil;
  if Binding <> nil then Text := Binding.OnUseText
  else Text := '';
  if Text = '' then
    if Item is TUselessItem then Text := (Item as TUselessItem).GetOnUseCodeText
    else if Item is TArtefact then Text := (Item as TArtefact).GetOnUseCodeText;
  if (Text <> '') and (Binding <> nil) and (Binding.Script <> nil) then
  begin
    Script := Binding.Script;
    CurrentScript := Script;
    Script.CurrentShip := Ship;
    Script.InitCode.LocalVar.GetVar('CurShip').SetDword(Cardinal(Ship));
    ParentCode := Script.InitCode;
  end;
  if Text <> '' then
  begin
    ScriptActionParamStack.Add(nil);
    ScriptActionShipStack.Add(Ship);
    if ParentCode <> nil then ExecuteScriptText(Text, ParentCode.LocalVar)
    else ExecuteScriptText(Text, nil);
    Result := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
    ScriptActionParamStack.Delete(ScriptActionParamStack.Count - 1);
    ScriptActionShipStack.Delete(ScriptActionShipStack.Count - 1);
  end;
  CurrentScript := SavedScript;
  ScriptUseItem := nil;
end;
{ @end $65B66C }

{ @routine $65B880 RunItemConfigActionCode }
function RunItemConfigActionCode(Item: TItem; ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
var
  Entry: TScriptCacheUnit;
  Binding: TScriptItem;
  ParentCode: TCodeEC;
  Snapshot: TScriptContextSnapshot;
begin
  Result := Param;
  Entry := nil;
  if Item is TArtefact then Entry := TScriptCacheUnit((Item as TArtefact).GetActionCode);
  if Item is TUselessItem then Entry := TScriptCacheUnit((Item as TUselessItem).GetActionCode);
  if Entry <> nil then
    if ActionType in Entry.ActionTypeMask then
      if (ActionType <> satOnStep) or (Param in Entry.StepTypeMask) then
      begin
        Binding := TScriptItem(Item.ScriptItem);
        ParentCode := nil;
        try
          ScriptItemContextStack.Add(Item);
          ScriptItemInfoContextStack.Add(nil);
          ScriptActionTypeStack.Add(Pointer(ActionType));
          ScriptActionObject1Stack.Add(Object1);
          ScriptActionObject2Stack.Add(Object2);
          ScriptActionParamStack.Add(Pointer(Param));
          ScriptActionShipStack.Add(Ship);
          ScriptSnap(Snapshot);
          if (Binding <> nil) and (Binding.Script <> nil) then
          begin
            Binding.Script.PublishCurrentShip(Ship);
            ParentCode := CurrentScript.InitCode;
          end;
          RunScriptCode(Entry.SourceText, Entry.Code, ParentCode);
          ScriptUnSnap(Snapshot);
          Result := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
          ScriptActionTypeStack.Delete(ScriptActionTypeStack.Count - 1);
          ScriptActionObject1Stack.Delete(ScriptActionObject1Stack.Count - 1);
          ScriptActionObject2Stack.Delete(ScriptActionObject2Stack.Count - 1);
          ScriptActionParamStack.Delete(ScriptActionParamStack.Count - 1);
          ScriptActionShipStack.Delete(ScriptActionShipStack.Count - 1);
          ScriptItemInfoContextStack.Delete(ScriptItemInfoContextStack.Count - 1);
          ScriptItemContextStack.Delete(ScriptItemContextStack.Count - 1);
        except
          on E: Exception do
          begin
            AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
            AppendLogLineThreadSafe('Error in item actcode, item=');
            AppendLogLineThreadSafe(AnsiString(Item.GetDisplayName));
            if Item.ScriptItem <> nil then
              AppendLogLineThreadSafe(AnsiString('script name - ' + TScriptItem(Item.ScriptItem).Name));
            raise;
          end;
        end;
      end;
end;
{ @end $65B880 }

{ @routine $65BC78 RunCustomShipInfoActionCode }
function RunCustomShipInfoActionCode(Info: PCustomShipInfo; ActionType: Byte; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
var
  Config: TBlockParEC;
  Entry: TScriptCacheUnit;
  Snapshot: TScriptContextSnapshot;
begin
  Result := Param;
  Entry := TScriptCacheUnit(Info.ActionCode);
  if not Info.ActionCodeInitialized then
  begin
    Info.ActionCodeInitialized := True;
    Config := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName);
    try
      Entry := GetCachedActionCode(CustomShipInfoScriptCache, Info.TypeName, Config);
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        AppendLogLineThreadSafe(AnsiString('Error in actcode, info=' + Info.TypeName));
        LogScriptCallHistory;
        raise;
      end;
    end;
    Info.ActionCode := Entry;
  end;
  if Entry <> nil then
    if ActionType in Entry.ActionTypeMask then
      if (ActionType <> satOnStep) or (Param in Entry.StepTypeMask) then
      begin
        ScriptItemContextStack.Add(nil);
        ScriptItemInfoContextStack.Add(Info);
        ScriptActionTypeStack.Add(Pointer(ActionType));
        ScriptActionObject1Stack.Add(Object1);
        ScriptActionObject2Stack.Add(Object2);
        ScriptActionParamStack.Add(Pointer(Param));
        ScriptActionShipStack.Add(Ship);
        try
          ScriptSnap(Snapshot);
          RunScriptCode(Entry.SourceText, Entry.Code, nil);
          ScriptUnSnap(Snapshot);
        except
          on E: Exception do
          begin
            AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
            AppendLogLineThreadSafe(AnsiString('Error in actcode, info=' + Info.TypeName));
            LogScriptCallHistory;
            raise;
          end;
        end;
        Result := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
        ScriptActionTypeStack.Delete(ScriptActionTypeStack.Count - 1);
        ScriptActionObject1Stack.Delete(ScriptActionObject1Stack.Count - 1);
        ScriptActionObject2Stack.Delete(ScriptActionObject2Stack.Count - 1);
        ScriptActionParamStack.Delete(ScriptActionParamStack.Count - 1);
        ScriptActionShipStack.Delete(ScriptActionShipStack.Count - 1);
        ScriptItemInfoContextStack.Delete(ScriptItemInfoContextStack.Count - 1);
        ScriptItemContextStack.Delete(ScriptItemContextStack.Count - 1);
      end;
end;
{ @end $65BC78 }

{ @routine $65C114 TScriptItem_FormatDataText }
function TScriptItem.FormatDataText(Text, ColorTag: WideString): WideString;
begin
  Result := Text;
  ReplaceTextToken(Result, '<Data1>', WideString(IntToStr(Data[1])), ColorTag);
  ReplaceTextToken(Result, '<Data2>', WideString(IntToStr(Data[2])), ColorTag);
  ReplaceTextToken(Result, '<Data3>', WideString(IntToStr(Data[3])), ColorTag);
  ReplaceTextToken(Result, '<TextData1>', TextData1, ColorTag);
  ReplaceTextToken(Result, '<TextData2>', TextData2, ColorTag);
  ReplaceTextToken(Result, '<TextData3>', TextData3, ColorTag);
end;
{ @end $65C114 }

{ @routine $65C308 GetScriptContextDescription }
function GetScriptContextDescription: WideString;
var
  Info: PCustomShipInfo;
  Item: TItem;
  Binding: TScriptItem;
begin
  if ScriptItemContextStack.Count > 0 then
  begin
    Info := PCustomShipInfo(ScriptItemInfoContextStack[ScriptItemInfoContextStack.Count - 1]);
    if Info <> nil then
    begin
      Result := Info.TypeName;
      Exit;
    end;
    Item := TItem(ScriptItemContextStack[ScriptItemInfoContextStack.Count - 1]);
    if Item <> nil then
    begin
      Binding := TScriptItem(Item.ScriptItem);
      if Binding <> nil then
      begin
        if Binding.Script <> nil then
          Result := Item.GetDisplayName + ' (' + Binding.Name + ', ' + Binding.Script.ScriptFileName + ')'
        else Result := Item.GetDisplayName + ' (' + Binding.Name + ', unknown script)';
      end
      else Result := Item.GetDisplayName;
      Exit;
    end;
    Result := 'unknown actcode';
  end;
  if CurrentScript <> nil then
  begin
    if CurrentScriptState <> nil then
      Result := CurrentScriptState.Name + ' (' + CurrentScript.ScriptFileName + ')'
    else Result := CurrentScript.ScriptFileName;
  end
  else if ScriptUseItem <> nil then
  begin
    Binding := TScriptItem(ScriptUseItem.ScriptItem);
    if Binding <> nil then
    begin
      if Binding.Script <> nil then
        Result := ScriptUseItem.GetDisplayName + ' (' + Binding.Name + ', ' + Binding.Script.ScriptFileName + ')'
      else Result := ScriptUseItem.GetDisplayName + ' (' + Binding.Name + ', unknown script)';
    end
    else Result := ScriptUseItem.GetDisplayName;
  end
  else Result := 'unknown source';
end;
{ @end $65C308 }

end.
