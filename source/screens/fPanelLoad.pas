unit fPanelLoad;

interface

uses EC_Struct, GI_GAI, GI_Image, GI_Label, GI_MessageLoop, GI_Panel;

type
  TfPanelLoad = class(TObjectEx) // @size 0xA0
  public
    Screen: TMessageLoopGI; // @offset 0x4
    ProgressSegments: array[0..16] of TImageGI; // @offset 0x08
    LayoutAdjusted: Boolean; // @offset 0x4C
    BackgroundImage: TObjectGI; // @offset 0x50
    ShipPanelImage: TObjectGI; // @offset 0x54
    LoadAnimation: TObjectGI; // @offset 0x58
    AnimationText: TObjectGI; // @offset 0x5C
    ProgressLabel: TLabelGI; // @offset 0x60
    ProgressBar: TObjectGI; // @offset 0x64
    BackgroundRestTop: Integer; // @offset 0x68
    ShipPanelRestTop: Integer; // @offset 0x6C
    AnimationRestTop: Integer; // @offset 0x70
    AnimationTextRestTop: Integer; // @offset 0x74
    ProgressLabelRestTop: Integer; // @offset 0x78
    ProgressBarRestTop: Integer; // @offset 0x7C
    ShutterTimer: TCallbackTimerIdGI; // @offset 0x80
    ShutterOpenFraction: Single; // @offset 0x84
    RightShutter: TPanelGI; // @offset 0x88
    LeftShutter: TPanelGI; // @offset 0x8C
    TopShutter: TPanelGI; // @offset 0x90
    BottomShutter: TPanelGI; // @offset 0x94
    HasShutters: Boolean; // @offset 0x98
    ShutterDirection: Integer; // @offset 0x9C  +1 opening, -1 closing.

    constructor Create; // @addr 0x0075377C
    destructor Destroy; override; // @addr 0x007537B8
    procedure InitializeLayout(Screen: TMessageLoopGI); // @addr 0x007537E0
    procedure OnOpen; // @addr 0x00753EE0
    procedure OnClose; // @addr 0x00753FCC
    function GetProgressSegmentCount: Integer; // @addr 0x00753FFC
    procedure Show; // @addr 0x00754004
    procedure Hide; // @addr 0x00754038
    procedure SelectBackgroundStyle(StyleGroup: Integer); // @addr 0x0075406C @note "Accepts groups 0..3; selects a style for shutter or legacy artwork. Other values preserve the current style."
    procedure RefreshBackgroundImages; // @addr 0x00754174
    procedure SetProgress(Fraction: Single); // @addr 0x007544EC @note "Requires a fraction in 0..1; does not clamp the progress-segment index."
    procedure SetShutterOpenFraction(Fraction: Single); // @addr 0x00754654
    procedure StartOpeningShutters; // @addr 0x00754794
    procedure StartClosingShutters; // @addr 0x00754804 @note "Closes Screen after the animation, or immediately when shutters are disabled."
    procedure UpdateOpeningShutters(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00754898
    procedure UpdateClosingShutters(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x00754924
    function IsAnimatingShutters: Boolean; // @addr 0x007549DC
    function GetShutterDirection: Integer; // @addr 0x007549E8 @note "Returns zero without an active timer."
  end;

var
  ActiveLoadPanel: TfPanelLoad; // @addr 0x0081B910

implementation

uses Classes, GR_Main, Globals, GlobalsV, SysUtils, aMyFunction, aPlayer;

{ @routine $75377C TfPanelLoad_Create }
constructor TfPanelLoad.Create;
begin
  inherited Create;
  LayoutAdjusted := False;
end;
{ @end $75377C }

{ @routine $7537B8 TfPanelLoad_Destroy }
destructor TfPanelLoad.Destroy;
begin
  inherited Destroy;
end;
{ @end $7537B8 }

{ @routine $7537E0 TfPanelLoad_InitializeLayout }
procedure TfPanelLoad.InitializeLayout(Screen: TMessageLoopGI);
var
  I: Integer;
  Panel: TObjectGI;
begin
  Self.Screen := Screen;
  AppendLogTextThreadSafe('fPanelLoad... ');
  if not LayoutAdjusted then
  begin
    Panel := Self.Screen.GetByName('PanelLoad');
    Panel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with Panel.FindByNameRecursive('BGImage') do
    begin
      SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight div 2));
      SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
    end;
    with Panel.FindByNameRecursive('ShipPanelImage') do SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with Panel.FindByNameRecursive('LoadAnim') as TgaiGI do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
      StopAutoPlayback;
    end;
    with Panel.FindByNameRecursive('LoadAnimText') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with Panel.FindByNameRecursive('PLProgress') do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
    with Panel.FindByNameRecursive('PLBar') do SetActive(False);
    LayoutAdjusted := True;
  end;
  AppendLogLineThreadSafe('ok');
  for I := 0 to GetProgressSegmentCount - 1 do
  begin
    ProgressSegments[I] := Self.Screen.GetByName('PLB' + IntToStr(I + 1)) as TImageGI;
    ProgressSegments[I].SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  end;
  BackgroundImage := Self.Screen.GetByName('BGImage');
  ShipPanelImage := Self.Screen.GetByName('ShipPanelImage');
  LoadAnimation := Self.Screen.GetByName('LoadAnim');
  AnimationText := Self.Screen.GetByName('LoadAnimText');
  ProgressLabel := Self.Screen.GetByName('PLProgress') as TLabelGI;
  ProgressBar := Self.Screen.GetByName('PLBar');
  BackgroundRestTop := BackgroundImage.LocalPosition.Y;
  ShipPanelRestTop := ShipPanelImage.LocalPosition.Y;
  AnimationRestTop := LoadAnimation.LocalPosition.Y;
  AnimationTextRestTop := AnimationText.LocalPosition.Y;
  ProgressLabelRestTop := ProgressLabel.LocalPosition.Y;
  ProgressBarRestTop := ProgressBar.LocalPosition.Y;
  RightShutter := Self.Screen.FindControlByPath('PLRight') as TPanelGI;
  LeftShutter := Self.Screen.FindControlByPath('PLLeft') as TPanelGI;
  TopShutter := Self.Screen.FindControlByPath('PLTop') as TPanelGI;
  BottomShutter := Self.Screen.FindControlByPath('PLBottom') as TPanelGI;
  HasShutters := (RightShutter <> nil) and (LeftShutter <> nil) and (TopShutter <> nil) and (BottomShutter <> nil);
  if HasShutters then
  begin
    RightShutter.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    LeftShutter.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    TopShutter.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    BottomShutter.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    Self.Screen.GetByName('PLRightImage').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    Self.Screen.GetByName('PLLeftImage').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    Self.Screen.GetByName('PLTopImage').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    Self.Screen.GetByName('PLBottomImage').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  end;
