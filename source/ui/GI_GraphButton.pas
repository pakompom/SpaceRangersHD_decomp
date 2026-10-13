unit GI_GraphButton;

interface

uses EC_BlockPar, GI_Image, GI_Label, GI_Main, GI_MessageLoop, Types;

type
  TGraphButtonKindGI = (gbkNormal = 0, gbkFix = 1, gbkDisable = 2, gbkFixDisable = 3); // @size 1
  TGraphButtonHitKindGI = (gbhRect = 0, gbhGraph = 1, gbhImageHit = 2); // @size 1

  TGraphButtonGI = class(TObjectGI) // @size 0x1F4
  public
    Kind: TGraphButtonKindGI; // @offset 0x120
    HitKind: TGraphButtonHitKindGI; // @offset 0x121
    Down: Boolean; // @offset 0x122
    Disabled: Boolean; // @offset 0x123
    DownCallback: TObjectNotifyEventGI; // @offset $128
    UpCallback: TObjectNotifyEventGI; // @offset $130
    StateChangedCallback: TObjectNotifyEventGI; // @offset $138
    ImageNormal: TImageGI; // @offset 0x140
    ImageNormalActive: TImageGI; // @offset 0x144
    ImageDown: TImageGI; // @offset 0x148
    ImageDownActive: TImageGI; // @offset 0x14C
    ImageDisabled: TImageGI; // @offset 0x150
    ImageDisabledActive: TImageGI; // @offset 0x154
    ImageHit: TImageGI; // @offset 0x158
    CaptionLabel: TLabelGI; // @offset 0x15C
    NormalOffset: TPoint; // @offset 0x160
    NormalActiveOffset: TPoint; // @offset 0x168
    DownOffset: TPoint; // @offset 0x170
    DownActiveOffset: TPoint; // @offset 0x178
    DisabledOffset: TPoint; // @offset 0x180
    DisabledActiveOffset: TPoint; // @offset 0x188
    HitOffset: TPoint; // @offset 0x190
    EnterSound: WideString; // @offset 0x198
    LeaveSound: WideString; // @offset 0x19C
    ClickSound: WideString; // @offset 0x1A0
    CaptionOffsets: TRect; // @offset $1A4 // Left/Top for normal, Right/Bottom for down.
    // Color order: normal, normal-active, down, down-active, disabled, disabled-active.
    CaptionColors: array[0..5] of Cardinal; // @offset 0x1B4
    CaptionShadowColors: array[0..5] of Cardinal; // @offset 0x1CC
    CaptionAlignX: TTextAlignXGI; // @offset 0x1E4
    CaptionAlignY: TTextAlignYGI; // @offset 0x1E5
    ImageAutoUpdateFlags: Cardinal; // @offset 0x1E8
    UpOnlyDown: Boolean; // @offset 0x1EC
    OnPressCode: TBlockParEC; // @offset 0x1F0

    constructor Create(Owner: TObjectGI); // @addr 0x004AC898
    destructor Destroy; override; // @addr 0x004AC954
    procedure Clear; override; // @addr 0x004AC97C
    procedure SetCaptionFontName(const FontName: WideString); // @addr 0x004ACA48
    procedure SetCaption(const Text: WideString); // @addr 0x004ACADC
    procedure SetCaptionColor(Value: Cardinal); // @addr 0x004ACB70 @note "Applies to every button state."
    procedure SetCaptionShadowOffset(Value: Integer); // @addr 0x004ACC28
    procedure SetImageNormalPath(const Path: WideString); // @addr 0x004ACCBC
    procedure SetImageNormalActivePath(const Path: WideString); // @addr 0x004ACD3C
    procedure SetImageDownPath(const Path: WideString); // @addr 0x004ACDBC
    procedure SetImageDownActivePath(const Path: WideString); // @addr 0x004ACE3C
    procedure SetImageDisabledPath(const Path: WideString); // @addr 0x004ACEBC
    procedure SetImageDisabledActivePath(const Path: WideString); // @addr 0x004ACF3C
    procedure SetImageHitPath(const Path: WideString); // @addr 0x004ACFBC
    procedure SetKind(Value: TGraphButtonKindGI); // @addr 0x004AD020
    function HitTest(Point: TPoint): Boolean; // @addr 0x004AD034 @note "Graph mode accepts a hit on any state image, including inactive states."
    procedure SetDown(Value: Boolean); // @addr 0x004AD118
    procedure SetDisabled(Value: Boolean); // @addr 0x004AD12C
    function IsHovered: Boolean; // @addr 0x004AD140
    procedure SetHovered(Value: Boolean); // @addr 0x004AD14C @note "Does not change keyboard focus."
    function GetMaxStateImageSize: TPoint; // @addr 0x004AD170 @note "Native code compares an uninitialized temporary size when the first state image is absent."
    procedure UpdateStateVisuals; // @addr 0x004AD2D0
    procedure UpdateStateImagePlacement; // @addr 0x004AD624
    procedure SetSize(Size: TPoint); override; // @addr 0x004AD6F0
    procedure SetOrigin(Origin: TPoint); override; // @addr 0x004AD718
    procedure OnActivate; override; // @addr 0x004AD740
    procedure OnDeactivate; override; // @addr 0x004AD77C
    procedure OnMouseEnter; override; // @addr $4AD7B4
    procedure OnMouseLeave; override; // @addr $4AD7BC
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4AD7D8
    procedure OnHoverGained; override; // @addr $4AD838
    procedure OnHoverLost; override; // @addr $4AD888
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4AD950
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4ADABC
    procedure ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint); override; // @addr $4ADB98
    procedure UpdateAutoGeometry; override; // @addr $4AED00
    procedure ExecuteOnPressCode; // @addr 0x004AD910
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004ADBB0
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004ADBDC
    procedure LoadButtonProperties(Block: TBlockParEC); // @addr 0x004ADBF8 @note "Configured state-image positions are absolute; stored positions are relative to this control."
  end;

