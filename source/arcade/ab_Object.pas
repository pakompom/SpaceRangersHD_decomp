unit ab_Object;
// Unit bracket (inferred): .text 0x0054E2C0..0x0054F667; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabObject VMT and methods: $54E30C..$54F668.

interface

uses Classes, EC_Struct, GI_MessageLoop, GI_Tail, ab_Global, GR_Sound;

type
  TabObject = class(TObjectEx) // @size $B0
  public
    Prev: TabObject; // @offset $04
    Next: TabObject; // @offset $08
    State: TSphericalBearingState; // @offset $10
    Mass: Double; // @offset $28
    Thrust: Double; // @offset $30
    Velocity: TPointF; // @offset $38
    MaxSpeed: Double; // @offset $40
    SpeedScale: Double; // @offset $48
    DistanceTravelled: Double; // @offset $50
    CollisionRadius: Double; // @offset $58
    Collidable: Boolean; // @offset $60
    ZoneRadius: Double; // @offset $68
    DeletionPending: Boolean; // @offset $70
    WallCollisionEnabled: Boolean; // @offset $71
    GravityEnabled: Boolean; // @offset $72
    ZoneDamageEnabled: Boolean; // @offset $73
    Active: Boolean; // @offset $74
    // Non-owning original firing object: Launch stores Owner ($4F3C98), child
    // projectiles inherit it, and hits pass it as damage source ($4F3E48).
    // Used to exclude self-collisions and select enemies; cleared on destruction.
    SourceObject: TabObject; // @offset $78
    InitialRandomSeed: Cardinal; // @offset $7C
    RandomState: Cardinal; // @offset $80
    SoundDelay: Integer; // @offset $84
    SoundPath: WideString; // @offset $88
    SoundGroup: Integer; // @offset $8C
    Sound: TSoundBufferControl; // @offset $90
    WeaponDamageScale: Single; // @offset $94
    AmmoRechargeScale: Single; // @offset $98
    MovementScale: Single; // @offset $9C
    GravityScale: Single; // @offset $A0
    RegenerationRate: Single; // @offset $A4
    DamageTakenScale: Single; // @offset $A8
    LuckScale: Single; // @offset $AC  Default 1; SF_ABShipModifiers exposes luck at $61F7FE. Multiplies the random reward roll.

    constructor Create; // @addr $54E33C
    destructor Destroy; override; // @addr $54E458
    function GetWorldPosition: TVector3D; // @addr $54E4E0
    function GetProjectedPosition: TVector3D; // @addr $54E52C
    function DistanceTo(Other: TabObject): Double; // @addr $54E56C
    function BearingAndDistanceTo(Other: TabObject): TSphericalBearingDistance; // @addr $54E6CC
    function GetProjectedHeading(Position: TVector3D): Double; // @addr $54E6F4
    procedure ChangeSpeed(Delta: Double); // @addr $54E804
    function CollidesWith(Other: TabObject): Boolean; // @addr $54E8E0
    function FindCollision: TabObject; // @addr $54E98C
    procedure ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean); virtual; // @addr $54E9F0 @slot $00
    procedure UpdateState; virtual; // @addr $54EA08 @slot $04
    procedure Advance; virtual; // @addr $54EA14 @slot $08
    procedure UpdateVisuals; virtual; // @addr $54F258 @slot $0C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); virtual; // @addr $54F264 @slot $10
    function RandomRange(BoundA, BoundB: Integer): Integer; // @addr $54F278
  end;

procedure ab_Object_Clear; // @addr $54F31C
procedure ab_Object_Add(Obj: TabObject); // @addr $54F334
procedure ab_Object_Delete(Obj: TabObject); // @addr $54F380
procedure ab_Object_QueueImageLoads(PendingLoads: TList; Owner: TObjectGI); // @addr $54F3EC
procedure ab_Object_UpdateSounds; // @addr $54F42C

var
  FirstArcadeObject: TabObject = nil; // @addr $87AEE4
  LastArcadeObject: TabObject = nil; // @addr $87AEE8

implementation

