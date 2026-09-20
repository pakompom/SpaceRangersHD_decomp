unit GI_ShrLight;
// Unit bracket (inferred): .text 0x004AFA00..0x004B00E2; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
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
    constructor Create(Owner: TObjectGI); // @addr $4AFB20
    destructor Destroy; override; // @addr $4AFB80
    procedure Clear; override; // @addr $4AFBD8
    procedure SetKind(Value: TShrLightKindGI); // @addr $4AFC28
    procedure SetLightShift(Value: Integer); // @addr $4AFCD8
    procedure SetSize(Size: TPoint); override; // @addr $4AFD10
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4AFD64
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $4AFD98
    procedure LoadLightProperties(Block: TBlockParEC); // @addr $4AFDC0
    procedure Draw(ClipRect: TRect); override; // @addr $4AFEE4
  end;

implementation

uses EC_Mem, GR_DX, GR_Main, SysUtils;

{ @routine $4AFB20 TShrLightGI_Create }
constructor TShrLightGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := slkAll;
  LightShift := 1;
end;
{ @end $4AFB20 }

{ @routine $4AFB80 TShrLightGI_Destroy }
destructor TShrLightGI.Destroy;
begin
  if LightBuffer <> nil then
  begin
    LightBuffer.Free;
    LightBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $4AFB80 }

{ @routine $4AFBD8 TShrLightGI_Clear }
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
{ @end $4AFBD8 }

{ @routine $4AFC28 TShrLightGI_SetKind }
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
{ @end $4AFC28 }

{ @routine $4AFCD8 TShrLightGI_SetLightShift }
procedure TShrLightGI.SetLightShift(Value: Integer);
begin
  if LightShift <> Value then
  begin
    LightShift := Value;
    Invalidate;
  end;
end;
{ @end $4AFCD8 }

{ @routine $4AFD10 TShrLightGI_SetSize }
procedure TShrLightGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if Kind = slkBuffer then
  begin
    LightBuffer.AllocateGrayscale(Size.X, Size.Y);
    LightBuffer.FillPixels(0);
  end;
end;
{ @end $4AFD10 }

{ @routine $4AFD64 TShrLightGI_LoadFromConfigPath }
procedure TShrLightGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadLightProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4AFD64 }

{ @routine $4AFD98 TShrLightGI_LoadFromBlock }
procedure TShrLightGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadLightProperties(Block);
end;
{ @end $4AFD98 }

{ @routine $4AFDC0 TShrLightGI_LoadLightProperties }
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
{ @end $4AFDC0 }

{ @routine $4AFEE4 TShrLightGI_Draw }
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
{ @end $4AFEE4 }

end.
