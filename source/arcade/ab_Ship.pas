unit ab_Ship;
// Unit bracket (inferred): .text 0x00501E90..0x005049D5; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, GI_MessageLoop, GI_Tail, ab_Global, SE_Space, ab_Object, ab_Hit, ab_W;

type
  TabShip = class(TabHit) // @size $2E0
  public
    Visual: TObjectSE; // @offset $D0
    OffscreenMarker: TObjectSE; // @offset $D8
    OffscreenLabel: TObjectGI; // @offset $DC
    VisualDiameter: Integer; // @offset $D4
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
    ConvertedFromGameShip: Boolean; // @offset $2C0 Marks a converted game ship ($61F3FA); preserves copied health and weapons during encounter setup.
    RandomRewardsDisabled: Boolean; // @offset $2C1 Scripted ships disable random rewards unless the reward argument is -1 ($61F20D).
    SpawnGraphKey: WideString; // @offset $2C4 CreateABShip graph argument; consumed by PopulateScriptedEncounter.
    ScriptLabel: WideString; // @offset $2C8 Label included in LabeledShipKilledInAB / LabeledShipSurvivedInAB events.
    RewardObject: TObject; // @offset $2CC Owned until transferred as a reward. The script API also accepts unchecked objects ($61F231/$61F23F).
    Team: Byte; // @offset $2D0 Scripted encounter allegiance; 1 joins the player.
    HealthScalePercent: Integer; // @offset $2D4 Scripted encounter health multiplier.
    DamageScalePercent: Integer; // @offset $2D8 Scripted encounter weapon damage multiplier.
    HasFiredWeapon: Boolean; // @offset $2DC Set by firing; retained for the no-shots victory check.
    constructor Create; // @addr $501F14
    destructor Destroy; override; // @addr $50203C
    procedure CreateShipVisual(const GraphKey: WideString; Diameter: Integer); // @addr $5023E4
    procedure CreateRuinsVisual(const GraphKey: WideString; Diameter: Integer); // @addr $50255C
    procedure AttachVisual; // @addr $50264C
    procedure DetachVisual; // @addr $50267C
    function FindNearestEnemy(Origin: TabObject): TabShip; // @addr $502714
    function FindNearestEnemyWithBearing(Origin: TabObject; var Bearing: TSphericalBearingDistance): TabShip; // @addr $5027C4
    procedure AddEnemy(Ship: TabShip); // @addr $50288C
    procedure AddTrackedShip(Ship: TabShip); // @addr $5028C0
    procedure SetTurnInput(Value: Double); // @addr $502960
    procedure StartThrust; // @addr $502984
    procedure StopThrust; // @addr $5029A0
    procedure StartReverseThrust; // @addr $5029B8
    procedure Brake; // @addr $5029D4
    procedure FirePrimary; // @addr $5029F0
    procedure FireSecondary; // @addr $502CB8
    procedure FirePrimaryAt(Target: TabObject); // @addr $502F90
    procedure FireSecondaryAt(Target: TabObject); // @addr $502FF0
    procedure SelectWeapon(Index: Integer); // @addr $503050
    function CanFireWeapon(Index: Integer): Boolean; // @addr $5030E8
    function MinimumWeaponRange: Double; // @addr $503174
    function MaximumWeaponRange: Double; // @addr $503208
    procedure AddWeapon(Kind: Integer); // @addr $503298
    procedure UpdateAvoidanceDistances; // @addr $504424
    procedure UpdateObstacleSensors; // @addr $50453C
    procedure ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean); override; // @addr $5028E4
    procedure UpdateState; override; // @addr $5032E0
    procedure Advance; override; // @addr $50361C
    procedure UpdateVisuals; override; // @addr $50395C
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $5026A0
  end;

procedure ab_Ship_RepelOverlaps; // @addr $50476C

