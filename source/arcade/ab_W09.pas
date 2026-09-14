unit ab_W09;
// Unit bracket (inferred): .text 0x0055E920..0x0055F0A5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW09 projectile family: $55E988..$55F0A6.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW09 = class(TabObject) // @size $C0
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8  0 parent, 1 parent explosion, 2 child, 3 child explosion.
    ExpireTick: Integer; // @offset $BC
    constructor Create; // @addr $55E988 @ida "TabW09 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $55EA0C @ida "void __usercall $name(TabW09 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer); // @addr $55EA64 @ida "void __usercall $name(TabW09 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>);"
    procedure LaunchChild(Parent: TabW09; Angle: Single); // @addr $55EB60 @ida "void __userpurge $name(TabW09 *Self@<eax>, TabW09 *Parent@<edx>, float Angle@<^0>);"
    procedure Advance; override; // @addr $55ECC4
    procedure UpdateVisuals; override; // @addr $55F094
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $55E988 TabW09_Create }
constructor TabW09.Create;
begin
  inherited Create;
  MaxSpeed := 12;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 5;
  Collidable := False;
end;
{ @end $55E988 }

{ @routine $55EA0C TabW09_Destroy }
destructor TabW09.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $55EA0C }

{ @routine $55EA64 TabW09_Launch }
procedure TabW09.Launch(Owner: TabObject; Amount: Integer);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 120;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w09_f', 'GAI,Bm.AB.w09_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $55EA64 }

{ @routine $55EB60 TabW09_LaunchChild }
procedure TabW09.LaunchChild(Parent: TabW09; Angle: Single);
begin
  SourceObject := Parent.SourceObject;
  Damage := Parent.Damage div 20;
  State := Parent.State;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Angle);
  Velocity := MakePointF(0, 0);
  MaxSpeed := 100;
  Thrust := 2.5;
  Phase := 2;
  ExpireTick := ArcadeTickCount + 20;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w09b_f', 'GAI,Bm.AB.w09b_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $55EB60 }

{ @routine $55ECC4 TabW09_Advance }
procedure TabW09.Advance;
var
  Index: Integer;
  Collision: TabObject;
  Enemy: TabShip;
  Child: TabW09;
begin
  inherited Advance;
  if (Phase <> 1) and (Phase <> 3) then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  if (Phase = 0) and (DistanceTravelled > 100) then MaxSpeed := 13;
  if (Phase = 0) and (DistanceTravelled > 300) then MaxSpeed := 8;
  Collision := nil;
  if (Phase <> 1) and (Phase <> 3) then
  begin
    Collision := FindCollision;
    if (DistanceTravelled < 200) and (Phase = 0) and (Collision = SourceObject) then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and (Phase <> 1) and (Phase <> 3) then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    if Phase = 0 then
    begin
      Phase := 1;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w09a_f', 'GAI,Bm.AB.w09a_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end
    else
    begin
      Phase := 3;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w09c_f', 'GAI,Bm.AB.w09c_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end;
  end
  else if (Phase = 0) and (ArcadeTickCount mod 3 = 0) and (SourceObject <> nil) then
  begin
    for Index := 0 to TabShip(SourceObject).Enemies.Count - 1 do
    begin
      Enemy := TabShip(SourceObject).Enemies[Index];
      with BearingAndDistanceTo(Enemy) do
        if (Distance < 400) and (Enemy.Health > 0) then
        begin
          Child := TabW09.Create;
          ab_Object_Add(Child);
          Child.LaunchChild(Self, BearingDeltaDegrees);
        end;
    end;
  end
  else if (Phase = 1) or (Phase = 3) then DeletionPending := Image.Finished;
end;
{ @end $55ECC4 }

{ @routine $55F094 TabW09_UpdateVisuals }
procedure TabW09.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $55F094 }

end.
