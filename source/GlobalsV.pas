unit GlobalsV;
// Unit bracket (inferred): .text 0x0045E830..0x0045EB47; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x0087671C..0x0087671C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes;

const
  // SF_EndGame also accepts arbitrary script-defined integers. Values above four
  // select FormGameEnd.WinPirateN; keep GameEndReason as Integer.
  gerDefault = 0; // Ordinary end-of-film death or CustomWin/CustomLose event.
  gerPlayerDeath = 2; // Explicit death detected on a planet or during takeoff.
  gerTerronConversion = 4; // Script exit_end; FormGameEnd.LossConvertToTerron variants.

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
  DumpLoadedConfig: Boolean = False; // @addr $87A7F0
  HalfGovAnim: Boolean = False; // @addr $87A7F4
  QuestStyleIndex: Integer = 0; // @addr $87A7F8 // Zero-based.
  QuestPageAnimationEnabled: Boolean = True; // @addr $87A7FC
  DefaultOrder: Integer = 0; // @addr $87A800
  RightClickOnShip: Integer = 0; // @addr $87A804
  EstOptionEnabled: Boolean = False; // @addr $87A808 Native purpose remains unresolved.
  SendRecordOff: Boolean = False; // @addr $87A80C
  ChangeAutoPilot: Integer = 4; // @addr $87A810
  DisableAutoPilot: Boolean = False; // @addr $87A814
  SkipGiper: Boolean = False; // @addr $87A818
  Wind: Integer = 2; // @addr $87A81C
  PendingQuestName: WideString = 'Prison'; // @addr $87A820 @note "Native default; standalone selector replaces it with a numeric quest ID or a quest resource name."
var
  RegisteredScreens: TGameScreenTable; // @addr 0x889D00
  SkipSavedPixelRestore: Boolean; // @addr $889DA8
  HardwareRenderingRequested: Boolean; // @addr $889DA9
  HardwareRenderingEnabled: Boolean; // @addr $889DAA
  RunningUnderWine: Boolean; // @addr $889DAB @note "Native startup checks ntdll wine_get_version/wine_get_host_version."
  ScaleViewportToWindow: Boolean; // @addr $889DAC
  UseTablesForGov: Boolean; // @addr $889DAD
  RangerFontName: WideString; // @addr $889DB0
  MiniFontName: WideString; // @addr $889DB4
  SmallFontName: WideString; // @addr $889DB8 @note "Initialized to Font.2Small."
  SmallBoldFontName: WideString; // @addr $889DBC @note "Initialized to Font.2SmallBold."
  NormalFontName: WideString; // @addr $889DC0 @note "Initialized to Font.2Normal."
  NormalBoldFontName: WideString; // @addr 0x889DC4 @note "Initialized to Font.2NormalBold."
  BigFontName: WideString; // @addr 0x889DC8 @note "Initialized to Font.2Big."
  HugeFontName: WideString; // @addr $889DCC
  IntroFontName: WideString; // @addr $889DD0
  AuthorsFontName: WideString; // @addr $889DD4
  SmoothSmallFontName: WideString; // @addr $889DD8 @note "Initialized to Font.Verdana8."
  SmoothSmallBoldFontName: WideString; // @addr $889DDC @note "Initialized to Font.Verdana8bold."
  SmoothNormalFontName: WideString; // @addr $889DE0 @note "Initialized to Font.Verdana9."
  SmoothNormalBoldFontName: WideString; // @addr $889DE4 @note "Initialized to Font.Verdana9bold."
  SmoothBigFontName: WideString; // @addr $889DE8
  SmoothHugeFontName: WideString; // @addr $889DEC
  SmoothIntroFontName: WideString; // @addr $889DF0
  PendingLoadFileName: AnsiString; // @addr 0x889DF4
var
  LoadedFilmCount: Integer; // @addr 0x889DF8
  GameEndReason: Integer; // @addr $889DFC @note "ger* ending codes; values 5..18 select the localized WinPirate epilogues. SF_EndGame can supply arbitrary integers."
