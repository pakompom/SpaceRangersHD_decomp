unit GI_CountBar;

interface

uses EC_BlockPar, GI_GraphButton, GI_Image, GI_MessageLoop, Types;

const
  cbHorizontal = 1;

type
  TCountBarGI = class(TObjectGI) // @size 0x15C
  public
    Minimum: Integer; // @offset 0x120
    Maximum: Integer; // @offset 0x124
    Position: Integer; // @offset 0x128
    Orientation: Integer; // @offset 0x12C
    Step: Integer; // @offset 0x130
    DecreaseButton: TGraphButtonGI; // @offset 0x134
    IncreaseButton: TGraphButtonGI; // @offset 0x138
    AfterThumbImage: TImageGI; // @offset 0x13C
    BeforeThumbImage: TImageGI; // @offset 0x140
    ThumbButton: TGraphButtonGI; // @offset 0x144
    MarkerImage: TImageGI; // @offset 0x148
    PositionChangedCallback: TObjectNotifyEventGI; // @offset $150
    RepeatTimer: TCallbackTimerIdGI; // @offset 0x158

    constructor Create(Owner: TObjectGI); // @addr 0x004AF204
    destructor Destroy; override; // @addr 0x004AF34C
    procedure SetRange(MinValue, MaxValue: Integer); // @addr 0x004AF418
    procedure SetPositionInternal(Value: Integer); // @addr 0x004AF484 @note "Clamps without invoking PositionChangedCallback."
    procedure SetPosition(Value: Integer); reintroduce; // @addr 0x004AF4D4 @note "Notifies only while Active and when the requested value differs from the previous position."
    procedure UpdateLayout; // @addr 0x004AF53C
    procedure AutoRepeat(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x004AF7C0
    procedure DecreasePressed(Sender: TObjectGI); // @addr 0x004AF82C
    procedure IncreasePressed(Sender: TObjectGI); // @addr 0x004AF880
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr 0x004AF8D4
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr 0x004AFA14
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr 0x004AFB88
    procedure OnMouseEnter; override; // @addr 0x004AFA04
    procedure OnMouseLeave; override; // @addr 0x004AFA0C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004AFBC4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004AFBF0
    procedure LoadCountBarProperties(Block: TBlockParEC); // @addr 0x004AFC0C
  end;

implementation

uses Classes, EC_Struct, GI_Main;

{ @routine $4AF204 TCountBarGI_Create }
constructor TCountBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Orientation := cbHorizontal;
  Minimum := 0;
  Maximum := 100;
  Position := 0;
  Step := 1;
  DecreaseButton := TGraphButtonGI.Create(Self);
  IncreaseButton := TGraphButtonGI.Create(Self);
  AfterThumbImage := TImageGI.Create(Self);
  BeforeThumbImage := TImageGI.Create(Self);
  ThumbButton := TGraphButtonGI.Create(Self);
  MarkerImage := TImageGI.Create(Self);
  DecreaseButton.DownCallback := DecreasePressed;
  IncreaseButton.DownCallback := IncreasePressed;
  AfterThumbImage.KindX := image_x_tile_left;
  AfterThumbImage.KindY := image_y_tile_top;
  BeforeThumbImage.KindX := image_x_tile_left;
  BeforeThumbImage.KindY := image_y_tile_top;
  ThumbButton.SetKind(button_toggle);
end;
{ @end $4AF204 }

{ @routine $4AF34C TCountBarGI_Destroy }
destructor TCountBarGI.Destroy;
begin
  if DecreaseButton <> nil then
  begin
    DecreaseButton.Free;
    DecreaseButton := nil;
  end;
  if IncreaseButton <> nil then
  begin
    IncreaseButton.Free;
    IncreaseButton := nil;
  end;
  if AfterThumbImage <> nil then
  begin
    AfterThumbImage.Free;
    AfterThumbImage := nil;
  end;
  if BeforeThumbImage <> nil then
  begin
    BeforeThumbImage.Free;
    BeforeThumbImage := nil;
  end;
  if ThumbButton <> nil then
  begin
    ThumbButton.Free;
    ThumbButton := nil;
  end;
  if MarkerImage <> nil then
  begin
    MarkerImage.Free;
    MarkerImage := nil;
  end;
  if RepeatTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
  inherited Destroy;
end;
{ @end $4AF34C }

{ @routine $4AF418 TCountBarGI_SetRange }
procedure TCountBarGI.SetRange(MinValue, MaxValue: Integer);
begin
  if (Maximum <> MaxValue) or (Minimum <> MinValue) then
  begin
    if MinValue > MaxValue then MinValue := MaxValue;
    Minimum := MinValue;
    Maximum := MaxValue;
    if Position < Minimum then SetPositionInternal(Minimum);
    if Position > Maximum then SetPositionInternal(Maximum);
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $4AF418 }

