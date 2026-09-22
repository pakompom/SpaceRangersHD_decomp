unit Globals;
// Unit bracket (inferred): .text 0x00526284..0x00538D85; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x0087784C..0x0087785F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses fMainForm, fCfgSettings, fGameEnd, fAbout, fIntroduction, fGameSettings, fGameSettings2, fLoadAB, fAchievements, fFilm, fRating2, fGameMenu, fGameLoad, fPlanet, fGov, fInfo, fScaner, fRewards, fGalaxy2, fGoodsShop2, EC_Expression, fTalk, ab_MainForm, fLoad, fJump, ThreadCalc, fJournal, fSelectFace, fLoadQuest, fPlanetQuest, fPlanetNO, aItem, aGalaxyStruct, aShip, fScore, fLoadRobot, fStarMap, aEFilm, aEFilmEnd, SE_Space, SE_Process, aPlanet, fShip2, fHangar, fRuinsTalk, fEquipmentShop, fSaveManager, GI_GraphButton, GI_MessageLoop, EC_Buf, EC_Struct, fFilmFile, SyncObjs, Classes, Types;

const
  PersistentMessageLifetimeTurns = 1000000; // Finite native lifetime for retained notices.

  // PlayerMessagePresentations order; keep the stored Kind byte and set widths.
  pmGalaxyNews = 0;
  pmRadio = 1;
  pmShipPositive = 2;
  pmQuestActive = 3;
  pmQuestSucceeded = 4;
  pmQuestCancelled = 5; // QuestCancel presentation is also used for generic warnings.
  pmTip = 6;
  pmUserNote = 7;
  pmShipNegative = 8;
  pmStorage = 9;
  pmRadioPlayer = 10; // Radio message with the player among its ship targets.

type
  TGreetingMask = set of 0..7; // @size $01 Field-specific names and bits are decoded by the loaders.


  TScriptTemplUnit = class(TObjectEx) // @size $20
  public
    ClassId: Integer; // @offset $04 First comma-delimited Script template value; copied to TScript.ClassId on creation/restart.
    Name: WideString; // @offset $08
    FileName: WideString; // @offset $0C
    UseCount: Integer; // @offset $10 Returned by SF_GCntRun.
    LastTurn: Integer; // @offset $14 Returned by SF_GLastTurnRun.
    ActiveScriptIndex: Integer; // @offset $18 -1 when no active galaxy script is bound.
    ConditionCode: TCodeEC; // @offset $1C
    constructor Create; // @addr $52D7B0
    destructor Destroy; override; // @addr $52D810
  end;

  TPlanetTempl = class(TObject) // @size $18
  public
    Radius: Integer; // @offset $04
    SmallMaskName: WideString; // @offset $08
    SmallLightName: WideString; // @offset $0C
    MaskName: WideString; // @offset $10
    LightName: WideString; // @offset $14
  end;

  TPlanetSpaceTemplate = record // @size $10
    Style: Integer; // @offset $00 First SE.Planet.Style value.
    StyleVariant: Integer; // @offset $04 Optional second SE.Planet.Style value.
    Radius: Integer; // @offset $08
    SpaceObject: TObjectSE; // @offset $0C Retained until UI shutdown.
  end;

  TSputnikTempl = class(TObject) // @size $0C
  public
    Radius: Integer; // @offset $04
    MaskName: WideString; // @offset $08
  end;

  TPlayerMessageKindSet = set of 0..15; // @size $02 Native exclusion mask for persistent-message searches.

  TPlayerMessageTarget = packed record // @size 0x08
    ShipId: Cardinal; // @offset 0x00
    PlanetId: Cardinal; // @offset 0x04
  end;

  // Native record RTTI at $5263EC.
  TMessagePlayerTypeGraph = record // @size $10
    NormalImage: WideString; // @offset $00
    ActiveImage: WideString; // @offset $04
    PressedImage: WideString; // @offset $08
    LifetimeTurns: Integer; // @offset $0C
  end;

  TPlayerMessagePresentations = array[0..10] of TMessagePlayerTypeGraph;

var
  PlayerMessagePresentations: array[0..10] of TMessagePlayerTypeGraph = (
    (NormalImage: 'GalaxyN'; ActiveImage: 'GalaxyA'; PressedImage: 'GalaxyD'; LifetimeTurns: 10),
    (NormalImage: 'EtherN'; ActiveImage: 'EtherA'; PressedImage: 'EtherD'; LifetimeTurns: 0),
    (NormalImage: 'ShipPlusN'; ActiveImage: 'ShipPlusA'; PressedImage: 'ShipPlusD'; LifetimeTurns: 5),
    (NormalImage: 'QuestNormalN'; ActiveImage: 'QuestNormalA'; PressedImage: 'QuestNormalD'; LifetimeTurns: PersistentMessageLifetimeTurns),
    (NormalImage: 'QuestOkN'; ActiveImage: 'QuestOkA'; PressedImage: 'QuestOkD'; LifetimeTurns: PersistentMessageLifetimeTurns),
    (NormalImage: 'QuestCancelN'; ActiveImage: 'QuestCancelA'; PressedImage: 'QuestCancelD'; LifetimeTurns: PersistentMessageLifetimeTurns),
    (NormalImage: 'TipsN'; ActiveImage: 'TipsA'; PressedImage: 'TipsD'; LifetimeTurns: 182),
    (NormalImage: 'UserN'; ActiveImage: 'UserA'; PressedImage: 'UserD'; LifetimeTurns: PersistentMessageLifetimeTurns),
    (NormalImage: 'ShipMinusN'; ActiveImage: 'ShipMinusA'; PressedImage: 'ShipMinusD'; LifetimeTurns: 5),
    (NormalImage: 'StorageN'; ActiveImage: 'StorageA'; PressedImage: 'StorageD'; LifetimeTurns: PersistentMessageLifetimeTurns),
    (NormalImage: 'Ether2N'; ActiveImage: 'Ether2A'; PressedImage: 'Ether2D'; LifetimeTurns: 0)); // @addr $87AD94 Native image defaults and turn lifetimes.

type
  TMessagePlayer = class(TObjectEx) // @size 0x44
  public
    Prev: TMessagePlayer; // @offset 0x04
    Next: TMessagePlayer; // @offset 0x08
    Key: WideString; // @offset 0x0C
    Kind: Byte; // @offset 0x10
    ImageNameOverride: WideString; // @offset 0x14
    NotificationSoundKind: Integer; // @offset 0x18  0: new message; 1: system liberation; some message kinds override it.
    Turn: Integer; // @offset 0x1C
    Text: WideString; // @offset 0x20
    Targets: array[0..2] of TPlayerMessageTarget; // @offset 0x24
    Button: TGraphButtonGI; // @offset 0x3C  Borrowed UI object, rebuilt after loading.
    WasRead: Boolean; // @offset 0x40
    NotificationSoundPlayed: Boolean; // @offset 0x41
    // Targets are serialized as all three ship IDs, then all three planet IDs.
    // Prev, Next and Button are not serialized; both flags are persistent.

    constructor Create; // @addr 0x52C9F4 @note "Does not link the object into the global message queue."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x52CA48
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x52CB28 @note "Leaves linkage and Button untouched. ImageNameOverride is present only from save version 109 onward."
    function GetNormalImageName: WideString; // @addr 0x52CC64
    function GetActiveImageName: WideString; // @addr 0x52CCB8
    function GetPressedImageName: WideString; // @addr 0x52CD0C
  end;

function FindScriptTemplateIndex(const Name: WideString): Integer; // @addr $52D854 @note "Case-sensitive; returns -1 when absent. Requires the template list. Native callers include UI loading and script builtins."

procedure CollectInactiveScriptTemplates(Dest: TList); // @addr $52D8BC @note "Clears Dest, borrows templates with ActiveScriptIndex < 0, then performs twice Count seeded swaps. Chaotic RNG mode ignores the seeds."

procedure RecreateSpaceProcess(const ConfigName: WideString); // @addr $52C8D0
function ShowPlayerTipOnce(Index: Integer): Boolean; // @addr $52D9E8 @note "Sets the shown bit and enqueues localized Tips.00-style player text; returns whether a new tip was shown."
function HasShownPlayerTip(Index: Integer): Boolean; // @addr $52DB38

function SelectSpaceImageTemplateFromSeed(Kind: Integer; Seed: Cardinal): Integer; // @addr $52DB58 @note "Weighted selection restricted to Kind; returns 0 if no weight is available."
function SelectSpaceImageTemplate(Kind: Integer): Integer; // @addr $52DC3C
function FindPlanetSpaceTemplateIndex(Style, StyleVariant: Integer): Integer; // @addr $52E8E4 @note "Raises when no template matches the two SE.Planet.Style values."
procedure HandleRuntimeExitCheck1; // @addr $52DC68 @note "Retained empty ExitScreenLoop test; assigned by Rangers.start to an otherwise unread hook."
procedure HandleRuntimeExitCheck2; // @addr $52DC74 @note "Retained empty ExitScreenLoop test; assigned by Rangers.start to an otherwise unread hook."

procedure InitializeScriptHostRuntime; // @addr 0x526AC4
procedure FinalizeScriptHostRuntime; // @addr 0x526C04
function ParseRobotMapRaceMask(Text: WideString): TOwnerMask; // @addr $52DC80 @ida "unsigned __int8 __usercall $name@<al>(unsigned __int16 *Text@<eax>);"
function FindRobotMapById(MapId: Integer): Integer; // @addr $52E88C Returns -1 for an unknown map.
procedure InitializeRobotMapDefinitions; // @addr $52DED4
procedure InitializeShipGreetingDefinitions; // @addr $52E9B4
procedure InitializeGovernmentGreetingDefinitions; // @addr $534F34
procedure InitializePlanetAdvertDefinitions; // @addr $538150
procedure InitializeGlobalUiRuntime; // @addr 0x526F10
procedure FinalizeGlobalUiRuntime; // @addr 0x52BED8
procedure ResetScriptHostRuntimeState; // @addr 0x52C68C
function FindMessageLoop(Name: WideString): TMessageLoopGI; // @addr 0x52BE1C @note "Case-sensitive; returns nil when absent."
procedure RunMainScreenStateLoop; // @addr 0x52C908 @note "Consumes RequestedScreenId before each run; zero ends dispatch. StarMap, Film and arcade battle use RunContinuous."

procedure SwapTurnFilms; // @addr $52C9D0 Exchanges the producer and playback films.
function GetInnermostScreenLoop: TMessageLoopGI; // @addr $538C18 Follows ChildLoop from the current registered screen.
function FindPlayerMessageExceptKinds(const Key: WideString; ExcludedKinds: TPlayerMessageKindSet; SkipLock: Boolean): TMessagePlayer; // @addr $52D3C8 @ida "TMessagePlayer *__usercall $name@<eax>(unsigned __int16 *Key@<eax>, unsigned __int16 ExcludedKinds@<dx>, bool SkipLock@<cl>);" Key is an optional substring; returned queue node is borrowed.
function RemovePlayerMessagesExceptKinds(Key: WideString; ExcludedKinds: TPlayerMessageKindSet; SkipLock: Boolean): Boolean; // @addr $52CF90 @ida "bool __usercall $name@<al>(unsigned __int16 *Key@<eax>, unsigned __int16 ExcludedKinds@<dx>, bool SkipLock@<cl>);" Returns whether any queued message was removed.
procedure ClearPersistentPlayerMessages; // @addr 0x52CD60
function CountPersistentPlayerMessages: Integer; // @addr 0x52CDDC
function IsPersistentPlayerMessageQueued(MessageEntry: TMessagePlayer; SkipLock: Boolean): Boolean; // @addr 0x52CE4C
procedure RemovePersistentPlayerMessage(MessageEntry: TMessagePlayer; SkipLock: Boolean); // @addr 0x52CED8 @note "Requires a queued node; unlinks and frees it."
function FindPlayerBubbleByText(const Text: WideString; SkipLock: Boolean): TMessagePlayer; // @addr 0x52D04C @note "Returns a borrowed queue node or nil."
function FindPlayerBubbleByKey(const Key: WideString; SkipLock: Boolean): TMessagePlayer; // @addr 0x52D0E4 @note "Returns a borrowed queue node or nil."
procedure RemovePlayerBubblePages(const Prefix: WideString; FirstPage: Integer); // @addr $52D260 @note "Removes matching prefix keys whose integer suffix is at least FirstPage; leaves unnumbered keys alone."
procedure RemovePlayerBubbleByKey(const Key: WideString); // @addr 0x52D17C @note "Removes only the first exact match."
function CreatePersistentPlayerMessage: TMessagePlayer; // @addr 0x52D484 @note "Appends a new node owned by the global message queue."
function AddOrUpdatePlayerBubble(Kind: Byte; Turn: Integer; const Text, Key: WideString): TMessagePlayer; // @addr 0x52D520 @note "Returns a borrowed queue node. An existing key updates kind/turn and nonempty text; otherwise an exact text match is returned unchanged."
procedure PruneExpiredPersistentPlayerMessages; // @addr 0x52D698

var

var
  MainMenuScreen: TfMainForm; // @addr 0x88A428
  NewGameScreen: TfGameSettings2; // @addr 0x88A42C
  IntroductionScreen: TfIntroduction; // @addr 0x88A430
  HangarScreen: TfHangar; // @addr $88A434
  PlanetScreen: TfPlanet; // @addr $88A438
  UninhabitedPlanetScreen: TfPlanetNO; // @addr $88A43C
  PlanetQuestScreen: TfPlanetQuest; // @addr 0x88A440
  RuinsTalkScreen: TfRuinsTalk; // @addr $88A444
  ArcadeBattleScreen: TfAB; // @addr $88A448
  EquipmentShopScreen: TfEquipmentShop; // @addr $88A44C
  GoodsShopScreen: TfGoodsShop2; // @addr $88A450
  GovernmentScreen: TfGov; // @addr $88A454
  InfoScreen: TfInfo; // @addr $88A458
  RangerRatingScreen: TfRating2; // @addr 0x88A45C
  RewardsScreen: TfRewards; // @addr $88A460
  ShipScreen: TfShip2; // @addr 0x88A464
  TalkScreen: TfTalk; // @addr $88A468
  ScannerScreen: TfScaner; // @addr $88A46C
  StarMapScreen: TfStarMap; // @addr 0x88A470
  FilmScreen: TfFilm; // @addr 0x88A474
  GalaxyScreen: TfGalaxy2; // @addr $88A478
  JumpScreen: TfJump; // @addr $88A47C
  LoadScreen: TfLoad; // @addr $88A480
  SaveManagerScreen: TfSaveManager; // @addr 0x88A484
  GameLoadScreen: TfGameLoad; // @addr $88A488
  GameMenuScreen: TfGameMenu; // @addr $88A48C
  SettingsScreen: TfCfgSettings; // @addr 0x88A490
  GameEndScreen: TfGameEnd; // @addr $88A494
  AboutScreen: TfAbout; // @addr 0x88A498
  ScoreScreen: TfScore; // @addr 0x88A49C
  SelectFaceScreen: TfSelectFace; // @addr $88A4A0
  SpaceObjectUiLoop: TMessageLoopGI; // @addr $88A4A4 Unregistered loop centered on the back buffer; hosts space-object controls.
  JournalScreen: TfJournal; // @addr $88A4A8
  LoadRobotScreen: TfLoadRobot; // @addr $88A4AC
  LoadQuestScreen: TfLoadQuest; // @addr 0x88A4B0
  LoadArcadeScreen: TfLoadAB; // @addr $88A4B4
  AchievementsScreen: TfAchievements; // @addr $88A4B8 Native UI shutdown does not free this screen.
var
  SpaceViewPosition: TPointF; // @addr $88A4BC Map scroll offset and scene sound attenuation origin.
  FilmCameraFollow: Boolean; // @addr $88A4C4
var

  TalkShip: TShip; // @addr 0x88A4C8
  TalkPlanet: TPlanet; // @addr $88A4CC Planet dialogue target, assigned by TPlanet.RequestDialog.
  TalkScripted: Boolean; // @addr $88A4D0 Set for the scripted Keller dialogue.
  TalkType: Byte; // @addr $88A4D1 tk* conversation ID set by TShip.ShowPlayerDialogue and exposed by SF_GetTalkType.
  TalkAmount: Integer; // @addr $88A4D4 Negotiated amount; ShowPlayerDialogue overwrites it only for positive inputs.
  TalkResponse: Byte; // @addr $88A4D8 Response selected by the conversation UI.
  TalkText: WideString; // @addr $88A4DC Message supplied to the conversation UI.
var
  ScriptUseItem: TItem; // @addr $88A4E0 Item currently executing OnUse; native runner clears it after success.
  ScriptItemContextStack: TList; // @addr $88A4E4
  ScriptItemInfoContextStack: TList; // @addr $88A4E8
  ScriptActionShipStack: TList; // @addr $88A4EC
  ScriptActionObject1Stack: TList; // @addr $88A4F0
  ScriptActionObject2Stack: TList; // @addr $88A4F4
  ScriptActionParamStack: TList; // @addr $88A4F8
  ScriptActionTypeStack: TList; // @addr $88A4FC
  ScreenLoadMode: Byte; // @addr $88A500 @note "Startup sets 0, or 3 for a screen with composite loading assets."
var

  ScriptTemplates: TList; // @addr $88A504 @note "Owns native TScriptTemplUnit entries."
  SharedScriptVariables: TVarArrayEC; // @addr $88A508 @note "Shared scope used by script compilation, execution and text-quest external parameters."
  GlobalScriptVariables: TVarArrayEC; // @addr $88A50C @note "Persistent script globals, initially GRunFrom and GRunStar."
  ScriptTemplateStartRequested: Boolean; // @addr $88A510 Set by script condition code; checked after running each inactive template.
  LastLoadedPlayerName: WideString; // @addr $88A514 Assigned by TPlayer.LoadFromBuffer; broader UI-cache role unresolved.
var
  ReloadScriptTemplates: Boolean = True; // @addr $87AE44 @note "Native initial value is True. Reset sets this flag; UI initialization reloads script and ship templates then clears it."
  ReloadModsRequested: Boolean = False; // @addr $87AE48
  StandaloneQuestMode: Boolean = False; // @addr $87AE4C @note "The quest selector sets True; planet/government/script launches set False. Guards campaign quest checks and turn advancement."
  ScannerTarget: TObject = nil; // @addr $87AE50 Borrowed target passed from the star map to the scanner screen.
  ScriptDialogIndex: Integer = -1; // @addr $87AE54 Selected script dialogue; -1 while resolving a dialogue variable.
var
  AwardSubject: TObject = nil; // @addr $87AE58 Borrowed ship selected by inventory, scanner or ranger ranking for the medals screen.
  PlayerStarDayPrepared: Boolean = False; // @addr 0x87AE5C
var
  PreviousFilmActivity: Cardinal = 0; // @addr $87AE60
  FilmSoundEffectsEnabled: Boolean = True; // @addr $87AE64 Temporarily disabled while the film slider seeks through steps.
  TurnCalculationThread: TThreadCalc = nil; // @addr $87AE68 @note "Owned here; ThreadCalc and Rangers access it through the imported reference cell."
  DefaultArcadeLaserEffect: WideString = 'Laser.W1'; // @addr $87AE6C Native default; callers remain to be identified.
  DefaultArcadeHitEffect: WideString = 'Anim.H1'; // @addr $87AE70 Native default; callers remain to be identified.
  DefaultArcadeExplosionEffect: WideString = 'Anim.E1'; // @addr $87AE74 Native default; callers remain to be identified.
var
  FilmHistory: TFilmFile = nil; // @addr 0x87AE78
  CacheLoader: TCacheLoader = nil; // @addr 0x87AE7C