uses Math, aMyFunction, Globals, GlobalsV, ab_Hit, ab_Ship, ab_ShipAI, ab_Zone, ab_StopLine;

{ @routine $54E33C TabObject_Create }
constructor TabObject.Create;
begin
  inherited Create;
  MaxSpeed := 5;
  SpeedScale := 1;
  DistanceTravelled := 0;
  WallCollisionEnabled := False;
  GravityEnabled := False;
  ZoneDamageEnabled := False;
  Active := True;
  Collidable := True;
  SoundDelay := -1;
  InitialRandomSeed := AdvanceRandomSeed(ArcadeBattleScreen.RandomSeed);
  RandomState := InitialRandomSeed;
  WeaponDamageScale := 1;
  AmmoRechargeScale := 1;
  MovementScale := 1;
  GravityScale := 1;
  RegenerationRate := 0;
  DamageTakenScale := 1;
  LuckScale := 1;
end;
{ @end $54E33C }

{ @routine $54E458 TabObject_Destroy }
destructor TabObject.Destroy;
var
  Obj: TabObject;
begin
  if Sound <> nil then
  begin
    Sound.Free;
    Sound := nil;
  end;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj.SourceObject = Self then Obj.SourceObject := nil;
    Obj := Obj.Next;
  end;
  inherited Destroy;
end;
{ @end $54E458 }

{ @routine $54E4E0 TabObject_GetWorldPosition }
function TabObject.GetWorldPosition: TVector3D;
begin
  Result := SphericalToVector3D(HeadingDegreesToRadians(State.LongitudeDegrees), HeadingDegreesToRadians(State.PolarAngleDegrees), SphereRadius);
end;
{ @end $54E4E0 }

{ @routine $54E52C TabObject_GetProjectedPosition }
function TabObject.GetProjectedPosition: TVector3D;
begin
  Result := GetWorldPosition;
  Result := ProjectPointByMatrix(SphereProjectionMatrix, Result);
end;
{ @end $54E52C }

{ @routine $54E56C TabObject_DistanceTo }
function TabObject.DistanceTo(Other: TabObject): Double;
var
  ArcAngle, TargetPolar, SourcePolar, LongitudeDelta, Value: Double;
begin
  TargetPolar := HeadingDegreesToRadians(Other.State.PolarAngleDegrees);
  SourcePolar := HeadingDegreesToRadians(State.PolarAngleDegrees);
  LongitudeDelta := HeadingDegreesToRadians(WrapHeadingDegrees(Other.State.LongitudeDegrees - State.LongitudeDegrees));
  Value := Cos(TargetPolar) * Cos(SourcePolar) + Sin(TargetPolar) * Sin(SourcePolar) * Cos(LongitudeDelta);
  if Value < -1 then Value := -1
  else if Value > 1 then Value := 1;
  ArcAngle := ArcCos(Value);
  Result := ArcAngle / (2 * Pi) * 2 * Pi * SphereRadius;
end;
{ @end $54E56C }

{ @routine $54E6CC TabObject_BearingAndDistanceTo }
function TabObject.BearingAndDistanceTo(Other: TabObject): TSphericalBearingDistance;
begin
  Result := GetSphericalBearingAndDistance(State, Other.State);
end;
{ @end $54E6CC }

{ @routine $54E6F4 TabObject_GetProjectedHeading }
function TabObject.GetProjectedHeading(Position: TVector3D): Double;
var
  ForwardState: TSphericalBearingState;
  ForwardPosition: TVector3D;
begin
  ForwardState := State;
  ForwardState := AdvanceSphericalStateOnCurrentSphere(ForwardState, 10);
  ForwardPosition := SphericalToVector3D(HeadingDegreesToRadians(ForwardState.LongitudeDegrees), HeadingDegreesToRadians(ForwardState.PolarAngleDegrees), SphereRadius);
  ForwardPosition := ProjectPointByMatrix(SphereProjectionMatrix, ForwardPosition);
  if (Position.X = ForwardPosition.X) and (Position.Y = ForwardPosition.Y) then
  begin
    Result := 0;
    Exit;
  end;
  Result := PointBearingDegrees(MakePointF(Position.X, Position.Y), MakePointF(ForwardPosition.X, ForwardPosition.Y));
