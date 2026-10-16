unit ab_Ship;

interface

uses Classes, GI_MessageLoop, GI_Tail, ab_Global, SE_Space, ab_Object, ab_Hit, ab_W;

type
  TabShip = class(TabHit) // @size $2E0
  public
    Visual: TObjectSE; // @offset $D0
    VisualDiameter: Integer; // @offset $D4
    OffscreenMarker: TObjectSE; // @offset $D8
    OffscreenLabel: TObjectGI; // @offset $DC
    Enemies: TList; // @offset $E0
    InitialEnemies: TList; // @offset $E4
    TrackedShips: TList; // @offset $E8
    TurnSpeed: Double; // @offset $F0
    TurnInput: Double; // @offset $F8
    WeaponCount: Integer; // @offset $100
    Weapons: array[0..4] of TabWeapon; // @offset $108
    PrimaryWeapon: Integer; // @offset $1F8
    SecondaryWeapon: Integer; // @offset $1FC
    LastPrimaryWeapon: Integer; // @offset $200
    LastPrimaryFireTick: Integer; // @offset $204
    LastSecondaryWeapon: Integer; // @offset $208
    LastSecondaryFireTick: Integer; // @offset $20C
    BonusTicks: array[0..7] of Integer; // @offset $210  Repair, speed, slow, weapon lock, damage, recharge, shield, invisibility.
    RevealTicks: Integer; // @offset $230
    OuterAvoidanceDistance: Double; // @offset $238
    MiddleAvoidanceDistance: Double; // @offset $240
    InnerAvoidanceDistance: Double; // @offset $248
    NextObstacleScanTick: Integer; // @offset $250
    ObstacleDistances: array[0..7] of Double; // @offset $258
    ObstacleLevels: array[0..7] of Integer; // @offset $298
    EncounterTag: Integer; // @offset $2B8 Population tag; native campaign encounters set 1.
    TickCounter: Integer; // @offset $2BC  Modulo-10000 per-ship tick counter.
    ConvertedFromGameShip: Boolean; // @offset $2C0 Marks a converted game ship; preserves copied health and weapons during encounter setup.
    RandomRewardsDisabled: Boolean; // @offset $2C1 Scripted ships disable random rewards unless the reward argument is -1.
    SpawnGraphKey: WideString; // @offset $2C4 CreateABShip graph argument; consumed by PopulateScriptedEncounter.
    ScriptLabel: WideString; // @offset $2C8 Label included in LabeledShipKilledInAB / LabeledShipSurvivedInAB events.
    RewardObject: TObject; // @offset $2CC Owned until transferred as a reward. The script API also accepts unchecked objects.
    Team: Byte; // @offset $2D0 Scripted encounter allegiance; 1 joins the player.
    HealthScalePercent: Integer; // @offset $2D4 Scripted encounter health multiplier.
    DamageScalePercent: Integer; // @offset $2D8 Scripted encounter weapon damage multiplier.
    HasFiredWeapon: Boolean; // @offset $2DC Set by firing; retained for the no-shots victory check.

    constructor Create; // @addr $65F794
    destructor Destroy; override; // @addr $65F880
    procedure CreateShipVisual(const GraphKey: WideString; Diameter: Integer); // @addr $65FB58
    procedure CreateRuinsVisual(const GraphKey: WideString; Diameter: Integer); // @addr $65FC9C
    procedure AttachVisual; // @addr $65FD68
    procedure DetachVisual; // @addr $65FD88
    function FindNearestEnemy(Origin: TabObject): TabShip; // @addr $65FDF8
    function FindNearestEnemyWithBearing(Origin: TabObject; var Bearing: TSphericalBearingDistance): TabShip; // @addr $65FE98
    procedure AddEnemy(Ship: TabShip); // @addr $65FF4C
    procedure AddTrackedShip(Ship: TabShip); // @addr $65FF70
    procedure SetTurnInput(Value: Double); // @addr $65FFF0
    procedure StartThrust; // @addr $66000C
    procedure StopThrust; // @addr $66001C
    procedure StartReverseThrust; // @addr $660028
    procedure Brake; // @addr $660038
    procedure FirePrimary; // @addr $660048
    procedure FireSecondary; // @addr $660258
    procedure FirePrimaryAt(Target: TabObject); // @addr $660474
    procedure FireSecondaryAt(Target: TabObject); // @addr $6604C0
    procedure SelectWeapon(Index: Integer); // @addr $66050C
    function CanFireWeapon(Index: Integer): Boolean; // @addr $660568
    function MinimumWeaponRange: Double; // @addr $6605B8
    function MaximumWeaponRange: Double; // @addr $660638
    procedure AddWeapon(Kind: Integer); // @addr $6606B0
    procedure UpdateAvoidanceDistances; // @addr $661614
    procedure UpdateObstacleSensors; // @addr $6616FC
    procedure ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean); override; // @addr $65FF7C
    procedure UpdateState; override; // @addr $6606DC
    procedure Advance; override; // @addr $66095C
    procedure UpdateVisuals; override; // @addr $660BCC
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $65FD9C
  end;

