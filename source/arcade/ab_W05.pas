unit ab_W05;
// Unit bracket (inferred): .text 0x004F55D0..0x004F5D73; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW05 projectile family: $4F5638..$4F5D74.

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
    constructor Create; // @addr $4F5638
    destructor Destroy; override; // @addr $4F56D4
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $4F578C
    procedure Advance; override; // @addr $4F5954
    procedure UpdateVisuals; override; // @addr $4F5AF4
  end;

implementation

uses GlobalsV;

{ @routine $4F5638 TabW05_Create }
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
{ @end $4F5638 }

{ @routine $4F56D4 TabW05_Destroy }
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
{ @end $4F56D4 }

{ @routine $4F578C TabW05_Launch }
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
{ @end $4F578C }

{ @routine $4F5954 TabW05_Advance }
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
{ @end $4F5954 }

{ @routine $4F5AF4 TabW05_UpdateVisuals }
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
{ @end $4F5AF4 }


end.
