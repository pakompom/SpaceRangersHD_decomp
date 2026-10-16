unit aScript;

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Ether, EC_Expression, EC_Str, EC_Struct, EC_Thread, Windows, aGalaxy, aGalaxyStruct, aItem, aMyFunction, aPlanet, aShip;

const
  // Serialized PlaceKind IDs, decoded by TScriptPlace.GetPoint ($648D14)
  // and ShipInPlace ($649244). Keep the stored field as a 32-bit integer.
  place_polar = 0;
  place_planet_position = 1;
  place_docked_at_planet = 2;
  place_star_bearing = 3;
  place_item_position = 4;
  place_group_relative = 5;
  place_coordinate_relative = 6;

  // TShip.ApplyScriptStateOrders ($6EF530), state completion ($6EF9E0),
  // and HasScriptControl ($6F1E24) establish these serialized StateKind IDs.
  script_ship_idle = 0;
  script_ship_move_to_place = 1;
  script_ship_follow_group = 2;
  script_ship_jump_to_star = 3;
  script_ship_land_on_planet = 4;
  script_ship_normal_ai = 5;

  item_def_equipment = 0;
  item_def_weapon = 1;
  item_def_goods = 2;
  item_def_artefact = 3;
  item_def_custom = 4;

  AllScriptStepTypes = [0..11];
  ScriptSpawnPlaceKinds = [place_polar, place_planet_position, place_star_bearing, place_group_relative, place_coordinate_relative];

