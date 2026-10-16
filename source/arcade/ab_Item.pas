unit ab_Item;
// TabItem VMT at $664944; original source-unit boundary unresolved.

interface

uses aItem, ab_Object, ab_Zone, SE_Space, SE_Container;

type
  TabItem = class(TabObject) // @size $C4
  public
    Item: TItem; // @offset $B0  Campaign equipment; nil for arena bonuses.
    BonusKind: Integer; // @offset $B4  -1 for equipment; otherwise index into the eight ship bonus timers.
    HiddenBonus: Boolean; // @offset $B8  Uses the unknown-bonus image.
    Visual: TContainerSE; // @offset $BC
    SpawnZone: PabZone; // @offset $C0
    constructor Create; // @addr $6649AC
    destructor Destroy; override; // @addr $664A30
    procedure SetItem(Value: TItem); // @addr $664AC8
    procedure SetBonus(Kind: Integer; Hidden: Boolean; Zone: PabZone); // @addr $664ADC
    procedure AttachVisual; // @addr $664C18
    procedure DetachVisual; // @addr $664C60
    procedure UpdateState; override; // @addr $664C90
    procedure Advance; override; // @addr $664C98
    procedure UpdateVisuals; override; // @addr $664CA0
  end;

procedure ab_Item_Update; // @addr $664DC0
procedure ab_Item_Drop(Origin: TabObject; Item: TItem; MinDistance, MaxDistance: Integer); // @addr $66517C
function ab_Item_FindNearestBonus(Origin: PabZone): TabItem; // @addr $665274
function ab_Item_FindBonusRoute(Origin: PabZone; var Zone: PabZone): TabItem; // @addr $66531C
function ab_Item_FindRepairRoute(Origin: PabZone; var Zone: PabZone): TabItem; // @addr $665404

implementation

uses Windows, Classes, SysUtils, EC_Struct, GI_Tail, ab_Global, SE_Process, ab_MainForm, ab_ShipAI, aMyFunction, ab_Ship, aShip, aPlayer, GR_Main, GR_Sound, Globals, GlobalsV;

{ @routine $6649AC TabItem_Create }
constructor TabItem.Create;
begin
  inherited Create;
  BonusKind := -1;
  HiddenBonus := False;
  WallCollisionEnabled := False;
  MaxSpeed := 0;
  SpeedScale := 0;
  Mass := 10;
  State.PolarAngleDegrees := 0;
  State.BearingDegrees := 0;
  CollisionRadius := 0;
  Collidable := False;
end;
{ @end $6649AC }

{ @routine $664A30 TabItem_Destroy }
destructor TabItem.Destroy;
var
  Obj: TabObject;
  Ship: TabShipAI;
begin
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj is TabShipAI then
    begin
      Ship := Obj as TabShipAI;
      if Ship.TargetBonus = Self then Ship.TargetBonus := nil;
    end;
    Obj := Obj.Next;
  end;
  if Item <> nil then
  begin
    Item.Free;
    Item := nil;
  end;
  if Visual <> nil then ReleaseSpaceObject(Visual);
  inherited Destroy;
end;
{ @end $664A30 }

{ @routine $664AC8 TabItem_SetItem }
procedure TabItem.SetItem(Value: TItem);
begin
  BonusKind := -1;
  Item := Value;
end;
{ @end $664AC8 }

{ @routine $664ADC TabItem_SetBonus }
procedure TabItem.SetBonus(Kind: Integer; Hidden: Boolean; Zone: PabZone);
begin
  BonusKind := Kind;
  HiddenBonus := Hidden;
  SpawnZone := Zone;
  if HiddenBonus then RetainSpaceObject(Visual, CreateSpaceObjectByName('Container', 'ItemAB.Unknown', Classes.Point(0, 0)))
  else RetainSpaceObject(Visual, CreateSpaceObjectByName('Container', 'ItemAB.' + IntToStr(Kind), Classes.Point(0, 0)));
end;
{ @end $664ADC }

{ @routine $664C18 TabItem_AttachVisual }
procedure TabItem.AttachVisual;
begin
  if Item <> nil then
  begin
    Item.GetGraphObject.AttachToSpace(ArcadeSpaceProcess.Space);
    Exit;
  end;
  if Visual <> nil then Visual.AttachToSpace(ArcadeSpaceProcess.Space);
end;
{ @end $664C18 }

{ @routine $664C60 TabItem_DetachVisual }
procedure TabItem.DetachVisual;
begin
  if Item <> nil then
  begin
    Item.GetGraphObject.DetachFromSpace;
    Exit;
  end;
  if Visual <> nil then Visual.DetachFromSpace;
end;
{ @end $664C60 }

{ @routine $664C90 TabItem_UpdateState }
procedure TabItem.UpdateState;
begin
  inherited UpdateState;
end;
{ @end $664C90 }

{ @routine $664C98 TabItem_Advance }
procedure TabItem.Advance;
begin
  inherited Advance;
