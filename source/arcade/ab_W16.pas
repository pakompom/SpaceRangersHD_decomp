unit ab_W16;
// Unit bracket (inferred): .text 0x004FA11C..0x004FA9FD; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW16 projectile family: $4FA184..$4FA9FE.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW16 = class(TabObject) // @size $C4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8  0 parent, 1 parent explosion, 2 child, 3 child explosion.
    ExpireTick: Integer; // @offset $BC
    ParentProjectile: TabW16; // @offset $C0
    constructor Create; // @addr $4FA184
    destructor Destroy; override; // @addr $4FA208
    procedure Launch(Owner: TabObject; Amount: Integer); // @addr $4FA2C0
    procedure LaunchChild(Parent: TabW16; Angle: Single); // @addr $4FA3C4
    procedure Advance; override; // @addr $4FA534
    procedure UpdateVisuals; override; // @addr $4FA9EC
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $4FA184 TabW16_Create }
constructor TabW16.Create;
begin
  inherited Create;
  MaxSpeed := 12;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 5;
  Collidable := False;
end;
{ @end $4FA184 }

{ @routine $4FA208 TabW16_Destroy }
destructor TabW16.Destroy;
var
  Obj: TabObject;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if (Obj is TabW16) and ((Obj as TabW16).ParentProjectile = Self) then
      (Obj as TabW16).ParentProjectile := nil;
    Obj := Obj.Next;
  end;
  inherited Destroy;
end;
{ @end $4FA208 }

{ @routine $4FA2C0 TabW16_Launch }
procedure TabW16.Launch(Owner: TabObject; Amount: Integer);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 120;
  ParentProjectile := nil;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w16_f', 'GAI,Bm.AB.w16_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4FA2C0 }

{ @routine $4FA3C4 TabW16_LaunchChild }
procedure TabW16.LaunchChild(Parent: TabW16; Angle: Single);
begin
  SourceObject := Parent.SourceObject;
  Damage := Parent.Damage div 5;
  State := Parent.State;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Angle);
  Velocity := MakePointF(0, 0);
  MaxSpeed := 10;
  Thrust := 2.5;
  Phase := 2;
  ExpireTick := ArcadeTickCount + 50;
  ParentProjectile := Parent;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w16b_f', 'GAI,Bm.AB.w16b_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4FA3C4 }

{ @routine $4FA534 TabW16_Advance }
procedure TabW16.Advance;
var
  Collision: TabObject;
  Child: TabW16;
begin
  inherited Advance;
  if (Phase <> 1) and (Phase <> 3) then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  if (Phase = 0) and (DistanceTravelled > 100) then MaxSpeed := 13;
  Collision := nil;
  if (Phase <> 1) and (Phase <> 3) then
  begin
    Collision := FindCollision;
    if (Collision = SourceObject) and (Phase = 0) and (DistanceTravelled < 200) then Collision := nil;
    if (Collision = SourceObject) and (Phase = 2) and (ParentProjectile <> nil) and
      (ParentProjectile.DistanceTravelled < 600) then Collision := nil;
    if Collision <> nil then
      if Collision is TabW16 then
        if ((Collision as TabW16).ParentProjectile = Self) or (ParentProjectile = Collision) or
          ((ParentProjectile <> nil) and ((Collision as TabW16).ParentProjectile = ParentProjectile)) then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and (Phase <> 1) and (Phase <> 3) then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    if Phase = 0 then
    begin
      Phase := 1;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w16a_f', 'GAI,Bm.AB.w16a_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end
    else
    begin
      Phase := 3;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w16c_f', 'GAI,Bm.AB.w16c_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end;
  end
  else if (Phase = 0) and (DistanceTravelled > 50) and (SourceObject <> nil) then
  begin
    Child := TabW16.Create;
    ab_Object_Add(Child);
    Child.LaunchChild(Self, Random(360));
  end
  else if (Phase = 2) and (ParentProjectile <> nil) then
  begin
    with BearingAndDistanceTo(ParentProjectile) do
      if Distance > 10 then
      begin
        State.BearingDegrees := State.BearingDegrees + BearingDeltaDegrees;
        MaxSpeed := ParentProjectile.MaxSpeed * 1.5;
      end
      else if Distance < 5 then State.BearingDegrees := Random(360)
      else MaxSpeed := MaxSpeed * 0.6;
  end
  else if (Phase = 1) or (Phase = 3) then DeletionPending := Image.Finished;
end;
{ @end $4FA534 }

{ @routine $4FA9EC TabW16_UpdateVisuals }
procedure TabW16.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $4FA9EC }

end.