type

  TScriptActionTypeSet = set of TScriptEventKind; // @size $08
  TScriptStepTypeSet = set of 0..11; // @size $02
  TScriptShipTypeMask = set of THullType; // @size 0x02
  TScriptDominatorMasks = array[TDominatorKind] of TDominatorSeriesMask; // TDominatorKind index; TDominatorSeries bits.

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

  TDialogOverride = packed record // @size $10
    DialogName: WideString; // @offset $00
    Priority: Integer; // @offset $04
    Script: TScript; // @offset $08 Borrowed.
    AnswerData: Cardinal; // @offset $0C
  end;
  PScriptPlanetBinding = ^TScriptPlanet;

  PScriptShipRequirement = ^TScriptShipOtb;
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

  TDialogBlock = record // @size $0C
    Text: WideString; // @offset $00
    Script: TScript; // @offset $04 Borrowed owner.
    Mode: Byte; // @offset $08 Zero enables, one disables, two or more suppress matching choices.
  end;

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

    constructor Create; // @addr 0x00648B1C
    destructor Destroy; override; // @addr 0x00648B7C
  end;

  TScriptConstellation = class(TObjectEx) // @size 0x8
  public
    Constellation: TConstellation; // @offset 0x04

    constructor Create; // @addr 0x00648BCC
    destructor Destroy; override; // @addr 0x00648C04
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
    function GetGroup: TScriptGroup; // @addr 0x00648CA0
    function RunActionCode(ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x00652E1C @note "Returns the event parameter after script changes. Object slots can carry event-specific integers."

    constructor Create; // @addr 0x00648C2C
    destructor Destroy; override; // @addr 0x00648C64
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
    TargetValue2: TVarEC; // @offset 0x30  Second coordinate variable for place_coordinate_relative.
    function GetPoint: TPointF; // @addr 0x00648D14
    function GetRandomPoint(Seed: Cardinal): TPointF; // @addr 0x00649120
    function ShipInPlace(Ship: TShip): Boolean; // @addr 0x00649244 @note "place_docked_at_planet requires docking at the bound planet; other kinds require normal space."

    constructor Create; // @addr 0x00648CB4
    destructor Destroy; override; // @addr 0x00648CEC
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
    OwnerId: TOwnerId; // @offset 0x20
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
    procedure CompileActionCode; // @addr 0x00652758 @note "Requires nonempty OnActionText and an empty ActionCode slot."
    function RunActionCode(ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x00652A6C @note "Returns the event parameter after script changes. Object slots can carry event-specific integers."
    function FormatDataText(Text, ColorTag: WideString): WideString; // @addr 0x00653B74

    constructor Create; // @addr 0x0064929C
    destructor Destroy; override; // @addr 0x006492E0
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

    constructor Create; // @addr 0x00649328
    destructor Destroy; override; // @addr 0x00649360
  end;

  TScriptState = class(TObjectEx) // @size 0x4C
  public
    Name: WideString; // @offset 0x04
    StateKind: Integer; // @offset 0x08  script_ship_* serialized state ID.
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

    constructor Create; // @addr 0x00649398
    destructor Destroy; override; // @addr 0x006493E4
  end;

  TScriptDialog = class(TObjectEx) // @size 0xC
  public
    Name: WideString; // @offset 0x04
    Code: TCodeEC; // @offset 0x08

    constructor Create; // @addr 0x0064946C
    destructor Destroy; override; // @addr 0x006494B0
  end;

  TScriptDialogMsg = class(TObjectEx) // @size 0xC
  public
    Name: WideString; // @offset 0x04
    Code: TCodeEC; // @offset 0x08

    constructor Create; // @addr 0x006494E8
    destructor Destroy; override; // @addr 0x0064952C
  end;

  TScriptDialogAnswer = class(TObjectEx) // @size 0x10
  public
    Name: WideString; // @offset 0x04
    AnswerCode: TCodeEC; // @offset 0x08
    ActionCode: TCodeEC; // @offset 0x0C

    constructor Create; // @addr 0x00649564
    destructor Destroy; override; // @addr 0x006495B8
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
    procedure Clear; // @addr 0x00649868 @note "Frees owned entries but retains list and code containers."
    procedure PublishShipContext(Binding: TScriptShip); // @addr 0x00649A80 @note "Changes the global CurrentScript context."
    procedure PublishCurrentShip(Ship: TShip); // @addr 0x00649AF4
    function GetStar(Name: WideString): TScriptStar; // @addr 0x00649B30 @note "Raises when absent."
    function GetPlanetBinding(Name: WideString): PScriptPlanetBinding; // @addr 0x00649C3C @note "Raises when absent."
    function GetItem(Name: WideString): TScriptItem; // @addr 0x00649D84 @note "Raises when absent."
    procedure RunShipState(Binding: TScriptShip); // @addr 0x00649E8C
    procedure RunTurnCode; // @addr 0x0064A0F0
    procedure RunDialogCode; // @addr 0x0064A284
    procedure CallDialog(Index: Integer); // @addr 0x0064A41C
    procedure CallDialogByVariable(Name: WideString); // @addr 0x0064A6D8
    procedure CallDialogMessage(Index: Integer); // @addr 0x0064A7D8
    procedure BuildDialogAnswer(Index: Integer); // @addr 0x0064AA7C
    procedure ExecuteDialogAnswer(Index: Integer); // @addr 0x0064AD34 @note "Index -1 is ignored."
    procedure BindShip(GroupIndex: Integer; Ship: TShip); // @addr 0x0064AFDC @note "The player may have multiple script bindings; ordinary ships have one."
    procedure UnbindShip(Ship: TShip); // @addr 0x0064B060
    procedure ClearShipBindings; // @addr 0x0064B118
    procedure ChangeState(Binding: TScriptShip; StateIndex: Integer); // @addr 0x0064B1C8
    procedure SetGroupRelation(SourceGroup, TargetGroup: Integer; Level: TRelationLevel); // @addr 0x0064B23C @note "Changes source ships' relations to ranger members of the target group."
    procedure SetPlanetRelation(GroupIndex: Integer; Planet: TPlanet; Level: TRelationLevel); // @addr 0x0064B2F0
    function TryBindStars(StarIndex: Integer): Boolean; // @addr 0x0064B358 @note "Recursively assigns remaining stars and their planets; earlier star bindings must already exist."
    function LoadFromBuffer(Buffer: TBufEC; AnchorStar: TStar; FirstPlanet: TPlanet; CreateObjects: Boolean): Boolean; // @addr 0x0064BF80 @note "Accepts script-definition versions 5 through 8."
    function LoadFromFile(FileName: WideString; AnchorStar: TStar; FirstPlanet: TPlanet; CreateObjects: Boolean): Boolean; // @addr 0x0064EEE0
    procedure SaveState(Buffer: TBufEC); // @addr 0x0064F04C @note "Compiled instructions are excluded."
    procedure LoadState(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x0064F738 @note "Requires the original script-definition file. Resolves star, planet and item IDs through Galaxy; ship IDs are deferred."
    procedure BindImportedFunctions; // @addr 0x00650358
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr 0x006505BC @note "Resolves saved ship IDs and restores ship, place, and state bindings after LoadState."

    constructor Create; // @addr 0x00649600
    destructor Destroy; override; // @addr 0x00649720
  end;

  TScriptThread = class(TThreadEC) // @size 0x2C
  public
    constructor Create; // @addr 0x00646E58
    procedure Execute; override; // @addr 0x00646E90 @slot 0x00
  end;

  TScriptCacheUnit = class(TObject) // @size 0x1C
  public
    Name: WideString; // @offset 0x04
    SourceText: WideString; // @offset 0x08
    Code: TCodeEC; // @offset 0x0C  Owned.
    ActionTypeMask: TScriptActionTypeSet; // @offset 0x10  Native 62-bit action-type set.
    StepTypeMask: TScriptStepTypeSet; // @offset 0x18  Native 12-bit step-type set.
    procedure Initialize(Name, SourceText, ActionTypes, StepTypes: WideString); // @addr 0x00651FA0

    constructor Create; // @addr 0x00651F2C
    destructor Destroy; override; // @addr 0x00651F68
  end;

  TScriptCache = class(TObject) // @size 0x8
  public
    Entries: TObjectList; // @offset 0x04  Owns TScriptCacheUnit entries sorted by Name.
    function GetOrCompile(Name: WideString; Config: TBlockParEC): TScriptCacheUnit; // @addr 0x00651D24 @note "Returns nil for absent or empty OnActCode."

    constructor Create; // @addr 0x00651938
    destructor Destroy; override; // @addr 0x006519C0
  end;

  TScriptGICacheUnit = class(TObject) // @size 0x10
  public
    Block: TBlockParEC; // @offset 0x04  Borrowed cache key.
    SourceText: WideString; // @offset 0x08
    Code: TCodeEC; // @offset 0x0C  Owned.
    procedure Initialize(Block: TBlockParEC; SourceText: WideString); // @addr 0x00652274

    constructor Create; // @addr 0x00652200
    destructor Destroy; override; // @addr 0x0065223C
  end;

  // A script-visible notification: none is an unset/reset status, regardless of queue contents.
  TScriptQuestStatus = (quest_status_none, quest_status_queued, quest_status_succeeded, quest_status_failed); // @size 0x04

  TScriptGICache = class(TObject) // @size 0x8
  public
    Entries: TObjectList; // @offset 0x04  Owns entries sorted by Block pointer.
    function GetOrCompile(Block: TBlockParEC): TScriptGICacheUnit; // @addr 0x00651AA4 @note "Returns nil for empty source."

    constructor Create; // @addr 0x0065197C
    destructor Destroy; override; // @addr 0x006519F4
  end;
  PScriptABRequest = ^TScriptABRequest;

  TLibraryHandler = class(TObject) // @size 0x10
  public
    LibraryName: WideString; // @offset 0x04
    ModuleHandle: Cardinal; // @offset 0x08  Owned Win32 module handle.
    DefinitionBlock: TBlockParEC; // @offset 0x0C  Borrowed ScriptLibs.<name> block.
    constructor Create(LibraryName: WideString; ModuleHandle: Cardinal; DefinitionBlock: TBlockParEC); // @addr 0x00650898
    procedure InitFunction(Cell: TVarEC); // @addr 0x0065097C
    procedure InitAllFunctions(Scope: TVarArrayEC); // @addr 0x00650E30

    destructor Destroy; override; // @addr 0x00650924
  end;
  PScriptPBRequest = ^TScriptPBRequest;

  TLibraryCache = class(TObject) // @size 0x8
  public
    Libraries: TObjectList; // @offset 0x04  Owns TLibraryHandler entries sorted by LibraryName.
    function GetLib(Name: WideString): TLibraryHandler; // @addr 0x00651104
    procedure InitFunction(Cell: TVarEC); // @addr 0x006512B0

    constructor Create; // @addr 0x00650F48
    destructor Destroy; override; // @addr 0x00650F8C
  end;
  PScriptVDRequest = ^TScriptVDRequest;

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
  CurrentScript: TScript; // @addr 0x0081B848
  QueuedArcadeBattles: TList; // @addr 0x0081B84C  Owns PScriptABRequest records.
  QueuedPlanetaryBattles: TList; // @addr 0x0081B850  Owns PScriptPBRequest records.
  QueuedTextQuests: TList; // @addr 0x0081B854 // Owns PQueuedTextQuest records.
  QueuedVideos: TList; // @addr 0x0081B858  Owns PScriptVDRequest records.
  ResumingScript: TScript = nil; // @addr 0x0080F704
  StagedArcadeShipScript: TScript = nil; // @addr $80F708
  ScriptArcadeReturnScreenId: Byte = 0; // @addr $80F70C Direct stores in TryShowQueuedArcadeBattle establish ownership.
  ScriptTakeoffRequested: Boolean = False; // @addr 0x0080F710
  StagedArcadeShips: TObjectList; // @addr $81B85C  Owns ships waiting for an arcade request.
  ScriptEndTurnRequested: Boolean = False; // @addr 0x0080F714
  ScriptFunctionScope: TVarArrayEC; // @addr 0x0081B860
  ScriptProcess: TCodeProcessEC; // @addr 0x0081B864
  ScriptDialogOverrides: TObjectList; // @addr 0x0081B868  Record entries are freed explicitly before clearing.
  ScriptLibraryCache: TLibraryCache = nil; // @addr 0x0080F718
  ArtefactScriptCache: TScriptCache = nil; // @addr $80F71C @note "Named artifact action code via TArtefact.GetActionCode."
  ArtefactKindScriptCache: TScriptCache = nil; // @addr $80F720 @note "Item-type artifact action code; item types 8 and 9 use the named artifact cache instead."
  UselessItemScriptCache: TScriptCache = nil; // @addr $80F724
  CustomShipInfoScriptCache: TScriptCache = nil; // @addr $80F728
  GameplayUiScriptCache: TScriptGICache = nil; // @addr 0x0080F72C
  CurrentScriptState: TScriptState = nil; // @addr 0x0080F730
  ScriptDialogInjections: TObjectList; // @addr 0x0081B86C
  ScriptDialogBlocks: TObjectList; // @addr 0x0081B870
  ScriptRequestThread: TScriptThread; // @addr 0x0081B874

procedure LogScriptCallHistory; // @addr 0x00646204
procedure ClearPendingScriptRequests; // @addr 0x006464C0
function HasPendingScriptRequests: Boolean; // @addr 0x006465B4
function TryShowQueuedArcadeBattle: Boolean; // @addr 0x006465F8
function TryShowQueuedTextQuest: Boolean; // @addr 0x00646698
function TryRunQueuedPlanetaryBattle: Boolean; // @addr 0x0064671C
function TryShowQueuedVideo: Boolean; // @addr 0x00646974
function TryDispatchScriptTakeoff: Boolean; // @addr 0x00646B10
function TryDispatchScriptEndTurn: Boolean; // @addr 0x00646B98
function TryDispatchResumingScriptRequest: Boolean; // @addr 0x00646C54 @note "Moves the first request belonging to ResumingScript to its queue's front."
function DispatchPendingScriptRequests: Boolean; // @addr 0x00646DC4
procedure StartScriptRequestThread; // @addr 0x00646E34
procedure CompleteQueuedArcadeBattle(Status: Integer); // @addr 0x00646F58 @note "Requires a nonempty queue. Clears ResumingScript when no requests remain; preserves GABStatus changed by the script."
procedure CompleteQueuedTextQuest(Status: TScriptQuestStatus); // @addr 0x00647024 @note "Requires a nonempty queue. Clears ResumingScript when no requests remain; preserves GQuestStatus changed by the script."
procedure CompleteQueuedPlanetaryBattle(Status: Integer); // @addr 0x006470E8 @note "Requires a nonempty queue. Clears ResumingScript when no requests remain; preserves GRobotStatus changed by the script."
procedure CompleteQueuedVideo(Status: Integer); // @addr 0x006471AC @note "Requires a nonempty queue when a player exists. Clears ResumingScript when no requests remain; preserves GVideoStatus changed by the script."
procedure LogScriptStepCount(ExpressionCount: Integer); // @addr 0x00647280

procedure InitializeScriptEngine; // @addr 0x0064734C
procedure FinalizeScriptEngine; // @addr 0x00647390
procedure RunGlobalScriptsForContext(Star: TStar; RunFrom: Integer); // @addr 0x006473C8
function TryStartScriptByName(AnchorStar: TStar; AnchorPlanet: TPlanet; Name: WideString): Boolean; // @addr 0x0064763C
function TryStartScriptInstanceFromTemplate(AnchorStar: TStar; AnchorPlanet: TPlanet; TemplateIndex: Integer): Boolean; // @addr 0x006476A0
function TryRestartScript(Script: TScript; AnchorStar: TStar; AnchorPlanet: TPlanet): Boolean; // @addr 0x00647760 @note "Replaces and frees Script on success; retains it on failure. Requires an existing Galaxy.Scripts entry."
procedure CompileScriptTemplateCondition(TemplateIndex: Integer); // @addr 0x006478BC
function IsStarProtectedByScript(Star: TStar): Boolean; // @addr 0x00647B08
function ScriptDefinitionBit(Value: Cardinal; BitIndex: Integer): Boolean; // @addr 0x00647B94
function DecodeScriptRaceMask(Value: Cardinal): TOwnerMask; // @addr 0x00647B9C
function DecodeScriptOwnerMask(Value: Cardinal): TOwnerMask; // @addr 0x00647C68 @note "Bit 9 also selects the player's current owner ID."
function DecodeScriptEconomyMask(Value: Cardinal): TPlanetEconomies; // @addr 0x00647DC8
function DecodeScriptGovernmentMask(Value: Cardinal): TPlanetGovernments; // @addr 0x00647E54
function DecodeScriptShipTypeMask(Value: Cardinal): TScriptShipTypeMask; // @addr 0x00647F20
function DecodeScriptDominatorMask(Value: Cardinal; KlingType: TDominatorKind): TDominatorSeriesMask; // @addr 0x00648060
function DecodeScriptItemOwner(Value: Integer): TOwnerId; // @addr 0x00648398 @note "Values outside 0..7 become owner_uninhabited."
function DecodeScriptRelationLevel(Value: Integer): TRelationLevel; // @addr 0x006483E4 @note "Values outside 0..4 become hostile."
function ScriptShipMatchesType(Ship: TShip; ShipTypeMask: TScriptShipTypeMask; StationNames: WideString; DominatorMasks: array of TDominatorSeriesMask): Boolean; // @addr 0x00648414 @note "DominatorMasks requires eight entries indexed by TDominatorKind. StationNames is a comma-separated filter when ship-type bit 8 is set."
function CollectScriptCandidateShips(Star: TStar): TList; // @addr 0x006485C0 @note "Caller owns the list; ship references are borrowed."
function FindScriptGroupCandidate(Candidates: TList; Group: TScriptGroup): TShip; // @addr 0x00648898 @note "Returns the first match or nil; leaves Candidates unchanged."
function GetScriptShipBindingForContext(Ship: TShip; Script: TScript): TScriptShip; // @addr 0x00648AC0 @note "The player may have multiple bindings; ordinary ships have one."
procedure ClearScriptDialogRules; // @addr 0x00650798
procedure ExecuteScriptText(SourceText: WideString; Scope: TVarArrayEC); // @addr 0x0065132C @note "Nil Scope temporarily clears CurrentScript. Compiled code is freed after execution."
function CompileScriptText(SourceText: WideString): TCodeEC; // @addr 0x006515A0 @note "Caller owns the returned code."
procedure RunScriptCode(ContextName: WideString; Code, ParentCode: TCodeEC); // @addr 0x00651704
function GetCachedActionCode(var Cache: TScriptCache; Name: WideString; Config: TBlockParEC): TScriptCacheUnit; // @addr 0x006522D4
procedure ExecuteGameplayUiCode(Block: TBlockParEC; VirtualKey: Cardinal); // @addr 0x00652344 @note "Runs with CurrentScript nil. VirtualKey=0 leaves KEY and KEYMOD unchanged."
procedure ScriptSnap(out Snapshot: TScriptContextSnapshot); // @addr 0x00652660 @note "When CurrentScript is nil, only Snapshot.Script is written."
procedure ScriptUnSnap(Snapshot: TScriptContextSnapshot); // @addr 0x006526BC
function RunItemUseCode(Item: TItem; Ship: TShip): Integer; // @addr 0x0065315C @note "Returns ScriptItemActParam, initially zero."
function RunItemConfigActionCode(Item: TItem; ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x00653344 @note "Uses artifact or useless-item configuration code. Object slots can carry event-specific integers."
function RunCustomShipInfoActionCode(Info: PCustomShipInfo; ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer; // @addr 0x00653708 @note "Returns the event parameter after script changes. Object slots can carry event-specific integers."
function GetScriptContextDescription: WideString; // @addr 0x00653D54

implementation

uses GI_MessageLoop, GI_MessageBox, GI_XviD, MMSystem, Robot, fPanelMain, fShip2, fStarMap, BreakMessageGIException, EC_Cache, EC_CacheBuf, GR_Main, Globals, SysUtils, GlobalsV, aConst, aKling, aPlayer, aRanger, aRuins, aScriptFun, aTranclucator, aWarrior;

{ @routine $646204 LogScriptCallHistory }
procedure LogScriptCallHistory;
var
  I, Position, Count: Integer;
  Cell: TVarEC;
begin
  Count := ScriptCallTraceCount;
  Position := (ScriptCallTracePosition - 1 + 20) mod 20;
  Cell := ScriptCallTrace[Position];
  while (Cell <> nil) and (Cell.ValueKind = value_script_function) do
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
{ @end $646204 }

{ @routine $6464C0 ClearPendingScriptRequests }
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
{ @end $6464C0 }

{ @routine $6465B4 HasPendingScriptRequests }
function HasPendingScriptRequests: Boolean;
begin
  Result := (QueuedArcadeBattles.Count > 0) or (QueuedTextQuests.Count > 0) or
    (QueuedPlanetaryBattles.Count > 0) or (QueuedVideos.Count > 0) or
    ScriptTakeoffRequested or ScriptEndTurnRequested;
end;
{ @end $6465B4 }

{ @routine $6465F8 TryShowQueuedArcadeBattle }
function TryShowQueuedArcadeBattle: Boolean;
var
  Request: PScriptABRequest;
begin
  Result := False;
  if QueuedArcadeBattles.Count > 0 then
  begin
    Request := QueuedArcadeBattles[0];
    ArcadeBattleScreen.SelectedMapName := Request.MapName;
    case CurrentScreenId of
      screen_equipment_shop, screen_government, screen_info, screen_goods_shop:
        if GetPlayer.CurrentPlanet <> nil then ScriptArcadeReturnScreenId := Ord(screen_planet)
        else ScriptArcadeReturnScreenId := Ord(screen_ruins_talk);
    else ScriptArcadeReturnScreenId := Ord(CurrentScreenId);
    end;
    RequestedScreenId := screen_arcade_battle;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
    Result := True;
  end;
end;
{ @end $6465F8 }

{ @routine $646698 TryShowQueuedTextQuest }
function TryShowQueuedTextQuest: Boolean;
begin
  Result := False;
  if QueuedTextQuests.Count > 0 then
  begin
    StandaloneQuestMode := False;
    case CurrentScreenId of
      screen_equipment_shop, screen_government, screen_info, screen_goods_shop:
        if GetPlayer.CurrentPlanet <> nil then QuestReturnScreenId := screen_planet
        else QuestReturnScreenId := screen_ruins_talk;
    else QuestReturnScreenId := CurrentScreenId;
    end;
    RequestedScreenId := screen_text_quest;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
    Result := True;
  end;
end;
{ @end $646698 }

{ @routine $64671C TryRunQueuedPlanetaryBattle }
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
    Request := QueuedPlanetaryBattles[0];
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
      if ShowMessageBoxGI(TMessageLoopGI(RegisteredScreens[CurrentScreenId]), LocalizedColorText('FormGov.BattlePlanetQuestCrashed'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        Status := 3
      else raise Exception.Create('Error in Matrix.dll');
    end;
    if Status = 0 then Exit;
    if Status = 1 then
    begin
      RequestedScreenId := screen_main_menu;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
      Exit;
    end;
    if Status = 3 then Status := 2
    else Status := 3;
    RequestedScreenId := CurrentScreenId;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
    CompleteQueuedPlanetaryBattle(Status);
    Result := True;
  end;
end;
{ @end $64671C }

{ @routine $646974 TryShowQueuedVideo }
function TryShowQueuedVideo: Boolean;
var
  Request: PScriptVDRequest;
  Video: TxvidGI;
begin
  Result := False;
  if QueuedVideos.Count > 0 then
  begin
    Request := QueuedVideos[0];
    if not SkipVideo and (RegisteredScreens[CurrentScreenId] = RuinsTalkScreen) then
    begin
      Video := TMessageLoopGI(RegisteredScreens[CurrentScreenId]).GetByName('Film') as TxvidGI;
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
        if RuinsTalkScreen.ScriptVideoTimer <> 0 then
        begin
          RuinsTalkScreen.CancelCallbackTimer(RuinsTalkScreen.ScriptVideoTimer);
          RuinsTalkScreen.ScriptVideoTimer := 0;
        end;
        RuinsTalkScreen.ScriptVideoTimer := RuinsTalkScreen.ScheduleCallbackTimer(5, 5, RuinsTalkScreen.AdvanceScriptVideo);
      end
      else CompleteQueuedVideo(3);
    end
    else CompleteQueuedVideo(3);
    Result := True;
  end;
end;
{ @end $646974 }

{ @routine $646B10 TryDispatchScriptTakeoff }
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
      if GetPlayer.Order = order_takeoff then
      begin
        HangarScreen.TryTakeOff;
        ScriptEndTurnRequested := False;
        TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
        Result := True;
      end;
    end;
  end;
end;
{ @end $646B10 }

{ @routine $646B98 TryDispatchScriptEndTurn }
function TryDispatchScriptEndTurn: Boolean;
begin
  Result := False;
  if ScriptEndTurnRequested then
  begin
    ScriptEndTurnRequested := False;
    if CurrentScreenId = screen_ruins_talk then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.EndTurnClicked(nil)
    else if CurrentScreenId = screen_planet then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.EndTurnClicked(nil)
    else if CurrentScreenId = screen_uninhabited_planet then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.EndTurnClicked(nil)
    else if CurrentScreenId = screen_star_map then
      TfStarMap(RegisteredScreens[CurrentScreenId]).EndTurnAfterOpen := True;
    Result := True;
  end;
end;
{ @end $646B98 }

{ @routine $646C54 TryDispatchResumingScriptRequest }
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
    Video := QueuedVideos[I];
    if Video.Script <> ResumingScript then Continue;
    if I > 0 then
    begin
      QueuedVideos.Delete(I);
      QueuedVideos.Insert(0, Video);
    end;
    TryShowQueuedVideo;
    Result := True;
    Exit;
  end;
  for I := 0 to QueuedTextQuests.Count - 1 do
  begin
    Quest := QueuedTextQuests[I];
    if Quest.Script <> ResumingScript then Continue;
    if I > 0 then
    begin
      QueuedTextQuests.Delete(I);
      QueuedTextQuests.Insert(0, Quest);
    end;
    TryShowQueuedTextQuest;
    Result := True;
    Exit;
  end;
  for I := 0 to QueuedArcadeBattles.Count - 1 do
  begin
    Arcade := QueuedArcadeBattles[I];
    if Arcade.Script <> ResumingScript then Continue;
    if I > 0 then
    begin
      QueuedArcadeBattles.Delete(I);
      QueuedArcadeBattles.Insert(0, Arcade);
    end;
    TryShowQueuedArcadeBattle;
    Result := True;
    Exit;
  end;
  for I := 0 to QueuedPlanetaryBattles.Count - 1 do
  begin
    Planetary := QueuedPlanetaryBattles[I];
    if Planetary.Script <> ResumingScript then Continue;
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
{ @end $646C54 }

{ @routine $646DC4 DispatchPendingScriptRequests }
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
{ @end $646DC4 }

{ @routine $646E34 StartScriptRequestThread }
procedure StartScriptRequestThread;
begin
  if ScriptRequestThread <> nil then
    if not ScriptRequestThread.IsRunning then ScriptRequestThread.Start;
end;
{ @end $646E34 }

{ @routine $646E58 TScriptThread_Create }
constructor TScriptThread.Create;
begin
  inherited Create;
end;
{ @end $646E58 }

{ @routine $646E90 TScriptThread_Execute }
procedure TScriptThread.Execute;
begin
  if (TurnCalculationThread <> nil) and TurnCalculationThread.IsRunning then
    TurnCalculationThread.WaitForIdle(INFINITE);
  if HasPendingScriptRequests then
  begin
    if CurrentScreenId = screen_ship then
    begin
      ShipReturnScreenId := screen_star_map;
      TfShip2(RegisteredScreens[CurrentScreenId]).CloseClicked(nil);
      Exit;
    end;
    if GetPlayer.DockedTo <> nil then RequestedScreenId := screen_ruins_talk
    else if GetPlayer.CurrentPlanet <> nil then
    begin
      if GetPlayer.CurrentPlanet.OwnerId = owner_uninhabited then RequestedScreenId := screen_uninhabited_planet
      else RequestedScreenId := screen_planet;
    end
    else RequestedScreenId := screen_star_map;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $646E90 }

{ @routine $646F58 CompleteQueuedArcadeBattle }
procedure CompleteQueuedArcadeBattle(Status: Integer);
var
  Request: PScriptABRequest;
begin
  Request := QueuedArcadeBattles[0];
  QueuedArcadeBattles.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.NamedItems['GABStatus'].AsInteger := Status;
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.NamedItems['GABStatus'].AsInteger = Status then
      Request.Script.InitCode.LocalVar.NamedItems['GABStatus'].AsInteger := 0;
  end;
  Request.Ships.Clear;
  Request.Ships.Free;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $646F58 }

{ @routine $647024 CompleteQueuedTextQuest }
procedure CompleteQueuedTextQuest(Status: TScriptQuestStatus);
var
  Request: PQueuedTextQuest;
begin
  Request := QueuedTextQuests[0];
  QueuedTextQuests.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.NamedItems['GQuestStatus'].AsInteger := Integer(Status);
    Request.Script.RunTurnCode;
    if TScriptQuestStatus(Request.Script.InitCode.LocalVar.NamedItems['GQuestStatus'].AsInteger) = Status then
      Request.Script.InitCode.LocalVar.NamedItems['GQuestStatus'].AsInteger := Ord(quest_status_none);
  end;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $647024 }

{ @routine $6470E8 CompleteQueuedPlanetaryBattle }
procedure CompleteQueuedPlanetaryBattle(Status: Integer);
var
  Request: PScriptPBRequest;
begin
  Request := QueuedPlanetaryBattles[0];
  QueuedPlanetaryBattles.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.NamedItems['GRobotStatus'].AsInteger := Status;
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.NamedItems['GRobotStatus'].AsInteger = Status then
      Request.Script.InitCode.LocalVar.NamedItems['GRobotStatus'].AsInteger := 0;
  end;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $6470E8 }

{ @routine $6471AC CompleteQueuedVideo }
procedure CompleteQueuedVideo(Status: Integer);
var
  Request: PScriptVDRequest;
begin
  if GetPlayer = nil then Exit;
  Request := QueuedVideos[0];
  QueuedVideos.Delete(0);
  ResumingScript := Request.Script;
  if Request.Script <> nil then
  begin
    Request.Script.InitCode.LocalVar.NamedItems['GVideoStatus'].AsInteger := Status;
    Request.Script.RunTurnCode;
    if Request.Script.InitCode.LocalVar.NamedItems['GVideoStatus'].AsInteger = Status then
      Request.Script.InitCode.LocalVar.NamedItems['GVideoStatus'].AsInteger := 0;
  end;
  Dispose(Request);
  if not HasPendingScriptRequests then ResumingScript := nil;
end;
{ @end $6471AC }

{ @routine $647280 LogScriptStepCount }
procedure LogScriptStepCount(ExpressionCount: Integer);
begin
  AppendLogLineThreadSafe(AnsiString(GetScriptContextDescription + ' code expressions count ' + IntToWideString(ExpressionCount)));
  if ExpressionCount > 200000 then LogScriptCallHistory;
end;
{ @end $647280 }

{ @routine $64734C InitializeScriptEngine }
procedure InitializeScriptEngine;
begin
  ScriptProcess := TCodeProcessEC.Create;
  CurrentScript := nil;
  ScriptFunctionScope := TVarArrayEC.Create;
  InitializeScriptBuiltinsAndConstants(ScriptFunctionScope);
  SetScriptStepCallback(LogScriptStepCount, 100000);
end;
{ @end $64734C }

{ @routine $647390 FinalizeScriptEngine }
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
{ @end $647390 }

{ @routine $6473C8 RunGlobalScriptsForContext }
procedure RunGlobalScriptsForContext(Star: TStar; RunFrom: Integer);
var
  Template: TScriptTemplUnit;
  Candidates: TList;
  I: Integer;
begin
  SharedScriptVariables.NamedItems['GRunFrom'].AsInteger := RunFrom;
  SharedScriptVariables.NamedItems['GRunStar'].AsDword := Cardinal(Star);
  Candidates := TList.Create;
  CollectInactiveScriptTemplates(Candidates);
  for I := 0 to Candidates.Count - 1 do
  begin
    Template := Candidates[I];
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
{ @end $6473C8 }

{ @routine $64763C TryStartScriptByName }
function TryStartScriptByName(AnchorStar: TStar; AnchorPlanet: TPlanet; Name: WideString): Boolean;
var
  Index: Integer;
begin
  Index := FindScriptTemplateIndex(Name);
  if Index < 0 then Result := False
  else Result := TryStartScriptInstanceFromTemplate(AnchorStar, AnchorPlanet, Index);
end;
{ @end $64763C }

{ @routine $6476A0 TryStartScriptInstanceFromTemplate }
function TryStartScriptInstanceFromTemplate(AnchorStar: TStar; AnchorPlanet: TPlanet; TemplateIndex: Integer): Boolean;
var
  Template: TScriptTemplUnit;
  Script: TScript;
  Index: Integer;
begin
  Template := ScriptTemplates[TemplateIndex];
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
{ @end $6476A0 }

{ @routine $647760 TryRestartScript }
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
  Template := ScriptTemplates[Index];
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
      if (Message <> nil) and (Message.Kind = message_quest_active) then
      begin
        Message.Kind := message_quest_cancelled;
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
{ @end $647760 }

{ @routine $6478BC CompileScriptTemplateCondition }
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
  Template := ScriptTemplates[TemplateIndex];
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
    ErrorText := Template.ConditionCode.Compile(Analyzer, nil, nil, nil, nil);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('ScriptFirstLoad.Compiler. Error=' + ErrorText);
    Template.ConditionCode.LocalVar.Add('GScriptName', value_string).AsString := Template.Name;
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;
{ @end $6478BC }

{ @routine $647B08 IsStarProtectedByScript }
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
    Script := Galaxy.Scripts[I];
    for J := 0 to Script.Stars.Count - 1 do
    begin
      Binding := Script.Stars[J];
      if Binding.ProtectStar and (Binding.Star = Star) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
  Result := False;
end;
{ @end $647B08 }

{ @routine $647B94 ScriptDefinitionBit }
function ScriptDefinitionBit(Value: Cardinal; BitIndex: Integer): Boolean;
begin
  Result := Boolean((Value shr BitIndex) and 1);
end;
{ @end $647B94 }

{ @routine $647B9C DecodeScriptRaceMask }
function DecodeScriptRaceMask(Value: Cardinal): TOwnerMask;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [owner_maloc..owner_gaal];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [owner_maloc];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [owner_peleng];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [owner_human];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [owner_feyan];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [owner_gaal];
end;
{ @end $647B9C }

{ @routine $647C68 DecodeScriptOwnerMask }
function DecodeScriptOwnerMask(Value: Cardinal): TOwnerMask;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [owner_maloc..owner_pirate];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [owner_maloc];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [owner_peleng];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [owner_human];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [owner_feyan];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [owner_gaal];
  if ScriptDefinitionBit(Value, 6) then Result := Result + [owner_dominator];
  if ScriptDefinitionBit(Value, 7) then Result := Result + [owner_uninhabited];
  if ScriptDefinitionBit(Value, 8) then Result := Result + [owner_pirate];
  if ScriptDefinitionBit(Value, 9) and (GetPlayer <> nil) then Result := Result + [GetPlayer.OwnerId];
end;
{ @end $647C68 }

{ @routine $647DC8 DecodeScriptEconomyMask }
function DecodeScriptEconomyMask(Value: Cardinal): TPlanetEconomies;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [economy_agricultural..economy_industrial];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [economy_agricultural];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [economy_industrial];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [economy_mixed];
end;
{ @end $647DC8 }

{ @routine $647E54 DecodeScriptGovernmentMask }
function DecodeScriptGovernmentMask(Value: Cardinal): TPlanetGovernments;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [government_anarchy..government_democracy];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [government_anarchy];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [government_dictatorship];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [government_monarchy];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [government_republic];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [government_democracy];
end;
{ @end $647E54 }

{ @routine $647F20 DecodeScriptShipTypeMask }
function DecodeScriptShipTypeMask(Value: Cardinal): TScriptShipTypeMask;
var
  I: Integer;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [hull_ranger..hull_station];
    Exit;
  end;
  Result := [];
  if ScriptDefinitionBit(Value, 1) then Result := Result + [hull_ranger];
  if ScriptDefinitionBit(Value, 2) then Result := Result + [hull_warrior];
  if ScriptDefinitionBit(Value, 3) then Result := Result + [hull_pirate];
  if ScriptDefinitionBit(Value, 4) then Result := Result + [hull_transport];
  if ScriptDefinitionBit(Value, 5) then Result := Result + [hull_liner];
  if ScriptDefinitionBit(Value, 6) then Result := Result + [hull_diplomat];
  if ScriptDefinitionBit(Value, 25) then Result := Result + [hull_tranclucator];
  for I := 7 to 24 do
    if ScriptDefinitionBit(Value, I) then
    begin
      Result := Result + [hull_dominator];
      Break;
    end;
end;
{ @end $647F20 }

{ @routine $648060 DecodeScriptDominatorMask }
function DecodeScriptDominatorMask(Value: Cardinal; KlingType: TDominatorKind): TDominatorSeriesMask;
begin
  if not ScriptDefinitionBit(Value, 0) then
  begin
    Result := [series_blazer..series_terron];
    Exit;
  end;
  Result := [];
  case KlingType of
    dominator_boss:
      begin
        if ScriptDefinitionBit(Value, 7) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 13) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 19) then Result := Result + [series_terron];
      end;
    dominator_equantor:
      begin
        if ScriptDefinitionBit(Value, 8) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 14) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 20) then Result := Result + [series_terron];
      end;
    dominator_urgant:
      begin
        if ScriptDefinitionBit(Value, 9) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 15) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 21) then Result := Result + [series_terron];
      end;
    dominator_smersh:
      begin
        if ScriptDefinitionBit(Value, 10) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 16) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 22) then Result := Result + [series_terron];
      end;
    dominator_menoc:
      begin
        if ScriptDefinitionBit(Value, 11) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 17) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 23) then Result := Result + [series_terron];
      end;
    dominator_shtip:
      begin
        if ScriptDefinitionBit(Value, 12) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 18) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 24) then Result := Result + [series_terron];
      end;
    dominator_bertor:
      begin
        if ScriptDefinitionBit(Value, 26) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 28) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 30) then Result := Result + [series_terron];
      end;
    dominator_klig:
      begin
        if ScriptDefinitionBit(Value, 27) then Result := Result + [series_blazer];
        if ScriptDefinitionBit(Value, 29) then Result := Result + [series_keller];
        if ScriptDefinitionBit(Value, 31) then Result := Result + [series_terron];
      end;
  end;
