unit SE_Meteorite;

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

    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $77DE90
    destructor Destroy; override; // @addr $77DF18
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $77DF40
    procedure DetachFromSpace; override; // @addr $77E040
    procedure SetPosition(APosition: TPointF); override; // @addr $77E080
    function IsNearView(Point: TPointF): Boolean; // @addr $77E0C4
    procedure PlaceRandomly; // @addr $77E164
    procedure RestartOutsideView; // @addr $77E1DC
    procedure AdvanceMotion(Timer: PSpaceTimerSE; UserData: Integer); // @addr $77E368
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $77E42C
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $77E550
  end;

implementation

uses Math, GlobalsV, GR_Main, GI_Main, EC_Str, aMyFunction, SE_Process;

{ @routine $77DE90 TMeteoriteSE_Create }
constructor TMeteoriteSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
end;
{ @end $77DE90 }

{ @routine $77DF18 TMeteoriteSE_Destroy }
destructor TMeteoriteSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $77DF18 }

{ @routine $77DF40 TMeteoriteSE_AttachToSpace }
procedure TMeteoriteSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Comet');
  ConfigureRandomSound('Comet');
  inherited AttachToSpace(ASpace);
  Animation := TgaiGI.Create(Space.MapPanel);
  Animation.SetImagePath(ImagePath);
  Animation.ObjectSize := Animation.GetContentSize;
  Animation.Sme := HalfPoint(Animation.ClientSize);
  Animation.SetDepthByName(DepthExpression);
  Animation.Pos := TruncatePointF(Position);
  Animation.World := True;
  Animation.SequenceIndex := 0;
  Animation.UpdateAutoGeometry;
  Animation.RestartPlayback;
  PlaceRandomly;
  MoveTimer := Space.CreateTimer(TimerInterval, TimerInterval, AdvanceMotion, 0);
end;
{ @end $77DF40 }

{ @routine $77E040 TMeteoriteSE_DetachFromSpace }
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
{ @end $77E040 }

{ @routine $77E080 TMeteoriteSE_SetPosition }
procedure TMeteoriteSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then Animation.Pos := TruncatePointF(APosition);
end;
{ @end $77E080 }

{ @routine $77E0C4 TMeteoriteSE_IsNearView }
function TMeteoriteSE.IsNearView(Point: TPointF): Boolean;
var Width, Height: Single;
begin
  Width := GameScreenWidth;
  Height := GameScreenHeight;
  Result := (SpaceViewPosition.X - Width < Point.X) and
    (SpaceViewPosition.X + Width > Point.X) and
    (SpaceViewPosition.Y - Height < Point.Y) and
    (SpaceViewPosition.Y + Height > Point.Y);
end;
{ @end $77E0C4 }

{ @routine $77E164 TMeteoriteSE_PlaceRandomly }
procedure TMeteoriteSE.PlaceRandomly;
var
  Radius: Single;
  Bound: Integer;
begin
  if Space = nil then Exit;
  Radius := TProcessSE(Space.Process).SystemRadius;
  Bound := Round(Radius);
  Pos := MakePointF(RandomIntRange(-Bound, Bound), RandomIntRange(-Bound, Bound));
end;
{ @end $77E164 }

{ @routine $77E1DC TMeteoriteSE_RestartOutsideView }
procedure TMeteoriteSE.RestartOutsideView;
var
  Radius: Single;
  Bound: Integer;
  StartPoint, EndPoint, Intersection: TPointF;
begin
  if Space = nil then Exit;
  Radius := TProcessSE(Space.Process).SystemRadius;
  while True do
  begin
    Bound := Round(Radius);
    EndPoint := MakePointF(RandomIntRange(-Bound, Bound), RandomIntRange(-Bound, Bound));
    StartPoint := MakePointF(EndPoint.X + Sin(Pi + Angle) * (Radius * 4),
      EndPoint.Y - Cos(Pi + Angle) * (Radius * 4));
    if not SegmentIntersectsRectEdges(StartPoint, EndPoint,
      MakePointF(-Radius * 1.2, -Radius * 1.2), MakePointF(1.2 * Radius, 1.2 * Radius), Intersection) then Continue;
    if IsNearView(Intersection) then Continue;
    Break;
  end;
  Pos := Intersection;
end;
{ @end $77E1DC }

{ @routine $77E368 TMeteoriteSE_AdvanceMotion }
procedure TMeteoriteSE.AdvanceMotion(Timer: PSpaceTimerSE; UserData: Integer);
var Limit: Single;
begin
  Pos := MakePointF(Position.X + Sin(Angle) * Speed, Position.Y - Cos(Angle) * Speed);
  Limit := TProcessSE(Space.Process).SystemRadius * 1.3;
  if ((-Limit > Position.X) or (Position.X > Limit) or (-Limit > Position.Y) or (Position.Y > Limit)) and
    not IsNearView(Position) then RestartOutsideView;
end;
{ @end $77E368 }

{ @routine $77E42C TMeteoriteSE_LoadTemplate }
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
{ @end $77E42C }

{ @routine $77E550 TMeteoriteSE_ApplyConfig }
procedure TMeteoriteSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $77E550 }

end.
