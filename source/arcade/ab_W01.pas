unit ab_W01;
// Unit bracket (inferred): .text 0x00561E30..0x0056266F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW01 projectile family: $561E98..$562670.

interface

uses Classes, EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW01 = class(TabObject) // @size $EC
  public
    ValueB0: Single; // @offset $B0  Constructor sets 500; no consumer in this family.
    Damage: Integer; // @offset $B4
    Image: PabWorldImage; // @offset $B8
    Exploding: Boolean; // @offset $BC
    TrailDistance: Single; // @offset $C0
    LastTrailPosition: TVector3D; // @offset $C8
    ExpireTick: Integer; // @offset $E0
    TurnSpeed: Single; // @offset $E4
    TrailImages: TList; // @offset $E8
    constructor Create; // @addr $561E98 @ida "TabW01 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $561F50 @ida "void __usercall $name(TabW01 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $562008 @ida "void __userpurge $name(TabW01 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Offset@<^0>);"
    procedure Advance; override; // @addr $5621B8
    procedure UpdateVisuals; override; // @addr $5623F0
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $561E98 TabW01_Create }
constructor TabW01.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  ValueB0 := 500;
  TurnSpeed := 4;
  Mass := 1;
  Thrust := 1.2;
  CollisionRadius := 1;
  Collidable := False;
  TrailImages := TList.Create;
end;
{ @end $561E98 }

{ @routine $561F50 TabW01_Destroy }
destructor TabW01.Destroy;
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
{ @end $561F50 }

{ @routine $562008 TabW01_Launch }
procedure TabW01.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
var
  Heading, HeadingDelta: Double;
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  LastTrailPosition := GetWorldPosition;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 30;
  if Offset <> 0 then
  begin
    Heading := WrapHeadingDegrees(State.BearingDegrees + 90);
    HeadingDelta := HeadingDifferenceDegrees(Heading, State.BearingDegrees);
    AdvanceSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, Heading, SphereRadius, Offset);
    State.BearingDegrees := WrapHeadingDegrees(Heading + HeadingDelta);
  end;
  TrailDistance := 0;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w01_f', 'GAI,Bm.AB.w01_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $562008 }

{ @routine $5621B8 TabW01_Advance }
procedure TabW01.Advance;
var
  Collision: TabObject;
  Enemy: TabShip;
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
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, False);
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w01b_f', 'GAI,Bm.AB.w01b_s');
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
{ @end $5621B8 }

{ @routine $5623F0 TabW01_UpdateVisuals }
procedure TabW01.UpdateVisuals;
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
      Entry := ab_WorldImage_Create(GetWorldPosition, 'GAI,Bm.AB.w01a_f', '', False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
      TrailImages.Add(Entry);
    end
    else
    begin
      ab_WorldImage_Set(Entry, GetWorldPosition, 'GAI,Bm.AB.w01a_f', '');
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
    Position := GetWorldPosition;
    Position := MakeVector3D((Position.X + LastTrailPosition.X) / 2, (Position.Y + LastTrailPosition.Y) / 2, (Position.Z + LastTrailPosition.Z) / 2);
    if Entry = nil then
    begin
      Entry := ab_WorldImage_Create(Position, 'GAI,Bm.AB.w01a_f', '', False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
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
{ @end $5623F0 }

end.
