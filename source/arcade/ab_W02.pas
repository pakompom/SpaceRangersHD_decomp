unit ab_W02;
// Unit bracket (inferred): .text 0x004F432C..0x004F48F1; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW02 projectile family: $4F4394..$4F48F2.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW02 = class(TabObject) // @size $C4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8  0 launch, 1 armed, 2 explosion.
    ExpireTick: Integer; // @offset $BC
    ArmTick: Integer; // @offset $C0
    constructor Create; // @addr $4F4394
    destructor Destroy; override; // @addr $4F4418
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $4F4470
    procedure Advance; override; // @addr $4F45CC
    procedure UpdateVisuals; override; // @addr $4F48E0
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $4F4394 TabW02_Create }
constructor TabW02.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 1;
  Collidable := False;
end;
{ @end $4F4394 }

{ @routine $4F4418 TabW02_Destroy }
destructor TabW02.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $4F4418 }

{ @routine $4F4470 TabW02_Launch }
procedure TabW02.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 100;
  ArmTick := ArcadeTickCount + 25;
  if Offset <> 0 then State := AdvanceSphericalStateOnCurrentSphere(State, Offset);
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w02_f', 'GAI,Bm.AB.w02_s', False);
  ab_WorldImage_SetFrameMode(Image, afmRandomStart);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4F4470 }

{ @routine $4F45CC TabW02_Advance }
procedure TabW02.Advance;
var
  Collision: TabObject;
  Enemy: TabShip;
  Bearing: TSphericalBearingDistance;
begin
  inherited Advance;
  if Phase <> 2 then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  Collision := nil;
  if Phase <> 2 then
  begin
    Collision := FindCollision;
    if (Phase = 0) and (Collision = SourceObject) then Collision := nil;
  end;
  if (Collision <> nil) and (Phase <> 2) then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    Phase := 2;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w02a_f', 'GAI,Bm.AB.w02a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if (Phase = 0) and (ArcadeTickCount > ArmTick) then
  begin
    Phase := 1;
    Velocity := MakePointF(0, 0);
    Thrust := 0;
  end
  else if (Phase = 1) and (ArcadeTickCount > ExpireTick) then
  begin
    Phase := 2;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w02a_f', 'GAI,Bm.AB.w02a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if (Phase = 1) and (SourceObject <> nil) then
  begin
    Enemy := (SourceObject as TabShip).FindNearestEnemyWithBearing(Self, Bearing);
    if (Enemy <> nil) and (Bearing.Distance < 300) then
    begin
      State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Bearing.BearingDeltaDegrees);
      Thrust := 2;
      MaxSpeed := 2;
    end
    else
    begin
      Velocity := MakePointF(0, 0);
      Thrust := 0;
    end;
  end
  else if Phase = 2 then DeletionPending := Image.Finished;
end;
{ @end $4F45CC }

{ @routine $4F48E0 TabW02_UpdateVisuals }
procedure TabW02.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $4F48E0 }

end.
