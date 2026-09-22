unit aPlanet;
// Unit bracket (inferred): .text 0x0077F760..0x00796C48; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, EC_Str, EC_Struct, SE_Planet, SE_Sputnik, Types, aEFilm, aGalaxy, aGalaxyStruct, aItem, aMyFunction;

type
  TPlanetTerrainKind = (ptWater = 0, ptLand = 1, ptHill = 2); // @size 0x01

  TPlanetSurfaceLootEntry = packed record // @size 0x0C
    GridX: Byte; // @offset 0x00  Display grid column, 0..13.
    GridY: Byte; // @offset 0x01  Display grid row, 0..6.
    TerrainKind: TPlanetTerrainKind; // @offset 0x02
    Unavailable: Boolean; // @offset 0x03  Suppresses display/collection even after its terrain is explored (0x7E8E74, 0x7EAC98); not a discovered flag.
    SurfaceTileIndex: Integer; // @offset 0x04  One-based ordinal within this terrain's exploration tiles.
    Item: TItem; // @offset 0x08  Owned until transferred to the player.
  end;
  PPlanetSurfaceLootEntry = ^TPlanetSurfaceLootEntry;

  TDominatorSpawnWeightRow = array[0..7] of Integer;
  TDominatorSpawnWeightTable = array[1..5] of TDominatorSpawnWeightRow;

  // VMT 0x77F7AC; the satellite wrapper owns a retained space-object reference.
  TSputnik = class(TObjectEx) // @size 0x10
  public
    Id: Cardinal; // @offset 0x04
    Graphic: TSputnikSE; // @offset 0x08
    FilmObject: TEFilmObj; // @offset 0x0C  Borrowed from PrimaryFilm.

    constructor Create; // @addr 0x77F830
    destructor Destroy; override; // @addr 0x77F898
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x77F8E0
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x77F944
  end;

  // VMT 0x77F804 confirms size. SaveToBuffer/LoadFromBuffer establish the
  // stored field widths; orbit doubles are serialized through Single precision.
  // The unaccessed +1C/+3C gaps align the following Double fields.
  TPlanet = class(TObjectEx) // @size 0x168
  public
    Id: Cardinal; // @offset 0x04
    GenerationSeed: Cardinal; // @offset 0x08
    RandomState: Cardinal; // @offset 0x0C
    SpriteTemplateIndex: Integer; // @offset 0x10  Generation-only index into the 16-byte planet sprite template table.
    Name: WideString; // @offset 0x14
    CurrentStar: TStar; // @offset 0x18
    Orbit: TPolarPoint; // @offset 0x20  Angle at +20, radius at +28; not a Cartesian position.
    ReservedSaveValue: Integer; // @offset 0x30  Binary-save passthrough. No gameplay use identified in this build; original meaning unknown.
    Reserved34: Cardinal; // @offset 0x34  Cleared by Create; no subsequent use identified in this build.
    Radius: Integer; // @offset 0x38  Script.PlanetSize.
    OrbitalVelocity: Double; // @offset 0x40  Degrees per unscaled movement step.
    InventionLevels: array[TPlanetInvention] of Byte; // @offset 0x48  piMainTech is the main technology level used to gate the other tracks.
    CurrentInvention: TPlanetInvention; // @offset 0x5C
    CurrentInventionPoints: Single; // @offset 0x60
    ResearchLevelPercent: Byte; // @offset 0x64  Selection ceiling, compared with invention level * 12.5.
    ResearchLevelStep: Byte; // @offset 0x65  Increment used when no eligible invention remains.
    Population: Integer; // @offset 0x68
    Economy: TPlanetEconomy; // @offset 0x6C
    Money: Integer; // @offset 0x70  Population-funded treasury used by ship generation and refitting.
    OwnerId: TOwnerId; // @offset 0x74
    IsCoalitionOwned: Boolean; // @offset 0x75  Cached OwnerId membership in the five Coalition races.
    RaceId: TOwnerId; // @offset 0x76
    Government: TPlanetGovernment; // @offset 0x77
    Goods: array[TGoodsIndex] of TGoodsTradePriceEntry; // @offset 0x78
    GoodsScarcityTicks: array[TGoodsIndex] of Byte; // @offset 0xF8
    GoodsSurplusTicks: array[TGoodsIndex] of Byte; // @offset 0x100
    TextQuestId: Integer; // @offset 0x108 // -1 when no text quest is assigned.
    RangerRelations: TList; // @offset 0x10C  Integer scores stored in pointer slots, indexed by Galaxy.Rangers.
    EquipmentShop: TObjectList; // @offset 0x110  Owned TItem stock.
    Warriors: TObjectList; // @offset 0x114  Garrison roster; Destroy clears it before freeing the list to avoid freeing ships owned elsewhere.
    HomeRangerCount: Integer; // @offset 0x118
    HomeTransportCount: Integer; // @offset 0x11C  TTransport instances based here, including liners and diplomats.
    WaterTiles: Integer; // @offset 0x120
    WaterExplored: Integer; // @offset 0x124
    LandTiles: Integer; // @offset 0x128
    LandExplored: Integer; // @offset 0x12C
    HillTiles: Integer; // @offset 0x130
    HillExplored: Integer; // @offset 0x134
    ProbeOrbitCount: Byte; // @offset 0x138  Available probe trajectories on the exploration screen; serialized as OrbitCnt.
    HasPlayerLanded: Boolean; // @offset 0x139  First player landing sets this; counts for EXPLORER only if OwnerId=6 then. Saved since version 99.
    SurfaceLootEntries: TList; // @offset 0x13C  Owns allocated PPlanetSurfaceLootEntry records and their items; may be nil.
    GraphicRadius: Integer; // @offset 0x140  Generated from the sprite template; saved as a Word.
    Graphic: TPlanetSE; // @offset 0x144  Retained reference, released by Destroy.
    GraphName: WideString; // @offset 0x148
    Satellites: TObjectList; // @offset 0x14C  Owned TSputnik entries.
    LastFilmPosition: TPoint; // @offset 0x150
    FilmObject: TEFilmObj; // @offset 0x158  Borrowed from PrimaryFilm.
    NoLanding: Boolean; // @offset 0x15C
    ShopUpdateMode: Byte; // @offset 0x15D  TShopUpdateMode value (Script.NoShopUpdate); LoadFromBuffer temporarily stores the packed flag byte here before masking to bits 0..1.
    NoAutomaticShipSpawning: Boolean; // @offset 0x15E  Script.PlanetExtraFlags bit 0.
    NoRandomEvents: Boolean; // @offset 0x15F  Script.PlanetExtraFlags bit 1.
    IsMainPiratePlanet: Boolean; // @offset 0x160  Identifies the clan home planet independently of OwnerId.
    CustomFaction: WideString; // @offset 0x164  Overrides the star faction in GetFactionResourceName.

    constructor Create; // @addr 0x77FA30
    destructor Destroy; override; // @addr 0x77FB28
    procedure InitGenerated(Star: TStar; TotalPlanetCount, InhabitedCountOrSpecialMode: Integer); // @addr 0x77FCA8 @note "Fourth argument: 0 selects the Solar System, 1..3 limit inhabited planets, 10/11 select special systems. Caller inserts Self into the star's planet list."
    procedure InitDominatorSpawnProxy(Star: TStar); // @addr 0x783378 @note "Only sets CurrentStar, OwnerId=5 and all invention levels to 8; used by the separate Dominator spawn planet."
    procedure InitGeneratedUninhabited(Star: TStar); // @addr 0x7833B4 @note "Creates graphics, surface terrain, loot and initial market/research state; caller owns planet registration."
    procedure SaveToBuffer(Buffer: TBufEC); // @addr 0x785188
    procedure LoadFromBlock(Block: TBlockParEC); // @addr 0x78785C @note "Loads editable text fields, updates existing items/ships and processes creation requests. The first matching item name ends the search even when its type is disallowed or creation returns nil."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); // @addr 0x789148 @note "Forwards Galaxy from TStar.ResolveLoadedReferences to shop, garrison and surface item resolvers; removes incompatible main-pirate-planet modules from saves older than 106."
    function TrySpawnDominator: Pointer; // @addr 0x7892F0 @note "Daily strength, control and delay gates; returns nil when no ship is spawned."
    procedure NextDay; // @addr 0x789844
    procedure TryDispatchPirateAttacks; // @addr 0x78B9B4 @note "Uses Self's random state for galaxy-wide attacks; disabled by pirate ending 3."
    procedure TrySpawnPirateBaseRaid; // @addr 0x78BF90 @note "Targets a pirate base in a Coalition system; disabled by pirate endings 3 and 5."
    function BuyRanger(MoneyPercent: Integer): Pointer; // @addr 0x790A58
    function SpawnTransport(Kind: Byte; MoneyPercent: Integer): Pointer; // @addr 0x790B90 @note "Kind 0 randomizes the subtype, 3 selects transport, 4 liner, and all others diplomat. Result is owned by CurrentStar.Ships."
    function BuyWarrior(MoneyPercent: Integer): Pointer; // @addr 0x790DB4 @note "Creates a TPirate for Pirate Clan ownership, otherwise a TWarrior."
    function BuyPirate(MoneyPercent: Integer): Pointer; // @addr 0x790C90
    function SpawnTranclucator(BasicEquipment: Boolean): Pointer; // @addr 0x790D50 @note "Creates an unowned Tranclucator docked here and inserts it into CurrentStar.Ships."
    function BuyFlagship(MoneyPercent: Integer): Pointer; // @addr 0x791124 @note "Generates a warrior with WarriorType=1 and scales its budget by Coalition control."
    function SpawnWeightedDominatorShip: Pointer; // @addr 0x7912D0 @note "Excludes boss type; suppresses Bertors when the constellation already has one of this series or Self is the spawn proxy."
    function SpawnDominatorShip(Kind: TKlingType): Pointer; // @addr 0x79146C
    function GenerateShipForScriptGroup(Group: Pointer): Pointer; // @addr 0x79150C @note "Uses group owner/type/equipment constraints; returns nil for a boss request. Temporarily changes planet ownership, star series and global technology."
    procedure InitializeFilmState(StepIndex: Integer; RecordFilm: Boolean); // @addr 0x78C518 @note "Always initializes LastFilmPosition; optionally creates film entries for the planet and satellites."
    procedure AdvanceOrbitStep(StepIndex: Integer; RecordFilm: Boolean); // @addr 0x78C8E0
    function PredictPosition(StepsAhead: Integer): TPointF; // @addr 0x78C9F0
    function RequestDialog: Boolean; // @addr 0x78CA40 @note "Queues planet dialogue to the UI thread and waits for its event; requires normal-space player state."
    procedure UpdateOwnerFlags; // @addr 0x78CAD4
    procedure UpdateMarketState; // @addr 0x78CB00
    procedure TriggerGovernmentRevolution; // @addr 0x78D268
    procedure TryTriggerEconomicEvent; // @addr 0x78D6C0 @note "May trigger a revolution, goods scarcity or surplus and publish planet news; honors NoRandomEvents."
    procedure HandleAsteroidImpact(Asteroid: Pointer); // @addr 0x78EB64 @note "Native no-op. TStar.NextDay calls this after detecting a collision; the caller handles impact effects, debris and asteroid respawn."
    procedure CollectScriptDialogChoices(Choices: TStringsEC); // @addr 0x78EB74 @note "Clears Choices, appends matching nonempty planet-binding titles and stores the owning TScript as each entry's data."
    function GetSurfaceAnimationMask: Integer; // @addr 0x78EC8C @note "Returns -1 when unavailable; otherwise combines a surface family in bits 24..31 with eligible animation bits."
    function GetGovernmentPortraitGraph: WideString; // @addr 0x78EF64 @note "Seed-based StyleFace selection, excluding the player's portrait."
    function GetFullName(Separator: WideString): WideString; // @addr 0x78F164 @note "Main Pirate Planet returns its name without the localized planet prefix."
    function GetPosition: TPointF; // @addr 0x78F218
    function GetInfoText(ForMap: Boolean): WideString; // @addr 0x78F238 @note "ForMap suppresses the artifact treasure hint and can append a Pirate Clan warning."
    function GetGovernmentName: WideString; // @addr 0x78FA9C
    function GetNativeRaceName: WideString; // @addr 0x78FACC @note "Localized DisplayName for RaceToOwner(RaceId)."
    function GetFactionResourceName: WideString; // @addr 0x78FB00 @note "Faction/series/internal owner identifier used for resource selection."
    function CalculateBasePopulation: Integer; // @addr 0x78FC30 @note "Maps Radius 60..100 to population 100000..1000000 with clamping and rounding."
    function CountPlanetsOfSameRace: Integer; // @addr 0x78FC78 @note "For OwnerId=6 counts all uninhabited planets; otherwise counts non-uninhabited planets with the same RaceId. Includes Self."
    function FindUnchartedNeighborConstellation: TConstellation; // @addr 0x78FD04 @note "First adjacent invisible constellation, excluding ID 20; borrowed result or nil."
    function FindNearestPlanetByOwnerMask(OwnerMask: TOwnerMask): TPlanet; // @addr 0x78FD8C @note "Searches stars in CurrentStar's distance order, then each star's planet list; no planet-distance tie break."
    procedure NormalizeSurfaceLootEntries; // @addr 0x78FE3C @note "Sorts by SurfaceTileIndex and moves overlapping markers to free cells of the 14-by-7 display grid."
    function GetTotalSurfaceTileCount: Integer; // @addr 0x79021C
    function GetUnexploredSurfaceTileCount: Integer; // @addr 0x79024C @note "Returns zero unless OwnerId=6."
    function AddSurfaceLootEntry(Item: TItem): Boolean; // @addr 0x790294 @note "Takes item ownership, allocates a 12-byte entry and always returns true on completion. Requires positive surface area; resets exploration if fully explored."
    function TryResetSurfaceLootAfterLongAbsence: Boolean; // @addr 0x7904B0 @note "Requires OwnerId=6, at least 720 days without a player visit and no deployed player probe here. Clears unavailable loot flags and resets exploration if any flag changed."
    procedure BoostInventionLevels(Count: Integer); // @addr 0x7905D4 @note "Increments the current track, clears its progress and selects the next track after every increment."
    procedure SelectCurrentInvention; // @addr 0x79061C @note "Chooses among tracks permitted by ResearchLevelPercent and the piMainTech track; raises if no choice is found."
    procedure AdvanceInventionProgress; // @addr 0x790788 @note "Uses the difficulty multiplier; completion requires progress strictly above 100. Levels cap at 8 and excess progress is discarded."
    function CalculateInventionProgressRate: Single; // @addr 0x7909E8 @note "Radius factor times economy and race multipliers; excludes the difficulty multiplier."
    function BuildGovernmentGreeting: WideString; // @addr 0x7953E8
    procedure ForceGoodsScarcity(StartEvent: Boolean; GoodsMask: TItemTypeMask); // @addr 0x794840 @ida "void __usercall $name(TPlanet *Self@<eax>, bool StartEvent@<dl>, TItemTypeMask *GoodsMask@<ecx>);"
    procedure ForceGoodsSurplus(StartEvent: Boolean; GoodsMask: TItemTypeMask); // @addr 0x794A0C @ida "void __usercall $name(TPlanet *Self@<eax>, bool StartEvent@<dl>, TItemTypeMask *GoodsMask@<ecx>);"
    function GenerateHullOffer(Ship: Pointer): THull; // @addr 0x793758
    function GenerateWeaponOffer(Ship: Pointer): TWeapon; // @addr 0x793DC4 @note "New item or nil; does not add it to EquipmentShop."
    function GenerateEquipmentOffer(Ship: Pointer; ItemType: TItemType): TEquipment; // @addr 0x794124
    function SelectEquipmentOfferSpecialMicroModule(Item: TEquipment): Integer; // @addr 0x792E20 @note "Returns a zero-based module index or -1; advances planet RNG."
    function SelectHullOfferSpecialMicroModule(Hull: THull): Integer; // @addr 0x793084 @note "Returns a zero-based module index or -1; advances planet RNG."
    function SelectWeaponOfferSpecialMicroModule(Weapon: TWeapon): Integer; // @addr 0x7932E8 @note "Returns a zero-based module index or -1; advances planet RNG."
    procedure RefreshEquipmentShopInventory; // @addr 0x79354C @note "Weekly replacement/generation gate; disabled by sumDisabled and sumGoodsOnly."
    function BuildEquipmentOfferBatch(Ship: Pointer; UnusedForceGeneratedOffers: Boolean): TObjectList; // @addr 0x794488 @note "Returns a new owning list of generated equipment, using the race quota table. Caller forwards ForceGeneratedOffers in CL; this routine saves but never reads it."
    function CalculateEquipmentShopTargetCount: Integer; // @addr 0x7945DC @note "Population, economy and deterministic turn jitter adjust race quotas; clamps to 10..20."
    function CountEquipmentShopItemsInBucket(ItemType: TItemType): Integer; // @addr 0x7946D4 @note "Bucket 50 includes all weapon types 50..68; other buckets require an exact type."
    function RemoveSimilarEquipmentShopItem(Item: TEquipment): Boolean; // @addr 0x79474C @note "Frees at most one other stock item of the same type and level, protecting named script items. Does not insert Item."
    function CountBailablePrisoners: Integer; // @addr 0x794C18 @note "Counts local imprisoned rangers/pirates with a positive remaining prison term and no incompatible script state."
    function GetGovernmentBackgroundGraph: WideString; // @addr 0x794CB4
    function BuildNonCivilTreasureHintText: WideString; // @addr 0x794D98
    procedure SaveToBlock(Block: TBlockParEC); // @addr 0x7861A4
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); // @addr 0x7857C0
    function RelationToRanger(RangerIndex: Integer): Integer; // @addr 0x791EC0
    function RelationToShip(Ship: Pointer): TPercent; // @addr 0x7924F0
    function GetRelationLevelToShip(Ship: Pointer): TRelationLevel; // @addr 0x792980
    function GetRelationLevelTextToShip(Ship: Pointer): WideString; // @addr 0x792A18 @ida "void __usercall $name(TPlanet *Self@<eax>, TShip *Ship@<edx>, unsigned __int16 **Result@<ecx>);"
    procedure SetRelationLevelToRanger(Ranger: Pointer; Level: TRelationLevel); // @addr 0x7921FC
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); // @addr 0x792384
    function GetCivilInfoText: WideString; // @addr 0x792A50
    function HasHostileShipsInSystem: Boolean; // @addr 0x792DB0 @note "Tests normal-space ships in CurrentStar for RelationToShip < 10."
  end;

// Nested in TPlanet.TryDispatchPirateAttacks. All four helpers receive its EBP
// as a caller-popped static link, including calls between sibling helpers.
// Captures relative to ParentFrame:
//   -04 target star; -08 action; -0C target pirate count; -10 eligible source count;
//   -14 source star; -18 target opposition count; -28 target pirate strength;
//   -38 target opposition strength; -3C planet supplying RNG; -48 source pirate strength;
//   -4C current ship; -50 dispatch limit; -54 ship index; -58 dispatched count.
// All three captured strength values are ten-byte Extended, not Double.
// Action 0 skips; 1 rebalances a Pirate system; 2 reinforces a threatened Pirate
// system; 3 reinforces pirates in a foreign system; 4 starts a new attack.
// Dispatch limit is count div 4 for action 1, otherwise count - count div 4.
// Native loop tests dispatched <= limit, so it can send limit+1 eligible ships.

var
  EconomicEventChance: Integer = 4; // @addr $87C7F8 Compared against an inclusive 0..100 roll for each economic event.

var
  DominatorSpawnWeights: TDominatorSpawnWeightTable = (
    (0, 50, 50, 100, 200, 600, 0, 0),
    (0, 50, 50, 150, 250, 500, 2, 0),
    (0, 50, 100, 200, 250, 400, 10, 0),
    (0, 100, 100, 250, 250, 300, 20, 0),
    (0, 100, 150, 300, 250, 200, 30, 0)); // @addr 0x87C7FC @note "Five 32-byte rows, eight Integer weights in TKlingType order; SpawnWeightedDominatorShip selects row 1..5 from faction control."
  MainPiratePlanet: TPlanet; // @addr 0x88B0E8 @note "Script.PlanetPirateClan; borrowed reference, retained after PirateWin(3)."

implementation

uses Windows, GI_Tail, GR_Main, Globals, GlobalsV, Math, SE_Process, SE_Space, SysUtils, aConst, aKling, aNormalShip, aPirate, aPlayer, aRanger, aRuins, aScript, aShip, aTranclucator, aTransport, aWarrior, fEquipmentShop;

{ @routine $77F830 TSputnik_Create }
constructor TSputnik.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextSputnikId;
    Inc(Galaxy.NextSputnikId);
  end;
end;
{ @end $77F830 }

{ @routine $77F898 TSputnik_Destroy }
destructor TSputnik.Destroy;
begin
  if Graphic <> nil then ReleaseSpaceObject(TObjectSE(Graphic));
  inherited Destroy;
end;
{ @end $77F898 }

{ @routine $77F8E0 TSputnik_SaveToBuffer }
procedure TSputnik.SaveToBuffer(Buffer: TBufEC);
var State: TBufEC;
begin
  Buffer.AddDWord(Id);
  Buffer.AddWideStringZ(Graphic.GraphKey);
  State := Graphic.BuildStateBuffer;
  Buffer.AddBuffer(State);
  State.Free;
  Buffer.AddSingle(Graphic.OrbitAngle);
end;
{ @end $77F8E0 }

{ @routine $77F944 TSputnik_LoadFromBuffer }
procedure TSputnik.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var State: TBufEC;
begin
  Id := Buffer.GetUInt32;
  if Galaxy.NextSputnikId <= Id then Galaxy.NextSputnikId := Id + 1;
  RetainSpaceObject(TObjectSE(Graphic), TSputnikSE.Create(Buffer.ReadWideString, Classes.Point(0, 0)));
  State := TBufEC.Create;
  Buffer.ReadLengthPrefixedBuffer(State);
  Graphic.LoadStateBuffer(State);
  State.Free;
  Graphic.OrbitAngle := Buffer.GetSingle;
end;
{ @end $77F944 }

{ @routine $77FA30 TPlanet_Create }
constructor TPlanet.Create;
begin
  inherited Create;
  if aGalaxy.Galaxy <> nil then
  begin
    Id := aGalaxy.Galaxy.NextPlanetId;
    Inc(aGalaxy.Galaxy.NextPlanetId);
    GenerationSeed := NextRandomIntRange(100000, MaxInt, aGalaxy.Galaxy.RandomState);
  end;
  RandomState := GenerationSeed;
  Warriors := TObjectList.Create;
  RangerRelations := TObjectList.Create;
  EquipmentShop := TObjectList.Create;
  Satellites := TObjectList.Create;
  Graphic := nil;
  Reserved34 := 0;
end;
{ @end $77FA30 }

{ @routine $77FB28 TPlanet_Destroy }
destructor TPlanet.Destroy;
var
  i: Integer;
  Entry: PPlanetSurfaceLootEntry;
begin
  Satellites.Free;
  Warriors.Clear;
  Warriors.Free;
  Warriors := nil;
  if aKling.DominatorSpawnPlanet <> Self then
  begin
    i := aGalaxy.Galaxy.Planets.IndexOf(Self);
    if i >= 0 then aGalaxy.Galaxy.Planets.Delete(i);
  end;
  // Native code deletes entries but leaves the RangerRelations list allocated.
  for i := RangerRelations.Count - 1 downto 0 do RangerRelations.Delete(i);
  if Graphic <> nil then ReleaseSpaceObject(TObjectSE(Graphic));
  EquipmentShop.Free;
  EquipmentShop := nil;
  if SurfaceLootEntries <> nil then
  begin
    for i := 0 to SurfaceLootEntries.Count - 1 do
    begin
      Entry := SurfaceLootEntries[i];
      Entry.Item.Free;
      Entry.Item := nil;
      Dispose(Entry);
    end;
    SurfaceLootEntries.Free;
    SurfaceLootEntries := nil;
  end;
  inherited Destroy;
end;
{ @end $77FB28 }

{ @routine $77FCA8 TPlanet_InitGenerated }
procedure TPlanet.InitGenerated(Star: TStar; TotalPlanetCount, InhabitedCountOrSpecialMode: Integer);
{ Self is added to Star.Planets by the caller. UnusedRadius and UnusedItem
  retain unreferenced native frame slots, as in InitGeneratedUninhabited. }
var
  OtherPlanet, PreviousPlanet: TPlanet;
  Invention: TPlanetInvention;
  Good: Byte;
  Quantity, Count, I, Part, LeastOwnerPlanetCount, ExistingRing, ModuleIndex: Integer;
  SavedRandomState: Cardinal;
  EconomyRoll: Integer;
  PreviousExtent, SatelliteRadius, UnusedRadius, MinOrbitRadius, MaxOrbitRadius: Double;
  GovernmentCandidate: TPlanetGovernment;
  ItemOwner, OwnerLoop: TOwnerId;
  BlockName: WideString;
  Satellite: TSputnik;
  SatelliteCount: Integer;
  SatelliteConfig: TBlockParEC;
  Item: TEquipment;
  ItemType: TItemType;
  Series: Integer;
  GovernmentRoll, RingKind: Byte;
  TemplateAvailable, AllowRing, IsSolar: Boolean;
  HullType: THullType;
  UnusedItem: TItem;
  Loot: TEquipmentWithActCode;
  Module: TMicroModule;
  Cistern: TCistern;
  GoodsItem: TGoods;
  Weight, Level: Integer;
  WeaponInfo: PWeaponInfo;
  MinSizeFactor, MaxSizeFactor: Single;
  MinLevel, MaxLevel, WeaponTechLevel: Integer;
  GeneratedWeapon: TWeapon;