implementation

uses Classes, EC_Str, EC_Struct, GR_Main, GR_Sound, Math, Windows;


{ @routine $4AC898 TGraphButtonGI_Create }
constructor TGraphButtonGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := gbkNormal;
  HitKind := gbhRect;
  UpOnlyDown := False;
  CaptionColors[0] := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  CaptionColors[1] := CaptionColors[0];
  CaptionColors[2] := CaptionColors[0];
  CaptionColors[3] := CaptionColors[0];
  CaptionColors[4] := CaptionColors[0];
  CaptionColors[5] := CaptionColors[0];
  CaptionAlignX := taxCenter;
  CaptionAlignY := tayCenterEx;
  OnPressCode := nil;
end;
{ @end $4AC898 }

{ @routine $4AC954 TGraphButtonGI_Destroy }
destructor TGraphButtonGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4AC954 }

{ @routine $4AC97C TGraphButtonGI_Clear }
procedure TGraphButtonGI.Clear;
begin
  Kind := gbkNormal;
  if ImageNormal <> nil then
  begin
    ImageNormal.Free;
    ImageNormal := nil;
  end;
  if ImageNormalActive <> nil then
  begin
    ImageNormalActive.Free;
    ImageNormalActive := nil;
  end;
  if ImageDown <> nil then
  begin
    ImageDown.Free;
    ImageDown := nil;
  end;
  if ImageDownActive <> nil then
  begin
    ImageDownActive.Free;
    ImageDownActive := nil;
  end;
  if ImageDisabled <> nil then
  begin
    ImageDisabled.Free;
    ImageDisabled := nil;
  end;
  if ImageDisabledActive <> nil then
  begin
    ImageDisabledActive.Free;
    ImageDisabledActive := nil;
  end;
  if ImageHit <> nil then
  begin
    ImageHit.Free;
    ImageHit := nil;
  end;
  if CaptionLabel <> nil then
  begin
    CaptionLabel.Free;
    CaptionLabel := nil;
  end;
  inherited Clear;
end;
{ @end $4AC97C }

{ @routine $4ACA48 TGraphButtonGI_SetCaptionFontName }
procedure TGraphButtonGI.SetCaptionFontName(const FontName: WideString);
begin
  if CaptionLabel = nil then
  begin
    CaptionLabel := TLabelGI.Create(Self);
    CaptionLabel.Pos := Classes.Point(0, 0);
    CaptionLabel.ObjectSize := ClientSize;
    CaptionLabel.SetDepth(-9999);
    CaptionLabel.SetTextAlignX(CaptionAlignX);
    CaptionLabel.SetTextAlignY(CaptionAlignY);
  end;
  CaptionLabel.SetFontName(FontName);
end;
{ @end $4ACA48 }

{ @routine $4ACADC TGraphButtonGI_SetCaption }
procedure TGraphButtonGI.SetCaption(const Text: WideString);
begin
  if CaptionLabel = nil then
  begin
    CaptionLabel := TLabelGI.Create(Self);
    CaptionLabel.Pos := Classes.Point(0, 0);
    CaptionLabel.ObjectSize := ClientSize;
    CaptionLabel.SetDepth(-9999);
    CaptionLabel.SetTextAlignX(CaptionAlignX);
    CaptionLabel.SetTextAlignY(CaptionAlignY);
  end;
  CaptionLabel.Text := Text;
end;
{ @end $4ACADC }

{ @routine $4ACB70 TGraphButtonGI_SetCaptionColor }
procedure TGraphButtonGI.SetCaptionColor(Value: Cardinal);
begin
  CaptionColors[0] := Value;
  CaptionColors[1] := Value;
  CaptionColors[2] := Value;
  CaptionColors[3] := Value;
  CaptionColors[4] := Value;
  CaptionColors[5] := Value;
  if CaptionLabel = nil then
  begin
    CaptionLabel := TLabelGI.Create(Self);
    CaptionLabel.Pos := Classes.Point(0, 0);
    CaptionLabel.ObjectSize := ClientSize;
    CaptionLabel.SetDepth(-9999);
    CaptionLabel.SetTextAlignX(CaptionAlignX);
    CaptionLabel.SetTextAlignY(CaptionAlignY);
  end;
  CaptionLabel.SetTextColor(Value);
end;
{ @end $4ACB70 }