var
  PlayerArcadeShip: TabShip = nil; // @addr $87AD00
  KellerArcadeShip: TabShip = nil; // @addr $87AD04
  KellerAuxiliaryShip: TabShip = nil; // @addr $87AD08 Keeps Keller alive while present; exact visual role under review.

var
  ArcadePaused: Boolean; // @addr $88A414
  ArcadePauseWithShift: Boolean; // @addr $88A415

implementation

uses aItem, aConst, Math, EC_Struct, aMyFunction, GR_Main, GlobalsV, SE_Process, SE_Ship2, SE_Ruins, ab_MainForm, ab_StopLine, ab_Zone, abWall, ab_ShipAI, aPlayer, aShip, aGalaxy;

{ @routine $501F14 TabShip_Create }
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
{ @end $501F14 }

{ @routine $50203C TabShip_Destroy }
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
{ @end $50203C }

{ @routine $5023E4 TabShip_CreateShipVisual }
procedure TabShip.CreateShipVisual(const GraphKey: WideString; Diameter: Integer);
begin
  RetainSpaceObject(Visual, CreateSpaceObjectByName('Ship2', GraphKey, Classes.Point(0, 0)));
  (Visual as TShip2SE).TailEmitIntervalMs := 10;
  Visual.SetAlpha(255);
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
{ @end $5023E4 }

{ @routine $50255C TabShip_CreateRuinsVisual }
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
{ @end $50255C }

{ @routine $50264C TabShip_AttachVisual }
procedure TabShip.AttachVisual;
begin
  if Visual <> nil then Visual.AttachToSpace(ArcadeSpaceProcess.Space);
end;
{ @end $50264C }

{ @routine $50267C TabShip_DetachVisual }
procedure TabShip.DetachVisual;
begin
  if Visual <> nil then Visual.DetachFromSpace;
end;
{ @end $50267C }

{ @routine $5026A0 TabShip_QueueImageLoad }
procedure TabShip.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
var
  Index: Integer;
begin
  if Visual <> nil then Visual.QueueImageLoad(PendingLoads, Owner);
  for Index := 0 to WeaponCount - 1 do
    ab_Weapon_QueueImageLoad(@Weapons[Index], PendingLoads, Owner);
end;
{ @end $5026A0 }

{ @routine $502714 TabShip_FindNearestEnemy }
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
    if (Ship.Health >= 1) and ((Ship.BonusTicks[abkInvisibility] <= 0) or (Ship.RevealTicks > 0)) then
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
{ @end $502714 }

{ @routine $5027C4 TabShip_FindNearestEnemyWithBearing }
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
    if (Ship.Health >= 1) and ((Ship.BonusTicks[abkInvisibility] <= 0) or (Ship.RevealTicks > 0)) then
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
{ @end $5027C4 }

{ @routine $50288C TabShip_AddEnemy }
procedure TabShip.AddEnemy(Ship: TabShip);
begin
  Enemies.Add(Ship);
  InitialEnemies.Add(Ship);
end;
{ @end $50288C }

{ @routine $5028C0 TabShip_AddTrackedShip }
procedure TabShip.AddTrackedShip(Ship: TabShip);
begin
  TrackedShips.Add(Ship);
end;
{ @end $5028C0 }

{ @routine $5028E4 TabShip_ApplyDamage }
procedure TabShip.ApplyDamage(Amount: Integer; Source: TabObject; Disrupt: Boolean);
begin
  if Health > 0 then
    if BonusTicks[abkShield] > 0 then
      inherited ApplyDamage(Round(Amount * ShieldDamageScale * DamageTakenScale), Source, Disrupt)
    else
      inherited ApplyDamage(Round(Amount * DamageTakenScale), Source, Disrupt);
end;
{ @end $5028E4 }

{ @routine $502960 TabShip_SetTurnInput }
procedure TabShip.SetTurnInput(Value: Double);
begin
  TurnInput := Value;
end;
{ @end $502960 }

