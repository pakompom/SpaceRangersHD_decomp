unit GI_ScrollBar;
// Unit bracket (inferred): .text 0x0048C7D8..0x004904C4; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_Image, GI_Label, GI_MessageLoop, GI_Panel, Types;

type
  TScrollBarGI = class(TPanelGI) // @size 0x1D8
  public
    Minimum: Integer; // @offset 0x140
    Maximum: Integer; // @offset 0x144
    Position: Integer; // @offset 0x148
    LargeChange: Integer; // @offset 0x14C
    SmallChange: Integer; // @offset 0x150
    PageSize: Integer; // @offset 0x154
    Orientation: Integer; // @offset 0x158
    CalculationMode: Integer; // @offset 0x15C
    // Each image triple is normal, active, down. Up/Down also mean left/right horizontally.
    UpImages: array[0..2] of TImageGI; // @offset 0x160
    BeforeThumbBarImages: array[0..2] of TImageGI; // @offset 0x16C
    ThumbTopImages: array[0..2] of TImageGI; // @offset 0x178
    ThumbCenterImages: array[0..2] of TImageGI; // @offset 0x184
    ThumbBottomImages: array[0..2] of TImageGI; // @offset 0x190
    AfterThumbBarImages: array[0..2] of TImageGI; // @offset 0x19C
    DownImages: array[0..2] of TImageGI; // @offset 0x1A8
    RepeatTimer: PCallbackTimerGI; // @offset 0x1B4
    PressedRegion: Integer; // @offset 0x1B8
    HoveredRegion: Integer; // @offset 0x1BC
    DragStartPosition: Integer; // @offset 0x1C0
    MinimumLabel: TLabelGI; // @offset 0x1C4
    MaximumLabel: TLabelGI; // @offset 0x1C8
    PositionLabel: TLabelGI; // @offset 0x1CC
    PositionChangedCallback: TObjectNotifyEventGI; // @offset $1D0

    constructor Create(Owner: TObjectGI); // @addr 0x48C900
    destructor Destroy; override; // @addr 0x48CD4C
    procedure Clear; override; // @addr 0x48CEA4 @note "Resets the range to 0..99 and clears callbacks; does not call inherited Clear."
    function GetHitRegion(Point: TPoint): Integer; // @addr 0x48D238 @note "Returns 0 outside, 1/2 arrows, 3/4 page regions, or 5 thumb; only tests the scrolling axis."
    procedure SetRange(MinValue, MaxValue: Integer); // @addr 0x48D3EC
    procedure SetPositionInternal(NewPosition: Integer); // @addr 0x48D590 @note "Does not invoke PositionChangedCallback."
    procedure SetPosition(NewPosition: Integer); reintroduce; // @addr 0x48D764 @note "Notifies only while Active and only when the clamped position changes."
    procedure SetSmallChange(Value: Integer); // @addr 0x48D958
    procedure SetLargeChange(Value: Integer); // @addr 0x48D9A0 @note "A value equal to SmallChange is ignored even if LargeChange differs."
    procedure SetPageSize(Value: Integer); // @addr 0x48D9E8 @note "Caps at Maximum-Minimum+1; no lower bound check."
    procedure SetOrientation(Value: Integer); // @addr 0x48DA68 @note "Value 1 is horizontal; other values use vertical layout."
    procedure SetKindCalcMode(Value: Integer); // @addr 0x48DAB0
    procedure SetConfigPath(const Path: WideString); override; // @addr 0x48DAF8
    procedure SetSize(Size: TPoint); override; // @addr 0x48DB30
    procedure UpdateLayout; // @addr 0x48DB90
    procedure UpdateSizeForOrientation; // @addr 0x48EDD4 @note "Uses the up-arrow image for scrollbar thickness."
    procedure StartAutoRepeat(DelayMs, RepeatMs: Integer); // @addr 0x48F65C
    procedure StopAutoRepeat; // @addr 0x48F69C
    procedure AutoRepeat(Timer: PCallbackTimerGI; UserData: Integer); // @addr 0x48F6D4
    procedure SetUpPosition(Point: TPoint); // @addr $48CF40
    procedure SetBeforeThumbBarPosition(Point: TPoint); // @addr $48CF8C
    procedure SetThumbTopPosition(Point: TPoint); // @addr $48CFD8
    procedure SetThumbCenterPosition(Point: TPoint); // @addr $48D024
    procedure SetThumbBottomPosition(Point: TPoint); // @addr $48D070
    procedure SetAfterThumbBarPosition(Point: TPoint); // @addr $48D0BC
    procedure SetDownPosition(Point: TPoint); // @addr $48D108
    procedure SetBeforeThumbBarSize(Size: TPoint); // @addr $48D154
    procedure SetThumbCenterSize(Size: TPoint); // @addr $48D1A0
    procedure SetAfterThumbBarSize(Size: TPoint); // @addr $48D1EC
    procedure SetActive(Enabled: Boolean); override; // @addr $48DB64
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $48EE3C
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $48F1B0
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $48F5C8
    procedure ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint); override; // @addr $48F640
    procedure OnMouseEnter; override; // @addr $48F154
    procedure OnMouseLeave; override; // @addr $48F168
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x48F788
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x48F7BC
    procedure LoadScrollBarProperties(Block: TBlockParEC); // @addr 0x48F7E4
  end;

implementation

uses Classes, GI_Main, GR_Main, SysUtils;

