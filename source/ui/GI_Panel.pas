unit GI_Panel;
// Unit bracket (inferred): .text 0x004728CC..0x00473744; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_MessageLoop, Types;

type
  TPanelScrollTypeGI = (pstSimple = 0, pstAll = 1, pstObj = 2, pstView = 3); // @size 1
  TPanelScrollAxisGI = (psaHorizontal = 0, psaVertical = 1, psaBoth = 2); // @size 1

  TPanelGI = class(TObjectGI) // @size 0x13C
  public
    DragScrollingEnabled: Boolean; // @offset 0x120
    ScrollType: TPanelScrollTypeGI; // @offset 0x121
    Dragging: Boolean; // @offset 0x122
    LastDragPoint: TPoint; // @offset 0x123
    ScrollChangedCallback: TObjectNotifyEventGI; // @offset $130
    ScrollAxis: TPanelScrollAxisGI; // @offset 0x138

    constructor Create(Owner: TObjectGI); // @addr 0x472A14
    destructor Destroy; override; // @addr 0x472A7C
    procedure Clear; override; // @addr 0x472AB0
    function GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint; override; // @addr 0x472AFC @note "Only ModeW children are affected by scrolling."
    function ToLocalPoint(Point: TPoint): TPoint; override; // @addr 0x472B68
    function ToAbsolutePoint(Point: TPoint): TPoint; override; // @addr 0x472BAC
    procedure SetDragScrollingEnabled(Value: Boolean); // @addr 0x472BF0
    procedure SetScrollOffset(Offset: TPoint); virtual; // @addr 0x472C38 @slot 0xC8 @calls "0x6A4C15 0x6A4CB1"
    function GetVisibleContentRect: TRect; // @addr 0x472F8C
    procedure ScrollRectIntoView(Rect: TRect); // @addr 0x472FE4
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $473104
    procedure ProcessRightButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4732E8
    procedure ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $473394
    procedure OnActivate; override; // @addr 0x4730E8
    procedure OnMouseEnter; override; // @addr 0x473268
    procedure OnMouseLeave; override; // @addr 0x473284
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x473410
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x473584
  end;

implementation

uses Classes, EC_Str, GI_Main, GR_Main, SysUtils;


{ @routine $472A14 TPanelGI_Create }
constructor TPanelGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  SkipOwnQueuedDraw := 1;
  DragScrollingEnabled := False;
  ScrollType := pstAll;
end;
{ @end $472A14 }

{ @routine $472A7C TPanelGI_Destroy }
destructor TPanelGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $472A7C }

{ @routine $472AB0 TPanelGI_Clear }
procedure TPanelGI.Clear;
begin
  inherited Clear;
  ScrollOffset.X := 0;
  ScrollOffset.Y := 0;
  Dragging := False;
  DragScrollingEnabled := False;
  ScrollType := pstAll;
  ScrollAxis := psaBoth;
end;
{ @end $472AB0 }

{ @routine $472AFC TPanelGI_GetChildAbsolutePosition }
function TPanelGI.GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint;
begin
  if not ModeW then
  begin
    Result.X := AbsolutePosition.X + LocalPosition.X;
    Result.Y := AbsolutePosition.Y + LocalPosition.Y;
  end
  else
  begin
    Result.X := AbsolutePosition.X + LocalPosition.X - ScrollOffset.X;
    Result.Y := AbsolutePosition.Y + LocalPosition.Y - ScrollOffset.Y;
  end;
end;
{ @end $472AFC }

{ @routine $472B68 TPanelGI_ToLocalPoint }
function TPanelGI.ToLocalPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X - AbsolutePosition.X + ScrollOffset.X;
  Result.Y := Point.Y - AbsolutePosition.Y + ScrollOffset.Y;
end;
{ @end $472B68 }

{ @routine $472BAC TPanelGI_ToAbsolutePoint }
function TPanelGI.ToAbsolutePoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X + AbsolutePosition.X - ScrollOffset.X;
  Result.Y := Point.Y + AbsolutePosition.Y - ScrollOffset.Y;
end;
{ @end $472BAC }

{ @routine $472BF0 TPanelGI_SetDragScrollingEnabled }
procedure TPanelGI.SetDragScrollingEnabled(Value: Boolean);
begin
  if Value <> DragScrollingEnabled then
  begin
    DragScrollingEnabled := Value;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end;
end;
{ @end $472BF0 }

