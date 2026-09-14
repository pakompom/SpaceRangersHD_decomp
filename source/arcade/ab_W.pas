unit ab_W;
// Shared arcade weapon records and dispatch: $56269C..$56423F.
// Inferred ownership; original unit boundary remains unresolved.

interface

uses Classes, GI_MessageLoop, aGalaxyStruct, ab_Object;

type
  PabWeapon = ^TabWeapon;
  TabWeapon = record // @size $30
    Kind: Byte; // @offset $00  Zero-based arcade weapon type.
    ItemType: Byte; // @offset $01  Corresponding campaign item type (50..67).
    SlotData: Cardinal; // @offset $04 Campaign equipment slot index and secondary-fire flag; copied from TEquipment.AssignedSlotData.
    Ammo: Integer; // @offset $08
    MaxAmmo: Integer; // @offset $0C
    RechargePerTick: Integer; // @offset $10
    AmmoCost: Integer; // @offset $14
    LastFireTick: Integer; // @offset $18
    FireIntervalTicks: Integer; // @offset $1C
    Damage: Integer; // @offset $20
    Range: Double; // @offset $28
  end;

procedure ab_Weapon_InitializeFromInfo(Weapon: PabWeapon; Info: PWeaponInfo); // @addr $56269C
procedure ab_Weapon_Initialize(Weapon: PabWeapon; ItemType: Byte); // @addr $5626BC
procedure ab_Weapon_Fire(Weapon: PabWeapon; Owner: TabObject; DamageScale: Single); // @addr $562E34 @ida "void __userpurge $name(TabWeapon *Weapon@<eax>, TabObject *Owner@<edx>, float DamageScale@<^0>);"
procedure ab_Weapon_QueueImageLoad(Weapon: PabWeapon; PendingLoads: TList; Owner: TObjectGI); // @addr $563754

implementation

uses Globals, GR_Main, GI_Tail, ab_Global,
  ab_W01, ab_W02, ab_W03, ab_W04, ab_W05, ab_W06, ab_W07, ab_W08, ab_W09, ab_W10, ab_W11, ab_W12, ab_W13, ab_W14, ab_W15, ab_W16, ab_W17, ab_W18;


{ @routine $56269C ab_Weapon_InitializeFromInfo }
procedure ab_Weapon_InitializeFromInfo(Weapon: PabWeapon; Info: PWeaponInfo);
begin
  ab_Weapon_Initialize(Weapon, Info.ArcadeWeaponType);
end;
{ @end $56269C }