end;
{ @end $648060 }

{ @routine $648398 DecodeScriptItemOwner }
function DecodeScriptItemOwner(Value: Integer): TOwnerId;
begin
  if Value = 0 then Result := owner_maloc
  else if Value = 1 then Result := owner_peleng
  else if Value = 2 then Result := owner_human
  else if Value = 3 then Result := owner_feyan
  else if Value = 4 then Result := owner_gaal
  else if Value = 5 then Result := owner_dominator
  else if Value = 6 then Result := owner_uninhabited
  else if Value = 7 then Result := owner_pirate
  else Result := owner_uninhabited;
end;
{ @end $648398 }

{ @routine $6483E4 DecodeScriptRelationLevel }
function DecodeScriptRelationLevel(Value: Integer): TRelationLevel;
begin
  if Value = 0 then Result := relation_level_hostile
  else if Value = 1 then Result := relation_level_bad
  else if Value = 2 then Result := relation_level_normal
  else if Value = 3 then Result := relation_level_good
  else if Value = 4 then Result := relation_level_excellent
  else Result := relation_level_hostile;
end;
{ @end $6483E4 }

{ @routine $648414 ScriptShipMatchesType }
function ScriptShipMatchesType(Ship: TShip; ShipTypeMask: TScriptShipTypeMask; StationNames: WideString; DominatorMasks: array of TDominatorSeriesMask): Boolean;
var
  Name: WideString;
  I, Count: Integer;
