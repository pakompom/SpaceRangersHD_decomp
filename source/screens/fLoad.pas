unit fLoad;

interface

uses Classes, EC_Thread, EC_BlockPar, GI_MessageLoop, fPanelLoad;

type
  TCacheLoader = class(TThreadEC) // @size 0x38
  public
    PendingLoads: TList; // @offset 0x2C  Owns the list and its load-request entries.
    TotalLoadCount: Integer; // @offset 0x30
    CompletedLoadCount: Integer; // @offset 0x34
    procedure Execute; override; // @addr 0x005E8DE0
    procedure SetPendingLoads(Loads: TList; StartImmediately: Boolean); // @addr 0x005E8E94 @note "Takes ownership; waits for the previous run before replacing the list."
  end;

  TfLoad = class(TMessageLoopGI) // @size 0x108
  public
    ProgressTimer: TCallbackTimerIdGI; // @offset 0xD0
    LoadProgress: Single; // @offset 0xD4
    DisplayedProgress: Single; // @offset 0xD8
    LoadingFinished: Boolean; // @offset 0xDC
    IntroSkipRequest: Integer; // @offset $E0  1 skips this item; 2 skips the remaining intro.
    IntroTimer: TCallbackTimerIdGI; // @offset $E4
    IntroStartedAt: Cardinal; // @offset $E8
    IntroConfig: TBlockParEC; // @offset $EC
    IntroItemIndex: Integer; // @offset $F0
    IntroVideoFrameCount: Integer; // @offset $F4
    IntroDurationMs: Integer; // @offset $F8
    IntroImageKind: Integer; // @offset $FC  0 video, 1 GAI.
    LoadPanel: TfPanelLoad; // @offset 0x100
    BackgroundStyle: Integer; // @offset $104

    constructor Create; // @addr 0x005E8EDC
    destructor Destroy; override; // @addr 0x005E8F24
    procedure InitializeLayout; override; // @addr 0x005E8F60
    procedure OnOpen; override; // @addr 0x005E90E0
    procedure OnClose; override; // @addr 0x005E92BC
    procedure UpdateLoadingProgress(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005E9540
    procedure IntroMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5E9654
    procedure IntroKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5E9678
    procedure StartIntroItem(Index: Integer); // @addr $5E9694
    procedure UpdateIntro(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $5E9BC0
  end;

procedure QueueCommonLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $5E8548
procedure QueueSpaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $5E89C0
procedure QueueHyperspaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $5E8B98
procedure QueueArcadeLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $5E8BB4
procedure RemoveDuplicateCacheLoads(PendingLoads: TList); // @addr $5E8BE0
procedure QueueConfiguredLoadingAssets(PendingLoads: TList; Path: WideString); // @addr $5E8C80
procedure LoadPendingAssets(PendingLoads: TList); // @addr $5E8D9C

var
  IntroFinished: Boolean = False; // @addr $80F650
  IntroPlaying: Boolean; // @addr $81B834

implementation

uses Windows, SysUtils, Math, MMSystem, EC_Cache, EC_Str, GR_Main, Globals,
  GlobalsV, GI_GAI, GI_XviD, ab_Object, aGalaxy, SE_Gate;

{ @routine $5E8548 QueueCommonLoadingAssets }
procedure QueueCommonLoadingAssets(PendingLoads: TList; Owner: TObjectGI);
begin
  if ScreenLoadMode <> 4 then
  begin
    QueueConfiguredLoadingAssets(PendingLoads, 'LoadGame');
    RemoveDuplicateCacheLoads(PendingLoads);
  end;
  if AnimMenuShip then
  begin
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.FormMain3.2ShipA1');
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.FormMain3.2ShipA2');
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.FormMain3.2ShipA3');
  end;
  if GameScreenWidth >= 1600 then
  begin
    if AnimMenuShip then
    begin
      GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.FormMain3.AnimGaalShip01A');
      GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.FormMain3.AnimGaalShip02A');
      GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.FormMain3.AnimGaalShip03A');
    end;
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.AnimGaalShip01');
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.AnimGaalShip02');
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.AnimGaalShip03');
  end;
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.2Ship1');
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.2Ship2');
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.2Ship3');
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain2.2AnimCaption');
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GI', 'Bm.FormMain3.2BG');
  if ScreenLoadMode = 4 then begin end;
end;
{ @end $5E8548 }

{ @routine $5E89C0 QueueSpaceLoadingAssets }
procedure QueueSpaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI);
var
  Template: TSputnikTempl;
  I, Count: Integer;
  Gate: TGateSE;
begin
  PlayerStar.QueueSpaceImageLoads(PendingLoads, Owner);
  if SputnikShow then
  begin
    Count := SatelliteRenderTemplates.Count;
    for I := 0 to Count - 1 do
    begin
      Template := SatelliteRenderTemplates[I];
      GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'PlanetTempl', Template.MaskName);
    end;
  end;
  Gate := TGateSE.Create('Gate', Classes.Point(0, 0));
  Gate.QueueImageLoad(PendingLoads, Owner);
  Gate.Free;
  for I := 0 to High(SpaceImageTemplates) do
    if SpaceImageTemplates[I].CacheControl <> nil then TCGaiControlEC(SpaceImageTemplates[I].CacheControl).QueueLoadIfMissing(PendingLoads);
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', PlayerStar.GetBackgroundImagePath(I));
  QueueConfiguredLoadingAssets(PendingLoads, 'Space');
  if SoundEnabled then QueueConfiguredLoadingAssets(PendingLoads, 'SpaceSound');
  RemoveDuplicateCacheLoads(PendingLoads);
