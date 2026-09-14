unit GI_StatusBar;
// Unit bracket (inferred): .text 0x004A03A4..0x004A0D28; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Owner: TObjectGI); // @addr 0x4A04CC @ida "TStatusBarGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4A0620 @ida "void __usercall $name(TStatusBarGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Clear; override; // @addr 0x4A067C @note "Preserves Value; resets the range to 0..100."
    procedure SetRange(MinValue, MaxValue: Double); // @addr 0x4A06B4 @ida "void __userpurge $name(TStatusBarGI *Self@<eax>, double MinValue@<^8>, double MaxValue@<^0>);" @note "If MinValue exceeds MaxValue, lowers MinValue to MaxValue. Does not clamp the stored Value."
    procedure SetValue(NewValue: Double); // @addr 0x4A073C @ida "void __userpurge $name(TStatusBarGI *Self@<eax>, double NewValue@<^0>);"
    procedure SetSize(Size: TPoint); override; // @addr 0x4A07D0 @ida "void __usercall $name(TStatusBarGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure UpdateImageLayout; // @addr 0x4A0808
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4A0B48
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4A0B7C
    procedure LoadStatusProperties(Block: TBlockParEC); // @addr 0x4A0BA4
  end;

implementation

uses Classes, EC_Str, GI_Main;

{ @routine $4A04CC TStatusBarGI_Create }
constructor TStatusBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  LeftImage := TImageGI.Create(Self);
  CenterImage := TImageGI.Create(Self);
  RightImage := TImageGI.Create(Self);
  LeftImage.SetDepth(1);
  LeftImage.SetImageKindX(ikxLeft);
  LeftImage.SetImageKindY(ikyCenter);
  CenterImage.SetDepth(1);
  CenterImage.SetImageKindX(ikxLeftFill);
  CenterImage.SetImageKindY(ikyCenter);
  RightImage.SetDepth(1);
  RightImage.SetImageKindX(ikxLeft);
  RightImage.SetImageKindY(ikyCenter);
  Minimum := 0;
  Maximum := 100;
end;
{ @end $4A04CC }

{ @routine $4A0620 TStatusBarGI_Destroy }
destructor TStatusBarGI.Destroy;
begin
  LeftImage.Free;
  CenterImage.Free;
  RightImage.Free;
  inherited Destroy;
end;
{ @end $4A0620 }

{ @routine $4A067C TStatusBarGI_Clear }
procedure TStatusBarGI.Clear;
begin
  Minimum := 0;
  Maximum := 100;
  inherited Clear;
end;
{ @end $4A067C }

{ @routine $4A06B4 TStatusBarGI_SetRange }
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
{ @end $4A06B4 }

{ @routine $4A073C TStatusBarGI_SetValue }
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
{ @end $4A073C }

{ @routine $4A07D0 TStatusBarGI_SetSize }
procedure TStatusBarGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  UpdateImageLayout;
  Invalidate;
end;
{ @end $4A07D0 }

{ @routine $4A0808 TStatusBarGI_UpdateImageLayout }
procedure TStatusBarGI.UpdateImageLayout;
var Width: Integer;
begin
  if Maximum - Minimum = 0 then Width := 0
  else Width := Round((Value - Minimum) / (Maximum - Minimum) * ClientSize.X);
  if Minimum = Value then
  begin
    LeftImage.SetSize(Classes.Point(0, ClientSize.Y));
    CenterImage.SetSize(Classes.Point(0, ClientSize.Y));
    RightImage.SetSize(Classes.Point(0, ClientSize.Y));
  end
  else if LeftImage.GetContentSize.X + RightImage.GetContentSize.X >= Width then
  begin
    LeftImage.SetSize(Classes.Point(LeftImage.GetContentSize.X, ClientSize.Y));
    CenterImage.SetSize(Classes.Point(0, ClientSize.Y));
    RightImage.SetSize(Classes.Point(RightImage.GetContentSize.X, ClientSize.Y));
    LeftImage.SetPosition(Classes.Point(0, 0));
    CenterImage.SetPosition(Classes.Point(LeftImage.ClientSize.X, 0));
    RightImage.SetPosition(Classes.Point(LeftImage.ClientSize.X, 0));
  end
  else
  begin
    LeftImage.SetSize(Classes.Point(LeftImage.GetContentSize.X, ClientSize.Y));
    CenterImage.SetSize(Classes.Point(Width - LeftImage.ClientSize.X - RightImage.ClientSize.X, ClientSize.Y));
    RightImage.SetSize(Classes.Point(RightImage.GetContentSize.X, ClientSize.Y));
    LeftImage.SetPosition(Classes.Point(0, 0));
    CenterImage.SetPosition(Classes.Point(LeftImage.ClientSize.X, 0));
    RightImage.SetPosition(Classes.Point(LeftImage.ClientSize.X + CenterImage.ClientSize.X, 0));
    CenterImage.SetImageKindX(ikxLeftFill);
  end;
end;
{ @end $4A0808 }

{ @routine $4A0B48 TStatusBarGI_LoadFromConfigPath }
procedure TStatusBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadStatusProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4A0B48 }

{ @routine $4A0B7C TStatusBarGI_LoadFromBlock }
procedure TStatusBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadStatusProperties(Block);
end;
{ @end $4A0B7C }

{ @routine $4A0BA4 TStatusBarGI_LoadStatusProperties }
procedure TStatusBarGI.LoadStatusProperties(Block: TBlockParEC);
begin
  if Block.CountParams('ImageLeft') > 0 then LeftImage.SetImagePath(Block.GetParam('ImageLeft'));
  if Block.CountParams('ImageMiddle') > 0 then CenterImage.SetImagePath(Block.GetParam('ImageMiddle'));
  if Block.CountParams('ImageRight') > 0 then RightImage.SetImagePath(Block.GetParam('ImageRight'));
  if (Block.CountParams('Min') > 0) and (Block.CountParams('Max') > 0) then
    SetRange(ExtractDecimalToSingleW(Block.GetParam('Min')), ExtractDecimalToSingleW(Block.GetParam('Max')));
  if Block.CountParams('Cur') > 0 then SetValue(ExtractDecimalToSingleW(Block.GetParam('Cur')));
  UpdateImageLayout;
end;
{ @end $4A0BA4 }

end.
