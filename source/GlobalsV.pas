unit GlobalsV;
// Unit bracket (inferred): .text 0x0045E830..0x0045EB47; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x0087571C..0x0087571C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes;

type
  // Keep the registry independent of UI/cache implementation units. Consumers
  // cast these object references to the concrete cache and message-loop types.
  TSpaceImageTemplate = record // @size $10
    Kind: Integer; // @offset $00 SpaceImg parameter name; used for weighted selection.
    Weight: Integer; // @offset $04
    CacheControl: TObject; // @offset $08 Owned, released by UI shutdown.
    CachedData: TObject; // @offset $0C Borrowed during rendering.
  end;
  TSpaceImageTemplates = array of TSpaceImageTemplate;

  TStarFieldImageTemplate = record // @size $10
    Reserved: Integer; // @offset $00 Zero-initialized; use not yet established.
    Weight: Integer; // @offset $04 StarFieldImg parameter name.
    CacheControl: TObject; // @offset $08 Owned, released by UI shutdown.
    CachedData: TObject; // @offset $0C Borrowed during rendering.
  end;
  TStarFieldImageTemplates = array of TStarFieldImageTemplate;

  TGameScreenId = (
    screenNone=0,
    screenMainMenu=1,
    screenIntroduction=3,
    screenHangar=4,
    screenPlanet=5,
    screenPlanetNO=6,
    screenPlanetQuest=7,
    screenEquipmentShop=8,
    screenShip=10,
    screenTalk=11,
    screenScanner=12,
    screenGovernment=15,
    screenStarMap=16,
    screenFilm=17,
    screenGalaxy=18,
    screenJump=19,
    screenRuinsTalk=20,
    screenArcadeBattle=21,
    screenLoad=22,
    screenSaveManager=23,
    screenGameLoad=24,
    screenGameMenu=25,
    screenSettings=26,
    screenGameEnd=27,
    screenInfo=28,
    screenRewards=30,
    screenAbout=31,
    screenScores=32,
    screenNewGame=33,
    screenGoodsShop=34,
    screenRating=35,
    screenSelectFace=36,
    screenJournal=37,
    screenLoadRobot=38,
    screenLoadQuest=39,
    screenLoadArcade=40,
    screenAchievements=41
  ); // @size 0x01
  TGalaxyMapFontChoice = (
    gmfRanger=1,
    gmfMini=2,
    gmfSmall=3,
    gmfSmallBold=4,
    gmfNormal=5,
    gmfNormalBold=6
  ); // @size 0x04
  TGameScreenTable = array[0..41] of TObject;

function FormToId(Screen: TObject): TGameScreenId; // @addr 0x45E874 @note "Raises when absent; nil matches the first empty slot."
function GetRegisteredScreenLoop(ScreenId: TGameScreenId): TObject; // @addr 0x45E8D4 @note "No bounds check."
function IsSpaceBackdropScreen(ScreenId: TGameScreenId): Boolean; // @addr 0x45E8F4
function ScreenUsesCompositeLoadAssets(ScreenId: TGameScreenId): Boolean; // @addr 0x45E924


var


  // Module reference cells point to global storage, not directly to its objects.


var
  // Managed globals follow the verified native finalization order.
var
  DumpLoadedConfig: Boolean = False; // @addr $8797F0
  HalfGovAnim: Boolean = False; // @addr $8797F4
  QuestStyleIndex: Integer = 0; // @addr $8797F8 // Zero-based.
  QuestPageAnimationEnabled: Boolean = True; // @addr $8797FC
  DefaultOrder: Integer = 0; // @addr $879800
  RightClickOnShip: Integer = 0; // @addr $879804
  EstOptionEnabled: Boolean = False; // @addr $879808 Native purpose remains unresolved.
  SendRecordOff: Boolean = False; // @addr $87980C
  ChangeAutoPilot: Integer = 4; // @addr $879810
  DisableAutoPilot: Boolean = False; // @addr $879814
  SkipGiper: Boolean = False; // @addr $879818
  Wind: Integer = 2; // @addr $87981C
  PendingQuestName: WideString = 'Prison'; // @addr $879820 @note "Native default; standalone selector replaces it with a numeric quest ID or a quest resource name."