end;
{ @end $54E6F4 }

{ @routine $54E804 TabObject_ChangeSpeed }
procedure TabObject.ChangeSpeed(Delta: Double);
var
  Speed, Angle: Double;
begin
  Speed := Sqrt(Sqr(Velocity.X) + Sqr(Velocity.Y));
  if Speed = 0 then Exit;
  Angle := Math.ArcTan2(Velocity.X, -Velocity.Y);
  Speed := Max(0, Speed + Delta);
  Velocity.X := Sin(Angle) * Speed;
  Velocity.Y := -Cos(Angle) * Speed;
end;
{ @end $54E804 }

{ @routine $54E8E0 TabObject_CollidesWith }
function TabObject.CollidesWith(Other: TabObject): Boolean;
begin
  if (CollisionRadius <= 0) or (Other.CollisionRadius <= 0) then
  begin
    Result := False;
    Exit;
  end;
  if (not Collidable) and (not Other.Collidable) then
  begin
    Result := False;
    Exit;
  end;
  if (Other is TabHit) and ((Other as TabHit).Health <= 0) then
  begin
    Result := False;
    Exit;
  end;
  Result := CollisionRadius + Other.CollisionRadius >= DistanceTo(Other);
end;
{ @end $54E8E0 }

{ @routine $54E98C TabObject_FindCollision }
function TabObject.FindCollision: TabObject;
var
  Obj: TabObject;
begin
  if (ArcadeTickCount and 1) <> 0 then
  begin
    Result := nil;
    Exit;
  end;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if (Obj <> Self) and CollidesWith(Obj) then
    begin
      Result := Obj;
      Exit;
    end;
    Obj := Obj.Next;
  end;
  Result := nil;
end;
{ @end $54E98C }

{ @routine $54E9F0 TabObject_ApplyDamage }
procedure TabObject.ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean);
begin
end;
{ @end $54E9F0 }

{ @routine $54EA08 TabObject_UpdateState }
procedure TabObject.UpdateState;
begin
end;
{ @end $54EA08 }

{ @routine $54EA14 TabObject_Advance }
procedure TabObject.Advance;
var
  Force: TPointF;
  TravelBearing, ArcDistance, HeadingDelta, ReflectedSpeed: Double;
  Factor, Limit: Single;
  Zone: PabZone;
  Bearing, Distance, UnusedResult: Double;
