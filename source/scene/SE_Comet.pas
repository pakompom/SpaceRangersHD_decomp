unit SE_Comet;
// Unit bracket (inferred): .text 0x00824E18..0x008265F1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, Types, EC_BlockPar, EC_Struct, GI_GAI, GI_MessageLoop, SE_Space;

type
  PCometTrailEntry = ^TCometTrailEntry;
  TCometTrailEntry = record // @size $20
    Next: PCometTrailEntry; // @offset $00
    Prev: PCometTrailEntry; // @offset $04
    Position: TPointF; // @offset $08
    Velocity: TPointF; // @offset $10
    Animation: TgaiGI; // @offset $18
    Finished: Boolean; // @offset $1C
  end;

  TCometSE = class(TObjectSE) // @size $120
  public
    TimerInterval: Integer; // @offset $4C
    MoveTimer: PSpaceTimerSE; // @offset $50
    ImagePath: WideString; // @offset $54
    ReservedImageText: WideString; // @offset $58 Native managed-field table includes this slot; no access found in the retained comet routines.
    ExplosionPath: WideString; // @offset $5C
    ExplosionFrames: WideString; // @offset $60
    TrailPath: WideString; // @offset $64
    TrailFrames: WideString; // @offset $68
    FirstTrailEntry: PCometTrailEntry; // @offset $6C
    SavedFrameIndex: Integer; // @offset $74
    TrailHistoryCount: Integer; // @offset $F0
    Animation: TgaiGI; // @offset $F4
    CompletedExplosion: TgaiGI; // @offset $F8
    CurrentExplosion: TgaiGI; // @offset $FC
    SkipMoves: Integer; // @offset $100
    Velocity: TPointF; // @offset $104
    MoveAngle: Single; // @offset $10C
    Radius: Single; // @offset $110
    Speed: Single; // @offset $114
    StarAttraction: Single; // @offset $118
    ObjectAttraction: Single; // @offset $11C

    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $824F04
    destructor Destroy; override; // @addr $824FC4
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $824FF8
    procedure DetachFromSpace; override; // @addr $8251B8
    procedure SetPosition(APosition: TPointF); override; // @addr $825280
    procedure ResetTrajectory(Angle: Single); // @addr $8252D8
    procedure StartMotionTimer; // @addr $8254BC
    procedure StopMotionTimer; // @addr $8254F8
    procedure AdvanceMotionTimer(Timer: PSpaceTimerSE; UserData: Integer); // @addr $825524
    procedure ApplyAttraction(Center: TPointF; Strength: Single); // @addr $825544
    procedure ExplosionFinished(Sender: TObjectGI); // @addr $8257A8
    procedure RemoveTrailEntry(Entry: PCometTrailEntry); // @addr $825844
    procedure ExplodeAndRespawn; // @addr $8258C8
    procedure AdvanceSteps(Count: Integer); // @addr $825C38
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $82614C
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $826590
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $8265AC
  end;

implementation

uses SysUtils, Math, GlobalsV, GR_Main, GI_Main, EC_Str, aMyFunction, Globals, GR_Sound, SE_Planet;

{ @routine $824F04 TCometSE_Create }
constructor TCometSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  Animation := nil;
  CompletedExplosion := nil;
  CurrentExplosion := nil;
  FirstTrailEntry := nil;
  TrailHistoryCount := 0;
end;
{ @end $824F04 }

{ @routine $824FC4 TCometSE_Destroy }
destructor TCometSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $824FC4 }

{ @routine $824FF8 TCometSE_AttachToSpace }
procedure TCometSE.AttachToSpace(ASpace: TSpaceSE);
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
  if (SavedFrameIndex < 0) or (SavedFrameIndex >= Animation.SequenceFrameCount) then
    SavedFrameIndex := RandomIntRange(0, Animation.SequenceFrameCount - 1);
  Animation.SetSequenceFrame(SavedFrameIndex);
  Animation.RestartPlayback;
  TrailHistoryCount := 0;
  while FirstTrailEntry <> nil do RemoveTrailEntry(FirstTrailEntry);
  StartMotionTimer;
end;
{ @end $824FF8 }

{ @routine $8251B8 TCometSE_DetachFromSpace }
procedure TCometSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  StopMotionTimer;
  while FirstTrailEntry <> nil do RemoveTrailEntry(FirstTrailEntry);
  if Animation <> nil then
  begin
    SavedFrameIndex := Animation.SequenceFrame;
    Animation.Free;
    Animation := nil;
  end;
  if CompletedExplosion <> nil then
  begin
    CompletedExplosion.Free;
    CompletedExplosion := nil;
  end;
  if CurrentExplosion <> nil then
  begin
    CurrentExplosion.Free;
    CurrentExplosion := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $8251B8 }