var
  RegisteredScreens: TGameScreenTable; // @addr 0x888D00
  SkipSavedPixelRestore: Boolean; // @addr $888DA8
  HardwareRenderingRequested: Boolean; // @addr $888DA9
  HardwareRenderingEnabled: Boolean; // @addr $888DAA
  RunningUnderWine: Boolean; // @addr $888DAB @note "Native startup checks ntdll wine_get_version/wine_get_host_version."
  ScaleViewportToWindow: Boolean; // @addr $888DAC
  UseTablesForGov: Boolean; // @addr $888DAD
  RangerFontName: WideString; // @addr $888DB0
  MiniFontName: WideString; // @addr $888DB4
  SmallFontName: WideString; // @addr $888DB8 @note "Initialized to Font.2Small."
  SmallBoldFontName: WideString; // @addr $888DBC @note "Initialized to Font.2SmallBold."
  NormalFontName: WideString; // @addr $888DC0 @note "Initialized to Font.2Normal."
  NormalBoldFontName: WideString; // @addr 0x888DC4 @note "Initialized to Font.2NormalBold."
  BigFontName: WideString; // @addr 0x888DC8 @note "Initialized to Font.2Big."
  HugeFontName: WideString; // @addr $888DCC
  IntroFontName: WideString; // @addr $888DD0
  AuthorsFontName: WideString; // @addr $888DD4
  SmoothSmallFontName: WideString; // @addr $888DD8 @note "Initialized to Font.Verdana8."
  SmoothSmallBoldFontName: WideString; // @addr $888DDC @note "Initialized to Font.Verdana8bold."
  SmoothNormalFontName: WideString; // @addr $888DE0 @note "Initialized to Font.Verdana9."
  SmoothNormalBoldFontName: WideString; // @addr $888DE4 @note "Initialized to Font.Verdana9bold."
  SmoothBigFontName: WideString; // @addr $888DE8
  SmoothHugeFontName: WideString; // @addr $888DEC
  SmoothIntroFontName: WideString; // @addr $888DF0
  PendingLoadFileName: AnsiString; // @addr 0x888DF4
var
  LoadedFilmCount: Integer; // @addr 0x888DF8
  GameEndReason: Integer; // @addr $888DFC @note "One selects death; other native ending codes remain unresolved."
