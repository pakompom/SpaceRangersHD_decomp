unit GI_Line;
// Unit bracket (inferred): .text 0x00484E20..0x004851CD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TLineGI = class(TObjectGI) // @size 0x124
  public
    Color: Cardinal; // @offset 0x120

    constructor Create(Owner: TObjectGI); // @addr 0x484F3C @ida "TLineGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x484FA4 @ida "void __usercall $name(TLineGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x484FD8
    procedure SetColor(Value: Cardinal); // @addr 0x485008
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x485040
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x485078
    procedure LoadLineProperties(Block: TBlockParEC); // @addr 0x4850A0
    procedure Draw(ClipRect: TRect); override; // @addr 0x485124 @ida "void __usercall $name(TLineGI *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

implementation

uses Classes, GI_Main, GR_DX, GR_Main;

{ @routine $484F3C TLineGI_Create }
constructor TLineGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
end;
{ @end $484F3C }

{ @routine $484FA4 TLineGI_Destroy }
destructor TLineGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $484FA4 }

{ @routine $484FD8 TLineGI_Clear }
procedure TLineGI.Clear;
begin
  Color := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  inherited Clear;
end;
{ @end $484FD8 }

{ @routine $485008 TLineGI_SetColor }
procedure TLineGI.SetColor(Value: Cardinal);
begin
  if Color <> Value then
  begin
    Color := Value;
    Invalidate;
  end;
end;
{ @end $485008 }

{ @routine $485040 TLineGI_LoadFromConfigPath }
procedure TLineGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadLineProperties(Block);
end;
{ @end $485040 }

{ @routine $485078 TLineGI_LoadFromBlock }
procedure TLineGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadLineProperties(Block);
end;
{ @end $485078 }

{ @routine $4850A0 TLineGI_LoadLineProperties }
procedure TLineGI.LoadLineProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Color') > 0 then Color := GetColorGI(Block.GetParam('Color'));
end;
{ @end $4850A0 }

{ @routine $485124 TLineGI_Draw }
procedure TLineGI.Draw(ClipRect: TRect);
begin
  if HardwareRenderingEnabled then
    DrawAlphaLine(HitTestBounds.Left, HitTestBounds.Top, HitTestBounds.Right - 1,
      HitTestBounds.Bottom - 1, Color565ToArgb(Color), 255, @ClipRect)
  else
    ScreenRenderBuffer.DrawLine16Clipped(Classes.Point(HitTestBounds.Left, HitTestBounds.Top),
      Classes.Point(HitTestBounds.Right - 1, HitTestBounds.Bottom - 1), Color, ClipRect);
end;
{ @end $485124 }

end.
