unit ab_W04;
// Unit bracket (inferred): .text 0x004F4DE4..0x004F55CD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW04 projectile family: $4F4E4C..$4F55CE.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW04 = class(TabObject) // @size $C8
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8  0 parent, 1 parent explosion, 2 child coasting, 3 child tracking, 4 child explosion.
    ExpireTick: Integer; // @offset $BC
    AimTick: Integer; // @offset $C0
    constructor Create; // @addr $4F4E4C
    destructor Destroy; override; // @addr $4F4ED0
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $4F4F28
    procedure LaunchChild(Parent: TabW04; Angle: Single); // @addr $4F5074
    procedure Advance; override; // @addr $4F51EC
    procedure UpdateVisuals; override; // @addr $4F55BC
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $4F4E4C TabW04_Create }
constructor TabW04.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 1;
  Collidable := False;
end;
{ @end $4F4E4C }

{ @routine $4F4ED0 TabW04_Destroy }
destructor TabW04.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $4F4ED0 }

{ @routine $4F4F28 TabW04_Launch }
procedure TabW04.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 25;
  if Offset <> 0 then State := AdvanceSphericalStateOnCurrentSphere(State, Offset);
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w04_f', 'GAI,Bm.AB.w04_s', False);
  ab_WorldImage_SetFrameMode(Image, afmRandomStart);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4F4F28 }

{ @routine $4F5074 TabW04_LaunchChild }
procedure TabW04.LaunchChild(Parent: TabW04; Angle: Single);
begin
  SourceObject := Parent.SourceObject;
  Damage := Parent.Damage div 3;
  State := Parent.State;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Angle);
  Velocity := MakePointF(0, 0);
  ExpireTick := ArcadeTickCount + 30;
  AimTick := ArcadeTickCount + 8;
  Thrust := 1;
  Phase := 2;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w04b_f', 'GAI,Bm.AB.w04b_s', False);
  ab_WorldImage_SetFrameMode(Image, afmRandomStart);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4F5074 }

{ @routine $4F51EC TabW04_Advance }
procedure TabW04.Advance;
var
  Collision: TabObject;
  Enemy: TabShip;
  Child: TabW04;
  Bearing: TSphericalBearingDistance;
begin
  inherited Advance;
  if (Phase <> 1) and (Phase <> 4) then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  Collision := nil;
  if (Phase <> 1) and (Phase <> 4) then
  begin
    Collision := FindCollision;
    if (Phase = 0) and (Collision = SourceObject) then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and (Phase <> 1) and (Phase <> 4) then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False)
    else if Phase = 0 then
    begin
      Child := TabW04.Create;
      ab_Object_Add(Child);
      Child.LaunchChild(Self, 35);
      Child := TabW04.Create;
      ab_Object_Add(Child);
      Child.LaunchChild(Self, 155);
      Child := TabW04.Create;
      ab_Object_Add(Child);
      Child.LaunchChild(Self, 275);
    end;
    if Phase = 0 then
    begin
      Phase := 1;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w04a_f', 'GAI,Bm.AB.w04a_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end
    else
    begin
      Phase := 4;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w04c_f', 'GAI,Bm.AB.w04c_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end;
  end
  else if (Phase = 2) and (ArcadeTickCount > AimTick) then
  begin
    if SourceObject <> nil then Enemy := (SourceObject as TabShip).FindNearestEnemyWithBearing(Self, Bearing)
    else Enemy := nil;
    if (Enemy <> nil) and (Bearing.Distance < 500) then
    begin
      Velocity := MakePointF(0, 0);
      State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Bearing.BearingDeltaDegrees);
      Thrust := 3;
    end;
    Phase := 3;
  end
  else if (Phase = 1) or (Phase = 4) then DeletionPending := Image.Finished;
end;
{ @end $4F51EC }

{ @routine $4F55BC TabW04_UpdateVisuals }
procedure TabW04.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $4F55BC }

end.