{ @routine $48C900 TScrollBarGI_Create }
constructor TScrollBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  RepeatTimer := nil;
  UpImages[0] := TImageGI.Create(Self);
  UpImages[0].SetDepth(1);
  UpImages[1] := TImageGI.Create(Self);
  UpImages[1].SetDepth(1);
  UpImages[2] := TImageGI.Create(Self);
  UpImages[2].SetDepth(1);
  BeforeThumbBarImages[0] := TImageGI.Create(Self);
  BeforeThumbBarImages[0].SetDepth(1);
  BeforeThumbBarImages[1] := TImageGI.Create(Self);
  BeforeThumbBarImages[1].SetDepth(1);
  BeforeThumbBarImages[2] := TImageGI.Create(Self);
  BeforeThumbBarImages[2].SetDepth(1);
  ThumbTopImages[0] := TImageGI.Create(Self);
  ThumbTopImages[0].SetDepth(0);
  ThumbTopImages[1] := TImageGI.Create(Self);
  ThumbTopImages[1].SetDepth(0);
  ThumbTopImages[2] := TImageGI.Create(Self);
  ThumbTopImages[2].SetDepth(0);
  ThumbCenterImages[0] := TImageGI.Create(Self);
  ThumbCenterImages[0].SetDepth(0);
  ThumbCenterImages[1] := TImageGI.Create(Self);
  ThumbCenterImages[1].SetDepth(0);
  ThumbCenterImages[2] := TImageGI.Create(Self);
  ThumbCenterImages[2].SetDepth(0);
  ThumbBottomImages[0] := TImageGI.Create(Self);
  ThumbBottomImages[0].SetDepth(0);
  ThumbBottomImages[1] := TImageGI.Create(Self);
  ThumbBottomImages[1].SetDepth(0);
  ThumbBottomImages[2] := TImageGI.Create(Self);
  ThumbBottomImages[2].SetDepth(0);
  AfterThumbBarImages[0] := TImageGI.Create(Self);
  AfterThumbBarImages[0].SetDepth(1);
  AfterThumbBarImages[1] := TImageGI.Create(Self);
  AfterThumbBarImages[1].SetDepth(1);
  AfterThumbBarImages[2] := TImageGI.Create(Self);
  AfterThumbBarImages[2].SetDepth(1);
  DownImages[0] := TImageGI.Create(Self);
  DownImages[0].SetDepth(1);
  DownImages[1] := TImageGI.Create(Self);
  DownImages[1].SetDepth(1);
  DownImages[2] := TImageGI.Create(Self);
  DownImages[2].SetDepth(1);
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := 2;
  CalculationMode := 0;
end;
{ @end $48C900 }

{ @routine $48CD4C TScrollBarGI_Destroy }
destructor TScrollBarGI.Destroy;
begin
  UpImages[0].Free;
  UpImages[1].Free;
  UpImages[2].Free;
  BeforeThumbBarImages[0].Free;
  BeforeThumbBarImages[1].Free;
  BeforeThumbBarImages[2].Free;
  ThumbTopImages[0].Free;
  ThumbTopImages[1].Free;
  ThumbTopImages[2].Free;
  ThumbCenterImages[0].Free;
  ThumbCenterImages[1].Free;
  ThumbCenterImages[2].Free;
  ThumbBottomImages[0].Free;
  ThumbBottomImages[1].Free;
  ThumbBottomImages[2].Free;
  AfterThumbBarImages[0].Free;
  AfterThumbBarImages[1].Free;
  AfterThumbBarImages[2].Free;
  DownImages[0].Free;
  DownImages[1].Free;
  DownImages[2].Free;
  inherited Destroy;
end;
{ @end $48CD4C }

{ @routine $48CEA4 TScrollBarGI_Clear }
procedure TScrollBarGI.Clear;
begin
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := 2;
  CalculationMode := 0;
  PressedRegion := 0;
  HoveredRegion := 0;
  StopAutoRepeat;
  PositionChangedCallback := nil;
end;
{ @end $48CEA4 }

{ @routine $48CF40 TScrollBarGI_SetUpPosition }
procedure TScrollBarGI.SetUpPosition(Point: TPoint);
begin
  UpImages[0].SetPosition(Point);
  UpImages[1].SetPosition(Point);
  UpImages[2].SetPosition(Point);
end;
{ @end $48CF40 }

{ @routine $48CF8C TScrollBarGI_SetBeforeThumbBarPosition }
procedure TScrollBarGI.SetBeforeThumbBarPosition(Point: TPoint);
begin
  BeforeThumbBarImages[0].SetPosition(Point);
  BeforeThumbBarImages[1].SetPosition(Point);
  BeforeThumbBarImages[2].SetPosition(Point);
end;
{ @end $48CF8C }

{ @routine $48CFD8 TScrollBarGI_SetThumbTopPosition }
procedure TScrollBarGI.SetThumbTopPosition(Point: TPoint);
begin
  ThumbTopImages[0].SetPosition(Point);
  ThumbTopImages[1].SetPosition(Point);
  ThumbTopImages[2].SetPosition(Point);
end;
{ @end $48CFD8 }

{ @routine $48D024 TScrollBarGI_SetThumbCenterPosition }
procedure TScrollBarGI.SetThumbCenterPosition(Point: TPoint);
begin
  ThumbCenterImages[0].SetPosition(Point);
  ThumbCenterImages[1].SetPosition(Point);
  ThumbCenterImages[2].SetPosition(Point);
end;
{ @end $48D024 }

{ @routine $48D070 TScrollBarGI_SetThumbBottomPosition }
procedure TScrollBarGI.SetThumbBottomPosition(Point: TPoint);
begin
  ThumbBottomImages[0].SetPosition(Point);
  ThumbBottomImages[1].SetPosition(Point);
  ThumbBottomImages[2].SetPosition(Point);
end;
{ @end $48D070 }

{ @routine $48D0BC TScrollBarGI_SetAfterThumbBarPosition }
procedure TScrollBarGI.SetAfterThumbBarPosition(Point: TPoint);
begin
  AfterThumbBarImages[0].SetPosition(Point);
  AfterThumbBarImages[1].SetPosition(Point);
  AfterThumbBarImages[2].SetPosition(Point);
end;
{ @end $48D0BC }

{ @routine $48D108 TScrollBarGI_SetDownPosition }
procedure TScrollBarGI.SetDownPosition(Point: TPoint);
begin
  DownImages[0].SetPosition(Point);
  DownImages[1].SetPosition(Point);
  DownImages[2].SetPosition(Point);
