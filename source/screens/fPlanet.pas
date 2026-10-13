unit fPlanet;

interface

uses EC_BlockPar, GI_MessageLoop, fPanelLoad, fPanelMain, fPanelPlanet;

type
  TfPlanet = class(TMessageLoopGIWithMainPanel) // @size 0xE0
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    LoadPanel: TfPanelLoad; // @offset 0xD8

    constructor Create; // @addr 0x00504410
    destructor Destroy; override; // @addr 0x0050446C
    procedure RefreshTextQuestPrompt; // @addr 0x0050501C
    procedure RefreshPlanetInfo; // @addr 0x00504A4C
    procedure EndTurnClicked(Sender: TObjectGI); // @addr 0x00505794
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x005057F8
    procedure StartTextQuest(Sender: TObjectGI); // @addr 0x00504EC4
    procedure OnOpen; override; // @addr 0x005046C0
    procedure OnClose; override; // @addr 0x005049F8
    procedure SelectMusic; override; // @addr 0x0050592C
    procedure InitializeLayout; override; // @addr 0x005044C0
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x005058C8
  end;

implementation

uses Classes, SysUtils, Windows, Types, GR_Main, Globals, GlobalsV, GI_Main,
  GI_GraphButton, GI_GraphBuf, GI_Image, GI_Label, GI_Window, GI_TransImage,
  GI_MessageBox, aConst, aMyFunction, aGalaxy, aGalaxyStruct, aGalaxyEvent,
  aPlanet, aPlayer, aRanger, aSaveLoad, aScript, fEquipmentShop, fGalaxy2,
  fSaveManager, fShip2, fPlanetQuest, ThreadCalc;

{ @routine $504410 TfPlanet_Create }
constructor TfPlanet.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $504410 }

{ @routine $50446C TfPlanet_Destroy }
destructor TfPlanet.Destroy;
begin
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
  inherited Destroy;
end;
{ @end $50446C }

{ @routine $5044C0 TfPlanet_InitializeLayout }
procedure TfPlanet.InitializeLayout;
var
  Panel, Info, Quest: TObjectGI;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  PlanetPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fPlanet... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Panel := GetByName('MainPanel');
  Panel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Panel.FindByNameRecursive('BGCity').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Info := Panel.FindByNameRecursive('PanelInfo');
  Info.SetPosition(Classes.Point(Info.LocalPosition.X + ExtraScreenWidth, Info.LocalPosition.Y));
  Quest := Panel.FindByNameRecursive('QuestInfo');
  // Native layout adds the extra width to both coordinates here.
  Quest.SetPosition(Classes.Point(Quest.LocalPosition.X + ExtraScreenWidth,
    Quest.LocalPosition.Y + ExtraScreenWidth));
  AppendLogLineThreadSafe('ok');
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
end;
{ @end $5044C0 }

{ @routine $5046C0 TfPlanet_OnOpen }
procedure TfPlanet.OnOpen;
var
  Event: TGalaxyEvent;
begin
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
  MainPanel.OnOpen;
  PlanetPanel.OnOpen;
  LoadPanel.OnOpen;
  if GetPlayer.CurrentPlanet.IsMainPiratePlanet then SoundSection := 0
  else SoundSection := Ord(GetPlayer.CurrentPlanet.RaceId) + 1;
  if GetPlayer.CurrentPlanet <> TemporaryShopPlanet then
  begin
    SelectMusic;
    if TemporaryShopSlots <> nil then RestoreTemporaryShopStock;
    RunGlobalScriptsForContext(GetPlayer.CurrentStar, 0);
    PruneExpiredPersistentPlayerMessages;
    BuildTemporaryShopSlotGrid;
  end;
  Galaxy.ReleaseItemGraphics;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  (GetByName('BGCity') as TImageGI).ImageSourcePath := GetPlayer.CurrentPlanet.GetGovernmentBackgroundGraph;
  RefreshPlanetInfo;
  RefreshTextQuestPrompt;
  if (GetPlayer = nil) or ((GetPlayer.CurrentPlanet <> nil) and
    (GetPlayer.CurrentStar.ControlFaction = sfDominators)) then
  begin
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('PlanetCaptured');
    GameEndReason := gerPlayerDeath;
    RequestedScreenId := screenGameEnd;
    RequestClose(1);
    Exit;
  end;
  if GetPlayer.PendingLiberationCeremonyPlanet = GetPlayer.CurrentPlanet then
  begin
    RequestedScreenId := screenGovernment;
    RequestClose(1);
    Exit;
  end;
  if GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile then
  begin
    RequestedScreenId := screenGovernment;
    RequestClose(1);
    Exit;
  end;
  if DispatchPendingScriptRequests then
  begin
    Galaxy.PrimeIntegrityChecksum(94);
    Exit;
  end;
  if (GetPlayer.CurrentPlanet <> nil) and ((GetPlayer.PendingDockDialogue > 0) or
    GetPlayer.CurrentPlanet.IsMainPiratePlanet) then
  begin
    RequestedScreenId := screenGovernment;
    RequestClose(1);
    Exit;
  end;
  if GR_Main.CCInterface.GetResourceChecksumFailed and not GR_Main.CCInterface.GetTamperDetected then
    GR_Main.CCInterface.SetTamperDetected(True);
  MainPanel.RebuildMessageButtons(False);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm, nil, nil, 0);
  Galaxy.PrimeIntegrityChecksum(94);
