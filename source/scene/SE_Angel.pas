unit SE_Angel;

interface

uses Classes, Types, EC_BlockPar, EC_Struct, GI_GAI, GI_MessageLoop, SE_Space;

type
  PAngelEntry = ^TAngelEntry;
  TAngelEntry = record // @size $30
    Next: PAngelEntry; // @offset $00
    Prev: PAngelEntry; // @offset $04
    Position: TPointF; // @offset $08
    Target: TPointF; // @offset $10
    Velocity: TPointF; // @offset $18
    Animation: TgaiGI; // @offset $20
    Angle: Single; // @offset $24
    FrameIndex: Integer; // @offset $28
    MovingUp: Boolean; // @offset $2C
    FrameVariant: Byte; // @offset $2D
  end;

  TAngelSE = class(TObjectSE) // @size $BC
  public
    TimerInterval: Integer; // @offset $4C
    MoveTimer: PSpaceTimerSE; // @offset $50
    ImagePath: WideString; // @offset $54 Native managed slot consumed by QueueImageLoad; LoadTemplate does not assign it.
    ImageCount: Integer; // @offset $58
    ImagePaths: array[0..7] of WideString; // @offset $5C
    FirstEntry: PAngelEntry; // @offset $7C
    FrameIndex: Integer; // @offset $80
    SizeRange: TPoint; // @offset $84
    TurnTicks: Integer; // @offset $8C
    Velocity: TPointF; // @offset $90
    GroupSize: TPointF; // @offset $98
    MoveAngle: Single; // @offset $A0
    Speed: Single; // @offset $A4
    EntryCount: Integer; // @offset $A8
    Target: TPointF; // @offset $AC
    TargetDelay: Integer; // @offset $B4
    MoveState: Byte; // @offset $B8 0=wander, 1=seek target, 2=turn before seeking.

    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $77E638
    procedure DetachFromSpace; override; // @addr $77E6B0
    procedure SetPosition(APosition: TPointF); override; // @addr $77E6E4
    procedure SetVelocityFromAngle(Angle: Single); // @addr $77E750
    procedure StartMotionTimer; // @addr $77E79C
    procedure StopMotionTimer; // @addr $77E7C4
    function GetFrameCount(Entry: PAngelEntry): Integer; // @addr $77E7E0
    procedure ToggleFrameVariants; // @addr $77E800
    procedure AdvanceMotionTimer(Timer: PSpaceTimerSE; UserData: Integer); // @addr $77E824
    procedure AppendEntry; // @addr $77E830
    procedure RemoveEntry(Entry: PAngelEntry); // @addr $77E9BC
    procedure AdvanceEntry(Entry: PAngelEntry); // @addr $77EA00
    procedure Wander; // @addr $77EBE8
    procedure SeekTarget; // @addr $77ED90
    procedure UpdateHeading; // @addr $77EFDC
    procedure AdvanceSteps(Count: Integer); // @addr $77F044
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $77F0F0
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $77F4A8
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $77F4B0
  end;

implementation

uses Math, EC_Str, GI_Main, GI_RotateImage5, aMyFunction, SE_Ship2;

{ @routine $77E638 TAngelSE_AttachToSpace }
procedure TAngelSE.AttachToSpace(ASpace: TSpaceSE);
var Index: Integer;
begin
  if IsAttachedToSpace then Exit;
  ConfigureLoopSound('Angel');
  ConfigureRandomSound('Angel');
  inherited AttachToSpace(ASpace);
  FirstEntry := nil;
  for Index := 1 to EntryCount do AppendEntry;
  MoveState := 0;
  TargetDelay := 500;
  StartMotionTimer;
end;
{ @end $77E638 }

{ @routine $77E6B0 TAngelSE_DetachFromSpace }
procedure TAngelSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  StopMotionTimer;
  while FirstEntry <> nil do RemoveEntry(FirstEntry);
  inherited DetachFromSpace;
end;
{ @end $77E6B0 }

