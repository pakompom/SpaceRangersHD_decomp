unit fCount1;

interface

uses Classes, Types, GI_MessageLoop;

type
  TfCount1 = class(TMessageLoopGI) // @size $FC
  public
    ImagePath: WideString; // @offset $D0
    KindImagePath: WideString; // @offset $D4 Empty selects the alternate count layout.
    Caption: WideString; // @offset $D8
    Minimum: Integer; // @offset $DC
    Maximum: Integer; // @offset $E0 Slider and arrow range.
    Limit: Integer; // @offset $E4 Highest acceptable value; larger values remain selectable but are red and cannot be accepted.
    Value: Integer; // @offset $E8
    Items: TList; // @offset $EC Optional borrowed PWideString labels indexed by Value - Minimum.
    Dragging: Boolean; // @offset $F0
    RepeatTimer: PCallbackTimerGI; // @offset $F4
    RepeatCount: Cardinal; // @offset $F8
    constructor Create; override; // @addr $622310 @ida "TfCount1 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $622354 @ida "void __usercall $name(TfCount1 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure InitializeLayout; override; // @addr $622388
    procedure OnOpen; override; // @addr $6224A8
    procedure OnClose; override; // @addr $6228A4
    procedure RefreshValue; // @addr $6228D8
    procedure AddPressed(Sender: TObjectGI); // @addr $622D80
    procedure SubPressed(Sender: TObjectGI); // @addr $622E1C
    procedure AddReleased(Sender: TObjectGI); // @addr $622EB8
    procedure SubReleased(Sender: TObjectGI); // @addr $622EF0
    procedure RepeatChange(Timer: PCallbackTimerGI; Data: Integer); // @addr $622F28
    procedure MaxClicked(Sender: TObjectGI); // @addr $6230C4
    procedure AcceptClicked(Sender: TObjectGI); // @addr $623118
    procedure CancelClicked(Sender: TObjectGI); // @addr $623150
    procedure BarMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $623188 @ida "void __userpurge $name(TfCount1 *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MainMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6231C8 @ida "void __userpurge $name(TfCount1 *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure MainMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $6231F4 @ida "void __userpurge $name(TfCount1 *Self@<eax>, TObjectGI *Sender@<edx>, unsigned int KeyState@<ecx>, TPoint *Point@<^0>);"
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $623398 @ida "void __userpurge $name(TfCount1 *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>, int Delta@<^0>);"
    procedure ProcessCallbackTimers; override; // @addr $623410
    procedure MainKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $623444
  end;

// Native TfCount1 VMT $6222A4 confirms the inferred unit ownership.
function ShowNumberDialog(Parent: TMessageLoopGI; const ImagePath, KindImagePath, Caption: WideString; Minimum, Maximum, Limit: Integer; Items: TList; var Value: Integer): Cardinal; // @addr $623530 @note "Borrows optional PWideString choices. Maximum bounds the slider; Limit bounds acceptance and the Max button."

implementation

uses Math, SysUtils, Windows, GR_Main, Globals, GlobalsV,
  GI_GraphBuf, GI_Image, GI_Label, GI_GraphButton;


{ @routine $622310 TfCount1_Create }
constructor TfCount1.Create;
begin
  inherited;
end;
{ @end $622310 }

{ @routine $622354 TfCount1_Destroy }
destructor TfCount1.Destroy;
begin
  inherited;
end;
{ @end $622354 }

{ @routine $622388 TfCount1_InitializeLayout }
procedure TfCount1.InitializeLayout;
begin
  ViewportRect := Classes.Rect(0,0,GameScreenWidth,GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth,GameScreenHeight));
    with FindByNameRecursive('Ok').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2,LocalPosition.Y + ExtraScreenHeight div 2));
  end;
end;
{ @end $622388 }

