unit aMissile;
// Unit bracket (inferred): .text 0x004EFF88..0x004F347C; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, EC_Struct, SE_Space, aEFilm, aGalaxy, aGalaxyStruct, aItem, aShip, aConst;

type
  // Saved target tags; unknown byte values leave references unresolved.
  TMissileTargetKind = (
    mtkNone = 0,
    mtkShip = 1,
    mtkItem = 2,
    mtkAsteroid = 3,
    mtkMissile = 4
  ); // @size $01

type
  TMissile = class(TObjectEx) // @size 0x74
  public
    Graphic: TObjectSE; // @offset 0x04
    Id: Cardinal; // @offset 0x08
    WeaponId: Integer; // @offset 0x0C Matches TItem.Id.
    ItemType: TItemType; // @offset 0x10
    TechLevel: Byte; // @offset 0x11
    MinDamage: Integer; // @offset 0x14
    MaxDamage: Integer; // @offset 0x18
    // Copied from the weapon: one-based MicroModuleTemplates indexes, zero when absent.
    MicroModuleIndex: Integer; // @offset 0x1C
    SpecialModuleIndex: Integer; // @offset 0x20
    Position: TPointF; // @offset 0x24
    Direction: Single; // @offset 0x2C
    Speed: Single; // @offset 0x30
    MaximumSpeed: Single; // @offset 0x34
    CurrentStar: TStar; // @offset 0x38
    OwnerShip: TShip; // @offset 0x3C
    Target: TObject; // @offset 0x40
    PreviousTarget: TObject; // @offset $44 Last invalidated target, excluded by retargeting.
    ShotIndex: Integer; // @offset 0x48
    TurnDirection: Single; // @offset 0x4C
    SourceHeading: Single; // @offset 0x50
    FlightTicks: Integer; // @offset $54 Advanced by 200 / MovementStepCount.
    DestroyQueued: Boolean; // @offset 0x58  StepDay marks intercepted/expired missiles; NextDay removes them.
    FilmObject: TEFilmObj; // @offset 0x5C
    SavedTargetKind: TMissileTargetKind; // @offset $60
    SavedPreviousTargetKind: TMissileTargetKind; // @offset $61
    LastTargetPosition: TPointF; // @offset $64
    LastTargetDistance: Single; // @offset $6C Squared distance used to detect overshooting, not a random seed.
    OvershootTicks: Integer; // @offset $70

    destructor Destroy; override; // @addr $4F00DC
    procedure SaveToBuffer(Buffer: TBufEC); virtual; // @addr $4F063C @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; World: TGalaxy); virtual; // @addr $4F0AB8 @slot $04
    procedure ResolveLoadedReferences(World: TGalaxy); // @addr $4F0F68
    procedure InitializeUnownedShot(Star: TStar; Target: TObject; X, Y: Integer; Direction: Single; MinDamage, MaxDamage: Integer; MaximumSpeed: Single; ItemType: TItemType; ModuleIndex, SpecialIndex: Integer); // @addr $4F04E8
    function CanBeHit(Attacker: TShip; UnusedWeapon: TWeapon): Boolean; // @addr $4F3204
    procedure RetargetTorpedo; // @addr $4F285C
    function TryReturnToOwner(StepIndex: Integer; RecordFilm: Boolean; PreviousPosition: TPointF; Ship: TShip): Boolean; // @addr $4F2620
    procedure ClearReferencesTo(Obj: TObject); // @addr 0x4F329C
    constructor Create; // @addr 0x4F005C
    procedure InitializeShot(Star: TStar; OwnerShip: TShip; Weapon: TWeapon; Target: TObject; ShotIndex: Integer); // @addr 0x4F0164 @note "Registers the missile in Star, copies weapon data and initializes position, heading and speed."
    procedure PrepareTurnMovement(StepIndex: Integer; RecordFilm, PlayShotSound: Boolean); // @addr 0x4F121C
    function GetDisplayName: WideString; // @addr $4F2A0C
    function GetInfoText: WideString; // @addr $4F2B04
    function GetGraphObject: TObjectSE; // @addr $4F110C Lazily creates and initializes the retained missile scene object.
    function GetGraphSuffix: WideString; virtual; // @addr $4F3340 @slot $08
    function GetWeaponInfo: PWeaponInfo; virtual; // @addr 0x4F3434 @slot 0x0C
    function GetShotVisual: Integer; // @addr 0x4F32E8 @note "Special micromodule override unless -1, otherwise the weapon-info default."
    function StepDay(StepIndex: Integer; RecordFilm: Boolean): TObject; // @addr 0x4F1780 @note "Returns a hit ship, item or asteroid, or nil when no object was hit."
  end;

  TCustomMissile = class(TMissile) // @size 0x78
  public
    WeaponInfo: PWeaponInfo; // @offset 0x74  Borrowed custom weapon definition.

    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $4F0A30
    procedure LoadFromBuffer(Buffer: TBufEC; World: TGalaxy); override; // @addr $4F0EF8
    function GetGraphSuffix: WideString; override; // @addr $4F33D8
    procedure InitializeUnownedShot(Star: TStar; Target: TObject; X, Y: Integer; Direction: Single; MinDamage, MaxDamage: Integer; MaximumSpeed: Single; WeaponName: WideString; ModuleIndex, SpecialIndex: Integer); // @addr $4F05A8
    function GetWeaponInfo: PWeaponInfo; override; // @addr 0x4F3464 @slot 0x0C
    procedure InitializeShot(Star: TStar; OwnerShip: TShip; Weapon: TWeapon; Target: TObject; ShotIndex: Integer); // @addr 0x4F04A8 @note "Caches Weapon.GetWeaponInfo before the base initializer."
  end;

