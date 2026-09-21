unit ab_MainForm;
// Unit bracket (inferred): .text 0x0053B550..0x0054BE3F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses aGalaxyStruct, Classes, aItem, EC_Buf, EC_Struct, aScript, aMyFunction, ab_Space, GI_GAI, GI_Image, GI_Label, GI_StarField, GI_Window, GI_GraphButton, GI_MessageLoop, GI_Panel, GI_PolyLine, SE_Space, fLoad, fPanelLoad, aPath, ab_Item, ab_Zone;

type
  // Variable-length map-color blocks read by LoadMap and used at
  // $544150/$5433D8. Offsets are relative to the start of each color block.
  // PInteger(@Field)^ below preserves the native separate address calculation.
  TArcadeMapColorHeader = packed record // @size $10
    CurrentColor: Integer; // @offset $00
    VariantCount: Integer; // @offset $04
    SelectedVariant: Integer; // @offset $08
    ByteSize: Integer; // @offset $0C
  end;
  PArcadeMapColorHeader = ^TArcadeMapColorHeader;
  TArcadeMapColorVariant = packed record // @size $08
    SequenceOffset: Integer; // @offset $00 Relative to the containing color header.
    AppearanceTag: Integer; // @offset $04
  end;
  PArcadeMapColorVariant = ^TArcadeMapColorVariant;
  TArcadeMapColorSequence = packed record // @size $08
    FrameIndex: Integer; // @offset $00
    FrameCount: Integer; // @offset $04 Followed by FrameCount packed 32-bit colors.
  end;
  PArcadeMapColorSequence = ^TArcadeMapColorSequence;

  TArcadeMapDrag = packed record // @size $09
    Active: Boolean; // @offset $00
    Position: TPoint; // @offset $01 Native packed drag state.
  end;

  TfAB = class(TMessageLoopGI) // @size 0x358
  public
    MapPanel: TPanelGI; // @offset $D0
    WorldPanel: TPanelGI; // @offset $D4
    StarField: TStarFieldGI; // @offset $D8
    StartStarImage: TgaiGI; // @offset $DC
    EndStarImage: TgaiGI; // @offset $E0
    ItemPanel: TPanelGI; // @offset $E4
    ItemInfoWindow: TWindowGI; // @offset $E8
    AutoButton: TGraphButtonGI; // @offset $EC
    ManualButton: TGraphButtonGI; // @offset $F0
    BattleHelpLabel: TLabelGI; // @offset $F4
    VictoryPanel: TPanelGI; // @offset $F8
    DefeatPanel: TPanelGI; // @offset $FC
    PlayerVisual: TObjectSE; // @offset $100 Retained scene object.
    PlayerMapPosition: TPointF; // @offset $104
    ShipPath: TSPath; // @offset $10C
    RouteSpaces: TList; // @offset $110
    MapDrag: TArcadeMapDrag; // @offset $114
    ScrollTimer: PCallbackTimerGI; // @offset $120
    MapBackgroundPath: WideString; // @offset $124
    WeaponButtons: array[0..4] of TObjectGI; // @offset $128 Native access includes explicit graph-button casts.
    WeaponIcons: array[0..4] of TImageGI; // @offset $13C
    WeaponChargeImages: array[0..4] of TImageGI; // @offset $150
    WeaponPrimaryImages: array[0..4] of TImageGI; // @offset $164
    WeaponSecondaryImages: array[0..4] of TImageGI; // @offset $178
    PlayButton: TGraphButtonGI; // @offset $190
    PauseButton: TGraphButtonGI; // @offset $194
    WorldLines: TPolyLineGI; // @offset $198
    UpdateTimer: PCallbackTimerGI; // @offset $19C Simulation callback TimerTakt.
    WorldCenterX: Integer; // @offset $1A0
    WorldCenterY: Integer; // @offset $1A4
    BonusIcons: array[0..7] of TImageGI; // @offset $1A8
    BonusRings: array[0..7] of TgaiGI; // @offset $1C8
    EnemyIcons: array[0..7] of TObjectGI; // @offset $1E8 Rotate-image or graph-buffer controls.
    EnemyHealthRings: array[0..7] of TgaiGI; // @offset $208
    EnemyRewardIcons: array[0..7] of TObjectGI; // @offset $228
    EnemyRewardBackdrops: array[0..7] of TObjectGI; // @offset $248
    TrackedShipIcons: array[0..7] of TObjectGI; // @offset $268
    TrackedShipHealthRings: array[0..7] of TgaiGI; // @offset $288
    CampaignWeapons: array[0..4] of TWeapon; // @offset $2A8 Borrowed equipped campaign weapons.
    ForwardKeyDown: Boolean; // @offset $2BC
    ReverseKeyDown: Boolean; // @offset $2BD
    BrakeKeyDown: Boolean; // @offset $2BE
    TurnLeftKeyDown: Boolean; // @offset $2BF
    TurnRightKeyDown: Boolean; // @offset $2C0
    PrimaryFireKeyDown: Boolean; // @offset $2C1 Ctrl.
    SecondaryFireKeyDown: Boolean; // @offset $2C2 Space/Shift.
    GridLines: TList; // @offset $2C4 Borrowed nodes owned by the world-line list.
    MapState2C8: Integer; // @offset $2C8 Reset by ClearBattle; remaining meaning unresolved.
    Text2CC: WideString; // @offset $2CC Native managed field; role unresolved.
    OverlaySegments: array[0..3] of PPolyLineSegmentGI; // @offset $2E0
    TransitionSpeed: Double; // @offset $310 Set to 10 by BeginMapTransition.
    CampaignTransitionStarted: Boolean; // @offset $318
    CampaignLoadStarted: Boolean; // @offset $319
    CampaignLoadFinished: Boolean; // @offset $31A
    CacheLoader: TCacheLoader; // @offset $31C
    DefeatCountdownTicks: Integer; // @offset $320 Starts at 150; decremented after player death.
    CampaignLoadProgress: Single; // @offset $324
    DepartureTurn: Integer; // @offset $328
    ArrivalTurn: Integer; // @offset $32C
    InfoSpace: TabSpace; // @offset $330 Space currently described by InfoPanel/InfoStar; nil when hidden.
    CargoPickupItem: TabItem; // @offset $334
    CargoPickupZone: PabZone; // @offset $338
    InitialRandomSeed: Cardinal; // @offset $33C
    RandomSeed: Cardinal; // @offset $340
    ViewModeBeforeDefeat: Byte; // @offset $344
    SimulationPaused: Boolean; // @offset $345 P/Pause toggles; distinct from route pause.
    VictoryTimer: PCallbackTimerGI; // @offset $348
    ListedObjects: TList; // @offset $34C Owned list; borrowed objects supply text to the battle list controls.
    LoadPanel: TfPanelLoad; // @offset $350 Owned.
    SelectedMapName: WideString; // @offset $354 Arena Map value supplied by the standalone selector.

    constructor Create; // @addr $53B604
    destructor Destroy; override; // @addr $53B670
    function ScreenPointToSphere(Point: TPoint; var Longitude, PolarAngle: Double): Boolean; // @addr $53EF60
    function RandomRange(BoundA, BoundB: Integer): Integer; // @addr $54B6E8
    function RandomFloat(BoundA, BoundB: Double): Double; // @addr $54B774
    procedure UpdateHelp(Sender: TObjectGI; Show: Boolean); // @addr $54B808
    procedure ControlMouseEnter(Sender: TObjectGI); // @addr $54B848
    procedure ControlMouseLeave(Sender: TObjectGI); // @addr $54B868
    procedure HideHelp; // @addr $54B880
    procedure HideObjectInfo; // @addr $54A114
    procedure TogglePause(Sender: TObjectGI); // @addr $54115C
    procedure WeaponSelect(Sender: TObjectGI); // @addr $540E1C
    procedure ToggleWeaponGroup(Sender: TObjectGI); // @addr $540E74
    procedure WeaponButtonClick(Sender: TObjectGI); // @addr $540F70
    procedure NormalizeWeaponSelection; // @addr $540F8C
    procedure ClearWeaponPanel; // @addr $540318
    procedure InvalidateFrame; // @addr $546854
    procedure DrawShipHealthBars; // @addr $5468DC
    procedure UpdateShipStatusIcons; // @addr $546E08
    procedure WeaponStateChanged(Sender: TObjectGI); // @addr $53FEC0
    procedure UpdateWeaponPanel; // @addr $53F12C
    procedure UpdateWeaponHighlights(Force: Boolean); // @addr $540534
    procedure OpenShipEquipment(Sender: TObjectGI); // @addr $54B0A8
    procedure RequestExit(Sender: TObjectGI); // @addr $53D8F4
    procedure BeginKellerDialogTransition; // @addr $548FA0
    procedure FinishCampaignTransition; // @addr $546658
    procedure ReportSurvivingShips; // @addr $541208
    procedure BeginBattleExit; // @addr $548FC0
    procedure SyncWeaponInventory; // @addr $54B290
    procedure EnterMapView; // @addr $542FC4
    procedure AdvanceMapColors; // @addr $544150
    procedure EnterCurrentSpace; // @addr $5433D8
    procedure BattleKeyDown(Sender: TObjectGI; VirtualKey: Cardinal); // @addr $53DAA4
    procedure BattleKeyUp(Sender: TObjectGI; VirtualKey: Cardinal); // @addr $53E478
    procedure BattleMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $53E654
    procedure BattleMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $53E9B8
    procedure BattleRightMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $53E9DC
    procedure BattleRightMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $53EA84
    procedure BattleMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $53EB08
    procedure BuildSpaceRoute(Route: TList; Origin, Destination: TabSpace); // @addr $548808
    procedure AppendShipPathArc(Destination: TPointF); // @addr $5481D8
    procedure AppendShipPathLine(Destination: TPointF); // @addr $5484D8
    procedure AppendShipPath(Destination: TPointF); // @addr $548784
    procedure UpdateShipPathImages; // @addr $548DDC
    procedure RebuildShipPath; // @addr $548A6C
    procedure BuildShipPathImages; // @addr $548AD8
    procedure ShowSpaceInfo(Space: TabSpace); // @addr $54916C
    procedure ShowItemInfo(Item: TabItem); // @addr $54A198
    procedure UpdateAutopilotButtons; // @addr $5410E8
    procedure ToggleAutopilot(Sender: TObjectGI); // @addr $541124
    procedure ResetBattleControls; // @addr $542E64
    procedure BeginMapTransition; // @addr $542F4C
    procedure CancelCargoPickup; // @addr $54B024
    procedure PickUpItem(Item: TabItem); // @addr $54B450
    procedure ShowVictory; // @addr $54B89C
    procedure CloseVictory(Sender: TObjectGI; VirtualKey: Cardinal); // @addr $54BD88
    procedure ClearEnemyStatus(Index: Integer); // @addr $546CC0
    procedure ClearTrackedShipStatus(Index: Integer); // @addr $546D94
    procedure ClearShipPath; // @addr $548F24
    procedure DrawFrame; override; // @addr $547F2C
    procedure OnOpen; override; // @addr $53C610
    procedure OnClose; override; // @addr $53D730
    procedure SelectMusic; override; // @addr $54BE0C
    procedure InitializeLayout; override; // @addr $53B6EC
    procedure ABSpaceBuild(GridSize: Integer; Angle: Single); // @addr 0x541B60
    procedure WorldImageCycleComplete(Sender: TObjectGI); // @addr $54819C
    procedure ClearOverlaySegments; // @addr $53EF08
    procedure ClearBattle; // @addr $5413C8
    procedure ClearMap; // @addr $541440
    procedure LoadMap(Buffer: TBufEC; LoadPolygons: Boolean); // @addr $541490
    procedure LoadMapResource(Path: WideString; LoadPolygons: Boolean); // @addr $5415BC
    procedure LoadMapFile(Path: WideString; LoadPolygons: Boolean); // @addr $541744
    procedure ClearGrid; // @addr $541870
    procedure BuildGrid; // @addr $5418DC
    procedure ScrollMapTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $5463C4
    procedure TimerTakt(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x544214
  end;

var
  ActiveArcadeRequestShips: TObjectList = nil; // @addr $87AEDC Borrowed ActiveArcadeRequest.Ships.
  ActiveArcadeRequest: PScriptABRequest = nil; // @addr $87AEE0 Borrowed head of QueuedArcadeBattles.

implementation

uses aKling, Windows, SysUtils, Math, GI_Tail, ab_Global, GlobalsV, GR_Main, GR_Music, GI_Main, ab_WorldImage, ab_Ship, aConst, aItem, aPlayer, aGalaxy,
  EC_CacheBuf, GR_DX, GR_Rect, GI_MultiImage, ab_Polygon, ab_StopLine, ab_WorldLine, ab_Object, ab_ShipAI, ab_W, aSaveLoad, GI_MessageBox, EC_BlockPar, SE_Process, SE_Ship2, SE_Ruins, ab_Hit, aShip, abWall, Globals, fShip2, fTalk, fStarMap, ThreadCalc, aCalc, aGalaxyEvent, aTranclucator, EC_Str, GI_RotateImage5, GI_GraphBuf, aPlanet, aRuins, SE_Star, SE_Planet;


{ @routine $53B604 TfAB_Create }
constructor TfAB.Create;
begin
  inherited Create;
  ListedObjects := TList.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $53B604 }

{ @routine $53B670 TfAB_Destroy }
destructor TfAB.Destroy;
begin
  if ListedObjects <> nil then
  begin
    ListedObjects.Free;
    ListedObjects := nil;
  end;
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $53B670 }

