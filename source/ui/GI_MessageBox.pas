unit GI_MessageBox;
// Unit bracket (inferred): .text 0x004D7418..0x004D8530; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native routines $4D74C4..$4D8531; dialog VMT and managed-field table precede OnOpen.

interface

uses GI_MessageLoop;

const
  // Native OnOpen ($4D74C4) reads the button, icon and text-alignment bits.
  mbgOK = $01;
  mbgCancel = $02;
  mbgUnused04 = $04; // Present in callers; no recovered reader.
  mbgWarning = $08;
  mbgQuestion = $10;
  mbgError = $20;
  mbgLeftAlign = $40;
  // Native AcceptClick / CancelClick return these when no exit is pending.
  mbgResultOK = 1;
  mbgResultCancel = 2;

type
  TMessageBoxGI = class(TMessageLoopGI) // @size $E4
  public
    MessageText: WideString; // @offset $D0
    Options: Cardinal; // @offset $D4 // mbg* option bits.
    UnusedOption: Integer; // @offset $D8 // Stored by ShowMessageBoxGI; no recovered reader.
    OffsetX: Integer; // @offset $DC
    OffsetY: Integer; // @offset $E0
    procedure OnOpen; override; // @addr $4D74C4
    procedure AcceptClick(Sender: TObjectGI); // @addr $4D82B8
    procedure CancelClick(Sender: TObjectGI); // @addr $4D82F0
    procedure DialogKeyDown(Sender: TObjectGI; VirtualKey: Cardinal); // @addr $4D8328
    procedure ProcessCallbackTimers; override; // @addr $4D83A4
  end;

function ShowMessageBoxGI(Parent: TMessageLoopGI; const Text: WideString; Options: Cardinal; UnusedOption: Integer = 0; OffsetX: Integer = 0; OffsetY: Integer = 0): Cardinal; // @addr $4D83D8

implementation

uses aMyFunction, Classes, EC_Str, GI_GraphButton, GI_Image, GI_Label, GI_Main, GI_Window,
  Globals, GR_Main, Types, Windows;

{ @routine $4D74C4 TMessageBoxGI_OnOpen }
procedure TMessageBoxGI.OnOpen;
var
  Window: TWindowGI;
  TextLabel: TLabelGI;
  AcceptButton, CancelButton: TGraphButtonGI;
  Icon, Light: TImageGI;
  TextSize, WindowSize, CandidateSize: TPoint;
  BottomMargin: Integer;
  VerticalFactor, TargetRatio, ActualRatio: Single;
  Attempts, IconTop: Integer;
  Borders: TRect;
