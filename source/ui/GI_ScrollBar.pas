unit GI_ScrollBar;

interface

uses EC_BlockPar, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types;

const
  // Zero selects an individual value; every nonzero mode accounts for PageSize.
  scmValue = 0;

  srNoHit = 0;
  srDecreaseArrow = 1;
  srIncreaseArrow = 2;
  srPageBefore = 3;
  srPageAfter = 4;
  srThumb = 5;

  sbImageNormal = 0;
  sbImageActive = 1;
  sbImageDown = 2;

type
  TScrollBarRegion = type Cardinal;
  TScrollBarOrientation = (soHorizontal = 1, soVertical); // @size $04

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
    procedure SetOrientation(Value: TScrollBarOrientation); // @addr 0x004A2154 @note "Any value other than soHorizontal uses vertical layout."
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
  UpImages[sbImageNormal] := TImageGI.Create(Self);
  UpImages[sbImageNormal].SetDepth(1);
  UpImages[sbImageActive] := TImageGI.Create(Self);
  UpImages[sbImageActive].SetDepth(1);
  UpImages[sbImageDown] := TImageGI.Create(Self);
  UpImages[sbImageDown].SetDepth(1);
  BeforeThumbBarImages[sbImageNormal] := TImageGI.Create(Self);
  BeforeThumbBarImages[sbImageNormal].SetDepth(1);
  BeforeThumbBarImages[sbImageActive] := TImageGI.Create(Self);
  BeforeThumbBarImages[sbImageActive].SetDepth(1);
  BeforeThumbBarImages[sbImageDown] := TImageGI.Create(Self);
  BeforeThumbBarImages[sbImageDown].SetDepth(1);
  ThumbTopImages[sbImageNormal] := TImageGI.Create(Self);
  ThumbTopImages[sbImageNormal].SetDepth(0);
  ThumbTopImages[sbImageActive] := TImageGI.Create(Self);
  ThumbTopImages[sbImageActive].SetDepth(0);
  ThumbTopImages[sbImageDown] := TImageGI.Create(Self);
  ThumbTopImages[sbImageDown].SetDepth(0);
  ThumbCenterImages[sbImageNormal] := TImageGI.Create(Self);
  ThumbCenterImages[sbImageNormal].SetDepth(0);
  ThumbCenterImages[sbImageActive] := TImageGI.Create(Self);
  ThumbCenterImages[sbImageActive].SetDepth(0);
  ThumbCenterImages[sbImageDown] := TImageGI.Create(Self);
  ThumbCenterImages[sbImageDown].SetDepth(0);
  ThumbBottomImages[sbImageNormal] := TImageGI.Create(Self);
  ThumbBottomImages[sbImageNormal].SetDepth(0);
  ThumbBottomImages[sbImageActive] := TImageGI.Create(Self);
  ThumbBottomImages[sbImageActive].SetDepth(0);
  ThumbBottomImages[sbImageDown] := TImageGI.Create(Self);
  ThumbBottomImages[sbImageDown].SetDepth(0);
  AfterThumbBarImages[sbImageNormal] := TImageGI.Create(Self);
  AfterThumbBarImages[sbImageNormal].SetDepth(1);
  AfterThumbBarImages[sbImageActive] := TImageGI.Create(Self);
  AfterThumbBarImages[sbImageActive].SetDepth(1);
  AfterThumbBarImages[sbImageDown] := TImageGI.Create(Self);
  AfterThumbBarImages[sbImageDown].SetDepth(1);
  DownImages[sbImageNormal] := TImageGI.Create(Self);
  DownImages[sbImageNormal].SetDepth(1);
  DownImages[sbImageActive] := TImageGI.Create(Self);
  DownImages[sbImageActive].SetDepth(1);
  DownImages[sbImageDown] := TImageGI.Create(Self);
  DownImages[sbImageDown].SetDepth(1);
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := soVertical;
  CalculationMode := scmValue;
end;
{ @end $4A1470 }

