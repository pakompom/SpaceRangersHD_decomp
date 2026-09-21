unit fPanelMain;
// Unit bracket (inferred): .text 0x008137D8..0x00818331; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Struct, GI_GraphButton, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types;

type
  TfPanelMain = class(TObjectEx) // @size 0x88
  public
    Screen: TMessageLoopGI; // @offset 0x4
    StatusTimer: PCallbackTimerGI; // @offset 0x8
    MessagePulseTimer: PCallbackTimerGI; // @offset 0xC
    MessageSlideTimer: PCallbackTimerGI; // @offset 0x10
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
    DateTimer: PCallbackTimerGI; // @offset 0x64
    DateTimerIntervalMs: Integer; // @offset 0x68
    AuxiliaryItems: TList; // @offset $6C Owned list of borrowed persistent messages awaiting deletion animation.
    MoneyWarningActive: Boolean; // @offset 0x70
    MoneyWarningTicks: Integer; // @offset 0x74
    MoneyWarningTimer: PCallbackTimerGI; // @offset 0x78
    CargoWarningActive: Boolean; // @offset 0x7C
    CargoWarningTicks: Integer; // @offset 0x80
    CargoWarningTimer: PCallbackTimerGI; // @offset 0x84

    constructor Create; // @addr 0x8138D8
    destructor Destroy; override; // @addr 0x813934
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x813970
    procedure OnOpen; // @addr 0x814340
    procedure OnClose; // @addr 0x8144B8
    procedure RefreshMoneyAndCargo; // @addr 0x814654
    procedure RefreshDate; // @addr 0x8149B0
    procedure SetDateRange(FirstTurn, LastTurn: Integer); // @addr 0x814B88
    procedure StartDateAnimation(IntervalMs: Integer); // @addr 0x814BF4
    procedure AdvanceDateAnimation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $814C84
    procedure RefreshStatusTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $815CE4
    procedure AdvanceMessageSlide(Timer: PCallbackTimerGI; UserData: Integer); // @addr $81740C
    procedure AdvanceMoneyWarning(Timer: PCallbackTimerGI; UserData: Integer); // @addr $817D1C
    procedure AdvanceCargoWarning(Timer: PCallbackTimerGI; UserData: Integer); // @addr $817DEC
    procedure EndTurnClicked(Sender: TObjectGI); // @addr 0x814D70
    procedure ShipClicked(Sender: TObjectGI); // @addr 0x815034
    procedure QuestClicked(Sender: TObjectGI); // @addr 0x815234
    procedure GalaxyClicked(Sender: TObjectGI); // @addr 0x815348
    procedure JournalClicked(Sender: TObjectGI); // @addr 0x815468
    procedure MenuClicked(Sender: TObjectGI); // @addr 0x81557C
    procedure TryAutoTurnSave; // @addr 0x815660
    procedure QuickSave; // @addr 0x8157B0
    procedure QuickLoad(SlotIndex: Integer); // @addr 0x815978
    procedure RefreshEndTurnButton; // @addr 0x8160B0
    procedure DisableNavigationButtons; // @addr 0x8160F0
    procedure EnableNavigationButtons; // @addr 0x816208
    procedure RebuildMessageButtons(SkipLock: Boolean); // @addr $816320
    procedure ClearMessageButtons; // @addr $8168F0
    function RemoveDismissibleMessages(Key: WideString): Boolean; // @addr $8169C4
    procedure MessageMouseEnter(Sender: TObjectGI); // @addr $816A68
    procedure MessageMouseLeave(Sender: TObjectGI); // @addr $816CDC
    procedure DeleteMessage(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint; SkipLock: Boolean); // @addr $816D1C
    procedure MessageRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $816FD4
    procedure AdvanceMessageDeletion(Sender: TObjectGI); // @addr $817010
    procedure FinishMessageDeletion(Sender: TObjectGI); // @addr $8171DC
    procedure MessageClicked(Sender: TObjectGI); // @addr $817500
    procedure PlayUnreadMessageSounds; // @addr $817AB8
    procedure PulseUnreadMessages(Timer: PCallbackTimerGI; UserData: Integer); // @addr $815D00
    procedure ProcessKeyDown(Key: Cardinal); // @addr $817F48
    procedure PostMouseMove; // @addr $818238
    procedure SlideMessagesIn; // @addr 0x817328
    procedure SlideMessagesOut; // @addr 0x817398
    procedure FlashMoneyWarning; // @addr 0x817CB0
    procedure FlashCargoWarning; // @addr 0x817D70
    procedure ShowControlHelp(Sender: TObjectGI; Visible: Boolean); // @addr 0x817E50
    procedure ShowHelpText(Text: WideString; Visible: Boolean); // @addr 0x817EC8

    procedure Show; // @addr 0x8145AC
    procedure Hide; // @addr 0x814618
  end;

  TMessageLoopGIWithMainPanel = class(TMessageLoopGI) // @size 0xD4
  public
    MainPanel: TfPanelMain; // @offset 0xD0
    constructor Create; // @addr 0x818284
    destructor Destroy; override; // @addr 0x8182DC
  end;

