unit fMainForm;

interface

uses EC_BlockPar, GI_MessageLoop, Types, fPanelLoad;

type
  TfMainForm = class(TMessageLoopGI) // @size 0xF4
  public
    BackgroundTimer: TCallbackTimerIdGI; // @offset 0xD0
    BackgroundScrollOffset: Integer; // @offset 0xD4
    LastMenuShipAnimation: Integer; // @offset 0xD8
    LastGaalShipAnimation: Integer; // @offset 0xDC
    MenuTextState: WideString; // @offset $E0 Cleared on open; otherwise unused in the recovered code.
    PopupState: Integer; // @offset $EC Cleared when closing PanelAB.
    LoadPanel: TfPanelLoad; // @offset 0xF0

    constructor Create; // @addr 0x0052E98C
    destructor Destroy; override; // @addr 0x0052E9D4
    procedure InitializeLayout; override; // @addr 0x0052EA10
    procedure OnOpen; override; // @addr 0x0052FBEC
    procedure OnClose; override; // @addr 0x0053085C
    procedure SelectMusic; override; // @addr 0x00531224
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x00531248
    procedure QuitClicked(Sender: TObjectGI); // @addr 0x00530868
    procedure NewGameClicked(Sender: TObjectGI); // @addr 0x0053090C
    procedure AchievementsClicked(Sender: TObjectGI); // @addr 0x00530940
    procedure LoadGameClicked(Sender: TObjectGI); // @addr 0x0053098C
    procedure SettingsClicked(Sender: TObjectGI); // @addr 0x005309E0
    procedure ScoresClicked(Sender: TObjectGI); // @addr 0x00530A2C
    procedure AboutClicked(Sender: TObjectGI); // @addr 0x00530A40
    procedure RobotBattleClicked(Sender: TObjectGI); // @addr 0x00531124
    procedure TextQuestClicked(Sender: TObjectGI); // @addr 0x00531160
    procedure ArcadeBattleClicked(Sender: TObjectGI); // @addr 0x0053119C
    procedure ModsClicked(Sender: TObjectGI); // @addr 0x005311D8
    procedure MenuShipAnimationFinished(Sender: TObjectGI); // @addr 0x00530CDC
    procedure GaalShipAnimationFinished(Sender: TObjectGI); // @addr 0x00530EA4
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x00530A64
    procedure MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x00530CBC
    procedure ScrollBackground(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00531038
    procedure ClosePopup; // @addr 0x005310D4
  end;

implementation

uses Classes, Windows, SysUtils, GR_Main, Globals, GlobalsV, GI_GraphButton, GI_GAI, GI_MessageBox, GI_Label, GI_Image, EC_Str, aMyFunction, aScript, aConst, fShip2, fSaveManager, fMods, Robot;

{ @routine $52E98C TfMainForm_Create }
constructor TfMainForm.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $52E98C }

{ @routine $52E9D4 TfMainForm_Destroy }
destructor TfMainForm.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $52E9D4 }

{ @routine $52EA10 TfMainForm_InitializeLayout }
procedure TfMainForm.InitializeLayout;
var
  OffsetX, OffsetY, LogoShift: Integer;
  Extension: WideString;
  CaptionControl: TObjectGI;
