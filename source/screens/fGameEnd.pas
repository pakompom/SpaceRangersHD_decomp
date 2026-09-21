unit fGameEnd;
// Unit bracket (inferred): .text 0x005E4DE4..0x005E8117; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, Types;

type
  TfGameEnd = class(TMessageLoopGI) // @size $E4
  public
    TextScrollTimer: PCallbackTimerGI; // @offset $D0
    TextPanelTop: Integer; // @offset $D4
    TextPanelHeight: Integer; // @offset $D8
    BackgroundTimer: PCallbackTimerGI; // @offset $DC
    BackgroundScrollOffset: Integer; // @offset $E0

    procedure ScrollBackground(Timer: PCallbackTimerGI; UserData: Integer); // @addr $5E7C28
    procedure ScrollEndingText(Timer: PCallbackTimerGI; UserData: Integer); // @addr $5E7CEC
    procedure ContinueClicked(Sender: TObjectGI); // @addr $5E7DF4
    procedure LoadClicked(Sender: TObjectGI); // @addr $5E7E98
    procedure ShowControlHelp(Sender: TObjectGI; Show: Boolean); // @addr $5E7F08
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5E7FA0

    procedure OnOpen; override; // @addr $5E60E0
    procedure OnClose; override; // @addr $5E7B8C
    procedure SelectMusic; override; // @addr $5E8008
    procedure InitializeLayout; override; // @addr $5E4E7C
  end;

implementation

uses aGalaxyStruct, Classes, Windows, SysUtils, EC_Str, EC_Struct, GI_Main, GI_Frame,
  GI_Image, GI_Label, GI_GraphButton, GI_GraphBuf, GR_Main, GR_Music,
  Globals, GlobalsV, aMyFunction, aPlayer, aGalaxy, aGalaxyEvent,
  fScore, fAbout, fSaveManager, ThreadCalc, SimpleSteamApi, Achievements;

{ @routine $5E4E7C TfGameEnd_InitializeLayout }
procedure TfGameEnd.InitializeLayout;
var Unused: Integer; Control: TObjectGI;
begin
  inherited;
  AppendLogTextThreadSafe('fGameEnd... ');
  ViewportRect := Classes.Rect(ExtraScreenWidth div 2,ExtraScreenHeight div 2,ViewportRect.Left + ExtraScreenWidth div 2,ViewportRect.Top + ExtraScreenHeight div 2);
  with TFrameGI.Create(GetByName('MainPanel')) do
  begin
    SetName('FrameLoad');
    SetFillColor(0);
    SetFill(True);
    SetKind(fkRect);
    SetPosition(Classes.Point(0,0));
    SetDepth(1);
    SetSize(Classes.Point(0,0));
  end;
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('ImageFon1') do SetPosition(Classes.Point(LocalPosition.X,GameScreenHeight - ClientSize.Y));
    with FindByNameRecursive('ImageFon2') do SetPosition(Classes.Point(LocalPosition.X,GameScreenHeight - ClientSize.Y));
    with FindByNameRecursive('ImageTop') do SetSize(Classes.Point(GameScreenWidth,ClientSize.Y));
    with FindByNameRecursive('ImageBottom') do
    begin
      SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight));
      SetSize(Classes.Point(GameScreenWidth,ClientSize.Y));
    end;
    with FindByNameRecursive('ImageScreen') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Maloc') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Peleng') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Fei') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Gaal') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin1Maloc') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin1Peleng') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin1People') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin1Fei') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin1Gaal') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin2') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin3Maloc') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin3Peleng') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin3People') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin3Fei') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin3Gaal') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin4Maloc') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin4Peleng') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin4People') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin4Fei') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin4Gaal') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin5Maloc') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin5Peleng') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin5People') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin5Fei') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin5Gaal') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin6') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin7') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('PirateWin8') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('MainPanel') do
    begin
      Control := FirstChild;
      while Control <> nil do
      begin
        if FindTextOffsetW(Control.ControlName,'CustomEnd') = 0 then
          Control.SetPosition(Classes.Point(Control.LocalPosition.X,Control.LocalPosition.Y + ExtraScreenHeight div 2));
        Control := Control.NextSibling;
      end;
    end;
    with FindByNameRecursive('Ok') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('Load') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('LabelHelp') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('PanelText') do
    begin
      SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth,ClientSize.Y + ExtraScreenHeight));
      with FindByNameRecursive('GBText') do SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth,ClientSize.Y));
    end;
    AppendLogLineThreadSafe('ok');
  end;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  SetHelpCallback(ShowControlHelp);
  (GetByName('Ok') as TGraphButtonGI).UpCallback := ContinueClicked;
  (GetByName('Load') as TGraphButtonGI).UpCallback := LoadClicked;
