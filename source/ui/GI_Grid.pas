unit GI_Grid;
// Unit bracket (inferred): .text 0x004ABA08..0x004AE974; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, GI_Frame, GI_Image, GI_Label, GI_MessageLoop, GI_PanelScrollBar, Types;

type
  TGridTypeGI = (gtHide = 0, gtCell = 1, gtRow = 2, gtCol = 3); // @size 1

  TGridRowGI = record // @size 0x0C
    Height: Integer; // @offset 0x00
    AutoHeightMinimum: Integer; // @offset 0x04
    AutoHeight: Boolean; // @offset 0x08
  end;
  PGridRowGI = ^TGridRowGI;
  TGridRowsGI = array of TGridRowGI;
  TGridCanSelectCellEventGI = function(Sender: TObjectGI; Cell: TPoint): Boolean of object;

  TGridGI = class(TPanelScrollBarGI) // @size 0x1C0
  public
    ColumnCount: Integer; // @offset 0x170
    RowCount: Integer; // @offset 0x174
    ColumnWidths: ^Integer; // @offset 0x178
    Rows: array of TGridRowGI; // @offset 0x17C
    FontName: WideString; // @offset 0x180
    TextColor: Cardinal; // @offset 0x184
    GridType: TGridTypeGI; // @offset 0x188
    GridColor: Cardinal; // @offset 0x18C
    BackgroundImage: TImageGI; // @offset 0x190
    ActiveCellImage: TImageGI; // @offset 0x194
    ActiveCellFrame: TFrameGI; // @offset 0x198
    ActiveCell: TPoint; // @offset 0x19C
    RowSelect: Boolean; // @offset 0x1A4
    ColSelect: Boolean; // @offset 0x1A5
    SelectionChangedCallback: TObjectNotifyEventGI; // @offset $1A8
    CanSelectCellCallback: TGridCanSelectCellEventGI; // @offset $1B0
    RepeatedCellClickCallback: TObjectNotifyEventGI; // @offset $1B8
    // Rows points into a Delphi dynamic array. ColumnWidths uses the EC heap.
    // Each cell is a TLabelGI child with column/row packed into the dword at +0x8C.

    constructor Create(Owner: TObjectGI); // @addr 0x4ABB60
    destructor Destroy; override; // @addr 0x4ABC90
    procedure Clear; override; // @addr 0x4ABCC8
    procedure LayoutCell(Child: TObjectGI); // @addr 0x4ABDB8
    procedure LayoutCells; // @addr 0x4ABF28
    procedure UpdateGridExtent; // @addr 0x4ABF64
    procedure RebuildGridLines; // @addr 0x4AC078 @note "Type 0 hides lines, 1 draws both axes, 2 horizontal separators, 3 vertical separators; nonzero types include the outer border."
    procedure UpdateRowAutoHeight(RowIndex: Integer); // @addr 0x4AC528
    procedure UpdateActiveCellVisibility; // @addr 0x4AC5CC
    procedure SetColumnCount(Value: Integer); // @addr 0x4AC710 @note "New columns default to 100 pixels."
    procedure SetRowCount(Value: Integer); // @addr 0x4AC880 @note "New rows default to 15 pixels."
    procedure SetGridType(Value: TGridTypeGI); // @addr 0x4ACA24
    function GetColumnWidth(ColumnIndex: Integer): Integer; // @addr 0x4ACA6C
    procedure SetColumnWidth(ColumnIndex, Width: Integer); // @addr 0x4ACB9C
    function GetRowHeight(RowIndex: Integer): Integer; // @addr 0x4ACC00
    procedure SetRowHeight(RowIndex, Height: Integer); // @addr 0x4ACD20 @note "Also updates AutoHeightMinimum when the row's AutoHeight flag is set."
    procedure SetRowAutoHeightEnabled(RowIndex: Integer; Enabled: Boolean); // @addr 0x4ACDE0 @note "Does not validate RowIndex."
    function GetCell(CellX, CellY: Integer): TLabelGI; // @addr 0x4ACE2C @note "Raises for out-of-range coordinates or a missing cell label."
    procedure SetRowSelectEnabled(Value: Boolean); // @addr 0x4AD048
    procedure SetColSelectEnabled(Value: Boolean); // @addr 0x4AD080
    procedure SetBackgroundImagePath(Path: WideString); // @addr 0x4AD0B8
    procedure SetActiveCellImagePath(Path: WideString); // @addr 0x4AD190
    procedure SetActiveCellImageHalfAlpha(Value: Boolean); // @addr 0x4AD2B0
    procedure SetActiveCell(Cell: TPoint); // @addr 0x4AD2E0 @note "Invalid coordinates become (-1,-1); valid cells are scrolled into view."
    procedure SelectCell(Cell: TPoint); // @addr 0x4AD690 @note "Selection can be vetoed by the callback."
    procedure CellClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint); // @addr 0x4AD724
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4AD984
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4AD9BC
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override; // @addr $4AD840
    procedure OnFocusGained; override; // @addr $4AD890
    procedure OnFocusLost; override; // @addr $4AD8A4
    procedure ProcessKeyDown(Key: Integer); override; // @addr $4AD8B8
    procedure Draw(ClipRect: TRect); override; // @addr $4AE950
    procedure LoadGridProperties(Block: TBlockParEC); // @addr 0x4AD9E4
  end;

