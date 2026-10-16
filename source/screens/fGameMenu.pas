unit fGameMenu;

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TfGameMenu = class(TMessageLoopGI) // @size 0xD0
  public


    procedure ResumeClicked(Sender: TObjectGI); // @addr $532F78
    procedure SaveClicked(Sender: TObjectGI); // @addr $532F94
    procedure LoadClicked(Sender: TObjectGI); // @addr $533074
    procedure SettingsClicked(Sender: TObjectGI); // @addr $5330A4
    procedure HelpClicked(Sender: TObjectGI); // @addr $5330CC
    procedure ExitClicked(Sender: TObjectGI); // @addr $533190
    procedure AchievementsClicked(Sender: TObjectGI); // @addr $5332B0
    procedure BackgroundMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5332D8
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5334FC

    procedure OnOpen; override; // @addr 0x00532EF8
    procedure OnClose; override; // @addr 0x00532F60
    procedure SelectMusic; override; // @addr 0x005335DC
    procedure InitializeLayout; override; // @addr 0x00532BC0
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x0053359C
  end;

implementation

uses aGalaxyStruct, Classes, Windows, ShellAPI, GR_Main, GR_Music, Globals, GlobalsV,
  GI_Main, GI_GraphBuf, GI_GraphButton, GI_Image, aConst, aMyFunction,
  aPlayer, aGalaxy, fLoad, fSaveManager, fStarMap;

{ @routine $532BC0 TfGameMenu_InitializeLayout }
procedure TfGameMenu.InitializeLayout;
begin
  inherited;
  AppendLogTextThreadSafe('fGameMenu... ');
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('Resume').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
  end;
  AppendLogLineThreadSafe('ok');
  GetByName('MainPanel').LeftButtonUpCallback := BackgroundMouseUp;
  with GetByName('Resume') as TGraphButtonGI do UpCallback := ResumeClicked;
  with GetByName('Save') as TGraphButtonGI do UpCallback := SaveClicked;
  with GetByName('Load') as TGraphButtonGI do UpCallback := LoadClicked;
  with GetByName('Settings') as TGraphButtonGI do UpCallback := SettingsClicked;
  with GetByName('Help') as TGraphButtonGI do UpCallback := HelpClicked;
  with GetByName('Exit') as TGraphButtonGI do UpCallback := ExitClicked;
  with GetByName('Close') as TGraphButtonGI do UpCallback := ResumeClicked;
  with GetByName('Achievements') as TGraphButtonGI do UpCallback := AchievementsClicked;
end;
{ @end $532BC0 }

{ @routine $532EF8 TfGameMenu_OnOpen }
procedure TfGameMenu.OnOpen;
begin
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True,0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  ContentPanel.KeyDownCallback := MainPanelKeyDown;
end;
{ @end $532EF8 }

{ @routine $532F60 TfGameMenu_OnClose }
procedure TfGameMenu.OnClose;
begin
  if AuxRenderBuffer <> nil then AuxRenderBuffer.Clear;
end;
{ @end $532F60 }

{ @routine $532F78 TfGameMenu_ResumeClicked }
procedure TfGameMenu.ResumeClicked(Sender: TObjectGI);
begin
  RequestedScreenId := GameMenuReturnScreenId;
  RequestClose(1);
end;
{ @end $532F78 }

{ @routine $532F94 TfGameMenu_SaveClicked }
procedure TfGameMenu.SaveClicked(Sender: TObjectGI);
begin
  if Galaxy.IronWill then ShowMessageBoxGI(Self,LocalizedColorText('FormGameSet2.IronWillText'),mbgCancel or mbgUnused04)
  else if Galaxy.SpecialSimulationMode = 0 then
  begin
    SaveManagerReturnScreenId := GameMenuReturnScreenId;
    SaveManagerMode := save_dialog_save;
    RequestedScreenId := screen_save_manager;
    RequestClose(1);
  end;
end;
{ @end $532F94 }

{ @routine $533074 TfGameMenu_LoadClicked }
procedure TfGameMenu.LoadClicked(Sender: TObjectGI);
begin
  SaveManagerReturnScreenId := GameMenuReturnScreenId;
  SaveManagerMode := save_dialog_load;
  RequestedScreenId := screen_save_manager;
  RequestClose(1);
end;
{ @end $533074 }

{ @routine $5330A4 TfGameMenu_SettingsClicked }
procedure TfGameMenu.SettingsClicked(Sender: TObjectGI);
begin
  SettingsReturnScreenId := GameMenuReturnScreenId;
  RequestedScreenId := screen_settings;
  RequestClose(1);
