unit aTranclucator;
// Unit bracket (inferred): .text 0x0065C5FC..0x0065FF2D; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses EC_Buf, aGalaxy, aGalaxyStruct, aPlanet, aShip;

type
  TTranclucatorCollectionKind = (
    tckOther = 0, tckArtefact = 1, tckMicroModule = 2, tckEquipment = 3,
    tckUseless = 4, tckGoods = 5, tckCountable = 6
  ); // @size 0x1
  TTranclucatorStorageKind = (tskPlanet = 1, tskStation = 2); // @size 0x4

  TTranclucator = class(TShip) // @size 0x4EC
  public
    ArtefactSize: Integer; // @offset 0x4D0
    ArtefactSystemName: WideString; // @offset 0x4D4
    OwnerShip: TShip; // @offset 0x4D8  Script.Proprietor.
    FollowOwner: Boolean; // @offset 0x4DC  Script.Docking.
    SeekItems: Boolean; // @offset 0x4DD
    AutoArrange: Boolean; // @offset 0x4DE
    StoreOnLanding: Boolean; // @offset 0x4DF  Script.LandStorage; also applies when docked to a station.
    CollectionPermissions: array[TTranclucatorCollectionKind] of Boolean; // @offset $4E0 Script.SeekPermitNone through SeekPermitNode.
    StoragePermissions: array[TTranclucatorStorageKind] of Boolean; // @offset $4E7 Planet and station storage switches.

    procedure StoreUnequippedCargoAt(Location: TObject); // @addr $65DC90
    function UnloadCargoForPlayerOwner: Boolean; // @addr $65DE1C
    function TryLandForStorage: Boolean; // @addr $65DEE4
    function ConvertToStoredArtefact: Boolean; // @addr $65E0D0
    procedure UpdateFreeFlightOrder; // @addr $65E300
    procedure EquipEssentialInventory; // @addr $65E748
    procedure Init(AOwnerShip: TShip; Faction: TOwnerId; BasicEquipment: Boolean); // @addr $65CA28
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $65CEC0 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $65D088 @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr $65D24C @slot 0x08
    procedure ClearObjectReferences; override; // @addr $65D290 @slot 0x0C
    function GetGreetingShipCategory: TGreetingShipCategory; override; // @addr $65D94C @slot 0x30
    function GetHomeStar: TStar; override; // @addr $65D974 @slot 0x34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $65D98C @slot 0x3C
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $65DA40 @slot 0x60
    procedure BuildReachablePlanetQueue; override; // @addr $65E468 @slot 0x64
    procedure SelectEnemyShipInStar; override; // @addr $65EE68 @slot 0x6C
    procedure EngageEnemyShip; override; // @addr $65EE80 @slot 0x70
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $65EE8C @slot 0x80
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $65EEB8 @slot 0x74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $65EED0 @slot 0x78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $65EEE4 @slot 0x7C
    function RecomputeFearState: Boolean; override; // @addr $65EF40 @slot 0x84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $65EF54 @slot 0x88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $65EF6C @slot 0x8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $65EF90 @slot 0x90
    procedure ProcessCombatDialogue; override; // @addr $65EFB4 @slot 0xA0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $65EFC0 @slot 0xA4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $65EFD0 @slot 0xA8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $65F028 @slot 0xAC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $65F07C @slot 0xB0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $65F0D4 @slot 0xB4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $65F1A0 @slot 0xB8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $65F1F0 @slot 0xBC
    procedure RefreshCurrentStanding; override; // @addr $65F240 @slot 0xC4
    procedure AssignWeaponTargetsInStar; override; // @addr $65E8A0 @slot 0x20
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $65F378 @slot 0x54

    function GetDominantCareer: TRangerCareer; override; // @addr 0x65D960 @slot 0x38 @note "Always rcWarrior."
    function GetName: WideString; override; // @addr 0x65D70C @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x65D738 @slot 0x28 @calls "0x65D726"

    procedure NextDayLogic; override; // @addr 0x65D318 @slot 0x1C @calls "0x65D2F0"
    function TryCollectPreferredFloatingLoot(MaxTravelDays: Integer): Boolean; // @addr 0x65E48C @note "Returns whether a move order is active; nearby pickups can be queued even when the result is false."

    procedure NextDay; override; // @addr 0x65D2B0 @slot 0x18
    constructor Create; // @addr 0x65C738
    destructor Destroy; override; // @addr 0x65C7A8
    procedure ClearCollectionPermissions; // @addr 0x65C7DC
    procedure SetCollectionPermission(Kind: TTranclucatorCollectionKind; Enabled: Boolean); // @addr 0x65C808
    function GetCollectionPermission(Kind: TTranclucatorCollectionKind): Boolean; // @addr 0x65C830
    procedure ResetStoragePermissions; // @addr 0x65C858 @note "Enables planets and disables stations."
    procedure SetStoragePermission(Kind: TTranclucatorStorageKind; Enabled: Boolean); // @addr 0x65C894
    function GetStoragePermission(Kind: TTranclucatorStorageKind): Boolean; // @addr 0x65C8CC @note "Unknown kinds return false."
    procedure TransferUnequippedCargo(Destination: TShip); // @addr 0x65DB34 @note "Moves unequipped inventory and artefacts plus all goods; refreshes Self and the destination player's storage bubbles."
    function CanFollowOwnerInCurrentStar: Boolean; // @addr 0x65D9B8 @note "Checks FollowOwner, owner presence, shared star and owner hyperspace state; does not require docking."
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x65D9A0 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x65DA10 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x65E474 @slot 0x68
  end;

