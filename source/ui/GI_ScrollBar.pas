unit GI_ScrollBar;

interface

uses EC_BlockPar, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types;

const
  // Zero selects an individual value; every nonzero mode accounts for PageSize.
  scroll_calc_value = 0;

  scroll_hit_none = 0;
  scroll_hit_arrow_dec = 1;
  scroll_hit_arrow_inc = 2;
  scroll_hit_page_before = 3;
  scroll_hit_page_after = 4;
  scroll_hit_thumb = 5;

  scroll_image_normal = 0;
  scroll_image_hover = 1;
  scroll_image_pressed = 2;

type
  TScrollBarRegion = type Cardinal;
  TScrollBarOrientation = (scroll_axis_horizontal = 1, scroll_axis_vertical); // @size $04

  TScrollBarGI = class(TPanelGI) // @size 0x1D8
  public
    Minimum: Integer; // @offset 0x140
    Maximum: Integer; // @offset 0x144
    Position: Integer; // @offset 0x148
    LargeChange: Integer; // @offset 0x14C
    SmallChange: Integer; // @offset 0x150
    PageSize: Integer; // @offset 0x154
    Orientation: TScrollBarOrientation; // @offset 0x158
    CalculationMode: Integer; // @offset 0x15C
    // Each image triple is normal, active, down. Up/Down also mean left/right horizontally.
    UpImages: array[0..2] of TImageGI; // @offset 0x160
    BeforeThumbBarImages: array[0..2] of TImageGI; // @offset 0x16C
    ThumbTopImages: array[0..2] of TImageGI; // @offset 0x178
    ThumbCenterImages: array[0..2] of TImageGI; // @offset 0x184
    ThumbBottomImages: array[0..2] of TImageGI; // @offset 0x190
    AfterThumbBarImages: array[0..2] of TImageGI; // @offset 0x19C
    DownImages: array[0..2] of TImageGI; // @offset 0x1A8
    RepeatTimer: TCallbackTimerIdGI; // @offset 0x1B4
    PressedRegion: TScrollBarRegion; // @offset 0x1B8
    HoveredRegion: TScrollBarRegion; // @offset 0x1BC
    DragStartPosition: Integer; // @offset 0x1C0
    MinimumLabel: TLabelGI; // @offset 0x1C4
    MaximumLabel: TLabelGI; // @offset 0x1C8
    PositionLabel: TLabelGI; // @offset 0x1CC
    PositionChangedCallback: TObjectNotifyEventGI; // @offset $1D0

    constructor Create(Owner: TObjectGI); // @addr 0x004A1470
    destructor Destroy; override; // @addr 0x004A17DC
    procedure Clear; override; // @addr 0x004A18E8 @note "Resets the range to 0..99 and clears callbacks; does not call inherited Clear."
    function GetHitRegion(Point: TPoint): TScrollBarRegion; // @addr 0x004A1BB4 @note "Returns 0 outside, 1/2 arrows, 3/4 page regions, or 5 thumb; only tests the scrolling axis."
    procedure SetRange(MinValue, MaxValue: Integer); // @addr 0x004A1CC8
    procedure SetPositionInternal(NewPosition: Integer); // @addr 0x004A1E08 @note "Does not invoke PositionChangedCallback."
    procedure SetPosition(NewPosition: Integer); reintroduce; // @addr 0x004A1F54 @note "Notifies only while Active and only when the clamped position changes."
    procedure SetSmallChange(Value: Integer); // @addr 0x004A20B8
    procedure SetLargeChange(Value: Integer); // @addr 0x004A20E4 @note "A value equal to SmallChange is ignored even if LargeChange differs."
    procedure SetPageSize(Value: Integer); // @addr 0x004A2110 @note "Caps at Maximum-Minimum+1; no lower bound check."
    procedure SetOrientation(Value: TScrollBarOrientation); // @addr 0x004A2154 @note "Any value other than scroll_axis_horizontal uses vertical layout."
    procedure SetKindCalcMode(Value: Integer); // @addr 0x004A2180
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x004A21AC
    procedure SetSize(Size: TPoint); override; // @addr 0x004A21D0
    procedure UpdateLayout; // @addr 0x004A221C
    procedure UpdateSizeForOrientation; // @addr 0x004A3140 @note "Uses the up-arrow image for scrollbar thickness."
    procedure StartAutoRepeat(DelayMs, RepeatMs: Integer); // @addr 0x004A37B0
    procedure StopAutoRepeat; // @addr 0x004A37E0
    procedure AutoRepeat(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr 0x004A3804
    procedure SetUpPosition(Point: TPoint); // @addr $4A195C
    procedure SetBeforeThumbBarPosition(Point: TPoint); // @addr $4A1998
    procedure SetThumbTopPosition(Point: TPoint); // @addr $4A19D4
    procedure SetThumbCenterPosition(Point: TPoint); // @addr $4A1A10
    procedure SetThumbBottomPosition(Point: TPoint); // @addr $4A1A4C
    procedure SetAfterThumbBarPosition(Point: TPoint); // @addr $4A1A88
    procedure SetDownPosition(Point: TPoint); // @addr $4A1AC4
    procedure SetBeforeThumbBarSize(Size: TPoint); // @addr $4A1B00
    procedure SetThumbCenterSize(Size: TPoint); // @addr $4A1B3C
    procedure SetAfterThumbBarSize(Size: TPoint); // @addr $4A1B78
    procedure SetActive(Enabled: Boolean); override; // @addr $4A21FC
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4A3190
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4A3438
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4A3754
    procedure ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint); override; // @addr $4A37AC
    procedure OnMouseEnter; override; // @addr $4A33FC
    procedure OnMouseLeave; override; // @addr $4A3404
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004A3868
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004A3894
    procedure LoadScrollBarProperties(Block: TBlockParEC); // @addr 0x004A38B0
  end;

implementation

uses Classes, GI_Main, GR_Main, SysUtils;

