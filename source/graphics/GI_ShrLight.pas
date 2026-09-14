unit GI_ShrLight;
// Unit bracket (inferred): .text 0x00483EF8..0x004845DA; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class ownership follows reference/unit_ownership.json.

interface

uses EC_BlockPar, GI_MessageLoop, GR_GraphBuf, Types;

type
  TShrLightKindGI = (slkAll=0, slkBuffer=1); // @size $01
  TShrLightGI = class(TObjectGI) // @size $138
  public
    Kind: TShrLightKindGI; // @offset $120
    LightShift: Integer; // @offset $124
    LightBuffer: TGraphBufGR; // @offset $128 Owned grayscale mask when Kind=slkBuffer.
    constructor Create(Owner: TObjectGI); // @addr $484018 @ida "TShrLightGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr $484078 @ida "void __usercall $name(TShrLightGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr $4840D0
    procedure SetKind(Value: TShrLightKindGI); // @addr $484120
    procedure SetLightShift(Value: Integer); // @addr $4841D0
    procedure SetSize(Size: TPoint); override; // @addr $484208 @ida "void __usercall $name(TShrLightGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $48425C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $484290
    procedure LoadLightProperties(Block: TBlockParEC); // @addr $4842B8
    procedure Draw(ClipRect: TRect); override; // @addr $4843DC @ida "void __usercall $name(TShrLightGI *Self@<eax>, TRect *ClipRect@<edx>);"
  end;

implementation

uses EC_Mem, GR_DX, GR_Main, SysUtils;

{ @routine $484018 TShrLightGI_Create }
constructor TShrLightGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := slkAll;
  LightShift := 1;
end;
{ @end $484018 }

{ @routine $484078 TShrLightGI_Destroy }
destructor TShrLightGI.Destroy;
begin
  if LightBuffer <> nil then
  begin
    LightBuffer.Free;
    LightBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $484078 }

{ @routine $4840D0 TShrLightGI_Clear }
procedure TShrLightGI.Clear;
begin
  if LightBuffer <> nil then
  begin
    LightBuffer.Free;
    LightBuffer := nil;
  end;
  Kind := slkAll;
  LightShift := 1;
  inherited Clear;
end;
{ @end $4840D0 }

{ @routine $484120 TShrLightGI_SetKind }
procedure TShrLightGI.SetKind(Value: TShrLightKindGI);
begin
  if Kind <> Value then
  begin
    Kind := Value;
    if Kind = slkBuffer then
    begin
      LightBuffer := TGraphBufGR.Create(False);
      LightBuffer.AllocateGrayscale(ClientSize.X, ClientSize.Y);
      LightBuffer.FillPixels(0);
    end
    else if LightBuffer <> nil then
    begin
      LightBuffer.Free;
      LightBuffer := nil;
    end;
    Invalidate;
  end;
end;
{ @end $484120 }

{ @routine $4841D0 TShrLightGI_SetLightShift }
procedure TShrLightGI.SetLightShift(Value: Integer);
begin
  if LightShift <> Value then
  begin
    LightShift := Value;
    Invalidate;
  end;
end;
{ @end $4841D0 }

{ @routine $484208 TShrLightGI_SetSize }
procedure TShrLightGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if Kind = slkBuffer then
  begin
    LightBuffer.AllocateGrayscale(Size.X, Size.Y);
    LightBuffer.FillPixels(0);
  end;
end;
{ @end $484208 }

{ @routine $48425C TShrLightGI_LoadFromConfigPath }
procedure TShrLightGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadLightProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $48425C }

{ @routine $484290 TShrLightGI_LoadFromBlock }
procedure TShrLightGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadLightProperties(Block);
end;
{ @end $484290 }

{ @routine $4842B8 TShrLightGI_LoadLightProperties }
procedure TShrLightGI.LoadLightProperties(Block: TBlockParEC);
var Text: WideString;
begin
  if Block.CountParams('ShrLight') > 0 then
    SetLightShift(StrToInt(AnsiString(Block.GetParam('ShrLight'))));
  if Block.CountParams('Kind') > 0 then
  begin
    Text := Block.GetParam('Kind');
    if Text = 'All' then SetKind(slkAll)
    else if Text = 'Buf' then SetKind(slkBuffer);
  end;
end;
{ @end $4842B8 }

{ @routine $4843DC TShrLightGI_Draw }
procedure TShrLightGI.Draw(ClipRect: TRect);
var Alpha: Integer;
begin
  if HardwareRenderingEnabled then
  begin
    Alpha := 255;
    if LightShift = 2 then Alpha := 128
    else if LightShift = 0 then Exit
    else if LightShift = -2 then Alpha := 64
    else AppendLogLineThreadSafe('FShrLight=' + IntToStr(LightShift));
    if Kind = slkBuffer then
      DrawColoredRect(0, 0, GameScreenWidth, GameScreenHeight, 0, Alpha, True, @ClipRect)
    else if Kind = slkAll then
      DrawColoredRect(0, 0, GameScreenWidth, GameScreenHeight, 0, Alpha, True, @ClipRect);
  end
  else if Kind = slkBuffer then
    Ex_OKGR_ShrLightMask_16(AddPointerOffset(ScreenRenderBuffer.GetPixels,
      ScreenRenderBuffer.PitchBytes * ClipRect.Top + ClipRect.Left * 2), ScreenRenderBuffer.PitchBytes,
      AddPointerOffset(LightBuffer.GetPixels,
        (ClipRect.Top - HitTestBounds.Top) * LightBuffer.PitchBytes + (ClipRect.Left - HitTestBounds.Left)),
      LightBuffer.PitchBytes, ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top)
  else if Kind = slkAll then ScreenRenderBuffer.ShiftLight16(LightShift, ClipRect);
end;
{ @end $4843DC }

end.
