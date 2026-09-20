unit ab_W06;
// Unit bracket (inferred): .text 0x004F5DA0..0x004F62CD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW06 projectile family: $4F5E08..$4F62CE.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW06 = class(TabObject) // @size $C4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    ExpireTick: Integer; // @offset $BC
    TurnSpeed: Single; // @offset $C0
    constructor Create; // @addr $4F5E08
    destructor Destroy; override; // @addr $4F5E9C
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $4F5EF4
    procedure Advance; override; // @addr $4F607C
    procedure UpdateVisuals; override; // @addr $4F62BC
  end;


implementation

uses ab_Ship, GlobalsV;

{ @routine $4F5E08 TabW06_Create }
constructor TabW06.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 1.2;
  CollisionRadius := 1;
  Collidable := False;
  TurnSpeed := 10;
end;
{ @end $4F5E08 }

{ @routine $4F5E9C TabW06_Destroy }
destructor TabW06.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $4F5E9C }

{ @routine $4F5EF4 TabW06_Launch }
procedure TabW06.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
var
  Heading, HeadingDelta: Double;
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 20;
  if Offset <> 0 then
  begin
    Heading := WrapHeadingDegrees(State.BearingDegrees + 90);
    HeadingDelta := HeadingDifferenceDegrees(Heading, State.BearingDegrees);
    AdvanceSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, Heading, SphereRadius, Offset);
    State.BearingDegrees := WrapHeadingDegrees(Heading + HeadingDelta);
  end;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w06_f', 'GAI,Bm.AB.w06_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4F5EF4 }

{ @routine $4F607C TabW06_Advance }
procedure TabW06.Advance;
var
  Collision: TabObject;
  Enemy: TabShip;
  Bearing: TSphericalBearingDistance;
begin
  inherited Advance;
  if not Exploding then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  Collision := nil;
  if not Exploding then
  begin
    Collision := FindCollision;
    if Collision = SourceObject then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and not Exploding then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w06a_f', 'GAI,Bm.AB.w06a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if not Exploding and (Collision = nil) then
  begin
    if SourceObject <> nil then
    begin
      Enemy := SourceObject as TabShip;
      Enemy := Enemy.FindNearestEnemyWithBearing(Self, Bearing);
      if Enemy <> nil then
        if Bearing.Distance < 400 then
        begin
          if Bearing.BearingDeltaDegrees < -TurnSpeed then Bearing.BearingDeltaDegrees := -TurnSpeed
          else if Bearing.BearingDeltaDegrees > TurnSpeed then Bearing.BearingDeltaDegrees := TurnSpeed;
          State.BearingDegrees := State.BearingDegrees + Bearing.BearingDeltaDegrees;
        end;
    end;
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $4F607C }

{ @routine $4F62BC TabW06_UpdateVisuals }
procedure TabW06.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $4F62BC }

end.