{ @routine $4A1470 TScrollBarGI_Create }
constructor TScrollBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  RepeatTimer := 0;
  UpImages[scroll_image_normal] := TImageGI.Create(Self);
  UpImages[scroll_image_normal].SetDepth(1);
  UpImages[scroll_image_hover] := TImageGI.Create(Self);
  UpImages[scroll_image_hover].SetDepth(1);
  UpImages[scroll_image_pressed] := TImageGI.Create(Self);
  UpImages[scroll_image_pressed].SetDepth(1);
  BeforeThumbBarImages[scroll_image_normal] := TImageGI.Create(Self);
  BeforeThumbBarImages[scroll_image_normal].SetDepth(1);
  BeforeThumbBarImages[scroll_image_hover] := TImageGI.Create(Self);
  BeforeThumbBarImages[scroll_image_hover].SetDepth(1);
  BeforeThumbBarImages[scroll_image_pressed] := TImageGI.Create(Self);
  BeforeThumbBarImages[scroll_image_pressed].SetDepth(1);
  ThumbTopImages[scroll_image_normal] := TImageGI.Create(Self);
  ThumbTopImages[scroll_image_normal].SetDepth(0);
  ThumbTopImages[scroll_image_hover] := TImageGI.Create(Self);
  ThumbTopImages[scroll_image_hover].SetDepth(0);
  ThumbTopImages[scroll_image_pressed] := TImageGI.Create(Self);
  ThumbTopImages[scroll_image_pressed].SetDepth(0);
  ThumbCenterImages[scroll_image_normal] := TImageGI.Create(Self);
  ThumbCenterImages[scroll_image_normal].SetDepth(0);
  ThumbCenterImages[scroll_image_hover] := TImageGI.Create(Self);
  ThumbCenterImages[scroll_image_hover].SetDepth(0);
  ThumbCenterImages[scroll_image_pressed] := TImageGI.Create(Self);
  ThumbCenterImages[scroll_image_pressed].SetDepth(0);
  ThumbBottomImages[scroll_image_normal] := TImageGI.Create(Self);
  ThumbBottomImages[scroll_image_normal].SetDepth(0);
  ThumbBottomImages[scroll_image_hover] := TImageGI.Create(Self);
  ThumbBottomImages[scroll_image_hover].SetDepth(0);
  ThumbBottomImages[scroll_image_pressed] := TImageGI.Create(Self);
  ThumbBottomImages[scroll_image_pressed].SetDepth(0);
  AfterThumbBarImages[scroll_image_normal] := TImageGI.Create(Self);
  AfterThumbBarImages[scroll_image_normal].SetDepth(1);
  AfterThumbBarImages[scroll_image_hover] := TImageGI.Create(Self);
  AfterThumbBarImages[scroll_image_hover].SetDepth(1);
  AfterThumbBarImages[scroll_image_pressed] := TImageGI.Create(Self);
  AfterThumbBarImages[scroll_image_pressed].SetDepth(1);
  DownImages[scroll_image_normal] := TImageGI.Create(Self);
  DownImages[scroll_image_normal].SetDepth(1);
  DownImages[scroll_image_hover] := TImageGI.Create(Self);
  DownImages[scroll_image_hover].SetDepth(1);
  DownImages[scroll_image_pressed] := TImageGI.Create(Self);
  DownImages[scroll_image_pressed].SetDepth(1);
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := scroll_axis_vertical;
  CalculationMode := scroll_calc_value;
end;
{ @end $4A1470 }

{ @routine $4A17DC TScrollBarGI_Destroy }
destructor TScrollBarGI.Destroy;
begin
  UpImages[scroll_image_normal].Free;
  UpImages[scroll_image_hover].Free;
  UpImages[scroll_image_pressed].Free;
  BeforeThumbBarImages[scroll_image_normal].Free;
  BeforeThumbBarImages[scroll_image_hover].Free;
  BeforeThumbBarImages[scroll_image_pressed].Free;
  ThumbTopImages[scroll_image_normal].Free;
  ThumbTopImages[scroll_image_hover].Free;
  ThumbTopImages[scroll_image_pressed].Free;
  ThumbCenterImages[scroll_image_normal].Free;
  ThumbCenterImages[scroll_image_hover].Free;
  ThumbCenterImages[scroll_image_pressed].Free;
  ThumbBottomImages[scroll_image_normal].Free;
  ThumbBottomImages[scroll_image_hover].Free;
  ThumbBottomImages[scroll_image_pressed].Free;
  AfterThumbBarImages[scroll_image_normal].Free;
  AfterThumbBarImages[scroll_image_hover].Free;
  AfterThumbBarImages[scroll_image_pressed].Free;
  DownImages[scroll_image_normal].Free;
  DownImages[scroll_image_hover].Free;
  DownImages[scroll_image_pressed].Free;
  inherited Destroy;
end;
{ @end $4A17DC }

{ @routine $4A18E8 TScrollBarGI_Clear }
procedure TScrollBarGI.Clear;
begin
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := scroll_axis_vertical;
  CalculationMode := scroll_calc_value;
  PressedRegion := scroll_hit_none;
  HoveredRegion := scroll_hit_none;
  StopAutoRepeat;
  PositionChangedCallback := nil;
end;
{ @end $4A18E8 }

{ @routine $4A195C TScrollBarGI_SetUpPosition }
procedure TScrollBarGI.SetUpPosition(Point: TPoint);
begin
  UpImages[scroll_image_normal].Pos := Point;
  UpImages[scroll_image_hover].Pos := Point;
  UpImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A195C }

{ @routine $4A1998 TScrollBarGI_SetBeforeThumbBarPosition }
procedure TScrollBarGI.SetBeforeThumbBarPosition(Point: TPoint);
begin
  BeforeThumbBarImages[scroll_image_normal].Pos := Point;
  BeforeThumbBarImages[scroll_image_hover].Pos := Point;
  BeforeThumbBarImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A1998 }

{ @routine $4A19D4 TScrollBarGI_SetThumbTopPosition }
procedure TScrollBarGI.SetThumbTopPosition(Point: TPoint);
begin
  ThumbTopImages[scroll_image_normal].Pos := Point;
  ThumbTopImages[scroll_image_hover].Pos := Point;
  ThumbTopImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A19D4 }

{ @routine $4A1A10 TScrollBarGI_SetThumbCenterPosition }
procedure TScrollBarGI.SetThumbCenterPosition(Point: TPoint);
begin
  ThumbCenterImages[scroll_image_normal].Pos := Point;
  ThumbCenterImages[scroll_image_hover].Pos := Point;
  ThumbCenterImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A1A10 }

{ @routine $4A1A4C TScrollBarGI_SetThumbBottomPosition }
procedure TScrollBarGI.SetThumbBottomPosition(Point: TPoint);
begin
  ThumbBottomImages[scroll_image_normal].Pos := Point;
  ThumbBottomImages[scroll_image_hover].Pos := Point;
  ThumbBottomImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A1A4C }

{ @routine $4A1A88 TScrollBarGI_SetAfterThumbBarPosition }
procedure TScrollBarGI.SetAfterThumbBarPosition(Point: TPoint);
begin
  AfterThumbBarImages[scroll_image_normal].Pos := Point;
  AfterThumbBarImages[scroll_image_hover].Pos := Point;
  AfterThumbBarImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A1A88 }

