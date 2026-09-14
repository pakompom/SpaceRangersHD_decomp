unit fMainForm;
// Unit bracket (inferred): .text 0x00538B20..0x0053BA15; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types, fPanelLoad;

type
  TfMainForm = class(TMessageLoopGI) // @size 0xF4
  public
    BackgroundTimer: PCallbackTimerGI; // @offset 0xD0
    BackgroundScrollOffset: Integer; // @offset 0xD4
    LastMenuShipAnimation: Integer; // @offset 0xD8
    LastGaalShipAnimation: Integer; // @offset 0xDC
    MenuTextState: WideString; // @offset $E0 Cleared on open; other use remains unresolved.
    PopupState: Integer; // @offset $EC Cleared when closing PanelAB.
    LoadPanel: TfPanelLoad; // @offset 0xF0

    constructor Create; // @addr 0x538BCC @ida "TfMainForm *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x538C24 @ida "void __usercall $name(TfMainForm *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout; override; // @addr 0x538C7C
    procedure OnOpen; override; // @addr 0x53A168
    procedure OnClose; override; // @addr 0x53AE9C
    procedure SelectMusic; override; // @addr 0x53B9CC
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x53B9F8
    procedure QuitClicked(Sender: TObjectGI); // @addr 0x53AEB4
    procedure NewGameClicked(Sender: TObjectGI); // @addr 0x53AF60
    procedure AchievementsClicked(Sender: TObjectGI); // @addr 0x53AFA4
    procedure LoadGameClicked(Sender: TObjectGI); // @addr 0x53B000
    procedure SettingsClicked(Sender: TObjectGI); // @addr 0x53B064
    procedure ScoresClicked(Sender: TObjectGI); // @addr 0x53B0C0
    procedure AboutClicked(Sender: TObjectGI); // @addr 0x53B0E8
    procedure RobotBattleClicked(Sender: TObjectGI); // @addr 0x53B88C
    procedure TextQuestClicked(Sender: TObjectGI); // @addr 0x53B8D8
    procedure ArcadeBattleClicked(Sender: TObjectGI); // @addr 0x53B924
    procedure ModsClicked(Sender: TObjectGI); // @addr 0x53B970
    procedure MenuShipAnimationFinished(Sender: TObjectGI); // @addr 0x53B3D0
    procedure GaalShipAnimationFinished(Sender: TObjectGI); // @addr 0x53B5B8
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x53B11C
    procedure MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x53B3A4 @ida "void __userpurge $name(TfMainForm *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ScrollBackground(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x53B770
    procedure ClosePopup; // @addr 0x53B82C
  end;

implementation

uses Classes, Windows, SysUtils, GR_Main, Globals, GlobalsV, GI_GraphButton, GI_GAI, GI_MessageBox, GI_Label, GI_Image, EC_Str, aMyFunction, aScript, aConst, fShip2, fSaveManager, fMods, Robot;

{ @routine $538BCC TfMainForm_Create }
constructor TfMainForm.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $538BCC }

{ @routine $538C24 TfMainForm_Destroy }
destructor TfMainForm.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $538C24 }

