unit SE_BGObj;
// Unit bracket (inferred): .text 0x007CC330..0x007CC629; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_MessageLoop, GI_Image, SE_Space, Types;

type
  TBGObjSE = class(TObjectSE) // @size $58

  public
    ImagePath: WideString; // @offset $4C
    Radius: Single; // @offset $50 Loaded but not used by this scene unit.
    Image: TImageGI; // @offset $54
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7CC3F4
    procedure DetachFromSpace; override; // @addr $7CC4A4
    procedure SetPosition(APosition: TPointF); override; // @addr $7CC4E0 @ida "void __usercall $name(TBGObjSE *Self@<eax>, TPointF *APosition@<edx>);"
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7CC528
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $7CC5E4
  end;

implementation

uses EC_Str, GI_Main;
{ @routine $7CC3F4 TBGObjSE_AttachToSpace }
procedure TBGObjSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  Image := TImageGI.Create(Space.MapPanel);
  Image.SetPositionModeW(True);
  Image.SetDepthByName(DepthExpression);
  Image.SetPosition(TruncatePointF(Position));
  Image.SetImagePath(ImagePath);
  Image.SetSize(Image.GetContentSize);
end;
{ @end $7CC3F4 }

{ @routine $7CC4A4 TBGObjSE_DetachFromSpace }
procedure TBGObjSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  Space.MapPanel.FreeOwnedChild(Image);
  Image := nil;
  inherited DetachFromSpace;
end;
{ @end $7CC4A4 }

{ @routine $7CC4E0 TBGObjSE_SetPosition }
procedure TBGObjSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Image.SetPosition(TruncatePointF(APosition));
end;
{ @end $7CC4E0 }

{ @routine $7CC528 TBGObjSE_LoadTemplate }
procedure TBGObjSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  Radius := ExtractDigitsToIntW(Block.GetParam('Radius'));
end;
{ @end $7CC528 }

{ @routine $7CC5E4 TBGObjSE_QueueImageLoad }
procedure TBGObjSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
  with TImageGI.Create(Owner) do
  begin
    SetImagePath(Self.ImagePath);
    QueueImageLoad(PendingLoads);
    Free;
  end;
end;
{ @end $7CC5E4 }

end.
