unit Globals;

interface

uses fMainForm, fCfgSettings, fGameEnd, fAbout, fIntroduction, fGameSettings, fGameSettings2, fLoadAB, fAchievements, fFilm, fRating2, fGameMenu, fGameLoad, fPlanet, fGov, fInfo, fScaner, fRewards, fGalaxy2, fGoodsShop2, EC_Expression, fTalk, ab_MainForm, fLoad, fJump, ThreadCalc, fJournal, fSelectFace, fLoadQuest, fPlanetQuest, fPlanetNO, aItem, aGalaxyStruct, aShip, fScore, fLoadRobot, fStarMap, aEFilm, aEFilmEnd, SE_Space, SE_Planet, SE_Process, aPlanet, fShip2, fHangar, fRuinsTalk, fEquipmentShop, fSaveManager, GI_GraphButton, GI_MessageLoop, EC_Buf, EC_Struct, fFilmFile, SyncObjs, Classes, Types;

const
  PersistentMessageLifetimeTurns = 1000000; // Finite native lifetime for retained notices.

type
  TScriptVariableTypeNames = array[TScriptValueKind] of WideString;

  // PlayerMessagePresentations order, also persisted in the message queue.
  TPlayerMessageKind = (
    message_galaxy_news = 0,
    message_radio = 1,
    message_ship_positive = 2,
    message_quest_active = 3,
    message_quest_succeeded = 4,
    message_quest_cancelled = 5, // QuestCancel presentation also carries generic warnings.
    message_tip = 6,
    message_user_note = 7,
    message_ship_negative = 8,
    message_storage = 9,
    message_radio_with_player = 10 // Radio message with the player among its ship targets.
  ); // @size $01

  // Greeting configuration predicates; omitted-field defaults vary by rule.
  TGreetingCondition = (
    greeting_match_true = 0, greeting_match_false = 1, greeting_match_any = 2
  ); // @size $01
  TGreetingFlightKind = (
    greeting_flight_any = 0, greeting_flight_to_planet = 1, greeting_flight_to_star = 2,
    greeting_flight_to_item = 3, greeting_flight_to_ship = 4
  ); // @size $01

  TGreetingShipCategories = set of TGreetingShipCategory; // @size $01
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
    constructor Create; // @addr $7A5FE8
    destructor Destroy; override; // @addr $7A6034
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
    SpaceObject: TPlanetSE; // @offset $0C Retained until UI shutdown.
  end;

  TSputnikTempl = class(TObject) // @size $0C
  public
    Radius: Integer; // @offset $04
    MaskName: WideString; // @offset $08
  end;

  TPlayerMessageKindSet = set of TPlayerMessageKind; // @size $02 Native exclusion mask for persistent-message searches.

  TPlayerMessageTarget = record // @size 0x08
    ShipId: Cardinal; // @offset 0x00
    PlanetId: Cardinal; // @offset 0x04
  end;

  TMessagePlayerTypeGraph = record // @size $10
    NormalImage: WideString; // @offset $00
    ActiveImage: WideString; // @offset $04
    PressedImage: WideString; // @offset $08
    LifetimeTurns: Integer; // @offset $0C
  end;

  TPlayerMessagePresentations = array[TPlayerMessageKind] of TMessagePlayerTypeGraph;

var
  PlayerMessagePresentations: array[TPlayerMessageKind] of TMessagePlayerTypeGraph = (
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
    (NormalImage: 'Ether2N'; ActiveImage: 'Ether2A'; PressedImage: 'Ether2D'; LifetimeTurns: 0)); // @addr $812DAC Native image defaults and turn lifetimes.

type
  TMessagePlayer = class(TObjectEx) // @size 0x44
  public
    Prev: TMessagePlayer; // @offset 0x04
    Next: TMessagePlayer; // @offset 0x08
    Key: WideString; // @offset 0x0C
    Kind: TPlayerMessageKind; // @offset 0x10
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

    constructor Create; // @addr 0x007A5458 @note "Does not link the object into the global message queue."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x007A549C
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr 0x007A5540 @note "Leaves linkage and Button untouched. ImageNameOverride is present only from save version 109 onward."
    function GetNormalImageName: WideString; // @addr 0x007A5644
    function GetActiveImageName: WideString; // @addr 0x007A5688
    function GetPressedImageName: WideString; // @addr 0x007A56CC
  end;

function FindScriptTemplateIndex(const Name: WideString): Integer; // @addr $7A6068 @note "Case-sensitive; returns -1 when absent. Requires the template list. Native callers include UI loading and script builtins."

procedure CollectInactiveScriptTemplates(Dest: TList); // @addr $7A60AC @note "Clears Dest, borrows templates with ActiveScriptIndex < 0, then performs twice Count seeded swaps. Chaotic RNG mode ignores the seeds."

procedure RecreateSpaceProcess(const ConfigName: WideString); // @addr $7A538C
function ShowPlayerTipOnce(Index: Integer): Boolean; // @addr $7A61A4 @note "Sets the shown bit and enqueues localized Tips.00-style player text; returns whether a new tip was shown."
function HasShownPlayerTip(Index: Integer): Boolean; // @addr $7A62EC

function SelectSpaceImageTemplateFromSeed(Kind: Integer; Seed: Cardinal): Integer; // @addr $7A62FC @note "Weighted selection restricted to Kind; returns 0 if no weight is available."
function SelectSpaceImageTemplate(Kind: Integer): Integer; // @addr $7A6398
function FindPlanetSpaceTemplateIndex(Style, StyleVariant: Integer): Integer; // @addr $7A6E68 @note "Raises when no template matches the two SE.Planet.Style values."
procedure HandleRuntimeExitCheck1; // @addr $7A63B4 @note "Retained empty ExitScreenLoop test; assigned by Rangers.start to an otherwise unread hook."
procedure HandleRuntimeExitCheck2; // @addr $7A63C0 @note "Retained empty ExitScreenLoop test; assigned by Rangers.start to an otherwise unread hook."

procedure InitializeScriptHostRuntime; // @addr 0x0079FD48
procedure FinalizeScriptHostRuntime; // @addr 0x0079FE88
function ParseRobotMapRaceMask(Text: WideString): TOwnerMask; // @addr $7A63CC @ida "unsigned __int8 __usercall $name@<al>(unsigned __int16 *Text@<eax>);"
function FindRobotMapById(MapId: Integer): Integer; // @addr $7A6E34 Returns -1 for an unknown map.
procedure InitializeRobotMapDefinitions; // @addr $7A65F4
procedure InitializeShipGreetingDefinitions; // @addr $7A6F0C
procedure InitializeGovernmentGreetingDefinitions; // @addr $7ACE8C
procedure InitializePlanetAdvertDefinitions; // @addr $7AFDB4
procedure InitializeGlobalUiRuntime; // @addr 0x007A0124
procedure FinalizeGlobalUiRuntime; // @addr 0x007A4AF8
procedure ResetScriptHostRuntimeState; // @addr 0x007A51AC
function FindMessageLoop(Name: WideString): TMessageLoopGI; // @addr 0x007A4A64 @note "Case-sensitive; returns nil when absent."
procedure RunMainScreenStateLoop; // @addr 0x007A53C0 @note "Consumes RequestedScreenId before each run; zero ends dispatch. StarMap, Film and arcade battle use RunContinuous."

procedure SwapTurnFilms; // @addr $7A5440 Exchanges the producer and playback films.
function GetInnermostScreenLoop: TMessageLoopGI; // @addr $7B0708 Follows ChildLoop from the current registered screen.
function FindPlayerMessageExceptKinds(const Key: WideString; ExcludedKinds: TPlayerMessageKindSet; SkipLock: Boolean): TMessagePlayer; // @addr $7A5C84 @ida "TMessagePlayer *__usercall $name@<eax>(unsigned __int16 *Key@<eax>, unsigned __int16 ExcludedKinds@<dx>, bool SkipLock@<cl>);" Key is an optional substring; returned queue node is borrowed.
function RemovePlayerMessagesExceptKinds(Key: WideString; ExcludedKinds: TPlayerMessageKindSet; SkipLock: Boolean): Boolean; // @addr $7A58DC @ida "bool __usercall $name@<al>(unsigned __int16 *Key@<eax>, unsigned __int16 ExcludedKinds@<dx>, bool SkipLock@<cl>);" Returns whether any queued message was removed.
procedure ClearPersistentPlayerMessages; // @addr 0x007A5710
function CountPersistentPlayerMessages: Integer; // @addr 0x007A5778
function IsPersistentPlayerMessageQueued(MessageEntry: TMessagePlayer; SkipLock: Boolean): Boolean; // @addr 0x007A57D0
procedure RemovePersistentPlayerMessage(MessageEntry: TMessagePlayer; SkipLock: Boolean); // @addr 0x007A5848 @note "Requires a queued node; unlinks and frees it."
function FindPlayerBubbleByText(const Text: WideString; SkipLock: Boolean): TMessagePlayer; // @addr 0x007A5998 @note "Returns a borrowed queue node or nil."
function FindPlayerBubbleByKey(const Key: WideString; SkipLock: Boolean): TMessagePlayer; // @addr 0x007A5A20 @note "Returns a borrowed queue node or nil."
procedure RemovePlayerBubblePages(const Prefix: WideString; FirstPage: Integer); // @addr $7A5B54 @note "Removes matching prefix keys whose integer suffix is at least FirstPage; leaves unnumbered keys alone."
procedure RemovePlayerBubbleByKey(const Key: WideString); // @addr 0x007A5AA8 @note "Removes only the first exact match."
function CreatePersistentPlayerMessage: TMessagePlayer; // @addr 0x007A5D2C @note "Appends a new node owned by the global message queue."
function AddOrUpdatePlayerBubble(Kind: TPlayerMessageKind; Turn: Integer; const Text, Key: WideString): TMessagePlayer; // @addr 0x007A5DC0 @note "Returns a borrowed queue node. An existing key updates kind/turn and nonempty text; otherwise an exact text match is returned unchanged."
procedure PruneExpiredPersistentPlayerMessages; // @addr 0x007A5EFC

var

var
  MainMenuScreen: TfMainForm; // @addr 0x0081CB64
  NewGameScreen: TfGameSettings2; // @addr 0x0081CB68
  IntroductionScreen: TfIntroduction; // @addr 0x0081CB6C
  HangarScreen: TfHangar; // @addr $81CB70
  PlanetScreen: TfPlanet; // @addr $81CB74
  UninhabitedPlanetScreen: TfPlanetNO; // @addr $81CB78
  PlanetQuestScreen: TfPlanetQuest; // @addr 0x0081CB7C
  RuinsTalkScreen: TfRuinsTalk; // @addr $81CB80
  ArcadeBattleScreen: TfAB; // @addr $81CB84
  EquipmentShopScreen: TfEquipmentShop; // @addr $81CB88
  GoodsShopScreen: TfGoodsShop2; // @addr $81CB8C
  GovernmentScreen: TfGov; // @addr $81CB90
  InfoScreen: TfInfo; // @addr $81CB94
  RangerRatingScreen: TfRating2; // @addr 0x0081CB98
  RewardsScreen: TfRewards; // @addr $81CB9C
  ShipScreen: TfShip2; // @addr 0x0081CBA0
  TalkScreen: TfTalk; // @addr $81CBA4
  ScannerScreen: TfScaner; // @addr $81CBA8
  StarMapScreen: TfStarMap; // @addr 0x0081CBAC
  FilmScreen: TfFilm; // @addr 0x0081CBB0
  GalaxyScreen: TfGalaxy2; // @addr $81CBB4
  JumpScreen: TfJump; // @addr $81CBB8
  LoadScreen: TfLoad; // @addr $81CBBC
  SaveManagerScreen: TfSaveManager; // @addr 0x0081CBC0
  GameLoadScreen: TfGameLoad; // @addr $81CBC4
  GameMenuScreen: TfGameMenu; // @addr $81CBC8
  SettingsScreen: TfCfgSettings; // @addr 0x0081CBCC
  GameEndScreen: TfGameEnd; // @addr $81CBD0
  AboutScreen: TfAbout; // @addr 0x0081CBD4
  ScoreScreen: TfScore; // @addr 0x0081CBD8
  SelectFaceScreen: TfSelectFace; // @addr $81CBDC
  SpaceObjectUiLoop: TMessageLoopGI; // @addr $81CBE0 Unregistered loop centered on the back buffer; hosts space-object controls.
  JournalScreen: TfJournal; // @addr $81CBE4
  LoadRobotScreen: TfLoadRobot; // @addr $81CBE8
  LoadQuestScreen: TfLoadQuest; // @addr 0x0081CBEC
  LoadArcadeScreen: TfLoadAB; // @addr $81CBF0
  AchievementsScreen: TfAchievements; // @addr $81CBF4 Native UI shutdown does not free this screen.
