unit fHangar;
// Unit bracket (inferred): .text 0x00669BE4..0x006709E4; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Types, EC_BlockPar, GI_GraphBuf, GI_MessageLoop, GI_Window, GR_GraphBuf, aShip, fPanelLoad, fPanelMain, fPanelPlanet, fPanelRuins;

type
  THangarShipSlot = record // @size 0x14
    AnimationState: Integer; // @offset 0x00
    ShipId: Integer; // @offset 0x04
    ImageBuffer: TGraphBufGR; // @offset 0x08
    Opacity: Integer; // @offset 0x0C
    ImageControl: TGraphBufGI; // @offset 0x10
  end;

  TfHangar = class(TMessageLoopGIWithMainPanel) // @size 0x1B0
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    StationPanel: TfPanelRuins; // @offset 0xD8
    LoadPanel: TfPanelLoad; // @offset 0xDC
    ShipInfoWindow: TWindowGI; // @offset 0xE0
    ShipSlots: array[0..8] of THangarShipSlot; // @offset 0xF8
    HoveredShip: TShip; // @offset $E4 Borrowed ship currently described by ShipInfoWindow.
    ShipInfoHideTimer: PCallbackTimerGI; // @offset $E8
    TakeOffPending: Boolean; // @offset $EC
    AmbientAnimationTimer: PCallbackTimerGI; // @offset $F0
    DockedShipsTimer: PCallbackTimerGI; // @offset $F4
    SelectedShip: TShip; // @offset 0x1AC Borrowed inspected ship; forwarded to ShipScreen.ShipToInspect and used by CheatSkill.

    constructor Create; // @addr 0x669C7C
    destructor Destroy; override; // @addr 0x669D34
    procedure OnOpen; override; // @addr 0x66A89C
    procedure OnClose; override; // @addr 0x66B440
    procedure SelectMusic; override; // @addr 0x66C27C
    procedure InitializeLayout; override; // @addr 0x669E1C
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x670960

    procedure RepairHullClicked(Sender: TObjectGI); // @addr 0x66C970 @note "Insufficient funds buy a proportional partial repair."
    procedure RefuelClicked(Sender: TObjectGI); // @addr 0x66CD1C @note "Requires enough money to fill the tank completely."
    procedure TakeOffClicked(Sender: TObjectGI); // @addr 0x66CFD4
    function TryTakeOff: Boolean; // @addr $66BAB0 @note "Orders player takeoff and runs campaign turn/transitions when accepted. Self is unused."
    procedure ShipClicked(Sender: TObjectGI); // @addr 0x66BEAC
    function RefreshTakeOffStatus: Boolean; // @addr $66D1F0 Refreshes hull, fuel and engine warnings and reports whether takeoff is allowed.
    procedure RefreshServiceButtons; // @addr 0x66C5BC
    procedure MainMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $66EBF8
    procedure MainRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $66EDA8
    procedure EndTurnClicked(Sender: TObjectGI); // @addr $66BC2C
    procedure BeginTakeOff; // @addr $66BFF4
    procedure MainKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $66C054
    function IsServiceButtonDown: Boolean; // @addr $66C4F4
    procedure StopAnimation(Sender: TObjectGI); // @addr $66D1BC
    procedure AmbientAnimationComplete(Sender: TObjectGI); // @addr $66DD54
    procedure StartAmbientAnimation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $66DE64
    procedure ShowShipInfo(Ship: TShip); // @addr $66EFF0
    procedure HideShipInfo(Timer: PCallbackTimerGI; UserData: Integer); // @addr $66EF98
    procedure CaptureDispatcherMirror(Sender: TObjectGI); // @addr $66B63C
    procedure DispatcherAnimationComplete(Sender: TObjectGI); // @addr $66B7AC
    function GetShipPortraitScale(Ship: TShip): Single; // @addr $66DF3C
    procedure LoadDockedShipImage(Index: Integer; ImagePath: WideString; LargeHull: Boolean; Scale: Single); // @addr $66DFDC
    procedure SetDockedShipOpacity(Index: Integer; Alpha: Byte); // @addr $66E234
    procedure AnimateDockedShips(Timer: PCallbackTimerGI; UserData: Integer); // @addr $66E3C8
    procedure RefreshDockedShips; // @addr 0x66E58C
  end;

const
  HangarDominatorPortraitScales: array[TDominatorSeries, TKlingType] of Single = (
    (1.0,1.1,1.1,0.7,0.7,0.3,1.0,0.5),
    (1.0,1.2,0.9,0.9,0.8,0.7,1.0,0.5),
    (1.0,1.1,0.9,0.7,0.6,0.5,1.0,0.5)); // @addr $87BECC

implementation

uses Windows, Math, aRanger, aPirate, SE_Ship2, SE_Ruins, SE_Star, aTranclucator, fShip2, fStarMap, fRuinsTalk, aRuins, GI_GI, aKling, EC_Str, GI_Image, aConst, aPlanet, EC_Data, GI_Label, aItem, aSaveLoad, aScript, GI_Main, GI_MessageBox, EC_Cache, GR_DX, GR_Music, fGalaxy2, fSaveManager, GR_Main, Classes, SysUtils, Globals, GlobalsV, GI_GAI, GI_GraphButton, GR_Sound, aGalaxy, aGalaxyStruct, aPlayer, aMyFunction, EC_Struct, ThreadCalc, aCalc;

{ @routine $669C7C TfHangar_Create }
constructor TfHangar.Create;
var I: Integer;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
  for I := 0 to 8 do ShipSlots[I].ImageBuffer := TGraphBufGR.Create(False);
  SelectedShip := nil;
end;
{ @end $669C7C }

{ @routine $669D34 TfHangar_Destroy }
destructor TfHangar.Destroy;
var I: Integer;
begin
  if StationPanel <> nil then
  begin
    StationPanel.Free;
    StationPanel := nil;
  end;
  if PlanetPanel <> nil then
  begin
    PlanetPanel.Free;
    PlanetPanel := nil;
  end;
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  for I := 0 to 8 do
    if ShipSlots[I].ImageBuffer <> nil then
    begin
      ShipSlots[I].ImageBuffer.Free;
      ShipSlots[I].ImageBuffer := nil;
    end;
  inherited Destroy;
end;
{ @end $669D34 }

{ @routine $669E1C TfHangar_InitializeLayout }
procedure TfHangar.InitializeLayout;
var I: Integer;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  PlanetPanel.InitializeLayout(Self);
  StationPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fHangar... ');
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('AnimOpen') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('AnimRnd') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('AnimRepair') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('AnimFuel') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship0') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship1') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship2') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship3') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship4') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship5') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship6') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship7') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ship8') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    FindByNameRecursive('BGCity2').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGCity').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('OpenImage') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PanelUp') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PanelDown') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  ShipInfoWindow := GetByName('InfoShip') as TWindowGI;
  for I := 0 to 8 do ShipSlots[I].ImageControl := GetByName('Ship' + IntToStr(I)) as TGraphBufGI;
  GetByName('MainPanel').MouseMoveCallback := MainMouseMove;
  GetByName('MainPanel').RightButtonDownCallback := MainRightButtonDown;
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  (GetByName('ButRepair') as TGraphButtonGI).UpCallback := RepairHullClicked;
  (GetByName('ButRefuel') as TGraphButtonGI).UpCallback := RefuelClicked;
  (GetByName('ButTakeOff') as TGraphButtonGI).UpCallback := TakeOffClicked;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := PlanetPanel.PlanetClicked;
end;
{ @end $669E1C }

