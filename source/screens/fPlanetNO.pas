unit fPlanetNO;
// Unit bracket (inferred): .text 0x007E516C..0x007ECB8B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, EC_Struct, GI_Image, GI_Label, GI_MessageLoop, GI_Window, GR_Sound, Types, aItem, fPanelLoad, fPanelMain;

type
  TProbeTrajectoryPoint = packed record // @size 0x14
    Position: TPointF; // @offset 0x00
    Direction: TPointF; // @offset 0x08  Unit vector to the next point; undefined for the last point.
  end;
  TProbeTrajectory = array[0..255] of TProbeTrajectoryPoint;

  TfPlanetNO = class(TMessageLoopGIWithMainPanel) // @size 0x7958
  public
    LoadPanel: TfPanelLoad; // @offset 0xD4
    TrajectoryPointCounts: array[0..5] of Integer; // @offset 0xD8
    Trajectories: array[0..5] of TProbeTrajectory; // @offset 0xF0
    SelectedTrajectoryIndex: Integer; // @offset 0x78F0  -1 when no trajectory is highlighted.
    SatelliteInventoryPageStart: Integer; // @offset 0x78F4
    SatelliteInventorySlots: array[0..5] of TImageGI; // @offset 0x78F8
    ResearchPanelVisible: Boolean; // @offset 0x7910
    ItemInfoWindow: TWindowGI; // @offset 0x7914
    ItemInfoImage: TImageGI; // @offset 0x7918
    ItemInfoNameLabel: TLabelGI; // @offset 0x791C
    ItemInfoTextLabel: TLabelGI; // @offset 0x7920
    ItemInfoSizeLabel: TLabelGI; // @offset 0x7924
    ItemInfoCostLabel: TLabelGI; // @offset 0x7928
    ItemInfoRaceIcon: TImageGI; // @offset 0x792C
    ItemInfoHideTimer: PCallbackTimerGI; // @offset 0x7930
    HoveredItem: TItem; // @offset 0x7934  Borrowed.
    SatellitePanelNeedsLayout: Boolean; // @offset 0x7938
    SatelliteMovementTimer: PCallbackTimerGI; // @offset 0x793C
    ProbeSignalTimer: PCallbackTimerGI; // @offset 0x7940
    ProbeSignalSound: TSoundBufferControl; // @offset 0x7944  Owned looping sound controller; fades when the deployed-probe count changes.
    ProbeSignalCount: Integer; // @offset 0x7948
    HeldSatellite: TSatellite; // @offset 0x794C  Temporarily removed from the inventory/deployed list.
    HeldSatelliteOrigin: Integer; // @offset 0x7950  0: inventory; 1: deployed list. Preserved while dragging.
    HoveringSurfaceLoot: Boolean; // @offset 0x7954
    NewSurfaceLootDiscovered: Boolean; // @offset 0x7955

    constructor Create; // @addr 0x7E5204
    destructor Destroy; override; // @addr 0x7E525C
    procedure InitializeLayout; override; // @addr 0x7E52B4
    procedure OnOpen; override; // @addr 0x7E5BDC
    procedure OnClose; override; // @addr 0x7E5D60
    procedure TakeoffClicked(Sender: TObjectGI); // @addr 0x7E5DF8
    procedure RefreshPlanetInfo; // @addr 0x7E646C
    procedure RefreshTextQuestPrompt; // @addr 0x7E688C
    procedure StartTextQuest(Sender: TObjectGI); // @addr 0x7E62EC
    procedure EndTurnClicked(Sender: TObjectGI); // @addr 0x7E7080
    procedure ShipClicked(Sender: TObjectGI); // @addr 0x7E7178
    procedure GalaxyClicked(Sender: TObjectGI); // @addr 0x7E7204
    procedure QuestClicked(Sender: TObjectGI); // @addr 0x7E725C
    procedure ToggleResearchPanel(Sender: TObjectGI); // @addr 0x7E72B4
    procedure OpenResearchPanel; // @addr 0x7E730C
    procedure CloseResearchPanel; // @addr 0x7E7674 @note "Returns a held probe to its origin list before destroying research controls."
    procedure BuildTrajectory(TrajectoryIndex: Integer); // @addr 0x7E77C8 @note "Requires index 0..5 and an empty point count. Builds at most 256 points from connected image markers."
    function GetRandomTrajectoryPoint(TrajectoryIndex: Integer): TPoint; // @addr 0x7E8014 @note "Requires a nonempty trajectory."
    function ProjectPointOntoTrajectory(TrajectoryIndex: Integer; Point: TPoint): TPoint; // @addr 0x7E808C @note "Requires a trajectory spanning a positive X range. Result is untouched if no segment matches."
    function AdvanceTrajectoryPoint(TrajectoryIndex: Integer; Point: TPoint): TPoint; // @addr 0x7E8304 @note "Advances four pixels along the projected segment; Result is untouched if no segment matches."
    function FindTrajectoryAtCursor: Integer; // @addr 0x7E85AC @note "Returns -1 on a miss; searches only the current planet's available probe orbits."
    function IsCursorOverTrajectory(TrajectoryIndex: Integer): Boolean; // @addr 0x7E8604
    procedure ResearchMapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7E86F0
    procedure ResearchMapMouseLeave(Sender: TObjectGI); // @addr 0x7E8C48
    procedure RefreshResearchPanel; // @addr 0x7E8E74
    procedure ScrollSatellitePageLeft(Sender: TObjectGI); // @addr 0x7EA8D4
    procedure ScrollSatellitePageRight(Sender: TObjectGI); // @addr 0x7EA908
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x7EA948
    procedure MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7EA988
    procedure SatelliteInventoryMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7EAA54
    procedure ResearchMapMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7EAC98 @note "Collects accessible surface loot or exchanges the held probe with the selected orbit."
    procedure MainPanelRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x7EB1FC
    procedure UpdateActionCursor(ForceHand: Boolean); override; // @addr 0x7EB234
    procedure ReturnHeldSatellite; // @addr 0x7EB408
    function FindDeployedSatellite(TrajectoryIndex: Integer): TSatellite; // @addr 0x7EB4EC @note "Borrowed probe on the current planet, or nil; -1 always returns nil."
    function CountDeployedSatellites: Integer; // @addr 0x7EB568
    procedure AdvanceSatelliteMarkers(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7EB5C8
    procedure UpdateProbeSignalSound(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7EB680
    procedure UpdateItemInfoPopup(Item: TItem); // @addr 0x7EB900 @note "Borrows Item; nil schedules a delayed hide."
    procedure ShowGoodsInfoPopup(Item: TGoods); // @addr 0x7EC2F8
    procedure HideItemInfoPopup(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x7EC784
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x7EC7EC
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x7EC9E4
    procedure SelectMusic; override; // @addr 0x7ECA58
  end;

const
  ProbeTrajectoryHitRadiusSquared: Single = 400.0; // @addr $87CD28

implementation

uses Windows, aTranclucator, aRanger, fPlanetQuest, fShip2, fStarMap, fSaveManager, aSaveLoad, GI_MessageBox, GR_Main, Classes, GI_GraphBuf, GI_GAI, GI_GraphButton, EC_Str, GR_GraphBuf, GI_GI, EC_Mem, SysUtils, Math, aGalaxy, aGalaxyStruct, aPlayer, aPlanet, aShip, aConst, aScript,
  aMyFunction, GI_Main, GI_Panel, Globals, GlobalsV, GR_Music, SE_Planet,
  ThreadCalc, aCalc;

type
  PProbeMarkerPixel = ^TProbeMarkerPixel;
  TProbeMarkerPixel = record
    X, Y: Integer;
    Pixel: PCardinal;
    Visited: PByte;
  end;

{ @routine $7E5204 TfPlanetNO_Create }
constructor TfPlanetNO.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $7E5204 }

{ @routine $7E525C TfPlanetNO_Destroy }
destructor TfPlanetNO.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $7E525C }

{ @routine $7E52B4 TfPlanetNO_InitializeLayout }
procedure TfPlanetNO.InitializeLayout;
var I: Integer; LargeBackground: Boolean;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fPlanetNO... ');
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('PlanetBG') do
    begin
      LargeBackground := (ClientSize.X > 1024) or (ClientSize.Y > 768);
      if LargeBackground then
      begin
        SetPosition(Classes.Point(0,0));
        SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
      end
      else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    end;
    with FindByNameRecursive('CockpitImage') as TImageGI do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
      SetImagePath(GetImagePath);
      SetActive(not LargeBackground);
    end;
    with FindByNameRecursive('PanelResearch') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('ButResearch').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('PanelInfo') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y));
    with FindByNameRecursive('QuestInfo') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y + ExtraScreenWidth));
  end;
  AppendLogLineThreadSafe('ok');
  with GetByName('MainPanel') do
  begin
    MouseMoveCallback := MainPanelMouseMove;
    RightButtonDownCallback := MainPanelRightButtonDown;
  end;
  (GetByName('ButTakeoff') as TGraphButtonGI).UpCallback := TakeoffClicked;
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  (GetByName('PM_Gal') as TGraphButtonGI).UpCallback := GalaxyClicked;
  (GetByName('PM_Quest') as TGraphButtonGI).UpCallback := QuestClicked;
  (GetByName('ButResearch') as TGraphButtonGI).UpCallback := ToggleResearchPanel;
  (GetByName('ButClose') as TGraphButtonGI).UpCallback := ToggleResearchPanel;
  with GetByName('PanelPath') do
  begin
    MouseMoveCallback := ResearchMapMouseMove;
    MouseLeaveCallback := ResearchMapMouseLeave;
    LeftButtonDownCallback := ResearchMapMouseDown;
  end;
  (GetByName('ButLeft') as TGraphButtonGI).UpCallback := ScrollSatellitePageLeft;
  (GetByName('ButRight') as TGraphButtonGI).UpCallback := ScrollSatellitePageRight;
  for I := 0 to 5 do
  begin
    SatelliteInventorySlots[I] := GetByName('Slot_' + IntToStr(I) + 'i') as TImageGI;
    SatelliteInventorySlots[I].UserValue := I;
    SatelliteInventorySlots[I].LeftButtonDownCallback := SatelliteInventoryMouseDown;
  end;
  ItemInfoWindow := GetByName('PII') as TWindowGI;
  ItemInfoImage := GetByName('InfoImage') as TImageGI;
  ItemInfoNameLabel := GetByName('InfoName') as TLabelGI;
  ItemInfoTextLabel := GetByName('InfoText') as TLabelGI;
  ItemInfoSizeLabel := GetByName('InfoSize') as TLabelGI;
  ItemInfoCostLabel := GetByName('InfoPrice') as TLabelGI;
  ItemInfoRaceIcon := GetByName('EmRace') as TImageGI;
