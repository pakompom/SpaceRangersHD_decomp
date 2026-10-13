unit SE_StarsField;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_MessageLoop, GI_SimpleImage, GI_InfiniteImage, SE_Space, Types;

type
  TStarsFieldSE = class(TObjectSE) // @size $58

  public
    ImagePath: WideString; // @offset $4C
    InfiniteImage: TInfiniteImageGI; // @offset $50
    StaticImage: TSimpleImageGI; // @offset $54
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $781914
    procedure DetachFromSpace; override; // @addr $781A08
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $781A50
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $781AC0
  end;

implementation

uses GlobalsV, GI_Image;
{ @routine $781914 TStarsFieldSE_AttachToSpace }
procedure TStarsFieldSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  if StaticBackground then
  begin
    StaticImage := TSimpleImageGI.Create(Space.MapPanel);
    StaticImage.SetDepthByName(DepthExpression);
    StaticImage.World := False;
    StaticImage.KindX := ikxLeftFill;
    StaticImage.KindY := ikyTopFill;
    StaticImage.Pos := Classes.Point(-Space.MapPanel.OriginPoint.X, -Space.MapPanel.OriginPoint.Y);
    StaticImage.ObjectSize := Classes.Point(Space.MapPanel.ClientSize.X, Space.MapPanel.ClientSize.Y);
    StaticImage.SetImagePath(ImagePath);
  end
  else
  begin
    InfiniteImage := TInfiniteImageGI.Create(Space.MapPanel);
    InfiniteImage.SetDepthByName(DepthExpression);
    InfiniteImage.World := True;
    InfiniteImage.SetImagePath(ImagePath);
  end;
end;
{ @end $781914 }

{ @routine $781A08 TStarsFieldSE_DetachFromSpace }
procedure TStarsFieldSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if InfiniteImage <> nil then
  begin
    Space.MapPanel.FreeOwnedChild(InfiniteImage);
    InfiniteImage := nil;
  end;
  if StaticImage <> nil then
  begin
    Space.MapPanel.FreeOwnedChild(StaticImage);
    StaticImage := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $781A08 }

{ @routine $781A50 TStarsFieldSE_LoadTemplate }
procedure TStarsFieldSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
end;
{ @end $781A50 }

{ @routine $781AC0 TStarsFieldSE_QueueImageLoad }
procedure TStarsFieldSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
  if StaticBackground then
    with TSimpleImageGI.Create(Owner) do
    begin
      SetImagePath(Self.ImagePath);
      QueueImageLoad(PendingLoads);
      Free;
    end
  else
    with TInfiniteImageGI.Create(Owner) do
    begin
      SetImagePath(Self.ImagePath);
      QueueImageLoad(PendingLoads);
      Free;
    end;
end;
{ @end $781AC0 }

end.