var
  SaveManagerMode: TSaveManagerMode = smmLoad; // @addr 0x87AE80
  TalkRequestEvent: Cardinal = 0; // @addr $87AE84 @note "Auto-reset event: ship/planet turn workers request a player conversation."
  TalkCompletedEvent: Cardinal = 0; // @addr $87AE88 @note "Auto-reset event signaled when the star-map UI returns from conversation."
  ScriptUiRequestEvent: Cardinal = 0; // @addr $87AE8C @note "Raised by the turn thread when requesting a UI-side conversation."
  ScriptUiAbortEvent: Cardinal = 0; // @addr $87AE90 @note "Aborts a pending turn-thread conversation wait; the worker returns False."
  PlanetRenderTemplates: TList = nil; // @addr $87AE94 Owns TPlanetTempl instances.
var
  MinimapFrameCounter: Integer = 0; // @addr $87AE98 Film/star-map draw cadence; reset by manual minimap scrolling.
  Skip1C: Boolean = False; // @addr $87AE9C
  SkipVideo: Boolean = False; // @addr $87AEA0
  SkipIntro: Boolean = False; // @addr $87AEA4
var
  NewGameGenerationThread: TThreadCreateNewGame; // @addr 0x88A518
  ShownPlayerTips: Cardinal; // @addr $88A51C Bit mask; native shifts use the low five bits of the tip index.
var
  StarMapWeaponPanelOpen: Boolean; // @addr $88A520 Toggled by TfStarMap.ToggleWeaponPanelClicked; reset on arcade exit.
var

  PrimaryFilm: TEFilm; // @addr 0x88A524
  SecondaryFilm: TEFilm; // @addr 0x88A528
var
  TrailingFilmEffects: TEFilmEnd; // @addr $88A52C Native shared trailing-effect owner.
var

  SpaceProcess: TProcessSE; // @addr $88A530
var
  ActiveLoadBuffer: TBufEC; // @addr 0x88A534 @note "Borrowed during LoadGameFromFile; exposed for progress reporting."
var

  PersistentPlayerMessageLock: TCriticalSection; // @addr $88A538
  FirstPersistentPlayerMessage: TMessagePlayer; // @addr 0x88A53C
  LastPersistentPlayerMessage: TMessagePlayer; // @addr 0x88A540
  ArcadeExplosionSounds: array of WideString; // @addr $88A544 ABSound.Explosion values.
  ArcadeItemSounds: array of WideString; // @addr $88A548 ABSound.Item values.
  ArcadeHitSounds: array of WideString; // @addr $88A54C ABSound.Hit values.
  ArcadeWeaponFirstSounds: array[0..17] of WideString; // @addr $88A550 ABSound.WeaponFirst.
  ArcadeWeaponLoopSounds: array[0..17] of WideString; // @addr $88A598 ABSound.WeaponLoop entries, after the time value.
var
  ArcadeWeaponLoopTicks: array[0..17] of Integer; // @addr $88A5E0 First configured value divided by 20; -1 when absent.
  RaceShipTemplates: array[TOwnerId, 0..5] of TObjectSE; // @addr $88A628 @note "Retained SE.Ship templates indexed by race and six ordinary ship kinds."
  BlazerShipTemplates: array[0..7] of TObjectSE; // @addr $88A6E8
  KellerShipTemplates: array[0..7] of TObjectSE; // @addr $88A708
  TerronShipTemplates: array[0..7] of TObjectSE; // @addr $88A728
  PirateClanShipTemplates: array[TOwnerId] of TObjectSE; // @addr $88A748
  PlanetSpaceTemplates: array of TPlanetSpaceTemplate; // @addr $88A768

type
  // Native record RTTI at $526870.
  TRobotMap = record // @size $50
    Id: Integer; // @offset $00
    Name: WideString; // @offset $04
    Group: Integer; // @offset $08 -1 when absent.
    Access: Integer; // @offset $0C
    Side: Integer; // @offset $10 Red=1, Green=2, Blue=4.
    Length: Integer; // @offset $14
    Map: WideString; // @offset $18
    PlanetRace: TOwnerMask; // @offset $1C Empty mask means Any.
    PlayerRace: TOwnerMask; // @offset $1D Empty mask means Any.
    PlayerStatus: TRangerCareerSet; // @offset $1E Empty mask means Any.
    MinWins: Integer; // @offset $20
    MaxWins: Integer; // @offset $24
    Reiteration: Integer; // @offset $28
    ReinforcementsDisabled: Boolean; // @offset $2C
    Terron: Boolean; // @offset $2D
    Demo: Boolean; // @offset $2E
    AfterLiberation: Boolean; // @offset $2F
    GovTextStart: WideString; // @offset $30
    GovTextWin: WideString; // @offset $34
    GovTextLoss: WideString; // @offset $38
    RobotsStart: WideString; // @offset $3C
    RobotsWin: WideString; // @offset $40
    RobotsLoss: WideString; // @offset $44
    FromAuthor: WideString; // @offset $48
    PlayerPlayCount: Integer; // @offset $4C Scratch rebuilt from player history by TPlayer.SelectPlanetBattleMap; not set by the definition loader.
  end;

var
  UselessItemRemainsCount: Integer; // @addr $88A76C UselessItems.CntRemains.
  RobotMapDefinitions: array of TRobotMap; // @addr $88A770

type
  // Native record RTTI at $5268F4.
  TShipGreetingsInfo = record // @size $84
    Name: WideString; // @offset $00
    Priority: Integer; // @offset $04
    AutoTalk: Byte; // @offset $08
    FlyType: Byte; // @offset $09
    ShipType: TGreetingMask; // @offset $0A
    Relations: TRelationLevels; // @offset $0B
    ShipRace: TOwnerMask; // @offset $0C
    PlayerRace: TOwnerMask; // @offset $0D
    ShipRaceIsPlayerRace: Byte; // @offset $0E
    PlayerAttackGoodShip: Byte; // @offset $0F
    InFear: Byte; // @offset $10
    ShipBadFlyToShip: Byte; // @offset $11
    ShipBadType: TGreetingMask; // @offset $12
    ShipBadRace: TOwnerMask; // @offset $13
    ShipFlyToPlayer: Byte; // @offset $14
    PlayerFlyToShip: Byte; // @offset $15
    PlayerIsShipBad: Byte; // @offset $16
    ShipTurnBeforeEndOrder: TGreetingCountMask; // @offset $17
    PlayerTurnBeforeEndOrder: TGreetingCountMask; // @offset $19
    ShipBadTurnBeforeEndOrder: TGreetingCountMask; // @offset $1B
    ShipStatus: TRangerCareerSet; // @offset $1D
    PlayerStatus: TRangerCareerSet; // @offset $1E
    ShipStrength: TGreetingMask; // @offset $1F
    PlayerStrength: TGreetingMask; // @offset $20
    ShipStructure: TGreetingMask; // @offset $21
    PlayerStructure: TGreetingMask; // @offset $22
    ShipRating: TGreetingMask; // @offset $23
    PlayerRating: TGreetingMask; // @offset $24
    ShipRank: TGreetingMask; // @offset $25
    PlayerRank: TGreetingMask; // @offset $26
    RatingShipWithPlayer: TGreetingMask; // @offset $27
    RankShipWithPlayer: TGreetingMask; // @offset $28
    StrengthShipWithPlayer: TGreetingMask; // @offset $29
    Goods: Byte; // @offset $2A
    ShipGoodsCnt: TGreetingMask; // @offset $2B
    PlayerGoodsCnt: TGreetingMask; // @offset $2C
    ShipHaveGoods: Byte; // @offset $2D
    PlayerHaveGoods: Byte; // @offset $2E
    ShipGoodsTypeCnt: TGreetingCountMask; // @offset $2F
    PlayerGoodsTypeCnt: TGreetingCountMask; // @offset $31
    ShipMayScanPlayer: Byte; // @offset $33
    RangerInCurStar: TGreetingCountMask; // @offset $34
    PirateInCurStar: TGreetingCountMask; // @offset $36
    KlingInCurStar: TGreetingCountMask; // @offset $38
    WarriorInCurStar: TGreetingCountMask; // @offset $3A
    TransportInCurStar: TGreetingCountMask; // @offset $3C
    LastPlanetRace: TOwnerMask; // @offset $3E
    LastPlanetRelations: TRelationLevels; // @offset $3F
    LastPlanetGoodsCnt: TGreetingMask; // @offset $40
    LastPlanetGoodsSale: TGreetingMask; // @offset $41
    LastPlanetGoodsBuy: TGreetingMask; // @offset $42
    LastPlanetIsHomePlanet: Byte; // @offset $43
    LastPlanetRaceIsShipRace: Byte; // @offset $44
    LastPlanetRaceIsPlayerRace: Byte; // @offset $45
    LastPlanetEconomy: TPlanetEconomies; // @offset $46
    LastPlanetGovernment: TPlanetGovernments; // @offset $47
    LastPlanetInCurStar: Byte; // @offset $48
    LastPlanetDistToShipInTurn: TGreetingCountMask; // @offset $49
    RangerInLastPlanetStar: TGreetingCountMask; // @offset $4B
    PirateInLastPlanetStar: TGreetingCountMask; // @offset $4D
    KlingInLastPlanetStar: TGreetingCountMask; // @offset $4F
    WarriorInLastPlanetStar: TGreetingCountMask; // @offset $51
    TransportInLastPlanetStar: TGreetingCountMask; // @offset $53
    ToPlanetRace: TOwnerMask; // @offset $55
    ToPlanetRelations: TRelationLevels; // @offset $56
    ToPlanetGoodsCnt: TGreetingMask; // @offset $57
    ToPlanetGoodsSale: TGreetingMask; // @offset $58
    ToPlanetGoodsBuy: TGreetingMask; // @offset $59
    ToPlanetIsHomePlanet: Byte; // @offset $5A
    ToPlanetRaceIsShipRace: Byte; // @offset $5B
    ToPlanetRaceIsPlayerRace: Byte; // @offset $5C
    ToPlanetEconomy: TPlanetEconomies; // @offset $5D
    ToPlanetGovernment: TPlanetGovernments; // @offset $5E
    ToPlanetIsLastPlanet: Byte; // @offset $5F
    ToPlanetRaceIsLastPlanetRace: Byte; // @offset $60
    HomePlanetInToStar: Byte; // @offset $61
    HomePlanetInCurStar: Byte; // @offset $62
    ToStarControlByKling: Byte; // @offset $63
    ToStarInBattle: Byte; // @offset $64
    RangerInToStar: TGreetingCountMask; // @offset $65
    PirateInToStar: TGreetingCountMask; // @offset $67
    KlingInToStar: TGreetingCountMask; // @offset $69
    WarriorInToStar: TGreetingCountMask; // @offset $6B
    TransportInToStar: TGreetingCountMask; // @offset $6D
    ItemType: WideString; // @offset $70
    ShipNeedInItem: Byte; // @offset $74
    ToShipType: TGreetingMask; // @offset $75
    ToShipRace: TOwnerMask; // @offset $76
    ToShipInPlanet: Byte; // @offset $77
    ToShipBad: Byte; // @offset $78
    ToShipRelations: TRelationLevels; // @offset $79
    RankShipWithPlayerExtra: TGreetingMask; // @offset $7A Second field loaded from RankShipWithPlayer; the normal-ship consumer compares PirateRank.
    PlayerPirateRank: TGreetingMask; // @offset $7B
    Female: Byte; // @offset $7C
    ToStarControlByPirates: Byte; // @offset $7D
    PirateClanInCurStar: TGreetingCountMask; // @offset $7E
    PirateClanInToStar: TGreetingCountMask; // @offset $80
    CoalitionAlreadyDefeated: Byte; // @offset $82
    DominatorsAlreadyDefeated: Byte; // @offset $83
  end;

  // Byte predicates use 0=Yes, 1=No, 2=Any; omitted-field defaults vary by rule.
  // Native record RTTI at $526924.
  TGovGreetingsInfo = record // @size $44
    Name: WideString; // @offset $00
    Priority: Integer; // @offset $04
    PlayerRace: TOwnerMask; // @offset $08
    PlayerStatus: TRangerCareerSet; // @offset $09
    PlayerRating: TGreetingMask; // @offset $0A
    PlayerRank: TGreetingMask; // @offset $0B
    Goods: Byte; // @offset $0C
    CurPlanetRace: TOwnerMask; // @offset $0D
    CurPlanetRaceIsPlayerRace: Byte; // @offset $0E
    CurPlanetRelations: TRelationLevels; // @offset $0F
    CurPlanetGoodsPermit: Byte; // @offset $10
    CurPlanetGoodsCnt: TGreetingMask; // @offset $11
    CurPlanetGoodsSale: TGreetingMask; // @offset $12
    CurPlanetGoodsBuy: TGreetingMask; // @offset $13
    CurPlanetEconomy: TPlanetEconomies; // @offset $14
    CurPlanetGovernment: TPlanetGovernments; // @offset $15
    RangerInCurStar: TGreetingCountMask; // @offset $16
    PirateInCurStar: TGreetingCountMask; // @offset $18
    KlingInCurStar: TGreetingCountMask; // @offset $1A
    WarriorInCurStar: TGreetingCountMask; // @offset $1C
    TransportInCurStar: TGreetingCountMask; // @offset $1E
    CurStarInBattle: Byte; // @offset $20
    ToPlanetRace: TOwnerMask; // @offset $21
    ToPlanetRaceIsPlayerRace: Byte; // @offset $22
    ToPlanetRaceIsCurPlanetRace: Byte; // @offset $23
    ToPlanetRelations: TRelationLevels; // @offset $24
    ToPlanetGoodsPermit: Byte; // @offset $25
    ToPlanetGoodsCnt: TGreetingMask; // @offset $26
    ToPlanetGoodsSale: TGreetingMask; // @offset $27
    ToPlanetGoodsBuy: TGreetingMask; // @offset $28
    ToPlanetEconomy: TPlanetEconomies; // @offset $29
    ToPlanetGovernment: TPlanetGovernments; // @offset $2A
    ToPlanetInCurStar: Byte; // @offset $2B
    RangerInToStar: TGreetingCountMask; // @offset $2C
    PirateInToStar: TGreetingCountMask; // @offset $2E
    KlingInToStar: TGreetingCountMask; // @offset $30
    WarriorInToStar: TGreetingCountMask; // @offset $32
    TransportInToStar: TGreetingCountMask; // @offset $34
    ToStarControlByKling: Byte; // @offset $36
    ToStarInBattle: Byte; // @offset $37
    CurPlanetPirateClan: Byte; // @offset $38
    CurStarInBattlePirates: Byte; // @offset $39
    PirateClanInCurStar: TGreetingCountMask; // @offset $3A
    PirateClanInToStar: TGreetingCountMask; // @offset $3C
    ToStarControlByPirates: Byte; // @offset $3E
    CoalitionAlreadyDefeated: Byte; // @offset $3F
    DominatorsAlreadyDefeated: Byte; // @offset $40
    PlayerPirateRank: TGreetingMask; // @offset $41
  end;

  // Native record RTTI at $52694C.
  TPlanetAdvtUnit = record // @size $14
    Name: WideString; // @offset $00
    Image1: WideString; // @offset $04
    Image2: WideString; // @offset $08
    War: Integer; // @offset $0C Clamped to -1..1.
    Goods: Byte; // @offset $10 0..7, or 42 when absent/unrecognized.
    Owner: TOwnerMask; // @offset $11
  end;

  // Native RTTI at $5269A8 names TPlanetAdvtList: a weighted advert sequence.
  // Field-only object preserves anonymous numbering; original record/object syntax is uncertain.
  TPlanetAdvtList = object // @size $08
    Weight: Integer; // @offset $00 Numeric PlanetAdvt.List parameter name; weighted selection in TPlanetSE.StartRandomSurfaceAnimation.
    Indices: array of Integer; // @offset $04
  end;

  // Native record RTTI at $526A18.
  TPlanetAdvtGroup = record // @size $18
    Image1: WideString; // @offset $00
    Image2: WideString; // @offset $04
    Position: TPoint; // @offset $08
    Adverts: array of TPlanetAdvtUnit; // @offset $10
    Lists: array of TPlanetAdvtList; // @offset $14
  end;

  PPlanetAdvertDefinition = ^TPlanetAdvtGroup;

var
  ShipGreetingDefinitions: array of TShipGreetingsInfo; // @addr $88A774
var
  ShipGreetingCount: Integer; // @addr $88A778
  GovernmentGreetingDefinitions: array of TGovGreetingsInfo; // @addr $88A77C
var
  GovernmentGreetingCount: Integer; // @addr $88A780
  PlanetAdvertDefinitions: array of TPlanetAdvtGroup; // @addr $88A784

type
  TGovernmentGreetingDefinitions = array of TGovGreetingsInfo;

  TShipGreetingDefinitions = array of TShipGreetingsInfo;

  TPlanetAdverts = array of TPlanetAdvtUnit;

  TPlanetAdvertIndices = array of Integer;

  TPlanetAdvertLists = array of TPlanetAdvtList;

  TPlanetAdvertDefinitions = array of TPlanetAdvtGroup;

  TRobotMapDefinitions = array of TRobotMap;

  TPlanetSpaceTemplates = array of TPlanetSpaceTemplate;

implementation

// @unit-initialization $87784C
// @unit-finalization $538C4C

uses aPacket, aSaveLoad, aScript, aPath, Robot, aConst, aPlayer, GI_Main, PopUp, EC_CacheGAI, EC_Thread, EC_Cache, aGalaxy, aMyFunction, EC_BlockPar, GR_Main, EC_Str, GlobalsV, Math, SysUtils, Windows, ab_Global;

{ @routine $526AC4 InitializeScriptHostRuntime }
procedure InitializeScriptHostRuntime;
begin
  PersistentPlayerMessageLock := TCriticalSection.Create;
  SaveLoadLock := TCriticalSection.Create;
  GetLastError;
  InitializePathNodePool;
  FilmHistory := TFilmFile.Create;
  TalkRequestEvent := CreateEvent(nil, False, False, nil);
  TalkCompletedEvent := CreateEvent(nil, False, False, nil);
  ScriptUiRequestEvent := CreateEvent(nil, True, False, nil);
  ScriptUiAbortEvent := CreateEvent(nil, True, False, nil);
  TurnCalculationThread := TThreadCalc.Create;
  TurnCalculationThread.SetPriority(2);
  ScriptTemplates := TList.Create;
  GlobalScriptVariables := TVarArrayEC.Create;
  SharedScriptVariables := TVarArrayEC.Create;
  GlobalScriptVariables.Add('GRunFrom', vkInt).SetInt(0);
  GlobalScriptVariables.Add('GRunStar', vkDword).SetInt(0);
  InitializeScriptEngine;
end;
{ @end $526AC4 }

{ @routine $526C04 FinalizeScriptHostRuntime }
procedure FinalizeScriptHostRuntime;
var
  Race: TOwnerId; Kind, Series: Byte;
  Item: TObject;
  Index: Integer;
begin
  FinalizeScriptEngine;
  if GlobalScriptVariables <> nil then
  begin
    GlobalScriptVariables.Free;
    GlobalScriptVariables := nil;
  end;
  if SharedScriptVariables <> nil then
  begin
    SharedScriptVariables.Free;
    SharedScriptVariables := nil;
  end;
  if ScriptTemplates <> nil then
  begin
    for Index := 0 to ScriptTemplates.Count - 1 do
    begin
      Item := ScriptTemplates[Index];
      Item.Free;
    end;
    ScriptTemplates.Free;
    ScriptTemplates := nil;
  end;
  if TurnCalculationThread <> nil then
  begin
    TurnCalculationThread.Free;
    TurnCalculationThread := nil;
  end;
  if TalkRequestEvent <> 0 then
  begin
    CloseHandle(TalkRequestEvent);
    TalkRequestEvent := 0;
  end;
  if TalkCompletedEvent <> 0 then
  begin
    CloseHandle(TalkCompletedEvent);
    TalkCompletedEvent := 0;
  end;
  if ScriptUiRequestEvent <> 0 then
  begin
    CloseHandle(ScriptUiRequestEvent);
    ScriptUiRequestEvent := 0;
  end;
  if ScriptUiAbortEvent <> 0 then
  begin
    CloseHandle(ScriptUiAbortEvent);
    ScriptUiAbortEvent := 0;
  end;
  for Race := oiMaloc to oiPirate do
  begin
    for Kind := 0 to 5 do
      if RaceShipTemplates[Race, Kind] <> nil then
        ReleaseSpaceObject(RaceShipTemplates[Race, Kind]);
    if PirateClanShipTemplates[Race] <> nil then
      ReleaseSpaceObject(PirateClanShipTemplates[Race]);
  end;
  for Series := 0 to 7 do
    if Series <> 0 then
    begin
      if BlazerShipTemplates[Series] <> nil then ReleaseSpaceObject(BlazerShipTemplates[Series]);
      if KellerShipTemplates[Series] <> nil then ReleaseSpaceObject(KellerShipTemplates[Series]);
      if TerronShipTemplates[Series] <> nil then ReleaseSpaceObject(TerronShipTemplates[Series]);
    end;
  if FilmHistory <> nil then
  begin
    FilmHistory.Free;
    FilmHistory := nil;
  end;
  FinalizePathNodePool;
  if SaveLoadLock <> nil then
  begin
    SaveLoadLock.Free;
    SaveLoadLock := nil;
  end;
  if PersistentPlayerMessageLock <> nil then
  begin
    PersistentPlayerMessageLock.Free;
    PersistentPlayerMessageLock := nil;
  end;