{ @routine $66A89C TfHangar_OnOpen }
procedure TfHangar.OnOpen;
var
  I: Integer;
  Path: WideString;
begin
  HoveredShip := nil;
  LoadPanel.OnOpen;
  if AmbientAnimationTimer <> nil then
  begin
    CancelCallbackTimer(AmbientAnimationTimer);
    AmbientAnimationTimer := nil;
  end;
  if DockedShipsTimer <> nil then
  begin
    CancelCallbackTimer(DockedShipsTimer);
    DockedShipsTimer := nil;
  end;
  DockedShipsTimer := ScheduleCallbackTimer(20,20,AnimateDockedShips);
  GetByName('AnimRepair').SetActive(False);
  GetByName('AnimFuel').SetActive(False);
  SelectMusic;
  MainPanel.OnOpen;
  MainPanel.NavigationLocked := False;
  MainPanel.Show;
  if GetPlayer.IsOnPlanet then
  begin
    PlanetPanel.OnOpen;
    PlanetPanel.Show;
    StationPanel.Hide;
  end
  else
  begin
    PlanetPanel.Hide;
    StationPanel.OnOpen;
    StationPanel.Show;
  end;
  TakeOffPending := False;
  with GetByName('ButClose') as TGraphButtonGI do
    if GetPlayer.IsOnPlanet then UpCallback := PlanetPanel.PlanetClicked
    else if GetPlayer.IsDockedToShip then UpCallback := StationPanel.ServicesClicked;
  GetByName('MainPanel').KeyDownCallback := MainKeyDown;
  with GetByName('BGCity2') as TImageGI do
  begin
    SetActive(GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = rstMilitaryBase));
    if Active then
    begin
      SetImagePath('GAI,' + GetPlayer.CurrentStar.GetBackgroundImagePath(I));
      GaiImageControl.LoadFrameSequenceFromText(SingleFrameAnimationSpec);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
    end;
  end;
  with GetByName('BGCity') as TImageGI do
    if GetPlayer.IsOnPlanet then
    begin
      SetActive(True);
      (FindByNameRecursive('BGCity') as TImageGI).SetImagePath(GetPlayer.CurrentPlanet.GetGovernmentBackgroundGraph);
    end
    else if GetPlayer.IsDockedToShip then
    begin
      SetActive(True);
      if GetPlayer.DockedTo.TypeNameOverrideKey <> WideString('') then
      begin
        Path := 'Bm.FormRuins.' + GiResourceSuffix + GetPlayer.DockedTo.TypeNameOverrideKey + 'bg';
        if CacheDataRoot.FileExistsByPath(Path) then SetImagePath('GI,' + Path)
        else SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[GetPlayer.DockedTo.TypeId].Name + 'bg');
      end
      else SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[GetPlayer.DockedTo.TypeId].Name + 'bg');
    end
    else SetActive(False);
  if AnimHangar then
  begin
    with GetByName('AnimOpen') as TgaiGI do
    begin
      SetActive(True);
      SetSequenceFrame(0);
      RestartPlayback;
      CycleCompleteCallback := AmbientAnimationComplete;
    end;
    with GetByName('AnimRnd') as TgaiGI do
    begin
      SetActive(False);
      StopAutoPlayback;
      CycleCompleteCallback := AmbientAnimationComplete;
    end;
    DrawQueuedUpdateRects;
    SoundManager.PlaySound('Sound.HangarOpen');
    GetByName('OpenImage').SetActive(False);
  end
  else
  begin
    GetByName('AnimOpen').SetActive(False);
    GetByName('AnimRnd').SetActive(False);
    GetByName('OpenImage').SetActive(True);
  end;
  GetByName('PanelUp').SetActive(True);
  GetByName('PanelDown').SetActive(True);
  with GetByName('FaceI') as TImageGI do
  begin
    SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + 'Dispatcheri');
    SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
  end;
  with GetByName('FaceA') as TgaiGI do
  begin
    UserValue := 0;
    FirstFrameOnly := not AnimCaptain;
    SetImagePath('Bm.Captain.' + GiResourceSuffix + 'Dispatchera');
    SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetSequenceFrame(RandomIntRange(0, SequenceFrameCount - 1));
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
    CycleCompleteCallback := Self.DispatcherAnimationComplete;
    RestartPlayback;
  end;
  with GetByName('FaceA') as TgaiGI do FrameAdvancedCallback := CaptureDispatcherMirror;
  GetByName('FaceGB').SetActive(False);
  with GetByName('CaptainI') as TImageGI do
  begin
    SetImagePath('GI,' + GetPlayer.GetCaptainPortraitResourceBase + 'i');
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
  end;
  with GetByName('CaptainA') as TgaiGI do
  begin
    FirstFrameOnly := not AnimCaptain;
    SetImagePath(GetPlayer.GetCaptainPortraitResourceBase + 'a');
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
    RestartPlayback;
  end;
  CaptureDispatcherMirror(nil);
  for I := 0 to 8 do
  begin
    ShipSlots[I].AnimationState := 0;
    ShipSlots[I].Opacity := 0;
    GetByName('Ship' + IntToStr(I)).SetActive(False);
  end;
  RefreshDockedShips;
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm,nil,nil,0);
  Galaxy.PrimeIntegrityChecksum(210);
  RefreshServiceButtons;
  MainPanel.RebuildMessageButtons(False);
end;
{ @end $66A89C }

{ @routine $66B440 TfHangar_OnClose }
procedure TfHangar.OnClose;
var I: Integer;
begin
  Galaxy.CheckIntegrityChecksum(211);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm,nil,nil,0);
  ShipInfoWindow.SetActive(False);
  HoveredShip := nil;
  if ShipInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ShipInfoHideTimer);
    ShipInfoHideTimer := nil;
  end;
  LoadPanel.OnClose;
  for I := 0 to 8 do
  begin
    (GetByName('Ship' + IntToStr(I)) as TGraphBufGI).GraphBuf.Clear;
    if ShipSlots[I].ImageBuffer <> nil then ShipSlots[I].ImageBuffer.Clear;
  end;
  if AmbientAnimationTimer <> nil then
  begin
    CancelCallbackTimer(AmbientAnimationTimer);
    AmbientAnimationTimer := nil;
  end;
  if DockedShipsTimer <> nil then
  begin
    CancelCallbackTimer(DockedShipsTimer);
    DockedShipsTimer := nil;
  end;
  if RequestedScreenId <> screenScanner then SoundManager.StopUncontrolledSounds;
  MainPanel.OnClose;
  if (GetPlayer <> nil) and GetPlayer.IsOnPlanet then PlanetPanel.OnClose else StationPanel.OnClose;
end;
{ @end $66B440 }

{ @routine $66B63C TfHangar_CaptureDispatcherMirror }
procedure TfHangar.CaptureDispatcherMirror(Sender: TObjectGI);
var
  Position: TPoint;
  WasActive: Boolean;
begin
  if HardwareRenderingEnabled then Exit;
  WasActive := ShipInfoWindow.Active;
  ShipInfoWindow.SetActive(False);
  with GetByName('FaceGB') as TGraphBufGI do
  begin
    SetActive(False);
    if not ShowSystemMouse then SetCursorActive(False);
    DrawQueuedUpdateRects;
    if not ShowSystemMouse then SetCursorActive(True);
    Position := ToAbsolutePoint(Classes.Point(0,0));
    GraphBuf.AllocateNative(ClientSize.X,ClientSize.Y);
    Ex_OKGR_Copy_XY_XY_WORD(GraphBuf.GetPixels,GraphBuf.PitchBytes,0,0,
      Pointer(Cardinal(ScreenRenderBuffer.GetPixels) + Cardinal(Position.X * 2) + Cardinal(Position.Y * ScreenRenderBuffer.PitchBytes)),
      ScreenRenderBuffer.PitchBytes,0,0,ClientSize.X,ClientSize.Y);
    GraphBuf.FlipHorizontal16;
    SetActive(True);
  end;
  ShipInfoWindow.SetActive(WasActive);
