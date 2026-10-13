unit fJump;

interface

uses GI_MessageLoop, fPanelLoad;

type
  TfJump = class(TMessageLoopGI) // @size 0xEC
  public
    TransitionTimer: TCallbackTimerIdGI; // @offset 0xD0
    LoadingStarted: Boolean; // @offset $D4
    NoPendingLoads: Boolean; // @offset $D5
    Progress: Single; // @offset $D8
    LoadPanel: TfPanelLoad; // @offset 0xDC
    MovieStartTick: Cardinal; // @offset 0xE0
    MovieTimer: TCallbackTimerIdGI; // @offset 0xE4
    RestoreOrdersOnArrival: Boolean; // @offset $E8

    constructor Create; // @addr 0x005312E8
    destructor Destroy; override; // @addr 0x00531330
    procedure OnOpen; override; // @addr 0x005314CC
    procedure OnClose; override; // @addr 0x0053189C
    procedure SelectMusic; override; // @addr 0x00531F48
    procedure InitializeLayout; override; // @addr 0x0053136C
    procedure AdvanceTravel(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $53190C
    procedure AdvanceLoading(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $531C08
    procedure AdvanceMovie(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $531E64
    function StopMovie: Boolean; // @addr $531EC4
  end;

implementation

uses aGalaxyStruct, SysUtils, Classes, Types, Math, Windows, MMSystem, Globals, GlobalsV, GR_Main,
  GR_DX, GR_Music, GI_XviD, EC_Str, aPlayer, aShip, aGalaxy, aRuins, aScript,
  aItem, ThreadCalc, aCalc, fLoad, fStarMap, fRuinsTalk;

{ @routine $5312E8 TfJump_Create }
constructor TfJump.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $5312E8 }

{ @routine $531330 TfJump_Destroy }
destructor TfJump.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $531330 }

{ @routine $53136C TfJump_InitializeLayout }
procedure TfJump.InitializeLayout;
begin
  inherited InitializeLayout;
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fJump... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('Film').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  end;
  AppendLogLineThreadSafe('ok');
  RestoreOrdersOnArrival := False;
end;
{ @end $53136C }

{ @routine $5314CC TfJump_OnOpen }
procedure TfJump.OnOpen;
var
  MovieConfig, MoviePath: WideString;
  // @nested $531460 BeginTravel
  procedure BeginTravel; cdecl; // @addr $531460 @ida "void __cdecl $name(void *ParentFrame);"
  begin
    if TransitionTimer <> 0 then
    begin
      CancelCallbackTimer(TransitionTimer);
      TransitionTimer := 0;
    end;
    TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceTravel);
    LoadPanel.SetProgress(0);
    LoadPanel.Show;
  end;
