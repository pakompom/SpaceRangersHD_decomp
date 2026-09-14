unit GI_Circle;
// Unit bracket (inferred): .text 0x00473C04..0x00474C8B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, GR_GraphBuf, Types;

type
  TCircleKindGI = (ckSimple=0, ckCircle=1, ckFill=2, ckShrLight=3, ckMulLight=4); // @size 0x01
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

    constructor Create(Owner: TObjectGI); // @addr 0x473D24 @ida "TCircleGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x473E00 @ida "void __usercall $name(TCircleGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x473E34
    procedure SetKind(Value: TCircleKindGI); // @addr 0x473F00
    procedure SetColor(Value: Cardinal); // @addr 0x473FA8
    procedure SetFillColor(Value: Cardinal); // @addr 0x473FE0
    procedure SetCenter(Value: TPoint); // @addr 0x474018 @ida "void __usercall $name(TCircleGI *Self@<eax>, TPoint *Value@<edx>);"
    procedure SetRadius(Value: Integer); // @addr 0x474078
    procedure SetShrLightInner(Value: Byte); // @addr 0x4740B8
    procedure SetShrLightOuter(Value: Byte); // @addr 0x4740F8
    procedure SetSize(Size: TPoint); override; // @addr 0x474138 @ida "void __usercall $name(TCircleGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure SetActive(Enabled: Boolean); override; // @addr 0x474168
    procedure OnActivate; override; // @addr 0x4741C0
    procedure OnDeactivate; override; // @addr 0x4741DC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x474208
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x474240
    procedure LoadShapeProperties(Block: TBlockParEC); // @addr 0x474268
    procedure Draw(ClipRect: TRect); override; // @addr 0x4745F4 @ida "void __usercall $name(TCircleGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "MulLight is unimplemented."
  end;

implementation

uses GR_Main, GR_DX, GI_Main, EC_Mem, Classes, SysUtils, Math;

{ @routine $473D24 TCircleGI_Create }
constructor TCircleGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := ckSimple;
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  FillColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  Center := Classes.Point(0, 0);
  Radius := 10;
  ShrLightInner := 1;
  ShrLightOuter := 0;
  LightBufferDirty := True;
end;
{ @end $473D24 }

{ @routine $473E00 TCircleGI_Destroy }
destructor TCircleGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $473E00 }

{ @routine $473E34 TCircleGI_Clear }
procedure TCircleGI.Clear;
begin
  Kind := ckSimple;
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
{ @end $473E34 }

{ @routine $473F00 TCircleGI_SetKind }
procedure TCircleGI.SetKind(Value: TCircleKindGI);
begin
  if Value <> Kind then
  begin
    Kind := Value;
    if (Kind = ckShrLight) or (Kind = ckMulLight) then
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
end;
{ @end $473F00 }

{ @routine $473FA8 TCircleGI_SetColor }
procedure TCircleGI.SetColor(Value: Cardinal);
begin
  if Color <> Value then
  begin
    Color := Value;
    Invalidate;
  end;
end;
{ @end $473FA8 }

{ @routine $473FE0 TCircleGI_SetFillColor }
procedure TCircleGI.SetFillColor(Value: Cardinal);
begin
  if FillColor <> Value then
  begin
    FillColor := Value;
    Invalidate;
  end;
end;
{ @end $473FE0 }

{ @routine $474018 TCircleGI_SetCenter }
procedure TCircleGI.SetCenter(Value: TPoint);
begin
  if (Center.X <> Value.X) or (Center.Y <> Value.Y) then
  begin
    Center := Value;
    LightBufferDirty := True;
    Invalidate;
  end;
end;
{ @end $474018 }

{ @routine $474078 TCircleGI_SetRadius }
procedure TCircleGI.SetRadius(Value: Integer);
begin
  if Radius <> Value then
  begin
    Radius := Value;
    LightBufferDirty := True;
    Invalidate;
  end;
end;
{ @end $474078 }

