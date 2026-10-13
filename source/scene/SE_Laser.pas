unit SE_Laser;

interface

uses Classes, EC_BlockPar, EC_Str, EC_Struct, GI_MessageLoop, GI_RotateImage2, SE_Space, Types;

type
  TLaserSE = class(TObjectSE) // @size $78
  public
    FrameImages: TStringsEC; // @offset $4C
    FrameInterval: Cardinal; // @offset $50
    TargetPosition: TPointF; // @offset $54
    SegmentSize: Integer; // @offset $5C Template RadiusUnit; used as sprite dimensions and beam spacing.
    Segments: TList; // @offset $60 Owned rotated image controls while attached.
    FrameIndex: Integer; // @offset $64
    AnimationTimer: TCallbackTimerIdGI; // @offset $68
    ManualAnimation: Boolean; // @offset $6C
    EndPosition: TPointF; // @offset $70 Rebuilt endpoint after the final segment.
    destructor Destroy; override; // @addr $7810C4
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7810FC
    procedure DetachFromSpace; override; // @addr $781120
    procedure SetPosition(APosition: TPointF); override; // @addr $781140
    procedure RebuildSegments; // @addr $781170
    procedure ClearSegments; // @addr $7813D0
    procedure UpdateSegmentImages; // @addr $781424
    procedure StartAnimationTimer; // @addr $7814F4
    procedure StopAnimationTimer; // @addr $781528
    procedure AdvanceAnimationTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal); // @addr $781548
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $781574
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $781690
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $781780
  end;

implementation

uses Math, GI_Main, aMyFunction;
{ @routine $7810C4 TLaserSE_Destroy }
destructor TLaserSE.Destroy;
begin
  if FrameImages <> nil then
  begin
    FrameImages.Free;
    FrameImages := nil;
  end;
  inherited Destroy;
end;
{ @end $7810C4 }

{ @routine $7810FC TLaserSE_AttachToSpace }
procedure TLaserSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not IsAttachedToSpace then
  begin
    inherited AttachToSpace(ASpace);
    RebuildSegments;
  end;
end;
{ @end $7810FC }

{ @routine $781120 TLaserSE_DetachFromSpace }
procedure TLaserSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    ClearSegments;
    inherited DetachFromSpace;
  end;
end;
{ @end $781120 }

{ @routine $781140 TLaserSE_SetPosition }
procedure TLaserSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then RebuildSegments;
end;
{ @end $781140 }

{ @routine $781170 TLaserSE_RebuildSegments }
procedure TLaserSE.RebuildSegments;
var
  Segment: TRotateImage2GI;
  Angle, AngleSin, AngleCos, Distance, BeamLength: Double;
  ImageAngle: Integer;
begin
  ClearSegments;
  Angle := ArcTan2(TargetPosition.X - Position.X, -(TargetPosition.Y - Position.Y));
  AngleSin := Sin(Angle);
  AngleCos := Cos(Angle);
  ImageAngle := Byte(Round(Angle / GamePi * 127));
  Distance := SegmentSize / 2;
  BeamLength := Sqrt(Sqr(TargetPosition.X - Position.X) + Sqr(TargetPosition.Y - Position.Y));
  Segments := TList.Create;
  Segment := nil;
  while Distance < BeamLength do
  begin
    Segment := TRotateImage2GI.Create(Space.MapPanel);
    Segment.World := True;
    Segment.SetDepthByName(DepthExpression);
    EndPosition := MakePointF(AngleSin * Distance + Position.X, Position.Y - AngleCos * Distance);
    Segment.Pos := TruncatePointF(EndPosition);
    Segment.SetAngle(ImageAngle);
    Segment.SetAlpha(192);
    Segment.SetImage(FrameImages.Strings[0], Classes.Point(SegmentSize, SegmentSize), Classes.Point(SegmentSize div 2, SegmentSize div 2));
    Segments.Add(Segment);
    Distance := Distance + SegmentSize - 4;
  end;
  { Native code retains this empty check of the final segment. }
  if Segment <> nil then begin end;
  EndPosition := MakePointF(SegmentSize / 2 * AngleSin + EndPosition.X, EndPosition.Y - SegmentSize / 2 * AngleCos);
  FrameIndex := 0;
  UpdateSegmentImages;
  StartAnimationTimer;
