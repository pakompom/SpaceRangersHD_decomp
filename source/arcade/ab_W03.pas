unit ab_W03;
// Unit bracket (inferred): .text 0x00561378..0x00561865; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native TabW03 projectile family: $5613E0..$561866.

interface

uses EC_Struct, GI_Tail, ab_Global, ab_Object, ab_WorldImage;

type
  TabW03 = class(TabObject) // @size $BC
  public
    Damage: Integer; // @offset $B0
    Image: PabWorldImage; // @offset $B4
    Exploding: Boolean; // @offset $B8
    constructor Create; // @addr $5613E0 @ida "TabW03 *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr $5614C8 @ida "void __usercall $name(TabW03 *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure Launch(Owner: TabObject; Amount: Integer; Offset: Single); // @addr $561524 @ida "void __userpurge $name(TabW03 *Self@<eax>, TabObject *Owner@<edx>, int Amount@<ecx>, float Offset@<^0>);"
    procedure Explode; // @addr $56165C
    procedure Advance; override; // @addr $561718
    procedure UpdateVisuals; override; // @addr $561854
  end;

var
  ProjectileCount: Integer = 0; // @addr $87AA3C

implementation

{ @routine $5613E0 TabW03_Create }
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
{ @end $5613E0 }

{ @routine $5614C8 TabW03_Destroy }
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
{ @end $5614C8 }

{ @routine $561524 TabW03_Launch }
procedure TabW03.Launch(Owner: TabObject; Amount: Integer; Offset: Single);
begin
  SourceObject := Owner;
  Damage := Amount;
  State := Owner.State;
  Velocity := Owner.Velocity;
  if Offset <> 0 then State := AdvanceSphericalStateOnCurrentSphere(State, Offset);
  Image := ab_WorldImage_Create(MakeVector3D(0, 0, 0), 'GAI,Bm.AB.w03_f', 'GAI,Bm.AB.w03_s', False);
  ab_WorldImage_SetFrameMode(Image, afmRandomStart);
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
end;
{ @end $561524 }

{ @routine $56165C TabW03_Explode }
procedure TabW03.Explode;
begin
  Exploding := True;
  ab_WorldImage_Set(Image, GetWorldPosition, 'GAI,Bm.AB.w03a_f', 'GAI,Bm.AB.w03a_s');
  ab_WorldImage_SetDepth(Image, HitFrontDepth, HitBackDepth);
  ab_WorldImage_SetLooping(Image, False);
end;
{ @end $56165C }

{ @routine $561718 TabW03_Advance }
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
{ @end $561718 }

{ @routine $561854 TabW03_UpdateVisuals }
procedure TabW03.UpdateVisuals;
begin
  inherited UpdateVisuals;
end;
{ @end $561854 }

end.
