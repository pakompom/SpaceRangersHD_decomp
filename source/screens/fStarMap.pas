unit fStarMap;
// Unit bracket (inferred): .text 0x007A5B74..0x007C8A63; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_Circle, GI_GraphBuf, GI_GraphButton, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, GI_SpaceCircle, GI_SpaceImg, GI_StarField, GI_Window, SE_Space, Types, aAsteroid, aEFilm, aGalaxy, aItem, aShip, fPanelLoad, fPanelMain;

type
  TStarMapMode = (smmInactive=0, smmOrders=1, smmTurnFilm=2); // @size 0x1
  TStarMapResumeMode = (smrNormal=0, smrOrders=1, smrTurnFilm=2, smrWaitForTurn=3); // @size 0x1
  TStarMapPathKind = (smpNone=0, smpAsteroid=1, smpShip=2); // @size 0x4
  TStarMapReservedEntry = packed record // @size $08 Native anonymous array element size; no element accesses found in the indexed screen methods.
    Data: array[0..7] of Byte; // @offset $00
  end;

  TfStarMap = class(TMessageLoopGIWithMainPanel) // @size 0x29C
  public
    LoadPanel: TfPanelLoad; // @offset 0xD4
    Mode: TStarMapMode; // @offset 0xD8
    ResumeMode: TStarMapResumeMode; // @offset 0xD9
    ScrollLeftHeld: Boolean; // @offset 0xDA
    ScrollRightHeld: Boolean; // @offset 0xDB
    ScrollUpHeld: Boolean; // @offset 0xDC
    ScrollDownHeld: Boolean; // @offset 0xDD
    CenterShipButton: TGraphButtonGI; // @offset 0xE0
    TerronFadeImage: TObjectGI; // @offset 0xE8
    LargeHelpBuffer: TGraphBufGI; // @offset 0xEC
    LargeHelpText: WideString; // @offset 0xF0
    LargeHelpTimer: PCallbackTimerGI; // @offset 0xF4
    LargeHelpProgress: Single; // @offset 0xF8
    PendingHoleRefresh: THole; // @offset 0xFC
    PlanetBattleMapId: Integer; // @offset 0x100
    PlanetBattleState: Integer; // @offset 0x104
    DisplayedObject: TObject; // @offset 0x108
    SuppressMiddleFollowCycle: Boolean; // @offset $10C Left-button selection sets this for a newly selected follow target.
    SpaceEffectsTimer: PCallbackTimerGI; // @offset 0x110
    CursorObject: TObject; // @offset 0x114
    MapScrollTimer: PCallbackTimerGI; // @offset 0x118
    PlayerPathTimer: PCallbackTimerGI; // @offset 0x11C
    ScannerSelectionActive: Boolean; // @offset 0x120
    TalkSelectionActive: Boolean; // @offset 0x121
    SelectedWeapons: array[0..4] of Boolean; // @offset 0x122
    InterceptorSelectionActive: Boolean; // @offset 0x127
    CustomSelectionActive: Boolean; // @offset 0x128
    CustomSelectionItem: TItem; // @offset 0x12C
    CustomSelectionInfoName: WideString; // @offset 0x130
    CustomSelectionRadius: Integer; // @offset 0x134
    CustomSelectionColor: Cardinal; // @offset 0x138
    CustomSelectionAllowedCursor: WideString; // @offset 0x13C
    CustomSelectionDeniedCursor: WideString; // @offset 0x140
    CustomSelectionSuccessText: WideString; // @offset 0x144
    CustomSelectionOutOfRangeText: WideString; // @offset 0x148
    CustomSelectionFailureText: WideString; // @offset 0x14C
    MinimapPathKind: TStarMapPathKind; // @offset 0x154
    WeaponPanel: TPanelGI; // @offset 0x158
    WeaponPanelRestTop: Integer; // @offset 0x15C
    WeaponPanelProgress: Single; // @offset 0x160
    WeaponPanelTarget: Integer; // @offset 0x164
    WeaponPanelTimer: PCallbackTimerGI; // @offset 0x168
    SpacePanel: TPanelGI; // @offset 0x16C
    SpacePanelRestTop: Integer; // @offset 0x170
    SpacePanelProgress: Single; // @offset 0x174
    SpacePanelTarget: Integer; // @offset 0x178
    SpacePanelTimer: PCallbackTimerGI; // @offset 0x17C
    AnimateSpacePanelOnResume: Boolean; // @offset 0x180
    DeferredEndTurnTimer: PCallbackTimerGI; // @offset 0x184
    PathAsteroid: TAsteroid; // @offset 0x188
    FilmFrameTimer: PCallbackTimerGI; // @offset 0x18C
    FilmStepIndex: Integer; // @offset 0x190
    NextFilmCommand: PEFilmCommand; // @offset 0x194
    FilmProgressTimer: PCallbackTimerGI; // @offset 0x198
    ContinueTurnCalculation: Boolean; // @offset $19C
    BreakRequested: Boolean; // @offset 0x19D
    BreakOnNextFilm: Boolean; // @offset 0x19E
    Flag19F: Boolean; // @offset $19F Set at film start; no reads found in indexed screen methods.
    ReservedFilmState1A0: Integer; // @offset $1A0 Cleared at film start; no reads found.
    FilmFrameIntervalMs: Single; // @offset 0x1A4
    FilmFrameIntervalDelta: Single; // @offset 0x1A8
    FilmCameraPosition: TPointF; // @offset 0x1AC
    FilmCameraTarget: TPointF; // @offset 0x1B4
    FilmCameraTargetUntilStep: Integer; // @offset 0x1BC
    FilmCameraEventIndex: Integer; // @offset 0x1C0
    FilmCameraTargetKind: Integer; // @offset 0x1C4
    FilmCameraShakeAngle: Single; // @offset 0x1C8
    FilmCameraShakeOffset: TPointF; // @offset 0x1CC
    FilmCameraSpeed: Single; // @offset 0x1D4
    FilmCameraMoving: Boolean; // @offset 0x1D8
    ReservedEntries1: array of TStarMapReservedEntry; // @offset $1DC 250 entries; native RTTI $7A5B74. Allocated/freed, purpose unresolved.
    ReservedEntries2: array of TStarMapReservedEntry; // @offset $1E0 250 entries; native RTTI $7A5B98. Allocated/freed, purpose unresolved.
    ReservedFilmState1E4: Integer; // @offset $1E4 Cleared at film start/restart; no reads found.
    TrailingEffectSteps: Integer; // @offset 0x1EC
    DisplayedFilmObject: TObjectSE; // @offset 0x1F0
    MapControls: TPanelGI; // @offset 0x1F4
    PartnerPanel: TPanelGI; // @offset 0x1F8
    SecondaryPartnerPanel: TPanelGI; // @offset 0x1FC
    InfoWindow: TWindowGI; // @offset 0x200
    InfoTextLabel: TLabelGI; // @offset 0x204
    ItemInfoWindow: TWindowGI; // @offset 0x208
    ShipInfoPanel: TPanelGI; // @offset 0x20C
    PlanetInfoPanel: TPanelGI; // @offset 0x210
    StarInfoWindow: TWindowGI; // @offset 0x214
    StandardInfoPanel: TPanelGI; // @offset 0x218
    StarField: TStarFieldGI; // @offset 0x21C
    ActionCircle: TCircleGI; // @offset 0x220
    ActionColorCircle: TSpaceCircleGI; // @offset 0x224
    WeaponColorCircles: array[0..3] of TSpaceCircleGI; // @offset 0x228
    WeaponButtons: array[0..4] of TGraphButtonGI; // @offset 0x238
    WeaponImages: array[0..4] of TImageGI; // @offset 0x24C
    AllWeaponsButton: TGraphButtonGI; // @offset 0x260
    HideSpacePanelButton: TGraphButtonGI; // @offset 0x264
    ShowSpacePanelButton: TGraphButtonGI; // @offset 0x268
    ScannerButton: TGraphButtonGI; // @offset 0x26C
    TalkButton: TGraphButtonGI; // @offset 0x270
    TurnFilmButton: TGraphButtonGI; // @offset 0x274
    WeaponBackgroundImage: TImageGI; // @offset 0x278
    SpaceBackgroundImage: TImageGI; // @offset 0x27C
    ShipToInspect: TShip; // @offset 0x280
    HitObjectPosition: TPoint; // @offset 0x284
    HitObjectSize: TPoint; // @offset 0x28C
    BattleMusicSelected: Boolean; // @offset 0x294
    EndTurnAfterOpen: Boolean; // @offset 0x295
    PendingSceneObjects: TList; // @offset 0x298

    constructor Create; // @addr 0x7A5CA0 @ida "TfStarMap *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x7A5D78 @ida "void __usercall $name(TfStarMap *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure DrawFrame; override; // @addr 0x7ADBA0
    procedure OnOpen; override; // @addr 0x7A7778
    procedure OnClose; override; // @addr 0x7A86C8
    procedure SelectMusic; override; // @addr 0x7C89C4
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x7BE414 @ida "void __userpurge $name(TfStarMap *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure InitializeLayout; override; // @addr 0x7A605C
    procedure UpdateActionCursor(CanTake: Boolean); override; // @addr 0x7BD4A4
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x7C8928
    procedure EndTurnClicked(Sender: TObjectGI); // @addr 0x7A9AE0
    procedure ClearPathOverlay(PlayerPath: Boolean); // @addr 0x7ABABC
    procedure RefreshScoreModsLabel; // @addr 0x7AA44C

    procedure ProcessTurnFilm; // @addr 0x7BEF24
    procedure AdvanceFilmFrame(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7BFB44
    procedure UpdateTurnCalculation(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7BFCB0
    procedure StartTurnFilm; // @addr 0x7BE710
    procedure StopTurnFilm(StopTurnProcessing: Boolean); // @addr 0x7BEB60
    procedure RestartTurnFilm; // @addr 0x7BEC70
    procedure OpenFilmHistoryClicked(Sender: TObjectGI); // @addr 0x7AA400

    function GetMapCenter: TPoint; // @addr 0x7A5E1C @ida "void __usercall $name(TfStarMap *Self@<eax>, TPoint *Result@<edx>);"
    procedure SetMapCenterManually(Point: TPoint); // @addr 0x7A5E88 @ida "void __usercall $name(TfStarMap *Self@<eax>, TPoint *Point@<edx>);" @note "Disables automatic film-camera following."
    procedure SetMapCenter(Center: TPoint); // @addr 0x7A5F24 @ida "void __usercall $name(TfStarMap *Self@<eax>, TPoint *Center@<edx>);"
    procedure CenterMapForTalk(Position: TPointF); // @addr 0x7A5FB8 @ida "void __usercall $name(TfStarMap *Self@<eax>, TPointF *Position@<edx>);"
    procedure RestorePendingSceneObjects; // @addr 0x7A8AE8
    procedure BuildSpaceBackground(StarField: TStarFieldGI; SpaceImage: TSpaceImgGI; Seed: Cardinal; BackgroundIndex: Integer); // @addr 0x7A8CA4
    procedure SaveSpaceImageState(SpaceImage: TSpaceImgGI); // @addr 0x7A9898
    procedure SaveSpaceBackground; // @addr 0x7A9A54
    procedure DeferredEndTurn(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7A9A98
    procedure MapKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x7A9DCC
    procedure MapKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr 0x7AA348
    procedure BuildShipPathOverlay(Ship: TShip; DelayEndImage: Boolean; InitialImagePath: WideString); // @addr 0x7AA930 @note "May rebuild the ship movement path and update its order destination."
    procedure UpdatePathEndImage(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7ABA14
    procedure ShowAsteroidPath(Asteroid: TAsteroid); // @addr 0x7ABC28
    procedure ClearAsteroidPath; // @addr 0x7ABEC8
    procedure ClearPartnerButtons; // @addr 0x7ABF70
    procedure RebuildPartnerButtons; // @addr 0x7ABF9C
    procedure PartnerClicked(Sender: TObjectGI); // @addr 0x7AC890
    procedure PartnerRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7ACB3C @ida "void __userpurge $name(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure PartnerMouseEnter(Sender: TObjectGI); // @addr 0x7ACC40
    procedure PartnerMouseLeave(Sender: TObjectGI); // @addr 0x7ACC98
    procedure AddMapAnimation(Position: TPointF; ImagePath: WideString; DelayMs: Integer); // @addr 0x7ACCB4 @ida "void __userpurge $name(TfStarMap *Self@<eax>, TPointF *Position@<edx>, unsigned __int16 *ImagePath@<ecx>, int DelayMs@<^0>);"
    procedure ClearMapAnimations; // @addr 0x7ACDE8
    procedure MapAnimationFinished(Sender: TObjectGI); // @addr 0x7ACE40
    function FindObjectAtCursor: TObject; // @addr 0x7ACE64 @note "Returns a borrowed game object or nil; updates HitObjectPosition and HitObjectSize."
    procedure QueueInterfaceImages; // @addr 0x7AD81C
    procedure ShowLargeHelp(const Text: WideString); // @addr 0x7AD87C
    procedure HideLargeHelp; // @addr 0x7AD914
    procedure AnimateLargeHelp(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7AD968
    procedure RedrawMap; // @addr 0x7ADB60
    procedure RunTalkDialogs; // @addr 0x7ADF00
    procedure GalaxyClicked(Sender: TObjectGI); // @addr 0x7AE204
    procedure ShipClicked(Sender: TObjectGI); // @addr 0x7AE2D4
    procedure StartOrderMode; // @addr 0x7AE3EC
    procedure StopOrderMode; // @addr 0x7AE980
    procedure HideOrderInterface; // @addr 0x7AEB78
    procedure ConfigureMiddleButtonAction; // @addr 0x7AEC2C
    procedure ScrollMap(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7AEC7C
    procedure AdvanceSpaceEffects(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7AEDFC
    function IsMapPointBlocked(Sender: TObjectGI; Point: TPoint): Boolean; // @addr 0x7AEE68 @ida "bool __usercall $name@<al>(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, TPoint *Point@<ecx>);"
    procedure MapLeftButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7AF0E8 @ida "void __userpurge $name(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MapMiddleButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7B16CC @ida "void __userpurge $name(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MapRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7B1FA4 @ida "void __userpurge $name(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7B2B84 @ida "void __userpurge $name(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure OrderKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x7B2CF0
    procedure OrderKeyUp(Sender: TObjectGI; Key: Cardinal); // @addr 0x7B34E0
    procedure SelectAllUsableWeapons; // @addr 0x7B3510
    procedure SelectUntargetedWeapons; // @addr 0x7B35BC
    procedure ShowObjectInfo(Obj: TObject); // @addr 0x7B3648 @note "Nil hides the object panels. Accepts game objects, not scene objects."
    procedure MapScrollChanged; // @addr 0x7BAFF4
    function GetPriceSnapshotKey(Obj: TObject): WideString; // @addr 0x7BB018 @ida "void __usercall $name(TfStarMap *Self@<eax>, TObject *Obj@<edx>, unsigned __int16 **Result@<ecx>);"
    procedure SaveVisiblePriceSnapshots; // @addr 0x7BB128
    procedure CenterOnShip(Ship: TShip); // @addr 0x7BB384
    procedure CenterOnDominator(Selection: Integer); // @addr 0x7BB4B0 @note "Selection 1 chooses the nearest TKling; 2 chooses the farthest."
    procedure CenterShipClicked(Sender: TObjectGI); // @addr 0x7BB5C4
    procedure CenterShipMouseEnter(Sender: TObjectGI); // @addr 0x7BB5E4
    procedure CenterShipMouseLeave(Sender: TObjectGI); // @addr 0x7BB630
    procedure AllWeaponsClicked(Sender: TObjectGI); // @addr 0x7BB64C
    procedure ScannerClicked(Sender: TObjectGI); // @addr 0x7BB6BC
    procedure TalkClicked(Sender: TObjectGI); // @addr 0x7BB794
    procedure SelectInterceptorTarget; // @addr 0x7BB858
    procedure BeginCustomSelection; // @addr 0x7BB91C
    procedure ToggleWeaponPanelClicked(Sender: TObjectGI); // @addr 0x7BB9A4
    procedure WeaponButtonDown(Sender: TObjectGI); // @addr 0x7BB9F8
    procedure WeaponButtonUp(Sender: TObjectGI); // @addr 0x7BBA44
    procedure RefreshWeaponButtons; // @addr 0x7BBB80
    procedure RefreshActionRanges; // @addr 0x7BC474
    procedure HideActionRanges; // @addr 0x7BCC30
    procedure RebuildTargetMarkers; // @addr 0x7BCCC4
    procedure ClearTargetMarkers; // @addr 0x7BD44C
    procedure UpdateWeaponPanelPosition; // @addr 0x7BDECC
    procedure AnimateWeaponPanel(Target: Integer); // @addr 0x7BDFEC @note "Stores the animation direction; native toggle passes -1 to hide and +1 to show."
    procedure AdvanceWeaponPanel(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7BE060
    procedure UpdateSpacePanelPosition; // @addr 0x7BE188
    procedure AnimateSpacePanel(Target: Integer); // @addr 0x7BE278 @note "Stores the signed animation direction."
    procedure AdvanceSpacePanel(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7BE2EC
    procedure BreakTurnClicked(Sender: TObjectGI); // @addr 0x7BFDF8
    procedure UpdateFilmCamera; // @addr 0x7BFEB8
    procedure CenterFilmShipClicked(Sender: TObjectGI); // @addr 0x7C07CC
    procedure CenterFilmShipMouseEnter(Sender: TObjectGI); // @addr 0x7C07F0
    procedure CenterFilmShipMouseLeave(Sender: TObjectGI); // @addr 0x7C084C
    procedure FilmMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7C0868 @ida "void __userpurge $name(TfStarMap *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    function FindFilmObjectAtCursor(out ObjectId: Cardinal): TObjectSE; // @addr 0x7C0914 @note "Returns a borrowed scene object; sets ObjectId to zero on failure."
    procedure ShowFilmObjectInfo(Obj: TObjectSE; ObjectId: Cardinal); // @addr 0x7C0DA8 @note "Nil hides the object panels. ObjectId resolves recorded information in the current film."
    procedure PrepareTalkDisplay; // @addr 0x7C805C
    procedure WaitForTurnOrTalk; // @addr 0x7C810C
    procedure UpdateTerronTransformation; // @addr 0x7C829C
    procedure TerronTransformationStarted(Sender: TObjectGI); // @addr 0x7C85F4
    procedure TerronTransformationFrame(Sender: TObjectGI); // @addr 0x7C86A8
    procedure TerronTransformationFinished(Sender: TObjectGI); // @addr 0x7C8878
  end;

function GetTurnFilmFrameInterval(Activity: Integer): Integer; // @addr 0x7BE69C @note "Returns milliseconds, adjusted by the configured film speed."

var
  PanelSlideCurve: array[0..15] of Single = (0, 0.033, 0.112, 0.269, 0.456, 0.675, 0.882, 1.023, 1.09, 1.127, 1.129, 1.111, 1.064, 1.036, 1.011, 1); // @addr $87C214
  FilmCameraLookAheadSteps: Integer = 30; // @addr $87C254

implementation

uses Globals, GlobalsV, SE_Process, GR_Main, ThreadCalc, aCalc, aPlayer, EC_Str,
  GI_GAI, aEFilmEnd, aMyFunction, fLoad, fFilmFile, Windows, Messages, GI_MultiImage, aGalaxyStruct, aScript, fShip2, SysUtils, GR_DX, GR_Rect, SE_Hole, aKling, GR_Gi, aRanger, fGalaxy2, fSaveManager, GI_MessageBox, aConst, aPlanet, aRuins, Robot, aSaveLoad, fLoadRobot, GI_StarFieldImg, Math, Achievements, EC_Mem, aMissile, SE_Missile, SE_Ship2, SE_Container, SE_Ruins, SE_Asteroid, SE_Planet, SE_Star, aEObjInfo, aPirate, aPath, fTalk, fGoodsShop2, aTranclucator, ab_MainForm;

{ @routine $7A5CA0 TfStarMap_Create }
constructor TfStarMap.Create;
begin
  inherited Create;
  UpdateRectsEnabled := False;
  LoadPanel := TfPanelLoad.Create;
  SetLength(ReservedEntries1, 250);
  SetLength(ReservedEntries2, 250);
  FilmCameraSpeed := 1;
  ShipToInspect := nil;
  PendingHoleRefresh := nil;
  PendingSceneObjects := TList.Create;
end;
{ @end $7A5CA0 }

{ @routine $7A5D78 TfStarMap_Destroy }
destructor TfStarMap.Destroy;
begin
  ReservedEntries1 := nil;
  ReservedEntries2 := nil;
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  if PendingSceneObjects <> nil then PendingSceneObjects.Free;
  PendingSceneObjects := nil;
  inherited Destroy;
end;
{ @end $7A5D78 }

{ @routine $7A5E1C TfStarMap_GetMapCenter }
function TfStarMap.GetMapCenter: TPoint;
begin
  if MapControls = nil then MapControls := GetByName('MainPanel') as TPanelGI;
  Result := MapControls.ScrollOffset;
end;
{ @end $7A5E1C }

{ @routine $7A5E88 TfStarMap_SetMapCenterManually }
procedure TfStarMap.SetMapCenterManually(Point: TPoint);
begin
  if MapControls = nil then MapControls := GetByName('MainPanel') as TPanelGI;
  MapControls.SetScrollOffset(Point);
  if SpaceProcess.IsSpaceOpen then SpaceProcess.Space.MapScrollChanged(nil);
  FilmCameraFollow := False;
end;
{ @end $7A5E88 }

{ @routine $7A5F24 TfStarMap_SetMapCenter }
procedure TfStarMap.SetMapCenter(Center: TPoint);
begin
  if MapControls = nil then MapControls := GetByName('MainPanel') as TPanelGI;
  MapControls.SetScrollOffset(Center);
  if SpaceProcess.IsSpaceOpen then SpaceProcess.Space.MapScrollChanged(nil);
end;
{ @end $7A5F24 }

{ @routine $7A5FB8 TfStarMap_CenterMapForTalk }
procedure TfStarMap.CenterMapForTalk(Position: TPointF);
var
  Offset: TPoint;
begin
  Offset := Classes.Point(0, 0);
  ShowObjectInfo(nil);
  if TalkShip <> nil then
    SetMapCenter(SubtractPoints(TruncatePointF(Position), Offset))
  else if (TalkPlanet <> nil) and (TalkPlanet.CurrentStar = GetPlayer.CurrentStar) then
    SetMapCenter(SubtractPoints(TruncatePointF(Position), Offset));
end;
{ @end $7A5FB8 }

{ @routine $7A605C TfStarMap_InitializeLayout }
procedure TfStarMap.InitializeLayout;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fStarMap... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    Parent.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    SetPosition(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
    SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('CircleActionShr') do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
    end;
    with FindByNameRecursive('LargeHelp') do
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('MapPanel') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('CenterShip') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('MapPanelA') do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
      with NextSibling do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    end;
    with FindByNameRecursive('FPS') do
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('Mods') do
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y - ExtraScreenHeight div 2));
    FindByNameRecursive('PanelMain').SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
    with FindByNameRecursive('PanelSpace') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    if GiResourceVariant = 2 then
      FindByNameRecursive('PanelLoad').SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)))
    else if GiResourceVariant = 1 then
      FindByNameRecursive('PanelLoad').SetPosition(Classes.Point(-400, -300));
    with FindByNameRecursive('MapPartnerDuty').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('CircleActionColor') do
    begin
      SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('CircleActionWeaponColor') do
    begin
      SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('CircleActionWeaponColor2') do
    begin
      SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('CircleActionWeaponColor3') do
    begin
      SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('CircleActionWeaponColor4') do
    begin
      SetPosition(Classes.Point(-(GameScreenWidth shr 1), -(GameScreenHeight shr 1)));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('SpaceImg') do
    begin
      SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('StarField') do
    begin
      SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('StarFieldImg') do
    begin
      SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('StarFieldM') do
    begin
      SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    end;
    with FindByNameRecursive('Info') do
      SetPosition(Classes.Point(LocalPosition.X - ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('InfoStd') do
      SetPosition(Classes.Point(LocalPosition.X - ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('InfoShip') do
      SetPosition(Classes.Point(LocalPosition.X - ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('InfoPlanet') do
      SetPosition(Classes.Point(LocalPosition.X - ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('InfoStar') do
      SetPosition(Classes.Point(LocalPosition.X - ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
    with FindByNameRecursive('InfoItem') do
      SetPosition(Classes.Point(LocalPosition.X - ExtraScreenWidth div 2, LocalPosition.Y - ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  MapControls := GetByName('MainPanel') as TPanelGI;
  PartnerPanel := GetByName('MapPartner') as TPanelGI;
  SecondaryPartnerPanel := GetByName('MapPartner2') as TPanelGI;
  InfoWindow := GetByName('Info') as TWindowGI;
  InfoTextLabel := GetByName('InfoText') as TLabelGI;
  ItemInfoWindow := GetByName('InfoItem') as TWindowGI;
  ShipInfoPanel := GetByName('InfoShip') as TPanelGI;
  PlanetInfoPanel := GetByName('InfoPlanet') as TPanelGI;
  StarInfoWindow := GetByName('InfoStar') as TWindowGI;
  StandardInfoPanel := GetByName('InfoStd') as TPanelGI;
  StarField := GetByName('StarField') as TStarFieldGI;
  ActionCircle := GetByName('CircleActionShr') as TCircleGI;
  ActionColorCircle := GetByName('CircleActionColor') as TSpaceCircleGI;
  WeaponColorCircles[0] := GetByName('CircleActionWeaponColor') as TSpaceCircleGI;
  WeaponColorCircles[1] := GetByName('CircleActionWeaponColor2') as TSpaceCircleGI;
  WeaponColorCircles[2] := GetByName('CircleActionWeaponColor3') as TSpaceCircleGI;
  WeaponColorCircles[3] := GetByName('CircleActionWeaponColor4') as TSpaceCircleGI;
  WeaponButtons[0] := GetByName('PS_W0') as TGraphButtonGI;
  WeaponButtons[1] := GetByName('PS_W1') as TGraphButtonGI;
  WeaponButtons[2] := GetByName('PS_W2') as TGraphButtonGI;
  WeaponButtons[3] := GetByName('PS_W3') as TGraphButtonGI;
  WeaponButtons[4] := GetByName('PS_W4') as TGraphButtonGI;
  WeaponImages[0] := GetByName('PS_W0I') as TImageGI;
  WeaponImages[1] := GetByName('PS_W1I') as TImageGI;
  WeaponImages[2] := GetByName('PS_W2I') as TImageGI;
  WeaponImages[3] := GetByName('PS_W3I') as TImageGI;
  WeaponImages[4] := GetByName('PS_W4I') as TImageGI;
  AllWeaponsButton := GetByName('PS_WA') as TGraphButtonGI;
  HideSpacePanelButton := GetByName('PS_Hide') as TGraphButtonGI;
  ShowSpacePanelButton := GetByName('PS_Show') as TGraphButtonGI;
  ScannerButton := GetByName('PS_Scaner') as TGraphButtonGI;
  TalkButton := GetByName('PS_Talk') as TGraphButtonGI;
  TurnFilmButton := GetByName('PS_Film') as TGraphButtonGI;
  MapControls.KeyDownCallback := MapKeyDown;
  MapControls.KeyUpCallback := MapKeyUp;
  MapControls.SetDragScrollingEnabled(True);
  MapControls.ScrollType := pstSimple;
  WeaponBackgroundImage := GetByName('PS_ImageWeaponBG') as TImageGI;
  SpaceBackgroundImage := GetByName('PS_ImageBG') as TImageGI;
  LargeHelpBuffer := GetByName('LargeHelp') as TGraphBufGI;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  (GetByName('PM_Gal') as TGraphButtonGI).UpCallback := GalaxyClicked;
  (GetByName('PS_Film') as TGraphButtonGI).UpCallback := OpenFilmHistoryClicked;
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  CenterShipButton := GetByName('CenterShip') as TGraphButtonGI;
  AllWeaponsButton.UpCallback := AllWeaponsClicked;
  ScannerButton.UpCallback := ScannerClicked;
  TalkButton.UpCallback := TalkClicked;
  HideSpacePanelButton.UpCallback := ToggleWeaponPanelClicked;
  ShowSpacePanelButton.UpCallback := ToggleWeaponPanelClicked;
  WeaponPanel := GetByName('PS_Up') as TPanelGI;
  WeaponPanelRestTop := WeaponPanel.LocalPosition.Y;
  SpacePanel := GetByName('PanelSpace') as TPanelGI;
  SpacePanelRestTop := SpacePanel.LocalPosition.Y;
  (GetByName('MapPanel') as TGraphBufGI).BindExternalGraphBuf(RenderScratchBuffer);
  BattleMusicSelected := False;
  EndTurnAfterOpen := False;
end;
{ @end $7A605C }

{ @routine $7A7778 TfStarMap_OnOpen }
procedure TfStarMap.OnOpen;
var
  Entry: PEFilmEndEntry;
  MapIndex: Integer;
  StartText, WinText, LossText, TerronName: WideString;
  BattleFailed: Boolean;
begin
  if (GetPlayer <> nil) and (Byte(GetPlayer.RuinsMode) > 0) then GetPlayer.ExitRuinsMode;
  if DispatchPendingScriptRequests then Exit;
  EvictMainMenuShipCachesWhenAddressSpaceHigh;
  if not ShipScreen.FlagD4 then Galaxy.CheckIntegrityChecksum(1116)
  else Galaxy.ClearIntegrityStatus;
  LoadPanel.OnOpen;
  BreakOnNextFilm := False;
  AnimateSpacePanelOnResume := False;
  if PlanetBattleState = 1 then
  begin
    MapIndex := FindRobotMapById(PlanetBattleMapId);
    StartText := RobotMapDefinitions[MapIndex].RobotsStart;
    ReplaceTextToken(StartText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
    ReplaceTextToken(StartText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
    ExpandLocalizedTextMarkupAndPrefixLines(StartText);
    StartText := WideString(IntToStr(1)) + StartText;
    StartText := WideString(IntToStr(Min(Integer(Galaxy.GetDifficultyTierIndex) and $7F, 3) + 1)) + StartText;
    StartText := WideString(IntToStr(6)) + StartText;
    WinText := RobotMapDefinitions[MapIndex].RobotsWin;
    ReplaceTextToken(WinText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
    ReplaceTextToken(WinText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
    ExpandLocalizedTextMarkupAndPrefixLines(WinText);
    LossText := RobotMapDefinitions[MapIndex].RobotsLoss;
    ReplaceTextToken(LossText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
    ReplaceTextToken(LossText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
    ExpandLocalizedTextMarkupAndPrefixLines(LossText);
    if TerronShip <> nil then TerronName := TerronShip.GetFullName(' ');
    if IsTurnCalculationRunning and (WaitForSingleObject(ScriptUiRequestEvent, 0) <> WAIT_OBJECT_0) then WaitForTurnCalculation;
    if not MemorySnapshotActive then SaveGameToMemorySnapshot;
    LoadPanel.OnOpen;
    LoadPanel.SelectBackgroundStyle(3);
    LoadPanel.RefreshBackgroundImages;
    try
      BattleFailed := False;
      PlanetBattleState := FRun(RobotMapDefinitions[MapIndex].Map, StartText, WinText, LossText, TerronName);
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        BattleFailed := True;
      end;
    end;
    if MemorySnapshotActive then RestoreGameFromMemorySnapshot;
    if BattleFailed then
    begin
      if ShowMessageBoxGI(Self, LocalizedColorText('FormGov.BattlePlanetQuestCrashed'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
        PlanetBattleState := 3
      else raise Exception.Create('Error in Matrix.dll');
    end;
    if PlanetBattleState <> 0 then
    begin
      if PlanetBattleState = 1 then
      begin
        PlanetBattleState := 0;
        if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
        MemorySnapshotBuffer := nil;
        MemorySnapshotActive := False;
        if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
        Galaxy := nil;
        ScreenLoadMode := 4;
        PostLoadScreenId := screenMainMenu;
        RequestedScreenId := screenLoad;
        ReleaseAllTextureSurfaces;
        RequestClose(1);
      end
      else
      begin
        RequestedScreenId := screenStarMap;
        RequestClose(1);
      end;
    end;
  end
  else if PlanetBattleState in [2, 4] then
  begin
    SetLength(GetPlayer.PlanetBattleHistory, High(GetPlayer.PlanetBattleHistory) + 1 + 1);
    with GetPlayer.PlanetBattleHistory[High(GetPlayer.PlanetBattleHistory)] do
    begin
      MapId := PlanetBattleMapId;
      Statistics[0] := RobotBattleStatistics[0];
      Statistics[1] := RobotBattleStatistics[1];
      Statistics[2] := RobotBattleStatistics[2];
      Statistics[3] := RobotBattleStatistics[3];
      Statistics[4] := RobotBattleStatistics[4];
      Statistics[5] := RobotBattleStatistics[5];
      ResultCode := 1;
      CompletionMode := PlanetBattleState;
      DateTurn := Galaxy.CurrentTurn;
    end;
    Galaxy.TerronLandingLockTurn := 0;
    PlanetBattleState := 0;
    GetPlayer.OrderTakeoff;
    FilmCameraFollow := True;
    PlayerStar.RefreshSpaceObjectPositions;
    if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(3) then Galaxy.EnableDominatorSurfaces
    else Galaxy.DisableDominatorSurfaces;
    CalculatePlayerStarTurnAndWait;
    if ExitScreenLoop then Exit;
    if GetPlayer <> nil then CalculateGalaxyTurnAndWait;
    if GetPlayer = nil then
    begin
      RequestedScreenId := screenGameEnd;
      RequestClose(1);
      Exit;
    end;
    LoadPanel.OnOpen;
    LoadPanel.SelectBackgroundStyle(0);
    LoadPanel.RefreshBackgroundImages;
    StarMapScreen.ResumeMode := smrTurnFilm;
    ScreenLoadMode := 2;
    PostLoadScreenId := screenStarMap;
    RequestedScreenId := screenLoad;
    ReleaseAllTextureSurfaces;
    RequestClose(1);
  end
  else if PlanetBattleState = 3 then
  begin
    SetLength(GetPlayer.PlanetBattleHistory, High(GetPlayer.PlanetBattleHistory) + 1 + 1);
    with GetPlayer.PlanetBattleHistory[High(GetPlayer.PlanetBattleHistory)] do
    begin
      MapId := PlanetBattleMapId;
      Statistics[0] := RobotBattleStatistics[0];
      Statistics[1] := RobotBattleStatistics[1];
      Statistics[2] := RobotBattleStatistics[2];
      Statistics[3] := RobotBattleStatistics[3];
      Statistics[4] := RobotBattleStatistics[4];
      Statistics[5] := RobotBattleStatistics[5];
      ResultCode := 1;
      CompletionMode := PlanetBattleState;
      DateTurn := Galaxy.CurrentTurn;
    end;
    Inc(GetPlayer.PlanetBattles);
    PlanetBattleState := 0;
    LoadRobotScreen.LoadCompletionData;
    LoadRobotScreen.RecordCompletion(PlanetBattleMapId, -RobotBattleStatistics[0] div 1000, 2);
    LoadRobotScreen.SaveCompletionData;
    TryAddAchievementProgress('IRONMAN', 1);
    if TerronShip <> nil then TerronShip.DestroyQueued := True;
    GetPlayer.OrderTakeoff;
    FilmCameraFollow := True;
    PlayerStar.RefreshSpaceObjectPositions;
    if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(3) then Galaxy.EnableDominatorSurfaces
    else Galaxy.DisableDominatorSurfaces;
    CalculatePlayerStarTurnAndWait;
    if ExitScreenLoop then Exit;
    if GetPlayer <> nil then CalculateGalaxyTurnAndWait;
    if GetPlayer = nil then
    begin
      RequestedScreenId := screenGameEnd;
      RequestClose(1);
      Exit;
    end;
    LoadPanel.OnOpen;
    LoadPanel.SelectBackgroundStyle(0);
    LoadPanel.RefreshBackgroundImages;
    StarMapScreen.ResumeMode := smrTurnFilm;
    ScreenLoadMode := 2;
    PostLoadScreenId := screenStarMap;
    RequestedScreenId := screenLoad;
    ReleaseAllTextureSurfaces;
    RequestClose(1);
  end
  else
  begin
    PlanetBattleState := 0;
    if not ShipScreen.FlagD4 then GetPlayer.CancelInvalidTravelOrder;
    ClearMapAnimations;
    GetByName('FPS').SetActive(ShowFrameRate);
    RefreshScoreModsLabel;
    SetMapCenter(TruncatePointF(SpaceViewPosition));
    MainPanel.OnOpen;
    MainPanel.Hide;
    GetByName('PanelSpace').SetActive(False);
    UpdateRectsEnabled := True;
    MapControls.Invalidate;
    UpdateRectsEnabled := False;
    PlayerStar.OpenSpaceScene(MapControls, GetByName('MapPanel'), Self);
    if ResumeMode <> smrTurnFilm then PlayerStar.RefreshSpaceObjectPositions;
    BuildSpaceBackground(GetByName('StarField') as TStarFieldGI, GetByName('SpaceImg') as TSpaceImgGI,
      PlayerStar.GenerationSeed, PlayerStar.BackgroundImage);
    MapScrollTimer := ScheduleCallbackTimer(ScrollTime, ScrollTime, ScrollMap);
    with GetByName('StarFieldImg') as TStarFieldImgGI do
    begin
      SetActive(Wind >= 2);
      if StarCount <= 0 then SeedStars;
    end;
    FindControlByPath('StarFieldM').SetActive(Wind >= 1);
    if ResumeMode = smrTurnFilm then
    begin
      SelectMusic;
      RebuildPartnerButtons;
      StartTurnFilm;
    end
    else if ResumeMode = smrWaitForTurn then
    begin
      if not MusicInSpaceEnabled then MusicManager.RequestFadeOut;
      WaitForTurnOrTalk;
    end
    else
    begin
      if not MusicInSpaceEnabled then MusicManager.RequestFadeOut;
      StartOrderMode;
    end;
    ResumeMode := smrNormal;
    GetByName('MapPanelA').SetActive((GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(1));
    if ShipScreen.FlagD4 then
    begin
      SetCursorActive(False);
      MainPanel.RefreshMoneyAndCargo;
      FullFrameRedrawRequested := True;
      DrawFrame;
      CaptureScreenBackground(True, 0);
      ShipReturnScreenId := FormToId(Self);
      RequestedScreenId := screenShip;
      RequestClose(1);
      HideLargeHelp;
      Galaxy.ClearIntegrityStatus;
    end
    else
    begin
      if TrailingFilmEffects <> nil then
      begin
        Entry := TrailingFilmEffects.FirstEntry;
        while Entry <> nil do
        begin
          Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
          if Entry.RelatedObject1 <> nil then Entry.RelatedObject1.AttachToSpace(SpaceProcess.Space);
          Entry := Entry.Next;
        end;
      end;
      RestorePendingSceneObjects;
      SetCursorActive(True);
      ShipToInspect := nil;
      HideLargeHelp;
      PlayerStar.RefreshMovementStepParameters;
      if GetPlayer <> nil then GetPlayer.ScriptItemsAct($18, nil, nil, 0);
      Galaxy.PrimeIntegrityChecksum(1117);
      if EndTurnAfterOpen then
      begin
        EndTurnAfterOpen := False;
        ShipScreen.FlagD4 := False;
        EndTurnClicked(nil);
      end;
    end;
  end;
end;
{ @end $7A7778 }

{ @routine $7A86C8 TfStarMap_OnClose }
procedure TfStarMap.OnClose;
var
  Stage: Integer;
begin
  Stage := 0;
  try
    if (Galaxy <> nil) and (Mode = smmOrders) then Galaxy.CheckIntegrityChecksum(2);
    Stage := 1;
    if DeferredEndTurnTimer <> nil then
    begin
      CancelCallbackTimer(DeferredEndTurnTimer);
      DeferredEndTurnTimer := nil;
    end;
    if PlayerPathTimer <> nil then
    begin
      CancelCallbackTimer(PlayerPathTimer);
      PlayerPathTimer := nil;
    end;
    Stage := 2;
    if LargeHelpTimer <> nil then
    begin
      CancelCallbackTimer(LargeHelpTimer);
      LargeHelpTimer := nil;
    end;
    Stage := 3;
    if TerronFadeImage <> nil then
    begin
      TerronFadeImage.Free;
      TerronFadeImage := nil;
    end;
    Stage := 4;
    ClearPartnerButtons;
    Stage := 5;
    if (Galaxy <> nil) and not MemorySnapshotActive then SaveSpaceBackground;
    Stage := 6;
    if MapScrollTimer <> nil then
    begin
      CancelCallbackTimer(MapScrollTimer);
      MapScrollTimer := nil;
    end;
    Stage := 7;
    if TrailingFilmEffects <> nil then
    begin
      TrailingFilmEffects.Free;
      TrailingFilmEffects := nil;
    end;
    Stage := 8;
    if SecondaryFilm <> nil then SecondaryFilm.ReleaseWeaponSceneObjects;
    Stage := 9;
    (GetByName('InfoStarPanel') as TPanelGI).FreeOwnedChildren;
    Stage := 10;
    MainPanel.OnClose;
    Stage := 11;
    LoadPanel.OnClose;
    Stage := 12;
    if Galaxy <> nil then
    begin
      if Mode = smmOrders then StopOrderMode
      else if Mode = smmTurnFilm then StopTurnFilm(True);
    end;
    Stage := 13;
    if Galaxy <> nil then SpaceProcess.CloseSpace;
    Stage := 14;
    if CacheLoader.IsRunning then CacheLoader.WaitForIdle($FFFFFFFF);
    Stage := 15;
    WaitForTurnCalculation;
    Stage := 16;
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct($19, nil, nil, 0);
    CacheLoadLoggingEnabled := False;
    Galaxy.ClearIntegrityStatus;
    Stage := 17;
    if AuxRenderBuffer <> nil then AuxRenderBuffer.Clear;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('TfStarMap.AfterRun, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $7A86C8 }

{ @routine $7A8AE8 TfStarMap_RestorePendingSceneObjects }
procedure TfStarMap.RestorePendingSceneObjects;
var
  Entry: PEFilmEndEntry;
  Index: Integer;
begin
  if PendingSceneObjects.Count > 0 then
  begin
    if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
    for Index := 0 to PendingSceneObjects.Count - 1 do
    begin
      Entry := TrailingFilmEffects.AppendEntry;
      RetainSpaceObject(Entry.SceneObject, PendingSceneObjects[Index]);
      RetainSpaceObject(Entry.RelatedObject1, nil);
      Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
    end;
    PendingSceneObjects.Clear;
  end;
  if PendingHoleRefresh <> nil then
  begin
    for Index := 0 to Galaxy.Holes.Count - 1 do
      if Galaxy.Holes[Index] = PendingHoleRefresh then
      begin
        with PendingHoleRefresh do
        if (GetPlayer.CurrentStar = Star1) or (GetPlayer.CurrentStar = Star2) then
        begin
          if GetPlayer.CurrentStar = Star1 then Graphic.SetPosition(Position1)
          else Graphic.SetPosition(Position2);
          Graphic.DetachFromSpace;
          THoleSE(Graphic).SetState(1);
          Graphic.AttachToSpace(SpaceProcess.Space);
        end;
        Break;
      end;
    PendingHoleRefresh := nil;
  end;
end;
{ @end $7A8AE8 }

{ @routine $7A8CA4 TfStarMap_BuildSpaceBackground }
procedure TfStarMap.BuildSpaceBackground(StarField: TStarFieldGI; SpaceImage: TSpaceImgGI; Seed: Cardinal; BackgroundIndex: Integer);
var
  Radius, Diameter, X, Y, Index, Attempts: Integer;
  Depth: Single;
  Scale: Double;
  Count: Integer;
  Image: PSpaceImageGI;
  Kind: Integer;
  Text: WideString;
  Colors: array[0..15] of Cardinal;
begin
  Seed := StepRandomSeed(Seed);
  Radius := Round(PlayerStar.ComputeMapDiameter div 2);
  Diameter := PlayerStar.ComputeMapDiameter;
  Scale := RemapClamped(Radius, 2500.0, 4500.0, 1.0, 2.0);
  Count := Round(Scale * 2000.0);
  for Index := 0 to 3 do Colors[Index] := CurrentPixelFormat.PackRgbBytes(100 + 16 * Index, 100 + 16 * Index, 100 + 16 * Index);
  for Index := 0 to 3 do Colors[Index + 4] := CurrentPixelFormat.PackRgbBytes(100 + 40 * Index, 1, 1);
  for Index := 0 to 3 do Colors[Index + 8] := CurrentPixelFormat.PackRgbBytes(1, 100 + 40 * Index, 1);
  for Index := 0 to 3 do Colors[Index + 12] := CurrentPixelFormat.PackRgbBytes(1, 1, 100 + 40 * Index);
  StarField.Stars.Clear;
  for Index := 0 to Round(Count * 0.6) do
  begin
    X := SeededRandomIntRange(-Radius * 5, Radius * 5, Seed);
    Seed := StepRandomSeed(Seed);
    Y := SeededRandomIntRange(-Radius * 5, Radius * 5, Seed);
    Seed := StepRandomSeed(Seed);
    Depth := SeededRandomIntRange(2, 8, Seed);
    Seed := StepRandomSeed(Seed);
    StarField.Stars.AddPoint(X, Y, Depth, Colors[RandomIntRange(4, 15)]);
  end;
  for Index := 0 to Round(Count * 0.3) do
  begin
    X := SeededRandomIntRange(-Diameter, Diameter, Seed);
    Seed := StepRandomSeed(Seed);
    Y := SeededRandomIntRange(-Diameter, Diameter, Seed);
    Seed := StepRandomSeed(Seed);
    Depth := SeededRandomIntRange(1, 100, Seed) / 100.0 + 1.0;
    Seed := StepRandomSeed(Seed);
    StarField.Stars.AddPoint(X, Y, Depth, Colors[RandomIntRange(4, 15)]);
  end;
  for Index := 0 to Round(Count * 0.1) do
  begin
    X := SeededRandomIntRange(-Radius, Radius, Seed);
    Seed := StepRandomSeed(Seed);
    Y := SeededRandomIntRange(-Radius, Radius, Seed);
    Seed := StepRandomSeed(Seed);
    Depth := 1.1;
    StarField.Stars.AddPoint(X, Y, Depth, Colors[RandomIntRange(4, 15)]);
  end;
  StarField.MarkViewDirty;
  StarField.Invalidate;
  System.RandSeed := PlayerStar.GenerationSeed;
  Count := Round(RemapClamped(Scale, 1.0, 2.0, 1.0, 2.0));
  if (GlobalsV.SpaceImage = 1) and (Count > 1) then Count := 1;
  if BackgroundIndex < 10 then Text := GameDataConfig.GetBlockByPath('StyleNebula').GetParam(WideString('0' + IntToStr(BackgroundIndex)))
  else Text := GameDataConfig.GetBlockByPath('StyleNebula').GetParam(WideString(IntToStr(BackgroundIndex)));
  Index := SeededRandomIntRange(0, CountDelimitedPartsW(Text, ',') - 1, Seed);
  Seed := StepRandomSeed(Seed);
  Kind := ExtractDigitsToIntW(ExtractDelimitedPartW(Text, Index, ','));
  SpaceImage.ClearImages;
  if GlobalsV.SpaceImage > 0 then
  begin
    for Index := 1 to Count do
    begin
      Attempts := 0;
      repeat
        X := SeededRandomIntRange(-Diameter, Diameter, Seed);
        Seed := StepRandomSeed(Seed);
        Y := SeededRandomIntRange(-Diameter, Diameter, Seed);
        Seed := StepRandomSeed(Seed);
        Depth := RandomFloatRange(5.5, 6.0) * 1.1 + RemapClamped(Radius, 2500.0, 4000.0, 0.0, 3.0);
        Seed := StepRandomSeed(Seed);
        Inc(Attempts);
      until (SpaceImage.NearestImageDistance(X, Y) > RemapClamped(Radius, 2500.0, 4000.0, 3000.0, 6000.0)) or (Attempts > 100);
      if Attempts > 100 then Break;
      SpaceImage.AddImage(SelectSpaceImageTemplate(Kind), X, Y, Depth);
      Seed := StepRandomSeed(Seed);
    end;
    if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(2) then
    begin
      Attempts := 0;
      repeat
        X := SeededRandomIntRange(-Radius div 2, Radius div 2, Seed);
        Seed := StepRandomSeed(Seed);
        Y := SeededRandomIntRange(-Radius div 2, Radius div 2, Seed);
        Seed := StepRandomSeed(Seed);
        Depth := RandomFloatRange(2.5, 3.0) * 1.1 + RemapClamped(Radius, 2500.0, 4000.0, 0.0, 3.0);
        if Galaxy.SpaceEffectKind = 1 then
        begin
          X := -Abs(X);
          Y := Abs(X);
          Depth := 1.5;
        end;
        Seed := StepRandomSeed(Seed);
        Inc(Attempts);
      until (SpaceImage.NearestImageDistance(X, Y) > RemapClamped(Radius, 1500.0, 2000.0, 1500.0, 3000.0)) or (Attempts > 100);
      SpaceImage.AddImage(SelectSpaceImageTemplate(Galaxy.SpaceEffectKind + 10), X, Y, Depth);
    end;
    if High(Galaxy.SpaceBackgroundEntries) + 1 <= 0 then Galaxy.GenerateSpaceBackground(BackgroundIndex);
    for Index := 0 to High(Galaxy.SpaceBackgroundEntries) do
    begin
      Image := SpaceImage.AddImage(Galaxy.SpaceBackgroundEntries[Index].ImageIndex,
        Galaxy.SpaceBackgroundEntries[Index].Position.X, Galaxy.SpaceBackgroundEntries[Index].Position.Y, Galaxy.SpaceBackgroundEntries[Index].Position.Z);
      Image.OrbitCenter := Galaxy.SpaceBackgroundEntries[Index].OrbitCenter;
      Image.OrbitStepDegrees := Galaxy.SpaceBackgroundEntries[Index].OrbitStepDegrees;
      Image.Unknown70 := Galaxy.SpaceBackgroundEntries[Index].ImageIndex;
      Image.FrameIndex := Galaxy.SpaceBackgroundEntries[Index].FrameIndex;
      SpaceImage.UpdateImageOrbitAndFrame(Image);
    end;
    SpaceImage.AnimateImages(nil, 0);
    SpaceImage.ProjectImages;
    SpaceImage.Invalidate;
  end;
  if BackgroundIndex < 10 then StarField.SetBackgroundImage(WideString('Bm.BGO.bg0' + IntToStr(BackgroundIndex)))
  else StarField.SetBackgroundImage(WideString('Bm.BGO.bg' + IntToStr(BackgroundIndex)));
  StarField.BackgroundScale := Diameter * 3 / 2000.0;
end;
{ @end $7A8CA4 }

{ @routine $7A9898 TfStarMap_SaveSpaceImageState }
procedure TfStarMap.SaveSpaceImageState(SpaceImage: TSpaceImgGI);
var
  Index, SavedCount: Integer;
  Image: PSpaceImageGI;
begin
  SetLength(Galaxy.SpaceBackgroundEntries, SpaceImage.ImageCount);
  SavedCount := 0;
  for Index := 0 to SpaceImage.ImageCount - 1 do
  begin
    Image := SpaceImage.GetImage(Index);
    if Image.TemplateIndex >= 100 then
    begin
      Galaxy.SpaceBackgroundEntries[SavedCount].ImageIndex := Image.Unknown70;
      Galaxy.SpaceBackgroundEntries[SavedCount].OrbitCenter := Image.OrbitCenter;
      Galaxy.SpaceBackgroundEntries[SavedCount].Position := MakeVector3D(Image.X, Image.Y, Image.Depth);
      Galaxy.SpaceBackgroundEntries[SavedCount].Unknown38 := Image.Unknown38;
      Galaxy.SpaceBackgroundEntries[SavedCount].OrbitStepDegrees := Image.OrbitStepDegrees;
      Galaxy.SpaceBackgroundEntries[SavedCount].FrameIndex := Image.FrameIndex;
      Inc(SavedCount);
    end;
  end;
  SetLength(Galaxy.SpaceBackgroundEntries, SavedCount);
end;
{ @end $7A9898 }

{ @routine $7A9A54 TfStarMap_SaveSpaceBackground }
procedure TfStarMap.SaveSpaceBackground;
begin
  SaveSpaceImageState(GetByName('SpaceImg') as TSpaceImgGI);
end;
{ @end $7A9A54 }

{ @routine $7A9A98 TfStarMap_DeferredEndTurn }
procedure TfStarMap.DeferredEndTurn(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if DeferredEndTurnTimer <> nil then
  begin
    CancelCallbackTimer(DeferredEndTurnTimer);
    DeferredEndTurnTimer := nil;
  end;
  EndTurnClicked(nil);
end;
{ @end $7A9A98 }

{ @routine $7A9AE0 TfStarMap_EndTurnClicked }
procedure TfStarMap.EndTurnClicked(Sender: TObjectGI);
var
  WaitResult: Cardinal;
  Events: array[0..1] of THandle;
  EventList: Pointer;
begin
  if not MainPanel.NavigationLocked and not ShipScreen.FlagD4 then
  begin
    if TrailingFilmEffects <> nil then TrailingFilmEffects.RemoveLinkedWeaponEffects;
    Galaxy.CheckIntegrityChecksum(3);
    if not IsTurnCalculationRunningUI and (TurnCalculationPhase <> tcpGalaxyRunning) and (TurnCalculationPhase <> tcpPlayerStarRunning) then
    begin
      if GetPlayer.CalculateSpeed = 0 then GetPlayer.OrderNone(False);
      if PendingPlayerFollowTarget <> nil then GetPlayer.ProcessPendingPlayerFollowTargeting;
      PreviousFilmActivity := 0;
      MainPanel.TryAutoTurnSave;
      SoundManager.PlaySound('Sound.Turn');
      PruneExpiredPersistentPlayerMessages;
      ClearPathOverlay(True);
      ClearPathOverlay(False);
      StopOrderMode;
      BreakOnNextFilm := IsVirtualKeyDown(VK_SHIFT);
      PlayerAutomaticControl := False;
      FilmCameraFollow := ViewFollowShip;
      if not PlayerStarDayPrepared then AppendLogLineThreadSafe('Not calc NextDay header');
      GetPlayer.NextDay;
      QueuePlayerStarTurnCalculation;
      Events[0] := TurnCalculationThread.IdleEvent;
      Events[1] := TalkRequestEvent;
      EventList := @Events;
      WaitResult := WaitForMultipleObjects(Length(Events), EventList, False, INFINITE);
      if (TurnCalculationThread.IdleEvent = 0) or (WaitResult = WAIT_OBJECT_0) then
      begin
        RebuildPartnerButtons;
        if (GetPlayer <> nil) and not GetPlayer.InHyperspace then QueueGalaxyTurnCalculation;
        StartTurnFilm;
      end
      else if WaitResult = WAIT_FAILED then
        raise Exception.Create('Error GetLastError()=' + IntToStr(Int64(GetLastError)))
      else if WaitResult = WAIT_OBJECT_0 + 1 then
      begin
        ScriptDialogIndex := -1;
        RunTalkDialogs;
        WaitForTurnOrTalk;
      end;
      (GetByName('PM_Break') as TGraphButtonGI).SetHovered(False);
      PostMouseMoveMessage;
    end;
  end;
end;
{ @end $7A9AE0 }

{ @routine $7A9DCC TfStarMap_MapKeyDown }
procedure TfStarMap.MapKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if MainPanel.NavigationLocked or ShipScreen.FlagD4 then Exit;
  if IsVirtualKeyDown(VK_CONTROL) and (Key = VK_ADD) then
  begin
    MusicManager.RequestFadeOut;
    SelectMusic;
    Exit;
  end;
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_MENU) then
  begin
    if (Mode = smmOrders) and not IsTurnCalculationRunningUI then
    begin
      if Key = VK_F2 then
      begin
        if Galaxy.IronWill then
        begin
          ShowMessageBoxGI(Self, LocalizedColorText('FormGameSet2.IronWillText'), mbgCancel or mbgUnused04);
          FullFrameRedrawRequested := True;
          DrawFrame;
          Exit;
        end;
        if Galaxy.SpecialSimulationMode <> 0 then Exit;
        CaptureSavePreview;
        Galaxy.CheckIntegrityChecksum(91);
        CaptureGalaxyPreview(Self);
        Galaxy.PrimeIntegrityChecksum(92);
        ResumeMode := smrOrders;
        SaveManagerReturnScreenId := FormToId(Self);
        SaveManagerMode := smmSave;
        RequestedScreenId := screenSaveManager;
        RequestClose(1);
      end
      else if Key = VK_F3 then
      begin
        ResumeMode := smrOrders;
        SaveManagerReturnScreenId := FormToId(Self);
        SaveManagerMode := smmLoad;
        RequestedScreenId := screenSaveManager;
        RequestClose(1);
      end
      else if Key = VK_F5 then
      begin
        if Galaxy.SpecialSimulationMode <> 0 then Exit;
        MainPanel.QuickSave;
      end
      else if Key = VK_F6 then MainPanel.QuickLoad(3)
      else if Key = VK_F7 then MainPanel.QuickLoad(2)
      else if Key = VK_F8 then MainPanel.QuickLoad(1)
      else if Key = VK_NUMPAD0 then
      begin
        Galaxy.CheckIntegrityChecksum(55);
        GetPlayer.TogglePickupTargets(False);
        Galaxy.PrimeIntegrityChecksum(56);
        RebuildTargetMarkers;
      end
      else if Key = VK_DECIMAL then
      begin
        Galaxy.CheckIntegrityChecksum(55);
        GetPlayer.TogglePickupTargets(True);
        Galaxy.PrimeIntegrityChecksum(56);
        RebuildTargetMarkers;
      end
      else if Key = VK_INSERT then
      begin
        if Galaxy.SpecialSimulationMode <> 0 then Exit;
        SaveVisiblePriceSnapshots;
      end
      else if Key = VK_F11 then
      begin
        if not MainPanel.RemoveDismissibleMessages('GOODS') then MainPanel.RemoveDismissibleMessages('');
      end
      else if Key = VK_F1 then MainPanel.JournalClicked(nil);
    end;
    if Key = VK_LEFT then
    begin
      ScrollLeftHeld := True;
      if Mode = smmOrders then ShowObjectInfo(nil);
    end
    else if Key = VK_RIGHT then
    begin
      ScrollRightHeld := True;
      if Mode = smmOrders then ShowObjectInfo(nil);
    end
    else if Key = VK_UP then
    begin
      ScrollUpHeld := True;
      if Mode = smmOrders then ShowObjectInfo(nil);
    end
    else if Key = VK_DOWN then
    begin
      ScrollDownHeld := True;
      if Mode = smmOrders then ShowObjectInfo(nil);
    end
    else if Key = Ord('C') then
    begin
      if Mode = smmOrders then CenterShipClicked(nil)
      else CenterFilmShipClicked(nil);
    end
    else if Key = Ord('X') then
    begin
      if Mode = smmOrders then CenterOnDominator(1);
    end
    else if Key = Ord('Z') then
    begin
      if Mode = smmOrders then CenterOnDominator(2);
    end
    else if (Mode = smmOrders) and (Key = VK_SPACE) then
    begin
      if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
    end
    else if (Mode = smmTurnFilm) and (Key = VK_SPACE) then
    begin
      if not (GetByName('PM_Break') as TGraphButtonGI).Disabled then BreakTurnClicked(nil);
    end;
  end;
end;
{ @end $7A9DCC }

{ @routine $7AA348 TfStarMap_MapKeyUp }
procedure TfStarMap.MapKeyUp(Sender: TObjectGI; Key: Cardinal);
begin
  if Mode = smmOrders then DisplayedObject := nil;
  if Key = VK_LEFT then
  begin
    ScrollLeftHeld := False;
    ShowObjectInfo(FindObjectAtCursor);
  end
  else if Key = VK_RIGHT then
  begin
    ScrollRightHeld := False;
    ShowObjectInfo(FindObjectAtCursor);
  end
  else if Key = VK_UP then
  begin
    ScrollUpHeld := False;
    ShowObjectInfo(FindObjectAtCursor);
  end
  else if Key = VK_DOWN then
  begin
    ScrollDownHeld := False;
    ShowObjectInfo(FindObjectAtCursor);
  end;
end;
{ @end $7AA348 }

{ @routine $7AA400 TfStarMap_OpenFilmHistoryClicked }
procedure TfStarMap.OpenFilmHistoryClicked(Sender: TObjectGI);
begin
  if (Mode = smmOrders) and not IsTurnCalculationRunningUI and (FilmHistory.GetCount > 0) then
  begin
    RequestedScreenId := screenFilm;
    RequestClose(1);
  end;
end;
{ @end $7AA400 }

{ @routine $7AA44C TfStarMap_RefreshScoreModsLabel }
procedure TfStarMap.RefreshScoreModsLabel;
var
  Text: WideString;
begin
  with GetByName('Mods') as TLabelGI do
  begin
    if Galaxy.HasVisibleScoreModFlags then
    begin
      Text := DecodeTextW(Galaxy.FinalizationNameEncoded);
      if (Length(Text) = 0) and GR_Main.CCInterface.GetEditableStateApplied then Text := LookupLocalizedTextByKey('Cheat.Warning')
      else if (Length(Text) > 0) and (Galaxy.GetCheatPoints <> 0) then Text := Text + ' + ' + LookupLocalizedTextByKey('Cheat.Warning');
      if (Galaxy.DominatorModLevel > 0) and (Length(Text) > 0) then Text := Text + ' + ';
      if Galaxy.DominatorModLevel = 1 then Text := Text + LookupLocalizedTextByKey('Cheat.Mod_DomikHorrible')
      else if Galaxy.DominatorModLevel = 2 then Text := Text + LookupLocalizedTextByKey('Cheat.Mod_DomikNightmare')
      else if Galaxy.DominatorModLevel = 3 then Text := Text + LookupLocalizedTextByKey('Cheat.Mod_DomikHellish');
      if Galaxy.TechnicModEnabled = 1 then
      begin
        if Length(Text) > 0 then Text := Text + ' + ';
        Text := Text + LookupLocalizedTextByKey('Cheat.Mod_Technic');
      end;
      if Galaxy.AmmoModEnabled = 1 then
      begin
        if Length(Text) > 0 then Text := Text + ' + ';
        Text := Text + LookupLocalizedTextByKey('Cheat.Mod_Ammo');
      end;
      if Galaxy.GodModEnabled = 1 then
      begin
        if Length(Text) > 0 then Text := Text + ' + ';
        Text := Text + LookupLocalizedTextByKey('Cheat.Mod_God');
      end;
      if Galaxy.UltraScanModEnabled = 1 then
      begin
        if Length(Text) > 0 then Text := Text + ' + ';
        Text := Text + LookupLocalizedTextByKey('Cheat.Mod_Ultrascan');
      end;
      if Galaxy.StasisModEnabled = 1 then
      begin
        if Length(Text) > 0 then Text := Text + ' + ';
        Text := Text + LookupLocalizedTextByKey('Cheat.Mod_Stasis');
      end;
      SetText(Text);
      SetActive(True);
    end
    else
    begin
      if Galaxy.GetCheatPoints <> 0 then
      begin
        SetText(LookupLocalizedTextByKey('Cheat.Warning'));
        SetActive(True);
      end
      else
      begin
        SetText('');
        SetActive(False);
      end;
    end;
  end;
end;
{ @end $7AA44C }

{ @routine $7AA930 TfStarMap_BuildShipPathOverlay }
procedure TfStarMap.BuildShipPathOverlay(Ship: TShip; DelayEndImage: Boolean; InitialImagePath: WideString);
var
  Point, TargetPosition: TPointF;
  ImageSize: TPoint;
  Cursor, Node, LastNode: PSPathNode;
  Owner: TObjectGI;
  EndImage: TgaiGI;
  TargetShip, OtherShip: TShip;
  Distance, Angle, AngleOffset, Radius, PathLength: Single;
  Index, Count, LandingTurns: Integer;
  LabelGI: TLabelGI;
  EndPosition: TPoint;
  PathImages: TMultiImageGI;
  UnitImage: TMultiImageUnitGI;
  Positions: PPointF;
  WritePosition: PSingle;
begin
  if (Ship = GetPlayer) and (PlayerPathTimer <> nil) then
  begin
    CancelCallbackTimer(PlayerPathTimer);
    PlayerPathTimer := nil;
  end;
  Owner := MapControls;
  LandingTurns := -1;
  if Ship = TerronShip then Exit;
  if (Ship.Order = soFollowShip) or ((Ship = GetPlayer) and (PendingPlayerFollowTarget <> nil)) then
  begin
    if (Ship = GetPlayer) and (PendingPlayerFollowTarget <> nil) then TargetShip := PendingPlayerFollowTarget
    else TargetShip := Ship.OrderTarget as TShip;
    if TargetShip.IsOnPlanet then TargetPosition := TargetShip.CurrentPlanet.GetPosition
    else TargetPosition := TargetShip.Position;
    Distance := PointDistance(Ship.Position, TargetShip.Position);
    AngleOffset := 0;
    Count := 0;
    while Count < 4 do
    begin
      Inc(Count);
      Radius := TargetShip.Graphic.Size.X / 2 + 20;
      if Distance < 1 then
      begin
        Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 259, Ship.Seed * TargetShip.Seed)) + AngleOffset;
        Point.X := TargetPosition.X + Sin(Angle) * Radius;
        Point.Y := TargetPosition.Y - Cos(Angle) * Radius;
      end
      else
      begin
        Angle := ArcTan2(Ship.Position.X - TargetPosition.X, -(Ship.Position.Y - TargetPosition.Y)) + AngleOffset;
        Point.X := TargetPosition.X + Sin(Angle) * Radius;
        Point.Y := TargetPosition.Y - Cos(Angle) * Radius;
      end;
      Index := 0;
      while Index < Ship.CurrentStar.Ships.Count do
      begin
        OtherShip := TShip(Ship.CurrentStar.Ships[Index]);
        if OtherShip.InNormalSpace and (PointDistanceSquared(Point, OtherShip.Position) < 900) then Break;
        Inc(Index);
      end;
      AngleOffset := AngleOffset + 1.5707963;
      if Index >= Ship.CurrentStar.Ships.Count then Break;
    end;
    Galaxy.CheckIntegrityChecksum(13);
    Ship.OrderDestination := Point;
    Ship.ClearMovementPath;
    Ship.BuildFullPathTo(Ship.OrderDestination);
    Galaxy.PrimeIntegrityChecksum(14);
  end
  else if Ship.Order = soLand then
  begin
    Galaxy.CheckIntegrityChecksum(15);
    Ship.ClearMovementPath;
    if (Ship = GetPlayer) and (Ship.OrderTarget is TPlanet) then
    begin
      Ship.BuildPlanetLandingPath;
      LandingTurns := Ship.GetMovementPathTurnCount;
      Ship.BuildFullPathTo(AddPointsF((Ship.OrderTarget as TPlanet).GetPosition, Ship.OrderDestination));
    end
    else
    begin
      if Ship.OrderTarget is TShip then
        Ship.BuildFullPathTo(AddPointsF((Ship.OrderTarget as TShip).Position, Ship.OrderDestination))
      else Ship.BuildFullPathTo(AddPointsF((Ship.OrderTarget as TPlanet).GetPosition, Ship.OrderDestination));
    end;
    Galaxy.PrimeIntegrityChecksum(16);
  end
  else if Ship.Order = soJumpHole then
  begin
    Galaxy.CheckIntegrityChecksum(17);
    Ship.ClearMovementPath;
    Ship.BuildFullPathTo(Ship.OrderDestination);
    Galaxy.PrimeIntegrityChecksum(18);
  end
  else if Ship.Order = soJump then
  begin
    Galaxy.CheckIntegrityChecksum(19);
    Ship.ClearMovementPath;
    Ship.BuildOrderMovementPath(999999);
    Galaxy.PrimeIntegrityChecksum(20);
  end
  else if (Ship <> GetPlayer) and (Ship.Order = soMove) then
  begin
    Galaxy.CheckIntegrityChecksum(21);
    Ship.ClearMovementPath;
    Ship.BuildFullPathTo(Ship.OrderDestination);
    Galaxy.PrimeIntegrityChecksum(22);
  end;
  if Ship.MovementPath.ActiveHead <> nil then
  begin
    if Ship = GetPlayer then PathImages := GetByName('PlayerPath') as TMultiImageGI
    else PathImages := GetByName('ShipPath') as TMultiImageGI;
    if PathImages.Images.Count < 1 then
    begin
      PathImages.AddImage('Bm.PI.Path1');
      PathImages.AddImage('Bm.PI.Path2');
      PathImages.AddImage('Bm.PI.Path3');
      PathImages.AddImage('Bm.PI.Path4');
    end;
    PathImages.ClearUnits;
    PathLength := 0;
    Node := Ship.MovementPath.ActiveHead;
    while Node <> nil do
    begin
      LastNode := Ship.MovementPath.GetFollowingNode(Node, 198);
      if LastNode = nil then LastNode := Ship.MovementPath.ActiveTail;
      Point := MakePointF(1e10, 1e10);
      Cursor := LastNode;
      while True do
      begin
        if PointDistanceSquared(Point, Cursor.Position) > 225 then
        begin
          if (Point.X <> 1e10) and (Ship = GetPlayer) then PathLength := PathLength + PointDistance(Point, Cursor.Position);
          Point := Cursor.Position;
          if Cursor <> Ship.MovementPath.ActiveTail then
          begin
            UnitImage := PathImages.AddUnit;
            PathImages.SetUnitPosition(UnitImage, TruncatePointF(Point));
            if Cursor <> LastNode then
            begin
              if Node = Ship.MovementPath.ActiveHead then UnitImage.ImageIndex := 0
              else UnitImage.ImageIndex := 1;
            end
            else
            begin
              // The native routine keeps both assignments, including this redundant test.
              if Node = Ship.MovementPath.ActiveHead then UnitImage.ImageIndex := 2
              else UnitImage.ImageIndex := 2;
            end;
          end;
        end;
        if Cursor = Node then Break;
        Cursor := Cursor.Prev;
      end;
      Node := LastNode.Next;
    end;
    if (Ship.Order = soLand) and not ((Ship = GetPlayer) and (PendingPlayerFollowTarget <> nil)) then
    begin
      if Ship.OrderTarget is TShip then EndPosition := TruncatePointF(AddPointsF((Ship.OrderTarget as TShip).Position, Ship.OrderDestination))
      else EndPosition := TruncatePointF(AddPointsF((Ship.OrderTarget as TPlanet).GetPosition, Ship.OrderDestination));
    end
    else EndPosition := TruncatePointF(Ship.OrderDestination);
    EndImage := TgaiGI.Create(Owner);
    if not DelayEndImage then
    begin
      if (PendingPlayerFollowTarget <> nil) and (Ship = GetPlayer) then EndImage.SetImagePath('Bm.PI.PathEndAutoBattle')
      else if Ship.Order = soFollowShip then
      begin
        if (Ship is TKling) and (Ship as TKling).ShouldKamikaze then EndImage.SetImagePath('Bm.PI.PathEndKamikaze')
        else if Ship.GetFollowMode = 3 then EndImage.SetImagePath('Bm.PI.PathEndKamikaze')
        else if Ship.GetFollowMode = 0 then EndImage.SetImagePath('Bm.PI.PathEndFollowNear')
        else if Ship.GetFollowMode = 1 then EndImage.SetImagePath('Bm.PI.PathEndFollowMin')
        else EndImage.SetImagePath('Bm.PI.PathEndFollowMax');
      end
      else if Ship.Order = soLand then EndImage.SetImagePath('Bm.PI.PathEndLanding')
      else if Ship.Order = soJumpHole then EndImage.SetImagePath('Bm.PI.PathEndJumpHole')
      else EndImage.SetImagePath('Bm.PI.PathEndMove');
    end
    else
    begin
      if (PendingPlayerFollowTarget <> nil) and (Ship = GetPlayer) then
      begin
        EndImage.SetImagePath(InitialImagePath);
        EndImage.HelpText := 'Bm.PI.PathEndAutoBattle';
        PlayerPathTimer := ScheduleCallbackTimer(GetDoubleClickTime + 50, 999, UpdatePathEndImage, Integer(EndImage));
      end
      else if Ship.Order = soFollowShip then
      begin
        if Ship.GetFollowMode = 0 then EndImage.HelpText := 'Bm.PI.PathEndFollowNear'
        else if Ship.GetFollowMode = 1 then EndImage.HelpText := 'Bm.PI.PathEndFollowMin'
        else EndImage.HelpText := 'Bm.PI.PathEndFollowMax';
        EndImage.SetImagePath(InitialImagePath);
        PlayerPathTimer := ScheduleCallbackTimer(GetDoubleClickTime + 50, 999, UpdatePathEndImage, Integer(EndImage));
      end
      else if Ship.Order = soLand then EndImage.SetImagePath('Bm.PI.PathEndLanding')
      else if Ship.Order = soJumpHole then EndImage.SetImagePath('Bm.PI.PathEndJumpHole')
      else EndImage.SetImagePath('Bm.PI.PathEndMove');
    end;
    EndImage.SequenceIndex := 0;
    EndImage.UpdateAutoGeometry;
    if Ship = GetPlayer then EndImage.SetDepth(UnitPathEndDepth)
    else EndImage.SetDepth(ShipPathEndDepth);
    EndImage.SetPosition(EndPosition);
    EndImage.SetPositionModeW(True);
    ImageSize := EndImage.GetContentSize;
    EndImage.SetOrigin(HalfPoint(ImageSize));
    EndImage.SetSize(ImageSize);
    EndImage.RestartPlayback;
    LabelGI := TLabelGI.Create(Owner);
    if Ship = GetPlayer then LabelGI.SetDepth(UnitPathEndDepth)
    else LabelGI.SetDepth(ShipPathEndDepth);
    LabelGI.SetFontName(NormalFontName);
    LabelGI.SetSize(Classes.Point(120, 20));
    LabelGI.SetTextAlignX(taxLeft);
    LabelGI.SetTextAlignY(tayCenterEx);
    if LandingTurns < 0 then
    begin
      if ViewPathLength and (Ship = GetPlayer) and (Ship.Order = soMove) then
        LabelGI.SetText(IntToStr(Ship.GetMovementPathTurnCount) + ' (' + IntToStr(Round(PathLength)) + ')')
      else LabelGI.SetText(IntToStr(Ship.GetMovementPathTurnCount));
    end
    else LabelGI.SetText(IntToStr(LandingTurns));
    LabelGI.SetPositionModeW(True);
    LabelGI.SetPosition(AddPoints(EndPosition, Classes.Point(20, -32)));
    if (Ship <> GetPlayer) or (GetPlayer = CursorObject) then
    begin
      Count := Ship.MovementPath.NodeCount;
      Positions := AllocEC(Count * SizeOf(TPointF));
      WritePosition := Pointer(Positions);
      Cursor := Ship.MovementPath.ActiveHead;
      while Cursor <> nil do
      begin
        WritePosition^ := Cursor.Position.X;
        WritePosition := Pointer(PAnsiChar(WritePosition) + SizeOf(Single));
        WritePosition^ := Cursor.Position.Y;
        WritePosition := Pointer(PAnsiChar(WritePosition) + SizeOf(Single));
        Cursor := Cursor.Next;
      end;
      SpaceProcess.Space.SetPath(Positions, Count);
      SpaceProcess.Space.DrawMinimap;
      FreeEC(Positions);
      MinimapPathKind := smpShip;
    end;
  end;
end;
{ @end $7AA930 }

{ @routine $7ABA14 TfStarMap_UpdatePathEndImage }
procedure TfStarMap.UpdatePathEndImage(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if PlayerPathTimer <> nil then
  begin
    CancelCallbackTimer(PlayerPathTimer);
    PlayerPathTimer := nil;
  end;
  TgaiGI(UserData).SetImagePath(TgaiGI(UserData).HelpText);
  TgaiGI(UserData).SequenceIndex := 0;
  TgaiGI(UserData).UpdateAutoGeometry;
  TgaiGI(UserData).SetPositionModeW(True);
  TgaiGI(UserData).SetOrigin(HalfPoint(TgaiGI(UserData).GetContentSize));
  TgaiGI(UserData).SetSize(TgaiGI(UserData).GetContentSize);
  TgaiGI(UserData).RestartPlayback;
end;
{ @end $7ABA14 }

{ @routine $7ABABC TfStarMap_ClearPathOverlay }
procedure TfStarMap.ClearPathOverlay(PlayerPath: Boolean);
var
  NextControl, Control: TObjectGI;
begin
  if PlayerPath and (PlayerPathTimer <> nil) then
  begin
    CancelCallbackTimer(PlayerPathTimer);
    PlayerPathTimer := nil;
  end;
  with MapControls do NextControl := FirstChild;
  while NextControl <> nil do
  begin
    Control := NextControl;
    NextControl := NextControl.NextSibling;
    if (PlayerPath and (Control.Depth = UnitPathEndDepth)) or
      (not PlayerPath and (Control.Depth = ShipPathEndDepth)) then
    begin
      Control.SetActive(False);
      Control.Free;
    end;
  end;
  if PlayerPath then
    with GetByName('PlayerPath') as TMultiImageGI do ClearUnits
  else
    with GetByName('ShipPath') as TMultiImageGI do ClearUnits;
  if MinimapPathKind = smpShip then
  begin
    SpaceProcess.Space.ClearPath;
    SpaceProcess.Space.DrawMinimap;
    MinimapPathKind := smpNone;
  end;
end;
{ @end $7ABABC }

{ @routine $7ABC28 TfStarMap_ShowAsteroidPath }
procedure TfStarMap.ShowAsteroidPath(Asteroid: TAsteroid);
var
  Count: Integer;
  Positions, Cursor: Pointer;
  X, Y, NextX, NextY: Single;
  I: Integer;
  Image: TImageGI;
begin
  if PathAsteroid = Asteroid then Exit;
  ClearAsteroidPath;
  PathAsteroid := Asteroid;
  Count := 800;
  Cursor := AllocEC(Count * SizeOf(TPointF));
  Positions := Cursor;
  Asteroid.WritePredictedPositions(Cursor, Count);
  X := ReadSingleEC(Cursor);
  Cursor := AddPointerOffset(Cursor, SizeOf(Single));
  Y := ReadSingleEC(Cursor);
  Cursor := AddPointerOffset(Cursor, SizeOf(Single));
  for I := 1 to Count - 1 do
  begin
    NextX := ReadSingleEC(Cursor);
    Cursor := AddPointerOffset(Cursor, SizeOf(Single));
    NextY := ReadSingleEC(Cursor);
    Cursor := AddPointerOffset(Cursor, SizeOf(Single));
    if Sqr(X - NextX) + Sqr(Y - NextY) > 144 then
    begin
      X := NextX;
      Y := NextY;
      Image := TImageGI.Create(MapControls);
      Image.SetDepth(UnitPathDepth);
      Image.SetPosition(Classes.Point(Round(NextX), Round(NextY)));
      Image.SetPositionModeW(True);
      if I < 200 then Image.SetImagePath('GI,Bm.PI.Path1')
      else Image.SetImagePath('GI,Bm.PI.Path2');
      Image.SetSize(Image.GetContentSize);
      Image.SetOrigin(HalfPoint(Image.ClientSize));
      Image.UserValue := 101;
    end;
  end;
  FreeEC(Positions);
  Count := 2400;
  Cursor := AllocEC(Count * SizeOf(TPointF));
  Asteroid.WritePredictedPositions(Cursor, Count);
  SpaceProcess.Space.SetPath(Cursor, Count);
  SpaceProcess.Space.DrawMinimap;
  FreeEC(Cursor);
  MinimapPathKind := smpAsteroid;
end;
{ @end $7ABC28 }

{ @routine $7ABEC8 TfStarMap_ClearAsteroidPath }
procedure TfStarMap.ClearAsteroidPath;
var
  NextControl, Control: TObjectGI;
begin
  if PathAsteroid <> nil then
  begin
    PathAsteroid := nil;
    if MinimapPathKind = smpAsteroid then
    begin
      SpaceProcess.Space.ClearPath;
      SpaceProcess.Space.DrawMinimap;
      MinimapPathKind := smpNone;
    end;
    NextControl := MapControls.FirstChild;
    while NextControl <> nil do
    begin
      Control := NextControl;
      NextControl := NextControl.NextSibling;
      if Control.UserValue = 101 then
      begin
        Control.SetActive(False);
        Control.Free;
      end;
    end;
  end;
end;
{ @end $7ABEC8 }

{ @routine $7ABF70 TfStarMap_ClearPartnerButtons }
procedure TfStarMap.ClearPartnerButtons;
begin
  PartnerPanel.Parent.SetActive(False);
  SecondaryPartnerPanel.FreeOwnedChildren;
end;
{ @end $7ABF70 }

{ @routine $7ABF9C TfStarMap_RebuildPartnerButtons }
procedure TfStarMap.RebuildPartnerButtons;
var
  StarIndex, ShipIndex, PlacedCount, PartnerCount: Integer;
  Star: TStar;
  Ship: TShip;
  Portrait: WideString;
begin
  ClearPartnerButtons;
  if GetPlayer <> nil then
  begin
    PlacedCount := 0;
    PartnerCount := 0;
    for StarIndex := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := TStar(Galaxy.Stars[StarIndex]);
      for ShipIndex := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[ShipIndex]);
        if Ship.PartnerShip = GetPlayer then Inc(PartnerCount);
      end;
    end;
    for StarIndex := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := TStar(Galaxy.Stars[StarIndex]);
      for ShipIndex := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[ShipIndex]);
        if Ship.PartnerShip = GetPlayer then
        begin
          with TGraphButtonGI.Create(SecondaryPartnerPanel) do
          begin
            SetKind(gbkDisable);
            Portrait := '';
            if (Ship.Graphic <> nil) and (Ship.Graphic is TShip2SE) and (TShip2SE(Ship.Graphic).PanelPartnerImage <> '') then
              Portrait := TShip2SE(Ship.Graphic).PanelPartnerImage
            else if (Ship.Graphic <> nil) and (Ship.Graphic is TRuinsSE) and (TRuinsSE(Ship.Graphic).PanelPartnerImage <> '') then
              Portrait := TRuinsSE(Ship.Graphic).PanelPartnerImage
            else if Ship.IsFemaleHumanPilot and (Ship.TypeId = stRanger) and (Ship.GetHull.HullType = htSpecial) and (Ship.GetHull.GetSpecialKindGraph = 'J') then
              Portrait := 'Female'
            else if (Ship.TypeId = stRanger) and Ship.UsesVeteranHumanRangerAppearance then
              Portrait := 'PeopleO'
            else if Ship is TPirate then
            begin
              Portrait := Portrait + 'P';
              if (Ship.OwnerId = Byte(oiPirate)) and (TPirate(Ship).PirateType <> 0) then
                Portrait := OwnerInfo[Integer(RaceToOwner(Ship.PilotRace)) and $7F].InternalName + Portrait + 'C'
              else Portrait := OwnerInfo[Integer(RaceToOwner(Ship.PilotRace)) and $7F].InternalName + Portrait;
            end
            else Portrait := OwnerInfo[Integer(RaceToOwner(Ship.PilotRace)) and $7F].InternalName;
            SetImageNormalPath('GI,Bm.PanelSpace2.' + GiResourceSuffix + Portrait + 'N');
            SetImageNormalActivePath('GI,Bm.PanelSpace2.' + GiResourceSuffix + Portrait + 'A');
            SetImageDownPath('GI,Bm.PanelSpace2.' + GiResourceSuffix + Portrait + 'D');
            SetImageDisabledPath('GI,Bm.PanelSpace2.' + GiResourceSuffix + Portrait + 'H');
            EnterSound := 'Sound.ButtonEnter';
            LeaveSound := 'Sound.ButtonLeave';
            ClickSound := 'Sound.ButtonClick';
            UserValue := Ship.Id;
            HitKind := gbhRect;
            SetSize(GetMaxStateImageSize);
            if PartnerCount <= 5 then
              SetPosition(Classes.Point(GiScalePixelsEx(23, 20) + PlacedCount * GiScalePixels(25) - ClientSize.X div 2,
                GiScalePixels(20) - ClientSize.Y div 2))
            else
              SetPosition(Classes.Point(GiScalePixelsEx(23, 20) + PlacedCount * GiScalePixels(21) - 5 - ClientSize.X div 2,
                GiScalePixels(20) - ClientSize.Y div 2));
            UpdateStateImagePlacement;
            UpdateStateVisuals;
            DownCallback := PartnerClicked;
            RightButtonDownCallback := PartnerRightButtonDown;
            MouseEnterCallback := PartnerMouseEnter;
            MouseLeaveCallback := PartnerMouseLeave;
            SetDisabled(Ship.InHyperspace or (Ship.CurrentStar <> GetPlayer.CurrentStar));
            HelpCallback := MainPanel.ShowControlHelp;
            HelpText := Ship.GetFullName(' ');
            Inc(PlacedCount);
            PartnerPanel.Parent.SetActive(PlacedCount > 0);
            PartnerPanel.SetSize(Classes.Point(Math.Min(GiScalePixelsEx(12, 10) + PlacedCount * GiScalePixels(25) + GiScalePixelsEx(22, 18),
              PartnerPanel.Parent.ClientSize.X - 10), PartnerPanel.ClientSize.Y));
            PartnerPanel.SetPosition(Classes.Point(PartnerPanel.Parent.ClientSize.X - PartnerPanel.ClientSize.X, 0));
            with GetByName('MapPartnerBG2') do SetPosition(Classes.Point(PartnerPanel.ClientSize.X - ClientSize.X, 0));
            with GetByName('MapPartnerDuty') do SetPosition(Classes.Point(PartnerPanel.LocalPosition.X - 5, LocalPosition.Y));
          end;
        end;
      end;
    end;
  end;
end;
{ @end $7ABF9C }

{ @routine $7AC890 TfStarMap_PartnerClicked }
procedure TfStarMap.PartnerClicked(Sender: TObjectGI);
var Ship: TShip; FilmObject: TEFilmObj; Instance: TObject;
begin
  if Mode = smmTurnFilm then
  begin
    FilmObject := SecondaryFilm.FindObjectById('Ship2', Sender.UserValue);
    if (FilmObject = nil) or (FilmObject.SceneObject = nil) then Exit;
    SetMapCenterManually(TruncatePointF(FilmObject.SceneObject.Position));
  end
  else
  begin
    Instance := Galaxy.IdToShip(Sender.UserValue, False);
    if Instance = nil then Exit;
    Ship := Instance as TShip;
    if (GetPlayer.CurrentStar <> Ship.CurrentStar) or Ship.InHyperspace then Exit;
    if Ship.InNormalSpace then SetMapCenterManually(TruncatePointF(Ship.Position))
    else if Ship.IsOnPlanet then SetMapCenterManually(TruncatePointF(Ship.CurrentPlanet.GetPosition))
    else if Ship.IsDockedToShip then SetMapCenterManually(TruncatePointF(Ship.DockedTo.Position))
    else Exit;
  end;
  AddMapAnimation(PointToPointF(GetMapCenter), 'Bm.SI.' + GiResourceSuffix + 'Ring', 0);
  AddMapAnimation(PointToPointF(GetMapCenter), 'Bm.SI.' + GiResourceSuffix + 'Ring', 200);
  AddMapAnimation(PointToPointF(GetMapCenter), 'Bm.SI.' + GiResourceSuffix + 'Ring', 400);
end;
{ @end $7AC890 }

{ @routine $7ACB3C TfStarMap_PartnerRightButtonDown }
procedure TfStarMap.PartnerRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Ship: TShip;
  Obj: TObject;
begin
  if Mode = smmOrders then
  begin
    Obj := Galaxy.IdToShip(Sender.UserValue, False);
    if Obj <> nil then
    begin
      Ship := Obj as TShip;
      if (GetPlayer.CurrentStar = Ship.CurrentStar) and Ship.InNormalSpace then
        if PointDistance(GetPlayer.Position, Ship.Position) <= GetPlayer.GetRadarRange then
        begin
          TalkShip := Ship;
          TalkScripted := False;
          ScriptDialogIndex := -1;
          Galaxy.CheckIntegrityChecksum(23);
          RunTalkDialogs;
          Galaxy.PrimeIntegrityChecksum(24);
          BreakUiMessage;
        end;
    end;
  end;
end;
{ @end $7ACB3C }

{ @routine $7ACC40 TfStarMap_PartnerMouseEnter }
procedure TfStarMap.PartnerMouseEnter(Sender: TObjectGI);
var
  Obj, Instance: TObject;
begin
  if Mode = smmOrders then
  begin
    Instance := Galaxy.IdToShip(Sender.UserValue, False);
    if Instance <> nil then
    begin
      Obj := Instance as TShip;
      ShowObjectInfo(Obj);
    end;
  end;
end;
{ @end $7ACC40 }

{ @routine $7ACC98 TfStarMap_PartnerMouseLeave }
procedure TfStarMap.PartnerMouseLeave(Sender: TObjectGI);
begin
  ShowObjectInfo(nil);
end;
{ @end $7ACC98 }

{ @routine $7ACCB4 TfStarMap_AddMapAnimation }
procedure TfStarMap.AddMapAnimation(Position: TPointF; ImagePath: WideString; DelayMs: Integer);
var
  Animation: TgaiGI;
begin
  Animation := TgaiGI.Create(MapControls);
  Animation.SetDepthByName('IAnim');
  Animation.SetPosition(TruncatePointF(Position));
  Animation.SetPositionModeW(True);
  Animation.SetImagePath(ImagePath);
  Animation.SetSize(Animation.GetContentSize);
  Animation.SetOrigin(HalfPoint(Animation.ClientSize));
  Animation.UserValue := 102;
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  if DelayMs >= 0 then Animation.SetFrameDelay(0, DelayMs);
  Animation.CycleCompleteCallback := MapAnimationFinished;
  Animation.RestartPlayback;
end;
{ @end $7ACCB4 }

{ @routine $7ACDE8 TfStarMap_ClearMapAnimations }
procedure TfStarMap.ClearMapAnimations;
var
  NextControl, Control: TObjectGI;
begin
  NextControl := MapControls.FirstChild;
  while NextControl <> nil do
  begin
    Control := NextControl;
    NextControl := NextControl.NextSibling;
    if Control.UserValue = 102 then
    begin
      Control.SetActive(False);
      Control.Free;
    end;
  end;
end;
{ @end $7ACDE8 }

{ @routine $7ACE40 TfStarMap_MapAnimationFinished }
procedure TfStarMap.MapAnimationFinished(Sender: TObjectGI);
begin
  Sender.SetActive(False);
  Sender.Free;
end;
{ @end $7ACE40 }

{ @routine $7ACE64 TfStarMap_FindObjectAtCursor }
function TfStarMap.FindObjectAtCursor: TObject;
var
  Index, Count: Integer;
  Ship: TShip;
  Item: TItem;
  Planet: TPlanet;
  Asteroid: TAsteroid;
  Point: TPoint;
  Hole: THole;
  Missile: TMissile;
begin
  if Mode <> smmOrders then
  begin
    Result := nil;
    Exit;
  end;
  HitObjectPosition := Classes.Point(0, 0);
  HitObjectSize := Classes.Point(0, 0);
  if MainPanel.BackgroundImage.HitTestPixel(GetCursorPoint) then
  begin
    Result := nil;
    Exit;
  end;
  Point := GetCursorPoint;
  if IsMapPointBlocked(MapControls, Point) then
  begin
    Result := nil;
    Exit;
  end;
  Point := MapControls.ToLocalPoint(GetCursorPoint);
  Count := PlayerStar.Missiles.Count;
  for Index := 0 to Count - 1 do
  begin
    Missile := TMissile(PlayerStar.Missiles[Index]);
    if (Missile <> nil) and (Missile.GetGraphObject <> nil) and Missile.GetGraphObject.HitTestCursor then
    begin
      HitObjectPosition := Classes.Point(Round(Missile.GetGraphObject.Position.X) - GetMapCenter.X, Round(Missile.GetGraphObject.Position.Y) - GetMapCenter.Y);
      HitObjectSize := Missile.GetGraphObject.Size;
      Result := Missile;
      Exit;
    end;
  end;
  Count := PlayerStar.Ships.Count;
  for Index := 0 to Count - 1 do
  begin
    Ship := TShip(PlayerStar.Ships[Index]);
    if not (Ship is TRuins) and (Ship <> nil) and (Ship.Graphic <> nil) and Ship.Graphic.HitTestCursor then
    begin
      HitObjectPosition := Classes.Point(Round(Ship.Graphic.Position.X) - GetMapCenter.X, Round(Ship.Graphic.Position.Y) - GetMapCenter.Y);
      HitObjectSize := Ship.Graphic.Size;
      Result := Ship;
      Exit;
    end;
  end;
  Count := PlayerStar.Items.Count;
  for Index := 0 to Count - 1 do
  begin
    Item := TItem(PlayerStar.Items[Index]);
    if (Item <> nil) and (Item.GetGraphObject <> nil) and Item.GetGraphObject.HitTestCursor then
    begin
      HitObjectPosition := Classes.Point(Round(Item.GetGraphObject.Position.X) - GetMapCenter.X, Round(Item.GetGraphObject.Position.Y) - GetMapCenter.Y);
      HitObjectSize := Classes.Point(38, 38);
      Result := Item;
      Exit;
    end;
  end;
  Count := PlayerStar.Ships.Count;
  for Index := 0 to Count - 1 do
  begin
    Ship := TShip(PlayerStar.Ships[Index]);
    if (Ship is TRuins) and (Ship <> nil) and (Ship.Graphic <> nil) and Ship.Graphic.HitTestCursor then
    begin
      HitObjectPosition := Classes.Point(Round(Ship.Graphic.Position.X) - GetMapCenter.X, Round(Ship.Graphic.Position.Y) - GetMapCenter.Y);
      HitObjectSize := Ship.Graphic.Size;
      Result := Ship;
      Exit;
    end;
  end;
  Count := PlayerStar.Asteroids.Count;
  for Index := 0 to Count - 1 do
  begin
    Asteroid := TAsteroid(PlayerStar.Asteroids[Index]);
    if (Asteroid <> nil) and (Asteroid.GraphObject <> nil) and Asteroid.GraphObject.HitTestCursor then
    begin
      HitObjectPosition := Classes.Point(Round(Asteroid.GraphObject.Position.X) - GetMapCenter.X, Round(Asteroid.GraphObject.Position.Y) - GetMapCenter.Y);
      HitObjectSize := Asteroid.GraphObject.Size;
      Result := Asteroid;
      Exit;
    end;
  end;
  Count := PlayerStar.Planets.Count;
  for Index := 0 to Count - 1 do
  begin
    Planet := TPlanet(PlayerStar.Planets[Index]);
    if Planet.Graphic.IsRuins then
    begin
      if Planet.Graphic.HitTestCursor then
      begin
        HitObjectPosition := Classes.Point(Round(Planet.Graphic.Position.X) - GetMapCenter.X, Round(Planet.Graphic.Position.Y) - GetMapCenter.Y);
        HitObjectSize := Planet.Graphic.Size;
        Result := Planet;
        Exit;
      end;
    end
    else if Sqr(Point.X - Planet.GetPosition.X) + Sqr(Point.Y - Planet.GetPosition.Y) < Sqr(Planet.GraphicRadius) then
    begin
      HitObjectPosition := Classes.Point(Round(Planet.Graphic.Position.X) - GetMapCenter.X, Round(Planet.Graphic.Position.Y) - GetMapCenter.Y);
      HitObjectSize := Planet.Graphic.Size;
      Result := Planet;
      Exit;
    end;
  end;
  if Point.X * Point.X + Point.Y * Point.Y < Sqr(PlayerStar.Radius) then
  begin
    HitObjectPosition := Classes.Point(Round(PlayerStar.Graphic.Position.X) - GetMapCenter.X, Round(PlayerStar.Graphic.Position.Y) - GetMapCenter.Y);
    HitObjectSize := Classes.Point(300, 300);
    Result := PlayerStar;
    Exit;
  end;
  for Index := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := THole(Galaxy.Holes[Index]);
    if ((Hole.Star1 = PlayerStar) or (Hole.Star2 = PlayerStar)) and (Hole.Graphic <> nil) then
    begin
      if PointDistanceSquared(Hole.Graphic.Position, PointToPointF(Point)) < Sqr(THoleSE(Hole.Graphic).HitRadius) then
      begin
        HitObjectPosition := Classes.Point(Round(Hole.Graphic.Position.X) - GetMapCenter.X, Round(Hole.Graphic.Position.Y) - GetMapCenter.Y);
        HitObjectSize := Classes.Point(120, 120);
        Result := Hole;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;
{ @end $7ACE64 }

{ @routine $7AD81C TfStarMap_QueueInterfaceImages }
procedure TfStarMap.QueueInterfaceImages;
var Loads: TList;
begin
  if not CacheLoader.IsRunning then
  begin
    Loads := TList.Create;
    QueueHyperspaceLoadingAssets(Loads, RootUiObject);
    if Loads.Count > 0 then CacheLoader.SetPendingLoads(Loads, True)
    else Loads.Free;
  end;
end;
{ @end $7AD81C }

{ @routine $7AD87C TfStarMap_ShowLargeHelp }
procedure TfStarMap.ShowLargeHelp(const Text: WideString);
begin
  LargeHelpText := Text;
  LargeHelpBuffer.SetActive(True);
  if LargeHelpTimer <> nil then
  begin
    CancelCallbackTimer(LargeHelpTimer);
    LargeHelpTimer := nil;
  end;
  LargeHelpTimer := ScheduleCallbackTimer(20, 20, AnimateLargeHelp);
  LargeHelpProgress := 0;
  AnimateLargeHelp(nil, 0);
end;
{ @end $7AD87C }

{ @routine $7AD914 TfStarMap_HideLargeHelp }
procedure TfStarMap.HideLargeHelp;
begin
  if LargeHelpTimer <> nil then
  begin
    CancelCallbackTimer(LargeHelpTimer);
    LargeHelpTimer := nil;
  end;
  LargeHelpBuffer.Invalidate;
  LargeHelpBuffer.SetActive(False);
end;
{ @end $7AD914 }

{ @routine $7AD968 TfStarMap_AnimateLargeHelp }
procedure TfStarMap.AnimateLargeHelp(Timer: PCallbackTimerGI; UserData: Integer);
var
  Intensity: Single;
  Color: Cardinal;
  Offset: Cardinal;
begin
  LargeHelpProgress := LargeHelpProgress + 0.01;
  if LargeHelpProgress >= 1.0 then HideLargeHelp
  else
  begin
    Intensity := 1.0 - (Cos(Pi * LargeHelpProgress * 2.0 * 2.0) * 0.5 + 0.5);
    with MeasureLabelTextBounds(LargeHelpText, NormalFontName) do
    begin
      LargeHelpBuffer.SourceHasPerPixelAlpha := True;
      Color := $FF000000 or (Cardinal(Round(Intensity * 224.0)) shl 16) or
        (Cardinal(Round(Intensity * 225.0)) shl 8) or Cardinal(Round(Intensity * 183.0));
      RenderLabelTextToBuffer(LargeHelpBuffer.GraphBuf, Right - Left + 1, 0, 0, LargeHelpText, NormalFontName, Color, 0, 0);
    end;
    with LargeHelpBuffer do
    begin
      Offset := (GraphBuf.Width shr 1) - ClientSize.X div 2;
      SetSize(Classes.Point(GraphBuf.Width, GraphBuf.Height));
      SetPosition(Classes.Point(LocalPosition.X - Offset, LocalPosition.Y));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      Invalidate;
    end;
  end;
end;
{ @end $7AD968 }

{ @routine $7ADB60 TfStarMap_RedrawMap }
procedure TfStarMap.RedrawMap;
begin
  UpdateRectsEnabled := True;
  MapControls.InvalidateChildren(False);
  CursorControl.Invalidate;
  UpdateRectsEnabled := False;
  InvalidateTransientControl;
end;
{ @end $7ADB60 }

{ @routine $7ADBA0 TfStarMap_DrawFrame }
procedure TfStarMap.DrawFrame;
var
  RectNode: TRectGR;
  Stage: Integer;
begin
  Stage := 0;
  try
    if (MinimapFrameCounter mod 16) = 0 then
    begin
      Stage := 1;
      if Mode = smmTurnFilm then SpaceProcess.Space.DrawMinimap;
    end;
    Inc(MinimapFrameCounter);
    Stage := 2;
    RedrawMap;
    Stage := 3;
    StarField.UpdateBackgroundBounds;
    Stage := 4;
    if SkipSavedPixelRestore or FullFrameRedrawRequested then
    begin
      UpdateRects.Clear;
      UpdateRectsEnabled := True;
      InvalidateViewport;
      UpdateRectsEnabled := False;
    end;
    FullFrameRedrawRequested := False;
    Stage := 5;
    RestoreSavedPixels16;
    Stage := 6;
    RestoreSavedLines;
    Stage := 7;
    ErasePreviousFrame;
    Stage := 8;
    RectNode := UpdateRects.FirstRect;
    while RectNode <> nil do
    begin
      StarField.DrawBackground(RectNode.Bounds);
      RectNode := RectNode.Next;
    end;
    Stage := 9;
    if not HardwareRenderingEnabled then PrepareFrameDraw;
    Stage := 10;
    DrawQueuedControlRects;
    Stage := 11;
    if not ShipScreen.FlagD4 and (TalkScreen.Flag128 = 0) and not GoodsShopScreen.FlagEC then
    begin
      if not BeginFramePresentation then
      begin
        RequestedScreenId := screenNone;
        PostLoadScreenId := FormToId(Self);
        RequestClose(1);
        Exit;
      end;
      Stage := 12;
      FinishQueuedDraw;
      Stage := 13;
      CommitFrameDraw;
      Stage := 14;
      ResetSavedLineCount;
      Stage := 15;
      ResetSecondaryPixelCount;
      Stage := 16;
      EndFramePresentation;
    end;
    Stage := 17;
    RedrawMap;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('TfStarMap.Draw2, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $7ADBA0 }

{ @routine $7ADF00 TfStarMap_RunTalkDialogs }
procedure TfStarMap.RunTalkDialogs;
var
  Trading: Integer;
  Index: Integer;
begin
  PrepareTalkDisplay;
  TalkReturnScreenId := FormToId(Self);
  RequestedScreenId := screenTalk;
  if GetPlayer <> TalkShip then SoundManager.PlaySound('Sound.Talk');
  ScannerSelectionActive := False;
  TalkSelectionActive := False;
  HideActionRanges;
  SetCursorActive(False);
  for Index := 0 to 2 do
  begin
    PresentScreenBuffer;
    Present;
  end;
  if AuxRenderBuffer <> nil then AuxRenderBuffer.Clear;
  CaptureScreenBackground(False, 0);
  SetCursorActive(True);
  Trading := 0;
  TalkScreen.PlayTransitionSounds := True;
  while True do
  begin
    if Trading = 0 then
    begin
      RunTalk(Self);
      if TalkScreen.Flag128 = 2 then Trading := 1;
    end
    else
    begin
      RunGoodsShop(Self);
      TalkScreen.Flag12C := True;
      if not GoodsShopScreen.FlagEC then Trading := 0;
    end;
    MainPanel.RefreshMoneyAndCargo;
    if (TalkScreen.Flag128 = 0) and not GoodsShopScreen.FlagEC then MainPanel.RebuildMessageButtons(False)
    else if Trading = 0 then MainPanel.RebuildMessageButtons(False)
    else
    begin
      MainPanel.ShowHelpText('', False);
      MainPanel.ClearMessageButtons;
    end;
    ScannerSelectionActive := False;
    TalkSelectionActive := False;
    HideActionRanges;
    SetCursorActive(False);
    Present;
    SetCursorActive(True);
    if (TalkScreen.Flag128 = 0) and not GoodsShopScreen.FlagEC then Break;
    SetCursorActive(False);
    CaptureScreenBackground(Trading <> 0, 1);
    SetCursorActive(True);
  end;
  if (SpaceProcess <> nil) and (SpaceProcess.Space <> nil) then
  begin
    SpaceProcess.BindMinimap(GetByName('MapPanel'));
    if Mode = smmOrders then SpaceProcess.Space.ScrollChangedCallback := MapScrollChanged
    else SpaceProcess.Space.ScrollChangedCallback := nil;
    if Mode = smmOrders then
    begin
      RebuildPartnerButtons;
      RebuildTargetMarkers;
    end;
  end;
  RestorePendingSceneObjects;
  ResumeMode := smrNormal;
  if GameEndReason = 4 then
  begin
    RequestedScreenId := screenGameEnd;
    ReleaseAllTextureSurfaces;
    RequestClose(1);
  end;
end;
{ @end $7ADF00 }

{ @routine $7AE204 TfStarMap_GalaxyClicked }
procedure TfStarMap.GalaxyClicked(Sender: TObjectGI);
begin
  if Galaxy.SpecialSimulationMode = 0 then
  begin
    MainPanel.NavigationLocked := True;
    if not ShipScreen.FlagD4 then
    begin
      HideLargeHelp;
      GetByName('PM_WinMsg').SetActive(False);
      SetCursorActive(False);
      Present;
      CaptureScreenBackground(True, 0);
      SetCursorActive(True);
      GalaxyScreen.ViewMode := 2;
      GalaxyReturnScreenId := FormToId(Self);
      RequestedScreenId := screenGalaxy;
      RequestClose(1);
    end;
  end;
end;
{ @end $7AE204 }

{ @routine $7AE2D4 TfStarMap_ShipClicked }
procedure TfStarMap.ShipClicked(Sender: TObjectGI);
begin
  if Galaxy.SpecialSimulationMode = 0 then
  begin
    MainPanel.NavigationLocked := True;
    if not ShipScreen.FlagD4 then
    begin
      Galaxy.CheckIntegrityChecksum(13131);
      HideLargeHelp;
      ShowObjectInfo(nil);
      ClearPathOverlay(True);
      BuildShipPathOverlay(GetPlayer, False, '');
      SetCursorActive(False);
      Present;
      CaptureScreenBackground(True, 0);
      SetCursorActive(True);
      ShipScreen.ShipToInspect := ShipToInspect;
      if ShipToInspect = nil then PlayerHoldShip := GetPlayer;
      ShipScreen.PlayTransitionSounds := True;
      ShipReturnScreenId := FormToId(Self);
      Galaxy.ClearIntegrityStatus;
      RequestedScreenId := screenShip;
      RequestClose(1);
    end;
  end;
end;
{ @end $7AE2D4 }

{ @routine $7AE3EC TfStarMap_StartOrderMode }
procedure TfStarMap.StartOrderMode;
var
  Index: Integer;
begin
  Galaxy.ClearIntegrityStatus;
  ScrollLeftHeld := False;
  ScrollRightHeld := False;
  ScrollUpHeld := False;
  ScrollDownHeld := False;
  MinimapFrameCounter := 0;
  ScannerSelectionActive := False;
  TalkSelectionActive := False;
  for Index := 0 to 4 do SelectedWeapons[Index] := False;
  InterceptorSelectionActive := False;
  CustomSelectionActive := False;
  DisplayedObject := nil;
  CursorObject := nil;
  UpdateRectsEnabled := True;
  MapControls.Invalidate;
  UpdateRectsEnabled := False;
  GetPlayer.BuildOrderMovementPath(999999);
  CenterShipButton.DownCallback := CenterShipClicked;
  CenterShipButton.MouseEnterCallback := CenterShipMouseEnter;
  CenterShipButton.MouseLeaveCallback := CenterShipMouseLeave;
  if SpaceEffectsTimer <> nil then
  begin
    CancelCallbackTimer(SpaceEffectsTimer);
    SpaceEffectsTimer := nil;
  end;
  SpaceEffectsTimer := ScheduleCallbackTimer(18, 18, AdvanceSpaceEffects);
  InfoWindow.SetActive(False);
  ItemInfoWindow.SetActive(False);
  ShipInfoPanel.SetActive(False);
  PlanetInfoPanel.SetActive(False);
  StarInfoWindow.SetActive(False);
  StandardInfoPanel.SetActive(False);
  SpaceProcess.Space.ScrollChangedCallback := MapScrollChanged;
  MainPanel.Show;
  WeaponPanel.SetActive(StarMapWeaponPanelOpen);
  MapControls.LeftButtonDownCallback := MapLeftButtonDown;
  ConfigureMiddleButtonAction;
  MapControls.RightButtonDownCallback := MapRightButtonDown;
  MapControls.RightButtonDoubleClickCallback := nil;
  MapControls.MouseMoveCallback := MapMouseMove;
  ContentPanel.KeyDownCallback := OrderKeyDown;
  ContentPanel.KeyUpCallback := OrderKeyUp;
  SpaceProcess.Space.DrawMinimap;
  RebuildTargetMarkers;
  RefreshActionRanges;
  RefreshWeaponButtons;
  MainPanel.RebuildMessageButtons(False);
  Mode := smmOrders;
  Galaxy.PrimeIntegrityChecksum(25);
  BuildShipPathOverlay(GetPlayer, False, '');
  RebuildPartnerButtons;
  MainPanel.SetDateRange(Galaxy.CurrentTurn, Galaxy.CurrentTurn);
  MainPanel.RefreshDate;
  if StarMapWeaponPanelOpen then WeaponPanelProgress := 1.0
  else WeaponPanelProgress := 0.0;
  if WeaponPanelTimer <> nil then
  begin
    CancelCallbackTimer(WeaponPanelTimer);
    WeaponPanelTimer := nil;
  end;
  UpdateWeaponPanelPosition;
  if AnimateSpacePanelOnResume then
  begin
    if SpacePanelTimer <> nil then
    begin
      CancelCallbackTimer(SpacePanelTimer);
      SpacePanelTimer := nil;
    end;
    SpacePanelProgress := 0.0;
    AnimateSpacePanel(1);
  end
  else
  begin
    if SpacePanelTimer <> nil then
    begin
      CancelCallbackTimer(SpacePanelTimer);
      SpacePanelTimer := nil;
    end;
    SpacePanelProgress := 1.0;
    UpdateSpacePanelPosition;
  end;
  AnimateSpacePanelOnResume := False;
  Galaxy.CheckIntegrityChecksum(311);
  UpdateTerronTransformation;
  Galaxy.PrimeIntegrityChecksum(310);
  TalkButton.SetDisabled(not GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar));
  ScannerButton.SetDisabled((not GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar) or
    not GetPlayer.IsEquipmentUsable(GetPlayer.GetScanner)) and (Galaxy.UltraScanModEnabled = 0));
  if CenterShipButton.IsHovered then
  begin
    CenterShipMouseLeave(nil);
    CenterShipMouseEnter(nil);
  end;
  (GetByName('PM_EndTurn') as TGraphButtonGI).SetHovered(False);
  PostMouseMoveMessage;
  if GameEndReason = 4 then
  begin
    RequestedScreenId := screenGameEnd;
    ReleaseAllTextureSurfaces;
    RequestClose(1);
  end;
  Galaxy.CheckIntegrityChecksum(105);
  Galaxy.PrimeIntegrityChecksum(106);
end;
{ @end $7AE3EC }

{ @routine $7AE980 TfStarMap_StopOrderMode }
procedure TfStarMap.StopOrderMode;
var
  Index: Integer;
begin
  Galaxy.CheckIntegrityChecksum(26);
  if DeferredEndTurnTimer <> nil then
  begin
    CancelCallbackTimer(DeferredEndTurnTimer);
    DeferredEndTurnTimer := nil;
  end;
  if PlayerPathTimer <> nil then
  begin
    CancelCallbackTimer(PlayerPathTimer);
    PlayerPathTimer := nil;
  end;
  Mode := smmInactive;
  if WeaponPanelTimer <> nil then
  begin
    CancelCallbackTimer(WeaponPanelTimer);
    WeaponPanelTimer := nil;
  end;
  AnimateSpacePanel(-1);
  CenterShipButton.DownCallback := nil;
  CursorObject := nil;
  ScannerSelectionActive := False;
  TalkSelectionActive := False;
  InterceptorSelectionActive := False;
  CustomSelectionActive := False;
  for Index := 0 to 4 do SelectedWeapons[Index] := False;
  RefreshActionRanges;
  HideActionRanges;
  MainPanel.ClearMessageButtons;
  HideOrderInterface;
  SpaceProcess.Space.ScrollChangedCallback := nil;
  MapControls.LeftButtonDownCallback := nil;
  MapControls.LeftButtonDoubleClickCallback := nil;
  MapControls.RightButtonDownCallback := nil;
  MapControls.MouseMoveCallback := nil;
  ContentPanel.KeyDownCallback := nil;
  ContentPanel.KeyUpCallback := nil;
  if SpaceEffectsTimer <> nil then
  begin
    CancelCallbackTimer(SpaceEffectsTimer);
    SpaceEffectsTimer := nil;
  end;
end;
{ @end $7AE980 }

{ @routine $7AEB78 TfStarMap_HideOrderInterface }
procedure TfStarMap.HideOrderInterface;
begin
  ClearAsteroidPath;
  ClearTargetMarkers;
  ClearMapAnimations;
  ClearPathOverlay(True);
  ClearPathOverlay(False);
  MainPanel.ClearMessageButtons;
  InfoWindow.SetActive(False);
  ItemInfoWindow.SetActive(False);
  ShipInfoPanel.SetActive(False);
  PlanetInfoPanel.SetActive(False);
  StarInfoWindow.SetActive(False);
  StandardInfoPanel.SetActive(False);
  MainPanel.Hide;
end;
{ @end $7AEB78 }

{ @routine $7AEC2C TfStarMap_ConfigureMiddleButtonAction }
procedure TfStarMap.ConfigureMiddleButtonAction;
begin
  if ActionDoubleClick then
  begin
    MapControls.LeftButtonDoubleClickCallback := MapMiddleButtonDown;
    Exit;
  end;
  MapControls.LeftButtonDoubleClickCallback := MapLeftButtonDown;
end;
{ @end $7AEC2C }

{ @routine $7AEC7C TfStarMap_ScrollMap }
procedure TfStarMap.ScrollMap(Timer: PCallbackTimerGI; UserData: Integer);
var
  Point, OldPoint: TPoint;
  X, Y: SmallInt;
begin
  OldPoint := GetMapCenter;
  Point := OldPoint;
  if ScrollLeftHeld then Dec(Point.X, ScrollStep);
  if ScrollRightHeld then Inc(Point.X, ScrollStep);
  if ScrollUpHeld then Dec(Point.Y, ScrollStep);
  if ScrollDownHeld then Inc(Point.Y, ScrollStep);
  X := GetCursorPoint.X;
  Y := GetCursorPoint.Y;
  if GetForegroundWindow = MainWindowHandle then
  begin
    if (X >= -30) and (X <= Integer(GameScreenWidth) + 30) then
    begin
      if X < ScrollSense then Dec(Point.X, ScrollStep);
      if X > Integer(GameScreenWidth) - ScrollSense - 1 then Inc(Point.X, ScrollStep);
    end;
    if (Y >= -30) and (Y <= Integer(GameScreenHeight) + 30) then
    begin
      if Y < ScrollSense then Dec(Point.Y, ScrollStep);
      if Y > Integer(GameScreenHeight) - ScrollSense - 1 then Inc(Point.Y, ScrollStep);
    end;
    if (OldPoint.X <> Point.X) or (OldPoint.Y <> Point.Y) then SetMapCenterManually(Point);
  end;
end;
{ @end $7AEC7C }

{ @routine $7AEDFC TfStarMap_AdvanceSpaceEffects }
procedure TfStarMap.AdvanceSpaceEffects(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if TrailingFilmEffects <> nil then
  begin
    TrailingFilmEffects.AdvanceEffects;
    if TrailingFilmEffects.FirstEntry = nil then
    begin
      TrailingFilmEffects.Free;
      TrailingFilmEffects := nil;
    end;
  end;
  SpaceProcess.Space.AdvanceTimers;
  SpaceProcess.Space.AdvanceObjects;
end;
{ @end $7AEDFC }

{ @routine $7AEE68 TfStarMap_IsMapPointBlocked }
function TfStarMap.IsMapPointBlocked(Sender: TObjectGI; Point: TPoint): Boolean;
begin
  Result := True;
  if (Sender <> nil) and Sender.IsOccludedAtPoint(Point) then Exit;
  if MainPanel.BackgroundImage.HitTestPixel(Point) then Exit;
  if WeaponPanel.Active and WeaponBackgroundImage.HitTestPixel(Point) then Exit;
  if SpaceBackgroundImage.HitTestPixel(Point) then Exit;
  if WeaponPanel.Active and WeaponButtons[0].HitTest(Point) then Exit;
  if WeaponPanel.Active and WeaponButtons[1].HitTest(Point) then Exit;
  if WeaponPanel.Active and WeaponButtons[2].HitTest(Point) then Exit;
  if WeaponPanel.Active and WeaponButtons[3].HitTest(Point) then Exit;
  if WeaponPanel.Active and WeaponButtons[4].HitTest(Point) then Exit;
  if WeaponPanel.Active and AllWeaponsButton.HitTest(Point) then Exit;
  if HideSpacePanelButton.HitTest(Point) then Exit;
  if ShowSpacePanelButton.HitTest(Point) then Exit;
  if ScannerButton.HitTest(Point) then Exit;
  if TalkButton.HitTest(Point) then Exit;
  if TurnFilmButton.HitTest(Point) then Exit;
  if MainPanel.ShipButton.HitTest(Point) then Exit;
  if MainPanel.GalaxyButton.HitTest(Point) then Exit;
  if MainPanel.QuestButton.HitTest(Point) then Exit;
  if MainPanel.EndTurnButton.HitTest(Point) then Exit;
  if MainPanel.MenuButton.HitTest(Point) then Exit;
  Result := False;
end;
{ @end $7AEE68 }

{ @routine $7AF0E8 TfStarMap_MapLeftButtonDown }
procedure TfStarMap.MapLeftButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  MapControl: TPanelGI;
  Destination: TPointF;
  Ship: TShip;
  Location: TObject;
  Hole: THole;
  Index, Mode, SelectedCount, ActionResult: Integer;
  TargetPosition: TPointF;
  Info: PCustomShipInfo;
  HadWeapons, OutOfRange: Boolean;
  Weapon: TWeapon;
  Node, FollowingNode: PSPathNode;
  ScanUnresolved, TalkUnresolved, AnimatePath: Boolean;
  Response, InitialImage: WideString;
begin
  if MainPanel.NavigationLocked then Exit;
  if ShipScreen.FlagD4 then Exit;
  HideLargeHelp;
  if IsMapPointBlocked(Sender, Point) then Exit;
  CursorObject := FindObjectAtCursor;
  ScanUnresolved := ScannerSelectionActive;
  TalkUnresolved := TalkSelectionActive;
  OutOfRange := False;
  HadWeapons := False;
  SelectedCount := 0;
  for Index := 0 to 4 do
    if SelectedWeapons[Index] then
    begin
      Inc(SelectedCount);
      HadWeapons := True;
    end;
  MapControl := MapControls;
  Destination := PointToPointF(MapControl.ToLocalPoint(Point));
  if CustomSelectionActive and (CursorObject <> nil) and not (CursorObject is THole) then
  begin
    TargetPosition.X := 0;
    TargetPosition.Y := 0;
    if CursorObject is TShip then TargetPosition := TShip(CursorObject).Position
    else if CursorObject is TMissile then TargetPosition := TMissile(CursorObject).Position
    else if CursorObject is TAsteroid then TargetPosition := TAsteroid(CursorObject).Position
    else if CursorObject is TItem then TargetPosition := TItem(CursorObject).Position
    else if CursorObject is TPlanet then TargetPosition := TPlanet(CursorObject).GetPosition
    else if CursorObject is THole then
    begin
      // Kept by the native routine despite the outer hole exclusion.
      if THole(CursorObject).Star1 = PlayerStar then TargetPosition := THole(CursorObject).Position1
      else TargetPosition := THole(CursorObject).Position2;
    end;
    if PointDistanceSquared(GetPlayer.Position, TargetPosition) > CustomSelectionRadius * CustomSelectionRadius then
      ShowLargeHelp(CustomSelectionOutOfRangeText)
    else
    begin
      ActionResult := 0;
      if CustomSelectionItem <> nil then
      begin
        if CustomSelectionItem.ScriptItem <> nil then
          ActionResult := TScriptItem(CustomSelectionItem.ScriptItem).RunActionCode($35, GetPlayer, CursorObject, nil, ActionResult);
        if CustomSelectionItem is TEquipmentWithActCode then
          ActionResult := RunItemConfigActionCode(CustomSelectionItem, $35, GetPlayer, CursorObject, nil, ActionResult);
      end
      else
        for Index := 0 to GetPlayer.CustomShipInfos.Count - 1 do
        begin
          Info := GetPlayer.CustomShipInfos[Index];
          if not Info.DeleteQueued and (Info.TypeName = CustomSelectionInfoName) then
          begin
            ActionResult := RunCustomShipInfoActionCode(Info, $35, GetPlayer, CursorObject, nil, ActionResult);
            Break;
          end;
        end;
      if ActionResult > 0 then ShowLargeHelp(CustomSelectionSuccessText)
      else if ActionResult = 0 then ShowLargeHelp(CustomSelectionFailureText);
    end;
    CustomSelectionActive := False;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
    Exit;
  end;
  if not (TalkSelectionActive and (CursorObject is TStar) and (TerronShip <> nil) and
    (GetPlayer.CurrentStar = TerronShip.CurrentStar) and (Galaxy.TerronToStarTurn >= $40000000)) then
  begin
    if ((ScannerSelectionActive or TalkSelectionActive) and not (CursorObject is TShip)) or
       ((CursorObject is TShip) and
        ((ScannerSelectionActive and ((CursorObject as TShip).NoScan or GetPlayer.ScanLocked)) or
         (TalkSelectionActive and ((CursorObject as TShip).NoTalk or GetPlayer.TalkLocked)) or
         ((HadWeapons or InterceptorSelectionActive) and not GetPlayer.CanSelectShipTarget(CursorObject as TShip)))) then
    begin
      if ScannerSelectionActive then ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanImpossible'))
      else if TalkSelectionActive then ShowLargeHelp(LookupLocalizedTextByKey('Help.TalkImpossible'))
      else if HadWeapons then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotCancel'));
      ScannerSelectionActive := False;
      TalkSelectionActive := False;
      RefreshActionRanges;
      RefreshWeaponButtons;
      UpdateActionCursor(False);
      Exit;
    end;
  end;
  if (GetPlayer.CalculateSpeed <= 0) and not HadWeapons and not ScannerSelectionActive and
    not TalkSelectionActive and not InterceptorSelectionActive and not (CursorObject is TItem) then
  begin
    SetCursorActive(False);
    DrawFrame;
    SetCursorActive(True);
    ShowMessageBoxGI(Self, LocalizedColorText('Help.Speed0'), mbgCancel or mbgError);
    FullFrameRedrawRequested := True;
    DrawFrame;
    Exit;
  end;
  if CursorObject <> nil then
  begin
    if (CursorObject is TPlanet) and (CursorObject as TPlanet).NoLanding then CursorObject := nil
    else if CursorObject is TRuins then
    begin
      if HadWeapons or InterceptorSelectionActive then
        if not GetPlayer.CanSelectShipTarget(CursorObject as TRuins) then CursorObject := nil;
      if not HadWeapons and not InterceptorSelectionActive then
        if not (CursorObject as TRuins).CheckDockingPermission(GetPlayer, Response) then
        begin
          ShowLargeHelp(Response);
          CursorObject := nil;
        end;
    end
    else if CursorObject is THole then
      if GetPlayer.NoJump or ((CursorObject as THole).ArcadeMapName = 'NoEntry') then CursorObject := nil;
  end;
  if CursorObject = nil then
  begin
    ClearPathOverlay(True);
    PendingPlayerFollowTarget := nil;
    Galaxy.CheckIntegrityChecksum(27);
    GetPlayer.OrderMove(Destination, False);
    GetPlayer.BuildOrderMovementPath(999999);
    if (GetPlayer.MovementPath <> nil) and (GetPlayer.MovementPath.ActiveHead <> nil) then
    begin
      Node := GetPlayer.MovementPath.ActiveHead;
      while Node <> nil do
      begin
        FollowingNode := GetPlayer.MovementPath.GetFollowingNode(Node, 198);
        if FollowingNode = nil then Break;
        if FollowingNode.Next = nil then Break;
        Node := FollowingNode.Next;
      end;
      if PointDistanceSquared(Node.Position, GetPlayer.MovementPath.ActiveTail.Position) < 4900 then
      begin
        FollowingNode := Node;
        while (FollowingNode <> nil) and (PointDistanceSquared(FollowingNode.Position, Node.Position) < 25) do
          FollowingNode := FollowingNode.Prev;
        if FollowingNode <> nil then
        begin
          GetPlayer.OrderMove(FollowingNode.Position, False);
          GetPlayer.BuildOrderMovementPath(999999);
        end;
      end;
    end
    else GetPlayer.OrderNone(False);
    BuildShipPathOverlay(GetPlayer, False, '');
    if InterceptorSelectionActive then
      if GetPlayer.GetHull.InterceptorTarget <> nil then
      begin
        GetPlayer.GetHull.InterceptorTarget := nil;
        RebuildTargetMarkers;
      end;
    Galaxy.PrimeIntegrityChecksum(28);
  end
  else if CursorObject is TPlanet then
  begin
    Location := CursorObject as TPlanet;
    ClearPathOverlay(True);
    Galaxy.CheckIntegrityChecksum(33);
    PendingPlayerFollowTarget := nil;
    if not (((GetPlayer.Order = soLand) and (GetPlayer.OrderTarget = Location)) or
      ((CursorObject as TPlanet).OwnerId = Byte(oiDominator)) or
      ((GetPlayer.CurrentStar.Status.CustomFaction <> '') and ((CursorObject as TPlanet).OwnerId <> Byte(oiUninhabited)))) then
    begin
      GetPlayer.OrderLanding(Location, False);
      GetPlayer.OrderDestination := SubtractPointsF(Destination, TPlanet(Location).GetPosition);
      ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveLanding'));
    end
    else
    begin
      GetPlayer.OrderMove(Destination, False);
      GetPlayer.BuildOrderMovementPath(999999);
    end;
    Galaxy.PrimeIntegrityChecksum(34);
    BuildShipPathOverlay(GetPlayer, False, '');
  end
  else if CursorObject is THole then
  begin
    Hole := CursorObject as THole;
    ClearPathOverlay(True);
    Galaxy.CheckIntegrityChecksum(35);
    PendingPlayerFollowTarget := nil;
    if not ((GetPlayer.Order = soJumpHole) and (GetPlayer.OrderTarget = Hole)) then
    begin
      GetPlayer.OrderJumpHole(Hole, False);
      GetPlayer.OrderDestination := Destination;
      GetPlayer.BuildOrderMovementPath(999999);
    end
    else
    begin
      GetPlayer.OrderMove(Destination, False);
      GetPlayer.BuildOrderMovementPath(999999);
    end;
    Galaxy.PrimeIntegrityChecksum(36);
    BuildShipPathOverlay(GetPlayer, False, '');
  end
  else if (CursorObject is TRuins) or
    ((TerronShip = CursorObject) and (Galaxy.TerronLandingLockTurn > 0) and not TalkSelectionActive) then
  begin
    Ship := CursorObject as TShip;
    ClearPathOverlay(True);
    Galaxy.CheckIntegrityChecksum(37);
    PendingPlayerFollowTarget := nil;
    if HadWeapons and (GetPlayer <> CursorObject) then
    begin
      Mode := 0;
      Galaxy.CheckIntegrityChecksum(41);
      for Index := 0 to 4 do
        if SelectedWeapons[Index] then
        begin
          Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
          if PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) <= GetPlayer.GetWeaponActionRange(Weapon) then
          begin
            SelectedWeapons[Index] := False;
            Weapon.Target := CursorObject;
            Mode := 1;
          end
          else if Mode = 0 then
          begin
            Mode := 2;
            OutOfRange := True;
          end;
        end;
      Galaxy.PrimeIntegrityChecksum(42);
      if Mode = 1 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotSet'))
      else if Mode = 2 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotOutRange'));
      RebuildTargetMarkers;
    end
    else if InterceptorSelectionActive and (GetPlayer <> CursorObject) then
    begin
      if (PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) <= 1000) and
        ((CursorObject as TRuins).InterceptorPassesRemaining = 0) then
      begin
        GetPlayer.GetHull.InterceptorTarget := CursorObject as TRuins;
        ShowLargeHelp(LookupLocalizedTextByKey('Help.InterceptorsSet'));
      end
      else if PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) > 1000 then
        ShowLargeHelp(LookupLocalizedTextByKey('Help.InterceptorsOutRange'));
      Galaxy.PrimeIntegrityChecksum(42);
      RebuildTargetMarkers;
    end
    else if not (((GetPlayer.Order = soLand) and (GetPlayer.OrderTarget = Ship)) or
      ((Byte(Ship.GetRelationLevelToShip(GetPlayer)) <= 0) and ((Ship <> TerronShip) or (Galaxy.TerronLandingLockTurn <= 0)))) then
    begin
      GetPlayer.OrderLanding(Ship, False);
      GetPlayer.OrderDestination := SubtractPointsF(Destination, Ship.Position);
      ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveLanding'));
    end
    else
    begin
      GetPlayer.OrderMove(Destination, False);
      GetPlayer.BuildOrderMovementPath(999999);
    end;
    Galaxy.PrimeIntegrityChecksum(38);
    BuildShipPathOverlay(GetPlayer, False, '');
  end
  else if CursorObject is TShip then
  begin
    Ship := CursorObject as TShip;
    if ScannerSelectionActive then
    begin
      if (PointDistance(GetPlayer.Position, Ship.Position) <= GetPlayer.GetRadarRange) and
        (GetPlayer <> CursorObject) and GetPlayer.CanScanShip(Ship) and
        ((Galaxy.UltraScanModEnabled <> 0) or GetPlayer.CanResolveObjectWithScanner(Ship) or (Ship.TypeId = stTranclucator)) then
      begin
        if (Ship is TTranclucator) and ((Ship as TTranclucator).OwnerShip = GetPlayer) then
        begin
          ShipToInspect := Ship;
          ShipClicked(nil);
        end
        else
        begin
          HideLargeHelp;
          ScannerSelectionActive := False;
          TalkSelectionActive := False;
          HideActionRanges;
          ShowObjectInfo(nil);
          SoundManager.PlaySound('Sound.Scan');
          SetCursorActive(False);
          Present;
          CaptureScreenBackground(True, 0);
          SetCursorActive(True);
          ScanUnresolved := False;
          ScannerTarget := CursorObject;
          ScannerReturnScreenId := FormToId(Self);
          RequestedScreenId := screenScanner;
          RequestClose(1);
        end;
      end
      else if GetPlayer = CursorObject then
      begin
        ScanUnresolved := False;
        ShipToInspect := GetPlayer;
        ShipClicked(nil);
      end
      else if PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) > GetPlayer.GetRadarRange then
      begin
        ScanUnresolved := False;
        ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanOutRange'));
      end
      else if (GetPlayer <> CursorObject) and not (CursorObject is TRuins) then
        if not GetPlayer.CanResolveObjectWithScanner(CursorObject) and ((CursorObject as TShip).TypeId <> stTranclucator) then
        begin
          ScanUnresolved := False;
          ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanPowerLow'));
        end;
    end
    else if TalkSelectionActive then
    begin
      if (PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) <= GetPlayer.GetRadarRange) and
        (GetPlayer <> CursorObject) and not ((CursorObject is TKling) and (CursorObject as TKling).IsProgramActive(prgDisconnection)) then
      begin
        HideLargeHelp;
        TalkUnresolved := False;
        CurrentScript := nil;
        ScriptDialogIndex := -1;
        TalkShip := CursorObject as TShip;
        TalkScripted := False;
        Galaxy.CheckIntegrityChecksum(39);
        RunTalkDialogs;
        ClearPathOverlay(True);
        GetPlayer.BuildOrderMovementPath(999999);
        Galaxy.PrimeIntegrityChecksum(40);
        BuildShipPathOverlay(GetPlayer, False, '');
      end
      else if PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) > GetPlayer.GetRadarRange then
      begin
        TalkUnresolved := False;
        ShowLargeHelp(LookupLocalizedTextByKey('Help.TalkOutRange'));
      end;
    end
    else if InterceptorSelectionActive and (GetPlayer <> CursorObject) then
    begin
      if (PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) <= 1000) and
        ((CursorObject as TShip).InterceptorPassesRemaining = 0) then
      begin
        GetPlayer.GetHull.InterceptorTarget := CursorObject as TShip;
        ShowLargeHelp(LookupLocalizedTextByKey('Help.InterceptorsSet'));
      end
      else if PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) > 1000 then
        ShowLargeHelp(LookupLocalizedTextByKey('Help.InterceptorsOutRange'));
      Galaxy.PrimeIntegrityChecksum(42);
      RebuildTargetMarkers;
    end
    else if HadWeapons and (GetPlayer <> CursorObject) then
    begin
      Mode := 0;
      Galaxy.CheckIntegrityChecksum(41);
      for Index := 0 to 4 do
        if SelectedWeapons[Index] then
        begin
          Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
          if PointDistance(GetPlayer.Position, (CursorObject as TShip).Position) <= GetPlayer.GetWeaponActionRange(Weapon) then
          begin
            SelectedWeapons[Index] := False;
            Weapon.Target := CursorObject;
            Mode := 1;
          end
          else if Mode = 0 then
          begin
            Mode := 2;
            OutOfRange := True;
          end;
        end;
      Galaxy.PrimeIntegrityChecksum(42);
      if Mode = 1 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotSet'))
      else if Mode = 2 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotOutRange'));
      RebuildTargetMarkers;
    end
    else if ((GetAsyncKeyState(VK_CONTROL) and $8000) = $8000) and (GetPlayer <> CursorObject) then
    begin
      ClearPathOverlay(True);
      Galaxy.CheckIntegrityChecksum(43);
      GetPlayer.OrderNone(False);
      if GetPlayer.CanSelectShipTarget(CursorObject as TShip) then PendingPlayerFollowTarget := CursorObject as TShip;
      Galaxy.PrimeIntegrityChecksum(44);
      BuildShipPathOverlay(GetPlayer, False, '');
      ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveAuto'));
    end
    else if GetPlayer = Ship then
    begin
      ClearPathOverlay(True);
      Galaxy.CheckIntegrityChecksum(45);
      PendingPlayerFollowTarget := nil;
      GetPlayer.OrderNone(False);
      Galaxy.PrimeIntegrityChecksum(46);
    end
    else
    begin
      Mode := 0;
      if PendingPlayerFollowTarget = Ship then Mode := 1
      else if (GetPlayer.Order = soFollowShip) and (GetPlayer.OrderTarget = Ship) then
      begin
        if Byte(GetPlayer.OrderStateData) = 1 then Mode := 3
        else Mode := 2;
      end;
      if (RightClickOnShip <> 2) or (Mode = 0) then
      begin
        ClearPathOverlay(True);
        AnimatePath := False;
        if Mode = 0 then
        begin
          SuppressMiddleFollowCycle := True;
          Mode := DefaultOrder;
          if (Mode < 0) or (Mode > 3) then Mode := 0;
          if DefaultOrder = 0 then
          begin
            if Byte(Ship.GetRelationLevelToShip(GetPlayer)) <= 0 then Mode := 1
            else Mode := 2;
          end;
        end
        else
        begin
          SuppressMiddleFollowCycle := False;
          AnimatePath := (RightClickOnShip <> 2) and ActionDoubleClick;
          if AnimatePath then
          begin
            if Mode = 1 then InitialImage := 'Bm.PI.PathEndAutoBattle'
            else if Mode = 2 then InitialImage := 'Bm.PI.PathEndFollowNear'
            else if Mode = 3 then InitialImage := 'Bm.PI.PathEndFollowMin'
            else InitialImage := 'Bm.PI.PathEndFollowMax';
          end;
          Inc(Mode);
          if Mode > 3 then Mode := 1;
        end;
        Galaxy.CheckIntegrityChecksum(47);
        if Mode = 1 then
          if not GetPlayer.CanSelectShipTarget(CursorObject as TShip) then Mode := 2;
        if Mode = 1 then
        begin
          GetPlayer.OrderNone(False);
          PendingPlayerFollowTarget := CursorObject as TShip;
          ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveAuto'));
        end
        else if Mode = 2 then
        begin
          PendingPlayerFollowTarget := nil;
          GetPlayer.OrderFollowShip(Ship, 0, False);
          ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveNear'));
        end
        else if Mode = 3 then
        begin
          PendingPlayerFollowTarget := nil;
          GetPlayer.OrderFollowShip(Ship, 1, False);
          ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveShot'));
        end;
        Galaxy.PrimeIntegrityChecksum(48);
        if AnimatePath then BuildShipPathOverlay(GetPlayer, True, InitialImage)
        else BuildShipPathOverlay(GetPlayer, False, '');
      end;
    end;
  end
  else if CursorObject is TStar then
  begin
    if TalkSelectionActive then
    begin
      if PointDistance(GetPlayer.Position, TerronShip.Position) <= GetPlayer.GetRadarRange then
      begin
        TalkShip := TerronShip;
        TalkScripted := False;
        ScriptDialogIndex := -1;
        Galaxy.CheckIntegrityChecksum(49);
        RunTalkDialogs;
        Galaxy.PrimeIntegrityChecksum(50);
      end;
    end
    else
    begin
      ClearPathOverlay(True);
      Galaxy.CheckIntegrityChecksum(51);
      GetPlayer.OrderMove(Destination, False);
      GetPlayer.BuildOrderMovementPath(999999);
      Galaxy.PrimeIntegrityChecksum(52);
      BuildShipPathOverlay(GetPlayer, False, '');
    end;
  end
  else if CursorObject is TItem then
  begin
    if HadWeapons then
    begin
      Mode := 0;
      Galaxy.CheckIntegrityChecksum(53);
      for Index := 0 to 4 do
        if SelectedWeapons[Index] then
        begin
          Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
          if PointDistance(GetPlayer.Position, (CursorObject as TItem).Position) <= GetPlayer.GetWeaponActionRange(Weapon) then
          begin
            SelectedWeapons[Index] := False;
            Weapon.Target := CursorObject;
            Mode := 1;
          end
          else if Mode = 0 then
          begin
            Mode := 2;
            OutOfRange := True;
          end;
        end;
      Galaxy.PrimeIntegrityChecksum(54);
      if Mode = 1 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotSet'))
      else if Mode = 2 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotOutRange'));
      RebuildTargetMarkers;
    end
    else if CanCargoHookHandleItem(TItem(CursorObject), GetPlayer) then
      if not GetPlayer.IsRecentlyDroppedItem(TItem(CursorObject)) then
      begin
        Galaxy.CheckIntegrityChecksum(55);
        if GetPlayer.HasPickupTarget(TItem(CursorObject)) then GetPlayer.RemovePickupTarget(TItem(CursorObject))
        else GetPlayer.AddPickupTarget(TItem(CursorObject), False);
        Galaxy.PrimeIntegrityChecksum(56);
        RebuildTargetMarkers;
      end;
  end
  else if CursorObject is TAsteroid then
  begin
    if HadWeapons then
    begin
      Mode := 0;
      Galaxy.CheckIntegrityChecksum(57);
      for Index := 0 to 4 do
        if SelectedWeapons[Index] then
        begin
          Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
          if PointDistance(GetPlayer.Position, (CursorObject as TAsteroid).Position) <= GetPlayer.GetWeaponActionRange(Weapon) then
          begin
            SelectedWeapons[Index] := False;
            Weapon.Target := CursorObject;
            Mode := 1;
          end
          else if Mode = 0 then
          begin
            Mode := 2;
            OutOfRange := True;
          end;
        end;
      Galaxy.PrimeIntegrityChecksum(58);
      if Mode = 1 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotSet'))
      else if Mode = 2 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotOutRange'));
      RebuildTargetMarkers;
    end;
  end
  else if CursorObject is TMissile then
  begin
    if HadWeapons then
    begin
      Mode := 0;
      Galaxy.CheckIntegrityChecksum(59);
      for Index := 0 to 4 do
        if SelectedWeapons[Index] then
        begin
          Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
          if PointDistance(GetPlayer.Position, (CursorObject as TMissile).Position) <= GetPlayer.GetWeaponActionRange(Weapon) then
          begin
            SelectedWeapons[Index] := False;
            Weapon.Target := CursorObject;
            Mode := 1;
          end
          else if Mode = 0 then
          begin
            Mode := 2;
            OutOfRange := True;
          end;
        end;
      Galaxy.PrimeIntegrityChecksum(60);
      if Mode = 1 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotSet'))
      else if Mode = 2 then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotOutRange'));
      RebuildTargetMarkers;
    end;
  end;
  ScannerSelectionActive := False;
  TalkSelectionActive := False;
  InterceptorSelectionActive := False;
  CustomSelectionActive := False;
  for Index := 0 to 4 do
  begin
    if SelectedWeapons[Index] then Dec(SelectedCount);
    SelectedWeapons[Index] := False;
  end;
  if HadWeapons and (SelectedCount <= 0) and not OutOfRange then ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotCancel'));
  if ScanUnresolved then ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanImpossible'));
  if TalkUnresolved then ShowLargeHelp(LookupLocalizedTextByKey('Help.TalkImpossible'));
  RefreshActionRanges;
  RefreshWeaponButtons;
  UpdateActionCursor(False);
end;
{ @end $7AF0E8 }

{ @routine $7B16CC TfStarMap_MapMiddleButtonDown }
procedure TfStarMap.MapMiddleButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Vector: TPointF;
  Scale: Single;
  Planet: TPlanet;
  Ship: TShip;
  Hole: THole;
  Destination: TPointF;
  FollowMode: Integer;
begin
  if not MainPanel.NavigationLocked and not ShipScreen.FlagD4 and not IsMapPointBlocked(Sender, Point) then
  begin
    Destination := PointToPointF(MapControls.ToLocalPoint(Point));
    if (CursorObject is THole) and not GetPlayer.NoJump and ((CursorObject as THole).ArcadeMapName <> 'NoEntry') then
    begin
      Hole := CursorObject as THole;
      ClearPathOverlay(True);
      Galaxy.CheckIntegrityChecksum(61);
      PendingPlayerFollowTarget := nil;
      GetPlayer.OrderJumpHole(Hole, False);
      GetPlayer.OrderDestination := Destination;
      GetPlayer.BuildOrderMovementPath(999999);
      Galaxy.PrimeIntegrityChecksum(62);
    end
    else if (CursorObject <> nil) and
      (((CursorObject is TRuins) and (CursorObject as TRuins).CanDock(GetPlayer)) or
       ((CursorObject = TerronShip) and (Galaxy.TerronLandingLockTurn > 0))) then
    begin
      Ship := CursorObject as TShip;
      ClearPathOverlay(True);
      Galaxy.CheckIntegrityChecksum(63);
      PendingPlayerFollowTarget := nil;
      GetPlayer.OrderLanding(Ship, False);
      GetPlayer.OrderDestination := SubtractPointsF(Destination, Ship.Position);
      Galaxy.PrimeIntegrityChecksum(64);
    end
    else if (CursorObject <> nil) and (CursorObject is TShip) and (GetPlayer <> CursorObject) and (RightClickOnShip <> 2) then
    begin
      ClearPathOverlay(True);
      Ship := CursorObject as TShip;
      FollowMode := 0;
      if PendingPlayerFollowTarget = Ship then FollowMode := 1
      else if (GetPlayer.Order = soFollowShip) and (GetPlayer.OrderTarget = Ship) then
      begin
        if Byte(GetPlayer.OrderStateData) = 1 then FollowMode := 3
        else FollowMode := 2;
      end;
      if FollowMode = 0 then
      begin
        FollowMode := DefaultOrder;
        if (FollowMode < 0) or (FollowMode > 3) then FollowMode := 0;
        if DefaultOrder = 0 then
        begin
          if Byte(Ship.GetRelationLevelToShip(GetPlayer)) <= 0 then FollowMode := 1
          else FollowMode := 2;
        end;
      end
      else if not SuppressMiddleFollowCycle then
      begin
        Dec(FollowMode);
        if FollowMode < 1 then FollowMode := 3;
      end;
      Galaxy.CheckIntegrityChecksum(65);
      if FollowMode = 1 then
        if not GetPlayer.CanSelectShipTarget(CursorObject as TShip) then FollowMode := 2;
      if FollowMode = 1 then
      begin
        GetPlayer.OrderNone(False);
        PendingPlayerFollowTarget := CursorObject as TShip;
        ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveAuto'));
      end
      else if FollowMode = 2 then
      begin
        PendingPlayerFollowTarget := nil;
        GetPlayer.OrderFollowShip(Ship, 0, False);
        ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveNear'));
      end
      else if FollowMode = 3 then
      begin
        PendingPlayerFollowTarget := nil;
        GetPlayer.OrderFollowShip(Ship, 1, False);
        ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveShot'));
      end;
      Galaxy.PrimeIntegrityChecksum(66);
    end
    else if (CursorObject <> nil) and (CursorObject is TPlanet) and not (CursorObject as TPlanet).NoLanding then
    begin
      Planet := CursorObject as TPlanet;
      ClearPathOverlay(True);
      Galaxy.CheckIntegrityChecksum(67);
      PendingPlayerFollowTarget := nil;
      if ((CursorObject as TPlanet).OwnerId <> Byte(oiDominator)) and
        ((GetPlayer.CurrentStar.Status.CustomFaction = '') or ((CursorObject as TPlanet).OwnerId = Byte(oiUninhabited))) then
      begin
        GetPlayer.OrderLanding(Planet, False);
        GetPlayer.OrderDestination := SubtractPointsF(Destination, Planet.GetPosition);
      end
      else
      begin
        GetPlayer.OrderMove(Destination, False);
        GetPlayer.BuildOrderMovementPath(999999);
      end;
      Galaxy.PrimeIntegrityChecksum(68);
    end
    else if (CursorObject <> nil) and (CursorObject is TItem) then
    begin
      Vector.X := GetPlayer.Position.X - TItem(CursorObject).Position.X;
      Vector.Y := GetPlayer.Position.Y - TItem(CursorObject).Position.Y;
      Scale := GetPlayer.GetCargoHookRange / 4 * (1 / Sqrt(Vector.X * Vector.X + Vector.Y * Vector.Y));
      Vector.X := Round(TItem(CursorObject).Position.X + Scale * Vector.X);
      Vector.Y := Round(TItem(CursorObject).Position.Y + Scale * Vector.Y);
      Galaxy.CheckIntegrityChecksum(69);
      PendingPlayerFollowTarget := nil;
      GetPlayer.OrderMove(Vector, False);
      if CanCargoHookHandleItem(TItem(CursorObject), GetPlayer) and not GetPlayer.IsRecentlyDroppedItem(TItem(CursorObject)) then
      begin
        if GetPlayer.HasPickupTarget(TItem(CursorObject)) then GetPlayer.RemovePickupTarget(TItem(CursorObject));
        GetPlayer.AddPickupTarget(TItem(CursorObject), True);
        RebuildTargetMarkers;
      end;
      Galaxy.PrimeIntegrityChecksum(70);
    end;
    if Mode = smmOrders then
    begin
      Galaxy.CheckIntegrityChecksum(71);
      GetPlayer.BuildOrderMovementPath(999999);
      Galaxy.PrimeIntegrityChecksum(72);
      BuildShipPathOverlay(GetPlayer, False, '');
      if DeferredEndTurnTimer <> nil then
      begin
        CancelCallbackTimer(DeferredEndTurnTimer);
        DeferredEndTurnTimer := nil;
      end;
      DeferredEndTurnTimer := ScheduleCallbackTimer(200, 200, DeferredEndTurn);
    end;
  end;
end;
{ @end $7B16CC }

{ @routine $7B1FA4 TfStarMap_MapRightButtonDown }
procedure TfStarMap.MapRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Index, FollowMode: Integer;
  Ship: TShip;
begin
  if not MainPanel.NavigationLocked and not ShipScreen.FlagD4 then
  begin
    HideLargeHelp;
    ScannerSelectionActive := False;
    TalkSelectionActive := False;
    InterceptorSelectionActive := False;
    CustomSelectionActive := False;
    for Index := 0 to 4 do SelectedWeapons[Index] := False;
    CursorObject := FindObjectAtCursor;
    if CursorObject = GetPlayer then
    begin
      ShipToInspect := GetPlayer;
      ShipClicked(nil);
    end
    else if (CursorObject is TTranclucator) and ((CursorObject as TTranclucator).OwnerShip = GetPlayer) then
    begin
      ShipToInspect := CursorObject as TShip;
      ShipClicked(nil);
    end
    else if (CursorObject is TShip) and not (CursorObject is TRuins) then
    begin
      Ship := CursorObject as TShip;
      if (Ship <> GetPlayer) and not ScannerSelectionActive and not TalkSelectionActive then
      begin
        if (RightClickOnShip = 0) and
          ((GetPlayer.IsEquipmentUsable(GetPlayer.GetScanner) and GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar)) or
           (Galaxy.UltraScanModEnabled = 1)) then
        begin
          if (PointDistance(GetPlayer.Position, Ship.Position) <= GetPlayer.GetRadarRange) and
            (Ship <> GetPlayer) and GetPlayer.CanScanShip(Ship) and
            ((Galaxy.UltraScanModEnabled <> 0) or GetPlayer.CanResolveObjectWithScanner(Ship) or (Ship.TypeId = stTranclucator)) then
          begin
            if Ship.NoScan or GetPlayer.ScanLocked then ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanImpossible'))
            else
            begin
              HideLargeHelp;
              ScannerSelectionActive := False;
              TalkSelectionActive := False;
              HideActionRanges;
              ShowObjectInfo(nil);
              SoundManager.PlaySound('Sound.Scan');
              SetCursorActive(False);
              Present;
              CaptureScreenBackground(True, 0);
              SetCursorActive(True);
              ScannerTarget := CursorObject;
              ScannerReturnScreenId := FormToId(Self);
              RequestedScreenId := screenScanner;
              RequestClose(1);
            end;
          end
          else if CursorObject = GetPlayer then
          begin
            // Kept by the native routine even after the earlier player-object branch.
            ShipToInspect := GetPlayer;
            ShipClicked(nil);
          end
          else
          begin
            if PointDistance(GetPlayer.Position, Ship.Position) > GetPlayer.GetRadarRange then
              ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanOutRange'))
            else if (CursorObject <> GetPlayer) and not (CursorObject is TRuins) and
              not GetPlayer.CanResolveObjectWithScanner(CursorObject) and (Ship.TypeId <> stTranclucator) then
              ShowLargeHelp(LookupLocalizedTextByKey('Help.ScanPowerLow'));
          end;
        end
        else if (RightClickOnShip = 1) and GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar) then
        begin
          if (PointDistance(GetPlayer.Position, Ship.Position) <= GetPlayer.GetRadarRange) and
            (CursorObject <> GetPlayer) and not ((CursorObject is TKling) and (CursorObject as TKling).IsProgramActive(prgDisconnection)) then
          begin
            if Ship.NoTalk or GetPlayer.TalkLocked then ShowLargeHelp(LookupLocalizedTextByKey('Help.TalkImpossible'))
            else
            begin
              HideLargeHelp;
              TalkShip := Ship;
              TalkScripted := False;
              ScriptDialogIndex := -1;
              Galaxy.CheckIntegrityChecksum(73);
              RunTalkDialogs;
              ClearPathOverlay(True);
              GetPlayer.BuildOrderMovementPath(999999);
              Galaxy.PrimeIntegrityChecksum(74);
              BuildShipPathOverlay(GetPlayer, False, '');
              BreakUiMessage;
            end;
          end
          else if PointDistance(GetPlayer.Position, Ship.Position) > GetPlayer.GetRadarRange then
            ShowLargeHelp(LookupLocalizedTextByKey('Help.TalkOutRange'));
        end
        else if RightClickOnShip = 2 then
        begin
          ClearPathOverlay(True);
          FollowMode := 0;
          if PendingPlayerFollowTarget = Ship then FollowMode := 1
          else if (GetPlayer.Order = soFollowShip) and (GetPlayer.OrderTarget = Ship) then
          begin
            if (Byte(GetPlayer.OrderStateData) = 1) and GetPlayer.CanSelectShipTarget(Ship) then FollowMode := 3
            else FollowMode := 2;
          end;
          if FollowMode = 0 then
          begin
            FollowMode := DefaultOrder;
            if (FollowMode < 0) or (FollowMode > 3) then FollowMode := 0;
            if DefaultOrder = 0 then
            begin
              if Byte(Ship.GetRelationLevelToShip(GetPlayer)) <= 0 then FollowMode := 1
              else FollowMode := 2;
            end;
          end
          else
          begin
            Inc(FollowMode);
            if FollowMode > 3 then FollowMode := 1;
          end;
          if not GetPlayer.CanSelectShipTarget(Ship) and (FollowMode = 3) then FollowMode := 1;
          Galaxy.CheckIntegrityChecksum(75);
          if FollowMode = 1 then
            if not GetPlayer.CanSelectShipTarget(CursorObject as TShip) then FollowMode := 2;
          if FollowMode = 1 then
          begin
            GetPlayer.OrderNone(False);
            PendingPlayerFollowTarget := CursorObject as TShip;
            ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveAuto'));
          end
          else if FollowMode = 2 then
          begin
            PendingPlayerFollowTarget := nil;
            GetPlayer.OrderFollowShip(Ship, 0, False);
            ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveNear'));
          end
          else if FollowMode = 3 then
          begin
            PendingPlayerFollowTarget := nil;
            GetPlayer.OrderFollowShip(Ship, 1, False);
            ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveShot'));
          end;
          Galaxy.PrimeIntegrityChecksum(76);
          BuildShipPathOverlay(GetPlayer, False, '');
        end;
      end;
    end
    else if ((CursorObject is TPlanet) and ((CursorObject as TPlanet).OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and
      ((CursorObject as TPlanet).CurrentStar.Status.CustomFaction = '') and
      (PointDistance(GetPlayer.Position, (CursorObject as TPlanet).GetPosition) <= GetPlayer.GetRadarRange)) or
      ((CursorObject is TRuins) and (CursorObject as TRuins).CanDock(GetPlayer) and
       not (CursorObject as TRuins).NoTalk and
       (PointDistance(GetPlayer.Position, (CursorObject as TRuins).Position) <= GetPlayer.GetRadarRange)) then
    begin
      AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, GoodsShopScreen.BuildPriceText(CursorObject), GetPriceSnapshotKey(CursorObject));
      SoundManager.PlaySound('Sound.UserMsgAdd');
      MainPanel.RebuildMessageButtons(False);
    end;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7B1FA4 }

{ @routine $7B2B84 TfStarMap_MapMouseMove }
procedure TfStarMap.MapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not MainPanel.NavigationLocked and not ShipScreen.FlagD4 then
  begin
    RefreshActionRanges;
    if PtInRect(ScrollInteriorRect, Point) then UpdateActionCursor(False);
    if not Sender.IsOccludedAtPoint(Point) then
    begin
      if (KeyState and MK_RBUTTON) = MK_RBUTTON then ShowObjectInfo(FindObjectAtCursor)
      else if not PtInRect(ScrollInteriorRect, Point) then
      begin
        if not IsCursorImageSelected('Scroll') then SetCursorByName('Scroll');
        ShowObjectInfo(nil);
      end
      else
      begin
        if not ScrollLeftHeld and not ScrollRightHeld and not ScrollUpHeld and not ScrollDownHeld then
          ShowObjectInfo(FindObjectAtCursor)
        else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
      end;
    end;
  end;
end;
{ @end $7B2B84 }

{ @routine $7B2CF0 TfStarMap_OrderKeyDown }
procedure TfStarMap.OrderKeyDown(Sender: TObjectGI; Key: Cardinal);
var
  Index: Integer;
  Weapon: TWeapon;
  CanAfterburn: Boolean;
  Binding: TScriptShip;
begin
  if not MainPanel.NavigationLocked and not ShipScreen.FlagD4 and
    not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
  begin
    DisplayedObject := nil;
    if Key = Ord('I') then ScannerClicked(nil)
    else if Key = Ord('T') then TalkClicked(nil)
    else if (Key >= Ord('1')) and (Key < Ord('6')) then
    begin
      Index := Key - Ord('1');
      Galaxy.CheckIntegrityChecksum(77);
      TalkSelectionActive := False;
      ScannerSelectionActive := False;
      InterceptorSelectionActive := False;
      CustomSelectionActive := False;
      Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
      if not GetPlayer.IsEquipmentUsable(Weapon) or
        ((Byte(Weapon.GetWeaponInfo.ShotType) in [Ord(wstTorpedo)..Ord(wstRocket)]) and (Weapon.Ammo <= 0)) then SelectedWeapons[Index] := False
      else
      begin
        Weapon.Target := nil;
        SelectedWeapons[Index] := not SelectedWeapons[Index];
      end;
      Galaxy.PrimeIntegrityChecksum(78);
      RebuildTargetMarkers;
      RefreshActionRanges;
      RefreshWeaponButtons;
      UpdateActionCursor(False);
    end
    else if Key = VK_OEM_3 then
    begin
      TalkSelectionActive := False;
      ScannerSelectionActive := False;
      InterceptorSelectionActive := False;
      CustomSelectionActive := False;
      SelectAllUsableWeapons;
      RebuildTargetMarkers;
      RefreshActionRanges;
      RefreshWeaponButtons;
      UpdateActionCursor(False);
    end
    else if Key = Ord('B') then
    begin
      if (GetPlayer <> nil) and (GetPlayer.GetHull.CapitalShip > 0) then
      begin
        Galaxy.CheckIntegrityChecksum(401);
        GetPlayer.EnterRuinsMode(0);
        Galaxy.PrimeIntegrityChecksum(402);
      end;
    end
    else if Key = Ord('N') then
    begin
      if (GetPlayer <> nil) and GetPlayer.GetHull.InterceptorsEnabled then SelectInterceptorTarget;
    end
    else if (Key = VK_OEM_PLUS) or (Key = VK_ADD) then
    begin
      SelectUntargetedWeapons;
      RebuildTargetMarkers;
      RefreshActionRanges;
      RefreshWeaponButtons;
      UpdateActionCursor(False);
    end
    else if Key = VK_SUBTRACT then
    begin
      Galaxy.CheckIntegrityChecksum(79);
      for Index := 0 to 4 do
      begin
        SelectedWeapons[Index] := False;
        Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
        if Weapon <> nil then
        begin
          Weapon.Target := nil;
          ShowLargeHelp(LookupLocalizedTextByKey('Help.ShotCancel'));
        end;
      end;
      Galaxy.PrimeIntegrityChecksum(80);
      RebuildTargetMarkers;
      RefreshActionRanges;
      RefreshWeaponButtons;
      UpdateActionCursor(False);
    end
    else if Key = Ord('S') then
    begin
      if Galaxy.SpecialSimulationMode = 0 then
      begin
        ShipToInspect := GetPlayer;
        ShipClicked(nil);
      end;
    end
    else if Key = Ord('M') then
    begin
      if Galaxy.SpecialSimulationMode = 0 then GalaxyClicked(nil);
    end
    else if Key = Ord('R') then MainPanel.QuestClicked(nil)
    else if Key = VK_ESCAPE then MainPanel.MenuClicked(nil)
    else if Key = Ord('H') then OpenFilmHistoryClicked(nil)
    else if Key = Ord('W') then ToggleWeaponPanelClicked(nil)
    else if (Key = Ord('F')) and (Mode = smmOrders) then
    begin
      CanAfterburn := (GetPlayer.GetSlotCount(sskAfterburner) > 0) and
        GetPlayer.IsEquipmentUsable(GetPlayer.GetEngine) and GetPlayer.InNormalSpace;
      if not GetPlayer.AfterburnerActive and CanAfterburn then
      begin
        SoundManager.PlaySound('Sound.ForsageOn');
        ShowLargeHelp(LookupLocalizedTextByKey('Help.ForsageOn'));
        ClearPathOverlay(True);
        Galaxy.CheckIntegrityChecksum(81);
        GetPlayer.AfterburnerActive := True;
        GetPlayer.RefreshDerivedStats(True);
        GetPlayer.BuildOrderMovementPath(999999);
        if GetPlayer.ScriptShipBindings <> nil then
        begin
          Index := GetPlayer.ScriptShipBindings.Count - 1;
          while Index >= 0 do
          begin
            if Index >= GetPlayer.ScriptShipBindings.Count then Index := GetPlayer.ScriptShipBindings.Count - 1
            else
            begin
              Binding := TScriptShip(GetPlayer.ScriptShipBindings[Index]);
              if Binding.Script <> nil then Binding.Script.RunShipState(Binding);
              Dec(Index);
            end;
          end;
        end;
        Galaxy.PrimeIntegrityChecksum(82);
        BuildShipPathOverlay(GetPlayer, False, '');
      end
      else if GetPlayer.AfterburnerActive then
      begin
        SoundManager.PlaySound('Sound.ForsageOff');
        ShowLargeHelp(LookupLocalizedTextByKey('Help.ForsageOff'));
        ClearPathOverlay(True);
        Galaxy.CheckIntegrityChecksum(83);
        GetPlayer.AfterburnerActive := False;
        GetPlayer.RefreshDerivedStats(True);
        GetPlayer.BuildOrderMovementPath(999999);
        if GetPlayer.ScriptShipBindings <> nil then
        begin
          Index := GetPlayer.ScriptShipBindings.Count - 1;
          while Index >= 0 do
          begin
            if Index >= GetPlayer.ScriptShipBindings.Count then Index := GetPlayer.ScriptShipBindings.Count - 1
            else
            begin
              Binding := TScriptShip(GetPlayer.ScriptShipBindings[Index]);
              if Binding.Script <> nil then Binding.Script.RunShipState(Binding);
              Dec(Index);
            end;
          end;
        end;
        Galaxy.PrimeIntegrityChecksum(84);
        BuildShipPathOverlay(GetPlayer, False, '');
      end;
    end;
  end;
end;
{ @end $7B2CF0 }

{ @routine $7B34E0 TfStarMap_OrderKeyUp }
procedure TfStarMap.OrderKeyUp(Sender: TObjectGI; Key: Cardinal);
begin
  // The native body retains these guard reads despite having no guarded action.
  if not MainPanel.NavigationLocked and not ShipScreen.FlagD4 then
  begin
  end;
end;
{ @end $7B34E0 }

{ @routine $7B3510 TfStarMap_SelectAllUsableWeapons }
procedure TfStarMap.SelectAllUsableWeapons;
var
  Index: Integer;
  Weapon: TWeapon;
begin
  Galaxy.CheckIntegrityChecksum(85);
  for Index := 0 to 4 do
  begin
    Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
    if not GetPlayer.IsEquipmentUsable(Weapon) or
      ((Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Ammo <= 0)) then
      SelectedWeapons[Index] := False
    else
    begin
      Weapon.Target := nil;
      SelectedWeapons[Index] := True;
    end;
  end;
  Galaxy.PrimeIntegrityChecksum(86);
end;
{ @end $7B3510 }

{ @routine $7B35BC TfStarMap_SelectUntargetedWeapons }
procedure TfStarMap.SelectUntargetedWeapons;
var
  Index: Integer;
  Weapon: TWeapon;
begin
  for Index := 0 to 4 do
  begin
    Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
    if not GetPlayer.IsEquipmentUsable(Weapon) or
      ((Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Ammo <= 0)) then
      SelectedWeapons[Index] := False
    else
    begin
      if Weapon.Target = nil then SelectedWeapons[Index] := True;
    end;
  end;
end;
{ @end $7B35BC }

{ @routine $7B3648 TfStarMap_ShowObjectInfo }
procedure TfStarMap.ShowObjectInfo(Obj: TObject);
const
  WearableItemTypes = [0..79] - [0..7,9,23..25,35..38,42,69..72,74..79];
var
  Panel: TPanelGI;
  Objects: TList;
  I, J, RowHeight, RowX: Integer;
  IconInset: Cardinal;
  NameWidth, DetailWidth, StatusCount: Integer;
  Distance: Single;
  OwnerId: Byte;
  ImagePath, Text, ColorTag: WideString;
  Child: TObjectGI;
  DamageName, DamageValue: TLabelGI;
  ItemObject: TItem;
  ActivePanel: TObjectGI;
  BarWidth, CapWidth, MinimumWidth: Integer;
  CustomInfo: TCustomSystemInfo;
  Images: WideString;
begin
  if (Obj is TStar) and (TerronShip <> nil) and (TerronShip.CurrentStar = Obj) and
    (Galaxy.TerronToStarTurn >= $40000000) then Obj := TerronShip;
  if (TerronShip <> nil) and (Obj = TerronShip) and (Galaxy.TerronToStarTurn >= $40000000) then
    HitObjectPosition := Classes.Point(Round(TerronShip.CurrentStar.Graphic.Position.X) - GetMapCenter.X,
      Round(TerronShip.CurrentStar.Graphic.Position.Y) - GetMapCenter.Y);
  if (Obj <> nil) and (Obj is TAsteroid) then ShowAsteroidPath(Obj as TAsteroid)
  else ClearAsteroidPath;
  if (Obj = nil) or (DisplayedObject <> Obj) then
  begin
    if (Obj <> nil) and (Obj is TShip) then TShip(Obj).ScriptItemsAct(satOnShowingShipInfo, nil, nil, 0);
    if (Obj <> nil) and (Obj is TStar) and (GetPlayer <> nil) then GetPlayer.ScriptItemsAct(satOnShowingStarInfo, Obj, nil, 0);
    if Obj = nil then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(False);
      ClearAsteroidPath;
      ClearPathOverlay(False);
      DisplayedObject := nil;
    end
    else if (GetPlayer = nil) or
      ((Obj is TItem) and (PointDistance(TItem(Obj).Position, GetPlayer.Position) > GetPlayer.GetRadarRange)) or
      ((Obj is TShip) and ((GetPlayer.CurrentStar <> TShip(Obj).CurrentStar) or
      (TShip(Obj).InHyperspace and (Obj <> TerronShip)) or
      (PointDistance(TShip(Obj).Position, GetPlayer.Position) > GetPlayer.GetRadarRange))) or
      ((Obj is TAsteroid) and (PointDistance(TAsteroid(Obj).Position, GetPlayer.Position) > GetPlayer.GetRadarRange)) or
      ((Obj is TMissile) and (PointDistance(TMissile(Obj).Position, GetPlayer.Position) > GetPlayer.GetRadarRange)) or
      (Obj is THole) or (Obj is TPlanet) then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(True);
      if Obj is TItem then
      begin
        if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
        begin
          ItemObject := Obj as TItem;
          if ItemObject.ScriptItem <> nil then TScriptItem(ItemObject.ScriptItem).RunActionCode(satOnShowingItemInfo, nil, PlayerStar, nil, 0);
          if ItemObject is TEquipmentWithActCode then RunItemConfigActionCode(ItemObject, satOnShowingItemInfo, nil, PlayerStar, nil, 0);
        end;
        GetByName('InfoStdGB').SetActive(False);
        with GetByName('InfoStdImage') as TImageGI do
        begin
          SetActive(True);
          if Obj is TGoods then SetImagePath('GI,' + GetItemTypeBitmapPath(TItem(Obj).ItemType))
          else SetImagePath('GI,' + TItem(Obj).GetBitmapResourceName + 's');
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
        if Obj is TGoods then
        begin
          (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(GoodsMarket[Ord(TItem(Obj).ItemType)].DisplayName, InfoNameColorTag));
          (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('Items.Goods.Text.' + IntToStr(Ord(TItem(Obj).ItemType) + 1)));
        end
        else
        begin
          (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(LocalizedText('FormInfo.ContainerName'), InfoNameColorTag));
          (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
        end;
        (GetByName('InfoItemSize') as TLabelGI).SetText('???');
        (GetByName('InfoItemPrice') as TLabelGI).SetText('???');
        ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      end
      else if Obj is TShip then
      begin
        if (Obj as TShip).Graphic is TShip2SE then
        begin
          GetByName('InfoStdImage').SetActive(False);

          with GetByName('InfoStdGB') as TGraphBufGI do
          begin
            ImagePath := (Obj as TShip).GetShipPortraitImagePath;
            SetActive(ImagePath <> '');
            if Active then
            begin
              SourceHasPerPixelAlpha := True;
              LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(ImagePath, 1, ','), GraphBuf);
              if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
              begin
                if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                  GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
                else
                  GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
              end;
              SetImageKindX(ikxCenter);
              SetImageKindY(ikyCenter);
              SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
            end;
          end;
        end
        else
        begin
          GetByName('InfoStdImage').SetActive(False);
          with GetByName('InfoStdGB') as TGraphBufGI do
          begin
            SetActive(True);
            SourceHasPerPixelAlpha := True;
            LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(((Obj as TShip).Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf);

            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
            SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
          end;
        end;
        (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor((Obj as TShip).GetFullName(' '), InfoNameColorTag));

        if Obj is TShip then
        if (Obj as TShip).PartnerShip = GetPlayer then
          (GetByName('InfoStdName') as TLabelGI).SetText((GetByName('InfoStdName') as TLabelGI).GetText + #13#10 + WrapTextInColor(LookupLocalizedTextByKey('FormInfo.Partner'), '<color=255,240,100>'));

        (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
        ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      end
      else if Obj is TAsteroid then
      begin
        GetByName('InfoStdImage').SetActive(False);
        with GetByName('InfoStdGB') as TGraphBufGI do
        begin
          SetActive(True);
          SourceHasPerPixelAlpha := True;
          LoadGaiFrameToGraphBuf(TAsteroidSE(TAsteroid(Obj).GraphObject).ImagePath, GraphBuf, TAsteroid(Obj).Id);

          if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
          begin
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
            else
              GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
          end;
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
        (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor((Obj as TAsteroid).GetDisplayName, InfoNameColorTag));
        (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
        ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      end
      else if Obj is TMissile then
      begin
        GetByName('InfoStdImage').SetActive(False);
        with GetByName('InfoStdGB') as TGraphBufGI do
        begin
          SetActive(True);
          SourceHasPerPixelAlpha := True;
          LoadGiByPathIntoGraphBuf('Bm.Missile.w' + (Obj as TMissile).GetGraphSuffix + '_' + GiResourceSuffix + 'i', GraphBuf);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
        (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor((Obj as TMissile).GetDisplayName, InfoNameColorTag));
        (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
        ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      end
      else if Obj is THole then
      begin
        GetByName('InfoStdImage').SetActive(False);
        with GetByName('InfoStdGB') as TGraphBufGI do
        begin
          SetActive(True);
          SourceHasPerPixelAlpha := True;
          LoadGaiFrameToGraphBuf(THoleSE(THole(Obj).Graphic).ImagePath, GraphBuf, 32);

          if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
          begin
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
            else
              GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
          end;
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
        (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(LocalizedText(THoleSE(THole(Obj).Graphic).NameTextPath), InfoNameColorTag));
        (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText(THoleSE(THole(Obj).Graphic).InfoTextPath));
        ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      end
      else if Obj is TPlanet then
      begin
        if ((Obj as TPlanet).OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and not (Obj as TPlanet).IsMainPiratePlanet and
          (TPlanet(Obj).CurrentStar.Status.CustomFaction = '') then
        begin
          if DisplayedObject = Obj then Exit;
          PlanetInfoPanel.SetActive(True);
          StandardInfoPanel.SetActive(False);
          (GetByName('InfoPlanetName') as TLabelGI).SetText(WrapTextInColor((Obj as TPlanet).Name, InfoNameColorTag));
          if (TPlanet(Obj).OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and (TPlanet(Obj).CurrentStar.Status.CustomFaction = '') then
          begin
            with GetByName('InfoPlanetEmRace') as TImageGI do
            begin
              SetImagePath(GetFactionEmblemPath((Obj as TPlanet).GetFactionResourceName));
              SetImageKindX(ikxCenter);
              SetImageKindY(ikyCenter);
              SetActive(True);
            end;
          end
          else GetByName('InfoPlanetEmRace').SetActive(False);
          with GetByName('InfoPlanetImage') as TGraphBufGI do
          begin
            SourceHasPerPixelAlpha := True;
            TPlanetSE((Obj as TPlanet).Graphic).RenderToBuffer(Self, GraphBuf, False);

            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
          end;
          if (Obj as TPlanet).IsMainPiratePlanet then
            (GetByName('InfoPlanetOwner') as TLabelGI).SetText(OwnerInfo[(Obj as TPlanet).OwnerId].DisplayName)
          else (GetByName('InfoPlanetOwner') as TLabelGI).SetText((Obj as TPlanet).GetNativeRaceName);
          (GetByName('InfoPlanetPop') as TLabelGI).SetText(IntToStr(Round((Obj as TPlanet).Population / 1000)));
          (GetByName('InfoPlanetEco') as TLabelGI).SetText(PlanetEconomyInfo[Ord((Obj as TPlanet).Economy)].DisplayName);
          (GetByName('InfoPlanetGov') as TLabelGI).SetText((Obj as TPlanet).GetGovernmentName);
          (GetByName('InfoPlanetRel') as TLabelGI).SetText((Obj as TPlanet).GetRelationLevelTextToShip(GetPlayer));
          ShipScreen.LayoutObjectInfo(PlanetInfoPanel as TWindowGI, GetByName('InfoPlanetName') as TLabelGI,
            GetByName('IPOwner') as TLabelGI,
            GetByName('InfoPlanetOwner') as TLabelGI,
            GetByName('IPPop') as TLabelGI,
            GetByName('InfoPlanetPop') as TLabelGI,
            GetByName('IPEco') as TLabelGI,
            GetByName('InfoPlanetEco') as TLabelGI,
            GetByName('IPGov') as TLabelGI,
            GetByName('InfoPlanetGov') as TLabelGI,
            GetByName('IPRel') as TLabelGI,
            GetByName('InfoPlanetRel') as TLabelGI,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            GetByName('InfoPlanetEmRace'),
            True,
            0);
        end
        else
        begin
          GetByName('InfoStdImage').SetActive(False);
          with GetByName('InfoStdGB') as TGraphBufGI do
          begin
            SetActive(True);
            SourceHasPerPixelAlpha := True;
            TPlanetSE((Obj as TPlanet).Graphic).RenderToBuffer(Self, GraphBuf, False);

            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
            SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
          end;
          (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor((Obj as TPlanet).Name, InfoNameColorTag));
          (GetByName('InfoStdText') as TLabelGI).SetText((Obj as TPlanet).GetInfoText(False));
          ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
        end;
      end;
      DisplayedObject := Obj;
    end
    else if Obj is TItem then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(True);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(False);

      if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
      begin
        ItemObject := Obj as TItem;
        if ItemObject.ScriptItem <> nil then TScriptItem(ItemObject.ScriptItem).RunActionCode(satOnShowingItemInfo, nil, PlayerStar, nil, 0);
        if ItemObject is TEquipmentWithActCode then RunItemConfigActionCode(ItemObject, satOnShowingItemInfo, nil, PlayerStar, nil, 0);
      end;
      with GetByName('InfoItemImage') as TImageGI do
      begin
        if Obj is TGoods then SetImagePath('GI,' + GetItemTypeBitmapPath(TItem(Obj).ItemType))
        else SetImagePath('GI,' + TItem(Obj).GetBitmapResourceName + 's');
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
      end;
      if Obj is TGoods then
      begin
        (GetByName('InfoItemName') as TLabelGI).SetText(WrapTextInColor(GoodsMarket[Ord(TItem(Obj).ItemType)].DisplayName, InfoNameColorTag));
        (GetByName('InfoItemText') as TLabelGI).SetText(LocalizedText('Items.Goods.Text.' + IntToStr(Ord(TItem(Obj).ItemType) + 1)));
      end
      else
      begin
        (GetByName('InfoItemName') as TLabelGI).SetText('');
        (GetByName('InfoItemName') as TLabelGI).SetText(WrapTextInColor(TItem(Obj).GetDisplayName, InfoNameColorTag));
        (GetByName('InfoItemText') as TLabelGI).SetText(TItem(Obj).GetInfoText('<color=255,240,100>', nil));
      end;
      (GetByName('InfoItemSize') as TLabelGI).SetText(IntToStr(TItem(Obj).Weight));
      (GetByName('InfoItemPrice') as TLabelGI).SetText(IntToStr(TItem(Obj).Cost));
      with GetByName('InfoItemEmRace') as TImageGI do
      begin
        SetImagePath(GetFactionEmblemPath((Obj as TItem).GetOwnerConfigName));
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      if not ((Byte((Obj as TItem).ItemType) in WearableItemTypes) or ((Obj as TItem).ItemType = t_Hull)) then
      begin
        with GetByName('InfoDurable') as TImageGI do Parent.Parent.SetActive(False);
        MinimumWidth := 0;
      end
      else
      begin
        if Obj is THull then BarWidth := Round(Sqrt((Obj as TItem).Weight / HullBaseSize / Max(0.1, (Obj as THull).GetFragilityFactor([]))) * 64)
        else BarWidth := Round(64 / Max(0.1, (Obj as TEquipment).GetFragilityFactor([])));
        BarWidth := Min(192, Max(32, BarWidth));
        with GetByName('InfoDurableLeft') as TImageGI do
        begin
          CapWidth := GetContentSize.X;
          MinimumWidth := CapWidth * 2 + BarWidth + LocalPosition.X + Parent.LocalPosition.X + Parent.Parent.LocalPosition.X * 2;
        end;
        with GetByName('InfoDurable') as TImageGI do
        begin
          Parent.Parent.SetActive(True);
          Parent.Parent.SetSize(Classes.Point(CapWidth * 2 + BarWidth, Parent.Parent.ClientSize.Y));
          Parent.SetSize(Classes.Point(BarWidth + 2, Parent.Parent.ClientSize.Y));
          if (Obj as TItem).ItemType = t_Hull then
            SetPosition(Classes.Point(Round((Obj as THull).HullPoints / (Obj as THull).Weight * BarWidth) - (GetContentSize.X - 5), LocalPosition.Y))
          else SetPosition(Classes.Point(Round((Obj as TEquipment).ConditionPercent / 100 * BarWidth) - (GetContentSize.X - 5), LocalPosition.Y));
        end;
        with GetByName('InfoDurableRight') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X, LocalPosition.Y));
          Parent.SetPosition(Classes.Point(CapWidth, Parent.LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
        end;
        with GetByName('InfoDurableBack') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X, LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
        end;
      end;
      ShipScreen.LayoutItemInfo(ItemInfoWindow, GetByName('InfoItemName') as TLabelGI, GetByName('InfoItemText') as TLabelGI, True, True, MinimumWidth);
      GetByName('InfoItemSize').SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
      GetByName('InfoItemPrice').SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
      GetByName('InfoItemEmRace').SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
      ShipScreen.LayoutItemInfo(ItemInfoWindow, GetByName('InfoItemName') as TLabelGI, GetByName('InfoItemText') as TLabelGI, True, True, 0);
      DisplayedObject := Obj;
    end
    else if Obj is TShip then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(True);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(False);
      if GetPlayer <> Obj then
      begin
        (GetByName('InfoShipName') as TLabelGI).SetText(WrapTextInColor((Obj as TShip).GetFullName(' '), InfoNameColorTag));

        if Obj is TShip then
        if (Obj as TShip).PartnerShip = GetPlayer then
          (GetByName('InfoShipName') as TLabelGI).SetText((GetByName('InfoShipName') as TLabelGI).GetText + #13#10 + WrapTextInColor(LookupLocalizedTextByKey('FormInfo.Partner'), '<color=255,240,100>'));
        if (Obj is TKling) and ((Obj as TKling).ActiveProgramAppliedTurn > 0) and
          ((Obj as TKling).ActiveProgramId in [6..11]) then
          (GetByName('InfoShipName') as TLabelGI).SetText((GetByName('InfoShipName') as TLabelGI).GetText + #13#10 +
            WrapTextInColor(LocalizedText('Programms.' + ProgramNames[(Obj as TKling).ActiveProgramId] + '.AddToShipInfo'), '<color=255,0,0>'));
      end
      else
        (GetByName('InfoShipName') as TLabelGI).SetText(WrapTextInColor((Obj as TShip).GetFullName(' '), InfoNameColorTag));
      if TShip(Obj).GetFactionNameKey <> 'None' then
      begin
        with GetByName('InfoShipEmRace') as TImageGI do
        begin
          SetImagePath(GetFactionEmblemPath((Obj as TShip).GetFactionNameKey));
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
          SetActive(True);
        end;
      end
      else GetByName('InfoShipEmRace').SetActive(False);
      if (Obj as TShip).Graphic is TShip2SE then
      begin
        with GetByName('InfoShipImage2') as TGraphBufGI do
        begin
          ImagePath := (Obj as TShip).GetShipPortraitImagePath;
          SetActive(ImagePath <> '');
          if Active then
          begin
            SourceHasPerPixelAlpha := True;
            LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(ImagePath, 1, ','), GraphBuf);
            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
            SetImageKindX(ikxCenter);
            SetImageKindY(ikyCenter);
            SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
          end;
        end;
      end
      else
      begin
        with GetByName('InfoShipImage2') as TGraphBufGI do
        begin
          SetActive(True);
          SourceHasPerPixelAlpha := True;
          if (Obj = TerronShip) and (Galaxy.TerronToStarTurn >= $40000000) then
            LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE(TerronShip.CurrentStar.Graphic).StaticImagePath, 1, ','), GraphBuf)
          else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(((Obj as TShip).Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf);

          if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
          begin
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
            else
              GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
          end;
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
      end;
      if Obj is TRuins then
      begin
        (GetByName('ISType') as TLabelGI).SetActive(False);
        (GetByName('InfoShipType') as TLabelGI).SetActive(False);
      end
      else
      begin
        (GetByName('ISType') as TLabelGI).SetActive(True);
        (GetByName('InfoShipType') as TLabelGI).SetActive(True);
        if Obj is TRanger then (GetByName('InfoShipType') as TLabelGI).SetText((Obj as TRanger).GetCharacterName)
        else (GetByName('InfoShipType') as TLabelGI).SetText((Obj as TShip).GetLocalizedTypeName);
      end;
      (GetByName('InfoShipSpeed') as TLabelGI).SetText(IntToStr((Obj as TShip).CalculateSpeed));
      (GetByName('InfoShipDamage') as TLabelGI).SetText(WrapTextInColor('???', ''));
      if (Obj as TShip).GetHull.HullPoints <= (Obj as TShip).GetHull.Weight / 2 then ColorTag := '<color=255,166,0>'
      else ColorTag := '';
      if GetPlayer.CanResolveObjectWithScanner(Obj) or (GetPlayer = Obj) or ((Obj as TShip).PartnerShip = GetPlayer) or ((Obj as TShip).TypeId = stTranclucator) then
      begin
        Text := WrapTextInColor(IntToStr((Obj as TShip).GetHull.HullPoints), ColorTag) + '/' + IntToStr((Obj as TShip).GetHull.Weight);
        if GetPlayer.HasScannerArtefact(Obj as TShip) then
        begin
          (GetByName('InfoShipDamage') as TLabelGI).SetText((Obj as TShip).GetWeaponDamageSummary);
          Text := Text + ' + ' + WrapTextInColor((Obj as TShip).GetRepairPointsSummary, '');
        end;
        (GetByName('InfoShipSize') as TLabelGI).SetText(Text);
      end
      else (GetByName('InfoShipSize') as TLabelGI).SetText(WrapTextInColor('???', ColorTag));
      Text := IntToStr(Integer((Obj as TShip).GetDefensePercent) and $7F) + '%';
      if GetPlayer.CanResolveObjectWithScanner(Obj) or (GetPlayer = Obj) or ((Obj as TShip).PartnerShip = GetPlayer) or ((Obj as TShip).TypeId = stTranclucator) then
      begin
        Text := Text + ' + ' + WrapTextInColor(IntToStr((Obj as TShip).GetArmor), '');
        if GetPlayer.HasScannerArtefact(Obj as TShip) then Text := (Obj as TShip).GetManeuverabilitySummary + Text;
      end;
      (GetByName('InfoShipDef') as TLabelGI).SetText(Text);
      (GetByName('InfoShipRel') as TLabelGI).SetText((Obj as TShip).GetRelationLevelTextToShip(GetPlayer));
      if (GetPlayer <> Obj) and not (Obj is TRuins) and (GetPlayer.CountActiveArtefacts(Ord(t_ArtefactAnalyzer)) > 0) and GetPlayer.CanResolveObjectWithScanner(Obj) then
      begin
        (GetByName('ISWin') as TLabelGI).SetActive(True);
        (GetByName('InfoShipWin') as TLabelGI).SetActive(True);
        (GetByName('InfoShipWin') as TLabelGI).SetText(IntToStr(Integer(GetPlayer.GetWinChancePercent(Obj as TShip)) and $7F) + '%');
      end
      else
      begin
        (GetByName('ISWin') as TLabelGI).SetActive(False);
        (GetByName('InfoShipWin') as TLabelGI).SetActive(False);
      end;
      BarWidth := Round(Sqrt((Obj as TShip).GetHull.Weight / HullBaseSize / Max(0.1, (Obj as TShip).GetHull.GetFragilityFactor([]))) * 64);
      BarWidth := Min(192, Max(32, BarWidth));
      with GetByName('InfoShipDurableLeft') as TImageGI do
      begin
        CapWidth := GetContentSize.X;
        MinimumWidth := CapWidth * 2 + BarWidth + LocalPosition.X + Parent.LocalPosition.X + Parent.Parent.LocalPosition.X * 2;
      end;
      with GetByName('InfoShipDurable') as TImageGI do
      begin
        if GetPlayer.CanResolveObjectWithScanner(Obj) or (GetPlayer = Obj) or ((Obj as TShip).PartnerShip = GetPlayer) or ((Obj as TShip).TypeId = stTranclucator) then
          SetPosition(Classes.Point(Round((Obj as TShip).GetHull.HullPoints / (Obj as TShip).GetHull.Weight * BarWidth) - (GetContentSize.X - 5), LocalPosition.Y))
        else
        begin
          MinimumWidth := MinimumWidth - BarWidth + 64;
          BarWidth := 64;
          SetPosition(Classes.Point(BarWidth - (GetContentSize.X - 5), LocalPosition.Y));
        end;
        Parent.Parent.SetActive(True);
        Parent.Parent.SetSize(Classes.Point(CapWidth * 2 + BarWidth, Parent.Parent.ClientSize.Y));
        Parent.SetSize(Classes.Point(BarWidth + 2, Parent.Parent.ClientSize.Y));
      end;
      with GetByName('InfoShipDurableRight') as TImageGI do
      begin
        SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X, LocalPosition.Y));
        Parent.SetPosition(Classes.Point(CapWidth, Parent.LocalPosition.Y));
        Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
      end;
      with GetByName('InfoShipDurableBack') as TImageGI do
      begin
        SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X, LocalPosition.Y));
        Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
      end;
      DamageName := GetByName('ISDamage') as TLabelGI;
      DamageValue := GetByName('InfoShipDamage') as TLabelGI;
      if GetPlayer.HasScannerArtefact(Obj as TShip) then
      begin
        DamageName.SetActive(True);
        DamageValue.SetActive(True);
      end
      else
      begin
        DamageName.SetActive(False);
        DamageValue.SetActive(False);
        DamageName := nil;
        DamageValue := nil;
      end;
      Text := (Obj as TShip).GetCombatStatusDescription(StatusCount, False);
      if StatusCount > 0 then
      begin
        (GetByName('ISEffects') as TLabelGI).SetActive(True);
        with GetByName('InfoShipEffects') as TLabelGI do
        begin
          if GetPlayer.HasScannerArtefact(Obj as TShip) then SetText((Obj as TShip).GetCombatStatusDescription(StatusCount, True))
          else SetText(Text);
          SetSize(Classes.Point(ClientSize.X, StatusCount * GetLineHeight + 2));
          SetActive(True);
        end;
      end
      else
      begin
        (GetByName('ISEffects') as TLabelGI).SetActive(False);
        (GetByName('InfoShipEffects') as TLabelGI).SetActive(False);
      end;
      ShipScreen.LayoutObjectInfo(ShipInfoPanel as TWindowGI, GetByName('InfoShipName') as TLabelGI,
        GetByName('ISType') as TLabelGI,
        GetByName('InfoShipType') as TLabelGI,
        GetByName('ISSpeed') as TLabelGI,
        GetByName('InfoShipSpeed') as TLabelGI,
        GetByName('ISSize') as TLabelGI,
        GetByName('InfoShipSize') as TLabelGI,
        GetByName('ISDef') as TLabelGI,
        GetByName('InfoShipDef') as TLabelGI,
        DamageName,
        DamageValue,
        GetByName('ISRel') as TLabelGI,
        GetByName('InfoShipRel') as TLabelGI,
        GetByName('ISWin') as TLabelGI,
        GetByName('InfoShipWin') as TLabelGI,
        GetByName('ISEffects') as TLabelGI,
        GetByName('InfoShipEffects') as TLabelGI,
        GetByName('InfoShipEmRace'),
        True,
        MinimumWidth);
      DisplayedObject := Obj;
      if Obj is TShip then BuildShipPathOverlay(Obj as TShip, False, '')
      else ClearPathOverlay(False);
    end
    else if Obj is TStar then
    begin
      ClearPathOverlay(False);
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(True);
      StandardInfoPanel.SetActive(False);
      with GetByName('InfoStarImage') as TGraphBufGI do
      begin
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE((Obj as TStar).Graphic).StaticImagePath, 1, ','), GraphBuf);

        if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
        begin
          if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
            GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
          else
            GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
        end;
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      Panel := GetByName('InfoStarPanel') as TPanelGI;
      Panel.FreeOwnedChildren;
      Panel.SetSize(Classes.Point(StarInfoWindow.ClientSize.X - StarInfoWindow.WorkSubRect.Left - StarInfoWindow.WorkSubRect.Right, Panel.ClientSize.Y));
      Objects := TList.Create;
      for I := 0 to GetPlayer.CurrentStar.Planets.Count - 1 do Objects.Add(GetPlayer.CurrentStar.Planets[I]);
      for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
        if TObject(GetPlayer.CurrentStar.Ships[I]) is TRuins then
        if (TObject(GetPlayer.CurrentStar.Ships[I]) as TRuins).InNormalSpace then
        if ((TObject(GetPlayer.CurrentStar.Ships[I]) as TRuins).Graphic is TRuinsSE) or
          (((TObject(GetPlayer.CurrentStar.Ships[I]) as TRuins).Graphic is TShip2SE) and
          (((TObject(GetPlayer.CurrentStar.Ships[I]) as TRuins).Graphic as TShip2SE).AlternateImagePath <> '')) then
        begin
          Distance := PointDistanceSquared(TShip(GetPlayer.CurrentStar.Ships[I]).Position, MakePointF(0, 0));
          J := 0;
          while J < Objects.Count do
          begin
            if TObject(Objects[J]) is TPlanet then
            begin
              if PointDistanceSquared(TPlanet(Objects[J]).GetPosition, MakePointF(0, 0)) > Distance then Break;
            end
            else if PointDistanceSquared(TShip(Objects[J]).Position, MakePointF(0, 0)) > Distance then Break;
            Inc(J);
          end;
          Objects.Insert(J, GetPlayer.CurrentStar.Ships[I]);
        end;
      for I := 0 to GetPlayer.CurrentStar.CustomSystemInfos.Count - 1 do
      begin
        CustomInfo := GetPlayer.CurrentStar.CustomSystemInfos[I];
        Distance := Sqr(CustomInfo.Distance);
        J := 0;
        while J < Objects.Count do
        begin
          if TObject(Objects[J]) is TPlanet then
          begin
            if PointDistanceSquared(TPlanet(Objects[J]).GetPosition, MakePointF(0, 0)) > Distance then Break;
          end
          else if TObject(Objects[J]) is TRuins then
          begin
            if PointDistanceSquared(TShip(Objects[J]).Position, MakePointF(0, 0)) > Distance then Break;
          end
          else if Sqr(TCustomSystemInfo(Objects[J]).Distance) > Distance then Break;
          Inc(J);
        end;
        Objects.Insert(J, CustomInfo);
      end;
      RowHeight := GiScalePixels(20);
      NameWidth := GiScalePixels(100);
      DetailWidth := GiScalePixels(100);
      for I := 0 to Objects.Count - 1 do
        with TLabelGI.Create(Panel) do
        begin
          SetFontName(NormalFontName);
          SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
          SetSize(Classes.Point(1, RowHeight));
          SetPosition(Classes.Point(0, RowHeight * I));
          SetWordWrapEnabled(False);
          SetTextAlignX(taxAuto);
          SetTextAlignY(tayCenterEx);
          if TObject(Objects[I]) is TPlanet then SetText(TPlanet(Objects[I]).Name)
          else if TObject(Objects[I]) is TShip then SetText(TShip(Objects[I]).Name)
          else SetText(TCustomSystemInfo(Objects[I]).Name);
          NameWidth := Max(NameWidth, ClientSize.X);
        end;
      Child := Panel.FirstChild;
      while Child <> nil do
      begin
        if Child is TLabelGI then
          with Child as TLabelGI do
          begin
            SetTextAlignX(taxRight);
            SetSize(Classes.Point(NameWidth, RowHeight));
          end;
        Child := Child.NextSibling;
      end;
      for I := 0 to Objects.Count - 1 do
      begin
        with TGraphBufGI.Create(Panel, False) do
        begin
          IconInset := 0;
          if TObject(Objects[I]) is TPlanet then
          begin
            if (TObject(Objects[I]) as TPlanet).Radius < 70 then IconInset := 4
            else if (TObject(Objects[I]) as TPlanet).Radius < 80 then IconInset := 3
            else if (TObject(Objects[I]) as TPlanet).Radius < 90 then IconInset := 2
            else if (TObject(Objects[I]) as TPlanet).Radius < 100 then IconInset := 1
            else IconInset := 0;
          end;
          SourceHasPerPixelAlpha := True;
          SetPosition(Classes.Point(NameWidth + 5 + 1 + (IconInset shr 1), RowHeight * I + 1 + (IconInset shr 1)));
          SetSize(Classes.Point(RowHeight - 2 - IconInset, RowHeight - 2 - IconInset));
          if TObject(Objects[I]) is TPlanet then
          begin
            TPlanetSE(TPlanet(Objects[I]).Graphic).RenderToBuffer(Self, GraphBuf, True);
            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
          end
          else if TObject(Objects[I]) is TRuins then
          begin
            if TShip(Objects[I]).Graphic is TRuinsSE then
              LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TShip(Objects[I]).Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf)
            else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TShip(Objects[I]).Graphic as TShip2SE).AlternateImagePath, 1, ','), GraphBuf);
            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
          end
          else if TCustomSystemInfo(Objects[I]).Icon <> '' then
          begin
            LoadGiByPathIntoGraphBuf(TCustomSystemInfo(Objects[I]).Icon, GraphBuf);
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
            else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
          end;
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
        end;
        if TObject(Objects[I]) is TPlanet then OwnerId := TPlanet(Objects[I]).OwnerId
        else if TObject(Objects[I]) is TRuins then OwnerId := TShip(Objects[I]).OwnerId
        else OwnerId := Byte(oiUninhabited);
        if TObject(Objects[I]) is TRuins then
        begin
          with TLabelGI.Create(Panel) do
          begin
            if GiResourceVariant = 2 then SetFontName(MiniFontName)
            else SetFontName(SmallFontName);
            SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
            SetSize(Classes.Point(1, RowHeight));
            SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
            SetWordWrapEnabled(False);
            SetTextAlignX(taxAuto);
            SetTextAlignY(tayCenterEx);
            SetText(LowerCaseWideString(TShip(Objects[I]).GetLocalizedTypeName));
            DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
          end;
        end
        else if TObject(Objects[I]) is TCustomSystemInfo then
        begin
          CustomInfo := Objects[I];
          if (CountDelimitedPartsW(CustomInfo.Info, ':') > 1) and
            (ExtractDelimitedPartW(CustomInfo.Info, 0, ':') = 'Image') then
          begin
            Images := ExtractDelimitedPartW(CustomInfo.Info, 1, ':');
            RowX := NameWidth + 5 + RowHeight + 5 + 1;
            for J := 0 to CountDelimitedPartsW(Images, ',') - 1 do
              with TImageGI.Create(Panel) do
              begin
                SetImagePath('GI,' + ExtractDelimitedPartW(Images, J, ','));
                SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                SetPosition(Classes.Point(RowX, RowHeight * I + 1));
                RowX := RowX + RowHeight + 2;
              end;
          end
          else if (CountDelimitedPartsW(CustomInfo.Info, ':') > 1) and
            (ExtractDelimitedPartW(CustomInfo.Info, 0, ':') = 'RGBA') then
          begin
            Images := ExtractDelimitedPartW(CustomInfo.Info, 1, ':');
            RowX := NameWidth + 5 + RowHeight + 5 + 1;
            for J := 0 to CountDelimitedPartsW(Images, ',') - 1 do
              with TGraphBufGI.Create(Panel, False) do
              begin
                SourceHasPerPixelAlpha := True;
                LoadBitmapPathAsRgba(ExtractDelimitedPartW(Images, J, ',') + '?RGBA');
                SetPosition(Classes.Point(RowX, RowHeight * I + 1));
                SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                begin
                  if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                    GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
                  else
                    GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
                end;
                SetImageKindX(ikxCenter);
                SetImageKindY(ikyCenter);
                RowX := RowX + RowHeight + 2;
              end;
          end
          else
            with TLabelGI.Create(Panel) do
            begin
              if GiResourceVariant = 2 then SetFontName(MiniFontName)
              else SetFontName(SmallFontName);
              SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
              SetSize(Classes.Point(1, RowHeight));
              SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
              SetWordWrapEnabled(False);
              SetTextAlignX(taxAuto);
              SetTextAlignY(tayCenterEx);
              SetText(CustomInfo.Info);
              DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
            end;
        end
        else if OwnerId <> Byte(oiUninhabited) then
        if not (TObject(Objects[I]) is TPlanet) or not (TObject(Objects[I]) as TPlanet).IsMainPiratePlanet then
          with TGraphBufGI.Create(Panel, False) do
          begin
            SourceHasPerPixelAlpha := True;
            LoadBitmapPathAsRgba(ExtractDelimitedPartW(GetFactionEmblemPath((TObject(Objects[I]) as TPlanet).GetFactionResourceName), 1, ',') + '?RGBA');
            SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I + 1));
            SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
            if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
            begin
              if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
              else
                GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            end;
            SetImageKindX(ikxCenter);
            SetImageKindY(ikyCenter);
          end;
        if (TObject(Objects[I]) is TPlanet) and ((TObject(Objects[I]) as TPlanet).OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and
          not (TObject(Objects[I]) as TPlanet).IsMainPiratePlanet and ((TObject(Objects[I]) as TPlanet).CurrentStar.Status.CustomFaction = '') then
        begin
          RowX := NameWidth + 5 + RowHeight + 5 + 1;
          with TImageGI.Create(Panel) do
          begin
            case (TObject(Objects[I]) as TPlanet).GetRelationLevelToShip(GetPlayer) of
              rlHostile: SetImagePath('GI,Bm.FormGalaxy2.Face4');
              rlBad: SetImagePath('GI,Bm.FormGalaxy2.Face3');
              rlNormal: SetImagePath('GI,Bm.FormGalaxy2.Face2');
              rlGood: SetImagePath('GI,Bm.FormGalaxy2.Face1');
              rlExcellent: SetImagePath('GI,Bm.FormGalaxy2.Face0');
            else SetImagePath('GI,Bm.FormGalaxy2.Face2');
            end;
            SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
            SetPosition(Classes.Point(RowX + RowHeight + 2, RowHeight * I + 1));
          end;
          RowX := RowX + RowHeight + 2;
          if (TObject(Objects[I]) as TPlanet).Economy in [peAgricultural, peIndustrial] then
            with TImageGI.Create(Panel) do
            begin
              case (TObject(Objects[I]) as TPlanet).Economy of
                peAgricultural: SetImagePath('GI,Bm.FormGalaxy.EconAgrar');
                peIndustrial: SetImagePath('GI,Bm.FormGalaxy.EconIndustr');
              end;
              SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
              SetPosition(Classes.Point(RowX + RowHeight, RowHeight * I + 1));
            end;
        end
        else if (TObject(Objects[I]) is TPlanet) and (TObject(Objects[I]) as TPlanet).IsMainPiratePlanet then
        begin
          with TLabelGI.Create(Panel) do
          begin
            if GiResourceVariant = 2 then SetFontName(MiniFontName)
            else SetFontName(SmallFontName);
            SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
            SetSize(Classes.Point(1, RowHeight));
            SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
            SetWordWrapEnabled(False);
            SetTextAlignX(taxAuto);
            SetTextAlignY(tayCenterEx);
            SetText(LowerCaseWideString(LocalizedText('ShipType.TypeName.PB')));
            DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
          end;
        end
        else if TObject(Objects[I]) is TPlanet then
        if (TObject(Objects[I]) as TPlanet).OwnerId = Byte(oiUninhabited) then
        if (TObject(Objects[I]) as TPlanet).GetUnexploredSurfaceTileCount = 0 then
        begin
          with TLabelGI.Create(Panel) do
          begin
            SetFontName(MiniFontName);
            SetTextColor(CurrentPixelFormat.PackRgbBytes(140, 140, 140));
            SetSize(Classes.Point(1, RowHeight));
            SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
            SetWordWrapEnabled(False);
            SetTextAlignX(taxAuto);
            SetTextAlignY(tayCenterEx);
            SetText(LowerCaseWideString(LocalizedText('Planet.NotCivil.AllExplore')));
            DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
          end;
        end;
      end;
      Panel.SetSize(Classes.Point(NameWidth + DetailWidth, RowHeight * Objects.Count));
      Panel.SetPosition(StarInfoWindow.WorkSubRect.TopLeft);
      StarInfoWindow.SetSize(Classes.Point(Panel.ClientSize.X + StarInfoWindow.WorkSubRect.Left + StarInfoWindow.WorkSubRect.Right,
        StarInfoWindow.WorkSubRect.Top + StarInfoWindow.WorkSubRect.Bottom + RowHeight * Objects.Count));
      StarInfoWindow.UpdateAutoGeometry;
      with GetByName('InfoStarName') as TLabelGI do
      begin
        SetText(WrapTextInColor((Obj as TStar).Name, InfoNameColorTag));
        SetSize(Classes.Point(StarInfoWindow.ClientSize.X - StarInfoWindow.WorkSubRect.Right - LocalPosition.X - 15, ClientSize.Y));
      end;
      Objects.Free;
      DisplayedObject := Obj;
    end
    else if Obj is TMissile then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(True);
      GetByName('InfoStdImage').SetActive(False);
      with GetByName('InfoStdGB') as TGraphBufGI do
      begin
        SetActive(True);
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf('Bm.Missile.w' + (Obj as TMissile).GetGraphSuffix + '_' + GiResourceSuffix + 'i', GraphBuf);
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
      end;
      (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor((Obj as TMissile).GetDisplayName, InfoNameColorTag));
      (GetByName('InfoStdText') as TLabelGI).SetText((Obj as TMissile).GetInfoText);
      ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      DisplayedObject := Obj;
    end
    else if Obj is TAsteroid then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(True);
      GetByName('InfoStdImage').SetActive(False);
      with GetByName('InfoStdGB') as TGraphBufGI do
      begin
        SetActive(True);
        SourceHasPerPixelAlpha := True;
        LoadGaiFrameToGraphBuf(TAsteroidSE(TAsteroid(Obj).GraphObject).ImagePath, GraphBuf, TAsteroid(Obj).Id);

        if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
        begin
          if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
            GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
          else
            GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
        end;
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
      end;
      (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor((Obj as TAsteroid).GetDisplayName, InfoNameColorTag));
      (GetByName('InfoStdText') as TLabelGI).SetText((Obj as TAsteroid).GetInfoText);
      ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as TLabelGI, True, True, 0);
      DisplayedObject := Obj;
    end
    else
    begin
      InfoWindow.SetActive(True);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(False);
      InfoTextLabel.SetText(GetPlayer.GetObjectInfoText(Obj));
      InfoWindow.SetSize(Classes.Point(InfoTextLabel.ClientSize.X + InfoWindow.WorkSubRect.Left + InfoWindow.WorkSubRect.Right,
        InfoTextLabel.ClientSize.Y + InfoWindow.WorkSubRect.Top + InfoWindow.WorkSubRect.Bottom));
      InfoWindow.UpdateAutoGeometry;
      InfoTextLabel.SetPosition(Classes.Point(InfoWindow.WorkSubRect.Left, InfoWindow.WorkSubRect.Top));
      DisplayedObject := Obj;
      if Obj is TAsteroid then ShowAsteroidPath(Obj as TAsteroid)
      else ClearAsteroidPath;
      if Obj is TShip then BuildShipPathOverlay(Obj as TShip, False, '')
      else ClearPathOverlay(False);
    end;
  end;
  if InfoWindow.Active then ActivePanel := InfoWindow
  else if ItemInfoWindow.Active then ActivePanel := ItemInfoWindow
  else if ShipInfoPanel.Active then ActivePanel := ShipInfoPanel
  else if PlanetInfoPanel.Active then ActivePanel := PlanetInfoPanel
  else if StarInfoWindow.Active then ActivePanel := StarInfoWindow
  else if StandardInfoPanel.Active then ActivePanel := StandardInfoPanel
  else Exit;
  if DynamicTipsPos then
  begin
    Inc(HitObjectPosition.X, Cardinal(GameScreenWidth) div 2);
    Inc(HitObjectPosition.Y, Cardinal(GameScreenHeight) div 2);
    I := Cardinal(GameScreenWidth) div 3;
    if HitObjectPosition.X <= I then Inc(HitObjectPosition.X, HitObjectSize.X div 2)
    else if HitObjectPosition.X >= 2 * I then
      HitObjectPosition.X := HitObjectPosition.X - HitObjectSize.X div 2 - ActivePanel.ClientSize.X
    else
    begin
      Dec(HitObjectPosition.X, ActivePanel.ClientSize.X div 2);
      I := 0;
    end;
    if I = 0 then
    begin
      if HitObjectPosition.Y < Integer(Cardinal(GameScreenHeight) div 2) then
      begin
        Inc(HitObjectPosition.Y, HitObjectSize.Y div 2);
        if ActivePanel.ClientSize.Y + HitObjectPosition.Y + 10 > Integer(GameScreenHeight) then
          HitObjectPosition.Y := HitObjectPosition.Y - HitObjectSize.Y - ActivePanel.ClientSize.Y;
        if HitObjectPosition.Y < 10 then HitObjectPosition.Y := 10;
      end
      else HitObjectPosition.Y := HitObjectPosition.Y - HitObjectSize.Y div 2 - ActivePanel.ClientSize.Y;
    end
    else
    begin
      I := Cardinal(GameScreenHeight) div 3;
      if HitObjectPosition.Y <= I then Inc(HitObjectPosition.Y, HitObjectSize.Y div 2)
      else if HitObjectPosition.Y >= 2 * I then
        HitObjectPosition.Y := HitObjectPosition.Y - HitObjectSize.Y div 2 - ActivePanel.ClientSize.Y
      else Dec(HitObjectPosition.Y, ActivePanel.ClientSize.Y div 2);
    end;
    Dec(HitObjectPosition.X, Cardinal(GameScreenWidth) div 2);
    Dec(HitObjectPosition.Y, Cardinal(GameScreenHeight) div 2);
    ActivePanel.SetPosition(HitObjectPosition);
  end
  else ActivePanel.SetPosition(Classes.Point(10 - Cardinal(GameScreenWidth) div 2, 10 - Cardinal(GameScreenHeight) div 2));
end;
{ @end $7B3648 }

{ @routine $7BAFF4 TfStarMap_MapScrollChanged }
procedure TfStarMap.MapScrollChanged;
begin
  RefreshActionRanges;
  SpaceProcess.Space.DrawMinimap;
end;
{ @end $7BAFF4 }

{ @routine $7BB018 TfStarMap_GetPriceSnapshotKey }
function TfStarMap.GetPriceSnapshotKey(Obj: TObject): WideString;
begin
  if Obj is TPlanet then Result := (Obj as TPlanet).Name
  else if Obj is TRuins then Result := (Obj as TRuins).Name
  else if Obj is TShip then Result := (Obj as TShip).Name
  else Result := '';
  Result := 'GOODS' + Result + Galaxy.FormatTurnDate(-1);
end;
{ @end $7BB018 }

{ @routine $7BB128 TfStarMap_SaveVisiblePriceSnapshots }
procedure TfStarMap.SaveVisiblePriceSnapshots;
var
  Index: Integer;
  Planet: TPlanet;
  Ship: TShip;
  Added: Boolean;
begin
  Added := False;
  for Index := 0 to GetPlayer.CurrentStar.Planets.Count - 1 do
  begin
    Planet := TPlanet(GetPlayer.CurrentStar.Planets[Index]);
    if Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)] then
      if PointDistance(GetPlayer.Position, Planet.GetPosition) <= GetPlayer.GetRadarRange then
      begin
        AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, GoodsShopScreen.BuildPriceText(Planet), GetPriceSnapshotKey(Planet));
        Added := True;
      end;
  end;
  for Index := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(GetPlayer.CurrentStar.Ships[Index]);
    if Ship is TRuins then
      if (Ship as TRuins).CanDock(GetPlayer) and not Ship.NoTalk then
        if PointDistance(GetPlayer.Position, Ship.Position) <= GetPlayer.GetRadarRange then
        begin
          AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, GoodsShopScreen.BuildPriceText(Ship), GetPriceSnapshotKey(Ship));
          Added := True;
        end;
  end;
  if Added then
  begin
    SoundManager.PlaySound('Sound.UserMsgAdd');
    MainPanel.RebuildMessageButtons(False);
  end;
end;
{ @end $7BB128 }

{ @routine $7BB384 TfStarMap_CenterOnShip }
procedure TfStarMap.CenterOnShip(Ship: TShip);
begin
  SetMapCenterManually(TruncatePointF(Ship.Position));
  AddMapAnimation(Ship.Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 0);
  AddMapAnimation(Ship.Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 200);
  AddMapAnimation(Ship.Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 400);
end;
{ @end $7BB384 }

{ @routine $7BB4B0 TfStarMap_CenterOnDominator }
procedure TfStarMap.CenterOnDominator(Selection: Integer);
var
  Index: Integer;
  Ship, NearestShip, FarthestShip: TShip;
  FarthestDistance, NearestDistance, Distance: Double;
begin
  FarthestDistance := 0;
  NearestDistance := 1.0E20;
  NearestShip := nil;
  FarthestShip := nil;
  for Index := 0 to PlayerStar.Ships.Count - 1 do
  begin
    Ship := PlayerStar.Ships[Index];
    if not Ship.IsOutsideStarSpace and (Ship is TKling) then
    begin
      Distance := PointDistance(GetPlayer.Position, Ship.Position);
      if Distance > FarthestDistance then
      begin
        FarthestDistance := Distance;
        FarthestShip := Ship;
      end;
      if Distance < NearestDistance then
      begin
        NearestDistance := Distance;
        NearestShip := Ship;
      end;
    end;
  end;
  if (Selection = 1) and (NearestShip <> nil) then CenterOnShip(NearestShip)
  else if Selection = 2 then
    if FarthestShip <> nil then CenterOnShip(FarthestShip);
end;
{ @end $7BB4B0 }

{ @routine $7BB5C4 TfStarMap_CenterShipClicked }
procedure TfStarMap.CenterShipClicked(Sender: TObjectGI);
begin
  CenterOnShip(GetPlayer);
end;
{ @end $7BB5C4 }

{ @routine $7BB5E4 TfStarMap_CenterShipMouseEnter }
procedure TfStarMap.CenterShipMouseEnter(Sender: TObjectGI);
begin
  // The native guard tests job 5 as well as the declared preparation job 3.
  if IsTurnCalculationRunning and ((TurnCalculationThread.Job = tcjPreparePlayerStar) or (Integer(TurnCalculationThread.Job) = 5)) then Exit;
  if GetPlayer <> nil then ShowObjectInfo(GetPlayer);
end;
{ @end $7BB5E4 }

{ @routine $7BB630 TfStarMap_CenterShipMouseLeave }
procedure TfStarMap.CenterShipMouseLeave(Sender: TObjectGI);
begin
  ShowObjectInfo(nil);
end;
{ @end $7BB630 }

{ @routine $7BB64C TfStarMap_AllWeaponsClicked }
procedure TfStarMap.AllWeaponsClicked(Sender: TObjectGI);
begin
  if Mode = smmOrders then
  begin
    TalkSelectionActive := False;
    ScannerSelectionActive := False;
    InterceptorSelectionActive := False;
    CustomSelectionActive := False;
    SelectAllUsableWeapons;
    RebuildTargetMarkers;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7BB64C }

{ @routine $7BB6BC TfStarMap_ScannerClicked }
procedure TfStarMap.ScannerClicked(Sender: TObjectGI);
var
  Index: Integer;
begin
  if Mode = smmOrders then
  begin
    TalkSelectionActive := False;
    for Index := 0 to 4 do SelectedWeapons[Index] := False;
    InterceptorSelectionActive := False;
    CustomSelectionActive := False;
    if (not GetPlayer.IsEquipmentUsable(GetPlayer.GetScanner) or not GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar))
      and (Galaxy.UltraScanModEnabled = 0) then ScannerSelectionActive := False
    else ScannerSelectionActive := not ScannerSelectionActive;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7BB6BC }

{ @routine $7BB794 TfStarMap_TalkClicked }
procedure TfStarMap.TalkClicked(Sender: TObjectGI);
var
  Index: Integer;
begin
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  if Mode = smmOrders then
  begin
    ScannerSelectionActive := False;
    for Index := 0 to 4 do SelectedWeapons[Index] := False;
    InterceptorSelectionActive := False;
    CustomSelectionActive := False;
    if not GetPlayer.IsEquipmentUsable(GetPlayer.GetRadar) then TalkSelectionActive := False
    else TalkSelectionActive := not TalkSelectionActive;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7BB794 }

{ @routine $7BB858 TfStarMap_SelectInterceptorTarget }
procedure TfStarMap.SelectInterceptorTarget;
var
  Index: Integer;
begin
  if (Mode = smmOrders) and (GetPlayer <> nil) and GetPlayer.GetHull.InterceptorsEnabled and
    (GetPlayer.GetHull.Energy >= GetPlayer.GetInterceptorEnergyCost) then
  begin
    TalkSelectionActive := False;
    ScannerSelectionActive := False;
    for Index := 0 to 4 do SelectedWeapons[Index] := False;
    CustomSelectionActive := False;
    InterceptorSelectionActive := True;
    RebuildTargetMarkers;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7BB858 }

{ @routine $7BB91C TfStarMap_BeginCustomSelection }
procedure TfStarMap.BeginCustomSelection;
var
  Index: Integer;
begin
  if (Mode = smmOrders) and (GetPlayer <> nil) then
  begin
    TalkSelectionActive := False;
    ScannerSelectionActive := False;
    for Index := 0 to 4 do SelectedWeapons[Index] := False;
    InterceptorSelectionActive := False;
    CustomSelectionActive := True;
    RebuildTargetMarkers;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7BB91C }

{ @routine $7BB9A4 TfStarMap_ToggleWeaponPanelClicked }
procedure TfStarMap.ToggleWeaponPanelClicked(Sender: TObjectGI);
begin
  if Mode = smmOrders then
  begin
    StarMapWeaponPanelOpen := not StarMapWeaponPanelOpen;
    if StarMapWeaponPanelOpen then AnimateWeaponPanel(1)
    else AnimateWeaponPanel(-1);
  end;
end;
{ @end $7BB9A4 }

{ @routine $7BB9F8 TfStarMap_WeaponButtonDown }
procedure TfStarMap.WeaponButtonDown(Sender: TObjectGI);
var
  Index: Integer;
  Image: TImageGI;
begin
  Index := ExtractDigitsToIntW(Sender.ControlName);
  Image := WeaponImages[Index];
  Image.SetPosition(Classes.Point(Image.LocalPosition.X, 0));
end;
{ @end $7BB9F8 }

{ @routine $7BBA44 TfStarMap_WeaponButtonUp }
procedure TfStarMap.WeaponButtonUp(Sender: TObjectGI);
var
  Index: Integer;
  Weapon: TWeapon;
begin
  if Mode = smmOrders then
  begin
    DisplayedObject := nil;
    Index := ExtractDigitsToIntW(Sender.ControlName);
    Galaxy.CheckIntegrityChecksum(87);
    Weapon := GetPlayer.FindEquippedItemInSlot(Ord(t_Weapon1), Index) as TWeapon;
    TalkSelectionActive := False;
    ScannerSelectionActive := False;
    InterceptorSelectionActive := False;
    CustomSelectionActive := False;
    if not GetPlayer.IsEquipmentUsable(Weapon) or
      ((Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) and (Weapon.Ammo <= 0)) then
      SelectedWeapons[Index] := False
    else
    begin
      if Weapon.Target <> nil then
      begin
        Weapon.Target := nil;
        SelectedWeapons[Index] := False;
      end
      else SelectedWeapons[Index] := not SelectedWeapons[Index];
    end;
    Galaxy.PrimeIntegrityChecksum(88);
    RebuildTargetMarkers;
    RefreshActionRanges;
    RefreshWeaponButtons;
    UpdateActionCursor(False);
  end;
end;
{ @end $7BBA44 }

{ @routine $7BBB80 TfStarMap_RefreshWeaponButtons }
procedure TfStarMap.RefreshWeaponButtons;
var
  Slot: Integer;
  Weapon: TWeapon;
  Button: TGraphButtonGI;
  Image: TImageGI;
begin
  for Slot := 0 to 4 do
  begin
    Weapon := GetPlayer.FindEquippedItemInSlot($32, Slot) as TWeapon;
    Button := WeaponButtons[Slot];
    Button.SetDisabled((GetPlayer.GetSlotCount(sskWeapon) <= Slot) or not GetPlayer.IsEquipmentUsable(Weapon));
    if GetPlayer.GetSlotCount(sskWeapon) <= Slot then
      Button.SetImageDisabledPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Disabled')
    else if Weapon = nil then
      Button.SetImageDisabledPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Empty')
    else if not GetPlayer.IsEquipmentUsable(Weapon) then
      Button.SetImageDisabledPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Red');
    if SelectedWeapons[Slot] then
    begin
      Button.SetImageNormalPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Down');
      Button.SetImageNormalActivePath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Down');
      Button.SetImageDownPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Normal');
    end
    else if SelectedWeapons[Slot] or ((Weapon <> nil) and (Weapon.Target <> nil)) then
    begin
      Button.SetImageNormalPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Select');
      Button.SetImageNormalActivePath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Select');
      Button.SetImageDownPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Down');
    end
    else
    begin
      Button.SetImageNormalPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Normal');
      Button.SetImageNormalActivePath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Active');
      Button.SetImageDownPath('GI,Bm.PanelMain2.' + GiResourceSuffix + 'W' + IntToStr(Slot + 1) + 'Down');
    end;
    Button.DownCallback := WeaponButtonDown;
    Button.UpCallback := WeaponButtonUp;
    Image := WeaponImages[Slot];
    if Weapon = nil then Image.SetActive(False)
    else
    begin
      Image.SetActive(True);
      Image.SetImagePath('GI,' + Weapon.GetBitmapResourceName + 's');
    end;
    Image.SetImageKindX(ikxCenter);
    Image.SetImageKindY(ikyCenter);
    if SelectedWeapons[Slot] then Image.SetPosition(Classes.Point(Image.LocalPosition.X, 0))
    else Image.SetPosition(Classes.Point(Image.LocalPosition.X, -2));
    if Weapon <> nil then
      WeaponButtons[Slot].HelpText := Weapon.GetDisplayName + ' (' + WrapTextInColor(IntToStr(Slot + 1), '<color=255,240,100>') + ')';
  end;
end;
{ @end $7BBB80 }

{ @routine $7BC474 TfStarMap_RefreshActionRanges }
procedure TfStarMap.RefreshActionRanges;
var
  Point: TPoint;
  MainCenter: TPoint;
  MainRadius: Integer;
  MainColor: Cardinal;
  MainVisible: Boolean;
  InnerCenter: TPoint;
  InnerRadius: Integer;
  InnerColor: Cardinal;
  InnerVisible: Boolean;
  RadarCenter: TPointF;
  RadarRadius: Integer;
  RadarColor: Cardinal;
  RadarChanged: Boolean;
  Slot, ExtraIndex, MinRange, MaxRange, DirectRange: Integer;
  AnyWeapon: Boolean;
  Weapon: TWeapon;
  MainCircle, InnerCircle, ExtraCircle: TSpaceCircleGI;
  SimpleCircle: TCircleGI;
  RangeValue, RangeMaximum: Integer;
  Reserved: array[0..2] of Integer;
begin
  CursorObject := FindObjectAtCursor;
  // These three assignments are retained from the native routine; their values are unused.
  Reserved[0] := 1;
  Reserved[1] := 1;
  Reserved[2] := 1;
  AnyWeapon := False;
  for Slot := 0 to 4 do
    if SelectedWeapons[Slot] then
    begin
      AnyWeapon := True;
      Break;
    end;
  RadarCenter := GetPlayer.Position;
  RadarRadius := GetPlayer.GetRadarRange;
  RadarColor := 0;
  InnerCenter := TruncatePointF(GetPlayer.Position);
  InnerRadius := 0;
  InnerColor := 0;
  InnerVisible := False;
  MainCenter := TruncatePointF(GetPlayer.Position);
  MainRadius := GetPlayer.GetRadarRange;
  MainColor := 0;
  MainVisible := False;
  if ScannerSelectionActive then
  begin
    MainColor := CurrentPixelFormat.PackRgbBytes(255, 255, 0);
    MainVisible := True;
    RadarColor := MainColor;
  end
  else if TalkSelectionActive then
  begin
    MainColor := CurrentPixelFormat.PackRgbBytes(255, 0, 255);
    MainVisible := True;
    RadarColor := MainColor;
  end
  else if InterceptorSelectionActive then
  begin
    MainColor := CurrentPixelFormat.PackRgbBytes(255, 100, 0);
    MainVisible := True;
    MainRadius := 1000;
    RadarRadius := 1000;
    RadarColor := MainColor;
  end
  else if CustomSelectionActive then
  begin
    MainColor := CustomSelectionColor;
    MainVisible := True;
    MainRadius := CustomSelectionRadius;
    RadarRadius := CustomSelectionRadius;
    RadarColor := MainColor;
  end
  else if AnyWeapon then
  begin
    MinRange := 999999999;
    MaxRange := -999999999;
    for Slot := 0 to 4 do
      if SelectedWeapons[Slot] then
      begin
        Weapon := GetPlayer.FindEquippedItemInSlot($32, Slot) as TWeapon;
        if GetPlayer.GetWeaponActionRange(Weapon) < MinRange then MinRange := GetPlayer.GetWeaponActionRange(Weapon);
        if GetPlayer.GetWeaponActionRange(Weapon) > MaxRange then MaxRange := GetPlayer.GetWeaponActionRange(Weapon);
      end;
    MainColor := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
    MainRadius := MaxRange;
    MainVisible := True;
    if MaxRange <> MinRange then
    begin
      InnerRadius := MinRange;
      InnerColor := CurrentPixelFormat.PackRgbBytes(255, 0, 0);
      InnerVisible := True;
    end;
    RadarColor := MainColor;
    RadarRadius := MainRadius;
  end
  else if CursorObject = nil then
  begin
    MainVisible := False;
    RadarColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
  end
  else
  begin
    if CursorObject is TItem then
    begin
      InnerRadius := GetPlayer.GetRadarRange;
      InnerColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
      InnerVisible := True;
      if GetPlayer.GetCargoHook <> nil then
      begin
        MainColor := CurrentPixelFormat.PackRgbBytes(0, 0, 255);
        MainRadius := GetPlayer.GetCargoHookRange;
        MainVisible := True;
        RadarColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
      end;
    end
    else if CursorObject <> nil then
    begin
      MainColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
      MainVisible := True;
      RadarColor := MainColor;
    end;
  end;
  MainCircle := ActionColorCircle;
  if MainVisible then MainCircle.UpdateAbsolutePosition;
  Point := MainCircle.ToLocalPoint(MapControls.ToAbsolutePoint(MainCenter));
  if (MainCircle.Center.X <> Point.X) or (MainCircle.Center.Y <> Point.Y) then MainCircle.SetCenter(Point);
  if MainCircle.Radius <> MainRadius then MainCircle.SetRadius(MainRadius);
  if MainCircle.Color <> MainColor then MainCircle.Color := MainColor;
  if MainCircle.Active <> MainVisible then MainCircle.SetActive(MainVisible);
  InnerCircle := WeaponColorCircles[0];
  if InnerVisible then InnerCircle.UpdateAbsolutePosition;
  Point := InnerCircle.ToLocalPoint(MapControls.ToAbsolutePoint(InnerCenter));
  if (InnerCircle.Center.X <> Point.X) or (InnerCircle.Center.Y <> Point.Y) then InnerCircle.SetCenter(Point);
  if InnerCircle.Radius <> InnerRadius then InnerCircle.SetRadius(InnerRadius);
  if InnerCircle.Color <> InnerColor then InnerCircle.Color := InnerColor;
  if InnerCircle.Active <> InnerVisible then InnerCircle.SetActive(InnerVisible);
  DirectRange := 0;
  if AnyWeapon then
    for Slot := 0 to 4 do
      if SelectedWeapons[Slot] then
      begin
        Weapon := GetPlayer.FindEquippedItemInSlot($32, Slot) as TWeapon;
        if not (Byte(Weapon.GetWeaponInfo.ShotType) in [Ord(wstTorpedo)..Ord(wstRocket)]) then
        begin
          RangeValue := GetPlayer.GetWeaponActionRange(Weapon);
          if DirectRange > RangeValue then RangeMaximum := DirectRange
          else RangeMaximum := RangeValue;
          DirectRange := RangeMaximum;
        end;
      end;
  ExtraIndex := -1;
  if (DirectRange <> 0) and (DirectRange <> MainRadius) and (not InnerVisible or (InnerRadius <> DirectRange)) then ExtraIndex := 0;
  for Slot := 0 to 2 do
  begin
    ExtraCircle := WeaponColorCircles[Slot + 1];
    if Slot = ExtraIndex then ExtraCircle.UpdateAbsolutePosition;
    Point := ExtraCircle.ToLocalPoint(MapControls.ToAbsolutePoint(MainCenter));
    if (ExtraCircle.Center.X <> Point.X) or (ExtraCircle.Center.Y <> Point.Y) then ExtraCircle.SetCenter(Point);
    if ExtraCircle.Radius <> DirectRange then ExtraCircle.SetRadius(DirectRange);
    if ExtraCircle.Color <> MainColor then ExtraCircle.Color := MainColor;
    if (Slot = ExtraIndex) <> ExtraCircle.Active then ExtraCircle.SetActive(Slot = ExtraIndex);
  end;
  SimpleCircle := ActionCircle;
  if not CircleAction then SimpleCircle.SetActive(False)
  else
  begin
    Point := SimpleCircle.ToLocalPoint(MapControls.ToAbsolutePoint(MainCenter));
    SimpleCircle.UpdateAbsolutePosition;
    if (SimpleCircle.Center.X <> Point.X) or (SimpleCircle.Center.Y <> Point.Y) then SimpleCircle.SetCenter(Point);
    if SimpleCircle.Radius <> MainRadius then SimpleCircle.SetRadius(MainRadius);
    if SimpleCircle.Active <> MainVisible then SimpleCircle.SetActive(MainVisible);
  end;
  RadarChanged := False;
  if (SpaceProcess.RadarCenter.X <> RadarCenter.X) or (SpaceProcess.RadarCenter.Y <> RadarCenter.Y) then
  begin
    SpaceProcess.RadarCenter := RadarCenter;
    RadarChanged := True;
  end;
  if SpaceProcess.ActionRange <> RadarRadius then
  begin
    SpaceProcess.ActionRange := RadarRadius;
    RadarChanged := True;
  end;
  if SpaceProcess.ActionColor <> RadarColor then
  begin
    SpaceProcess.ActionColor := RadarColor;
    RadarChanged := True;
  end;
  if RadarChanged then SpaceProcess.Space.DrawMinimap;
end;
{ @end $7BC474 }

{ @routine $7BCC30 TfStarMap_HideActionRanges }
procedure TfStarMap.HideActionRanges;
begin
  with ActionColorCircle do SetActive(False);
  with WeaponColorCircles[0] do SetActive(False);
  with WeaponColorCircles[1] do SetActive(False);
  with WeaponColorCircles[2] do SetActive(False);
  with WeaponColorCircles[3] do SetActive(False);
  with ActionCircle do SetActive(False);
end;
{ @end $7BCC30 }

{ @routine $7BCCC4 TfStarMap_RebuildTargetMarkers }
procedure TfStarMap.RebuildTargetMarkers;
const
  TargetDamageFlags = [dkScanBonus..dkDroidBlock];
  NoDamageFlags = [];
var
  J, I: Integer;
  Weapon: TWeapon;
  Point: TPointF;
  Image: TImageGI;
  Item: TItem;
  Target: TShip;
  BadgePoint: TPointF;
begin
  ClearTargetMarkers;
  for I := 1 to GetPlayer.WeaponCount do
  begin
    Weapon := GetPlayer.Weapons[I];
    if Weapon.Target <> nil then
      if (Weapon.Target is TItem) or (Weapon.Target is TAsteroid) or (Weapon.Target is TMissile) or
        ((Weapon.Target is TShip) and (Weapon.Target as TShip).InNormalSpace) then
      begin
        if Weapon.Target is TItem then Point := (Weapon.Target as TItem).Position
        else if Weapon.Target is TAsteroid then Point := (Weapon.Target as TAsteroid).Position
        else if Weapon.Target is TMissile then Point := (Weapon.Target as TMissile).Position
        else if Weapon.Target is TShip then Point := (Weapon.Target as TShip).Position;
        Point := AddPointsF(Point, MakePointF(-40, -40));
        for J := 1 to I - 1 do
          if GetPlayer.Weapons[J].Target = Weapon.Target then Point.X := Point.X + 32;
        Image := TImageGI.Create(MapControls);
        Image.SetImagePath('GI,' + Weapon.GetBitmapResourceName + 's');
        Image.SetSize(Image.GetContentSize);
        Image.SetOrigin(HalfPoint(Image.ClientSize));
        Image.SetPosition(TruncatePointF(Point));
        Image.SetDepthByName('Weapon');
        Image.SetPositionModeW(True);
        Image.UserValue := 100;
        Image.UserIndex := I;
        Image.MouseBlocking := True;
        if Weapon.Target is TShip then
          if GetPlayer.CanResolveObjectWithScanner(Weapon.Target) and ((Weapon.GetDamageFlags * TargetDamageFlags) <> NoDamageFlags) then
          begin
            Image := TImageGI.Create(MapControls);
            Image.SetImagePath('GI,Bm.Items.WeaponTarget');
            Image.SetSize(Image.GetContentSize);
            Image.SetOrigin(HalfPoint(Image.ClientSize));
            BadgePoint.X := Point.X - 10;
            BadgePoint.Y := Point.Y + 10;
            Image.SetPosition(TruncatePointF(BadgePoint));
            Image.SetDepthByName('Hit');
            Image.SetPositionModeW(True);
            Image.UserValue := 100;
            Image.UserIndex := I;
            Image.MouseBlocking := True;
          end;
      end;
  end;
  if GetPlayer.GetHull.InterceptorsEnabled then
  begin
    Target := GetPlayer.GetHull.InterceptorTarget;
    if Target = nil then Target := GetPlayer.SelectInterceptorTarget;
    if Target <> nil then
    begin
      Point := Target.Position;
      Point := AddPointsF(Point, MakePointF(-40, -40));
      for J := 1 to GetPlayer.WeaponCount do
        if GetPlayer.Weapons[J].Target = Target then Point.X := Point.X + 32;
      Image := TImageGI.Create(MapControls);
      Image.SetImagePath('GI,Bm.Items.2Interceptors_s');
      Image.SetSize(Image.GetContentSize);
      Image.SetOrigin(HalfPoint(Image.ClientSize));
      Image.SetPosition(TruncatePointF(Point));
      Image.SetDepthByName('Weapon');
      Image.SetPositionModeW(True);
      Image.UserValue := 100;
      Image.UserIndex := 0;
      Image.MouseBlocking := True;
    end;
  end;
  if GetPlayer.PickupTargets <> nil then
    for I := 0 to GetPlayer.PickupTargets.Count - 1 do
    begin
      Item := GetPlayer.PickupTargets[I];
      Image := TImageGI.Create(MapControls);
      Image.SetImagePath('GAI,Bm.PI.ItemTakeAnim');
      Image.SetSize(Image.GetContentSize);
      Image.SetOrigin(HalfPoint(Image.ClientSize));
      Image.SetPosition(TruncatePointF(AddPointsF(Item.Position, MakePointF(-20, 20))));
      Image.SetDepthByName('Weapon');
      Image.SetPositionModeW(True);
      Image.UserValue := 100;
      Image.MouseBlocking := True;
      Image.RestartPlayback;
    end;
end;
{ @end $7BCCC4 }

{ @routine $7BD44C TfStarMap_ClearTargetMarkers }
procedure TfStarMap.ClearTargetMarkers;
var
  NextControl, Control: TObjectGI;
begin
  NextControl := MapControls.FirstChild;
  while NextControl <> nil do
  begin
    Control := NextControl;
    NextControl := NextControl.NextSibling;
    if Control.UserValue = 100 then
    begin
      Control.SetActive(False);
      Control.Free;
    end;
  end;
end;
{ @end $7BD44C }

{ @routine $7BD4A4 TfStarMap_UpdateActionCursor }
procedure TfStarMap.UpdateActionCursor(CanTake: Boolean);
var
  Point: TPointF;
  Obj: TObject;
  Index, Range, ActionResult: Integer;
  Info: PCustomShipInfo;
  AnyWeapon: Boolean;
  Weapon: TWeapon;
begin
  AnyWeapon := False;
  for Index := 0 to 4 do
    if SelectedWeapons[Index] then
    begin
      AnyWeapon := True;
      Break;
    end;
  if ScannerSelectionActive then
  begin
    Obj := FindObjectAtCursor;
    if (Obj is TShip) and not (Obj is TRuins) and not (Obj is TKling) then
    begin
      if Sqr(GetPlayer.GetRadarRange) >= PointDistanceSquared((Obj as TShip).Position, GetPlayer.Position) then
      begin
        if not IsCursorImageSelected('ScanFull') then SetCursorByName('ScanFull');
      end
      else if not IsCursorImageSelected('ScanSmall') then SetCursorByName('ScanSmall');
    end
    else if not IsCursorImageSelected('ScanSmall') then SetCursorByName('ScanSmall');
  end
  else if TalkSelectionActive then
  begin
    Obj := FindObjectAtCursor;
    if (Obj is TShip) and not (Obj is TRuins) then
    begin
      if Sqr(GetPlayer.GetRadarRange) >= PointDistanceSquared((Obj as TShip).Position, GetPlayer.Position) then
      begin
        if not IsCursorImageSelected('TalkFull') then SetCursorByName('TalkFull');
      end
      else if not IsCursorImageSelected('TalkSmall') then SetCursorByName('TalkSmall');
    end
    else if not IsCursorImageSelected('TalkSmall') then SetCursorByName('TalkSmall');
  end
  else if InterceptorSelectionActive then
  begin
    Obj := FindObjectAtCursor;
    if Obj is TShip then
    begin
      Point := (Obj as TShip).Position;
      if (PointDistanceSquared(Point, GetPlayer.Position) <= 1000000) and ((Obj as TShip).InterceptorPassesRemaining = 0) then
      begin
        if not IsCursorImageSelected('InterceptorsFull') then SetCursorByName('InterceptorsFull');
      end
      else if not IsCursorImageSelected('InterceptorsSmall') then SetCursorByName('InterceptorsSmall');
    end
    else if not IsCursorImageSelected('InterceptorsSmall') then SetCursorByName('InterceptorsSmall');
  end
  else if CustomSelectionActive then
  begin
    Obj := FindObjectAtCursor;
    Point.X := 0;
    Point.Y := 0;
    // Native checks the cached CursorObject class but reads the current hit object's position.
    if CursorObject is TShip then Point := TShip(Obj).Position
    else if CursorObject is TMissile then Point := TMissile(Obj).Position
    else if CursorObject is TAsteroid then Point := TAsteroid(Obj).Position
    else if CursorObject is TItem then Point := TItem(Obj).Position
    else if CursorObject is TPlanet then Point := TPlanet(Obj).GetPosition
    else if CursorObject is THole then
    begin
      if THole(Obj).Star1 = PlayerStar then Point := THole(Obj).Position1
      else Point := THole(Obj).Position2;
    end;
    if PointDistanceSquared(GetPlayer.Position, Point) > CustomSelectionRadius * CustomSelectionRadius then
    begin
      if not IsCursorImageSelected(CustomSelectionDeniedCursor) then SetCursorByName(CustomSelectionDeniedCursor);
    end
    else
    begin
      ActionResult := 0;
      if CustomSelectionItem <> nil then
      begin
        if CustomSelectionItem.ScriptItem <> nil then
          ActionResult := TScriptItem(CustomSelectionItem.ScriptItem).RunActionCode($36, GetPlayer, Obj, nil, ActionResult);
        if CustomSelectionItem is TEquipmentWithActCode then
          ActionResult := RunItemConfigActionCode(CustomSelectionItem, $36, GetPlayer, Obj, nil, ActionResult);
      end
      else
      begin
        for Index := 0 to GetPlayer.CustomShipInfos.Count - 1 do
        begin
          Info := GetPlayer.CustomShipInfos[Index];
          if not Info.DeleteQueued and (Info.TypeName = CustomSelectionInfoName) then
          begin
            ActionResult := RunCustomShipInfoActionCode(Info, $36, GetPlayer, Obj, nil, ActionResult);
            Break;
          end;
        end;
      end;
      if ActionResult > 0 then
      begin
        if not IsCursorImageSelected(CustomSelectionAllowedCursor) then SetCursorByName(CustomSelectionAllowedCursor);
      end
      else if not IsCursorImageSelected(CustomSelectionDeniedCursor) then SetCursorByName(CustomSelectionDeniedCursor);
    end;
  end
  else if AnyWeapon then
  begin
    Obj := FindObjectAtCursor;
    if (Obj is TShip) or (Obj is TItem) or (Obj is TAsteroid) or (Obj is TMissile) then
    begin
      Range := -999999999;
      for Index := 0 to 4 do
        if SelectedWeapons[Index] then
        begin
          Weapon := GetPlayer.FindEquippedItemInSlot($32, Index) as TWeapon;
          if GetPlayer.GetWeaponActionRange(Weapon) > Range then Range := GetPlayer.GetWeaponActionRange(Weapon);
        end;
      if Obj is TShip then Point := (Obj as TShip).Position
      else if Obj is TItem then Point := (Obj as TItem).Position
      else if Obj is TAsteroid then Point := (Obj as TAsteroid).Position
      else if Obj is TMissile then Point := (Obj as TMissile).Position;
      if PointDistanceSquared(Point, GetPlayer.Position) <= Sqr(Range) then
      begin
        if not IsCursorImageSelected('FireFull') then SetCursorByName('FireFull');
      end
      else if not IsCursorImageSelected('FireSmall') then SetCursorByName('FireSmall');
    end
    else if not IsCursorImageSelected('FireSmall') then SetCursorByName('FireSmall');
  end
  else
  begin
    Obj := FindObjectAtCursor;
    if (Obj is TItem) and CanCargoHookHandleItem(Obj as TItem, GetPlayer) and not GetPlayer.IsRecentlyDroppedItem(TItem(Obj)) then
    begin
      if not IsCursorImageSelected('Take') then SetCursorByName('Take');
    end
    else if MapControls.Dragging then
    begin
      if not IsCursorImageSelected('Scroll') then SetCursorByName('Scroll');
    end
    else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  end;
end;
{ @end $7BD4A4 }

{ @routine $7BDECC TfStarMap_UpdateWeaponPanelPosition }
procedure TfStarMap.UpdateWeaponPanelPosition;
var
  Progress: Single;
begin
  if WeaponPanelProgress < 0 then WeaponPanelProgress := 0
  else if WeaponPanelProgress > 1 then WeaponPanelProgress := 1;
  WeaponPanel.SetActive(WeaponPanelProgress > 0);
  Progress := PanelSlideCurve[Round(15 * WeaponPanelProgress)];
  WeaponPanel.SetPosition(Classes.Point(WeaponPanel.LocalPosition.X,
    WeaponPanelRestTop + WeaponPanel.ClientSize.Y - Round(WeaponPanel.ClientSize.Y * Progress)));
  ShowSpacePanelButton.SetActive(not StarMapWeaponPanelOpen);
  HideSpacePanelButton.SetActive(StarMapWeaponPanelOpen);
end;
{ @end $7BDECC }

{ @routine $7BDFEC TfStarMap_AnimateWeaponPanel }
procedure TfStarMap.AnimateWeaponPanel(Target: Integer);
begin
  WeaponPanelTarget := Target;
  if WeaponPanelTimer <> nil then
  begin
    CancelCallbackTimer(WeaponPanelTimer);
    WeaponPanelTimer := nil;
  end;
  WeaponPanelTimer := ScheduleCallbackTimer(30, 30, AdvanceWeaponPanel);
  UpdateWeaponPanelPosition;
end;
{ @end $7BDFEC }

{ @routine $7BE060 TfStarMap_AdvanceWeaponPanel }
procedure TfStarMap.AdvanceWeaponPanel(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if WeaponPanelTarget <= 0.0 then
  begin
    WeaponPanelProgress := WeaponPanelProgress - 0.07;
    if WeaponPanelProgress <= 0 then
    begin
      WeaponPanelProgress := 0;
      if WeaponPanelTimer <> nil then
      begin
        CancelCallbackTimer(WeaponPanelTimer);
        WeaponPanelTimer := nil;
      end;
    end;
  end
  else if WeaponPanelTarget >= 1.0 then
  begin
    WeaponPanelProgress := WeaponPanelProgress + 0.07;
    if WeaponPanelProgress >= 1 then
    begin
      WeaponPanelProgress := 1;
      if WeaponPanelTimer <> nil then
      begin
        CancelCallbackTimer(WeaponPanelTimer);
        WeaponPanelTimer := nil;
      end;
    end;
  end;
  UpdateWeaponPanelPosition;
end;
{ @end $7BE060 }

{ @routine $7BE188 TfStarMap_UpdateSpacePanelPosition }
procedure TfStarMap.UpdateSpacePanelPosition;
var
  Progress: Single;
begin
  if SpacePanelProgress < 0 then SpacePanelProgress := 0
  else if SpacePanelProgress > 1 then SpacePanelProgress := 1;
  SpacePanel.SetActive(SpacePanelProgress > 0);
  Progress := PanelSlideCurve[Round(15 * SpacePanelProgress)];
  SpacePanel.SetPosition(Classes.Point(SpacePanel.LocalPosition.X,
    SpacePanelRestTop + SpacePanel.ClientSize.Y - Round(SpacePanel.ClientSize.Y * Progress)));
end;
{ @end $7BE188 }

{ @routine $7BE278 TfStarMap_AnimateSpacePanel }
procedure TfStarMap.AnimateSpacePanel(Target: Integer);
begin
  SpacePanelTarget := Target;
  if SpacePanelTimer <> nil then
  begin
    CancelCallbackTimer(SpacePanelTimer);
    SpacePanelTimer := nil;
  end;
  SpacePanelTimer := ScheduleCallbackTimer(30, 30, AdvanceSpacePanel);
  UpdateSpacePanelPosition;
end;
{ @end $7BE278 }

{ @routine $7BE2EC TfStarMap_AdvanceSpacePanel }
procedure TfStarMap.AdvanceSpacePanel(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if SpacePanelTarget <= 0.0 then
  begin
    SpacePanelProgress := SpacePanelProgress - 0.07;
    if SpacePanelProgress <= 0 then
    begin
      SpacePanelProgress := 0;
      if SpacePanelTimer <> nil then
      begin
        CancelCallbackTimer(SpacePanelTimer);
        SpacePanelTimer := nil;
      end;
    end;
  end
  else if SpacePanelTarget >= 1.0 then
  begin
    SpacePanelProgress := SpacePanelProgress + 0.07;
    if SpacePanelProgress >= 1 then
    begin
      SpacePanelProgress := 1;
      if SpacePanelTimer <> nil then
      begin
        CancelCallbackTimer(SpacePanelTimer);
        SpacePanelTimer := nil;
      end;
    end;
  end;
  UpdateSpacePanelPosition;
end;
{ @end $7BE2EC }

{ @routine $7BE414 TfStarMap_ProcessMouseWheel }
procedure TfStarMap.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  FollowMode: Integer;
  Ship: TShip;
begin
  if (Mode = smmOrders) and ((GetPlayer.Order = soFollowShip) or (PendingPlayerFollowTarget <> nil)) then
  begin
    ClearPathOverlay(True);
    if PendingPlayerFollowTarget <> nil then
    begin
      Ship := PendingPlayerFollowTarget;
      FollowMode := 1;
    end
    else if Byte(GetPlayer.OrderStateData) = 1 then
    begin
      Ship := GetPlayer.OrderTarget as TShip;
      FollowMode := 3;
    end
    else
    begin
      Ship := GetPlayer.OrderTarget as TShip;
      FollowMode := 2;
    end;
    if Delta = WHEEL_DELTA then
    begin
      Inc(FollowMode);
      if FollowMode > 3 then FollowMode := 1;
    end
    else if Delta = -WHEEL_DELTA then
    begin
      Dec(FollowMode);
      if FollowMode < 1 then FollowMode := 3;
    end;
    Galaxy.CheckIntegrityChecksum(89);
    if FollowMode = 1 then
      if not GetPlayer.CanSelectShipTarget(Ship) then FollowMode := 2;
    if FollowMode = 1 then
    begin
        GetPlayer.OrderNone(False);
        PendingPlayerFollowTarget := Ship;
        ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveAuto'));
    end
    else if FollowMode = 2 then
    begin
        PendingPlayerFollowTarget := nil;
        GetPlayer.OrderFollowShip(Ship, 0, False);
        ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveNear'));
    end
    else if FollowMode = 3 then
    begin
        PendingPlayerFollowTarget := nil;
        GetPlayer.OrderFollowShip(Ship, 1, False);
        ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveShot'));
    end;
    Galaxy.PrimeIntegrityChecksum(90);
    BuildShipPathOverlay(GetPlayer, False, '');
  end;
end;
{ @end $7BE414 }

{ @routine $7BE69C GetTurnFilmFrameInterval }
function GetTurnFilmFrameInterval(Activity: Integer): Integer;
begin
  if Activity = 0 then Result := 18
  else if Activity = 1 then Result := 14
  else Result := 10;
  if FilmSpeed = 0 then Inc(Result, 2)
  else if FilmSpeed = 2 then Dec(Result, 2)
  else if FilmSpeed = 3 then Result := Round(Result / 2);
end;
{ @end $7BE69C }

{ @routine $7BE710 TfStarMap_StartTurnFilm }
procedure TfStarMap.StartTurnFilm;
begin
  DisplayedFilmObject := nil;
  MapControls.MouseMoveCallback := FilmMouseMove;
  ScrollLeftHeld := False;
  ScrollRightHeld := False;
  ScrollUpHeld := False;
  ScrollDownHeld := False;
  FilmStepIndex := -1;
  TrailingEffectSteps := 0;
  BreakRequested := BreakOnNextFilm;
  Flag19F := True;
  MainPanel.Show;
  MainPanel.DisableNavigationButtons;
  MainPanel.RebuildMessageButtons(False);
  SwapTurnFilms;
  SpaceProcess.RadarRange := SecondaryFilm.RadarRange;
  SpaceProcess.ActionRange := SecondaryFilm.RadarRange;
  SpaceProcess.ActionColor := CurrentPixelFormat.PackRgbBytes(0, 255, 0);
  MainPanel.SetDateRange(SecondaryFilm.Turn, SecondaryFilm.Turn + 1);
  if SecondaryFilm.PlayerCombatRecorded and not BattleMusicSelected and not DoNotChangeMusicInBattle then
  begin
    if not MusicInSpaceEnabled then MusicManager.RequestFadeOut
    else MusicManager.PlayCategory('Battle');
  end;
  CenterShipButton.DownCallback := CenterFilmShipClicked;
  CenterShipButton.MouseEnterCallback := CenterFilmShipMouseEnter;
  CenterShipButton.MouseLeaveCallback := CenterFilmShipMouseLeave;
  with GetByName('PM_Break') as TGraphButtonGI do
  begin
    SetActive(True);
    SetDisabled(False);
    UpCallback := BreakTurnClicked;
  end;
  ContinueTurnCalculation := False;
  FilmProgressTimer := ScheduleCallbackTimer(50, 50, UpdateTurnCalculation);
  NextFilmCommand := SecondaryFilm.FirstCommand;
  Mode := smmTurnFilm;
  FilmFrameIntervalMs := GetTurnFilmFrameInterval(SecondaryFilm.InitialActivity);
  if SecondaryFilm.InitialActivity = SecondaryFilm.FinalActivity then FilmFrameIntervalDelta := 0
  else FilmFrameIntervalDelta := (GetTurnFilmFrameInterval(SecondaryFilm.FinalActivity) - GetTurnFilmFrameInterval(SecondaryFilm.InitialActivity)) / 180.0;
  if FilmFrameTimer <> nil then
  begin
    CancelCallbackTimer(FilmFrameTimer);
    FilmFrameTimer := nil;
  end;
  FilmFrameTimer := ScheduleCallbackTimer(Round(FilmFrameIntervalMs), Round(FilmFrameIntervalMs), AdvanceFilmFrame);
  FilmCameraTargetUntilStep := 0;
  FilmCameraEventIndex := 0;
  FilmCameraTargetKind := 0;
  FilmCameraPosition := PointToPointF(GetMapCenter);
  FilmCameraTarget := FilmCameraPosition;
  ReservedFilmState1E4 := 0;
  FilmCameraMoving := False;
  AdvanceFilmFrame(nil, 0);
  ReservedFilmState1A0 := 0;
  if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  if CenterShipButton.IsHovered then CenterFilmShipMouseEnter(nil);
end;
{ @end $7BE710 }

{ @routine $7BEB60 TfStarMap_StopTurnFilm }
procedure TfStarMap.StopTurnFilm(StopTurnProcessing: Boolean);
begin
  DisplayedFilmObject := nil;
  Mode := smmInactive;
  (GetByName('PM_Break') as TGraphButtonGI).SetDisabled(True);
  if StopTurnProcessing and ContinueTurnCalculation then WaitForTurnCalculationUI;
  if FilmProgressTimer <> nil then
  begin
    CancelCallbackTimer(FilmProgressTimer);
    FilmProgressTimer := nil;
  end;
  if FilmFrameTimer <> nil then
  begin
    CancelCallbackTimer(FilmFrameTimer);
    FilmFrameTimer := nil;
  end;
  CenterShipButton.DownCallback := nil;
  MapControls.MouseMoveCallback := nil;
  MainPanel.ClearMessageButtons;
  MainPanel.Hide;
end;
{ @end $7BEB60 }

{ @routine $7BEC70 TfStarMap_RestartTurnFilm }
procedure TfStarMap.RestartTurnFilm;
begin
  DisplayedFilmObject := nil;
  MainPanel.RebuildMessageButtons(False);
  RebuildPartnerButtons;
  FilmStepIndex := -1;
  if FilmProgressTimer <> nil then
  begin
    CancelCallbackTimer(FilmProgressTimer);
    FilmProgressTimer := nil;
  end;
  FilmProgressTimer := ScheduleCallbackTimer(50, 50, UpdateTurnCalculation);
  ContinueTurnCalculation := False;
  BreakRequested := BreakOnNextFilm;
  (GetByName('PM_Break') as TGraphButtonGI).UpCallback := BreakTurnClicked;
  SwapTurnFilms;
  MainPanel.SetDateRange(SecondaryFilm.Turn, SecondaryFilm.Turn + 1);
  NextFilmCommand := SecondaryFilm.FirstCommand;
  FilmFrameIntervalMs := GetTurnFilmFrameInterval(SecondaryFilm.InitialActivity);
  if SecondaryFilm.InitialActivity = SecondaryFilm.FinalActivity then FilmFrameIntervalDelta := 0
  else FilmFrameIntervalDelta := (GetTurnFilmFrameInterval(SecondaryFilm.FinalActivity) - GetTurnFilmFrameInterval(SecondaryFilm.InitialActivity)) / 180.0;
  if FilmFrameTimer <> nil then
  begin
    CancelCallbackTimer(FilmFrameTimer);
    FilmFrameTimer := nil;
  end;
  FilmFrameTimer := ScheduleCallbackTimer(Round(FilmFrameIntervalMs), Round(FilmFrameIntervalMs), AdvanceFilmFrame);
  FilmCameraTargetUntilStep := 0;
  FilmCameraEventIndex := 0;
  FilmCameraTargetKind := 0;
  FilmCameraPosition := PointToPointF(GetMapCenter);
  FilmCameraTarget := FilmCameraPosition;
  ReservedFilmState1E4 := 0;
  FilmCameraMoving := False;
  AdvanceFilmFrame(nil, 0);
  if CenterShipButton.IsHovered then CenterFilmShipMouseEnter(nil);
end;
{ @end $7BEC70 }

{ @routine $7BEF24 TfStarMap_ProcessTurnFilm }
procedure TfStarMap.ProcessTurnFilm;
var
  WaitResult: Cardinal;
  Events: array[0..1] of THandle;
  EventList: Pointer;
  Index: Integer;
  Request: PScriptABRequest;
  Stage: Integer;
begin
  Stage := 0;
  try
    if TrailingFilmEffects <> nil then
    begin
      Stage := 1;
      TrailingFilmEffects.AdvanceEffects;
      if TrailingFilmEffects.FirstEntry = nil then
      begin
        TrailingFilmEffects.Free;
        TrailingFilmEffects := nil;
      end;
    end;
    Stage := 2;
    SpaceProcess.Space.AdvanceTimers;
    if (TrailingEffectSteps <= 0) and (NextFilmCommand <> nil) then
    begin
      Stage := 3;
      if NextFilmCommand = nil then RaiseWideMessage('film step')
      else if NextFilmCommand.Kind = efcBeginTrailingEffects then
      begin
        Stage := 4;
        if TrailingFilmEffects = nil then TrailingFilmEffects := TEFilmEnd.Create;
        TrailingFilmEffects.TakeTrailingEffects(SecondaryFilm);
        Inc(FilmStepIndex);
        NextFilmCommand := NextFilmCommand.Next;
      end
      else
      begin
        Stage := 5;
        Inc(FilmStepIndex);
        while NextFilmCommand <> nil do
        begin
          if NextFilmCommand.Kind = efcBeginTrailingEffects then Break;
          if not ((NextFilmCommand.Kind = efcAttachObject) and
            ((Galaxy.TerronToStarTurn and $40000000) <> 0) and
            (PEFilmObjectCommand(NextFilmCommand).Obj.GraphKey = 'Ruins.Terron')) then
          begin
            if NextFilmCommand.StepIndex > FilmStepIndex then Break;
            Stage := 6;
            SecondaryFilm.ExecuteCommand(SpaceProcess, NextFilmCommand, False);
          end;
          NextFilmCommand := NextFilmCommand.Next;
        end;
      end;
    end;
    Stage := 7;
    MainPanel.DateSlideProgress := FilmStepIndex / 200;
    if MainPanel.DateSlideProgress > 1 then MainPanel.DateSlideProgress := 1;
    MainPanel.RefreshDate;
    UpdateFilmCamera;
    Stage := 8;
    if TrailingEffectSteps > 0 then
    begin
      Stage := 9;
      Dec(TrailingEffectSteps);
      if TrailingEffectSteps <= 0 then
      begin
        Stage := 10;
        StopTurnFilm(True);
        GameEndReason := 0;
        RequestedScreenId := screenGameEnd;
        ReleaseAllTextureSurfaces;
        RequestClose(1);
      end;
    end
    else if NextFilmCommand = nil then
    begin
      Stage := 11;
      if (GetPlayer = nil) and (SecondaryFilm.Turn >= Galaxy.CurrentTurn) then
        TrailingEffectSteps := 200
      else if (GetPlayer <> nil) and GetPlayer.InHyperspace and not GetPlayer.Graphic.IsAttachedToSpace then
      begin
        Stage := 12;
        StopTurnFilm(True);
        if GetPlayer.Order = soJumpHole then
        begin
          Stage := 13;
          if GetPlayer.OrderTarget is THole then
            ArcadeBattleScreen.SelectedMapName := (GetPlayer.OrderTarget as THole).ArcadeMapName
          else ArcadeBattleScreen.SelectedMapName := '';
          if Pos('SkipAB', ArcadeBattleScreen.SelectedMapName) <> 1 then
            RequestedScreenId := screenArcadeBattle
          else
          begin
            RequestedScreenId := screenJump;
            ArcadeBattleScreen.SelectedMapName := '';
          end;
          for Index := 0 to Galaxy.Scripts.Count - 1 do TScript(Galaxy.Scripts[Index]).RunTurnCode;
          if QueuedArcadeBattles.Count > 0 then
          begin
            Stage := 14;
            Request := PScriptABRequest(QueuedArcadeBattles[0]);
            RequestedScreenId := screenArcadeBattle;
            ArcadeBattleScreen.SelectedMapName := Request.MapName;
            ScriptArcadeReturnScreenId := Ord(CurrentScreenId);
          end;
        end
        else
        begin
          Stage := 15;
          if (Galaxy <> nil) and Galaxy.IsOldHyperspaceEnabled and (GetPlayer.Order <> soTeleport) then
            RequestedScreenId := screenArcadeBattle
          else RequestedScreenId := screenJump;
        end;
        Stage := 16;
        if GetPlayer.Order = soJumpHole then LoadPanel.SelectBackgroundStyle(2)
        else LoadPanel.SelectBackgroundStyle(1);
        LoadPanel.RefreshBackgroundImages;
        LoadPanel.StartClosingShutters;
        ReleaseAllTextureSurfaces;
      end
      else if (GetPlayer <> nil) and not PlayerAutomaticControl and GetPlayer.IsOnPlanet and not GetPlayer.Graphic.IsAttachedToSpace then
      begin
        Stage := 17;
        StopTurnFilm(True);
        if not IsTurnCalculationRunningUI and (TurnCalculationPhase = tcpPlayerStarFinished) then QueueGalaxyTurnCalculation;
        if GetPlayer.CurrentPlanet.OwnerId = Byte(oiUninhabited) then
        begin
          if GetPlayer.GetEngine <> nil then
            GetPlayer.ApplyItemDegradation(GetPlayer.GetEngine, idkUse, NextRandomUnitFloat(GetPlayer.RandomState) * 15);
          RequestedScreenId := screenPlanetNO;
        end
        else RequestedScreenId := screenPlanet;
        LoadPanel.SelectBackgroundStyle(0);
        LoadPanel.RefreshBackgroundImages;
        LoadPanel.StartClosingShutters;
        ReleaseAllTextureSurfaces;
      end
      else if (GetPlayer <> nil) and not PlayerAutomaticControl and GetPlayer.IsDockedToShip and not GetPlayer.Graphic.IsAttachedToSpace then
      begin
        Stage := 18;
        StopTurnFilm(True);
        if not IsTurnCalculationRunningUI and (TurnCalculationPhase = tcpPlayerStarFinished) then QueueGalaxyTurnCalculation;
        if GetPlayer.DockedTo = TerronShip then
        begin
          Stage := 19;
          PlanetBattleMapId := -1;
          for Index := 0 to High(RobotMapDefinitions) do
            if RobotMapDefinitions[Index].Terron then
            begin
              PlanetBattleMapId := RobotMapDefinitions[Index].Id;
              Break;
            end;
          if PlanetBattleMapId < 0 then RaiseWideMessage('terron map');
          PlanetBattleState := 1;
          RequestedScreenId := screenStarMap;
          LoadPanel.SelectBackgroundStyle(3);
          LoadPanel.RefreshBackgroundImages;
          LoadPanel.StartClosingShutters;
        end
        else
        begin
          Stage := 20;
          RequestedScreenId := screenRuinsTalk;
          LoadPanel.SelectBackgroundStyle(0);
          LoadPanel.RefreshBackgroundImages;
          LoadPanel.StartClosingShutters;
          ReleaseAllTextureSurfaces;
        end;
      end
      else
      begin
        Stage := 21;
        if not ContinueTurnCalculation and ShouldContinuePlayerTravel then
          if not BreakRequested or (GetPlayer = nil) or GetPlayer.IsOnPlanet then
          begin
            WaitForTurnCalculationUI;
            UpdateTurnCalculation(nil, 0);
          end;
        if ContinueTurnCalculation then
        begin
          Stage := 22;
          if IsTurnCalculationRunningUI then
          begin
            Events[0] := TurnCalculationThread.IdleEvent;
            Events[1] := TalkRequestEvent;
            EventList := @Events;
            WaitResult := WaitForMultipleObjects(Length(Events), EventList, False, INFINITE);
          end
          else WaitResult := WAIT_OBJECT_0;
          Stage := 23;
          if WaitResult = WAIT_FAILED then
            raise Exception.Create('Error GetLastError()=' + IntToStr(Int64(GetLastError)))
          else if WaitResult = WAIT_OBJECT_0 then
          begin
            Stage := 24;
            QueueInterfaceImages;
            if (GetPlayer <> nil) and not GetPlayer.InHyperspace then
            begin
              UpdateTerronTransformation;
              QueueGalaxyTurnCalculation;
            end;
            if BreakRequested then
            begin
              RestartTurnFilm;
              BreakRequested := True;
            end
            else RestartTurnFilm;
          end
          else if WaitResult = WAIT_OBJECT_0 + 1 then
          begin
            Stage := 25;
            StopTurnFilm(False);
            RunTalkDialogs;
            WaitForTurnOrTalk;
          end;
        end
        else
        begin
          Stage := 26;
          StopTurnFilm(True);
          QueueInterfaceImages;
          if IsTurnCalculationRunningUI then WaitForTurnCalculationUI;
          Stage := 27;
          QueuePlayerStarPreparation;
          Stage := 28;
          StartScriptRequestThread;
          Events[0] := TurnCalculationThread.IdleEvent;
          Events[1] := TalkRequestEvent;
          EventList := @Events;
          WaitResult := WaitForMultipleObjects(Length(Events), EventList, False, INFINITE);
          if (TurnCalculationThread.IdleEvent = 0) or (WaitResult = WAIT_OBJECT_0) then
          begin
            AnimateSpacePanelOnResume := True;
            StartOrderMode;
          end
          else if WaitResult = WAIT_FAILED then
            raise Exception.Create('Error GetLastError()=' + IntToStr(Int64(GetLastError)))
          else if WaitResult = WAIT_OBJECT_0 + 1 then
          begin
            Stage := 29;
            RunTalkDialogs;
            Stage := 30;
            WaitForTurnOrTalk;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in TfStarMap.FilmStep, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $7BEF24 }

{ @routine $7BFB44 TfStarMap_AdvanceFilmFrame }
procedure TfStarMap.AdvanceFilmFrame(Timer: PCallbackTimerGI; UserData: Integer);
begin
  ProcessTurnFilm;
  if FilmFrameIntervalDelta <> 0.0 then
  begin
    FilmFrameIntervalMs := FilmFrameIntervalMs + FilmFrameIntervalDelta;
    if FilmFrameIntervalDelta < 0.0 then
    begin
      if FilmFrameIntervalMs < GetTurnFilmFrameInterval(SecondaryFilm.FinalActivity) then
      begin
        FilmFrameIntervalMs := GetTurnFilmFrameInterval(SecondaryFilm.FinalActivity);
        FilmFrameIntervalDelta := 0.0;
      end;
    end
    else if FilmFrameIntervalMs > GetTurnFilmFrameInterval(SecondaryFilm.FinalActivity) then
    begin
      FilmFrameIntervalMs := GetTurnFilmFrameInterval(SecondaryFilm.FinalActivity);
      FilmFrameIntervalDelta := 0.0;
    end;
    if FilmFrameTimer <> nil then
    begin
      CancelCallbackTimer(FilmFrameTimer);
      FilmFrameTimer := nil;
    end;
    FilmFrameTimer := ScheduleCallbackTimer(Round(FilmFrameIntervalMs), Round(FilmFrameIntervalMs), AdvanceFilmFrame);
  end;
end;
{ @end $7BFB44 }

{ @routine $7BFCB0 TfStarMap_UpdateTurnCalculation }
procedure TfStarMap.UpdateTurnCalculation(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if BreakRequested and (GetPlayer <> nil) and not GetPlayer.IsOnPlanet then
    ContinueTurnCalculation := False
  else if not IsTurnCalculationRunningUI and
    (((BeginCalcNextTurn < 1.0) and (FilmStepIndex > Round(BeginCalcNextTurn * 200.0))) or
    ((BeginCalcNextTurn >= 1.0) and (FilmStepIndex > Round(AdaptiveBeginCalcNextTurn * 200.0)))) then
  begin
    ContinueTurnCalculation := ShouldContinuePlayerTravel;
    if ContinueTurnCalculation and (TurnCalculationPhase = tcpGalaxyFinished) then
    begin
      MainPanel.TryAutoTurnSave;
      QueuePlayerStarTurnCalculation;
    end;
    if FilmProgressTimer <> nil then
    begin
      CancelCallbackTimer(FilmProgressTimer);
      FilmProgressTimer := nil;
    end;
  end;
end;
{ @end $7BFCB0 }

{ @routine $7BFDF8 TfStarMap_BreakTurnClicked }
procedure TfStarMap.BreakTurnClicked(Sender: TObjectGI);
begin
  ShowLargeHelp(LookupLocalizedTextByKey('Help.MoveBreak'));
  BreakRequested := True;
  (GetByName('PM_Break') as TGraphButtonGI).SetDisabled(True);
end;
{ @end $7BFDF8 }

{ @routine $7BFEB8 TfStarMap_UpdateFilmCamera }
procedure TfStarMap.UpdateFilmCamera;
var
  BestPriority, BestIndex: Integer;
  Center: TPoint;
  HalfSize: TPoint;
  Vector, TopLeft, BottomRight: TPointF;
  Distance, Speed: Single;
  ViewRect: TRect;
begin
  if FilmStepIndex > 200 then Exit;
  if (FilmStepIndex = 0) and not SecondaryFilm.ForceCameraMovement then
  begin
    HalfSize.X := GameScreenWidth shr 2;
    HalfSize.Y := GameScreenHeight shr 2;
    FilmCameraMoving := (FilmCameraPosition.X - HalfSize.X > SecondaryFilm.CameraAnchor.X) or
      (FilmCameraPosition.X + HalfSize.X <= SecondaryFilm.CameraAnchor.X) or
      (FilmCameraPosition.Y - HalfSize.Y > SecondaryFilm.CameraAnchor.Y) or
      (FilmCameraPosition.Y + HalfSize.Y <= SecondaryFilm.CameraAnchor.Y);
  end;
  if FilmCameraMoving or SecondaryFilm.ForceCameraMovement or (SecondaryFilm.CameraEventCount <> 0) then
  begin
    if FilmCameraTargetUntilStep <= FilmStepIndex then
    begin
      BestPriority := -1;
      BestIndex := -1;
      while FilmCameraEventIndex < SecondaryFilm.CameraEventCount do
      begin
        if PEFilmCameraEventArray(SecondaryFilm.CameraEvents)[FilmCameraEventIndex].StepIndex >= FilmStepIndex + FilmCameraLookAheadSteps then Break;
        if PEFilmCameraEventArray(SecondaryFilm.CameraEvents)[FilmCameraEventIndex].Priority > BestPriority then
        begin
          BestPriority := PEFilmCameraEventArray(SecondaryFilm.CameraEvents)[FilmCameraEventIndex].Priority;
          BestIndex := FilmCameraEventIndex;
        end;
        Inc(FilmCameraEventIndex);
      end;
      if BestIndex >= 0 then
      begin
        FilmCameraTargetUntilStep := PEFilmCameraEventArray(SecondaryFilm.CameraEvents)[BestIndex].StepIndex + FilmCameraLookAheadSteps;
        HalfSize.X := (GameScreenWidth shr 1) - GiScalePixels(100);
        HalfSize.Y := (GameScreenHeight shr 1) - GiScalePixels(100);
        ViewRect.Left := Round(FilmCameraPosition.X - HalfSize.X);
        ViewRect.Top := Round(FilmCameraPosition.Y - HalfSize.Y);
        ViewRect.Right := Round(FilmCameraPosition.X + HalfSize.X);
        ViewRect.Bottom := Round(FilmCameraPosition.Y + HalfSize.Y);
        with ViewRect, PEFilmCameraEventArray(SecondaryFilm.CameraEvents)[BestIndex] do
        begin
          if (Left > StartPosition.X) or (Right <= StartPosition.X) or
             (Top > StartPosition.Y) or (Bottom <= StartPosition.Y) or
             (Left > EndPosition.X) or (Right <= EndPosition.X) or
             (Top > EndPosition.Y) or (Bottom <= EndPosition.Y) then
          begin
            Vector.X := EndPosition.X - StartPosition.X;
            Vector.Y := EndPosition.Y - StartPosition.Y;
            Distance := Sqrt(Sqr(Vector.X) + Sqr(Vector.Y));
            if Distance = 0 then FilmCameraTarget := StartPosition
            else
            begin
              Vector.X := Vector.X / Distance;
              Vector.Y := Vector.Y / Distance;
              Distance := Math.Min(Distance, GiScalePixels(600));
              FilmCameraTarget.X := StartPosition.X + Vector.X * Distance * 0.5;
              FilmCameraTarget.Y := StartPosition.Y + Vector.Y * Distance * 0.5;
            end;
          end;
        end;
        FilmCameraTargetKind := 1;
      end
      else
      begin
        FilmCameraTargetKind := 0;
        FilmCameraTargetUntilStep := FilmStepIndex + FilmCameraLookAheadSteps;
      end;
    end;
    if FilmCameraTargetKind = 0 then
    begin
      if (SpaceProcess.RadarCenter.X <> SecondaryFilm.CameraAnchor.X) or
         (SpaceProcess.RadarCenter.Y <> SecondaryFilm.CameraAnchor.Y) then
      begin
        Vector.X := (GameScreenWidth shr 1) - GiScalePixels(150);
        Vector.Y := (GameScreenHeight shr 1) - GiScalePixels(150);
        TopLeft := SubtractPointsF(SpaceProcess.RadarCenter, Vector);
        BottomRight := AddPointsF(SpaceProcess.RadarCenter, Vector);
        if SegmentIntersectsRectEdges(SpaceProcess.RadarCenter, SecondaryFilm.CameraAnchor, TopLeft, BottomRight, Vector) then
          FilmCameraTarget := Vector
        else FilmCameraTarget := SecondaryFilm.CameraAnchor;
      end
      else FilmCameraTarget := SpaceProcess.RadarCenter;
    end;
    if (FilmStepIndex <> 0) and FilmCameraFollow then
    begin
      Center := GetMapCenter;
      if (Center.X <> Round(FilmCameraPosition.X - FilmCameraShakeOffset.X)) or
         (Center.Y <> Round(FilmCameraPosition.Y - FilmCameraShakeOffset.Y)) then
      begin
        FilmCameraPosition.X := Center.X - FilmCameraShakeOffset.X;
        FilmCameraPosition.Y := Center.Y - FilmCameraShakeOffset.Y;
      end;
      Vector.X := FilmCameraTarget.X - FilmCameraPosition.X;
      Vector.Y := FilmCameraTarget.Y - FilmCameraPosition.Y;
      Distance := Sqrt(Sqr(Vector.X) + Sqr(Vector.Y));
      if Distance <= 2 then
      begin
        FilmCameraMoving := False;
        FilmCameraPosition := FilmCameraTarget;
      end
      else
      begin
        Vector.X := Vector.X / Distance;
        Vector.Y := Vector.Y / Distance;
        Speed := Math.Max(1, Distance * 0.1);
        if Speed > FilmCameraSpeed then Speed := Math.Min(Speed, FilmCameraSpeed * 1.1)
        else if Speed < FilmCameraSpeed then Speed := Math.Max(Speed, FilmCameraSpeed * 0.9);
        FilmCameraSpeed := Speed;
        FilmCameraPosition.X := FilmCameraPosition.X + Vector.X * Speed;
        FilmCameraPosition.Y := FilmCameraPosition.Y + Vector.Y * Speed;
      end;
      FilmCameraShakeOffset.X := Sin(FilmCameraShakeAngle) * GiScalePixels(30);
      FilmCameraShakeOffset.Y := -Cos(FilmCameraShakeAngle) * GiScalePixels(30);
      FilmCameraShakeAngle := FilmCameraShakeAngle + Pi / 256;
      SetMapCenter(Classes.Point(Round(FilmCameraPosition.X + FilmCameraShakeOffset.X),
        Round(FilmCameraPosition.Y + FilmCameraShakeOffset.Y)));
    end;
  end;
end;
{ @end $7BFEB8 }

{ @routine $7C07CC TfStarMap_CenterFilmShipClicked }
procedure TfStarMap.CenterFilmShipClicked(Sender: TObjectGI);
begin
  FilmCameraFollow := True;
  FilmCameraMoving := True;
end;
{ @end $7C07CC }

{ @routine $7C07F0 TfStarMap_CenterFilmShipMouseEnter }
procedure TfStarMap.CenterFilmShipMouseEnter(Sender: TObjectGI);
begin
  if IsTurnCalculationRunning and ((TurnCalculationThread.Job = tcjPreparePlayerStar) or (Integer(TurnCalculationThread.Job) = 5)) then Exit;
  if GetPlayer <> nil then ShowFilmObjectInfo(GetPlayer.Graphic, GetPlayer.Id);
end;
{ @end $7C07F0 }

{ @routine $7C084C TfStarMap_CenterFilmShipMouseLeave }
procedure TfStarMap.CenterFilmShipMouseLeave(Sender: TObjectGI);
begin
  ShowFilmObjectInfo(nil, 0);
end;
{ @end $7C084C }

{ @routine $7C0868 TfStarMap_FilmMouseMove }
procedure TfStarMap.FilmMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Obj: TObjectSE;
  ObjectId: Cardinal;
begin
  if Sender.IsOccludedAtPoint(Point) or ((KeyState and MK_RBUTTON) = MK_RBUTTON) then Exit;
  if not PtInRect(ScrollInteriorRect, Point) then ShowFilmObjectInfo(nil, 0)
  else
  begin
    if not ScrollLeftHeld and not ScrollRightHeld and not ScrollUpHeld and not ScrollDownHeld then
    begin
      Obj := FindFilmObjectAtCursor(ObjectId);
      ShowFilmObjectInfo(Obj, ObjectId);
    end;
  end;
end;
{ @end $7C0868 }

{ @routine $7C0914 TfStarMap_FindFilmObjectAtCursor }
function TfStarMap.FindFilmObjectAtCursor(out ObjectId: Cardinal): TObjectSE;
var Point: TPoint; Obj: TEFilmObj;
begin
  if MainPanel.BackgroundImage.HitTestPixel(GetCursorPoint) then
  begin
    Result := nil;
    ObjectId := 0;
    Exit;
  end;
  Point := MapControls.ToLocalPoint(GetCursorPoint);
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is TMissileSE) and Obj.SceneObject.HitTestCursor then
    begin
      Result := Obj.SceneObject;
      ObjectId := Obj.ObjectId;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is TShip2SE) and Obj.SceneObject.HitTestCursor then
    begin
      Result := Obj.SceneObject;
      ObjectId := Obj.ObjectId;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is TContainerSE) and Obj.SceneObject.HitTestCursor then
    begin
      Result := Obj.SceneObject;
      ObjectId := Obj.ObjectId;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is TRuinsSE) and Obj.SceneObject.HitTestCursor then
    begin
      Result := Obj.SceneObject;
      ObjectId := Obj.ObjectId;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is TAsteroidSE) and Obj.SceneObject.HitTestCursor then
    begin
      Result := Obj.SceneObject;
      ObjectId := Obj.ObjectId;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is TPlanetSE) then
    begin
      if (Obj.SceneObject as TPlanetSE).IsRuins then
      begin
        if Obj.SceneObject.HitTestCursor then
        begin
          Result := Obj.SceneObject;
          ObjectId := Obj.ObjectId;
          Exit;
        end;
      end
      else if Sqr(Point.X - Obj.SceneObject.Position.X) + Sqr(Point.Y - Obj.SceneObject.Position.Y) < Sqr((Obj.SceneObject as TPlanetSE).Radius) then
      begin
        Result := Obj.SceneObject;
        ObjectId := Obj.ObjectId;
        Exit;
      end;
    end;
    Obj := Obj.Next;
  end;
  if Sqr((SecondaryFilm.ObjectInfo as TEObjInfo).StarRadius) > Point.X * Point.X + Point.Y * Point.Y then
  begin
    Obj := SecondaryFilm.FirstObject;
    while Obj <> nil do
    begin
      if (Obj.SceneObject <> nil) and (Obj.SceneObject is TStarSE) then
      begin
        Result := Obj.SceneObject;
        ObjectId := Obj.ObjectId;
        Exit;
      end;
      Obj := Obj.Next;
    end;
  end;
  Obj := SecondaryFilm.FirstObject;
  while Obj <> nil do
  begin
    if (Obj.SceneObject <> nil) and (Obj.SceneObject is THoleSE) then
      if PointDistanceSquared(Obj.SceneObject.Position, PointToPointF(Point)) <
        Sqr(THoleSE(Obj.SceneObject).HitRadius) then
      begin
        Result := Obj.SceneObject;
        ObjectId := Obj.ObjectId;
        Exit;
      end;
    Obj := Obj.Next;
  end;
  Result := nil;
  ObjectId := 0;
end;
{ @end $7C0914 }

{ @routine $7C0DA8 TfStarMap_ShowFilmObjectInfo }
procedure TfStarMap.ShowFilmObjectInfo(Obj: TObjectSE; ObjectId: Cardinal);

const
  WearableItemTypes = [0..79] - [0..7,9,23..25,35..38,42,69..72,74..79];

var
  I, J, RowHeight, RowX: Integer;
  IconInset: Cardinal;
  NameWidth, DetailWidth, StatusCount: Integer;
  Planet: PEPlanetInfo;
  Ship: PEShipInfo;
  Item: PEItemInfo;
  Asteroid: PEAsteroidInfo;
  Missile: PEMissileInfo;
  Text: WideString;
  Panel: TPanelGI;
  Objects, Records: TList;
  Distance: Single;
  OwnerId: Byte;
  Snapshot: TEObjInfo;
  FilmObject: TEFilmObj;
  ImagePath, ColorTag: WideString;
  Child: TObjectGI;
  DamageName, DamageValue: TLabelGI;
  IsCivilized: Boolean;
  ActivePanel: TObjectGI;
  BarWidth, CapWidth, MinimumWidth: Integer;
  CustomInfo: PECustomSystemInfo;
  Images: WideString;
  { Local order and repeated layout calls follow the original DCC32 frame. }
begin
  Item := nil;
  Asteroid := nil;
  Planet := nil;
  Ship := nil;
  Missile := nil;
  if (Obj is TStarSE) and (TerronShip <> nil) and
     (TerronShip.CurrentStar.Id = ObjectId) and (Galaxy.TerronToStarTurn >= $40000000) then
  begin
    ShowObjectInfo(TerronShip);
    Exit;
  end;
  Snapshot := SecondaryFilm.ObjectInfo as TEObjInfo;
  if Obj <> nil then
  begin
    if Obj is TPlanetSE then Planet := (SecondaryFilm.ObjectInfo as TEObjInfo).FindPlanet(ObjectId);
    if (Obj is TShip2SE) or (Obj is TRuinsSE) then Ship := (SecondaryFilm.ObjectInfo as TEObjInfo).FindShip(ObjectId);
    if Obj is TContainerSE then Item := (SecondaryFilm.ObjectInfo as TEObjInfo).FindItem(ObjectId);
    if Obj is TAsteroidSE then Asteroid := (SecondaryFilm.ObjectInfo as TEObjInfo).FindAsteroid(ObjectId);
    if Obj is TMissileSE then Missile := (SecondaryFilm.ObjectInfo as TEObjInfo).FindMissile(ObjectId);
  end;
  if (Obj = nil) or ((Obj is TPlanetSE) and (Planet = nil)) or
     ((Obj is TShip2SE) and (Ship = nil)) or ((Obj is TRuinsSE) and (Ship = nil)) or
     ((Obj is TContainerSE) and (Item = nil)) or ((Obj is TAsteroidSE) and (Asteroid = nil)) or
     ((Obj is TMissileSE) and (Missile = nil)) then
  begin
    InfoWindow.SetActive(False);
    ItemInfoWindow.SetActive(False);
    ShipInfoPanel.SetActive(False);
    PlanetInfoPanel.SetActive(False);
    StarInfoWindow.SetActive(False);
    StandardInfoPanel.SetActive(False);
    DisplayedFilmObject := nil;
    DisplayedObject := nil;
    Exit;
  end;
  if (Obj is TPlanetSE) or (Obj is THoleSE) or
     ((Obj is TContainerSE) and (PointDistance(Obj.Position, SpaceProcess.RadarCenter) > SecondaryFilm.RadarRange)) or
     (((Obj is TShip2SE) or (Obj is TRuinsSE)) and (PointDistance(Obj.Position, SpaceProcess.RadarCenter) > SecondaryFilm.RadarRange)) or
     ((Obj is TAsteroidSE) and (PointDistance(Obj.Position, SpaceProcess.RadarCenter) > SecondaryFilm.RadarRange)) or
     ((Obj is TMissileSE) and (PointDistance(Obj.Position, SpaceProcess.RadarCenter) > SecondaryFilm.RadarRange)) then
  begin
    HitObjectPosition := Classes.Point(Round(Obj.Position.X) - GetMapCenter.X, Round(Obj.Position.Y) - GetMapCenter.Y);
    HitObjectSize := Obj.Size;
    if DisplayedFilmObject <> Obj then
    begin
      InfoWindow.SetActive(False);
      ItemInfoWindow.SetActive(False);
      ShipInfoPanel.SetActive(False);
      PlanetInfoPanel.SetActive(False);
      StarInfoWindow.SetActive(False);
      StandardInfoPanel.SetActive(True);
      if Obj is TContainerSE then
      begin
        GetByName('InfoStdGB').SetActive(False);
        with GetByName('InfoStdImage') as TImageGI do
        begin
          SetActive(True);
          SetImagePath(Item^.ImagePath);
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
        end;
        if Item^.ItemType in [t_Food..t_Narcotics] then
        begin
          (GetByName('InfoStdName') as TLabelGI).SetText(Item^.Name);
          (GetByName('InfoStdText') as TLabelGI).SetText(Item^.InfoText);
        end
        else
        begin
          (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(LocalizedText(
                                                         'FormInfo.ContainerName'), InfoNameColorTag));
          (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
        end;
        (GetByName('InfoItemSize') as TLabelGI).SetText('???');
        (GetByName('InfoItemPrice') as TLabelGI).SetText('???');
        ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as
        TLabelGI, True, True, 0);
      end
      else if (Obj is TShip2SE) or (Obj is TRuinsSE) then
           begin
             if Obj is TShip2SE then
             begin
               GetByName('InfoStdImage').SetActive(False);
               with GetByName('InfoStdGB') as TGraphBufGI do
               begin
                 ImagePath := Ship^.PortraitImage;
                 SetActive(ImagePath <> '');
                 if Active then
                 begin
                   SourceHasPerPixelAlpha := True;
                   LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(ImagePath, 1, ','), GraphBuf);
                   if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                   begin
                     if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                       GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.
                                                                                                                   Height)), 5
                       )
                     else
                       GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),
                       ClientSize.Y, 5);
                   end;
                   SetImageKindX(ikxCenter);
                   SetImageKindY(ikyCenter);
                   SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
                 end;
               end;
             end
             else
             begin
               GetByName('InfoStdImage').SetActive(False);
               with GetByName('InfoStdGB') as TGraphBufGI do
               begin
                 SetActive(True);
                 SourceHasPerPixelAlpha := True;
                 LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((Obj as TRuinsSE).StaticImagePath, 1, ','), GraphBuf);

                 if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                 begin
                   if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                     GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height
                     )), 5)
                   else
                     GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize
                     .Y, 5);
                 end;
                 SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
               end;
             end;
             (GetByName('InfoStdName') as TLabelGI).SetText(Ship^.FullName);
             (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
             ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText')
             as TLabelGI, True, True, 0);
           end
      else if Obj is TPlanetSE then
           begin
             IsCivilized := (Planet^.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and
                            ((MainPiratePlanet = nil) or (Planet^.Id <> MainPiratePlanet.Id));
             if IsCivilized then
             begin
               if Planet^.OwnerId = Byte(oiPirate) then
                 IsCivilized := Planet^.Faction = OwnerInfo[Ord(oiPirate)].InternalName + RaceToSys(Planet^.RaceId)
               else
                 IsCivilized := Planet^.Faction = OwnerInfo[Planet^.OwnerId].InternalName;
             end;
             if IsCivilized then
             begin
               InfoWindow.SetActive(False);
               ItemInfoWindow.SetActive(False);
               ShipInfoPanel.SetActive(False);
               PlanetInfoPanel.SetActive(True);
               StarInfoWindow.SetActive(False);
               StandardInfoPanel.SetActive(False);
               (GetByName('InfoPlanetName') as TLabelGI).SetText(WrapTextInColor(Planet^.Name, InfoNameColorTag));
               if Planet^.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)] then
               begin
                 with GetByName('InfoPlanetEmRace') as TImageGI do
                 begin
                   SetImagePath(GetFactionEmblemPath(Planet^.Faction));
                   SetImageKindX(ikxCenter);
                   SetImageKindY(ikyCenter);
                   SetActive(True);
                 end;
               end
               else GetByName('InfoPlanetEmRace').SetActive(False);
               with GetByName('InfoPlanetImage') as TGraphBufGI do
               begin
                 SourceHasPerPixelAlpha := True;
                 (Obj as TPlanetSE).RenderToBuffer(Self, GraphBuf, False);

                 if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                 begin
                   if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                     GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height
                     )), 5)
                   else
                     GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize
                     .Y, 5);
                 end;
               end;
               if (MainPiratePlanet <> nil) and (Planet^.Id = MainPiratePlanet.Id) then
                 (GetByName('InfoPlanetOwner') as TLabelGI).SetText(OwnerInfo[Planet^.OwnerId].DisplayName)
               else
                 (GetByName('InfoPlanetOwner') as TLabelGI).SetText(OwnerInfo[Ord(TOwnerId(RaceToOwner(Planet^.RaceId)))].
                 DisplayName);
               (GetByName('InfoPlanetPop') as TLabelGI).SetText(IntToStr(Round(Planet^.Population / 1000)));
               (GetByName('InfoPlanetEco') as TLabelGI).SetText(PlanetEconomyInfo[Ord(Planet^.Economy)].DisplayName);
               (GetByName('InfoPlanetGov') as TLabelGI).SetText(PlanetGovernmentMarket[Ord(Planet^.Government)].DisplayName);
               (GetByName('InfoPlanetRel') as TLabelGI).SetText(RelationInfo[Ord(Planet^.Relation)].DisplayName);
               ShipScreen.LayoutObjectInfo(PlanetInfoPanel as TWindowGI, GetByName('InfoPlanetName') as TLabelGI,
               GetByName('IPOwner') as TLabelGI,
               GetByName('InfoPlanetOwner') as TLabelGI,
               GetByName('IPPop') as TLabelGI,
               GetByName('InfoPlanetPop') as TLabelGI,
               GetByName('IPEco') as TLabelGI,
               GetByName('InfoPlanetEco') as TLabelGI,
               GetByName('IPGov') as TLabelGI,
               GetByName('InfoPlanetGov') as TLabelGI,
               GetByName('IPRel') as TLabelGI,
               GetByName('InfoPlanetRel') as TLabelGI,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               GetByName('InfoPlanetEmRace'),
               True,
               0);
             end
             else
             begin
               GetByName('InfoStdImage').SetActive(False);
               with GetByName('InfoStdGB') as TGraphBufGI do
               begin
                 SetActive(True);
                 SourceHasPerPixelAlpha := True;
                 (Obj as TPlanetSE).RenderToBuffer(Self, GraphBuf, False);

                 if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                 begin
                   if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                     GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height
                     )), 5)
                   else
                     GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize
                     .Y, 5);
                 end;
                 SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
               end;
               (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(Planet^.Name, InfoNameColorTag));
               if Planet^.OwnerId = Byte(oiUninhabited) then
               begin
                 Text := LocalizedText('Planet.NotCivil.Info.TextAboutPlanet');
                 if Planet^.UnexploredWater > 0 then
                   ReplaceTextToken(Text, '<Water>', IntToStr(Planet^.UnexploredWater), '<color=255,240,100>')
                 else ReplaceTextToken(Text, '<Water>', '-', '');
                 if Planet^.UnexploredLand > 0 then
                   ReplaceTextToken(Text, '<Land>', IntToStr(Planet^.UnexploredLand), '<color=255,240,100>')
                 else ReplaceTextToken(Text, '<Land>', '-', '');
                 if Planet^.UnexploredHills > 0 then
                   ReplaceTextToken(Text, '<Hill>', IntToStr(Planet^.UnexploredHills), '<color=255,240,100>')
                 else ReplaceTextToken(Text, '<Hill>', '-', '');
                 if GetPlayer <> nil then
                   if GetPlayer.CountActiveArtefacts(Ord(t_ArtefactAnalyzer)) > 0 then Text := Text + #13#10 + Planet^.TreasureHint;
               end
               else if (MainPiratePlanet <> nil) and (Planet^.Id = MainPiratePlanet.Id) then
                    begin
                      if Planet^.OwnerId = Byte(oiPirate) then
                        Text := LocalizedText('Planet.MainPiratePlanet.Info.TextAboutPlanet')
                      else Text := LocalizedText('Planet.MainPiratePlanet.Info.TextAboutPlanetAlt');
                    end
               else
               begin
                 IsCivilized := Planet^.OwnerId = Byte(oiDominator);
                 if IsCivilized then
                   IsCivilized := (Planet^.Faction = DominatorSeriesNames[0]) or
                                  (Planet^.Faction = DominatorSeriesNames[2]) or (Planet^.Faction = DominatorSeriesNames[1]);
                 if IsCivilized then Text := LocalizedText('Planet.Kling.Info.TextAboutPlanet')
                 else Text := LocalizedText('Planet.' + Planet^.Faction + '.Info.TextAboutPlanet');
                 ReplaceTextToken(Text, '<Race>', OwnerInfo[Ord(TOwnerId(RaceToOwner(Planet^.RaceId)))].DisplayName,
                 '<color=255,240,100>');
               end;
               (GetByName('InfoStdText') as TLabelGI).SetText(Text);
               ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName(
                                                                                                                       'InfoStdText'
               ) as TLabelGI, True, True, 0);
             end;
           end
      else if Obj is TAsteroidSE then
           begin
             GetByName('InfoStdImage').SetActive(False);
             with GetByName('InfoStdGB') as TGraphBufGI do
             begin
               SetActive(True);
               SourceHasPerPixelAlpha := True;
               LoadGaiFrameToGraphBuf((Obj as TAsteroidSE).ImagePath, GraphBuf, ObjectId);

               if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
               begin
                 if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                   GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),
                   5)
                 else
                   GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y,
                   5);
               end;
               SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
             end;
             (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(Asteroid^.Name, InfoNameColorTag));
             (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
             ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText')
             as TLabelGI, True, True, 0);
           end
      else if Obj is TMissileSE then
           begin
             GetByName('InfoStdImage').SetActive(False);
             with GetByName('InfoStdGB') as TGraphBufGI do
             begin
               SetActive(True);
               SourceHasPerPixelAlpha := True;
               LoadGiByPathIntoGraphBuf('Bm.' + Obj.GraphKey + '_' + GiResourceSuffix + 'i', GraphBuf);
               SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
             end;
             (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(Missile^.Name, InfoNameColorTag));
             (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText('FormInfo.ObjOutOfRange'));
             ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText')
             as TLabelGI, True, True, 0);
           end
      else if Obj is THoleSE then
           begin
             GetByName('InfoStdImage').SetActive(False);
             with GetByName('InfoStdGB') as TGraphBufGI do
             begin
               SetActive(True);
               SourceHasPerPixelAlpha := True;
               LoadGaiFrameToGraphBuf((Obj as THoleSE).ImagePath, GraphBuf, 32);

               if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
               begin
                 if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                   GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),
                   5)
                 else
                   GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y,
                   5);
               end;
               SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
             end;
             (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(LocalizedText(THoleSE(Obj).
             NameTextPath), InfoNameColorTag));
             (GetByName('InfoStdText') as TLabelGI).SetText(LocalizedText(THoleSE(Obj).InfoTextPath));
             ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText')
             as TLabelGI, True, True, 0);
           end;
      DisplayedFilmObject := Obj;
    end;
  end
  else if Obj is TContainerSE then
       begin
         HitObjectPosition := Classes.Point(Round(Obj.Position.X) - GetMapCenter.X, Round(Obj.Position.Y) - GetMapCenter.Y);
         HitObjectSize := Obj.Size;
         if DisplayedFilmObject <> Obj then
         begin
           DisplayedFilmObject := Obj;
           InfoWindow.SetActive(False);
           ItemInfoWindow.SetActive(True);
           ShipInfoPanel.SetActive(False);
           PlanetInfoPanel.SetActive(False);
           StarInfoWindow.SetActive(False);
           StandardInfoPanel.SetActive(False);
           with GetByName('InfoItemImage') as TImageGI do
           begin
             SetImagePath(Item^.ImagePath);
             SetImageKindX(ikxCenter);
             SetImageKindY(ikyCenter);
             SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
           end;
           (GetByName('InfoItemName') as TLabelGI).SetText(Item^.Name);
           (GetByName('InfoItemText') as TLabelGI).SetText(Item^.InfoText);
           (GetByName('InfoItemSize') as TLabelGI).SetText(IntToStr(Item^.Weight));
           (GetByName('InfoItemPrice') as TLabelGI).SetText(IntToStr(Item^.Cost));
           with GetByName('InfoItemEmRace') as TImageGI do
           begin
             SetImagePath(GetFactionEmblemPath(Item^.Faction));
             SetImageKindX(ikxCenter);
             SetImageKindY(ikyCenter);
           end;
           if not ((Byte(Item^.ItemType) in WearableItemTypes) or (Item^.ItemType = t_Hull)) then
           begin
             with GetByName('InfoDurable') as TImageGI do
               Parent.Parent.SetActive(False);
             MinimumWidth := 0;
           end
           else
           begin
             if Item^.ItemType = t_Hull then
               BarWidth := Round(Sqrt(Item^.Weight / HullBaseSize / Max(0.1, Item^.Fragility)) * 64)
             else BarWidth := Round(64 / Max(0.1, Item^.Fragility));
             BarWidth := Min(192, Max(32, BarWidth));
             with GetByName('InfoDurableLeft') as TImageGI do
             begin
               CapWidth := GetContentSize.X;
               MinimumWidth := CapWidth * 2 + BarWidth + LocalPosition.X + Parent.LocalPosition.X + Parent.Parent.LocalPosition.X *
                               2;
             end;
             with GetByName('InfoDurable') as TImageGI do
             begin
               Parent.Parent.SetActive(True);
               Parent.Parent.SetSize(Classes.Point(CapWidth * 2 + BarWidth, Parent.Parent.ClientSize.Y));
               Parent.SetSize(Classes.Point(BarWidth + 2, Parent.Parent.ClientSize.Y));
               SetPosition(Classes.Point(Round(BarWidth * (Item^.ConditionPercent / 100)) - (GetContentSize.X - 5), LocalPosition.Y)
               );
             end;
             with GetByName('InfoDurableRight') as TImageGI do
             begin
               SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X, LocalPosition.Y));
               Parent.SetPosition(Classes.Point(CapWidth, Parent.LocalPosition.Y));
               Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
             end;
             with GetByName('InfoDurableBack') as TImageGI do
             begin
               SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X, LocalPosition.Y));
               Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
             end;
           end;
           ShipScreen.LayoutItemInfo(ItemInfoWindow, GetByName('InfoItemName') as TLabelGI, GetByName('InfoItemText') as TLabelGI, True,
           True, MinimumWidth);
           GetByName('InfoItemSize').SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X, ItemInfoWindow.ClientSize.Y +
                                                 ShipScreen.ItemSizeLabelPosition.Y));
           GetByName('InfoItemPrice').SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X, ItemInfoWindow.ClientSize.Y +
                                                  ShipScreen.ItemPriceLabelPosition.Y));
           GetByName('InfoItemEmRace').SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X,
                                                   ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
           ShipScreen.LayoutItemInfo(ItemInfoWindow, GetByName('InfoItemName') as TLabelGI, GetByName('InfoItemText') as TLabelGI, True,
           True, 0);
         end;
       end
  else if (Obj is TShip2SE) or (Obj is TRuinsSE) then
       begin
         HitObjectPosition := Classes.Point(Round(Obj.Position.X) - GetMapCenter.X, Round(Obj.Position.Y) - GetMapCenter.Y);
         HitObjectSize := Obj.Size;
         if DisplayedFilmObject <> Obj then
         begin
           DisplayedFilmObject := Obj;
           InfoWindow.SetActive(False);
           ItemInfoWindow.SetActive(False);
           ShipInfoPanel.SetActive(True);
           PlanetInfoPanel.SetActive(False);
           StarInfoWindow.SetActive(False);
           StandardInfoPanel.SetActive(False);
           (GetByName('InfoShipName') as TLabelGI).SetText(Ship^.FullName);
           if Ship^.Faction <> 'None' then
           begin
             with GetByName('InfoShipEmRace') as TImageGI do
             begin
               SetImagePath(GetFactionEmblemPath(Ship^.Faction));
               SetImageKindX(ikxCenter);
               SetImageKindY(ikyCenter);
               SetActive(True);
             end;
           end
           else GetByName('InfoShipEmRace').SetActive(False);
           if Obj is TShip2SE then
           begin
             with GetByName('InfoShipImage2') as TGraphBufGI do
             begin
               ImagePath := Ship^.PortraitImage;
               SetActive(ImagePath <> '');
               if Active then
               begin
                 SourceHasPerPixelAlpha := True;
                 LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(ImagePath, 1, ','), GraphBuf);
                 if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                 begin
                   if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                     GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height
                     )), 5)
                   else
                     GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize
                     .Y, 5);
                 end;
                 SetImageKindX(ikxCenter);
                 SetImageKindY(ikyCenter);
                 SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
               end;
             end;
           end
           else
           begin
             with GetByName('InfoShipImage2') as TGraphBufGI do
             begin
               SetActive(True);
               SourceHasPerPixelAlpha := True;
               LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((Obj as TRuinsSE).StaticImagePath, 1, ','), GraphBuf);

               if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
               begin
                 if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                   GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),
                   5)
                 else
                   GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y,
                   5);
               end;
               SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
             end;
           end;
           if (Obj is TRuinsSE) and (Ship^.OwnerId <> Byte(oiDominator)) then
           begin
             (GetByName('ISType') as TLabelGI).SetActive(False);
             (GetByName('InfoShipType') as TLabelGI).SetActive(False);
           end
           else
           begin
             (GetByName('ISType') as TLabelGI).SetActive(True);
             (GetByName('InfoShipType') as TLabelGI).SetActive(True);
             (GetByName('InfoShipType') as TLabelGI).SetText(Ship^.TypeName);
           end;
           (GetByName('InfoShipSpeed') as TLabelGI).SetText(IntToStr(Ship^.Speed));
           if Ship^.HullPoints <= Ship^.HullCapacity / 2 then ColorTag := '<color=255,166,0>'
           else ColorTag := '';
           if Ship^.ScannerResolved then
           begin
             Text := WrapTextInColor(IntToStr(Ship^.HullPoints), ColorTag) + '/' + IntToStr(Ship^.HullCapacity);
             if Ship^.RepairPoints >= 0 then Text := Text + ' + ' + WrapTextInColor(IntToStr(Ship^.RepairPoints), '');
             (GetByName('InfoShipSize') as TLabelGI).SetText(Text);
           end
           else (GetByName('InfoShipSize') as TLabelGI).SetText(WrapTextInColor('???', ColorTag));
           (GetByName('InfoShipDef') as TLabelGI).SetText(Ship^.DefenseText);
           (GetByName('InfoShipDamage') as TLabelGI).SetText(Ship^.DamageText);
           (GetByName('InfoShipRel') as TLabelGI).SetText(RelationInfo[Ord(Ship^.Relation)].DisplayName);
           if Ship^.WinChance >= 0 then
           begin
             (GetByName('ISWin') as TLabelGI).SetActive(True);
             (GetByName('InfoShipWin') as TLabelGI).SetActive(True);
             (GetByName('InfoShipWin') as TLabelGI).SetText(IntToStr(Ship^.WinChance) + '%');
           end
           else
           begin
             (GetByName('ISWin') as TLabelGI).SetActive(False);
             (GetByName('InfoShipWin') as TLabelGI).SetActive(False);
           end;
           BarWidth := Round(Sqrt(Ship^.HullCapacity / HullBaseSize / Max(0.1, Ship^.HullFragility)) * 64);
           BarWidth := Min(192, Max(32, BarWidth));
           with GetByName('InfoShipDurableLeft') as TImageGI do
           begin
             CapWidth := GetContentSize.X;
             MinimumWidth := CapWidth * 2 + BarWidth + LocalPosition.X + Parent.LocalPosition.X + Parent.Parent.LocalPosition.X * 2;
           end;
           with GetByName('InfoShipDurable') as TImageGI do
           begin
             if Ship^.ScannerResolved then
               SetPosition(Classes.Point(Round(Ship^.HullPoints / Ship^.HullCapacity * BarWidth) - (GetContentSize.X - 5),
               LocalPosition.Y))
             else
             begin
               MinimumWidth := MinimumWidth - BarWidth + 64;
               BarWidth := 64;
               SetPosition(Classes.Point(BarWidth - (GetContentSize.X - 5), LocalPosition.Y));
             end;
             Parent.Parent.SetActive(True);
             Parent.Parent.SetSize(Classes.Point(CapWidth * 2 + BarWidth, Parent.Parent.ClientSize.Y));
             Parent.SetSize(Classes.Point(BarWidth + 2, Parent.Parent.ClientSize.Y));
           end;
           with GetByName('InfoShipDurableRight') as TImageGI do
           begin
             SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X, LocalPosition.Y));
             Parent.SetPosition(Classes.Point(CapWidth, Parent.LocalPosition.Y));
             Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
           end;
           with GetByName('InfoShipDurableBack') as TImageGI do
           begin
             SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X, LocalPosition.Y));
             Parent.SetSize(Classes.Point(BarWidth + CapWidth, Parent.ClientSize.Y));
           end;
           DamageName := GetByName('ISDamage') as TLabelGI;
           DamageValue := GetByName('InfoShipDamage') as TLabelGI;
           if Length(Ship^.DamageText) > 0 then
           begin
             DamageName.SetActive(True);
             DamageValue.SetActive(True);
           end
           else
           begin
             DamageName.SetActive(False);
             DamageValue.SetActive(False);
             DamageName := nil;
             DamageValue := nil;
           end;
           StatusCount := Ship^.CombatStatusCount;
           if StatusCount > 0 then
           begin
             (GetByName('ISEffects') as TLabelGI).SetActive(True);
             with GetByName('InfoShipEffects') as TLabelGI do
             begin
               SetText(Ship^.CombatStatusText);
               SetSize(Classes.Point(ClientSize.X, StatusCount * GetLineHeight + 2));
               SetActive(True);
             end;
           end
           else
           begin
             (GetByName('ISEffects') as TLabelGI).SetActive(False);
             (GetByName('InfoShipEffects') as TLabelGI).SetActive(False);
           end;
           ShipScreen.LayoutObjectInfo(ShipInfoPanel as TWindowGI, GetByName('InfoShipName') as TLabelGI,
           GetByName('ISType') as TLabelGI,
           GetByName('InfoShipType') as TLabelGI,
           GetByName('ISSpeed') as TLabelGI,
           GetByName('InfoShipSpeed') as TLabelGI,
           GetByName('ISSize') as TLabelGI,
           GetByName('InfoShipSize') as TLabelGI,
           GetByName('ISDef') as TLabelGI,
           GetByName('InfoShipDef') as TLabelGI,
           DamageName,
           DamageValue,
           GetByName('ISRel') as TLabelGI,
           GetByName('InfoShipRel') as TLabelGI,
           GetByName('ISWin') as TLabelGI,
           GetByName('InfoShipWin') as TLabelGI,
           GetByName('ISEffects') as TLabelGI,
           GetByName('InfoShipEffects') as TLabelGI,
           GetByName('InfoShipEmRace'),
           True,
           MinimumWidth);
         end;
       end
  else if Obj is TStarSE then
       begin
         HitObjectPosition := Classes.Point(Round(Obj.Position.X) - GetMapCenter.X, Round(Obj.Position.Y) - GetMapCenter.Y);
         HitObjectSize := Obj.Size;
         if DisplayedFilmObject <> Obj then
         begin
           DisplayedFilmObject := Obj;
           InfoWindow.SetActive(False);
           ItemInfoWindow.SetActive(False);
           ShipInfoPanel.SetActive(False);
           PlanetInfoPanel.SetActive(False);
           StarInfoWindow.SetActive(True);
           StandardInfoPanel.SetActive(False);
           (GetByName('InfoStarName') as TLabelGI).SetText(WrapTextInColor((SecondaryFilm.ObjectInfo as TEObjInfo).StarName,
           InfoNameColorTag));
           with GetByName('InfoStarImage') as TGraphBufGI do
           begin
             SourceHasPerPixelAlpha := True;
             LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((Obj as TStarSE).StaticImagePath, 1, ','), GraphBuf);

             if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
             begin
               if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                 GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
               else
                 GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
             end;
             SetImageKindX(ikxCenter);
             SetImageKindY(ikyCenter);
           end;
           Panel := GetByName('InfoStarPanel') as TPanelGI;
           Panel.FreeOwnedChildren;
           Objects := TList.Create;
           Records := TList.Create;
           FilmObject := SecondaryFilm.FirstObject;
           while FilmObject <> nil do
           begin
             if FilmObject.SceneObject <> nil then
               if FilmObject.SceneObject is TPlanetSE then
               begin
                 Planet := Snapshot.FindPlanet(FilmObject.ObjectId);
                 if Planet <> nil then
                 begin
                   Objects.Add(FilmObject.SceneObject);
                   Records.Add(Planet);
                 end;
               end;
             FilmObject := FilmObject.Next;
           end;
           FilmObject := SecondaryFilm.FirstObject;
           while FilmObject <> nil do
           begin
             if FilmObject.SceneObject <> nil then
               if ((FilmObject.SceneObject is TRuinsSE) and not TRuinsSE(FilmObject.SceneObject).HideOnStarInfo) or
                  ((FilmObject.SceneObject is TShip2SE) and ((FilmObject.SceneObject as TShip2SE).AlternateImagePath <> '')) then
                 if (FilmObject.SceneObject.GraphKey <> 'Ruins.Blazer') and
                    (FilmObject.SceneObject.GraphKey <> 'Ruins.Keller') and
                    (FilmObject.SceneObject.GraphKey <> 'Ruins.Terron') and
                    (FilmObject.SceneObject.GraphKey <> 'Ruins.FighterSwarm') then
                 begin
                   Ship := Snapshot.FindShip(FilmObject.ObjectId);
                   if Ship <> nil then
                     if not Ship^.OutsideNormalSpace then
                     begin
                       Distance := PointDistanceSquared(FilmObject.SceneObject.Position, MakePointF(0, 0));
                       J := 0;
                       while J < Objects.Count do
                       begin
                         if PointDistanceSquared(TObjectSE(Objects[J]).Position, MakePointF(0, 0)) > Distance then Break;
                         Inc(J);
                       end;
                       Objects.Insert(J, FilmObject.SceneObject);
                       Records.Insert(J, Ship);
                     end;
                 end;
             FilmObject := FilmObject.Next;
           end;
           for I := 0 to High(Snapshot.CustomSystemInfos) do
           begin
             CustomInfo := @Snapshot.CustomSystemInfos[I];
             Distance := Sqr(CustomInfo^.Distance);
             J := 0;
             while J < Objects.Count do
             begin
               if Objects[J] <> nil then
                 if PointDistanceSquared(TObjectSE(Objects[J]).Position, MakePointF(0, 0)) > Distance then Break;
               if Objects[J] = nil then
                 if PECustomSystemInfo(Records[J])^.Distance > CustomInfo^.Distance then Break;
               Inc(J);
             end;
             Objects.Insert(J, nil);
             Records.Insert(J, CustomInfo);
           end;
           RowHeight := GiScalePixels(20);
           NameWidth := GiScalePixels(100);
           DetailWidth := GiScalePixels(100);
           for I := 0 to Objects.Count - 1 do
             with TLabelGI.Create(Panel) do
             begin
               SetFontName(NormalFontName);
               SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
               SetSize(Classes.Point(1, RowHeight));
               SetPosition(Classes.Point(0, RowHeight * I));
               SetWordWrapEnabled(False);
               SetTextAlignX(taxAuto);
               SetTextAlignY(tayCenterEx);
               if Objects[I] = nil then SetText(PECustomSystemInfo(Records[I])^.Name)
               else if TObject(Objects[I]) is TPlanetSE then SetText(PEPlanetInfo(Records[I])^.Name)
               else SetText(PEShipInfo(Records[I])^.Name);
               NameWidth := Max(NameWidth, ClientSize.X);
             end;
           Child := Panel.FirstChild;
           while Child <> nil do
           begin
             if Child is TLabelGI then
               with Child as TLabelGI do
               begin
                 SetTextAlignX(taxRight);
                 SetSize(Classes.Point(NameWidth, RowHeight));
               end;
             Child := Child.NextSibling;
           end;
           for I := 0 to Objects.Count - 1 do
           begin
             with TGraphBufGI.Create(Panel, False) do
             begin
               IconInset := 0;
               if TObject(Objects[I]) is TPlanetSE then
               begin
                 if (TObject(Objects[I]) as TPlanetSE).Radius < 70 then IconInset := 4
                 else if (TObject(Objects[I]) as TPlanetSE).Radius < 80 then IconInset := 3
                 else if (TObject(Objects[I]) as TPlanetSE).Radius < 90 then IconInset := 2
                 else if (TObject(Objects[I]) as TPlanetSE).Radius < 100 then IconInset := 1
                 else IconInset := 0;
               end;
               SourceHasPerPixelAlpha := True;
               SetPosition(Classes.Point(NameWidth + 5 + 1 + (IconInset shr 1), RowHeight * I + 1 + (IconInset shr 1)));
               SetSize(Classes.Point(RowHeight - 2 - IconInset, RowHeight - 2 - IconInset));
               if Objects[I] = nil then
               begin
                 if PECustomSystemInfo(Records[I])^.ImagePath <> '' then
                 begin
                   LoadGiByPathIntoGraphBuf(PECustomSystemInfo(Records[I])^.ImagePath, GraphBuf);
                   if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                     GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height
                     )), 5)
                   else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),
                     ClientSize.Y, 5);
                 end;
               end
               else if TObject(Objects[I]) is TPlanetSE then
                    begin
                      TPlanetSE(Objects[I]).RenderToBuffer(Self, GraphBuf, True);
                      if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                      begin
                        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                          GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.
                                                                                                                      Height)),
                          5)
                        else
                          GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),
                          ClientSize.Y, 5);
                      end;
                    end
               else if TObject(Objects[I]) is TShip2SE then
                    begin
                      LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TShip2SE(Objects[I]).AlternateImagePath, 1, ','), GraphBuf);
                      if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                      begin
                        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                          GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.
                                                                                                                      Height)),
                          5)
                        else
                          GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),
                          ClientSize.Y, 5);
                      end;
                    end
               else
               begin
                 LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TRuinsSE(Objects[I]).StaticImagePath, 1, ','), GraphBuf);
                 if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                 begin
                   if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                     GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height
                     )), 5)
                   else
                     GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize
                     .Y, 5);
                 end;
               end;
               SetImageKindX(ikxCenter);
               SetImageKindY(ikyCenter);
             end;
             if Objects[I] = nil then OwnerId := Byte(oiUninhabited)
             else if TObject(Objects[I]) is TPlanetSE then OwnerId := PEPlanetInfo(Records[I])^.OwnerId
             else OwnerId := PEShipInfo(Records[I])^.OwnerId;
             if Objects[I] = nil then
             begin
               CustomInfo := Records[I];
               if (CountDelimitedPartsW(CustomInfo^.Text, ':') > 1) and
                  (ExtractDelimitedPartW(CustomInfo^.Text, 0, ':') = 'Image') then
               begin
                 Images := ExtractDelimitedPartW(CustomInfo^.Text, 1, ':');
                 RowX := NameWidth + 5 + RowHeight + 5 + 1;
                 for J := 0 to CountDelimitedPartsW(Images, ',') - 1 do
                   with TImageGI.Create(Panel) do
                   begin
                     SetImagePath('GI,' + ExtractDelimitedPartW(Images, J, ','));
                     SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                     SetPosition(Classes.Point(RowX, RowHeight * I + 1));
                     RowX := RowX + RowHeight + 2;
                   end;
               end
               else if (CountDelimitedPartsW(CustomInfo^.Text, ':') > 1) and
                       (ExtractDelimitedPartW(CustomInfo^.Text, 0, ':') = 'RGBA') then
                    begin
                      Images := ExtractDelimitedPartW(CustomInfo^.Text, 1, ':');
                      RowX := NameWidth + 5 + RowHeight + 5 + 1;
                      for J := 0 to CountDelimitedPartsW(Images, ',') - 1 do
                        with TGraphBufGI.Create(Panel, False) do
                        begin
                          SourceHasPerPixelAlpha := True;
                          LoadBitmapPathAsRgba(ExtractDelimitedPartW(Images, J, ',') + '?RGBA');
                          SetPosition(Classes.Point(RowX, RowHeight * I + 1));
                          SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                          if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                          begin
                            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(
                                                                                                                      GraphBuf
                                                                                                                          .
                                                                                                                        Height
                              )), 5)
                            else
                              GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),
                              ClientSize.Y, 5);
                          end;
                          SetImageKindX(ikxCenter);
                          SetImageKindY(ikyCenter);
                          RowX := RowX + RowHeight + 2;
                        end;
                    end
               else
                 with TLabelGI.Create(Panel) do
                 begin
                   if GiResourceVariant = 2 then SetFontName(MiniFontName)
                   else SetFontName(SmallFontName);
                   SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
                   SetSize(Classes.Point(1, RowHeight));
                   SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
                   SetWordWrapEnabled(False);
                   SetTextAlignX(taxAuto);
                   SetTextAlignY(tayCenterEx);
                   SetText(CustomInfo^.Text);
                   DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
                 end;
             end
             else if (TObject(Objects[I]) is TRuinsSE) or (TObject(Objects[I]) is TShip2SE) then
                  begin
                    with TLabelGI.Create(Panel) do
                    begin
                      if GiResourceVariant = 2 then SetFontName(MiniFontName)
                      else SetFontName(SmallFontName);
                      SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
                      SetSize(Classes.Point(1, RowHeight));
                      SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
                      SetWordWrapEnabled(False);
                      SetTextAlignX(taxAuto);
                      SetTextAlignY(tayCenterEx);
                      SetText(LowerCaseWideString(PEShipInfo(Records[I])^.TypeName));
                      DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
                    end;
                  end
             else if OwnerId <> Byte(oiUninhabited) then
                    if (TObject(Objects[I]) is TPlanetSE) and
                       ((MainPiratePlanet = nil) or (PEPlanetInfo(Records[I])^.Id <> MainPiratePlanet.Id)) then
                      with TGraphBufGI.Create(Panel, False) do
                      begin
                        SourceHasPerPixelAlpha := True;
                        LoadBitmapPathAsRgba(ExtractDelimitedPartW(GetFactionEmblemPath(PEPlanetInfo(Records[I])^.Faction), 1, ',')
                        + '?RGBA');
                        SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I + 1));
                        SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                        if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
                        begin
                          if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                            GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.
                                                                                                                        Height)),
                            5)
                          else
                            GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),
                            ClientSize.Y, 5);
                        end;
                        SetImageKindX(ikxCenter);
                        SetImageKindY(ikyCenter);
                      end;
             IsCivilized := (TObject(Objects[I]) is TPlanetSE) and
                            (PEPlanetInfo(Records[I])^.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and
                            ((MainPiratePlanet = nil) or (PEPlanetInfo(Records[I])^.Id <> MainPiratePlanet.Id));
             if IsCivilized then
             begin
               if PEPlanetInfo(Records[I])^.OwnerId = Byte(oiPirate) then
                 IsCivilized := PEPlanetInfo(Records[I])^.Faction = OwnerInfo[Ord(oiPirate)].InternalName + RaceToSys(PEPlanetInfo(Records[I])^.
                                RaceId)
               else IsCivilized := PEPlanetInfo(Records[I])^.Faction = OwnerInfo[PEPlanetInfo(Records[I])^.OwnerId].InternalName;
             end;
             if IsCivilized then
             begin
               RowX := NameWidth + 5 + RowHeight + 5 + 1;
               with TImageGI.Create(Panel) do
               begin
                 case PEPlanetInfo(Records[I])^.Relation of
                   rlHostile: SetImagePath('GI,Bm.FormGalaxy2.Face4');
                   rlBad: SetImagePath('GI,Bm.FormGalaxy2.Face3');
                   rlNormal: SetImagePath('GI,Bm.FormGalaxy2.Face2'); { Native explicit case, also repeated by the default. }
                   rlGood: SetImagePath('GI,Bm.FormGalaxy2.Face1');
                   rlExcellent: SetImagePath('GI,Bm.FormGalaxy2.Face0');
                   else SetImagePath('GI,Bm.FormGalaxy2.Face2');
                 end;
                 SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                 SetPosition(Classes.Point(RowX + RowHeight + 2, RowHeight * I + 1));
               end;
               RowX := RowX + RowHeight + 2;
               if PEPlanetInfo(Records[I])^.Economy in [peAgricultural, peIndustrial] then
                 with TImageGI.Create(Panel) do
                 begin
                   case PEPlanetInfo(Records[I])^.Economy of
                     peAgricultural: SetImagePath('GI,Bm.FormGalaxy.EconAgrar');
                     peIndustrial: SetImagePath('GI,Bm.FormGalaxy.EconIndustr');
                   end;
                   SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
                   SetPosition(Classes.Point(RowX + RowHeight, RowHeight * I + 1));
                 end;
             end
             else if (TObject(Objects[I]) is TPlanetSE) and (MainPiratePlanet <> nil) and
                     (PEPlanetInfo(Records[I])^.Id = MainPiratePlanet.Id) then
                  begin
                    with TLabelGI.Create(Panel) do
                    begin
                      if GiResourceVariant = 2 then SetFontName(MiniFontName)
                      else SetFontName(SmallFontName);
                      SetTextColor(GetStyleColorGI('StarInfoObjectType', 40, 237, 245));
                      SetSize(Classes.Point(1, RowHeight));
                      SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
                      SetWordWrapEnabled(False);
                      SetTextAlignX(taxAuto);
                      SetTextAlignY(tayCenterEx);
                      SetText(LowerCaseWideString(LocalizedText('ShipType.TypeName.PB')));
                      DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
                    end;
                  end
             else if (TObject(Objects[I]) is TPlanetSE) and (PEPlanetInfo(Records[I])^.OwnerId = Byte(oiUninhabited)) and
                     (PEPlanetInfo(Records[I])^.UnexploredWater = 0) and (PEPlanetInfo(Records[I])^.UnexploredLand = 0) and
                     (PEPlanetInfo(Records[I])^.UnexploredHills = 0) then
                  begin
                    with TLabelGI.Create(Panel) do
                    begin
                      if GiResourceVariant = 2 then SetFontName(MiniFontName)
                      else SetFontName(SmallFontName);
                      SetTextColor(CurrentPixelFormat.PackRgbBytes(140, 140, 140));
                      SetSize(Classes.Point(1, RowHeight));
                      SetPosition(Classes.Point(NameWidth + 5 + RowHeight + 5 + 1, RowHeight * I));
                      SetWordWrapEnabled(False);
                      SetTextAlignX(taxAuto);
                      SetTextAlignY(tayCenterEx);
                      SetText(LowerCaseWideString(LocalizedText('Planet.NotCivil.AllExplore')));
                      DetailWidth := Max(DetailWidth, ClientSize.X + GiScalePixels(35));
                    end;
                  end;
           end;
           Panel.SetSize(Classes.Point(NameWidth + DetailWidth, RowHeight * Objects.Count));
           StarInfoWindow.SetSize(Classes.Point(Panel.ClientSize.X + StarInfoWindow.WorkSubRect.Left + StarInfoWindow.WorkSubRect.Right,
                                  StarInfoWindow.WorkSubRect.Top + StarInfoWindow.WorkSubRect.Bottom + RowHeight * Objects.Count));
           StarInfoWindow.UpdateAutoGeometry;
           Objects.Free;
           Records.Free;
         end;
       end
  else if Obj is TAsteroidSE then
       begin
         HitObjectPosition := Classes.Point(Round(Obj.Position.X) - GetMapCenter.X, Round(Obj.Position.Y) - GetMapCenter.Y);
         HitObjectSize := Obj.Size;
         if DisplayedFilmObject <> Obj then
         begin
           DisplayedFilmObject := Obj;
           InfoWindow.SetActive(False);
           ItemInfoWindow.SetActive(False);
           ShipInfoPanel.SetActive(False);
           PlanetInfoPanel.SetActive(False);
           StarInfoWindow.SetActive(False);
           StandardInfoPanel.SetActive(True);
           GetByName('InfoStdImage').SetActive(False);
           with GetByName('InfoStdGB') as TGraphBufGI do
           begin
             SetActive(True);
             SourceHasPerPixelAlpha := True;
             LoadGaiFrameToGraphBuf((Obj as TAsteroidSE).ImagePath, GraphBuf, ObjectId);

             if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
             begin
               if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                 GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
               else
                 GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
             end;
             SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
           end;
           (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(Asteroid^.Name, InfoNameColorTag));
           (GetByName('InfoStdText') as TLabelGI).SetText(Asteroid^.InfoText);
           ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as
           TLabelGI, True, True, 0);
         end;
       end
  else if Obj is TMissileSE then
       begin
         HitObjectPosition := Classes.Point(Round(Obj.Position.X) - GetMapCenter.X, Round(Obj.Position.Y) - GetMapCenter.Y);
         HitObjectSize := Obj.Size;
         if DisplayedFilmObject <> Obj then
         begin
           DisplayedFilmObject := Obj;
           InfoWindow.SetActive(False);
           ItemInfoWindow.SetActive(False);
           ShipInfoPanel.SetActive(False);
           PlanetInfoPanel.SetActive(False);
           StarInfoWindow.SetActive(False);
           StandardInfoPanel.SetActive(True);
           GetByName('InfoStdImage').SetActive(False);
           with GetByName('InfoStdGB') as TGraphBufGI do
           begin
             SetActive(True);
             SourceHasPerPixelAlpha := True;
             LoadGiByPathIntoGraphBuf('Bm.' + Obj.GraphKey + '_' + GiResourceSuffix + 'i', GraphBuf);
             SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
           end;
           (GetByName('InfoStdName') as TLabelGI).SetText(WrapTextInColor(Missile^.Name, InfoNameColorTag));
           (GetByName('InfoStdText') as TLabelGI).SetText(Missile^.InfoText);
           ShipScreen.LayoutItemInfo(StandardInfoPanel as TWindowGI, GetByName('InfoStdName') as TLabelGI, GetByName('InfoStdText') as
           TLabelGI, True, True, 0);
         end;
       end;
  if Obj is TContainerSE then HitObjectSize := Classes.Point(38, 38);
  if Obj is TStarSE then HitObjectSize := Classes.Point(300, 300);
  if InfoWindow.Active then ActivePanel := InfoWindow
  else if ItemInfoWindow.Active then ActivePanel := ItemInfoWindow
  else if ShipInfoPanel.Active then ActivePanel := ShipInfoPanel
  else if PlanetInfoPanel.Active then ActivePanel := PlanetInfoPanel
  else if StarInfoWindow.Active then ActivePanel := StarInfoWindow
  else if StandardInfoPanel.Active then ActivePanel := StandardInfoPanel
  else Exit;
  if DynamicTipsPos then
  begin
    Inc(HitObjectPosition.X, Cardinal(GameScreenWidth) div 2);
    Inc(HitObjectPosition.Y, Cardinal(GameScreenHeight) div 2);
    I := Cardinal(GameScreenWidth) div 3;
    if HitObjectPosition.X <= I then Inc(HitObjectPosition.X, HitObjectSize.X div 2)
    else if HitObjectPosition.X >= 2 * I then
           HitObjectPosition.X := HitObjectPosition.X - HitObjectSize.X div 2 - ActivePanel.ClientSize.X
    else
    begin
      Dec(HitObjectPosition.X, ActivePanel.ClientSize.X div 2);
      I := 0;
    end;
    if I = 0 then
    begin
      if HitObjectPosition.Y < Integer(Cardinal(GameScreenHeight) div 2) then
      begin
        Inc(HitObjectPosition.Y, HitObjectSize.Y div 2);
        if ActivePanel.ClientSize.Y + HitObjectPosition.Y + 10 > Integer(GameScreenHeight) then
          HitObjectPosition.Y := HitObjectPosition.Y - HitObjectSize.Y - ActivePanel.ClientSize.Y;
        if HitObjectPosition.Y < 10 then HitObjectPosition.Y := 10;
      end
      else HitObjectPosition.Y := HitObjectPosition.Y - HitObjectSize.Y div 2 - ActivePanel.ClientSize.Y;
    end
    else
    begin
      I := Cardinal(GameScreenHeight) div 3;
      if HitObjectPosition.Y <= I then Inc(HitObjectPosition.Y, HitObjectSize.Y div 2)
      else if HitObjectPosition.Y >= 2 * I then
             HitObjectPosition.Y := HitObjectPosition.Y - HitObjectSize.Y div 2 - ActivePanel.ClientSize.Y
      else Dec(HitObjectPosition.Y, ActivePanel.ClientSize.Y div 2);
    end;
    Dec(HitObjectPosition.X, Cardinal(GameScreenWidth) div 2);
    Dec(HitObjectPosition.Y, Cardinal(GameScreenHeight) div 2);
    ActivePanel.SetPosition(HitObjectPosition);
  end
  else ActivePanel.SetPosition(Classes.Point(10 - Cardinal(GameScreenWidth) div 2, 10 - Cardinal(GameScreenHeight) div 2));
end;
{ @end $7C0DA8 }

{ @routine $7C805C TfStarMap_PrepareTalkDisplay }
procedure TfStarMap.PrepareTalkDisplay;
begin
  FilmCameraMoving := True;
  MainPanel.Show;
  ShowObjectInfo(nil);
  if TalkShip <> nil then CenterMapForTalk(TalkShip.Position)
  else if (TalkPlanet <> nil) and (TalkPlanet.CurrentStar = GetPlayer.CurrentStar) then
    CenterMapForTalk(GetPlayer.Position);
  SpaceProcess.Space.DrawMinimap;
  SetCursorActive(False);
  DrawFrame;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
end;
{ @end $7C805C }

{ @routine $7C810C TfStarMap_WaitForTurnOrTalk }
procedure TfStarMap.WaitForTurnOrTalk;
var
  WaitResult: Cardinal;
  Events: array[0..1] of THandle;
  EventList: Pointer;
begin
  MainPanel.Hide;
  ResumeMode := smrNormal;
  // Native dormant checks precede the actual wait setup.
  if TurnCalculationThread.IdleEvent = 0 then
    if TurnCalculationThread.IdleEvent = 0 then ;
  SetEvent(TalkCompletedEvent);
  Events[0] := TurnCalculationThread.IdleEvent;
  Events[1] := TalkRequestEvent;
  EventList := @Events;
  WaitResult := WaitForMultipleObjects(Length(Events), EventList, False, INFINITE);
  if (TurnCalculationThread.IdleEvent = 0) or (WaitResult = WAIT_OBJECT_0) then
  begin
    if PlayerStarDayPrepared then
    begin
      AnimateSpacePanelOnResume := True;
      StartOrderMode;
    end
    else
    begin
      RebuildPartnerButtons;
      if (GetPlayer <> nil) and not GetPlayer.InHyperspace then
      begin
        UpdateTerronTransformation;
        QueueGalaxyTurnCalculation;
      end;
      StartTurnFilm;
    end;
  end
  else if WaitResult = WAIT_FAILED then
    raise Exception.Create('Error GetLastError()=' + IntToStr(Int64(GetLastError)))
  else if WaitResult = WAIT_OBJECT_0 + 1 then
  begin
    RunTalkDialogs;
    WaitForTurnOrTalk;
  end;
end;
{ @end $7C810C }

{ @routine $7C829C TfStarMap_UpdateTerronTransformation }
procedure TfStarMap.UpdateTerronTransformation;
var Obj: TObjectSE;
begin
  if ((Galaxy.TerronToStarTurn and $20000000) = 0) and
     ((Galaxy.TerronToStarTurn and $40000000) <> 0) and
     ((Galaxy.TerronToStarTurn and $0FFFFFFF) <= Galaxy.CurrentTurn) and
     (GetPlayer <> nil) and (GetPlayer.CurrentStar = TerronShip.CurrentStar) then
  begin
    if not AnimStar then
    begin
      Obj := SpaceProcess.Space.FirstObject;
      while Obj <> nil do
      begin
        if TerronShip.Graphic = Obj then
        begin
          Obj.DetachFromSpace;
          TerronShip.Order := soJump;
          TerronShip.OrderTarget := TerronShip.CurrentStar;
          TerronShip.InHyperspace := True;
          TerronShip.OrderStateData := 2;
          TerronShip.Position := MakePointF(0, 0);
          Break;
        end;
        Obj := Obj.Next;
      end;
      TerronShip.CurrentStar.Graphic.DetachFromSpace;
      ReleaseSpaceObject(TerronShip.CurrentStar.Graphic);
      RetainSpaceObject(TerronShip.CurrentStar.Graphic,
        CreateSpaceObjectByName('Star', 'Star.TerronAfter', Classes.Point(0, 0)));
      TerronShip.CurrentStar.Graphic.AttachToSpace(SpaceProcess.Space);
    end
    else
    begin
      Obj := SpaceProcess.Space.FirstObject;
      while Obj <> nil do
      begin
        if Obj is TStarSE then
        begin
          if not Assigned(TStarSE(Obj).Animation.CycleCompleteCallback) then
          begin
            Galaxy.TerronToStarTurn := $40000000;
            TStarSE(Obj).Animation.CycleCompleteCallback := TerronTransformationStarted;
            Obj := SpaceProcess.Space.FirstObject;
            while Obj <> nil do
            begin
              if TerronShip.Graphic = Obj then
              begin
                // CreateNormalGraphic uses Ruins.Terron, whose TRuinsSE owns these images.
                if TRuinsSE(Obj).Animation <> nil then
                begin
                  TerronFadeImage := TRuinsSE(Obj).Animation;
                  TRuinsSE(Obj).Animation := nil;
                end
                else
                begin
                  TerronFadeImage := TRuinsSE(Obj).StaticImage;
                  TRuinsSE(Obj).StaticImage := nil;
                end;
                Obj.DetachFromSpace;
                TerronShip.Order := soJump;
                TerronShip.OrderTarget := TerronShip.CurrentStar;
                TerronShip.InHyperspace := True;
                TerronShip.OrderStateData := 2;
                TerronShip.Position := MakePointF(0, 0);
                Break;
              end;
              Obj := Obj.Next;
            end;
          end;
          Break;
        end;
        Obj := Obj.Next;
      end;
    end;
  end;
end;
{ @end $7C829C }

{ @routine $7C85F4 TfStarMap_TerronTransformationStarted }
procedure TfStarMap.TerronTransformationStarted(Sender: TObjectGI);
var Image: TgaiGI;
begin
  Image := Sender as TgaiGI;
  Image.SetImagePath('Bm.Star.Terron_Transform_a');
  Image.SequenceIndex := 0;
  Image.UpdateAutoGeometry;
  Image.RestartPlayback;
  Image.CycleCompleteCallback := TerronTransformationFinished;
  Image.FrameAdvancedCallback := TerronTransformationFrame;
end;
{ @end $7C85F4 }

{ @routine $7C86A8 TfStarMap_TerronTransformationFrame }
procedure TfStarMap.TerronTransformationFrame(Sender: TObjectGI);
var Alpha: Byte; Progress: Single;
begin
  if (TerronShip <> nil) and ((Sender as TgaiGI).SequenceFrame <> 0) and (TerronFadeImage <> nil) then
  begin
    Progress := (Sender as TgaiGI).SequenceFrame / ((Sender as TgaiGI).SequenceFrameCount - 1);
    Progress := Progress * 2;
    if Progress > 1 then Progress := 1;
    Alpha := Round((1 - Progress) * 255);
    if TerronFadeImage is TgaiGI then
    begin
      if (TerronFadeImage as TgaiGI).Alpha > Alpha then
      begin
        (TerronFadeImage as TgaiGI).SetAlpha(Alpha);
        if (TerronFadeImage as TgaiGI).Alpha <= 0 then
        begin
          TerronFadeImage.Free;
          TerronFadeImage := nil;
        end;
      end;
    end
    else
    begin
      if (TerronFadeImage as TImageGI).GetAlpha > Alpha then
      begin
        (TerronFadeImage as TImageGI).SetAlpha(Alpha);
        if (TerronFadeImage as TImageGI).GetAlpha <= 0 then
        begin
          TerronFadeImage.Free;
          TerronFadeImage := nil;
        end;
      end;
    end;
  end;
end;
{ @end $7C86A8 }

{ @routine $7C8878 TfStarMap_TerronTransformationFinished }
procedure TfStarMap.TerronTransformationFinished(Sender: TObjectGI);
var
  Animation: TgaiGI;
begin
  Animation := Sender as TgaiGI;
  Animation.SetImagePath('Bm.Star.TerronAfter_a');
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  Animation.RestartPlayback;
  Animation.FrameAdvancedCallback := nil;
  Animation.CycleCompleteCallback := nil;
  Galaxy.TerronToStarTurn := Galaxy.TerronToStarTurn or $20000000;
end;
{ @end $7C8878 }

{ @routine $7C8928 TfStarMap_ExecuteUiCode }
procedure TfStarMap.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if MainPanel.NavigationLocked then Exit;
  if ShipScreen.FlagD4 then Exit;
  if ExitScreenLoop then Exit;
  if WaitForSingleObject(ScriptUiRequestEvent, 0) = WAIT_OBJECT_0 then Exit;
  if not (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) then
    WaitForTurnCalculation;
  Galaxy.CheckIntegrityChecksum(10007);
  ExecuteGameplayUiCode(Block, Key);
  Galaxy.PrimeIntegrityChecksum(20007);
end;
{ @end $7C8928 }

{ @routine $7C89C4 TfStarMap_SelectMusic }
procedure TfStarMap.SelectMusic;
begin
  if GetPlayer = nil then
  begin
    MusicManager.PlayCategory('Base');
    Exit;
  end;
  if MusicInSpaceEnabled then
  begin
    if (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
    begin
      StarMapScreen.BattleMusicSelected := True;
      MusicManager.PlayCategory('Destroyer');
    end
    else
    begin
      StarMapScreen.BattleMusicSelected := False;
      MusicManager.PlayCategory('StarMap');
    end;
  end
  else MusicManager.RequestFadeOut;
end;
{ @end $7C89C4 }

end.
