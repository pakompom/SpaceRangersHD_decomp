unit GI_Circle;

interface

uses EC_BlockPar, GI_MessageLoop, GR_GraphBuf, Types;

type
  TCircleKindGI = (
    circle_fit_outline = 0,
    circle_outline = 1,
    circle_fit_fill = 2,
    circle_shift_light = 3,
    circle_multiply_light = 4 // Configurable, but the native draw branch is unimplemented.
  ); // @size 0x01
  TCircleGI = class(TObjectGI) // @size 0x140
  public
    Kind: TCircleKindGI; // @offset 0x120
    Color: Cardinal; // @offset 0x124
    FillColor: Cardinal; // @offset 0x128
    Center: TPoint; // @offset 0x12C
    Radius: Integer; // @offset 0x134
    ShrLightInner: Byte; // @offset 0x138
    ShrLightOuter: Byte; // @offset 0x139
    LightBufferDirty: Boolean; // @offset 0x13A
    LightBuffer: TGraphBufGR; // @offset 0x13C

    constructor Create(Owner: TObjectGI); // @addr 0x00484310
    destructor Destroy; override; // @addr 0x004843C8
    procedure Clear; override; // @addr 0x004843F0
    procedure SetKind(Value: TCircleKindGI); // @addr 0x00484494
    procedure SetColor(Value: Cardinal); // @addr 0x00484500
    procedure SetFillColor(Value: Cardinal); // @addr 0x00484520
    procedure SetCenter(Value: TPoint); // @addr 0x00484540
    procedure SetRadius(Value: Integer); // @addr 0x0048458C
    procedure SetShrLightInner(Value: Byte); // @addr 0x004845B0
    procedure SetShrLightOuter(Value: Byte); // @addr 0x004845D4
    procedure SetSize(Size: TPoint); override; // @addr 0x004845F8
    procedure SetActive(Enabled: Boolean); override; // @addr 0x00484620
    procedure OnActivate; override; // @addr 0x00484658
    procedure OnDeactivate; override; // @addr 0x0048466C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x00484688
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004846B4
    procedure LoadShapeProperties(Block: TBlockParEC); // @addr 0x004846D0
    procedure Draw(ClipRect: TRect); override; // @addr 0x00484A44 @note "MulLight is unimplemented."
  end;

implementation

uses GR_Main, GR_DX, GI_Main, EC_Mem, Classes, SysUtils, Math;

{ @routine $484310 TCircleGI_Create }
constructor TCircleGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := circle_fit_outline;
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  FillColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  Center := Classes.Point(0, 0);
  Radius := 10;
  ShrLightInner := 1;
  ShrLightOuter := 0;
  LightBufferDirty := True;
end;
{ @end $484310 }

{ @routine $4843C8 TCircleGI_Destroy }
destructor TCircleGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4843C8 }

{ @routine $4843F0 TCircleGI_Clear }
procedure TCircleGI.Clear;
begin
  Kind := circle_fit_outline;
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  FillColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  Center := Classes.Point(0, 0);
  Radius := 10;
  ShrLightInner := 1;
  ShrLightOuter := 0;
  LightBufferDirty := True;
  if LightBuffer <> nil then
  begin
    LightBuffer.Free;
    LightBuffer := nil;
  end;
  inherited Clear;
end;
{ @end $4843F0 }

{ @routine $484494 TCircleGI_SetKind }
procedure TCircleGI.SetKind(Value: TCircleKindGI);
begin
  if Value = Kind then Exit;
  Kind := Value;
  if (Kind = circle_shift_light) or (Kind = circle_multiply_light) then
  begin
    if LightBuffer = nil then LightBuffer := TGraphBufGR.Create(False);
  end
  else
    if LightBuffer <> nil then
    begin
      LightBuffer.Free;
      LightBuffer := nil;
    end;
  LightBufferDirty := True;
  Invalidate;
end;
{ @end $484494 }

{ @routine $484500 TCircleGI_SetColor }
procedure TCircleGI.SetColor(Value: Cardinal);
begin
  if Color = Value then Exit;
  Color := Value;
  Invalidate;
end;
{ @end $484500 }

{ @routine $484520 TCircleGI_SetFillColor }
procedure TCircleGI.SetFillColor(Value: Cardinal);
begin
  if FillColor = Value then Exit;
  FillColor := Value;
  Invalidate;
end;
{ @end $484520 }