end;
{ @end $5E4E7C }

{ @routine $5E60E0 TfGameEnd_OnOpen }
procedure TfGameEnd.OnOpen;
var
  Text, DeathCause: WideString;
  Score: TfScoreUnit;
  Position, Size: TPoint;
  I: Integer;
  Event: TGalaxyEvent;
  Control: TObjectGI;
  CustomText, CustomPicture: WideString;
  CustomWin, CustomLoss, DefaultLoss: Boolean;
begin
  WaitForTurnCalculation;
  if SteamInitialized and not SteamLeaderboardFound then SteamSetLeaderboardName('Scores');
  CustomText := '';
  CustomPicture := '';
  CustomWin := False;
  CustomLoss := False;
  if GameEndReason = gerDefault then
    for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
    begin
      Event := Galaxy.GalaxyEvents[I];
      if Event.EventType = 'CustomLose' then
      begin
        CustomText := Event.GetTextData(0);
        CustomPicture := Event.GetTextData(1);
        CustomLoss := True;
        Break;
      end;
      if Event.EventType = 'CustomWin' then
      begin
        CustomText := Event.GetTextData(0);
        CustomPicture := Event.GetTextData(1);
        CustomWin := True;
        Break;
      end;
    end;
  if (GameEndReason > 4) or CustomWin then
  begin
    (GetByName('ImageFon1') as TImageGI).SetImagePath('GI,Bm.FormIntro2.2bg');
    (GetByName('ImageFon2') as TImageGI).SetImagePath('GI,Bm.FormIntro2.2bg');
  end
  else
  begin
    (GetByName('ImageFon1') as TImageGI).SetImagePath('GI,Bm.FormEnd2.2bg');
    (GetByName('ImageFon2') as TImageGI).SetImagePath('GI,Bm.FormEnd2.2bg');
  end;
  BackgroundScrollOffset := 0;
  if BackgroundTimer <> nil then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := nil;
  end;
  if AnimMainFon then BackgroundTimer := ScheduleCallbackTimer(40,40,ScrollBackground);
  ScrollBackground(nil,0);
  SelectMusic;
  if GetPlayer <> nil then
    ScoreScreen.RecordPlayerResult((GetPlayer <> nil) and (GameEndReason <> gerPlayerDeath) and not CustomLoss);
  Score := ScoreScreen.Entries[ScoreScreen.SelectedIndex];
  DefaultLoss := (GameEndReason <= 4) and not CustomWin and (CustomPicture = '');
  GetByName('Maloc').SetActive((Score.PilotRace = oiMaloc) and DefaultLoss);
  GetByName('Peleng').SetActive((Score.PilotRace = oiPeleng) and DefaultLoss);
  GetByName('Fei').SetActive((Score.PilotRace = oiFeyan) and DefaultLoss);
  GetByName('Gaal').SetActive((Score.PilotRace = oiGaal) and DefaultLoss);
  GetByName('PirateWin1Maloc').SetActive((GameEndReason in [5,9,11]) and (Score.PilotRace = oiMaloc));
  GetByName('PirateWin1Peleng').SetActive((GameEndReason in [5,9,11]) and (Score.PilotRace = oiPeleng));
  GetByName('PirateWin1People').SetActive((GameEndReason in [5,9,11]) and (Score.PilotRace = oiHuman));
  GetByName('PirateWin1Fei').SetActive((GameEndReason in [5,9,11]) and (Score.PilotRace = oiFeyan));
  GetByName('PirateWin1Gaal').SetActive((GameEndReason in [5,9,11]) and (Score.PilotRace = oiGaal));
  GetByName('PirateWin2').SetActive(GameEndReason in [6,10]);
  GetByName('PirateWin3Maloc').SetActive((GameEndReason in [7,18]) and (Score.PilotRace = oiMaloc));
  GetByName('PirateWin3Peleng').SetActive((GameEndReason in [7,18]) and (Score.PilotRace = oiPeleng));
  GetByName('PirateWin3People').SetActive((GameEndReason in [7,18]) and (Score.PilotRace = oiHuman));
  GetByName('PirateWin3Fei').SetActive((GameEndReason in [7,18]) and (Score.PilotRace = oiFeyan));
  GetByName('PirateWin3Gaal').SetActive((GameEndReason in [7,18]) and (Score.PilotRace = oiGaal));
  GetByName('PirateWin4Maloc').SetActive((GameEndReason = 8) and (Score.PilotRace = oiMaloc));
  GetByName('PirateWin4Peleng').SetActive((GameEndReason = 8) and (Score.PilotRace = oiPeleng));
  GetByName('PirateWin4People').SetActive((GameEndReason = 8) and (Score.PilotRace = oiHuman));
  GetByName('PirateWin4Fei').SetActive((GameEndReason = 8) and (Score.PilotRace = oiFeyan));
  GetByName('PirateWin4Gaal').SetActive((GameEndReason = 8) and (Score.PilotRace = oiGaal));
  GetByName('PirateWin5Maloc').SetActive((GameEndReason in [12..14]) and (Score.PilotRace = oiMaloc));
  GetByName('PirateWin5Peleng').SetActive((GameEndReason in [12..14]) and (Score.PilotRace = oiPeleng));
  GetByName('PirateWin5People').SetActive((GameEndReason in [12..14]) and (Score.PilotRace = oiHuman));
  GetByName('PirateWin5Fei').SetActive((GameEndReason in [12..14]) and (Score.PilotRace = oiFeyan));
  GetByName('PirateWin5Gaal').SetActive((GameEndReason in [12..14]) and (Score.PilotRace = oiGaal));
  GetByName('PirateWin6').SetActive(GameEndReason = 15);
  GetByName('PirateWin7').SetActive(GameEndReason = 16);
  GetByName('PirateWin8').SetActive(GameEndReason = 17);
  GetByName('PirateWin').SetActive((GameEndReason > 18) or (CustomWin and (CustomPicture = '')));
  with GetByName('MainPanel') do
  begin
    Control := FirstChild;
    while Control <> nil do
    begin
      if FindTextOffsetW(Control.ControlName,'CustomEnd') = 0 then
        Control.SetActive(Control.ControlName = 'CustomEnd' + CustomPicture);
      Control := Control.NextSibling;
    end;
  end;
  (GetByName('Load') as TGraphButtonGI).SetDisabled(GameEndReason > 4);
  if GameEndReason > 4 then
  begin
    with GetByName('Load') do
    begin
      Position := LocalPosition;
      Size := ClientSize;
      Dec(Position.X,5);
      Dec(Position.Y,5);
      Inc(Size.X,10);
      Inc(Size.Y,10);
    end;
    with GetByName('FrameLoad') do
    begin
      SetPosition(Position);
      SetSize(Size);
    end;
  end;
  with GetByName('PanelText') do
  begin
    TextPanelTop := LocalPosition.Y;
    TextPanelHeight := ClientSize.Y;
  end;
  if GameEndReason > 4 then Text := LookupLocalizedTextByKey(AnsiString('FormGameEnd.WinPirate') + IntToStr(GameEndReason))
  else if GameEndReason = gerTerronConversion then
  begin
    if Galaxy.CoalitionDefeatedTurn <> 0 then Text := LocalizedColorText('FormGameEnd.LossConvertToTerron3')
    else if Galaxy.PirateWinType <> 3 then Text := LocalizedColorText('FormGameEnd.LossConvertToTerron2')
    else
    begin
      if (Galaxy.KellerSeriesResolvedTurn <> 0) or (Galaxy.BlazerSeriesResolvedTurn <> 0) then
        Text := LocalizedColorText('FormGameEnd.LossConvertToTerron')
      else Text := LocalizedColorText('FormGameEnd.LossConvertToTerron1');
    end;
  end
  else if CustomText <> '' then Text := CustomText
  else
  begin
    Text := PickLocalizedTextVariant('FormGameEnd.Loss',Random(100000));
    Event := nil;
    for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
    begin
      if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn < Galaxy.CurrentTurn then Break;
      if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerDeath' then Event := Galaxy.GalaxyEvents[I];
    end;
    if Event <> nil then
    begin
      DeathCause := Event.GetTextData(0);
      if DeathCause = 'PlanetCaptured' then
      begin
        Text := PickLocalizedTextVariant('FormGameEnd.LossInPlanet',Random(100000));
        if (GetPlayer <> nil) and (GetPlayer.CurrentPlanet <> nil) then
        begin
          if (GetPlayer.CurrentPlanet.CustomFaction <> '') and
            (LocalizedColorText('FormGameEnd.LossInPlanet' + GetPlayer.CurrentPlanet.CustomFaction) <> '') then
            Text := PickLocalizedTextVariant('FormGameEnd.LossInPlanet' + GetPlayer.CurrentPlanet.CustomFaction,Random(100000))
          else if (GetPlayer.CurrentPlanet.CurrentStar.Status.CustomFaction <> '') and
            (LocalizedColorText('FormGameEnd.LossInPlanet' + GetPlayer.CurrentPlanet.CurrentStar.Status.CustomFaction) <> '') then
            Text := PickLocalizedTextVariant('FormGameEnd.LossInPlanet' + GetPlayer.CurrentPlanet.CurrentStar.Status.CustomFaction,Random(100000));
          ReplaceTextToken(Text,'<Planet>',GetPlayer.CurrentPlanet.Name,'<color=255,240,100>');
        end
        else ReplaceTextToken(Text,'<Planet>','','');
      end;
      if DeathCause = 'StationDestroyed' then Text := PickLocalizedTextVariant('FormGameEnd.LossInShip',Random(100000));
      if DeathCause = 'KilledByBeamWeapon' then Text := PickLocalizedTextVariant('FormGameEnd.LossKilledByWeaponHit',Random(100000));
      if DeathCause = 'KilledByMissile' then Text := PickLocalizedTextVariant('FormGameEnd.LossKilledByMissileHit',Random(100000));
      if DeathCause = 'KilledByInterceptor' then Text := PickLocalizedTextVariant('FormGameEnd.LossKilledByInterceptorHit',Random(100000));
      if DeathCause = 'KilledByAsteroid' then Text := PickLocalizedTextVariant('FormGameEnd.LossKilledByAsteroidHit',Random(100000));
      if DeathCause = 'KilledByExplosion' then Text := PickLocalizedTextVariant('FormGameEnd.LossKilledByExplosion',Random(100000));
      if DeathCause = 'KilledBySunDamage' then Text := PickLocalizedTextVariant('FormGameEnd.LossKilledBySunDamage',Random(100000));
    end;
  end;
  if LastLoadedPlayerName = '' then LastLoadedPlayerName := 'GPlayerName='#39;
  ReplaceTextToken(Text,'<Player>',LastLoadedPlayerName,'<color=255,240,100>');
  ReplaceTextToken(Text,'<Date>',FormatGameTurnDate(Galaxy.CurrentTurn),'<color=255,240,100>');
  if FindTextOffsetW(Text,'<Money>') >= 0 then
    if LastMedicalPolicyTicks = 0 then ReplaceTextToken(Text,'<Money>','10.000','<color=255,240,100>')
    else
    begin
      ReplaceTextToken(Text,'<Money>','20.000','<color=255,240,100>');
      TryUnlockAchievement('INSURANCE');
    end;
  ReplaceTextToken(Text,'<br>',#13#10,'');
  with GetByName('GBText') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    if (ExtraScreenWidth > 127) or (ExtraScreenHeight > 127) then
      RenderLabelTextToBuffer(GraphBuf,ClientSize.X,1,0,Text,'Font.2Big',$FFFFF3D2,$FF373737,$FFDBDA9C)
    else RenderLabelTextToBuffer(GraphBuf,ClientSize.X,1,0,Text,'Font.2Intro',$FFFFF3D2,$FF373737,$FFDBDA9C);
    SetSize(Classes.Point(ClientSize.X,GraphBuf.Height));
    SetPosition(Classes.Point(LocalPosition.X,TextPanelHeight));
  end;
  if TextScrollTimer <> nil then
  begin
    CancelCallbackTimer(TextScrollTimer);
    TextScrollTimer := nil;
  end;
  TextScrollTimer := ScheduleCallbackTimer(20,20,ScrollEndingText);
end;
{ @end $5E60E0 }

{ @routine $5E7B8C TfGameEnd_OnClose }
procedure TfGameEnd.OnClose;
begin
  if TextScrollTimer <> nil then
  begin
    CancelCallbackTimer(TextScrollTimer);
    TextScrollTimer := nil;
  end;
  with GetByName('GBText') as TGraphBufGI do GraphBuf.Clear;
  if BackgroundTimer <> nil then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := nil;
  end;
end;
{ @end $5E7B8C }

{ @routine $5E7C28 TfGameEnd_ScrollBackground }
procedure TfGameEnd.ScrollBackground(Timer: PCallbackTimerGI; UserData: Integer);
var Offset: Integer;
begin
  Inc(BackgroundScrollOffset);
  with GetByName('ImageFon1') do
  begin
    Offset := BackgroundScrollOffset mod ClientSize.X;
    SetPosition(Classes.Point(0 - Offset,LocalPosition.Y));
  end;
  with GetByName('ImageFon2') do SetPosition(Classes.Point(ClientSize.X - Offset,LocalPosition.Y));
end;
{ @end $5E7C28 }

{ @routine $5E7CEC TfGameEnd_ScrollEndingText }
procedure TfGameEnd.ScrollEndingText(Timer: PCallbackTimerGI; UserData: Integer);
var Limit: Single;
begin
  with GetByName('GBText') as TGraphBufGI do
  begin
    SetPosition(AddPoints(LocalPosition,Classes.Point(0,-1)));
    Limit := (TextPanelTop + TextPanelHeight) * 0.45 - ClientSize.Y * 0.5;
    if Limit < 0 then Limit := 2 * Limit;
    if LocalPosition.Y < Limit then
      if TextScrollTimer <> nil then
      begin
        CancelCallbackTimer(TextScrollTimer);
        TextScrollTimer := nil;
      end;
  end;
end;
{ @end $5E7CEC }

{ @routine $5E7DF4 TfGameEnd_ContinueClicked }
procedure TfGameEnd.ContinueClicked(Sender: TObjectGI);
begin
  if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
  Galaxy := nil;
  if GameEndReason <= 4 then RequestedScreenId := screenScores
  else
  begin
    AboutScreen.ReturnToScores := True;
    RequestedScreenId := screenAbout;
  end;
  RequestClose(1);
  BreakUiMessage;
end;
{ @end $5E7DF4 }

{ @routine $5E7E98 TfGameEnd_LoadClicked }
procedure TfGameEnd.LoadClicked(Sender: TObjectGI);
begin
  ShowControlHelp(nil,False);
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True,0);
  SetCursorActive(True);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveManagerMode := smmLoad;
  RequestedScreenId := screenSaveManager;
  RequestClose(1);