procedure ab_Ship_RepelOverlaps; // @addr $6618AC

var
  PlayerArcadeShip: TabShip = nil; // @addr $80F760
  KellerArcadeShip: TabShip = nil; // @addr $80F764
  KellerAuxiliaryShip: TabShip = nil; // @addr $80F768 Keeps Keller alive while non-nil.

var
  ArcadePaused: Boolean; // @addr $81B8D4
  ArcadePauseWithShift: Boolean; // @addr $81B8D5

implementation

uses aItem, aConst, Math, EC_Struct, aMyFunction, GR_Main, GlobalsV, SE_Process, SE_Ship2, SE_Ruins, ab_MainForm, ab_StopLine, ab_Zone, abWall, ab_ShipAI, aPlayer, aShip, aGalaxy;

{ @routine $65F794 TabShip_Create }
constructor TabShip.Create;
begin
  inherited Create;
  TurnSpeedScale := 1;
  DisruptUntilTick := 0;
  Health := 200;
  MaxHealth := 200;
  TurnSpeed := 2;
  WallCollisionEnabled := True;
  GravityEnabled := True;
  ZoneDamageEnabled := True;
  Enemies := TList.Create;
  InitialEnemies := TList.Create;
  TrackedShips := TList.Create;
  TickCounter := 0;
  ConvertedFromGameShip := False;
  SpawnGraphKey := '';
  ScriptLabel := '';
  RewardObject := nil;
  RandomRewardsDisabled := False;
end;
{ @end $65F794 }

{ @routine $65F880 TabShip_Destroy }
destructor TabShip.Destroy;
var
  Obj: TabObject;
  Ship: TabShip;
  Index, Count: Integer;
begin
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if Obj is TabShip then
    begin
      Ship := Obj as TabShip;
      if Ship.Enemies <> nil then
      begin
        while True do
        begin
          Index := Ship.Enemies.IndexOf(Self);
          if Index < 0 then Break;
          Ship.Enemies.Delete(Index);
          Index := Ship.InitialEnemies.IndexOf(Self);
          if Index >= 0 then Ship.InitialEnemies[Index] := nil;
        end;
        while True do
        begin
          Index := Ship.TrackedShips.IndexOf(Self);
          if Index < 0 then Break;
          Ship.TrackedShips[Index] := nil;
        end;
      end;
      if (Ship is TabShipAI) and ((Ship as TabShipAI).TargetShip = Self) then
        (Ship as TabShipAI).TargetShip := nil;
    end;
    Obj := Obj.Next;
  end;
  if Self = PlayerArcadeShip then PlayerArcadeShip := nil;
  if Self = KellerArcadeShip then KellerArcadeShip := nil;
  if Self = KellerAuxiliaryShip then KellerAuxiliaryShip := nil;
  if PlayerArcadeShip <> nil then
  begin
    Index := 0;
    Count := PlayerArcadeShip.Enemies.Count;
    while Index < Count do
    begin
      if TObject(PlayerArcadeShip.Enemies[Index]) is TabShipAI then Break;
      Inc(Index);
    end;
    if Index >= Count then
    begin
      PlayerArcadeShip.StopThrust;
      PlayerArcadeShip.SetTurnInput(0);
      ArcadeAutopilotEnabled := False;
      ArcadeBattleScreen.UpdateAutopilotButtons;
      ArcadeEnemiesDefeated := True;
      Obj := FirstArcadeObject;
      while Obj <> nil do
      begin
        if (Obj is TabWall) and (TabWall(Obj).Health > 0) then
          TabWall(Obj).Health := Min(20, TabWall(Obj).Health);
        Obj := Obj.Next;
      end;
      if not ArcadeKellerEncounter or (KellerArcadeShip = nil) then ArcadeBattleScreen.ShowVictory;
    end;
  end;
  if Visual <> nil then ReleaseSpaceObject(Visual);
  if OffscreenMarker <> nil then
  begin
    OffscreenMarker.Free;
    OffscreenMarker := nil;
  end;
  if OffscreenLabel <> nil then
  begin
    OffscreenLabel.Free;
    OffscreenLabel := nil;
  end;
  if Enemies <> nil then
  begin
    Enemies.Free;
    Enemies := nil;
  end;
  if InitialEnemies <> nil then
  begin
    InitialEnemies.Free;
    InitialEnemies := nil;
  end;
  if TrackedShips <> nil then
  begin
    TrackedShips.Free;
    TrackedShips := nil;
  end;
  if RewardObject <> nil then RewardObject.Free;
  RewardObject := nil;
  inherited Destroy;
end;
{ @end $65F880 }