{ @routine $5626BC ab_Weapon_Initialize }
procedure ab_Weapon_Initialize(Weapon: PabWeapon; ItemType: Byte);
begin
  Weapon.ItemType := ItemType;
  if ItemType = 50 then
  begin
    Weapon.Kind := 0;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 3;
    Weapon.AmmoCost := 100;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 8;
    Weapon.Damage := 4;
    Weapon.Range := 600;
  end
  else if ItemType = 51 then
  begin
    Weapon.Kind := 1;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 100;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 5;
    Weapon.Damage := 5;
    Weapon.Range := 400;
  end
  else if ItemType = 52 then
  begin
    Weapon.Kind := 2;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 200;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 30;
    Weapon.Damage := 12;
    Weapon.Range := 900;
  end
  else if ItemType = 53 then
  begin
    Weapon.Kind := 3;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 200;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 30;
    Weapon.Damage := 15;
    Weapon.Range := 500;
  end
  else if ItemType = 54 then
  begin
    Weapon.Kind := 4;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 300;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 30;
    Weapon.Damage := 1400;
    Weapon.Range := 500;
  end
  else if ItemType = 55 then
  begin
    Weapon.Kind := 5;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 25;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 2;
    Weapon.Damage := 2;
    Weapon.Range := 300;
  end
  else if ItemType = 56 then
  begin
    Weapon.Kind := 6;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 1;
    Weapon.AmmoCost := 100;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 10;
    Weapon.Damage := 15;
    Weapon.Range := 700;
  end
  else if ItemType = 57 then
  begin
    Weapon.Kind := 7;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 300;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 10;
    Weapon.Damage := 50;
    Weapon.Range := 500;
  end
  else if ItemType = 58 then
  begin
    Weapon.Kind := 8;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 1;
    Weapon.AmmoCost := 250;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 20;
    Weapon.Damage := 35;
    Weapon.Range := 900;
  end
  else if ItemType = 59 then
  begin
    Weapon.Kind := 9;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 500;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 30;
    Weapon.Damage := 80;
    Weapon.Range := 900;
  end
  else if ItemType = 60 then
  begin
    Weapon.Kind := 10;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 3;
    Weapon.AmmoCost := 500;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 30;
    Weapon.Damage := 80;
    Weapon.Range := 1100;
  end
  else if ItemType = 61 then
  begin
    Weapon.Kind := 11;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 500;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 50;
    Weapon.Damage := 200;
    Weapon.Range := 500;
  end
  else if ItemType = 62 then
  begin
    Weapon.Kind := 12;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 400;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 40;
    Weapon.Damage := 80;
    Weapon.Range := 450;
  end
  else if ItemType = 63 then
  begin
    Weapon.Kind := 13;
    Weapon.Ammo := 10000;
    Weapon.MaxAmmo := 10000;
    Weapon.RechargePerTick := 10;
    Weapon.AmmoCost := 7000;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 50;
    Weapon.Damage := 80;
    Weapon.Range := 2000;
  end
  else if ItemType = 64 then
  begin
    Weapon.Kind := 14;
    Weapon.Ammo := 10000;
    Weapon.MaxAmmo := 10000;
    Weapon.RechargePerTick := 10;
    Weapon.AmmoCost := 9000;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 60;
    Weapon.Damage := 100;
    Weapon.Range := 1000;
  end
  else if ItemType = 65 then
  begin
    Weapon.Kind := 15;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 1;
    Weapon.AmmoCost := 250;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 20;
    Weapon.Damage := 30;
    Weapon.Range := 900;
  end
  else if ItemType = 66 then
  begin
    Weapon.Kind := 16;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 150;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 10;
    Weapon.Damage := 14;
    Weapon.Range := 900;
  end
  else if ItemType = 67 then
  begin
    Weapon.Kind := 17;
    Weapon.Ammo := 1000;
    Weapon.MaxAmmo := 1000;
    Weapon.RechargePerTick := 2;
    Weapon.AmmoCost := 200;
    Weapon.LastFireTick := 0;
    Weapon.FireIntervalTicks := 20;
    Weapon.Damage := 20;
    Weapon.Range := 150;
  end;
end;
{ @end $5626BC }

{ @routine $562E34 ab_Weapon_Fire }
procedure ab_Weapon_Fire(Weapon: PabWeapon; Owner: TabObject; DamageScale: Single);
var
  W01: TabW01;
  W02: TabW02;
  W03: TabW03;
  W04: TabW04;
  W05: TabW05;
  W06: TabW06;
  W07: TabW07;
  W08: TabW08;
  W09: TabW09;
  W10: TabW10;
  W11: TabW11;
  W12: TabW12;
  W13: TabW13;
  W14: TabW14;
  W15: TabW15;
  W16: TabW16;
  W17: TabW17;
  W18: TabW18;
  Angle: Single;
  Index: Integer;

  // @nested $562DD8 ConfigureObjectSound
  procedure ConfigureObjectSound(Obj: TabObject; Kind: Integer); // @addr $562DD8 @ida "void __usercall $name(TabObject *Obj@<eax>, int Kind@<edx>, void *ParentFrame@<^0>);" @stackpop 0 @calls "0x562ecf,0x562f1f,0x562f6f,0x562fbf,0x56301c,0x563068,0x5630b4,0x5630fd,0x563149,0x563195,0x5631e1,0x563231,0x563281,0x5632d5,0x563323,0x563373,0x5633c3,0x56341d,0x563469,0x5634c1,0x56350b,0x563555,0x5635b8,0x56362f,0x563699,0x5636e7,0x563734"
  begin
    if ArcadeWeaponLoopTicks[Kind] >= 0 then
    begin
      Obj.SoundDelay := ArcadeWeaponLoopTicks[Kind];
      Obj.SoundPath := ArcadeWeaponLoopSounds[Kind];
      Obj.SoundGroup := Kind + 9000;
    end;
  end;