{ @routine $502984 TabShip_StartThrust }
procedure TabShip.StartThrust;
begin
  Thrust := 2.5;
end;
{ @end $502984 }

{ @routine $5029A0 TabShip_StopThrust }
procedure TabShip.StopThrust;
begin
  Thrust := 0;
end;
{ @end $5029A0 }

{ @routine $5029B8 TabShip_StartReverseThrust }
procedure TabShip.StartReverseThrust;
begin
  Thrust := -1.8;
end;
{ @end $5029B8 }

{ @routine $5029D4 TabShip_Brake }
procedure TabShip.Brake;
begin
  ChangeSpeed(-1);
end;
{ @end $5029D4 }

{ @routine $5029F0 TabShip_FirePrimary }
procedure TabShip.FirePrimary;
var
  Score, BestScore, Index, Candidate, BestWeapon: Integer;
  DamageScale: Single;
begin
  if (Health > 0) and (WeaponCount > 0) and (BonusTicks[abkWeaponLock] <= 0) then
    if (Self <> PlayerArcadeShip) or (LastPrimaryWeapon = PrimaryWeapon) or
      (WeaponSwitchDelayMs div ArcadeTickMs <= ArcadeTickCount - LastPrimaryFireTick) then
      if CanFireWeapon(PrimaryWeapon) then
      begin
        if BonusTicks[abkInvisibility] > 0 then RevealTicks := RevealAfterFiringMs div ArcadeTickMs;
        LastPrimaryWeapon := PrimaryWeapon;
        LastPrimaryFireTick := ArcadeTickCount;
        Weapons[PrimaryWeapon].LastFireTick := ArcadeTickCount;
        if not ((Galaxy <> nil) and (Galaxy.AmmoModEnabled = 1) and (Self = PlayerArcadeShip)) then
          Dec(Weapons[PrimaryWeapon].Ammo, Weapons[PrimaryWeapon].AmmoCost);
        if BonusTicks[abkDamage] > 0 then DamageScale := WeaponDamageBonusScale
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
            if Weapons[Candidate].SlotData and EquipmentSecondaryFireFlag = 0 then
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
{ @end $5029F0 }

{ @routine $502CB8 TabShip_FireSecondary }
procedure TabShip.FireSecondary;
var
  Score, BestScore, Index, Candidate, BestWeapon: Integer;
  DamageScale: Single;
begin
  if (Health > 0) and (WeaponCount > 0) and (BonusTicks[abkWeaponLock] <= 0) then
    if (Self <> PlayerArcadeShip) or (LastSecondaryWeapon = SecondaryWeapon) or
      (WeaponSwitchDelayMs div ArcadeTickMs <= ArcadeTickCount - LastSecondaryFireTick) then
      if CanFireWeapon(SecondaryWeapon) then
      begin
        if BonusTicks[abkInvisibility] > 0 then RevealTicks := RevealAfterFiringMs div ArcadeTickMs;
        LastSecondaryWeapon := SecondaryWeapon;
        LastSecondaryFireTick := ArcadeTickCount;
        Weapons[SecondaryWeapon].LastFireTick := ArcadeTickCount;
        if not ((Galaxy <> nil) and (Galaxy.AmmoModEnabled = 1) and (Self = PlayerArcadeShip)) then
          Dec(Weapons[SecondaryWeapon].Ammo, Weapons[SecondaryWeapon].AmmoCost);
        if BonusTicks[abkDamage] > 0 then DamageScale := WeaponDamageBonusScale
        else DamageScale := 1;
        DamageScale := DamageScale * WeaponDamageScale;
        ab_Weapon_Fire(@Weapons[SecondaryWeapon], Self, DamageScale);
        if (Self = PlayerArcadeShip) and (Weapons[SecondaryWeapon].Ammo < Weapons[SecondaryWeapon].AmmoCost) then
        begin
          BestScore := -1;
          BestWeapon := -1;
          Candidate := SecondaryWeapon;
          for Index := 0 to WeaponCount - 1 do
          begin
            if Weapons[Candidate].SlotData and EquipmentSecondaryFireFlag <> 0 then
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
{ @end $502CB8 }

