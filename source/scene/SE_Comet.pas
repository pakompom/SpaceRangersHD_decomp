unit SE_Comet;
// Unit bracket (inferred): .text 0x007CAB54..0x007CC32D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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

    constructor Create(GraphKey: WideString; UnusedPosition: TPoint); // @addr $7CAC40 @ida "TCometSE *__userpurge $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>, unsigned __int16 *GraphKey@<ecx>, TPoint *UnusedPosition@<^0>);"
    destructor Destroy; override; // @addr $7CAD00 @ida "void __usercall $name(TCometSE *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $7CAD34
    procedure DetachFromSpace; override; // @addr $7CAEF4
    procedure SetPosition(APosition: TPointF); override; // @addr $7CAFBC @ida "void __usercall $name(TCometSE *Self@<eax>, TPointF *APosition@<edx>);"
    procedure ResetTrajectory(Angle: Single); // @addr $7CB014 @ida "void __userpurge $name(TCometSE *Self@<eax>, float Angle@<^0>);"
    procedure StartMotionTimer; // @addr $7CB1F8
    procedure StopMotionTimer; // @addr $7CB234
    procedure AdvanceMotionTimer(Timer: PSpaceTimerSE; UserData: Integer); // @addr $7CB260
    procedure ApplyAttraction(Center: TPointF; Strength: Single); // @addr $7CB280 @ida "void __userpurge $name(TCometSE *Self@<eax>, TPointF *Center@<edx>, float Strength@<^0>);"
    procedure ExplosionFinished(Sender: TObjectGI); // @addr $7CB4E4
    procedure RemoveTrailEntry(Entry: PCometTrailEntry); // @addr $7CB580
    procedure ExplodeAndRespawn; // @addr $7CB604
    procedure AdvanceSteps(Count: Integer); // @addr $7CB974
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $7CBE88
    procedure ApplyConfig(Block: TBlockParEC); override; // @addr $7CC2CC
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $7CC2E8
  end;

implementation

uses SysUtils, Math, GlobalsV, GR_Main, GI_Main, EC_Str, aMyFunction, Globals, GR_Sound, SE_Planet;

{ @routine $7CAC40 TCometSE_Create }
constructor TCometSE.Create(GraphKey: WideString; UnusedPosition: TPoint);
begin
  inherited Create(GraphKey, UnusedPosition);
  Animation := nil;
  CompletedExplosion := nil;
  CurrentExplosion := nil;
  FirstTrailEntry := nil;
  TrailHistoryCount := 0;
end;
{ @end $7CAC40 }

{ @routine $7CAD00 TCometSE_Destroy }
destructor TCometSE.Destroy;
begin
  inherited Destroy;
end;
{ @end $7CAD00 }

{ @routine $7CAD34 TCometSE_AttachToSpace }
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
{ @end $7CAD34 }

{ @routine $7CAEF4 TCometSE_DetachFromSpace }
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
{ @end $7CAEF4 }

{ @routine $7CAFBC TCometSE_SetPosition }
procedure TCometSE.SetPosition(APosition: TPointF);
begin
  inherited SetPosition(APosition);
  if IsAttachedToSpace then
    if Animation <> nil then Animation.SetPosition(TruncatePointF(APosition));
end;
{ @end $7CAFBC }

{ @routine $7CB014 TCometSE_ResetTrajectory }
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
{ @end $7CB014 }

{ @routine $7CB1F8 TCometSE_StartMotionTimer }
procedure TCometSE.StartMotionTimer;
begin
  StopMotionTimer;
  MoveTimer := Space.CreateTimer(TimerInterval, TimerInterval, AdvanceMotionTimer, 0);
end;
{ @end $7CB1F8 }

{ @routine $7CB234 TCometSE_StopMotionTimer }
procedure TCometSE.StopMotionTimer;
begin
  if MoveTimer <> nil then
  begin
    Space.DeleteTimer(MoveTimer);
    MoveTimer := nil;
  end;
end;
{ @end $7CB234 }

{ @routine $7CB260 TCometSE_AdvanceMotionTimer }
procedure TCometSE.AdvanceMotionTimer(Timer: PSpaceTimerSE; UserData: Integer);
begin
  AdvanceSteps(1);
end;
{ @end $7CB260 }

{ @routine $7CB280 TCometSE_ApplyAttraction }
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
{ @end $7CB280 }

{ @routine $7CB4E4 TCometSE_ExplosionFinished }
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
{ @end $7CB4E4 }

{ @routine $7CB580 TCometSE_RemoveTrailEntry }
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
{ @end $7CB580 }

{ @routine $7CB604 TCometSE_ExplodeAndRespawn }
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
{ @end $7CB604 }

{ @routine $7CB974 TCometSE_AdvanceSteps }
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
{ @end $7CB974 }

{ @routine $7CBE88 TCometSE_LoadTemplate }
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
{ @end $7CBE88 }

{ @routine $7CC2CC TCometSE_ApplyConfig }
procedure TCometSE.ApplyConfig(Block: TBlockParEC);
begin
  inherited ApplyConfig(Block);
end;
{ @end $7CC2CC }

{ @routine $7CC2E8 TCometSE_QueueImageLoad }
procedure TCometSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var Control: TgaiGI;
begin
  Control := TgaiGI.Create(Owner);
  Control.SetImagePath(ImagePath);
  Control.QueueImageLoad(PendingLoads);
  Control.Free;
end;
{ @end $7CC2E8 }

end.