var
  ShipTail: Integer = 0; // @addr $879824
  ThreeDimensionalModeEnabled: Boolean = False; // @addr $879828 @note "3D setting, cleared on EDirectXRender during device startup."
  AnimCaptain: Boolean = False; // @addr $87982C
  AnimItem: Boolean = False; // @addr $879830
  Comet: Integer = 1; // @addr $879834
  BGImage: Boolean = False; // @addr $879838
  AnimShipFull: Boolean = False; // @addr $87983C
  AnimCity: Boolean = False; // @addr $879840
  AnimMenuShip: Boolean = True; // @addr $879844
  AnimGov: Integer = 2; // @addr $879848
  AnimStar: Boolean = True; // @addr $87984C
  AnimHangar: Boolean = True; // @addr $879850
  CircleAction: Boolean = True; // @addr $879854
  StaticBackground: Boolean = True; // @addr $879858
  ScrollTime: Integer = 20; // @addr $87985C
  ScrollStep: Integer = 5; // @addr $879860
  ScrollSense: Integer = 1; // @addr $879864
  FilmSpeed: Integer = 1; // @addr $879868
  BGOCount: Integer = 50; // @addr $87986C
  BGOTime: Integer = 300; // @addr $879870
  SpaceImage: Integer = 0; // @addr $879874
  SoundEnabled: Boolean = False; // @addr $879878
  SoundInSpaceEnabled: Boolean = False; // @addr $87987C
  SoundVolume: Single = 1.0; // @addr $879880
  RobotSoundVolume: Single = 1.0; // @addr $879884
  MusicEnabled: Boolean = False; // @addr $879888
  MusicInSpaceEnabled: Boolean = False; // @addr $87988C
  MusicInHyperEnabled: Boolean = True; // @addr $879890
  MusicInPlanetEnabled: Boolean = True; // @addr $879894
  MusicVolume: Single = 0.75; // @addr $879898
  MusicVolumeScale: Single = 1.0; // @addr $87989C
  RobotMusicVolume: Single = 0.75; // @addr $8798A0
  MaxFilmStepSkip: Integer = 3; // @addr $8798A4
  FilmHistoryLimit: Integer = 1; // @addr 0x8798A8 @note "CountFilmSave setting. UI range is 1..100; config loading clamps only the minimum to 1. Limit applies when a recording is added, not while loading a save."
  BeginCalcNextTurn: Single = 1.0; // @addr $8798AC
  DoNotChangeMusicInBattle: Boolean = False; // @addr $8798B0
  ViewFollowShip: Boolean = True; // @addr $8798B4
  ActionDoubleClick: Boolean = True; // @addr $8798B8
  GalaxyMapFontChoice: TGalaxyMapFontChoice = gmfNormalBold; // @addr 0x8798BC @note "FontGalaxy setting; default gmfNormalBold. Out-of-range values also use the normal-bold font."
  FontQuest: Integer = 0; // @addr $8798C0
  FontDialog: Integer = 0; // @addr $8798C4
  FontSmoothingEnabled: Boolean = False; // @addr 0x8798C8 @note "FontSmooth setting."
  ScreenshotFormat: Integer = 1; // @addr $8798CC  0=BMP, 1=PNG, 2=JPEG.
  ScreenshotJpegQuality: Integer = 85; // @addr $8798D0
  DynamicTipsPos: Boolean = True; // @addr $8798D4
  ViewPathLength: Boolean = False; // @addr $8798D8
  AfterburnerStopCondition: Integer = 35; // @addr $8798DC
  TurnSaveStep: Integer = 0; // @addr 0x8798E0
  QuickSaveExtraSlots: Integer = 0; // @addr 0x8798E4
  MaxPlayerNews: Integer = 30; // @addr $8798E8
  MaxSearchResult: Integer = 100; // @addr $8798EC
  ClickAutoCloseForm: Boolean = True; // @addr $8798F0
  UiRuntimeFlag: Boolean = False; // @addr $8798F4 Native purpose remains unresolved.
  MultiThreadEnabled: Boolean = False; // @addr $8798F8
  ShowWineWarning: Boolean = False; // @addr $8798FC
  XonarSoundDevice: Boolean = False; // @addr $879900
  ShowXonarWarning: Boolean = False; // @addr $879904
  PlanetDepth: Single = 0; // @addr $879908
  ShipPathDepth: Single = 15.0; // @addr $87990C
  ShipPathEndDepth: Single = 14.0; // @addr $879910
  UnitPathDepth: Single = 13.0; // @addr $879914
  UnitPathEndDepth: Single = 12.0; // @addr $879918
  ActionButtonDepth: Single = 9.0; // @addr $87991C
  GalaxyStarDepth: Single = 20.0; // @addr $879920
  GalaxyStarNameDepth: Single = 19.0; // @addr $879924
  GalaxyWarDepth: Single = 18.0; // @addr $879928
  ConstellationLineDepth: Single = 21.0; // @addr $87992C
  ConstellationColorDepth: Single = 22.0; // @addr $879930
  MemorySnapshotActive: Boolean = False; // @addr 0x879934
  PreviousScreenId: TGameScreenId = screenNone; // @addr 0x879938
  CurrentScreenId: TGameScreenId = screenNone; // @addr 0x87993C
  RequestedScreenId: TGameScreenId = screenNone; // @addr 0x879940
  PostLoadScreenId: TGameScreenId = screenNone; // @addr 0x879944
  ShipReturnScreenId: TGameScreenId = screenNone; // @addr $879948
  TalkReturnScreenId: TGameScreenId = screenNone; // @addr $87994C
  ScannerReturnScreenId: TGameScreenId = screenNone; // @addr $879950
  QuestReturnScreenId: TGameScreenId = screenNone; // @addr $879954 @note "Quest selector or campaign screen that launched the active text quest."
  Screen13ReturnScreenId: TGameScreenId = screenNone; // @addr $879958 @note "Return screen for native screen ID 13; its purpose remains unresolved."
  GalaxyReturnScreenId: TGameScreenId = screenNone; // @addr $87995C Set by the star-map/ruins caller; consumed by galaxy-map Back.
  SaveManagerReturnScreenId: TGameScreenId = screenNone; // @addr 0x879960
  GameMenuReturnScreenId: TGameScreenId = screenNone; // @addr $879964
  SettingsReturnScreenId: TGameScreenId = screenNone; // @addr 0x879968
  AchievementsReturnScreenId: TGameScreenId = screenNone; // @addr $87996C
  LoadedSaveVersion: Integer = 0; // @addr 0x879970
  LoadingFilmCount: Integer = -1; // @addr 0x879974 @note "-1 outside the film-loading phase."
  BackgroundShade: Boolean = False; // @addr $879978
  BackgroundBlur: Boolean = False; // @addr $87997C
  BackgroundGrayscale: Boolean = False; // @addr $879980
  PlanetClouds: Boolean = True; // @addr $879984
  PlanetAtm: Boolean = True; // @addr $879988
  AnimChangeForm: Boolean = True; // @addr $87998C
  AnimMainFon: Boolean = True; // @addr $879990
  SputnikShow: Boolean = True; // @addr $879994
  SatelliteLightMapPath: WideString = 'Bm.Planet.S.Light094'; // @addr $879998 Used by TPlanetGI.SetImageFromTemplate when creating its light buffers.
