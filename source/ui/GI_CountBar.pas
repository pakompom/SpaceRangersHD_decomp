unit GI_CountBar;
// Unit bracket (inferred): .text 0x004A4210..0x004A5340; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_GraphButton, GI_Image, GI_MessageLoop, Types;

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
    RepeatTimer: PCallbackTimerGI; // @offset 0x158

    constructor Create(Owner: TObjectGI); // @addr 0x4A4330 @ida "TCountBarGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4A44CC @ida "void __usercall $name(TCountBarGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure SetRange(MinValue, MaxValue: Integer); // @addr 0x4A4608
    procedure SetPositionInternal(Value: Integer); // @addr 0x4A46C8 @note "Clamps without invoking PositionChangedCallback."
    procedure SetPosition(Value: Integer); reintroduce; // @addr 0x4A475C @note "Notifies only while Active and when the requested value differs from the previous position."
    procedure UpdateLayout; // @addr 0x4A4814
    procedure AutoRepeat(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x4A4B04
    procedure DecreasePressed(Sender: TObjectGI); // @addr 0x4A4BA0
    procedure IncreasePressed(Sender: TObjectGI); // @addr 0x4A4C20
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr 0x4A4CA0 @ida "void __usercall $name(TCountBarGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr 0x4A4E30 @ida "void __usercall $name(TCountBarGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr 0x4A4FE8 @ida "void __usercall $name(TCountBarGI *Self@<eax>, unsigned int KeyState@<edx>, TPoint *Point@<ecx>);"
    procedure OnMouseEnter; override; // @addr 0x4A4E08
    procedure OnMouseLeave; override; // @addr 0x4A4E1C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A503C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A5070
    procedure LoadCountBarProperties(Block: TBlockParEC); // @addr 0x4A5098
  end;

implementation

uses Classes, EC_Struct, GI_Main;

{ @routine $4A4330 TCountBarGI_Create }
constructor TCountBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Orientation := 1;
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
  AfterThumbImage.SetImageKindX(ikxLeftFill);
  AfterThumbImage.SetImageKindY(ikyTopFill);
  BeforeThumbImage.SetImageKindX(ikxLeftFill);
  BeforeThumbImage.SetImageKindY(ikyTopFill);
  ThumbButton.SetKind(gbkFix);
end;
{ @end $4A4330 }

{ @routine $4A44CC TCountBarGI_Destroy }
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
  if RepeatTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
  inherited Destroy;
end;
{ @end $4A44CC }

{ @routine $4A4608 TCountBarGI_SetRange }
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
{ @end $4A4608 }

{ @routine $4A46C8 TCountBarGI_SetPositionInternal }
procedure TCountBarGI.SetPositionInternal(Value: Integer);
begin
  if Position <> Value then
  begin
    Position := Value;
    if Position < Minimum then Position := Minimum;
    if Position > Maximum then Position := Maximum;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $4A46C8 }

{ @routine $4A475C TCountBarGI_SetPosition }
procedure TCountBarGI.SetPosition(Value: Integer);
begin
  if Position <> Value then
  begin
    Position := Value;
    if Position < Minimum then Position := Minimum;
    if Position > Maximum then Position := Maximum;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
      if Assigned(PositionChangedCallback) then PositionChangedCallback(Self);
    end;
  end;
end;
{ @end $4A475C }

{ @routine $4A4814 TCountBarGI_UpdateLayout }
procedure TCountBarGI.UpdateLayout;
var
  TrackWidth, ThumbLeft, ThumbRight: Integer;
  ThumbSize, IncreaseSize, DecreaseSize: TPoint;
begin
  if Orientation = 1 then
  begin
    ThumbSize := ThumbButton.GetMaxStateImageSize;
    DecreaseSize := DecreaseButton.GetMaxStateImageSize;
    IncreaseSize := IncreaseButton.GetMaxStateImageSize;
    TrackWidth := ClientSize.X - ThumbSize.X - IncreaseSize.X - DecreaseSize.X;
    if Maximum - Minimum = 0 then ThumbLeft := IncreaseSize.X
    else ThumbLeft := Integer(Round(TrackWidth * (Position - Minimum) / (Maximum - Minimum))) - ThumbSize.X div 2 + IncreaseSize.X + ThumbSize.X div 2;
    ThumbRight := ThumbLeft + ThumbSize.X;
    DecreaseButton.SetPosition(Classes.Point(0, 0));
    DecreaseButton.SetSize(DecreaseSize);
    IncreaseButton.SetPosition(Classes.Point(ClientSize.X - IncreaseSize.X, 0));
    IncreaseButton.SetSize(IncreaseSize);
    BeforeThumbImage.SetPosition(Classes.Point(DecreaseSize.X, 0));
    BeforeThumbImage.SetSize(Classes.Point(ThumbLeft - DecreaseSize.X, AfterThumbImage.GetContentSize.Y));
    AfterThumbImage.SetPosition(Classes.Point(ThumbRight, 0));
    AfterThumbImage.SetSize(Classes.Point(ClientSize.X - ThumbRight - IncreaseSize.X, BeforeThumbImage.GetContentSize.Y));
    ThumbButton.SetPosition(Classes.Point(ThumbLeft, 0));
    ThumbButton.SetSize(Classes.Point(ThumbRight - ThumbLeft, ThumbSize.Y));
    AfterThumbImage.SetImageKindX(ikxRightFill);
    BeforeThumbImage.SetImageKindX(ikxLeftFill);
    MarkerImage.SetPosition(AddPoints(ThumbButton.LocalPosition, HalfPoint(ThumbButton.ClientSize)));
    if DecreaseButton.Kind = gbkDisable then DecreaseButton.SetDisabled(Position <= Minimum);
    if IncreaseButton.Kind = gbkDisable then IncreaseButton.SetDisabled(Position >= Maximum);
  end;
end;
{ @end $4A4814 }

{ @routine $4A4B04 TCountBarGI_AutoRepeat }
procedure TCountBarGI.AutoRepeat(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if DecreaseButton.Down then SetPosition(Position - Step)
  else if IncreaseButton.Down then SetPosition(Position + Step)
  else
  if RepeatTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
end;
{ @end $4A4B04 }

{ @routine $4A4BA0 TCountBarGI_DecreasePressed }
procedure TCountBarGI.DecreasePressed(Sender: TObjectGI);
begin
  SetPosition(Position - Step);
  if RepeatTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(300, 50, AutoRepeat);
end;
{ @end $4A4BA0 }

{ @routine $4A4C20 TCountBarGI_IncreasePressed }
procedure TCountBarGI.IncreasePressed(Sender: TObjectGI);
begin
  SetPosition(Position + Step);
  if RepeatTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(RepeatTimer);
    RepeatTimer := nil;
  end;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(300, 50, AutoRepeat);
end;
{ @end $4A4C20 }

{ @routine $4A4CA0 TCountBarGI_ProcessMouseMove }
procedure TCountBarGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var TrackStart, TrackEnd: Integer;
begin
  inherited ProcessMouseMove(KeyState, Point);
  Point := ToLocalPoint(Point);
  if ThumbButton.Down and (Orientation = 1) then
  begin
    TrackStart := DecreaseButton.GetMaxStateImageSize.X + ThumbButton.GetMaxStateImageSize.X div 2;
    TrackEnd := ClientSize.X - IncreaseButton.GetMaxStateImageSize.X -
      (ThumbButton.GetMaxStateImageSize.X - ThumbButton.GetMaxStateImageSize.X div 2);
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else SetPosition(Integer(Round((Point.X - TrackStart) / (TrackEnd - TrackStart) * (Maximum - Minimum))) + Minimum);
  end;
end;
{ @end $4A4CA0 }

{ @routine $4A4E08 TCountBarGI_OnMouseEnter }
procedure TCountBarGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $4A4E08 }

{ @routine $4A4E1C TCountBarGI_OnMouseLeave }
procedure TCountBarGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
end;
{ @end $4A4E1C }

{ @routine $4A4E30 TCountBarGI_ProcessLeftButtonDown }
procedure TCountBarGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
var TrackStart, TrackEnd: Integer;
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Active then MessageLoop.SetFocusedControl(Self);
  Point := ToLocalPoint(Point);
  if Orientation = 1 then
  begin
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
end;
{ @end $4A4E30 }

{ @routine $4A4FE8 TCountBarGI_ProcessLeftButtonUp }
procedure TCountBarGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  ThumbButton.SetDown(False);
  if MessageLoop.FocusedControl = Self then MessageLoop.SetFocusedControl(nil);
end;
{ @end $4A4FE8 }

{ @routine $4A503C TCountBarGI_LoadFromConfigPath }
procedure TCountBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadCountBarProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4A503C }