{ @routine $825280 TCometSE_SetPosition }
procedure TCometSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
    if Animation <> nil then Animation.SetPosition(TruncatePointF(APosition));
end;
{ @end $825280 }

{ @routine $8252D8 TCometSE_ResetTrajectory }
procedure TCometSE.ResetTrajectory(Angle: Single);
begin
  if SkipMoves >= 0 then
  begin
    if Random(50) < 25 then
    begin
      Velocity.X := Sin(Angle) * Speed;
      Velocity.Y := Cos(Angle) * -Speed;
    end
    else
    begin
      Velocity.X := Sin(Angle) * -Speed;
      Velocity.Y := Cos(Angle) * Speed;
    end;
    Position.X := RandomIntRange(-4096, 4096);
    Position.Y := RandomIntRange(-4096, 4096);
    SkipMoves := -1;
    while (SpaceViewPosition.X - (Cardinal(GameScreenWidth) shr 1) < Position.X) and
      (SpaceViewPosition.X + (Cardinal(GameScreenWidth) shr 1) > Position.X) and
      (SpaceViewPosition.Y - (Cardinal(GameScreenHeight) shr 1) < Position.Y) and
      (SpaceViewPosition.Y + (Cardinal(GameScreenHeight) shr 1) > Position.Y) do
    begin
      Position.X := RandomIntRange(-4096, 4096);
      Position.Y := RandomIntRange(-4096, 4096);
    end;
  end;
end;
{ @end $8252D8 }

{ @routine $8254BC TCometSE_StartMotionTimer }
procedure TCometSE.StartMotionTimer;
begin
  StopMotionTimer;
  MoveTimer := Space.CreateTimer(TimerInterval, TimerInterval, AdvanceMotionTimer, 0);
end;
{ @end $8254BC }

{ @routine $8254F8 TCometSE_StopMotionTimer }
procedure TCometSE.StopMotionTimer;
begin
  if MoveTimer <> nil then
  begin
    Space.DeleteTimer(MoveTimer);
    MoveTimer := nil;
  end;
end;
{ @end $8254F8 }

{ @routine $825524 TCometSE_AdvanceMotionTimer }
procedure TCometSE.AdvanceMotionTimer(Timer: PSpaceTimerSE; UserData: Integer);
begin
  AdvanceSteps(1);
end;
{ @end $825524 }

{ @routine $825544 TCometSE_ApplyAttraction }
procedure TCometSE.ApplyAttraction(Center: TPointF; Strength: Single);
var
  Angle: Double;
  Force: Single;
  Delta: TPointF;
begin
  Delta := MakePointF(Position.X - Center.X, Position.Y - Center.Y);
  if Abs(Delta.X) < 1 then Angle := ArcTan2(Delta.Y, 1)
  else Angle := ArcTan2(Delta.Y, Delta.X);
  if Abs(Delta.X) + Abs(Delta.Y) < 64 then Force := 0
  else Force := Strength / (Delta.X * Delta.X + Delta.Y * Delta.Y);
  Velocity := OffsetPointByRadiusAngle(Velocity, -Force, Angle);
  if Abs(Velocity.X) > Abs(Velocity.Y) then
  begin
    if Velocity.X > 7 then
    begin
      Velocity.Y := Velocity.Y * 7 / Velocity.X;
      Velocity.X := 7;
    end;
    if Velocity.X < -7 then
    begin
      Velocity.Y := Velocity.Y * 7 / -Velocity.X;
      Velocity.X := -7;
    end;
  end
  else
  begin
    if Velocity.Y > 7 then
    begin
      Velocity.X := Velocity.X * 7 / Velocity.Y;
      Velocity.Y := 7;
    end;
    if Velocity.Y < -7 then
    begin
      Velocity.X := Velocity.X * 7 / -Velocity.Y;
      Velocity.Y := -7;
    end;
  end;
end;
{ @end $825544 }

{ @routine $8257A8 TCometSE_ExplosionFinished }
procedure TCometSE.ExplosionFinished(Sender: TObjectGI);
begin
  if Sender <> nil then
    if Sender is TgaiGI then
    begin
      if CompletedExplosion <> nil then
      begin
        CompletedExplosion.Free;
        CompletedExplosion := nil;
      end;
      if Sender = CurrentExplosion then
      begin
        CompletedExplosion := CurrentExplosion;
        CompletedExplosion.SetSequenceFrame(CompletedExplosion.SequenceFrameCount - 2);
        CurrentExplosion := nil;
      end;
    end;
