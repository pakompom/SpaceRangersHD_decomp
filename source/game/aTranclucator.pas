unit aTranclucator;
// Unit bracket (inferred): .text 0x005CD9E0..0x005D1311; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    CollectionPermissions: array[0..6] of Boolean; // @offset $4E0 Script.SeekPermitNone through SeekPermitNode.
    StoragePermissions: array[1..2] of Boolean; // @offset $4E7 Planet and station storage switches.

    procedure StoreUnequippedCargoAt(Location: TObject); // @addr $5CF074
    function UnloadCargoForPlayerOwner: Boolean; // @addr $5CF200
    function TryLandForStorage: Boolean; // @addr $5CF2C8
    function ConvertToStoredArtefact: Boolean; // @addr $5CF4B4
    procedure UpdateFreeFlightOrder; // @addr $5CF6E4
    procedure EquipEssentialInventory; // @addr $5CFB2C
    procedure Init(AOwnerShip: TShip; Faction: Byte; BasicEquipment: Boolean); // @addr $5CDE0C
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $5CE2A4 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $5CE46C @slot 0x04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr $5CE630 @slot 0x08
    procedure ClearObjectReferences; override; // @addr $5CE674 @slot 0x0C
    function GetGreetingShipCategory: Byte; override; // @addr $5CED30 @slot 0x30
    function GetHomeStar: TStar; override; // @addr $5CED58 @slot 0x34
    function GetStrengthScaledPirateStatus: Byte; override; // @addr $5CED70 @slot 0x3C
    procedure RepairBrokenEquipmentAtLocation; override; // @addr $5CEE24 @slot 0x60
    procedure BuildReachablePlanetQueue; override; // @addr $5CF84C @slot 0x64
    procedure SelectEnemyShipInStar; override; // @addr $5D024C @slot 0x6C
    procedure EngageEnemyShip; override; // @addr $5D0264 @slot 0x70
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $5D0270 @slot 0x80
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr $5D029C @slot 0x74
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr $5D02B4 @slot 0x78
    procedure ReactToAttack(Attacker: TShip); override; // @addr $5D02C8 @slot 0x7C
    function RecomputeFearState: Boolean; override; // @addr $5D0324 @slot 0x84
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $5D0338 @slot 0x88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $5D0350 @slot 0x8C
    function EvaluateAllyRelationAndStrength(Ship: TShip): Boolean; override; // @addr $5D0374 @slot 0x90
    procedure ProcessCombatDialogue; override; // @addr $5D0398 @slot 0xA0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $5D03A4 @slot 0xA4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $5D03B4 @slot 0xA8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $5D040C @slot 0xAC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $5D0460 @slot 0xB0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $5D04B8 @slot 0xB4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $5D0584 @slot 0xB8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $5D05D4 @slot 0xBC
    procedure RefreshCurrentStanding; override; // @addr $5D0624 @slot 0xC4
    procedure AssignWeaponTargetsInStar; override; // @addr $5CFC84 @slot 0x20
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $5D075C @slot 0x54

    function GetDominantCareer: TRangerCareer; override; // @addr 0x5CED44 @slot 0x38 @note "Always rcWarrior."
    function GetName: WideString; override; // @addr 0x5CEAF0 @slot 0x24 @ida "void __usercall $name(TTranclucator *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x5CEB1C @slot 0x28 @calls "0x5CEB0A" @ida "void __usercall $name(TTranclucator *Self@<eax>, unsigned __int16 *Separator@<edx>, unsigned __int16 **Result@<ecx>);"

    procedure NextDayLogic; override; // @addr 0x5CE6FC @slot 0x1C @calls "0x5CE6D4"
    function TryCollectPreferredFloatingLoot(MaxTravelDays: Integer): Boolean; // @addr 0x5CF870 @note "Returns whether a move order is active; nearby pickups can be queued even when the result is false."

    procedure NextDay; override; // @addr 0x5CE694 @slot 0x18
    constructor Create; // @addr 0x5CDB1C @ida "TTranclucator *__usercall $name@<eax>(void *SelfOrClass@<eax>, unsigned __int8 Allocate@<dl>);"
    destructor Destroy; override; // @addr 0x5CDB8C @ida "void __usercall $name(TTranclucator *Self@<eax>, __int8 DestroyFlags@<dl>);"
    procedure ClearCollectionPermissions; // @addr 0x5CDBC0
    procedure SetCollectionPermission(Kind: TTranclucatorCollectionKind; Enabled: Boolean); // @addr 0x5CDBEC
    function GetCollectionPermission(Kind: TTranclucatorCollectionKind): Boolean; // @addr 0x5CDC14
    procedure ResetStoragePermissions; // @addr 0x5CDC3C @note "Enables planets and disables stations."
    procedure SetStoragePermission(Kind: TTranclucatorStorageKind; Enabled: Boolean); // @addr 0x5CDC78
    function GetStoragePermission(Kind: TTranclucatorStorageKind): Boolean; // @addr 0x5CDCB0 @note "Unknown kinds return false."
    procedure TransferUnequippedCargo(Destination: TShip); // @addr 0x5CEF18 @note "Moves unequipped inventory and artefacts plus all goods; refreshes Self and the destination player's storage bubbles."
    function CanFollowOwnerInCurrentStar: Boolean; // @addr 0x5CED9C @note "Checks FollowOwner, owner presence, shared star and owner hyperspace state; does not require docking."
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x5CED84 @slot 0x40
    procedure RefuelAtLocation; override; // @addr 0x5CEDF4 @slot 0x48 @note "Fills installed fuel tanks without charging Money."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x5CF858 @slot 0x68
  end;