implementation

uses Classes, GR_Main, SE_Weapon, EC_BlockPar, Math, Globals, GlobalsV, SysUtils, aMyFunction, aAsteroid, aPlayer, aKling;

{ @routine $4F005C TMissile_Create }
constructor TMissile.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextMissileId;
    Inc(Galaxy.NextMissileId);
  end;
  WeaponId := 0;
  PreviousTarget := nil;
  LastTargetDistance := 1E20;
end;
{ @end $4F005C }

{ @routine $4F00DC TMissile_Destroy }
destructor TMissile.Destroy;
var
  Index: Integer;
begin
  if Graphic <> nil then ReleaseSpaceObject(Graphic);
  if CurrentStar <> nil then
  begin
    CurrentStar.ClearTargetReferences(Self);
    Index := CurrentStar.Missiles.IndexOf(Self);
    if Index >= 0 then CurrentStar.Missiles.Delete(Index);
  end;
  inherited Destroy;
end;
{ @end $4F00DC }

{ @routine $4F0164 TMissile_InitializeShot }
procedure TMissile.InitializeShot(Star: TStar; OwnerShip: TShip; Weapon: TWeapon; Target: TObject; ShotIndex: Integer);
var
  DY, DX: Single;
  ShotCount, SpeedBonus, SpecialBonus: Integer;
begin
  Star.Missiles.Add(Self);
  CurrentStar := Star;
  Self.OwnerShip := OwnerShip;
  Self.Target := Target;
  WeaponId := Weapon.Id;
  ItemType := Weapon.ItemType;
  MinDamage := OwnerShip.GetWeaponMinDamage(Weapon);
  MicroModuleIndex := Weapon.MicroModuleIndex;
  SpecialModuleIndex := Weapon.SpecialModuleIndex;
  MaxDamage := OwnerShip.GetWeaponMaxDamage(Weapon);
  SpeedBonus := Self.OwnerShip.GetTotalStatBonus(bonMissileSpeed);
  SpecialBonus := 0;
  if SpecialModuleIndex > 0 then SpecialBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonMissileSpeed];
  if MicroModuleIndex > 0 then
  begin
    Inc(SpeedBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonMissileSpeed]);
    if SpecialBonus < 0 then Inc(SpecialBonus, Round(SpecialBonus * MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinPenalty] * 0.0001))
    else Inc(SpecialBonus, Round(SpecialBonus * MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinEff] * 0.0001));
  end;
  Inc(SpeedBonus, SpecialBonus);
  TechLevel := Weapon.TechLevel;
  Self.ShotIndex := ShotIndex;
  ShotCount := Weapon.GetShotCount;
  Direction := OwnerShip.MovementDirection;
  Position := OwnerShip.Position;
  if ShotIndex > 0 then
  begin
    Direction := Direction - 60 / (ShotCount + 3) * ((ShotIndex + 1) div 2) * (2 * (ShotIndex mod 2) - 1);
    DX := Sin(HeadingDegreesToRadians(Direction));
    DY := -Cos(HeadingDegreesToRadians(Direction));
    Position := MakePointF(Position.X + -DX * 8, Position.Y + -DY * 8);
  end;
  MaximumSpeed := Max(GetWeaponInfo.MissileMinSpeed div 10, RemapClamped(TechLevel, 1, 8, GetWeaponInfo.MissileMinSpeed, GetWeaponInfo.MissileMaxSpeed) + SpeedBonus);
end;
{ @end $4F0164 }

{ @routine $4F04A8 TCustomMissile_InitializeShot }
procedure TCustomMissile.InitializeShot(Star: TStar; OwnerShip: TShip; Weapon: TWeapon; Target: TObject; ShotIndex: Integer);
begin
  WeaponInfo := Weapon.GetWeaponInfo;
  inherited InitializeShot(Star, OwnerShip, Weapon, Target, ShotIndex);
end;
{ @end $4F04A8 }

{ @routine $4F04E8 TMissile_InitializeUnownedShot }
procedure TMissile.InitializeUnownedShot(Star: TStar; Target: TObject; X, Y: Integer; Direction: Single; MinDamage, MaxDamage: Integer; MaximumSpeed: Single; ItemType: TItemType; ModuleIndex, SpecialIndex: Integer);
begin
  Star.Missiles.Add(Self);
  CurrentStar := Star;
  OwnerShip := nil;
  Self.Target := Target;
  WeaponId := 0;
  Self.ItemType := ItemType;
  MicroModuleIndex := ModuleIndex;
  SpecialModuleIndex := SpecialIndex;
  Self.MinDamage := MinDamage;
  Self.MaxDamage := MaxDamage;
  Self.Direction := Direction;
  Position := MakePointF(X, Y);
  Self.MaximumSpeed := MaximumSpeed;
  TechLevel := 1;
  ShotIndex := 0;
end;
{ @end $4F04E8 }

{ @routine $4F05A8 TCustomMissile_InitializeUnownedShot }
procedure TCustomMissile.InitializeUnownedShot(Star: TStar; Target: TObject; X, Y: Integer; Direction: Single; MinDamage, MaxDamage: Integer; MaximumSpeed: Single; WeaponName: WideString; ModuleIndex, SpecialIndex: Integer);
begin
  WeaponInfo := Galaxy.RequireCustomWeaponInfo(WeaponName);
  inherited InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, MaximumSpeed, WeaponInfo.ItemType, ModuleIndex, SpecialIndex);