begin
  Force := MakePointF(0, 0);
  if Thrust <> 0 then
  begin
    Force.X := Force.X + Sin(HeadingDegreesToRadians(State.BearingDegrees)) * Thrust * MovementScale;
    Force.Y := Force.Y - Cos(HeadingDegreesToRadians(State.BearingDegrees)) * Thrust * MovementScale;
  end;
  if GravityEnabled then
  begin
    Zone := ab_Zone_FindNearestEnabled(State.LongitudeDegrees, State.PolarAngleDegrees);
    if Zone <> nil then
    begin
      ComputeSphericalBearingAndDistance(Bearing, Distance, State.LongitudeDegrees, State.PolarAngleDegrees, 0, Zone.Longitude, Zone.PolarAngle, SphereRadius);
      Limit := 2;
      if PlayerArcadeShip = Self then
        if Sqr(Velocity.X) + Sqr(Velocity.Y) > Sqr(2.0) then Limit := 8;
      if Zone.GravityStrength < 0 then
        Factor := -Min(Limit / 2, Abs(Zone.GravityStrength) * Mass / (Sqr(Distance) + 0.1))
      else
        Factor := Min(Limit, Abs(Zone.GravityStrength) * Mass / (Sqr(Distance) + 0.1));
      Bearing := HeadingDegreesToRadians(WrapHeadingDegrees(Bearing));
      Force.X := Force.X + Sin(Bearing) * Factor * GravityScale;
      Force.Y := Force.Y - Cos(Bearing) * Factor * GravityScale;
    end;
  end;
  if ZoneDamageEnabled and ((Self as TabHit).Health > 0) then
  begin
    Zone := FirstZone;
    while Zone <> nil do
    begin
      if Zone.DamagePerTick <> 0 then
      begin
        ComputeSphericalBearingAndDistance(Bearing, Distance, Zone.Longitude, Zone.PolarAngle, 0, State.LongitudeDegrees, State.PolarAngleDegrees, SphereRadius);
        if Zone.Radius + ZoneRadius + 5 > Distance then
        begin
          if Zone.DamagePerTick < 0 then
          begin
            (Self as TabHit).Health := Min((Self as TabHit).MaxHealth, (Self as TabHit).Health + -Zone.DamagePerTick);
          end
          else
          begin
            ApplyDamage(Zone.DamagePerTick, nil, False);
            if Self is TabShipAI then (Self as TabShipAI).NoticeDamagingZone(Zone);
          end;
        end;
      end;
      Zone := Zone.Next;
    end;
  end;
  Factor := 1 / Mass;
  Velocity.X := Velocity.X + Force.X * Factor;
  Velocity.Y := Velocity.Y + Force.Y * Factor;
  ArcDistance := Sqrt(Sqr(Velocity.X) + Sqr(Velocity.Y));
  if MaxSpeed * SpeedScale < ArcDistance then ArcDistance := MaxSpeed * SpeedScale;
  ArcDistance := Max(0, ArcDistance - RemapClamped(ArcDistance, 0, MaxSpeed, SphereLowSpeedDrag, SphereHighSpeedDrag));
  TravelBearing := PointBearingDegrees(MakePointF(0, 0), Velocity);
  if PlayerArcadeShip = Self then
  begin
    PlayerArcadeShip.TurnSpeed := RemapClamped(ArcDistance, 0, MaxSpeed, PlayerSlowTurnSpeed, PlayerFastTurnSpeed);
    Limit := PlayerDriftTurnStep;
    Factor := HeadingDifferenceDegrees(TravelBearing, State.BearingDegrees);
    if Abs(Factor) < 90 then
    begin
      if -Limit > Factor then TravelBearing := WrapHeadingDegrees(TravelBearing - Limit)
      else if Factor > Limit then TravelBearing := WrapHeadingDegrees(TravelBearing + Limit);
    end
    else
    begin
      Factor := HeadingDifferenceDegrees(TravelBearing, WrapHeadingDegrees(State.BearingDegrees + 180));
      if -Limit > Factor then TravelBearing := WrapHeadingDegrees(TravelBearing - Limit)
      else if Factor > Limit then TravelBearing := WrapHeadingDegrees(TravelBearing + Limit);
    end;
  end;
  if ArcDistance <> 0 then
  begin
    if WallCollisionEnabled then
    begin
      if ab_StopLine_ReflectMovement(State, AdvanceSphericalStateAlongBearing(State, TravelBearing, ArcDistance), HeadingDelta, ReflectedSpeed, UnusedResult) then
      begin
        ArcDistance := ReflectedSpeed;
        TravelBearing := WrapHeadingDegrees(TravelBearing + HeadingDelta);
      end;
      State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + UnusedResult);
    end;
    if ArcDistance > 0 then
    begin
      State := AdvanceSphericalStateAndTravelBearing(State, TravelBearing, ArcDistance);
      DistanceTravelled := DistanceTravelled + ArcDistance;
      Velocity.X := Sin(HeadingDegreesToRadians(TravelBearing)) * ArcDistance;
      Velocity.Y := -Cos(HeadingDegreesToRadians(TravelBearing)) * ArcDistance;
    end
    else
    begin
      Velocity.X := 0;
      Velocity.Y := 0;
    end;
  end
  else
  begin
    Velocity.X := 0;
    Velocity.Y := 0;
  end;
end;
{ @end $54EA14 }

{ @routine $54F258 TabObject_UpdateVisuals }
procedure TabObject.UpdateVisuals;
begin
end;
{ @end $54F258 }

{ @routine $54F264 TabObject_QueueImageLoad }
procedure TabObject.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
end;
{ @end $54F264 }