{ @routine $4A1AC4 TScrollBarGI_SetDownPosition }
procedure TScrollBarGI.SetDownPosition(Point: TPoint);
begin
  DownImages[scroll_image_normal].Pos := Point;
  DownImages[scroll_image_hover].Pos := Point;
  DownImages[scroll_image_pressed].Pos := Point;
end;
{ @end $4A1AC4 }

{ @routine $4A1B00 TScrollBarGI_SetBeforeThumbBarSize }
procedure TScrollBarGI.SetBeforeThumbBarSize(Size: TPoint);
begin
  BeforeThumbBarImages[scroll_image_normal].ObjectSize := Size;
  BeforeThumbBarImages[scroll_image_hover].ObjectSize := Size;
  BeforeThumbBarImages[scroll_image_pressed].ObjectSize := Size;
end;
{ @end $4A1B00 }

{ @routine $4A1B3C TScrollBarGI_SetThumbCenterSize }
procedure TScrollBarGI.SetThumbCenterSize(Size: TPoint);
begin
  ThumbCenterImages[scroll_image_normal].ObjectSize := Size;
  ThumbCenterImages[scroll_image_hover].ObjectSize := Size;
  ThumbCenterImages[scroll_image_pressed].ObjectSize := Size;
end;
{ @end $4A1B3C }

{ @routine $4A1B78 TScrollBarGI_SetAfterThumbBarSize }
procedure TScrollBarGI.SetAfterThumbBarSize(Size: TPoint);
begin
  AfterThumbBarImages[scroll_image_normal].ObjectSize := Size;
  AfterThumbBarImages[scroll_image_hover].ObjectSize := Size;
  AfterThumbBarImages[scroll_image_pressed].ObjectSize := Size;
end;
{ @end $4A1B78 }

{ @routine $4A1BB4 TScrollBarGI_GetHitRegion }
function TScrollBarGI.GetHitRegion(Point: TPoint): TScrollBarRegion;
var
  UpEnd, ThumbStart, ThumbEnd, DownStart: Integer;
begin
  if Orientation = scroll_axis_horizontal then
  begin
    UpEnd := UpImages[scroll_image_normal].ClientSize.X;
    ThumbStart := ThumbTopImages[scroll_image_normal].LocalPosition.X;
    ThumbEnd := ThumbBottomImages[scroll_image_normal].LocalPosition.X + ThumbBottomImages[scroll_image_normal].ClientSize.X;
    DownStart := ClientSize.X - DownImages[scroll_image_normal].ClientSize.X;
    if Point.X < 0 then Result := scroll_hit_none
    else if Point.X <= UpEnd then Result := scroll_hit_arrow_dec
    else if Point.X <= ThumbStart then Result := scroll_hit_page_before
    else if Point.X <= ThumbEnd then Result := scroll_hit_thumb
    else if Point.X <= DownStart then Result := scroll_hit_page_after
    else if Point.X <= ClientSize.X then Result := scroll_hit_arrow_inc
    else Result := scroll_hit_none;
  end
  else
  begin
    UpEnd := UpImages[scroll_image_normal].ClientSize.Y;
    ThumbStart := ThumbTopImages[scroll_image_normal].LocalPosition.Y;
    ThumbEnd := ThumbBottomImages[scroll_image_normal].LocalPosition.Y + ThumbBottomImages[scroll_image_normal].ClientSize.Y;
    DownStart := ClientSize.Y - DownImages[scroll_image_normal].ClientSize.Y;
    if Point.Y < 0 then Result := scroll_hit_none
    else if Point.Y <= UpEnd then Result := scroll_hit_arrow_dec
    else if Point.Y <= ThumbStart then Result := scroll_hit_page_before
    else if Point.Y <= ThumbEnd then Result := scroll_hit_thumb
    else if Point.Y <= DownStart then Result := scroll_hit_page_after
    else if Point.Y <= ClientSize.Y then Result := scroll_hit_arrow_inc
    else Result := scroll_hit_none;
  end;
end;
{ @end $4A1BB4 }

{ @routine $4A1CC8 TScrollBarGI_SetRange }
procedure TScrollBarGI.SetRange(MinValue, MaxValue: Integer);
begin
  if MinimumLabel <> nil then MinimumLabel.Text := IntToStr(MinValue);
  if MaximumLabel <> nil then MaximumLabel.Text := IntToStr(MaxValue);
  if (Maximum <> MaxValue) or (Minimum <> MinValue) then
  begin
    if MinValue > MaxValue then MinValue := MaxValue;
    Minimum := MinValue;
    Maximum := MaxValue;
    if Position < Minimum then SetPositionInternal(Minimum);
    if Position > Maximum then SetPositionInternal(Maximum);
    if Maximum - Minimum + 1 < PageSize then SetPosition(Minimum);
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $4A1CC8 }

{ @routine $4A1E08 TScrollBarGI_SetPositionInternal }
procedure TScrollBarGI.SetPositionInternal(NewPosition: Integer);
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  if PositionLabel <> nil then PositionLabel.Text := IntToStr(NewPosition);
  if Position = NewPosition then Exit;
  Position := NewPosition;
  if Position < Minimum then Position := Minimum;
  if CalculationMode = scroll_calc_value then
  begin
    if Position > Maximum then Position := Maximum;
  end
  else
  begin
    if Maximum - PageSize + 1 < Position then Position := Maximum - PageSize + 1;
    if Position < Minimum then Position := Minimum;
  end;
  if PositionLabel <> nil then PositionLabel.Text := IntToStr(Position);
  if OldPosition <> Position then
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
end;
{ @end $4A1E08 }

{ @routine $4A1F54 TScrollBarGI_SetPosition }
procedure TScrollBarGI.SetPosition(NewPosition: Integer);
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  if PositionLabel <> nil then PositionLabel.Text := IntToStr(NewPosition);
  if Position = NewPosition then Exit;
  Position := NewPosition;
  if Position < Minimum then Position := Minimum;
  if CalculationMode = scroll_calc_value then
  begin
    if Position > Maximum then Position := Maximum;
  end
  else
  begin
    if Maximum - PageSize + 1 < Position then Position := Maximum - PageSize + 1;
    if Position < Minimum then Position := Minimum;
  end;
  if PositionLabel <> nil then PositionLabel.Text := IntToStr(Position);
  if OldPosition <> Position then
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
      if Assigned(PositionChangedCallback) then PositionChangedCallback(Self);
    end;
end;
{ @end $4A1F54 }

{ @routine $4A20B8 TScrollBarGI_SetSmallChange }
procedure TScrollBarGI.SetSmallChange(Value: Integer);
begin
  if SmallChange = Value then Exit;
  SmallChange := Value;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A20B8 }

