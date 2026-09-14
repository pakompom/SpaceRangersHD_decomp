unit GI_Window;
// Unit bracket (inferred): .text 0x004B2F9C..0x004B3F1C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(Owner: TObjectGI); // @addr 0x4B30C0 @ida "TWindowGI *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, TObjectGI *Owner@<ecx>);"
    destructor Destroy; override; // @addr 0x4B329C @ida "void __usercall $name(TWindowGI *Self@<eax>, __int8 DestroyFlags@<dl>);"
    function AlignSizeToBorderTiles(Size: TPoint): TPoint; // @addr 0x4B341C @ida "void __usercall $name(TWindowGI *Self@<eax>, TPoint *Size@<edx>, TPoint *Result@<ecx>);"
    procedure UpdateBorderLayout; // @addr 0x4B3564
    procedure LoadFromConfigPath(const Path: WideString); override; // @addr 0x4B3AA4
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x4B3AD8
    procedure LoadWindowProperties(Block: TBlockParEC); // @addr 0x4B3B00
    procedure UpdateAutoGeometry; override; // @addr 0x4B3EE4
  end;

implementation

uses Classes, GI_Main, GR_Main, Math;


{ @routine $4B30C0 TWindowGI_Create }
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
{ @end $4B30C0 }

{ @routine $4B329C TWindowGI_Destroy }
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
{ @end $4B329C }

{ @routine $4B341C TWindowGI_AlignSizeToBorderTiles }
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
{ @end $4B341C }

{ @routine $4B3564 TWindowGI_UpdateBorderLayout }
procedure TWindowGI.UpdateBorderLayout;
var First, Last, Width, Height: Integer;
begin
  TopLeftImage.SetSize(TopLeftImage.GetContentSize);
  TopLeftImage.SetPosition(Classes.Point(0, 0));
  TopRightImage.SetSize(TopRightImage.GetContentSize);
  TopRightImage.SetPosition(Classes.Point(ClientSize.X - TopRightImage.ClientSize.X, 0));
  BottomLeftImage.SetSize(BottomLeftImage.GetContentSize);
  BottomLeftImage.SetPosition(Classes.Point(0, ClientSize.Y - BottomLeftImage.ClientSize.Y));
  BottomRightImage.SetSize(BottomRightImage.GetContentSize);
  BottomRightImage.SetPosition(Classes.Point(ClientSize.X - BottomRightImage.ClientSize.X,
    ClientSize.Y - BottomRightImage.ClientSize.Y));
  First := TopLeftImage.ClientSize.X;
  Last := ClientSize.X - TopRightImage.ClientSize.X;
  if Last - First <= 0 then TopImage.SetActive(False)
  else
  begin
    TopImage.SetActive(True);
    TopImage.SetSize(Classes.Point(Last - First, TopImage.GetContentSize.Y));
    TopImage.SetPosition(Classes.Point(First, 0));
    TopImage.SetImageKindX(ikxLeftFill);
  end;
  First := BottomLeftImage.ClientSize.X;
  Last := ClientSize.X - BottomRightImage.ClientSize.X;
  if Last - First <= 0 then BottomImage.SetActive(False)
  else
  begin
    BottomImage.SetActive(True);
    BottomImage.SetSize(Classes.Point(Last - First, BottomImage.GetContentSize.Y));
    BottomImage.SetPosition(Classes.Point(First, ClientSize.Y - BottomImage.ClientSize.Y));
    BottomImage.SetImageKindX(ikxLeftFill);
  end;
  First := TopLeftImage.ClientSize.Y;
  Last := ClientSize.Y - BottomLeftImage.ClientSize.Y;
  if Last - First <= 0 then LeftImage.SetActive(False)
  else
  begin
    LeftImage.SetActive(True);
    LeftImage.SetSize(Classes.Point(LeftImage.GetContentSize.X, Last - First));
    LeftImage.SetPosition(Classes.Point(0, First));
    LeftImage.SetImageKindY(ikyTopFill);
  end;
  First := TopRightImage.ClientSize.Y;
  Last := ClientSize.Y - BottomRightImage.ClientSize.Y;
  if Last - First <= 0 then RightImage.SetActive(False)
  else
  begin
    RightImage.SetActive(True);
    RightImage.SetSize(Classes.Point(RightImage.GetContentSize.X, Last - First));
    RightImage.SetPosition(Classes.Point(ClientSize.X - RightImage.ClientSize.X, First));
    RightImage.SetImageKindY(ikyTopFill);
  end;
  Width := ClientSize.X - LeftImage.ClientSize.X - RightImage.ClientSize.X;
  Height := ClientSize.Y - TopImage.ClientSize.Y - BottomImage.ClientSize.Y;
  if (Width <= 0) or (Height <= 0) or
    ((LeftImage.ClientSize.Y <= 0) and (TopImage.ClientSize.X <= 0)) then TextureImage.SetActive(False)
  else
  begin
    TextureImage.SetActive(True);
    TextureImage.SetPosition(Classes.Point(LeftImage.ClientSize.X, TopImage.ClientSize.Y));
    TextureImage.SetSize(Classes.Point(Width, Height));
    TextureImage.SetImageKindX(ikxLeftFill);
    TextureImage.SetImageKindY(ikyTopFill);
  end;