{ @routine $472C38 TPanelGI_SetScrollOffset }
procedure TPanelGI.SetScrollOffset(Offset: TPoint);
var Child: TObjectGI; Delta: TPoint; DestRect, SourceRect: TRect;
begin
  if (ScrollOffset.X = Offset.X) and (ScrollOffset.Y = Offset.Y) then Exit;
  if ScrollType = pstSimple then
  begin
    ScrollOffset := Offset;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
  end
  else if ScrollType = pstAll then
  begin
    ScrollOffset := Offset;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Invalidate;
  end
  else if ScrollType = pstObj then
  begin
    MessageLoop.RegionDrawPending := True;
    MessageLoop.InvalidateMouseViewControls;
    Child := FirstChild;
    while Child <> nil do
    begin
      if Child.PositionModeW then Child.Invalidate;
      Child := Child.NextSibling;
    end;
    ScrollOffset := Offset;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    Child := FirstChild;
    while Child <> nil do
    begin
      if Child.PositionModeW then Child.Invalidate;
      Child := Child.NextSibling;
    end;
  end
  else if ScrollType = pstView then
  begin
    Delta.X := ScrollOffset.X - Offset.X;
    Delta.Y := ScrollOffset.Y - Offset.Y;
    if (Abs(Delta.X) > ClientSize.X div 2) or (Abs(Delta.Y) > ClientSize.Y div 2) then
    begin
      ScrollOffset := Offset;
      UpdateAbsolutePosition;
      UpdateSubtreeHitBounds;
      Invalidate;
      Exit;
    end;
    MessageLoop.DrawQueuedUpdateRects;
    ScrollOffset := Offset;
    UpdateAbsolutePosition;
    UpdateSubtreeHitBounds;
    MessageLoop.RootUiObject.InvalidateScrollOverlap(HitTestBounds, Delta, Self);
    DestRect := GetLocalBounds;
    SourceRect := DestRect;
    if Delta.X > 0 then
    begin
      InvalidateRect(Classes.Rect(DestRect.Left, DestRect.Top, DestRect.Left + Delta.X, DestRect.Bottom));
      Inc(DestRect.Left, Delta.X);
      Dec(SourceRect.Right, Delta.X);
    end
    else if Delta.X < 0 then
    begin
      InvalidateRect(Classes.Rect(DestRect.Right + Delta.X, DestRect.Top, DestRect.Right, DestRect.Bottom));
      Inc(DestRect.Right, Delta.X);
      Dec(SourceRect.Left, Delta.X);
    end;
    if Delta.Y > 0 then
    begin
      InvalidateRect(Classes.Rect(DestRect.Left, DestRect.Top, DestRect.Right, DestRect.Top + Delta.Y));
      Inc(DestRect.Top, Delta.Y);
      Dec(SourceRect.Bottom, Delta.Y);
    end
    else if Delta.Y < 0 then
    begin
      InvalidateRect(Classes.Rect(DestRect.Left, DestRect.Bottom + Delta.Y, DestRect.Right, DestRect.Bottom));
      Inc(DestRect.Bottom, Delta.Y);
      Dec(SourceRect.Top, Delta.Y);
    end;
    Ex_OKGR_CopySingleBuf_XY_XY_WORD(ScreenRenderBuffer.GetPixels, ScreenRenderBuffer.PitchBytes,
      DestRect.Left, DestRect.Top, SourceRect.Left, SourceRect.Top,
      SourceRect.Right - SourceRect.Left, SourceRect.Bottom - SourceRect.Top);
  end;
end;
{ @end $472C38 }

{ @routine $472F8C TPanelGI_GetVisibleContentRect }
function TPanelGI.GetVisibleContentRect: TRect;
begin
  Result.Left := ScrollOffset.X - OriginPoint.X;
  Result.Top := ScrollOffset.Y - OriginPoint.Y;
  Result.Right := Result.Left + ClientSize.X;
  Result.Bottom := Result.Top + ClientSize.Y;
end;
{ @end $472F8C }

{ @routine $472FE4 TPanelGI_ScrollRectIntoView }
procedure TPanelGI.ScrollRectIntoView(Rect: TRect);
var Offset: TPoint; Visible: TRect;
begin
  Offset := ScrollOffset;
  Visible := GetVisibleContentRect;
  if Rect.Bottom > Visible.Bottom then
  begin
    Offset.Y := Rect.Bottom - (Visible.Bottom - Visible.Top);
    SetScrollOffset(Offset);
  end;
  Offset := ScrollOffset;
  Visible := GetVisibleContentRect;
  if Rect.Top < Visible.Top then
  begin
    Offset.Y := Rect.Top;
    SetScrollOffset(Offset);
  end;
  Offset := ScrollOffset;
  Visible := GetVisibleContentRect;
  if Rect.Right > Visible.Right then
  begin
    Offset.X := Rect.Right - (Visible.Right - Visible.Left);
    SetScrollOffset(Offset);
  end;
  Offset := ScrollOffset;
  Visible := GetVisibleContentRect;
  if Rect.Left < Visible.Left then
  begin
    Offset.X := Rect.Left;
    SetScrollOffset(Offset);
  end;
