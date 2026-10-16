unit GI_Frame;

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TFrameBorderKindGI = (frame_no_border=0, frame_rect_border=1); // @size 0x01
  TFrameGI = class(TObjectGI) // @size 0x130
  public
    Kind: TFrameBorderKindGI; // @offset 0x120
    Color: Cardinal; // @offset 0x124
    FillColor: Cardinal; // @offset 0x128
    Fill: Boolean; // @offset 0x12C
    FillAlpha: Byte; // @offset 0x12D

    constructor Create(Owner: TObjectGI); // @addr 0x00491B50
    destructor Destroy; override; // @addr 0x00491B9C
    procedure Clear; override; // @addr 0x00491BC4 @note "Preserves fill and color fields."
    procedure SetKind(Value: TFrameBorderKindGI); // @addr 0x00491BD4
    procedure SetColor(Value: Cardinal); // @addr 0x00491BF4
    procedure SetFillColor(Value: Cardinal); // @addr 0x00491C14
    procedure SetFill(Value: Boolean); // @addr 0x00491C34
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x00491C54
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00491C80
    procedure LoadFrameProperties(Block: TBlockParEC); // @addr 0x00491C9C
    procedure Draw(ClipRect: TRect); override; // @addr 0x00491E38 @note "Fill is independent of Kind. FillAlpha values other than 255 all produce alpha 64."
  end;

implementation

uses Classes, EC_Mem, GI_Main, GR_DX, GR_Main;

{ @routine $491B50 TFrameGI_Create }
constructor TFrameGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := frame_no_border;
  Fill := False;
  FillAlpha := 255;
end;
{ @end $491B50 }

{ @routine $491B9C TFrameGI_Destroy }
destructor TFrameGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $491B9C }

{ @routine $491BC4 TFrameGI_Clear }
procedure TFrameGI.Clear;
begin
  Kind := frame_no_border;
  inherited Clear;
end;
{ @end $491BC4 }

{ @routine $491BD4 TFrameGI_SetKind }
procedure TFrameGI.SetKind(Value: TFrameBorderKindGI);
begin
  if Kind = Value then Exit;
  Kind := Value;
  Invalidate;
end;
{ @end $491BD4 }

{ @routine $491BF4 TFrameGI_SetColor }
procedure TFrameGI.SetColor(Value: Cardinal);
begin
  if Color = Value then Exit;
  Color := Value;
  Invalidate;
end;
{ @end $491BF4 }

{ @routine $491C14 TFrameGI_SetFillColor }
procedure TFrameGI.SetFillColor(Value: Cardinal);
begin
  if FillColor = Value then Exit;
  FillColor := Value;
  Invalidate;
end;
{ @end $491C14 }

{ @routine $491C34 TFrameGI_SetFill }
procedure TFrameGI.SetFill(Value: Boolean);
begin
  if Fill = Value then Exit;
  Fill := Value;
  Invalidate;
end;
{ @end $491C34 }

{ @routine $491C54 TFrameGI_LoadFromConfigPath }
procedure TFrameGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadFrameProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $491C54 }

{ @routine $491C80 TFrameGI_LoadFromBlock }
procedure TFrameGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadFrameProperties(Block);
end;
{ @end $491C80 }

{ @routine $491C9C TFrameGI_LoadFrameProperties }
procedure TFrameGI.LoadFrameProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Kind') > 0 then
  begin
    if Block.GetParam('Kind') = 'Hide' then Kind := frame_no_border
    else if Block.GetParam('Kind') = 'Rect' then Kind := frame_rect_border;
  end;
  if Block.CountParams('Color') > 0 then SetColor(GetColorGI(Block.GetParam('Color')));
  if Block.CountParams('ColorFill') > 0 then SetFillColor(GetColorGI(Block.GetParam('ColorFill')));
  if Block.CountParams('Fill') > 0 then SetFill(ParseEnabledNameGI(Block.GetParam('Fill')));
end;
{ @end $491C9C }

{ @routine $491E38 TFrameGI_Draw }
procedure TFrameGI.Draw(ClipRect: TRect);
begin
  if Fill then
  begin
    if HardwareRenderingEnabled then
    begin
      if FillAlpha = 255 then
        DrawColoredRect(ClipRect.Left, ClipRect.Top, ClipRect.Right - ClipRect.Left,
          ClipRect.Bottom - ClipRect.Top, Color565ToArgb(FillColor), 255, True, @ClipRect)
      else
        DrawColoredRect(ClipRect.Left, ClipRect.Top, ClipRect.Right - ClipRect.Left,
          ClipRect.Bottom - ClipRect.Top, Color565ToArgb(FillColor), 64, True, @ClipRect);
    end
    else
    begin
      if FillAlpha = 255 then
        Ex_OKGR_Fill_WORD(AddPointerOffset(ScreenRenderBuffer.GetPixels,
          ScreenRenderBuffer.PitchBytes * ClipRect.Top + ClipRect.Left * 2),
          ScreenRenderBuffer.PitchBytes, ClipRect.Right - ClipRect.Left,
          ClipRect.Bottom - ClipRect.Top, FillColor)
      else
        ScreenRenderBuffer.DrawAlphaTrapezium16(HitTestBounds.Left, HitTestBounds.Right,
          HitTestBounds.Top, HitTestBounds.Left, HitTestBounds.Right, HitTestBounds.Bottom,
          FillColor, 64, ClipRect);
    end;
  end;
  if Kind = frame_rect_border then
  begin
    if HardwareRenderingEnabled then
    begin
      DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - 1,
        HitTestBounds.Top, Color, 255, @ClipRect);
      DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Bottom - 1, HitTestBounds.Right - 1,
        HitTestBounds.Bottom - 1, Color, 255, @ClipRect);
      DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Left,
        HitTestBounds.Bottom - 1, Color, 255, @ClipRect);
      DrawAlphaLine(HitTestBounds.Right - 1, HitTestBounds.Top, HitTestBounds.Right - 1,
        HitTestBounds.Bottom - 1, Color, 255, @ClipRect);
    end
    else
    begin
      ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Left, HitTestBounds.Top),
        Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Top), Color, ClipRect);
      ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Left, HitTestBounds.Bottom - 1),
        Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1), Color, ClipRect);
      ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Left, HitTestBounds.Top),
        Classes.Point(HitTestBounds.Left, HitTestBounds.Bottom - 1), Color, ClipRect);
      ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Top),
        Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1), Color, ClipRect);
    end;
  end;
end;
{ @end $491E38 }

end.
