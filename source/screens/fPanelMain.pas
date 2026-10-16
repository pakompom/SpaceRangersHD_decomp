unit fPanelMain;

interface

uses Classes, EC_Struct, GI_GraphButton, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types;

type
  TfPanelMain = class(TObjectEx) // @size 0x88
  public
    Screen: TMessageLoopGI; // @offset 0x4
    StatusTimer: TCallbackTimerIdGI; // @offset 0x8
    MessagePulseTimer: TCallbackTimerIdGI; // @offset 0xC
    MessageSlideTimer: TCallbackTimerIdGI; // @offset 0x10
    HelpLabel: TLabelGI; // @offset 0x14
    DisplayedShipId: Cardinal; // @offset $18 Last ship selected through a persistent message.
    DisplayedPlanetId: Cardinal; // @offset $1C Last planet selected through a persistent message.
    MessagePanel: TPanelGI; // @offset 0x20
    BackgroundImage: TImageGI; // @offset 0x24
    ShipButton: TGraphButtonGI; // @offset 0x28
    GalaxyButton: TGraphButtonGI; // @offset 0x2C
    QuestButton: TGraphButtonGI; // @offset 0x30
    EndTurnButton: TGraphButtonGI; // @offset 0x34
    MenuButton: TGraphButtonGI; // @offset 0x38
    DateLabel: TLabelGI; // @offset 0x3C
    DateNextImage: TImageGI; // @offset 0x40
    NextDateLabel: TLabelGI; // @offset 0x44
    NavigationLocked: Boolean; // @offset 0x48
    MessagePulseStep: Integer; // @offset 0x4C
    MessageSlideDirection: Integer; // @offset 0x50
    MessagePanelRestTop: Integer; // @offset 0x54
    DisplayedTurn: Integer; // @offset 0x58
    DateSlideProgress: Single; // @offset 0x5C
    TargetTurn: Integer; // @offset 0x60
    DateTimer: TCallbackTimerIdGI; // @offset 0x64
    DateTimerIntervalMs: Integer; // @offset 0x68
    AuxiliaryItems: TList; // @offset $6C Owned list of borrowed persistent messages awaiting deletion animation.
    MoneyWarningActive: Boolean; // @offset 0x70
    MoneyWarningTicks: Integer; // @offset 0x74
    MoneyWarningTimer: TCallbackTimerIdGI; // @offset 0x78
    CargoWarningActive: Boolean; // @offset 0x7C
    CargoWarningTicks: Integer; // @offset 0x80
    CargoWarningTimer: TCallbackTimerIdGI; // @offset 0x84

    constructor Create; // @addr 0x00759DD4
    destructor Destroy; override; // @addr 0x00759E1C
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x00759E4C
    procedure OnOpen; // @addr 0x0075A6E0
    procedure OnClose; // @addr 0x0075A7F0
    procedure RefreshMoneyAndCargo; // @addr 0x0075A920
    procedure RefreshDate; // @addr 0x0075AC38
    procedure SetDateRange(FirstTurn, LastTurn: Integer); // @addr 0x0075ADBC
    procedure StartDateAnimation(IntervalMs: Integer); // @addr 0x0075ADE8
    procedure AdvanceDateAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $75AE48
    procedure RefreshStatusTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $75BCF8
    procedure AdvanceMessageSlide(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $75D114
    procedure AdvanceMoneyWarning(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $75D914
    procedure AdvanceCargoWarning(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $75D99C
    procedure EndTurnClicked(Sender: TObjectGI); // @addr 0x0075AEF0
    procedure ShipClicked(Sender: TObjectGI); // @addr 0x0075B18C
    procedure QuestClicked(Sender: TObjectGI); // @addr 0x0075B33C
    procedure GalaxyClicked(Sender: TObjectGI); // @addr 0x0075B428
    procedure JournalClicked(Sender: TObjectGI); // @addr 0x0075B524
    procedure MenuClicked(Sender: TObjectGI); // @addr 0x0075B610
    procedure TryAutoTurnSave; // @addr 0x0075B6C8
    procedure QuickSave; // @addr 0x0075B7F8
    procedure QuickLoad(SlotIndex: Integer); // @addr 0x0075B9A8
    procedure RefreshEndTurnButton; // @addr 0x0075C034
    procedure DisableNavigationButtons; // @addr 0x0075C064
    procedure EnableNavigationButtons; // @addr 0x0075C158
    procedure RebuildMessageButtons(SkipLock: Boolean); // @addr $75C250
    procedure ClearMessageButtons; // @addr $75C7AC
    function RemoveDismissibleMessages(Key: WideString): Boolean; // @addr $75C854
    procedure MessageMouseEnter(Sender: TObjectGI); // @addr $75C8F0
    procedure MessageMouseLeave(Sender: TObjectGI); // @addr $75CB20
    procedure DeleteMessage(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint; SkipLock: Boolean); // @addr $75CB54
    procedure MessageRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $75CDB4
    procedure AdvanceMessageDeletion(Sender: TObjectGI); // @addr $75CDE0
    procedure FinishMessageDeletion(Sender: TObjectGI); // @addr $75CF60
    procedure MessageClicked(Sender: TObjectGI); // @addr $75D1B0
    procedure PlayUnreadMessageSounds; // @addr $75D704
    procedure PulseUnreadMessages(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $75BD00
    procedure ProcessKeyDown(Key: Cardinal); // @addr $75DAA8
    procedure PostMouseMove; // @addr $75DD64
    procedure SlideMessagesIn; // @addr 0x0075D074
    procedure SlideMessagesOut; // @addr 0x0075D0C0
    procedure FlashMoneyWarning; // @addr 0x0075D8C8
    procedure FlashCargoWarning; // @addr 0x0075D944
    procedure ShowControlHelp(Sender: TObjectGI; Visible: Boolean); // @addr 0x0075D9D8
    procedure ShowHelpText(Text: WideString; Visible: Boolean); // @addr 0x0075DA34

    procedure Show; // @addr 0x0075A88C
    procedure Hide; // @addr 0x0075A8EC
  end;

  TMessageLoopGIWithMainPanel = class(TMessageLoopGI) // @size 0xD4
  public
    MainPanel: TfPanelMain; // @offset 0xD0
    constructor Create; // @addr 0x0075DDA4
    destructor Destroy; override; // @addr 0x0075DDEC
  end;

var
  CurrentDateColor: Cardinal; // @addr $81B928 Normal date text style, selected during layout.
  AdvancingDateColor: Cardinal; // @addr $81B92C Date-transition text style, selected during layout.

implementation

uses aMyFunction, aGalaxy, aScript, aPlayer, Globals, GlobalsV, GR_Main, SysUtils, ThreadCalc, aCalc, fStarMap, GI_Window, GI_GAI, GI_Main, GR_gi, Windows, Messages, fPanelLoad, fShip2, fRating2, fGalaxy2, fJournal, fSaveManager, GI_MessageBox, aConst, EC_Str, aPlanet, aGalaxyStruct, aGalaxyEvent, aSaveLoad, aEFilm, aShip;

{ @routine $759DD4 TfPanelMain_Create }
constructor TfPanelMain.Create;
begin
  inherited Create;
  NavigationLocked := False;
  AuxiliaryItems := TList.Create;
end;
{ @end $759DD4 }

{ @routine $759E1C TfPanelMain_Destroy }
destructor TfPanelMain.Destroy;
begin
  AuxiliaryItems.Free;
  inherited Destroy;
end;
{ @end $759E1C }

{ @routine $759E4C TfPanelMain_InitializeLayout }
procedure TfPanelMain.InitializeLayout(Screen: TMessageLoopGI);
begin
  Self.Screen := Screen;
  AppendLogTextThreadSafe('fPanelMain... ');
  with Self.Screen.GetByName('PanelMain') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('PM_PanelMsg') do
    begin
      SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth, ClientSize.Y));
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('PM_WinMsg') do
    begin
      SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth, ClientSize.Y));
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('PM_Ship').Parent do
    begin
      SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('PM_ImageBG') as TImageGI do
      begin
        SetPosition(Classes.Point(0, 0));
        SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
      end;
      with FindByNameRecursive('PM_Ship') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_Gal') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_Quest') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_EndTurn') as TGraphButtonGI do
        if GiResourceVariant = 2 then
          SetPosition(Classes.Point(899 + ExtraScreenWidth, 33))
        else
          SetPosition(Classes.Point(702 + ExtraScreenWidth, 25));
      with FindByNameRecursive('PM_Break') as TGraphButtonGI do
        if GiResourceVariant = 2 then
          SetPosition(Classes.Point(899 + ExtraScreenWidth, 33))
        else
          SetPosition(Classes.Point(702 + ExtraScreenWidth, 25));
      with FindByNameRecursive('PM_Logo') do
        if GiResourceVariant = 2 then
          SetPosition(Classes.Point(0, 42))
        else
          SetPosition(Classes.Point(3, 32));
      with FindByNameRecursive('PM_WarningSpace') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_WarningMoney') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_Money') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_FreeSpace') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
      with FindByNameRecursive('PM_Help') do
        SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth, ClientSize.Y));
      with FindByNameRecursive('PM_PanelDate') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y));
    end;
  end;
  AppendLogLineThreadSafe('ok');
  MessagePanel := Self.Screen.GetByName('PM_PanelMsg') as TPanelGI;
  MessagePanelRestTop := MessagePanel.LocalPosition.Y;
  HelpLabel := Self.Screen.GetByName('PM_Help') as TLabelGI;
  BackgroundImage := Self.Screen.GetByName('PM_ImageBG') as TImageGI;
  ShipButton := Self.Screen.GetByName('PM_Ship') as TGraphButtonGI;
  GalaxyButton := Self.Screen.GetByName('PM_Gal') as TGraphButtonGI;
  QuestButton := Self.Screen.GetByName('PM_Quest') as TGraphButtonGI;
  EndTurnButton := Self.Screen.GetByName('PM_EndTurn') as TGraphButtonGI;
  MenuButton := Self.Screen.GetByName('PM_Logo') as TGraphButtonGI;
  (Self.Screen.GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  ShipButton.UpCallback := ShipClicked;
  QuestButton.UpCallback := QuestClicked;
  GalaxyButton.UpCallback := GalaxyClicked;
  MenuButton.UpCallback := MenuClicked;
  DateLabel := Self.Screen.GetByName('PM_Date') as TLabelGI;
  DateNextImage := Self.Screen.GetByName('PM_DateNextImage') as TImageGI;
  NextDateLabel := Self.Screen.GetByName('PM_DateNew') as TLabelGI;
  Self.Screen.SetHelpCallback(ShowControlHelp);
  CurrentDateColor := GetStyleColorGI('PanelMain.TextColor', 200, 240, 255);
  AdvancingDateColor := GetStyleColorGI('PanelMain.DateTransitionColor', 6, 166, 198);
end;
{ @end $759E4C }

{ @routine $75A6E0 TfPanelMain_OnOpen }
procedure TfPanelMain.OnOpen;
begin
  NavigationLocked := False;
  if MessageSlideTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := 0;
  end;
  if MessagePulseTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessagePulseTimer);
    MessagePulseTimer := 0;
  end;
  if StatusTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(StatusTimer);
    StatusTimer := 0;
  end;
  if DateTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(DateTimer);
    DateTimer := 0;
  end;
  StatusTimer := Screen.ScheduleCallbackTimer(200, 200, RefreshStatusTimer);
  MessagePanel.SetPosition(Classes.Point(MessagePanel.LocalPosition.X, MessagePanelRestTop));
  Screen.GetByName('PM_Help').SetActive(False);
  EnableNavigationButtons;
  DisplayedShipId := 0;
  DisplayedPlanetId := 0;
  DisplayedTurn := Galaxy.CurrentTurn;
  DateSlideProgress := 1;
  TargetTurn := Galaxy.CurrentTurn;
  AuxiliaryItems.Clear;
  CargoWarningActive := False;
  MoneyWarningActive := False;
  RefreshMoneyAndCargo;
