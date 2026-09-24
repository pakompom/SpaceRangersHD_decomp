unit GI_MultiImage;
// Unit bracket (inferred): .text 0x0049A53C..0x0049B771; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses GI_MessageLoop, EC_CacheGI, EC_BlockPar, Classes, Types;

type
  TMultiImageUnitGI = class;
  TMultiImageColGI = class;
  TMultiImageRowGI = class;

  TMultiImageUnitGI = class(TObject) // @size $28
  public
    Prev: TMultiImageUnitGI; // @offset $04
    Next: TMultiImageUnitGI; // @offset $08
    PrevInColumn: TMultiImageUnitGI; // @offset $0C
    NextInColumn: TMultiImageUnitGI; // @offset $10
    Column: TMultiImageColGI; // @offset $14
    ImageIndex: Integer; // @offset $18
    Position: TPoint; // @offset $1C
    UserData: Pointer; // @offset $24 Borrowed application data; TfAB stores a path-node pointer.
  end;

  TMultiImageColGI = class(TObject) // @size $1C
  public
    Prev: TMultiImageColGI; // @offset $04
    Next: TMultiImageColGI; // @offset $08
    First: TMultiImageUnitGI; // @offset $0C
    Last: TMultiImageUnitGI; // @offset $10
    Row: TMultiImageRowGI; // @offset $14
    Index: Integer; // @offset $18
  end;

  TMultiImageRowGI = class(TObject) // @size $18
  public
    Prev: TMultiImageRowGI; // @offset $04
    Next: TMultiImageRowGI; // @offset $08
    First: TMultiImageColGI; // @offset $0C
    Last: TMultiImageColGI; // @offset $10
    Index: Integer; // @offset $14
  end;

  TMultiImageImageGI = class(TObject) // @size $18
  public
    ImageCache: TCGiControlEC; // @offset $04
    Bounds: TRect; // @offset $08
    constructor Create; // @addr $49A7E0
    destructor Destroy; override; // @addr $49A848
    procedure SetImage(Path: WideString); // @addr $49A88C
  end;

  TMultiImageGI = class(TObjectGI) // @size $138
  public
    FirstUnit: TMultiImageUnitGI; // @offset $120
    LastUnit: TMultiImageUnitGI; // @offset $124
    FirstRow: TMultiImageRowGI; // @offset $128
    LastRow: TMultiImageRowGI; // @offset $12C
    CellSize: Integer; // @offset $130
    Images: TList; // @offset $134
    constructor Create(Owner: TObjectGI); // @addr $49A980
    destructor Destroy; override; // @addr $49A9EC
    procedure Clear; override; // @addr $49AA48
    function AddUnit: TMultiImageUnitGI; // @addr $49AA6C
    procedure RemoveUnit(Item: TMultiImageUnitGI); // @addr $49AAE8
    procedure ClearUnits; // @addr $49AB78
    procedure UnlinkUnitFromColumn(Item: TMultiImageUnitGI); // @addr $49ABAC @note "Prunes empty columns and rows."
    procedure ClearSpatialIndex; // @addr $49AD4C @note "Preserves units and clears their spatial links."
    function GetOrCreateRow(Index: Integer): TMultiImageRowGI; // @addr $49AE04
    function GetOrCreateColumn(Row: TMultiImageRowGI; Index: Integer): TMultiImageColGI; // @addr $49AF1C
    procedure SetUnitPosition(Item: TMultiImageUnitGI; Position: TPoint); // @addr $49B028 @note "Native early-out compares the control's Position, not the item's old position. CellSize must be nonzero."
    procedure ClearImages; // @addr $49B118
    function AddImage(Path: WideString): Integer; // @addr $49B180
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr $49B204
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $49B238
    procedure LoadImageProperties(Block: TBlockParEC); // @addr $49B260 @note "Empty in native code."
    procedure Invalidate; override; // @addr $49B270
    procedure Draw(ClipRect: TRect); override; // @addr $49B46C
    procedure QueueImageLoad(PendingLoads: TList); override; // @addr $49B71C
  end;