end;
{ @end $664C98 }

{ @routine $664CA0 TabItem_UpdateVisuals }
procedure TabItem.UpdateVisuals;
var
  Position: TVector3D;
begin
  inherited UpdateVisuals;
  Position := GetWorldPosition;
  Position := ProjectPointByMatrix(SphereProjectionMatrix, Position);
  if Item <> nil then
  begin
    Item.GetGraphObject.Pos := MakePointF(Position.X, Position.Y);
    if not IsDepthBeforeSphereHorizon(Position.Z) then DetachVisual
    else
    begin
      AttachVisual;
      Item.GetGraphObject.DepthValue := ItemFrontDepth;
    end;
  end
  else if Visual <> nil then
  begin
    Visual.Pos := MakePointF(Position.X, Position.Y);
    if not IsDepthBeforeSphereHorizon(Position.Z) then DetachVisual
    else
    begin
      AttachVisual;
      Visual.SetDepth(ItemFrontDepth);
    end;
  end;
end;
{ @end $664CA0 }

{ @routine $664DC0 ab_Item_Update }
procedure ab_Item_Update;
var
  Zone: PabZone;
  Bonus: TabItem;
  Index, Count: Integer;
  Distance: Single;
  NextObj, Obj, Ship: TabObject;
  Kinds: array[0..7] of Integer;
begin
  if PlayerArcadeShip <> nil then
    if PlayerArcadeShip.Enemies.Count > 0 then
    begin
      Zone := FirstZone;
      while Zone <> nil do
      begin
        if ((Zone.BonusFlags and ArcadeBonusKindMask) <> 0) and (Zone.NextBonusTick >= 0) and (Zone.NextBonusTick <= ArcadeTickCount) then
        begin
          Zone.NextBonusTick := -1;
          Count := 0;
          for Index := Low(Kinds) to High(Kinds) do
            if (Zone.BonusFlags and (1 shl Index)) <> 0 then
            begin
              Kinds[Count] := Index;
              Inc(Count);
            end;
          Bonus := TabItem.Create;
          Bonus.SetBonus(Kinds[RandomIntRange(0, Count - 1)], (Zone.BonusFlags and arcade_bonus_hidden) <> 0, Zone);
          Bonus.State.LongitudeDegrees := Zone.Longitude;
          Bonus.State.PolarAngleDegrees := Zone.PolarAngle;
          Bonus.State.BearingDegrees := RandomIntRange(0, 359);
          Distance := 0;
          AdvanceSphericalBearingState(Bonus.State.LongitudeDegrees, Bonus.State.PolarAngleDegrees,
            Bonus.State.BearingDegrees, SphereRadius, Distance);
          Bonus.AttachVisual;
          ab_Object_Add(Bonus);
        end;
        Zone := Zone.Next;
      end;
    end;
  NextObj := FirstArcadeObject;
  while NextObj <> nil do
  begin
    Obj := NextObj;
    NextObj := NextObj.Next;
    if Obj is TabItem then
    begin
      if TabItem(Obj).BonusKind >= 0 then
      begin
        Bonus := TabItem(Obj);
        Ship := FirstArcadeObject;
        while Ship <> nil do
        begin
          if (Ship is TabShip) and (Ship.DistanceTo(Bonus) < 60) then
          begin
            Bonus.Visual.DetachFromSpace;
            Bonus.SpawnZone.NextBonusTick := ArcadeTickCount + 20 * RandomIntRange(
              BonusRespawnSeconds[Bonus.SpawnZone.BonusRespawnClass * 2], BonusRespawnSeconds[Bonus.SpawnZone.BonusRespawnClass * 2 + 1]);
            if (Bonus.BonusKind = arcade_effect_invisibility) and (TabShip(Ship).BonusTicks[Bonus.BonusKind] <= 0) then TabShip(Ship).RevealTicks := 0;
            TabShip(Ship).BonusTicks[Bonus.BonusKind] := 20 * BonusDurationSeconds[Bonus.BonusKind];
            if PlayerArcadeShip = TabShip(Ship) then SoundManager.PlaySound(ArcadeItemSounds[Bonus.BonusKind]);
            ab_Object_Delete(Bonus);
            Break;
          end;
          Ship := Ship.Next;
        end;
      end;
    end;
  end;
  if IsVirtualKeyDown(VK_MENU) and (PlayerArcadeShip <> nil) and (PlayerArcadeShip.Health > 0) and
    (GetPlayer <> nil) and GetPlayer.IsEquipmentUsable(GetPlayer.GetCargoHook) then
  begin
    NextObj := FirstArcadeObject;
    while NextObj <> nil do
    begin
      Obj := NextObj;
      NextObj := NextObj.Next;
      if Obj is TabItem then
        if ((Obj as TabItem).Item <> nil) and
          ((Obj as TabItem).Item.Weight <= GetPlayer.CargoFreeSpace) and
          (PlayerArcadeShip.DistanceTo(Obj) < CargoPickupDistance) and
          (GetPlayer.CalculateCargoHookPower(GetPlayer.GetCargoHook) >= (Obj as TabItem).Item.Weight) then
          begin
            ArcadeBattleScreen.PickUpItem(Obj as TabItem);
            ArcadeBattleScreen.CancelCargoPickup;
          end;
    end;
  end;