end;
{ @end $526C04 }

var
  ScriptVariableTypeNames: array[0..10] of WideString = (
    'Unknown', 'Int', 'DW', 'Float', 'Str', 'ExternFun', 'LibraryFun',
    'Fun', 'Class', 'Array', 'Ref'); // @addr $87AEA8 Native initialization descriptors at $538D8C..$538DDC.

{ @routine $526F10 InitializeGlobalUiRuntime }
procedure InitializeGlobalUiRuntime;
var
  Race: TOwnerId;
  Index, TemplateIndex, Count: Integer;
  SatelliteTemplate: TSputnikTempl;
  PlanetTemplate: TPlanetTempl;
  Section: TBlockParEC;
  Series, Kind: Byte;
  ScriptTemplate: TScriptTemplUnit;
  Text, WarningText: WideString;
  ShipBlock: TBlockParEC;
  Variable, Other: TVarEC;
begin
  CacheLoader := TCacheLoader.Create;
  InitializeSaveWriter;
  RangerFontName := 'Font.2Ranger';
  MiniFontName := 'Font.2Mini';
  SmallFontName := 'Font.2Small';
  SmallBoldFontName := 'Font.2SmallBold';
  NormalFontName := 'Font.2Normal';
  NormalBoldFontName := 'Font.2NormalBold';
  BigFontName := 'Font.2Big';
  HugeFontName := 'Font.2Huge';
  IntroFontName := 'Font.2Intro';
  AuthorsFontName := 'Font.2Authors';
  SmoothSmallFontName := 'Font.Verdana8';
  SmoothSmallBoldFontName := 'Font.Verdana8bold';
  SmoothNormalFontName := 'Font.Verdana9';
  SmoothNormalBoldFontName := 'Font.Verdana9bold';
  SmoothBigFontName := 'Font.Verdana11';
  SmoothHugeFontName := 'Font.Verdana12';
  SmoothIntroFontName := 'Font.Verdana13';
  if UserSettingsConfig.CountParamsByPath('ChangeAutoPilot') > 0 then
    ChangeAutoPilot := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('ChangeAutoPilot'));
  if UserSettingsConfig.CountParams('AltResolutionSwitch') > 0 then
    AltResolutionSwitch := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AltResolutionSwitch'));
  if UserSettingsConfig.CountParamsByPath('DisableAutoPilot') > 0 then
    DisableAutoPilot := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('DisableAutoPilot'));
  AwardDialogsEnabled := True;
  if UserSettingsConfig.CountParamsByPath('PQuestStyle') > 0 then
    QuestStyleIndex := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('PQuestStyle'));
  if UserSettingsConfig.CountParamsByPath('PQuestAnim') > 0 then
    QuestPageAnimationEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('PQuestAnim'));
  if UserSettingsConfig.CountParamsByPath('DefaultOrder') > 0 then
    DefaultOrder := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('DefaultOrder'));
  if UserSettingsConfig.CountParamsByPath('RightClickOnShip') > 0 then
    RightClickOnShip := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('RightClickOnShip'));
  if UserSettingsConfig.CountParamsByPath('DoNotChangeMusicInBattle') > 0 then
    DoNotChangeMusicInBattle := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('DoNotChangeMusicInBattle'));
  if UserSettingsConfig.CountParamsByPath('ViewFollowShip') > 0 then
    ViewFollowShip := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('ViewFollowShip'));
  if UserSettingsConfig.CountParamsByPath('ViewPathLength') > 0 then
    ViewPathLength := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('ViewPathLength'));
  if UserSettingsConfig.CountParamsByPath('TurnSaveStep') > 0 then
    TurnSaveStep := Min(TurnsPerYear, ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('TurnSaveStep')));
  if UserSettingsConfig.CountParamsByPath('QuickSaveExtraSlots') > 0 then
    QuickSaveExtraSlots := Min(9, ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('QuickSaveExtraSlots')));
  if UserSettingsConfig.CountParamsByPath('MaxPlayerNews') > 0 then
    MaxPlayerNews := Min(100, ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('MaxPlayerNews')));
  if UserSettingsConfig.CountParamsByPath('ForsageDeactivatePercent') > 0 then
    AfterburnerStopCondition := Min(100, ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('ForsageDeactivatePercent')));
  if UserSettingsConfig.CountParamsByPath('MaxSearchResult') > 0 then
    MaxSearchResult := Min(100, ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('MaxSearchResult')));
  if UserSettingsConfig.CountParamsByPath('ClickAutoCloseForm') > 0 then
    ClickAutoCloseForm := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('ClickAutoCloseForm'));
  if UserSettingsConfig.CountParamsByPath('ActionDoubleClick') > 0 then
    ActionDoubleClick := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('ActionDoubleClick'));
  if UserSettingsConfig.CountParamsByPath('SkipGiper') > 0 then
    SkipGiper := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('SkipGiper'));
  Text := 'e';
  Text := Text + 's';
  Text := Text + 't';
  if UserSettingsConfig.CountParamsByPath(Text) > 0 then
    EstOptionEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker(Text));
  if UserSettingsConfig.CountParamsByPath('SendRecordOff') > 0 then
    SendRecordOff := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('SendRecordOff'));
  if UserSettingsConfig.CountParamsByPath('Wind') > 0 then
    Wind := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('Wind'));
  if UserSettingsConfig.CountParamsByPath('Skip1C') > 0 then
    Skip1C := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('Skip1C'));
  if UserSettingsConfig.CountParamsByPath('SkipVideo') > 0 then
    SkipVideo := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('SkipVideo'));
  if UserSettingsConfig.CountParamsByPath('SkipIntro') > 0 then
    SkipIntro := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('SkipIntro'));
  if UserSettingsConfig.CountParamsByPath('ShipTail') > 0 then
    ShipTail := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('ShipTail'));
  if UserSettingsConfig.CountParamsByPath('AnimCaptain') > 0 then
    AnimCaptain := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimCaptain'));
  if UserSettingsConfig.CountParamsByPath('AnimItem') > 0 then
    AnimItem := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimItem'));
  if UserSettingsConfig.CountParamsByPath('BGImage') > 0 then
    BGImage := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('BGImage'));
  if UserSettingsConfig.CountParamsByPath('Comet') > 0 then
    Comet := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('Comet'));
  if UserSettingsConfig.CountParamsByPath('AnimShipFull') > 0 then
    AnimShipFull := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimShipFull'));
  if UserSettingsConfig.CountParamsByPath('AnimCity') > 0 then
    AnimCity := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimCity'));
  if UserSettingsConfig.CountParamsByPath('AnimGov') > 0 then
    AnimGov := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('AnimGov'));
  if UserSettingsConfig.CountParamsByPath('AnimMenuShip') > 0 then
    AnimMenuShip := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimMenuShip'));
  if UserSettingsConfig.CountParamsByPath('AnimStar') > 0 then
    AnimStar := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimStar'));
  if UserSettingsConfig.CountParamsByPath('AnimHangar') > 0 then
    AnimHangar := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimHangar'));
  if UserSettingsConfig.CountParamsByPath('CircleAction') > 0 then
    CircleAction := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('CircleAction'));
  if UserSettingsConfig.CountParamsByPath('StaticBackground') > 0 then
    StaticBackground := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('StaticBackground'));
  if UserSettingsConfig.CountParamsByPath('ScrollTime') > 0 then
    ScrollTime := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('ScrollTime')));
  if UserSettingsConfig.CountParamsByPath('ScrollStep') > 0 then
    ScrollStep := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('ScrollStep')));
  if UserSettingsConfig.CountParamsByPath('ScrollSense') > 0 then
    ScrollSense := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('ScrollSense')));
  if UserSettingsConfig.CountParamsByPath('FilmSpeed') > 0 then
    FilmSpeed := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('FilmSpeed')));
  ScrollInteriorRect := Classes.Rect(ScrollSense, ScrollSense, GameScreenWidth - ScrollSense, GameScreenHeight - ScrollSense);
  if not IsInstallFeatureEnabled('AnimGov') then AnimGov := 0;
  if not IsInstallFeatureEnabled('AnimCaptain') then AnimCaptain := False;
  if not IsInstallFeatureEnabled('Video') then
  begin
    SkipVideo := True;
    SkipIntro := True;
  end;
  if UserSettingsConfig.CountParamsByPath('BGOCount') > 0 then
    BGOCount := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('BGOCount')));
  if UserSettingsConfig.CountParamsByPath('BGOTime') > 0 then
    BGOTime := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('BGOTime')));
  if UserSettingsConfig.CountParamsByPath('MaxFilmStepSkip') > 0 then
    MaxFilmStepSkip := StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('MaxFilmStepSkip')));
  if UserSettingsConfig.CountParamsByPath('CountFilmSave') > 0 then
    FilmHistoryLimit := Max(1, StrToInt(AnsiString(UserSettingsConfig.GetParamByPathOrMarker('CountFilmSave'))));
  if UserSettingsConfig.CountParamsByPath('SputnikShow') > 0 then
    SputnikShow := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('SputnikShow'));
  if UserSettingsConfig.CountParamsByPath('SpaceImage') > 0 then
    SpaceImage := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('SpaceImage'));
  if UserSettingsConfig.CountParamsByPath('ShowFPS') > 0 then
    ShowFrameRate := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('ShowFPS'));
  if UserSettingsConfig.CountParamsByPath('FontGalaxy') > 0 then
    GalaxyMapFontChoice := TGalaxyMapFontChoice(ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('FontGalaxy')));
  if UserSettingsConfig.CountParamsByPath('FontDialog') > 0 then
    FontDialog := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('FontDialog'));
  if UserSettingsConfig.CountParamsByPath('FontQuest') > 0 then
    FontQuest := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('FontQuest'));
  if UserSettingsConfig.CountParamsByPath('FontSmooth') > 0 then
    FontSmoothingEnabled := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('FontSmooth'));
  if UserSettingsConfig.CountParamsByPath('ScreenShotType') > 0 then
    ScreenshotFormat := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('ScreenShotType'));
  if UserSettingsConfig.CountParamsByPath('ScreenShotQuality') > 0 then
    ScreenshotJpegQuality := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('ScreenShotQuality'));
  if UserSettingsConfig.CountParamsByPath('DynamicTipsPos') > 0 then
    DynamicTipsPos := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('DynamicTipsPos'));
  if UserSettingsConfig.CountParamsByPath('BackgroundShade') > 0 then
    BackgroundShade := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('BackgroundShade'));
  if UserSettingsConfig.CountParamsByPath('BackgroundBlur') > 0 then
    BackgroundBlur := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('BackgroundBlur'));
  if UserSettingsConfig.CountParamsByPath('BackgroundGrayscale') > 0 then
    BackgroundGrayscale := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('BackgroundGrayscale'));
  if UserSettingsConfig.CountParamsByPath('PlanetClouds') > 0 then
    PlanetClouds := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('PlanetClouds'));
  if UserSettingsConfig.CountParamsByPath('PlanetAtm') > 0 then
    PlanetAtm := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('PlanetAtm'));
  if UserSettingsConfig.CountParamsByPath('AnimChangeForm') > 0 then
    AnimChangeForm := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimChangeForm'));
  if UserSettingsConfig.CountParamsByPath('AnimMainFon') > 0 then
    AnimMainFon := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('AnimMainFon'));
  if UserSettingsConfig.CountParamsByPath('BeginCalcNextTurn') > 0 then
    BeginCalcNextTurn := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('BeginCalcNextTurn')) / 100;
  if BeginCalcNextTurn < 0 then BeginCalcNextTurn := 0
  else if BeginCalcNextTurn > 1 then BeginCalcNextTurn := 1;
  if UserSettingsConfig.CountParamsByPath('HalfGovAnim') > 0 then
    HalfGovAnim := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('HalfGovAnim'));
  if UserSettingsConfig.CountParamsByPath('UseTablesForGov') > 0 then
    UseTablesForGov := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('UseTablesForGov'));
  if UserSettingsConfig.CountParamsByPath('RobotShowStencilShadows') > 0 then
    RobotSettings.ShowStencilShadows := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotShowStencilShadows'));
  if UserSettingsConfig.CountParamsByPath('RobotShowProjShadows') > 0 then
    RobotSettings.ShowProjShadows := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotShowProjShadows'));
  if UserSettingsConfig.CountParamsByPath('RobotSelectEx') > 0 then
    RobotSettings.SelectEx := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotSelectEx'));
  if UserSettingsConfig.CountParamsByPath('RobotLandTexturesGloss') > 0 then
    RobotSettings.LandTexturesGloss := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotLandTexturesGloss'));
  if UserSettingsConfig.CountParamsByPath('RobotObjTexturesGloss') > 0 then
    RobotSettings.ObjTexturesGloss := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotObjTexturesGloss'));
  if UserSettingsConfig.CountParamsByPath('RobotSoftwareCursor') > 0 then
    RobotSettings.SoftwareCursor := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotSoftwareCursor'));
  if UserSettingsConfig.CountParamsByPath('RobotSky') > 0 then
    RobotSettings.Sky := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('RobotSky'));
  if UserSettingsConfig.CountParamsByPath('RobotRobotShadow') > 0 then
    RobotSettings.RobotShadow := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('RobotRobotShadow'));
  if UserSettingsConfig.CountParamsByPath('RobotSound') > 0 then
    RobotSound := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotSound'));
  if UserSettingsConfig.CountParamsByPath('RobotMusic') > 0 then
    RobotMusic := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotMusic'));
  if UserSettingsConfig.CountParamsByPath('RobotVSync') > 0 then
    RobotVSync := ParseEnabledNameGI(UserSettingsConfig.GetParamByPathOrMarker('RobotVSync'));
  if UserSettingsConfig.CountParamsByPath('RobotFSAASamples') > 0 then
    RobotFSAASamples := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('RobotFSAASamples'));
  if UserSettingsConfig.CountParamsByPath('RobotAnisotropy') > 0 then
    RobotAnisotropy := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('RobotAnisotropy'));
  if UserSettingsConfig.CountParamsByPath('RobotMaxDistance') > 0 then
    RobotMaxDistance := ExtractDigitsToIntW(UserSettingsConfig.GetParamByPathOrMarker('RobotMaxDistance'));
  if ReloadScriptTemplates then
  begin
    Section := GameDataConfig.GetBlockByPath('Script');
    Count := Section.GetParamCount;
    for Index := 0 to Count - 1 do
    begin
      if FindScriptTemplateIndex(Section.GetParamName(Index)) >= 0 then
        raise Exception.Create('Script name not unique');
      ScriptTemplate := TScriptTemplUnit.Create;
      ScriptTemplate.Name := Section.GetParamName(Index);
      Text := Section.GetParamValue(Index);
      ScriptTemplate.ClassId := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
      ScriptTemplate.FileName := ExtractDelimitedPartW(Text, 1, ',');
      ScriptTemplates.Add(ScriptTemplate);
      CompileScriptTemplateCondition(ScriptTemplates.Count - 1);
    end;
    for Index := GlobalScriptVariables.Count - 2 downto 0 do
    begin
      Variable := GlobalScriptVariables.GetItemByNameOrder(Index);
      Other := GlobalScriptVariables.GetItemByNameOrder(Index + 1);
      if Variable.Name = Other.Name then
      begin
        if Variable.RealVType <> Other.RealVType then
        begin
          WarningText := 'Warning! Mismatching global variables with same name <' + Variable.Name + '> found! Types are ' +
            ScriptVariableTypeNames[Ord(Variable.RealVType)] + ' and ' +
            ScriptVariableTypeNames[Ord(Other.RealVType)];
          if Variable.RealVType = vkEmpty then
          begin
            WarningText := WarningText + ', ' + ScriptVariableTypeNames[Ord(Variable.RealVType)] + ' will be discarded';
            GlobalScriptVariables.Remove(Variable);
          end
          else
          begin
            WarningText := WarningText + ', ' + ScriptVariableTypeNames[Ord(Other.RealVType)] + ' will be discarded';
            GlobalScriptVariables.Remove(Other);
          end;
          AppendLogLineThreadSafe(AnsiString(WarningText));
        end
        else
        begin
          if Variable.EqualsValue(Other) or not (Variable.RealVType in [vkInt, vkDword, vkFloat, vkString]) then
            GlobalScriptVariables.Remove(Other)
          else
          begin
            WarningText := 'Warning! Mismatching global variables with same name <' + Variable.Name + '> found! Initial values are ' +
              Variable.GetString + ' and ' + Other.GetString + '. Value ' + Variable.GetString + ' will be used';
            GlobalScriptVariables.Remove(Other);
          end;
        end;
      end;
    end;
  end;
  if ReloadScriptTemplates then
  begin
    for Race := oiMaloc to oiPirate do
    begin
      ShipBlock := GameDataConfig.GetBlockByPath('SE.Ship').FindBlock(OwnerInfo[Race].InternalName);
      for Kind := 0 to 5 do RaceShipTemplates[Race, Kind] := nil;
      PirateClanShipTemplates[Race] := nil;
      if ShipBlock <> nil then
      begin
        if ShipBlock.CountBlocks('Ranger') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, 0], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Ranger', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Warrior') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, 1], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Warrior', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Pirate') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, 2], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Pirate', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Transport') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, 3], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Transport', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Liner') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, 4], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Liner', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Diplomat') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, 5], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Diplomat', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('PirateClan') > 0 then
          RetainSpaceObject(PirateClanShipTemplates[Race], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.PirateClan', Classes.Point(0, 0)));
      end;
    end;
    Index := 1;
    for Series := 0 to 7 do
      if Series <> 0 then
      begin
        RetainSpaceObject(BlazerShipTemplates[Series], CreateSpaceObjectByName('Ship2', WideString('Ship.Blazer.B' + IntToStr(Index)), Classes.Point(0, 0)));
        RetainSpaceObject(KellerShipTemplates[Series], CreateSpaceObjectByName('Ship2', WideString('Ship.Keller.K' + IntToStr(Index)), Classes.Point(0, 0)));
        RetainSpaceObject(TerronShipTemplates[Series], CreateSpaceObjectByName('Ship2', WideString('Ship.Terron.T' + IntToStr(Index)), Classes.Point(0, 0)));
        Inc(Index);
      end;
  end;
  Count := GameDataConfig.GetBlockByPath('SE.Planet').GetBlockCount;
  for Index := 0 to Count - 1 do
  begin
    Section := GameDataConfig.GetBlockByPath('SE.Planet').GetBlockByIndex(Index);
    if Section.CountParams('Image') <= 0 then Dec(Count);
  end;
  SetLength(PlanetSpaceTemplates, Count);
  Count := GameDataConfig.GetBlockByPath('SE.Planet').GetBlockCount;
  TemplateIndex := 0;
  for Index := 0 to Count - 1 do
  begin
    Section := GameDataConfig.GetBlockByPath('SE.Planet').GetBlockByIndex(Index);
    if Section.CountParams('Image') > 0 then
    begin
      RetainSpaceObject(PlanetSpaceTemplates[TemplateIndex].SpaceObject,
        CreateSpaceObjectByName('Planet', 'Planet.' + GameDataConfig.GetBlockByPath('SE.Planet').GetBlockNameByIndex(Index), Classes.Point(0, 0)));
      PlanetSpaceTemplates[TemplateIndex].Radius := StrToInt(AnsiString(Section.GetParam('Radius')));
      PlanetSpaceTemplates[TemplateIndex].Style := 0;
      PlanetSpaceTemplates[TemplateIndex].StyleVariant := 0;
      if Section.CountParams('Style') > 0 then
      begin
        Text := Section.GetParam('Style');
        PlanetSpaceTemplates[TemplateIndex].Style := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
        if CountDelimitedPartsW(Text, ',') >= 2 then
          PlanetSpaceTemplates[TemplateIndex].StyleVariant := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, ','));
      end;
      Inc(TemplateIndex);
    end;
  end;
  PopupController := TfPopUpController.Create;
  LoadScreen := TfLoad.Create;
  RegisteredScreens[screenLoad] := LoadScreen;
  LoadScreen.InitializeFromConfig(UiStyleConfig, 'Load', True);
  LoadScreen.InitializeLayout;
  MainMenuScreen := TfMainForm.Create;
  RegisteredScreens[screenMainMenu] := MainMenuScreen;
  MainMenuScreen.InitializeFromConfig(UiStyleConfig, 'MainForm', True);
  PlanetQuestScreen := TfPlanetQuest.Create;
  RegisteredScreens[screenPlanetQuest] := PlanetQuestScreen;
  PlanetQuestScreen.InitializeFromConfig(UiStyleConfig, 'PlanetQuest', True);
  GameLoadScreen := TfGameLoad.Create;
  RegisteredScreens[screenGameLoad] := GameLoadScreen;
  GameLoadScreen.InitializeFromConfig(UiStyleConfig, 'GameLoad', True);
  NewGameScreen := TfGameSettings2.Create;
  RegisteredScreens[screenNewGame] := NewGameScreen;
  NewGameScreen.InitializeFromConfig(UiStyleConfig, 'GameSettings', True);
  IntroductionScreen := TfIntroduction.Create;
  RegisteredScreens[screenIntroduction] := IntroductionScreen;
  IntroductionScreen.InitializeFromConfig(UiStyleConfig, 'Introduction', True);
  HangarScreen := TfHangar.Create;
  RegisteredScreens[screenHangar] := HangarScreen;
  HangarScreen.InitializeFromConfig(UiStyleConfig, 'Hangar', True);
  PlanetScreen := TfPlanet.Create;
  RegisteredScreens[screenPlanet] := PlanetScreen;
  PlanetScreen.InitializeFromConfig(UiStyleConfig, 'Planet', True);
  UninhabitedPlanetScreen := TfPlanetNO.Create;
  RegisteredScreens[screenPlanetNO] := UninhabitedPlanetScreen;
  UninhabitedPlanetScreen.InitializeFromConfig(UiStyleConfig, 'PlanetNO', True);
  RuinsTalkScreen := TfRuinsTalk.Create;
  RegisteredScreens[screenRuinsTalk] := RuinsTalkScreen;
  RuinsTalkScreen.InitializeFromConfig(UiStyleConfig, 'RuinsTalk', True);
  ArcadeBattleScreen := TfAB.Create;
  RegisteredScreens[screenArcadeBattle] := ArcadeBattleScreen;
  ArcadeBattleScreen.InitializeFromConfig(UiStyleConfig, 'AB', True);
  GovernmentScreen := TfGov.Create;
  RegisteredScreens[screenGovernment] := GovernmentScreen;
  GovernmentScreen.InitializeFromConfig(UiStyleConfig, 'Gov', True);
  InfoScreen := TfInfo.Create;
  RegisteredScreens[screenInfo] := InfoScreen;
  InfoScreen.InitializeFromConfig(UiStyleConfig, 'Info', True);
  RangerRatingScreen := TfRating2.Create;
  RegisteredScreens[screenRating] := RangerRatingScreen;
  RangerRatingScreen.InitializeFromConfig(UiStyleConfig, 'Rating', True);
  RewardsScreen := TfRewards.Create;
  RegisteredScreens[screenRewards] := RewardsScreen;
  RewardsScreen.InitializeFromConfig(UiStyleConfig, 'Rewards', True);
  ShipScreen := TfShip2.Create;
  RegisteredScreens[screenShip] := ShipScreen;
  ShipScreen.InitializeFromConfig(UiStyleConfig, 'Ship', True);
  TalkScreen := TfTalk.Create;
  RegisteredScreens[screenTalk] := TalkScreen;
  TalkScreen.InitializeFromConfig(UiStyleConfig, 'Talk', True);
  ScannerScreen := TfScaner.Create;
  RegisteredScreens[screenScanner] := ScannerScreen;
  ScannerScreen.InitializeFromConfig(UiStyleConfig, 'Scaner', True);
  StarMapScreen := TfStarMap.Create;
  RegisteredScreens[screenStarMap] := StarMapScreen;
  StarMapScreen.InitializeFromConfig(UiStyleConfig, 'StarMap', True);
  FilmScreen := TfFilm.Create;
  RegisteredScreens[screenFilm] := FilmScreen;
  FilmScreen.InitializeFromConfig(UiStyleConfig, 'Film', True);
  GalaxyScreen := TfGalaxy2.Create;
  RegisteredScreens[screenGalaxy] := GalaxyScreen;
  GalaxyScreen.InitializeFromConfig(UiStyleConfig, 'Galaxy', True);
  JumpScreen := TfJump.Create;
  RegisteredScreens[screenJump] := JumpScreen;
  JumpScreen.InitializeFromConfig(UiStyleConfig, 'Jump', True);
  EquipmentShopScreen := TfEquipmentShop.Create;
  RegisteredScreens[screenEquipmentShop] := EquipmentShopScreen;
  EquipmentShopScreen.InitializeFromConfig(UiStyleConfig, 'EquipmentShop', True);
  GoodsShopScreen := TfGoodsShop2.Create;
  RegisteredScreens[screenGoodsShop] := GoodsShopScreen;
  GoodsShopScreen.InitializeFromConfig(UiStyleConfig, 'GoodsShop', True);
  SaveManagerScreen := TfSaveManager.Create;
  RegisteredScreens[screenSaveManager] := SaveManagerScreen;
  SaveManagerScreen.InitializeFromConfig(UiStyleConfig, 'SaveManager', True);
  GameMenuScreen := TfGameMenu.Create;
  RegisteredScreens[screenGameMenu] := GameMenuScreen;
  GameMenuScreen.InitializeFromConfig(UiStyleConfig, 'GameMenu', True);
  SettingsScreen := TfCfgSettings.Create;
  RegisteredScreens[screenSettings] := SettingsScreen;
  SettingsScreen.InitializeFromConfig(UiStyleConfig, 'CfgSettings', True);
  GameEndScreen := TfGameEnd.Create;
  RegisteredScreens[screenGameEnd] := GameEndScreen;
  GameEndScreen.InitializeFromConfig(UiStyleConfig, 'GameEnd', True);
  AboutScreen := TfAbout.Create;
  RegisteredScreens[screenAbout] := AboutScreen;
  AboutScreen.InitializeFromConfig(UiStyleConfig, 'About', True);
  ScoreScreen := TfScore.Create;
  RegisteredScreens[screenScores] := ScoreScreen;
  ScoreScreen.InitializeFromConfig(UiStyleConfig, 'Score', True);
  SelectFaceScreen := TfSelectFace.Create;
  RegisteredScreens[screenSelectFace] := SelectFaceScreen;
  SelectFaceScreen.InitializeFromConfig(UiStyleConfig, 'SelectFace', True);
  JournalScreen := TfJournal.Create;
  RegisteredScreens[screenJournal] := JournalScreen;
  JournalScreen.InitializeFromConfig(UiStyleConfig, 'Journal', True);
  LoadRobotScreen := TfLoadRobot.Create;
  RegisteredScreens[screenLoadRobot] := LoadRobotScreen;
  LoadRobotScreen.InitializeFromConfig(UiStyleConfig, 'LoadRobot', True);
  LoadQuestScreen := TfLoadQuest.Create;
  RegisteredScreens[screenLoadQuest] := LoadQuestScreen;
  LoadQuestScreen.InitializeFromConfig(UiStyleConfig, 'LoadQuest', True);
  LoadArcadeScreen := TfLoadAB.Create;
  RegisteredScreens[screenLoadArcade] := LoadArcadeScreen;
  LoadArcadeScreen.InitializeFromConfig(UiStyleConfig, 'LoadAB', True);
  AchievementsScreen := TfAchievements.Create;
  RegisteredScreens[screenAchievements] := AchievementsScreen;
  AchievementsScreen.InitializeFromConfig(UiStyleConfig, 'Achievements', True);
  SpaceObjectUiLoop := TMessageLoopGI.Create;
  SpaceObjectUiLoop.InitializeDefaults;
  SpaceObjectUiLoop.ViewportRect := Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height);
  SpaceObjectUiLoop.UpdateRectsEnabled := False;
  SpaceObjectUiLoop.ContentPanel.SetOrigin(Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1));
  SpaceObjectUiLoop.ContentPanel.SetPosition(Classes.Point(RenderScratchBuffer.Width shr 1, RenderScratchBuffer.Height shr 1));
  PrimaryFilm := TEFilm.Create;
  SecondaryFilm := TEFilm.Create;
  RecreateSpaceProcess('Process.Normal');
  PlanetRenderTemplates := TList.Create;
  PlanetTemplate := TPlanetTempl.Create;
  PlanetRenderTemplates.Add(PlanetTemplate);
  PlanetTemplate.Radius := 33;
  PlanetTemplate.SmallMaskName := 'Bm.Planet.S.Mask052';
  PlanetTemplate.SmallLightName := 'Bm.Planet.S.Light052';
  PlanetTemplate.MaskName := 'Bm.Planet.S.Mask066';
  PlanetTemplate.LightName := 'Bm.Planet.S.Light066';
  PlanetTemplate := TPlanetTempl.Create;
  PlanetRenderTemplates.Add(PlanetTemplate);
  PlanetTemplate.Radius := 60;
  PlanetTemplate.SmallMaskName := 'Bm.Planet.S.Mask094';
  PlanetTemplate.SmallLightName := 'Bm.Planet.S.Light094';
  PlanetTemplate.MaskName := 'Bm.Planet.S.Mask120';
  PlanetTemplate.LightName := 'Bm.Planet.S.Light120';
  PlanetTemplate := TPlanetTempl.Create;
  PlanetRenderTemplates.Add(PlanetTemplate);
  PlanetTemplate.Radius := 70;
  PlanetTemplate.SmallMaskName := 'Bm.Planet.S.Mask108';
  PlanetTemplate.SmallLightName := 'Bm.Planet.S.Light108';
  PlanetTemplate.MaskName := 'Bm.Planet.S.Mask140';
  PlanetTemplate.LightName := 'Bm.Planet.S.Light140';
  PlanetTemplate := TPlanetTempl.Create;
  PlanetRenderTemplates.Add(PlanetTemplate);
  PlanetTemplate.Radius := 80;
  PlanetTemplate.SmallMaskName := 'Bm.Planet.S.Mask124';
  PlanetTemplate.SmallLightName := 'Bm.Planet.S.Light124';
  PlanetTemplate.MaskName := 'Bm.Planet.S.Mask160';
  PlanetTemplate.LightName := 'Bm.Planet.S.Light160';
  PlanetTemplate := TPlanetTempl.Create;
  PlanetRenderTemplates.Add(PlanetTemplate);
  PlanetTemplate.Radius := 90;
  PlanetTemplate.SmallMaskName := 'Bm.Planet.S.Mask142';
  PlanetTemplate.SmallLightName := 'Bm.Planet.S.Light142';
  PlanetTemplate.MaskName := 'Bm.Planet.S.Mask180';
  PlanetTemplate.LightName := 'Bm.Planet.S.Light180';
  PlanetTemplate := TPlanetTempl.Create;
  PlanetRenderTemplates.Add(PlanetTemplate);
  PlanetTemplate.Radius := 100;
  PlanetTemplate.SmallMaskName := 'Bm.Planet.S.Mask156';
  PlanetTemplate.SmallLightName := 'Bm.Planet.S.Light156';
  PlanetTemplate.MaskName := 'Bm.Planet.S.Mask200';
  PlanetTemplate.LightName := 'Bm.Planet.S.Light200';
  SatelliteRenderTemplates := TList.Create;
  Index := MinimumSatelliteTemplateRadius;
  while not (Index > MaximumSatelliteTemplateRadius) do
  begin
    SatelliteTemplate := TSputnikTempl.Create;
    SatelliteRenderTemplates.Add(SatelliteTemplate);
    SatelliteTemplate.MaskName := WideString('Bm.Planet.S.Mask0' + IntToStr(Index) + '?' + IntToStr(SatelliteTemplateParameter1) + ',' + IntToStr(SatelliteTemplateParameter2));
    SatelliteTemplate.Radius := Index;
    Inc(Index);
  end;
  Section := GameDataConfig.GetBlock('SpaceImg');
  Count := Section.GetParamCount;
  SetLength(SpaceImageTemplates, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := Section.GetParamValue(Index);
    if CountDelimitedPartsW(Text, ',') < 2 then raise Exception.Create('Error in GlobalsInit');
    SpaceImageTemplates[Index].Kind := ExtractDigitsToIntW(Section.GetParamName(Index));
    SpaceImageTemplates[Index].Weight := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
    SpaceImageTemplates[Index].CacheControl := TCGaiControlEC.Create;
    SpaceImageTemplates[Index].CachedData := nil;
    GlobalCache.ResetControl(TCGaiControlEC(SpaceImageTemplates[Index].CacheControl));
    TCGaiControlEC(SpaceImageTemplates[Index].CacheControl).SetCacheKey(ExtractDelimitedPartW(Text, 1, ','));
  end;
  Section := GameDataConfig.GetBlock('StarFieldImg');
  Count := Section.GetParamCount;
  SetLength(StarFieldImageTemplates, Count);
  for Index := 0 to Count - 1 do
  begin
    StarFieldImageTemplates[Index].Weight := ExtractDigitsToIntW(Section.GetParamName(Index));
    StarFieldImageTemplates[Index].CacheControl := TCGaiControlEC.Create;
    StarFieldImageTemplates[Index].CachedData := nil;
    GlobalCache.ResetControl(TCGaiControlEC(StarFieldImageTemplates[Index].CacheControl));
    TCGaiControlEC(StarFieldImageTemplates[Index].CacheControl).SetCacheKey(Section.GetParamValue(Index));
  end;
  ReloadScriptTemplates := False;
  InitializeGameplayConfig;
  InitializeShipGreetingDefinitions;
  InitializeGovernmentGreetingDefinitions;
  InitializePlanetAdvertDefinitions;
  InitializeRobotMapDefinitions;
  UselessItemRemainsCount := StrToInt(AnsiString(LookupLocalizedTextByKey('UselessItems.CntRemains')));
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('Explosion');
  Count := Section.GetParamCount;
  SetLength(ArcadeExplosionSounds, Count);
  for Index := 0 to Count - 1 do ArcadeExplosionSounds[Index] := Section.GetParamValue(Index);
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('Hit');
  Count := Section.GetParamCount;
  SetLength(ArcadeHitSounds, Count);
  for Index := 0 to Count - 1 do ArcadeHitSounds[Index] := Section.GetParamValue(Index);
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('Item');
  Count := Section.GetParamCount;
  SetLength(ArcadeItemSounds, Count);
  for Index := 0 to Count - 1 do ArcadeItemSounds[Index] := Section.GetParamValue(Index);
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('WeaponFirst');
  for Index := 0 to 17 do
    if Section.CountParams(WideString(IntToStr(Index))) <= 0 then
      ArcadeWeaponFirstSounds[Index] := ''
    else ArcadeWeaponFirstSounds[Index] := Section.GetParam(WideString(IntToStr(Index)));
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('WeaponLoop');
  for Index := 0 to 17 do
    if Section.CountParams(WideString(IntToStr(Index))) <= 0 then
    begin
      ArcadeWeaponLoopSounds[Index] := '';
      ArcadeWeaponLoopTicks[Index] := -1;
    end
    else
    begin
      Text := Section.GetParam(WideString(IntToStr(Index)));
      ArcadeWeaponLoopTicks[Index] := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ',')) div ArcadeTickMs;
      ArcadeWeaponLoopSounds[Index] := ExtractDelimitedPartW(Text, 1, ',');
    end;