end;
{ @end $75A6E0 }

{ @routine $75A7F0 TfPanelMain_OnClose }
procedure TfPanelMain.OnClose;
begin
  NavigationLocked := False;
  if StatusTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(StatusTimer);
    StatusTimer := 0;
  end;
  if MessagePulseTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessagePulseTimer);
    MessagePulseTimer := 0;
  end;
  if MessageSlideTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := 0;
  end;
  if DateTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(DateTimer);
    DateTimer := 0;
  end;
  if CargoWarningTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(CargoWarningTimer);
    CargoWarningTimer := 0;
  end;
  if MoneyWarningTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := 0;
  end;
  AuxiliaryItems.Clear;
end;
{ @end $75A7F0 }

{ @routine $75A88C TfPanelMain_Show }
procedure TfPanelMain.Show;
begin
  Screen.GetByName('PanelMain').SetActive(True);
  Screen.GetByName('PM_Help').SetActive(False);
  EnableNavigationButtons;
end;
{ @end $75A88C }

{ @routine $75A8EC TfPanelMain_Hide }
procedure TfPanelMain.Hide;
begin
  Screen.GetByName('PanelMain').SetActive(False);
end;
{ @end $75A8EC }

{ @routine $75A920 TfPanelMain_RefreshMoneyAndCargo }
procedure TfPanelMain.RefreshMoneyAndCargo;
var
  FreeSpace: Integer;
begin
  if (CurrentScreenId <> screen_star_map) or (StarMapScreen.Mode = map_mode_orders) then
  begin
    TargetTurn := Galaxy.CurrentTurn;
    if (DisplayedTurn < TargetTurn) and (DateSlideProgress >= 1) then
      DateSlideProgress := 0;
    RefreshDate;
  end;
  if GetPlayer <> nil then
  begin
    if MoneyWarningActive and ((MoneyWarningTicks and 1) = 0) then
    begin
      Screen.GetByName('PM_WarningMoney').SetActive(True);
      (Screen.GetByName('PM_Money') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 128, 61));
    end
    else
    begin
      Screen.GetByName('PM_WarningMoney').SetActive(False);
      (Screen.GetByName('PM_Money') as TLabelGI).SetTextColor(CurrentDateColor);
    end;
    (Screen.GetByName('PM_Money') as TLabelGI).Text := IntToStr(GetPlayer.Money);
    FreeSpace := GetPlayer.GetCargoFreeSpace;
    if (CargoWarningActive and ((CargoWarningTicks and 1) = 0)) or ((FreeSpace < 0) and not CargoWarningActive) then
    begin
      Screen.GetByName('PM_WarningSpace').SetActive(True);
      (Screen.GetByName('PM_FreeSpace') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 128, 61));
    end
    else
    begin
      Screen.GetByName('PM_WarningSpace').SetActive(False);
      (Screen.GetByName('PM_FreeSpace') as TLabelGI).SetTextColor(CurrentDateColor);
    end;
    (Screen.GetByName('PM_FreeSpace') as TLabelGI).Text := IntToStr(FreeSpace);
  end
  else
  begin
    (Screen.GetByName('PM_Money') as TLabelGI).Text := '';
    (Screen.GetByName('PM_FreeSpace') as TLabelGI).Text := '';
  end;
