unit ab_W02;
// Unit bracket (inferred): .text 0x00561868..0x00561E2D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW02 projectile family: $5618D0..$561E2E.

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
    constructor Create; // @addr $5618D0 @ida "TabW02 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $561954 @ida "void __usercall $name(TabW02 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $5619AC @ida "void __userpurge $name(TabW02 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Offset@<^0>);"
    procedure Advance; override; // @addr $561B08
    procedure UpdateVisuals; override; // @addr $561E1C
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $5618D0 TabW02_Create }
constructor TabW02.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 1;
  Collidable := False;
end;
{ @end $5618D0 }

{ @routine $561954 TabW02_Destroy }
destructor TabW02.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $561954 }

{ @routine $5619AC TabW02_Launch }
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
{ @end $5619AC }

{ @routine $561B08 TabW02_Advance }
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
{ @end $561B08 }

{ @routine $561E1C TabW02_UpdateVisuals }
procedure TabW02.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $561E1C }

end.