{ @routine $4ACC28 TGraphButtonGI_SetCaptionShadowOffset }
procedure TGraphButtonGI.SetCaptionShadowOffset(Value: Integer);
begin
  if CaptionLabel = nil then
  begin
    CaptionLabel := TLabelGI.Create(Self);
    CaptionLabel.Pos := Classes.Point(0, 0);
    CaptionLabel.ObjectSize := ClientSize;
    CaptionLabel.SetDepth(-9999);
    CaptionLabel.SetTextAlignX(CaptionAlignX);
    CaptionLabel.SetTextAlignY(CaptionAlignY);
  end;
  CaptionLabel.SetShadowOffset(Value);
end;
{ @end $4ACC28 }

{ @routine $4ACCBC TGraphButtonGI_SetImageNormalPath }
procedure TGraphButtonGI.SetImageNormalPath(const Path: WideString);
begin
  if ImageNormal = nil then ImageNormal := TImageGI.Create(Self);
  ImageNormal.SetDepth(1);
  ImageNormal.AutoUpdateFlags := ImageAutoUpdateFlags;
  ImageNormal.ImageSourcePath := Path;
  ImageNormal.ObjectSize := ImageNormal.GetContentSize;
  ImageNormal.Pos := NormalOffset;
end;
{ @end $4ACCBC }

{ @routine $4ACD3C TGraphButtonGI_SetImageNormalActivePath }
procedure TGraphButtonGI.SetImageNormalActivePath(const Path: WideString);
begin
  if ImageNormalActive = nil then ImageNormalActive := TImageGI.Create(Self);
  ImageNormalActive.SetDepth(1);
  ImageNormalActive.AutoUpdateFlags := ImageAutoUpdateFlags;
  ImageNormalActive.ImageSourcePath := Path;
  ImageNormalActive.ObjectSize := ImageNormalActive.GetContentSize;
  ImageNormalActive.Pos := NormalActiveOffset;
end;
{ @end $4ACD3C }

{ @routine $4ACDBC TGraphButtonGI_SetImageDownPath }
procedure TGraphButtonGI.SetImageDownPath(const Path: WideString);
begin
  if ImageDown = nil then ImageDown := TImageGI.Create(Self);
  ImageDown.SetDepth(1);
  ImageDown.AutoUpdateFlags := ImageAutoUpdateFlags;
  ImageDown.ImageSourcePath := Path;
  ImageDown.ObjectSize := ImageDown.GetContentSize;
  ImageDown.Pos := DownOffset;
end;
{ @end $4ACDBC }

{ @routine $4ACE3C TGraphButtonGI_SetImageDownActivePath }
procedure TGraphButtonGI.SetImageDownActivePath(const Path: WideString);
begin
  if ImageDownActive = nil then ImageDownActive := TImageGI.Create(Self);
  ImageDownActive.SetDepth(1);
  ImageDownActive.AutoUpdateFlags := ImageAutoUpdateFlags;
  ImageDownActive.ImageSourcePath := Path;
  ImageDownActive.ObjectSize := ImageDownActive.GetContentSize;
  ImageDownActive.Pos := DownActiveOffset;
end;
{ @end $4ACE3C }

{ @routine $4ACEBC TGraphButtonGI_SetImageDisabledPath }
procedure TGraphButtonGI.SetImageDisabledPath(const Path: WideString);
begin
  if ImageDisabled = nil then ImageDisabled := TImageGI.Create(Self);
  ImageDisabled.SetDepth(1);
  ImageDisabled.AutoUpdateFlags := ImageAutoUpdateFlags;
  ImageDisabled.ImageSourcePath := Path;
  ImageDisabled.ObjectSize := ImageDisabled.GetContentSize;
  ImageDisabled.Pos := DisabledOffset;
end;
{ @end $4ACEBC }

{ @routine $4ACF3C TGraphButtonGI_SetImageDisabledActivePath }
procedure TGraphButtonGI.SetImageDisabledActivePath(const Path: WideString);
begin
  if ImageDisabledActive = nil then ImageDisabledActive := TImageGI.Create(Self);
  ImageDisabledActive.SetDepth(1);
  ImageDisabledActive.AutoUpdateFlags := ImageAutoUpdateFlags;
  ImageDisabledActive.ImageSourcePath := Path;
  ImageDisabledActive.ObjectSize := ImageDisabledActive.GetContentSize;
  ImageDisabledActive.Pos := DisabledActiveOffset;
end;
{ @end $4ACF3C }

{ @routine $4ACFBC TGraphButtonGI_SetImageHitPath }
procedure TGraphButtonGI.SetImageHitPath(const Path: WideString);
begin
  if ImageHit = nil then ImageHit := TImageGI.Create(Self);
  ImageHit.ImageSourcePath := Path;
  ImageHit.ObjectSize := ImageHit.GetContentSize;
  ImageHit.Pos := HitOffset;
end;
{ @end $4ACFBC }

{ @routine $4AD020 TGraphButtonGI_SetKind }
procedure TGraphButtonGI.SetKind(Value: TGraphButtonKindGI);
begin
  if Kind = Value then Exit;
  Kind := Value;
  UpdateStateVisuals;
end;
{ @end $4AD020 }

