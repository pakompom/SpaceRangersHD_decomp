program Rangers;

{$APPTYPE GUI}
{$IMAGEBASE $00400000}
{$SETPEFLAGS $20}
{$I-}
{$R Rangers.res}

uses Windows,
  Classes,
  SysUtils,
  Registry,
  Forms,
  MMSystem,
  Dialogs,
  GlobalsV,
  EC_Struct,
  Direct3D9,
  CrcUnit,
  GI_GAI,
  GR_Rect,
  EC_FileStream,
  GI_XviD,
  GI_Circle,
  GI_PolyLine,
  GR_gi,
  EC_CacheGAI,
  GI_SpaceImg,
  GI_SpaceCircle,
  GI_StarFieldImg,
  EC_CachePalBitmap,
  EC_CacheRotateBuf,
  EC_CachePlanetTempl,
  EC_CacheLightPal,
  EC_CacheTBitmap,
  EC_CacheBitmap,
  GI_StarFieldM,
  GI_StarField,
  EC_CacheGI,
  GI_GraphBuf,
  GI_ShrLight,
  GI_Frame,
  GI_Line,
  GI_SimpleImage,
  GI_TransImage,
  GI_GI,
  EC_CacheAlphaBitmap,
  GI_AlphaImage,
  GI_AImage,
  GI_Image,
  EC_CacheFont,
  GI_Label,
  GI_ScrollBar,
  GI_PanelScrollBar,
  GI_Grid,
  GI_RadioGroup,
  GI_CheckBox,
  GI_Planet,
  GI_PlanetButton,
  GI_StatusBar,
  GI_GraphButton,
  GI_CountBar,
  GI_Edit,
  GI_Zone,
  GI_TextButton,
  GI_SimpleButton,
  GI_Door,
  GI_MultiImage,
  GI_GAIFile,
  GI_InfiniteImage,
  GI_RotateImageGAI,
  EC_CacheHSAI,
  GI_RotateImage5,
  GI_RotateImage2,
  GI_RotateImage,
  GI_SBPath,
  GI_Window,
  GI_Panel,
  PopUp,
  GI_Cursor,
  GI_Main,
  aPacket,
  DirectXRenderException,
  MessageText,
  GR_Main,
  GI_MessageLoop,
  SE_SoundRnd,
  WStringUtils,
  NoSteamAchievemens,
  SimpleSteamApi,
  GI_MessageBox,
  SE_Gate,
  aCalc,
  aPath,
  aGalaxyEvent,
  TextQuestInterface,
  TextFieldClass,
  EventClass,
  ValueListClass,
  CPDiapClass,
  ParViewStringClass,
  ParameterClass,
  CPVarClass,
  CalcParseClass,
  ParameterDeltaClass,
  LocationClass,
  SequenceClass,
  PathClass,
  TextQuest,
  EC_CacheBuf,
  ab_Global,
  GI_Tail,
  EC_Ether,
  GI_PSWeapon,
  GI_RadialEffect,
  GI_PSMissileHit,
  GI_PDTurretWeapon,
  GI_PSEyes,
  GI_PSWeapon16Esodafer,
  GI_PSWeapon14Vertix,
  GI_PSWeapon13IMHO,
  GI_PSWeapon12Turbogravir,
  GI_PSWeapon11Desintegrator,
  GI_PSWeapon10AVision,
  GI_PSWeapon09MResonator,
  GI_PSWeapon08ECutter,
  GI_PSWeapon07Blaster,
  GI_PSWeapon06Phaser,
  GI_PSWeapon05Treton,
  GI_PSWeapon03Lezka,
  GI_PSWeapon02FragCannon,
  GI_PSWeapon01Laser,
  aGroup,
  fChameleon,
  fTextBox,
  fCount2,
  aEObjInfo,
  fListBox,
  fPlanet,
  fPlanetNO,
  fGoodsShop2,
  fScaner,
  fGov,
  fFilm,
  aModsInfo,
  fMods,
  fMainForm,
  fJump,
  fGameLoad,
  fGameMenu,
  fCfgSettings,
  fGameEnd,
  fPlanetQuest,
  ab_W18,
  ab_W17,
  ab_W16,
  ab_W15,
  ab_W14,
  ab_W13,
  ab_W12,
  ab_W11,
  ab_W10,
  ab_W09,
  ab_W08,
  ab_W07,
  ab_W06,
  ab_W05,
  ab_W04,
  ab_W03,
  ab_W02,
  ab_W01,
  ab_W,
  abWall,
  fRuinsTalk,
  fPanelPlanet,
  fInfo,
  aPirate,
  aWarrior,
  aTransport,
  aKling,
  aTranclucator,
  fAbout,
  fIntroduction,
  fGameSettings,
  fGameSettings2,
  SE_Missile,
  aMissile,
  fRewards,
  fRating2,
  fSelectFace,
  fJournal,
  fLoadRobot,
  fLoadQuest,
  fLoadAB,
  aSaveLoad,
  BlockParException,
  ExceptionInfo,
  ab_Polygon,
  fLoad,
  fTalk,
  fHangar,
  fCustom,
  fCount1,
  aScriptFun,
  aScript,
  ab_Space,
  ab_ShipAI,
  ab_Object,
  SE_Ship2,
  ab_Hit,
  ab_Ship,
  ab_StopLine,
  ab_WorldLine,
  ab_WorldImage,
  ab_Zone,
  ab_Item,
  ab_MainForm,
  SE_GAIEffect,
  fGalaxy2,
  fPanelRuins,
  fEquipmentShop,
  CheatCode,
  fScore,
  SE_Planet,
  SE_Sputnik,
  SE_Asteroid,
  fFilmFile,
  FGInt,
  FGIntRSA,
  SE_Ruins,
  aRuins,
  fShip2,
  SE_Star,
  aShip,
  ThreadCalc,
  SE_Container,
  aItem,
  aRanger,
  SE_Hole,
  aAsteroid,
  aPlanet,
  aNormalShip,
  aPlayer,
  fPanelLoad,
  fSaveManager,
  fPanelMain,
  fStarMap,
  SE_Meteorite,
  SE_Angel,
  SE_Anim,
  SE_Comet,
  SE_BGObj,
  SE_Laser,
  SE_StarsField,
  SE_Process,
  aEFilm,
  aEFilmEnd,
  SE_Space,
  SE_Weapon,
  aConst,
  Robot,
  GR_DX,
  EC_CacheSound,
  EC_Data,
  EC_Cache,
  VorbisFile,
  GR_Sound,
  EC_Thread,
  GR_Music,
  EC_Str,
  Achievements,
  fAchievements,
  Globals,
  SE_Garbage,
  EC_Mem,
  GR_GraphBufPal,
  EC_Expression,
  EC_BlockPar,
  EC_HsFile,
  EC_File,
  EC_Buf,
  GR_GraphBuf,
  aVector,
  aGalaxy,
  aMyFunction,
  EC_OKGF,
  GR_AMStream,
  DirectSound,
  BreakMessageGIException,
  VFW,
  aGalaxyStruct,
  GI_PolyFill,
  ab_ShipWall,
  fGalaxy,
  GI_CountBox,
  GI_Track,
  fRating,
  DirectDraw,
  PrintGameState,
  ab_Fast,
  sb_W01,
  GR_RectEx,
  GI_PSWeapon17Kafacitor;

