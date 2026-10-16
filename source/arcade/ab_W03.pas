unit ab_W03;

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW03 = class(TabObject) // @size $BC
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    constructor Create; // @addr $5538D8
    destructor Destroy; override; // @addr $553994
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $5539D8
    procedure Explode; // @addr $553AE4
    procedure Advance; override; // @addr $553B90
    procedure UpdateVisuals; override; // @addr $553C88
  end;

var
  ProjectileCount: Integer = 0; // @addr $80E99C

implementation

{ @routine $5538D8 TabW03_Create }
constructor TabW03.Create;
var
  Obj: TabObject;
begin
  inherited Create;
  MaxSpeed := 12;
  Mass := 1;
  Thrust := 1;
  CollisionRadius := 1;
  Collidable := False;
  Inc(ProjectileCount);
  if ProjectileCount > 30 then
  begin
    Obj := FirstArcadeObject;
    while Obj <> nil do
    begin
      if (Obj is TabW03) and not TabW03(Obj).Exploding then
      begin
        (Obj as TabW03).Explode;
        Break;
      end;
      Obj := Obj.Next;
    end;
  end;
end;
{ @end $5538D8 }

{ @routine $553994 TabW03_Destroy }
destructor TabW03.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  Dec(ProjectileCount);
  inherited Destroy;
end;
{ @end $553994 }

{ @routine $5539D8 TabW03_Launch }
procedure TabW03.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  if Offset <> 0 then State := AdvanceSphericalStateOnCurrentSphere(State, Offset);
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w03_f', 'GAI,Bm.AB.w03_s', False);
  ab_WorldImage_SetFrameMode(Image, animation_random_start);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $5539D8 }

{ @routine $553AE4 TabW03_Explode }
procedure TabW03.Explode;
begin
  Exploding := True;
  ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w03a_f', 'GAI,Bm.AB.w03a_s');
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
  ab_WorldImage_SetLooping(Image, False);
end;
{ @end $553AE4 }

{ @routine $553B90 TabW03_Advance }
procedure TabW03.Advance;
var
  Collision: TabObject;
begin
  inherited Advance;
  if not Exploding then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  if DistanceTravelled > 500 then MaxSpeed := 8;
  Collision := nil;
  if not Exploding then
  begin
    Collision := FindCollision;
    if (DistanceTravelled < 500) and (Collision = SourceObject) then Collision := nil;
  end;
  if (Collision <> nil) and not Exploding then
  begin
    if Collision <> nil then
    begin
      Collision.Velocity := MakePointF(Velocity.X / 2, Velocity.Y / 2);
      Collision.ApplyDamage(Damage, SourceObject, False);
    end;
    Explode;
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $553B90 }

{ @routine $553C88 TabW03_UpdateVisuals }
procedure TabW03.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $553C88 }

end.