{ @routine $53B6EC TfAB_InitializeLayout }
procedure TfAB.InitializeLayout;
var
  Index: Integer;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('ab_MainForm... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('Map') do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      with FindByNameRecursive('SE') do
      begin
        SetPosition(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
        SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
        SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      end;
      with FindByNameRecursive('UpdateObj') do
      begin
        SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
        with FindByNameRecursive('FPS') do
          SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
        with FindByNameRecursive('LInfo') do
        begin
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
          SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
        end;
        with FindByNameRecursive('LHelp') do
        begin
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
          SetSize(Classes.Point(GameScreenWidth - 10, ClientSize.Y));
        end;
        if GiResourceVariant = 2 then
          with FindByNameRecursive('ABInfo') do SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
        with FindByNameRecursive('PanelWeapon') do
          SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight));
        with FindByNameRecursive('PRight') do
          SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight));
        with FindByNameRecursive('PItem') do
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
        with FindByNameRecursive('PanelWin') do
        begin
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
          SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
          with FindByNameRecursive('PanelWinHide') do
          begin
            SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
            with FindByNameRecursive('WinText') do SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
            with FindByNameRecursive('WinItem') do SetSize(Classes.Point(GameScreenWidth - 4, ClientSize.Y));
            with FindByNameRecursive('WinShr') do SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
          end;
        end;
        with FindByNameRecursive('PanelMenuLose') do
        begin
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
          SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
          with FindByNameRecursive('PanelLoseHide') do
          begin
            SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
            with FindByNameRecursive('PanelLose') do SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
            with FindByNameRecursive('LoseKeyPress') do SetSize(Classes.Point(GameScreenWidth - 4, ClientSize.Y));
            with FindByNameRecursive('LoseShr') do SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
          end;
        end;
      end;
      with FindByNameRecursive('StarField') do
      begin
        SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
        SetPosition(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
        SetOrigin(Classes.Point(GameScreenWidth shr 1, GameScreenHeight shr 1));
      end;
    end;
  end;
  AppendLogLineThreadSafe('ok');
  LoadPanel.InitializeLayout(Self);
  SetHelpCallback(UpdateHelp);
  with GetByName('MainPanel') do
  begin
    KeyDownCallback := BattleKeyDown;
    KeyUpCallback := BattleKeyUp;
    LeftButtonDownCallback := BattleMouseDown;
    LeftButtonUpCallback := BattleMouseUp;
    RightButtonDownCallback := BattleRightMouseDown;
    RightButtonUpCallback := BattleRightMouseUp;
    MouseMoveCallback := BattleMouseMove;
  end;
  MapPanel := GetByName('Map') as TPanelGI;
  WorldPanel := GetByName('SE') as TPanelGI;
  StarField := GetByName('StarField') as TStarFieldGI;
  StartStarImage := GetByName('StarStart') as TgaiGI;
  EndStarImage := GetByName('StarEnd') as TgaiGI;
  ItemPanel := GetByName('PItem') as TPanelGI;
  ItemInfoWindow := GetByName('InfoItem') as TWindowGI;
  AutoButton := GetByName('ButAuto') as TGraphButtonGI;
  AutoButton.UpCallback := ToggleAutopilot;
  ManualButton := GetByName('ButManual') as TGraphButtonGI;
  ManualButton.UpCallback := ToggleAutopilot;
  BattleHelpLabel := GetByName('LHelp') as TLabelGI;
  VictoryPanel := GetByName('PanelWin') as TPanelGI;
  DefeatPanel := GetByName('PanelMenuLose') as TPanelGI;
  (GetByName('ButShip') as TGraphButtonGI).UpCallback := OpenShipEquipment;
  for Index := 0 to 4 do
  begin
    WeaponButtons[Index] := GetByName('F' + IntToStr(Index + 1)) as TGraphButtonGI;
    (WeaponButtons[Index] as TGraphButtonGI).UpCallback := WeaponButtonClick;
    WeaponChargeImages[Index] := GetByName('W' + IntToStr(Index + 1) + 'C') as TImageGI;
    WeaponPrimaryImages[Index] := GetByName('W' + IntToStr(Index + 1) + 'P') as TImageGI;
    WeaponSecondaryImages[Index] := GetByName('W' + IntToStr(Index + 1) + 'P2') as TImageGI;
    WeaponIcons[Index] := GetByName('W' + IntToStr(Index + 1) + 'I') as TImageGI;
  end;
  PlayButton := GetByName('ButPlay') as TGraphButtonGI;
  PlayButton.UpCallback := TogglePause;
  PauseButton := GetByName('ButPause') as TGraphButtonGI;
  PauseButton.UpCallback := TogglePause;
  SelectedMapName := '';
end;
{ @end $53B6EC }

{ @routine $53C610 TfAB_OnOpen }
procedure TfAB.OnOpen;
var
  Ship, ShipX0, ShipX1: TabShip;
  Index: Integer;
begin
  if not MusicInHyperEnabled then MusicManager.RequestFadeOut;
  LoadPanel.OnOpen;
  if QueuedArcadeBattles.Count > 0 then ActiveArcadeRequest := QueuedArcadeBattles[0]
  else ActiveArcadeRequest := nil;
  if ActiveArcadeRequest <> nil then ActiveArcadeRequestShips := ActiveArcadeRequest.Ships
  else ActiveArcadeRequestShips := nil;
  if (Galaxy <> nil) and (GetPlayer <> nil) and (ActiveArcadeRequest = nil) and not Galaxy.IsChaoticRandomEnabled then
  begin
    if GetPlayer.TransitOriginStar <> nil then
      InitialRandomSeed := GetPlayer.TransitOriginStar.GenerationSeed * GetPlayer.CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 77 + 1783)
    else
      InitialRandomSeed := GetPlayer.CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 77 + 1783);
    RandomSeed := InitialRandomSeed;
  end
  else
  begin
    InitialRandomSeed := RandomIntRange(100000, MaxInt);
    RandomSeed := InitialRandomSeed;
  end;
  ArcadeKellerEncounter := False;
  ArcadeMapViewPosition := Classes.Point(0, 0);
  DefeatCountdownTicks := 150;
  if GetPlayer <> nil then
  begin
    DepartureTurn := Galaxy.CurrentTurn;
    ArrivalTurn := DepartureTurn + (GetPlayer.OrderStateData and $FFFF);
  end;
  GetByName('LInfo').SetActive(False);
  ShipPath := TSPath.Create;
  RouteSpaces := TList.Create;
  if ArcadeSpaceProcess <> nil then
  begin
    ArcadeSpaceProcess.Free;
    ArcadeSpaceProcess := nil;
  end;
  ArcadeSpaceProcess := TProcessSE.Create('Process.Normal');
  ArcadeSpaceProcess.RadarCenter := MakePointF(0, 0);
  ArcadeSpaceProcess.RadarRange := 0;
  ArcadeSpaceProcess.ActionRange := 0;
  ArcadeSpaceProcess.ActionColor := 0;
  ArcadeSpaceProcess.OpenSpace(WorldPanel, Self);
  ArcadeSpaceProcess.Space.AlphaShift := 0;
  if GetPlayer <> nil then
    if GetPlayer.IsHealthEffectActive(1) then ArcadeSpaceProcess.Space.AlphaShift := 2;
  SkipSavedPixelRestore := True;
  StarField.Stars.Clear;
  StarField.BackgroundScale := 8;
  WorldLines := TPolyLineGI.Create(MapPanel);
  WorldLines.SetDepth(200);
  WorldLines.NormalizeBounds := False;
  WorldLines.SetPosition(StarField.LocalPosition);
  WorldLines.SetSize(StarField.ClientSize);
  WorldLines.SetOrigin(StarField.OriginPoint);
  WorldLines.AutoRebuildBounds := True;
  WorldLines.SetPositionModeW(True);
  WorldLines.SetActive(True);
  WorldCenterX := MapPanel.ClientSize.X div 2;
  WorldCenterY := MapPanel.ClientSize.Y div 2;
  if GetPlayer = nil then
  begin
    RetainSpaceObject(PlayerVisual, CreateSpaceObjectByName('Ship2', 'Ship.People.Ranger', Classes.Point(0, 0)));
    PlayerVisual.SetSize(Classes.Point(GiScalePixels(64), GiScalePixels(64)));
  end
  else
  begin
    if GetPlayer.Graphic is TShip2SE then
      RetainSpaceObject(PlayerVisual, CreateSpaceObjectByName('Ship2', GetPlayer.Graphic.GraphKey, Classes.Point(0, 0)))
    else
      RetainSpaceObject(PlayerVisual, CreateSpaceObjectByName('Ruins', GetPlayer.Graphic.GraphKey, Classes.Point(0, 0)));
    PlayerVisual.SetSize(Classes.Point(GetPlayer.Graphic.Size.X, GetPlayer.Graphic.Size.Y));
  end;
  PlayerVisual.SetAlpha(255);
  if PlayerVisual is TShip2SE then
  begin
    TShip2SE(PlayerVisual).TailEmitIntervalMs := 10;
    if ShipTail <> 0 then TShip2SE(PlayerVisual).SetTailMode(1)
    else TShip2SE(PlayerVisual).SetTailMode(0);
  end;
  ab_Object_Clear;
  Ship := TabShipAI.Create;
  ab_Object_Add(Ship);
  PlayerArcadeShip := Ship;
  if GetPlayer = nil then Ship.CreateShipVisual('Ship.People.Ranger', 64)
  else
  begin
    if GetPlayer.Graphic is TRuinsSE then
      Ship.CreateRuinsVisual(GetPlayer.Graphic.GraphKey, GetPlayer.Graphic.Size.X)
    else if GiResourceVariant = 2 then
      Ship.CreateShipVisual(GetPlayer.Graphic.GraphKey, GetPlayer.Graphic.Size.X)
    else
      Ship.CreateShipVisual(GetPlayer.Graphic.GraphKey, Round((GetPlayer.Graphic.Size.X shl 10) / 800));
    GetPlayer.ScriptItemsAct($37, Ship, nil, 0);
  end;
  Ship.MaxSpeed := 11;
  Ship.TurnSpeed := PlayerInitialTurnSpeed;
  Ship.Thrust := 0;
  if GetPlayer = nil then
  begin
    Ship.MaxHealth := 1000;
    Ship.Health := 1000;
    Ship.WeaponCount := 5;
    ab_Weapon_Initialize(@Ship.Weapons[0], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.Weapons[0].SlotData := 0;
    ab_Weapon_Initialize(@Ship.Weapons[1], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.Weapons[1].SlotData := 1;
    ab_Weapon_Initialize(@Ship.Weapons[2], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.Weapons[2].SlotData := 2;
    ab_Weapon_Initialize(@Ship.Weapons[3], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.Weapons[3].SlotData := 3 or EquipmentSecondaryFireFlag;
    ab_Weapon_Initialize(@Ship.Weapons[4], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.Weapons[4].SlotData := 4 or EquipmentSecondaryFireFlag;
    Ship.PrimaryWeapon := -1;
    Ship.SecondaryWeapon := -1;
    NormalizeWeaponSelection;
  end
  else
  begin
    Ship.MaxHealth := GetPlayer.GetHull.Weight;
    Ship.Health := GetPlayer.GetHull.HullPoints;
    for Index := 0 to 4 do CampaignWeapons[Index] := nil;
    SyncWeaponInventory;
    for Index := 0 to Ship.WeaponCount - 1 do Ship.Weapons[Index].Ammo := Ship.Weapons[Index].MaxAmmo;
    Ship.PrimaryWeapon := -1;
    Ship.SecondaryWeapon := -1;
    NormalizeWeaponSelection;
  end;
  if GetPlayer = nil then
  begin
    Ship := TabShipAI.Create;
    ab_Object_Add(Ship);
    Ship.CreateShipVisual('Ship.X.0', 64);
    Ship.MaxSpeed := 12;
    Ship.TurnSpeed := 4;
    Ship.Thrust := 0;
    Ship.Health := 500;
    Ship.MaxHealth := 500;
    Ship.WeaponCount := 5;
    ab_Weapon_Initialize(@Ship.Weapons[0], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[1], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[2], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[3], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[4], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.PrimaryWeapon := 0;
    ShipX0 := Ship;
    Ship := TabShipAI.Create;
    ab_Object_Add(Ship);
    Ship.CreateShipVisual('Ship.X.1', 64);
    Ship.MaxSpeed := 12;
    Ship.TurnSpeed := 4;
    Ship.Thrust := 0;
    Ship.Health := 500;
    Ship.MaxHealth := 500;
    Ship.WeaponCount := 5;
    ab_Weapon_Initialize(@Ship.Weapons[0], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[1], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[2], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[3], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[4], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.PrimaryWeapon := 0;
    ShipX1 := Ship;
    Ship := TabShipAI.Create;
    ab_Object_Add(Ship);
    Ship.CreateShipVisual('Ship.X.2', 64);
    Ship.MaxSpeed := 12;
    Ship.TurnSpeed := 4;
    Ship.Thrust := 0;
    Ship.Health := 500;
    Ship.MaxHealth := 500;
    Ship.WeaponCount := 5;
    ab_Weapon_Initialize(@Ship.Weapons[0], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[1], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[2], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[3], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    ab_Weapon_Initialize(@Ship.Weapons[4], PickRandomItemType([Ord(t_Weapon1)..Ord(t_Weapon18)]));
    Ship.PrimaryWeapon := 0;
    for Index := 0 to 3 do
    begin
      KellerFragments[Index] := nil;
      KellerFragmentDistances[Index] := 0;
      KellerFragmentValuesAC[Index] := 0;
    end;
    KellerBreakupTicks := 0;
    KellerSplitActive := False;
    Ship.AddEnemy(PlayerArcadeShip);
    ShipX0.AddEnemy(PlayerArcadeShip);
    ShipX1.AddEnemy(PlayerArcadeShip);
    PlayerArcadeShip.AddEnemy(Ship);
    PlayerArcadeShip.AddEnemy(ShipX0);
    PlayerArcadeShip.AddEnemy(ShipX1);
  end;
  if GetPlayer = nil then
    ABSpaceBuild(RandomIntRange(3, 8), HeadingDegreesToRadians(RandomRange(0, 355)))
  else if ActiveArcadeRequest <> nil then
    ABSpaceBuild(1, HeadingDegreesToRadians(RandomRange(0, 355)))
  else if GetPlayer.Order = soJumpHole then
  begin
    if GetPlayer.TransitOriginStar <> nil then
      ABSpaceBuild(1, HeadingDegreesToRadians(PointBearingDegrees(GetPlayer.TransitOriginStar.Position, GetPlayer.CurrentStar.Position)))
    else ABSpaceBuild(1, 0);
  end
  else if GetPlayer.TransitOriginStar <> nil then
    ABSpaceBuild(Round(RemapClamped(PointDistance(GetPlayer.CurrentStar.Position, GetPlayer.TransitOriginStar.Position),
      10, GalaxySizeY div 2, 3, 8)),
      HeadingDegreesToRadians(PointBearingDegrees(GetPlayer.TransitOriginStar.Position, GetPlayer.CurrentStar.Position)))
  else ABSpaceBuild(3, 0);
  ForwardKeyDown := False;
  ReverseKeyDown := False;
  BrakeKeyDown := False;
  TurnLeftKeyDown := False;
  TurnRightKeyDown := False;
  PrimaryFireKeyDown := False;
  SecondaryFireKeyDown := False;
  ArcadePaused := False;
  ArcadePauseWithShift := False;
  PlayButton.SetActive(not ArcadePaused);
  PauseButton.SetActive(ArcadePaused);
  CampaignTransitionStarted := False;
  CampaignLoadStarted := False;
  CampaignLoadFinished := False;
  CacheLoader := nil;
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(605);
  if GetPlayer <> nil then
  begin
    RunGlobalScriptsForContext(GetPlayer.CurrentStar, 2);
    CacheLoader := TCacheLoader.Create;
  end;
  if Galaxy <> nil then
  begin
    Galaxy.PrimeIntegrityChecksum1(607);
    Galaxy.PrimeIntegrityChecksum2(608);
  end;
  if (GetPlayer = nil) or (GetPlayer.Order = soJumpHole) or (ActiveArcadeRequest <> nil) or
    ((Galaxy <> nil) and not Galaxy.IsOldHyperspaceEnabled) then
  begin
    CurrentArcadeSpace := NextArcadeSpace;
    ArcadeMapViewPosition := CurrentArcadeSpace.MapPosition;
    EnterCurrentSpace;
    SelectMusic;
  end
  else EnterMapView;
  ArcadeTickCount := 0;
  UpdateTimer := ScheduleCallbackTimer(20, 20, TimerTakt);
  ScrollTimer := ScheduleCallbackTimer(ScrollTime, ScrollTime, ScrollMapTimer);
  TimerTakt(nil, 0);
  HideHelp;
end;
{ @end $53C610 }

{ @routine $53D730 TfAB_OnClose }
procedure TfAB.OnClose;
var
  Index: Integer;
begin
  LoadPanel.OnClose;
  SelectedMapName := '';
  ClearShipPath;
  ClearBattle;
  ab_Space_Clear;
  if CacheLoader <> nil then
  begin
    CacheLoader.ClearFlag18;
    CacheLoader.Free;
    CacheLoader := nil;
  end;
  if PlayerVisual <> nil then ReleaseSpaceObject(PlayerVisual);
  if ScrollTimer <> nil then
  begin
    CancelCallbackTimer(ScrollTimer);
    ScrollTimer := nil;
  end;
  if UpdateTimer <> nil then
  begin
    CancelCallbackTimer(UpdateTimer);
    UpdateTimer := nil;
  end;
  if WorldLines <> nil then
  begin
    WorldLines.Free;
    WorldLines := nil;
  end;
  if ArcadeSpaceProcess <> nil then
  begin
    ArcadeSpaceProcess.Free;
    ArcadeSpaceProcess := nil;
  end;
  if ShipPath <> nil then
  begin
    ShipPath.Free;
    ShipPath := nil;
  end;
  if RouteSpaces <> nil then
  begin
    RouteSpaces.Free;
    RouteSpaces := nil;
  end;
  if ArcadeMapColorBuffer <> nil then
  begin
    ArcadeMapColorBuffer.Free;
    ArcadeMapColorBuffer := nil;
  end;
  for Index := 0 to 7 do ClearEnemyStatus(Index);
  for Index := 0 to 7 do ClearTrackedShipStatus(Index);
  CloseVictory(nil, 0);
end;
{ @end $53D730 }

{ @routine $53D8F4 TfAB_RequestExit }
procedure TfAB.RequestExit(Sender: TObjectGI);
var
  Standalone: Boolean;
begin
  if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormGameMenu.QExit'), mbgOK or mbgCancel) = mbgResultOK then
  begin
    Standalone := Galaxy = nil;
    if CacheLoader <> nil then CacheLoader.ClearFlag18;
    ClearShipPath;
    PlayerArcadeShip := nil;
    ab_Object_Clear;
    if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
    MemorySnapshotBuffer := nil;
    MemorySnapshotActive := False;
    if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
    Galaxy := nil;
    ScreenLoadMode := 4;
    PostLoadScreenId := screenMainMenu;
    if Standalone then PostLoadScreenId := screenLoadArcade
    else PostLoadScreenId := screenMainMenu;
    RequestedScreenId := screenLoad;
    ClearPendingScriptRequests;
    ActiveArcadeRequest := nil;
    ActiveArcadeRequestShips := nil;
    ArcadeKellerDefeats := 0;
    if ArcadeKellerReward <> nil then
    begin
      ArcadeKellerReward.Free;
      ArcadeKellerReward := nil;
    end;
    RequestClose(1);
    BreakUiMessage;
  end;
end;
{ @end $53D8F4 }

{ @routine $53DAA4 TfAB_BattleKeyDown }
procedure TfAB.BattleKeyDown(Sender: TObjectGI; VirtualKey: Cardinal);
var
  Index: Integer;
  Obj: TObject;
  EnemyCount: Integer;
begin
  CancelCargoPickup;
  if ((VirtualKey = VK_ESCAPE) or (VirtualKey = VK_SPACE)) and
     (VictoryPanel.Active or DefeatPanel.Active) then
  begin
    if (GetPlayer <> nil) and (GetPlayer.GetHull.HullPoints > 0) and VictoryPanel.Active then
    begin
      if ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormAB.QueryExit'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
      begin
        if (GetPlayer.Order = soJumpHole) or (ActiveArcadeRequest <> nil) then BeginBattleExit
        else BeginMapTransition;
      end;
    end
    else if Galaxy = nil then
    begin
      ScreenLoadMode := 4;
      PostLoadScreenId := screenLoadArcade;
      RequestedScreenId := screenLoad;
      RequestClose(1);
    end
    else CloseVictory(nil, 0);
    Exit;
  end;
  if (VirtualKey = VK_TAB) and VictoryPanel.Active then
    with GetByName('PanelWinHide') do SetActive(not Active);
  if IsVirtualKeyDown(VK_CONTROL) and IsVirtualKeyDown(VK_SHIFT) and IsVirtualKeyDown(VK_MENU) then
  begin
    if (VirtualKey = Ord('K')) and (GetPlayer = nil) and (PlayerArcadeShip <> nil) then
      for Index := 0 to PlayerArcadeShip.Enemies.Count - 1 do
        TabShip(PlayerArcadeShip.Enemies[Index]).ApplyDamage(TabShip(PlayerArcadeShip.Enemies[Index]).Health, nil, False);
    Exit;
  end;
  if (PlayerArcadeShip <> nil) and (VirtualKey >= Ord('1')) and (VirtualKey <= Ord('5')) and IsVirtualKeyDown(VK_SHIFT) then
  begin
    if not (WeaponButtons[VirtualKey - Ord('1')] as TGraphButtonGI).Disabled then
      ToggleWeaponGroup(WeaponButtons[VirtualKey - Ord('1')]);
  end
  else if (PlayerArcadeShip <> nil) and (VirtualKey >= Ord('1')) and (VirtualKey <= Ord('5')) then
  begin
    if Integer(VirtualKey - Ord('1')) < 5 then WeaponSelect(WeaponButtons[VirtualKey - Ord('1')]);
  end
  else if (VirtualKey = VK_SPACE) and (ArcadeViewMode = 2) then
  begin
    ArcadePaused := not ArcadePaused;
    PlayButton.SetActive(not ArcadePaused);
    PauseButton.SetActive(ArcadePaused);
    ArcadePauseWithShift := IsVirtualKeyDown(VK_SHIFT);
  end
  else if (VirtualKey = VK_RETURN) and (ArcadeViewMode = 2) and (NextArcadeSpace = nil) and
    (CurrentArcadeSpace <> EndArcadeSpace) and (CurrentArcadeSpace <> EndArcadeSpace) then
  begin
    EnemyCount := 0;
    for Index := 0 to CurrentArcadeSpace.Objects.Count - 1 do
    begin
      Obj := CurrentArcadeSpace.Objects[Index];
      if Obj is TabShipAI then Inc(EnemyCount);
    end;
    if EnemyCount > 0 then EnterCurrentSpace;
  end
  else if (VirtualKey = Ord('C')) and (ArcadeViewMode = 2) and (NextArcadeSpace = nil) then
    ArcadeMapViewPosition := TruncatePointF(PlayerMapPosition)
  else if (VirtualKey = Ord('Q')) and (GetPlayer = nil) then
  begin
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[0], 50);
    PlayerArcadeShip.Weapons[0].SlotData := 0;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[1], 51);
    PlayerArcadeShip.Weapons[1].SlotData := 1;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[2], 52);
    PlayerArcadeShip.Weapons[2].SlotData := 2;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[3], 53);
    PlayerArcadeShip.Weapons[3].SlotData := 3 or EquipmentSecondaryFireFlag;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[4], 54);
    PlayerArcadeShip.Weapons[4].SlotData := 4 or EquipmentSecondaryFireFlag;
    NormalizeWeaponSelection;
    UpdateWeaponPanel;
  end
  else if (VirtualKey = Ord('W')) and (GetPlayer = nil) then
  begin
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[0], 55);
    PlayerArcadeShip.Weapons[0].SlotData := 0;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[1], 56);
    PlayerArcadeShip.Weapons[1].SlotData := 1;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[2], 57);
    PlayerArcadeShip.Weapons[2].SlotData := 2;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[3], 58);
    PlayerArcadeShip.Weapons[3].SlotData := 3 or EquipmentSecondaryFireFlag;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[4], 59);
    PlayerArcadeShip.Weapons[4].SlotData := 4 or EquipmentSecondaryFireFlag;
    NormalizeWeaponSelection;
    UpdateWeaponPanel;
  end
  else if (VirtualKey = Ord('E')) and (GetPlayer = nil) then
  begin
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[0], 60);
    PlayerArcadeShip.Weapons[0].SlotData := 0;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[1], 61);
    PlayerArcadeShip.Weapons[1].SlotData := 1;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[2], 62);
    PlayerArcadeShip.Weapons[2].SlotData := 2;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[3], 63);
    PlayerArcadeShip.Weapons[3].SlotData := 3 or EquipmentSecondaryFireFlag;
    ab_Weapon_Initialize(@PlayerArcadeShip.Weapons[4], 64);
    PlayerArcadeShip.Weapons[4].SlotData := 4 or EquipmentSecondaryFireFlag;
    NormalizeWeaponSelection;
    UpdateWeaponPanel;
  end
  else if (VirtualKey = VK_SPACE) and (ArcadeViewMode = 2) and (CurrentArcadeSpace = NextArcadeSpace) then
  begin
    EnemyCount := 0;
    for Index := 0 to CurrentArcadeSpace.Objects.Count - 1 do
    begin
      Obj := CurrentArcadeSpace.Objects[Index];
      if Obj is TabShipAI then Inc(EnemyCount);
    end;
    if EnemyCount > 0 then EnterCurrentSpace;
  end;
  if (VirtualKey = VK_UP) or ((VirtualKey = Ord('R')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    ForwardKeyDown := True;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_DOWN) or ((VirtualKey = Ord('F')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    ReverseKeyDown := True;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_SPACE) or (VirtualKey = VK_SHIFT) then
  begin
    SecondaryFireKeyDown := True;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_LEFT) or ((VirtualKey = Ord('D')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    TurnLeftKeyDown := True;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_RIGHT) or ((VirtualKey = Ord('G')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    TurnRightKeyDown := True;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if VirtualKey = VK_CONTROL then
  begin
    PrimaryFireKeyDown := True;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if VirtualKey = VK_ESCAPE then RequestExit(nil)
  else if VirtualKey = Ord('A') then ToggleAutopilot(nil)
  else if (VirtualKey = Ord('S')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL) then OpenShipEquipment(nil)
  else if (VirtualKey = Ord('P')) or (VirtualKey = VK_PAUSE) then SimulationPaused := not SimulationPaused;
end;
{ @end $53DAA4 }

{ @routine $53E478 TfAB_BattleKeyUp }
procedure TfAB.BattleKeyUp(Sender: TObjectGI; VirtualKey: Cardinal);
begin
  CancelCargoPickup;
  if (VirtualKey = VK_UP) or ((VirtualKey = Ord('R')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    ForwardKeyDown := False;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_DOWN) or ((VirtualKey = Ord('F')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    ReverseKeyDown := False;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_SPACE) or (VirtualKey = VK_SHIFT) then
  begin
    SecondaryFireKeyDown := False;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_LEFT) or ((VirtualKey = Ord('D')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    TurnLeftKeyDown := False;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if (VirtualKey = VK_RIGHT) or ((VirtualKey = Ord('G')) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_CONTROL)) then
  begin
    TurnRightKeyDown := False;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end
  else if VirtualKey = VK_CONTROL then
  begin
    PrimaryFireKeyDown := False;
    ArcadeLastInputTick := ArcadeTickCount;
    ArcadeAutopilotEnabled := False;
    UpdateAutopilotButtons;
  end;
end;
{ @end $53E478 }

{ @routine $53E654 TfAB_BattleMouseDown }
procedure TfAB.BattleMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Origin: TabSpace;
  Route: TList;
  Index: Integer;
  Obj: TObject;
  EnemyCount: Integer;
begin
  if (ArcadeViewMode = 2) and (NextArcadeSpace = nil) and (HoveredArcadeSpace <> nil) and not Sender.IsOccludedAtPoint(Point) then
  begin
    Origin := CurrentArcadeSpace;
    if (RouteSpaces.Count > 0) and IsVirtualKeyDown(VK_CONTROL) then Origin := RouteSpaces[RouteSpaces.Count - 1];
    if (HoveredArcadeSpace = CurrentArcadeSpace) and (CurrentArcadeSpace <> EndArcadeSpace) then
    begin
      EnemyCount := 0;
      for Index := 0 to CurrentArcadeSpace.Objects.Count - 1 do
      begin
        Obj := CurrentArcadeSpace.Objects[Index];
        if Obj is TabShipAI then Inc(EnemyCount);
      end;
      if EnemyCount > 0 then EnterCurrentSpace;
    end
    else if (RouteSpaces.Count > 0) and (RouteSpaces[RouteSpaces.Count - 1] = HoveredArcadeSpace) then
    begin
      ArcadePaused := True;
      PlayButton.SetActive(not ArcadePaused);
      PauseButton.SetActive(ArcadePaused);
      ArcadePauseWithShift := IsVirtualKeyDown(VK_SHIFT);
      HideObjectInfo;
    end
    else
    begin
      ClearShipPath;
      if not IsVirtualKeyDown(VK_CONTROL) then RouteSpaces.Clear;
      Route := TList.Create;
      BuildSpaceRoute(Route, Origin, HoveredArcadeSpace);
      if Route.Count > 0 then
        for Index := 0 to Route.Count - 1 do RouteSpaces.Add(Route[Index]);
      Route.Free;
      RebuildShipPath;
      BuildShipPathImages;
    end;
  end
  else if (ArcadeViewMode = 0) and (CargoPickupItem <> nil) and
    (CargoPickupItem.BonusKind < 0) and (PlayerArcadeShip <> nil) and
    (PlayerArcadeShip.Health > 0) and (GetPlayer <> nil) and
    (GetPlayer.CargoFreeSpace >= CargoPickupItem.Item.Weight) and
    (PlayerArcadeShip.DistanceTo(CargoPickupItem) < ManualCargoPickupDistance) and
    GetPlayer.IsEquipmentUsable(GetPlayer.GetCargoHook) and
    (GetPlayer.CalculateCargoHookPower(GetPlayer.GetCargoHook) >= CargoPickupItem.Item.Weight) then
  begin
    PickUpItem(CargoPickupItem);
    CancelCargoPickup;
  end;
end;
{ @end $53E654 }

{ @routine $53E9B8 TfAB_BattleMouseUp }
procedure TfAB.BattleMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
end;
{ @end $53E9B8 }

{ @routine $53E9DC TfAB_BattleRightMouseDown }
procedure TfAB.BattleRightMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (ArcadeViewMode = 2) and (NextArcadeSpace = nil) and not ContentPanel.IsOccludedAtPoint(Point) then
  begin
    MapDrag.Active := True;
    MapDrag.Position := Point;
    if IsCursorImageSelected('Main') then SetCursorByName('Scroll');
  end;
end;
{ @end $53E9DC }

{ @routine $53EA84 TfAB_BattleRightMouseUp }
procedure TfAB.BattleRightMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (ArcadeViewMode = 2) and MapDrag.Active then
  begin
    MapDrag.Active := False;
    if IsCursorImageSelected('Scroll') then SetCursorByName('Main');
  end;
end;
{ @end $53EA84 }

{ @routine $53EB08 TfAB_BattleMouseMove }
procedure TfAB.BattleMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Distance, NearestDistance, ItemDistance: Double;
  Space: TabSpace;
  Obj: TabObject;
  LocalPoint: TPoint;
  Position: TVector3D;
begin
  if MapDrag.Active then
  begin
    if IsCursorImageSelected('Main') then SetCursorByName('Scroll');
    ArcadeMapViewPosition := Classes.Point(ArcadeMapViewPosition.X + MapDrag.Position.X - Point.X,
      ArcadeMapViewPosition.Y + MapDrag.Position.Y - Point.Y);
    MapDrag.Position := Point;
    if ArcadeMapBounds.Top - ArcadeMapPanMargin > ArcadeMapViewPosition.Y then
      ArcadeMapViewPosition.Y := ArcadeMapBounds.Top - ArcadeMapPanMargin;
    if ArcadeMapBounds.Bottom + ArcadeMapPanMargin < ArcadeMapViewPosition.Y then
      ArcadeMapViewPosition.Y := ArcadeMapBounds.Bottom + ArcadeMapPanMargin;
    if ArcadeMapBounds.Left - ArcadeMapPanMargin > ArcadeMapViewPosition.X then
      ArcadeMapViewPosition.X := ArcadeMapBounds.Left - ArcadeMapPanMargin;
    if ArcadeMapBounds.Right + ArcadeMapPanMargin < ArcadeMapViewPosition.X then
      ArcadeMapViewPosition.X := ArcadeMapBounds.Right + ArcadeMapPanMargin;
  end
  else
  begin
    if (Point.X = 0) or (Point.Y = 0) or (GameScreenWidth - 1 = Point.X) or (GameScreenHeight - 1 = Point.Y) then
    begin
      if (ArcadeViewMode = 2) and (NextArcadeSpace = nil) then
      begin
        SetCursorByName('Scroll');
        Exit;
      end;
    end
    else if (ArcadeViewMode = 2) and (NextArcadeSpace = nil) then
    begin
      Point.X := Point.X - WorldCenterX + ArcadeMapViewPosition.X;
      Point.Y := Point.Y - WorldCenterY + ArcadeMapViewPosition.Y;
      HoveredArcadeSpace := nil;
      NearestDistance := 1E20;
      Space := FirstArcadeSpace;
      while Space <> nil do
      begin
        Distance := PointDistanceSquared(PointToPointF(Point), PointToPointF(Space.MapPosition));
        if (Distance < NearestDistance) and (Sqr(GiScalePixels(ArcadeMapNodeRadius)) > Distance) then
        begin
          NearestDistance := Distance;
          HoveredArcadeSpace := Space;
        end;
        Space := Space.Next;
      end;
      ShowSpaceInfo(HoveredArcadeSpace);
    end
    else if ArcadeViewMode = 0 then
    begin
      LocalPoint := WorldPanel.ToLocalPoint(Point);
      Obj := FirstArcadeObject;
      while Obj <> nil do
      begin
        if Obj is TabItem then
        begin
          Position := Obj.GetWorldPosition;
          Position := ProjectPointByMatrix(SphereProjectionMatrix, Position);
          if IsDepthBeforeSphereHorizon(Position.Z) then
          begin
            ItemDistance := Sqr(LocalPoint.X - Position.X) + Sqr(LocalPoint.Y - Position.Y);
            if ItemDistance < 256 then
            begin
              ShowItemInfo(TabItem(Obj));
              Break;
            end;
          end;
        end;
        Obj := Obj.Next;
      end;
      if Obj = nil then CancelCargoPickup;
    end;
    if IsCursorImageSelected('Scroll') then SetCursorByName('Main');
  end;
end;
{ @end $53EB08 }

{ @routine $53EF08 TfAB_ClearOverlaySegments }
procedure TfAB.ClearOverlaySegments;
var
  Index: Integer;
begin
  for Index := 0 to 3 do
    if OverlaySegments[Index] <> nil then
    begin
      WorldLines.RetireSegment(OverlaySegments[Index]);
      OverlaySegments[Index] := nil;
    end;
end;
{ @end $53EF08 }

{ @routine $53EF60 TfAB_ScreenPointToSphere }
function TfAB.ScreenPointToSphere(Point: TPoint; var Longitude, PolarAngle: Double): Boolean;
var
  Source, RayOrigin, RayDirection: TVector3D;
  Matrix: TMatrix4D;
begin
  Point := WorldPanel.ToLocalPoint(Point);
  Matrix := InvertMatrix4D(SpherePerspectiveMatrix);
  Source := MakeVector3D(Point.X, Point.Y, 1);
  Source := ProjectPointByMatrix(Matrix, Source);
  Matrix := InvertMatrix4D(SphereViewMatrix);
  RayDirection.X := Source.X * Matrix[0][0] + Source.Y * Matrix[1][0] + Source.Z * Matrix[2][0];
  RayDirection.Y := Source.X * Matrix[0][1] + Source.Y * Matrix[1][1] + Source.Z * Matrix[2][1];
  RayDirection.Z := Source.X * Matrix[0][2] + Source.Y * Matrix[1][2] + Source.Z * Matrix[2][2];
  RayOrigin.X := Matrix[3][0];
  RayOrigin.Y := Matrix[3][1];
  RayOrigin.Z := Matrix[3][2];
  Result := TryIntersectRayWithSphere(RayOrigin,
    MakeVector3D(RayOrigin.X + RayDirection.X, RayOrigin.Y + RayDirection.Y, RayOrigin.Z + RayDirection.Z),
    MakeVector3D(0, 0, 0), SphereRadius, RayOrigin);
  if Result then VectorToSphericalAngles(RayOrigin, Longitude, PolarAngle);
end;
{ @end $53EF60 }

{ @routine $53F12C TfAB_UpdateWeaponPanel }
procedure TfAB.UpdateWeaponPanel;
var
  Value, Index, SlotIndex, Group: Integer;
  Button: TGraphButtonGI;
  Item: TWeapon;
  WeaponName: WideString;
  MicroModule: Integer;
begin
  if (PlayerArcadeShip = nil) or (PlayerArcadeShip.Health <= 0) or (ArcadeViewMode = 5) then ClearWeaponPanel
  else
  begin
    GetByName('PanelWeapon').SetActive(True);
    for Value := 1 to 5 do
    begin
      Button := GetByName('F' + IntToStr(Value)) as TGraphButtonGI;
      Button.HelpText := '';
      Button.SetDisabled(True);
      Group := 0;
      for Index := 0 to PlayerArcadeShip.WeaponCount - 1 do
      begin
        SlotIndex := PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSlotIndexMask;
        if Value - 1 = SlotIndex then
        begin
          if (PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSecondaryFireFlag) <> 0 then Group := 1;
          Break;
        end;
      end;
      if Group <> 0 then
      begin
        Button.SetImageNormalPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'GN');
        Button.SetImageNormalActivePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'GA');
        Button.SetImageDownPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'GD');
      end
      else
      begin
        Button.SetImageNormalPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'BN');
        Button.SetImageNormalActivePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'BA');
        Button.SetImageDownPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'BD');
      end;
      Button.SetImageDisabledPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'H');
      Button.ImageNormal.SetImageKindY(ikyBottom);
      Button.ImageNormalActive.SetImageKindY(ikyBottom);
      Button.ImageDown.SetImageKindY(ikyBottom);
      Button.UserValue := -1;
      Button.UserIndex := -1;
      Button.UserData := Value;
      Button.StateChangedCallback := WeaponStateChanged;
      for Index := 0 to PlayerArcadeShip.WeaponCount - 1 do
      begin
        SlotIndex := PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSlotIndexMask;
        if Value - 1 = SlotIndex then
        begin
          Button.UserIndex := Index;
          Break;
        end;
      end;
      if GetPlayer <> nil then
      begin
        Item := GetPlayer.FindEquippedItemInSlot(t_Weapon1, Value - 1) as TWeapon;
        if GetPlayer.GetSlotCount(sskWeapon) <= Value - 1 then
          Button.SetImageDisabledPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'H')
        else if Item = nil then
          Button.SetImageDisabledPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'E')
        else if not GetPlayer.IsEquipmentUsable(Item) then
          Button.SetImageDisabledPath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Value) + 'R');
      end;
      WeaponChargeImages[Value - 1].SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'CurH');
      WeaponPrimaryImages[Value - 1].SetActive(False);
      WeaponSecondaryImages[Value - 1].SetActive(False);
      with WeaponIcons[Value - 1] do
      begin
        if (GetPlayer <> nil) and (GetPlayer.FindEquippedItemInSlot(t_Weapon1, Value - 1) <> nil) then
        begin
          WeaponIcons[Value - 1].SetActive(True);
          SetImagePath('GI,' + GetPlayer.FindEquippedItemInSlot(t_Weapon1, Value - 1).GetBitmapResourceName + 's');
        end
        else if Button.UserIndex >= 0 then
        begin
          WeaponIcons[Value - 1].SetActive(True);
          SetImagePath('GI,Bm.Items.' + GiResourceSuffix + ItemTypeNames[TItemType(PlayerArcadeShip.Weapons[Button.UserIndex].ItemType)] + 's');
        end
        else WeaponIcons[Value - 1].SetActive(False);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
    end;
    Value := 0;
    while Value < PlayerArcadeShip.WeaponCount do
    begin
      SlotIndex := PlayerArcadeShip.Weapons[Value].SlotData and EquipmentSlotIndexMask;
      (WeaponButtons[SlotIndex] as TGraphButtonGI).SetDisabled(False);
      WeaponButtons[SlotIndex].SetActive(True);
      WeaponButtons[SlotIndex].HelpCallback := UpdateHelp;
      if WeaponButtons[SlotIndex].UserState = 0 then
        WeaponButtons[SlotIndex].UserState := Integer(TImageGI.Create(WeaponButtons[SlotIndex]));
      if (GetPlayer <> nil) and (GetPlayer.FindEquippedItemInSlot(t_Weapon1, SlotIndex) <> nil) then
      begin
        Item := GetPlayer.FindEquippedItemInSlot(t_Weapon1, SlotIndex) as TWeapon;
        MicroModule := Item.MicroModuleIndex;
        Item.MicroModuleIndex := 0;
        WeaponName := Item.GetShortName;
        Item.MicroModuleIndex := MicroModule;
      end
      else WeaponName := LocalizedText('Items.Weapon.Name.' + IntToStr(PlayerArcadeShip.Weapons[Value].ItemType - 50 + 1));
      if (PlayerArcadeShip.Weapons[Value].SlotData and EquipmentSecondaryFireFlag) <> 0 then
        WeaponButtons[SlotIndex].HelpText := ReplaceAllWideString(ReplaceAllWideString(LookupLocalizedTextByKey('Help.ABWeapon2'), '<SelectKey>', IntToStr(Value + 1)), '<WeaponName>', WeaponName)
      else
        WeaponButtons[SlotIndex].HelpText := ReplaceAllWideString(ReplaceAllWideString(LookupLocalizedTextByKey('Help.ABWeapon1'), '<SelectKey>', IntToStr(Value + 1)), '<WeaponName>', WeaponName);
      (WeaponButtons[SlotIndex] as TGraphButtonGI).UpdateStateVisuals;
      Inc(Value);
    end;
    UpdateWeaponHighlights(True);
  end;
