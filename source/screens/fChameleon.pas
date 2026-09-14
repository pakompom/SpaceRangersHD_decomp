unit fChameleon;
// Native TfChameleon VMT $50292C and callers establish this unit's ownership.

interface

uses Classes, Types, GI_MessageLoop, GI_Image;

type
  TfChameleon = class(TMessageLoopGI) // @size $F4
  public
    ChameleonActive: Boolean; // @offset $D0
    VisualType: Byte; // @offset $D1
    Charges: array[0..2] of Integer; // @offset $D4
    Choice: Integer; // @offset $E0 One-based: disable, Blazer, Keller, Terron.
    ChoiceImages: array[1..4] of TImageGI; // @offset $E4 Disabled choices have nil entries.
    procedure OnOpen; override; // @addr $502B7C
    procedure ProcessCallbackTimers; override; // @addr $503F70
    procedure AddChoice(Index, X: Integer; Y: Integer; Text: WideString; Selected, Disabled: Boolean); // @addr $5035A0
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $503934 @ida "void __userpurge $name(TfChameleon *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0.4>);"
    procedure ChoiceMouseEnter(Sender: TObjectGI); // @addr $503B5C
    procedure ChoiceMouseLeave(Sender: TObjectGI); // @addr $503C98
    procedure MoveChoice(Delta: Integer); // @addr $503E10
    procedure AcceptClicked(Sender: TObjectGI); // @addr $503E94
    procedure CancelClicked(Sender: TObjectGI); // @addr $503ECC
    procedure MainKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $503F04
  end;

function ShowChameleonDialog(Parent: TMessageLoopGI; BlazerCharges, KellerCharges: Integer; TerronCharges: Integer; VisualType: Byte; Active: Boolean; var Choice: Integer): Cardinal; // @addr $503FA4

implementation

uses Windows, SysUtils, EC_Str, EC_Struct, GI_Window, GI_Label, GI_GraphButton, GI_Main, GR_Main, GR_Sound, Globals, GlobalsV, aConst;

{ @routine $502B7C TfChameleon_OnOpen }
procedure TfChameleon.OnOpen;
var
  Y, Index: Integer;
  Window: TWindowGI;
  Caption: TLabelGI;
  AcceptButton, CancelButton: TGraphButtonGI;
  Size: TPoint;
  SeriesText, NameText, ShipName: WideString;
  Series: Byte;
  Disabled, NeedSelection, HasSelection: Boolean;
  WorkRect: TRect;

  // @nested $502978 ChameleonChargeUnavailable
  function ChameleonChargeUnavailable(Count: Integer): Boolean; // @addr $502978 @ida "bool __usercall $name@<al>(int Count@<eax>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x503138" Nested OnOpen helper; does not access its parent frame.
  begin
    if Count > 0 then Result := False else Result := True;
  end;

  // @nested $502998 FormatChameleonChargeCount
  function FormatChameleonChargeCount(Count: Integer): WideString; // @addr $502998 @ida "void __usercall $name(int Count@<eax>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x50318D"
  begin
    Result := ' (' + FormatText1(LocalizedText('ShipInfo.AddInfo.Chameleon.Count'),'','<Count>',IntToStr(Count)) + ')';
  end;

  // @nested $502AB4 ChameleonSeriesColor
  function ChameleonSeriesColor(Series: Byte): WideString; // @addr $502AB4 @ida "void __usercall $name(unsigned __int8 Series@<al>, unsigned __int16 **Result@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x503157"
  begin
    Result := '';
    case Series of
      0: Result := '<color=255,0,0>';
      1: Result := '<color=0,128,255>';
      2: Result := '<color=45,105,45>';
    end;
  end;