var
  TranclucatorSkillBonusWeights: array[22..27] of Integer = (100, 100, 80, 80, 60, 60); // @addr $87B5C0
  // The $5D0792 dispatch table confines these reads to BonusKind=13..20.
  // Each reloads the unchanged byte at EBP-5; $87B5A4 is the base biased by -13*4.
  TranclucatorSlotBonusWeights: array[13..20] of Integer = (100, 100, 200, 100, 200, 75, 10, 30); // @addr $87B5D8 @indexrefs "$5D0B15,$5D0B55,$5D0B95,$5D0BC6,$5D0C22,$5D0C62,$5D0C93,$5D0CC2,$5D0D00,$5D0D31,$5D0D60,$5D0D9E,$5D0DCF,$5D0DFE,$5D0E3C,$5D0E98,$5D0EE2,$5D0F79,$5D0FF3,$5D104F,$5D10EB,$5D111B"

implementation

uses Classes, SysUtils, Math, GR_Main, GlobalsV, aConst, aMyFunction, aItem, aPlayer, aRuins, aScript, aAsteroid;

{ @routine $5CDB1C TTranclucator_Create }
constructor TTranclucator.Create;
begin
  inherited Create;
  ClearCollectionPermissions;
  ResetStoragePermissions;
  AutoArrange := False;
  StoreOnLanding := False;
  ArtefactSize := 0;
end;
{ @end $5CDB1C }

{ @routine $5CDB8C TTranclucator_Destroy }
destructor TTranclucator.Destroy;
begin
  inherited Destroy;
end;
{ @end $5CDB8C }

{ @routine $5CDBC0 TTranclucator_ClearCollectionPermissions }
procedure TTranclucator.ClearCollectionPermissions;
var Kind: TTranclucatorCollectionKind;
begin
  for Kind := Low(TTranclucatorCollectionKind) to High(TTranclucatorCollectionKind) do
    CollectionPermissions[Ord(Kind)] := False;
end;
{ @end $5CDBC0 }

{ @routine $5CDBEC TTranclucator_SetCollectionPermission }
procedure TTranclucator.SetCollectionPermission(Kind: TTranclucatorCollectionKind; Enabled: Boolean);
begin
  CollectionPermissions[Ord(Kind)] := Enabled;
end;
{ @end $5CDBEC }

{ @routine $5CDC14 TTranclucator_GetCollectionPermission }
function TTranclucator.GetCollectionPermission(Kind: TTranclucatorCollectionKind): Boolean;
begin
  Result := CollectionPermissions[Ord(Kind)];
end;
{ @end $5CDC14 }

{ @routine $5CDC3C TTranclucator_ResetStoragePermissions }
procedure TTranclucator.ResetStoragePermissions;
var Kind: Integer;
begin
  for Kind := 1 to 2 do StoragePermissions[Ord(Kind)] := False;
  SetStoragePermission(tskPlanet, True);
end;
{ @end $5CDC3C }

