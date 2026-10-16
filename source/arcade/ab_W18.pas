unit ab_W18;

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW18 = class(TabObject) // @size $CC
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    ExpireTick: Integer; // @offset $BC
    OrbitAngle: Single; // @offset $C0
    AngleCorrection: Single; // @offset $C4
    OrbitRadius: Single; // @offset $C8
    constructor Create; // @addr $54DE24
    destructor Destroy; override; // @addr $54DE94
    procedure Launch(Owner: TabObject; Amount: Integer; Angle: Single); // @addr $54DED0
    procedure Advance; override; // @addr $54DFCC
    procedure UpdateVisuals; override; // @addr $54E408
  end;

implementation

uses GlobalsV, ab_Ship;

{ @routine $54DE24 TabW18_Create }
constructor TabW18.Create;
begin
  inherited Create;
  MaxSpeed := 100;
  AngleCorrection := 0;
  Mass := 1;
  Thrust := 0;
  CollisionRadius := 1;
  Collidable := False;
end;
{ @end $54DE24 }

{ @routine $54DE94 TabW18_Destroy }
destructor TabW18.Destroy;
begin
  if Image <> nil then
  begin
    ab_WorldImage_Delete(Image);
    Image := nil;
  end;
  inherited Destroy;
end;
{ @end $54DE94 }

{ @routine $54DED0 TabW18_Launch }
procedure TabW18.Launch(Owner: TabObject; Amount: Integer; Angle: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  OrbitAngle := Angle;
  OrbitRadius := 1;
  State := Owner.State;
  Velocity := Owner.Velocity;
  ExpireTick := ArcadeTickCount + 1000;
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w18_f', 'GAI,Bm.AB.w18_s', False);
  ab_WorldImage_SetFrameMode(Image, animation_random_start);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $54DED0 }

{ @routine $54DFCC TabW18_Advance }
procedure TabW18.Advance;
var
  Collision, NextNeighbor, Obj: TabObject;
  PositiveDelta, NegativeDelta, Delta: Single;
begin
  inherited Advance;
  if not Exploding then
  begin
    if SourceObject <> nil then
    begin
      if OrbitRadius < 150 then OrbitRadius := OrbitRadius + 0.5;
      if OrbitRadius < 100 then OrbitRadius := OrbitRadius + 0.5;
      if OrbitRadius < 50 then OrbitRadius := OrbitRadius + 0.5;
      if ArcadeTickCount mod 3 = 1 then
      begin
        OrbitAngle := WrapHeadingDegrees(OrbitAngle + 3.75 + AngleCorrection);
        AngleCorrection := 0;
      end
      else OrbitAngle := WrapHeadingDegrees(OrbitAngle + 3.75);
      State := AdvanceSphericalStateOnCurrentSphere(
        MakeSphericalBearingState(SourceObject.State.LongitudeDegrees,
          SourceObject.State.PolarAngleDegrees, OrbitAngle), OrbitRadius);
      if ArcadeTickCount mod 3 = 0 then
      begin
        Collision := nil;
        NextNeighbor := nil;
        PositiveDelta := 0;
        NegativeDelta := 0;
        Obj := FirstArcadeObject;
        while Obj <> nil do
        begin
          if (Obj is TabW18) and (Obj <> Self) and ((Obj as TabW18).SourceObject = SourceObject) then
          begin
            Delta := WrapSignedHeadingDegrees((Obj as TabW18).OrbitAngle - OrbitAngle);
            if (Delta < 0) and ((Collision = nil) or (NegativeDelta < Delta)) then
            begin
              NegativeDelta := Delta;
              Collision := Obj;
            end;
            if (Delta >= 0) and ((NextNeighbor = nil) or (PositiveDelta > Delta)) then
            begin
              PositiveDelta := Delta;
              NextNeighbor := Obj;
            end;
          end;
          Obj := Obj.Next;
        end;
        if Collision <> nil then
          (Collision as TabW18).AngleCorrection := (Collision as TabW18).AngleCorrection - (180 + NegativeDelta) * 0.03;
        if NextNeighbor <> nil then
          (NextNeighbor as TabW18).AngleCorrection := (NextNeighbor as TabW18).AngleCorrection + (180 - PositiveDelta) * 0.03;
      end;
    end;
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
    if Collision <> nil then
    begin
      Collision.ApplyDamage(Damage, SourceObject, False);
      Collision.State.BearingDegrees := Collision.State.BearingDegrees - 30;
    end;
    Exploding := True;
    ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w18a_f', 'GAI,Bm.AB.w18a_s');
    ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
    ab_WorldImage_SetLooping(Image, False);
  end
  else if Exploding then DeletionPending := Image.Finished;
end;
{ @end $54DFCC }

{ @routine $54E408 TabW18_UpdateVisuals }
procedure TabW18.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $54E408 }

end.