{ @routine $77E6E4 TAngelSE_SetPosition }
procedure TAngelSE.SetPosition(APosition: TPointF);
var Entry: PAngelEntry;
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
  begin
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      if Entry.Animation <> nil then
        Entry.Animation.Pos := TruncatePointF(RotateAndTranslatePoint(Entry.Position, APosition, MoveAngle));
      Entry := Entry.Next;
    end;
  end;
end;
{ @end $77E6E4 }

{ @routine $77E750 TAngelSE_SetVelocityFromAngle }
procedure TAngelSE.SetVelocityFromAngle(Angle: Single);
begin
  Velocity.X := Sin(Angle) * Speed;
  Velocity.Y := Cos(Angle) * Speed;
  AdvanceSteps(0);
end;
{ @end $77E750 }

{ @routine $77E79C TAngelSE_StartMotionTimer }
procedure TAngelSE.StartMotionTimer;
begin
  StopMotionTimer;
  MoveTimer := Space.CreateTimer(TimerInterval, TimerInterval, AdvanceMotionTimer, 0);
end;
{ @end $77E79C }

{ @routine $77E7C4 TAngelSE_StopMotionTimer }
procedure TAngelSE.StopMotionTimer;
begin
  if MoveTimer <> nil then
  begin
    Space.DeleteTimer(MoveTimer);
    MoveTimer := nil;
  end;
end;
{ @end $77E7C4 }

{ @routine $77E7E0 TAngelSE_GetFrameCount }
function TAngelSE.GetFrameCount(Entry: PAngelEntry): Integer;
var Animation: TgaiGI;
begin
  Result := 0;
  if Entry = nil then Entry := FirstEntry;
  if Entry <> nil then
  begin
    Animation := Entry.Animation;
    if Animation <> nil then Result := Animation.GetMainImageFrameCount;
  end;
end;
{ @end $77E7E0 }

{ @routine $77E800 TAngelSE_ToggleFrameVariants }
procedure TAngelSE.ToggleFrameVariants;
var Entry: PAngelEntry;
begin
  Entry := FirstEntry;
  while Entry <> nil do
  begin
    if Entry.Animation <> nil then
      if Entry.FrameVariant = 0 then Entry.FrameVariant := 1
      else Dec(Entry.FrameVariant);
    Entry := Entry.Next;
  end;
end;
{ @end $77E800 }

{ @routine $77E824 TAngelSE_AdvanceMotionTimer }
procedure TAngelSE.AdvanceMotionTimer(Timer: PSpaceTimerSE; UserData: Integer);
begin
  AdvanceSteps(1);
end;
{ @end $77E824 }

{ @routine $77E830 TAngelSE_AppendEntry }
procedure TAngelSE.AppendEntry;
var Entry: PAngelEntry;
begin
  New(Entry);
  Entry.Next := FirstEntry;
  Entry.Prev := nil;
  if FirstEntry <> nil then FirstEntry.Prev := Entry;
  FirstEntry := Entry;
  Entry.Position := MakePointF(RandomFloatRange(-GroupSize.X, GroupSize.X), RandomFloatRange(-GroupSize.Y, GroupSize.Y));
  Entry.Velocity := MakePointF(0, 0);
  Entry.Target := Entry.Position;
  Entry.Angle := 0;
  Entry.Animation := TgaiGI.Create(Space.MapPanel);
  Entry.Animation.SetImagePath(ImagePaths[Random(ImageCount)]);
  Entry.Animation.SequenceIndex := 0;
  Entry.Animation.UpdateAutoGeometry;
  Entry.Animation.ObjectSize := Entry.Animation.GetContentSize;
  Entry.Animation.Sme := HalfPoint(Entry.Animation.ClientSize);
  Entry.Animation.SetDepthByName(DepthExpression);
  Entry.Animation.Pos := Classes.Point(Trunc(Entry.Position.X + Position.X), Trunc(Entry.Position.Y + Position.Y));
  Entry.Animation.World := True;
  Entry.Animation.SetSequenceFrame(0);
  Entry.Animation.RestartPlayback;
  Entry.FrameIndex := 0;
  Entry.MovingUp := False;
  Entry.FrameVariant := 0;
end;
{ @end $77E830 }