{ @routine $4AD034 TGraphButtonGI_HitTest }
function TGraphButtonGI.HitTest(Point: TPoint): Boolean;
begin
  Result := False;
  if HitKind = gbhRect then Result := ContainsPoint(Point)
  else if HitKind = gbhGraph then
  begin
    if ImageNormal <> nil then Result := ImageNormal.HitTestPixel(Point);
    if Result then Exit;
    if ImageNormalActive <> nil then Result := ImageNormalActive.HitTestPixel(Point);
    if Result then Exit;
    if ImageDown <> nil then Result := ImageDown.HitTestPixel(Point);
    if Result then Exit;
    if ImageDownActive <> nil then Result := ImageDownActive.HitTestPixel(Point);
    if Result then Exit;
    if ImageDisabled <> nil then Result := ImageDisabled.HitTestPixel(Point);
    if Result then Exit;
    if ImageDisabledActive <> nil then Result := ImageDisabledActive.HitTestPixel(Point);
    if Result then Exit;
  end
  else if HitKind = gbhImageHit then
  begin
    if ImageHit <> nil then Result := ImageHit.HitTestPixel(Point);
  end;
end;
{ @end $4AD034 }

{ @routine $4AD118 TGraphButtonGI_SetDown }
procedure TGraphButtonGI.SetDown(Value: Boolean);
begin
  if Down = Value then Exit;
  Down := Value;
  UpdateStateVisuals;
end;
{ @end $4AD118 }

{ @routine $4AD12C TGraphButtonGI_SetDisabled }
procedure TGraphButtonGI.SetDisabled(Value: Boolean);
begin
  if Disabled = Value then Exit;
  Disabled := Value;
  UpdateStateVisuals;
end;
{ @end $4AD12C }

{ @routine $4AD140 TGraphButtonGI_IsHovered }
function TGraphButtonGI.IsHovered: Boolean;
begin
  Result := MessageLoop.HoveredControl = Self;
end;
{ @end $4AD140 }

{ @routine $4AD14C TGraphButtonGI_SetHovered }
procedure TGraphButtonGI.SetHovered(Value: Boolean);
begin
  if Value then MessageLoop.SetHoveredControl(Self)
  else if MessageLoop.HoveredControl = Self then MessageLoop.SetHoveredControl(nil);
end;
{ @end $4AD14C }

{ @routine $4AD170 TGraphButtonGI_GetMaxStateImageSize }
function TGraphButtonGI.GetMaxStateImageSize: TPoint;
var Size: TPoint;
begin
  Result.X := 0;
  Result.Y := 0;
  // Native comparisons are unconditional, including before Size is initialized.
  if ImageNormal <> nil then Size := ImageNormal.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
  if ImageNormalActive <> nil then Size := ImageNormalActive.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
  if ImageDown <> nil then Size := ImageDown.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
  if ImageDownActive <> nil then Size := ImageDownActive.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
  if ImageDisabled <> nil then Size := ImageDisabled.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
  if ImageDisabledActive <> nil then Size := ImageDisabledActive.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
  if ImageHit <> nil then Size := ImageHit.GetContentSize;
  Result.X := Max(Result.X, Size.X);
  Result.Y := Max(Result.Y, Size.Y);
end;
{ @end $4AD170 }

{ @routine $4AD2D0 TGraphButtonGI_UpdateStateVisuals }
procedure TGraphButtonGI.UpdateStateVisuals;
begin
  if ImageNormal <> nil then ImageNormal.IsActive := False;
  if ImageNormalActive <> nil then ImageNormalActive.IsActive := False;
  if ImageDown <> nil then ImageDown.IsActive := False;
  if ImageDownActive <> nil then ImageDownActive.IsActive := False;
  if ImageDisabled <> nil then ImageDisabled.IsActive := False;
  if ImageDisabledActive <> nil then ImageDisabledActive.IsActive := False;
  if ImageHit <> nil then ImageHit.IsActive := False;
  if Disabled and ((Kind = gbkDisable) or (Kind = gbkFixDisable)) then
  begin
    if MessageLoop.HoveredControl = Self then
    begin
      if ImageDisabledActive <> nil then ImageDisabledActive.IsActive := True
      else if ImageDisabled <> nil then ImageDisabled.IsActive := True;
    end
    else if ImageDisabled <> nil then ImageDisabled.IsActive := True;
  end
  else
  begin
    if Down then
    begin
      if MessageLoop.HoveredControl = Self then
      begin
        if ImageDownActive <> nil then ImageDownActive.IsActive := True
        else if ImageDown <> nil then ImageDown.IsActive := True;
      end
      else if ImageDown <> nil then ImageDown.IsActive := True;
    end
    else
    begin
      if MessageLoop.HoveredControl = Self then
      begin
        if ImageNormalActive <> nil then ImageNormalActive.IsActive := True
        else if ImageNormal <> nil then ImageNormal.IsActive := True;
      end
      else if ImageNormal <> nil then ImageNormal.IsActive := True;
    end;
  end;
  if CaptionLabel <> nil then
  begin
    if not Down then CaptionLabel.Pos := CaptionOffsets.TopLeft
    else CaptionLabel.Pos := CaptionOffsets.BottomRight;
    if Disabled and ((Kind = gbkDisable) or (Kind = gbkFixDisable)) then
    begin
      if MessageLoop.HoveredControl = Self then
      begin
        CaptionLabel.SetTextColor(CaptionColors[5]);
        CaptionLabel.SetShadowColor(CaptionShadowColors[5]);
      end
      else
      begin
        CaptionLabel.SetTextColor(CaptionColors[4]);
        CaptionLabel.SetShadowColor(CaptionShadowColors[4]);
      end;
    end
    else
    begin
      if Down then
      begin
        if MessageLoop.HoveredControl = Self then
        begin
          CaptionLabel.SetTextColor(CaptionColors[3]);
          CaptionLabel.SetShadowColor(CaptionShadowColors[3]);
        end
        else
        begin
          CaptionLabel.SetTextColor(CaptionColors[2]);
          CaptionLabel.SetShadowColor(CaptionShadowColors[2]);
        end;
      end
      else
      begin
        if MessageLoop.HoveredControl = Self then
        begin
          CaptionLabel.SetTextColor(CaptionColors[1]);
          CaptionLabel.SetShadowColor(CaptionShadowColors[1]);
        end
        else
        begin
          CaptionLabel.SetTextColor(CaptionColors[0]);
          CaptionLabel.SetShadowColor(CaptionShadowColors[0]);
        end;
      end;
    end;
  end;
  if ImageNormal <> nil then
    if ImageNormal.Active then ImageNormal.RestartPlayback;
  if ImageNormalActive <> nil then
    if ImageNormalActive.Active then ImageNormalActive.RestartPlayback;
  if ImageDown <> nil then
    if ImageDown.Active then ImageDown.RestartPlayback;
  if ImageDownActive <> nil then
    if ImageDownActive.Active then ImageDownActive.RestartPlayback;
  if ImageDisabled <> nil then
    if ImageDisabled.Active then ImageDisabled.RestartPlayback;
  if ImageDisabledActive <> nil then
    if ImageDisabledActive.Active then ImageDisabledActive.RestartPlayback;
  Invalidate;
  if Assigned(StateChangedCallback) then StateChangedCallback(Self);