end;
{ @end $53F12C }

{ @routine $53FEC0 TfAB_WeaponStateChanged }
procedure TfAB.WeaponStateChanged(Sender: TObjectGI);
var
  Button: TGraphButtonGI;
  Image: TImageGI;
  Charge: Single;
  Index: Integer;
begin
  Button := TGraphButtonGI(Sender);
  Image := TImageGI(Button.UserState);
  if Image <> nil then
  begin
    if Button.Disabled then Image.SetActive(False)
    else
    begin
      Image.SetActive(True);
      if PlayerArcadeShip = nil then Charge := 0
      else
      begin
        Index := Sender.UserIndex;
        Charge := PlayerArcadeShip.Weapons[Index].Ammo / PlayerArcadeShip.Weapons[Index].MaxAmmo;
      end;
      if Button.Down then
      begin
        Charge := Charge - 0.05;
        if Charge < 0 then Charge := 0;
      end;
      if (Sender as TGraphButtonGI).Down then
        Image.SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Cardinal(Sender.UserData)) + 'OD')
      else if (Sender as TGraphButtonGI).IsHovered then
        Image.SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Cardinal(Sender.UserData)) + 'OA')
      else
        Image.SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'W' + IntToStr(Cardinal(Sender.UserData)) + 'ON');
      Image.SetImageKindY(ikyTop);
      Image.SetSize(Classes.Point(Button.ClientSize.X, Button.ClientSize.Y - Round(Button.ClientSize.Y * Charge)));
      Button.ImageNormal.SetPosition(Classes.Point(Button.ImageNormal.LocalPosition.X, Button.ClientSize.Y - Round(Button.ClientSize.Y * Charge)));
      Button.ImageNormal.SetSize(Classes.Point(Button.ImageNormal.ClientSize.X, Round(Button.ClientSize.Y * Charge)));
      Button.ImageNormalActive.SetPosition(Classes.Point(Button.ImageNormalActive.LocalPosition.X, Button.ClientSize.Y - Round(Button.ClientSize.Y * Charge)));
      Button.ImageNormalActive.SetSize(Classes.Point(Button.ImageNormalActive.ClientSize.X, Round(Button.ClientSize.Y * Charge)));
      Button.ImageDown.SetPosition(Classes.Point(Button.ImageDown.LocalPosition.X, Button.ClientSize.Y - Round(Button.ClientSize.Y * Charge)));
      Button.ImageDown.SetSize(Classes.Point(Button.ImageDown.ClientSize.X, Round(Button.ClientSize.Y * Charge)));
    end;
  end;
end;
{ @end $53FEC0 }

{ @routine $540318 TfAB_ClearWeaponPanel }
procedure TfAB.ClearWeaponPanel;
var
  Index: Integer;
begin
  with GetByName('PanelWeapon') do
    if Active then
    begin
      FindByNameRecursive('PanelWeapon').SetActive(False);
      for Index := 0 to 4 do
      begin
        WeaponButtons[Index].SetActive(False);
        WeaponIcons[Index].SetActive(False);
      end;
      for Index := Low(BonusIcons) to High(BonusIcons) do
        if BonusIcons[Index] <> nil then
        begin
          BonusIcons[Index].Free;
          BonusIcons[Index] := nil;
          BonusRings[Index].Free;
          BonusRings[Index] := nil;
        end;
      for Index := 0 to 7 do
        if EnemyIcons[Index] <> nil then
        begin
          EnemyIcons[Index].Free;
          EnemyIcons[Index] := nil;
          EnemyHealthRings[Index].Free;
          EnemyHealthRings[Index] := nil;
          if EnemyRewardIcons[Index] <> nil then EnemyRewardIcons[Index].Free;
          EnemyRewardIcons[Index] := nil;
          if EnemyRewardBackdrops[Index] <> nil then EnemyRewardBackdrops[Index].Free;
          EnemyRewardBackdrops[Index] := nil;
        end;
      for Index := 0 to 7 do
        if TrackedShipIcons[Index] <> nil then
        begin
          TrackedShipIcons[Index].Free;
          TrackedShipIcons[Index] := nil;
          TrackedShipHealthRings[Index].Free;
          TrackedShipHealthRings[Index] := nil;
        end;
    end;
end;
{ @end $540318 }

{ @routine $540534 TfAB_UpdateWeaponHighlights }
procedure TfAB.UpdateWeaponHighlights(Force: Boolean);
var
  Index, Top, Height, Slot: Integer;
  Button: TGraphButtonGI;
  Icon: TImageGI;
  Ring: TgaiGI;
begin
  if (PlayerArcadeShip = nil) or (PlayerArcadeShip.Health <= 0) then
    ClearWeaponPanel
  else
  begin
    Index := 0;
    while Index < PlayerArcadeShip.WeaponCount do
    begin
      Slot := PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSlotIndexMask;
      Button := WeaponButtons[Slot] as TGraphButtonGI;
      if Force or ((ArcadeTickCount and 3) = 0) then
      begin
        Button.UpdateStateVisuals;
        if PlayerArcadeShip.PrimaryWeapon = Index then
          WeaponChargeImages[Slot].SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'CurB')
        else if PlayerArcadeShip.SecondaryWeapon = Index then
          WeaponChargeImages[Slot].SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'CurG')
        else
          WeaponChargeImages[Slot].SetImagePath('GI,Bm.FormAB2.' + GiResourceSuffix + 'CurH');
        WeaponPrimaryImages[Slot].SetActive((PlayerArcadeShip.Weapons[Index].Ammo < PlayerArcadeShip.Weapons[Index].AmmoCost) and (((ArcadeTickCount shr 2) and 1) = 0));
        WeaponSecondaryImages[Slot].SetActive((PlayerArcadeShip.Weapons[Index].Ammo < PlayerArcadeShip.Weapons[Index].AmmoCost) and (((ArcadeTickCount shr 2) and 1) <> 0));
      end;
      WeaponButtons[Slot].UserValue := Index;
      Inc(Index);
    end;
    Height := GiScalePixels(64);
    for Index := 0 to 7 do
    begin
      if PlayerArcadeShip.BonusTicks[Index] <= 0 then
      begin
        if BonusIcons[Index] <> nil then
        begin
          BonusIcons[Index].Free;
          BonusIcons[Index] := nil;
          BonusRings[Index].Free;
          BonusRings[Index] := nil;
          HideHelp;
        end;
      end
      else
      begin
        if BonusIcons[Index] = nil then
        begin
          BonusIcons[Index] := TImageGI.Create(ItemPanel);
          Icon := BonusIcons[Index];
          Icon.SetImagePath('GI,Bm.ABItem.' + GiResourceSuffix + '_0' + IntToStr(Index) + '_i');
          Icon.SetSize(Classes.Point(ItemPanel.ClientSize.X, Height));
          Icon.SetDepth(0);
          BonusRings[Index] := TgaiGI.Create(ItemPanel);
          Ring := BonusRings[Index];
          Ring.SetImagePath('Bm.ABItem.' + GiResourceSuffix + '_Ring');
          Ring.SetSize(Classes.Point(ItemPanel.ClientSize.X, Height));
          Ring.SequenceIndex := 0;
          Ring.UpdateAutoGeometry;
          Ring.SetMouseViewUpdates(True);
          Ring.MouseBlocking := True;
          Ring.StopAutoPlayback;
          Ring.SetDepth(1);
          Ring.HelpCallback := UpdateHelp;
          Ring.MouseEnterCallback := ControlMouseEnter;
          Ring.MouseLeaveCallback := ControlMouseLeave;
          if Index = 0 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemLife')
          else if Index = 1 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemFast')
          else if Index = 2 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemSlow')
          else if Index = 3 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemLock')
          else if Index = 4 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemDamage')
          else if Index = 5 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemReload')
          else if Index = 6 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemDefence')
          else if Index = 7 then Ring.HelpText := LookupLocalizedTextByKey('Help.ABItemInvisible');
        end;
      end;
    end;
    Top := ItemPanel.ClientSize.Y - Height;
    for Index := Low(BonusIcons) to High(BonusIcons) do
      if PlayerArcadeShip.BonusTicks[Index] > 0 then
      begin
        BonusIcons[Index].SetPosition(Classes.Point(0, Top));
        BonusRings[Index].SetPosition(Classes.Point(0, Top));
        BonusRings[Index].SetSequenceFrame(Round((1 - PlayerArcadeShip.BonusTicks[Index] / (BonusDurationSeconds[Index] * 20)) * BonusRings[Index].SequenceFrameCount));
        Dec(Top, Height);
      end;
  end;
end;
{ @end $540534 }

{ @routine $540E1C TfAB_WeaponSelect }
procedure TfAB.WeaponSelect(Sender: TObjectGI);
var
  Index: Integer;
begin
  if PlayerArcadeShip <> nil then
  begin
    Index := Sender.UserValue;
    if (Index >= 0) and (PlayerArcadeShip.PrimaryWeapon <> Index) then
    begin
      PlayerArcadeShip.SelectWeapon(Index);
      UpdateWeaponHighlights(True);
    end;
  end;
end;
{ @end $540E1C }

{ @routine $540E74 TfAB_ToggleWeaponGroup }
procedure TfAB.ToggleWeaponGroup(Sender: TObjectGI);
var
  Index: Integer;
begin
  if PlayerArcadeShip <> nil then
  begin
    Index := Sender.UserValue;
    if Index >= 0 then
    begin
      PlayerArcadeShip.Weapons[Index].SlotData := PlayerArcadeShip.Weapons[Index].SlotData xor EquipmentSecondaryFireFlag;
      if Galaxy <> nil then Galaxy.CheckIntegrityChecksum1(640);
      if GetPlayer <> nil then
        with GetPlayer.FindEquippedItemInSlot(t_Weapon1, PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSlotIndexMask) as TWeapon do
          AssignedSlotData := PlayerArcadeShip.Weapons[Index].SlotData;
      NormalizeWeaponSelection;
      UpdateWeaponPanel;
      if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum1(641);
      UpdateHelp(Sender, True);
    end;
  end;
end;
{ @end $540E74 }

{ @routine $540F70 TfAB_WeaponButtonClick }
procedure TfAB.WeaponButtonClick(Sender: TObjectGI);
begin
  ToggleWeaponGroup(Sender);
end;
{ @end $540F70 }

{ @routine $540F8C TfAB_NormalizeWeaponSelection }
procedure TfAB.NormalizeWeaponSelection;
var
  Index: Integer;
begin
  if (PlayerArcadeShip.PrimaryWeapon >= 0) and
     ((PlayerArcadeShip.Weapons[PlayerArcadeShip.PrimaryWeapon].SlotData and EquipmentSecondaryFireFlag) <> 0) then
    PlayerArcadeShip.PrimaryWeapon := -1;
  if PlayerArcadeShip.PrimaryWeapon < 0 then
    for Index := 0 to PlayerArcadeShip.WeaponCount - 1 do
      if (PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSecondaryFireFlag) = 0 then
      begin
        PlayerArcadeShip.PrimaryWeapon := Index;
        Break;
      end;
  if (PlayerArcadeShip.SecondaryWeapon >= 0) and
     ((PlayerArcadeShip.Weapons[PlayerArcadeShip.SecondaryWeapon].SlotData and EquipmentSecondaryFireFlag) = 0) then
    PlayerArcadeShip.SecondaryWeapon := -1;
  if PlayerArcadeShip.SecondaryWeapon < 0 then
    for Index := 0 to PlayerArcadeShip.WeaponCount - 1 do
      if (PlayerArcadeShip.Weapons[Index].SlotData and EquipmentSecondaryFireFlag) <> 0 then
      begin
        PlayerArcadeShip.SecondaryWeapon := Index;
        Break;
      end;
end;
{ @end $540F8C }

{ @routine $5410E8 TfAB_UpdateAutopilotButtons }
procedure TfAB.UpdateAutopilotButtons;
begin
  AutoButton.SetActive(ArcadeAutopilotEnabled);
  ManualButton.SetActive(not ArcadeAutopilotEnabled);
end;
{ @end $5410E8 }

{ @routine $541124 TfAB_ToggleAutopilot }
procedure TfAB.ToggleAutopilot(Sender: TObjectGI);
begin
  ArcadeLastInputTick := ArcadeTickCount;
  ArcadeAutopilotEnabled := not ArcadeAutopilotEnabled;
  UpdateAutopilotButtons;
end;
{ @end $541124 }

{ @routine $54115C TfAB_TogglePause }
procedure TfAB.TogglePause(Sender: TObjectGI);
begin
  HideObjectInfo;
  ArcadePauseWithShift := IsVirtualKeyDown(VK_SHIFT);
  ArcadePaused := Sender = PlayButton;
  PlayButton.SetActive(not ArcadePaused);
  PauseButton.SetActive(ArcadePaused);
  if PlayButton.Active then UpdateHelp(PlayButton, True)
  else UpdateHelp(PauseButton, True);
  BreakUiMessage;
end;
{ @end $54115C }

{ @routine $541208 TfAB_ReportSurvivingShips }
procedure TfAB.ReportSurvivingShips;
var
  Index: Integer;
  Ship: TabShip;
  Event: TGalaxyEvent;
begin
  if (PlayerArcadeShip <> nil) and (PlayerArcadeShip.Health > 0) then
  begin
    for Index := 0 to PlayerArcadeShip.TrackedShips.Count - 1 do
    begin
      Ship := PlayerArcadeShip.TrackedShips[Index];
      if (Ship <> nil) and (Ship.ScriptLabel <> '') and (Ship.Health > 0) then
      begin
        Event := AddGalaxyEvent('LabeledShipSurvivedInAB');
        Event.AddTextData(Ship.ScriptLabel);
        Event.AddData(Ship.Health);
        Event.AddData(Ship.MaxHealth);
      end;
    end;
    for Index := 0 to PlayerArcadeShip.InitialEnemies.Count - 1 do
    begin
      Ship := PlayerArcadeShip.InitialEnemies[Index];
      if (Ship <> nil) and (Ship.ScriptLabel <> '') and (Ship.Health > 0) then
      begin
        Event := AddGalaxyEvent('LabeledShipSurvivedInAB');
        Event.AddTextData(Ship.ScriptLabel);
        Event.AddData(Ship.Health);
        Event.AddData(Ship.MaxHealth);
      end;
    end;
  end;
end;
{ @end $541208 }

{ @routine $5413C8 TfAB_ClearBattle }
procedure TfAB.ClearBattle;
begin
  PlayerArcadeShip := nil;
  ab_Object_Clear;
  ClearGrid;
  ClearOverlaySegments;
  ab_Zone_ClearImages;
  ab_ZoneLink_ClearImages;
  ab_Polygon_Clear;
  ab_StopLine_Clear;
  ab_StopPoint_Clear;
  ab_WorldLine_Clear;
  ab_WorldImage_Clear;
  ab_Space_ClearImages;
  if WorldLines <> nil then WorldLines.ClearSegments;
  MapState2C8 := 0;
end;
{ @end $5413C8 }

{ @routine $541440 TfAB_ClearMap }
procedure TfAB.ClearMap;
begin
  ClearGrid;
  ClearOverlaySegments;
  ab_Zone_ClearImages;
  ab_ZoneLink_ClearImages;
  ab_Polygon_Clear;
  ab_StopLine_Clear;
  ab_StopPoint_Clear;
  ab_WorldLine_Clear;
  ab_WorldImage_Clear;
  ab_Space_ClearImages;
  WorldLines.ClearSegments;
end;
{ @end $541440 }

{ @routine $541490 TfAB_LoadMap }
procedure TfAB.LoadMap(Buffer: TBufEC; LoadPolygons: Boolean);
begin
  ClearMap;
  if (Buffer = nil) or (Buffer.DataSize < 32) then
    ab_StopLine_AddLatitude(10, 10)
  else
  begin
    if Buffer.GetUInt32 <> $6D776261 then RaiseWideMessage('Incorrect format ABMap');
    ArcadeMapVersion := Buffer.GetUInt32;
    SphereRadius := Buffer.GetSingle;
    if ArcadeMapColorBuffer = nil then ArcadeMapColorBuffer := TBufEC.Create
    else ArcadeMapColorBuffer.Clear;
    ArcadeMapColorBuffer.SetSize(Buffer.GetInt32);
    Buffer.ReadBytes(ArcadeMapColorBuffer.Data, ArcadeMapColorBuffer.DataSize);
    ab_StopLine_Load(Buffer);
    ab_Zone_Load(Buffer);
    if LoadPolygons then ab_Polygon_Load(Buffer);
  end;
end;
{ @end $541490 }

{ @routine $5415BC TfAB_LoadMapResource }
procedure TfAB.LoadMapResource(Path: WideString; LoadPolygons: Boolean);
var
  Control: TCBufControlEC;
  Data: TCBufEC;
begin
  Control := nil;
  try
    Control := TCBufControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Data := AcquireOrCreateBuffer(Control);
    LoadMap(Data.Buffer, LoadPolygons);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
  if LoadPolygons then
  begin
    Control := nil;
    try
      Control := TCBufControlEC.Create;
      GlobalCache.ResetControl(Control);
      Control.SetCacheKey(Path + '_');
      Data := AcquireOrCreateBuffer(Control);
      Data.Buffer.ExpandZlibPayloadInPlace;
      ab_Polygon_LoadVisibility(Data.Buffer);
    finally
      if Control <> nil then
      begin
        Control.Release;
        Control.Free;
      end;
    end;
  end;
  ab_StopPoint_ClearIndex;