{ @routine $65FB58 TabShip_CreateShipVisual }
procedure TabShip.CreateShipVisual(const GraphKey: WideString; Diameter: Integer);
begin
  RetainSpaceObject(Visual, CreateSpaceObjectByName('Ship2', GraphKey, Classes.Point(0, 0)));
  (Visual as TShip2SE).TailEmitIntervalMs := 10;
  Visual.Alpha := 255;
  if (Self = PlayerArcadeShip) and (ShipTail <> 0) and (ArcadeSpaceProcess.Space.AlphaShift = 0) then
    (Visual as TShip2SE).SetTailMode(1)
  else
    (Visual as TShip2SE).SetTailMode(0);
  VisualDiameter := Diameter;
  EffectOriginSpread := GiScalePixels(VisualDiameter);
  Mass := 10;
  State.PolarAngleDegrees := 0;
  State.BearingDegrees := 0;
  CollisionRadius := Diameter / 2 * 1.1;
  ZoneRadius := 0.9 * CollisionRadius;
  HasFiredWeapon := False;
end;
{ @end $65FB58 }

{ @routine $65FC9C TabShip_CreateRuinsVisual }
procedure TabShip.CreateRuinsVisual(const GraphKey: WideString; Diameter: Integer);
begin
  RetainSpaceObject(Visual, CreateSpaceObjectByName('Ruins', GraphKey, Classes.Point(0, 0)));
  TRuinsSE(Visual).KeepSize := True;
  VisualDiameter := Diameter;
  EffectOriginSpread := GiScalePixels(VisualDiameter);
  Mass := 10;
  State.PolarAngleDegrees := 0;
  State.BearingDegrees := 0;
  CollisionRadius := Diameter / 2 * 1.1;
  ZoneRadius := 0.9 * CollisionRadius;
end;
{ @end $65FC9C }

{ @routine $65FD68 TabShip_AttachVisual }
procedure TabShip.AttachVisual;
begin
  if Visual <> nil then Visual.AttachToSpace(ArcadeSpaceProcess.Space);
end;
{ @end $65FD68 }

{ @routine $65FD88 TabShip_DetachVisual }
procedure TabShip.DetachVisual;
begin
  if Visual <> nil then Visual.DetachFromSpace;
end;
{ @end $65FD88 }

{ @routine $65FD9C TabShip_QueueImageLoad }
procedure TabShip.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Index: Integer;
begin
  if Visual <> nil then Visual.QueueImageLoad(PendingLoads, Owner);
  for Index := 0 to WeaponCount - 1 do
    ab_Weapon_QueueImageLoad(@Weapons[Index], PendingLoads, Owner);
end;
{ @end $65FD9C }

{ @routine $65FDF8 TabShip_FindNearestEnemy }
function TabShip.FindNearestEnemy(Origin: TabObject): TabShip;
var
  Index: Integer;
  Ship: TabShip;
  BestDistance, Distance: Double;
begin
  Result := nil;
  BestDistance := 1e20;
  for Index := 0 to Enemies.Count - 1 do
  begin
    Ship := Enemies[Index];
    if (Ship.Health >= 1) and ((Ship.BonusTicks[arcade_effect_invisibility] <= 0) or (Ship.RevealTicks > 0)) then
    begin
      Distance := Origin.DistanceTo(Ship);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        Result := Ship;
      end;
    end;
  end;
end;
{ @end $65FDF8 }

{ @routine $65FE98 TabShip_FindNearestEnemyWithBearing }
function TabShip.FindNearestEnemyWithBearing(Origin: TabObject; var Bearing: TSphericalBearingDistance): TabShip;
var
  Index: Integer;
  Ship: TabShip;
  BestDistance: Double;
  CandidateBearing: TSphericalBearingDistance;
begin
  Result := nil;
  BestDistance := 1e20;
  for Index := 0 to Enemies.Count - 1 do
  begin
    Ship := Enemies[Index];
    if (Ship.Health >= 1) and ((Ship.BonusTicks[arcade_effect_invisibility] <= 0) or (Ship.RevealTicks > 0)) then
    begin
      CandidateBearing := Origin.BearingAndDistanceTo(Ship);
      if CandidateBearing.Distance < BestDistance then
      begin
        BestDistance := CandidateBearing.Distance;
        Bearing := CandidateBearing;
        Result := Ship;
      end;
    end;
  end;
end;
{ @end $65FE98 }

{ @routine $65FF4C TabShip_AddEnemy }
procedure TabShip.AddEnemy(Ship: TabShip);
begin
  Enemies.Add(Ship);
  InitialEnemies.Add(Ship);
end;
{ @end $65FF4C }

{ @routine $65FF70 TabShip_AddTrackedShip }
procedure TabShip.AddTrackedShip(Ship: TabShip);
begin
  TrackedShips.Add(Ship);
end;
{ @end $65FF70 }

{ @routine $65FF7C TabShip_ApplyDamage }
procedure TabShip.ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean);
begin
  if Health > 0 then
    if BonusTicks[arcade_effect_shield] > 0 then
      inherited ApplyDamage(Round(Amount * ShieldDamageScale * DamageTakenScale), Source, Disrupt)
    else
      inherited ApplyDamage(Round(Amount * DamageTakenScale), Source, Disrupt);