end;
{ @end $66B63C }

{ @routine $66B7AC TfHangar_DispatcherAnimationComplete }
procedure TfHangar.DispatcherAnimationComplete(Sender: TObjectGI);
var Alternate: Integer;
begin
  Alternate := 0;
  if Sender.UserValue <> 0 then Alternate := 0
  else if RandomIntRange(0,2) = 0 then Alternate := 1;
  with GetByName('FaceI') as TImageGI do
  begin
    if Alternate = 0 then SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + 'Dispatcheri')
    else SetImagePath('GI,Bm.Captain.' + GiResourceSuffix + 'Dispatcher2i');
    SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
  end;
  with GetByName('FaceA') as TgaiGI do
  begin
    UserValue := Alternate;
    FirstFrameOnly := not AnimCaptain;
    if Alternate = 0 then SetImagePath('Bm.Captain.' + GiResourceSuffix + 'Dispatchera')
    else SetImagePath('Bm.Captain.' + GiResourceSuffix + 'Dispatcher2a');
    SetHardwareMirrorHorizontal(HardwareRenderingEnabled);
    SequenceIndex := 0;
    UpdateAutoGeometry;
    SetSequenceFrame(0);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
    CycleCompleteCallback := Self.DispatcherAnimationComplete;
    RestartPlayback;
  end;
end;
{ @end $66B7AC }

{ @routine $66BAB0 TfHangar_TryTakeOff }
function TfHangar.TryTakeOff: Boolean;
var I: Integer;
begin
  Galaxy.CheckIntegrityChecksum(212);
  PruneExpiredPersistentPlayerMessages;
  GetPlayer.OrderTakeoff;
  if GetPlayer.Order <> soTakeoff then
  begin
    Result := False;
    Galaxy.PrimeIntegrityChecksum(212);
    Exit;
  end;

  Result := True;
  for I := 0 to Galaxy.Scripts.Count - 1 do TScript(Galaxy.Scripts[I]).RunTurnCode;
  StarMapWeaponPanelOpen := False;
  FilmCameraFollow := True;
  PlayerStar.RefreshSpaceObjectPositions;
  RestoreTemporaryShopStock;
  RunGlobalScriptsForContext(GetPlayer.CurrentStar,1);
  if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(heHolyFanaticism) then Galaxy.EnableDominatorSurfaces
  else Galaxy.DisableDominatorSurfaces;
  CalculatePlayerStarTurnAndWait;
  if ExitScreenLoop then Exit;
  if GetPlayer = nil then
  begin
    GameEndReason := gerPlayerDeath;
    RequestedScreenId := screenGameEnd;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
    Exit;
  end;

  CalculateGalaxyTurnAndWait;
  StarMapScreen.ResumeMode := smrTurnFilm;
  ScreenLoadMode := 2;
  PostLoadScreenId := screenStarMap;
  RequestedScreenId := screenLoad;
end;
{ @end $66BAB0 }

{ @routine $66BC2C TfHangar_EndTurnClicked }
procedure TfHangar.EndTurnClicked(Sender: TObjectGI);
begin
  if (GetPlayer = nil) or (GetPlayer.QueuedTravelTarget <> nil) then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = rstDominion) and
    (GetPlayer.DockedTo.Order = soTeleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and
    not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = rstDominion) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = rstMilitaryBase) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and
    ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    if GetPlayer.Speed <= 0 then RuinsTalkScreen.DepartWithStation(1)
    else StationPanel.TakeOffForStationTravel;
    Exit;
  end;
  if LoadPanel.IsAnimatingShutters then Exit;
  Galaxy.CheckIntegrityChecksum(213);
  RestoreTemporaryShopStock;
  MainPanel.EndTurnClicked(Sender);
  Galaxy.PrimeIntegrityChecksum(227);
  RefreshServiceButtons;
  MainPanel.RebuildMessageButtons(False);
  if ExitCode = 0 then
  begin
    BuildTemporaryShopSlotGrid;
    Galaxy.PrimeIntegrityChecksum(214);
    RefreshDockedShips;
  end;
end;
{ @end $66BC2C }

{ @routine $66BEAC TfHangar_ShipClicked }
procedure TfHangar.ShipClicked(Sender: TObjectGI);
begin
  if IsServiceButtonDown then Exit;
  ShipInfoWindow.SetActive(False);
  ShipScreen.ShipToInspect := SelectedShip;
  MainPanel.ShipClicked(Sender);
  ShipScreen.ShipToInspect := nil;
  SelectedShip := nil;
  MainPanel.RebuildMessageButtons(False);
  MainPanel.RefreshMoneyAndCargo;
  if ShipScreen.ShipStateChanged then
  begin
    ShipSlots[0].AnimationState := 0;
    ShipSlots[0].Opacity := 0;
    GetByName('Ship' + IntToStr(0)).SetActive(False);
    RefreshDockedShips;
  end;
  RefreshServiceButtons;
end;
{ @end $66BEAC }

{ @routine $66BFF4 TfHangar_BeginTakeOff }
procedure TfHangar.BeginTakeOff;
begin
  MainPanel.NavigationLocked := True;
  if not TryTakeOff then
  begin
    MainPanel.NavigationLocked := False;
    Exit;
  end;
  LoadPanel.SelectBackgroundStyle(0);
  LoadPanel.RefreshBackgroundImages;
  LoadPanel.StartClosingShutters;
end;
{ @end $66BFF4 }

{ @routine $66C054 TfHangar_MainKeyDown }
procedure TfHangar.MainKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if (ExitCode <> 0) or LoadPanel.IsAnimatingShutters or IsServiceButtonDown or
    IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = VK_SPACE then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else if Key = Ord('F') then
  begin
    if not (GetByName('ButTakeOff') as TGraphButtonGI).Disabled then TakeOffClicked(nil);
  end
  else if Key = Ord('A') then
  begin
    if not (GetByName('ButRepair') as TGraphButtonGI).Disabled then RepairHullClicked(nil);
  end
  else if Key = Ord('B') then
  begin
    if not (GetByName('ButRefuel') as TGraphButtonGI).Disabled then RefuelClicked(nil);
  end
  else if Key = Ord('S') then
  begin
    SelectedShip := GetPlayer;
    ShipClicked(nil);
  end
  else
  begin
    MainPanel.ProcessKeyDown(Key);
    if GetPlayer.IsDockedToShip then StationPanel.ProcessKeyDown(Key)
    else if GetPlayer.IsOnPlanet then PlanetPanel.ProcessKeyDown(Key);
  end;
end;
{ @end $66C054 }

{ @routine $66C27C TfHangar_SelectMusic }
procedure TfHangar.SelectMusic;
begin
  if ((ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1)) or TakeOffPending then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.IsOnPlanet then
  begin
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
    begin
      if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.PiratePlanetMain');
    end
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end
  else if GetPlayer.IsDockedToShip then
  begin
    if not MusicInPlanetEnabled then
    begin
      MusicManager.RequestFadeOut;
      Exit;
    end;
    if GetPlayer.DockedTo.TypeId in [rstPirateBase,rstDominion] then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end;
