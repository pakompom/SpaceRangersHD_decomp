unit fAbout;

interface

uses GI_MessageLoop, GI_Panel, Types;

type
  TfAbout = class(TMessageLoopGI) // @size 0xE4
  public
    ScrollTimer: TCallbackTimerIdGI; // @offset 0xD0
    ViewportPanel: TPanelGI; // @offset 0xD4
    CreditsPanel: TPanelGI; // @offset 0xD8
    CreditsHeight: Integer; // @offset 0xDC
    FirstMusicSelection: Boolean; // @offset 0xE0
    ReturnToScores: Boolean; // @offset 0xE1

    procedure InitializeLayout; override; // @addr 0x005BB138
    procedure OnOpen; override; // @addr 0x005BB790
    procedure OnClose; override; // @addr 0x005BB9B4
    procedure SelectMusic; override; // @addr 0x005BBD08
    procedure ClearCredits; // @addr 0x005BB9D4
    procedure AddCreditLine(Text: WideString; Red, Green, Blue: Byte); // @addr 0x005BB9E8
    procedure AddCreditSeparator; // @addr 0x005BBB18
    procedure AddCreditSpacing(Height: Integer); // @addr 0x005BBC44
    procedure ScrollCredits(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x005BBC4C
    procedure CloseMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x005BBCA0
    procedure CloseKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x005BBCE0
  end;

implementation

uses Classes, EC_BlockPar, EC_Str, EC_Thread, GI_Image, GI_Label, GR_Main,
  Globals, GlobalsV, aConst, GR_Music;

{ @routine $5BB138 TfAbout_InitializeLayout }
procedure TfAbout.InitializeLayout;
var
  Shift: Integer;
begin
  inherited InitializeLayout;
  AppendLogTextThreadSafe('fAbout... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('BGImage') do SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('LogoPanel') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('ShadeBottom') do SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('PanelImage') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
    with FindByNameRecursive('Caption') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
    with FindByNameRecursive('SubCaption') do SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('LogoElemental') do
    begin
      Shift := LocalPosition.X * Integer(GameScreenWidth) div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('LabelElemental') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('Logo1C') do
    begin
      Shift := LocalPosition.X * Integer(GameScreenWidth) div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('Label1C') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('LogoKatauri') do
    begin
      Shift := LocalPosition.X * Integer(GameScreenWidth) div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('LabelKatauri') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('LogoSnk') do
    begin
      Shift := LocalPosition.X * Integer(GameScreenWidth) div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('LabelSnk') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('PAbout') do
    begin
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y));
      SetSize(Classes.Point(ClientSize.X, ClientSize.Y + ExtraScreenHeight));
    end;
  end;
  AppendLogLineThreadSafe('ok');
  ViewportPanel := GetByName('PAbout') as TPanelGI;
  CreditsPanel := GetByName('PAboutI') as TPanelGI;
  with GetByName('MainPanel') do
  begin
    KeyDownCallback := CloseKeyDown;
    LeftButtonUpCallback := CloseMouseDown;
    RightButtonUpCallback := CloseMouseDown;
  end;
end;
{ @end $5BB138 }

{ @routine $5BB790 TfAbout_OnOpen }
procedure TfAbout.OnOpen;
var
  Block: TBlockParEC;
  I, Count: Integer;
  Kind: WideString;
begin
  FirstMusicSelection := True;
  MusicManager.RequestFadeOut;
  if ScrollTimer <> 0 then
  begin
    CancelCallbackTimer(ScrollTimer);
    ScrollTimer := 0;
  end;
  ScrollTimer := ScheduleCallbackTimer(20, 20, ScrollCredits);
  CreditsPanel.SetPosition(Classes.Point(0, ViewportPanel.ClientSize.Y));
  ClearCredits;
  Block := LanguageDataConfig.GetBlock('FormAbout');
  Count := Block.GetParamCount;
  for I := 0 to Count - 1 do
  begin
    Kind := Block.GetParamName(I);
    if (Kind = 'T') or (Kind = 'N') then
    begin
      if Kind = 'T' then AddCreditLine(Block.GetParamValue(I), 105, 235, 235)
      else AddCreditLine(Block.GetParamValue(I), 255, 255, 255);
    end
    else if Kind = 'S' then
    begin
      Kind := Block.GetParamValue(I);
      AddCreditSpacing(GiScalePixels(ExtractDigitsToIntW(Kind)));
    end
    else if Kind = 'L' then AddCreditSeparator;
  end;
  CreditsPanel.SetSize(Classes.Point(CreditsPanel.ClientSize.X, CreditsHeight));
