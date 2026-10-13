unit SE_Container;

interface

uses Classes, EC_BlockPar, EC_Struct, GI_AlphaImage, GI_GAI, GI_MessageLoop, SE_Space, Types;

type
  TContainerSE = class(TObjectSE) // @size $5C
  public
    ImagePath: WideString; // @offset $4C
    MinimapImagePath: WideString; // @offset $50
    Animation: TgaiGI; // @offset $54
    MinimapImage: TAlphaImageGI; // @offset $58
    procedure CopyTo(Destination: TObjectSE); override; // @addr $6F41DC
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $6F4224
    procedure DetachFromSpace; override; // @addr $6F43C8
    procedure SetPosition(APosition: TPointF); override; // @addr $6F4404
    procedure SetDepth(Value: Single); override; // @addr $6F4488
    function GetDepth: Single; override; // @addr $6F44A4
    function HitTestCursor: Boolean; override; // @addr $6F44B4
    procedure DrawMap; override; // @addr $6F44D0
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $6F4540
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $6F4600
  end;

implementation

uses aMyFunction, Globals, GR_Main, SE_Process;

{ @routine $6F41DC TContainerSE_CopyTo }
procedure TContainerSE.CopyTo(Destination: TObjectSE);
begin
  inherited CopyTo(Destination);
  (Destination as TContainerSE).ImagePath := ImagePath;
  (Destination as TContainerSE).MinimapImagePath := MinimapImagePath;
end;
{ @end $6F41DC }

{ @routine $6F4224 TContainerSE_AttachToSpace }
procedure TContainerSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not IsAttachedToSpace then
  begin
    ConfigureLoopSound('Container');
    ConfigureRandomSound('Container');
    inherited AttachToSpace(ASpace);
    Animation := TgaiGI.Create(Space.MapPanel);
    Animation.SetImagePath(ImagePath);
    Animation.SequenceIndex := 0;
    Animation.UpdateAutoGeometry;
    Animation.World := True;
    Animation.SetDepthByName(DepthExpression);
    Animation.Pos := TruncatePointF(Position);
    Animation.ObjectSize := Animation.GetContentSize;
    Animation.Sme := HalfPoint(Animation.ClientSize);
    Animation.SetSequenceFrame(RandomIntRange(0, Animation.SequenceFrameCount - 1));
    Animation.RestartPlayback;
    MinimapImage := TAlphaImageGI.Create(SpaceObjectUiLoop.ContentPanel);
    MinimapImage.World := True;
    MinimapImage.SetDepthByName(DepthExpression);
    MinimapImage.Pos := TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale));
    MinimapImage.SetImagePath(MinimapImagePath);
    MinimapImage.ObjectSize := MinimapImage.GetContentSize;
    MinimapImage.Sme := HalfPoint(MinimapImage.ClientSize);
  end;
end;
{ @end $6F4224 }

{ @routine $6F43C8 TContainerSE_DetachFromSpace }
procedure TContainerSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    if Animation <> nil then
    begin
      Animation.Free;
      Animation := nil;
    end;
    if MinimapImage <> nil then
    begin
      MinimapImage.Free;
      MinimapImage := nil;
    end;
    inherited DetachFromSpace;
  end;
end;
{ @end $6F43C8 }

{ @routine $6F4404 TContainerSE_SetPosition }
procedure TContainerSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Animation.Pos := TruncatePointF(APosition);
    MinimapImage.Pos := TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale));
  end;
end;
{ @end $6F4404 }

{ @routine $6F4488 TContainerSE_SetDepth }
procedure TContainerSE.SetDepth(Value: Single);
begin
  Animation.SetDepth(Value);
end;
{ @end $6F4488 }

{ @routine $6F44A4 TContainerSE_GetDepth }
function TContainerSE.GetDepth: Single;
begin
  Result := Animation.Depth;
end;
{ @end $6F44A4 }

{ @routine $6F44B4 TContainerSE_HitTestCursor }
function TContainerSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $6F44B4 }

{ @routine $6F44D0 TContainerSE_DrawMap }
procedure TContainerSE.DrawMap;
var
  CurrentProcess: TProcessSE;
begin
  CurrentProcess := Space.Process as TProcessSE;
  if PointDistanceSquared(Position, CurrentProcess.RadarCenter) < Sqr(CurrentProcess.RadarRange) then
    MinimapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $6F44D0 }

{ @routine $6F4540 TContainerSE_LoadTemplate }
procedure TContainerSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam(GiResourceSuffix + 'Image');
  MinimapImagePath := Block.GetParam('ImageMap');
end;
{ @end $6F4540 }

{ @routine $6F4600 TContainerSE_QueueImageLoad }
procedure TContainerSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Image: TgaiGI;
  MapImage: TAlphaImageGI;
begin
  Image := TgaiGI.Create(Owner);
  Image.SetImagePath(ImagePath);
  Image.QueueImageLoad(PendingLoads);
  Image.Free;
  MapImage := TAlphaImageGI.Create(Owner);
  MapImage.SetImagePath(MinimapImagePath);
  MapImage.QueueImageLoad(PendingLoads);
  MapImage.Free;
end;
{ @end $6F4600 }

end.