end;
{ @end $65FF7C }

{ @routine $65FFF0 TabShip_SetTurnInput }
procedure TabShip.SetTurnInput(Value: Double);
begin
  TurnInput := Value;
end;
{ @end $65FFF0 }

{ @routine $66000C TabShip_StartThrust }
procedure TabShip.StartThrust;
begin
  Thrust := 2.5;
end;
{ @end $66000C }

{ @routine $66001C TabShip_StopThrust }
procedure TabShip.StopThrust;
begin
  Thrust := 0;
end;
{ @end $66001C }

{ @routine $660028 TabShip_StartReverseThrust }
procedure TabShip.StartReverseThrust;
begin
  Thrust := -1.8;
end;
{ @end $660028 }

{ @routine $660038 TabShip_Brake }
procedure TabShip.Brake;
begin
  ChangeSpeed(-1);
end;
{ @end $660038 }

{ @routine $660048 TabShip_FirePrimary }
procedure TabShip.FirePrimary;
var
  Score, BestScore, Index, Candidate, BestWeapon: Integer;
  DamageScale: Single;
begin
  if (Health > 0) and (WeaponCount > 0) and (BonusTicks[arcade_effect_weapons_disabled] <= 0) then
    if (Self <> PlayerArcadeShip) or (LastPrimaryWeapon = PrimaryWeapon) or
      (WeaponSwitchDelayMs div ArcadeTickMs <= ArcadeTickCount - LastPrimaryFireTick) then
      if CanFireWeapon(PrimaryWeapon) then
      begin
        if BonusTicks[arcade_effect_invisibility] > 0 then RevealTicks := RevealAfterFiringMs div ArcadeTickMs;
        LastPrimaryWeapon := PrimaryWeapon;
        LastPrimaryFireTick := ArcadeTickCount;
        Weapons[PrimaryWeapon].LastFireTick := ArcadeTickCount;
        if not ((Galaxy <> nil) and (Galaxy.AmmoModEnabled = 1) and (Self = PlayerArcadeShip)) then
          Dec(Weapons[PrimaryWeapon].Ammo, Weapons[PrimaryWeapon].AmmoCost);
        if BonusTicks[arcade_effect_damage_boost] > 0 then DamageScale := WeaponDamageBonusScale
        else DamageScale := 1;
        DamageScale := DamageScale * WeaponDamageScale;
        ab_Weapon_Fire(@Weapons[PrimaryWeapon], Self, DamageScale);
        if (Weapons[PrimaryWeapon].Ammo < Weapons[PrimaryWeapon].AmmoCost) then
        begin
          BestScore := -1;
          BestWeapon := -1;
          Candidate := PrimaryWeapon;
          for Index := 0 to WeaponCount - 1 do
          begin
            if Weapons[Candidate].SlotData and equipment_secondary_fire = 0 then
            begin
              Score := Round(Weapons[Candidate].Ammo / Weapons[Candidate].MaxAmmo * 100);
              if CanFireWeapon(Candidate) then Inc(Score, 100);
              if Score > BestScore then
              begin
                BestScore := Score;
                BestWeapon := Candidate;
              end;
            end;
            Inc(Candidate);
            if Candidate >= WeaponCount then Candidate := 0;
          end;
          if BestWeapon >= 0 then PrimaryWeapon := BestWeapon;
        end;
        HasFiredWeapon := True;
      end;
end;
{ @end $660048 }

{ @routine $660258 TabShip_FireSecondary }
procedure TabShip.FireSecondary;
var
  Score, BestScore, Index, Candidate, BestWeapon: Integer;
  DamageScale: Single;
begin
  if (Health > 0) then
    if (WeaponCount > 0) then
    if (BonusTicks[arcade_effect_weapons_disabled] <= 0) then
    if (Self <> PlayerArcadeShip) or (LastSecondaryWeapon = SecondaryWeapon) or
      (WeaponSwitchDelayMs div ArcadeTickMs <= ArcadeTickCount - LastSecondaryFireTick) then
      if CanFireWeapon(SecondaryWeapon) then
      begin
        if BonusTicks[arcade_effect_invisibility] > 0 then RevealTicks := RevealAfterFiringMs div ArcadeTickMs;
        LastSecondaryWeapon := SecondaryWeapon;
        LastSecondaryFireTick := ArcadeTickCount;
        Weapons[SecondaryWeapon].LastFireTick := ArcadeTickCount;
        if not ((Galaxy <> nil) and (Galaxy.AmmoModEnabled = 1) and (Self = PlayerArcadeShip)) then
          Dec(Weapons[SecondaryWeapon].Ammo, Weapons[SecondaryWeapon].AmmoCost);
        if BonusTicks[arcade_effect_damage_boost] > 0 then DamageScale := WeaponDamageBonusScale
        else DamageScale := 1;
        DamageScale := DamageScale * WeaponDamageScale;
        ab_Weapon_Fire(@Weapons[SecondaryWeapon], Self, DamageScale);
        if (Self = PlayerArcadeShip) then
          if (Weapons[SecondaryWeapon].Ammo < Weapons[SecondaryWeapon].AmmoCost) then
        begin
          BestScore := -1;
          BestWeapon := -1;
          Candidate := SecondaryWeapon;
          for Index := 0 to WeaponCount - 1 do
          begin
            if Weapons[Candidate].SlotData and equipment_secondary_fire <> 0 then
            begin
              Score := Round(Weapons[Candidate].Ammo / Weapons[Candidate].MaxAmmo * 100);
              if CanFireWeapon(Candidate) then Inc(Score, 100);
              if Score > BestScore then
              begin
                BestScore := Score;
                BestWeapon := Candidate;
              end;
            end;
            Inc(Candidate);
            if Candidate >= WeaponCount then Candidate := 0;
          end;
          if BestWeapon >= 0 then SecondaryWeapon := BestWeapon;
        end;
        HasFiredWeapon := True;
      end;