end;
{ @end $4AD2D0 }

{ @routine $4AD624 TGraphButtonGI_UpdateStateImagePlacement }
procedure TGraphButtonGI.UpdateStateImagePlacement;
begin
  if ImageNormal <> nil then ImageNormal.Pos := NormalOffset;
  if ImageNormalActive <> nil then ImageNormalActive.Pos := NormalActiveOffset;
  if ImageDown <> nil then ImageDown.Pos := DownOffset;
  if ImageDownActive <> nil then ImageDownActive.Pos := DownActiveOffset;
  if ImageDisabled <> nil then ImageDisabled.Pos := DisabledOffset;
  if ImageDisabledActive <> nil then ImageDisabledActive.Pos := DisabledActiveOffset;
  if ImageHit <> nil then ImageHit.Pos := HitOffset;
  if CaptionLabel <> nil then
  begin
    CaptionLabel.Pos := Classes.Point(0, 0);
    CaptionLabel.ObjectSize := ClientSize;
  end;
end;
{ @end $4AD624 }

{ @routine $4AD6F0 TGraphButtonGI_SetSize }
procedure TGraphButtonGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  UpdateStateImagePlacement;
end;
{ @end $4AD6F0 }

{ @routine $4AD718 TGraphButtonGI_SetOrigin }
procedure TGraphButtonGI.SetOrigin(Origin: TPoint);
begin
  inherited SetOrigin(Origin);
  UpdateStateImagePlacement;
end;
{ @end $4AD718 }

{ @routine $4AD740 TGraphButtonGI_OnActivate }
procedure TGraphButtonGI.OnActivate;
begin
  inherited OnActivate;
  if HitTestCursor then MessageLoop.HoveredControl := Self;
  if (Kind = gbkNormal) or (Kind = gbkDisable) then Down := False;
  UpdateStateVisuals;
end;
{ @end $4AD740 }

{ @routine $4AD77C TGraphButtonGI_OnDeactivate }
procedure TGraphButtonGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if MessageLoop.HoveredControl = Self then MessageLoop.HoveredControl := nil;
  if (Kind = gbkNormal) or (Kind = gbkDisable) then Down := False;
  UpdateStateVisuals;
end;
{ @end $4AD77C }

{ @routine $4AD7B4 TGraphButtonGI_OnMouseEnter }
procedure TGraphButtonGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;
{ @end $4AD7B4 }

{ @routine $4AD7BC TGraphButtonGI_OnMouseLeave }
procedure TGraphButtonGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if MessageLoop.HoveredControl = Self then MessageLoop.SetHoveredControl(nil);
end;
{ @end $4AD7BC }

{ @routine $4AD7D8 TGraphButtonGI_ProcessMouseMove }
procedure TGraphButtonGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
begin
  if MouseBlockingTest and IsOccludedAtPoint(AbsolutePosition) then Exit;
  if HitTest(Point) then
  begin
    if not Disabled then MessageLoop.SetHoveredControl(Self);
  end
  else if MessageLoop.HoveredControl = Self then MessageLoop.SetHoveredControl(nil);
end;
{ @end $4AD7D8 }

{ @routine $4AD838 TGraphButtonGI_OnHoverGained }
procedure TGraphButtonGI.OnHoverGained;
begin
  if (EnterSound <> '') and not Disabled then SoundManager.PlaySound(EnterSound);
  if Assigned(HelpCallback) then HelpCallback(Self, True);
  UpdateStateVisuals;
end;
{ @end $4AD838 }