begin
  if ArcadeWeaponFirstSounds[Weapon.Kind] <> '' then
    if IsDepthBeforeSphereHorizon(Owner.GetProjectedPosition.Z) then
      SoundManager.PlaySound(ArcadeWeaponFirstSounds[Weapon.Kind]);
  if Weapon.Kind = 0 then
  begin
    W01 := TabW01.Create;
    ab_Object_Add(W01);
    W01.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W01, 0);
  end
  else if Weapon.Kind = 1 then
  begin
    W02 := TabW02.Create;
    ab_Object_Add(W02);
    W02.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W02, 1);
  end
  else if Weapon.Kind = 2 then
  begin
    W03 := TabW03.Create;
    ab_Object_Add(W03);
    W03.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W03, 2);
  end
  else if Weapon.Kind = 3 then
  begin
    W04 := TabW04.Create;
    ab_Object_Add(W04);
    W04.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W04, 3);
  end
  else if Weapon.Kind = 4 then
  begin
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), -15);
    ConfigureObjectSound(W05, 4);
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), -10);
    ConfigureObjectSound(W05, 4);
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), -5);
    ConfigureObjectSound(W05, 4);
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), 0);
    ConfigureObjectSound(W05, 4);
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), 5);
    ConfigureObjectSound(W05, 4);
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), 10);
    ConfigureObjectSound(W05, 4);
    W05 := TabW05.Create;
    ab_Object_Add(W05);
    W05.Launch(Owner, Round(Weapon.Damage * DamageScale / 7), 15);
    ConfigureObjectSound(W05, 4);
  end
  else if Weapon.Kind = 5 then
  begin
    W06 := TabW06.Create;
    ab_Object_Add(W06);
    W06.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W06, 5);
  end
  else if Weapon.Kind = 6 then
  begin
    W07 := TabW07.Create;
    ab_Object_Add(W07);
    W07.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W07, 6);
  end
  else if Weapon.Kind = 7 then
  begin
    W08 := TabW08.Create;
    ab_Object_Add(W08);
    W08.Launch(Owner, Round(Weapon.Damage * DamageScale), 0, 0, nil);
    ConfigureObjectSound(W08, 7);
  end
  else if Weapon.Kind = 8 then
  begin
    W09 := TabW09.Create;
    ab_Object_Add(W09);
    W09.Launch(Owner, Round(Weapon.Damage * DamageScale));
    ConfigureObjectSound(W09, 8);
  end
  else if Weapon.Kind = 9 then
  begin
    W10 := TabW10.Create;
    ab_Object_Add(W10);
    W10.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W10, 9);
  end
  else if Weapon.Kind = 10 then
  begin
    W11 := TabW11.Create;
    ab_Object_Add(W11);
    W11.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W11, 10);
  end
  else if Weapon.Kind = 11 then
  begin
    W12 := TabW12.Create;
    ab_Object_Add(W12);
    W12.Launch(Owner, Round(Weapon.Damage * DamageScale / 2), 0);
    ConfigureObjectSound(W12, 11);
    W12 := TabW12.Create;
    ab_Object_Add(W12);
    W12.Launch(Owner, Round(Weapon.Damage * DamageScale / 2), 180);
    ConfigureObjectSound(W12, 11);
  end
  else if Weapon.Kind = 12 then
  begin
    W13 := TabW13.Create;
    ab_Object_Add(W13);
    W13.Launch(Owner, Round(Weapon.Damage * DamageScale), 0, 0, nil);
    ConfigureObjectSound(W13, 12);
    W13 := TabW13.Create;
    ab_Object_Add(W13);
    W13.Launch(Owner, Round(Weapon.Damage * DamageScale), 40, 0, nil);
    ConfigureObjectSound(W13, 12);
    W13 := TabW13.Create;
    ab_Object_Add(W13);
    W13.Launch(Owner, Round(Weapon.Damage * DamageScale), 320, 0, nil);
    ConfigureObjectSound(W13, 12);
  end
  else if Weapon.Kind = 13 then
  begin
    Angle := 0;
    Index := 0;
    while Angle < 360 do
    begin
      W14 := TabW14.Create;
      ab_Object_Add(W14);
      W14.Launch(Owner, Round(Weapon.Damage * DamageScale), Angle);
      if Index and 1 = 0 then ConfigureObjectSound(W14, 13);
      Angle := Angle + 15;
      Inc(Index);
    end;
  end
  else if Weapon.Kind = 14 then
  begin
    Angle := 0;
    while Angle < 360 do
    begin
      W15 := TabW15.Create;
      ab_Object_Add(W15);
      W15.Launch(Owner, Round(Weapon.Damage * DamageScale), Angle);
      ConfigureObjectSound(W15, 14);
      Angle := Angle + 45;
    end;
  end
  else if Weapon.Kind = 15 then
  begin
    W16 := TabW16.Create;
    ab_Object_Add(W16);
    W16.Launch(Owner, Round(Weapon.Damage * DamageScale));
    ConfigureObjectSound(W16, 8);
  end
  else if Weapon.Kind = 16 then
  begin
    W17 := TabW17.Create;
    ab_Object_Add(W17);
    W17.Launch(Owner, Round(Weapon.Damage * DamageScale));
    ConfigureObjectSound(W17, 2);
  end
  else if Weapon.Kind = 17 then
  begin
    W18 := TabW18.Create;
    ab_Object_Add(W18);
    W18.Launch(Owner, Round(Weapon.Damage * DamageScale), 0);
    ConfigureObjectSound(W18, 3);
  end;