begin
  inherited InitializeLayout;
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fMainForm... ');
  with GetByName('LVersion') as TLabelGI do
  begin
    if GameScreenWidth >= 1280 then
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
      Text := ReplaceAllWideString(LocalizedText('FormMain.Version'), '<Value>', GameVersionText);
      LogoShift := 0;
    end
    else
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight - 7));
      Text := ReplaceAllWideString(LocalizedText('FormMain.Version2'), '<Value>', GameVersionText);
      LogoShift := 16;
    end;
  end;
  with GetByName('LogoElemental') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight - LogoShift));
  with GetByName('Logo1C') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight - LogoShift));
  with GetByName('LogoKatauri') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight - LogoShift));
  with GetByName('LogoSNK') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight - LogoShift));
  if (ExtraScreenWidth <> 0) or (ExtraScreenHeight <> 0) then
  begin
    ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
    OffsetX := 0;
    OffsetY := 0;
    if GameScreenWidth >= 1600 then
    begin
      OffsetX := -250;
      if (GameScreenHeight >= 900) and (GameScreenHeight < 1040) then OffsetY := (1040 - Integer(GameScreenHeight)) shr 1;
    end;
    with GetByName('MainPanel') do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      with FindByNameRecursive('AnimMain') do
      begin
        if ExtraScreenHeight < 0 then
        begin
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
          SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
        end
        else SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      end;
      with FindByNameRecursive('MicroText') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('Circle') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('New') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Score') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Achievements') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Load') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Settings') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('About') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Exit') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('AnimAddonShip') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadRobot') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadQuest') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadAB') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('Mods') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadRobotCnt') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadQuestCnt') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadABCnt') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('ModsCnt') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LRobot') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LQuest') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LAB') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LMods') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      if ExtraScreenWidth > 0 then
      begin
        CaptionControl := FindByNameRecursive('Caption');
        if CaptionControl is TgaiGI then
        begin
          with CaptionControl as TgaiGI do
          begin
            if (GameScreenWidth >= 1600) and (GameScreenHeight >= 900) then
            begin
              SetSize(Classes.Point(843, 218));
              SetPosition(Classes.Point((Integer(GameScreenWidth) - ClientSize.X) div 2, 57));
              SetImagePath('Bm.FormMain3.CaptionLarge');
            end
            else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
          end;
        end
        else
        begin
          with CaptionControl as TImageGI do
          begin
            if (GameScreenWidth >= 1600) and (GameScreenHeight >= 900) then
            begin
              SetSize(Classes.Point(843, 218));
              SetPosition(Classes.Point((Integer(GameScreenWidth) - ClientSize.X) div 2, 57));
              Extension := ExtractFileExtNoDotW(Trim(LowerCase(AnsiString(CacheDataRoot.FindEntry('Bm').ChildData.FindEntry('FormMain3').ChildData.FindEntry('CaptionLarge').SharedFileRef.FileRef.FileName))));
              if Extension = 'gai' then ImageSourcePath := 'GAI,Bm.FormMain3.CaptionLarge'
              else ImageSourcePath := 'GI,Bm.FormMain3.CaptionLarge';
            end
            else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
          end;
        end;
        with FindByNameRecursive('CaptionBlur') as TImageGI do
        begin
          if (GameScreenWidth >= 1600) and (GameScreenHeight >= 900) then
            SetPosition(Classes.Point((Integer(GameScreenWidth) - ClientSize.X) div 2 - 7, -29))
          else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
        end;
        with FindByNameRecursive('SubName') as TImageGI do
        begin
          if (GameScreenWidth >= 1600) and (GameScreenHeight >= 900) then
          begin
            ImageSourcePath := 'GI,Bm.FormMain3.SubLarge';
            SetSize(Classes.Point(932, 76));
            SetPosition(Classes.Point((Integer(GameScreenWidth) - ClientSize.X) div 2 - 54, 320));
          end
          else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
        end;
      end;
      with FindByNameRecursive('Planet') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    end;
  end;
  AppendLogLineThreadSafe('ok');
  with GetByName('LoadRobot') as TGraphButtonGI do
  begin
    SetActive(RobotInterface <> nil);
    UpCallback := RobotBattleClicked;
  end;
  with GetByName('LoadQuest') as TGraphButtonGI do UpCallback := TextQuestClicked;
  with GetByName('LoadAB') as TGraphButtonGI do UpCallback := ArcadeBattleClicked;
  with GetByName('Mods') as TGraphButtonGI do UpCallback := ModsClicked;
end;
{ @end $52EA10 }