var
  CurrentDateColor: Cardinal; // @addr $88B110 Normal date text style, selected during layout.
  AdvancingDateColor: Cardinal; // @addr $88B114 Date-transition text style, selected during layout.

implementation

uses aGalaxy, aScript, aPlayer, Globals, GlobalsV, GR_Main, SysUtils, ThreadCalc, aCalc, fStarMap, GI_Window, GI_GAI, GI_Main, GR_gi, Windows, Messages, fPanelLoad, fShip2, fRating2, fGalaxy2, fJournal, fSaveManager, GI_MessageBox, aConst, EC_Str, aPlanet, aGalaxyStruct, aGalaxyEvent, aSaveLoad, aEFilm, aShip;

{ @routine $8138D8 TfPanelMain_Create }
constructor TfPanelMain.Create;
begin
  inherited Create;
  NavigationLocked := False;
  AuxiliaryItems := TList.Create;
end;
{ @end $8138D8 }

{ @routine $813934 TfPanelMain_Destroy }
destructor TfPanelMain.Destroy;
begin
  AuxiliaryItems.Free;
  inherited Destroy;
end;
{ @end $813934 }

{ @routine $813970 TfPanelMain_InitializeLayout }
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
{ @end $813970 }

{ @routine $814340 TfPanelMain_OnOpen }
procedure TfPanelMain.OnOpen;
begin
  NavigationLocked := False;
  if MessageSlideTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := nil;
  end;
  if MessagePulseTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessagePulseTimer);
    MessagePulseTimer := nil;
  end;
  if StatusTimer <> nil then
  begin
    Screen.CancelCallbackTimer(StatusTimer);
    StatusTimer := nil;
  end;
  if DateTimer <> nil then
  begin
    Screen.CancelCallbackTimer(DateTimer);
    DateTimer := nil;
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
{ @end $814340 }

{ @routine $8144B8 TfPanelMain_OnClose }
procedure TfPanelMain.OnClose;
begin
  NavigationLocked := False;
  if StatusTimer <> nil then
  begin
    Screen.CancelCallbackTimer(StatusTimer);
    StatusTimer := nil;
  end;
  if MessagePulseTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessagePulseTimer);
    MessagePulseTimer := nil;
  end;
  if MessageSlideTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := nil;
  end;
  if DateTimer <> nil then
  begin
    Screen.CancelCallbackTimer(DateTimer);
    DateTimer := nil;
  end;
  if CargoWarningTimer <> nil then
  begin
    Screen.CancelCallbackTimer(CargoWarningTimer);
    CargoWarningTimer := nil;
  end;
  if MoneyWarningTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := nil;
  end;
  AuxiliaryItems.Clear;
end;
{ @end $8144B8 }

{ @routine $8145AC TfPanelMain_Show }
procedure TfPanelMain.Show;
begin
  Screen.GetByName('PanelMain').SetActive(True);
  Screen.GetByName('PM_Help').SetActive(False);
  EnableNavigationButtons;