end;
{ @end $66C27C }

{ @routine $66C4F4 TfHangar_IsServiceButtonDown }
function TfHangar.IsServiceButtonDown: Boolean;
begin
  Result := True;
  if (GetByName('ButTakeOff') as TGraphButtonGI).Down or
    (GetByName('ButRepair') as TGraphButtonGI).Down or
    (GetByName('ButRefuel') as TGraphButtonGI).Down then Exit;
  Result := False;
end;
{ @end $66C4F4 }

{ @routine $66C5BC TfHangar_RefreshServiceButtons }
procedure TfHangar.RefreshServiceButtons;
begin
  with GetByName('ButRepair') as TGraphButtonGI do
  begin
    SetDisabled((GetPlayer = nil) or (GetPlayer.GetHull.HullPoints >= GetPlayer.GetHull.Weight));
    if Disabled then HelpText := LocalizedColorText('Help.ButRepair')
    else HelpText := LocalizedColorText('Help.ButRepair') + ' ' +
      FormatText1(LocalizedColorText('FormHangar.HullStatus.Cost'),TextHighlightColorTag,'<Money>',IntToStr(GetPlayer.GetHull.CalculateRepairCost));
  end;
  with GetByName('ButRefuel') as TGraphButtonGI do
  begin
    SetDisabled((GetPlayer = nil) or (GetPlayer.GetFullRefuelCost <= 0));
    if Disabled then HelpText := LocalizedColorText('Help.ButRefuel')
    else HelpText := LocalizedColorText('Help.ButRefuel') + ' ' +
      FormatText1(LocalizedColorText('FormHangar.FuelTankStatus.Cost'),TextHighlightColorTag,'<Money>',IntToStr(GetPlayer.GetFullRefuelCost));
  end;
  (GetByName('ButTakeOff') as TGraphButtonGI).SetDisabled(not RefreshTakeOffStatus);
end;
{ @end $66C5BC }

{ @routine $66C970 TfHangar_RepairHullClicked }
procedure TfHangar.RepairHullClicked(Sender: TObjectGI);
begin
  if LoadPanel.IsAnimatingShutters or MainPanel.NavigationLocked or HasPendingScriptRequests then Exit;
  if GetPlayer.Money <= 0 then
  begin
    Galaxy.CheckIntegrityChecksum(215);
    GetPlayer.SetMoney(0);
    Galaxy.PrimeIntegrityChecksum(216);
    ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormHangar.HullStatus.NotMoney'),TextHighlightColorTag,'<Money>',IntToStr(GetPlayer.GetHull.CalculateRepairCost)),mbgCancel or mbgError);
    MainPanel.FlashMoneyWarning;
    Exit;
  end;
  if GetPlayer.GetHull.CalculateRepairCost > GetPlayer.Money then
  begin
    Galaxy.CheckIntegrityChecksum(217);
    Inc(GetPlayer.GetHull.HullPoints,Round(GetPlayer.Money / GetPlayer.GetHull.CalculateRepairCost * (GetPlayer.GetHull.Weight - GetPlayer.GetHull.HullPoints)));
    GetPlayer.SetMoney(0);
    Galaxy.PrimeIntegrityChecksum(218);
    SoundManager.PlaySound('Sound.Repair');
  end
  else
  begin
    Galaxy.CheckIntegrityChecksum(219);
    GetPlayer.SetMoney(GetPlayer.Money - GetPlayer.GetHull.CalculateRepairCost);
    GetPlayer.GetHull.HullPoints := GetPlayer.GetHull.Weight;
    Galaxy.PrimeIntegrityChecksum(220);
    SoundManager.PlaySound('Sound.Repair');
  end;
  with GetByName('AnimRepair') as TgaiGI do
  begin
    SetActive(True);
    SetSequenceFrame(0);
    RestartPlayback;
    CycleCompleteCallback := Self.StopAnimation;
  end;
  RefreshServiceButtons;
  SetHoveredControl(nil);
  PostMouseMoveMessage;
end;
{ @end $66C970 }

{ @routine $66CD1C TfHangar_RefuelClicked }
procedure TfHangar.RefuelClicked(Sender: TObjectGI);
begin
  if LoadPanel.IsAnimatingShutters or MainPanel.NavigationLocked or HasPendingScriptRequests then Exit;
  if GetPlayer.GetFullRefuelCost > GetPlayer.Money then
  begin
    ShowMessageBoxGI(Self,FormatText1(LocalizedColorText('FormHangar.FuelTankStatus.NotMoney'),TextHighlightColorTag,'<Money>',IntToStr(GetPlayer.GetFullRefuelCost)),mbgCancel or mbgError);
    MainPanel.FlashMoneyWarning;
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum(221);
  GetPlayer.SetMoney(GetPlayer.Money - GetPlayer.GetFullRefuelCost);
  GetPlayer.GetFuelTanks.Fuel := GetPlayer.GetFuelTanks.Capacity;
  GetPlayer.RefreshDerivedStats(True);
  Galaxy.PrimeIntegrityChecksum(222);
  SoundManager.PlaySound('Sound.Sell');
  with GetByName('AnimFuel') as TgaiGI do
  begin
    SetActive(True);
    SetSequenceFrame(0);
    RestartPlayback;
    CycleCompleteCallback := Self.StopAnimation;
  end;
  RefreshServiceButtons;
  SetHoveredControl(nil);
  PostMouseMoveMessage;
end;
{ @end $66CD1C }

{ @routine $66CFD4 TfHangar_TakeOffClicked }
procedure TfHangar.TakeOffClicked(Sender: TObjectGI);
begin
  if LoadPanel.IsAnimatingShutters or MainPanel.NavigationLocked or HasPendingScriptRequests or
    (TurnCalculationPhase = tcpGalaxyRunning) or (TurnCalculationPhase = tcpPlayerStarRunning) then Exit;
  CaptureSavePreview;
  Galaxy.CheckIntegrityChecksum(223);
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath,'as');
  Galaxy.PrimeIntegrityChecksum(223);
  PlayerAutomaticControl := False;
  (GetByName('ButRepair') as TGraphButtonGI).SetDisabled(True);
  (GetByName('ButRefuel') as TGraphButtonGI).SetDisabled(True);
  (GetByName('ButTakeOff') as TGraphButtonGI).SetDisabled(True);
  TakeOffPending := True;
  if MusicManager.CategoryOverride = WideString('') then MusicManager.RequestFadeOut;
  EvictRuinsAndGovernmentCaches;
  ReleaseAllTextureSurfaces;
  BeginTakeOff;
end;
{ @end $66CFD4 }

{ @routine $66D1BC TfHangar_StopAnimation }
procedure TfHangar.StopAnimation(Sender: TObjectGI);
begin
  with Sender as TgaiGI do
  begin
    SetActive(False);
    StopAutoPlayback;
  end;
end;
{ @end $66D1BC }

{ @routine $66D1F0 TfHangar_RefreshTakeOffStatus }
function TfHangar.RefreshTakeOffStatus: Boolean;
var
  TotalText, Text: WideString;
  Warning: Boolean;