end;
{ @end $472FE4 }

{ @routine $4730E8 TPanelGI_OnActivate }
procedure TPanelGI.OnActivate;
begin
  inherited OnActivate;
  Dragging := False;
end;
{ @end $4730E8 }

{ @routine $473104 TPanelGI_ProcessMouseMove }
procedure TPanelGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var X, Y: Integer;
begin
  inherited ProcessMouseMove(KeyState, Point);
  if Dragging = True then
    if (Point.X <> LastDragPoint.X) or (Point.Y <> LastDragPoint.Y) then
    begin
      if MessageLoop.IsCursorImageSelected('Main') then MessageLoop.SetCursorByName('Scroll');
      if (ScrollAxis = psaHorizontal) or (ScrollAxis = psaBoth) then X := ScrollOffset.X + LastDragPoint.X - Point.X
      else X := ScrollOffset.X;
      if (ScrollAxis = psaVertical) or (ScrollAxis = psaBoth) then Y := ScrollOffset.Y + LastDragPoint.Y - Point.Y
      else Y := ScrollOffset.Y;
      SetScrollOffset(Classes.Point(X, Y));
      LastDragPoint := Point;
      if Assigned(ScrollChangedCallback) then ScrollChangedCallback(Self);
    end;
end;
{ @end $473104 }

{ @routine $473268 TPanelGI_OnMouseEnter }
procedure TPanelGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  Dragging := False;
end;
{ @end $473268 }

{ @routine $473284 TPanelGI_OnMouseLeave }
procedure TPanelGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  Dragging := False;
  if MessageLoop.IsCursorImageSelected('Scroll') then MessageLoop.SetCursorByName('Main');
end;
{ @end $473284 }

{ @routine $4732E8 TPanelGI_ProcessRightButtonDown }
procedure TPanelGI.ProcessRightButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessRightButtonDown(KeyState, Point);
  if not IsOccludedAtPoint(Point) and (DragScrollingEnabled = True) then
  begin
    Dragging := True;
    LastDragPoint := Point;
    if MessageLoop.IsCursorImageSelected('Main') then MessageLoop.SetCursorByName('Scroll');
  end;
end;
{ @end $4732E8 }

{ @routine $473394 TPanelGI_ProcessRightButtonUp }
procedure TPanelGI.ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessRightButtonUp(KeyState, Point);
  Dragging := False;
  if MessageLoop.IsCursorImageSelected('Scroll') then MessageLoop.SetCursorByName('Main');
end;
{ @end $473394 }

{ @routine $473410 TPanelGI_LoadFromConfigPath }
procedure TPanelGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC; Text: WideString;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  if Block.CountParams('CenterWorld') > 0 then
  begin
    Text := Block.GetParam('CenterWorld');
    ScrollOffset.X := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    ScrollOffset.Y := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
  end;
  if Block.CountParams('MoveWorld') > 0 then DragScrollingEnabled := ParseEnabledNameGI(Block.GetParam('MoveWorld'));
end;
{ @end $473410 }

{ @routine $473584 TPanelGI_LoadFromBlock }
procedure TPanelGI.LoadFromBlock(Block: TBlockParEC);
var Text: WideString;
begin
  inherited LoadFromBlock(Block);
  if Block.CountParams('CenterWorld') > 0 then
  begin
    Text := Block.GetParam('CenterWorld');
    ScrollOffset.X := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    ScrollOffset.Y := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
  end;
  if Block.CountParams('MoveWorld') > 0 then
    if TrimWideString(Block.GetParam('MoveWorld')) = 'True' then DragScrollingEnabled := True;
  if Block.CountParams('TypeScroll') > 0 then
  begin
    Text := Block.GetParam('TypeScroll');
    if Text = 'Simple' then ScrollType := pstSimple
    else if Text = 'All' then ScrollType := pstAll
    else if Text = 'Obj' then ScrollType := pstObj
    else if Text = 'View' then ScrollType := pstView;
  end;
end;
{ @end $473584 }

end.