end;
{ @end $8257A8 }

{ @routine $825844 TCometSE_RemoveTrailEntry }
procedure TCometSE.RemoveTrailEntry(Entry: PCometTrailEntry);
begin
  if Entry <> nil then
  begin
    if Entry.Prev <> nil then Entry.Prev.Next := Entry.Next;
    if Entry.Next <> nil then Entry.Next.Prev := Entry.Prev;
    if Entry = FirstTrailEntry then FirstTrailEntry := Entry.Next;
    if Entry.Animation <> nil then Entry.Animation.Free;
    Entry.Animation := nil;
    Dispose(Entry);
  end;
end;
{ @end $825844 }

{ @routine $8258C8 TCometSE_ExplodeAndRespawn }
procedure TCometSE.ExplodeAndRespawn;
var Control: TgaiGI;
begin
  if Space <> nil then
  begin
    if FilmSoundEffectsEnabled and SoundInSpaceEnabled and Space.ContainsMapPoint(Position) then
      SoundManager.PlaySound(WideString('Sound.expl' + IntToStr(RandomIntRange(3, 5))));
    Control := TgaiGI.Create(Space.MapPanel);
    Control.SetImagePath(ExplosionPath);
    Control.LoadFrameSequenceFromText(ExplosionFrames);
    Control.SetSequenceFrame(0);
    Control.SetSize(Control.GetContentSize);
    Control.SetOrigin(HalfPoint(Control.ClientSize));
    Control.SetDepthByName(DepthExpression);
    Control.SetDepth(Control.Depth - 1);
    Control.SetPosition(TruncatePointF(Position));
    Control.SetPositionModeW(True);
    Control.CycleCompleteCallback := ExplosionFinished;
    Control.RestartPlayback;
    if CurrentExplosion <> nil then CurrentExplosion.Free;
    CurrentExplosion := Control;
    repeat
      case Random(4) of
        0: begin Position.X := -4096; Position.Y := RandomIntRange(-4096, 4096); end;
        1: begin Position.X := 4096; Position.Y := RandomIntRange(-4096, 4096); end;
        2: begin Position.Y := 4096; Position.X := RandomIntRange(-4096, 4096); end;
        3: begin Position.Y := -4096; Position.X := RandomIntRange(-4096, 4096); end;
      end;
    until (SpaceViewPosition.X - (Cardinal(GameScreenWidth) shr 1) > Position.X) or
      (SpaceViewPosition.X + (Cardinal(GameScreenWidth) shr 1) < Position.X) or
      (SpaceViewPosition.Y - (Cardinal(GameScreenHeight) shr 1) > Position.Y) or
      (SpaceViewPosition.Y + (Cardinal(GameScreenHeight) shr 1) < Position.Y);
    Velocity.X := Velocity.X * 0.5;
    Velocity.Y := Velocity.Y * 0.5;
  end;
end;
{ @end $8258C8 }

{ @routine $825C38 TCometSE_AdvanceSteps }
procedure TCometSE.AdvanceSteps(Count: Integer);
var
  NextEntry, Entry: PCometTrailEntry;
  Circle: PPlanetCollisionCircle;