{ @routine $4A5070 TCountBarGI_LoadFromBlock }
procedure TCountBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadCountBarProperties(Block);
end;
{ @end $4A5070 }

{ @routine $4A5098 TCountBarGI_LoadCountBarProperties }
procedure TCountBarGI.LoadCountBarProperties(Block: TBlockParEC);
begin
  if Block.CountParams('ImageDecNormal') > 0 then DecreaseButton.SetImageNormalPath(Block.GetParam('ImageDecNormal'));
  if Block.CountParams('ImageDecNormalA') > 0 then DecreaseButton.SetImageNormalActivePath(Block.GetParam('ImageDecNormalA'));
  if Block.CountParams('ImageDecDown') > 0 then DecreaseButton.SetImageDownPath(Block.GetParam('ImageDecDown'));
  if Block.CountParams('ImageIncNormal') > 0 then IncreaseButton.SetImageNormalPath(Block.GetParam('ImageIncNormal'));
  if Block.CountParams('ImageIncNormalA') > 0 then IncreaseButton.SetImageNormalActivePath(Block.GetParam('ImageIncNormalA'));
  if Block.CountParams('ImageIncDown') > 0 then IncreaseButton.SetImageDownPath(Block.GetParam('ImageIncDown'));
  if Block.CountParams('ImageTrackMin') > 0 then AfterThumbImage.SetImagePath(Block.GetParam('ImageTrackMin'));
  if Block.CountParams('ImageTrackMax') > 0 then BeforeThumbImage.SetImagePath(Block.GetParam('ImageTrackMax'));
  if Block.CountParams('ImageTrackPolNormal') > 0 then ThumbButton.SetImageNormalPath(Block.GetParam('ImageTrackPolNormal'));
  if Block.CountParams('ImageTrackPolNormalA') > 0 then ThumbButton.SetImageNormalActivePath(Block.GetParam('ImageTrackPolNormalA'));
  if Block.CountParams('ImageTrackPolDown') > 0 then ThumbButton.SetImageDownPath(Block.GetParam('ImageTrackPolDown'));
  if Block.CountParams('ImageTrackUp') > 0 then MarkerImage.SetImagePath(Block.GetParam('ImageTrackUp'));
  UpdateLayout;
end;
{ @end $4A5098 }

end.