end;
{ @end $48D108 }

{ @routine $48D154 TScrollBarGI_SetBeforeThumbBarSize }
procedure TScrollBarGI.SetBeforeThumbBarSize(Size: TPoint);
begin
  BeforeThumbBarImages[0].SetSize(Size);
  BeforeThumbBarImages[1].SetSize(Size);
  BeforeThumbBarImages[2].SetSize(Size);
end;
{ @end $48D154 }

{ @routine $48D1A0 TScrollBarGI_SetThumbCenterSize }
procedure TScrollBarGI.SetThumbCenterSize(Size: TPoint);
begin
  ThumbCenterImages[0].SetSize(Size);
  ThumbCenterImages[1].SetSize(Size);
  ThumbCenterImages[2].SetSize(Size);
end;
{ @end $48D1A0 }

{ @routine $48D1EC TScrollBarGI_SetAfterThumbBarSize }
procedure TScrollBarGI.SetAfterThumbBarSize(Size: TPoint);
begin
  AfterThumbBarImages[0].SetSize(Size);
  AfterThumbBarImages[1].SetSize(Size);
  AfterThumbBarImages[2].SetSize(Size);
end;
{ @end $48D1EC }

{ @routine $48D238 TScrollBarGI_GetHitRegion }
function TScrollBarGI.GetHitRegion(Point: TPoint): Integer;
var
  UpEnd, ThumbStart, ThumbEnd, DownStart: Integer;
begin
  if Orientation = 1 then
  begin
    UpEnd := UpImages[0].ClientSize.X;
    ThumbStart := ThumbTopImages[0].LocalPosition.X;
    ThumbEnd := ThumbBottomImages[0].LocalPosition.X + ThumbBottomImages[0].ClientSize.X;
    DownStart := ClientSize.X - DownImages[0].ClientSize.X;
    if Point.X < 0 then Result := 0
    else if Point.X <= UpEnd then Result := 1
    else if Point.X <= ThumbStart then Result := 3
    else if Point.X <= ThumbEnd then Result := 5
    else if Point.X <= DownStart then Result := 4
    else if Point.X <= ClientSize.X then Result := 2
    else Result := 0;
  end
  else
  begin
    UpEnd := UpImages[0].ClientSize.Y;
    ThumbStart := ThumbTopImages[0].LocalPosition.Y;
    ThumbEnd := ThumbBottomImages[0].LocalPosition.Y + ThumbBottomImages[0].ClientSize.Y;
    DownStart := ClientSize.Y - DownImages[0].ClientSize.Y;
    if Point.Y < 0 then Result := 0
    else if Point.Y <= UpEnd then Result := 1
    else if Point.Y <= ThumbStart then Result := 3
    else if Point.Y <= ThumbEnd then Result := 5
    else if Point.Y <= DownStart then Result := 4
    else if Point.Y <= ClientSize.Y then Result := 2
    else Result := 0;
  end;
end;
{ @end $48D238 }

{ @routine $48D3EC TScrollBarGI_SetRange }
procedure TScrollBarGI.SetRange(MinValue, MaxValue: Integer);
begin
  if MinimumLabel <> nil then MinimumLabel.SetText(IntToStr(MinValue));
  if MaximumLabel <> nil then MaximumLabel.SetText(IntToStr(MaxValue));
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
{ @end $48D3EC }

{ @routine $48D590 TScrollBarGI_SetPositionInternal }
procedure TScrollBarGI.SetPositionInternal(NewPosition: Integer);
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  if PositionLabel <> nil then PositionLabel.SetText(IntToStr(NewPosition));
  if Position <> NewPosition then
  begin
    Position := NewPosition;
    if Position < Minimum then Position := Minimum;
    if CalculationMode = 0 then
    begin
      if Position > Maximum then Position := Maximum;
    end
    else
    begin
      if Maximum - PageSize + 1 < Position then Position := Maximum - PageSize + 1;
      if Position < Minimum then Position := Minimum;
    end;
    if PositionLabel <> nil then PositionLabel.SetText(IntToStr(Position));
    if OldPosition <> Position then
      if Active = True then
      begin
        UpdateLayout;
        Invalidate;
      end;
  end;
end;
{ @end $48D590 }

{ @routine $48D764 TScrollBarGI_SetPosition }
procedure TScrollBarGI.SetPosition(NewPosition: Integer);
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  if PositionLabel <> nil then PositionLabel.SetText(IntToStr(NewPosition));
  if Position <> NewPosition then
  begin
    Position := NewPosition;
    if Position < Minimum then Position := Minimum;
    if CalculationMode = 0 then
    begin
      if Position > Maximum then Position := Maximum;
    end
    else
    begin
      if Maximum - PageSize + 1 < Position then Position := Maximum - PageSize + 1;
      if Position < Minimum then Position := Minimum;
    end;
    if PositionLabel <> nil then PositionLabel.SetText(IntToStr(Position));
    if OldPosition <> Position then
      if Active = True then
      begin
        UpdateLayout;
        Invalidate;
        if Assigned(PositionChangedCallback) then PositionChangedCallback(Self);
      end;
  end;
end;
{ @end $48D764 }

{ @routine $48D958 TScrollBarGI_SetSmallChange }
procedure TScrollBarGI.SetSmallChange(Value: Integer);
begin
  if SmallChange <> Value then
  begin
    SmallChange := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $48D958 }

{ @routine $48D9A0 TScrollBarGI_SetLargeChange }
procedure TScrollBarGI.SetLargeChange(Value: Integer);
begin
  if SmallChange <> Value then
  begin
    LargeChange := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $48D9A0 }

{ @routine $48D9E8 TScrollBarGI_SetPageSize }
procedure TScrollBarGI.SetPageSize(Value: Integer);
begin
  if PageSize <> Value then
  begin
    PageSize := Value;
    if PageSize > Maximum - Minimum + 1 then PageSize := Maximum - Minimum + 1;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $48D9E8 }