implementation

uses Classes, SysUtils, Windows, EC_Mem, EC_Str, GI_Main, GI_Line, GR_Main;

const
  // Cell UserValue packs the column below the row; decorations use -1.
  GridCellCoordinateMask = $FFFF;
  GridCellRowShift = 16;
  GridDecorationTag = -1;

{ @routine $4ABB60 TGridGI_Create }
constructor TGridGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  TextColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  GridType := gtCell;
  GridColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  ActiveCellFrame := TFrameGI.Create(Self);
  ActiveCellFrame.SetPositionModeW(True);
  ActiveCellFrame.SetKind(fkRect);
  ActiveCellFrame.SetDepth(-3);
  ActiveCellFrame.SetColor(CurrentPixelFormat.PackRgbBytes(255, 0, 0));
  ActiveCellFrame.UserValue := GridDecorationTag;
  SetDragScrollingEnabled(True);
  SetScrollbarsOutside(True);
  SetUnlimitedWorldEnabled(False);
end;
{ @end $4ABB60 }

{ @routine $4ABC90 TGridGI_Destroy }
destructor TGridGI.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{ @end $4ABC90 }

{ @routine $4ABCC8 TGridGI_Clear }
procedure TGridGI.Clear;
begin
  if ControlName = 'DebugGrid' then SetColumnCount(0);
  SetColumnCount(0);
  SetRowCount(0);
  if ColumnWidths <> nil then FreeEC(ColumnWidths);
  ColumnWidths := nil;
  TextColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  GridType := gtCell;
  GridColor := CurrentPixelFormat.PackRgbBytes(255, 255, 255);
  BackgroundImage := nil;
  ActiveCellImage := nil;
  ActiveCell.X := -1;
  ActiveCell.Y := -1;
end;
{ @end $4ABCC8 }

{ @routine $4ABDB8 TGridGI_LayoutCell }
procedure TGridGI.LayoutCell(Child: TObjectGI);
var X, Y, I: Integer;
begin
  if Child is TLabelGI then
  begin
    Child.SetSize(Classes.Point(GetColumnWidth(Child.UserValue and GridCellCoordinateMask) + 1, GetRowHeight(Child.UserValue shr GridCellRowShift) + 1));
    X := 0;
    Y := 0;
    for I := 0 to (Child.UserValue and GridCellCoordinateMask) - 1 do X := X + GetColumnWidth(I);
    for I := 0 to (Child.UserValue shr GridCellRowShift) - 1 do Y := Y + GetRowHeight(I);
    Child.SetPosition(Classes.Point(X, Y));
    if not Child.PositionModeW then
    begin
      Child.SetPositionModeW(True);
      Child.SetDepth(-1);
      with Child as TLabelGI do
      begin
        SetFontName(Self.FontName);
        SetTextAlignX(taxLeft);
        SetTextAlignY(tayTop);
        LeftButtonDownCallback := CellClick;
        SetTextColor(Self.TextColor);
      end;
    end;
  end;
end;
{ @end $4ABDB8 }

{ @routine $4ABF28 TGridGI_LayoutCells }
procedure TGridGI.LayoutCells;
var Child, Current: TObjectGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    Current := Child;
    Child := Child.NextSibling;
    LayoutCell(Current);
  end;
end;
{ @end $4ABF28 }

{ @routine $4ABF64 TGridGI_UpdateGridExtent }
procedure TGridGI.UpdateGridExtent;
var X, Y, I: Integer;
begin
  X := 0;
  Y := 0;
  for I := 0 to ColumnCount - 1 do X := X + GetColumnWidth(I);
  for I := 0 to RowCount - 1 do Y := Y + GetRowHeight(I);
  if BackgroundImage <> nil then BackgroundImage.SetSize(Classes.Point(X, Y));
  if (ActiveCell.X < 0) or (ActiveCell.X >= ColumnCount) or (ActiveCell.Y < 0) or (ActiveCell.Y >= RowCount) then
    ActiveCell := Classes.Point(-1, -1);
  RebuildGridLines;
  UpdateScrollRanges;