end;
{ @end $5BB790 }

{ @routine $5BB9B4 TfAbout_OnClose }
procedure TfAbout.OnClose;
begin
  if ScrollTimer <> 0 then
  begin
    CancelCallbackTimer(ScrollTimer);
    ScrollTimer := 0;
  end;
end;
{ @end $5BB9B4 }

{ @routine $5BB9D4 TfAbout_ClearCredits }
procedure TfAbout.ClearCredits;
begin
  CreditsHeight := 0;
  CreditsPanel.FreeOwnedChildren;
end;
{ @end $5BB9D4 }

{ @routine $5BB9E8 TfAbout_AddCreditLine }
procedure TfAbout.AddCreditLine(Text: WideString; Red, Green, Blue: Byte);
var
  LabelControl: TLabelGI;
begin
  LabelControl := TLabelGI.Create(CreditsPanel);
  LabelControl.SetPosition(Classes.Point(0, CreditsHeight));
  LabelControl.SetSize(Classes.Point(ViewportPanel.ClientSize.X, 1));
  LabelControl.SetFontName(AuthorsFontName);
  LabelControl.SetWordWrapEnabled(False);
  LabelControl.SetPositionModeW(False);
  LabelControl.SetTextAlignX(text_x_center);
  LabelControl.SetTextAlignY(text_y_fit_height);
  LabelControl.SetText(Text);
  LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(Red, Green, Blue));
  LabelControl.SetTextAlignX(text_x_center);
  LabelControl.SetTextAlignY(text_y_center);
  LabelControl.SetSize(Classes.Point(LabelControl.ClientSize.X, LabelControl.ClientSize.Y + 4));
  CreditsHeight := CreditsHeight + LabelControl.ClientSize.Y;
end;
{ @end $5BB9E8 }

{ @routine $5BBB18 TfAbout_AddCreditSeparator }
procedure TfAbout.AddCreditSeparator;
var
  Image: TImageGI;
begin
  Image := TImageGI.Create(CreditsPanel);
  Image.SetImagePath('GI,Bm.FormAbout2.' + GiResourceSuffix + 'Line');
  Image.SetPosition(Classes.Point(0, CreditsHeight));
  Image.SetSize(Classes.Point(ViewportPanel.ClientSize.X, Image.GetContentSize.Y + 4));
  Image.SetPositionModeW(False);
  Image.SetImageKindX(image_x_center);
  Image.SetImageKindY(image_y_center);
  CreditsHeight := CreditsHeight + Image.ClientSize.Y;
end;
{ @end $5BBB18 }

{ @routine $5BBC44 TfAbout_AddCreditSpacing }
procedure TfAbout.AddCreditSpacing(Height: Integer);
begin
  CreditsHeight := CreditsHeight + Height;
end;
{ @end $5BBC44 }

{ @routine $5BBC4C TfAbout_ScrollCredits }
procedure TfAbout.ScrollCredits(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  CreditsPanel.SetPosition(Classes.Point(0, CreditsPanel.LocalPosition.Y - 1));
  if -CreditsPanel.LocalPosition.Y >= CreditsPanel.ClientSize.Y then
    CreditsPanel.SetPosition(Classes.Point(0, ViewportPanel.ClientSize.Y));
end;
{ @end $5BBC4C }

{ @routine $5BBCA0 TfAbout_CloseMouseDown }
procedure TfAbout.CloseMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ReturnToScores then RequestedScreenId := screen_scores
  else RequestedScreenId := screen_main_menu;
  RequestClose(1);
end;
{ @end $5BBCA0 }

{ @routine $5BBCE0 TfAbout_CloseKeyDown }
procedure TfAbout.CloseKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if ReturnToScores then RequestedScreenId := screen_scores
  else RequestedScreenId := screen_main_menu;
  RequestClose(1);
end;
{ @end $5BBCE0 }

{ @routine $5BBD08 TfAbout_SelectMusic }
procedure TfAbout.SelectMusic;
begin
  if FirstMusicSelection then
  begin
    MusicManager.PlayCategory('Song');
    FirstMusicSelection := False;
  end
  else MusicManager.PlayCategory('Base');
end;
{ @end $5BBD08 }

end.
