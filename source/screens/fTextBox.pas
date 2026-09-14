unit fTextBox;

interface

uses Types, GI_MessageLoop, GI_Edit, GI_GraphButton;

type
  TfTextBox = class(TMessageLoopGI) // @size $EC
  public
    Caption: WideString; // @offset $D0
    Edit: TEditGI; // @offset $D4
    Value: WideString; // @offset $D8 Accepted text; cancellation preserves the initial value.
    AcceptButton: TGraphButtonGI; // @offset $DC
    MaximumLength: Integer; // @offset $E0
    OffsetX: Integer; // @offset $E4
    OffsetY: Integer; // @offset $E8
    constructor Create; override; // @addr $5041B8 @ida "TfTextBox *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $5041FC @ida "void __usercall $name(TfTextBox *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure OnOpen; override; // @addr $504230
    procedure OnClose; override; // @addr $504B84
    procedure AcceptClicked(Sender: TObjectGI); // @addr $504B90
    procedure CancelClicked(Sender: TObjectGI); // @addr $504BDC
    procedure FocusEdit; // @addr $504BFC
    procedure TextChanged(Sender: TObjectGI); // @addr $504C24
    function IsValidText(Candidate: WideString): Boolean; // @addr $504C60
    procedure EditKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $504D20
    procedure ProcessCallbackTimers; override; // @addr $504E10
  end;

// Native TfTextBox VMT $504154 confirms the inferred unit ownership.
function ShowTextInputDialog(Parent: TMessageLoopGI; Caption: WideString; var Value: WideString; MaximumLength, OffsetX, OffsetY: Integer): Cardinal; // @addr $504E44 @note "Runs the modal TfTextBox and copies its text back even on cancellation."

implementation

uses Classes, Windows, EC_Str, GI_Window, GI_Label, GI_Main,
  GR_Main, Globals, GlobalsV, aConst, aMyFunction;


{ @routine $5041B8 TfTextBox_Create }
constructor TfTextBox.Create;
begin
  inherited;
end;
{ @end $5041B8 }

{ @routine $5041FC TfTextBox_Destroy }
destructor TfTextBox.Destroy;
begin
  inherited;
end;
{ @end $5041FC }

{ @routine $504230 TfTextBox_OnOpen }
procedure TfTextBox.OnOpen;
var
  Window: TWindowGI;
  CancelButton: TGraphButtonGI;
  CaptionLabel: TLabelGI;
  Size: TPoint;
  Insets: TRect;
begin
  Window := TWindowGI.Create(ContentPanel);
  Window.SetDepth(1);
  Window.SetConfigPath('Style.Window.' + GiResourceSuffix + 'MessageBox');
  if GiResourceVariant = 1 then Window.SetSize(Classes.Point(280,80))
  else Window.SetSize(Classes.Point(300,100));
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
  if GiResourceVariant = 1 then
  begin
    CaptionLabel.SetPosition(Classes.Point(25,40));
    CaptionLabel.SetSize(Classes.Point(500,16));
  end
  else
  begin
    CaptionLabel.SetPosition(Classes.Point(25,50));
    CaptionLabel.SetSize(Classes.Point(500,21));
  end;
  CaptionLabel.SetTextAlignX(taxLeft);
  CaptionLabel.SetTextAlignY(tayCenter);
  CaptionLabel.SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  CaptionLabel.SetFontName(NormalBoldFontName);
  CaptionLabel.SetText(ReplaceAllWideString(ReplaceAllWideString(Caption,'<color=255,240,100>','<color=0,50,200>'),'<color=0,255,0>','<color=255,255,0>'));
  Edit := TEditGI.Create(ContentPanel);
  with Edit do
  begin
    if GiResourceVariant = 1 then
    begin
      SetPosition(Classes.Point(25,60));
      SetSize(Classes.Point(230,19));
    end
    else
    begin
      SetPosition(Classes.Point(25,75));
      SetSize(Classes.Point(250,21));
    end;
    ClearFocusOnEnter := False;
    SetBorderEnabled(True);
    SetBorderLightColor(CurrentPixelFormat.PackRgbBytes(0,0,255));
    SetBorderDarkColor(CurrentPixelFormat.PackRgbBytes(0,0,255));
    SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    SetFontName(NormalFontName);
    MaxLength := 30;
    SetText(Value);
    KeyDownCallback := EditKeyDown;
    ChangedCallback := TextChanged;
    MaxLength := MaximumLength;
    AutoScrollText := True;
  end;
  ViewportRect.Left := (GameScreenWidth shr 1) + OffsetX - Size.X div 2;
  ViewportRect.Top := (GameScreenHeight shr 1) + OffsetY - Size.Y div 2;
  ViewportRect.Right := (GameScreenWidth shr 1) + OffsetX + Size.X div 2;
  ViewportRect.Bottom := (GameScreenHeight shr 1) + OffsetY + Size.Y div 2;
  ContentPanel.SetPosition(ViewportRect.TopLeft);
  ContentPanel.SetSize(Size);
  ContentPanel.UpdateAbsolutePosition;
  ContentPanel.UpdateSubtreeHitBounds;
  FocusEdit;