end;
{ @end $7E52B4 }

{ @routine $7E5BDC TfPlanetNO_OnOpen }
procedure TfPlanetNO.OnOpen;
begin
  SelectMusic;
  MainPanel.OnOpen;
  LoadPanel.OnOpen;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  with GetByName('PlanetBG') as TImageGI do
    SetImagePath('GI,Bm.PlanetBG.' + GetPlayer.CurrentPlanet.Graphic.BackgroundGraph);
  SelectedTrajectoryIndex := -1;
  MainPanel.RebuildMessageButtons(False);
  RefreshPlanetInfo;
  RefreshTextQuestPrompt;
  CloseResearchPanel;
  DispatchPendingScriptRequests;
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm,nil,nil,0);
  Galaxy.PrimeIntegrityChecksum(111);
end;
{ @end $7E5BDC }

{ @routine $7E5D60 TfPlanetNO_OnClose }
procedure TfPlanetNO.OnClose;
begin
  if RequestedScreenId <> screenLoad then Galaxy.CheckIntegrityChecksum(112);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm,nil,nil,0);
  CloseResearchPanel;
  MainPanel.OnClose;
  LoadPanel.OnClose;
  if GetPlayer <> nil then GetPlayer.RefreshStorageBubbles;
  MainPanel.RefreshMoneyAndCargo;
  MainPanel.RebuildMessageButtons(False);
end;
{ @end $7E5D60 }

{ @routine $7E5DF8 TfPlanetNO_TakeoffClicked }
procedure TfPlanetNO.TakeoffClicked(Sender: TObjectGI);
var I: Integer;
begin
  if (TurnCalculationPhase = tcpGalaxyRunning) or (TurnCalculationPhase = tcpPlayerStarRunning) or HasPendingScriptRequests then Exit;
  Galaxy.CheckIntegrityChecksum(129);
  GetPlayer.RefreshDerivedStats(True);
  Galaxy.PrimeIntegrityChecksum(129);
  if (HeldSatellite <> nil) and (HeldSatelliteOrigin = 0) and (GetPlayer.GetCargoFreeSpace < HeldSatellite.Weight) then
  begin
    ShowMessageBoxGI(Self,LocalizedText('FormRuins.ShipOvercharging'),mbgCancel or mbgError);
    Exit;
  end;
  if not GetPlayer.HasPositiveSpeed then
  begin
    if GetPlayer.GetCargoFreeSpace < 0 then
      ShowMessageBoxGI(Self,LocalizedText('FormRuins.ShipOvercharging'),mbgCancel or mbgError)
    else if GetPlayer.GetEngine = nil then
      ShowMessageBoxGI(Self,LocalizedText('FormRuins.NotEngine'),mbgCancel or mbgError)
    else if GetPlayer.GetFuelTanks = nil then
      ShowMessageBoxGI(Self,LocalizedText('FormRuins.NotFuelTank'),mbgCancel or mbgError);
    Exit;
  end;
  if GetPlayer.HasSatelliteOnPlanet(GetPlayer.CurrentPlanet) and
    (ShowMessageBoxGI(Self,FormatText1(LanguageDataConfig.GetParamByPathOrMarker('FormPlanetNO.SatelliteInPlanet'),
      '<color=255,240,100>','<Name>',GetPlayer.CurrentPlanet.Name),mbgOK or mbgCancel) <> mbgResultOK) then Exit;
  Galaxy.CheckIntegrityChecksum(113);
  CloseResearchPanel;
  ReturnHeldSatellite;
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath,'as');
  PruneExpiredPersistentPlayerMessages;
  GetPlayer.OrderTakeoff;
  for I := 0 to Galaxy.Scripts.Count - 1 do TScript(Galaxy.Scripts[I]).RunTurnCode;
  StarMapScreen.SetMapCenterManually(TruncatePointF(GetPlayer.Position));
  PlayerStar.RefreshSpaceObjectPositions;
  RunGlobalScriptsForContext(GetPlayer.CurrentStar,1);
  if (GetPlayer <> nil) and GetPlayer.IsHealthEffectActive(3) then Galaxy.EnableDominatorSurfaces
  else Galaxy.DisableDominatorSurfaces;
  CalculatePlayerStarTurnAndWait;
  if not ExitScreenLoop then
    if GetPlayer = nil then
    begin
      RequestedScreenId := screenGameEnd;
      RequestClose(1);
    end
    else
    begin
      CalculateGalaxyTurnAndWait;
      StarMapWeaponPanelOpen := False;
      StarMapScreen.ResumeMode := smrTurnFilm;
      ScreenLoadMode := 2;
      PostLoadScreenId := screenStarMap;
      RequestedScreenId := screenLoad;
      LoadPanel.SelectBackgroundStyle(0);
      LoadPanel.RefreshBackgroundImages;
      LoadPanel.StartClosingShutters;
    end;
end;
{ @end $7E5DF8 }

{ @routine $7E62EC TfPlanetNO_StartTextQuest }
procedure TfPlanetNO.StartTextQuest(Sender: TObjectGI);
begin
  if LoadPanel.IsAnimatingShutters then Exit;
  if (Sender.UserValue <> 0) and
    (ShowMessageBoxGI(Self,LocalizedText('FormGov.QuestCertificate.NotCertificateAttention'),mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK) then Exit;
  Galaxy.CheckIntegrityChecksum(114);
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath,'as');
  StandaloneQuestMode := False;
  QuestReturnScreenId := FormToId(Self);
  RequestedScreenId := screenPlanetQuest;
  RequestClose(1);
end;
{ @end $7E62EC }

{ @routine $7E646C TfPlanetNO_RefreshPlanetInfo }
procedure TfPlanetNO.RefreshPlanetInfo;
var Window: TWindowGI;
begin
  Window := GetByName('PanelInfo') as TWindowGI;
  with GetByName('PanelInfo_Name') as TLabelGI do
    SetText(ReplaceColoredToken(LocalizedText('Planet.Civil.Info.TextNamePlanet'),'<Planet>',GetPlayer.CurrentPlanet.Name,InfoNameColorTag));
  with GetByName('PanelInfo_Text') as TLabelGI do
  begin
    SetText(GetPlayer.CurrentPlanet.GetInfoText(False));
    Window.SetSize(Classes.Point(ClientSize.X + Window.WorkSubRect.Left + Window.WorkSubRect.Right,ClientSize.Y + Window.WorkSubRect.Top + Window.WorkSubRect.Bottom));
    Window.UpdateAutoGeometry;
    Window.SetActive(True);
    SetPosition(Window.WorkSubRect.TopLeft);
  end;
  with GetByName('PanelInfo_Image') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    GetPlayer.CurrentPlanet.Graphic.RenderToBuffer(Self,GraphBuf,False);
    if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
      GraphBuf.RescaleRgba(ClientSize.X,Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)),5)
    else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)),ClientSize.Y,5);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  ShipScreen.LayoutItemInfo(Window,GetByName('PanelInfo_Name') as TLabelGI,GetByName('PanelInfo_Text') as TLabelGI,True,True,0);
  with GetByName('PanelInfo_Name') as TLabelGI do
    SetSize(Classes.Point(Window.ClientSize.X - LocalPosition.X - Window.WorkSubRect.Right,ClientSize.Y));
  Window.SetPosition(Classes.Point(GameScreenWidth - 10 - Window.ClientSize.X,10));
end;
{ @end $7E646C }

{ @routine $7E688C TfPlanetNO_RefreshTextQuestPrompt }
procedure TfPlanetNO.RefreshTextQuestPrompt;
var
  Window: TWindowGI;
  QuestId, I: Integer;
  Quest: PQuest;
  Text: WideString;
