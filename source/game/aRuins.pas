unit aRuins;

interface

uses EC_BlockPar, EC_Buf, EC_Struct, aGalaxy, aGalaxyStruct, aItem, aMyFunction, aPlanet, aShip;

type

  TStationHullTypes = set of THullType; // @size $02 Offered hull_* categories.

  TStationHullGeneration = packed record // @size $14
    MinSize: Integer; // @offset $00
    MaxSize: Integer; // @offset $04
    TechSizeBonus: Integer; // @offset $08
    MinLevel: Integer; // @offset $0C
    MaxLevel: Integer; // @offset $10
  end;
  TStationLevelRange = packed record // @size $08
    Minimum: Integer; // @offset $00
    Maximum: Integer; // @offset $04
  end;
  TStationWeaponGeneration = packed record // @size $10
    BasicLevel: Integer; // @offset $00
    IntermediateLevel: Integer; // @offset $04
    AdvancedLevel: Integer; // @offset $08
    MinimumRange: Integer; // @offset $0C
  end;

  TRuins = class(TShip) // @size 0x568 @methodorder source
  public
    EquipmentShop: TObjectList; // @offset 0x4D0  Owns equipment offers.
    ShopGoods: array[TGoodsIndex] of TGoodsTradePriceEntry; // @offset 0x4D4
    RelocationAge: Integer; // @offset 0x554
    FlyToStar: TStar; // @offset 0x558
    FlyDate: Integer; // @offset 0x55C
    SatelliteOffer: TSatellite; // @offset 0x560  Owned until transferred to the buyer.
    SpecialServiceActive: Boolean; // @offset 0x564
    ModernizationSponsor: Boolean; // @offset 0x565  Script.RuinsAllowModernization.
    NoLanding: Boolean; // @offset 0x566
    ShopUpdateMode: TShopUpdateMode; // @offset 0x567

    constructor Create; // @addr 0x0069A480
    destructor Destroy; override; // @addr 0x0069A500
    procedure Init(StationType: TStationType; Star: TStar; TypeNameOverride: WideString); // @addr 0x0069A8E4 @note "Also registers the station in Star. Type 13 inherits ranger-center defaults."
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x0069B140 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x0069B264 @slot 0x04 @note "Requires a fresh instance. FlyToStar temporarily contains a saved star ID."
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr 0x0069B404 @slot 0x10 @note "Includes the player's storage at this station and temporarily displayed shop stock."
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr 0x0069B9CC @slot 0x14 @note "Applies edits to existing state; can append new shop and player-storage items."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x0069C090 @slot 0x08
    procedure ClearObjectReferences; override; // @addr 0x0069C0F0 @slot 0x0C @note "Calls inherited, clears shop-item references and FlyToStar; leaves FlyDate unchanged."
    procedure NextDay; override; // @addr 0x0069C134 @slot 0x18
    procedure NextDayLogic; override; // @addr 0x0069C1F8 @slot 0x1C
    function GetName: WideString; override; // @addr 0x0069CAA0 @slot 0x24
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x0069CAB4 @slot 0x28
    function GetColoredFullName(const ColorTag: WideString): WideString; // @addr 0x0069CBBC @note "Uses the station type's alternate localized caption and colors the individual name."
    function GetGreetingShipCategory: TGreetingShipCategory; override; // @addr $69CCFC @slot 0x30
    function GetDominantCareer: TRangerCareer; override; // @addr 0x0069CD00 @slot 0x38 @note "Always career_trader."
    function GetHomeStar: TStar; override; // @addr $69CD04 @slot 0x34
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr $69CD08 @slot 0x3C
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x0069CD0C @slot 0x40 @note "Always zero."
    procedure RegenerateSatelliteOffer; // @addr 0x0069CD10 @note "Invalidates TargetPlanet on the existing offer."
    procedure RefuelAtLocation; override; // @addr 0x0069CD94 @slot 0x48
    procedure RepairBrokenEquipmentAtLocation; override; // @addr 0x0069CDBC @slot 0x60 @note "Sponsored stations restore equipment condition without a repair transaction."
    procedure ReloadWeapons; // @addr 0x0069CEB0 @note "Sponsored stations gain only one round per weapon; other stations refill to capacity."
    procedure RefreshShopInventory; // @addr 0x0069CF04 @note "Disabled in modes 1 and 3; otherwise follows the station's weekly schedule after initial setup."
    function CalculateEquipmentShopTargetCount: Integer; // @addr 0x0069D104 @note "Returns 10..18; advances the station RNG state."
    function CountEquipmentShopItems(ItemType: TItemType): Integer; // @addr 0x0069D168 @note "Bucket 50 includes all weapon item types 50..68."
    function FindMostExpensiveShopItem(MinCost, MaxCost: Integer): TItem; // @addr 0x0069D1B8 @note "Excludes hulls; inclusive cost bounds. Borrowed result, nil when absent."
    function RemoveSimilarShopItem(Item: TEquipment): Boolean; // @addr 0x0069D220 @note "Frees at most one existing offer matching type and level; never inserts Item. May also compare size when below the target shop count."
    function SelectEquipmentOfferSpecialMicroModule(Item: TEquipment; Planet: TPlanet): Integer; // @addr 0x0069D4E0 @note "Returns a zero-based module index or -1; advances the station RNG."
    function SelectHullOfferSpecialMicroModule(Hull: THull; Planet: TPlanet): Integer; // @addr 0x0069D724 @note "Returns a zero-based module index or -1; advances the station RNG."
    function SelectWeaponOfferSpecialMicroModule(Weapon: TWeapon; Planet: TPlanet): Integer; // @addr 0x0069D968 @note "Returns a zero-based module index or -1; advances the station RNG."
    procedure BuildReachablePlanetQueue; override; // @addr 0x0069DBAC @slot 0x64 @note "Empty."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x0069DBB0 @slot 0x68 @note "Always false."
    procedure SelectEnemyShipInStar; override; // @addr 0x0069DBB4 @slot 0x6C @note "Clears EnemyShip."
    procedure EngageEnemyShip; override; // @addr 0x0069DBC0 @slot 0x70 @note "Empty."
    procedure AssignWeaponTargetsInStar; override; // @addr 0x0069DBC4 @slot 0x20 @note "Targets hostile ships, incoming missiles and nearby asteroids."

    function TryStartAbductionCycle: Boolean; // @addr $69DFC0
    procedure TryAbductDepartingShip(Ship: TShip); // @addr $69E2A4 @note "May redirect a departing ship to this station during its abduction cycle."
    procedure ReportAbductionOutcome; // @addr $69E510 @note "Posts the native Pirate Clan success/failure message after the station reappears."
    function EvaluateLocalForceBalance(Point: TPointF): Single; // @addr $69E800
    function EvaluateRelocationPosition(Point: TPointF): Single; // @addr $69EADC
    function TryRepositionInStar: Boolean; // @addr 0x0069EC00 @note "Successful repositioning initiates a teleport."
    function TryRelocateToPirateStar: Boolean; // @addr 0x0069EEB4 @note "Travel starts next turn; transfers the star's Dominion ownership reference."
    function AcceptPickupItem(Item: TItem): Boolean; override; // @addr $69F010 @slot 0x94
    procedure ApplyInventoryMicroModulesToShopItems; // @addr 0x0069F050 @note "Consumes compatible modules from Inventory, skipping index 0; modifies EquipmentShop items."
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr $69F168 @slot 0x80
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr 0x0069F17C @slot 0x74 @note "Floors the stored relation at 50, except for the player when NoLanding is set."
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr 0x0069F1D8 @slot 0x78 @note "Positive changes receive the ranger's Charisma bonus; stored relation is clamped to 0..100."
    procedure ReactToAttack(Attacker: TShip); override; // @addr $69F2FC @slot $7C
    function RecomputeFearState: Boolean; override; // @addr 0x0069F5A0 @slot 0x84 @note "Returns false without changing InFear."
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr $69F5A4 @slot 0x88
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr $69F5A8 @slot 0x8C
    function AcceptsAppealFrom(Ship: TShip): Boolean; override; // @addr $69F5AC @slot 0x90
    procedure ProcessCombatDialogue; override; // @addr $69F5B0 @slot 0xA0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr $69F5B4 @slot 0xA4
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr $69F5B8 @slot 0xA8
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr $69F604 @slot 0xAC
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr $69F648 @slot 0xB0
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr $69F694 @slot 0xB4
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $69F6E0 @slot 0xB8
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr $69F724 @slot 0xBC
    procedure ForceGoodsForSale(GoodsMask: TItemTypeMask); // @addr 0x0069F768 @ida "void __usercall $name(TRuins *Self@<eax>, TItemTypeMask *GoodsMask@<edx>);" @note "Script.GoodsRuinsForBuy. Restocks selected goods and sets prices near the global minimum."

    procedure GenerateCombatSkills; // @addr 0x0069F8A4 @note "Sets base Accuracy and Maneuverability to 0..5 using galaxy technology and war state."
    procedure RandomizePosition; // @addr 0x0069F994 @note "Immediately replaces Position with a sampled arrival point in CurrentStar."
    function SelectTeleportArrivalPoint(Star: TStar): TPointF; // @addr 0x0069FA40 @note "Search is limited to 1001 attempts."
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr $69FB1C @slot 0x50

    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr $69FB30 @slot $54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr $69FFA4 @slot $58
    procedure RefreshCurrentStanding; override; // @addr 0x006A0428 @slot 0xC4 @note "Script state can force standing_custom or preserve the current value; station_custom has no default assignment."
    function GeneratePlanetHullOffer(Ship: TObject; Planet: TPlanet): THull; // @addr 0x006A0464 @note "Type-13 fallback through the planet's hull generator; may apply a special module."
    function GenerateHullOffer(Ship: TObject; Planet: TPlanet): THull; // @addr 0x006A04F8 @note "Returns a newly allocated offer or nil; Planet supplies local technology."
    function GenerateWeaponOffer(Ship: TObject; Planet: TPlanet): TWeapon; // @addr 0x006A0BA8 @note "Chooses the weapon type; returns a newly allocated offer or nil."
    function GenerateEquipmentOffer(Ship: TObject; Planet: TPlanet; ItemType: TItemType): TEquipment; // @addr 0x006A0F18 @note "Accepts types 42..68; weapon types all select the weapon generator. Does not insert the result into EquipmentShop."
    function GenerateEquipmentOfferBatch(Ship: TShip; UnusedForceGeneratedOffers: Boolean): TObjectList; // @addr 0x006A143C @note "Returns a new owning list of offers. Ignores the Boolean argument."
    procedure UpdateGoodsMarketState; // @addr 0x006A1570 @note "Does nothing in modes 1 and 2."

    function CalculateRepairCost(Ship: TShip; out EquipmentCost: Integer): Integer; // @addr 0x006A1A30 @note "Returns the total including eligible artefacts; EquipmentCost excludes the separate artefact pass. Military discount uses the player's rank."
    function GetRepairCost(Ship: TShip): Integer; // @addr 0x006A1BEC
    procedure RepairShipEquipment(Ship: TShip); // @addr 0x006A1BF8 @note "Charges the full quote and repairs eligible items only if affordable. Caller refreshes ship statistics."
    function GetNodeSaleBatchSize: Integer; // @addr 0x006A1D08 @note "Returns min(NodeReserve, 250), without a lower clamp."
    function FindPirateBaseWithNodes: TRuins; // @addr 0x006A1D20 @note "Searches from CurrentStar for a standard pirate base with positive NodeReserve in a peaceful non-Dominator system. Borrowed result or nil."
    function SelectServiceMicroModule(Kind, Index: Integer; InvertRarity: Boolean): Integer; // @addr 0x006A1E00 @note "Zero-based module index. Deterministic chain keyed by station, current turn and player RNG state; Kind 1 selects priorities 31..69, Kind 2 selects 0..20 or 10..30, others 70..100."
    function CanDock(Ship: TShip): Boolean; override; // @addr 0x006A1F2C @slot 0xC8
    function CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean; override; // @addr 0x006A1F80 @slot 0xCC @note "Clears Response on success; otherwise supplies a refusal message."
  end;