{ @routine $5CDC78 TTranclucator_SetStoragePermission }
procedure TTranclucator.SetStoragePermission(Kind: TTranclucatorStorageKind; Enabled: Boolean);
begin
  case Kind of
    tskPlanet: StoragePermissions[Ord(tskPlanet)] := Enabled;
    tskStation: StoragePermissions[Ord(tskStation)] := Enabled;
  end;
end;
{ @end $5CDC78 }

{ @routine $5CDCB0 TTranclucator_GetStoragePermission }
function TTranclucator.GetStoragePermission(Kind: TTranclucatorStorageKind): Boolean;
begin
  Result := False;
  case Kind of
    tskPlanet: Result := StoragePermissions[Ord(tskPlanet)];
    tskStation: Result := StoragePermissions[Ord(tskStation)];
  end;
end;
{ @end $5CDCB0 }

{ @routine $5CDE0C TTranclucator_Init }
procedure TTranclucator.Init(AOwnerShip: TShip; Faction: Byte; BasicEquipment: Boolean);
var
  WeaponType: Byte;
  MaximumHullSize: Integer;

  // @nested $5CDCEC RandomHullLevel
  function RandomHullLevel: Integer; // @addr $5CDCEC @calls "0x5CE029" @ida "int __usercall $name@<eax>(void *ParentFrame@<^0>);" @stackpop 0
  begin
    Result := NextRandomIntRange(1, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 1, 8)), RandomState);
  end;

  // @nested $5CDD58 RandomEquipmentLevel
  function RandomEquipmentLevel: Integer; // @addr $5CDD58 @calls "0x5CE042 0x5CE080 0x5CE0A8 0x5CE0D0" @ida "int __usercall $name@<eax>(void *ParentFrame@<^0>);" @stackpop 0
  begin
    Result := NextRandomIntRange(1, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 1, 4)), RandomState);
  end;

  // @nested $5CDDC4 RandomEquipmentSize
  function RandomEquipmentSize(BaseSize: Integer): Integer; // @addr $5CDDC4 @calls "0x5CDF47 0x5CDF96 0x5CE051 0x5CE08F 0x5CE0B7 0x5CE0DF 0x5CE12D" @ida "int __usercall $name@<eax>(int BaseSize@<eax>, void *ParentFrame@<^0>);" @stackpop 0
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
    WeaponType := NextRandomIntRange(0, 2, RandomState) + 50;
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
    WeaponType := NextRandomIntRange(0, 2, RandomState) + 50;
    CreateAndEquipWeapon(WeaponType, RandomEquipmentSize(WeaponInfos[WeaponType].AverageSize), 1, OwnerId);
    BaseSkills[0] := NextRandomIntRange(0, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6)), RandomState);
    BaseSkills[1] := NextRandomIntRange(0, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6)), RandomState);
    BaseSkills[2] := NextRandomIntRange(0, Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 6)), RandomState);
  end;
  TechKnowledge := 8;
  if GetCargoFreeSpace < 0 then GetHull.Weight := GetHull.Weight + Abs(GetCargoFreeSpace);
  RefreshGraphicSize;
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
end;
{ @end $5CDE0C }

{ @routine $5CE2A4 TTranclucator_SaveToBuffer }
procedure TTranclucator.SaveToBuffer(Buffer: TBufEC);
var Kind: TTranclucatorCollectionKind;
    StorageKind: Integer;
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
    Buffer.AddBoolean(CollectionPermissions[Ord(Kind)]);
  for StorageKind := 1 to 2 do Buffer.AddBoolean(StoragePermissions[Ord(StorageKind)]);
  Buffer.AddBoolean(StoreOnLanding);
end;
{ @end $5CE2A4 }