begin
  VerticalFactor := 0.4;
  TargetRatio := 1.6178011;
  BottomMargin := GiScalePixels(35);
  ContentPanel.KeyDownCallback := DialogKeyDown;
  Window := TWindowGI.Create(ContentPanel);
  Window.SetDepth(1);
  Window.SetConfigPath('Style.Window.' + GiResourceSuffix + 'MessageBox');
  Borders := Window.WorkSubRect;
  CandidateSize := Window.AlignSizeToBorderTiles(Classes.Point(0, 0));
  Light := TImageGI.Create(ContentPanel);
  if Options and mbgWarning = mbgWarning then Light.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightRed')
  else if Options and mbgQuestion = mbgQuestion then Light.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightBlue')
  else if Options and mbgError = mbgError then Light.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightRed')
  else Light.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightBlue');
  Light.SetSize(Light.GetContentSize);
  Icon := TImageGI.Create(ContentPanel);
  if Options and mbgWarning = mbgWarning then Icon.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Warning')
  else if Options and mbgQuestion = mbgQuestion then Icon.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Question')
  else if Options and mbgError = mbgError then Icon.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Error')
  else Icon.SetImagePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Info');
  Icon.SetSize(Icon.GetContentSize);
  Icon.SetPosition(Classes.Point(Borders.Left, Borders.Top));
  TextLabel := TLabelGI.Create(ContentPanel);
  TextLabel.SetDepth(0);
  TextLabel.SetFontName(NormalFontName);
  TextLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  TextLabel.SetText(ReplaceAllWideString(ReplaceAllWideString(MessageText,
    TextHighlightColorTag, DialogHighlightColorTag), GreenColorTag, YellowColorTag));
  Attempts := 100;
  while Attempts > 0 do
  begin
    TextLabel.SetTextAlignX(taxCenter);
    TextLabel.SetTextAlignY(tayCenter);
    TextLabel.SetSize(Classes.Point(CandidateSize.X - Borders.Left - Borders.Right - Icon.ClientSize.X - GiScalePixels(10), 1));
    TextLabel.SetWordWrapEnabled(True);
    TextLabel.SetTextAlignX(taxLeft);
    TextLabel.SetTextAlignY(tayAuto);
    TextSize := TextLabel.ClientSize;
    Window.SetPosition(Classes.Point(0, 0));
    Window.SetSize(Classes.Point(TextSize.X + Borders.Left + Borders.Right + Icon.ClientSize.X + GiScalePixels(10),
      TextSize.Y + Borders.Top + Borders.Bottom + BottomMargin));
    Window.UpdateAutoGeometry;
    WindowSize := Window.ClientSize;
    ActualRatio := WindowSize.X / WindowSize.Y;
    if ActualRatio - TargetRatio < -0.1 then Inc(CandidateSize.X, 10)
    else if ActualRatio - TargetRatio > 0.1 then Inc(CandidateSize.Y, 10)
    else Break;
    Dec(Attempts);
  end;
  if Options and mbgOK = mbgOK then
  begin
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
    if Options and mbgCancel <> mbgCancel then
      AcceptButton.SetPosition(Classes.Point(WindowSize.X div 2 - AcceptButton.ClientSize.X div 2,
        WindowSize.Y - Borders.Bottom - AcceptButton.ClientSize.Y))
    else
      AcceptButton.SetPosition(Classes.Point(WindowSize.X div 2 - AcceptButton.ClientSize.X - GiScalePixels(5),
        WindowSize.Y - Borders.Bottom - AcceptButton.ClientSize.Y));
    AcceptButton.HitKind := gbhRect;
    AcceptButton.UpdateStateImagePlacement;
    AcceptButton.UpdateStateVisuals;
    AcceptButton.UpCallback := AcceptClick;
  end;
  if Options and mbgCancel = mbgCancel then
  begin
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
    if Options and mbgOK <> mbgOK then
      CancelButton.SetPosition(Classes.Point(WindowSize.X div 2 - CancelButton.ClientSize.X div 2,
        WindowSize.Y - Borders.Bottom - CancelButton.ClientSize.Y))
    else
      CancelButton.SetPosition(Classes.Point(WindowSize.X div 2 + GiScalePixels(5),
        WindowSize.Y - Borders.Bottom - CancelButton.ClientSize.Y));
    CancelButton.HitKind := gbhRect;
    CancelButton.UpdateStateImagePlacement;
    CancelButton.UpdateStateVisuals;
    CancelButton.UpCallback := CancelClick;
  end;
  ViewportRect.Left := GameScreenWidth shr 1 + OffsetX - WindowSize.X div 2;
  ViewportRect.Top := GameScreenHeight shr 1 + OffsetY - WindowSize.Y div 2;
  ViewportRect.Right := GameScreenWidth shr 1 + OffsetX + WindowSize.X div 2;
  ViewportRect.Bottom := GameScreenHeight shr 1 + OffsetY + WindowSize.Y div 2;
  ContentPanel.SetPosition(ViewportRect.TopLeft);
  ContentPanel.SetSize(WindowSize);
  ContentPanel.UpdateAbsolutePosition;
  ContentPanel.UpdateSubtreeHitBounds;
  if Options and mbgLeftAlign = mbgLeftAlign then TextLabel.SetTextAlignX(taxLeft)
  else TextLabel.SetTextAlignX(taxCenter);
  TextLabel.SetTextAlignY(tayAuto);
  TextLabel.SetPosition(Classes.Point(Icon.ClientSize.X + Borders.Left + GiScalePixels(10),
    Integer(Round((WindowSize.Y - Borders.Top - Borders.Bottom - BottomMargin - TextLabel.ClientSize.Y) * VerticalFactor)) + Borders.Top));
  Icon.SetPosition(Classes.Point(Icon.LocalPosition.X, TextLabel.LocalPosition.Y));
  if Icon.LocalPosition.Y + Icon.ClientSize.Y > TextLabel.LocalPosition.Y + TextLabel.ClientSize.Y then
  begin
    if TextLabel.LocalPosition.Y - (Icon.ClientSize.Y div 2 - TextLabel.ClientSize.Y div 2) < Borders.Top then IconTop := Borders.Top
    else IconTop := TextLabel.LocalPosition.Y - (Icon.ClientSize.Y div 2 - TextLabel.ClientSize.Y div 2);
    Icon.SetPosition(Classes.Point(Icon.LocalPosition.X, IconTop));
  end;
  Light.SetPosition(Classes.Point(WindowSize.X div 2 - Light.ClientSize.X div 2, 0));
  TextSize := TextLabel.MeasureContentSize(nil);
