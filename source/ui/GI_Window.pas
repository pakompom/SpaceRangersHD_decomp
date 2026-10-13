unit GI_Window;

interface

uses EC_BlockPar, GI_Image, GI_MessageLoop, GI_Panel, Types;

type
  TWindowGI = class(TPanelGI) // @size 0x17C
  public
    LeftImage: TImageGI; // @offset 0x140
    RightImage: TImageGI; // @offset 0x144
    TopImage: TImageGI; // @offset 0x148
    BottomImage: TImageGI; // @offset 0x14C
    TopLeftImage: TImageGI; // @offset 0x150
    TopRightImage: TImageGI; // @offset 0x154
    BottomLeftImage: TImageGI; // @offset 0x158
    BottomRightImage: TImageGI; // @offset 0x15C
    TextureImage: TImageGI; // @offset 0x160
    WorkSubRect: TRect; // @offset 0x164
    MinimumSize: TPoint; // @offset 0x174

    constructor Create(Owner: TObjectGI); // @addr 0x004BBFD4
    destructor Destroy; override; // @addr 0x004BC158
    function AlignSizeToBorderTiles(Size: TPoint): TPoint; // @addr 0x004BC24C
    procedure UpdateBorderLayout; // @addr 0x004BC34C
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x004BC71C
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x004BC748
    procedure LoadWindowProperties(Block: TBlockParEC); // @addr 0x004BC764
    procedure UpdateAutoGeometry; override; // @addr 0x004BCB10
  end;

implementation

uses Classes, GI_Main, GR_Main, Math;


{ @routine $4BBFD4 TWindowGI_Create }
constructor TWindowGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  LeftImage := TImageGI.Create(Self);
  LeftImage.SetDepth(1000000);
  RightImage := TImageGI.Create(Self);
  RightImage.SetDepth(1000000);
  TopImage := TImageGI.Create(Self);
  TopImage.SetDepth(1000000);
  BottomImage := TImageGI.Create(Self);
  BottomImage.SetDepth(1000000);
  TopLeftImage := TImageGI.Create(Self);
  TopLeftImage.SetDepth(1000000);
  TopRightImage := TImageGI.Create(Self);
  TopRightImage.SetDepth(1000000);
  BottomLeftImage := TImageGI.Create(Self);
  BottomLeftImage.SetDepth(1000000);
  BottomRightImage := TImageGI.Create(Self);
  BottomRightImage.SetDepth(1000000);
  TextureImage := TImageGI.Create(Self);
  TextureImage.SetDepth(1000000);
end;
{ @end $4BBFD4 }

{ @routine $4BC158 TWindowGI_Destroy }
destructor TWindowGI.Destroy;
begin
  if LeftImage <> nil then
  begin
    LeftImage.Free;
    LeftImage := nil;
  end;
  if RightImage <> nil then
  begin
    RightImage.Free;
    RightImage := nil;
  end;
  if TopImage <> nil then
  begin
    TopImage.Free;
    TopImage := nil;
  end;
  if BottomImage <> nil then
  begin
    BottomImage.Free;
    BottomImage := nil;
  end;
  if TopLeftImage <> nil then
  begin
    TopLeftImage.Free;
    TopLeftImage := nil;
  end;
  if TopRightImage <> nil then
  begin
    TopRightImage.Free;
    TopRightImage := nil;
  end;
  if BottomLeftImage <> nil then
  begin
    BottomLeftImage.Free;
    BottomLeftImage := nil;
  end;
  if BottomRightImage <> nil then
  begin
    BottomRightImage.Free;
    BottomRightImage := nil;
  end;
  if TextureImage <> nil then
  begin
    TextureImage.Free;
    TextureImage := nil;
  end;
  inherited Destroy;
end;
{ @end $4BC158 }

{ @routine $4BC24C TWindowGI_AlignSizeToBorderTiles }
function TWindowGI.AlignSizeToBorderTiles(Size: TPoint): TPoint;
var BorderSize: Integer; CornerSize, TileSize: TPoint;
begin
  Size.X := Max(Size.X, MinimumSize.X);
  Size.Y := Max(Size.Y, MinimumSize.Y);
  CornerSize := TopLeftImage.GetContentSize;
  TileSize := TopRightImage.GetContentSize;
  BorderSize := CornerSize.X + TileSize.X;
  if Size.X <= BorderSize then Result.X := BorderSize
  else
  begin
    TileSize := TopImage.GetContentSize;
    Result.X := Ceil((Size.X - BorderSize) / TileSize.X) * TileSize.X + BorderSize;
  end;
  TileSize := BottomLeftImage.GetContentSize;
  BorderSize := CornerSize.Y + TileSize.Y;
  if Size.Y <= BorderSize then Result.Y := BorderSize
  else
  begin
    TileSize := LeftImage.GetContentSize;
    Result.Y := Ceil((Size.Y - BorderSize) / TileSize.Y) * TileSize.Y + BorderSize;
  end;
end;
{ @end $4BC24C }