begin
  CurrentStar := Star;
  if InhabitedCountOrSpecialMode = 0 then IsSolar := True
  else IsSolar := False;
  if IsSolar then
  begin
    RaceId := oiHuman;
    Name := LanguageDataConfig.GetBlock('PlanetName').GetBlock('Solar').GetParamValue(Star.Planets.Count);
    OrbitalVelocity := (NextRandomIntRange(1, 1, RandomState) * 2 - 1) * (4.5 - Star.Planets.Count / 2);
    Orbit.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
    SpriteTemplateIndex := FindPlanetSpaceTemplateIndex(1, Star.Planets.Count + 1);
    GraphicRadius := PlanetSpaceTemplates[SpriteTemplateIndex].Radius;
    RetainSpaceObject(TObjectSE(Graphic), TPlanetSE.Create);
    PlanetSpaceTemplates[SpriteTemplateIndex].SpaceObject.CopyTo(Graphic);
    GraphName := Graphic.GraphKey;
    Radius := GraphicRadius;
    Graphic.SetPosition(PolarToPoint(Orbit));
    Graphic.SetRotationTimerInterval(SeededRandomIntRange(60, 100, Star.Planets.Count * 3 + 47));
    Graphic.SetSurfaceMapStep(-1);
    Graphic.OrbitalVelocity := OrbitalVelocity;
    case Star.Planets.Count of
      0:
        begin
          Orbit.Radius := Radius + Star.SystemRadius + 175;
          OwnerId := oiUninhabited;
          Government := pgAnarchy;
          Economy := peAgricultural;
        end;
      1:
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200;
          OwnerId := oiHuman;
          Government := pgDemocracy;
          Economy := peAgricultural;
          Population := CalculateBasePopulation;
        end;
      2:
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200;
          OwnerId := oiHuman;
          Government := pgDemocracy;
          Economy := peIndustrial;
          Population := 1000000;
          Satellite := TSputnik.Create;
          Satellites.Add(Satellite);
          MinOrbitRadius := Round(Radius * 1.3);
          RetainSpaceObject(TObjectSE(Satellite.Graphic), TSputnikSE.Create('Sputnik.Moon', Classes.Point(0, 0)));
          Satellite.Graphic.DepthOrder := 0;
          Satellite.Graphic.OrbitCenter := GetPosition;
          Satellite.Graphic.OrbitRadius := MinOrbitRadius;
          Satellite.Graphic.OrbitAngle := 180;
          Satellite.Graphic.OrbitAngleStep := 1.1;
          Satellite.Graphic.OrbitTimerInterval := 30;
          Satellite.Graphic.OrbitInclination := 70;
          Satellite.Graphic.OrbitRotation := 250;
          Satellite.Graphic.MinDisplayRadius := Round(GeneratedSatelliteBaseRadius * 1.2);
          Satellite.Graphic.MaxDisplayRadius := Round(GeneratedSatelliteBaseRadius * 1.5);
          Satellite.Graphic.RotationTimerInterval := 25;
          Satellite.Graphic.SurfaceMapStep := 1;
        end;
      3:
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200 +
            Round(200 - RemapClamped(Star.Planets.Count, 1, 6, 0, 200));
          OwnerId := oiHuman;
          Government := pgDictatorship;
          Economy := peIndustrial;
          Population := 100000;
          SatelliteCount := 2;
          for I := 0 to SatelliteCount - 1 do
          begin
            Satellite := TSputnik.Create;
            Satellites.Add(Satellite);
            MinOrbitRadius := Round(Radius * 1.3);
            MaxOrbitRadius := Radius * 2;
            RetainSpaceObject(TObjectSE(Satellite.Graphic), TSputnikSE.Create('Sputnik.Mars' + IntToStr(I), Classes.Point(0, 0)));
            Satellite.Graphic.DepthOrder := I;
            Satellite.Graphic.OrbitCenter := GetPosition;
            Satellite.Graphic.OrbitRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
            Satellite.Graphic.OrbitAngle := NextRandomIntRange(0, 360, RandomState);
            Satellite.Graphic.OrbitAngleStep := 1 + NextRandomUnitFloat(RandomState);
            Satellite.Graphic.OrbitTimerInterval := 30;
            Satellite.Graphic.OrbitInclination := NextRandomIntRange(50, 120, RandomState);
            Satellite.Graphic.OrbitRotation := NextRandomIntRange(200, 350, RandomState);
            Satellite.Graphic.MinDisplayRadius := GeneratedSatelliteBaseRadius;
            Satellite.Graphic.MaxDisplayRadius := Round(Satellite.Graphic.MinDisplayRadius * 1.5);
            Satellite.Graphic.RotationTimerInterval := 25;
            Satellite.Graphic.SurfaceMapStep := 1;
          end;
        end;
      4:
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200 +
            Round(200 - RemapClamped(Star.Planets.Count, 1, 6, 0, 200));
          OwnerId := oiUninhabited;
          Government := pgAnarchy;
          Economy := peAgricultural;
          SatelliteCount := 4;
          for I := 0 to SatelliteCount - 1 do
          begin
            Satellite := TSputnik.Create;
            Satellites.Add(Satellite);
            MinOrbitRadius := Round(Radius * 1.3);
            MaxOrbitRadius := Radius * 2;
            RetainSpaceObject(TObjectSE(Satellite.Graphic), TSputnikSE.Create('Sputnik.' +
              GameDataConfig.GetBlockByPath('SE.Sputnik').GetBlockNameByIndex(NextRandomIntRange(0,
                GameDataConfig.GetBlockByPath('SE.Sputnik').GetBlockCount - 1, RandomState)), Classes.Point(0, 0)));
            Satellite.Graphic.DepthOrder := I;
            Satellite.Graphic.OrbitCenter := GetPosition;
            Satellite.Graphic.OrbitRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
            Satellite.Graphic.OrbitAngle := NextRandomIntRange(0, 360, RandomState);
            Satellite.Graphic.OrbitAngleStep := 1 + NextRandomUnitFloat(RandomState);
            Satellite.Graphic.OrbitTimerInterval := NextRandomIntRange(30, 35, RandomState);
            Satellite.Graphic.OrbitInclination := NextRandomIntRange(50, 120, RandomState);
            Satellite.Graphic.OrbitRotation := NextRandomIntRange(200, 350, RandomState);
            Satellite.Graphic.MinDisplayRadius := GeneratedSatelliteBaseRadius;
            Satellite.Graphic.MaxDisplayRadius := Round(RemapClamped(NextRandomUnitFloat(RandomState) / 1,
              0, 1, Satellite.Graphic.MinDisplayRadius * 1.3,
              Min(MaximumSatelliteTemplateRadius, Satellite.Graphic.MinDisplayRadius * 2)));
            Satellite.Graphic.RotationTimerInterval := 25;
            Satellite.Graphic.SurfaceMapStep := 1;
          end;
        end;
      5:
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200 +
            Round(200 - RemapClamped(Star.Planets.Count, 1, 6, 0, 200));
          OwnerId := oiUninhabited;
          Government := pgRepublic;
          Economy := peMixed;
          Population := 120000;
          Graphic.SetRingKind(22);
        end;
      6:
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200 +
            Round(200 - RemapClamped(Star.Planets.Count, 1, 6, 0, 200));
          OwnerId := oiUninhabited;
          Government := pgAnarchy;
          Economy := peAgricultural;
          SatelliteCount := 1;
          for I := 0 to SatelliteCount - 1 do
          begin
            Satellite := TSputnik.Create;
            Satellites.Add(Satellite);
            MinOrbitRadius := Round(Radius * 1.3);
            MaxOrbitRadius := Radius * 2;
            RetainSpaceObject(TObjectSE(Satellite.Graphic), TSputnikSE.Create('Sputnik.' +
              GameDataConfig.GetBlockByPath('SE.Sputnik').GetBlockNameByIndex(NextRandomIntRange(0,
                GameDataConfig.GetBlockByPath('SE.Sputnik').GetBlockCount - 1, RandomState)), Classes.Point(0, 0)));
            Satellite.Graphic.DepthOrder := I;
            Satellite.Graphic.OrbitCenter := GetPosition;
            Satellite.Graphic.OrbitRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
            Satellite.Graphic.OrbitAngle := NextRandomIntRange(0, 360, RandomState);
            Satellite.Graphic.OrbitAngleStep := 1 + NextRandomUnitFloat(RandomState);
            Satellite.Graphic.OrbitTimerInterval := 30;
            Satellite.Graphic.OrbitInclination := NextRandomIntRange(50, 120, RandomState);
            Satellite.Graphic.OrbitRotation := NextRandomIntRange(1, 359, RandomState);
            Satellite.Graphic.MinDisplayRadius := GeneratedSatelliteBaseRadius;
            Satellite.Graphic.MaxDisplayRadius := Round(RemapClamped(NextRandomUnitFloat(RandomState) / 1,
              0, 1, MaximumSatelliteTemplateRadius / 2, MaximumSatelliteTemplateRadius));
            Satellite.Graphic.RotationTimerInterval := 25;
            Satellite.Graphic.SurfaceMapStep := 1;
          end;
        end;
    end;
  end
  else
  begin
    if InhabitedCountOrSpecialMode > 3 then
    begin
      if (Star.Planets.Count = 1) and (InhabitedCountOrSpecialMode = 10) then
      begin
        OwnerId := oiPirate;
        RaceId := oiHuman;
        IsMainPiratePlanet := True;
        MainPiratePlanet := Self;
      end
      else if (InhabitedCountOrSpecialMode = 11) and (Star.Planets.Count < 5) then
      begin
        OwnerId := oiPirate;
        RaceId := TOwnerId(Star.Planets.Count);
      end
      else OwnerId := oiUninhabited;
    end
    else
    begin
      Count := 0;
      for I := 0 to Star.Planets.Count - 1 do
      begin
        PreviousPlanet := TPlanet(Star.Planets[I]);
        if PreviousPlanet.OwnerId <> oiUninhabited then Inc(Count);
      end;
      if InhabitedCountOrSpecialMode = Count then OwnerId := oiUninhabited
      else if (TotalPlanetCount - Star.Planets.Count <= InhabitedCountOrSpecialMode - Count) or
              (NextRandomUnitFloat(RandomState) < 0.7) or
              ((aGalaxy.Galaxy.Stars.IndexOf(Star) < 5) and (Star.Planets.Count = 0)) then
      begin
        case aGalaxy.Galaxy.FindConstellationIndexForStar(CurrentStar) of
          0, 6: begin OwnerId := oiMaloc; RaceId := oiMaloc; end;
          1, 5: begin OwnerId := oiPeleng; RaceId := oiPeleng; end;
          2, 7: begin OwnerId := oiHuman; RaceId := oiHuman; end;
          3, 8: begin OwnerId := oiFeyan; RaceId := oiFeyan; end;
          4, 9: begin OwnerId := oiGaal; RaceId := oiGaal; end;
        else
          case NextRandomIntRange(0, 4, RandomState) of
            0: begin OwnerId := oiMaloc; RaceId := oiMaloc; end;
            1: begin OwnerId := oiPeleng; RaceId := oiPeleng; end;
            2: begin OwnerId := oiHuman; RaceId := oiHuman; end;
            3: begin OwnerId := oiFeyan; RaceId := oiFeyan; end;
            4: begin OwnerId := oiGaal; RaceId := oiGaal; end;
          end;
        end;
        if ((Count > 0) or (aGalaxy.Galaxy.FindConstellationIndexForStar(CurrentStar) > 4)) and
           ((NextRandomUnitFloat(RandomState) < 0.2) or (aGalaxy.Galaxy.FindConstellationIndexForStar(CurrentStar) > 9)) and
           (aGalaxy.Galaxy.Stars.IndexOf(Star) > 4) then
        begin
          ItemOwner := oiMaloc;
          LeastOwnerPlanetCount := 10000;
          for OwnerLoop := oiMaloc to oiGaal do
          begin
            if (CurrentStar.CountDistinctInhabitedPlanetOwners = 2) and
               (CurrentStar.CountPlanetsByOwner(OwnerLoop) = 0) then Continue;
            Count := 0;
            for I := 0 to aGalaxy.Galaxy.Planets.Count - 1 do
            begin
              PreviousPlanet := TPlanet(aGalaxy.Galaxy.Planets[I]);
              if PreviousPlanet.OwnerId = OwnerLoop then Inc(Count);
            end;
            if LeastOwnerPlanetCount > Count then
            begin
              LeastOwnerPlanetCount := Count;
              ItemOwner := OwnerLoop;
            end;
          end;
          OwnerId := ItemOwner;
          RaceId := OwnerToRace(ItemOwner);
        end;
      end
      else OwnerId := oiUninhabited;
    end;
    BlockName := OwnerToSys(OwnerId);
    if OwnerId <> oiPirate then Name := ''
    else
    begin
      if InhabitedCountOrSpecialMode = 10 then Quantity := 0
      else Quantity := Star.Planets.Count + 1;
      Name := LanguageDataConfig.GetBlock('PlanetName').GetBlock(BlockName).GetParamValue(Quantity);
    end;
    if (InhabitedCountOrSpecialMode = 10) and (OwnerId = oiPirate) then
    begin
      OrbitalVelocity := (NextRandomIntRange(0, 1, RandomState) * 2 - 1) * (4.5 - Star.Planets.Count / 2);
      Orbit.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
      GraphicRadius := 80;
      RetainSpaceObject(TObjectSE(Graphic), TPlanetSE.CreateFromGraph('Ruins.RG', Classes.Point(0, 0)));
      GraphName := Graphic.GraphKey;
      Radius := GraphicRadius;
      Graphic.SetPosition(PolarToPoint(Orbit));
      Graphic.SetRotationTimerInterval(NextRandomIntRange(60, 100, RandomState));
      Graphic.SetSurfaceMapStep(NextRandomIntRange(0, 1, RandomState) * 2 - 1);
      Graphic.OrbitalVelocity := OrbitalVelocity;
      PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
      Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200;
    end
    else
    begin
      Count := High(PlanetSpaceTemplates) + 1;
      Part := 0;
      Quantity := NextRandomIntRange(0, Count - 1, RandomState);
      while True do
      begin
        TemplateAvailable := True;
        Inc(Part);
        IncrementWrapped(Quantity, 0, Count - 1);
        if PlanetSpaceTemplates[Quantity].Style = 1 then Continue;
        if CountPlanetsOfSameRace = 0 then
        begin
          if PlanetSpaceTemplates[Quantity].Radius > 80 then Continue;
        end
        else if (CountPlanetsOfSameRace = 1) and (OwnerId <> oiUninhabited) then
        begin
          if PlanetSpaceTemplates[Quantity].Radius < 100 then Continue;
        end
        else if Star.Planets.Count > 0 then
        begin
          PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
          if Abs(PlanetSpaceTemplates[Quantity].Radius - PreviousPlanet.Radius) < 11 then Continue;
        end;
        if Part < Count then
          for I := 0 to aGalaxy.Galaxy.Planets.Count - 1 do
          begin
            OtherPlanet := TPlanet(aGalaxy.Galaxy.Planets[I]);
            if (OtherPlanet.SpriteTemplateIndex = Quantity) and ((OtherPlanet.CurrentStar = Star) or
               (PointDistanceSquared(OtherPlanet.CurrentStar.Position, Star.Position) < 2500)) then
            begin
              TemplateAvailable := False;
              Break;
            end;
          end;
        if TemplateAvailable then Break;
      end;
      SpriteTemplateIndex := Quantity;
      GraphicRadius := PlanetSpaceTemplates[Quantity].Radius;
      RetainSpaceObject(TObjectSE(Graphic), TPlanetSE.Create);
      PlanetSpaceTemplates[Quantity].SpaceObject.CopyTo(Graphic);
      GraphName := Graphic.GraphKey;
      AllowRing := True;
      ExistingRing := 0;
      for I := 0 to Star.Planets.Count - 1 do
      begin
        PreviousPlanet := TPlanet(Star.Planets[I]);
        if PreviousPlanet.Graphic.RingKind > 0 then
        begin
          if ExistingRing > 0 then AllowRing := False;
          ExistingRing := PreviousPlanet.Graphic.RingKind;
        end;
      end;
      if AllowRing and not IsSolar then
      begin
        if (NextRandomUnitFloat(RandomState) < 0.8) and (GraphicRadius > 90) and
           not (ExistingRing in [1, 4, 5]) and (OwnerId <> oiUninhabited) then
        begin
          I := 0;
          repeat
            Inc(I);
            RingKind := NextRandomIntRange(1, 9, RandomState);
          until (RingKind in [1, 4, 5]) or (I > 200);
          Graphic.SetRingKind(RingKind);
        end
        else if (NextRandomUnitFloat(RandomState) < 0.4) and (GraphicRadius > 90) then
        begin
          if not (ExistingRing in [21, 22]) then Graphic.SetRingKind(NextRandomIntRange(21, 22, RandomState));
        end
        else if (OwnerId <> oiUninhabited) and (GraphicRadius > 70) and (NextRandomUnitFloat(RandomState) < 0.7) then
        begin
          if not (ExistingRing in [1..9]) then Graphic.SetRingKind(NextRandomIntRange(1, 9, RandomState));
        end
        else Graphic.SetRingKind(0);
      end
      else Graphic.SetRingKind(0);
      Radius := GraphicRadius;
      if Star.Planets.Count = 0 then Orbit.Radius := Radius + Star.SystemRadius + 350
      else
      begin
        PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
        Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200 +
          Round(200 - RemapClamped(Star.Planets.Count, 1, 6, 0, 200));
      end;
      OrbitalVelocity := (NextRandomIntRange(0, 1, RandomState) * 2 - 1) * (4.5 - Star.Planets.Count / 2);
      Orbit.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
      Graphic.SetPosition(PolarToPoint(Orbit));
      Graphic.SetRotationTimerInterval(NextRandomIntRange(60, 100, RandomState));
      Graphic.SetSurfaceMapStep(NextRandomIntRange(0, 1, RandomState) * 2 - 1);
      Graphic.OrbitalVelocity := OrbitalVelocity;
      SatelliteConfig := GameDataConfig.GetBlockByPath('SE.Sputnik');
      if Graphic.RingKind = 0 then MinOrbitRadius := Round(Radius * 1.3)
      else MinOrbitRadius := Round(Radius * 1.5);
      MaxOrbitRadius := Radius * 2;
      if Graphic.RingKind = 0 then SatelliteCount := NextRandomIntRange(1, 4, RandomState)
      else if Graphic.RingKind < 20 then SatelliteCount := NextRandomIntRange(0, 4, RandomState)
      else SatelliteCount := 0;
      if Star.Planets.Count > 0 then
      begin
        PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
        if PreviousPlanet.Satellites.Count > 0 then
        begin
          if Graphic.RingKind > 0 then SatelliteCount := 0
          else if OwnerId = oiUninhabited then SatelliteCount := 0
          else SatelliteCount := Min(SatelliteCount, 1);
        end;
      end;
      PreviousExtent := 0;
      if SatelliteCount > 0 then
      for I := 0 to SatelliteCount - 1 do
      begin
        if SatelliteCount = 1 then SatelliteRadius := MinOrbitRadius
        else SatelliteRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
        if (I <= 0) or (SatelliteRadius >= PreviousExtent) then
        begin
          Satellite := TSputnik.Create;
          Satellites.Add(Satellite);
          RetainSpaceObject(TObjectSE(Satellite.Graphic), TSputnikSE.Create('Sputnik.' +
            SatelliteConfig.GetBlockNameByIndex(NextRandomIntRange(0, SatelliteConfig.GetBlockCount - 1, RandomState)),
            Classes.Point(0, 0)));
          Satellite.Graphic.DepthOrder := I;
          Satellite.Graphic.OrbitCenter := GetPosition;
          if SatelliteCount = 1 then Satellite.Graphic.OrbitRadius := MinOrbitRadius
          else Satellite.Graphic.OrbitRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
          Satellite.Graphic.OrbitAngle := NextRandomIntRange(0, 360, RandomState);
          Satellite.Graphic.OrbitAngleStep := 1 + NextRandomUnitFloat(RandomState);
          Satellite.Graphic.OrbitTimerInterval := NextRandomIntRange(28, 35, RandomState);
          Satellite.Graphic.OrbitInclination := NextRandomIntRange(50, 120, RandomState);
          Satellite.Graphic.OrbitRotation := NextRandomIntRange(200, 350, RandomState);
          Satellite.Graphic.MinDisplayRadius := Round(RemapClamped(NextRandomUnitFloat(RandomState) / SatelliteCount,
            0, 1, GeneratedSatelliteBaseRadius, GeneratedSatelliteBaseRadius * 2));
          Satellite.Graphic.MaxDisplayRadius := Round(RemapClamped(NextRandomUnitFloat(RandomState) / 1,
            0, 1, Satellite.Graphic.MinDisplayRadius * 1.3,
            Min(MaximumSatelliteTemplateRadius, Satellite.Graphic.MinDisplayRadius * 2)));
          PreviousExtent := Satellite.Graphic.OrbitRadius + Satellite.Graphic.MaxDisplayRadius div 2;
          Satellite.Graphic.RotationTimerInterval := 25;
          Satellite.Graphic.SurfaceMapStep := ((I mod 2) * 2 - 1) * 2;
        end;
      end;
    end;
    Government := TPlanetGovernment(NextRandomIntRange(0, 4, RandomState));
    GovernmentRoll := NextRandomIntRange(0, 100, RandomState);
    for GovernmentCandidate := pgDemocracy downto pgAnarchy do
      if aConst.PlanetRaceMarket[RaceId].GovernmentRollThresholds[GovernmentCandidate] <= GovernmentRoll then
      begin
        Government := GovernmentCandidate;
        Break;
      end;
    EconomyRoll := NextRandomIntRange(1, aGalaxy.Galaxy.GetAgriculturalPlanetWeight +
      aGalaxy.Galaxy.GetMixedPlanetWeight + aGalaxy.Galaxy.GetIndustrialPlanetWeight, RandomState);
    if EconomyRoll <= aGalaxy.Galaxy.GetAgriculturalPlanetWeight then Economy := peAgricultural
    // Native code adds the agricultural weight twice for the second threshold.
    else if EconomyRoll <= aGalaxy.Galaxy.GetAgriculturalPlanetWeight + aGalaxy.Galaxy.GetAgriculturalPlanetWeight then Economy := peMixed
    else Economy := peIndustrial;
    Population := CalculateBasePopulation;
  end;
  for Invention := Low(TPlanetInvention) to High(TPlanetInvention) do InventionLevels[Invention] := PlanetInventionInfo[Invention].InitialLevel;
  CurrentInvention := piHull;
  CurrentInventionPoints := 0;
  ResearchLevelPercent := 30;
  BoostInventionLevels(aConst.PlanetRaceMarket[RaceId].InitialInventionBoostCount);
  ResearchLevelPercent := NextRandomIntRange(20, 40, RandomState);
  ResearchLevelStep := NextRandomIntRange(5, 10, RandomState);
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    Goods[Good].Count := NextRandomIntRange(GoodsMarket[Good].BaseStock div 2, GoodsMarket[Good].BaseStock, RandomState);
    Goods[Good].PriceState := GoodsMarket[Good].AveragePrice;
    Goods[Good].PurchasePrice := Round(Goods[Good].PriceState);
    Goods[Good].BaseSalePrice := Round(Goods[Good].PriceState * 0.98 - 1);
    GoodsScarcityTicks[Good] := 0;
    GoodsSurplusTicks[Good] := 0;
  end;
  TextQuestId := -1;
  Money := Round(RemapClamped(Radius, 60, 100, 10000, 100000));
  HomeRangerCount := 0;
  HomeTransportCount := 0;
  if OwnerId <> oiUninhabited then
    for ItemType := t_Hull to WeaponCategoryItemType do
      case ItemType of
        t_Hull:
          for I := 1 to NextRandomIntRange(1, 5, RandomState) do
          begin
            Item := THull.Create;
            EquipmentShop.Add(Item);
            HullType := THullType(NextRandomIntRange(Ord(htRanger), Ord(htDiplomat), RandomState));
            ItemOwner := RaceToOwner(RaceId);
            Series := aGalaxy.Galaxy.SelectHullSeries(ItemOwner, HullType, 1, 100);
            (Item as THull).Init(NextRandomIntRange(Round(HullBaseSize * EquipmentSizeFactors[5]),
              Round(HullBaseSize * EquipmentSizeFactors[4]), RandomState),
              NextRandomIntRange(1, InventionLevels[piHull], RandomState), ItemOwner, HullType, Series, False);
          end;
        t_FuelTanks:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TFuelTanks.Create;
            EquipmentShop.Add(Item);
            (Item as TFuelTanks).Init(NextRandomIntRange(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]),
              Round(FuelTanksBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piFuelTanks], RandomState), OwnerId);
          end;
        t_Engine:
          for I := 1 to NextRandomIntRange(1, 3, RandomState) do
          begin
            Item := TEngine.Create;
            EquipmentShop.Add(Item);
            (Item as TEngine).Init(NextRandomIntRange(Round(EngineBaseSize * EquipmentSizeFactors[5]),
              Round(EngineBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piEngine], RandomState), OwnerId);
          end;
        t_Radar:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TRadar.Create;
            EquipmentShop.Add(Item);
            (Item as TRadar).Init(NextRandomIntRange(Round(RadarBaseSize * EquipmentSizeFactors[5]),
              Round(RadarBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piRadar], RandomState), OwnerId);
          end;
        t_Scaner:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TScaner.Create;
            EquipmentShop.Add(Item);
            (Item as TScaner).Init(NextRandomIntRange(Round(ScannerBaseSize * EquipmentSizeFactors[5]),
              Round(ScannerBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piScanner], RandomState), OwnerId);
          end;
        t_RepairRobot:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TRepairRobot.Create;
            EquipmentShop.Add(Item);
            (Item as TRepairRobot).Init(NextRandomIntRange(Round(RepairRobotBaseSize * EquipmentSizeFactors[5]),
              Round(RepairRobotBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piRepairRobot], RandomState), OwnerId);
          end;
        t_CargoHook:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TCargoHook.Create;
            EquipmentShop.Add(Item);
            (Item as TCargoHook).Init(NextRandomIntRange(Round(CargoHookBaseSize * EquipmentSizeFactors[5]),
              Round(CargoHookBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piCargoHook], RandomState), OwnerId);
          end;
        t_DefGenerator:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TDefGenerator.Create;
            EquipmentShop.Add(Item);
            (Item as TDefGenerator).Init(NextRandomIntRange(Round(DefGeneratorBaseSize * EquipmentSizeFactors[5]),
              Round(DefGeneratorBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piMainTech], RandomState), OwnerId);
          end;
        WeaponCategoryItemType:
          for I := 1 to NextRandomIntRange(2, InventionLevels[piMainTech] + 2, RandomState) do
          begin
            WeaponInfo := aGalaxy.Galaxy.SelectWeaponInfo(RandomIntRange(1, 100000), [waFree], InventionLevels[piMainTech], 1);
            GeneratedWeapon := CreateGeneratedWeapon(WeaponInfo,
              NextRandomIntRange(Round(WeaponInfo.AverageSize * EquipmentSizeFactors[5]),
                Round(WeaponInfo.AverageSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piMainTech], RandomState), OwnerId);
            EquipmentShop.Add(GeneratedWeapon);
          end;
      end;
  WaterTiles := Round(Graphic.SpaceConfigValues[0]);
  WaterExplored := 0;
  LandTiles := Round(Graphic.SpaceConfigValues[1]);
  LandExplored := 0;
  HillTiles := Round(Graphic.SpaceConfigValues[2]);
  HillExplored := 0;
  ProbeOrbitCount := Round(RemapClamped(Radius, 60, 100, 1, 3));
  if SeededRandomUnitFloat(RandomState) < 0.5 then Inc(ProbeOrbitCount);
  if SeededRandomUnitFloat(RandomState) < 0.8 then Inc(ProbeOrbitCount);
  if (OwnerId = oiUninhabited) and (GetUnexploredSurfaceTileCount > 50) then
  begin
    for I := 1 to NextRandomIntRange(1, Round(RemapClamped(Radius, 60, 100, 1, 3)), RandomState) do
    begin
      if SeededRandomUnitFloat(RandomState) < 0.8 then Continue;
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.8) then Continue;
      Loot := CreateRandomLootItem(ilpTreasure, RaceToOwner(RaceId), 767 + NextRandomIntRange(1, 3000, RandomState));
      if Loot is TArtefactTranclucator then
        TTranclucator(TArtefactTranclucator(Loot).Ship).OwnerShip := nil;
      AddSurfaceLootEntry(Loot);
    end;
    for I := 1 to NextRandomIntRange(1, Round(RemapClamped(Radius, 60, 100, 1, 3)), RandomState) do
    begin
      if SeededRandomUnitFloat(RandomState) < 0.8 then Continue;
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.8) then Continue;
      ModuleIndex := aGalaxy.Galaxy.SelectMicroModule(NextRandomIntRange(0, 50, RandomState), 100, RandomState, nil);
      Module := TMicroModule.Create;
      Module.Init(ModuleIndex);
      AddSurfaceLootEntry(Module);
    end;
    for I := 1 to Round(RemapClamped(Radius, 60, 100, 2, 4)) do
    begin
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.4) then Continue;
      Cistern := TCistern.Create;
      Count := NextRandomIntRange(5, 20, RandomState);
      if SeededRandomUnitFloat(RandomState) < 0.2 then
      begin
        Count := RoundAndTruncateToFives(Count * 2);
        if SeededRandomUnitFloat(RandomState) < 0.1 then Count := RoundAndTruncateToFives(Count * 2);
      end;
      Cistern.Init(NextRandomIntRange(0, Count, RandomState), Count, RaceToOwner(RaceId));
      AddSurfaceLootEntry(Cistern);
    end;
    MinLevel := 1;
    MaxLevel := 5;
    WeaponTechLevel := NextRandomIntRange(1, NextRandomIntRange(2, 4, RandomState), RandomState);
    MinSizeFactor := EquipmentSizeFactors[5];
    MaxSizeFactor := EquipmentSizeFactors[1];
    for I := 1 to Round(RemapClamped(Radius, 60, 100, 2, 3)) do
    begin
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.75) then Continue;
      Count := 0;
      Item := nil;
      while True do
      begin
        Inc(Count);
        if NextRandomIntRange(1, 130, RandomState) > 70 then
        begin
          WeaponInfo := aGalaxy.Galaxy.SelectWeaponInfo(RandomState, [waFree],
            Min(WeaponTechLevel + 2, 8), Max(1, WeaponTechLevel - 1));
          Weight := NextRandomIntRange(Round(WeaponInfo.AverageSize * MinSizeFactor),
            Round(WeaponInfo.AverageSize * MaxSizeFactor), RandomState);
          Level := NextRandomIntRange(MinLevel, MaxLevel, RandomState);
          Item := CreateGeneratedWeapon(WeaponInfo, Weight, Level, oiUninhabited);
        end
        else
        begin
          ItemType := TItemType(PickRandomItemType([Ord(t_FuelTanks)..Ord(t_DefGenerator)]));
          Weight := NextRandomIntRange(Round(GetAverageItemSize(ItemType) * MinSizeFactor),
            Round(GetAverageItemSize(ItemType) * MaxSizeFactor), RandomState);
          Level := NextRandomIntRange(MinLevel, MaxLevel, RandomState);
          Item := CreateGeneratedEquipment(ItemType, Weight, Level, oiUninhabited);
        end;
        if (Item.Cost < 5000) or ((Item.Cost < 5000 * 1.5) and (Count > 2)) or
           ((Item.Cost < 10000) and (Count > 3)) or (Count > 4) then Break;
        Item.Free;
      end;
      Item.ConditionPercent := SeededRandomFloatRange(Item.Id, 10, 100);
      AddSurfaceLootEntry(Item);
    end;
    for I := 1 to Round(RemapClamped(Radius, 60, 100, 2, 5)) do
    begin
      if (I > 2) and (SeededRandomUnitFloat(RandomState) < 0.4) then Continue;
      ItemType := TItemType(NextRandomIntRange(0, 7, RandomState));
      Count := NextRandomIntRange(Max(1, GoodsMarket[Ord(ItemType)].BaseStock div 20),
        Round(RemapClamped(Radius, 60, 100, GoodsMarket[Ord(ItemType)].BaseStock div 15,
          GoodsMarket[Ord(ItemType)].BaseStock div 7)), RandomState);
      SavedRandomState := RandomState;
      if Count < 10 then Part := NextRandomIntRange(1, 2, RandomState)
      else Part := NextRandomIntRange(1, 4, RandomState);
      for Part := 1 to Part do
      begin
        GoodsItem := TGoods.Create;
        Quantity := Count div SeededRandomIntRange(1, 5, RandomState * Part * Byte(ItemType)) + 1;
        RandomState := SavedRandomState;
        GoodsItem.Init(ItemType, Quantity);
        GoodsItem.Cost := GoodsItem.Cost div SeededRandomIntRange(2, 5, RandomState * Part * Byte(ItemType) * 3);
        AddSurfaceLootEntry(GoodsItem);
      end;
    end;
    NormalizeSurfaceLootEntries;
  end;
  HasPlayerLanded := False;
  UpdateOwnerFlags;
  for I := 0 to aGalaxy.Galaxy.CustomRules.ExtraInventions do
  begin
    CurrentInventionPoints := 101;
    AdvanceInventionProgress;
  end;
end;
{ @end $77FCA8 }

{ @routine $783378 TPlanet_InitDominatorSpawnProxy }
procedure TPlanet.InitDominatorSpawnProxy(Star: TStar);
var Index: TPlanetInvention;
begin
  CurrentStar := Star;
  OwnerId := oiDominator;
  for Index := Low(TPlanetInvention) to High(TPlanetInvention) do InventionLevels[Index] := 8;
end;
{ @end $783378 }

{ @routine $7833B4 TPlanet_InitGeneratedUninhabited }
procedure TPlanet.InitGeneratedUninhabited(Star: TStar);
{ Requires an existing planet in Star.Planets: native orbit spacing reads the
  final entry before any empty-list check. Self is registered by the caller.
  The unused locals preserve observed O- frame gaps; their original names and
  scalar types are unknown. UnusedText is different: native initialization and
  finalization explicitly identify that unused slot as a managed WideString. }
var
  UnusedPlanet, PreviousPlanet: TPlanet;
  Invention: TPlanetInvention;
  Good: Byte;
  Quantity, Count, I, Part, UnusedCount, ExistingRing, ModuleIndex: Integer;
  SavedRandomState: Cardinal;
  UnusedOrbit, PreviousExtent, SatelliteRadius, UnusedRadius, MinOrbitRadius, MaxOrbitRadius: Double;
  UnusedOwner, ItemOwner: TOwnerId;
  UnusedText: WideString;
  Satellite: TSputnik;
  SatelliteCount: Integer;
  SatelliteConfig: TBlockParEC;
  Item: TEquipment;
  ItemType: TItemType;
  Series: Integer;
  UnusedRingFlags: array[0..2] of Byte;
  AllowRing: Boolean;
  UnusedHullFlag: Byte; HullType: THullType;
  UnusedItem: TItem;
  Loot: TEquipmentWithActCode;
  Module: TMicroModule;
  Cistern: TCistern;
  GoodsItem: TGoods;
  Ranger: TRanger;
  Weight, Level: Integer;
  WeaponInfo: PWeaponInfo;
  MinSizeFactor, MaxSizeFactor: Single;
  MinLevel, MaxLevel, WeaponTechLevel: Integer;
  GeneratedWeapon: TWeapon;