end;
{ @end $526F10 }

{ @routine $52BE1C FindMessageLoop }
function FindMessageLoop(Name: WideString): TMessageLoopGI;
var
  Index: TGameScreenId;
begin
  Result := nil;
  for Index := Low(TGameScreenId) to High(TGameScreenId) do
    if (TMessageLoopGI(RegisteredScreens[Index]) <> nil) and
       (TObject(RegisteredScreens[Index]) is TMessageLoopGI) and
       ((TObject(RegisteredScreens[Index]) as TMessageLoopGI).RegisteredLoopName = Name) then
    begin
      Result := TMessageLoopGI(RegisteredScreens[Index]);
      Break;
    end;
end;
{ @end $52BE1C }

{ @routine $52BED8 FinalizeGlobalUiRuntime }
procedure FinalizeGlobalUiRuntime;
var
  Index, Count: Integer;
  SatelliteTemplate: TSputnikTempl;
  PlanetTemplate: TPlanetTempl;
  ScreenIndex: TGameScreenId;
  Slot: TShopSlot;
begin
  ArcadeHitSounds := nil;
  ArcadeExplosionSounds := nil;
  ArcadeItemSounds := nil;
  Count := High(SpaceImageTemplates) + 1;
  for Index := 0 to Count - 1 do
    if TCGaiControlEC(SpaceImageTemplates[Index].CacheControl) <> nil then
    begin
      TCGaiControlEC(SpaceImageTemplates[Index].CacheControl).Free;
      SpaceImageTemplates[Index].CacheControl := nil;
    end;
  SpaceImageTemplates := nil;
  Count := High(StarFieldImageTemplates) + 1;
  for Index := 0 to Count - 1 do
    if TCGaiControlEC(StarFieldImageTemplates[Index].CacheControl) <> nil then
    begin
      TCGaiControlEC(StarFieldImageTemplates[Index].CacheControl).Free;
      StarFieldImageTemplates[Index].CacheControl := nil;
    end;
  StarFieldImageTemplates := nil;
  if PlanetRenderTemplates <> nil then
  begin
    Count := PlanetRenderTemplates.Count;
    for Index := 0 to Count - 1 do
    begin
      PlanetTemplate := PlanetRenderTemplates[Index];
      PlanetTemplate.Free;
    end;
    PlanetRenderTemplates.Free;
    PlanetRenderTemplates := nil;
  end;
  if SatelliteRenderTemplates <> nil then
  begin
    Count := SatelliteRenderTemplates.Count;
    for Index := 0 to Count - 1 do
    begin
      SatelliteTemplate := SatelliteRenderTemplates[Index];
      SatelliteTemplate.Free;
    end;
    SatelliteRenderTemplates.Free;
    SatelliteRenderTemplates := nil;
  end;
  if SpaceProcess <> nil then
  begin
    SpaceProcess.Free;
    SpaceProcess := nil;
  end;
  if GameplayUiScriptCache <> nil then
  begin
    GameplayUiScriptCache.Free;
    GameplayUiScriptCache := nil;
  end;
  if TemporaryShopSlots <> nil then
  begin
    Count := TemporaryShopSlots.Count;
    for Index := 0 to Count - 1 do
    begin
      Slot := TemporaryShopSlots[Index];
      if Slot.SlotImage <> nil then
      begin
        Slot.SlotImage.Free;
        Slot.SlotImage := nil;
      end;
      if Slot.BorderImage <> nil then
      begin
        Slot.BorderImage.Free;
        Slot.BorderImage := nil;
      end;
      if Slot.TypeOverlayImage <> nil then
      begin
        Slot.TypeOverlayImage.Free;
        Slot.TypeOverlayImage := nil;
      end;
      if Slot.ItemIconImage <> nil then
      begin
        Slot.ItemIconImage.Free;
        Slot.ItemIconImage := nil;
      end;
      if Slot.ItemAnimation <> nil then
      begin
        Slot.ItemAnimation.Free;
        Slot.ItemAnimation := nil;
      end;
      if Slot.MicroModuleImage <> nil then
      begin
        Slot.MicroModuleImage.Free;
        Slot.MicroModuleImage := nil;
      end;
    end;
  end;
  if MainMenuScreen <> nil then
  begin
    MainMenuScreen.Free;
    MainMenuScreen := nil;
  end;
  if NewGameScreen <> nil then
  begin
    NewGameScreen.Free;
    NewGameScreen := nil;
  end;
  if IntroductionScreen <> nil then
  begin
    IntroductionScreen.Free;
    IntroductionScreen := nil;
  end;
  if HangarScreen <> nil then
  begin
    HangarScreen.Free;
    HangarScreen := nil;
  end;
  if PlanetScreen <> nil then
  begin
    PlanetScreen.Free;
    PlanetScreen := nil;
  end;
  if UninhabitedPlanetScreen <> nil then
  begin
    UninhabitedPlanetScreen.Free;
    UninhabitedPlanetScreen := nil;
  end;
  if PlanetQuestScreen <> nil then
  begin
    PlanetQuestScreen.Free;
    PlanetQuestScreen := nil;
  end;
  if RuinsTalkScreen <> nil then
  begin
    RuinsTalkScreen.Free;
    RuinsTalkScreen := nil;
  end;
  if ArcadeBattleScreen <> nil then
  begin
    ArcadeBattleScreen.Free;
    ArcadeBattleScreen := nil;
  end;
  if EquipmentShopScreen <> nil then
  begin
    EquipmentShopScreen.Free;
    EquipmentShopScreen := nil;
  end;
  if GoodsShopScreen <> nil then
  begin
    GoodsShopScreen.Free;
    GoodsShopScreen := nil;
  end;
  if GovernmentScreen <> nil then
  begin
    GovernmentScreen.Free;
    GovernmentScreen := nil;
  end;
  if InfoScreen <> nil then
  begin
    InfoScreen.Free;
    InfoScreen := nil;
  end;
  if RangerRatingScreen <> nil then
  begin
    RangerRatingScreen.Free;
    RangerRatingScreen := nil;
  end;
  if RewardsScreen <> nil then
  begin
    RewardsScreen.Free;
    RewardsScreen := nil;
  end;
  if ShipScreen <> nil then
  begin
    ShipScreen.Free;
    ShipScreen := nil;
  end;
  if TalkScreen <> nil then
  begin
    TalkScreen.Free;
    TalkScreen := nil;
  end;
  if ScannerScreen <> nil then
  begin
    ScannerScreen.Free;
    ScannerScreen := nil;
  end;
  if StarMapScreen <> nil then
  begin
    StarMapScreen.Free;
    StarMapScreen := nil;
  end;
  if FilmScreen <> nil then
  begin
    FilmScreen.Free;
    FilmScreen := nil;
  end;
  if GalaxyScreen <> nil then
  begin
    GalaxyScreen.Free;
    GalaxyScreen := nil;
  end;
  if JumpScreen <> nil then
  begin
    JumpScreen.Free;
    JumpScreen := nil;
  end;
  if LoadScreen <> nil then
  begin
    LoadScreen.Free;
    LoadScreen := nil;
  end;
  if SaveManagerScreen <> nil then
  begin
    SaveManagerScreen.Free;
    SaveManagerScreen := nil;
  end;
  if GameLoadScreen <> nil then
  begin
    GameLoadScreen.Free;
    GameLoadScreen := nil;
  end;
  if GameMenuScreen <> nil then
  begin
    GameMenuScreen.Free;
    GameMenuScreen := nil;
  end;
  if SettingsScreen <> nil then
  begin
    SettingsScreen.Free;
    SettingsScreen := nil;
  end;
  if GameEndScreen <> nil then
  begin
    GameEndScreen.Free;
    GameEndScreen := nil;
  end;
  if AboutScreen <> nil then
  begin
    AboutScreen.Free;
    AboutScreen := nil;
  end;
  if ScoreScreen <> nil then
  begin
    ScoreScreen.Free;
    ScoreScreen := nil;
  end;
  if SelectFaceScreen <> nil then
  begin
    SelectFaceScreen.Free;
    SelectFaceScreen := nil;
  end;
  if JournalScreen <> nil then
  begin
    JournalScreen.Free;
    JournalScreen := nil;
  end;
  if SpaceObjectUiLoop <> nil then
  begin
    SpaceObjectUiLoop.Free;
    SpaceObjectUiLoop := nil;
  end;
  if LoadRobotScreen <> nil then
  begin
    LoadRobotScreen.Free;
    LoadRobotScreen := nil;
  end;
  if LoadQuestScreen <> nil then
  begin
    LoadQuestScreen.Free;
    LoadQuestScreen := nil;
  end;
  if LoadArcadeScreen <> nil then
  begin
    LoadArcadeScreen.Free;
    LoadArcadeScreen := nil;
  end;
  // Native code omits AchievementsScreen from this cleanup list.
  for ScreenIndex := Low(TGameScreenId) to High(TGameScreenId) do RegisteredScreens[ScreenIndex] := nil;
  if PopupController <> nil then
  begin
    PopupController.Free;
    PopupController := nil;
  end;
  if SecondaryFilm <> nil then
  begin
    SecondaryFilm.Free;
    SecondaryFilm := nil;
  end;
  if PrimaryFilm <> nil then
  begin
    PrimaryFilm.Free;
    PrimaryFilm := nil;
  end;
  if PlanetSpaceTemplates <> nil then
  begin
    Count := High(PlanetSpaceTemplates);
    for Index := 0 to Count do
      if PlanetSpaceTemplates[Index].SpaceObject <> nil then
        ReleaseSpaceObject(PlanetSpaceTemplates[Index].SpaceObject);
  end;
  PlanetSpaceTemplates := nil;
  FinalizeSaveWriter;
  if CacheLoader <> nil then
  begin
    CacheLoader.Free;
    CacheLoader := nil;
  end;