end;
{ @end $5E89C0 }

{ @routine $5E8B98 QueueHyperspaceLoadingAssets }
procedure QueueHyperspaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI);
begin
  PlayerStar.QueueHyperspaceShipImageLoads(PendingLoads, Owner);
  RemoveDuplicateCacheLoads(PendingLoads);
end;
{ @end $5E8B98 }

{ @routine $5E8BB4 QueueArcadeLoadingAssets }
procedure QueueArcadeLoadingAssets(PendingLoads: TList; Owner: TObjectGI);
begin
  ab_Object_QueueImageLoads(PendingLoads, Owner);
  QueueConfiguredLoadingAssets(PendingLoads, 'AB');
  RemoveDuplicateCacheLoads(PendingLoads);
end;
{ @end $5E8BB4 }

{ @routine $5E8BE0 RemoveDuplicateCacheLoads }
procedure RemoveDuplicateCacheLoads(PendingLoads: TList);
var
  I, J: Integer;
  First, Second: TCacheControlEC;
begin
  I := 0;
  while PendingLoads.Count - 1 > I do
  begin
    First := PendingLoads[I];
    J := I + 1;
    while PendingLoads.Count > J do
    begin
      Second := PendingLoads[J];
      if (First.ClassName = Second.ClassName) and (First.CacheKey = Second.CacheKey) then
      begin
        Second.Free;
        PendingLoads.Delete(J);
      end
      else Inc(J);
    end;
    Inc(I);
  end;
end;
{ @end $5E8BE0 }

{ @routine $5E8C80 QueueConfiguredLoadingAssets }
procedure QueueConfiguredLoadingAssets(PendingLoads: TList; Path: WideString);
var
  I, Count: Integer;
  Block: TBlockParEC;
begin
  Block := GameDataConfig.GetBlockByPath('Load.' + Path);
  Count := Block.GetBlockCount;
  for I := 0 to Count - 1 do
    QueueConfiguredLoadingAssets(PendingLoads, Path + '.' + Block.GetBlockNameByIndex(I));
  Count := Block.GetParamCount;
  for I := 0 to Count - 1 do
    GlobalCache.QueueNamedLoadIfMissing(PendingLoads,
      Block.GetParamName(I), Block.GetParamValue(I));
end;
{ @end $5E8C80 }

{ @routine $5E8D9C LoadPendingAssets }
procedure LoadPendingAssets(PendingLoads: TList);
var
  I, Count: Integer;
  Control: TCacheControlEC;
begin
  Count := PendingLoads.Count;
  for I := 0 to Count - 1 do
  begin
    Control := PendingLoads[I];
    Control.AcquireData;
    Control.Release;
    Control.Free;
  end;
  PendingLoads.Clear;
end;
{ @end $5E8D9C }