{ @routine $4AF484 TCountBarGI_SetPositionInternal }
procedure TCountBarGI.SetPositionInternal(Value: Integer);
begin
  if Position = Value then Exit;
  Position := Value;
  if Position < Minimum then Position := Minimum;
  if Position > Maximum then Position := Maximum;
  if Active <> True then Exit;
  UpdateLayout;
  Invalidate;
end;
{ @end $4AF484 }

{ @routine $4AF4D4 TCountBarGI_SetPosition }
procedure TCountBarGI.SetPosition(Value: Integer);
begin
  if Position = Value then Exit;
  Position := Value;
  if Position < Minimum then Position := Minimum;
  if Position > Maximum then Position := Maximum;
  if Active <> True then Exit;
  UpdateLayout;
  Invalidate;
  if Assigned(PositionChangedCallback) then PositionChangedCallback(Self);
end;
{ @end $4AF4D4 }

{ @routine $4AF53C TCountBarGI_UpdateLayout }
procedure TCountBarGI.UpdateLayout;
var
  TrackWidth, ThumbLeft, ThumbRight: Integer;
  ThumbSize, IncreaseSize, DecreaseSize: TPoint;
begin
  if Orientation <> cbHorizontal then Exit;
  ThumbSize := ThumbButton.GetMaxStateImageSize;
  DecreaseSize := DecreaseButton.GetMaxStateImageSize;
  IncreaseSize := IncreaseButton.GetMaxStateImageSize;
  TrackWidth := ClientSize.X - ThumbSize.X - IncreaseSize.X - DecreaseSize.X;
  if Maximum - Minimum = 0 then ThumbLeft := IncreaseSize.X
  else ThumbLeft := Integer(Round(TrackWidth * (Position - Minimum) / (Maximum - Minimum))) - ThumbSize.X div 2 + IncreaseSize.X + ThumbSize.X div 2;
  ThumbRight := ThumbLeft + ThumbSize.X;
  DecreaseButton.Pos := Classes.Point(0, 0);
  DecreaseButton.ObjectSize := DecreaseSize;
  IncreaseButton.Pos := Classes.Point(ClientSize.X - IncreaseSize.X, 0);
  IncreaseButton.ObjectSize := IncreaseSize;
  BeforeThumbImage.Pos := Classes.Point(DecreaseSize.X, 0);
  BeforeThumbImage.ObjectSize := Classes.Point(ThumbLeft - DecreaseSize.X, AfterThumbImage.GetContentSize.Y);
  AfterThumbImage.Pos := Classes.Point(ThumbRight, 0);
  AfterThumbImage.ObjectSize := Classes.Point(ClientSize.X - ThumbRight - IncreaseSize.X, BeforeThumbImage.GetContentSize.Y);
  ThumbButton.Pos := Classes.Point(ThumbLeft, 0);
  ThumbButton.ObjectSize := Classes.Point(ThumbRight - ThumbLeft, ThumbSize.Y);
  AfterThumbImage.KindX := image_x_tile_right;
  BeforeThumbImage.KindX := image_x_tile_left;
  MarkerImage.Pos := AddPoints(ThumbButton.LocalPosition, HalfPoint(ThumbButton.ClientSize));
  if DecreaseButton.Kind = button_push_can_disable then DecreaseButton.SetDisabled(Position <= Minimum);
  if IncreaseButton.Kind = button_push_can_disable then IncreaseButton.SetDisabled(Position >= Maximum);
end;
{ @end $4AF53C }

{ @routine $4AF7C0 TCountBarGI_AutoRepeat }
procedure TCountBarGI.AutoRepeat(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if DecreaseButton.Down then SetPosition(Position - Step)
  else if IncreaseButton.Down then SetPosition(Position + Step)
  else
  if RepeatTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
end;
{ @end $4AF7C0 }

{ @routine $4AF82C TCountBarGI_DecreasePressed }
procedure TCountBarGI.DecreasePressed(Sender: TObjectGI);
begin
  SetPosition(Position - Step);
  if RepeatTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(300, 50, AutoRepeat);
end;
{ @end $4AF82C }

{ @routine $4AF880 TCountBarGI_IncreasePressed }
procedure TCountBarGI.IncreasePressed(Sender: TObjectGI);
begin
  SetPosition(Position + Step);
  if RepeatTimer <> 0 then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := 0;
  end;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(300, 50, AutoRepeat);
end;
{ @end $4AF880 }

{ @routine $4AF8D4 TCountBarGI_ProcessMouseMove }
procedure TCountBarGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var TrackStart, TrackEnd: Integer;
begin
  inherited ProcessMouseMove(KeyState, Point);
  Point := ToLocalPoint(Point);
  if not ThumbButton.Down or (Orientation <> cbHorizontal) then Exit;
  TrackStart := DecreaseButton.GetMaxStateImageSize.X + ThumbButton.GetMaxStateImageSize.X div 2;
  TrackEnd := ClientSize.X - IncreaseButton.GetMaxStateImageSize.X -
    (ThumbButton.GetMaxStateImageSize.X - ThumbButton.GetMaxStateImageSize.X div 2);
  if Maximum - Minimum = 0 then SetPosition(Minimum)
  else SetPosition(Integer(Round((Point.X - TrackStart) / (TrackEnd - TrackStart) * (Maximum - Minimum))) + Minimum);
end;
{ @end $4AF8D4 }

{ @routine $4AFA04 TCountBarGI_OnMouseEnter }
procedure TCountBarGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $4AFA04 }