end;
{ @end $660258 }

{ @routine $660474 TabShip_FirePrimaryAt }
procedure TabShip.FirePrimaryAt(Target: TabObject);
var
  Distance: Double;
begin
  if (Health <= 0) or (BonusTicks[arcade_effect_weapons_disabled] > 0) then Exit;
  Distance := DistanceTo(Target);
  if Distance <= Weapons[PrimaryWeapon].Range then FirePrimary;
end;
{ @end $660474 }

{ @routine $6604C0 TabShip_FireSecondaryAt }
procedure TabShip.FireSecondaryAt(Target: TabObject);
var
  Distance: Double;
begin
  if (Health <= 0) or (BonusTicks[arcade_effect_weapons_disabled] > 0) then Exit;
  Distance := DistanceTo(Target);
  if Distance <= Weapons[SecondaryWeapon].Range then FireSecondary;
end;
{ @end $6604C0 }

{ @routine $66050C TabShip_SelectWeapon }
procedure TabShip.SelectWeapon(Index: Integer);
begin
  if Self = PlayerArcadeShip then
  begin
    if Index < 0 then
    begin
      PrimaryWeapon := -1;
      SecondaryWeapon := -1;
      Exit;
    end;
    if Index < WeaponCount then
    begin
      if Weapons[Index].SlotData and equipment_secondary_fire = 0 then PrimaryWeapon := Index
      else SecondaryWeapon := Index;
    end;
  end
  else if PrimaryWeapon <> Index then PrimaryWeapon := Index;
end;
{ @end $66050C }

{ @routine $660568 TabShip_CanFireWeapon }
function TabShip.CanFireWeapon(Index: Integer): Boolean;
begin
  Result := False;
  if (BonusTicks[arcade_effect_weapons_disabled] <= 0) then
    if (Index >= 0) then
    if (Index < WeaponCount) then
    if (Weapons[Index].AmmoCost <= Weapons[Index].Ammo) then
    Result := ArcadeTickCount - Weapons[Index].LastFireTick >= Weapons[Index].FireIntervalTicks;
end;
{ @end $660568 }

{ @routine $6605B8 TabShip_MinimumWeaponRange }
function TabShip.MinimumWeaponRange: Double;
var
  Index: Integer;
begin
  Result := 1e20;
  for Index := 0 to WeaponCount - 1 do Result := Min(Result, Weapons[Index].Range);
end;
{ @end $6605B8 }

{ @routine $660638 TabShip_MaximumWeaponRange }
function TabShip.MaximumWeaponRange: Double;
var
  Index: Integer;
begin
  Result := 0;
  for Index := 0 to WeaponCount - 1 do Result := Max(Result, Weapons[Index].Range);
end;
{ @end $660638 }

{ @routine $6606B0 TabShip_AddWeapon }
procedure TabShip.AddWeapon(Kind: Integer);
begin
  if WeaponCount >= Length(Weapons) then Exit;
  ab_Weapon_Initialize(@Weapons[WeaponCount], Kind + 50);
  Inc(WeaponCount);
end;
{ @end $6606B0 }

{ @routine $6606DC TabShip_UpdateState }
procedure TabShip.UpdateState;
var
  Turn: Double;
  Index: Integer;