{ @routine $48DA68 TScrollBarGI_SetOrientation }
procedure TScrollBarGI.SetOrientation(Value: Integer);
begin
  if Orientation <> Value then
  begin
    Orientation := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $48DA68 }

{ @routine $48DAB0 TScrollBarGI_SetKindCalcMode }
procedure TScrollBarGI.SetKindCalcMode(Value: Integer);
begin
  if CalculationMode <> Value then
  begin
    CalculationMode := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;
{ @end $48DAB0 }

{ @routine $48DAF8 TScrollBarGI_SetConfigPath }
procedure TScrollBarGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $48DAF8 }

{ @routine $48DB30 TScrollBarGI_SetSize }
procedure TScrollBarGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if Active = True then UpdateLayout;
end;
{ @end $48DB30 }

{ @routine $48DB64 TScrollBarGI_SetActive }
procedure TScrollBarGI.SetActive(Enabled: Boolean);
begin
  inherited SetActive(Enabled);
  if Enabled = True then UpdateLayout;
end;
{ @end $48DB64 }

{ @routine $48DB90 TScrollBarGI_UpdateLayout }
procedure TScrollBarGI.UpdateLayout;
var
  X, Y, TrackLength, BeforeLength, ThumbLength, AfterLength, MinimumThumbLength: Integer;
