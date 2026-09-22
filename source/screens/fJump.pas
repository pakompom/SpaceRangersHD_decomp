unit fJump;
// Unit bracket (inferred): .text 0x006709E8..0x00671829; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, fPanelLoad;

type
  TfJump = class(TMessageLoopGI) // @size 0xEC
  public
    TransitionTimer: PCallbackTimerGI; // @offset 0xD0
    LoadingStarted: Boolean; // @offset $D4
    NoPendingLoads: Boolean; // @offset $D5
    Progress: Single; // @offset $D8
    RestoreOrdersOnArrival: Boolean; // @offset $E8
    LoadPanel: TfPanelLoad; // @offset 0xDC
    MovieStartTick: Cardinal; // @offset 0xE0
    MovieTimer: PCallbackTimerGI; // @offset 0xE4

    constructor Create; // @addr 0x670A7C
    destructor Destroy; override; // @addr 0x670AD4
    procedure OnOpen; override; // @addr 0x670CB8
    procedure OnClose; override; // @addr 0x671098
    procedure SelectMusic; override; // @addr 0x671820
    procedure InitializeLayout; override; // @addr 0x670B2C
    procedure AdvanceTravel(Timer: PCallbackTimerGI; UserData: Integer); // @addr $671120
    procedure AdvanceLoading(Timer: PCallbackTimerGI; UserData: Integer); // @addr $671440
    procedure AdvanceMovie(Timer: PCallbackTimerGI; UserData: Integer); // @addr $671700
    function StopMovie: Boolean; // @addr $67176C
  end;

implementation

uses aGalaxyStruct, SysUtils, Classes, Types, Math, Windows, MMSystem, Globals, GlobalsV, GR_Main,
  GR_DX, GR_Music, GI_XviD, EC_Str, aPlayer, aShip, aGalaxy, aRuins, aScript,
  aItem, ThreadCalc, aCalc, fLoad, fStarMap, fRuinsTalk;

{ @routine $670A7C TfJump_Create }
constructor TfJump.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $670A7C }

{ @routine $670AD4 TfJump_Destroy }
destructor TfJump.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $670AD4 }

{ @routine $670B2C TfJump_InitializeLayout }
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
{ @end $670B2C }

{ @routine $670CB8 TfJump_OnOpen }
procedure TfJump.OnOpen;
var
  MovieConfig, MoviePath: WideString;
  // @nested $670C2C BeginTravel
  procedure BeginTravel; cdecl; // @addr $670C2C @ida "void __cdecl $name(void *ParentFrame);"
  begin
    if TransitionTimer <> nil then
    begin
      CancelCallbackTimer(TransitionTimer);
      TransitionTimer := nil;
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
    SetCursorActive(True);
    LoadPanel.OnOpen;
    RunGlobalScriptsForContext(GetPlayer.CurrentStar, 2);
    LoadingStarted := False;
    NoPendingLoads := False;
    if GetPlayer.InHyperspace or GetPlayer.IsDockedToShip then
      TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceTravel)
    else AdvanceLoading(nil, 0);
    Progress := 0;
    LoadPanel.SetProgress(0);
    LoadPanel.Show;
    Present;
  end
  else if GetPlayer.IsDockedToShip then
  begin
    SetCursorActive(False);
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
        if MovieTimer <> nil then
        begin
          CancelCallbackTimer(MovieTimer);
          MovieTimer := nil;
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
{ @end $670CB8 }

{ @routine $671098 TfJump_OnClose }
procedure TfJump.OnClose;
begin
  StopMovie;
  with GetByName('Film') as TxvidGI do
  begin
    ImageClose;
    SetActive(False);
  end;
  LoadPanel.OnClose;
  if TransitionTimer <> nil then
  begin
    CancelCallbackTimer(TransitionTimer);
    TransitionTimer := nil;
  end;
end;
{ @end $671098 }

{ @routine $671120 TfJump_AdvanceTravel }
procedure TfJump.AdvanceTravel(Timer: PCallbackTimerGI; UserData: Integer);
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
      AdvanceLoading(nil, 0);
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
      AdvanceLoading(nil, 0);
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
{ @end $671120 }

{ @routine $671440 TfJump_AdvanceLoading }
procedure TfJump.AdvanceLoading(Timer: PCallbackTimerGI; UserData: Integer);
var
  Loads: TList;
begin
  if not LoadingStarted then
  begin
    LoadingStarted := True;
    if TransitionTimer <> nil then
    begin
      CancelCallbackTimer(TransitionTimer);
      TransitionTimer := nil;
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
      if TransitionTimer <> nil then
      begin
        CancelCallbackTimer(TransitionTimer);
        TransitionTimer := nil;
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
{ @end $671440 }

{ @routine $671700 TfJump_AdvanceMovie }
procedure TfJump.AdvanceMovie(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if (GetByName('Film') as TxvidGI).SetPlaybackTime(timeGetTime - MovieStartTick) then StopMovie;
end;
{ @end $671700 }

{ @routine $67176C TfJump_StopMovie }
function TfJump.StopMovie: Boolean;
begin
  Result := MovieTimer <> nil;
  if MusicEnabled and Result then MusicManager.StopImmediately;
  if MovieTimer <> nil then
  begin
    CancelCallbackTimer(MovieTimer);
    MovieTimer := nil;
  end;
  InvalidateViewport;
  if TransitionTimer <> nil then
  begin
    CancelCallbackTimer(TransitionTimer);
    TransitionTimer := nil;
  end;
  TransitionTimer := ScheduleCallbackTimer(20, 20, AdvanceTravel);
end;
{ @end $67176C }

{ @routine $671820 TfJump_SelectMusic }
procedure TfJump.SelectMusic;
begin
end;
{ @end $671820 }

end.
