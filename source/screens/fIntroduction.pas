unit fIntroduction;
// Unit bracket (inferred): .text 0x00660520..0x00661982; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop;

type
  TfIntroduction = class(TMessageLoopGI) // @size 0xF0
  public
    GenerationProgressTimer: PCallbackTimerGI; // @offset 0xD0
    TextScrollTimer: PCallbackTimerGI; // @offset 0xD4
    BackgroundTimer: PCallbackTimerGI; // @offset 0xD8
    BackgroundScrollOffset: Integer; // @offset 0xDC
    TextPanelTop: Integer; // @offset 0xE0
    TextPanelHeight: Integer; // @offset 0xE4
    ProgressPulsePhase: Single; // @offset 0xE8
    ContinueBlinkTimer: PCallbackTimerGI; // @offset 0xEC

    procedure InitializeLayout; override; // @addr 0x6605BC
    procedure OnOpen; override; // @addr 0x660B30
    procedure OnClose; override; // @addr 0x661088
    procedure SelectMusic; override; // @addr 0x661968
    procedure UpdateGenerationProgress(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x661194
    procedure BlinkContinueButton(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x66158C
    procedure ScrollIntroductionText(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x661674
    procedure ScrollBackground(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x661748
    procedure ContinueMouseEnter(Sender: TObjectGI); // @addr 0x66180C
    procedure ContinueClicked(Sender: TObjectGI); // @addr 0x661844
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x6618E0
  end;

var
  IntroductionPulseCounter: Integer = 0; // @addr $87BEB0
  NewGameGenerationStage: Integer; // @addr $88AA40 Shared with TThreadCreateNewGame; stage 8 means generation completed.
  IntroductionBlinkColorA: Cardinal; // @addr $88AA44
  IntroductionBlinkColorB: Cardinal; // @addr $88AA48
  IntroductionPulseRed: Byte; // @addr $88AA4C
  IntroductionPulseGreen: Byte; // @addr $88AA4D
  IntroductionPulseBlue: Byte; // @addr $88AA4E
  DisplayedGenerationStage: Integer; // @addr $88AA50

implementation

uses aGalaxyStruct, Classes, Windows, SysUtils, EC_Str, EC_Struct, GI_Main, GI_Image,
  GI_Label, GI_GraphButton, GI_GraphBuf, GR_Main, GR_DX, GR_Music,
  Globals, GlobalsV, aMyFunction, aPlayer, fGameSettings2;

{ @routine $6605BC TfIntroduction_InitializeLayout }
procedure TfIntroduction.InitializeLayout;
var I: Integer;
begin
  inherited;
  AppendLogTextThreadSafe('fIntroduction... ');
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('ImageFon1') do SetPosition(Classes.Point(LocalPosition.X,GameScreenHeight - ClientSize.Y));
    with FindByNameRecursive('ImageFon2') do SetPosition(Classes.Point(LocalPosition.X,GameScreenHeight - ClientSize.Y));
    with FindByNameRecursive('ImageTop') do SetSize(Classes.Point(GameScreenWidth,ClientSize.Y));
    with FindByNameRecursive('ImageBottom') do
    begin
      SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight));
      SetSize(Classes.Point(GameScreenWidth,ClientSize.Y));
    end;
    with FindByNameRecursive('ImageScreen') do SetPosition(Classes.Point(LocalPosition.X,LocalPosition.Y + ExtraScreenHeight div 2));
    with FindByNameRecursive('Ok') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth,LocalPosition.Y + ExtraScreenHeight));
    for I := 1 to 8 do
    begin
      with FindByNameRecursive(AnsiString('ICW') + IntToStr(I)) do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive(AnsiString('MCW') + IntToStr(I)) do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('PanelText') do
    begin
      SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth,ClientSize.Y + ExtraScreenHeight));
      with FindByNameRecursive('GBText') do SetSize(Classes.Point(ClientSize.X + ExtraScreenWidth,ClientSize.Y));
    end;
  end;
  IntroductionBlinkColorA := GetStyleColorGI('Introduction.BlinkColorA',27,68,98);
  IntroductionBlinkColorB := GetStyleColorGI('Introduction.BlinkColorB',93,152,166);
  AppendLogLineThreadSafe('ok');
end;
{ @end $6605BC }