begin
  Result := False;
  if not (ShipToHullType(Ship) in ShipTypeMask) then Exit;
  if (Ship is TRuins) and (hull_station in ShipTypeMask) then
  begin
    Name := '';
    if not (Ship.TypeId in [station_ranger_center..station_custom]) then Exit;
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
    if not ((Ship as TKling).DominatorSeries in DominatorMasks[Ord((Ship as TKling).KlingType)]) then Exit;
  Result := True;
end;
{ @end $648414 }

{ @routine $6485C0 CollectScriptCandidateShips }
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
    Ship := Star.Ships[I];
    if Ship.LiberationGroup <> nil then Continue;
    Strict := (GetPlayer <> Ship) and (not (Ship is TKling) or ((Ship as TKling).KlingType <> dominator_boss));
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
        OtherShip := Star.Ships[J];
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
    Planet := Star.Planets[K];
    ShipCount := Planet.Warriors.Count;
    for I := 0 to ShipCount - 1 do
    begin
      Ship := Planet.Warriors[I];
      if Ship.ScriptShip <> nil then Continue;
      if Ship.AbsoluteScriptOrder > 0 then Continue;
      if Candidates.IndexOf(Ship) >= 0 then Continue;
      if Ship.GetHull.HullPoints < Ship.GetHull.Weight div 2 then Continue;
      Candidates.Add(Ship);
    end;
  end;
  Result := Candidates;
end;
{ @end $6485C0 }

{ @routine $648898 FindScriptGroupCandidate }
function FindScriptGroupCandidate(Candidates: TList; Group: TScriptGroup): TShip;
var
  I: Integer;
  Ship: TShip;
  Point: TPointF;
  DistanceSquared: Single;
begin
  for I := 0 to Candidates.Count - 1 do
  begin
    Ship := Candidates[I];
    if Ship.LiberationGroup <> nil then Continue;
    if not (Ship.OwnerId in Group.OwnerMask) then Continue;
    if not ScriptShipMatchesType(Ship, Group.ShipTypeMask, Group.StationNames, Group.DominatorMasks) then Continue;
    if Ship = GetPlayer then Continue;
    if (Ship <> BlazerShip) and (Ship <> KellerShip) and (Ship <> TerronShip) and
      ((Ship.Speed < Group.MinSpeed) or (Ship.Speed > Group.MaxSpeed)) then Continue;
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
      if (TRanger(Ship).CareerStatus[career_trader] < Group.MinTraderStatus) or
        (TRanger(Ship).CareerStatus[career_trader] > Group.MaxTraderStatus) then Continue;
      if (TRanger(Ship).CareerStatus[career_warrior] < Group.MinWarriorStatus) or
        (TRanger(Ship).CareerStatus[career_warrior] > Group.MaxWarriorStatus) then Continue;
      if (TRanger(Ship).CareerStatus[career_pirate] < Group.MinPirateStatus) or
        (TRanger(Ship).CareerStatus[career_pirate] > Group.MaxPirateStatus) then Continue;
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
{ @end $648898 }

{ @routine $648AC0 GetScriptShipBindingForContext }
function GetScriptShipBindingForContext(Ship: TShip; Script: TScript): TScriptShip;
var
  I: Integer;
begin
  Result := nil;
  if Ship is TPlayer then
  begin
    for I := 0 to TPlayer(Ship).ScriptShipBindings.Count - 1 do
    begin
      Result := TPlayer(Ship).ScriptShipBindings[I];
      if Result.Script = Script then Break;
      Result := nil;
    end;
  end
  else Result := TScriptShip(Ship.ScriptShip);
end;
{ @end $648AC0 }

{ @routine $648B1C TScriptStar_Create }
constructor TScriptStar.Create;
begin
  inherited Create;
  Constraints := nil;
  Planets := nil;
  ShipRequirements := nil;
end;
{ @end $648B1C }

{ @routine $648B7C TScriptStar_Destroy }
destructor TScriptStar.Destroy;
begin
  ShipRequirements := nil;
  Planets := nil;
  Constraints := nil;
  inherited Destroy;
end;
{ @end $648B7C }

{ @routine $648BCC TScriptConstellation_Create }
constructor TScriptConstellation.Create;
begin
  inherited Create;
end;
{ @end $648BCC }

{ @routine $648C04 TScriptConstellation_Destroy }
destructor TScriptConstellation.Destroy;
begin
  inherited Destroy;
end;
{ @end $648C04 }

{ @routine $648C2C TScriptShip_Create }
constructor TScriptShip.Create;
begin
  inherited Create;
end;
{ @end $648C2C }

{ @routine $648C64 TScriptShip_Destroy }
destructor TScriptShip.Destroy;
begin
  if Ship <> nil then
  begin
    Ship.ScriptShip := nil;
    Ship := nil;
  end;
  inherited Destroy;
end;
{ @end $648C64 }

{ @routine $648CA0 TScriptShip_GetGroup }
function TScriptShip.GetGroup: TScriptGroup;
begin
  Result := Script.Groups[GroupIndex];
end;
{ @end $648CA0 }

{ @routine $648CB4 TScriptPlace_Create }
constructor TScriptPlace.Create;
begin
  inherited Create;
end;
{ @end $648CB4 }

{ @routine $648CEC TScriptPlace_Destroy }
destructor TScriptPlace.Destroy;
begin
  inherited Destroy;
end;
{ @end $648CEC }

{ @routine $648D14 TScriptPlace_GetPoint }
function TScriptPlace.GetPoint: TPointF;
var
  Distance, Angle: Single;
  I, Count: Integer;
  Binding: TScriptShip;
  Center: TPointF;
begin
  if PlaceKind = place_polar then
  begin
    Angle := HeadingDegreesToRadians(AngleOffset);
    Distance := OriginStar.MapDiameter / 2 * DistanceScale;
    Result.X := System.Sin(Angle) * Distance;
    Result.Y := System.Cos(Angle) * -Distance;
  end
  else if PlaceKind = place_planet_position then Result := TPlanet(TargetValue).GetPosition
  else if PlaceKind = place_docked_at_planet then Result := MakePointF(0, 0)
  else if PlaceKind = place_star_bearing then
  begin
    Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(OriginStar.Position, TStar(TargetValue).Position) + AngleOffset));
    Distance := OriginStar.MapDiameter / 2 * DistanceScale;
    Result.X := System.Sin(Angle) * Distance;
    Result.Y := System.Cos(Angle) * -Distance;
  end
  else if PlaceKind = place_item_position then
  begin
    if TScriptItem(TargetValue).Item = nil then Result := MakePointF(0, 0)
    else Result := TScriptItem(TargetValue).Item.Position;
  end
  else if PlaceKind = place_group_relative then
  begin
    Count := 0;
    Center := MakePointF(0, 0);
    for I := 0 to Script.Ships.Count - 1 do
    begin
      Binding := Script.Ships[I];
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
  else if PlaceKind = place_coordinate_relative then
  begin
    Center := MakePointF(TVarEC(TargetValue).AsFloat, TargetValue2.AsFloat);
    Angle := HeadingDegreesToRadians(WrapHeadingDegrees(PointBearingDegrees(Center, MakePointF(0, 0)) + AngleOffset));
    Distance := OriginStar.MapDiameter / 2 * DistanceScale;
    Result.X := System.Sin(Angle) * Distance + Center.X;
    Result.Y := Center.Y - System.Cos(Angle) * Distance;
  end;
  if PlaceKind in [place_item_position, place_group_relative] then
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
{ @end $648D14 }

{ @routine $649120 TScriptPlace_GetRandomPoint }
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
    if (PlaceKind in [place_item_position, place_group_relative]) and (Result.X * Result.X + Result.Y * Result.Y < 2 * OriginStar.SafeRadius * OriginStar.SafeRadius) then
    begin
      Result.X := Result.X - System.Sin(Angle) * (Radius * 1.8);
      Result.Y := Result.Y - -System.Cos(Angle) * (Radius * 1.8);
    end;
  end;
end;
{ @end $649120 }

{ @routine $649244 TScriptPlace_ShipInPlace }
function TScriptPlace.ShipInPlace(Ship: TShip): Boolean;
begin
  if PlaceKind = place_docked_at_planet then Result := Ship.CurrentPlanet = TPlanet(TargetValue)
  else if not Ship.InNormalSpace then Result := False
  else Result := PointDistanceSquared(GetPoint, Ship.Position) <= Sqr(Radius);
end;
{ @end $649244 }

{ @routine $64929C TScriptItem_Create }
constructor TScriptItem.Create;
begin
  inherited Create;
  ActionCode := nil;
  ActionCodeInitialized := False;
  Script := nil;
end;
{ @end $64929C }

{ @routine $6492E0 TScriptItem_Destroy }
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
{ @end $6492E0 }

{ @routine $649328 TScriptGroup_Create }
constructor TScriptGroup.Create;
begin
  inherited Create;
end;
{ @end $649328 }

{ @routine $649360 TScriptGroup_Destroy }
destructor TScriptGroup.Destroy;
begin
  if Ships <> nil then
  begin
    Ships.Free;
    Ships := nil;
  end;
  inherited Destroy;
end;
{ @end $649360 }

{ @routine $649398 TScriptState_Create }
constructor TScriptState.Create;
begin
  inherited Create;
  StateCode := TCodeEC.Create;
  ActionCode := nil;
end;
{ @end $649398 }

{ @routine $6493E4 TScriptState_Destroy }
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
{ @end $6493E4 }

{ @routine $64946C TScriptDialog_Create }
constructor TScriptDialog.Create;
begin
  inherited Create;
  Code := TCodeEC.Create;
end;
{ @end $64946C }

{ @routine $6494B0 TScriptDialog_Destroy }
destructor TScriptDialog.Destroy;
begin
  if Code <> nil then
  begin
    Code.Free;
    Code := nil;
  end;
  inherited Destroy;
end;
{ @end $6494B0 }

{ @routine $6494E8 TScriptDialogMsg_Create }
constructor TScriptDialogMsg.Create;
begin
  inherited Create;
  Code := TCodeEC.Create;
end;
{ @end $6494E8 }

{ @routine $64952C TScriptDialogMsg_Destroy }
destructor TScriptDialogMsg.Destroy;
begin
  if Code <> nil then
  begin
    Code.Free;
    Code := nil;
  end;
  inherited Destroy;
end;
{ @end $64952C }

{ @routine $649564 TScriptDialogAnswer_Create }
constructor TScriptDialogAnswer.Create;
begin
  inherited Create;
  AnswerCode := TCodeEC.Create;
  ActionCode := TCodeEC.Create;
end;
{ @end $649564 }

{ @routine $6495B8 TScriptDialogAnswer_Destroy }
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
{ @end $6495B8 }

{ @routine $649600 TScript_Create }
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
{ @end $649600 }

{ @routine $649720 TScript_Destroy }
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
{ @end $649720 }

{ @routine $649868 TScript_Clear }
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
      State := States[I];
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
      Binding := Ships[I];
      Binding.Free;
    end;
    Ships.Clear;
  end;
  if Dialogs <> nil then
  begin
    for I := 0 to Dialogs.Count - 1 do
    begin
      Dialog := Dialogs[I];
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
{ @end $649868 }