{ @routine $5E8DE0 TCacheLoader_Execute }
procedure TCacheLoader.Execute;
var
  I, Count: Integer;
  Control: TCacheControlEC;
begin
  if PendingLoads = nil then Exit;
  Count := PendingLoads.Count;
  for I := 0 to Count - 1 do
  begin
    while (PauseRequested or ((Galaxy <> nil) and Galaxy.Destroying)) and
      not ExitScreenLoop and not IsStopRequested do SysUtils.Sleep(100);
    Control := PendingLoads[I];
    if not ExitScreenLoop and not IsStopRequested then
    begin
      Control.AcquireData;
      Control.Release;
    end;
    Control.Free;
    Inc(CompletedLoadCount);
  end;
  PendingLoads.Free;
  PendingLoads := nil;
end;
{ @end $5E8DE0 }

{ @routine $5E8E94 TCacheLoader_SetPendingLoads }
procedure TCacheLoader.SetPendingLoads(Loads: TList; StartImmediately: Boolean);
begin
  if IsRunning then WaitForIdle(INFINITE);
  PendingLoads := Loads;
  CompletedLoadCount := 0;
  TotalLoadCount := PendingLoads.Count;
  SetPriority(priority_lowest);
  if StartImmediately then Start;
end;
{ @end $5E8E94 }

{ @routine $5E8EDC TfLoad_Create }
constructor TfLoad.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $5E8EDC }

{ @routine $5E8F24 TfLoad_Destroy }
destructor TfLoad.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $5E8F24 }

{ @routine $5E8F60 TfLoad_InitializeLayout }
procedure TfLoad.InitializeLayout;
var Root: TObjectGI;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fLoad... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Root := GetByName('');
  Root.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Root.FindByNameRecursive('IntroRect').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  with Root.FindByNameRecursive('Intro') as TgaiGI do
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Root.FindByNameRecursive('Film').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  AppendLogLineThreadSafe('ok');
  LoadPanel.InitializeLayout(Self);
end;
{ @end $5E8F60 }

{ @routine $5E90E0 TfLoad_OnOpen }
procedure TfLoad.OnOpen;
var Loads: TList;
begin
  IntroSkipRequest := 0;
  LoadPanel.OnOpen;
  ContentPanel.KeyDownCallback := IntroKeyDown;
  ContentPanel.LeftButtonDownCallback := IntroMouseDown;
  ContentPanel.RightButtonDownCallback := IntroMouseDown;
  if SkipIntro then IntroFinished := True;
  if IntroFinished and (MusicManager.CategoryOverride = '') then MusicManager.RequestFadeOut;
  LoadProgress := 0;
  DisplayedProgress := 0;
  LoadingFinished := False;
  Self.ShowCursor := False;
  Loads := TList.Create;
  if (ScreenLoadMode = 0) or (ScreenLoadMode = 4) then
    QueueCommonLoadingAssets(Loads, RootUiObject)
  else if ScreenLoadMode = 2 then
    QueueSpaceLoadingAssets(Loads, RootUiObject)
  else if ScreenLoadMode = 3 then
  begin
    QueueCommonLoadingAssets(Loads, RootUiObject);
    QueueSpaceLoadingAssets(Loads, RootUiObject);
  end;
  if Loads.Count > 0 then
  begin
    CacheLoader.SetPendingLoads(Loads, False);
    ProgressTimer := ScheduleCallbackTimer(20, 20, UpdateLoadingProgress);
  end
  else
  begin
    Loads.Free;
    RequestClose(1);
  end;
  if IntroFinished then
  begin
    CacheLoader.Start;
    LoadPanel.SetProgress(0);
    LoadPanel.Show;
  end
  else
  begin
    IntroPlaying := True;
    CacheLoader.Start;
    IntroSkipRequest := 0;
    IntroTimer := 0;
    IntroConfig := MainDataConfig.GetBlock('Intro');
    StartIntroItem(1);
  end;
  CheckPlatformModules;
end;
{ @end $5E90E0 }