{ @routine $77E9BC TAngelSE_RemoveEntry }
procedure TAngelSE.RemoveEntry(Entry: PAngelEntry);
begin
  if Entry <> nil then
  begin
    if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
    if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
    if Entry = FirstEntry then FirstEntry := Entry.Next;
    if Entry.Animation <> nil then Entry.Animation.Free;
    Dispose(Entry);
  end;
end;
{ @end $77E9BC }

{ @routine $77EA00 TAngelSE_AdvanceEntry }
procedure TAngelSE.AdvanceEntry(Entry: PAngelEntry);
var Movement: TPointF;
begin
  if (Abs(Entry.Position.X - Entry.Target.X) <= Abs(Entry.Velocity.X) + 0.2) and
    (Abs(Entry.Position.Y - Entry.Target.Y) <= Abs(Entry.Velocity.Y) + 0.2) then
  begin
    Movement := MakePointF(RandomFloatRange(-GroupSize.X, GroupSize.X), RandomFloatRange(-GroupSize.Y, GroupSize.Y));
    Entry.Target := Movement;
    Entry.Velocity := MakePointF((-Entry.Position.X + Entry.Target.X) / 64, (-Entry.Position.Y + Entry.Target.Y) / 64);
  end
  else Entry.Position := MakePointF(Entry.Position.X + Entry.Velocity.X, Entry.Position.Y + Entry.Velocity.Y);
  Movement := RotateAndTranslatePoint(Entry.Velocity, Velocity, MoveAngle);
  if Entry.Velocity.Y < -0.5 then Entry.MovingUp := True
  else Entry.MovingUp := False;
  if Abs(Movement.X) < 0.1 then Entry.Angle := ArcTan2(Movement.Y, 0.1)
  else Entry.Angle := ArcTan2(Movement.Y, Movement.X);
end;
{ @end $77EA00 }

{ @routine $77EBE8 TAngelSE_Wander }
procedure TAngelSE.Wander;
var
  Obj: TObjectSE;
  Count: Cardinal;
  Index: Integer;
begin
  if Abs(TurnTicks) = 0 then
  begin
    if Random(100) < 10 then TurnTicks := RandomIntRange(-128, 128);
  end
  else if TurnTicks < 0 then
  begin
    Inc(TurnTicks);
    MoveAngle := MoveAngle + 0.01;
    if MoveAngle > Pi then MoveAngle := MoveAngle - 2 * Pi;
  end
  else
  begin
    Dec(TurnTicks);
    MoveAngle := MoveAngle - 0.01;
    if MoveAngle < -Pi then MoveAngle := MoveAngle + 2 * Pi;
  end;
  if TargetDelay > 0 then Dec(TargetDelay);
  if (TargetDelay = 0) and (MoveState = 0) then
    if Space <> nil then
    begin
      Obj := Space.FirstObject;
      Count := 0;
      while Obj <> nil do
      begin
        if Obj is TShip2SE then Inc(Count);
        Obj := Obj.Next;
      end;
      Index := Random(Count);
      Obj := Space.FirstObject;
      while Obj <> nil do
      begin
        if Obj is TShip2SE then
        begin
          if Index = 0 then
          begin
            Target := Obj.Position;
            MoveState := 1;
            Break;
          end;
          Dec(Index);
        end;
        Obj := Obj.Next;
      end;
    end;
  if TurnTicks = 0 then
    if MoveState = 2 then MoveState := 1;
end;
{ @end $77EBE8 }

{ @routine $77ED90 TAngelSE_SeekTarget }
procedure TAngelSE.SeekTarget;
var
  Delta: TPointF;
  Angle: Single;
