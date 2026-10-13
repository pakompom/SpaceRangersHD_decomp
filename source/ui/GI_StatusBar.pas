unit GI_StatusBar;

interface

uses EC_BlockPar, GI_Image, GI_MessageLoop, GI_Panel, Types;

type
  TStatusBarGI = class(TPanelGI) // @size 0x164
  public
    Minimum: Double; // @offset 0x140
    Maximum: Double; // @offset 0x148
    Value: Double; // @offset 0x150
    LeftImage: TImageGI; // @offset 0x158
    CenterImage: TImageGI; // @offset 0x15C
    RightImage: TImageGI; // @offset 0x160

    constructor Create(Owner: TObjectGI); // @addr 0x004ABFB4
    destructor Destroy; override; // @addr 0x004AC0CC
    procedure Clear; override; // @addr 0x004AC114 @note "Preserves Value; resets the range to 0..100."
    procedure SetRange(MinValue, MaxValue: Double); // @addr 0x004AC13C @note "If MinValue exceeds MaxValue, lowers MinValue to MaxValue. Does not clamp the stored Value."
    procedure SetValue(NewValue: Double); // @addr 0x004AC1B4
    procedure SetSize(Size: TPoint); override; // @addr 0x004AC234
    procedure UpdateImageLayout; // @addr 0x004AC264
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004AC4F4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004AC520
    procedure LoadStatusProperties(Block: TBlockParEC); // @addr 0x004AC53C
  end;

implementation

uses Classes, EC_Str, GI_Main;

{ @routine $4ABFB4 TStatusBarGI_Create }
constructor TStatusBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  LeftImage := TImageGI.Create(Self);
  CenterImage := TImageGI.Create(Self);
  RightImage := TImageGI.Create(Self);
  LeftImage.SetDepth(1);
  LeftImage.KindX := ikxLeft;
  LeftImage.KindY := ikyCenter;
  CenterImage.SetDepth(1);
  CenterImage.KindX := ikxLeftFill;
  CenterImage.KindY := ikyCenter;
  RightImage.SetDepth(1);
  RightImage.KindX := ikxLeft;
  RightImage.KindY := ikyCenter;
  Minimum := 0;
  Maximum := 100;
end;
{ @end $4ABFB4 }

{ @routine $4AC0CC TStatusBarGI_Destroy }
destructor TStatusBarGI.Destroy;
begin
  LeftImage.Free;
  CenterImage.Free;
  RightImage.Free;
  inherited Destroy;
end;
{ @end $4AC0CC }

{ @routine $4AC114 TStatusBarGI_Clear }
procedure TStatusBarGI.Clear;
begin
  Minimum := 0;
  Maximum := 100;
  inherited Clear;
end;
{ @end $4AC114 }

{ @routine $4AC13C TStatusBarGI_SetRange }
procedure TStatusBarGI.SetRange(MinValue, MaxValue: Double);
begin
  if MinValue > MaxValue then MinValue := MaxValue;
  if (MinValue <> Minimum) or (MaxValue <> Maximum) then
  begin
    Minimum := MinValue;
    Maximum := MaxValue;
    UpdateImageLayout;
    Invalidate;
  end;
end;
{ @end $4AC13C }

{ @routine $4AC1B4 TStatusBarGI_SetValue }
procedure TStatusBarGI.SetValue(NewValue: Double);
begin
  if NewValue < Minimum then NewValue := Minimum;
  if NewValue > Maximum then NewValue := Maximum;
  if NewValue <> Value then
  begin
    Value := NewValue;
    UpdateImageLayout;
    Invalidate;
  end;
end;
{ @end $4AC1B4 }

{ @routine $4AC234 TStatusBarGI_SetSize }
procedure TStatusBarGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  UpdateImageLayout;
  Invalidate;
end;
{ @end $4AC234 }

{ @routine $4AC264 TStatusBarGI_UpdateImageLayout }
procedure TStatusBarGI.UpdateImageLayout;
var Width: Integer;
begin
  if Maximum - Minimum = 0 then Width := 0
  else Width := Round((Value - Minimum) / (Maximum - Minimum) * ClientSize.X);
  if Minimum = Value then
  begin
    LeftImage.ObjectSize := Classes.Point(0, ClientSize.Y);
    CenterImage.ObjectSize := Classes.Point(0, ClientSize.Y);
    RightImage.ObjectSize := Classes.Point(0, ClientSize.Y);
  end
  else if LeftImage.GetContentSize.X + RightImage.GetContentSize.X >= Width then
  begin
    LeftImage.ObjectSize := Classes.Point(LeftImage.GetContentSize.X, ClientSize.Y);
    CenterImage.ObjectSize := Classes.Point(0, ClientSize.Y);
    RightImage.ObjectSize := Classes.Point(RightImage.GetContentSize.X, ClientSize.Y);
    LeftImage.Pos := Classes.Point(0, 0);
    CenterImage.Pos := Classes.Point(LeftImage.ClientSize.X, 0);
    RightImage.Pos := Classes.Point(LeftImage.ClientSize.X, 0);
  end
  else
  begin
    LeftImage.ObjectSize := Classes.Point(LeftImage.GetContentSize.X, ClientSize.Y);
    CenterImage.ObjectSize := Classes.Point(Width - LeftImage.ClientSize.X - RightImage.ClientSize.X, ClientSize.Y);
    RightImage.ObjectSize := Classes.Point(RightImage.GetContentSize.X, ClientSize.Y);
    LeftImage.Pos := Classes.Point(0, 0);
    CenterImage.Pos := Classes.Point(LeftImage.ClientSize.X, 0);
    RightImage.Pos := Classes.Point(LeftImage.ClientSize.X + CenterImage.ClientSize.X, 0);
    CenterImage.KindX := ikxLeftFill;
  end;
end;
{ @end $4AC264 }

{ @routine $4AC4F4 TStatusBarGI_LoadFromConfigPath }
procedure TStatusBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadStatusProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4AC4F4 }

{ @routine $4AC520 TStatusBarGI_LoadFromBlock }
procedure TStatusBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadStatusProperties(Block);
end;
{ @end $4AC520 }

{ @routine $4AC53C TStatusBarGI_LoadStatusProperties }
procedure TStatusBarGI.LoadStatusProperties(Block: TBlockParEC);
begin
  if Block.CountParams('ImageLeft') > 0 then LeftImage.ImageSourcePath := Block.GetParam('ImageLeft');
  if Block.CountParams('ImageMiddle') > 0 then CenterImage.ImageSourcePath := Block.GetParam('ImageMiddle');
  if Block.CountParams('ImageRight') > 0 then RightImage.ImageSourcePath := Block.GetParam('ImageRight');
  if (Block.CountParams('Min') > 0) and (Block.CountParams('Max') > 0) then
    SetRange(ExtractDecimalToSingleW(Block.GetParam('Min')), ExtractDecimalToSingleW(Block.GetParam('Max')));
  if Block.CountParams('Cur') > 0 then SetValue(ExtractDecimalToSingleW(Block.GetParam('Cur')));
  UpdateImageLayout;
end;
{ @end $4AC53C }

end.
