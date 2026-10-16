unit fGameLoad;

interface

uses EC_Thread, GI_MessageLoop, fPanelLoad;

type
  TThreadGameLoad = class(TThreadEC) // @size 0x30
  public
    Succeeded: Boolean; // @offset 0x2C
    procedure Execute; override; // @addr 0x00532044
  end;

  TfGameLoad = class(TMessageLoopGI) // @size 0xEC
  public
    LoadThread: TThreadGameLoad; // @offset 0xD0
    ProgressTimer: TCallbackTimerIdGI; // @offset 0xD4
    AssetPreloadStarted: Boolean; // @offset 0xD8
    TargetProgress: Single; // @offset 0xDC
    DisplayedProgress: Single; // @offset 0xE0
    LoadingComplete: Boolean; // @offset 0xE4
    LoadPanel: TfPanelLoad; // @offset 0xE8
    constructor Create; // @addr 0x0053209C
    destructor Destroy; override; // @addr 0x005320E4
    procedure InitializeLayout; override; // @addr 0x00532120
    procedure OnOpen; override; // @addr 0x00532210
    procedure OnClose; override; // @addr 0x00532314
    procedure SelectMusic; override; // @addr 0x00532B24
    function IsLoading: Boolean; // @addr $532720
    procedure UpdateLoadingProgress(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00532744
  end;

implementation

uses aGalaxyStruct, SysUtils, Classes, Windows, Math, GR_Main, GR_Music, Globals, GlobalsV, GI_Main,
  EC_BlockPar, aConst, aMyFunction, aPlayer, aGalaxy, aSaveLoad,
  fLoad, fStarMap;

{ @routine $532044 TThreadGameLoad_Execute }
procedure TThreadGameLoad.Execute;
begin
  Succeeded := False;
  Succeeded := LoadGameFromFile(PendingLoadFileName);
end;
{ @end $532044 }

{ @routine $53209C TfGameLoad_Create }
constructor TfGameLoad.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $53209C }

{ @routine $5320E4 TfGameLoad_Destroy }
destructor TfGameLoad.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $5320E4 }

{ @routine $532120 TfGameLoad_InitializeLayout }
procedure TfGameLoad.InitializeLayout;
begin
  inherited;
  AppendLogTextThreadSafe('fGameLoad... ');
  ViewportRect := Classes.Rect(ExtraScreenWidth div 2,ExtraScreenHeight div 2,ViewportRect.Left + ExtraScreenWidth div 2,ViewportRect.Top + ExtraScreenHeight div 2);
  GetByName('PanelLoad').Parent.SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
  AppendLogLineThreadSafe('ok');
  LoadPanel.InitializeLayout(Self);
end;
{ @end $532120 }

{ @routine $532210 TfGameLoad_OnOpen }
procedure TfGameLoad.OnOpen;
begin
  LoadPanel.OnOpen;
  LoadPanel.Show;
  if MusicManager.CategoryOverride = '' then MusicManager.RequestFadeOut;
  TargetProgress := 0;
  DisplayedProgress := 0;
  LoadingComplete := False;
  if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  if (Galaxy <> nil) and not Galaxy.Destroying then Galaxy.Free;
  Galaxy := nil;
  AssetPreloadStarted := False;
  LoadThread := TThreadGameLoad.Create;
  LoadThread.SetPriority(priority_below_normal);
  LoadThread.Start;
  ProgressTimer := ScheduleCallbackTimer(20,20,UpdateLoadingProgress);
  LoadPanel.SetProgress(0);
end;
{ @end $532210 }