{ @routine $4A20E4 TScrollBarGI_SetLargeChange }
procedure TScrollBarGI.SetLargeChange(Value: Integer);
begin
  if SmallChange = Value then Exit;
  LargeChange := Value;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A20E4 }

{ @routine $4A2110 TScrollBarGI_SetPageSize }
procedure TScrollBarGI.SetPageSize(Value: Integer);
begin
  if PageSize = Value then Exit;
  PageSize := Value;
  if PageSize > Maximum - Minimum + 1 then PageSize := Maximum - Minimum + 1;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A2110 }

{ @routine $4A2154 TScrollBarGI_SetOrientation }
procedure TScrollBarGI.SetOrientation(Value: TScrollBarOrientation);
begin
  if Orientation = Value then Exit;
  Orientation := Value;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A2154 }

{ @routine $4A2180 TScrollBarGI_SetKindCalcMode }
procedure TScrollBarGI.SetKindCalcMode(Value: Integer);
begin
  if CalculationMode = Value then Exit;
  CalculationMode := Value;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A2180 }

{ @routine $4A21AC TScrollBarGI_SetConfigPath }
procedure TScrollBarGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A21AC }

{ @routine $4A21D0 TScrollBarGI_SetSize }
procedure TScrollBarGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if Active = True then UpdateLayout;
end;
{ @end $4A21D0 }

{ @routine $4A21FC TScrollBarGI_SetActive }
procedure TScrollBarGI.SetActive(Enabled: Boolean);
begin
  inherited SetActive(Enabled);
  if Enabled = True then UpdateLayout;
end;
{ @end $4A21FC }

{ @routine $4A221C TScrollBarGI_UpdateLayout }
procedure TScrollBarGI.UpdateLayout;
var
  X, Y, TrackLength, BeforeLength, ThumbLength, AfterLength, MinimumThumbLength: Integer;