implementation

uses EC_Cache, EC_Struct, GR_Main, GR_DX;

{ @routine $49A7E0 TMultiImageImageGI_Create }
constructor TMultiImageImageGI.Create;
begin
  inherited Create;
  ImageCache := TCGiControlEC.Create;
  GlobalCache.ResetControl(ImageCache);
end;
{ @end $49A7E0 }

{ @routine $49A848 TMultiImageImageGI_Destroy }
destructor TMultiImageImageGI.Destroy;
begin
  ImageCache.Free;
  ImageCache := nil;
  inherited Destroy;
end;
{ @end $49A848 }

{ @routine $49A88C TMultiImageImageGI_SetImage }
procedure TMultiImageImageGI.SetImage(Path: WideString);
var Data: TCGiEC; Size: TPoint;
begin
  if ImageCache.CacheKey <> Path then
  begin
    ImageCache.SetCacheKey(Path);
    Data := AcquireCachedGi(ImageCache);
    try
      Size := Data.Image.GetContentSize;
    finally
      ImageCache.Release;
    end;
    Bounds.Left := -Size.X div 2;
    Bounds.Top := -Size.Y div 2;
    Bounds.Right := Bounds.Left + Size.X;
    Bounds.Bottom := Bounds.Top + Size.Y;
  end;
end;
{ @end $49A88C }

{ @routine $49A980 TMultiImageGI_Create }
constructor TMultiImageGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  Images := TList.Create;
  CellSize := 128;
end;
{ @end $49A980 }

{ @routine $49A9EC TMultiImageGI_Destroy }
destructor TMultiImageGI.Destroy;
begin
  ClearImages;
  ClearUnits;
  Images.Free;
  Images := nil;
  inherited Destroy;
end;
{ @end $49A9EC }

{ @routine $49AA48 TMultiImageGI_Clear }
procedure TMultiImageGI.Clear;
begin
  ClearImages;
  ClearUnits;
  inherited Clear;
end;
{ @end $49AA48 }

{ @routine $49AA6C TMultiImageGI_AddUnit }
function TMultiImageGI.AddUnit: TMultiImageUnitGI;
var Item: TMultiImageUnitGI;
begin
  Item := TMultiImageUnitGI.Create;
  if LastUnit <> nil then LastUnit.Next := Item;
  Item.Prev := LastUnit;
  Item.Next := nil;
  LastUnit := Item;
  if FirstUnit = nil then FirstUnit := Item;
  Result := Item;
end;
{ @end $49AA6C }

{ @routine $49AAE8 TMultiImageGI_RemoveUnit }
procedure TMultiImageGI.RemoveUnit(Item: TMultiImageUnitGI);
begin
  UnlinkUnitFromColumn(Item);
  if Item.Prev <> nil then Item.Prev.Next := Item.Next;
  if Item.Next <> nil then Item.Next.Prev := Item.Prev;
  if LastUnit = Item then LastUnit := Item.Prev;
  if FirstUnit = Item then FirstUnit := Item.Next;
  Item.Free;
end;
{ @end $49AAE8 }

{ @routine $49AB78 TMultiImageGI_ClearUnits }
procedure TMultiImageGI.ClearUnits;
begin
  ClearSpatialIndex;
  while FirstUnit <> nil do RemoveUnit(LastUnit);
end;
{ @end $49AB78 }