begin
  CurrentStar := Star;
  OwnerId := oiUninhabited;
  RaceId := oiMaloc;
  Name := 'New Planet';
  Count := High(PlanetSpaceTemplates) + 1;
  Quantity := RandomIntRange(0, Count - 1);
  while PlanetSpaceTemplates[Quantity].Style = 1 do
    Quantity := RandomIntRange(0, Count - 1);
  SpriteTemplateIndex := Quantity;
  GraphicRadius := PlanetSpaceTemplates[Quantity].Radius;
  RetainSpaceObject(TObjectSE(Graphic), TPlanetSE.Create);
  PlanetSpaceTemplates[Quantity].SpaceObject.CopyTo(Graphic);
  GraphName := Graphic.GraphKey;
  AllowRing := True;
  ExistingRing := 0;
  for I := 0 to Star.Planets.Count - 1 do
  begin
    PreviousPlanet := TPlanet(Star.Planets[I]);
    if PreviousPlanet.Graphic.RingKind > 0 then
    begin
      if ExistingRing > 0 then AllowRing := False;
      ExistingRing := PreviousPlanet.Graphic.RingKind;
    end;
  end;
  if AllowRing and (NextRandomUnitFloat(RandomState) < 0.4) and (GraphicRadius > 90) then
  begin
    if not (ExistingRing in [21, 22]) then Graphic.SetRingKind(NextRandomIntRange(21, 22, RandomState));
  end
  else Graphic.SetRingKind(0);
  Radius := GraphicRadius;
  PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
  Orbit.Radius := PreviousPlanet.Orbit.Radius + PreviousPlanet.Radius + Radius + 200 +
    Round(200 - RemapClamped(Star.Planets.Count, 1, 6, 0, 200));
  OrbitalVelocity := (NextRandomIntRange(0, 1, RandomState) * 2 - 1) * (4.5 - Star.Planets.Count / 2);
  Orbit.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
  Graphic.SetPosition(PolarToPoint(Orbit));
  Graphic.SetRotationTimerInterval(NextRandomIntRange(60, 100, RandomState));
  Graphic.SetSurfaceMapStep(NextRandomIntRange(0, 1, RandomState) * 2 - 1);
  Graphic.OrbitalVelocity := OrbitalVelocity;
  SatelliteConfig := GameDataConfig.GetBlockByPath('SE.Sputnik');
  if Graphic.RingKind = 0 then MinOrbitRadius := Round(Radius * 1.3)
  else MinOrbitRadius := Round(Radius * 1.5);
  MaxOrbitRadius := Radius * 2;
  if Graphic.RingKind = 0 then SatelliteCount := NextRandomIntRange(1, 4, RandomState)
  else if Graphic.RingKind < 20 then SatelliteCount := NextRandomIntRange(0, 4, RandomState)
  else SatelliteCount := 0;
  if Star.Planets.Count > 0 then
  begin
    PreviousPlanet := TPlanet(Star.Planets[Star.Planets.Count - 1]);
    if PreviousPlanet.Satellites.Count > 0 then SatelliteCount := 0;
  end;
  PreviousExtent := 0;
  if SatelliteCount > 0 then
  for I := 0 to SatelliteCount - 1 do
  begin
    if SatelliteCount = 1 then SatelliteRadius := MinOrbitRadius
    else SatelliteRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
    if (I <= 0) or (SatelliteRadius >= PreviousExtent) then
    begin
      Satellite := TSputnik.Create;
      Satellites.Add(Satellite);
      RetainSpaceObject(TObjectSE(Satellite.Graphic), TSputnikSE.Create('Sputnik.' +
        SatelliteConfig.GetBlockNameByIndex(NextRandomIntRange(0, SatelliteConfig.GetBlockCount - 1, RandomState)),
        Classes.Point(0, 0)));
      Satellite.Graphic.DepthOrder := I;
      Satellite.Graphic.OrbitCenter := GetPosition;
      if SatelliteCount = 1 then Satellite.Graphic.OrbitRadius := MinOrbitRadius
      else Satellite.Graphic.OrbitRadius := Round(RemapClamped(I, 0, 3, MinOrbitRadius, MaxOrbitRadius));
      Satellite.Graphic.OrbitAngle := NextRandomIntRange(0, 360, RandomState);
      Satellite.Graphic.OrbitAngleStep := 1 + NextRandomUnitFloat(RandomState);
      Satellite.Graphic.OrbitTimerInterval := NextRandomIntRange(28, 35, RandomState);
      Satellite.Graphic.OrbitInclination := NextRandomIntRange(50, 120, RandomState);
      Satellite.Graphic.OrbitRotation := NextRandomIntRange(200, 350, RandomState);
      Satellite.Graphic.MinDisplayRadius := Round(RemapClamped(NextRandomUnitFloat(RandomState) / SatelliteCount,
        0, 1, GeneratedSatelliteBaseRadius, GeneratedSatelliteBaseRadius * 2));
      Satellite.Graphic.MaxDisplayRadius := Round(RemapClamped(NextRandomUnitFloat(RandomState) / 1,
        0, 1, Satellite.Graphic.MinDisplayRadius * 1.3,
        Min(MaximumSatelliteTemplateRadius, Satellite.Graphic.MinDisplayRadius * 2)));
      PreviousExtent := Satellite.Graphic.OrbitRadius + Satellite.Graphic.MaxDisplayRadius div 2;
      Satellite.Graphic.RotationTimerInterval := 25;
      Satellite.Graphic.SurfaceMapStep := ((I mod 2) * 2 - 1) * 2;
    end;
  end;
  Government := pgAnarchy;
  Economy := peMixed;
  Population := CalculateBasePopulation;
  for Invention := Low(TPlanetInvention) to High(TPlanetInvention) do InventionLevels[Invention] := PlanetInventionInfo[Invention].InitialLevel;
  CurrentInvention := piHull;
  CurrentInventionPoints := 0;
  ResearchLevelPercent := 30;
  BoostInventionLevels(aConst.PlanetRaceMarket[RaceId].InitialInventionBoostCount);
  ResearchLevelPercent := NextRandomIntRange(20, 40, RandomState);
  ResearchLevelStep := NextRandomIntRange(5, 10, RandomState);
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    Goods[Good].Count := NextRandomIntRange(GoodsMarket[Good].BaseStock div 2, GoodsMarket[Good].BaseStock, RandomState);
    Goods[Good].PriceState := GoodsMarket[Good].AveragePrice;
    Goods[Good].PurchasePrice := Round(Goods[Good].PriceState);
    Goods[Good].BaseSalePrice := Round(Goods[Good].PriceState * 0.98 - 1);
    GoodsScarcityTicks[Good] := 0;
    GoodsSurplusTicks[Good] := 0;
  end;
  TextQuestId := -1;
  Money := Round(RemapClamped(Radius, 60, 100, 10000, 100000));
  HomeRangerCount := 0;
  HomeTransportCount := 0;
  // Kept even though OwnerId was assigned 6 above: the original emits this stock-generation branch.
  if OwnerId <> oiUninhabited then
    for ItemType := t_Hull to WeaponCategoryItemType do
      case ItemType of
        t_Hull:
          for I := 1 to NextRandomIntRange(1, 5, RandomState) do
          begin
            Item := THull.Create;
            EquipmentShop.Add(Item);
            HullType := THullType(NextRandomIntRange(Ord(htRanger), Ord(htDiplomat), RandomState));
            ItemOwner := RaceToOwner(RaceId);
            Series := aGalaxy.Galaxy.SelectHullSeries(ItemOwner, HullType, 1, 100);
            (Item as THull).Init(NextRandomIntRange(Round(HullBaseSize * EquipmentSizeFactors[5]),
              Round(HullBaseSize * EquipmentSizeFactors[4]), RandomState),
              NextRandomIntRange(1, InventionLevels[piHull], RandomState), ItemOwner, HullType, Series, False);
          end;
        t_FuelTanks:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TFuelTanks.Create;
            EquipmentShop.Add(Item);
            (Item as TFuelTanks).Init(NextRandomIntRange(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]),
              Round(FuelTanksBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piFuelTanks], RandomState), OwnerId);
          end;
        t_Engine:
          for I := 1 to NextRandomIntRange(1, 3, RandomState) do
          begin
            Item := TEngine.Create;
            EquipmentShop.Add(Item);
            (Item as TEngine).Init(NextRandomIntRange(Round(EngineBaseSize * EquipmentSizeFactors[5]),
              Round(EngineBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piEngine], RandomState), OwnerId);
          end;
        t_Radar:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TRadar.Create;
            EquipmentShop.Add(Item);
            (Item as TRadar).Init(NextRandomIntRange(Round(RadarBaseSize * EquipmentSizeFactors[5]),
              Round(RadarBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piRadar], RandomState), OwnerId);
          end;
        t_Scaner:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TScaner.Create;
            EquipmentShop.Add(Item);
            (Item as TScaner).Init(NextRandomIntRange(Round(ScannerBaseSize * EquipmentSizeFactors[5]),
              Round(ScannerBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piScanner], RandomState), OwnerId);
          end;
        t_RepairRobot:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TRepairRobot.Create;
            EquipmentShop.Add(Item);
            (Item as TRepairRobot).Init(NextRandomIntRange(Round(RepairRobotBaseSize * EquipmentSizeFactors[5]),
              Round(RepairRobotBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piRepairRobot], RandomState), OwnerId);
          end;
        t_CargoHook:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TCargoHook.Create;
            EquipmentShop.Add(Item);
            (Item as TCargoHook).Init(NextRandomIntRange(Round(CargoHookBaseSize * EquipmentSizeFactors[5]),
              Round(CargoHookBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piCargoHook], RandomState), OwnerId);
          end;
        t_DefGenerator:
          for I := 1 to NextRandomIntRange(1, 2, RandomState) do
          begin
            Item := TDefGenerator.Create;
            EquipmentShop.Add(Item);
            (Item as TDefGenerator).Init(NextRandomIntRange(Round(DefGeneratorBaseSize * EquipmentSizeFactors[5]),
              Round(DefGeneratorBaseSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piMainTech], RandomState), OwnerId);
          end;
        WeaponCategoryItemType:
          for I := 1 to NextRandomIntRange(2, InventionLevels[piMainTech] + 2, RandomState) do
          begin
            WeaponInfo := aGalaxy.Galaxy.SelectWeaponInfo(RandomIntRange(1, 100000), [waFree], InventionLevels[piMainTech], 1);
            GeneratedWeapon := CreateGeneratedWeapon(WeaponInfo,
              NextRandomIntRange(Round(WeaponInfo.AverageSize * EquipmentSizeFactors[5]),
                Round(WeaponInfo.AverageSize * EquipmentSizeFactors[1]), RandomState),
              NextRandomIntRange(1, InventionLevels[piMainTech], RandomState), OwnerId);
            EquipmentShop.Add(GeneratedWeapon);
          end;
      end;
  WaterTiles := Round(Graphic.SpaceConfigValues[0]);
  WaterExplored := 0;
  LandTiles := Round(Graphic.SpaceConfigValues[1]);
  LandExplored := 0;
  HillTiles := Round(Graphic.SpaceConfigValues[2]);
  HillExplored := 0;
  ProbeOrbitCount := Round(RemapClamped(Radius, 60, 100, 1, 3));
  if SeededRandomUnitFloat(RandomState) < 0.5 then Inc(ProbeOrbitCount);
  if SeededRandomUnitFloat(RandomState) < 0.8 then Inc(ProbeOrbitCount);
  if (OwnerId = oiUninhabited) and (GetUnexploredSurfaceTileCount > 50) then
  begin
    for I := 1 to NextRandomIntRange(1, Round(RemapClamped(Radius, 60, 100, 1, 3)), RandomState) do
    begin
      if SeededRandomUnitFloat(RandomState) < 0.8 then Continue;
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.8) then Continue;
      Loot := CreateRandomLootItem(ilpTreasure, RaceToOwner(RaceId), 767 + NextRandomIntRange(1, 3000, RandomState));
      if Loot is TArtefactTranclucator then
        TTranclucator(TArtefactTranclucator(Loot).Ship).OwnerShip := nil;
      AddSurfaceLootEntry(Loot);
    end;
    for I := 1 to NextRandomIntRange(1, Round(RemapClamped(Radius, 60, 100, 1, 3)), RandomState) do
    begin
      if SeededRandomUnitFloat(RandomState) < 0.8 then Continue;
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.8) then Continue;
      ModuleIndex := aGalaxy.Galaxy.SelectMicroModule(NextRandomIntRange(0, 50, RandomState), 100, RandomState, nil);
      Module := TMicroModule.Create;
      Module.Init(ModuleIndex);
      AddSurfaceLootEntry(Module);
    end;
    for I := 1 to Round(RemapClamped(Radius, 60, 100, 2, 4)) do
    begin
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.4) then Continue;
      Cistern := TCistern.Create;
      Count := NextRandomIntRange(5, 20, RandomState);
      if SeededRandomUnitFloat(RandomState) < 0.2 then
      begin
        Count := RoundAndTruncateToFives(Count * 2);
        if SeededRandomUnitFloat(RandomState) < 0.1 then Count := RoundAndTruncateToFives(Count * 2);
      end;
      Cistern.Init(NextRandomIntRange(0, Count, RandomState), Count, RaceToOwner(RaceId));
      AddSurfaceLootEntry(Cistern);
    end;
    MinLevel := 1;
    MaxLevel := 5;
    WeaponTechLevel := NextRandomIntRange(1, NextRandomIntRange(2, 4, RandomState), RandomState);
    MinSizeFactor := EquipmentSizeFactors[5];
    MaxSizeFactor := EquipmentSizeFactors[1];
    for I := 1 to Round(RemapClamped(Radius, 60, 100, 2, 3)) do
    begin
      if (I > 1) and (SeededRandomUnitFloat(RandomState) < 0.75) then Continue;
      Count := 0;
      Item := nil;
      while True do
      begin
        Inc(Count);
        if NextRandomIntRange(1, 130, RandomState) > 70 then
        begin
          WeaponInfo := aGalaxy.Galaxy.SelectWeaponInfo(RandomState, [waFree],
            Min(WeaponTechLevel + 2, 8), Max(1, WeaponTechLevel - 1));
          Weight := NextRandomIntRange(Round(WeaponInfo.AverageSize * MinSizeFactor),
            Round(WeaponInfo.AverageSize * MaxSizeFactor), RandomState);
          Level := NextRandomIntRange(MinLevel, MaxLevel, RandomState);
          Item := CreateGeneratedWeapon(WeaponInfo, Weight, Level, oiUninhabited);
        end
        else
        begin
          ItemType := TItemType(PickRandomItemType([Ord(t_FuelTanks)..Ord(t_DefGenerator)]));
          Weight := NextRandomIntRange(Round(GetAverageItemSize(ItemType) * MinSizeFactor),
            Round(GetAverageItemSize(ItemType) * MaxSizeFactor), RandomState);
          Level := NextRandomIntRange(MinLevel, MaxLevel, RandomState);
          Item := CreateGeneratedEquipment(ItemType, Weight, Level, oiUninhabited);
        end;
        if (Item.Cost < 5000) or ((Item.Cost < 5000 * 1.5) and (Count > 2)) or
           ((Item.Cost < 10000) and (Count > 3)) or (Count > 4) then Break;
        Item.Free;
      end;
      Item.ConditionPercent := SeededRandomFloatRange(Item.Id, 10, 100);
      AddSurfaceLootEntry(Item);
    end;
    for I := 1 to Round(RemapClamped(Radius, 60, 100, 2, 5)) do
    begin
      if (I > 2) and (SeededRandomUnitFloat(RandomState) < 0.4) then Continue;
      ItemType := TItemType(NextRandomIntRange(0, 7, RandomState));
      Count := NextRandomIntRange(Max(1, GoodsMarket[Ord(ItemType)].BaseStock div 20),
        Round(RemapClamped(Radius, 60, 100, GoodsMarket[Ord(ItemType)].BaseStock div 15,
          GoodsMarket[Ord(ItemType)].BaseStock div 7)), RandomState);
      SavedRandomState := RandomState;
      if Count < 10 then Part := NextRandomIntRange(1, 2, RandomState)
      else Part := NextRandomIntRange(1, 4, RandomState);
      for Part := 1 to Part do
      begin
        GoodsItem := TGoods.Create;
        Quantity := Count div SeededRandomIntRange(1, 5, RandomState * Part * Byte(ItemType)) + 1;
        RandomState := SavedRandomState;
        GoodsItem.Init(ItemType, Quantity);
        GoodsItem.Cost := GoodsItem.Cost div SeededRandomIntRange(2, 5, RandomState * Part * Byte(ItemType) * 3);
        AddSurfaceLootEntry(GoodsItem);
      end;
    end;
    NormalizeSurfaceLootEntries;
  end;
  for I := 0 to aGalaxy.Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(aGalaxy.Galaxy.Rangers[I]);
    RangerRelations.Add(Pointer(OwnerRelations[RaceToOwner(RaceId),
      RaceToOwner(Ranger.PilotRace)]));
  end;
  HasPlayerLanded := False;
  UpdateOwnerFlags;
end;
{ @end $7833B4 }

{ @routine $785188 TPlanet_SaveToBuffer }
procedure TPlanet.SaveToBuffer(Buffer: TBufEC);
var
  Track: TPlanetInvention;
  Kind: Byte;
  i, Count: Integer;
  Ship: TShip;
  Satellite: TSputnik;
  Item: TItem;
  Entry: PPlanetSurfaceLootEntry;
begin
  Buffer.AddDWord(Self.Id);
  Buffer.AddIntegerValue(Self.GenerationSeed);
  Buffer.AddDWord(Self.RandomState);
  Buffer.AddWideStringZ(Self.Name);
  Buffer.AddSingle(Self.Orbit.AngleDegrees);
  Buffer.AddSingle(Self.Orbit.Radius);
  i := 4;
  Buffer.AddSingle(Self.OrbitalVelocity);
  Buffer.AddIntegerValue(Self.ReservedSaveValue);
  Buffer.AddIntegerValue(Self.Radius);
  Buffer.AddIntegerValue(Self.WaterTiles);
  Buffer.AddIntegerValue(Self.WaterExplored);
  Buffer.AddIntegerValue(Self.LandTiles);
  Buffer.AddIntegerValue(Self.LandExplored);
  Buffer.AddIntegerValue(Self.HillTiles);
  Buffer.AddIntegerValue(Self.HillExplored);
  Buffer.AddAnsiChar(AnsiChar(Self.ProbeOrbitCount));
  Buffer.AddBoolean(Self.HasPlayerLanded);
  for Track := Low(TPlanetInvention) to High(TPlanetInvention) do Buffer.AddAnsiChar(AnsiChar(Self.InventionLevels[Track]));
  Buffer.AddAnsiChar(AnsiChar(Self.CurrentInvention));
  Buffer.AddSingle(Self.CurrentInventionPoints);
  Buffer.AddAnsiChar(AnsiChar(Self.ResearchLevelPercent));
  Buffer.AddAnsiChar(AnsiChar(Self.ResearchLevelStep));
  Buffer.AddDWord(Self.Population);
  Buffer.AddAnsiChar(AnsiChar(Self.Economy));
  Buffer.AddDWord(Self.Money);
  Buffer.AddAnsiChar(AnsiChar(Self.OwnerId));
  Buffer.AddAnsiChar(AnsiChar(Self.RaceId));
  Buffer.AddAnsiChar(AnsiChar(Self.Government));
  for Kind := 0 to 7 do
  begin
    Buffer.AddIntegerValue(Self.Goods[Kind].Count);
    Buffer.AddSingle(Self.Goods[Kind].PriceState);
    Buffer.AddIntegerValue(Self.Goods[Kind].PurchasePrice);
    Buffer.AddIntegerValue(Self.Goods[Kind].BaseSalePrice);
    Buffer.AddAnsiChar(AnsiChar(Self.GoodsScarcityTicks[Kind]));
    Buffer.AddAnsiChar(AnsiChar(Self.GoodsSurplusTicks[Kind]));
  end;
  Count := Self.RangerRelations.Count;
  Buffer.AddWideChar(WideChar(Count));
  for i := 0 to Count - 1 do Buffer.AddAnsiChar(AnsiChar(Self.RangerRelations[i]));
  Count := Self.EquipmentShop.Count;
  Buffer.AddWideChar(WideChar(Count));
  for i := 0 to Count - 1 do
  begin
    Item := TItem(Self.EquipmentShop[i]);
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  Count := 0;
  for i := 0 to Self.Warriors.Count - 1 do
  begin
    Ship := TShip(Self.Warriors[i]);
    if Ship.CurrentStar.Ships.IndexOf(Ship) < 0 then Inc(Count);
  end;
  Buffer.AddWideChar(WideChar(Count));
  Count := Self.Warriors.Count;
  for i := 0 to Count - 1 do
  begin
    Ship := TShip(Self.Warriors[i]);
    if Ship.CurrentStar.Ships.IndexOf(Ship) < 0 then
    begin
      Buffer.AddAnsiChar(AnsiChar(Ship.TypeId));
      Ship.SaveToBuffer(Buffer);
    end;
  end;
  Buffer.AddWideChar(WideChar(Self.HomeRangerCount));
  Buffer.AddWideChar(WideChar(Self.HomeTransportCount));
  Buffer.AddWideChar(#0);
  Buffer.AddWideChar(#0);
  Buffer.AddWideChar(#0);
  Buffer.AddWideChar(WideChar(Self.GraphicRadius));
  Buffer.AddWideStringZ(Self.GraphName);
  Buffer.AddWideChar(WideChar(Self.Graphic.RotationTimerInterval));
  Buffer.AddIntegerValue(Self.Graphic.SurfaceMapStep);
  Buffer.AddAnsiChar(AnsiChar(Self.Graphic.RingKind));
  Buffer.AddIntegerValue(Self.TextQuestId);
  Count := Self.Satellites.Count;
  Buffer.AddWideChar(WideChar(Count));
  for i := 0 to Count - 1 do
  begin
    Satellite := TSputnik(Self.Satellites[i]);
    Satellite.SaveToBuffer(Buffer);
  end;
  if Self.SurfaceLootEntries = nil then Buffer.AddWideChar(#0)
  else
  begin
    Buffer.AddWideChar(WideChar(Self.SurfaceLootEntries.Count));
    for i := 0 to Self.SurfaceLootEntries.Count - 1 do
    begin
      Entry := Self.SurfaceLootEntries[i];
      Buffer.AddAnsiChar(AnsiChar(Entry.GridX));
      Buffer.AddAnsiChar(AnsiChar(Entry.GridY));
      Buffer.AddAnsiChar(AnsiChar(Entry.TerrainKind));
      Buffer.AddIntegerValue(Entry.SurfaceTileIndex);
      Buffer.AddBoolean(Entry.Unavailable);
      Buffer.AddAnsiChar(AnsiChar(Entry.Item.ItemType));
      Entry.Item.SaveToBuffer(Buffer);
    end;
  end;
  Buffer.AddBoolean(Self.NoLanding);
  Buffer.AddAnsiChar(AnsiChar(Byte((4 * Ord(Self.NoAutomaticShipSpawning)) + Self.ShopUpdateMode + (8 * Ord(Self.NoRandomEvents)))));
  Buffer.AddBoolean(Self.IsMainPiratePlanet);
  Buffer.AddWideStringZ(Self.CustomFaction);
end;
{ @end $785188 }

{ @routine $7857C0 TPlanet_LoadFromBuffer }
procedure TPlanet.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  Track: TPlanetInvention;
  Item: TItem;
  Good: Byte;
  i, Count: Integer;
  Ship: TShip;
  ShipType: TShipType;
  Satellite: TSputnik;
  Entry: PPlanetSurfaceLootEntry;
  Stage: Integer;
begin
  Stage := 0;
  try
    Id := Buffer.GetUInt32;
    if Galaxy.NextPlanetId <= Id then Galaxy.NextPlanetId := Id + 1;
    GenerationSeed := Buffer.GetInt32;
    RandomState := Buffer.GetUInt32;
    Name := Buffer.ReadWideString;
    Orbit.AngleDegrees := Buffer.GetSingle;
    Orbit.Radius := Buffer.GetSingle;
    OrbitalVelocity := Buffer.GetSingle;
    ReservedSaveValue := Buffer.GetInt32;
    Radius := Buffer.GetInt32;
    WaterTiles := Buffer.GetInt32;
    WaterExplored := Buffer.GetInt32;
    LandTiles := Buffer.GetInt32;
    LandExplored := Buffer.GetInt32;
    HillTiles := Buffer.GetInt32;
    HillExplored := Buffer.GetInt32;
    ProbeOrbitCount := Buffer.GetByte;
    if GlobalsV.LoadedSaveVersion >= 99 then HasPlayerLanded := Buffer.GetBoolean
    else HasPlayerLanded := False;
    Stage := 1;
    for Track := Low(TPlanetInvention) to High(TPlanetInvention) do
      if GlobalsV.LoadedSaveVersion <= 90 then
      begin
        Buffer.GetByte;
        InventionLevels[Track] := Buffer.GetByte;
        if Track >= piIndustrialLaser then InventionLevels[Track] := Min(8, Integer(InventionLevels[Track]) * 2 - 1);
      end
      else InventionLevels[Track] := Buffer.GetByte;
    if GlobalsV.LoadedSaveVersion <= 90 then CurrentInvention := TPlanetInvention(Buffer.GetByte shr 1)
    else CurrentInvention := TPlanetInvention(Buffer.GetByte);
    CurrentInventionPoints := Buffer.GetSingle;
    ResearchLevelPercent := Buffer.GetByte;
    ResearchLevelStep := Buffer.GetByte;
    Population := Buffer.GetUInt32;
    Economy := TPlanetEconomy(Buffer.GetByte);
    Money := Buffer.GetUInt32;
    OwnerId := TOwnerId(Buffer.GetByte);
    RaceId := TOwnerId(Buffer.GetByte);
    Government := TPlanetGovernment(Buffer.GetByte);
    if GlobalsV.LoadedSaveVersion < 96 then Buffer.GetByte;
    Stage := 2;
    for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    begin
      Goods[Good].Count := Buffer.GetInt32;
      Goods[Good].PriceState := Buffer.GetSingle;
      Goods[Good].PurchasePrice := Buffer.GetInt32;
      Goods[Good].BaseSalePrice := Buffer.GetInt32;
      GoodsScarcityTicks[Good] := Buffer.GetByte;
      GoodsSurplusTicks[Good] := Buffer.GetByte;
    end;
    Stage := 3;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise SysUtils.EAbort.Create('Err');
    for i := 0 to Count - 1 do RangerRelations.Add(Pointer(Buffer.GetByte));
    Stage := 4;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise SysUtils.EAbort.Create('Err');
    for i := 0 to Count - 1 do
    begin
      Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
      EquipmentShop.Add(Item);
      Item.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 5;
    Count := Buffer.GetWord;
    if (Count < 0) or (Count > MaxSavedListCount) then raise SysUtils.EAbort.Create('Err');
    for i := 0 to Count - 1 do
    begin
      ShipType := TShipType(Buffer.GetByte);
      Ship := CreateShipByType(ShipType);
      Warriors.Add(Ship);
      Ship.CurrentStar := CurrentStar;
      Ship.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 6;
    HomeRangerCount := Buffer.GetWord;
    HomeTransportCount := Buffer.GetWord;
    Buffer.GetWord;
    if GlobalsV.LoadedSaveVersion < 144 then Buffer.GetWord;
    Buffer.GetWord;
    Buffer.GetWord;
    Stage := 7;
    GraphicRadius := Buffer.GetWord;
    GraphName := Buffer.ReadWideString;
    RetainSpaceObject(TObjectSE(Graphic), CreateSpaceObjectByName('Planet', GraphName, Classes.Point(0, 0)));
    Graphic.SetPosition(PolarToPoint(Orbit));
    Graphic.SetRotationTimerInterval(Buffer.GetWord);
    Stage := 8;
    Graphic.SetSurfaceMapStep(Buffer.GetInt32);
    Graphic.OrbitalVelocity := OrbitalVelocity;
    Graphic.SetRingKind(Buffer.GetByte);
    TextQuestId := Buffer.GetInt32;
    Stage := 9;
    Count := Buffer.GetWord;
    for i := 0 to Count - 1 do
    begin
      Satellite := TSputnik.Create;
      Satellite.LoadFromBuffer(Buffer, Galaxy);
      Satellites.Add(Satellite);
    end;
    Stage := 10;
    Count := Buffer.GetWord;
    if (Count > 0) and (SurfaceLootEntries = nil) then SurfaceLootEntries := TList.Create;
    Stage := 11;
    for i := 0 to Count - 1 do
    begin
      System.GetMem(Entry, SizeOf(TPlanetSurfaceLootEntry));
      SurfaceLootEntries.Add(Entry);
      Entry.GridX := Buffer.GetByte;
      Entry.GridY := Buffer.GetByte;
      Entry.TerrainKind := TPlanetTerrainKind(Buffer.GetByte);
      Entry.SurfaceTileIndex := Buffer.GetInt32;
      Entry.Unavailable := Buffer.GetBoolean;
      Entry.Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
      Entry.Item.LoadFromBuffer(Buffer, Galaxy);
    end;
    Stage := 12;
    NoLanding := Buffer.GetBoolean;
    if GlobalsV.LoadedSaveVersion >= 83 then ShopUpdateMode := Buffer.GetByte
    else ShopUpdateMode := 0;
    NoAutomaticShipSpawning := ShopUpdateMode and 4 > 0;
    NoRandomEvents := ShopUpdateMode and 8 > 0;
    ShopUpdateMode := ShopUpdateMode and 3;
    IsMainPiratePlanet := Buffer.GetBoolean;
    if IsMainPiratePlanet then MainPiratePlanet := Self;
    if GlobalsV.LoadedSaveVersion >= 166 then CustomFaction := Buffer.ReadWideString;
  except
    on E: SysUtils.Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise SysUtils.Exception.Create('Error in procedure TPlanet.Load, label = ' + SysUtils.IntToStr(Stage));
    end;
  end;
end;
{ @end $7857C0 }

{ @routine $7861A4 TPlanet_SaveToBlock }
procedure TPlanet.SaveToBlock(Block: TBlockParEC);
var
  i: Integer;
  Text: WideString;
  Ship: TShip;
  Entry: PPlanetSurfaceLootEntry;
  Item: TItem;
  Slot: TShopSlot;
begin
  Block.AddParam(DecodeTextW('Pul4awnre2taNgarmEes'), Name); // 'PlanetName'
  Block.AddParam(DecodeTextW('OpwRn3ewr'), aConst.OwnerInfo[OwnerId].InternalName); // 'Owner'
  Block.AddParam(DecodeTextW('Rja6cEe'), aConst.OwnerInfo[RaceToOwner(RaceId)].InternalName); // 'Race'
  Block.AddParam(DecodeTextW('Elc0o5neowmWyq'), aConst.PlanetEconomyInfo[Economy].InternalName); // 'Economy'
  Block.AddParam(DecodeTextW('GLotvUecrBmnemn7t'), aConst.PlanetGovernmentMarket[Government].InternalName); // 'Goverment'
  Block.AddParam(DecodeTextW('ItSaiNzze'), SysUtils.IntToStr(Radius)); // 'ISize'
  Block.AddParam(DecodeTextW('OcrublietyRnakdlipuns'), SysUtils.FloatToStr(Orbit.Radius)); // 'OrbitRadius'
  Block.AddParam(DecodeTextW('OsrabniktuAinegilne'), SysUtils.FloatToStr(Orbit.AngleDegrees)); // 'OrbitAngle'
  Block.AddParam(DecodeTextW('Rpe7lyamtgi4oendThokP4lWasyfeKry'), SysUtils.IntToStr(Byte(RangerRelations[0]))); // 'RelationToPlayer'
  Block.AddParam(DecodeTextW('IsMraliunaTrepcohaLienvuelle'), SysUtils.IntToStr(InventionLevels[piMainTech])); // 'IMainTechLevel'
  Text := SysUtils.IntToStr(InventionLevels[piHull]);
  for i := Ord(piFuelTanks) to Ord(High(TPlanetInvention)) do Text := Text + ',' + SysUtils.IntToStr(InventionLevels[TPlanetInvention(i)]);
  Block.AddParam(DecodeTextW('Toe5cfh2LSexvNejlusw'), Text); // 'TechLevels'
  Block.AddParam(DecodeTextW('C2u4rrrTeengtyIwnsvgeEn6tjieodn'), SysUtils.IntToStr(Ord(CurrentInvention))); // 'CurrentInvention'
  Block.AddParam(DecodeTextW('CluurtreewnstQIvnhv6eenwtfijo6ntPwoSirn5tts7'), SysUtils.FloatToStr(CurrentInventionPoints)); // 'CurrentInventionPoints'
  with Block.AddBlockByPath(DecodeTextW('EdqeSahloEp')) do // 'EqShop'
  begin
    if (EquipmentShop <> nil) and (EquipmentShop.Count > 0) then
    begin
      for i := 0 to EquipmentShop.Count - 1 do
      begin
        Item := EquipmentShop[i];
        Text := DecodeTextW('ImtreamrIodo') + SysUtils.IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.SaveToBlock(AddBlockByPath(Text));
      end;
    end
    else if GetPlayer.CurrentPlanet = Self then
      if fEquipmentShop.TemporaryShopSlots <> nil then
        for i := 0 to fEquipmentShop.TemporaryShopSlots.Count - 1 do
        begin
          Slot := fEquipmentShop.TemporaryShopSlots[i];
          Item := Slot.Item;
          if Item <> nil then
          begin
            Text := DecodeTextW('ImtreamrIodo') + SysUtils.IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
            Item.SaveToBlock(AddBlockByPath(Text));
          end;
        end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
  Text := SysUtils.IntToStr(Goods[aConst.GoodsTextOrder[0]].Count);
  for i := 1 to 7 do Text := Text + ',' + SysUtils.IntToStr(Goods[aConst.GoodsTextOrder[Byte(i)]].Count);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesa'), Text); // 'ShopGoods'
  Text := SysUtils.IntToStr(Goods[aConst.GoodsTextOrder[0]].PurchasePrice);
  for i := 1 to 7 do Text := Text + ',' + SysUtils.IntToStr(Goods[aConst.GoodsTextOrder[Byte(i)]].PurchasePrice);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesaSrakloe'), Text); // 'ShopGoodsSale'
  Text := SysUtils.IntToStr(Goods[aConst.GoodsTextOrder[0]].BaseSalePrice);
  for i := 1 to 7 do Text := Text + ',' + SysUtils.IntToStr(Goods[aConst.GoodsTextOrder[Byte(i)]].BaseSalePrice);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesaBruhy'), Text); // 'ShopGoodsBuy'
  with Block.AddBlockByPath(DecodeTextW('GlamrirLihsaoln')) do // 'Garrison'
  begin
    for i := 0 to Warriors.Count - 1 do
    begin
      Ship := Warriors[i];
      if Ship.CurrentStar.Ships.IndexOf(Ship) < 0 then
      begin
        Text := DecodeTextW('WfajrRrkiSo4rgImd5') + SysUtils.IntToStr(Int64(Cardinal(Ship.Id))); // 'WarriorId'
        Ship.SaveToBlock(AddBlockByPath(Text));
      end;
    end;
  end;
  Block.AddParam(DecodeTextW('WuartTewrfSgpwaQcde'), SysUtils.IntToStr(WaterTiles)); // 'WaterSpace'
  Block.AddParam(DecodeTextW('WbantderrwCSofmgpUlkaltwef'), SysUtils.IntToStr(WaterExplored)); // 'WaterComplate'
  Block.AddParam(DecodeTextW('LLagnsd3SwpFascge4'), SysUtils.IntToStr(LandTiles)); // 'LandSpace'
  Block.AddParam(DecodeTextW('LgaEnwdsCfogmHpjlya5tre'), SysUtils.IntToStr(LandExplored)); // 'LandComplate'
  Block.AddParam(DecodeTextW('HbiFldleSrptaycue'), SysUtils.IntToStr(HillTiles)); // 'HillSpace'
  Block.AddParam(DecodeTextW('HninlglnCfodmFpflFastee'), SysUtils.IntToStr(HillExplored)); // 'HillComplate'
  Block.AddParam(DecodeTextW('OyrebwiftlCknstx'), SysUtils.IntToStr(ProbeOrbitCount)); // 'OrbitCnt'
  with Block.AddBlockByPath(DecodeTextW('Sataokrgalgae')) do // 'Storage'
  begin
    for i := 0 to GetPlayer.StorageEntries.Count - 1 do
      if PStorageEntry(GetPlayer.StorageEntries[i]).LocationOwner = Self then
      begin
        Item := PStorageEntry(GetPlayer.StorageEntries[i]).Item;
        Text := DecodeTextW('ImtreamrIodo') + SysUtils.IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.SaveToBlock(AddBlockByPath(Text));
      end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
  with Block.AddBlockByPath(DecodeTextW('TurieKalsauOrden')) do // 'Treasure'
  begin
    if SurfaceLootEntries <> nil then
      for i := 0 to SurfaceLootEntries.Count - 1 do
      begin
        Entry := SurfaceLootEntries[i];
        Text := DecodeTextW('HyiIdedfehnjIytrewm') + SysUtils.IntToStr(i + 1); // 'HiddenItem'
        with AddBlockByPath(Text) do
        begin
          AddParam(DecodeTextW('LaawnedrTtyhpuei'), SysUtils.IntToStr(Ord(Entry.TerrainKind))); // 'LandType'
          AddParam(DecodeTextW('DjetpEtwh'), SysUtils.IntToStr(Entry.SurfaceTileIndex)); // 'Depth'
          Entry.Item.SaveToBlock(AddBlockByPath(DecodeTextW('IrtteEmtIIdy') + SysUtils.IntToStr(Int64(Cardinal(Entry.Item.Id))))); // 'ItemId'
        end;
      end;
    AddParam(DecodeTextW('Cur5erawtre3NregwgHjikdHdgern4IFthejm6'), ''); // 'CreateNewHiddenItem'
  end;
  Block.AddParam(DecodeTextW('CorFedaWtaesNfeTwgShhji6pw'), ''); // 'CreateNewShip'
end;
{ @end $7861A4 }

{ @routine $78785C TPlanet_LoadFromBlock }
procedure TPlanet.LoadFromBlock(Block: TBlockParEC);
var
  i: Integer;
  Text, Part, ShipName: WideString;
  Ship: TShip;
  Entry: PPlanetSurfaceLootEntry;
  Item: TItem;
  ItemType: TItemType;
  ShipType: TShipType;
  Storage: PStorageEntry;
  Slot: TShopSlot;
  OldOwner, Owner, OldRace: TOwnerId;
  OldSeries, Series: TDominatorSeries;
begin
  Name := Block.GetParam(DecodeTextW('Pul4awnre2taNgarmEes')); // 'PlanetName'
  Text := Block.GetParam(DecodeTextW('OpwRn3ewr')); // 'Owner'
  for i := 0 to 7 do if Text = aConst.OwnerInfo[TOwnerId(i)].InternalName then OwnerId := TOwnerId(i);
  Text := Block.GetParam(DecodeTextW('Rja6cEe')); // 'Race'
  for i := 0 to 4 do if Text = aConst.OwnerInfo[TOwnerId(i)].InternalName then RaceId := TOwnerId(i);
  Text := Block.GetParam(DecodeTextW('Elc0o5neowmWyq')); // 'Economy'
  for i := 0 to 2 do if Text = aConst.PlanetEconomyInfo[TPlanetEconomy(i)].InternalName then Economy := TPlanetEconomy(i);
  Text := Block.GetParam(DecodeTextW('GLotvUecrBmnemn7t')); // 'Goverment'
  for i := 0 to 4 do if Text = aConst.PlanetGovernmentMarket[TPlanetGovernment(i)].InternalName then Government := TPlanetGovernment(i);
  Orbit.Radius := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('OcrublietyRnakdlipuns'))); // 'OrbitRadius'
  Orbit.AngleDegrees := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('OsrabniktuAinegilne'))); // 'OrbitAngle'
  RangerRelations[0] := Pointer(SysUtils.StrToInt(Block.GetParam(DecodeTextW('Rpe7lyamtgi4oendThokP4lWasyfeKry')))); // 'RelationToPlayer'
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesa')); // 'ShopGoods'
  for i := 0 to 7 do Goods[aConst.GoodsTextOrder[Byte(i)]].Count := SysUtils.StrToInt(ExtractDelimitedPartW(Text, i, ','));
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesaSrakloe')); // 'ShopGoodsSale'
  for i := 0 to 7 do Goods[aConst.GoodsTextOrder[Byte(i)]].PurchasePrice := SysUtils.StrToInt(ExtractDelimitedPartW(Text, i, ','));
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesaBruhy')); // 'ShopGoodsBuy'
  for i := 0 to 7 do Goods[aConst.GoodsTextOrder[Byte(i)]].BaseSalePrice := SysUtils.StrToInt(ExtractDelimitedPartW(Text, i, ','));
  with Block.GetBlockByPath(DecodeTextW('EdqeSahloEp')) do // 'EqShop'
  begin
    if (EquipmentShop <> nil) and (EquipmentShop.Count > 0) then
    begin
      for i := 0 to EquipmentShop.Count - 1 do
      begin
        Item := EquipmentShop[i];
        Text := DecodeTextW('ImtreamrIodo') + SysUtils.IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.LoadFromBlock(GetBlockByPath(Text));
      end;
    end
    else if GetPlayer.CurrentPlanet = Self then
      if fEquipmentShop.TemporaryShopSlots <> nil then
        for i := 0 to fEquipmentShop.TemporaryShopSlots.Count - 1 do
        begin
          Slot := fEquipmentShop.TemporaryShopSlots[i];
          Item := Slot.Item;
          if Item <> nil then
          begin
            Text := DecodeTextW('ImtreamrIodo') + SysUtils.IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
            Item.LoadFromBlock(GetBlockByPath(Text));
          end;
        end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for i := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, i, ',');
      for ItemType := t_Food to t_UselessCountableItem do
        if aConst.ItemTypeNames[ItemType] = Part then
        begin
          if ItemType in [t_Hull..t_CustomWeapon] then
          begin
            Item := CreateDefaultItemByType(ItemType);
            if Item <> nil then
            begin
              if (fEquipmentShop.TemporaryShopSlots <> nil) and (fEquipmentShop.TemporaryShopPlanet = Self) then
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
  end;
  with Block.GetBlockByPath(DecodeTextW('Sataokrgalgae')) do // 'Storage'
  begin
    for i := 0 to GetPlayer.StorageEntries.Count - 1 do
      if PStorageEntry(GetPlayer.StorageEntries[i]).LocationOwner = Self then
      begin
        Item := PStorageEntry(GetPlayer.StorageEntries[i]).Item;
        Text := DecodeTextW('ImtreamrIodo') + SysUtils.IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.LoadFromBlock(GetBlockByPath(Text));
      end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for i := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, i, ',');
      for ItemType := t_Food to t_UselessCountableItem do
        if aConst.ItemTypeNames[ItemType] = Part then
        begin
          if (ItemType in [t_Food..t_Narcotics]) or (ItemType in [t_Hull..t_CustomWeapon]) or
            (ItemType in [t_ArtefactHull..t_ArtFastRacks]) or (ItemType in [t_Protoplasm..t_Satellite]) then
          begin
            Item := CreateDefaultItemByType(ItemType);
            if Item <> nil then
            begin
              System.GetMem(Storage, SizeOf(TStorageEntry));
              Storage.LocationOwner := Self;
              Storage.SlotIndex := GetPlayer.FindNextStorageSlot(Self);
              Storage.Item := Item;
              GetPlayer.StorageEntries.Add(Storage);
              GetPlayer.RefreshStorageBubbles;
            end;
          end;
          Break;
        end;
    end;
  end;
  Text := Block.GetParam(DecodeTextW('Toe5cfh2LSexvNejlusw')); // 'TechLevels'
  for i := Ord(Low(TPlanetInvention)) to Ord(High(TPlanetInvention)) do InventionLevels[TPlanetInvention(i)] := SysUtils.StrToInt(ExtractDelimitedPartW(Text, i, ','));
  CurrentInvention := TPlanetInvention(SysUtils.StrToInt(Block.GetParam(DecodeTextW('C2u4rrrTeengtyIwnsvgeEn6tjieodn')))); // 'CurrentInvention'
  CurrentInventionPoints := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('CluurtreewnstQIvnhv6eenwtfijo6ntPwoSirn5tts7'))); // 'CurrentInventionPoints'
  with Block.GetBlockByPath(DecodeTextW('GlamrirLihsaoln')) do // 'Garrison'
  begin
    for i := 0 to Warriors.Count - 1 do
    begin
      Ship := Warriors[i];
      if Ship.CurrentStar.Ships.IndexOf(Ship) < 0 then
      begin
        Text := DecodeTextW('WfajrRrkiSo4rgImd5') + SysUtils.IntToStr(Int64(Cardinal(Ship.Id))); // 'WarriorId'
        Ship.LoadFromBlock(GetBlockByPath(Text));
      end;
    end;
  end;
  WaterTiles := SysUtils.StrToInt(Block.GetParam(DecodeTextW('WuartTewrfSgpwaQcde'))); // 'WaterSpace'
  WaterExplored := SysUtils.StrToInt(Block.GetParam(DecodeTextW('WbantderrwCSofmgpUlkaltwef'))); // 'WaterComplate'
  LandTiles := SysUtils.StrToInt(Block.GetParam(DecodeTextW('LLagnsd3SwpFascge4'))); // 'LandSpace'
  LandExplored := SysUtils.StrToInt(Block.GetParam(DecodeTextW('LgaEnwdsCfogmHpjlya5tre'))); // 'LandComplate'
  HillTiles := SysUtils.StrToInt(Block.GetParam(DecodeTextW('HbiFldleSrptaycue'))); // 'HillSpace'
  HillExplored := SysUtils.StrToInt(Block.GetParam(DecodeTextW('HninlglnCfodmFpflFastee'))); // 'HillComplate'
  ProbeOrbitCount := SysUtils.StrToInt(Block.GetParam(DecodeTextW('OyrebwiftlCknstx'))); // 'OrbitCnt'
  with Block.GetBlockByPath(DecodeTextW('TurieKalsauOrden')) do // 'Treasure'
  begin
    if SurfaceLootEntries <> nil then
      for i := 0 to SurfaceLootEntries.Count - 1 do
      begin
        Entry := SurfaceLootEntries[i];
        Text := DecodeTextW('HyiIdedfehnjIytrewm') + SysUtils.IntToStr(i + 1); // 'HiddenItem'
        with GetBlockByPath(Text) do
        begin
          Entry.TerrainKind := TPlanetTerrainKind(SysUtils.StrToInt(GetParam(DecodeTextW('LaawnedrTtyhpuei')))); // 'LandType'
          Entry.SurfaceTileIndex := SysUtils.StrToInt(GetParam(DecodeTextW('DjetpEtwh'))); // 'Depth'
          Entry.Item.LoadFromBlock(GetBlockByPath(DecodeTextW('IrtteEmtIIdy') + SysUtils.IntToStr(Int64(Cardinal(Entry.Item.Id))))); // 'ItemId'
        end;
      end;
    Text := GetParam(DecodeTextW('Cur5erawtre3NregwgHjikdHdgern4IFthejm6')); // 'CreateNewHiddenItem'
    for i := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Part := ExtractDelimitedPartW(Text, i, ',');
      for ItemType := t_Food to t_UselessCountableItem do
        if aConst.ItemTypeNames[ItemType] = Part then
        begin
          if ItemType in [t_Food..t_Narcotics, t_ArtefactHull..t_Satellite] then
            if ItemType <> t_Hull then
            begin
              Item := CreateDefaultItemByType(ItemType);
              if Item <> nil then
              begin
                AddSurfaceLootEntry(Item);
              end;
            end;
          Break;
        end;
    end;
  end;
  Text := Block.GetParam(DecodeTextW('CorFedaWtaesNfeTwgShhji6pw')); // 'CreateNewShip'
  for i := 0 to CountDelimitedPartsW(Text, ',') - 1 do
  begin
    Part := ExtractDelimitedPartW(Text, i, ',');
    ShipName := ExtractDelimitedPartW(Part, 0, '.');
    OldOwner := OwnerId;
    OldRace := RaceId;
    OldSeries := CurrentStar.DominatorSeries;
    if CountDelimitedPartsW(Part, '.') > 1 then
    begin
      Part := ExtractDelimitedPartW(Part, 1, '.');
      for Series := dsBlazer to dsTerron do
        if aConst.DominatorSeriesNames[Ord(Series)] = Part then CurrentStar.DominatorSeries := Series;
      for Owner := oiMaloc to oiPirate do
        if aConst.OwnerInfo[Owner].InternalName = Part then
        begin
          OwnerId := Owner;
          if Owner in aConst.PlanetOwnerMasks.Coalition then RaceId := OwnerToRace(Owner);
        end;
    end;
    for ShipType := Low(TShipType) to High(TShipType) do
      if aConst.ShipTypeNames[ShipType].Name = ShipName then
      begin
        case ShipType of
          stKling: SpawnWeightedDominatorShip;
          stRanger: BuyRanger(100);
          stTransport: SpawnTransport(0, 100);
          stPirate: BuyPirate(100);
          stWarrior: BuyWarrior(100);
          stTranclucator: SpawnTranclucator(True);
        end;
        Break;
      end;
    CurrentStar.DominatorSeries := OldSeries;
    OwnerId := OldOwner;
    RaceId := OldRace;
  end;