end;
{ @end $4F05A8 }

{ @routine $4F063C TMissile_SaveToBuffer }
procedure TMissile.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddDWord(Id);
  Buffer.AddDWord(WeaponId);
  Buffer.AddAnsiChar(AnsiChar(ItemType));
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddIntegerValue(MinDamage);
  Buffer.AddIntegerValue(MaxDamage);
  Buffer.AddIntegerValue(MicroModuleIndex);
  if MicroModuleIndex > 0 then Buffer.AddDWord(MicroModuleTemplates[MicroModuleIndex - 1].ConfigNameHash);
  Buffer.AddIntegerValue(SpecialModuleIndex);
  if SpecialModuleIndex > 0 then Buffer.AddDWord(MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNameHash);
  Buffer.AddSingle(Position.X);
  Buffer.AddSingle(Position.Y);
  Buffer.AddSingle(Direction);
  Buffer.AddSingle(TurnDirection);
  if CurrentStar = nil then Buffer.AddDWord(0) else Buffer.AddDWord(CurrentStar.Id);
  if OwnerShip = nil then Buffer.AddDWord(0) else Buffer.AddDWord(OwnerShip.Id);
  if Target = nil then Buffer.AddAnsiChar(AnsiChar(mtkNone))
  else if Target is TShip then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkShip));
      Buffer.AddDWord((Target as TShip).Id);
    end
    else if Target is TItem then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkItem));
      Buffer.AddDWord((Target as TItem).Id);
    end
    else if Target is TAsteroid then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkAsteroid));
      Buffer.AddDWord((Target as TAsteroid).Id);
    end
    else if Target is TMissile then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkMissile));
      Buffer.AddDWord((Target as TMissile).Id);
    end
    else Buffer.AddAnsiChar(AnsiChar(mtkNone));
  Buffer.AddAnsiChar(AnsiChar(ShotIndex));
  Buffer.AddIntegerValue(FlightTicks);
  Buffer.AddSingle(SourceHeading);
  Buffer.AddSingle(Speed);
  Buffer.AddSingle(MaximumSpeed);
  if PreviousTarget = nil then Buffer.AddAnsiChar(AnsiChar(mtkNone))
  else if PreviousTarget is TShip then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkShip));
      Buffer.AddDWord((PreviousTarget as TShip).Id);
    end
    else if PreviousTarget is TItem then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkItem));
      Buffer.AddDWord((PreviousTarget as TItem).Id);
    end
    else if PreviousTarget is TAsteroid then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkAsteroid));
      Buffer.AddDWord((PreviousTarget as TAsteroid).Id);
    end
    else if PreviousTarget is TMissile then
    begin
      Buffer.AddAnsiChar(AnsiChar(mtkMissile));
      Buffer.AddDWord((PreviousTarget as TMissile).Id);
    end
    else Buffer.AddAnsiChar(AnsiChar(mtkNone));
  Buffer.AddSingle(LastTargetPosition.X);
  Buffer.AddSingle(LastTargetPosition.Y);
  Buffer.AddSingle(LastTargetDistance);
end;
{ @end $4F063C }

{ @routine $4F0A30 TCustomMissile_SaveToBuffer }
procedure TCustomMissile.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(WeaponInfo.ConfigName);
  inherited SaveToBuffer(Buffer);
end;
{ @end $4F0A30 }

{ @routine $4F0AB8 TMissile_LoadFromBuffer }
procedure TMissile.LoadFromBuffer(Buffer: TBufEC; World: TGalaxy);
var
  ModuleNumber: Integer;
// @nested $4F0A5C FindLegacyMissileMicroModuleIndex
function FindLegacyMissileMicroModuleIndex(ConfigNumber: Integer): Integer; // @addr $4F0A5C @note "Nested legacy lookup; caller pops the unused static link."
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[I].ConfigNumber = ConfigNumber then
    begin
      Result := I + 1;
      Exit;
    end;