end;
{ @end $52BED8 }

{ @routine $52C68C ResetScriptHostRuntimeState }
procedure ResetScriptHostRuntimeState;
var
  Race: TOwnerId; Kind, Series: Byte;
  Index: Integer;
begin
  if ScriptTemplates <> nil then
    for Index := ScriptTemplates.Count - 1 downto 0 do
    begin
      TObject(ScriptTemplates[Index]).Free;
      ScriptTemplates.Delete(Index);
    end;
  if GlobalScriptVariables <> nil then
  begin
    GlobalScriptVariables.Clear;
    GlobalScriptVariables.Add('GRunFrom', vkInt).SetInt(0);
    GlobalScriptVariables.Add('GRunStar', vkDword).SetInt(0);
  end;
  if ArtefactScriptCache <> nil then
  begin
    ArtefactScriptCache.Free;
    ArtefactScriptCache := nil;
  end;
  if ArtefactKindScriptCache <> nil then
  begin
    ArtefactKindScriptCache.Free;
    ArtefactKindScriptCache := nil;
  end;
  if UselessItemScriptCache <> nil then
  begin
    UselessItemScriptCache.Free;
    UselessItemScriptCache := nil;
  end;
  if CustomShipInfoScriptCache <> nil then
  begin
    CustomShipInfoScriptCache.Free;
    CustomShipInfoScriptCache := nil;
  end;
  if ScriptLibraryCache <> nil then
  begin
    ScriptLibraryCache.Free;
    ScriptLibraryCache := nil;
  end;
  for Race := oiMaloc to oiPirate do
  begin
    for Kind := 0 to 5 do
      if RaceShipTemplates[Race, Kind] <> nil then
        ReleaseSpaceObject(RaceShipTemplates[Race, Kind]);
    if PirateClanShipTemplates[Race] <> nil then
      ReleaseSpaceObject(PirateClanShipTemplates[Race]);
  end;
  for Series := 0 to 7 do
    if Series <> 0 then
    begin
      if BlazerShipTemplates[Series] <> nil then ReleaseSpaceObject(BlazerShipTemplates[Series]);
      if KellerShipTemplates[Series] <> nil then ReleaseSpaceObject(KellerShipTemplates[Series]);
      if TerronShipTemplates[Series] <> nil then ReleaseSpaceObject(TerronShipTemplates[Series]);
    end;
  ReloadScriptTemplates := True;
end;
{ @end $52C68C }

{ @routine $52C8D0 RecreateSpaceProcess }
procedure RecreateSpaceProcess(const ConfigName: WideString);
begin
  if SpaceProcess <> nil then
  begin
    SpaceProcess.Free;
    SpaceProcess := nil;
  end;
  SpaceProcess := TProcessSE.Create(ConfigName);
end;
{ @end $52C8D0 }

{ @routine $52C908 RunMainScreenStateLoop }
procedure RunMainScreenStateLoop;
begin
  while True do
  begin
    if ExitScreenLoop then Break;
    if (RequestedScreenId = screenStarMap) or
       (RequestedScreenId = screenFilm) or
       (RequestedScreenId = screenArcadeBattle) then
    begin
      CurrentScreenId := RequestedScreenId;
      RequestedScreenId := screenNone;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RunContinuous;
      PreviousScreenId := CurrentScreenId;
      CurrentScreenId := screenNone;
    end
    else
    begin
      if RequestedScreenId = screenNone then Exit;
      CurrentScreenId := RequestedScreenId;
      RequestedScreenId := screenNone;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).Run;
      PreviousScreenId := CurrentScreenId;
      CurrentScreenId := screenNone;
    end;
  end;
end;
{ @end $52C908 }

{ @routine $52C9D0 SwapTurnFilms }
procedure SwapTurnFilms;
var
  Film: TEFilm;
begin
  Film := PrimaryFilm;
  PrimaryFilm := SecondaryFilm;
  SecondaryFilm := Film;
end;
{ @end $52C9D0 }

{ @routine $52C9F4 TMessagePlayer_Create }
constructor TMessagePlayer.Create;
begin
  inherited Create;
  Button := nil;
  ImageNameOverride := '';
end;
{ @end $52C9F4 }

{ @routine $52CA48 TMessagePlayer_SaveToBuffer }
procedure TMessagePlayer.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(Key);
  Buffer.AddAnsiChar(AnsiChar(Kind));
  Buffer.AddIntegerValue(NotificationSoundKind);
  Buffer.AddIntegerValue(Turn);
  Buffer.AddWideStringZ(Text);
  Buffer.AddBoolean(False);
  Buffer.AddDWord(Targets[0].ShipId);
  Buffer.AddDWord(Targets[1].ShipId);
  Buffer.AddDWord(Targets[2].ShipId);
  Buffer.AddDWord(Targets[0].PlanetId);
  Buffer.AddDWord(Targets[1].PlanetId);
  Buffer.AddDWord(Targets[2].PlanetId);
  Buffer.AddBoolean(WasRead);
  Buffer.AddBoolean(NotificationSoundPlayed);
  Buffer.AddWideStringZ(ImageNameOverride);
end;
{ @end $52CA48 }

{ @routine $52CB28 TMessagePlayer_LoadFromBuffer }
procedure TMessagePlayer.LoadFromBuffer(Buffer: TBufEC);
begin
  Key := Buffer.ReadWideString;
  Kind := Buffer.GetByte;
  NotificationSoundKind := Buffer.GetInt32;
  Turn := Buffer.GetInt32;
  Text := Buffer.ReadWideString;
  Buffer.GetBoolean;
  Targets[0].ShipId := Buffer.GetUInt32;
  Targets[1].ShipId := Buffer.GetUInt32;
  Targets[2].ShipId := Buffer.GetUInt32;
  Targets[0].PlanetId := Buffer.GetUInt32;
  Targets[1].PlanetId := Buffer.GetUInt32;
  Targets[2].PlanetId := Buffer.GetUInt32;
  WasRead := Buffer.GetBoolean;
  NotificationSoundPlayed := Buffer.GetBoolean;
  if LoadedSaveVersion >= 109 then ImageNameOverride := Buffer.ReadWideString;
end;
{ @end $52CB28 }

{ @routine $52CC64 TMessagePlayer_GetNormalImageName }
function TMessagePlayer.GetNormalImageName: WideString;
begin
  if ImageNameOverride = '' then Result := PlayerMessagePresentations[Kind].NormalImage
  else Result := ImageNameOverride + 'N';
end;
{ @end $52CC64 }

{ @routine $52CCB8 TMessagePlayer_GetActiveImageName }
function TMessagePlayer.GetActiveImageName: WideString;
begin
  if ImageNameOverride = '' then Result := PlayerMessagePresentations[Kind].ActiveImage
  else Result := ImageNameOverride + 'A';
end;
{ @end $52CCB8 }

{ @routine $52CD0C TMessagePlayer_GetPressedImageName }
function TMessagePlayer.GetPressedImageName: WideString;
begin
  if ImageNameOverride = '' then Result := PlayerMessagePresentations[Kind].PressedImage
  else Result := ImageNameOverride + 'D';
end;
{ @end $52CD0C }

{ @routine $52CD60 ClearPersistentPlayerMessages }
procedure ClearPersistentPlayerMessages;
var Next, Entry: TMessagePlayer;
begin
  PersistentPlayerMessageLock.Enter;
  try
    Next := FirstPersistentPlayerMessage;
    while Next <> nil do
    begin
      Entry := Next;
      Next := Next.Next;
      Entry.Free;
    end;
    FirstPersistentPlayerMessage := nil;
    LastPersistentPlayerMessage := nil;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52CD60 }

{ @routine $52CDDC CountPersistentPlayerMessages }
function CountPersistentPlayerMessages: Integer;
var Entry: TMessagePlayer; Count: Integer;
begin
  PersistentPlayerMessageLock.Enter;
  try
    Count := 0;
    Entry := FirstPersistentPlayerMessage;
    while Entry <> nil do
    begin
      Inc(Count);
      Entry := Entry.Next;
    end;
    Result := Count;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52CDDC }

{ @routine $52CE4C IsPersistentPlayerMessageQueued }
function IsPersistentPlayerMessageQueued(MessageEntry: TMessagePlayer; SkipLock: Boolean): Boolean;
var Entry: TMessagePlayer;
begin
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    Entry := FirstPersistentPlayerMessage;
    while Entry <> nil do
    begin
      if Entry = MessageEntry then
      begin
        Result := True;
        Exit;
      end;
      Entry := Entry.Next;
    end;
    Result := False;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52CE4C }

{ @routine $52CED8 RemovePersistentPlayerMessage }
procedure RemovePersistentPlayerMessage(MessageEntry: TMessagePlayer; SkipLock: Boolean);
begin
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    if MessageEntry.Prev <> nil then MessageEntry.Prev.Next := MessageEntry.Next;
    if MessageEntry.Next <> nil then MessageEntry.Next.Prev := MessageEntry.Prev;
    if LastPersistentPlayerMessage = MessageEntry then LastPersistentPlayerMessage := MessageEntry.Prev;
    if FirstPersistentPlayerMessage = MessageEntry then FirstPersistentPlayerMessage := MessageEntry.Next;
    MessageEntry.Free;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52CED8 }

{ @routine $52CF90 RemovePlayerMessagesExceptKinds }
function RemovePlayerMessagesExceptKinds(Key: WideString; ExcludedKinds: TPlayerMessageKindSet; SkipLock: Boolean): Boolean;
var
  MessageEntry: TMessagePlayer;
begin
  Result := False;
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    repeat
      MessageEntry := FindPlayerMessageExceptKinds(Key, ExcludedKinds, True);
      if MessageEntry <> nil then
      begin
        RemovePersistentPlayerMessage(MessageEntry, True);
        Result := True;
      end;
    until MessageEntry = nil;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52CF90 }

{ @routine $52D04C FindPlayerBubbleByText }
function FindPlayerBubbleByText(const Text: WideString; SkipLock: Boolean): TMessagePlayer;
var Entry: TMessagePlayer;
begin
  Result := nil;
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    Entry := FirstPersistentPlayerMessage;
    while Entry <> nil do
    begin
      if Entry.Text = Text then
      begin
        Result := Entry;
        Exit;
      end;
      Entry := Entry.Next;
    end;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D04C }

{ @routine $52D0E4 FindPlayerBubbleByKey }
function FindPlayerBubbleByKey(const Key: WideString; SkipLock: Boolean): TMessagePlayer;
var Entry: TMessagePlayer;
begin
  Result := nil;
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    Entry := FirstPersistentPlayerMessage;
    while Entry <> nil do
    begin
      if Entry.Key = Key then
      begin
        Result := Entry;
        Exit;
      end;
      Entry := Entry.Next;
    end;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D0E4 }

{ @routine $52D17C RemovePlayerBubbleByKey }
procedure RemovePlayerBubbleByKey(const Key: WideString);
var Entry: TMessagePlayer;
begin
  PersistentPlayerMessageLock.Enter;
  try
    Entry := FirstPersistentPlayerMessage;
    while Entry <> nil do
    begin
      if Entry.Key = Key then
      begin
        if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
        if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
        if LastPersistentPlayerMessage = Entry then LastPersistentPlayerMessage := Entry.Prev;
        if FirstPersistentPlayerMessage = Entry then FirstPersistentPlayerMessage := Entry.Next;
        Entry.Free;
        Exit;
      end;
      Entry := Entry.Next;
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D17C }

{ @routine $52D260 RemovePlayerBubblePages }
procedure RemovePlayerBubblePages(const Prefix: WideString; FirstPage: Integer);
var Entry, Next: TMessagePlayer; PrefixLength: Integer; Suffix: WideString;
begin
  PersistentPlayerMessageLock.Enter;
  try
    Entry := FirstPersistentPlayerMessage;
    while Entry <> nil do
    begin
      Next := Entry.Next;
      PrefixLength := Pos(Prefix, Entry.Key);
      if PrefixLength = 1 then
      begin
        PrefixLength := Length(Prefix);
        Suffix := CopyWideStringUnchecked(Entry.Key, PrefixLength + 1, Length(Entry.Key) - PrefixLength);
        if IsIntegerTextW(Suffix) and (ExtractDigitsToIntW(Suffix) >= FirstPage) then
        begin
          if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
          if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
          if LastPersistentPlayerMessage = Entry then LastPersistentPlayerMessage := Entry.Prev;
          if FirstPersistentPlayerMessage = Entry then FirstPersistentPlayerMessage := Entry.Next;
          Entry.Free;
        end;
      end;
      Entry := Next;
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D260 }

{ @routine $52D3C8 FindPlayerMessageExceptKinds }
function FindPlayerMessageExceptKinds(const Key: WideString; ExcludedKinds: TPlayerMessageKindSet; SkipLock: Boolean): TMessagePlayer;
var
  MessageEntry: TMessagePlayer;
begin
  Result := nil;
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    MessageEntry := FirstPersistentPlayerMessage;
    while MessageEntry <> nil do
    begin
      if not (MessageEntry.Kind in ExcludedKinds) and ((Length(Key) = 0) or (Pos(Key, MessageEntry.Key) > 0)) then
      begin
        Result := MessageEntry;
        Exit;
      end;
      MessageEntry := MessageEntry.Next;
    end;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D3C8 }

{ @routine $52D484 CreatePersistentPlayerMessage }
function CreatePersistentPlayerMessage: TMessagePlayer;
var Entry: TMessagePlayer;
begin
  PersistentPlayerMessageLock.Enter;
  try
    Entry := TMessagePlayer.Create;
    if LastPersistentPlayerMessage <> nil then LastPersistentPlayerMessage.Next := Entry;
    Entry.Prev := LastPersistentPlayerMessage;
    Entry.Next := nil;
    LastPersistentPlayerMessage := Entry;
    if FirstPersistentPlayerMessage = nil then FirstPersistentPlayerMessage := Entry;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
  Result := Entry;
