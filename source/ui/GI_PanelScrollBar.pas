unit GI_PanelScrollBar;
// Unit bracket (inferred): .text 0x004979F8..0x00498953; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, GI_Panel, GI_ScrollBar, Types;

type
  TPanelScrollBarGI = class(TPanelGI) // @size 0x16C
  public
    HorizontalScrollBar: TScrollBarGI; // @offset 0x140
    VerticalScrollBar: TScrollBarGI; // @offset 0x144
    AutoHorizontalPlacement: Boolean; // @offset 0x148
    AutoVerticalPlacement: Boolean; // @offset 0x149
    HorizontalScrollBarRect: TRect; // @offset 0x14A
    VerticalScrollBarRect: TRect; // @offset 0x15A
    ScrollbarsOutside: Boolean; // @offset 0x16A
    UnlimitedWorld: Boolean; // @offset 0x16B

    constructor Create(Owner: TObjectGI); // @addr 0x497B24 @ida "TPanelScrollBarGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x497D0C @ida "void __usercall $name(TPanelScrollBarGI *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Frees both scrollbars, including when parented outside this panel."
    procedure Clear; override; // @addr 0x497D88
    procedure SetVerticalScrollBarConfigPath(Path: WideString); // @addr 0x497DC8
    procedure SetHorizontalScrollbarEnabled(Value: Boolean); // @addr 0x497E1C
    function IsVerticalScrollbarEnabled: Boolean; // @addr $497E54
    procedure SetVerticalScrollbarEnabled(Value: Boolean); // @addr 0x497E74
    procedure SetScrollbarsOutside(Value: Boolean); // @addr 0x497EAC @note "The panel retains ownership of scrollbars parented outside it."
    procedure SetUnlimitedWorldEnabled(Value: Boolean); // @addr 0x497FA4
    procedure SetSize(Size: TPoint); override; // @addr 0x497FDC @ida "void __usercall $name(TPanelScrollBarGI *Self@<eax>, TPoint *Size@<edx>);"
    procedure SetOrigin(Origin: TPoint); override; // @addr 0x498008 @ida "void __usercall $name(TPanelScrollBarGI *Self@<eax>, TPoint *Origin@<edx>);"
    procedure SetScrollOffset(Offset: TPoint); override; // @addr 0x498034 @ida "void __usercall $name(TPanelScrollBarGI *Self@<eax>, TPoint *Offset@<edx>);"
    procedure SetDepth(NewDepth: Double); override; // @addr 0x498098 @ida "void __userpurge $name(TPanelScrollBarGI *Self@<eax>, double NewDepth@<^0>);"
    procedure UpdateScrollbarPlacement; // @addr 0x4980E8
    procedure UpdateScrollRanges; // @addr 0x4983C4 @note "Only active PositionModeW children contribute; scrollbars are excluded."
    procedure ScrollbarPositionChanged(Sender: TObjectGI); // @addr 0x498520
    procedure PanelScrollChanged(Sender: TObjectGI); // @addr 0x498564 @note "Clamps the panel back to scrollbar positions when UnlimitedWorld is false."
    procedure ScrollbarDestroyed(Sender: TObjectGI); // @addr 0x4985DC
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x498620
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x498654
    procedure LoadScrollbarPanelProperties(Block: TBlockParEC); // @addr 0x49867C
  end;

implementation

uses Classes, EC_Str, EC_Struct, GI_Main, GR_Main;


{ @routine $497B24 TPanelScrollBarGI_Create }
constructor TPanelScrollBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  HorizontalScrollBar := TScrollBarGI.Create(Self);
  HorizontalScrollBar.UserValue := -1;
  VerticalScrollBar := TScrollBarGI.Create(Self);
  VerticalScrollBar.UserValue := -1;
  HorizontalScrollBar.DestroyNotify := ScrollbarDestroyed;
  VerticalScrollBar.DestroyNotify := ScrollbarDestroyed;
  HorizontalScrollBar.SetActive(False);
  HorizontalScrollBar.SetOrientation(1);
  HorizontalScrollBar.SetKindCalcMode(1);
  VerticalScrollBar.SetActive(False);
  VerticalScrollBar.SetOrientation(2);
  VerticalScrollBar.SetKindCalcMode(1);
  HorizontalScrollBar.SetDepth(-1E30);
  VerticalScrollBar.SetDepth(-1E30);
  HorizontalScrollBar.PositionChangedCallback := ScrollbarPositionChanged;
  VerticalScrollBar.PositionChangedCallback := ScrollbarPositionChanged;
  AutoHorizontalPlacement := True;
  AutoVerticalPlacement := True;
  ScrollbarsOutside := False;
  UnlimitedWorld := True;
  ScrollChangedCallback := PanelScrollChanged;