begin
  if not Active then Exit;
  if Orientation = scroll_axis_horizontal then
  begin
    Y := ClientSize.Y div 2;
    if UpImages[scroll_image_normal].ClientSize.X + DownImages[scroll_image_normal].ClientSize.X +
      ThumbTopImages[scroll_image_normal].ClientSize.X + ThumbBottomImages[scroll_image_normal].ClientSize.X >= ClientSize.X then
    begin
      X := 0;
      SetUpPosition(Classes.Point(X, Y - UpImages[scroll_image_normal].ClientSize.Y div 2));
      Inc(X, UpImages[scroll_image_normal].ClientSize.X);
      SetThumbTopPosition(Classes.Point(X, Y - ThumbTopImages[scroll_image_normal].ClientSize.Y div 2));
      SetBeforeThumbBarPosition(Classes.Point(X, Y - BeforeThumbBarImages[scroll_image_normal].ClientSize.Y div 2));
      SetBeforeThumbBarSize(Classes.Point(
        BeforeThumbBarImages[scroll_image_normal].ClientSize.X,
        BeforeThumbBarImages[scroll_image_normal].ClientSize.Y));
      Inc(X, ThumbTopImages[scroll_image_normal].ClientSize.X);
      ThumbCenterImages[scroll_image_normal].IsActive := False;
      ThumbCenterImages[scroll_image_hover].IsActive := False;
      ThumbCenterImages[scroll_image_pressed].IsActive := False;
      SetThumbBottomPosition(Classes.Point(X, Y - ThumbBottomImages[scroll_image_normal].ClientSize.Y div 2));
      SetAfterThumbBarPosition(Classes.Point(X, Y - AfterThumbBarImages[scroll_image_normal].ClientSize.Y div 2));
      SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[scroll_image_normal].ClientSize.X, AfterThumbBarImages[scroll_image_normal].ClientSize.Y));
      Inc(X, ThumbBottomImages[scroll_image_normal].ClientSize.X);
      SetDownPosition(Classes.Point(X, Y - DownImages[scroll_image_normal].ClientSize.Y div 2));
    end
    else
    begin
      TrackLength := ClientSize.X - UpImages[scroll_image_normal].ClientSize.X - DownImages[scroll_image_normal].ClientSize.X;
      if Maximum - Minimum + 1 = 0 then
      begin
        ThumbLength := TrackLength;
      end
      else
      begin
        ThumbLength := Trunc(PageSize / (Maximum - Minimum + 1) * TrackLength);
        if ThumbLength > TrackLength then
        begin
          ThumbLength := TrackLength;
        end;
      end;
      MinimumThumbLength := 0;
      if ThumbTopImages[scroll_image_normal].ClientSize.X + ThumbBottomImages[scroll_image_normal].ClientSize.X >= ThumbLength then
      begin
        ThumbLength := ThumbTopImages[scroll_image_normal].ClientSize.X + ThumbBottomImages[scroll_image_normal].ClientSize.X;
        MinimumThumbLength := ThumbLength;
      end;
      if CalculationMode = scroll_calc_value then
      begin
        if MinimumThumbLength = 0 then
        begin
          if Maximum - Minimum + 1 = 0 then BeforeLength := 0
          else BeforeLength := Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength);
        end
        else
        begin
          if Maximum - Minimum = 0 then BeforeLength := 0
          else BeforeLength := Trunc((Position - Minimum) / (Maximum - Minimum) * (TrackLength - MinimumThumbLength));
        end;
      end
      else
      begin
        if Maximum - Minimum + 1 = 0 then BeforeLength := 0
        else BeforeLength := Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength);
        if BeforeLength + ThumbLength > TrackLength then BeforeLength := TrackLength - ThumbLength;
      end;
      AfterLength := TrackLength - BeforeLength - ThumbLength;
      if ThumbTopImages[scroll_image_normal].ClientSize.X + ThumbBottomImages[scroll_image_normal].ClientSize.X >= ThumbLength then
      begin
        ThumbCenterImages[scroll_image_normal].IsActive := False;
        ThumbCenterImages[scroll_image_hover].IsActive := False;
        ThumbCenterImages[scroll_image_pressed].IsActive := False;
        SetThumbCenterSize(Classes.Point(0, ThumbCenterImages[scroll_image_normal].ClientSize.Y));
      end
      else
      begin
        ThumbCenterImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb)) or (PressedRegion = scroll_hit_thumb));
        ThumbCenterImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb);
        ThumbCenterImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_thumb;
        SetThumbCenterPosition(Classes.Point(
          UpImages[scroll_image_normal].ClientSize.X + ThumbTopImages[scroll_image_normal].ClientSize.X + BeforeLength,
          Y - ThumbCenterImages[scroll_image_normal].ClientSize.Y div 2));
        SetThumbCenterSize(Classes.Point(
          ThumbLength - (ThumbTopImages[scroll_image_normal].ClientSize.X + ThumbBottomImages[scroll_image_normal].ClientSize.X),
          ThumbCenterImages[scroll_image_normal].ClientSize.Y));
      end;
      SetUpPosition(Classes.Point(0, Y - UpImages[scroll_image_normal].ClientSize.Y div 2));
      SetDownPosition(Classes.Point(
        ClientSize.X - DownImages[scroll_image_normal].ClientSize.X,
        Y - DownImages[scroll_image_normal].ClientSize.Y div 2));
      SetThumbTopPosition(Classes.Point(
        UpImages[scroll_image_normal].ClientSize.X + BeforeLength,
        Y - ThumbTopImages[scroll_image_normal].ClientSize.Y div 2));
      SetThumbBottomPosition(Classes.Point(
        BeforeLength + ThumbLength - ThumbBottomImages[scroll_image_normal].ClientSize.X + UpImages[scroll_image_normal].ClientSize.X,
        Y - ThumbBottomImages[scroll_image_normal].ClientSize.Y div 2));
      SetBeforeThumbBarPosition(Classes.Point(
        UpImages[scroll_image_normal].ClientSize.X,
        Y - BeforeThumbBarImages[scroll_image_normal].ClientSize.Y div 2));
      SetBeforeThumbBarSize(Classes.Point(
        ThumbTopImages[scroll_image_normal].ClientSize.X + BeforeLength,
        BeforeThumbBarImages[scroll_image_normal].ClientSize.Y));
      SetAfterThumbBarPosition(Classes.Point(
        BeforeLength + ThumbLength - ThumbBottomImages[scroll_image_normal].ClientSize.X + DownImages[scroll_image_normal].ClientSize.X,
        Y - AfterThumbBarImages[scroll_image_normal].ClientSize.Y div 2));
      SetAfterThumbBarSize(Classes.Point(
        ThumbBottomImages[scroll_image_normal].ClientSize.X + AfterLength,
        AfterThumbBarImages[scroll_image_normal].ClientSize.Y));
    end;
  end
  else
  begin
    X := ClientSize.X div 2;
    if UpImages[scroll_image_normal].ClientSize.Y + DownImages[scroll_image_normal].ClientSize.Y +
      ThumbTopImages[scroll_image_normal].ClientSize.Y + ThumbBottomImages[scroll_image_normal].ClientSize.Y >= ClientSize.Y then
    begin
      Y := 0;
      SetUpPosition(Classes.Point(X - UpImages[scroll_image_normal].ClientSize.X div 2, Y));
      Inc(Y, UpImages[scroll_image_normal].ClientSize.Y);
      SetThumbTopPosition(Classes.Point(X - ThumbTopImages[scroll_image_normal].ClientSize.X div 2, Y));
      SetBeforeThumbBarPosition(Classes.Point(X - BeforeThumbBarImages[scroll_image_normal].ClientSize.X div 2, Y));
      SetBeforeThumbBarSize(Classes.Point(
        BeforeThumbBarImages[scroll_image_normal].ClientSize.X,
        BeforeThumbBarImages[scroll_image_normal].ClientSize.Y));
      Inc(Y, ThumbTopImages[scroll_image_normal].ClientSize.Y);
      ThumbCenterImages[scroll_image_normal].IsActive := False;
      ThumbCenterImages[scroll_image_hover].IsActive := False;
      ThumbCenterImages[scroll_image_pressed].IsActive := False;
      SetThumbBottomPosition(Classes.Point(X - ThumbBottomImages[scroll_image_normal].ClientSize.X div 2, Y));
      SetAfterThumbBarPosition(Classes.Point(X - AfterThumbBarImages[scroll_image_normal].ClientSize.X div 2, Y));
      SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[scroll_image_normal].ClientSize.X, AfterThumbBarImages[scroll_image_normal].ClientSize.Y));
      Inc(Y, ThumbBottomImages[scroll_image_normal].ClientSize.Y);
      SetDownPosition(Classes.Point(X - DownImages[scroll_image_normal].ClientSize.X div 2, Y));
    end
    else
    begin
      TrackLength := ClientSize.Y - UpImages[scroll_image_normal].ClientSize.Y - DownImages[scroll_image_normal].ClientSize.Y;
      if Maximum - Minimum + 1 = 0 then
      begin
        ThumbLength := TrackLength;
      end
      else
      begin
        ThumbLength := Trunc(PageSize / (Maximum - Minimum + 1) * TrackLength);
        if ThumbLength > TrackLength then
        begin
          ThumbLength := TrackLength;
        end;
      end;
      MinimumThumbLength := 0;
      if ThumbTopImages[scroll_image_normal].ClientSize.Y + ThumbBottomImages[scroll_image_normal].ClientSize.Y >= ThumbLength then
      begin
        ThumbLength := ThumbTopImages[scroll_image_normal].ClientSize.Y + ThumbBottomImages[scroll_image_normal].ClientSize.Y;
        MinimumThumbLength := ThumbLength;
      end;
      if CalculationMode = scroll_calc_value then
      begin
        if MinimumThumbLength = 0 then
        begin
          if Maximum - Minimum + 1 = 0 then BeforeLength := 0
          else BeforeLength := Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength);
        end
        else
        begin
          if Maximum - Minimum = 0 then BeforeLength := 0
          else BeforeLength := Trunc((Position - Minimum) / (Maximum - Minimum) * (TrackLength - MinimumThumbLength));
        end;
      end
      else
      begin
        if Maximum - Minimum + 1 = 0 then BeforeLength := 0
        else BeforeLength := Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength);
        if BeforeLength + ThumbLength > TrackLength then BeforeLength := TrackLength - ThumbLength;
      end;
      AfterLength := TrackLength - BeforeLength - ThumbLength;
      if ThumbTopImages[scroll_image_normal].ClientSize.Y + ThumbBottomImages[scroll_image_normal].ClientSize.Y >= ThumbLength then
      begin
        ThumbCenterImages[scroll_image_normal].IsActive := False;
        ThumbCenterImages[scroll_image_hover].IsActive := False;
        ThumbCenterImages[scroll_image_pressed].IsActive := False;
        SetThumbCenterSize(Classes.Point(ThumbCenterImages[scroll_image_normal].ClientSize.X, 0));
      end
      else
      begin
        ThumbCenterImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb)) or (PressedRegion = scroll_hit_thumb));
        ThumbCenterImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb);
        ThumbCenterImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_thumb;
        SetThumbCenterPosition(Classes.Point(
          X - ThumbCenterImages[scroll_image_normal].ClientSize.X div 2,
          UpImages[scroll_image_normal].ClientSize.Y + ThumbTopImages[scroll_image_normal].ClientSize.Y + BeforeLength));
        SetThumbCenterSize(Classes.Point(
          ThumbCenterImages[scroll_image_normal].ClientSize.X,
          ThumbLength - (ThumbTopImages[scroll_image_normal].ClientSize.Y + ThumbBottomImages[scroll_image_normal].ClientSize.Y)));
      end;
      SetUpPosition(Classes.Point(X - UpImages[scroll_image_normal].ClientSize.X div 2, 0));
      SetDownPosition(Classes.Point(
        X - DownImages[scroll_image_normal].ClientSize.X div 2,
        ClientSize.Y - DownImages[scroll_image_normal].ClientSize.Y));
      SetThumbTopPosition(Classes.Point(
        X - ThumbTopImages[scroll_image_normal].ClientSize.X div 2,
        UpImages[scroll_image_normal].ClientSize.Y + BeforeLength));
      SetThumbBottomPosition(Classes.Point(
        X - ThumbBottomImages[scroll_image_normal].ClientSize.X div 2,
        BeforeLength + ThumbLength - ThumbBottomImages[scroll_image_normal].ClientSize.Y + UpImages[scroll_image_normal].ClientSize.Y));
      SetBeforeThumbBarPosition(Classes.Point(
        X - BeforeThumbBarImages[scroll_image_normal].ClientSize.X div 2,
        UpImages[scroll_image_normal].ClientSize.Y));
      SetBeforeThumbBarSize(Classes.Point(
        BeforeThumbBarImages[scroll_image_normal].ClientSize.X,
        ThumbTopImages[scroll_image_normal].ClientSize.Y + BeforeLength));
      SetAfterThumbBarPosition(Classes.Point(
        X - AfterThumbBarImages[scroll_image_normal].ClientSize.X div 2,
        BeforeLength + ThumbLength - ThumbBottomImages[scroll_image_normal].ClientSize.Y + DownImages[scroll_image_normal].ClientSize.Y));
      SetAfterThumbBarSize(Classes.Point(
        AfterThumbBarImages[scroll_image_normal].ClientSize.X,
        ThumbBottomImages[scroll_image_normal].ClientSize.Y + AfterLength));
    end;
  end;
  UpImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_arrow_dec)) or (PressedRegion = scroll_hit_arrow_dec));
  UpImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_arrow_dec);
  UpImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_arrow_dec;
  BeforeThumbBarImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_page_before)) or (PressedRegion = scroll_hit_page_before));
  BeforeThumbBarImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_page_before);
  BeforeThumbBarImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_page_before;
  ThumbTopImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb)) or (PressedRegion = scroll_hit_thumb));
  ThumbTopImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb);
  ThumbTopImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_thumb;
  ThumbBottomImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb)) or (PressedRegion = scroll_hit_thumb));
  ThumbBottomImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_thumb);
  ThumbBottomImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_thumb;
  AfterThumbBarImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_page_after)) or (PressedRegion = scroll_hit_page_after));
  AfterThumbBarImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_page_after);
  AfterThumbBarImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_page_after;
  DownImages[scroll_image_normal].IsActive := not (((PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_arrow_inc)) or (PressedRegion = scroll_hit_arrow_inc));
  DownImages[scroll_image_hover].IsActive := (PressedRegion = scroll_hit_none) and (HoveredRegion = scroll_hit_arrow_inc);
  DownImages[scroll_image_pressed].IsActive := PressedRegion = scroll_hit_arrow_inc;
