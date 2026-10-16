unit GlobalsV;

interface

uses Classes;

const
  // SF_EndGame also accepts arbitrary script-defined integers. Values above four
  // select FormGameEnd.WinPirateN; keep GameEndReason as Integer.
  game_end_default = 0; // Ordinary end-of-film death or CustomWin/CustomLose event.
  game_end_player_death = 2; // Explicit death detected on a planet or during takeoff.
  game_end_terron_conversion = 4; // Script exit_end; FormGameEnd.LossConvertToTerron variants.

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
    screen_none=0,
    screen_main_menu=1,
    screen_introduction=3,
    screen_hangar=4,
    screen_planet=5,
    screen_uninhabited_planet=6,
    screen_text_quest=7,
    screen_equipment_shop=8,
    screen_ship=10,
    screen_talk=11,
    screen_scanner=12,
    screen_government=15,
    screen_star_map=16,
    screen_turn_replay=17,
    screen_galaxy_map=18,
    screen_jump=19,
    screen_ruins_talk=20,
    screen_arcade_battle=21,
    screen_asset_loading=22,
    screen_save_manager=23,
    screen_save_loading=24,
    screen_game_menu=25,
    screen_settings=26,
    screen_game_end=27,
    screen_info=28,
    screen_rewards=30,
    screen_about=31,
    screen_scores=32,
    screen_new_game=33,
    screen_goods_shop=34,
    screen_ranger_ranking=35,
    screen_portrait_selection=36,
    screen_journal=37,
    screen_planet_battle_selection=38,
    screen_quest_selection=39,
    screen_arcade_selection=40,
    screen_achievements=41
  ); // @size 0x01
  TGalaxyMapFontChoice = (
    map_font_ranger=1,
    map_font_mini=2,
    map_font_small=3,
    map_font_small_bold=4,
    map_font_normal=5,
    map_font_normal_bold=6
  ); // @size 0x04
  TGameScreenTable = array[TGameScreenId] of TObject;

function FormToId(Screen: TObject): TGameScreenId; // @addr 0x0045E874 @note "Raises when absent; nil matches the first empty slot."
function GetRegisteredScreenLoop(ScreenId: TGameScreenId): TObject; // @addr 0x0045E8B8 @note "No bounds check."
function IsSpaceBackdropScreen(ScreenId: TGameScreenId): Boolean; // @addr 0x0045E8C4
function ScreenUsesCompositeLoadAssets(ScreenId: TGameScreenId): Boolean; // @addr 0x0045E8DC

var
  DumpLoadedConfig: Boolean = False; // @addr $80A7F0
  HalfGovAnim: Boolean = False; // @addr $80A7F4
  QuestStyleIndex: Integer = 0; // @addr $80A7F8 // Zero-based.
  QuestPageAnimationEnabled: Boolean = True; // @addr $80A7FC
  DefaultOrder: Integer = 0; // @addr $80A800
  RightClickOnShip: Integer = 0; // @addr $80A804
  EstOptionEnabled: Boolean = False; // @addr $80A808 Native purpose remains unresolved.
  SendRecordOff: Boolean = False; // @addr $80A80C
  ChangeAutoPilot: Integer = 4; // @addr $80A810
  DisableAutoPilot: Boolean = False; // @addr $80A814
  SkipGiper: Boolean = False; // @addr $80A818
  Wind: Integer = 2; // @addr $80A81C
  PendingQuestName: WideString = 'Prison'; // @addr $80A820 @note "Native default; standalone selector replaces it with a numeric quest ID or a quest resource name."