end;
{ @end $497B24 }

{ @routine $497D0C TPanelScrollBarGI_Destroy }
destructor TPanelScrollBarGI.Destroy;
begin
  if HorizontalScrollBar <> nil then
  begin
    HorizontalScrollBar.Free;
    HorizontalScrollBar := nil;
  end;
  if VerticalScrollBar <> nil then
  begin
    VerticalScrollBar.Free;
    VerticalScrollBar := nil;
  end;
  inherited Destroy;
end;
{ @end $497D0C }

{ @routine $497D88 TPanelScrollBarGI_Clear }
procedure TPanelScrollBarGI.Clear;
begin
  inherited Clear;
  if (HorizontalScrollBar <> nil) and (VerticalScrollBar <> nil) then SetScrollbarsOutside(False);
  UnlimitedWorld := True;
end;
{ @end $497D88 }

{ @routine $497DC8 TPanelScrollBarGI_SetVerticalScrollBarConfigPath }
procedure TPanelScrollBarGI.SetVerticalScrollBarConfigPath(Path: WideString);
begin
  VerticalScrollBar.SetConfigPath(Path);
end;
{ @end $497DC8 }

{ @routine $497E1C TPanelScrollBarGI_SetHorizontalScrollbarEnabled }
procedure TPanelScrollBarGI.SetHorizontalScrollbarEnabled(Value: Boolean);
begin
  HorizontalScrollBar.SetActive(Value);
  if Value = True then HorizontalScrollBar.UpdateSizeForOrientation;
end;
{ @end $497E1C }

{ @routine $497E54 TPanelScrollBarGI_IsVerticalScrollbarEnabled }
function TPanelScrollBarGI.IsVerticalScrollbarEnabled: Boolean;
begin
  Result := VerticalScrollBar.Active;
end;
{ @end $497E54 }

{ @routine $497E74 TPanelScrollBarGI_SetVerticalScrollbarEnabled }
procedure TPanelScrollBarGI.SetVerticalScrollbarEnabled(Value: Boolean);
begin
  VerticalScrollBar.SetActive(Value);
  if Value = True then VerticalScrollBar.UpdateSizeForOrientation;
end;
{ @end $497E74 }

{ @routine $497EAC TPanelScrollBarGI_SetScrollbarsOutside }
procedure TPanelScrollBarGI.SetScrollbarsOutside(Value: Boolean);
begin
  if Value <> ScrollbarsOutside then
  begin
    ScrollbarsOutside := Value;
    if not ScrollbarsOutside then
    begin
      HorizontalScrollBar.Reparent(Self);
      VerticalScrollBar.Reparent(Self);
      HorizontalScrollBar.SetDepth(-1E30);
      VerticalScrollBar.SetDepth(-1E30);
    end
    else
    begin
      HorizontalScrollBar.Reparent(Parent);
      VerticalScrollBar.Reparent(Parent);
      HorizontalScrollBar.SetDepth(Depth);
      VerticalScrollBar.SetDepth(Depth);
    end;
    UpdateScrollbarPlacement;
    Invalidate;
  end;
end;
{ @end $497EAC }

{ @routine $497FA4 TPanelScrollBarGI_SetUnlimitedWorldEnabled }
procedure TPanelScrollBarGI.SetUnlimitedWorldEnabled(Value: Boolean);
begin
  if Value <> UnlimitedWorld then
  begin
    UnlimitedWorld := Value;
    Invalidate;
  end;
end;
{ @end $497FA4 }

{ @routine $497FDC TPanelScrollBarGI_SetSize }
procedure TPanelScrollBarGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  UpdateScrollbarPlacement;
end;
{ @end $497FDC }

{ @routine $498008 TPanelScrollBarGI_SetOrigin }
procedure TPanelScrollBarGI.SetOrigin(Origin: TPoint);
begin
  inherited SetOrigin(Origin);
  UpdateScrollbarPlacement;
end;
{ @end $498008 }

{ @routine $498034 TPanelScrollBarGI_SetScrollOffset }
procedure TPanelScrollBarGI.SetScrollOffset(Offset: TPoint);
begin
  inherited SetScrollOffset(Offset);
  if HorizontalScrollBar <> nil then HorizontalScrollBar.SetPositionInternal(ScrollOffset.X);
  if VerticalScrollBar <> nil then VerticalScrollBar.SetPositionInternal(ScrollOffset.Y);