end;
begin
  Id := Buffer.GetUInt32;
  if Id >= World.NextMissileId then World.NextMissileId := Id + 1;
  if LoadedSaveVersion >= 159 then WeaponId := Buffer.GetUInt32;
  ItemType := MigrateSavedItemType(Buffer.GetByte);
  TechLevel := Buffer.GetByte;
  if LoadedSaveVersion >= 100 then
  begin
    MinDamage := Buffer.GetInt32;
    MaxDamage := Buffer.GetInt32;
  end
  else
  begin
    MinDamage := Buffer.GetByte;
    MaxDamage := Buffer.GetByte;
  end;
  if LoadedSaveVersion >= 157 then
  begin
    MicroModuleIndex := ReadSavedMicroModuleIndex(Buffer);
    SpecialModuleIndex := ReadSavedMicroModuleIndex(Buffer);
  end
  else if LoadedSaveVersion >= 82 then
  begin
    MicroModuleIndex := Buffer.GetInt32;
    SpecialModuleIndex := Buffer.GetInt32;
    if LoadedSaveVersion >= 98 then
    begin
      if MicroModuleIndex > 0 then
      begin
        ModuleNumber := Buffer.GetInt32;
        if ((High(MicroModuleTemplates) + 1) < MicroModuleIndex) or (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber <> ModuleNumber) then MicroModuleIndex := FindLegacyMissileMicroModuleIndex(ModuleNumber);
      end;
      if SpecialModuleIndex > 0 then
      begin
        ModuleNumber := Buffer.GetInt32;
        if ((High(MicroModuleTemplates) + 1) < SpecialModuleIndex) or (MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber <> ModuleNumber) then SpecialModuleIndex := FindLegacyMissileMicroModuleIndex(ModuleNumber);
      end;
    end;
  end
  else
  begin
    MicroModuleIndex := 0;
    SpecialModuleIndex := 0;
  end;
  if LoadedSaveVersion < 98 then
  begin
    if MicroModuleIndex <> 0 then
    begin
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 24 then Inc(MicroModuleIndex);
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 124 then Inc(MicroModuleIndex);
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 219 then Inc(MicroModuleIndex);
    end;
    if SpecialModuleIndex <> 0 then
    begin
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 24 then Inc(SpecialModuleIndex);
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 124 then Inc(SpecialModuleIndex);
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 219 then Inc(SpecialModuleIndex);
    end;
  end;
  Position.X := Buffer.GetSingle;
  Position.Y := Buffer.GetSingle;
  Direction := Buffer.GetSingle;
  TurnDirection := Buffer.GetSingle;
  CurrentStar := TStar(Buffer.GetUInt32);
  OwnerShip := TShip(Buffer.GetUInt32);
  SavedTargetKind := TMissileTargetKind(Buffer.GetByte);
  if SavedTargetKind = mtkNone then Target := nil else Target := TObject(Buffer.GetUInt32);
  ShotIndex := Buffer.GetByte;
  FlightTicks := Buffer.GetInt32;
  SourceHeading := Buffer.GetSingle;
  Speed := Buffer.GetSingle;
  if LoadedSaveVersion >= 95 then MaximumSpeed := Buffer.GetSingle
  else MaximumSpeed := RemapClamped(TechLevel, 1, 8, GetWeaponInfo.MissileMinSpeed, GetWeaponInfo.MissileMaxSpeed);
  SavedPreviousTargetKind := TMissileTargetKind(Buffer.GetByte);
  if SavedPreviousTargetKind = mtkNone then PreviousTarget := nil else PreviousTarget := TObject(Buffer.GetUInt32);
  LastTargetPosition.X := Buffer.GetSingle;
  LastTargetPosition.Y := Buffer.GetSingle;
  LastTargetDistance := Buffer.GetSingle;
end;
{ @end $4F0AB8 }

{ @routine $4F0EF8 TCustomMissile_LoadFromBuffer }
procedure TCustomMissile.LoadFromBuffer(Buffer: TBufEC; World: TGalaxy);
begin
  WeaponInfo := World.RequireCustomWeaponInfo(Buffer.ReadWideString);
  inherited LoadFromBuffer(Buffer, World);
end;
{ @end $4F0EF8 }

{ @routine $4F0F68 TMissile_ResolveLoadedReferences }
procedure TMissile.ResolveLoadedReferences(World: TGalaxy);
begin
  CurrentStar := TObject(World.IdToStar(Cardinal(CurrentStar))) as TStar;
  OwnerShip := TObject(World.IdToShip(Cardinal(OwnerShip), True)) as TShip;
  if SavedTargetKind = mtkShip then Target := TObject(World.IdToShip(Cardinal(Target), True)) as TShip
  else if SavedTargetKind = mtkItem then Target := TObject(World.IdToItem(Cardinal(Target), True)) as TItem
  else if SavedTargetKind = mtkAsteroid then Target := TObject(World.IdToAsteroid(Cardinal(Target))) as TAsteroid
  else if SavedTargetKind = mtkMissile then Target := TObject(World.IdToMissile(Cardinal(Target))) as TMissile;
  if SavedPreviousTargetKind = mtkShip then PreviousTarget := TObject(World.IdToShip(Cardinal(PreviousTarget), True)) as TShip
  else if SavedPreviousTargetKind = mtkItem then PreviousTarget := TObject(World.IdToItem(Cardinal(PreviousTarget), True)) as TItem
  else if SavedPreviousTargetKind = mtkAsteroid then PreviousTarget := TObject(World.IdToAsteroid(Cardinal(PreviousTarget))) as TAsteroid
  else if SavedPreviousTargetKind = mtkMissile then PreviousTarget := TObject(World.IdToMissile(Cardinal(PreviousTarget))) as TMissile;
end;
{ @end $4F0F68 }

{ @routine $4F110C TMissile_GetGraphObject }
function TMissile.GetGraphObject: TObjectSE;
begin
  if Graphic = nil then
  begin
    RetainSpaceObject(Graphic, CreateSpaceObjectByName('Missile', 'Missile.w' + GetGraphSuffix, Classes.Point(0, 0)));
    Graphic.SetPosition(Position);
    Graphic.SetAngle(HeadingDegreesToByte(Direction));
    Graphic.SetAlpha(255);
  end;
  Result := Graphic;
end;
{ @end $4F110C }

{ @routine $4F121C TMissile_PrepareTurnMovement }
procedure TMissile.PrepareTurnMovement(StepIndex: Integer; RecordFilm, PlayShotSound: Boolean);
var
  PathLength, TurnFraction: Single;
  Config, Palette: TBlockParEC;