{ @routine $5E92BC TfLoad_OnClose }
procedure TfLoad.OnClose;
begin
  with GetByName('Film') as TxvidGI do ImageClose;
  LoadPanel.OnClose;
  if CacheLoader.IsRunning then CacheLoader.WaitForIdle(INFINITE);
  if ProgressTimer <> 0 then
  begin
    CancelCallbackTimer(ProgressTimer);
    ProgressTimer := 0;
  end;
  if IntroTimer <> 0 then
  begin
    CancelCallbackTimer(IntroTimer);
    IntroTimer := 0;
  end;
  if (ScreenLoadMode = 0) or (ScreenLoadMode = 3) then
  begin
    MainMenuScreen.InitializeLayout;
    PlanetQuestScreen.InitializeLayout;
    LoadScreen.InitializeLayout;
    NewGameScreen.InitializeLayout;
    IntroductionScreen.InitializeLayout;
    HangarScreen.InitializeLayout;
    PlanetScreen.InitializeLayout;
    UninhabitedPlanetScreen.InitializeLayout;
    RuinsTalkScreen.InitializeLayout;
    ArcadeBattleScreen.InitializeLayout;
    EquipmentShopScreen.InitializeLayout;
    GoodsShopScreen.InitializeLayout;
    GovernmentScreen.InitializeLayout;
    InfoScreen.InitializeLayout;
    RangerRatingScreen.InitializeLayout;
    RewardsScreen.InitializeLayout;
    ShipScreen.InitializeLayout;
    ScannerScreen.InitializeLayout;
    StarMapScreen.InitializeLayout;
    FilmScreen.InitializeLayout;
    GalaxyScreen.InitializeLayout;
    JumpScreen.InitializeLayout;
    SaveManagerScreen.InitializeLayout;
    GameLoadScreen.InitializeLayout;
    GameMenuScreen.InitializeLayout;
    SettingsScreen.InitializeLayout;
    GameEndScreen.InitializeLayout;
    AboutScreen.InitializeLayout;
    ScoreScreen.InitializeLayout;
    SpaceObjectUiLoop.InitializeLayout;
    TalkScreen.InitializeLayout;
    SelectFaceScreen.InitializeLayout;
    JournalScreen.InitializeLayout;
    LoadRobotScreen.InitializeLayout;
    LoadQuestScreen.InitializeLayout;
    LoadArcadeScreen.InitializeLayout;
    AchievementsScreen.InitializeLayout;
  end;
  IntroFinished := True;
  RequestedScreenId := PostLoadScreenId;
  PostLoadScreenId := screen_none;
end;
{ @end $5E92BC }