end;
{ @end $7537E0 }

{ @routine $753EE0 TfPanelLoad_OnOpen }
procedure TfPanelLoad.OnOpen;
begin
  Hide;
  if LoadScreen.BackgroundStyle <= 0 then SelectBackgroundStyle(0);
  RefreshBackgroundImages;
  SetProgress(1);
  ShutterOpenFraction := 0;
  SetShutterOpenFraction(ShutterOpenFraction);
  if ((PreviousScreenId = screen_asset_loading) and (CurrentScreenId <> screen_main_menu) and
      (CurrentScreenId <> screen_save_loading) and (CurrentScreenId <> screen_quest_selection)) or
    ((PreviousScreenId = screen_asset_loading) and (CurrentScreenId = screen_main_menu) and SkipVideo) or
    ((PreviousScreenId = screen_save_loading) and (CurrentScreenId <> screen_asset_loading)) or
    ((CurrentScreenId in [screen_hangar, screen_planet, screen_uninhabited_planet, screen_equipment_shop,
        screen_government, screen_ruins_talk, screen_info]) and
      (PreviousScreenId = screen_star_map) and (GetPlayer.RuinsMode = 0)) or
    ((CurrentScreenId in [screen_star_map, screen_ruins_talk]) and
      (PreviousScreenId in [screen_jump, screen_arcade_battle])) or
    ((CurrentScreenId = screen_arcade_battle) and (PreviousScreenId = screen_star_map)) then
  begin
    PreviousScreenId := screen_none;
    StartOpeningShutters;
  end;
  ActiveLoadPanel := Self;