end;
{ @end $5415BC }

{ @routine $541744 TfAB_LoadMapFile }
procedure TfAB.LoadMapFile(Path: WideString; LoadPolygons: Boolean);
var
  Buffer: TBufEC;
begin
  Buffer := TBufEC.Create;
  try
    Buffer.LoadFromWideFilePath(PWideChar(Path + '.map'));
    LoadMap(Buffer, LoadPolygons);
    if LoadPolygons then
    begin
      Buffer.Clear;
      Buffer.LoadFromWideFilePath(PWideChar(Path + '.opt'));
      Buffer.ExpandZlibPayloadInPlace;
      ab_Polygon_LoadVisibility(Buffer);
    end;
  finally
    Buffer.Free;
  end;
  ab_StopPoint_ClearIndex;
end;
{ @end $541744 }

{ @routine $541870 TfAB_ClearGrid }
procedure TfAB.ClearGrid;
var
  Index: Integer;
begin
  if GridLines <> nil then
  begin
    for Index := 0 to GridLines.Count - 1 do
      ab_WorldLine_Delete(GridLines[Index]);
    GridLines.Free;
    GridLines := nil;
  end;
end;
{ @end $541870 }

{ @routine $5418DC TfAB_BuildGrid }
procedure TfAB.BuildGrid;
var
  PolarAngle, Longitude, LongitudeStep, PolarStep: Double;
  First, Last: TVector3D;
begin
  ClearGrid;
  if (ArcadeGridMode <> 0) and (ArcadeViewMode = 0) then
  begin
    GridLines := TList.Create;
    LongitudeStep := Pi / 8;
    PolarStep := Pi / 16;
    Longitude := 0;
    while Longitude < Pi * 2 - 0.001 do
    begin
      PolarAngle := PolarStep * 2;
      while PolarAngle < Pi - PolarStep * 2 - 0.001 do
      begin
        First := SphericalToVector3D(Longitude, PolarAngle, SphereRadius);
        Last := SphericalToVector3D(Longitude, PolarAngle + PolarStep, SphereRadius);
        GridLines.Add(ab_WorldLine_Create(First, Last, 1,
          CurrentPixelFormat.PackRgbBytes(240, 240, 255),
          CurrentPixelFormat.PackRgbBytes(75, 75, 75), True));
        PolarAngle := PolarAngle + PolarStep;
      end;
      Longitude := Longitude + LongitudeStep;
    end;
    PolarStep := PolarStep * 2;
    PolarAngle := PolarStep;
    while PolarAngle < Pi - PolarStep + 0.001 do
    begin
      Longitude := 0;
      while Longitude < Pi * 2 - 0.001 do
      begin
        First := SphericalToVector3D(Longitude, PolarAngle, SphereRadius);
        Last := SphericalToVector3D(Longitude + LongitudeStep, PolarAngle, SphereRadius);
        GridLines.Add(ab_WorldLine_Create(First, Last, 1,
          CurrentPixelFormat.PackRgbBytes(240, 240, 255),
          CurrentPixelFormat.PackRgbBytes(75, 75, 75), True));
        Longitude := Longitude + LongitudeStep;
      end;
      PolarAngle := PolarAngle + PolarStep;
    end;
  end;
end;
{ @end $5418DC }

{ @routine $541B60 TfAB_ABSpaceBuild }
procedure TfAB.ABSpaceBuild(GridSize: Integer; Angle: Single);
var
  Index, Attempt, OtherIndex, Choice: Integer;
  Space, Other: TabSpace;
  Link: PabSpaceLink;
  Current, Candidate, Previous, StartPoint, EndPoint: TPoint;
  Position: TPointF;
  Changed, Retry: Boolean;
  UnusedLocal: Integer; // Native reserves an unused dword before BlockCount; original name/type unknown.
  BlockCount, Weight: Integer;
  Config, Selected: TBlockParEC;
  Exits: array[0..2] of Integer;
begin
  Weight := Min(10, Round(GridSize * 0.8));
  if Weight < 1 then Weight := 1;
  Retry := True;
  while Retry do
  begin
    Retry := False;
    ab_Space_Clear;
    for Index := 0 to GridSize - 1 do
      for Attempt := 0 to GridSize - 1 do
        with ab_Space_Add do
        begin
          GridPosition := Classes.Point(Index, Attempt);
          Position.X := RandomRange(-GiScalePixels(ArcadeMapNodeRadius), GiScalePixels(ArcadeMapNodeRadius)) + 5 * GiScalePixels(ArcadeMapNodeRadius) * Attempt;
          Position.Y := RandomRange(-GiScalePixels(ArcadeMapNodeRadius), GiScalePixels(ArcadeMapNodeRadius)) + 5 * GiScalePixels(ArcadeMapNodeRadius) * Index;
          MapPosition := Classes.Point(Round(Cos(Angle) * Position.X + Sin(Angle) * Position.Y),
            Round(Sin(Angle) * Position.X - Cos(Angle) * Position.Y));
        end;
    StartPoint := Classes.Point(0, GridSize div 2);
    EndPoint := Classes.Point(GridSize - 1, GridSize div 2);
    Previous := StartPoint;
    if Weight > 1 then
    begin
      for Index := 0 to Weight - 1 do
      begin
        Current := StartPoint;
        Space := ab_Space_Find(Current);
        while GridSize - 1 > Current.X do
        begin
          if (Abs(Current.X - EndPoint.X) <= 1) and (Abs(Current.Y - EndPoint.Y) <= 1) then
            Candidate := EndPoint
          else
          begin
            Attempt := 0;
            while Attempt < 5 do
            begin
              Inc(Attempt);
              Candidate.X := Current.X + 1;
              Candidate.Y := Current.Y + RandomRange(-1, 1);
              if ((Candidate.X <> Current.X) or (Candidate.Y <> Current.Y)) and
                ((Candidate.X <> Previous.X) or (Candidate.Y <> Previous.Y)) and
                (Candidate.X >= 0) and (Candidate.X < GridSize) and
                (Candidate.Y >= 0) and (Candidate.Y < GridSize) then
                if (Candidate.X = Current.X) or (Candidate.Y = Current.Y) or
                  (ab_SpaceLink_Find(ab_Space_Find(Classes.Point(Candidate.X, Current.Y)),
                    ab_Space_Find(Classes.Point(Current.X, Candidate.Y))) = nil) then
                begin
                  Other := ab_Space_Find(Candidate);
                  if (Other.IncomingCount < 3) and (Other.IncomingCount + Other.OutgoingCount < 4) then Break;
                end;
            end;
            if Attempt >= 5 then Break;
          end;
          Other := ab_Space_Find(Candidate);
          if ab_SpaceLink_Find(Space, Other) = nil then
          begin
            if (Current.X = StartPoint.X) and (Current.Y = StartPoint.Y) and (Space.OutgoingCount >= 3) then Break;
            ab_SpaceLink_Connect(Space, Other);
            Inc(Space.OutgoingCount);
            Inc(Other.IncomingCount);
          end;
          Previous := Current;
          Current := Candidate;
          Space := Other;
        end;
        ab_Space_RecountLinks;
      end;
      Changed := True;
      while Changed do
      begin
        Changed := False;
        Space := FirstArcadeSpace;
        while Space <> nil do
        begin
          Other := Space;
          Space := Space.Next;
          if ((Other.GridPosition.X <> EndPoint.X) or (Other.GridPosition.Y <> EndPoint.Y)) and
            ((Other.GridPosition.X <> StartPoint.X) or (Other.GridPosition.Y <> StartPoint.Y)) and
            ((Other.OutgoingCount = 0) or (Other.IncomingCount = 0)) then
          begin
            Changed := True;
            ab_Space_Delete(Other);
          end;
        end;
        ab_Space_RecountLinks;
      end;
      Space := ab_Space_Find(EndPoint);
      if Space.IncomingCount <= 0 then Retry := True;
    end;
  end;
  StartArcadeSpace := ab_Space_Add;
  StartArcadeSpace.GridPosition := Classes.Point(StartPoint.X - 1, StartPoint.Y);
  Position.X := 5 * GiScalePixels(ArcadeMapNodeRadius) * StartArcadeSpace.GridPosition.Y;
  Position.Y := 5 * GiScalePixels(ArcadeMapNodeRadius) * StartArcadeSpace.GridPosition.X;
  StartArcadeSpace.BoundaryKind := 1;
  StartArcadeSpace.MapPosition := Classes.Point(Round(Cos(Angle) * Position.X + Sin(Angle) * Position.Y),
    Round(Sin(Angle) * Position.X - Cos(Angle) * Position.Y));
  EndArcadeSpace := ab_Space_Add;
  EndArcadeSpace.GridPosition := Classes.Point(EndPoint.X + 1, EndPoint.Y);
  Position.X := 5 * GiScalePixels(ArcadeMapNodeRadius) * EndArcadeSpace.GridPosition.Y;
  Position.Y := 5 * GiScalePixels(ArcadeMapNodeRadius) * EndArcadeSpace.GridPosition.X;
  EndArcadeSpace.BoundaryKind := 1;
  EndArcadeSpace.MapPosition := Classes.Point(Round(Cos(Angle) * Position.X + Sin(Angle) * Position.Y),
    Round(Sin(Angle) * Position.X - Cos(Angle) * Position.Y));
  ab_SpaceLink_Connect(StartArcadeSpace, ab_Space_Find(StartPoint));
  ab_SpaceLink_Connect(ab_Space_Find(EndPoint), EndArcadeSpace);
  ab_Space_RecountLinks;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    if (StartArcadeSpace <> Space) and (EndArcadeSpace <> Space) then Space.Danger := RandomRange(10, 100);
    Space := Space.Next;
  end;
  Space := StartArcadeSpace;
  while not (EndArcadeSpace = Space) do
  begin
    Choice := RandomRange(0, Space.OutgoingCount - 1);
    Link := FirstArcadeSpaceLink;
    while Link <> nil do
    begin
      if Link.First = Space then
      begin
        Dec(Choice);
        if Choice < 0 then
        begin
          Space := Link.Last;
          Break;
        end;
      end;
      Link := Link.Next;
    end;
    Space.Danger := 0;
  end;
  Other := nil;
  if (GetPlayer <> nil) and (GetPlayer.Order = soJumpHole) and
    ((GetPlayer.OrderTarget as THole).HoleType = 4) and (Galaxy.KellerLeaveTurn = 0) and
    (KellerShip <> nil) and KellerShip.InHyperspace and (Galaxy.KellerMissionState in [4, 5]) then
  begin
    Other := ab_Space_Find(EndPoint);
    Other.Danger := 100;
  end;
  ab_Space_UpdateApproachDanger;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    if Space.Danger <= 0 then Space.AppearanceIndex := RandomRange(0, 1)
    else if Space.Danger + Space.ApproachDanger < ArcadeHighDangerThreshold then Space.AppearanceIndex := RandomRange(0, 1) + 2
    else Space.AppearanceIndex := RandomRange(0, 1) + 4;
    Space := Space.Next;
  end;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    if (StartArcadeSpace <> Space) and (EndArcadeSpace <> Space) then
    begin
      Space.Color28 := ArcadeMapPalette[Space.AppearanceIndex * 6 + 4];
      Space.Color30 := ArcadeMapPalette[Space.AppearanceIndex * 6 + 5];
      Space.Color2C := (ArcadeMapPalette[Space.AppearanceIndex * 6 + 4] and $FFFFFF) or $80000000;
      Space.Color34 := (ArcadeMapPalette[Space.AppearanceIndex * 6 + 5] and $FFFFFF) or $80000000;
      if Space = Other then Space.PopulateKellerEncounter
      else if (GetPlayer <> nil) and (GetPlayer.Order = soJumpHole) and (ActiveArcadeRequest = nil) then Space.PopulateHoleEncounter
      else if (GetPlayer <> nil) and (ActiveArcadeRequest <> nil) then Space.PopulateScriptedEncounter
      else Space.PopulateObjects;
    end;
    Space := Space.Next;
  end;
  CurrentArcadeSpace := StartArcadeSpace;
  NextArcadeSpace := ab_Space_Find(StartPoint);
  ArcadeMapViewPosition := CurrentArcadeSpace.MapPosition;
  PlayerVisual.SetAngle(HeadingDegreesToByte(RadiansToHeadingDegrees(Angle)));
  PlayerMapPosition := PointToPointF(StartArcadeSpace.MapPosition);
  RouteSpaces.Add(NextArcadeSpace);
  RebuildShipPath;
  ClearShipPath;
  ArcadeMapCenter := Classes.Point((StartArcadeSpace.MapPosition.X + EndArcadeSpace.MapPosition.X) div 2,
    (StartArcadeSpace.MapPosition.Y + EndArcadeSpace.MapPosition.Y) div 2);
  if GetPlayer <> nil then
  begin
    if KellerArcadeShip <> nil then MapBackgroundPath := 'Bm.FormAB2.2bg3'
    else if (ActiveArcadeRequest <> nil) and (ActiveArcadeRequest.BackgroundId <> 0) then
      MapBackgroundPath := 'Bm.FormAB2.2bg' + IntToStr(ActiveArcadeRequest.BackgroundId)
    else if (ActiveArcadeRequest <> nil) and (ActiveArcadeRequest.BackgroundMapName <> '') then
      MapBackgroundPath := ActiveArcadeRequest.BackgroundMapName
    else MapBackgroundPath := 'Bm.FormAB2.2bg' + IntToStr(RandomRange(1, 3));
  end
  else MapBackgroundPath := 'Bm.FormAB2.2bg' + IntToStr(RandomRange(1, 3));
  Config := GameDataConfig.GetBlock('ABMap');
  BlockCount := Config.GetBlockCount;
  Weight := 0;
  for Index := 0 to BlockCount - 1 do
    Inc(Weight, ExtractDigitsToIntW(Config.GetBlockByIndex(Index).GetParam('Priority')));
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    if Space.BoundaryKind = 1 then Space := Space.Next
    else
    begin
      if Space.OutgoingCount > 3 then RaiseWideMessage('Error in ABSpaceBuild');
      Changed := False;
      Retry := False;
      Selected := nil;
      if (KellerArcadeShip <> nil) and (GetPlayer <> nil) then Space.MapPath := 'ABMap.map_boss'
      else if (GetPlayer <> nil) and (ActiveArcadeRequest <> nil) then Space.MapPath := ActiveArcadeRequest.MapName
      else
      begin
        Attempt := RandomRange(0, Weight - 1);
        Index := 0;
        while True do
        begin
          Selected := Config.GetBlockByIndex(Index);
          if FindTextOffsetW(Selected.GetParam('Portal'), IntToStr(Space.OutgoingCount)) >= 0 then
          begin
            Changed := True;
            Retry := True;
            Dec(Attempt, ExtractDigitsToIntW(Selected.GetParam('Priority')));
            if Attempt < 0 then Break;
          end;
          Inc(Index);
          if Index >= BlockCount then
          begin
            Index := 0;
            if not Retry then Break;
            Retry := False;
          end;
        end;
        if not Changed then RaiseWideMessage('ABMap not found');
        Space.MapPath := Selected.GetParam('Path');
      end;
      Space := Space.Next;
    end;
  end;
  ArcadeMapBounds.TopLeft := FirstArcadeSpace.MapPosition;
  ArcadeMapBounds.BottomRight := FirstArcadeSpace.MapPosition;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    ArcadeMapBounds.Left := Min(ArcadeMapBounds.Left, Space.MapPosition.X);
    ArcadeMapBounds.Right := Max(ArcadeMapBounds.Right, Space.MapPosition.X);
    ArcadeMapBounds.Top := Min(ArcadeMapBounds.Top, Space.MapPosition.Y);
    ArcadeMapBounds.Bottom := Max(ArcadeMapBounds.Bottom, Space.MapPosition.Y);
    Exits[0] := 0;
    Exits[1] := 0;
    Exits[2] := 0;
    if Space.PortalSlotCount > 1 then Exits[1] := 1;
    if Space.PortalSlotCount > 2 then Exits[2] := 2;
    for Index := 0 to 4 do
    begin
      Attempt := RandomRange(0, Space.PortalSlotCount - 1);
      OtherIndex := RandomRange(0, Space.PortalSlotCount - 1);
      Choice := Exits[Attempt];
      Exits[Attempt] := Exits[OtherIndex];
      Exits[OtherIndex] := Choice;
    end;
    Index := 0;
    Link := FirstArcadeSpaceLink;
    while Link <> nil do
    begin
      if Link.First = Space then
      begin
        if Index >= 3 then RaiseWideMessage('EError');
        Link.ExitIndex := Exits[Index];
        Inc(Index);
      end;
      Link := Link.Next;
    end;
    Space := Space.Next;
  end;
end;
{ @end $541B60 }

{ @routine $542E64 TfAB_ResetBattleControls }
procedure TfAB.ResetBattleControls;
begin
  CloseVictory(nil, 0);
  ListedObjects.Clear;
  SimulationPaused := False;
  ForwardKeyDown := False;
  ReverseKeyDown := False;
  BrakeKeyDown := False;
  TurnLeftKeyDown := False;
  TurnRightKeyDown := False;
  PrimaryFireKeyDown := False;
  SecondaryFireKeyDown := False;
  PlayerArcadeShip.DisruptUntilTick := 0;
  ArcadeLastInputTick := ArcadeTickCount;
  ArcadeAutopilotEnabled := False;
  ArcadeEnemiesDefeated := False;
  UpdateAutopilotButtons;
  CacheLoadLoggingEnabled := False;
  ArcadeViewMode := 0;
  SetSystemCursorPosition(Classes.Point(GameScreenWidth - 2, GameScreenHeight - 2));
end;
{ @end $542E64 }

{ @routine $542F4C TfAB_BeginMapTransition }
procedure TfAB.BeginMapTransition;
var
  NextObject, Obj: TabObject;
begin
  CloseVictory(nil, 0);
  ArcadeViewMode := 1;
  CancelCargoPickup;
  NextObject := FirstArcadeObject;
  while NextObject <> nil do
  begin
    Obj := NextObject;
    NextObject := NextObject.Next;
    if PlayerArcadeShip <> Obj then ab_Object_Delete(Obj);
  end;
  TransitionSpeed := 10;
end;
{ @end $542F4C }

{ @routine $542FC4 TfAB_EnterMapView }
procedure TfAB.EnterMapView;
var
  Obj: TabObject;
begin
  CloseVictory(nil, 0);
  ForwardKeyDown := False;
  ReverseKeyDown := False;
  BrakeKeyDown := False;
  TurnLeftKeyDown := False;
  TurnRightKeyDown := False;
  PrimaryFireKeyDown := False;
  SecondaryFireKeyDown := False;
  ArcadeViewMode := 2;
  UpdateWeaponPanel;
  CancelCargoPickup;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj is TabShip then (Obj as TabShip).DetachVisual;
    Obj := Obj.Next;
  end;
  with StartStarImage do
  begin
    SetSize(GetContentSize);
    SetOrigin(HalfPoint(ClientSize));
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetActive(True);
    RestartPlayback;
  end;
  with EndStarImage do
  begin
    SetSize(GetContentSize);
    SetOrigin(HalfPoint(ClientSize));
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetActive(True);
    RestartPlayback;
  end;
  StarField.SetBackgroundImage(MapBackgroundPath);
  StarField.BackgroundScale := 8;
  SphereCameraDistance := 1000 + SphereNearCameraOffset;
  UpdateSphereProjectionMetrics;
  ab_Space_CreateImages;
  ab_SpaceLink_BuildGeometry;
  PlayerVisual.AttachToSpace(ArcadeSpaceProcess.Space);
  PlayerVisual.SetDepth(ShipFrontDepth);
  if PlayerVisual is TShip2SE then TShip2SE(PlayerVisual).SetTailDepth(ShipTailFrontDepth);
  PlayerMapPosition := PointToPointF(CurrentArcadeSpace.MapPosition);
  PlayerVisual.SetPosition(PlayerMapPosition);
  if NextArcadeSpace <> nil then
    PlayerVisual.SetAngle(HeadingDegreesToByte(PointBearingDegrees(PointToPointF(CurrentArcadeSpace.MapPosition), PointToPointF(NextArcadeSpace.MapPosition))));
  if NextArcadeSpace = nil then BuildSpaceRoute(RouteSpaces, CurrentArcadeSpace, EndArcadeSpace)
  else if (RouteSpaces.Count < 1) or (RouteSpaces[0] <> NextArcadeSpace) then
  begin
    RouteSpaces.Clear;
    RouteSpaces.Add(NextArcadeSpace);
  end;
  RebuildShipPath;
  if NextArcadeSpace = nil then BuildShipPathImages else ClearShipPath;
  ArcadePauseWithShift := False;
  ArcadePaused := NextArcadeSpace <> nil;
  PlayButton.SetActive(not ArcadePaused);
  PauseButton.SetActive(ArcadePaused);
  ab_StopLine_Clear;
  ab_StopPoint_Clear;
  if (GetPlayer <> nil) and CampaignTransitionStarted and CampaignLoadStarted and not CampaignLoadFinished then CacheLoader.ClearFlag18;
  GetByName('PRight').SetActive(True);
end;
{ @end $542FC4 }

{ @routine $5433D8 TfAB_EnterCurrentSpace }
procedure TfAB.EnterCurrentSpace;
var
  Obj, Other: TabObject;
  ExitLink: PabSpaceLink;
  StopLine: PabStopLine;
  Zone: PabZone;
  ZoneLink: PabZoneLink;
  Ship: TabShipAI;
  Wall, OtherWall: TabWall;
  Index, OtherIndex, DesiredColor, ColorCount, BestDifference, ColorValue, Selection: Integer;
  HasEnemies: Boolean;
  PendingLoads: TList;
  Remaining: Integer;
  ColorData: PArcadeMapColorHeader;
  UnusedLocal: Integer; // Native unused dword before compiler temporaries; original name/type unknown.