begin
  Delta := MakePointF(Target.X - Position.X, Target.Y - Position.Y);
  if Abs(Delta.X) < 0.2 then Angle := ArcTan2(Delta.Y, 0.2)
  else Angle := ArcTan2(Delta.Y, Delta.X);
  if Abs(Angle - MoveAngle) < Pi then
  begin
    if Angle - 0.01 > MoveAngle then MoveAngle := MoveAngle + 0.02
    else if Angle + 0.01 < MoveAngle then MoveAngle := MoveAngle - 0.02;
  end
  else
  begin
    if MoveAngle < Angle then MoveAngle := MoveAngle - 0.02
    else MoveAngle := MoveAngle + 0.02;
    if MoveAngle > Pi then MoveAngle := MoveAngle - 2 * Pi;
    if MoveAngle < -Pi then MoveAngle := MoveAngle + 2 * Pi;
  end;
  if (Abs(Position.X - Target.X) < 64) and (Abs(Position.Y - Target.Y) < 64) then
  begin
    MoveState := 0;
    TargetDelay := 500 + Random(500);
  end
  else if Random(1000) < 10 then
  begin
    TurnTicks := RandomIntRange(-128, 128);
    MoveState := 2;
  end;
end;
{ @end $77ED90 }

{ @routine $77EFDC TAngelSE_UpdateHeading }
procedure TAngelSE.UpdateHeading;
begin
  case MoveState of
    0: Wander;
    2: Wander;
    1: SeekTarget;
  else Wander;
  end;
  Velocity := PointFromRadiusAngle(Speed, MoveAngle);
end;
{ @end $77EFDC }

{ @routine $77F044 TAngelSE_AdvanceSteps }
procedure TAngelSE.AdvanceSteps(Count: Integer);
var Entry: PAngelEntry;
begin
  while Count > 0 do
  begin
    Inc(FrameIndex);
    if FrameIndex >= GetFrameCount(nil) then FrameIndex := 0;
    UpdateHeading;
    Entry := FirstEntry;
    while Entry <> nil do
    begin
      AdvanceEntry(Entry);
      Entry := Entry.Next;
    end;
    ToggleFrameVariants;
    Position := MakePointF(Position.X + Velocity.X, Position.Y + Velocity.Y);
    if FirstEntry <> nil then Pos := Position;
    Dec(Count);
  end;
end;
{ @end $77F044 }

{ @routine $77F0F0 TAngelSE_LoadTemplate }
procedure TAngelSE.LoadTemplate(Block: TBlockParEC);
var
  IntRange: TPoint;
  Range: TPointF;
begin
  inherited LoadTemplate(Block);
  SizeRange := Classes.Point(32, 64);
  GroupSize := MakePointF(32, 64);
  MoveAngle := 0;
  FrameIndex := 0;
  EntryCount := 4;
  TimerInterval := ExtractDigitsToIntW(Block.GetParam('Time'));
  if Block.CountParams('Size') > 0 then SizeRange := GetPointGI(Block.GetParam('Size'));
  if Block.CountParams('Speed') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('Speed'));
    Speed := RandomFloatRange(Range.X, Range.Y);
  end;
  if Block.CountParams('MoveAngle') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('MoveAngle'));
    MoveAngle := RandomFloatRange(Range.X, Range.Y);
  end;
  if Block.CountParams('WorldPos') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('WorldPos'));
    Position := MakePointF(RandomFloatRange(Range.X, Range.Y), RandomFloatRange(Range.X, Range.Y));
  end;
  if Block.CountParams('GroupSize') > 0 then GroupSize := GetFloatPointGI(Block.GetParam('GroupSize'));
  if Block.CountParams('AngelCount') > 0 then
  begin
    IntRange := GetPointGI(Block.GetParam('AngelCount'));
    EntryCount := RandomIntRange(IntRange.X, IntRange.Y);
  end;
  ImageCount := 0;
  while Block.CountParams('Image' + IntToWideString(ImageCount)) > 0 do
  begin
    ImagePaths[ImageCount] := Block.GetParam('Image' + IntToWideString(ImageCount));
    Inc(ImageCount);
    if ImageCount = 8 then Break;
  end;
  SetVelocityFromAngle(MoveAngle);
end;
{ @end $77F0F0 }

{ @routine $77F4A8 TAngelSE_ApplyConfig }
procedure TAngelSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $77F4A8 }

{ @routine $77F4B0 TAngelSE_QueueImageLoad }
procedure TAngelSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var Control: TRotateImage5GI;
begin
  Control := TRotateImage5GI.Create(Owner);
  Control.QueueImagePath(PendingLoads, ImagePath);
  Control.Free;
end;
{ @end $77F4B0 }

end.