var
  RegisteredScreens: TGameScreenTable; // @addr 0x00819D00
  SkipSavedPixelRestore: Boolean; // @addr $819DA8
  HardwareRenderingRequested: Boolean; // @addr $819DA9
  HardwareRenderingEnabled: Boolean; // @addr $819DAA
  RunningUnderWine: Boolean; // @addr $819DAB @note "Native startup checks ntdll wine_get_version/wine_get_host_version."
  ScaleViewportToWindow: Boolean; // @addr $819DAC
  UseTablesForGov: Boolean; // @addr $819DAD
  RangerFontName: WideString; // @addr $819DB0
  MiniFontName: WideString; // @addr $819DB4
  SmallFontName: WideString; // @addr $819DB8 @note "Initialized to Font.2Small."
  SmallBoldFontName: WideString; // @addr $819DBC @note "Initialized to Font.2SmallBold."
  NormalFontName: WideString; // @addr $819DC0 @note "Initialized to Font.2Normal."
  NormalBoldFontName: WideString; // @addr 0x00819DC4 @note "Initialized to Font.2NormalBold."
  BigFontName: WideString; // @addr 0x00819DC8 @note "Initialized to Font.2Big."
  HugeFontName: WideString; // @addr $819DCC
  IntroFontName: WideString; // @addr $819DD0
  AuthorsFontName: WideString; // @addr $819DD4
  SmoothSmallFontName: WideString; // @addr $819DD8 @note "Initialized to Font.Verdana8."
  SmoothSmallBoldFontName: WideString; // @addr $819DDC @note "Initialized to Font.Verdana8bold."
  SmoothNormalFontName: WideString; // @addr $819DE0 @note "Initialized to Font.Verdana9."
  SmoothNormalBoldFontName: WideString; // @addr $819DE4 @note "Initialized to Font.Verdana9bold."
  SmoothBigFontName: WideString; // @addr $819DE8
  SmoothHugeFontName: WideString; // @addr $819DEC
  SmoothIntroFontName: WideString; // @addr $819DF0
  PendingLoadFileName: AnsiString; // @addr 0x00819DF4
var
  LoadedFilmCount: Integer; // @addr 0x00819DF8
  GameEndReason: Integer; // @addr $819DFC @note "ger* ending codes; values 5..18 select the localized WinPirate epilogues. SF_EndGame can supply arbitrary integers."