end;
{ @end $4ABF64 }

{ @routine $4AC078 TGridGI_RebuildGridLines }
procedure TGridGI.RebuildGridLines;
var Child, Current: TObjectGI; X, Y, I, Position: Integer; Line: TLineGI;
begin
  Child := FirstChild;
  while Child <> nil do
  begin
    Current := Child;
    Child := Child.NextSibling;
    if Current is TLineGI then FreeOwnedChild(Current);
  end;
  if (GridType = gtHide) or (ColumnCount < 1) or (RowCount < 1) then Exit;
  X := 0;
  Y := 0;
  for I := 0 to ColumnCount - 1 do X := X + GetColumnWidth(I);
  for I := 0 to RowCount - 1 do Y := Y + GetRowHeight(I);
  if ((GridType = gtCell) or (GridType = gtRow)) and (RowCount >= 2) then
  begin
    Position := GetRowHeight(0);
    for I := 1 to RowCount - 1 do
    begin
      Line := TLineGI.Create(Self);
      Line.SetPosition(Classes.Point(0, Position));
      Line.SetSize(Classes.Point(X + 1, 1));
      Line.SetPositionModeW(True);
      Line.SetColor(GridColor);
      Line.SetDepth(-2);
      Line.UserValue := GridDecorationTag;
      Position := Position + GetRowHeight(I);
    end;
  end;
  if ((GridType = gtCell) or (GridType = gtCol)) and (ColumnCount >= 2) then
  begin
    Position := GetColumnWidth(0);
    for I := 1 to ColumnCount - 1 do
    begin
      Line := TLineGI.Create(Self);
      Line.SetPosition(Classes.Point(Position, 0));
      Line.SetSize(Classes.Point(1, Y + 1));
      Line.SetPositionModeW(True);
      Line.SetColor(GridColor);
      Line.SetDepth(-2);
      Line.UserValue := GridDecorationTag;
      Position := Position + GetColumnWidth(I);
    end;
  end;
  Line := TLineGI.Create(Self);
  Line.SetPosition(Classes.Point(0, 0));
  Line.SetSize(Classes.Point(X + 1, 1));
  Line.SetPositionModeW(True);
  Line.SetColor(GridColor);
  Line.SetDepth(-2);
  Line.UserValue := GridDecorationTag;
  Line := TLineGI.Create(Self);
  Line.SetPosition(Classes.Point(0, Y));
  Line.SetSize(Classes.Point(X + 1, 1));
  Line.SetPositionModeW(True);
  Line.SetColor(GridColor);
  Line.SetDepth(-2);
  Line.UserValue := GridDecorationTag;
  Line := TLineGI.Create(Self);
  Line.SetPosition(Classes.Point(0, 0));
  Line.SetSize(Classes.Point(1, Y + 1));
  Line.SetPositionModeW(True);
  Line.SetColor(GridColor);
  Line.SetDepth(-2);
  Line.UserValue := GridDecorationTag;
  Line := TLineGI.Create(Self);
  Line.SetPosition(Classes.Point(X, 0));
  Line.SetSize(Classes.Point(1, Y + 1));
  Line.SetPositionModeW(True);
  Line.SetColor(GridColor);
  Line.SetDepth(-2);
  Line.UserValue := GridDecorationTag;
end;
{ @end $4AC078 }

{ @routine $4AC528 TGridGI_UpdateRowAutoHeight }
procedure TGridGI.UpdateRowAutoHeight(RowIndex: Integer);
var Child: TObjectGI; Height, CellHeight: Integer;
begin
  Height := Rows[RowIndex].AutoHeightMinimum;
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child is TLabelGI) and (Child.UserValue shr GridCellRowShift = RowIndex) then
    begin
      CellHeight := (Child as TLabelGI).MeasureContentSize(nil).Y + 2;
      if CellHeight > Height then Height := CellHeight;
    end;
    Child := Child.NextSibling;
  end;
  SetRowHeight(RowIndex, Height);
end;
{ @end $4AC528 }

{ @routine $4AC5CC TGridGI_UpdateActiveCellVisibility }
procedure TGridGI.UpdateActiveCellVisibility;
var Rect: TRect;
begin
  if (ActiveCell.X >= ColumnCount) or (ActiveCell.Y >= RowCount) then ActiveCell := Classes.Point(-1, -1);
  Rect.Left := ActiveCellFrame.LocalPosition.X;
  Rect.Top := ActiveCellFrame.LocalPosition.Y;
  Rect.Right := ActiveCellFrame.LocalPosition.X + ActiveCellFrame.ClientSize.X;
  Rect.Bottom := ActiveCellFrame.LocalPosition.Y + ActiveCellFrame.ClientSize.Y;
  ScrollRectIntoView(Rect);
  if (ActiveCell.X < 0) or (ActiveCell.Y < 0) then
  begin
    if ActiveCellFrame <> nil then ActiveCellFrame.SetActive(False);
    if ActiveCellImage <> nil then ActiveCellImage.SetActive(False);
  end else
  begin
    if ActiveCellFrame <> nil then ActiveCellFrame.SetActive(True);
    if ActiveCellImage <> nil then ActiveCellImage.SetActive(True);
  end;
