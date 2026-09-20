unit SE_Hole;
// Unit bracket (inferred): .text 0x007ECBE8..0x007ED5FC; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_MessageLoop, SE_Space, Types;

type
  THoleSE = class(TObjectSE) // @size $78
  public
    ImagePath: WideString; // @offset $4C Animation resource used by star-map information thumbnails.
    MapImagePath: WideString; // @offset $50
    Animation: TgaiGI; // @offset $54
    MapImage: TImageGI; // @offset $58
    SavedSequenceFrameIndex: Integer; // @offset $5C
    GalaxyImagePath: WideString; // @offset $68
    GalaxyPriority: Integer; // @offset $6C
    NameTextPath: WideString; // @offset $70 Localization key read by TfStarMap.ShowFilmObjectInfo.
    InfoTextPath: WideString; // @offset $74 Localization key read by TfStarMap.ShowFilmObjectInfo.
    State: Integer; // @offset $60
    HitRadius: Integer; // @offset $64 Used by star-map film-object hit testing.
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7ECCCC
    procedure DetachFromSpace; override; // @addr $7ECF38
    procedure SetPosition(APosition: TPointF); override; // @addr $7ECFD4
    procedure DrawMap; override; // @addr $7ED064
    function HitTestCursor: Boolean; override; // @addr $7ED0E4
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7ED114
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $7ED418
    procedure AnimationCycleComplete(Sender: TObjectGI); // @addr $7ED434
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $7ED584
    procedure SetState(Value: Integer); // @addr $7ECFA0 Preserves state 1 when asked to reset an attached effect to state 0.
  end;

implementation

uses Globals, GR_Main, GI_Main, EC_Str, SE_Process;

{ @routine $7ECCCC THoleSE_AttachToSpace }
procedure THoleSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Hole');
  ConfigureRandomSound('Hole');
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  { Both native state branches load the same resource. }
  if State = 1 then Animation.SetImagePath(ImagePath)
  else Animation.SetImagePath(ImagePath);
  Animation.CycleCompleteCallback := AnimationCycleComplete;
  Animation.SetSize(Animation.GetContentSize);
  Animation.SetOrigin(HalfPoint(Animation.ClientSize));
  Animation.SetDepthByName(DepthExpression);
  Animation.SetPosition(TruncatePointF(Position));
  Animation.SetPositionModeW(True);
  if State = 1 then Animation.SequenceIndex := 0
  else Animation.SequenceIndex := 1;
  Animation.UpdateAutoGeometry;
  if State = 1 then SavedSequenceFrameIndex := 0;
  Animation.SetSequenceFrame(SavedSequenceFrameIndex);
  Animation.RestartPlayback;
  MapImage := TImageGI.Create(SpaceObjectUiLoop.ContentPanel);
  MapImage.SetPositionModeW(True);
  MapImage.SetDepthByName(DepthExpression);
  MapImage.SetPosition(TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale)));
  MapImage.SetImagePath(MapImagePath);
  MapImage.SetSize(MapImage.GetContentSize);
  MapImage.SetOrigin(HalfPoint(MapImage.GetContentSize));
end;
{ @end $7ECCCC }

{ @routine $7ECF38 THoleSE_DetachFromSpace }
procedure THoleSE.DetachFromSpace;
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
{ @end $7ECF38 }

{ @routine $7ECFA0 THoleSE_SetState }
procedure THoleSE.SetState(Value: Integer);
begin
  if (State = 1) and (Value = 0) and IsAttachedToSpace then Exit;
  State := Value;
end;
{ @end $7ECFA0 }

{ @routine $7ECFD4 THoleSE_SetPosition }
procedure THoleSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Animation.SetPosition(TruncatePointF(APosition));
    MapImage.SetPosition(TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale)));
  end;
end;
{ @end $7ECFD4 }

{ @routine $7ED064 THoleSE_DrawMap }
procedure THoleSE.DrawMap;
begin
  with Space.Process as TProcessSE do
    if PointDistanceSquared(Self.Position, RadarCenter) < Sqr(RadarRange) then
      MapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $7ED064 }

{ @routine $7ED0E4 THoleSE_HitTestCursor }
function THoleSE.HitTestCursor: Boolean;
begin
  if not IsAttachedToSpace then Result := False
  else Result := Animation.HitTestCursor;
end;
{ @end $7ED0E4 }

{ @routine $7ED114 THoleSE_LoadTemplate }
procedure THoleSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  MapImagePath := Block.GetParam('ImageMap');
  if Block.CountParams('Radius') > 0 then HitRadius := ExtractDigitsToIntW(Block.GetParam('Radius'))
  else HitRadius := 80;
  if Block.CountParams('GalaxyImage') > 0 then GalaxyImagePath := Block.GetParam('GalaxyImage')
  else GalaxyImagePath := 'GI,Bm.FormGalaxy.BlackHole';
  if Block.CountParams('GalaxyPriority') > 0 then GalaxyPriority := ExtractDigitsToIntW(Block.GetParam('GalaxyPriority'))
  else GalaxyPriority := 80;
  if Block.CountParams('NamePath') > 0 then NameTextPath := Block.GetParam('NamePath')
  else NameTextPath := 'FormInfo.HoleName';
  if Block.CountParams('TextPath') > 0 then InfoTextPath := Block.GetParam('TextPath')
  else InfoTextPath := 'FormInfo.HoleText';
end;
{ @end $7ED114 }

{ @routine $7ED418 THoleSE_ApplyConfig }
procedure THoleSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $7ED418 }

{ @routine $7ED434 THoleSE_AnimationCycleComplete }
procedure THoleSE.AnimationCycleComplete(Sender: TObjectGI);
begin
  if State = 1 then
  begin
    Animation.SetImagePath(ImagePath);
    Animation.SetSize(Animation.GetContentSize);
    Animation.SetOrigin(HalfPoint(Animation.ClientSize));
    Animation.SequenceIndex := 1;
    Animation.UpdateAutoGeometry;
    Animation.SetSequenceFrame(0);
    Animation.RestartPlayback;
  end
  else if State = 2 then
  begin
    if Animation.SequenceIndex = 2 then DetachFromSpace
    else
    begin
      Animation.SetImagePath(ImagePath);
      Animation.SetSize(Animation.GetContentSize);
      Animation.SetOrigin(HalfPoint(Animation.ClientSize));
      Animation.SequenceIndex := 2;
      Animation.UpdateAutoGeometry;
      Animation.SetSequenceFrame(0);
      Animation.RestartPlayback;
    end;
  end;
end;
{ @end $7ED434 }

{ @routine $7ED584 THoleSE_QueueImageLoad }
procedure THoleSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
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
{ @end $7ED584 }

end.