{ @routine $54F278 TabObject_RandomRange }
function TabObject.RandomRange(BoundA, BoundB: Integer): Integer;
begin
  RandomState := 16807 * (RandomState mod 127773) - 2836 * (RandomState div 127773);
  Result := Integer(RandomState) - 1;
  if Result < 0 then Result := -Result;
  if BoundA <= BoundB then Result := BoundA + Result mod (BoundB - BoundA + 1)
  else Result := BoundB + Result mod (BoundA - BoundB + 1);
end;
{ @end $54F278 }

{ @routine $54F31C ab_Object_Clear }
procedure ab_Object_Clear;
begin
  while not (FirstArcadeObject = nil) do ab_Object_Delete(LastArcadeObject);
end;
{ @end $54F31C }

{ @routine $54F334 ab_Object_Add }
procedure ab_Object_Add(Obj: TabObject);
begin
  if LastArcadeObject <> nil then LastArcadeObject.Next := Obj;
  Obj.Prev := LastArcadeObject;
  Obj.Next := nil;
  LastArcadeObject := Obj;
  if FirstArcadeObject = nil then FirstArcadeObject := Obj;
end;
{ @end $54F334 }

{ @routine $54F380 ab_Object_Delete }
procedure ab_Object_Delete(Obj: TabObject);
begin
  if Obj.Prev <> nil then Obj.Prev.Next := Obj.Next;
  if Obj.Next <> nil then Obj.Next.Prev := Obj.Prev;
  if LastArcadeObject = Obj then LastArcadeObject := Obj.Prev;
  if FirstArcadeObject = Obj then FirstArcadeObject := Obj.Next;
  Obj.Free;
end;
{ @end $54F380 }

{ @routine $54F3EC ab_Object_QueueImageLoads }
procedure ab_Object_QueueImageLoads(PendingLoads: TList; Owner: TObjectGI);
var
  Obj: TabObject;
begin
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    Obj.QueueImageLoad(PendingLoads, Owner);
    Obj := Obj.Next;
  end;
end;
{ @end $54F3EC }

{ @routine $54F42C ab_Object_UpdateSounds }
procedure ab_Object_UpdateSounds;
var
  Obj: TabObject;
  Index: Integer;
  Playing, Closest: TabObject;
  BestDistance, Distance, Volume: Single;
  Counts: array[0..14] of Integer;
  Position: TVector3D;
begin
  for Index := 0 to 14 do Counts[Index] := 0;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj.SoundDelay > 0 then Dec(Obj.SoundDelay);
    if (Obj.SoundDelay = 0) and (Obj.SoundGroup >= 9000) and (Obj.SoundGroup <= 9014) then
      Inc(Counts[Obj.SoundGroup - 9000]);
    Obj := Obj.Next;
  end;
  for Index := 0 to 14 do
    if Counts[Index] > 0 then
    begin
      Closest := nil;
      Playing := nil;
      BestDistance := 1e20;
      Obj := FirstArcadeObject;
      while Obj <> nil do
      begin
        if (Obj.SoundDelay = 0) and (Index + 9000 = Obj.SoundGroup) then
        begin
          if Obj.Sound <> nil then Playing := Obj;
          Position := Obj.GetProjectedPosition;
          if IsDepthBeforeSphereHorizon(Position.Z) then
          begin
            Distance := Sqr(Position.X) + Sqr(Position.Y);
            if Distance < BestDistance then
            begin
              BestDistance := Distance;
              Closest := Obj;
            end;
          end;
        end;
        Obj := Obj.Next;
      end;
      if (Playing <> nil) and (Closest <> Playing) then
      begin
        Playing.Sound.Free;
        Playing.Sound := nil;
      end;
      if Closest <> nil then
      begin
        if Closest.Sound = nil then
        begin
          Closest.Sound := TSoundBufferControl.Create;
          Closest.Sound.Configure(Closest.SoundPath, Closest.SoundGroup, True);
        end;
        Volume := (Sqrt(BestDistance) - 100) * (1 / 300);
        if Volume < 0 then Volume := 0
        else if Volume > 1 then Volume := 1;
        Closest.Sound.SetVolume(1 - Volume);
      end;
    end;
end;
{ @end $54F42C }

end.
