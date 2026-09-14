unit SE_Container;
// Unit bracket (inferred): .text 0x0072FEC4..0x00730520; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class and methods: $72FE98..$730521.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_AlphaImage, GI_GAI, GI_MessageLoop, SE_Space, Types;

type
  TContainerSE = class(TObjectSE) // @size $5C
  public
    ImagePath: WideString; // @offset $4C
    MinimapImagePath: WideString; // @offset $50
    Animation: TgaiGI; // @offset $54
    MinimapImage: TAlphaImageGI; // @offset $58
    procedure CopyTo(Destination: TObjectSE); override; // @addr $72FF94
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $72FFE8
    procedure DetachFromSpace; override; // @addr $730204
    procedure SetPosition(APosition: TPointF); override; // @addr $73025C @ida "void __usercall $name(TContainerSE *Self@<eax>, TPointF *APosition@<edx>);"
    procedure SetDepth(Value: Single); override; // @addr $7302EC @ida "void __userpurge $name(TContainerSE *Self@<eax>, float Value@<^0>);"
    function GetDepth: Single; override; // @addr $730310 @ida "float __usercall $name@<st0>(TContainerSE *Self@<eax>);"
    function HitTestCursor: Boolean; override; // @addr $730330
    procedure DrawMap; override; // @addr $730360
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7303E0
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $7304A8
  end;

implementation

uses aMyFunction, Globals, GR_Main, SE_Process;

{ @routine $72FF94 TContainerSE_CopyTo }
procedure TContainerSE.CopyTo(Destination: TObjectSE);
begin
  inherited CopyTo(Destination);
  (Destination as TContainerSE).ImagePath := ImagePath;
  (Destination as TContainerSE).MinimapImagePath := MinimapImagePath;
end;
{ @end $72FF94 }

{ @routine $72FFE8 TContainerSE_AttachToSpace }
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
    Animation.SetPositionModeW(True);
    Animation.SetDepthByName(DepthExpression);
    Animation.SetPosition(TruncatePointF(Position));
    Animation.SetSize(Animation.GetContentSize);
    Animation.SetOrigin(HalfPoint(Animation.ClientSize));
    Animation.SetSequenceFrame(RandomIntRange(0, Animation.SequenceFrameCount - 1));
    Animation.RestartPlayback;
    MinimapImage := TAlphaImageGI.Create(SpaceObjectUiLoop.ContentPanel);
    MinimapImage.SetPositionModeW(True);
    MinimapImage.SetDepthByName(DepthExpression);
    MinimapImage.SetPosition(TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale)));
    MinimapImage.SetImagePath(MinimapImagePath);
    MinimapImage.SetSize(MinimapImage.GetContentSize);
    MinimapImage.SetOrigin(HalfPoint(MinimapImage.ClientSize));
  end;
end;
{ @end $72FFE8 }

{ @routine $730204 TContainerSE_DetachFromSpace }
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
{ @end $730204 }

{ @routine $73025C TContainerSE_SetPosition }
procedure TContainerSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Animation.SetPosition(TruncatePointF(APosition));
    MinimapImage.SetPosition(TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale)));
  end;
end;
{ @end $73025C }

{ @routine $7302EC TContainerSE_SetDepth }
procedure TContainerSE.SetDepth(Value: Single);
begin
  Animation.SetDepth(Value);
end;
{ @end $7302EC }

{ @routine $730310 TContainerSE_GetDepth }
function TContainerSE.GetDepth: Single;
begin
  Result := Animation.Depth;
end;
{ @end $730310 }

{ @routine $730330 TContainerSE_HitTestCursor }
function TContainerSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $730330 }

{ @routine $730360 TContainerSE_DrawMap }
procedure TContainerSE.DrawMap;
var
  CurrentProcess: TProcessSE;
begin
  CurrentProcess := Space.Process as TProcessSE;
  if PointDistanceSquared(Position, CurrentProcess.RadarCenter) < Sqr(CurrentProcess.RadarRange) then
    MinimapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $730360 }

{ @routine $7303E0 TContainerSE_LoadTemplate }
procedure TContainerSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam(GiResourceSuffix + 'Image');
  MinimapImagePath := Block.GetParam('ImageMap');
end;
{ @end $7303E0 }

{ @routine $7304A8 TContainerSE_QueueImageLoad }
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
{ @end $7304A8 }

end.