var
  TranclucatorSkillBonusWeights: array[bonSkill1..bonSkill6] of Integer = (100, 100, 80, 80, 60, 60); // @addr $87BE78
  // The $65F3AE dispatch table confines these reads to BonusKind=13..20.
  // Each reloads the unchanged byte at EBP-5; $87BE10 is the base biased by -13*4.
  TranclucatorSlotBonusWeights: array[bonSlotRadar..bonSlotForsage] of Integer = (100, 100, 200, 100, 200, 75, 10, 30); // @addr $87BE90 @indexrefs "$65F731,$65F771,$65F7B1,$65F7E2,$65F83E,$65F87E,$65F8AF,$65F8DE,$65F91C,$65F94D,$65F97C,$65F9BA,$65F9EB,$65FA1A,$65FA58,$65FAB4,$65FAFE,$65FB95,$65FC0F,$65FC6B,$65FD07,$65FD37"

implementation

uses Classes, SysUtils, Math, GR_Main, GlobalsV, aConst, aMyFunction, aItem, aPlayer, aRuins, aScript, aAsteroid;

{ @routine $65C738 TTranclucator_Create }
constructor TTranclucator.Create;
begin
  inherited Create;
  ClearCollectionPermissions;
  ResetStoragePermissions;
  AutoArrange := False;
  StoreOnLanding := False;
  ArtefactSize := 0;
end;
{ @end $65C738 }

{ @routine $65C7A8 TTranclucator_Destroy }
destructor TTranclucator.Destroy;
begin
  inherited Destroy;
end;
{ @end $65C7A8 }

{ @routine $65C7DC TTranclucator_ClearCollectionPermissions }
procedure TTranclucator.ClearCollectionPermissions;
var Kind: TTranclucatorCollectionKind;
begin
  for Kind := Low(TTranclucatorCollectionKind) to High(TTranclucatorCollectionKind) do
    CollectionPermissions[Kind] := False;
end;
{ @end $65C7DC }

{ @routine $65C808 TTranclucator_SetCollectionPermission }
procedure TTranclucator.SetCollectionPermission(Kind: TTranclucatorCollectionKind; Enabled: Boolean);
begin
  CollectionPermissions[Kind] := Enabled;
end;
{ @end $65C808 }

{ @routine $65C830 TTranclucator_GetCollectionPermission }
function TTranclucator.GetCollectionPermission(Kind: TTranclucatorCollectionKind): Boolean;
begin
  Result := CollectionPermissions[Kind];
end;
{ @end $65C830 }

{ @routine $65C858 TTranclucator_ResetStoragePermissions }
procedure TTranclucator.ResetStoragePermissions;
var Kind: TTranclucatorStorageKind;
begin
  for Kind := Low(TTranclucatorStorageKind) to High(TTranclucatorStorageKind) do StoragePermissions[Kind] := False;
  SetStoragePermission(tskPlanet, True);
end;
{ @end $65C858 }

{ @routine $65C894 TTranclucator_SetStoragePermission }
procedure TTranclucator.SetStoragePermission(Kind: TTranclucatorStorageKind; Enabled: Boolean);
begin
  case Kind of
    tskPlanet: StoragePermissions[tskPlanet] := Enabled;
    tskStation: StoragePermissions[tskStation] := Enabled;
  end;
end;
{ @end $65C894 }

{ @routine $65C8CC TTranclucator_GetStoragePermission }
function TTranclucator.GetStoragePermission(Kind: TTranclucatorStorageKind): Boolean;
begin
  Result := False;
  case Kind of
    tskPlanet: Result := StoragePermissions[tskPlanet];
    tskStation: Result := StoragePermissions[tskStation];
  end;
end;
{ @end $65C8CC }

{ @routine $65CA28 TTranclucator_Init }
procedure TTranclucator.Init(AOwnerShip: TShip; Faction: TOwnerId; BasicEquipment: Boolean);
var
  WeaponType: TItemType;
  MaximumHullSize: Integer;

  // @nested $65C908 RandomHullLevel
  function RandomHullLevel: Integer; // @addr $65C908 @calls "0x65CC45"
  begin
    Result := NextRandomIntRange(1, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 1, 8)), RandomState);
  end;

  // @nested $65C974 RandomEquipmentLevel
  function RandomEquipmentLevel: Integer; // @addr $65C974 @calls "0x65CC5E 0x65CC9C 0x65CCC4 0x65CCEC"
  begin
    Result := NextRandomIntRange(1, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 1, 4)), RandomState);
  end;

  // @nested $65C9E0 RandomEquipmentSize
  function RandomEquipmentSize(BaseSize: Integer): Integer; // @addr $65C9E0 @calls "0x65CB63 0x65CBB2 0x65CC6D 0x65CCAB 0x65CCD3 0x65CCFB 0x65CD49"
  begin
    Result := NextRandomIntRange(Round(BaseSize * EquipmentSizeFactors[3]),
      Round(BaseSize * EquipmentSizeFactors[4]), RandomState);
  end;