{ @routine $538C7C TfMainForm_InitializeLayout }
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
    if Cardinal(GameScreenWidth) >= 1280 then
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight));
      SetText(ReplaceAllWideString(LocalizedText('FormMain.Version'), '<Value>', '2.1.2500'));
      LogoShift := 0;
    end
    else
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth, LocalPosition.Y + ExtraScreenHeight - 7));
      SetText(ReplaceAllWideString(LocalizedText('FormMain.Version2'), '<Value>', '2.1.2500'));
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
    if Cardinal(GameScreenWidth) >= 1600 then
    begin
      OffsetX := -250;
      if (Cardinal(GameScreenHeight) >= 900) and (Cardinal(GameScreenHeight) < 1040) then OffsetY := (1040 - GameScreenHeight) shr 1;
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
            if (Cardinal(GameScreenWidth) >= 1600) and (Cardinal(GameScreenHeight) >= 900) then
            begin
              SetSize(Classes.Point(843, 218));
              SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2, 57));
              SetImagePath('Bm.FormMain3.CaptionLarge');
            end
            else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
          end;
        end
        else
        begin
          with CaptionControl as TImageGI do
          begin
            if (Cardinal(GameScreenWidth) >= 1600) and (Cardinal(GameScreenHeight) >= 900) then
            begin
              SetSize(Classes.Point(843, 218));
              SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2, 57));
              Extension := ExtractFileExtNoDotW(Trim(LowerCase(AnsiString(CacheDataRoot.FindEntry('Bm').ChildData.FindEntry('FormMain3').ChildData.FindEntry('CaptionLarge').SharedFileRef.FileRef.FileName))));
              if Extension = 'gai' then SetImagePath('GAI,Bm.FormMain3.CaptionLarge')
              else SetImagePath('GI,Bm.FormMain3.CaptionLarge');
            end
            else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
          end;
        end;
        with FindByNameRecursive('CaptionBlur') as TImageGI do
        begin
          if (Cardinal(GameScreenWidth) >= 1600) and (Cardinal(GameScreenHeight) >= 900) then
            SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2 - 7, -29))
          else SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
        end;
        with FindByNameRecursive('SubName') as TImageGI do
        begin
          if (Cardinal(GameScreenWidth) >= 1600) and (Cardinal(GameScreenHeight) >= 900) then
          begin
            SetImagePath('GI,Bm.FormMain3.SubLarge');
            SetSize(Classes.Point(932, 76));
            SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2 - 54, 320));
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
{ @end $538C7C }

{ @routine $53A168 TfMainForm_OnOpen }
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
  if BackgroundTimer <> nil then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := nil;
  end;
  if AnimMainFon then BackgroundTimer := ScheduleCallbackTimer(40, 40, ScrollBackground);
  ScrollBackground(nil, 0);
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
  if Cardinal(GameScreenWidth) >= 1600 then
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
  with GetByName('LoadRobotCnt') as TLabelGI do SetText(LoadRobotScreen.GetCompletionSummary);
  with GetByName('LoadQuestCnt') as TLabelGI do SetText(LoadQuestScreen.GetCompletionSummary);
  with GetByName('LoadABCnt') as TLabelGI do SetText(LoadArcadeScreen.GetCatalogSummary);
  with GetByName('ModsCnt') as TLabelGI do
  begin
    if SkipModsOnReload then SetText('<color=255,0,0>' + IntToWideString(CountDelimitedPartsW(SelectedMods, ',')) + '</color>')
    else SetText(IntToWideString(CountDelimitedPartsW(SelectedMods, ',')));
  end;
  if ShowWineWarning then
  begin
    ShowWineWarning := False;
    ShowMessageBoxGI(Self, LocalizedColorText('Warning.WeRunOnWine'), mbgCancel or mbgUnused04);
  end;
  if ShowXonarWarning then
  begin
    ShowXonarWarning := False;
    ShowMessageBoxGI(Self, LocalizedColorText('Warning.XonarDetected'), mbgCancel or mbgUnused04);
  end;
end;
{ @end $53A168 }

{ @routine $53AE9C TfMainForm_OnClose }
procedure TfMainForm.OnClose;
begin
  LoadPanel.OnClose;
end;
{ @end $53AE9C }

{ @routine $53AEB4 TfMainForm_QuitClicked }
procedure TfMainForm.QuitClicked(Sender: TObjectGI);
begin
  if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormMain.MsgExit'), mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
  begin
    RequestedScreenId := screenNone;
    RequestClose(1);
  end;
end;
{ @end $53AEB4 }

{ @routine $53AF60 TfMainForm_NewGameClicked }
procedure TfMainForm.NewGameClicked(Sender: TObjectGI);
begin
  ShipScreen.SelectedHoldKind := phkEmpty;
  ShipScreen.SelectedHoldItem := nil;
  RequestedScreenId := screenNewGame;
  RequestClose(1);
end;
{ @end $53AF60 }

{ @routine $53AFA4 TfMainForm_AchievementsClicked }
procedure TfMainForm.AchievementsClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  AchievementsReturnScreenId := FormToId(Self);
  RequestedScreenId := screenAchievements;
  RequestClose(1);
end;
{ @end $53AFA4 }

{ @routine $53B000 TfMainForm_LoadGameClicked }
procedure TfMainForm.LoadGameClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveManagerMode := smmLoad;
  RequestedScreenId := screenSaveManager;
  RequestClose(1);