{ @routine $5E9540 TfLoad_UpdateLoadingProgress }
procedure TfLoad.UpdateLoadingProgress(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if not LoadingFinished then
  begin
    if CacheLoader.IsRunning then
      LoadProgress := CacheLoader.CompletedLoadCount / CacheLoader.TotalLoadCount
    else
    begin
      LoadingFinished := True;
      LoadProgress := 1;
    end;
  end;
  if DisplayedProgress < LoadProgress then
  begin
    DisplayedProgress := Min(0.05 + DisplayedProgress, LoadProgress);
    LoadPanel.SetProgress(DisplayedProgress);
  end;
  if not LoadingFinished then Exit;
  if 0.999 > DisplayedProgress then Exit;
  if not IntroPlaying then
  begin
    LoadPanel.SetProgress(1);
    Present;
    RequestClose(1);
  end;
end;
{ @end $5E9540 }

{ @routine $5E9654 TfLoad_IntroMouseDown }
procedure TfLoad.IntroMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  IntroSkipRequest := 1;
end;
{ @end $5E9654 }

{ @routine $5E9678 TfLoad_IntroKeyDown }
procedure TfLoad.IntroKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key <> 0 then
  begin
    IntroSkipRequest := 1;
    if Key = VK_ESCAPE then Inc(IntroSkipRequest);
  end;
end;
{ @end $5E9678 }

{ @routine $5E9694 TfLoad_StartIntroItem }
procedure TfLoad.StartIntroItem(Index: Integer);
var
  Block: TBlockParEC;
  ImagePath: WideString;
begin
  Block := IntroConfig.FindBlock(IntToStr(Index));
  if (Block = nil) or (IntroSkipRequest > 1) then
  begin
    InvalidateViewport;
    IntroPlaying := False;
    Exit;
  end;
  IntroItemIndex := Index;
  if Block.CountParams('Image') = 0 then
  begin
    StartIntroItem(Index + 1);
    Exit;
  end;
  ImagePath := Block.GetParam('Image');
  if LowerCaseWideString(TrimWideString(ExtractFileExtNoDotW(ImagePath))) = 'vdo' then
  begin
    IntroImageKind := 0;
    with GetByName('Film') as TxvidGI do
      if not ImageOpen(ImagePath, False) then
      begin
        StartIntroItem(Index + 1);
        Exit;
      end;
    if Block.CountParams('Frames') > 0 then
      IntroVideoFrameCount := ExtractDigitsToIntW(Block.GetParam('Frames'));
  end
  else
  begin
    IntroImageKind := 1;
    with GetByName('Intro') as TgaiGI do
    begin
      SetImagePath(ImagePath);
      SetPosition(Classes.Point(0, 0));
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      if Block.CountParams('Size') > 0 then
      begin
        ImagePath := Block.GetParam('Size');
        if CountDelimitedPartsW(ImagePath, ',') > 1 then
        begin
          SetSize(Classes.Point(ExtractDigitsToIntW(ExtractDelimitedPartW(ImagePath, 0, ',')),
            ExtractDigitsToIntW(ExtractDelimitedPartW(ImagePath, 1, ','))));
          SetPosition(Classes.Point((Integer(GameScreenWidth) - ClientSize.X) div 2, (Integer(GameScreenHeight) - ClientSize.Y) div 2));
          if Block.CountParams('Sme') > 0 then
          begin
            ImagePath := Block.GetParam('Sme');
            if CountDelimitedPartsW(ImagePath, ',') > 1 then
              SetPosition(Classes.Point(LocalPosition.X + ExtractSignedDigitsToIntW(ExtractDelimitedPartW(ImagePath, 0, ',')),
                LocalPosition.Y + ExtractSignedDigitsToIntW(ExtractDelimitedPartW(ImagePath, 1, ','))));
          end;
        end;
      end;
      if Block.CountParams('Frames') > 0 then
        LoadFrameSequenceFromText('[80,0-' + Block.GetParam('Frames') + ']');
      PrimeImageCaches;
      SetActive(True);
      StopAutoPlayback;
      SetSequenceFrame(0);
    end;
  end;
  if Block.CountParams('Time') > 0 then
    IntroDurationMs := ExtractDigitsToIntW(Block.GetParam('Time'));
  if MusicEnabled then
    if Block.CountParams('Sound') > 0 then
    begin
      MusicManager.PlayCategory(Block.GetParam('Sound'));
      while not MusicManager.IsPlaying do SysUtils.Sleep(1);
    end;
  IntroStartedAt := timeGetTime;
  if IntroTimer <> 0 then
  begin
    CancelCallbackTimer(IntroTimer);
    IntroTimer := 0;
  end;
  IntroSkipRequest := 0;
  IntroTimer := ScheduleCallbackTimer(5, 5, UpdateIntro);
end;
{ @end $5E9694 }

{ @routine $5E9BC0 TfLoad_UpdateIntro }
procedure TfLoad.UpdateIntro(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Fraction: Double;
begin
  Fraction := (timeGetTime - IntroStartedAt) / IntroDurationMs;
  if Fraction > 1 then Fraction := 1;
  if (Fraction >= 1) or (IntroSkipRequest > 0) then
  begin
    if IntroTimer <> 0 then
    begin
      CancelCallbackTimer(IntroTimer);
      IntroTimer := 0;
    end;
    if MusicEnabled then
    begin
      MusicManager.StopImmediately;
      while MusicManager.IsPlaying do SysUtils.Sleep(1);
    end;
    with GetByName('Film') as TxvidGI do ImageClose;
    with GetByName('Intro') as TgaiGI do SetImagePath('');
    StartIntroItem(IntroItemIndex + 1);
    Exit;
  end;
  if IntroImageKind = 0 then
  begin
    with GetByName('Film') as TxvidGI do
      SetFramePosition(Round((IntroVideoFrameCount - 1) * Fraction));
  end
  else
  begin
    with GetByName('Intro') as TgaiGI do
      SetFramePosition(Round((SequenceFrameCount - 1) * Fraction), True);
  end;
end;
{ @end $5E9BC0 }

end.