begin
  if GetPlayer = nil then
  begin
    Result := False;
    Exit;
  end;
  Galaxy.CheckIntegrityChecksum(225);
  GetPlayer.RefreshDerivedStats(True);
  Galaxy.PrimeIntegrityChecksum(226);
  Result := True;
  TotalText := LocalizedColorText('FormHangar.TotalStatus.Good');
  with GetPlayer do
  begin
    Text := '';
    Warning := False;
    if GetHull.HullPoints >= GetHull.Weight then Text := LocalizedColorText('FormHangar.HullStatus.Ok')
    else
    begin
      Text := LocalizedColorText('FormHangar.HullStatus.NeedRepair');
      Warning := True;
    end;
    (GetByName('Text1') as TLabelGI).SetText(Text);
    GetByName('Light1').SetActive(Warning);
    Text := '';
    Warning := False;
    if GetFuelTanks = nil then
    begin
      Text := LocalizedColorText('FormHangar.FuelTankStatus.Non');
      TotalText := LocalizedText('FormHangar.TotalStatus.Bad');
      Result := False;
      Warning := True;
    end
    else if not CanUseEquipmentTech(GetFuelTanks) then
    begin
      Text := LocalizedColorText('FormHangar.FuelTankStatus.CanNotUse');
      TotalText := LocalizedColorText('FormHangar.TotalStatus.Bad');
      Result := False;
      Warning := True;
    end
    else if GetFuelTanks.Fuel = 0 then
    begin
      Text := LocalizedColorText('FormHangar.FuelTankStatus.Empty');
      TotalText := LocalizedText('FormHangar.TotalStatus.Bad');
      Result := False;
      Warning := True;
    end
    else if GetFuelTanks.BrokenFlag <> 0 then
    begin
      Text := LocalizedColorText('FormHangar.FuelTankStatus.NeedRepair');
      TotalText := LocalizedColorText('FormHangar.TotalStatus.Nearly');
      Warning := True;
    end
    else if GetFuelTanks.ConditionPercent < 20 then
    begin
      Text := LocalizedColorText('FormHangar.FuelTankStatus.SmallDuration');
      TotalText := LocalizedColorText('FormHangar.TotalStatus.Nearly');
      Warning := True;
    end
    else if GetFuelTanks.ConditionPercent < 50 then
    begin
      Text := LocalizedColorText('FormHangar.FuelTankStatus.AverageDuration');
      TotalText := LocalizedColorText('FormHangar.TotalStatus.Nearly');
      Warning := True;
    end
    else if GetFuelTanks.Fuel < GetFuelTanks.Capacity then Text := LocalizedColorText('FormHangar.FuelTankStatus.NeedFuel')
    else Text := LocalizedColorText('FormHangar.FuelTankStatus.Ok');
    (GetByName('Text2') as TLabelGI).SetText(Text);
    GetByName('Light2').SetActive(Warning);
    Text := '';
    Warning := False;
    if GetEngine = nil then
    begin
      Text := LocalizedColorText('FormHangar.EngineStatus.Non');
      TotalText := LocalizedColorText('FormHangar.TotalStatus.Bad');
      Result := False;
      Warning := True;
    end
    else if not CanUseEquipmentTech(GetEngine) or (CalculateEngineSpeed(GetEngine,False) <= 0) then
    begin
      Text := LocalizedColorText('FormHangar.EngineStatus.CanNotUse');
      TotalText := LocalizedColorText('FormHangar.TotalStatus.Bad');
      Result := False;
      Warning := True;
    end
    else
    begin
      if GetEngine.BrokenFlag <> 0 then
      begin
        Text := LocalizedColorText('FormHangar.EngineStatus.NeedRepair');
        if Result then TotalText := LocalizedColorText('FormHangar.TotalStatus.Nearly');
        Warning := True;
      end
      else if GetEngine.ConditionPercent < 20 then
      begin
        Text := LocalizedColorText('FormHangar.EngineStatus.SmallDuration');
        if Result then TotalText := LocalizedColorText('FormHangar.TotalStatus.Nearly');
        Warning := True;
      end
      else if GetEngine.ConditionPercent < 50 then
      begin
        Text := LocalizedColorText('FormHangar.EngineStatus.AverageDuration');
        if Result then TotalText := LocalizedColorText('FormHangar.TotalStatus.Nearly');
        Warning := True;
      end
      else Text := LocalizedColorText('FormHangar.EngineStatus.Ok');
      if (GetPlayer.DockedTo <> nil) and GetPlayer.DockedTo.InHyperspace then
      begin
        TotalText := LocalizedColorText('FormHangar.TotalStatus.RuinInHyperSpace');
        Result := False;
      end;
      if CargoFreeSpace < 0 then
      begin
        TotalText := LocalizedColorText('FormHangar.TotalStatus.ShipOvercharging');
        Result := False;
      end;
    end;
    (GetByName('Text3') as TLabelGI).SetText(Text);
    GetByName('Light3').SetActive(Warning);
    (GetByName('Text4') as TLabelGI).SetText(TotalText);
    GetByName('Light4').SetActive(not Result);
  end;
end;
{ @end $66D1F0 }

{ @routine $66DD54 TfHangar_AmbientAnimationComplete }
procedure TfHangar.AmbientAnimationComplete(Sender: TObjectGI);
begin
  if not AnimHangar then Exit;
  with GetByName('AnimOpen') as TgaiGI do
  begin
    SetActive(True);
    StopAutoPlayback;
    SetSequenceFrame(SequenceFrameCount - 1);
  end;
  with GetByName('AnimRnd') as TgaiGI do
  begin
    SetActive(False);
    StopAutoPlayback;
  end;
  if AmbientAnimationTimer <> nil then
  begin
    CancelCallbackTimer(AmbientAnimationTimer);
    AmbientAnimationTimer := nil;
  end;
  AmbientAnimationTimer := ScheduleCallbackTimer(RandomIntRange(2000,4000),1,StartAmbientAnimation);
end;
{ @end $66DD54 }

{ @routine $66DE64 TfHangar_StartAmbientAnimation }
procedure TfHangar.StartAmbientAnimation(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if AmbientAnimationTimer <> nil then
  begin
    CancelCallbackTimer(AmbientAnimationTimer);
    AmbientAnimationTimer := nil;
  end;
  if AnimHangar then
  begin
    with GetByName('AnimOpen') as TgaiGI do
    begin
      SetActive(False);
      StopAutoPlayback;
    end;
    with GetByName('AnimRnd') as TgaiGI do
    begin
      SetActive(True);
      SetSequenceFrame(0);
      RestartPlayback;
    end;
  end;
end;
{ @end $66DE64 }

{ @routine $66DF3C TfHangar_GetShipPortraitScale }
function TfHangar.GetShipPortraitScale(Ship: TShip): Single;
begin
  if Ship.ChameleonActive then Result := HangarDominatorPortraitScales[Ship.ChameleonSeries,Ship.ChameleonVisualType]
  else if Ship is TKling then Result := HangarDominatorPortraitScales[(Ship as TKling).DominatorSeries,(Ship as TKling).KlingType]
  else Result := 1.0;
end;
{ @end $66DF3C }

{ @routine $66DFDC TfHangar_LoadDockedShipImage }
procedure TfHangar.LoadDockedShipImage(Index: Integer; ImagePath: WideString; LargeHull: Boolean; Scale: Single);
var Width: Integer;
begin
  with GetByName('Ship' + IntToStr(Index)) as TGraphBufGI do
  begin
    SetActive(True);
    SourceHasPerPixelAlpha := True;
    LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(ImagePath,1,','),ShipSlots[Index].ImageBuffer);
    if Index <= 0 then Width := GiScalePixels(128)
    else if Index <= 3 then Width := GiScalePixels(100)
    else Width := GiScalePixels(80);
    if LargeHull then Inc(Width,Width div 2);
    Width := Round(Width * Scale);
    if (ShipSlots[Index].ImageBuffer.Width > Width) or (ShipSlots[Index].ImageBuffer.Height > Width) then
      ShipSlots[Index].ImageBuffer.RescaleRgba(Width,Round(Width * ShipSlots[Index].ImageBuffer.Height / ShipSlots[Index].ImageBuffer.Width),5);
    SetOrigin(ShipSlots[Index].ImageBuffer.GetPixelCentroid);
    SetSize(Classes.Point(ShipSlots[Index].ImageBuffer.Width,ShipSlots[Index].ImageBuffer.Height));
    SetImageKindX(ikxLeft);
    SetImageKindY(ikyTop);
  end;