{ @routine $502F90 TabShip_FirePrimaryAt }
procedure TabShip.FirePrimaryAt(Target: TabObject);
var
  Distance: Double;
begin
  if (Health > 0) and (BonusTicks[abkWeaponLock] <= 0) then
  begin
    Distance := DistanceTo(Target);
    if Distance <= Weapons[PrimaryWeapon].Range then FirePrimary;
  end;
end;
{ @end $502F90 }

{ @routine $502FF0 TabShip_FireSecondaryAt }
procedure TabShip.FireSecondaryAt(Target: TabObject);
var
  Distance: Double;
begin
  if (Health > 0) and (BonusTicks[abkWeaponLock] <= 0) then
  begin
    Distance := DistanceTo(Target);
    if Distance <= Weapons[SecondaryWeapon].Range then FireSecondary;
  end;
end;
{ @end $502FF0 }

{ @routine $503050 TabShip_SelectWeapon }
procedure TabShip.SelectWeapon(Index: Integer);
begin
  if Self = PlayerArcadeShip then
  begin
    if Index < 0 then
    begin
      PrimaryWeapon := -1;
      SecondaryWeapon := -1;
    end
    else if Index < WeaponCount then
    begin
      if Weapons[Index].SlotData and EquipmentSecondaryFireFlag = 0 then PrimaryWeapon := Index
      else SecondaryWeapon := Index;
    end;
  end
  else if PrimaryWeapon <> Index then PrimaryWeapon := Index;
end;
{ @end $503050 }

{ @routine $5030E8 TabShip_CanFireWeapon }
function TabShip.CanFireWeapon(Index: Integer): Boolean;
begin
  Result := False;
  if (BonusTicks[abkWeaponLock] <= 0) and (Index >= 0) and (Index < WeaponCount) and
    (Weapons[Index].AmmoCost <= Weapons[Index].Ammo) then
    Result := ArcadeTickCount - Weapons[Index].LastFireTick >= Weapons[Index].FireIntervalTicks;
end;
{ @end $5030E8 }

{ @routine $503174 TabShip_MinimumWeaponRange }
function TabShip.MinimumWeaponRange: Double;
var
  Index: Integer;
begin
  Result := 1e20;
  for Index := 0 to WeaponCount - 1 do Result := Min(Result, Weapons[Index].Range);
end;
{ @end $503174 }

{ @routine $503208 TabShip_MaximumWeaponRange }
function TabShip.MaximumWeaponRange: Double;
var
  Index: Integer;
begin
  Result := 0;
  for Index := 0 to WeaponCount - 1 do Result := Max(Result, Weapons[Index].Range);
end;
{ @end $503208 }

{ @routine $503298 TabShip_AddWeapon }
procedure TabShip.AddWeapon(Kind: Integer);
begin
  if WeaponCount < 5 then
  begin
    ab_Weapon_Initialize(@Weapons[WeaponCount], Kind + 50);
    Inc(WeaponCount);
  end;
end;
{ @end $503298 }

{ @routine $5032E0 TabShip_UpdateState }
procedure TabShip.UpdateState;
var
  Turn: Double;
  Index: Integer;
begin
  if BonusTicks[abkRecharge] > 0 then
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
  if BonusTicks[abkSpeed] > 0 then SpeedScale := SpeedScale * SpeedBonusScale;
  if BonusTicks[abkSlow] > 0 then SpeedScale := SpeedScale * SpeedPenaltyScale;
  if BonusTicks[abkSpeed] > 0 then TurnSpeedScale := TurnSpeedScale * SpeedBonusScale;
  if BonusTicks[abkSlow] > 0 then TurnSpeedScale := TurnSpeedScale * SpeedPenaltyScale;