begin
  if RecordFilm then
  begin
    FilmObject := PrimaryFilm.AddObject(Id, GetGraphObject);
    PrimaryFilm.SetObjectPosition(StepIndex, FilmObject, Position);
    PrimaryFilm.SetObjectAngle(StepIndex, FilmObject, HeadingDegreesToByte(Direction));
    PrimaryFilm.AttachObject(StepIndex, FilmObject);
    if PlayShotSound then
    begin
      if Self is TCustomMissile then Config := GameDataConfig.GetBlockByPath('SE.' + GetWeaponInfo.PrimarySE)
      else Config := GameDataConfig.GetBlockByPath('SE.Weapon.' + IntToStr(Ord(ItemType) - Ord(t_IndustrialLaser)));
      Palette := Config.FindBlock('Palettes');
      if Palette <> nil then Palette := Palette.FindBlock(IntToStr(GetShotVisual));
      if (Palette <> nil) and (Palette.CountParams('SoundShot') > 0) then PrimaryFilm.PlayObjectSound(StepIndex, FilmObject, Palette.GetParam('SoundShot'))
      else if Config.CountParams('SoundShot') > 0 then PrimaryFilm.PlayObjectSound(StepIndex, FilmObject, Config.GetParam('SoundShot'))
      else if Self is TCustomMissile then PrimaryFilm.PlayObjectSound(StepIndex, FilmObject, 'Sound.shot' + GetWeaponInfo.ConfigName)
      else PrimaryFilm.PlayObjectSound(StepIndex, FilmObject, 'Sound.shot' + IntToStr(Ord(ItemType) - Ord(t_IndustrialLaser)));
    end;
  end;
  if FlightTicks = 0 then
  begin
    if OwnerShip <> nil then
    begin
      SourceHeading := OwnerShip.MovementDirection;
      Speed := Max(OwnerShip.Speed, MaximumSpeed);
      PathLength := 0;
      if (OwnerShip.MovementPath <> nil) and (OwnerShip.MovementPath.NodeCount > 0) then
      begin
        PathLength := OwnerShip.MovementPath.GetLength;
        TurnFraction := StepIndex / CurrentStar.MovementStepCount;
        if 1 - TurnFraction = 0 then PathLength := 0 else PathLength := PathLength / (1 - TurnFraction);
        if HeadingDifferenceDegrees(OwnerShip.MovementDirection, RadiansToHeadingDegrees(ArcTan2(
          OwnerShip.MovementPath.ActiveTail.Position.X - OwnerShip.Position.X, -(OwnerShip.MovementPath.ActiveTail.Position.Y - OwnerShip.Position.Y)))) < 0 then TurnDirection := -1
        else TurnDirection := 1;
      end
      else TurnDirection := 1;
      // The initial maximum above is overwritten in the native routine too.
      Speed := PathLength + 100;
      if Speed < 200 then Speed := 200;
    end
    else
    begin
      Speed := MaximumSpeed;
      SourceHeading := 0;
      TurnDirection := 0;
    end;
    Inc(FlightTicks);
  end;
  OvershootTicks := -1;
end;
{ @end $4F121C }

{ @routine $4F1780 TMissile_StepDay }
function TMissile.StepDay(StepIndex: Integer; RecordFilm: Boolean): TObject;
var
  StepScale, TargetHeading, Delta, Separation: Double;
  PreviousPosition, TargetPosition: TPointF;
  OtherMissile: TMissile;
  I, J, VerticalSign: Integer;
  Asteroid: TAsteroid;
  Ship: TShip;
  HasTarget: Boolean;
  Item: TItem;
  DesiredSpeed, DistanceSquared: Single;
  Drop: PMovingDropItemEntry;
  Effect: TObjectSE;
  EffectFilm: TEFilmObj;
  Stage: Integer;