end;
{ @end $498034 }

{ @routine $498098 TPanelScrollBarGI_SetDepth }
procedure TPanelScrollBarGI.SetDepth(NewDepth: Double);
begin
  inherited SetDepth(NewDepth);
  if ScrollbarsOutside then
  begin
    HorizontalScrollBar.SetDepth(NewDepth);
    VerticalScrollBar.SetDepth(NewDepth);
  end;
end;
{ @end $498098 }

{ @routine $4980E8 TPanelScrollBarGI_UpdateScrollbarPlacement }
procedure TPanelScrollBarGI.UpdateScrollbarPlacement;
begin
  if not ScrollbarsOutside then
  begin
    if AutoHorizontalPlacement then
    begin
      TObjectGI(HorizontalScrollBar).SetPosition(Classes.Point(0, ClientSize.Y - HorizontalScrollBar.ClientSize.Y));
      HorizontalScrollBar.SetSize(Classes.Point(ClientSize.X - VerticalScrollBar.ClientSize.X, HorizontalScrollBar.ClientSize.Y));
    end
    else
    begin
      TObjectGI(HorizontalScrollBar).SetPosition(HorizontalScrollBarRect.TopLeft);
      HorizontalScrollBar.SetSize(SubtractPoints(HorizontalScrollBarRect.BottomRight, HorizontalScrollBarRect.TopLeft));
    end;
    if AutoVerticalPlacement then
    begin
      TObjectGI(VerticalScrollBar).SetPosition(Classes.Point(ClientSize.X - VerticalScrollBar.ClientSize.X, 0));
      VerticalScrollBar.SetSize(Classes.Point(VerticalScrollBar.ClientSize.X, ClientSize.Y - HorizontalScrollBar.ClientSize.Y));
    end
    else
    begin
      TObjectGI(VerticalScrollBar).SetPosition(VerticalScrollBarRect.TopLeft);
      VerticalScrollBar.SetSize(SubtractPoints(VerticalScrollBarRect.BottomRight, VerticalScrollBarRect.TopLeft));
    end;
  end
  else
  begin
    if AutoHorizontalPlacement then
    begin
      TObjectGI(HorizontalScrollBar).SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ClientSize.Y));
      HorizontalScrollBar.SetSize(Classes.Point(ClientSize.X, HorizontalScrollBar.ClientSize.Y));
    end
    else
    begin
      TObjectGI(HorizontalScrollBar).SetPosition(HorizontalScrollBarRect.TopLeft);
      HorizontalScrollBar.SetSize(SubtractPoints(HorizontalScrollBarRect.BottomRight, HorizontalScrollBarRect.TopLeft));
    end;
    if AutoVerticalPlacement then
    begin
      TObjectGI(VerticalScrollBar).SetPosition(Classes.Point(LocalPosition.X + ClientSize.X, LocalPosition.Y));
      VerticalScrollBar.SetSize(Classes.Point(VerticalScrollBar.ClientSize.X, ClientSize.Y));
    end
    else
    begin
      TObjectGI(VerticalScrollBar).SetPosition(VerticalScrollBarRect.TopLeft);
      VerticalScrollBar.SetSize(SubtractPoints(VerticalScrollBarRect.BottomRight, VerticalScrollBarRect.TopLeft));
    end;
  end;
end;
{ @end $4980E8 }

{ @routine $4983C4 TPanelScrollBarGI_UpdateScrollRanges }
procedure TPanelScrollBarGI.UpdateScrollRanges;
var Child: TObjectGI; Bounds, ChildBounds: TRect;
begin
  if not Active then Exit;
  Bounds.Left := $7FFFFFF0;
  Bounds.Top := $7FFFFFF0;
  Bounds.Right := -$7FFFFFF0;
  Bounds.Bottom := -$7FFFFFF0;
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child <> HorizontalScrollBar) and (Child <> VerticalScrollBar) and
      (Child.PositionModeW = True) and (Child.Active = True) then
    begin
      ChildBounds := Child.GetLocalBounds;
      if ChildBounds.Left < Bounds.Left then Bounds.Left := ChildBounds.Left;
      if ChildBounds.Top < Bounds.Top then Bounds.Top := ChildBounds.Top;
      if ChildBounds.Right > Bounds.Right then Bounds.Right := ChildBounds.Right;
      if ChildBounds.Bottom > Bounds.Bottom then Bounds.Bottom := ChildBounds.Bottom;
    end;
    Child := Child.NextSibling;
  end;
  if HorizontalScrollBar <> nil then
  begin
    HorizontalScrollBar.SetRange(Bounds.Left, Bounds.Right - 1);
    HorizontalScrollBar.SetPageSize(ClientSize.X);
    HorizontalScrollBar.SetPositionInternal(ScrollOffset.X);
  end;
  if VerticalScrollBar <> nil then
  begin
    VerticalScrollBar.SetRange(Bounds.Top, Bounds.Bottom - 1);
    VerticalScrollBar.SetPageSize(ClientSize.Y);
    VerticalScrollBar.SetPositionInternal(ScrollOffset.Y);
  end;