end;
{ @end $4AC5CC }

{ @routine $4AC710 TGridGI_SetColumnCount }
procedure TGridGI.SetColumnCount(Value: Integer);
var Child, Current: TObjectGI; X, Y, OldCount: Integer;
begin
  if Value = ColumnCount then Exit;
  OldCount := ColumnCount;
  ColumnCount := Value;
  ColumnWidths := ReAllocREC(ColumnWidths, Value * SizeOf(Integer));
  if Value < OldCount then
  begin
    Child := FirstChild;
    while Child <> nil do
    begin
      Current := Child;
      Child := Child.NextSibling;
      if (Current is TLabelGI) and (Current.UserValue and GridCellCoordinateMask >= Value) and (Current.UserValue <> GridDecorationTag) then
        FreeOwnedChild(Current);
    end;
  end else
  begin
    for X := OldCount to Value - 1 do
    begin
      WriteIntegerEC(AddPointerOffset(ColumnWidths, X * SizeOf(Integer)), 100);
      for Y := 0 to RowCount - 1 do
      begin
        Child := TLabelGI.Create(Self);
        Child.UserValue := X or (Y shl GridCellRowShift);
        LayoutCell(Child);
      end;
    end;
  end;
  UpdateGridExtent;
  Invalidate;
end;
{ @end $4AC710 }

{ @routine $4AC880 TGridGI_SetRowCount }
procedure TGridGI.SetRowCount(Value: Integer);
var Child, Current: TObjectGI; X, Y, OldCount: Integer;
begin
  if Value = RowCount then Exit;
  OldCount := RowCount;
  RowCount := Value;
  SetLength(Rows, RowCount);
  if Value < OldCount then
  begin
    Child := FirstChild;
    while Child <> nil do
    begin
      Current := Child;
      Child := Child.NextSibling;
      if (Current is TLabelGI) and (Current.UserValue shr GridCellRowShift and GridCellCoordinateMask >= Value) and (Current.UserValue <> GridDecorationTag) then
        FreeOwnedChild(Current);
    end;
  end else
  begin
    for Y := OldCount to Value - 1 do
    begin
      Rows[Y].Height := 15;
      Rows[Y].AutoHeightMinimum := 15;
      Rows[Y].AutoHeight := False;
      for X := 0 to ColumnCount - 1 do
      begin
        Child := TLabelGI.Create(Self);
        Child.UserValue := X or (Y shl GridCellRowShift);
        LayoutCell(Child);
      end;
    end;
  end;
  UpdateActiveCellVisibility;
  UpdateGridExtent;
  Invalidate;
end;
{ @end $4AC880 }

{ @routine $4ACA24 TGridGI_SetGridType }
procedure TGridGI.SetGridType(Value: TGridTypeGI);
begin
  if Value <> GridType then
  begin
    GridType := Value;
    LayoutCells;
    UpdateGridExtent;
    Invalidate;
  end;
end;
{ @end $4ACA24 }

{ @routine $4ACA6C TGridGI_GetColumnWidth }
function TGridGI.GetColumnWidth(ColumnIndex: Integer): Integer;
begin
  if (ColumnIndex < 0) or (ColumnIndex >= ColumnCount) then
    raise Exception.Create('TGridGI.GetSizeX. (' + IntToStr(ColumnIndex) + '<0) or (' + IntToStr(ColumnIndex) + '>0' + IntToStr(ColumnCount) + ')');
  Result := ReadIntegerEC(AddPointerOffset(ColumnWidths, ColumnIndex * SizeOf(Integer)));
end;
{ @end $4ACA6C }

{ @routine $4ACB9C TGridGI_SetColumnWidth }
procedure TGridGI.SetColumnWidth(ColumnIndex, Width: Integer);
begin
  if GetColumnWidth(ColumnIndex) <> Width then
  begin
    WriteInt32EC(AddPointerOffset(ColumnWidths, ColumnIndex * SizeOf(Integer)), Width);
    LayoutCells;
    UpdateGridExtent;
    Invalidate;
  end;
end;
{ @end $4ACB9C }