var
  SpaceViewPosition: TPointF; // @addr $81CBF8 Map scroll offset and scene sound attenuation origin.
  FilmCameraFollow: Boolean; // @addr $81CC00
var

  TalkShip: TShip; // @addr 0x0081CC04
  TalkPlanet: TPlanet; // @addr $81CC08 Planet dialogue target, assigned by TPlanet.RequestDialog.
  TalkScripted: Boolean; // @addr $81CC0C Set for the scripted Keller dialogue.
  TalkType: TTalkEventKind; // @addr $81CC0D tk* conversation ID set by TShip.ShowPlayerDialogue and exposed by SF_GetTalkType.
  TalkAmount: Integer; // @addr $81CC10 Negotiated amount; ShowPlayerDialogue overwrites it only for positive inputs.
  TalkResponse: Byte; // @addr $81CC14 Response selected by the conversation UI.
  TalkText: WideString; // @addr $81CC18 Message supplied to the conversation UI.
var
  ScriptUseItem: TItem; // @addr $81CC1C Item currently executing OnUse; native runner clears it after success.
  ScriptItemContextStack: TList; // @addr $81CC20
  ScriptItemInfoContextStack: TList; // @addr $81CC24
  ScriptActionShipStack: TList; // @addr $81CC28
  ScriptActionObject1Stack: TList; // @addr $81CC2C
  ScriptActionObject2Stack: TList; // @addr $81CC30
  ScriptActionParamStack: TList; // @addr $81CC34
  ScriptActionTypeStack: TList; // @addr $81CC38
  ScreenLoadMode: Byte; // @addr $81CC3C @note "Startup sets 0, or 3 for a screen with composite loading assets."
var

  ScriptTemplates: TList; // @addr $81CC40 @note "Owns native TScriptTemplUnit entries."
  SharedScriptVariables: TVarArrayEC; // @addr $81CC44 @note "Shared scope used by script compilation, execution and text-quest external parameters."
  GlobalScriptVariables: TVarArrayEC; // @addr $81CC48 @note "Persistent script globals, initially GRunFrom and GRunStar."
  ScriptTemplateStartRequested: Boolean; // @addr $81CC4C Set by script condition code; checked after running each inactive template.
  LastLoadedPlayerName: WideString; // @addr $81CC50 Player-name snapshot used by the end-game text.
var
  ReloadScriptTemplates: Boolean = True; // @addr $812E5C @note "Native initial value is True. Reset sets this flag; UI initialization reloads script and ship templates then clears it."
  ReloadModsRequested: Boolean = False; // @addr $812E60
  StandaloneQuestMode: Boolean = False; // @addr $812E64 @note "The quest selector sets True; planet/government/script launches set False. Guards campaign quest checks and turn advancement."
  ScannerTarget: TObject = nil; // @addr $812E68 Borrowed target passed from the star map to the scanner screen.
  ScriptDialogIndex: Integer = -1; // @addr $812E6C Selected script dialogue; -1 while resolving a dialogue variable.
var
  AwardSubject: TObject = nil; // @addr $812E70 Borrowed ship selected by inventory, scanner or ranger ranking for the medals screen.
  PlayerStarDayPrepared: Boolean = False; // @addr 0x00812E74
var
  PreviousFilmActivity: Cardinal = 0; // @addr $812E78
  FilmSoundEffectsEnabled: Boolean = True; // @addr $812E7C Temporarily disabled while the film slider seeks through steps.
  TurnCalculationThread: TThreadCalc = nil; // @addr $812E80 @note "Owned here; ThreadCalc and Rangers access it through the imported reference cell."
  DefaultArcadeLaserEffect: WideString = 'Laser.W1'; // @addr $812E84 Native default; callers remain to be identified.
  DefaultArcadeHitEffect: WideString = 'Anim.H1'; // @addr $812E88 Native default; callers remain to be identified.
  DefaultArcadeExplosionEffect: WideString = 'Anim.E1'; // @addr $812E8C Native default; callers remain to be identified.
var
  FilmHistory: TFilmFile = nil; // @addr 0x00812E90
  CacheLoader: TCacheLoader = nil; // @addr 0x00812E94
var
  SaveManagerMode: TSaveManagerMode = save_dialog_load; // @addr 0x00812E98
  TalkRequestEvent: Cardinal = 0; // @addr $812E9C @note "Auto-reset event: ship/planet turn workers request a player conversation."
  TalkCompletedEvent: Cardinal = 0; // @addr $812EA0 @note "Auto-reset event signaled when the star-map UI returns from conversation."
  ScriptUiRequestEvent: Cardinal = 0; // @addr $812EA4 @note "Raised by the turn thread when requesting a UI-side conversation."
  ScriptUiAbortEvent: Cardinal = 0; // @addr $812EA8 @note "Aborts a pending turn-thread conversation wait; the worker returns False."
  PlanetRenderTemplates: TList = nil; // @addr $812EAC Owns TPlanetTempl instances.
var
  MinimapFrameCounter: Integer = 0; // @addr $812EB0 Film/star-map draw cadence; reset by manual minimap scrolling.
  Skip1C: Boolean = False; // @addr $812EB4
  SkipVideo: Boolean = False; // @addr $812EB8
  SkipIntro: Boolean = False; // @addr $812EBC
var
  NewGameGenerationThread: TThreadCreateNewGame; // @addr 0x0081CC54
  ShownPlayerTips: Cardinal; // @addr $81CC58 Bit mask; native shifts use the low five bits of the tip index.
var
  StarMapWeaponPanelOpen: Boolean; // @addr $81CC5C Toggled by TfStarMap.ToggleWeaponPanelClicked; reset on arcade exit.
var

  PrimaryFilm: TEFilm; // @addr 0x0081CC60
  SecondaryFilm: TEFilm; // @addr 0x0081CC64
var
  TrailingFilmEffects: TEFilmEnd; // @addr $81CC68 Native shared trailing-effect owner.
var

  SpaceProcess: TProcessSE; // @addr $81CC6C
var
  ActiveLoadBuffer: TBufEC; // @addr 0x0081CC70 @note "Borrowed during LoadGameFromFile; exposed for progress reporting."
var

  PersistentPlayerMessageLock: TCriticalSection; // @addr $81CC74
  FirstPersistentPlayerMessage: TMessagePlayer; // @addr 0x0081CC78
  LastPersistentPlayerMessage: TMessagePlayer; // @addr 0x0081CC7C
  ArcadeExplosionSounds: array of WideString; // @addr $81CC80 ABSound.Explosion values.
  ArcadeItemSounds: array of WideString; // @addr $81CC84 ABSound.Item values.
  ArcadeHitSounds: array of WideString; // @addr $81CC88 ABSound.Hit values.
  ArcadeWeaponFirstSounds: array[0..17] of WideString; // @addr $81CC8C ABSound.WeaponFirst.
  ArcadeWeaponLoopSounds: array[0..17] of WideString; // @addr $81CCD4 ABSound.WeaponLoop entries, after the time value.
var
  ArcadeWeaponLoopTicks: array[0..17] of Integer; // @addr $81CD1C First configured value divided by 20; -1 when absent.
  RaceShipTemplates: array[TOwnerId, hull_ranger..hull_diplomat] of TObjectSE; // @addr $81CD64 @note "Retained SE.Ship templates indexed by owner and six ordinary hull kinds."
  BlazerShipTemplates: array[TDominatorKind] of TObjectSE; // @addr $81CE24
  KellerShipTemplates: array[TDominatorKind] of TObjectSE; // @addr $81CE44
  TerronShipTemplates: array[TDominatorKind] of TObjectSE; // @addr $81CE64
  PirateClanShipTemplates: array[TOwnerId] of TObjectSE; // @addr $81CE84
  PlanetSpaceTemplates: array of TPlanetSpaceTemplate; // @addr $81CEA4

type
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
  UselessItemRemainsCount: Integer; // @addr $81CEA8 UselessItems.CntRemains.
  RobotMapDefinitions: array of TRobotMap; // @addr $81CEAC