begin
  if BonusTicks[arcade_effect_ammo_recharge] > 0 then
  begin
    for Index := 0 to WeaponCount - 1 do
      Weapons[Index].Ammo := Min(Weapons[Index].Ammo + Round(Weapons[Index].RechargePerTick * AmmoRechargeScale * AmmoRechargeBonusScale), Weapons[Index].MaxAmmo);
  end
  else
  begin
    for Index := 0 to WeaponCount - 1 do
      Weapons[Index].Ammo := Min(Weapons[Index].Ammo + Round(Weapons[Index].RechargePerTick * AmmoRechargeScale), Weapons[Index].MaxAmmo);
  end;
  if TurnInput <> 0 then
  begin
    Turn := TurnInput;
    if -TurnSpeed * TurnSpeedScale > Turn then Turn := -TurnSpeed * TurnSpeedScale
    else if TurnSpeed * TurnSpeedScale < Turn then Turn := TurnSpeed * TurnSpeedScale;
    State.BearingDegrees := WrapHeadingDegrees(State.BearingDegrees + Turn);
  end;
  inherited UpdateState;
  SpeedScale := SpeedScale * MovementScale;
  TurnSpeedScale := TurnSpeedScale * MovementScale;
  if BonusTicks[arcade_effect_speed_boost] > 0 then SpeedScale := SpeedScale * SpeedBonusScale;
  if BonusTicks[arcade_effect_slowdown] > 0 then SpeedScale := SpeedScale * SpeedPenaltyScale;
  if BonusTicks[arcade_effect_speed_boost] > 0 then TurnSpeedScale := TurnSpeedScale * SpeedBonusScale;
  if BonusTicks[arcade_effect_slowdown] > 0 then TurnSpeedScale := TurnSpeedScale * SpeedPenaltyScale;
end;
{ @end $6606DC }

{ @routine $66095C TabShip_Advance }
procedure TabShip.Advance;
var
  Index: Integer;
  Zone: PabZone;
begin
  inherited Advance;
  if Health = 0 then
  begin
    Velocity := MakePointF(0, 0);
    Thrust := 0;
  end
  else
  begin
    for Index := Low(BonusTicks) to High(BonusTicks) do
      if BonusTicks[Index] > 0 then Dec(BonusTicks[Index]);
    if BonusTicks[arcade_effect_regeneration] > 0 then Health := Min(MaxHealth, Health + RegenerationHealthPerTick);
    if 0.01 <= RegenerationRate then
    begin
      if RegenerationRate < 10 then
        if TickCounter mod Round(10 / RegenerationRate) = 0 then
          Health := Min(MaxHealth, Health + RegenerationHealthPerTick);
      if RegenerationRate >= 10 then
        Health := Min(MaxHealth, Health + Round(RegenerationHealthPerTick * RegenerationRate / 10));
    end;
    if (Self = PlayerArcadeShip) and (TickCounter mod 10 = 0) then
      if GetPlayer <> nil then
        if GetPlayer.CountActiveArtefacts(artefact_repair_robot) > 0 then
          Health := Min(MaxHealth, Health + RegenerationHealthPerTick * GetPlayer.CountActiveArtefacts(artefact_repair_robot));
    if (BonusTicks[arcade_effect_invisibility] > 0) and (RevealTicks > 0) then Dec(RevealTicks);
  end;
  UpdateObstacleSensors;
  if ArcadeTickCount and $40 = 0 then
    if ab_Zone_IsInsideKind10(State.LongitudeDegrees, State.PolarAngleDegrees) then
      if WallCollisionEnabled then
      begin
        Zone := ab_Zone_FindNearestOutside(State.LongitudeDegrees, State.PolarAngleDegrees);
        if Zone <> nil then
        begin
          State.LongitudeDegrees := Zone.Longitude;
          State.PolarAngleDegrees := Zone.PolarAngle;
        end;
      end;
  TickCounter := (TickCounter + 1) mod 10000;
end;
{ @end $66095C }

{ @routine $660BCC TabShip_UpdateVisuals }
procedure TabShip.UpdateVisuals;
var
  ViewSize: TPoint;
  HorizonAlpha: Double;
  Alpha: Integer;
  InvisibilityAlpha: Single;
  Position: TVector3D;
  Bearing: TSphericalBearingDistance;
