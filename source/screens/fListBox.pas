unit fListBox;

interface

uses Classes, Types, GI_MessageLoop, GI_GraphButton, GI_PanelScrollBar;

type
  TfListBox = class(TMessageLoopGI) // @size $F0
  public
    SelectedIndex: Integer; // @offset $D0 Reset to -1 on opening; set only on acceptance.
    AcceptButton: TGraphButtonGI; // @offset $D4
    ScrollPanel: TPanelScrollBarGI; // @offset $D8
    SelectedControl: TObjectGI; // @offset $DC
    Caption: WideString; // @offset $E0
    Items: TList; // @offset $E4 Borrowed PWideString entries.
    OffsetX: Integer; // @offset $E8
    OffsetY: Integer; // @offset $EC
    constructor Create; override; // @addr $5090DC @ida "TfListBox *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $509120 @ida "void __usercall $name(TfListBox *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnOpen; override; // @addr $509154
    procedure OnClose; override; // @addr $509A28
    procedure PopulateChoices; // @addr $509A34
    procedure AcceptClicked(Sender: TObjectGI); // @addr $509C64
    procedure CancelClicked(Sender: TObjectGI); // @addr $509CB8
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $509CD8 @ida "void __userpurge $name(TfListBox *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $509D4C @ida "void __userpurge $name(TfListBox *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ChoiceDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $509DF0 @ida "void __userpurge $name(TfListBox *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ProcessCallbackTimers; override; // @addr $509E1C
  end;

// Native TfListBox VMT $509080 confirms the inferred unit ownership.
function ShowListDialog(Parent: TMessageLoopGI; var SelectedIndex: Integer; Caption: WideString; Items: TList; OffsetX, OffsetY: Integer): Cardinal; // @addr $509E50 @note "Borrows a list of PWideString choices; copies the selection back and clears the dialog's borrowed list before freeing it."

implementation

uses Windows, GI_Window, GI_Frame, GI_Label, GI_Panel, GI_Main, GR_Main, Globals, GlobalsV;


{ @routine $5090DC TfListBox_Create }
constructor TfListBox.Create;
begin
  inherited;
end;
{ @end $5090DC }

{ @routine $509120 TfListBox_Destroy }
destructor TfListBox.Destroy;
begin
  inherited;
end;
{ @end $509120 }

{ @routine $509154 TfListBox_OnOpen }
procedure TfListBox.OnOpen;
var
  Window: TWindowGI;
  CancelButton: TGraphButtonGI;
  CaptionLabel: TLabelGI;
  Size: TPoint;
  Insets: TRect;
begin
  SelectedIndex := -1;
  SelectedControl := nil;
  Window := TWindowGI.Create(ContentPanel);
  Window.SetDepth(1);
  Window.SetConfigPath('Style.Window.' + GiResourceSuffix + 'MessageBox');
  Window.SetSize(Classes.Point(GiScalePixels(250),GiScalePixels(400)));
  Window.UpdateAutoGeometry;
  Insets := Window.WorkSubRect;
  Size := Window.ClientSize;
  AcceptButton := TGraphButtonGI.Create(ContentPanel);
  with AcceptButton do
  begin
   EnterSound := 'Sound.ButtonEnter';
   LeaveSound := 'Sound.ButtonLeave';
   ClickSound := 'Sound.ButtonClick';
   UpOnlyDown := True;
   SetDepth(0);
   SetImageNormalPath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'OkN');
   SetImageNormalActivePath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'OkA');
   SetImageDownPath('GI,Bm.FormMessageBox.' + GiResourceSuffix + 'OkD');
    SetSize(Self.AcceptButton.GetMaxStateImageSize);
    SetPosition(Classes.Point(Size.X div 2 - Self.AcceptButton.ClientSize.X - GiScalePixels(5),Size.Y - Insets.Bottom - Self.AcceptButton.ClientSize.Y));
    HitKind := gbhRect;
    UpdateStateImagePlacement;
    UpdateStateVisuals;
    UpCallback := AcceptClicked;
  end;
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
  CancelButton.SetPosition(Classes.Point(Size.X div 2 + GiScalePixels(5),Size.Y - Insets.Bottom - CancelButton.ClientSize.Y));
  CancelButton.HitKind := gbhRect;
  CancelButton.UpdateStateImagePlacement;
  CancelButton.UpdateStateVisuals;
  CancelButton.UpCallback := CancelClicked;
  CaptionLabel := TLabelGI.Create(ContentPanel);
  Window.SetDepth(2);
  CaptionLabel.SetText(Caption);
  CaptionLabel.SetSize(Classes.Point(Size.X,GiScalePixels(21)));
  CaptionLabel.SetPosition(Classes.Point(0,GiScalePixels(30)));
  CaptionLabel.SetTextAlignX(taxCenter);
  CaptionLabel.SetTextAlignY(tayCenter);
  CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  CaptionLabel.SetFontName(NormalBoldFontName);
  ScrollPanel := TPanelScrollBarGI.Create(Window);
  with ScrollPanel do
  begin
    SetDepth(9);
    SetUnlimitedWorldEnabled(False);
    SetScrollbarsOutside(True);
    SetVerticalScrollBarConfigPath('Style.ScrollBar.' + GiResourceSuffix + 'PQS2');
    SetHorizontalScrollbarEnabled(False);
    SetVerticalScrollbarEnabled(True);
    SetPosition(Classes.Point(Insets.Left + GiScalePixels(10),CaptionLabel.LocalPosition.Y + CaptionLabel.ClientSize.Y + GiScalePixels(10)));
    SetSize(Classes.Point(Size.X - Insets.Right - LocalPosition.X - VerticalScrollBar.ClientSize.X - GiScalePixels(10),AcceptButton.LocalPosition.Y - LocalPosition.Y - GiScalePixels(15)));
    ScrollAxis := psaVertical;
  end;
  with TFrameGI.Create(Window) do
  begin
    SetPosition(Classes.Point(ScrollPanel.LocalPosition.X - 1,ScrollPanel.LocalPosition.Y - 1));
    SetSize(Classes.Point(ScrollPanel.ClientSize.X - 1,ScrollPanel.ClientSize.Y + 2));
    SetDepth(8);
    SetKind(fkRect);
    SetColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  end;
  PopulateChoices;
  ViewportRect.Left := (GameScreenWidth shr 1) + OffsetX - Size.X div 2;
  ViewportRect.Top := (GameScreenHeight shr 1) + OffsetY - Size.Y div 2;
  ViewportRect.Right := (GameScreenWidth shr 1) + OffsetX + Size.X div 2;
  ViewportRect.Bottom := (GameScreenHeight shr 1) + OffsetY + Size.Y div 2;
  ContentPanel.SetPosition(ViewportRect.TopLeft);
  ContentPanel.SetSize(Size);
  ContentPanel.UpdateAbsolutePosition;
  ContentPanel.UpdateSubtreeHitBounds;
