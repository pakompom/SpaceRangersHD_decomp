unit fGov;
// Unit bracket (inferred): .text 0x006C77EC..0x006D0EDE; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, aRanger, fPanelLoad, fPanelMain, fPanelPlanet, EC_Str, EC_BlockPar, EC_CacheFont, GI_Label, Types;

type
  TfGov = class(TMessageLoopGIWithMainPanel) // @size 0x13C
  public
    PlanetPanel: TfPanelPlanet; // @offset 0xD4
    LoadPanel: TfPanelLoad; // @offset 0xD8
    DialogText: WideString; // @offset 0xDC
    FormattedTextLength: Integer; // @offset 0xE0
    DialogRefreshTimer: PCallbackTimerGI; // @offset 0xE4
    NextChoiceTop: Integer; // @offset 0xE8
    QuestOffer: TQuest; // @offset 0xF0
    QuestNegotiationLevel: Integer; // @offset 0x114  -1..1.
    QuestRewardStep: Integer; // @offset 0x118
    QuestDurationStep: Integer; // @offset 0x11C

    ScriptDialogNames: TStringsEC; // @offset $120 Script names with borrowed TScript data.
    ScriptDialogCursor: Integer; // @offset $124
    AnimationRestartRequested: Boolean; // @offset $EC
    PlanetBattleMapId: Integer; // @offset $128
    PendingTransition: Integer; // @offset $12C 1=launch/exit to menu, 2=loss, 3=win, 4=cancel; launch is consumed on reopening.
    UseHdPortrait: Boolean; // @offset $130
    UseClassicPortrait: Boolean; // @offset $131
    PortraitPanel: TObjectGI; // @offset $134
    SavedChoiceScroll: Integer; // @offset $138

    constructor Create; // @addr 0x6C7898
    destructor Destroy; override; // @addr 0x6C7918
    procedure InitializeLayout; override; // @addr $6C7DEC
    procedure OnOpen; override; // @addr 0x6C84B0 @note "Native diagnostic name: TfGov.BeforeRun."
    procedure AddChoice(Text: WideString; Value: Integer; Callback: TDialogChoiceEventGI); // @addr $6CA804
    procedure ClearDialogChoices; // @addr 0x6CA788
    procedure BuildGovernmentChoices(SkipScriptResponseText: Boolean); // @addr 0x6CC178 @note "DL flag: true suppresses selecting/appending response text from the script-choice list; script execution and choice construction still run. Callers pass 0 or 1."
    procedure BuildQuestOfferChoices; // @addr 0x6CCED0
    procedure RequestQuest(Action: Integer); // @addr 0x6CDE90
    procedure MakeQuestEasier(Action: Integer); // @addr 0x6CE5B4
    procedure MakeQuestHarder(Action: Integer); // @addr 0x6CE8AC
    procedure AcceptQuest(Action: Integer); // @addr 0x6CEBA4
    procedure RejectQuest(Action: Integer); // @addr 0x6CEE18
    procedure PermanentlyDeclineQuest(Action: Integer); // @addr 0x6CEF08
    procedure AddScriptTakeoffChoice(Caption: WideString); // @addr $6CCC78
    procedure AddScriptPlanetChoice(Caption: WideString); // @addr $6CCCDC
    procedure AddScriptGoodsChoice(Caption: WideString); // @addr $6CCD40
    procedure AddScriptShopChoice(Caption: WideString); // @addr $6CCDA4
    procedure AddScriptHangarChoice(Caption: WideString); // @addr $6CCE08
    procedure AddScriptRestartChoice(Caption: WideString); // @addr $6D0DE4
    procedure AddScriptNewsExitChoice(Caption: WideString); // @addr $6CCE6C
    procedure ContinueScriptDialog; // @addr $6CCB44
    procedure RunScriptAnswerKeepingScroll(Answer: Integer); // @addr $6CD1CC
    procedure RunScriptAnswer(Answer: Integer); // @addr $6CD158
    procedure OnClose; override; // @addr $6CA2CC
    procedure EndTurnClicked(Sender: TObjectGI); // @addr $6CA358
    procedure ShipClicked(Sender: TObjectGI); // @addr $6CA410
    procedure RequestAnimationRestart; // @addr $6CA488
    procedure PortraitAnimationComplete(Sender: TObjectGI); // @addr $6CA49C
    procedure UpdatePortraitAnimation(Talking: Boolean); // @addr $6CA4D8
    procedure RememberChoiceScroll; // @addr $6CA73C
    procedure ChoiceMouseEnter(Sender: TObjectGI); // @addr $6CADD0
    procedure ChoiceMouseLeave(Sender: TObjectGI); // @addr $6CADF0
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6CAE10
    procedure ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6CAE90
    procedure RestartTextPresentation(RestartAnimation: Boolean); // @addr $6CAFB0
    procedure AdvanceTextPresentation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6CB05C
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $6CB4D0
    function CreateDialogObject(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr $6CB5C8
    procedure AddMessageClicked(Sender: TObjectGI); // @addr $6CB8DC
    procedure StartScriptMessage(Action: Integer); // @addr $6CD120
    procedure RunInjectedAnswerKeepingScroll(Answer: Integer); // @addr $6D0D8C
    procedure RunScriptTakeoffAnswer(Answer: Integer); // @addr $6CD1F0
    procedure RunScriptPlanetAnswer(Answer: Integer); // @addr $6CD2AC
    procedure RunScriptGoodsAnswer(Answer: Integer); // @addr $6CD2E0
    procedure RunScriptShopAnswer(Answer: Integer); // @addr $6CD314
    procedure RunScriptHangarAnswer(Answer: Integer); // @addr $6CD348
    procedure RunScriptNewsExitAnswer(Answer: Integer); // @addr $6CD37C
    procedure RunScriptRestartAnswer(Answer: Integer); // @addr $6D0DB0
    procedure ReturnToPlanet(Action: Integer); // @addr $6D0B78
    procedure ExitGovernment(Action: Integer); // @addr $6D0BA0
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr $6D0E6C
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $6CB6AC
    procedure SelectMusic; override; // @addr $6CBA4C
    procedure DeclinePlanetBattle(Action: Integer); // @addr $6CF050
    procedure ConfirmDeclineAllPlanetBattles(Action: Integer); // @addr $6CF1E4
    procedure DeclineAllPlanetBattles(Action: Integer); // @addr $6CF39C
    procedure CancelDeclineAllPlanetBattles(Action: Integer); // @addr $6CF474
    procedure CancelPrisonBail(Action: Integer); // @addr $6D0AC4
    procedure ShowPlanetBattleSupport(Action: Integer); // @addr $6CF53C
    procedure StartPlanetBattleWithoutSupport(Action: Integer); // @addr $6CF898
    procedure StartPlanetBattleWithReinforcements(Action: Integer); // @addr $6CF978
    procedure StartPlanetBattleWithBombardment(Action: Integer); // @addr $6CFA58
    procedure DeclineBattleAndLeave(Action: Integer); // @addr $6CFB38
    procedure ChoosePrisonInsteadOfBattle(Action: Integer); // @addr $6CFC68
    procedure EnterPrison(Action: Integer); // @addr $6CD3B0
    procedure ShowMapOffer(Action: Integer); // @addr $6CFF78
    procedure BuyMap(Action: Integer); // @addr $6D022C
    procedure DeclineMapOffer(Action: Integer); // @addr $6D03CC
    procedure ShowPrisonBail(Action: Integer); // @addr $6D0494
    procedure PayPrisonBail(Action: Integer); // @addr $6D0924
    procedure ContinueAfterPrison(Action: Integer); // @addr $6CD5C4
    procedure ShowBribeOffer(Action: Integer); // @addr $6CD704
    procedure PayBribe(Action: Integer); // @addr $6CDADC
    procedure DeclineBribe(Action: Integer); // @addr $6CDDC4
    procedure AddBuiltinGovernmentChoices; // @addr $6CC898
    procedure RefreshGovernmentDialog; // @addr $6CBBD0
    procedure RunInjectedAnswer(Answer: Integer); // @addr $6D0BC8
  end;

var
  GovernmentBattleDifficulty: Integer; // @addr $88B0C4 Native battle launch selector, 1..3.

implementation

uses Classes, SysUtils, Math, Windows, Globals, GlobalsV, GR_Main, GI_Main, GI_Panel, GI_Image, GI_GAI, GI_PanelScrollBar, GI_ScrollBar, GI_GraphButton, aGalaxy, aGalaxyStruct, aConst, aShip, aPlayer, aPlanet, aScript, aMyFunction, aSaveLoad, fSaveManager, fHangar, fShip2, fTalk, ThreadCalc, aCalc, aItem, Achievements, aPirate, aNormalShip, Robot, fPlanetQuest;

{ @routine $6C7898 TfGov_Create }
constructor TfGov.Create;
begin
  inherited Create;
  PlanetPanel := TfPanelPlanet.Create;
  ScriptDialogNames := TStringsEC.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $6C7898 }

{ @routine $6C7918 TfGov_Destroy }
destructor TfGov.Destroy;
begin
  if LoadPanel <> nil then begin LoadPanel.Free; LoadPanel := nil; end;
  if PlanetPanel <> nil then begin PlanetPanel.Free; PlanetPanel := nil; end;
  if ScriptDialogNames <> nil then begin ScriptDialogNames.Free; ScriptDialogNames := nil; end;
  inherited Destroy;
end;
{ @end $6C7918 }