{ @routine $4AD888 TGraphButtonGI_OnHoverLost }
procedure TGraphButtonGI.OnHoverLost;
begin
  if (Kind = gbkNormal) or (Kind = gbkDisable) then
  begin
    if Down then
    begin
      Down := False;
      if Assigned(UpCallback) then UpCallback(Self);
    end;
  end;
  if (LeaveSound <> '') and not Disabled then SoundManager.PlaySound(LeaveSound);
  if Assigned(HelpCallback) then HelpCallback(Self, False);
  UpdateStateVisuals;
end;
{ @end $4AD888 }

{ @routine $4AD910 TGraphButtonGI_ExecuteOnPressCode }
procedure TGraphButtonGI.ExecuteOnPressCode;
begin
  if OnPressCode <> nil then
  begin
    MessageLoop.QueueUiCode(OnPressCode, True);
    if Assigned(HelpCallback) then HelpCallback(Self, False);
  end
  else MessageLoop.RefreshMouseDispatch;
end;
{ @end $4AD910 }

{ @routine $4AD950 TGraphButtonGI_ProcessLeftButtonDown }
procedure TGraphButtonGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  if IsOccludedAtPoint(Point) then Exit;
  if not HitTest(Point) then Exit;
  if MessageLoop.HoveredControl <> Self then Exit;
  if ((Kind = gbkDisable) or (Kind = gbkFixDisable)) and (Disabled = True) then Exit;
  if (Kind = gbkNormal) or (Kind = gbkDisable) then
  begin
    Down := True;
    if ClickSound <> '' then SoundManager.PlaySound(ClickSound);
    if Assigned(DownCallback) then
    begin
      DownCallback(Self);
      ExecuteOnPressCode;
    end;
  end
  else
  begin
    if Down then
    begin
      Down := False;
      if Assigned(UpCallback) then
      begin
        UpCallback(Self);
        ExecuteOnPressCode;
      end
      else if not Assigned(DownCallback) then ExecuteOnPressCode;
    end
    else
    begin
      Down := True;
      if ClickSound <> '' then SoundManager.PlaySound(ClickSound);
      if Assigned(DownCallback) then
      begin
        DownCallback(Self);
        ExecuteOnPressCode;
      end
      else if not Assigned(UpCallback) then ExecuteOnPressCode;
    end;
  end;
  UpdateStateVisuals;
end;
{ @end $4AD950 }

{ @routine $4ADABC TGraphButtonGI_ProcessLeftButtonUp }
procedure TGraphButtonGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
var WasDown: Boolean;
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  if IsOccludedAtPoint(Point) then Exit;
  if not HitTest(Point) then Exit;
  if MessageLoop.HoveredControl <> Self then Exit;
  if ((Kind = gbkDisable) or (Kind = gbkFixDisable)) and (Disabled = True) then Exit;
  if (Kind = gbkNormal) or (Kind = gbkDisable) then
  begin
    WasDown := Down;
    Down := False;
    if Assigned(UpCallback) and MessageLoop.ConsumeTimerTickChange then
    begin
      if (UpOnlyDown = False) or (WasDown <> False) then UpCallback(Self);
      ExecuteOnPressCode;
    end;
    if not Assigned(UpCallback) and not Assigned(DownCallback) then ExecuteOnPressCode;
    UpdateStateVisuals;
  end;
end;
{ @end $4ADABC }

{ @routine $4ADB98 TGraphButtonGI_ProcessLeftButtonDoubleClick }
procedure TGraphButtonGI.ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonDoubleClick(KeyState, Point);
end;
{ @end $4ADB98 }

{ @routine $4ADBB0 TGraphButtonGI_LoadFromConfigPath }
procedure TGraphButtonGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadButtonProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4ADBB0 }

{ @routine $4ADBDC TGraphButtonGI_LoadFromBlock }
procedure TGraphButtonGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadButtonProperties(Block);
end;
{ @end $4ADBDC }

