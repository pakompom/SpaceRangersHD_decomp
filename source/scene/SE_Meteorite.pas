unit SE_Meteorite;
// Unit bracket (inferred): .text 0x007C8AA0..0x007C92FE; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_BlockPar, EC_Struct, GI_GAI, SE_Space, Types;

type
  TMeteoriteSE = class(TObjectSE) // @size $64
  public
    ImagePath: WideString; // @offset $4C
    TimerInterval: Integer; // @offset $50
    Speed: Single; // @offset $54
    Angle: Single; // @offset $58 Radians, zero points upward.
    Animation: TgaiGI; // @offset $5C
    MoveTimer: PSpaceTimerSE; // @offset $60

    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $7C8B68 @ida "TMeteoriteSE *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *GraphKey@<ecx>, TPoint *UnusedPosition@<^0>);"
    destructor Destroy; override; // @addr $7C8BF4 @ida "void __usercall $name(TMeteoriteSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7C8C28
    procedure DetachFromSpace; override; // @addr $7C8D78
    procedure SetPosition(APosition: TPointF); override; // @addr $7C8DD4 @ida "void __usercall $name(TMeteoriteSE *Self@<eax>, TPointF *APosition@<edx>);"
    function IsNearView(Point: TPointF): Boolean; // @addr $7C8E1C @ida "bool __usercall $name@<al>(TMeteoriteSE *Self@<eax>, TPointF *Point@<edx>);"
    procedure PlaceRandomly; // @addr $7C8EBC
    procedure RestartOutsideView; // @addr $7C8F34
    procedure AdvanceMotion(Timer: PSpaceTimerSE; UserData: Integer); // @addr $7C90B8
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7C91A8
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $7C92E4
  end;

implementation

uses Math, GlobalsV, GR_Main, GI_Main, EC_Str, aMyFunction, SE_Process;

{ @routine $7C8B68 TMeteoriteSE_Create }
constructor TMeteoriteSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
end;
{ @end $7C8B68 }

{ @routine $7C8BF4 TMeteoriteSE_Destroy }
destructor TMeteoriteSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $7C8BF4 }

{ @routine $7C8C28 TMeteoriteSE_AttachToSpace }
procedure TMeteoriteSE.AttachToSpace(ASpace: TSpaceSE);
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
  Animation.RestartPlayback;
  PlaceRandomly;
  MoveTimer := Space.CreateTimer(TimerInterval, TimerInterval, AdvanceMotion, 0);
end;
{ @end $7C8C28 }

{ @routine $7C8D78 TMeteoriteSE_DetachFromSpace }
procedure TMeteoriteSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if MoveTimer <> nil then
  begin
    Space.DeleteTimer(MoveTimer);
    MoveTimer := nil;
  end;
  if Animation <> nil then
  begin
    Animation.Free;
    Animation := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $7C8D78 }

{ @routine $7C8DD4 TMeteoriteSE_SetPosition }
procedure TMeteoriteSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Animation.SetPosition(TruncatePointF(APosition));
end;
{ @end $7C8DD4 }

{ @routine $7C8E1C TMeteoriteSE_IsNearView }
function TMeteoriteSE.IsNearView(Point: TPointF): Boolean;
var Height, Width: Single;
begin
  Width := Cardinal(GameScreenWidth);
  Height := Cardinal(GameScreenHeight);
  Result := (SpaceViewPosition.X - Width < Point.X) and
    (SpaceViewPosition.X + Width > Point.X) and
    (SpaceViewPosition.Y - Height < Point.Y) and
    (SpaceViewPosition.Y + Height > Point.Y);
end;
{ @end $7C8E1C }

{ @routine $7C8EBC TMeteoriteSE_PlaceRandomly }
procedure TMeteoriteSE.PlaceRandomly;
var
  Radius: Single;
  Bound: Integer;
begin
  if Space <> nil then
  begin
    Radius := TProcessSE(Space.Process).SystemRadius;
    Bound := Round(Radius);
    SetPosition(MakePointF(RandomIntRange(-Bound, Bound), RandomIntRange(-Bound, Bound)));
  end;
end;
{ @end $7C8EBC }

{ @routine $7C8F34 TMeteoriteSE_RestartOutsideView }
procedure TMeteoriteSE.RestartOutsideView;
var
  Radius: Single;
  Bound: Integer;
  StartPoint, EndPoint, Intersection: TPointF;
begin
  if Space <> nil then
  begin
    Radius := TProcessSE(Space.Process).SystemRadius;
    repeat
      Bound := Round(Radius);
      EndPoint := MakePointF(RandomIntRange(-Bound, Bound), RandomIntRange(-Bound, Bound));
      StartPoint := MakePointF(EndPoint.X + Sin(Pi + Angle) * (Radius * 4),
        EndPoint.Y - Cos(Pi + Angle) * (Radius * 4));
    until SegmentIntersectsRectEdges(StartPoint, EndPoint,
      MakePointF(-Radius * 1.2, -Radius * 1.2), MakePointF(1.2 * Radius, 1.2 * Radius), Intersection) and
      not IsNearView(Intersection);
    SetPosition(Intersection);
  end;
end;
{ @end $7C8F34 }

{ @routine $7C90B8 TMeteoriteSE_AdvanceMotion }
procedure TMeteoriteSE.AdvanceMotion(Timer: PSpaceTimerSE; UserData: Integer);
var Limit: Single;
begin
  SetPosition(MakePointF(Position.X + Sin(Angle) * Speed, Position.Y - Cos(Angle) * Speed));
  Limit := TProcessSE(Space.Process).SystemRadius * 1.3;
  if ((-Limit > Position.X) or (Position.X > Limit) or (-Limit > Position.Y) or (Position.Y > Limit)) and
    not IsNearView(Position) then RestartOutsideView;
end;
{ @end $7C90B8 }

{ @routine $7C91A8 TMeteoriteSE_LoadTemplate }
procedure TMeteoriteSE.LoadTemplate(Block: TBlockParEC);
var Range: TPointF;
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
  TimerInterval := ExtractDigitsToIntW(Block.GetParam('Time'));
  Range := GetFloatPointGI(Block.GetParam('Speed'));
  Speed := RandomFloatRange(Range.X, Range.Y);
  Angle := HeadingDegreesToRadians(ExtractDecimalToSingleW(Block.GetParam('Angle')));
end;
{ @end $7C91A8 }

{ @routine $7C92E4 TMeteoriteSE_ApplyConfig }
procedure TMeteoriteSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $7C92E4 }

end.
