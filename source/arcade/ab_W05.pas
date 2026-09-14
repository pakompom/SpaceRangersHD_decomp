unit ab_W05;
// Unit bracket (inferred): .text 0x005603BC..0x00560B5F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW05 projectile family: $560424..$560B60.

interface

uses Classes, EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW05 = class(TabObject) // @size $E4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    TrailDistance: Single; // @offset $BC
    LastTrailPosition: TVector3D; // @offset $C0
    ExpireTick: Integer; // @offset $D8
    TurnDelta: Single; // @offset $DC
    TrailImages: TList; // @offset $E0
    constructor Create; // @addr $560424 @ida "TabW05 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $5604C0 @ida "void __usercall $name(TabW05 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $560578 @ida "void __userpurge $name(TabW05 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Offset@<^0>);"
    procedure Advance; override; // @addr $560740
    procedure UpdateVisuals; override; // @addr $5608E0
  end;

implementation

uses GlobalsV;

{ @routine $560424 TabW05_Create }
constructor TabW05.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  Mass := 1;
  Thrust := 1.2;
  CollisionRadius := 1;
  Collidable := False;
  TrailImages := TList.Create;
end;
{ @end $560424 }

{ @routine $5604C0 TabW05_Destroy }
destructor TabW05.Destroy;
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
{ @end $5604C0 }

{ @routine $560578 TabW05_Launch }
procedure TabW05.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
var
  Heading, HeadingDelta: Double;
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  LastTrailPosition := GetWorldPosition;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 25;
  TurnDelta := Offset / 5;
  if Offset <> 0 then
  begin
    Heading := WrapHeadingDegrees(State.BearingDegrees + 90);
    HeadingDelta := HeadingDifferenceDegrees(Heading, State.BearingDegrees);
    AdvanceSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, Heading, SphereRadius, Offset);
    State.BearingDegrees := WrapHeadingDegrees(Heading + HeadingDelta);
  end;
  TrailDistance := 0;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w05_f', 'GAI,Bm.AB.w05_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $560578 }

{ @routine $560740 TabW05_Advance }
procedure TabW05.Advance;
var
  Collision: TabObject;
begin
  inherited Advance;
  State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + TurnDelta);
  if not Exploding then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  Collision := nil;
  if not Exploding then
  begin
    Collision := FindCollision;
    if Collision = SourceObject then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and not Exploding then
  begin
    if Collision <> nil then Collision.ApplyDamage(Damage, SourceObject, True);
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w05b_f', 'GAI,Bm.AB.w05b_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $560740 }

{ @routine $5608E0 TabW05_UpdateVisuals }
procedure TabW05.UpdateVisuals;
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
      Entry := ab_WorldImage_Create(GetWorldPosition, 'GAI,Bm.AB.w05a_f', '', False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
      TrailImages.Add(Entry);
    end
    else
    begin
      ab_WorldImage_Set(Entry, GetWorldPosition, 'GAI,Bm.AB.w05a_f', '');
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
      Entry := ab_WorldImage_Create(Position, 'GAI,Bm.AB.w05a_f', '', False);
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
      TrailImages.Add(Entry);
    end
    else
    begin
      ab_WorldImage_Set(Entry, Position, 'GAI,Bm.AB.w05a_f', '');
      ab_WorldImage_SetDepth(Entry, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Entry, False);
    end;
    LastTrailPosition := GetWorldPosition;
  end;
end;
{ @end $5608E0 }


end.