{ @routine $4ADBF8 TGraphButtonGI_LoadButtonProperties }
procedure TGraphButtonGI.LoadButtonProperties(Block: TBlockParEC);
var Text: WideString;
begin
  if Block.CountParams('CaptionAlignY') > 0 then
  begin
    Text := TrimWideString(Block.GetParam('CaptionAlignY'));
    CaptionAlignY := ParseTextAlignYName(Text);
  end;
  if Block.CountParams('CaptionAlignX') > 0 then
  begin
    Text := TrimWideString(Block.GetParam('CaptionAlignX'));
    CaptionAlignX := ParseTextAlignXName(Text);
  end;
  if Block.CountParams('Font') > 0 then SetCaptionFontName(Block.GetParam('Font'));
  if Block.CountParams('Caption') > 0 then
  begin
    Text := Block.GetParam('Caption');
    SetCaption(Text);
    if LanguageDataConfig.CountParamsByPath(Text) > 0 then
      SetCaption(LanguageDataConfig.GetParamByPathOrMarker(Text));
  end;
  if Block.CountParams('CaptionColor') > 0 then SetCaptionColor(GetColorGI(Block.GetParam('CaptionColor')));
  if Block.CountParams('CaptionShadow') > 0 then SetCaptionShadowOffset(ExtractDigitsToIntW(Block.GetParam('CaptionShadow')));
  if Block.CountParams('CaptionColorNormal') > 0 then CaptionColors[0] := GetColorGI(Block.GetParam('CaptionColorNormal'));
  if Block.CountParams('CaptionColorNormalA') > 0 then CaptionColors[1] := GetColorGI(Block.GetParam('CaptionColorNormalA'));
  if Block.CountParams('CaptionColorDown') > 0 then CaptionColors[2] := GetColorGI(Block.GetParam('CaptionColorDown'));
  if Block.CountParams('CaptionColorDownA') > 0 then CaptionColors[3] := GetColorGI(Block.GetParam('CaptionColorDownA'));
  if Block.CountParams('CaptionColorDisable') > 0 then CaptionColors[4] := GetColorGI(Block.GetParam('CaptionColorDisable'));
  if Block.CountParams('CaptionColorDisableA') > 0 then CaptionColors[5] := GetColorGI(Block.GetParam('CaptionColorDisableA'));
  if Block.CountParams('CaptionShadowColorNormal') > 0 then CaptionShadowColors[0] := GetColorGI(Block.GetParam('CaptionShadowColorNormal'));
  if Block.CountParams('CaptionShadowColorNormalA') > 0 then CaptionShadowColors[1] := GetColorGI(Block.GetParam('CaptionShadowColorNormalA'));
  if Block.CountParams('CaptionShadowColorDown') > 0 then CaptionShadowColors[2] := GetColorGI(Block.GetParam('CaptionShadowColorDown'));
  if Block.CountParams('CaptionShadowColorDownA') > 0 then CaptionShadowColors[3] := GetColorGI(Block.GetParam('CaptionShadowColorDownA'));
  if Block.CountParams('CaptionShadowColorDisable') > 0 then CaptionShadowColors[4] := GetColorGI(Block.GetParam('CaptionShadowColorDisable'));
  if Block.CountParams('CaptionShadowColorDisableA') > 0 then CaptionShadowColors[5] := GetColorGI(Block.GetParam('CaptionShadowColorDisableA'));
  if Block.CountParams('Kind') > 0 then
  begin
    Text := Block.GetParam('Kind');
    if Text = 'Normal' then SetKind(gbkNormal)
    else if Text = 'Fix' then SetKind(gbkFix)
    else if Text = 'Disable' then SetKind(gbkDisable)
    else if Text = 'FixDisable' then SetKind(gbkFixDisable);
  end;
  if Block.CountParams('Auto') > 0 then ImageAutoUpdateFlags := ParseAutoGeometryFlagsGI(Block.GetParam('Auto'));
  if Block.CountParams('KindHit') > 0 then
  begin
    Text := Block.GetParam('KindHit');
    if Text = 'Rect' then HitKind := gbhRect
    else if Text = 'Graph' then HitKind := gbhGraph
    else if Text = 'ImageHit' then HitKind := gbhImageHit;
  end;
  if Block.CountParams('ImageNormal') > 0 then SetImageNormalPath(Block.GetParam('ImageNormal'));
  if Block.CountParams('ImageNormalA') > 0 then SetImageNormalActivePath(Block.GetParam('ImageNormalA'));
  if Block.CountParams('ImageDown') > 0 then SetImageDownPath(Block.GetParam('ImageDown'));
  if Block.CountParams('ImageDownA') > 0 then SetImageDownActivePath(Block.GetParam('ImageDownA'));
  if Block.CountParams('ImageDisable') > 0 then SetImageDisabledPath(Block.GetParam('ImageDisable'));
  if Block.CountParams('ImageDisableA') > 0 then SetImageDisabledActivePath(Block.GetParam('ImageDisableA'));
  if Block.CountParams('ImageHit') > 0 then SetImageHitPath(Block.GetParam('ImageHit'));
  if Block.CountParams('ImageNormal_Pos') > 0 then NormalOffset := GetPointGI(Block.GetParam('ImageNormal_Pos'))
  else NormalOffset := LocalPosition;
  if Block.CountParams('ImageNormalA_Pos') > 0 then NormalActiveOffset := GetPointGI(Block.GetParam('ImageNormalA_Pos'))
  else NormalActiveOffset := LocalPosition;
  if Block.CountParams('ImageDown_Pos') > 0 then DownOffset := GetPointGI(Block.GetParam('ImageDown_Pos'))
  else DownOffset := LocalPosition;
  if Block.CountParams('ImageDownA_Pos') > 0 then DownActiveOffset := GetPointGI(Block.GetParam('ImageDownA_Pos'))
  else DownActiveOffset := LocalPosition;
  if Block.CountParams('ImageDisable_Pos') > 0 then DisabledOffset := GetPointGI(Block.GetParam('ImageDisable_Pos'))
  else DisabledOffset := LocalPosition;
  if Block.CountParams('ImageDisableA_Pos') > 0 then DisabledActiveOffset := GetPointGI(Block.GetParam('ImageDisableA_Pos'))
  else DisabledActiveOffset := LocalPosition;
  if Block.CountParams('ImageHit_Pos') > 0 then HitOffset := GetPointGI(Block.GetParam('ImageHit_Pos'))
  else HitOffset := LocalPosition;
  NormalOffset := SubtractPoints(NormalOffset, LocalPosition);
  NormalActiveOffset := SubtractPoints(NormalActiveOffset, LocalPosition);
  DownOffset := SubtractPoints(DownOffset, LocalPosition);
  DownActiveOffset := SubtractPoints(DownActiveOffset, LocalPosition);
  DisabledOffset := SubtractPoints(DisabledOffset, LocalPosition);
  DisabledActiveOffset := SubtractPoints(DisabledActiveOffset, LocalPosition);
  HitOffset := SubtractPoints(HitOffset, LocalPosition);
  if Block.CountParams('Disable') > 0 then SetDisabled(ParseEnabledNameGI(Block.GetParam('Disable')));
  if Block.CountParams('Down') > 0 then SetDown(ParseEnabledNameGI(Block.GetParam('Down')));
  if Block.CountParams('UpOnlyDown') > 0 then UpOnlyDown := ParseEnabledNameGI(Block.GetParam('UpOnlyDown'));
  if Block.CountParams('SoundEnter') > 0 then EnterSound := Block.GetParam('SoundEnter');
  if Block.CountParams('SoundLeave') > 0 then LeaveSound := Block.GetParam('SoundLeave');
  if Block.CountParams('SoundClick') > 0 then ClickSound := Block.GetParam('SoundClick');
  if Block.CountParams('CaptionSme') > 0 then CaptionOffsets := GetRectGI(Block.GetParam('CaptionSme'));
  if Block.CountBlocks('OnPressCode') > 0 then OnPressCode := Block.GetBlock('OnPressCode');
  UpdateStateImagePlacement;