{ @routine $5CE46C TTranclucator_LoadFromBuffer }
procedure TTranclucator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, OldItemCount: Integer;
  Kind: TTranclucatorCollectionKind;
  StorageKind: Integer;

  // @nested $5CE3C4 ReadOldPermission
  procedure ReadOldPermission(ItemType: Byte); // @addr $5CE3C4 @calls "0x5CE5C7" @ida "void __usercall $name(unsigned __int8 ItemType@<al>, void *ParentFrame@<^0>);" @stackpop 0
  var Enabled: Boolean;
  begin
    Enabled := Buffer.GetBoolean;
    case ItemType of
      0: CollectionPermissions[Ord(tckGoods)] := Enabled;
      8: CollectionPermissions[Ord(tckArtefact)] := Enabled;
      43: CollectionPermissions[Ord(tckEquipment)] := Enabled;
      69: CollectionPermissions[Ord(tckCountable)] := Enabled;
      70: CollectionPermissions[Ord(tckUseless)] := Enabled;
      71: CollectionPermissions[Ord(tckMicroModule)] := Enabled;
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
      CollectionPermissions[Ord(Kind)] := Buffer.GetBoolean
  else
  begin
    if LoadedSaveVersion < 78 then OldItemCount := 68
    else if LoadedSaveVersion < 96 then OldItemCount := 72
    else if LoadedSaveVersion < 127 then OldItemCount := 73
    else OldItemCount := 74;
    for I := 0 to OldItemCount - 1 do ReadOldPermission(Byte(MigrateSavedItemType(I)));
  end;
  for StorageKind := 1 to 2 do StoragePermissions[StorageKind] := Buffer.GetBoolean;
  StoreOnLanding := Buffer.GetBoolean;
end;
{ @end $5CE46C }

{ @routine $5CE630 TTranclucator_ResolveLoadedReferences }
procedure TTranclucator.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  OwnerShip := TObject(Galaxy.IdToShip(Integer(OwnerShip), True)) as TShip;
  inherited ResolveLoadedReferences(Galaxy);
end;
{ @end $5CE630 }

{ @routine $5CE674 TTranclucator_ClearObjectReferences }
procedure TTranclucator.ClearObjectReferences;
begin
  OwnerShip := nil;
  inherited ClearObjectReferences;
end;
{ @end $5CE674 }

{ @routine $5CE694 TTranclucator_NextDay }
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
{ @end $5CE694 }

// Zero-byte pointer additions retain the native evaluation order of IndexOf.
{ @routine $5CE6FC TTranclucator_NextDayLogic }
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
{ @end $5CE6FC }

{ @routine $5CEAF0 TTranclucator_GetName }
function TTranclucator.GetName: WideString;
begin
  Result := GetFullName(' ');
end;
{ @end $5CEAF0 }

{ @routine $5CEB1C TTranclucator_GetFullName }
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
{ @end $5CEB1C }

{ @routine $5CED30 TTranclucator_GetGreetingShipCategory }
function TTranclucator.GetGreetingShipCategory: Byte;
begin
  Result := gscTransport; // Native default category, also used for transports.
end;
{ @end $5CED30 }

{ @routine $5CED44 TTranclucator_GetDominantCareer }
function TTranclucator.GetDominantCareer: TRangerCareer;
begin
  Result := rcWarrior;
end;
{ @end $5CED44 }

{ @routine $5CED58 TTranclucator_GetHomeStar }
function TTranclucator.GetHomeStar: TStar;
begin
  Result := nil;
end;
{ @end $5CED58 }

{ @routine $5CED70 TTranclucator_GetStrengthScaledPirateStatus }
function TTranclucator.GetStrengthScaledPirateStatus: Byte;
begin
  Result := 100;
end;
{ @end $5CED70 }

{ @routine $5CED84 TTranclucator_GetDesiredCargoFreeSpace }
function TTranclucator.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $5CED84 }

{ @routine $5CED9C TTranclucator_CanFollowOwnerInCurrentStar }
function TTranclucator.CanFollowOwnerInCurrentStar: Boolean;
begin
  Result := FollowOwner and (OwnerShip <> nil) and (OwnerShip.CurrentStar = CurrentStar) and not OwnerShip.InHyperspace;
end;
{ @end $5CED9C }

{ @routine $5CEDF4 TTranclucator_RefuelAtLocation }
procedure TTranclucator.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $5CEDF4 }

{ @routine $5CEE24 TTranclucator_RepairBrokenEquipmentAtLocation }
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
{ @end $5CEE24 }