end;
{ @end $753EE0 }

{ @routine $753FCC TfPanelLoad_OnClose }
procedure TfPanelLoad.OnClose;
begin
  if ActiveLoadPanel = Self then ActiveLoadPanel := nil;
  if ShutterTimer <> 0 then
  begin
    Screen.CancelCallbackTimer(ShutterTimer);
    ShutterTimer := 0;
  end;
end;
{ @end $753FCC }

{ @routine $753FFC TfPanelLoad_GetProgressSegmentCount }
function TfPanelLoad.GetProgressSegmentCount: Integer;
begin
  Result := 17;
end;
{ @end $753FFC }

{ @routine $754004 TfPanelLoad_Show }
procedure TfPanelLoad.Show;
begin
  Screen.GetByName('PanelLoad').SetActive(True);
end;
{ @end $754004 }

{ @routine $754038 TfPanelLoad_Hide }
procedure TfPanelLoad.Hide;
begin
  Screen.GetByName('PanelLoad').SetActive(False);
end;
{ @end $754038 }

{ @routine $75406C TfPanelLoad_SelectBackgroundStyle }
procedure TfPanelLoad.SelectBackgroundStyle(StyleGroup: Integer);
begin
  if not HasShutters then
  begin
    if StyleGroup = 0 then LoadScreen.BackgroundStyle := RandomIntRange(1, 2)
    else if StyleGroup = 1 then LoadScreen.BackgroundStyle := RandomIntRange(3, 6)
    else if StyleGroup = 2 then LoadScreen.BackgroundStyle := 7
    else if StyleGroup = 3 then LoadScreen.BackgroundStyle := 8;
  end
  else
  begin
    if StyleGroup = 0 then LoadScreen.BackgroundStyle := RandomIntRange(1, 7)
    else if StyleGroup = 1 then LoadScreen.BackgroundStyle := RandomIntRange(8, 13)
    else if StyleGroup = 2 then LoadScreen.BackgroundStyle := 14
    else if StyleGroup = 3 then LoadScreen.BackgroundStyle := 15;
  end;
end;
{ @end $75406C }

{ @routine $754174 TfPanelLoad_RefreshBackgroundImages }
procedure TfPanelLoad.RefreshBackgroundImages;
var
  Style: WideString;
begin
  if not HasShutters then
    (BackgroundImage as TImageGI).ImageSourcePath := 'GI,Bm.FormLoad2.Style' + IntToStr(LoadScreen.BackgroundStyle)
  else
  begin
    if LoadScreen.BackgroundStyle < 10 then Style := '0' + IntToStr(LoadScreen.BackgroundStyle)
    else Style := IntToStr(LoadScreen.BackgroundStyle);
    (Screen.GetByName('PLRightImage') as TImageGI).ImageSourcePath := 'GI,Bm.FormLoad2.ShutterRight' + Style;
    (Screen.GetByName('PLLeftImage') as TImageGI).ImageSourcePath := 'GI,Bm.FormLoad2.ShutterLeft' + Style;
    (Screen.GetByName('PLTopImage') as TImageGI).ImageSourcePath := 'GI,Bm.FormLoad2.ShutterTop' + Style;
    (Screen.GetByName('PLBottomImage') as TImageGI).ImageSourcePath := 'GI,Bm.FormLoad2.ShutterBottom' + Style;
  end;
end;
{ @end $754174 }

{ @routine $7544EC TfPanelLoad_SetProgress }
procedure TfPanelLoad.SetProgress(Fraction: Single);
var
  I, LastActive: Integer;
begin
  LastActive := Round(GetProgressSegmentCount * Fraction) - 1;
  for I := 0 to LastActive do ProgressSegments[I].SetActive(True);
  for I := LastActive + 1 to GetProgressSegmentCount - 1 do ProgressSegments[I].SetActive(False);
  ProgressLabel.SetText(IntToStr(Round(Fraction * 100 + 0.5)) + '%');
  with Screen.GetByName('LoadAnim') as TgaiGI do
    SetSequenceFrame(Round((SequenceFrameCount - 1) * Fraction * 2 + 3) mod (SequenceFrameCount - 1));
