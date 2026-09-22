unit fCfgSettings;
// Unit bracket (inferred): .text 0x005F21BC..0x00602807; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_CacheFont, EC_BlockPar, GI_CountBar, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types;

type
  TOptionSliderEvent = procedure(Sender: TCountBarGI) of object;

  TfCfgSettings = class(TMessageLoopGI) // @size 0x140
  public
    ActiveGroupIndex: Integer; // @offset 0xD0
    BuildGroupIndex: Integer; // @offset 0xD4
    CurrentOptionName: WideString; // @offset 0xD8
    GroupPanels: array[0..5] of TPanelGI; // @offset 0xDC
    GroupNextY: array[0..5] of Integer; // @offset 0xF4
    SettingsMode: Integer; // @offset 0x10C // 0: game; 1: robot battles.
    ModeButtonState: Integer; // @offset 0x110 // 0: normal; 1: hovered; 2: pressed.
    ModeLeftPosition: TPoint; // @offset 0x114
    ModeRightPosition: TPoint; // @offset 0x11C
    GroupButtonTops: array[0..3] of Integer; // @offset 0x124
    ModeLeaveTimer: PCallbackTimerGI; // @offset 0x134
    RobotAvailability: Integer; // @offset 0x138
    HasInstalledPackages: Boolean; // @offset 0x13C

    procedure InitializeLayout; override; // @addr 0x5F2344
    procedure OnOpen; override; // @addr 0x5F2E88
    procedure OnClose; override; // @addr 0x5F8E1C
    procedure SelectMusic; override; // @addr 0x602480
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr 0x6027B4
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr 0x5FF368
    procedure MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x5F8E6C
    procedure ShowControlHelp(Sender: TObjectGI; Show: Boolean); // @addr 0x5F9048
    procedure GroupClicked(Sender: TObjectGI); // @addr 0x5F90BC
    procedure RefreshVisibleGroup; // @addr 0x5F9220
    function AddOptionLabel(OptionName, Caption: WideString; UnusedFlag: Boolean): TLabelGI; // @addr 0x5F9420
    procedure AddOptionChoice(Value: Integer; Caption: WideString; Selected, Disabled: Boolean); // @addr 0x5F9724
    procedure OptionChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x5F9BEC
    procedure OptionChoiceMouseEnter(Sender: TObjectGI); // @addr 0x5F9DD4
    procedure OptionChoiceMouseLeave(Sender: TObjectGI); // @addr 0x5F9F10
    procedure AddOptionSlider(ValueLabel: TLabelGI; Minimum, Maximum, Position, UnusedStep: Integer; Callback: TOptionSliderEvent); // @addr 0x5FA04C @note "Invokes Callback immediately with the new slider."
    function HasOptionValue(OptionName: WideString): Boolean; // @addr 0x5FA7C4 @note "Searches only the active group."
    function GetOptionValue(OptionName: WideString): Integer; // @addr 0x5FA924 @note "Searches only the active group; raises when no selected choice or slider exists."
    procedure SetOptionValue(OptionName: WideString; Value: Integer); // @addr 0x5FAAE0 @note "Searches only the active group; missing options are ignored."
    procedure FormatResolution(Sender: TCountBarGI); // @addr 0x5FABE8
    procedure FormatRobotResolution(Sender: TCountBarGI); // @addr 0x5FADDC
    procedure FormatRobotFsaaSamples(Sender: TCountBarGI); // @addr 0x5FAFD0
    procedure PreviewBrightness(Sender: TCountBarGI); // @addr 0x5FB0D0 @note "Changes display gamma before settings are applied."
    procedure PreviewContrast(Sender: TCountBarGI); // @addr 0x5FB264 @note "Changes display gamma before settings are applied."
    procedure FormatInteger(Sender: TCountBarGI); // @addr 0x5FB3F8
    procedure FormatTurnSaveStep(Sender: TCountBarGI); // @addr 0x5FB4E8
    procedure FormatForsageDeactivatePercent(Sender: TCountBarGI); // @addr 0x5FB7C4
    procedure HighPresetClicked(Sender: TObjectGI); // @addr 0x5FBA20
    procedure MediumPresetClicked(Sender: TObjectGI); // @addr 0x5FC364
    procedure LowPresetClicked(Sender: TObjectGI); // @addr 0x5FCC7C
    procedure AutoPresetClicked(Sender: TObjectGI); // @addr 0x5FD560
    procedure CancelClicked(Sender: TObjectGI); // @addr 0x5FE294
    procedure ModeMouseEnter(Sender: TObjectGI); // @addr 0x5FF048
    procedure ModeMouseLeave(Sender: TObjectGI); // @addr 0x5FF0F0
    procedure RefreshModeUi; // @addr 0x5FE2C0
    procedure ModeLeaveTimerTick(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x5FF158
    procedure ModeMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x5FF1FC
    procedure ModeMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x5FF28C
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x5FF330
    procedure ApplyClicked(Sender: TObjectGI); // @addr 0x5FF420 @note "Persists CFG.TXT; changes requiring rebuilt resources request another runtime session."
    function CreateWarningImage(Owner: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr 0x60238C @note "Embedded-item data is ignored."
  end;

function EstimateCpuClockMHz: Double; // @addr 0x5F2268 @note "Uses the low 32 bits of a timestamp-counter delta across a 200 ms sleep; temporarily raises process/thread priority."

var
  SettingsModeColorNormal: Cardinal; // @addr $88AA08
  SettingsModeColorHighlighted: Cardinal; // @addr $88AA0C

implementation

uses aGalaxyStruct, Windows, Classes, SysUtils, Math, GR_Main, GlobalsV, Globals, EC_Str,
  aGalaxy, aPlayer, aPlanet, aShip, aItem, aConst, aMyFunction, aScript,
  GI_GraphButton, GI_PanelScrollBar, GI_MessageBox, EC_Struct, GI_Main, Robot, EC_File, GR_DX, GR_Sound, fStarMap;

{ @routine $5F2268 EstimateCpuClockMHz }
function EstimateCpuClockMHz: Double;
var
  CounterLow, CounterHigh: Cardinal;
  ProcessPriority: Cardinal;
  ThreadPriority: Integer;
begin
  ProcessPriority := GetPriorityClass(GetCurrentProcess);
  ThreadPriority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  try
    SysUtils.Sleep(10);
    // The native source contains these timestamp-counter assembly blocks.
    asm
      rdtsc
      mov CounterLow, eax
      mov CounterHigh, edx
    end;
    SysUtils.Sleep(200);
    asm
      rdtsc
      sub eax, CounterLow
      sbb edx, CounterHigh
      mov CounterLow, eax
      mov CounterHigh, edx
    end;
    Result := CounterLow / 200000.0;
  except
    Result := 1500;
  end;
  SetThreadPriority(GetCurrentThread, ThreadPriority);
  SetPriorityClass(GetCurrentProcess, ProcessPriority);
end;
{ @end $5F2268 }

{ @routine $5F2344 TfCfgSettings_InitializeLayout }
procedure TfCfgSettings.InitializeLayout;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fCfgSettings... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FirstChild do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      with NextSibling do
      begin
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight));
        with NextSibling do
        begin
          SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
          with NextSibling do
          begin
            SetPosition(Classes.Point(ExtraScreenWidth div 2 + LocalPosition.X, LocalPosition.Y));
            SetSize(Classes.Point(ClientSize.X, ClientSize.Y + Max(ExtraScreenHeight, 0)));
            with FindByNameRecursive('PanelSet') as TPanelScrollBarGI do
            begin
              SetSize(Classes.Point(ClientSize.X, ClientSize.Y + Max(ExtraScreenHeight, 0)));
              VerticalScrollBar.SetSize(Classes.Point(VerticalScrollBar.ClientSize.X, VerticalScrollBar.ClientSize.Y + Max(ExtraScreenHeight, 0)));
            end;
            with NextSibling do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
          end;
        end;
      end;
    end;
    with FindByNameRecursive('ModeLeftPanel').NextSibling do
    begin
      SetSize(Classes.Point(ClientSize.X, ClientSize.Y + Max(ExtraScreenHeight, 0)));
      with NextSibling do SetSize(Classes.Point(ClientSize.X, ClientSize.Y + Max(ExtraScreenHeight, 0)));
    end;
    with FirstChild.NextSibling do SetDepth(Depth - 2);
  end;
  AppendLogLineThreadSafe('ok');
  with GetByName('Cancel') as TGraphButtonGI do UpCallback := CancelClicked;
  (GetByName('Ok') as TGraphButtonGI).UpCallback := ApplyClicked;
  GetByName('MainPanel').MouseMoveCallback := MainPanelMouseMove;
  with GetByName('ButAUp') as TGraphButtonGI do UpCallback := HighPresetClicked;
  with GetByName('ButAMiddle') as TGraphButtonGI do UpCallback := MediumPresetClicked;
  with GetByName('ButADown') as TGraphButtonGI do UpCallback := LowPresetClicked;
  with GetByName('ButAAuto') as TGraphButtonGI do UpCallback := AutoPresetClicked;
  with GetByName('MainPanel') do KeyDownCallback := MainPanelKeyDown;
  with GetByName('ButGroup0') as TGraphButtonGI do
  begin
    UpCallback := GroupClicked;
    DownCallback := GroupClicked;
    GroupButtonTops[0] := LocalPosition.Y;
  end;
  with GetByName('ButGroup1') as TGraphButtonGI do
  begin
    UpCallback := GroupClicked;
    DownCallback := GroupClicked;
    GroupButtonTops[1] := LocalPosition.Y;
  end;
  with GetByName('ButGroup2') as TGraphButtonGI do
  begin
    UpCallback := GroupClicked;
    DownCallback := GroupClicked;
    GroupButtonTops[2] := LocalPosition.Y;
  end;
  with GetByName('ButGroup3') as TGraphButtonGI do
  begin
    UpCallback := GroupClicked;
    DownCallback := GroupClicked;
    GroupButtonTops[3] := LocalPosition.Y;
  end;
  ModeLeftPosition := GetByName('ModeLeftPanel').LocalPosition;
  ModeRightPosition := GetByName('ModeRightPanel').LocalPosition;
  with GetByName('ModeLeftButtonN') do
  begin
    MouseEnterCallback := ModeMouseEnter;
    MouseLeaveCallback := ModeMouseLeave;
    LeftButtonDownCallback := ModeMouseDown;
    LeftButtonUpCallback := ModeMouseUp;
    UserValue := 0;
  end;
  with GetByName('ModeLeftButtonD') do
  begin
    MouseEnterCallback := ModeMouseEnter;
    MouseLeaveCallback := ModeMouseLeave;
    LeftButtonDownCallback := ModeMouseDown;
    LeftButtonUpCallback := ModeMouseUp;
    UserValue := 0;
  end;
  with GetByName('ModeRightButtonN') do
  begin
    MouseEnterCallback := ModeMouseEnter;
    MouseLeaveCallback := ModeMouseLeave;
    LeftButtonDownCallback := ModeMouseDown;
    LeftButtonUpCallback := ModeMouseUp;
    UserValue := 1;
  end;
  with GetByName('ModeRightButtonD') do
  begin
    MouseEnterCallback := ModeMouseEnter;
    MouseLeaveCallback := ModeMouseLeave;
    LeftButtonDownCallback := ModeMouseDown;
    LeftButtonUpCallback := ModeMouseUp;
    UserValue := 1;
  end;
  SettingsModeColorNormal := GetStyleColorGI('Settings.ModeColorNormal', 0, 44, 70);
  SettingsModeColorHighlighted := GetStyleColorGI('Settings.ModeColorHighlighted', 0, 255, 255);
end;
{ @end $5F2344 }

{ @routine $5F2E88 TfCfgSettings_OnOpen }
procedure TfCfgSettings.OnOpen;
var
  Panel: TPanelScrollBarGI;
  I, LanguageCount: Integer;
  Language, LanguageName: WideString;
  ValueLabel: TLabelGI;
  Block: TBlockParEC;
