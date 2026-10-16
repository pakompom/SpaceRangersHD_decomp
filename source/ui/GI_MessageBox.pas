unit GI_MessageBox;

interface

uses GI_MessageLoop;

const
  // Native OnOpen ($4D74B8) reads the button, icon and text-alignment bits.
  messagebox_ok = $01;
  messagebox_cancel = $02;
  messagebox_info = $04; // Documented IconInfo marker; Info is the fallback, with no explicit bit test.
  messagebox_warning = $08;
  messagebox_question = $10;
  messagebox_error = $20;
  messagebox_align_left = $40;
  // Native AcceptClick / CancelClick return these when no exit is pending.
  messagebox_result_ok = 1;
  messagebox_result_cancel = 2;

type
  TMessageBoxGI = class(TMessageLoopGI) // @size $E4
  public
    MessageText: WideString; // @offset $D0
    Options: Cardinal; // @offset $D4 Button, icon and text-alignment option bits.
    UnusedOption: Integer; // @offset $D8 // Stored by ShowMessageBoxGI; no recovered reader.
    OffsetX: Integer; // @offset $DC
    OffsetY: Integer; // @offset $E0
    procedure OnOpen; override; // @addr $4D74B8
    procedure AcceptClick(Sender: TObjectGI); // @addr $4D81DC
    procedure CancelClick(Sender: TObjectGI); // @addr $4D81F4
    procedure DialogKeyDown(Sender: TObjectGI; VirtualKey: Cardinal); // @addr $4D820C
    procedure ProcessCallbackTimers; override; // @addr $4D8260
  end;

function ShowMessageBoxGI(Parent: TMessageLoopGI; const Text: WideString; Options: Cardinal; UnusedOption: Integer = 0; OffsetX: Integer = 0; OffsetY: Integer = 0): Cardinal; // @addr $4D8288

implementation

uses aMyFunction, Classes, EC_Str, GI_GraphButton, GI_Image, GI_Label, GI_Main, GI_Window,
  Globals, GR_Main, Types, Windows;