{ @routine $484540 TCircleGI_SetCenter }
procedure TCircleGI.SetCenter(Value: TPoint);
begin
  if (Center.X = Value.X) and (Center.Y = Value.Y) then Exit;
  Center := Value;
  LightBufferDirty := True;
  Invalidate;
end;
{ @end $484540 }

{ @routine $48458C TCircleGI_SetRadius }
procedure TCircleGI.SetRadius(Value: Integer);
begin
  if Radius = Value then Exit;
  Radius := Value;
  LightBufferDirty := True;
  Invalidate;
end;
{ @end $48458C }

{ @routine $4845B0 TCircleGI_SetShrLightInner }
procedure TCircleGI.SetShrLightInner(Value: Byte);
begin
  if ShrLightInner = Value then Exit;
  ShrLightInner := Value;
  LightBufferDirty := True;
  Invalidate;
end;
{ @end $4845B0 }

{ @routine $4845D4 TCircleGI_SetShrLightOuter }
procedure TCircleGI.SetShrLightOuter(Value: Byte);
begin
  if ShrLightOuter = Value then Exit;
  ShrLightOuter := Value;
  LightBufferDirty := True;
  Invalidate;
end;
{ @end $4845D4 }

{ @routine $4845F8 TCircleGI_SetSize }
procedure TCircleGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  LightBufferDirty := True;
end;
{ @end $4845F8 }

{ @routine $484620 TCircleGI_SetActive }
procedure TCircleGI.SetActive(Enabled: Boolean);
begin
  inherited SetActive(Enabled);
  if (not Active) and ((Kind = circle_shift_light) or (Kind = circle_multiply_light)) and (LightBuffer <> nil) then LightBuffer.Clear;
end;
{ @end $484620 }

{ @routine $484658 TCircleGI_OnActivate }
procedure TCircleGI.OnActivate;
begin
  inherited OnActivate;
  LightBufferDirty := True;
end;
{ @end $484658 }

{ @routine $48466C TCircleGI_OnDeactivate }
procedure TCircleGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if LightBuffer <> nil then LightBuffer.Clear;
end;
{ @end $48466C }

{ @routine $484688 TCircleGI_LoadFromConfigPath }
procedure TCircleGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadShapeProperties(Block);
end;
{ @end $484688 }

{ @routine $4846B4 TCircleGI_LoadFromBlock }
procedure TCircleGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadShapeProperties(Block);
end;
{ @end $4846B4 }

{ @routine $4846D0 TCircleGI_LoadShapeProperties }
procedure TCircleGI.LoadShapeProperties(Block: TBlockParEC);
var Text: WideString;
begin
  if Block.CountParams('Kind') > 0 then
  begin
    Text := Block.GetParam('Kind');
    if Text = 'Simple' then SetKind(circle_fit_outline)
    else if Text = 'Circle' then SetKind(circle_outline)
    else if Text = 'Fill' then SetKind(circle_fit_fill)
    else if Text = 'ShrLight' then SetKind(circle_shift_light)
    else if Text = 'MulLight' then SetKind(circle_multiply_light);
  end;
  if Block.CountParams('Color') > 0 then SetColor(GetColorGI(Block.GetParam('Color')));
  if Block.CountParams('ColorFill') > 0 then SetFillColor(GetColorGI(Block.GetParam('ColorFill')));
  if Block.CountParams('Radius') > 0 then SetRadius(StrToInt(Block.GetParam('Radius')));
  if Block.CountParams('Center') > 0 then SetCenter(GetPointGI(Block.GetParam('Center')));
  if Block.CountParams('ShrLightInner') > 0 then SetShrLightInner(StrToInt(Block.GetParam('ShrLightInner')));
  if Block.CountParams('ShrLightOuter') > 0 then SetShrLightOuter(StrToInt(Block.GetParam('ShrLightOuter')));
end;
{ @end $4846D0 }