end;
{ @end $53B000 }

{ @routine $53B064 TfMainForm_SettingsClicked }
procedure TfMainForm.SettingsClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  SettingsReturnScreenId := FormToId(Self);
  RequestedScreenId := screenSettings;
  RequestClose(1);
end;
{ @end $53B064 }

{ @routine $53B0C0 TfMainForm_ScoresClicked }
procedure TfMainForm.ScoresClicked(Sender: TObjectGI);
begin
  RequestedScreenId := screenScores;
  RequestClose(1);
end;
{ @end $53B0C0 }

{ @routine $53B0E8 TfMainForm_AboutClicked }
procedure TfMainForm.AboutClicked(Sender: TObjectGI);
begin
  AboutScreen.ReturnToScores := False;
  RequestedScreenId := screenAbout;
  RequestClose(1);
end;
{ @end $53B0E8 }

{ @routine $53B11C TfMainForm_MainPanelKeyDown }
procedure TfMainForm.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = Ord('Q') then
  begin
    TGraphButtonGI(GetByName('LoadQuest')).ExecuteOnPressCode;
    TextQuestClicked(nil);
  end
  else if (Key = Ord('R')) and IsInstallFeatureEnabled('Robot') and
    (RobotInterface <> nil) and (RobotInterface.Support = 0) and (FindControlByPath('PanelRL') = nil) then
  begin
    TGraphButtonGI(GetByName('LoadRobot')).ExecuteOnPressCode;
    RobotBattleClicked(nil);
  end
  else if (Key = Ord('A')) or (Key = Ord('F')) then
  begin
    TGraphButtonGI(GetByName('LoadAB')).ExecuteOnPressCode;
    ArcadeBattleClicked(nil);
  end
  else if Key = Ord('M') then ModsClicked(nil)
  else if (Key = VK_F3) or (Key = Ord('L')) then
  begin
    TGraphButtonGI(GetByName('Load')).ExecuteOnPressCode;
    SaveManagerReturnScreenId := FormToId(Self);
    SaveManagerMode := smmLoad;
    RequestedScreenId := screenSaveManager;
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
{ @end $53B11C }

{ @routine $53B3A4 TfMainForm_MainPanelMouseMove }
procedure TfMainForm.MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  RefreshTimerTick;
end;
{ @end $53B3A4 }

{ @routine $53B3D0 TfMainForm_MenuShipAnimationFinished }
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
{ @end $53B3D0 }

{ @routine $53B5B8 TfMainForm_GaalShipAnimationFinished }
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
{ @end $53B5B8 }

{ @routine $53B770 TfMainForm_ScrollBackground }
procedure TfMainForm.ScrollBackground(Timer: PCallbackTimerGI; UserData: Integer);
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
{ @end $53B770 }

{ @routine $53B82C TfMainForm_ClosePopup }
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
{ @end $53B82C }

{ @routine $53B88C TfMainForm_RobotBattleClicked }
procedure TfMainForm.RobotBattleClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  RequestedScreenId := screenLoadRobot;
  RequestClose(1);
end;
{ @end $53B88C }

{ @routine $53B8D8 TfMainForm_TextQuestClicked }
procedure TfMainForm.TextQuestClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  RequestedScreenId := screenLoadQuest;
  RequestClose(1);
end;
{ @end $53B8D8 }

{ @routine $53B924 TfMainForm_ArcadeBattleClicked }
procedure TfMainForm.ArcadeBattleClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  RequestedScreenId := screenLoadArcade;
  RequestClose(1);
end;
{ @end $53B924 }

{ @routine $53B970 TfMainForm_ModsClicked }
procedure TfMainForm.ModsClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  SetCursorActive(True);
  ShowModsManager(Self);
  if ReloadModsRequested then
  begin
    RequestedScreenId := screenNone;
    PostLoadScreenId := screenMainMenu;
    RequestClose(1);
  end;
end;
{ @end $53B970 }

{ @routine $53B9CC TfMainForm_SelectMusic }
procedure TfMainForm.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $53B9CC }

{ @routine $53B9F8 TfMainForm_ExecuteUiCode }
procedure TfMainForm.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  ExecuteGameplayUiCode(Block, Key);
end;
{ @end $53B9F8 }

end.