type
  TWineGetHostVersion = procedure(var HostOS, HostVersion: PAnsiChar); stdcall;
  TWineGetBuildId = function: PAnsiChar; stdcall;
  TAD = class(TObject) // @size $04
  public
    procedure ApplicationActivated(Sender: TObject); // @addr $873600
    procedure ApplicationDeactivated(Sender: TObject); // @addr $8737B0
  end;

  TSteamCallbacksThread = class(TThreadEC) // @size 0x2C
  public


    procedure Execute; override; // @addr 0x8732E0
  end;

var
  SteamCallbackThread: TSteamCallbacksThread = nil; // @addr $8820B8
  ApplicationEvents: TAD; // @addr $88C29C
  StartupTime: TSystemTime; // @addr $88C2A0
  ArgumentIndex: Integer; // @addr $88C2B0
  ExecutableFileName: AnsiString; // @addr $88C2B4
  HadProtectedStatus: Boolean; // @addr $88C2B8
  StartupTextBC: WideString; // @addr $88C2BC Finalized by the program; no native readers identified.
  WineModule: Cardinal; // @addr $88C2C0
  WineGetVersion: Pointer; // @addr $88C2C4
  WineGetHostVersion: TWineGetHostVersion; // @addr $88C2C8
  WineNtToUnixFileName: Pointer; // @addr $88C2CC
  WineGetBuildId: TWineGetBuildId; // @addr $88C2D0
  WineHostOS: PAnsiChar; // @addr $88C2D4
  WineHostVersion: PAnsiChar; // @addr $88C2D8
  LanguageBuffer: PStartupWideString; // @addr $88C2DC
  LanguageFileName: AnsiString; // @addr $88C2E0
  LanguageLine: AnsiString; // @addr $88C2E4
  StartupText: WideString; // @addr $88C2E8
  LanguageFile: TextFile; // @addr $88C2EC