end;
{ @end $66DFDC }

{ @routine $66E234 TfHangar_SetDockedShipOpacity }
procedure TfHangar.SetDockedShipOpacity(Index: Integer; Alpha: Byte);
begin
  with GetByName('Ship' + IntToStr(Index)) as TGraphBufGI do
  begin
    GraphBuf.AllocateRgbaTight(ShipSlots[Index].ImageBuffer.Width,ShipSlots[Index].ImageBuffer.Height);
    GraphBuf.CopyRect32(Classes.Point(0,0),ShipSlots[Index].ImageBuffer,Classes.Rect(0,0,ShipSlots[Index].ImageBuffer.Width,ShipSlots[Index].ImageBuffer.Height));
    GraphBuf.ScaleAlpha(Classes.Rect(0,0,ShipSlots[Index].ImageBuffer.Width,ShipSlots[Index].ImageBuffer.Height),Alpha);
    Invalidate;
  end;
end;
{ @end $66E234 }

{ @routine $66E3C8 TfHangar_AnimateDockedShips }
procedure TfHangar.AnimateDockedShips(Timer: PCallbackTimerGI; UserData: Integer);
var I: Integer;
begin
  for I := 0 to 8 do
    if ShipSlots[I].AnimationState = 1 then
    begin
      Inc(ShipSlots[I].Opacity,10);
      if ShipSlots[I].Opacity >= 255 then
      begin
        ShipSlots[I].Opacity := 255;
        ShipSlots[I].AnimationState := 2;
      end;
      SetDockedShipOpacity(I,ShipSlots[I].Opacity);
    end
    else if ShipSlots[I].AnimationState = 3 then
    begin
      Dec(ShipSlots[I].Opacity,10);
      if ShipSlots[I].Opacity <= 0 then
      begin
        ShipSlots[I].Opacity := 0;
        ShipSlots[I].AnimationState := 0;
        (GetByName('Ship' + IntToStr(I)) as TGraphBufGI).SetActive(False);
      end;
      SetDockedShipOpacity(I,ShipSlots[I].Opacity);
    end;
  RefreshDockedShips;
end;
{ @end $66E3C8 }

{ @routine $66E58C TfHangar_RefreshDockedShips }
procedure TfHangar.RefreshDockedShips;
// Early loop guards retain the native local-use weights and ShipId store order.
var
  I, J, K, Swap: Integer;
  Ship: TShip;
  Path: WideString;
  LargeHull: Boolean;
  SlotOrder: array[0..8] of Integer;
begin
  if IsTurnCalculationRunning then WaitForTurnCalculation;
  for I := 0 to 8 do
    if ShipSlots[I].AnimationState = 2 then
    begin
      Ship := TShip(Galaxy.IdToShip(ShipSlots[I].ShipId,False));
      if (Ship = nil) or
        (not (GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet = Ship.CurrentPlanet)) and
         not (GetPlayer.IsDockedToShip and (GetPlayer.DockedTo = Ship.DockedTo))) then
      begin
        ShipSlots[I].AnimationState := 3;
        ShipSlots[I].Opacity := 255;
      end;
    end;
  for I := 1 to 8 do
    if (ShipSlots[I].AnimationState = 0) and (ShipSlots[I].ShipId <> 0) then
    begin
      Ship := TShip(Galaxy.IdToShip(ShipSlots[I].ShipId,False));
      if Ship <> nil then
      begin
        if not ((GetPlayer.IsOnPlanet and (GetPlayer.CurrentPlanet = Ship.CurrentPlanet)) or
          (GetPlayer.IsDockedToShip and (GetPlayer.DockedTo = Ship.DockedTo))) then Ship := nil
        else
        begin
          K := 0;
          while K <= 8 do
          begin
            if (ShipSlots[K].AnimationState <> 0) and (ShipSlots[K].ShipId = Ship.Id) then
            begin
              Ship := nil;
              Break;
            end;
            Inc(K);
          end;
        end;
      end;
      if Ship = nil then Continue;
      Path := '';
      LargeHull := False;
      Path := Ship.GetShipPortraitImagePath;
      if Path = WideString('') then Continue;
      ShipSlots[I].ShipId := Ship.Id;
      ShipSlots[I].AnimationState := 1;
      ShipSlots[I].Opacity := 0;
      LoadDockedShipImage(I,Path,LargeHull,GetShipPortraitScale(Ship));
      SetDockedShipOpacity(I,ShipSlots[I].Opacity);
    end;
  for I := 0 to 8 do SlotOrder[I] := I;
  for I := 0 to 10 do
  begin
    J := RandomIntRange(1,8);
    K := RandomIntRange(1,8);
    Swap := SlotOrder[J];
    SlotOrder[J] := SlotOrder[K];
    SlotOrder[K] := Swap;
  end;
  for I := 0 to 8 do
    if ShipSlots[SlotOrder[I]].AnimationState = 0 then
    begin
      Ship := nil;
      if SlotOrder[I] = 0 then Ship := GetPlayer
      else if Ship = nil then
      begin
      if GetPlayer.IsOnPlanet then
      begin
        for J := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
        begin
          Ship := TShip(GetPlayer.CurrentStar.Ships[J]);
          if GetPlayer = Ship then Ship := nil
          else if GetPlayer.CurrentPlanet <> Ship.CurrentPlanet then Ship := nil
          else
          begin
            K := 0;
            while K <= 8 do
            begin
              if (ShipSlots[K].AnimationState <> 0) and (ShipSlots[K].ShipId = Ship.Id) then Break;
              Inc(K);
            end;
            if K > 8 then Break;
            Ship := nil;
          end;
        end;
        if Ship = nil then
          for J := 0 to GetPlayer.CurrentPlanet.Warriors.Count - 1 do
          begin
            Ship := TShip(GetPlayer.CurrentPlanet.Warriors[J]);
            if GetPlayer.CurrentPlanet <> Ship.CurrentPlanet then Ship := nil
            else
            begin
              K := 0;
              while K <= 8 do
              begin
                if (ShipSlots[K].AnimationState <> 0) and (ShipSlots[K].ShipId = Ship.Id) then Break;
                Inc(K);
              end;
              if K > 8 then Break;
              Ship := nil;
            end;
          end;
      end
      else if GetPlayer.IsDockedToShip then
        for J := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
        begin
          Ship := TShip(GetPlayer.CurrentStar.Ships[J]);
          if GetPlayer = Ship then Ship := nil
          else if GetPlayer.DockedTo <> Ship.DockedTo then Ship := nil
          else
          begin
            K := 0;
            while K <= 8 do
            begin
              if (ShipSlots[K].AnimationState <> 0) and (ShipSlots[K].ShipId = Ship.Id) then Break;
              Inc(K);
            end;
            if K > 8 then Break;
            Ship := nil;
          end;
        end;
      end;
      if Ship = nil then Continue;
      Path := '';
      LargeHull := False;
      Path := Ship.GetShipPortraitImagePath;
      if Path = WideString('') then Continue;
      ShipSlots[SlotOrder[I]].ShipId := Ship.Id;
      ShipSlots[SlotOrder[I]].AnimationState := 1;
      ShipSlots[SlotOrder[I]].Opacity := 0;
      LoadDockedShipImage(SlotOrder[I],Path,LargeHull,GetShipPortraitScale(Ship));
      // Native indexes the opacity by I here, before mapping through SlotOrder.
      SetDockedShipOpacity(SlotOrder[I],ShipSlots[I].Opacity);
    end;
