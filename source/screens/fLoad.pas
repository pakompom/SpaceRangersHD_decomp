unit fLoad;
// Unit bracket (inferred): .text 0x00603988..0x00605568; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_Thread, EC_BlockPar, GI_MessageLoop, fPanelLoad;

type
  TCacheLoader = class(TThreadEC) // @size 0x38
  public
    PendingLoads: TList; // @offset 0x2C  Owns the list and its load-request entries.
    TotalLoadCount: Integer; // @offset 0x30
    CompletedLoadCount: Integer; // @offset 0x34
    procedure Execute; override; // @addr 0x604420
    procedure SetPendingLoads(Loads: TList; StartImmediately: Boolean); // @addr 0x604504 @note "Takes ownership; waits for the previous run before replacing the list."
  end;

  TfLoad = class(TMessageLoopGI) // @size 0x108
  public
    ProgressTimer: PCallbackTimerGI; // @offset 0xD0
    LoadProgress: Single; // @offset 0xD4
    DisplayedProgress: Single; // @offset 0xD8
    LoadingFinished: Boolean; // @offset 0xDC
    IntroSkipRequest: Integer; // @offset $E0  1 skips this item; 2 skips the remaining intro.
    IntroTimer: PCallbackTimerGI; // @offset $E4
    IntroStartedAt: Cardinal; // @offset $E8
    IntroConfig: TBlockParEC; // @offset $EC
    IntroItemIndex: Integer; // @offset $F0
    IntroVideoFrameCount: Integer; // @offset $F4
    IntroDurationMs: Integer; // @offset $F8
    IntroImageKind: Integer; // @offset $FC  0 video, 1 GAI.
    LoadPanel: TfPanelLoad; // @offset 0x100
    BackgroundStyle: Integer; // @offset $104

    constructor Create; // @addr 0x604568 @ida "TfLoad *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x6045C0 @ida "void __usercall $name(TfLoad *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout; override; // @addr 0x604618
    procedure OnOpen; override; // @addr 0x6047A0
    procedure OnClose; override; // @addr 0x6049D8
    procedure UpdateLoadingProgress(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x604C88
    procedure IntroMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $604DD8 @ida "void __userpurge $name(TfLoad *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure IntroKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $604E08
    procedure StartIntroItem(Index: Integer); // @addr $604E40
    procedure UpdateIntro(Timer: PCallbackTimerGI; UserData: Integer); // @addr $6053B4
  end;

procedure QueueCommonLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $603A7C
procedure QueueSpaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $603F50
procedure QueueHyperspaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $604148
procedure QueueArcadeLoadingAssets(PendingLoads: TList; Owner: TObjectGI); // @addr $604174
procedure RemoveDuplicateCacheLoads(PendingLoads: TList); // @addr $6041B0
procedure QueueConfiguredLoadingAssets(PendingLoads: TList; Path: WideString); // @addr $604274
procedure LoadPendingAssets(PendingLoads: TList); // @addr $6043C0

var
  IntroFinished: Boolean = False; // @addr $87B6F0
  IntroPlaying: Boolean; // @addr $889C34

implementation

uses Windows, SysUtils, Math, MMSystem, EC_Cache, EC_Str, GR_Main, Globals,
  GlobalsV, GI_GAI, GI_XviD, ab_Object, aGalaxy, SE_Gate;

{ @routine $603A7C QueueCommonLoadingAssets }
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
  if Cardinal(GameScreenWidth) >= 1600 then
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
{ @end $603A7C }

{ @routine $603F50 QueueSpaceLoadingAssets }
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
    if TCGaiControlEC(SpaceImageTemplates[I].CacheControl) <> nil then TCGaiControlEC(SpaceImageTemplates[I].CacheControl).QueueLoadIfMissing(PendingLoads);
  GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', PlayerStar.GetBackgroundImagePath(I));
  QueueConfiguredLoadingAssets(PendingLoads, 'Space');
  if SoundEnabled then QueueConfiguredLoadingAssets(PendingLoads, 'SpaceSound');
  RemoveDuplicateCacheLoads(PendingLoads);
end;
{ @end $603F50 }

{ @routine $604148 QueueHyperspaceLoadingAssets }
procedure QueueHyperspaceLoadingAssets(PendingLoads: TList; Owner: TObjectGI);
begin
  PlayerStar.QueueHyperspaceShipImageLoads(PendingLoads, Owner);
  RemoveDuplicateCacheLoads(PendingLoads);
end;
{ @end $604148 }

{ @routine $604174 QueueArcadeLoadingAssets }
procedure QueueArcadeLoadingAssets(PendingLoads: TList; Owner: TObjectGI);
begin
  ab_Object_QueueImageLoads(PendingLoads, Owner);
  QueueConfiguredLoadingAssets(PendingLoads, 'AB');
  RemoveDuplicateCacheLoads(PendingLoads);
end;
{ @end $604174 }

{ @routine $6041B0 RemoveDuplicateCacheLoads }
procedure RemoveDuplicateCacheLoads(PendingLoads: TList);
var
  I, J: Integer;
  First, Second: TCacheControlEC;
begin
  I := 0;
  while PendingLoads.Count - 1 > I do
  begin
    First := TCacheControlEC(PendingLoads[I]);
    J := I + 1;
    while PendingLoads.Count > J do
    begin
      Second := TCacheControlEC(PendingLoads[J]);
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
{ @end $6041B0 }

{ @routine $604274 QueueConfiguredLoadingAssets }
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
{ @end $604274 }

{ @routine $6043C0 LoadPendingAssets }
procedure LoadPendingAssets(PendingLoads: TList);
var
  I, Count: Integer;
  Control: TCacheControlEC;
begin
  Count := PendingLoads.Count;
  for I := 0 to Count - 1 do
  begin
    Control := TCacheControlEC(PendingLoads[I]);
    Control.AcquireData;
    Control.Release;
    Control.Free;
  end;
  PendingLoads.Clear;
end;
{ @end $6043C0 }

{ @routine $604420 TCacheLoader_Execute }
procedure TCacheLoader.Execute;
var
  I, Count: Integer;
  Control: TCacheControlEC;
begin
  if PendingLoads <> nil then
  begin
    Count := PendingLoads.Count;
    for I := 0 to Count - 1 do
    begin
      while (Flag18 or ((Galaxy <> nil) and Galaxy.Destroying)) and
        not ExitScreenLoop and not IsStopRequested do SysUtils.Sleep(100);
      Control := TCacheControlEC(PendingLoads[I]);
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
end;
{ @end $604420 }

{ @routine $604504 TCacheLoader_SetPendingLoads }
procedure TCacheLoader.SetPendingLoads(Loads: TList; StartImmediately: Boolean);
begin
  if IsRunning then WaitForIdle(INFINITE);
  PendingLoads := Loads;
  CompletedLoadCount := 0;
  TotalLoadCount := PendingLoads.Count;
  SetPriority(1);
  if StartImmediately then Start;
end;
{ @end $604504 }

{ @routine $604568 TfLoad_Create }
constructor TfLoad.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $604568 }