end;
{ @end $5E7E98 }

{ @routine $5E7F08 TfGameEnd_ShowControlHelp }
procedure TfGameEnd.ShowControlHelp(Sender: TObjectGI; Show: Boolean);
var LabelControl: TLabelGI;
begin
  LabelControl := GetByName('LabelHelp') as TLabelGI;
  if (Sender = nil) or (Sender.HelpText = '') or Sender.IsOccludedAtPoint(GetCursorPoint) then Show := False;
  LabelControl.SetActive(Show);
  if Sender <> nil then LabelControl.SetText(Sender.HelpText);
end;
{ @end $5E7F08 }

{ @routine $5E7FA0 TfGameEnd_MainPanelKeyDown }
procedure TfGameEnd.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
    if Key = VK_F3 then LoadClicked(nil)
    else if (Key = VK_ESCAPE) or (Key = VK_RETURN) then ContinueClicked(nil);
end;
{ @end $5E7FA0 }

{ @routine $5E8008 TfGameEnd_SelectMusic }
procedure TfGameEnd.SelectMusic;
var I: Integer; Event: TGalaxyEvent;
begin
  if GameEndReason > 4 then
  begin
    MusicManager.PlayCategory('Win');
    Exit;
  end;
  if (GameEndReason <> gerDefault) or (Galaxy = nil) then
  begin
    MusicManager.PlayCategory('Loss');
    Exit;
  end;
  if GameEndReason = gerDefault then
      for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
      begin
        Event := Galaxy.GalaxyEvents[I];
        if Galaxy.CurrentTurn > Event.Turn then Break;
        if Event.EventType = 'CustomLose' then
        begin
          MusicManager.PlayCategory('Loss');
          Exit;
        end;
        if Event.EventType = 'CustomWin' then
        begin
          MusicManager.PlayCategory('Win');
          Exit;
        end;
      end;
  MusicManager.PlayCategory('Loss');
end;
{ @end $5E8008 }

end.