begin
  inherited UpdateVisuals;
  Position := GetWorldPosition;
  Position := ProjectPointByMatrix(SphereProjectionMatrix, Position);
  if (Visual <> nil) and Visual.IsAttachedToSpace then
  begin
    if (Position.Z <= SphereHorizonDepth) and (Position.Z > SphereFarHorizonDepth) then
      HorizonAlpha := (SphereHorizonDepth - Position.Z) / (SphereHorizonDepth - SphereFarHorizonDepth)
    else if (Position.Z > SphereHorizonDepth) and (Position.Z < SphereNearHorizonDepth) then
      HorizonAlpha := (SphereHorizonDepth - Position.Z) / (SphereHorizonDepth - SphereNearHorizonDepth)
    else HorizonAlpha := 1;
    Visual.Pos := MakePointF(Position.X, Position.Y);
    if Health > 0 then
    begin
      if (BonusTicks[arcade_effect_invisibility] > 0) and (RevealTicks <= 0) then
      begin
        if Self <> PlayerArcadeShip then InvisibilityAlpha := OtherInvisibleAlpha
        else InvisibilityAlpha := PlayerInvisibleAlpha;
      end
      else InvisibilityAlpha := 1;
      if not IsDepthBeforeSphereHorizon(Position.Z) then
      begin
        Alpha := Round(128 * InvisibilityAlpha * HorizonAlpha);
        if (Visual.Size.X <> EffectOriginSpread div 2) and
          ((Self <> KellerArcadeShip) or (Galaxy = nil) or (Galaxy.KellerLeaveTurn = 0)) then
        begin
          Visual.DetachFromSpace;
          Visual.ObjectSize := Classes.Point(EffectOriginSpread div 2, EffectOriginSpread div 2);
          Visual.AttachToSpace(ArcadeSpaceProcess.Space);
        end;
        Visual.SetDepth(ShipBackDepth);
        if Visual is TShip2SE then TShip2SE(Visual).SetTailDepth(ShipTailBackDepth);
      end
      else
      begin
        Alpha := Round(255 * InvisibilityAlpha * HorizonAlpha);
        if Visual.Size.X <> EffectOriginSpread then
        begin
          Visual.DetachFromSpace;
          Visual.ObjectSize := Classes.Point(EffectOriginSpread, EffectOriginSpread);
          Visual.AttachToSpace(ArcadeSpaceProcess.Space);
        end;
        Visual.SetDepth(ShipFrontDepth);
        if Visual is TShip2SE then TShip2SE(Visual).SetTailDepth(ShipTailFrontDepth);
      end;
    end
    else
    begin
      if Self <> KellerArcadeShip then
      begin
        Alpha := Max(0, Visual.Alpha - 10);
        if Visual.Alpha < 10 then Visual.DetachFromSpace;
      end
      else Alpha := Visual.Alpha;
    end;
    if ArcadeViewMode in [1, 3] then
      Alpha := Round(RemapClamped(SphereCameraDistance, SphereRadius + SphereNearCameraOffset,
        (SphereRadius + SphereFarCameraOffset) / 3, Alpha, 0));
    Visual.Alpha := Alpha;
  end;
  if Visual is TShip2SE then
  begin
    Visual.Angle := HeadingDegreesToByte(GetProjectedHeading(Position));
    (Visual as TShip2SE).OffsetTailsAlongHeading(RandomIntRange(0, 1) * 0.3 + 2);
    (Visual as TShip2SE).SetTailsEmitting(Thrust <> 0);
    if (Visual.Angle >= 254) or (Visual.Angle <= 2) then Visual.Angle := 0;
  end;
  if PlayerArcadeShip <> nil then
    if OffscreenMarker <> nil then
    begin
      Position := PlayerArcadeShip.GetWorldPosition;
      Position := ProjectPointByMatrix(SphereProjectionMatrix, Position);
      Bearing := PlayerArcadeShip.BearingAndDistanceTo(Self);
      Bearing.BearingDeltaDegrees := WrapHeadingDegrees(PlayerArcadeShip.GetProjectedHeading(Position) + Bearing.BearingDeltaDegrees);
      if Bearing.BearingDeltaDegrees > 180 then Bearing.BearingDeltaDegrees := Bearing.BearingDeltaDegrees - 360;
      ViewSize := ArcadeBattleScreen.WorldPanel.ClientSize;
      if (Bearing.BearingDeltaDegrees >= 0) and (Bearing.BearingDeltaDegrees <= 45) then
        OffscreenMarker.Pos := MakePointF((ViewSize.X / 2 - 30) * (Bearing.BearingDeltaDegrees / 45), -(ViewSize.Y div 2) + 30)
      else if (Bearing.BearingDeltaDegrees >= -45) and (Bearing.BearingDeltaDegrees < 0) then
        OffscreenMarker.Pos := MakePointF((ViewSize.X / 2 - 30) * (Bearing.BearingDeltaDegrees / 45), -(ViewSize.Y div 2) + 30)
      else if Bearing.BearingDeltaDegrees >= 135 then
        OffscreenMarker.Pos := MakePointF((180 - Bearing.BearingDeltaDegrees) / 45 * (ViewSize.X / 2 - 30), ViewSize.Y div 2 - 30)
      else if Bearing.BearingDeltaDegrees <= -135 then
        OffscreenMarker.Pos := MakePointF(-(180 + Bearing.BearingDeltaDegrees) / 45 * (ViewSize.X / 2 - 30), ViewSize.Y div 2 - 30)
      else if (Bearing.BearingDeltaDegrees >= 45) and (Bearing.BearingDeltaDegrees <= 90) then
        OffscreenMarker.Pos := MakePointF(ViewSize.X div 2 - 30, (ViewSize.Y / 2 - 30) * ((Bearing.BearingDeltaDegrees - 90) / 45))
      else if (Bearing.BearingDeltaDegrees >= 90) and (Bearing.BearingDeltaDegrees <= 135) then
        OffscreenMarker.Pos := MakePointF(ViewSize.X div 2 - 30, (ViewSize.Y / 2 - 30) * ((Bearing.BearingDeltaDegrees - 90) / 45))
      else if (Bearing.BearingDeltaDegrees <= -45) and (Bearing.BearingDeltaDegrees >= -90) then
        OffscreenMarker.Pos := MakePointF(-(ViewSize.X div 2) + 30, (-Bearing.BearingDeltaDegrees - 45 + -45) / 45 * (ViewSize.Y / 2 - 30))
      else if (Bearing.BearingDeltaDegrees <= -90) and (Bearing.BearingDeltaDegrees >= -135) then
        OffscreenMarker.Pos := MakePointF(-(ViewSize.X div 2) + 30, (ViewSize.Y / 2 - 30) * ((-Bearing.BearingDeltaDegrees - 90) / 45))
      else OffscreenMarker.Pos := MakePointF(100, 100);
      OffscreenLabel.Pos := TruncatePointF(OffscreenMarker.Position);
      Bearing := BearingAndDistanceTo(PlayerArcadeShip);
      if PointDistanceSquared(OffscreenMarker.Position, Visual.Position) < 0.001 then OffscreenMarker.Angle := 0
      else OffscreenMarker.Angle := HeadingDegreesToByte(WrapHeadingDegrees(PointBearingDegrees(OffscreenMarker.Position, Visual.Position) - Bearing.BearingDeltaDegrees));
    end;