end;
{ @end $8145AC }

{ @routine $814618 TfPanelMain_Hide }
procedure TfPanelMain.Hide;
begin
  Screen.GetByName('PanelMain').SetActive(False);
end;
{ @end $814618 }

{ @routine $814654 TfPanelMain_RefreshMoneyAndCargo }
procedure TfPanelMain.RefreshMoneyAndCargo;
var
  FreeSpace: Integer;
begin
  if (CurrentScreenId <> screenStarMap) or (StarMapScreen.Mode = smmOrders) then
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
    (Screen.GetByName('PM_Money') as TLabelGI).SetText(WideString(IntToStr(GetPlayer.Money)));
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
    (Screen.GetByName('PM_FreeSpace') as TLabelGI).SetText(WideString(IntToStr(FreeSpace)));
  end
  else
  begin
    (Screen.GetByName('PM_Money') as TLabelGI).SetText('');
    (Screen.GetByName('PM_FreeSpace') as TLabelGI).SetText('');
  end;
end;
{ @end $814654 }

{ @routine $8149B0 TfPanelMain_RefreshDate }
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
{ @end $8149B0 }

{ @routine $814B88 TfPanelMain_SetDateRange }
procedure TfPanelMain.SetDateRange(FirstTurn, LastTurn: Integer);
begin
  DisplayedTurn := FirstTurn;
  TargetTurn := LastTurn;
  if DisplayedTurn > TargetTurn then DisplayedTurn := TargetTurn;
  if DisplayedTurn <> TargetTurn then DateSlideProgress := 0
  else DateSlideProgress := 1;
  RefreshDate;
end;
{ @end $814B88 }

{ @routine $814BF4 TfPanelMain_StartDateAnimation }
procedure TfPanelMain.StartDateAnimation(IntervalMs: Integer);
begin
  if (DisplayedTurn < TargetTurn) and ((DisplayedTurn < TargetTurn - 1) or (DateSlideProgress < 1)) then
  begin
    if DateTimer <> nil then
    begin
      Screen.CancelCallbackTimer(DateTimer);
      DateTimer := nil;
    end;
    DateTimerIntervalMs := IntervalMs;
    DateTimer := Screen.ScheduleCallbackTimer(IntervalMs, IntervalMs, AdvanceDateAnimation);
  end;
end;
{ @end $814BF4 }

{ @routine $814C84 TfPanelMain_AdvanceDateAnimation }
procedure TfPanelMain.AdvanceDateAnimation(Timer: PCallbackTimerGI; UserData: Integer);
begin
  DateSlideProgress := (TargetTurn - DisplayedTurn) * 0.01 * (TargetTurn - DisplayedTurn) + DateSlideProgress;
  if DateSlideProgress >= 1 then
  begin
    Inc(DisplayedTurn);
    if TargetTurn - DisplayedTurn > 300 then DisplayedTurn := TargetTurn - 10;
    if DisplayedTurn >= TargetTurn then
    begin
      DateSlideProgress := 1;
      if DateTimer <> nil then
      begin
        Screen.CancelCallbackTimer(DateTimer);
        DateTimer := nil;
        StartScriptRequestThread;
      end;
    end
    else DateSlideProgress := 0;
  end;
  RefreshDate;
end;
{ @end $814C84 }

