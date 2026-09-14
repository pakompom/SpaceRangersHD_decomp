unit fGameMenu;
// Unit bracket (inferred): .text 0x0053D544..0x0053E3BF; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TfGameMenu = class(TMessageLoopGI) // @size 0xD0
  public


    procedure ResumeClicked(Sender: TObjectGI); // @addr $53DA0C
    procedure SaveClicked(Sender: TObjectGI); // @addr $53DA38
    procedure LoadClicked(Sender: TObjectGI); // @addr $53DB24
    procedure SettingsClicked(Sender: TObjectGI); // @addr $53DB60
    procedure HelpClicked(Sender: TObjectGI); // @addr $53DB94
    procedure ExitClicked(Sender: TObjectGI); // @addr $53DC64
    procedure AchievementsClicked(Sender: TObjectGI); // @addr $53DD90
    procedure BackgroundMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $53DDC4 @ida "void __userpurge $name(TfGameMenu *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $53DFF8

    procedure OnOpen; override; // @addr 0x53D978
    procedure OnClose; override; // @addr 0x53D9EC
    procedure SelectMusic; override; // @addr 0x53E100
    procedure InitializeLayout; override; // @addr 0x53D5DC
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x53E0B4
  end;

implementation

uses aGalaxyStruct, Classes, Windows, ShellAPI, GR_Main, GR_Music, Globals, GlobalsV,
  GI_Main, GI_GraphBuf, GI_GraphButton, GI_Image, aConst, aMyFunction,
  aPlayer, aGalaxy, fLoad, fSaveManager, fStarMap;

{ @routine $53D5DC TfGameMenu_InitializeLayout }
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
{ @end $53D5DC }

{ @routine $53D978 TfGameMenu_OnOpen }
procedure TfGameMenu.OnOpen;
begin
  if AuxRenderBuffer.GetPixels = nil then CaptureScreenBackground(True,0);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  ContentPanel.KeyDownCallback := MainPanelKeyDown;
end;
{ @end $53D978 }

{ @routine $53D9EC TfGameMenu_OnClose }
procedure TfGameMenu.OnClose;
begin
  if AuxRenderBuffer <> nil then AuxRenderBuffer.Clear;
end;
{ @end $53D9EC }

{ @routine $53DA0C TfGameMenu_ResumeClicked }
procedure TfGameMenu.ResumeClicked(Sender: TObjectGI);
begin
  RequestedScreenId := GameMenuReturnScreenId;
  RequestClose(1);
end;
{ @end $53DA0C }

{ @routine $53DA38 TfGameMenu_SaveClicked }
procedure TfGameMenu.SaveClicked(Sender: TObjectGI);
begin
  if Galaxy.IronWill then ShowMessageBoxGI(Self,LocalizedColorText('FormGameSet2.IronWillText'),mbgCancel or mbgUnused04)
  else if Galaxy.SpecialSimulationMode = 0 then
  begin
    SaveManagerReturnScreenId := GameMenuReturnScreenId;
    SaveManagerMode := smmSave;
    RequestedScreenId := screenSaveManager;
    RequestClose(1);
  end;
end;
{ @end $53DA38 }

{ @routine $53DB24 TfGameMenu_LoadClicked }
procedure TfGameMenu.LoadClicked(Sender: TObjectGI);
begin
  SaveManagerReturnScreenId := GameMenuReturnScreenId;
  SaveManagerMode := smmLoad;
  RequestedScreenId := screenSaveManager;
  RequestClose(1);
end;
{ @end $53DB24 }

{ @routine $53DB60 TfGameMenu_SettingsClicked }
procedure TfGameMenu.SettingsClicked(Sender: TObjectGI);
begin
  SettingsReturnScreenId := GameMenuReturnScreenId;
  RequestedScreenId := screenSettings;
  RequestClose(1);
end;
{ @end $53DB60 }

{ @routine $53DB94 TfGameMenu_HelpClicked }
procedure TfGameMenu.HelpClicked(Sender: TObjectGI);
begin
  ShowWindow(MainWindowHandle,SW_MINIMIZE);
  // Native $53DC28 and $53DC5C are the empty and 'open' PAnsiChar literals.
  ShellExecuteA(0,'open',PAnsiChar(AnsiString(LocalizedText('FormGameMenu.HelpFile'))),'','',SW_SHOWNORMAL);
end;
{ @end $53DB94 }

{ @routine $53DC64 TfGameMenu_ExitClicked }
procedure TfGameMenu.ExitClicked(Sender: TObjectGI);
begin
  if ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormGameMenu.QExit'),mbgOK or mbgCancel or mbgQuestion) = mbgResultOK then
  begin
    if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
    MemorySnapshotBuffer := nil;
    MemorySnapshotActive := False;
    if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
    Galaxy := nil;
    EvictRuinsAndGovernmentCaches;
    EvictStarAndBackgroundCaches;
    ReleaseAllTextureSurfaces;
    ScreenLoadMode := 4;
    PostLoadScreenId := screenMainMenu;
    RequestedScreenId := screenLoad;
    RequestClose(1);
  end;
end;
{ @end $53DC64 }

{ @routine $53DD90 TfGameMenu_AchievementsClicked }
procedure TfGameMenu.AchievementsClicked(Sender: TObjectGI);
begin
  AchievementsReturnScreenId := GameMenuReturnScreenId;
  RequestedScreenId := screenAchievements;
  RequestClose(1);
end;
{ @end $53DD90 }

{ @routine $53DDC4 TfGameMenu_BackgroundMouseUp }
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
{ @end $53DDC4 }

{ @routine $53DFF8 TfGameMenu_MainPanelKeyDown }
procedure TfGameMenu.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) then
    if Key = VK_ESCAPE then ResumeClicked(nil)
    else if (Key = Ord('S')) or (Key = VK_F2) then SaveClicked(nil)
    else if (Key = Ord('L')) or (Key = VK_F3) then LoadClicked(nil)
    else if Key = Ord('C') then SettingsClicked(nil)
    else if Key = Ord('E') then ExitClicked(nil)
    else if Key = Ord('H') then HelpClicked(nil);
end;
{ @end $53DFF8 }

{ @routine $53E0B4 TfGameMenu_ExecuteUiCode }
procedure TfGameMenu.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not ExitScreenLoop then
  begin
    Galaxy.CheckIntegrityChecksum(10013);
    ExecuteGameplayUiCode(Block,Key);
    Galaxy.PrimeIntegrityChecksum(20013);
  end;
end;
{ @end $53E0B4 }

{ @routine $53E100 TfGameMenu_SelectMusic }
procedure TfGameMenu.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.RuinsMode <> 0 then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
    begin
      if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
      begin
        if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.CurrentPlanet.RaceId)) and $7F].InternalName + 'Pirate')
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
      if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase),Ord(rstDominion)] then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.DockedTo.PilotRace)) and $7F].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[Integer(RaceToOwner(GetPlayer.DockedTo.PilotRace)) and $7F].InternalName);
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
{ @end $53E100 }

end.