{ @routine $52FBEC TfMainForm_OnOpen }
procedure TfMainForm.OnOpen;
var I: Integer;
begin
  SuppressModRetryPrompt := True;
  LoadPanel.OnOpen;
  LastMenuShipAnimation := -1;
  LastGaalShipAnimation := -1;
  MenuTextState := '';
  if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
  Galaxy := nil;
  // Retained native wait follows clearing the global, even on the standalone path.
  while (Galaxy <> nil) and Galaxy.Destroying do SysUtils.Sleep(1);
  I := 0;
  while FindControlByPath('TempGAI' + IntToStr(I)) <> nil do
  begin
    (GetByName('TempGAI' + IntToStr(I)) as TgaiGI).RestartPlayback;
    Inc(I);
  end;
  GetByName('MainPanel').MouseMoveCallback := MainPanelMouseMove;
  (GetByName('Exit') as TGraphButtonGI).UpCallback := QuitClicked;
  (GetByName('New') as TGraphButtonGI).UpCallback := NewGameClicked;
  (GetByName('Load') as TGraphButtonGI).UpCallback := LoadGameClicked;
  (GetByName('Settings') as TGraphButtonGI).UpCallback := SettingsClicked;
  (GetByName('Achievements') as TGraphButtonGI).UpCallback := AchievementsClicked;
  with GetByName('Score') as TGraphButtonGI do UpCallback := ScoresClicked;
  (GetByName('About') as TGraphButtonGI).UpCallback := AboutClicked;
  SelectMusic;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  BackgroundScrollOffset := 0;
  if BackgroundTimer <> 0 then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := 0;
  end;
  if AnimMainFon then BackgroundTimer := ScheduleCallbackTimer(40, 40, ScrollBackground);
  ScrollBackground(0, 0);
  if GetByName('Logo1C') is TgaiGI then
    with GetByName('Logo1C') as TgaiGI do
    begin
      SequenceIndex := 0;
      UpdateAutoGeometry;
      StopAutoPlayback;
      PrimeImageCaches;
    end;
  if GetByName('LogoElemental') is TgaiGI then
    with GetByName('LogoElemental') as TgaiGI do
    begin
      SequenceIndex := 0;
      UpdateAutoGeometry;
      StopAutoPlayback;
      PrimeImageCaches;
    end;
  with GetByName('AnimAddonShip') as TgaiGI do
  begin
    FirstFrameOnly := not AnimMenuShip;
    SetPosition(Classes.Point(0, ExtraScreenHeight div 2 + 60));
    SetDepth(29);
    if AnimMenuShip then
    begin
      SetFirstFrameImagePath('Bm.FormMain3.2Ship1');
      SetImagePath('Bm.FormMain3.2ShipA1');
      PrimeImageCaches;
      SetFirstFrameImagePath('Bm.FormMain3.2Ship2');
      SetImagePath('Bm.FormMain3.2ShipA2');
      PrimeImageCaches;
      SetFirstFrameImagePath('Bm.FormMain3.2Ship3');
      SetImagePath('Bm.FormMain3.2ShipA3');
      PrimeImageCaches;
      CycleCompleteCallback := MenuShipAnimationFinished;
      MenuShipAnimationFinished(FindByNameRecursive('AnimAddonShip'));
    end
    else
    begin
      SetFirstFrameImagePath('Bm.FormMain3.2Ship1');
      PrimeImageCaches;
    end;
    SetActive(True);
  end;
  if GameScreenWidth >= 1600 then
  begin
    if FindControlByPath('AnimGaalShip') <> nil then
      with GetByName('AnimGaalShip') as TgaiGI do
      begin
        FirstFrameOnly := not AnimMenuShip;
        SetPosition(Classes.Point(GameScreenWidth - 661, (GameScreenHeight - 642) shr 1 + 70));
        SetDepth(29);
        if AnimMenuShip then
        begin
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip01');
          SetImagePath('Bm.FormMain3.AnimGaalShip01A');
          PrimeImageCaches;
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip02');
          SetImagePath('Bm.FormMain3.AnimGaalShip02A');
          PrimeImageCaches;
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip03');
          SetImagePath('Bm.FormMain3.AnimGaalShip03A');
          PrimeImageCaches;
          CycleCompleteCallback := GaalShipAnimationFinished;
          GaalShipAnimationFinished(FindByNameRecursive('AnimGaalShip'));
        end
        else
        begin
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip01');
          PrimeImageCaches;
        end;
        SetActive(True);
      end;
  end
  else if FindControlByPath('AnimGaalShip') <> nil then GetByName('AnimGaalShip').SetActive(False);
  with GetByName('LoadRobotCnt') as TLabelGI do Text := LoadRobotScreen.GetCompletionSummary;
  with GetByName('LoadQuestCnt') as TLabelGI do Text := LoadQuestScreen.GetCompletionSummary;
  with GetByName('LoadABCnt') as TLabelGI do Text := LoadArcadeScreen.GetCatalogSummary;
  with GetByName('ModsCnt') as TLabelGI do
  begin
    if SkipModsOnReload then Text := RedColorTag + IntToWideString(CountDelimitedPartsW(SelectedMods, ',')) + EndColorTag
    else Text := IntToWideString(CountDelimitedPartsW(SelectedMods, ','));
  end;
  if ShowWineWarning then
  begin
    ShowWineWarning := False;
    ShowMessageBoxGI(Self, LocalizedColorText('Warning.WeRunOnWine'), messagebox_cancel or messagebox_info);
  end;
  if ShowXonarWarning then
  begin
    ShowXonarWarning := False;
    ShowMessageBoxGI(Self, LocalizedColorText('Warning.XonarDetected'), messagebox_cancel or messagebox_info);
  end;