{ @routine $6C7DEC TfGov_InitializeLayout }
procedure TfGov.InitializeLayout;
var HalfWidth, ChoiceGrowth: Integer; Owner: Byte;
  // @nested $6C79B8 LayoutPortrait
  procedure LayoutPortrait(Name: WideString; Screen: TMessageLoopGI); // @addr $6C79B8 @calls "0x6C7F28" @note "Nested in TfGov.InitializeLayout; captures half-width and Self."
  var I, PortraitX, PortraitY, TableY, Bottom, DeltaX, DeltaY: Integer; Panel: TObjectGI;
  begin
    Panel := Screen.FindControlByPath(Name);
    if Panel <> nil then
    begin
      Panel.SetSize(Point(GameScreenWidth, GameScreenHeight));
      PortraitY := Cardinal(GameScreenHeight) div 10;
      TableY := PortraitY + (Panel.FindByNameRecursive('Gov_Anim0').ClientSize.Y div 10) * 6;
      Bottom := TableY + (Panel.FindByNameRecursive('Table').ClientSize.Y div 10) * 9;
      DeltaX := Panel.FindByNameRecursive('Gov_Anim0').LocalPosition.X - Panel.FindByNameRecursive('Gov_Anim1').LocalPosition.X;
      DeltaY := Panel.FindByNameRecursive('Gov_Anim0').ClientSize.Y - Panel.FindByNameRecursive('Gov_Anim1').ClientSize.Y;
      if GameScreenHeight > Bottom then
      begin
        PortraitY := PortraitY + GameScreenHeight - Bottom;
        TableY := TableY + GameScreenHeight - Bottom;
      end;
      with Panel.FindByNameRecursive('Table') do
      begin
        SetPosition(Point(HalfWidth + (HalfWidth - ClientSize.X) div 2, TableY));
        SetActive(UseClassicPortrait);
      end;
      if Panel.FindByNameRecursive('Table2') <> nil then
      with Panel.FindByNameRecursive('Table2') do
      begin
        SetPosition(Point(HalfWidth + (HalfWidth - ClientSize.X) div 2, TableY));
        SetActive(False);
      end;
      PortraitX := (HalfWidth div 2) * 3 - Panel.FindByNameRecursive('Gov_Anim0').ClientSize.X div 2;
      for I := 0 to 1 do
      begin
        with Panel.FindByNameRecursive(WideString('Gov_Anim' + IntToStr(I))) do
          if not UseClassicPortrait then SetPosition(Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight))
          else SetPosition(Point(PortraitX - I * DeltaX, PortraitY + I * DeltaY));
        with Panel.FindByNameRecursive(WideString('GovHD_Anim' + IntToStr(I))) do
          SetPosition(Point(HalfWidth + (HalfWidth - ClientSize.X) div 2, LocalPosition.Y + ExtraScreenHeight));
      end;
      Panel.FindByNameRecursive('BG').SetSize(Point(GameScreenWidth, GameScreenHeight));
    end;
  end;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  PlanetPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fGov... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Point(GameScreenWidth, GameScreenHeight));
    HalfWidth := Cardinal(GameScreenWidth) div 2;
    UseHdPortrait := False;
    UseClassicPortrait := False;
    if (Cardinal(GameScreenWidth) >= 1280) and (Cardinal(GameScreenHeight) >= 960) then
    begin
      UseHdPortrait := True;
      UseClassicPortrait := UseTablesForGov;
    end;
    for Owner := 0 to 7 do LayoutPortrait('Gov' + OwnerInfo[Owner].InternalName, Self);
    with FindByNameRecursive('PanelTalk') do
    begin
      HalfWidth := Min(Max(ExtraScreenHeight, 0), 250) div 3;
      ChoiceGrowth := (HalfWidth div 4) * 3;
      HalfWidth := HalfWidth * 3 - ChoiceGrowth;
      if ExtraScreenHeight < 0 then SetPosition(Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2))
      else SetPosition(Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
      SetSize(Point(ClientSize.X, ClientSize.Y + HalfWidth + ChoiceGrowth));
      with FirstChild do
      begin
        SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth));
        SetSize(Point(ClientSize.X, ClientSize.Y + ChoiceGrowth));
      end;
      with FindByNameRecursive('UserMsgAdd') do SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth));
      with FindByNameRecursive('ButFormClose') do SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth + ChoiceGrowth));
      with FindByNameRecursive('TextScroll') as TPanelScrollBarGI do
      begin
        SetSize(Point(ClientSize.X, ClientSize.Y + HalfWidth));
        VerticalScrollBar.SetSize(Point(VerticalScrollBar.ClientSize.X, VerticalScrollBar.ClientSize.Y + HalfWidth));
        with FindByNameRecursive('TalkText') do SetSize(Point(ClientSize.X, ClientSize.Y + HalfWidth));
      end;
      with FindByNameRecursive('TalkPA') as TPanelScrollBarGI do
      begin
        SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth));
        SetSize(Point(ClientSize.X, ClientSize.Y + ChoiceGrowth));
        TObjectGI(VerticalScrollBar).SetPosition(Point(VerticalScrollBar.LocalPosition.X, VerticalScrollBar.LocalPosition.Y + HalfWidth));
        VerticalScrollBar.SetSize(Point(VerticalScrollBar.ClientSize.X, VerticalScrollBar.ClientSize.Y + ChoiceGrowth));
        with NextSibling do
        begin
          SetSize(Point(ClientSize.X, ClientSize.Y + HalfWidth + ChoiceGrowth));
          with NextSibling do
          begin
            SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth + ChoiceGrowth));
            with NextSibling do
            begin
              SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth));
              with NextSibling do SetPosition(Point(LocalPosition.X, LocalPosition.Y + HalfWidth));
            end;
          end;
        end;
      end;
    end;
  end;
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  with GetByName('UserMsgAdd') as TGraphButtonGI do UpCallback := AddMessageClicked;
  with GetByName('ButFormClose') as TGraphButtonGI do UpCallback := PlanetPanel.PlanetClicked;
end;
{ @end $6C7DEC }

// Reviewed compiler-layout difference: native reserves one extra, unreferenced
// dword at EBP-$F4, before its managed-string temporaries, and emits an extra
// push ECX in the prologue. Rebuilt temporaries from $F8 onward are four bytes
// nearer EBP. Calls, branches, constants and field accesses agree throughout.
{ @routine $6C84B0 TfGov_OnOpen }
procedure TfGov.OnOpen;
var
  Owner: Byte;
  MapIndex, Money, ExperienceAwarded: Integer;
  Text, WinText, LossText, TerronName: WideString;
  Event: TGalaxyEvent;
  Stage: Integer;
  Failed: Boolean;
  Portrait: TObjectGI;
  // Four native frame bytes precede compiler temporaries; no access identifies their type.
  UnresolvedFrameBytes: array[0..3] of Byte;
