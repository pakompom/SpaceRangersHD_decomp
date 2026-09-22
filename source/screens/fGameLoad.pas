unit fGameLoad;
// Unit bracket (inferred): .text 0x00661994..0x00662679; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Thread, GI_MessageLoop, fPanelLoad;

type
  TThreadGameLoad = class(TThreadEC) // @size 0x30
  public
    Succeeded: Boolean; // @offset 0x2C
    procedure Execute; override; // @addr 0x661A8C
  end;

  TfGameLoad = class(TMessageLoopGI) // @size 0xEC
  public
    LoadThread: TThreadGameLoad; // @offset 0xD0
    ProgressTimer: PCallbackTimerGI; // @offset 0xD4
    AssetPreloadStarted: Boolean; // @offset 0xD8
    TargetProgress: Single; // @offset 0xDC
    DisplayedProgress: Single; // @offset 0xE0
    LoadingComplete: Boolean; // @offset 0xE4
    LoadPanel: TfPanelLoad; // @offset 0xE8
    constructor Create; // @addr 0x661AF0
    destructor Destroy; override; // @addr 0x661B48
    procedure InitializeLayout; override; // @addr 0x661BA0
    procedure OnOpen; override; // @addr 0x661CA8
    procedure OnClose; override; // @addr 0x661DD8
    procedure SelectMusic; override; // @addr 0x662670
    function IsLoading: Boolean; // @addr $6621FC
    procedure UpdateLoadingProgress(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x662234
  end;

implementation

uses aGalaxyStruct, SysUtils, Classes, Windows, Math, GR_Main, GR_Music, Globals, GlobalsV, GI_Main,
  EC_BlockPar, aConst, aMyFunction, aPlayer, aGalaxy, aSaveLoad,
  fLoad, fStarMap;

{ @routine $661A8C TThreadGameLoad_Execute }
procedure TThreadGameLoad.Execute;
begin
  Succeeded := False;
  Succeeded := LoadGameFromFile(PendingLoadFileName);
end;
{ @end $661A8C }

{ @routine $661AF0 TfGameLoad_Create }
constructor TfGameLoad.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $661AF0 }

{ @routine $661B48 TfGameLoad_Destroy }
destructor TfGameLoad.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $661B48 }

{ @routine $661BA0 TfGameLoad_InitializeLayout }
procedure TfGameLoad.InitializeLayout;
begin
  inherited;
  AppendLogTextThreadSafe('fGameLoad... ');
  ViewportRect := Classes.Rect(ExtraScreenWidth div 2,ExtraScreenHeight div 2,ViewportRect.Left + ExtraScreenWidth div 2,ViewportRect.Top + ExtraScreenHeight div 2);
  GetByName('PanelLoad').Parent.SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
  AppendLogLineThreadSafe('ok');
  LoadPanel.InitializeLayout(Self);
end;
{ @end $661BA0 }

{ @routine $661CA8 TfGameLoad_OnOpen }
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
  LoadThread.SetPriority(2);
  LoadThread.Start;
  ProgressTimer := ScheduleCallbackTimer(20,20,UpdateLoadingProgress);
  LoadPanel.SetProgress(0);
end;
{ @end $661CA8 }

{ @routine $661DD8 TfGameLoad_OnClose }
procedure TfGameLoad.OnClose;
var Category: WideString;
begin
  LoadPanel.OnClose;
  if LoadThread <> nil then
  begin
    LoadThread.Free;
    LoadThread := nil;
  end;
  if ProgressTimer <> nil then
  begin
    CancelCallbackTimer(ProgressTimer);
    ProgressTimer := nil;
  end;
  if MusicManager.CategoryOverride = '' then
  begin
    if GetPlayer = nil then MusicManager.PlayCategory('Base')
    else if GetPlayer.IsOnPlanet then
      begin
        if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
        begin
          if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
          else MusicManager.PlayCategory('Nation.PiratePlanetMain');
        end
        else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
      end
      else if GetPlayer.IsDockedToShip then
      begin
        if GetPlayer.DockedTo.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)] then
        begin
          Category := GetPlayer.DockedTo.TypeNameOverrideKey;
          if (Category <> '') and (MainDataConfig.GetBlock('Music').CountBlocks(Category) > 0) then
            MusicManager.PlayCategory(GetPlayer.DockedTo.TypeNameOverrideKey)
          else MusicManager.PlayCategory(GetPlayer.DockedTo.GetTypeNameKey);
        end
        else
        begin
          // Retain the native CurrentPlanet lookup in this non-station docking branch.
          if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
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
{ @end $661DD8 }

{ @routine $6621FC TfGameLoad_IsLoading }
function TfGameLoad.IsLoading: Boolean;
begin
  if (LoadThread <> nil) and LoadThread.IsRunning then Result := True
  else Result := False;
end;
{ @end $6621FC }

{ @routine $662234 TfGameLoad_UpdateLoadingProgress }
procedure TfGameLoad.UpdateLoadingProgress(Timer: PCallbackTimerGI; UserData: Integer);
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
        if ShowMessageBoxGI(GetInnermostScreenLoop,LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.QueryReloadMods'),mbgOK or mbgCancel or mbgError) = mbgResultOK then
        begin
          Block := TBlockParEC.Create;
          Block.AddParam('CurrentMod',LoadedSaveModSet);
          Block.SaveTextFile(ModSelectionConfigPath,True,False);
          Block.Free;
          RequestedScreenId := screenNone;
          PostLoadScreenId := screenGameLoad;
          ReloadModsRequested := True;
          RequestClose(1);
          Exit;
        end;
      end
      else ShowMessageBoxGI(Self,LanguageDataConfig.GetParamByPathOrMarker('FormSaveManager.LoadError'),mbgOK or mbgError);
      RequestedScreenId := screenMainMenu;
      ApplyEditableSaveOnLoad := False;
      RequestClose(1);
      Exit;
    end;
    if not AssetPreloadStarted then
    begin
      Loads := TList.Create;
      StarMapScreen.ResumeMode := smrOrders;
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
{ @end $662234 }

{ @routine $662670 TfGameLoad_SelectMusic }
procedure TfGameLoad.SelectMusic;
begin

end;
{ @end $662670 }

end.