end;
{ @end $66E58C }

{ @routine $66EBF8 TfHangar_MainMouseMove }
procedure TfHangar.MainMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  I: Integer;
  Ship: TShip;
  CursorPoint: TPoint;
begin
  if (Galaxy = nil) or (GetPlayer = nil) or GetPlayer.IsHullDestroyed then Exit;
  CursorPoint := GetCursorPoint;
  for I := 0 to 8 do
  begin
    Ship := TShip(Galaxy.IdToShip(ShipSlots[I].ShipId,False));
    if (Ship <> nil) and ShipSlots[I].ImageControl.HitTestPixel(CursorPoint) then
    begin
      ShowShipInfo(Ship);
      if DynamicTipsPos then
      begin
        with ShipSlots[I].ImageControl do
          ShipInfoWindow.SetPosition(Classes.Point(HitTestBounds.Left + ClientSize.X div 2 - ShipInfoWindow.ClientSize.X div 2,
            HitTestBounds.Top + ClientSize.Y));
      end
      else ShipInfoWindow.SetPosition(Classes.Point(10,10));
      Exit;
    end;
  end;
  HoveredShip := nil;
  if ShipInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ShipInfoHideTimer);
    ShipInfoHideTimer := nil;
  end;
  ShipInfoHideTimer := ScheduleCallbackTimer(30,30,HideShipInfo);
end;
{ @end $66EBF8 }

{ @routine $66EDA8 TfHangar_MainRightButtonDown }
procedure TfHangar.MainRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  I: Integer;
  Ship: TShip;
  CursorPoint: TPoint;
begin
  CursorPoint := GetCursorPoint;
  for I := 0 to 8 do
  begin
    Ship := TShip(Galaxy.IdToShip(ShipSlots[I].ShipId,False));
    if (Ship <> nil) and ShipSlots[I].ImageControl.HitTestPixel(CursorPoint) and (Ship.TypeId <> stKling) and not Ship.NoScan then
    begin
      if GetPlayer = Ship then
      begin
        SelectedShip := GetPlayer;
        ShipClicked(nil);
      end
      else if (Ship is TTranclucator) and ((Ship as TTranclucator).OwnerShip = GetPlayer) then
      begin
        if IsVirtualKeyDown(VK_CONTROL) then
        begin
          Galaxy.CheckIntegrityChecksum(227);
          (Ship as TTranclucator).ConvertToStoredArtefact;
          Galaxy.PrimeIntegrityChecksum(228);
          RefreshDockedShips;
        end
        else
        begin
          SelectedShip := Ship;
          ShipClicked(nil);
        end;
      end
      else
      begin
        SoundManager.PlaySound('Sound.Scan');
        SetCursorActive(False);
        Present;
        CaptureScreenBackground(True,0);
        SetCursorActive(True);
        ScannerTarget := Ship;
        ScannerReturnScreenId := FormToId(Self);
        RequestedScreenId := screenScanner;
        RequestClose(1);
      end;
      BreakUiMessage;
      Break;
    end;
  end;
end;
{ @end $66EDA8 }

{ @routine $66EF98 TfHangar_HideShipInfo }
procedure TfHangar.HideShipInfo(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if ShipInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ShipInfoHideTimer);
    ShipInfoHideTimer := nil;
  end;
  ShipInfoWindow.SetActive(False);
  HoveredShip := nil;
end;
{ @end $66EF98 }

{ @routine $66EFF0 TfHangar_ShowShipInfo }
procedure TfHangar.ShowShipInfo(Ship: TShip);
var
  Text, Path, ColorTag: WideString;
  DamageCaption, DamageText: TLabelGI;
  BarWidth, CapWidth, MinimumWidth: Integer;