end;
{ @end $78785C }

{ @routine $789148 TPlanet_ResolveLoadedReferences }
procedure TPlanet.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  Ship: TShip;
  i, Count: Integer;
  Item: TItem;
  Entry: PPlanetSurfaceLootEntry;
begin
  Count := EquipmentShop.Count;
  for i := 0 to Count - 1 do
  begin
    Item := EquipmentShop[i];
    Item.ResolveLoadedReferences(Galaxy);
  end;
  if (GlobalsV.LoadedSaveVersion < 106) and IsMainPiratePlanet then
    for i := Count - 1 downto 0 do
    begin
      Item := EquipmentShop[i];
      if (Item is TEquipment) and
        ((Item as TEquipment).SpecialModuleIndex > 0) and
        (not (rstPirateBase in aConst.MicroModuleTemplates[(Item as TEquipment).SpecialModuleIndex - 1].OfferStationTypes)) then
      begin
        EquipmentShop.Delete(i);
        Item.Free;
      end;
    end;
  Count := Warriors.Count;
  for i := 0 to Count - 1 do
  begin
    Ship := Warriors[i];
    Ship.ResolveLoadedReferences(Galaxy);
  end;
  if SurfaceLootEntries <> nil then
    for i := 0 to SurfaceLootEntries.Count - 1 do
    begin
      Entry := SurfaceLootEntries[i];
      Entry.Item.ResolveLoadedReferences(Galaxy);
    end;
  UpdateOwnerFlags;
end;
{ @end $789148 }

{ @routine $7892F0 TPlanet_TrySpawnDominator }
function TPlanet.TrySpawnDominator: Pointer;
var
  i, SeriesStars, ShipCount, Jitter, MaximumShips, Chance, Delay, BaseDelay: Integer;
  Control, SeriesControl, ControlThreshold: Byte;
  Star: TStar;
begin
  Result := nil;
  if CurrentStar.DominatorSeries = dsTerron then
  begin
    if (aKling.TerronShip = nil) or (aGalaxy.Galaxy.TerronGrowLockTurn <> 0) or
      (aGalaxy.Galaxy.TerronToStarTurn >= TerronTransformationFlag) then Exit;
  end
  else if CurrentStar.DominatorSeries = dsBlazer then
    if (aKling.BlazerShip = nil) or (aGalaxy.Galaxy.BlazerLandingPlanetId <> 0) or
      aKling.BlazerShip.DestroyQueued then Exit;
  Control := aGalaxy.Galaxy.GetFactionControlPercent(sfDominators);
  SeriesStars := 0;
  for i := 0 to aGalaxy.Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(aGalaxy.Galaxy.Stars[i]);
    if (Star.ControlFaction = sfDominators) and (CurrentStar.DominatorSeries = Star.DominatorSeries) and
      (Star.Status.CustomFaction = '') then Inc(SeriesStars);
  end;
  SeriesControl := System.Round(SeriesStars / aGalaxy.Galaxy.Stars.Count * 100);
  MaximumShips := 10;
  case CurrentStar.DominatorSeries of
    dsKeller: MaximumShips := 15;
    dsBlazer: MaximumShips := 13;
    dsTerron: MaximumShips := 11;
  end;
  Jitter := SeededRandomIntRange(0, 5, GenerationSeed + aGalaxy.Galaxy.CurrentTurn div 500);
  MaximumShips := System.Round(RemapClamped(SeriesControl, 0, 33, MaximumShips, 10)) + Jitter -
    System.Round(RemapClamped(SeriesControl, 34, 100, 0, 3)) +
    System.Round(RemapClamped(aGalaxy.Galaxy.GetDominatorSeriesControlShare(CurrentStar.DominatorSeries), 0, 1, 3, 0));
  Chance := 0;
  case CurrentStar.DominatorSeries of
    dsKeller: Chance := 20;
    dsBlazer: Chance := 40;
    dsTerron: Chance := 60;
  end;
  ControlThreshold := System.Round(RemapClamped(aGalaxy.Galaxy.CurrentTurn, GalaxyWarmupTurns, 11250, 40, 80));
  Chance := System.Round(RemapClamped(Control, 0, ControlThreshold, Chance * 0.5, 0) +
    RemapClamped(Control, ControlThreshold, 100, Chance * 0.5, 1));
  if CurrentStar.Battle <> 0 then Inc(Chance, 10);
  BaseDelay := System.Round(aGalaxy.Galaxy.ScaleDifficultyExponentially(aGalaxy.Galaxy.GetDominatorSpawnLevel, 81, 0.333));
  Delay := System.Round(RemapClamped(Control, 0, ControlThreshold, 1, BaseDelay * 0.5) +
    RemapClamped(Control, ControlThreshold, 100, 0, BaseDelay * 0.5));
  if aGalaxy.Galaxy.CurrentTurn >= 666 then
    if aGalaxy.Galaxy.DominatorModLevel = 1 then
    begin Chance := 70; Delay := 3; MaximumShips := 15; end
    else if aGalaxy.Galaxy.DominatorModLevel = 2 then
    begin Chance := 85; Delay := 2; MaximumShips := 15; end
    else if aGalaxy.Galaxy.DominatorModLevel = 3 then
    begin Chance := 100; Delay := 1; MaximumShips := 15; end;
  ShipCount := CurrentStar.CountStandardDominatorsOfLocalSeries;
  if ShipCount = 0 then Chance := Max(Int64(1), System.Round(Chance * 0.2));
  if (CurrentStar.DaysSinceLastNpcShipSpawn > Delay) and
    (NextRandomIntRange(1, 100, RandomState) <= Chance) and (ShipCount < MaximumShips) then
    Result := SpawnWeightedDominatorShip;
end;
{ @end $7892F0 }

{ @routine $789844 TPlanet_NextDay }
procedure TPlanet.NextDay;
var
  Good: Byte;
  I, N: Integer;
  Strength: Extended;
  Ship: TShip;
  PirateSpawnFactor, GarrisonSpawnFactor, PirateLimitFactor, GarrisonLimitFactor: Double;
  Boost, Budget, SystemRatio: Double;
  PirateKills, ClanShips, IndependentShips: Integer;
  NearbyStar: TStar;
begin
  if GetPlayer = nil then Exit;
  I := 4; // Native diagnostic-era assignment, overwritten by the later loops.
  Orbit.AngleDegrees := WrapHeadingDegrees(Orbit.AngleDegrees);
  if aGalaxy.Galaxy.SpecialSimulationMode <> 0 then Exit;
  if (OwnerId <> oiUninhabited) and (CurrentStar.Status.CustomFaction <> '') then
  begin
    if NextRandomUnitFloat(RandomState) < 0.7 then AdvanceInventionProgress;
    Exit;
  end;
  try
    case OwnerId of
      oiMaloc..oiGaal:
      begin
        // Native growth adds 300 even when already above the radius-based population.
        if CalculateBasePopulation < Population then Inc(Population, 300)
        else Inc(Population, Trunc(Population * 0.02));
        TryTriggerEconomicEvent;
        UpdateMarketState;
        Inc(Money, Trunc(Population * 0.001));
        if not IsMainPiratePlanet and not NoAutomaticShipSpawning then
        begin
          if CurrentStar.Constellation.Id <> 20 then
          begin
            if (aGalaxy.Galaxy.CountEligibleRangers < Min(aGalaxy.Galaxy.CountFactionStars(sfCoalition) * 1.5, 63) +
                aGalaxy.Galaxy.GetExtraRangerCount) and
               (CurrentStar.CountEligibleRangersInSpace < aGalaxy.Galaxy.GetExtraRangerCount + 1) and
               (NextRandomUnitFloat(RandomState) < 0.04) then BuyRanger(100);
            if (CurrentStar.ShipTypeCounts[stTransport] < 5) and
               (aGalaxy.Galaxy.CountFactionStars(sfPirates) * 3 +
                aGalaxy.Galaxy.CountFactionStars(sfCoalition) * 9 > aGalaxy.Galaxy.TransportCount) and
               (NextRandomUnitFloat(RandomState) < 0.05) and (HomeTransportCount < 2) then SpawnTransport(0, 100);
            if (CurrentStar.ShipTypeCounts[stPirate] < 2) and
               (aGalaxy.Galaxy.CountFactionStars(sfCoalition) > aGalaxy.Galaxy.PirateCount) then
              if NextRandomUnitFloat(RandomState) < Sqr(aConst.PlanetRaceMarket[RaceId].PirateRelationFactor / 10) then
                BuyPirate(100);
          end;
          if aGalaxy.Galaxy.CountFactionStars(sfCoalition) > 1 then N := 1 else N := 2;
          if NextRandomUnitFloat(RandomState) < 0.01 * N then
            if Warriors.Count < RemapClamped(Radius, 60, 100, 1, 3) * N then
              BuyWarrior(100)
            else if (aGalaxy.Galaxy.RangerSpawnQuotas[RaceId] > 0) and
                    (NextRandomUnitFloat(RandomState) < 0.1) then BuyFlagship(200);
        end;
        AdvanceInventionProgress;
        RefreshEquipmentShopInventory;
        if HasHostileShipsInSystem then
        begin
          for I := 0 to Warriors.Count - 1 do
          begin
            Ship := TShip(Warriors[I]);
            if Ship.CurrentPlanet = Self then
            begin
              if CurrentStar.Ships.IndexOf(Ship) = -1 then CurrentStar.Ships.Add(Ship);
              if not Ship.RepairHullAtLocation then Ship.OrderTakeoff;
            end;
          end;
        end
        else
          for I := Warriors.Count - 1 downto 0 do
          begin
            Ship := TShip(Warriors[I]);
            if (Ship.ScriptShip = nil) and (Ship.LiberationGroup = nil) and (Ship.CurrentPlanet = Self) then
            begin
              N := CurrentStar.Ships.IndexOf(Ship);
              if N >= 0 then
              begin
                CurrentStar.Ships.Delete(N);
                Ship.EnemyShip := nil;
                Ship.TruceShip := nil;
                Ship.PartnerShip := nil;
                Ship.GetHull.HullPoints := Ship.GetHull.Weight;
              end
              else
              begin
                if NextRandomUnitFloat(RandomState) < 0.2 then Ship.BuyEquipmentAtLocation(False);
                if NextRandomUnitFloat(RandomState) < 0.02 then
                begin
                  Ship.RefreshDerivedStats(True);
                  if (Ship.Wealth < aGalaxy.Galaxy.MaxRangerWealth * 0.3) or (Ship.StrengthInAverageRanger < 0.7) then
                    if NextRandomUnitFloat(RandomState) < 0.8 then
                      Ship.SetMoney(Ship.Money + Max(1000, Min(5000, aGalaxy.Galaxy.MaxRangerWealth div 15)))
                    else
                      Ship.SetMoney(Ship.Money + Max(2000, Min(10000, aGalaxy.Galaxy.MaxRangerWealth div 7)));
                  if (aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition) <= 5) and
                     (Ship.Wealth < aGalaxy.Galaxy.MaxRangerWealth * 0.6) then
                    Ship.SetMoney(Ship.Money + Max(3000, Min(15000, aGalaxy.Galaxy.MaxRangerWealth div 7)));
                  Ship.RestoreEssentialEquipment;
                  if (TWarrior(Ship).WarriorType <> wtFlagship) and
                     ((Ship.StrengthInBestRanger < 0.2) or (NextRandomUnitFloat(RandomState) < 0.1)) then
                    Ship.GenerateExtraWeapon;
                  if (Ship.StrengthInBestRanger < 0.5) and (NextRandomUnitFloat(RandomState) < 0.2) then
                    Ship.ImproveRandomEquipment(True);
                  if (Ship.StrengthInBestRanger < 0.3) and (NextRandomUnitFloat(RandomState) < 0.1) then
                  begin
                    Ship.GainExperience(NextRandomIntRange(500, 1500, RandomState), esUnscaled);
                    (Ship as TWarrior).TrainSkillsAutomatically;
                  end;
                  Ship.RefreshDerivedStats(True);
                end;
              end;
              if (aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition) <= 5) and (NextRandomUnitFloat(RandomState) < 0.05) then
                Ship.ImproveRandomEquipment(True);
              if (aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition) <= 2) and (NextRandomUnitFloat(RandomState) < 0.05) then
              begin
                Ship.BuyEquipmentAtLocation(False);
                Ship.RestoreEssentialEquipment;
                Ship.ImproveRandomEquipment(True);
              end;
              if TWarrior(Ship).IsHomePatrolTurn then
              begin
                Ship.BuyEquipmentAtLocation(False);
                Ship.BuyEquipmentAtLocation(False);
                CurrentStar.Ships.Add(Ship);
                Ship.OrderTakeoff;
                if TWarrior(Ship).WarriorType = wtFlagship then TWarrior(Ship).ReassignFlagshipHomePlanet;
              end;
            end;
          end;
      end;
      oiDominator:
      begin
        for Good := Low(TGoodsIndex) to High(TGoodsIndex) do Goods[Good].Count := 0;
        Money := 0;
        if NextRandomUnitFloat(RandomState) < 0.7 then AdvanceInventionProgress;
        if NextRandomUnitFloat(RandomState) < 0.2 then RefreshEquipmentShopInventory;
        if not NoAutomaticShipSpawning then TrySpawnDominator;
        if HasHostileShipsInSystem then
          for I := 0 to CurrentStar.Ships.Count - 1 do
          begin
            Ship := TShip(CurrentStar.Ships[I]);
            if Ship.CurrentPlanet = Self then Ship.OrderTakeoff;
          end;
      end;
      oiUninhabited: TryResetSurfaceLootAfterLongAbsence;
      oiPirate:
      begin
        if IsMainPiratePlanet and (aGalaxy.Galaxy.PirateWinType <> 3) then
        begin
          if (aGalaxy.Galaxy.GetFactionControlPercent(sfPirates) > Cardinal(aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition) * 2)) and
             (aGalaxy.Galaxy.GetFactionControlPercent(sfPirates) > 10) and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
            for I := 0 to aGalaxy.Galaxy.Rangers.Count - 1 do
            begin
              Ship := TShip(aGalaxy.Galaxy.Rangers[I]);
              if not TRanger(Ship).ExcludedFromRating and (Ship.OwnerId <> oiPirate) and not Ship.IsInPrison then
                ChangeRelationToRanger(Ship, -1);
            end;
          if (aGalaxy.Galaxy.GetFactionControlPercent(sfPirates) > Cardinal(aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition) * 4)) and
             (aGalaxy.Galaxy.GetFactionControlPercent(sfPirates) > 20) and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
            for I := 0 to aGalaxy.Galaxy.Rangers.Count - 1 do
            begin
              Ship := TShip(aGalaxy.Galaxy.Rangers[I]);
              if not TRanger(Ship).ExcludedFromRating and (Ship.OwnerId <> oiPirate) and not Ship.IsInPrison then
                ChangeRelationToRanger(Ship, -1);
            end;
          TryDispatchPirateAttacks;
          if not NoRandomEvents then TrySpawnPirateBaseRaid;
          Government := pgAnarchy;
          Economy := peIndustrial;
        end;
        // Native growth adds 300 even when already above the radius-based population.
        if CalculateBasePopulation < Population then Inc(Population, 300)
        else Inc(Population, Trunc(Population * 0.02));
        UpdateMarketState;
        Inc(Money, Trunc(Population * 0.001));
        PirateSpawnFactor := 1;
        GarrisonSpawnFactor := 1;
        PirateLimitFactor := 1;
        GarrisonLimitFactor := 1;
        if aGalaxy.Galaxy.CountFactionStars(sfPirates) > 0 then
          SystemRatio := aGalaxy.Galaxy.GetCoalitionToPirateSystemRatio
        else SystemRatio := 0;
        case aGalaxy.Galaxy.PirateWinType of
          0:
          begin
            PirateSpawnFactor := 1 + 0.125 * SystemRatio;
            GarrisonSpawnFactor := 1 + 0.125 * SystemRatio;
          end;
          1:
          begin
            PirateSpawnFactor := 1 - 0.125 * SystemRatio;
            GarrisonSpawnFactor := 1 + 0.375 * SystemRatio;
            PirateLimitFactor := 1 - 0.125 * SystemRatio;
            GarrisonLimitFactor := 1 + 0.375 * SystemRatio;
          end;
          2:
          begin
            PirateSpawnFactor := 1 + 0.375 * SystemRatio;
            GarrisonSpawnFactor := 1 - 0.125 * SystemRatio;
            PirateLimitFactor := 1 + 0.375 * SystemRatio;
            GarrisonLimitFactor := 1 - 0.125 * SystemRatio;
          end;
          3:
          begin
            PirateSpawnFactor := 1 - 0.125 * SystemRatio;
            GarrisonSpawnFactor := 1 - 0.25 * SystemRatio;
            PirateLimitFactor := 1 - 0.125 * SystemRatio;
            GarrisonLimitFactor := 1 - 0.25 * SystemRatio;
          end;
          5:
          begin
            PirateSpawnFactor := 1.25;
            GarrisonSpawnFactor := 1.125;
            PirateLimitFactor := 1.25;
            GarrisonLimitFactor := 1.125;
          end;
        end;
        case aGalaxy.Galaxy.DifficultyLevels[0] of
          0:
          begin
            PirateSpawnFactor := PirateSpawnFactor * 0.5;
            GarrisonSpawnFactor := GarrisonSpawnFactor * 0.5;
          end;
          1:
          begin
            PirateSpawnFactor := PirateSpawnFactor * 0.85;
            GarrisonSpawnFactor := GarrisonSpawnFactor * 0.85;
          end;
          2:
          begin
            PirateSpawnFactor := PirateSpawnFactor * 1;
            GarrisonSpawnFactor := GarrisonSpawnFactor * 1;
          end;
          3:
          begin
            PirateSpawnFactor := PirateSpawnFactor * 1.12;
            GarrisonSpawnFactor := GarrisonSpawnFactor * 1.12;
          end;
        else
          PirateSpawnFactor := PirateSpawnFactor * (1.12 + (aGalaxy.Galaxy.DifficultyLevels[0] - 3) * 0.12);
          GarrisonSpawnFactor := GarrisonSpawnFactor * (1.12 + (aGalaxy.Galaxy.DifficultyLevels[0] - 3) * 0.12);
        end;
        PirateLimitFactor := PirateLimitFactor * Min(2, 1 + 0.04 * SystemRatio * SystemRatio);
        GarrisonLimitFactor := GarrisonLimitFactor * Min(2, 1 + 0.04 * SystemRatio * SystemRatio);
        Budget := 200;
        if CurrentStar.Constellation.Id <> 20 then
        begin
          N := 0;
          for I := 1 to Min(10, aGalaxy.Galaxy.Stars.Count - 1) do
          begin
            NearbyStar := CurrentStar.StarDistances[I].Star;
            if (NearbyStar.ControlFaction = sfDominators) or (NearbyStar.Status.CustomFaction <> '') then Dec(N)
            else if NearbyStar.ControlFaction = sfCoalition then Inc(N, 2);
          end;
          PirateSpawnFactor := PirateSpawnFactor * RemapClamped(N, -10, 20, 0.5, 2);
          GarrisonSpawnFactor := GarrisonSpawnFactor * RemapClamped(N, -10, 20, 0.5, 2);
          PirateLimitFactor := PirateLimitFactor * RemapClamped(N, -10, 20, 0.8, 1.2);
          GarrisonLimitFactor := GarrisonLimitFactor * RemapClamped(N, -10, 20, 0.8, 1.2);
          Budget := RemapClamped(N, -10, 20, 50, 200);
        end;
        if (CurrentStar.Constellation.Id <> 20) or (GetPlayer.CurrentStar = CurrentStar) then
        begin
          PirateKills := 0;
          for I := 0 to CurrentStar.Ships.Count - 1 do
          begin
            Ship := TShip(CurrentStar.Ships[I]);
            if (Ship.OwnerId <> oiPirate) and (Ship is TNormalShip) then
              Inc(PirateKills, TNormalShip(Ship).CurrentSystemKills.Pirate);
          end;
          PirateSpawnFactor := PirateSpawnFactor * (1 - PirateKills / 15);
          GarrisonSpawnFactor := GarrisonSpawnFactor * (1 - PirateKills / 15);
        end;
        if CurrentStar.Battle <> 0 then
        begin
          PirateSpawnFactor := PirateSpawnFactor * 0.4;
          GarrisonSpawnFactor := GarrisonSpawnFactor * 0.4;
        end;
        if (CurrentStar.Id = aGalaxy.Galaxy.KellerResearchTargetStarId) and (KellerShip <> nil) then
        begin
          if (KellerShip.CurrentStar = CurrentStar) and not KellerShip.InHyperspace then
          begin
            if not NoAutomaticShipSpawning then TrySpawnDominator;
            AdvanceInventionProgress;
            for I := 0 to CurrentStar.Ships.Count - 1 do
            begin
              Ship := TShip(CurrentStar.Ships[I]);
              if (Ship.OwnerId = oiDominator) and (Ship.CurrentPlanet = Self) and
                 (NextRandomUnitFloat(RandomState) < 0.2) then
                Government := TPlanetGovernment(NextRandomIntRange(0, 4, RandomState));
            end;
          end;
        end
        else if not NoAutomaticShipSpawning then
        begin
          ClanShips := CurrentStar.CountPirateForces(False, Strength, False, True);
          IndependentShips := CurrentStar.CountPirateForces(False, Strength, True, False);
          PirateSpawnFactor := PirateSpawnFactor / Max(ClanShips / 9, 1);
          GarrisonSpawnFactor := GarrisonSpawnFactor / Max(IndependentShips / 21, 1);
          if (ClanShips < 3 * PirateLimitFactor) and
             (aGalaxy.Galaxy.PirateClanCount < (3 * PirateLimitFactor + 6 * GarrisonLimitFactor) *
               aGalaxy.Galaxy.CountFactionStars(sfPirates)) and
             (NextRandomUnitFloat(RandomState) < 0.02 * PirateSpawnFactor) then
          begin
            Ship := TShip(BuyPirate(Round(Budget)));
            if (CurrentStar.Constellation.Id = 20) and (aGalaxy.Galaxy.PirateWinType <> 3) then
            begin
              Boost := PirateLimitFactor;
              while Boost > 1 do
              begin
                Ship.ImproveRandomEquipment(True);
                Ship.GainExperience(Ship.TotalExperience div 7, esUnscaled);
                Ship.SetMoney((Ship.Money div 7) * 8);
                Boost := Boost * 0.85;
              end;
              (Ship as TNormalShip).TrainSkillsAutomatically;
              Ship.BuyEquipmentAtLocation(False);
              Ship.BuyEquipmentAtLocation(False);
              Ship.BuyEquipmentAtLocation(False);
            end;
          end;
          if (IndependentShips < 7 * GarrisonLimitFactor) and
             (NextRandomUnitFloat(RandomState) < 0.05 * GarrisonSpawnFactor) then
          begin
            Ship := TShip(BuyWarrior(Round(Budget)));
            if (CurrentStar.Constellation.Id = 20) and (aGalaxy.Galaxy.PirateWinType <> 3) then
            begin
              Boost := GarrisonLimitFactor;
              while Boost > 1 do
              begin
                Ship.ImproveRandomEquipment(True);
                Ship.GainExperience(Ship.TotalExperience div 7, esUnscaled);
                Ship.SetMoney((Ship.Money div 7) * 8);
                Boost := Boost * 0.85;
              end;
              (Ship as TNormalShip).TrainSkillsAutomatically;
              Ship.BuyEquipmentAtLocation(False);
              Ship.BuyEquipmentAtLocation(False);
              Ship.BuyEquipmentAtLocation(False);
            end;
          end;
          if (CurrentStar.Constellation.Id <> 20) and
             (CurrentStar.CountPirateForces(False, Strength, True, False) > 0) then
          begin
            if (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) and (CurrentStar.ShipTypeCounts[stTransport] < 5) and
               (aGalaxy.Galaxy.CountFactionStars(sfPirates) * 3 +
                aGalaxy.Galaxy.CountFactionStars(sfCoalition) * 9 > aGalaxy.Galaxy.TransportCount) and
               (NextRandomUnitFloat(RandomState) < 0.02) and (HomeTransportCount < 1) then SpawnTransport(0, 100);
            if (aGalaxy.Galaxy.CoalitionDefeatedTurn > 0) and (CurrentStar.ShipTypeCounts[stTransport] < 5) and
               (aGalaxy.Galaxy.CountFactionStars(sfPirates) * 5 > aGalaxy.Galaxy.TransportCount) and
               (NextRandomUnitFloat(RandomState) < 0.05) and (HomeTransportCount < 2) then SpawnTransport(0, 100);
          end;
        end;
        if (NextRandomUnitFloat(RandomState) < 0.85) or IsMainPiratePlanet then AdvanceInventionProgress;
        if (NextRandomUnitFloat(RandomState) < 0.5) or IsMainPiratePlanet then RefreshEquipmentShopInventory;
      end;
    end;
    if NextRandomUnitFloat(RandomState) < 0.01 then GenerationSeed := RandomState;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TPlanet.NextDay');
    end;
  end;