{ @routine $4ACC00 TGridGI_GetRowHeight }
function TGridGI.GetRowHeight(RowIndex: Integer): Integer;
begin
  if (RowIndex < 0) or (RowIndex >= RowCount) then
    raise Exception.Create('TGridGI.GetSizeX. (' + IntToStr(RowIndex) + '<0) or (' + IntToStr(RowIndex) + '>=' + IntToStr(RowCount) + ')');
  Result := Rows[RowIndex].Height;
end;
{ @end $4ACC00 }

{ @routine $4ACD20 TGridGI_SetRowHeight }
procedure TGridGI.SetRowHeight(RowIndex, Height: Integer);
var Cell: TPoint;
begin
  if GetRowHeight(RowIndex) <> Height then
  begin
    Rows[RowIndex].Height := Height;
    if Rows[RowIndex].AutoHeight then Rows[RowIndex].AutoHeightMinimum := Rows[RowIndex].Height;
    LayoutCells;
    UpdateGridExtent;
    Cell := ActiveCell;
    ActiveCell.X := -2;
    SetActiveCell(Cell);
    Invalidate;
  end;
end;
{ @end $4ACD20 }

{ @routine $4ACDE0 TGridGI_SetRowAutoHeightEnabled }
procedure TGridGI.SetRowAutoHeightEnabled(RowIndex: Integer; Enabled: Boolean);
begin
  if Rows[RowIndex].AutoHeight <> Enabled then
  begin
    Rows[RowIndex].AutoHeight := Enabled;
    UpdateRowAutoHeight(RowIndex);
  end;
end;
{ @end $4ACDE0 }

{ @routine $4ACE2C TGridGI_GetCell }
function TGridGI.GetCell(CellX, CellY: Integer): TLabelGI;
var Child: TObjectGI;
begin
  if (CellX < 0) or (ColumnCount <= CellX) or (CellY < 0) or (RowCount <= CellY) then
    raise Exception.Create('TGridGI.GetCell. Cell=' + IntToStr(CellX) + ',' + IntToStr(CellY) + '  Count=' + IntToStr(ColumnCount) + ',' + IntToStr(RowCount));
  Child := FirstChild;
  while Child <> nil do
  begin
    if (Child is TLabelGI) and (Child.UserValue and GridCellCoordinateMask = CellX) and (Child.UserValue shr GridCellRowShift = CellY) then
    begin
      Result := Child as TLabelGI;
      Exit;
    end;
    Child := Child.NextSibling;
  end;
  raise Exception.Create('TGridGI.GetCell. Cell=' + IntToStr(CellX) + ',' + IntToStr(CellY) + '  Count=' + IntToStr(ColumnCount) + ',' + IntToStr(RowCount));
end;
{ @end $4ACE2C }

{ @routine $4AD048 TGridGI_SetRowSelectEnabled }
procedure TGridGI.SetRowSelectEnabled(Value: Boolean);
begin
  if RowSelect <> Value then
  begin
    RowSelect := Value;
    Invalidate;
  end;
end;
{ @end $4AD048 }

{ @routine $4AD080 TGridGI_SetColSelectEnabled }
procedure TGridGI.SetColSelectEnabled(Value: Boolean);
begin
  if ColSelect <> Value then
  begin
    ColSelect := Value;
    Invalidate;
  end;
end;
{ @end $4AD080 }

{ @routine $4AD0B8 TGridGI_SetBackgroundImagePath }
procedure TGridGI.SetBackgroundImagePath(Path: WideString);
var Image: TImageGI;
begin
  if BackgroundImage <> nil then
  begin
    FreeOwnedChild(BackgroundImage);
    BackgroundImage := nil;
  end;
  Image := TImageGI.Create(Self);
  Image.UserValue := GridDecorationTag;
  Image.SetDepth(2);
  Image.SetImagePath(Path);
  Image.SetImageKindX(ikxLeftFill);
  Image.SetImageKindY(ikyTopFill);
  Image.SetPositionModeW(True);
  BackgroundImage := Image;
  UpdateGridExtent;
end;
{ @end $4AD0B8 }

{ @routine $4AD190 TGridGI_SetActiveCellImagePath }
procedure TGridGI.SetActiveCellImagePath(Path: WideString);
begin
  if Path = '' then
  begin
    if ActiveCellImage <> nil then
    begin
      FreeOwnedChild(ActiveCellImage);
      ActiveCellImage := nil;
    end;
  end else
  begin
    if ActiveCellImage = nil then ActiveCellImage := TImageGI.Create(Self);
    ActiveCellImage.SetImagePath(Path);
    ActiveCellImage.SetImageKindX(ikxLeftFill);
    ActiveCellImage.SetImageKindY(ikyTopFill);
    ActiveCellImage.UserValue := GridDecorationTag;
    ActiveCellImage.SetDepth(1);
    ActiveCellImage.SetPositionModeW(True);
  end;
  UpdateGridExtent;
  Invalidate;