end;
{ @end $504230 }

{ @routine $504B84 TfTextBox_OnClose }
procedure TfTextBox.OnClose;
begin

end;
{ @end $504B84 }

{ @routine $504B90 TfTextBox_AcceptClicked }
procedure TfTextBox.AcceptClicked(Sender: TObjectGI);
begin
  if not AcceptButton.Disabled then
  begin
    Value := Edit.Text;
    RequestClose(1);
  end;
end;
{ @end $504B90 }

{ @routine $504BDC TfTextBox_CancelClicked }
procedure TfTextBox.CancelClicked(Sender: TObjectGI);
begin
  RequestClose(2);
end;
{ @end $504BDC }

{ @routine $504BFC TfTextBox_FocusEdit }
procedure TfTextBox.FocusEdit;
begin
  Edit.ProcessLeftButtonDown(0,Edit.LocalPosition);
end;
{ @end $504BFC }

{ @routine $504C24 TfTextBox_TextChanged }
procedure TfTextBox.TextChanged(Sender: TObjectGI);
begin
  AcceptButton.SetDisabled(not IsValidText(Edit.Text));
end;
{ @end $504C24 }

{ @routine $504C60 TfTextBox_IsValidText }
function TfTextBox.IsValidText(Candidate: WideString): Boolean;
var
  I: Integer;
begin
  Result := False;
  Candidate := TrimWideString(Candidate);
  if Length(Candidate) < 1 then Exit;
  with Edit do
    for I := 0 to Length(Candidate) - 1 do
      if not HasGlyph(Candidate[I+1]) then Exit;
  Result := True;
end;
{ @end $504C60 }

{ @routine $504D20 TfTextBox_EditKeyDown }
procedure TfTextBox.EditKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) then
  begin
    if Key = Ord('C') then SetClipboardWideText(Edit.Text)
    else if Key = Ord('V') then begin
        Edit.SetText(GetClipboardWideText);
        Edit.SetCaretPosition(Length(Edit.Text));
    end
    else if Key = VK_BACK then Edit.SetText('');
  end
  else if Key = VK_ESCAPE then CancelClicked(nil)
  else if Key = VK_RETURN then AcceptClicked(nil);
end;
{ @end $504D20 }

{ @routine $504E10 TfTextBox_ProcessCallbackTimers }
procedure TfTextBox.ProcessCallbackTimers;
begin
  inherited;
  if ParentLoop.ExitCode <> 0 then
    if ExitCode = 0 then RequestClose(255);
end;
{ @end $504E10 }

{ @routine $504E44 ShowTextInputDialog }
function ShowTextInputDialog(Parent: TMessageLoopGI; Caption: WideString; var Value: WideString; MaximumLength, OffsetX, OffsetY: Integer): Cardinal;
var
  Dialog: TfTextBox;
  State: TCursorStateGI;
begin
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  CaptureScreenBackground(False,0);
  Dialog := TfTextBox.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeDefaults;
  try
    Dialog.MaximumLength := MaximumLength;
    Dialog.OffsetX := OffsetX;
    Dialog.OffsetY := OffsetY;
    Dialog.Caption := Caption;
    Dialog.Value := Value;
    Result := Dialog.Run;
    Value := Dialog.Value;
    Parent.InvalidateViewport;
  finally
    Parent.ChildLoop := nil;
    Dialog.Free;
  end;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.NativeHook48;
  if Result = 254 then BreakUiMessage;
end;
{ @end $504E44 }

end.