{ @routine $4D74B8 TMessageBoxGI_OnOpen }
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
  Window.Style := 'Style.Window.' + GiResourceSuffix + 'MessageBox';
  Borders := Window.WorkSubRect;
  CandidateSize := Window.AlignSizeToBorderTiles(Classes.Point(0, 0));
  Light := TImageGI.Create(ContentPanel);
  if Options and messagebox_warning = messagebox_warning then Light.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightRed'
  else if Options and messagebox_question = messagebox_question then Light.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightBlue'
  else if Options and messagebox_error = messagebox_error then Light.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightRed'
  else Light.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'LightBlue';
  Light.ObjectSize := Light.GetContentSize;
  Icon := TImageGI.Create(ContentPanel);
  if Options and messagebox_warning = messagebox_warning then Icon.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Warning'
  else if Options and messagebox_question = messagebox_question then Icon.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Question'
  else if Options and messagebox_error = messagebox_error then Icon.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Error'
  else Icon.ImageSourcePath := 'GI,Bm.FormMessageBox.' + GiResourceSuffix + 'Info';
  Icon.ObjectSize := Icon.GetContentSize;
  Icon.Pos := Classes.Point(Borders.Left, Borders.Top);
  TextLabel := TLabelGI.Create(ContentPanel);
  TextLabel.SetDepth(0);
  TextLabel.SetFontName(NormalFontName);
  TextLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  TextLabel.Text := ReplaceAllWideString(ReplaceAllWideString(MessageText,
    TextHighlightColorTag, DialogHighlightColorTag), GreenColorTag, YellowColorTag);
  Attempts := 100;
  while Attempts > 0 do
  begin
    TextLabel.SetTextAlignX(text_x_center);
    TextLabel.SetTextAlignY(text_y_center);
    TextLabel.ObjectSize := Classes.Point(CandidateSize.X - Borders.Left - Borders.Right - Icon.ClientSize.X - GiScalePixels(10), 1);
    TextLabel.SetWordWrapEnabled(True);
    TextLabel.SetTextAlignX(text_x_left);
    TextLabel.SetTextAlignY(text_y_fit_height);
    TextSize := TextLabel.ClientSize;
    Window.Pos := Classes.Point(0, 0);
    Window.ObjectSize := Classes.Point(TextSize.X + Borders.Left + Borders.Right + Icon.ClientSize.X + GiScalePixels(10),
      TextSize.Y + Borders.Top + Borders.Bottom + BottomMargin);
    Window.UpdateAutoGeometry;
    WindowSize := Window.ClientSize;
    ActualRatio := WindowSize.X / WindowSize.Y;
    if ActualRatio - TargetRatio < -0.1 then Inc(CandidateSize.X, 10)
    else if ActualRatio - TargetRatio > 0.1 then Inc(CandidateSize.Y, 10)
    else Break;
    Dec(Attempts);
  end;
  if Options and messagebox_ok = messagebox_ok then
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
    AcceptButton.ObjectSize := AcceptButton.GetMaxStateImageSize;
    if Options and messagebox_cancel <> messagebox_cancel then
      AcceptButton.Pos := Classes.Point(WindowSize.X div 2 - AcceptButton.ClientSize.X div 2,
        WindowSize.Y - Borders.Bottom - AcceptButton.ClientSize.Y)
    else
      AcceptButton.Pos := Classes.Point(WindowSize.X div 2 - AcceptButton.ClientSize.X - GiScalePixels(5),
        WindowSize.Y - Borders.Bottom - AcceptButton.ClientSize.Y);
    AcceptButton.HitKind := button_hit_bounds;
    AcceptButton.UpdateStateImagePlacement;
    AcceptButton.UpdateStateVisuals;
    AcceptButton.UpCallback := AcceptClick;
  end;
  if Options and messagebox_cancel = messagebox_cancel then
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
    CancelButton.ObjectSize := CancelButton.GetMaxStateImageSize;
    if Options and messagebox_ok <> messagebox_ok then
      CancelButton.Pos := Classes.Point(WindowSize.X div 2 - CancelButton.ClientSize.X div 2,
        WindowSize.Y - Borders.Bottom - CancelButton.ClientSize.Y)
    else
      CancelButton.Pos := Classes.Point(WindowSize.X div 2 + GiScalePixels(5),
        WindowSize.Y - Borders.Bottom - CancelButton.ClientSize.Y);
    CancelButton.HitKind := button_hit_bounds;
    CancelButton.UpdateStateImagePlacement;
    CancelButton.UpdateStateVisuals;
    CancelButton.UpCallback := CancelClick;
  end;
  ViewportRect.Left := GameScreenWidth shr 1 + OffsetX - WindowSize.X div 2;
  ViewportRect.Top := GameScreenHeight shr 1 + OffsetY - WindowSize.Y div 2;
  ViewportRect.Right := GameScreenWidth shr 1 + OffsetX + WindowSize.X div 2;
  ViewportRect.Bottom := GameScreenHeight shr 1 + OffsetY + WindowSize.Y div 2;
  ContentPanel.Pos := ViewportRect.TopLeft;
  ContentPanel.ObjectSize := WindowSize;
  ContentPanel.UpdateAbsolutePosition;
  ContentPanel.UpdateSubtreeHitBounds;
  if Options and messagebox_align_left = messagebox_align_left then TextLabel.SetTextAlignX(text_x_left)
  else TextLabel.SetTextAlignX(text_x_center);
  TextLabel.SetTextAlignY(text_y_fit_height);
  TextLabel.Pos := Classes.Point(Icon.ClientSize.X + Borders.Left + GiScalePixels(10),
    Integer(Round((WindowSize.Y - Borders.Top - Borders.Bottom - BottomMargin - TextLabel.ClientSize.Y) * VerticalFactor)) + Borders.Top);
  Icon.Pos := Classes.Point(Icon.LocalPosition.X, TextLabel.LocalPosition.Y);
  if Icon.LocalPosition.Y + Icon.ClientSize.Y > TextLabel.LocalPosition.Y + TextLabel.ClientSize.Y then
  begin
    if TextLabel.LocalPosition.Y - (Icon.ClientSize.Y div 2 - TextLabel.ClientSize.Y div 2) < Borders.Top then IconTop := Borders.Top
    else IconTop := TextLabel.LocalPosition.Y - (Icon.ClientSize.Y div 2 - TextLabel.ClientSize.Y div 2);
    Icon.Pos := Classes.Point(Icon.LocalPosition.X, IconTop);
  end;
  Light.Pos := Classes.Point(WindowSize.X div 2 - Light.ClientSize.X div 2, 0);
  TextSize := TextLabel.MeasureContentSize(nil);
end;
{ @end $4D74B8 }

{ @routine $4D81DC TMessageBoxGI_AcceptClick }
procedure TMessageBoxGI.AcceptClick(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(messagebox_result_ok) else RequestClose(ExitCode);
end;
{ @end $4D81DC }

{ @routine $4D81F4 TMessageBoxGI_CancelClick }
procedure TMessageBoxGI.CancelClick(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(messagebox_result_cancel) else RequestClose(ExitCode);
end;
{ @end $4D81F4 }

{ @routine $4D820C TMessageBoxGI_DialogKeyDown }
procedure TMessageBoxGI.DialogKeyDown(Sender: TObjectGI; VirtualKey: Cardinal);
begin
  if (Options and messagebox_cancel = messagebox_cancel) and ((VirtualKey = VK_ESCAPE) or (VirtualKey = Ord('N')) or ((VirtualKey = VK_RETURN) and (Options and messagebox_ok <> messagebox_ok))) then
    CancelClick(Sender)
  else if (Options and messagebox_ok = messagebox_ok) and ((VirtualKey = VK_RETURN) or (VirtualKey = Ord('Y'))) then
    AcceptClick(Sender);
end;
{ @end $4D820C }

{ @routine $4D8260 TMessageBoxGI_ProcessCallbackTimers }
procedure TMessageBoxGI.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $4D8260 }

{ @routine $4D8288 ShowMessageBoxGI }
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
{ @end $4D8288 }

end.