begin
  QuestId := -1;
  Window := GetByName('QuestInfo') as TWindowGI;
  Quest := nil;
  Window.SetActive(False);
  if (GetPlayer.CurrentPlanet.TextQuestId > -1) and (GetPlayer.Quests.Count > 0) then
    for I := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := PQuest(GetPlayer.Quests[I]);
      if (Quest.QuestType = qtPlanetQuest) and (Quest.ObjectiveTarget is TPlanet) and
        (GetPlayer.CurrentPlanet = (Quest.ObjectiveTarget as TPlanet)) and
        (LanguageDataConfig.GetBlockByPath('PlanetQuest.PlanetQuest').CountParams(IntToStr(Quest.QuestNumber)) > 0) then
      begin
        QuestId := Quest.QuestNumber;
        if (Quest.QuestNumber < 10000) or
          ((LanguageDataConfig.GetBlock('PlanetQuest').CountBlocks('PlanetQuestLic') > 0) and
           (LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuestLic').GetParamOrMarker(IntToStr(Quest.QuestNumber)) = PlanetQuestScreen.GetQuestContentHash(Quest.QuestNumber))) then
          Window.FindByNameRecursive('QuestInfo_Run').UserValue := 0
        else Window.FindByNameRecursive('QuestInfo_Run').UserValue := 1;
        Window.SetActive(True);
        Break;
      end;
    end;
  if Window.Active then
  begin
    with GetByName('QuestInfo_Name') as TLabelGI do
      SetText(LocalizedText('PlanetQuest.StartText.QuestCaption'));
    with GetByName('QuestInfo_Text') as TLabelGI do
    begin
      Text := LocalizedColorText('PlanetQuest.StartText.' + IntToStr(QuestId));
      if Text = WideString('') then Text := LocalizedColorText('PlanetQuest.StartText.QuestExtern');
      if Quest <> nil then
      begin
        ReplaceTextToken(Text,'<CurPlanet>',(Quest.ObjectiveTarget as TPlanet).Name,'<color=255,240,100>');
        ReplaceTextToken(Text,'<CurStar>',(Quest.ObjectiveTarget as TPlanet).CurrentStar.Name,'<color=255,240,100>');
        ReplaceTextToken(Text,'<FromPlanet>',Quest.Planet.Name,'<color=255,240,100>');
        ReplaceTextToken(Text,'<FromStar>',Quest.Planet.CurrentStar.Name,'<color=255,240,100>');
      end;
      SetText(Text);
      Window.SetSize(Classes.Point(ClientSize.X + Window.WorkSubRect.Left + Window.WorkSubRect.Right,ClientSize.Y + Window.WorkSubRect.Top + Window.WorkSubRect.Bottom));
      Window.UpdateAutoGeometry;
      Window.SetActive(True);
      SetPosition(Window.WorkSubRect.TopLeft);
    end;
    ShipScreen.LayoutItemInfo(Window,GetByName('QuestInfo_Name') as TLabelGI,GetByName('QuestInfo_Text') as TLabelGI,True,True,0);
    with GetByName('QuestInfo_Run') as TGraphButtonGI do
    begin
      UpCallback := StartTextQuest;
      Window.SetSize(Classes.Point(Window.ClientSize.X,GiScalePixels(5) + (ClientSize.Y + Window.ClientSize.Y)));
      Window.UpdateAutoGeometry;
      SetPosition(Classes.Point(Window.ClientSize.X div 2 - ClientSize.X div 2,Window.ClientSize.Y - GiScalePixels(10) - ClientSize.Y));
    end;
    with GetByName('QuestInfo_Name') as TLabelGI do
      SetSize(Classes.Point(Window.ClientSize.X - LocalPosition.X - Window.WorkSubRect.Right,ClientSize.Y));
    Window.SetPosition(Classes.Point(GameScreenWidth - 10 - Window.ClientSize.X,GameScreenHeight - GiScalePixels(90) - Window.ClientSize.Y));
  end;
end;
{ @end $7E688C }

{ @routine $7E7080 TfPlanetNO_EndTurnClicked }
procedure TfPlanetNO.EndTurnClicked(Sender: TObjectGI);
begin
  if LoadPanel.IsAnimatingShutters then Exit;
  Galaxy.CheckIntegrityChecksum(115);
  if ResearchPanelVisible then
  begin
    ReturnHeldSatellite;
    HideItemInfoPopup(nil,0);
  end;
  MainPanel.EndTurnClicked(Sender);
  RefreshPlanetInfo;
  RefreshTextQuestPrompt;
  Galaxy.PrimeIntegrityChecksum(116);
  MainPanel.RebuildMessageButtons(False);
  if ResearchPanelVisible then
  begin
    RefreshResearchPanel;
    if NewSurfaceLootDiscovered then SoundManager.PlaySound('Sound.ProbeExplore');
  end;
end;
{ @end $7E7080 }

{ @routine $7E7178 TfPlanetNO_ShipClicked }
procedure TfPlanetNO.ShipClicked(Sender: TObjectGI);
begin
  if ResearchPanelVisible then
  begin
    ReturnHeldSatellite;
    HideItemInfoPopup(nil,0);
  end;
  MainPanel.ShipClicked(Sender);
  if (ExitCode = 0) and ResearchPanelVisible then
  begin
    Galaxy.CheckIntegrityChecksum(777);
    GetPlayer.AssignSatelliteIndicesFromHoldOrder;
    Galaxy.PrimeIntegrityChecksum(774);
    RefreshResearchPanel;
  end;
end;
{ @end $7E7178 }

{ @routine $7E7204 TfPlanetNO_GalaxyClicked }
procedure TfPlanetNO.GalaxyClicked(Sender: TObjectGI);
begin
  if ResearchPanelVisible then
  begin
    ReturnHeldSatellite;
    HideItemInfoPopup(nil,0);
  end;
  MainPanel.GalaxyClicked(Sender);
  if ResearchPanelVisible then RefreshResearchPanel;
end;
{ @end $7E7204 }

{ @routine $7E725C TfPlanetNO_QuestClicked }
procedure TfPlanetNO.QuestClicked(Sender: TObjectGI);
begin
  if ResearchPanelVisible then
  begin
    ReturnHeldSatellite;
    HideItemInfoPopup(nil,0);
  end;
  MainPanel.QuestClicked(Sender);
  if ResearchPanelVisible then RefreshResearchPanel;
end;
{ @end $7E725C }

{ @routine $7E72B4 TfPlanetNO_ToggleResearchPanel }
procedure TfPlanetNO.ToggleResearchPanel(Sender: TObjectGI);
begin
  if GetByName('PanelResearch').Active then CloseResearchPanel else OpenResearchPanel;
end;
{ @end $7E72B4 }

{ @routine $7E730C TfPlanetNO_OpenResearchPanel }
procedure TfPlanetNO.OpenResearchPanel;
var I, Parts: Integer;
begin
  SatelliteInventoryPageStart := 0;
  SatellitePanelNeedsLayout := True;
  Galaxy.CheckIntegrityChecksum(117);
  GetPlayer.RepairDuplicateSatelliteTrajectoryIndices;
  GetPlayer.CompactSatelliteTrajectoryIndices;
  GetPlayer.AssignSatelliteIndicesFromHoldOrder;
  Galaxy.PrimeIntegrityChecksum(118);
  ResearchPanelVisible := True;
  for I := 0 to 5 do
    if TrajectoryPointCounts[I] = 0 then BuildTrajectory(I);
  GetByName('PanelResearch').SetActive(True);
  RefreshResearchPanel;
  HoveredItem := nil;
  HoveringSurfaceLoot := False;
  with GetByName('PlanetImage') as TGraphBufGI do
  begin
    Parts := CountDelimitedPartsW(GetPlayer.CurrentPlanet.Graphic.ImagePath,'.');
    LoadBitmapPathAsRgb('Bm.PUMaps.' + ExtractDelimitedPartW(GetPlayer.CurrentPlanet.Graphic.ImagePath,Parts - 1,'.') + '?RGB');
    if GiResourceVariant = 1 then
      GraphBuf.RescaleRgb(Round(Cardinal(GraphBuf.Width) * 800 / 1024),Round(Cardinal(GraphBuf.Height) * 800 / 1024));
    GraphBuf.ConvertRgbTo565;
  end;
  if SatelliteMovementTimer <> nil then
  begin
    CancelCallbackTimer(SatelliteMovementTimer);
    SatelliteMovementTimer := nil;
  end;
  SatelliteMovementTimer := ScheduleCallbackTimer(30,30,AdvanceSatelliteMarkers);
  ProbeSignalCount := 0;
  if ProbeSignalTimer <> nil then
  begin
    CancelCallbackTimer(ProbeSignalTimer);
    ProbeSignalTimer := nil;
  end;
  ProbeSignalTimer := ScheduleCallbackTimer(20,20,UpdateProbeSignalSound);
  with GetByName('Scan') as TgaiGI do
  begin
    SetSize(GetContentSize);
    SequenceIndex := 0;
    UpdateAutoGeometry;
  end;
end;
{ @end $7E730C }

{ @routine $7E7674 TfPlanetNO_CloseResearchPanel }
procedure TfPlanetNO.CloseResearchPanel;
begin
  if ProbeSignalSound <> nil then
  begin
    ProbeSignalSound.Free;
    ProbeSignalSound := nil;
  end;
  if SatelliteMovementTimer <> nil then
  begin
    CancelCallbackTimer(SatelliteMovementTimer);
    SatelliteMovementTimer := nil;
  end;
  if ProbeSignalTimer <> nil then
  begin
    CancelCallbackTimer(ProbeSignalTimer);
    ProbeSignalTimer := nil;
  end;
  ReturnHeldSatellite;
  GetByName('PanelResearch').SetActive(False);
  ResearchMapMouseLeave(nil);
  GetByName('PanelSatellite').FreeOwnedChildren;
  GetByName('PanelItems').FreeOwnedChildren;
  HoveredItem := nil;
  HoveringSurfaceLoot := False;
  HideItemInfoPopup(nil,0);
  ResearchPanelVisible := False;
end;
{ @end $7E7674 }

{ @routine $7E77C8 TfPlanetNO_BuildTrajectory }
procedure TfPlanetNO.BuildTrajectory(TrajectoryIndex: Integer);
var
  Buffer: TGraphBufGR;
  I, J, X, Y, NeighborX, NeighborY, SumX, SumY, OffsetX, OffsetY: Integer;
  Pixel, NeighborPixel: PCardinal;
  Visited, CursorVisited, NeighborVisited: PByte;
  Queue, ReadNode, WriteNode: PProbeMarkerPixel;
  Count, ReadCount: Integer;
  InverseLength: Single;
  Swap: TProbeTrajectoryPoint;
begin
  Buffer := TGraphBufGR.Create(False);
  LoadGiByPathIntoGraphBuf('Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(TrajectoryIndex + 1),Buffer);
  Visited := AllocClearEC(Buffer.Width * Buffer.Height);
  Queue := AllocClearEC(256 * SizeOf(TProbeMarkerPixel));
  OffsetX := GetByName('W' + IntToStr(TrajectoryIndex)).LocalPosition.X;
  OffsetY := GetByName('W' + IntToStr(TrajectoryIndex)).LocalPosition.Y;
  CursorVisited := Visited;
  Pixel := Buffer.GetPixels;
  for Y := 0 to Buffer.Height - 1 do
  begin
    for X := 0 to Buffer.Width - 1 do
    begin
      if (Pixel^ shr 24 > 32) and (CursorVisited^ = 0) then
      begin
        if TrajectoryPointCounts[TrajectoryIndex] >= 256 then RaiseWideMessage('BuildPath.1');
        SumX := X;
        SumY := Y;
        ReadNode := Queue;
        ReadNode.X := X;
        ReadNode.Y := Y;
        ReadNode.Pixel := Pixel;
        ReadNode.Visited := CursorVisited;
        CursorVisited^ := 1;
        ReadCount := 0;
        Count := 1;
        WriteNode := PProbeMarkerPixel(Cardinal(ReadNode) + SizeOf(TProbeMarkerPixel));
        Pixel^ := $FFFFFFFF;
        while ReadCount < Count do
        begin
          for I := 0 to 3 do
          begin
            NeighborX := ReadNode.X;
            NeighborY := ReadNode.Y;
            NeighborVisited := ReadNode.Visited;
            NeighborPixel := ReadNode.Pixel;
            case I of
              0:
                begin
                  Inc(NeighborX);
                  if Buffer.Width <= NeighborX then Continue;
                  NeighborVisited := PByte(Cardinal(NeighborVisited) + 1);
                  NeighborPixel := PCardinal(Cardinal(NeighborPixel) + 4);
                end;
              1:
                begin
                  Dec(NeighborX);
                  if NeighborX < 0 then Continue;
                  NeighborVisited := PByte(Cardinal(NeighborVisited) - 1);
                  NeighborPixel := PCardinal(Cardinal(NeighborPixel) - 4);
                end;
              2:
                begin
                  Inc(NeighborY);
                  if Buffer.Height <= NeighborY then Continue;
                  NeighborVisited := PByte(Cardinal(NeighborVisited) + Cardinal(Buffer.Width));
                  NeighborPixel := PCardinal(Cardinal(NeighborPixel) + Cardinal(Buffer.PitchBytes));
                end;
              3:
                begin
                  Dec(NeighborY);
                  if NeighborY < 0 then Continue;
                  NeighborVisited := PByte(Cardinal(NeighborVisited) - Cardinal(Buffer.Width));
                  NeighborPixel := PCardinal(Cardinal(NeighborPixel) - Cardinal(Buffer.PitchBytes));
                end;
            end;
            if (NeighborPixel^ shr 24 > 32) and (NeighborVisited^ = 0) then
            begin
              if Count >= 256 then RaiseWideMessage('BuildPath.2');
              Inc(SumX,NeighborX);
              Inc(SumY,NeighborY);
              WriteNode.X := NeighborX;
              WriteNode.Y := NeighborY;
              WriteNode.Visited := NeighborVisited;
              WriteNode.Pixel := NeighborPixel;
              WriteNode := PProbeMarkerPixel(Cardinal(WriteNode) + SizeOf(TProbeMarkerPixel));
              NeighborVisited^ := 1;
              Inc(Count);
              NeighborPixel^ := $FF800000;
            end;
          end;
          ReadNode := PProbeMarkerPixel(Cardinal(ReadNode) + SizeOf(TProbeMarkerPixel));
          Inc(ReadCount);
        end;
        Trajectories[TrajectoryIndex][TrajectoryPointCounts[TrajectoryIndex]].Position.X := SumX / Count + OffsetX;
        Trajectories[TrajectoryIndex][TrajectoryPointCounts[TrajectoryIndex]].Position.Y := SumY / Count + OffsetY;
        Inc(TrajectoryPointCounts[TrajectoryIndex]);
      end;
      Pixel := PCardinal(Cardinal(Pixel) + 4);
      CursorVisited := PByte(Cardinal(CursorVisited) + 1);
    end;
    Pixel := PCardinal(Cardinal(Pixel) + Cardinal(Buffer.PitchBytes - 4 * Buffer.Width));
  end;
  for I := 0 to TrajectoryPointCounts[TrajectoryIndex] - 2 do
    for J := I + 1 to TrajectoryPointCounts[TrajectoryIndex] - 1 do
      if Trajectories[TrajectoryIndex][J].Position.X < Trajectories[TrajectoryIndex][I].Position.X then
      begin
        Swap := Trajectories[TrajectoryIndex][J];
        Trajectories[TrajectoryIndex][J] := Trajectories[TrajectoryIndex][I];
        Trajectories[TrajectoryIndex][I] := Swap;
      end;
  for I := 0 to TrajectoryPointCounts[TrajectoryIndex] - 2 do
  begin
    Trajectories[TrajectoryIndex][I].Direction.X := Trajectories[TrajectoryIndex][I + 1].Position.X - Trajectories[TrajectoryIndex][I].Position.X;
    Trajectories[TrajectoryIndex][I].Direction.Y := Trajectories[TrajectoryIndex][I + 1].Position.Y - Trajectories[TrajectoryIndex][I].Position.Y;
    InverseLength := 1 / Sqrt(Sqr(Trajectories[TrajectoryIndex][I].Direction.X) + Sqr(Trajectories[TrajectoryIndex][I].Direction.Y));
    Trajectories[TrajectoryIndex][I].Direction.X := Trajectories[TrajectoryIndex][I].Direction.X * InverseLength;
    Trajectories[TrajectoryIndex][I].Direction.Y := Trajectories[TrajectoryIndex][I].Direction.Y * InverseLength;
  end;
  FreeEC(Queue);
  FreeEC(Visited);
  Buffer.Free;
end;
{ @end $7E77C8 }

{ @routine $7E8014 TfPlanetNO_GetRandomTrajectoryPoint }
function TfPlanetNO.GetRandomTrajectoryPoint(TrajectoryIndex: Integer): TPoint;
var I: Integer;
begin
  I := RandomIntRange(0,TrajectoryPointCounts[TrajectoryIndex] - 1);
  Result.X := Round(Trajectories[TrajectoryIndex][I].Position.X);
  Result.Y := Round(Trajectories[TrajectoryIndex][I].Position.Y);
end;
{ @end $7E8014 }

{ @routine $7E808C TfPlanetNO_ProjectPointOntoTrajectory }
function TfPlanetNO.ProjectPointOntoTrajectory(TrajectoryIndex: Integer; Point: TPoint): TPoint;
var I: Integer; X, Distance, DeltaX, DeltaY: Single;
begin
  X := Point.X;
  while X >= Trajectories[TrajectoryIndex][TrajectoryPointCounts[TrajectoryIndex] - 1].Position.X do
    X := X - (Trajectories[TrajectoryIndex][TrajectoryPointCounts[TrajectoryIndex] - 1].Position.X - Trajectories[TrajectoryIndex][0].Position.X);
  if X < Trajectories[TrajectoryIndex][0].Position.X then X := Trajectories[TrajectoryIndex][0].Position.X;
  for I := 0 to TrajectoryPointCounts[TrajectoryIndex] - 1 do
    if (X >= Trajectories[TrajectoryIndex][I].Position.X) and (X < Trajectories[TrajectoryIndex][I + 1].Position.X) then
    begin
      DeltaX := X - Trajectories[TrajectoryIndex][I].Position.X;
      DeltaY := Point.Y - Trajectories[TrajectoryIndex][I].Position.Y;
      Distance := Trajectories[TrajectoryIndex][I].Direction.X * DeltaX + Trajectories[TrajectoryIndex][I].Direction.Y * DeltaY;
      if Distance < 0 then Distance := 0;
      Result.X := Round(Trajectories[TrajectoryIndex][I].Position.X + Trajectories[TrajectoryIndex][I].Direction.X * Distance);
      Result.Y := Round(Trajectories[TrajectoryIndex][I].Position.Y + Trajectories[TrajectoryIndex][I].Direction.Y * Distance);
      Exit;
    end;
end;
{ @end $7E808C }

{ @routine $7E8304 TfPlanetNO_AdvanceTrajectoryPoint }
function TfPlanetNO.AdvanceTrajectoryPoint(TrajectoryIndex: Integer; Point: TPoint): TPoint;
var I: Integer; X, Distance, DeltaX, DeltaY: Single;
begin
  X := Point.X;
  while X > Trajectories[TrajectoryIndex][TrajectoryPointCounts[TrajectoryIndex] - 1].Position.X do
    X := X - (Trajectories[TrajectoryIndex][TrajectoryPointCounts[TrajectoryIndex] - 1].Position.X - Trajectories[TrajectoryIndex][0].Position.X);
  if X < Trajectories[TrajectoryIndex][0].Position.X then X := Trajectories[TrajectoryIndex][0].Position.X;
  for I := 0 to TrajectoryPointCounts[TrajectoryIndex] - 1 do
    if (X >= Trajectories[TrajectoryIndex][I].Position.X) and (X < Trajectories[TrajectoryIndex][I + 1].Position.X) then
    begin
      DeltaX := X - Trajectories[TrajectoryIndex][I].Position.X;
      DeltaY := Point.Y - Trajectories[TrajectoryIndex][I].Position.Y;
      Distance := Trajectories[TrajectoryIndex][I].Direction.X * DeltaX + Trajectories[TrajectoryIndex][I].Direction.Y * DeltaY;
      if Distance < 0 then Distance := 0;
      Distance := Distance + 4;
      Result.X := Round(Trajectories[TrajectoryIndex][I].Position.X + Trajectories[TrajectoryIndex][I].Direction.X * Distance);
      Result.Y := Round(Trajectories[TrajectoryIndex][I].Position.Y + Trajectories[TrajectoryIndex][I].Direction.Y * Distance);
      Result := ProjectPointOntoTrajectory(TrajectoryIndex,Result);
      Exit;
    end;
end;
{ @end $7E8304 }

{ @routine $7E85AC TfPlanetNO_FindTrajectoryAtCursor }
function TfPlanetNO.FindTrajectoryAtCursor: Integer;
var I: Integer;
begin
  for I := 0 to GetPlayer.CurrentPlanet.ProbeOrbitCount - 1 do
    if IsCursorOverTrajectory(I) then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;
{ @end $7E85AC }

{ @routine $7E8604 TfPlanetNO_IsCursorOverTrajectory }
function TfPlanetNO.IsCursorOverTrajectory(TrajectoryIndex: Integer): Boolean;
var I: Integer; Point: TPoint; X, Y: Single;
begin
  Point := GetByName('PanelPath').ToLocalPoint(GetCursorPoint);
  X := Point.X;
  Y := Point.Y;
  for I := 0 to TrajectoryPointCounts[TrajectoryIndex] - 2 do
    if Sqr(Trajectories[TrajectoryIndex][I].Position.X - X) + Sqr(Trajectories[TrajectoryIndex][I].Position.Y - Y) < ProbeTrajectoryHitRadiusSquared then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;
{ @end $7E8604 }

{ @routine $7E86F0 TfPlanetNO_ResearchMapMouseMove }
procedure TfPlanetNO.ResearchMapMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  I: Integer;
  Entry: PPlanetSurfaceLootEntry;
  Cell: TPoint;
begin
  if GetPlayer.CurrentPlanet.SurfaceLootEntries <> nil then
  begin
    Cell := GetByName('PanelItems').ToLocalPoint(Point);
    Cell.X := Cell.X div GiScalePixelsEx(36,28);
    Cell.Y := Cell.Y div GiScalePixelsEx(36,28);
    for I := 0 to GetPlayer.CurrentPlanet.SurfaceLootEntries.Count - 1 do
    begin
      Entry := GetPlayer.CurrentPlanet.SurfaceLootEntries[I];
      if (Entry.GridX = Cell.X) and (Entry.GridY = Cell.Y) and
        (((Entry.TerrainKind = ptWater) and (GetPlayer.CurrentPlanet.WaterExplored >= Entry.SurfaceTileIndex)) or
         ((Entry.TerrainKind = ptLand) and (GetPlayer.CurrentPlanet.LandExplored >= Entry.SurfaceTileIndex)) or
         ((Entry.TerrainKind = ptHill) and (GetPlayer.CurrentPlanet.HillExplored >= Entry.SurfaceTileIndex))) and not Entry.Unavailable then
      begin
        UpdateItemInfoPopup(Entry.Item);
        HoveringSurfaceLoot := True;
        if (HeldSatellite = nil) and not IsCursorImageSelected('Take') then SetCursorByName('Take');
        if SelectedTrajectoryIndex >= 0 then
        begin
          with GetByName('W' + IntToStr(SelectedTrajectoryIndex)) as TImageGI do
            if (FindDeployedSatellite(SelectedTrajectoryIndex) <> nil) and
              ((FindDeployedSatellite(SelectedTrajectoryIndex).BrokenFlag <> 0) or
               (GetPlayer.GetSatelliteExplorationTurns(FindDeployedSatellite(SelectedTrajectoryIndex)) = 0)) then
              SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(SelectedTrajectoryIndex + 1) + 'B')
            else SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(SelectedTrajectoryIndex + 1));
          SelectedTrajectoryIndex := -1;
        end;
        Exit;
      end;
    end;
  end;
  HoveringSurfaceLoot := False;
  if SelectedTrajectoryIndex < 0 then UpdateItemInfoPopup(nil);
  if (SelectedTrajectoryIndex < 0) or not IsCursorOverTrajectory(SelectedTrajectoryIndex) then
  begin
    I := FindTrajectoryAtCursor;
    if I <> SelectedTrajectoryIndex then
    begin
      ResearchMapMouseLeave(Sender);
      SelectedTrajectoryIndex := I;
      if SelectedTrajectoryIndex >= 0 then
        with GetByName('W' + IntToStr(SelectedTrajectoryIndex)) as TImageGI do
          SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(SelectedTrajectoryIndex + 1) + 'A');
      UpdateItemInfoPopup(FindDeployedSatellite(SelectedTrajectoryIndex));
      UpdateActionCursor(False);
    end;
  end;