type
  TShipGreetingsInfo = record // @size $84
    Name: WideString; // @offset $00
    Priority: Integer; // @offset $04
    AutoTalk: TGreetingCondition; // @offset $08
    FlyType: TGreetingFlightKind; // @offset $09
    ShipType: TGreetingShipCategories; // @offset $0A
    Relations: TRelationLevels; // @offset $0B
    ShipRace: TOwnerMask; // @offset $0C
    PlayerRace: TOwnerMask; // @offset $0D
    ShipRaceIsPlayerRace: TGreetingCondition; // @offset $0E
    PlayerAttackGoodShip: TGreetingCondition; // @offset $0F
    InFear: TGreetingCondition; // @offset $10
    ShipBadFlyToShip: TGreetingCondition; // @offset $11
    ShipBadType: TGreetingShipCategories; // @offset $12
    ShipBadRace: TOwnerMask; // @offset $13
    ShipFlyToPlayer: TGreetingCondition; // @offset $14
    PlayerFlyToShip: TGreetingCondition; // @offset $15
    PlayerIsShipBad: TGreetingCondition; // @offset $16
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
    ShipHaveGoods: TGreetingCondition; // @offset $2D
    PlayerHaveGoods: TGreetingCondition; // @offset $2E
    ShipGoodsTypeCnt: TGreetingCountMask; // @offset $2F
    PlayerGoodsTypeCnt: TGreetingCountMask; // @offset $31
    ShipMayScanPlayer: TGreetingCondition; // @offset $33
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
    LastPlanetIsHomePlanet: TGreetingCondition; // @offset $43
    LastPlanetRaceIsShipRace: TGreetingCondition; // @offset $44
    LastPlanetRaceIsPlayerRace: TGreetingCondition; // @offset $45
    LastPlanetEconomy: TPlanetEconomies; // @offset $46
    LastPlanetGovernment: TPlanetGovernments; // @offset $47
    LastPlanetInCurStar: TGreetingCondition; // @offset $48
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
    ToPlanetIsHomePlanet: TGreetingCondition; // @offset $5A
    ToPlanetRaceIsShipRace: TGreetingCondition; // @offset $5B
    ToPlanetRaceIsPlayerRace: TGreetingCondition; // @offset $5C
    ToPlanetEconomy: TPlanetEconomies; // @offset $5D
    ToPlanetGovernment: TPlanetGovernments; // @offset $5E
    ToPlanetIsLastPlanet: TGreetingCondition; // @offset $5F
    ToPlanetRaceIsLastPlanetRace: TGreetingCondition; // @offset $60
    HomePlanetInToStar: TGreetingCondition; // @offset $61
    HomePlanetInCurStar: TGreetingCondition; // @offset $62
    ToStarControlByKling: TGreetingCondition; // @offset $63
    ToStarInBattle: TGreetingCondition; // @offset $64
    RangerInToStar: TGreetingCountMask; // @offset $65
    PirateInToStar: TGreetingCountMask; // @offset $67
    KlingInToStar: TGreetingCountMask; // @offset $69
    WarriorInToStar: TGreetingCountMask; // @offset $6B
    TransportInToStar: TGreetingCountMask; // @offset $6D
    ItemType: WideString; // @offset $70
    ShipNeedInItem: TGreetingCondition; // @offset $74
    ToShipType: TGreetingShipCategories; // @offset $75
    ToShipRace: TOwnerMask; // @offset $76
    ToShipInPlanet: TGreetingCondition; // @offset $77
    ToShipBad: TGreetingCondition; // @offset $78
    ToShipRelations: TRelationLevels; // @offset $79
    RankShipWithPlayerExtra: TGreetingMask; // @offset $7A Second field loaded from RankShipWithPlayer; the normal-ship consumer compares PirateRank.
    PlayerPirateRank: TGreetingMask; // @offset $7B
    Female: Byte; // @offset $7C
    ToStarControlByPirates: TGreetingCondition; // @offset $7D
    PirateClanInCurStar: TGreetingCountMask; // @offset $7E
    PirateClanInToStar: TGreetingCountMask; // @offset $80
    CoalitionAlreadyDefeated: TGreetingCondition; // @offset $82
    DominatorsAlreadyDefeated: TGreetingCondition; // @offset $83
  end;

  // Three-valued predicates preserve each rule's omitted-field default.
  TGovGreetingsInfo = record // @size $44
    Name: WideString; // @offset $00
    Priority: Integer; // @offset $04
    PlayerRace: TOwnerMask; // @offset $08
    PlayerStatus: TRangerCareerSet; // @offset $09
    PlayerRating: TGreetingMask; // @offset $0A
    PlayerRank: TGreetingMask; // @offset $0B
    Goods: Byte; // @offset $0C
    CurPlanetRace: TOwnerMask; // @offset $0D
    CurPlanetRaceIsPlayerRace: TGreetingCondition; // @offset $0E
    CurPlanetRelations: TRelationLevels; // @offset $0F
    CurPlanetGoodsPermit: TGreetingCondition; // @offset $10
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
    CurStarInBattle: TGreetingCondition; // @offset $20
    ToPlanetRace: TOwnerMask; // @offset $21
    ToPlanetRaceIsPlayerRace: TGreetingCondition; // @offset $22
    ToPlanetRaceIsCurPlanetRace: TGreetingCondition; // @offset $23
    ToPlanetRelations: TRelationLevels; // @offset $24
    ToPlanetGoodsPermit: TGreetingCondition; // @offset $25
    ToPlanetGoodsCnt: TGreetingMask; // @offset $26
    ToPlanetGoodsSale: TGreetingMask; // @offset $27
    ToPlanetGoodsBuy: TGreetingMask; // @offset $28
    ToPlanetEconomy: TPlanetEconomies; // @offset $29
    ToPlanetGovernment: TPlanetGovernments; // @offset $2A
    ToPlanetInCurStar: TGreetingCondition; // @offset $2B
    RangerInToStar: TGreetingCountMask; // @offset $2C
    PirateInToStar: TGreetingCountMask; // @offset $2E
    KlingInToStar: TGreetingCountMask; // @offset $30
    WarriorInToStar: TGreetingCountMask; // @offset $32
    TransportInToStar: TGreetingCountMask; // @offset $34
    ToStarControlByKling: TGreetingCondition; // @offset $36
    ToStarInBattle: TGreetingCondition; // @offset $37
    CurPlanetPirateClan: TGreetingCondition; // @offset $38
    CurStarInBattlePirates: TGreetingCondition; // @offset $39
    PirateClanInCurStar: TGreetingCountMask; // @offset $3A
    PirateClanInToStar: TGreetingCountMask; // @offset $3C
    ToStarControlByPirates: TGreetingCondition; // @offset $3E
    CoalitionAlreadyDefeated: TGreetingCondition; // @offset $3F
    DominatorsAlreadyDefeated: TGreetingCondition; // @offset $40
    PlayerPirateRank: TGreetingMask; // @offset $41
  end;

  TPlanetAdvtUnit = record // @size $14
    Name: WideString; // @offset $00
    Image1: WideString; // @offset $04
    Image2: WideString; // @offset $08
    War: Integer; // @offset $0C Clamped to -1..1.
    Goods: Byte; // @offset $10 0..7, or goods_unspecified when absent/unrecognized.
    Owner: TOwnerMask; // @offset $11
  end;

  // Weighted planet advert sequence.
  TPlanetAdvtList = object // @size $08
    Weight: Integer; // @offset $00 Numeric PlanetAdvt.List parameter name; weighted selection in TPlanetSE.StartRandomSurfaceAnimation.
    Indices: array of Integer; // @offset $04
  end;

  TPlanetAdvtGroup = record // @size $18
    Image1: WideString; // @offset $00
    Image2: WideString; // @offset $04
    Position: TPoint; // @offset $08
    Adverts: array of TPlanetAdvtUnit; // @offset $10
    Lists: array of TPlanetAdvtList; // @offset $14
  end;

  PPlanetAdvertDefinition = ^TPlanetAdvtGroup;

var
  ShipGreetingDefinitions: array of TShipGreetingsInfo; // @addr $81CEB0
var
  ShipGreetingCount: Integer; // @addr $81CEB4
  GovernmentGreetingDefinitions: array of TGovGreetingsInfo; // @addr $81CEB8
var
  GovernmentGreetingCount: Integer; // @addr $81CEBC
  PlanetAdvertDefinitions: array of TPlanetAdvtGroup; // @addr $81CEC0

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

// @unit-initialization $8079C8
// @unit-finalization $7B0728

uses aPacket, aSaveLoad, aScript, aPath, Robot, aConst, aPlayer, GI_Main, PopUp, EC_CacheGAI, EC_Thread, EC_Cache, aGalaxy, aMyFunction, EC_BlockPar, GR_Main, EC_Str, GlobalsV, Math, SysUtils, Windows, ab_Global;

{ @routine $79FD48 InitializeScriptHostRuntime }
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
  TurnCalculationThread.SetPriority(priority_below_normal);
  ScriptTemplates := TList.Create;
  GlobalScriptVariables := TVarArrayEC.Create;
  SharedScriptVariables := TVarArrayEC.Create;
  GlobalScriptVariables.Add('GRunFrom', value_int32).SetInt(0);
  GlobalScriptVariables.Add('GRunStar', value_uint32).SetInt(0);
  InitializeScriptEngine;
end;
{ @end $79FD48 }

{ @routine $79FE88 FinalizeScriptHostRuntime }
procedure FinalizeScriptHostRuntime;
var
  Race: TOwnerId; Kind: THullType; KlingKind: TDominatorKind;
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
  for Race := owner_maloc to owner_pirate do
  begin
    for Kind := hull_ranger to hull_diplomat do
      if RaceShipTemplates[Race, Kind] <> nil then
        ReleaseSpaceObject(RaceShipTemplates[Race, Kind]);
    if PirateClanShipTemplates[Race] <> nil then
      ReleaseSpaceObject(PirateClanShipTemplates[Race]);
  end;
  for KlingKind := Low(TDominatorKind) to High(TDominatorKind) do
    if KlingKind <> dominator_boss then
    begin
      if BlazerShipTemplates[KlingKind] <> nil then ReleaseSpaceObject(BlazerShipTemplates[KlingKind]);
      if KellerShipTemplates[KlingKind] <> nil then ReleaseSpaceObject(KellerShipTemplates[KlingKind]);
      if TerronShipTemplates[KlingKind] <> nil then ReleaseSpaceObject(TerronShipTemplates[KlingKind]);
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
{ @end $79FE88 }

var
  ScriptVariableTypeNames: TScriptVariableTypeNames = (
    'Unknown', 'Int', 'DW', 'Float', 'Str', 'ExternFun', 'LibraryFun',
    'Fun', 'Class', 'Array', 'Ref'); // @addr $812EC0

