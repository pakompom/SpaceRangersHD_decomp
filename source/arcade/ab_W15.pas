unit ab_W15;
// Unit bracket (inferred): .text 0x0055C040..0x0055C6ED; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW15 projectile family: $55C0A8..$55C6EE.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW15 = class(TabObject) // @size $C8
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8
    TurnSpeed: Single; // @offset $BC
    TurnBias: Single; // @offset $C0
    ExpireTick: Integer; // @offset $C4
    constructor Create; // @addr $55C0A8 @ida "TabW15 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $55C19C @ida "void __usercall $name(TabW15 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Angle: Single); // @addr $55C1F8 @ida "void __userpurge $name(TabW15 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Angle@<^0>);"
    procedure Explode; // @addr $55C314
    procedure Advance; override; // @addr $55C3D0
    procedure UpdateVisuals; override; // @addr $55C6DC
  end;

var
  W15ProjectileCount: Integer = 0; // @addr $87AA38

implementation

uses GlobalsV, ab_Ship, aMyFunction;

{ @routine $55C0A8 TabW15_Create }
constructor TabW15.Create;
var
  Obj: TabObject;
begin
  inherited Create;
  MaxSpeed := 12;
  Mass := 1;
  Thrust := 1.5;
  TurnSpeed := 1;
  CollisionRadius := 5;
  Collidable := True;
  Inc(W15ProjectileCount);
  if W15ProjectileCount > 50 then
  begin
    Obj := FirstArcadeObject;
    while Obj <> nil do
    begin
      if (Obj is TabW15) and (TabW15(Obj).Phase <> 2) then
      begin
        (Obj as TabW15).Explode;
        Break;
      end;
      Obj := Obj.Next;
    end;
  end;
end;
{ @end $55C0A8 }

{ @routine $55C19C TabW15_Destroy }
destructor TabW15.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  Dec(W15ProjectileCount);
  inherited Destroy;
end;
{ @end $55C19C }

{ @routine $55C1F8 TabW15_Launch }
procedure TabW15.Launch(Owner: TabObject; Amount: Integer; Angle: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Angle);
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 1500;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w15_f', 'GAI,Bm.AB.w15_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $55C1F8 }

{ @routine $55C314 TabW15_Explode }
procedure TabW15.Explode;
begin
  Phase := 2;
  ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w15a_f', 'GAI,Bm.AB.w15a_s');
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
  ab_WorldImage_SetLooping(Image, False);
end;
{ @end $55C314 }

{ @routine $55C3D0 TabW15_Advance }
procedure TabW15.Advance;
var
  Collision: TabObject;
  Enemy: TabShip;
begin
  inherited Advance;
  if Phase <> 2 then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  if ArcadeTickCount mod 150 = 0 then
    TurnBias := RandomIntRange(25, 40) * (RandomIntRange(0, 1) * 2 - 1);
  Collision := nil;
  if Phase <> 2 then
  begin
    Collision := FindCollision;
    if (Collision <> nil) and (SourceObject <> nil) and (Collision is TabShip) and
      (TabShip(SourceObject).Enemies.IndexOf(Collision) < 0) then Collision := nil;
    if Collision = SourceObject then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and (Phase <> 2) then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    Phase := 2;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w15a_f', 'GAI,Bm.AB.w15a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if (Phase = 0) and (DistanceTravelled > 400) then
  begin
    MaxSpeed := 5;
    Phase := 1;
  end
  else if Phase = 1 then
  begin
    if SourceObject <> nil then
    begin
      Enemy := SourceObject as TabShip;
      Enemy := Enemy.FindNearestEnemy(Self);
      if Enemy <> nil then
        with BearingAndDistanceTo(Enemy) do
        begin
          BearingDeltaDegrees := BearingDeltaDegrees + TurnBias;
          if BearingDeltaDegrees < -TurnSpeed then BearingDeltaDegrees := -TurnSpeed
          else if BearingDeltaDegrees > TurnSpeed then BearingDeltaDegrees := TurnSpeed;
          State.BearingDegrees := State.BearingDegrees + BearingDeltaDegrees;
        end;
    end;
  end
  else if Phase = 2 then DeletionPending := Image.Finished;
end;
{ @end $55C3D0 }

{ @routine $55C6DC TabW15_UpdateVisuals }
procedure TabW15.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $55C6DC }

end.