{ @routine $49ABAC TMultiImageGI_UnlinkUnitFromColumn }
procedure TMultiImageGI.UnlinkUnitFromColumn(Item: TMultiImageUnitGI);
var Column: TMultiImageColGI; Row: TMultiImageRowGI;
begin
  if Item.Column <> nil then
  begin
    Column := Item.Column;
    if Item.PrevInColumn <> nil then Item.PrevInColumn.NextInColumn := Item.NextInColumn;
    if Item.NextInColumn <> nil then Item.NextInColumn.PrevInColumn := Item.PrevInColumn;
    if Column.Last = Item then Column.Last := Item.PrevInColumn;
    if Column.First = Item then Column.First := Item.NextInColumn;
    Item.PrevInColumn := nil;
    Item.NextInColumn := nil;
    if Column.Last <> nil then Item.Column := nil
    else
    begin
      Row := Item.Column.Row;
      Item.Column := nil;
      if Column.Prev <> nil then Column.Prev.Next := Column.Next;
      if Column.Next <> nil then Column.Next.Prev := Column.Prev;
      if Row.Last = Column then Row.Last := Column.Prev;
      if Row.First = Column then Row.First := Column.Next;
      Column.Free;
      if Row.Last = nil then
      begin
        if Row.Prev <> nil then Row.Prev.Next := Row.Next;
        if Row.Next <> nil then Row.Next.Prev := Row.Prev;
        if LastRow = Row then LastRow := Row.Prev;
        if FirstRow = Row then FirstRow := Row.Next;
        Row.Free;
      end;
    end;
  end;
end;
{ @end $49ABAC }

{ @routine $49AD4C TMultiImageGI_ClearSpatialIndex }
procedure TMultiImageGI.ClearSpatialIndex;
var Row, OldRow: TMultiImageRowGI; Column, OldColumn: TMultiImageColGI; Item: TMultiImageUnitGI;
begin
  Row := FirstRow;
  while Row <> nil do
  begin
    OldRow := Row;
    Row := Row.Next;
    Column := OldRow.First;
    while Column <> nil do
    begin
      OldColumn := Column;
      Column := Column.Next;
      OldColumn.Free;
    end;
    OldRow.Free;
  end;
  FirstRow := nil;
  LastRow := nil;
  Item := FirstUnit;
  while Item <> nil do
  begin
    Item.Column := nil;
    Item.PrevInColumn := nil;
    Item.NextInColumn := nil;
    Item := Item.Next;
  end;
end;
{ @end $49AD4C }

{ @routine $49AE04 TMultiImageGI_GetOrCreateRow }
function TMultiImageGI.GetOrCreateRow(Index: Integer): TMultiImageRowGI;
var Row: TMultiImageRowGI;
begin
  Row := FirstRow;
  while Row <> nil do
  begin
    if Row.Index = Index then
    begin
      Result := Row;
      Exit;
    end;
    if Row.Index > Index then Break;
    Row := Row.Next;
  end;
  Result := TMultiImageRowGI.Create;
  Result.Index := Index;
  if Row = nil then
  begin
    if LastRow <> nil then LastRow.Next := Result;
    Result.Prev := LastRow;
    Result.Next := nil;
    LastRow := Result;
    if FirstRow = nil then FirstRow := Result;
  end
  else
  begin
    Result.Prev := Row.Prev;
    Result.Next := Row;
    if Row.Prev <> nil then Row.Prev.Next := Result;
    Row.Prev := Result;
    if FirstRow = Row then FirstRow := Result;
  end;
end;
{ @end $49AE04 }

{ @routine $49AF1C TMultiImageGI_GetOrCreateColumn }
function TMultiImageGI.GetOrCreateColumn(Row: TMultiImageRowGI; Index: Integer): TMultiImageColGI;
var Column: TMultiImageColGI;
begin
  Column := Row.First;
  while Column <> nil do
  begin
    if Column.Index = Index then
    begin
      Result := Column;
      Exit;
    end;
    if Column.Index > Index then Break;
    Column := Column.Next;
  end;
  Result := TMultiImageColGI.Create;
  Result.Row := Row;
  Result.Index := Index;
  if Column = nil then
  begin
    if Row.Last <> nil then Row.Last.Next := Result;
    Result.Prev := Row.Last;
    Result.Next := nil;
    Row.Last := Result;
    if Row.First = nil then Row.First := Result;
  end
  else
  begin
    Result.Prev := Column.Prev;
    Result.Next := Column;
    if Column.Prev <> nil then Column.Prev.Next := Result;
    Column.Prev := Result;
    if Row.First = Column then Row.First := Result;
  end;
