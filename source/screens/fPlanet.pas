unit fPlanet;
// Unit bracket (inferred): .text 0x00509FDC..0x0050B884; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, fPanelLoad, fPanelMain, fPanelPlanet;

type
  TfPlanet = class(TMessageLoopGIWithMainPanel) // @size 0xE0
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    LoadPanel: TfPanelLoad; // @offset 0xD8

    constructor Create; // @addr 0x50A074 @ida "TfPlanet *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x50A0E0 @ida "void __usercall $name(TfPlanet *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure RefreshTextQuestPrompt; // @addr 0x50AD8C
    procedure RefreshPlanetInfo; // @addr 0x50A740
    procedure EndTurnClicked(Sender: TObjectGI); // @addr 0x50B580
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x50B5F8
    procedure StartTextQuest(Sender: TObjectGI); // @addr 0x50AC24
    procedure OnOpen; override; // @addr 0x50A380
    procedure OnClose; override; // @addr 0x50A6E0
    procedure SelectMusic; override; // @addr 0x50B760
    procedure InitializeLayout; override; // @addr 0x50A15C
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x50B6EC
  end;

implementation

uses Classes, SysUtils, Windows, Types, GR_Main, Globals, GlobalsV, GI_Main,
  GI_GraphButton, GI_GraphBuf, GI_Image, GI_Label, GI_Window, GI_TransImage,
  GI_MessageBox, aConst, aMyFunction, aGalaxy, aGalaxyStruct, aGalaxyEvent,
  aPlanet, aPlayer, aRanger, aSaveLoad, aScript, fEquipmentShop, fGalaxy2,
  fSaveManager, fShip2, fPlanetQuest, ThreadCalc;

{ @routine $50A074 TfPlanet_Create }
constructor TfPlanet.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $50A074 }

{ @routine $50A0E0 TfPlanet_Destroy }
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
{ @end $50A0E0 }

{ @routine $50A15C TfPlanet_InitializeLayout }
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
{ @end $50A15C }

{ @routine $50A380 TfPlanet_OnOpen }
procedure TfPlanet.OnOpen;
var
  Event: TGalaxyEvent;
begin
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
  MainPanel.OnOpen;
  PlanetPanel.OnOpen;
  LoadPanel.OnOpen;
  if GetPlayer.CurrentPlanet.IsMainPiratePlanet then SoundSection := 0
  else SoundSection := GetPlayer.CurrentPlanet.RaceId + 1;
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
  (GetByName('BGCity') as TImageGI).SetImagePath(GetPlayer.CurrentPlanet.GetGovernmentBackgroundGraph);
  RefreshPlanetInfo;
  RefreshTextQuestPrompt;
  if (GetPlayer = nil) or ((GetPlayer.CurrentPlanet <> nil) and
    (GetPlayer.CurrentStar.ControlFaction = sfDominators)) then
  begin
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('PlanetCaptured');
    GameEndReason := 2;
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
{ @end $50A380 }

{ @routine $50A6E0 TfPlanet_OnClose }
procedure TfPlanet.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(95);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  MainPanel.OnClose;
  PlanetPanel.OnClose;
  LoadPanel.OnClose;
end;
{ @end $50A6E0 }

{ @routine $50A740 TfPlanet_RefreshPlanetInfo }
procedure TfPlanet.RefreshPlanetInfo;
var
  Window: TWindowGI;
begin
  Window := GetByName('PanelInfo') as TWindowGI;
  with GetByName('PanelInfo_Name') as TLabelGI do
    if GetPlayer.CurrentPlanet.IsMainPiratePlanet then
      SetText(GetPlayer.CurrentPlanet.Name)
    else
      SetText(ReplaceColoredToken(
        LocalizedText('Planet.Civil.Info.TextNamePlanet'),
        '<Planet>', GetPlayer.CurrentPlanet.Name, InfoNameColorTag));
  with GetByName('PanelInfo_Text') as TLabelGI do
  begin
    SetText(GetPlayer.CurrentPlanet.GetCivilInfoText);
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
    if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
      GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
    else
      GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
  end;
  ShipScreen.LayoutItemInfo(Window, GetByName('PanelInfo_Name') as TLabelGI,
    GetByName('PanelInfo_Text') as TLabelGI, True, False, 0);
  with GetByName('PanelInfo_Race') as TImageGI do
  begin
    SetImagePath(GetFactionEmblemPath(GetPlayer.CurrentPlanet.GetFactionResourceName));
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetPosition(Classes.Point(Window.ClientSize.X + ShipScreen.ItemRaceImagePosition.X,
      Window.ClientSize.Y + ShipScreen.ItemRaceImagePosition.Y));
  end;
  with GetByName('PanelInfo_Text') as TLabelGI do SetTextAlignX(taxLeft);
end;
{ @end $50A740 }

{ @routine $50AC24 TfPlanet_StartTextQuest }
procedure TfPlanet.StartTextQuest(Sender: TObjectGI);
begin
  if (Sender.UserValue <> 0) and (ShowMessageBoxGI(Self,
    LocalizedText('FormGov.QuestCertificate.NotCertificateAttention'),
    mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK) then Exit;
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
{ @end $50AC24 }

{ @routine $50AD8C TfPlanet_RefreshTextQuestPrompt }
procedure TfPlanet.RefreshTextQuestPrompt;
var
  Window: TWindowGI;
  QuestNumber, I: Integer;
  Quest: PQuest;
  Text: WideString;
begin
  QuestNumber := -1;
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
        QuestNumber := Quest.QuestNumber;
        if (Quest.QuestNumber < 10000) or
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
    SetText(LocalizedText('PlanetQuest.StartText.QuestCaption'));
  with GetByName('QuestInfo_Text') as TLabelGI do
  begin
    Text := LocalizedColorText('PlanetQuest.StartText.' + IntToStr(QuestNumber));
    if Text = '' then Text := LocalizedColorText('PlanetQuest.StartText.QuestExtern');
    if Quest <> nil then
    begin
      ReplaceTextToken(Text, '<CurPlanet>', (Quest.ObjectiveTarget as TPlanet).Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<CurStar>', (Quest.ObjectiveTarget as TPlanet).CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromPlanet>', Quest.Planet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromStar>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
    end;
    SetText(Text);
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
{ @end $50AD8C }

{ @routine $50B580 TfPlanet_EndTurnClicked }
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
{ @end $50B580 }

{ @routine $50B5F8 TfPlanet_MainPanelKeyDown }
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
{ @end $50B5F8 }

{ @routine $50B6EC TfPlanet_ExecuteUiCode }
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
{ @end $50B6EC }

{ @routine $50B760 TfPlanet_SelectMusic }
procedure TfPlanet.SelectMusic;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
  begin
    if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
    else
      MusicManager.PlayCategory('Nation.PiratePlanetMain');
  end
  else
    MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
end;
{ @end $50B760 }

end.