begin
  TypeId := stTranclucator;
  if AOwnerShip <> nil then
  begin
    OwnerShip := AOwnerShip;
    CurrentStar := AOwnerShip.CurrentStar;
    CurrentStar.Ships.Add(Self);
  end
  else
  begin
    OwnerShip := nil;
    CurrentStar := nil;
  end;
  OwnerId := Faction;
  HomePlanet := nil;
  CurrentPlanet := nil;
  Position := MakePointF(0, 0);
  MovementDirection := 0;
  Name := '';
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  if BasicEquipment then
  begin
    CreateAndEquipHull(Round(NextRandomIntRange(200, 300, RandomState) * HullCapacityScale), 1, OwnerId, -1, False);
    CreateAndEquipFuelTanks(10, 1, OwnerId);
    CreateAndEquipEngine(RandomEquipmentSize(EngineBaseSize), 2, OwnerId);
    WeaponType := TItemType(NextRandomIntRange(0, 2, RandomState) + Ord(t_Weapon1));
    CreateAndEquipWeapon(WeaponType, RandomEquipmentSize(WeaponInfos[WeaponType].AverageSize), 1, OwnerId);
  end
  else
  begin
    MaximumHullSize := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 300, 800) * HullCapacityScale);
    CreateAndEquipHull(NextRandomIntRange(Round(HullCapacityScale * 200), MaximumHullSize, RandomState), RandomHullLevel, OwnerId, -1, False);
    CreateAndEquipEngine(RandomEquipmentSize(EngineBaseSize), RandomEquipmentLevel, OwnerId);
    CreateAndEquipFuelTanks(10, 1, OwnerId);
    CreateAndEquipDefGenerator(RandomEquipmentSize(DefGeneratorBaseSize), RandomEquipmentLevel, OwnerId);
    CreateAndEquipRepairRobot(RandomEquipmentSize(RepairRobotBaseSize), RandomEquipmentLevel, OwnerId);
    CreateAndEquipCargoHook(RandomEquipmentSize(CargoHookBaseSize), RandomEquipmentLevel, OwnerId);
    WeaponType := TItemType(NextRandomIntRange(0, 2, RandomState) + Ord(t_Weapon1));
    CreateAndEquipWeapon(WeaponType, RandomEquipmentSize(WeaponInfos[WeaponType].AverageSize), 1, OwnerId);
    BaseSkills[psAccuracy] := NextRandomIntRange(0, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6)), RandomState);
    BaseSkills[psManeuverability] := NextRandomIntRange(0, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6)), RandomState);
    BaseSkills[psTechnical] := NextRandomIntRange(0, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6)), RandomState);
  end;
  TechKnowledge := 8;
  if GetCargoFreeSpace < 0 then GetHull.Weight := GetHull.Weight + Abs(GetCargoFreeSpace);
  RefreshGraphicSize;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
end;
{ @end $65CA28 }

{ @routine $65CEC0 TTranclucator_SaveToBuffer }
procedure TTranclucator.SaveToBuffer(Buffer: TBufEC);
var Kind: TTranclucatorCollectionKind;
    StorageKind: TTranclucatorStorageKind;
begin
  inherited SaveToBuffer(Buffer);
  if OwnerShip = nil then Buffer.AddDWord(0) else Buffer.AddDWord(OwnerShip.Id);
  Buffer.AddBoolean(FollowOwner);
  Buffer.AddBoolean(SeekItems);
  Buffer.AddBoolean(AutoArrange);
  Buffer.AddIntegerValue(ArtefactSize);
  if ArtefactSystemName = '' then Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(ArtefactSystemName);
  end;
  for Kind := Low(TTranclucatorCollectionKind) to High(TTranclucatorCollectionKind) do
    Buffer.AddBoolean(CollectionPermissions[Kind]);
  for StorageKind := Low(TTranclucatorStorageKind) to High(TTranclucatorStorageKind) do Buffer.AddBoolean(StoragePermissions[StorageKind]);
  Buffer.AddBoolean(StoreOnLanding);
end;
{ @end $65CEC0 }

{ @routine $65D088 TTranclucator_LoadFromBuffer }
procedure TTranclucator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, OldItemCount: Integer;
  Kind: TTranclucatorCollectionKind;
  StorageKind: TTranclucatorStorageKind;

  // @nested $65CFE0 ReadOldPermission
  procedure ReadOldPermission(ItemType: TItemType); // @addr $65CFE0 @calls "0x65D1E3"
  var Enabled: Boolean;
  begin
    Enabled := Buffer.GetBoolean;
    case ItemType of
      t_Food: CollectionPermissions[tckGoods] := Enabled;
      t_Artefact: CollectionPermissions[tckArtefact] := Enabled;
      t_FuelTanks: CollectionPermissions[tckEquipment] := Enabled;
      t_Protoplasm: CollectionPermissions[tckCountable] := Enabled;
      t_UselessItem: CollectionPermissions[tckUseless] := Enabled;
      t_MicroModule: CollectionPermissions[tckMicroModule] := Enabled;
    end;
  end;

begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  OwnerShip := TShip(Buffer.GetUInt32);
  FollowOwner := Buffer.GetBoolean;
  SeekItems := Buffer.GetBoolean;
  AutoArrange := Buffer.GetBoolean;
  ArtefactSize := Buffer.GetInt32;
  if LoadedSaveVersion < 129 then Buffer.GetByte;
  if (LoadedSaveVersion >= 86) and Buffer.GetBoolean then ArtefactSystemName := Buffer.ReadWideString;
  if LoadedSaveVersion >= 131 then
    for Kind := Low(TTranclucatorCollectionKind) to High(TTranclucatorCollectionKind) do
      CollectionPermissions[Kind] := Buffer.GetBoolean
  else
  begin
    if LoadedSaveVersion < 78 then OldItemCount := 68
    else if LoadedSaveVersion < 96 then OldItemCount := 72
    else if LoadedSaveVersion < 127 then OldItemCount := 73
    else OldItemCount := 74;
    for I := 0 to OldItemCount - 1 do ReadOldPermission(MigrateSavedItemType(I));
  end;
  for StorageKind := Low(TTranclucatorStorageKind) to High(TTranclucatorStorageKind) do StoragePermissions[StorageKind] := Buffer.GetBoolean;
  StoreOnLanding := Buffer.GetBoolean;
end;
{ @end $65D088 }

{ @routine $65D24C TTranclucator_ResolveLoadedReferences }
procedure TTranclucator.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  OwnerShip := TObject(Galaxy.IdToShip(Integer(OwnerShip), True)) as TShip;
  inherited ResolveLoadedReferences(Galaxy);
end;
{ @end $65D24C }

{ @routine $65D290 TTranclucator_ClearObjectReferences }
procedure TTranclucator.ClearObjectReferences;
begin
  OwnerShip := nil;
  inherited ClearObjectReferences;
end;
{ @end $65D290 }

{ @routine $65D2B0 TTranclucator_NextDay }
procedure TTranclucator.NextDay;
begin
  inherited NextDay;
  if (ScriptShip <> nil) and HasScriptControl then
  begin
    ScriptNextDay;
    if ScriptShip <> nil then Exit;
  end;
  NextDayLogic;
  if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