begin
  ContentPanel.KeyDownCallback := MainKeyDown;
  Window := TWindowGI.Create(ContentPanel);
  Window.SetDepth(1);
  Window.SetConfigPath('Style.Window.' + GiResourceSuffix + 'MessageBox');
  Window.SetSize(Classes.Point(280,200));
  Window.UpdateAutoGeometry;
  WorkRect := Window.WorkSubRect;
  Size := Window.ClientSize;
  AcceptButton := TGraphButtonGI.Create(ContentPanel);
  AcceptButton.EnterSound := 'Sound.ButtonEnter';
  AcceptButton.LeaveSound := 'Sound.ButtonLeave';
  AcceptButton.ClickSound := 'Sound.ButtonClick';
  AcceptButton.UpOnlyDown := True;
  AcceptButton.SetDepth(0);
  AcceptButton.SetImageNormalPath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'OkN');
  AcceptButton.SetImageNormalActivePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'OkA');
  AcceptButton.SetImageDownPath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'OkD');
  AcceptButton.SetSize(AcceptButton.GetMaxStateImageSize);
  AcceptButton.SetPosition(Classes.Point(Size.X div 2 - AcceptButton.ClientSize.X - GiScalePixels(5),Size.Y - WorkRect.Bottom - AcceptButton.ClientSize.Y));
  AcceptButton.HitKind := gbhRect;
  AcceptButton.UpdateStateImagePlacement;
  AcceptButton.UpdateStateVisuals;
  AcceptButton.UpCallback := AcceptClicked;
  CancelButton := TGraphButtonGI.Create(ContentPanel);
  CancelButton.EnterSound := 'Sound.ButtonEnter';
  CancelButton.LeaveSound := 'Sound.ButtonLeave';
  CancelButton.ClickSound := 'Sound.ButtonClick';
  CancelButton.UpOnlyDown := True;
  CancelButton.SetDepth(0);
  CancelButton.SetImageNormalPath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'CancelN');
  CancelButton.SetImageNormalActivePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'CancelA');
  CancelButton.SetImageDownPath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'CancelD');
  CancelButton.SetSize(CancelButton.GetMaxStateImageSize);
  CancelButton.SetPosition(Classes.Point(Size.X div 2 + GiScalePixels(5),Size.Y - WorkRect.Bottom - CancelButton.ClientSize.Y));
  CancelButton.HitKind := gbhRect;
  CancelButton.UpdateStateImagePlacement;
  CancelButton.UpdateStateVisuals;
  CancelButton.UpCallback := CancelClicked;
  Caption := TLabelGI.Create(ContentPanel);
  Caption.SetDepth(0);
  Caption.SetFontName(NormalFontName);
  Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  ShipName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[0] + '.' + IntToStr(VisualType));
  Caption.SetText(LocalizedText('ShipInfo.AddInfo.Chameleon.Name') + ' - ' + WrapTextInColor(ShipName,'<color=0,50,200>'));
  Caption.SetTextAlignX(taxCenter);
  Caption.SetTextAlignY(tayAuto);
  Caption.SetPosition(Classes.Point(0,WorkRect.Bottom));
  Caption.SetSize(Classes.Point(Window.ClientSize.X,1));
  Y := Caption.ClientSize.Y + 10;
  Index := 1;
  SeriesText := LocalizedText('ShipInfo.AddInfo.Chameleon.Series');
  Inc(Y,30);
  AddChoice(Index,20,Y,LocalizedText('ShipInfo.AddInfo.Chameleon.Disable'),ChameleonActive,not ChameleonActive);
  NeedSelection := not ChameleonActive;
  HasSelection := ChameleonActive;
  for Series := 0 to 2 do
  begin
    Inc(Y,20);
    Inc(Index);
    NameText := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[Series] + '.0');
    Disabled := ChameleonChargeUnavailable(Charges[Series]);
    AddChoice(Index,20,Y,SeriesText + ' ' + WrapTextInColor(NameText,ChameleonSeriesColor(Series)) + FormatChameleonChargeCount(Charges[Series]),NeedSelection and not Disabled,Disabled);
    if NeedSelection and not Disabled then
    begin
      NeedSelection := False;
      HasSelection := True;
    end;
  end;
  AcceptButton.SetDisabled(not HasSelection);
  ViewportRect.Left := (GameScreenWidth shr 1) - Size.X div 2;
  ViewportRect.Top := (GameScreenHeight shr 1) - Size.Y div 2;
  ViewportRect.Right := (GameScreenWidth shr 1) + Size.X div 2;
  ViewportRect.Bottom := (GameScreenHeight shr 1) + Size.Y div 2;
  ContentPanel.SetPosition(ViewportRect.TopLeft);
  ContentPanel.SetSize(Size);
  ContentPanel.UpdateAbsolutePosition;
  ContentPanel.UpdateSubtreeHitBounds;
end;
{ @end $502B7C }

{ @routine $5035A0 TfChameleon_AddChoice }
procedure TfChameleon.AddChoice(Index, X: Integer; Y: Integer; Text: WideString; Selected, Disabled: Boolean);
var
  Image: TImageGI;
  Caption: TLabelGI;
  Width: Integer;
begin
  Image := TImageGI.Create(ContentPanel);
  Image.SetName('ImgRadio');
  if Disabled then Image.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchH')
  else if not Selected then Image.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN')
  else
  begin
    Image.SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD');
    Choice := Index;
  end;
  Image.SetPosition(Classes.Point(X,Y));
  Image.SetSize(Image.GetContentSize);
  Image.SetImageKindY(ikyCenter);
  ChoiceImages[Index] := nil;
  if not Disabled then
  begin
    Image.LeftButtonDownCallback := ChoiceMouseDown;
    Image.MouseEnterCallback := ChoiceMouseEnter;
    Image.MouseLeaveCallback := ChoiceMouseLeave;
    Image.UserValue := Index;
    ChoiceImages[Index] := Image;
  end;
  Width := GiScalePixelsEx(300,300);
  Caption := TLabelGI.Create(ContentPanel);
  Caption.SetFontName(NormalFontName);
  Caption.SetPositionModeW(False);
  Caption.SetPosition(Classes.Point(X + Image.GetContentSize.X,Y));
  Caption.SetSize(Classes.Point(Width,1));
  Caption.SetTextAlignX(taxLeft);
  Caption.SetTextAlignY(tayAuto);
  Caption.SetText(Text);
  if Disabled then Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(127,127,127))
  else Caption.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  if not Disabled then
  begin
    Caption.LeftButtonDownCallback := ChoiceMouseDown;
    Caption.MouseEnterCallback := ChoiceMouseEnter;
    Caption.MouseLeaveCallback := ChoiceMouseLeave;
  end;
  Caption.UserValue := Integer(Image);