{ @routine $814D70 TfPanelMain_EndTurnClicked }
procedure TfPanelMain.EndTurnClicked(Sender: TObjectGI);
var
  Event: TGalaxyEvent;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if GetPlayer = nil then Exit;
  if (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId = Byte(oiDominator)) then Exit;
  if GetPlayer.QueuedTravelTarget <> nil then Exit;
  if GetPlayer.RuinsMode <> 0 then Exit;
  if Screen.ParentLoop <> nil then Exit;
  if (GetPlayer <> nil) and (GetPlayer.CurrentPlanet <> nil) and
    (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) then
  begin
    if Screen <> GovernmentScreen then
    begin
      RequestedScreenId := screenGovernment;
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
  if (GetPlayer = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId = Byte(oiDominator))) then
  begin
    Event := AddGalaxyEvent('PlayerDeath');
    Event.AddTextData('PlanetCaptured');
    GameEndReason := gerPlayerDeath;
    RequestedScreenId := screenGameEnd;
    Screen.RequestClose(1);
  end
  else
  begin
    PostMouseMoveMessage;
    if (GetPlayer.PendingDockDialogue > 0) and (GetPlayer.DockedTo <> nil) then
    begin
      RequestedScreenId := screenRuinsTalk;
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
    end
    else if (GetPlayer.PendingDockDialogue > 0) and (GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentPlanet.OwnerId <> Byte(oiUninhabited)) then
    begin
      RequestedScreenId := screenGovernment;
      TMessageLoopGI(RegisteredScreens[Ord(CurrentScreenId)]).RequestClose(1);
    end;
  end;
end;
{ @end $814D70 }

{ @routine $815034 TfPanelMain_ShipClicked }
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
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.SetCursorActive(True);
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
    Screen.SetCursorActive(False);
    FullFrameRedrawRequested := True;
    Screen.InvalidateViewport;
    Screen.DrawQueuedUpdateRects;
    CaptureScreenBackground(True, 0);
    Screen.SetCursorActive(True);
  end;
  Galaxy.PrimeIntegrityChecksum(110);
  ShipScreen.ShipStateChanged := Changed;
  if GetPlayer.IsOnPlanet and (Screen <> GovernmentScreen) then
    if GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile then
    begin
      RequestedScreenId := screenGovernment;
      Screen.RequestClose(1);
    end;
end;
{ @end $815034 }

{ @routine $815234 TfPanelMain_QuestClicked }
procedure TfPanelMain.QuestClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Screen.ExitCode <> 0 then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.SetCursorActive(True);
  Galaxy.CheckIntegrityChecksum(107);
  ClearMessageButtons;
  ShowRangerRating(Screen);
  RebuildMessageButtons(False);
  PostMouseMove;
  Galaxy.PrimeIntegrityChecksum(108);
end;
{ @end $815234 }

{ @routine $815348 TfPanelMain_GalaxyClicked }
procedure TfPanelMain.GalaxyClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  if Screen.ExitCode <> 0 then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.SetCursorActive(True);
  GalaxyScreen.ViewMode := 1;
  Galaxy.CheckIntegrityChecksum(140);
  ClearMessageButtons;
  RunGalaxyMap(Screen);
  RebuildMessageButtons(False);
  PostMouseMove;
  Galaxy.PrimeIntegrityChecksum(141);
end;
{ @end $815348 }

{ @routine $815468 TfPanelMain_JournalClicked }
procedure TfPanelMain.JournalClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Screen.ExitCode <> 0 then Exit;
  if (Screen.ParentLoop <> nil) and (Sender = nil) then Exit;
  Screen.GetByName('PM_WinMsg').SetActive(False);
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureScreenBackground(True, 0);
  Screen.SetCursorActive(True);
  Galaxy.CheckIntegrityChecksum(102);
  ClearMessageButtons;
  RunJournal(Screen);
  RebuildMessageButtons(False);
  PostMouseMove;
  Galaxy.PrimeIntegrityChecksum(103);
end;
{ @end $815468 }

{ @routine $81557C TfPanelMain_MenuClicked }
procedure TfPanelMain.MenuClicked(Sender: TObjectGI);
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Screen.ParentLoop <> nil then Exit;
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureScreenBackground(True, 0);
  CaptureSavePreview;
  Galaxy.CheckIntegrityChecksum(98);
  CaptureGalaxyPreview(Screen);
  Galaxy.PrimeIntegrityChecksum(99);
  Screen.SetCursorActive(True);
  GameMenuReturnScreenId := FormToId(Screen);
  RequestedScreenId := screenGameMenu;
  Screen.RequestClose(1);
end;
{ @end $81557C }