end;
{ @end $65D2B0 }

// Zero-byte pointer additions retain the native evaluation order of IndexOf.
{ @routine $65D318 TTranclucator_NextDayLogic }
procedure TTranclucator.NextDayLogic;
var Stage: Integer;
begin
  Stage := 1;
  try
    if (GetEngine = nil) or (GetFuelTanks = nil) then EquipEssentialInventory;
    Stage := 2;
    if AutoArrange or (OwnerShip = nil) then
    begin
      AutoEquipInventory;
      AutoEquipArtefacts;
    end;
    RepairBrokenEquipmentAtLocation;
    Stage := 3;
    if IsOnPlanet or IsDockedToShip then
    begin
      Stage := 4;
      if StoreOnLanding then
      begin
        Stage := 5;
        if not ConvertToStoredArtefact then UnloadCargoForPlayerOwner;
      end
      else
      begin
        Stage := 6;
        UnloadCargoForPlayerOwner;
        if CargoFreeSpace < 0 then
        begin
          Stage := 7;
          DropCargoUntilNotOverloaded;
          if CargoFreeSpace < 0 then ConvertToStoredArtefact else OrderTakeoff;
        end;
      end;
      Stage := 8;
    end
    else if InNormalSpace then
    begin
      Stage := 9;
      AssignWeaponTargetsInStar;
      Stage := 10;
      if CargoFreeSpace < 0 then
      begin
        Stage := 11;
        DropCargoUntilNotOverloaded;
      end
      else if not (SeekItems and (CargoFreeSpace > 0) and TryCollectPreferredFloatingLoot(50)) then
        if not (SeekItems and TryLandForStorage) then
          if FollowOwner and (OwnerShip <> nil) then
          begin
            Stage := 12;
            OrderFollowShip(OwnerShip, 0, False);
          end
          else
          begin
            Stage := 13;
            if not OrderAbsolute then UpdateFreeFlightOrder;
          end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create(AnsiString('Error in procedure TTranclucator.NextDayLogic ' + GetFullName(' ') + ' label = ' + WideString(IntToStr(Stage))));
    end;
  end;
end;
{ @end $65D318 }

{ @routine $65D70C TTranclucator_GetName }
function TTranclucator.GetName: WideString;
begin
  Result := GetFullName(' ');
end;
{ @end $65D70C }

{ @routine $65D738 TTranclucator_GetFullName }
function TTranclucator.GetFullName(const Separator: WideString): WideString;
var Path, DisplayName, TypeName: WideString;
begin
  if Name <> '' then DisplayName := Name
  else DisplayName := LookupLocalizedTextByKey('Artefacts.ArtTranclucator.Name') + '-' + WideString(IntToStr(Cardinal(Id)));
  if TypeNameOverrideKey = '' then Result := DisplayName
  else
  begin
    Path := 'ShipType.' + ShipTypeNames[stTranclucator].Name + '.' + TypeNameOverrideKey;
    if LanguageDataConfig.CountParamsByPath(Path) > 0 then TypeName := LocalizedText(Path)
    else TypeName := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if TypeName <> '' then Result := TypeName + Separator + Name
    else Result := Name;
  end;
end;
{ @end $65D738 }

{ @routine $65D94C TTranclucator_GetGreetingShipCategory }
function TTranclucator.GetGreetingShipCategory: TGreetingShipCategory;
begin
  Result := gscTransport; // Native default category, also used for transports.
end;
{ @end $65D94C }

{ @routine $65D960 TTranclucator_GetDominantCareer }
function TTranclucator.GetDominantCareer: TRangerCareer;
begin
  Result := rcWarrior;
end;
{ @end $65D960 }

{ @routine $65D974 TTranclucator_GetHomeStar }
function TTranclucator.GetHomeStar: TStar;
begin
  Result := nil;
end;
{ @end $65D974 }

{ @routine $65D98C TTranclucator_GetStrengthScaledPirateStatus }
function TTranclucator.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 100;
end;
{ @end $65D98C }

{ @routine $65D9A0 TTranclucator_GetDesiredCargoFreeSpace }
function TTranclucator.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $65D9A0 }

{ @routine $65D9B8 TTranclucator_CanFollowOwnerInCurrentStar }
function TTranclucator.CanFollowOwnerInCurrentStar: Boolean;
begin
  Result := FollowOwner and (OwnerShip <> nil) and (OwnerShip.CurrentStar = CurrentStar) and not OwnerShip.InHyperspace;
end;
{ @end $65D9B8 }

{ @routine $65DA10 TTranclucator_RefuelAtLocation }
procedure TTranclucator.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $65DA10 }

{ @routine $65DA40 TTranclucator_RepairBrokenEquipmentAtLocation }
procedure TTranclucator.RepairBrokenEquipmentAtLocation;
begin
  if (GetEngine <> nil) and ((GetEngine.BrokenFlag <> 0) or (GetEngine.ConditionPercent < 1)) then
  begin
    GetEngine.ConditionPercent := 1;
    GetEngine.BrokenFlag := 0;
  end;
  if (GetFuelTanks <> nil) and ((GetFuelTanks.BrokenFlag <> 0) or (GetFuelTanks.ConditionPercent < 1)) then
  begin
    GetFuelTanks.ConditionPercent := 1;
    GetFuelTanks.BrokenFlag := 0;
  end;
end;
{ @end $65DA40 }

{ @routine $65DB34 TTranclucator_TransferUnequippedCargo }
procedure TTranclucator.TransferUnequippedCargo(Destination: TShip);
var
  I: Integer;
  Item: TEquipment;
  Artefact: TArtefact;
  Good: Byte;

  // @nested $65DAF0 AddGoods
  procedure AddGoods(Good: Byte; Quantity, Cost: Integer); // @addr $65DAF0 @note "Nested helper; caller-popped static link, destination at ParentFrame-4."
  begin
    if Quantity > 0 then
    begin
      Inc(Destination.CargoGoods[Good].Count, Quantity);
      Inc(Destination.CargoGoods[Good].TotalCost, Cost);
    end;
  end;