begin
  Stage := 0;
  try
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
    MainPanel.OnOpen;
    PlanetPanel.OnOpen;
    LoadPanel.OnOpen;
    SavedChoiceScroll := -1;
    Stage := 1;
    (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
    (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
    if GetPlayer.CurrentPlanet.IsMainPiratePlanet then SoundSection := 0
    else SoundSection := GetPlayer.CurrentPlanet.RaceId + 1;
    Stage := 2;
    if GetPlayer.CurrentPlanet <> TemporaryShopPlanet then
    begin
      SelectMusic;
      if TemporaryShopSlots <> nil then RestoreTemporaryShopStock;
      RunGlobalScriptsForContext(GetPlayer.CurrentStar, 0);
      PruneExpiredPersistentPlayerMessages;
      BuildTemporaryShopSlotGrid;
    end;
    Stage := 3;
    if (GetPlayer = nil) or ((GetPlayer.CurrentPlanet <> nil) and (GetPlayer.CurrentStar.ControlFaction = sfDominators)) then
    begin
      Event := AddGalaxyEvent('PlayerDeath');
      Event.AddTextData('PlanetCaptured');
      GameEndReason := 2;
      RequestedScreenId := screenGameEnd;
      RequestClose(1);
      Exit;
    end;
    if GetPlayer.PendingDockDialogue = 1 then GetPlayer.PendingDockDialogue := 0;
    Stage := 4;
    for Owner := 0 to 7 do
    begin
      Portrait := FindControlByPath('Gov' + OwnerInfo[Owner].InternalName);
      if Portrait <> nil then Portrait.SetActive(False);
    end;
    if GetPlayer.CurrentPlanet.IsMainPiratePlanet and (GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate)) then
      PortraitPanel := GetByName('GovPirateClan')
    else PortraitPanel := GetByName('Gov' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName);
    PortraitPanel.SetActive(True);
    with PortraitPanel do
    begin
      if FindByNameRecursive('Table2') <> nil then
      begin
        FindByNameRecursive('Table').SetActive((GetPlayer.CurrentPlanet.OwnerId <> Byte(oiPirate)) and UseHdPortrait and UseClassicPortrait);
        FindByNameRecursive('Table2').SetActive((GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate)) and UseHdPortrait and UseClassicPortrait);
      end
      else FindByNameRecursive('Table').SetActive(UseHdPortrait and UseClassicPortrait);
      with FindByNameRecursive('BG') as TImageGI do
        if GetPlayer.CurrentPlanet.IsMainPiratePlanet then SetImagePath('GI,Bm.Gov.PirateBG')
        else if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
          SetImagePath('GI,Bm.Gov.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'PirateBG')
        else SetImagePath('GI,Bm.Gov.2' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'BGi');
      if UseHdPortrait and not UseClassicPortrait then
      begin
        with FindByNameRecursive('GovHD_Anim0') as TgaiGI do
        begin
          FirstFrameOnly := AnimGov = 0;
          PrimeImageCaches;
        end;
        if AnimGov = 2 then
        with FindByNameRecursive('GovHD_Anim1') as TgaiGI do
        begin
          FirstFrameOnly := AnimGov = 0;
          PrimeImageCaches;
        end;
      end
      else
      begin
        with FindByNameRecursive('Gov_Anim0') as TgaiGI do
        begin
          FirstFrameOnly := AnimGov = 0;
          PrimeImageCaches;
        end;
        if AnimGov = 2 then
        with FindByNameRecursive('Gov_Anim1') as TgaiGI do
        begin
          FirstFrameOnly := AnimGov = 0;
          PrimeImageCaches;
        end;
      end;
    end;
    Stage := 5;
    Stage := 6;
    with GetByName('TalkText') as TLabelGI do
    begin
      SetText('');
      if FontDialog = 0 then SetFontName(NormalFontName)
      else if FontDialog = 1 then SetFontName(SmoothBigFontName)
      else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
      else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
    end;
    UpdatePortraitAnimation(True);
    Stage := 7;
    if PendingTransition = 1 then
    begin
      Stage := 8;
      MapIndex := FindRobotMapById(PlanetBattleMapId);
      Text := RobotMapDefinitions[MapIndex].RobotsStart;
      ReplaceTextToken(Text, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Player>', GetPlayer.Name, '<color=255,240,100>');
      ExpandLocalizedTextMarkupAndPrefixLines(Text);
      Text := WideString(IntToStr(GovernmentBattleDifficulty)) + Text;
      Text := WideString(IntToStr(Min(Galaxy.GetDifficultyTierIndex, 3) + 1)) + Text;
      Text := WideString(IntToStr(GetPlayer.CurrentPlanet.RaceId + 1)) + Text;
      WinText := RobotMapDefinitions[MapIndex].RobotsWin;
      ReplaceTextToken(WinText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(WinText, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(WinText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
      ExpandLocalizedTextMarkupAndPrefixLines(WinText);
      LossText := RobotMapDefinitions[MapIndex].RobotsLoss;
      ReplaceTextToken(LossText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(LossText, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(LossText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
      ExpandLocalizedTextMarkupAndPrefixLines(LossText);
      TerronName := GetPlayer.CurrentPlanet.GetFullName(' ') + ', ' + LookupLocalizedTextOrEmpty('FormShip.StorageInfo.StarInfo') + ' ' + GetPlayer.CurrentStar.Name;
      Stage := 9;
      if IsTurnCalculationRunning and (WaitForSingleObject(ScriptUiRequestEvent, 0) <> WAIT_OBJECT_0) then WaitForTurnCalculation;
      if not MemorySnapshotActive then SaveGameToMemorySnapshot;
      LoadPanel.OnOpen;
      LoadPanel.SelectBackgroundStyle(3);
      LoadPanel.RefreshBackgroundImages;
      Stage := 10;
      try
        Failed := False;
        PendingTransition := FRun(RobotMapDefinitions[MapIndex].Map, Text, WinText, LossText, TerronName);
      except
        on E: Exception do
        begin
          AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
          Failed := True;
        end;
      end;
      Stage := 11;
      if MemorySnapshotActive then RestoreGameFromMemorySnapshot;
      Stage := 12;
      if Failed then
      begin
        if ShowMessageBoxGI(Self, LocalizedColorText('FormGov.BattlePlanetQuestCrashed'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
          PendingTransition := 3
        else raise Exception.Create('Error in Matrix.dll');
      end;
      if PendingTransition = 0 then Exit;
      if PendingTransition = 1 then
      begin
        PendingTransition := 0;
        if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
        MemorySnapshotBuffer := nil;
        MemorySnapshotActive := False;
        if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
        Galaxy := nil;
        ScreenLoadMode := 4;
        PostLoadScreenId := screenMainMenu;
        RequestedScreenId := screenLoad;
        RequestClose(1);
        Exit;
      end;
      RequestedScreenId := screenGovernment;
      RequestClose(1);
      Exit;
    end;
    if PendingTransition = 2 then
    begin
      Stage := 13;
      MapIndex := FindRobotMapById(PlanetBattleMapId);
      Money := RoundAndTruncateToTens(Min(GetPlayer.Wealth * 0.03, Min(Galaxy.ComputeScaledAverageMoney(2) * 7, Galaxy.ComputeScaledHugeMoney(2) * 1.5)));
      Money := Round(Money * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].ArcadeRewardScale);
      case GovernmentBattleDifficulty of
        1: Money := RoundAndTruncateToTens(Money * 0.5);
        2: Money := RoundAndTruncateToTens(Money * 0.2);
        3: Money := RoundAndTruncateToTens(Money * 0.1);
      end;
      Stage := 14;
      GetPlayer.SetMoney(GetPlayer.Money + Money);
      SoundManager.PlaySound('Sound.Sell');
      GetPlayer.CurrentPlanet.ChangeRelationToRanger(GetPlayer, -40);
      DialogText := RobotMapDefinitions[MapIndex].GovTextLoss;
      ReplaceTextToken(DialogText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(Money)), '<color=255,240,100>');
      Stage := 15;
      BuildGovernmentChoices(True);
      Stage := 16;
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
        ResultCode := GovernmentBattleDifficulty;
        CompletionMode := PendingTransition;
        DateTurn := Galaxy.CurrentTurn;
      end;
      GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
    end
    else if PendingTransition = 3 then
    begin
      Stage := 17;
      MapIndex := FindRobotMapById(PlanetBattleMapId);
      Money := RoundAndTruncateToTens(Max(GetPlayer.Wealth * 0.03, Galaxy.ComputeScaledBigMoney(2)));
      Money := Round(Money * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestMoneyFactor);
      if GetPlayer.IsHealthEffectActive(23) then
        Money := Round(SeededRandomFloatRange((Integer(GetPlayer.CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 33, 1.3, 2.3) * Money);
      Inc(Money, Round(Money * GetPlayer.GetEffectiveSkillLevel(psCharisma) * 0.1));
      case GovernmentBattleDifficulty of
        1: Money := RoundAndTruncateToTens(Money * 4.0);
        2: Money := RoundAndTruncateToTens(Money * 1.6);
        3: Money := RoundAndTruncateToTens(Money * 0.8);
      end;
      Stage := 18;
      GetPlayer.SetMoney(GetPlayer.Money + Money);
      SoundManager.PlaySound('Sound.LiberationSystem');
      Stage := 19;
      DialogText := RobotMapDefinitions[MapIndex].GovTextWin;
      ReplaceTextToken(DialogText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(Money)), '<color=255,240,100>');
      DialogText := DialogText + GetPlayer.GrantPlanetQuestReward(GovernmentBattleDifficulty, ExperienceAwarded);
      Event := AddGalaxyEvent('PlayerFinishesPlanetaryBattle');
      Event.AddData(PlanetBattleMapId);
      Event.AddData(Money);
      Event.AddData(ExperienceAwarded);
      Stage := 20;
      BuildGovernmentChoices(True);
      Stage := 21;
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
        ResultCode := GovernmentBattleDifficulty;
        CompletionMode := PendingTransition;
        DateTurn := Galaxy.CurrentTurn;
      end;
      Stage := 22;
      GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
      Inc(GetPlayer.PlanetBattles);
      TryAddAchievementProgress('IRONMAN', 1);
      Stage := 23;
      LoadRobotScreen.LoadCompletionData;
      if GovernmentBattleDifficulty = 1 then LoadRobotScreen.RecordCompletion(PlanetBattleMapId, -RobotBattleStatistics[0] div 1000, 2)
      else LoadRobotScreen.RecordCompletion(PlanetBattleMapId, -RobotBattleStatistics[0] div 1000, 1);
      LoadRobotScreen.SaveCompletionData;
    end
    else if PendingTransition = 4 then
    begin
      Stage := 24;
      GetPlayer.CurrentPlanet.SetRelationLevelToRanger(GetPlayer, rlBad);
      DialogText := PickLocalizedTextVariant('FormGov.PlanetBattle.GovAfterCancel', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 124);
      ClearDialogChoices;
      AddChoice(PickLocalizedTextVariant('FormGov.PlanetBattle.PlayerAfterCancelNormal', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 123), 0, DeclineBattleAndLeave);
      AddChoice(PickLocalizedTextVariant('FormGov.PlanetBattle.PlayerAfterCancelPrison', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 123), 0, ChoosePrisonInsteadOfBattle);
      Stage := 25;
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
        ResultCode := GovernmentBattleDifficulty;
        CompletionMode := PendingTransition;
        DateTurn := Galaxy.CurrentTurn;
      end;
      GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
    end;
    Stage := 26;
    if PendingTransition = 0 then RefreshGovernmentDialog;
    PendingTransition := 0;
    Stage := 27;
    RestartTextPresentation(False);
    Stage := 28;
    with GetByName('TalkPA') as TPanelScrollBarGI do SetVerticalScrollbarEnabled(False);
    AnimationRestartRequested := False;
    MainPanel.RebuildMessageButtons(False);
    Stage := 29;
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct($18, nil, nil, 0);
    Galaxy.PrimeIntegrityChecksum(170);
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfGov.BeforeRun, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $6C84B0 }

{ @routine $6CA2CC TfGov_OnClose }
procedure TfGov.OnClose;
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(171);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct($19, nil, nil, 0);
  LoadPanel.OnClose;
  ScriptDialogIndex := -1;
  ClearDialogChoices;
  MainPanel.OnClose;
  PlanetPanel.OnClose;
  ScriptDialogNames.Clear;
end;
{ @end $6CA2CC }

{ @routine $6CA358 TfGov_EndTurnClicked }
procedure TfGov.EndTurnClicked(Sender: TObjectGI);
begin
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) > rlHostile) and (GetPlayer.PendingDockDialogue <= 1) then
  begin
    Galaxy.CheckIntegrityChecksum(172);
    RestoreTemporaryShopStock;
    MainPanel.EndTurnClicked(Sender);
    MainPanel.RebuildMessageButtons(False);
    if ExitCode = 0 then
    begin
      BuildTemporaryShopSlotGrid;
      UpdatePortraitAnimation(True);
      RefreshGovernmentDialog;
      Galaxy.PrimeIntegrityChecksum(173);
      RestartTextPresentation(True);
      AnimationRestartRequested := False;
    end;
  end;
end;
{ @end $6CA358 }

{ @routine $6CA410 TfGov_ShipClicked }
procedure TfGov.ShipClicked(Sender: TObjectGI);
begin
  MainPanel.ShipClicked(Sender);
  if ShipScreen.Flag3BC then
  begin
    Galaxy.CheckIntegrityChecksum(302);
    RefreshGovernmentDialog;
    Galaxy.PrimeIntegrityChecksum(303);
    RestartTextPresentation(True);
    MainPanel.RebuildMessageButtons(False);
  end;
end;
{ @end $6CA410 }

{ @routine $6CA488 TfGov_RequestAnimationRestart }
procedure TfGov.RequestAnimationRestart;
begin
  AnimationRestartRequested := True;
end;
{ @end $6CA488 }

{ @routine $6CA49C TfGov_PortraitAnimationComplete }
procedure TfGov.PortraitAnimationComplete(Sender: TObjectGI);
begin
  if AnimationRestartRequested then
  begin
    UpdatePortraitAnimation(True);
    AnimationRestartRequested := False;
  end
  else UpdatePortraitAnimation(False);
end;
{ @end $6CA49C }

{ @routine $6CA4D8 TfGov_UpdatePortraitAnimation }
procedure TfGov.UpdatePortraitAnimation(Talking: Boolean);
begin
  if AnimGov <> 2 then Talking := False;
  if UseHdPortrait and not UseClassicPortrait then
  begin
    with PortraitPanel.FindByNameRecursive('GovHD_Anim0') as TgaiGI do
    begin
      CycleCompleteCallback := PortraitAnimationComplete;
      SetSequenceFrame(0);
      StopAutoPlayback;
      if not Talking then RestartPlayback
      else StopAutoPlayback;
      SetActive(not Talking);
    end;
    with PortraitPanel.FindByNameRecursive('GovHD_Anim1') as TgaiGI do
    begin
      CycleCompleteCallback := PortraitAnimationComplete;
      SetSequenceFrame(0);
      StopAutoPlayback;
      if Talking then RestartPlayback
      else StopAutoPlayback;
      SetActive(Talking);
    end;
  end
  else
  begin
    with PortraitPanel.FindByNameRecursive('Gov_Anim0') as TgaiGI do
    begin
      CycleCompleteCallback := PortraitAnimationComplete;
      SetSequenceFrame(0);
      StopAutoPlayback;
      if not Talking then RestartPlayback
      else StopAutoPlayback;
      SetActive(not Talking);
    end;
    with PortraitPanel.FindByNameRecursive('Gov_Anim1') as TgaiGI do
    begin
      CycleCompleteCallback := PortraitAnimationComplete;
      SetSequenceFrame(0);
      StopAutoPlayback;
      if Talking then RestartPlayback
      else StopAutoPlayback;
      SetActive(Talking);
    end;
  end;
end;
{ @end $6CA4D8 }

{ @routine $6CA73C TfGov_RememberChoiceScroll }
procedure TfGov.RememberChoiceScroll;
begin
  SavedChoiceScroll := (GetByName('TalkPA') as TPanelScrollBarGI).VerticalScrollBar.Position;
end;
{ @end $6CA73C }

{ @routine $6CA788 TfGov_ClearDialogChoices }
procedure TfGov.ClearDialogChoices;
var Child, Panel: TObjectGI;
begin
  NextChoiceTop := 0;
  Panel := GetByName('TalkPA');
  Child := Panel.FirstChild;
  while Child <> nil do
  begin
    TObject(Child.UserValue).Free;
    Child := Child.NextSibling;
  end;
  Panel.FreeOwnedChildren;
  Panel.Invalidate;
end;
{ @end $6CA788 }

{ @routine $6CA804 TfGov_AddChoice }
procedure TfGov.AddChoice(Text: WideString; Value: Integer; Callback: TDialogChoiceEventGI);
var Panel: TPanelScrollBarGI; Choice: TfTalkA; I: Integer; Row: TPanelGI;
  Highlight: TImageGI; BlockMode: Byte;
begin
  BlockMode := 0;
  if ScriptDialogBlocks <> nil then
    for I := 0 to ScriptDialogBlocks.Count - 1 do
      if FindTextOffsetW(Text, PScriptDialogBlock(ScriptDialogBlocks[I]).Text) >= 0 then
        BlockMode := Max(BlockMode, PScriptDialogBlock(ScriptDialogBlocks[I]).Mode);
  if BlockMode >= 2 then Exit;
  Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  I := 0;
  while I < Length(Text) do
  begin
    if (Text[I + 1] <> '-') and (Text[I + 1] <> ' ') then Break;
    Inc(I);
  end;
  if I > 0 then Text := Copy(Text, I + 1, Length(Text) - I);
  Choice := TfTalkA.Create;
  Choice.Callback := Callback;
  Choice.Value := Value;
  if BlockMode > 0 then Choice.Callback := nil;
  Row := TPanelGI.Create(Panel);
  Row.UserValue := Integer(Choice);
  Row.SetPosition(Point(0, NextChoiceTop));
  Row.SetSize(Point(Panel.ClientSize.X, 20));
  Row.SetPositionModeW(True);
  Row.MouseEnterCallback := ChoiceMouseEnter;
  Row.MouseLeaveCallback := ChoiceMouseLeave;
  Row.LeftButtonDownCallback := ChoiceMouseDown;
  Row.LeftButtonUpCallback := ChoiceMouseUp;
  Highlight := TImageGI.Create(Row);
  Highlight.SetDepth(3);
  Highlight.SetPosition(Point(0, 0));
  Highlight.SetSize(Point(Panel.ClientSize.X, 20));
  Highlight.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Line');
  Highlight.SetImageKindX(ikxLeftFill);
  Highlight.SetImageKindY(ikyTopFill);
  Highlight.SetActive(False);
  with TLabelGI.Create(Row) do
  begin
  if FontDialog = 0 then SetFontName(NormalFontName)
  else if FontDialog = 1 then SetFontName(SmoothBigFontName)
  else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
  else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
  SetSize(Point(Panel.ClientSize.X - GiScalePixels(20), 20));
  SetPosition(Point(GiScalePixels(10), 0));
  SetWordWrapEnabled(True);
  SetTextAlignX(taxLeft);
  SetTextAlignY(tayAuto);
  if not Assigned(Callback) then Text := RemoveTextTagsW(Text);
  SetText('<Object=0,20,14,0>' + ReplaceAllWideString(Text, '<color=255,240,100>', '<color=0,50,200>'));
  SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  if not Assigned(Choice.Callback) then SetTextColor(CurrentPixelFormat.PackRgbBytes(127, 127, 127));
  CreateEmbeddedControl := CreateDialogObject;
  SetTextAlignY(tayCenterEx);
  Row.SetSize(Point(Row.ClientSize.X, ClientSize.Y + 2 * GiScalePixelsEx(2, 2)));
  SetSize(Point(ClientSize.X, Row.ClientSize.Y));
  Highlight.SetSize(Row.ClientSize);
  Inc(NextChoiceTop, ClientSize.Y);
  end;
end;
{ @end $6CA804 }

{ @routine $6CADD0 TfGov_ChoiceMouseEnter }
procedure TfGov.ChoiceMouseEnter(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(True);
end;
{ @end $6CADD0 }

{ @routine $6CADF0 TfGov_ChoiceMouseLeave }
procedure TfGov.ChoiceMouseLeave(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(False);
end;
{ @end $6CADF0 }

{ @routine $6CAE10 TfGov_ChoiceMouseDown }
procedure TfGov.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(2, 0));
end;
{ @end $6CAE10 }

{ @routine $6CAE90 TfGov_ChoiceMouseUp }
procedure TfGov.ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Choice: TfTalkA;
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
    (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(0, 0));
  Galaxy.CheckIntegrityChecksum(174);
  Choice := TfTalkA(Sender.UserValue);
  if Assigned(Choice.Callback) then Choice.Callback(Choice.Value)
  else if Assigned(Choice.FallbackCallback) then Choice.FallbackCallback(Choice.FallbackText)
  else
  begin
    Galaxy.PrimeIntegrityChecksum(176);
    Exit;
  end;
  Galaxy.PrimeIntegrityChecksum(175);
  RestartTextPresentation(True);
  MainPanel.RefreshMoneyAndCargo;
  MainPanel.RebuildMessageButtons(False);
  BreakUiMessage;
end;
{ @end $6CAE90 }

{ @routine $6CAFB0 TfGov_RestartTextPresentation }
procedure TfGov.RestartTextPresentation(RestartAnimation: Boolean);
begin
  if RestartAnimation then RequestAnimationRestart;
  (GetByName('TalkPA') as TPanelScrollBarGI).SetActive(False);
  FormattedTextLength := 0;
  if DialogRefreshTimer <> nil then
  begin
    CancelCallbackTimer(DialogRefreshTimer);
    DialogRefreshTimer := nil;
  end;
  DialogRefreshTimer := ScheduleCallbackTimer(10, 10, AdvanceTextPresentation);
end;
{ @end $6CAFB0 }

{ @routine $6CB05C TfGov_AdvanceTextPresentation }
procedure TfGov.AdvanceTextPresentation(Timer: PCallbackTimerGI; UserData: Integer);
var Choices, TextPanel: TPanelScrollBarGI;
begin
  if FormattedTextLength >= Length(DialogText) then
  begin
    Choices := GetByName('TalkPA') as TPanelScrollBarGI;
    Choices.SetActive(True);
    Choices.VerticalScrollBar.SetSmallChange((GetByName('TalkText') as TLabelGI).GetLineHeight);
    Choices.VerticalScrollBar.SetLargeChange(Choices.ClientSize.Y);
    Choices.VerticalScrollBar.SetPageSize(Choices.ClientSize.Y);
    Choices.SetScrollOffset(Point(0, 0));
    Choices.VerticalScrollBar.SetActive(NextChoiceTop > Choices.ClientSize.Y);
    Choices.VerticalScrollBar.SetDepth(4);
    Choices.SetDragScrollingEnabled(Choices.VerticalScrollBar.Active);
    Choices.UpdateScrollRanges;
    if DialogRefreshTimer <> nil then
    begin
      CancelCallbackTimer(DialogRefreshTimer);
      DialogRefreshTimer := nil;
    end;
    if SavedChoiceScroll >= 0 then Choices.VerticalScrollBar.SetPosition(SavedChoiceScroll);
    SavedChoiceScroll := -1;
    PostMouseMoveMessage;
  end
  else
  begin
    DialogText := LocalizedTextLinePrefix + TrimWideString(DialogText);
    DialogText := ReplaceAllWideString(DialogText, #13#10 + LocalizedTextLinePrefix, #13#10);
    DialogText := ReplaceAllWideString(DialogText, #13#10, #13#10 + LocalizedTextLinePrefix);
    FormattedTextLength := Length(DialogText);
    DialogText := ReplaceAllWideString(DialogText, '<color=255,240,100>', '<color=0,50,200>');
    (GetByName('TalkText') as TLabelGI).SetText(DialogText);
    TextPanel := GetByName('TextScroll') as TPanelScrollBarGI;
    TextPanel.SetScrollOffset(Point(0, 0));
    TextPanel.UpdateScrollRanges;
    TextPanel.VerticalScrollBar.SetActive((TextPanel.FindByNameRecursive('TalkText') as TLabelGI).ClientSize.Y > TextPanel.ClientSize.Y);
    TextPanel.VerticalScrollBar.SetSmallChange((TextPanel.FindByNameRecursive('TalkText') as TLabelGI).GetLineHeight);
    TextPanel.VerticalScrollBar.SetLargeChange(TextPanel.ClientSize.Y);
    TextPanel.VerticalScrollBar.SetPageSize(TextPanel.ClientSize.Y);
    (GetByName('UserMsgAdd') as TGraphButtonGI).SetDisabled(False);
  end;
end;
{ @end $6CB05C }

{ @routine $6CB4D0 TfGov_ProcessMouseWheel }
procedure TfGov.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  Panel: TPanelScrollBarGI;
begin
  Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  if not Panel.ContainsPoint(Point) then Panel := GetByName('TextScroll') as TPanelScrollBarGI;
  if Delta = WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange);
end;
{ @end $6CB4D0 }

{ @routine $6CB5C8 TfGov_CreateDialogObject }
function TfGov.CreateDialogObject(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI;
var Image: TImageGI;
begin
  Result := TImageGI.Create(LabelControl);
  Image := Result as TImageGI;
  Image.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Answer');
  Image.SetImageKindX(ikxLeft);
end;
{ @end $6CB5C8 }

{ @routine $6CB6AC TfGov_MainPanelKeyDown }
procedure TfGov.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var Panel: TPanelScrollBarGI; Button: TGraphButtonGI;
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) or (ExitCode <> 0) then Exit;
  Panel := GetByName('TextScroll') as TPanelScrollBarGI;
  if Key = VK_SPACE then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else if Key = Ord('S') then ShipClicked(nil)
  else if Key = VK_UP then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
  else if Key = VK_DOWN then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange)
  else if Key = VK_PRIOR then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.LargeChange)
  else if Key = VK_NEXT then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.LargeChange)
  else if Key = VK_INSERT then
  begin
    Button := GetByName('UserMsgAdd') as TGraphButtonGI;
    AddMessageClicked(Button);
  end
  else
  begin
    MainPanel.ProcessKeyDown(Key);
    PlanetPanel.ProcessKeyDown(Key);
  end;
end;
{ @end $6CB6AC }

{ @routine $6CB8DC TfGov_AddMessageClicked }
procedure TfGov.AddMessageClicked(Sender: TObjectGI);
var Text: WideString;
begin
  Text := (GetByName('TalkText') as TLabelGI).GetText;
  Text := ReplaceAllWideString(Text, '<color=0,50,200>', '<color=255,240,100>');
  (Sender as TGraphButtonGI).SetDisabled(True);
  SoundManager.PlaySound('Sound.UserMsgAdd');
  AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, Text, '');
  MainPanel.RebuildMessageButtons(False);
  BreakUiMessage;
end;
{ @end $6CB8DC }

{ @routine $6CBA4C TfGov_SelectMusic }
procedure TfGov.SelectMusic;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
  else if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
  begin
    if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
      MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
    else MusicManager.PlayCategory('Nation.PiratePlanetMain');
  end
  else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
end;
{ @end $6CBA4C }

{ @routine $6CBBD0 TfGov_RefreshGovernmentDialog }
procedure TfGov.RefreshGovernmentDialog;
var I, J: Integer; Planet: TPlanet; Ship: TShip;
begin
  if IsTurnCalculationRunningUI then WaitForTurnCalculationUI;
  if ExitCode = 0 then
  begin
    if GetPlayer.InPrison then
    begin
      if GetPlayer.CurrentPlanet.OwnerId <> Byte(oiPirate) then
        DialogText := LocalizedColorText('FormGov.Prison.GovAfterPrison')
      else DialogText := LocalizedColorText('FormGov.PirateClanPrison.GovAfterPrison');
      GetPlayer.InPrison := False;
      Inc(GetPlayer.PrisonStaysCompleted);
      TryAddAchievementProgress('PRISON', 1);
      for I := 0 to Galaxy.Planets.Count - 1 do
      begin
        Planet := Galaxy.Planets[I];
        for J := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[J];
          if GetPlayer = Ship.EnemyShip then Ship.EnemyShip := nil;
          if GetPlayer.EnemyShip = Ship then GetPlayer.EnemyShip := nil;
        end;
      end;
      ClearDialogChoices;
      AddChoice(LocalizedColorText('FormGov.I_Continue'), 0, ContinueAfterPrison);
    end
    else if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) = rlHostile) and
      not HasPendingScriptRequests and not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
    begin
      if GetPlayer.OwnerId <> Byte(oiPirate) then DialogText := LocalizedColorText('FormGov.Prison.GovBeforePrison')
      else DialogText := LocalizedColorText('FormGov.PirateClanPrison.GovBeforePrison');
      ClearDialogChoices;
      if GetPlayer.CurrentPlanet.OwnerId <> Byte(oiPirate) then
        AddChoice(LocalizedColorText('FormGov.Prison.PlayerGoToPrison'), 0, EnterPrison)
      else AddChoice(LocalizedColorText('FormGov.PirateClanPrison.PlayerGoToPrison'), 0, EnterPrison);
    end
    else if GetPlayer.PendingLiberationCeremonyPlanet = GetPlayer.CurrentPlanet then
    begin
      DialogText := TNormalShip(GetPlayer).CollectLiberationRewards;
      ClearDialogChoices;
      AddChoice(LocalizedColorText('FormGov.PlayerAfterCongratulationsLiberator'), 0, ExitGovernment);
    end
    else
    begin
      DialogText := GetPlayer.CurrentPlanet.BuildGovernmentGreeting;
      BuildGovernmentChoices(False);
    end;
  end;
end;
{ @end $6CBBD0 }

{ @routine $6CC178 TfGov_BuildGovernmentChoices }
procedure TfGov.BuildGovernmentChoices(SkipScriptResponseText: Boolean);
var
  Script: TScript;
  Text, Mode: WideString;
  I, J, Selected, Priority, PartCount: Integer;
  Swapped: Pointer;
begin
  ClearScriptDialogRules;
  ClearDialogChoices;
  GetPlayer.CurrentPlanet.CollectScriptDialogChoices(ScriptDialogNames);
  ScriptDialogCursor := 0;
  Script := nil;
  ScriptDialogIndex := -1;
  while ScriptDialogCursor < ScriptDialogNames.GetCount do
  begin
    Script := TScript(ScriptDialogNames.GetDataAt(ScriptDialogCursor));
    Script.CallDialogByVariable(ScriptDialogNames.GetTextAt(ScriptDialogCursor));
    if ScriptDialogIndex >= 0 then Break;
    Inc(ScriptDialogCursor);
  end;
  if GetPlayer.TryTurnInAnyQuest(Text) then DialogText := Text;
  if ScriptDialogIndex < 0 then
  begin
    for I := 0 to Galaxy.Scripts.Count - 1 do
    begin
      Script := Galaxy.Scripts[I];
      Script.RunAuxiliaryCode;
    end;
    if ScriptDialogOverrides.Count > 0 then
    begin
      Selected := 0;
      Priority := PScriptDialogOverride(ScriptDialogOverrides[0]).Priority;
      for I := 0 to ScriptDialogOverrides.Count - 1 do
        if PScriptDialogOverride(ScriptDialogOverrides[I]).Priority > Priority then
        begin
          Selected := I;
          Priority := PScriptDialogOverride(ScriptDialogOverrides[I]).Priority;
        end;
      Script := PScriptDialogOverride(ScriptDialogOverrides[Selected]).Script;
      Script.InitCode.LocalVar.GetVar('GAnswerData').SetDword(PScriptDialogOverride(ScriptDialogOverrides[Selected]).AnswerData);
      Text := PScriptDialogOverride(ScriptDialogOverrides[Selected]).DialogName;
      if Text <> '' then
      begin
        Script.CallDialogByVariable(Text);
        if ScriptDialogIndex < 0 then
          AppendLogLineThreadSafe(AnsiString(Script.ScriptFileName + ' has overriden dialog with ' + Text + ' but it failed to start'));
      end;
      if ScriptDialogIndex < 0 then AddBuiltinGovernmentChoices
      else
      begin
        StartScriptMessage(Integer(Script));
      end;
    end
    else
    begin
      Selected := -1;
      Priority := 0;
      if not SkipScriptResponseText then
      for I := 0 to ScriptDialogInjections.Count - 1 do
        if PScriptDialogInjection(ScriptDialogInjections[I]).ReplaceGreeting then
          if (Selected < 0) or (PScriptDialogInjection(ScriptDialogInjections[I]).Priority > Priority) then
          begin
            Priority := PScriptDialogInjection(ScriptDialogInjections[I]).Priority;
            Selected := I;
          end;
      if Selected >= 0 then
        DialogText := PScriptDialogInjection(ScriptDialogInjections[Selected]).Text;
      for I := 1 to ScriptDialogInjections.Count - 1 do
        for J := ScriptDialogInjections.Count - 1 downto I do
          if PScriptDialogInjection(ScriptDialogInjections[J]).Priority > PScriptDialogInjection(ScriptDialogInjections[J - 1]).Priority then
          begin
            Swapped := ScriptDialogInjections[J];
            ScriptDialogInjections[J] := ScriptDialogInjections[J - 1];
            ScriptDialogInjections[J - 1] := Swapped;
          end;
      for I := 0 to ScriptDialogInjections.Count - 1 do
      begin
        if not PScriptDialogInjection(ScriptDialogInjections[I]).ReplaceGreeting then
        begin
          Text := PScriptDialogInjection(ScriptDialogInjections[I]).Text;
          if (Text <> '') and not SkipScriptResponseText then DialogText := DialogText + #13#10 + Text;
        end;
        Text := PScriptDialogInjection(ScriptDialogInjections[I]).Answer;
        if Text <> '' then
        begin
          Mode := '';
          PartCount := CountDelimitedPartsW(Text, '~');
          if PartCount > 1 then
          begin
            Mode := ExtractDelimitedPartW(Text, 0, '~');
            Text := ExtractDelimitedRangeW(Text, 1, PartCount - 1, '~');
          end;
          if Mode = 'block' then AddChoice(Text, 0, ScriptDialogBlockCallback)
          else if Mode = 'snap' then AddChoice(Text, Integer(ScriptDialogInjections[I]), RunInjectedAnswerKeepingScroll)
          else AddChoice(PScriptDialogInjection(ScriptDialogInjections[I]).Answer, Integer(ScriptDialogInjections[I]), RunInjectedAnswer);
        end;
      end;
      AddBuiltinGovernmentChoices;
    end;
  end
  else if not Script.SkipGreeting then
    AddChoice(LocalizedColorText('FormGov.I_Continue'), Integer(Script), StartScriptMessage)
  else
  begin
    Script.SkipGreeting := False;
    StartScriptMessage(Integer(Script));
  end;
end;
{ @end $6CC178 }

{ @routine $6CC898 TfGov_AddBuiltinGovernmentChoices }
procedure TfGov.AddBuiltinGovernmentChoices;
begin
  if (GetPlayer.CurrentPlanet.CurrentStar.Constellation.Id <> 20) or
    (not GetPlayer.CurrentPlanet.IsMainPiratePlanet and
    (GetPlayer.CurrentPlanet.OwnerId in TOwnerMask(PlanetOwnerMasks.Coalition))) then
    AddChoice(LocalizedColorText('FormGov.I_QueryQuest'), 0, RequestQuest);
  if (GetPlayer.CurrentPlanet.GetRelationLevelToShip(GetPlayer) <= rlNormal) and
    not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
    AddChoice(PickLocalizedTextVariant('FormGov.Bribe.I_Bribe', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 239516), 0, ShowBribeOffer);
  if GetPlayer.CurrentPlanet.FindUnchartedNeighborConstellation <> nil then
    AddChoice(LocalizedColorText('FormGov.BuyMap.I_BuyMap'), 0, ShowMapOffer);
  if GetPlayer.CurrentPlanet.CountBailablePrisoners > 0 then
    AddChoice(LocalizedColorText('FormGov.GuarantPrison.PlayerAsk'), 0, ShowPrisonBail);
  AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
end;
{ @end $6CC898 }

{ @routine $6CCB44 TfGov_ContinueScriptDialog }
procedure TfGov.ContinueScriptDialog;
var Script: TScript;
begin
  ScriptDialogIndex := -1;
  Inc(ScriptDialogCursor);
  Script := nil;
  while ScriptDialogCursor < ScriptDialogNames.GetCount do
  begin
    Script := ScriptDialogNames.GetDataAt(ScriptDialogCursor);
    Script.CallDialogByVariable(ScriptDialogNames.GetTextAt(ScriptDialogCursor));
    if ScriptDialogIndex >= 0 then Break;
    Inc(ScriptDialogCursor);
  end;
  if ScriptDialogIndex < 0 then BuildGovernmentChoices(True)
  else AddChoice(LocalizedColorText('FormGov.I_Continue'), Integer(Script), StartScriptMessage);
end;
{ @end $6CCB44 }

{ @routine $6CCC78 TfGov_AddScriptTakeoffChoice }
procedure TfGov.AddScriptTakeoffChoice(Caption: WideString);
begin
  AddChoice(Caption, CurrentScript.CurrentAnswer, RunScriptTakeoffAnswer);
end;
{ @end $6CCC78 }

{ @routine $6CCCDC TfGov_AddScriptPlanetChoice }
procedure TfGov.AddScriptPlanetChoice(Caption: WideString);
begin
  AddChoice(Caption, CurrentScript.CurrentAnswer, RunScriptPlanetAnswer);
end;
{ @end $6CCCDC }

{ @routine $6CCD40 TfGov_AddScriptGoodsChoice }
procedure TfGov.AddScriptGoodsChoice(Caption: WideString);
begin
  AddChoice(Caption, CurrentScript.CurrentAnswer, RunScriptGoodsAnswer);
end;
{ @end $6CCD40 }

{ @routine $6CCDA4 TfGov_AddScriptShopChoice }
procedure TfGov.AddScriptShopChoice(Caption: WideString);
begin
  AddChoice(Caption, CurrentScript.CurrentAnswer, RunScriptShopAnswer);
end;
{ @end $6CCDA4 }

{ @routine $6CCE08 TfGov_AddScriptHangarChoice }
procedure TfGov.AddScriptHangarChoice(Caption: WideString);
begin
  AddChoice(Caption, CurrentScript.CurrentAnswer, RunScriptHangarAnswer);
end;
{ @end $6CCE08 }

{ @routine $6CCE6C TfGov_AddScriptNewsExitChoice }
procedure TfGov.AddScriptNewsExitChoice(Caption: WideString);
begin
  AddChoice(Caption, CurrentScript.CurrentAnswer, RunScriptNewsExitAnswer);
end;
{ @end $6CCE6C }

{ @routine $6CCED0 TfGov_BuildQuestOfferChoices }
procedure TfGov.BuildQuestOfferChoices;
begin
  ClearDialogChoices;
  AddChoice(LocalizedColorText('FormGov.I_QuestAccept'), 0, AcceptQuest);
  AddChoice(LocalizedColorText('FormGov.I_QuestReject'), 0, RejectQuest);
  AddChoice(LocalizedColorText('FormGov.I_QuestEasy'), 0, MakeQuestEasier);
  AddChoice(LocalizedColorText('FormGov.I_QuestDifficult'), 0, MakeQuestHarder);
  if QuestOffer.QuestType = qtPlanetQuest then
    AddChoice(LocalizedColorText('FormGov.I_PlanetQuestClose'), 0, PermanentlyDeclineQuest);
  AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
end;
{ @end $6CCED0 }

{ @routine $6CD120 TfGov_StartScriptMessage }
procedure TfGov.StartScriptMessage(Action: Integer);
begin
  ClearDialogChoices;
  CurrentScript := TScript(Action);
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $6CD120 }

{ @routine $6CD158 TfGov_RunScriptAnswer }
procedure TfGov.RunScriptAnswer(Answer: Integer);
begin
  ClearDialogChoices;
  ScriptDialogIndex := -1;
  CurrentScript.ExecuteDialogAnswer(Answer);
  if ScriptDialogIndex < 0 then RaiseWideMessage('I_Script');
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $6CD158 }