{ @routine $4740B8 TCircleGI_SetShrLightInner }
procedure TCircleGI.SetShrLightInner(Value: Byte);
begin
  if ShrLightInner <> Value then
  begin
    ShrLightInner := Value;
    LightBufferDirty := True;
    Invalidate;
  end;
end;
{ @end $4740B8 }

{ @routine $4740F8 TCircleGI_SetShrLightOuter }
procedure TCircleGI.SetShrLightOuter(Value: Byte);
begin
  if ShrLightOuter <> Value then
  begin
    ShrLightOuter := Value;
    LightBufferDirty := True;
    Invalidate;
  end;
end;
{ @end $4740F8 }

{ @routine $474138 TCircleGI_SetSize }
procedure TCircleGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  LightBufferDirty := True;
end;
{ @end $474138 }

{ @routine $474168 TCircleGI_SetActive }
procedure TCircleGI.SetActive(Enabled: Boolean);
begin
  inherited SetActive(Enabled);
  if (not Active) and ((Kind = ckShrLight) or (Kind = ckMulLight)) then
    if LightBuffer <> nil then LightBuffer.Clear;
end;
{ @end $474168 }

{ @routine $4741C0 TCircleGI_OnActivate }
procedure TCircleGI.OnActivate;
begin
  inherited OnActivate;
  LightBufferDirty := True;
end;
{ @end $4741C0 }

{ @routine $4741DC TCircleGI_OnDeactivate }
procedure TCircleGI.OnDeactivate;
begin
  inherited OnDeactivate;
  if LightBuffer <> nil then LightBuffer.Clear;
end;
{ @end $4741DC }

{ @routine $474208 TCircleGI_LoadFromConfigPath }
procedure TCircleGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadShapeProperties(Block);
end;
{ @end $474208 }

{ @routine $474240 TCircleGI_LoadFromBlock }
procedure TCircleGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadShapeProperties(Block);
end;
{ @end $474240 }

{ @routine $474268 TCircleGI_LoadShapeProperties }
procedure TCircleGI.LoadShapeProperties(Block: TBlockParEC);
var Text: WideString;
begin
  if Block.CountParams('Kind') > 0 then
  begin
    Text := Block.GetParam('Kind');
    if Text = 'Simple' then SetKind(ckSimple)
    else if Text = 'Circle' then SetKind(ckCircle)
    else if Text = 'Fill' then SetKind(ckFill)
    else if Text = 'ShrLight' then SetKind(ckShrLight)
    else if Text = 'MulLight' then SetKind(ckMulLight);
  end;
  if Block.CountParams('Color') > 0 then SetColor(GetColorGI(Block.GetParam('Color')));
  if Block.CountParams('ColorFill') > 0 then SetFillColor(GetColorGI(Block.GetParam('ColorFill')));
  if Block.CountParams('Radius') > 0 then SetRadius(StrToInt(Block.GetParam('Radius')));
  if Block.CountParams('Center') > 0 then SetCenter(GetPointGI(Block.GetParam('Center')));
  if Block.CountParams('ShrLightInner') > 0 then SetShrLightInner(StrToInt(Block.GetParam('ShrLightInner')));
  if Block.CountParams('ShrLightOuter') > 0 then SetShrLightOuter(StrToInt(Block.GetParam('ShrLightOuter')));
end;
{ @end $474268 }

{ @routine $4745F4 TCircleGI_Draw }
procedure TCircleGI.Draw(ClipRect: TRect);
var R, X, Y, Width, Height: Integer; Bounds: TRect;
begin
  if Kind = ckSimple then
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
  else if Kind = ckCircle then
  begin
    if Radius > 0 then
      if HardwareRenderingEnabled then
        DrawCircle(Center.X, Center.Y, Radius, Color565ToArgb(Color), 255, 0, @ClipRect)
      else ScreenRenderBuffer.DrawAntialiasedCircle16(Center, Radius, Color, ClipRect);
  end
  else if Kind = ckFill then
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
  else if Kind = ckShrLight then
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
  else if Kind = ckMulLight then
  begin
    // The native branch retains only this renderer test.
    if HardwareRenderingEnabled then begin end;
  end;
end;
{ @end $4745F4 }

end.