begin
  while Count > 0 do
  begin
    if CompletedExplosion <> nil then
    begin
      CompletedExplosion.Free;
      CompletedExplosion := nil;
    end;
    NextEntry := FirstTrailEntry;
    while NextEntry <> nil do
    begin
      Entry := NextEntry;
      NextEntry := NextEntry.Next;
      if Entry.Finished then RemoveTrailEntry(Entry)
      else
      begin
        Entry.Position := MakePointF(Entry.Position.X + Entry.Velocity.X, Entry.Position.Y + Entry.Velocity.Y);
        if CurrentExplosion <> nil then Entry.Velocity := HalfPointF(Entry.Velocity);
        if Entry.Animation <> nil then Entry.Animation.SetPosition(TruncatePointF(Entry.Position));
      end;
    end;
    ApplyAttraction(MakePointF(0, 0), StarAttraction);
    if (Abs(Position.X) < 200) and (Abs(Position.Y) < 200) and
      (Position.X * Position.X + Position.Y * Position.Y < 40000) then ExplodeAndRespawn;
    Circle := FirstPlanetCollisionCircle;
    while Circle <> nil do
    begin
      ApplyAttraction(MakePointF(Circle.Position.X, Circle.Position.Y), ObjectAttraction);
      if (Abs(Circle.Position.X - Position.X) < Circle.Radius) and
        (Abs(Circle.Position.Y - Position.Y) < Circle.Radius) and
        ((Circle.Position.X - Position.X) * (Circle.Position.X - Position.X) +
         (Circle.Position.Y - Position.Y) * (Circle.Position.Y - Position.Y) < Circle.RadiusSquared) then
      begin
        ExplodeAndRespawn;
        Break;
      end;
      Circle := Circle.Next;
    end;
    Position := MakePointF(Position.X + Velocity.X, Position.Y + Velocity.Y);
    if (SpaceViewPosition.X - (Cardinal(GameScreenWidth) shr 1) > Position.X) or
      (SpaceViewPosition.Y - (Cardinal(GameScreenHeight) shr 1) > Position.Y) or
      (SpaceViewPosition.X + (Cardinal(GameScreenWidth) shr 1) < Position.X) or
      (SpaceViewPosition.Y + (Cardinal(GameScreenHeight) shr 1) < Position.Y) then
    begin
      if (Position.X > 4096) and (Velocity.X >= 0) then Position.X := -4096;
      if (Position.X < -4096) and (Velocity.X <= 0) then Position.X := 4096;
      if (Position.Y > 4096) and (Velocity.Y >= 0) then Position.Y := -4096;
      if (Position.Y < -4096) and (Velocity.Y <= 0) then Position.Y := 4096;
      while (SpaceViewPosition.X - (Cardinal(GameScreenWidth) shr 1) < Position.X) and
        (SpaceViewPosition.X + (Cardinal(GameScreenWidth) shr 1) > Position.X) and
        (SpaceViewPosition.Y - (Cardinal(GameScreenHeight) shr 1) < Position.Y) and
        (SpaceViewPosition.Y + (Cardinal(GameScreenHeight) shr 1) > Position.Y) do
      begin
        Position.X := RandomIntRange(-4096, 4096);
        Position.Y := RandomIntRange(-4096, 4096);
      end;
    end;
    if Animation <> nil then SetPosition(Position);
    Dec(Count);
  end;
end;
{ @end $825C38 }

{ @routine $82614C TCometSE_LoadTemplate }
procedure TCometSE.LoadTemplate(Block: TBlockParEC);
var
  IntRange: TPoint;
  Range: TPointF;
begin
  inherited LoadTemplate(Block);
  SkipMoves := 0;
  SavedFrameIndex := -1;
  TimerInterval := StrToInt(AnsiString(Block.GetParam('Time')));
  StarAttraction := 20000;
  ObjectAttraction := 4000;
  if Block.CountParams('Radius') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('Radius'));
    Radius := RandomFloatRange(Range.X, Range.Y);
  end;
  if Block.CountParams('Speed') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('Speed'));
    Speed := RandomFloatRange(Range.X, Range.Y);
  end;
  if Block.CountParams('StarFallStrength') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('StarFallStrength'));
    StarAttraction := RandomFloatRange(Range.X, Range.Y);
  end;
  if Block.CountParams('PlanetFallStrength') > 0 then
  begin
    Range := GetFloatPointGI(Block.GetParam('PlanetFallStrength'));
    ObjectAttraction := RandomFloatRange(Range.X, Range.Y);
  end;
  if Block.CountParams('SkipMoves') > 0 then
  begin
    IntRange := GetPointGI(Block.GetParam('SkipMoves'));
    SkipMoves := RandomIntRange(IntRange.X, IntRange.Y);
  end;
  if Block.CountParams('MoveAngle') > 0 then
  begin
    IntRange := GetPointGI(Block.GetParam('MoveAngle'));
    MoveAngle := RandomIntRange(IntRange.X, IntRange.Y) * Pi / 180;
  end;
  ExplosionPath := Block.GetParam('Explore');
  ExplosionFrames := Block.GetParam('ExploreFrame');
  TrailPath := Block.GetParam('Track');
  TrailFrames := Block.GetParam('TrackFrame');
  ResetTrajectory(MoveAngle);
end;
{ @end $82614C }

{ @routine $826590 TCometSE_ApplyConfig }
procedure TCometSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $826590 }

{ @routine $8265AC TCometSE_QueueImageLoad }
procedure TCometSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var Control: TgaiGI;
begin
  Control := TgaiGI.Create(Owner);
  Control.SetImagePath(ImagePath);
  Control.QueueImageLoad(PendingLoads);
  Control.Free;
end;
{ @end $8265AC }

end.
