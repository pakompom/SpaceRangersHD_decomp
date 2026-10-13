unit SE_Asteroid;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_MessageLoop, SE_Space;

type
  TAsteroidSE = class(TObjectSE) // @size 0x60
  public
    ImagePath: WideString; // @offset 0x4C
    MapImagePath: WideString; // @offset 0x50
    Animation: TgaiGI; // @offset 0x54
    MapImage: TImageGI; // @offset 0x58
    SavedSequenceFrameIndex: Integer; // @offset 0x5C

    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr 0x00695DC4
    procedure DetachFromSpace; override; // @addr 0x00695F6C
    procedure SetPosition(APosition: TPointF); override; // @addr 0x00695FB4
    function GetSequenceFrameIndex: Integer; // @addr 0x00696038
    procedure SetSequenceFrameIndex(FrameIndex: Integer); // @addr 0x0069604C
    function HitTestCursor: Boolean; override; // @addr 0x006960D0
    procedure DrawMap; override; // @addr 0x00696060 @note "Requires an attached space."
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr 0x006960EC
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr 0x00696194
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr 0x0069619C
  end;

implementation

uses Globals, GR_Main, GI_Main, SE_Process;
{ @routine $695DC4 TAsteroidSE_AttachToSpace }
procedure TAsteroidSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Comet');
  ConfigureRandomSound('Comet');
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  Animation.SetImagePath(ImagePath);
  Animation.ObjectSize := Animation.GetContentSize;
  Animation.Sme := HalfPoint(Animation.ClientSize);
  Animation.SetDepthByName(DepthExpression);
  Animation.Pos := TruncatePointF(Position);
  Animation.World := True;
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  Animation.SetSequenceFrame(SavedSequenceFrameIndex);
  Animation.RestartPlayback;
  Size := Animation.ClientSize;
  MapImage := TImageGI.Create(SpaceObjectUiLoop.ContentPanel);
  MapImage.World := True;
  MapImage.SetDepthByName(DepthExpression);
  MapImage.Pos := TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale));
  MapImage.ImageSourcePath := MapImagePath;
  MapImage.ObjectSize := MapImage.GetContentSize;
  MapImage.Sme := HalfPoint(MapImage.GetContentSize);
end;
{ @end $695DC4 }

{ @routine $695F6C TAsteroidSE_DetachFromSpace }
procedure TAsteroidSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if Animation <> nil then
  begin
    SavedSequenceFrameIndex := Animation.SequenceFrame;
    Animation.Free;
    Animation := nil;
  end;
  if MapImage <> nil then
  begin
    MapImage.Free;
    MapImage := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $695F6C }

{ @routine $695FB4 TAsteroidSE_SetPosition }
procedure TAsteroidSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Animation.Pos := TruncatePointF(APosition);
    MapImage.Pos := TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale));
  end;
end;
{ @end $695FB4 }

{ @routine $696038 TAsteroidSE_GetSequenceFrameIndex }
function TAsteroidSE.GetSequenceFrameIndex: Integer;
begin
  if Animation = nil then Result := SavedSequenceFrameIndex
  else Result := Animation.SequenceFrame;
end;
{ @end $696038 }

{ @routine $69604C TAsteroidSE_SetSequenceFrameIndex }
procedure TAsteroidSE.SetSequenceFrameIndex(FrameIndex: Integer);
begin
  SavedSequenceFrameIndex := FrameIndex;
  if Animation <> nil then Animation.SetSequenceFrame(FrameIndex);
end;
{ @end $69604C }

{ @routine $696060 TAsteroidSE_DrawMap }
procedure TAsteroidSE.DrawMap;
begin
  with Space.Process as TProcessSE do
    if PointDistanceSquared(Self.Position, RadarCenter) < Sqr(RadarRange) then
      MapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $696060 }

{ @routine $6960D0 TAsteroidSE_HitTestCursor }
function TAsteroidSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $6960D0 }

{ @routine $6960EC TAsteroidSE_LoadTemplate }
procedure TAsteroidSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  MapImagePath := Block.GetParam('ImageMap');
end;
{ @end $6960EC }

{ @routine $696194 TAsteroidSE_ApplyConfig }
procedure TAsteroidSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $696194 }

{ @routine $69619C TAsteroidSE_QueueImageLoad }
procedure TAsteroidSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
  with TgaiGI.Create(Owner) do
  begin
    SetImagePath(Self.ImagePath);
    QueueImageLoad(PendingLoads);
    Free;
  end;
  with TImageGI.Create(Owner) do
  begin
    SetImagePath(MapImagePath);
    QueueImageLoad(PendingLoads);
    Free;
  end;
end;
{ @end $69619C }

end.