const
  StationPilotRaces: array[station_ranger_center..station_dominion, 0..1] of TOwnerId = (
    (owner_feyan, owner_gaal),
    (owner_human, owner_peleng),
    (owner_maloc, owner_peleng),
    (owner_feyan, owner_gaal),
    (owner_human, owner_human),
    (owner_gaal, owner_gaal),
    (owner_feyan, owner_feyan)); // @addr $80F848
  StationHullGeneration: array[station_ranger_center..station_dominion] of TStationHullGeneration = (
    (MinSize: 900; MaxSize: 1600; TechSizeBonus: 1500; MinLevel: 2; MaxLevel: 6),
    (MinSize: 900; MaxSize: 1000; TechSizeBonus: 1500; MinLevel: 2; MaxLevel: 5),
    (MinSize: 1200; MaxSize: 1500; TechSizeBonus: 1700; MinLevel: 2; MaxLevel: 7),
    (MinSize: 800; MaxSize: 1200; TechSizeBonus: 1100; MinLevel: 2; MaxLevel: 7),
    (MinSize: 800; MaxSize: 1000; TechSizeBonus: 1100; MinLevel: 2; MaxLevel: 5),
    (MinSize: 800; MaxSize: 1000; TechSizeBonus: 1200; MinLevel: 2; MaxLevel: 5),
    (MinSize: 900; MaxSize: 1000; TechSizeBonus: 1500; MinLevel: 2; MaxLevel: 5)); // @addr $80F858
  StationDefenseLevels: array[station_ranger_center..station_dominion] of TStationLevelRange = (
    (Minimum: 2; Maximum: 6),
    (Minimum: 2; Maximum: 5),
    (Minimum: 2; Maximum: 7),
    (Minimum: 2; Maximum: 8),
    (Minimum: 2; Maximum: 5),
    (Minimum: 2; Maximum: 4),
    (Minimum: 2; Maximum: 5)); // @addr $80F8E4
  StationRepairLevels: array[station_ranger_center..station_dominion] of TStationLevelRange = (
    (Minimum: 2; Maximum: 5),
    (Minimum: 1; Maximum: 4),
    (Minimum: 2; Maximum: 5),
    (Minimum: 2; Maximum: 6),
    (Minimum: 2; Maximum: 4),
    (Minimum: 2; Maximum: 3),
    (Minimum: 1; Maximum: 4)); // @addr $80F91C
  StationWeaponGeneration: array[station_ranger_center..station_dominion] of TStationWeaponGeneration = (
    (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 450),
    (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 400),
    (BasicLevel: 4; IntermediateLevel: 4; AdvancedLevel: 4; MinimumRange: 470),
    (BasicLevel: 4; IntermediateLevel: 4; AdvancedLevel: 4; MinimumRange: 500),
    (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 300),
    (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 350),
    (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 400)); // @addr $80F954
  StationWeaponTypes: array[station_ranger_center..station_dominion, 0..2] of TItemType = (
    (item_flux, item_flow_blaster, item_atomic_vision),
    (item_flux, item_wave_phaser, item_disintegrator),
    (item_flux, item_multiresonator, item_flow_blaster),
    (item_flux, item_treton, item_turbogravitron),
    (item_fragmentation_cannon, item_electronic_cutter, item_wave_phaser),
    (item_industrial_laser, item_treton, item_wave_phaser),
    (item_flux, item_wave_phaser, item_disintegrator)); // @addr $80F9C4
  StationSkillBonusWeights: array[bonus_accuracy..bonus_leadership] of Integer = (100, 100, 80, 0, 0, 0); // @addr $80F9DC
  StationOfferHullLevelBonus: array[station_ranger_center..station_dominion] of Integer = (0,0,1,0,0,0,0); // @addr $80F9F4
  StationOfferHullTypes: array[station_ranger_center..station_dominion] of TStationHullTypes = (
    [hull_ranger],
    [hull_pirate, hull_transport],
    [hull_ranger, hull_warrior],
    [hull_ranger..hull_diplomat],
    [hull_transport, hull_liner],
    [hull_transport..hull_diplomat],
    [hull_pirate]); // @addr $80FA10
  StationOfferRareHullTypes: array[station_ranger_center..station_dominion] of TStationHullTypes = (
    [hull_ranger],
    [hull_pirate],
    [hull_warrior],
    [hull_ranger, hull_transport..hull_diplomat],
    [hull_transport, hull_liner],
    [hull_transport..hull_diplomat],
    [hull_pirate]); // @addr $80FA20
  StationOfferWeaponLevelBonus: array[TStationType] of Integer = (1,1,2,1,1,1,2,1); // @addr $80FA30
  StationOfferEquipmentLevelBonus: array[TStationType,item_fuel_tanks..item_defense_generator] of Integer = (
    (1,0,1,0,0,0,0), (0,0,0,0,0,1,0), (0,0,0,0,0,0,0), (0,0,0,1,0,1,0),
    (0,0,0,0,0,1,0), (0,0,0,0,0,1,0), (0,0,0,0,0,1,0), (0,0,0,0,0,0,0)); // @addr $80FA50

implementation

uses aWarrior, aPlayer, aNormalShip, aPirate, aRanger, aConst, Math, Windows, GR_Main, aGalaxyEvent, SysUtils, Globals, aScript, fEquipmentShop, EC_Str, aAsteroid, aMissile, aTranclucator, GlobalsV;

{ @routine $69A480 TRuins_Create }
constructor TRuins.Create;
begin
  inherited Create;
  EquipmentShop := TObjectList.Create;
  RelocationAge := 0;
  FlyToStar := nil;
  FlyDate := 0;
  ModernizationSponsor := False;
  SpecialServiceActive := False;
  if Galaxy <> nil then RegenerateSatelliteOffer;
end;
{ @end $69A480 }

{ @routine $69A500 TRuins_Destroy }
destructor TRuins.Destroy;
var
  I: Integer;
  Ranger: TRanger;
  Event: TGalaxyEvent;
  Star: TStar;
begin
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := Galaxy.Rangers[I];
    if Ranger.LastDockedNonPlanetLocation = Self then Ranger.LastDockedNonPlanetLocation := nil;
  end;
  EquipmentShop.Free;
  EquipmentShop := nil;
  if SatelliteOffer <> nil then
  begin
    SatelliteOffer.Free;
    SatelliteOffer := nil;
  end;
  if not Galaxy.Destroying and (GetPlayer <> nil) and (GetPlayer.RuinsProxy <> Self) then
  begin
    Event := AddGalaxyEvent('RuinsDestroyed');
    Event.AddData(Ord(TypeId));
    Event.AddData(Id);
    Event.AddData(CurrentStar.Id);
    Event.AddTextData(Name);
    Event.AddTextData(TypeNameOverrideKey);
  end;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if Star.Dominion = Self then Star.Dominion := nil;
  end;
  inherited Destroy;
end;
{ @end $69A500 }

{ @routine $69A8E4 TRuins_Init }
procedure TRuins.Init(StationType: TStationType; Star: TStar; TypeNameOverride: WideString);
var I: Integer; Ranger: TRanger; Event: TGalaxyEvent; Good: Byte; Weapon: TWeapon; Hook: TCargoHook; EquipmentOwner: TOwnerId;

  // @nested $69A650 SelectStationName
  procedure SelectStationName(Config: TBlockParEC); // @addr $69A650 @calls "0x0069AA1A,0x0069AA49"
  var Index, I, J, K, LastName: Integer; Used: Boolean; Ship: TShip; OtherStar: TStar;
  begin
    if Config = nil then Exit;
    if Config.CountBlocks(ShipTypeNames[TypeId].Name) = 0 then Exit;
    LastName := Config.GetBlock(ShipTypeNames[TypeId].Name).GetParamCount - 1;
    Index := NextRandomIntRange(0, LastName, RandomState);
    for I := 0 to LastName do
    begin
      Name := Config.GetBlock(ShipTypeNames[TypeId].Name).GetParamValue(Index);
      Used := False;
      for J := 0 to Galaxy.Stars.Count - 1 do
      begin
        OtherStar := Galaxy.Stars[J];
        for K := 0 to OtherStar.Ships.Count - 1 do
        begin
          Ship := OtherStar.Ships[K];
          if (Ship.TypeId = TypeId) and (Ship.Name = Name) and (Ship <> Self) then
          begin
            Used := True;
            Break;
          end;
        end;
        if Used then Break;
      end;
      if not Used then Break;
      IncrementWrapped(Index, 0, LastName);
      if I = LastName then Name := Name + ' ' + '-' + IntToStr(NextRandomIntRange(10, 99, RandomState)) + '-';
    end;
  end;

  // @nested $69A88C RandomStationEquipmentSize
  function RandomStationEquipmentSize(BaseSize: Integer): Integer; // @addr $69A88C @calls "0x0069ACE2,0x0069ACFD,0x0069AD4F,0x0069ADA0,0x0069AE68,0x0069AF45,0x0069AFC6,0x0069B050"
  begin
    Result := NextRandomIntRange(Round(BaseSize * EquipmentSizeFactors[2] * 2), Round(BaseSize * EquipmentSizeFactors[1] * 2), RandomState);
  end;
begin
  if StationType = station_custom then TypeId := station_ranger_center else TypeId := StationType;
  TypeNameOverrideKey := TypeNameOverride;
  CurrentStar := Star;
  CurrentStar.Ships.Add(Self);
  HomePlanet := nil;
  CurrentPlanet := nil;
  if (Galaxy.CurrentTurn < GalaxyWarmupTurns) and (GetPlayer.CurrentStar.Constellation = Star.Constellation) then
    PilotRace := StationPilotRaces[TypeId, 0]
  else if NextRandomUnitFloat(RandomState) < 0.5 then PilotRace := StationPilotRaces[TypeId, 0]
  else PilotRace := StationPilotRaces[TypeId, 1];
  OwnerId := RaceToOwner(PilotRace);
  RandomizePosition;
  Name := '';
  SelectStationName(ModRuinNameConfig);
  if Length(GetName) = 0 then SelectStationName(LanguageDataConfig.GetBlock('RuinName'));
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := Galaxy.Rangers[I];
    RangerRelations.Add(Pointer(OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ranger.PilotRace)]));
  end;
  GenerateCombatSkills;
  RefreshCurrentStanding;
  if (GetPlayer <> nil) and (GetPlayer.RuinsProxy <> Self) then
  begin
    Event := AddGalaxyEvent('RuinsCreated');
    Event.AddData(Ord(StationType));
    Event.AddData(Id);
    Event.AddData(Star.Id);
    Event.AddTextData(Name);
    Event.AddTextData(TypeNameOverride);
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  RefreshShopInventory;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    ShopGoods[Good].Count := Round(StationGoodsFactors[TypeId, Good].StockFactor * GoodsMarket[Good].BaseStock);
    ShopGoods[Good].PriceState := GoodsMarket[Good].AveragePrice;
    ShopGoods[Good].PurchasePrice := Round(ShopGoods[Good].PriceState);
    ShopGoods[Good].BaseSalePrice := Round(ShopGoods[Good].PriceState * 0.98 - 1);
  end;
  if CurrentStar.ControlFaction = faction_pirates then EquipmentOwner := owner_pirate else EquipmentOwner := OwnerId;
  CreateAndEquipHull(RoundAndTruncateToTens((NextRandomIntRange(StationHullGeneration[TypeId].MinSize, StationHullGeneration[TypeId].MaxSize, RandomState) +
    Galaxy.ScaleIntByTechLevel(0, StationHullGeneration[TypeId].TechSizeBonus)) * HullCapacityScale),
    Galaxy.ScaleIntByTechLevel(1, NextRandomIntRange(StationHullGeneration[TypeId].MinLevel, StationHullGeneration[TypeId].MaxLevel, RandomState)),
    OwnerId, -1, CurrentStar.ControlFaction = faction_pirates);
  CreateAndEquipFuelTanks(RandomStationEquipmentSize(FuelTanksBaseSize), 1, EquipmentOwner);
  CreateAndEquipEngine(RandomStationEquipmentSize(EngineBaseSize), 1, EquipmentOwner);
  CreateAndEquipDefGenerator(RandomStationEquipmentSize(DefGeneratorBaseSize),
    Galaxy.ScaleIntByTechLevel(1, NextRandomIntRange(StationDefenseLevels[TypeId].Minimum, StationDefenseLevels[TypeId].Maximum, RandomState)), EquipmentOwner);
  CreateAndEquipRepairRobot(RandomStationEquipmentSize(RepairRobotBaseSize),
    Galaxy.ScaleIntByTechLevel(1, NextRandomIntRange(StationRepairLevels[TypeId].Minimum, StationRepairLevels[TypeId].Maximum, RandomState)), EquipmentOwner);
  if (WeaponInfos[StationWeaponTypes[TypeId, 2]].TechLevel <= Galaxy.TechLevel) and (NextRandomUnitFloat(RandomState) > 0.6) then
    Weapon := CreateAndEquipWeapon(StationWeaponTypes[TypeId, 2], RandomStationEquipmentSize(WeaponInfos[StationWeaponTypes[TypeId, 2]].AverageSize),
      Galaxy.ScaleIntByTechLevel(StationWeaponGeneration[TypeId].AdvancedLevel, NextRandomIntRange(StationWeaponGeneration[TypeId].AdvancedLevel + 1, 8, RandomState)), EquipmentOwner)
  else if (WeaponInfos[StationWeaponTypes[TypeId, 1]].TechLevel <= Galaxy.TechLevel) and (NextRandomUnitFloat(RandomState) > 0.6) then
    Weapon := CreateAndEquipWeapon(StationWeaponTypes[TypeId, 1], RandomStationEquipmentSize(WeaponInfos[StationWeaponTypes[TypeId, 1]].AverageSize),
      Galaxy.ScaleIntByTechLevel(StationWeaponGeneration[TypeId].IntermediateLevel, NextRandomIntRange(StationWeaponGeneration[TypeId].IntermediateLevel + 1, 8, RandomState)), EquipmentOwner)
  else
    Weapon := CreateAndEquipWeapon(StationWeaponTypes[TypeId, 0], RandomStationEquipmentSize(WeaponInfos[StationWeaponTypes[TypeId, 0]].AverageSize),
      Galaxy.ScaleIntByTechLevel(StationWeaponGeneration[TypeId].BasicLevel, NextRandomIntRange(StationWeaponGeneration[TypeId].BasicLevel + 1, 8, RandomState)), EquipmentOwner);
  Weapon.Range := Max(Weapon.Range, StationWeaponGeneration[TypeId].MinimumRange);
  if TypeId = station_dominion then
  begin
    CurrentStar.Dominion := Self;
    Hook := CreateAndEquipCargoHook(RandomStationEquipmentSize(CargoHookBaseSize), Galaxy.ScaleIntByTechLevel(2, NextRandomIntRange(5, 8, RandomState)), EquipmentOwner);
    Hook.Range := Max(Hook.Range, 200);
  end;
  if GetCargoFreeSpace < 0 then Inc(GetHull.Weight, Abs(GetCargoFreeSpace));
  RefreshDerivedStats(True);
  NodeReserve := 0;
  TypeId := StationType;
end;
{ @end $69A8E4 }

{ @routine $69B140 TRuins_SaveToBuffer }
procedure TRuins.SaveToBuffer(Buffer: TBufEC);
var Count, I: Integer; Item: TItem; Good: Byte;
begin
  inherited SaveToBuffer(Buffer);
  Count := EquipmentShop.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Item := EquipmentShop[I];
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    Buffer.AddIntegerValue(ShopGoods[Good].Count);
    Buffer.AddSingle(ShopGoods[Good].PriceState);
    Buffer.AddIntegerValue(ShopGoods[Good].PurchasePrice);
    Buffer.AddIntegerValue(ShopGoods[Good].BaseSalePrice);
  end;
  Buffer.AddIntegerValue(RelocationAge);
  if FlyToStar = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(FlyToStar.Id);
  Buffer.AddIntegerValue(FlyDate);
  SatelliteOffer.SaveToBuffer(Buffer);
  Buffer.AddBoolean(ModernizationSponsor);
  Buffer.AddBoolean(SpecialServiceActive);
  Buffer.AddBoolean(NoLanding);
  Buffer.AddAnsiChar(AnsiChar(ShopUpdateMode));
end;
{ @end $69B140 }

