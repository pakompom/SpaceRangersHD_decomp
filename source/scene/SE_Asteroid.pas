unit SE_Asteroid;
// Unit bracket (inferred): .text 0x00797CE8..0x00798330; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr 0x797DB8
    procedure DetachFromSpace; override; // @addr 0x797FD8
    procedure SetPosition(APosition: TPointF); override; // @addr 0x798040
    function GetSequenceFrameIndex: Integer; // @addr 0x7980D0
    procedure SetSequenceFrameIndex(FrameIndex: Integer); // @addr 0x798104
    function HitTestCursor: Boolean; override; // @addr 0x7981B4
    procedure DrawMap; override; // @addr 0x798134 @note "Requires an attached space."
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr 0x7981E4
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr 0x79829C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr 0x7982B8
  end;

implementation

uses Globals, GR_Main, GI_Main, SE_Process;
{ @routine $797DB8 TAsteroidSE_AttachToSpace }
procedure TAsteroidSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Comet');
  ConfigureRandomSound('Comet');
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  Animation.SetImagePath(ImagePath);
  Animation.SetSize(Animation.GetContentSize);
  Animation.SetOrigin(HalfPoint(Animation.ClientSize));
  Animation.SetDepthByName(DepthExpression);
  Animation.SetPosition(TruncatePointF(Position));
  Animation.SetPositionModeW(True);
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  Animation.SetSequenceFrame(SavedSequenceFrameIndex);
  Animation.RestartPlayback;
  Size := Animation.ClientSize;
  MapImage := TImageGI.Create(SpaceObjectUiLoop.ContentPanel);
  MapImage.SetPositionModeW(True);
  MapImage.SetDepthByName(DepthExpression);
  MapImage.SetPosition(TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale)));
  MapImage.SetImagePath(MapImagePath);
  MapImage.SetSize(MapImage.GetContentSize);
  MapImage.SetOrigin(HalfPoint(MapImage.GetContentSize));
end;
{ @end $797DB8 }

{ @routine $797FD8 TAsteroidSE_DetachFromSpace }
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
{ @end $797FD8 }

{ @routine $798040 TAsteroidSE_SetPosition }
procedure TAsteroidSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Animation.SetPosition(TruncatePointF(APosition));
    MapImage.SetPosition(TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale)));
  end;
end;
{ @end $798040 }

{ @routine $7980D0 TAsteroidSE_GetSequenceFrameIndex }
function TAsteroidSE.GetSequenceFrameIndex: Integer;
begin
  if Animation = nil then Result := SavedSequenceFrameIndex
  else Result := Animation.SequenceFrame;
end;
{ @end $7980D0 }

{ @routine $798104 TAsteroidSE_SetSequenceFrameIndex }
procedure TAsteroidSE.SetSequenceFrameIndex(FrameIndex: Integer);
begin
  SavedSequenceFrameIndex := FrameIndex;
  if Animation <> nil then Animation.SetSequenceFrame(FrameIndex);
end;
{ @end $798104 }

{ @routine $798134 TAsteroidSE_DrawMap }
procedure TAsteroidSE.DrawMap;
begin
  with Space.Process as TProcessSE do
    if PointDistanceSquared(Self.Position, RadarCenter) < Sqr(RadarRange) then
      MapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $798134 }

{ @routine $7981B4 TAsteroidSE_HitTestCursor }
function TAsteroidSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $7981B4 }

{ @routine $7981E4 TAsteroidSE_LoadTemplate }
procedure TAsteroidSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  MapImagePath := Block.GetParam('ImageMap');
end;
{ @end $7981E4 }

{ @routine $79829C TAsteroidSE_ApplyConfig }
procedure TAsteroidSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $79829C }

{ @routine $7982B8 TAsteroidSE_QueueImageLoad }
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
{ @end $7982B8 }

end.
