unit fCount2;

interface

uses GI_MessageLoop, Types;

type
  TfCount2 = class(TMessageLoopGI) // @size $104
  public
    ImagePath: WideString; // @offset $D0
    PreviewImagePath: WideString; // @offset $D4
    Description: WideString; // @offset $D8
    Minimum: Integer; // @offset $DC
    Maximum: Integer; // @offset $E0
    Limit: Integer; // @offset $E4
    Value: Integer; // @offset $E8
    UnitValue: Single; // @offset $EC
    Available: Integer; // @offset $F0
    TotalLimit: Integer; // @offset $F4
    Dragging: Boolean; // @offset $F8
    RepeatTimer: TCallbackTimerIdGI; // @offset $FC
    FontName: WideString; // @offset $100


    constructor Create; // @addr $500264
    destructor Destroy; override; // @addr $50029C
    procedure InitializeLayout; override; // @addr $5002C4
    procedure OnOpen; override; // @addr $5003D4
    procedure OnClose; override; // @addr $5008D8
    procedure RefreshValue; // @addr $5008F8
    procedure IncreaseMouseDown(Sender: TObjectGI); // @addr $500D6C
    procedure DecreaseMouseDown(Sender: TObjectGI); // @addr $500DD8
    procedure IncreaseMouseUp(Sender: TObjectGI); // @addr $500E44
    procedure DecreaseMouseUp(Sender: TObjectGI); // @addr $500E64
    procedure RepeatChange(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $500E84
    procedure MaximumClicked(Sender: TObjectGI); // @addr $500EBC
    procedure AcceptClicked(Sender: TObjectGI); // @addr $500EE8
    procedure CancelClicked(Sender: TObjectGI); // @addr $500F00
    procedure SliderMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $500F18
    procedure SliderMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $500F44
    procedure SliderMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $500F64
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $5010A4
    procedure ProcessCallbackTimers; override; // @addr $5010F8
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $501120
  end;

function ShowCountDialogWithFont(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer; PreviewImagePath, FontName: WideString): Cardinal; // @addr $5011C4

function ShowCountDialog(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer): Cardinal; // @addr $5013C0

implementation

uses Classes, SysUtils, Math, Windows, GlobalsV, GR_Main, GR_GraphBuf,
  GI_Main, GI_Image, GI_GraphBuf, GI_Label, GI_GraphButton;


{ @routine $500264 TfCount2_Create }
constructor TfCount2.Create;
begin
  inherited Create;
end;
{ @end $500264 }

{ @routine $50029C TfCount2_Destroy }
destructor TfCount2.Destroy;
begin
  inherited Destroy;
end;
{ @end $50029C }

{ @routine $5002C4 TfCount2_InitializeLayout }
procedure TfCount2.InitializeLayout;
begin
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  with GetByName('MainPanel') do
  begin
    SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    FindByNameRecursive('BGBuf').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
    with FindByNameRecursive('Ok').Parent do
      SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2, LocalPosition.Y + ExtraScreenHeight div 2));
  end;
end;
{ @end $5002C4 }

{ @routine $5003D4 TfCount2_OnOpen }
procedure TfCount2.OnOpen;
begin
  Dragging := False;
  if ImagePath <> '' then
    with GetByName('ItemImage') as TImageGI do
    begin
      ImageSourcePath := Self.ImagePath;
      KindX := ikxCenter;
      KindY := ikyCenter;
      SetActive(True);
    end
  else with GetByName('ItemImage') as TImageGI do SetActive(False);
  if PreviewImagePath <> '' then
    with GetByName('ItemBuf') as TGraphBufGI do
    begin
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf(PreviewImagePath, GraphBuf);
      if GraphBuf.Width >= GraphBuf.Height then
        GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / GraphBuf.Width * GraphBuf.Height), 5)
      else GraphBuf.RescaleRgba(Round(ClientSize.Y / GraphBuf.Height * GraphBuf.Width), ClientSize.Y, 5);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end
  else with GetByName('ItemBuf') as TGraphBufGI do SetActive(False);
  with GetByName('Caption') as TLabelGI do
  begin
    Text := Description;
    SetFontName(Self.FontName);
  end;
  with GetByName('BGBuf') as TGraphBufGI do BindExternalGraphBuf(AuxRenderBuffer);
  with GetByName('Add') as TGraphButtonGI do
  begin
    DownCallback := IncreaseMouseDown;
    UpCallback := IncreaseMouseUp;
  end;
  with GetByName('Sub') as TGraphButtonGI do
  begin
    DownCallback := DecreaseMouseDown;
    UpCallback := DecreaseMouseUp;
  end;
  (GetByName('Max') as TGraphButtonGI).UpCallback := MaximumClicked;
  (GetByName('Ok') as TGraphButtonGI).UpCallback := AcceptClicked;
  (GetByName('Close') as TGraphButtonGI).UpCallback := CancelClicked;
  GetByName('PanelBar').LeftButtonDownCallback := SliderMouseDown;
  with GetByName('MainPanel') do
  begin
    MouseMoveCallback := SliderMouseMove;
    LeftButtonUpCallback := SliderMouseUp;
    KeyDownCallback := MainPanelKeyDown;
  end;
  GetByName('Kind0').SetActive(UnitValue > 0);
  GetByName('Count').SetActive(UnitValue > 0);
  GetByName('Sum').SetActive(UnitValue > 0);
  GetByName('Kind1').SetActive(UnitValue <= 0);
  GetByName('Count2').SetActive(UnitValue <= 0);
  RefreshValue;