{ @routine $7A0124 InitializeGlobalUiRuntime }
procedure InitializeGlobalUiRuntime;
var
  Race: TOwnerId;
  Index, TemplateIndex, Count: Integer;
  SatelliteTemplate: TSputnikTempl;
  PlanetTemplate: TPlanetTempl;
  Section: TBlockParEC;
  KlingKind: TDominatorKind; Kind: THullType;
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
    ScrollTime := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('ScrollTime'));
  if UserSettingsConfig.CountParamsByPath('ScrollStep') > 0 then
    ScrollStep := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('ScrollStep'));
  if UserSettingsConfig.CountParamsByPath('ScrollSense') > 0 then
    ScrollSense := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('ScrollSense'));
  if UserSettingsConfig.CountParamsByPath('FilmSpeed') > 0 then
    FilmSpeed := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('FilmSpeed'));
  ScrollInteriorRect := Classes.Rect(ScrollSense, ScrollSense, GameScreenWidth - ScrollSense, GameScreenHeight - ScrollSense);
  if not IsInstallFeatureEnabled('AnimGov') then AnimGov := 0;
  if not IsInstallFeatureEnabled('AnimCaptain') then AnimCaptain := False;
  if not IsInstallFeatureEnabled('Video') then
  begin
    SkipVideo := True;
    SkipIntro := True;
  end;
  if UserSettingsConfig.CountParamsByPath('BGOCount') > 0 then
    BGOCount := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('BGOCount'));
  if UserSettingsConfig.CountParamsByPath('BGOTime') > 0 then
    BGOTime := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('BGOTime'));
  if UserSettingsConfig.CountParamsByPath('MaxFilmStepSkip') > 0 then
    MaxFilmStepSkip := StrToInt(UserSettingsConfig.GetParamByPathOrMarker('MaxFilmStepSkip'));
  if UserSettingsConfig.CountParamsByPath('CountFilmSave') > 0 then
    FilmHistoryLimit := Max(1, StrToInt(UserSettingsConfig.GetParamByPathOrMarker('CountFilmSave')));
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
    Count := Section.ParamCount;
    for Index := 0 to Count - 1 do
    begin
      if FindScriptTemplateIndex(Section.ParamNames[Index]) >= 0 then
        raise Exception.Create('Script name not unique');
      ScriptTemplate := TScriptTemplUnit.Create;
      ScriptTemplate.Name := Section.ParamNames[Index];
      Text := Section.ParamValues[Index];
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
            ScriptVariableTypeNames[Variable.RealVType] + ' and ' +
            ScriptVariableTypeNames[Other.RealVType];
          if Variable.RealVType = value_empty then
          begin
            WarningText := WarningText + ', ' + ScriptVariableTypeNames[Variable.RealVType] + ' will be discarded';
            GlobalScriptVariables.Remove(Variable);
          end
          else
          begin
            WarningText := WarningText + ', ' + ScriptVariableTypeNames[Other.RealVType] + ' will be discarded';
            GlobalScriptVariables.Remove(Other);
          end;
          AppendLogLineThreadSafe(WarningText);
        end
        else
        begin
          if Variable.EqualsValue(Other) or not (Variable.RealVType in [value_int32, value_uint32, value_float64, value_string]) then
            GlobalScriptVariables.Remove(Other)
          else
          begin
            WarningText := 'Warning! Mismatching global variables with same name <' + Variable.Name + '> found! Initial values are ' +
              Variable.AsString + ' and ' + Other.AsString + '. Value ' + Variable.AsString + ' will be used';
            GlobalScriptVariables.Remove(Other);
          end;
        end;
      end;
    end;
  end;
  if ReloadScriptTemplates then
  begin
    for Race := owner_maloc to owner_pirate do
    begin
      ShipBlock := GameDataConfig.GetBlockByPath('SE.Ship').FindBlock(OwnerInfo[Race].InternalName);
      for Kind := hull_ranger to hull_diplomat do RaceShipTemplates[Race, Kind] := nil;
      PirateClanShipTemplates[Race] := nil;
      if ShipBlock <> nil then
      begin
        if ShipBlock.CountBlocks('Ranger') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, hull_ranger], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Ranger', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Warrior') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, hull_warrior], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Warrior', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Pirate') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, hull_pirate], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Pirate', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Transport') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, hull_transport], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Transport', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Liner') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, hull_liner], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Liner', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('Diplomat') > 0 then
          RetainSpaceObject(RaceShipTemplates[Race, hull_diplomat], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.Diplomat', Classes.Point(0, 0)));
        if ShipBlock.CountBlocks('PirateClan') > 0 then
          RetainSpaceObject(PirateClanShipTemplates[Race], CreateSpaceObjectByName('Ship2', 'Ship.' + OwnerInfo[Race].InternalName + '.PirateClan', Classes.Point(0, 0)));
      end;
    end;
    Index := 1;
    for KlingKind := Low(TDominatorKind) to High(TDominatorKind) do
      if KlingKind <> dominator_boss then
      begin
        RetainSpaceObject(BlazerShipTemplates[KlingKind], CreateSpaceObjectByName('Ship2', WideString('Ship.Blazer.B' + IntToStr(Index)), Classes.Point(0, 0)));
        RetainSpaceObject(KellerShipTemplates[KlingKind], CreateSpaceObjectByName('Ship2', WideString('Ship.Keller.K' + IntToStr(Index)), Classes.Point(0, 0)));
        RetainSpaceObject(TerronShipTemplates[KlingKind], CreateSpaceObjectByName('Ship2', WideString('Ship.Terron.T' + IntToStr(Index)), Classes.Point(0, 0)));
        Inc(Index);
      end;
  end;
  Count := GameDataConfig.GetBlockByPath('SE.Planet').BlockCount;
  for Index := 0 to Count - 1 do
  begin
    Section := GameDataConfig.GetBlockByPath('SE.Planet').Blocks[Index];
    if Section.CountParams('Image') <= 0 then Dec(Count);
  end;
  SetLength(PlanetSpaceTemplates, Count);
  Count := GameDataConfig.GetBlockByPath('SE.Planet').BlockCount;
  TemplateIndex := 0;
  for Index := 0 to Count - 1 do
  begin
    Section := GameDataConfig.GetBlockByPath('SE.Planet').Blocks[Index];
    if Section.CountParams('Image') <= 0 then Continue;
    RetainSpaceObject(PlanetSpaceTemplates[TemplateIndex].SpaceObject,
      CreateSpaceObjectByName('Planet', 'Planet.' + GameDataConfig.GetBlockByPath('SE.Planet').BlockNames[Index], Classes.Point(0, 0)));
    PlanetSpaceTemplates[TemplateIndex].Radius := StrToInt(Section.Params['Radius']);
    PlanetSpaceTemplates[TemplateIndex].Style := 0;
    PlanetSpaceTemplates[TemplateIndex].StyleVariant := 0;
    if Section.CountParams('Style') > 0 then
    begin
      Text := Section.Params['Style'];
      PlanetSpaceTemplates[TemplateIndex].Style := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
      if CountDelimitedPartsW(Text, ',') >= 2 then
        PlanetSpaceTemplates[TemplateIndex].StyleVariant := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 1, ','));
    end;
    Inc(TemplateIndex);
  end;
  PopupController := TfPopUpController.Create;
  LoadScreen := TfLoad.Create;
  RegisteredScreens[screen_asset_loading] := LoadScreen;
  LoadScreen.InitializeFromConfig(UiStyleConfig, 'Load', True);
  LoadScreen.InitializeLayout;
  MainMenuScreen := TfMainForm.Create;
  RegisteredScreens[screen_main_menu] := MainMenuScreen;
  MainMenuScreen.InitializeFromConfig(UiStyleConfig, 'MainForm', True);
  PlanetQuestScreen := TfPlanetQuest.Create;
  RegisteredScreens[screen_text_quest] := PlanetQuestScreen;
  PlanetQuestScreen.InitializeFromConfig(UiStyleConfig, 'PlanetQuest', True);
  GameLoadScreen := TfGameLoad.Create;
  RegisteredScreens[screen_save_loading] := GameLoadScreen;
  GameLoadScreen.InitializeFromConfig(UiStyleConfig, 'GameLoad', True);
  NewGameScreen := TfGameSettings2.Create;
  RegisteredScreens[screen_new_game] := NewGameScreen;
  NewGameScreen.InitializeFromConfig(UiStyleConfig, 'GameSettings', True);
  IntroductionScreen := TfIntroduction.Create;
  RegisteredScreens[screen_introduction] := IntroductionScreen;
  IntroductionScreen.InitializeFromConfig(UiStyleConfig, 'Introduction', True);
  HangarScreen := TfHangar.Create;
  RegisteredScreens[screen_hangar] := HangarScreen;
  HangarScreen.InitializeFromConfig(UiStyleConfig, 'Hangar', True);
  PlanetScreen := TfPlanet.Create;
  RegisteredScreens[screen_planet] := PlanetScreen;
  PlanetScreen.InitializeFromConfig(UiStyleConfig, 'Planet', True);
  UninhabitedPlanetScreen := TfPlanetNO.Create;
  RegisteredScreens[screen_uninhabited_planet] := UninhabitedPlanetScreen;
  UninhabitedPlanetScreen.InitializeFromConfig(UiStyleConfig, 'PlanetNO', True);
  RuinsTalkScreen := TfRuinsTalk.Create;
  RegisteredScreens[screen_ruins_talk] := RuinsTalkScreen;
  RuinsTalkScreen.InitializeFromConfig(UiStyleConfig, 'RuinsTalk', True);
  ArcadeBattleScreen := TfAB.Create;
  RegisteredScreens[screen_arcade_battle] := ArcadeBattleScreen;
  ArcadeBattleScreen.InitializeFromConfig(UiStyleConfig, 'AB', True);
  GovernmentScreen := TfGov.Create;
  RegisteredScreens[screen_government] := GovernmentScreen;
  GovernmentScreen.InitializeFromConfig(UiStyleConfig, 'Gov', True);
  InfoScreen := TfInfo.Create;
  RegisteredScreens[screen_info] := InfoScreen;
  InfoScreen.InitializeFromConfig(UiStyleConfig, 'Info', True);
  RangerRatingScreen := TfRating2.Create;
  RegisteredScreens[screen_ranger_ranking] := RangerRatingScreen;
  RangerRatingScreen.InitializeFromConfig(UiStyleConfig, 'Rating', True);
  RewardsScreen := TfRewards.Create;
  RegisteredScreens[screen_rewards] := RewardsScreen;
  RewardsScreen.InitializeFromConfig(UiStyleConfig, 'Rewards', True);
  ShipScreen := TfShip2.Create;
  RegisteredScreens[screen_ship] := ShipScreen;
  ShipScreen.InitializeFromConfig(UiStyleConfig, 'Ship', True);
  TalkScreen := TfTalk.Create;
  RegisteredScreens[screen_talk] := TalkScreen;
  TalkScreen.InitializeFromConfig(UiStyleConfig, 'Talk', True);
  ScannerScreen := TfScaner.Create;
  RegisteredScreens[screen_scanner] := ScannerScreen;
  ScannerScreen.InitializeFromConfig(UiStyleConfig, 'Scaner', True);
  StarMapScreen := TfStarMap.Create;
  RegisteredScreens[screen_star_map] := StarMapScreen;
  StarMapScreen.InitializeFromConfig(UiStyleConfig, 'StarMap', True);
  FilmScreen := TfFilm.Create;
  RegisteredScreens[screen_turn_replay] := FilmScreen;
  FilmScreen.InitializeFromConfig(UiStyleConfig, 'Film', True);
  GalaxyScreen := TfGalaxy2.Create;
  RegisteredScreens[screen_galaxy_map] := GalaxyScreen;
  GalaxyScreen.InitializeFromConfig(UiStyleConfig, 'Galaxy', True);
  JumpScreen := TfJump.Create;
  RegisteredScreens[screen_jump] := JumpScreen;
  JumpScreen.InitializeFromConfig(UiStyleConfig, 'Jump', True);
  EquipmentShopScreen := TfEquipmentShop.Create;
  RegisteredScreens[screen_equipment_shop] := EquipmentShopScreen;
  EquipmentShopScreen.InitializeFromConfig(UiStyleConfig, 'EquipmentShop', True);
  GoodsShopScreen := TfGoodsShop2.Create;
  RegisteredScreens[screen_goods_shop] := GoodsShopScreen;
  GoodsShopScreen.InitializeFromConfig(UiStyleConfig, 'GoodsShop', True);
  SaveManagerScreen := TfSaveManager.Create;
  RegisteredScreens[screen_save_manager] := SaveManagerScreen;
  SaveManagerScreen.InitializeFromConfig(UiStyleConfig, 'SaveManager', True);
  GameMenuScreen := TfGameMenu.Create;
  RegisteredScreens[screen_game_menu] := GameMenuScreen;
  GameMenuScreen.InitializeFromConfig(UiStyleConfig, 'GameMenu', True);
  SettingsScreen := TfCfgSettings.Create;
  RegisteredScreens[screen_settings] := SettingsScreen;
  SettingsScreen.InitializeFromConfig(UiStyleConfig, 'CfgSettings', True);
  GameEndScreen := TfGameEnd.Create;
  RegisteredScreens[screen_game_end] := GameEndScreen;
  GameEndScreen.InitializeFromConfig(UiStyleConfig, 'GameEnd', True);
  AboutScreen := TfAbout.Create;
  RegisteredScreens[screen_about] := AboutScreen;
  AboutScreen.InitializeFromConfig(UiStyleConfig, 'About', True);
  ScoreScreen := TfScore.Create;
  RegisteredScreens[screen_scores] := ScoreScreen;
  ScoreScreen.InitializeFromConfig(UiStyleConfig, 'Score', True);
  SelectFaceScreen := TfSelectFace.Create;
  RegisteredScreens[screen_portrait_selection] := SelectFaceScreen;
  SelectFaceScreen.InitializeFromConfig(UiStyleConfig, 'SelectFace', True);
  JournalScreen := TfJournal.Create;
  RegisteredScreens[screen_journal] := JournalScreen;
  JournalScreen.InitializeFromConfig(UiStyleConfig, 'Journal', True);
  LoadRobotScreen := TfLoadRobot.Create;
  RegisteredScreens[screen_planet_battle_selection] := LoadRobotScreen;
  LoadRobotScreen.InitializeFromConfig(UiStyleConfig, 'LoadRobot', True);
  LoadQuestScreen := TfLoadQuest.Create;
  RegisteredScreens[screen_quest_selection] := LoadQuestScreen;
  LoadQuestScreen.InitializeFromConfig(UiStyleConfig, 'LoadQuest', True);
  LoadArcadeScreen := TfLoadAB.Create;
  RegisteredScreens[screen_arcade_selection] := LoadArcadeScreen;
  LoadArcadeScreen.InitializeFromConfig(UiStyleConfig, 'LoadAB', True);
  AchievementsScreen := TfAchievements.Create;
  RegisteredScreens[screen_achievements] := AchievementsScreen;
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
    SatelliteTemplate.MaskName := WideString('Bm.Planet.S.Mask0' + IntToStr(Index) + '?' + IntToStr(SatelliteSurfaceTextureWidth) + ',' + IntToStr(SatelliteSurfaceTextureHeight));
    SatelliteTemplate.Radius := Index;
    Inc(Index);
  end;
  Section := GameDataConfig.GetBlock('SpaceImg');
  Count := Section.ParamCount;
  SetLength(SpaceImageTemplates, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := Section.ParamValues[Index];
    if CountDelimitedPartsW(Text, ',') < 2 then raise Exception.Create('Error in GlobalsInit');
    SpaceImageTemplates[Index].Kind := ExtractDigitsToIntW(Section.ParamNames[Index]);
    SpaceImageTemplates[Index].Weight := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ','));
    SpaceImageTemplates[Index].CacheControl := TCGaiControlEC.Create;
    SpaceImageTemplates[Index].CachedData := nil;
    GlobalCache.ResetControl(TCGaiControlEC(SpaceImageTemplates[Index].CacheControl));
    TCGaiControlEC(SpaceImageTemplates[Index].CacheControl).SetCacheKey(ExtractDelimitedPartW(Text, 1, ','));
  end;
  Section := GameDataConfig.GetBlock('StarFieldImg');
  Count := Section.ParamCount;
  SetLength(StarFieldImageTemplates, Count);
  for Index := 0 to Count - 1 do
  begin
    StarFieldImageTemplates[Index].Weight := ExtractDigitsToIntW(Section.ParamNames[Index]);
    StarFieldImageTemplates[Index].CacheControl := TCGaiControlEC.Create;
    StarFieldImageTemplates[Index].CachedData := nil;
    GlobalCache.ResetControl(TCGaiControlEC(StarFieldImageTemplates[Index].CacheControl));
    TCGaiControlEC(StarFieldImageTemplates[Index].CacheControl).SetCacheKey(Section.ParamValues[Index]);
  end;
  ReloadScriptTemplates := False;
  InitializeGameplayConfig;
  InitializeShipGreetingDefinitions;
  InitializeGovernmentGreetingDefinitions;
  InitializePlanetAdvertDefinitions;
  InitializeRobotMapDefinitions;
  UselessItemRemainsCount := StrToInt(LookupLocalizedTextByKey('UselessItems.CntRemains'));
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('Explosion');
  Count := Section.ParamCount;
  SetLength(ArcadeExplosionSounds, Count);
  for Index := 0 to Count - 1 do ArcadeExplosionSounds[Index] := Section.ParamValues[Index];
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('Hit');
  Count := Section.ParamCount;
  SetLength(ArcadeHitSounds, Count);
  for Index := 0 to Count - 1 do ArcadeHitSounds[Index] := Section.ParamValues[Index];
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('Item');
  Count := Section.ParamCount;
  SetLength(ArcadeItemSounds, Count);
  for Index := 0 to Count - 1 do ArcadeItemSounds[Index] := Section.ParamValues[Index];
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('WeaponFirst');
  for Index := Low(ArcadeWeaponFirstSounds) to High(ArcadeWeaponFirstSounds) do
    if Section.CountParams(IntToStr(Index)) <= 0 then
      ArcadeWeaponFirstSounds[Index] := ''
    else ArcadeWeaponFirstSounds[Index] := Section.Params[IntToStr(Index)];
  Section := GameDataConfig.GetBlock('ABSound').GetBlock('WeaponLoop');
  for Index := Low(ArcadeWeaponLoopSounds) to High(ArcadeWeaponLoopSounds) do
    if Section.CountParams(IntToStr(Index)) <= 0 then
    begin
      ArcadeWeaponLoopSounds[Index] := '';
      ArcadeWeaponLoopTicks[Index] := -1;
    end
    else
    begin
      Text := Section.Params[IntToStr(Index)];
      ArcadeWeaponLoopTicks[Index] := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, 0, ',')) div ArcadeTickMs;
      ArcadeWeaponLoopSounds[Index] := ExtractDelimitedPartW(Text, 1, ',');
    end;
