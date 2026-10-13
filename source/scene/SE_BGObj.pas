unit SE_BGObj;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_MessageLoop, GI_Image, SE_Space, Types;

type
  TBGObjSE = class(TObjectSE) // @size $58

  public
    ImagePath: WideString; // @offset $4C
    Radius: Single; // @offset $50 Loaded but not used by this scene unit.
    Image: TImageGI; // @offset $54
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $780E38
    procedure DetachFromSpace; override; // @addr $780EBC
    procedure SetPosition(APosition: TPointF); override; // @addr $780EE8
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $780F2C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $780FDC
  end;

implementation

uses EC_Str, GI_Main;
{ @routine $780E38 TBGObjSE_AttachToSpace }
procedure TBGObjSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  Image := TImageGI.Create(Space.MapPanel);
  Image.World := True;
  Image.SetDepthByName(DepthExpression);
  Image.Pos := TruncatePointF(Position);
  Image.ImageSourcePath := ImagePath;
  Image.ObjectSize := Image.GetContentSize;
end;
{ @end $780E38 }

{ @routine $780EBC TBGObjSE_DetachFromSpace }
procedure TBGObjSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  Space.MapPanel.FreeOwnedChild(Image);
  Image := nil;
  inherited DetachFromSpace;
end;
{ @end $780EBC }

{ @routine $780EE8 TBGObjSE_SetPosition }
procedure TBGObjSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Image.Pos := TruncatePointF(APosition);
end;
{ @end $780EE8 }

{ @routine $780F2C TBGObjSE_LoadTemplate }
procedure TBGObjSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  Radius := ExtractDigitsToIntW(Block.GetParam('Radius'));
end;
{ @end $780F2C }

{ @routine $780FDC TBGObjSE_QueueImageLoad }
procedure TBGObjSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
  with TImageGI.Create(Owner) do
  begin
    SetImagePath(Self.ImagePath);
    QueueImageLoad(PendingLoads);
    Free;
  end;
end;
{ @end $780FDC }

end.