begin
  EvictStarAndBackgroundCaches;
  ReleaseAllTextureSurfaces;
  if not GetPlayer.IsDockedToShip then
  begin
    Self.ShowCursor := True;
    LoadPanel.OnOpen;
    RunGlobalScriptsForContext(GetPlayer.CurrentStar, 2);
    LoadingStarted := False;
    NoPendingLoads := False;
    if GetPlayer.InHyperspace or GetPlayer.IsDockedToShip then
      TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceTravel)
    else AdvanceLoading(0, 0);
    Progress := 0;
    LoadPanel.SetProgress(0);
    LoadPanel.Show;
    Present;
  end
  else if GetPlayer.IsDockedToShip then
  begin
    Self.ShowCursor := False;
    LoadPanel.OnOpen;
    RunGlobalScriptsForContext(GetPlayer.CurrentStar, 2);
    LoadingStarted := False;
    NoPendingLoads := False;
    Progress := 0;
    Present;
    if SkipVideo then
    begin
      BeginTravel;
      Exit;
    end;
    LoadPanel.SetProgress(1);
    LoadPanel.Hide;
    if GetPlayer.DockedTo.TypeId = rstMilitaryBase then
      MovieConfig := LanguageDataConfig.GetParamByPathOrMarker('FormRuins.WB.HyperJumpVideo')
    else if GetPlayer.DockedTo.TypeId = rstDominion then
      MovieConfig := LanguageDataConfig.GetParamByPathOrMarker('FormRuins.CB.HyperJumpVideo')
    else
    begin
      BeginTravel;
      Exit;
    end;
    MoviePath := ExtractDelimitedPartW(MovieConfig, 0, ',');
    with GetByName('Film') as TxvidGI do
    begin
      SetActive(True);
      if ImageOpen(MoviePath, True) then
      begin
        if MusicEnabled and (CountDelimitedPartsW(MovieConfig, ',') > 1) then
        begin
          MusicManager.StopImmediately;
          while MusicManager.IsPlaying do SysUtils.Sleep(1);
          MusicManager.PlayCategory(ExtractDelimitedPartW(MovieConfig, 1, ','));
          while not MusicManager.IsPlaying do SysUtils.Sleep(1);
        end;
        MovieStartTick := timeGetTime;
        if MovieTimer <> 0 then
        begin
          CancelCallbackTimer(MovieTimer);
          MovieTimer := 0;
        end;
        MovieTimer := ScheduleCallbackTimer(5, 5, AdvanceMovie);
      end
      else
      begin
        SetActive(False);
        BeginTravel;
      end;
    end;
  end;
end;
{ @end $5314CC }

{ @routine $53189C TfJump_OnClose }
procedure TfJump.OnClose;
begin
  StopMovie;
  with GetByName('Film') as TxvidGI do
  begin
    ImageClose;
    SetActive(False);
  end;
  LoadPanel.OnClose;
  if TransitionTimer <> 0 then
  begin
    CancelCallbackTimer(TransitionTimer);
    TransitionTimer := 0;
  end;
end;
{ @end $53189C }

