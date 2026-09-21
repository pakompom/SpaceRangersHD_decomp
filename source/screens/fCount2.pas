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
    RepeatTimer: PCallbackTimerGI; // @offset $FC
    FontName: WideString; // @offset $100


    constructor Create; // @addr $520EFC
    destructor Destroy; override; // @addr $520F40
    procedure InitializeLayout; override; // @addr $520F74
    procedure OnOpen; override; // @addr $521094
    procedure OnClose; override; // @addr $521664
    procedure RefreshValue; // @addr $521698
    procedure IncreaseMouseDown(Sender: TObjectGI); // @addr $521BA8
    procedure DecreaseMouseDown(Sender: TObjectGI); // @addr $521C50
    procedure IncreaseMouseUp(Sender: TObjectGI); // @addr $521CF8
    procedure DecreaseMouseUp(Sender: TObjectGI); // @addr $521D30
    procedure RepeatChange(Timer: PCallbackTimerGI; UserData: Integer); // @addr $521D68
    procedure MaximumClicked(Sender: TObjectGI); // @addr $521DE8
    procedure AcceptClicked(Sender: TObjectGI); // @addr $521E5C
    procedure CancelClicked(Sender: TObjectGI); // @addr $521E94
    procedure SliderMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $521ECC
    procedure SliderMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $521F0C
    procedure SliderMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $521F38
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $5220C4
    procedure ProcessCallbackTimers; override; // @addr $522160
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $522194
  end;

// Native TfCount2 VMT $520E88 confirms the inferred unit ownership.
function ShowCountDialogWithFont(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer; PreviewImagePath, FontName: WideString): Cardinal; // @addr $5222A4

function ShowCountDialog(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer): Cardinal; // @addr $5224A0

implementation

uses Classes, SysUtils, Math, Windows, GlobalsV, GR_Main, GR_GraphBuf,
  GI_Main, GI_Image, GI_GraphBuf, GI_Label, GI_GraphButton;


{ @routine $520EFC TfCount2_Create }
constructor TfCount2.Create;
begin
  inherited Create;
end;
{ @end $520EFC }

{ @routine $520F40 TfCount2_Destroy }
destructor TfCount2.Destroy;
begin
  inherited Destroy;
end;
{ @end $520F40 }

{ @routine $520F74 TfCount2_InitializeLayout }
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
{ @end $520F74 }

{ @routine $521094 TfCount2_OnOpen }
procedure TfCount2.OnOpen;
begin
  Dragging := False;
  if ImagePath <> '' then
    with GetByName('ItemImage') as TImageGI do
    begin
      SetImagePath(Self.ImagePath);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end
  else with GetByName('ItemImage') as TImageGI do SetActive(False);
  if PreviewImagePath <> '' then
    with GetByName('ItemBuf') as TGraphBufGI do
    begin
      SourceHasPerPixelAlpha := True;
      LoadGiByPathIntoGraphBuf(PreviewImagePath, GraphBuf);
      if Cardinal(GraphBuf.Width) >= Cardinal(GraphBuf.Height) then
        GraphBuf.RescaleRgba(ClientSize.X, Round(ClientSize.X / Cardinal(GraphBuf.Width) * Cardinal(GraphBuf.Height)), 5)
      else GraphBuf.RescaleRgba(Round(ClientSize.Y / Cardinal(GraphBuf.Height) * Cardinal(GraphBuf.Width)), ClientSize.Y, 5);
      SetImageKindX(ikxCenter);
      SetImageKindY(ikyCenter);
      SetActive(True);
    end
  else with GetByName('ItemBuf') as TGraphBufGI do SetActive(False);
  with GetByName('Caption') as TLabelGI do
  begin
    SetText(Description);
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
{ @end $521094 }

{ @routine $521664 TfCount2_OnClose }
procedure TfCount2.OnClose;
begin
  if RepeatTimer <> nil then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $521664 }

{ @routine $521698 TfCount2_RefreshValue }
procedure TfCount2.RefreshValue;
var Width, Position: Integer;
begin
  Width := GetByName('BarRange').ClientSize.X + 2;
  if Maximum - Minimum <= 0 then Position := Width - 1
  else Position := Round(Value / Maximum * (Width - 1));
  with GetByName('Bar') do SetPosition(Classes.Point(Position - 1 - ClientSize.X div 2, 0));
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
  (GetByName('Count') as TLabelGI).SetText(IntToStr(Value));
  (GetByName('Count2') as TLabelGI).SetText(IntToStr(Value));
  (GetByName('Sum') as TLabelGI).SetText(IntToStr(Round(Value * UnitValue)));
  (GetByName('Add') as TGraphButtonGI).SetDisabled(Value = Maximum);
  (GetByName('Sub') as TGraphButtonGI).SetDisabled(Value = Minimum);
  (GetByName('Max') as TGraphButtonGI).SetDisabled(Value = Min(Available, Min(Limit, Maximum)));