{ @routine $5CEF18 TTranclucator_TransferUnequippedCargo }
procedure TTranclucator.TransferUnequippedCargo(Destination: TShip);
var
  I: Integer;
  Item: TEquipment;
  Artefact: TArtefact;
  Good: Byte;

  // @nested $5CEED4 AddGoods
  procedure AddGoods(Good: Byte; Quantity, Cost: Integer); // @addr $5CEED4 @ida "void __usercall $name(unsigned __int8 Good@<al>, int Quantity@<edx>, int Cost@<ecx>, void *ParentFrame@<^0>);" @note "Nested helper; caller-popped static link, destination at ParentFrame-4."
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
    Item := TEquipment(Inventory[I + 0]);
    if Item.EquippedFlag = 0 then
    begin
      Inventory.Delete(Inventory.IndexOf(Pointer(PAnsiChar(Item) + 0)));
      Destination.Inventory.Add(Item);
    end;
  end;
  for I := Artefacts.Count - 1 downto 0 do
  begin
    Artefact := TArtefact(Artefacts[I + 0]);
    if Artefact.EquippedFlag = 0 then
    begin
      Artefacts.Delete(Artefacts.IndexOf(Pointer(PAnsiChar(Artefact) + 0)));
      Destination.Artefacts.Add(Artefact);
    end;
  end;
  for Good := 0 to 7 do
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
{ @end $5CEF18 }

{ @routine $5CF074 TTranclucator_StoreUnequippedCargoAt }
// The +0 index/pointer expressions below preserve native DCC32 argument scheduling.
procedure TTranclucator.StoreUnequippedCargoAt(Location: TObject);
var Good: Byte;
    I: Integer;
    Item: TEquipment;
    Artefact: TArtefact;
begin
  if not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then
  begin
    for I := Inventory.Count - 1 downto 0 do
    begin
      Item := TEquipment(Inventory[I + 0]);
      if Item.EquippedFlag = 0 then
      begin
        GetPlayer.AddItemToPlayerStorage(Item, Location, -1);
        Inventory.Delete(Inventory.IndexOf(Pointer(PAnsiChar(Item) + 0)));
      end;
    end;
    for I := Artefacts.Count - 1 downto 0 do
    begin
      Artefact := TArtefact(Artefacts[I + 0]);
      if Artefact.EquippedFlag = 0 then
      begin
        GetPlayer.AddItemToPlayerStorage(Artefact, Location, -1);
        Artefacts.Delete(Artefacts.IndexOf(Pointer(PAnsiChar(Artefact) + 0)));
      end;
    end;
    for Good := 0 to 7 do
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
{ @end $5CF074 }

{ @routine $5CF200 TTranclucator_UnloadCargoForPlayerOwner }
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
{ @end $5CF200 }

{ @routine $5CF2C8 TTranclucator_TryLandForStorage }
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
        if (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and (Planet.GetRelationLevelToShip(GetPlayer) >= rlNormal) then
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
{ @end $5CF2C8 }

{ @routine $5CF4B4 TTranclucator_ConvertToStoredArtefact }
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
  if (OwnerShip <> nil) and (not (Location is TPlanet) or ((Location as TPlanet).OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)])) then
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
    ScriptItemsAct($2E, Artefact, Location, 0);
    GetPlayer.ScriptItemsAct($2E, Artefact, Location, 0);
    Result := True;
  end;
end;
{ @end $5CF4B4 }

{ @routine $5CF6E4 TTranclucator_UpdateFreeFlightOrder }
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
{ @end $5CF6E4 }

{ @routine $5CF84C TTranclucator_BuildReachablePlanetQueue }
procedure TTranclucator.BuildReachablePlanetQueue;
begin

end;
{ @end $5CF84C }

{ @routine $5CF858 TTranclucator_CanQueueReachablePlanet }
function TTranclucator.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := False;
end;
{ @end $5CF858 }

{ @routine $5CF870 TTranclucator_TryCollectPreferredFloatingLoot }
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
          if not CollectionPermissions[Ord(tckGoods)] then Continue;
        end
        else if Item is TArtefact then
        begin
          if not CollectionPermissions[Ord(tckArtefact)] then Continue;
        end
        else if Item is TMicroModule then
        begin
          if not CollectionPermissions[Ord(tckMicroModule)] then Continue;
        end
        else if Item is TCountableItem then
        begin
          if not CollectionPermissions[Ord(tckCountable)] then Continue;
        end
        else if Item is TUselessItem then
        begin
          if not CollectionPermissions[Ord(tckUseless)] then Continue;
        end
        else if Byte(Item.ItemType) in [Ord(t_FuelTanks)..Ord(t_CustomWeapon)] then
        begin
          if not CollectionPermissions[Ord(tckEquipment)] then Continue;
        end
        else if not CollectionPermissions[Ord(tckOther)] then Continue;
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
{ @end $5CF870 }