end;
{ @end $509154 }

{ @routine $509A28 TfListBox_OnClose }
procedure TfListBox.OnClose;
begin

end;
{ @end $509A28 }

{ @routine $509A34 TfListBox_PopulateChoices }
procedure TfListBox.PopulateChoices;
var
  I, Count, Y: Integer;
  Row: TPanelGI;
  LabelControl: TLabelGI;
begin
  Y := 0;
  Count := Items.Count;
  for I := 0 to Count - 1 do
  begin
    Row := TPanelGI.Create(ScrollPanel);
    Row.SetPositionModeW(True);
    Row.SetPosition(Classes.Point(0,Y));
    Row.SetSize(Classes.Point(ScrollPanel.ClientSize.X,GiScalePixels(15)));
    LabelControl := TLabelGI.Create(Row);
    LabelControl.SetPosition(Classes.Point(0,0));
    LabelControl.SetTextAlignX(taxLeft);
    LabelControl.SetTextAlignY(tayCenterEx);
    LabelControl.SetWordWrapEnabled(False);
    LabelControl.SetSize(Row.ClientSize);
    LabelControl.SetFontName(NormalFontName);
    LabelControl.UserValue := I;
    LabelControl.SetText(PWideString(Items[I])^);
    LabelControl.HelpText := LabelControl.GetText;
    LabelControl.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,200));
    LabelControl.LeftButtonDownCallback := ChoiceMouseDown;
    LabelControl.LeftButtonDoubleClickCallback := ChoiceDoubleClick;
    Inc(Y,Row.ClientSize.Y);
  end;
  with ScrollPanel do
  begin
    UpdateScrollbarPlacement;
    UpdateScrollRanges;
    VerticalScrollBar.SetSmallChange(GiScalePixels(15));
    VerticalScrollBar.SetLargeChange(ClientSize.Y);
    VerticalScrollBar.SetPageSize(ClientSize.Y);
  end;