{ @routine $6224A8 TfCount1_OnOpen }
procedure TfCount1.OnOpen;
begin
  Dragging := False;
  with GetByName('ItemImage') as TImageGI do
  begin
    SetImagePath(Self.ImagePath);
    SetImageKindX(ikxCenter);
    SetImageKindY(ikyCenter);
    SetActive(True);
  end;
  (GetByName('Caption') as TLabelGI).SetText(Caption);
  (GetByName('BGBuf') as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
  with GetByName('Add') as TGraphButtonGI do
  begin
    DownCallback := AddPressed;
    UpCallback := AddReleased;
  end;
  with GetByName('Sub') as TGraphButtonGI do
  begin
    DownCallback := SubPressed;
    UpCallback := SubReleased;
  end;
  (GetByName('Max') as TGraphButtonGI).UpCallback := MaxClicked;
  (GetByName('Ok') as TGraphButtonGI).UpCallback := AcceptClicked;
  (GetByName('Close') as TGraphButtonGI).UpCallback := CancelClicked;
  GetByName('PanelBar').LeftButtonDownCallback := BarMouseDown;
  with GetByName('MainPanel') do
  begin
    MouseMoveCallback := MainMouseMove;
    LeftButtonUpCallback := MainMouseUp;
    KeyDownCallback := MainKeyDown;
  end;
  if KindImagePath <> '' then
  begin
    with GetByName('Kind0') as TImageGI do
    begin
      SetImagePath(KindImagePath);
      SetActive(True);
    end;
    GetByName('Count').SetActive(True);
    GetByName('Kind1').SetActive(False);
    GetByName('Count2').SetActive(False);
  end
  else
  begin
    GetByName('Kind1').SetActive(True);
    GetByName('Count2').SetActive(True);
    GetByName('Count').SetActive(False);
    GetByName('Kind0').SetActive(False);
  end;
  RefreshValue;
end;
{ @end $6224A8 }

{ @routine $6228A4 TfCount1_OnClose }
procedure TfCount1.OnClose;
begin
  if RepeatTimer <> nil then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $6228A4 }

{ @routine $6228D8 TfCount1_RefreshValue }
procedure TfCount1.RefreshValue;
var
  Width, Position: Integer;
begin
  Width := GetByName('BarRange').ClientSize.X + 2;
  if Maximum - Minimum <= 0 then Position := Width - 1
  else Position := Round((Value - Minimum) / (Maximum - Minimum) * (Width - 1));
  with GetByName('Bar') do SetPosition(Classes.Point(Position - 1 - ClientSize.X div 2,0));
  with GetByName('BarArrow') do SetPosition(Classes.Point(Position + 3,0));
  (GetByName('Ok') as TGraphButtonGI).SetDisabled(Value > Limit);
  if Value <= Limit then
  begin
    (GetByName('Count') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
    (GetByName('Count2') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(0,0,0));
  end
  else
  begin
    (GetByName('Count') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255,0,0));
    (GetByName('Count2') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255,0,0));
  end;
  if Items <> nil then
  begin
    (GetByName('Count') as TLabelGI).SetText(PWideString(Items[Value - Minimum])^);
    (GetByName('Count2') as TLabelGI).SetText(PWideString(Items[Value - Minimum])^);
  end
  else
  begin
    (GetByName('Count') as TLabelGI).SetText(IntToStr(Value));
    (GetByName('Count2') as TLabelGI).SetText(IntToStr(Value));
  end;
  (GetByName('Add') as TGraphButtonGI).SetDisabled(Value = Maximum);
  (GetByName('Sub') as TGraphButtonGI).SetDisabled(Value = Minimum);
  (GetByName('Max') as TGraphButtonGI).SetDisabled(Value = Min(Limit,Maximum));
end;
{ @end $6228D8 }

{ @routine $622D80 TfCount1_AddPressed }
procedure TfCount1.AddPressed(Sender: TObjectGI);
begin
  if not Dragging then
  begin
    if Value < Maximum then Inc(Value);
    RefreshValue;
    if RepeatTimer <> nil then
    begin
      CancelCallbackTimer(RepeatTimer);
      RepeatTimer := nil;
    end;
    RepeatTimer := ScheduleCallbackTimer(300,50,RepeatChange,1);
    RepeatCount := 0;
  end;
end;
{ @end $622D80 }

{ @routine $622E1C TfCount1_SubPressed }
procedure TfCount1.SubPressed(Sender: TObjectGI);
begin
  if not Dragging then
  begin
    if Value > Minimum then Dec(Value);
    RefreshValue;
    if RepeatTimer <> nil then
    begin
      CancelCallbackTimer(RepeatTimer);
      RepeatTimer := nil;
    end;
    RepeatTimer := ScheduleCallbackTimer(300,50,RepeatChange);
    RepeatCount := 0;
  end;
end;
{ @end $622E1C }

{ @routine $622EB8 TfCount1_AddReleased }
procedure TfCount1.AddReleased(Sender: TObjectGI);
begin
  if RepeatTimer <> nil then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $622EB8 }

{ @routine $622EF0 TfCount1_SubReleased }
procedure TfCount1.SubReleased(Sender: TObjectGI);
begin
  if RepeatTimer <> nil then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $622EF0 }

