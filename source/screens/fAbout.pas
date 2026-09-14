unit fAbout;
// Unit bracket (inferred): .text 0x005D137C..0x005D21C8; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    procedure InitializeLayout; override; // @addr 0x5D1410
    procedure OnOpen; override; // @addr 0x5D1B14
    procedure OnClose; override; // @addr 0x5D1D78
    procedure SelectMusic; override; // @addr 0x5D2184
    procedure ClearCredits; // @addr 0x5D1DAC
    procedure AddCreditLine(Text: WideString; Red, Green, Blue: Byte); // @addr 0x5D1DD0
    procedure AddCreditSeparator; // @addr 0x5D1F1C
    procedure AddCreditSpacing(Height: Integer); // @addr 0x5D205C
    procedure ScrollCredits(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x5D2078
    procedure CloseMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr 0x5D20F8 @ida "void __userpurge $name(TfAbout *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure CloseKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr 0x5D2144
  end;

implementation

uses Classes, EC_BlockPar, EC_Str, EC_Thread, GI_Image, GI_Label, GR_Main,
  Globals, GlobalsV, aConst, GR_Music;

{ @routine $5D1410 TfAbout_InitializeLayout }
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
{ @end $5D1410 }

{ @routine $5D1B14 TfAbout_OnOpen }
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
{ @end $5D1B14 }

{ @routine $5D1D78 TfAbout_OnClose }
procedure TfAbout.OnClose;
begin
  if ScrollTimer <> nil then
  begin
    CancelCallbackTimer(ScrollTimer);
    ScrollTimer := nil;
  end;
end;
{ @end $5D1D78 }

{ @routine $5D1DAC TfAbout_ClearCredits }
procedure TfAbout.ClearCredits;
begin
  CreditsHeight := 0;
  CreditsPanel.FreeOwnedChildren;
end;
{ @end $5D1DAC }

{ @routine $5D1DD0 TfAbout_AddCreditLine }
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
{ @end $5D1DD0 }

{ @routine $5D1F1C TfAbout_AddCreditSeparator }
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
{ @end $5D1F1C }

{ @routine $5D205C TfAbout_AddCreditSpacing }
procedure TfAbout.AddCreditSpacing(Height: Integer);
begin
  CreditsHeight := CreditsHeight + Height;
end;
{ @end $5D205C }

{ @routine $5D2078 TfAbout_ScrollCredits }
procedure TfAbout.ScrollCredits(Timer: PCallbackTimerGI; UserData: Integer);
begin
  CreditsPanel.SetPosition(Classes.Point(0, CreditsPanel.LocalPosition.Y - 1));
  if -CreditsPanel.LocalPosition.Y >= CreditsPanel.ClientSize.Y then
    CreditsPanel.SetPosition(Classes.Point(0, ViewportPanel.ClientSize.Y));
end;
{ @end $5D2078 }

{ @routine $5D20F8 TfAbout_CloseMouseDown }
procedure TfAbout.CloseMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if ReturnToScores then RequestedScreenId := screenScores
  else RequestedScreenId := screenMainMenu;
  RequestClose(1);
end;
{ @end $5D20F8 }

{ @routine $5D2144 TfAbout_CloseKeyDown }
procedure TfAbout.CloseKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if ReturnToScores then RequestedScreenId := screenScores
  else RequestedScreenId := screenMainMenu;
  RequestClose(1);
end;
{ @end $5D2144 }

{ @routine $5D2184 TfAbout_SelectMusic }
procedure TfAbout.SelectMusic;
begin
  if FirstMusicSelection then
  begin
    MusicManager.PlayCategory('Song');
    FirstMusicSelection := False;
  end
  else MusicManager.PlayCategory('Base');
end;
{ @end $5D2184 }

end.