end;
{ @end $5003D4 }

{ @routine $5008D8 TfCount2_OnClose }
procedure TfCount2.OnClose;
begin
  if RepeatTimer <> 0 then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
end;
{ @end $5008D8 }

{ @routine $5008F8 TfCount2_RefreshValue }
procedure TfCount2.RefreshValue;
var Width, Position: Integer;
begin
  Width := GetByName('BarRange').ClientSize.X + 2;
  if Maximum - Minimum <= 0 then Position := Width - 1
  else Position := Round(Value / Maximum * (Width - 1));
  with GetByName('Bar') do SetPosition(Classes.Point(-1 + Position - ClientSize.X div 2, 0));
  with GetByName('BarArrow') do SetPosition(Classes.Point(Position + 3, 0));
  (GetByName('Ok') as TGraphButtonGI).SetDisabled(Value > Limit);
  if Value <= Available then
  begin
    (GetByName('Count') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
    (GetByName('Count2') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  end
  else
  begin
    (GetByName('Count') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 0, 0));
    (GetByName('Count2') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 0, 0));
  end;
  if Value * UnitValue <= TotalLimit then
    (GetByName('Sum') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0))
  else (GetByName('Sum') as TLabelGI).SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 0, 0));
  (GetByName('Count') as TLabelGI).Text := IntToStr(Value);
  (GetByName('Count2') as TLabelGI).Text := IntToStr(Value);
  (GetByName('Sum') as TLabelGI).Text := IntToStr(Round(Value * UnitValue));
  (GetByName('Add') as TGraphButtonGI).SetDisabled(Value = Maximum);
  (GetByName('Sub') as TGraphButtonGI).SetDisabled(Value = Minimum);
  (GetByName('Max') as TGraphButtonGI).SetDisabled(Value = Min(Available, Min(Limit, Maximum)));
end;
{ @end $5008F8 }

{ @routine $500D6C TfCount2_IncreaseMouseDown }
procedure TfCount2.IncreaseMouseDown(Sender: TObjectGI);
begin
  if not Dragging then
  begin
    Inc(Value);
    if Value > Maximum then Value := Maximum;
    RefreshValue;
    if RepeatTimer <> 0 then
    begin
      CancelCallbackTimer(RepeatTimer);
      RepeatTimer := 0;
    end;
    RepeatTimer := ScheduleCallbackTimer(300, 50, RepeatChange, 2);
  end;
end;
{ @end $500D6C }

{ @routine $500DD8 TfCount2_DecreaseMouseDown }
procedure TfCount2.DecreaseMouseDown(Sender: TObjectGI);
begin
  if not Dragging then
  begin
    Dec(Value);
    if Value < Minimum then Value := Minimum;
    RefreshValue;
    if RepeatTimer <> 0 then
    begin
      CancelCallbackTimer(RepeatTimer);
      RepeatTimer := 0;
    end;
    RepeatTimer := ScheduleCallbackTimer(300, 50, RepeatChange);
  end;
end;
{ @end $500DD8 }

{ @routine $500E44 TfCount2_IncreaseMouseUp }
procedure TfCount2.IncreaseMouseUp(Sender: TObjectGI);
begin
  if RepeatTimer <> 0 then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
end;
{ @end $500E44 }

{ @routine $500E64 TfCount2_DecreaseMouseUp }
procedure TfCount2.DecreaseMouseUp(Sender: TObjectGI);
begin
  if RepeatTimer <> 0 then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
end;
{ @end $500E64 }

