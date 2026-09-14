unit SE_Laser;
// Unit bracket (inferred): .text 0x007CC62C..0x007CCFF5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    AnimationTimer: PCallbackTimerGI; // @offset $68
    ManualAnimation: Boolean; // @offset $6C
    EndPosition: TPointF; // @offset $70 Rebuilt endpoint after the final segment.
    destructor Destroy; override; // @addr $7CC6E0 @ida "void __usercall $name(TLaserSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7CC730
    procedure DetachFromSpace; override; // @addr $7CC760
    procedure SetPosition(APosition: TPointF); override; // @addr $7CC788 @ida "void __usercall $name(TLaserSE *Self@<eax>, TPointF *APosition@<edx>);"
    procedure RebuildSegments; // @addr $7CC7C0
    procedure ClearSegments; // @addr $7CCA84
    procedure UpdateSegmentImages; // @addr $7CCAFC
    procedure StartAnimationTimer; // @addr $7CCC0C
    procedure StopAnimationTimer; // @addr $7CCC54
    procedure AdvanceAnimationTimer(Timer: PCallbackTimerGI; UserData: Integer); // @addr $7CCC84
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7CCCCC
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $7CCE10
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $7CCF08
  end;

implementation

uses Math, GI_Main;
{ @routine $7CC6E0 TLaserSE_Destroy }
destructor TLaserSE.Destroy;
begin
  if FrameImages <> nil then
  begin
    FrameImages.Free;
    FrameImages := nil;
  end;
  inherited Destroy;
end;
{ @end $7CC6E0 }

{ @routine $7CC730 TLaserSE_AttachToSpace }
procedure TLaserSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if not IsAttachedToSpace then
  begin
    inherited AttachToSpace(ASpace);
    RebuildSegments;
  end;
end;
{ @end $7CC730 }

{ @routine $7CC760 TLaserSE_DetachFromSpace }
procedure TLaserSE.DetachFromSpace;
begin
  if IsAttachedToSpace then
  begin
    ClearSegments;
    inherited DetachFromSpace;
  end;
end;
{ @end $7CC760 }

{ @routine $7CC788 TLaserSE_SetPosition }
procedure TLaserSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then RebuildSegments;
end;
{ @end $7CC788 }

{ @routine $7CC7C0 TLaserSE_RebuildSegments }
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
  ImageAngle := Round(Angle / 3.1415926 * 127) and $FF;
  Distance := SegmentSize / 2;
  BeamLength := Sqrt(Sqr(TargetPosition.X - Position.X) + Sqr(TargetPosition.Y - Position.Y));
  Segments := TList.Create;
  Segment := nil;
  while Distance < BeamLength do
  begin
    Segment := TRotateImage2GI.Create(Space.MapPanel);
    Segment.SetPositionModeW(True);
    Segment.SetDepthByName(DepthExpression);
    EndPosition := MakePointF(AngleSin * Distance + Position.X, Position.Y - AngleCos * Distance);
    Segment.SetPosition(TruncatePointF(EndPosition));
    Segment.SetAngle(ImageAngle);
    Segment.SetAlpha(192);
    Segment.SetImage(FrameImages.GetTextAt(0), Classes.Point(SegmentSize, SegmentSize), Classes.Point(SegmentSize div 2, SegmentSize div 2));
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
{ @end $7CC7C0 }

{ @routine $7CCA84 TLaserSE_ClearSegments }
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
      Segment.SetActive(False);
      Space.MapPanel.FreeOwnedChild(Segment);
    end;
    Segments.Free;
    { The native routine leaves the freed list pointer unchanged. }
  end;
end;
{ @end $7CCA84 }

{ @routine $7CCAFC TLaserSE_UpdateSegmentImages }
procedure TLaserSE.UpdateSegmentImages;
var
  Index: Integer;
  Segment: TRotateImage2GI;
begin
  if (Segments <> nil) and (FrameIndex >= 0) and (FrameImages <> nil) and (FrameIndex < FrameImages.GetCount) then
    for Index := 0 to Segments.Count - 1 do
    begin
      Segment := Segments[Index];
      Segment.SetImage(FrameImages.GetTextAt(FrameIndex), Classes.Point(SegmentSize, SegmentSize), Classes.Point(SegmentSize div 2, SegmentSize div 2));
    end;
end;
{ @end $7CCAFC }

{ @routine $7CCC0C TLaserSE_StartAnimationTimer }
procedure TLaserSE.StartAnimationTimer;
begin
  StopAnimationTimer;
  if not ManualAnimation then
    AnimationTimer := Space.Screen.ScheduleCallbackTimer(FrameInterval, FrameInterval, AdvanceAnimationTimer);
end;
{ @end $7CCC0C }

{ @routine $7CCC54 TLaserSE_StopAnimationTimer }
procedure TLaserSE.StopAnimationTimer;
begin
  if AnimationTimer <> nil then
  begin
    Space.Screen.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
end;
{ @end $7CCC54 }

{ @routine $7CCC84 TLaserSE_AdvanceAnimationTimer }
procedure TLaserSE.AdvanceAnimationTimer(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Inc(FrameIndex);
  if FrameIndex < FrameImages.GetCount then UpdateSegmentImages
  else
  begin
    FrameIndex := 0;
    UpdateSegmentImages;
  end;
end;
{ @end $7CCC84 }

{ @routine $7CCCCC TLaserSE_LoadTemplate }
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
{ @end $7CCCCC }

{ @routine $7CCE10 TLaserSE_ApplyConfig }
procedure TLaserSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
  if Block.CountParams('PosDes') > 0 then TargetPosition := PointToPointF(GetPointGI(Block.GetParam('PosDes')));
  if Block.CountParams('ManualAnim') > 0 then ManualAnimation := ParseEnabledNameGI(Block.GetParam('ManualAnim'));
end;
{ @end $7CCE10 }

{ @routine $7CCF08 TLaserSE_QueueImageLoad }
procedure TLaserSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Index, Count: Integer;
  Segment: TRotateImage2GI;
begin
  Segment := TRotateImage2GI.Create(Owner);
  Count := FrameImages.GetCount;
  for Index := 0 to Count - 1 do
  begin
    Segment.SetImage(FrameImages.GetTextAt(Index), Classes.Point(SegmentSize, SegmentSize), Classes.Point(SegmentSize div 2, SegmentSize div 2));
    Segment.QueueImageLoad(PendingLoads);
  end;
  Segment.Free;
end;
{ @end $7CCF08 }

end.