{ @routine $69B264 TRuins_LoadFromBuffer }
procedure TRuins.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var Count, I: Integer; Item: TItem; Good: Byte;
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 102 then Buffer.GetByte;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
    EquipmentShop.Add(Item);
    Item.LoadFromBuffer(Buffer, Galaxy);
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    ShopGoods[Good].Count := Buffer.GetInt32;
    ShopGoods[Good].PriceState := Buffer.GetSingle;
    ShopGoods[Good].PurchasePrice := Buffer.GetInt32;
    ShopGoods[Good].BaseSalePrice := Buffer.GetInt32;
  end;
  if LoadedSaveVersion >= 107 then RelocationAge := Buffer.GetInt32;
  FlyToStar := TStar(Buffer.GetUInt32);
  FlyDate := Buffer.GetInt32;
  if SatelliteOffer <> nil then
  begin
    SatelliteOffer.Free;
    SatelliteOffer := nil;
  end;
  SatelliteOffer := TSatellite.Create;
  SatelliteOffer.LoadFromBuffer(Buffer, Galaxy);
  SatelliteOffer.TargetPlanet := nil;
  ModernizationSponsor := Buffer.GetBoolean;
  SpecialServiceActive := Buffer.GetBoolean;
  NoLanding := Buffer.GetBoolean;
  if LoadedSaveVersion >= 83 then ShopUpdateMode := TShopUpdateMode(Buffer.GetByte)
  else ShopUpdateMode := shop_update_all;
end;
{ @end $69B264 }

{ @routine $69B404 TRuins_SaveToBlock }
procedure TRuins.SaveToBlock(Block: TBlockParEC);
var
  I: Integer;
  Text: WideString;
  Item: TItem;
  Slot: TShopSlot;
  ShopBlock: TBlockParEC;
begin
  inherited SaveToBlock(Block);
  Text := IntToStr(ShopGoods[GoodsTextOrder[0]].Count);
  for I := 1 to 7 do Text := Text + ',' + IntToStr(ShopGoods[GoodsTextOrder[Byte(I)]].Count);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesa'), Text); // 'ShopGoods'
  Text := IntToStr(ShopGoods[GoodsTextOrder[0]].PurchasePrice);
  for I := 1 to 7 do Text := Text + ',' + IntToStr(ShopGoods[GoodsTextOrder[Byte(I)]].PurchasePrice);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesaSrakloe'), Text); // 'ShopGoodsSale'
  Text := IntToStr(ShopGoods[GoodsTextOrder[0]].BaseSalePrice);
  for I := 1 to 7 do Text := Text + ',' + IntToStr(ShopGoods[GoodsTextOrder[Byte(I)]].BaseSalePrice);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesaBruhy'), Text); // 'ShopGoodsBuy'
  ShopBlock := Block.AddBlockByPath(DecodeTextW('EdqeSahloEp')); // 'EqShop'
  if (EquipmentShop <> nil) and (EquipmentShop.Count > 0) then
  begin
    for I := 0 to EquipmentShop.Count - 1 do
    begin
      Item := EquipmentShop[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.SaveToBlock(ShopBlock.AddBlockByPath(Text));
    end;
  end
  else if (GetPlayer.DockedTo = Self) and (TemporaryShopSlots <> nil) then
    for I := 0 to TemporaryShopSlots.Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      Item := Slot.Item;
      if Item <> nil then
      begin
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
        Item.SaveToBlock(ShopBlock.AddBlockByPath(Text));
      end;
    end;
  ShopBlock.AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  with Block.AddBlockByPath(DecodeTextW('Sataokrgalgae')) do // 'Storage'
  begin
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      if PStorageEntry(GetPlayer.StorageEntries[I]).LocationOwner = Self then
      begin
        Item := PStorageEntry(GetPlayer.StorageEntries[I]).Item;
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
        Item.SaveToBlock(AddBlockByPath(Text));
      end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
end;
{ @end $69B404 }

{ @routine $69B9CC TRuins_LoadFromBlock }
procedure TRuins.LoadFromBlock(Block: TBlockParEC);
var
  I: Integer;
  Text, Name: WideString;
  Item: TItem;
  Kind: TItemType;
  Entry: PStorageEntry;
  Slot: TShopSlot;
  ShopBlock: TBlockParEC;
begin
  inherited LoadFromBlock(Block);
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordes')); // 'ShopGoods'
  for I := 0 to 7 do ShopGoods[GoodsTextOrder[TGoodsIndex(I)]].Count := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesaSrakloe')); // 'ShopGoodsSale'
  for I := 0 to 7 do ShopGoods[GoodsTextOrder[TGoodsIndex(I)]].PurchasePrice := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesaBruhy')); // 'ShopGoodsBuy'
  for I := 0 to 7 do ShopGoods[GoodsTextOrder[TGoodsIndex(I)]].BaseSalePrice := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  ShopBlock := Block.GetBlockByPath(DecodeTextW('EdqeSahloEp')); // 'EqShop'
  if (EquipmentShop <> nil) and (EquipmentShop.Count > 0) then
  begin
    for I := 0 to EquipmentShop.Count - 1 do
    begin
      Item := EquipmentShop[I];
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
      Item.LoadFromBlock(ShopBlock.GetBlockByPath(Text));
    end;
  end
  else if (GetPlayer.DockedTo = Self) and (TemporaryShopSlots <> nil) then
    for I := 0 to TemporaryShopSlots.Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      Item := Slot.Item;
      if Item <> nil then
      begin
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
        Item.LoadFromBlock(ShopBlock.GetBlockByPath(Text));
      end;
    end;
  Text := ShopBlock.GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
  for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
  begin
    Name := ExtractDelimitedPartW(Text, I, ',');
    for Kind := Low(TItemType) to High(TItemType) do
    begin
      if ItemTypeNames[Kind] <> Name then Continue;
      if Kind in [item_hull..item_custom_weapon] then
      begin
        Item := CreateDefaultItemByType(Kind);
        if Item <> nil then
        begin
          if (TemporaryShopSlots <> nil) and (TemporaryShopStation = Self) then
          begin
            RestoreTemporaryShopStock;
            EquipmentShop.Add(Item);
            BuildTemporaryShopSlotGrid;
          end
          else EquipmentShop.Add(Item);
        end;
      end;
      Break;
    end;
  end;
  with Block.GetBlockByPath(DecodeTextW('Sataokrgalgae')) do // 'Storage'
  begin
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      if PStorageEntry(GetPlayer.StorageEntries[I]).LocationOwner = Self then
      begin
        Item := PStorageEntry(GetPlayer.StorageEntries[I]).Item;
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Item.Id); // 'ItemId'
        Item.LoadFromBlock(GetBlockByPath(Text));
      end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Name := ExtractDelimitedPartW(Text, I, ',');
      for Kind := Low(TItemType) to High(TItemType) do
        if ItemTypeNames[Kind] = Name then
        begin
          if (Kind in [item_food..item_narcotics]) or (Kind in [item_hull..item_custom_weapon]) or (Kind in [artefact_hull..artefact_extra_missiles]) or (Kind in [item_nodes..item_satellite]) then
          begin
            Item := CreateDefaultItemByType(Kind);
            if Item <> nil then
            begin
              New(Entry);
              Entry.LocationOwner := Self;
              Entry.SlotIndex := GetPlayer.FindNextStorageSlot(Self);
              Entry.Item := Item;
              GetPlayer.StorageEntries.Add(Entry);
              GetPlayer.RefreshStorageBubbles;
            end;
          end;
          Break;
        end;
    end;
  end;
end;
{ @end $69B9CC }

{ @routine $69C090 TRuins_ResolveLoadedReferences }
procedure TRuins.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  Count: Integer;
  I: Integer;
  Item: TItem;
begin
  inherited ResolveLoadedReferences(Galaxy);
  Count := EquipmentShop.Count;
  for I := 0 to Count - 1 do
  begin
    Item := EquipmentShop[I];
    Item.ResolveLoadedReferences(Galaxy);
  end;
  FlyToStar := TObject(Galaxy.IdToStar(Cardinal(FlyToStar))) as TStar;
end;
{ @end $69C090 }

{ @routine $69C0F0 TRuins_ClearObjectReferences }
procedure TRuins.ClearObjectReferences;
var
  Count: Integer;
  I: Integer;
  Item: TItem;
begin
  inherited ClearObjectReferences;
  Count := EquipmentShop.Count;
  for I := 0 to Count - 1 do
  begin
    Item := EquipmentShop[I];
    Item.ClearReferences;
  end;
  FlyToStar := nil;
end;
{ @end $69C0F0 }

{ @routine $69C134 TRuins_NextDay }
procedure TRuins.NextDay;
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
{ @end $69C134 }

{ @routine $69C1F8 TRuins_NextDayLogic }
procedure TRuins.NextDayLogic;
var
  Stage: Integer;
  // Existing unknown four-byte native frame region.
  UnresolvedFrameBytes: array[0..3] of Byte;
  Imbalance, LocalBalance: Single;

  // @nested $69C188 FindDominionHomeStar
  function FindDominionHomeStar: TStar; // @addr $69C188 @calls "0x0069C609,0x0069C7C3"
  var I: Integer; Star: TStar;
  begin
    Result := nil;
    if (TransitOriginStar <> nil) and (TransitOriginStar.Dominion = Self) then
    begin
      Result := TransitOriginStar;
      Exit;
    end;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      if Star.Dominion = Self then
      begin
        Result := Star;
        Exit;
      end;
    end;
  end;
begin
  Stage := 0;
  try
    if IsDocked then OrderTakeoff;
    if not InNormalSpace then Exit;
    Stage := 1;
    if (EnemyShip <> nil) and (EnemyShip.CurrentStar <> CurrentStar) then EnemyShip := nil;
    Stage := 2;
    if NextRandomIntRange(1, 60, RandomState) = 1 then
    begin
      RepairBrokenEquipmentAtLocation;
      ReloadWeapons;
      if Galaxy.IsStationShopUpdateEnabled and not ModernizationSponsor then
      begin
        BuyEquipmentAtLocation(False);
        RepairBrokenEquipmentAtLocation;
      end;
    end;
    Stage := 3;
    AssignWeaponTargetsInStar;
    Stage := 4;
    QueueItemsWithinPickupRange;
    Stage := 5;
    if TypeId = station_pirate_base then
    begin
      Stage := 6;
      if Galaxy.HasUnresolvedDominatorSeries([series_blazer, series_keller, series_terron]) and (Galaxy.CurrentTurn mod 60 = 0) and
         (DaysSincePlayerSeen > 30) and (NodeReserve < Max(500, GetPlayer.TotalExperience div 10)) and
         (NodeReserve < 200 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor) then
        Inc(NodeReserve, NextRandomIntRange(0, Round(250 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor), RandomState));
    end
    else if TypeId = station_dominion then
    begin
      Stage := 7;
      AutoApplyMicroModules;
      ApplyInventoryMicroModulesToShopItems;
      Inc(RelocationAge);
      if CurrentStar.Dominion = Self then
      begin
        if (FlyToStar <> nil) and (CurrentStar.Battle <> 0) then
        begin
          FlyToStar := nil;
          FlyDate := 0;
          OrderNone(False);
        end;
        if (FlyToStar = nil) and (Order = order_none) then
        begin
          Stage := 8;
          if not TryRelocateToPirateStar and not TryStartAbductionCycle then TryRepositionInStar;
        end;
      end
      else
      begin
        if CurrentStar = FlyToStar then
        begin
          FlyToStar := nil;
          FlyDate := Galaxy.CurrentTurn + 30;
        end;
        Imbalance := Abs(CurrentStar.GetCachedFactionStrength(faction_coalition) - CurrentStar.GetCachedFactionStrength(faction_dominators) * 2.5) / Max(0.001, CurrentStar.GetCachedFactionStrength(faction_pirates));
        LocalBalance := EvaluateLocalForceBalance(Position);
        if ((LocalBalance < -150) or (Imbalance > 30)) and (FlyDate < Galaxy.CurrentTurn + 25) and (FlyDate > Galaxy.CurrentTurn) then
        begin
          FlyToStar := FindDominionHomeStar;
          if FlyToStar <> nil then FlyDate := Galaxy.CurrentTurn + 1 else FlyDate := 0;
        end
        else if (Imbalance > 1.5) or (LocalBalance < -8) then
          FlyDate := Min(FlyDate, Max(FlyDate - 15, Galaxy.CurrentTurn + 4))
        else if (Imbalance > 1.37) or (LocalBalance < -4) then
          FlyDate := Min(FlyDate, Max(FlyDate - 7, Galaxy.CurrentTurn + 4))
        else if (Imbalance > 1.25) or (LocalBalance < -2) then
          FlyDate := Min(FlyDate, Max(FlyDate - 3, Galaxy.CurrentTurn + 4))
        else if (Imbalance > 1.12) or (LocalBalance < -1) then
          FlyDate := Min(FlyDate, Max(FlyDate - 1, Galaxy.CurrentTurn + 4));
        if FlyDate < Galaxy.CurrentTurn + 3 then FlyToStar := FindDominionHomeStar;
      end;
    end;
    Stage := 9;
    if CargoFreeSpace < 0 then DropCargoUntilNotOverloaded;
    Stage := 10;
    if NextRandomIntRange(1, 17, RandomState) = 1 then RegenerateSatelliteOffer;
    Stage := 11;
    RefreshShopInventory;
    Stage := 12;
    UpdateGoodsMarketState;
    Stage := 13;
    if FlyToStar <> nil then
    begin
      if CurrentStar = FlyToStar then
      begin
        FlyToStar := nil;
        FlyDate := 0;
      end
      else if FlyDate <= Galaxy.CurrentTurn then OrderTeleport(FlyToStar, SelectTeleportArrivalPoint(FlyToStar), 10, True);
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TRuins.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $69C1F8 }

{ @routine $69CAA0 TRuins_GetName }
function TRuins.GetName: WideString;
begin
  Result := Name;
end;
{ @end $69CAA0 }

{ @routine $69CAB4 TRuins_GetFullName }
function TRuins.GetFullName(const Separator: WideString): WideString;
var Caption: WideString;
begin
  if TypeNameOverrideKey = '' then
    Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey) + Separator + Name
  else
  begin
    Caption := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Caption <> '' then Result := Caption + Separator + Name
    else Result := Name;
  end;