begin
  for I := Inventory.Count - 1 downto 0 do
  begin
    Item := TEquipment(Inventory[I]);
    if Item.EquippedFlag <> 0 then Continue;
    Inventory.Delete(Inventory.IndexOf(Item));
    Destination.Inventory.Add(Item);
  end;
  for I := Artefacts.Count - 1 downto 0 do
  begin
    Artefact := TArtefact(Artefacts[I]);
    if Artefact.EquippedFlag <> 0 then Continue;
    Artefacts.Delete(Artefacts.IndexOf(Artefact));
    Destination.Artefacts.Add(Artefact);
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    with CargoGoods[Good] do
    begin
      AddGoods(Good, Count, TotalCost);
      Count := 0;
      TotalCost := 0;
      PurchasedCount := 0;
      PurchasedTotalCost := 0;
    end;
  RefreshDerivedStats(True);
  if GetPlayer = Destination then GetPlayer.RefreshStorageBubbles;
end;
{ @end $65DB34 }

{ @routine $65DC90 TTranclucator_StoreUnequippedCargoAt }
procedure TTranclucator.StoreUnequippedCargoAt(Location: TObject);
var Good: Byte;
    I: Integer;
    Item: TEquipment;
    Artefact: TArtefact;
begin
  if not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [oiMaloc..oiGaal, oiPirate]) then
  begin
    for I := Inventory.Count - 1 downto 0 do
    begin
      Item := TEquipment(Inventory[I]);
      if Item.EquippedFlag <> 0 then Continue;
      GetPlayer.AddItemToPlayerStorage(Item, Location, -1);
      Inventory.Delete(Inventory.IndexOf(Item));
    end;
    for I := Artefacts.Count - 1 downto 0 do
    begin
      Artefact := TArtefact(Artefacts[I]);
      if Artefact.EquippedFlag <> 0 then Continue;
      GetPlayer.AddItemToPlayerStorage(Artefact, Location, -1);
      Artefacts.Delete(Artefacts.IndexOf(Artefact));
    end;
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
      with CargoGoods[Good] do
      begin
        GetPlayer.AddGoodsToPlayerStorage(Good, Count, TotalCost, Location, -1);
        Count := 0;
        TotalCost := 0;
        PurchasedCount := 0;
        PurchasedTotalCost := 0;
      end;
    RefreshDerivedStats(True);
    GetPlayer.RefreshStorageBubbles;
  end;
end;
{ @end $65DC90 }

{ @routine $65DE1C TTranclucator_UnloadCargoForPlayerOwner }
function TTranclucator.UnloadCargoForPlayerOwner: Boolean;
begin
  Result := False;
  if (OwnerShip <> nil) and (GetPlayer <> nil) and (GetPlayer = OwnerShip) then
  begin
    if IsOnPlanet then
    begin
      StoreUnequippedCargoAt(CurrentPlanet);
      if CargoFreeSpace >= 0 then OrderTakeoff;
      Result := True;
    end
    else if IsDockedToShip then
    begin
      StoreUnequippedCargoAt(DockedTo);
      if (CargoFreeSpace >= 0) and DockedTo.InNormalSpace then OrderTakeoff
      else OrderNone(False);
      Result := True;
    end;
  end;
end;
{ @end $65DE1C }

{ @routine $65DEE4 TTranclucator_TryLandForStorage }
function TTranclucator.TryLandForStorage: Boolean;
var I: Integer;
    Location: TObject;
    Planet: TPlanet;
    Ship: TShip;
    Distance, BestDistance: Double;
begin
  Result := False;
  if (OwnerShip <> nil) and (GetPlayer <> nil) and (GetPlayer = OwnerShip) and HasLooseNonScriptItemsOrGoods then
  begin
    BestDistance := 10000;
    Location := nil;
    if GetStoragePermission(tskPlanet) then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := TPlanet(CurrentStar.Planets[I]);
        if (Planet.OwnerId in [oiMaloc..oiGaal, oiPirate]) and (Planet.GetRelationLevelToShip(GetPlayer) >= rlNormal) then
        begin
          Distance := PointDistance(Position, Planet.GetPosition);
          if BestDistance >= Distance then
          begin
            Location := Planet;
            BestDistance := Distance;
          end;
        end;
      end;
    if GetStoragePermission(tskStation) then
      for I := 0 to CurrentStar.Ships.Count - 1 do
      begin
        Ship := TShip(CurrentStar.Ships[I]);
        if (Ship is TRuins) and (Ship.GetRelationLevelToShip(GetPlayer) >= rlNormal) and Ship.CanDock(Self) then
        begin
          Distance := PointDistance(Position, Ship.Position);
          if BestDistance >= Distance then
          begin
            Location := Ship;
            BestDistance := Distance;
          end;
        end;
      end;
    if Location <> nil then
    begin
      OrderLanding(Location, True);
      Result := True;
    end;
  end;
end;
{ @end $65DEE4 }

{ @routine $65E0D0 TTranclucator_ConvertToStoredArtefact }
function TTranclucator.ConvertToStoredArtefact: Boolean;
var I, Index: Integer;
    Location: TObject;
    Artefact: TArtefactTranclucator;