{ @routine $622F28 TfCount1_RepeatChange }
procedure TfCount1.RepeatChange(Timer: PCallbackTimerGI; Data: Integer);
var
  Step: Cardinal;
begin
  Step := Round(Exp(RepeatCount * 0.1));
  if Cardinal(Maximum - Minimum) div 10 < Step then Step := (Maximum - Minimum) div 10
  else Inc(RepeatCount);
  Step := Max(1,Step);
  if Cardinal(Data) > 0 then Inc(Value,Min(Maximum - Value,Step))
  else Dec(Value,Min(Value - Minimum,Step));
  RefreshValue;
end;
{ @end $622F28 }

{ @routine $6230C4 TfCount1_MaxClicked }
procedure TfCount1.MaxClicked(Sender: TObjectGI);
begin
  Value := Min(Limit,Maximum);
  RefreshValue;
end;
{ @end $6230C4 }

{ @routine $623118 TfCount1_AcceptClicked }
procedure TfCount1.AcceptClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(1) else RequestClose(ExitCode);
end;
{ @end $623118 }

{ @routine $623150 TfCount1_CancelClicked }
procedure TfCount1.CancelClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
end;
{ @end $623150 }

{ @routine $623188 TfCount1_BarMouseDown }
procedure TfCount1.BarMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  Dragging := True;
  MainMouseMove(Sender,KeyState,Point);
end;
{ @end $623188 }

{ @routine $6231C8 TfCount1_MainMouseUp }
procedure TfCount1.MainMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  Dragging := False;
end;
{ @end $6231C8 }

{ @routine $6231F4 TfCount1_MainMouseMove }
procedure TfCount1.MainMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var
  X, Width: Integer;
begin
  if Dragging then
  begin
    X := GetByName('BarRange').ToLocalPoint(GetCursorPoint).X;
    Width := GetByName('BarRange').ClientSize.X + 2;
    Value := Round(Min(1.0,Max(0.0,(X - 1) / (Width - 1))) * (Maximum - Minimum) + Minimum);
    if Value < Minimum then Value := Minimum
    else if Value > Maximum then Value := Maximum;
    RefreshValue;
  end;
end;
{ @end $6231F4 }

{ @routine $623398 TfCount1_ProcessMouseWheel }
procedure TfCount1.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = -WHEEL_DELTA then
  begin
    if Value < Maximum then Inc(Value);
    RefreshValue;
  end
  else if Delta = WHEEL_DELTA then
  begin
    if Value > Minimum then Dec(Value);
    RefreshValue;
  end;
end;
{ @end $623398 }

{ @routine $623410 TfCount1_ProcessCallbackTimers }
procedure TfCount1.ProcessCallbackTimers;
begin
  inherited;
  if ParentLoop.ExitCode <> 0 then
    if ExitCode = 0 then RequestClose(255);
end;
{ @end $623410 }

{ @routine $623444 TfCount1_MainKeyDown }
procedure TfCount1.MainKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_LEFT then
  begin
    if Value > Minimum then Dec(Value);
    RefreshValue;
  end
  else if Key = VK_RIGHT then
  begin
    if Value < Maximum then Inc(Value);
    RefreshValue;
  end
  else if Key = VK_HOME then
  begin
    Value := Minimum;
    RefreshValue;
  end
  else if Key = VK_END then
  begin
    Value := Maximum;
    RefreshValue;
  end
  else if Key = VK_ESCAPE then CancelClicked(nil)
  else if (Key = VK_RETURN) and (Value <= Limit) then AcceptClicked(nil);
end;
{ @end $623444 }

{ @routine $623530 ShowNumberDialog }
function ShowNumberDialog(Parent: TMessageLoopGI; const ImagePath, KindImagePath, Caption: WideString; Minimum, Maximum, Limit: Integer; Items: TList; var Value: Integer): Cardinal;
var
  Dialog: TfCount1;
  State: TCursorStateGI;
begin
  Parent.RootUiObject.NativeHook50;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
  Parent.DrawQueuedUpdateRects;
  CaptureScreenBackground(False,0);
  Dialog := TfCount1.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeFromConfig(UiStyleConfig,'Number',True);
  Dialog.InitializeLayout;
  try
    Dialog.ImagePath := ImagePath;
    Dialog.KindImagePath := KindImagePath;
    Dialog.Caption := Caption;
    Dialog.Minimum := Minimum;
    Dialog.Maximum := Maximum;
    Dialog.Limit := Limit;
    Dialog.Value := Value;
    Dialog.Items := Items;
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
end;
{ @end $623530 }

end.