end;
{ @end $5046C0 }

{ @routine $5049F8 TfPlanet_OnClose }
procedure TfPlanet.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(95);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  MainPanel.OnClose;
  PlanetPanel.OnClose;
  LoadPanel.OnClose;
end;
{ @end $5049F8 }

{ @routine $504A4C TfPlanet_RefreshPlanetInfo }
procedure TfPlanet.RefreshPlanetInfo;
var
  Window: TWindowGI;
begin
  Window := GetByName('PanelInfo') as TWindowGI;
  with GetByName('PanelInfo_Name') as TLabelGI do
    if GetPlayer.CurrentPlanet.IsMainPiratePlanet then
      Text := GetPlayer.CurrentPlanet.Name
    else
      Text := ReplaceColoredToken(
        LocalizedText('Planet.Civil.Info.TextNamePlanet'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, InfoNameColorTag);
  with GetByName('PanelInfo_Text') as TLabelGI do
  begin
    Text := GetPlayer.CurrentPlanet.GetCivilInfoText;
    Window.SetSize(Classes.Point(ClientSize.X + Window.WorkSubRect.Left + Window.WorkSubRect.Right,
      ClientSize.Y + Window.WorkSubRect.Top + Window.WorkSubRect.Bottom));
    Window.UpdateAutoGeometry;
    Window.SetPosition(Classes.Point(GameScreenWidth - 10 - Window.ClientSize.X, 10));
    Window.SetActive(True);
    SetPosition(Window.WorkSubRect.TopLeft);
  end;
  with GetByName('PanelInfo_Image') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    GetPlayer.CurrentPlanet.Graphic.RenderToBuffer(Self, GraphBuf, False);
    if GraphBuf.Width >= GraphBuf.Height then
      GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height), 5)
    else
      GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width), ClientSize.Y, 5);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  ShipScreen.LayoutItemInfo(Window, GetByName('PanelInfo_Name') as TLabelGI,
    GetByName('PanelInfo_Text') as TLabelGI, True, False, 0);
  with GetByName('PanelInfo_Race') as TImageGI do
  begin
    ImageSourcePath := GetFactionEmblemPath(GetPlayer.CurrentPlanet.GetFactionResourceName);
    KindX := ikxCenter;
    KindY := ikyCenter;
    SetPosition(Classes.Point(Window.ClientSize.X + ShipScreen.ItemRaceImagePosition.X,
      Window.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
  end;
  with GetByName('PanelInfo_Text') as TLabelGI do SetTextAlignX(taxLeft);
end;
{ @end $504A4C }

{ @routine $504EC4 TfPlanet_StartTextQuest }
procedure TfPlanet.StartTextQuest(Sender: TObjectGI);
begin
  if Sender.UserValue <> 0 then
    if ShowMessageBoxGI(Self,
      LocalizedText('FormGov.QuestCertificate.NotCertificateAttention'),
      mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
  Galaxy.CheckIntegrityChecksum(162);
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  StandaloneQuestMode := False;
  QuestReturnScreenId := FormToId(Self);
  RequestedScreenId := screenPlanetQuest;
  RequestClose(1);
end;
{ @end $504EC4 }

{ @routine $50501C TfPlanet_RefreshTextQuestPrompt }
procedure TfPlanet.RefreshTextQuestPrompt;
var
  Window: TWindowGI;
  QuestNumber, I: Integer;
  Quest: PQuest;
  CaptionText: WideString;
begin
  QuestNumber := -1;
  Window := GetByName('QuestInfo') as TWindowGI;
  Quest := nil;
  Window.SetActive(False);
  if (GetPlayer.CurrentPlanet.TextQuestId > -1) and (GetPlayer.Quests.Count > 0) then
    for I := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[I];
      if (Quest.QuestType = qtPlanetQuest) and (Quest.ObjectiveTarget is TPlanet) and
        (GetPlayer.CurrentPlanet = (Quest.ObjectiveTarget as TPlanet)) and
        (LanguageDataConfig.GetBlockByPath('PlanetQuest.PlanetQuest').CountParams(IntToStr(Quest.QuestNumber)) > 0) then
      begin
        QuestNumber := Quest.QuestNumber;
        if (Quest.QuestNumber < FirstLicensedQuestId) or
          ((LanguageDataConfig.GetBlock('PlanetQuest').CountBlocks('PlanetQuestLic') > 0) and
          (LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuestLic').GetParamOrMarker(IntToStr(Quest.QuestNumber)) =
          PlanetQuestScreen.GetQuestContentHash(Quest.QuestNumber))) then
          Window.FindByNameRecursive('QuestInfo_Run').UserValue := 0
        else
          Window.FindByNameRecursive('QuestInfo_Run').UserValue := 1;
        Window.SetActive(True);
        Break;
      end;
    end;
  if not Window.Active then Exit;
  with GetByName('QuestInfo_Name') as TLabelGI do
    Text := LocalizedText('PlanetQuest.StartText.QuestCaption');
  with GetByName('QuestInfo_Text') as TLabelGI do
  begin
    CaptionText := LocalizedColorText('PlanetQuest.StartText.' + IntToStr(QuestNumber));
    if CaptionText = '' then CaptionText := LocalizedColorText('PlanetQuest.StartText.QuestExtern');
    if Quest <> nil then
    begin
      ReplaceTextToken(CaptionText, '<CurPlanet>', (Quest.ObjectiveTarget as TPlanet).Name, TextHighlightColorTag);
      ReplaceTextToken(CaptionText, '<CurStar>', (Quest.ObjectiveTarget as TPlanet).CurrentStar.Name, TextHighlightColorTag);
      ReplaceTextToken(CaptionText, '<FromPlanet>', Quest.Planet.Name, TextHighlightColorTag);
      ReplaceTextToken(CaptionText, '<FromStar>', Quest.Planet.CurrentStar.Name, TextHighlightColorTag);
    end;
    Text := CaptionText;
    Window.SetSize(Classes.Point(ClientSize.X + Window.WorkSubRect.Left + Window.WorkSubRect.Right,
      ClientSize.Y + Window.WorkSubRect.Top + Window.WorkSubRect.Bottom));
    Window.UpdateAutoGeometry;
    Window.SetActive(True);
    SetPosition(Window.WorkSubRect.TopLeft);
  end;
  ShipScreen.LayoutItemInfo(Window, GetByName('QuestInfo_Name') as TLabelGI,
    GetByName('QuestInfo_Text') as TLabelGI, True, True, 0);
  with GetByName('QuestInfo_Run') as TGraphButtonGI do
  begin
    UpCallback := StartTextQuest;
    Window.SetSize(Classes.Point(Window.ClientSize.X, ClientSize.Y + Window.ClientSize.Y + GiScalePixels(5)));
    Window.UpdateAutoGeometry;
    SetPosition(Classes.Point(Window.ClientSize.X div 2 - ClientSize.X div 2,
      Window.ClientSize.Y - GiScalePixels(10) - ClientSize.Y));
  end;
  with GetByName('QuestInfo_Name') as TLabelGI do
    SetSize(Classes.Point(Window.ClientSize.X - LocalPosition.X - Window.WorkSubRect.Right, ClientSize.Y));
  Window.SetPosition(Classes.Point(GameScreenWidth - 10 - Window.ClientSize.X,
    GameScreenHeight - GiScalePixels(90) - Window.ClientSize.Y));
end;
{ @end $50501C }

{ @routine $505794 TfPlanet_EndTurnClicked }
procedure TfPlanet.EndTurnClicked(Sender: TObjectGI);
begin
  Galaxy.CheckIntegrityChecksum(96);
  RestoreTemporaryShopStock;
  MainPanel.EndTurnClicked(Sender);
  RefreshPlanetInfo;
  RefreshTextQuestPrompt;
  MainPanel.RebuildMessageButtons(False);
  if ExitCode = 0 then
  begin
    BuildTemporaryShopSlotGrid;
    Galaxy.PrimeIntegrityChecksum(97);
  end;
end;
{ @end $505794 }

{ @routine $5057F8 TfPlanet_MainPanelKeyDown }
procedure TfPlanet.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var
  Button: TObjectGI;
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or
    IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = VK_SPACE then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else if Key = Ord('Q') then
  begin
    Button := GetByName('QuestInfo_Run');
    if Button.Active then StartTextQuest(Button);
  end
  else
  begin
    MainPanel.ProcessKeyDown(Key);
    PlanetPanel.ProcessKeyDown(Key);
  end;
end;
{ @end $5057F8 }

{ @routine $5058C8 TfPlanet_ExecuteUiCode }
procedure TfPlanet.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if MainPanel.NavigationLocked then Exit;
  if ExitScreenLoop then Exit;
  if TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared] then
  begin
    Galaxy.CheckIntegrityChecksum(10002);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20002);
  end;
end;
{ @end $5058C8 }

{ @routine $50592C TfPlanet_SelectMusic }
procedure TfPlanet.SelectMusic;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
  begin
    if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
    else
      MusicManager.PlayCategory('Nation.PiratePlanetMain');
  end
  else
    MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
end;
{ @end $50592C }

end.
