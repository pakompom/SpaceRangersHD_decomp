unit SE_Star;
// Unit bracket (inferred): .text 0x006F72C4..0x006F7B23; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_GAI, GI_Image, GI_gi, GI_MessageLoop, SE_Space, Types;

type
  TStarSE = class(TObjectSE) // @size $78 Native VMT at $6F7310; used for the first minimap drawing pass.
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
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $6F7398
    procedure DetachFromSpace; override; // @addr $6F76B4
    procedure SetPosition(APosition: TPointF); override; // @addr $6F7738 @ida "void __usercall $name(TStarSE *Self@<eax>, TPointF *APosition@<edx>);"
    function GetSequenceFrameIndex: Integer; // @addr $6F77F8
    procedure SetSequenceFrameIndex(FrameIndex: Integer); // @addr $6F782C
    function HitTestCursor: Boolean; override; // @addr $6F785C
    procedure DrawMap; override; // @addr $6F78B0
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $6F78F0
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $6F7A6C
  end;

implementation

uses GlobalsV, Globals, GR_Main, GI_Main, EC_Str;
{ @routine $6F7398 TStarSE_AttachToSpace }
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
{ @end $6F7398 }

{ @routine $6F76B4 TStarSE_DetachFromSpace }
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
{ @end $6F76B4 }

{ @routine $6F7738 TStarSE_SetPosition }
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
{ @end $6F7738 }

{ @routine $6F77F8 TStarSE_GetSequenceFrameIndex }
function TStarSE.GetSequenceFrameIndex: Integer;
begin
  if Animation = nil then Result := SavedSequenceFrameIndex
  else Result := Animation.SequenceFrame;
end;
{ @end $6F77F8 }

{ @routine $6F782C TStarSE_SetSequenceFrameIndex }
procedure TStarSE.SetSequenceFrameIndex(FrameIndex: Integer);
begin
  SavedSequenceFrameIndex := FrameIndex;
  if Animation <> nil then Animation.SetSequenceFrame(FrameIndex);
end;
{ @end $6F782C }

{ @routine $6F785C TStarSE_HitTestCursor }
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
{ @end $6F785C }

{ @routine $6F78B0 TStarSE_DrawMap }
procedure TStarSE.DrawMap;
begin
  MapImage.Draw(Classes.Rect(0, 0, RenderScratchBuffer.Width, RenderScratchBuffer.Height));
end;
{ @end $6F78B0 }

{ @routine $6F78F0 TStarSE_LoadTemplate }
procedure TStarSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  StaticImagePath := Block.GetParam('Image');
  AnimationPath := Block.GetParam('Anim');
  MapImagePath := Block.GetParam('ImageMap');
  ImageOrigin := GetPointGI(Block.GetParam('SmeImage'));
  MapImageOrigin := GetPointGI(Block.GetParam('SmeImageMap'));
end;
{ @end $6F78F0 }

{ @routine $6F7A6C TStarSE_QueueImageLoad }
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
{ @end $6F7A6C }

end.