end;
{ @end $69CAB4 }

{ @routine $69CBBC TRuins_GetColoredFullName }
function TRuins.GetColoredFullName(const ColorTag: WideString): WideString;
begin
  if TypeNameOverrideKey = '' then
    Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey + 'Small') + ' ' + WrapTextInColor(Name, ColorTag)
  else Result := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey + 'Small') + ' ' + WrapTextInColor(Name, ColorTag);
end;
{ @end $69CBBC }

{ @routine $69CCFC TRuins_GetGreetingShipCategory }
function TRuins.GetGreetingShipCategory: TGreetingShipCategory;
begin
  Result := greeting_ship_transport; // Native default category, also used for transports.
end;
{ @end $69CCFC }

{ @routine $69CD00 TRuins_GetDominantCareer }
function TRuins.GetDominantCareer: TRangerCareer;
begin
  Result := career_trader;
end;
{ @end $69CD00 }

{ @routine $69CD04 TRuins_GetHomeStar }
function TRuins.GetHomeStar: TStar;
begin
  Result := nil;
end;
{ @end $69CD04 }

{ @routine $69CD08 TRuins_GetStrengthScaledPirateStatus }
function TRuins.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 0;
end;
{ @end $69CD08 }

{ @routine $69CD0C TRuins_GetDesiredCargoFreeSpace }
function TRuins.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;
{ @end $69CD0C }

{ @routine $69CD10 TRuins_RegenerateSatelliteOffer }
procedure TRuins.RegenerateSatelliteOffer;
var Level: Integer;
begin
  if SatelliteOffer = nil then SatelliteOffer := TSatellite.Create;
  Level := NextRandomIntRange(0, Round(Galaxy.ScaleIntByTechLevel(1, 5)), RandomState);
  SatelliteOffer.InitGenerated(Level, PickRandomEquipmentOwner(RandomState), RandomState);
  SatelliteOffer.TargetPlanet := nil;
end;
{ @end $69CD10 }

{ @routine $69CD94 TRuins_RefuelAtLocation }
procedure TRuins.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;
{ @end $69CD94 }

{ @routine $69CDBC TRuins_RepairBrokenEquipmentAtLocation }
procedure TRuins.RepairBrokenEquipmentAtLocation;
var I: Integer; Item, Artefact: TEquipment;
begin
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := Inventory[I];
    if (not (Item is TWeapon) or (TWeapon(Item).GetWeaponInfo.Availability <> availability_not_sold_node_repair)) and
       CanRepairEquipmentTech(Item) and ((Item.BrokenFlag <> 0) or (Item.ConditionPercent < 1)) then
    begin
      Item.BrokenFlag := 0;
      if ModernizationSponsor then Item.ConditionPercent := 1
      else Item.Repair;
    end;
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Artefact := Artefacts[I];
    if (Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 1) then
    begin
      Artefact.BrokenFlag := 0;
      if ModernizationSponsor then Artefact.ConditionPercent := 1
      else Artefact.Repair;
    end;
  end;
end;
{ @end $69CDBC }

{ @routine $69CEB0 TRuins_ReloadWeapons }
procedure TRuins.ReloadWeapons;
var I: Integer; Weapon: TWeapon;
begin
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    if (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) and (Weapon.Ammo < Weapon.AmmoCapacity) then
    begin
      if ModernizationSponsor then Inc(Weapon.Ammo)
      else Weapon.Ammo := Weapon.AmmoCapacity;
    end;
  end;
end;
{ @end $69CEB0 }

{ @routine $69CF04 TRuins_RefreshShopInventory }
procedure TRuins.RefreshShopInventory;
var I, Attempts, Added: Integer; Item: TEquipment; Kind: TItemType; Planet: TPlanet;
begin
  if ShopUpdateMode in [shop_update_disabled, shop_update_goods] then Exit;
  if (Galaxy.CurrentTurn > CreationTurn + 1) and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 7 <> 0) then Exit;
  Planet := CurrentStar.Planets[NextRandomIntRange(0, CurrentStar.Planets.Count - 1, RandomState)];
  if Planet.OwnerId = owner_uninhabited then Planet := nil;
  if EquipmentShop.Count >= CalculateEquipmentShopTargetCount then
    if Planet <> nil then
    begin
      I := SeededRandomIntRange(0, EquipmentShop.Count - 1, Seed * Cardinal(Galaxy.CurrentTurn));
      Item := EquipmentShop[I];
      if (Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '') then
      begin
        EquipmentShop.Delete(I);
        Item.Free;
      end;
    end;
  Added := 0;
  while (EquipmentShop.Count <= CalculateEquipmentShopTargetCount * 0.7) or ((EquipmentShop.Count <= CalculateEquipmentShopTargetCount) and (Planet <> nil)) do
  begin
    if Planet = nil then Planet := FindFirstInhabitedPlanetInStar;
    Inc(Added);
    if Added > 10 then Break;
    Attempts := 0;
    repeat
      Inc(Attempts);
      Kind := TItemType(SeededRandomIntRange(Ord(item_hull), Ord(WeaponCategoryItemType), (Seed * Cardinal(Galaxy.CurrentTurn)) * 175 + Cardinal(Attempts)));
    until (Attempts > 20) or (CountEquipmentShopItems(Kind) < StationEquipmentOfferQuotas[TypeId].ByItemCategory[Kind]);
    Item := GenerateEquipmentOffer(GetPlayer, Planet, Kind);
    if Item <> nil then
    begin
      EquipmentShop.Add(Item);
      RemoveSimilarShopItem(Item);
    end;
  end;
end;
{ @end $69CF04 }

{ @routine $69D104 TRuins_CalculateEquipmentShopTargetCount }
function TRuins.CalculateEquipmentShopTargetCount: Integer;
var Count: Integer; Kind: TItemType;
begin
  Count := 0;
  for Kind := item_hull to WeaponCategoryItemType do Inc(Count, StationEquipmentOfferQuotas[TypeId].ByItemCategory[Kind]);
  Result := Round(Count + NextRandomIntRange(-2, 2, RandomState));
  Result := Max(10, Min(Result, 18));
end;
{ @end $69D104 }

{ @routine $69D168 TRuins_CountEquipmentShopItems }
function TRuins.CountEquipmentShopItems(ItemType: TItemType): Integer;
var I, Count: Integer; Item: TItem;
begin
  Count := 0;
  for I := 0 to EquipmentShop.Count - 1 do
  begin
    Item := EquipmentShop[I];
    // The WeaponCategoryItemType shop bucket counts every weapon subtype.
    if (Item.ItemType = ItemType) or ((Item.ItemType in WeaponItemTypes) and (ItemType = WeaponCategoryItemType)) then Inc(Count);
  end;
  Result := Count;
end;
{ @end $69D168 }

{ @routine $69D1B8 TRuins_FindMostExpensiveShopItem }
function TRuins.FindMostExpensiveShopItem(MinCost, MaxCost: Integer): TItem;
var I: Integer; Item: TEquipment; Best: TItem;
begin
  Best := nil;
  for I := 0 to EquipmentShop.Count - 1 do
  begin
    Item := EquipmentShop[I];
    if Item.ItemType = item_hull then Continue;
    if Item.Cost > MaxCost then Continue;
    if Item.Cost < MinCost then Continue;
    if Best = nil then Best := Item
    else if Item.Cost > Best.Cost then Best := Item;
  end;
  Result := Best;
end;
{ @end $69D1B8 }

{ @routine $69D220 TRuins_RemoveSimilarShopItem }
function TRuins.RemoveSimilarShopItem(Item: TEquipment): Boolean;
var I: Integer; Existing: TEquipment;
begin
  Result := False;
  for I := 0 to EquipmentShop.Count - 1 do
  begin
    Existing := EquipmentShop[I];
    if not ((Existing.ItemType = Item.ItemType) and (Existing <> Item) and
       ((Existing.ScriptItem = nil) or (TScriptItem(Existing.ScriptItem).Name = ''))) then Continue;
    case Existing.ItemType of
      item_hull: if (Existing as THull).TechLevel = (Item as THull).TechLevel then Result := True;
      item_fuel_tanks: if (Existing as TFuelTanks).TechLevel = (Item as TFuelTanks).TechLevel then Result := True;
      item_engine: if (Existing as TEngine).TechLevel = (Item as TEngine).TechLevel then Result := True;
      item_radar: if (Existing as TRadar).TechLevel = (Item as TRadar).TechLevel then Result := True;
      item_scanner: if (Existing as TScaner).TechLevel = (Item as TScaner).TechLevel then Result := True;
      item_repair_robot: if (Existing as TRepairRobot).TechLevel = (Item as TRepairRobot).TechLevel then Result := True;
      item_cargo_hook: if (Existing as TCargoHook).TechLevel = (Item as TCargoHook).TechLevel then Result := True;
      item_defense_generator: if (Existing as TDefGenerator).TechLevel = (Item as TDefGenerator).TechLevel then Result := True;
    else
      if Existing.ItemType in WeaponItemTypes then
        if (Existing as TWeapon).TechLevel = (Item as TWeapon).TechLevel then Result := True;
    end;
    if Result then
    begin
      if EquipmentShop.Count < CalculateEquipmentShopTargetCount then
        Result := Abs(Existing.Weight - Item.Weight) < Existing.Weight div 5;
      if Result then
      begin
        EquipmentShop.Delete(I);
        Existing.Free;
        Break;
      end;
    end;
  end;
end;
{ @end $69D220 }

