unit ab_W09;
// Unit bracket (inferred): .text 0x004F70B4..0x004F7839; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW09 projectile family: $4F711C..$4F783A.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW09 = class(TabObject) // @size $C0
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8  0 parent, 1 parent explosion, 2 child, 3 child explosion.
    ExpireTick: Integer; // @offset $BC
    constructor Create; // @addr $4F711C
    destructor Destroy; override; // @addr $4F71A0
    procedure Launch(Owner: TabObject; Amount: Integer); // @addr $4F71F8
    procedure LaunchChild(Parent: TabW09; Angle: Single); // @addr $4F72F4
    procedure Advance; override; // @addr $4F7458
    procedure UpdateVisuals; override; // @addr $4F7828
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $4F711C TabW09_Create }
constructor TabW09.Create;
begin
  inherited Create;
  MaxSpeed := 12;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 5;
  Collidable := False;
end;
{ @end $4F711C }

{ @routine $4F71A0 TabW09_Destroy }
destructor TabW09.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $4F71A0 }

{ @routine $4F71F8 TabW09_Launch }
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
{ @end $4F71F8 }

{ @routine $4F72F4 TabW09_LaunchChild }
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
{ @end $4F72F4 }

{ @routine $4F7458 TabW09_Advance }
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
{ @end $4F7458 }

{ @routine $4F7828 TabW09_UpdateVisuals }
procedure TabW09.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $4F7828 }

end.