end;
{ @end $4D74C4 }

{ @routine $4D82B8 TMessageBoxGI_AcceptClick }
procedure TMessageBoxGI.AcceptClick(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(mbgResultOK) else RequestClose(ExitCode);
end;
{ @end $4D82B8 }

{ @routine $4D82F0 TMessageBoxGI_CancelClick }
procedure TMessageBoxGI.CancelClick(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(mbgResultCancel) else RequestClose(ExitCode);
end;
{ @end $4D82F0 }

{ @routine $4D8328 TMessageBoxGI_DialogKeyDown }
procedure TMessageBoxGI.DialogKeyDown(Sender: TObjectGI; VirtualKey: Cardinal);
begin
  if (Options and mbgCancel = mbgCancel) and ((VirtualKey = VK_ESCAPE) or (VirtualKey = Ord('N')) or ((VirtualKey = VK_RETURN) and (Options and mbgOK <> mbgOK))) then
    CancelClick(Sender)
  else if (Options and mbgOK = mbgOK) and ((VirtualKey = VK_RETURN) or (VirtualKey = Ord('Y'))) then
    AcceptClick(Sender);
end;
{ @end $4D8328 }

{ @routine $4D83A4 TMessageBoxGI_ProcessCallbackTimers }
procedure TMessageBoxGI.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $4D83A4 }

{ @routine $4D83D8 ShowMessageBoxGI }
function ShowMessageBoxGI(Parent: TMessageLoopGI; const Text: WideString; Options: Cardinal; UnusedOption, OffsetX, OffsetY: Integer): Cardinal;
var
  Dialog: TMessageBoxGI;
  CursorState: TCursorStateGI;
begin
  Parent.RootUiObject.OnModalSuspend;
  Parent.CaptureCursorState(@CursorState);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  Dialog := TMessageBoxGI.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeDefaults;
  try
    Dialog.MessageText := Text;
    Dialog.Options := Options;
    Dialog.UnusedOption := UnusedOption;
    Dialog.OffsetX := OffsetX;
    Dialog.OffsetY := OffsetY;
    Result := Dialog.Run;
    Parent.InvalidateViewport;
  finally
    Parent.ChildLoop := nil;
    Dialog.Free;
  end;
  Parent.RestoreCursorState(@CursorState);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.OnModalResume;
  if Result = 254 then BreakUiMessage;
end;
{ @end $4D83D8 }

end.