end;
{ @end $5032E0 }

{ @routine $50361C TabShip_Advance }
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
    if BonusTicks[abkRegeneration] > 0 then Health := Min(MaxHealth, Health + RegenerationHealthPerTick);
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
        if GetPlayer.CountActiveArtefacts(t_ArtefactDroid) > 0 then
          Health := Min(MaxHealth, Health + RegenerationHealthPerTick * GetPlayer.CountActiveArtefacts(t_ArtefactDroid));
    if (BonusTicks[abkInvisibility] > 0) and (RevealTicks > 0) then Dec(RevealTicks);
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
{ @end $50361C }

{ @routine $50395C TabShip_UpdateVisuals }
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
    Visual.SetPosition(MakePointF(Position.X, Position.Y));
    if Health > 0 then
    begin
      if (BonusTicks[abkInvisibility] > 0) and (RevealTicks <= 0) then
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
          Visual.SetSize(Classes.Point(EffectOriginSpread div 2, EffectOriginSpread div 2));
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
          Visual.SetSize(Classes.Point(EffectOriginSpread, EffectOriginSpread));
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
        Alpha := Max(0, Visual.GetAlpha - 10);
        if Visual.GetAlpha < 10 then Visual.DetachFromSpace;
      end
      else Alpha := Visual.GetAlpha;
    end;
    if ArcadeViewMode in [1, 3] then
      Alpha := Round(RemapClamped(SphereCameraDistance, SphereRadius + SphereNearCameraOffset,
        (SphereRadius + SphereFarCameraOffset) / 3, Alpha, 0));
    Visual.SetAlpha(Alpha);
  end;
  if Visual is TShip2SE then
  begin
    Visual.SetAngle(HeadingDegreesToByte(GetProjectedHeading(Position)));
    (Visual as TShip2SE).OffsetTailsAlongHeading(RandomIntRange(0, 1) * 0.3 + 2);
    (Visual as TShip2SE).SetTailsEmitting(Thrust <> 0);
    if (Visual.GetAngle >= 254) or (Visual.GetAngle <= 2) then Visual.SetAngle(0);
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
        OffscreenMarker.SetPosition(MakePointF((ViewSize.X / 2 - 30) * (Bearing.BearingDeltaDegrees / 45), -(ViewSize.Y div 2) + 30))
      else if (Bearing.BearingDeltaDegrees >= -45) and (Bearing.BearingDeltaDegrees < 0) then
        OffscreenMarker.SetPosition(MakePointF((ViewSize.X / 2 - 30) * (Bearing.BearingDeltaDegrees / 45), -(ViewSize.Y div 2) + 30))
      else if Bearing.BearingDeltaDegrees >= 135 then
        OffscreenMarker.SetPosition(MakePointF((180 - Bearing.BearingDeltaDegrees) / 45 * (ViewSize.X / 2 - 30), ViewSize.Y div 2 - 30))
      else if Bearing.BearingDeltaDegrees <= -135 then
        OffscreenMarker.SetPosition(MakePointF(-(180 + Bearing.BearingDeltaDegrees) / 45 * (ViewSize.X / 2 - 30), ViewSize.Y div 2 - 30))
      else if (Bearing.BearingDeltaDegrees >= 45) and (Bearing.BearingDeltaDegrees <= 90) then
        OffscreenMarker.SetPosition(MakePointF(ViewSize.X div 2 - 30, (ViewSize.Y / 2 - 30) * ((Bearing.BearingDeltaDegrees - 90) / 45)))
      else if (Bearing.BearingDeltaDegrees >= 90) and (Bearing.BearingDeltaDegrees <= 135) then
        OffscreenMarker.SetPosition(MakePointF(ViewSize.X div 2 - 30, (ViewSize.Y / 2 - 30) * ((Bearing.BearingDeltaDegrees - 90) / 45)))
      else if (Bearing.BearingDeltaDegrees <= -45) and (Bearing.BearingDeltaDegrees >= -90) then
        OffscreenMarker.SetPosition(MakePointF(-(ViewSize.X div 2) + 30, (-Bearing.BearingDeltaDegrees - 45 + -45) / 45 * (ViewSize.Y / 2 - 30)))
      else if (Bearing.BearingDeltaDegrees <= -90) and (Bearing.BearingDeltaDegrees >= -135) then
        OffscreenMarker.SetPosition(MakePointF(-(ViewSize.X div 2) + 30, (ViewSize.Y / 2 - 30) * ((-Bearing.BearingDeltaDegrees - 90) / 45)))
      else OffscreenMarker.SetPosition(MakePointF(100, 100));
      OffscreenLabel.SetPosition(TruncatePointF(OffscreenMarker.Position));
      Bearing := BearingAndDistanceTo(PlayerArcadeShip);
      if PointDistanceSquared(OffscreenMarker.Position, Visual.Position) < 0.001 then OffscreenMarker.SetAngle(0)
      else OffscreenMarker.SetAngle(HeadingDegreesToByte(WrapHeadingDegrees(PointBearingDegrees(OffscreenMarker.Position, Visual.Position) - Bearing.BearingDeltaDegrees)));
    end;