end;
{ @end $75A920 }

{ @routine $75AC38 TfPanelMain_RefreshDate }
procedure TfPanelMain.RefreshDate;
var X: Integer;
begin
  DateLabel.SetText(Galaxy.FormatTurnDate(DisplayedTurn));
  if DisplayedTurn < TargetTurn then
    NextDateLabel.SetText(Galaxy.FormatTurnDate(DisplayedTurn + 1))
  else NextDateLabel.SetText(Galaxy.FormatTurnDate(DisplayedTurn));
  X := -Round((DateLabel.ClientSize.X + DateNextImage.ClientSize.X) * DateSlideProgress);
  DateLabel.SetPosition(Classes.Point(X, 0));
  DateNextImage.SetPosition(Classes.Point(X + DateLabel.ClientSize.X, DateNextImage.LocalPosition.Y));
  NextDateLabel.SetPosition(Classes.Point(X + DateLabel.ClientSize.X + DateNextImage.ClientSize.X, 0));
  if (DisplayedTurn >= TargetTurn) or ((DisplayedTurn >= TargetTurn - 1) and (DateSlideProgress >= 1)) then
  begin
    DateLabel.SetTextColor(CurrentDateColor);
    NextDateLabel.SetTextColor(CurrentDateColor);
  end
  else
  begin
    DateLabel.SetTextColor(AdvancingDateColor);
    NextDateLabel.SetTextColor(AdvancingDateColor);
  end;
end;
{ @end $75AC38 }

{ @routine $75ADBC TfPanelMain_SetDateRange }
procedure TfPanelMain.SetDateRange(FirstTurn, LastTurn: Integer);
begin
  DisplayedTurn := FirstTurn;
  TargetTurn := LastTurn;
  if DisplayedTurn > TargetTurn then DisplayedTurn := TargetTurn;
  if DisplayedTurn <> TargetTurn then DateSlideProgress := 0
  else DateSlideProgress := 1;
  RefreshDate;
end;
{ @end $75ADBC }

{ @routine $75ADE8 TfPanelMain_StartDateAnimation }
procedure TfPanelMain.StartDateAnimation(IntervalMs: Integer);
begin
  if (DisplayedTurn < TargetTurn) and ((DisplayedTurn < TargetTurn - 1) or (DateSlideProgress < 1)) then
  begin
    if DateTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(DateTimer);
      DateTimer := 0;
    end;
    DateTimerIntervalMs := IntervalMs;
    DateTimer := Screen.ScheduleCallbackTimer(IntervalMs, IntervalMs, AdvanceDateAnimation);
  end;
end;
{ @end $75ADE8 }

{ @routine $75AE48 TfPanelMain_AdvanceDateAnimation }
procedure TfPanelMain.AdvanceDateAnimation(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  DateSlideProgress := (TargetTurn - DisplayedTurn) * 0.01 * (TargetTurn - DisplayedTurn) + DateSlideProgress;
  if DateSlideProgress >= 1 then
  begin
    Inc(DisplayedTurn);
    if TargetTurn - DisplayedTurn > 300 then DisplayedTurn := TargetTurn - 10;
    if DisplayedTurn >= TargetTurn then
    begin
      DateSlideProgress := 1;
      if DateTimer <> 0 then
      begin
        Screen.CancelCallbackTimer(DateTimer);
        DateTimer := 0;
        StartScriptRequestThread;
      end;
    end
    else DateSlideProgress := 0;
  end;
  RefreshDate;
end;
{ @end $75AE48 }

{ @routine $75AEF0 TfPanelMain_EndTurnClicked }
procedure TfPanelMain.EndTurnClicked(Sender: TObjectGI);
var
  Event: TGalaxyEvent;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if GetPlayer = nil then Exit;
  if (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId = owner_dominator) then Exit;
  if GetPlayer.QueuedTravelTarget <> nil then Exit;
  if GetPlayer.RuinsMode <> 0 then Exit;
  if Screen.ParentLoop <> nil then Exit;
  if (GetPlayer <> nil) and (GetPlayer.CurrentPlanet <> nil) and
    (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile) then
  begin
    if Screen <> GovernmentScreen then
    begin
      RequestedScreenId := screen_government;
      Screen.RequestClose(1);
    end;
    Exit;
  end;
  if not IsTurnCalculationRunningUI then
  begin
    TryAutoTurnSave;
    SoundManager.PlaySound('Sound.Turn');
    PruneExpiredPersistentPlayerMessages;
    CalculatePlayerStarTurnAndWait;
    if ExitScreenLoop then Exit;
    if GetPlayer <> nil then
    begin
      Inc(Galaxy.CurrentTurn);
      RefreshEndTurnButton;
      StartDateAnimation(10);
      Dec(Galaxy.CurrentTurn);
      CalculateGalaxyTurnAndWait;
    end;
  end;
  if (GetPlayer = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId = owner_dominator)) then
  begin
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('PlanetCaptured');
    GameEndReason := game_end_player_death;
    RequestedScreenId := screen_game_end;
    Screen.RequestClose(1);
    Exit;
  end;
  PostMouseMoveMessage;
  if (GetPlayer.PendingDockDialogue > 0) and (GetPlayer.DockedTo <> nil) then
  begin
    RequestedScreenId := screen_ruins_talk;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
    Exit;
  end;
  if (GetPlayer.PendingDockDialogue > 0) and (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId <> owner_uninhabited) then
  begin
    RequestedScreenId := screen_government;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;
{ @end $75AEF0 }

{ @routine $75B18C TfPanelMain_ShipClicked }
procedure TfPanelMain.ShipClicked(Sender: TObjectGI);
var
  Changed: Boolean;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  if Screen.ExitCode <> 0 then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.ShowCursor := True;
  Changed := False;
  ShipScreen.PlayTransitionSounds := True;
  Galaxy.CheckIntegrityChecksum(109);
  while True do
  begin
    ClearMessageButtons;
    RunShipEquipment(Screen);
    RebuildMessageButtons(False);
    PostMouseMove;
    if ShipScreen.ShipStateChanged then Changed := True;
    RefreshMoneyAndCargo;
    RebuildMessageButtons(False);
    if not ShipScreen.ReopenRequested then Break;
    Screen.ShowCursor := False;
    FullFrameRedrawRequested := True;
    Screen.InvalidateViewport;
    Screen.DrawQueuedUpdateRects;
    CaptureScreenBackground(True, 0);
    Screen.ShowCursor := True;
  end;
  Galaxy.PrimeIntegrityChecksum(110);
  ShipScreen.ShipStateChanged := Changed;
  if GetPlayer.IsOnPlanet and (Screen <> GovernmentScreen) then
    if GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = relation_level_hostile then
    begin
      RequestedScreenId := screen_government;
      Screen.RequestClose(1);
    end;
end;
{ @end $75B18C }

