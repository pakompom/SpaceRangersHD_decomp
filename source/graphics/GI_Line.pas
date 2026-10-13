unit GI_Line;

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TLineGI = class(TObjectGI) // @size 0x124
  public
    Color: Cardinal; // @offset 0x120

    constructor Create(Owner: TObjectGI); // @addr 0x00492244
    destructor Destroy; override; // @addr 0x00492294
    procedure Clear; override; // @addr 0x004922BC
    procedure SetColor(Value: Cardinal); // @addr 0x004922E4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x00492304
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x00492330
    procedure LoadLineProperties(Block: TBlockParEC); // @addr 0x0049234C
    procedure Draw(ClipRect: TRect); override; // @addr 0x004923C4
  end;

implementation

uses Classes, GI_Main, GR_DX, GR_Main;

{ @routine $492244 TLineGI_Create }
constructor TLineGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
end;
{ @end $492244 }

{ @routine $492294 TLineGI_Destroy }
destructor TLineGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $492294 }

{ @routine $4922BC TLineGI_Clear }
procedure TLineGI.Clear;
begin
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  inherited Clear;
end;
{ @end $4922BC }

{ @routine $4922E4 TLineGI_SetColor }
procedure TLineGI.SetColor(Value: Cardinal);
begin
  if Color = Value then Exit;
  Color := Value;
  Invalidate;
end;
{ @end $4922E4 }

{ @routine $492304 TLineGI_LoadFromConfigPath }
procedure TLineGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadLineProperties(Block);
end;
{ @end $492304 }

{ @routine $492330 TLineGI_LoadFromBlock }
procedure TLineGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadLineProperties(Block);
end;
{ @end $492330 }

{ @routine $49234C TLineGI_LoadLineProperties }
procedure TLineGI.LoadLineProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Color') > 0 then Color := GetColorGI(Block.GetParam('Color'));
end;
{ @end $49234C }

{ @routine $4923C4 TLineGI_Draw }
procedure TLineGI.Draw(ClipRect: TRect);
begin
  if HardwareRenderingEnabled then
    DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - 1,
      HitTestBounds.Bottom - 1, Color565ToArgb(Color), 255, @ClipRect)
  else
    ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Left, HitTestBounds.Top),
      Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1), Color, ClipRect);
end;
{ @end $4923C4 }

end.