end;
{ @end $660BCC }

{ @routine $661614 TabShip_UpdateAvoidanceDistances }
procedure TabShip.UpdateAvoidanceDistances;
begin
  if TurnSpeed = 0 then
  begin
    OuterAvoidanceDistance := 30;
    MiddleAvoidanceDistance := 30;
    InnerAvoidanceDistance := 30;
    Exit;
  end;
  OuterAvoidanceDistance := 180 / (TurnSpeed * TurnSpeedScale) * (5 * MaxSpeed) / Pi * 2;
  MiddleAvoidanceDistance := 180 / (TurnSpeed * TurnSpeedScale) * (5 * MaxSpeed / 4) / Pi * 2;
  InnerAvoidanceDistance := 60;
end;
{ @end $661614 }

{ @routine $6616FC TabShip_UpdateObstacleSensors }
procedure TabShip.UpdateObstacleSensors;
var
  Index: Integer;
begin
  if ArcadeTickCount < NextObstacleScanTick then Exit;
  NextObstacleScanTick := ArcadeTickCount + 4;
  UpdateAvoidanceDistances;
  ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, State.BearingDegrees), ObstacleDistances[0], ObstacleDistances[4]);
  ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, WrapHeadingDegrees(State.BearingDegrees + 45)), ObstacleDistances[1], ObstacleDistances[5]);
  ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, WrapHeadingDegrees(State.BearingDegrees + 90)), ObstacleDistances[2], ObstacleDistances[6]);
  ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, WrapHeadingDegrees(State.BearingDegrees + 90 + 45)), ObstacleDistances[3], ObstacleDistances[7]);
  for Index := Low(ObstacleDistances) to High(ObstacleDistances) do
    if ObstacleDistances[Index] > OuterAvoidanceDistance then ObstacleLevels[Index] := 0
    else if ObstacleDistances[Index] > MiddleAvoidanceDistance then ObstacleLevels[Index] := 1
    else if ObstacleDistances[Index] > InnerAvoidanceDistance then ObstacleLevels[Index] := 2
    else ObstacleLevels[Index] := 3;
end;
{ @end $6616FC }

{ @routine $6618AC ab_Ship_RepelOverlaps }
procedure ab_Ship_RepelOverlaps;
var
  Obj, Other: TabObject;
  Bearing, Distance, Speed: Double;
begin
  if (ArcadeTickCount and 1) <> 0 then Exit;
  Obj := FirstArcadeObject;
  while Obj <> nil do
  begin
    if (Obj is TabHit) and (TabHit(Obj).Health > 0) and Obj.Active and not (Obj is TabWall) then
    begin
      Other := FirstArcadeObject;
      while Other <> nil do
      begin
        if (Obj <> Other) and (Other is TabHit) and (TabHit(Other).Health > 0)
          and Other.Active and ((not (Other is TabWall)) or (Other.ZoneRadius > 1)) then
        begin
          ComputeSphericalBearingAndDistance(Obj.State.LongitudeDegrees, Obj.State.PolarAngleDegrees, 0,
            Other.State.LongitudeDegrees, Other.State.PolarAngleDegrees, SphereRadius, Bearing, Distance);
          if (Obj.ZoneRadius + Other.ZoneRadius > Distance) and (Distance > 0) then
          begin
            Speed := Max(1, Sqrt(Sqr(Obj.Velocity.X) + Sqr(Obj.Velocity.Y)) / 2);
            Bearing := HeadingDegreesToRadians(WrapHeadingDegrees(Bearing + 180));
            Obj.Velocity.X := Sin(Bearing) * Speed;
            Obj.Velocity.Y := -Cos(Bearing) * Speed;
            if Obj is TabShipAI then (Obj as TabShipAI).NoticeCollision;
          end;
        end;
        Other := Other.Next;
      end;
    end;
    Obj := Obj.Next;
  end;
end;
{ @end $6618AC }

end.