var
  SatelliteTemplateParameter1: Integer = 128; // @addr $87999C
  SatelliteTemplateParameter2: Integer = 60; // @addr $8799A0
  MinimumSatelliteTemplateRadius: Integer = 10; // @addr $8799A4
  GeneratedSatelliteBaseRadius: Integer = 13; // @addr $8799A8 Base for procedural satellite display sizes, separate from render-template limits.
  MaximumSatelliteTemplateRadius: Integer = 60; // @addr $8799AC
  SatelliteRenderTemplates: TList = nil; // @addr $8799B0 Owns TSputnikTempl instances.
  SpaceImageTemplates: array of TSpaceImageTemplate = nil; // @addr $8799B4
  StarFieldImageTemplates: array of TStarFieldImageTemplate = nil; // @addr $8799B8
var
  ForcedPlanetQuestId: Integer = -1; // @addr $8799BC Nonnegative forces this quest ID in government offers; native default is -1.

implementation

// @unit-initialization $87571C
// @unit-finalization $45EA2C

uses SysUtils;

{ @routine $45E874 FormToId }
function FormToId(Screen: TObject): TGameScreenId;
var
  Id: TGameScreenId;
begin
  Id := screenNone;
  repeat
    if RegisteredScreens[Ord(Id)] = Screen then
    begin
      Result := Id;
      Exit;
    end;
    Inc(Id);
  until Id = TGameScreenId(42);
  raise Exception.Create('FormToId');
end;
{ @end $45E874 }

{ @routine $45E8D4 GetRegisteredScreenLoop }
function GetRegisteredScreenLoop(ScreenId: TGameScreenId): TObject;
begin
  Result := RegisteredScreens[Ord(ScreenId)];
end;
{ @end $45E8D4 }

{ @routine $45E8F4 IsSpaceBackdropScreen }
function IsSpaceBackdropScreen(ScreenId: TGameScreenId): Boolean;
begin
  Result := (ScreenId = screenStarMap) or (ScreenId = screenGalaxy) or
    (ScreenId = screenFilm) or (ScreenId = screenTalk);
end;
{ @end $45E8F4 }

{ @routine $45E924 ScreenUsesCompositeLoadAssets }
function ScreenUsesCompositeLoadAssets(ScreenId: TGameScreenId): Boolean;
begin
  Result := False;
  if IsSpaceBackdropScreen(ScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenLoad) and IsSpaceBackdropScreen(PostLoadScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenShip) and IsSpaceBackdropScreen(ShipReturnScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenScanner) and IsSpaceBackdropScreen(ScannerReturnScreenId) then begin Result := True; Exit; end;
  if (ScreenId = TGameScreenId(13)) and IsSpaceBackdropScreen(Screen13ReturnScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenSaveManager) and IsSpaceBackdropScreen(SaveManagerReturnScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenGameMenu) and IsSpaceBackdropScreen(GameMenuReturnScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenSettings) and IsSpaceBackdropScreen(SettingsReturnScreenId) then begin Result := True; Exit; end;
  if (ScreenId = screenSettings) and (SettingsReturnScreenId = screenGameMenu) and
    IsSpaceBackdropScreen(GameMenuReturnScreenId) then Result := True;
end;
{ @end $45E924 }

end.