end;
{ @end $7A0124 }

{ @routine $7A4A64 FindMessageLoop }
function FindMessageLoop(Name: WideString): TMessageLoopGI;
var
  Index: TGameScreenId;
begin
  Result := nil;
  for Index := Low(TGameScreenId) to High(TGameScreenId) do
    if (RegisteredScreens[Index] <> nil) and
       (RegisteredScreens[Index] is TMessageLoopGI) and
       ((RegisteredScreens[Index] as TMessageLoopGI).RegisteredLoopName = Name) then
    begin
      Result := TMessageLoopGI(RegisteredScreens[Index]);
      Break;
    end;
end;
{ @end $7A4A64 }

{ @routine $7A4AF8 FinalizeGlobalUiRuntime }
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
    if SpaceImageTemplates[Index].CacheControl <> nil then
    begin
      SpaceImageTemplates[Index].CacheControl.Free;
      SpaceImageTemplates[Index].CacheControl := nil;
    end;
  SpaceImageTemplates := nil;
  Count := High(StarFieldImageTemplates) + 1;
  for Index := 0 to Count - 1 do
    if StarFieldImageTemplates[Index].CacheControl <> nil then
    begin
      StarFieldImageTemplates[Index].CacheControl.Free;
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
{ @end $7A4AF8 }

{ @routine $7A51AC ResetScriptHostRuntimeState }
procedure ResetScriptHostRuntimeState;
var
  Race: TOwnerId; Kind: THullType; KlingKind: TDominatorKind;
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
    GlobalScriptVariables.Add('GRunFrom', value_int32).SetInt(0);
    GlobalScriptVariables.Add('GRunStar', value_uint32).SetInt(0);
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
  for Race := owner_maloc to owner_pirate do
  begin
    for Kind := hull_ranger to hull_diplomat do
      if RaceShipTemplates[Race, Kind] <> nil then
        ReleaseSpaceObject(RaceShipTemplates[Race, Kind]);
    if PirateClanShipTemplates[Race] <> nil then
      ReleaseSpaceObject(PirateClanShipTemplates[Race]);
  end;
  for KlingKind := Low(TDominatorKind) to High(TDominatorKind) do
    if KlingKind <> dominator_boss then
    begin
      if BlazerShipTemplates[KlingKind] <> nil then ReleaseSpaceObject(BlazerShipTemplates[KlingKind]);
      if KellerShipTemplates[KlingKind] <> nil then ReleaseSpaceObject(KellerShipTemplates[KlingKind]);
      if TerronShipTemplates[KlingKind] <> nil then ReleaseSpaceObject(TerronShipTemplates[KlingKind]);
    end;
  ReloadScriptTemplates := True;
end;
{ @end $7A51AC }

{ @routine $7A538C RecreateSpaceProcess }
procedure RecreateSpaceProcess(const ConfigName: WideString);
begin
  if SpaceProcess <> nil then
  begin
    SpaceProcess.Free;
    SpaceProcess := nil;
  end;
  SpaceProcess := TProcessSE.Create(ConfigName);
end;
{ @end $7A538C }

{ @routine $7A53C0 RunMainScreenStateLoop }
procedure RunMainScreenStateLoop;
begin
  while True do
  begin
    if ExitScreenLoop then Exit;
    if (RequestedScreenId = screen_star_map) or
       (RequestedScreenId = screen_turn_replay) or
       (RequestedScreenId = screen_arcade_battle) then
    begin
      CurrentScreenId := RequestedScreenId;
      RequestedScreenId := screen_none;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RunContinuous;
      PreviousScreenId := CurrentScreenId;
      CurrentScreenId := screen_none;
    end
    else
    begin
      if RequestedScreenId = screen_none then Exit;
      CurrentScreenId := RequestedScreenId;
      RequestedScreenId := screen_none;
      TMessageLoopGI(RegisteredScreens[CurrentScreenId]).Run;
      PreviousScreenId := CurrentScreenId;
      CurrentScreenId := screen_none;
    end;
  end;
end;
{ @end $7A53C0 }

{ @routine $7A5440 SwapTurnFilms }
procedure SwapTurnFilms;
var
  Film: TEFilm;
begin
  Film := PrimaryFilm;
  PrimaryFilm := SecondaryFilm;
  SecondaryFilm := Film;
end;
{ @end $7A5440 }

{ @routine $7A5458 TMessagePlayer_Create }
constructor TMessagePlayer.Create;
begin
  inherited Create;
  Button := nil;
  ImageNameOverride := '';
end;
{ @end $7A5458 }

{ @routine $7A549C TMessagePlayer_SaveToBuffer }
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
{ @end $7A549C }

{ @routine $7A5540 TMessagePlayer_LoadFromBuffer }
procedure TMessagePlayer.LoadFromBuffer(Buffer: TBufEC);
begin
  Key := Buffer.ReadWideString;
  Kind := TPlayerMessageKind(Buffer.GetByte);
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
{ @end $7A5540 }

{ @routine $7A5644 TMessagePlayer_GetNormalImageName }
function TMessagePlayer.GetNormalImageName: WideString;
begin
  if ImageNameOverride = '' then Result := PlayerMessagePresentations[Kind].NormalImage
  else Result := ImageNameOverride + 'N';
end;
{ @end $7A5644 }

{ @routine $7A5688 TMessagePlayer_GetActiveImageName }
function TMessagePlayer.GetActiveImageName: WideString;
begin
  if ImageNameOverride = '' then Result := PlayerMessagePresentations[Kind].ActiveImage
  else Result := ImageNameOverride + 'A';
end;
{ @end $7A5688 }

{ @routine $7A56CC TMessagePlayer_GetPressedImageName }
function TMessagePlayer.GetPressedImageName: WideString;
begin
  if ImageNameOverride = '' then Result := PlayerMessagePresentations[Kind].PressedImage
  else Result := ImageNameOverride + 'D';
end;
{ @end $7A56CC }

{ @routine $7A5710 ClearPersistentPlayerMessages }
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
{ @end $7A5710 }

{ @routine $7A5778 CountPersistentPlayerMessages }
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
{ @end $7A5778 }

{ @routine $7A57D0 IsPersistentPlayerMessageQueued }
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
{ @end $7A57D0 }

{ @routine $7A5848 RemovePersistentPlayerMessage }
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
{ @end $7A5848 }

{ @routine $7A58DC RemovePlayerMessagesExceptKinds }
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
{ @end $7A58DC }

{ @routine $7A5998 FindPlayerBubbleByText }
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
{ @end $7A5998 }

{ @routine $7A5A20 FindPlayerBubbleByKey }
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
{ @end $7A5A20 }

{ @routine $7A5AA8 RemovePlayerBubbleByKey }
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
{ @end $7A5AA8 }

{ @routine $7A5B54 RemovePlayerBubblePages }
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
{ @end $7A5B54 }

{ @routine $7A5C84 FindPlayerMessageExceptKinds }
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
{ @end $7A5C84 }

{ @routine $7A5D2C CreatePersistentPlayerMessage }
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
{ @end $7A5D2C }

{ @routine $7A5DC0 AddOrUpdatePlayerBubble }
function AddOrUpdatePlayerBubble(Kind: TPlayerMessageKind; Turn: Integer; const Text, Key: WideString): TMessagePlayer;
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
{ @end $7A5DC0 }

