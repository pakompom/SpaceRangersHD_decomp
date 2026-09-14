unit GI_Frame;
// Unit bracket (inferred): .text 0x004845F0..0x00484E1E; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TFrameKindGI = (fkHide=0, fkRect=1); // @size 0x01
  TFrameGI = class(TObjectGI) // @size 0x130
  public
    Kind: TFrameKindGI; // @offset 0x120
    Color: Cardinal; // @offset 0x124
    FillColor: Cardinal; // @offset 0x128
    Fill: Boolean; // @offset 0x12C
    FillAlpha: Byte; // @offset 0x12D

    constructor Create(Owner: TObjectGI); // @addr 0x484710 @ida "TFrameGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x484778 @ida "void __usercall $name(TFrameGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4847AC @note "Preserves fill and color fields."
    procedure SetKind(Value: TFrameKindGI); // @addr 0x4847C8
    procedure SetColor(Value: Cardinal); // @addr 0x484800
    procedure SetFillColor(Value: Cardinal); // @addr 0x484838
    procedure SetFill(Value: Boolean); // @addr 0x484870
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4848A8
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4848DC
    procedure LoadFrameProperties(Block: TBlockParEC); // @addr 0x484904
    procedure Draw(ClipRect: TRect); override; // @addr 0x484AB0 @ida "void __usercall $name(TFrameGI *Self@<eax>, TRect *ClipRect@<edx>);" @note "Fill is independent of Kind. FillAlpha values other than 255 all produce alpha 64."
  end;

implementation

uses Classes, EC_Mem, GI_Main, GR_DX, GR_Main;

{ @routine $484710 TFrameGI_Create }
constructor TFrameGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := fkHide;
  Fill := False;
  FillAlpha := 255;
end;
{ @end $484710 }

{ @routine $484778 TFrameGI_Destroy }
destructor TFrameGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $484778 }

{ @routine $4847AC TFrameGI_Clear }
procedure TFrameGI.Clear;
begin
  Kind := fkHide;
  inherited Clear;
end;
{ @end $4847AC }

{ @routine $4847C8 TFrameGI_SetKind }
procedure TFrameGI.SetKind(Value: TFrameKindGI);
begin
  if Kind <> Value then
  begin
    Kind := Value;
    Invalidate;
  end;
end;
{ @end $4847C8 }

{ @routine $484800 TFrameGI_SetColor }
procedure TFrameGI.SetColor(Value: Cardinal);
begin
  if Color <> Value then
  begin
    Color := Value;
    Invalidate;
  end;
end;
{ @end $484800 }

{ @routine $484838 TFrameGI_SetFillColor }
procedure TFrameGI.SetFillColor(Value: Cardinal);
begin
  if FillColor <> Value then
  begin
    FillColor := Value;
    Invalidate;
  end;
end;
{ @end $484838 }

{ @routine $484870 TFrameGI_SetFill }
procedure TFrameGI.SetFill(Value: Boolean);
begin
  if Fill <> Value then
  begin
    Fill := Value;
    Invalidate;
  end;
end;
{ @end $484870 }

{ @routine $4848A8 TFrameGI_LoadFromConfigPath }
procedure TFrameGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadFrameProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4848A8 }

{ @routine $4848DC TFrameGI_LoadFromBlock }
procedure TFrameGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadFrameProperties(Block);
end;
{ @end $4848DC }

{ @routine $484904 TFrameGI_LoadFrameProperties }
procedure TFrameGI.LoadFrameProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Kind') > 0 then
  begin
    if Block.GetParam('Kind') = 'Hide' then Kind := fkHide
    else if Block.GetParam('Kind') = 'Rect' then Kind := fkRect;
  end;
  if Block.CountParams('Color') > 0 then SetColor(GetColorGI(Block.GetParam('Color')));
  if Block.CountParams('ColorFill') > 0 then SetFillColor(GetColorGI(Block.GetParam('ColorFill')));
  if Block.CountParams('Fill') > 0 then SetFill(ParseEnabledNameGI(Block.GetParam('Fill')));
end;
{ @end $484904 }

{ @routine $484AB0 TFrameGI_Draw }
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
  if Kind = fkRect then
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
{ @end $484AB0 }

end.