{ @routine $75B33C TfPanelMain_QuestClicked }
procedure TfPanelMain.QuestClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Screen.ExitCode <> 0 then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.ShowCursor := True;
  Galaxy.CheckIntegrityChecksum(107);
  ClearMessageButtons;
  ShowRangerRating(Screen);
  RebuildMessageButtons(False);
  PostMouseMove;
  Galaxy.PrimeIntegrityChecksum(108);
end;
{ @end $75B33C }

{ @routine $75B428 TfPanelMain_GalaxyClicked }
procedure TfPanelMain.GalaxyClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  if Screen.ExitCode <> 0 then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.ShowCursor := True;
  GalaxyScreen.ViewMode := 1;
  Galaxy.CheckIntegrityChecksum(140);
  ClearMessageButtons;
  RunGalaxyMap(Screen);
  RebuildMessageButtons(False);
  PostMouseMove;
  Galaxy.PrimeIntegrityChecksum(141);
end;
{ @end $75B428 }

{ @routine $75B524 TfPanelMain_JournalClicked }
procedure TfPanelMain.JournalClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Screen.ExitCode <> 0 then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.ShowCursor := True;
  Galaxy.CheckIntegrityChecksum(102);
  ClearMessageButtons;
  RunJournal(Screen);
  RebuildMessageButtons(False);
  PostMouseMove;
  Galaxy.PrimeIntegrityChecksum(103);
end;
{ @end $75B524 }

{ @routine $75B610 TfPanelMain_MenuClicked }
procedure TfPanelMain.MenuClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Screen.ParentLoop <> nil then Exit;
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureScreenBackground(True, 0);
  CaptureSavePreview;
  Galaxy.CheckIntegrityChecksum(98);
  CaptureGalaxyPreview(Screen);
  Galaxy.PrimeIntegrityChecksum(99);
  Screen.ShowCursor := True;
  GameMenuReturnScreenId := FormToId(Screen);
  RequestedScreenId := screen_game_menu;
  Screen.RequestClose(1);
end;
{ @end $75B610 }

{ @routine $75B6C8 TfPanelMain_TryAutoTurnSave }
procedure TfPanelMain.TryAutoTurnSave;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Galaxy.IronWill then Exit;
  if TurnSaveStep = 0 then Exit;
  if (Galaxy.CurrentTurn mod TurnSaveStep) <> 0 then Exit;
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureSavePreview;
  CaptureGalaxyPreview(Screen);
  Screen.ShowCursor := False;
  SaveManagerReturnScreenId := FormToId(Screen);
  SaveGameToFile(SaveManagerScreen.GetTurnSavePath, 'TurnSave');
  Screen.ShowCursor := True;
end;
{ @end $75B6C8 }

{ @routine $75B7F8 TfPanelMain_QuickSave }
procedure TfPanelMain.QuickSave;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if GetInnermostScreenLoop.ParentLoop <> nil then Exit;
  if Galaxy.IronWill then
  begin
    ShowMessageBoxGI(Screen, LocalizedColorText('FormGameSet2.IronWillText'), mbgCancel or mbgUnused04);
    FullFrameRedrawRequested := True;
    Exit;
  end;
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  Screen.ShowCursor := False;
  Screen.Present;
  CaptureSavePreview;
  Galaxy.CheckIntegrityChecksum(132);
  CaptureGalaxyPreview(Screen);
  Screen.ShowCursor := False;
  SaveManagerReturnScreenId := FormToId(Screen);
  SaveGameToFile(SaveManagerScreen.GetQuickSavePath(1), 'QuickSave');
  Galaxy.PrimeIntegrityChecksum(133);
  Screen.ShowCursor := True;
end;
{ @end $75B7F8 }

{ @routine $75B9A8 TfPanelMain_QuickLoad }
procedure TfPanelMain.QuickLoad(SlotIndex: Integer);
var
  Text: WideString;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if GetInnermostScreenLoop.ParentLoop <> nil then Exit;
  Screen.ShowCursor := False;
  if SaveManagerScreen.QuickSaveExists(SlotIndex) then
  begin
    if (QuickSaveExtraSlots > 0) or (SlotIndex > 1) then
      Text := ReplaceColoredToken(LookupLocalizedTextByKey('FormSaveManager.QueryQuickN'), '<Num>', IntToStr(SlotIndex), TextHighlightColorTag)
    else
      Text := LookupLocalizedTextByKey('FormSaveManager.QueryQuick');
    if ShowMessageBoxGI(Screen, Text, mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      PendingLoadFileName := AnsiString(SaveManagerScreen.GetQuickSavePath(SlotIndex));
      RequestedScreenId := screen_save_loading;
      Screen.RequestClose(1);
      Exit;
    end;
  end
  else if QuickSaveExtraSlots + 1 >= SlotIndex then
  begin
    if QuickSaveExtraSlots > 0 then
      Text := ReplaceColoredToken(LookupLocalizedTextByKey('FormSaveManager.QuickNotExistN'), '<Num>', IntToStr(SlotIndex), TextHighlightColorTag)
    else
      Text := LookupLocalizedTextByKey('FormSaveManager.QuickNotExist');
    ShowMessageBoxGI(Screen, Text, mbgOK or mbgUnused04);
    FullFrameRedrawRequested := True;
  end;
  Screen.ShowCursor := True;
  Screen.Present;
end;
{ @end $75B9A8 }

{ @routine $75BCF8 TfPanelMain_RefreshStatusTimer }
procedure TfPanelMain.RefreshStatusTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  RefreshEndTurnButton;
end;
{ @end $75BCF8 }

{ @routine $75BD00 TfPanelMain_PulseUnreadMessages }
procedure TfPanelMain.PulseUnreadMessages(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  Control: TObjectGI;
  Finished: Boolean;
  MessageEntry: TMessagePlayer;
  Alpha: Byte;
  Stage: Integer; // Native diagnostic-stage assignments are retained although not consumed.
begin
  PersistentPlayerMessageLock.Enter;
  Stage := 0;
  try
    Inc(MessagePulseStep);
    Finished := True;
    if MessagePanel.Active = True then
    begin
      Stage := 1;
      MessagePulseStep := MessagePulseStep mod 32;
      if MessagePulseStep < 16 then Alpha := 255 - MessagePulseStep * 8
      else Alpha := 127 + (MessagePulseStep - 16) * 8;
      Control := MessagePanel.FirstChild;
      while Control <> nil do
      begin
        Stage := 2;
        MessageEntry := TMessagePlayer(Control.UserValue);
        if IsPersistentPlayerMessageQueued(MessageEntry, True) and (MessageEntry.Button = TGraphButtonGI(Control)) then
        begin
          Stage := 3;
          if Control is TGraphButtonGI then
          begin
            Stage := 4;
            if (MessageEntry.Kind in [message_galaxy_news, message_tip]) and not MessageEntry.WasRead then
            begin
              Stage := 5;
              with Control as TGraphButtonGI do
              begin
                LoadGiByPathIntoGraphBuf('Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetNormalImageName,
                  ImageNormal.GraphBufControl.GraphBuf);
                Stage := 6;
                ImageNormal.GraphBufControl.GraphBuf.ScaleAlpha(Classes.Rect(0, 0,
                  ImageNormal.GraphBufControl.GraphBuf.Width, ImageNormal.GraphBufControl.GraphBuf.Height), Alpha);
                Stage := 7;
                Finished := False;
                Invalidate;
                Stage := 8;
              end;
            end
            else if ((Control as TGraphButtonGI).ImageNormal <> nil) and
              ((Control as TGraphButtonGI).ImageNormal.GraphBufControl <> nil) then
            begin
              Stage := 9;
              (Control as TGraphButtonGI).ImageNormal.SetImagePath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetNormalImageName);
              Stage := 10;
              (Control as TGraphButtonGI).Invalidate;
            end;
          end;
        end;
        Stage := 11;
        Control := Control.NextSibling;
      end;
    end;
    Stage := 12;
    if Finished then
      if MessagePulseTimer <> 0 then
      begin
        Screen.CancelCallbackTimer(MessagePulseTimer);
        MessagePulseTimer := 0;
      end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $75BD00 }