{ @routine $4AFA0C TCountBarGI_OnMouseLeave }
procedure TCountBarGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
end;
{ @end $4AFA0C }

{ @routine $4AFA14 TCountBarGI_ProcessLeftButtonDown }
procedure TCountBarGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
var TrackStart, TrackEnd: Integer;
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Active then MessageLoop.SetFocusedControl(Self);
  Point := ToLocalPoint(Point);
  if Orientation <> cbHorizontal then Exit;
  TrackStart := DecreaseButton.GetMaxStateImageSize.X + ThumbButton.GetMaxStateImageSize.X div 2;
  TrackEnd := ClientSize.X - IncreaseButton.GetMaxStateImageSize.X -
    (ThumbButton.GetMaxStateImageSize.X - ThumbButton.GetMaxStateImageSize.X div 2);
  if (Point.X >= DecreaseButton.GetMaxStateImageSize.X) and
    (Point.X <= ClientSize.X - IncreaseButton.GetMaxStateImageSize.X) then
  begin
    if Maximum - Minimum = 0 then SetPosition(Minimum)
    else SetPosition(Integer(Round((Point.X - TrackStart) / (TrackEnd - TrackStart) * (Maximum - Minimum))) + Minimum);
    ThumbButton.SetDown(True);
  end;
end;
{ @end $4AFA14 }

{ @routine $4AFB88 TCountBarGI_ProcessLeftButtonUp }
procedure TCountBarGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  ThumbButton.SetDown(False);
  if MessageLoop.FocusedControl = Self then MessageLoop.SetFocusedControl(nil);
end;
{ @end $4AFB88 }

{ @routine $4AFBC4 TCountBarGI_LoadFromConfigPath }
procedure TCountBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadCountBarProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4AFBC4 }

{ @routine $4AFBF0 TCountBarGI_LoadFromBlock }
procedure TCountBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadCountBarProperties(Block);
end;
{ @end $4AFBF0 }

{ @routine $4AFC0C TCountBarGI_LoadCountBarProperties }
procedure TCountBarGI.LoadCountBarProperties(Block: TBlockParEC);
begin
  if Block.CountParams('ImageDecNormal') > 0 then DecreaseButton.SetImageNormalPath(Block.GetParam('ImageDecNormal'));
  if Block.CountParams('ImageDecNormalA') > 0 then DecreaseButton.SetImageNormalActivePath(Block.GetParam('ImageDecNormalA'));
  if Block.CountParams('ImageDecDown') > 0 then DecreaseButton.SetImageDownPath(Block.GetParam('ImageDecDown'));
  if Block.CountParams('ImageIncNormal') > 0 then IncreaseButton.SetImageNormalPath(Block.GetParam('ImageIncNormal'));
  if Block.CountParams('ImageIncNormalA') > 0 then IncreaseButton.SetImageNormalActivePath(Block.GetParam('ImageIncNormalA'));
  if Block.CountParams('ImageIncDown') > 0 then IncreaseButton.SetImageDownPath(Block.GetParam('ImageIncDown'));
  if Block.CountParams('ImageTrackMin') > 0 then AfterThumbImage.ImageSourcePath := Block.GetParam('ImageTrackMin');
  if Block.CountParams('ImageTrackMax') > 0 then BeforeThumbImage.ImageSourcePath := Block.GetParam('ImageTrackMax');
  if Block.CountParams('ImageTrackPolNormal') > 0 then ThumbButton.SetImageNormalPath(Block.GetParam('ImageTrackPolNormal'));
  if Block.CountParams('ImageTrackPolNormalA') > 0 then ThumbButton.SetImageNormalActivePath(Block.GetParam('ImageTrackPolNormalA'));
  if Block.CountParams('ImageTrackPolDown') > 0 then ThumbButton.SetImageDownPath(Block.GetParam('ImageTrackPolDown'));
  if Block.CountParams('ImageTrackUp') > 0 then MarkerImage.ImageSourcePath := Block.GetParam('ImageTrackUp');
  UpdateLayout;
end;
{ @end $4AFC0C }

end.