end;
{ @end $52D484 }

{ @routine $52D520 AddOrUpdatePlayerBubble }
function AddOrUpdatePlayerBubble(Kind: Byte; Turn: Integer; const Text, Key: WideString): TMessagePlayer;
var Entry: TMessagePlayer;
begin
  PersistentPlayerMessageLock.Enter;
  try
    if Key <> '' then
    begin
      Entry := FindPlayerBubbleByKey(Key, True);
      if Entry <> nil then
      begin
        if Entry.Kind <> Kind then
        begin
          Entry.WasRead := False;
          Entry.NotificationSoundPlayed := False;
        end;
        Entry.Kind := Kind;
        Entry.Turn := Turn;
        if Text <> '' then Entry.Text := Text;
        Result := Entry;
        Exit;
      end;
    end;
    Entry := FindPlayerBubbleByText(Text, True);
    if Entry <> nil then
    begin
      Result := Entry;
      Exit;
    end;
    Entry := TMessagePlayer.Create;
    if LastPersistentPlayerMessage <> nil then LastPersistentPlayerMessage.Next := Entry;
    Entry.Prev := LastPersistentPlayerMessage;
    Entry.Next := nil;
    LastPersistentPlayerMessage := Entry;
    if FirstPersistentPlayerMessage = nil then FirstPersistentPlayerMessage := Entry;
    Entry.Key := Key;
    Entry.Kind := Kind;
    Entry.Turn := Turn;
    Entry.Text := Text;
    Entry.WasRead := False;
    Entry.NotificationSoundPlayed := False;
    Result := Entry;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D520 }

{ @routine $52D698 PruneExpiredPersistentPlayerMessages }
procedure PruneExpiredPersistentPlayerMessages;
var Next, Entry: TMessagePlayer;
begin
  PersistentPlayerMessageLock.Enter;
  try
    Next := FirstPersistentPlayerMessage;
    while Next <> nil do
    begin
      Entry := Next;
      Next := Next.Next;
      if Entry.WasRead and (Entry.Kind in [pmTip]) and (Galaxy.CurrentTurn - Entry.Turn >= 7) then
        RemovePersistentPlayerMessage(Entry, True)
      else if Galaxy.CurrentTurn - Entry.Turn >= PlayerMessagePresentations[Entry.Kind].LifetimeTurns then
        RemovePersistentPlayerMessage(Entry, True)
      else if Entry.WasRead and (Entry.Kind in [pmGalaxyNews..pmShipPositive, pmQuestSucceeded, pmQuestCancelled, pmShipNegative]) then
        RemovePersistentPlayerMessage(Entry, True)
      else if not GetPlayer.InNormalSpace and (Entry.Kind = pmRadio) then
        RemovePersistentPlayerMessage(Entry, True);
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $52D698 }

{ @routine $52D7B0 TScriptTemplUnit_Create }
constructor TScriptTemplUnit.Create;
begin
  inherited Create;
  ConditionCode := TCodeEC.Create;
  ActiveScriptIndex := -1;
end;
{ @end $52D7B0 }

{ @routine $52D810 TScriptTemplUnit_Destroy }
destructor TScriptTemplUnit.Destroy;
begin
  ConditionCode.Free;
  ConditionCode := nil;
  inherited Destroy;
end;
{ @end $52D810 }

{ @routine $52D854 FindScriptTemplateIndex }
function FindScriptTemplateIndex(const Name: WideString): Integer;
var
  Item: TScriptTemplUnit;
  Count, Index: Integer;
begin
  Count := ScriptTemplates.Count;
  for Index := 0 to Count - 1 do
  begin
    Item := ScriptTemplates[Index];
    if Item.Name = Name then
    begin
      Result := Index;
      Exit;
    end;
  end;
  Result := -1;
end;
{ @end $52D854 }

{ @routine $52D8BC CollectInactiveScriptTemplates }
procedure CollectInactiveScriptTemplates(Dest: TList);
var
  Item: TScriptTemplUnit;
  Count, Index, First, Second: Integer;
begin
  Dest.Clear;
  Count := ScriptTemplates.Count;
  for Index := 0 to Count - 1 do
  begin
    Item := ScriptTemplates[Index];
    if Item.ActiveScriptIndex < 0 then Dest.Add(Item);
  end;
  if Dest.Count >= 2 then
  begin
    Count := Dest.Count * 2;
    for Index := 0 to Count - 1 do
    begin
      First := SeededRandomIntRange(0, Dest.Count - 1,
        Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn) * Cardinal(Index));
      Second := SeededRandomIntRange(0, Dest.Count - 1,
        Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn + Index));
      if First <> Second then
      begin
        Item := Dest[First];
        Dest[First] := Dest[Second];
        Dest[Second] := Item;
      end;
    end;
  end;
end;
{ @end $52D8BC }

{ @routine $52D9E8 ShowPlayerTipOnce }
function ShowPlayerTipOnce(Index: Integer): Boolean;
begin
  Result := False;
  if ShownPlayerTips shr Index and 1 = 0 then
  begin
    ShownPlayerTips := ShownPlayerTips or (1 shl Index);
    if Index < 10 then AddOrUpdatePlayerBubble(pmTip, Galaxy.CurrentTurn, LocalizedColorText('Tips.0' + SysUtils.IntToStr(Index)), '')
    else AddOrUpdatePlayerBubble(pmTip, Galaxy.CurrentTurn, LocalizedColorText('Tips.' + SysUtils.IntToStr(Index)), '');
    Result := True;
  end;
end;
{ @end $52D9E8 }

{ @routine $52DB38 HasShownPlayerTip }
function HasShownPlayerTip(Index: Integer): Boolean;
begin
  Result := ShownPlayerTips shr Index and 1 <> 0;
end;
{ @end $52DB38 }

{ @routine $52DB58 SelectSpaceImageTemplateFromSeed }
function SelectSpaceImageTemplateFromSeed(Kind: Integer; Seed: Cardinal): Integer;
var
  Index, Weight: Integer;
begin
  Weight := 0;
  for Index := 0 to High(SpaceImageTemplates) do
    if SpaceImageTemplates[Index].Kind = Kind then
      Inc(Weight, SpaceImageTemplates[Index].Weight);
  if Weight = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Weight := SeededRandomIntRange(0, Weight - 1, Seed);
  for Index := 0 to High(SpaceImageTemplates) do
    if SpaceImageTemplates[Index].Kind = Kind then
    begin
      Dec(Weight, SpaceImageTemplates[Index].Weight);
      if Weight < 0 then
      begin
        Result := Index;
        Exit;
      end;
    end;
  Result := 0;
end;
{ @end $52DB58 }

{ @routine $52DC3C SelectSpaceImageTemplate }
function SelectSpaceImageTemplate(Kind: Integer): Integer;
begin
  Result := SelectSpaceImageTemplateFromSeed(Kind, RandomIntRange(0, 2000000000));
end;
{ @end $52DC3C }

{ @routine $52DC68 HandleRuntimeExitCheck1 }
procedure HandleRuntimeExitCheck1;
begin
  if ExitScreenLoop then;
end;
{ @end $52DC68 }

{ @routine $52DC74 HandleRuntimeExitCheck2 }
procedure HandleRuntimeExitCheck2;
begin
  if ExitScreenLoop then;
end;
{ @end $52DC74 }

{ @routine $52DC80 ParseRobotMapRaceMask }
function ParseRobotMapRaceMask(Text: WideString): TOwnerMask;
var Names: AnsiString;
begin
  Result := [];
  if (Text <> '') and (Text <> 'Any') then
  begin
    Names := AnsiString(Text);
    if Pos('Maloc', Names) > 0 then Include(Result, oiMaloc);
    if Pos('Peleng', Names) > 0 then Include(Result, oiPeleng);
    if Pos('People', Names) > 0 then Include(Result, oiHuman);
    if Pos('Fei', Names) > 0 then Include(Result, oiFeyan);
    if Pos('Gaal', Names) > 0 then Include(Result, oiGaal);
  end;
end;
{ @end $52DC80 }

{ @routine $52DED4 InitializeRobotMapDefinitions }
procedure InitializeRobotMapDefinitions;
var
  Block, Root: TBlockParEC;
  Previous, Index, Count: Integer;
  Text: WideString;

  // @nested $52DDC8 ReadMapText
  function ReadMapText(const Path: WideString): WideString; // @addr $52DDC8 @calls "0x52DFCB,0x52dff4,0x52e01d,0x52e043,0x52e084,0x52e0ad,0x52e168,0x52e191,0x52e1c5,0x52e1f9,0x52e2db,0x52e304,0x52e32d,0x52e356,0x52e37f,0x52e3a8,0x52e3d1,0x52e3fd,0x52e42c,0x52e45b,0x52e48a,0x52e4b9,0x52e4e8,0x52e517" @note "Nested in InitializeRobotMapDefinitions; joins repeated fields with CRLF."
  var Part, PartCount: Integer;
  begin
    Result := '';
    PartCount := Block.CountParamsByPath(Path);
    for Part := 0 to PartCount - 1 do
    begin
      if Result <> '' then Result := Result + #13#10;
      Result := Result + Block.GetParamByPath(Path + ':' + WideString(IntToStr(Part)));
    end;
  end;

begin
  Root := LanguageDataConfig.GetBlock('RobotsMap');
  Count := Root.GetBlockCount;
  SetLength(RobotMapDefinitions, Count);
  for Index := 0 to Count - 1 do
  begin
    RobotMapDefinitions[Index].Id := ExtractDigitsToIntW(Root.GetBlockNameByIndex(Index));
    for Previous := 0 to Index - 1 do
      if RobotMapDefinitions[Index].Id = RobotMapDefinitions[Previous].Id then
        RaiseWideMessage('RobotMap.Id');
    Block := Root.GetBlockByIndex(Index);
    RobotMapDefinitions[Index].Name := ReadMapText('Name');
    RobotMapDefinitions[Index].Map := ReadMapText('Map');
    Text := ReadMapText('Group');
    if Text <> '' then
      RobotMapDefinitions[Index].Group := ExtractSignedDigitsToIntW(ReadMapText('Group'))
    else RobotMapDefinitions[Index].Group := -1;
    RobotMapDefinitions[Index].Access := ExtractSignedDigitsToIntW(ReadMapText('Access'));
    Text := ReadMapText('Side');
    RobotMapDefinitions[Index].Side := 0;
    if Pos('Red', AnsiString(Text)) > 0 then RobotMapDefinitions[Index].Side := RobotMapDefinitions[Index].Side or 1;
    if Pos('Green', AnsiString(Text)) > 0 then RobotMapDefinitions[Index].Side := RobotMapDefinitions[Index].Side or 2;
    if Pos('Blue', AnsiString(Text)) > 0 then RobotMapDefinitions[Index].Side := RobotMapDefinitions[Index].Side or 4;
    RobotMapDefinitions[Index].Length := ExtractSignedDigitsToIntW(ReadMapText('Length'));
    Text := ReadMapText('PlanetRace');
    RobotMapDefinitions[Index].PlanetRace := ParseRobotMapRaceMask(Text);
    Text := ReadMapText('PlayerRace');
    RobotMapDefinitions[Index].PlayerRace := ParseRobotMapRaceMask(Text);
    Text := ReadMapText('PlayerStatus');
    RobotMapDefinitions[Index].PlayerStatus := [];
    if (Text <> '') and (Text <> 'Any') then
    begin
      if Pos('Trader', AnsiString(Text)) > 0 then Include(RobotMapDefinitions[Index].PlayerStatus, rcTrader);
      if Pos('Pirate', AnsiString(Text)) > 0 then Include(RobotMapDefinitions[Index].PlayerStatus, rcPirate);
      if Pos('Warrior', AnsiString(Text)) > 0 then Include(RobotMapDefinitions[Index].PlayerStatus, rcWarrior);
    end;
    RobotMapDefinitions[Index].MinWins := ExtractSignedDigitsToIntW(ReadMapText('MinWins'));
    RobotMapDefinitions[Index].MaxWins := ExtractSignedDigitsToIntW(ReadMapText('MaxWins'));
    RobotMapDefinitions[Index].Reiteration := ExtractDigitsToIntW(ReadMapText('Reiteration'));
    RobotMapDefinitions[Index].ReinforcementsDisabled := ParseEnabledNameGI(ReadMapText('ReinforcementsDisabled'));
    RobotMapDefinitions[Index].Terron := ParseEnabledNameGI(ReadMapText('Terron'));
    RobotMapDefinitions[Index].Demo := ParseEnabledNameGI(ReadMapText('Demo'));
    RobotMapDefinitions[Index].AfterLiberation := ParseEnabledNameGI(ReadMapText('AfterLiberation'));
    RobotMapDefinitions[Index].GovTextStart := ReadMapText('GovTextStart');
    RobotMapDefinitions[Index].GovTextWin := ReadMapText('GovTextWin');
    RobotMapDefinitions[Index].GovTextLoss := ReadMapText('GovTextLoss');
    RobotMapDefinitions[Index].RobotsStart := ReadMapText('RobotsStart');
    RobotMapDefinitions[Index].RobotsWin := ReadMapText('RobotsWin');
    RobotMapDefinitions[Index].RobotsLoss := ReadMapText('RobotsLoss');
    RobotMapDefinitions[Index].FromAuthor := ReadMapText('FromAuthor');
  end;
end;
{ @end $52DED4 }

{ @routine $52E88C FindRobotMapById }
function FindRobotMapById(MapId: Integer): Integer;
var
  Index: Integer;
begin
  for Index := 0 to High(RobotMapDefinitions) do
    if RobotMapDefinitions[Index].Id = MapId then
    begin
      Result := Index;
      Exit;
    end;
  Result := -1;
end;
{ @end $52E88C }

{ @routine $52E8E4 FindPlanetSpaceTemplateIndex }
function FindPlanetSpaceTemplateIndex(Style, StyleVariant: Integer): Integer;
var
  Index: Integer;
begin
  for Index := 0 to High(PlanetSpaceTemplates) do
    if (PlanetSpaceTemplates[Index].Style = Style) and
       (PlanetSpaceTemplates[Index].StyleVariant = StyleVariant) then
    begin
      Result := Index;
      Exit;
    end;
  Result := -1;
  RaiseWideMessage('find planet');
end;
{ @end $52E8E4 }

{ @routine $52E9B4 InitializeShipGreetingDefinitions }
procedure InitializeShipGreetingDefinitions;
var
  Block: TBlockParEC;
  Index, EntryIndex, Item, Count: Integer;
  Text: WideString;

  // @nested $52E974 ReadShipGreetingField
  function ReadShipGreetingField(const FieldName: WideString): WideString {
    @addr $52E974
    @calls "0x52eb43,0x52eb8e,0x52EBEB,0x52ec91,0x52edf2,0x52ef0b,0x52ef39,0x52EF67,0x52efbe,0x52f015,0x52f06c,0x52f0c3,0x52f25a,0x52f288,0x52f2df,0x52f336,0x52f38d,0x52f455,0x52f51d,0x52f5e5,0x52f6ab,0x52f771,0x52f88d,0x52f9a9,0x52fac5,0x52fbe1,0x52fcfd,0x52fe19,0x52ffb0,0x530147,0x530263,0x53037f,0x53049b,0x5305a0,0x5306e5,0x53082a,0x530881,0x5308d8,0x530971,0x530a0a,0x530a61,0x530b29,0x530bf1,0x530cb9,0x530d81,0x530e49,0x530e94,0x530fb0,0x5310f5,0x531211,0x53132d,0x531384,0x5313db,0x531432,0x5314f8,0x531614,0x53166b,0x531735,0x5317fd,0x5318c5,0x53198d,0x531a55,0x531b1d,0x531b4b,0x531c67,0x531dac,0x531ec8,0x531fe4,0x53203b,0x532092,0x5320e9,0x5321af,0x5322cb,0x532322,0x532379,0x5323d0,0x532427,0x53247e,0x5324d5,0x53259d,0x532665,0x53272d,0x5327f5,0x5328bd,0x5328e0,0x5329fc,0x532a53,0x532bc1,0x532bef,0x532c46,0x532c9d,0x532db9,0x532f50,0x53306c,0x5330ab,0x533180,0x5331d7,0x53329f,0x533367,0x5333c7"
  };
  begin
    if Block.CountParams(FieldName) > 0 then Result := Block.GetParam(FieldName)
    else Result := '';
  end;