{ @routine $532314 TfGameLoad_OnClose }
procedure TfGameLoad.OnClose;
var Category: WideString;
begin
  LoadPanel.OnClose;
  if LoadThread <> nil then
  begin
    LoadThread.Free;
    LoadThread := nil;
  end;
  if ProgressTimer <> 0 then
  begin
    CancelCallbackTimer(ProgressTimer);
    ProgressTimer := 0;
  end;
  if MusicManager.CategoryOverride = '' then
  begin
    if GetPlayer = nil then MusicManager.PlayCategory('Base')
    else if GetPlayer.IsOnPlanet then
    begin
      if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
      begin
        if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.PiratePlanetMain');
      end
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
    end
    else if GetPlayer.IsDockedToShip then
    begin
      if GetPlayer.DockedTo.TypeId in [station_ranger_center..station_custom] then
      begin
        Category := GetPlayer.DockedTo.TypeNameOverrideKey;
        if (Category <> '') and (MainDataConfig.GetBlock('Music').CountBlocks(Category) > 0) then
          MusicManager.PlayCategory(GetPlayer.DockedTo.TypeNameOverrideKey)
        else MusicManager.PlayCategory(GetPlayer.DockedTo.GetTypeNameKey);
      end
      else
      begin
          // Retain the native CurrentPlanet lookup in this non-station docking branch.
        if GetPlayer.CurrentPlanet.OwnerId = owner_pirate then
          MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
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
    SysUtils.Sleep(100);
    MusicManager.RequestFadeOut;
  end;
  Galaxy.CheckIntegrityChecksumAndSetStatus(555);
end;
{ @end $532314 }

{ @routine $532720 TfGameLoad_IsLoading }
function TfGameLoad.IsLoading: Boolean;
begin
  if (LoadThread <> nil) and LoadThread.IsRunning then Result := True
  else Result := False;
end;
{ @end $532720 }

{ @routine $532744 TfGameLoad_UpdateLoadingProgress }
procedure TfGameLoad.UpdateLoadingProgress(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Loads: TList; Block: TBlockParEC;
begin
  if LoadThread.IsRunning then
  begin
    if (LoadingFilmCount < 0) and (ActiveLoadBuffer <> nil) then
      TargetProgress := ActiveLoadBuffer.Position / ActiveLoadBuffer.DataSize * 0.5;
  end
  else if not LoadingComplete then
  begin
    if not LoadThread.Succeeded then
    begin
      if SelectedMods <> LoadedSaveModSet then
      begin
        if ShowMessageBoxGI(GetInnermostScreenLoop,LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.QueryReloadMods'),messagebox_ok or messagebox_cancel or messagebox_error) = messagebox_result_ok then
        begin
          Block := TBlockParEC.Create;
          Block.AddParam('CurrentMod',LoadedSaveModSet);
          Block.SaveTextFile(ModSelectionConfigPath,True,False);
          Block.Free;
          RequestedScreenId := screen_none;
          PostLoadScreenId := screen_save_loading;
          ReloadModsRequested := True;
          RequestClose(1);
          Exit;
        end;
      end
      else ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.LoadError'),messagebox_ok or messagebox_error);
      RequestedScreenId := screen_main_menu;
      ApplyEditableSaveOnLoad := False;
      RequestClose(1);
      Exit;
    end;
    if not AssetPreloadStarted then
    begin
      Loads := TList.Create;
      StarMapScreen.ResumeMode := map_resume_orders;
      if ScreenUsesCompositeLoadAssets(RequestedScreenId) then QueueSpaceLoadingAssets(Loads,RootUiObject);
      if Loads.Count < 1 then
      begin
        Loads.Free;
        TargetProgress := 1;
        LoadingComplete := True;
        AssetPreloadStarted := True;
      end
      else
      begin
        CacheLoader.SetPendingLoads(Loads,True);
        AssetPreloadStarted := True;
      end;
    end
    else if not CacheLoader.IsRunning then
    begin
      LoadingComplete := True;
      TargetProgress := 1;
    end
    else TargetProgress := CacheLoader.CompletedLoadCount / CacheLoader.TotalLoadCount * 0.5 + 0.5;
  end;
  if DisplayedProgress < TargetProgress then
  begin
    DisplayedProgress := Min(0.005 + DisplayedProgress,TargetProgress);
    LoadPanel.SetProgress(DisplayedProgress);
  end;
  if LoadingComplete and (DisplayedProgress >= 0.999) then RequestClose(1);
end;
{ @end $532744 }

{ @routine $532B24 TfGameLoad_SelectMusic }
procedure TfGameLoad.SelectMusic;
begin

end;
{ @end $532B24 }

end.