begin
  Result := False;
  StoreOnLanding := False;
  SeekItems := False;
  FollowOwner := False;
  if IsOnPlanet then Location := CurrentPlanet
  else if IsDockedToShip then Location := DockedTo
  else Exit;
  if (OwnerShip <> nil) and (not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [oiMaloc..oiGaal, oiPirate])) then
  begin
    EnemyShip := nil;
    TruceShip := nil;
    PartnerShip := nil;
    OrderNone(False);
    AfterburnerActive := False;
    for I := 1 to WeaponCount do Weapons[I].Target := nil;
    if ScriptShip <> nil then (ScriptShip as TScriptShip).Script.UnbindShip(Self);
    if CurrentStar <> nil then
    begin
      Index := CurrentStar.Ships.IndexOf(Self);
      if Index >= 0 then CurrentStar.Ships.Delete(Index);
    end;
    CurrentStar := nil;
    DockedTo := nil;
    CurrentPlanet := nil;
    if GetEngine <> nil then GetEngine.OutputPercent := 100;
    StoreUnequippedCargoAt(Location);
    Artefact := TArtefactTranclucator.Create;
    Artefact.InitTranclucator(GetHull.OwnerId, OwnerShip, Self);
    OwnerShip.AddItemToPlayerStorage(Artefact, Location, -1);
    GetPlayer.RefreshStorageBubbles;
    OwnerShip.RefreshDerivedStats(True);
    ScriptItemsAct(satOnTrancPacking, Artefact, Location, 0);
    GetPlayer.ScriptItemsAct(satOnTrancPacking, Artefact, Location, 0);
    Result := True;
  end;
end;
{ @end $65E0D0 }

{ @routine $65E300 TTranclucator_UpdateFreeFlightOrder }
procedure TTranclucator.UpdateFreeFlightOrder;
begin
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
    OrderFollowShip(EnemyShip, 1, False)
  else if (OwnerShip <> nil) and (OwnerShip.CurrentStar = CurrentStar) and OwnerShip.InNormalSpace then
  begin
    if (OwnerShip.Order = soFollowShip) and (OwnerShip.EnemyShip = OwnerShip.OrderTarget) and (OwnerShip.EnemyShip <> Self) then
      OrderFollowShip(OwnerShip.EnemyShip, 1, False)
    else OrderFollowShip(OwnerShip, 0, False);
  end
  else if (OwnerShip <> nil) and (OwnerShip.CurrentStar = CurrentStar) and (OwnerShip.CurrentPlanet <> nil) then
    OrderMove(OwnerShip.CurrentPlanet.GetPosition, False)
  else OrderRandomFreeFlightMove;
end;
{ @end $65E300 }

{ @routine $65E468 TTranclucator_BuildReachablePlanetQueue }
procedure TTranclucator.BuildReachablePlanetQueue;
begin

end;
{ @end $65E468 }

{ @routine $65E474 TTranclucator_CanQueueReachablePlanet }
function TTranclucator.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := False;
end;
{ @end $65E474 }

{ @routine $65E48C TTranclucator_TryCollectPreferredFloatingLoot }
function TTranclucator.TryCollectPreferredFloatingLoot(MaxTravelDays: Integer): Boolean;
var I: Integer;
    Item, TargetItem: TItem;
    HaveTarget: Boolean;
    Distance, BestDistance: Double;
begin
  Result := False;
  if IsEquipmentUsable(GetCargoHook) and (Speed >= 1) then
  begin
    HaveTarget := False;
    TargetItem := nil;
    BestDistance := 10000;
    for I := 0 to CurrentStar.Items.Count - 1 do
    begin
      Item := TItem(CurrentStar.Items[I]);
      if (CalculateCargoHookPower(GetCargoHook) >= Item.Weight) and
        ((Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '')) and
        not (Item is TArtefactTranclucator) then
      begin
        if Item is TGoods then
        begin
          if not CollectionPermissions[tckGoods] then Continue;
        end
        else if Item is TArtefact then
        begin
          if not CollectionPermissions[tckArtefact] then Continue;
        end
        else if Item is TMicroModule then
        begin
          if not CollectionPermissions[tckMicroModule] then Continue;
        end
        else if Item is TCountableItem then
        begin
          if not CollectionPermissions[tckCountable] then Continue;
        end
        else if Item is TUselessItem then
        begin
          if not CollectionPermissions[tckUseless] then Continue;
        end
        else if Item.ItemType in [t_FuelTanks..t_CustomWeapon] then
        begin
          if not CollectionPermissions[tckEquipment] then Continue;
        end
        else if not CollectionPermissions[tckOther] then Continue;
        if (CountOtherShipsTargetingItem(Item) <= 0) and (CargoFreeSpace - GetReservedPickupWeight >= Item.Weight) then
        begin
          if IsItemInPickupRange(Item) then AddPickupTarget(Item, False)
          else
          begin
            Distance := PointDistance(Position, Item.Position);
            if (MaxTravelDays >= Distance / Speed) and (BestDistance >= Distance) then
            begin
              TargetItem := Item;
              HaveTarget := True;
              BestDistance := Distance;
            end;
          end;
        end;
      end;
    end;
    if TargetItem <> nil then OrderMove(GetPickupApproachPosition(TargetItem.Position), True);
    if not HaveTarget and (Order = soMove) then OrderNone(False);
    if Order = soMove then Result := True;
  end;
end;
{ @end $65E48C }

{ @routine $65E748 TTranclucator_EquipEssentialInventory }
procedure TTranclucator.EquipEssentialInventory;
var I: Integer;
    Item: TItem;
begin
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := TItem(Inventory[I]);
    case Byte(Item.ItemType) of
      Ord(t_FuelTanks):
        if GetFuelTanks = nil then EquipItem(Item as TFuelTanks)
        else if GetFuelTanks.Weight > Item.Weight then
        begin
          UnequipSlot(GetFuelTanks.ItemType, 0);
          EquipItem(Item as TFuelTanks);
        end;
      Ord(t_Engine):
        if GetEngine = nil then EquipItem(Item as TEngine)
        else if CalculateItemEffectiveness(Item) > CalculateItemEffectiveness(GetEngine) then
        begin
          UnequipSlot(GetEngine.ItemType, 0);
          EquipItem(Item as TEngine);
        end;
    end;
  end;
  RefreshDerivedStats(True);
end;
{ @end $65E748 }

