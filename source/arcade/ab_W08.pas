unit ab_W08;

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW08 = class(TabObject) // @size $C4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    Generation: Integer; // @offset $BC
    ExpireTick: Integer; // @offset $C0
    constructor Create; // @addr $551B98
    destructor Destroy; override; // @addr $551C04
    procedure Launch(Owner: TabObject; Amount: Integer; Angle: Single; AGeneration: Integer; Origin: TabObject); // @addr $551C40
    procedure Advance; override; // @addr $551E40
    procedure UpdateVisuals; override; // @addr $5520C8
  end;


implementation

uses ab_Ship, GlobalsV, aMyFunction;

{ @routine $551B98 TabW08_Create }
constructor TabW08.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 0.8;
  CollisionRadius := 5;
  Collidable := False;
end;
{ @end $551B98 }

{ @routine $551C04 TabW08_Destroy }
destructor TabW08.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $551C04 }

{ @routine $551C40 TabW08_Launch }
procedure TabW08.Launch(Owner: TabObject; Amount: Integer; Angle: Single; AGeneration: Integer; Origin: TabObject);
begin
  SourceObject := Owner;
  Damage := Amount;
  if Origin <> nil then State := Origin.State
  else State := Owner.State;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Angle);
  if Owner <> nil then Velocity := Owner.Velocity
  else if Origin <> nil then Velocity := Origin.Velocity
  else Velocity := MakePointF(0, 0);
  Generation := AGeneration;
  if Generation = 0 then ExpireTick := ArcadeTickCount + 30
  else ExpireTick := ArcadeTickCount + 15;
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
{ @end $551C40 }

{ @routine $551E40 TabW08_Advance }
procedure TabW08.Advance;
var
  Collision: TabObject;
  Child: TabW08;
begin
  inherited Advance;
  if not Exploding then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  Collision := nil;
  if not Exploding then
  begin
    Collision := FindCollision;
    if (DistanceTravelled < 200) and (Collision = SourceObject) then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and not Exploding then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False)
    else if Generation <= 1 then
    begin
      Child := TabW08.Create;
      ab_Object_Add(Child);
      Child.Launch(SourceObject as TabShip, Damage div 3, RandomIntRange(0, 360), Generation + 1, Self);
      Child := TabW08.Create;
      ab_Object_Add(Child);
      Child.Launch(SourceObject as TabShip, Damage div 3, RandomIntRange(0, 360), Generation + 1, Self);
      Child := TabW08.Create;
      ab_Object_Add(Child);
      Child.Launch(SourceObject as TabShip, Damage div 3, RandomIntRange(0, 360), Generation + 1, Self);
    end;
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w08a_f', 'GAI,Bm.AB.w08a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $551E40 }

{ @routine $5520C8 TabW08_UpdateVisuals }
procedure TabW08.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $5520C8 }

end.