{ @routine $8732E0 TSteamCallbacksThread_Execute }
procedure TSteamCallbacksThread.Execute;
var
  CurrentTick, LastCallbackTick: Cardinal;
begin
  LastCallbackTick := timeGetTime;
  while not IsStopRequested do
  begin
    CurrentTick := timeGetTime;
    if CurrentTick - LastCallbackTick > 200 then
    begin
      SteamRunCallbacks;
      LastCallbackTick := CurrentTick;
    end;
    SysUtils.Sleep(100);
  end;
end;
{ @end $8732E0 }

{ @routine $873330 ClearReadOnlyAttributesRecursive }
procedure ClearReadOnlyAttributesRecursive(DirectoryPath: WideString); // @addr 0x873330 @note "Changes the process working directory and does not restore it; paths pass through the ANSI filesystem API."
var
  SearchHandle: THandle;
  FindData: TWin32FindDataA;
begin
  SetCurrentDir(AnsiString(DirectoryPath));
  SearchHandle := Windows.FindFirstFile('*.*', FindData);
  if SearchHandle <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_READONLY) <> 0 then
        if SetFileAttributesA(FindData.cFileName, FILE_ATTRIBUTE_NORMAL) then;
    until not Windows.FindNextFile(SearchHandle, FindData);
    Windows.FindClose(SearchHandle);
  end;
  SearchHandle := Windows.FindFirstFile('*.*', FindData);
  if SearchHandle <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
        if (AnsiString(FindData.cFileName) <> '.') and
           (AnsiString(FindData.cFileName) <> '..') then
          ClearReadOnlyAttributesRecursive(DirectoryPath + '\' + WideString(AnsiString(FindData.cFileName)));
    until not Windows.FindNextFile(SearchHandle, FindData);
    Windows.FindClose(SearchHandle);
  end;
end;
{ @end $873330 }

{ @routine $873540 HandleApplicationActivated }
procedure HandleApplicationActivated; // @addr 0x873540
var
  Buffer: TSoundBuffer;
begin
  RuntimeActive := True;
  if SoundManager <> nil then
  begin
    Buffer := SoundManager.FirstBuffer;
    while Buffer <> nil do
    begin
      if Buffer.Streaming then Buffer.SetVolume(MusicVolume * MusicVolumeScale)
      else Buffer.SetVolume(SoundVolume);
      Buffer := Buffer.Next;
    end;
  end;
  if RegisteredScreens[Ord(CurrentScreenId)] <> nil then
  begin
    FullFrameRedrawRequested := True;
    (TObject(RegisteredScreens[Ord(CurrentScreenId)]) as TMessageLoopGI).InvalidateViewport;
  end;
  if MemorySnapshotActive then RestoreGameFromMemorySnapshot;
end;
{ @end $873540 }

{ @routine $873600 TAD_ApplicationActivated }
procedure TAD.ApplicationActivated(Sender: TObject);
begin
  HandleApplicationActivated;
end;
{ @end $873600 }

{ @routine $873618 HandleApplicationDeactivated }
procedure HandleApplicationDeactivated; // @addr 0x873618
var
  WaitResult: Cardinal;
  Events: array[0..1] of THandle;
  EventPointer: Pointer;
begin
  if WindowedModeRequested then Exit;
  RuntimeActive := False;
  Exit;
  // Native O- code retains the following disabled snapshot/wait path.
  if ExitScreenLoop then;
  if (NewGameGenerationThread <> nil) and NewGameGenerationThread.IsRunning then
    NewGameGenerationThread.WaitForIdle(INFINITE);
  if GetPlayer = nil then Exit;
  if Galaxy = nil then Exit;
  if IsTurnCalculationRunning then
  begin
    Events[0] := TurnCalculationThread.IdleEvent;
    Events[1] := ScriptUiRequestEvent;
    EventPointer := @Events;
    repeat
      WaitResult := WaitForMultipleObjects(2, EventPointer, False, INFINITE);
      if WaitResult = WAIT_OBJECT_0 + 1 then
      begin
        SetEvent(ScriptUiAbortEvent);
        SysUtils.Sleep(1);
      end
      else Break;
    until False;
    if WaitResult = WAIT_OBJECT_0 then;
  end;
  if GetPlayer.InNormalSpace and not PlayerStarDayPrepared then
  begin
    StartPlayerStarPreparation;
    if IsTurnCalculationRunning then
    begin
      Events[0] := TurnCalculationThread.IdleEvent;
      Events[1] := ScriptUiRequestEvent;
      EventPointer := @Events;
      repeat
        WaitResult := WaitForMultipleObjects(2, EventPointer, False, INFINITE);
        if WaitResult = WAIT_OBJECT_0 + 1 then
        begin
          SetEvent(ScriptUiAbortEvent);
          SysUtils.Sleep(1);
        end
        else Break;
      until False;
      if WaitResult = WAIT_OBJECT_0 then;
    end;
  end;
  ResetEvent(ScriptUiAbortEvent);
  if (GameLoadScreen.LoadThread <> nil) and GameLoadScreen.LoadThread.IsRunning then
    GameLoadScreen.LoadThread.WaitForIdle(INFINITE);
  if not MemorySnapshotActive then SaveGameToMemorySnapshot;
end;
{ @end $873618 }

{ @routine $8737B0 TAD_ApplicationDeactivated }
procedure TAD.ApplicationDeactivated(Sender: TObject);
begin
  HandleApplicationDeactivated;
end;
{ @end $8737B0 }

{ @routine $8737C8 HandleMessageIdle }
procedure HandleMessageIdle; // @addr $8737C8 @note "Checks background work, but this build performs no idle action. Assigned to GR_Main.OnMessageIdle. Removing the empty tests changes native behavior and bytes."
begin
  if MemorySnapshotActive then Exit;
  if Galaxy = nil then Exit;
  if (NewGameGenerationThread <> nil) and NewGameGenerationThread.IsRunning then Exit;
  if (GameLoadScreen <> nil) and GameLoadScreen.IsLoading then Exit;
  if IsTurnCalculationRunning then Exit;
end;
{ @end $8737C8 }

{ @routine $873818 HandleMessageResume }
procedure HandleMessageResume; // @addr $873818 @note "Empty conditional callback assigned to GR_Main.OnMessageResume."
begin
  if MemorySnapshotActive then Exit;
  if Galaxy = nil then Exit;
end;
{ @end $873818 }

{ @routine $87382C PurgeCacheDirectoryFiles }
procedure PurgeCacheDirectoryFiles; // @addr 0x87382C @note "Nonrecursive; restores the previous working directory."
var
  FileName, OldDirectory: AnsiString;
  Search: TSearchRec;
begin
  OldDirectory := GetCurrentDir;
  SetCurrentDir(AnsiString(GetGameUserDirectory + 'Cache\'));
  if SysUtils.FindFirst('*.*', faAnyFile, Search) = 0 then
  begin
    repeat
      FileName := Search.Name;
      if (FileName <> '.') and (FileName <> '..') then
        SysUtils.DeleteFile(AnsiString(GetGameUserDirectory + 'Cache\' + WideString(FileName)));
    until SysUtils.FindNext(Search) <> 0;
    SysUtils.FindClose(Search);
  end;
  SetCurrentDir(OldDirectory);
end;
{ @end $87382C }

{ @routine $873A3C CollectInstallLanguageCodes }
function CollectInstallLanguageCodes: WideString; // @addr 0x873A3C @ida "void __usercall $name(unsigned __int16 **Result@<eax>);" @note "Comma-separated lowercase names from INSTALL_*.txt in the current directory."
var
  FileName, LanguageCode: WideString;
  LowerCode: AnsiString;
  NameLength: Integer;
  Search: TSearchRec;
begin
  Result := '';
  if SysUtils.FindFirst('INSTALL_*.txt', faAnyFile, Search) = 0 then
  begin
    repeat
      FileName := Search.Name;
      NameLength := Length(FileName);
      LanguageCode := Copy(FileName, 9, NameLength - 12);
      LowerCode := AnsiLowerCase(AnsiString(LanguageCode));
      if Result = '' then Result := WideString(LowerCode)
      else Result := Result + ',' + WideString(LowerCode);
    until SysUtils.FindNext(Search) <> 0;
    SysUtils.FindClose(Search);
  end;
end;
{ @end $873A3C }


{$I RecoveredExports.inc}

{ @routine $876AB4 start }
begin
  // @unit-finalization $873BC8
  DecimalSeparator := '.';
  MainRuntimeThreadId := GetCurrentThreadId;
  GR_Main.CCInterface := TCCInterface.Create;
  RuntimeExitCheckCallback1 := HandleRuntimeExitCheck1;
  RuntimeExitCheckCallback2 := HandleRuntimeExitCheck2;
  DebugKeyCallback := HandleDebugKey;
  RuntimeStartupTick := timeGetTime;
  OnMessageIdle := @HandleMessageIdle;
  OnMessageResume := @HandleMessageResume;
  Application.Initialize;
  ApplicationEvents := TAD.Create;
  Application.OnActivate := ApplicationEvents.ApplicationActivated;
  Application.OnDeactivate := ApplicationEvents.ApplicationDeactivated;
  if OpenEvent(EVENT_MODIFY_STATE, False, 'EG_SpaceRangers_Run') <> 0 then
    Windows.MessageBox(0, 'Please terminate already running instance of the game!', 'Space Rangers', MB_ICONERROR)
  else
  begin
    CreateEvent(nil, True, True, 'EG_SpaceRangers_Run');
    for ArgumentIndex := 1 to ParamCount do
      if LowerCase(ParamStr(ArgumentIndex)) = 'savemergedcfg' then
        DumpLoadedConfig := True;
    SetLength(ExecutableFileName, MAX_PATH);
    if GetModuleFileNameA(0, PAnsiChar(ExecutableFileName), MAX_PATH) <> 0 then
    begin
      SetLength(ExecutableFileName, StrLen(PAnsiChar(ExecutableFileName)));
      ClearReadOnlyAttributesRecursive(ExtractFileDirW(WideString(ExecutableFileName)));
      SetCurrentDir(AnsiString(ExtractFileDirW(WideString(ExecutableFileName))));
    end;
    WriteRegistryStringLegacy(HKEY_LOCAL_MACHINE, 'SOFTWARE\CLASSES\avifile\Extensions\VDO', '', '{00020000-0000-0000-C000-000000000046}');
    Randomize;
    repeat
      try
        try
          PostLoadScreenId := screenMainMenu;
          CreateStartupLogFile;
          SelectedLanguage := '';
          AvailableLanguageCodes := '';
          RequestedLanguage := '';
          InitializeAchievementDefinitions;
          if not SkipModsOnReload then InitializePlatformRuntimeAndMainWindow;
          SteamInitialized := False;
          if InstallConfig.CountParamsByPath('GameDistributor') > 0 then
          begin
            StartupText := WideString(LowerCase(AnsiString(InstallConfig.GetParamByPathOrMarker('GameDistributor'))));
            if StartupText = 'steam' then
            begin
              AppendLogLineThreadSafe('GameDistributor=Steam');
              LoadSteamApi;
              SetLength(SelectedLanguage, 255);
              SetLength(AvailableLanguageCodes, 255);
              SteamInitialized := SteamInit(SelectedLanguage, AvailableLanguageCodes);
              if not SteamInitialized then AppendLogLineThreadSafe('Steam not initialized');
            end
            else if StartupText = 'gog' then AppendLogLineThreadSafe('GameDistributor=GOG')
            else AppendLogLineThreadSafe(AnsiString('GameDistributor=Unknown(' + InstallConfig.GetParamByPathOrMarker('GameDistributor') + ')'));
          end
          else AppendLogLineThreadSafe('GameDistributor=None');
          if SteamInitialized then
          begin
            LanguageBuffer := @SelectedLanguage;
            TruncateStartupWideString(LanguageBuffer);
            LanguageBuffer := @AvailableLanguageCodes;
            TruncateStartupWideString(LanguageBuffer);
          end
          else
          begin
            SelectedLanguage := 'english';
            AvailableLanguageCodes := CollectInstallLanguageCodes;
            LanguageFileName := AnsiString(GetGameUserDirectory + 'Lang.txt');
            if FileExists(LanguageFileName) then
            begin
              AssignFile(LanguageFile, LanguageFileName);
              Reset(LanguageFile);
              while not Eof(LanguageFile) do
              begin
                Readln(LanguageFile, LanguageLine);
                StartupText := WideString(LanguageLine);
                if CountDelimitedPartsW(StartupText, '=') > 1 then
                  if ExtractDelimitedPartW(StartupText, 0, '=') = 'Lang' then
                    SelectedLanguage := TrimWideString(ExtractDelimitedPartW(StartupText, 1, '='));
              end;
              CloseFile(LanguageFile);
            end;
          end;
          LoadLanguageAndPackages;
          if SteamInitialized then
          begin
            SteamSetLeaderboardName('Scores');
            InitializeSteamAchievements;
            SteamInitialized := SteamLocal(214730);
          end;
          InitializeScriptHostRuntime;
          LoadLocalAchievements;
          RunningUnderWine := False;
          WineModule := Windows.LoadLibrary('ntdll.dll');
          if WineModule > 32 then
          begin
            WineGetVersion := GetProcAddress(WineModule, 'wine_get_version');
            @WineGetHostVersion := GetProcAddress(WineModule, 'wine_get_host_version');
            WineNtToUnixFileName := GetProcAddress(WineModule, 'wine_nt_to_unix_file_name');
            @WineGetBuildId := GetProcAddress(WineModule, 'wine_get_build_id');
            RunningUnderWine := (WineGetVersion <> nil) or Assigned(WineGetHostVersion) or
              (WineNtToUnixFileName <> nil) or Assigned(WineGetBuildId);
            if RunningUnderWine then
            begin
              AppendLogLineThreadSafe('----------------------------------');
              AppendLogLineThreadSafe('NOTICE: Game is launched under Wine or Proton!');
              AppendLogLineThreadSafe('NOTICE: Game may work as it does on Windows - or be funky, bug out and crash.');
              AppendLogLineThreadSafe('NOTICE: Please refer to https://www.protondb.com/app/214730 if you having any issues');
              AppendLogLineThreadSafe('NOTICE: MacOS users may try to ask for help on https://www.reddit.com/r/macgaming/ or https://www.reddit.com/r/wine_gaming/');
              AppendLogLineThreadSafe('----------------------------------');
              if Assigned(WineGetHostVersion) then
              begin
                WineGetHostVersion(WineHostOS, WineHostVersion);
                AppendLogTextThreadSafe('Host OS=');
                // Native startup reports Darwin as Linux; retain that behavior.
                if AnsiString(WineHostOS) = 'Darwin' then AppendLogTextThreadSafe('Linux')
                else AppendLogTextThreadSafe(AnsiString(WineHostOS));
                AppendLogLineThreadSafe(' ' + AnsiString(ShortString(WineHostVersion)));
              end
              else AppendLogLineThreadSafe('Can''t detect host OS, wine_get_host_version() not found');
              if Assigned(WineGetBuildId) then AppendLogLineThreadSafe('Wine=' + AnsiString(WineGetBuildId()))
              else AppendLogLineThreadSafe('Can''t detect Wine build version, wine_get_build_id() not found');
            end;
            FreeLibrary(WineModule);
          end;
          HadProtectedStatus := False;
          GetSystemTime(StartupTime);
          AppendOptionalDebugLogLine(Format('=== Start %d-%.2d-%.2d %.2d.%.2d.%.2d.%.3d',
            [StartupTime.wYear, StartupTime.wMonth, StartupTime.wDay, StartupTime.wHour,
             StartupTime.wMinute, StartupTime.wSecond, StartupTime.wMilliseconds]));
          while True do
          begin
            if ReloadScriptTemplates or ReloadModsRequested then LoadDatConfigAndModOverrides;
            if ReloadModsRequested then
            begin
              LoadSelectedModInstallBlocks;
              if not LoadConfiguredPackages then raise Exception.Create('Error while openning package files');
              ReloadModsRequested := False;
            end;
            InitializeRuntimeAndSettings;
            InitializeGlobalUiRuntime;
            InitializeRobotRuntime;
            if SteamCallbackThread = nil then SteamCallbackThread := TSteamCallbacksThread.Create;
            if not SteamCallbackThread.IsRunning and SteamInitialized then SteamCallbackThread.Start;
            timeBeginPeriod(1);
            if Galaxy <> nil then
            begin
              Galaxy.RefreshAllShipDerivedState;
              Galaxy.ReapplyInterfaceOverrides;
              Galaxy.BindScriptImports;
              if HadProtectedStatus then; // Native retains this disabled status check.
            end;
            if BuildVersionMismatch then Break;
            RequestedScreenId := screenLoad;
            ScreenLoadMode := 0;
            if PostLoadScreenId = screenArcadeBattle then PostLoadScreenId := screenMainMenu;
            if ScreenUsesCompositeLoadAssets(PostLoadScreenId) then ScreenLoadMode := 3;
            RunMainScreenStateLoop;
            timeEndPeriod(1);
            HadProtectedStatus := False;
            if Galaxy <> nil then
            begin
              HadProtectedStatus := GR_Main.CCInterface.GetProtectedStateXorSeed <> 0;
              Galaxy.RestoreProtectedState;
              Galaxy.ClearIntegrityStatus;
            end;
            FinalizeRobotRuntime;
            FinalizeGlobalUiRuntime;
            FinalizeRuntimeAndSettings;
            if ((RequestedScreenId = screenNone) and (PostLoadScreenId = screenNone)) or ExitScreenLoop then
            begin
              FreeDatConfigRoots;
              Break;
            end;
            if ReloadModsRequested then
            begin
              ResetScriptHostRuntimeState;
              ResetInstalledPackageState;
              FreeDatConfigRoots;
              ClearModInfoState;
              SkipModsOnReload := False;
            end;
          end;
          SkipModsOnReload := False;
          if Galaxy <> nil then
          begin
            if IsTurnCalculationRunning then WaitForTurnCalculation;
            Galaxy.Free;
            Galaxy := nil;
            if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
            MemorySnapshotBuffer := nil;
            MemorySnapshotActive := False;
          end;
          FreeAllRandomSounds;
          SteamCallbackThread.RequestStop;
          UnloadSteamApi;
          FinalizeScriptHostRuntime;
          FinalizePlatformRuntime;
          if StartupCleanupObject <> nil then
          begin
            StartupCleanupObject.Free;
            StartupCleanupObject := nil;
          end;
          PurgeCacheDirectoryFiles;
        except
          if not SuppressModRetryPrompt and (SelectedMods <> '') and not SkipModsOnReload then
            if Windows.MessageBox(MainWindowHandle, 'Failed to launch, do you want to try restarting without mods?', 'Exception:', MB_OKCANCEL or MB_ICONERROR) = IDOK then
            begin
              ResetScriptHostRuntimeState;
              ResetInstalledPackageState;
              ClearModInfoState;
              SkipModsOnReload := True;
              raise;
            end;
          SkipModsOnReload := False;
          if Galaxy <> nil then
          begin
            // Native passes the +$28 event field, not the +$08 thread handle.
            if IsTurnCalculationRunning then TerminateThread(TurnCalculationThread.IdleEvent, 0);
            Galaxy.Free;
            Galaxy := nil;
          end;
          if MemorySnapshotBuffer <> nil then MemorySnapshotBuffer.Free;
          MemorySnapshotBuffer := nil;
          MemorySnapshotActive := False;
          FinalizeGlobalUiRuntime;
          FinalizeRuntimeAndSettings;
          FreeAllRandomSounds;
          FinalizeScriptHostRuntime;
          FinalizePlatformRuntime;
          if StartupCleanupObject <> nil then
          begin
            StartupCleanupObject.Free;
            StartupCleanupObject := nil;
          end;
          raise;
        end;
      except
        on StartupException: Exception do
          AppendLogLineThreadSafe('Exception ' + StartupException.ClassName + ' with message ' + StartupException.Message);
      end;
    until not SkipModsOnReload;
  end;
end.
{ @end $876AB4 }