{ @routine $484A44 TCircleGI_Draw }
procedure TCircleGI.Draw(ClipRect: TRect);
var R, X, Y, Width, Height: Integer; Bounds: TRect;
begin
  if Kind = circle_fit_outline then
  begin
    R := Min(HitTestBounds.Bottom - HitTestBounds.Top, HitTestBounds.Right - HitTestBounds.Left) div 2;
    if R > 0 then
      if HardwareRenderingEnabled then
        DrawCircle((HitTestBounds.Right + HitTestBounds.Left) div 2,
          (HitTestBounds.Bottom + HitTestBounds.Top) div 2, R, Color565ToArgb(Color), 255, 0, @ClipRect)
      else ScreenRenderBuffer.DrawAntialiasedCircle16(Classes.Point(
        (HitTestBounds.Bottom + HitTestBounds.Top) div 2,
        (HitTestBounds.Right + HitTestBounds.Left) div 2), R, Color, ClipRect);
  end
  else if Kind = circle_outline then
  begin
    if Radius > 0 then
      if HardwareRenderingEnabled then
        DrawCircle(Center.X, Center.Y, Radius, Color565ToArgb(Color), 255, 0, @ClipRect)
      else ScreenRenderBuffer.DrawAntialiasedCircle16(Center, Radius, Color, ClipRect);
  end
  else if Kind = circle_fit_fill then
  begin
    R := Min(HitTestBounds.Bottom - HitTestBounds.Top, HitTestBounds.Right - HitTestBounds.Left) div 2;
    if R > 0 then
      if HardwareRenderingEnabled then
        DrawCircle((HitTestBounds.Bottom + HitTestBounds.Top) div 2,
          (HitTestBounds.Right + HitTestBounds.Left) div 2, R, Color565ToArgb(Color), 255, 1, @ClipRect)
      else ScreenRenderBuffer.DrawCircle16(Classes.Point(
        (HitTestBounds.Bottom + HitTestBounds.Top) div 2,
        (HitTestBounds.Right + HitTestBounds.Left) div 2), R, Color, FillColor, ClipRect);
  end
  else if Kind = circle_shift_light then
  begin
    if HardwareRenderingEnabled then
    begin
      if Radius > 0 then
      begin
        if Center.Y - Radius > ClipRect.Top then
          DrawColoredRect(ClipRect.Left, ClipRect.Top, ClipRect.Right - ClipRect.Left,
            Center.Y - Radius - ClipRect.Top, 0, 127, True, @ClipRect);
        if Center.Y + Radius < ClipRect.Bottom then
          DrawColoredRect(ClipRect.Left, Center.Y + Radius, ClipRect.Right - ClipRect.Left,
            ClipRect.Bottom - (Center.Y + Radius), 0, 127, True, @ClipRect);
        if Center.X - Radius > ClipRect.Left then
        begin
          X := ClipRect.Left;
          Y := Center.Y - Radius;
          if Y < ClipRect.Top then Y := ClipRect.Top;
          Width := Center.X - Radius - X;
          Height := Center.Y + Radius - Y;
          if Y + Height > ClipRect.Bottom then Height := ClipRect.Bottom - Y;
          DrawColoredRect(X, Y, Width, Height, 0, 127, True, @ClipRect);
        end;
        if Center.X + Radius < ClipRect.Right then
        begin
          X := Center.X + Radius;
          Y := Center.Y - Radius;
          if Y < ClipRect.Top then Y := ClipRect.Top;
          Width := ClipRect.Right - X;
          if X + Width > ClipRect.Right then Width := ClipRect.Right - X;
          Height := Center.Y + Radius - Y;
          if Y + Height > ClipRect.Bottom then Height := ClipRect.Bottom - Y;
          DrawColoredRect(X, Y, Width, Height, 0, 127, True, @ClipRect);
        end;
        DrawCircle(Center.X, Center.Y, Radius, 0, 127, 2, @ClipRect);
      end;
    end
    else
    begin
      if (LightBufferDirty = True) or (LightBuffer.GetPixels = nil) then
      begin
        LightBuffer.AllocateGrayscale(ClientSize.X, ClientSize.Y);
        LightBuffer.FillPixels(ShrLightOuter);
        if Radius > 0 then
        begin
          Bounds.Left := 0;
          Bounds.Top := 0;
          Bounds.Right := ClientSize.X;
          Bounds.Bottom := ClientSize.Y;
          LightBuffer.DrawCircle8(Center, Radius, ShrLightInner, ShrLightInner, Bounds);
        end;
        LightBufferDirty := False;
      end;
      Ex_OKGR_ShrLightMask_16(AddPointerOffset(ScreenRenderBuffer.GetPixels,
        ScreenRenderBuffer.PitchBytes * ClipRect.Top + ClipRect.Left * 2), ScreenRenderBuffer.PitchBytes,
        AddPointerOffset(LightBuffer.GetPixels, (ClipRect.Top - HitTestBounds.Top) * LightBuffer.PitchBytes +
          (ClipRect.Left - HitTestBounds.Left)), LightBuffer.PitchBytes,
        ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top);
    end;
  end
  else if Kind = circle_multiply_light then
  begin
    // The native branch retains only this renderer test.
    if HardwareRenderingEnabled then begin end;
  end;
end;
{ @end $484A44 }

end.