end;
{ @end $789844 }

{ @routine $78B9B4 TPlanet_TryDispatchPirateAttacks }
procedure TPlanet.TryDispatchPirateAttacks;
var
  TargetStar: TStar;
  Action, TargetPirates, EligibleShips: Integer;
  SourceStar: TStar;
  TargetOpposition: Integer;
  TargetPirateStrength, TargetOppositionStrength, SourcePirateStrength: Extended;
  Ship: TShip;
  DispatchLimit, ShipIndex, Dispatched: Integer;
  StarIndex, Attempts, NeighborIndex: Integer;
  ControlPercent: Byte;
  Chance, NeighborLimit, BaseChance, ControlLimit, MinimumFleet: Integer;
  SourceOppositionStrength: Extended;
  HasBlocker: Boolean;
  OtherPirates: Integer;

  // @nested $78B2F8 CalculatePirateAttackNeighborhoodFactor
  function CalculatePirateAttackNeighborhoodFactor(Star: TStar): Single; // @addr 0x78B2F8 @note "Nested in TryDispatchPirateAttacks; unused static link is caller-popped. Scores up to ten nearby stars and maps the score to 0.8..1.2."
  var
    Score, I: Integer;
    Neighbor: TStar;
  begin
    Score := 0;
    for I := 1 to Min(10, aGalaxy.Galaxy.Stars.Count - 1) do
    begin
      Neighbor := Star.StarDistances[I].Star;
      if (Neighbor.ControlFaction = sfDominators) or (Neighbor.Status.CustomFaction <> '') then Dec(Score)
      else if Neighbor.ControlFaction = sfCoalition then Inc(Score, 2);
    end;
    Result := RemapClamped(Score, -10, 20, 0.8, 1.2);
  end;

  // @nested $78B3C0 SelectAction
  procedure SelectAction; // @addr 0x78B3C0 @ida "void __cdecl $name(void *ParentFrame);" @note "Writes the captured action. Can replace action 1 with 2; otherwise a failed condition preserves the prior action."
  begin
    if TargetStar.ControlFaction = sfPirates then
    begin
      if TargetStar.Status.CustomFaction <> '' then
      begin
        Action := 0;
        Exit;
      end;
      if TargetPirates > 0 then
        if EligibleShips * CalculatePirateAttackNeighborhoodFactor(SourceStar) >
           TargetPirates * CalculatePirateAttackNeighborhoodFactor(TargetStar) * 4 then Action := 1;
      if (TargetPirates < TargetOpposition) or (TargetPirateStrength < TargetOppositionStrength) then Action := 2;
    end
    else
    begin
      if (TargetPirates > 0) and ((TargetPirates < TargetOpposition) or
         (TargetPirateStrength < TargetOppositionStrength) or (NextRandomIntRange(1, 100, RandomState) <= 5)) then
        Action := 3;
      if (TargetPirates = 0) and ((TargetOpposition < EligibleShips) or
         (TargetOppositionStrength < SourcePirateStrength) or
         ((MainPiratePlanet <> nil) and (SourceStar = MainPiratePlanet.CurrentStar))) then Action := 4;
    end;
  end;

  // @nested $78B52C IsShipEligible
  function IsShipEligible: Boolean; // @addr 0x78B52C @ida "bool __cdecl $name(void *ParentFrame);" @note "Current ship must be a TPirate owned by the clan, in normal space, without an absolute order, absolute script order, script binding or partner. Ordinary nonabsolute orders are allowed."
  begin
    Result := (Ship is TPirate) and (Ship.OwnerId = oiPirate) and not Ship.OrderAbsolute and
      (Ship.AbsoluteScriptOrder = 0) and Ship.InNormalSpace and (Ship.ScriptShip = nil) and (Ship.PartnerShip = nil);
  end;

  // @nested $78B5AC CountEligibleShips
  function CountEligibleShips: Integer; // @addr 0x78B5AC @ida "int __cdecl $name(void *ParentFrame);" @note "Counts eligible ships in the source star and overwrites the captured current-ship slot while scanning."
  var
    Count, I: Integer;
  begin
    Count := 0;
    I := 0;
    while I < SourceStar.Ships.Count do
    begin
      Ship := TShip(SourceStar.Ships[I]);
      Inc(I);
      if IsShipEligible then Inc(Count);
    end;
    Result := Count;
  end;

  // @nested $78B608 DispatchShips
  procedure DispatchShips; // @addr 0x78B608 @ida "void __cdecl $name(void *ParentFrame);" @note "Issues absolute jumps and increments RaidPressure. Action 4 can instead schedule an idle Dominion for CurrentTurn+10. May publish an ArtAnalyzer warning."
  var
    Quarter: Integer;
    Dominion: TRuins;
    Text: WideString;
  begin
    if (Action = 4) and (SourceStar.Dominion <> nil) and (TargetStar.ControlFaction = sfCoalition) then
    begin
      Dominion := TRuins(SourceStar.Dominion);
      if Dominion.InNormalSpace and (Dominion.Order = soNone) and (Dominion.ScriptShip = nil) and
         not Dominion.HasScriptControl and (Dominion.FlyToStar = nil) and
         (NextRandomIntRange(0, 100, RandomState) > 70) then
      begin
        Dominion.FlyToStar := TargetStar;
        Dominion.FlyDate := aGalaxy.Galaxy.CurrentTurn + 10;
        if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) and (TargetStar.Status.CustomFaction = '') then
        begin
          Text := FormatText1(LocalizedText('Artefacts.ArtAnalyzer.AttackPirates'),
            TextHighlightColorTag, '<Star>', TargetStar.Name);
          if Text <> '' then AddOrUpdatePlayerBubble(pmGalaxyNews, aGalaxy.Galaxy.CurrentTurn, Text, '');
        end;
        Exit;
      end;
    end;
    Quarter := EligibleShips div 4;
    if Action = 1 then DispatchLimit := Quarter else DispatchLimit := EligibleShips - Quarter;
    ShipIndex := 0;
    Dispatched := 0;
    while (ShipIndex < SourceStar.Ships.Count) and (Dispatched <= DispatchLimit) and (DispatchLimit > 0) do
    begin
      Ship := TShip(SourceStar.Ships[ShipIndex]);
      Inc(ShipIndex);
      if not IsShipEligible then Continue;
      Ship.OrderJump(TargetStar, True);
      TPirate(Ship).RaidPressure := TPirate(Ship).RaidPressure + 1;
      Inc(Dispatched);
    end;
    if (Action = 4) and (Dispatched > 0) and (TargetStar.ControlFaction = sfCoalition) then
      if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) and (TargetStar.Status.CustomFaction = '') then
      begin
        Text := FormatText1(LocalizedText('Artefacts.ArtAnalyzer.AttackPirates'),
          TextHighlightColorTag, '<Star>', TargetStar.Name);
        if Text <> '' then AddOrUpdatePlayerBubble(pmGalaxyNews, aGalaxy.Galaxy.CurrentTurn, Text, '');
      end;
  end;

begin
  if GetPlayer = nil then Exit;
  ControlPercent := aGalaxy.Galaxy.GetFactionControlPercent(sfPirates);
  BaseChance := Round(aGalaxy.Galaxy.ScaleDifficultyExponentially(aGalaxy.Galaxy.GetPirateAggressionLevel, 5, 2));
  ControlLimit := 15 + Round(aGalaxy.Galaxy.GetPirateAggressionLevel * 5 * 0.125);
  case aGalaxy.Galaxy.PirateWinType of
    1:
    begin
      BaseChance := BaseChance * 2;
      ControlLimit := ControlLimit * 2;
    end;
    2:
    begin
      BaseChance := Round(BaseChance * 0.75);
      ControlLimit := Round(ControlLimit * 1.5);
    end;
    3:
    begin
      BaseChance := 0;
      ControlLimit := 0;
    end;
    5:
    begin
      BaseChance := Round(BaseChance * 0.5);
      ControlLimit := Round(ControlLimit * 2);
    end;
  end;
  Chance := Round(RemapClamped(ControlPercent, 1, ControlLimit, BaseChance, 0));
  Chance := Round(Chance * RemapClamped(aGalaxy.Galaxy.WarDeltaWin[2], 0, 5, 1, 0.3));
  if Chance = 0 then Exit;
  MinimumFleet := 5;
  StarIndex := 0;
  while StarIndex < aGalaxy.Galaxy.Stars.Count do
  begin
    SourceStar := TStar(aGalaxy.Galaxy.Stars[StarIndex]);
    if SourceStar.Constellation.Id = 20 then NeighborLimit := 15 else NeighborLimit := 10;
    Inc(StarIndex);
    if (SourceStar.ControlFaction <> sfPirates) or (SourceStar.Status.CustomFaction <> '') or (SourceStar.Battle <> 0) then Continue;
    HasBlocker := False;
    OtherPirates := 0;
    for Attempts := 0 to SourceStar.Ships.Count - 1 do
    begin
      Ship := TShip(SourceStar.Ships[Attempts]);
      if Ship.CurrentStanding in [ssDominator, ssCoalitionMilitary, ssCoalitionActive] then
      begin
        HasBlocker := True;
        Break;
      end;
      if (Ship.CurrentStanding in [ssCoalitionPassive]) and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then Inc(OtherPirates);
    end;
    if HasBlocker then Continue;
    SourceStar.CountPirateForces(True, SourcePirateStrength, True, True);
    EligibleShips := CountEligibleShips;
    if (EligibleShips div 4 < OtherPirates) or (EligibleShips < MinimumFleet) then Continue;
    if NextRandomIntRange(1, 1000, RandomState) > Chance then Continue;
    SourceStar.CountForcesByOwnerGroups(SourceOppositionStrength, True, True, False, False);
    Action := 0;
    Attempts := NeighborLimit;
    NeighborIndex := NextRandomIntRange(1, NeighborLimit, RandomState);
    while (Attempts > 0) and (Action = 0) do
    begin
      TargetStar := TObject(SourceStar.StarDistances[NeighborIndex].Star) as TStar;
      NeighborIndex := IncrementWrapped(NeighborIndex, 1, NeighborLimit);
      Dec(Attempts);
      if (TargetStar.Constellation.Id = 20) or (TargetStar = SourceStar) or IsStarProtectedByScript(TargetStar) then Continue;
      if aGalaxy.Galaxy.CurrentTurn <= GalaxyWarmupTurns then
      begin
        if GetPlayer.CurrentStar = TargetStar then Continue;
        if Sqr((1 - aGalaxy.Galaxy.CurrentTurn / GalaxyWarmupTurns) * 70 + 30) >
           PointDistanceSquared(TargetStar.Position, GetPlayer.CurrentStar.Position) then Continue;
      end;
      TargetPirates := TargetStar.CountPirateForces(False, TargetPirateStrength, True, True);
      TargetOpposition := TargetStar.CountForcesByOwnerGroups(TargetOppositionStrength, True, True, False, False);
      if (CalculatePirateAttackNeighborhoodFactor(SourceStar) > CalculatePirateAttackNeighborhoodFactor(TargetStar)) and
         (NextRandomUnitFloat(RandomState) < 0.5) then Continue;
      SelectAction;
      if ((Action = 4) or (Action = 3) or (Action = 2)) and
         (NextRandomIntRange(1, 60, RandomState) <= TargetStar.PlayerPresenceLevel) then Continue;
      if Action <> 0 then DispatchShips;
    end;
  end;
end;
{ @end $78B9B4 }

{ @routine $78BF90 TPlanet_TrySpawnPirateBaseRaid }
procedure TPlanet.TrySpawnPirateBaseRaid;
var
  i, j, Chance: Integer;
  Star, TargetStar: TStar;
  Ship, Base, TargetBase: TShip;
  PirateCount, CoalitionCount, CivilCount, DominatorCount: Integer;
  Score, BestScore: Single;
  SpawnPlanet: TPlanet;
  OldOwner: TOwnerId;
  MessageText: WideString;

  // @nested $78BEBC CalculatePirateBaseRaidNeighborhoodThreshold
  function CalculatePirateBaseRaidNeighborhoodThreshold(Star: TStar): Single; // @addr 0x78BEBC @note "Nested in TrySpawnPirateBaseRaid; unused static link is caller-popped. Scores up to ten nearby stars and maps the score to 5..20."
  var
    Score, i: Integer;
  begin
    Score := 0;
    for i := 1 to Min(10, aGalaxy.Galaxy.Stars.Count - 1) do
      if Star.StarDistances[i].Star.Status.CustomFaction <> '' then Dec(Score)
      else
        case Star.StarDistances[i].Star.ControlFaction of
          sfCoalition: Inc(Score, 2);
          sfPirates: Dec(Score, 2);
          sfDominators: Dec(Score);
        end;
    Result := RemapClamped(Score, -20, 20, 5, 20);
  end;

begin
  if GetPlayer = nil then Exit;
  if aGalaxy.Galaxy.PirateWinType in [3, 5] then Exit;
  if aGalaxy.Galaxy.CurrentTurn mod (55 - 5 * System.Round(aGalaxy.Galaxy.GetPirateAggressionLevel * 0.125)) <> 0 then Exit;
  Chance := System.Round((aGalaxy.Galaxy.GetPirateAggressionLevel + 4) *
    RemapClamped(aGalaxy.Galaxy.GetCoalitionToPirateSystemRatio, 0.3, 3, 0.1, 1) *
    RemapClamped(aGalaxy.Galaxy.WarDeltaWin[2], 0, 5, 1, 0.3));
  if NextRandomIntRange(1, 100, RandomState) > Chance then Exit;
  TargetStar := nil;
  TargetBase := nil;
  BestScore := 0;
  for i := 0 to aGalaxy.Galaxy.Stars.Count - 1 do
  begin
    Star := aGalaxy.Galaxy.Stars[i];
    if (Star.ControlFaction <> sfCoalition) or (Star.Status.CustomFaction <> '') or
      (Star.Battle <> 0) or Star.NoComeKling or IsStarProtectedByScript(Star) then Continue;
    if aGalaxy.Galaxy.CurrentTurn <= GalaxyWarmupTurns then
    begin
      if GetPlayer.CurrentStar = Star then Continue;
      if Sqr((1 - aGalaxy.Galaxy.CurrentTurn / GalaxyWarmupTurns) * 70 + 25) >
        PointDistanceSquared(Star.Position, GetPlayer.CurrentStar.Position) then Continue;
    end;
    PirateCount := 0;
    CoalitionCount := 0;
    CivilCount := 0;
    DominatorCount := 0;
    Base := nil;
    for j := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[j];
      if Ship.CurrentStanding in [ssDominator, ssCustom] then Inc(DominatorCount)
      else if Ship.OwnerId = oiPirate then Inc(PirateCount)
      else if Ship.TypeId in [stRanger, stTransport] then Inc(CivilCount)
      else if Ship.CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive] then Inc(CoalitionCount);
      if (Ship.TypeId = rstPirateBase) and Ship.InNormalSpace and (Ship.ScriptShip = nil) then Base := Ship;
    end;
    if (Base = nil) or (DominatorCount > 0) or (PirateCount > 0) then Continue;
    Score := NextRandomIntRange(10, 15, RandomState) *
      (CalculatePirateBaseRaidNeighborhoodThreshold(Star) / (CivilCount + 10 + CoalitionCount * 2));
    if (TargetStar = nil) or (Score > BestScore) then
    begin
      TargetStar := Star;
      BestScore := Score;
      TargetBase := Base;
    end;
  end;
  if TargetStar = nil then Exit;
  for i := 1 to NextRandomIntRange(6, 8, RandomState) do
  begin
    SpawnPlanet := TargetStar.SelectRandomInhabitedPlanet;
    OldOwner := SpawnPlanet.OwnerId;
    SpawnPlanet.OwnerId := oiPirate;
    Ship := TObject(SpawnPlanet.BuyWarrior(100)) as TShip;
    Ship.Position := TargetBase.Position;
    Ship.CurrentPlanet := nil;
    Ship.DockedTo := TargetBase;
    TPirate(Ship).RaidPressure := 1;
    TNormalShip(Ship).TrainSkillsAutomatically;
    SpawnPlanet.OwnerId := OldOwner;
  end;
  if (GetPlayer <> nil) and (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) then
  begin
    MessageText := FormatText1(LocalizedText('Artefacts.ArtAnalyzer.AttackPirates'), TextHighlightColorTag, '<Star>', TargetStar.Name);
    if MessageText <> '' then AddOrUpdatePlayerBubble(pmGalaxyNews, aGalaxy.Galaxy.CurrentTurn, MessageText, '');
  end;
end;
{ @end $78BF90 }

{ @routine $78C518 TPlanet_InitializeFilmState }
procedure TPlanet.InitializeFilmState(StepIndex: Integer; RecordFilm: Boolean);
var
  Satellite: TSputnik;
  Index, Reserved, Count, Icon, Stage: Integer;
begin
  Stage := 0;
  Reserved := 4;
  try
    LastFilmPosition := TruncatePointF(GetPosition);
    Stage := 1;
    Stage := 2;
    if RecordFilm then
    begin
      Stage := 3;
      FilmObject := PrimaryFilm.AddObject(Id, Graphic);
      Stage := 4;
      PrimaryFilm.SetObjectPosition(StepIndex, FilmObject, GetPosition);
      if CustomFaction = '' then Icon := Ord(OwnerId)
      else
      begin
        Icon := GetCustomFactionPlanetIconNumber(CustomFaction);
        if Icon < 0 then Icon := Ord(OwnerId)
        else Icon := Icon + 1 + 7;
      end;
      PrimaryFilm.SetPlanetState(StepIndex, FilmObject, Graphic.RotationTimerInterval,
        Graphic.SurfaceMapStep, Round(OrbitalVelocity * 1000), Graphic.RingKind, Icon);
      Stage := 5;
      PrimaryFilm.AttachObject(StepIndex, FilmObject);
      Stage := 6;
      Count := Satellites.Count;
      for Index := 0 to Count - 1 do
      begin
        Stage := 7;
        Satellite := TSputnik(Satellites[Index]);
        Stage := 8;
        Satellite.FilmObject := PrimaryFilm.AddObject(Satellite.Id, Satellite.Graphic);
        Stage := 9;
        PrimaryFilm.SetObjectOrbitCenter(StepIndex, Satellite.FilmObject, GetPosition);
        Stage := 10;
        PrimaryFilm.SetObjectStateBuffer(StepIndex, Satellite.FilmObject, Satellite.Graphic.BuildStateBuffer);
        Stage := 11;
        PrimaryFilm.AttachObject(StepIndex, Satellite.FilmObject);
      end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TPlanet.StepDayStart, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $78C518 }

{ @routine $78C8E0 TPlanet_AdvanceOrbitStep }
procedure TPlanet.AdvanceOrbitStep(StepIndex: Integer; RecordFilm: Boolean);
var
  Point: TPoint;
  Satellite: TSputnik;
  Index, Count: Integer;
begin
  Orbit.AngleDegrees := CurrentStar.MovementStepScale * OrbitalVelocity + Orbit.AngleDegrees;
  if RecordFilm then
  begin
    Point := TruncatePointF(GetPosition);
    if (LastFilmPosition.X <> Point.X) or (LastFilmPosition.Y <> Point.Y) then
    begin
      PrimaryFilm.SetObjectPosition(StepIndex, FilmObject, PointToPointF(Point));
      LastFilmPosition := Point;
      Count := Satellites.Count;
      for Index := 0 to Count - 1 do
      begin
        Satellite := TSputnik(Satellites[Index]);
        PrimaryFilm.SetObjectOrbitCenter(StepIndex, Satellite.FilmObject, PointToPointF(Point));
      end;
    end;
  end;
end;
{ @end $78C8E0 }

{ @routine $78C9F0 TPlanet_PredictPosition }
function TPlanet.PredictPosition(StepsAhead: Integer): TPointF;
var Polar: TPolarPoint;
begin
  Polar.Radius := Orbit.Radius;
  Polar.AngleDegrees := CurrentStar.MovementStepScale * OrbitalVelocity * StepsAhead + Orbit.AngleDegrees;
  Result := PolarToPoint(Polar);
end;
{ @end $78C9F0 }

{ @routine $78CA40 TPlanet_RequestDialog }
function TPlanet.RequestDialog: Boolean;
begin
  if ExitScreenLoop or not GetPlayer.InNormalSpace then
  begin
    Result := False;
    Exit;
  end;
  TalkShip := nil;
  TalkPlanet := Self;
  TalkScripted := True;
  ResetEvent(TalkCompletedEvent);
  SetEvent(TalkRequestEvent);
  if WaitForSingleObject(TalkCompletedEvent, INFINITE) <> WAIT_OBJECT_0 then
  begin
    Result := False;
    ResetEvent(TalkRequestEvent);
  end
  else
  begin
    SysUtils.Sleep(10);
    Result := True;
  end;
end;
{ @end $78CA40 }

{ @routine $78CAD4 TPlanet_UpdateOwnerFlags }
procedure TPlanet.UpdateOwnerFlags;
begin
  IsCoalitionOwned := OwnerId in aConst.PlanetOwnerMasks.Coalition;
end;
{ @end $78CAD4 }

{ @routine $78CB00 TPlanet_UpdateMarketState }
procedure TPlanet.UpdateMarketState;
{ The entire procedure is reconstructed Pascal, without assembler or byte patches.
  Local order, Single intermediates, inlined Math overloads, set construction,
  case ranges and expression grouping reproduce the native instruction stream. }
var
  ItemType: Byte;
  TargetPrice, PriceStep, EconomyFactor: Single;
  TargetStock, StockStep, StoredUnits: Integer;
begin
  if GetPlayer = nil then Exit;
  if ShopUpdateMode in [1, 2] then Exit;
  for ItemType := 0 to 7 do
  begin
    if GoodsScarcityTicks[ItemType] > 0 then
      ForceGoodsScarcity(False, [ItemType]);
    if GoodsSurplusTicks[ItemType] > 0 then
      ForceGoodsSurplus(False, [ItemType]);
    StoredUnits := GetPlayer.CountStoredItemUnits(Self, TItemType(ItemType));
    if (GetPlayer.CurrentPlanet = Self) and (GetPlayer.ConsecutiveDockedDays > 1) then
      Inc(StoredUnits, GetPlayer.CargoGoods[ItemType].Count);
    EconomyFactor := aConst.GoodsMarket[ItemType].EconomyFactors[Economy];
    if OwnerId in aConst.PlanetOwnerMasks.PirateClan then
      EconomyFactor := EconomyFactor * aConst.GoodsMarket[ItemType].PirateEconomyFactor;
    TargetStock := System.Round(aConst.GoodsMarket[ItemType].BaseStock *
      aConst.PlanetRaceMarket[RaceId].GoodsFactors[ItemType].StockFactor *
      aConst.PlanetGovernmentMarket[Government].GoodsFactors[ItemType].StockFactor *
      EconomyFactor * RemapClamped(Radius, 60, 100, 0.5, 1.5));
    TargetPrice := aConst.GoodsMarket[ItemType].AveragePrice *
      aConst.PlanetRaceMarket[RaceId].GoodsFactors[ItemType].PriceFactor *
      aConst.PlanetGovernmentMarket[Government].GoodsFactors[ItemType].PriceFactor / EconomyFactor;
    if Goods[ItemType].Count + StoredUnits < TargetStock then
      TargetPrice := TargetPrice / RemapClamped(Goods[ItemType].Count + StoredUnits, TargetStock * 0.1, TargetStock, 0.8, 1)
    else
      TargetPrice := TargetPrice / RemapClamped(Goods[ItemType].Count + StoredUnits, TargetStock, TargetStock * 3, 1, 1.2);
    if aConst.GoodsMarket[ItemType].MinPrice < TargetPrice then
      TargetPrice := Min(TargetPrice, aConst.GoodsMarket[ItemType].MaxPrice + 1)
    else
      TargetPrice := Max(TargetPrice, aConst.GoodsMarket[ItemType].MinPrice - 1);
    if Goods[ItemType].PriceState - TargetPrice >= 0 then
      PriceStep := TargetPrice * NextRandomFloatRange(0.005, 0.008, RandomState)
    else
      PriceStep := -TargetPrice * NextRandomFloatRange(0.005, 0.008, RandomState);
    case NextRandomIntRange(1, 100, RandomState) of
      1..70: Goods[ItemType].PriceState := Goods[ItemType].PriceState - PriceStep;
      71..90: ;
    else Goods[ItemType].PriceState := Goods[ItemType].PriceState + PriceStep;
    end;
    if aConst.GoodsMarket[ItemType].MinPrice div 2 > Goods[ItemType].PriceState then
      Goods[ItemType].PriceState := aConst.GoodsMarket[ItemType].MinPrice div 2
    else if aConst.GoodsMarket[ItemType].MaxPrice * 2 < Goods[ItemType].PriceState then
      Goods[ItemType].PriceState := aConst.GoodsMarket[ItemType].MaxPrice * 2;
    Goods[ItemType].PurchasePrice := Max(2, System.Round(Goods[ItemType].PriceState));
    Goods[ItemType].BaseSalePrice := Max(Goods[ItemType].PurchasePrice div 2 + 1,
      System.Round(Goods[ItemType].PriceState * RemapClamped(Goods[ItemType].Count + StoredUnits, TargetStock, TargetStock * 2.2, 0.99, 0.5) - 1));
    if Goods[ItemType].Count + StoredUnits - TargetStock >= 0 then
      StockStep := System.Round(TargetStock * NextRandomFloatRange(0.0025, 0.005, RandomState) + NextRandomUnitFloat(RandomState))
    else
      StockStep := System.Round(-TargetStock * NextRandomFloatRange(0.0025, 0.005, RandomState) - NextRandomUnitFloat(RandomState));
    case NextRandomIntRange(1, 100, RandomState) of
      1..20: Dec(Goods[ItemType].Count, StockStep);
      21..95: ;
    else Inc(Goods[ItemType].Count, StockStep);
    end;
    if Goods[ItemType].Count < 0 then Goods[ItemType].Count := 0;
  end;
end;
{ @end $78CB00 }

{ @routine $78D268 TPlanet_TriggerGovernmentRevolution }
procedure TPlanet.TriggerGovernmentRevolution;
var
  NewGovernment, Candidate: TPlanetGovernment;
  i, Attempts, Roll: Integer;
  Ranger: TRanger;
  ItemType: Byte;
  GoodsMask: TItemTypeMask;
  NewsType: TGalaxyNewsKind;
