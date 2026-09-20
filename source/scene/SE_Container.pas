unit SE_Container;
// Unit bracket (inferred): .text 0x008109E4..0x00811040; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native class and methods: $7E5140..$811041.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_AlphaImage, GI_GAI, GI_MessageLoop, SE_Space, Types;

type
  TContainerSE = class(TObjectSE) // @size $5C
  public
    ImagePath: WideString; // @offset $4C
    MinimapImagePath: WideString; // @offset $50
    Animation: TgaiGI; // @offset $54
    MinimapImage: TAlphaImageGI; // @offset $58
    procedure CopyTo(Destination: TObjectSE); override; // @addr $810AB4
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $810B08
    procedure DetachFromSpace; override; // @addr $810D24
    procedure SetPosition(APosition: TPointF); override; // @addr $810D7C
    procedure SetDepth(Value: Single); override; // @addr $810E0C
    function GetDepth: Single; override; // @addr $810E30
    function HitTestCursor: Boolean; override; // @addr $810E50
    procedure DrawMap; override; // @addr $810E80
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $810F00
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $810FC8
  end;

implementation

uses aMyFunction, Globals, GR_Main, SE_Process;

{ @routine $810AB4 TContainerSE_CopyTo }
procedure TContainerSE.CopyTo(Destination: TObjectSE);
begin
  inherited CopyTo(Destination);
  (Destination as TContainerSE).ImagePath := ImagePath;
  (Destination as TContainerSE).MinimapImagePath := MinimapImagePath;
end;
{ @end $810AB4 }

{ @routine $810B08 TContainerSE_AttachToSpace }
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
{ @end $810B08 }

{ @routine $810D24 TContainerSE_DetachFromSpace }
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
{ @end $810D24 }

{ @routine $810D7C TContainerSE_SetPosition }
procedure TContainerSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Animation.SetPosition(TruncatePointF(APosition));
    MinimapImage.SetPosition(TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale)));
  end;
end;
{ @end $810D7C }

{ @routine $810E0C TContainerSE_SetDepth }
procedure TContainerSE.SetDepth(Value: Single);
begin
  Animation.SetDepth(Value);
end;
{ @end $810E0C }

{ @routine $810E30 TContainerSE_GetDepth }
function TContainerSE.GetDepth: Single;
begin
  Result := Animation.Depth;
end;
{ @end $810E30 }

{ @routine $810E50 TContainerSE_HitTestCursor }
function TContainerSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $810E50 }

{ @routine $810E80 TContainerSE_DrawMap }
procedure TContainerSE.DrawMap;
var
  CurrentProcess: TProcessSE;
begin
  CurrentProcess := Space.Process as TProcessSE;
  if PointDistanceSquared(Position, CurrentProcess.RadarCenter) < Sqr(CurrentProcess.RadarRange) then
    MinimapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $810E80 }

{ @routine $810F00 TContainerSE_LoadTemplate }
procedure TContainerSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam(GiResourceSuffix + 'Image');
  MinimapImagePath := Block.GetParam('ImageMap');
end;
{ @end $810F00 }

{ @routine $810FC8 TContainerSE_QueueImageLoad }
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
{ @end $810FC8 }

end.