end;
{ @end $4A221C }

{ @routine $4A3140 TScrollBarGI_UpdateSizeForOrientation }
procedure TScrollBarGI.UpdateSizeForOrientation;
begin
  if Orientation = scroll_axis_horizontal then
    ObjectSize := Classes.Point(ClientSize.X, UpImages[scroll_image_normal].ClientSize.Y)
  else
    ObjectSize := Classes.Point(UpImages[scroll_image_normal].ClientSize.X, ClientSize.Y);
end;
{ @end $4A3140 }

{ @routine $4A3190 TScrollBarGI_ProcessMouseMove }
procedure TScrollBarGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessMouseMove(KeyState, Point);
  if PressedRegion = scroll_hit_thumb then
  begin
    if Orientation = scroll_axis_horizontal then
    begin
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else if CalculationMode = scroll_calc_value then
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[scroll_image_normal].ClientSize.X
          - DownImages[scroll_image_normal].ClientSize.X
          - ThumbCenterImages[scroll_image_normal].ClientSize.X
          - ThumbTopImages[scroll_image_normal].ClientSize.X
          - ThumbBottomImages[scroll_image_normal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[scroll_image_normal].ClientSize.X))) + DragStartPosition)
      else
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[scroll_image_normal].ClientSize.X
          - DownImages[scroll_image_normal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[scroll_image_normal].ClientSize.X))) + DragStartPosition);
    end
    else
    begin
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else if CalculationMode = scroll_calc_value then
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[scroll_image_normal].ClientSize.Y
          - DownImages[scroll_image_normal].ClientSize.Y
          - ThumbCenterImages[scroll_image_normal].ClientSize.Y
          - ThumbTopImages[scroll_image_normal].ClientSize.Y
          - ThumbBottomImages[scroll_image_normal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[scroll_image_normal].ClientSize.Y))) + DragStartPosition)
      else
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[scroll_image_normal].ClientSize.Y
          - DownImages[scroll_image_normal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[scroll_image_normal].ClientSize.Y))) + DragStartPosition);
    end;
  end;
  HoveredRegion := GetHitRegion(ToLocalPoint(Point));
  UpdateLayout;
  Invalidate;
end;
{ @end $4A3190 }

{ @routine $4A33FC TScrollBarGI_OnMouseEnter }
procedure TScrollBarGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $4A33FC }

{ @routine $4A3404 TScrollBarGI_OnMouseLeave }
procedure TScrollBarGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if PressedRegion = scroll_hit_none then HoveredRegion := scroll_hit_none;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $4A3404 }

