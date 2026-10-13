unit ab_W17;

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW17 = class(TabObject) // @size $C4
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Phase: Integer; // @offset $B8  0 parent, 1 parent explosion, 2 child, 3 child explosion.
    ExpireTick: Integer; // @offset $BC
    Partner: TabW17; // @offset $C0
    constructor Create; // @addr $54E478
    destructor Destroy; override; // @addr $54E4E4
    procedure Launch(Owner: TabObject; Amount: Integer); // @addr $54E534
    procedure LaunchPartner(Other: TabW17; Owner: TabObject; Amount: Integer); // @addr $54E650
    procedure Advance; override; // @addr $54E75C
    procedure UpdateVisuals; override; // @addr $54EB34
  end;

implementation

uses ab_Ship, GlobalsV;

{ @routine $54E478 TabW17_Create }
constructor TabW17.Create;
begin
  inherited Create;
  MaxSpeed := 20;
  Mass := 0.1;
  Thrust := 1;
  CollisionRadius := 5;
  Collidable := False;
end;
{ @end $54E478 }

{ @routine $54E4E4 TabW17_Destroy }
destructor TabW17.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  if Partner <> nil then Partner.Partner := nil;
  inherited Destroy;
end;
{ @end $54E4E4 }

{ @routine $54E534 TabW17_Launch }
procedure TabW17.Launch(Owner: TabObject; Amount: Integer);
var
  Other: TabW17;
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  State.BearingDegrees := State.BearingDegrees + 30;
  Phase := 0;
  ExpireTick := ArcadeTickCount + 120;
  Partner := nil;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w17_f', 'GAI,Bm.AB.w17_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
  Other := TabW17.Create;
  ab_Object_Add(Other);
  Other.LaunchPartner(Self, Owner, Amount);
end;
{ @end $54E534 }

{ @routine $54E650 TabW17_LaunchPartner }
procedure TabW17.LaunchPartner(Other: TabW17; Owner: TabObject; Amount: Integer);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  State.BearingDegrees := State.BearingDegrees - 30;
  Phase := 2;
  ExpireTick := ArcadeTickCount + 120;
  Partner := Other;
  Other.Partner := Self;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w17b_f', 'GAI,Bm.AB.w17b_s', False);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $54E650 }

{ @routine $54E75C TabW17_Advance }
procedure TabW17.Advance;
var
  Collision: TabObject;
  Delta: Double;
begin
  inherited Advance;
  if (Phase <> 1) and (Phase <> 3) then ab_WorldImage_SetPosition(Image, GetWorldPosition);
  if (Phase in [0, 2]) and (DistanceTravelled > 200) then MaxSpeed := 11;
  Collision := nil;
  if (Phase <> 1) and (Phase <> 3) then
  begin
    Collision := FindCollision;
    if (DistanceTravelled < 300) and (Phase in [0, 2]) and (Collision = SourceObject) then Collision := nil;
    if Partner = Collision then Collision := nil;
  end;
  if ((ArcadeTickCount > ExpireTick) or (Collision <> nil)) and (Phase <> 1) and (Phase <> 3) then
  begin
    if Collision <> nil then
    begin
      Collision.ApplyDamage(Damage, SourceObject, False);
      if Partner <> nil then
      begin
        Partner.Velocity := Collision.Velocity;
        Partner.State.BearingDegrees := Partner.State.BearingDegrees + Partner.BearingAndDistanceTo(Collision).BearingDeltaDegrees;
        Partner.MaxSpeed := Partner.MaxSpeed * 1.5;
        Partner.Thrust := 2;
        Partner.Partner := nil;
        Partner := nil;
      end;
    end;
    if Phase = 0 then
    begin
      Phase := 1;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w17a_f', 'GAI,Bm.AB.w17a_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end
    else
    begin
      Phase := 3;
      ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w17c_f', 'GAI,Bm.AB.w17c_s');
      ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
      ab_WorldImage_SetLooping(Image, False);
    end;
  end
  else if (Phase in [0, 2]) and (Partner <> nil) then
  begin
    with BearingAndDistanceTo(Partner) do
    begin
      Delta := BearingDeltaDegrees;
      while Delta > 180 do Delta := Delta - 360;
      while Delta < -180 do Delta := Delta + 360;
      if (Distance > 100) and (Abs(Delta) > 60) then
      begin
        if Delta > 0 then Delta := Delta - 60
        else Delta := Delta + 60;
        State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Delta);
      end;
    end;
  end
  else if (Phase = 1) or (Phase = 3) then DeletionPending := Image.Finished;
end;
{ @end $54E75C }

{ @routine $54EB34 TabW17_UpdateVisuals }
procedure TabW17.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $54EB34 }

end.