end;
{ @end $4B3564 }

{ @routine $4B3AA4 TWindowGI_LoadFromConfigPath }
procedure TWindowGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadWindowProperties(UiStyleConfig.GetBlockByPath(Path));
end;
{ @end $4B3AA4 }

{ @routine $4B3AD8 TWindowGI_LoadFromBlock }
procedure TWindowGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadWindowProperties(Block);
end;
{ @end $4B3AD8 }

{ @routine $4B3B00 TWindowGI_LoadWindowProperties }
procedure TWindowGI.LoadWindowProperties(Block: TBlockParEC);
begin
  if Block.CountParams('ImageTopLeft') > 0 then
    TopLeftImage.SetImagePath(Block.GetParam('ImageTopLeft'));
  if Block.CountParams('ImageTopRight') > 0 then
    TopRightImage.SetImagePath(Block.GetParam('ImageTopRight'));
  if Block.CountParams('ImageBottomLeft') > 0 then
    BottomLeftImage.SetImagePath(Block.GetParam('ImageBottomLeft'));
  if Block.CountParams('ImageBottomRight') > 0 then
    BottomRightImage.SetImagePath(Block.GetParam('ImageBottomRight'));
  if Block.CountParams('ImageLeft') > 0 then
    LeftImage.SetImagePath(Block.GetParam('ImageLeft'));
  if Block.CountParams('ImageRight') > 0 then
    RightImage.SetImagePath(Block.GetParam('ImageRight'));
  if Block.CountParams('ImageTop') > 0 then
    TopImage.SetImagePath(Block.GetParam('ImageTop'));
  if Block.CountParams('ImageBottom') > 0 then
    BottomImage.SetImagePath(Block.GetParam('ImageBottom'));
  if Block.CountParams('ImageTexture') > 0 then
    TextureImage.SetImagePath(Block.GetParam('ImageTexture'));
  if Block.CountParams('WorkSubRect') > 0 then WorkSubRect := GetRectGI(Block.GetParam('WorkSubRect'));
  if Block.CountParams('MinSize') > 0 then MinimumSize := GetPointGI(Block.GetParam('MinSize'));
end;
{ @end $4B3B00 }

{ @routine $4B3EE4 TWindowGI_UpdateAutoGeometry }
procedure TWindowGI.UpdateAutoGeometry;
begin
  inherited UpdateAutoGeometry;
  SetSize(AlignSizeToBorderTiles(ClientSize));
  UpdateBorderLayout;
end;
{ @end $4B3EE4 }

end.