begin
  NewGovernment := Government;
  Attempts := 0;
  NewsType := gnRevolutionAnarchy;
  repeat
    Roll := NextRandomIntRange(0, 100, RandomState);
    for Candidate := pgDemocracy downto pgAnarchy do
      if aConst.PlanetRaceMarket[RaceId].GovernmentRollThresholds[Candidate] <= Roll then
      begin
        NewGovernment := Candidate;
        case NewGovernment of
          pgAnarchy: NewsType := gnRevolutionAnarchy;
          pgDictatorship: NewsType := gnRevolutionDictatorship;
          pgMonarchy: NewsType := gnRevolutionMonarchy;
          pgRepublic: NewsType := gnRevolutionRepublic;
          pgDemocracy: NewsType := gnRevolutionDemocracy;
        end;
        Break;
      end;
    Inc(Attempts);
    if Attempts > 100 then
      if Government <> pgAnarchy then
      begin
        NewGovernment := pgAnarchy;
        NewsType := gnRevolutionAnarchy;
      end
      else
      begin
        NewGovernment := pgDemocracy;
        NewsType := gnRevolutionDemocracy;
      end;
    // The native news-duplication test has an empty body.
    if CurrentStar.IsConstellationVisible and
      (aGalaxy.Galaxy.CountPlanetNewsByType(NewsType) > 0) and (Attempts < 200) then ;
  until Government <> NewGovernment;
  Government := NewGovernment;
  for i := 0 to aGalaxy.Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(aGalaxy.Galaxy.Rangers[i]);
    if not Ranger.ExcludedFromRating then
      ChangeRelationToRanger(Ranger, aConst.PlanetGovernmentMarket[Government].RevolutionRelationDelta[
        Ranger.GetDominantCareer]);
  end;
  // Native emits every revolution under the anarchy ID, regardless of NewGovernment.
  if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
    aGalaxy.Galaxy.AddPlanetNews(gnRevolutionAnarchy, FormatText2(
      PickLocalizedTextVariant('GalaxyNews.Planet.Revolution.' + SysUtils.IntToStr(Ord(Government)),
        (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
      TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  // The goods event uses Candidate even when the attempt limit changes NewGovernment.
  case Candidate of
    pgAnarchy: ForceGoodsScarcity(True, [0, 1, 2, 6]);
    pgDictatorship: ForceGoodsScarcity(True, [0, 1, 6]);
    pgMonarchy:
      begin
        GoodsMask := [0];
        for ItemType := 1 to 7 do
          if aConst.GoodsMarket[ItemType].AveragePrice > Goods[ItemType].PriceState then
            Include(GoodsMask, ItemType);
        ForceGoodsSurplus(True, GoodsMask);
      end;
    pgRepublic:
      begin
        ForceGoodsScarcity(True, [4]);
        ForceGoodsSurplus(True, [2, 6]);
      end;
    pgDemocracy:
      begin
        ForceGoodsScarcity(True, [3, 4]);
        ForceGoodsSurplus(True, [2, 6]);
      end;
  end;
end;
{ @end $78D268 }

{ @routine $78D6C0 TPlanet_TryTriggerEconomicEvent }
procedure TPlanet.TryTriggerEconomicEvent;
begin
  if IsMainPiratePlanet then Exit;
  if NoRandomEvents then Exit;
  if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.PlanetNews.Count >= MaxPlanetNews) then Exit;
  if CurrentStar.ShipTypeCounts[stKling] > 0 then Exit;
  if (aGalaxy.Galaxy.CurrentTurn + Integer(GenerationSeed)) mod 30 <> 0 then Exit;
  if CurrentStar.DaysSincePlayerVisit < 30 then Exit;
  if SeededRandomFloatRange(aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1017, 0, 1) <
    aConst.PlanetRaceMarket[RaceId].RevolutionChance then
    TriggerGovernmentRevolution
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1117) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnMineralDeposit) = 0)) and
    (Economy in [peMixed, peIndustrial]) then
  begin
    ForceGoodsScarcity(True, [2]);
    ForceGoodsSurplus(True, [4]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnMineralDeposit, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.MineralDeposit',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1127) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnMineralShortage) = 0)) and
    (Economy in [peIndustrial]) then
  begin
    ForceGoodsScarcity(True, [4]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnMineralShortage, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.NeedMineral',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1217) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnArmsSurplus) = 0)) and
    (Economy in [peMixed, peIndustrial]) and
    (RaceToOwner(RaceId) in [oiMaloc, oiHuman, oiFeyan]) then
  begin
    ForceGoodsScarcity(True, [2]);
    ForceGoodsSurplus(True, [6]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnArmsSurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyArms',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1227) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnArmsShortage) = 0)) and
    (Economy in [peMixed]) and
    (RaceToOwner(RaceId) in [oiMaloc..oiHuman]) then
  begin
    ForceGoodsScarcity(True, [6]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnArmsShortage, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.NeedArms',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1237) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnArmsShortage) = 0)) and
    (Economy in [peMixed]) and
    (RaceToOwner(RaceId) in [oiMaloc..oiFeyan]) and
    (Government in [pgDemocracy]) then
  begin
    ForceGoodsScarcity(True, [6]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnArmsShortage, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.NeedArmsForRevolution',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1317) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnTechnicsSurplus) = 0)) and
    (Economy in [peMixed, peIndustrial]) and
    (RaceToOwner(RaceId) in [oiHuman..oiGaal]) then
  begin
    ForceGoodsSurplus(True, [2, 6]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnTechnicsSurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyTechnics',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 71417) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnFoodSurplus) = 0)) and
    (Economy in [peAgricultural, peMixed]) then
  begin
    ForceGoodsSurplus(True, [0]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnFoodSurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyFood',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 31427) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnFoodSurplus) = 0)) and
    (Economy in [peAgricultural]) then
  begin
    ForceGoodsSurplus(True, [0]);
    ForceGoodsScarcity(True, [2]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnFoodSurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyFoodNeedTechnics',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 21437) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnFoodShortage) = 0)) and
    (Economy in [peAgricultural, peMixed, peIndustrial]) and
    (RaceToOwner(RaceId) in [oiMaloc..oiFeyan]) then
  begin
    ForceGoodsScarcity(True, [0, 1, 7]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnFoodShortage, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.NeedFood',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1517) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnMedicineSurplus) = 0)) and
    (Economy in [peMixed]) and
    (RaceToOwner(RaceId) in [oiHuman..oiGaal]) then
  begin
    ForceGoodsSurplus(True, [1]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnMedicineSurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyMedicine',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1617) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnLuxurySurplus) = 0)) and
    (Economy in [peAgricultural, peMixed, peIndustrial]) and
    (RaceToOwner(RaceId) in [oiPeleng..oiGaal]) then
  begin
    ForceGoodsSurplus(True, [3]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnLuxurySurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyLuxury',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1717) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnLuxuryShortage) = 0)) and
    (Economy in [peAgricultural, peMixed]) and
    (RaceToOwner(RaceId) in [oiHuman..oiGaal]) then
  begin
    ForceGoodsScarcity(True, [3]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnLuxuryShortage, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.NeedLuxury',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1817) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnAlcoholSurplus) = 0)) and
    (Economy in [peAgricultural, peMixed]) and
    (RaceToOwner(RaceId) in [oiPeleng..oiHuman]) then
  begin
    ForceGoodsSurplus(True, [5]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnAlcoholSurplus, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.ManyAlcohol',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end
  else if (SeededRandomIntRange(0, 100,
    aGalaxy.Galaxy.CurrentTurn * Integer(GenerationSeed) * 1917) < EconomicEventChance) and
    (not CurrentStar.IsConstellationVisible or (aGalaxy.Galaxy.CountPlanetNewsByType(gnAlcoholShortage) = 0)) and
    (Economy in [peMixed, peIndustrial]) and
    (RaceToOwner(RaceId) in [oiHuman,oiGaal]) then
  begin
    ForceGoodsScarcity(True, [5]);
    if CurrentStar.IsConstellationVisible and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then
      aGalaxy.Galaxy.AddPlanetNews(gnAlcoholShortage, FormatText2(
        PickLocalizedTextVariant('GalaxyNews.Planet.NeedAlcohol',
          (aGalaxy.Galaxy.CurrentTurn div 10) * Integer(GenerationSeed)),
        TextHighlightColorTag, '<Star>', CurrentStar.Name, '<Planet>', Name));
  end;
end;
{ @end $78D6C0 }

{ @routine $78EB64 TPlanet_HandleAsteroidImpact }
procedure TPlanet.HandleAsteroidImpact(Asteroid: Pointer);
begin

end;
{ @end $78EB64 }

{ @routine $78EB74 TPlanet_CollectScriptDialogChoices }
procedure TPlanet.CollectScriptDialogChoices(Choices: TStringsEC);
var
  i, j, k: Integer;
  Script: TScript;
  Star: TScriptStar;
begin
  Choices.Clear;
  for i := 0 to aGalaxy.Galaxy.Scripts.Count - 1 do
  begin
    Script := aGalaxy.Galaxy.Scripts[i];
    for j := 0 to Script.Stars.Count - 1 do
    begin
      Star := Script.Stars[j];
      for k := 0 to High(Star.Planets) do
        if (Star.Planets[k].Planet = Self) and (Star.Planets[k].DialogChoiceText <> '') then
        begin
          Choices.Add(Star.Planets[k].DialogChoiceText);
          Choices.SetDataAt(Choices.GetCount - 1, Script);
        end;
    end;
  end;
end;
{ @end $78EB74 }

{ @routine $78EC8C TPlanet_GetSurfaceAnimationMask }
function TPlanet.GetSurfaceAnimationMask: Integer;
var
  Index, ConditionIndex, Family: Integer;
  GoodsIndex, Good, SelectedGood: Byte;
  Owners: TOwnerMask;
  Eligible: Boolean;
  Definition: PPlanetAdvertDefinition;
begin
  Result := -1;
  if not (OwnerId in aConst.PlanetOwnerMasks.Coalition) then Exit;
  if Graphic.RingKind = 1 then Family := 0
  else if Graphic.RingKind = 4 then Family := 1
  else if Graphic.RingKind = 5 then Family := 2
  else Exit;
  SelectedGood := UnspecifiedGoods;
  ConditionIndex := 0;
  for GoodsIndex := Low(TGoodsIndex) to High(TGoodsIndex) do
    if aConst.GoodsLegalOnPlanet[GoodsIndex, RaceId, Government] then
      if Goods[GoodsIndex].Count >= aConst.GoodsMarket[GoodsIndex].BaseStock div 2 then
      begin
        Index := Goods[GoodsIndex].PurchasePrice -
          (aConst.GoodsMarket[GoodsIndex].MinPrice + aConst.GoodsMarket[GoodsIndex].AveragePrice) div 2;
        if (Index < 0) and (Index < ConditionIndex) then
        begin
          ConditionIndex := Index;
          SelectedGood := GoodsIndex;
        end;
      end;
  Definition := @PlanetAdvertDefinitions[Family];
  Result := 0;
  for Index := 0 to High(Definition^.Lists) do
  begin
    Eligible := True;
    for ConditionIndex := 0 to High(Definition^.Lists[Index].Indices) do
    begin
      repeat
        case Definition^.Adverts[Definition^.Lists[Index].Indices[ConditionIndex]].War of
          -1: if CurrentStar.Battle <> 0 then
              begin
                Eligible := False;
                Break;
              end;
           1: if CurrentStar.Battle = 0 then
              begin
                Eligible := False;
                Break;
              end;
        end;
        Good := Definition^.Adverts[Definition^.Lists[Index].Indices[ConditionIndex]].Goods;
        if (Good in [Ord(t_Food)..Ord(t_Narcotics)]) and (Good <> SelectedGood) then Eligible := False
        else
        begin
          Owners := Definition^.Adverts[Definition^.Lists[Index].Indices[ConditionIndex]].Owner;
          if (Owners <> []) and not (OwnerId in Owners) then Eligible := False
          else Result := Result or (1 shl Index);
        end;
      until True;
      // Native sets the bit as each condition succeeds; a later failure does
      // not clear an already set bit for the same list.
      if not Eligible then Break;
    end;
  end;
  if Result <= 0 then Result := -1
  else Result := Result or (Family shl 24);
end;
{ @end $78EC8C }

{ @routine $78EF64 TPlanet_GetGovernmentPortraitGraph }
function TPlanet.GetGovernmentPortraitGraph: WideString;
var
  Index, Count, FaceCount: Integer;
  Block: TBlockParEC;
  Faces: array[0..50] of Integer;
begin
  FaceCount := 0;
  Block := GameDataConfig.GetBlockByPath('StyleFace' + aConst.OwnerInfo[OwnerId].InternalName);
  Count := Block.GetParamCount;
  for Index := 0 to Count - 1 do
    if FindTextOffsetW(Block.GetParamValue(Index), 'L') >= 0 then
    begin
      Faces[FaceCount] := ExtractDigitsToIntW(Block.GetParamName(Index));
      if (GetPlayer = nil) or (GetPlayer.PortraitFaceId <> Faces[FaceCount]) then Inc(FaceCount);
    end;
  // Native selection deliberately excludes the last candidate and assumes at least two.
  Index := Faces[Integer(GenerationSeed) mod (FaceCount - 1)];
  Result := 'Bm.Captain.' + GiResourceSuffix + aConst.OwnerInfo[OwnerId].InternalName + WideString(IntToStr(Index));
end;
{ @end $78EF64 }

{ @routine $78F164 TPlanet_GetFullName }
function TPlanet.GetFullName(Separator: WideString): WideString;
begin
  if IsMainPiratePlanet then Result := Name
  else Result := LocalizedText('Planet.Name') + Separator + Name;
end;
{ @end $78F164 }

{ @routine $78F218 TPlanet_GetPosition }
function TPlanet.GetPosition: TPointF;
begin
  Result := PolarToPoint(Orbit);
end;
{ @end $78F218 }

{ @routine $78F238 TPlanet_GetInfoText }
function TPlanet.GetInfoText(ForMap: Boolean): WideString;
var Text: WideString;
begin
  if IsMainPiratePlanet then
  begin
    if OwnerId = oiPirate then Text := LocalizedText('Planet.MainPiratePlanet.Info.TextAboutPlanet')
    else Text := LocalizedText('Planet.MainPiratePlanet.Info.TextAboutPlanetAlt');
  end
  else if (CustomFaction <> '') and (OwnerId <> oiUninhabited) then
    Text := LocalizedText('Planet.' + CustomFaction + '.Info.TextAboutPlanet')
  else if (CurrentStar.Status.CustomFaction <> '') and (OwnerId <> oiUninhabited) then
    Text := LocalizedText('Planet.' + CurrentStar.Status.CustomFaction + '.Info.TextAboutPlanet')
  else
    case OwnerId of
      oiMaloc..oiGaal, oiPirate: Text := LocalizedText('Planet.Civil.Info.TextAboutPlanet');
      oiDominator: Text := LocalizedText('Planet.Kling.Info.TextAboutPlanet');
      oiUninhabited: Text := LocalizedText('Planet.NotCivil.Info.TextAboutPlanet');
    end;
  if GetPlayer <> nil then
    if (GetPlayer.CountActiveArtefacts(t_ArtefactAnalyzer) > 0) and (OwnerId = oiUninhabited) and not ForMap then
      Text := Text + #13#10 + BuildNonCivilTreasureHintText;
  if ForMap and (OwnerId = oiPirate) and (Galaxy.CoalitionDefeatedTurn = 0) then
    Text := Text + #13#10 + RedColorTag + LocalizedText('Planet.Civil.Info.TextPlanetControlledByPirates') + EndColorTag;
  if WaterTiles - WaterExplored > 0 then ReplaceTextToken(Text, '<Water>', WideString(IntToStr(WaterTiles - WaterExplored)), TextHighlightColorTag)
  else ReplaceTextToken(Text, '<Water>', '-', '');
  if LandTiles - LandExplored > 0 then ReplaceTextToken(Text, '<Land>', WideString(IntToStr(LandTiles - LandExplored)), TextHighlightColorTag)
  else ReplaceTextToken(Text, '<Land>', '-', '');
  if HillTiles - HillExplored > 0 then ReplaceTextToken(Text, '<Hill>', WideString(IntToStr(HillTiles - HillExplored)), TextHighlightColorTag)
  else ReplaceTextToken(Text, '<Hill>', '-', '');
  ReplaceTextToken(Text, '<Planet>', Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Star>', CurrentStar.Name, TextHighlightColorTag);
  if IsMainPiratePlanet then ReplaceTextToken(Text, '<Race>', aConst.OwnerInfo[OwnerId].DisplayName, TextHighlightColorTag)
  else ReplaceTextToken(Text, '<Race>', GetNativeRaceName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Population>', WideString(IntToStr(Round(Population / 1000))), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Economy>', aConst.PlanetEconomyInfo[Economy].DisplayName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Goverment>', GetGovernmentName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Relation>', GetRelationLevelTextToShip(GetPlayer), TextHighlightColorTag);
  Result := Text;
end;
{ @end $78F238 }

{ @routine $78FA9C TPlanet_GetGovernmentName }
function TPlanet.GetGovernmentName: WideString;
begin
  Result := aConst.PlanetGovernmentMarket[Government].DisplayName;
end;
{ @end $78FA9C }

{ @routine $78FACC TPlanet_GetNativeRaceName }
function TPlanet.GetNativeRaceName: WideString;
begin
  Result := aConst.OwnerInfo[RaceToOwner(RaceId)].DisplayName;
end;
{ @end $78FACC }

{ @routine $78FB00 TPlanet_GetFactionResourceName }
function TPlanet.GetFactionResourceName: WideString;
begin
  if CustomFaction <> '' then Result := CustomFaction
  else if CurrentStar.Status.CustomFaction <> '' then Result := CurrentStar.Status.CustomFaction
  else if CurrentStar.ControlFaction = sfDominators then Result := aConst.DominatorSeriesNames[Ord(CurrentStar.DominatorSeries)]
  else if IsMainPiratePlanet then Result := aConst.OwnerInfo[OwnerId].InternalName
  else if OwnerId = oiPirate then Result := aConst.OwnerInfo[oiPirate].InternalName + RaceToSys(RaceId)
  else Result := aConst.OwnerInfo[OwnerId].InternalName;
end;
{ @end $78FB00 }

{ @routine $78FC30 TPlanet_CalculateBasePopulation }
function TPlanet.CalculateBasePopulation: Integer;
begin
  Result := Round(RemapClamped(Radius, 60, 100, 100000, 1000000));
end;
{ @end $78FC30 }

{ @routine $78FC78 TPlanet_CountPlanetsOfSameRace }
function TPlanet.CountPlanetsOfSameRace: Integer;
var
  i, Count: Integer;
  Planet: TPlanet;
begin
  Count := 0;
  for i := 0 to aGalaxy.Galaxy.Planets.Count - 1 do
  begin
    Planet := aGalaxy.Galaxy.Planets[i];
    if OwnerId = oiUninhabited then
    begin
      if OwnerId = Planet.OwnerId then Inc(Count);
    end
    else if Planet.OwnerId <> oiUninhabited then
      if RaceId = Planet.RaceId then Inc(Count);
  end;
  Result := Count;
end;
{ @end $78FC78 }

{ @routine $78FD04 TPlanet_FindUnchartedNeighborConstellation }
function TPlanet.FindUnchartedNeighborConstellation: TConstellation;
var
  i: Integer;
  Constellation: TConstellation;
begin
  for i := 0 to aGalaxy.Galaxy.Constellations.Count - 1 do
  begin
    Constellation := aGalaxy.Galaxy.Constellations[i];
    if Constellation.SharesOutlineSegment(CurrentStar.Constellation) then
      if not Constellation.Visible then
        if Constellation.Id <> 20 then
        begin
          Result := Constellation;
          Exit;
        end;
  end;
  Result := nil;
end;
{ @end $78FD04 }

{ @routine $78FD8C TPlanet_FindNearestPlanetByOwnerMask }
function TPlanet.FindNearestPlanetByOwnerMask(OwnerMask: TOwnerMask): TPlanet;
var
  i, j: Integer;
  Star: TStar;
  Planet: TPlanet;
begin
  for i := 0 to aGalaxy.Galaxy.Stars.Count - 1 do
  begin
    Star := TObject(CurrentStar.StarDistances[i].Star) as TStar;
    for j := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[j];
      if Planet.OwnerId in OwnerMask then
      begin
        Result := Planet;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;
{ @end $78FD8C }

{ @routine $78FE3C TPlanet_NormalizeSurfaceLootEntries }
procedure TPlanet.NormalizeSurfaceLootEntries;
var
  i, j, Direction, X, Y: Integer;
  First, Second: PPlanetSurfaceLootEntry;
  Tail, Head: Integer;
  Occupied, Visited: array[0..13, 0..6] of Boolean;
  Queue: array[0..97] of TPoint;
begin
  if SurfaceLootEntries = nil then Exit;
  for i := 0 to SurfaceLootEntries.Count - 2 do
    for j := i + 1 to SurfaceLootEntries.Count - 1 do
    begin
      First := SurfaceLootEntries[i];
      Second := SurfaceLootEntries[j];
      if Second.SurfaceTileIndex < First.SurfaceTileIndex then
      begin
        SurfaceLootEntries[i] := Second;
        SurfaceLootEntries[j] := First;
      end;
    end;
  // These native inclusive bounds overrun the 14-by-7 arrays; retained exactly.
  for Y := 0 to 7 do
    for X := 0 to 14 do Occupied[X, Y] := False;
  for i := 0 to SurfaceLootEntries.Count - 1 do
  begin
    First := SurfaceLootEntries[i];
    Occupied[First.GridX, First.GridY] := True;
  end;
  for i := 0 to SurfaceLootEntries.Count - 2 do
  begin
    First := SurfaceLootEntries[i];
    for j := i + 1 to SurfaceLootEntries.Count - 1 do
    begin
      Second := SurfaceLootEntries[j];
      if (First.GridX = Second.GridX) and (First.GridY = Second.GridY) then
      begin
        for Y := 0 to 7 do
          for X := 0 to 14 do Visited[X, Y] := False;
        Queue[0].X := Second.GridX;
        Queue[0].Y := Second.GridY;
        Visited[Queue[0].X, Queue[0].Y] := True;
        Head := 0;
        Tail := 1;
        while Head < Tail do
        begin
          for Direction := 0 to 3 do
          begin
            X := Queue[Head].X;
            Y := Queue[Head].Y;
            case Direction of
              0: begin Inc(X); if X >= 14 then Continue; end;
              1: begin Dec(X); if X < 0 then Continue; end;
              2: begin Inc(Y); if Y >= 7 then Continue; end;
              3: begin Dec(Y); if Y < 0 then Continue; end;
            end;
            if Visited[X, Y] then Continue;
            if not Occupied[X, Y] then
            begin
              Occupied[X, Y] := True;
              Second.GridX := X;
              Second.GridY := Y;
              Head := Tail;
              Break;
            end
            else
            begin
              if Tail >= 98 then RaiseWideMessage('Gone item coords');
              Visited[X, Y] := True;
              Queue[Tail].X := X;
              Queue[Tail].Y := Y;
              Inc(Tail);
            end;
          end;
          Inc(Head);
        end;
      end;
    end;
  end;
end;
{ @end $78FE3C }

{ @routine $79021C TPlanet_GetTotalSurfaceTileCount }
function TPlanet.GetTotalSurfaceTileCount: Integer;
begin
  Result := WaterTiles + LandTiles + HillTiles;
end;
{ @end $79021C }

{ @routine $79024C TPlanet_GetUnexploredSurfaceTileCount }
function TPlanet.GetUnexploredSurfaceTileCount: Integer;
begin
  if OwnerId = oiUninhabited then Result := GetTotalSurfaceTileCount - (WaterExplored + LandExplored + HillExplored)
  else Result := 0;
end;
{ @end $79024C }

{ @routine $790294 TPlanet_AddSurfaceLootEntry }
function TPlanet.AddSurfaceLootEntry(Item: TItem): Boolean;
var
  Terrain, Total: Integer;
  Entry: PPlanetSurfaceLootEntry;
begin
  if GetUnexploredSurfaceTileCount = 0 then
  begin
    WaterExplored := 0;
    LandExplored := 0;
    HillExplored := 0;
  end;
  Total := GetTotalSurfaceTileCount;
  Terrain := 0;
  while True do
  begin
    Terrain := System.Round(NextRandomIntRange(1, Total, RandomState));
    if (Terrain <= WaterTiles) and (WaterExplored < WaterTiles) then
    begin Terrain := 0; Break; end
    else if (Terrain <= WaterTiles + LandTiles) and (LandExplored < LandTiles) then
    begin Terrain := 1; Break; end
    else if (Terrain <= WaterTiles + LandTiles + HillTiles) and (HillExplored < HillTiles) then
    begin Terrain := 2; Break; end;
  end;
  if SurfaceLootEntries = nil then SurfaceLootEntries := TList.Create;
  System.GetMem(Entry, SizeOf(TPlanetSurfaceLootEntry));
  SurfaceLootEntries.Add(Entry);
  Entry.GridX := NextRandomIntRange(0, 13, RandomState);
  Entry.GridY := NextRandomIntRange(0, 6, RandomState);
  Entry.TerrainKind := TPlanetTerrainKind(Terrain);
  case Terrain of
    0: Entry.SurfaceTileIndex := SeededRandomIntRange(WaterExplored + 1, WaterTiles, RandomState);
    1: Entry.SurfaceTileIndex := SeededRandomIntRange(LandExplored + 1, LandTiles, RandomState);
    2: Entry.SurfaceTileIndex := SeededRandomIntRange(HillExplored + 1, HillTiles, RandomState);
  end;
  Entry.Unavailable := False;
  Entry.Item := Item;
  Result := True;
end;
{ @end $790294 }

{ @routine $7904B0 TPlanet_TryResetSurfaceLootAfterLongAbsence }
function TPlanet.TryResetSurfaceLootAfterLongAbsence: Boolean;
var
  i: Integer;
  Entry: PPlanetSurfaceLootEntry;
begin
  Result := False;
  if CurrentStar.DaysSincePlayerVisit < 720 then Exit;
  if OwnerId <> oiUninhabited then Exit;
  if GetUnexploredSurfaceTileCount > GetTotalSurfaceTileCount * 0.4 then Exit;
  if GetPlayer.HasSatelliteOnPlanet(Self) then Exit;
  if SurfaceLootEntries = nil then Exit;
  for i := 0 to SurfaceLootEntries.Count - 1 do
  begin
    Entry := SurfaceLootEntries[i];
    if Entry.Unavailable and GetPlayer.CanAccessSurfaceLootItem(Entry.Item) then
    begin
      Entry.Unavailable := False;
      Result := True;
    end;
  end;
  if Result then
  begin
    WaterExplored := 0;
    LandExplored := 0;
    HillExplored := 0;
  end;
end;
{ @end $7904B0 }

{ @routine $7905D4 TPlanet_BoostInventionLevels }
procedure TPlanet.BoostInventionLevels(Count: Integer);
var Index: Integer;
begin
  for Index := 1 to Count do
  begin
    Inc(InventionLevels[CurrentInvention]);
    CurrentInventionPoints := 0;
    SelectCurrentInvention;
  end;
end;
{ @end $7905D4 }

{ @routine $79061C TPlanet_SelectCurrentInvention }
procedure TPlanet.SelectCurrentInvention;
var
  Track: TPlanetInvention;
  Chance: Double;
  Found: Boolean;
  i, Index: Integer;
begin
  Found := False;
  Chance := 0.03;
  repeat
    Index := NextRandomIntRange(Ord(Low(TPlanetInvention)), Ord(High(TPlanetInvention)), RandomState);
    for i := Ord(Low(TPlanetInvention)) to Ord(High(TPlanetInvention)) do
    begin
      IncrementWrapped(Index, Ord(Low(TPlanetInvention)), Ord(High(TPlanetInvention)));
      Track := TPlanetInvention(Index);
      if (ResearchLevelPercent > System.Round(InventionLevels[Track] * 12.5)) and
        (aConst.PlanetInventionInfo[Track].RequiredMainTechLevel <= InventionLevels[piMainTech]) and
        (InventionLevels[Track] <= InventionLevels[piMainTech]) and
        (NextRandomUnitFloat(RandomState) <= Chance) then
      begin
        CurrentInvention := Track;
        Found := True;
        Break;
      end;
    end;
    Chance := Chance + 0.03;
    if Chance > 1.2 then
      raise Exception.Create('Error in TPlanet.SetCurInvention');
  until Found;
end;
{ @end $79061C }

{ @routine $790788 TPlanet_AdvanceInventionProgress }
procedure TPlanet.AdvanceInventionProgress;
var
  Track: TPlanetInvention;
  Average, Progress: Double;
  Complete, RaiseCeiling: Boolean;
  Count: Integer;
begin
  Complete := True;
  for Track := Low(TPlanetInvention) to High(TPlanetInvention) do
    if InventionLevels[Track] < 8 then Complete := False;
  if Complete then Exit;
  Progress := CalculateInventionProgressRate;
  Progress := Progress * aConst.GalaxyDifficultyTuning[aGalaxy.Galaxy.DifficultyLevels[4]].InventionProgressScale;
  CurrentInventionPoints := CurrentInventionPoints + Progress;
  if CurrentInventionPoints > 100 then
  begin
    InventionLevels[CurrentInvention] := Min(8, InventionLevels[CurrentInvention] + 1);
    CurrentInventionPoints := 0;
    Complete := True;
    for Track := Low(TPlanetInvention) to High(TPlanetInvention) do
      if InventionLevels[Track] < 8 then Complete := False;
    if Complete then Exit;
    RaiseCeiling := True;
    repeat
      for Track := Low(TPlanetInvention) to High(TPlanetInvention) do
        if (ResearchLevelPercent > System.Round(InventionLevels[Track] * 12.5)) and
          (aConst.PlanetInventionInfo[Track].RequiredMainTechLevel <= InventionLevels[piMainTech]) and
          (InventionLevels[Track] <= InventionLevels[piMainTech]) then RaiseCeiling := False;
      if not RaiseCeiling then
      begin
        Average := 0;
        Count := 0;
        for Track := Low(TPlanetInvention) to High(TPlanetInvention) do
          if aConst.PlanetInventionInfo[Track].RequiredMainTechLevel <= InventionLevels[piMainTech] then
          begin
            Average := Average + InventionLevels[Track] * 12.5;
            Inc(Count);
          end;
        if Count = 0 then Count := 1;
        Average := Average / Count;
        if ResearchLevelPercent < Average then RaiseCeiling := True;
      end;
      if RaiseCeiling then
        if ResearchLevelPercent + ResearchLevelStep < 100 then
          ResearchLevelPercent := ResearchLevelPercent + ResearchLevelStep
        else ResearchLevelPercent := 100;
    until not RaiseCeiling;
    SelectCurrentInvention;
  end;
end;
{ @end $790788 }

{ @routine $7909E8 TPlanet_CalculateInventionProgressRate }
function TPlanet.CalculateInventionProgressRate: Single;
begin
  Result := RemapClamped(Radius, 60, 100, 0.7, 1.3) *
    (aConst.PlanetEconomyInfo[Economy].InventionProgressScale * aConst.PlanetRaceMarket[RaceId].InventionProgressScale);
end;
{ @end $7909E8 }

{ @routine $790A58 TPlanet_BuyRanger }
function TPlanet.BuyRanger(MoneyPercent: Integer): Pointer;
var
  Budget: Integer;
  Ranger: TRanger;
begin
  Ranger := TRanger.Create;
  Inc(HomeRangerCount);
  if aGalaxy.Galaxy.CurrentTurn < GalaxyWarmupTurns then Budget := aGalaxy.Galaxy.MaxRangerWealth
  else Budget := Min(Int64(aGalaxy.Galaxy.AverageRangerCapital),
    System.Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1, 0.4, 0.6) * aGalaxy.Galaxy.MaxRangerWealth));
  if Budget > 500000 then Budget := 500000;
  Budget := System.Round(Budget * 0.01 * MoneyPercent);
  Ranger.InitializeAtPlanet(Self, Budget);
  Result := Ranger;
  CurrentStar.DaysSinceLastNpcShipSpawn := 0;
end;
{ @end $790A58 }

{ @routine $790B90 TPlanet_SpawnTransport }
function TPlanet.SpawnTransport(Kind: Byte; MoneyPercent: Integer): Pointer;
var
  Budget: Integer;
  Transport: TTransport;
  SubType: TTransportType;
begin
  Transport := TTransport.Create;
  Budget := System.Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1, 0.2, 0.4) * aGalaxy.Galaxy.MaxRangerWealth);
  if Budget > 600000 then Budget := 600000;
  Budget := System.Round(Budget * 0.01 * MoneyPercent);
  if Kind = 0 then Transport.InitGenerated(Self, Budget, ttTransport, True)
  else
  begin
    if Kind = 3 then SubType := ttTransport
    else if Kind = 4 then SubType := ttLiner
    else SubType := ttDiplomat;
    Transport.InitGenerated(Self, Budget, SubType, False);
  end;
  Result := Transport;
  CurrentStar.DaysSinceLastNpcShipSpawn := 0;
end;
{ @end $790B90 }

{ @routine $790C90 TPlanet_BuyPirate }
function TPlanet.BuyPirate(MoneyPercent: Integer): Pointer;
var
  Budget: Integer;
  Pirate: TPirate;
begin
  Pirate := TPirate.Create;
  Budget := System.Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1, 0.3, 0.5) * aGalaxy.Galaxy.MaxRangerWealth);
  if Budget > 800000 then Budget := 800000;
  Budget := System.Round(Budget * 0.01 * MoneyPercent);
  Pirate.InitGenerated(Self, Budget, 0);
  Result := Pirate;
  CurrentStar.DaysSinceLastNpcShipSpawn := 0;
end;
{ @end $790C90 }

{ @routine $790D50 TPlanet_SpawnTranclucator }
function TPlanet.SpawnTranclucator(BasicEquipment: Boolean): Pointer;
var Ship: TTranclucator;
begin
  Ship := TTranclucator.Create;
  Ship.Init(nil, OwnerId, BasicEquipment);
  Ship.CurrentPlanet := Self;
  Ship.CurrentStar := CurrentStar;
  CurrentStar.Ships.Add(Ship);
  Result := Ship;
end;
{ @end $790D50 }

{ @routine $790DB4 TPlanet_BuyWarrior }
function TPlanet.BuyWarrior(MoneyPercent: Integer): Pointer;
var
  Budget: Integer;
  Warrior: TWarrior;
  Pirate: TPirate;
  Kind: Integer;
begin
  if OwnerId = oiPirate then
  begin
    Pirate := TPirate.Create;
    Budget := System.Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1, 0.3, 0.5) * aGalaxy.Galaxy.MaxRangerWealth);
    if Budget > 800000 then Budget := 800000;
    Budget := System.Round(RemapClamped(aGalaxy.Galaxy.GetFactionControlPercent(sfDominators) +
      aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition), 0, 100, Budget * 0.7, Budget * 1.2));
    if NextRandomUnitFloat(RandomState) > 0.2 then
      Budget := System.Round(RemapClamped(aGalaxy.Galaxy.WarDeltaWin[2], -5, 5, Budget * 2, Budget * 0.5));
    Budget := System.Round(Budget * 0.01 * MoneyPercent);
    Kind := NextRandomIntRange(0, 9, RandomState);
    if Kind <= 3 then Pirate.InitGenerated(Self, Budget, 1)
    else if Kind <= 7 then Pirate.InitGenerated(Self, Budget, 2)
    else Pirate.InitGenerated(Self, Budget, 3);
    Result := Pirate;
  end
  else
  begin
    Warrior := TWarrior.Create;
    Budget := System.Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1, 0.3, 0.5) * aGalaxy.Galaxy.MaxRangerWealth);
    if Budget > 900000 then Budget := 900000;
    Budget := System.Round(RemapClamped(aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition), 0, 100, Budget * 1.2, Budget * 0.7));
    if NextRandomUnitFloat(RandomState) > 0.2 then
      Budget := System.Round(RemapClamped(aGalaxy.Galaxy.WarDeltaWin[0], -5, 5, Budget * 2, Budget * 0.5));
    Budget := System.Round(Budget * 0.01 * MoneyPercent);
    Warrior.InitGenerated(Self, Budget, wtRegular);
    Result := Warrior;
  end;
  CurrentStar.DaysSinceLastNpcShipSpawn := 0;
end;
{ @end $790DB4 }

{ @routine $791124 TPlanet_BuyFlagship }
function TPlanet.BuyFlagship(MoneyPercent: Integer): Pointer;
var
  Budget: Integer;
  Warrior: TWarrior;
begin
    Warrior := TWarrior.Create;
    Budget := System.Round(RemapClamped(NextRandomUnitFloat(RandomState), 0, 1, 0.3, 0.5) * aGalaxy.Galaxy.MaxRangerWealth);
    if Budget > 900000 then Budget := 900000;
    Budget := System.Round(RemapClamped(aGalaxy.Galaxy.GetFactionControlPercent(sfCoalition), 0, 100, Budget * 1.2, Budget * 0.7));
    if NextRandomUnitFloat(RandomState) > 0.2 then
      Budget := System.Round(RemapClamped(aGalaxy.Galaxy.WarDeltaWin[0], -5, 5, Budget * 2, Budget * 0.5));
    Budget := System.Round(Budget * 0.01 * MoneyPercent);
    Warrior.InitGenerated(Self, Budget, wtFlagship);
    Result := Warrior;
  CurrentStar.DaysSinceLastNpcShipSpawn := 0;
end;
{ @end $791124 }

{ @routine $7912D0 TPlanet_SpawnWeightedDominatorShip }
function TPlanet.SpawnWeightedDominatorShip: Pointer;
var
  Level, Roll, Accumulated: Integer;
  Kind, LargestKind: TKlingType;
  Total, LargestWeight: Integer;
begin
  Level := System.Round(RemapClamped(aGalaxy.Galaxy.CountFactionStars(sfDominators), 0, 100, 5, 1));
  Total := 0;
  LargestKind := ktBoss;
  LargestWeight := 0;
  for Kind := ktBoss to ktKlig do
  begin
    if Kind = ktBoss then Continue;
    if (Kind = ktBertor) and
      (CurrentStar.Constellation.HasBertorOfSeries(CurrentStar.DominatorSeries) or
       (aKling.DominatorSpawnPlanet = Self)) then Continue;
    Inc(Total, DominatorSpawnWeights[Level, Ord(Kind)]);
    if (DominatorSpawnWeights[Level, Ord(Kind)] > LargestWeight) or (LargestKind = ktBoss) then
    begin
      LargestWeight := DominatorSpawnWeights[Level, Ord(Kind)];
      LargestKind := Kind;
    end;
  end;
  Accumulated := 0;
  Roll := NextRandomIntRange(0, Total, RandomState);
  for Kind := ktBoss to ktKlig do
  begin
    if Kind = ktBoss then Continue;
    if (Kind = ktBertor) and
      (CurrentStar.Constellation.HasBertorOfSeries(CurrentStar.DominatorSeries) or
       (aKling.DominatorSpawnPlanet = Self)) then Continue;
    Inc(Accumulated, DominatorSpawnWeights[Level, Ord(Kind)]);
    if Roll <= Accumulated then
    begin
      Result := SpawnDominatorShip(Kind);
      Exit;
    end;
  end;
  Result := SpawnDominatorShip(ktShtip);
end;
{ @end $7912D0 }

{ @routine $79146C TPlanet_SpawnDominatorShip }
function TPlanet.SpawnDominatorShip(Kind: TKlingType): Pointer;
var
  Ship: TKling;
  Series: TDominatorSeries;
begin
  Ship := TKling.Create;
  Series := CurrentStar.DominatorSeries;
  if CurrentStar.ControlFaction <> sfDominators then
  begin
    if (Series = dsTerron) and (aKling.TerronShip <> nil) and
      (aGalaxy.Galaxy.TerronToStarTurn >= TerronTransformationFlag) then Series := dsKeller;
    if (Series = dsBlazer) and (aGalaxy.Galaxy.BlazerSelfDestructTurn <> 0) then Series := dsKeller;
  end;
  Ship.InitGenerated(Kind, Self, Series);
  Result := Ship;
  CurrentStar.DaysSinceLastNpcShipSpawn := 0;
end;
{ @end $79146C }

{ @routine $79150C TPlanet_GenerateShipForScriptGroup }
function TPlanet.GenerateShipForScriptGroup(Group: Pointer): Pointer;
var
  Rules: TObject;
  Ship: TShip;
  Owner, SelectedOwner, OldOwner, OldRace: TOwnerId;
  Series, SelectedSeries, OldSeries: TDominatorSeries;
  Kind, SelectedKind: TKlingType;
  ShipKind, SelectedShipKind: THullType;
  i, j, Count: Integer;
  Found: Boolean;
  OldTechLevel: Integer;
begin
  Rules := TObject(Group) as TScriptGroup;
  if OwnerId in TScriptGroup(Rules).OwnerMask then SelectedOwner := OwnerId
  else
  begin
    SelectedOwner := oiMaloc;
    Count := 0;
    for Owner := oiMaloc to oiPirate do
      if Owner in TScriptGroup(Rules).OwnerMask then Inc(Count);
    Count := NextRandomIntRange(1, Count, RandomState);
    for Owner := oiMaloc to oiPirate do
      if Owner in TScriptGroup(Rules).OwnerMask then
      begin
        Dec(Count);
        SelectedOwner := Owner;
        if Count <= 0 then Break;
      end;
  end;
  SelectedShipKind := htRanger;
  SelectedKind := ktBoss;
  SelectedSeries := dsBlazer;
  Count := 0;
  for ShipKind := Low(THullType) to High(THullType) do
    if ShipKind in TScriptGroup(Rules).ShipTypeMask then
    begin
      if ShipKind = htKling then
      begin
        for Kind := ktBoss to ktKlig do
          for Series := dsBlazer to dsTerron do
            if Byte(Series) in TScriptGroup(Rules).DominatorMasks[Ord(Kind)] then Inc(Count);
      end
      else Inc(Count);
    end;
  Count := NextRandomIntRange(1, Count, RandomState);
  Found := False;
  for ShipKind := Low(THullType) to High(THullType) do
  begin
    if not (ShipKind in TScriptGroup(Rules).ShipTypeMask) then Continue;
    if ShipKind = htKling then
    begin
      for Kind := ktBoss to ktKlig do
      begin
        for Series := dsBlazer to dsTerron do
        begin
          if Byte(Series) in TScriptGroup(Rules).DominatorMasks[Ord(Kind)] then
          begin
            Dec(Count);
            SelectedKind := Kind;
            SelectedShipKind := ShipKind;
            SelectedSeries := Series;
            Found := Count <= 0;
          end;
          if Found then Break;
        end;
        if Found then Break;
      end;
    end
    else
    begin
      Dec(Count);
      SelectedShipKind := ShipKind;
      Found := Count <= 0;
    end;
    if Found then Break;
  end;
  Result := nil;
  if (SelectedShipKind = htKling) and (SelectedKind = ktBoss) then Exit;
  OldOwner := OwnerId;
  OwnerId := SelectedOwner;
  OldRace := RaceId;
  if OwnerId in [oiMaloc..oiGaal] then RaceId := OwnerToRace(OwnerId);
  OldSeries := CurrentStar.DominatorSeries;
  CurrentStar.DominatorSeries := SelectedSeries;
  OldTechLevel := aGalaxy.Galaxy.TechLevel;
  i := 0;
  Ship := nil;
  while Ship = nil do
  begin
    case SelectedShipKind of
      htRanger: Ship := TObject(BuyRanger(100)) as TShip;
      htWarrior: Ship := TObject(BuyWarrior(100)) as TShip;
      htPirate: Ship := TObject(BuyPirate(100)) as TShip;
      htTransport..htDiplomat: Ship := TObject(SpawnTransport(Byte(SelectedShipKind), 100)) as TShip;
      htKling: Ship := TObject(SpawnDominatorShip(SelectedKind)) as TShip;
      htTranclucator: Ship := TObject(SpawnTranclucator(True)) as TShip;
    end;
    Inc(i);
    if i mod 50 = 0 then aGalaxy.Galaxy.TechLevel := Min(8, aGalaxy.Galaxy.TechLevel + 1);
    if TScriptGroup(Rules).MinCargoHookLevel > 0 then
      if Ship.GetSlotCount(sskCargoHook) < 1 then
      begin
        Ship.Free;
        Ship := nil;
      end;
  end;
  aGalaxy.Galaxy.TechLevel := OldTechLevel;
  if Ship <> nil then
  begin
    i := 0;
    repeat
      Inc(Money, aGalaxy.Galaxy.ComputeScaledSmallMoney(OwnerId));
      if TScriptGroup(Rules).MinCargoHookLevel > 0 then
      begin
        if (Ship.GetCargoHook <> nil) and (Ship.GetCargoHook.TechLevel >= TScriptGroup(Rules).MinCargoHookLevel) then
          Ship.LiquidateInventoryItem(Ship.GetCargoHook);
        Ship.CreateAndEquipCargoHook(System.Round(aConst.CargoHookBaseSize), TScriptGroup(Rules).MinCargoHookLevel, OwnerId);
        Ship.RefreshDerivedStats(True);
      end;
      if TScriptGroup(Rules).MinSpeed > Ship.Speed then Ship.ImproveRandomEquipment(True);
      Ship.RefreshDerivedStats(True);
      if (TScriptGroup(Rules).MinStrength > Ship.StrengthInBestRanger) and (TScriptGroup(Rules).WeaponRequirement = 1) then
        Ship.ImproveRandomEquipment(True);
      Ship.RefreshDerivedStats(True);
      if (TScriptGroup(Rules).MinStrength > Ship.StrengthInBestRanger) and (TScriptGroup(Rules).WeaponRequirement = 1) then
        Ship.ImproveRandomEquipment(True);
      Ship.RefreshDerivedStats(True);
      if (TScriptGroup(Rules).MaxStrength < Ship.StrengthInBestRanger) and (TScriptGroup(Rules).WeaponRequirement = 1) then
        if Ship.CountEquippedWeapons > 1 then Ship.LiquidateInventoryItem(Ship.Weapons[1]);
      Ship.RefreshDerivedStats(True);
      if (TScriptGroup(Rules).MaxStrength < Ship.StrengthInBestRanger) and (TScriptGroup(Rules).WeaponRequirement = 1) then
        if Ship.GetDefGenerator <> nil then Ship.LiquidateInventoryItem(Ship.GetDefGenerator);
      if (TScriptGroup(Rules).WeaponRequirement = 2) and (Ship.WeaponCount > 0) then
        for j := Ship.WeaponCount downto 1 do Ship.LiquidateInventoryItem(Ship.Weapons[j]);
      Inc(i);
    until i = 11;
  end;
  if Ship <> nil then
    if Ship.GetCargoFreeSpace < TScriptGroup(Rules).MinFreeCargoSpace then
    begin
      Inc(Ship.GetHull.Weight, TScriptGroup(Rules).MinFreeCargoSpace - Ship.CargoFreeSpace);
      Ship.GetHull.HullPoints := Ship.GetHull.Weight;
      Ship.RefreshDerivedStats(True);
    end;
  if (Ship <> nil) and (Ship is TRanger) then
  begin
    // Native code complements the Byte before testing the range. Preserve
    // that behavior rather than interpreting it as a negated membership test.
    if (not (Ship as TRanger).CareerStatus[rcTrader]) in [TScriptGroup(Rules).MinTraderStatus..TScriptGroup(Rules).MaxTraderStatus] then
    begin
      (Ship as TRanger).CareerStatus[rcTrader] := (TScriptGroup(Rules).MinTraderStatus + TScriptGroup(Rules).MaxTraderStatus) div 2;
      (Ship as TRanger).CareerStatus[rcPirate] := (100 - (Ship as TRanger).CareerStatus[rcTrader]) div 2;
      (Ship as TRanger).CareerStatus[rcWarrior] := 100 - (Ship as TRanger).CareerStatus[rcTrader] - (Ship as TRanger).CareerStatus[rcPirate];
    end;
    if (not (Ship as TRanger).CareerStatus[rcPirate]) in [TScriptGroup(Rules).MinPirateStatus..TScriptGroup(Rules).MaxPirateStatus] then
    begin
      (Ship as TRanger).CareerStatus[rcPirate] := (TScriptGroup(Rules).MinPirateStatus + TScriptGroup(Rules).MaxPirateStatus) div 2;
      (Ship as TRanger).CareerStatus[rcTrader] := (100 - (Ship as TRanger).CareerStatus[rcPirate]) div 2;
      (Ship as TRanger).CareerStatus[rcWarrior] := 100 - (Ship as TRanger).CareerStatus[rcPirate] - (Ship as TRanger).CareerStatus[rcTrader];
    end;
    if (not (Ship as TRanger).CareerStatus[rcWarrior]) in [TScriptGroup(Rules).MinWarriorStatus..TScriptGroup(Rules).MaxWarriorStatus] then
    begin
      (Ship as TRanger).CareerStatus[rcWarrior] := (TScriptGroup(Rules).MinWarriorStatus + TScriptGroup(Rules).MaxWarriorStatus) div 2;
      (Ship as TRanger).CareerStatus[rcTrader] := (100 - (Ship as TRanger).CareerStatus[rcWarrior]) div 2;
      (Ship as TRanger).CareerStatus[rcPirate] := 100 - (Ship as TRanger).CareerStatus[rcWarrior] - (Ship as TRanger).CareerStatus[rcTrader];
    end;
  end;
  Ship.RefreshDerivedStats(True);
  if (OwnerId <> OldOwner) or (RaceId <> OldRace) then
  begin
    RaceId := OldRace;
    OwnerId := OldOwner;
    Ship.HomePlanet := TObject(FindNearestPlanetByOwnerMask([Ship.OwnerId])) as TPlanet;
    if Ship.HomePlanet = nil then Ship.HomePlanet := Self;
    if Ship is TWarrior then
    begin
      i := Warriors.IndexOf(Ship);
      if i >= 0 then Warriors.Delete(i);
      i := Ship.HomePlanet.Warriors.IndexOf(Ship);
      if i < 0 then Ship.HomePlanet.Warriors.Add(Ship);
    end;
  end;
  CurrentStar.DominatorSeries := OldSeries;
  Result := Ship;
end;
{ @end $79150C }

{ @routine $791EC0 TPlanet_RelationToRanger }
function TPlanet.RelationToRanger(RangerIndex: Integer): Integer;
begin
  try
    if (OwnerId = oiPirate) and not IsMainPiratePlanet and (MainPiratePlanet <> nil) then
      Result := MainPiratePlanet.RelationToRanger(RangerIndex)
    else if IsMainPiratePlanet and (OwnerId <> oiPirate) then
      Result := 50
    else
      Result := TPercent(Integer(RangerRelations[RangerIndex]));
  except
    on E: SysUtils.Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise SysUtils.Exception.Create('Error in procedure TPlanet.RelationToRanger ' + Name +
        ' planet owner = ' + SysUtils.IntToStr(Ord(OwnerId)) + ' i = ' + SysUtils.IntToStr(RangerIndex) +
        ' count = ' + SysUtils.IntToStr(RangerRelations.Count));
    end;
  end;
end;
{ @end $791EC0 }

{ @routine $7921FC TPlanet_SetRelationLevelToRanger }
procedure TPlanet.SetRelationLevelToRanger(Ranger: Pointer; Level: TRelationLevel);
begin
  case Level of
    rlHostile: RangerRelations[aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)] := Pointer(5);
    rlBad: RangerRelations[aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)] := Pointer(20);
    rlNormal: RangerRelations[aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)] := Pointer(45);
    rlGood: RangerRelations[aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)] := Pointer(70);
    rlExcellent: RangerRelations[aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)] := Pointer(90);
  else
    RangerRelations[aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)] := Pointer(5);
  end;