begin
  CloseVictory(nil, 0);
  GetByName('PRight').SetActive(False);
  HideObjectInfo;
  CancelCargoPickup;
  HasEnemies := GetPlayer = nil;
  ArcadeViewMode := 3;
  StarField.SetViewPosition(MakePointF(0, 0));
  ClearShipPath;
  if (GetPlayer <> nil) and CampaignTransitionStarted and CampaignLoadStarted and not CampaignLoadFinished then CacheLoader.SetFlag18;
  PlayerArcadeShip.StopThrust;
  PlayerArcadeShip.Velocity := MakePointF(0, 0);
  PlayerArcadeShip.SetTurnInput(0);
  ab_Space_ClearImages;
  StartStarImage.SetActive(False);
  EndStarImage.SetActive(False);
  PlayerVisual.DetachFromSpace;
  StarField.SetBackgroundImage(MapBackgroundPath);
  StarField.BackgroundScale := 8;
  if (Length(SelectedMapName) > 0) and (SelectedMapName <> 'SkipAB') and (SelectedMapName <> 'NoEntry') then
  begin
    if SysUtils.FileExists(SelectedMapName + '.map') then LoadMapFile(SelectedMapName, True)
    else LoadMapResource(SelectedMapName, True);
  end
  else LoadMapResource(CurrentArcadeSpace.MapPath, True);
  Remaining := ArcadeMapColorBuffer.DataSize;
  ColorData := ArcadeMapColorBuffer.Data;
  while Remaining > 0 do
  begin
    ColorCount := PInteger(@ColorData.VariantCount)^;
    Selection := PInteger(@ColorData.SelectedVariant)^;
    if Selection = 0 then
    begin
      Selection := 0;
      for Index := 0 to ColorCount - 1 do
      begin
        ColorValue := PInteger(Index * SizeOf(TArcadeMapColorVariant) + SizeOf(TArcadeMapColorHeader) + SizeOf(Integer) + PAnsiChar(ColorData))^;
        if ColorValue = 0 then
        begin
          Selection := Index;
          Break;
        end;
      end;
    end
    else
    begin
      ExitLink := ab_SpaceLink_FindExit(CurrentArcadeSpace, Selection - 1);
      if ExitLink = nil then
      begin
        Selection := -1;
        for Index := 0 to ColorCount - 1 do
        begin
          ColorValue := PInteger(Index * SizeOf(TArcadeMapColorVariant) + SizeOf(TArcadeMapColorHeader) + SizeOf(Integer) + PAnsiChar(ColorData))^;
          if ColorValue = 0 then
          begin
            Selection := Index;
            Break;
          end;
        end;
      end
      else
      begin
        DesiredColor := 0;
        case ExitLink.Last.AppearanceIndex of
          0: DesiredColor := 1;
          1: DesiredColor := 2;
          2: DesiredColor := 21;
          3: DesiredColor := 22;
          4: DesiredColor := 31;
          5: DesiredColor := 32;
        else RaiseWideMessage('AB color');
        end;
        Selection := 0;
        BestDifference := 999999;
        for Index := 0 to ColorCount - 1 do
        begin
          ColorValue := PInteger(Index * SizeOf(TArcadeMapColorVariant) + SizeOf(TArcadeMapColorHeader) + SizeOf(Integer) + PAnsiChar(ColorData))^;
          if ColorValue < 20 then Dec(ColorValue, 10);
          ColorValue := Abs(DesiredColor - ColorValue);
          if ColorValue < BestDifference then
          begin
            BestDifference := ColorValue;
            Selection := Index;
          end;
        end;
      end;
    end;
    PInteger(@ColorData.SelectedVariant)^ := Selection;
    Dec(Remaining, PInteger(@ColorData.ByteSize)^);
    ColorData := Pointer(PInteger(@ColorData.ByteSize)^ + PAnsiChar(ColorData));
  end;
  ArcadeKellerEncounter := (GetPlayer <> nil) and (GetPlayer.Order = soJumpHole) and
    ((GetPlayer.OrderTarget as THole).HoleType = 4) and (Galaxy.KellerLeaveTurn = 0) and
    (KellerShip <> nil) and (Galaxy.KellerMissionState in [4, 5]);
  if GetPlayer <> nil then
  begin
    for Index := 0 to CurrentArcadeSpace.Objects.Count - 1 do
    begin
      Obj := CurrentArcadeSpace.Objects[Index];
      ab_Object_Add(Obj);
      if Obj is TabShipAI then
      begin
        if ActiveArcadeRequest = nil then
        begin
          Ship := Obj as TabShipAI;
          PlayerArcadeShip.AddEnemy(Ship);
          Ship.AddEnemy(PlayerArcadeShip);
          if Galaxy <> nil then
            if (KellerArcadeShip = nil) and Galaxy.IsArcadeBattleRoyaleEnabled then
              for OtherIndex := Index + 1 to CurrentArcadeSpace.Objects.Count - 1 do
              begin
                Other := CurrentArcadeSpace.Objects[OtherIndex];
                if (Other is TabShipAI) and (PlayerArcadeShip <> Other) then
                  if Ship.Visual.GraphKey <> (Other as TabShipAI).Visual.GraphKey then
                  begin
                    Ship.AddEnemy(Other as TabShipAI);
                    (Other as TabShipAI).AddEnemy(Ship);
                  end;
              end;
        end;
        HasEnemies := True;
      end;
    end;
    CurrentArcadeSpace.Objects.Clear;
  end;
  ab_StopLine_BuildCollisionList;
  ab_Zone_BuildAllRoutes;
  BuildGrid;
  ab_StopPoint_ClearImages;
  ab_StopLine_UpdateWorldLines;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj is TabShip then
    begin
      if PlayerArcadeShip = Obj then
      begin
        Zone := ab_Zone_RandomKind(1);
        if Zone = nil then Zone := ab_Zone_RandomKind(0);
        (Obj as TabShip).State := ab_Zone_RandomPosition(Zone);
      end
      else (Obj as TabShip).State := ab_Zone_RandomPosition(ab_Zone_RandomKind(0));
      (Obj as TabShip).Visual.SetAlpha(0);
      (Obj as TabShip).AttachVisual;
      if Obj is TabShipAI then (Obj as TabShipAI).ResetIntent;
    end
    else if Obj is TabItem then
      (Obj as TabItem).State := ab_Zone_RandomPosition(ab_Zone_RandomKind(0));
    Obj := Obj.Next;
  end;
  Zone := FirstZone;
  while Zone <> nil do
  begin
    if (Zone.Kind = 5) or ((Zone.Kind in [6..8]) and (HasEnemies and not ArcadeKellerEncounter)) then
    begin
      Wall := TabWall.Create;
      ab_Object_Add(Wall);
      Wall.BindZone(Zone);
      Wall.CollisionRadius := 40;
      Wall.MaxSpeed := 0;
      if Zone.Kind = 5 then
      begin
        Wall.MaxHealth := Zone.BarrierHealth;
        if Wall.MaxHealth >= 1000000 then Wall.CollisionRadius := 0;
      end
      else if ArcadeKellerEncounter then
      begin
        Wall.MaxHealth := 1000000;
        Wall.CollisionRadius := 0;
      end
      else if (GetPlayer <> nil) and (GetPlayer.Order = soJumpHole) then
        Wall.MaxHealth := Zone.BarrierHealth
      else Wall.MaxHealth := Zone.BarrierHealth;
      Wall.Health := Wall.MaxHealth;
      Wall.State := MakeSphericalBearingState(Zone.Longitude, Zone.PolarAngle, 0);
      Wall.AttachVisual;
    end;
    Zone := Zone.Next;
  end;
  ZoneLink := FirstZoneLink;
  while ZoneLink <> nil do
  begin
    if (ZoneLink.BarrierLinkMode = 1) and (ZoneLink.First.Kind in [6..8]) and (ZoneLink.Last.Kind in [6..8]) then
    begin
      Wall := ab_Wall_FindZone(ZoneLink.First);
      OtherWall := ab_Wall_FindZone(ZoneLink.Last);
      if Wall <> nil then
        if OtherWall <> nil then
        begin
          if Wall.StopPoint = nil then
          begin
            Wall.StopPoint := ab_StopPoint_Add;
            Wall.StopPoint.Longitude := ZoneLink.First.Longitude;
            Wall.StopPoint.PolarAngle := ZoneLink.First.PolarAngle;
            Wall.StopPoint.Radius := SphereRadius;
            ab_StopPoint_UpdatePosition(Wall.StopPoint);
          end;
          if OtherWall.StopPoint = nil then
          begin
            OtherWall.StopPoint := ab_StopPoint_Add;
            OtherWall.StopPoint.Longitude := ZoneLink.Last.Longitude;
            OtherWall.StopPoint.PolarAngle := ZoneLink.Last.PolarAngle;
            OtherWall.StopPoint.Radius := SphereRadius;
            ab_StopPoint_UpdatePosition(OtherWall.StopPoint);
          end;
          StopLine := ab_StopLine_Add;
          StopLine.First := Wall.StopPoint;
          StopLine.Last := OtherWall.StopPoint;
          StopLine.Visible := False;
          StopLine.Collidable := True;
        end;
    end;
    ZoneLink := ZoneLink.Next;
  end;
  ZoneLink := FirstZoneLink;
  while ZoneLink <> nil do
  begin
    if (ZoneLink.BarrierLinkMode = 1) and (ZoneLink.First.Kind = 5) and (ZoneLink.Last.Kind = 5) then
    begin
      Wall := ab_Wall_FindZone(ZoneLink.First);
      OtherWall := ab_Wall_FindZone(ZoneLink.Last);
      if Wall <> nil then
        if OtherWall <> nil then
        begin
          if Wall.StopPoint = nil then
          begin
            Wall.StopPoint := ab_StopPoint_Add;
            Wall.StopPoint.Longitude := ZoneLink.First.Longitude;
            Wall.StopPoint.PolarAngle := ZoneLink.First.PolarAngle;
            Wall.StopPoint.Radius := SphereRadius;
            ab_StopPoint_UpdatePosition(Wall.StopPoint);
          end;
          if OtherWall.StopPoint = nil then
          begin
            OtherWall.StopPoint := ab_StopPoint_Add;
            OtherWall.StopPoint.Longitude := ZoneLink.Last.Longitude;
            OtherWall.StopPoint.PolarAngle := ZoneLink.Last.PolarAngle;
            OtherWall.StopPoint.Radius := SphereRadius;
            ab_StopPoint_UpdatePosition(OtherWall.StopPoint);
          end;
          StopLine := ab_StopLine_Add;
          StopLine.First := Wall.StopPoint;
          StopLine.Last := OtherWall.StopPoint;
          StopLine.Visible := False;
          StopLine.Collidable := True;
        end;
    end;
    ZoneLink := ZoneLink.Next;
  end;
  ab_StopLine_BuildCollisionList;
  ab_Wall_BuildBarrierImages;
  ab_StopLine_UpdateWorldLines;
  SphereViewState := PlayerArcadeShip.State;
  SphereViewState.BearingDegrees := 0;
  SphereCameraDistance := SphereRadius + SphereFarCameraOffset;
  TransitionSpeed := 500;
  UpdateWeaponPanel;
  PendingLoads := TList.Create;
  QueueArcadeLoadingAssets(PendingLoads, ContentPanel);
  LoadPendingAssets(PendingLoads);
  PendingLoads.Free;
  RefreshTimerTick;
end;
{ @end $5433D8 }

{ @routine $544150 TfAB_AdvanceMapColors }
procedure TfAB.AdvanceMapColors;
var
  Remaining, BlockBytes, Selection, FrameIndex, FrameCount: Integer;
  ColorData: PArcadeMapColorHeader;
  Frames: PArcadeMapColorSequence;
begin
  // Variable-sized native color blocks: current color, variant count, selected
  // variant, byte size; then (sequence offset, appearance tag) pairs. Each
  // sequence stores its current frame, frame count and packed color frames.
  Remaining := ArcadeMapColorBuffer.DataSize;
  ColorData := ArcadeMapColorBuffer.Data;
  while Remaining > 0 do
  begin
    Selection := PInteger(@ColorData.SelectedVariant)^;
    BlockBytes := PInteger(@ColorData.ByteSize)^;
    if Selection < 0 then ColorData.CurrentColor := 0
    else
    begin
      Frames := Pointer(PArcadeMapColorVariant(Selection * SizeOf(TArcadeMapColorVariant) + SizeOf(TArcadeMapColorHeader) + PAnsiChar(ColorData)).SequenceOffset + PAnsiChar(ColorData));
      FrameIndex := Frames.FrameIndex;
      FrameCount := PInteger(@Frames.FrameCount)^;
      Inc(FrameIndex);
      if FrameIndex >= FrameCount then FrameIndex := 0;
      Frames.FrameIndex := FrameIndex;
      ColorData.CurrentColor := PInteger(FrameIndex * SizeOf(Integer) + SizeOf(TArcadeMapColorSequence) + PAnsiChar(Frames))^;
    end;
    ColorData := Pointer(PAnsiChar(ColorData) + BlockBytes);
    Dec(Remaining, BlockBytes);
  end;
end;
{ @end $544150 }

{ @routine $544214 TfAB_TimerTakt }
procedure TfAB.TimerTakt(Timer: PCallbackTimerGI; UserData: Integer);
var
  Obj, NextObject: TabObject;
  BearingDegrees, Distance, Step: Double;
  Position: TPointF;
  TargetLongitude, TargetPolarAngle, SourceLongitude, SourcePolarAngle: Double;
  Loads: TList;
  Index: Integer;
  Space: TabSpace;
  Panel: TObjectGI;
  Owner: TPanelGI;
  Stage: Integer;
  LabelControl, DateLabel: TLabelGI;
  CameraPos, TargetPos, UpVector: TVector3D;
  View, Rotation: TMatrix4D;
  UnusedBeforeBearing: array[0..7] of Byte; // Native unused bytes between the matrix and bearing records.
  Bearing: TSphericalBearingDistance;
  State: TSphericalBearingState;
  UnusedAfterState: array[0..3] of Byte; // Native unused bytes before backend temporaries.
begin
  Stage := 0;
  Obj := nil;
  try
    if Galaxy <> nil then
      if (GetPlayer = nil) or (GetPlayer.GetHull.HullPoints <= 0) then
      begin
        if GetPlayer <> nil then Galaxy.ScoreScreenDismissed := 1;
        while GetPlayer <> nil do SysUtils.Sleep(1);
        RequestedScreenId := screenGameEnd;
        if UpdateTimer <> nil then
        begin
          CancelCallbackTimer(UpdateTimer);
          UpdateTimer := nil;
        end;
        RequestClose(1);
        Exit;
      end;
    Stage := 1;
    if ArcadeViewMode = 0 then
    begin
      if not ArcadeAutopilotEnabled and not ArcadeEnemiesDefeated and not DisableAutoPilot and
        ((ArcadeTickCount - ArcadeLastInputTick) * 20 > ChangeAutoPilot * 1000) then
      begin
        ArcadeAutopilotEnabled := True;
        UpdateAutopilotButtons;
      end;
      AdvanceMapColors;
      ab_Item_Update;
    end;
    Stage := 2;
    if (GetPlayer <> nil) and ((PlayerArcadeShip = nil) or (PlayerArcadeShip.Health <= 0)) then
    begin
      Stage := 3;
      if DefeatCountdownTicks <= 0 then
      begin
        ScoreScreen.RecordPlayerResult(False);
        GetPlayer.Free;
        GameEndReason := 3;
        RequestedScreenId := screenGameEnd;
        ClearPendingScriptRequests;
        ActiveArcadeRequest := nil;
        ActiveArcadeRequestShips := nil;
        ArcadeKellerDefeats := 0;
        if ArcadeKellerReward <> nil then
        begin
          ArcadeKellerReward.Free;
          ArcadeKellerReward := nil;
        end;
        if UpdateTimer <> nil then
        begin
          CancelCallbackTimer(UpdateTimer);
          UpdateTimer := nil;
        end;
        RequestClose(1);
        Exit;
      end;
      Dec(DefeatCountdownTicks);
      if VictoryPanel.Active then CloseVictory(nil, 0);
    end
    else if (Galaxy = nil) and (GetPlayer = nil) and ((PlayerArcadeShip = nil) or (PlayerArcadeShip.Health <= 0)) then
    begin
      Stage := 4;
      if (DefeatCountdownTicks <= 0) and not DefeatPanel.Active then
      begin
        Owner := GetByName('LoseKeyPress') as TPanelGI;
        Owner.FreeOwnedChildren;
        LabelControl := TLabelGI.Create(Owner);
        LabelControl.SetFontName(NormalFontName);
        LabelControl.SetPosition(Classes.Point(0, GiScalePixels(30)));
        LabelControl.SetSize(Classes.Point(Owner.ClientSize.X, 1));
        LabelControl.SetTextAlignX(taxCenter);
        LabelControl.SetTextAlignY(tayAuto);
        LabelControl.SetText(LocalizedColorText('FormAB.TextExit'));
        LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
        Owner.SetSize(Classes.Point(Owner.ClientSize.X, GiScalePixels(30) + Owner.ClientSize.Y + LabelControl.ClientSize.Y));
        Panel := DefeatPanel;
        Panel.SetSize(Classes.Point(Panel.ClientSize.X, Owner.LocalPosition.Y + Owner.ClientSize.Y + GiScalePixels(20)));
        Panel.SetActive(True);
        Panel := GetByName('LoseShr');
        Panel.SetSize(Classes.Point(Panel.ClientSize.X, Owner.LocalPosition.Y + Owner.ClientSize.Y + GiScalePixels(20)));
        GetByName('PanelLoseHide').SetActive(True);
      end;
      if DefeatCountdownTicks <= -500 then
      begin
        ScreenLoadMode := 4;
        PostLoadScreenId := screenLoadArcade;
        RequestedScreenId := screenLoad;
        if UpdateTimer <> nil then
        begin
          CancelCallbackTimer(UpdateTimer);
          UpdateTimer := nil;
        end;
        RequestClose(1);
        Exit;
      end;
      Dec(DefeatCountdownTicks);
    end
    else if ArcadeKellerEncounter then
    begin
      Stage := 5;
      if not KellerSplitActive and (KellerBreakupTicks > 50) and (KellerArcadeShip <> nil) and
        (KellerFragments[0] <> nil) and (PlayerArcadeShip <> nil) and (PlayerArcadeShip.Health > 0) then
      begin
        KellerSplitActive := True;
        BeginKellerDialogTransition;
      end;
    end;
    Stage := 6;
    if ArcadeViewMode in [2, 5] then
    begin
      Stage := 7;
      if (ArcadeViewMode = 2) and (NextArcadeSpace <> nil) and (ShipPath <> nil) and (ShipPath.ActiveHead <> nil) then
      begin
        Stage := 8;
        if IsCursorImageSelected('Scroll') then SetCursorByName('Main');
        MapDrag.Active := False;
        BearingDegrees := HeadingDegreesToRadians(PointBearingDegrees(PointToPointF(CurrentArcadeSpace.MapPosition), PointToPointF(NextArcadeSpace.MapPosition)));
        PlayerMapPosition.X := Sin(BearingDegrees) * 4 + PlayerMapPosition.X;
        PlayerMapPosition.Y := PlayerMapPosition.Y - Cos(BearingDegrees) * 4;
        if PlayerVisual is TShip2SE then
          TShip2SE(PlayerVisual).OffsetTailsAlongHeading(PointDistance(PlayerMapPosition, ShipPath.ActiveHead.Position) / 2.5 + RandomIntRange(0, 1) * 0.3);
        PlayerMapPosition := ShipPath.ActiveHead.Position;
        PlayerVisual.SetAngle(HeadingDegreesToByte(ShipPath.ActiveHead.Heading));
        ShipPath.RemoveNode(ShipPath.ActiveHead);
        if (ShipPath.ActiveHead = nil) or
          (PointDistanceSquared(PointToPointF(NextArcadeSpace.MapPosition), PlayerMapPosition) <= ArcadePathStep * ArcadePathStep) then
        begin
          Stage := 9;
          CurrentArcadeSpace := NextArcadeSpace;
          RouteSpaces.Delete(RouteSpaces.IndexOf(NextArcadeSpace));
          NextArcadeSpace := nil;
          Index := 0;
          while Index < CurrentArcadeSpace.Objects.Count do
          begin
            if TObject(CurrentArcadeSpace.Objects[Index]) is TabShip then Break;
            Inc(Index);
          end;
          if (Index < CurrentArcadeSpace.Objects.Count) and (RandomRange(1, 100) <= CurrentArcadeSpace.Danger) then
          begin
            SelectMusic;
            EnterCurrentSpace;
          end
          else
          begin
            if (RouteSpaces.Count > 0) and ArcadePaused then NextArcadeSpace := RouteSpaces[0]
            else
            begin
              ArcadePauseWithShift := False;
              ArcadePaused := False;
              PlayButton.SetActive(not ArcadePaused);
              PauseButton.SetActive(ArcadePaused);
              if RouteSpaces.Count < 1 then BuildSpaceRoute(RouteSpaces, CurrentArcadeSpace, EndArcadeSpace);
              RebuildShipPath;
              BuildShipPathImages;
            end;
          end;
        end;
      end;
      if (ArcadeViewMode = 2) and (NextArcadeSpace = nil) and (CurrentArcadeSpace <> EndArcadeSpace) and ArcadePaused then
      begin
        Stage := 10;
        HideObjectInfo;
        ClearShipPath;
        if RouteSpaces.Count < 1 then BuildSpaceRoute(RouteSpaces, CurrentArcadeSpace, EndArcadeSpace);
        RebuildShipPath;
        NextArcadeSpace := RouteSpaces[0];
        if ArcadePauseWithShift then
        begin
          ArcadePauseWithShift := False;
          ArcadePaused := False;
          PlayButton.SetActive(not ArcadePaused);
          PauseButton.SetActive(ArcadePaused);
        end;
      end;
      if (CurrentArcadeSpace = EndArcadeSpace) and (GetPlayer <> nil) and CampaignLoadFinished and
        CampaignTransitionStarted and (CampaignLoadProgress >= 1) then
      begin
        Stage := 11;
        if UpdateTimer <> nil then
        begin
          CancelCallbackTimer(UpdateTimer);
          UpdateTimer := nil;
        end;
        Galaxy.PrimeIntegrityChecksum(614);
        RequestClose(1);
        Exit;
      end;
      if (CurrentArcadeSpace = EndArcadeSpace) and not CampaignLoadFinished and (ArcadeViewMode = 2) then BeginBattleExit;
      if (ArcadeViewMode = 5) and (GetPlayer <> nil) and not CampaignTransitionStarted then FinishCampaignTransition;
      if (GetPlayer <> nil) and CampaignTransitionStarted and not CampaignLoadStarted then
      begin
        Stage := 12;
        CampaignLoadStarted := True;
        Loads := TList.Create;
        QueueSpaceLoadingAssets(Loads, RootUiObject);
        if Loads.Count > 0 then
        begin
          CacheLoader.SetPendingLoads(Loads, True);
          if ArcadeViewMode = 5 then CacheLoader.SetPriority(3);
        end
        else
        begin
          Loads.Free;
          CampaignLoadFinished := True;
          CampaignLoadProgress := 1;
        end;
      end;
      if GetPlayer <> nil then
        if CampaignTransitionStarted then
          if CampaignLoadStarted then
            if not CampaignLoadFinished then
            begin
              CampaignLoadFinished := not CacheLoader.IsRunning;
              if CampaignLoadFinished then
                if ArcadeViewMode <> 5 then CampaignLoadProgress := 1;
            end;
    end
    else if ArcadeViewMode = 3 then
    begin
      Stage := 13;
      Step := Max(10, (SphereCameraDistance - (SphereRadius + SphereNearCameraOffset)) / 20);
      if Step > TransitionSpeed then Step := Min(Step, TransitionSpeed + 50)
      else if Step < TransitionSpeed then Step := Max(Step, TransitionSpeed - 10);
      TransitionSpeed := Step;
      SphereCameraDistance := SphereCameraDistance - Step;
      if SphereCameraDistance <= SphereRadius + SphereNearCameraOffset then
      begin
        SphereCameraDistance := SphereRadius + SphereNearCameraOffset;
        ResetBattleControls;
      end;
    end;
    if ArcadeViewMode = 1 then
    begin
      Stage := 14;
      Step := 1000;
      if Step > TransitionSpeed then Step := Min(Step, TransitionSpeed + 20)
      else if Step < TransitionSpeed then Step := Max(Step, TransitionSpeed - 5);
      TransitionSpeed := Step;
      SphereCameraDistance := SphereCameraDistance + Step;
      if SphereCameraDistance >= SphereRadius + SphereFarCameraOffset then
      begin
        SphereCameraDistance := SphereRadius + SphereFarCameraOffset;
        EnterMapView;
      end;
    end;
    if ArcadeViewMode = 5 then
    begin
      Stage := 15;
      if CampaignLoadStarted then
      begin
        if CacheLoader.TotalLoadCount <= 0 then CampaignLoadProgress := 1
        else
        begin
          CampaignLoadProgress := Min(CampaignLoadProgress + 0.004, CacheLoader.CompletedLoadCount / CacheLoader.TotalLoadCount);
          if CampaignLoadProgress > 0.99 then CampaignLoadProgress := 1;
        end;
        LoadPanel.SetProgress(CampaignLoadProgress);
      end;
    end;
    if (ArcadeViewMode = 0) and not SimulationPaused then
    begin
      Stage := 16;
      Inc(ArcadeTickCount);
      if (PlayerArcadeShip <> nil) and not ArcadeAutopilotEnabled then
      begin
        if ForwardKeyDown then PlayerArcadeShip.StartThrust
        else if ReverseKeyDown then PlayerArcadeShip.StartReverseThrust
        else PlayerArcadeShip.StopThrust;
        Stage := 17;
        if BrakeKeyDown then PlayerArcadeShip.Brake;
        Stage := 18;
        if TurnLeftKeyDown then
        begin
          PlayerArcadeShip.SetTurnInput(-100);
          SphereViewState.BearingDegrees := WrapHeadingDegrees(SphereViewState.BearingDegrees - 0.3);
        end
        else if TurnRightKeyDown then
        begin
          PlayerArcadeShip.SetTurnInput(100);
          SphereViewState.BearingDegrees := WrapHeadingDegrees(SphereViewState.BearingDegrees + 0.3);
        end
        else PlayerArcadeShip.SetTurnInput(0);
        Stage := 19;
        if PrimaryFireKeyDown then PlayerArcadeShip.FirePrimary;
        Stage := 20;
        if SecondaryFireKeyDown then PlayerArcadeShip.FireSecondary;
      end;
      Stage := 21;
      Obj := FirstArcadeObject;
      while Obj <> nil do
      begin
        Obj.UpdateState;
        Obj := Obj.Next;
      end;
      Stage := 22;
      Obj := FirstArcadeObject;
      while Obj <> nil do
      begin
        Obj.Advance;
        if Obj.DeletionPending then
        begin
          Stage := 23;
          NextObject := Obj;
          Obj := Obj.Next;
          ab_Object_Delete(NextObject);
          Stage := 231;
        end
        else Obj := Obj.Next;
      end;
      Stage := 24;
      if (GetPlayer <> nil) and (PlayerArcadeShip <> nil) and (PlayerArcadeShip.Health > 0) and
        TabShipAI(PlayerArcadeShip).InsideCurrentZone and (TabShipAI(PlayerArcadeShip).CurrentZone.Kind in [2..4]) then
      begin
        NextArcadeSpace := nil;
        if GetPlayer.Order = soJumpHole then BeginBattleExit
        else
        begin
          ArcadePaused := False;
          ArcadePauseWithShift := False;
          PlayButton.SetActive(not ArcadePaused);
          PauseButton.SetActive(ArcadePaused);
          BeginMapTransition;
        end;
      end;
    end
    else if ArcadeViewMode = 0 then
    begin
      Stage := 25;
      Step := 0.5;
      if GetAsyncKeyState(VK_CONTROL) and $8000 = $8000 then Step := Step * 10;
      if ForwardKeyDown then SphereViewState.PolarAngleDegrees := Max(0, SphereViewState.PolarAngleDegrees - Step);
      if ReverseKeyDown then SphereViewState.PolarAngleDegrees := Min(180, SphereViewState.PolarAngleDegrees + Step);
      if TurnLeftKeyDown then SphereViewState.LongitudeDegrees := WrapHeadingDegrees(SphereViewState.LongitudeDegrees - Step);
      if TurnRightKeyDown then SphereViewState.LongitudeDegrees := WrapHeadingDegrees(SphereViewState.LongitudeDegrees + Step);
    end;
    if (PlayerArcadeShip <> nil) and (ArcadeViewMode in [0, 3]) then
    begin
      Stage := 26;
      State := PlayerArcadeShip.State;
      State := AdvanceSphericalStateOnCurrentSphere(State, CameraLookAheadDistance);
      Bearing := GetSphericalBearingAndDistance(SphereViewState, State);
      if Bearing.Distance > CameraFollowStep then Bearing.Distance := CameraFollowStep;
      BearingDegrees := WrapHeadingDegrees(SphereViewState.BearingDegrees + Bearing.BearingDeltaDegrees);
      AdvanceSphericalBearingState(SphereViewState.LongitudeDegrees, SphereViewState.PolarAngleDegrees,
        BearingDegrees, SphereRadius, Bearing.Distance);
    end
    else if (ArcadeViewMode = 4) and (KellerArcadeShip <> nil) then
    begin
      Stage := 27;
      ScreenPointToSphere(Classes.Point(GameScreenWidth div 2, GameScreenHeight div 2), TargetLongitude, TargetPolarAngle);
      ScreenPointToSphere(Classes.Point(GiScalePixels(250), GiScalePixels(300)), SourceLongitude, SourcePolarAngle);
      ComputeSphericalBearingAndDistance(BearingDegrees, Distance, SourceLongitude, SourcePolarAngle, 0,
        TargetLongitude, TargetPolarAngle, SphereRadius);
      if BearingDegrees < 0 then BearingDegrees := 360 + BearingDegrees;
      State := KellerArcadeShip.State;
      State := AdvanceSphericalStateAlongBearing(State, BearingDegrees, Distance);
      Bearing := GetSphericalBearingAndDistance(SphereViewState, State);
      if Bearing.Distance > CameraFollowStep * 2 then Bearing.Distance := CameraFollowStep * 2;
      BearingDegrees := WrapHeadingDegrees(SphereViewState.BearingDegrees + Bearing.BearingDeltaDegrees);
      AdvanceSphericalBearingState(SphereViewState.LongitudeDegrees, SphereViewState.PolarAngleDegrees,
        BearingDegrees, SphereRadius, Bearing.Distance);
      SphereViewState.BearingDegrees := 0;
      if Bearing.Distance < 5 then
      begin
        Stage := 28;
        if (KellerShip = nil) or (KellerShip.ScriptShip = nil) then RaiseWideMessage('Not found script');
        Galaxy.CheckIntegrityChecksum1(622);
        if ArcadeKellerReward <> nil then
        begin
          ClearPlayerHoldEntries;
          if ArcadeKellerReward is TArtefact then GetPlayer.Artefacts.Insert(0, ArcadeKellerReward)
          else GetPlayer.Inventory.Add(ArcadeKellerReward);
          ArcadeKellerReward := nil;
        end;
        Stage := 29;
        ScriptDialogIndex := -1;
        TScriptShip(KellerShip.ScriptShip).Script.PublishShipContext(KellerShip.ScriptShip as TScriptShip);
        CurrentScript.CallDialogByVariable(TScriptShip(KellerShip.ScriptShip).State.DialogTextOrVariable);
        if ScriptDialogIndex < 0 then RaiseWideMessage('Not found dialog');
        TalkShip := KellerShip;
        TalkPlanet := nil;
        TalkScripted := True;
        SetCursorActive(False);
        Present;
        CaptureScreenBackground(True, 0);
        SetCursorActive(True);
        TalkReturnScreenId := FormToId(Self);
        RunTalk(Self);
        ArcadeViewMode := 0;
        KellerDeathPending := False;
        if Galaxy.KellerLeaveTurn <> 0 then KellerDeathPending := True;
        ArcadeEnemiesDefeated := False;
        Galaxy.PrimeIntegrityChecksum1(623);
      end;
    end;
    Stage := 30;
    CameraPos := SphericalToVector3D(HeadingDegreesToRadians(SphereViewState.LongitudeDegrees),
      HeadingDegreesToRadians(SphereViewState.PolarAngleDegrees), SphereCameraDistance);
    TargetPos := MakeVector3D(0, 0, 0);
    UpVector := SphericalToVector3D(HeadingDegreesToRadians(SphereViewState.LongitudeDegrees),
      HeadingDegreesToRadians(SphereViewState.PolarAngleDegrees + 90), SphereCameraDistance);
    View := BuildLookAtMatrix(CameraPos, TargetPos, UpVector);
    Rotation := BuildZAxisRotationMatrix(HeadingDegreesToRadians(SphereViewState.BearingDegrees));
    SphereViewMatrix := MultiplyMatrix4D(Rotation, View);
    SpherePerspectiveMatrix := BuildPerspectiveProjectionMatrix(SphereCameraDistance - SphereRadius - 100,
      SphereCameraDistance + SphereRadius + 100, HeadingDegreesToRadians(SphereFieldOfView), Cardinal(GameScreenWidth));
    SphereProjectionMatrix := MultiplyMatrix4D(SpherePerspectiveMatrix, SphereViewMatrix);
    UpdateSphereProjectionMetrics;
    if ArcadeViewMode = 2 then
    begin
      Stage := 31;
      if NextArcadeSpace <> nil then
      begin
        ArcadeMapViewPosition := TruncatePointF(PlayerMapPosition);
        HoveredArcadeSpace := nil;
      end;
      ab_Space_Update;
      ab_Space_CreateImages;
      StartStarImage.SetPosition(SubtractPoints(StartArcadeSpace.MapPosition, ArcadeMapViewPosition));
      EndStarImage.SetPosition(SubtractPoints(EndArcadeSpace.MapPosition, ArcadeMapViewPosition));
      Space := FirstArcadeSpace;
      while Space <> nil do
      begin
        if Space.Image <> nil then Space.Image.SetPosition(SubtractPoints(Space.MapPosition, ArcadeMapViewPosition));
        Space := Space.Next;
      end;
      Position := PointToPointF(SubtractPoints(TruncatePointF(PlayerMapPosition), ArcadeMapViewPosition));
      if PlayerVisual is TShip2SE then
        TShip2SE(PlayerVisual).OffsetTails(MakePointF(Position.X - PlayerVisual.Position.X, Position.Y - PlayerVisual.Position.Y));
      PlayerVisual.SetPosition(Position);
      if NextArcadeSpace = nil then UpdateShipPathImages;
    end;
    Stage := 32;
    ab_StopLine_UpdateColors;
    ab_WorldLine_Update;
    ab_WorldImage_Update;
    Stage := 33;
    Obj := FirstArcadeObject;
    while Obj <> nil do
    begin
      Obj.UpdateVisuals;
      Obj := Obj.Next;
    end;
    Stage := 34;
    ab_Object_UpdateSounds;
    Stage := 35;
    if ArcadeViewMode = 0 then UpdateWeaponHighlights(False);
    Stage := 36;
    if (ArcadeViewMode = 2) and (GetPlayer <> nil) then
    begin
      DateLabel := GetByName('Turn') as TLabelGI;
      CameraPos.X := EndArcadeSpace.MapPosition.X - StartArcadeSpace.MapPosition.X;
      CameraPos.Y := EndArcadeSpace.MapPosition.Y - StartArcadeSpace.MapPosition.Y;
      TargetPos.X := PlayerMapPosition.X - StartArcadeSpace.MapPosition.X;
      TargetPos.Y := PlayerMapPosition.Y - StartArcadeSpace.MapPosition.Y;
      DateLabel.SetText(FormatGameTurnDate(Round((CameraPos.X * TargetPos.X + CameraPos.Y * TargetPos.Y) /
        (Sqr(CameraPos.X) + Sqr(CameraPos.Y)) * (ArrivalTurn - DepartureTurn) + DepartureTurn)));
    end;
    Stage := 37;
    if not SimulationPaused then ab_Ship_RepelOverlaps;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      AppendLogLineThreadSafe('Error in procedure TfAB.TimerTakt, label = ' + IntToStr(Stage));
      if Obj <> nil then AppendLogLineThreadSafe('Obj ' + Obj.ClassName);
      raise;
    end;
  end;