{ @routine $69D4E0 TRuins_SelectEquipmentOfferSpecialMicroModule }
function TRuins.SelectEquipmentOfferSpecialMicroModule(Item: TEquipment; Planet: TPlanet): Integer;
var I, Candidate, Count: Integer; Template: PMicroModuleTemplate; Ceiling, Minimum, Maximum: Integer;
begin
  Result := -1;
  if NextRandomIntRange(1, 100, RandomState) > Galaxy.GetMicroModuleOfferRollThresholdPercent then Exit;
  Ceiling := Round(Planet.InventionLevels[research_main_technology] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := @MicroModuleTemplates[0];
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    while True do
    begin
      if not Template.SpecialOnly then Break;
      if TypeNameOverrideKey <> '' then
      begin
        if (Template.OfferStationNames <> '<Any>') and (Pos('<' + TypeNameOverrideKey + '>', Template.OfferStationNames) <= 0) then Break;
      end
      else if not (TypeId in Template.OfferStationTypes) then Break;
      if not IsBonusCompatibleWithEquipment(I, Item) then Break;
      if Template.Priority > Ceiling then Break;
      if Count = 0 then
      begin
        Minimum := Template.Priority;
        Maximum := Template.Priority;
      end
      else
      begin
        Minimum := Min(Minimum, Template.Priority);
        Maximum := Max(Maximum, Template.Priority);
      end;
      MicroModuleCandidateIndices[Count] := I;
      Inc(Count);
      Break;
    end;
    Inc(Template);
  end;
  if Count <= 0 then Exit;
  Minimum := Max(0, Maximum - 40);
  for I := 0 to 10 do
  begin
    Candidate := NextRandomIntRange(0, Count - 1, RandomState);
    if MicroModuleTemplates[MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
    begin
      Result := MicroModuleCandidateIndices[Candidate];
      Break;
    end;
  end;
end;
{ @end $69D4E0 }

{ @routine $69D724 TRuins_SelectHullOfferSpecialMicroModule }
function TRuins.SelectHullOfferSpecialMicroModule(Hull: THull; Planet: TPlanet): Integer;
var I, Candidate, Count: Integer; Template: PMicroModuleTemplate; Ceiling, Minimum, Maximum: Integer;
begin
  Result := -1;
  if NextRandomIntRange(1, 100, RandomState) > Galaxy.GetMicroModuleOfferRollThresholdPercent then Exit;
  Ceiling := Round(Planet.InventionLevels[research_main_technology] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := @MicroModuleTemplates[0];
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    while True do
    begin
      if not Template.SpecialOnly then Break;
      if TypeNameOverrideKey <> '' then
      begin
        if (Template.OfferStationNames <> '<Any>') and (Pos('<' + TypeNameOverrideKey + '>', Template.OfferStationNames) <= 0) then Break;
      end
      else if not (TypeId in Template.OfferStationTypes) then Break;
      if not IsBonusCompatibleWithHull(I, Hull) then Break;
      if Template.Priority > Ceiling then Break;
      if Count = 0 then
      begin
        Minimum := Template.Priority;
        Maximum := Template.Priority;
      end
      else
      begin
        Minimum := Min(Minimum, Template.Priority);
        Maximum := Max(Maximum, Template.Priority);
      end;
      MicroModuleCandidateIndices[Count] := I;
      Inc(Count);
      Break;
    end;
    Inc(Template);
  end;
  if Count <= 0 then Exit;
  Minimum := Max(0, Maximum - 40);
  for I := 0 to 10 do
  begin
    Candidate := NextRandomIntRange(0, Count - 1, RandomState);
    if MicroModuleTemplates[MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
    begin
      Result := MicroModuleCandidateIndices[Candidate];
      Break;
    end;
  end;
end;
{ @end $69D724 }

{ @routine $69D968 TRuins_SelectWeaponOfferSpecialMicroModule }
function TRuins.SelectWeaponOfferSpecialMicroModule(Weapon: TWeapon; Planet: TPlanet): Integer;
var I, Candidate, Count: Integer; Template: PMicroModuleTemplate; Ceiling, Minimum, Maximum: Integer;
begin
  Result := -1;
  if NextRandomIntRange(1, 100, RandomState) > Galaxy.GetMicroModuleOfferRollThresholdPercent then Exit;
  Ceiling := Round(Planet.InventionLevels[research_main_technology] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := @MicroModuleTemplates[0];
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    while True do
    begin
      if not Template.SpecialOnly then Break;
      if TypeNameOverrideKey <> '' then
      begin
        if (Template.OfferStationNames <> '<Any>') and (Pos('<' + TypeNameOverrideKey + '>', Template.OfferStationNames) <= 0) then Break;
      end
      else if not (TypeId in Template.OfferStationTypes) then Break;
      if not IsBonusCompatibleWithWeapon(I, Weapon) then Break;
      if Template.Priority > Ceiling then Break;
      if Count = 0 then
      begin
        Minimum := Template.Priority;
        Maximum := Template.Priority;
      end
      else
      begin
        Minimum := Min(Minimum, Template.Priority);
        Maximum := Max(Maximum, Template.Priority);
      end;
      MicroModuleCandidateIndices[Count] := I;
      Inc(Count);
      Break;
    end;
    Inc(Template);
  end;
  if Count <= 0 then Exit;
  Minimum := Max(0, Maximum - 40);
  for I := 0 to 10 do
  begin
    Candidate := NextRandomIntRange(0, Count - 1, RandomState);
    if MicroModuleTemplates[MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
    begin
      Result := MicroModuleCandidateIndices[Candidate];
      Break;
    end;
  end;
end;
{ @end $69D968 }

{ @routine $69DBAC TRuins_BuildReachablePlanetQueue }
procedure TRuins.BuildReachablePlanetQueue;
begin
end;
{ @end $69DBAC }

{ @routine $69DBB0 TRuins_CanQueueReachablePlanet }
function TRuins.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := False;
end;
{ @end $69DBB0 }

{ @routine $69DBB4 TRuins_SelectEnemyShipInStar }
procedure TRuins.SelectEnemyShipInStar;
begin
  EnemyShip := nil;
end;
{ @end $69DBB4 }

{ @routine $69DBC0 TRuins_EngageEnemyShip }
procedure TRuins.EngageEnemyShip;
begin
end;
{ @end $69DBC0 }

{ @routine $69DBC4 TRuins_AssignWeaponTargetsInStar }
procedure TRuins.AssignWeaponTargetsInStar;
var I, J, Assigned: Integer; Ship: TShip; Weapon: TWeapon; Asteroid: TAsteroid; DistanceSquared: Single; Missile: TMissile;
begin
  Assigned := 0;
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    Weapon.Target := nil;
  end;
  if (GetPlayer.CurrentStar = CurrentStar) or (NextRandomUnitFloat(RandomState) > 0.7) or Galaxy.IsFullStationTargetingEnabled or
     (CurrentStar.ControlFaction = faction_dominators) or (CurrentStar.Status.CustomFaction <> '') then
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := CurrentStar.Ships[I];
      if ((Ship.OwnerId = owner_dominator) or (Ship.RelationToShip(Self) < RelationBadMin)) and Ship.InNormalSpace and
         (not HasIndependentScriptFaction or not Ship.HasIndependentScriptFaction or
          (TScriptShip(ScriptShip).StateText <> TScriptShip(Ship.ScriptShip).StateText)) then
        for J := 1 to WeaponCount do
        begin
          Weapon := Weapons[J];
          if not ((Weapon.Target = nil) and IsEquipmentUsable(Weapon) and
             (PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)))) then Continue;
          Weapon.Target := Ship;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
        end;
    end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do
  begin
    Missile := CurrentStar.Missiles[I];
    if (Missile.OwnerShip <> Self) and (Missile.Target = Self) then
      for J := 1 to WeaponCount do
      begin
        Weapon := Weapons[J];
        if not (not (Weapon.GetWeaponInfo.ShotType in [shot_torpedo..shot_rocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) and
           (PointDistanceSquared(Position, Missile.Position) <= Sqr(GetWeaponRange(Weapon)))) then Continue;
        Weapon.Target := Missile;
        Inc(Assigned);
        if Assigned = WeaponCount then Exit;
        Break;
      end;
  end;
  if (CurrentStar.Items.Count < 10) and (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do
    begin
      Asteroid := CurrentStar.Asteroids[I];
      DistanceSquared := PointDistanceSquared(Position, Asteroid.Position);
      if DistanceSquared <= AsteroidTargetRangeSquared then
        for J := 1 to WeaponCount do
        begin
          Weapon := Weapons[J];
          if not (((NextRandomUnitFloat(RandomState) <= 0.9) or (GetHullIntegrityPercent <= 90)) and
             not (Weapon.GetWeaponInfo.ShotType in [shot_area_damage..shot_rocket]) and IsEquipmentUsable(Weapon) and
             (Sqr(GetWeaponRange(Weapon)) >= DistanceSquared)) then Continue;
          Weapon.Target := Asteroid;
          Inc(Assigned);
          if Assigned = WeaponCount then Exit;
          Break;
        end;
    end;
end;
{ @end $69DBC4 }

{ @routine $69DFC0 TRuins_TryStartAbductionCycle }
function TRuins.TryStartAbductionCycle: Boolean;
var I, J, Count: Integer; Ship: TShip; Star: TStar;
begin
  Result := False;
  if CurrentStar.Dominion <> Self then Exit;
  if (PickupTargets <> nil) and (PickupTargets.Count > 0) then Exit;
  if CurrentStar.Dominion <> Self then Exit;
  if CurrentStar.Battle <> 0 then Exit;
  if RelocationAge < 135.0 then Exit;
  if NextRandomIntRange(1, 100, RandomState) <= Round(RemapClamped(RelocationAge, 135, 675, 100, 95)) then Exit;
  Count := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if Ship.AbductedByPirateClan then Exit;
    if not (Ship.InNormalSpace and (Ship is TPirate) and (Ship.ScriptShip = nil) and (Ship.AbsoluteScriptOrder <= 0) and
      (Ship.Order in [order_none, order_move])) then Continue;
    Inc(Count);
  end;
  if Count < 5 then Exit;
  Count := 0;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    if CurrentStar.StarDistances[I].Distance > 40 then Break;
    Star := TStar(CurrentStar.StarDistances[I].Star);
    if not ((Star.ControlFaction = faction_coalition) and (Star.Status.CustomFaction = '')) then Continue;
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.InNormalSpace and (Ship.Order = order_jump) and
        (TStar(Ship.OrderTarget).ControlFaction = faction_coalition) and (TStar(Ship.OrderTarget).Status.CustomFaction = '') and
        (Ship.EstimateOrderTravelTurns >= 2) and (Ship is TNormalShip) and (Ship.OwnerId <> owner_pirate) and
        (Ship.TypeId in [ship_ranger..ship_transport]) and (Ship.ScriptShip = nil) and (Ship.AbsoluteScriptOrder <= 0) then Inc(Count);
    end;
  end;
  if Count <= 0 then Exit;
  RelocationAge := (RelocationAge - 90) div 2;
  OrderTeleport(CurrentStar, Position, 10, True);
  Result := True;
end;
{ @end $69DFC0 }

{ @routine $69E2A4 TRuins_TryAbductDepartingShip }
procedure TRuins.TryAbductDepartingShip(Ship: TShip);
var
  Candidate: TNormalShip;
begin
  if CurrentStar.Dominion <> Self then Exit;
  if not InHyperspace then Exit;
  if Order <> order_teleport then Exit;
  if OrderTarget <> CurrentStar then Exit;
  if Cardinal(OrderStateData) <= 1 then Exit;
  if Ship.ScriptShip <> nil then Exit;
  if Ship.HasScriptControl then Exit;
  if Ship.CountActiveArtefacts(artefact_hyperjump) > 0 then Exit;
  if not (Ship is TNormalShip) then Exit;
  Candidate := TNormalShip(Ship);
  if Candidate.AbductedByPirateClan then Exit;
  if Candidate is TPirate then Exit;
  if Candidate.CurrentStanding in [standing_pirate_passive..standing_pirate_military] then Exit;
  if (GetPlayer <> nil) and (GetPlayer.QuestTargetDefendShip = Candidate) and (NextRandomIntRange(1, 100, RandomState) > 70) then Exit;
  if GetPlayer = Candidate then
  begin
    if Galaxy.CurrentTurn < 200 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor + GalaxyWarmupTurns then Exit;
    if NextRandomIntRange(0, 100, RandomState) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor < 40 then Exit;
  end;
  if Candidate.TypeId = ship_transport then Candidate.AbductedByPirateClan := True
  else if Candidate.TypeId = ship_ranger then
    case (Candidate as TRanger).GetDominantCareer of
      career_trader: Candidate.AbductedByPirateClan := NextRandomIntRange(1, 100, RandomState) > 30;
      career_warrior: Candidate.AbductedByPirateClan := NextRandomIntRange(1, 100, RandomState) > 70;
      career_pirate: Candidate.AbductedByPirateClan := NextRandomIntRange(1, 100, RandomState) > 50;
    end;
  if not Candidate.AbductedByPirateClan then Exit;
  Candidate.OrderTarget := CurrentStar;
  Candidate.OrderStateData := OrderStateData + NextRandomIntRange(1, 10, RandomState);
end;
{ @end $69E2A4 }

{ @routine $69E510 TRuins_ReportAbductionOutcome }
procedure TRuins.ReportAbductionOutcome;
var
  Text: WideString;
  I, Abducted, Pirates: Integer;
  Ship: TShip;
begin
  Abducted := 0;
  Pirates := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if Ship.AbductedByPirateClan then Inc(Abducted);
    if Ship.InNormalSpace and (Ship is TPirate) and (Ship.ScriptShip = nil) and (Ship.Order in [order_none, order_move]) then Inc(Pirates);
  end;
  Text := TextHighlightColorTag + GetFullName(' ') + EndColorTag + #13#10;
  if Abducted = 0 then Text := Text + LookupTalkText('Talk.PirateClan.RuinTalkAfterAbduct.Failure')
  else if Pirates = 0 then Text := Text + LookupTalkText('Talk.PirateClan.RuinTalkAfterAbduct.SuccessNoPirate')
  else Text := Text + LookupTalkText('Talk.PirateClan.RuinTalkAfterAbduct.Success');
  AddOrUpdatePlayerBubble(message_radio, Galaxy.CurrentTurn, Text, '').Targets[0].ShipId := Id;
end;
{ @end $69E510 }

{ @routine $69E800 TRuins_EvaluateLocalForceBalance }
function TRuins.EvaluateLocalForceBalance(Point: TPointF): Single;
var I: Integer; Ship: TShip; ReferenceStrength, RelationFactor, HullFraction: Single;
begin
  Result := 0;
  RefreshDerivedStats(True);
  HullFraction := Max(0.01, GetHull.HullPoints / GetHull.Weight);
  ReferenceStrength := Max(1.0, Strength / (UsableWeaponCount + 7) + Galaxy.AverageRangerStrength * 0.1 * HullFraction);
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    RelationFactor := 1;
    if (Ship.DockedTo = Self) and ((FlyToStar = nil) or (FlyToStar = CurrentStar)) then RelationFactor := 0.75
    else if not Ship.InNormalSpace then Continue;
    if GetRelationLevelToShip(Ship) = relation_level_hostile then RelationFactor := -1 * RelationFactor
    else if GetRelationLevelToShip(Ship) = relation_level_excellent then RelationFactor := 1 * RelationFactor
    else if GetRelationLevelToShip(Ship) = relation_level_good then RelationFactor := 0.5 * RelationFactor
    else Continue;
    if RelationFactor > 0 then RelationFactor := RelationFactor * HullFraction;
    Result := Result + Ship.Strength / (Ship.UsableWeaponCount + 7) / ReferenceStrength * RelationFactor *
      Min(1.0, Ship.Speed / Max(100, PointDistance(Point, Ship.Position)));
  end;
end;
{ @end $69E800 }

{ @routine $69EADC TRuins_EvaluateRelocationPosition }
function TRuins.EvaluateRelocationPosition(Point: TPointF): Single;
var I, RangeSquared: Integer; Item: TItem;
begin
  Result := 0;
  if IsEquipmentUsable(GetCargoHook) then
  begin
    RangeSquared := GetCargoHookRangeSquared;
    for I := 0 to CurrentStar.Items.Count - 1 do
    begin
      Item := CurrentStar.Items[I];
      if CanCargoHookHandleItem(Item, Self) and (PointDistanceSquared(Point, Item.Position) <= RangeSquared) and AcceptPickupItem(Item) then
        Result := Result + Item.Cost;
    end;
  end;
  Result := Result / Max(10, Galaxy.ComputeScaledMiniMoney(owner_human));
  Result := Result * RemapClamped(RelocationAge, 30, 90, 0.3, 1);
  if CurrentStar.Battle <> 0 then Result := Result + EvaluateLocalForceBalance(Point);
end;
{ @end $69EADC }

{ @routine $69EC00 TRuins_TryRepositionInStar }
function TRuins.TryRepositionInStar: Boolean;
const StationTypes = [station_ranger_center..station_custom];
var SavedPoint, BestPoint: TPointF; InitialScore, BestScore, Score, Radius: Single; I: Integer;
begin
  Result := False;
  if (PickupTargets <> nil) and (PickupTargets.Count > 0) then Exit;
  if RelocationAge < 30 then Exit;
  for I := 0 to CurrentStar.Ships.Count - 1 do
    if TShip(CurrentStar.Ships[I]).AbductedByPirateClan and TShip(CurrentStar.Ships[I]).InHyperspace then Exit;
  SavedPoint := Position;
  InitialScore := EvaluateRelocationPosition(Position);
  BestScore := InitialScore;
  for I := 0 to 100 do
  begin
    RandomizePosition;
    Score := EvaluateRelocationPosition(Position);
    if (Score >= BestScore) and (DistanceToNearestShipByTypeMask(StationTypes) > 700) then
    begin
      BestScore := Score;
      BestPoint := Position;
    end;
  end;
  if ((InitialScore > 0) and (BestScore < InitialScore + 10)) or (BestScore < InitialScore + 5) then
  begin
    Position := SavedPoint;
    Exit;
  end;
  Radius := 100;
  for I := 0 to 100 do
  begin
    Position.X := BestPoint.X + NextRandomIntRange(-100, 100, RandomState) * 0.01 * Radius;
    Position.Y := BestPoint.Y + NextRandomIntRange(-100, 100, RandomState) * 0.01 * Radius;
    if (DistanceToNearestShipByTypeMask(StationTypes) > 700) and (Sqr(Position.X) + Sqr(Position.Y) >= Sqr(CurrentStar.SafeRadius) * 1.1) then
    begin
      Score := EvaluateRelocationPosition(Position);
      if Score >= BestScore then
      begin
        BestScore := Score;
        BestPoint := Position;
        Radius := Radius * 0.75;
      end;
    end;
  end;
  Position := SavedPoint;
  RelocationAge := (RelocationAge - 30) div 2;
  OrderTeleport(CurrentStar, BestPoint, 0, True);
  Result := True;
end;
{ @end $69EC00 }

{ @routine $69EEB4 TRuins_TryRelocateToPirateStar }
function TRuins.TryRelocateToPirateStar: Boolean;
var I: Integer; Star: TStar; Candidates: TList; Constellation: TConstellation;
begin
  Result := False;
  if CurrentStar.Battle = 0 then Exit;
  if RelocationAge < 45 then Exit;
  if CurrentStar.Dominion <> Self then Exit;
  if EvaluateLocalForceBalance(Position) > -10 then Exit;
  Candidates := TList.Create;
  Constellation := CurrentStar.Constellation;
  for I := 0 to Constellation.Stars.Count - 1 do
  begin
    Star := Constellation.Stars[I];
    if Star = CurrentStar then Continue;
    if Star.ControlFaction <> faction_pirates then Continue;
    if Star.Battle <> 0 then Continue;
    if IsStarProtectedByScript(Star) then Continue;
    if Star.Dominion <> nil then Continue;
    if Star.Status.CustomFaction <> '' then Continue;
    Candidates.Add(Star);
  end;
  if Candidates.Count = 0 then
  begin
    Candidates.Free;
    Exit;
  end;
  Star := Candidates[NextRandomIntRange(0, Candidates.Count - 1, RandomState)];
  Candidates.Free;
  CurrentStar.Dominion := nil;
  Star.Dominion := Self;
  FlyToStar := Star;
  FlyDate := Galaxy.CurrentTurn + 1;
  RelocationAge := (RelocationAge - 150) div 2;
  Result := True;
end;
{ @end $69EEB4 }

{ @routine $69F010 TRuins_AcceptPickupItem }
function TRuins.AcceptPickupItem(Item: TItem): Boolean;
const
  DominionPickupTypes = [item_food..artefact_antigravity, artefact_defense_to_energy..artefact_hyperjump,
    artefact_defense_to_weapon_slot..item_custom_weapon, item_micro_module];
  StationPickupTypes = [item_food..item_narcotics, item_hull..item_custom_weapon];
begin
  Result := False;
  if TypeId = station_dominion then
  begin
    if not (Item.ItemType in DominionPickupTypes) then Exit;
  end
  else if not ((Item.ItemType in StationPickupTypes) and (Item.OwnerId <> owner_dominator)) then Exit;
  Result := True;
end;
{ @end $69F010 }

{ @routine $69F050 TRuins_ApplyInventoryMicroModulesToShopItems }
procedure TRuins.ApplyInventoryMicroModulesToShopItems;
var I, J: Integer; Module: TItem; Item: TEquipment; Applied: Boolean;
begin
  Applied := True;
  while Applied do
  begin
    Applied := False;
    for I := 1 to Inventory.Count - 1 do
    begin
      Module := Inventory[I];
      if Module is TMicroModule then
        for J := 0 to EquipmentShop.Count - 1 do
        begin
          Item := EquipmentShop[J];
          if (Module as TMicroModule).CanInstallOn(Item) then
          begin
            Applied := True;
            ApplyMicroModule((Module as TMicroModule).MicroModuleIndex - 1, Item);
            Inventory.Delete(Inventory.IndexOf(Module));
            Module.Free;
            RefreshDerivedStats(True);
            Break;
          end;
        end;
      if Applied then Break;
    end;
  end;
end;
{ @end $69F050 }

{ @routine $69F168 TRuins_RelationToNonRanger }
function TRuins.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship.TypeId in [ship_dominator, ship_tranclucator] then Result := 50 else Result := 100;
end;
{ @end $69F168 }

{ @routine $69F17C TRuins_RelationToRanger }
function TRuins.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := Byte(RangerRelations[Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)]);
  if not NoLanding or (GetPlayer <> Ranger) then Result := Max(50, Result);
end;
{ @end $69F17C }

{ @routine $69F1D8 TRuins_ChangeRelationToRanger }
procedure TRuins.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var Relation: Byte; NewRelation, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(RangerRelations[Index]);
  if (Amount > 0) and (TShip(Ranger).GetEffectiveSkillLevel(skill_charisma) > 0) then
    Inc(Amount, Round((TShip(Ranger).GetEffectiveSkillLevel(skill_charisma)) * Amount * 0.2));
  NewRelation := Relation + Amount;
  if NewRelation < 0 then Relation := 0
  else if NewRelation > 100 then Relation := 100
  else Relation := NewRelation;
  RangerRelations[Index] := Pointer(Relation);
  if (Relation < RelationBadMin) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then
  begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then
      GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $69F1D8 }

{ @routine $69F2FC TRuins_ReactToAttack }
procedure TRuins.ReactToAttack(Attacker: TShip);
var I: Integer; Planet: TPlanet; Independent: Boolean;
begin
  EnemyShip := Attacker;
  if CurrentStanding = standing_custom then Exit;
  Independent := not (CurrentStanding in FactionStandingMasks[CurrentStar.ControlFaction]) or (CurrentStar.Status.CustomFaction <> '');
  if Attacker.TypeId = ship_ranger then
  begin
    ChangeRelationToRanger(Attacker, -10);
    if Independent then Exit;
    if (CurrentStar.ControlFaction = faction_pirates) and (MainPiratePlanet <> nil) then MainPiratePlanet.ChangeRelationToRanger(Attacker, -10)
    else if CurrentStar.ControlFaction <> faction_dominators then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := CurrentStar.Planets[I];
        if Planet.OwnerId <> owner_uninhabited then Planet.ChangeRelationToRanger(Attacker, -10);
      end;
  end;
  if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = ship_ranger) then
  begin
    ChangeRelationToRanger(Attacker.PartnerShip, -5);
    if Independent then Exit;
    if (CurrentStar.ControlFaction = faction_pirates) and (MainPiratePlanet <> nil) then MainPiratePlanet.ChangeRelationToRanger(Attacker.PartnerShip, -5)
    else if CurrentStar.ControlFaction <> faction_dominators then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := CurrentStar.Planets[I];
        if Planet.OwnerId <> owner_uninhabited then Planet.ChangeRelationToRanger(Attacker.PartnerShip, -5);
      end;
  end;
  if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and (TTranclucator(Attacker).OwnerShip.TypeId = ship_ranger) then
  begin
    ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10);
    if Independent then Exit;
    if (CurrentStar.ControlFaction = faction_pirates) and (MainPiratePlanet <> nil) then MainPiratePlanet.ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10)
    else if CurrentStar.ControlFaction <> faction_dominators then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := CurrentStar.Planets[I];
        if Planet.OwnerId <> owner_uninhabited then Planet.ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10);
      end;
  end;
  if not Independent and (Attacker is TNormalShip) and
     ((Attacker as TNormalShip).CurrentSystemKills.ByFaction[CurrentStar.ControlFaction] = 0) then
    (Attacker as TNormalShip).CurrentSystemKills.ByFaction[CurrentStar.ControlFaction] := 1;