begin
  if Active then
  begin
    if (Orientation = 1) then
    begin
      Y := (ClientSize.Y div 2);
      if ((((UpImages[0].ClientSize.X + DownImages[0].ClientSize.X) + ThumbTopImages[0].ClientSize.X) + ThumbBottomImages[0].ClientSize.X) >= ClientSize.X) then
      begin
        X := 0;
        SetUpPosition(Classes.Point(X, (Y - (UpImages[0].ClientSize.Y div 2))));
        Inc(X, UpImages[0].ClientSize.X);
        SetThumbTopPosition(Classes.Point(X, (Y - (ThumbTopImages[0].ClientSize.Y div 2))));
        SetBeforeThumbBarPosition(Classes.Point(X, (Y - (BeforeThumbBarImages[0].ClientSize.Y div 2))));
        SetBeforeThumbBarSize(Classes.Point(BeforeThumbBarImages[0].ClientSize.X, BeforeThumbBarImages[0].ClientSize.Y));
        Inc(X, ThumbTopImages[0].ClientSize.X);
        ThumbCenterImages[0].SetActive(False);
        ThumbCenterImages[1].SetActive(False);
        ThumbCenterImages[2].SetActive(False);
        SetThumbBottomPosition(Classes.Point(X, (Y - (ThumbBottomImages[0].ClientSize.Y div 2))));
        SetAfterThumbBarPosition(Classes.Point(X, (Y - (AfterThumbBarImages[0].ClientSize.Y div 2))));
        SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[0].ClientSize.X, AfterThumbBarImages[0].ClientSize.Y));
        Inc(X, ThumbBottomImages[0].ClientSize.X);
        SetDownPosition(Classes.Point(X, (Y - (DownImages[0].ClientSize.Y div 2))));
      end
      else
      begin
        TrackLength := ((ClientSize.X - UpImages[0].ClientSize.X) - DownImages[0].ClientSize.X);
        if ((Maximum - Minimum + 1) = 0) then
        begin
          ThumbLength := TrackLength;
        end
        else
        begin
          ThumbLength := Integer(Trunc(((PageSize / ((Maximum - Minimum) + 1)) * TrackLength)));
          if (ThumbLength > TrackLength) then
          begin
            ThumbLength := TrackLength;
          end;
        end;
        MinimumThumbLength := 0;
        if ((ThumbTopImages[0].ClientSize.X + ThumbBottomImages[0].ClientSize.X) >= ThumbLength) then
        begin
          ThumbLength := (ThumbTopImages[0].ClientSize.X + ThumbBottomImages[0].ClientSize.X);
          MinimumThumbLength := ThumbLength;
        end;
        if CalculationMode = 0 then
        begin
          if MinimumThumbLength = 0 then
          begin
            if Maximum - Minimum + 1 = 0 then BeforeLength := 0
            else BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          end
          else
          begin
            if Maximum - Minimum = 0 then BeforeLength := 0
            else BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum) * (TrackLength - MinimumThumbLength)));
          end;
        end
        else
        begin
          if Maximum - Minimum + 1 = 0 then BeforeLength := 0
          else BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          if BeforeLength + ThumbLength > TrackLength then BeforeLength := TrackLength - ThumbLength;
        end;
        AfterLength := ((TrackLength - BeforeLength) - ThumbLength);
        if ((ThumbTopImages[0].ClientSize.X + ThumbBottomImages[0].ClientSize.X) >= ThumbLength) then
        begin
          ThumbCenterImages[0].SetActive(False);
          ThumbCenterImages[1].SetActive(False);
          ThumbCenterImages[2].SetActive(False);
          SetThumbCenterSize(Classes.Point(0, ThumbCenterImages[0].ClientSize.Y));
        end
        else
        begin
          ThumbCenterImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 5)) or (PressedRegion = 5)));
          ThumbCenterImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 5));
          ThumbCenterImages[2].SetActive(PressedRegion = 5);
          SetThumbCenterPosition(Classes.Point(((UpImages[0].ClientSize.X + ThumbTopImages[0].ClientSize.X) + BeforeLength), (Y - (ThumbCenterImages[0].ClientSize.Y div 2))));
          SetThumbCenterSize(Classes.Point((ThumbLength - (ThumbTopImages[0].ClientSize.X + ThumbBottomImages[0].ClientSize.X)), ThumbCenterImages[0].ClientSize.Y));
        end;
        SetUpPosition(Classes.Point(0, (Y - (UpImages[0].ClientSize.Y div 2))));
        SetDownPosition(Classes.Point((ClientSize.X - DownImages[0].ClientSize.X), (Y - (DownImages[0].ClientSize.Y div 2))));
        SetThumbTopPosition(Classes.Point((UpImages[0].ClientSize.X + BeforeLength), (Y - (ThumbTopImages[0].ClientSize.Y div 2))));
        SetThumbBottomPosition(Classes.Point((((BeforeLength + ThumbLength) - ThumbBottomImages[0].ClientSize.X) + UpImages[0].ClientSize.X), (Y - (ThumbBottomImages[0].ClientSize.Y div 2))));
        SetBeforeThumbBarPosition(Classes.Point(UpImages[0].ClientSize.X, (Y - (BeforeThumbBarImages[0].ClientSize.Y div 2))));
        SetBeforeThumbBarSize(Classes.Point((ThumbTopImages[0].ClientSize.X + BeforeLength), BeforeThumbBarImages[0].ClientSize.Y));
        SetAfterThumbBarPosition(Classes.Point((((BeforeLength + ThumbLength) - ThumbBottomImages[0].ClientSize.X) + DownImages[0].ClientSize.X), (Y - (AfterThumbBarImages[0].ClientSize.Y div 2))));
        SetAfterThumbBarSize(Classes.Point((ThumbBottomImages[0].ClientSize.X + AfterLength), AfterThumbBarImages[0].ClientSize.Y));
      end;
    end
    else
    begin
      X := (ClientSize.X div 2);
      if ((((UpImages[0].ClientSize.Y + DownImages[0].ClientSize.Y) + ThumbTopImages[0].ClientSize.Y) + ThumbBottomImages[0].ClientSize.Y) >= ClientSize.Y) then
      begin
        Y := 0;
        SetUpPosition(Classes.Point((X - (UpImages[0].ClientSize.X div 2)), Y));
        Inc(Y, UpImages[0].ClientSize.Y);
        SetThumbTopPosition(Classes.Point((X - (ThumbTopImages[0].ClientSize.X div 2)), Y));
        SetBeforeThumbBarPosition(Classes.Point((X - (BeforeThumbBarImages[0].ClientSize.X div 2)), Y));
        SetBeforeThumbBarSize(Classes.Point(BeforeThumbBarImages[0].ClientSize.X, BeforeThumbBarImages[0].ClientSize.Y));
        Inc(Y, ThumbTopImages[0].ClientSize.Y);
        ThumbCenterImages[0].SetActive(False);
        ThumbCenterImages[1].SetActive(False);
        ThumbCenterImages[2].SetActive(False);
        SetThumbBottomPosition(Classes.Point((X - (ThumbBottomImages[0].ClientSize.X div 2)), Y));
        SetAfterThumbBarPosition(Classes.Point((X - (AfterThumbBarImages[0].ClientSize.X div 2)), Y));
        SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[0].ClientSize.X, AfterThumbBarImages[0].ClientSize.Y));
        Inc(Y, ThumbBottomImages[0].ClientSize.Y);
        SetDownPosition(Classes.Point((X - (DownImages[0].ClientSize.X div 2)), Y));
      end
      else
      begin
        TrackLength := ((ClientSize.Y - UpImages[0].ClientSize.Y) - DownImages[0].ClientSize.Y);
        if ((Maximum - Minimum + 1) = 0) then
        begin
          ThumbLength := TrackLength;
        end
        else
        begin
          ThumbLength := Integer(Trunc(((PageSize / ((Maximum - Minimum) + 1)) * TrackLength)));
          if (ThumbLength > TrackLength) then
          begin
            ThumbLength := TrackLength;
          end;
        end;
        MinimumThumbLength := 0;
        if ((ThumbTopImages[0].ClientSize.Y + ThumbBottomImages[0].ClientSize.Y) >= ThumbLength) then
        begin
          ThumbLength := (ThumbTopImages[0].ClientSize.Y + ThumbBottomImages[0].ClientSize.Y);
          MinimumThumbLength := ThumbLength;
        end;
        if CalculationMode = 0 then
        begin
          if MinimumThumbLength = 0 then
          begin
            if Maximum - Minimum + 1 = 0 then BeforeLength := 0
            else BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          end
          else
          begin
            if Maximum - Minimum = 0 then BeforeLength := 0
            else BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum) * (TrackLength - MinimumThumbLength)));
          end;
        end
        else
        begin
          if Maximum - Minimum + 1 = 0 then BeforeLength := 0
          else BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          if BeforeLength + ThumbLength > TrackLength then BeforeLength := TrackLength - ThumbLength;
        end;
        AfterLength := ((TrackLength - BeforeLength) - ThumbLength);
        if ((ThumbTopImages[0].ClientSize.Y + ThumbBottomImages[0].ClientSize.Y) >= ThumbLength) then
        begin
          ThumbCenterImages[0].SetActive(False);
          ThumbCenterImages[1].SetActive(False);
          ThumbCenterImages[2].SetActive(False);
          SetThumbCenterSize(Classes.Point(ThumbCenterImages[0].ClientSize.X, 0));
        end
        else
        begin
          ThumbCenterImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 5)) or (PressedRegion = 5)));
          ThumbCenterImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 5));
          ThumbCenterImages[2].SetActive(PressedRegion = 5);
          SetThumbCenterPosition(Classes.Point((X - (ThumbCenterImages[0].ClientSize.X div 2)), ((UpImages[0].ClientSize.Y + ThumbTopImages[0].ClientSize.Y) + BeforeLength)));
          SetThumbCenterSize(Classes.Point(ThumbCenterImages[0].ClientSize.X, (ThumbLength - (ThumbTopImages[0].ClientSize.Y + ThumbBottomImages[0].ClientSize.Y))));
        end;
        SetUpPosition(Classes.Point((X - (UpImages[0].ClientSize.X div 2)), 0));
        SetDownPosition(Classes.Point((X - (DownImages[0].ClientSize.X div 2)), (ClientSize.Y - DownImages[0].ClientSize.Y)));
        SetThumbTopPosition(Classes.Point((X - (ThumbTopImages[0].ClientSize.X div 2)), (UpImages[0].ClientSize.Y + BeforeLength)));
        SetThumbBottomPosition(Classes.Point((X - (ThumbBottomImages[0].ClientSize.X div 2)), (((BeforeLength + ThumbLength) - ThumbBottomImages[0].ClientSize.Y) + UpImages[0].ClientSize.Y)));
        SetBeforeThumbBarPosition(Classes.Point((X - (BeforeThumbBarImages[0].ClientSize.X div 2)), UpImages[0].ClientSize.Y));
        SetBeforeThumbBarSize(Classes.Point(BeforeThumbBarImages[0].ClientSize.X, (ThumbTopImages[0].ClientSize.Y + BeforeLength)));
        SetAfterThumbBarPosition(Classes.Point((X - (AfterThumbBarImages[0].ClientSize.X div 2)), (((BeforeLength + ThumbLength) - ThumbBottomImages[0].ClientSize.Y) + DownImages[0].ClientSize.Y)));
        SetAfterThumbBarSize(Classes.Point(AfterThumbBarImages[0].ClientSize.X, (ThumbBottomImages[0].ClientSize.Y + AfterLength)));
      end;
    end;
    UpImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 1)) or (PressedRegion = 1)));
    UpImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 1));
    UpImages[2].SetActive(PressedRegion = 1);
    BeforeThumbBarImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 3)) or (PressedRegion = 3)));
    BeforeThumbBarImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 3));
    BeforeThumbBarImages[2].SetActive(PressedRegion = 3);
    ThumbTopImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 5)) or (PressedRegion = 5)));
    ThumbTopImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 5));
    ThumbTopImages[2].SetActive(PressedRegion = 5);
    ThumbBottomImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 5)) or (PressedRegion = 5)));
    ThumbBottomImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 5));
    ThumbBottomImages[2].SetActive(PressedRegion = 5);
    AfterThumbBarImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 4)) or (PressedRegion = 4)));
    AfterThumbBarImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 4));
    AfterThumbBarImages[2].SetActive(PressedRegion = 4);
    DownImages[0].SetActive(not (((PressedRegion = 0) and (HoveredRegion = 2)) or (PressedRegion = 2)));
    DownImages[1].SetActive((PressedRegion = 0) and (HoveredRegion = 2));
    DownImages[2].SetActive(PressedRegion = 2);
  end;