begin
  if IsInstallFeatureEnabled('Robot') then
  begin
    RobotAvailability := 1;
    if RobotInterface <> nil then RobotAvailability := RobotInterface.Support;
  end
  else RobotAvailability := 4;
  SettingsMode := 0;
  ModeButtonState := 0;
  GetByName('LabelHelp').SetActive(False);
  Panel := GetByName('PanelSet') as TPanelScrollBarGI;
  Panel.FreeOwnedChildren;
  for I := 0 to 5 do
  begin
    GroupNextY[I] := 0;
    GroupPanels[I] := TPanelGI.Create(Panel);
    with GroupPanels[I] do
    begin
      SetSize(Classes.Point(Panel.ClientSize.X, 0));
      SetPosition(Classes.Point(0, 0));
      SetDepth(-100);
      SetPositionModeW(True);
    end;
  end;
  BuildGroupIndex := 0;
  HasInstalledPackages := False;
  for I := 0 to ModLanguageInstallConfigs.Count - 1 do
  begin
    Block := ModLanguageInstallConfigs[I];
    Block := Block.GetBlock('Packages');
    if Block.GetParamCount > 0 then
    begin
      HasInstalledPackages := True;
      Break;
    end;
  end;
  if not SteamInitialized and (RequestedLanguage = '') then
  begin
    AddOptionLabel('Lang', LocalizedText('FormCfgSettings.Lang'), True);
    if (AvailableLanguageCodes <> '') and (CountDelimitedPartsW(AvailableLanguageCodes, ',') > 0) then
    begin
      LanguageCount := CountDelimitedPartsW(AvailableLanguageCodes, ',');
      for I := 0 to LanguageCount - 1 do
      begin
        Language := ExtractDelimitedPartW(AvailableLanguageCodes, I, ',');
        if FileExists(AnsiString('install_' + Language + '.txt')) then
        begin
          Block := TBlockParEC.Create;
          Block.LoadFromTextFileWithEncodingProbe(PWideChar('install_' + Language + '.txt'), False);
          LanguageName := Block.GetParam('LangName');
          Block.Free;
        end;
        AddOptionChoice(I, LanguageName, UpperCaseWideString(Language) = UpperCaseWideString(SelectedLanguage),
          (Galaxy <> nil) and HasInstalledPackages);
      end;
    end
    else
    begin
      Language := SelectedLanguage;
      AddOptionChoice(0, ExtractDelimitedPartW(Language, 0, ','), True, False);
    end;
  end;
  AddOptionLabel('MultiThread', LocalizedText('FormCfgSettings.MultiThread'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), MultiThreadEnabled, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not MultiThreadEnabled, False);
  AddOptionLabel('DefaultOrder', LocalizedText('FormCfgSettings.DefaultOrder'), False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.DefaultOrderAuto'), DefaultOrder = 0, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.DefaultOrderNear'), DefaultOrder = 2, False);
  AddOptionChoice(3, LocalizedText('FormCfgSettings.DefaultOrderFar'), DefaultOrder = 3, False);
  AddOptionLabel('RightClickOnShip', LocalizedText('FormCfgSettings.RightClickOnShip'), False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RightClickOnShipScaner'), RightClickOnShip = 0, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RightClickOnShipTalk'), RightClickOnShip = 1, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.RightClickOnShipChangeOrder'), RightClickOnShip = 2, False);
  AddOptionLabel('FilmSpeed', LocalizedText('FormCfgSettings.FilmSpeed'), False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.FilmSpeed0'), FilmSpeed = 0, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.FilmSpeed1'), FilmSpeed = 1, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.FilmSpeed2'), FilmSpeed = 2, False);
  AddOptionChoice(3, LocalizedText('FormCfgSettings.FilmSpeed3'), FilmSpeed = 3, False);
  AddOptionLabel('ViewFollowShip', LocalizedText('FormCfgSettings.ViewFollowShip'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), ViewFollowShip, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not ViewFollowShip, False);
  AddOptionLabel('ViewPathLength', LocalizedText('FormCfgSettings.ViewPathLength'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), ViewPathLength, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not ViewPathLength, False);
  AddOptionLabel('ActionDoubleClick', LocalizedText('FormCfgSettings.ActionDoubleClick'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), ActionDoubleClick, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not ActionDoubleClick, False);
  AddOptionLabel('ClickAutoCloseForm', LocalizedText('FormCfgSettings.ClickAutoCloseForm'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), ClickAutoCloseForm, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not ClickAutoCloseForm, False);
  ValueLabel := AddOptionLabel('ForsageDeactivatePercent', LocalizedText('FormCfgSettings.ForsageTurnOff'), False);
  AddOptionSlider(ValueLabel, 0, 100, AfterburnerStopCondition, 1, FormatForsageDeactivatePercent);
  ValueLabel := AddOptionLabel('MaxSearchResult', LocalizedText('FormCfgSettings.MaxSearchResult'), False);
  AddOptionSlider(ValueLabel, 1, 100, MaxSearchResult, 1, FormatInteger);
  ValueLabel := AddOptionLabel('MaxPlayerNews', LocalizedText('FormCfgSettings.MaxPlayerNews'), False);
  AddOptionSlider(ValueLabel, 0, 100, MaxPlayerNews, 1, FormatInteger);
  ValueLabel := AddOptionLabel('TurnSaveStep', LocalizedText('FormCfgSettings.TurnSaveStep'), False);
  AddOptionSlider(ValueLabel, 0, TurnsPerYear, TurnSaveStep, 1, FormatTurnSaveStep);
  ValueLabel := AddOptionLabel('QuickSaveExtraSlots', LocalizedText('FormCfgSettings.QuickSaveSlots'), False);
  AddOptionSlider(ValueLabel, 0, 9, QuickSaveExtraSlots, 1, FormatInteger);
  ValueLabel := AddOptionLabel('CountFilmSave', LocalizedText('FormCfgSettings.CountFilmSave'), False);
  AddOptionSlider(ValueLabel, 1, 100, FilmHistoryLimit, 1, FormatInteger);
  ValueLabel := AddOptionLabel('ScrollSpeed', LocalizedText('FormCfgSettings.ScrollSpeed'), False);
  AddOptionSlider(ValueLabel, 1, 80, ScrollStep, 1, FormatInteger);
  ValueLabel := AddOptionLabel('BeginCalcNextTurn', LocalizedText('FormCfgSettings.BeginCalcNextTurn'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(BeginCalcNextTurn * 100.0), 1, FormatInteger);
  ValueLabel := AddOptionLabel('ChangeAutoPilot', LocalizedText('FormCfgSettings.ChangeAutoPilot'), False);
  AddOptionSlider(ValueLabel, 2, 20, ChangeAutoPilot, 1, FormatInteger);
  AddOptionLabel('DisableAutoPilot', LocalizedText('FormCfgSettings.DisableAutoPilot'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), DisableAutoPilot, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not DisableAutoPilot, False);
  BuildGroupIndex := 1;
  if AltResolutionSwitch then
  begin
    AddOptionLabel('Resolution', LocalizedText('FormCfgSettings.Resolution'), True);
    I := GameDisplayModeCount - 1;
    while I >= 0 do
    begin
      with GameDisplayModes[I] do
        if Width = 0 then AddOptionChoice(I, LocalizedText('FormCfgSettings.HelpButAuto'), SelectedGameDisplayMode = I, False)
        else AddOptionChoice(I, WideString(IntToStr(Width) + 'x' + IntToStr(Height)), SelectedGameDisplayMode = I, False);
      Dec(I);
    end;
  end
  else
  begin
    ValueLabel := AddOptionLabel('Resolution', LocalizedText('FormCfgSettings.Resolution'), False);
    AddOptionSlider(ValueLabel, 0, GameDisplayModeCount - 1, SelectedGameDisplayMode, 1, FormatResolution);
  end;
  AddOptionLabel('VSync', LocalizedText('FormCfgSettings.VSync'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), VSyncEnabled, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not VSyncEnabled, False);
  AddOptionLabel('Window', LocalizedText('FormCfgSettings.Window'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), WindowedModeRequested, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not WindowedModeRequested, False);
  if AlternateViewportEnabled then
  begin
    AddOptionLabel('RenderMode', LocalizedText('FormCfgSettings.RenderMode'), False);
    AddOptionChoice(1, LocalizedText('FormCfgSettings.RenderMode1'), ScaleViewportToWindow, False);
    AddOptionChoice(0, LocalizedText('FormCfgSettings.RenderMode2'), not ScaleViewportToWindow, False);
  end;
  if not AlternateViewportEnabled then
  begin
    AddOptionLabel('HardwareRender', LocalizedText('FormCfgSettings.HardwareRender'), False);
    AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), HardwareRenderingRequested, False);
    AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not HardwareRenderingRequested, False);
  end;
  AddOptionLabel('UseTablesForGov', LocalizedText('FormCfgSettings.UseTablesForGov'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), UseTablesForGov, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not UseTablesForGov, False);
  AddOptionLabel('FontSmooth', LocalizedText('FormCfgSettings.FontSmooth'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), FontSmoothingEnabled, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not FontSmoothingEnabled, False);
  AddOptionLabel('FontDialog', LocalizedText('FormCfgSettings.FontDialog'), True);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.FontGalaxySmall'), FontDialog = 0, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.FontSizeMid'), FontDialog = 1, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.FontSizeBig'), FontDialog = 2, False);
  AddOptionChoice(3, LocalizedText('FormCfgSettings.FontSizeLarge'), FontDialog >= 3, False);
  AddOptionLabel('FontQuest', LocalizedText('FormCfgSettings.FontQuest'), True);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.FontGalaxySmall'), FontQuest = 0, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.FontSizeMid'), FontQuest = 1, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.FontSizeBig'), FontQuest = 2, False);
  AddOptionChoice(3, LocalizedText('FormCfgSettings.FontSizeLarge'), FontQuest >= 3, False);
  ValueLabel := AddOptionLabel('Brightness', LocalizedText('FormCfgSettings.Brightness'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(DisplayBrightness * 50.0 + 50.0), 1, PreviewBrightness);
  ValueLabel := AddOptionLabel('Contrast', LocalizedText('FormCfgSettings.Contrast'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(DisplayContrast * 50.0 + 50.0), 1, PreviewContrast);
  AddOptionLabel('Intro', LocalizedText('FormCfgSettings.Intro'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), not SkipIntro, not IsInstallFeatureEnabled('Video'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), SkipIntro, False);
  AddOptionLabel('Video', LocalizedText('FormCfgSettings.Video'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), not SkipVideo, not IsInstallFeatureEnabled('Video'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), SkipVideo, False);
  AddOptionLabel('SoftwareCursor', LocalizedText('FormCfgSettings.SoftwareCursor'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.SoftwareCursorHardware'), ShowSystemMouse, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.SoftwareCursorSoftware'), not ShowSystemMouse, False);
  AddOptionLabel('BGImage', LocalizedText('FormCfgSettings.BGImage'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), BGImage, not IsInstallFeatureEnabled('BGImage'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not BGImage, False);
  AddOptionLabel('AnimCaptain', LocalizedText('FormCfgSettings.AnimCaptain'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimCaptain, not IsInstallFeatureEnabled('AnimCaptain'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimCaptain, False);
  AddOptionLabel('AnimShip', LocalizedText('FormCfgSettings.AnimShip'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.AnimShipFull'), AnimShipFull, not IsInstallFeatureEnabled('AnimShipFull'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.AnimShipSmall'), not AnimShipFull, not IsInstallFeatureEnabled('AnimShipSmall'));
  AddOptionLabel('AnimItem', LocalizedText('FormCfgSettings.AnimItem'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimItem, not IsInstallFeatureEnabled('AnimItem'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimItem, False);
  AddOptionLabel('AnimMenuShip', LocalizedText('FormCfgSettings.AnimMenuShip'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimMenuShip, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimMenuShip, False);
  AddOptionLabel('AnimGov', LocalizedText('FormCfgSettings.AnimGov'), False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.AnimGovFull'), AnimGov = 2, not IsInstallFeatureEnabled('AnimGov'));
  AddOptionChoice(1, LocalizedText('FormCfgSettings.AnimGovHalf'), AnimGov = 1, not IsInstallFeatureEnabled('AnimGov'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.AnimGovOff'), AnimGov = 0, False);
  AddOptionLabel('AnimHangar', LocalizedText('FormCfgSettings.AnimHangar'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimHangar, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimHangar, False);
  AddOptionLabel('AnimStar', LocalizedText('FormCfgSettings.AnimStar'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimStar, not IsInstallFeatureEnabled('AnimStar'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimStar, False);
  AddOptionLabel('SpaceImage', LocalizedText('FormCfgSettings.SpaceImage'), False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.CometLarge'), SpaceImage >= 2, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.CometSmall'), SpaceImage = 1, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.CometOff'), SpaceImage = 0, False);
  AddOptionLabel('SputnikShow', LocalizedText('FormCfgSettings.SputnikShow'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), SputnikShow, not IsInstallFeatureEnabled('SputnikShow'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not SputnikShow, False);
  AddOptionLabel('CircleAction', LocalizedText('FormCfgSettings.CircleAction'), False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.CircleActionNormal'), not CircleAction, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.CircleActionHide'), CircleAction, False);
  AddOptionLabel('Tail', LocalizedText('FormCfgSettings.Tails'), False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.TailAll'), ShipTail = 2, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.TailPlayer'), ShipTail = 1, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.TailOff'), ShipTail = 0, False);
  AddOptionLabel('Comet', LocalizedText('FormCfgSettings.Comet'), False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.CometLarge'), Comet >= 2, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.CometSmall'), Comet = 1, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.CometOff'), Comet = 0, False);
  AddOptionLabel('Wind', LocalizedText('FormCfgSettings.Wind'), False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.WindFull'), Wind >= 2, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.WindSmall'), Wind = 1, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.WindOff'), Wind = 0, False);
  AddOptionLabel('PlanetClouds', LocalizedText('FormCfgSettings.PlanetClouds'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), PlanetClouds, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not PlanetClouds, False);
  AddOptionLabel('PlanetAtm', LocalizedText('FormCfgSettings.PlanetAtm'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), PlanetAtm, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not PlanetAtm, False);
  AddOptionLabel('AnimChangeForm', LocalizedText('FormCfgSettings.AnimChangeForm'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimChangeForm, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimChangeForm, False);
  AddOptionLabel('AnimMainFon', LocalizedText('FormCfgSettings.AnimMainFon'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), AnimMainFon, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not AnimMainFon, False);
  AddOptionLabel('BackgroundShade', LocalizedText('FormCfgSettings.BackgroundShade'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), BackgroundShade, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not BackgroundShade, False);
  AddOptionLabel('BackgroundGrayscale', LocalizedText('FormCfgSettings.BackgroundGrayscale'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), BackgroundGrayscale, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not BackgroundGrayscale, False);
  AddOptionLabel('DynamicTipsPos', LocalizedText('FormCfgSettings.DynamicTipsPos'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), DynamicTipsPos, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not DynamicTipsPos, False);
  AddOptionLabel('ShowFPS', LocalizedText('FormCfgSettings.ShowFPS'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), ShowFrameRate, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not ShowFrameRate, False);
  AddOptionLabel('ScreenShotType', LocalizedText('FormCfgSettings.ScreenShotType'), False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.ShotBMP'), ScreenshotFormat = 0, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.ShotPNG'), ScreenshotFormat = 1, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.ShotJPG'), ScreenshotFormat = 2, False);
  ValueLabel := AddOptionLabel('ScreenShotQuality', LocalizedText('FormCfgSettings.ScreenShotQuality'), False);
  AddOptionSlider(ValueLabel, 0, 100, ScreenshotJpegQuality, 1, FormatInteger);
  AddOptionLabel('FontGalaxy', LocalizedText('FormCfgSettings.FontGalaxy'), True);
  AddOptionChoice(6, LocalizedText('FormCfgSettings.FontGalaxyNormalBold'), GalaxyMapFontChoice = gmfNormalBold, False);
  AddOptionChoice(5, LocalizedText('FormCfgSettings.FontGalaxyNormal'), GalaxyMapFontChoice = gmfNormal, False);
  AddOptionChoice(4, LocalizedText('FormCfgSettings.FontGalaxySmallBold'), GalaxyMapFontChoice = gmfSmallBold, False);
  AddOptionChoice(3, LocalizedText('FormCfgSettings.FontGalaxySmall'), GalaxyMapFontChoice = gmfSmall, False);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.FontGalaxyMini'), GalaxyMapFontChoice = gmfMini, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.FontGalaxyRanger'), GalaxyMapFontChoice = gmfRanger, False);
  BuildGroupIndex := 2;
  AddOptionLabel('Sound', LocalizedText('FormCfgSettings.Sound'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), SoundEnabled, not IsInstallFeatureEnabled('Sound'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not SoundEnabled, False);
  AddOptionLabel('SoundInSpace', LocalizedText('FormCfgSettings.SoundInSpace'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), SoundInSpaceEnabled, not IsInstallFeatureEnabled('SoundInSpace'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not SoundInSpaceEnabled, False);
  ValueLabel := AddOptionLabel('SoundVolume', LocalizedText('FormCfgSettings.SoundVolume'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(SoundVolume * 100.0), 1, FormatInteger);
  AddOptionLabel('Music', LocalizedText('FormCfgSettings.Music'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), MusicEnabled, not IsInstallFeatureEnabled('Music'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not MusicEnabled, False);
  AddOptionLabel('MusicInSpace', LocalizedText('FormCfgSettings.MusicInSpace'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), MusicInSpaceEnabled, not IsInstallFeatureEnabled('MusicInSpace'));
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not MusicInSpaceEnabled, False);
  ValueLabel := AddOptionLabel('MusicVolume', LocalizedText('FormCfgSettings.MusicVolume'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(MusicVolume * 100.0), 1, FormatInteger);
  AddOptionLabel('MusicInHyper', LocalizedText('FormCfgSettings.MusicInHyper'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), MusicInHyperEnabled, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not MusicInHyperEnabled, False);
  AddOptionLabel('MusicInPlanet', LocalizedText('FormCfgSettings.MusicInPlanet'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), MusicInPlanetEnabled, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not MusicInPlanetEnabled, False);
  BuildGroupIndex := 4;
  if AltResolutionSwitch then
  begin
    AddOptionLabel('RobotResolution', LocalizedText('FormCfgSettings.Resolution'), True);
    I := RobotDisplayModeCount - 1;
    while I >= 0 do
    begin
      with RobotDisplayModes[I] do
        if Width = 0 then AddOptionChoice(I, LocalizedText('FormCfgSettings.HelpButAuto'), SelectedRobotDisplayMode = I, False)
        else AddOptionChoice(I, WideString(IntToStr(Width) + 'x' + IntToStr(Height)), SelectedRobotDisplayMode = I, False);
      Dec(I);
    end;
  end
  else
  begin
    ValueLabel := AddOptionLabel('RobotResolution', LocalizedText('FormCfgSettings.Resolution'), False);
    AddOptionSlider(ValueLabel, 0, RobotDisplayModeCount - 1, SelectedRobotDisplayMode, 1, FormatRobotResolution);
  end;
  AddOptionLabel('RobotVSync', LocalizedText('FormCfgSettings.VSync'), False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), RobotVSync, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not RobotVSync, False);
  if SupportedMultiSampleCount > 1 then
  begin
    ValueLabel := AddOptionLabel('RobotFSAASamples', LocalizedText('FormCfgSettings.RobotFSAA'), False);
    AddOptionSlider(ValueLabel, 0, SupportedMultiSampleCount - 1, GetRobotMultiSampleIndex, 1, FormatRobotFsaaSamples);
  end;
  if Integer(MaximumAnisotropy) > 0 then
  begin
    ValueLabel := AddOptionLabel('RobotAnisotropy', LocalizedText('FormCfgSettings.RobotAnisotropy'), False);
    AddOptionSlider(ValueLabel, 0, MaximumAnisotropy, RobotAnisotropy, 1, FormatInteger);
  end;
  ValueLabel := AddOptionLabel('RobotMaxDistance', LocalizedText('FormCfgSettings.RobotMaxDistance'), False);
  AddOptionSlider(ValueLabel, 0, 100, RobotMaxDistance, 1, FormatInteger);
  ValueLabel := AddOptionLabel('RobotBrightness', LocalizedText('FormCfgSettings.Brightness'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(RobotBrightness * 50.0 + 50.0), 1, FormatInteger);
  ValueLabel := AddOptionLabel('RobotContrast', LocalizedText('FormCfgSettings.Contrast'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(RobotContrast * 50.0 + 50.0), 1, FormatInteger);
  AddOptionLabel('RobotShowStencilShadows', LocalizedText('FormCfgSettings.RobotShowStencilShadows'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RobotShowStencilShadowsOn'), RobotSettings.ShowStencilShadows, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RobotShowStencilShadowsOff'), not RobotSettings.ShowStencilShadows, False);
  AddOptionLabel('RobotShowProjShadows', LocalizedText('FormCfgSettings.RobotShowProjShadows'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RobotShowProjShadowsOn'), RobotSettings.ShowProjShadows, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RobotShowProjShadowsOff'), not RobotSettings.ShowProjShadows, False);
  AddOptionLabel('RobotRobotShadow', LocalizedText('FormCfgSettings.RobotRobotShadow'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RobotRobotShadowStencil'), RobotSettings.RobotShadow = 1, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RobotRobotShadowOff'), RobotSettings.RobotShadow = 0, False);
  AddOptionLabel('RobotSelectEx', LocalizedText('FormCfgSettings.RobotSelectEx'), True);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RobotSelectExNormal'), not RobotSettings.SelectEx, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RobotSelectExSpecial'), RobotSettings.SelectEx, False);
  AddOptionLabel('RobotLandTexturesGloss', LocalizedText('FormCfgSettings.RobotLandTexturesGloss'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), RobotSettings.LandTexturesGloss, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not RobotSettings.LandTexturesGloss, False);
  AddOptionLabel('RobotObjTexturesGloss', LocalizedText('FormCfgSettings.RobotObjTexturesGloss'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), RobotSettings.ObjTexturesGloss, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not RobotSettings.ObjTexturesGloss, False);
  AddOptionLabel('RobotSoftwareCursor', LocalizedText('FormCfgSettings.RobotSoftwareCursor'), True);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RobotSoftwareCursorHardware'), not RobotSettings.SoftwareCursor, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RobotSoftwareCursorSoftware'), RobotSettings.SoftwareCursor, False);
  AddOptionLabel('RobotSky', LocalizedText('FormCfgSettings.RobotSky'), True);
  AddOptionChoice(2, LocalizedText('FormCfgSettings.RobotSkyGood'), RobotSettings.Sky = 2, False);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.RobotSkyLow'), RobotSettings.Sky = 1, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.RobotSkyOff'), RobotSettings.Sky = 0, False);
  BuildGroupIndex := 5;
  AddOptionLabel('RobotMusic', LocalizedText('FormCfgSettings.RobotMusic'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), RobotMusic, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not RobotMusic, False);
  ValueLabel := AddOptionLabel('RobotMusicVolume', LocalizedText('FormCfgSettings.MusicVolume'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(RobotMusicVolume * 100.0), 1, FormatInteger);
  AddOptionLabel('RobotSound', LocalizedText('FormCfgSettings.RobotSound'), True);
  AddOptionChoice(1, LocalizedText('FormCfgSettings.Yes'), RobotSound, False);
  AddOptionChoice(0, LocalizedText('FormCfgSettings.No'), not RobotSound, False);
  ValueLabel := AddOptionLabel('RobotSoundVolume', LocalizedText('FormCfgSettings.SoundVolume'), False);
  AddOptionSlider(ValueLabel, 0, 100, Round(RobotSoundVolume * 100.0), 1, FormatInteger);
  BuildGroupIndex := 3;
  for I := 0 to 5 do
    with GroupPanels[I] do SetSize(Classes.Point(ClientSize.X, GroupNextY[I]));
  Panel.VerticalScrollBar.SetSmallChange((GetByName('ButGroup0') as TGraphButtonGI).CaptionLabel.GetLineHeight * 2);
  Panel.VerticalScrollBar.SetLargeChange(Panel.ClientSize.Y);
  Panel.VerticalScrollBar.SetPageSize(Panel.ClientSize.Y);
  ActiveGroupIndex := 0;
  RefreshVisibleGroup;
  RefreshModeUi;
  if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(131);
end;
{ @end $5F2E88 }

{ @routine $5F8E1C TfCfgSettings_OnClose }
procedure TfCfgSettings.OnClose;
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(132);
  if ModeLeaveTimer <> nil then
  begin
    CancelCallbackTimer(ModeLeaveTimer);
    ModeLeaveTimer := nil;
  end;
end;
{ @end $5F8E1C }

{ @routine $5F8E6C TfCfgSettings_MainPanelMouseMove }
procedure TfCfgSettings.MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Button: TGraphButtonGI; Show: Boolean;
begin
  Button := nil;
  Show := False;
  repeat
    Button := GetByName('ButAUp') as TGraphButtonGI;
    Show := Button.HitTest(Point);
    if Show then Break;
    Button := GetByName('ButAMiddle') as TGraphButtonGI;
    Show := Button.HitTest(Point);
    if Show then Break;
    Button := GetByName('ButADown') as TGraphButtonGI;
    Show := Button.HitTest(Point);
    if Show then Break;
    Button := GetByName('ButAAuto') as TGraphButtonGI;
    Show := Button.HitTest(Point);
    if Show then Break;
    Button := GetByName('Cancel') as TGraphButtonGI;
    Show := Button.HitTest(Point);
    if Show then Break;
    Button := GetByName('Ok') as TGraphButtonGI;
    Show := Button.HitTest(Point);
    if Show then Break;
  until True;
  ShowControlHelp(Button, Show);
end;
{ @end $5F8E6C }

{ @routine $5F9048 TfCfgSettings_ShowControlHelp }
procedure TfCfgSettings.ShowControlHelp(Sender: TObjectGI; Show: Boolean);
begin
  with GetByName('LabelHelp') as TLabelGI do
  begin
    if Sender.HelpText = '' then Show := False;
    SetActive(Show);
    SetText(Sender.HelpText);
  end;
end;
{ @end $5F9048 }

{ @routine $5F90BC TfCfgSettings_GroupClicked }
procedure TfCfgSettings.GroupClicked(Sender: TObjectGI);
var Group: Integer;
begin
  Group := ExtractDigitsToIntW(Sender.ControlName);
  if SettingsMode = 1 then Group := Group + 4 - 1;
  (GetByName('ButGroup0') as TGraphButtonGI).SetDown((Group = 0) or (Group = 4));
  (GetByName('ButGroup1') as TGraphButtonGI).SetDown((Group = 1) or (Group = 5));
  (GetByName('ButGroup2') as TGraphButtonGI).SetDown(Group = 2);
  (GetByName('ButGroup3') as TGraphButtonGI).SetDown(Group = 3);
  if ActiveGroupIndex <> Group then
  begin
    ActiveGroupIndex := Group;
    RefreshVisibleGroup;
    RefreshModeUi;
  end;
end;
{ @end $5F90BC }

{ @routine $5F9220 TfCfgSettings_RefreshVisibleGroup }
procedure TfCfgSettings.RefreshVisibleGroup;
var I: Integer;
begin
  with GetByName('ButGroup0') as TGraphButtonGI do SetDown(ActiveGroupIndex = 0);
  with GetByName('ButGroup1') as TGraphButtonGI do SetDown((ActiveGroupIndex = 1) or (ActiveGroupIndex = 4));
  with GetByName('ButGroup2') as TGraphButtonGI do SetDown((ActiveGroupIndex = 2) or (ActiveGroupIndex = 5));
  with GetByName('ButGroup3') as TGraphButtonGI do SetDown(ActiveGroupIndex = 3);
  for I := 0 to 5 do with GroupPanels[I] do SetActive(I = ActiveGroupIndex);
  with GetByName('PanelSet') as TPanelScrollBarGI do
  begin
    SetScrollOffset(Classes.Point(0, 0));
    UpdateScrollRanges;
    SetVerticalScrollbarEnabled(GroupNextY[ActiveGroupIndex] > ClientSize.Y);
  end;
end;
{ @end $5F9220 }

{ @routine $5F9420 TfCfgSettings_AddOptionLabel }
function TfCfgSettings.AddOptionLabel(OptionName, Caption: WideString; UnusedFlag: Boolean): TLabelGI;
begin
  CurrentOptionName := OptionName;
  if GroupNextY[BuildGroupIndex] <> 0 then
  begin
    // Native retains a zero-spacing adjustment before the separator.
    GroupNextY[BuildGroupIndex] := GroupNextY[BuildGroupIndex];
    with TImageGI.Create(GroupPanels[BuildGroupIndex]) do
    begin
      SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'Line');
      SetPosition(Classes.Point(0, GroupNextY[BuildGroupIndex]));
      SetSize(Classes.Point(GroupPanels[BuildGroupIndex].ClientSize.X, GetContentSize.Y + 2));
      Inc(GroupNextY[BuildGroupIndex], ClientSize.Y);
    end;
  end;
  Result := TLabelGI.Create(GroupPanels[BuildGroupIndex]);
  Result.SetFontName(NormalFontName);
  Result.SetPositionModeW(False);
  Result.SetPosition(Classes.Point(0, GroupNextY[BuildGroupIndex]));
  Result.SetSize(Classes.Point(GroupPanels[BuildGroupIndex].ClientSize.X, 1));
  Result.SetTextAlignX(taxLeft);
  Result.SetTextAlignY(tayAuto);
  Result.SetTextColor(CurrentPixelFormat.PackRgbBytes(205, 205, 205));
  Result.SetText(Caption + '.');
  Result.HelpText := Caption;
  Result.SetTextAlignY(tayTop);
  Result.SetSize(Classes.Point(Result.ClientSize.X, Result.ClientSize.Y + 1));
  Inc(GroupNextY[BuildGroupIndex], 2);
end;
{ @end $5F9420 }

{ @routine $5F9724 TfCfgSettings_AddOptionChoice }
procedure TfCfgSettings.AddOptionChoice(Value: Integer; Caption: WideString; Selected, Disabled: Boolean);
var Image: TImageGI; ValueLabel: TLabelGI; RightMargin: Integer;
begin
  RightMargin := GiScalePixelsEx(50, 30);
  ValueLabel := TLabelGI.Create(GroupPanels[BuildGroupIndex]);
  ValueLabel.SetFontName(NormalFontName);
  ValueLabel.SetPositionModeW(False);
  ValueLabel.SetPosition(Classes.Point(0, GroupNextY[BuildGroupIndex]));
  ValueLabel.SetSize(Classes.Point(GroupPanels[BuildGroupIndex].ClientSize.X - RightMargin, 1));
  ValueLabel.SetTextAlignX(taxRight);
  ValueLabel.SetTextAlignY(tayAuto);
  if Selected then ValueLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 234, 118))
  else ValueLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(205, 205, 205));
  ValueLabel.SetText(Caption);
  if not Disabled then
  begin
    ValueLabel.LeftButtonDownCallback := OptionChoiceMouseDown;
    ValueLabel.MouseEnterCallback := OptionChoiceMouseEnter;
    ValueLabel.MouseLeaveCallback := OptionChoiceMouseLeave;
  end;
  ValueLabel.SetTextAlignY(tayCenterEx);
  Image := TImageGI.Create(GroupPanels[BuildGroupIndex]);
  if Selected then Image.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD')
  else if Disabled then Image.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchH')
  else Image.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN');
  Image.SetPosition(Classes.Point(GroupPanels[BuildGroupIndex].ClientSize.X - Image.GetContentSize.X - RightMargin, GroupNextY[BuildGroupIndex]));
  Image.SetSize(Image.GetContentSize);
  Image.SetImageKindY(ikyCenter);
  if not Disabled then
  begin
    Image.LeftButtonDownCallback := OptionChoiceMouseDown;
    Image.MouseEnterCallback := OptionChoiceMouseEnter;
    Image.MouseLeaveCallback := OptionChoiceMouseLeave;
  end;
  if not Disabled or (CurrentOptionName = 'Lang') then Image.SetName(CurrentOptionName);
  Image.UserValue := Value;
  ValueLabel.SetSize(Classes.Point(ValueLabel.ClientSize.X - Image.ClientSize.X - 10, Max(ValueLabel.ClientSize.Y, Image.ClientSize.Y)));
  Image.SetPosition(Classes.Point(Image.LocalPosition.X, Image.LocalPosition.Y + (Max(ValueLabel.ClientSize.Y, Image.ClientSize.Y) - ValueLabel.ClientSize.Y) div 2));
  GroupNextY[BuildGroupIndex] := GroupNextY[BuildGroupIndex] + ValueLabel.ClientSize.Y + GiScalePixels(5);
  ValueLabel.UserValue := Integer(Image);
end;
{ @end $5F9724 }

{ @routine $5F9BEC TfCfgSettings_OptionChoiceMouseDown }
procedure TfCfgSettings.OptionChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Control: TObjectGI;
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  Control := GroupPanels[ActiveGroupIndex].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = Sender.ControlName then
      if Control = Sender then
        (Control as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD')
      else (Control as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN');
    Control := Control.NextSibling;
  end;
  if (Point.X <> -1000) or (Point.Y <> -1000) then SoundManager.PlaySound('Sound.ButtonClick');
end;
{ @end $5F9BEC }

{ @routine $5F9DD4 TfCfgSettings_OptionChoiceMouseEnter }
procedure TfCfgSettings.OptionChoiceMouseEnter(Sender: TObjectGI);
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  if (Sender as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN' then
    (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA');
end;
{ @end $5F9DD4 }

{ @routine $5F9F10 TfCfgSettings_OptionChoiceMouseLeave }
procedure TfCfgSettings.OptionChoiceMouseLeave(Sender: TObjectGI);
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  if (Sender as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA' then
    (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN');
end;
{ @end $5F9F10 }

{ @routine $5FA04C TfCfgSettings_AddOptionSlider }
procedure TfCfgSettings.AddOptionSlider(ValueLabel: TLabelGI; Minimum, Maximum, Position, UnusedStep: Integer; Callback: TOptionSliderEvent);
var Slider: TCountBarGI;
begin
  Slider := TCountBarGI.Create(GroupPanels[BuildGroupIndex]);
  GroupNextY[BuildGroupIndex] := GroupNextY[BuildGroupIndex];
  Slider.SetPositionModeW(False);
  if GiResourceVariant = 2 then Slider.SetSize(Classes.Point(199, 20))
  else Slider.SetSize(Classes.Point(156, 20));
  TObjectGI(Slider).SetPosition(Classes.Point(GroupPanels[BuildGroupIndex].ClientSize.X - Slider.ClientSize.X, GroupNextY[BuildGroupIndex]));
  Slider.DecreaseButton.SetKind(gbkDisable);
  Slider.DecreaseButton.SetImageNormalPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeftN');
  Slider.DecreaseButton.SetImageNormalActivePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeftA');
  Slider.DecreaseButton.SetImageDownPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeftD');
  Slider.DecreaseButton.SetImageDisabledPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeftH');
  Slider.DecreaseButton.EnterSound := 'Sound.ButtonEnter';
  Slider.DecreaseButton.LeaveSound := 'Sound.ButtonLeave';
  Slider.DecreaseButton.ClickSound := 'Sound.ButtonClick';
  Slider.IncreaseButton.SetKind(gbkDisable);
  Slider.IncreaseButton.SetImageNormalPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRightN');
  Slider.IncreaseButton.SetImageNormalActivePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRightA');
  Slider.IncreaseButton.SetImageDownPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRightD');
  Slider.IncreaseButton.SetImageDisabledPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRightH');
  Slider.IncreaseButton.EnterSound := 'Sound.ButtonEnter';
  Slider.IncreaseButton.LeaveSound := 'Sound.ButtonLeave';
  Slider.IncreaseButton.ClickSound := 'Sound.ButtonClick';
  Slider.MarkerImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackUp');
  Slider.MarkerImage.SetSize(Slider.MarkerImage.GetContentSize);
  Slider.MarkerImage.SetOrigin(HalfPoint(Slider.MarkerImage.ClientSize));
  Slider.AfterThumbImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackLeft');
  Slider.BeforeThumbImage.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackRight');
  Slider.ThumbButton.SetImageNormalPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Slider.ThumbButton.SetImageNormalActivePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Slider.ThumbButton.SetImageDownPath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'TrackPol');
  Slider.PositionChangedCallback := TObjectNotifyEventGI(Callback);
  Slider.UpdateLayout;
  Slider.SetRange(Minimum, Maximum);
  Slider.SetPositionInternal(Position);
  Slider.SetName(CurrentOptionName);
  Slider.UserIndex := Integer(ValueLabel);
  GroupNextY[BuildGroupIndex] := GroupNextY[BuildGroupIndex] + Slider.ClientSize.Y + GiScalePixels(6);
  Callback(Slider);
end;
{ @end $5FA04C }

{ @routine $5FA7C4 TfCfgSettings_HasOptionValue }
function TfCfgSettings.HasOptionValue(OptionName: WideString): Boolean;
var Control: TObjectGI;
begin
  Control := GroupPanels[ActiveGroupIndex].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = OptionName then
      if Control is TImageGI then
      begin
        if (Control as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD' then
        begin
          Result := True;
          Exit;
        end;
      end
      else if Control is TCountBarGI then
      begin
        Result := True;
        Exit;
      end;
    Control := Control.NextSibling;
  end;
  Result := False;
end;
{ @end $5FA7C4 }

{ @routine $5FA924 TfCfgSettings_GetOptionValue }
function TfCfgSettings.GetOptionValue(OptionName: WideString): Integer;
var Control: TObjectGI;
begin
  Result := 0;
  Control := GroupPanels[ActiveGroupIndex].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = OptionName then
      if Control is TImageGI then
      begin
        if (Control as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD' then
        begin
          Result := Control.UserValue;
          Exit;
        end;
      end
      else if Control is TCountBarGI then
      begin
        Result := (Control as TCountBarGI).Position;
        Exit;
      end;
    Control := Control.NextSibling;
  end;
  RaiseWideMessage('UnitGet Type=' + OptionName);
end;
{ @end $5FA924 }

{ @routine $5FAAE0 TfCfgSettings_SetOptionValue }
procedure TfCfgSettings.SetOptionValue(OptionName: WideString; Value: Integer);
var Control: TObjectGI;
begin
  Control := GroupPanels[ActiveGroupIndex].FirstChild;
  while Control <> nil do
  begin
    if Control.ControlName = OptionName then
    begin
      if (Control is TImageGI) and (Control.UserValue = Value) and Assigned(Control.LeftButtonDownCallback) then
      begin
        OptionChoiceMouseDown(Control, 0, Classes.Point(-1000, -1000));
        Break;
      end
      else if Control is TCountBarGI then
      begin
        (Control as TCountBarGI).SetPosition(Value);
        Break;
      end;
    end;
    Control := Control.NextSibling;
  end;
end;
{ @end $5FAAE0 }

{ @routine $5FABE8 TfCfgSettings_FormatResolution }
procedure TfCfgSettings.FormatResolution(Sender: TCountBarGI);
var Index: Integer; ValueLabel: TLabelGI;
begin
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    Index := Sender.Position;
    if GameDisplayModes[Index].Width = 0 then
      ValueLabel.SetText(ValueLabel.HelpText + '<color=255,240,100>' + ' ' + LocalizedText('FormCfgSettings.HelpAuto') + '</color>')
    else ValueLabel.SetText(ValueLabel.HelpText + '<color=255,240,100>' + ' ' + WideString(IntToStr(GameDisplayModes[Index].Width)) + 'x' + WideString(IntToStr(GameDisplayModes[Index].Height)) + '</color>');
  end;
end;
{ @end $5FABE8 }

{ @routine $5FADDC TfCfgSettings_FormatRobotResolution }
procedure TfCfgSettings.FormatRobotResolution(Sender: TCountBarGI);
var Index: Integer; ValueLabel: TLabelGI;
begin
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    Index := Sender.Position;
    if RobotDisplayModes[Index].Width = 0 then
      ValueLabel.SetText(ValueLabel.HelpText + '<color=255,240,100>' + ' ' + LocalizedText('FormCfgSettings.HelpAuto') + '</color>')
    else ValueLabel.SetText(ValueLabel.HelpText + '<color=255,240,100>' + ' ' + WideString(IntToStr(RobotDisplayModes[Index].Width)) + 'x' + WideString(IntToStr(RobotDisplayModes[Index].Height)) + '</color>');
  end;
end;
{ @end $5FADDC }

{ @routine $5FAFD0 TfCfgSettings_FormatRobotFsaaSamples }
procedure TfCfgSettings.FormatRobotFsaaSamples(Sender: TCountBarGI);
var Index: Integer; ValueLabel: TLabelGI;
begin
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    Index := Sender.Position;
    ValueLabel.SetText(ReplaceColoredToken(ValueLabel.HelpText, '<Value>', WideString(IntToStr(SupportedMultiSamples[Index])), '<color=255,240,100>'));
  end;
end;
{ @end $5FAFD0 }

{ @routine $5FB0D0 TfCfgSettings_PreviewBrightness }
procedure TfCfgSettings.PreviewBrightness(Sender: TCountBarGI);
var ValueLabel: TLabelGI;
begin
  if HasOptionValue('Contrast') and HasOptionValue('Brightness') then
  begin
    ApplyGammaRamp((GetOptionValue('Brightness') - 50) / 50.0, (GetOptionValue('Contrast') - 50) / 50.0);
  end;
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    ValueLabel.SetText(ReplaceColoredToken(ValueLabel.HelpText, '<Value>', WideString(IntToStr(Sender.Position)), '<color=255,240,100>'));
  end;
end;
{ @end $5FB0D0 }

{ @routine $5FB264 TfCfgSettings_PreviewContrast }
procedure TfCfgSettings.PreviewContrast(Sender: TCountBarGI);
var ValueLabel: TLabelGI;
begin
  if HasOptionValue('Contrast') and HasOptionValue('Brightness') then
  begin
    ApplyGammaRamp((GetOptionValue('Brightness') - 50) / 50.0, (GetOptionValue('Contrast') - 50) / 50.0);
  end;
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    ValueLabel.SetText(ReplaceColoredToken(ValueLabel.HelpText, '<Value>', WideString(IntToStr(Sender.Position)), '<color=255,240,100>'));
  end;
end;
{ @end $5FB264 }

{ @routine $5FB3F8 TfCfgSettings_FormatInteger }
procedure TfCfgSettings.FormatInteger(Sender: TCountBarGI);
var ValueLabel: TLabelGI;
begin
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    ValueLabel.SetText(ReplaceColoredToken(ValueLabel.HelpText, '<Value>', WideString(IntToStr(Sender.Position)), '<color=255,240,100>'));
  end;
end;
{ @end $5FB3F8 }

{ @routine $5FB4E8 TfCfgSettings_FormatTurnSaveStep }
procedure TfCfgSettings.FormatTurnSaveStep(Sender: TCountBarGI);
var Value: Integer; Text: WideString; ValueLabel: TLabelGI;
begin
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    Value := Sender.Position;
    if Value = 0 then Text := LocalizedText('FormCfgSettings.TurnSaveStepNever')
    else if Value = 1 then Text := LocalizedText('FormCfgSettings.TurnSaveStep1')
    else if (Value >= 2) and (Value <= 4) then
      Text := ReplaceColoredToken(LocalizedText('FormCfgSettings.TurnSaveStep2'), '<Value>', WideString(IntToStr(Value)), '<color=255,240,100>')
    else Text := ReplaceColoredToken(LocalizedText('FormCfgSettings.TurnSaveStep3'), '<Value>', WideString(IntToStr(Value)), '<color=255,240,100>');
    ValueLabel.SetText(ReplaceColoredToken(ValueLabel.HelpText, '<Text>', Text, '<color=255,240,100>'));
  end;
end;
{ @end $5FB4E8 }

{ @routine $5FB7C4 TfCfgSettings_FormatForsageDeactivatePercent }
procedure TfCfgSettings.FormatForsageDeactivatePercent(Sender: TCountBarGI);
var Value: Integer; Text: WideString; ValueLabel: TLabelGI;
begin
  if Sender.UserIndex <> 0 then
  begin
    ValueLabel := TLabelGI(Sender.UserIndex);
    Value := Sender.Position;
    if Value <= 0 then Text := LocalizedText('FormCfgSettings.ForsageTurnOffNever')
    else if Value < 100 then
      Text := ReplaceColoredToken(LocalizedText('FormCfgSettings.ForsageTurnOffStep'), '<Value>', WideString(IntToStr(100 - Value)), '<color=255,240,100>')
    else Text := LocalizedText('FormCfgSettings.ForsageTurnOffAlways');
    ValueLabel.SetText(ReplaceColoredToken(ValueLabel.HelpText, '<Text>', Text, '<color=255,240,100>'));
  end;
end;
{ @end $5FB7C4 }

{ @routine $5FBA20 TfCfgSettings_HighPresetClicked }
procedure TfCfgSettings.HighPresetClicked(Sender: TObjectGI);
var SavedGroup: Integer;
begin
  SavedGroup := ActiveGroupIndex;
  ActiveGroupIndex := 0;
  SetOptionValue('CountFilmSave', 30);
  SetOptionValue('ScrollSpeed', 20);
  SetOptionValue('ScrollSense', 1);
  SetOptionValue('FilmSpeed', 2);
  SetOptionValue('BeginCalcNextTurn', 100);
  ActiveGroupIndex := 1;
  SetOptionValue('Resolution', 2);
  SetOptionValue('Brightness', 50);
  SetOptionValue('Contrast', 50);
  SetOptionValue('Video', 1);
  SetOptionValue('BGImage', 1);
  SetOptionValue('AnimCaptain', 1);
  SetOptionValue('AnimShip', 1);
  SetOptionValue('AnimItem', 1);
  SetOptionValue('AnimMenuShip', 1);
  SetOptionValue('AnimGov', 2);
  SetOptionValue('AnimHangar', 1);
  SetOptionValue('AnimStar', 1);
  SetOptionValue('SpaceImage', 2);
  SetOptionValue('SputnikShow', 1);
  SetOptionValue('CircleAction', 0);
  SetOptionValue('Tail', 2);
  SetOptionValue('Comet', 2);
  SetOptionValue('Wind', 2);
  SetOptionValue('PlanetClouds', 1);
  SetOptionValue('PlanetAtm', 1);
  SetOptionValue('AnimChangeForm', 1);
  SetOptionValue('AnimMainFon', 1);
  ActiveGroupIndex := 2;
  SetOptionValue('Sound', 1);
  SetOptionValue('SoundInSpace', 1);
  SetOptionValue('SoundVolume', 100);
  SetOptionValue('Music', 1);
  SetOptionValue('MusicInSpace', 1);
  SetOptionValue('MusicVolume', 75);
  ActiveGroupIndex := 4;
  SetOptionValue('RobotBrightness', 50);
  SetOptionValue('RobotContrast', 50);
  SetOptionValue('RobotShowStencilShadows', 1);
  SetOptionValue('RobotShowProjShadows', 1);
  SetOptionValue('RobotRobotShadow', 1);
  SetOptionValue('RobotLandTexturesGloss', 1);
  SetOptionValue('RobotObjTexturesGloss', 1);
  SetOptionValue('RobotSky', 2);
  ActiveGroupIndex := 5;
  SetOptionValue('RobotSound', 1);
  SetOptionValue('RobotSoundVolume', 100);
  SetOptionValue('RobotMusic', 1);
  SetOptionValue('RobotMusicVolume', 75);
  ActiveGroupIndex := SavedGroup;
  ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormCfgSettings.AutoMax'), mbgOK or mbgUnused04);
end;
{ @end $5FBA20 }

{ @routine $5FC364 TfCfgSettings_MediumPresetClicked }
procedure TfCfgSettings.MediumPresetClicked(Sender: TObjectGI);
var SavedGroup: Integer;
begin
  SavedGroup := ActiveGroupIndex;
  ActiveGroupIndex := 0;
  SetOptionValue('CountFilmSave', 20);
  SetOptionValue('ScrollSpeed', 20);
  SetOptionValue('ScrollSense', 1);
  SetOptionValue('FilmSpeed', 1);
  SetOptionValue('BeginCalcNextTurn', 100);
  ActiveGroupIndex := 1;
  SetOptionValue('Brightness', 50);
  SetOptionValue('Contrast', 50);
  SetOptionValue('Video', 1);
  SetOptionValue('BGImage', 1);
  SetOptionValue('AnimCaptain', 1);
  SetOptionValue('AnimShip', 1);
  SetOptionValue('AnimItem', 1);
  SetOptionValue('AnimHangar', 1);
  SetOptionValue('AnimMenuShip', 1);
  SetOptionValue('AnimGov', 1);
  SetOptionValue('AnimHangar', 1);
  SetOptionValue('AnimStar', 1);
  SetOptionValue('SpaceImage', 1);
  SetOptionValue('SputnikShow', 1);
  SetOptionValue('CircleAction', 0);
  SetOptionValue('Tail', 1);
  SetOptionValue('Comet', 1);
  SetOptionValue('Wind', 1);
  SetOptionValue('PlanetClouds', 0);
  SetOptionValue('PlanetAtm', 0);
  SetOptionValue('AnimChangeForm', 0);
  SetOptionValue('AnimMainFon', 0);
  ActiveGroupIndex := 2;
  SetOptionValue('Sound', 1);
  SetOptionValue('SoundInSpace', 1);
  SetOptionValue('SoundVolume', 100);
  SetOptionValue('Music', 1);
  SetOptionValue('MusicInSpace', 1);
  SetOptionValue('MusicVolume', 75);
  ActiveGroupIndex := 4;
  SetOptionValue('RobotBrightness', 50);
  SetOptionValue('RobotContrast', 50);
  SetOptionValue('RobotShowStencilShadows', 0);
  SetOptionValue('RobotShowProjShadows', 1);
  SetOptionValue('RobotRobotShadow', 0);
  SetOptionValue('RobotLandTexturesGloss', 0);
  SetOptionValue('RobotObjTexturesGloss', 0);
  SetOptionValue('RobotSky', 1);
  ActiveGroupIndex := 5;
  SetOptionValue('RobotSound', 1);
  SetOptionValue('RobotSoundVolume', 100);
  SetOptionValue('RobotMusic', 1);
  SetOptionValue('RobotMusicVolume', 75);
  ActiveGroupIndex := SavedGroup;
  ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormCfgSettings.AutoMiddle'), mbgOK or mbgUnused04);
end;
{ @end $5FC364 }

{ @routine $5FCC7C TfCfgSettings_LowPresetClicked }
procedure TfCfgSettings.LowPresetClicked(Sender: TObjectGI);
var SavedGroup: Integer;
begin
  SavedGroup := ActiveGroupIndex;
  ActiveGroupIndex := 0;
  SetOptionValue('CountFilmSave', 1);
  SetOptionValue('ScrollSpeed', 20);
  SetOptionValue('ScrollSense', 1);
  SetOptionValue('FilmSpeed', 0);
  SetOptionValue('BeginCalcNextTurn', 0);
  ActiveGroupIndex := 1;
  SetOptionValue('Resolution', 1);
  SetOptionValue('Brightness', 50);
  SetOptionValue('Contrast', 50);
  SetOptionValue('Video', 0);
  SetOptionValue('BGImage', 0);
  SetOptionValue('AnimCaptain', 0);
  SetOptionValue('AnimShip', 0);
  SetOptionValue('AnimItem', 0);
  SetOptionValue('AnimMenuShip', 0);
  SetOptionValue('AnimGov', 0);
  SetOptionValue('AnimHangar', 0);
  SetOptionValue('AnimStar', 0);
  SetOptionValue('SpaceImage', 0);
  SetOptionValue('SputnikShow', 0);
  SetOptionValue('CircleAction', 0);
  SetOptionValue('Tail', 0);
  SetOptionValue('Comet', 0);
  SetOptionValue('Wind', 0);
  SetOptionValue('PlanetClouds', 0);
  SetOptionValue('PlanetAtm', 0);
  SetOptionValue('AnimChangeForm', 0);
  SetOptionValue('AnimMainFon', 0);
  ActiveGroupIndex := 2;
  SetOptionValue('Sound', 0);
  SetOptionValue('SoundInSpace', 0);
  SetOptionValue('SoundVolume', 100);
  SetOptionValue('Music', 0);
  SetOptionValue('MusicInSpace', 0);
  SetOptionValue('MusicVolume', 75);
  ActiveGroupIndex := 4;
  SetOptionValue('RobotBrightness', 50);
  SetOptionValue('RobotContrast', 50);
  SetOptionValue('RobotShowStencilShadows', 0);
  SetOptionValue('RobotShowProjShadows', 0);
  SetOptionValue('RobotRobotShadow', 0);
  SetOptionValue('RobotLandTexturesGloss', 0);
  SetOptionValue('RobotObjTexturesGloss', 0);
  SetOptionValue('RobotSky', 0);
  ActiveGroupIndex := 5;
  SetOptionValue('RobotSound', 0);
  SetOptionValue('RobotSoundVolume', 100);
  SetOptionValue('RobotMusic', 0);
  SetOptionValue('RobotMusicVolume', 75);
  ActiveGroupIndex := SavedGroup;
  ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormCfgSettings.AutoMin'), mbgOK or mbgUnused04);
end;
{ @end $5FCC7C }

{ @routine $5FD560 TfCfgSettings_AutoPresetClicked }
procedure TfCfgSettings.AutoPresetClicked(Sender: TObjectGI);
var SavedGroup, ClockMHz, MemoryMB: Integer; ModernWindows: Boolean;
  Memory: TMemoryStatus;
  Version: TOSVersionInfo;
begin
  ClockMHz := Round(Min(Min(EstimateCpuClockMHz, EstimateCpuClockMHz), EstimateCpuClockMHz));
  FillChar(Memory, SizeOf(Memory), 0);
  Memory.dwLength := SizeOf(Memory);
  GlobalMemoryStatus(Memory);
  MemoryMB := Memory.dwTotalPhys shr 20;
  FillChar(Version, SizeOf(Version), 0);
  Version.dwOSVersionInfoSize := SizeOf(Version);
  GetVersionEx(Version);
  ModernWindows := (Version.dwMajorVersion > 5) or ((Version.dwMajorVersion = 5) and (Version.dwMinorVersion >= 1));
  SavedGroup := ActiveGroupIndex;
  ActiveGroupIndex := 0;
  SetOptionValue('CountFilmSave', 30);
  SetOptionValue('ScrollSpeed', 20);
  SetOptionValue('ScrollSense', 1);
  if (ClockMHz < 1000) then
  begin
    SetOptionValue('FilmSpeed', 0);
  end
  else if (ClockMHz < 2000) then
  begin
    SetOptionValue('FilmSpeed', 1);
  end
  else
  begin
    SetOptionValue('FilmSpeed', 2);
  end;
  SetOptionValue('BeginCalcNextTurn', 100);
  ActiveGroupIndex := 1;
  SetOptionValue('Resolution', 2);
  SetOptionValue('Brightness', 50);
  SetOptionValue('Contrast', 50);
  SetOptionValue('Video', Ord(ClockMHz >= 500));
  SetOptionValue('BGImage', 1);
  SetOptionValue('AnimCaptain', Ord(ClockMHz >= 500));
  SetOptionValue('AnimShip', 1);
  SetOptionValue('AnimItem', Ord(ClockMHz >= 300));
  if ((ClockMHz < 700) or (MemoryMB < 200)) then
  begin
    SetOptionValue('AnimGov', 0);
  end
  else if ((ClockMHz < 1500) or ((MemoryMB < 300) and (ClockMHz < 2400))) then
  begin
    SetOptionValue('AnimGov', 1);
  end
  else
  begin
    SetOptionValue('AnimGov', 2);
  end;
  if ((ClockMHz < 1500) or ((MemoryMB < 300) and (ClockMHz < 2400))) then
  begin
    SetOptionValue('AnimMenuShip', 0);
  end
  else
  begin
    SetOptionValue('AnimMenuShip', 1);
  end;
  SetOptionValue('SoftwareCursor', Ord(ModernWindows));
  SetOptionValue('AnimHangar', Ord((ClockMHz >= 2000) or ((ClockMHz >= 1400) and (MemoryMB > 500))));
  SetOptionValue('AnimStar', Ord(ClockMHz >= 500));
  if (ClockMHz < 500) then
  begin
    SetOptionValue('SpaceImage', 0);
  end
  else if (ClockMHz < 1900) then
  begin
    SetOptionValue('SpaceImage', 1);
  end
  else
  begin
    SetOptionValue('SpaceImage', 2);
  end;
  SetOptionValue('SputnikShow', Ord(ClockMHz >= 500));
  SetOptionValue('CircleAction', 0);
  if (ClockMHz < 500) then
  begin
    SetOptionValue('Tail', 0);
  end
  else if (ClockMHz < 1000) then
  begin
    SetOptionValue('Tail', 1);
  end
  else
  begin
    SetOptionValue('Tail', 2);
  end;
  if (ClockMHz < 500) then
  begin
    SetOptionValue('Comet', 0);
  end
  else if (ClockMHz < 1000) then
  begin
    SetOptionValue('Comet', 1);
  end
  else
  begin
    SetOptionValue('Comet', 2);
  end;
  if (ClockMHz < 500) then
  begin
    SetOptionValue('Wind', 0);
  end
  else if (ClockMHz < 1000) then
  begin
    SetOptionValue('Wind', 1);
  end
  else
  begin
    SetOptionValue('Wind', 2);
  end;
  SetOptionValue('PlanetClouds', Ord(ClockMHz >= 1900));
  SetOptionValue('PlanetAtm', Ord(ClockMHz >= 1900));
  SetOptionValue('AnimChangeForm', Ord(ClockMHz >= 1900));
  SetOptionValue('AnimMainFon', Ord(ClockMHz >= 1500));
  ActiveGroupIndex := 2;
  SetOptionValue('Sound', Ord(ClockMHz >= 200));
  SetOptionValue('SoundInSpace', Ord(ClockMHz >= 200));
  SetOptionValue('SoundVolume', 100);
  SetOptionValue('Music', Ord(ClockMHz >= 400));
  SetOptionValue('MusicInSpace', Ord(ClockMHz >= 400));
  SetOptionValue('MusicVolume', 75);
  ActiveGroupIndex := 4;
  SetOptionValue('RobotBrightness', 50);
  SetOptionValue('RobotContrast', 50);
  SetOptionValue('RobotShowStencilShadows', Ord(ClockMHz >= 2400));
  SetOptionValue('RobotShowProjShadows', Ord(ClockMHz >= 2000));
  SetOptionValue('RobotRobotShadow', Ord(ClockMHz >= 2400));
  SetOptionValue('RobotLandTexturesGloss', Ord(ClockMHz >= 2000));
  SetOptionValue('RobotObjTexturesGloss', Ord(ClockMHz >= 2000));
  if (ClockMHz >= 2000) then
  begin
    SetOptionValue('RobotSky', 2);
  end
  else if (ClockMHz >= 1000) then
  begin
    SetOptionValue('RobotSky', 1);
  end
  else
  begin
    SetOptionValue('RobotSky', 0);
  end;
  SetOptionValue('RobotSoftwareCursor', Ord(not ModernWindows));
  ActiveGroupIndex := 5;
  SetOptionValue('RobotSound', Ord(ClockMHz >= 700));
  SetOptionValue('RobotSoundVolume', 100);
  SetOptionValue('RobotMusic', Ord(ClockMHz >= 1500));
  SetOptionValue('RobotMusicVolume', 75);
  ActiveGroupIndex := SavedGroup;
  ShowMessageBoxGI(Self, LookupLocalizedTextByKey('FormCfgSettings.Auto'), mbgOK or mbgUnused04);
end;
{ @end $5FD560 }

{ @routine $5FE294 TfCfgSettings_CancelClicked }
procedure TfCfgSettings.CancelClicked(Sender: TObjectGI);
begin
  RequestedScreenId := SettingsReturnScreenId;
  RequestClose(1);
end;
{ @end $5FE294 }

{ @routine $5FE2C0 TfCfgSettings_RefreshModeUi }
procedure TfCfgSettings.RefreshModeUi;
begin
  if SettingsMode = 0 then
  begin
    with GetByName('WarningMod') as TLabelGI do
    begin
      SetText('');
      if ActiveGroupIndex = 3 then SetText(LocalizedText('FormCfgSettings.WarningMod'));
    end;
    with GetByName('Warning') as TLabelGI do SetText('');
    with GetByName('ButGroup0') as TGraphButtonGI do
    begin
      SetActive(True);
      SetPosition(Classes.Point(LocalPosition.X, GroupButtonTops[0]));
    end;
    with GetByName('ButGroup1') as TGraphButtonGI do
    begin
      SetPosition(Classes.Point(LocalPosition.X, GroupButtonTops[1]));
    end;
    with GetByName('ButGroup2') as TGraphButtonGI do
    begin
      SetPosition(Classes.Point(LocalPosition.X, GroupButtonTops[2]));
    end;
    with GetByName('ButGroup3') as TGraphButtonGI do
    begin
      SetActive(False);
      SetPosition(Classes.Point(LocalPosition.X, GroupButtonTops[3]));
    end;
    GetByName('ModeLeft').SetActive(True);
    GetByName('ModeRight').SetActive(False);
    GetByName('ModeLeftPanel').SetDepth(-1);
    GetByName('ModeRightPanel').SetDepth(-3);
    GetByName('ModeLeftSmall').SetActive(True);
    GetByName('ModeRightSmall').SetActive(False);
    GetByName('ModeLeftButtonN').SetActive(ModeButtonState < 2);
    GetByName('ModeLeftButtonD').SetActive(ModeButtonState >= 2);
    GetByName('ModeRightButtonN').SetActive(True);
    GetByName('ModeRightButtonD').SetActive(False);
    if ModeButtonState <> 0 then GetByName('ModeLeftPanel').SetPosition(ModeLeftPosition)
    else GetByName('ModeLeftPanel').SetPosition(AddPoints(ModeLeftPosition, Classes.Point(-1, 4)));
    with GetByName('ModeLeftName') as TLabelGI do
      if ModeButtonState = 1 then
      begin
        SetTextColor(SettingsModeColorHighlighted);
        SetShadowOffset(0);
      end
      else
      begin
        SetTextColor(SettingsModeColorNormal);
        SetShadowOffset(1);
      end;
    with GetByName('ModeRightName') as TLabelGI do
    begin
      SetTextColor(SettingsModeColorNormal);
      SetShadowOffset(1);
    end;
    GetByName('ModeRightPanel').SetPosition(ModeRightPosition);
  end
  else
  begin
    with GetByName('WarningMod') as TLabelGI do SetText('');
    with GetByName('Warning') as TLabelGI do
    begin
      SetText('');
      CreateEmbeddedControl := CreateWarningImage;
      if RobotAvailability = 1 then SetText(WideString('<Object=0,' + IntToStr(GiScalePixels(26)) + ',' + IntToStr(GiScalePixelsEx(24, 18)) + ',0>') + LocalizedText('FormCfgSettings.WarningNoDX9'))
      else if RobotAvailability = 2 then SetText(WideString('<Object=0,' + IntToStr(GiScalePixels(26)) + ',' + IntToStr(GiScalePixelsEx(24, 18)) + ',0>') + LocalizedText('FormCfgSettings.WarningDriverOld'))
      else if RobotAvailability = 3 then SetText(WideString('<Object=0,' + IntToStr(GiScalePixels(26)) + ',' + IntToStr(GiScalePixelsEx(24, 18)) + ',0>') + LocalizedText('FormCfgSettings.WarningVideoUnsupported'))
      else if RobotAvailability = 4 then SetText(WideString('<Object=0,' + IntToStr(GiScalePixels(26)) + ',' + IntToStr(GiScalePixelsEx(24, 18)) + ',0>') + LocalizedText('FormCfgSettings.WarningNoInstall'));
    end;
    with GetByName('ButGroup0') as TGraphButtonGI do SetActive(False);
    with GetByName('ButGroup1') as TGraphButtonGI do SetPosition(Classes.Point(LocalPosition.X, GroupButtonTops[0]));
    with GetByName('ButGroup2') as TGraphButtonGI do SetPosition(Classes.Point(LocalPosition.X, GroupButtonTops[1]));
    with GetByName('ButGroup3') as TGraphButtonGI do SetActive(False);
    GetByName('ModeLeft').SetActive(False);
    GetByName('ModeRight').SetActive(True);
    GetByName('ModeLeftPanel').SetDepth(-3);
    GetByName('ModeRightPanel').SetDepth(-1);
    GetByName('ModeLeftSmall').SetActive(False);
    GetByName('ModeRightSmall').SetActive(True);
    GetByName('ModeLeftButtonN').SetActive(True);
    GetByName('ModeLeftButtonD').SetActive(False);
    GetByName('ModeRightButtonN').SetActive(ModeButtonState < 2);
    GetByName('ModeRightButtonD').SetActive(ModeButtonState >= 2);
    if ModeButtonState <> 0 then GetByName('ModeRightPanel').SetPosition(ModeRightPosition)
    else GetByName('ModeRightPanel').SetPosition(AddPoints(ModeRightPosition, Classes.Point(1, 4)));
    with GetByName('ModeRightName') as TLabelGI do
      if ModeButtonState = 1 then
      begin
        SetTextColor(SettingsModeColorHighlighted);
        SetShadowOffset(0);
      end
      else
      begin
        SetTextColor(SettingsModeColorNormal);
        SetShadowOffset(1);
      end;
    with GetByName('ModeLeftName') as TLabelGI do
    begin
      SetTextColor(SettingsModeColorNormal);
      SetShadowOffset(1);
    end;
    GetByName('ModeLeftPanel').SetPosition(ModeLeftPosition);
  end;
end;
{ @end $5FE2C0 }

{ @routine $5FF048 TfCfgSettings_ModeMouseEnter }
procedure TfCfgSettings.ModeMouseEnter(Sender: TObjectGI);
begin
  if ModeLeaveTimer <> nil then
  begin
    CancelCallbackTimer(ModeLeaveTimer);
    ModeLeaveTimer := nil;
  end;
  if Sender.UserValue = SettingsMode then
  begin
    if ModeButtonState <> 1 then SoundManager.PlaySound('Sound.ButtonEnter');
    ModeButtonState := 1;
  end;
  RefreshModeUi;
end;
{ @end $5FF048 }

{ @routine $5FF0F0 TfCfgSettings_ModeMouseLeave }
procedure TfCfgSettings.ModeMouseLeave(Sender: TObjectGI);
begin
  if ModeLeaveTimer <> nil then
  begin
    CancelCallbackTimer(ModeLeaveTimer);
    ModeLeaveTimer := nil;
  end;
  ModeLeaveTimer := ScheduleCallbackTimer(20, 20, ModeLeaveTimerTick, Sender.UserValue);
end;
{ @end $5FF0F0 }

{ @routine $5FF158 TfCfgSettings_ModeLeaveTimerTick }
procedure TfCfgSettings.ModeLeaveTimerTick(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if ModeLeaveTimer <> nil then
  begin
    CancelCallbackTimer(ModeLeaveTimer);
    ModeLeaveTimer := nil;
  end;
  if UserData = SettingsMode then
  begin
    if ModeButtonState <> 0 then SoundManager.PlaySound('Sound.ButtonLeave');
    ModeButtonState := 0;
  end;
  RefreshModeUi;
end;
{ @end $5FF158 }

{ @routine $5FF1FC TfCfgSettings_ModeMouseDown }
procedure TfCfgSettings.ModeMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if Sender.UserValue = SettingsMode then
  begin
    if ModeButtonState <> 2 then SoundManager.PlaySound('Sound.ButtonClick');
    ModeButtonState := 2;
  end;
  RefreshModeUi;
end;
{ @end $5FF1FC }

{ @routine $5FF28C TfCfgSettings_ModeMouseUp }
procedure TfCfgSettings.ModeMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if Sender.UserValue = SettingsMode then
  begin
    if SettingsMode = 0 then SettingsMode := 1 else SettingsMode := 0;
    ModeButtonState := 0;
  end;
  RefreshModeUi;
  if SettingsMode = 0 then
  begin
    ActiveGroupIndex := 0;
    RefreshVisibleGroup;
  end
  else
  begin
    ActiveGroupIndex := 4;
    RefreshVisibleGroup;
  end;
end;
{ @end $5FF28C }

{ @routine $5FF330 TfCfgSettings_MainPanelKeyDown }
procedure TfCfgSettings.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_ESCAPE then CancelClicked(nil)
  else if Key = VK_RETURN then ApplyClicked(nil);
end;
{ @end $5FF330 }

{ @routine $5FF368 TfCfgSettings_ProcessMouseWheel }
procedure TfCfgSettings.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  with GetByName('PanelSet') as TPanelScrollBarGI do
    if Delta = WHEEL_DELTA then VerticalScrollBar.SetPosition(VerticalScrollBar.Position - VerticalScrollBar.SmallChange)
    else if Delta = -WHEEL_DELTA then VerticalScrollBar.SetPosition(VerticalScrollBar.Position + VerticalScrollBar.SmallChange);
end;
{ @end $5FF368 }

{ @routine $5FF420 TfCfgSettings_ApplyClicked }
{$I-}
procedure TfCfgSettings.ApplyClicked(Sender: TObjectGI);
var
  RestartNeeded, ResetNeeded: Boolean;
  Index: Integer;
  Text: WideString;
  Buffer: TSoundBuffer;
  Language: WideString;
  LanguageFile: TextFile;
begin
  RestartNeeded := False;
  ResetNeeded := False;
  ActiveGroupIndex := 0;
  if not SteamInitialized and (RequestedLanguage = '') then
  begin
    Language := ExtractDelimitedPartW(AvailableLanguageCodes, GetOptionValue('Lang'), ',');
    if SelectedLanguage <> Language then
    begin
      SelectedLanguage := Language;
      Text := GetGameUserDirectory + 'Lang.txt';
      AssignFile(LanguageFile, AnsiString(Text));
      Rewrite(LanguageFile);
      Write(LanguageFile, 'Lang=');
      Writeln(LanguageFile, SelectedLanguage);
      CloseFile(LanguageFile);
      RestartNeeded := True;
      if LanguageInstallConfig <> nil then
      begin
        LanguageInstallConfig.Free;
        LanguageInstallConfig := nil;
      end;
      if not FileExists(AnsiString('install_' + SelectedLanguage + '.txt')) then
        raise Exception.Create(AnsiString('Not installed language: ' + SelectedLanguage))
      else
      begin
        LanguageInstallConfig := TBlockParEC.Create;
        LanguageInstallConfig.LoadFromTextFileWithEncodingProbe(PWideChar('install_' + SelectedLanguage + '.txt'), False);
      end;
      ReloadModsRequested := True;
    end;
  end;
  MultiThreadEnabled := Boolean(GetOptionValue('MultiThread'));
  UserSettingsConfig.SetOrAddParam('MultiThread', BoolToWideString(MultiThreadEnabled));
  DefaultOrder := GetOptionValue('DefaultOrder');
  UserSettingsConfig.SetOrAddParam('DefaultOrder', WideString(IntToStr(DefaultOrder)));
  RightClickOnShip := GetOptionValue('RightClickOnShip');
  UserSettingsConfig.SetOrAddParam('RightClickOnShip', WideString(IntToStr(RightClickOnShip)));
  ViewFollowShip := Boolean(GetOptionValue('ViewFollowShip'));
  UserSettingsConfig.SetOrAddParam('ViewFollowShip', BoolToWideString(ViewFollowShip));
  ViewPathLength := Boolean(GetOptionValue('ViewPathLength'));
  UserSettingsConfig.SetOrAddParam('ViewPathLength', BoolToWideString(ViewPathLength));
  ActionDoubleClick := Boolean(GetOptionValue('ActionDoubleClick'));
  UserSettingsConfig.SetOrAddParam('ActionDoubleClick', BoolToWideString(ActionDoubleClick));
  ClickAutoCloseForm := Boolean(GetOptionValue('ClickAutoCloseForm'));
  UserSettingsConfig.SetOrAddParam('ClickAutoCloseForm', BoolToWideString(ClickAutoCloseForm));
  TurnSaveStep := GetOptionValue('TurnSaveStep');
  UserSettingsConfig.SetOrAddParam('TurnSaveStep', WideString(IntToStr(TurnSaveStep)));
  QuickSaveExtraSlots := GetOptionValue('QuickSaveExtraSlots');
  UserSettingsConfig.SetOrAddParam('QuickSaveExtraSlots', WideString(IntToStr(QuickSaveExtraSlots)));
  FilmHistoryLimit := GetOptionValue('CountFilmSave');
  UserSettingsConfig.SetOrAddParam('CountFilmSave', WideString(IntToStr(FilmHistoryLimit)));
  ScrollStep := GetOptionValue('ScrollSpeed');
  UserSettingsConfig.SetOrAddParam('ScrollStep', WideString(IntToStr(ScrollStep)));
  MaxPlayerNews := GetOptionValue('MaxPlayerNews');
  UserSettingsConfig.SetOrAddParam('MaxPlayerNews', WideString(IntToStr(MaxPlayerNews)));
  MaxSearchResult := GetOptionValue('MaxSearchResult');
  UserSettingsConfig.SetOrAddParam('MaxSearchResult', WideString(IntToStr(MaxSearchResult)));
  AfterburnerStopCondition := GetOptionValue('ForsageDeactivatePercent');
  UserSettingsConfig.SetOrAddParam('ForsageDeactivatePercent', WideString(IntToStr(AfterburnerStopCondition)));
  FilmSpeed := GetOptionValue('FilmSpeed');
  UserSettingsConfig.SetOrAddParam('FilmSpeed', WideString(IntToStr(FilmSpeed)));
  ChangeAutoPilot := GetOptionValue('ChangeAutoPilot');
  UserSettingsConfig.SetOrAddParam('ChangeAutoPilot', WideString(IntToStr(ChangeAutoPilot)));
  DisableAutoPilot := Boolean(GetOptionValue('DisableAutoPilot'));
  UserSettingsConfig.SetOrAddParam('DisableAutoPilot', BoolToWideString(DisableAutoPilot));
  BeginCalcNextTurn := GetOptionValue('BeginCalcNextTurn') / 100.0;
  UserSettingsConfig.SetOrAddParam('BeginCalcNextTurn', WideString(IntToStr(Round(BeginCalcNextTurn * 100.0))));

  ActiveGroupIndex := 1;
  Index := GetOptionValue('Resolution');
  if SelectedGameDisplayMode <> Index then
  begin
    if GameDisplayModes[Index].Width = 0 then
    begin
      if (GameDisplayModes[SelectedGameDisplayMode].Width <> DesktopDisplayMode.Width) or
         (GameDisplayModes[SelectedGameDisplayMode].Height <> DesktopDisplayMode.Height) then
        RestartNeeded := True;
    end
    else if (GameDisplayModes[Index].Width <> GameDisplayModes[SelectedGameDisplayMode].Width) or
            (GameDisplayModes[Index].Height <> GameDisplayModes[SelectedGameDisplayMode].Height) then
      RestartNeeded := True;
    SelectedGameDisplayMode := Index;
  end;
  if Index >= 0 then
  begin
    Text := WideString(IntToStr(GameDisplayModes[Index].Width) + ',' + IntToStr(GameDisplayModes[Index].Height));
    if RequestedRefreshRate > 0 then
      Text := Text + ',' + WideString(IntToStr(RequestedRefreshRate));
    UserSettingsConfig.SetOrAddParam('VideoMode', Text);
  end;
  DisplayBrightness := (GetOptionValue('Brightness') - 50) / 50.0;
  DisplayContrast := (GetOptionValue('Contrast') - 50) / 50.0;
  UserSettingsConfig.SetOrAddParam('Brightness', WideString(Format('%.2f', [DisplayBrightness])));
  UserSettingsConfig.SetOrAddParam('Contrast', WideString(Format('%.2f', [DisplayContrast])));
  ApplyGammaRamp(DisplayBrightness, DisplayContrast);
  if Boolean(GetOptionValue('VSync')) <> VSyncEnabled then
  begin
    ResetNeeded := True;
    VSyncEnabled := not VSyncEnabled;
    UserSettingsConfig.SetOrAddParam('VSync', BoolToWideString(VSyncEnabled));
  end;
  if Boolean(GetOptionValue('Window')) <> WindowedModeRequested then
  begin
    ResetNeeded := True;
    WindowedModeRequested := Boolean(GetOptionValue('Window'));
    UserSettingsConfig.SetOrAddParam('Window', BoolToWideString(WindowedModeRequested));
  end;
  if AlternateViewportEnabled and (Boolean(GetOptionValue('RenderMode')) <> ScaleViewportToWindow) then
  begin
    RestartNeeded := True;
    ScaleViewportToWindow := Boolean(GetOptionValue('RenderMode'));
    UserSettingsConfig.SetOrAddParam('RenderModeScale', BoolToWideString(ScaleViewportToWindow));
  end;
  if not AlternateViewportEnabled and (Boolean(GetOptionValue('HardwareRender')) <> HardwareRenderingRequested) then
  begin
    HardwareRenderingRequested := not HardwareRenderingRequested;
    UserSettingsConfig.SetOrAddParam('HardwareRender', BoolToWideString(HardwareRenderingRequested));
    HardwareRenderingEnabled := HardwareRenderingRequested and
      (not RunningUnderWine or ((UserSettingsConfig.CountParams('AllowHardwareRenderUnderWine') <> 0) and
        ParseEnabledNameGI(TrimWideString(UserSettingsConfig.GetParamByPathOrMarker('AllowHardwareRenderUnderWine')))));
  end;
  ShowSystemMouse := Boolean(GetOptionValue('SoftwareCursor'));
  UserSettingsConfig.SetOrAddParam('ShowSystemMouse', BoolToWideString(ShowSystemMouse));
  SkipIntro := not Boolean(GetOptionValue('Intro'));
  UserSettingsConfig.SetOrAddParam('SkipIntro', BoolToWideString(SkipIntro));
  SkipVideo := not Boolean(GetOptionValue('Video'));
  UserSettingsConfig.SetOrAddParam('SkipVideo', BoolToWideString(SkipVideo));
  BGImage := Boolean(GetOptionValue('BGImage'));
  UserSettingsConfig.SetOrAddParam('BGImage', BoolToWideString(BGImage));
  AnimCaptain := Boolean(GetOptionValue('AnimCaptain'));
  UserSettingsConfig.SetOrAddParam('AnimCaptain', BoolToWideString(AnimCaptain));
  AnimShipFull := Boolean(GetOptionValue('AnimShip'));
  UserSettingsConfig.SetOrAddParam('AnimShipFull', BoolToWideString(AnimShipFull));
  AnimItem := Boolean(GetOptionValue('AnimItem'));
  UserSettingsConfig.SetOrAddParam('AnimItem', BoolToWideString(AnimItem));
  AnimMenuShip := Boolean(GetOptionValue('AnimMenuShip'));
  UserSettingsConfig.SetOrAddParam('AnimMenuShip', BoolToWideString(AnimMenuShip));
  AnimGov := GetOptionValue('AnimGov');
  UserSettingsConfig.SetOrAddParam('AnimGov', WideString(IntToStr(AnimGov)));
  AnimHangar := Boolean(GetOptionValue('AnimHangar'));
  UserSettingsConfig.SetOrAddParam('AnimHangar', BoolToWideString(AnimHangar));
  AnimStar := Boolean(GetOptionValue('AnimStar'));
  UserSettingsConfig.SetOrAddParam('AnimStar', BoolToWideString(AnimStar));
  if GetOptionValue('SpaceImage') <> SpaceImage then
  begin
    SpaceImage := GetOptionValue('SpaceImage');
    if (Galaxy <> nil) and (SpaceImage > 0) then
      Galaxy.GenerateSpaceBackground(PlayerStar.BackgroundImage);
    UserSettingsConfig.SetOrAddParam('SpaceImage', WideString(IntToStr(SpaceImage)));
  end;
  SputnikShow := Boolean(GetOptionValue('SputnikShow'));
  UserSettingsConfig.SetOrAddParam('SputnikShow', BoolToWideString(SputnikShow));
  CircleAction := Boolean(GetOptionValue('CircleAction'));
  UserSettingsConfig.SetOrAddParam('CircleAction', BoolToWideString(CircleAction));
  ShipTail := GetOptionValue('Tail');
  UserSettingsConfig.SetOrAddParam('ShipTail', WideString(IntToStr(ShipTail)));
  Comet := GetOptionValue('Comet');
  UserSettingsConfig.SetOrAddParam('Comet', WideString(IntToStr(Comet)));
  Wind := GetOptionValue('Wind');
  UserSettingsConfig.SetOrAddParam('Wind', WideString(IntToStr(Wind)));
  BackgroundShade := Boolean(GetOptionValue('BackgroundShade'));
  UserSettingsConfig.SetOrAddParam('BackgroundShade', BoolToWideString(BackgroundShade));
  BackgroundGrayscale := Boolean(GetOptionValue('BackgroundGrayscale'));
  UserSettingsConfig.SetOrAddParam('BackgroundGrayscale', BoolToWideString(BackgroundGrayscale));
  PlanetClouds := Boolean(GetOptionValue('PlanetClouds'));
  UserSettingsConfig.SetOrAddParam('PlanetClouds', BoolToWideString(PlanetClouds));
  PlanetAtm := Boolean(GetOptionValue('PlanetAtm'));
  UserSettingsConfig.SetOrAddParam('PlanetAtm', BoolToWideString(PlanetAtm));
  AnimChangeForm := Boolean(GetOptionValue('AnimChangeForm'));
  UserSettingsConfig.SetOrAddParam('AnimChangeForm', BoolToWideString(AnimChangeForm));
  AnimMainFon := Boolean(GetOptionValue('AnimMainFon'));
  UserSettingsConfig.SetOrAddParam('AnimMainFon', BoolToWideString(AnimMainFon));
  ShowFrameRate := Boolean(GetOptionValue('ShowFPS'));
  UserSettingsConfig.SetOrAddParam('ShowFPS', BoolToWideString(ShowFrameRate));
  GalaxyMapFontChoice := TGalaxyMapFontChoice(GetOptionValue('FontGalaxy'));
  UserSettingsConfig.SetOrAddParam('FontGalaxy', WideString(IntToStr(Integer(GalaxyMapFontChoice))));
  DynamicTipsPos := Boolean(GetOptionValue('DynamicTipsPos'));
  UserSettingsConfig.SetOrAddParam('DynamicTipsPos', BoolToWideString(DynamicTipsPos));
  if Boolean(GetOptionValue('UseTablesForGov')) <> UseTablesForGov then
  begin
    RestartNeeded := True;
    UseTablesForGov := Boolean(GetOptionValue('UseTablesForGov'));
    UserSettingsConfig.SetOrAddParam('UseTablesForGov', BoolToWideString(UseTablesForGov));
  end;
  FontSmoothingEnabled := Boolean(GetOptionValue('FontSmooth'));
  UserSettingsConfig.SetOrAddParam('FontSmooth', BoolToWideString(FontSmoothingEnabled));
  FontDialog := GetOptionValue('FontDialog');
  UserSettingsConfig.SetOrAddParam('FontDialog', WideString(IntToStr(FontDialog)));
  FontQuest := GetOptionValue('FontQuest');
  UserSettingsConfig.SetOrAddParam('FontQuest', WideString(IntToStr(FontQuest)));
  ScreenshotFormat := GetOptionValue('ScreenShotType');
  UserSettingsConfig.SetOrAddParam('ScreenShotType', WideString(IntToStr(ScreenshotFormat)));
  ScreenshotJpegQuality := GetOptionValue('ScreenShotQuality');
  UserSettingsConfig.SetOrAddParam('ScreenShotQuality', WideString(IntToStr(ScreenshotJpegQuality)));

  ActiveGroupIndex := 2;
  if Boolean(GetOptionValue('Sound')) <> SoundEnabled then
  begin
    UserSettingsConfig.SetOrAddParam('Sound', BoolToWideString(not SoundEnabled));
    RestartNeeded := True;
  end;
  SoundInSpaceEnabled := Boolean(GetOptionValue('SoundInSpace'));
  UserSettingsConfig.SetOrAddParam('SoundInSpace', BoolToWideString(SoundInSpaceEnabled));
  SoundVolume := GetOptionValue('SoundVolume') / 100.0;
  UserSettingsConfig.SetOrAddParam('SoundVolume', WideString(IntToStr(GetOptionValue('SoundVolume'))));
  if Boolean(GetOptionValue('Music')) <> MusicEnabled then
  begin
    UserSettingsConfig.SetOrAddParam('Music', BoolToWideString(not MusicEnabled));
    RestartNeeded := True;
  end;
  MusicInSpaceEnabled := Boolean(GetOptionValue('MusicInSpace'));
  UserSettingsConfig.SetOrAddParam('MusicInSpace', BoolToWideString(MusicInSpaceEnabled));
  MusicVolume := GetOptionValue('MusicVolume') / 100.0;
  UserSettingsConfig.SetOrAddParam('MusicVolume', WideString(IntToStr(GetOptionValue('MusicVolume'))));
  MusicInHyperEnabled := Boolean(GetOptionValue('MusicInHyper'));
  UserSettingsConfig.SetOrAddParam('MusicInHyper', BoolToWideString(MusicInHyperEnabled));
  MusicInPlanetEnabled := Boolean(GetOptionValue('MusicInPlanet'));
  UserSettingsConfig.SetOrAddParam('MusicInPlanet', BoolToWideString(MusicInPlanetEnabled));

  ActiveGroupIndex := 4;
  SelectedRobotDisplayMode := GetOptionValue('RobotResolution');
  UserSettingsConfig.SetOrAddParam('RobotResolution', WideString(IntToStr(RobotDisplayModes[SelectedRobotDisplayMode].Width) + ',' + IntToStr(RobotDisplayModes[SelectedRobotDisplayMode].Height)));
  RobotVSync := Boolean(GetOptionValue('RobotVSync'));
  UserSettingsConfig.SetOrAddParam('RobotVSync', BoolToWideString(RobotVSync));
  if SupportedMultiSampleCount > 1 then
  begin
    RobotFSAASamples := SupportedMultiSamples[GetOptionValue('RobotFSAASamples')];
    UserSettingsConfig.SetOrAddParam('RobotFSAASamples', WideString(IntToStr(RobotFSAASamples)));
  end;
  if Integer(MaximumAnisotropy) > 0 then
  begin
    RobotAnisotropy := GetOptionValue('RobotAnisotropy');
    UserSettingsConfig.SetOrAddParam('RobotAnisotropy', WideString(IntToStr(RobotAnisotropy)));
  end;
  RobotMaxDistance := GetOptionValue('RobotMaxDistance');
  UserSettingsConfig.SetOrAddParam('RobotMaxDistance', WideString(IntToStr(RobotMaxDistance)));
  RobotBrightness := (GetOptionValue('RobotBrightness') - 50) / 50.0;
  RobotContrast := (GetOptionValue('RobotContrast') - 50) / 50.0;
  UserSettingsConfig.SetOrAddParam('RobotBrightness', WideString(Format('%.2f', [RobotBrightness])));
  UserSettingsConfig.SetOrAddParam('RobotContrast', WideString(Format('%.2f', [RobotContrast])));
  RobotSettings.ShowStencilShadows := Boolean(GetOptionValue('RobotShowStencilShadows'));
  UserSettingsConfig.SetOrAddParam('RobotShowStencilShadows', BoolToWideString(RobotSettings.ShowStencilShadows));
  RobotSettings.ShowProjShadows := Boolean(GetOptionValue('RobotShowProjShadows'));
  UserSettingsConfig.SetOrAddParam('RobotShowProjShadows', BoolToWideString(RobotSettings.ShowProjShadows));
  RobotSettings.RobotShadow := Byte(GetOptionValue('RobotRobotShadow'));
  UserSettingsConfig.SetOrAddParam('RobotRobotShadow', WideString(IntToStr(RobotSettings.RobotShadow)));
  RobotSettings.SelectEx := Boolean(GetOptionValue('RobotSelectEx'));
  UserSettingsConfig.SetOrAddParam('RobotSelectEx', BoolToWideString(RobotSettings.SelectEx));
  RobotSettings.LandTexturesGloss := Boolean(GetOptionValue('RobotLandTexturesGloss'));
  UserSettingsConfig.SetOrAddParam('RobotLandTexturesGloss', BoolToWideString(RobotSettings.LandTexturesGloss));
  RobotSettings.ObjTexturesGloss := Boolean(GetOptionValue('RobotObjTexturesGloss'));
  UserSettingsConfig.SetOrAddParam('RobotObjTexturesGloss', BoolToWideString(RobotSettings.ObjTexturesGloss));
  RobotSettings.SoftwareCursor := Boolean(GetOptionValue('RobotSoftwareCursor'));
  UserSettingsConfig.SetOrAddParam('RobotSoftwareCursor', BoolToWideString(RobotSettings.SoftwareCursor));
  RobotSettings.Sky := Byte(GetOptionValue('RobotSky'));
  UserSettingsConfig.SetOrAddParam('RobotSky', WideString(IntToStr(RobotSettings.Sky)));

  ActiveGroupIndex := 5;
  RobotMusic := Boolean(GetOptionValue('RobotMusic'));
  UserSettingsConfig.SetOrAddParam('RobotMusic', BoolToWideString(RobotMusic));
  RobotMusicVolume := GetOptionValue('RobotMusicVolume') / 100.0;
  UserSettingsConfig.SetOrAddParam('RobotMusicVolume', WideString(IntToStr(GetOptionValue('RobotMusicVolume'))));
  RobotSound := Boolean(GetOptionValue('RobotSound'));
  UserSettingsConfig.SetOrAddParam('RobotSound', BoolToWideString(RobotSound));
  RobotSoundVolume := GetOptionValue('RobotSoundVolume') / 100.0;
  UserSettingsConfig.SetOrAddParam('RobotSoundVolume', WideString(IntToStr(GetOptionValue('RobotSoundVolume'))));

  ActiveGroupIndex := 3;
  Text := GetGameUserDirectory + 'cfg.txt';
  UserSettingsConfig.SaveTextFile(PWideChar(Text), True, False);
  StarMapScreen.ConfigureMiddleButtonAction;
  if SoundManager <> nil then
  begin
    Buffer := SoundManager.FirstBuffer;
    while Buffer <> nil do
    begin
      if Buffer.Streaming then
        Buffer.SetVolume(MusicVolume * MusicVolumeScale)
      else
        Buffer.SetVolume(SoundVolume);
      Buffer := Buffer.Next;
    end;
  end;
  if ShowSystemMouse then
    while ShowCursor(True) < 0 do
  else
    while ShowCursor(False) >= 0 do;
  if ResetNeeded and not RestartNeeded then GR_DXReset;
  if not RestartNeeded then
    RequestedScreenId := SettingsReturnScreenId
  else
  begin
    RequestedScreenId := screenNone;
    PostLoadScreenId := SettingsReturnScreenId;
  end;
  if not HardwareRenderingEnabled then ReleaseAllTextureSurfaces;
  RequestClose(1);
end;
{$I+}
{ @end $5FF420 }

{ @routine $60238C TfCfgSettings_CreateWarningImage }
function TfCfgSettings.CreateWarningImage(Owner: TLabelGI; Item: PFontObjectEC): TObjectGI;
begin
  Result := TImageGI.Create(Owner);
  with Result as TImageGI do
  begin
    SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'Warning');
    SetImageKindX(ikxLeft);
    SetImageKindY(ikyTop);
  end;
end;
{ @end $60238C }

{ @routine $602480 TfCfgSettings_SelectMusic }
procedure TfCfgSettings.SelectMusic;
begin
  if GetPlayer = nil then MusicManager.PlayCategory('Base')
  else if GetPlayer.IsOnPlanet then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
      if GetPlayer.CurrentPlanet.OwnerId = oiPirate then
      begin
        if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then
          MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
        else MusicManager.PlayCategory('Nation.PiratePlanetMain');
      end
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end
  else if GetPlayer.IsDockedToShip then
  begin
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut
    else
      if GetPlayer.DockedTo.TypeId in [Ord(rstPirateBase), Ord(rstDominion)] then
        MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.DockedTo.PilotRace)].InternalName);
  end
  else if GetPlayer.InNormalSpace then
  begin
    if MusicInSpaceEnabled then
    begin
      if (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 20) then
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
{ @end $602480 }

{ @routine $6027B4 TfCfgSettings_ExecuteUiCode }
procedure TfCfgSettings.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if Galaxy <> nil then Galaxy.CheckIntegrityChecksum(10000);
  ExecuteGameplayUiCode(Block, Key);
  if Galaxy <> nil then Galaxy.PrimeIntegrityChecksum(20000);
end;
{ @end $6027B4 }


end.