end;
{ @end $7E86F0 }

{ @routine $7E8C48 TfPlanetNO_ResearchMapMouseLeave }
procedure TfPlanetNO.ResearchMapMouseLeave(Sender: TObjectGI);
begin
  if SelectedTrajectoryIndex >= 0 then
  begin
    with GetByName('W' + IntToStr(SelectedTrajectoryIndex)) as TImageGI do
      if (FindDeployedSatellite(SelectedTrajectoryIndex) <> nil) and
        ((FindDeployedSatellite(SelectedTrajectoryIndex).BrokenFlag <> 0) or
        (GetPlayer.GetSatelliteExplorationTurns(FindDeployedSatellite(SelectedTrajectoryIndex)) = 0)) then
        SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(SelectedTrajectoryIndex + 1) + 'B')
      else SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(SelectedTrajectoryIndex + 1));
    SelectedTrajectoryIndex := -1;
  end;
  UpdateItemInfoPopup(nil);
  UpdateActionCursor(False);
end;
{ @end $7E8C48 }

{ @routine $7E8E74 TfPlanetNO_RefreshResearchPanel }
procedure TfPlanetNO.RefreshResearchPanel;
var
  I: Integer;
  InventorySatellite, Satellite: TSatellite;
  WaterRate, LandRate, HillRate: Integer;
  Child: TImageGI;
  OldChild: TObjectGI;
  Panel: TPanelGI;
  Entry: PPlanetSurfaceLootEntry;
  Undiscovered: Boolean;