{ @routine $649A80 TScript_PublishShipContext }
procedure TScript.PublishShipContext(Binding: TScriptShip);
begin
  CurrentShip := Binding.Ship;
  CurrentScript := Self;
  InitCode.LocalVar.NamedItems['EndState'].AsInteger := Ord(Binding.EndState);
  InitCode.LocalVar.NamedItems['CurShip'].AsDword := Cardinal(CurrentShip);
end;
{ @end $649A80 }

{ @routine $649AF4 TScript_PublishCurrentShip }
procedure TScript.PublishCurrentShip(Ship: TShip);
begin
  CurrentShip := Ship;
  CurrentScript := Self;
  InitCode.LocalVar.NamedItems['CurShip'].AsDword := Cardinal(CurrentShip);
end;
{ @end $649AF4 }

{ @routine $649B30 TScript_GetStar }
function TScript.GetStar(Name: WideString): TScriptStar;
var
  I, Count: Integer;
  Star: TScriptStar;
begin
  Count := Stars.Count;
  for I := 0 to Count - 1 do
  begin
    Star := Stars[I];
    if Name = Star.Name then
    begin
      Result := Star;
      Exit;
    end;
  end;
  raise Exception.Create(AnsiString('Error.Script. Not found star =' + Name));
end;
{ @end $649B30 }

{ @routine $649C3C TScript_GetPlanetBinding }
function TScript.GetPlanetBinding(Name: WideString): PScriptPlanetBinding;
var
  I, Count, J: Integer;
  Star: TScriptStar;
begin
  Count := Stars.Count;
  for I := 0 to Count - 1 do
  begin
    Star := Stars[I];
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
{ @end $649C3C }

{ @routine $649D84 TScript_GetItem }
function TScript.GetItem(Name: WideString): TScriptItem;
var
  Item: TScriptItem;
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
  begin
    Item := Items[I];
    if Item.Name = Name then
    begin
      Result := Item;
      Exit;
    end;
  end;
  raise Exception.Create(AnsiString('Error.Script. Not found item =' + Name));
end;
{ @end $649D84 }

{ @routine $649E8C TScript_RunShipState }
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
{ @end $649E8C }

{ @routine $64A0F0 TScript_RunTurnCode }
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
{ @end $64A0F0 }

{ @routine $64A284 TScript_RunDialogCode }
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
{ @end $64A284 }

{ @routine $64A41C TScript_CallDialog }
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
{ @end $64A41C }

{ @routine $64A6D8 TScript_CallDialogByVariable }
procedure TScript.CallDialogByVariable(Name: WideString);
var
  Cell: TVarEC;
begin
  Cell := InitCode.LocalVar.GetVarNE(Name);
  if Cell = nil then raise Exception.Create(AnsiString('Dialog ' + Name + ' not found in script ' + ScriptFileName));
  CallDialog(Cell.AsInteger);
end;
{ @end $64A6D8 }

{ @routine $64A7D8 TScript_CallDialogMessage }
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
{ @end $64A7D8 }

{ @routine $64AA7C TScript_BuildDialogAnswer }
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
{ @end $64AA7C }

{ @routine $64AD34 TScript_ExecuteDialogAnswer }
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
{ @end $64AD34 }

{ @routine $64AFDC TScript_BindShip }
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
  if (Ship is TWarrior) then
    if (Ship.CurrentStar.Ships.IndexOf(Ship) = -1) then
    Ship.CurrentStar.Ships.Add(Ship);
end;
{ @end $64AFDC }

{ @routine $64B060 TScript_UnbindShip }
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
        Binding := Ships[Index];
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
      Binding := Ships[Index];
      Binding.Free;
      Ships.Delete(Index);
    end;
    Ship.ScriptShip := nil;
  end;
end;
{ @end $64B060 }

{ @routine $64B118 TScript_ClearShipBindings }
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
      if Index < 0 then Continue;
      Binding := Ships[Index];
      Binding.Free;
      Ships.Delete(Index);
      GetPlayer.ScriptShipBindings.Delete(I);
    end;
  for I := Ships.Count - 1 downto 0 do
  begin
    Binding := Ships[I];
    Ship := Binding.Ship;
    Binding.Free;
    Ships.Delete(I);
    Ship.ScriptShip := nil;
  end;
end;
{ @end $64B118 }

{ @routine $64B1C8 TScript_ChangeState }
procedure TScript.ChangeState(Binding: TScriptShip; StateIndex: Integer);
begin
  if Binding = nil then Exit;
  Binding.State := States[StateIndex];
  if Binding.State.EntryCode <> nil then Binding.State.EntryCode.Run(ScriptProcess);
  if not (Binding.Ship is TPlayer) then Binding.Ship.InitializeScriptStateOrders;
  if Binding.State.StateCode <> nil then
  begin
    PublishShipContext(Binding);
    Binding.State.StateCode.Run(ScriptProcess);
  end;
end;
{ @end $64B1C8 }

{ @routine $64B23C TScript_SetGroupRelation }
procedure TScript.SetGroupRelation(SourceGroup, TargetGroup: Integer; Level: TRelationLevel);
var
  Source, Target: TScriptShip;
  I, J: Integer;
begin
  if SourceGroup = TargetGroup then Exit;
  for I := 0 to Ships.Count - 1 do
  begin
    Source := Ships[I];
    if Source.GroupIndex = SourceGroup then
      for J := 0 to Ships.Count - 1 do
      begin
        Target := Ships[J];
        if (Target.GroupIndex = TargetGroup) and (Target.Ship is TRanger) then
          Source.Ship.SetStoredRangerRelationLevel(TRanger(Target.Ship), Level);
      end;
  end;
end;
{ @end $64B23C }

{ @routine $64B2F0 TScript_SetPlanetRelation }
procedure TScript.SetPlanetRelation(GroupIndex: Integer; Planet: TPlanet; Level: TRelationLevel);
var
  Binding: TScriptShip;
  I: Integer;
begin
  for I := 0 to Ships.Count - 1 do
  begin
    Binding := Ships[I];
    if (Binding.GroupIndex = GroupIndex) and (Binding.Ship is TRanger) then
      Planet.SetRelationLevelToRanger(TRanger(Binding.Ship), Level);
  end;
end;
{ @end $64B2F0 }

{ @routine $64B358 TScript_TryBindStars }
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
  Binding := Stars[StarIndex];
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
          Hole := aGalaxy.Galaxy.Holes[K];
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
      if (StarIndex = 0) and (K = 0) and (AnchorPlanet <> nil) then
      begin
        Binding.Planets[0].Planet := AnchorPlanet;
        Continue;
      end;
      if Star.Status.CustomFaction <> '' then Exit;
      MinOrbitSquared := Sqr(Binding.Planets[K].MinOrbitPercent / 100 * (Star.MapDiameter / 2));
      MaxOrbitSquared := Sqr(Binding.Planets[K].MaxOrbitPercent / 100 * (Star.MapDiameter / 2));
      Binding.Planets[K].Planet := nil;
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
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
          Ship := Candidates[I];
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
            if TRanger(Ship).CareerStatus[career_trader] < Requirement.MinTraderStatus then Continue;
            if TRanger(Ship).CareerStatus[career_trader] > Requirement.MaxTraderStatus then Continue;
            if TRanger(Ship).CareerStatus[career_warrior] < Requirement.MinWarriorStatus then Continue;
            if TRanger(Ship).CareerStatus[career_warrior] > Requirement.MaxWarriorStatus then Continue;
            if TRanger(Ship).CareerStatus[career_pirate] < Requirement.MinPirateStatus then Continue;
            if TRanger(Ship).CareerStatus[career_pirate] > Requirement.MaxPirateStatus then Continue;
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
  Binding := Stars[StarIndex];
  if Binding.ConstellationIndex = -1 then
  begin
    Count := aGalaxy.Galaxy.Stars.Count;
    for K := 0 to Count - 1 do
    begin
      Star := TStar(TScriptStar(Stars[0]).Star.StarDistances[K].Star);
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
      Star := aGalaxy.Galaxy.Stars[K];
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
        ConstellationBinding := Constellations[J];
        if ConstellationBinding.Constellation <> nil then
          if ConstellationBinding.Constellation = Star.Constellation then Break;
        Inc(J);
      end;
      if J < Constellations.Count then Continue;
      ConstellationBinding := Constellations[Binding.ConstellationIndex];
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
        Star := Constellation.Stars[K];
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
{ @end $64B358 }