end;
{ @end $52FBEC }

{ @routine $53085C TfMainForm_OnClose }
procedure TfMainForm.OnClose;
begin
  LoadPanel.OnClose;
end;
{ @end $53085C }

{ @routine $530868 TfMainForm_QuitClicked }
procedure TfMainForm.QuitClicked(Sender: TObjectGI);
begin
  if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormMain.MsgExit'), messagebox_ok or messagebox_cancel or messagebox_question) = messagebox_result_ok then
  begin
    RequestedScreenId := screen_none;
    RequestClose(1);
  end;
end;
{ @end $530868 }

{ @routine $53090C TfMainForm_NewGameClicked }
procedure TfMainForm.NewGameClicked(Sender: TObjectGI);
begin
  ShipScreen.SelectedHoldKind := hold_empty;
  ShipScreen.SelectedHoldItem := nil;
  RequestedScreenId := screen_new_game;
  RequestClose(1);
end;
{ @end $53090C }

{ @routine $530940 TfMainForm_AchievementsClicked }
procedure TfMainForm.AchievementsClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  AchievementsReturnScreenId := FormToId(Self);
  RequestedScreenId := screen_achievements;
  RequestClose(1);
end;
{ @end $530940 }

{ @routine $53098C TfMainForm_LoadGameClicked }
procedure TfMainForm.LoadGameClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  SaveManagerReturnScreenId := FormToId(Self);
  SaveManagerMode := save_dialog_load;
  RequestedScreenId := screen_save_manager;
  RequestClose(1);
end;
{ @end $53098C }

{ @routine $5309E0 TfMainForm_SettingsClicked }
procedure TfMainForm.SettingsClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  SettingsReturnScreenId := FormToId(Self);
  RequestedScreenId := screen_settings;
  RequestClose(1);
end;
{ @end $5309E0 }

{ @routine $530A2C TfMainForm_ScoresClicked }
procedure TfMainForm.ScoresClicked(Sender: TObjectGI);
begin
  RequestedScreenId := screen_scores;
  RequestClose(1);
end;
{ @end $530A2C }

{ @routine $530A40 TfMainForm_AboutClicked }
procedure TfMainForm.AboutClicked(Sender: TObjectGI);
begin
  AboutScreen.ReturnToScores := False;
  RequestedScreenId := screen_about;
  RequestClose(1);
end;
{ @end $530A40 }

{ @routine $530A64 TfMainForm_MainPanelKeyDown }
procedure TfMainForm.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = Ord('Q') then
  begin
    TGraphButtonGI(GetByName('LoadQuest')).ExecuteOnPressCode;
    TextQuestClicked(nil);
    Exit;
  end;
  if (Key = Ord('R')) and IsInstallFeatureEnabled('Robot') and
    (RobotInterface <> nil) and (RobotInterface.Support = 0) and (FindControlByPath('PanelRL') = nil) then
  begin
    TGraphButtonGI(GetByName('LoadRobot')).ExecuteOnPressCode;
    RobotBattleClicked(nil);
    Exit;
  end;
  if (Key = Ord('A')) or (Key = Ord('F')) then
  begin
    TGraphButtonGI(GetByName('LoadAB')).ExecuteOnPressCode;
    ArcadeBattleClicked(nil);
    Exit;
  end;
  if Key = Ord('M') then
  begin
    ModsClicked(nil);
    Exit;
  end;
  if (Key = VK_F3) or (Key = Ord('L')) then
  begin
    TGraphButtonGI(GetByName('Load')).ExecuteOnPressCode;
    SaveManagerReturnScreenId := FormToId(Self);
    SaveManagerMode := save_dialog_load;
    RequestedScreenId := screen_save_manager;
    RequestClose(1);
  end
  else if Key = VK_ESCAPE then
  begin
    if FindControlByPath('PanelAB') <> nil then ClosePopup
    else QuitClicked(nil);
  end
  else if (Key = Ord('N')) or (Key = VK_RETURN) then
  begin
    TGraphButtonGI(GetByName('New')).ExecuteOnPressCode;
    NewGameClicked(nil);
  end
  else if Key = Ord('C') then
  begin
    TGraphButtonGI(GetByName('Settings')).ExecuteOnPressCode;
    SettingsClicked(nil);
  end;