{ @routine $6045C0 TfLoad_Destroy }
destructor TfLoad.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $6045C0 }

{ @routine $604618 TfLoad_InitializeLayout }
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
{ @end $604618 }

{ @routine $6047A0 TfLoad_OnOpen }
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
  SetCursorActive(False);
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
    IntroTimer := nil;
    IntroConfig := MainDataConfig.GetBlock('Intro');
    StartIntroItem(1);
  end;
  CheckPlatformModules;
end;
{ @end $6047A0 }

{ @routine $6049D8 TfLoad_OnClose }
procedure TfLoad.OnClose;
begin
  with GetByName('Film') as TxvidGI do ImageClose;
  LoadPanel.OnClose;
  if CacheLoader.IsRunning then CacheLoader.WaitForIdle(INFINITE);
  if ProgressTimer <> nil then
  begin
    CancelCallbackTimer(ProgressTimer);
    ProgressTimer := nil;
  end;
  if IntroTimer <> nil then
  begin
    CancelCallbackTimer(IntroTimer);
    IntroTimer := nil;
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
  PostLoadScreenId := screenNone;
end;
{ @end $6049D8 }

{ @routine $604C88 TfLoad_UpdateLoadingProgress }
procedure TfLoad.UpdateLoadingProgress(Timer: PCallbackTimerGI; UserData: Integer);
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
{ @end $604C88 }

{ @routine $604DD8 TfLoad_IntroMouseDown }
procedure TfLoad.IntroMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  IntroSkipRequest := 1;
end;
{ @end $604DD8 }

{ @routine $604E08 TfLoad_IntroKeyDown }
procedure TfLoad.IntroKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key <> 0 then
  begin
    IntroSkipRequest := 1;
    if Key = VK_ESCAPE then Inc(IntroSkipRequest);
  end;
end;
{ @end $604E08 }

{ @routine $604E40 TfLoad_StartIntroItem }
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
          SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2, (GameScreenHeight - ClientSize.Y) div 2));
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
  if IntroTimer <> nil then
  begin
    CancelCallbackTimer(IntroTimer);
    IntroTimer := nil;
  end;
  IntroSkipRequest := 0;
  IntroTimer := ScheduleCallbackTimer(5, 5, UpdateIntro);
end;
{ @end $604E40 }

{ @routine $6053B4 TfLoad_UpdateIntro }
procedure TfLoad.UpdateIntro(Timer: PCallbackTimerGI; UserData: Integer);
var Fraction: Double;
begin
  Fraction := (timeGetTime - IntroStartedAt) / IntroDurationMs;
  if Fraction > 1 then Fraction := 1;
  if (Fraction >= 1) or (IntroSkipRequest > 0) then
  begin
    if IntroTimer <> nil then
    begin
      CancelCallbackTimer(IntroTimer);
      IntroTimer := nil;
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
{ @end $6053B4 }

end.