{ @routine $64BF80 TScript_LoadFromBuffer }
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
  KlingType: TDominatorKind;

  // @nested $64BC74 CompileStateActionCode
  procedure CompileStateActionCode(State: TScriptState); // @addr 0x0064BC74 @note "Nested helper; captures Self at ParentFrame-4. Caller removes ParentFrame."
  var
    SourceText, ActionTypes, StepTypes: WideString;
    I, Count: Integer;
    Step: Cardinal;
    Action: TScriptEventKind;
  begin
    if State.OnActionText[1] = '[' then
    begin
      I := FindTextPosW(']', State.OnActionText);
      SourceText := CopyWideStringUnchecked(State.OnActionText, I + 1, Length(State.OnActionText) - I);
      ActionTypes := CopyWideStringUnchecked(State.OnActionText, 2, I - 2);
      StepTypes := ExtractDelimitedPartW(ActionTypes, 1, '|');
      ActionTypes := ExtractDelimitedPartW(ActionTypes, 0, '|');
      State.ActionCode := CompileScriptText(SourceText);
      if ((ActionTypes = '') and (StepTypes = '')) or (ActionTypes = 'Any') then State.ActionTypeMask := [event_step..event_death]
      else if ActionTypes = '' then State.ActionTypeMask := [event_step]
      else
      begin
        if StepTypes <> '' then State.ActionTypeMask := [event_step]
        else State.ActionTypeMask := [];
        ActionTypes := ',' + ActionTypes + ',';
        for Action := Low(ScriptActionTypeNames) to High(ScriptActionTypeNames) do
          if Pos(',' + ScriptActionTypeNames[Action] + ',', ActionTypes) > 0 then
            Include(State.ActionTypeMask, Action);
      end;
      if (StepTypes = '') or (StepTypes = 'Any') then State.StepTypeMask := AllScriptStepTypes
      else
      begin
        State.StepTypeMask := [];
        Count := CountDelimitedPartsW(StepTypes, ',');
        for I := 0 to Count - 1 do
        begin
          Step := ExtractDigitsToIntW(ExtractDelimitedPartW(StepTypes, I, ','));
          if Step in AllScriptStepTypes then Include(State.StepTypeMask, Step);
        end;
      end;
    end
    else
    begin
      State.ActionCode := CompileScriptText(State.OnActionText);
      State.ActionTypeMask := [event_step..event_death];
      State.StepTypeMask := AllScriptStepTypes;
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
          Star.Constraints[J].OtherStar := Stars[Buffer.GetInt32];
          Star.Constraints[J].MinDistance := Buffer.GetInt32;
          Star.Constraints[J].MaxDistance := Buffer.GetInt32;
          Star.Constraints[J].RequireBlackHole := Buffer.GetBoolean;
        end
      else
        for J := 0 to SubCount - 1 do
        begin
          Star.Constraints[J].OtherStar := Stars[Buffer.GetInt32];
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
    if SubCount <= 0 then Continue;
    SetLength(Star.ShipRequirements, SubCount);
    for J := 0 to SubCount - 1 do
    begin
      Star.ShipRequirements[J].Count := Buffer.GetInt32;
      Star.ShipRequirements[J].OwnerMask := DecodeScriptOwnerMask(Buffer.GetUInt32);
      Mask := Buffer.GetUInt32;
      Star.ShipRequirements[J].ShipTypeMask := DecodeScriptShipTypeMask(Mask);
      for KlingType := Low(TDominatorKind) to High(TDominatorKind) do Star.ShipRequirements[J].DominatorMasks[KlingType] := DecodeScriptDominatorMask(Mask, KlingType);
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
      if Star.ShipRequirements[J].StationNames <> '' then Star.ShipRequirements[J].ShipTypeMask := Star.ShipRequirements[J].ShipTypeMask + [hull_station];
    end;
  end;
  if CreateObjects then
  begin
    Star := Stars[0];
    Star.Star := AnchorStar;
    if Star.ConstellationIndex >= 0 then
    begin
      Constellation := Constellations[Star.ConstellationIndex];
      Constellation.Constellation := AnchorStar.Constellation;
    end;
    if not TryBindStars(0) then Exit;
    for I := 0 to Stars.Count - 1 do
    begin
      Star := Stars[I];
      InitCode.LocalVar.NamedItems[Star.Name].AsDword := Cardinal(Star.Star);
      if Star.Planets <> nil then
        for J := 0 to High(Star.Planets) do
        begin
          PlanetBinding := @Star.Planets[J];
          InitCode.LocalVar.NamedItems[PlanetBinding.Name].AsDword := Cardinal(PlanetBinding.Planet);
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
    if Place.PlaceKind = place_polar then
    begin
      Place.AngleOffset := Buffer.GetSingle;
      Place.DistanceScale := Buffer.GetSingle;
      Place.Radius := Buffer.GetInt32;
    end
    else if Place.PlaceKind = place_planet_position then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.Radius := Buffer.GetInt32;
    end
    else if Place.PlaceKind = place_docked_at_planet then Place.TargetVarName := Buffer.ReadWideString
    else if Place.PlaceKind = place_star_bearing then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.DistanceScale := Buffer.GetSingle;
      Place.Radius := Buffer.GetInt32;
      Place.AngleOffset := Buffer.GetSingle;
    end
    else if Place.PlaceKind = place_item_position then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.Radius := Buffer.GetInt32;
    end
    else if Place.PlaceKind = place_group_relative then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.DistanceScale := Buffer.GetSingle;
      Place.Radius := Buffer.GetInt32;
      Place.AngleOffset := Buffer.GetSingle;
    end
    else if Place.PlaceKind = place_coordinate_relative then
    begin
      Place.TargetVarName := Buffer.ReadWideString;
      Place.TargetVarName2 := Buffer.ReadWideString;
      Place.Radius := Buffer.GetInt32;
    end
    else RaiseWideMessage('Script.Place.Type');
    if CreateObjects then InitCode.LocalVar.NamedItems[Place.Name].AsDword := Cardinal(Place);
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
    InitCode.LocalVar.NamedItems[ScriptItem.Name].AsDword := Cardinal(ScriptItem);
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
    for KlingType := Low(TDominatorKind) to High(TDominatorKind) do Group.DominatorMasks[KlingType] := DecodeScriptDominatorMask(Mask, KlingType);
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
    if Group.StationNames <> '' then Group.ShipTypeMask := Group.ShipTypeMask + [hull_station];
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
      Group := Groups[I];
      Group.Ships := TList.Create;
      Group.Planet := TPlanet(InitCode.LocalVar.NamedItems[Group.PlanetVarName].AsDword);
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
            Group := Groups[GroupRelations[I].Group1];
            if Group.Ships.Count < Group.MaxCount then Break;
          end
          else if Balance > GroupRelations[I].MaxCombatBalance then
          begin
            Group := Groups[GroupRelations[I].Group2];
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
  ErrorText := InitCode.Compile(Analyzer, nil, nil, nil, nil);
  Analyzer.Free;
  if ErrorText <> '' then RaiseWideMessage('CodeInit.Compiler. Error=' + ErrorText);
  InitCode.LocalVar.Add('EndState', value_int32).AsInteger := 0;
  InitCode.LocalVar.Add('CurShip', value_uint32).AsInteger := 0;
  InitCode.LocalVar.Add('GABStatus', value_int32).AsInteger := 0;
  InitCode.LocalVar.Add('GQuestStatus', value_int32).AsInteger := Ord(quest_status_none);
  InitCode.LocalVar.Add('GRobotStatus', value_int32).AsInteger := 0;
  InitCode.LocalVar.Add('GVideoStatus', value_int32).AsInteger := 0;
  InitCode.LocalVar.Add('GAnswerData', value_uint32).AsInteger := 0;
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
  ErrorText := TurnCode.Compile(Analyzer, nil, nil, nil, nil);
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
    ErrorText := DialogCode.Compile(Analyzer, nil, nil, nil, nil);
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
    if (State.StateKind <> script_ship_idle) and (State.StateKind <> script_ship_normal_ai) then State.TargetVarName := Buffer.ReadWideString;
    SubCount := Buffer.GetInt32;
    if SubCount > 0 then
    begin
      SetLength(State.EnemyGroupNames, SubCount);
      SetLength(State.EnemyGroupIndices, SubCount);
      for J := 0 to SubCount - 1 do State.EnemyGroupNames[J] := Buffer.ReadWideString;
    end;
    State.PickupItemVarName := Buffer.ReadWideString;
    if State.PickupItemVarName <> '' then State.PickupItem := TScriptItem(InitCode.LocalVar.NamedItems[State.PickupItemVarName].AsDword);
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
      ErrorText := State.DialogCode.Compile(Analyzer, nil, nil, nil, nil);
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
      ErrorText := State.EntryCode.Compile(Analyzer, nil, nil, nil, nil);
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
    ErrorText := State.StateCode.Compile(Analyzer, nil, nil, nil, nil);
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
    ErrorText := Dialog.Code.Compile(Analyzer, nil, nil, nil, nil);
    Analyzer.Free;
    if ErrorText <> '' then RaiseWideMessage('Dialog.Code.Compiler. Error=' + ErrorText + ' State=' + Dialog.Name);
    Dialog.Code.LinkAll(ScriptFunctionScope, False);
    Dialog.Code.LinkAll(SharedScriptVariables, False);
    Dialog.Code.LinkAll(InitCode.LocalVar, False);
    Dialog.Code.ScriptFunLinked := True;
    InitCode.LocalVar.NamedItems[Dialog.Name].AsInteger := I;
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
    ErrorText := DialogMessage.Code.Compile(Analyzer, nil, nil, nil, nil);
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
    ErrorText := DialogAnswer.AnswerCode.Compile(Analyzer, nil, nil, nil, nil);
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
    ErrorText := DialogAnswer.ActionCode.Compile(Analyzer, nil, nil, nil, nil);
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
      State := States[I];
      if State.TargetVarName <> '' then State.TargetValue := InitCode.LocalVar.NamedItems[State.TargetVarName].AsDword;
      if State.EnemyGroupIndices <> nil then
        for J := 0 to High(State.EnemyGroupIndices) do
          State.EnemyGroupIndices[J] := InitCode.LocalVar.NamedItems[State.EnemyGroupNames[J]].AsInteger;
    end;
    for I := 0 to Places.Count - 1 do
    begin
      Place := Places[I];
      if Place.OriginVarName <> '' then Place.OriginStar := TStar(InitCode.LocalVar.NamedItems[Place.OriginVarName].AsDword);
      if Place.PlaceKind = place_coordinate_relative then
      begin
        if Place.TargetVarName <> '' then Place.TargetValue := Cardinal(InitCode.LocalVar.NamedItems[Place.TargetVarName]);
        if Place.TargetVarName2 <> '' then Place.TargetValue2 := InitCode.LocalVar.NamedItems[Place.TargetVarName2];
      end
      else if Place.TargetVarName <> '' then Place.TargetValue := InitCode.LocalVar.NamedItems[Place.TargetVarName].AsDword;
    end;
    for I := 0 to Items.Count - 1 do
    begin
      ScriptItem := Items[I];
      if ScriptItem.Name = '' then Continue;
      Item := nil;
      if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 0) then
      begin
        Item := TFuelTanks.Create;
        (Item as TFuelTanks).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 1) then
      begin
        Item := TEngine.Create;
        (Item as TEngine).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 2) then
      begin
        Item := TRadar.Create;
        (Item as TRadar).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 3) then
      begin
        Item := TScaner.Create;
        (Item as TScaner).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 4) then
      begin
        Item := TRepairRobot.Create;
        (Item as TRepairRobot).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 5) then
      begin
        Item := TCargoHook.Create;
        (Item as TCargoHook).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if (ScriptItem.DefinitionKind = item_def_equipment) and (ScriptItem.DefinitionType = 6) then
      begin
        Item := TDefGenerator.Create;
        (Item as TDefGenerator).Init(ScriptItem.Weight, ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if ScriptItem.DefinitionKind = item_def_equipment then RaiseWideMessage('Script unknow item type')
      else if (ScriptItem.DefinitionKind = item_def_weapon) and (ScriptItem.DefinitionType >= 0) and
        (ScriptItem.DefinitionType < CountItemTypesInMask([item_industrial_laser..item_lirecron])) then
      begin
        Item := TWeapon.Create;
        (Item as TWeapon).Init(GetItemTypeFromMask([item_industrial_laser..item_lirecron], ScriptItem.DefinitionType + 1), ScriptItem.Weight,
          ScriptItem.Level, ScriptItem.OwnerId);
      end
      else if ScriptItem.DefinitionKind = item_def_weapon then RaiseWideMessage('Script unknow item type')
      else if (ScriptItem.DefinitionKind = item_def_goods) and (ScriptItem.DefinitionType >= 0) and (ScriptItem.DefinitionType <= 8) then
      begin
        Item := TGoods.Create;
        (Item as TGoods).Init(TItemType(Byte(ScriptItem.DefinitionType) - Byte(ScriptItem.DefinitionType > 4)), ScriptItem.Weight);
        (Item as TGoods).NaturalFlag := ScriptItem.DefinitionType = 5;
      end
      else if (ScriptItem.DefinitionKind = item_def_goods) and (ScriptItem.DefinitionType = 9) then RaiseWideMessage('Script. Protoplasm not support')
      else if ScriptItem.DefinitionKind = item_def_goods then RaiseWideMessage('Script unknow item type')
      else if (ScriptItem.DefinitionKind = item_def_artefact) and (ScriptItem.DefinitionType >= 0) and
        (ScriptItem.DefinitionType < CountItemTypesInMask([artefact_hull..artefact_extra_missiles])) then
        Item := CreateConfiguredArtefactByItemType(GetItemTypeFromMask([artefact_hull..artefact_extra_missiles], ScriptItem.DefinitionType + 1), ScriptItem.OwnerId)
      else if ScriptItem.DefinitionKind = item_def_artefact then RaiseWideMessage('Script unknow item type')
      else if ScriptItem.DefinitionKind = item_def_custom then
      begin
        Item := TUselessItem.Create;
        (Item as TUselessItem).Init(ScriptItem.ConfigName, series_blazer, 0, False);
      end
      else if ScriptItem.DefinitionKind = 5 then Continue
      else RaiseWideMessage('Script unknow item type');
      Item.ScriptItem := ScriptItem;
      if InitCode.LocalVar.NamedItems[ScriptItem.LocationVarName].AsDword < 255 then
      begin
        Group := Groups[InitCode.LocalVar.NamedItems[ScriptItem.LocationVarName].AsDword];
        J := 0;
        while J < Group.Ships.Count do
        begin
          Ship := Group.Ships[J];
          if Ship.CargoFreeSpace >= Item.Weight then Break;
          Inc(J);
        end;
        if J < Group.Ships.Count then
        begin
          Ship := Group.Ships[J];
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
              ((Item as TArtefactTranclucator).Ship as TTranclucator).OwnerShip := Ship;
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
            Ship := Group.Ships[J];
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
            Ship := Group.Ships[0];
            Inc(Ship.CargoGoods[Ord(Item.ItemType)].Count, TGoods(Item).Quantity);
          end;
          Item.Free;
          Item := nil;
        end
        else
        begin
          Ship := Group.Ships[0];
          if Item is TArtefact then Ship.Artefacts.Add(Item)
          else
          begin
            Ship.Inventory.Add(Item);
            Ship.EquipItem(Item as TEquipment);
          end;
          Ship.RefreshDerivedStats(True);
        end;
      end
      else if TObject(InitCode.LocalVar.NamedItems[ScriptItem.LocationVarName].AsDword) is TPlanet then
      begin
        Planet := TPlanet(InitCode.LocalVar.NamedItems[ScriptItem.LocationVarName].AsDword);
        Planet.EquipmentShop.Add(Item);
      end
      else
      begin
        Place := TScriptPlace(InitCode.LocalVar.NamedItems[ScriptItem.LocationVarName].AsDword);
        if (Place.PlaceKind <> place_polar) and (Place.PlaceKind <> place_planet_position) and (Place.PlaceKind <> place_star_bearing) and (Place.PlaceKind <> place_group_relative) then RaiseWideMessage('Script error place type');
        Item.Position := Place.GetPoint;
        for K := 0 to 3 do
        begin
          SubCount := Place.OriginStar.Items.Count;
          J := 0;
          while J < SubCount do
          begin
            OtherItem := Place.OriginStar.Items[J];
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
      Binding := Ships[I];
      ChangeState(Binding, TScriptGroup(Groups[Binding.GroupIndex]).InitialStateIndex);
    end;
    for I := 0 to Stars.Count - 1 do
    begin
      Star := Stars[I];
      if Star.ProtectStar then aGalaxy.Galaxy.CancelEnemyJumpsToStar(Star.Star);
    end;
  end;
  Result := True;
end;
{ @end $64BF80 }

{ @routine $64EEE0 TScript_LoadFromFile }
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
{ @end $64EEE0 }

{ @routine $64F04C TScript_SaveState }
procedure TScript.SaveState(Buffer: TBufEC);
var
  I, J, Count: Integer;
  Binding: TScriptShip;
  Cell: TVarEC;
  Kind: TScriptValueKind;
  Star: TScriptStar;
  ScriptItem: TScriptItem;
begin
  Buffer.AddWideStringZ(ScriptFileName);
  Ether.SaveToBuffer(Buffer);
  Count := InitCode.LocalVar.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Cell := InitCode.LocalVar[I];
    Kind := Cell.Kind;
    if Kind = value_empty then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end
    else if Kind = value_int32 then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddIntegerValue(Cell.AsInteger);
    end
    else if Kind = value_uint32 then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDWord(Cell.AsDword);
    end
    else if Kind = value_float64 then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDouble(Cell.AsFloat);
    end
    else if Kind = value_string then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.AsString);
    end
    else if Kind = value_array then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Cell.AsArray.SaveToBuffer(Buffer);
    end
    else if (Kind = value_library_function) and (Cell.AsString <> '') then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.AsString);
    end
    else
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Kind := value_empty;
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end;
  end;
  Count := TurnCode.LocalVar.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Cell := TurnCode.LocalVar[I];
    Kind := Cell.Kind;
    if Kind = value_empty then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end
    else if Kind = value_int32 then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddIntegerValue(Cell.AsInteger);
    end
    else if Kind = value_uint32 then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDWord(Cell.AsDword);
    end
    else if Kind = value_float64 then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddDouble(Cell.AsFloat);
    end
    else if Kind = value_string then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.AsString);
    end
    else if Kind = value_array then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Cell.AsArray.SaveToBuffer(Buffer);
    end
    else if (Kind = value_library_function) and (Cell.AsString <> '') then
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Buffer.AddAnsiChar(AnsiChar(Kind));
      Buffer.AddWideStringZ(Cell.AsString);
    end
    else
    begin
      Buffer.AddWideStringZ(Cell.Name);
      Kind := value_empty;
      Buffer.AddAnsiChar(AnsiChar(Kind));
    end;
  end;
  Buffer.AddIntegerValue(Stars.Count);
  for I := 0 to Stars.Count - 1 do
  begin
    Star := Stars[I];
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
    ScriptItem := Items[I];
    if (ScriptItem.Name = '') and (ScriptItem.Item = nil) then Continue;
    Inc(Count);
  end;
  Buffer.AddIntegerValue(Count);
  for I := 0 to Items.Count - 1 do
  begin
    ScriptItem := Items[I];
    if (ScriptItem.Name = '') and (ScriptItem.Item = nil) then Continue;
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
  Count := Ships.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Binding := Ships[I];
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
{ @end $64F04C }