end;
{ @end $530A64 }

{ @routine $530CBC TfMainForm_MainPanelMouseMove }
procedure TfMainForm.MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  RefreshTimerTick;
end;
{ @end $530CBC }

{ @routine $530CDC TfMainForm_MenuShipAnimationFinished }
procedure TfMainForm.MenuShipAnimationFinished(Sender: TObjectGI);
var Index: Integer;
begin
  Index := 1;
  repeat
    case RandomIntRange(0, 99) of
      0..49: Index := 1;
      50..69: Index := 2;
      70..99: Index := 3;
    end;
  until (Index = 1) or (Index <> LastMenuShipAnimation);
  LastMenuShipAnimation := Index;
  with GetByName('AnimAddonShip') as TgaiGI do
  begin
    SetFirstFrameImagePath('Bm.FormMain3.' + GiResourceSuffix + 'Ship' + IntToStr(Index));
    SetImagePath('Bm.FormMain3.' + GiResourceSuffix + 'ShipA' + IntToStr(Index));
    SequenceIndex := 0;
    UpdateAutoGeometry;
    RestartPlayback;
  end;
end;
{ @end $530CDC }

{ @routine $530EA4 TfMainForm_GaalShipAnimationFinished }
procedure TfMainForm.GaalShipAnimationFinished(Sender: TObjectGI);
var Index: Integer;
begin
  Index := 1;
  repeat
    case RandomIntRange(0, 99) of
      0..49: Index := 1;
      50..69: Index := 2;
      70..99: Index := 3;
    end;
  until (Index = 1) or (Index <> LastGaalShipAnimation);
  LastGaalShipAnimation := Index;
  with GetByName('AnimGaalShip') as TgaiGI do
  begin
    SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip0' + IntToStr(Index));
    SetImagePath('Bm.FormMain3.AnimGaalShip0' + IntToStr(Index) + 'A');
    SequenceIndex := 0;
    UpdateAutoGeometry;
    RestartPlayback;
  end;
end;
{ @end $530EA4 }

{ @routine $531038 TfMainForm_ScrollBackground }
procedure TfMainForm.ScrollBackground(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Offset: Integer;
begin
  Inc(BackgroundScrollOffset);
  with GetByName('ImageFon1') do
  begin
    Offset := BackgroundScrollOffset mod ClientSize.X;
    SetPosition(Classes.Point(0 - Offset, 0));
  end;
  with GetByName('ImageFon2') do SetPosition(Classes.Point(ClientSize.X - Offset, 0));
end;
{ @end $531038 }

{ @routine $5310D4 TfMainForm_ClosePopup }
procedure TfMainForm.ClosePopup;
var Control: TObjectGI;
begin
  PopupState := 0;
  if FindControlByPath('PanelAB') <> nil then
  begin
    Control := FindControlByPath('PanelAB');
    Control.Invalidate;
    Control.Free;
  end;
end;
{ @end $5310D4 }

{ @routine $531124 TfMainForm_RobotBattleClicked }
procedure TfMainForm.RobotBattleClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  RequestedScreenId := screen_planet_battle_selection;
  RequestClose(1);
end;
{ @end $531124 }

{ @routine $531160 TfMainForm_TextQuestClicked }
procedure TfMainForm.TextQuestClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  RequestedScreenId := screen_quest_selection;
  RequestClose(1);
end;
{ @end $531160 }

{ @routine $53119C TfMainForm_ArcadeBattleClicked }
procedure TfMainForm.ArcadeBattleClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  CaptureScreenBackground(True, 0);
  Self.ShowCursor := True;
  RequestedScreenId := screen_arcade_selection;
  RequestClose(1);
end;
{ @end $53119C }

{ @routine $5311D8 TfMainForm_ModsClicked }
procedure TfMainForm.ModsClicked(Sender: TObjectGI);
begin
  Self.ShowCursor := False;
  Present;
  Self.ShowCursor := True;
  ShowModsManager(Self);
  if ReloadModsRequested then
  begin
    RequestedScreenId := screen_none;
    PostLoadScreenId := screen_main_menu;
    RequestClose(1);
  end;
end;
{ @end $5311D8 }

{ @routine $531224 TfMainForm_SelectMusic }
procedure TfMainForm.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $531224 }

{ @routine $531248 TfMainForm_ExecuteUiCode }
procedure TfMainForm.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  ExecuteGameplayUiCode(Block, Key);
end;
{ @end $531248 }

end.