end;
{ @end $521698 }

{ @routine $521BA8 TfCount2_IncreaseMouseDown }
procedure TfCount2.IncreaseMouseDown(Sender: TObjectGI);
begin
  if not Dragging then
  begin
    Inc(Value);
    if Value > Maximum then Value := Maximum;
    RefreshValue;
    if RepeatTimer <> nil then
    begin
      CancelCallbackTimer(RepeatTimer);
      RepeatTimer := nil;
    end;
    RepeatTimer := ScheduleCallbackTimer(300, 50, RepeatChange, 2);
  end;
end;
{ @end $521BA8 }

{ @routine $521C50 TfCount2_DecreaseMouseDown }
procedure TfCount2.DecreaseMouseDown(Sender: TObjectGI);
begin
  if not Dragging then
  begin
    Dec(Value);
    if Value < Minimum then Value := Minimum;
    RefreshValue;
    if RepeatTimer <> nil then
    begin
      CancelCallbackTimer(RepeatTimer);
      RepeatTimer := nil;
    end;
    RepeatTimer := ScheduleCallbackTimer(300, 50, RepeatChange);
  end;
end;
{ @end $521C50 }

{ @routine $521CF8 TfCount2_IncreaseMouseUp }
procedure TfCount2.IncreaseMouseUp(Sender: TObjectGI);
begin
  if RepeatTimer <> nil then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $521CF8 }

{ @routine $521D30 TfCount2_DecreaseMouseUp }
procedure TfCount2.DecreaseMouseUp(Sender: TObjectGI);
begin
  if RepeatTimer <> nil then
  begin
    CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $521D30 }

{ @routine $521D68 TfCount2_RepeatChange }
procedure TfCount2.RepeatChange(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Value := Value + UserData - 1;
  if Value < Minimum then Value := Minimum
  else if Value > Maximum then Value := Maximum;
  RefreshValue;
end;
{ @end $521D68 }

{ @routine $521DE8 TfCount2_MaximumClicked }
procedure TfCount2.MaximumClicked(Sender: TObjectGI);
begin
  Value := Min(Available, Min(Limit, Maximum));
  RefreshValue;
end;
{ @end $521DE8 }

{ @routine $521E5C TfCount2_AcceptClicked }
procedure TfCount2.AcceptClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(1) else RequestClose(ExitCode);
end;
{ @end $521E5C }

{ @routine $521E94 TfCount2_CancelClicked }
procedure TfCount2.CancelClicked(Sender: TObjectGI);
begin
  if ExitCode = 0 then RequestClose(2) else RequestClose(ExitCode);
end;
{ @end $521E94 }

{ @routine $521ECC TfCount2_SliderMouseDown }
procedure TfCount2.SliderMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  Dragging := True;
  SliderMouseMove(Sender, KeyState, Point);
end;
{ @end $521ECC }

{ @routine $521F0C TfCount2_SliderMouseUp }
procedure TfCount2.SliderMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  Dragging := False;
end;
{ @end $521F0C }

{ @routine $521F38 TfCount2_SliderMouseMove }
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
{ @end $521F38 }

{ @routine $5220C4 TfCount2_ProcessMouseWheel }
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
{ @end $5220C4 }

{ @routine $522160 TfCount2_ProcessCallbackTimers }
procedure TfCount2.ProcessCallbackTimers;
begin
  inherited ProcessCallbackTimers;
  if (ParentLoop.ExitCode <> 0) and (ExitCode = 0) then RequestClose(255);
end;
{ @end $522160 }

{ @routine $522194 TfCount2_MainPanelKeyDown }
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
{ @end $522194 }

{ @routine $5222A4 ShowCountDialogWithFont }
function ShowCountDialogWithFont(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer; PreviewImagePath, FontName: WideString): Cardinal;
var
  Dialog: TfCount2;
  State: TCursorStateGI;
begin
  Parent.RootUiObject.OnModalSuspend;
  Parent.CaptureCursorState(@State);
  Parent.SetCursorActive(False);
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
{ @end $5222A4 }

{ @routine $5224A0 ShowCountDialog }
function ShowCountDialog(Parent: TMessageLoopGI; const ImagePath, Description: WideString; Minimum, Maximum, Limit: Integer; UnitValue: Single; Available, TotalLimit: Integer; var Value: Integer): Cardinal;
begin
  Result := ShowCountDialogWithFont(Parent, ImagePath, Description, Minimum, Maximum, Limit, UnitValue, Available, TotalLimit, Value, '', NormalFontName);
end;
{ @end $5224A0 }

end.