begin
  Stage := 0;
  try
    Result := nil;
    PreviousPosition := Position;
    StepScale := BaseMovementStepsPerTurn / CurrentStar.MovementStepCount;
    Inc(FlightTicks, Round(StepScale));
    TargetPosition := MakePointF(0, 0);
    HasTarget := False;
    DesiredSpeed := MaximumSpeed;
    Stage := 1;
    if FlightTicks < BaseMovementStepsPerTurn then
    begin
      Stage := 2;
      if OwnerShip <> nil then
      begin
        Stage := 3;
        Delta := OwnerShip.MovementDirection - SourceHeading;
        SourceHeading := OwnerShip.MovementDirection;
        Separation := ShotIndex * 0.1 + 0.1;
        if Delta > 0 then Delta := Delta - Separation * StepScale
        else if Delta < 0 then Delta := Delta + Separation * StepScale;
        if Delta < -0.5 * StepScale then Delta := -0.5 * StepScale
        else if Delta > 0.5 * StepScale then Delta := 0.5 * StepScale;
        Direction := WrapHeadingDegrees(Direction + Delta);
        if RecordFilm then PrimaryFilm.SetObjectAngle(StepIndex, FilmObject, HeadingDegreesToByte(Direction));
        Position.X := Position.X + Sin(HeadingDegreesToRadians(Direction)) * (Speed / BaseMovementStepsPerTurn * StepScale);
        Position.Y := Position.Y - Cos(HeadingDegreesToRadians(Direction)) * (Speed / BaseMovementStepsPerTurn * StepScale);
      end
      else
      begin
        Stage := 4;
        Position.X := Position.X + Sin(HeadingDegreesToRadians(Direction)) * (Speed / BaseMovementStepsPerTurn * StepScale);
        Position.Y := Position.Y - Cos(HeadingDegreesToRadians(Direction)) * (Speed / BaseMovementStepsPerTurn * StepScale);
      end;
    end
    else
    begin
      Stage := 5;
      RetargetTorpedo;
      Stage := 6;
      if Target <> nil then
      begin
        if (Target is TShip) and (TShip(Target).CurrentStar = CurrentStar) and TShip(Target).InNormalSpace then
        begin
          Stage := 7;
          TargetPosition := TShip(Target).Position;
          HasTarget := True;
        end
        else if Target is TItem then
        begin
          Stage := 8;
          TargetPosition := TItem(Target).Position;
          HasTarget := True;
        end
        else if Target is TAsteroid then
        begin
          Stage := 9;
          TargetPosition := TAsteroid(Target).Position;
          HasTarget := True;
        end
        else if Target is TMissile then
        begin
          Stage := 10;
          TargetPosition := TMissile(Target).Position;
          HasTarget := True;
        end
        else
        begin
          Stage := 11;
          PreviousTarget := Target;
          Target := nil;
        end;
      end;
      if HasTarget then
      begin
        Stage := 12;
        VerticalSign := -1;
        if (FlightTicks > 1) and (LastTargetPosition.X = TargetPosition.X) and (LastTargetPosition.Y = TargetPosition.Y) then
        begin
          Stage := 13;
          DistanceSquared := PointDistanceSquared(Position, TargetPosition);
          if (LastTargetDistance < DistanceSquared) and (OvershootTicks < 0) then OvershootTicks := RandomIntRange(Round(Speed / 40), Round(Speed / 10));
          LastTargetDistance := DistanceSquared;
          if OvershootTicks > 0 then
          begin
            VerticalSign := 1;
            Dec(OvershootTicks);
          end;
        end;
        LastTargetPosition := TargetPosition;
        TargetHeading := RadiansToHeadingDegrees(ArcTan2(TargetPosition.X - Position.X, (TargetPosition.Y - Position.Y) * VerticalSign));
        Stage := 14;
        Delta := HeadingDifferenceDegrees(Direction, TargetHeading);
        if Abs(Delta) <= 3 * StepScale then Direction := TargetHeading
        else
        begin
          if Delta < 0 then Direction := WrapHeadingDegrees(Direction - 3 * StepScale)
          else Direction := WrapHeadingDegrees(Direction + 3 * StepScale);
        end;
        Stage := 14;
        if RecordFilm then PrimaryFilm.SetObjectAngle(StepIndex, FilmObject, HeadingDegreesToByte(Direction));
      end;
      Stage := 15;
      if Abs(Speed - DesiredSpeed) <= 10 then Speed := DesiredSpeed
      else if Speed < DesiredSpeed then Speed := Speed + 10
      else if Speed > DesiredSpeed then Speed := Speed - 10;
        Position.X := Position.X + Sin(HeadingDegreesToRadians(Direction)) * (Speed / BaseMovementStepsPerTurn * StepScale);
        Position.Y := Position.Y - Cos(HeadingDegreesToRadians(Direction)) * (Speed / BaseMovementStepsPerTurn * StepScale);
    end;
    Stage := 16;
    if RecordFilm then PrimaryFilm.SetObjectPosition(StepIndex, FilmObject, Position);
    Stage := 17;
    for I := 0 to CurrentStar.Missiles.Count - 1 do
    begin
      Stage := 18;
      OtherMissile := TMissile(CurrentStar.Missiles[I]);
      if (OtherMissile <> Self) and ((Target = OtherMissile) or (OtherMissile.Target = Self)) and
        SegmentIntersectsCircle(PreviousPosition, Position, OtherMissile.Position, 10) then
      begin
        Stage := 19;
        if RecordFilm then
        begin
        Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
        EffectFilm := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Position);
        PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
        PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        PrimaryFilm.DetachObject(StepIndex, FilmObject);
        ReleaseSpaceObject(Graphic);
          PrimaryFilm.DetachObject(StepIndex, OtherMissile.FilmObject);
          ReleaseSpaceObject(OtherMissile.Graphic);
        end;
        OtherMissile.DestroyQueued := True;
        DestroyQueued := True;
        Exit;
      end;
    end;
    Stage := 20;
    for I := 0 to CurrentStar.Items.Count - 1 do
    begin
      Stage := 21;
      Item := TItem(CurrentStar.Items[I]);
      Stage := 22;
      if ((GetWeaponInfo.ShotType <> wstTorpedo) or (Target = Item)) and
        SegmentIntersectsCircle(PreviousPosition, Position, Item.Position, 10) then
      begin
        Stage := 23;
        J := CurrentStar.MovingDropItems.Count - 1;
        while J >= 0 do
        begin
          Drop := CurrentStar.MovingDropItems[J];
          if Drop.Payload = Item then Break;
          Dec(J);
        end;
        if J < 0 then
        begin
          Result := Item;
          Exit;
        end;
      end;
    end;
    Stage := 24;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Stage := 25;
      Ship := TShip(CurrentStar.Ships[I]);
      if not Ship.IsHullDestroyed and Ship.InNormalSpace then
      begin
        if TryReturnToOwner(StepIndex, RecordFilm, PreviousPosition, Ship) then Exit;
        if (OwnerShip <> Ship) and ((Target = Ship) or (OwnerShip = nil) or (OwnerShip.GetRelationLevelToShip(Ship) = rlHostile)) then
        begin
          Stage := 26;
          if SegmentIntersectsCircle(PreviousPosition, Position, Ship.Position, 20) then
          begin
            Result := Ship;
            Exit;
          end;
        end;
      end;
    end;
    Stage := 27;
    for I := 0 to CurrentStar.Asteroids.Count - 1 do
    begin
      Asteroid := TAsteroid(CurrentStar.Asteroids[I]);
      Stage := 28;
      if SegmentIntersectsCircle(PreviousPosition, Position, Asteroid.Position, 10) then
      begin
        Result := Asteroid;
        Exit;
      end;
    end;
    Stage := 29;
    if SegmentIntersectsCircle(PreviousPosition, Position, MakePointF(0, 0), CurrentStar.Radius * 0.7) then
    begin
      if RecordFilm then
      begin
        Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
        EffectFilm := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Position);
        PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
        PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        PrimaryFilm.DetachObject(StepIndex, FilmObject);
        ReleaseSpaceObject(Graphic);
      end;
      DestroyQueued := True;
      Exit;
    end;
    begin
      Stage := 30;
      if (FlightTicks > 1000) and ((Target = nil) or not (FlightTicks * 0.005 * MaximumSpeed < GetWeaponInfo.MissileRange)) then
      begin
        if RecordFilm then
        begin
        Effect := TWeaponSE.Create('Weapon.Asteroid', Classes.Point(0, 0), 0, -1);
        EffectFilm := PrimaryFilm.AddObject(0, Effect);
        PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Position);
        PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
        PrimaryFilm.AttachObject(StepIndex, EffectFilm);
        PrimaryFilm.DetachObject(StepIndex, FilmObject);
        ReleaseSpaceObject(Graphic);
        end;
        DestroyQueued := True;
        Exit;
      end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TMissile.StepDay, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $4F1780 }