end;
{ @end $69F2FC }

{ @routine $69F5A0 TRuins_RecomputeFearState }
function TRuins.RecomputeFearState: Boolean;
begin
  Result := False;
end;
{ @end $69F5A0 }

{ @routine $69F5A4 TRuins_AcceptsRansomDemandFrom }
function TRuins.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := False;
end;
{ @end $69F5A4 }

{ @routine $69F5A8 TRuins_TrustsAttackRequester }
function TRuins.TrustsAttackRequester(Ship: TShip): Boolean;
begin
  Result := True;
end;
{ @end $69F5A8 }

{ @routine $69F5AC TRuins_AcceptsAppealFrom }
function TRuins.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := False;
end;
{ @end $69F5AC }

{ @routine $69F5B0 TRuins_ProcessCombatDialogue }
procedure TRuins.ProcessCombatDialogue;
begin
end;
{ @end $69F5B0 }

{ @routine $69F5B4 TRuins_ReactToExtortionDemand }
procedure TRuins.ReactToExtortionDemand(Ranger: Pointer);
begin
end;
{ @end $69F5B4 }

{ @routine $69F5B8 TRuins_BuildMoneyExtortionResponse }
function TRuins.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $69F5B8 }

{ @routine $69F604 TRuins_BuildCargoExtortionResponse }
function TRuins.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $69F604 }

{ @routine $69F648 TRuins_BuildTrucePaymentResponse }
function TRuins.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $69F648 }

{ @routine $69F694 TRuins_BuildAttackRequestResponse }
function TRuins.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;
{ @end $69F694 }

{ @routine $69F6E0 TRuins_AcceptPartnershipOffer }
function TRuins.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $69F6E0 }

{ @routine $69F724 TRuins_BuildPartnershipOfferResponse }
function TRuins.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;
{ @end $69F724 }

{ @routine $69F768 TRuins_ForceGoodsForSale }
procedure TRuins.ForceGoodsForSale(GoodsMask: TItemTypeMask);
var Good: Byte;
begin
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    if Good in GoodsMask then
    begin
      ShopGoods[Good].PriceState := GoodsMarket[Good].MinPrice * NextRandomFloatRange(0.9, 1.1, RandomState);
      ShopGoods[Good].Count := Max(ShopGoods[Good].Count + NextRandomIntRange(1, GoodsMarket[Good].BaseStock div 10 + 1, RandomState), GoodsMarket[Good].BaseStock div 10 + 1);
      ShopGoods[Good].PurchasePrice := Round(ShopGoods[Good].PriceState);
      ShopGoods[Good].BaseSalePrice := Max(1, Round(ShopGoods[Good].PriceState * 0.98 - 1));
    end;
end;
{ @end $69F768 }

{ @routine $69F8A4 TRuins_GenerateCombatSkills }
procedure TRuins.GenerateCombatSkills;
var Level, Accuracy, Maneuverability: Integer;
begin
  Level := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 4));
  if Galaxy.GetFactionControlPercent(faction_dominators) < 40 then Dec(Level, 2);
  if Galaxy.GetFactionControlPercent(faction_dominators) > 80 then Inc(Level);
  if Galaxy.WarDeltaWin[faction_dominators] > -3 then Inc(Level);
  if Galaxy.WarDeltaWin[faction_dominators] < 3 then Dec(Level, 2);
  Accuracy := NextRandomIntRange(Level - 1, Level + 1, RandomState);
  Maneuverability := NextRandomIntRange(Level - 1, Level + 1, RandomState);
  Accuracy := Min(5, Max(0, Accuracy));
  Maneuverability := Min(5, Max(0, Maneuverability));
  BaseSkills[skill_accuracy] := Accuracy;
  BaseSkills[skill_maneuverability] := Maneuverability;
end;
{ @end $69F8A4 }

{ @routine $69F994 TRuins_RandomizePosition }
procedure TRuins.RandomizePosition;
var Point: TPointF;
begin
  Point := SelectTeleportArrivalPoint(CurrentStar);
  Position := Point;
end;
{ @end $69F994 }

{ @routine $69FA40 TRuins_SelectTeleportArrivalPoint }
function TRuins.SelectTeleportArrivalPoint(Star: TStar): TPointF;
var Attempts: Integer; Planet: TPlanet; LastPlanet: Integer; Polar: TPolarPoint;

  // @nested $69F9B8 IsStationArrivalPointClear
  function IsStationArrivalPointClear(Point: TPointF): Boolean; // @addr $69F9B8 @calls "0x0069FAFA"
  var I: Integer; Ship: TShip; DistanceSquared: Single;
  begin
    Result := False;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if (Ship is TRuins) and (Ship <> Self) then
      begin
        DistanceSquared := PointDistanceSquared(Point, Ship.Position);
        if DistanceSquared <= 490000 then Exit;
      end;
    end;
    Result := True;
  end;
begin
  Attempts := 0;
  LastPlanet := Star.Planets.Count - 1;
  if Galaxy.AreStationsNearStarsEnabled then LastPlanet := LastPlanet div 2;
  repeat
    Planet := Star.Planets[NextRandomIntRange(0, LastPlanet, RandomState)];
    Polar.Radius := Planet.Radius + Planet.Orbit.Radius + 100 + NextRandomIntRange(0, 50, RandomState);
    Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
    Result := PolarToPoint(Polar);
    Inc(Attempts);
  until IsStationArrivalPointClear(Result) or (Attempts > 1000);
end;
{ @end $69FA40 }

{ @routine $69FB1C TRuins_AdjustItemEvaluation }
function TRuins.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
begin
  Result := Effectiveness;
end;
{ @end $69FB1C }

{ @routine $69FB30 TRuins_EvaluateStatBonus }
function TRuins.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
      NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonus_armor: Result := Value * 300;
    bonus_radar_range: Result := ShortInt(GetRadar = nil);
    bonus_scanner_power: Result := Value * 20 * CountWeaponsByDamageFlags(ScannerFlags);
    bonus_repair_points: Result := Value * 20 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonus_defense: Result := Value * 8 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonus_energy_damage: Result := Value * 10;
    bonus_splinter_damage: Result := Value * 10;
    bonus_missile_damage: Result := Value * 10 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonus_weapon_range: Result := Value;
    bonus_accuracy..bonus_leadership:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), Value) * StationSkillBonusWeights[BonusKind];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) > 6) then
          Result := Result + (StationSkillBonusWeights[BonusKind] * 0.05) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]), -Value) * -StationSkillBonusWeights[BonusKind];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]) < 0) then
          Result := Result + (StationSkillBonusWeights[BonusKind] * 0.03) * (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[BonusKind]));
      end;
  end;
  if TypeId = station_dominion then
    case BonusKind of
      bonus_hook_power: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.0;
      bonus_hook_range: Result := Value * 1.5;
    end;
end;
{ @end $69FB30 }

{ @routine $69FFA4 TRuins_EvaluateWeaponDamage }
function TRuins.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [damage_flag_scanner_bonus..damage_flag_droid_block];
  ShockFlags = [damage_flag_shock];
  AcidFlags = [damage_flag_acid];
var
  ScannerFactor, StatusFactor: Single;
  Flags: TDamageFlagSet;
  HasOtherWeapon: Boolean;
  I, ShotTotal: Integer;