var
  ShipTail: Integer = 0; // @addr $80A824
  ThreeDimensionalModeEnabled: Boolean = False; // @addr $80A828 @note "3D setting, cleared on EDirectXRender during device startup."
  AnimCaptain: Boolean = False; // @addr $80A82C
  AnimItem: Boolean = False; // @addr $80A830
  Comet: Integer = 1; // @addr $80A834
  BGImage: Boolean = False; // @addr $80A838
  AnimShipFull: Boolean = False; // @addr $80A83C
  AnimCity: Boolean = False; // @addr $80A840
  AnimMenuShip: Boolean = True; // @addr $80A844
  AnimGov: Integer = 2; // @addr $80A848
  AnimStar: Boolean = True; // @addr $80A84C
  AnimHangar: Boolean = True; // @addr $80A850
  CircleAction: Boolean = True; // @addr $80A854
  StaticBackground: Boolean = True; // @addr $80A858
  ScrollTime: Integer = 20; // @addr $80A85C
  ScrollStep: Integer = 5; // @addr $80A860
  ScrollSense: Integer = 1; // @addr $80A864
  FilmSpeed: Integer = 1; // @addr $80A868
  BGOCount: Integer = 50; // @addr $80A86C
  BGOTime: Integer = 300; // @addr $80A870
  SpaceImage: Integer = 0; // @addr $80A874
  SoundEnabled: Boolean = False; // @addr $80A878
  SoundInSpaceEnabled: Boolean = False; // @addr $80A87C
  SoundVolume: Single = 1.0; // @addr $80A880
  RobotSoundVolume: Single = 1.0; // @addr $80A884
  MusicEnabled: Boolean = False; // @addr $80A888
  MusicInSpaceEnabled: Boolean = False; // @addr $80A88C
  MusicInHyperEnabled: Boolean = True; // @addr $80A890
  MusicInPlanetEnabled: Boolean = True; // @addr $80A894
  MusicVolume: Single = 0.75; // @addr $80A898
  MusicVolumeScale: Single = 1.0; // @addr $80A89C
  RobotMusicVolume: Single = 0.75; // @addr $80A8A0
  MaxFilmStepSkip: Integer = 3; // @addr $80A8A4
  FilmHistoryLimit: Integer = 1; // @addr 0x0080A8A8 @note "CountFilmSave setting. UI range is 1..100; config loading clamps only the minimum to 1. Limit applies when a recording is added, not while loading a save."
  BeginCalcNextTurn: Single = 1.0; // @addr $80A8AC
  DoNotChangeMusicInBattle: Boolean = False; // @addr $80A8B0
  ViewFollowShip: Boolean = True; // @addr $80A8B4
  ActionDoubleClick: Boolean = True; // @addr $80A8B8
  GalaxyMapFontChoice: TGalaxyMapFontChoice = map_font_normal_bold; // @addr 0x0080A8BC @note "FontGalaxy setting; default map_font_normal_bold. Out-of-range values also use the normal-bold font."
  FontQuest: Integer = 0; // @addr $80A8C0
  FontDialog: Integer = 0; // @addr $80A8C4
  FontSmoothingEnabled: Boolean = False; // @addr 0x0080A8C8 @note "FontSmooth setting."
  ScreenshotFormat: Integer = 1; // @addr $80A8CC  0=BMP, 1=PNG, 2=JPEG.
  ScreenshotJpegQuality: Integer = 85; // @addr $80A8D0
  DynamicTipsPos: Boolean = True; // @addr $80A8D4
  ViewPathLength: Boolean = False; // @addr $80A8D8
  AfterburnerStopCondition: Integer = 35; // @addr $80A8DC
  TurnSaveStep: Integer = 0; // @addr 0x0080A8E0
  QuickSaveExtraSlots: Integer = 0; // @addr 0x0080A8E4
  MaxPlayerNews: Integer = 30; // @addr $80A8E8
  MaxSearchResult: Integer = 100; // @addr $80A8EC
  ClickAutoCloseForm: Boolean = True; // @addr $80A8F0
  AwardDialogsEnabled: Boolean = False; // @addr $80A8F4 Enables award-window clicks in the ship, scanner and ranger-rating screens; set by settings initialization.
  MultiThreadEnabled: Boolean = False; // @addr $80A8F8
  ShowWineWarning: Boolean = False; // @addr $80A8FC
  XonarSoundDevice: Boolean = False; // @addr $80A900
  ShowXonarWarning: Boolean = False; // @addr $80A904
  PlanetDepth: Single = 0; // @addr $80A908
  ShipPathDepth: Single = 15.0; // @addr $80A90C
  ShipPathEndDepth: Single = 14.0; // @addr $80A910
  UnitPathDepth: Single = 13.0; // @addr $80A914
  UnitPathEndDepth: Single = 12.0; // @addr $80A918
  ActionButtonDepth: Single = 9.0; // @addr $80A91C
  GalaxyStarDepth: Single = 20.0; // @addr $80A920
  GalaxyStarNameDepth: Single = 19.0; // @addr $80A924
  GalaxyWarDepth: Single = 18.0; // @addr $80A928
  ConstellationLineDepth: Single = 21.0; // @addr $80A92C
  ConstellationColorDepth: Single = 22.0; // @addr $80A930
  MemorySnapshotActive: Boolean = False; // @addr 0x0080A934
  PreviousScreenId: TGameScreenId = screen_none; // @addr 0x0080A938
  CurrentScreenId: TGameScreenId = screen_none; // @addr 0x0080A93C
  RequestedScreenId: TGameScreenId = screen_none; // @addr 0x0080A940
  PostLoadScreenId: TGameScreenId = screen_none; // @addr 0x0080A944
  ShipReturnScreenId: TGameScreenId = screen_none; // @addr $80A948
  TalkReturnScreenId: TGameScreenId = screen_none; // @addr $80A94C
  ScannerReturnScreenId: TGameScreenId = screen_none; // @addr $80A950
  QuestReturnScreenId: TGameScreenId = screen_none; // @addr $80A954 @note "Quest selector or campaign screen that launched the active text quest."
  Screen13ReturnScreenId: TGameScreenId = screen_none; // @addr $80A958 @note "Return screen for native screen ID 13; its purpose remains unresolved."
  GalaxyReturnScreenId: TGameScreenId = screen_none; // @addr $80A95C Set by the star-map/ruins caller; consumed by galaxy-map Back.
  SaveManagerReturnScreenId: TGameScreenId = screen_none; // @addr 0x0080A960
  GameMenuReturnScreenId: TGameScreenId = screen_none; // @addr $80A964
  SettingsReturnScreenId: TGameScreenId = screen_none; // @addr 0x0080A968
  AchievementsReturnScreenId: TGameScreenId = screen_none; // @addr $80A96C
  LoadedSaveVersion: Integer = 0; // @addr 0x0080A970
  LoadingFilmCount: Integer = -1; // @addr 0x0080A974 @note "-1 outside the film-loading phase."
  BackgroundShade: Boolean = False; // @addr $80A978
  BackgroundBlur: Boolean = False; // @addr $80A97C
  BackgroundGrayscale: Boolean = False; // @addr $80A980
  PlanetClouds: Boolean = True; // @addr $80A984
  PlanetAtm: Boolean = True; // @addr $80A988
  AnimChangeForm: Boolean = True; // @addr $80A98C
  AnimMainFon: Boolean = True; // @addr $80A990
  SputnikShow: Boolean = True; // @addr $80A994
  SatelliteLightMapPath: WideString = 'Bm.Planet.S.Light094'; // @addr $80A998 Used by TPlanetGI.SetImageFromTemplate when creating its light buffers.