begin
  NewSurfaceLootDiscovered := False;
  with GetByName('Scan') as TgaiGI do
  begin
    SetActive(CountDeployedSatellites > 0);
    if Active then RestartPlayback;
  end;
  (GetByName('Caption') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Caption'),'<Name>',GetPlayer.CurrentPlanet.Name,''));
  for I := 0 to 5 do
    with GetByName('W' + IntToStr(I)) as TImageGI do
    begin
      SetActive(GetPlayer.CurrentPlanet.ProbeOrbitCount > I);
      if Active then
        if SelectedTrajectoryIndex = I then
          SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(I + 1) + 'A')
        else if (FindDeployedSatellite(I) <> nil) and
          ((FindDeployedSatellite(I).BrokenFlag <> 0) or (GetPlayer.GetSatelliteExplorationTurns(FindDeployedSatellite(I)) = 0)) then
          SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(I + 1) + 'B')
        else SetImagePath('GI,Bm.FormUnknown2.' + GiResourceSuffix + 'W' + IntToStr(I + 1));
    end;
  Galaxy.CheckIntegrityChecksum(119);
  Panel := GetByName('PanelItems') as TPanelGI;
  Child := TImageGI(Panel.FirstChild);
  while Child <> nil do
  begin
    OldChild := Child;
    Child := TImageGI(Child.NextSibling);
    Entry := PPlanetSurfaceLootEntry(OldChild.UserValue);
    if (GetPlayer.CurrentPlanet.SurfaceLootEntries = nil) or (GetPlayer.CurrentPlanet.SurfaceLootEntries.IndexOf(Entry) < 0) then
    begin
      OldChild.Invalidate;
      OldChild.Free;
    end;
  end;
  if GetPlayer.CurrentPlanet.SurfaceLootEntries <> nil then
    for I := 0 to GetPlayer.CurrentPlanet.SurfaceLootEntries.Count - 1 do
    begin
      Entry := GetPlayer.CurrentPlanet.SurfaceLootEntries[I];
      Undiscovered := False;
      if ((((Entry.TerrainKind = ptWater) and (GetPlayer.CurrentPlanet.WaterExplored >= Entry.SurfaceTileIndex)) or
           ((Entry.TerrainKind = ptLand) and (GetPlayer.CurrentPlanet.LandExplored >= Entry.SurfaceTileIndex)) or
           ((Entry.TerrainKind = ptHill) and (GetPlayer.CurrentPlanet.HillExplored >= Entry.SurfaceTileIndex))) and not Entry.Unavailable) or
         ((GetPlayer.CountActiveArtefacts(Ord(t_ArtefactAnalyzer)) > 0) and (Entry.Item is TEquipmentWithActCode) and TEquipmentWithActCode(Entry.Item).DisplayAsArtefact) then
      begin
        if not (((Entry.TerrainKind = ptWater) and (GetPlayer.CurrentPlanet.WaterExplored >= Entry.SurfaceTileIndex)) or
                ((Entry.TerrainKind = ptLand) and (GetPlayer.CurrentPlanet.LandExplored >= Entry.SurfaceTileIndex)) or
                ((Entry.TerrainKind = ptHill) and (GetPlayer.CurrentPlanet.HillExplored >= Entry.SurfaceTileIndex))) then Undiscovered := True;
        Child := TImageGI(Panel.FirstChild);
        while Child <> nil do
        begin
          if Pointer(Child.UserValue) = Entry then Break;
          Child := TImageGI(Child.NextSibling);
        end;
        if Child = nil then
        begin
          with TImageGI.Create(Panel) do
          begin
            UserValue := Integer(Entry);
            if not Undiscovered then
            begin
              if Entry.Item is TGoods then SetImagePath('GI,' + Entry.Item.GetBitmapResourceName)
              else SetImagePath('GI,' + Entry.Item.GetBitmapResourceName + 's');
            end
            else SetImagePath('GI,' + Entry.Item.GetBitmapResourceName + 'ab');
            SetSize(GetContentSize);
            SetOrigin(HalfPoint(ClientSize));
            SetPosition(Classes.Point(Entry.GridX * GiScalePixelsEx(36,28) + GiScalePixelsEx(36,28) div 2,
              Entry.GridY * GiScalePixelsEx(36,28) + GiScalePixelsEx(36,28) div 2));
          end;
        end
        else if not (Entry.Item is TGoods) then
          if (Child.GetImagePath <> 'GI,' + Entry.Item.GetBitmapResourceName + 's') and not Undiscovered then
          begin
            Child.SetImagePath('GI,' + Entry.Item.GetBitmapResourceName + 's');
            Child.SetSize(Child.GetContentSize);
            Child.SetOrigin(HalfPoint(Child.ClientSize));
            Child.SetPosition(Classes.Point(Entry.GridX * GiScalePixelsEx(36,28) + GiScalePixelsEx(36,28) div 2,
              Entry.GridY * GiScalePixelsEx(36,28) + GiScalePixelsEx(36,28) div 2));
            NewSurfaceLootDiscovered := True;
          end;
      end;
    end;
  Galaxy.PrimeIntegrityChecksum(120);
  Panel := GetByName('PanelSatellite') as TPanelGI;
  Child := TImageGI(Panel.FirstChild);
  while Child <> nil do
  begin
    OldChild := Child;
    Child := TImageGI(Child.NextSibling);
    Satellite := TSatellite(OldChild.UserValue);
    if (GetPlayer.Satellites.IndexOf(Satellite) < 0) or (GetPlayer.CurrentPlanet <> Satellite.TargetPlanet) then
    begin
      OldChild.Invalidate;
      OldChild.Free;
    end;
  end;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
  begin
    Satellite := TSatellite(GetPlayer.Satellites[I]);
    if GetPlayer.CurrentPlanet = Satellite.TargetPlanet then
    begin
      Child := TImageGI(Panel.FirstChild);
      while Child <> nil do
      begin
        if Pointer(Child.UserValue) = Satellite then Break;
        Child := TImageGI(Child.NextSibling);
      end;
      if Child = nil then
      begin
        if not AnimItem then
        begin
          with TImageGI.Create(Panel) do
          begin
            UserValue := Integer(Satellite);
            SetImagePath('GI,' + Satellite.GetBitmapResourceName + 's');
            SetSize(GetContentSize);
            SetOrigin(HalfPoint(ClientSize));
            if SatellitePanelNeedsLayout then SetPosition(GetRandomTrajectoryPoint(Satellite.TrajectoryIndex))
            else SetPosition(ProjectPointOntoTrajectory(Satellite.TrajectoryIndex,Panel.ToLocalPoint(GetCursorPoint)));
          end;
        end
        else
        begin
          with TgaiGI.Create(Panel) do
          begin
            UserValue := Integer(Satellite);
            SetImagePath(Satellite.GetBitmapResourceName + 'a');
            SequenceIndex := 0;
            UpdateAutoGeometry;
            SetSize(GetContentSize);
            SetOrigin(HalfPoint(ClientSize));
            RestartPlayback;
            if SatellitePanelNeedsLayout then SetPosition(GetRandomTrajectoryPoint(Satellite.TrajectoryIndex))
            else SetPosition(ProjectPointOntoTrajectory(Satellite.TrajectoryIndex,Panel.ToLocalPoint(GetCursorPoint)));
          end;
        end;
      end;
    end;
  end;
  SatellitePanelNeedsLayout := False;
  Galaxy.CheckIntegrityChecksum(1117);
  GetPlayer.RepairDuplicateSatelliteTrajectoryIndices;
  Galaxy.PrimeIntegrityChecksum(1118);
  for I := 0 to 5 do
  begin
    InventorySatellite := GetPlayer.FindSatelliteByTrajectoryIndex(SatelliteInventoryPageStart + I);
    with GetByName('Slot_' + IntToStr(I) + 'i') as TImageGI do
      if InventorySatellite = nil then SetImagePath('')
      else
      begin
        SetImagePath('GI,' + InventorySatellite.GetBitmapResourceName + 's');
        SetImageKindX(ikxCenter);
        SetImageKindY(ikyCenter);
      end;
  end;
  (GetByName('ButLeft') as TGraphButtonGI).SetDisabled(SatelliteInventoryPageStart <= 0);
  (GetByName('ButRight') as TGraphButtonGI).SetDisabled(GetPlayer.GetSatelliteTrajectoryIndexLimit < SatelliteInventoryPageStart + 6);
  (GetByName('WaterSpace') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Space'),'<val>',IntToStr(GetPlayer.CurrentPlanet.WaterTiles),'<color=0,50,200>'));
  (GetByName('LandSpace') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Space'),'<val>',IntToStr(GetPlayer.CurrentPlanet.LandTiles),'<color=0,50,200>'));
  (GetByName('HillSpace') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Space'),'<val>',IntToStr(GetPlayer.CurrentPlanet.HillTiles),'<color=0,50,200>'));
  (GetByName('WaterComplate') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Complate'),'<val>',IntToStr(GetPlayer.CurrentPlanet.WaterExplored),'<color=0,50,200>'));
  (GetByName('LandComplate') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Complate'),'<val>',IntToStr(GetPlayer.CurrentPlanet.LandExplored),'<color=0,50,200>'));
  (GetByName('HillComplate') as TLabelGI).SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.Complate'),'<val>',IntToStr(GetPlayer.CurrentPlanet.HillExplored),'<color=0,50,200>'));
  WaterRate := 0;
  LandRate := 0;
  HillRate := 0;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
  begin
    Satellite := TSatellite(GetPlayer.Satellites[I]);
    if (GetPlayer.CurrentPlanet = Satellite.TargetPlanet) and (Satellite.BrokenFlag = 0) then
    begin
      WaterRate := Min(GetPlayer.CurrentPlanet.WaterTiles - GetPlayer.CurrentPlanet.WaterExplored,WaterRate + Satellite.WaterExplorationRate);
      LandRate := Min(GetPlayer.CurrentPlanet.LandTiles - GetPlayer.CurrentPlanet.LandExplored,LandRate + Satellite.LandExplorationRate);
      HillRate := Min(GetPlayer.CurrentPlanet.HillTiles - GetPlayer.CurrentPlanet.HillExplored,HillRate + Satellite.HillExplorationRate);
    end;
  end;
  with GetByName('WaterTimeLeft') as TLabelGI do
  begin
    SetActive(WaterRate > 0);
    if Active then
    begin
      WaterRate := Min(999,Ceil((GetPlayer.CurrentPlanet.WaterTiles - GetPlayer.CurrentPlanet.WaterExplored) / WaterRate));
      SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.TimeLeft'),'<val>',IntToStr(WaterRate),'<color=0,50,200>'));
    end;
  end;
  with GetByName('LandTimeLeft') as TLabelGI do
  begin
    SetActive(LandRate > 0);
    if Active then
    begin
      LandRate := Min(999,Ceil((GetPlayer.CurrentPlanet.LandTiles - GetPlayer.CurrentPlanet.LandExplored) / LandRate));
      SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.TimeLeft'),'<val>',IntToStr(LandRate),'<color=0,50,200>'));
    end;
  end;
  with GetByName('HillTimeLeft') as TLabelGI do
  begin
    SetActive(HillRate > 0);
    if Active then
    begin
      HillRate := Min(999,Ceil((GetPlayer.CurrentPlanet.HillTiles - GetPlayer.CurrentPlanet.HillExplored) / HillRate));
      SetText(ReplaceColoredToken(LocalizedColorText('FormPlanetNO.TimeLeft'),'<val>',IntToStr(HillRate),'<color=0,50,200>'));
    end;
  end;
  GetByName('Light1').SetActive(GetPlayer.CurrentPlanet.WaterExplored >= GetPlayer.CurrentPlanet.WaterTiles);
  GetByName('Light2').SetActive(GetPlayer.CurrentPlanet.LandExplored >= GetPlayer.CurrentPlanet.LandTiles);
  GetByName('Light3').SetActive(GetPlayer.CurrentPlanet.HillExplored >= GetPlayer.CurrentPlanet.HillTiles);
end;
{ @end $7E8E74 }

{ @routine $7EA8D4 TfPlanetNO_ScrollSatellitePageLeft }
procedure TfPlanetNO.ScrollSatellitePageLeft(Sender: TObjectGI);
begin
  if SatelliteInventoryPageStart > 0 then
  begin
    Dec(SatelliteInventoryPageStart);
    RefreshResearchPanel;
    PostMouseMoveMessage;
  end;
end;
{ @end $7EA8D4 }

{ @routine $7EA908 TfPlanetNO_ScrollSatellitePageRight }
procedure TfPlanetNO.ScrollSatellitePageRight(Sender: TObjectGI);
begin
  if SatelliteInventoryPageStart + 6 <= GetPlayer.GetSatelliteTrajectoryIndexLimit then
  begin
    Inc(SatelliteInventoryPageStart);
    RefreshResearchPanel;
    PostMouseMoveMessage;
  end;
end;
{ @end $7EA908 }

{ @routine $7EA948 TfPlanetNO_ProcessMouseWheel }
procedure TfPlanetNO.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = WHEEL_DELTA then ScrollSatellitePageLeft(nil)
  else if Delta = -WHEEL_DELTA then ScrollSatellitePageRight(nil);
end;
{ @end $7EA948 }

{ @routine $7EA988 TfPlanetNO_MainPanelMouseMove }
procedure TfPlanetNO.MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var I: Integer; Item: TItem; HideInfo, ForceHand: Boolean;
begin
  if ResearchPanelVisible and (SelectedTrajectoryIndex < 0) and not HoveringSurfaceLoot then
  begin
    HideInfo := True;
    ForceHand := False;
    for I := 0 to 5 do
      if SatelliteInventorySlots[I].ContainsPoint(Point) then
      begin
        Item := GetPlayer.FindSatelliteByTrajectoryIndex(SatelliteInventoryPageStart + I);
        if Item <> nil then
        begin
          HideInfo := False;
          ForceHand := True;
          UpdateItemInfoPopup(Item);
        end;
        Break;
      end;
    if HideInfo then UpdateItemInfoPopup(nil);
    UpdateActionCursor(ForceHand);
  end;
end;
{ @end $7EA988 }

{ @routine $7EAA54 TfPlanetNO_SatelliteInventoryMouseDown }
procedure TfPlanetNO.SatelliteInventoryMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Item: TSatellite;
begin
  Galaxy.CheckIntegrityChecksum(121);
  Item := GetPlayer.FindSatelliteByTrajectoryIndex(SatelliteInventoryPageStart + Sender.UserValue);
  if (HeldSatellite = nil) and (Item <> nil) then
  begin
    HeldSatellite := Item;
    HeldSatelliteOrigin := 0;
    GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(Item));
    GetPlayer.RefreshDerivedStats(True);
    UpdateActionCursor(False);
    RefreshResearchPanel;
    SoundManager.PlaySound('Sound.SlotGet');
    PostMouseMoveMessage;
  end
  else if HeldSatellite <> nil then
  begin
    if Item <> nil then GetPlayer.InsertSatelliteTrajectoryIndex(SatelliteInventoryPageStart + Sender.UserValue);
    SoundManager.PlaySound('Sound.SlotPut');
    GetPlayer.Inventory.Add(HeldSatellite);
    (TObject(HeldSatellite) as TSatellite).TrajectoryIndex := SatelliteInventoryPageStart + Sender.UserValue;
    (TObject(HeldSatellite) as TSatellite).TargetPlanet := nil;
    HeldSatellite := nil;
    GetPlayer.RefreshDerivedStats(True);
    GetPlayer.RemoveEmptySatelliteTrajectoryIndex(SatelliteInventoryPageStart + Sender.UserValue + 1);
    GetPlayer.ArrangeHoldSatellitesByTrajectoryIndex;
    UpdateActionCursor(False);
    RefreshResearchPanel;
    PostMouseMoveMessage;
  end;
  Galaxy.PrimeIntegrityChecksum(122);
  GetPlayer.RefreshStorageBubbles;
  MainPanel.RefreshMoneyAndCargo;
  MainPanel.RebuildMessageButtons(False);
end;
{ @end $7EAA54 }

{ @routine $7EAC98 TfPlanetNO_ResearchMapMouseDown }
procedure TfPlanetNO.ResearchMapMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  I: Integer;
  Entry: PPlanetSurfaceLootEntry;
  Cell: TPoint;
  Item: TSatellite;
begin
  if GetPlayer.CurrentPlanet.SurfaceLootEntries <> nil then
    for I := 0 to GetPlayer.CurrentPlanet.SurfaceLootEntries.Count - 1 do
    begin
      Entry := GetPlayer.CurrentPlanet.SurfaceLootEntries[I];
      if ((Entry.TerrainKind = ptWater) and (GetPlayer.CurrentPlanet.WaterExplored >= Entry.SurfaceTileIndex)) or
         ((Entry.TerrainKind = ptLand) and (GetPlayer.CurrentPlanet.LandExplored >= Entry.SurfaceTileIndex)) or
         ((Entry.TerrainKind = ptHill) and (GetPlayer.CurrentPlanet.HillExplored >= Entry.SurfaceTileIndex)) then
        if not Entry.Unavailable then
        begin
          Cell := GetByName('PanelItems').ToLocalPoint(Point);
          Cell.X := Cell.X div GiScalePixelsEx(36,28);
          Cell.Y := Cell.Y div GiScalePixelsEx(36,28);
          if (Entry.GridX = Cell.X) and (Entry.GridY = Cell.Y) then
          begin
            if GetPlayer.GetCargoFreeSpace < Entry.Item.Weight then
            begin
              MainPanel.FlashCargoWarning;
              Exit;
            end;
            SoundManager.PlaySound('Sound.PlanetGet');
            Galaxy.CheckIntegrityChecksum(123);
            if Entry.Item is TArtefactTranclucator then
              (TObject((Entry.Item as TArtefactTranclucator).Ship) as TTranclucator).OwnerShip := GetPlayer;
            if Entry.Item is TGoods then
            begin
              Inc(GetPlayer.CargoGoods[Ord(Entry.Item.ItemType)].Count,(Entry.Item as TGoods).Quantity);
              Entry.Item.Free;
            end
            else if Entry.Item is TArtefact then GetPlayer.Artefacts.Add(Entry.Item)
            else GetPlayer.Inventory.Add(Entry.Item);
            GetPlayer.RefreshDerivedStats(True);
            GetPlayer.CurrentPlanet.SurfaceLootEntries.Delete(I);
            if GetPlayer.CurrentPlanet.SurfaceLootEntries.Count <= 0 then
            begin
              GetPlayer.CurrentPlanet.SurfaceLootEntries.Free;
              GetPlayer.CurrentPlanet.SurfaceLootEntries := nil;
            end;
            Entry.Item := nil;
            Dispose(Entry);
            Galaxy.PrimeIntegrityChecksum(124);
            UpdateActionCursor(False);
            RefreshResearchPanel;
            PostMouseMoveMessage;
            Break;
          end;
        end;
    end;
  if (SelectedTrajectoryIndex >= 0) and ((HeldSatellite <> nil) or (FindDeployedSatellite(SelectedTrajectoryIndex) <> nil)) then
  begin
    HeldSatelliteOrigin := 1;
    Galaxy.CheckIntegrityChecksum(125);
    Item := FindDeployedSatellite(SelectedTrajectoryIndex);
    if Item <> nil then GetPlayer.Satellites.Delete(GetPlayer.Satellites.IndexOf(Item));
    if HeldSatellite <> nil then
    begin
      SoundManager.PlaySound('Sound.SlotPut');
      GetPlayer.Satellites.Add(HeldSatellite);
      if Item <> nil then
      begin
        Item.TrajectoryIndex := (TObject(HeldSatellite) as TSatellite).TrajectoryIndex;
        HeldSatelliteOrigin := 0;
      end;
      (TObject(HeldSatellite) as TSatellite).TrajectoryIndex := SelectedTrajectoryIndex;
      (TObject(HeldSatellite) as TSatellite).TargetPlanet := GetPlayer.CurrentPlanet;
      HeldSatellite := nil;
    end
    else if Item <> nil then SoundManager.PlaySound('Sound.SlotGet');
    Galaxy.PrimeIntegrityChecksum(126);
    if Item <> nil then HeldSatellite := Item;
    SelectedTrajectoryIndex := -1;
    UpdateActionCursor(False);
    RefreshResearchPanel;
    PostMouseMoveMessage;
    GetPlayer.RefreshStorageBubbles;
    MainPanel.RefreshMoneyAndCargo;
    MainPanel.RebuildMessageButtons(False);
  end;
end;
{ @end $7EAC98 }

{ @routine $7EB1FC TfPlanetNO_MainPanelRightButtonDown }
procedure TfPlanetNO.MainPanelRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ResearchPanelVisible then ReturnHeldSatellite;
end;
{ @end $7EB1FC }

{ @routine $7EB234 TfPlanetNO_UpdateActionCursor }
procedure TfPlanetNO.UpdateActionCursor(ForceHand: Boolean);
begin
  if HeldSatellite <> nil then
    SetCursorImage('GI,' + HeldSatellite.GetBitmapResourceName + 's',Classes.Point(16,16))
  else if (SelectedTrajectoryIndex >= 0) and (FindDeployedSatellite(SelectedTrajectoryIndex) <> nil) then
  begin
    if not IsCursorImageSelected('Take') then
    begin
      SoundManager.PlaySound('Sound.ProbeEnter');
      SetCursorByName('Take');
    end;
  end
  else if ForceHand or (HoveredItem <> nil) then
  begin
    if not IsCursorImageSelected('Take') then SetCursorByName('Take');
  end
  else if not IsCursorImageSelected('Main') then SetCursorByName('Main');
  GetByName('Glow').SetActive(HeldSatellite <> nil);
end;
{ @end $7EB234 }

{ @routine $7EB408 TfPlanetNO_ReturnHeldSatellite }
procedure TfPlanetNO.ReturnHeldSatellite;
begin
  if HeldSatellite = nil then Exit;
  Galaxy.CheckIntegrityChecksum(127);
  if HeldSatelliteOrigin = 0 then
  begin
    GetPlayer.Inventory.Add(HeldSatellite);
    HeldSatellite := nil;
    GetPlayer.RefreshDerivedStats(True);
    UpdateActionCursor(False);
    RefreshResearchPanel;
    PostMouseMoveMessage;
  end
  else
  begin
    GetPlayer.Satellites.Add(HeldSatellite);
    HeldSatellite := nil;
    SatellitePanelNeedsLayout := True;
    SelectedTrajectoryIndex := -1;
    UpdateActionCursor(False);
    RefreshResearchPanel;
    PostMouseMoveMessage;
  end;
  Galaxy.PrimeIntegrityChecksum(128);
end;
{ @end $7EB408 }

{ @routine $7EB4EC TfPlanetNO_FindDeployedSatellite }
function TfPlanetNO.FindDeployedSatellite(TrajectoryIndex: Integer): TSatellite;
var I: Integer;
begin
  if TrajectoryIndex = -1 then
  begin
    Result := nil;
    Exit;
  end;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
  begin
    Result := TSatellite(GetPlayer.Satellites[I]);
    if (GetPlayer.CurrentPlanet = Result.TargetPlanet) and (Result.TrajectoryIndex = TrajectoryIndex) then Exit;
  end;
  Result := nil;
end;
{ @end $7EB4EC }

{ @routine $7EB568 TfPlanetNO_CountDeployedSatellites }
function TfPlanetNO.CountDeployedSatellites: Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
    if TSatellite(GetPlayer.Satellites[I]).TargetPlanet = GetPlayer.CurrentPlanet then Inc(Result);
end;
{ @end $7EB568 }

{ @routine $7EB5C8 TfPlanetNO_AdvanceSatelliteMarkers }
procedure TfPlanetNO.AdvanceSatelliteMarkers(Timer: PCallbackTimerGI; UserData: Integer);
var Panel: TPanelGI; Control: TObjectGI; Satellite: TSatellite;
begin
  Panel := GetByName('PanelSatellite') as TPanelGI;
  Control := Panel.FirstChild;
  while Control <> nil do
  begin
    Satellite := TSatellite(Control.UserValue);
    if GetPlayer.Satellites.IndexOf(Satellite) >= 0 then
      Control.SetPosition(AdvanceTrajectoryPoint(Satellite.TrajectoryIndex,Control.LocalPosition));
    Control := Control.NextSibling;
  end;
end;
{ @end $7EB5C8 }

{ @routine $7EB680 TfPlanetNO_UpdateProbeSignalSound }
procedure TfPlanetNO.UpdateProbeSignalSound(Timer: PCallbackTimerGI; UserData: Integer);
var Count: Integer;
begin
  Count := CountDeployedSatellites;
  if (ProbeSignalCount <> Count) and (ProbeSignalSound <> nil) then
  begin
    ProbeSignalSound.SetVolume(Max(0,ProbeSignalSound.Volume - 0.02));
    if ProbeSignalSound.Volume <= 0 then
    begin
      ProbeSignalSound.Free;
      ProbeSignalSound := nil;
    end;
  end;
  if ProbeSignalSound = nil then ProbeSignalCount := Count;
  if (ProbeSignalSound = nil) and (ProbeSignalCount > 0) then
  begin
    ProbeSignalSound := TSoundBufferControl.Create;
    ProbeSignalSound.Configure('Sound.ProbeSignal' + IntToStr(ProbeSignalCount),0,True);
    ProbeSignalSound.SetVolume(0.01);
  end;
  if (ProbeSignalCount > 0) and (ProbeSignalCount = Count) and (ProbeSignalSound <> nil) and (ProbeSignalSound.Volume < 1) then
    ProbeSignalSound.SetVolume(Min(1,ProbeSignalSound.Volume + 0.02));
end;
{ @end $7EB680 }

{ @routine $7EB900 TfPlanetNO_UpdateItemInfoPopup }
// The explicit script receiver value preserves native argument evaluation order.
procedure TfPlanetNO.UpdateItemInfoPopup(Item: TItem);
const
  DurableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
var
  Equipment: TEquipment;
  BarWidth, CapWidth, MinimumWidth: Integer;
  Reserved7C, Reserved80, Reserved84: Integer; // Unused native stack locals.
begin
  if Item <> HoveredItem then
  begin
    HoveredItem := Item;
    if Item = nil then
    begin
      if ItemInfoHideTimer <> nil then
      begin
        CancelCallbackTimer(ItemInfoHideTimer);
        ItemInfoHideTimer := nil;
      end;
      ItemInfoHideTimer := ScheduleCallbackTimer(300,99999,HideItemInfoPopup);
    end
    else
    begin
      if ItemInfoHideTimer <> nil then
      begin
        CancelCallbackTimer(ItemInfoHideTimer);
        ItemInfoHideTimer := nil;
      end;
      if Item is TGoods then ShowGoodsInfoPopup(Item as TGoods)
      else
      begin
        if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
        begin
          if Item.ScriptItem <> nil then TScriptItem(Integer(Item.ScriptItem) + 0).RunActionCode(satOnShowingItemInfo,nil,GetPlayer.CurrentPlanet,nil,0);
          if Item is TEquipmentWithActCode then RunItemConfigActionCode(Item, satOnShowingItemInfo,nil,GetPlayer.CurrentPlanet,nil,0);
        end;
        Equipment := Item as TEquipment;
        ItemInfoWindow.SetActive(True);
        with ItemInfoImage do
        begin
          SetImagePath('GI,' + Equipment.GetBitmapResourceName + 's');
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
          SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
        end;
        ItemInfoNameLabel.SetText(WrapTextInColor(Equipment.GetDisplayName,InfoNameColorTag));
        ItemInfoTextLabel.SetText(Equipment.GetInfoText('<color=255,240,100>',GetPlayer));
        ItemInfoSizeLabel.SetText(IntToStr(Equipment.Weight));
        ItemInfoCostLabel.SetText(IntToStr(Equipment.Cost));
        with ItemInfoRaceIcon do
        begin
          SetImagePath(GetFactionEmblemPath(Equipment.GetOwnerConfigName));
          SetImageKindX(ikxCenter);
          SetImageKindY(ikyCenter);
        end;
      if not (Byte(Equipment.ItemType) in DurableTypes) and (Equipment.ItemType <> t_Hull) then
      begin
        with GetByName('InfoDurable') as TImageGI do Parent.Parent.SetActive(False);
        MinimumWidth := 0;
      end
      else
      begin
        if Equipment is THull then BarWidth := Round(Sqrt(Equipment.Weight / HullBaseSize / Max(0.1,Equipment.GetFragilityFactor([]))) * 64)
        else BarWidth := Round(64 / Max(0.1,Equipment.GetFragilityFactor([])));
        BarWidth := Min(192,Max(32,BarWidth));
        with GetByName('InfoDurableLeft') as TImageGI do
        begin
          CapWidth := GetContentSize.X;
          MinimumWidth := 2 * CapWidth + BarWidth + LocalPosition.X + Parent.LocalPosition.X + 2 * Parent.Parent.LocalPosition.X;
        end;
        with GetByName('InfoDurable') as TImageGI do
        begin
          Parent.Parent.SetActive(True);
          Parent.Parent.SetSize(Classes.Point(2 * CapWidth + BarWidth,Parent.Parent.ClientSize.Y));
          Parent.SetSize(Classes.Point(BarWidth + 2,Parent.Parent.ClientSize.Y));
          if Equipment.ItemType = t_Hull then
            SetPosition(Classes.Point(Round((Equipment as THull).HullPoints / (Equipment as THull).Weight * BarWidth) - (GetContentSize.X - 5),LocalPosition.Y))
          else SetPosition(Classes.Point(Round(BarWidth * (Equipment.ConditionPercent / 100)) - (GetContentSize.X - 5),LocalPosition.Y));
        end;
        with GetByName('InfoDurableRight') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + CapWidth - GetContentSize.X,LocalPosition.Y));
          Parent.SetPosition(Classes.Point(CapWidth,Parent.LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth,Parent.ClientSize.Y));
        end;
        with GetByName('InfoDurableBack') as TImageGI do
        begin
          SetPosition(Classes.Point(BarWidth + 1 - GetContentSize.X,LocalPosition.Y));
          Parent.SetSize(Classes.Point(BarWidth + CapWidth,Parent.ClientSize.Y));
        end;
      end;
        ShipScreen.LayoutItemInfo(ItemInfoWindow,ItemInfoNameLabel,ItemInfoTextLabel,True,True,MinimumWidth);
        ItemInfoSizeLabel.SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X,ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
        ItemInfoCostLabel.SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X,ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
        ItemInfoRaceIcon.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X,ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
      end;
    end;
  end;
end;
{ @end $7EB900 }

{ @routine $7EC2F8 TfPlanetNO_ShowGoodsInfoPopup }
procedure TfPlanetNO.ShowGoodsInfoPopup(Item: TGoods);
begin
  GetByName('PII').SetActive(True);
  with GetByName('InfoImage') as TImageGI do
  begin
    SetImagePath('GI,' + GetItemTypeBitmapPath(Item.ItemType));
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetPosition(SubtractPoints(ShipScreen.ItemImageCenter,GetVisualCenter));
  end;
  (GetByName('InfoName') as TLabelGI).SetText(WrapTextInColor(GoodsMarket[Ord(Item.ItemType)].DisplayName,InfoNameColorTag));
  (GetByName('InfoText') as TLabelGI).SetText(LocalizedText('Items.Goods.Text.' + IntToStr(Ord(Item.ItemType) + 1)));
  (GetByName('InfoSize') as TLabelGI).SetText(IntToStr(Item.Quantity));
  (GetByName('InfoPrice') as TLabelGI).SetText(IntToStr(Item.Cost));
  with GetByName('EmRace') as TImageGI do
  begin
    SetImagePath(GetFactionEmblemPath(OwnerInfo[RaceToOwner(GetPlayer.PilotRace)].InternalName));
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  GetByName('InfoDurable').Parent.Parent.SetActive(False);
  ShipScreen.LayoutItemInfo(ItemInfoWindow,ItemInfoNameLabel,ItemInfoTextLabel,True,True,0);
  ItemInfoSizeLabel.SetPosition(Classes.Point(ShipScreen.ItemSizeLabelPosition.X,ItemInfoWindow.ClientSize.Y + ShipScreen.ItemSizeLabelPosition.Y));
  ItemInfoCostLabel.SetPosition(Classes.Point(ShipScreen.ItemPriceLabelPosition.X,ItemInfoWindow.ClientSize.Y + ShipScreen.ItemPriceLabelPosition.Y));
  ItemInfoRaceIcon.SetPosition(Classes.Point(ItemInfoWindow.ClientSize.X + ShipScreen.ItemRaceImagePosition.X,ItemInfoWindow.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
end;
{ @end $7EC2F8 }

{ @routine $7EC784 TfPlanetNO_HideItemInfoPopup }
procedure TfPlanetNO.HideItemInfoPopup(Timer: PCallbackTimerGI; UserData: Integer);
begin
  HoveredItem := nil;
  if ItemInfoHideTimer <> nil then
  begin
    CancelCallbackTimer(ItemInfoHideTimer);
    ItemInfoHideTimer := nil;
  end;
  GetByName('PII').SetActive(False);
end;
{ @end $7EC784 }

{ @routine $7EC7EC TfPlanetNO_MainPanelKeyDown }
procedure TfPlanetNO.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var QuestButton: TObjectGI;
begin
  if LoadPanel.IsAnimatingShutters or IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = VK_SPACE then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else if Key = Ord('F') then TakeoffClicked(nil)
  else if Key = Ord('E') then ToggleResearchPanel(nil)
  else if Key = VK_LEFT then
  begin
    if ResearchPanelVisible then ScrollSatellitePageLeft(nil);
  end
  else if Key = VK_RIGHT then
  begin
    if ResearchPanelVisible then ScrollSatellitePageRight(nil);
  end
  else if Key = VK_ESCAPE then
  begin
    if ResearchPanelVisible then
    begin
      if HeldSatellite <> nil then ReturnHeldSatellite else CloseResearchPanel;
    end
    else MainPanel.MenuClicked(nil);
  end
  else if Key = Ord('M') then GalaxyClicked(nil)
  else if Key = Ord('S') then ShipClicked(nil)
  else if Key = Ord('R') then QuestClicked(nil)
  else if Key = Ord('Q') then
  begin
    QuestButton := GetByName('QuestInfo_Run');
    if QuestButton.Active then StartTextQuest(QuestButton);
  end
  else MainPanel.ProcessKeyDown(Key);
end;
{ @end $7EC7EC }

{ @routine $7EC9E4 TfPlanetNO_ExecuteUiCode }
procedure TfPlanetNO.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not MainPanel.NavigationLocked and not ExitScreenLoop and
    (TurnCalculationPhase in [tcpIdle,tcpGalaxyFinished,tcpPlayerStarFinished,tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10003);
    ExecuteGameplayUiCode(Block,Key);
    Galaxy.PrimeIntegrityChecksum(20003);
  end;
end;
{ @end $7EC9E4 }

{ @routine $7ECA58 TfPlanetNO_SelectMusic }
procedure TfPlanetNO.SelectMusic;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.CurrentPlanet <> nil then
    if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
    begin
      if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.PiratePlanetMain');
    end
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
end;
{ @end $7ECA58 }

end.