{ @routine $65E8A0 TTranclucator_AssignWeaponTargetsInStar }
procedure TTranclucator.AssignWeaponTargetsInStar;
var I, J, AssignedCount: Integer;
    Ship: TShip;
    Weapon: TWeapon;
    Distance: Double;
    Asteroid: TAsteroid;
begin
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    Weapon.Target := nil;
  end;
  AssignedCount := 0;
  if OwnerShip <> nil then
  begin
    // The native code repeats the owner guard before following its enemy.
    if (OwnerShip <> nil) and (OwnerShip.EnemyShip <> nil) and (OwnerShip.EnemyShip <> Self) and
      (OwnerShip.EnemyShip.CurrentStar = CurrentStar) and OwnerShip.EnemyShip.InNormalSpace then
      for J := 1 to WeaponCount do
      begin
        Weapon := Weapons[J];
        if (Weapon.Target = nil) and IsEquipmentUsable(Weapon) and
          (PointDistanceSquared(Position, OwnerShip.EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon))) then
        begin
          Weapon.Target := OwnerShip.EnemyShip;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
        end;
      end;
    if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
      for J := 1 to WeaponCount do
      begin
        Weapon := Weapons[J];
        if (Weapon.Target = nil) and IsEquipmentUsable(Weapon) and
          (PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon))) then
        begin
          Weapon.Target := EnemyShip;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
        end;
      end;
    if CurrentStar.Battle <> 0 then
      for I := 0 to CurrentStar.Ships.Count - 1 do
      begin
        Ship := TShip(CurrentStar.Ships[I]);
        if (Ship.OwnerId = oiDominator) and Ship.InNormalSpace then
        begin
          Distance := PointDistance(Position, Ship.Position);
          for J := 1 to WeaponCount do
          begin
            Weapon := Weapons[J];
            if (Weapon.Target = nil) and IsEquipmentUsable(Weapon) and (GetWeaponRange(Weapon) >= Distance) then
            begin
              Weapon.Target := Ship;
              Inc(AssignedCount);
              if WeaponCount = AssignedCount then Exit;
            end;
          end;
        end;
      end;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if Ship.InNormalSpace and (Ship <> Self) and (Ship <> OwnerShip) and
        ((RelationToShip(Ship) < RelationBadMin) or (Ship = EnemyShip) or (Ship.EnemyShip = Self)) then
        for J := 1 to WeaponCount do
        begin
          Weapon := Weapons[J];
          if (Weapon.Target = nil) and IsEquipmentUsable(Weapon) and
            (PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon))) then
          begin
            Weapon.Target := Ship;
            Inc(AssignedCount);
            if WeaponCount = AssignedCount then Exit;
          end;
        end;
    end;
    if GetPlayer.CurrentStar = CurrentStar then
      for I := 0 to CurrentStar.Asteroids.Count - 1 do
      begin
        Asteroid := TAsteroid(CurrentStar.Asteroids[I]);
        Distance := PointDistanceSquared(Position, Asteroid.Position);
        if Distance <= AsteroidTargetRangeSquared then
          for J := 1 to WeaponCount do
          begin
            Weapon := Weapons[J];
            if not (Weapon.GetWeaponInfo^.ShotType in [wstAreaDamage..wstRocket]) and
              (Weapon.Target = nil) and IsEquipmentUsable(Weapon) and (Sqr(GetWeaponRange(Weapon)) >= Distance) then
            begin
              Weapon.Target := Asteroid;
              Inc(AssignedCount);
              if WeaponCount = AssignedCount then Exit;
              Break;
            end;
          end;
      end;
  end;
end;
{ @end $65E8A0 }

{ @routine $65EE68 TTranclucator_SelectEnemyShipInStar }
procedure TTranclucator.SelectEnemyShipInStar;
begin
  EnemyShip := nil;
end;
{ @end $65EE68 }

{ @routine $65EE80 TTranclucator_EngageEnemyShip }
procedure TTranclucator.EngageEnemyShip;
begin

end;
{ @end $65EE80 }

{ @routine $65EE8C TTranclucator_RelationToNonRanger }
function TTranclucator.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship.TypeId in [stKling, stTranclucator] then Result := 50 else Result := 100;
end;
{ @end $65EE8C }

{ @routine $65EEB8 TTranclucator_RelationToRanger }
function TTranclucator.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := 100;
end;
{ @end $65EEB8 }

{ @routine $65EED0 TTranclucator_ChangeRelationToRanger }
procedure TTranclucator.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
begin

end;
{ @end $65EED0 }

{ @routine $65EEE4 TTranclucator_ReactToAttack }
procedure TTranclucator.ReactToAttack(Attacker: TShip);
begin
  if (OwnerShip = nil) or ((OwnerShip <> Attacker) and
    (not (Attacker is TTranclucator) or (TTranclucator(Attacker).OwnerShip <> OwnerShip))) then EnemyShip := Attacker;
end;
{ @end $65EEE4 }

{ @routine $65EF40 TTranclucator_RecomputeFearState }
function TTranclucator.RecomputeFearState: Boolean;
begin
  Result := False;
end;
{ @end $65EF40 }

{ @routine $65EF54 TTranclucator_AcceptsRansomDemandFrom }
function TTranclucator.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := False;
end;
{ @end $65EF54 }

{ @routine $65EF6C TTranclucator_TrustsAttackRequester }
function TTranclucator.TrustsAttackRequester(Ship: TShip): Boolean;
begin
  Result := Ship = OwnerShip;
end;
{ @end $65EF6C }

{ @routine $65EF90 TTranclucator_AcceptsAppealFrom }
function TTranclucator.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := Ship = OwnerShip;
end;
{ @end $65EF90 }

{ @routine $65EFB4 TTranclucator_ProcessCombatDialogue }
procedure TTranclucator.ProcessCombatDialogue;
begin

end;
{ @end $65EFB4 }

{ @routine $65EFC0 TTranclucator_ReactToExtortionDemand }
procedure TTranclucator.ReactToExtortionDemand(Ranger: Pointer);
begin