{ @routine $4A3438 TScrollBarGI_ProcessLeftButtonDown }
procedure TScrollBarGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Active then MessageLoop.SetFocusedControl(Self);
  HoveredRegion := GetHitRegion(ToLocalPoint(Point));
  PressedRegion := HoveredRegion;
  if PressedRegion = scroll_hit_arrow_dec then
  begin
    SetPosition(Position - SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = scroll_hit_arrow_inc then
  begin
    SetPosition(Position + SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = scroll_hit_page_before then
  begin
    SetPosition(Position - LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = scroll_hit_page_after then
  begin
    SetPosition(Position + LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = scroll_hit_thumb then
  begin
    StopAutoRepeat;
    if Maximum - Minimum = 0 then DragStartPosition := Minimum
    else if Orientation = scroll_axis_horizontal then
    begin
      if CalculationMode = scroll_calc_value then
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[scroll_image_normal].ClientSize.X
          - DownImages[scroll_image_normal].ClientSize.X
          - ThumbCenterImages[scroll_image_normal].ClientSize.X
          - ThumbTopImages[scroll_image_normal].ClientSize.X
          - ThumbBottomImages[scroll_image_normal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[scroll_image_normal].ClientSize.X)))
      else
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[scroll_image_normal].ClientSize.X
          - DownImages[scroll_image_normal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[scroll_image_normal].ClientSize.X)));
    end
    else
    begin
      if CalculationMode = scroll_calc_value then
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[scroll_image_normal].ClientSize.Y
          - DownImages[scroll_image_normal].ClientSize.Y
          - ThumbCenterImages[scroll_image_normal].ClientSize.Y
          - ThumbTopImages[scroll_image_normal].ClientSize.Y
          - ThumbBottomImages[scroll_image_normal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[scroll_image_normal].ClientSize.Y)))
      else
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[scroll_image_normal].ClientSize.Y
          - DownImages[scroll_image_normal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[scroll_image_normal].ClientSize.Y)));
    end;
  end;
  UpdateLayout;
  Invalidate;
end;
{ @end $4A3438 }

{ @routine $4A3754 TScrollBarGI_ProcessLeftButtonUp }
procedure TScrollBarGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  PressedRegion := scroll_hit_none;
  if not HitTestCursor then HoveredRegion := scroll_hit_none;
  if MessageLoop.FocusedControl = Self then MessageLoop.SetFocusedControl(nil);
  UpdateLayout;
  StopAutoRepeat;
end;
{ @end $4A3754 }

{ @routine $4A37AC TScrollBarGI_ProcessLeftButtonDoubleClick }
procedure TScrollBarGI.ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint);
begin

end;
{ @end $4A37AC }

{ @routine $4A37B0 TScrollBarGI_StartAutoRepeat }
procedure TScrollBarGI.StartAutoRepeat(DelayMs, RepeatMs: Integer);
begin
  StopAutoRepeat;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(DelayMs, RepeatMs, AutoRepeat);
end;
{ @end $4A37B0 }

{ @routine $4A37E0 TScrollBarGI_StopAutoRepeat }
procedure TScrollBarGI.StopAutoRepeat;
begin
  if RepeatTimer <> 0 then MessageLoop.CancelCallbackTimer(RepeatTimer);
  RepeatTimer := 0;
end;
{ @end $4A37E0 }

{ @routine $4A3804 TScrollBarGI_AutoRepeat }
procedure TScrollBarGI.AutoRepeat(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  if PressedRegion = scroll_hit_arrow_dec then SetPosition(Position - SmallChange)
  else if PressedRegion = scroll_hit_arrow_inc then SetPosition(Position + SmallChange)
  else if PressedRegion = scroll_hit_page_before then SetPosition(Position - LargeChange)
  else if PressedRegion = scroll_hit_page_after then SetPosition(Position + LargeChange);
end;
{ @end $4A3804 }

{ @routine $4A3868 TScrollBarGI_LoadFromConfigPath }
procedure TScrollBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadScrollBarProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4A3868 }

{ @routine $4A3894 TScrollBarGI_LoadFromBlock }
procedure TScrollBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadScrollBarProperties(Block);
end;
{ @end $4A3894 }