end;
{ @end $48DB90 }

{ @routine $48EDD4 TScrollBarGI_UpdateSizeForOrientation }
procedure TScrollBarGI.UpdateSizeForOrientation;
begin
  if Orientation = 1 then
    SetSize(Classes.Point(ClientSize.X, UpImages[0].ClientSize.Y))
  else
    SetSize(Classes.Point(UpImages[0].ClientSize.X, ClientSize.Y));
end;
{ @end $48EDD4 }

{ @routine $48EE3C TScrollBarGI_ProcessMouseMove }
procedure TScrollBarGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessMouseMove(KeyState, Point);
  if PressedRegion = 5 then
  begin
    if Orientation = 1 then
    begin
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else if CalculationMode = 0 then
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.X - UpImages[0].ClientSize.X - DownImages[0].ClientSize.X - ThumbCenterImages[0].ClientSize.X - ThumbTopImages[0].ClientSize.X - ThumbBottomImages[0].ClientSize.X) * (Point.X - HitTestBounds.Left - UpImages[0].ClientSize.X))) + DragStartPosition)
      else
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.X - UpImages[0].ClientSize.X - DownImages[0].ClientSize.X) * (Point.X - HitTestBounds.Left - UpImages[0].ClientSize.X))) + DragStartPosition);
    end
    else
    begin
      if Maximum - Minimum = 0 then SetPosition(Minimum)
      else if CalculationMode = 0 then
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.Y - UpImages[0].ClientSize.Y - DownImages[0].ClientSize.Y - ThumbCenterImages[0].ClientSize.Y - ThumbTopImages[0].ClientSize.Y - ThumbBottomImages[0].ClientSize.Y) * (Point.Y - HitTestBounds.Top - UpImages[0].ClientSize.Y))) + DragStartPosition)
      else
        SetPosition(Integer(Trunc((Maximum - Minimum) / (ClientSize.Y - UpImages[0].ClientSize.Y - DownImages[0].ClientSize.Y) * (Point.Y - HitTestBounds.Top - UpImages[0].ClientSize.Y))) + DragStartPosition);
    end;
  end;
  HoveredRegion := GetHitRegion(ToLocalPoint(Point));
  UpdateLayout;
  Invalidate;
end;
{ @end $48EE3C }

{ @routine $48F154 TScrollBarGI_OnMouseEnter }
procedure TScrollBarGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $48F154 }

{ @routine $48F168 TScrollBarGI_OnMouseLeave }
procedure TScrollBarGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if PressedRegion = 0 then HoveredRegion := 0;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;
{ @end $48F168 }

{ @routine $48F1B0 TScrollBarGI_ProcessLeftButtonDown }
procedure TScrollBarGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Active then MessageLoop.SetFocusedControl(Self);
  HoveredRegion := GetHitRegion(ToLocalPoint(Point));
  PressedRegion := HoveredRegion;
  if PressedRegion = 1 then
  begin
    SetPosition(Position - SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = 2 then
  begin
    SetPosition(Position + SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = 3 then
  begin
    SetPosition(Position - LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = 4 then
  begin
    SetPosition(Position + LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = 5 then
  begin
    StopAutoRepeat;
    if Maximum - Minimum = 0 then DragStartPosition := Minimum
    else if Orientation = 1 then
    begin
      if CalculationMode = 0 then
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.X - UpImages[0].ClientSize.X - DownImages[0].ClientSize.X - ThumbCenterImages[0].ClientSize.X - ThumbTopImages[0].ClientSize.X - ThumbBottomImages[0].ClientSize.X) * (Point.X - HitTestBounds.Left - UpImages[0].ClientSize.X)))
      else
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.X - UpImages[0].ClientSize.X - DownImages[0].ClientSize.X) * (Point.X - HitTestBounds.Left - UpImages[0].ClientSize.X)));
    end
    else
    begin
      if CalculationMode = 0 then
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.Y - UpImages[0].ClientSize.Y - DownImages[0].ClientSize.Y - ThumbCenterImages[0].ClientSize.Y - ThumbTopImages[0].ClientSize.Y - ThumbBottomImages[0].ClientSize.Y) * (Point.Y - HitTestBounds.Top - UpImages[0].ClientSize.Y)))
      else
        DragStartPosition := Position - Integer(Trunc((Maximum - Minimum) / (ClientSize.Y - UpImages[0].ClientSize.Y - DownImages[0].ClientSize.Y) * (Point.Y - HitTestBounds.Top - UpImages[0].ClientSize.Y)));
    end;
  end;
  UpdateLayout;
  Invalidate;