end;
{ @end $4AD190 }

{ @routine $4AD2B0 TGridGI_SetActiveCellImageHalfAlpha }
procedure TGridGI.SetActiveCellImageHalfAlpha(Value: Boolean);
begin
  if ActiveCellImage <> nil then ActiveCellImage.SetHalfAlpha(Value);
end;
{ @end $4AD2B0 }

{ @routine $4AD2E0 TGridGI_SetActiveCell }
procedure TGridGI.SetActiveCell(Cell: TPoint);
var LabelControl: TLabelGI;
begin
  if (ActiveCell.X = Cell.X) and (ActiveCell.Y = Cell.Y) then Exit;
  ActiveCell := Cell;
  if (ActiveCell.X >= 0) and (ActiveCell.X < ColumnCount) and (ActiveCell.Y >= 0) and (ActiveCell.Y < RowCount) then
  begin
    if ActiveCellImage <> nil then
    begin
      if not RowSelect and not ColSelect then
      begin
        LabelControl := GetCell(ActiveCell.X, ActiveCell.Y);
        ActiveCellImage.SetPosition(LabelControl.LocalPosition);
        ActiveCellImage.SetSize(LabelControl.ClientSize);
      end else if RowSelect then
      begin
        LabelControl := GetCell(0, ActiveCell.Y);
        ActiveCellImage.SetPosition(LabelControl.LocalPosition);
        LabelControl := GetCell(ColumnCount - 1, ActiveCell.Y);
        ActiveCellImage.SetSize(Classes.Point(LabelControl.LocalPosition.X + LabelControl.ClientSize.X, LabelControl.ClientSize.Y));
      end else if ColSelect then
      begin
        LabelControl := GetCell(ActiveCell.X, 0);
        ActiveCellImage.SetPosition(LabelControl.LocalPosition);
        LabelControl := GetCell(ActiveCell.X, RowCount - 1);
        ActiveCellImage.SetSize(Classes.Point(LabelControl.ClientSize.X, LabelControl.LocalPosition.Y + LabelControl.ClientSize.Y));
      end;
    end;
      if not RowSelect and not ColSelect then
      begin
        LabelControl := GetCell(ActiveCell.X, ActiveCell.Y);
        ActiveCellFrame.SetPosition(LabelControl.LocalPosition);
        ActiveCellFrame.SetSize(LabelControl.ClientSize);
      end else if RowSelect then
      begin
        LabelControl := GetCell(0, ActiveCell.Y);
        ActiveCellFrame.SetPosition(LabelControl.LocalPosition);
        LabelControl := GetCell(ColumnCount - 1, ActiveCell.Y);
        ActiveCellFrame.SetSize(Classes.Point(LabelControl.LocalPosition.X + LabelControl.ClientSize.X, LabelControl.ClientSize.Y));
      end else if ColSelect then
      begin
        LabelControl := GetCell(ActiveCell.X, 0);
        ActiveCellFrame.SetPosition(LabelControl.LocalPosition);
        LabelControl := GetCell(ActiveCell.X, RowCount - 1);
        ActiveCellFrame.SetSize(Classes.Point(LabelControl.ClientSize.X, LabelControl.LocalPosition.Y + LabelControl.ClientSize.Y));
      end;
  end else ActiveCell := Classes.Point(-1, -1);
  UpdateActiveCellVisibility;
  Invalidate;
end;
{ @end $4AD2E0 }

{ @routine $4AD690 TGridGI_SelectCell }
procedure TGridGI.SelectCell(Cell: TPoint);
begin
  if (Cell.X < 0) or (Cell.X >= ColumnCount) or (Cell.Y < 0) or (Cell.Y >= RowCount) then Exit;
  if Assigned(CanSelectCellCallback) then
    if not CanSelectCellCallback(Self, Cell) then Exit;
  SetActiveCell(Cell);
  if Assigned(SelectionChangedCallback) then SelectionChangedCallback(Self);
end;
{ @end $4AD690 }