{ @routine $53190C TfJump_AdvanceTravel }
procedure TfJump.AdvanceTravel(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  PreviousStar: TStar;
begin
  if (GetPlayer = nil) or (GetPlayer.GetHull.HullPoints <= 0) then
  begin
    if GetPlayer <> nil then Galaxy.ScoreScreenDismissed := 1;
    while GetPlayer <> nil do SysUtils.Sleep(1);
    RequestedScreenId := screenGameEnd;
    RequestClose(1);
    Exit;
  end;
  Progress := Progress + 0.008;
  if Progress > 0.49 then Progress := 0.5;
  LoadPanel.SetProgress(Progress);
  if IsTurnCalculationRunningUI or (TurnCalculationPhase in [tcpGalaxyRunning, tcpPlayerStarRunning]) then Exit;
  if TurnCalculationPhase = tcpGalaxyFinished then
  begin
    QueuePlayerStarTurnCalculation;
    Exit;
  end;
  if GetPlayer.IsDockedToShip then
  begin
    if (GetPlayer.DockedTo.Order <> soTeleport) and
      (((GetPlayer.DockedTo as TRuins).FlyToStar = GetPlayer.DockedTo.CurrentStar) or ((GetPlayer.DockedTo as TRuins).FlyToStar = nil)) then
    begin
      QueueGalaxyTurnCalculation;
      AdvanceLoading(0, 0);
      Exit;
    end;
    Galaxy.ClearJumpGates;
    PreviousStar := PlayerStar;
    PlayerStar := GetPlayer.CurrentStar;
    PlayerStar.RebuildShipMovementPaths;
    PreviousStar.RebuildShipMovementPaths;
    if (Cardinal(GetPlayer.OrderStateData) and $FFFF) = 1 then
    begin
      PruneExpiredPersistentPlayerMessages;
      RunGlobalScriptsForContext(GetPlayer.CurrentStar, 3);
    end;
    Galaxy.GenerateSpaceBackground(GetPlayer.CurrentStar.BackgroundImage);
    QueueGalaxyTurnCalculation;
    Present;
  end
  else
  begin
    if not (GetPlayer.Order in [soJump, soJumpHole, soTeleport]) or
      ((GetPlayer.Order = soJumpHole) and (GetPlayer.OrderStateData = HoleExitOrderState)) then
    begin
      QueueGalaxyTurnCalculation;
      StarMapScreen.SetMapCenterManually(TruncatePointF(GetPlayer.Position));
      StarMapScreen.ResumeMode := smrTurnFilm;
      AdvanceLoading(0, 0);
      Exit;
    end;
    Galaxy.ClearJumpGates;
    PreviousStar := PlayerStar;
    PlayerStar := GetPlayer.CurrentStar;
    PlayerStar.RebuildShipMovementPaths;
    PreviousStar.RebuildShipMovementPaths;
    if (Cardinal(GetPlayer.OrderStateData) and $FFFF) = 1 then
    begin
      PruneExpiredPersistentPlayerMessages;
      RunGlobalScriptsForContext(GetPlayer.CurrentStar, 3);
    end;
    Galaxy.GenerateSpaceBackground(GetPlayer.CurrentStar.BackgroundImage);
    QueueGalaxyTurnCalculation;
    Present;
  end;
end;
{ @end $53190C }

{ @routine $531C08 TfJump_AdvanceLoading }
procedure TfJump.AdvanceLoading(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var
  Loads: TList;
begin
  if not LoadingStarted then
  begin
    LoadingStarted := True;
    if TransitionTimer <> 0 then
    begin
      CancelCallbackTimer(TransitionTimer);
      TransitionTimer := 0;
    end;
    Loads := TList.Create;
    QueueSpaceLoadingAssets(Loads, RootUiObject);
    if Loads.Count > 0 then
    begin
      CacheLoader.SetPendingLoads(Loads, True);
      TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceLoading);
    end
    else
    begin
      TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceLoading);
      NoPendingLoads := True;
      Loads.Free;
    end;
  end
  else
  begin
    if NoPendingLoads then Progress := Progress + 0.008
    else Progress := Min(Progress + 0.008, CacheLoader.CompletedLoadCount / CacheLoader.TotalLoadCount * 0.5 + 0.5);
    if Progress > 0.99 then Progress := 1;
    LoadPanel.SetProgress(Progress);
    if (NoPendingLoads or not CacheLoader.IsRunning) and (Progress >= 1) then
    begin
      if TransitionTimer <> 0 then
      begin
        CancelCallbackTimer(TransitionTimer);
        TransitionTimer := 0;
      end;
      if GetPlayer.IsDockedToShip then
      begin
        RuinsTalkScreen.ShowArrivalVideo := True;
        RequestedScreenId := screenRuinsTalk;
      end
      else
      begin
        RequestedScreenId := screenStarMap;
        if RestoreOrdersOnArrival then
        begin
          StarMapScreen.ResumeMode := smrOrders;
          SpaceViewPosition := GetPlayer.Position;
          RestoreOrdersOnArrival := False;
        end;
      end;
      RequestClose(1);
    end;
  end;
end;
{ @end $531C08 }

{ @routine $531E64 TfJump_AdvanceMovie }
procedure TfJump.AdvanceMovie(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if (GetByName('Film') as TxvidGI).SetPlaybackTime(timeGetTime - MovieStartTick) then StopMovie;
end;
{ @end $531E64 }

{ @routine $531EC4 TfJump_StopMovie }
function TfJump.StopMovie: Boolean;
begin
  Result := MovieTimer <> 0;
  if MusicEnabled and Result then MusicManager.StopImmediately;
  if MovieTimer <> 0 then
  begin
    CancelCallbackTimer(MovieTimer);
    MovieTimer := 0;
  end;
  InvalidateViewport;
  if TransitionTimer <> 0 then
  begin
    CancelCallbackTimer(TransitionTimer);
    TransitionTimer := 0;
  end;
  TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceTravel);
end;
{ @end $531EC4 }

{ @routine $531F48 TfJump_SelectMusic }
procedure TfJump.SelectMusic;
begin
end;
{ @end $531F48 }

end.