{ @routine $7A5EFC PruneExpiredPersistentPlayerMessages }
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
      if Entry.WasRead and (Entry.Kind in [message_tip]) and (Galaxy.CurrentTurn - Entry.Turn >= 7) then
        RemovePersistentPlayerMessage(Entry, True)
      else if Galaxy.CurrentTurn - Entry.Turn >= PlayerMessagePresentations[Entry.Kind].LifetimeTurns then
        RemovePersistentPlayerMessage(Entry, True)
      else if Entry.WasRead and (Entry.Kind in [message_galaxy_news..message_ship_positive, message_quest_succeeded, message_quest_cancelled, message_ship_negative]) then
        RemovePersistentPlayerMessage(Entry, True)
      else if not GetPlayer.InNormalSpace and (Entry.Kind = message_radio) then
        RemovePersistentPlayerMessage(Entry, True);
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $7A5EFC }

{ @routine $7A5FE8 TScriptTemplUnit_Create }
constructor TScriptTemplUnit.Create;
begin
  inherited Create;
  ConditionCode := TCodeEC.Create;
  ActiveScriptIndex := -1;
end;
{ @end $7A5FE8 }

{ @routine $7A6034 TScriptTemplUnit_Destroy }
destructor TScriptTemplUnit.Destroy;
begin
  ConditionCode.Free;
  ConditionCode := nil;
  inherited Destroy;
end;
{ @end $7A6034 }

{ @routine $7A6068 FindScriptTemplateIndex }
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
{ @end $7A6068 }

{ @routine $7A60AC CollectInactiveScriptTemplates }
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
  if Dest.Count < 2 then Exit;
  Count := Dest.Count * 2;
  for Index := 0 to Count - 1 do
  begin
    First := SeededRandomIntRange(0, Dest.Count - 1,
      Galaxy.GenerationSeed * Galaxy.CurrentTurn * Index);
    Second := SeededRandomIntRange(0, Dest.Count - 1,
      Galaxy.GenerationSeed * (Galaxy.CurrentTurn + Index));
    if First <> Second then
    begin
      Item := Dest[First];
      Dest[First] := Dest[Second];
      Dest[Second] := Item;
    end;
  end;
end;
{ @end $7A60AC }

{ @routine $7A61A4 ShowPlayerTipOnce }
function ShowPlayerTipOnce(Index: Integer): Boolean;
begin
  Result := False;
  if ShownPlayerTips shr Index and 1 <> 0 then Exit;
  ShownPlayerTips := ShownPlayerTips or (1 shl Index);
  if Index < 10 then AddOrUpdatePlayerBubble(message_tip, Galaxy.CurrentTurn, LocalizedColorText('Tips.0' + SysUtils.IntToStr(Index)), '')
  else AddOrUpdatePlayerBubble(message_tip, Galaxy.CurrentTurn, LocalizedColorText('Tips.' + SysUtils.IntToStr(Index)), '');
  Result := True;
end;
{ @end $7A61A4 }

{ @routine $7A62EC HasShownPlayerTip }
function HasShownPlayerTip(Index: Integer): Boolean;
begin
  Result := ShownPlayerTips shr Index and 1 <> 0;
end;
{ @end $7A62EC }

{ @routine $7A62FC SelectSpaceImageTemplateFromSeed }
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
{ @end $7A62FC }

{ @routine $7A6398 SelectSpaceImageTemplate }
function SelectSpaceImageTemplate(Kind: Integer): Integer;
begin
  Result := SelectSpaceImageTemplateFromSeed(Kind, RandomIntRange(0, 2000000000));
end;
{ @end $7A6398 }

{ @routine $7A63B4 HandleRuntimeExitCheck1 }
procedure HandleRuntimeExitCheck1;
begin
  if ExitScreenLoop then;
end;
{ @end $7A63B4 }

{ @routine $7A63C0 HandleRuntimeExitCheck2 }
procedure HandleRuntimeExitCheck2;
begin
  if ExitScreenLoop then;
end;
{ @end $7A63C0 }

{ @routine $7A63CC ParseRobotMapRaceMask }
function ParseRobotMapRaceMask(Text: WideString): TOwnerMask;
var Names: AnsiString;
begin
  Result := [];
  if (Text = '') or (Text = 'Any') then Exit;
  Names := AnsiString(Text);
  if Pos('Maloc', Names) > 0 then Include(Result, owner_maloc);
  if Pos('Peleng', Names) > 0 then Include(Result, owner_peleng);
  if Pos('People', Names) > 0 then Include(Result, owner_human);
  if Pos('Fei', Names) > 0 then Include(Result, owner_feyan);
  if Pos('Gaal', Names) > 0 then Include(Result, owner_gaal);
end;
{ @end $7A63CC }

{ @routine $7A65F4 InitializeRobotMapDefinitions }
procedure InitializeRobotMapDefinitions;
var
  Block, Root: TBlockParEC;
  Previous, Index, Count: Integer;
  Text: WideString;

  // @nested $7A650C ReadMapText
  function ReadMapText(const Path: WideString): WideString; // @addr $7A650C @calls "0x007A66CD,0x007A66F1,0x007A670E,0x007A6734,0x007A675D,0x007A677A,0x007A6805,0x007A6822,0x007A684A,0x007A6872,0x007A6936,0x007A695A,0x007A6977,0x007A6994,0x007A69B1,0x007A69CE,0x007A69EB,0x007A6A08,0x007A6A25,0x007A6A42,0x007A6A62,0x007A6A85,0x007A6AA8,0x007A6ACB" @note "Nested in InitializeRobotMapDefinitions; joins repeated fields with CRLF."
  var Part, PartCount: Integer;
  begin
    Result := '';
    PartCount := Block.CountParamsByPath(Path);
    for Part := 0 to PartCount - 1 do
    begin
      if Result <> '' then Result := Result + #13#10;
      Result := Result + Block.GetParamByPath(Path + ':' + IntToStr(Part));
    end;
  end;

begin
  Root := LanguageDataConfig.GetBlock('RobotsMap');
  Count := Root.BlockCount;
  SetLength(RobotMapDefinitions, Count);
  for Index := 0 to Count - 1 do
  begin
    RobotMapDefinitions[Index].Id := ExtractDigitsToIntW(Root.BlockNames[Index]);
    for Previous := 0 to Index - 1 do
      if RobotMapDefinitions[Index].Id = RobotMapDefinitions[Previous].Id then
        RaiseWideMessage('RobotMap.Id');
    Block := Root.Blocks[Index];
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
      if Pos('Trader', AnsiString(Text)) > 0 then Include(RobotMapDefinitions[Index].PlayerStatus, career_trader);
      if Pos('Pirate', AnsiString(Text)) > 0 then Include(RobotMapDefinitions[Index].PlayerStatus, career_pirate);
      if Pos('Warrior', AnsiString(Text)) > 0 then Include(RobotMapDefinitions[Index].PlayerStatus, career_warrior);
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
{ @end $7A65F4 }

{ @routine $7A6E34 FindRobotMapById }
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
{ @end $7A6E34 }

{ @routine $7A6E68 FindPlanetSpaceTemplateIndex }
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
{ @end $7A6E68 }

{ @routine $7A6F0C InitializeShipGreetingDefinitions }
procedure InitializeShipGreetingDefinitions;
var
  Block: TBlockParEC;
  Index, EntryIndex, Item, Count: Integer;
  Text: WideString;

  // @nested $7A6ED4 ReadShipGreetingField
  function ReadShipGreetingField(const FieldName: WideString): WideString {
    @addr $7A6ED4

  };
  begin
    if Block.CountParams(FieldName) > 0 then Result := Block.Params[FieldName]
    else Result := '';
  end;