{ @routine $815660 TfPanelMain_TryAutoTurnSave }
procedure TfPanelMain.TryAutoTurnSave;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if Galaxy.IronWill then Exit;
  if TurnSaveStep = 0 then Exit;
  if (Galaxy.CurrentTurn mod TurnSaveStep) <> 0 then Exit;
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureSavePreview;
  CaptureGalaxyPreview(Screen);
  Screen.SetCursorActive(False);
  SaveManagerReturnScreenId := FormToId(Screen);
  SaveGameToFile(SaveManagerScreen.GetTurnSavePath, 'TurnSave');
  Screen.SetCursorActive(True);
end;
{ @end $815660 }

{ @routine $8157B0 TfPanelMain_QuickSave }
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
  Screen.SetCursorActive(False);
  Screen.Present;
  CaptureSavePreview;
  Galaxy.CheckIntegrityChecksum(132);
  CaptureGalaxyPreview(Screen);
  Screen.SetCursorActive(False);
  SaveManagerReturnScreenId := FormToId(Screen);
  SaveGameToFile(SaveManagerScreen.GetQuickSavePath(1), 'QuickSave');
  Galaxy.PrimeIntegrityChecksum(133);
  Screen.SetCursorActive(True);
end;
{ @end $8157B0 }

{ @routine $815978 TfPanelMain_QuickLoad }
procedure TfPanelMain.QuickLoad(SlotIndex: Integer);
var
  Text: WideString;
begin
  if (ActiveLoadPanel <> nil) and ActiveLoadPanel.IsAnimatingShutters then Exit;
  if NavigationLocked then Exit;
  if HasPendingScriptRequests then Exit;
  if GetInnermostScreenLoop.ParentLoop <> nil then Exit;
  Screen.SetCursorActive(False);
  if SaveManagerScreen.QuickSaveExists(SlotIndex) then
  begin
    if (QuickSaveExtraSlots > 0) or (SlotIndex > 1) then
      Text := ReplaceColoredToken(LookupLocalizedTextByKey('FormSaveManager.QueryQuickN'), '<Num>', WideString(IntToStr(SlotIndex)), '<color=255,240,100>')
    else
      Text := LookupLocalizedTextByKey('FormSaveManager.QueryQuick');
    if ShowMessageBoxGI(Screen, Text, mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
    begin
      PendingLoadFileName := AnsiString(SaveManagerScreen.GetQuickSavePath(SlotIndex));
      RequestedScreenId := screenGameLoad;
      Screen.RequestClose(1);
      Exit;
    end;
  end
  else if QuickSaveExtraSlots + 1 >= SlotIndex then
  begin
    if QuickSaveExtraSlots > 0 then
      Text := ReplaceColoredToken(LookupLocalizedTextByKey('FormSaveManager.QuickNotExistN'), '<Num>', WideString(IntToStr(SlotIndex)), '<color=255,240,100>')
    else
      Text := LookupLocalizedTextByKey('FormSaveManager.QuickNotExist');
    ShowMessageBoxGI(Screen, Text, mbgOK or mbgUnused04);
    FullFrameRedrawRequested := True;
  end;
  Screen.SetCursorActive(True);
  Screen.Present;
end;
{ @end $815978 }

{ @routine $815CE4 TfPanelMain_RefreshStatusTimer }
procedure TfPanelMain.RefreshStatusTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  RefreshEndTurnButton;
end;
{ @end $815CE4 }

{ @routine $815D00 TfPanelMain_PulseUnreadMessages }
procedure TfPanelMain.PulseUnreadMessages(Timer: PCallbackTimerGI; UserData: Integer);
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
        if IsPersistentPlayerMessageQueued(MessageEntry, True) and (MessageEntry.Button = Control) then
        begin
          Stage := 3;
          if Control is TGraphButtonGI then
          begin
            Stage := 4;
            if (MessageEntry.Kind in [0, 6]) and not MessageEntry.WasRead then
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
    if Finished and (MessagePulseTimer <> nil) then
    begin
      Screen.CancelCallbackTimer(MessagePulseTimer);
      MessagePulseTimer := nil;
    end;
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $815D00 }