end;
{ @end $7544EC }

{ @routine $754654 TfPanelLoad_SetShutterOpenFraction }
procedure TfPanelLoad.SetShutterOpenFraction(Fraction: Single);
begin
  if not HasShutters then Exit;
  LeftShutter.SetPosition(Classes.Point(-Round(GameScreenWidth * Fraction * 0.34), LeftShutter.LocalPosition.Y));
  RightShutter.SetPosition(Classes.Point(Round(GameScreenWidth * Fraction * 0.34), RightShutter.LocalPosition.Y));
  TopShutter.SetPosition(Classes.Point(TopShutter.LocalPosition.X, -Round(GameScreenHeight * Fraction * 0.61)));
  BottomShutter.SetPosition(Classes.Point(BottomShutter.LocalPosition.X, Round(GameScreenHeight * Fraction * 0.39)));
end;
{ @end $754654 }

{ @routine $754794 TfPanelLoad_StartOpeningShutters }
procedure TfPanelLoad.StartOpeningShutters;
begin
  if AnimChangeForm and HasShutters then
  begin
    Show;
    if ShutterTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(ShutterTimer);
      ShutterTimer := 0;
    end;
    ShutterTimer := Screen.ScheduleCallbackTimer(17, 17, UpdateOpeningShutters);
    ShutterDirection := 1;
    Exit;
  end;
  Hide;
end;
{ @end $754794 }

{ @routine $754804 TfPanelLoad_StartClosingShutters }
procedure TfPanelLoad.StartClosingShutters;
begin
  if AnimChangeForm and HasShutters then
  begin
    Show;
    SetProgress(0);
    ShutterOpenFraction := 1;
    SetShutterOpenFraction(ShutterOpenFraction);
    if ShutterTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(ShutterTimer);
      ShutterTimer := 0;
    end;
    ShutterTimer := Screen.ScheduleCallbackTimer(17, 17, UpdateClosingShutters);
    ShutterDirection := -1;
    Exit;
  end;
  Screen.RequestClose(1);
end;
{ @end $754804 }

{ @routine $754898 TfPanelLoad_UpdateOpeningShutters }
procedure TfPanelLoad.UpdateOpeningShutters(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  ShutterOpenFraction := 0.03 + ShutterOpenFraction;
  if ShutterOpenFraction >= 1 then
  begin
    ShutterOpenFraction := 1;
    if ShutterTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(ShutterTimer);
      ShutterTimer := 0;
    end;
    Hide;
    SetShutterOpenFraction(ShutterOpenFraction);
    Screen.Present;
  end
  else SetShutterOpenFraction(ShutterOpenFraction);
end;
{ @end $754898 }

{ @routine $754924 TfPanelLoad_UpdateClosingShutters }
procedure TfPanelLoad.UpdateClosingShutters(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  ShutterOpenFraction := ShutterOpenFraction - 0.03;
  if ShutterOpenFraction <= -0.025 then
  begin
    ShutterOpenFraction := 0;
    if ShutterTimer <> 0 then
    begin
      Screen.CancelCallbackTimer(ShutterTimer);
      ShutterTimer := 0;
    end;
    SetShutterOpenFraction(ShutterOpenFraction);
    Screen.Present;
    Screen.RequestClose(1);
  end
  else if ShutterOpenFraction <= 0 then SetShutterOpenFraction(0)
  else SetShutterOpenFraction(ShutterOpenFraction);
end;
{ @end $754924 }

{ @routine $7549DC TfPanelLoad_IsAnimatingShutters }
function TfPanelLoad.IsAnimatingShutters: Boolean;
begin
  Result := ShutterTimer <> 0;
end;
{ @end $7549DC }

{ @routine $7549E8 TfPanelLoad_GetShutterDirection }
function TfPanelLoad.GetShutterDirection: Integer;
begin
  if ShutterTimer = 0 then Result := 0
  else Result := ShutterDirection;
end;
{ @end $7549E8 }

end.