{ @routine $660B30 TfIntroduction_OnOpen }
procedure TfIntroduction.OnOpen;
var I: Integer; Text: WideString;
begin
  DisplayedGenerationStage := 0;
  NewGameGenerationStage := 0;
  ProgressPulsePhase := 0;
  for I := 1 to 8 do
  begin
    (GetByName(AnsiString('MCW') + IntToStr(I)) as TLabelGI).SetTextColor(IntroductionBlinkColorA);
    GetByName(AnsiString('ICW') + IntToStr(I)).SetActive(False);
  end;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  with GetByName('PanelText') do
  begin
    TextPanelTop := LocalPosition.Y;
    TextPanelHeight := ClientSize.Y;
  end;
  with GetByName('Ok') as TGraphButtonGI do
  begin
    UpCallback := ContinueClicked;
    MouseEnterCallback := ContinueMouseEnter;
    SetDisabled(True);
  end;
  if NewGameGenerationThread = nil then
    Text := FormatText1(LocalizedText('FormIntroduction.Text'),'<color=255,240,100>','<Player>',GetPlayer.Name)
  else
    Text := FormatText1(LocalizedText('FormIntroduction.Text'),'<color=255,240,100>','<Player>',NewGameGenerationThread.PlayerName);
  with GetByName('GBText') as TGraphBufGI do
  begin
    SourceHasPerPixelAlpha := True;
    if (ExtraScreenWidth > 127) and (ExtraScreenHeight > 127) then
      RenderLabelTextToBuffer(GraphBuf,ClientSize.X,1,0,Text,BigFontName,$FFFDFFD7,$FF373737,$FFDBDA9C)
    else if ExtraScreenWidth > 127 then
      RenderLabelTextToBuffer(GraphBuf,ClientSize.X,1,0,Text,SmoothIntroFontName,$FFFDFFD7,$FF373737,$FFDBDA9C)
    else RenderLabelTextToBuffer(GraphBuf,ClientSize.X,1,0,Text,IntroFontName,$FFFDFFD7,$FF373737,$FFDBDA9C);
    SetSize(Classes.Point(ClientSize.X,GraphBuf.Height));
    SetPosition(Classes.Point(LocalPosition.X,TextPanelHeight));
  end;
  if GenerationProgressTimer <> nil then
  begin
    CancelCallbackTimer(GenerationProgressTimer);
    GenerationProgressTimer := nil;
  end;
  GenerationProgressTimer := ScheduleCallbackTimer(20,20,UpdateGenerationProgress);
  if TextScrollTimer <> nil then
  begin
    CancelCallbackTimer(TextScrollTimer);
    TextScrollTimer := nil;
  end;
  TextScrollTimer := ScheduleCallbackTimer(20,20,ScrollIntroductionText);
  if BackgroundTimer <> nil then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := nil;
  end;
  if AnimMainFon then BackgroundTimer := ScheduleCallbackTimer(40,40,ScrollBackground);
  IntroductionPulseRed := 20;
  IntroductionPulseGreen := 30;
  IntroductionPulseBlue := 50;
  BackgroundScrollOffset := 0;
  ScrollBackground(nil,0);
end;
{ @end $660B30 }

{ @routine $661088 TfIntroduction_OnClose }
procedure TfIntroduction.OnClose;
begin
  if ContinueBlinkTimer <> nil then
  begin
    CancelCallbackTimer(ContinueBlinkTimer);
    ContinueBlinkTimer := nil;
  end;
  if GenerationProgressTimer <> nil then
  begin
    CancelCallbackTimer(GenerationProgressTimer);
    GenerationProgressTimer := nil;
  end;
  if TextScrollTimer <> nil then
  begin
    CancelCallbackTimer(TextScrollTimer);
    TextScrollTimer := nil;
  end;
  if BackgroundTimer <> nil then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := nil;
  end;
  if NewGameGenerationThread <> nil then
  begin
    NewGameGenerationThread.Free;
    NewGameGenerationThread := nil;
  end;
  with GetByName('GBText') as TGraphBufGI do GraphBuf.Clear;
end;
{ @end $661088 }

{ @routine $661194 TfIntroduction_UpdateGenerationProgress }
procedure TfIntroduction.UpdateGenerationProgress(Timer: PCallbackTimerGI; UserData: Integer);
var Delta: Integer; Amount: Single;
begin
  if IntroductionPulseCounter > 50 then Delta := -3 else Delta := 3;
  Inc(IntroductionPulseRed,Delta);
  Inc(IntroductionPulseGreen,Delta);
  Inc(IntroductionPulseBlue,Delta);
  IncrementWrapped(IntroductionPulseCounter,0,100);
  if (IntroductionPulseCounter = 0) or (IntroductionPulseRed <= 20) then
  begin
    IntroductionPulseRed := 20;
    IntroductionPulseGreen := 30;
    IntroductionPulseBlue := 50;
  end;
  ProgressPulsePhase := ProgressPulsePhase + 0.05;
  if ProgressPulsePhase >= 1 then
  begin
    ProgressPulsePhase := 0;
    if DisplayedGenerationStage < NewGameGenerationStage then
    begin
      Inc(DisplayedGenerationStage);
      if (DisplayedGenerationStage + 0 >= 1) and (DisplayedGenerationStage + 0 <= 8) then
        GetByName(AnsiString('ICW') + IntToStr(DisplayedGenerationStage)).SetActive(True);
      if (DisplayedGenerationStage + 0 >= 1) and (DisplayedGenerationStage + 0 <= 8) then
        (GetByName(AnsiString('MCW') + IntToStr(DisplayedGenerationStage)) as TLabelGI).SetTextColor(IntroductionBlinkColorA);
    end;
  end;
  if ProgressPulsePhase < 0.5 then Amount := ProgressPulsePhase * 2
  else Amount := 1 - (ProgressPulsePhase - 0.5) * 2;
  if (DisplayedGenerationStage + 1 >= 1) and (DisplayedGenerationStage + 1 <= 8) then
        (GetByName(AnsiString('MCW') + IntToStr(DisplayedGenerationStage + 1)) as TLabelGI).SetTextColor(CurrentPixelFormat.InterpolateRgb(IntroductionBlinkColorA,IntroductionBlinkColorB,Amount));
  if (NewGameGenerationThread = nil) or (not NewGameGenerationThread.IsRunning and (DisplayedGenerationStage = 8)) then
  begin
    if GenerationProgressTimer <> nil then
    begin
      CancelCallbackTimer(GenerationProgressTimer);
      GenerationProgressTimer := nil;
    end;
    with GetByName('Ok') as TGraphButtonGI do
    begin
      SetHovered(False);
      SetDisabled(False);
    end;
    if NewGameGenerationThread <> nil then
    begin
      NewGameGenerationThread.Free;
      NewGameGenerationThread := nil;
    end;
    RootUiObject.ProcessMouseMove(0,Classes.Point(-1,-1));
    PostMouseMoveMessage;
    if ContinueBlinkTimer <> nil then
    begin
      CancelCallbackTimer(ContinueBlinkTimer);
      ContinueBlinkTimer := nil;
    end;
    ContinueBlinkTimer := ScheduleCallbackTimer(200,200,BlinkContinueButton);
  end;