{ @routine $4A17DC TScrollBarGI_Destroy }
destructor TScrollBarGI.Destroy;
begin
  UpImages[sbImageNormal].Free;
  UpImages[sbImageActive].Free;
  UpImages[sbImageDown].Free;
  BeforeThumbBarImages[sbImageNormal].Free;
  BeforeThumbBarImages[sbImageActive].Free;
  BeforeThumbBarImages[sbImageDown].Free;
  ThumbTopImages[sbImageNormal].Free;
  ThumbTopImages[sbImageActive].Free;
  ThumbTopImages[sbImageDown].Free;
  ThumbCenterImages[sbImageNormal].Free;
  ThumbCenterImages[sbImageActive].Free;
  ThumbCenterImages[sbImageDown].Free;
  ThumbBottomImages[sbImageNormal].Free;
  ThumbBottomImages[sbImageActive].Free;
  ThumbBottomImages[sbImageDown].Free;
  AfterThumbBarImages[sbImageNormal].Free;
  AfterThumbBarImages[sbImageActive].Free;
  AfterThumbBarImages[sbImageDown].Free;
  DownImages[sbImageNormal].Free;
  DownImages[sbImageActive].Free;
  DownImages[sbImageDown].Free;
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
  Orientation := soVertical;
  CalculationMode := scmValue;
  PressedRegion := srNoHit;
  HoveredRegion := srNoHit;
  StopAutoRepeat;
  PositionChangedCallback := nil;
end;
{ @end $4A18E8 }

{ @routine $4A195C TScrollBarGI_SetUpPosition }
procedure TScrollBarGI.SetUpPosition(Point: TPoint);
begin
  UpImages[sbImageNormal].Pos := Point;
  UpImages[sbImageActive].Pos := Point;
  UpImages[sbImageDown].Pos := Point;
end;
{ @end $4A195C }

{ @routine $4A1998 TScrollBarGI_SetBeforeThumbBarPosition }
procedure TScrollBarGI.SetBeforeThumbBarPosition(Point: TPoint);
begin
  BeforeThumbBarImages[sbImageNormal].Pos := Point;
  BeforeThumbBarImages[sbImageActive].Pos := Point;
  BeforeThumbBarImages[sbImageDown].Pos := Point;
end;
{ @end $4A1998 }

{ @routine $4A19D4 TScrollBarGI_SetThumbTopPosition }
procedure TScrollBarGI.SetThumbTopPosition(Point: TPoint);
begin
  ThumbTopImages[sbImageNormal].Pos := Point;
  ThumbTopImages[sbImageActive].Pos := Point;
  ThumbTopImages[sbImageDown].Pos := Point;
end;
{ @end $4A19D4 }

{ @routine $4A1A10 TScrollBarGI_SetThumbCenterPosition }
procedure TScrollBarGI.SetThumbCenterPosition(Point: TPoint);
begin
  ThumbCenterImages[sbImageNormal].Pos := Point;
  ThumbCenterImages[sbImageActive].Pos := Point;
  ThumbCenterImages[sbImageDown].Pos := Point;
end;
{ @end $4A1A10 }

{ @routine $4A1A4C TScrollBarGI_SetThumbBottomPosition }
procedure TScrollBarGI.SetThumbBottomPosition(Point: TPoint);
begin
  ThumbBottomImages[sbImageNormal].Pos := Point;
  ThumbBottomImages[sbImageActive].Pos := Point;
  ThumbBottomImages[sbImageDown].Pos := Point;
end;
{ @end $4A1A4C }

{ @routine $4A1A88 TScrollBarGI_SetAfterThumbBarPosition }
procedure TScrollBarGI.SetAfterThumbBarPosition(Point: TPoint);
begin
  AfterThumbBarImages[sbImageNormal].Pos := Point;
  AfterThumbBarImages[sbImageActive].Pos := Point;
  AfterThumbBarImages[sbImageDown].Pos := Point;
end;
{ @end $4A1A88 }

{ @routine $4A1AC4 TScrollBarGI_SetDownPosition }
procedure TScrollBarGI.SetDownPosition(Point: TPoint);
begin
  DownImages[sbImageNormal].Pos := Point;
  DownImages[sbImageActive].Pos := Point;
  DownImages[sbImageDown].Pos := Point;
end;
{ @end $4A1AC4 }

{ @routine $4A1B00 TScrollBarGI_SetBeforeThumbBarSize }
procedure TScrollBarGI.SetBeforeThumbBarSize(Size: TPoint);
begin
  BeforeThumbBarImages[sbImageNormal].ObjectSize := Size;
  BeforeThumbBarImages[sbImageActive].ObjectSize := Size;
  BeforeThumbBarImages[sbImageDown].ObjectSize := Size;
end;
{ @end $4A1B00 }