end;
{ @end $544214 }

{ @routine $5463C4 TfAB_ScrollMapTimer }
procedure TfAB.ScrollMapTimer(Timer: PCallbackTimerGI; UserData: Integer);
var
  Position, PreviousPosition: TPoint;
  CursorX, CursorY: SmallInt;
begin
  if (Galaxy <> nil) and ((GetPlayer = nil) or (GetPlayer.GetHull.HullPoints <= 0)) then
  begin
    if GetPlayer <> nil then Galaxy.ScoreScreenDismissed := 1;
    while GetPlayer <> nil do SysUtils.Sleep(1);
    RequestedScreenId := screenGameEnd;
    RequestClose(1);
  end
  else if (ArcadeViewMode = 2) and (NextArcadeSpace = nil) then
  begin
    PreviousPosition := ArcadeMapViewPosition;
    Position := PreviousPosition;
    if TurnLeftKeyDown then Dec(Position.X, ScrollStep);
    if TurnRightKeyDown then Inc(Position.X, ScrollStep);
    if ForwardKeyDown then Dec(Position.Y, ScrollStep);
    if ReverseKeyDown then Inc(Position.Y, ScrollStep);
    CursorX := GetCursorPoint.X;
    CursorY := GetCursorPoint.Y;
    if CursorX < ScrollSense then Dec(Position.X, ScrollStep);
    if GameScreenWidth - ScrollSense - 1 < CursorX then Inc(Position.X, ScrollStep);
    if CursorY < ScrollSense then Dec(Position.Y, ScrollStep);
    if GameScreenHeight - ScrollSense - 1 < CursorY then Inc(Position.Y, ScrollStep);
    if (PreviousPosition.X <> Position.X) or (PreviousPosition.Y <> Position.Y) then
    begin
      ArcadeMapViewPosition := Position;
      if ArcadeMapBounds.Top - ArcadeMapPanMargin > ArcadeMapViewPosition.Y then
        ArcadeMapViewPosition.Y := ArcadeMapBounds.Top - ArcadeMapPanMargin;
      if ArcadeMapBounds.Bottom + ArcadeMapPanMargin < ArcadeMapViewPosition.Y then
        ArcadeMapViewPosition.Y := ArcadeMapBounds.Bottom + ArcadeMapPanMargin;
      if ArcadeMapBounds.Left - ArcadeMapPanMargin > ArcadeMapViewPosition.X then
        ArcadeMapViewPosition.X := ArcadeMapBounds.Left - ArcadeMapPanMargin;
      if ArcadeMapBounds.Right + ArcadeMapPanMargin < ArcadeMapViewPosition.X then
        ArcadeMapViewPosition.X := ArcadeMapBounds.Right + ArcadeMapPanMargin;
    end;
  end;
end;
{ @end $5463C4 }

{ @routine $546658 TfAB_FinishCampaignTransition }
procedure TfAB.FinishCampaignTransition;
var
  SavedStar: TStar;
begin
  if (Galaxy <> nil) and ((GetPlayer = nil) or (GetPlayer.GetHull.HullPoints <= 0)) then
  begin
    if UpdateTimer <> nil then
    begin
      CancelCallbackTimer(UpdateTimer);
      UpdateTimer := nil;
    end;
    if GetPlayer <> nil then Galaxy.ScoreScreenDismissed := 1;
    while GetPlayer <> nil do SysUtils.Sleep(1);
    RequestedScreenId := screenGameEnd;
    RequestClose(1);
  end
  else
  begin
    if RequestedScreenId <> screenStarMap then CampaignTransitionStarted := True
    else if not IsTurnCalculationRunningUI and not (TurnCalculationPhase in [tcpGalaxyRunning, tcpPlayerStarRunning]) then
    begin
      if TurnCalculationPhase = tcpGalaxyFinished then QueuePlayerStarTurnCalculation
      else if ((GetPlayer.Order <> soJump) and (GetPlayer.Order <> soJumpHole)) or
        ((GetPlayer.Order = soJumpHole) and (GetPlayer.OrderStateData = -65536)) then
      begin
        StarMapScreen.SetMapCenterManually(TruncatePointF(GetPlayer.Position));
        StarMapScreen.ResumeMode := smrTurnFilm;
        CampaignTransitionStarted := True;
        QueueGalaxyTurnCalculation;
      end
      else
      begin
        Galaxy.ClearJumpGates;
        SavedStar := PlayerStar;
        PlayerStar := GetPlayer.CurrentStar;
        PlayerStar.RebuildShipMovementPaths;
        SavedStar.RebuildShipMovementPaths;
        if (Cardinal(GetPlayer.OrderStateData) and $FFFF) = 1 then
        begin
          PruneExpiredPersistentPlayerMessages;
          RunGlobalScriptsForContext(GetPlayer.CurrentStar, 3);
        end;
        Galaxy.GenerateSpaceBackground(GetPlayer.CurrentStar.BackgroundImage);
        GetPlayer.InHyperspace := True;
        QueueGalaxyTurnCalculation;
      end;
    end;
  end;
end;
{ @end $546658 }

{ @routine $546854 TfAB_InvalidateFrame }
procedure TfAB.InvalidateFrame;
begin
  UpdateRectsEnabled := True;
  GetByName('UpdateObj').InvalidateChildren(True);
  WorldPanel.InvalidateChildren(True);
  if not (ArcadeViewMode in [2, 5]) then ab_Polygon_QueueUpdateRects;
  if ArcadeViewMode = 2 then ab_SpaceLink_Invalidate;
  CursorControl.Invalidate;
  UpdateRectsEnabled := False;
end;
{ @end $546854 }

{ @routine $5468DC TfAB_DrawShipHealthBars }
procedure TfAB.DrawShipHealthBars;
var
  Obj: TabObject;
  Ship: TabShip;
  CenterY, CenterX, Width, FilledWidth, Height: Integer;
  BottomLeft, BottomRight, TopRight, TopLeft: TPoint;
begin
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if not (Obj is TabShip) then Obj := Obj.Next
    else
    begin
      Ship := TabShip(Obj);
      Obj := Obj.Next;
      if (Ship.Visual <> nil) and Ship.Visual.IsAttachedToSpace and
         (Ship.Visual.GetDepth = ShipFrontDepth) and Ship.HealthBarVisible and
         ((Ship.BonusTicks[abkInvisibility] <= 0) or (Ship.RevealTicks > 0) or (PlayerArcadeShip = Ship)) then
      begin
        CenterX := Round(Ship.Visual.Position.X) + WorldCenterX;
        CenterY := Round(Ship.Visual.Position.Y) + WorldCenterY;
        Width := Ship.EffectOriginSpread;
        Height := 3;
        FilledWidth := Round(Ship.Health / Ship.MaxHealth * Width);
        TopLeft.Y := CenterY + Ship.EffectOriginSpread div 2;
        TopRight.Y := TopLeft.Y;
        BottomRight.Y := TopRight.Y + Height;
        BottomLeft.Y := TopLeft.Y + Height;
        if FilledWidth > 0 then
        begin
          TopLeft.X := CenterX - Width div 2;
          TopRight.X := TopLeft.X + FilledWidth;
          BottomRight.X := TopRight.X;
          BottomLeft.X := TopLeft.X;
          if HardwareRenderingEnabled then
          begin
            DrawColoredTriangle(TopLeft.X, TopLeft.Y, $FFFF0000,
              TopRight.X, TopRight.Y, $FFFF0000,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, True, @GameScreenRect);
            DrawColoredTriangle(TopRight.X, TopRight.Y, $FFFF0000,
              BottomRight.X, BottomRight.Y, $FFFFFFFF,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, True, @GameScreenRect);
          end
          else
          begin
            TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
              TopLeft.X, TopLeft.Y, $FFFF0000,
              TopRight.X, TopRight.Y, $FFFF0000,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, @GameScreenRect);
            TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
              TopRight.X, TopRight.Y, $FFFF0000,
              BottomRight.X, BottomRight.Y, $FFFFFFFF,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, @GameScreenRect);
          end;
        end;
        if FilledWidth < Width then
        begin
          TopLeft.X := CenterX - Width div 2 + FilledWidth;
          TopRight.X := TopLeft.X + Width - FilledWidth;
          BottomRight.X := TopRight.X;
          BottomLeft.X := TopLeft.X;
          if HardwareRenderingEnabled then
          begin
            DrawColoredTriangle(TopLeft.X, TopLeft.Y, $FF0000FF,
              TopRight.X, TopRight.Y, $FF0000FF,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, True, @GameScreenRect);
            DrawColoredTriangle(TopRight.X, TopRight.Y, $FF0000FF,
              BottomRight.X, BottomRight.Y, $FFFFFFFF,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, True, @GameScreenRect);
          end
          else
          begin
            TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
              TopLeft.X, TopLeft.Y, $FF0000FF,
              TopRight.X, TopRight.Y, $FF0000FF,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, @GameScreenRect);
            TriangleRasterizer16(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
              TopRight.X, TopRight.Y, $FF0000FF,
              BottomRight.X, BottomRight.Y, $FFFFFFFF,
              BottomLeft.X, BottomLeft.Y, $FFFFFFFF, @GameScreenRect);
          end;
        end;
      end;
    end;
  end;
end;
{ @end $5468DC }

{ @routine $546CC0 TfAB_ClearEnemyStatus }
procedure TfAB.ClearEnemyStatus(Index: Integer);
begin
  if EnemyIcons[Index] <> nil then
  begin
    EnemyIcons[Index].Free;
    EnemyIcons[Index] := nil;
  end;
  if EnemyHealthRings[Index] <> nil then
  begin
    EnemyHealthRings[Index].Free;
    EnemyHealthRings[Index] := nil;
  end;
  if EnemyRewardIcons[Index] <> nil then
  begin
    EnemyRewardIcons[Index].Free;
    EnemyRewardIcons[Index] := nil;
  end;
  if EnemyRewardBackdrops[Index] <> nil then
  begin
    EnemyRewardBackdrops[Index].Free;
    EnemyRewardBackdrops[Index] := nil;
  end;
end;
{ @end $546CC0 }

{ @routine $546D94 TfAB_ClearTrackedShipStatus }
procedure TfAB.ClearTrackedShipStatus(Index: Integer);
begin
  if TrackedShipIcons[Index] <> nil then
  begin
    TrackedShipIcons[Index].Free;
    TrackedShipIcons[Index] := nil;
  end;
  if TrackedShipHealthRings[Index] <> nil then
  begin
    TrackedShipHealthRings[Index].Free;
    TrackedShipHealthRings[Index] := nil;
  end;
end;
{ @end $546D94 }

{ @routine $546E08 TfAB_UpdateShipStatusIcons }
procedure TfAB.UpdateShipStatusIcons;
var
  PosX, PosY, RingWidth, RingHeight, Index, OffsetX, OffsetY, IconWidth, IconHeight: Integer;
  Ship: TabShipAI;
  Item: TItem;
  UnusedRecord: record Reserved: Integer; end; // Native unused four-byte slot before the temporary point records.