end;
{ @end $49AF1C }

{ @routine $49B028 TMultiImageGI_SetUnitPosition }
procedure TMultiImageGI.SetUnitPosition(Item: TMultiImageUnitGI; Position: TPoint);
var Column: TMultiImageColGI;
begin
  // Preserve the native comparison against the control's position.
  if (Item.Column <> nil) and (Self.LocalPosition.X = Position.X) and (Self.LocalPosition.Y = Position.Y) then Exit;
  Item.Position := Position;
  Column := GetOrCreateColumn(GetOrCreateRow(Position.Y div CellSize), Position.X div CellSize);
  if Item.Column = Column then Exit;
  UnlinkUnitFromColumn(Item);
  Item.Column := Column;
  if Column.Last <> nil then Column.Last.NextInColumn := Item;
  Item.PrevInColumn := Column.Last;
  Item.NextInColumn := nil;
  Column.Last := Item;
  if Column.First = nil then Column.First := Item;
end;
{ @end $49B028 }

{ @routine $49B118 TMultiImageGI_ClearImages }
procedure TMultiImageGI.ClearImages;
var Image: TMultiImageImageGI; I: Integer;
begin
  if Images <> nil then
  begin
    for I := 0 to Images.Count - 1 do
    begin
      Image := TMultiImageImageGI(Images[I]);
      Image.Free;
    end;
    Images.Clear;
  end;
end;
{ @end $49B118 }

{ @routine $49B180 TMultiImageGI_AddImage }
function TMultiImageGI.AddImage(Path: WideString): Integer;
var Image: TMultiImageImageGI;
begin
  Image := TMultiImageImageGI.Create;
  Image.SetImage(Path);
  Images.Add(Image);
  Result := Images.Count - 1;
end;
{ @end $49B180 }

{ @routine $49B204 TMultiImageGI_LoadFromConfigPath }
procedure TMultiImageGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadImageProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $49B204 }

{ @routine $49B238 TMultiImageGI_LoadFromBlock }
procedure TMultiImageGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadImageProperties(Block);
end;
{ @end $49B238 }

{ @routine $49B260 TMultiImageGI_LoadImageProperties }
procedure TMultiImageGI.LoadImageProperties(Block: TBlockParEC);
begin
end;
{ @end $49B260 }

{ @routine $49B270 TMultiImageGI_Invalidate }
procedure TMultiImageGI.Invalidate;
var
  MinColumn, MaxColumn, MinRow, MaxRow: Integer;
  Row: TMultiImageRowGI;
  Column: TMultiImageColGI;
  Item: TMultiImageUnitGI;
  Position: TPoint;
  Image: TMultiImageImageGI;
  Bounds: TRect;
begin
  if not MessageLoop.UpdateRectsEnabled then Exit;
  if not Active then Exit;
  if not IntersectRects(Bounds, HitTestBounds, GameScreenRect) then Exit;
  Dec(Bounds.Left, AbsolutePosition.X);
  Dec(Bounds.Top, AbsolutePosition.Y);
  Dec(Bounds.Right, AbsolutePosition.X);
  Dec(Bounds.Bottom, AbsolutePosition.Y);
  MinColumn := Bounds.Left div CellSize - 1;
  MaxColumn := (Bounds.Right - 1) div CellSize + 1;
  MinRow := Bounds.Top div CellSize - 1;
  MaxRow := (Bounds.Bottom - 1) div CellSize + 1;
  Row := FirstRow;
  while Row <> nil do
  begin
    if (Row.Index >= MinRow) and (Row.Index <= MaxRow) then
    begin
      Column := Row.First;
      while Column <> nil do
      begin
        if (Column.Index >= MinColumn) and (Column.Index <= MaxColumn) then
        begin
          Item := Column.First;
          while Item <> nil do
          begin
            Position.X := AbsolutePosition.X + Item.Position.X;
            Position.Y := AbsolutePosition.Y + Item.Position.Y;
            Image := TMultiImageImageGI(Images[Item.ImageIndex]);
            Bounds.Left := Position.X + Image.Bounds.Left;
            Bounds.Top := Position.Y + Image.Bounds.Top;
            Bounds.Right := Position.X + Image.Bounds.Right;
            Bounds.Bottom := Position.Y + Image.Bounds.Bottom;
            MessageLoop.QueueUpdateRect(Bounds);
            Item := Item.NextInColumn;
          end;
        end
        else if Column.Index > MaxColumn then Break;
        Column := Column.Next;
      end;
    end
    else if Row.Index > MaxRow then Break;
    Row := Row.Next;
  end;