{ @routine $75C034 TfPanelMain_RefreshEndTurnButton }
procedure TfPanelMain.RefreshEndTurnButton;
var Button: TGraphButtonGI;
begin
  Button := EndTurnButton;
  if IsTurnCalculationRunningUI then Button.SetDisabled(True)
  else Button.SetDisabled(False);
  RefreshMoneyAndCargo;
end;
{ @end $75C034 }

{ @routine $75C064 TfPanelMain_DisableNavigationButtons }
procedure TfPanelMain.DisableNavigationButtons;
var Control: TObjectGI;
begin
  (Screen.GetByName('PM_Ship') as TGraphButtonGI).SetDisabled(True);
  (Screen.GetByName('PM_Gal') as TGraphButtonGI).SetDisabled(True);
  (Screen.GetByName('PM_Quest') as TGraphButtonGI).SetDisabled(True);
  EndTurnButton.SetActive(False);
  Control := Screen.GetByName('PM_Break');
  Control.HelpCallback := ShowControlHelp;
  Control.SetActive(True);
  MenuButton.SetDisabled(True);
end;
{ @end $75C064 }

{ @routine $75C158 TfPanelMain_EnableNavigationButtons }
procedure TfPanelMain.EnableNavigationButtons;
var Control: TObjectGI;
begin
  (Screen.GetByName('PM_Ship') as TGraphButtonGI).SetDisabled(False);
  (Screen.GetByName('PM_Gal') as TGraphButtonGI).SetDisabled(False);
  (Screen.GetByName('PM_Quest') as TGraphButtonGI).SetDisabled(False);
  EndTurnButton.SetActive(True);
  Control := Screen.GetByName('PM_Break');
  Control.HelpCallback := nil;
  Control.SetActive(False);
  MenuButton.SetDisabled(False);
  PostMouseMoveMessage;
end;
{ @end $75C158 }

{ @routine $75C250 TfPanelMain_RebuildMessageButtons }
procedure TfPanelMain.RebuildMessageButtons(SkipLock: Boolean);
var
  Panel: TPanelGI;
  MessageEntry: TMessagePlayer;
  Button: TGraphButtonGI;
  Count, MaxCount, X: Integer;
begin
  ClearMessageButtons;
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    Screen.GetByName('PM_Help').SetActive(False);
    if FirstPersistentPlayerMessage = nil then Exit;
    DisplayedShipId := 0;
    DisplayedPlanetId := 0;
    Panel := Screen.GetByName('PM_PanelMsg') as TPanelGI;
    Panel.SetActive(True);
    Screen.GetByName('PM_WinMsg').SetActive(False);
    MessageEntry := LastPersistentPlayerMessage;
    Count := 0;
    MaxCount := (Panel.ClientSize.X - 44) div 22;
    while (MessageEntry <> nil) and (Count < MaxCount) do
    begin
      Inc(Count);
      MessageEntry := MessageEntry.Prev;
    end;
    if MessageEntry = nil then MessageEntry := FirstPersistentPlayerMessage;
    X := 0;
    while MessageEntry <> nil do
    begin
      Button := TGraphButtonGI.Create(Panel);
      Button.UserValue := Integer(MessageEntry);
      MessageEntry.Button := Button;
      Button.MouseEnterCallback := MessageMouseEnter;
      Button.MouseLeaveCallback := MessageMouseLeave;
      Button.RightButtonDownCallback := MessageRightButtonDown;
      Button.UpCallback := MessageClicked;
      Button.EnterSound := 'Sound.ButtonInfoEnter';
      Button.LeaveSound := 'Sound.ButtonInfoLeave';
      Button.ClickSound := 'Sound.ButtonInfoClick';
      if (MessageEntry.Kind = message_radio) and (GetPlayer <> nil) and
        ((MessageEntry.Targets[0].ShipId = GetPlayer.Id) or
        (MessageEntry.Targets[1].ShipId = GetPlayer.Id) or
        (MessageEntry.Targets[2].ShipId = GetPlayer.Id)) then MessageEntry.Kind := message_radio_with_player;
      if (MessageEntry.Kind in [message_galaxy_news, message_tip]) and not MessageEntry.WasRead then
      begin
        Button.SetImageNormalPath('GraphBuf');
        Button.ImageNormal.GraphBufControl.SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf('Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetNormalImageName,
          Button.ImageNormal.GraphBufControl.GraphBuf);
        Button.ImageNormal.SetSize(Button.ImageNormal.GetContentSize);
        if MessagePulseTimer = 0 then
          MessagePulseTimer := Screen.ScheduleCallbackTimer(40, 40, PulseUnreadMessages);
      end
      else
        Button.SetImageNormalPath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetNormalImageName);
      Button.SetImageNormalActivePath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetActiveImageName);
      Button.SetImageDownPath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetPressedImageName);
      Button.HitKind := button_hit_bounds;
      Button.SetSize(Button.GetMaxStateImageSize);
      Button.SetPosition(Classes.Point(X, Panel.ClientSize.Y div 2 - Button.ClientSize.Y div 2));
      X := X + Button.ClientSize.X + 2;
      Button.UpdateStateImagePlacement;
      Button.UpdateStateVisuals;
      MessageEntry := MessageEntry.Next;
    end;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
  PlayUnreadMessageSounds;
  SlideMessagesIn;
  PostMouseMove;
end;
{ @end $75C250 }

{ @routine $75C7AC TfPanelMain_ClearMessageButtons }
procedure TfPanelMain.ClearMessageButtons;
var
  Panel: TPanelGI;
  MessageEntry: TMessagePlayer;
begin
  if MessagePulseTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessagePulseTimer);
    MessagePulseTimer := 0;
  end;
  Panel := Screen.GetByName('PM_PanelMsg') as TPanelGI;
  Panel.SetActive(False);
  Panel.FreeOwnedChildren;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  MessageEntry := LastPersistentPlayerMessage;
  while MessageEntry <> nil do
  begin
    MessageEntry.Button := nil;
    MessageEntry := MessageEntry.Prev;
  end;
end;
{ @end $75C7AC }

{ @routine $75C854 TfPanelMain_RemoveDismissibleMessages }
function TfPanelMain.RemoveDismissibleMessages(Key: WideString): Boolean;
begin
  Result := False;
  if RemovePlayerMessagesExceptKinds(Key, [message_quest_active, message_storage], False) then
  begin
    RebuildMessageButtons(False);
    SoundManager.PlaySound('Sound.DelMsg');
    Result := True;
  end;
end;
{ @end $75C854 }

