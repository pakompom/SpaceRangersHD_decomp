unit GI_Panel;

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

    constructor Create(Owner: TObjectGI); // @addr 0x004BE528
    destructor Destroy; override; // @addr 0x004BE574
    procedure Clear; override; // @addr 0x004BE59C
    function GetChildAbsolutePosition(LocalPosition: TPoint; ModeW: Boolean): TPoint; override; // @addr 0x004BE5D0 @note "Only ModeW children are affected by scrolling."
    function ToLocalPoint(Point: TPoint): TPoint; override; // @addr 0x004BE618
    function ToAbsolutePoint(Point: TPoint): TPoint; override; // @addr 0x004BE644
    procedure SetDragScrollingEnabled(Value: Boolean); // @addr 0x004BE670
    procedure SetScrollOffset(Offset: TPoint); virtual; // @addr 0x004BE69C @slot 0xC8
    function GetVisibleContentRect: TRect; // @addr 0x004BE974
    procedure ScrollRectIntoView(Rect: TRect); // @addr 0x004BE998
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override; // @addr $4BEA9C
    procedure ProcessRightButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4BEC18
    procedure ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint); override; // @addr $4BECA8
    procedure OnActivate; override; // @addr 0x004BEA88
    procedure OnMouseEnter; override; // @addr 0x004BEBAC
    procedure OnMouseLeave; override; // @addr 0x004BEBC0
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004BED10
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004BEE70
  end;

implementation

uses Classes, EC_Str, GI_Main, GR_Main, SysUtils;


{ @routine $4BE528 TPanelGI_Create }
constructor TPanelGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  SkipOwnQueuedDraw := 1;
  DragScrollingEnabled := False;
  ScrollType := pstAll;
end;
{ @end $4BE528 }

{ @routine $4BE574 TPanelGI_Destroy }
destructor TPanelGI.Destroy;
begin
  inherited Destroy;
end;
{ @end $4BE574 }

{ @routine $4BE59C TPanelGI_Clear }
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
{ @end $4BE59C }

{ @routine $4BE5D0 TPanelGI_GetChildAbsolutePosition }
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
{ @end $4BE5D0 }

{ @routine $4BE618 TPanelGI_ToLocalPoint }
function TPanelGI.ToLocalPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X - AbsolutePosition.X + ScrollOffset.X;
  Result.Y := Point.Y - AbsolutePosition.Y + ScrollOffset.Y;
end;
{ @end $4BE618 }

{ @routine $4BE644 TPanelGI_ToAbsolutePoint }
function TPanelGI.ToAbsolutePoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X + AbsolutePosition.X - ScrollOffset.X;
  Result.Y := Point.Y + AbsolutePosition.Y - ScrollOffset.Y;
end;
{ @end $4BE644 }

{ @routine $4BE670 TPanelGI_SetDragScrollingEnabled }
procedure TPanelGI.SetDragScrollingEnabled(Value: Boolean);
begin
  if Value = DragScrollingEnabled then Exit;
  DragScrollingEnabled := Value;
  UpdateAbsolutePosition;
  UpdateSubtreeHitBounds;
  Invalidate;
end;
{ @end $4BE670 }

{ @routine $4BE69C TPanelGI_SetScrollOffset }
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
{ @end $4BE69C }

{ @routine $4BE974 TPanelGI_GetVisibleContentRect }
function TPanelGI.GetVisibleContentRect: TRect;
begin
  Result.Left := ScrollOffset.X - OriginPoint.X;
  Result.Top := ScrollOffset.Y - OriginPoint.Y;
  Result.Right := Result.Left + ClientSize.X;
  Result.Bottom := Result.Top + ClientSize.Y;
end;
{ @end $4BE974 }

{ @routine $4BE998 TPanelGI_ScrollRectIntoView }
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
{ @end $4BE998 }

{ @routine $4BEA88 TPanelGI_OnActivate }
procedure TPanelGI.OnActivate;
begin
  inherited OnActivate;
  Dragging := False;
end;
{ @end $4BEA88 }

{ @routine $4BEA9C TPanelGI_ProcessMouseMove }
procedure TPanelGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var X, Y: Integer;
begin
  inherited ProcessMouseMove(KeyState, Point);
  if Dragging <> True then Exit;
  if (Point.X = LastDragPoint.X) and (Point.Y = LastDragPoint.Y) then Exit;
  if MessageLoop.IsCursorImageSelected('Main') then MessageLoop.SetCursorByName('Scroll');
  if (ScrollAxis = psaHorizontal) or (ScrollAxis = psaBoth) then X := ScrollOffset.X + LastDragPoint.X - Point.X
  else X := ScrollOffset.X;
  if (ScrollAxis = psaVertical) or (ScrollAxis = psaBoth) then Y := ScrollOffset.Y + LastDragPoint.Y - Point.Y
  else Y := ScrollOffset.Y;
  SetScrollOffset(Classes.Point(X, Y));
  LastDragPoint := Point;
  if Assigned(ScrollChangedCallback) then ScrollChangedCallback(Self);
end;
{ @end $4BEA9C }

{ @routine $4BEBAC TPanelGI_OnMouseEnter }
procedure TPanelGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
  Dragging := False;
end;
{ @end $4BEBAC }

{ @routine $4BEBC0 TPanelGI_OnMouseLeave }
procedure TPanelGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  Dragging := False;
  if MessageLoop.IsCursorImageSelected('Scroll') then MessageLoop.SetCursorByName('Main');
end;
{ @end $4BEBC0 }

{ @routine $4BEC18 TPanelGI_ProcessRightButtonDown }
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
{ @end $4BEC18 }

{ @routine $4BECA8 TPanelGI_ProcessRightButtonUp }
procedure TPanelGI.ProcessRightButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessRightButtonUp(KeyState, Point);
  Dragging := False;
  if MessageLoop.IsCursorImageSelected('Scroll') then MessageLoop.SetCursorByName('Main');
end;
{ @end $4BECA8 }

{ @routine $4BED10 TPanelGI_LoadFromConfigPath }
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
{ @end $4BED10 }

{ @routine $4BEE70 TPanelGI_LoadFromBlock }
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
{ @end $4BEE70 }

end.