{ @routine $4AD724 TGridGI_CellClick }
procedure TGridGI.CellClick(Sender: TObjectGI; MouseState: Cardinal; Point: TPoint);
var Cell: TPoint; Repeated: Boolean;
begin
  Cell := Classes.Point(Sender.UserValue and GridCellCoordinateMask, Sender.UserValue shr GridCellRowShift);
  if Assigned(CanSelectCellCallback) then
    if not CanSelectCellCallback(Self, Cell) then Exit;
  if ((ActiveCell.Y = Cell.Y) and RowSelect) or ((ActiveCell.X = Cell.X) and ColSelect) or ((ActiveCell.X = Cell.X) and (ActiveCell.Y = Cell.Y)) then Repeated := True else Repeated := False;
  SetActiveCell(Cell);
  if Repeated then
  begin
    if Assigned(RepeatedCellClickCallback) then RepeatedCellClickCallback(Self);
  end else
    if Assigned(SelectionChangedCallback) then SelectionChangedCallback(Self);
end;
{ @end $4AD724 }

{ @routine $4AD840 TGridGI_ProcessLeftButtonDown }
procedure TGridGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
begin
  if IsOccludedAtPoint(Point) then Exit;
  inherited ProcessLeftButtonDown(KeyState, Point);
  if Active = True then MessageLoop.SetFocusedControl(Self);
end;
{ @end $4AD840 }

{ @routine $4AD890 TGridGI_OnFocusGained }
procedure TGridGI.OnFocusGained;
begin
  inherited OnFocusGained;
end;
{ @end $4AD890 }

{ @routine $4AD8A4 TGridGI_OnFocusLost }
procedure TGridGI.OnFocusLost;
begin
  inherited OnFocusLost;
end;
{ @end $4AD8A4 }

{ @routine $4AD8B8 TGridGI_ProcessKeyDown }
procedure TGridGI.ProcessKeyDown(Key: Integer);
begin
  if Key = VK_LEFT then SelectCell(Classes.Point(ActiveCell.X - 1, ActiveCell.Y))
  else if Key = VK_RIGHT then SelectCell(Classes.Point(ActiveCell.X + 1, ActiveCell.Y))
  else if Key = VK_UP then SelectCell(Classes.Point(ActiveCell.X, ActiveCell.Y - 1))
  else if Key = VK_DOWN then SelectCell(Classes.Point(ActiveCell.X, ActiveCell.Y + 1));
end;
{ @end $4AD8B8 }

{ @routine $4AD984 TGridGI_LoadFromConfigPath }
procedure TGridGI.LoadFromConfigPath(const Path: WideString);
var Block: TBlockParEC;
begin
  inherited LoadFromConfigPath(Path);
  Block := UiStyleConfig.GetBlockByPath(Path);
  LoadGridProperties(Block);
end;
{ @end $4AD984 }

{ @routine $4AD9BC TGridGI_LoadFromBlock }
procedure TGridGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadGridProperties(Block);
end;
{ @end $4AD9BC }

{ @routine $4AD9E4 TGridGI_LoadGridProperties }
procedure TGridGI.LoadGridProperties(Block: TBlockParEC);
var
  Text: WideString;
  Red, Green, Blue: Byte;
  Properties, CellProperties: TBlockParEC;
  LabelControl: TLabelGI;
  I, RowIndex, Count, CellX, CellY: Integer;
