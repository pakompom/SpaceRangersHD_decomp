unit fIntroduction;

interface

uses GI_MessageLoop;

type
  TfIntroduction = class(TMessageLoopGI) // @size 0xF0
  public
    GenerationProgressTimer: TCallbackTimerIdGI; // @offset 0xD0
    TextScrollTimer: TCallbackTimerIdGI; // @offset 0xD4
    BackgroundTimer: TCallbackTimerIdGI; // @offset 0xD8
    BackgroundScrollOffset: Integer; // @offset 0xDC
    TextPanelTop: Integer; // @offset 0xE0
    TextPanelHeight: Integer; // @offset 0xE4
    ProgressPulsePhase: Single; // @offset 0xE8
    ContinueBlinkTimer: TCallbackTimerIdGI; // @offset 0xEC

    procedure InitializeLayout; override; // @addr 0x005BBE00
    procedure OnOpen; override; // @addr 0x005BC30C
    procedure OnClose; override; // @addr 0x005BC7CC
    procedure SelectMusic; override; // @addr 0x005BCF70
    procedure UpdateGenerationProgress(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005BC894
    procedure BlinkContinueButton(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005BCC2C
    procedure ScrollIntroductionText(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005BCCF4
    procedure ScrollBackground(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005BCDAC
    procedure ContinueMouseEnter(Sender: TObjectGI); // @addr 0x005BCE48
    procedure ContinueClicked(Sender: TObjectGI); // @addr 0x005BCE68
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x005BCEF8
  end;

var
  IntroductionPulseCounter: Integer = 0; // @addr $80F558
  NewGameGenerationStage: Integer; // @addr $81B7E8 Shared with TThreadCreateNewGame; stage 8 means generation completed.
  IntroductionBlinkColorA: Cardinal; // @addr $81B7EC
  IntroductionBlinkColorB: Cardinal; // @addr $81B7F0
  IntroductionPulseRed: Byte; // @addr $81B7F4
  IntroductionPulseGreen: Byte; // @addr $81B7F5
  IntroductionPulseBlue: Byte; // @addr $81B7F6
  DisplayedGenerationStage: Integer; // @addr $81B7F8

implementation

uses aGalaxyStruct, Classes, Windows, SysUtils, EC_Str, EC_Struct, GI_Main, GI_Image,
  GI_Label, GI_GraphButton, GI_GraphBuf, GR_Main, GR_DX, GR_Music,
  Globals, GlobalsV, aMyFunction, aPlayer, fGameSettings2;

{ @routine $5BBE00 TfIntroduction_InitializeLayout }
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
{ @end $5BBE00 }

{ @routine $5BC30C TfIntroduction_OnOpen }
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
    Text := FormatText1(LocalizedText('FormIntroduction.Text'),TextHighlightColorTag,'<Player>',GetPlayer.Name)
  else
    Text := FormatText1(LocalizedText('FormIntroduction.Text'),TextHighlightColorTag,'<Player>',NewGameGenerationThread.PlayerName);
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
  if GenerationProgressTimer <> 0 then
  begin
    CancelCallbackTimer(GenerationProgressTimer);
    GenerationProgressTimer := 0;
  end;
  GenerationProgressTimer := ScheduleCallbackTimer(20,20,UpdateGenerationProgress);
  if TextScrollTimer <> 0 then
  begin
    CancelCallbackTimer(TextScrollTimer);
    TextScrollTimer := 0;
  end;
  TextScrollTimer := ScheduleCallbackTimer(20,20,ScrollIntroductionText);
  if BackgroundTimer <> 0 then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := 0;
  end;
  if AnimMainFon then BackgroundTimer := ScheduleCallbackTimer(40,40,ScrollBackground);
  IntroductionPulseRed := 20;
  IntroductionPulseGreen := 30;
  IntroductionPulseBlue := 50;
  BackgroundScrollOffset := 0;
  ScrollBackground(0,0);
end;
{ @end $5BC30C }

{ @routine $5BC7CC TfIntroduction_OnClose }
procedure TfIntroduction.OnClose;
begin
  if ContinueBlinkTimer <> 0 then
  begin
    CancelCallbackTimer(ContinueBlinkTimer);
    ContinueBlinkTimer := 0;
  end;
  if GenerationProgressTimer <> 0 then
  begin
    CancelCallbackTimer(GenerationProgressTimer);
    GenerationProgressTimer := 0;
  end;
  if TextScrollTimer <> 0 then
  begin
    CancelCallbackTimer(TextScrollTimer);
    TextScrollTimer := 0;
  end;
  if BackgroundTimer <> 0 then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := 0;
  end;
  if NewGameGenerationThread <> nil then
  begin
    NewGameGenerationThread.Free;
    NewGameGenerationThread := nil;
  end;
  with GetByName('GBText') as TGraphBufGI do GraphBuf.Clear;
end;
{ @end $5BC7CC }

{ @routine $5BC894 TfIntroduction_UpdateGenerationProgress }
procedure TfIntroduction.UpdateGenerationProgress(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Delta, Stage: Integer; Amount: Single;
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
      Stage := DisplayedGenerationStage;
      if (Stage >= 1) and (Stage <= 8) then
        GetByName(AnsiString('ICW') + IntToStr(Stage)).SetActive(True);
      Stage := DisplayedGenerationStage;
      if (Stage >= 1) and (Stage <= 8) then
        (GetByName(AnsiString('MCW') + IntToStr(Stage)) as TLabelGI).SetTextColor(IntroductionBlinkColorA);
    end;
  end;
  if ProgressPulsePhase < 0.5 then Amount := ProgressPulsePhase * 2
  else Amount := 1 - (ProgressPulsePhase - 0.5) * 2;
  Stage := DisplayedGenerationStage + 1;
  if (Stage >= 1) and (Stage <= 8) then
    (GetByName(AnsiString('MCW') + IntToStr(Stage)) as TLabelGI).SetTextColor(CurrentPixelFormat.InterpolateRgb(IntroductionBlinkColorA,IntroductionBlinkColorB,Amount));
  if (NewGameGenerationThread <> nil) and (NewGameGenerationThread.IsRunning or (DisplayedGenerationStage <> 8)) then Exit;
  if GenerationProgressTimer <> 0 then
  begin
    CancelCallbackTimer(GenerationProgressTimer);
    GenerationProgressTimer := 0;
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
  if ContinueBlinkTimer <> 0 then
  begin
    CancelCallbackTimer(ContinueBlinkTimer);
    ContinueBlinkTimer := 0;
  end;
  ContinueBlinkTimer := ScheduleCallbackTimer(200,200,BlinkContinueButton);
end;
{ @end $5BC894 }

{ @routine $5BCC2C TfIntroduction_BlinkContinueButton }
procedure TfIntroduction.BlinkContinueButton(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
{ @end $5BCC2C }

{ @routine $5BCCF4 TfIntroduction_ScrollIntroductionText }
procedure TfIntroduction.ScrollIntroductionText(Timer: TCallbackTimerIdGI; UserData: Cardinal);
var Limit: Single;
begin
  with GetByName('GBText') as TGraphBufGI do
  begin
    SetPosition(AddPoints(LocalPosition,Classes.Point(0,-1)));
    Limit := (TextPanelTop + TextPanelHeight) div 2 - ClientSize.Y div 2;
    if LocalPosition.Y < Limit then
      if TextScrollTimer <> 0 then
      begin
        CancelCallbackTimer(TextScrollTimer);
        TextScrollTimer := 0;
      end;
  end;
end;
{ @end $5BCCF4 }

{ @routine $5BCDAC TfIntroduction_ScrollBackground }
procedure TfIntroduction.ScrollBackground(Timer: TCallbackTimerIdGI; UserData: Cardinal);
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
{ @end $5BCDAC }

{ @routine $5BCE48 TfIntroduction_ContinueMouseEnter }
procedure TfIntroduction.ContinueMouseEnter(Sender: TObjectGI);
begin
  if ContinueBlinkTimer <> 0 then
  begin
    CancelCallbackTimer(ContinueBlinkTimer);
    ContinueBlinkTimer := 0;
  end;
end;
{ @end $5BCE48 }

{ @routine $5BCE68 TfIntroduction_ContinueClicked }
procedure TfIntroduction.ContinueClicked(Sender: TObjectGI);
begin
  ReleaseAllTextureSurfaces;
  if GetPlayer.DockedTo <> nil then RequestedScreenId := screenRuinsTalk
  else if GetPlayer.CurrentPlanet = nil then RaiseWideMessage('No player location')
  else if GetPlayer.CurrentPlanet.OwnerId = oiUninhabited then RequestedScreenId := screenPlanetNO
  else RequestedScreenId := screenPlanet;
  RequestClose(1);
end;
{ @end $5BCE68 }

{ @routine $5BCEF8 TfIntroduction_MainPanelKeyDown }
procedure TfIntroduction.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if not IsVirtualKeyDown(VK_CONTROL) and not IsVirtualKeyDown(VK_SHIFT) and not IsVirtualKeyDown(VK_MENU) and
    ((Key = VK_SPACE) or (Key = VK_RETURN) or (Key = VK_RIGHT)) then
    if not (GetByName('Ok') as TGraphButtonGI).Disabled then ContinueClicked(nil);
end;
{ @end $5BCEF8 }

{ @routine $5BCF70 TfIntroduction_SelectMusic }
procedure TfIntroduction.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;
{ @end $5BCF70 }

end.