begin
  ShipGreetingCount := 0;
  Count := StrToInt(AnsiString(LookupLocalizedTextByKey('ShipGreetings.CountShipGreetings')));
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('ShipGreetings').CountBlocks(WideString(IntToStr(Index))) > 0 then
      Inc(ShipGreetingCount);
  SetLength(ShipGreetingDefinitions, ShipGreetingCount);
  ShipGreetingCount := 0;
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('ShipGreetings').CountBlocks(WideString(IntToStr(Index))) <> 0 then
    begin
      Inc(ShipGreetingCount);
      EntryIndex := ShipGreetingCount - 1;
      Block := LanguageDataConfig.GetBlockByPath(WideString('ShipGreetings.' + IntToStr(Index)));
      with ShipGreetingDefinitions[EntryIndex] do
      begin
        Name := WideString(IntToStr(Index));
        Text := ReadShipGreetingField('Priority');
        if Text = '' then Priority := 10 else Priority := StrToInt(AnsiString(Text));
        Text := ReadShipGreetingField('AutoTalk');
        if (Text = '') or (Text = 'No') then AutoTalk := 1
        else if Text = 'Any' then AutoTalk := 2
        else AutoTalk := 0;
        Text := ReadShipGreetingField('FlyType');
        if (Text = 'Any') or (Text = '') then FlyType := 0
        else if Text = 'ToPlanet' then FlyType := 1
        else if Text = 'ToStar' then FlyType := 2
        else if Text = 'ToItem' then FlyType := 3
        else if Text = 'ToShip' then FlyType := 4
        else RaiseWideMessage(Text);
        Text := ReadShipGreetingField('ShipType');
        ShipType := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Transport', AnsiString(Text)) > 0 then Include(ShipType, gscTransport);
          if Pos('Liner', AnsiString(Text)) > 0 then Include(ShipType, gscLiner);
          if Pos('Diplomat', AnsiString(Text)) > 0 then Include(ShipType, gscDiplomat);
          if Pos('Ranger', AnsiString(Text)) > 0 then Include(ShipType, gscRanger);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipType, gscPirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ShipType, gscWarrior);
          if Pos('Kling', AnsiString(Text)) > 0 then Include(ShipType, gscKling);
          if Pos('Pirat', AnsiString(Text)) > 0 then Include(ShipType, gscPirateClan);
        end;
        Text := ReadShipGreetingField('Relations');
        Relations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(Relations, rlHostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(Relations, rlBad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(Relations, rlNormal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(Relations, rlGood);
          if Pos('Best', AnsiString(Text)) > 0 then Include(Relations, rlExcellent);
        end;
        Text := ReadShipGreetingField('ShipRace');
        ShipRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('PlayerRace');
        PlayerRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ShipRaceIsPlayerRace');
        if Text = 'Yes' then ShipRaceIsPlayerRace := 0
        else if Text = 'No' then ShipRaceIsPlayerRace := 1
        else ShipRaceIsPlayerRace := 2;
        Text := ReadShipGreetingField('PlayerAttackGoodShip');
        if Text = 'Yes' then PlayerAttackGoodShip := 0
        else if Text = 'No' then PlayerAttackGoodShip := 1
        else PlayerAttackGoodShip := 2;
        Text := ReadShipGreetingField('InFear');
        if Text = 'Yes' then InFear := 0
        else if Text = 'Any' then InFear := 2
        else InFear := 1;
        Text := ReadShipGreetingField('ShipBadFlyToShip');
        if Text = 'Yes' then ShipBadFlyToShip := 0
        else if Text = 'Any' then ShipBadFlyToShip := 2
        else ShipBadFlyToShip := 1;
        Text := ReadShipGreetingField('ShipBadType');
        ShipBadType := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Transport', AnsiString(Text)) > 0 then Include(ShipBadType, gscTransport);
          if Pos('Liner', AnsiString(Text)) > 0 then Include(ShipBadType, gscLiner);
          if Pos('Diplomat', AnsiString(Text)) > 0 then Include(ShipBadType, gscDiplomat);
          if Pos('Ranger', AnsiString(Text)) > 0 then Include(ShipBadType, gscRanger);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipBadType, gscPirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ShipBadType, gscWarrior);
          if Pos('Kling', AnsiString(Text)) > 0 then Include(ShipBadType, gscKling);
          if Pos('PirateClan', AnsiString(Text)) > 0 then Include(ShipBadType, gscPirateClan);
        end;
        Text := ReadShipGreetingField('ShipBadRace');
        ShipBadRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ShipFlyToPlayer');
        if Text = 'Yes' then ShipFlyToPlayer := 0
        else if Text = 'No' then ShipFlyToPlayer := 1
        else ShipFlyToPlayer := 2;
        Text := ReadShipGreetingField('PlayerFlyToShip');
        if Text = 'Yes' then PlayerFlyToShip := 0
        else if Text = 'No' then PlayerFlyToShip := 1
        else PlayerFlyToShip := 2;
        Text := ReadShipGreetingField('PlayerIsShipBad');
        if Text = 'Yes' then PlayerIsShipBad := 0
        else if Text = 'No' then PlayerIsShipBad := 1
        else PlayerIsShipBad := 2;
        Text := ReadShipGreetingField('ShipTurnBeforeEndOrder');
        ShipTurnBeforeEndOrder := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(ShipTurnBeforeEndOrder, Item);
          if Pos('Far', AnsiString(Text)) > 0 then Include(ShipTurnBeforeEndOrder, 10);
        end;
        Text := ReadShipGreetingField('PlayerTurnBeforeEndOrder');
        PlayerTurnBeforeEndOrder := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PlayerTurnBeforeEndOrder, Item);
          if Pos('Far', AnsiString(Text)) > 0 then Include(PlayerTurnBeforeEndOrder, 10);
        end;
        Text := ReadShipGreetingField('ShipBadTurnBeforeEndOrder');
        ShipBadTurnBeforeEndOrder := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(ShipBadTurnBeforeEndOrder, Item);
          if Pos('Far', AnsiString(Text)) > 0 then Include(ShipBadTurnBeforeEndOrder, 10);
        end;
        Text := ReadShipGreetingField('ShipStatus');
        ShipStatus := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Trader', AnsiString(Text)) > 0 then Include(ShipStatus, rcTrader);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipStatus, rcPirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ShipStatus, rcWarrior);
        end;
        Text := ReadShipGreetingField('PlayerStatus');
        PlayerStatus := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Trader', AnsiString(Text)) > 0 then Include(PlayerStatus, rcTrader);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(PlayerStatus, rcPirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(PlayerStatus, rcWarrior);
        end;
        Text := ReadShipGreetingField('ShipStrength');
        ShipStrength := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ShipStrength, 1);
          // Native uses Pirate here, unlike the other strength/size filters.
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipStrength, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ShipStrength, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ShipStrength, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ShipStrength, 5);
        end;
        Text := ReadShipGreetingField('PlayerStrength');
        PlayerStrength := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(PlayerStrength, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(PlayerStrength, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(PlayerStrength, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(PlayerStrength, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(PlayerStrength, 5);
        end;
        Text := ReadShipGreetingField('ShipStructure');
        ShipStructure := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ShipStructure, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ShipStructure, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ShipStructure, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ShipStructure, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ShipStructure, 5);
        end;
        Text := ReadShipGreetingField('PlayerStructure');
        PlayerStructure := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(PlayerStructure, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(PlayerStructure, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(PlayerStructure, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(PlayerStructure, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(PlayerStructure, 5);
        end;
        Text := ReadShipGreetingField('ShipRating');
        ShipRating := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ShipRating, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ShipRating, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ShipRating, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ShipRating, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ShipRating, 5);
        end;
        Text := ReadShipGreetingField('PlayerRating');
        PlayerRating := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(PlayerRating, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(PlayerRating, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(PlayerRating, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(PlayerRating, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(PlayerRating, 5);
        end;
        Text := ReadShipGreetingField('ShipRank');
        ShipRank := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Rookie', AnsiString(Text)) > 0 then Include(ShipRank, 0);
          if Pos('Cadet', AnsiString(Text)) > 0 then Include(ShipRank, 1);
          if Pos('Pilot', AnsiString(Text)) > 0 then Include(ShipRank, 2);
          if Pos('Wingman', AnsiString(Text)) > 0 then Include(ShipRank, 3);
          if Pos('Leader', AnsiString(Text)) > 0 then Include(ShipRank, 4);
          if Pos('Ace', AnsiString(Text)) > 0 then Include(ShipRank, 5);
          if Pos('Commander', AnsiString(Text)) > 0 then Include(ShipRank, 6);
          if Pos('Admiral', AnsiString(Text)) > 0 then Include(ShipRank, 7);
        end;
        Text := ReadShipGreetingField('PlayerRank');
        PlayerRank := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Rookie', AnsiString(Text)) > 0 then Include(PlayerRank, 0);
          if Pos('Cadet', AnsiString(Text)) > 0 then Include(PlayerRank, 1);
          if Pos('Pilot', AnsiString(Text)) > 0 then Include(PlayerRank, 2);
          if Pos('Wingman', AnsiString(Text)) > 0 then Include(PlayerRank, 3);
          if Pos('Leader', AnsiString(Text)) > 0 then Include(PlayerRank, 4);
          if Pos('Ace', AnsiString(Text)) > 0 then Include(PlayerRank, 5);
          if Pos('Commander', AnsiString(Text)) > 0 then Include(PlayerRank, 6);
          if Pos('Admiral', AnsiString(Text)) > 0 then Include(PlayerRank, 7);
        end;
        Text := ReadShipGreetingField('RatingShipWithPlayer');
        RatingShipWithPlayer := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(RatingShipWithPlayer, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(RatingShipWithPlayer, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(RatingShipWithPlayer, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(RatingShipWithPlayer, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(RatingShipWithPlayer, 5);
        end;
        Text := ReadShipGreetingField('RankShipWithPlayer');
        RankShipWithPlayer := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(RankShipWithPlayer, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(RankShipWithPlayer, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(RankShipWithPlayer, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(RankShipWithPlayer, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(RankShipWithPlayer, 5);
        end;
        Text := ReadShipGreetingField('StrengthShipWithPlayer');
        StrengthShipWithPlayer := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(StrengthShipWithPlayer, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(StrengthShipWithPlayer, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(StrengthShipWithPlayer, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(StrengthShipWithPlayer, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(StrengthShipWithPlayer, 5);
        end;
        Text := ReadShipGreetingField('Goods');
        if Text = '' then Goods := 42
        else if Text = 'Food' then Goods := 0
        else if Text = 'Medicine' then Goods := 1
        else if Text = 'Technics' then Goods := 2
        else if Text = 'Luxury' then Goods := 3
        else if Text = 'Minerals' then Goods := 4
        else if Text = 'Alcohol' then Goods := 5
        else if Text = 'Arms' then Goods := 6
        else if Text = 'Narcotics' then Goods := 7
        else Goods := 42;
        Text := ReadShipGreetingField('ShipGoodsCnt');
        ShipGoodsCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Zero', AnsiString(Text)) > 0 then Include(ShipGoodsCnt, 0);
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ShipGoodsCnt, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ShipGoodsCnt, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ShipGoodsCnt, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ShipGoodsCnt, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ShipGoodsCnt, 5);
        end;
        Text := ReadShipGreetingField('PlayerGoodsCnt');
        PlayerGoodsCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Zero', AnsiString(Text)) > 0 then Include(PlayerGoodsCnt, 0);
          if Pos('Mini', AnsiString(Text)) > 0 then Include(PlayerGoodsCnt, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(PlayerGoodsCnt, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(PlayerGoodsCnt, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(PlayerGoodsCnt, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(PlayerGoodsCnt, 5);
        end;
        Text := ReadShipGreetingField('ShipHaveGoods');
        if Text = 'Yes' then ShipHaveGoods := 0
        else if Text = 'No' then ShipHaveGoods := 1
        else ShipHaveGoods := 2;
        Text := ReadShipGreetingField('PlayerHaveGoods');
        if Text = 'Yes' then PlayerHaveGoods := 0
        else if Text = 'No' then PlayerHaveGoods := 1
        else PlayerHaveGoods := 2;
        Text := ReadShipGreetingField('ShipGoodsTypeCnt');
        ShipGoodsTypeCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 8 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(ShipGoodsTypeCnt, Item);
        end;
        Text := ReadShipGreetingField('PlayerGoodsTypeCnt');
        PlayerGoodsTypeCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 8 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PlayerGoodsTypeCnt, Item);
        end;
        Text := ReadShipGreetingField('ShipMayScanPlayer');
        if Text = 'Yes' then ShipMayScanPlayer := 0
        else if Text = 'No' then ShipMayScanPlayer := 1
        else ShipMayScanPlayer := 2;
        Text := ReadShipGreetingField('RangerInCurStar');
        RangerInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(RangerInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(RangerInCurStar, 10);
        end;
        Text := ReadShipGreetingField('PirateInCurStar');
        PirateInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateInCurStar, 10);
        end;
        Text := ReadShipGreetingField('KlingInCurStar');
        KlingInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(KlingInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(KlingInCurStar, 10);
        end;
        Text := ReadShipGreetingField('WarriorInCurStar');
        WarriorInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(WarriorInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(WarriorInCurStar, 10);
        end;
        Text := ReadShipGreetingField('TransportInCurStar');
        TransportInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(TransportInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(TransportInCurStar, 10);
        end;
        Text := ReadShipGreetingField('LastPlanetRace');
        if Text = 'Any' then LastPlanetRace := [oiMaloc..oiGaal] else LastPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('LastPlanetRelations');
        LastPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(LastPlanetRelations, rlHostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(LastPlanetRelations, rlBad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(LastPlanetRelations, rlNormal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(LastPlanetRelations, rlGood);
          if Pos('Best', AnsiString(Text)) > 0 then Include(LastPlanetRelations, rlExcellent);
        end;
        Text := ReadShipGreetingField('LastPlanetGoodsCnt');
        LastPlanetGoodsCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Zero', AnsiString(Text)) > 0 then Include(LastPlanetGoodsCnt, 0);
          if Pos('Mini', AnsiString(Text)) > 0 then Include(LastPlanetGoodsCnt, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(LastPlanetGoodsCnt, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(LastPlanetGoodsCnt, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(LastPlanetGoodsCnt, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(LastPlanetGoodsCnt, 5);
        end;
        Text := ReadShipGreetingField('LastPlanetGoodsSale');
        LastPlanetGoodsSale := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(LastPlanetGoodsSale, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(LastPlanetGoodsSale, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(LastPlanetGoodsSale, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(LastPlanetGoodsSale, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(LastPlanetGoodsSale, 5);
        end;
        Text := ReadShipGreetingField('LastPlanetGoodsBuy');
        LastPlanetGoodsBuy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(LastPlanetGoodsBuy, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(LastPlanetGoodsBuy, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(LastPlanetGoodsBuy, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(LastPlanetGoodsBuy, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(LastPlanetGoodsBuy, 5);
        end;
        Text := ReadShipGreetingField('LastPlanetIsHomePlanet');
        if Text = 'Yes' then LastPlanetIsHomePlanet := 0
        else if Text = 'No' then LastPlanetIsHomePlanet := 1
        else LastPlanetIsHomePlanet := 2;
        Text := ReadShipGreetingField('LastPlanetRaceIsShipRace');
        if Text = 'Yes' then LastPlanetRaceIsShipRace := 0
        else if Text = 'No' then LastPlanetRaceIsShipRace := 1
        else LastPlanetRaceIsShipRace := 2;
        Text := ReadShipGreetingField('LastPlanetRaceIsPlayerRace');
        if Text = 'Yes' then LastPlanetRaceIsPlayerRace := 0
        else if Text = 'No' then LastPlanetRaceIsPlayerRace := 1
        else LastPlanetRaceIsPlayerRace := 2;
        Text := ReadShipGreetingField('LastPlanetEconomy');
        LastPlanetEconomy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(LastPlanetEconomy, peAgricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(LastPlanetEconomy, peMixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(LastPlanetEconomy, peIndustrial);
        end;
        Text := ReadShipGreetingField('LastPlanetGoverment');
        LastPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, pgAnarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, pgDictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, pgMonarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, pgRepublic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, pgDemocracy);
        end;
        Text := ReadShipGreetingField('LastPlanetInCurStar');
        if Text = 'Yes' then LastPlanetInCurStar := 0
        else if Text = 'No' then LastPlanetInCurStar := 1
        else LastPlanetInCurStar := 2;
        Text := ReadShipGreetingField('LastPlanetDistToShipInTurn');
        LastPlanetDistToShipInTurn := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 1 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(LastPlanetDistToShipInTurn, Item);
          if Pos('Far', AnsiString(Text)) > 0 then Include(LastPlanetDistToShipInTurn, 10);
        end;
        Text := ReadShipGreetingField('RangerInLastPlanetStar');
        RangerInLastPlanetStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(RangerInLastPlanetStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(RangerInLastPlanetStar, 10);
        end;
        Text := ReadShipGreetingField('PirateInLastPlanetStar');
        PirateInLastPlanetStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateInLastPlanetStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateInLastPlanetStar, 10);
        end;
        Text := ReadShipGreetingField('KlingInLastPlanetStar');
        KlingInLastPlanetStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(KlingInLastPlanetStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(KlingInLastPlanetStar, 10);
        end;
        Text := ReadShipGreetingField('WarriorInLastPlanetStar');
        WarriorInLastPlanetStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(WarriorInLastPlanetStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(WarriorInLastPlanetStar, 10);
        end;
        Text := ReadShipGreetingField('TransportInLastPlanetStar');
        TransportInLastPlanetStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(TransportInLastPlanetStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(TransportInLastPlanetStar, 10);
        end;
        Text := ReadShipGreetingField('ToPlanetRace');
        ToPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ToPlanetRelations');
        ToPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlHostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlBad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlNormal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlGood);
          if Pos('Best', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlExcellent);
        end;
        Text := ReadShipGreetingField('ToPlanetGoodsCnt');
        ToPlanetGoodsCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Zero', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 0);
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 5);
        end;
        Text := ReadShipGreetingField('ToPlanetGoodsSale');
        ToPlanetGoodsSale := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 5);
        end;
        Text := ReadShipGreetingField('ToPlanetGoodsBuy');
        ToPlanetGoodsBuy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 5);
        end;
        Text := ReadShipGreetingField('ToPlanetIsHomePlanet');
        if Text = 'Yes' then ToPlanetIsHomePlanet := 0
        else if Text = 'No' then ToPlanetIsHomePlanet := 1
        else ToPlanetIsHomePlanet := 2;
        Text := ReadShipGreetingField('ToPlanetRaceIsShipRace');
        if Text = 'Yes' then ToPlanetRaceIsShipRace := 0
        else if Text = 'No' then ToPlanetRaceIsShipRace := 1
        else ToPlanetRaceIsShipRace := 2;
        Text := ReadShipGreetingField('ToPlanetRaceIsPlayerRace');
        if Text = 'Yes' then ToPlanetRaceIsPlayerRace := 0
        else if Text = 'No' then ToPlanetRaceIsPlayerRace := 1
        else ToPlanetRaceIsPlayerRace := 2;
        Text := ReadShipGreetingField('ToPlanetEconomy');
        ToPlanetEconomy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, peAgricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, peMixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, peIndustrial);
        end;
        Text := ReadShipGreetingField('ToPlanetGoverment');
        ToPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgAnarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgDictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgMonarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgRepublic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgDemocracy);
        end;
        Text := ReadShipGreetingField('ToPlanetIsLastPlanet');
        if Text = 'Yes' then ToPlanetIsLastPlanet := 0
        else if Text = 'Any' then ToPlanetIsLastPlanet := 2
        else ToPlanetIsLastPlanet := 1;
        Text := ReadShipGreetingField('ToPlanetRaceIsLastPlanetRace');
        if Text = 'Yes' then ToPlanetRaceIsLastPlanetRace := 0
        else if Text = 'No' then ToPlanetRaceIsLastPlanetRace := 1
        else ToPlanetRaceIsLastPlanetRace := 2;
        Text := ReadShipGreetingField('HomePlanetInToStar');
        if Text = 'Yes' then HomePlanetInToStar := 0
        else if Text = 'No' then HomePlanetInToStar := 1
        else HomePlanetInToStar := 2;
        Text := ReadShipGreetingField('HomePlanetInCurStar');
        if Text = 'Yes' then HomePlanetInCurStar := 0
        else if Text = 'No' then HomePlanetInCurStar := 1
        else HomePlanetInCurStar := 2;
        Text := ReadShipGreetingField('ToStarControlByKling');
        if Text = 'Yes' then ToStarControlByKling := 0
        else if Text = 'Any' then ToStarControlByKling := 2
        else ToStarControlByKling := 1;
        Text := ReadShipGreetingField('ToStarInBattle');
        if Text = 'Yes' then ToStarInBattle := 0
        else if Text = 'Any' then ToStarInBattle := 2
        else ToStarInBattle := 1;
        Text := ReadShipGreetingField('RangerInToStar');
        RangerInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(RangerInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(RangerInToStar, 10);
        end;
        Text := ReadShipGreetingField('PirateInToStar');
        PirateInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateInToStar, 10);
        end;
        Text := ReadShipGreetingField('KlingInToStar');
        KlingInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(KlingInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(KlingInToStar, 10);
        end;
        Text := ReadShipGreetingField('WarriorInToStar');
        WarriorInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(WarriorInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(WarriorInToStar, 10);
        end;
        Text := ReadShipGreetingField('TransportInToStar');
        TransportInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(TransportInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(TransportInToStar, 10);
        end;
        ItemType := ReadShipGreetingField('ItemType');
        // Native repeats this assignment; preserve both reads.
        Text := ReadShipGreetingField('ToPlanetGoverment');
        ToPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgAnarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgDictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgMonarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgRepublic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgDemocracy);
        end;
        Text := ReadShipGreetingField('ShipNeedInItem');
        if Text = 'Yes' then ShipNeedInItem := 0
        else if Text = 'No' then ShipNeedInItem := 1
        else ShipNeedInItem := 2;
        Text := ReadShipGreetingField('ToShipType');
        ToShipType := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Transport', AnsiString(Text)) > 0 then Include(ToShipType, gscTransport);
          if Pos('Liner', AnsiString(Text)) > 0 then Include(ToShipType, gscLiner);
          if Pos('Diplomat', AnsiString(Text)) > 0 then Include(ToShipType, gscDiplomat);
          if Pos('Ranger', AnsiString(Text)) > 0 then Include(ToShipType, gscRanger);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ToShipType, gscPirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ToShipType, gscWarrior);
          if Pos('Kling', AnsiString(Text)) > 0 then Include(ToShipType, gscKling);
        end;
        Text := ReadShipGreetingField('ToShipRace');
        ToShipRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ToShipInPlanet');
        if Text = 'Yes' then ToShipInPlanet := 0
        else if Text = 'No' then ToShipInPlanet := 1
        else ToShipInPlanet := 2;
        Text := ReadShipGreetingField('ToShipBad');
        if Text = 'Yes' then ToShipBad := 0
        else if Text = 'No' then ToShipBad := 1
        else ToShipBad := 2;
        Text := ReadShipGreetingField('ToShipRelations');
        ToShipRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(ToShipRelations, rlHostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(ToShipRelations, rlBad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(ToShipRelations, rlNormal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(ToShipRelations, rlGood);
          if Pos('Best', AnsiString(Text)) > 0 then Include(ToShipRelations, rlExcellent);
        end;
        Text := ReadShipGreetingField('PlayerPirateRank');
        PlayerPirateRank := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Noobie', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 0);
          if Pos('Kid', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 1);
          if Pos('Rader', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 2);
          if Pos('Skipper', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 3);
          if Pos('Rough', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 4);
          if Pos('Ataman', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 5);
          if Pos('Khan', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 6);
          if Pos('Baron', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 7);
        end;
        Text := ReadShipGreetingField('RankShipWithPlayer');
        RankShipWithPlayerExtra := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(RankShipWithPlayerExtra, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(RankShipWithPlayerExtra, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(RankShipWithPlayerExtra, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(RankShipWithPlayerExtra, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(RankShipWithPlayerExtra, 5);
        end;
        Text := ReadShipGreetingField('Female');
        if Text = 'Yes' then Female := 0 else Female := 1;
        Text := ReadShipGreetingField('PirateClanInToStar');
        PirateClanInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateClanInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateClanInToStar, 10);
        end;
        Text := ReadShipGreetingField('ToStarControlByPirates');
        if Text = 'Yes' then ToStarControlByPirates := 0
        else if Text = 'Any' then ToStarControlByPirates := 2
        else ToStarControlByPirates := 1;
        Text := ReadShipGreetingField('PirateClanInCurStar');
        PirateClanInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateClanInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateClanInCurStar, 10);
        end;
        // Native repeats this assignment; preserve both reads.
        Text := ReadShipGreetingField('PirateInToStar');
        PirateInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateInToStar, 10);
        end;
        Text := ReadShipGreetingField('CoalitionAlreadyDefeated');
        if Text = 'Yes' then CoalitionAlreadyDefeated := 0
        else if Text = 'No' then CoalitionAlreadyDefeated := 1
        else CoalitionAlreadyDefeated := 2;
        Text := ReadShipGreetingField('DominatorsAlreadyDefeated');
        if Text = 'Yes' then DominatorsAlreadyDefeated := 0
        else if Text = 'No' then DominatorsAlreadyDefeated := 1
        else DominatorsAlreadyDefeated := 2;
      end;
    end;
end;
{ @end $52E9B4 }

{ @routine $534F34 InitializeGovernmentGreetingDefinitions }
procedure InitializeGovernmentGreetingDefinitions;
var
  Block: TBlockParEC;
  Index, EntryIndex, Item, Count: Integer;
  Text: WideString;

  // @nested $534EC4 ReadGovernmentGreetingField
  function ReadGovernmentGreetingField(FieldName: WideString): WideString; // @addr $534EC4 @calls "0x5350c2,0x53510d,0x535135,0x5351df,0x5352d7,0x53546b,0x535570,0x53559e,0x5355f5,0x535711,0x535768,0x5358AD,0x5359C9,0x535ae5,0x535BAB,0x535cc7,0x535D8F,0x535e57,0x535f1f,0x535fe7,0x5360af,0x536106,0x536151,0x5361a8,0x5361ff,0x53631b,0x536372,0x5364b7,0x5365d3,0x5366ef,0x5367b5,0x5368D1,0x536928,0x5369f0,0x536AB8,0x536B80,0x536C48,0x536d10,0x536d67,0x536DBE,0x536e15,0x536E6C,0x536f34,0x536ffc,0x537053,0x5370aa,0x537101"
  begin
    if Block.CountParams(FieldName) > 0 then Result := Block.GetParam(FieldName)
    else Result := '';
  end;

begin
  GovernmentGreetingCount := 0;
  Count := StrToInt(AnsiString(LookupLocalizedTextByKey('GovGreetings.CountGovGreetings')));
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('GovGreetings').CountBlocks(WideString(IntToStr(Index))) > 0 then
      Inc(GovernmentGreetingCount);
  SetLength(GovernmentGreetingDefinitions, GovernmentGreetingCount);
  GovernmentGreetingCount := 0;
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('GovGreetings').CountBlocks(WideString(IntToStr(Index))) <> 0 then
    begin
      Inc(GovernmentGreetingCount);
      EntryIndex := GovernmentGreetingCount - 1;
      Block := LanguageDataConfig.GetBlockByPath(WideString('GovGreetings.' + IntToStr(Index)));
      with GovernmentGreetingDefinitions[EntryIndex] do
      begin
        Name := WideString(IntToStr(Index));
        Text := ReadGovernmentGreetingField('Priority');
        if Text = '' then Priority := 10 else Priority := StrToInt(AnsiString(Text));
        Text := ReadGovernmentGreetingField('PlayerRace');
        PlayerRace := ParseRobotMapRaceMask(Text);
        Text := ReadGovernmentGreetingField('PlayerStatus');
        PlayerStatus := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Trader', AnsiString(Text)) > 0 then Include(PlayerStatus, rcTrader);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(PlayerStatus, rcPirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(PlayerStatus, rcWarrior);
        end;
        Text := ReadGovernmentGreetingField('PlayerRating');
        PlayerRating := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(PlayerRating, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(PlayerRating, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(PlayerRating, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(PlayerRating, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(PlayerRating, 5);
        end;
        Text := ReadGovernmentGreetingField('PlayerRank');
        PlayerRank := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Rookie', AnsiString(Text)) > 0 then Include(PlayerRank, 0);
          if Pos('Cadet', AnsiString(Text)) > 0 then Include(PlayerRank, 1);
          if Pos('Pilot', AnsiString(Text)) > 0 then Include(PlayerRank, 2);
          if Pos('Wingman', AnsiString(Text)) > 0 then Include(PlayerRank, 3);
          if Pos('Leader', AnsiString(Text)) > 0 then Include(PlayerRank, 4);
          if Pos('Ace', AnsiString(Text)) > 0 then Include(PlayerRank, 5);
          if Pos('Commander', AnsiString(Text)) > 0 then Include(PlayerRank, 6);
          if Pos('Admiral', AnsiString(Text)) > 0 then Include(PlayerRank, 7);
        end;
        Text := ReadGovernmentGreetingField('Goods');
        if Text = '' then Goods := 42
        else if Text = 'Food' then Goods := 0
        else if Text = 'Medicine' then Goods := 1
        else if Text = 'Technics' then Goods := 2
        else if Text = 'Luxury' then Goods := 3
        else if Text = 'Minerals' then Goods := 4
        else if Text = 'Alcohol' then Goods := 5
        else if Text = 'Arms' then Goods := 6
        else if Text = 'Narcotics' then Goods := 7
        else Goods := 42;
        Text := ReadGovernmentGreetingField('CurPlanetRace');
        CurPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadGovernmentGreetingField('CurPlanetRaceIsPlayerRace');
        if Text = 'Yes' then CurPlanetRaceIsPlayerRace := 0
        else if Text = 'No' then CurPlanetRaceIsPlayerRace := 1
        else CurPlanetRaceIsPlayerRace := 2;
        Text := ReadGovernmentGreetingField('CurPlanetRelations');
        CurPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(CurPlanetRelations, rlHostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(CurPlanetRelations, rlBad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(CurPlanetRelations, rlNormal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(CurPlanetRelations, rlGood);
          if Pos('Best', AnsiString(Text)) > 0 then Include(CurPlanetRelations, rlExcellent);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetGoodsPermit');
        if Text = 'Yes' then CurPlanetGoodsPermit := 0
        else if Text = 'No' then CurPlanetGoodsPermit := 1
        else CurPlanetGoodsPermit := 2;
        Text := ReadGovernmentGreetingField('CurPlanetGoodsCnt');
        CurPlanetGoodsCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Zero', AnsiString(Text)) > 0 then Include(CurPlanetGoodsCnt, 0);
          if Pos('Mini', AnsiString(Text)) > 0 then Include(CurPlanetGoodsCnt, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(CurPlanetGoodsCnt, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(CurPlanetGoodsCnt, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(CurPlanetGoodsCnt, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(CurPlanetGoodsCnt, 5);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetGoodsSale');
        CurPlanetGoodsSale := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(CurPlanetGoodsSale, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(CurPlanetGoodsSale, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(CurPlanetGoodsSale, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(CurPlanetGoodsSale, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(CurPlanetGoodsSale, 5);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetGoodsBuy');
        CurPlanetGoodsBuy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(CurPlanetGoodsBuy, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(CurPlanetGoodsBuy, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(CurPlanetGoodsBuy, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(CurPlanetGoodsBuy, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(CurPlanetGoodsBuy, 5);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetEconomy');
        CurPlanetEconomy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(CurPlanetEconomy, peAgricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(CurPlanetEconomy, peMixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(CurPlanetEconomy, peIndustrial);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetGoverment');
        CurPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, pgAnarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, pgDictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, pgMonarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, pgRepublic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, pgDemocracy);
        end;
        Text := ReadGovernmentGreetingField('RangerInCurStar');
        RangerInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(RangerInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(RangerInCurStar, 10);
        end;
        Text := ReadGovernmentGreetingField('PirateInCurStar');
        PirateInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateInCurStar, 10);
        end;
        Text := ReadGovernmentGreetingField('KlingInCurStar');
        KlingInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(KlingInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(KlingInCurStar, 10);
        end;
        Text := ReadGovernmentGreetingField('WarriorInCurStar');
        WarriorInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(WarriorInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(WarriorInCurStar, 10);
        end;
        Text := ReadGovernmentGreetingField('TransportInCurStar');
        TransportInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(TransportInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(TransportInCurStar, 10);
        end;
        Text := ReadGovernmentGreetingField('CurStarInBattle');
        if Text = 'Yes' then CurStarInBattle := 0
        else if Text = 'Any' then CurStarInBattle := 2
        else CurStarInBattle := 1;
        Text := ReadGovernmentGreetingField('ToPlanetRace');
        if Text = 'Any' then ToPlanetRace := [oiMaloc..oiGaal] else ToPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadGovernmentGreetingField('ToPlanetRaceIsPlayerRace');
        if Text = 'Yes' then ToPlanetRaceIsPlayerRace := 0
        else if Text = 'No' then ToPlanetRaceIsPlayerRace := 1
        else ToPlanetRaceIsPlayerRace := 2;
        Text := ReadGovernmentGreetingField('ToPlanetRaceIsCurPlanetRace');
        if Text = 'Yes' then ToPlanetRaceIsCurPlanetRace := 0
        else if Text = 'No' then ToPlanetRaceIsCurPlanetRace := 1
        else ToPlanetRaceIsCurPlanetRace := 2;
        Text := ReadGovernmentGreetingField('ToPlanetRelations');
        ToPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlHostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlBad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlNormal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlGood);
          if Pos('Best', AnsiString(Text)) > 0 then Include(ToPlanetRelations, rlExcellent);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetGoodsPermit');
        if Text = 'Yes' then ToPlanetGoodsPermit := 0
        else if Text = 'No' then ToPlanetGoodsPermit := 1
        else ToPlanetGoodsPermit := 2;
        Text := ReadGovernmentGreetingField('ToPlanetGoodsCnt');
        ToPlanetGoodsCnt := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Zero', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 0);
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ToPlanetGoodsCnt, 5);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetGoodsSale');
        ToPlanetGoodsSale := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ToPlanetGoodsSale, 5);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetGoodsBuy');
        ToPlanetGoodsBuy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Mini', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 1);
          if Pos('Small', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 2);
          if Pos('Average', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 3);
          if Pos('Big', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 4);
          if Pos('Huge', AnsiString(Text)) > 0 then Include(ToPlanetGoodsBuy, 5);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetEconomy');
        ToPlanetEconomy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, peAgricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, peMixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, peIndustrial);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetGoverment');
        ToPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgAnarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgDictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgMonarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgRepublic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, pgDemocracy);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetInCurStar');
        if Text = 'Any' then ToPlanetInCurStar := 2
        else if Text = 'No' then ToPlanetInCurStar := 1
        else ToPlanetInCurStar := 0;
        Text := ReadGovernmentGreetingField('RangerInToStar');
        RangerInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(RangerInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(RangerInToStar, 10);
        end;
        Text := ReadGovernmentGreetingField('PirateInToStar');
        PirateInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateInToStar, 10);
        end;
        Text := ReadGovernmentGreetingField('KlingInToStar');
        KlingInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(KlingInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(KlingInToStar, 10);
        end;
        Text := ReadGovernmentGreetingField('WarriorInToStar');
        WarriorInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(WarriorInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(WarriorInToStar, 10);
        end;
        Text := ReadGovernmentGreetingField('TransportInToStar');
        TransportInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(TransportInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(TransportInToStar, 10);
        end;
        Text := ReadGovernmentGreetingField('ToStarControlByKling');
        if Text = 'Yes' then ToStarControlByKling := 0
        else if Text = 'Any' then ToStarControlByKling := 2
        else ToStarControlByKling := 1;
        Text := ReadGovernmentGreetingField('ToStarInBattle');
        if Text = 'Yes' then ToStarInBattle := 0
        else if Text = 'Any' then ToStarInBattle := 2
        else ToStarInBattle := 1;
        Text := ReadGovernmentGreetingField('CurPlanetPirateClan');
        if Text = 'Yes' then CurPlanetPirateClan := 0
        else if Text = 'No' then CurPlanetPirateClan := 1
        else CurPlanetPirateClan := 2;
        Text := ReadGovernmentGreetingField('CurStarInBattlePirates');
        if Text = 'Yes' then CurStarInBattlePirates := 0
        else if Text = 'Any' then CurStarInBattlePirates := 2
        else CurStarInBattlePirates := 1;
        Text := ReadGovernmentGreetingField('PirateClanInCurStar');
        PirateClanInCurStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateClanInCurStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateClanInCurStar, 10);
        end;
        Text := ReadGovernmentGreetingField('PirateClanInToStar');
        PirateClanInToStar := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          for Item := 0 to 9 do
            if Pos(IntToStr(Item), AnsiString(Text)) > 0 then Include(PirateClanInToStar, Item);
          if Pos('Many', AnsiString(Text)) > 0 then Include(PirateClanInToStar, 10);
        end;
        Text := ReadGovernmentGreetingField('ToStarControlByPirates');
        if Text = 'Yes' then ToStarControlByPirates := 0
        else if Text = 'Any' then ToStarControlByPirates := 2
        else ToStarControlByPirates := 1;
        Text := ReadGovernmentGreetingField('CoalitionAlreadyDefeated');
        if Text = 'Yes' then CoalitionAlreadyDefeated := 0
        else if Text = 'No' then CoalitionAlreadyDefeated := 1
        else CoalitionAlreadyDefeated := 2;
        Text := ReadGovernmentGreetingField('DominatorsAlreadyDefeated');
        if Text = 'Yes' then DominatorsAlreadyDefeated := 0
        else if Text = 'No' then DominatorsAlreadyDefeated := 1
        else DominatorsAlreadyDefeated := 2;
        Text := ReadGovernmentGreetingField('PlayerPirateRank');
        PlayerPirateRank := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Noobie', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 0);
          if Pos('Kid', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 1);
          if Pos('Rader', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 2);
          if Pos('Skipper', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 3);
          if Pos('Rough', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 4);
          if Pos('Ataman', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 5);
          if Pos('Khan', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 6);
          if Pos('Baron', AnsiString(Text)) > 0 then Include(PlayerPirateRank, 7);
        end;
      end;
    end;
end;
{ @end $534F34 }

{ @routine $538150 InitializePlanetAdvertDefinitions }
procedure InitializePlanetAdvertDefinitions;
var
  Root, GroupBlock, Block: TBlockParEC;
  GroupIndex, BlockIndex, AdvertIndex, FoundIndex, Count: Integer;
  Text, Name: WideString;
begin
  Root := MainDataConfig.GetBlockByPath('Data\PlanetAdvt');
  SetLength(PlanetAdvertDefinitions, Root.GetBlockCount);
  for GroupIndex := 0 to High(PlanetAdvertDefinitions) do
  begin
    GroupBlock := Root.GetBlockByIndex(GroupIndex);
    PlanetAdvertDefinitions[GroupIndex].Position := GetPointGI(GroupBlock.GetParamByPathOrMarker('Info.Pos'));
    if GroupBlock.GetBlock('Info').CountParams('Image1') > 0 then
      PlanetAdvertDefinitions[GroupIndex].Image1 := GroupBlock.GetParamByPathOrMarker('Info.Image1');
    if GroupBlock.GetBlock('Info').CountParams('Image2') > 0 then
      PlanetAdvertDefinitions[GroupIndex].Image2 := GroupBlock.GetParamByPathOrMarker('Info.Image2');
    Count := GroupBlock.GetBlockCount;
    SetLength(PlanetAdvertDefinitions[GroupIndex].Adverts, Count - 2);
    AdvertIndex := 0;
    for BlockIndex := 0 to Count - 1 do
    begin
      Text := GroupBlock.GetBlockNameByIndex(BlockIndex);
      if (Text <> 'List') and (Text <> 'Info') then
      begin
        Block := GroupBlock.GetBlockByIndex(BlockIndex);
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Name := Text;
        if Block.CountParams('Image1') > 0 then
          PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Image1 := Block.GetParam('Image1');
        if Block.CountParams('Image2') > 0 then
          PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Image2 := Block.GetParam('Image2');
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := 0;
        if Block.CountParams('War') > 0 then
        begin
          PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := ExtractSignedDigitsToIntW(Block.GetParam('War'));
          if PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War < -1 then
            PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := -1
          else if PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War > 1 then
            PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := 1;
        end;
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 42;
        if Block.CountParams('Goods') > 0 then
        begin
          Text := Block.GetParam('Goods');
          if Text = 'Food' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 0
          else if Text = 'Medicine' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 1
          else if Text = 'Technics' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 2
          else if Text = 'Luxury' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 3
          else if Text = 'Minerals' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 4
          else if Text = 'Alcohol' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 5
          else if Text = 'Arms' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 6
          else if Text = 'Narcotics' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 7
          else PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 42;
        end;
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner := [];
        if Block.CountParams('Owner') > 0 then
        begin
          Text := Block.GetParam('Owner');
          if Pos('Maloc', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, oiMaloc);
          if Pos('Peleng', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, oiPeleng);
          if Pos('People', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, oiHuman);
          if Pos('Fei', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, oiFeyan);
          if Pos('Gaal', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, oiGaal);
        end;
        Inc(AdvertIndex);
        if AdvertIndex >= Count - 1 then Break;
      end;
    end;
    Block := GroupBlock.GetBlock('List');
    SetLength(PlanetAdvertDefinitions[GroupIndex].Lists, Block.GetParamCount);
    for BlockIndex := 0 to High(PlanetAdvertDefinitions[GroupIndex].Lists) do
    begin
      PlanetAdvertDefinitions[GroupIndex].Lists[BlockIndex].Weight := ExtractDigitsToIntW(Block.GetParamName(BlockIndex));
      Text := Block.GetParamValue(BlockIndex);
      Count := CountDelimitedPartsW(Text, ',');
      SetLength(PlanetAdvertDefinitions[GroupIndex].Lists[BlockIndex].Indices, Count);
      for AdvertIndex := 0 to Count - 1 do
      begin
        Name := TrimWideString(ExtractDelimitedPartW(Text, AdvertIndex, ','));
        FoundIndex := 0;
        // Native stops before comparing the last entry, and retains it as fallback.
        while FoundIndex < High(PlanetAdvertDefinitions[GroupIndex].Adverts) do
        begin
          if PlanetAdvertDefinitions[GroupIndex].Adverts[FoundIndex].Name = Name then Break;
          Inc(FoundIndex);
        end;
        if FoundIndex > High(PlanetAdvertDefinitions[GroupIndex].Adverts) then
          RaiseWideMessage('PlanetAdvtInit. Not found: ' + Name);
        PlanetAdvertDefinitions[GroupIndex].Lists[BlockIndex].Indices[AdvertIndex] := FoundIndex;
      end;
    end;
  end;
end;
{ @end $538150 }

{ @routine $538C18 GetInnermostScreenLoop }
function GetInnermostScreenLoop: TMessageLoopGI;
begin
  Result := TMessageLoopGI(RegisteredScreens[CurrentScreenId]);
  while Result.ChildLoop <> nil do Result := Result.ChildLoop;
end;
{ @end $538C18 }

end.