{ @routine $8160B0 TfPanelMain_RefreshEndTurnButton }
procedure TfPanelMain.RefreshEndTurnButton;
var Button: TGraphButtonGI;
begin
  Button := EndTurnButton;
  if IsTurnCalculationRunningUI then Button.SetDisabled(True)
  else Button.SetDisabled(False);
  RefreshMoneyAndCargo;
end;
{ @end $8160B0 }

{ @routine $8160F0 TfPanelMain_DisableNavigationButtons }
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
{ @end $8160F0 }

{ @routine $816208 TfPanelMain_EnableNavigationButtons }
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
{ @end $816208 }

{ @routine $816320 TfPanelMain_RebuildMessageButtons }
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
      if (MessageEntry.Kind = 1) and (GetPlayer <> nil) and
        ((Integer(MessageEntry.Targets[0].ShipId) = GetPlayer.Id) or
         (Integer(MessageEntry.Targets[1].ShipId) = GetPlayer.Id) or
         (Integer(MessageEntry.Targets[2].ShipId) = GetPlayer.Id)) then MessageEntry.Kind := 10;
      if (MessageEntry.Kind in [0, 6]) and not MessageEntry.WasRead then
      begin
        Button.SetImageNormalPath('GraphBuf');
        Button.ImageNormal.GraphBufControl.SourceHasPerPixelAlpha := True;
        LoadGiByPathIntoGraphBuf('Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetNormalImageName,
          Button.ImageNormal.GraphBufControl.GraphBuf);
        Button.ImageNormal.SetSize(Button.ImageNormal.GetContentSize);
        if MessagePulseTimer = nil then
          MessagePulseTimer := Screen.ScheduleCallbackTimer(40, 40, PulseUnreadMessages);
      end
      else
        Button.SetImageNormalPath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetNormalImageName);
      Button.SetImageNormalActivePath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetActiveImageName);
      Button.SetImageDownPath('GI,Bm.MsgPlayer.' + GiResourceSuffix + MessageEntry.GetPressedImageName);
      Button.HitKind := gbhRect;
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
{ @end $816320 }

{ @routine $8168F0 TfPanelMain_ClearMessageButtons }
procedure TfPanelMain.ClearMessageButtons;
var
  Panel: TPanelGI;
  MessageEntry: TMessagePlayer;
begin
  if MessagePulseTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessagePulseTimer);
    MessagePulseTimer := nil;
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
{ @end $8168F0 }

{ @routine $8169C4 TfPanelMain_RemoveDismissibleMessages }
function TfPanelMain.RemoveDismissibleMessages(Key: WideString): Boolean;
begin
  Result := False;
  if RemovePlayerMessagesExceptKinds(Key, [3, 9], False) then
  begin
    RebuildMessageButtons(False);
    SoundManager.PlaySound('Sound.DelMsg');
    Result := True;
  end;
end;
{ @end $8169C4 }

{ @routine $816A68 TfPanelMain_MessageMouseEnter }
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
    LabelControl.SetTextAlignY(tayAuto);
    LabelControl.SetText(MessageEntry.Text);
    LabelControl.SetTextAlignY(tayCenterEx);
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
      if MessageEntry.Kind = 6 then MessageEntry.Turn := Galaxy.CurrentTurn;
    end;
    LabelControl.SetPosition(Window.WorkSubRect.TopLeft);
    Window.SetPosition(Classes.Point(Sender.HitTestBounds.Left + Sender.ClientSize.X div 2,
      Sender.HitTestBounds.Top - Window.ClientSize.Y - 5));
  finally
    PersistentPlayerMessageLock.Leave;
  end;
end;
{ @end $816A68 }

{ @routine $816CDC TfPanelMain_MessageMouseLeave }
procedure TfPanelMain.MessageMouseLeave(Sender: TObjectGI);
begin
  Screen.GetByName('PM_WinMsg').SetActive(False);
end;
{ @end $816CDC }

{ @routine $816D1C TfPanelMain_DeleteMessage }
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
    if MessageEntry.Kind in [3, 9] then Exit;
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
{ @end $816D1C }