end;
{ @end $664DC0 }

{ @routine $66517C ab_Item_Drop }
procedure ab_Item_Drop(Origin: TabObject; Item: TItem; MinDistance, MaxDistance: Integer);
var
  Dropped: TabItem;
  Attempt: Integer;
  Distance, Bearing: Double;
  Obj: TabObject;
begin
  Dropped := TabItem.Create;
  Dropped.SetItem(Item);
  for Attempt := 0 to 10 do
  begin
    Distance := RandomIntRange(MinDistance, MaxDistance);
    Bearing := RandomIntRange(0, 359);
    Dropped.State := Origin.State;
    Dropped.State.BearingDegrees := Bearing;
    AdvanceSphericalBearingState(Dropped.State.LongitudeDegrees, Dropped.State.PolarAngleDegrees,
      Dropped.State.BearingDegrees, SphereRadius, Distance);
    Obj := FirstArcadeObject;
    while Obj <> nil do
    begin
      if (Obj is TabItem) and (Obj.DistanceTo(Dropped) < 20) then Break;
      Obj := Obj.Next;
    end;
    if Obj = nil then Break;
  end;
  ab_Object_Add(Dropped);
  Dropped.AttachVisual;
end;
{ @end $66517C }

{ @routine $665274 ab_Item_FindNearestBonus }
function ab_Item_FindNearestBonus(Origin: PabZone): TabItem;
var
  Obj: TabItem;
  Distance, BestDistance: Double;
begin
  Result := nil;
  BestDistance := 1E20;
  Obj := TabItem(FirstArcadeObject);
  while Obj <> nil do
  begin
    if TObject(Obj) is TabItem then
      case Obj.BonusKind of
        arcade_effect_regeneration, arcade_effect_speed_boost, arcade_effect_damage_boost..arcade_effect_invisibility:
          begin
            ComputeSphericalDistance(Distance, Origin.Longitude, Origin.PolarAngle,
              0, Obj.State.LongitudeDegrees, Obj.State.PolarAngleDegrees, SphereRadius);
            if Distance < BestDistance then
            begin
              BestDistance := Distance;
              Result := Obj;
            end;
          end;
      end;
    Obj := TabItem(Obj.Next);
  end;
end;
{ @end $665274 }

{ @routine $66531C ab_Item_FindBonusRoute }
function ab_Item_FindBonusRoute(Origin: PabZone; var Zone: PabZone): TabItem;
var
  Obj: TabObject;
  Distance, BestDistance: Double;
  Route: PabZone;
begin
  Result := nil;
  Zone := nil;
  BestDistance := 1E20;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj is TabItem then
      case TabItem(Obj).BonusKind of
        arcade_effect_regeneration, arcade_effect_speed_boost, arcade_effect_damage_boost..arcade_effect_invisibility:
          begin
            ComputeSphericalDistance(Distance, Origin.Longitude, Origin.PolarAngle,
              0, Obj.State.LongitudeDegrees, Obj.State.PolarAngleDegrees, SphereRadius);
            if Distance < BestDistance then
            begin
              Route := ab_Zone_FindReachableRouteZone(TabItem(Obj).SpawnZone);
              if (Route <> nil) and (RandomIntRange(0, 2) = 0) then
                begin
                  Zone := Route;
                  BestDistance := Distance;
                  Result := TabItem(Obj);
                end;
            end;
          end;
      end;
    Obj := Obj.Next;
  end;
end;
{ @end $66531C }

{ @routine $665404 ab_Item_FindRepairRoute }
function ab_Item_FindRepairRoute(Origin: PabZone; var Zone: PabZone): TabItem;
var
  Obj: TabObject;
  Distance, BestDistance: Double;
  Route: PabZone;
begin
  Result := nil;
  Zone := nil;
  BestDistance := 1E20;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if (Obj is TabItem) and (TabItem(Obj).BonusKind in [arcade_effect_regeneration]) then
    begin
      ComputeSphericalDistance(Distance, Origin.Longitude, Origin.PolarAngle,
        0, Obj.State.LongitudeDegrees, Obj.State.PolarAngleDegrees, SphereRadius);
      if Distance < BestDistance then
      begin
        Route := ab_Zone_FindReachableRouteZone(TabItem(Obj).SpawnZone);
        if Route <> nil then
        begin
          Zone := Route;
          BestDistance := Distance;
          Result := TabItem(Obj);
        end;
      end;
    end;
    Obj := Obj.Next;
  end;
end;
{ @end $665404 }

end.