end;
{ @end $509A34 }

{ @routine $509C64 TfListBox_AcceptClicked }
procedure TfListBox.AcceptClicked(Sender: TObjectGI);
begin
  if SelectedControl <> nil then
    if not AcceptButton.Disabled then
    begin
      SelectedIndex := SelectedControl.UserValue;
      RequestClose(1);
    end;
end;
{ @end $509C64 }

{ @routine $509CB8 TfListBox_CancelClicked }
procedure TfListBox.CancelClicked(Sender: TObjectGI);
begin
  RequestClose(2);
end;
{ @end $509CB8 }

{ @routine $509CD8 TfListBox_ProcessMouseWheel }
procedure TfListBox.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  with ScrollPanel.VerticalScrollBar do
    if Delta = WHEEL_DELTA then SetPosition(Position - SmallChange)
    else if Delta = -WHEEL_DELTA then SetPosition(Position + SmallChange);
end;
{ @end $509CD8 }

{ @routine $509D4C TfListBox_ChoiceMouseDown }
procedure TfListBox.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if SelectedControl <> nil then
  begin
    (SelectedControl as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,200));
    SelectedControl := nil;
  end;
  SelectedControl := Sender;
  (SelectedControl as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(150,150,0));
end;
{ @end $509D4C }

{ @routine $509DF0 TfListBox_ChoiceDoubleClick }
procedure TfListBox.ChoiceDoubleClick(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  AcceptClicked(nil);
end;
{ @end $509DF0 }

{ @routine $509E1C TfListBox_ProcessCallbackTimers }
procedure TfListBox.ProcessCallbackTimers;
begin
  inherited;
  if ParentLoop.ExitCode <> 0 then
    if ExitCode = 0 then RequestClose(255);
end;
{ @end $509E1C }

{ @routine $509E50 ShowListDialog }
function ShowListDialog(Parent: TMessageLoopGI; var SelectedIndex: Integer; Caption: WideString; Items: TList; OffsetX, OffsetY: Integer): Cardinal;
var
  Dialog: TfListBox;
  State: TCursorStateGI;
begin
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  CaptureScreenBackground(False,0);
  Dialog := TfListBox.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeDefaults;
  Dialog.Items := Items;
  Dialog.Caption := Caption;
  Dialog.OffsetX := OffsetX;
  Dialog.OffsetY := OffsetY;
  try
    Result := Dialog.Run;
    SelectedIndex := Dialog.SelectedIndex;
    Parent.InvalidateViewport;
  finally
    Dialog.Caption := '';
    Dialog.Items := nil;
    Parent.ChildLoop := nil;
    Dialog.Free;
  end;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.NativeHook48;
  if Result = 254 then BreakUiMessage;
end;
{ @end $509E50 }

end.