end;
{ @end $49B270 }

{ @routine $49B46C TMultiImageGI_Draw }
procedure TMultiImageGI.Draw(ClipRect: TRect);
var
  Row: TMultiImageRowGI;
  Column: TMultiImageColGI;
  Item: TMultiImageUnitGI;
  MinColumn, MaxColumn, MinRow, MaxRow: Integer;
  Position: TPoint;
  Image: TMultiImageImageGI;
  Data: TCGiEC;
  Bounds, Intersection: TRect;
begin
  Bounds.Left := ClipRect.Left - AbsolutePosition.X;
  Bounds.Top := ClipRect.Top - AbsolutePosition.Y;
  Bounds.Right := ClipRect.Right - AbsolutePosition.X;
  Bounds.Bottom := ClipRect.Bottom - AbsolutePosition.Y;
  MinColumn := Bounds.Left div CellSize - 1;
  MaxColumn := (Bounds.Right - 1) div CellSize + 1;
  MinRow := Bounds.Top div CellSize - 1;
  MaxRow := (Bounds.Bottom - 1) div CellSize + 1;
  Row := FirstRow;
  while Row <> nil do
  begin
    if (Row.Index >= MinRow) and (Row.Index <= MaxRow) then
    begin
      Column := Row.First;
      while Column <> nil do
      begin
        if (Column.Index >= MinColumn) and (Column.Index <= MaxColumn) then
        begin
          Item := Column.First;
          while Item <> nil do
          begin
            Position.X := AbsolutePosition.X + Item.Position.X;
            Position.Y := AbsolutePosition.Y + Item.Position.Y;
            Image := TMultiImageImageGI(Images[Item.ImageIndex]);
            Bounds.Left := Image.Bounds.Left + Position.X;
            Bounds.Top := Image.Bounds.Top + Position.Y;
            Bounds.Right := Image.Bounds.Right + Position.X;
            Bounds.Bottom := Image.Bounds.Bottom + Position.Y;
            if IntersectRects(Intersection, Bounds, ClipRect) then
            begin
              Data := AcquireCachedGi(Image.ImageCache);
              try
                if HardwareRenderingEnabled then
                  DrawTexture(Data.GetOrCreateSurface(0), Bounds.Left, Bounds.Top, 255, RgbWhite, @ClipRect, False, False)
                else
                  Data.Image.DrawToGraphBuf(ScreenRenderBuffer, Bounds.Left, Bounds.Top, ClipRect, 0, 255);
              finally
                Image.ImageCache.Release;
              end;
            end;
            Item := Item.NextInColumn;
          end;
        end
        else if Column.Index > MaxColumn then Break;
        Column := Column.Next;
      end;
    end
    else if Row.Index > MaxRow then Break;
    Row := Row.Next;
  end;
end;
{ @end $49B46C }

{ @routine $49B71C TMultiImageGI_QueueImageLoad }
procedure TMultiImageGI.QueueImageLoad(PendingLoads: TList);
var Image: TMultiImageImageGI; I: Integer;
begin
  for I := 0 to Images.Count - 1 do
  begin
    Image := TMultiImageImageGI(Images[I]);
    Image.ImageCache.QueueLoadIfMissing(PendingLoads);
  end;
end;
{ @end $49B71C }

end.
