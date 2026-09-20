unit fAbout;
// Unit bracket (inferred): .text 0x00594CF0..0x00595B3C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, GI_Panel, Types;

type
  TfAbout = class(TMessageLoopGI) // @size 0xE4
  public
    ScrollTimer: PCallbackTimerGI; // @offset 0xD0
    ViewportPanel: TPanelGI; // @offset 0xD4
    CreditsPanel: TPanelGI; // @offset 0xD8
    CreditsHeight: Integer; // @offset 0xDC
    FirstMusicSelection: Boolean; // @offset 0xE0
    ReturnToScores: Boolean; // @offset 0xE1

    procedure InitializeLayout; override; // @addr 0x594D84
    procedure OnOpen; override; // @addr 0x595488
    procedure OnClose; override; // @addr 0x5956EC
    procedure SelectMusic; override; // @addr 0x595AF8
    procedure ClearCredits; // @addr 0x595720
    procedure AddCreditLine(Text: WideString; Red, Green, Blue: Byte); // @addr 0x595744
    procedure AddCreditSeparator; // @addr 0x595890
    procedure AddCreditSpacing(Height: Integer); // @addr 0x5959D0
    procedure ScrollCredits(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x5959EC
    procedure CloseMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x595A6C
    procedure CloseKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x595AB8
  end;

implementation

uses Classes, EC_BlockPar, EC_Str, EC_Thread, GI_Image, GI_Label, GR_Main,
  Globals, GlobalsV, aConst, GR_Music;

{ @routine $594D84 TfAbout_InitializeLayout }
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
      Shift := LocalPosition.X * GameScreenWidth div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('LabelElemental') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('Logo1C') do
    begin
      Shift := LocalPosition.X * GameScreenWidth div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('Label1C') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('LogoKatauri') do
    begin
      Shift := LocalPosition.X * GameScreenWidth div 1024 - LocalPosition.X;
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    end;
    with FindByNameRecursive('LabelKatauri') do
      SetPosition(Classes.Point(LocalPosition.X + Shift, LocalPosition.Y + ExtraScreenHeight));
    with FindByNameRecursive('LogoSnk') do
    begin
      Shift := LocalPosition.X * GameScreenWidth div 1024 - LocalPosition.X;
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
{ @end $594D84 }

{ @routine $595488 TfAbout_OnOpen }
procedure TfAbout.OnOpen;
var
  Block: TBlockParEC;
  I, Count: Integer;
  Kind: WideString;
begin
  FirstMusicSelection := True;
  MusicManager.RequestFadeOut;
  if ScrollTimer <> nil then
  begin
    CancelCallbackTimer(ScrollTimer);
    ScrollTimer := nil;
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
{ @end $595488 }

{ @routine $5956EC TfAbout_OnClose }
procedure TfAbout.OnClose;
begin
  if ScrollTimer <> nil then
  begin
    CancelCallbackTimer(ScrollTimer);
    ScrollTimer := nil;
  end;
end;
{ @end $5956EC }

{ @routine $595720 TfAbout_ClearCredits }
procedure TfAbout.ClearCredits;
begin
  CreditsHeight := 0;
  CreditsPanel.FreeOwnedChildren;
end;
{ @end $595720 }

{ @routine $595744 TfAbout_AddCreditLine }
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
  LabelControl.SetTextAlignX(taxCenter);
  LabelControl.SetTextAlignY(tayAuto);
  LabelControl.SetText(Text);
  LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(Red, Green, Blue));
  LabelControl.SetTextAlignX(taxCenter);
  LabelControl.SetTextAlignY(tayCenter);
  LabelControl.SetSize(Classes.Point(LabelControl.ClientSize.X, LabelControl.ClientSize.Y + 4));
  CreditsHeight := CreditsHeight + LabelControl.ClientSize.Y;
end;
{ @end $595744 }

{ @routine $595890 TfAbout_AddCreditSeparator }
procedure TfAbout.AddCreditSeparator;
var
  Image: TImageGI;
begin
  Image := TImageGI.Create(CreditsPanel);
  Image.SetImagePath('GI,Bm.FormAbout2.' + GiResourceSuffix + 'Line');
  Image.SetPosition(Classes.Point(0, CreditsHeight));
  Image.SetSize(Classes.Point(ViewportPanel.ClientSize.X, Image.GetContentSize.Y + 4));
  Image.SetPositionModeW(False);
  Image.SetImageKindX(ikxCenter);
  Image.SetImageKindY(ikyCenter);
  CreditsHeight := CreditsHeight + Image.ClientSize.Y;
end;
{ @end $595890 }

{ @routine $5959D0 TfAbout_AddCreditSpacing }
procedure TfAbout.AddCreditSpacing(Height: Integer);
begin
  CreditsHeight := CreditsHeight + Height;
end;
{ @end $5959D0 }

{ @routine $5959EC TfAbout_ScrollCredits }
procedure TfAbout.ScrollCredits(Timer: PCallbackTimerGI; UserData: Integer);
begin
  CreditsPanel.SetPosition(Classes.Point(0, CreditsPanel.LocalPosition.Y - 1));
  if -CreditsPanel.LocalPosition.Y >= CreditsPanel.ClientSize.Y then
    CreditsPanel.SetPosition(Classes.Point(0, ViewportPanel.ClientSize.Y));
end;
{ @end $5959EC }

{ @routine $595A6C TfAbout_CloseMouseDown }
procedure TfAbout.CloseMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ReturnToScores then RequestedScreenId := screenScores
  else RequestedScreenId := screenMainMenu;
  RequestClose(1);
end;
{ @end $595A6C }

{ @routine $595AB8 TfAbout_CloseKeyDown }
procedure TfAbout.CloseKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if ReturnToScores then RequestedScreenId := screenScores
  else RequestedScreenId := screenMainMenu;
  RequestClose(1);
end;
{ @end $595AB8 }

{ @routine $595AF8 TfAbout_SelectMusic }
procedure TfAbout.SelectMusic;
begin
  if FirstMusicSelection then
  begin
    MusicManager.PlayCategory('Song');
    FirstMusicSelection := False;
  end
  else MusicManager.PlayCategory('Base');
end;
{ @end $595AF8 }

end.