{ @routine $4A1B3C TScrollBarGI_SetThumbCenterSize }
procedure TScrollBarGI.SetThumbCenterSize(Size: TPoint);
begin
  ThumbCenterImages[sbImageNormal].ObjectSize := Size;
  ThumbCenterImages[sbImageActive].ObjectSize := Size;
  ThumbCenterImages[sbImageDown].ObjectSize := Size;
end;
{ @end $4A1B3C }

{ @routine $4A1B78 TScrollBarGI_SetAfterThumbBarSize }
procedure TScrollBarGI.SetAfterThumbBarSize(Size: TPoint);
begin
  AfterThumbBarImages[sbImageNormal].ObjectSize := Size;
  AfterThumbBarImages[sbImageActive].ObjectSize := Size;
  AfterThumbBarImages[sbImageDown].ObjectSize := Size;
end;
{ @end $4A1B78 }

{ @routine $4A1BB4 TScrollBarGI_GetHitRegion }
function TScrollBarGI.GetHitRegion(Point: TPoint): TScrollBarRegion;
var
  UpEnd, ThumbStart, ThumbEnd, DownStart: Integer;
begin
  if Orientation = soHorizontal then
  begin
    UpEnd := UpImages[sbImageNormal].ClientSize.X;
    ThumbStart := ThumbTopImages[sbImageNormal].LocalPosition.X;
    ThumbEnd := ThumbBottomImages[sbImageNormal].LocalPosition.X + ThumbBottomImages[sbImageNormal].ClientSize.X;
    DownStart := ClientSize.X - DownImages[sbImageNormal].ClientSize.X;
    if Point.X < 0 then Result := srNoHit
    else if Point.X <= UpEnd then Result := srDecreaseArrow
    else if Point.X <= ThumbStart then Result := srPageBefore
    else if Point.X <= ThumbEnd then Result := srThumb
    else if Point.X <= DownStart then Result := srPageAfter
    else if Point.X <= ClientSize.X then Result := srIncreaseArrow
    else Result := srNoHit;
  end
  else
  begin
    UpEnd := UpImages[sbImageNormal].ClientSize.Y;
    ThumbStart := ThumbTopImages[sbImageNormal].LocalPosition.Y;
    ThumbEnd := ThumbBottomImages[sbImageNormal].LocalPosition.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y;
    DownStart := ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y;
    if Point.Y < 0 then Result := srNoHit
    else if Point.Y <= UpEnd then Result := srDecreaseArrow
    else if Point.Y <= ThumbStart then Result := srPageBefore
    else if Point.Y <= ThumbEnd then Result := srThumb
    else if Point.Y <= DownStart then Result := srPageAfter
    else if Point.Y <= ClientSize.Y then Result := srIncreaseArrow
    else Result := srNoHit;
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
  if CalculationMode = scmValue then
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
  if CalculationMode = scmValue then
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
  if Orientation = soHorizontal then
  begin
    Y := ClientSize.Y div 2;
    if UpImages[sbImageNormal].ClientSize.X + DownImages[sbImageNormal].ClientSize.X +
      ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X >= ClientSize.X then
    begin
      X := 0;
      SetUpPosition(Classes.Point(X, Y - UpImages[sbImageNormal].ClientSize.Y div 2));
      Inc(X, UpImages[sbImageNormal].ClientSize.X);
      SetThumbTopPosition(Classes.Point(X, Y - ThumbTopImages[sbImageNormal].ClientSize.Y div 2));
      SetBeforeThumbBarPosition(Classes.Point(X, Y - BeforeThumbBarImages[sbImageNormal].ClientSize.Y div 2));
      SetBeforeThumbBarSize(Classes.Point(
        BeforeThumbBarImages[sbImageNormal].ClientSize.X,
        BeforeThumbBarImages[sbImageNormal].ClientSize.Y));
      Inc(X, ThumbTopImages[sbImageNormal].ClientSize.X);
      ThumbCenterImages[sbImageNormal].IsActive := False;
      ThumbCenterImages[sbImageActive].IsActive := False;
      ThumbCenterImages[sbImageDown].IsActive := False;
      SetThumbBottomPosition(Classes.Point(X, Y - ThumbBottomImages[sbImageNormal].ClientSize.Y div 2));
      SetAfterThumbBarPosition(Classes.Point(X, Y - AfterThumbBarImages[sbImageNormal].ClientSize.Y div 2));
      SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[sbImageNormal].ClientSize.X, AfterThumbBarImages[sbImageNormal].ClientSize.Y));
      Inc(X, ThumbBottomImages[sbImageNormal].ClientSize.X);
      SetDownPosition(Classes.Point(X, Y - DownImages[sbImageNormal].ClientSize.Y div 2));
    end
    else
    begin
      TrackLength := ClientSize.X - UpImages[sbImageNormal].ClientSize.X - DownImages[sbImageNormal].ClientSize.X;
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
      if ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X >= ThumbLength then
      begin
        ThumbLength := ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X;
        MinimumThumbLength := ThumbLength;
      end;
      if CalculationMode = scmValue then
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
      if ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X >= ThumbLength then
      begin
        ThumbCenterImages[sbImageNormal].IsActive := False;
        ThumbCenterImages[sbImageActive].IsActive := False;
        ThumbCenterImages[sbImageDown].IsActive := False;
        SetThumbCenterSize(Classes.Point(0, ThumbCenterImages[sbImageNormal].ClientSize.Y));
      end
      else
      begin
        ThumbCenterImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb));
        ThumbCenterImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srThumb);
        ThumbCenterImages[sbImageDown].IsActive := PressedRegion = srThumb;
        SetThumbCenterPosition(Classes.Point(
          UpImages[sbImageNormal].ClientSize.X + ThumbTopImages[sbImageNormal].ClientSize.X + BeforeLength,
          Y - ThumbCenterImages[sbImageNormal].ClientSize.Y div 2));
        SetThumbCenterSize(Classes.Point(
          ThumbLength - (ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X),
          ThumbCenterImages[sbImageNormal].ClientSize.Y));
      end;
      SetUpPosition(Classes.Point(0, Y - UpImages[sbImageNormal].ClientSize.Y div 2));
      SetDownPosition(Classes.Point(
        ClientSize.X - DownImages[sbImageNormal].ClientSize.X,
        Y - DownImages[sbImageNormal].ClientSize.Y div 2));
      SetThumbTopPosition(Classes.Point(
        UpImages[sbImageNormal].ClientSize.X + BeforeLength,
        Y - ThumbTopImages[sbImageNormal].ClientSize.Y div 2));
      SetThumbBottomPosition(Classes.Point(
        BeforeLength + ThumbLength - ThumbBottomImages[sbImageNormal].ClientSize.X + UpImages[sbImageNormal].ClientSize.X,
        Y - ThumbBottomImages[sbImageNormal].ClientSize.Y div 2));
      SetBeforeThumbBarPosition(Classes.Point(
        UpImages[sbImageNormal].ClientSize.X,
        Y - BeforeThumbBarImages[sbImageNormal].ClientSize.Y div 2));
      SetBeforeThumbBarSize(Classes.Point(
        ThumbTopImages[sbImageNormal].ClientSize.X + BeforeLength,
        BeforeThumbBarImages[sbImageNormal].ClientSize.Y));
      SetAfterThumbBarPosition(Classes.Point(
        BeforeLength + ThumbLength - ThumbBottomImages[sbImageNormal].ClientSize.X + DownImages[sbImageNormal].ClientSize.X,
        Y - AfterThumbBarImages[sbImageNormal].ClientSize.Y div 2));
      SetAfterThumbBarSize(Classes.Point(
        ThumbBottomImages[sbImageNormal].ClientSize.X + AfterLength,
        AfterThumbBarImages[sbImageNormal].ClientSize.Y));
    end;
  end
  else
  begin
    X := ClientSize.X div 2;
    if UpImages[sbImageNormal].ClientSize.Y + DownImages[sbImageNormal].ClientSize.Y +
      ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y >= ClientSize.Y then
    begin
      Y := 0;
      SetUpPosition(Classes.Point(X - UpImages[sbImageNormal].ClientSize.X div 2, Y));
      Inc(Y, UpImages[sbImageNormal].ClientSize.Y);
      SetThumbTopPosition(Classes.Point(X - ThumbTopImages[sbImageNormal].ClientSize.X div 2, Y));
      SetBeforeThumbBarPosition(Classes.Point(X - BeforeThumbBarImages[sbImageNormal].ClientSize.X div 2, Y));
      SetBeforeThumbBarSize(Classes.Point(
        BeforeThumbBarImages[sbImageNormal].ClientSize.X,
        BeforeThumbBarImages[sbImageNormal].ClientSize.Y));
      Inc(Y, ThumbTopImages[sbImageNormal].ClientSize.Y);
      ThumbCenterImages[sbImageNormal].IsActive := False;
      ThumbCenterImages[sbImageActive].IsActive := False;
      ThumbCenterImages[sbImageDown].IsActive := False;
      SetThumbBottomPosition(Classes.Point(X - ThumbBottomImages[sbImageNormal].ClientSize.X div 2, Y));
      SetAfterThumbBarPosition(Classes.Point(X - AfterThumbBarImages[sbImageNormal].ClientSize.X div 2, Y));
      SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[sbImageNormal].ClientSize.X, AfterThumbBarImages[sbImageNormal].ClientSize.Y));
      Inc(Y, ThumbBottomImages[sbImageNormal].ClientSize.Y);
      SetDownPosition(Classes.Point(X - DownImages[sbImageNormal].ClientSize.X div 2, Y));
    end
    else
    begin
      TrackLength := ClientSize.Y - UpImages[sbImageNormal].ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y;
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
      if ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y >= ThumbLength then
      begin
        ThumbLength := ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y;
        MinimumThumbLength := ThumbLength;
      end;
      if CalculationMode = scmValue then
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
      if ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y >= ThumbLength then
      begin
        ThumbCenterImages[sbImageNormal].IsActive := False;
        ThumbCenterImages[sbImageActive].IsActive := False;
        ThumbCenterImages[sbImageDown].IsActive := False;
        SetThumbCenterSize(Classes.Point(ThumbCenterImages[sbImageNormal].ClientSize.X, 0));
      end
      else
      begin
        ThumbCenterImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb));
        ThumbCenterImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srThumb);
        ThumbCenterImages[sbImageDown].IsActive := PressedRegion = srThumb;
        SetThumbCenterPosition(Classes.Point(
          X - ThumbCenterImages[sbImageNormal].ClientSize.X div 2,
          UpImages[sbImageNormal].ClientSize.Y + ThumbTopImages[sbImageNormal].ClientSize.Y + BeforeLength));
        SetThumbCenterSize(Classes.Point(
          ThumbCenterImages[sbImageNormal].ClientSize.X,
          ThumbLength - (ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y)));
      end;
      SetUpPosition(Classes.Point(X - UpImages[sbImageNormal].ClientSize.X div 2, 0));
      SetDownPosition(Classes.Point(
        X - DownImages[sbImageNormal].ClientSize.X div 2,
        ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y));
      SetThumbTopPosition(Classes.Point(
        X - ThumbTopImages[sbImageNormal].ClientSize.X div 2,
        UpImages[sbImageNormal].ClientSize.Y + BeforeLength));
      SetThumbBottomPosition(Classes.Point(
        X - ThumbBottomImages[sbImageNormal].ClientSize.X div 2,
        BeforeLength + ThumbLength - ThumbBottomImages[sbImageNormal].ClientSize.Y + UpImages[sbImageNormal].ClientSize.Y));
      SetBeforeThumbBarPosition(Classes.Point(
        X - BeforeThumbBarImages[sbImageNormal].ClientSize.X div 2,
        UpImages[sbImageNormal].ClientSize.Y));
      SetBeforeThumbBarSize(Classes.Point(
        BeforeThumbBarImages[sbImageNormal].ClientSize.X,
        ThumbTopImages[sbImageNormal].ClientSize.Y + BeforeLength));
      SetAfterThumbBarPosition(Classes.Point(
        X - AfterThumbBarImages[sbImageNormal].ClientSize.X div 2,
        BeforeLength + ThumbLength - ThumbBottomImages[sbImageNormal].ClientSize.Y + DownImages[sbImageNormal].ClientSize.Y));
      SetAfterThumbBarSize(Classes.Point(
        AfterThumbBarImages[sbImageNormal].ClientSize.X,
        ThumbBottomImages[sbImageNormal].ClientSize.Y + AfterLength));
    end;
  end;
  UpImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srDecreaseArrow)) or (PressedRegion = srDecreaseArrow));
  UpImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srDecreaseArrow);
  UpImages[sbImageDown].IsActive := PressedRegion = srDecreaseArrow;
  BeforeThumbBarImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srPageBefore)) or (PressedRegion = srPageBefore));
  BeforeThumbBarImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srPageBefore);
  BeforeThumbBarImages[sbImageDown].IsActive := PressedRegion = srPageBefore;
  ThumbTopImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb));
  ThumbTopImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srThumb);
  ThumbTopImages[sbImageDown].IsActive := PressedRegion = srThumb;
  ThumbBottomImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb));
  ThumbBottomImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srThumb);
  ThumbBottomImages[sbImageDown].IsActive := PressedRegion = srThumb;
  AfterThumbBarImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srPageAfter)) or (PressedRegion = srPageAfter));
  AfterThumbBarImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srPageAfter);
  AfterThumbBarImages[sbImageDown].IsActive := PressedRegion = srPageAfter;
  DownImages[sbImageNormal].IsActive := not (((PressedRegion = srNoHit) and (HoveredRegion = srIncreaseArrow)) or (PressedRegion = srIncreaseArrow));
  DownImages[sbImageActive].IsActive := (PressedRegion = srNoHit) and (HoveredRegion = srIncreaseArrow);
  DownImages[sbImageDown].IsActive := PressedRegion = srIncreaseArrow;
