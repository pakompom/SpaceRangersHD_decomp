unit ab_W12;
// Unit bracket (inferred): .text 0x004F88A8..0x004F8ED2; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW12 projectile family: $4F8910..$4F8ED4.

interface

uses Classes, EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW12 = class(TabObject) // @size $CC
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    ExpireTick: Integer; // @offset $BC
    OrbitAngle: Single; // @offset $C0
    OrbitRadius: Single; // @offset $C4
    TrailImages: TList; // @offset $C8
    constructor Create; // @addr $4F8910
    destructor Destroy; override; // @addr $4F89A8
    procedure Launch(Owner: TabObject; Amount: Integer; Angle: Single); // @addr $4F8A60
    procedure Advance; override; // @addr $4F8B74
    procedure UpdateVisuals; override; // @addr $4F8DC8
  end;

implementation

uses GlobalsV;

{ @routine $4F8910 TabW12_Create }
constructor TabW12.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 0;
  CollisionRadius := 1;
  Collidable := False;
  TrailImages := TList.Create;
end;
{ @end $4F8910 }

{ @routine $4F89A8 TabW12_Destroy }
destructor TabW12.Destroy;
var
  Index: Integer;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  if TrailImages <> nil then
  begin
    for Index := 0 to TrailImages.Count - 1 do ab_WorldImage_Delete(TrailImages[Index]);
    TrailImages.Free;
    TrailImages := nil;
  end;
  inherited Destroy;
end;
{ @end $4F89A8 }

{ @routine $4F8A60 TabW12_Launch }
procedure TabW12.Launch(Owner: TabObject; Amount: Integer; Angle: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  OrbitAngle := Angle;
  OrbitRadius := 1;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 100;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w12_f', 'GAI,Bm.AB.w12_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $4F8A60 }

{ @routine $4F8B74 TabW12_Advance }
procedure TabW12.Advance;
var
  Collision: TabObject;
begin
  inherited Advance;
  if not Exploding then
  begin
    OrbitAngle := WrapHeadingDegrees(OrbitAngle + 5);
    OrbitRadius := OrbitRadius + 3;
    if SourceObject <> nil then
      State := AdvanceSphericalStateOnCurrentSphere(MakeSphericalBearingState(SourceObject.State.LongitudeDegrees, SourceObject.State.PolarAngleDegrees, OrbitAngle), OrbitRadius);
    Velocity := MakePointF(0, 0);
    ab_WorldImage_SetPosition(Image, GetWorldPosition);
  end;
  Collision := nil;
  if not Exploding then
  begin
    Collision := FindCollision;
    if Collision = SourceObject then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil) or (SourceObject = nil)) and not Exploding then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w12b_f', 'GAI,Bm.AB.w12b_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $4F8B74 }

{ @routine $4F8DC8 TabW12_UpdateVisuals }
procedure TabW12.UpdateVisuals;
var
  Entry: PabWorldImage;
  Index: Integer;
begin
  inherited UpdateVisuals;
  if not Exploding then
  begin
    Entry := nil;
    for Index := 0 to TrailImages.Count - 1 do
    begin
      Entry := TrailImages[Index];
      if Entry.Finished then Break;
      Entry := nil;
    end;
    if Entry = nil then
    begin
      Entry := ab_WorldImage_Create(GetWorldPosition, 'GAI,Bm.AB.w12a_f', 'GAI,Bm.AB.w12a_s', False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
      TrailImages.Add(Entry);
    end
    else
    begin
      ab_WorldImage_Set(Entry, GetWorldPosition, 'GAI,Bm.AB.w12a_f', 'GAI,Bm.AB.w12a_s');
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
    end;
  end;
end;
{ @end $4F8DC8 }

end.