end;
{ @end $7921FC }

{ @routine $792384 TPlanet_ChangeRelationToRanger }
procedure TPlanet.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var
  Relation: Byte;
  Index: Integer;
begin
  Index := aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(RangerRelations[Index]);
  if ((TObject(Ranger) as TRanger).GetEffectiveSkillLevel(psCharisma) > 0) and (Amount > 0) then
    Inc(Amount, System.Round(((TObject(Ranger) as TRanger).GetEffectiveSkillLevel(psCharisma)) * Amount * 0.2));
  if Relation + Amount in [0..100] then Inc(Relation, Amount)
  else if Relation + Amount > 100 then Relation := 100
  else Relation := 0;
  RangerRelations[Index] := Pointer(Relation);
  if (GetPlayer = Ranger) and (GetRelationLevelToShip(Ranger) <= rlHostile) then
    GetPlayer.AchievementStats.CheckHaterAchievement;
  if GetPlayer = Ranger then
  begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then
      GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $792384 }

{ @routine $7924F0 TPlanet_RelationToShip }
function TPlanet.RelationToShip(Ship: Pointer): TPercent;
begin
  if (GetPlayer <> nil) and (GetPlayer = Ship) and
    (GetPlayer.PirateRank = 7) and (CurrentStar.Constellation.Id = 20) and
    not IsMainPiratePlanet and (OwnerId = oiPirate) then
  begin
    Result := 100;
    Exit;
  end;
  if OwnerId = oiUninhabited then
  begin
    Result := 100;
    Exit;
  end;
  Result := 0;
  if CurrentStar.Status.CustomFaction <> '' then
  begin
    if TShip(Ship).ScriptShip <> nil then
      if TScriptShip(TShip(Ship).ScriptShip).StateText = CurrentStar.Status.CustomFaction then Result := 100;
    Exit;
  end;
  if OwnerId in [oiMaloc..oiGaal, oiPirate] then
  begin
    if ((TObject(Ship) as TShip).CurrentStar = CurrentStar) and
      (not IsMainPiratePlanet or (GetPlayer <> Ship)) then
    begin
      if (OwnerId in aConst.PlanetOwnerMasks.PirateClan) and
        ((TObject(Ship) as TShip).CurrentStanding in [ssCoalitionMilitary, ssCoalitionActive]) then Exit;
      if (OwnerId in aConst.PlanetOwnerMasks.Coalition) and
        ((TObject(Ship) as TShip).CurrentStanding in [ssPirateActive, ssPirateMilitary]) then Exit;
    end;
    case (TObject(Ship) as TShip).TypeId of
      stRanger: Result := RelationToRanger(aGalaxy.Galaxy.Rangers.IndexOf(TObject(Ship) as TRanger));
      stTransport:
        if OwnerId in aConst.PlanetOwnerMasks.PirateClan then
          Result := Min(50, Integer(aConst.OwnerRelations[OwnerId, (TObject(Ship) as TTransport).OwnerId]))
        else
          Result := aConst.OwnerRelations[OwnerId, (TObject(Ship) as TTransport).OwnerId];
      stPirate:
        if OwnerId in aConst.PlanetOwnerMasks.PirateClan then
        begin
          if TShip(Ship).OwnerId = oiPirate then Result := 100
          else Result := aConst.OwnerRelations[OwnerId, TShip(Ship).OwnerId];
        end
        else
          Result := Max(Int64(30), Min(Int64(aConst.PlanetRaceMarket[RaceId].PirateRelationCeiling),
            System.Round(aConst.OwnerRelations[OwnerId, (TObject(Ship) as TPirate).OwnerId] *
              aConst.PlanetRaceMarket[RaceId].PirateRelationFactor)));
      stWarrior:
        if OwnerId in aConst.PlanetOwnerMasks.PirateClan then Result := 0
        else Result := 100;
      stKling: Result := 0;
      stTranclucator:
        if (TObject(Ship) as TTranclucator).OwnerShip <> nil then
          Result := RelationToShip((TObject(Ship) as TTranclucator).OwnerShip)
        else Result := 50;
      rstRangerCenter..rstCustomStation:
        if (TObject(Ship) as TShip).CurrentStanding in aConst.FactionStandingMasks[CurrentStar.ControlFaction] then Result := 100
        else Result := 0;
    else Result := 50;
    end;
  end
  else if OwnerId = oiDominator then
    if (TObject(Ship) as TShip).TypeId in [stKling] then Result := 100
    else Result := 0;
end;
{ @end $7924F0 }

{ @routine $792980 TPlanet_GetRelationLevelToShip }
function TPlanet.GetRelationLevelToShip(Ship: Pointer): TRelationLevel;
begin
  case RelationToShip(Ship) of
    0..9: Result := rlHostile;
    10..29: Result := rlBad;
    30..59: Result := rlNormal;
    60..79: Result := rlGood;
    80..100: Result := rlExcellent;
  else
    Result := rlNormal;
  end;
  if IsMainPiratePlanet and (GetPlayer = Ship) and (GetPlayer.CurrentPlanet = Self) and (Result = rlHostile) then
    Result := rlBad;
end;
{ @end $792980 }

{ @routine $792A18 TPlanet_GetRelationLevelTextToShip }
function TPlanet.GetRelationLevelTextToShip(Ship: Pointer): WideString;
begin
  Result := aConst.RelationInfo[GetRelationLevelToShip(Ship)].DisplayName;
end;
{ @end $792A18 }