end;
{ @end $4983C4 }

{ @routine $498520 TPanelScrollBarGI_ScrollbarPositionChanged }
procedure TPanelScrollBarGI.ScrollbarPositionChanged(Sender: TObjectGI);
begin
  SetScrollOffset(Classes.Point(HorizontalScrollBar.Position, VerticalScrollBar.Position));
end;
{ @end $498520 }

{ @routine $498564 TPanelScrollBarGI_PanelScrollChanged }
procedure TPanelScrollBarGI.PanelScrollChanged(Sender: TObjectGI);
begin
  HorizontalScrollBar.SetPositionInternal(ScrollOffset.X);
  VerticalScrollBar.SetPositionInternal(ScrollOffset.Y);
  if not UnlimitedWorld then SetScrollOffset(Classes.Point(HorizontalScrollBar.Position, VerticalScrollBar.Position));
end;
{ @end $498564 }

{ @routine $4985DC TPanelScrollBarGI_ScrollbarDestroyed }
procedure TPanelScrollBarGI.ScrollbarDestroyed(Sender: TObjectGI);
begin
  if HorizontalScrollBar = Sender then HorizontalScrollBar := nil;
  if VerticalScrollBar = Sender then VerticalScrollBar := nil;
end;
{ @end $4985DC }

{ @routine $498620 TPanelScrollBarGI_LoadFromConfigPath }
procedure TPanelScrollBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadScrollbarPanelProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $498620 }

{ @routine $498654 TPanelScrollBarGI_LoadFromBlock }
procedure TPanelScrollBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadScrollbarPanelProperties(Block);
end;
{ @end $498654 }

{ @routine $49867C TPanelScrollBarGI_LoadScrollbarPanelProperties }
procedure TPanelScrollBarGI.LoadScrollbarPanelProperties(Block: TBlockParEC);
begin
  if Block.CountParams('StyleBarX') > 0 then HorizontalScrollBar.SetConfigPath(Block.GetParam('StyleBarX'));
  if Block.CountParams('StyleBarY') > 0 then VerticalScrollBar.SetConfigPath(Block.GetParam('StyleBarY'));
  if Block.CountParams('ActiveBarX') > 0 then
  begin
    if Block.GetParam('ActiveBarX') = 'True' then SetHorizontalScrollbarEnabled(True)
    else SetHorizontalScrollbarEnabled(False);
  end;
  if Block.CountParams('ActiveBarY') > 0 then
  begin
    if Block.GetParam('ActiveBarY') = 'True' then SetVerticalScrollbarEnabled(True)
    else SetVerticalScrollbarEnabled(False);
  end;
  if Block.CountParams('ExternalSB') > 0 then
  begin
    if TrimWideString(Block.GetParam('ExternalSB')) = 'True' then SetScrollbarsOutside(True)
    else SetScrollbarsOutside(False);
  end;
  if Block.CountParams('UnlimitedWorld') > 0 then
  begin
    if TrimWideString(Block.GetParam('UnlimitedWorld')) = 'True' then SetUnlimitedWorldEnabled(True)
    else SetUnlimitedWorldEnabled(False);
  end;
  if Block.CountParams('PosAutoBarX') > 0 then AutoHorizontalPlacement := ParseEnabledNameGI(Block.GetParam('PosAutoBarX'));
  if Block.CountParams('PosAutoBarY') > 0 then AutoVerticalPlacement := ParseEnabledNameGI(Block.GetParam('PosAutoBarY'));
  if Block.CountParams('RectBarX') > 0 then HorizontalScrollBarRect := GetRectGI(Block.GetParam('RectBarX'));
  if Block.CountParams('RectBarY') > 0 then VerticalScrollBarRect := GetRectGI(Block.GetParam('RectBarY'));
  UpdateScrollbarPlacement;
  UpdateScrollRanges;
end;
{ @end $49867C }

end.