end;
{ @end $4ADBF8 }

{ @routine $4AED00 TGraphButtonGI_UpdateAutoGeometry }
procedure TGraphButtonGI.UpdateAutoGeometry;
var Bounds, ImageBounds: TRect;
begin
  inherited UpdateAutoGeometry;
  if ImageAutoUpdateFlags <> 0 then
  begin
    Bounds.Left := 0;
    Bounds.Top := 0;
    Bounds.Right := 0;
    Bounds.Bottom := 0;
    if ImageNormal <> nil then
    begin
      ImageBounds.TopLeft := ImageNormal.GetContentOrigin;
      ImageBounds.BottomRight := ImageNormal.GetContentSize;
      ImageBounds.BottomRight := AddPoints(ImageBounds.TopLeft, ImageBounds.BottomRight);
      Bounds := ImageBounds;
    end;
    if ImageNormalActive <> nil then
    begin
      ImageBounds.TopLeft := ImageNormalActive.GetContentOrigin;
      ImageBounds.BottomRight := ImageNormalActive.GetContentSize;
      ImageBounds.BottomRight := AddPoints(ImageBounds.TopLeft, ImageBounds.BottomRight);
      if Bounds.Right - Bounds.Left < 1 then Bounds := ImageBounds
      else Windows.UnionRect(Bounds, Bounds, ImageBounds);
    end;
    if ImageDown <> nil then
    begin
      ImageBounds.TopLeft := ImageDown.GetContentOrigin;
      ImageBounds.BottomRight := ImageDown.GetContentSize;
      ImageBounds.BottomRight := AddPoints(ImageBounds.TopLeft, ImageBounds.BottomRight);
      if Bounds.Right - Bounds.Left < 1 then Bounds := ImageBounds
      else Windows.UnionRect(Bounds, Bounds, ImageBounds);
    end;
    if ImageDownActive <> nil then
    begin
      ImageBounds.TopLeft := ImageDownActive.GetContentOrigin;
      ImageBounds.BottomRight := ImageDownActive.GetContentSize;
      ImageBounds.BottomRight := AddPoints(ImageBounds.TopLeft, ImageBounds.BottomRight);
      if Bounds.Right - Bounds.Left < 1 then Bounds := ImageBounds
      else Windows.UnionRect(Bounds, Bounds, ImageBounds);
    end;
    if ImageDisabled <> nil then
    begin
      ImageBounds.TopLeft := ImageDisabled.GetContentOrigin;
      ImageBounds.BottomRight := ImageDisabled.GetContentSize;
      ImageBounds.BottomRight := AddPoints(ImageBounds.TopLeft, ImageBounds.BottomRight);
      if Bounds.Right - Bounds.Left < 1 then Bounds := ImageBounds
      else Windows.UnionRect(Bounds, Bounds, ImageBounds);
    end;
    if ImageDisabledActive <> nil then
    begin
      ImageBounds.TopLeft := ImageDisabledActive.GetContentOrigin;
      ImageBounds.BottomRight := ImageDisabledActive.GetContentSize;
      ImageBounds.BottomRight := AddPoints(ImageBounds.TopLeft, ImageBounds.BottomRight);
      if Bounds.Right - Bounds.Left < 1 then Bounds := ImageBounds
      else Windows.UnionRect(Bounds, Bounds, ImageBounds);
    end;
    if (ImageAutoUpdateFlags and agfPosition) = agfPosition then Pos := Parent.ToLocalPoint(Bounds.TopLeft);
    if (ImageAutoUpdateFlags and agfSize) = agfSize then ObjectSize := SubtractPoints(Bounds.BottomRight, Bounds.TopLeft);
  end;
  inherited UpdateAutoGeometry;
end;
{ @end $4AED00 }

end.