begin
  if ShipInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ShipInfoHideTimer);
    ShipInfoHideTimer := nil;
  end;
  if HoveredShip = Ship then Exit;
  ShipInfoWindow.SetActive(True);
  Ship.ScriptItemsAct(satOnShowingShipInfo,nil,nil,0);
  if GetPlayer <> Ship then
  begin
    (GetByName('InfoShipName') as TLabelGI).SetText(WrapTextInColor(Ship.GetFullName(' '),InfoNameColorTag));
    if (Ship <> nil) and (GetPlayer = Ship.PartnerShip) then
      (GetByName('InfoShipName') as TLabelGI).SetText((GetByName('InfoShipName') as TLabelGI).GetText + #13#10 +
        WrapTextInColor(LookupLocalizedTextByKey('FormInfo.Partner'),TextHighlightColorTag));
    if (Ship is TKling) and ((Ship as TKling).ActiveProgramAppliedTurn > 0) and ((Ship as TKling).ActiveProgramId in [prgShipwreck..prgDisconnection]) then
      (GetByName('InfoShipName') as TLabelGI).SetText((GetByName('InfoShipName') as TLabelGI).GetText + #13#10 +
        WrapTextInColor(LocalizedText('Programms.' + ProgramNames[(Ship as TKling).ActiveProgramId] + '.AddToShipInfo'),RedColorTag));
    if (Ship is TRanger) and (Cardinal((Ship as TRanger).PrisonTermRemaining) > 0) then
      (GetByName('InfoShipName') as TLabelGI).SetText((GetByName('InfoShipName') as TLabelGI).GetText + #13#10 +
        WrapTextInColor(LocalizedColorText('FormHangar.Prison'),RedColorTag))
    else if (Ship is TPirate) and (Cardinal((Ship as TPirate).PrisonTermRemaining) > 0) then
      (GetByName('InfoShipName') as TLabelGI).SetText((GetByName('InfoShipName') as TLabelGI).GetText + #13#10 +
        WrapTextInColor(LocalizedColorText('FormHangar.Prison'),RedColorTag));
  end
  else (GetByName('InfoShipName') as TLabelGI).SetText(WrapTextInColor(Ship.GetFullName(' '),InfoNameColorTag));
  if Ship.GetFactionNameKey <> 'None' then
  begin
    with GetByName('InfoShipEmRace') as TImageGI do
    begin
      SetImagePath(GetFactionEmblemPath(Ship.GetFactionNameKey));
      SetImageKindX(ikxRight);
      SetImageKindY(ikyBottom);
      SetActive(True);
    end;
  end
  else GetByName('InfoShipEmRace').SetActive(False);
  if Ship.Graphic is TShip2SE then
  begin
    with GetByName('InfoShipImage2') as TGraphBufGI do
    begin
      Path := Ship.GetShipPortraitImagePath;
      SetActive(Path <> WideString(''));
      if Active then
      begin
        SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(Path,1,','),GraphBuf);
        if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
          if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
            GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
          else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y,5);
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
        SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
      end;
    end;
  end
  else
  begin
    with GetByName('InfoShipImage2') as TGraphBufGI do
    begin
      SetActive(True);
      SourceHasPerPixelAlpha := True;
      if (TerronShip = Ship) and (Galaxy.TerronToStarTurn >= TerronTransformationFlag) then
        LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW(TStarSE(TerronShip.CurrentStar.Graphic).StaticImagePath,1,','),GraphBuf)
      else LoadGiByPathIntoGraphBuf(ExtractDelimitedPartW((Ship.Graphic as TRuinsSE).StaticImagePath,1,','),GraphBuf);
      if (ClientSize.X < GraphBuf.Width) or (ClientSize.Y < GraphBuf.Height) then
        if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
          GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
        else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y,5);
      SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
    end;
  end;
  if Ship is TRuins then
  begin
    (GetByName('ISType') as TLabelGI).SetActive(False);
    (GetByName('InfoShipType') as TLabelGI).SetActive(False);
  end
  else
  begin
    (GetByName('ISType') as TLabelGI).SetActive(True);
    (GetByName('InfoShipType') as TLabelGI).SetActive(True);
    if Ship is TRanger then (GetByName('InfoShipType') as TLabelGI).SetText((Ship as TRanger).GetCharacterName)
    else (GetByName('InfoShipType') as TLabelGI).SetText(Ship.GetLocalizedTypeName);
  end;
  (GetByName('InfoShipSpeed') as TLabelGI).SetText(IntToStr(Ship.CalculateSpeed));
  (GetByName('InfoShipDamage') as TLabelGI).SetText(WrapTextInColor('???',''));
  if Ship.GetHull.HullPoints <= Ship.GetHull.Weight / 2 then ColorTag := OrangeColorTag else ColorTag := '';
  if GetPlayer.CanResolveObjectWithScanner(Ship) or (GetPlayer = Ship) or (GetPlayer = Ship.PartnerShip) or (Ship.TypeId = stTranclucator) then
  begin
    Text := WrapTextInColor(IntToStr(Ship.GetHull.HullPoints),ColorTag) + '/' + IntToStr(Ship.GetHull.Weight);
    if GetPlayer.HasScannerArtefact(Ship) then
    begin
      (GetByName('InfoShipDamage') as TLabelGI).SetText(Ship.GetWeaponDamageSummary);
      Text := Text + ' + ' + WrapTextInColor(Ship.GetRepairPointsSummary,'');
    end;
    (GetByName('InfoShipSize') as TLabelGI).SetText(Text);
  end
  else (GetByName('InfoShipSize') as TLabelGI).SetText(WrapTextInColor('???',ColorTag));
  Text := IntToStr(Ship.GetDefensePercent) + '%';
  if GetPlayer.CanResolveObjectWithScanner(Ship) or (GetPlayer = Ship) or (GetPlayer = Ship.PartnerShip) or (Ship.TypeId = stTranclucator) then
  begin
    Text := Text + ' + ' + WrapTextInColor(IntToStr(Ship.GetArmor),'');
    if GetPlayer.HasScannerArtefact(Ship) then Text := Ship.GetManeuverabilitySummary + Text;
  end;
  (GetByName('InfoShipDef') as TLabelGI).SetText(Text);
  (GetByName('InfoShipRel') as TLabelGI).SetText(Ship.GetRelationLevelTextToShip(GetPlayer));
  if (GetPlayer <> Ship) and not (Ship is TRuins) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) and GetPlayer.CanResolveObjectWithScanner(Ship) then
  begin
    (GetByName('ISWin') as TLabelGI).SetActive(True);
    (GetByName('InfoShipWin') as TLabelGI).SetActive(True);
    (GetByName('InfoShipWin') as TLabelGI).SetText(IntToStr(GetPlayer.GetWinChancePercent(Ship)) + '%');
  end
  else
  begin
    (GetByName('ISWin') as TLabelGI).SetActive(False);
    (GetByName('InfoShipWin') as TLabelGI).SetActive(False);
  end;
  BarWidth := Round(Sqrt(Ship.GetHull.Weight / HullBaseSize / Max(0.1,Ship.GetHull.GetFragilityFactor([]))) * 64);
  BarWidth := Min(192,Max(32,BarWidth));
  with GetByName('InfoShipDurableLeft') as TImageGI do
  begin
    CapWidth := GetContentSize.X;
    MinimumWidth := 2 * CapWidth + BarWidth + LocalPosition.X + Parent.LocalPosition.X + 2 * Parent.Parent.LocalPosition.X;
  end;
  with GetByName('InfoShipDurable') as TImageGI do
  begin
    if GetPlayer.CanResolveObjectWithScanner(Ship) or (GetPlayer = Ship) or (GetPlayer = Ship.PartnerShip) or (Ship.TypeId = stTranclucator) then
      SetPosition(Classes.Point(Round(Ship.GetHull.HullPoints / Ship.GetHull.Weight * BarWidth) - (GetContentSize.X - 5),LocalPosition.Y))
    else
    begin
      MinimumWidth := MinimumWidth - BarWidth + 64;
      BarWidth := 64;
      SetPosition(Classes.Point(BarWidth - (GetContentSize.X - 5),LocalPosition.Y));
    end;
    Parent.Parent.SetActive(True);
    Parent.Parent.SetSize(Classes.Point(2 * CapWidth + BarWidth,Parent.Parent.ClientSize.Y));
    Parent.SetSize(Classes.Point(BarWidth + 2,Parent.Parent.ClientSize.Y));
  end;
  with GetByName('InfoShipDurableRight') as TImageGI do
  begin
    SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X,LocalPosition.Y));
    Parent.SetPosition(Classes.Point(CapWidth,Parent.LocalPosition.Y));
    Parent.SetSize(Classes.Point(BarWidth + CapWidth,Parent.ClientSize.Y));
  end;
  with GetByName('InfoShipDurableBack') as TImageGI do
  begin
    SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X,LocalPosition.Y));
    Parent.SetSize(Classes.Point(BarWidth + CapWidth,Parent.ClientSize.Y));
  end;
  DamageCaption := GetByName('ISDamage') as TLabelGI;
  DamageText := GetByName('InfoShipDamage') as TLabelGI;
  if GetPlayer.HasScannerArtefact(Ship) then
  begin
    DamageCaption.SetActive(True);
    DamageText.SetActive(True);
  end
  else
  begin
    DamageCaption.SetActive(False);
    DamageText.SetActive(False);
    DamageCaption := nil;
    DamageText := nil;
  end;
  ShipScreen.LayoutObjectInfo(ShipInfoWindow,GetByName('InfoShipName') as TLabelGI,
    GetByName('ISType') as TLabelGI,GetByName('InfoShipType') as TLabelGI,
    GetByName('ISSpeed') as TLabelGI,GetByName('InfoShipSpeed') as TLabelGI,
    GetByName('ISSize') as TLabelGI,GetByName('InfoShipSize') as TLabelGI,
    GetByName('ISDef') as TLabelGI,GetByName('InfoShipDef') as TLabelGI,
    DamageCaption,DamageText,GetByName('ISRel') as TLabelGI,GetByName('InfoShipRel') as TLabelGI,
    GetByName('ISWin') as TLabelGI,GetByName('InfoShipWin') as TLabelGI,
    nil,nil,GetByName('InfoShipEmRace'),True,MinimumWidth);
  HoveredShip := Ship;
end;
{ @end $66EFF0 }

{ @routine $670960 TfHangar_ExecuteUiCode }
procedure TfHangar.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not LoadPanel.IsAnimatingShutters and not MainPanel.NavigationLocked and not ExitScreenLoop and
    (TurnCalculationPhase in [tcpIdle,tcpGalaxyFinished,tcpPlayerStarFinished,tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10000);
    ExecuteGameplayUiCode(Block,Key);
    Galaxy.PrimeIntegrityChecksum(20000);
  end;
end;
{ @end $670960 }

end.