end;
{ @end $4A221C }

{ @routine $4A3140 TScrollBarGI_UpdateSizeForOrientation }
procedure TScrollBarGI.UpdateSizeForOrientation;
begin
  if Orientation = soHorizontal then
    ObjectSize := Classes.Point(ClientSize.X, UpImages[sbImageNormal].ClientSize.Y)
  else
    ObjectSize := Classes.Point(UpImages[sbImageNormal].ClientSize.X, ClientSize.Y);
end;
{ @end $4A3140 }

{ @routine $4A3190 TScrollBarGI_ProcessMouseMove }
procedure TScrollBarGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessMouseMove(KeyState, Point);
  if PressedRegion = srThumb then
  begin
    if Orientation = soHorizontal then
    begin
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else if CalculationMode = scmValue then
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[sbImageNormal].ClientSize.X
          - DownImages[sbImageNormal].ClientSize.X
          - ThumbCenterImages[sbImageNormal].ClientSize.X
          - ThumbTopImages[sbImageNormal].ClientSize.X
          - ThumbBottomImages[sbImageNormal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[sbImageNormal].ClientSize.X))) + DragStartPosition)
      else
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[sbImageNormal].ClientSize.X
          - DownImages[sbImageNormal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[sbImageNormal].ClientSize.X))) + DragStartPosition);
    end
    else
    begin
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else if CalculationMode = scmValue then
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[sbImageNormal].ClientSize.Y
          - DownImages[sbImageNormal].ClientSize.Y
          - ThumbCenterImages[sbImageNormal].ClientSize.Y
          - ThumbTopImages[sbImageNormal].ClientSize.Y
          - ThumbBottomImages[sbImageNormal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[sbImageNormal].ClientSize.Y))) + DragStartPosition)
      else
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[sbImageNormal].ClientSize.Y
          - DownImages[sbImageNormal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[sbImageNormal].ClientSize.Y))) + DragStartPosition);
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
  if PressedRegion = srNoHit then HoveredRegion := srNoHit;
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
  if PressedRegion = srDecreaseArrow then
  begin
    SetPosition(Position - SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srIncreaseArrow then
  begin
    SetPosition(Position + SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srPageBefore then
  begin
    SetPosition(Position - LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srPageAfter then
  begin
    SetPosition(Position + LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srThumb then
  begin
    StopAutoRepeat;
    if Maximum - Minimum = 0 then DragStartPosition := Minimum
    else if Orientation = soHorizontal then
    begin
      if CalculationMode = scmValue then
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[sbImageNormal].ClientSize.X
          - DownImages[sbImageNormal].ClientSize.X
          - ThumbCenterImages[sbImageNormal].ClientSize.X
          - ThumbTopImages[sbImageNormal].ClientSize.X
          - ThumbBottomImages[sbImageNormal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[sbImageNormal].ClientSize.X)))
      else
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.X
          - UpImages[sbImageNormal].ClientSize.X
          - DownImages[sbImageNormal].ClientSize.X)
          * (Point.X - HitTestBounds.Left
          - UpImages[sbImageNormal].ClientSize.X)));
    end
    else
    begin
      if CalculationMode = scmValue then
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[sbImageNormal].ClientSize.Y
          - DownImages[sbImageNormal].ClientSize.Y
          - ThumbCenterImages[sbImageNormal].ClientSize.Y
          - ThumbTopImages[sbImageNormal].ClientSize.Y
          - ThumbBottomImages[sbImageNormal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[sbImageNormal].ClientSize.Y)))
      else
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.Y
          - UpImages[sbImageNormal].ClientSize.Y
          - DownImages[sbImageNormal].ClientSize.Y)
          * (Point.Y - HitTestBounds.Top
          - UpImages[sbImageNormal].ClientSize.Y)));
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
  PressedRegion := srNoHit;
  if not HitTestCursor then HoveredRegion := srNoHit;
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
  if PressedRegion = srDecreaseArrow then SetPosition(Position - SmallChange)
  else if PressedRegion = srIncreaseArrow then SetPosition(Position + SmallChange)
  else if PressedRegion = srPageBefore then SetPosition(Position - LargeChange)
  else if PressedRegion = srPageAfter then SetPosition(Position + LargeChange);
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
    if Block.GetParam('Kind') = 'x' then Orientation := soHorizontal
    else Orientation := soVertical;
  end;
  if Block.CountParams('KindCalc') > 0 then CalculationMode := StrToInt(Block.GetParam('KindCalc'));
  if Block.CountParams('ImageUpN') > 0 then UpImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageUpN');
  if Block.CountParams('ImageUpA') > 0 then UpImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageUpA');
  if Block.CountParams('ImageUpD') > 0 then UpImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageUpD');
  if Block.CountParams('ImageBarN') > 0 then BeforeThumbBarImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageBarN');
  if Block.CountParams('ImageBarA') > 0 then BeforeThumbBarImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageBarA');
  if Block.CountParams('ImageBarD') > 0 then BeforeThumbBarImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageBarD');
  if Block.CountParams('ImageTopN') > 0 then ThumbTopImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageTopN');
  if Block.CountParams('ImageTopA') > 0 then ThumbTopImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageTopA');
  if Block.CountParams('ImageTopD') > 0 then ThumbTopImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageTopD');
  if Block.CountParams('ImageCenterN') > 0 then ThumbCenterImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageCenterN');
  if Block.CountParams('ImageCenterA') > 0 then ThumbCenterImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageCenterA');
  if Block.CountParams('ImageCenterD') > 0 then ThumbCenterImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageCenterD');
  if Block.CountParams('ImageBottomN') > 0 then ThumbBottomImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageBottomN');
  if Block.CountParams('ImageBottomA') > 0 then ThumbBottomImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageBottomA');
  if Block.CountParams('ImageBottomD') > 0 then ThumbBottomImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageBottomD');
  if Block.CountParams('ImageBarN') > 0 then AfterThumbBarImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageBarN');
  if Block.CountParams('ImageBarA') > 0 then AfterThumbBarImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageBarA');
  if Block.CountParams('ImageBarD') > 0 then AfterThumbBarImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageBarD');
  if Block.CountParams('ImageDownN') > 0 then DownImages[sbImageNormal].ImageSourcePath := Block.GetParam('ImageDownN');
  if Block.CountParams('ImageDownA') > 0 then DownImages[sbImageActive].ImageSourcePath := Block.GetParam('ImageDownA');
  if Block.CountParams('ImageDownD') > 0 then DownImages[sbImageDown].ImageSourcePath := Block.GetParam('ImageDownD');
  UpImages[sbImageNormal].ObjectSize := UpImages[sbImageNormal].GetContentSize;
  UpImages[sbImageNormal].KindX := ikxCenter;
  UpImages[sbImageNormal].KindY := ikyCenter;
  UpImages[sbImageActive].ObjectSize := UpImages[sbImageActive].GetContentSize;
  UpImages[sbImageActive].KindX := ikxCenter;
  UpImages[sbImageActive].KindY := ikyCenter;
  UpImages[sbImageDown].ObjectSize := UpImages[sbImageDown].GetContentSize;
  UpImages[sbImageDown].KindX := ikxCenter;
  UpImages[sbImageDown].KindY := ikyCenter;
  BeforeThumbBarImages[sbImageNormal].ObjectSize := BeforeThumbBarImages[sbImageNormal].GetContentSize;
  BeforeThumbBarImages[sbImageNormal].KindX := ikxLeftFill;
  BeforeThumbBarImages[sbImageNormal].KindY := ikyTopFill;
  BeforeThumbBarImages[sbImageActive].ObjectSize := BeforeThumbBarImages[sbImageActive].GetContentSize;
  BeforeThumbBarImages[sbImageActive].KindX := ikxLeftFill;
  BeforeThumbBarImages[sbImageActive].KindY := ikyTopFill;
  BeforeThumbBarImages[sbImageDown].ObjectSize := BeforeThumbBarImages[sbImageDown].GetContentSize;
  BeforeThumbBarImages[sbImageDown].KindX := ikxLeftFill;
  BeforeThumbBarImages[sbImageDown].KindY := ikyTopFill;
  ThumbTopImages[sbImageNormal].ObjectSize := ThumbTopImages[sbImageNormal].GetContentSize;
  ThumbTopImages[sbImageNormal].KindX := ikxCenter;
  ThumbTopImages[sbImageNormal].KindY := ikyCenter;
  ThumbTopImages[sbImageActive].ObjectSize := ThumbTopImages[sbImageActive].GetContentSize;
  ThumbTopImages[sbImageActive].KindX := ikxCenter;
  ThumbTopImages[sbImageActive].KindY := ikyCenter;
  ThumbTopImages[sbImageDown].ObjectSize := ThumbTopImages[sbImageDown].GetContentSize;
  ThumbTopImages[sbImageDown].KindX := ikxCenter;
  ThumbTopImages[sbImageDown].KindY := ikyCenter;
  ThumbCenterImages[sbImageNormal].ObjectSize := ThumbCenterImages[sbImageNormal].GetContentSize;
  ThumbCenterImages[sbImageNormal].KindX := ikxLeftFill;
  ThumbCenterImages[sbImageNormal].KindY := ikyTopFill;
  ThumbCenterImages[sbImageActive].ObjectSize := ThumbCenterImages[sbImageActive].GetContentSize;
  ThumbCenterImages[sbImageActive].KindX := ikxLeftFill;
  ThumbCenterImages[sbImageActive].KindY := ikyTopFill;
  ThumbCenterImages[sbImageDown].ObjectSize := ThumbCenterImages[sbImageDown].GetContentSize;
  ThumbCenterImages[sbImageDown].KindX := ikxLeftFill;
  ThumbCenterImages[sbImageDown].KindY := ikyTopFill;
  ThumbBottomImages[sbImageNormal].ObjectSize := ThumbBottomImages[sbImageNormal].GetContentSize;
  ThumbBottomImages[sbImageNormal].KindX := ikxCenter;
  ThumbBottomImages[sbImageNormal].KindY := ikyCenter;
  ThumbBottomImages[sbImageActive].ObjectSize := ThumbBottomImages[sbImageActive].GetContentSize;
  ThumbBottomImages[sbImageActive].KindX := ikxCenter;
  ThumbBottomImages[sbImageActive].KindY := ikyCenter;
  ThumbBottomImages[sbImageDown].ObjectSize := ThumbBottomImages[sbImageDown].GetContentSize;
  ThumbBottomImages[sbImageDown].KindX := ikxCenter;
  ThumbBottomImages[sbImageDown].KindY := ikyCenter;
  AfterThumbBarImages[sbImageNormal].ObjectSize := AfterThumbBarImages[sbImageNormal].GetContentSize;
  AfterThumbBarImages[sbImageNormal].KindX := ikxRightFill;
  AfterThumbBarImages[sbImageNormal].KindY := ikyBottomFill;
  AfterThumbBarImages[sbImageActive].ObjectSize := AfterThumbBarImages[sbImageActive].GetContentSize;
  AfterThumbBarImages[sbImageActive].KindX := ikxRightFill;
  AfterThumbBarImages[sbImageActive].KindY := ikyBottomFill;
  AfterThumbBarImages[sbImageDown].ObjectSize := AfterThumbBarImages[sbImageDown].GetContentSize;
  AfterThumbBarImages[sbImageDown].KindX := ikxRightFill;
  AfterThumbBarImages[sbImageDown].KindY := ikyBottomFill;
  DownImages[sbImageNormal].ObjectSize := DownImages[sbImageNormal].GetContentSize;
  DownImages[sbImageNormal].KindX := ikxCenter;
  DownImages[sbImageNormal].KindY := ikyCenter;
  DownImages[sbImageActive].ObjectSize := DownImages[sbImageActive].GetContentSize;
  DownImages[sbImageActive].KindX := ikxCenter;
  DownImages[sbImageActive].KindY := ikyCenter;
  DownImages[sbImageDown].ObjectSize := DownImages[sbImageDown].GetContentSize;
  DownImages[sbImageDown].KindX := ikxCenter;
  DownImages[sbImageDown].KindY := ikyCenter;
  UpdateLayout;
end;
{ @end $4A38B0 }

end.