end;
{ @end $781170 }

{ @routine $7813D0 TLaserSE_ClearSegments }
procedure TLaserSE.ClearSegments;
var
  Index: Integer;
  Segment: TObjectGI;
begin
  StopAnimationTimer;
  if Segments <> nil then
  begin
    for Index := 0 to Segments.Count - 1 do
    begin
      Segment := Segments[Index];
      Segment.IsActive := False;
      Space.MapPanel.FreeOwnedChild(Segment);
    end;
    Segments.Free;
    { The native routine leaves the freed list pointer unchanged. }
  end;
end;
{ @end $7813D0 }

{ @routine $781424 TLaserSE_UpdateSegmentImages }
procedure TLaserSE.UpdateSegmentImages;
var
  Index: Integer;
  Segment: TRotateImage2GI;
begin
  if (Segments <> nil) and (FrameIndex >= 0) and (FrameImages <> nil) and (FrameIndex < FrameImages.Count) then
    for Index := 0 to Segments.Count - 1 do
    begin
      Segment := Segments[Index];
      Segment.SetImage(FrameImages.Strings[FrameIndex], Classes.Point(SegmentSize, SegmentSize), Classes.Point(SegmentSize div 2, SegmentSize div 2));
    end;
end;
{ @end $781424 }

{ @routine $7814F4 TLaserSE_StartAnimationTimer }
procedure TLaserSE.StartAnimationTimer;
begin
  StopAnimationTimer;
  if not ManualAnimation then
    AnimationTimer := Space.Screen.ScheduleCallbackTimer(FrameInterval, FrameInterval, AdvanceAnimationTimer);
end;
{ @end $7814F4 }

{ @routine $781528 TLaserSE_StopAnimationTimer }
procedure TLaserSE.StopAnimationTimer;
begin
  if AnimationTimer <> 0 then
  begin
    Space.Screen.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := 0;
  end;
end;
{ @end $781528 }

{ @routine $781548 TLaserSE_AdvanceAnimationTimer }
procedure TLaserSE.AdvanceAnimationTimer(Timer: TCallbackTimerIdGI; UserData: Cardinal);
begin
  Inc(FrameIndex);
  if FrameIndex < FrameImages.Count then UpdateSegmentImages
  else
  begin
    FrameIndex := 0;
    UpdateSegmentImages;
  end;
end;
{ @end $781548 }

{ @routine $781574 TLaserSE_LoadTemplate }
procedure TLaserSE.LoadTemplate(Block: TBlockParEC);
var
  Index: Integer;
begin
  inherited LoadTemplate(Block);
  if FrameImages <> nil then
  begin
    FrameImages.Free;
    FrameImages := nil;
  end;
  FrameImages := TStringsEC.Create;
  FrameInterval := ExtractDigitsToIntW(Block.GetParam('Time'));
  Index := 0;
  while Block.CountParams(IntToWideString(Index)) > 0 do
  begin
    FrameImages.Add(TrimWideString(Block.GetParam(IntToWideString(Index))));
    Inc(Index);
  end;
  SegmentSize := ExtractDigitsToIntW(Block.GetParam('RadiusUnit'));
end;
{ @end $781574 }

{ @routine $781690 TLaserSE_ApplyConfig }
procedure TLaserSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if Block.CountParams('PosDes') > 0 then TargetPosition := PointToPointF(GetPointGI(Block.GetParam('PosDes')));
  if Block.CountParams('ManualAnim') > 0 then ManualAnimation := ParseEnabledNameGI(Block.GetParam('ManualAnim'));
end;
{ @end $781690 }

{ @routine $781780 TLaserSE_QueueImageLoad }
procedure TLaserSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Index, Count: Integer;
  Segment: TRotateImage2GI;
begin
  Segment := TRotateImage2GI.Create(Owner);
  Count := FrameImages.Count;
  for Index := 0 to Count - 1 do
  begin
    Segment.SetImage(FrameImages.Strings[Index], Classes.Point(SegmentSize, SegmentSize), Classes.Point(SegmentSize div 2, SegmentSize div 2));
    Segment.QueueImageLoad(PendingLoads);
  end;
  Segment.Free;
end;
{ @end $781780 }

end.