end;
{ @end $48F1B0 }

{ @routine $48F5C8 TScrollBarGI_ProcessLeftButtonUp }
procedure TScrollBarGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  PressedRegion := 0;
  if not HitTestCursor then HoveredRegion := 0;
  if MessageLoop.FocusedControl = Self then MessageLoop.SetFocusedControl(nil);
  UpdateLayout;
  StopAutoRepeat;
end;
{ @end $48F5C8 }

{ @routine $48F640 TScrollBarGI_ProcessLeftButtonDoubleClick }
procedure TScrollBarGI.ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint);
begin

end;
{ @end $48F640 }

{ @routine $48F65C TScrollBarGI_StartAutoRepeat }
procedure TScrollBarGI.StartAutoRepeat(DelayMs, RepeatMs: Integer);
begin
  StopAutoRepeat;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(DelayMs, RepeatMs, AutoRepeat);
end;
{ @end $48F65C }

{ @routine $48F69C TScrollBarGI_StopAutoRepeat }
procedure TScrollBarGI.StopAutoRepeat;
begin
  if RepeatTimer <> nil then MessageLoop.CancelCallbackTimer(RepeatTimer);
  RepeatTimer := nil;
end;
{ @end $48F69C }

{ @routine $48F6D4 TScrollBarGI_AutoRepeat }
procedure TScrollBarGI.AutoRepeat(Timer: PCallbackTimerGI; UserData: Integer);
begin
  if PressedRegion = 1 then SetPosition(Position - SmallChange)
  else if PressedRegion = 2 then SetPosition(Position + SmallChange)
  else if PressedRegion = 3 then SetPosition(Position - LargeChange)
  else if PressedRegion = 4 then SetPosition(Position + LargeChange);
end;
{ @end $48F6D4 }

{ @routine $48F788 TScrollBarGI_LoadFromConfigPath }
procedure TScrollBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadScrollBarProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48F788 }

{ @routine $48F7BC TScrollBarGI_LoadFromBlock }
procedure TScrollBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadScrollBarProperties(Block);
end;
{ @end $48F7BC }