{ @routine $4A38B0 TScrollBarGI_LoadScrollBarProperties }
procedure TScrollBarGI.LoadScrollBarProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Min') > 0 then Minimum := StrToInt(Block.GetParam('Min'));
  if Block.CountParams('Max') > 0 then Maximum := StrToInt(Block.GetParam('Max'));
  if Block.CountParams('PageSize') > 0 then PageSize := StrToInt(Block.GetParam('PageSize'));
  if Block.CountParams('LargeChange') > 0 then LargeChange := StrToInt(Block.GetParam('LargeChange'));
  if Block.CountParams('SmallChange') > 0 then SmallChange := StrToInt(Block.GetParam('SmallChange'));
  if Block.CountParams('Position') > 0 then Position := StrToInt(Block.GetParam('Position'));
  if Block.CountParams('Kind') > 0 then
  begin
    if Block.GetParam('Kind') = 'x' then Orientation := scroll_axis_horizontal
    else Orientation := scroll_axis_vertical;
  end;
  if Block.CountParams('KindCalc') > 0 then CalculationMode := StrToInt(Block.GetParam('KindCalc'));
  if Block.CountParams('ImageUpN') > 0 then UpImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageUpN');
  if Block.CountParams('ImageUpA') > 0 then UpImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageUpA');
  if Block.CountParams('ImageUpD') > 0 then UpImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageUpD');
  if Block.CountParams('ImageBarN') > 0 then BeforeThumbBarImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageBarN');
  if Block.CountParams('ImageBarA') > 0 then BeforeThumbBarImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageBarA');
  if Block.CountParams('ImageBarD') > 0 then BeforeThumbBarImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageBarD');
  if Block.CountParams('ImageTopN') > 0 then ThumbTopImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageTopN');
  if Block.CountParams('ImageTopA') > 0 then ThumbTopImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageTopA');
  if Block.CountParams('ImageTopD') > 0 then ThumbTopImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageTopD');
  if Block.CountParams('ImageCenterN') > 0 then ThumbCenterImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageCenterN');
  if Block.CountParams('ImageCenterA') > 0 then ThumbCenterImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageCenterA');
  if Block.CountParams('ImageCenterD') > 0 then ThumbCenterImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageCenterD');
  if Block.CountParams('ImageBottomN') > 0 then ThumbBottomImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageBottomN');
  if Block.CountParams('ImageBottomA') > 0 then ThumbBottomImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageBottomA');
  if Block.CountParams('ImageBottomD') > 0 then ThumbBottomImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageBottomD');
  if Block.CountParams('ImageBarN') > 0 then AfterThumbBarImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageBarN');
  if Block.CountParams('ImageBarA') > 0 then AfterThumbBarImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageBarA');
  if Block.CountParams('ImageBarD') > 0 then AfterThumbBarImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageBarD');
  if Block.CountParams('ImageDownN') > 0 then DownImages[scroll_image_normal].ImageSourcePath := Block.GetParam('ImageDownN');
  if Block.CountParams('ImageDownA') > 0 then DownImages[scroll_image_hover].ImageSourcePath := Block.GetParam('ImageDownA');
  if Block.CountParams('ImageDownD') > 0 then DownImages[scroll_image_pressed].ImageSourcePath := Block.GetParam('ImageDownD');
  UpImages[scroll_image_normal].ObjectSize := UpImages[scroll_image_normal].GetContentSize;
  UpImages[scroll_image_normal].KindX := image_x_center;
  UpImages[scroll_image_normal].KindY := image_y_center;
  UpImages[scroll_image_hover].ObjectSize := UpImages[scroll_image_hover].GetContentSize;
  UpImages[scroll_image_hover].KindX := image_x_center;
  UpImages[scroll_image_hover].KindY := image_y_center;
  UpImages[scroll_image_pressed].ObjectSize := UpImages[scroll_image_pressed].GetContentSize;
  UpImages[scroll_image_pressed].KindX := image_x_center;
  UpImages[scroll_image_pressed].KindY := image_y_center;
  BeforeThumbBarImages[scroll_image_normal].ObjectSize := BeforeThumbBarImages[scroll_image_normal].GetContentSize;
  BeforeThumbBarImages[scroll_image_normal].KindX := image_x_tile_left;
  BeforeThumbBarImages[scroll_image_normal].KindY := image_y_tile_top;
  BeforeThumbBarImages[scroll_image_hover].ObjectSize := BeforeThumbBarImages[scroll_image_hover].GetContentSize;
  BeforeThumbBarImages[scroll_image_hover].KindX := image_x_tile_left;
  BeforeThumbBarImages[scroll_image_hover].KindY := image_y_tile_top;
  BeforeThumbBarImages[scroll_image_pressed].ObjectSize := BeforeThumbBarImages[scroll_image_pressed].GetContentSize;
  BeforeThumbBarImages[scroll_image_pressed].KindX := image_x_tile_left;
  BeforeThumbBarImages[scroll_image_pressed].KindY := image_y_tile_top;
  ThumbTopImages[scroll_image_normal].ObjectSize := ThumbTopImages[scroll_image_normal].GetContentSize;
  ThumbTopImages[scroll_image_normal].KindX := image_x_center;
  ThumbTopImages[scroll_image_normal].KindY := image_y_center;
  ThumbTopImages[scroll_image_hover].ObjectSize := ThumbTopImages[scroll_image_hover].GetContentSize;
  ThumbTopImages[scroll_image_hover].KindX := image_x_center;
  ThumbTopImages[scroll_image_hover].KindY := image_y_center;
  ThumbTopImages[scroll_image_pressed].ObjectSize := ThumbTopImages[scroll_image_pressed].GetContentSize;
  ThumbTopImages[scroll_image_pressed].KindX := image_x_center;
  ThumbTopImages[scroll_image_pressed].KindY := image_y_center;
  ThumbCenterImages[scroll_image_normal].ObjectSize := ThumbCenterImages[scroll_image_normal].GetContentSize;
  ThumbCenterImages[scroll_image_normal].KindX := image_x_tile_left;
  ThumbCenterImages[scroll_image_normal].KindY := image_y_tile_top;
  ThumbCenterImages[scroll_image_hover].ObjectSize := ThumbCenterImages[scroll_image_hover].GetContentSize;
  ThumbCenterImages[scroll_image_hover].KindX := image_x_tile_left;
  ThumbCenterImages[scroll_image_hover].KindY := image_y_tile_top;
  ThumbCenterImages[scroll_image_pressed].ObjectSize := ThumbCenterImages[scroll_image_pressed].GetContentSize;
  ThumbCenterImages[scroll_image_pressed].KindX := image_x_tile_left;
  ThumbCenterImages[scroll_image_pressed].KindY := image_y_tile_top;
  ThumbBottomImages[scroll_image_normal].ObjectSize := ThumbBottomImages[scroll_image_normal].GetContentSize;
  ThumbBottomImages[scroll_image_normal].KindX := image_x_center;
  ThumbBottomImages[scroll_image_normal].KindY := image_y_center;
  ThumbBottomImages[scroll_image_hover].ObjectSize := ThumbBottomImages[scroll_image_hover].GetContentSize;
  ThumbBottomImages[scroll_image_hover].KindX := image_x_center;
  ThumbBottomImages[scroll_image_hover].KindY := image_y_center;
  ThumbBottomImages[scroll_image_pressed].ObjectSize := ThumbBottomImages[scroll_image_pressed].GetContentSize;
  ThumbBottomImages[scroll_image_pressed].KindX := image_x_center;
  ThumbBottomImages[scroll_image_pressed].KindY := image_y_center;
  AfterThumbBarImages[scroll_image_normal].ObjectSize := AfterThumbBarImages[scroll_image_normal].GetContentSize;
  AfterThumbBarImages[scroll_image_normal].KindX := image_x_tile_right;
  AfterThumbBarImages[scroll_image_normal].KindY := image_y_tile_bottom;
  AfterThumbBarImages[scroll_image_hover].ObjectSize := AfterThumbBarImages[scroll_image_hover].GetContentSize;
  AfterThumbBarImages[scroll_image_hover].KindX := image_x_tile_right;
  AfterThumbBarImages[scroll_image_hover].KindY := image_y_tile_bottom;
  AfterThumbBarImages[scroll_image_pressed].ObjectSize := AfterThumbBarImages[scroll_image_pressed].GetContentSize;
  AfterThumbBarImages[scroll_image_pressed].KindX := image_x_tile_right;
  AfterThumbBarImages[scroll_image_pressed].KindY := image_y_tile_bottom;
  DownImages[scroll_image_normal].ObjectSize := DownImages[scroll_image_normal].GetContentSize;
  DownImages[scroll_image_normal].KindX := image_x_center;
  DownImages[scroll_image_normal].KindY := image_y_center;
  DownImages[scroll_image_hover].ObjectSize := DownImages[scroll_image_hover].GetContentSize;
  DownImages[scroll_image_hover].KindX := image_x_center;
  DownImages[scroll_image_hover].KindY := image_y_center;
  DownImages[scroll_image_pressed].ObjectSize := DownImages[scroll_image_pressed].GetContentSize;
  DownImages[scroll_image_pressed].KindX := image_x_center;
  DownImages[scroll_image_pressed].KindY := image_y_center;
  UpdateLayout;
end;
{ @end $4A38B0 }

end.
