unit GI_Line;
// Unit bracket (inferred): .text 0x004AAE24..0x004AB1D1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TLineGI = class(TObjectGI) // @size 0x124
  public
    Color: Cardinal; // @offset 0x120

    constructor Create(Owner: TObjectGI); // @addr 0x4AAF40
    destructor Destroy; override; // @addr 0x4AAFA8
    procedure Clear; override; // @addr 0x4AAFDC
    procedure SetColor(Value: Cardinal); // @addr 0x4AB00C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4AB044
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4AB07C
    procedure LoadLineProperties(Block: TBlockParEC); // @addr 0x4AB0A4
    procedure Draw(ClipRect: TRect); override; // @addr 0x4AB128
  end;

implementation

uses Classes, GI_Main, GR_DX, GR_Main;

{ @routine $4AAF40 TLineGI_Create }
constructor TLineGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
end;
{ @end $4AAF40 }

{ @routine $4AAFA8 TLineGI_Destroy }
destructor TLineGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4AAFA8 }

{ @routine $4AAFDC TLineGI_Clear }
procedure TLineGI.Clear;
begin
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  inherited Clear;
end;
{ @end $4AAFDC }

{ @routine $4AB00C TLineGI_SetColor }
procedure TLineGI.SetColor(Value: Cardinal);
begin
  if Color <> Value then
  begin
    Color := Value;
    Invalidate;
  end;
end;
{ @end $4AB00C }

{ @routine $4AB044 TLineGI_LoadFromConfigPath }
procedure TLineGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadLineProperties(Block);
end;
{ @end $4AB044 }

{ @routine $4AB07C TLineGI_LoadFromBlock }
procedure TLineGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadLineProperties(Block);
end;
{ @end $4AB07C }

{ @routine $4AB0A4 TLineGI_LoadLineProperties }
procedure TLineGI.LoadLineProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Color') > 0 then Color := GetColorGI(Block.GetParam('Color'));
end;
{ @end $4AB0A4 }

{ @routine $4AB128 TLineGI_Draw }
procedure TLineGI.Draw(ClipRect: TRect);
begin
  if HardwareRenderingEnabled then
    DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - 1,
      HitTestBounds.Bottom - 1, Color565ToArgb(Color), 255, @ClipRect)
  else
    ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Left, HitTestBounds.Top),
      Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1), Color, ClipRect);
end;
{ @end $4AB128 }

end.