begin
  Flags := Weapon.GetDamageFlags;
  if (Flags * ScannerFlags <> []) and (GetScanner <> nil) and (GetRadar <> nil) then
    ScannerFactor := RemapClamped(GetScannerPower - DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(Galaxy.TechLevel)) + 1, -5, 10, 0.1, 2)
  else ScannerFactor := 0;
  Result := BaseDamage * GetWeaponArtefactDamageFactor(Weapon);
  if damage_flag_life_steal in Flags then Result := Result * 1.5;
  if damage_flag_shock in Flags then Result := Result * (1.05 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  if damage_flag_acid in Flags then Result := Result * 1.05;
  StatusFactor := 1;
  if damage_flag_scanner_bonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if damage_flag_bonus_to_damaged_hull in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if damage_flag_weapon_block in Flags then Result := Result + ScannerFactor * 5;
    if damage_flag_droid_block in Flags then Result := Result + ScannerFactor * 5;
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if damage_flag_acid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
  end;
  case Weapon.GetWeaponInfo.ShotType of
    shot_rocket: Result := Result * 1.1 * Weapon.GetShotCount * (1 + StatusFactor);
    shot_missile: Result := Result * (1.1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor) * Weapon.GetShotCount;
    shot_torpedo: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor);
    shot_chain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    shot_splash: Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 + StatusFactor);
    shot_area_damage: Result := Result * (1 + Weapon.Range * 1.3 * 0.01 + StatusFactor);
  else Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  HasOtherWeapon := False;
  for I := 1 to CountEquippedWeapons do
    if not (Weapons[I].GetWeaponInfo.ShotType in [shot_area_damage..shot_rocket]) then HasOtherWeapon := True;
  if not HasOtherWeapon and (Weapon.GetWeaponInfo.ShotType in [shot_area_damage..shot_rocket]) then Result := Result * 0.5;
end;
{ @end $69FFA4 }

{ @routine $6A0428 TRuins_RefreshCurrentStanding }
procedure TRuins.RefreshCurrentStanding;
var StandingMode: TStandingOverride;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = override_custom_faction then CurrentStanding := standing_custom
  else if StandingMode <> override_fixed then
    if TypeId <> station_custom then CurrentStanding := StationDefaultStandings[TypeId];
end;
{ @end $6A0428 }

{ @routine $6A0464 TRuins_GeneratePlanetHullOffer }
function TRuins.GeneratePlanetHullOffer(Ship: TObject; Planet: TPlanet): THull;
var Buyer: TShip; ModuleIndex: Integer;
begin
  Result := nil;
  if (Planet <> nil) and (Ship <> nil) and (Ship is TShip) then
  begin
    Buyer := TShip(Ship);
    Result := Planet.GenerateHullOffer(Ship);
    if Result = nil then Exit;
    ModuleIndex := Result.SpecialModuleIndex - 1;
    if ModuleIndex < 0 then
    begin
      if Buyer.CanGenerateSpecialHullModule then ModuleIndex := SelectHullOfferSpecialMicroModule(Result, Planet);
      if (Buyer.GetHull.SpecialModuleIndex > 0) and (GetPlayer <> Buyer) and (ModuleIndex < 0) then
        ModuleIndex := Buyer.GetHull.SpecialModuleIndex - 1;
      if ModuleIndex >= 0 then ApplySpecialMicroModule(ModuleIndex, Result);
    end;
  end;
end;
{ @end $6A0464 }

{ @routine $6A04F8 TRuins_GenerateHullOffer }
function TRuins.GenerateHullOffer(Ship: TObject; Planet: TPlanet): THull;
var Buyer: TShip; Count, MinLevel, MaxLevel, MinSize, MaxSize, Size: Integer;
  HullType: THullType; Owner: TOwnerId; Series, ModuleIndex: Integer; Flagship: Boolean;