{ @routine $816FD4 TfPanelMain_MessageRightButtonDown }
procedure TfPanelMain.MessageRightButtonDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  DeleteMessage(Sender, KeyState, Point, False);
  BreakUiMessage;
end;
{ @end $816FD4 }

{ @routine $817010 TfPanelMain_AdvanceMessageDeletion }
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
{ @end $817010 }

{ @routine $8171DC TfPanelMain_FinishMessageDeletion }
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
      MessageEntry := TMessagePlayer(AuxiliaryItems[0]);
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
{ @end $8171DC }

{ @routine $817328 TfPanelMain_SlideMessagesIn }
procedure TfPanelMain.SlideMessagesIn;
begin
  MessageSlideDirection := -1;
  if MessageSlideTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := nil;
  end;
  if MessagePanel.LocalPosition.Y > MessagePanelRestTop then
    MessageSlideTimer := Screen.ScheduleCallbackTimer(10, 10, AdvanceMessageSlide);
end;
{ @end $817328 }

{ @routine $817398 TfPanelMain_SlideMessagesOut }
procedure TfPanelMain.SlideMessagesOut;
begin
  MessageSlideDirection := 1;
  if MessageSlideTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MessageSlideTimer);
    MessageSlideTimer := nil;
  end;
  if MessagePanel.LocalPosition.Y < GameScreenHeight - 5 then
    MessageSlideTimer := Screen.ScheduleCallbackTimer(10, 10, AdvanceMessageSlide);
end;
{ @end $817398 }