{ @routine $48F7E4 TScrollBarGI_LoadScrollBarProperties }
procedure TScrollBarGI.LoadScrollBarProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Min') > 0 then Minimum := StrToInt(Block.GetParam('Min'));
  if Block.CountParams('Max') > 0 then Maximum := StrToInt(Block.GetParam('Max'));
  if Block.CountParams('PageSize') > 0 then PageSize := StrToInt(Block.GetParam('PageSize'));
  if Block.CountParams('LargeChange') > 0 then LargeChange := StrToInt(Block.GetParam('LargeChange'));
  if Block.CountParams('SmallChange') > 0 then SmallChange := StrToInt(Block.GetParam('SmallChange'));
  if Block.CountParams('Position') > 0 then Position := StrToInt(Block.GetParam('Position'));
  if Block.CountParams('Kind') > 0 then
    if Block.GetParam('Kind') = 'x' then Orientation := 1 else Orientation := 2;
  if Block.CountParams('KindCalc') > 0 then CalculationMode := StrToInt(Block.GetParam('KindCalc'));
  if Block.CountParams('ImageUpN') > 0 then UpImages[0].SetImagePath(Block.GetParam('ImageUpN'));
  if Block.CountParams('ImageUpA') > 0 then UpImages[1].SetImagePath(Block.GetParam('ImageUpA'));
  if Block.CountParams('ImageUpD') > 0 then UpImages[2].SetImagePath(Block.GetParam('ImageUpD'));
  if Block.CountParams('ImageBarN') > 0 then BeforeThumbBarImages[0].SetImagePath(Block.GetParam('ImageBarN'));
  if Block.CountParams('ImageBarA') > 0 then BeforeThumbBarImages[1].SetImagePath(Block.GetParam('ImageBarA'));
  if Block.CountParams('ImageBarD') > 0 then BeforeThumbBarImages[2].SetImagePath(Block.GetParam('ImageBarD'));
  if Block.CountParams('ImageTopN') > 0 then ThumbTopImages[0].SetImagePath(Block.GetParam('ImageTopN'));
  if Block.CountParams('ImageTopA') > 0 then ThumbTopImages[1].SetImagePath(Block.GetParam('ImageTopA'));
  if Block.CountParams('ImageTopD') > 0 then ThumbTopImages[2].SetImagePath(Block.GetParam('ImageTopD'));
  if Block.CountParams('ImageCenterN') > 0 then ThumbCenterImages[0].SetImagePath(Block.GetParam('ImageCenterN'));
  if Block.CountParams('ImageCenterA') > 0 then ThumbCenterImages[1].SetImagePath(Block.GetParam('ImageCenterA'));
  if Block.CountParams('ImageCenterD') > 0 then ThumbCenterImages[2].SetImagePath(Block.GetParam('ImageCenterD'));
  if Block.CountParams('ImageBottomN') > 0 then ThumbBottomImages[0].SetImagePath(Block.GetParam('ImageBottomN'));
  if Block.CountParams('ImageBottomA') > 0 then ThumbBottomImages[1].SetImagePath(Block.GetParam('ImageBottomA'));
  if Block.CountParams('ImageBottomD') > 0 then ThumbBottomImages[2].SetImagePath(Block.GetParam('ImageBottomD'));
  if Block.CountParams('ImageBarN') > 0 then AfterThumbBarImages[0].SetImagePath(Block.GetParam('ImageBarN'));
  if Block.CountParams('ImageBarA') > 0 then AfterThumbBarImages[1].SetImagePath(Block.GetParam('ImageBarA'));
  if Block.CountParams('ImageBarD') > 0 then AfterThumbBarImages[2].SetImagePath(Block.GetParam('ImageBarD'));
  if Block.CountParams('ImageDownN') > 0 then DownImages[0].SetImagePath(Block.GetParam('ImageDownN'));
  if Block.CountParams('ImageDownA') > 0 then DownImages[1].SetImagePath(Block.GetParam('ImageDownA'));
  if Block.CountParams('ImageDownD') > 0 then DownImages[2].SetImagePath(Block.GetParam('ImageDownD'));
  UpImages[0].SetSize(UpImages[0].GetContentSize);
  UpImages[0].SetImageKindX(ikxCenter);
  UpImages[0].SetImageKindY(ikyCenter);
  UpImages[1].SetSize(UpImages[1].GetContentSize);
  UpImages[1].SetImageKindX(ikxCenter);
  UpImages[1].SetImageKindY(ikyCenter);
  UpImages[2].SetSize(UpImages[2].GetContentSize);
  UpImages[2].SetImageKindX(ikxCenter);
  UpImages[2].SetImageKindY(ikyCenter);
  BeforeThumbBarImages[0].SetSize(BeforeThumbBarImages[0].GetContentSize);
  BeforeThumbBarImages[0].SetImageKindX(ikxLeftFill);
  BeforeThumbBarImages[0].SetImageKindY(ikyTopFill);
  BeforeThumbBarImages[1].SetSize(BeforeThumbBarImages[1].GetContentSize);
  BeforeThumbBarImages[1].SetImageKindX(ikxLeftFill);
  BeforeThumbBarImages[1].SetImageKindY(ikyTopFill);
  BeforeThumbBarImages[2].SetSize(BeforeThumbBarImages[2].GetContentSize);
  BeforeThumbBarImages[2].SetImageKindX(ikxLeftFill);
  BeforeThumbBarImages[2].SetImageKindY(ikyTopFill);
  ThumbTopImages[0].SetSize(ThumbTopImages[0].GetContentSize);
  ThumbTopImages[0].SetImageKindX(ikxCenter);
  ThumbTopImages[0].SetImageKindY(ikyCenter);
  ThumbTopImages[1].SetSize(ThumbTopImages[1].GetContentSize);
  ThumbTopImages[1].SetImageKindX(ikxCenter);
  ThumbTopImages[1].SetImageKindY(ikyCenter);
  ThumbTopImages[2].SetSize(ThumbTopImages[2].GetContentSize);
  ThumbTopImages[2].SetImageKindX(ikxCenter);
  ThumbTopImages[2].SetImageKindY(ikyCenter);
  ThumbCenterImages[0].SetSize(ThumbCenterImages[0].GetContentSize);
  ThumbCenterImages[0].SetImageKindX(ikxLeftFill);
  ThumbCenterImages[0].SetImageKindY(ikyTopFill);
  ThumbCenterImages[1].SetSize(ThumbCenterImages[1].GetContentSize);
  ThumbCenterImages[1].SetImageKindX(ikxLeftFill);
  ThumbCenterImages[1].SetImageKindY(ikyTopFill);
  ThumbCenterImages[2].SetSize(ThumbCenterImages[2].GetContentSize);
  ThumbCenterImages[2].SetImageKindX(ikxLeftFill);
  ThumbCenterImages[2].SetImageKindY(ikyTopFill);
  ThumbBottomImages[0].SetSize(ThumbBottomImages[0].GetContentSize);
  ThumbBottomImages[0].SetImageKindX(ikxCenter);
  ThumbBottomImages[0].SetImageKindY(ikyCenter);
  ThumbBottomImages[1].SetSize(ThumbBottomImages[1].GetContentSize);
  ThumbBottomImages[1].SetImageKindX(ikxCenter);
  ThumbBottomImages[1].SetImageKindY(ikyCenter);
  ThumbBottomImages[2].SetSize(ThumbBottomImages[2].GetContentSize);
  ThumbBottomImages[2].SetImageKindX(ikxCenter);
  ThumbBottomImages[2].SetImageKindY(ikyCenter);
  AfterThumbBarImages[0].SetSize(AfterThumbBarImages[0].GetContentSize);
  AfterThumbBarImages[0].SetImageKindX(ikxRightFill);
  AfterThumbBarImages[0].SetImageKindY(ikyBottomFill);
  AfterThumbBarImages[1].SetSize(AfterThumbBarImages[1].GetContentSize);
  AfterThumbBarImages[1].SetImageKindX(ikxRightFill);
  AfterThumbBarImages[1].SetImageKindY(ikyBottomFill);
  AfterThumbBarImages[2].SetSize(AfterThumbBarImages[2].GetContentSize);
  AfterThumbBarImages[2].SetImageKindX(ikxRightFill);
  AfterThumbBarImages[2].SetImageKindY(ikyBottomFill);
  DownImages[0].SetSize(DownImages[0].GetContentSize);
  DownImages[0].SetImageKindX(ikxCenter);
  DownImages[0].SetImageKindY(ikyCenter);
  DownImages[1].SetSize(DownImages[1].GetContentSize);
  DownImages[1].SetImageKindX(ikxCenter);
  DownImages[1].SetImageKindY(ikyCenter);
  DownImages[2].SetSize(DownImages[2].GetContentSize);
  DownImages[2].SetImageKindX(ikxCenter);
  DownImages[2].SetImageKindY(ikyCenter);
  UpdateLayout;
end;
{ @end $48F7E4 }

end.