{ @routine $500E84 TfCount2_RepeatChange }
procedure TfCount2.RepeatChange(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  Value := Value + UserData - 1;
  if Value < Minimum then Value := Minimum
  else if Value > Maximum then Value := Maximum;
  RefreshValue;
end;
{ @end $500E84 }

{ @routine $500EBC TfCount2_MaximumClicked }
procedure TfCount2.MaximumClicked(Sender: TObjectGI);
begin
  Value := Min(Available, Min(Limit, Maximum));
  RefreshValue;
end;
{ @end $500EBC }

{ @routine $500EE8 TfCount2_AcceptClicked }
procedure TfCount2.AcceptClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(1) else RequestClose(ExitCode);
end;
{ @end $500EE8 }

{ @routine $500F00 TfCount2_CancelClicked }
procedure TfCount2.CancelClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
end;
{ @end $500F00 }

{ @routine $500F18 TfCount2_SliderMouseDown }
procedure TfCount2.SliderMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  Dragging := True;
  SliderMouseMove(Sender, KeyState, Point);
end;
{ @end $500F18 }

{ @routine $500F44 TfCount2_SliderMouseUp }
procedure TfCount2.SliderMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  Dragging := False;
end;
{ @end $500F44 }

{ @routine $500F64 TfCount2_SliderMouseMove }
procedure TfCount2.SliderMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var X, Width: Integer;
begin
  if Dragging then
  begin
    X := GetByName('BarRange').ToLocalPoint(GetCursorPoint).X;
    Width := GetByName('BarRange').ClientSize.X + 2;
    Value := Round(Maximum * Min(1.0, Max(0.0, (X - 1) / (Width - 1))));
    if Value < Minimum then Value := Minimum
    else if Value > Maximum then Value := Maximum;
    RefreshValue;
  end;
end;
{ @end $500F64 }

{ @routine $5010A4 TfCount2_ProcessMouseWheel }
procedure TfCount2.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
begin
  if Delta = -WHEEL_DELTA then
  begin
    Inc(Value);
    if Value > Maximum then Value := Maximum;
    RefreshValue;
  end
  else if Delta = WHEEL_DELTA then
  begin
    Dec(Value);
    if Value < Minimum then Value := Minimum;
    RefreshValue;
  end;
end;
{ @end $5010A4 }

{ @routine $5010F8 TfCount2_ProcessCallbackTimers }
procedure TfCount2.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $5010F8 }

{ @routine $501120 TfCount2_MainPanelKeyDown }
procedure TfCount2.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if Key = VK_LEFT then
  begin
    Dec(Value);
    if Value < Minimum then Value := Minimum;
    RefreshValue;
  end
  else if Key = VK_RIGHT then
  begin
    Inc(Value);
    if Value > Maximum then Value := Maximum;
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
{ @end $501120 }

{ @routine $5011C4 ShowCountDialogWithFont }
function ShowCountDialogWithFont(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer; PreviewImagePath, FontName: WideString): Cardinal;
var
  Dialog: TfCount2;
  State: TCursorStateGI;
begin
  Parent.RootUiObject.OnModalSuspend;
  Parent.CaptureCursorState(@State);
  Parent.ShowCursor := False;
  Parent.DrawQueuedUpdateRects;
  CaptureScreenBackground(False, 0);
  Dialog := TfCount2.Create;
  Dialog.ParentLoop := Parent;
  Parent.ChildLoop := Dialog;
  Dialog.InitializeFromConfig(UiStyleConfig, 'Count', True);
  Dialog.InitializeLayout;
  try
    Dialog.ImagePath := ImagePath;
    Dialog.PreviewImagePath := PreviewImagePath;
    Dialog.Description := Description;
    Dialog.Minimum := Minimum;
    Dialog.Maximum := Maximum;
    Dialog.Limit := Limit;
    Dialog.Value := Value;
    Dialog.UnitValue := UnitValue;
    Dialog.TotalLimit := TotalLimit;
    Dialog.Available := Available;
    Dialog.FontName := FontName;
    Result := Dialog.Run;
    Value := Dialog.Value;
    Parent.InvalidateViewport;
  finally
    Parent.ChildLoop := nil;
    Dialog.Free;
  end;
  Parent.RestoreCursorState(@State);
  Parent.UpdateCursorPosition;
  Parent.RootUiObject.OnModalResume;
end;
{ @end $5011C4 }

{ @routine $5013C0 ShowCountDialog }
function ShowCountDialog(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer): Cardinal;
begin
  Result := ShowCountDialogWithFont(Parent, ImagePath, Description, Minimum, Maximum, Limit, UnitValue, Available, TotalLimit, Value, '', NormalFontName);
end;
{ @end $5013C0 }

end.