begin
  if (PlayerArcadeShip = nil) or ((GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactScaner) <= 0)) or
    (ExitCode <> 0) or (ArcadeViewMode = 5) then
  begin
    for Index := 0 to 7 do ClearEnemyStatus(Index);
    for Index := 0 to 7 do ClearTrackedShipStatus(Index);
  end
  else
  begin
    RingWidth := GiScalePixels(64);
    RingHeight := GiScalePixels(64);
    IconWidth := Round(RingWidth * 0.75);
    IconHeight := Round(RingHeight * 0.75);
    for Index := 0 to 7 do
    begin
      if Index >= PlayerArcadeShip.InitialEnemies.Count then ClearEnemyStatus(Index)
      else
      begin
        Ship := PlayerArcadeShip.InitialEnemies[Index];
        if (Ship = nil) or (Ship.Health <= 0) then ClearEnemyStatus(Index)
        else
        begin
          if EnemyIcons[Index] = nil then
          begin
            if Ship.Visual is TShip2SE then
            begin
              EnemyIcons[Index] := TRotateImage5GI.Create(MapPanel);
              (EnemyIcons[Index] as TRotateImage5GI).SetImage((Ship.Visual as TShip2SE).GetImagePath, Classes.Point(IconWidth, IconHeight), Classes.Point(IconWidth, IconHeight));
            end
            else if Ship.Visual is TRuinsSE then
            begin
              EnemyIcons[Index] := TGraphBufGI.Create(MapPanel, False);
              with EnemyIcons[Index] as TGraphBufGI do
              begin
                SourceHasPerPixelAlpha := True;
                SetSize(Classes.Point(IconWidth, IconHeight));
                LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((Ship.Visual as TRuinsSE).StaticImagePath, 1, ','), GraphBuf);
                if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                  GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
                else
                  GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
              end;
            end;
          end;
          if EnemyHealthRings[Index] = nil then
          begin
            EnemyHealthRings[Index] := TgaiGI.Create(MapPanel);
            with EnemyHealthRings[Index] do
            begin
              SetImagePath('Bm.ABItem.' + GiResourceSuffix + '_Ring');
              SetSize(Classes.Point(RingWidth, RingHeight));
              SequenceIndex := 0;
              UpdateAutoGeometry;
              SetMouseViewUpdates(True);
              MouseBlocking := True;
              StopAutoPlayback;
              SetDepth(1);
            end;
          end;
          if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) <= 0) then
            if EnemyRewardIcons[Index] <> nil then
            begin
              EnemyRewardIcons[Index].Free;
              EnemyRewardIcons[Index] := nil;
              EnemyRewardBackdrops[Index].Free;
              EnemyRewardBackdrops[Index] := nil;
            end;
          if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) and (EnemyRewardIcons[Index] = nil) then
          begin
            EnemyRewardBackdrops[Index] := TImageGI.Create(MapPanel);
            with EnemyRewardBackdrops[Index] as TImageGI do
            begin
              SetImagePath('GI,Bm.Items.' + GiResourceSuffix + 'ABArtSlot');
              SetSize(GetContentSize);
              SetOrigin(HalfPoint(ClientSize));
            end;
            EnemyRewardIcons[Index] := TImageGI.Create(MapPanel);
            with EnemyRewardIcons[Index] as TImageGI do
            begin
              Item := TabShipAI(PlayerArcadeShip.InitialEnemies[Index]).GetRewardItem(True);
              if (Item <> nil) and (not (Item is TEquipmentWithActCode) or not TEquipmentWithActCode(Item).DisplayAsArtefact) then
              begin
                Item.Free;
                Item := nil;
              end;
              if Item <> nil then
              begin
                SetImagePath('GI,' + Item.GetBitmapResourceName + 'ab');
                SetSize(GetContentSize);
                SetOrigin(HalfPoint(ClientSize));
                Item.Free;
              end
              else
              begin
                EnemyRewardIcons[Index].Free;
                EnemyRewardIcons[Index] := nil;
                EnemyRewardBackdrops[Index].Free;
                EnemyRewardBackdrops[Index] := nil;
              end;
            end;
          end;
        end;
      end;
    end;
    for Index := 0 to 7 do
    begin
      if Index >= PlayerArcadeShip.TrackedShips.Count then ClearTrackedShipStatus(Index)
      else
      begin
        Ship := PlayerArcadeShip.TrackedShips[Index];
        if (Ship = nil) or (Ship.Health <= 0) then ClearTrackedShipStatus(Index)
        else
        begin
          if TrackedShipIcons[Index] = nil then
          begin
            if Ship.Visual is TShip2SE then
            begin
              TrackedShipIcons[Index] := TRotateImage5GI.Create(MapPanel);
              (TrackedShipIcons[Index] as TRotateImage5GI).SetImage((Ship.Visual as TShip2SE).GetImagePath, Classes.Point(IconWidth, IconHeight), Classes.Point(IconWidth, IconHeight));
            end
            else if Ship.Visual is TRuinsSE then
            begin
              TrackedShipIcons[Index] := TGraphBufGI.Create(MapPanel, False);
              with TrackedShipIcons[Index] as TGraphBufGI do
              begin
                SourceHasPerPixelAlpha := True;
                SetSize(Classes.Point(IconWidth, IconHeight));
                LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((Ship.Visual as TRuinsSE).StaticImagePath, 1, ','), GraphBuf);
                if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
                  GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
                else
                  GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
              end;
            end;
          end;
          if TrackedShipHealthRings[Index] = nil then
          begin
            TrackedShipHealthRings[Index] := TgaiGI.Create(MapPanel);
            with TrackedShipHealthRings[Index] do
            begin
              SetImagePath('Bm.ABItem.' + GiResourceSuffix + '_Ring');
              SetSize(Classes.Point(RingWidth, RingHeight));
              SequenceIndex := 0;
              UpdateAutoGeometry;
              SetMouseViewUpdates(True);
              MouseBlocking := True;
              StopAutoPlayback;
              SetDepth(1);
            end;
          end;
        end;
      end;
    end;
    PosX := 5;
    PosY := 5;
    OffsetX := Round((RingWidth - IconWidth) / 2);
    OffsetY := Round((RingHeight - IconHeight) / 2);
    for Index := 0 to 7 do
    begin
      if Index < PlayerArcadeShip.InitialEnemies.Count then
      begin
        Ship := PlayerArcadeShip.InitialEnemies[Index];
        if (Ship <> nil) and (EnemyIcons[Index] <> nil) and (EnemyHealthRings[Index] <> nil) then
        begin
          if EnemyIcons[Index] is TRotateImage5GI then
            EnemyIcons[Index].SetPosition(Classes.Point(PosX + IconWidth + OffsetX, PosY + IconHeight + OffsetY))
          else if EnemyIcons[Index] is TGraphBufGI then
            EnemyIcons[Index].SetPosition(Classes.Point(PosX + OffsetX, PosY + OffsetY));
          EnemyHealthRings[Index].SetPosition(Classes.Point(PosX, PosY));
          if EnemyRewardIcons[Index] <> nil then
            EnemyHealthRings[Index].SetSequenceFrame(Round((1.04 - Ship.Health * 0.96 / Ship.MaxHealth) * EnemyHealthRings[Index].SequenceFrameCount))
          else
            EnemyHealthRings[Index].SetSequenceFrame(Round((1 - Ship.Health / Ship.MaxHealth) * EnemyHealthRings[Index].SequenceFrameCount));
          if EnemyRewardIcons[Index] <> nil then
          begin
            with EnemyRewardIcons[Index] as TImageGI do
            begin
              if GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) <= 0 then
              begin
                EnemyRewardIcons[Index].Free;
                EnemyRewardIcons[Index] := nil;
                EnemyRewardBackdrops[Index].Free;
                EnemyRewardBackdrops[Index] := nil;
              end
              else
              begin
                SetPosition(Classes.Point(PosX + GiScalePixels(31), PosY + GiScalePixels(60)));
                Item := Ship.GetRewardItem(True);
                if (Item <> nil) and (not (Item is TEquipmentWithActCode) or not TEquipmentWithActCode(Item).DisplayAsArtefact) then
                begin
                  Item.Free;
                  Item := nil;
                end;
                if Item <> nil then
                begin
                  SetImagePath('GI,' + Item.GetBitmapResourceName + 'ab');
                  SetSize(GetContentSize);
                  SetOrigin(HalfPoint(ClientSize));
                  Item.Free;
                end
                else
                begin
                  EnemyRewardIcons[Index].Free;
                  EnemyRewardIcons[Index] := nil;
                  EnemyRewardBackdrops[Index].Free;
                  EnemyRewardBackdrops[Index] := nil;
                end;
              end;
            end;
          end;
          if EnemyRewardBackdrops[Index] <> nil then
            (EnemyRewardBackdrops[Index] as TImageGI).SetPosition(Classes.Point(PosX + GiScalePixels(31), PosY + GiScalePixels(60)));
        end;
        Inc(PosX, RingWidth);
      end;
    end;
    PosX := GameScreenWidth - 5 - RingWidth;
    PosY := 5;
    OffsetX := Round((RingWidth - IconWidth) / 2);
    OffsetY := Round((RingHeight - IconHeight) / 2);
    for Index := 0 to 7 do
    begin
      if Index < PlayerArcadeShip.TrackedShips.Count then
      begin
        Ship := PlayerArcadeShip.TrackedShips[Index];
        if (Ship <> nil) and (TrackedShipIcons[Index] <> nil) and (TrackedShipHealthRings[Index] <> nil) then
        begin
          if TrackedShipIcons[Index] is TRotateImage5GI then
            TrackedShipIcons[Index].SetPosition(Classes.Point(PosX + IconWidth + OffsetX, PosY + IconHeight + OffsetY))
          else if TrackedShipIcons[Index] is TGraphBufGI then
            TrackedShipIcons[Index].SetPosition(Classes.Point(PosX + OffsetX, PosY + OffsetY));
          TrackedShipHealthRings[Index].SetPosition(Classes.Point(PosX, PosY));
          TrackedShipHealthRings[Index].SetSequenceFrame(Round((1 - Ship.Health / Ship.MaxHealth) * TrackedShipHealthRings[Index].SequenceFrameCount));
        end;
        Dec(PosX, RingWidth);
      end;
    end;
  end;
end;
{ @end $546E08 }

{ @routine $547F2C TfAB_DrawFrame }
procedure TfAB.DrawFrame;
var
  Rect: TRectGR;
  Background: TStarFieldGI;
  PreviousSkipRestore: Boolean;
begin
  if ExitCode <> 0 then Exit;
  Inc(ArcadeFrameCount);
  if (ArcadeViewMode = 0) and (CargoPickupZone <> nil) and (PlayerArcadeShip <> nil) then
  begin
    CargoPickupZone.Longitude := PlayerArcadeShip.State.LongitudeDegrees;
    CargoPickupZone.PolarAngle := PlayerArcadeShip.State.PolarAngleDegrees;
    ab_Zone_UpdatePosition(CargoPickupZone);
    ab_Zone_UpdateImages(CargoPickupZone);
  end;
  if not (ArcadeViewMode in [2, 5]) then
  begin
    ab_Polygon_SelectVisibilityCell;
    ab_Polygon_ProjectVisiblePoints;
  end;
  if ArcadeViewMode = 5 then SysUtils.Sleep(10);
  InvalidateFrame;
  Background := GetByName('StarField') as TStarFieldGI;
  PreviousSkipRestore := SkipSavedPixelRestore;
  Background.UpdateBackgroundBounds;
  SkipSavedPixelRestore := SkipSavedPixelRestore or PreviousSkipRestore;
  if SkipSavedPixelRestore or FullFrameRedrawRequested then
  begin
    UpdateRects.Clear;
    UpdateRectsEnabled := True;
    InvalidateViewport;
    UpdateRectsEnabled := False;
  end;
  FullFrameRedrawRequested := False;
  RestoreSavedPixels16;
  ErasePreviousFrame;
  Rect := UpdateRects.FirstRect;
  while Rect <> nil do
  begin
    Background.DrawBackground(Rect.Bounds);
    Rect := Rect.Next;
  end;
  PrepareFrameDraw;
  if (ArcadeViewMode = 2) or ((ArcadeViewMode = 5) and (ViewModeBeforeDefeat = 2)) then
    ab_SpaceLink_Draw
  else
  begin
    ab_Polygon_Draw;
    DrawShipHealthBars;
    UpdateShipStatusIcons;
  end;
  DrawQueuedControlRects;
  if not BeginFramePresentation then
  begin
    RequestedScreenId := screenNone;
    PostLoadScreenId := FormToId(Self);
    ArcadeKellerDefeats := 0;
    if ArcadeKellerReward <> nil then
    begin
      ArcadeKellerReward.Free;
      ArcadeKellerReward := nil;
    end;
    RequestClose(1);
  end
  else
  begin
    FinishQueuedDraw;
    CommitFrameDraw;
    ResetSecondaryPixelCount;
    EndFramePresentation;
    InvalidateFrame;
    SkipSavedPixelRestore := False;
  end;
end;
{ @end $547F2C }

{ @routine $54819C TfAB_WorldImageCycleComplete }
procedure TfAB.WorldImageCycleComplete(Sender: TObjectGI);
var
  Entry: PabWorldImage;
begin
  Entry := PabWorldImage(Sender.UserValue);
  Entry.Finished := True;
  if Entry.Image <> nil then Entry.Image.SetActive(False);
end;
{ @end $54819C }

{ @routine $5481D8 TfAB_AppendShipPathArc }
procedure TfAB.AppendShipPathArc(Destination: TPointF);
var
  Node: PSPathNode;
  Position: TPointF;
  AngleStep, Step, FromHeading, ToHeading, Difference, InitialDifference, TangentStep: Double;
begin
  if ShipPath.ActiveTail = nil then
  begin
    Position := PlayerMapPosition;
    FromHeading := ByteToHeadingDegrees(PlayerVisual.GetAngle);
  end
  else
  begin
    Position := ShipPath.ActiveTail.Position;
    FromHeading := ShipPath.ActiveTail.Heading;
  end;
  if (Position.X <> Destination.X) or (Position.Y <> Destination.Y) then
  begin
    AngleStep := ArcadePathStep;
    Step := ArcadePathArcStep;
    if PointDistanceSquared(Position, Destination) < Step then
    begin
      ShipPath.AppendNode;
      Node := ShipPath.ActiveTail;
      Node.Position := Position;
      Node.Heading := FromHeading;
    end
    else
    begin
      ToHeading := RadiansToHeadingDegrees(ArcTan2(-(Position.X - Destination.X), Position.Y - Destination.Y));
      InitialDifference := HeadingDifferenceDegrees(FromHeading, ToHeading);
      if Abs(InitialDifference) >= AngleStep then
      begin
        TangentStep := CalculateTangentArcOffset(Position, Destination, FromHeading, AngleStep);
        if TangentStep < Step then Step := TangentStep;
        while (Position.X <> Destination.X) or (Position.Y <> Destination.Y) do
        begin
          ToHeading := RadiansToHeadingDegrees(ArcTan2(-(Position.X - Destination.X), Position.Y - Destination.Y));
          Difference := HeadingDifferenceDegrees(FromHeading, ToHeading);
          if Abs(Difference) <= AngleStep then Break;
          if InitialDifference > 0 then FromHeading := WrapHeadingDegrees(FromHeading + AngleStep)
          else FromHeading := WrapHeadingDegrees(FromHeading - AngleStep);
          Position.X := Sin(HeadingDegreesToRadians(FromHeading)) * Step + Position.X;
          Position.Y := Position.Y - Cos(HeadingDegreesToRadians(FromHeading)) * Step;
          if (Position.X - Destination.X) * (Position.X - Destination.X) +
            (Position.Y - Destination.Y) * (Position.Y - Destination.Y) <= Step * Step then Position := Destination;
          ShipPath.AppendNode;
          Node := ShipPath.ActiveTail;
          Node.Position := Position;
          Node.Heading := FromHeading;
        end;
      end;
    end;
  end;
end;
{ @end $5481D8 }

{ @routine $5484D8 TfAB_AppendShipPathLine }
procedure TfAB.AppendShipPathLine(Destination: TPointF);
var
  Vertical: Boolean;
  Distance, Travelled, Slope, AxisScale, AxisOrigin, Heading: Double;
  Position, Origin: TPointF;
  Node: PSPathNode;
  Step: Double;
begin
  if ShipPath.ActiveTail = nil then Origin := PlayerMapPosition
  else Origin := ShipPath.ActiveTail.Position;
  if (Origin.X <> Destination.X) or (Origin.Y <> Destination.Y) then
  begin
    Step := ArcadePathStep;
    Heading := RadiansToHeadingDegrees(ArcTan2(-(Origin.X - Destination.X), Origin.Y - Destination.Y));
    if Abs(Origin.X - Destination.X) < Abs(Origin.Y - Destination.Y) then Vertical := True
    else Vertical := False;
    Distance := Sqrt((Origin.X - Destination.X) * (Origin.X - Destination.X) +
      (Origin.Y - Destination.Y) * (Origin.Y - Destination.Y));
    if Vertical then
    begin
      Slope := (Destination.X - Origin.X) / (Destination.Y - Origin.Y);
      AxisScale := 1 / Sqrt(Slope * Slope + 1);
      if Destination.Y - Origin.Y < 0 then AxisScale := -AxisScale;
      AxisOrigin := Origin.Y;
    end
    else
    begin
      Slope := (Destination.Y - Origin.Y) / (Destination.X - Origin.X);
      AxisScale := 1 / Sqrt(Slope * Slope + 1);
      if Destination.X - Origin.X < 0 then AxisScale := -AxisScale;
      AxisOrigin := Origin.X;
    end;
    Travelled := Step;
    if Travelled >= Distance then
    begin
      ShipPath.AppendNode;
      Node := ShipPath.ActiveTail;
      Node.Position := Destination;
      Node.Heading := Heading;
    end
    else
      while Travelled < Distance do
      begin
        if Vertical then
        begin
          Position.Y := Travelled * AxisScale + AxisOrigin;
          Position.X := (Position.Y - Origin.Y) * Slope + Origin.X;
        end
        else
        begin
          Position.X := Travelled * AxisScale + AxisOrigin;
          Position.Y := (Position.X - Origin.X) * Slope + Origin.Y;
        end;
        ShipPath.AppendNode;
        Node := ShipPath.ActiveTail;
        Node.Position := Position;
        Node.Heading := Heading;
        Travelled := Travelled + Step;
      end;
  end;
end;
{ @end $5484D8 }

{ @routine $548784 TfAB_AppendShipPath }
procedure TfAB.AppendShipPath(Destination: TPointF);
var
  Step: Single;
begin
  AppendShipPathArc(Destination);
  AppendShipPathLine(Destination);
  Step := ArcadePathStep;
  if (ShipPath.ActiveHead <> nil) and
    (Step * Step > PointDistanceSquared(ShipPath.ActiveTail.Position, Destination)) then
    ShipPath.ActiveTail.Position := Destination;
end;
{ @end $548784 }

{ @routine $548808 TfAB_BuildSpaceRoute }
procedure TfAB.BuildSpaceRoute(Route: TList; Origin, Destination: TabSpace);
var
  Space, BestSpace: TabSpace;
  Link: PabSpaceLink;
  Pending, Following, Swap: TList;
  Index: Integer;
  BestCost: Double;
begin
  Route.Clear;
  Space := FirstArcadeSpace;
  while Space <> nil do
  begin
    Space.RouteCost := -1;
    Space := Space.Next;
  end;
  Pending := TList.Create;
  Following := TList.Create;
  Pending.Add(Destination);
  Destination.RouteCost := 0;
  while Pending.Count > 0 do
  begin
    Following.Clear;
    for Index := 0 to Pending.Count - 1 do
    begin
      Space := Pending[Index];
      Link := FirstArcadeSpaceLink;
      while Link <> nil do
      begin
        if (Link.Last = Space) and ((Link.First.RouteCost < 0) or
          (Space.RouteCost + Link.First.Danger + 0.001 < Link.First.RouteCost)) then
        begin
          Link.First.RouteCost := Space.RouteCost + Link.First.Danger + 0.001;
          if Following.IndexOf(Link.First) < 0 then Following.Add(Link.First);
        end;
        Link := Link.Next;
      end;
    end;
    Swap := Pending;
    Pending := Following;
    Following := Swap;
  end;
  Following.Free;
  Pending.Free;
  Space := Origin;
  while Space <> Destination do
  begin
    BestCost := 1E20;
    BestSpace := nil;
    Link := FirstArcadeSpaceLink;
    while Link <> nil do
    begin
      if (Link.First = Space) and (Link.Last.RouteCost >= 0) and (Link.Last.RouteCost < BestCost) then
      begin
        BestSpace := Link.Last;
        BestCost := Link.Last.RouteCost;
      end;
      Link := Link.Next;
    end;
    if BestSpace = nil then Break;
    Space := BestSpace;
    Route.Add(Space);
  end;
end;
{ @end $548808 }

{ @routine $548A6C TfAB_RebuildShipPath }
procedure TfAB.RebuildShipPath;
var
  Index: Integer;
  Space: TabSpace;
begin
  ShipPath.Clear;
  for Index := 0 to RouteSpaces.Count - 1 do
  begin
    Space := RouteSpaces[Index];
    AppendShipPath(PointToPointF(Space.MapPosition));
  end;
end;
{ @end $548A6C }

{ @routine $548AD8 TfAB_BuildShipPathImages }
procedure TfAB.BuildShipPathImages;
var
  PreviousPosition: TPointF;
  Node, First, Last: PSPathNode;
  Images: TMultiImageGI;
  Item: TMultiImageUnitGI;
  Index: Integer;
  Space: TabSpace;
begin
  if ShipPath.ActiveHead <> nil then
  begin
    Images := GetByName('ShipPath') as TMultiImageGI;
    if Images.Images.Count < 1 then
    begin
      Images.AddImage('Bm.PI.Path1');
      Images.AddImage('Bm.PI.Path2');
      Images.AddImage('Bm.PI.Path3');
      Images.AddImage('Bm.PI.Path4');
    end;
    Images.ClearUnits;
    First := ShipPath.ActiveHead;
    for Index := 0 to RouteSpaces.Count - 1 do
    begin
      Space := RouteSpaces[Index];
      Last := ShipPath.FindNearestFollowingNode(First, PointToPointF(Space.MapPosition));
      if Last = nil then Last := ShipPath.ActiveTail;
      PreviousPosition := MakePointF(1E10, 1E10);
      Node := Last;
      while True do
      begin
        if PointDistanceSquared(PreviousPosition, Node.Position) > 225 then
        begin
          PreviousPosition := Node.Position;
          if ShipPath.ActiveTail <> Node then
          begin
            Item := Images.AddUnit;
            Item.UserData := Node;
            Images.SetUnitPosition(Item, SubtractPoints(TruncatePointF(PreviousPosition), ArcadeMapViewPosition));
            if Node <> Last then Item.ImageIndex := 1
            else Item.ImageIndex := 2;
          end;
        end;
        if Node = First then Break;
        Node := Node.Prev;
      end;
      First := Last.Next;
    end;
    with GetByName('ShipPathEnd') as TgaiGI do
    begin
      SetActive(True);
      SetOrigin(HalfPoint(GetContentSize));
      SetPosition(SubtractPoints(TruncatePointF(ShipPath.ActiveTail.Position), ArcadeMapViewPosition));
      RestartPlayback;
    end;
  end;
end;
{ @end $548AD8 }

{ @routine $548DDC TfAB_UpdateShipPathImages }
procedure TfAB.UpdateShipPathImages;
var
  Node: PSPathNode;
  Item: TMultiImageUnitGI;
begin
  if ShipPath.ActiveHead <> nil then
  begin
    with GetByName('ShipPath') as TMultiImageGI do
    begin
      Item := FirstUnit;
      while Item <> nil do
      begin
        Node := Item.UserData;
        SetUnitPosition(Item, SubtractPoints(TruncatePointF(Node.Position), ArcadeMapViewPosition));
        Item := Item.Next;
      end;
    end;
    with GetByName('ShipPathEnd') as TgaiGI do
    begin
      SetActive(True);
      SetOrigin(HalfPoint(GetContentSize));
      SetPosition(SubtractPoints(TruncatePointF(ShipPath.ActiveTail.Position), ArcadeMapViewPosition));
      RestartPlayback;
    end;
  end;
end;
{ @end $548DDC }

{ @routine $548F24 TfAB_ClearShipPath }
procedure TfAB.ClearShipPath;
begin
  (GetByName('ShipPath') as TMultiImageGI).ClearUnits;
  (GetByName('ShipPathEnd') as TgaiGI).SetActive(False);
end;
{ @end $548F24 }

{ @routine $548FA0 TfAB_BeginKellerDialogTransition }
procedure TfAB.BeginKellerDialogTransition;
begin
  CloseVictory(nil, 0);
  ArcadeViewMode := 4;
end;
{ @end $548FA0 }

{ @routine $548FC0 TfAB_BeginBattleExit }
procedure TfAB.BeginBattleExit;
begin
  StarMapWeaponPanelOpen := False;
  if Galaxy <> nil then
  begin
    Galaxy.CheckIntegrityChecksum1(613);
    Galaxy.CheckIntegrityChecksum2(615);
    if GetPlayer <> nil then
    begin
      GetPlayer.GetHull.HullPoints := PlayerArcadeShip.Health;
      if not (GetPlayer.Order in [soJump, soJumpHole]) then GetPlayer.InHyperspace := False;
    end;
    if ActiveArcadeRequest <> nil then
    begin
      ReportSurvivingShips;
      ActiveArcadeRequest := nil;
      ActiveArcadeRequestShips := nil;
      CompleteQueuedArcadeBattle(2);
      RequestedScreenId := TGameScreenId(ScriptArcadeReturnScreenId);
    end
    else RequestedScreenId := screenStarMap;
    ArcadeKellerDefeats := 0;
    if ArcadeKellerReward <> nil then
    begin
      ArcadeKellerReward.Free;
      ArcadeKellerReward := nil;
    end;
    Galaxy.PrimeIntegrityChecksum(633);
  end;
  ClearWeaponPanel;
  CloseVictory(nil, 0);
  ViewModeBeforeDefeat := ArcadeViewMode;
  ArcadeViewMode := 5;
  NextArcadeSpace := EndArcadeSpace;
  CurrentArcadeSpace := EndArcadeSpace;
  if CampaignLoadStarted and not CampaignLoadFinished then CacheLoader.SetPriority(3);
  LoadPanel.SetProgress(0);
  LoadPanel.SetShutterOpenFraction(0);
  LoadPanel.Show;
  CampaignLoadProgress := 0;
end;
{ @end $548FC0 }

{ @routine $54916C TfAB_ShowSpaceInfo }
procedure TfAB.ShowSpaceInfo(Space: TabSpace);
var
  Distance: Single;
  Index, InsertIndex, RowHeight, ShipCount: Integer;
  Obj: TObject;
  Text: WideString;
  Star: TStar;
  Owner: TPanelGI;
  Objects: TList;
  OwnerId: TOwnerId;