var
  ShipTail: Integer = 0; // @addr $87A824
  ThreeDimensionalModeEnabled: Boolean = False; // @addr $87A828 @note "3D setting, cleared on EDirectXRender during device startup."
  AnimCaptain: Boolean = False; // @addr $87A82C
  AnimItem: Boolean = False; // @addr $87A830
  Comet: Integer = 1; // @addr $87A834
  BGImage: Boolean = False; // @addr $87A838
  AnimShipFull: Boolean = False; // @addr $87A83C
  AnimCity: Boolean = False; // @addr $87A840
  AnimMenuShip: Boolean = True; // @addr $87A844
  AnimGov: Integer = 2; // @addr $87A848
  AnimStar: Boolean = True; // @addr $87A84C
  AnimHangar: Boolean = True; // @addr $87A850
  CircleAction: Boolean = True; // @addr $87A854
  StaticBackground: Boolean = True; // @addr $87A858
  ScrollTime: Integer = 20; // @addr $87A85C
  ScrollStep: Integer = 5; // @addr $87A860
  ScrollSense: Integer = 1; // @addr $87A864
  FilmSpeed: Integer = 1; // @addr $87A868
  BGOCount: Integer = 50; // @addr $87A86C
  BGOTime: Integer = 300; // @addr $87A870
  SpaceImage: Integer = 0; // @addr $87A874
  SoundEnabled: Boolean = False; // @addr $87A878
  SoundInSpaceEnabled: Boolean = False; // @addr $87A87C
  SoundVolume: Single = 1.0; // @addr $87A880
  RobotSoundVolume: Single = 1.0; // @addr $87A884
  MusicEnabled: Boolean = False; // @addr $87A888
  MusicInSpaceEnabled: Boolean = False; // @addr $87A88C
  MusicInHyperEnabled: Boolean = True; // @addr $87A890
  MusicInPlanetEnabled: Boolean = True; // @addr $87A894
  MusicVolume: Single = 0.75; // @addr $87A898
  MusicVolumeScale: Single = 1.0; // @addr $87A89C
  RobotMusicVolume: Single = 0.75; // @addr $87A8A0
  MaxFilmStepSkip: Integer = 3; // @addr $87A8A4
  FilmHistoryLimit: Integer = 1; // @addr 0x87A8A8 @note "CountFilmSave setting. UI range is 1..100; config loading clamps only the minimum to 1. Limit applies when a recording is added, not while loading a save."
  BeginCalcNextTurn: Single = 1.0; // @addr $87A8AC
  DoNotChangeMusicInBattle: Boolean = False; // @addr $87A8B0
  ViewFollowShip: Boolean = True; // @addr $87A8B4
  ActionDoubleClick: Boolean = True; // @addr $87A8B8
  GalaxyMapFontChoice: TGalaxyMapFontChoice = gmfNormalBold; // @addr 0x87A8BC @note "FontGalaxy setting; default gmfNormalBold. Out-of-range values also use the normal-bold font."
  FontQuest: Integer = 0; // @addr $87A8C0
  FontDialog: Integer = 0; // @addr $87A8C4
  FontSmoothingEnabled: Boolean = False; // @addr 0x87A8C8 @note "FontSmooth setting."
  ScreenshotFormat: Integer = 1; // @addr $87A8CC  0=BMP, 1=PNG, 2=JPEG.
  ScreenshotJpegQuality: Integer = 85; // @addr $87A8D0
  DynamicTipsPos: Boolean = True; // @addr $87A8D4
  ViewPathLength: Boolean = False; // @addr $87A8D8
  AfterburnerStopCondition: Integer = 35; // @addr $87A8DC
  TurnSaveStep: Integer = 0; // @addr 0x87A8E0
  QuickSaveExtraSlots: Integer = 0; // @addr 0x87A8E4
  MaxPlayerNews: Integer = 30; // @addr $87A8E8
  MaxSearchResult: Integer = 100; // @addr $87A8EC
  ClickAutoCloseForm: Boolean = True; // @addr $87A8F0
  AwardDialogsEnabled: Boolean = False; // @addr $87A8F4 Enables award-window clicks in the ship, scanner and ranger-rating screens; set by settings initialization.
  MultiThreadEnabled: Boolean = False; // @addr $87A8F8
  ShowWineWarning: Boolean = False; // @addr $87A8FC
  XonarSoundDevice: Boolean = False; // @addr $87A900
  ShowXonarWarning: Boolean = False; // @addr $87A904
  PlanetDepth: Single = 0; // @addr $87A908
  ShipPathDepth: Single = 15.0; // @addr $87A90C
  ShipPathEndDepth: Single = 14.0; // @addr $87A910
  UnitPathDepth: Single = 13.0; // @addr $87A914
  UnitPathEndDepth: Single = 12.0; // @addr $87A918
  ActionButtonDepth: Single = 9.0; // @addr $87A91C
  GalaxyStarDepth: Single = 20.0; // @addr $87A920
  GalaxyStarNameDepth: Single = 19.0; // @addr $87A924
  GalaxyWarDepth: Single = 18.0; // @addr $87A928
  ConstellationLineDepth: Single = 21.0; // @addr $87A92C
  ConstellationColorDepth: Single = 22.0; // @addr $87A930
  MemorySnapshotActive: Boolean = False; // @addr 0x87A934
  PreviousScreenId: TGameScreenId = screenNone; // @addr 0x87A938
  CurrentScreenId: TGameScreenId = screenNone; // @addr 0x87A93C
  RequestedScreenId: TGameScreenId = screenNone; // @addr 0x87A940
  PostLoadScreenId: TGameScreenId = screenNone; // @addr 0x87A944
  ShipReturnScreenId: TGameScreenId = screenNone; // @addr $87A948
  TalkReturnScreenId: TGameScreenId = screenNone; // @addr $87A94C
  ScannerReturnScreenId: TGameScreenId = screenNone; // @addr $87A950
  QuestReturnScreenId: TGameScreenId = screenNone; // @addr $87A954 @note "Quest selector or campaign screen that launched the active text quest."
  Screen13ReturnScreenId: TGameScreenId = screenNone; // @addr $87A958 @note "Return screen for native screen ID 13; its purpose remains unresolved."
  GalaxyReturnScreenId: TGameScreenId = screenNone; // @addr $87A95C Set by the star-map/ruins caller; consumed by galaxy-map Back.
  SaveManagerReturnScreenId: TGameScreenId = screenNone; // @addr 0x87A960
  GameMenuReturnScreenId: TGameScreenId = screenNone; // @addr $87A964
  SettingsReturnScreenId: TGameScreenId = screenNone; // @addr 0x87A968
  AchievementsReturnScreenId: TGameScreenId = screenNone; // @addr $87A96C
  LoadedSaveVersion: Integer = 0; // @addr 0x87A970
  LoadingFilmCount: Integer = -1; // @addr 0x87A974 @note "-1 outside the film-loading phase."
  BackgroundShade: Boolean = False; // @addr $87A978
  BackgroundBlur: Boolean = False; // @addr $87A97C
  BackgroundGrayscale: Boolean = False; // @addr $87A980
  PlanetClouds: Boolean = True; // @addr $87A984
  PlanetAtm: Boolean = True; // @addr $87A988
  AnimChangeForm: Boolean = True; // @addr $87A98C
  AnimMainFon: Boolean = True; // @addr $87A990
  SputnikShow: Boolean = True; // @addr $87A994
  SatelliteLightMapPath: WideString = 'Bm.Planet.S.Light094'; // @addr $87A998 Used by TPlanetGI.SetImageFromTemplate when creating its light buffers.
var
  SatelliteTemplateParameter1: Integer = 128; // @addr $87A99C
  SatelliteTemplateParameter2: Integer = 60; // @addr $87A9A0
  MinimumSatelliteTemplateRadius: Integer = 10; // @addr $87A9A4
  GeneratedSatelliteBaseRadius: Integer = 13; // @addr $87A9A8 Base for procedural satellite display sizes, separate from render-template limits.
  MaximumSatelliteTemplateRadius: Integer = 60; // @addr $87A9AC
  SatelliteRenderTemplates: TList = nil; // @addr $87A9B0 Owns TSputnikTempl instances.
  SpaceImageTemplates: array of TSpaceImageTemplate = nil; // @addr $87A9B4
  StarFieldImageTemplates: array of TStarFieldImageTemplate = nil; // @addr $87A9B8
var
  ForcedPlanetQuestId: Integer = -1; // @addr $87A9BC Nonnegative forces this quest ID in government offers; native default is -1.

implementation

// @unit-initialization $87671C
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