end;
{ @end $661194 }

{ @routine $66158C TfIntroduction_BlinkContinueButton }
procedure TfIntroduction.BlinkContinueButton(Timer: PCallbackTimerGI; UserData: Integer);
var Enter, Leave: WideString;
begin
  with GetByName('Ok') as TGraphButtonGI do
  begin
    Enter := EnterSound;
    EnterSound := '';
    Leave := LeaveSound;
    LeaveSound := '';
    SetHovered(not IsHovered);
    EnterSound := Enter;
    LeaveSound := Leave;
  end;
end;
{ @end $66158C }

{ @routine $661674 TfIntroduction_ScrollIntroductionText }
procedure TfIntroduction.ScrollIntroductionText(Timer: PCallbackTimerGI; UserData: Integer);
var Limit: Single;
begin
  with GetByName('GBText') as TGraphBufGI do
  begin
    SetPosition(AddPoints(LocalPosition,Classes.Point(0,-1)));
    Limit := (TextPanelTop + TextPanelHeight) div 2 - ClientSize.Y div 2;
    if LocalPosition.Y < Limit then
      if TextScrollTimer <> nil then
      begin
        CancelCallbackTimer(TextScrollTimer);
        TextScrollTimer := nil;
      end;
  end;
end;
{ @end $661674 }

{ @routine $661748 TfIntroduction_ScrollBackground }
procedure TfIntroduction.ScrollBackground(Timer: PCallbackTimerGI; UserData: Integer);
var Offset: Integer;
begin
  Inc(BackgroundScrollOffset);
  with GetByName('ImageFon1') do
  begin
    Offset := BackgroundScrollOffset mod ClientSize.X;
    SetPosition(Classes.Point(0 - Offset,LocalPosition.Y));
  end;
  with GetByName('ImageFon2') do SetPosition(Classes.Point(ClientSize.X - Offset,LocalPosition.Y));
end;
{ @end $661748 }

{ @routine $66180C TfIntroduction_ContinueMouseEnter }
procedure TfIntroduction.ContinueMouseEnter(Sender: TObjectGI);
begin
  if ContinueBlinkTimer <> nil then
  begin
    CancelCallbackTimer(ContinueBlinkTimer);
    ContinueBlinkTimer := nil;
  end;
end;
{ @end $66180C }

{ @routine $661844 TfIntroduction_ContinueClicked }
procedure TfIntroduction.ContinueClicked(Sender: TObjectGI);
begin
  ReleaseAllTextureSurfaces;
  if GetPlayer.DockedTo <> nil then RequestedScreenId := screenRuinsTalk
  else if GetPlayer.CurrentPlanet = nil then RaiseWideMessage('No player location')
  else if GetPlayer.CurrentPlanet.OwnerId = oiUninhabited then RequestedScreenId := screenPlanetNO
  else RequestedScreenId := screenPlanet;
  RequestClose(1);
end;
{ @end $661844 }

{ @routine $6618E0 TfIntroduction_MainPanelKeyDown }
procedure TfIntroduction.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) and
    ((Key = VK_SPACE) or (Key = VK_RETURN) or (Key = VK_RIGHT)) then
    if not (GetByName('Ok') as TGraphButtonGI).Disabled then ContinueClicked(nil);
end;
{ @end $6618E0 }

{ @routine $661968 TfIntroduction_SelectMusic }
procedure TfIntroduction.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $661968 }

end.