begin
  if Space = nil then HideObjectInfo
  else if InfoSpace <> Space then
  begin
    InfoSpace := Space;
    if (GetPlayer <> nil) and ((StartArcadeSpace = Space) or (EndArcadeSpace = Space)) then
    begin
      GetByName('InfoStar').SetActive(True);
      if StartArcadeSpace = Space then Star := GetPlayer.TransitOriginStar else Star := GetPlayer.CurrentStar;
      (GetByName('InfoStarName') as TLabelGI).SetText(WrapTextInColor(Star.Name, '<color=255,240,100>'));
      with GetByName('InfoStarImage') as TGraphBufGI do
      begin
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE(Star.Graphic).StaticImagePath, 1, ','), GraphBuf);
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleBilinearRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)))
        else
          GraphBuf.RescaleBilinearRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
      Owner := GetByName('InfoStarPanel') as TPanelGI;
      Owner.FreeOwnedChildren;
      Objects := TList.Create;
      for Index := 0 to Star.Planets.Count - 1 do Objects.Add(Star.Planets[Index]);
      for Index := 0 to Star.Ships.Count - 1 do
        if TObject(Star.Ships[Index]) is TRuins then
        begin
          Distance := PointDistanceSquared(TShip(Star.Ships[Index]).Position, MakePointF(0, 0));
          InsertIndex := 0;
          while InsertIndex < Objects.Count do
          begin
            if TObject(Objects[InsertIndex]) is TPlanet then
            begin
              if PointDistanceSquared(TPlanet(Objects[InsertIndex]).GetPosition, MakePointF(0, 0)) > Distance then Break;
            end
            else if PointDistanceSquared(TShip(Objects[InsertIndex]).Position, MakePointF(0, 0)) > Distance then Break;
            Inc(InsertIndex);
          end;
          Objects.Insert(InsertIndex, Star.Ships[Index]);
        end;
      RowHeight := GiScalePixels(20);
      for Index := 0 to Objects.Count - 1 do
      begin
        with TLabelGI.Create(Owner) do
        begin
          SetFontName(NormalFontName);
          SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
          SetSize(Classes.Point(Owner.ClientSize.X div 2 + 15, RowHeight));
          SetPosition(Classes.Point(0, RowHeight * Index));
          SetWordWrapEnabled(False);
          SetTextAlignX(taxRight);
          SetTextAlignY(tayCenterEx);
          if TObject(Objects[Index]) is TPlanet then SetText(TPlanet(Objects[Index]).Name)
          else SetText(TShip(Objects[Index]).Name);
        end;
        with TGraphBufGI.Create(Owner, False) do
        begin
          SourceHasPerPixelAlpha := True;
          SetPosition(Classes.Point(Owner.ClientSize.X div 2 + 15 + 5 + 1, RowHeight * Index + 1));
          SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
          if TObject(Objects[Index]) is TPlanet then
          begin
            TPlanet(Objects[Index]).Graphic.RenderToBuffer(Self, GraphBuf, True);
            GraphBuf.RescaleBilinearRgba(ClientSize.X, ClientSize.Y);
          end
          else
          begin
            if TShip(Objects[Index]).Graphic is TRuinsSE then
              LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TShip(Objects[Index]).Graphic as TRuinsSE).StaticImagePath, 1, ','), GraphBuf)
            else
              LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((TShip(Objects[Index]).Graphic as TShip2SE).AlternateImagePath, 1, ','), GraphBuf);
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
            else
              GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
          end;
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
        end;
        if TObject(Objects[Index]) is TPlanet then OwnerId := TPlanet(Objects[Index]).OwnerId
        else OwnerId := TShip(Objects[Index]).OwnerId;
        if OwnerId <> oiUninhabited then
        begin
          with TGraphBufGI.Create(Owner, False) do
          begin
            SourceHasPerPixelAlpha := True;
            if TObject(Objects[Index]) is TPlanet then
              LoadBitmapPathAsRgba(ExtractDelimitedPartW(GetFactionEmblemPath(TPlanet(Objects[Index]).GetFactionResourceName), 1, ',') + '?RGBA')
            else
              LoadBitmapPathAsRgba(ExtractDelimitedPartW(GetFactionEmblemPath(TShip(Objects[Index]).GetFactionNameKey), 1, ',') + '?RGBA');
            SetPosition(Classes.Point(Owner.ClientSize.X div 2 + 15 + 5 + RowHeight + 5 + 1, RowHeight * Index + 1));
            SetSize(Classes.Point(RowHeight - 2, RowHeight - 2));
            if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
              GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
            else
              GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
            SetImageKindX(ikxCenter);
            SetImageKindY(ikyCenter);
          end;
        end;
      end;
      Owner.SetSize(Classes.Point(Owner.ClientSize.X, Objects.Count * RowHeight));
      with GetByName('InfoStar') as TWindowGI do
      begin
        SetSize(Classes.Point(ClientSize.X, WorkSubRect.Top + WorkSubRect.Bottom + Objects.Count * RowHeight));
        UpdateAutoGeometry;
      end;
      Objects.Free;
      GetByName('InfoPanel').SetActive(False);
    end
    else
    begin
      GetByName('InfoStar').SetActive(False);
      GetByName('InfoPanel').SetActive(True);
      (GetByName('InfoName') as TLabelGI).SetText(WrapTextInColor(LocalizedColorText('FormAB.InfoName'), '<color=255,240,100>'));
      (GetByName('InfoExit') as TLabelGI).SetText(IntToStr(Space.OutgoingCount));
      Text := Space.GetDangerText;
      (GetByName('InfoDanger') as TLabelGI).SetText(Text);
      ShipCount := 0;
      for Index := 0 to Space.Objects.Count - 1 do
      begin
        Obj := Space.Objects[Index];
        if Obj is TabShipAI then Inc(ShipCount);
      end;
      if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) then Text := IntToStr(ShipCount)
      else Text := LocalizedColorText('FormAB.Unknow');
      (GetByName('InfoPirate') as TLabelGI).SetText(Text);
      with GetByName('InfoPlanetImage') as TGraphBufGI do
      begin
        SetActive(True);
        SourceHasPerPixelAlpha := True;
        if StartArcadeSpace = Space then LoadGaiFrameToGraphBuf(StartStarImage.GetImagePath, GraphBuf, 0)
        else if EndArcadeSpace = Space then LoadGaiFrameToGraphBuf(EndStarImage.GetImagePath, GraphBuf, 0)
        else LoadGaiFrameToGraphBuf(Space.Image.GetImagePath, GraphBuf, 0);
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
        else
          GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
      end;
      BattleHelpLabel.SetActive(True);
      BattleHelpLabel.SetText(LocalizedColorText('Help.ABSphere'));
    end;
  end;
end;
{ @end $54916C }

{ @routine $54A114 TfAB_HideObjectInfo }
procedure TfAB.HideObjectInfo;
begin
  if InfoSpace <> nil then
  begin
    GetByName('InfoPanel').SetActive(False);
    GetByName('InfoStar').SetActive(False);
    HideHelp;
  end;
  InfoSpace := nil;
end;
{ @end $54A114 }

{ @routine $54A198 TfAB_ShowItemInfo }
procedure TfAB.ShowItemInfo(Item: TabItem);
var
  Instance: TItem;
  Width, LeftWidth, MinimumWidth: Integer;
begin
  if (Item = nil) or (PlayerArcadeShip = nil) then
  begin
    CancelCargoPickup;
    Exit;
  end;
  if Item.BonusKind >= 0 then
  begin
    CancelCargoPickup;
    Exit;
  end;
  if CargoPickupItem = Item then Exit;
  CargoPickupItem := Item;
  { The native routine retains this branch after the earlier bonus rejection. }
  if Item.BonusKind >= 0 then
  begin
    if not IsCursorImageSelected('Take') then SetCursorByName('Take');
  end
  else
  begin
    if (GetPlayer <> nil) and (GetPlayer.CargoFreeSpace >= Item.Item.Weight) and
      (PlayerArcadeShip.DistanceTo(Item) < ManualCargoPickupDistance) and
      (GetPlayer.CargoFreeSpace >= Item.Item.Weight) and
      GetPlayer.IsEquipmentUsable(GetPlayer.GetCargoHook) and
      (GetPlayer.CalculateCargoHookPower(GetPlayer.GetCargoHook) >= Item.Item.Weight) then
    begin
      if not IsCursorImageSelected('Take') then SetCursorByName('Take');
    end
    else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
    Instance := Item.Item;
    if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    begin
      if Instance.ScriptItem <> nil then TScriptItem(Instance.ScriptItem).RunActionCode(satOnShowingItemInfo, nil, nil, nil, 0);
      if Instance is TEquipmentWithActCode then RunItemConfigActionCode(Instance, satOnShowingItemInfo, nil, nil, nil, 0);
    end;
    ItemInfoWindow.SetActive(True);
    with GetByName('InfoItemImage') as TImageGI do
    begin
      if Instance is TGoods then SetImagePath('GI,' + GetItemTypeBitmapPath(Instance.ItemType))
      else SetImagePath('GI,' + Instance.GetBitmapResourceName + 's');
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetPosition(SubtractPoints(ShipScreen.ItemImageCenter, GetVisualCenter));
    end;
    if Instance is TGoods then
    begin
      (GetByName('InfoItemName') as TLabelGI).SetText(WrapTextInColor(GoodsMarket[Ord(Instance.ItemType)].DisplayName, InfoNameColorTag));
      (GetByName('InfoItemText') as TLabelGI).SetText(LocalizedText('Items.Goods.Text.' + IntToStr(Ord(Instance.ItemType) + 1)));
    end
    else
    begin
      (GetByName('InfoItemName') as TLabelGI).SetText('');
      (GetByName('InfoItemName') as TLabelGI).SetText(WrapTextInColor(Instance.GetDisplayName, InfoNameColorTag));
      (GetByName('InfoItemText') as TLabelGI).SetText(Instance.GetInfoText('<color=255,240,100>', nil));
    end;
    (GetByName('InfoItemSize') as TLabelGI).SetText(IntToStr(Instance.Weight));
    (GetByName('InfoItemPrice') as TLabelGI).SetText(IntToStr(Instance.Cost));
    with GetByName('InfoItemEmRace') as TImageGI do
    begin
      if Instance is TGoods then SetImagePath(GetFactionEmblemPath(OwnerInfo[oiUninhabited].InternalName))
      else SetImagePath(GetFactionEmblemPath(Instance.GetOwnerConfigName));
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
    if not ((Byte(Instance.ItemType) in ([0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79])) or (Instance.ItemType = t_Hull)) then
    begin
      with GetByName('InfoDurable') as TImageGI do Parent.Parent.SetActive(False);
      MinimumWidth := 0;
    end
    else
    begin
      if Instance is THull then Width := Round(Sqrt(Instance.Weight / HullBaseSize / Max(0.1, (Instance as THull).GetFragilityFactor([]))) * 64)
      else Width := Round(64 / Max(0.1, (Instance as TEquipment).GetFragilityFactor([])));
      Width := Min(192, Max(32, Width));
      with GetByName('InfoDurableLeft') as TImageGI do
      begin
        LeftWidth := GetContentSize.X;
        MinimumWidth := LeftWidth * 2 + Width + LocalPosition.X + Parent.LocalPosition.X + Parent.Parent.LocalPosition.X * 2;
      end;
      with GetByName('InfoDurable') as TImageGI do
      begin
        Parent.Parent.SetActive(True);
        Parent.Parent.SetSize(Classes.Point(LeftWidth * 2 + Width, Parent.Parent.ClientSize.Y));
        Parent.SetSize(Classes.Point(Width + 2, Parent.Parent.ClientSize.Y));
        if Instance.ItemType = t_Hull then
          SetPosition(Classes.Point(Round((Instance as THull).HullPoints / (Instance as THull).Weight * Width) - (GetContentSize.X - 5), LocalPosition.Y))
        else
          SetPosition(Classes.Point(Round((Instance as TEquipment).ConditionPercent / 100 * Width) - (GetContentSize.X - 5), LocalPosition.Y));
      end;
      with GetByName('InfoDurableRight') as TImageGI do
      begin
        SetPosition(Classes.Point(Width + LeftWidth - GetContentSize.X, LocalPosition.Y));
        Parent.SetPosition(Classes.Point(LeftWidth, Parent.LocalPosition.Y));
        Parent.SetSize(Classes.Point(Width + LeftWidth, Parent.ClientSize.Y));
      end;
      with GetByName('InfoDurableBack') as TImageGI do
      begin
        SetPosition(Classes.Point(Width + 1 - GetContentSize.X, LocalPosition.Y));
        Parent.SetSize(Classes.Point(Width + LeftWidth, Parent.ClientSize.Y));
      end;
    end;
    ShipScreen.LayoutItemInfo(ItemInfoWindow, GetByName('InfoItemName') as TLabelGI, GetByName('InfoItemText') as TLabelGI, True, True, MinimumWidth);
    GetByName('InfoItemSize').SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
    GetByName('InfoItemPrice').SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
    GetByName('InfoItemEmRace').SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X, ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
  end;
  if CargoPickupZone = nil then
  begin
    CargoPickupZone := ab_Zone_Add;
    CargoPickupZone.Kind := 20;
    CargoPickupZone.Radius := ManualCargoPickupDistance;
    CargoPickupZone.RadiusDegrees := CargoPickupZone.Radius * 180 / (Pi * SphereRadius);
  end;
  CargoPickupZone.Longitude := PlayerArcadeShip.State.LongitudeDegrees;
  CargoPickupZone.PolarAngle := PlayerArcadeShip.State.PolarAngleDegrees;
  ab_Zone_UpdatePosition(CargoPickupZone);
  ab_Zone_UpdateImages(CargoPickupZone);
end;
{ @end $54A198 }

{ @routine $54B024 TfAB_CancelCargoPickup }
procedure TfAB.CancelCargoPickup;
begin
  if CargoPickupItem <> nil then
  begin
    if not IsCursorImageSelected('Main') then SetCursorByName('Main');
    ItemInfoWindow.SetActive(False);
    CargoPickupItem := nil;
    if CargoPickupZone <> nil then
    begin
      ab_Zone_Delete(CargoPickupZone);
      CargoPickupZone := nil;
    end;
  end;
end;
{ @end $54B024 }

{ @routine $54B0A8 TfAB_OpenShipEquipment }
procedure TfAB.OpenShipEquipment(Sender: TObjectGI);
begin
  if (ArcadeViewMode <> 5) and (GetPlayer <> nil) and (PlayerArcadeShip <> nil) and (PlayerArcadeShip.Health > 0) then
  begin
    Galaxy.CheckIntegrityChecksum1(601);
    Galaxy.CheckIntegrityChecksum2(602);
    ForwardKeyDown := False;
    ReverseKeyDown := False;
    BrakeKeyDown := False;
    TurnLeftKeyDown := False;
    TurnRightKeyDown := False;
    PrimaryFireKeyDown := False;
    SecondaryFireKeyDown := False;
    GetPlayer.GetHull.HullPoints := PlayerArcadeShip.Health;
    SetCursorActive(False);
    Present;
    CaptureScreenBackground(True, 0);
    SetCursorActive(True);
    RunShipEquipment(Self);
    SyncWeaponInventory;
    Galaxy.PrimeIntegrityChecksum1(603);
    Galaxy.PrimeIntegrityChecksum2(604);
    UpdateWeaponPanel;
    Present;
  end;
end;
{ @end $54B0A8 }

{ @routine $54B290 TfAB_SyncWeaponInventory }
procedure TfAB.SyncWeaponInventory;
var
  SavedWeapons: array[0..4] of TWeapon;
  SavedAmmo: array[0..4] of Integer;
  SlotIndex, SlotCount: Integer;
  Item: TWeapon;

  // @nested $54B1E0 SaveWeaponInventory
  procedure SaveWeaponInventory; // @addr $54B1E0 @calls "0x54B2A8"
  var
    Index: Integer;
  begin
    for Index := 0 to 4 do
    begin
      SavedWeapons[Index] := CampaignWeapons[Index];
      if SavedWeapons[Index] <> nil then SavedAmmo[Index] := PlayerArcadeShip.Weapons[Index].Ammo
      else SavedAmmo[Index] := 0;
    end;
  end;

  // @nested $54B24C FindSavedWeaponAmmo
  function FindSavedWeaponAmmo(Weapon: TWeapon): Integer; // @addr $54B24C @calls "0x54B3D0"
  var
    Index: Integer;
  begin
    Result := 0;
    for Index := 0 to 4 do
      if SavedWeapons[Index] = Weapon then
      begin
        Result := SavedAmmo[Index];
        Break;
      end;
  end;

begin
  if PlayerArcadeShip <> nil then
  begin
    SaveWeaponInventory;
    PlayerArcadeShip.WeaponCount := 0;
    SlotCount := GetPlayer.GetSlotCount(sskWeapon);
    for SlotIndex := 0 to SlotCount - 1 do
    begin
      Item := GetPlayer.FindEquippedItemInSlot(t_Weapon1, SlotIndex) as TWeapon;
      if GetPlayer.IsEquipmentUsable(Item) then
      begin
        if (CampaignWeapons[PlayerArcadeShip.WeaponCount] <> Item) or
          (PlayerArcadeShip.Weapons[PlayerArcadeShip.WeaponCount].SlotData <> Item.AssignedSlotData) then
        begin
          ab_Weapon_InitializeFromInfo(@PlayerArcadeShip.Weapons[PlayerArcadeShip.WeaponCount], Item.GetWeaponInfo);
          CampaignWeapons[PlayerArcadeShip.WeaponCount] := Item;
          with PlayerArcadeShip.Weapons[PlayerArcadeShip.WeaponCount] do
          begin
            Ammo := FindSavedWeaponAmmo(Item);
            if Ammo > MaxAmmo then Ammo := 0;
            SlotData := Item.AssignedSlotData;
          end;
        end;
        Inc(PlayerArcadeShip.WeaponCount);
      end;
    end;
    for SlotIndex := PlayerArcadeShip.WeaponCount to 4 do CampaignWeapons[SlotIndex] := nil;
    NormalizeWeaponSelection;
  end;
end;
{ @end $54B290 }

{ @routine $54B450 TfAB_PickUpItem }
procedure TfAB.PickUpItem(Item: TabItem);
var
  Instance: TItem;
  Other: TObject;
  Index, Count: Integer;
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum1(616);
  Instance := Item.Item;
  Instance.GetGraphObject.DetachFromSpace;
  Instance.ReleaseGraphObject;
  Item.Item := nil;
  ab_Object_Delete(Item);
  if Instance is TArtefact then
  begin
    (Instance as TEquipment).EquippedFlag := 0;
    GetPlayer.Artefacts.Add(Instance);
    if Instance is TArtefactTranclucator then
      (TObject((Instance as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := GetPlayer;
  end
  else if Instance is TCountableItem then
  begin
    TCountableItem(Instance).DropFlag := 0;
    (Instance as TEquipment).EquippedFlag := 0;
    Index := 0;
    Other := nil;
    Count := GetPlayer.Inventory.Count;
    while Index < Count do
    begin
      Other := GetPlayer.Inventory[Index];
      if (Instance as TCountableItem).CanMerge(Other) then Break;
      Inc(Index);
    end;
    if (Index < Count) and (Other <> nil) then
    begin
      (Other as TCountableItem).Merge(Instance);
      Instance.Free;
    end
    else GetPlayer.Inventory.Add(Instance);
  end
  else if Instance is TEquipment then
  begin
    (Instance as TEquipment).EquippedFlag := 0;
    GetPlayer.Inventory.Add(Instance);
  end
  else if Instance is TGoods then
  begin
    Inc(GetPlayer.CargoGoods[Ord((Instance as TGoods).ItemType)].Count, (Instance as TGoods).Quantity);
    Inc(GetPlayer.CargoGoods[Ord((Instance as TGoods).ItemType)].TotalCost, (Instance as TGoods).Cost);
    Instance.Free;
  end;
  GetPlayer.RefreshDerivedStats(True);
  if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum1(616);
end;
{ @end $54B450 }

{ @routine $54B6E8 TfAB_RandomRange }
function TfAB.RandomRange(BoundA, BoundB: Integer): Integer;
begin
  RandomSeed := RandomSeed div 7981 + (RandomSeed * 7981 + 567);
  if BoundA < BoundB then Result := RandomSeed mod Cardinal(BoundB - BoundA + 1) + BoundA
  else Result := RandomSeed mod Cardinal(BoundA - BoundB + 1) + BoundB;
end;
{ @end $54B6E8 }

{ @routine $54B774 TfAB_RandomFloat }
function TfAB.RandomFloat(BoundA, BoundB: Double): Double;
begin
  RandomSeed := RandomSeed div 7931 + (RandomSeed * 7981 + 567);
  Result := SeededRandomIntRange(Trunc(BoundA * 1000 + 1), Trunc(BoundB * 1000 + 1), RandomSeed) / 1000;
end;
{ @end $54B774 }

{ @routine $54B808 TfAB_UpdateHelp }
procedure TfAB.UpdateHelp(Sender: TObjectGI; Show: Boolean);
begin
  BattleHelpLabel.SetActive(Show);
  if Show then BattleHelpLabel.SetText(Sender.HelpText);
end;
{ @end $54B808 }

{ @routine $54B848 TfAB_ControlMouseEnter }
procedure TfAB.ControlMouseEnter(Sender: TObjectGI);
begin
  UpdateHelp(Sender, True);
end;
{ @end $54B848 }

{ @routine $54B868 TfAB_ControlMouseLeave }
procedure TfAB.ControlMouseLeave(Sender: TObjectGI);
begin
  HideHelp;
end;
{ @end $54B868 }

{ @routine $54B880 TfAB_HideHelp }
procedure TfAB.HideHelp;
begin
  BattleHelpLabel.SetActive(False);
end;
{ @end $54B880 }

{ @routine $54B89C TfAB_ShowVictory }
procedure TfAB.ShowVictory;
var
  ItemsPanel: TPanelGI;
  Panel: TObjectGI;
  Index: Integer;
  Heading, ItemLabel, Footer: TLabelGI;
begin
  GetByName('WinItem').FreeOwnedChildren;
  ItemsPanel := GetByName('WinItem') as TPanelGI;
  ItemsPanel.FreeOwnedChildren;
  Index := 0;
  if ListedObjects.Count <= 0 then
    ItemsPanel.SetSize(Classes.Point(ItemsPanel.ClientSize.X, 0))
  else
  begin
    ItemsPanel.SetSize(Classes.Point(ItemsPanel.ClientSize.X, (ListedObjects.Count + 1) * GiScalePixels(20) + 5));
    Heading := TLabelGI.Create(ItemsPanel);
    Heading.SetFontName(NormalFontName);
    Heading.SetPosition(Classes.Point(0, 0 * GiScalePixels(20)));
    Heading.SetSize(Classes.Point(ItemsPanel.ClientSize.X, GiScalePixels(20)));
    Heading.SetTextAlignX(taxCenter);
    Heading.SetTextAlignY(tayCenterEx);
    Heading.SetText(LocalizedColorText('FormAB.WinItems'));
    Heading.SetTextColor(CurrentPixelFormat.PackRgbBytes(219, 218, 156));
    while ListedObjects.Count > Index do
    begin
      ItemLabel := TLabelGI.Create(ItemsPanel);
      ItemLabel.SetFontName(NormalFontName);
      ItemLabel.SetPosition(Classes.Point(0, (Index + 1) * GiScalePixels(20) + 5));
      ItemLabel.SetSize(Classes.Point(ItemsPanel.ClientSize.X, GiScalePixels(20)));
      ItemLabel.SetTextAlignX(taxCenter);
      ItemLabel.SetTextAlignY(tayCenterEx);
      ItemLabel.SetText(TEquipment(ListedObjects[Index]).GetDisplayName);
      ItemLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
      Inc(Index);
    end;
  end;
  Footer := TLabelGI.Create(ItemsPanel);
  Footer.SetFontName(NormalFontName);
  Footer.SetPosition(Classes.Point(0, (Index + 1) * GiScalePixels(30)));
  Footer.SetSize(Classes.Point(ItemsPanel.ClientSize.X, 1));
  Footer.SetTextAlignX(taxCenter);
  Footer.SetTextAlignY(tayAuto);
  Footer.SetText(LocalizedColorText('FormAB.TextExit'));
  Footer.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 255, 255));
  ItemsPanel.SetSize(Classes.Point(ItemsPanel.ClientSize.X, GiScalePixels(30) + ItemsPanel.ClientSize.Y + Footer.ClientSize.Y));
  Panel := VictoryPanel;
  Panel.SetSize(Classes.Point(Panel.ClientSize.X, ItemsPanel.LocalPosition.Y + ItemsPanel.ClientSize.Y + GiScalePixels(20)));
  Panel.SetActive(True);
  Panel := GetByName('WinShr');
  Panel.SetSize(Classes.Point(Panel.ClientSize.X, ItemsPanel.LocalPosition.Y + ItemsPanel.ClientSize.Y + GiScalePixels(20)));
  GetByName('PanelWinHide').SetActive(True);
  if (GetPlayer <> nil) and (PlayerArcadeShip <> nil) and not PlayerArcadeShip.HasFiredWeapon then
  begin
    Galaxy.CheckIntegrityChecksum1(630);
    GetPlayer.AchievementStats.CheckNoShotsArcadeVictoryAchievement;
    Galaxy.PrimeIntegrityChecksum1(631);
  end;
end;
{ @end $54B89C }

{ @routine $54BD88 TfAB_CloseVictory }
procedure TfAB.CloseVictory(Sender: TObjectGI; VirtualKey: Cardinal);
begin
  VictoryPanel.SetActive(False);
  GetByName('WinItem').FreeOwnedChildren;
  DefeatPanel.SetActive(False);
  if VictoryTimer <> nil then
  begin
    CancelCallbackTimer(VictoryTimer);
    VictoryTimer := nil;
  end;
end;
{ @end $54BD88 }

{ @routine $54BE0C TfAB_SelectMusic }
procedure TfAB.SelectMusic;
begin
  // Native arcade playback follows the hyper-space music setting.
  if MusicInHyperEnabled then MusicManager.PlayCategory('ArcadeBattle')
  else MusicManager.RequestFadeOut;
end;
{ @end $54BE0C }

end.
