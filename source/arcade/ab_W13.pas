unit ab_W13;
// Unit bracket (inferred): .text 0x0055CC00..0x0055D235; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW13 projectile family: $55CC68..$55D236.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW13 = class(TabObject) // @size $C4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    Generation: Integer; // @offset $BC
    ExpireTick: Integer; // @offset $C0
    constructor Create; // @addr $55CC68 @ida "TabW13 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $55CCF0 @ida "void __usercall $name(TabW13 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Angle: Single; AGeneration: Integer; Origin: TabObject); // @addr $55CD48 @ida "void __userpurge $name(TabW13 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Angle@<^8>, int AGeneration@<^4>, TabObject *Origin@<^0>);"
    procedure Advance; override; // @addr $55CF6C
    procedure UpdateVisuals; override; // @addr $55D224
  end;


implementation

uses GlobalsV, aMyFunction;

{ @routine $55CC68 TabW13_Create }
constructor TabW13.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 0.8;
  CollisionRadius := 5;
  Collidable := False;
end;
{ @end $55CC68 }

{ @routine $55CCF0 TabW13_Destroy }
destructor TabW13.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $55CCF0 }

{ @routine $55CD48 TabW13_Launch }
procedure TabW13.Launch(Owner: TabObject; Amount: Integer; Angle: Single; AGeneration: Integer; Origin: TabObject);
begin
  SourceObject := Owner;
  Damage := Amount;
  if Origin <> nil then State := Origin.State
  else State := Owner.State;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Angle);
  if Owner <> nil then Velocity := Owner.Velocity
  else Velocity := Origin.Velocity;
  Generation := AGeneration;
  if Generation = 0 then ExpireTick := ArcadeTickCount + 25
  else ExpireTick := ArcadeTickCount + 10;
  { Native W13 shares W08 projectile and explosion resources. }
  if Generation = 0 then
  begin
    Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w08_f', 'GAI,Bm.AB.w08_s', False);
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
  end
  else
  begin
    Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w08b_f', 'GAI,Bm.AB.w08b_s', False);
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
  end;
end;
{ @end $55CD48 }

{ @routine $55CF6C TabW13_Advance }
procedure TabW13.Advance;
var
  Collision: TabObject;
  Child: TabW13;
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
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False)
    else if Generation <= 1 then
    begin
      Child := TabW13.Create;
      ab_Object_Add(Child);
      Child.Launch(SourceObject, Damage div 3, RandomIntRange(0, 360), Generation + 1, Self);
      Child := TabW13.Create;
      ab_Object_Add(Child);
      Child.Launch(SourceObject, Damage div 3, RandomIntRange(0, 360), Generation + 1, Self);
      Child := TabW13.Create;
      ab_Object_Add(Child);
      Child.Launch(SourceObject, Damage div 3, RandomIntRange(0, 360), Generation + 1, Self);
    end;
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w08a_f', 'GAI,Bm.AB.w08a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $55CF6C }

{ @routine $55D224 TabW13_UpdateVisuals }
procedure TabW13.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $55D224 }

end.
