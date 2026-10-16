unit GI_ShrLight;

interface

uses EC_BlockPar, GI_MessageLoop, GR_GraphBuf, Types;

type
  TShrLightKindGI = (light_uniform=0, light_masked=1); // @size $01
  TShrLightGI = class(TObjectGI) // @size $138
  public
    Kind: TShrLightKindGI; // @offset $120
    LightShift: Integer; // @offset $124
    LightBuffer: TGraphBufGR; // @offset $128 Owned grayscale mask when Kind=light_masked.
    constructor Create(Owner: TObjectGI); // @addr $49156C
    destructor Destroy; override; // @addr $4915B4
    procedure Clear; override; // @addr $4915F0
    procedure SetKind(Value: TShrLightKindGI); // @addr $491624
    procedure SetLightShift(Value: Integer); // @addr $491694
    procedure SetSize(Size: TPoint); override; // @addr $4916B4
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $4916FC
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $491728
    procedure LoadLightProperties(Block: TBlockParEC); // @addr $491744
    procedure Draw(ClipRect: TRect); override; // @addr $491860
  end;

implementation

uses EC_Mem, GR_DX, GR_Main, SysUtils;

{ @routine $49156C TShrLightGI_Create }
constructor TShrLightGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Kind := light_uniform;
  LightShift := 1;
end;
{ @end $49156C }

{ @routine $4915B4 TShrLightGI_Destroy }
destructor TShrLightGI.Destroy;
begin
  if LightBuffer <> nil then
  begin
    LightBuffer.Free;
    LightBuffer := nil;
  end;
  inherited Destroy;
end;
{ @end $4915B4 }

{ @routine $4915F0 TShrLightGI_Clear }
procedure TShrLightGI.Clear;
begin
  if LightBuffer <> nil then
  begin
    LightBuffer.Free;
    LightBuffer := nil;
  end;
  Kind := light_uniform;
  LightShift := 1;
  inherited Clear;
end;
{ @end $4915F0 }

{ @routine $491624 TShrLightGI_SetKind }
procedure TShrLightGI.SetKind(Value: TShrLightKindGI);
begin
  if Kind = Value then Exit;
  Kind := Value;
  if Kind = light_masked then
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
{ @end $491624 }

{ @routine $491694 TShrLightGI_SetLightShift }
procedure TShrLightGI.SetLightShift(Value: Integer);
begin
  if LightShift = Value then Exit;
  LightShift := Value;
  Invalidate;
end;
{ @end $491694 }

{ @routine $4916B4 TShrLightGI_SetSize }
procedure TShrLightGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if Kind <> light_masked then Exit;
  LightBuffer.AllocateGrayscale(Size.X, Size.Y);
  LightBuffer.FillPixels(0);
end;
{ @end $4916B4 }

{ @routine $4916FC TShrLightGI_LoadFromConfigPath }
procedure TShrLightGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadLightProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4916FC }

{ @routine $491728 TShrLightGI_LoadFromBlock }
procedure TShrLightGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadLightProperties(Block);
end;
{ @end $491728 }

{ @routine $491744 TShrLightGI_LoadLightProperties }
procedure TShrLightGI.LoadLightProperties(Block: TBlockParEC);
var Text: WideString;
begin
  if Block.CountParams('ShrLight') > 0 then
    SetLightShift(StrToInt(Block.GetParam('ShrLight')));
  if Block.CountParams('Kind') > 0 then
  begin
    Text := Block.GetParam('Kind');
    if Text = 'All' then SetKind(light_uniform)
    else if Text = 'Buf' then SetKind(light_masked);
  end;
end;
{ @end $491744 }

{ @routine $491860 TShrLightGI_Draw }
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
    if Kind = light_masked then
      DrawColoredRect(0, 0, GameScreenWidth, GameScreenHeight, 0, Alpha, True, @ClipRect)
    else if Kind = light_uniform then
      DrawColoredRect(0, 0, GameScreenWidth, GameScreenHeight, 0, Alpha, True, @ClipRect);
  end
  else if Kind = light_masked then
    Ex_OKGR_ShrLightMask_16(AddPointerOffset(ScreenRenderBuffer.GetPixels,
      ScreenRenderBuffer.PitchBytes * ClipRect.Top + ClipRect.Left * 2), ScreenRenderBuffer.PitchBytes,
      AddPointerOffset(LightBuffer.GetPixels,
        (ClipRect.Top - HitTestBounds.Top) * LightBuffer.PitchBytes + (ClipRect.Left - HitTestBounds.Left)),
      LightBuffer.PitchBytes, ClipRect.Right - ClipRect.Left, ClipRect.Bottom - ClipRect.Top)
  else if Kind = light_uniform then ScreenRenderBuffer.ShiftLight16(LightShift, ClipRect);
end;
{ @end $491860 }

end.