{ @routine $64F738 TScript_LoadState }
procedure TScript.LoadState(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, J, K, Count, SubCount, StateIndex: Integer;
  Binding: TScriptShip;
  Name: WideString;
  Cell: TVarEC;
  TemporaryCell: Boolean;
  Kind: TScriptValueKind;
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
      Cell := TVarEC.Create(value_empty);
      TemporaryCell := True;
      AppendLogLineThreadSafe(AnsiString('Warning.Script.GameLoad variable not found: ' + Name + ' (' + ScriptFileName + ')'));
    end;
    Kind := TScriptValueKind(Buffer.GetByte);
    // Definition-owned dialog/group handles must not be overwritten by saved pointers.
    if (Kind = value_uint32) and not TemporaryCell then
    begin
      for J := 0 to Dialogs.Count - 1 do
        if TScriptDialog(Dialogs[J]).Name = Name then
        begin
          Cell := TVarEC.Create(value_empty);
          TemporaryCell := True;
          Break;
        end;
      if not TemporaryCell then
        for J := 0 to Groups.Count - 1 do
          if TScriptGroup(Groups[J]).Name = Name then
          begin
            Cell := TVarEC.Create(value_empty);
            TemporaryCell := True;
            Break;
          end;
    end;
    if (Kind = value_library_function) and not TemporaryCell then
    begin
      Cell := TVarEC.Create(value_empty);
      TemporaryCell := True;
    end;
    if Kind = value_empty then
    begin
    end
    else if Kind = value_int32 then Cell.AsInteger := Buffer.GetInt32
    else if Kind = value_uint32 then Cell.AsDword := Buffer.GetUInt32
    else if Kind = value_float64 then Cell.AsFloat := Buffer.GetDouble
    else if Kind = value_string then Cell.AsString := Buffer.ReadWideString
    else if Kind = value_array then
    begin
      Cell.AsArray := TVarArrayEC.Create;
      Cell.AsArray.LoadFromBuffer(Buffer);
    end
    else if Kind = value_library_function then
    begin
      Cell.ConvertToKind(value_library_function);
      Name := Buffer.ReadWideString;
      Cell.AsString := Name;
      if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
      try
        ScriptLibraryCache.InitFunction(Cell);
      except
        AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Name));
        Cell.ConvertToKind(value_empty);
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
      Cell := TVarEC.Create(value_empty);
      TemporaryCell := True;
      AppendLogLineThreadSafe(AnsiString('Warning.Script.GameLoad variable not found: ' + Name + ' (' + ScriptFileName + ')'));
    end;
    Kind := TScriptValueKind(Buffer.GetByte);
    if (Kind = value_library_function) and not TemporaryCell then
    begin
      Cell := TVarEC.Create(value_empty);
      TemporaryCell := True;
    end;
    if Kind = value_empty then
    begin
    end
    else if Kind = value_int32 then Cell.AsInteger := Buffer.GetInt32
    else if Kind = value_uint32 then Cell.AsDword := Buffer.GetUInt32
    else if Kind = value_float64 then Cell.AsFloat := Buffer.GetDouble
    else if Kind = value_string then Cell.AsString := Buffer.ReadWideString
    else if Kind = value_array then
    begin
      Cell.AsArray := TVarArrayEC.Create;
      Cell.AsArray.LoadFromBuffer(Buffer);
    end
    else if Kind = value_library_function then
    begin
      Cell.ConvertToKind(value_library_function);
      Name := Buffer.ReadWideString;
      Cell.AsString := Name;
      if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
      try
        ScriptLibraryCache.InitFunction(Cell);
      except
        AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Name));
        Cell.ConvertToKind(value_empty);
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
    InitCode.LocalVar.NamedItems[Star.Name].AsDword := Cardinal(Star.Star);
    SubCount := Buffer.GetInt32;
    for K := 0 to SubCount - 1 do
    begin
      Name := Buffer.ReadWideString;
      PlanetBinding := GetPlanetBinding(Name);
      PlanetBinding.Planet := Galaxy.IdToPlanet(Buffer.GetUInt32) as TPlanet;
      InitCode.LocalVar.NamedItems[PlanetBinding.Name].AsDword := Cardinal(PlanetBinding.Planet);
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
    if Name <> '' then InitCode.LocalVar.NamedItems[Name].AsDword := Cardinal(ScriptItem);
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
    if StateIndex >= 0 then Binding.State := States[StateIndex]
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
{ @end $64F738 }

{ @routine $650358 TScript_BindImportedFunctions }
procedure TScript.BindImportedFunctions;
var
  I: Integer;
  Cell: TVarEC;
begin
  for I := 0 to InitCode.LocalVar.Count - 1 do
  begin
    Cell := InitCode.LocalVar.GetItemByNameOrder(I);
    if Cell.ValueKind <> value_library_function then Continue;
    if Cell.AsString = '' then Continue;
    if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
    try
      ScriptLibraryCache.InitFunction(Cell);
    except
      AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Cell.Name));
      Cell.ConvertToKind(value_empty);
    end;
  end;
  for I := 0 to TurnCode.LocalVar.Count - 1 do
  begin
    Cell := TurnCode.LocalVar.GetItemByNameOrder(I);
    if Cell.ValueKind <> value_library_function then Continue;
    if Cell.AsString = '' then Continue;
    if ScriptLibraryCache = nil then ScriptLibraryCache := TLibraryCache.Create;
    try
      ScriptLibraryCache.InitFunction(Cell);
    except
      AppendLogLineThreadSafe(AnsiString('Failed to load function ' + Cell.Name));
      Cell.ConvertToKind(value_empty);
    end;
  end;
end;
{ @end $650358 }

{ @routine $6505BC TScript_ResolveLoadedReferences }
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
    Binding := Ships[I];
    Binding.Ship := Galaxy.IdToShip(Cardinal(Binding.Ship), True) as TShip;
    if Binding.Ship is TPlayer then TPlayer(Binding.Ship).ScriptShipBindings.Add(Binding)
    else Binding.Ship.ScriptShip := Binding;
  end;
  for I := 0 to Places.Count - 1 do
  begin
    Place := Places[I];
    InitCode.LocalVar.NamedItems[Place.Name].AsDword := Cardinal(Place);
    if Place.OriginVarName <> '' then Place.OriginStar := TStar(InitCode.LocalVar.NamedItems[Place.OriginVarName].AsDword);
    if Place.PlaceKind = place_coordinate_relative then
    begin
      if Place.TargetVarName <> '' then Place.TargetValue := Cardinal(InitCode.LocalVar.NamedItems[Place.TargetVarName]);
      if Place.TargetVarName2 <> '' then Place.TargetValue2 := InitCode.LocalVar.NamedItems[Place.TargetVarName2];
    end
    else if Place.TargetVarName <> '' then Place.TargetValue := InitCode.LocalVar.NamedItems[Place.TargetVarName].AsDword;
  end;
  for I := 0 to States.Count - 1 do
  begin
    State := States[I];
    if State.TargetVarName <> '' then State.TargetValue := InitCode.LocalVar.NamedItems[State.TargetVarName].AsDword;
    if State.EnemyGroupIndices <> nil then
      for J := 0 to High(State.EnemyGroupIndices) do
        State.EnemyGroupIndices[J] := InitCode.LocalVar.NamedItems[State.EnemyGroupNames[J]].AsInteger;
  end;
end;
{ @end $6505BC }

{ @routine $650798 ClearScriptDialogRules }
procedure ClearScriptDialogRules;
var
  I, Count: Integer;
begin
  // Dispose finalizes the records' WideStrings.
  if ScriptDialogOverrides <> nil then
  begin
    Count := ScriptDialogOverrides.Count;
    for I := 0 to Count - 1 do Dispose(PScriptDialogOverride(ScriptDialogOverrides[I]));
    ScriptDialogOverrides.Clear;
  end
  else ScriptDialogOverrides := TObjectList.Create;
  if ScriptDialogInjections <> nil then
  begin
    Count := ScriptDialogInjections.Count;
    for I := 0 to Count - 1 do Dispose(PScriptDialogInjection(ScriptDialogInjections[I]));
    ScriptDialogInjections.Clear;
  end
  else ScriptDialogInjections := TObjectList.Create;
  if ScriptDialogBlocks <> nil then
  begin
    Count := ScriptDialogBlocks.Count;
    for I := 0 to Count - 1 do Dispose(PScriptDialogBlock(ScriptDialogBlocks[I]));
    ScriptDialogBlocks.Clear;
  end
  else ScriptDialogBlocks := TObjectList.Create;
end;
{ @end $650798 }

{ @routine $650898 TLibraryHandler_Create }
constructor TLibraryHandler.Create(LibraryName: WideString; ModuleHandle: Cardinal; DefinitionBlock: TBlockParEC);
begin
  inherited Create;
  Self.LibraryName := LibraryName;
  Self.ModuleHandle := ModuleHandle;
  Self.DefinitionBlock := DefinitionBlock;
end;
{ @end $650898 }

{ @routine $650924 TLibraryHandler_Destroy }
destructor TLibraryHandler.Destroy;
begin
  if ModuleHandle <> 0 then FreeLibrary(ModuleHandle);
  inherited Destroy;
end;
{ @end $650924 }

{ @routine $65097C TLibraryHandler_InitFunction }
procedure TLibraryHandler.InitFunction(Cell: TVarEC);
var
  Name, Text, Kind: WideString;
  I, Count: Integer;
  Proc: Pointer;
  Signature: array of Dword;
begin
  Text := Cell.AsString;
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
  if Kind = 'int' then Signature[0] := Ord(library_int32)
  else if Kind = 'dword' then Signature[0] := Ord(library_uint32)
  else if Kind = 'float' then Signature[0] := Ord(library_float32)
  else if Kind = 'str' then Signature[0] := Ord(library_wide_cstring)
  else Signature[0] := Ord(library_void);
  Signature[1] := Cardinal(Proc);
  for I := 2 to Count - 1 do
  begin
    Kind := ExtractDelimitedPartW(Text, I, ',');
    if Kind = 'int' then Signature[I] := Ord(library_int32)
    else if Kind = 'dword' then Signature[I] := Ord(library_uint32)
    else if Kind = 'float' then Signature[I] := Ord(library_float32)
    else if Kind = 'str' then Signature[I] := Ord(library_wide_cstring)
    else if Kind = 'ref' then Signature[I] := Ord(library_cell_pointer)
    else if Kind = 'code' then Signature[I] := Ord(library_code_context)
    else raise Exception.Create(AnsiString('Failed to init library function ' + Name + ' from ' + LibraryName + ' - unknown type ' + Kind));
  end;
  Cell.SetLibrarySignature(Signature);
  SetLength(Signature, 0);
end;
{ @end $65097C }

{ @routine $650E30 TLibraryHandler_InitAllFunctions }
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
      Cell := TVarEC.Create(value_library_function);
      Cell.Name := Name;
      Scope.AddItem(Cell);
    end;
    if Cell.ValueKind = value_library_function then
    begin
      Cell.AsString := LibraryName + ',' + Name;
      InitFunction(Cell);
    end;
  end;
end;
{ @end $650E30 }

{ @routine $650F48 TLibraryCache_Create }
constructor TLibraryCache.Create;
begin
  inherited Create;
  Libraries := TObjectList.Create;
end;
{ @end $650F48 }

{ @routine $650F8C TLibraryCache_Destroy }
destructor TLibraryCache.Destroy;
begin
  Libraries.Free;
  inherited Destroy;
end;
{ @end $650F8C }

{ @routine $651104 TLibraryCache_GetLib }
function TLibraryCache.GetLib(Name: WideString): TLibraryHandler;
var
  LowIndex, HighIndex, Middle, Comparison: Integer;
  Entry: TLibraryHandler;

  // @nested $650FBC LoadHandler
  function LoadHandler: TLibraryHandler; // @addr 0x00650FBC @ida "TLibraryHandler *__cdecl $name(void *ParentFrame);" @note "Nested helper; captures the library name at ParentFrame-4. Returns nil when its ScriptLibs block is absent."
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
{ @end $651104 }