{ @routine $5CFB2C TTranclucator_EquipEssentialInventory }
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
          UnequipSlot(Byte(GetFuelTanks.ItemType), 0);
          EquipItem(Item as TFuelTanks);
        end;
      Ord(t_Engine):
        if GetEngine = nil then EquipItem(Item as TEngine)
        else if CalculateItemEffectiveness(Item) > CalculateItemEffectiveness(GetEngine) then
        begin
          UnequipSlot(Byte(GetEngine.ItemType), 0);
          EquipItem(Item as TEngine);
        end;
    end;
  end;
  RefreshDerivedStats(True);
end;
{ @end $5CFB2C }

{ @routine $5CFC84 TTranclucator_AssignWeaponTargetsInStar }
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
        if (Ship.OwnerId = Byte(oiDominator)) and Ship.InNormalSpace then
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
        ((RelationToShip(Ship) < 10) or (Ship = EnemyShip) or (Ship.EnemyShip = Self)) then
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
        if Distance <= 1000000 then
          for J := 1 to WeaponCount do
          begin
            Weapon := Weapons[J];
            if not (Byte(Weapon.GetWeaponInfo^.ShotType) in [Ord(wstAreaDamage)..Ord(wstRocket)]) and
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
{ @end $5CFC84 }

{ @routine $5D024C TTranclucator_SelectEnemyShipInStar }
procedure TTranclucator.SelectEnemyShipInStar;
begin
  EnemyShip := nil;
end;
{ @end $5D024C }

{ @routine $5D0264 TTranclucator_EngageEnemyShip }
procedure TTranclucator.EngageEnemyShip;
begin

end;
{ @end $5D0264 }

{ @routine $5D0270 TTranclucator_RelationToNonRanger }
function TTranclucator.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship.TypeId in [stKling, stTranclucator] then Result := 50 else Result := 100;
end;
{ @end $5D0270 }

{ @routine $5D029C TTranclucator_RelationToRanger }
function TTranclucator.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := 100;
end;
{ @end $5D029C }

{ @routine $5D02B4 TTranclucator_ChangeRelationToRanger }
procedure TTranclucator.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
begin

end;
{ @end $5D02B4 }

{ @routine $5D02C8 TTranclucator_ReactToAttack }
procedure TTranclucator.ReactToAttack(Attacker: TShip);
begin
  if (OwnerShip = nil) or ((OwnerShip <> Attacker) and
    (not (Attacker is TTranclucator) or (TTranclucator(Attacker).OwnerShip <> OwnerShip))) then EnemyShip := Attacker;
end;
{ @end $5D02C8 }

{ @routine $5D0324 TTranclucator_RecomputeFearState }
function TTranclucator.RecomputeFearState: Boolean;
begin
  Result := False;
end;
{ @end $5D0324 }

{ @routine $5D0338 TTranclucator_AcceptsRansomDemandFrom }
function TTranclucator.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := False;
end;
{ @end $5D0338 }

{ @routine $5D0350 TTranclucator_TrustsAttackRequester }
function TTranclucator.TrustsAttackRequester(Ship: TShip): Boolean;
begin
  Result := Ship = OwnerShip;
end;
{ @end $5D0350 }

{ @routine $5D0374 TTranclucator_EvaluateAllyRelationAndStrength }
function TTranclucator.EvaluateAllyRelationAndStrength(Ship: TShip): Boolean;
begin
  Result := Ship = OwnerShip;
end;
{ @end $5D0374 }

{ @routine $5D0398 TTranclucator_ProcessCombatDialogue }
procedure TTranclucator.ProcessCombatDialogue;
begin

end;
{ @end $5D0398 }

{ @routine $5D03A4 TTranclucator_ReactToExtortionDemand }
procedure TTranclucator.ReactToExtortionDemand(Ranger: Pointer);
begin

end;
{ @end $5D03A4 }

{ @routine $5D03B4 TTranclucator_BuildMoneyExtortionResponse }
function TTranclucator.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $5D03B4 }

{ @routine $5D040C TTranclucator_BuildCargoExtortionResponse }
function TTranclucator.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $5D040C }

{ @routine $5D0460 TTranclucator_BuildTrucePaymentResponse }
function TTranclucator.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $5D0460 }