{ @routine $792A50 TPlanet_GetCivilInfoText }
function TPlanet.GetCivilInfoText: WideString;
var Text: WideString;
begin
  Text := LocalizedText('Planet.Civil.Info.TextAboutPlanet');
  ReplaceTextToken(Text, '<Planet>', Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Star>', CurrentStar.Name, TextHighlightColorTag);
  if IsMainPiratePlanet then ReplaceTextToken(Text, '<Race>', aConst.OwnerInfo[OwnerId].DisplayName, TextHighlightColorTag)
  else ReplaceTextToken(Text, '<Race>', GetNativeRaceName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Population>', WideString(IntToStr(Round(Population / 1000))), TextHighlightColorTag);
  ReplaceTextToken(Text, '<Economy>', aConst.PlanetEconomyInfo[Economy].DisplayName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Goverment>', GetGovernmentName, TextHighlightColorTag);
  ReplaceTextToken(Text, '<Relation>', GetRelationLevelTextToShip(GetPlayer), TextHighlightColorTag);
  if (GetRelationLevelToShip(GetPlayer) <= rlBad) and not IsMainPiratePlanet then
    Text := Text + #13#10 + LocalizedText('Planet.Civil.Info.BadDopInfo');
  Result := Text;
end;
{ @end $792A50 }

{ @routine $792DB0 TPlanet_HasHostileShipsInSystem }
function TPlanet.HasHostileShipsInSystem: Boolean;
var
  i: Integer;
  Ship: TShip;
begin
  for i := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[i];
    if Ship.InNormalSpace then
      if RelationToShip(Ship) < RelationBadMin then
      begin
        Result := True;
        Exit;
      end;
  end;
  Result := False;
end;
{ @end $792DB0 }

{ @routine $792E20 TPlanet_SelectEquipmentOfferSpecialMicroModule }
function TPlanet.SelectEquipmentOfferSpecialMicroModule(Item: TEquipment): Integer;
var
  Selected, Count, Ceiling, Minimum, Maximum, i, Candidate: Integer;
  Template: PMicroModuleTemplate;
begin
  Result := -1;
  if not IsMainPiratePlanet then
    if NextRandomIntRange(1, 100, RandomState) > aGalaxy.Galaxy.GetMicroModuleOfferRollThresholdPercent then Exit;
  Ceiling := System.Round(InventionLevels[piMainTech] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := Pointer(aConst.MicroModuleTemplates);
  for i := 0 to aConst.MicroModuleTemplateCount - 1 do
  begin
    if Template.SpecialOnly and
      ((not IsMainPiratePlanet) or ([rstPirateBase, rstDominion] * Template.OfferStationTypes <> [])) and
      (IsMainPiratePlanet or Template.OnPlanets) and
      IsBonusCompatibleWithEquipment(i, Item) and (Template.Priority <= Ceiling) then
    begin
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
      aConst.MicroModuleCandidateIndices[Count] := i;
      Inc(Count);
    end;
    Template := Pointer(PAnsiChar(Template) + SizeOf(TMicroModuleInfo));
  end;
  Selected := -1;
  if Count > 0 then
  begin
    Minimum := Max(0, Maximum - 40);
    for i := 0 to 10 do
    begin
      Candidate := NextRandomIntRange(0, Count - 1, RandomState);
      if aConst.MicroModuleTemplates[aConst.MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
      begin
        Selected := aConst.MicroModuleCandidateIndices[Candidate];
        Break;
      end;
    end;
  end;
  Result := Selected;
end;
{ @end $792E20 }

{ @routine $793084 TPlanet_SelectHullOfferSpecialMicroModule }
function TPlanet.SelectHullOfferSpecialMicroModule(Hull: THull): Integer;
var
  Selected, Count, Ceiling, Minimum, Maximum, i, Candidate: Integer;
  Template: PMicroModuleTemplate;
begin
  Result := -1;
  if not IsMainPiratePlanet then
    if NextRandomIntRange(1, 100, RandomState) > aGalaxy.Galaxy.GetMicroModuleOfferRollThresholdPercent then Exit;
  Ceiling := System.Round(InventionLevels[piMainTech] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := Pointer(aConst.MicroModuleTemplates);
  for i := 0 to aConst.MicroModuleTemplateCount - 1 do
  begin
    if Template.SpecialOnly and
      ((not IsMainPiratePlanet) or ([rstPirateBase, rstDominion] * Template.OfferStationTypes <> [])) and
      (IsMainPiratePlanet or Template.OnPlanets) and
      IsBonusCompatibleWithHull(i, Hull) and (Template.Priority <= Ceiling) then
    begin
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
      aConst.MicroModuleCandidateIndices[Count] := i;
      Inc(Count);
    end;
    Template := Pointer(PAnsiChar(Template) + SizeOf(TMicroModuleInfo));
  end;
  Selected := -1;
  if Count > 0 then
  begin
    Minimum := Max(0, Maximum - 40);
    for i := 0 to 10 do
    begin
      Candidate := NextRandomIntRange(0, Count - 1, RandomState);
      if aConst.MicroModuleTemplates[aConst.MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
      begin
        Selected := aConst.MicroModuleCandidateIndices[Candidate];
        Break;
      end;
    end;
  end;
  Result := Selected;
end;
{ @end $793084 }

{ @routine $7932E8 TPlanet_SelectWeaponOfferSpecialMicroModule }
function TPlanet.SelectWeaponOfferSpecialMicroModule(Weapon: TWeapon): Integer;
var
  Selected, Count, Ceiling, Minimum, Maximum, i, Candidate: Integer;
  Template: PMicroModuleTemplate;
begin
  Result := -1;
  if not IsMainPiratePlanet then
    if NextRandomIntRange(1, 100, RandomState) > aGalaxy.Galaxy.GetMicroModuleOfferRollThresholdPercent then Exit;
  Ceiling := System.Round(InventionLevels[piMainTech] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := Pointer(aConst.MicroModuleTemplates);
  for i := 0 to aConst.MicroModuleTemplateCount - 1 do
  begin
    if Template.SpecialOnly and
      ((not IsMainPiratePlanet) or ([rstPirateBase, rstDominion] * Template.OfferStationTypes <> [])) and
      (IsMainPiratePlanet or Template.OnPlanets) and
      IsBonusCompatibleWithWeapon(i, Weapon) and (Template.Priority <= Ceiling) then
    begin
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
      aConst.MicroModuleCandidateIndices[Count] := i;
      Inc(Count);
    end;
    Template := Pointer(PAnsiChar(Template) + SizeOf(TMicroModuleInfo));
  end;
  Selected := -1;
  if Count > 0 then
  begin
    Minimum := Max(0, Maximum - 40);
    for i := 0 to 10 do
    begin
      Candidate := NextRandomIntRange(0, Count - 1, RandomState);
      if aConst.MicroModuleTemplates[aConst.MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
      begin
        Selected := aConst.MicroModuleCandidateIndices[Candidate];
        Break;
      end;
    end;
  end;
  Result := Selected;
end;
{ @end $7932E8 }

{ @routine $79354C TPlanet_RefreshEquipmentShopInventory }
procedure TPlanet.RefreshEquipmentShopInventory;
var
  Index, Attempts: Integer;
  Item: TEquipment;
  ItemType: TItemType;
begin
  if TShopUpdateMode(ShopUpdateMode) in [sumDisabled, sumGoodsOnly] then Exit;
  if (aGalaxy.Galaxy.CurrentTurn + Integer(GenerationSeed)) mod 7 = 0 then
  begin
    if CalculateEquipmentShopTargetCount <= EquipmentShop.Count then
      if (SeededRandomUnitFloat(StepRandomSeed(aGalaxy.Galaxy.CurrentTurn + Integer(GenerationSeed) + 17)) < 0.5) or
        IsMainPiratePlanet then
      begin
        Index := SeededRandomIntRange(0, EquipmentShop.Count - 1, aGalaxy.Galaxy.CurrentTurn * GenerationSeed);
        Item := TEquipment(EquipmentShop[Index]);
        if (Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '') then
        begin
          EquipmentShop.Delete(Index);
          Item.Free;
        end;
      end;
    if ((CalculateEquipmentShopTargetCount >= EquipmentShop.Count) and
      (SeededRandomUnitFloat(StepRandomSeed(aGalaxy.Galaxy.CurrentTurn + Integer(GenerationSeed))) < 0.5)) or
      (NextRandomIntRange(1, 100, RandomState) < 30) or IsMainPiratePlanet then
    begin
      Attempts := 0;
      repeat
        Inc(Attempts);
        ItemType := TItemType(SeededRandomIntRange(42, 52, aGalaxy.Galaxy.CurrentTurn * GenerationSeed * 175 + Attempts));
      until (Attempts > 30) or
        (CountEquipmentShopItemsInBucket(ItemType) < aConst.PlanetEquipmentOfferQuotas[RaceId][ItemType]);
      Item := GenerateEquipmentOffer(GetPlayer, ItemType);
      if Item <> nil then
      begin
        EquipmentShop.Add(Item);
        RemoveSimilarEquipmentShopItem(Item);
      end;
    end;
  end;
end;
{ @end $79354C }

{ @routine $793758 TPlanet_GenerateHullOffer }
function TPlanet.GenerateHullOffer(Ship: Pointer): THull;
var
  Target: TShip;
  Attempts, MinLevel, MaxLevel, MinSize, MaxSize, Size: Integer;
  HullType: THullType; Owner: TOwnerId;
  Series, ModuleIndex: Integer;
  Flagship: Boolean;
begin
  Result := nil;
  if (Ship = nil) or not (TObject(Ship) is TShip) then Exit;
  Target := Ship;
  HullType := htRanger;
  Attempts := 0;
  while True do
  begin
    if Attempts > 100 then Break;
    Inc(Attempts);
    HullType := THullType(NextRandomIntRange(Ord(htRanger), Ord(htDiplomat), RandomState));
    if (Government = pgAnarchy) and (HullType in [htWarrior, htDiplomat]) then Continue;
    if (Government = pgDictatorship) and (HullType in [htLiner..htDiplomat]) then Continue;
    if (Government = pgRepublic) and (OwnerId <> oiPeleng) and
      (SeededRandomUnitFloat(RandomState) < 0.8) and (HullType in [htPirate]) then Continue;
    if (Government = pgDemocracy) and (OwnerId <> oiPeleng) and (HullType in [htPirate]) then Continue;
    if (OwnerId = oiPirate) and (HullType = htWarrior) then Continue;
    Break;
  end;
  Flagship := (Target is TWarrior) and ((Target as TWarrior).WarriorType = wtFlagship);
  if Flagship then HullType := htFlagship;
  if (GetPlayer <> Target) and (Target.GetHull.HullType <> htSpecial) and
    (Target.GetHull.HullType <> HullType) then Exit;
  MaxLevel := InventionLevels[aConst.EquipmentInventionIndices[t_Hull]];
  MinLevel := Max(1, MaxLevel div 2 - 1);
  case aGalaxy.Galaxy.GetHullGrowthMod of
    1:
      begin
        Size := Target.GetHull.EstimateCapacityWithoutBonuses;
        if Flagship then Size := Size div 2;
        MinSize := Size div 2;
        if HullType in [htTransport..htLiner] then MaxSize := Size + aGalaxy.Galaxy.TechLevel * 40
        else if HullType in [htDiplomat] then MaxSize := Size + aGalaxy.Galaxy.TechLevel * 10
        else MaxSize := Size + aGalaxy.Galaxy.TechLevel * 25;
        MinSize := Max(Int64(MinSize), System.Round(aConst.HullBaseSize * aConst.EquipmentSizeFactors[5]));
        MaxSize := aGalaxy.Galaxy.ScaleIntByTechLevel(System.Round(aConst.HullBaseSize * aConst.EquipmentSizeFactors[4]), MaxSize);
      end;
    2:
      begin
        Size := Target.GetHull.Weight;
        if Flagship then Size := Size div 2;
        MinSize := System.Round(aConst.HullBaseSize * aConst.EquipmentSizeFactors[5]);
        MaxSize := Min(Int64(Size), System.Round(aConst.HullBaseSize *
          aConst.EquipmentSizeFactors[aGalaxy.Galaxy.ScaleIntByTechLevel(5, 1)]));
      end;
  else
    Size := Target.GetHull.Weight;
    if Flagship then Size := Size div 2;
    MinSize := Size div 2;
    if HullType in [htTransport..htLiner] then MaxSize := Size + 300
    else if HullType in [htDiplomat] then MaxSize := Size + 50
    else MaxSize := Size + 200;
    MinSize := Max(Int64(MinSize), System.Round(aConst.HullBaseSize * aConst.EquipmentSizeFactors[5]));
    MaxSize := Min(Int64(MaxSize), System.Round(aConst.HullBaseSize *
      aConst.EquipmentSizeFactors[aGalaxy.Galaxy.ScaleIntByTechLevel(4, 1)]));
  end;
  Owner := RaceToOwner(RaceId);
  if (NextRandomUnitFloat(RandomState) < 0.1) or IsMainPiratePlanet then
    Owner := TOwnerId(NextRandomIntRange(0, 4, RandomState));
  if (GetPlayer <> Target) and IsMainPiratePlanet then Owner := Target.GetHull.OwnerId;
  if (Target.GetHull.OwnerId <> Owner) and (GetPlayer <> Target) then Exit;
  Result := THull.Create;
  Series := -1;
  ModuleIndex := -1;
  Result.OwnerId := Owner;
  Result.PirateBuilt := OwnerId = oiPirate;
  if Target.CanGenerateSpecialHullModule then ModuleIndex := SelectHullOfferSpecialMicroModule(Result);
  if ModuleIndex < 0 then
  begin
    if Target.CanGenerateSpecialHullModule then ModuleIndex := SelectHullOfferSpecialMicroModule(Result);
    Series := aGalaxy.Galaxy.SelectHullSeries(Owner, HullType, 1, 100);
  end;
  if Flagship then
    Result.Init(NextRandomIntRange(MinSize * 2, MaxSize * 2, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner, htFlagship, Series, OwnerId = oiPirate)
  else
    Result.Init(NextRandomIntRange(MinSize, MaxSize, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner, HullType, Series, OwnerId = oiPirate);
  if (Target.GetHull.SpecialModuleIndex > 0) and (GetPlayer <> Target) and
    (ModuleIndex < 0) then ModuleIndex := Target.GetHull.SpecialModuleIndex - 1;
  if ModuleIndex >= 0 then ApplySpecialMicroModule(ModuleIndex, Result);
end;
{ @end $793758 }

{ @routine $793DC4 TPlanet_GenerateWeaponOffer }
function TPlanet.GenerateWeaponOffer(Ship: Pointer): TWeapon;
var
  Target: TShip;
  Attempts, MinLevel, MaxLevel, MinSize, MaxSize: Integer;
  Available: TWeaponAvailabilityMask;
  Info: PWeaponInfo;
  ModuleIndex: Integer;
  Owner: TOwnerId;
begin
  Result := nil;
  if (Ship = nil) or not (TObject(Ship) is TShip) then Exit;
  Target := Ship;
  Available := [waFree];
  if (Target.TypeId = stKling) and (OwnerId in aConst.PlanetOwnerMasks.Dominators) then
    Available := Available + [waNotSoldAndNodeRepair];
  if (Target.TypeId in [stRanger..stWarrior]) and (OwnerId in aConst.PlanetOwnerMasks.Coalition) then
    Available := Available + [waCoalitionOnly] + [aConst.OwnerWeaponAvailability[OwnerId]];
  if (Target.TypeId in [stRanger, stPirate]) and (OwnerId in aConst.PlanetOwnerMasks.PirateClan) then
    Available := Available + [aConst.OwnerWeaponAvailability[OwnerId]];
  Attempts := 0;
  if Attempts <= 100 then
  begin
    Inc(Attempts);
    Info := aGalaxy.Galaxy.SelectWeaponInfo(RandomState, Available, InventionLevels[piMainTech], 1);
    AdvanceRandomSeed(RandomState);
    // The native comparison has no rejecting branch, but both counts are called.
    if not (Target.TypeId in [stRanger, stPirate]) and (Info.ShotType in [wstTorpedo..wstRocket]) then
      if Target.CountDirectFireWeapons > Target.CountMissileWeapons then;
    MinSize := System.Round(Info.AverageSize * aConst.EquipmentSizeFactors[5]);
    MaxSize := System.Round(Info.AverageSize * aConst.EquipmentSizeFactors[1]);
    if (Target is TWarrior) and ((Target as TWarrior).WarriorType = wtFlagship) then
    begin
      MinSize := MinSize * 2;
      MaxSize := MaxSize * 2;
    end;
    MinLevel := 1;
    MaxLevel := Min(InventionLevels[piMainTech], InventionLevels[Info.InventionIndex]);
    if CurrentStar.Constellation.Id = 20 then MaxLevel := Max(MaxLevel, Integer(aGalaxy.Galaxy.TechLevel));
    MinLevel := Max(MinLevel, MaxLevel div 2 - 1);
    Owner := RaceToOwner(RaceId);
    if OwnerId = oiPirate then Owner := oiPirate;
    Result := CreateGeneratedWeapon(Info, NextRandomIntRange(MinSize, MaxSize, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner);
    if (Target is TWarrior) and ((Target as TWarrior).WarriorType = wtFlagship) then
    begin
      Result.DetailImprovement := 3;
      Result.Improve(ikAny);
    end
    else if Target.CanGenerateMicroModuleForLoadout then
    begin
      ModuleIndex := SelectWeaponOfferSpecialMicroModule(Result);
      if ModuleIndex >= 0 then ApplySpecialMicroModule(ModuleIndex, Result);
    end;
  end;
end;
{ @end $793DC4 }

{ @routine $794124 TPlanet_GenerateEquipmentOffer }
function TPlanet.GenerateEquipmentOffer(Ship: Pointer; ItemType: TItemType): TEquipment;
var
  Target: TShip;
  Priority, Attempts, Module, MinLevel, MaxLevel, MinSize, MaxSize, Special: Integer;
  Owner: TOwnerId;
begin
  Result := nil;
  if (Ship = nil) or not (TObject(Ship) is TShip) then Exit;
  Target := Ship;
  if ItemType in [t_FuelTanks..t_DefGenerator] then
  begin
    if not (ItemType in [t_FuelTanks..t_Engine]) and (Target.GetSlotCountForItemType(ItemType) = 0) and
      (GetPlayer <> Target) then Exit;
    MinLevel := 1;
    MaxLevel := InventionLevels[aConst.EquipmentInventionIndices[ItemType]];
    if CurrentStar.Constellation.Id = 20 then MaxLevel := Max(MaxLevel, Integer(aGalaxy.Galaxy.TechLevel));
    MinLevel := Max(MinLevel, MaxLevel div 2 - 1);
    MinSize := System.Round(GetAverageItemSize(ItemType) * aConst.EquipmentSizeFactors[5]);
    MaxSize := System.Round(GetAverageItemSize(ItemType) * aConst.EquipmentSizeFactors[1]);
    if (Target is TWarrior) and ((Target as TWarrior).WarriorType = wtFlagship) then
    begin
      MinSize := MinSize * 2;
      MaxSize := MaxSize * 2;
    end;
    Owner := RaceToOwner(RaceId);
    if OwnerId = oiPirate then Owner := oiPirate;
    Result := CreateGeneratedEquipment(ItemType, NextRandomIntRange(MinSize, MaxSize, RandomState), NextRandomIntRange(MinLevel, MaxLevel, RandomState), Owner);
    if Target.CanGenerateMicroModuleForLoadout then
    begin
      Special := SelectEquipmentOfferSpecialMicroModule(Result);
      if Special >= 0 then ApplySpecialMicroModule(Special, Result);
    end;
  end
  else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then Result := GenerateWeaponOffer(Ship)
  else if ItemType = t_Hull then Result := GenerateHullOffer(Ship);
  if Result <> nil then
  begin
    if Result.CanImprove then
      case NextRandomIntRange(0, 100, RandomState) of
        0..5: Result.Improve(ikMinor);
        6..7: Result.Improve(ikMedium);
      end;
    Attempts := 0;
    if IsMainPiratePlanet and (NextRandomIntRange(0, 100, RandomState) > 50) then
    repeat
      Priority := System.Round(RemapClamped(aGalaxy.Galaxy.TechLevel, 3, 7, 70, 0));
      Module := aGalaxy.Galaxy.SelectMicroModule(Priority + Attempts div 7, Min(100, Priority + 10 + Attempts * 3), AdvanceRandomSeed(RandomState), Self);
      if CanInstallMicroModule(Module, Result) then
      begin
        ApplyMicroModule(Module, Result);
        Break;
      end;
      Inc(Attempts);
    until Attempts > 50;
  end;
end;
{ @end $794124 }

{ @routine $794488 TPlanet_BuildEquipmentOfferBatch }
function TPlanet.BuildEquipmentOfferBatch(Ship: Pointer; UnusedForceGeneratedOffers: Boolean): TObjectList;
var
  Offers: TObjectList;
  i, j: Integer;
  ItemType: TItemType;
  Item: TItem;
begin
  Offers := TObjectList.Create;
  for j := 1 to aConst.PlanetEquipmentOfferQuotas[RaceId, t_Hull] do
  begin
    Item := GenerateEquipmentOffer(Ship, t_Hull);
    if Item <> nil then Offers.Add(Item);
  end;
  for i := 1 to CountItemTypesInMask([Ord(t_FuelTanks)..Ord(t_DefGenerator)]) do
  begin
    ItemType := TItemType(GetItemTypeFromMask([Ord(t_FuelTanks)..Ord(t_DefGenerator)], i));
    for j := 1 to aConst.PlanetEquipmentOfferQuotas[RaceId, ItemType] do
    begin
      Item := GenerateEquipmentOffer(Ship, ItemType);
      if Item <> nil then Offers.Add(Item);
    end;
  end;
  for i := 1 to aConst.PlanetEquipmentOfferQuotas[RaceId, WeaponCategoryItemType] do
  begin
    Item := GenerateEquipmentOffer(Ship, WeaponCategoryItemType);
    if Item <> nil then Offers.Add(Item);
  end;
  Result := Offers;
end;
{ @end $794488 }

{ @routine $7945DC TPlanet_CalculateEquipmentShopTargetCount }
function TPlanet.CalculateEquipmentShopTargetCount: Integer;
var
  Count: Integer;
  ItemType: TItemType;
begin
  Count := 0;
  for ItemType := t_Hull to WeaponCategoryItemType do
    Count := Count + aConst.PlanetEquipmentOfferQuotas[RaceId][ItemType];
  Result := System.Round(RemapClamped(Population, 100000, 1000000, 0.5, 1.3) * Count) +
    SeededRandomIntRange(-2, 2, (GenerationSeed - aGalaxy.Galaxy.CurrentTurn) * 1011011);
  case Economy of
    peAgricultural: Dec(Result, 2);
    peIndustrial: Inc(Result, 2);
  end;
  Result := Max(10, Min(Result, 20));
end;
{ @end $7945DC }

{ @routine $7946D4 TPlanet_CountEquipmentShopItemsInBucket }
function TPlanet.CountEquipmentShopItemsInBucket(ItemType: TItemType): Integer;
// The WeaponCategoryItemType shop bucket counts every weapon subtype.
var
  i, Count: Integer;
  Item: TItem;
begin
  Count := 0;
  for i := 0 to EquipmentShop.Count - 1 do
  begin
    Item := EquipmentShop[i];
    if (Item.ItemType = ItemType) or ((Item.ItemType in [t_IndustrialLaser..t_CustomWeapon]) and (ItemType = WeaponCategoryItemType)) then Inc(Count);
  end;
  Result := Count;
end;
{ @end $7946D4 }

{ @routine $79474C TPlanet_RemoveSimilarEquipmentShopItem }
function TPlanet.RemoveSimilarEquipmentShopItem(Item: TEquipment): Boolean;
var
  i, Index: Integer;
  Candidate: TEquipment;
begin
  Result := False;
  Index := NextRandomIntRange(0, EquipmentShop.Count - 1, RandomState);
  for i := 0 to EquipmentShop.Count - 1 do
  begin
    IncrementWrapped(Index, 0, EquipmentShop.Count - 1);
    Candidate := TEquipment(EquipmentShop[Index]);
    if (Item.ItemType = Candidate.ItemType) and (Candidate <> Item) and
      ((Candidate.ScriptItem = nil) or (TScriptItem(Candidate.ScriptItem).Name = '')) and
      (Candidate.GetLevel = Item.GetLevel) then
    begin
      EquipmentShop.Delete(Index);
      Candidate.Free;
      Result := True;
      Exit;
    end;
  end;
end;
{ @end $79474C }

{ @routine $794840 TPlanet_ForceGoodsScarcity }
procedure TPlanet.ForceGoodsScarcity(StartEvent: Boolean; GoodsMask: TItemTypeMask);
var
  Kind: Byte;
begin
  for Kind := 0 to 7 do
    if Kind in GoodsMask then
    begin
      Goods[Kind].PriceState := aConst.GoodsMarket[Kind].MaxPrice;
      Goods[Kind].Count := Min(Goods[Kind].Count, aConst.GoodsMarket[Kind].BaseStock div 10);
      Goods[Kind].PurchasePrice := System.Round(Goods[Kind].PriceState);
      Goods[Kind].BaseSalePrice := Max(Int64(1), System.Round(Goods[Kind].PriceState * 0.98 - 1));
      if StartEvent then
      begin
        GoodsScarcityTicks[Kind] := System.Round(30 * aConst.GalaxyDifficultyTuning[aGalaxy.Galaxy.DifficultyLevels[1]].GoodsEventDurationFactor);
        GoodsSurplusTicks[Kind] := 0;
      end
      else if GoodsScarcityTicks[Kind] > 0 then Dec(GoodsScarcityTicks[Kind]);
    end;
end;
{ @end $794840 }

{ @routine $794A0C TPlanet_ForceGoodsSurplus }
procedure TPlanet.ForceGoodsSurplus(StartEvent: Boolean; GoodsMask: TItemTypeMask);
var
  Kind: Byte;
begin
  for Kind := 0 to 7 do
    if Kind in GoodsMask then
    begin
      Goods[Kind].PriceState := aConst.GoodsMarket[Kind].MinPrice;
      Goods[Kind].Count := Max(Goods[Kind].Count, Min(Goods[Kind].Count + aConst.GoodsMarket[Kind].BaseStock div 5, aConst.GoodsMarket[Kind].BaseStock * 3));
      Goods[Kind].PurchasePrice := System.Round(Goods[Kind].PriceState);
      Goods[Kind].BaseSalePrice := Max(Int64(1), System.Round(Goods[Kind].PriceState * 0.98 - 1));
      if StartEvent then
      begin
        GoodsSurplusTicks[Kind] := System.Round(30 * aConst.GalaxyDifficultyTuning[aGalaxy.Galaxy.DifficultyLevels[1]].GoodsEventDurationFactor);
        GoodsScarcityTicks[Kind] := 0;
      end
      else if GoodsSurplusTicks[Kind] > 0 then Dec(GoodsSurplusTicks[Kind]);
    end;
end;
{ @end $794A0C }

{ @routine $794C18 TPlanet_CountBailablePrisoners }
function TPlanet.CountBailablePrisoners: Integer;
var
  i: Integer;
  Ship: TShip;
begin
  Result := 0;
  for i := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[i];
    if (Ship.CurrentPlanet = Self) and
      ((Ship.ScriptShip = nil) or ((TObject(Ship.ScriptShip) as TScriptShip).State.StateKind = sskNormalAI)) and
      Ship.IsInPrison and (Ship.GetPrisonTermRemaining > 0) then Inc(Result);
  end;
end;
{ @end $794C18 }

{ @routine $794CB4 TPlanet_GetGovernmentBackgroundGraph }
function TPlanet.GetGovernmentBackgroundGraph: WideString;
begin
  Result := 'GI,Bm.';
  if IsMainPiratePlanet then Result := Result + 'Gov.PirateBG'
  else
  begin
    Result := Result + 'City.' + aConst.OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName;
    if OwnerId = oiPirate then Result := Result + 'Pirate';
  end;
end;
{ @end $794CB4 }

{ @routine $794D98 TPlanet_BuildNonCivilTreasureHintText }
function TPlanet.BuildNonCivilTreasureHintText: WideString;
var
  Index: Integer;
  Score: Double;
  Item: TItem;
begin
  if (OwnerId <> oiUninhabited) or (SurfaceLootEntries = nil) or (SurfaceLootEntries.Count = 0) then
  begin
    Result := LocalizedText('Planet.NotCivil.Treasure.Nothing');
    Exit;
  end;
  Score := 0;
  for Index := 0 to SurfaceLootEntries.Count - 1 do
  begin
    Item := PPlanetSurfaceLootEntry(SurfaceLootEntries[Index]).Item;
    if Item is TGoods then
      Score := Score + Item.Cost * aConst.GoodsMarket[Ord(Item.ItemType)].AveragePrice * 0.000001
    else if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
      Score := Score + Item.Cost * GetAverageItemSize(Item.ItemType) / Math.Max(Item.Weight, 1) *
        TEquipment(Item).GetLevel * TWeapon(Item).GetWeaponInfo^.TechLevel * 0.000025
    else if Item.ItemType in [t_Hull..t_DefGenerator] then
      Score := Score + Item.Cost * GetAverageItemSize(Item.ItemType) / Math.Max(Item.Weight, 1) *
        Sqr(TEquipment(Item).GetLevel) * 0.000025
    else if Item is TMicroModule then
      Score := Score + 121 / (aConst.MicroModuleTemplates[TMicroModule(Item).MicroModuleIndex - 1].Priority + 20)
    else if Item is TArtefact then
      Score := Score + (GetAverageItemSize(Item.ItemType) * 0.5 / Math.Max(Item.Weight, 1) + 0.5) * 10
    else if (Item is TEquipmentWithActCode) and TEquipmentWithActCode(Item).DisplayAsArtefact then
      Score := Score + 10
    else if Item is TUselessItem then Score := Score + 1
    else Score := Score + 0.001;
  end;
  if Score >= 15 then Result := LocalizedText('Planet.NotCivil.Treasure.Lots')
  else if Score >= 5 then Result := LocalizedText('Planet.NotCivil.Treasure.Many')
  else if Score >= 1 then Result := LocalizedText('Planet.NotCivil.Treasure.Some')
  else Result := LocalizedText('Planet.NotCivil.Treasure.Few');
end;
{ @end $794D98 }

{ @routine $7953E8 TPlanet_BuildGovernmentGreeting }
function TPlanet.BuildGovernmentGreeting: WideString;
{ UnusedText is explicitly initialized/finalized by the native routine.
  PirateClanInCurStar, PirateClanInToStar and ToStarControlByPirates are loaded
  configuration fields but are not consulted here; population tests use only
  the five ordinary ship types. }
var
  Rules: array of TGovGreetingsInfo;
  HighIndex: Integer;
  SwapA, SwapB: TGovGreetingsInfo;
  UnusedText, Greeting: WideString;
  Attempt, NearStarIndex, I, ShipCount, Minimum, RuleIndex, BestPriority, Priority: Integer;
  Good: Byte;
  Rejected, FoundPlanet: Boolean;
  Star: TStar;
  Planet: TPlanet;
  ShipType: TShipType;
  CountMask: TGreetingCountMask;
  Ship: TShip;
  CoalitionPresent, DominatorsPresent, PiratesPresent, PlayerPartyPresent, CustomPresent: Boolean;

  // @nested $79526C PrepareRules
  procedure PrepareRules; // @addr 0x79526C @ida "void __cdecl $name(void *ParentFrame);" @note "Nested helper with caller-popped static link. Copies managed 0x44-byte greeting rules into ParentFrame-4; high index is at -8 and Self at -0C. Swaps each index 0..high div 2 with a seeded random index in 0..high; seed is Self.Id + 7*index + CurrentTurn div 7. Requires a nonempty rule table."
  var
    I, J: Integer;
  begin
    SetLength(Rules, GovernmentGreetingCount);
    for I := 0 to HighIndex do Rules[I] := GovernmentGreetingDefinitions[I];
    for I := 0 to HighIndex div 2 do
    begin
      J := SeededRandomIntRange(0, HighIndex, Id + 7 * I + aGalaxy.Galaxy.CurrentTurn div 7);
      SwapA := Rules[J];
      SwapB := Rules[I];
      Rules[I] := SwapA;
      Rules[J] := SwapB;
    end;
  end;

begin
  Result := '';
  UnusedText := '';
  BestPriority := -1;
  Priority := -1;
  CurrentStar.GetControlPresence(PlayerPartyPresent, CoalitionPresent, DominatorsPresent, PiratesPresent, CustomPresent);
  Minimum := 0;
  HighIndex := GovernmentGreetingCount - 1;
  PrepareRules;
  RuleIndex := SeededRandomIntRange(0, HighIndex, (Integer(Id) * aGalaxy.Galaxy.CurrentTurn) div 20);
  for Attempt := 0 to HighIndex do
  begin
    Greeting := '';
    IncrementWrapped(RuleIndex, Minimum, HighIndex);
    if BestPriority > 0 then
    begin
      Priority := Rules[RuleIndex].Priority;
      if Priority * SeededRandomIntRange(1, 100, Id + RuleIndex * (aGalaxy.Galaxy.CurrentTurn div 20)) <
         BestPriority * SeededRandomIntRange(1, 100, Id + RuleIndex * (aGalaxy.Galaxy.CurrentTurn div 20) * 3) then Continue;
    end;
    if (Rules[RuleIndex].PlayerRace <> []) and not (GetPlayer.PilotRace in Rules[RuleIndex].PlayerRace) then Continue;
    if (Rules[RuleIndex].PlayerStatus <> []) and not (GetPlayer.GetDominantCareer in Rules[RuleIndex].PlayerStatus) then Continue;
    if (Rules[RuleIndex].PlayerRating <> []) and not (GetPlayer.GetRangerRatingBand in Rules[RuleIndex].PlayerRating) then Continue;
    if (Rules[RuleIndex].PlayerRank <> []) and not (GetPlayer.Rank in Rules[RuleIndex].PlayerRank) then Continue;
    if (Rules[RuleIndex].PlayerPirateRank <> []) and not (GetPlayer.PirateRank in Rules[RuleIndex].PlayerPirateRank) then Continue;
    Good := NoGreetingGoods;
    if Rules[RuleIndex].Goods <> UnspecifiedGoods then Good := Rules[RuleIndex].Goods;
    Greeting := LocalizedColorText('GovGreetings.' + Rules[RuleIndex].Name + '.Text');
    if (Rules[RuleIndex].CurPlanetRace <> []) and not (RaceId in Rules[RuleIndex].CurPlanetRace) then Continue;
    if Rules[RuleIndex].CurPlanetPirateClan <> gcAny then
    begin
      if (Rules[RuleIndex].CurPlanetPirateClan = gcYes) and (OwnerId <> oiPirate) then Continue;
      if (Rules[RuleIndex].CurPlanetPirateClan = gcNo) and (OwnerId = oiPirate) then Continue;
    end;
    if Rules[RuleIndex].CurPlanetRaceIsPlayerRace <> gcAny then
    begin
      if (Rules[RuleIndex].CurPlanetRaceIsPlayerRace = gcYes) and (GetPlayer.PilotRace <> RaceId) then Continue;
      if (Rules[RuleIndex].CurPlanetRaceIsPlayerRace = gcNo) and (GetPlayer.PilotRace = RaceId) then Continue;
    end;
    if (Rules[RuleIndex].CurPlanetRelations <> []) and not (GetRelationLevelToShip(GetPlayer) in Rules[RuleIndex].CurPlanetRelations) then Continue;
    if Good <> NoGreetingGoods then
    begin
      if Rules[RuleIndex].CurPlanetGoodsPermit <> gcAny then
      begin
        if (Rules[RuleIndex].CurPlanetGoodsPermit = gcYes) and (not GoodsLegalOnPlanet[Good, RaceId, Government]) then Continue;
        if (Rules[RuleIndex].CurPlanetGoodsPermit = gcNo) and (GoodsLegalOnPlanet[Good, RaceId, Government] = True) then Continue;
      end;
      if (Rules[RuleIndex].CurPlanetGoodsCnt <> []) and not (aGalaxy.Galaxy.ClassifyGoodsQuantity(Goods[Good].Count, Good) in Rules[RuleIndex].CurPlanetGoodsCnt) then Continue;
      if (Rules[RuleIndex].CurPlanetGoodsSale <> []) and not (aGalaxy.Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, nil), Good) in Rules[RuleIndex].CurPlanetGoodsSale) then Continue;
      if (Rules[RuleIndex].CurPlanetGoodsBuy <> []) and not (aGalaxy.Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, nil), Good) in Rules[RuleIndex].CurPlanetGoodsBuy) then Continue;
    end;
    if (Rules[RuleIndex].CurPlanetEconomy <> []) and not (Economy in Rules[RuleIndex].CurPlanetEconomy) then Continue;
    if (Rules[RuleIndex].CurPlanetGovernment <> []) and not (Government in Rules[RuleIndex].CurPlanetGovernment) then Continue;
    Rejected := False;
    for ShipType := stKling to stWarrior do
    begin
      case ShipType of
        stKling: CountMask := Rules[RuleIndex].KlingInCurStar;
        stRanger: CountMask := Rules[RuleIndex].RangerInCurStar;
        stPirate: CountMask := Rules[RuleIndex].PirateInCurStar;
        stWarrior: CountMask := Rules[RuleIndex].WarriorInCurStar;
        stTransport: CountMask := Rules[RuleIndex].TransportInCurStar;
      else RaiseWideMessage('function TPlanet.GovGreeting:WideString;');
      end;
      if CountMask <> [] then
      begin
        ShipCount := 0;
        for I := 0 to CurrentStar.Ships.Count - 1 do
        begin
          Ship := TShip(CurrentStar.Ships[I]);
          if not Ship.HasScriptStateText and (Ship.TypeNameOverrideKey = '') and (Ship.TypeId = ShipType) then Inc(ShipCount);
        end;
        ShipCount := Min(10, ShipCount);
        if not (ShipCount in CountMask) then
        begin
          Rejected := True;
          Break;
        end;
      end;
    end;
    if Rejected then Continue;
    if Rules[RuleIndex].CurStarInBattle <> gcAny then
    begin
      if (Rules[RuleIndex].CurStarInBattle = gcYes) and (not (Boolean(CurrentStar.Battle) and DominatorsPresent)) then Continue;
      if (Rules[RuleIndex].CurStarInBattle = gcNo) and (Boolean(CurrentStar.Battle) and DominatorsPresent) then Continue;
    end;
    if Rules[RuleIndex].CurStarInBattlePirates <> gcAny then
    begin
      if (Rules[RuleIndex].CurStarInBattlePirates = gcYes) and (not (Boolean(CurrentStar.Battle) and PiratesPresent)) then Continue;
      if (Rules[RuleIndex].CurStarInBattlePirates = gcNo) and (Boolean(CurrentStar.Battle) and PiratesPresent) then Continue;
    end;
    if Rules[RuleIndex].CoalitionAlreadyDefeated <> gcAny then
    begin
      if (Rules[RuleIndex].CoalitionAlreadyDefeated = gcYes) and (aGalaxy.Galaxy.CoalitionDefeatedTurn = 0) then Continue;
      if (Rules[RuleIndex].CoalitionAlreadyDefeated = gcNo) and (aGalaxy.Galaxy.CoalitionDefeatedTurn <> 0) then Continue;
    end;
    if Rules[RuleIndex].DominatorsAlreadyDefeated <> gcAny then
    begin
      if (Rules[RuleIndex].DominatorsAlreadyDefeated = gcYes) and (aGalaxy.Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron])) then Continue;
      if (Rules[RuleIndex].DominatorsAlreadyDefeated = gcNo) and (not aGalaxy.Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron])) then Continue;
    end;
    if Rules[RuleIndex].ToPlanetRace <> [] then
    begin
      FoundPlanet := False;
      for NearStarIndex := 0 to 7 do
      begin
        Star := TObject(CurrentStar.StarDistances[NearStarIndex].Star) as TStar;
        if not Star.IsConstellationVisible then Continue;
        if Star.Constellation.Id = 20 then Continue;
        if Star.Status.CustomFaction <> '' then Continue;
        if Rules[RuleIndex].ToPlanetInCurStar <> gcAny then
        begin
          if (Rules[RuleIndex].ToPlanetInCurStar = gcYes) and (CurrentStar <> Star) then Continue;
          if (Rules[RuleIndex].ToPlanetInCurStar = gcNo) and (CurrentStar = Star) then Continue;
        end;
        Rejected := False;
        for ShipType := stKling to stWarrior do
        begin
          case ShipType of
            stKling: CountMask := Rules[RuleIndex].KlingInToStar;
            stRanger: CountMask := Rules[RuleIndex].RangerInToStar;
            stPirate: CountMask := Rules[RuleIndex].PirateInToStar;
            stWarrior: CountMask := Rules[RuleIndex].WarriorInToStar;
            stTransport: CountMask := Rules[RuleIndex].TransportInToStar;
          else RaiseWideMessage('function TPlanet.GovGreeting:WideString;');
          end;
          if CountMask <> [] then
          begin
            ShipCount := 0;
            for I := 0 to Star.Ships.Count - 1 do
            begin
              Ship := TShip(Star.Ships[I]);
              if not Ship.HasScriptStateText and (Ship.TypeNameOverrideKey = '') and (Ship.TypeId = ShipType) then Inc(ShipCount);
            end;
            ShipCount := Min(10, ShipCount);
            if not (ShipCount in CountMask) then
            begin
              Rejected := True;
              Break;
            end;
          end;
        end;
        if Rejected then Continue;
        if Rules[RuleIndex].ToStarControlByKling <> gcAny then
        begin
          if (Rules[RuleIndex].ToStarControlByKling = gcYes) and (Star.ControlFaction <> sfDominators) then Continue;
          if (Rules[RuleIndex].ToStarControlByKling = gcNo) and (Star.ControlFaction <> sfCoalition) then Continue;
        end;
        if Rules[RuleIndex].ToStarInBattle <> gcAny then
        begin
          if (Rules[RuleIndex].ToStarInBattle = gcYes) and (not Boolean(Star.Battle)) then Continue;
          if (Rules[RuleIndex].ToStarInBattle = gcNo) and (Boolean(Star.Battle)) then Continue;
        end;
        for I := 0 to Star.Planets.Count - 1 do
        begin
          Planet := TPlanet(Star.Planets[I]);
          if Planet = Self then Continue;
          if not (Planet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then Continue;
          if not (Planet.RaceId in Rules[RuleIndex].ToPlanetRace) then Continue;
          if Rules[RuleIndex].ToPlanetRaceIsPlayerRace <> gcAny then
          begin
            if (Rules[RuleIndex].ToPlanetRaceIsPlayerRace = gcYes) and (GetPlayer.PilotRace <> Planet.RaceId) then Continue;
            if (Rules[RuleIndex].ToPlanetRaceIsPlayerRace = gcNo) and (GetPlayer.PilotRace = Planet.RaceId) then Continue;
          end;
          if Rules[RuleIndex].ToPlanetRaceIsCurPlanetRace <> gcAny then
          begin
            if (Rules[RuleIndex].ToPlanetRaceIsCurPlanetRace = gcYes) and (RaceId <> Planet.RaceId) then Continue;
            if (Rules[RuleIndex].ToPlanetRaceIsCurPlanetRace = gcNo) and (RaceId = Planet.RaceId) then Continue;
          end;
          if Rules[RuleIndex].ToPlanetRelations <> [] then
          begin
            if not (Planet.GetRelationLevelToShip(GetPlayer) in Rules[RuleIndex].ToPlanetRelations) or
               (Planet.OwnerId = oiPirate) then Continue;
          end;
          if Good <> NoGreetingGoods then
          begin
            if Rules[RuleIndex].ToPlanetGoodsPermit <> gcAny then
            begin
              if (Rules[RuleIndex].ToPlanetGoodsPermit = gcYes) and (not GoodsLegalOnPlanet[Good, Planet.RaceId, Planet.Government]) then Continue;
              if (Rules[RuleIndex].ToPlanetGoodsPermit = gcNo) and (GoodsLegalOnPlanet[Good, Planet.RaceId, Planet.Government] = True) then Continue;
            end;
            if (Rules[RuleIndex].ToPlanetGoodsCnt <> []) and not (aGalaxy.Galaxy.ClassifyGoodsQuantity(Planet.Goods[Good].Count, Good) in Rules[RuleIndex].ToPlanetGoodsCnt) then Continue;
            if (Rules[RuleIndex].ToPlanetGoodsSale <> []) and not (aGalaxy.Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, Planet), Good) in Rules[RuleIndex].ToPlanetGoodsSale) then Continue;
            if (Rules[RuleIndex].ToPlanetGoodsBuy <> []) and not (aGalaxy.Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, Planet), Good) in Rules[RuleIndex].ToPlanetGoodsBuy) then Continue;
          end;
          if (Rules[RuleIndex].ToPlanetEconomy <> []) and not (Planet.Economy in Rules[RuleIndex].ToPlanetEconomy) then Continue;
          if (Rules[RuleIndex].ToPlanetGovernment <> []) and not (Planet.Government in Rules[RuleIndex].ToPlanetGovernment) then Continue;
          Greeting := ReplaceColoredToken(Greeting, '<ToPlanet>', Planet.Name, TextHighlightColorTag);
          Greeting := ReplaceColoredToken(Greeting, '<ToStar>', Planet.CurrentStar.Name, TextHighlightColorTag);
          if Good <> NoGreetingGoods then
          begin
            Greeting := ReplaceColoredToken(Greeting, '<ToPlanetGoodsCnt>', WideString(IntToStr(Planet.Goods[Good].Count)), TextHighlightColorTag);
            Greeting := ReplaceColoredToken(Greeting, '<ToPlanetGoodsSale>', WideString(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, Planet))), TextHighlightColorTag);
            Greeting := ReplaceColoredToken(Greeting, '<ToPlanetGoodsBuy>', WideString(IntToStr(GetPlayer.ShopGoodsSellPrice(Good, Planet))), TextHighlightColorTag);
          end;
          FoundPlanet := True;
          Break;
        end;
        if FoundPlanet then Break;
      end;
      if not FoundPlanet then Continue;
    end;
    if Greeting <> '' then
    begin
      Result := Greeting;
      Result := ReplaceColoredToken(Result, '<PlayerRank>', GetPlayer.GetRankName, TextHighlightColorTag);
      Result := ReplaceColoredToken(Result, '<CurPlanet>', Name, TextHighlightColorTag);
      Result := ReplaceColoredToken(Result, '<CurStar>', CurrentStar.Name, TextHighlightColorTag);
      if Good <> NoGreetingGoods then
      begin
        Result := ReplaceColoredToken(Result, '<CurPlanetGoodsCnt>', WideString(IntToStr(Goods[Good].Count)), TextHighlightColorTag);
        Result := ReplaceColoredToken(Result, '<CurPlanetGoodsSale>', WideString(IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, nil))), TextHighlightColorTag);
        Result := ReplaceColoredToken(Result, '<CurPlanetGoodsBuy>', WideString(IntToStr(GetPlayer.ShopGoodsSellPrice(Good, nil))), TextHighlightColorTag);
      end;
      if Priority = -1 then BestPriority := Rules[RuleIndex].Priority
      else BestPriority := Priority;
      if BestPriority >= 50 then Break;
    end;
  end;
end;
{ @end $7953E8 }

end.