{ @routine $6CD1CC TfGov_RunScriptAnswerKeepingScroll }
procedure TfGov.RunScriptAnswerKeepingScroll(Answer: Integer);
begin
  RememberChoiceScroll;
  RunScriptAnswer(Answer);
end;
{ @end $6CD1CC }

{ @routine $6CD1F0 TfGov_RunScriptTakeoffAnswer }
procedure TfGov.RunScriptTakeoffAnswer(Answer: Integer);
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  CurrentScript.ExecuteDialogAnswer(Answer);
  if not HangarScreen.TryTakeOff then RequestedScreenId := screenHangar;
  RequestClose(1);
end;
{ @end $6CD1F0 }

{ @routine $6CD2AC TfGov_RunScriptPlanetAnswer }
procedure TfGov.RunScriptPlanetAnswer(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  RequestedScreenId := screenPlanet;
  RequestClose(1);
end;
{ @end $6CD2AC }

{ @routine $6CD2E0 TfGov_RunScriptGoodsAnswer }
procedure TfGov.RunScriptGoodsAnswer(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  RequestedScreenId := screenGoodsShop;
  RequestClose(1);
end;
{ @end $6CD2E0 }

{ @routine $6CD314 TfGov_RunScriptShopAnswer }
procedure TfGov.RunScriptShopAnswer(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  RequestedScreenId := screenEquipmentShop;
  RequestClose(1);
end;
{ @end $6CD314 }

{ @routine $6CD348 TfGov_RunScriptHangarAnswer }
procedure TfGov.RunScriptHangarAnswer(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  RequestedScreenId := screenHangar;
  RequestClose(1);
end;
{ @end $6CD348 }

{ @routine $6CD37C TfGov_RunScriptNewsExitAnswer }
procedure TfGov.RunScriptNewsExitAnswer(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  RequestedScreenId := screenInfo;
  RequestClose(1);
end;
{ @end $6CD37C }

{ @routine $6CD3B0 TfGov_EnterPrison }
procedure TfGov.EnterPrison(Action: Integer);
var I: Integer; Ship: TShip;
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  GetPlayer.InPrison := True;
  GetPlayer.CurrentSystemKills.Normal := 0;
  GetPlayer.CurrentSystemKills.Pirate := 0;
  if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
  begin
    if MainPiratePlanet <> nil then MainPiratePlanet.ChangeRelationToRanger(GetPlayer, 80)
    else GetPlayer.CurrentPlanet.ChangeRelationToRanger(GetPlayer, 80);
  end
  else
  begin
    GetPlayer.CurrentPlanet.ChangeRelationToRanger(GetPlayer, 80);
    GetPlayer.ChangePlanetRelations(nil, rcmRaiseTo, 20, TOwnerMask(PlanetOwnerMasks.Coalition));
    GetPlayer.ChangePlanetRelations(GetPlayer.CurrentStar.Constellation, rcmIncrease, 30, TOwnerMask(PlanetOwnerMasks.Coalition));
  end;
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if ((Ship.TypeId = stWarrior) or ((Ship.TypeId = stPirate) and (TPirate(Ship).PirateType <> 0))) and
      (GetPlayer = Ship.EnemyShip) then
    begin
      Ship.EnemyShip := nil;
      if GetPlayer = Ship.OrderTarget then Ship.OrderNone(False);
    end;
  end;
  StandaloneQuestMode := False;
  QuestReturnScreenId := FormToId(Self);
  RequestedScreenId := screenPlanetQuest;
  RequestClose(1);
end;
{ @end $6CD3B0 }

{ @routine $6CD5C4 TfGov_ContinueAfterPrison }
procedure TfGov.ContinueAfterPrison(Action: Integer);
begin
  if GetPlayer.CurrentPlanet.OwnerId <> Byte(oiPirate) then
    DialogText := LocalizedColorText('FormGov.Prison.GovAfterPrisonNext')
  else DialogText := LocalizedColorText('FormGov.PirateClanPrison.GovAfterPrisonNext');
  BuildGovernmentChoices(True);
end;
{ @end $6CD5C4 }

{ @routine $6CD704 TfGov_ShowBribeOffer }
procedure TfGov.ShowBribeOffer(Action: Integer);
var Cost, RelationDeficit: Integer; Text: WideString;
begin
  if GetPlayer.CurrentPlanet.OwnerId <> Byte(oiPirate) then
  begin
    RelationDeficit := 100 - GetPlayer.CurrentPlanet.RelationToShip(GetPlayer);
    Cost := Round(RemapClamped(RelationDeficit, 0, 100, 1, 5) * (Galaxy.AverageRangerCapital div 100) *
      OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].FuelPriceFactor);
    Text := PickLocalizedTextVariant('FormGov.Bribe.Question', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 223429);
    ReplaceTextToken(Text, '<Money>', WideString(IntToStr(Cost)), '<color=255,240,100>');
    DialogText := Text;
    ClearDialogChoices;
    if GetPlayer.Money >= Cost then
      AddChoice(FormatText2(PickLocalizedTextVariant('FormGov.Bribe.Ok', (Galaxy.CurrentTurn div 5) * GetPlayer.CurrentPlanet.GenerationSeed + 8168236),
        '<color=255,240,100>', '<Money>', WideString(IntToStr(Cost)), '<Planet>', GetPlayer.CurrentPlanet.Name), 0, PayBribe);
    AddChoice(PickLocalizedTextVariant('FormGov.Bribe.No', (Galaxy.CurrentTurn div 5) * GetPlayer.CurrentPlanet.GenerationSeed + 23985), 0, DeclineBribe);
  end
  else
  begin
    DialogText := PickLocalizedTextVariant('FormGov.Bribe.GotoPB', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 112);
    BuildGovernmentChoices(True);
  end;
end;
{ @end $6CD704 }

{ @routine $6CDADC TfGov_PayBribe }
procedure TfGov.PayBribe(Action: Integer);
var Cost, RelationDeficit: Integer;
begin
    RelationDeficit := 100 - GetPlayer.CurrentPlanet.RelationToShip(GetPlayer);
    Cost := Round(RemapClamped(RelationDeficit, 0, 100, 1, 5) * (Galaxy.AverageRangerCapital div 100) *
      OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].FuelPriceFactor);
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  SoundManager.PlaySound('Sound.Sell');
  if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
  begin
    if MainPiratePlanet <> nil then MainPiratePlanet.ChangeRelationToRanger(GetPlayer, 100)
    else GetPlayer.CurrentPlanet.ChangeRelationToRanger(GetPlayer, 100);
  end
  else
  begin
    GetPlayer.CurrentPlanet.ChangeRelationToRanger(GetPlayer, 100);
    GetPlayer.ChangePlanetRelations(GetPlayer.CurrentStar, rcmIncrease, 20, TOwnerMask(PlanetOwnerMasks.Coalition));
  end;
  DialogText := PickLocalizedTextVariant('FormGov.Bribe.QuestionOk', (Galaxy.CurrentTurn div 5) * GetPlayer.CurrentPlanet.GenerationSeed + 7156317);
  ReplaceTextToken(DialogText, '<Money>', WideString(IntToStr(Cost)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
  BuildGovernmentChoices(True);
end;
{ @end $6CDADC }

{ @routine $6CDDC4 TfGov_DeclineBribe }
procedure TfGov.DeclineBribe(Action: Integer);
begin
  DialogText := PickLocalizedTextVariant('FormGov.Bribe.QuestionNo', (Galaxy.CurrentTurn div 5) * GetPlayer.CurrentPlanet.GenerationSeed + 92874253);
  BuildGovernmentChoices(True);
end;
{ @end $6CDDC4 }

{ @routine $6CDE90 TfGov_RequestQuest }
procedure TfGov.RequestQuest(Action: Integer);
var ResponseText: WideString; MapIndex, MapId: Integer;
begin
  if (GetPlayer.CurrentPlanet.CurrentStar.Battle <> 0) and (GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate)) then
  begin
    DialogText := PickLocalizedTextVariant('FormGov.DontQuest.WarInSystemPirate', (Galaxy.CurrentTurn div 5) * GetPlayer.CurrentPlanet.GenerationSeed + 118123);
    BuildGovernmentChoices(True);
  end
  else if GetPlayer.CurrentPlanet.CurrentStar.Battle <> 0 then
  begin
    DialogText := PickLocalizedTextVariant('FormGov.DontQuest.WarInSystem', (Galaxy.CurrentTurn div 5) * GetPlayer.CurrentPlanet.GenerationSeed + 118123);
    BuildGovernmentChoices(True);
  end
  else
  begin
    if GetPlayer.DeclinePlanetBattleOffers then MapId := -1
    else MapId := GetPlayer.SelectPlanetBattleMap;
    if (MapId >= 0) and (ForcedPlanetQuestId < 0) then
    begin
      MapIndex := FindRobotMapById(MapId);
      DialogText := RobotMapDefinitions[MapIndex].GovTextStart;
      ReplaceTextToken(DialogText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Planet>', GetPlayer.CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Player>', GetPlayer.Name, '<color=255,240,100>');
      ClearDialogChoices;
      if (RobotInterface <> nil) and (RobotInterface.Support() = 0) then
        AddChoice(LocalizedColorText('FormGov.I_QuestAccept'), MapId, ShowPlanetBattleSupport)
      else AddChoice(LocalizedColorText('FormGov.I_QuestAccept'), 0, ScriptDialogBlockCallback);
      AddChoice(LocalizedColorText('FormGov.I_PlanetBattleQuestClose'), MapId, DeclinePlanetBattle);
      AddChoice(LocalizedColorText('FormGov.I_PlanetBattleRejectAll'), 0, ConfirmDeclineAllPlanetBattles);
      AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
    end
    else if not GetPlayer.GenerateQuestOffer(QuestOffer, ResponseText) then
    begin
      DialogText := ResponseText;
      BuildGovernmentChoices(True);
    end
    else
    begin
      QuestNegotiationLevel := 0;
      DialogText := GetPlayer.BuildQuestText(QuestOffer, qtkOffer);
      if (QuestOffer.QuestType = qtPlanetQuest) and (QuestOffer.QuestNumber >= 10000) then
        if (LanguageDataConfig.GetBlock('PlanetQuest').CountBlocks('PlanetQuestLic') <= 0) or
          (LanguageDataConfig.GetBlock('PlanetQuest').GetBlock('PlanetQuestLic').GetParamOrMarker(WideString(IntToStr(QuestOffer.QuestNumber))) <>
           PlanetQuestScreen.GetQuestContentHash(QuestOffer.QuestNumber)) then
          DialogText := DialogText + #13#10 + ' ' + #13#10 + LocalizedText('FormGov.QuestCertificate.NotCertificate');
      QuestRewardStep := Round(QuestOffer.RewardMoney * 0.3);
      QuestDurationStep := Round((QuestOffer.DeadlineTurn - Galaxy.CurrentTurn) * 0.5);
      BuildQuestOfferChoices;
    end;
  end;
end;
{ @end $6CDE90 }

{ @routine $6CE5B4 TfGov_MakeQuestEasier }
procedure TfGov.MakeQuestEasier(Action: Integer);
begin
  Dec(QuestNegotiationLevel);
  case QuestOffer.QuestType of
    qtSendLetter..qtPlanetQuest: Inc(QuestOffer.DeadlineTurn, QuestDurationStep);
    qtDefendSystem..qtDefendShip: Dec(QuestOffer.DeadlineTurn, QuestDurationStep);
  end;
  Dec(QuestOffer.RewardMoney, QuestRewardStep);
  DialogText := LocalizedColorText('FormGov.CheckQuest.Easy') + #13#10 + GetPlayer.BuildQuestText(QuestOffer, qtkOffer);
  if QuestNegotiationLevel <= -1 then
  begin
    ClearDialogChoices;
    AddChoice(LocalizedColorText('FormGov.I_QuestAccept'), 0, AcceptQuest);
    AddChoice(LocalizedColorText('FormGov.I_QuestReject'), 0, RejectQuest);
    AddChoice(LocalizedColorText('FormGov.I_QuestDifficult'), 0, MakeQuestHarder);
    if QuestOffer.QuestType = qtPlanetQuest then
      AddChoice(LocalizedColorText('FormGov.I_PlanetQuestClose'), 0, PermanentlyDeclineQuest);
    AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
  end
  else BuildQuestOfferChoices;
end;
{ @end $6CE5B4 }

{ @routine $6CE8AC TfGov_MakeQuestHarder }
procedure TfGov.MakeQuestHarder(Action: Integer);
begin
  Inc(QuestNegotiationLevel);
  case QuestOffer.QuestType of
    qtSendLetter..qtPlanetQuest: Dec(QuestOffer.DeadlineTurn, QuestDurationStep);
    qtDefendSystem..qtDefendShip: Inc(QuestOffer.DeadlineTurn, QuestDurationStep);
  end;
  Inc(QuestOffer.RewardMoney, QuestRewardStep);
  DialogText := LocalizedColorText('FormGov.CheckQuest.Difficult') + #13#10 + GetPlayer.BuildQuestText(QuestOffer, qtkOffer);
  if QuestNegotiationLevel >= 1 then
  begin
    ClearDialogChoices;
    AddChoice(LocalizedColorText('FormGov.I_QuestAccept'), 0, AcceptQuest);
    AddChoice(LocalizedColorText('FormGov.I_QuestReject'), 0, RejectQuest);
    AddChoice(LocalizedColorText('FormGov.I_QuestEasy'), 0, MakeQuestEasier);
    if QuestOffer.QuestType = qtPlanetQuest then
      AddChoice(LocalizedColorText('FormGov.I_PlanetQuestClose'), 0, PermanentlyDeclineQuest);
    AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
  end
  else BuildQuestOfferChoices;
end;
{ @end $6CE8AC }

{ @routine $6CEBA4 TfGov_AcceptQuest }
procedure TfGov.AcceptQuest(Action: Integer);
var Quest: PQuest; Item: TUselessItem;
begin
  New(Quest);
  Quest^ := QuestOffer;
  Quest.Description := GetPlayer.BuildQuestText(Quest^, qtkOffer);
  Quest.CompletionText := GetPlayer.BuildQuestText(Quest^, qtkCompletion);
  GetPlayer.Quests.Add(Quest);
  GetPlayer.PublishQuestStatus(Quest, 0);
  if Quest.QuestType = qtSendLetter then
  begin
    Item := TUselessItem.Create;
    Item.Init(LookupLocalizedTextByKey(WideString('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.SysName')), dsBlazer, 0, False);
    GetPlayer.Inventory.Add(Item);
  end;
  DialogText := PickLocalizedTextVariant('FormGov.AfterPlayerTakeQuest', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 902983);
  ClearDialogChoices;
  AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
end;
{ @end $6CEBA4 }

{ @routine $6CEE18 TfGov_RejectQuest }
procedure TfGov.RejectQuest(Action: Integer);
begin
  DialogText := LocalizedColorText('FormGov.PlayerDontTakeQuest');
  ClearDialogChoices;
  AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
end;
{ @end $6CEE18 }

{ @routine $6CEF08 TfGov_PermanentlyDeclineQuest }
procedure TfGov.PermanentlyDeclineQuest(Action: Integer);
var Quest: PPlayerOldQuest;
begin
  DialogText := LocalizedColorText('FormGov.GovAfterPlanetQuestClose');
  New(Quest);
  Quest.QuestType := QuestOffer.QuestType;
  Quest.QuestNumber := QuestOffer.QuestNumber;
  Quest.Planet := QuestOffer.Planet;
  Quest.Description := 'PlanetQuestClose';
  Quest.Successful := False;
  Quest.Declined := True;
  PlayerOldQuests.Add(Quest);
  BuildGovernmentChoices(True);
end;
{ @end $6CEF08 }

{ @routine $6CF050 TfGov_DeclinePlanetBattle }
procedure TfGov.DeclinePlanetBattle(Action: Integer);
begin
  PlanetBattleMapId := Action;
  DialogText := LocalizedColorText('FormGov.GovAfterBattlePlanetQuestClose');
  SetLength(GetPlayer.PlanetBattleHistory, High(GetPlayer.PlanetBattleHistory) + 1 + 1);
  with GetPlayer.PlanetBattleHistory[High(GetPlayer.PlanetBattleHistory)] do
  begin
    MapId := PlanetBattleMapId;
    Statistics[0] := 0;
    Statistics[1] := 0;
    Statistics[2] := 0;
    Statistics[3] := 0;
    Statistics[4] := 0;
    Statistics[5] := 0;
    ResultCode := 1;
    CompletionMode := 0;
    DateTurn := Galaxy.CurrentTurn;
  end;
  GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
  BuildGovernmentChoices(True);
end;
{ @end $6CF050 }

{ @routine $6CF1E4 TfGov_ConfirmDeclineAllPlanetBattles }
procedure TfGov.ConfirmDeclineAllPlanetBattles(Action: Integer);
begin
  DialogText := LocalizedColorText('FormGov.I_PlanetBattleRejectAllConfirm');
  ClearDialogChoices;
  AddChoice(LocalizedColorText('FormGov.I_PlanetBattleRejectAllConfirmYes'), Action, DeclineAllPlanetBattles);
  AddChoice(LocalizedColorText('FormGov.I_PlanetBattleRejectAllConfirmNo'), Action, CancelDeclineAllPlanetBattles);
end;
{ @end $6CF1E4 }

{ @routine $6CF39C TfGov_DeclineAllPlanetBattles }
procedure TfGov.DeclineAllPlanetBattles(Action: Integer);
begin
  DialogText := LocalizedColorText('FormGov.I_PlanetBattleRejectAllConfirmAfterYes');
  GetPlayer.DeclinePlanetBattleOffers := True;
  BuildGovernmentChoices(True);
end;
{ @end $6CF39C }

{ @routine $6CF474 TfGov_CancelDeclineAllPlanetBattles }
procedure TfGov.CancelDeclineAllPlanetBattles(Action: Integer);
begin
  DialogText := LocalizedColorText('FormGov.I_PlanetBattleRejectAllConfirmAfterNo');
  BuildGovernmentChoices(True);
end;
{ @end $6CF474 }

{ @routine $6CF53C TfGov_ShowPlanetBattleSupport }
procedure TfGov.ShowPlanetBattleSupport(Action: Integer);
var MapIndex: Integer;
begin
  MapIndex := FindRobotMapById(Action);
  if RobotMapDefinitions[MapIndex].ReinforcementsDisabled then
    DialogText := PickLocalizedTextVariant('FormGov.PlanetBattle.GovBeforeBattleNoReinforcements', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 81263)
  else DialogText := PickLocalizedTextVariant('FormGov.PlanetBattle.GovBeforeBattle', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 81263);
  ClearDialogChoices;
  AddChoice(LocalizedColorText('FormGov.PlanetBattle.PlayerBeforeBattleNone'), Action, StartPlanetBattleWithoutSupport);
  if not RobotMapDefinitions[MapIndex].ReinforcementsDisabled then
    AddChoice(LocalizedColorText('FormGov.PlanetBattle.PlayerBeforeBattleHelp'), Action, StartPlanetBattleWithReinforcements);
  AddChoice(LocalizedColorText('FormGov.PlanetBattle.PlayerBeforeBattleDamage'), Action, StartPlanetBattleWithBombardment);
end;
{ @end $6CF53C }

{ @routine $6CF898 TfGov_StartPlanetBattleWithoutSupport }
procedure TfGov.StartPlanetBattleWithoutSupport(Action: Integer);
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  GovernmentBattleDifficulty := 1;
  PlanetBattleMapId := Action;
  PendingTransition := 1;
  RequestedScreenId := screenGovernment;
  LoadPanel.SelectBackgroundStyle(3);
  LoadPanel.RefreshBackgroundImages;
  LoadPanel.StartClosingShutters;
end;
{ @end $6CF898 }

{ @routine $6CF978 TfGov_StartPlanetBattleWithReinforcements }
procedure TfGov.StartPlanetBattleWithReinforcements(Action: Integer);
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  GovernmentBattleDifficulty := 2;
  PlanetBattleMapId := Action;
  PendingTransition := 1;
  RequestedScreenId := screenGovernment;
  LoadPanel.SelectBackgroundStyle(3);
  LoadPanel.RefreshBackgroundImages;
  LoadPanel.StartClosingShutters;
end;
{ @end $6CF978 }

{ @routine $6CFA58 TfGov_StartPlanetBattleWithBombardment }
procedure TfGov.StartPlanetBattleWithBombardment(Action: Integer);
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  GovernmentBattleDifficulty := 3;
  PlanetBattleMapId := Action;
  PendingTransition := 1;
  RequestedScreenId := screenGovernment;
  LoadPanel.SelectBackgroundStyle(3);
  LoadPanel.RefreshBackgroundImages;
  LoadPanel.StartClosingShutters;
end;
{ @end $6CFA58 }

{ @routine $6CFB38 TfGov_DeclineBattleAndLeave }
procedure TfGov.DeclineBattleAndLeave(Action: Integer);
begin
  DialogText := PickLocalizedTextVariant('FormGov.PlanetBattle.GovBeforeNormal', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 81263);
  ClearDialogChoices;
  AddChoice(LocalizedColorText('FormGov.I_Exit'), 0, ReturnToPlanet);
end;
{ @end $6CFB38 }

{ @routine $6CFC68 TfGov_ChoosePrisonInsteadOfBattle }
procedure TfGov.ChoosePrisonInsteadOfBattle(Action: Integer);
begin
  GetPlayer.CurrentPlanet.SetRelationLevelToRanger(GetPlayer, rlHostile);
  if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
  begin
    DialogText := PickLocalizedTextVariant('FormGov.PlanetBattle.GovBeforePrisonPirateClan', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 81263);
    ClearDialogChoices;
    AddChoice(PickLocalizedTextVariant('FormGov.PlanetBattle.PlayerGoToPrisonPirateClan', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 61253), 0, EnterPrison);
  end
  else
  begin
    DialogText := PickLocalizedTextVariant('FormGov.PlanetBattle.GovBeforePrison', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 81263);
    ClearDialogChoices;
    AddChoice(PickLocalizedTextVariant('FormGov.PlanetBattle.PlayerGoToPrison', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 61253), 0, EnterPrison);
  end;
end;
{ @end $6CFC68 }

{ @routine $6CFF78 TfGov_ShowMapOffer }
procedure TfGov.ShowMapOffer(Action: Integer);
var Cost: Integer;
begin
  Cost := RoundAndTruncateToTens(Min(GetPlayer.Wealth div 40, Galaxy.ComputeScaledBigMoney(GetPlayer.CurrentPlanet.OwnerId)) + 50);
  DialogText := FormatText2(PickLocalizedTextVariant('FormGov.BuyMap.GovAsk', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed), '<color=255,240,100>', '<Name>',
    (TObject(GetPlayer.CurrentPlanet.FindUnchartedNeighborConstellation) as TConstellation).GetName,
    '<Money>', WideString(IntToStr(Cost)));
  ClearDialogChoices;
  if GetPlayer.Money >= Cost then
    AddChoice(LocalizedColorText('FormGov.BuyMap.PlayerOk'), 0, BuyMap);
  AddChoice(LocalizedColorText('FormGov.BuyMap.PlayerNO'), 0, DeclineMapOffer);
end;
{ @end $6CFF78 }

{ @routine $6D022C TfGov_BuyMap }
procedure TfGov.BuyMap(Action: Integer);
var Cost: Integer;
begin
  Cost := RoundAndTruncateToTens(Min(GetPlayer.Wealth div 40, Galaxy.ComputeScaledBigMoney(GetPlayer.CurrentPlanet.OwnerId)) + 50);
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  (TObject(GetPlayer.CurrentPlanet.FindUnchartedNeighborConstellation) as TConstellation).Visible := True;
  GetPlayer.AchievementStats.CheckMapBuilderAchievement;
  SoundManager.PlaySound('Sound.Sell');
  DialogText := PickLocalizedTextVariant('FormGov.BuyMap.GovAfterOk', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 711);
  BuildGovernmentChoices(True);
end;
{ @end $6D022C }

{ @routine $6D03CC TfGov_DeclineMapOffer }
procedure TfGov.DeclineMapOffer(Action: Integer);
begin
  DialogText := PickLocalizedTextVariant('FormGov.BuyMap.GovAfterNo', (Galaxy.CurrentTurn div 10) * GetPlayer.CurrentPlanet.GenerationSeed + 112);
  BuildGovernmentChoices(True);
end;
{ @end $6D03CC }

{ @routine $6D0494 TfGov_ShowPrisonBail }
procedure TfGov.ShowPrisonBail(Action: Integer);
var Text, RowText: WideString; Ship: TShip; I, Cost: Integer; Ships: TList;
begin
  DialogText := LocalizedColorText('FormGov.GuarantPrison.PlanetAsk');
  Text := '';
  Ships := TList.Create;
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if (GetPlayer.CurrentPlanet = Ship.CurrentPlanet) and
      ((Ship.ScriptShip = nil) or ((Ship.ScriptShip as TScriptShip).State.StateKind = sskNormalAI)) and
      Ship.IsInPrison and (Ship.GetPrisonTermRemaining > 0) then
    begin
      RowText := FormatText2(LocalizedColorText('FormGov.GuarantPrison.ShipRow'), '<color=255,240,100>',
        '<Ship>', Ship.GetFullName(' '), '<Cost>', WideString(IntToStr(Ship.GetPrisonReleaseCost)));
      Text := Text + #13#10 + ' - ' + RowText;
      Ships.Add(Ship);
    end;
  end;
  DialogText := DialogText + Text;
  ClearDialogChoices;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[I];
    if Ship.IsInPrison then
    begin
      Cost := Ship.GetPrisonReleaseCost;
      Text := LocalizedColorText('FormGov.GuarantPrison.PlayerOk');
      Text := FormatText2(Text, '<color=255,240,100>', '<Ship>', Ship.GetFullName(' '),
        '<Cost>', WideString(IntToStr(Cost)));
      if GetPlayer.Money >= Cost then AddChoice(Text, Integer(Ship), PayPrisonBail)
      else AddChoice(Text, 0, ScriptDialogBlockCallback);
    end;
  end;
  AddChoice(LocalizedColorText('FormGov.GuarantPrison.PlayerNo'), 0, CancelPrisonBail);
  Ships.Free;
end;
{ @end $6D0494 }

{ @routine $6D0924 TfGov_PayPrisonBail }
procedure TfGov.PayPrisonBail(Action: Integer);
var Ship: TShip;
begin
  Ship := TShip(Action);
  if Ship.IsInPrison then
  begin
    GetPlayer.SetMoney(Max(0, GetPlayer.Money - Ship.GetPrisonReleaseCost));
    Ship.ClearPrisonTerm;
    Ship.ChangeRelationToRanger(GetPlayer, 100);
    Ship.OrderTakeoff;
    Inc(GetPlayer.AchievementStats.PrisonersBailedOut);
    TrySetAchievementProgress('PRISONBAIL', GetPlayer.AchievementStats.PrisonersBailedOut);
  end;
  SoundManager.PlaySound('Sound.Sell');
  DialogText := LocalizedColorText('FormGov.GuarantPrison.PlanetAfterOk');
  BuildGovernmentChoices(True);
end;
{ @end $6D0924 }

{ @routine $6D0AC4 TfGov_CancelPrisonBail }
procedure TfGov.CancelPrisonBail(Action: Integer);
begin
  DialogText := LocalizedColorText('FormGov.GuarantPrison.PlanetAfterNo');
  BuildGovernmentChoices(True);
end;
{ @end $6D0AC4 }

{ @routine $6D0B78 TfGov_ReturnToPlanet }
procedure TfGov.ReturnToPlanet(Action: Integer);
begin
  RequestedScreenId := screenPlanet;
  RequestClose(1);
end;
{ @end $6D0B78 }

{ @routine $6D0BA0 TfGov_ExitGovernment }
procedure TfGov.ExitGovernment(Action: Integer);
begin
  RequestedScreenId := screenPlanet;
  RequestClose(1);
end;
{ @end $6D0BA0 }

{ @routine $6D0BC8 TfGov_RunInjectedAnswer }
procedure TfGov.RunInjectedAnswer(Answer: Integer);
var Injection: PScriptDialogInjection; Text: WideString; PartCount: Integer;
begin
  Injection := PScriptDialogInjection(Answer);
  if Injection.ActionCode <> '' then
  begin
    CurrentScript := Injection.ActionScript;
    ExecuteScriptText(Injection.ActionCode, CurrentScript.InitCode.LocalVar);
  end;
  Text := Injection.Answer;
  PartCount := CountDelimitedPartsW(Text, '~');
  if PartCount > 1 then
  begin
    Text := ExtractDelimitedPartW(WideString(LowerCase(AnsiString(Text))), 0, '~');
    if Text = 'snap' then RememberChoiceScroll;
  end;
  ClearDialogChoices;
  CurrentScript := Injection.Script;
  CurrentScript.InitCode.LocalVar.GetVar('GAnswerData').SetDword(Injection.AnswerData);
  ScriptDialogIndex := -1;
  CurrentScript.CallDialogByVariable(Injection.DialogName);
  if ScriptDialogIndex < 0 then BuildGovernmentChoices(True)
  else CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $6D0BC8 }

{ @routine $6D0D8C TfGov_RunInjectedAnswerKeepingScroll }
procedure TfGov.RunInjectedAnswerKeepingScroll(Answer: Integer);
begin
  RememberChoiceScroll;
  RunInjectedAnswer(Answer);
end;
{ @end $6D0D8C }

{ @routine $6D0DB0 TfGov_RunScriptRestartAnswer }
procedure TfGov.RunScriptRestartAnswer(Answer: Integer);
begin
  DialogText := '';
  CurrentScript.ExecuteDialogAnswer(Answer);
  RefreshGovernmentDialog;
end;
{ @end $6D0DB0 }

{ @routine $6D0DE4 TfGov_AddScriptRestartChoice }
procedure TfGov.AddScriptRestartChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptRestartAnswer);
end;
{ @end $6D0DE4 }

{ @routine $6D0E6C TfGov_ExecuteUiCode }
procedure TfGov.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if MainPanel.NavigationLocked then Exit;
  if ExitScreenLoop then Exit;
  if TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared] then
  begin
    Galaxy.CheckIntegrityChecksum(10008);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20008);
  end;
end;
{ @end $6D0E6C }

end.