{ @routine $75C8F0 TfPanelMain_MessageMouseEnter }
procedure TfPanelMain.MessageMouseEnter(Sender: TObjectGI);
var
  MessageEntry: TMessagePlayer;
  Panel: TPanelGI;
  Window: TWindowGI;
  LabelControl: TLabelGI;
begin
  PersistentPlayerMessageLock.Enter;
  try
    MessageEntry := TMessagePlayer(Sender.UserValue);
    if not IsPersistentPlayerMessageQueued(MessageEntry, True) then Exit;
    Panel := Screen.GetByName('PM_PanelMsg') as TPanelGI;
    Window := Screen.GetByName('PM_WinMsg') as TWindowGI;
    LabelControl := Screen.GetByName('PM_LabelMsg') as TLabelGI;
    LabelControl.SetTextAlignY(text_y_fit_height);
    LabelControl.SetText(MessageEntry.Text);
    LabelControl.SetTextAlignY(text_y_font_center);
    Window.SetSize(Classes.Point(LabelControl.ClientSize.X + Window.WorkSubRect.Left + Window.WorkSubRect.Right,
      LabelControl.ClientSize.Y + Window.WorkSubRect.Top + Window.WorkSubRect.Bottom));
    Window.UpdateAutoGeometry;
    Window.SetPosition(Classes.Point(Window.LocalPosition.X, Panel.LocalPosition.Y - Window.ClientSize.Y - 5 - 5));
    Window.SetActive(True);
    LabelControl.SetSize(Classes.Point(Window.ClientSize.X - Window.WorkSubRect.Left - Window.WorkSubRect.Right,
      Window.ClientSize.Y - Window.WorkSubRect.Top - Window.WorkSubRect.Bottom));
    if not MessageEntry.WasRead then
    begin
      MessageEntry.WasRead := True;
      if MessageEntry.Kind = message_tip then MessageEntry.Turn := Galaxy.CurrentTurn;
    end;
    LabelControl.SetPosition(Window.WorkSubRect.TopLeft);
    Window.SetPosition(Classes.Point(Sender.HitTestBounds.Left + Sender.ClientSize.X div 2,
      Sender.HitTestBounds.Top - Window.ClientSize.Y - 5));
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $75C8F0 }

{ @routine $75CB20 TfPanelMain_MessageMouseLeave }
procedure TfPanelMain.MessageMouseLeave(Sender: TObjectGI);
begin
  Screen.GetByName('PM_WinMsg').SetActive(False);
end;
{ @end $75CB20 }

{ @routine $75CB54 TfPanelMain_DeleteMessage }
procedure TfPanelMain.DeleteMessage(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint; SkipLock: Boolean);
var
  MessageEntry: TMessagePlayer;
  Control: TObjectGI;
  Animation: TgaiGI;
begin
  if not SkipLock then PersistentPlayerMessageLock.Enter;
  try
    MessageEntry := TMessagePlayer(Sender.UserValue);
    if not IsPersistentPlayerMessageQueued(MessageEntry, True) then Exit;
    if MessageEntry.Kind in [message_quest_active, message_storage] then Exit;
    Control := MessagePanel.FirstChild;
    while Control <> nil do
    begin
      if (Control is TgaiGI) and Control.Active then Break;
      Control := Control.NextSibling;
    end;
    if Control <> nil then
    begin
      if AuxiliaryItems.IndexOf(MessageEntry) < 0 then AuxiliaryItems.Add(MessageEntry);
    end
    else
    begin
      Screen.GetByName('PM_WinMsg').SetActive(False);
      SoundManager.PlaySound('Sound.DelMsg');
      Sender.SetActive(False);
      Animation := TgaiGI.Create(MessagePanel);
      Animation.SetImagePath('Bm.PanelMain2.MsgDel');
      Animation.SequenceIndex := 0;
      Animation.UpdateAutoGeometry;
      Animation.SetSize(Animation.GetContentSize);
      Animation.SetOrigin(HalfPoint(Animation.ClientSize));
      Animation.SetPosition(AddPoints(Sender.LocalPosition, HalfPoint(Sender.ClientSize)));
      Animation.RestartPlayback;
      Animation.FrameAdvancedCallback := AdvanceMessageDeletion;
      Animation.CycleCompleteCallback := FinishMessageDeletion;
      Animation.UserValue := Integer(MessageEntry);
      Animation.UserIndex := Integer(Sender);
      Control := MessagePanel.FirstChild;
      while Control <> nil do
      begin
        Control.UserState := Control.LocalPosition.X;
        Control := Control.NextSibling;
      end;
    end;
  finally
    if not SkipLock then PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $75CB54 }

{ @routine $75CDB4 TfPanelMain_MessageRightButtonDown }
procedure TfPanelMain.MessageRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  DeleteMessage(Sender, KeyState, Point, False);
  BreakUiMessage;
end;
{ @end $75CDB4 }

{ @routine $75CDE0 TfPanelMain_AdvanceMessageDeletion }
procedure TfPanelMain.AdvanceMessageDeletion(Sender: TObjectGI);
var
  Progress: Double;
  Control, DeletedButton: TObjectGI;
begin
  DeletedButton := TObjectGI(Sender.UserIndex);
  Progress := (Sender as TgaiGI).SequenceFrame / (Sender as TgaiGI).SequenceFrameCount;
  Control := MessagePanel.FirstChild;
  while Control <> nil do
  begin
    if Control is TGraphButtonGI then
      Control.SetPosition(Classes.Point(Control.UserState, Control.LocalPosition.Y));
    Control := Control.NextSibling;
  end;
  if (Screen.GetByName('PM_PanelMsg').ClientSize.X - 22) div 22 < CountPersistentPlayerMessages then
  begin
    Control := DeletedButton.PrevSibling;
    while Control <> nil do
    begin
      if Control is TGraphButtonGI then
        Control.SetPosition(Classes.Point(Control.LocalPosition.X + Round((DeletedButton.ClientSize.X + 2) * Progress), Control.LocalPosition.Y));
      Control := Control.PrevSibling;
    end;
  end
  else
  begin
    Control := DeletedButton.NextSibling;
    while Control <> nil do
    begin
      if Control is TGraphButtonGI then
        Control.SetPosition(Classes.Point(Control.LocalPosition.X - Round((DeletedButton.ClientSize.X + 2) * Progress), Control.LocalPosition.Y));
      Control := Control.NextSibling;
    end;
  end;
  PostMouseMove;
end;
{ @end $75CDE0 }

{ @routine $75CF60 TfPanelMain_FinishMessageDeletion }
procedure TfPanelMain.FinishMessageDeletion(Sender: TObjectGI);
var
  MessageEntry: TMessagePlayer;
  Control: TObjectGI;
begin
  PersistentPlayerMessageLock.Enter;
  try
    if not IsPersistentPlayerMessageQueued(TMessagePlayer(Sender.UserValue), True) then Exit;
    RemovePersistentPlayerMessage(TMessagePlayer(Sender.UserValue), True);
    // Native retains this cast even though the with-scope uses the outer Sender.
    with Sender as TgaiGI do Sender.Free;
    RebuildMessageButtons(True);
    if AuxiliaryItems.Count > 0 then
    begin
      MessageEntry := AuxiliaryItems[0];
      Control := MessagePanel.FirstChild;
      while Control <> nil do
      begin
        if TMessagePlayer(Control.UserValue) = MessageEntry then Break;
        Control := Control.NextSibling;
      end;
      if Control <> nil then
      begin
        AuxiliaryItems.Delete(0);
        try
          DeleteMessage(Control, 0, Classes.Point(0, 0), True);
        except
        end;
        Exit;
      end;
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $75CF60 }