end;
{ @end $5035A0 }

{ @routine $503934 TfChameleon_ChoiceMouseDown }
procedure TfChameleon.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  Child: TObjectGI;
begin
  if Sender is TLabelGI then Sender := TObjectGI(Sender.UserValue);
  Child := ContentPanel.FirstChild;
  while Child <> nil do
  begin
    if (Child.ControlName = Sender.ControlName) and (Child is TImageGI) then
    begin
      if Child = Sender then
      begin
        (Child as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchD');
        Choice := (Child as TImageGI).UserValue;
      end
      else if (Child as TImageGI).UserValue <> 0 then
        (Child as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN');
    end;
    Child := Child.NextSibling;
  end;
  if (Point.X <> -1000) or (Point.Y <> -1000) then SoundManager.PlaySound('Sound.ButtonClick');
end;
{ @end $503934 }

{ @routine $503B5C TfChameleon_ChoiceMouseEnter }
procedure TfChameleon.ChoiceMouseEnter(Sender: TObjectGI);
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  if (Sender as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN' then
    (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA');
end;
{ @end $503B5C }

{ @routine $503C98 TfChameleon_ChoiceMouseLeave }
procedure TfChameleon.ChoiceMouseLeave(Sender: TObjectGI);
begin
  if not (Sender is TImageGI) then Sender := TObjectGI(Sender.UserValue);
  if (Sender as TImageGI).GetImagePath = 'GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchA' then
    (Sender as TImageGI).SetImagePath('GI,Bm.FormOptions2.' + GiResourceSuffix + 'SwitchN');
end;
{ @end $503C98 }

{ @routine $503E10 TfChameleon_MoveChoice }
procedure TfChameleon.MoveChoice(Delta: Integer);
var
  Index: Integer;
  // @nested $503DD4 Advance
  procedure Advance; // @addr $503DD4 @ida "void __usercall $name(void *ParentFrame@<^0>);" @stackpop 0 @calls "0x503E29,0x503E32"
  begin
    Index := Index + Delta;
    if Index < 1 then Index := 4
    else if Index > 4 then Index := 1;
  end;
begin
  Index := Choice;
  Advance;
  while (ChoiceImages[Index] = nil) and (Index <> Choice) do Advance;
  if ChoiceImages[Index] <> nil then ChoiceMouseDown(ChoiceImages[Index],0,ChoiceImages[Index].LocalPosition);
end;
{ @end $503E10 }

{ @routine $503E94 TfChameleon_AcceptClicked }
procedure TfChameleon.AcceptClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(1) else RequestClose(ExitCode);
end;
{ @end $503E94 }

{ @routine $503ECC TfChameleon_CancelClicked }
procedure TfChameleon.CancelClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
end;
{ @end $503ECC }

{ @routine $503F04 TfChameleon_MainKeyDown }
procedure TfChameleon.MainKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if (Key = VK_ESCAPE) or (Key = Ord('N')) then CancelClicked(Sender)
  else if (Key = VK_RETURN) or (Key = Ord('Y')) then AcceptClicked(Sender)
  else if Key = VK_UP then MoveChoice(-1)
  else if Key = VK_DOWN then MoveChoice(1);
end;
{ @end $503F04 }

{ @routine $503F70 TfChameleon_ProcessCallbackTimers }
procedure TfChameleon.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $503F70 }

{ @routine $503FA4 ShowChameleonDialog }
function ShowChameleonDialog(Parent: TMessageLoopGI; BlazerCharges, KellerCharges: Integer; TerronCharges: Integer; VisualType: Byte; Active: Boolean; var Choice: Integer): Cardinal;
var
  Dialog: TfChameleon;
  CursorState: TCursorStateGI;
begin
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@CursorState);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  Dialog := TfChameleon.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeDefaults;
  try
    Dialog.ChameleonActive := Active;
    Dialog.VisualType := VisualType;
    Dialog.Charges[0] := BlazerCharges;
    Dialog.Charges[1] := KellerCharges;
    Dialog.Charges[2] := TerronCharges;
    Result := Dialog.Run;
    Choice := Dialog.Choice;
    Parent.InvalidateViewport;
  finally
    Parent.ChildLoop := nil;
    Dialog.Free;
  end;
  Parent.RestoreCursorState(@CursorState);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.NativeHook48;
  if Result = 254 then BreakUiMessage;
end;
{ @end $503FA4 }

end.