{ @routine $6512B0 TLibraryCache_InitFunction }
procedure TLibraryCache.InitFunction(Cell: TVarEC);
begin
  GetLib(ExtractDelimitedPartW(Cell.AsString, 0, ',')).InitFunction(Cell);
end;
{ @end $6512B0 }

{ @routine $65132C ExecuteScriptText }
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
{ @end $65132C }

{ @routine $6515A0 CompileScriptText }
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
  ErrorText := Result.Compile(Analyzer, nil, nil, nil, nil);
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
{ @end $6515A0 }

{ @routine $651704 RunScriptCode }
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
{ @end $651704 }

{ @routine $651938 TScriptCache_Create }
constructor TScriptCache.Create;
begin
  inherited Create;
  Entries := TObjectList.Create;
end;
{ @end $651938 }

{ @routine $65197C TScriptGICache_Create }
constructor TScriptGICache.Create;
begin
  inherited Create;
  Entries := TObjectList.Create;
end;
{ @end $65197C }

{ @routine $6519C0 TScriptCache_Destroy }
destructor TScriptCache.Destroy;
begin
  Entries.Free;
  Entries := nil;
  inherited Destroy;
end;
{ @end $6519C0 }

{ @routine $6519F4 TScriptGICache_Destroy }
destructor TScriptGICache.Destroy;
begin
  Entries.Free;
  Entries := nil;
  inherited Destroy;
end;
{ @end $6519F4 }

{ @routine $651AA4 TScriptGICache_GetOrCompile }
function TScriptGICache.GetOrCompile(Block: TBlockParEC): TScriptGICacheUnit;
var
  LowIndex, HighIndex, Middle: Integer;
  Key: Cardinal;
  Entry: TScriptGICacheUnit;

  // @nested $651A28 CreateUiCacheEntry
  function CreateUiCacheEntry: TScriptGICacheUnit; // @addr $651A28 @ida "TScriptGICacheUnit *__cdecl $name(void *ParentFrame);" @note "Nested helper; captures Block at ParentFrame-4."
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
    if Entry = nil then Exit;
    Entries.Add(Entry);
    Result := Entry;
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
    if Entry = nil then Exit;
    Entries.Insert(0, Entry);
    Result := Entry;
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
    if Entry = nil then Exit;
    Entries.Add(Entry);
    Result := Entry;
    Exit;
  end;
  while True do
  begin
    if HighIndex - LowIndex < 2 then
    begin
      Entry := CreateUiCacheEntry;
      if Entry = nil then Exit;
      Entries.Insert(HighIndex, Entry);
      Result := Entry;
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
{ @end $651AA4 }

{ @routine $651D24 TScriptCache_GetOrCompile }
function TScriptCache.GetOrCompile(Name: WideString; Config: TBlockParEC): TScriptCacheUnit;
var
  LowIndex, HighIndex, Middle, Comparison: Integer;
  Entry: TScriptCacheUnit;
  SourceBlock: TBlockParEC;

  // @nested $651BF0 CreateEntry
  function CreateEntry: TScriptCacheUnit; // @addr 0x00651BF0 @ida "TScriptCacheUnit *__cdecl $name(void *ParentFrame);" @note "Nested helper; captures source block, config, and name at ParentFrame-4, -8, and -12. Caller owns a non-nil result."
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
{ @end $651D24 }

{ @routine $651F2C TScriptCacheUnit_Create }
constructor TScriptCacheUnit.Create;
begin
  inherited Create;
  Code := nil;
end;
{ @end $651F2C }

{ @routine $651F68 TScriptCacheUnit_Destroy }
destructor TScriptCacheUnit.Destroy;
begin
  if Code <> nil then Code.Free;
  Code := nil;
  inherited Destroy;
end;
{ @end $651F68 }

{ @routine $651FA0 TScriptCacheUnit_Initialize }
procedure TScriptCacheUnit.Initialize(Name, SourceText, ActionTypes, StepTypes: WideString);
var
  Action: TScriptEventKind;
  I: Integer;
  Step: Cardinal;
  Count: Integer;
begin
  Self.Name := Name;
  Self.SourceText := SourceText;
  Code := CompileScriptText(SourceText);
  if ((ActionTypes = '') and (StepTypes = '')) or (ActionTypes = 'Any') then ActionTypeMask := [event_step..event_death]
  else if ActionTypes = '' then ActionTypeMask := [event_step]
  else
  begin
    if StepTypes <> '' then ActionTypeMask := [event_step]
    else ActionTypeMask := [];
    ActionTypes := ',' + ActionTypes + ',';
    for Action := Low(ScriptActionTypeNames) to High(ScriptActionTypeNames) do
      if Pos(',' + ScriptActionTypeNames[Action] + ',', ActionTypes) > 0 then Include(ActionTypeMask, Action);
  end;
  if (StepTypes = '') or (StepTypes = 'Any') then StepTypeMask := AllScriptStepTypes
  else
  begin
    StepTypeMask := [];
    Count := CountDelimitedPartsW(StepTypes, ',');
    for I := 0 to Count - 1 do
    begin
      Step := ExtractDigitsToIntW(ExtractDelimitedPartW(StepTypes, I, ','));
      if Step in AllScriptStepTypes then Include(StepTypeMask, Step);
    end;
  end;
end;
{ @end $651FA0 }

{ @routine $652200 TScriptGICacheUnit_Create }
constructor TScriptGICacheUnit.Create;
begin
  inherited Create;
  Code := nil;
end;
{ @end $652200 }

{ @routine $65223C TScriptGICacheUnit_Destroy }
destructor TScriptGICacheUnit.Destroy;
begin
  if Code <> nil then Code.Free;
  Code := nil;
  inherited Destroy;
end;
{ @end $65223C }

{ @routine $652274 TScriptGICacheUnit_Initialize }
procedure TScriptGICacheUnit.Initialize(Block: TBlockParEC; SourceText: WideString);
begin
  Self.Block := Block;
  Self.SourceText := SourceText;
  Code := CompileScriptText(SourceText);
end;
{ @end $652274 }

{ @routine $6522D4 GetCachedActionCode }
function GetCachedActionCode(var Cache: TScriptCache; Name: WideString; Config: TBlockParEC): TScriptCacheUnit;
begin
  Result := nil;
  if Config = nil then Exit;
  if Cache = nil then Cache := TScriptCache.Create;
  Result := Cache.GetOrCompile(Name, Config);
end;
{ @end $6522D4 }

{ @routine $652344 ExecuteGameplayUiCode }
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
      if Cell <> nil then Cell.AsDword := VirtualKey
      else Code.LocalVar.Add('KEY', value_uint32).AsDword := VirtualKey;
      KeyModifiers := Ord(IsVirtualKeyDown(VK_SHIFT)) + Ord(IsVirtualKeyDown(VK_CONTROL)) * 2 + Ord(IsVirtualKeyDown(VK_MENU)) * 4;
      Cell := Code.LocalVar.GetVarNE('KEYMOD');
      if Cell <> nil then Cell.AsDword := KeyModifiers
      else Code.LocalVar.Add('KEYMOD', value_uint32).AsDword := KeyModifiers;
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
{ @end $652344 }

{ @routine $652660 ScriptSnap }
procedure ScriptSnap(out Snapshot: TScriptContextSnapshot);
begin
  Snapshot.Script := CurrentScript;
  if CurrentScript <> nil then
  begin
    Snapshot.CurrentShip := CurrentScript.CurrentShip;
    Snapshot.EndState := CurrentScript.InitCode.LocalVar.NamedItems['EndState'].AsInteger <> 0;
  end;
end;
{ @end $652660 }

{ @routine $6526BC ScriptUnSnap }
procedure ScriptUnSnap(Snapshot: TScriptContextSnapshot);
begin
  CurrentScript := Snapshot.Script;
  if CurrentScript <> nil then
  begin
    CurrentScript.CurrentShip := Snapshot.CurrentShip;
    CurrentScript.InitCode.LocalVar.NamedItems['CurShip'].AsDword := Cardinal(Snapshot.CurrentShip);
    CurrentScript.InitCode.LocalVar.NamedItems['EndState'].AsInteger := Ord(Snapshot.EndState);
  end;
end;
{ @end $6526BC }

{ @routine $652758 TScriptItem_CompileActionCode }
procedure TScriptItem.CompileActionCode;
var
  I: Integer;
  Step: Cardinal;
  Count: Integer;
  Action: TScriptEventKind;
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
    if ((ActionTypes = '') and (StepTypes = '')) or (ActionTypes = 'Any') then ActionTypeMask := [event_step..event_death]
    else if ActionTypes = '' then ActionTypeMask := [event_step]
    else
    begin
      if StepTypes <> '' then ActionTypeMask := [event_step]
      else ActionTypeMask := [];
      ActionTypes := ',' + ActionTypes + ',';
      for Action := Low(ScriptActionTypeNames) to High(ScriptActionTypeNames) do
        if Pos(',' + ScriptActionTypeNames[Action] + ',', ActionTypes) > 0 then Include(ActionTypeMask, Action);
    end;
    if (StepTypes = '') or (StepTypes = 'Any') then StepTypeMask := AllScriptStepTypes
    else
    begin
      StepTypeMask := [];
      Count := CountDelimitedPartsW(StepTypes, ',');
      for I := 0 to Count - 1 do
      begin
        Step := ExtractDigitsToIntW(ExtractDelimitedPartW(StepTypes, I, ','));
        if Step in AllScriptStepTypes then Include(StepTypeMask, Step);
      end;
    end;
  end
  else
  begin
    ActionCode := CompileScriptText(OnActionText);
    ActionTypeMask := [event_step..event_death];
    StepTypeMask := AllScriptStepTypes;
  end;
end;
{ @end $652758 }

{ @routine $652A6C TScriptItem_RunActionCode }
function TScriptItem.RunActionCode(ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
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
      if (ActionType = event_step) and not (Param in StepTypeMask) then Exit;
      if Script <> nil then
      begin
        ScriptSnap(Snapshot);
        Script.PublishCurrentShip(Ship);
        ScriptItemContextStack.Add(Item);
        ScriptItemInfoContextStack.Add(nil);
        ScriptActionTypeStack.Add(Pointer(Ord(ActionType)));
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
{ @end $652A6C }

{ @routine $652E1C TScriptShip_RunActionCode }
function TScriptShip.RunActionCode(ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
var
  Snapshot: TScriptContextSnapshot;
begin
  Result := Param;
  if (State = nil) or (State.OnActionText = '') then Exit;
  if not (ActionType in State.ActionTypeMask) then Exit;
  if (ActionType = event_step) and not (Param in State.StepTypeMask) then Exit;
  try
    ScriptSnap(Snapshot);
    Script.PublishCurrentShip(Ship);
    ScriptItemContextStack.Add(nil);
    ScriptItemInfoContextStack.Add(nil);
    ScriptActionTypeStack.Add(Pointer(Ord(ActionType)));
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
{ @end $652E1C }

{ @routine $65315C RunItemUseCode }
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
    Script.InitCode.LocalVar.NamedItems['CurShip'].AsDword := Cardinal(Ship);
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
{ @end $65315C }

{ @routine $653344 RunItemConfigActionCode }
function RunItemConfigActionCode(Item: TItem; ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
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
  if Entry = nil then Exit;
  if not (ActionType in Entry.ActionTypeMask) then Exit;
  if (ActionType = event_step) and not (Param in Entry.StepTypeMask) then Exit;
  Binding := TScriptItem(Item.ScriptItem);
  ParentCode := nil;
  try
    ScriptItemContextStack.Add(Item);
    ScriptItemInfoContextStack.Add(nil);
    ScriptActionTypeStack.Add(Pointer(Ord(ActionType)));
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
{ @end $653344 }

{ @routine $653708 RunCustomShipInfoActionCode }
function RunCustomShipInfoActionCode(Info: PCustomShipInfo; ActionType: TScriptEventKind; Ship: TShip; Object1, Object2: TObject; Param: Integer): Integer;
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
  if Entry = nil then Exit;
  if not (ActionType in Entry.ActionTypeMask) then Exit;
  if (ActionType = event_step) and not (Param in Entry.StepTypeMask) then Exit;
  ScriptItemContextStack.Add(nil);
  ScriptItemInfoContextStack.Add(Info);
  ScriptActionTypeStack.Add(Pointer(Ord(ActionType)));
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
{ @end $653708 }

{ @routine $653B74 TScriptItem_FormatDataText }
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
{ @end $653B74 }

{ @routine $653D54 GetScriptContextDescription }
function GetScriptContextDescription: WideString;
var
  Info: PCustomShipInfo;
  Item: TItem;
  Binding: TScriptItem;
begin
  if ScriptItemContextStack.Count > 0 then
  begin
    Info := ScriptItemInfoContextStack[ScriptItemInfoContextStack.Count - 1];
    if Info <> nil then
    begin
      Result := Info.TypeName;
      Exit;
    end;
    Item := ScriptItemContextStack[ScriptItemInfoContextStack.Count - 1];
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
{ @end $653D54 }

end.