end;
{ @end $50395C }

{ @routine $504424 TabShip_UpdateAvoidanceDistances }
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
{ @end $504424 }

{ @routine $50453C TabShip_UpdateObstacleSensors }
procedure TabShip.UpdateObstacleSensors;
var
  Index: Integer;
begin
  if ArcadeTickCount >= NextObstacleScanTick then
  begin
    NextObstacleScanTick := ArcadeTickCount + 4;
    UpdateAvoidanceDistances;
    ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, State.BearingDegrees), ObstacleDistances[0], ObstacleDistances[4]);
    ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, WrapHeadingDegrees(State.BearingDegrees + 45)), ObstacleDistances[1], ObstacleDistances[5]);
    ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, WrapHeadingDegrees(State.BearingDegrees + 90)), ObstacleDistances[2], ObstacleDistances[6]);
    ab_StopLine_GetDistances(MakeSphericalBearingState(State.LongitudeDegrees, State.PolarAngleDegrees, WrapHeadingDegrees(State.BearingDegrees + 90 + 45)), ObstacleDistances[3], ObstacleDistances[7]);
    for Index := 0 to 7 do
      if ObstacleDistances[Index] > OuterAvoidanceDistance then ObstacleLevels[Index] := 0
      else if ObstacleDistances[Index] > MiddleAvoidanceDistance then ObstacleLevels[Index] := 1
      else if ObstacleDistances[Index] > InnerAvoidanceDistance then ObstacleLevels[Index] := 2
      else ObstacleLevels[Index] := 3;
  end;
end;
{ @end $50453C }

{ @routine $50476C ab_Ship_RepelOverlaps }
procedure ab_Ship_RepelOverlaps;
var
  Obj, Other: TabObject;
  Bearing, Distance, Speed: Double;
begin
  if (ArcadeTickCount and 1) = 0 then
  begin
    Obj := FirstArcadeObject;
    while Obj <> nil do
    begin
      if (Obj is TabHit) and (TabHit(Obj).Health > 0) then
        if Obj.Active then
          if not (Obj is TabWall) then
          begin
            Other := FirstArcadeObject;
            while Other <> nil do
            begin
              if (Obj <> Other) and (Other is TabHit) and (TabHit(Other).Health > 0)
                and Other.Active and ((not (Other is TabWall)) or (Other.ZoneRadius > 1)) then
              begin
                ComputeSphericalBearingAndDistance(Bearing, Distance,
                  Obj.State.LongitudeDegrees, Obj.State.PolarAngleDegrees, 0,
                  Other.State.LongitudeDegrees, Other.State.PolarAngleDegrees, SphereRadius);
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
end;
{ @end $50476C }

end.