{ @routine $4BC34C TWindowGI_UpdateBorderLayout }
procedure TWindowGI.UpdateBorderLayout;
var First, Last, Width, Height: Integer;
begin
  TopLeftImage.ObjectSize := TopLeftImage.GetContentSize;
  TopLeftImage.Pos := Classes.Point(0, 0);
  TopRightImage.ObjectSize := TopRightImage.GetContentSize;
  TopRightImage.Pos := Classes.Point(ClientSize.X - TopRightImage.ClientSize.X, 0);
  BottomLeftImage.ObjectSize := BottomLeftImage.GetContentSize;
  BottomLeftImage.Pos := Classes.Point(0, ClientSize.Y - BottomLeftImage.ClientSize.Y);
  BottomRightImage.ObjectSize := BottomRightImage.GetContentSize;
  BottomRightImage.Pos := Classes.Point(ClientSize.X - BottomRightImage.ClientSize.X,
    ClientSize.Y - BottomRightImage.ClientSize.Y);
  First := TopLeftImage.ClientSize.X;
  Last := ClientSize.X - TopRightImage.ClientSize.X;
  if Last - First <= 0 then TopImage.IsActive := False
  else
  begin
    TopImage.IsActive := True;
    TopImage.ObjectSize := Classes.Point(Last - First, TopImage.GetContentSize.Y);
    TopImage.Pos := Classes.Point(First, 0);
    TopImage.KindX := ikxLeftFill;
  end;
  First := BottomLeftImage.ClientSize.X;
  Last := ClientSize.X - BottomRightImage.ClientSize.X;
  if Last - First <= 0 then BottomImage.IsActive := False
  else
  begin
    BottomImage.IsActive := True;
    BottomImage.ObjectSize := Classes.Point(Last - First, BottomImage.GetContentSize.Y);
    BottomImage.Pos := Classes.Point(First, ClientSize.Y - BottomImage.ClientSize.Y);
    BottomImage.KindX := ikxLeftFill;
  end;
  First := TopLeftImage.ClientSize.Y;
  Last := ClientSize.Y - BottomLeftImage.ClientSize.Y;
  if Last - First <= 0 then LeftImage.IsActive := False
  else
  begin
    LeftImage.IsActive := True;
    LeftImage.ObjectSize := Classes.Point(LeftImage.GetContentSize.X, Last - First);
    LeftImage.Pos := Classes.Point(0, First);
    LeftImage.KindY := ikyTopFill;
  end;
  First := TopRightImage.ClientSize.Y;
  Last := ClientSize.Y - BottomRightImage.ClientSize.Y;
  if Last - First <= 0 then RightImage.IsActive := False
  else
  begin
    RightImage.IsActive := True;
    RightImage.ObjectSize := Classes.Point(RightImage.GetContentSize.X, Last - First);
    RightImage.Pos := Classes.Point(ClientSize.X - RightImage.ClientSize.X, First);
    RightImage.KindY := ikyTopFill;
  end;
  Width := ClientSize.X - LeftImage.ClientSize.X - RightImage.ClientSize.X;
  Height := ClientSize.Y - TopImage.ClientSize.Y - BottomImage.ClientSize.Y;
  if (Width <= 0) or (Height <= 0) or
    ((LeftImage.ClientSize.Y <= 0) and (TopImage.ClientSize.X <= 0)) then TextureImage.IsActive := False
  else
  begin
    TextureImage.IsActive := True;
    TextureImage.Pos := Classes.Point(LeftImage.ClientSize.X, TopImage.ClientSize.Y);
    TextureImage.ObjectSize := Classes.Point(Width, Height);
    TextureImage.KindX := ikxLeftFill;
    TextureImage.KindY := ikyTopFill;
  end;
end;
{ @end $4BC34C }

{ @routine $4BC71C TWindowGI_LoadFromConfigPath }
procedure TWindowGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadWindowProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4BC71C }

{ @routine $4BC748 TWindowGI_LoadFromBlock }
procedure TWindowGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadWindowProperties(Block);
end;
{ @end $4BC748 }

{ @routine $4BC764 TWindowGI_LoadWindowProperties }
procedure TWindowGI.LoadWindowProperties(Block: TBlockParEC);
begin
  if Block.CountParams('ImageTopLeft') > 0 then
    TopLeftImage.ImageSourcePath := Block.GetParam('ImageTopLeft');
  if Block.CountParams('ImageTopRight') > 0 then
    TopRightImage.ImageSourcePath := Block.GetParam('ImageTopRight');
  if Block.CountParams('ImageBottomLeft') > 0 then
    BottomLeftImage.ImageSourcePath := Block.GetParam('ImageBottomLeft');
  if Block.CountParams('ImageBottomRight') > 0 then
    BottomRightImage.ImageSourcePath := Block.GetParam('ImageBottomRight');
  if Block.CountParams('ImageLeft') > 0 then
    LeftImage.ImageSourcePath := Block.GetParam('ImageLeft');
  if Block.CountParams('ImageRight') > 0 then
    RightImage.ImageSourcePath := Block.GetParam('ImageRight');
  if Block.CountParams('ImageTop') > 0 then
    TopImage.ImageSourcePath := Block.GetParam('ImageTop');
  if Block.CountParams('ImageBottom') > 0 then
    BottomImage.ImageSourcePath := Block.GetParam('ImageBottom');
  if Block.CountParams('ImageTexture') > 0 then
    TextureImage.ImageSourcePath := Block.GetParam('ImageTexture');
  if Block.CountParams('WorkSubRect') > 0 then WorkSubRect := GetRectGI(Block.GetParam('WorkSubRect'));
  if Block.CountParams('MinSize') > 0 then MinimumSize := GetPointGI(Block.GetParam('MinSize'));
end;
{ @end $4BC764 }

{ @routine $4BCB10 TWindowGI_UpdateAutoGeometry }
procedure TWindowGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
  ObjectSize := AlignSizeToBorderTiles(ClientSize);
  UpdateBorderLayout;
end;
{ @end $4BCB10 }

end.
