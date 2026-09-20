unit SE_Star;
// Unit bracket (inferred): .text 0x008299EC..0x0082A24B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_gi, GI_MessageLoop, SE_Space, Types;

type
  TStarSE = class(TObjectSE) // @size $78 Native VMT at $829A38; used for the first minimap drawing pass.
  public
    AnimationPath: WideString; // @offset $4C
    StaticImagePath: WideString; // @offset $50 Used by TfAB.ShowSpaceInfo for the star thumbnail.
    ImageOrigin: TPoint; // @offset $54 Loaded from SmeImage; drawing centers the control instead.
    MapImagePath: WideString; // @offset $5C
    MapImageOrigin: TPoint; // @offset $60
    StaticImage: TImageGI; // @offset $68
    Animation: TgaiGI; // @offset $6C Native Terron transformation installs its cycle callback here.
    MapImage: TgiGI; // @offset $70
    SavedSequenceFrameIndex: Integer; // @offset $74
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $829AC0
    procedure DetachFromSpace; override; // @addr $829DDC
    procedure SetPosition(APosition: TPointF); override; // @addr $829E60
    function GetSequenceFrameIndex: Integer; // @addr $829F20
    procedure SetSequenceFrameIndex(FrameIndex: Integer); // @addr $829F54
    function HitTestCursor: Boolean; override; // @addr $829F84
    procedure DrawMap; override; // @addr $829FD8
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $82A018
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $82A194
  end;

implementation

uses GlobalsV, Globals, GR_Main, GI_Main, EC_Str;
{ @routine $829AC0 TStarSE_AttachToSpace }
procedure TStarSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Star');
  ConfigureRandomSound('Star');
  inherited AttachToSpace(ASpace);
  if not AnimStar then
  begin
    StaticImage := TImageGI.Create(Space.MapPanel);
    StaticImage.SetImagePath(StaticImagePath);
    StaticImage.SetPositionModeW(True);
    StaticImage.SetDepthByName(DepthExpression);
    StaticImage.SetPosition(TruncatePointF(Position));
    StaticImage.SetSize(StaticImage.GetContentSize);
    StaticImage.SetOrigin(HalfPoint(StaticImage.ClientSize));
  end
  else
  begin
    Animation := TgaiGI.Create(Space.MapPanel);
    Animation.SetImagePath(AnimationPath);
    Animation.LoadFrameSequenceFromText('[65,0-' + IntToWideString(Animation.GetMainImageFrameCount - 1) + ']');
    Animation.SetPositionModeW(True);
    Animation.SetDepthByName(DepthExpression);
    Animation.SetPosition(TruncatePointF(Position));
    Animation.SetSize(Animation.GetContentSize);
    Animation.SetOrigin(HalfPoint(Animation.ClientSize));
    Animation.SetSequenceFrame(SavedSequenceFrameIndex);
    Animation.RestartPlayback;
  end;
  MapImage := TgiGI.Create(SpaceObjectUiLoop.ContentPanel);
  MapImage.SetPositionModeW(True);
  MapImage.SetDepthByName(DepthExpression);
  MapImage.SetPosition(TruncatePointF(MakePointF(Position.X * Space.MinimapScale, Position.Y * Space.MinimapScale)));
  MapImage.SetOrigin(MapImageOrigin);
  MapImage.SetImagePath(MapImagePath);
  MapImage.SetSize(MapImage.GetContentSize);
end;
{ @end $829AC0 }

{ @routine $829DDC TStarSE_DetachFromSpace }
procedure TStarSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if Animation <> nil then
  begin
    SavedSequenceFrameIndex := Animation.SequenceFrame;
    Animation.Free;
    Animation := nil;
  end;
  if StaticImage <> nil then
  begin
    StaticImage.Free;
    StaticImage := nil;
  end;
  if MapImage <> nil then
  begin
    MapImage.Free;
    MapImage := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $829DDC }

{ @routine $829E60 TStarSE_SetPosition }
procedure TStarSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    if StaticImage <> nil then StaticImage.SetPosition(TruncatePointF(APosition));
    if Animation <> nil then Animation.SetPosition(TruncatePointF(APosition));
    MapImage.SetPosition(TruncatePointF(MakePointF(APosition.X * Space.MinimapScale, APosition.Y * Space.MinimapScale)));
  end;
end;
{ @end $829E60 }

{ @routine $829F20 TStarSE_GetSequenceFrameIndex }
function TStarSE.GetSequenceFrameIndex: Integer;
begin
  if Animation = nil then Result := SavedSequenceFrameIndex
  else Result := Animation.SequenceFrame;
end;
{ @end $829F20 }

{ @routine $829F54 TStarSE_SetSequenceFrameIndex }
procedure TStarSE.SetSequenceFrameIndex(FrameIndex: Integer);
begin
  SavedSequenceFrameIndex := FrameIndex;
  if Animation <> nil then Animation.SetSequenceFrame(FrameIndex);
end;
{ @end $829F54 }

{ @routine $829F84 TStarSE_HitTestCursor }
function TStarSE.HitTestCursor: Boolean;
begin
  Result := False;
  if not IsAttachedToSpace then
  begin
    Result := False;
    Exit;
  end;
  if StaticImage <> nil then Result := StaticImage.HitTestCursor;
  if Animation <> nil then Result := Animation.HitTestCursor;
end;
{ @end $829F84 }

{ @routine $829FD8 TStarSE_DrawMap }
procedure TStarSE.DrawMap;
begin
  MapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $829FD8 }

{ @routine $82A018 TStarSE_LoadTemplate }
procedure TStarSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  StaticImagePath := Block.GetParam('Image');
  AnimationPath := Block.GetParam('Anim');
  MapImagePath := Block.GetParam('ImageMap');
  ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
  MapImageOrigin := GetPointGI(Block.GetParam('SmeImageMap'));
end;
{ @end $82A018 }

{ @routine $82A194 TStarSE_QueueImageLoad }
procedure TStarSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
  if not AnimStar then
    with TImageGI.Create(Owner) do
    begin
      SetImagePath(StaticImagePath);
      QueueImageLoad(PendingLoads);
      Free;
    end
  else
    with TgaiGI.Create(Owner) do
    begin
      SetImagePath(AnimationPath);
      QueueImageLoad(PendingLoads);
      Free;
    end;
  with TgiGI.Create(Owner) do
  begin
    SetImagePath(MapImagePath);
    QueueImageLoad(PendingLoads);
    Free;
  end;
end;
{ @end $82A194 }

end.