{ @routine $4F2620 TMissile_TryReturnToOwner }
function TMissile.TryReturnToOwner(StepIndex: Integer; RecordFilm: Boolean; PreviousPosition: TPointF; Ship: TShip): Boolean;
var
  I: Integer;
  FoundWeapon: Boolean;
  Item: TItem;
  Weapon: TWeapon;
  Effect: TObjectSE;
  EffectFilm: TEFilmObj;
begin
  Result := False;
  if (GetWeaponInfo.ShotType = wstTorpedo) and (OwnerShip <> nil) and (Ship = OwnerShip) and (Target = OwnerShip) and
    SegmentIntersectsCircle(PreviousPosition, Position, Ship.Position, 20) then
  begin
    FoundWeapon := False;
    for I := 1 to Ship.WeaponCount do
    begin
      Weapon := Ship.Weapons[I];
      if (Weapon <> nil) and (Weapon.Id = WeaponId) then
      begin
        FoundWeapon := True;
        if Weapon.Ammo < Weapon.AmmoCapacity then Inc(Weapon.Ammo);
        Break;
      end;
    end;
    if not FoundWeapon then
      for I := 1 to Ship.Inventory.Count - 1 do
      begin
        Item := Ship.Inventory[I];
        if Item.Id = WeaponId then
        begin
          if (Item is TWeapon) and (TWeapon(Item).Ammo < TWeapon(Item).AmmoCapacity) then Inc(TWeapon(Item).Ammo);
          Break;
        end;
      end;
    if RecordFilm then
    begin
      Effect := TWeaponSE.Create('Weapon.NoGraph', Classes.Point(0, 0), 0, -1);
      EffectFilm := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetObjectPosition(StepIndex, EffectFilm, Position);
      PrimaryFilm.SetWeaponHit(StepIndex, EffectFilm, 0, 0, False, True);
      PrimaryFilm.AttachObject(StepIndex, EffectFilm);
      PrimaryFilm.DetachObject(StepIndex, FilmObject);
      ReleaseSpaceObject(Graphic);
    end;
    DestroyQueued := True;
    Result := True;
  end;
end;
{ @end $4F2620 }

{ @routine $4F285C TMissile_RetargetTorpedo }
procedure TMissile.RetargetTorpedo;
var
  BestDistance, Distance: Single;
  I: Integer;
  Ship, BestShip: TShip;
begin
  if (GetWeaponInfo.ShotType = wstTorpedo) and (OwnerShip <> nil) and ((Target = nil) or (Target = OwnerShip)) then
  begin
    BestDistance := 1E30;
    BestShip := nil;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if not Ship.IsOutsideStarSpace and (Ship <> PreviousTarget) and (Ship.GetRelationLevelToShip(OwnerShip) <= rlHostile) and
        (not (OwnerShip is TKling) or not (OwnerShip as TKling).IsPlayerCamouflageEffective(Ship)) and
        (not (Ship is TKling) or not (Ship as TKling).IsPlayerCamouflageEffective(OwnerShip)) then
      begin
        Distance := PointDistance(Ship.Position, Position);
        if (Distance <= 700) and (Distance < BestDistance) then
        begin
          BestDistance := Distance;
          BestShip := Ship;
        end;
      end;
    end;
    if BestShip <> nil then Target := BestShip
    else if OwnerShip.InNormalSpace and (OwnerShip.CurrentStar = CurrentStar) then Target := OwnerShip
    else Target := nil;
  end;
end;
{ @end $4F285C }