begin
  Result := nil;
  if TypeId = station_custom then
  begin
    Result := GeneratePlanetHullOffer(Ship, Planet);
    Exit;
  end;
  if not ((Ship <> nil) and (Ship is TShip)) then Exit;
  Buyer := TShip(Ship);
  Count := 0;
  for HullType := hull_ranger to hull_flagship do if HullType in StationOfferHullTypes[TypeId] then Inc(Count);
  if Count = 0 then Exit;
  Count := NextRandomIntRange(1, Count, RandomState);
  for HullType := hull_ranger to hull_flagship do
  begin
    if HullType in StationOfferHullTypes[TypeId] then Dec(Count);
    if Count = 0 then Break;
  end;
  Flagship := (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = warrior_flagship);
  if Flagship then HullType := hull_flagship;
  if not ((GetPlayer = Buyer) or (Buyer.GetHull.HullType = hull_special) or (Buyer.GetHull.HullType = HullType)) then Exit;
  MaxLevel := Planet.InventionLevels[EquipmentInventionIndices[item_hull]];
  MinLevel := Max(1, MaxLevel div 2 - 1);
  MaxLevel := Min(8, MaxLevel + StationOfferHullLevelBonus[TypeId]);
  case Galaxy.GetHullGrowthMod of
    1:
      begin
        Size := Buyer.GetHull.EstimateCapacityWithoutBonuses;
        if Flagship then Size := Size div 2;
        MinSize := Size div 2;
        if HullType in [hull_transport, hull_liner] then MaxSize := Size + (40 + 10 * Ord(TypeId = station_business_center)) * Galaxy.TechLevel
        else case HullType of
          hull_diplomat: MaxSize := Size + 10 * Galaxy.TechLevel;
        else MaxSize := Size + 25 * Galaxy.TechLevel;
        end;
        MinSize := Max(MinSize, Round(HullBaseSize * EquipmentSizeFactors[5 - Ord(TypeId = station_business_center)]));
        MaxSize := Galaxy.ScaleIntByTechLevel(Round(HullBaseSize * EquipmentSizeFactors[4]), MaxSize);
      end;
    2:
      begin
        Size := Buyer.GetHull.Weight;
        if Flagship then Size := Size div 2;
        MinSize := Round(HullBaseSize * EquipmentSizeFactors[5 - Ord(TypeId = station_business_center)]);
        MaxSize := Min(Size, Round(HullBaseSize * EquipmentSizeFactors[Galaxy.ScaleIntByTechLevel(5, 1)]));
      end;
  else
    begin
      Size := Buyer.GetHull.Weight;
      if Flagship then Size := Size div 2;
      MinSize := Size div 2;
      if HullType in [hull_transport, hull_liner] then MaxSize := Size + 300 + 100 * Ord(TypeId = station_business_center)
      else case HullType of
        hull_diplomat: MaxSize := Size + 50;
      else MaxSize := Size + 200;
      end;
      MinSize := Max(MinSize, Round(HullBaseSize * EquipmentSizeFactors[5 - Ord(TypeId = station_business_center)]));
      MaxSize := Min(MaxSize, Round(HullBaseSize * EquipmentSizeFactors[Galaxy.ScaleIntByTechLevel(3, 1)]));
    end;
  end;
  Owner := PickRandomEquipmentOwner(RandomState);
  if not ((Buyer.GetHull.OwnerId = Owner) or (GetPlayer = Buyer)) then Exit;
  Result := THull.Create;
  Series := -1;
  ModuleIndex := -1;
  Result.OwnerId := Owner;
  Result.PirateBuilt := (CurrentStar.ControlFaction = faction_pirates) and (CurrentStar.Status.CustomFaction = '');
  if Buyer.CanGenerateSpecialHullModule then ModuleIndex := SelectHullOfferSpecialMicroModule(Result, Planet);
  if ModuleIndex < 0 then
  begin
    if Buyer.CanGenerateSpecialHullModule then ModuleIndex := SelectHullOfferSpecialMicroModule(Result, Planet);
    if HullType in StationOfferRareHullTypes[TypeId] then Series := Galaxy.SelectHullSeries(Owner, HullType, 1, 100)
    else Series := Galaxy.SelectHullSeries(Owner, HullType, 1, 30);
  end;
  if Flagship then Result.Init(NextRandomIntRange(MinSize * 2, MaxSize * 2, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner, hull_flagship, Series, Result.PirateBuilt)
  else Result.Init(NextRandomIntRange(MinSize, MaxSize, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner, HullType, Series, Result.PirateBuilt);
  if (Buyer.GetHull.SpecialModuleIndex > 0) and (GetPlayer <> Buyer) and (ModuleIndex < 0) then
    ModuleIndex := Buyer.GetHull.SpecialModuleIndex - 1;
  if ModuleIndex >= 0 then ApplySpecialMicroModule(ModuleIndex, Result);
end;
{ @end $6A04F8 }

{ @routine $6A0BA8 TRuins_GenerateWeaponOffer }
function TRuins.GenerateWeaponOffer(Ship: TObject; Planet: TPlanet): TWeapon;
var Buyer: TShip; Attempts, MinLevel, MaxLevel, MinSize, MaxSize: Integer;
  Availability: TWeaponAvailabilityMask; Info: PWeaponInfo; Owner, CandidateOwner: TOwnerId; ModuleIndex: Integer;
begin
  Result := nil;
  if (Ship <> nil) and (Ship is TShip) then
  begin
    Buyer := TShip(Ship);
    Availability := [availability_unrestricted];
    if (Buyer.TypeId = ship_dominator) and (OwnerId in PlanetOwnerMasks.Dominators) then Availability := Availability + [availability_not_sold_node_repair];
    if (Buyer.TypeId in [ship_ranger, ship_pirate]) and (CurrentStanding in FactionStandingMasks[faction_pirates]) and
       ((CurrentStar.ControlFaction = faction_pirates) or not (CurrentStanding in FactionStandingMasks[faction_coalition])) then
      Availability := Availability + [availability_pirate_only];
    if (Buyer.TypeId in [ship_ranger..ship_warrior]) and (CurrentStanding in FactionStandingMasks[faction_coalition]) and
       ((CurrentStar.ControlFaction = faction_coalition) or not (CurrentStanding in FactionStandingMasks[faction_pirates])) then
      Availability := Availability + [availability_coalition_only, availability_maloc_only..availability_gaal_only];
    // This is a single selection pass: Continue reaches the always-true condition.
    Attempts := 0;
    repeat
      if Attempts > 100 then Exit;
      Inc(Attempts);
      Info := Galaxy.SelectWeaponInfo(RandomState, Availability, Planet.InventionLevels[research_main_technology], 1);
      AdvanceRandomSeed(RandomState);
      if not (Buyer.TypeId in [ship_ranger, ship_pirate]) and (Info.ShotType in [shot_torpedo..shot_rocket]) and
        (Buyer.CountDirectFireWeapons > Buyer.CountMissileWeapons) then Continue;
    until True;
    MinSize := Round(Info.AverageSize * EquipmentSizeFactors[5]);
    MaxSize := Round(Info.AverageSize * EquipmentSizeFactors[1]);
    if (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = warrior_flagship) then
    begin
      MinSize := MinSize * 2;
      MaxSize := MaxSize * 2;
    end;
    MinLevel := 1;
    MaxLevel := Min(Planet.InventionLevels[research_main_technology], Planet.InventionLevels[Info.InventionIndex]);
    MinLevel := Max(MinLevel, MaxLevel div 2 - 1);
    MaxLevel := Min(8, MaxLevel + StationOfferWeaponLevelBonus[TypeId]);
    Owner := PickRandomEquipmentOwner(RandomState);
    if (CurrentStar.ControlFaction = faction_pirates) and (CurrentStanding in FactionStandingMasks[faction_pirates]) and
       ((NextRandomIntRange(1, 100, RandomState) < 70) or (Galaxy.CoalitionDefeatedTurn <> 0)) then Owner := owner_pirate;
    for CandidateOwner := owner_maloc to owner_pirate do if OwnerWeaponAvailability[CandidateOwner] = Info.Availability then
    begin
      Owner := CandidateOwner;
      Break;
    end;
    Result := CreateGeneratedWeapon(Info, NextRandomIntRange(MinSize, MaxSize, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner);
    if (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = warrior_flagship) then
    begin
      Result.DetailImprovement := 3;
      Result.Improve(upgrade_random);
    end
    else if Buyer.CanGenerateMicroModuleForLoadout then
    begin
      ModuleIndex := SelectWeaponOfferSpecialMicroModule(Result, Planet);
      if ModuleIndex >= 0 then ApplySpecialMicroModule(ModuleIndex, Result);
    end;
  end;
end;
{ @end $6A0BA8 }

{ @routine $6A0F18 TRuins_GenerateEquipmentOffer }
function TRuins.GenerateEquipmentOffer(Ship: TObject; Planet: TPlanet; ItemType: TItemType): TEquipment;
var Buyer: TShip; Attempts, Priority, ModuleIndex, MinLevel, MaxLevel, MinSize, MaxSize, SpecialModule: Integer; Owner: TOwnerId;
begin
  Result := nil;
  if (Ship = nil) or not (Ship is TShip) then Exit;
  Buyer := TShip(Ship);
  if ItemType in UtilityEquipmentTypes then
  begin
    if not (ItemType in [item_fuel_tanks,item_engine]) and (Buyer.GetSlotCountForItemType(ItemType) = 0) and (GetPlayer <> Buyer) then Exit;
    MinLevel := 1;
    MaxLevel := Planet.InventionLevels[EquipmentInventionIndices[ItemType]];
    MinLevel := Max(MinLevel, MaxLevel div 2 - 1);
    MaxLevel := Min(8, MaxLevel + StationOfferEquipmentLevelBonus[TypeId, ItemType]);
    MinSize := Round(GetAverageItemSize(ItemType) * EquipmentSizeFactors[5]);
    MaxSize := Round(GetAverageItemSize(ItemType) * EquipmentSizeFactors[1]);
    if (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = warrior_flagship) then
    begin
      MinSize := MinSize * 2;
      MaxSize := MaxSize * 2;
    end;
    Owner := PickRandomEquipmentOwner(RandomState);
    if (CurrentStar.ControlFaction = faction_pirates) and (CurrentStanding in FactionStandingMasks[faction_pirates]) and
       ((NextRandomIntRange(1, 100, RandomState) < 70) or (Galaxy.CoalitionDefeatedTurn <> 0)) then Owner := owner_pirate;
    Result := CreateGeneratedEquipment(ItemType, NextRandomIntRange(MinSize, MaxSize, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner);
    if Buyer.CanGenerateMicroModuleForLoadout then
    begin
      SpecialModule := SelectEquipmentOfferSpecialMicroModule(Result, Planet);
      if SpecialModule >= 0 then ApplySpecialMicroModule(SpecialModule, Result);
    end;
  end
  else if ItemType in WeaponItemTypes then Result := GenerateWeaponOffer(Ship, Planet)
  else if ItemType = item_hull then Result := GenerateHullOffer(Ship, Planet);
  if Result = nil then Exit;
  case TypeId of
    station_business_center:
      begin
        Result.Cost := Min(Int64(MaxMonetaryValue), Round(Result.Cost * 1.2));
        Result.ConditionPercent := NextRandomIntRange(70, 100, RandomState);
      end;
    station_medical_base: Result.ConditionPercent := NextRandomIntRange(1, 100, RandomState);
    station_pirate_base: Result.ConditionPercent := NextRandomIntRange(0, 60, RandomState);
    station_military_base: Result.ConditionPercent := NextRandomIntRange(60, 100, RandomState);
    station_dominion: Result.ConditionPercent := NextRandomIntRange(0, 60, RandomState);
  end;
  if Result.CanImprove then
    if TypeId = station_science_base then
      case NextRandomIntRange(0, 100, RandomState) of
        0..70: Result.Improve(upgrade_minor);
        71..90: Result.Improve(upgrade_medium);
        91..100: Result.Improve(upgrade_major);
      end
    else if TypeId = station_ranger_center then
      case NextRandomIntRange(0, 100, RandomState) of
        0..10: Result.Improve(upgrade_minor);
        11..20: Result.Improve(upgrade_medium);
        21..22: Result.Improve(upgrade_major);
      end
    else
      case NextRandomIntRange(0, 100, RandomState) of
        0..10: Result.Improve(upgrade_minor);
        11..20: Result.Improve(upgrade_medium);
        21..23: Result.Improve(upgrade_major);
      end;
  Attempts := 0;
  if (TypeId = station_dominion) and (NextRandomIntRange(0, 100, RandomState) > 50) then
    repeat
      Priority := Round(RemapClamped(Galaxy.TechLevel, 3, 7, 70, 0));
      ModuleIndex := Galaxy.SelectMicroModule(Priority + Attempts div 5, Min(100, Priority + 20 + Attempts * 4), AdvanceRandomSeed(RandomState), Self);
      if CanInstallMicroModule(ModuleIndex, Result) then
      begin
        ApplyMicroModule(ModuleIndex, Result);
        Break;
      end;
      Inc(Attempts);
    until Attempts > 50;
end;
{ @end $6A0F18 }

{ @routine $6A143C TRuins_GenerateEquipmentOfferBatch }
function TRuins.GenerateEquipmentOfferBatch(Ship: TShip; UnusedForceGeneratedOffers: Boolean): TObjectList;
var
  Item: TEquipment;
  I, J: Integer;
  Kind: TItemType;
  Planet: TPlanet;
begin
  Result := TObjectList.Create;
  for J := 1 to StationEquipmentOfferQuotas[TypeId].Hulls do
  begin
    Planet := TPlanet(CurrentStar.SelectRandomInhabitedPlanet);
    Item := GenerateEquipmentOffer(Ship, Planet, item_hull);
    if Item <> nil then Result.Add(Item);
  end;
  for I := 1 to CountItemTypesInMask(UtilityEquipmentTypes) do
  begin
    Kind := GetItemTypeFromMask(UtilityEquipmentTypes, I);
    for J := 1 to StationEquipmentOfferQuotas[TypeId].ByItemCategory[Kind] do
    begin
      Planet := TPlanet(CurrentStar.SelectRandomInhabitedPlanet);
      Item := GenerateEquipmentOffer(Ship, Planet, Kind);
      if Item <> nil then Result.Add(Item);
    end;
  end;
  for I := 1 to StationEquipmentOfferQuotas[TypeId].Weapons do
  begin
    Planet := TPlanet(CurrentStar.SelectRandomInhabitedPlanet);
    Item := GenerateEquipmentOffer(Ship, Planet, WeaponCategoryItemType);
    if Item <> nil then Result.Add(Item);
  end;
end;
{ @end $6A143C }

{ @routine $6A1570 TRuins_UpdateGoodsMarketState }
procedure TRuins.UpdateGoodsMarketState;
var Good: Byte; TargetPrice, PriceStep: Single; TargetCount, CountStep: Integer; Race: TOwnerId;
begin
  if ShopUpdateMode in [shop_update_disabled, shop_update_equipment] then Exit;
  Race := PilotRace;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    TargetCount := Round(GoodsMarket[Good].BaseStock * PlanetRaceMarket[Race].GoodsFactors[Good].StockFactor * StationGoodsFactors[TypeId, Good].StockFactor);
    TargetPrice := GoodsMarket[Good].AveragePrice * PlanetRaceMarket[Race].GoodsFactors[Good].PriceFactor * StationGoodsFactors[TypeId, Good].PriceFactor /
      RemapClamped(ShopGoods[Good].Count, TargetCount * 0.3, TargetCount * 2, 0.8, 1.2);
    if TargetPrice > GoodsMarket[Good].MinPrice then TargetPrice := Min(TargetPrice, GoodsMarket[Good].MaxPrice + 1)
    else TargetPrice := Max(TargetPrice, GoodsMarket[Good].MinPrice - 1);
    if ShopGoods[Good].PriceState - TargetPrice >= 0 then PriceStep := TargetPrice * NextRandomFloatRange(0.0035, 0.006, RandomState)
    else PriceStep := -TargetPrice * NextRandomFloatRange(0.0035, 0.006, RandomState);
    case NextRandomIntRange(1, 100, RandomState) of
      1..70: ShopGoods[Good].PriceState := ShopGoods[Good].PriceState - PriceStep;
      71..90: ;
    else ShopGoods[Good].PriceState := ShopGoods[Good].PriceState + PriceStep;
    end;
    if ShopGoods[Good].PriceState < GoodsMarket[Good].MinPrice div 2 then ShopGoods[Good].PriceState := GoodsMarket[Good].MinPrice div 2
    else if ShopGoods[Good].PriceState > GoodsMarket[Good].MaxPrice * 2 then ShopGoods[Good].PriceState := GoodsMarket[Good].MaxPrice * 2;
    ShopGoods[Good].PurchasePrice := Max(2, Round(ShopGoods[Good].PriceState));
    ShopGoods[Good].BaseSalePrice := Max(ShopGoods[Good].PurchasePrice div 2 + 1,
      Round(ShopGoods[Good].PriceState * RemapClamped(ShopGoods[Good].Count, TargetCount, TargetCount * 2, 0.9, 0.7) - 1));
    if ShopGoods[Good].Count - TargetCount >= 0 then
      CountStep := Round(TargetCount * NextRandomFloatRange(0.0025, 0.005, RandomState) + NextRandomUnitFloat(RandomState))
    else CountStep := Round(-TargetCount * NextRandomFloatRange(0.0025, 0.005, RandomState) - NextRandomUnitFloat(RandomState));
    case NextRandomIntRange(1, 100, RandomState) of
      1..20: Dec(ShopGoods[Good].Count, CountStep);
      21..95: ;
    else Inc(ShopGoods[Good].Count, CountStep);
    end;
    if ShopGoods[Good].Count < 0 then ShopGoods[Good].Count := 0;
  end;
end;
{ @end $6A1570 }

{ @routine $6A1A30 TRuins_CalculateRepairCost }
function TRuins.CalculateRepairCost(Ship: TShip; out EquipmentCost: Integer): Integer;
var I: Integer; Item: TEquipment; EquipmentFactor, ArtefactFactor: Single;
begin
  Result := 0;
  EquipmentFactor := 1;
  if TypeId = station_military_base then EquipmentFactor := RemapClamped(Ord(GetPlayer.Rank), 0, 7, 0.9, 0.2);
  if TypeId = station_pirate_base then EquipmentFactor := 0.84;
  for I := 0 to Ship.Inventory.Count - 1 do
  begin
    Item := Ship.Inventory[I];
    if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = availability_not_sold_node_repair) and
      not CanRepairArtefactsAtLocation then Continue;
    if not CanRepairEquipmentTech(Item) then Continue;
    if not ((Item.ItemType = item_hull) or ((Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90))) then Continue;
    Inc(Result, Round(Item.CalculateRepairCost * EquipmentFactor));
  end;
  EquipmentCost := Result;
  if not CanRepairArtefactsAtLocation then Exit;
  ArtefactFactor := 1;
  if TypeId = station_science_base then ArtefactFactor := 0.84;
  if TypeId = station_pirate_base then ArtefactFactor := 0.84;
  for I := 0 to Ship.Artefacts.Count - 1 do
  begin
    Item := Ship.Artefacts[I];
    if Item.EquippedFlag = 0 then Continue;
    if not (Item.ConditionPercent < 90) then Continue;
    Inc(Result, Round(Item.CalculateRepairCost * ArtefactFactor));
  end;
end;
{ @end $6A1A30 }

{ @routine $6A1BEC TRuins_GetRepairCost }
function TRuins.GetRepairCost(Ship: TShip): Integer;
var EquipmentCost: Integer;
begin
  Result := CalculateRepairCost(Ship, EquipmentCost);
end;
{ @end $6A1BEC }

{ @routine $6A1BF8 TRuins_RepairShipEquipment }
procedure TRuins.RepairShipEquipment(Ship: TShip);
var I: Integer; Item: TEquipment;
begin
  if GetRepairCost(Ship) > Ship.Money then Exit;
  Ship.SetMoney(Ship.Money - GetRepairCost(Ship));
  for I := 0 to Ship.Inventory.Count - 1 do
  begin
    Item := Ship.Inventory[I];
    if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = availability_not_sold_node_repair) and
      not CanRepairArtefactsAtLocation then Continue;
    if not CanRepairEquipmentTech(Item) then Continue;
    if not ((Item.ItemType = item_hull) or ((Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90))) then Continue;
    Item.Repair;
  end;
  if not CanRepairArtefactsAtLocation then Exit;
  for I := 0 to Ship.Artefacts.Count - 1 do
  begin
    Item := Ship.Artefacts[I];
    if Item.EquippedFlag = 0 then Continue;
    if not (Item.ConditionPercent < 90) then Continue;
    Item.Repair;
  end;
end;
{ @end $6A1BF8 }

{ @routine $6A1D08 TRuins_GetNodeSaleBatchSize }
function TRuins.GetNodeSaleBatchSize: Integer;
begin
  Result := Min(NodeReserve, 250);
end;
{ @end $6A1D08 }

{ @routine $6A1D20 TRuins_FindPirateBaseWithNodes }
function TRuins.FindPirateBaseWithNodes: TRuins;
var I, J, Index: Integer; Star: TStar; Ship: TShip;
begin
  Index := Galaxy.Stars.IndexOf(CurrentStar);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    IncrementWrapped(Index, 0, Galaxy.Stars.Count - 1);
    Star := Galaxy.Stars[Index];
    if Star.Battle <> 0 then Continue;
    if Star.ControlFaction = faction_dominators then Continue;
    if Star.Status.CustomFaction <> '' then Continue;
    if Star.ShipTypeCounts[station_pirate_base] = 0 then Continue;
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.TypeId <> station_pirate_base then Continue;
      if Ship.TypeNameOverrideKey <> '' then Continue;
      if Ship.NodeReserve <= 0 then Continue;
      Result := Ship as TRuins;
      Exit;
    end;
  end;
  Result := nil;
end;
{ @end $6A1D20 }

{ @routine $6A1E00 TRuins_SelectServiceMicroModule }
function TRuins.SelectServiceMicroModule(Kind, Index: Integer; InvertRarity: Boolean): Integer;
var
  ChainIndex: Integer;
  Rare: Boolean;
begin
  ChainIndex := Index + 2;
  Rare := ((Cardinal(Galaxy.CurrentTurn) + GetPlayer.RandomState) mod 33 = 0) <> InvertRarity;
  case Kind of
    2:
      if Rare then Result := Galaxy.SelectMicroModule(0, 20, Galaxy.CurrentTurn div 57 + 2938629 + 17 * ChainIndex + Id, Self)
      else Result := Galaxy.SelectMicroModule(10, 30, Galaxy.CurrentTurn div 57 + 32465621 + 17 * ChainIndex + Id, Self);
    1: Result := Galaxy.SelectMicroModule(31, 69, Galaxy.CurrentTurn div 57 + 2351417 + 17 * ChainIndex + Id, Self);
  else Result := Galaxy.SelectMicroModule(70, 100, Galaxy.CurrentTurn div 57 + 17 * ChainIndex + Id, Self);
  end;
end;
{ @end $6A1E00 }

{ @routine $6A1F2C TRuins_CanDock }
function TRuins.CanDock(Ship: TShip): Boolean;
begin
  Result := False;
  if InNormalSpace and (Ship.EnemyShip <> Self) and (GetRelationLevelToShip(Ship) > relation_level_hostile) and not NoLanding and
     (not (CurrentStanding in [standing_pirate_active..standing_pirate_military]) or (Ship.CurrentStanding in [standing_pirate_passive..standing_pirate_military])) then Result := True;
end;
{ @end $6A1F2C }

{ @routine $6A1F80 TRuins_CheckDockingPermission }
function TRuins.CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  if NoLanding or not InNormalSpace then begin
    Response := LookupLocalizedTextByKey('Help.LandingCancelScript');
    Exit;
  end;
  if (CurrentStanding in [standing_pirate_active..standing_pirate_military]) and not (Ship.CurrentStanding in [standing_pirate_passive..standing_pirate_military]) then begin
    Response := LookupLocalizedTextByKey('Help.LandingCancelPirate');
    Exit;
  end;
  if (Ship.EnemyShip = Self) or (GetRelationLevelToShip(Ship) <= relation_level_hostile) then begin
    Response := LookupLocalizedTextByKey('Help.LandingCancelWar');
    Exit;
  end;
  Response := '';
  Result := True;
end;
{ @end $6A1F80 }

end.
