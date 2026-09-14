unit ab_W10;
// Unit bracket (inferred): .text 0x0055E05C..0x0055E8CB; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW10 projectile family: $55E0C4..$55E8CC.

interface

uses Classes, EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW10 = class(TabObject) // @size $E4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    TrailDistance: Single; // @offset $BC
    LastTrailPosition: TVector3D; // @offset $C0
    ExpireTick: Integer; // @offset $D8
    TurnSpeed: Single; // @offset $DC
    TrailImages: TList; // @offset $E0
    constructor Create; // @addr $55E0C4 @ida "TabW10 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $55E16C @ida "void __usercall $name(TabW10 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $55E224 @ida "void __userpurge $name(TabW10 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Offset@<^0>);"
    procedure Advance; override; // @addr $55E3D4
    procedure UpdateVisuals; override; // @addr $55E64C
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $55E0C4 TabW10_Create }
constructor TabW10.Create;
begin
  inherited Create;
  MaxSpeed := 30;
  TurnSpeed := 10;
  Mass := 1;
  Thrust := 0.8;
  CollisionRadius := 5;
  Collidable := False;
  TrailImages := TList.Create;
end;
{ @end $55E0C4 }

{ @routine $55E16C TabW10_Destroy }
destructor TabW10.Destroy;
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
{ @end $55E16C }

{ @routine $55E224 TabW10_Launch }
procedure TabW10.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
var
  Heading, HeadingDelta: Double;
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  LastTrailPosition := GetWorldPosition;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 65;
  if Offset <> 0 then
  begin
    Heading := WrapHeadingDegrees(State.BearingDegrees + 90);
    HeadingDelta := HeadingDifferenceDegrees(Heading, State.BearingDegrees);
    AdvanceSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, Heading, SphereRadius, Offset);
    State.BearingDegrees := WrapHeadingDegrees(Heading + HeadingDelta);
  end;
  TrailDistance := 0;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w10_f', 'GAI,Bm.AB.w10_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $55E224 }

{ @routine $55E3D4 TabW10_Advance }
procedure TabW10.Advance;
var
  Collision: TabObject;
  Enemy: TabShip;
begin
  inherited Advance;
  if not Exploding then
  begin
    TurnSpeed := Sqrt(Sqr(Velocity.X) + Sqr(Velocity.Y)) / MaxSpeed * 15;
    ab_WorldImage_SetPosition(Image, GetWorldPosition);
  end;
  Collision := nil;
  if not Exploding then
  begin
    Collision := FindCollision;
    if Collision = SourceObject then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and not Exploding then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w10b_f', 'GAI,Bm.AB.w10b_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if not Exploding and (Collision = nil) then
  begin
    if SourceObject <> nil then
    begin
      Enemy := SourceObject as TabShip;
      Enemy := Enemy.FindNearestEnemy(Self);
      if Enemy <> nil then
        with BearingAndDistanceTo(Enemy) do
        begin
          if BearingDeltaDegrees < -TurnSpeed then BearingDeltaDegrees := -TurnSpeed
          else if BearingDeltaDegrees > TurnSpeed then BearingDeltaDegrees := TurnSpeed;
          State.BearingDegrees := State.BearingDegrees + BearingDeltaDegrees;
        end;
    end;
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $55E3D4 }

{ @routine $55E64C TabW10_UpdateVisuals }
procedure TabW10.UpdateVisuals;
var
  Entry: PabWorldImage;
  Index: Integer;
  Position: TVector3D;
begin
  inherited UpdateVisuals;
  if not Exploding and (DistanceTravelled > TrailDistance) then
  begin
    TrailDistance := 0;
    Entry := nil;
    for Index := 0 to TrailImages.Count - 1 do
    begin
      Entry := TrailImages[Index];
      if Entry.Finished then Break;
      Entry := nil;
    end;
    if Entry = nil then
    begin
      Entry := ab_WorldImage_Create(GetWorldPosition, 'GAI,Bm.AB.w10a_f', '', False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
      TrailImages.Add(Entry);
    end
    else
    begin
      ab_WorldImage_Set(Entry, GetWorldPosition, 'GAI,Bm.AB.w10a_f', '');
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
    end;
    Entry := nil;
    for Index := 0 to TrailImages.Count - 1 do
    begin
      Entry := TrailImages[Index];
      if Entry.Finished then Break;
      Entry := nil;
    end;
    // Native midpoint samples deliberately use the W01 trail asset.
    Position := GetWorldPosition;
    Position := MakeVector3D((Position.X + LastTrailPosition.X) / 2, (Position.Y + LastTrailPosition.Y) / 2, (Position.Z + LastTrailPosition.Z) / 2);
    if Entry = nil then
    begin
      Entry := ab_WorldImage_Create(Position, 'GAI,Bm.AB.w01a_f', '', False);
      ab_WorldImage_SetLooping(Entry, False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      TrailImages.Add(Entry);
    end
    else
    begin
      ab_WorldImage_Set(Entry, Position, 'GAI,Bm.AB.w01a_f', '');
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
    end;
    LastTrailPosition := GetWorldPosition;
  end;
end;
{ @end $55E64C }

end.