end;
{ @end $65EFC0 }

{ @routine $65EFD0 TTranclucator_BuildMoneyExtortionResponse }
function TTranclucator.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $65EFD0 }

{ @routine $65F028 TTranclucator_BuildCargoExtortionResponse }
function TTranclucator.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $65F028 }

{ @routine $65F07C TTranclucator_BuildTrucePaymentResponse }
function TTranclucator.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $65F07C }

{ @routine $65F0D4 TTranclucator_BuildAttackRequestResponse }
function TTranclucator.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
begin
  Result := True;
  Response := LookupVisibleTalkText('Talk.Tranclucator.Attack.Ok', Requester);
  SetJointAttackTarget(Requester, Target);
  FollowOwner := False;
  SeekItems := False;
end;
{ @end $65F0D4 }

{ @routine $65F1A0 TTranclucator_AcceptPartnershipOffer }
function TTranclucator.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $65F1A0 }

{ @routine $65F1F0 TTranclucator_BuildPartnershipOfferResponse }
function TTranclucator.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $65F1F0 }

{ @routine $65F240 TTranclucator_RefreshCurrentStanding }
procedure TTranclucator.RefreshCurrentStanding;
var StandingMode: TScriptStandingOverrideMode;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then
  begin
    if OwnerShip = nil then CurrentStanding := ssUnaligned
    else
    begin
      OwnerShip.RefreshCurrentStanding;
      if (OwnerShip.CurrentStar = CurrentStar) or (OwnerShip.CurrentStanding in [ssCoalitionMilitary, ssPirateMilitary]) then
        CurrentStanding := OwnerShip.CurrentStanding
      else if OwnerShip.CurrentStanding in [ssCoalitionActive, ssCoalitionPassive] then
      begin
        if CurrentStar.ControlFaction in [sfCoalition, sfDominators] then CurrentStanding := ssCoalitionActive else CurrentStanding := ssNeutral;
      end
      else if OwnerShip.CurrentStanding in [ssPiratePassive, ssPirateActive] then
      begin
        if CurrentStar.ControlFaction in [sfDominators, sfPirates] then CurrentStanding := ssPirateActive else CurrentStanding := ssNeutral;
      end
      else CurrentStanding := OwnerShip.CurrentStanding;
    end;
  end;
end;
{ @end $65F240 }

{ @routine $65F378 TTranclucator_EvaluateStatBonus }
function TTranclucator.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const ScannableDamageFlags = [dkScanBonus..dkDroidBlock];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonHull: Result := Value * 200;
    bonFuel: Result := 0;
    bonSpeed: Result := Value;
    bonJump: Result := 0;
    bonRadar: Result := 0;
    bonScan: Result := Value * 20 * CountWeaponsByDamageFlags(ScannableDamageFlags);
    bonDroid: Result := Value * 10 / Math.Max(0.1, GetHull.GetFragilityFactor([]));
    bonHook: Result := (Value * 0.1 + Math.Min(Value, HullBaseSize * EquipmentSizeFactors[5])) * 1.0;
    bonDef: Result := Value * 5 * 100 / Math.Max(5, 100 - Value) * 45 / Math.Max(5, 45 - Value);
    bonWEnergy: Result := Value * 10;
    bonWSplinter: Result := Value * 10;
    bonWMissile: Result := (Ord(GetRadarRange > 0) * 0.9 + 0.1) * (Value * 10);
    bonWRadius: Result := Sqr(Math.Max(100, SmoothedEnemySpeed) / Math.Max(100, SmoothedSpeed)) * Value;
    bonHookRadius: Result := Value * 0.1;
    bonMass: Result := RemapClamped(Value, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 5000;
    bonSlotRadar:
      if (GetSlotCount(sskRadar) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[BonusKind] - TranclucatorSlotBonusWeights[bonSlotWeapon] * CountMissileWeapons
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[BonusKind] - CountWeaponsByDamageFlags(ScannableDamageFlags) * 0.1 * TranclucatorSlotBonusWeights[bonSlotWeapon]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotHook:
      if (GetSlotCount(sskCargoHook) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskCargoHook) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[BonusKind] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Math.Min(Value, 5 - GetSlotCount(sskWeapon)) * TranclucatorSlotBonusWeights[BonusKind];
        if Value < 0 then
          Result := Math.Max(Value, -GetSlotCount(sskWeapon)) * TranclucatorSlotBonusWeights[BonusKind];
        if CountEquippedWeapons > Math.Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - (CountEquippedWeapons - Math.Max(1, Value + GetSlotCount(sskWeapon))) * (TranclucatorSlotBonusWeights[BonusKind] * 0.6);
      end;
    bonSlotArt:
      begin
        if (GetSlotCount(sskArtefact) < DefaultHullSlotCounts[sskArtefact]) and (Value > 0) then
          Result := Math.Min(Value, DefaultHullSlotCounts[sskArtefact] - GetSlotCount(sskArtefact)) * TranclucatorSlotBonusWeights[BonusKind];
        if Value < 0 then
          Result := Math.Max(Value, -GetSlotCount(sskArtefact)) * TranclucatorSlotBonusWeights[BonusKind];
        if (Artefacts <> nil) and (Artefacts.Count > Math.Max(Value + GetSlotCount(sskArtefact), 0)) then Result := -1000;
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := TranclucatorSlotBonusWeights[BonusKind]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -TranclucatorSlotBonusWeights[BonusKind];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Math.Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), Value) * TranclucatorSkillBonusWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) > 6) then
          Result := (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) - 6) * (TranclucatorSkillBonusWeights[BonusKind] * 0.05) + Result;
        if Value < 0 then
          Result := Math.Min(GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]), -Value) * -TranclucatorSkillBonusWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]) < 0) then
          Result := (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)])) * (TranclucatorSkillBonusWeights[BonusKind] * 0.03) + Result;
      end;
  else
    Result := 0;
  end;
end;
{ @end $65F378 }

end.