end;
{ @end $5330A4 }

{ @routine $5330CC TfGameMenu_HelpClicked }
procedure TfGameMenu.HelpClicked(Sender: TObjectGI);
begin
  ShowWindow(MainWindowHandle,SW_MINIMIZE);
  ShellExecuteA(0,'open',PAnsiChar(AnsiString(LocalizedText('FormGameMenu.HelpFile'))),'','',SW_SHOWNORMAL);
end;
{ @end $5330CC }

{ @routine $533190 TfGameMenu_ExitClicked }
procedure TfGameMenu.ExitClicked(Sender: TObjectGI);
begin
  if ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormGameMenu.QExit'),mbgOK or mbgCancel or mbgQuestion) <> mbgResultOK then Exit;
  if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
  Galaxy := nil;
  EvictRuinsAndGovernmentCaches;
  EvictStarAndBackgroundCaches;
  ReleaseAllTextureSurfaces;
  ScreenLoadMode := 4;
  PostLoadScreenId := screen_main_menu;
  RequestedScreenId := screen_asset_loading;
  RequestClose(1);
end;
{ @end $533190 }

{ @routine $5332B0 TfGameMenu_AchievementsClicked }
procedure TfGameMenu.AchievementsClicked(Sender: TObjectGI);
begin
  AchievementsReturnScreenId := GameMenuReturnScreenId;
  RequestedScreenId := screen_achievements;
  RequestClose(1);
end;
{ @end $5332B0 }

{ @routine $5332D8 TfGameMenu_BackgroundMouseUp }
procedure TfGameMenu.BackgroundMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if not (GetByName('ImageBG') as TImageGI).HitTestPixel(Point) then
    if not (GetByName('Resume') as TGraphButtonGI).ContainsPoint(Point) then
      if not (GetByName('Save') as TGraphButtonGI).ContainsPoint(Point) then
        if not (GetByName('Load') as TGraphButtonGI).ContainsPoint(Point) then
          if not (GetByName('Settings') as TGraphButtonGI).ContainsPoint(Point) then
            if not (GetByName('Help') as TGraphButtonGI).ContainsPoint(Point) then
              if not (GetByName('Exit') as TGraphButtonGI).ContainsPoint(Point) then
                if not (GetByName('Close') as TGraphButtonGI).ContainsPoint(Point) then
                  if not (GetByName('Achievements') as TGraphButtonGI).ContainsPoint(Point) then
                    ResumeClicked(nil);
end;
{ @end $5332D8 }

{ @routine $5334FC TfGameMenu_MainPanelKeyDown }
procedure TfGameMenu.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then Exit;
  if Key = VK_ESCAPE then ResumeClicked(nil)
  else if (Key = Ord('S')) or (Key = VK_F2) then SaveClicked(nil)
  else if (Key = Ord('L')) or (Key = VK_F3) then LoadClicked(nil)
  else if Key = Ord('C') then SettingsClicked(nil)
  else if Key = Ord('E') then ExitClicked(nil)
  else if Key = Ord('H') then HelpClicked(nil);
end;
{ @end $5334FC }

{ @routine $53359C TfGameMenu_ExecuteUiCode }
procedure TfGameMenu.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop then
  begin
    Galaxy.CheckIntegrityChecksum(10013);
    ExecuteGameplayUiCode(Block,Key);
    Galaxy.PrimeIntegrityChecksum(20013);
  end;
end;
{ @end $53359C }

{ @routine $5335DC TfGameMenu_SelectMusic }
procedure TfGameMenu.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.RuinsMode <> 0 then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
    begin
      if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
      begin
        if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.PiratePlanetMain');
      end
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
    end;
  end
  else if GetPlayer.IsDockedToShip then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
    begin
      if GetPlayer.DockedTo.TypeId in [station_pirate_base,station_dominion] then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
    end;
  end
  else if GetPlayer.InNormalSpace then
  begin
    if MusicInSpaceEnabled then
    begin
      if (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0,100) < 20) then
      begin
        StarMapScreen.BattleMusicSelected := True;
        MusicManager.PlayCategory('Destroyer');
      end
      else
      begin
        StarMapScreen.BattleMusicSelected := False;
        MusicManager.PlayCategory('StarMap');
      end;
    end
    else MusicManager.RequestFadeOut;
  end;
end;
{ @end $5335DC }

end.