{ @routine $4F2A0C TMissile_GetDisplayName }
function TMissile.GetDisplayName: WideString;
begin
  Result := LocalizedText('Items.Weapon.Missile.' + GetGraphSuffix + '.Name');
  if SpecialModuleIndex <> 0 then
    Result := Result + ' ' + MicroModuleTemplates[SpecialModuleIndex - 1].Name;
end;
{ @end $4F2A0C }

{ @routine $4F2B04 TMissile_GetInfoText }
function TMissile.GetInfoText: WideString;
var
  SpeedText, DamageText: WideString;
  DamageFactor: Single;
begin
  Result := LocalizedText('Items.Weapon.Missile.' + GetGraphSuffix + '.Text') + #13#10;
  if OwnerShip <> nil then
    Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextFrom'),
      TextHighlightColorTag, '<Name>', OwnerShip.GetName) + #13#10;
  if (Target <> nil) and (Target is TAsteroid) then
    Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextTarget'),
      TextHighlightColorTag, '<Name>', TAsteroid(Target).GetDisplayName) + #13#10
  else if (Target <> nil) and (Target is TItem) then
    Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextTarget'),
      TextHighlightColorTag, '<Name>', TItem(Target).GetDisplayName) + #13#10
  else if (Target <> nil) and (Target is TShip) then
    Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextTarget'),
      TextHighlightColorTag, '<Name>', TShip(Target).GetName) + #13#10
  else if (Target <> nil) and (Target is TMissile) then
    Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextTarget'),
      TextHighlightColorTag, '<Name>', TMissile(Target).GetDisplayName) + #13#10
  else
    Result := Result + LocalizedText('Items.Weapon.Missile.TextNoTarget') + #13#10;
  if OwnerShip <> nil then
    if GetPlayer.HasScannerArtefact(OwnerShip) then
    begin
      if GetPlayer.CanResolveObjectWithScanner(OwnerShip) or (GetPlayer = OwnerShip) or
        (GetPlayer = OwnerShip.PartnerShip) or (OwnerShip.TypeId = stTranclucator) then
      begin
        SpeedText := IntToStr(Round(Speed));
        if (OwnerShip.TypeId = stKling) and ((OwnerShip as TKling).KlingType = ktBoss) then
          DamageFactor := Galaxy.InterpolateDifficulty(-1, 0.7, 1, 1.2, 1.5) * 2
        else DamageFactor := 1;
        DamageText := IntToStr(Round(MinDamage * DamageFactor)) + '-' + IntToStr(Round(MaxDamage * DamageFactor));
      end
      else
      begin
        SpeedText := '???';
        DamageText := '???';
      end;
      Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextSpeed'),
        TextHighlightColorTag, '<Speed>', SpeedText) + ', ';
      Result := Result + FormatText1(LocalizedText('Items.Weapon.Missile.TextDamage'),
        TextHighlightColorTag, '<Damage>', DamageText) + #13#10;
    end;
end;
{ @end $4F2B04 }

{ @routine $4F3204 TMissile_CanBeHit }
function TMissile.CanBeHit(Attacker: TShip; UnusedWeapon: TWeapon): Boolean;
var
  Roll: Integer;
begin
  if Attacker = nil then Roll := NextRandomIntRange(1, 100, Galaxy.RandomState)
  else
  begin
    if (Attacker is TKling) and ((Attacker as TKling).KlingType = ktBoss) then
    begin
      Result := True;
      Exit;
    end;
    Roll := NextRandomIntRange(1, 100, Attacker.RandomState);
  end;
  Result := Roll <= GetWeaponInfo.MissileChanceToBeHit;
end;
{ @end $4F3204 }

{ @routine $4F329C TMissile_ClearReferencesTo }
procedure TMissile.ClearReferencesTo(Obj: TObject);
begin
  if OwnerShip = Obj then OwnerShip := nil;
  if Target = Obj then Target := nil;
  if PreviousTarget = Obj then PreviousTarget := nil;
end;
{ @end $4F329C }

{ @routine $4F32E8 TMissile_GetShotVisual }
function TMissile.GetShotVisual: Integer;
begin
  if (SpecialModuleIndex = 0) or (MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual = -1) then
    Result := GetWeaponInfo.DefaultPalette
  else Result := MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual;
end;
{ @end $4F32E8 }

{ @routine $4F3340 TMissile_GetGraphSuffix }
function TMissile.GetGraphSuffix: WideString;
begin
  Result := '';
  if SpecialModuleIndex <> 0 then Result := MicroModuleTemplates[SpecialModuleIndex - 1].MissileGraph;
  if Result = '' then Result := IntToStr(Ord(ItemType) - Ord(t_IndustrialLaser) + 1);
end;
{ @end $4F3340 }

{ @routine $4F33D8 TCustomMissile_GetGraphSuffix }
function TCustomMissile.GetGraphSuffix: WideString;
begin
  Result := '';
  if SpecialModuleIndex <> 0 then Result := MicroModuleTemplates[SpecialModuleIndex - 1].MissileGraph;
  if Result = '' then Result := WeaponInfo.ConfigName;
end;
{ @end $4F33D8 }

{ @routine $4F3434 TMissile_GetWeaponInfo }
function TMissile.GetWeaponInfo: PWeaponInfo;
begin
  Result := @WeaponInfos[ItemType];
end;
{ @end $4F3434 }

{ @routine $4F3464 TCustomMissile_GetWeaponInfo }
function TCustomMissile.GetWeaponInfo: PWeaponInfo;
begin
  Result := WeaponInfo;
end;
{ @end $4F3464 }

end.