{ @routine $5D04B8 TTranclucator_BuildAttackRequestResponse }
function TTranclucator.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
begin
  Result := True;
  Response := LookupVisibleTalkText('Talk.Tranclucator.Attack.Ok', Requester);
  SetJointAttackTarget(Requester, Target);
  FollowOwner := False;
  SeekItems := False;
end;
{ @end $5D04B8 }

{ @routine $5D0584 TTranclucator_AcceptPartnershipOffer }
function TTranclucator.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $5D0584 }

{ @routine $5D05D4 TTranclucator_BuildPartnershipOfferResponse }
function TTranclucator.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $5D05D4 }

{ @routine $5D0624 TTranclucator_RefreshCurrentStanding }
procedure TTranclucator.RefreshCurrentStanding;
var StandingMode: Integer;
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
        if Byte(CurrentStar.ControlFaction) in [0, 1] then CurrentStanding := ssCoalitionActive else CurrentStanding := ssNeutral;
      end
      else if OwnerShip.CurrentStanding in [ssPiratePassive, ssPirateActive] then
      begin
        if Byte(CurrentStar.ControlFaction) in [1, 2] then CurrentStanding := ssPirateActive else CurrentStanding := ssNeutral;
      end
      else CurrentStanding := OwnerShip.CurrentStanding;
    end;
  end;
end;
{ @end $5D0624 }

{ @routine $5D075C TTranclucator_EvaluateStatBonus }
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
    bonScan: Result := Value * 20 * (Integer(CountWeaponsByDamageFlags(ScannableDamageFlags)) and $7F);
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
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[Ord(BonusKind)] - TranclucatorSlotBonusWeights[18] * (Integer(CountMissileWeapons) and $7F)
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[Ord(BonusKind)] - (Integer(CountWeaponsByDamageFlags(ScannableDamageFlags)) and $7F) * 0.1 * TranclucatorSlotBonusWeights[18]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotHook:
      if (GetSlotCount(sskCargoHook) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskCargoHook) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then
        Result := -TranclucatorSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then
        Result := TranclucatorSlotBonusWeights[Ord(BonusKind)] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Math.Min(Value, 5 - GetSlotCount(sskWeapon)) * TranclucatorSlotBonusWeights[Ord(BonusKind)];
        if Value < 0 then
          Result := Math.Max(Value, -GetSlotCount(sskWeapon)) * TranclucatorSlotBonusWeights[Ord(BonusKind)];
        if (Integer(CountEquippedWeapons) and $7F) > Math.Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - ((Integer(CountEquippedWeapons) and $7F) - Math.Max(1, Value + GetSlotCount(sskWeapon))) * (TranclucatorSlotBonusWeights[Ord(BonusKind)] * 0.6);
      end;
    bonSlotArt:
      begin
        if (GetSlotCount(sskArtefact) < DefaultHullSlotCounts[8]) and (Value > 0) then
          Result := Math.Min(Value, DefaultHullSlotCounts[8] - GetSlotCount(sskArtefact)) * TranclucatorSlotBonusWeights[Ord(BonusKind)];
        if Value < 0 then
          Result := Math.Max(Value, -GetSlotCount(sskArtefact)) * TranclucatorSlotBonusWeights[Ord(BonusKind)];
        if (Artefacts <> nil) and (Artefacts.Count > Math.Max(Value + GetSlotCount(sskArtefact), 0)) then Result := -1000;
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := TranclucatorSlotBonusWeights[Ord(BonusKind)]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -TranclucatorSlotBonusWeights[Ord(BonusKind)];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Math.Min(6 - (Integer(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22]))) and $7F), Value) * TranclucatorSkillBonusWeights[Ord(BonusKind)];
        if (Value > 0) and (Value + (Integer(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22]))) and $7F) > 6) then
          Result := (Value + (Integer(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22]))) and $7F) - 6) * (TranclucatorSkillBonusWeights[Ord(BonusKind)] * 0.05) + Result;
        if Value < 0 then
          Result := Math.Min(Integer(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22]))) and $7F, -Value) * -TranclucatorSkillBonusWeights[Ord(BonusKind)];
        if (Value < 0) and (Value + (Integer(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22]))) and $7F) < 0) then
          Result := (Value + (Integer(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22]))) and $7F)) * (TranclucatorSkillBonusWeights[Ord(BonusKind)] * 0.03) + Result;
      end;
  else
    Result := 0;
  end;
end;
{ @end $5D075C }

end.