{ @routine $75D074 TfPanelMain_SlideMessagesIn }
procedure TfPanelMain.SlideMessagesIn;
begin
  MessageSlideDirection := -1;
  if MessageSlideTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := 0;
  end;
  if MessagePanel.LocalPosition.Y > MessagePanelRestTop then
    MessageSlideTimer := Screen.ScheduleCallbackTimer(10, 10, AdvanceMessageSlide);
end;
{ @end $75D074 }

{ @routine $75D0C0 TfPanelMain_SlideMessagesOut }
procedure TfPanelMain.SlideMessagesOut;
begin
  MessageSlideDirection := 1;
  if MessageSlideTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := 0;
  end;
  if MessagePanel.LocalPosition.Y < Integer(GameScreenHeight) - 5 then
    MessageSlideTimer := Screen.ScheduleCallbackTimer(10, 10, AdvanceMessageSlide);
end;
{ @end $75D0C0 }

{ @routine $75D114 TfPanelMain_AdvanceMessageSlide }
procedure TfPanelMain.AdvanceMessageSlide(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if MessageSlideDirection < 0 then
  begin
    if MessagePanel.LocalPosition.Y <= MessagePanelRestTop then
    begin
      if MessageSlideTimer <> 0 then
      begin
        Screen.CancelCallbackTimer(MessageSlideTimer);
        MessageSlideTimer := 0;
      end;
      Exit;
    end;
    MessagePanel.SetPosition(Classes.Point(MessagePanel.LocalPosition.X, MessagePanel.LocalPosition.Y + MessageSlideDirection));
  end
  else
  begin
    if MessagePanel.LocalPosition.Y >= Integer(GameScreenHeight) - 5 then
    begin
      if MessageSlideTimer <> 0 then
      begin
        Screen.CancelCallbackTimer(MessageSlideTimer);
        MessageSlideTimer := 0;
      end;
      Exit;
    end;
    MessagePanel.SetPosition(Classes.Point(MessagePanel.LocalPosition.X, MessagePanel.LocalPosition.Y + MessageSlideDirection));
  end;
end;
{ @end $75D114 }

{ @routine $75D1B0 TfPanelMain_MessageClicked }
procedure TfPanelMain.MessageClicked(Sender: TObjectGI);
var
  MessageEntry: TMessagePlayer;
  Ship: TShip;
  Planet: TPlanet;
  ShipId, PlanetId: Cardinal;
  Attempts: Integer;
  FilmObject: TEFilmObj;
begin
  if (CurrentScreenId <> screen_star_map) or
    ((StarMapScreen.Mode <> map_mode_orders) and (StarMapScreen.Mode <> map_mode_playback)) then Exit;
  PersistentPlayerMessageLock.Enter;
  try
    MessageEntry := TMessagePlayer(Sender.UserValue);
    if not IsPersistentPlayerMessageQueued(MessageEntry, True) then Exit;
    Attempts := 0;
    while Attempts < 3 do
    begin
      ShipId := 0;
      PlanetId := 0;
      if (DisplayedShipId = 0) and (DisplayedPlanetId = 0) then
      begin
        ShipId := MessageEntry.Targets[0].ShipId;
        if ShipId < 1 then PlanetId := MessageEntry.Targets[0].PlanetId;
        if (ShipId < 1) and (PlanetId < 1) then Exit;
      end
      else
      begin
        if MessageEntry.Targets[0].ShipId = DisplayedShipId then ShipId := MessageEntry.Targets[1].ShipId
        else if MessageEntry.Targets[1].ShipId = DisplayedShipId then ShipId := MessageEntry.Targets[2].ShipId
        else if MessageEntry.Targets[2].ShipId = DisplayedShipId then ShipId := MessageEntry.Targets[0].ShipId;
        if MessageEntry.Targets[0].PlanetId = DisplayedPlanetId then PlanetId := MessageEntry.Targets[1].PlanetId
        else if MessageEntry.Targets[1].PlanetId = DisplayedPlanetId then PlanetId := MessageEntry.Targets[2].PlanetId
        else if MessageEntry.Targets[2].PlanetId = DisplayedPlanetId then PlanetId := MessageEntry.Targets[0].PlanetId;
        if (ShipId < 1) and (PlanetId < 1) then
        begin
          ShipId := MessageEntry.Targets[0].ShipId;
          if ShipId < 1 then PlanetId := MessageEntry.Targets[0].PlanetId;
        end;
        if (ShipId < 1) and (PlanetId < 1) then Exit;
      end;
      DisplayedShipId := ShipId;
      DisplayedPlanetId := PlanetId;
      if DisplayedShipId <> 0 then
      begin
        if StarMapScreen.Mode = map_mode_orders then
        begin
          Ship := Galaxy.IdToShip(DisplayedShipId, False) as TShip;
          if (Ship <> nil) and Ship.InNormalSpace and (Ship.CurrentStar = GetPlayer.CurrentStar) then
          begin
            StarMapScreen.SetMapCenterManually(TruncatePointF(Ship.Position));
            StarMapScreen.AddMapAnimation(Ship.Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 0);
            StarMapScreen.AddMapAnimation(Ship.Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 200);
            StarMapScreen.AddMapAnimation(Ship.Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 400);
            Break;
          end;
        end
        else
        begin
          FilmObject := SecondaryFilm.FindObjectById('Ship2', DisplayedShipId);
          if (FilmObject <> nil) and (FilmObject.SceneObject <> nil) then
          begin
            StarMapScreen.SetMapCenterManually(TruncatePointF(FilmObject.SceneObject.Position));
            Break;
          end;
        end;
      end
      else if DisplayedPlanetId <> 0 then
      begin
        if StarMapScreen.Mode = map_mode_orders then
        begin
          Planet := Galaxy.IdToPlanet(DisplayedPlanetId, False) as TPlanet;
          if (Planet <> nil) and (Planet.CurrentStar = GetPlayer.CurrentStar) then
          begin
            StarMapScreen.SetMapCenterManually(TruncatePointF(Planet.GetPosition));
            StarMapScreen.AddMapAnimation(Planet.GetPosition, 'Bm.SI.' + GiResourceSuffix + 'Ring', 0);
            StarMapScreen.AddMapAnimation(Planet.GetPosition, 'Bm.SI.' + GiResourceSuffix + 'Ring', 200);
            StarMapScreen.AddMapAnimation(Planet.GetPosition, 'Bm.SI.' + GiResourceSuffix + 'Ring', 400);
            Break;
          end;
        end
        else
        begin
          FilmObject := SecondaryFilm.FindObjectById('Planet', DisplayedPlanetId);
          if (FilmObject <> nil) and (FilmObject.SceneObject <> nil) then
          begin
            StarMapScreen.SetMapCenterManually(TruncatePointF(FilmObject.SceneObject.Position));
            Break;
          end;
        end;
      end;
      Inc(Attempts);
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $75D1B0 }

{ @routine $75D704 TfPanelMain_PlayUnreadMessageSounds }
procedure TfPanelMain.PlayUnreadMessageSounds;
var
  MessageEntry: TMessagePlayer;
  PlayedNew, PlayedLiberation, PlayedQuestOk, PlayedQuestCancel: Boolean;