{ @routine $81740C TfPanelMain_AdvanceMessageSlide }
procedure TfPanelMain.AdvanceMessageSlide(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if MessageSlideDirection < 0 then
  begin
    if MessagePanel.LocalPosition.Y <= MessagePanelRestTop then
    begin
      if MessageSlideTimer <> nil then
      begin
        Screen.CancelCallbackTimer(MessageSlideTimer);
        MessageSlideTimer := nil;
      end;
    end
    else MessagePanel.SetPosition(Classes.Point(MessagePanel.LocalPosition.X, MessagePanel.LocalPosition.Y + MessageSlideDirection));
  end
  else
  begin
    if MessagePanel.LocalPosition.Y >= GameScreenHeight - 5 then
    begin
      if MessageSlideTimer <> nil then
      begin
        Screen.CancelCallbackTimer(MessageSlideTimer);
        MessageSlideTimer := nil;
      end;
    end
    else MessagePanel.SetPosition(Classes.Point(MessagePanel.LocalPosition.X, MessagePanel.LocalPosition.Y + MessageSlideDirection));
  end;
end;
{ @end $81740C }

{ @routine $817500 TfPanelMain_MessageClicked }
procedure TfPanelMain.MessageClicked(Sender: TObjectGI);
var
  MessageEntry: TMessagePlayer;
  Ship: TShip;
  Planet: TPlanet;
  ShipId, PlanetId: Cardinal;
  Attempts: Integer;
  FilmObject: TEFilmObj;
begin
  if (CurrentScreenId <> screenStarMap) or
    ((StarMapScreen.Mode <> smmOrders) and (StarMapScreen.Mode <> smmTurnFilm)) then Exit;
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
        if StarMapScreen.Mode = smmOrders then
        begin
          Ship := TObject(Galaxy.IdToShip(DisplayedShipId, False)) as TShip;
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
        if StarMapScreen.Mode = smmOrders then
        begin
          Planet := TObject(Galaxy.IdToPlanet(DisplayedPlanetId, False)) as TPlanet;
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
{ @end $817500 }

{ @routine $817AB8 TfPanelMain_PlayUnreadMessageSounds }
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
        if MessageEntry.Kind in [0..6, 8] then
          if not PlayedQuestOk and (MessageEntry.Kind = 4) then
          begin
            PlayedQuestOk := True;
            SoundManager.PlaySound('Sound.QuestOk');
          end
          else if not PlayedQuestCancel and (MessageEntry.Kind = 5) then
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
{ @end $817AB8 }

{ @routine $817CB0 TfPanelMain_FlashMoneyWarning }
procedure TfPanelMain.FlashMoneyWarning;
begin
  if MoneyWarningTimer <> nil then
  begin
    Screen.CancelCallbackTimer(MoneyWarningTimer);
    MoneyWarningTimer := nil;
  end;
  MoneyWarningTimer := Screen.ScheduleCallbackTimer(100, 100, AdvanceMoneyWarning);
  MoneyWarningActive := True;
  MoneyWarningTicks := 6;
  RefreshMoneyAndCargo;
end;
{ @end $817CB0 }

{ @routine $817D1C TfPanelMain_AdvanceMoneyWarning }
procedure TfPanelMain.AdvanceMoneyWarning(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Dec(MoneyWarningTicks);
  if MoneyWarningTicks <= 0 then
  begin
    if MoneyWarningTimer <> nil then
    begin
      Screen.CancelCallbackTimer(MoneyWarningTimer);
      MoneyWarningTimer := nil;
    end;
    MoneyWarningActive := False;
  end;
  RefreshMoneyAndCargo;
end;
{ @end $817D1C }

{ @routine $817D70 TfPanelMain_FlashCargoWarning }
procedure TfPanelMain.FlashCargoWarning;
begin
  if CargoWarningTimer <> nil then
  begin
    Screen.CancelCallbackTimer(CargoWarningTimer);
    CargoWarningTimer := nil;
  end;
  CargoWarningTimer := Screen.ScheduleCallbackTimer(100, 100, AdvanceCargoWarning);
  CargoWarningActive := True;
  CargoWarningTicks := 6;
  RefreshMoneyAndCargo;
end;
{ @end $817D70 }

{ @routine $817DEC TfPanelMain_AdvanceCargoWarning }
procedure TfPanelMain.AdvanceCargoWarning(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Dec(CargoWarningTicks);
  if CargoWarningTicks <= 0 then
  begin
    if CargoWarningTimer <> nil then
    begin
      Screen.CancelCallbackTimer(CargoWarningTimer);
      CargoWarningTimer := nil;
    end;
    CargoWarningActive := False;
  end;
  RefreshMoneyAndCargo;
end;
{ @end $817DEC }

{ @routine $817E50 TfPanelMain_ShowControlHelp }
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
{ @end $817E50 }

{ @routine $817EC8 TfPanelMain_ShowHelpText }
procedure TfPanelMain.ShowHelpText(Text: WideString; Visible: Boolean);
var LabelControl: TLabelGI;
begin
  LabelControl := HelpLabel;
  if Visible then SlideMessagesOut else SlideMessagesIn;
  LabelControl.SetActive(Visible);
  LabelControl.SetText(Text);
end;
{ @end $817EC8 }

{ @routine $817F48 TfPanelMain_ProcessKeyDown }
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
          SaveManagerMode := smmSave;
          RequestedScreenId := screenSaveManager;
          Screen.RequestClose(1);
        end;
      end
  else if Key = VK_F3 then
      begin
        SaveManagerReturnScreenId := FormToId(Screen);
        SaveManagerMode := smmLoad;
        RequestedScreenId := screenSaveManager;
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
{ @end $817F48 }

{ @routine $818238 TfPanelMain_PostMouseMove }
procedure TfPanelMain.PostMouseMove;
var
  Point: TPoint;
begin
  GetCursorPos(Point);
  ScreenToClient(MainWindowHandle, Point);
  PostMessage(MainWindowHandle, WM_MOUSEMOVE, 0, SmallInt(Point.X) or (SmallInt(Point.Y) shl 16));
end;
{ @end $818238 }

{ @routine $818284 TMessageLoopGIWithMainPanel_Create }
constructor TMessageLoopGIWithMainPanel.Create;
begin
  inherited Create;
  MainPanel := TfPanelMain.Create;
end;
{ @end $818284 }

{ @routine $8182DC TMessageLoopGIWithMainPanel_Destroy }
destructor TMessageLoopGIWithMainPanel.Destroy;
begin
  if MainPanel <> nil then
  begin
    MainPanel.Free;
    MainPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $8182DC }

end.