begin
  ShipGreetingCount := 0;
  Count := StrToInt(LookupLocalizedTextByKey('ShipGreetings.CountShipGreetings'));
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('ShipGreetings').CountBlocks(IntToStr(Index)) > 0 then
      Inc(ShipGreetingCount);
  SetLength(ShipGreetingDefinitions, ShipGreetingCount);
  ShipGreetingCount := 0;
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('ShipGreetings').CountBlocks(IntToStr(Index)) <> 0 then
    begin
      Inc(ShipGreetingCount);
      EntryIndex := ShipGreetingCount - 1;
      Block := LanguageDataConfig.GetBlockByPath(WideString('ShipGreetings.' + IntToStr(Index)));
      with ShipGreetingDefinitions[EntryIndex] do
      begin
        Name := IntToStr(Index);
        Text := ReadShipGreetingField('Priority');
        if Text = '' then Priority := 10 else Priority := StrToInt(Text);
        Text := ReadShipGreetingField('AutoTalk');
        if (Text = '') or (Text = 'No') then AutoTalk := greeting_match_false
        else if Text = 'Any' then AutoTalk := greeting_match_any
        else AutoTalk := greeting_match_true;
        Text := ReadShipGreetingField('FlyType');
        if (Text = 'Any') or (Text = '') then FlyType := greeting_flight_any
        else if Text = 'ToPlanet' then FlyType := greeting_flight_to_planet
        else if Text = 'ToStar' then FlyType := greeting_flight_to_star
        else if Text = 'ToItem' then FlyType := greeting_flight_to_item
        else if Text = 'ToShip' then FlyType := greeting_flight_to_ship
        else RaiseWideMessage(Text);
        Text := ReadShipGreetingField('ShipType');
        ShipType := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Transport', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_transport);
          if Pos('Liner', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_liner);
          if Pos('Diplomat', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_diplomat);
          if Pos('Ranger', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_ranger);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_pirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_warrior);
          if Pos('Kling', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_dominator);
          if Pos('Pirat', AnsiString(Text)) > 0 then Include(ShipType, greeting_ship_clan_pirate);
        end;
        Text := ReadShipGreetingField('Relations');
        Relations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(Relations, relation_level_hostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(Relations, relation_level_bad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(Relations, relation_level_normal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(Relations, relation_level_good);
          if Pos('Best', AnsiString(Text)) > 0 then Include(Relations, relation_level_excellent);
        end;
        Text := ReadShipGreetingField('ShipRace');
        ShipRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('PlayerRace');
        PlayerRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ShipRaceIsPlayerRace');
        if Text = 'Yes' then ShipRaceIsPlayerRace := greeting_match_true
        else if Text = 'No' then ShipRaceIsPlayerRace := greeting_match_false
        else ShipRaceIsPlayerRace := greeting_match_any;
        Text := ReadShipGreetingField('PlayerAttackGoodShip');
        if Text = 'Yes' then PlayerAttackGoodShip := greeting_match_true
        else if Text = 'No' then PlayerAttackGoodShip := greeting_match_false
        else PlayerAttackGoodShip := greeting_match_any;
        Text := ReadShipGreetingField('InFear');
        if Text = 'Yes' then InFear := greeting_match_true
        else if Text = 'Any' then InFear := greeting_match_any
        else InFear := greeting_match_false;
        Text := ReadShipGreetingField('ShipBadFlyToShip');
        if Text = 'Yes' then ShipBadFlyToShip := greeting_match_true
        else if Text = 'Any' then ShipBadFlyToShip := greeting_match_any
        else ShipBadFlyToShip := greeting_match_false;
        Text := ReadShipGreetingField('ShipBadType');
        ShipBadType := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Transport', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_transport);
          if Pos('Liner', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_liner);
          if Pos('Diplomat', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_diplomat);
          if Pos('Ranger', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_ranger);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_pirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_warrior);
          if Pos('Kling', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_dominator);
          if Pos('PirateClan', AnsiString(Text)) > 0 then Include(ShipBadType, greeting_ship_clan_pirate);
        end;
        Text := ReadShipGreetingField('ShipBadRace');
        ShipBadRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ShipFlyToPlayer');
        if Text = 'Yes' then ShipFlyToPlayer := greeting_match_true
        else if Text = 'No' then ShipFlyToPlayer := greeting_match_false
        else ShipFlyToPlayer := greeting_match_any;
        Text := ReadShipGreetingField('PlayerFlyToShip');
        if Text = 'Yes' then PlayerFlyToShip := greeting_match_true
        else if Text = 'No' then PlayerFlyToShip := greeting_match_false
        else PlayerFlyToShip := greeting_match_any;
        Text := ReadShipGreetingField('PlayerIsShipBad');
        if Text = 'Yes' then PlayerIsShipBad := greeting_match_true
        else if Text = 'No' then PlayerIsShipBad := greeting_match_false
        else PlayerIsShipBad := greeting_match_any;
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
          if Pos('Trader', AnsiString(Text)) > 0 then Include(ShipStatus, career_trader);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ShipStatus, career_pirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ShipStatus, career_warrior);
        end;
        Text := ReadShipGreetingField('PlayerStatus');
        PlayerStatus := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Trader', AnsiString(Text)) > 0 then Include(PlayerStatus, career_trader);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(PlayerStatus, career_pirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(PlayerStatus, career_warrior);
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
        if Text = '' then Goods := goods_unspecified
        else if Text = 'Food' then Goods := 0
        else if Text = 'Medicine' then Goods := 1
        else if Text = 'Technics' then Goods := 2
        else if Text = 'Luxury' then Goods := 3
        else if Text = 'Minerals' then Goods := 4
        else if Text = 'Alcohol' then Goods := 5
        else if Text = 'Arms' then Goods := 6
        else if Text = 'Narcotics' then Goods := 7
        else Goods := goods_unspecified;
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
        if Text = 'Yes' then ShipHaveGoods := greeting_match_true
        else if Text = 'No' then ShipHaveGoods := greeting_match_false
        else ShipHaveGoods := greeting_match_any;
        Text := ReadShipGreetingField('PlayerHaveGoods');
        if Text = 'Yes' then PlayerHaveGoods := greeting_match_true
        else if Text = 'No' then PlayerHaveGoods := greeting_match_false
        else PlayerHaveGoods := greeting_match_any;
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
        if Text = 'Yes' then ShipMayScanPlayer := greeting_match_true
        else if Text = 'No' then ShipMayScanPlayer := greeting_match_false
        else ShipMayScanPlayer := greeting_match_any;
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
        if Text = 'Any' then LastPlanetRace := [owner_maloc..owner_gaal] else LastPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('LastPlanetRelations');
        LastPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(LastPlanetRelations, relation_level_hostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(LastPlanetRelations, relation_level_bad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(LastPlanetRelations, relation_level_normal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(LastPlanetRelations, relation_level_good);
          if Pos('Best', AnsiString(Text)) > 0 then Include(LastPlanetRelations, relation_level_excellent);
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
        if Text = 'Yes' then LastPlanetIsHomePlanet := greeting_match_true
        else if Text = 'No' then LastPlanetIsHomePlanet := greeting_match_false
        else LastPlanetIsHomePlanet := greeting_match_any;
        Text := ReadShipGreetingField('LastPlanetRaceIsShipRace');
        if Text = 'Yes' then LastPlanetRaceIsShipRace := greeting_match_true
        else if Text = 'No' then LastPlanetRaceIsShipRace := greeting_match_false
        else LastPlanetRaceIsShipRace := greeting_match_any;
        Text := ReadShipGreetingField('LastPlanetRaceIsPlayerRace');
        if Text = 'Yes' then LastPlanetRaceIsPlayerRace := greeting_match_true
        else if Text = 'No' then LastPlanetRaceIsPlayerRace := greeting_match_false
        else LastPlanetRaceIsPlayerRace := greeting_match_any;
        Text := ReadShipGreetingField('LastPlanetEconomy');
        LastPlanetEconomy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(LastPlanetEconomy, economy_agricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(LastPlanetEconomy, economy_mixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(LastPlanetEconomy, economy_industrial);
        end;
        Text := ReadShipGreetingField('LastPlanetGoverment');
        LastPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, government_anarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, government_dictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, government_monarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, government_republic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(LastPlanetGovernment, government_democracy);
        end;
        Text := ReadShipGreetingField('LastPlanetInCurStar');
        if Text = 'Yes' then LastPlanetInCurStar := greeting_match_true
        else if Text = 'No' then LastPlanetInCurStar := greeting_match_false
        else LastPlanetInCurStar := greeting_match_any;
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
          if Pos('War', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_hostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_bad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_normal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_good);
          if Pos('Best', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_excellent);
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
        if Text = 'Yes' then ToPlanetIsHomePlanet := greeting_match_true
        else if Text = 'No' then ToPlanetIsHomePlanet := greeting_match_false
        else ToPlanetIsHomePlanet := greeting_match_any;
        Text := ReadShipGreetingField('ToPlanetRaceIsShipRace');
        if Text = 'Yes' then ToPlanetRaceIsShipRace := greeting_match_true
        else if Text = 'No' then ToPlanetRaceIsShipRace := greeting_match_false
        else ToPlanetRaceIsShipRace := greeting_match_any;
        Text := ReadShipGreetingField('ToPlanetRaceIsPlayerRace');
        if Text = 'Yes' then ToPlanetRaceIsPlayerRace := greeting_match_true
        else if Text = 'No' then ToPlanetRaceIsPlayerRace := greeting_match_false
        else ToPlanetRaceIsPlayerRace := greeting_match_any;
        Text := ReadShipGreetingField('ToPlanetEconomy');
        ToPlanetEconomy := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, economy_agricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, economy_mixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, economy_industrial);
        end;
        Text := ReadShipGreetingField('ToPlanetGoverment');
        ToPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_anarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_dictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_monarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_republic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_democracy);
        end;
        Text := ReadShipGreetingField('ToPlanetIsLastPlanet');
        if Text = 'Yes' then ToPlanetIsLastPlanet := greeting_match_true
        else if Text = 'Any' then ToPlanetIsLastPlanet := greeting_match_any
        else ToPlanetIsLastPlanet := greeting_match_false;
        Text := ReadShipGreetingField('ToPlanetRaceIsLastPlanetRace');
        if Text = 'Yes' then ToPlanetRaceIsLastPlanetRace := greeting_match_true
        else if Text = 'No' then ToPlanetRaceIsLastPlanetRace := greeting_match_false
        else ToPlanetRaceIsLastPlanetRace := greeting_match_any;
        Text := ReadShipGreetingField('HomePlanetInToStar');
        if Text = 'Yes' then HomePlanetInToStar := greeting_match_true
        else if Text = 'No' then HomePlanetInToStar := greeting_match_false
        else HomePlanetInToStar := greeting_match_any;
        Text := ReadShipGreetingField('HomePlanetInCurStar');
        if Text = 'Yes' then HomePlanetInCurStar := greeting_match_true
        else if Text = 'No' then HomePlanetInCurStar := greeting_match_false
        else HomePlanetInCurStar := greeting_match_any;
        Text := ReadShipGreetingField('ToStarControlByKling');
        if Text = 'Yes' then ToStarControlByKling := greeting_match_true
        else if Text = 'Any' then ToStarControlByKling := greeting_match_any
        else ToStarControlByKling := greeting_match_false;
        Text := ReadShipGreetingField('ToStarInBattle');
        if Text = 'Yes' then ToStarInBattle := greeting_match_true
        else if Text = 'Any' then ToStarInBattle := greeting_match_any
        else ToStarInBattle := greeting_match_false;
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
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_anarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_dictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_monarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_republic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_democracy);
        end;
        Text := ReadShipGreetingField('ShipNeedInItem');
        if Text = 'Yes' then ShipNeedInItem := greeting_match_true
        else if Text = 'No' then ShipNeedInItem := greeting_match_false
        else ShipNeedInItem := greeting_match_any;
        Text := ReadShipGreetingField('ToShipType');
        ToShipType := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Transport', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_transport);
          if Pos('Liner', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_liner);
          if Pos('Diplomat', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_diplomat);
          if Pos('Ranger', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_ranger);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_pirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_warrior);
          if Pos('Kling', AnsiString(Text)) > 0 then Include(ToShipType, greeting_ship_dominator);
        end;
        Text := ReadShipGreetingField('ToShipRace');
        ToShipRace := ParseRobotMapRaceMask(Text);
        Text := ReadShipGreetingField('ToShipInPlanet');
        if Text = 'Yes' then ToShipInPlanet := greeting_match_true
        else if Text = 'No' then ToShipInPlanet := greeting_match_false
        else ToShipInPlanet := greeting_match_any;
        Text := ReadShipGreetingField('ToShipBad');
        if Text = 'Yes' then ToShipBad := greeting_match_true
        else if Text = 'No' then ToShipBad := greeting_match_false
        else ToShipBad := greeting_match_any;
        Text := ReadShipGreetingField('ToShipRelations');
        ToShipRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(ToShipRelations, relation_level_hostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(ToShipRelations, relation_level_bad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(ToShipRelations, relation_level_normal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(ToShipRelations, relation_level_good);
          if Pos('Best', AnsiString(Text)) > 0 then Include(ToShipRelations, relation_level_excellent);
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
        if Text = 'Yes' then ToStarControlByPirates := greeting_match_true
        else if Text = 'Any' then ToStarControlByPirates := greeting_match_any
        else ToStarControlByPirates := greeting_match_false;
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
        if Text = 'Yes' then CoalitionAlreadyDefeated := greeting_match_true
        else if Text = 'No' then CoalitionAlreadyDefeated := greeting_match_false
        else CoalitionAlreadyDefeated := greeting_match_any;
        Text := ReadShipGreetingField('DominatorsAlreadyDefeated');
        if Text = 'Yes' then DominatorsAlreadyDefeated := greeting_match_true
        else if Text = 'No' then DominatorsAlreadyDefeated := greeting_match_false
        else DominatorsAlreadyDefeated := greeting_match_any;
      end;
    end;
end;
{ @end $7A6F0C }

{ @routine $7ACE8C InitializeGovernmentGreetingDefinitions }
procedure InitializeGovernmentGreetingDefinitions;
var
  Block: TBlockParEC;
  Index, EntryIndex, Item, Count: Integer;
  Text: WideString;

  // @nested $7ACE20 ReadGovernmentGreetingField
  function ReadGovernmentGreetingField(FieldName: WideString): WideString; // @addr $7ACE20 @calls "0x007AD000,0x007AD045,0x007AD06A,0x007AD109,0x007AD1F0,0x007AD34C,0x007AD433,0x007AD45E,0x007AD4AC,0x007AD5B7,0x007AD605,0x007AD736,0x007AD841,0x007AD94C,0x007ADA07,0x007ADB12,0x007ADBC5,0x007ADC78,0x007ADD2B,0x007ADDDE,0x007ADE91,0x007ADEDF,0x007ADF25,0x007ADF73,0x007ADFC1,0x007AE0CC,0x007AE11A,0x007AE24B,0x007AE356,0x007AE461,0x007AE51C,0x007AE627,0x007AE675,0x007AE728,0x007AE7DB,0x007AE88E,0x007AE941,0x007AE9F4,0x007AEA42,0x007AEA90,0x007AEADE,0x007AEB2C,0x007AEBDF,0x007AEC92,0x007AECE0,0x007AED2E,0x007AED7C"
  begin
    if Block.CountParams(FieldName) > 0 then Result := Block.Params[FieldName]
    else Result := '';
  end;

begin
  GovernmentGreetingCount := 0;
  Count := StrToInt(LookupLocalizedTextByKey('GovGreetings.CountGovGreetings'));
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('GovGreetings').CountBlocks(IntToStr(Index)) > 0 then
      Inc(GovernmentGreetingCount);
  SetLength(GovernmentGreetingDefinitions, GovernmentGreetingCount);
  GovernmentGreetingCount := 0;
  for Index := 0 to Count - 1 do
    if LanguageDataConfig.GetBlock('GovGreetings').CountBlocks(IntToStr(Index)) <> 0 then
    begin
      Inc(GovernmentGreetingCount);
      EntryIndex := GovernmentGreetingCount - 1;
      Block := LanguageDataConfig.GetBlockByPath(WideString('GovGreetings.' + IntToStr(Index)));
      with GovernmentGreetingDefinitions[EntryIndex] do
      begin
        Name := IntToStr(Index);
        Text := ReadGovernmentGreetingField('Priority');
        if Text = '' then Priority := 10 else Priority := StrToInt(Text);
        Text := ReadGovernmentGreetingField('PlayerRace');
        PlayerRace := ParseRobotMapRaceMask(Text);
        Text := ReadGovernmentGreetingField('PlayerStatus');
        PlayerStatus := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Trader', AnsiString(Text)) > 0 then Include(PlayerStatus, career_trader);
          if Pos('Pirate', AnsiString(Text)) > 0 then Include(PlayerStatus, career_pirate);
          if Pos('Warrior', AnsiString(Text)) > 0 then Include(PlayerStatus, career_warrior);
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
        if Text = '' then Goods := goods_unspecified
        else if Text = 'Food' then Goods := 0
        else if Text = 'Medicine' then Goods := 1
        else if Text = 'Technics' then Goods := 2
        else if Text = 'Luxury' then Goods := 3
        else if Text = 'Minerals' then Goods := 4
        else if Text = 'Alcohol' then Goods := 5
        else if Text = 'Arms' then Goods := 6
        else if Text = 'Narcotics' then Goods := 7
        else Goods := goods_unspecified;
        Text := ReadGovernmentGreetingField('CurPlanetRace');
        CurPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadGovernmentGreetingField('CurPlanetRaceIsPlayerRace');
        if Text = 'Yes' then CurPlanetRaceIsPlayerRace := greeting_match_true
        else if Text = 'No' then CurPlanetRaceIsPlayerRace := greeting_match_false
        else CurPlanetRaceIsPlayerRace := greeting_match_any;
        Text := ReadGovernmentGreetingField('CurPlanetRelations');
        CurPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(CurPlanetRelations, relation_level_hostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(CurPlanetRelations, relation_level_bad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(CurPlanetRelations, relation_level_normal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(CurPlanetRelations, relation_level_good);
          if Pos('Best', AnsiString(Text)) > 0 then Include(CurPlanetRelations, relation_level_excellent);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetGoodsPermit');
        if Text = 'Yes' then CurPlanetGoodsPermit := greeting_match_true
        else if Text = 'No' then CurPlanetGoodsPermit := greeting_match_false
        else CurPlanetGoodsPermit := greeting_match_any;
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
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(CurPlanetEconomy, economy_agricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(CurPlanetEconomy, economy_mixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(CurPlanetEconomy, economy_industrial);
        end;
        Text := ReadGovernmentGreetingField('CurPlanetGoverment');
        CurPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, government_anarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, government_dictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, government_monarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, government_republic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(CurPlanetGovernment, government_democracy);
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
        if Text = 'Yes' then CurStarInBattle := greeting_match_true
        else if Text = 'Any' then CurStarInBattle := greeting_match_any
        else CurStarInBattle := greeting_match_false;
        Text := ReadGovernmentGreetingField('ToPlanetRace');
        if Text = 'Any' then ToPlanetRace := [owner_maloc..owner_gaal] else ToPlanetRace := ParseRobotMapRaceMask(Text);
        Text := ReadGovernmentGreetingField('ToPlanetRaceIsPlayerRace');
        if Text = 'Yes' then ToPlanetRaceIsPlayerRace := greeting_match_true
        else if Text = 'No' then ToPlanetRaceIsPlayerRace := greeting_match_false
        else ToPlanetRaceIsPlayerRace := greeting_match_any;
        Text := ReadGovernmentGreetingField('ToPlanetRaceIsCurPlanetRace');
        if Text = 'Yes' then ToPlanetRaceIsCurPlanetRace := greeting_match_true
        else if Text = 'No' then ToPlanetRaceIsCurPlanetRace := greeting_match_false
        else ToPlanetRaceIsCurPlanetRace := greeting_match_any;
        Text := ReadGovernmentGreetingField('ToPlanetRelations');
        ToPlanetRelations := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('War', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_hostile);
          if Pos('Bad', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_bad);
          if Pos('Normal', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_normal);
          if Pos('Good', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_good);
          if Pos('Best', AnsiString(Text)) > 0 then Include(ToPlanetRelations, relation_level_excellent);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetGoodsPermit');
        if Text = 'Yes' then ToPlanetGoodsPermit := greeting_match_true
        else if Text = 'No' then ToPlanetGoodsPermit := greeting_match_false
        else ToPlanetGoodsPermit := greeting_match_any;
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
          if Pos('Agriculture', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, economy_agricultural);
          if Pos('Mixed', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, economy_mixed);
          if Pos('Industrial', AnsiString(Text)) > 0 then Include(ToPlanetEconomy, economy_industrial);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetGoverment');
        ToPlanetGovernment := [];
        if (Text <> '') and (Text <> 'Any') then
        begin
          if Pos('Anarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_anarchy);
          if Pos('Dictatorship', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_dictatorship);
          if Pos('Monarchy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_monarchy);
          if Pos('Republic', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_republic);
          if Pos('Democracy', AnsiString(Text)) > 0 then Include(ToPlanetGovernment, government_democracy);
        end;
        Text := ReadGovernmentGreetingField('ToPlanetInCurStar');
        if Text = 'Any' then ToPlanetInCurStar := greeting_match_any
        else if Text = 'No' then ToPlanetInCurStar := greeting_match_false
        else ToPlanetInCurStar := greeting_match_true;
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
        if Text = 'Yes' then ToStarControlByKling := greeting_match_true
        else if Text = 'Any' then ToStarControlByKling := greeting_match_any
        else ToStarControlByKling := greeting_match_false;
        Text := ReadGovernmentGreetingField('ToStarInBattle');
        if Text = 'Yes' then ToStarInBattle := greeting_match_true
        else if Text = 'Any' then ToStarInBattle := greeting_match_any
        else ToStarInBattle := greeting_match_false;
        Text := ReadGovernmentGreetingField('CurPlanetPirateClan');
        if Text = 'Yes' then CurPlanetPirateClan := greeting_match_true
        else if Text = 'No' then CurPlanetPirateClan := greeting_match_false
        else CurPlanetPirateClan := greeting_match_any;
        Text := ReadGovernmentGreetingField('CurStarInBattlePirates');
        if Text = 'Yes' then CurStarInBattlePirates := greeting_match_true
        else if Text = 'Any' then CurStarInBattlePirates := greeting_match_any
        else CurStarInBattlePirates := greeting_match_false;
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
        if Text = 'Yes' then ToStarControlByPirates := greeting_match_true
        else if Text = 'Any' then ToStarControlByPirates := greeting_match_any
        else ToStarControlByPirates := greeting_match_false;
        Text := ReadGovernmentGreetingField('CoalitionAlreadyDefeated');
        if Text = 'Yes' then CoalitionAlreadyDefeated := greeting_match_true
        else if Text = 'No' then CoalitionAlreadyDefeated := greeting_match_false
        else CoalitionAlreadyDefeated := greeting_match_any;
        Text := ReadGovernmentGreetingField('DominatorsAlreadyDefeated');
        if Text = 'Yes' then DominatorsAlreadyDefeated := greeting_match_true
        else if Text = 'No' then DominatorsAlreadyDefeated := greeting_match_false
        else DominatorsAlreadyDefeated := greeting_match_any;
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
{ @end $7ACE8C }

{ @routine $7AFDB4 InitializePlanetAdvertDefinitions }
procedure InitializePlanetAdvertDefinitions;
var
  Root, GroupBlock, Block: TBlockParEC;
  GroupIndex, BlockIndex, AdvertIndex, FoundIndex, Count: Integer;
  Text, Name: WideString;
begin
  Root := MainDataConfig.GetBlockByPath('Data\PlanetAdvt');
  SetLength(PlanetAdvertDefinitions, Root.BlockCount);
  for GroupIndex := 0 to High(PlanetAdvertDefinitions) do
  begin
    GroupBlock := Root.Blocks[GroupIndex];
    PlanetAdvertDefinitions[GroupIndex].Position := GetPointGI(GroupBlock.GetParamByPathOrMarker('Info.Pos'));
    if GroupBlock.GetBlock('Info').CountParams('Image1') > 0 then
      PlanetAdvertDefinitions[GroupIndex].Image1 := GroupBlock.GetParamByPathOrMarker('Info.Image1');
    if GroupBlock.GetBlock('Info').CountParams('Image2') > 0 then
      PlanetAdvertDefinitions[GroupIndex].Image2 := GroupBlock.GetParamByPathOrMarker('Info.Image2');
    Count := GroupBlock.BlockCount;
    SetLength(PlanetAdvertDefinitions[GroupIndex].Adverts, Count - 2);
    AdvertIndex := 0;
    for BlockIndex := 0 to Count - 1 do
    begin
      Text := GroupBlock.BlockNames[BlockIndex];
      if (Text = 'List') or (Text = 'Info') then Continue;
      Block := GroupBlock.Blocks[BlockIndex];
      PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Name := Text;
      if Block.CountParams('Image1') > 0 then
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Image1 := Block.Params['Image1'];
      if Block.CountParams('Image2') > 0 then
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Image2 := Block.Params['Image2'];
      PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := 0;
      if Block.CountParams('War') > 0 then
      begin
        PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := ExtractSignedDigitsToIntW(Block.Params['War']);
        if PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War < -1 then
          PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := -1
        else if PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War > 1 then
          PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].War := 1;
      end;
      PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := goods_unspecified;
      if Block.CountParams('Goods') > 0 then
      begin
        Text := Block.Params['Goods'];
        if Text = 'Food' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 0
        else if Text = 'Medicine' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 1
        else if Text = 'Technics' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 2
        else if Text = 'Luxury' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 3
        else if Text = 'Minerals' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 4
        else if Text = 'Alcohol' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 5
        else if Text = 'Arms' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 6
        else if Text = 'Narcotics' then PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := 7
        else PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Goods := goods_unspecified;
      end;
      PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner := [];
      if Block.CountParams('Owner') > 0 then
      begin
        Text := Block.Params['Owner'];
        if Pos('Maloc', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, owner_maloc);
        if Pos('Peleng', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, owner_peleng);
        if Pos('People', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, owner_human);
        if Pos('Fei', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, owner_feyan);
        if Pos('Gaal', AnsiString(Text)) > 0 then Include(PlanetAdvertDefinitions[GroupIndex].Adverts[AdvertIndex].Owner, owner_gaal);
      end;
      Inc(AdvertIndex);
      if AdvertIndex >= Count - 1 then Break;
    end;
    Block := GroupBlock.GetBlock('List');
    SetLength(PlanetAdvertDefinitions[GroupIndex].Lists, Block.ParamCount);
    for BlockIndex := 0 to High(PlanetAdvertDefinitions[GroupIndex].Lists) do
    begin
      PlanetAdvertDefinitions[GroupIndex].Lists[BlockIndex].Weight := ExtractDigitsToIntW(Block.ParamNames[BlockIndex]);
      Text := Block.ParamValues[BlockIndex];
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
{ @end $7AFDB4 }

{ @routine $7B0708 GetInnermostScreenLoop }
function GetInnermostScreenLoop: TMessageLoopGI;
begin
  Result := TMessageLoopGI(RegisteredScreens[CurrentScreenId]);
  while Result.ChildLoop <> nil do Result := Result.ChildLoop;
end;
{ @end $7B0708 }

end.