begin
  PlayedNew := False;
  PlayedLiberation := False;
  PlayedQuestOk := False;
  PlayedQuestCancel := False;
  PersistentPlayerMessageLock.Enter;
  try
    MessageEntry := FirstPersistentPlayerMessage;
    while MessageEntry <> nil do
    begin
      if not MessageEntry.NotificationSoundPlayed then
        if MessageEntry.Kind in [message_galaxy_news..message_tip, message_ship_negative] then
        begin
          if not PlayedQuestOk and (MessageEntry.Kind = message_quest_succeeded) then
          begin
            PlayedQuestOk := True;
            SoundManager.PlaySound('Sound.QuestOk');
          end
          else if not PlayedQuestCancel and (MessageEntry.Kind = message_quest_cancelled) then
          begin
            PlayedQuestCancel := True;
            SoundManager.PlaySound('Sound.QuestCancel');
          end
          else if not PlayedNew and (MessageEntry.NotificationSoundKind = 0) then
          begin
            PlayedNew := True;
            SoundManager.PlaySound('Sound.NewMsg');
          end
          else if not PlayedLiberation and (MessageEntry.NotificationSoundKind = 1) then
          begin
            PlayedLiberation := True;
            SoundManager.PlaySound('Sound.LiberationSystem');
          end;
        end;
      MessageEntry := MessageEntry.Next;
    end;
    MessageEntry := FirstPersistentPlayerMessage;
    while MessageEntry <> nil do
    begin
      MessageEntry.NotificationSoundPlayed := True;
      MessageEntry := MessageEntry.Next;
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $75D704 }

{ @routine $75D8C8 TfPanelMain_FlashMoneyWarning }
procedure TfPanelMain.FlashMoneyWarning;
begin
  if MoneyWarningTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := 0;
  end;
  MoneyWarningTimer := Screen.ScheduleCallbackTimer(100, 100, AdvanceMoneyWarning);
  MoneyWarningActive := True;
  MoneyWarningTicks := 6;
  RefreshMoneyAndCargo;
end;
{ @end $75D8C8 }

{ @routine $75D914 TfPanelMain_AdvanceMoneyWarning }
procedure TfPanelMain.AdvanceMoneyWarning(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  Dec(MoneyWarningTicks);
  if MoneyWarningTicks <= 0 then
  begin
    if MoneyWarningTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(MoneyWarningTimer);
      MoneyWarningTimer := 0;
    end;
    MoneyWarningActive := False;
  end;
  RefreshMoneyAndCargo;
end;
{ @end $75D914 }

{ @routine $75D944 TfPanelMain_FlashCargoWarning }
procedure TfPanelMain.FlashCargoWarning;
begin
  if CargoWarningTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(CargoWarningTimer);
    CargoWarningTimer := 0;
  end;
  CargoWarningTimer := Screen.ScheduleCallbackTimer(100, 100, AdvanceCargoWarning);
  CargoWarningActive := True;
  CargoWarningTicks := 6;
  RefreshMoneyAndCargo;
end;
{ @end $75D944 }

{ @routine $75D99C TfPanelMain_AdvanceCargoWarning }
procedure TfPanelMain.AdvanceCargoWarning(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  Dec(CargoWarningTicks);
  if CargoWarningTicks <= 0 then
  begin
    if CargoWarningTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(CargoWarningTimer);
      CargoWarningTimer := 0;
    end;
    CargoWarningActive := False;
  end;
  RefreshMoneyAndCargo;
end;
{ @end $75D99C }

{ @routine $75D9D8 TfPanelMain_ShowControlHelp }
procedure TfPanelMain.ShowControlHelp(Sender: TObjectGI; Visible: Boolean);
var LabelControl: TLabelGI;
begin
  LabelControl := HelpLabel;
  if (Sender = nil) or (Sender.HelpText = '') then Visible := False;
  if Visible then SlideMessagesOut else SlideMessagesIn;
  LabelControl.SetActive(Visible);
  if Sender = nil then LabelControl.SetText('')
  else LabelControl.SetText(Sender.HelpText);
end;
{ @end $75D9D8 }

{ @routine $75DA34 TfPanelMain_ShowHelpText }
procedure TfPanelMain.ShowHelpText(Text: WideString; Visible: Boolean);
var LabelControl: TLabelGI;
begin
  LabelControl := HelpLabel;
  if Visible then SlideMessagesOut else SlideMessagesIn;
  LabelControl.SetActive(Visible);
  LabelControl.SetText(Text);
end;
{ @end $75DA34 }

{ @routine $75DAA8 TfPanelMain_ProcessKeyDown }
procedure TfPanelMain.ProcessKeyDown(Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if IsTurnCalculationRunningUI then Exit;
  if Key = VK_F2 then
  begin
    if Galaxy.IronWill then
      ShowMessageBoxGI(Screen, LocalizedColorText('FormGameSet2.IronWillText'), mbgCancel or mbgUnused04)
    else if Galaxy.SpecialSimulationMode = 0 then
    begin
      CaptureSavePreview;
      Galaxy.CheckIntegrityChecksum(100);
      CaptureGalaxyPreview(Screen);
      Galaxy.PrimeIntegrityChecksum(101);
      SaveManagerReturnScreenId := FormToId(Screen);
      SaveManagerMode := save_dialog_save;
      RequestedScreenId := screen_save_manager;
      Screen.RequestClose(1);
    end;
  end
  else if Key = VK_F3 then
  begin
    SaveManagerReturnScreenId := FormToId(Screen);
    SaveManagerMode := save_dialog_load;
    RequestedScreenId := screen_save_manager;
    Screen.RequestClose(1);
  end
  else if Key = VK_SPACE then EndTurnClicked(nil)
  else if Key = Ord('M') then GalaxyClicked(nil)
  else if Key = Ord('S') then ShipClicked(nil)
  else if Key = Ord('R') then QuestClicked(nil)
  else if Key = VK_F1 then JournalClicked(nil)
  else if Key = VK_ESCAPE then MenuClicked(nil)
  else if Key = VK_F5 then QuickSave
  else if Key = VK_F6 then QuickLoad(3)
  else if Key = VK_F7 then QuickLoad(2)
  else if Key = VK_F8 then QuickLoad(1)
  else if Key = VK_F11 then
    if not RemoveDismissibleMessages('GOODS') then RemoveDismissibleMessages('');
end;
{ @end $75DAA8 }

{ @routine $75DD64 TfPanelMain_PostMouseMove }
procedure TfPanelMain.PostMouseMove;
var
  Point: TPoint;
begin
  GetCursorPos(Point);
  ScreenToClient(MainWindowHandle, Point);
  PostMessage(MainWindowHandle, WM_MOUSEMOVE, 0, SmallInt(Point.X) or (SmallInt(Point.Y) shl 16));
end;
{ @end $75DD64 }

{ @routine $75DDA4 TMessageLoopGIWithMainPanel_Create }
constructor TMessageLoopGIWithMainPanel.Create;
begin
  inherited Create;
  MainPanel := TfPanelMain.Create;
end;
{ @end $75DDA4 }

{ @routine $75DDEC TMessageLoopGIWithMainPanel_Destroy }
destructor TMessageLoopGIWithMainPanel.Destroy;
begin
  if MainPanel <> nil then
  begin
    MainPanel.Free;
    MainPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $75DDEC }

end.