var
  SatelliteSurfaceTextureWidth: Integer = 128; // @addr $80A99C
  SatelliteSurfaceTextureHeight: Integer = 60; // @addr $80A9A0
  MinimumSatelliteTemplateRadius: Integer = 10; // @addr $80A9A4
  GeneratedSatelliteBaseRadius: Integer = 13; // @addr $80A9A8 Base for procedural satellite display sizes, separate from render-template limits.
  MaximumSatelliteTemplateRadius: Integer = 60; // @addr $80A9AC
  SatelliteRenderTemplates: TList = nil; // @addr $80A9B0 Owns TSputnikTempl instances.
  SpaceImageTemplates: array of TSpaceImageTemplate = nil; // @addr $80A9B4
  StarFieldImageTemplates: array of TStarFieldImageTemplate = nil; // @addr $80A9B8
var
  ForcedPlanetQuestId: Integer = -1; // @addr $80A9BC Nonnegative forces this quest ID in government offers; native default is -1.

implementation

// @unit-initialization $80671C
// @unit-finalization $45E9E8

uses SysUtils;

{ @routine $45E874 FormToId }
function FormToId(Screen: TObject): TGameScreenId;
var
  Id: TGameScreenId;
begin
  for Id := Low(RegisteredScreens) to High(RegisteredScreens) do
  begin
    if RegisteredScreens[Id] = Screen then
    begin
      Result := Id;
      Exit;
    end;
  end;
  raise Exception.Create('FormToId');
end;
{ @end $45E874 }

{ @routine $45E8B8 GetRegisteredScreenLoop }
function GetRegisteredScreenLoop(ScreenId: TGameScreenId): TObject;
begin
  Result := RegisteredScreens[ScreenId];
end;
{ @end $45E8B8 }

{ @routine $45E8C4 IsSpaceBackdropScreen }
function IsSpaceBackdropScreen(ScreenId: TGameScreenId): Boolean;
begin
  Result := (ScreenId = screen_star_map) or (ScreenId = screen_galaxy_map) or
    (ScreenId = screen_turn_replay) or (ScreenId = screen_talk);
end;
{ @end $45E8C4 }

{ @routine $45E8DC ScreenUsesCompositeLoadAssets }
function ScreenUsesCompositeLoadAssets(ScreenId: TGameScreenId): Boolean;
begin
  Result := False;
  if IsSpaceBackdropScreen(ScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_asset_loading) and IsSpaceBackdropScreen(PostLoadScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_ship) and IsSpaceBackdropScreen(ShipReturnScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_scanner) and IsSpaceBackdropScreen(ScannerReturnScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = TGameScreenId(13)) and IsSpaceBackdropScreen(Screen13ReturnScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_save_manager) and IsSpaceBackdropScreen(SaveManagerReturnScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_game_menu) and IsSpaceBackdropScreen(GameMenuReturnScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_settings) and IsSpaceBackdropScreen(SettingsReturnScreenId) then
  begin
    Result := True;
    Exit;
  end;
  if (ScreenId = screen_settings) and (SettingsReturnScreenId = screen_game_menu) and
    IsSpaceBackdropScreen(GameMenuReturnScreenId) then Result := True;
end;
{ @end $45E8DC }

end.