end;
{ @end $562E34 }

{ @routine $563754 ab_Weapon_QueueImageLoad }
procedure ab_Weapon_QueueImageLoad(Weapon: PabWeapon; PendingLoads: TList; Owner: TObjectGI);
begin
  case Weapon.Kind of
    0:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w01_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w01_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w01a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w01a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w01b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w01b_s');
      end;
    1:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w02_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w02_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w02a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w02a_s');
      end;
    2:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w03_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w03_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w03a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w03a_s');
      end;
    3:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04b_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04c_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w04c_s');
      end;
    4:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w05_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w05_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w05a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w05a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w05b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w05b_s');
      end;
    5:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w06_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w06_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w06a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w06a_s');
      end;
    6:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w07_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w07_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w07a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w07a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w07b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w07b_s');
      end;
    7:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w08_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w08_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w08a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w08a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w08b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w08b_s');
      end;
    8:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09b_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09c_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w09c_s');
      end;
    9:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w10_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w10_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w10a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w10a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w10b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w10b_s');
      end;
    10:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w11_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w11_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w11a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w11a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w11b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w11b_s');
      end;
    11:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w12_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w12_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w12a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w12a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w12b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w12b_s');
      end;
    12:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w13_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w13_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w13a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w13a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w13b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w13b_s');
      end;
    13:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w14_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w14_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w14a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w14a_s');
      end;
    14:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w15_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w15_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w15a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w15a_s');
      end;
    15:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16b_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16c_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w16c_s');
      end;
    16:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17a_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17b_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17b_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17c_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w17c_s');
      end;
    17:
      begin
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w18_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w18_s');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w18a_f');
        GlobalCache.QueueNamedLoadIfMissing(PendingLoads, 'GAI', 'Bm.AB.w18a_s');
      end;
  end;
end;
{ @end $563754 }

end.