begin
  if Block.CountParams('Font') > 0 then FontName := TrimWideString(Block.GetParam('Font'));
  if Block.CountParams('TextColor') > 0 then
  begin
    Text := Block.GetParam('TextColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    TextColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('GridType') > 0 then
  begin
    Text := TrimWideString(Block.GetParam('GridType'));
    if Text = 'Hide' then SetGridType(gtHide)
    else if Text = 'Cell' then SetGridType(gtCell)
    else if Text = 'Row' then SetGridType(gtRow)
    else if Text = 'Col' then SetGridType(gtCol);
  end;
  if Block.CountParams('GridColor') > 0 then
  begin
    Text := Block.GetParam('GridColor');
    Red := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
    Green := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
    Blue := StrToInt(ExtractDelimitedPartW(Text, 2, ','));
    GridColor := CurrentPixelFormat.PackRgbBytes(Red, Green, Blue);
  end;
  if Block.CountParams('CountX') > 0 then SetColumnCount(StrToInt(Block.GetParam('CountX')));
  if Block.CountParams('CountY') > 0 then SetRowCount(StrToInt(Block.GetParam('CountY')));
  if Block.CountBlocks('GridX') > 0 then
  begin
    Properties := Block.GetBlock('GridX');
    Count := Properties.GetParamCount;
    for I := 0 to Count - 1 do
      SetColumnWidth(StrToInt(Properties.GetParamName(I)), StrToInt(Properties.GetParamValue(I)));
  end;
  if Block.CountBlocks('GridY') > 0 then
  begin
    Properties := Block.GetBlock('GridY');
    Count := Properties.GetParamCount;
    for I := 0 to Count - 1 do
    begin
      Text := TrimWideString(Properties.GetParamValue(I));
      RowIndex := StrToInt(Properties.GetParamName(I));
      if CountDelimitedPartsW(Text, ',') < 2 then
      begin
        Rows[RowIndex].AutoHeightMinimum := StrToInt(Text);
        SetRowHeight(RowIndex, StrToInt(Text));
        Rows[RowIndex].AutoHeight := False;
      end else
      begin
        if ExtractDelimitedPartW(Text, 1, ',') = 'Auto' then SetRowAutoHeightEnabled(RowIndex, True)
        else SetRowAutoHeightEnabled(RowIndex, False);
        SetRowHeight(RowIndex, StrToInt(ExtractDelimitedPartW(Text, 0, ',')));
      end;
    end;
  end;
  if Block.CountBlocks('GridCells') > 0 then
  begin
    Properties := Block.GetBlock('GridCells');
    Count := Properties.GetParamCount;
    for I := 0 to Count - 1 do
    begin
      Text := Properties.GetParamName(I);
      RowIndex := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
      GetCell(StrToInt(ExtractDelimitedPartW(Text, 0, ',')), RowIndex).LoadTextLinesFromBlockParam(Properties, Text);
      if Rows[RowIndex].AutoHeight then UpdateRowAutoHeight(RowIndex);
    end;
    Count := Properties.GetBlockCount;
    for I := 0 to Count - 1 do
    begin
      Text := Properties.GetBlockNameByIndex(I);
      CellX := StrToInt(ExtractDelimitedPartW(Text, 0, ','));
      CellY := StrToInt(ExtractDelimitedPartW(Text, 1, ','));
      LabelControl := GetCell(CellX, CellY);
      CellProperties := Properties.GetBlockByIndex(I);
      if CellProperties.CountParams('WordWrap') > 0 then LabelControl.SetWordWrapEnabled(ParseEnabledNameGI(TrimWideString(CellProperties.GetParam('WordWrap'))));
      if CellProperties.CountParams('AlignY') > 0 then LabelControl.SetTextAlignY(ParseTextAlignYName(TrimWideString(CellProperties.GetParam('AlignY'))));
      if CellProperties.CountParams('AlignX') > 0 then LabelControl.SetTextAlignX(ParseTextAlignXName(TrimWideString(CellProperties.GetParam('AlignX'))));
      if CellProperties.CountParams('TextColor') > 0 then LabelControl.SetTextColor(GetColorGI(Block.GetParam('TextColor')));
      if CellProperties.CountParams('Image') > 0 then LabelControl.SetEmbeddedImagePath(CellProperties.GetParam('Image'));
      if CellProperties.CountParams('ImageKindX') > 0 then LabelControl.SetEmbeddedImageKindX(ParseImageKindXName(CellProperties.GetParam('ImageKindX')));
      if CellProperties.CountParams('ImageKindY') > 0 then LabelControl.SetEmbeddedImageKindY(ParseImageKindYName(CellProperties.GetParam('ImageKindY')));
      if CellProperties.CountParams('ImageHalfAlpha') > 0 then LabelControl.SetEmbeddedImageHalfAlpha(ParseEnabledNameGI(CellProperties.GetParam('ImageHalfAlpha')));
      UpdateRowAutoHeight(CellY);
    end;
  end;
  if Block.CountParams('BackgroundImage') > 0 then SetBackgroundImagePath(Block.GetParam('BackgroundImage'));
  if Block.CountParams('RowSelect') > 0 then
  begin
    if TrimWideString(Block.GetParam('RowSelect')) = 'True' then SetRowSelectEnabled(True)
    else SetRowSelectEnabled(False);
  end;
  if Block.CountParams('ColSelect') > 0 then
  begin
    if TrimWideString(Block.GetParam('ColSelect')) = 'True' then SetColSelectEnabled(True)
    else SetColSelectEnabled(False);
  end;
  if Block.CountParams('ActiveCellImage') > 0 then SetActiveCellImagePath(Block.GetParam('ActiveCellImage'));
  if Block.CountParams('ActiveCell') > 0 then
  begin
    Text := Block.GetParam('ActiveCell');
    SetActiveCell(Classes.Point(StrToInt(ExtractDelimitedPartW(Text, 0, ',')), StrToInt(ExtractDelimitedPartW(Text, 1, ','))));
  end;
  if Block.CountParams('ActiveCellImageHalfAlpha') > 0 then SetActiveCellImageHalfAlpha(ParseEnabledNameGI(Block.GetParam('ActiveCellImageHalfAlpha')));
end;
{ @end $4AD9E4 }

{ @routine $4AE950 TGridGI_Draw }
procedure TGridGI.Draw(ClipRect: TRect);
begin
  inherited Draw(ClipRect);
end;
{ @end $4AE950 }

end.
