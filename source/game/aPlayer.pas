unit aPlayer;

interface

uses Achievements, Classes, EC_BlockPar, EC_Buf, EC_Struct, aGalaxy, aItem, aMyFunction, aPlanet, aRanger, aRuins, aShip, aGalaxyStruct;

type
  TPlanetBattleHistoryEntry = packed record // @size 0x28
    MapId: Integer; // @offset 0x00
    Statistics: TPlanetBattleStatistics; // @offset 0x04 Player-side counters returned by MatrixGame.
    ResultCode: Integer; // @offset 0x1C
    CompletionMode: Integer; // @offset 0x20
    DateTurn: Integer; // @offset 0x24
  end;

  TStorageEntry = packed record // @size 0x0C
    LocationOwner: TObject; // @offset 0x00
    SlotIndex: Integer; // @offset 0x04
    Item: TItem; // @offset 0x08
  end;
  PStorageEntry = ^TStorageEntry;

  TEquipmentConfiguration = packed record // @size 0xB0
    // IDs, not pointers. Zero denotes an empty slot; the hull is not saved here.
    EquipmentIds: array[0..11] of Cardinal; // @offset 0x00  Weapon slots 0..4, then up to seven other equipped items.
    ArtefactIds: array[0..31] of Cardinal; // @offset 0x30  Indexed by assigned artifact slot.
  end;

  TJournalRecord = class(TObjectEx) // @size 0x0C
  public
    DateTurn: Integer; // @offset 0x04
    Text: WideString; // @offset 0x08
    constructor Create; // @addr $747218
    destructor Destroy; override; // @addr $74725C
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $747284
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr $7472A4
  end;

  TStorageHeaderColumns = record // @size $08
    Size: Integer; // @offset $00
    Cost: Integer; // @offset $04
  end;
  TStorageHeaderColumnTable = array[1..2] of TStorageHeaderColumns;
  TStorageDividerLengthTable = array[1..2] of Integer;
  TProbeSummaryColumns = record // @size $14
    Heading: Integer; // @offset $00
    Size: Integer; // @offset $04
    Exploration: Integer; // @offset $08
    Condition: Integer; // @offset $0C
    Status: Integer; // @offset $10
  end;
  TProbeSummaryColumnTable = array[1..2] of TProbeSummaryColumns;
  TStorageItemColumns = record // @size $0C
    Heading: Integer; // @offset $00
    Size: Integer; // @offset $04
    Cost: Integer; // @offset $08
  end;
  TStorageItemColumnTable = array[1..2] of TStorageItemColumns;

  TPlayer = class(TRanger) // @size 0xDF0
  public
    InPrison: Boolean; // @offset 0x560
    TalkLocked: Boolean; // @offset 0x561  Player-global Script.NoTalkToShip lock.
    ScanLocked: Boolean; // @offset 0x562  Player-global Script.NoScanToShip lock.
    HyperspaceKillCount: Integer; // @offset 0x564  Script.ShipStatistic kind 8.
    BlackHoleKillCount: Integer; // @offset 0x568  Script.ShipStatistic kind 7.
    DominatorKillsByType: array[TDominatorKind] of Integer; // @offset $56C Indexed by TDominatorKind. Arcade Keller contributes to the boss slot (zero).
    ScriptShipBindings: TList; // @offset 0x58C
    QuestTargetKillShip: TShip; // @offset 0x590
    QuestTargetDefendShip: TShip; // @offset 0x594
    QuestTargetDefendStar: TStar; // @offset 0x598
    StorageEntries: TList; // @offset 0x59C  PStorageEntry elements.
    DebtAmount: Integer; // @offset 0x5A0  Total repayment, including interest and penalties.
    DebtDueTurn: Integer; // @offset 0x5A4
    DebtDefaultCount: Integer; // @offset 0x5A8  Missed repayment deadlines, not elapsed days.
    DepositAmount: Integer; // @offset 0x5AC
    DepositStartTurn: Integer; // @offset 0x5B0
    DepositDayCount: Integer; // @offset 0x5B4
    DepositInterestRate: Single; // @offset 0x5B8  Annual percentage points.
    MedicalPolicyTicks: Integer; // @offset 0x5BC  A purchased five-year policy starts at 1825.
    PirateLicenseTicks: Integer; // @offset 0x5C0
    PirateLicenseCash: Integer; // @offset 0x5C4  Credited license proceeds; decays after expiry.
    PendingPirateLicenseCash: Integer; // @offset 0x5C8  Folded into license proceeds and experience on the next turn.
    QueuedTravelTarget: TStar; // @offset 0x5CC  Player selection for Dominion travel.
    StationServiceLastUseTurns: array[TCoalitionProject] of Integer; // @offset $5D0 Initialized to 150; last-use turns for investment/service cooldowns.
    StatusEffectSourceNames: array[disease_blindness..stimulant_absolute_status] of WideString; // @offset 0x600
    DiseaseImmunity: Byte; // @offset 0x660  Clamped to 0..100.
    ProgramRewardStocks: array[TProgramIndex] of Integer; // @offset $664 Programs awarded for destroyed Dominator hull mass.
    LastDominatorProgramRewardTurn: Integer; // @offset $694
    DestroyedDominatorHullMass: Integer; // @offset $698 Accumulated capacity; reset after a program reward.
    Satellites: TObjectList; // @offset 0x69C  Owned deployed TSatellite instances.
    PlanetBattleHistory: array of TPlanetBattleHistoryEntry; // @offset 0x6A0  Includes maps marked used without playing.
    PlanetBattles: Integer; // @offset 0x6A4
    LastPlanetBattleTurn: Integer; // @offset 0x6A8
    DeclinePlanetBattleOffers: Boolean; // @offset 0x6AC Suppresses planetary-battle offers; set by DeclineAllPlanetBattles, editable key RejectPB.
    DiseaseContractionCount: Word; // @offset 0x6AE
    StimulantPurchaseCount: Word; // @offset 0x6B0
    PrisonStaysCompleted: Word; // @offset $6B2 PRISON: successful return from the prison quest.
    SatelliteTilesExplored: Integer; // @offset $6B4 ARCHEOLOGY: accumulated water/land/hill exploration gains.
    NationalityChangeCount: Integer; // @offset $6B8 MANYFACES: accepted nationality changes. Serialized as a word.
    SideChangeCount: Integer; // @offset $6BC SIDECHANGER: switches between Coalition and pirate allegiance. Serialized as a word.
    SelectedEquipmentConfiguration: Integer; // @offset 0x6C0  Zero-based; serialized as one byte.
    EquipmentConfigurations: array[0..9] of TEquipmentConfiguration; // @offset 0x6C4
    PiratePartners: TList; // @offset 0xDA4  Ship references, not owned by this list.
    UnresolvedFlagsDA8: array[0..5] of Boolean; // @offset $DA8 All initially true; serialized as six flags.
    JournalRecords: TObjectList; // @offset 0xDB0  Owned TJournalRecord entries.
    NewsEntries: TList; // @offset 0xDB4  Separately allocated records, not TObject instances.
    PendingDockDialogue: Byte; // @offset $DB8 After a turn, opens ruins/government dialogue for the current docking target.
    NoJump: Boolean; // @offset 0xDB9
    PirateClanReal: Boolean; // @offset 0xDBA
    AchievementStats: TAchievementStats; // @offset 0xDBC
    ExperienceByDominators: Integer; // @offset 0xDC0  Script.GetShipExpByType kind 1.
    ExperienceByPirates: Integer; // @offset 0xDC4  Kind 2.
    ExperienceByNormals: Integer; // @offset 0xDC8  Kind 3.
    ExperienceByTraderCareer: Integer; // @offset 0xDCC  Kind 4.
    RuinsMode: Byte; // @offset 0xDD0 Zero is inactive; EnterRuinsMode copies the capital-hull kind or explicit mode here.
    RuinsProxy: TShip; // @offset 0xDD4 Owned station proxy; initialized through a checked TRuins cast.
    RuinsSavedDockedTo: TShip; // @offset 0xDD8
    RuinsSavedPlanet: TPlanet; // @offset 0xDDC
    RuinsStatusText: WideString; // @offset 0xDE0
    AwardedAchievementKeys: TBlockParEC; // @offset 0xDE4
    BombKillsThisTurn: Integer; // @offset 0xDE8  Reset by NextDay; incremented for player bomb kills and checked for BOMBER.
    ChameleonLogic: array[TDominatorSeries] of Byte; // @offset 0xDEC  Script.PlayerLogicChameleon modes, indexed by TDominatorSeries.

    procedure InitializePlayerAtPlanet(Planet: TPlanet; InitialMoney, CharacterPreset: Integer); // @addr $749874 Inherited ranger registration followed by player career/skill defaults; CharacterPreset is unused here.
    procedure ApplyCharacterPreset(Planet: TPlanet; InitialMoney, CharacterPreset: Integer); // @addr $749918 Twenty-five race/preset loadouts, stored cargo and initial planet relations. Planet is unused.
    procedure BeginStorageTurn; // @addr $74FE40 Native empty turn-start hook.
    procedure RechargeTransmitters; // @addr $74E04C Increments every carried transmitter in the global player's artefact list, including unequipped ones.
    procedure ApplyBioArtefactHealthEffects; // @addr $74E098 Each active Bio artefact may shorten a disease and extend a stimulant by one turn.
    function MayTakeSubCrack: Boolean; // @addr $74E1A4 Terron unresolved, late-game offer cadence and no program 4 already carried.
    function GetSubCrackCost: Integer; // @addr $74E218 Difficulty-scaled price.
    function GetPirateServiceDiscount: TPercent; // @addr $74E248 Rounded pirate career status / 1.3, plus one percentage point.
    function CountProgramRewardStocks: Integer; // @addr $74E278
    function GetMaxPiratePartners: Integer; // @addr $752B1C Pirate career thresholds, eminent title and active license.
    function GetMaxDominionShips: Integer; // @addr $752B4C As pirate partners, with an additional threshold above career status 50.
    procedure AddJournalRecord(Text: WideString); // @addr $752B84 Dates the new record with the current turn.
    procedure DeleteJournalRecord(Index: Integer); // @addr $752BFC Native guard accepts Index=Count, leaving the list accessor to raise.
    procedure ClearJournal; // @addr $752C34
    procedure SortNewsEntries; // @addr $752E84 Ascending ID, using pairwise swaps.
    procedure MergeGalaxyNews; // @addr $753198 Copies galaxy news whose IDs are absent locally.
    procedure RefreshNewsAtLocation; // @addr $75327C Updates eligible docked players after turn 300 and retains the newest 100 entries.
    procedure CloseRuinsModeScreen; // @addr $7533F8 Returns to the saved location or star screen and requests screen closure.
    procedure RefreshCurrentStanding; override; // @addr $753528 @slot $C4 Includes the player's current-system kill counts and main pirate planet exception.
    constructor Create; // @addr $747350 Native constructor initializes lists/defaults; does not register or generate the player loadout.
    destructor Destroy; override; // @addr $7475F0 Requires the inherited ranger registration state for final cleanup.
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $747798 @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $747F20 @slot $04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr $748938 @slot $08
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr $748BDC @slot $10
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $749298 @slot $14
    function ExportJournal: WideString; // @addr $752C54
    function ExportNews: WideString; // @addr $752F80
    procedure TrimNewsEntries(KeepCount: Integer); // @addr $752F34 Removes and finalizes the oldest Count-KeepCount entries; unchecked argument.
    function TryAwardDominatorPrograms(Victim: TShip): Boolean; // @addr $74E294 Requires a TKling victim; records its hull capacity even when no reward is due.
    function GetSatelliteExplorationTurns(Satellite: TSatellite): Integer; // @addr $74FA98 @note "Remaining duration at the current planet using combined operational probe rates; capped at 999 per terrain."
    procedure ReportIdleSatellites(Star: TStar); // @addr $74FCD0 @note "Reports inactive deployed satellites in the entered star; records up to three target planets."
    procedure ExitRuinsMode; // @addr $7534B4 Restores the real docking target and rebuilds its temporary shop stock.
    procedure CreateRuinsProxy; // @addr $7532EC Creates a military-base proxy and removes it from the ordinary system ship list.
    procedure EnterRuinsMode(Mode: Integer); // @addr $753344 Nonpositive Mode uses the installed hull's CapitalShip kind.
    function CanSelectShipTarget(Ship: TShip): Boolean; // @addr $7535B8 Honors scripted targeting restrictions, chameleon logic and friendly station standing masks.
    function CanScanShip(Ship: TShip): Boolean; // @addr $753680 Checks station/Dominator restrictions and invokes the player's scan-permission item scripts.
    procedure SaveEquipmentConfiguration(Index: Integer); // @addr 0x007521FC @note "Index is zero-based and unchecked; the selected preset is unchanged."
    procedure ApplyEquipmentConfiguration(Index: Integer); // @addr 0x007527C8 @note "Can draw from storage at the current dock. Index is unchecked; the selected preset is unchanged."
    procedure NextDay; override; // @addr 0x0074C674 @slot 0x18
    function HasEquipmentConfiguration(Index: Integer): Boolean; // @addr 0x00752800 @note "Does not validate Index."

    function CalculateSpeed: Integer; override; // @addr 0x007532E4 @slot 0x4C
    function ComputeDepositAccruedValue: Integer; // @addr 0x0074DF58 @note "Capped at 100000000; zero for nonpositive principal."
    function CanAccessStoredItem(Item: TItem): Boolean; // @addr $74FE48 Native always-true permission hook used by storage lookup, counting and slot allocation.
    function CountStoredItemUnits(Location: TObject; ItemType: TItemType): Integer; // @addr 0x0074FE4C @note "Location=nil includes all storage locations. Goods and item types 69/75 count by weight; other matching items count individually."
    function HasSatelliteOnPlanet(Planet: TPlanet): Boolean; // @addr 0x0074EB9C @note "Requires Self=GetPlayer(): uses Self for the list count but fetches entries from the global player's deployed satellites."
    function CanAccessSurfaceLootItem(Item: TItem): Boolean; // @addr 0x0074FCCC @note "Native stub always returns true; Self and Item are unused. Called by treasure-map selection and planet loot reset."
    function FindNextStorageSlot(Location: TObject): Integer; // @addr 0x0074FFB4 @note "Returns a nonnegative slot local to Location."
    function FindStorageIndexByLocationAndSlot(Location: TObject; Slot: Integer): Integer; // @addr 0x00750084 @note "Returns a zero-based StorageEntries index, or -1."
    function FindStorageGoodsByLocationAndType(Location: TObject; Good: Byte): Integer; // @addr 0x007500E4 @note "Returns a zero-based StorageEntries index, or -1."
    function FindMergeableStorageItemByLocation(Location: TObject; Item: TCountableItem): Integer; // @addr 0x00750130 @note "Returns a zero-based StorageEntries index, or -1."
    procedure ShiftStorageSlotsAtOrAfter(Location: TObject; Slot: Integer); // @addr 0x0075018C
    function FindProfitableTradeRoute(Nearby: Boolean; Seed: Cardinal; var PurchasePlanet, SalePlanet: TPlanet; var Good: Byte; GoodsMask: TItemTypeMask): Boolean; // @addr $74E520 @ida "bool __userpurge $name@<al>(TPlayer *Self@<eax>, bool Nearby@<dl>, unsigned int Seed@<ecx>, TPlanet **PurchasePlanet@<^12>, TPlanet **SalePlanet@<^8>, unsigned __int8 *Good@<^4>, TItemTypeMask *GoodsMask@<^0>);" @note "Returns the highest-scoring visible Coalition trade route; retains output arguments on failure and excludes their previous endpoints."
    function SelectPlanetBattleMap: Integer; // @addr $751D90 Returns a map ID or -1; updates shared map play-count scratch from the player's history.
    function CanAccessHoldGoods(Good: Byte): Boolean; // @addr $74FE44 Native always-true permission hook; Good is passed in DL.
    procedure RepairDuplicateStorageSlots(Location: TObject); // @addr $74FEEC Reassigns later accessible entries with duplicate slot indices.
    function GetStorageSlotExtent(Location: TObject): Integer; // @addr $75001C Maximum accessible slot index plus one, or zero.
    procedure CloseVacantStorageSlot(Location: TObject; Slot: Integer); // @addr $7501E8 Shifts later slots down only if Slot is unoccupied.
    function HasAccessibleStorageAt(Location: TObject): Boolean; // @addr $750258 With nil, returns whether the entire storage list is empty.
    function CountPartnersInNormalSpace: Byte; // @addr $7502BC Counts ships following Self in the current system, wrapping at 256.
    function GetShipRatingComparison(Ship: TShip): Byte; // @addr $75030C Native compares ranger TotalExperience with the global player's PlaceInRating after refreshing rankings.
    function GetShipRankComparison(Ship: TShip): Byte; // @addr $750460 Returns 1..5 for relative Coalition rank, zero for non-normal ships.
    function GetShipPirateRankComparison(Ship: TShip): Byte; // @addr $75056C Returns 1..5 for relative pirate rank, zero for non-normal ships.
    function GetShipStrengthComparison(Ship: TShip): Byte; // @addr $750678 Returns 1..5 from strength relative to the global player.
    function GetAvailableNodeCount(Carrier: TShip): Integer; // @addr $752838 Includes the carrier's hold and the player's current-location storage.
    procedure ConsumeAvailableNodes(Count: Integer; Carrier: TShip); // @addr $7528E4 Uses the carrier's hold, then current-location storage; refreshes Self even when Carrier differs.
    procedure RefreshStorageBubbles; // @addr 0x00750DF8
    function HasDeployedSatellites: Boolean; // @addr $74EB60 @note "Uses Self.Satellites.Count but reads the global player's list."
    function GetStorageColumnHeaderText: WideString; // @addr $74EBD8
    function GetStorageDividerText: WideString; // @addr $74EE08
    function BuildDeployedSatelliteSummary(var LineCount: Integer): WideString; // @addr $74EEA8
    function BuildTranclucatorStorageSummary(var LineCount: Integer): WideString; // @addr $750778
    function CompareStorageEntries(Left, Right: PStorageEntry): Integer; // @addr $750A6C @note "Compares star/location IDs, type, module priority/index, weight and cost; ignores slot indices."
    procedure SortStorageEntries; // @addr $750D44
    procedure BuildStorageBubbles; // @addr 0x00750E00 @note "Publishes paginated storage summaries, including deployed probes; uses the global player's bubble list."
  end;

procedure SetPlayer(Player: TPlayer; Galaxy: TGalaxy); // @addr 0x0074730C @note "Updates Galaxy.PlayerRangerIndex; a nil Galaxy leaves the current player unchanged."
function GetPlayer: TPlayer; // @addr 0x00747300

var
  ArcadeKellerDefeats: Integer; // @addr $81B908 Native campaign reward guard.
  ArcadeKellerReward: TObject; // @addr $81B90C Owned reward item pending transfer.
  // The native initial DWORD decodes to nil; zero would decode to a non-null pointer.
  EncodedPlayer: Cardinal = $B1CD15D3; // @addr $8100FC
  StorageHeaderColumns: TStorageHeaderColumnTable = ((Size: 300; Cost: 380), (Size: 400; Cost: 490)); // @addr $810100
  StorageDividerLengths: TStorageDividerLengthTable = (76, 98); // @addr $810110
  ProbeSummaryColumns: TProbeSummaryColumnTable = (
    (Heading: 190; Size: 160; Exploration: 220; Condition: 280; Status: 295),
    (Heading: 250; Size: 200; Exploration: 280; Condition: 370; Status: 390)); // @addr $810118
  TranclucatorSummaryWidths: TStorageDividerLengthTable = (180, 240); // @addr $810140
  StorageItemColumns: TStorageItemColumnTable = ((Heading: 190; Size: 300; Cost: 380), (Heading: 250; Size: 400; Cost: 490)); // @addr $810148

implementation

uses SysUtils, GR_Main, EC_Str, Math, Globals, SimpleSteamApi, aScript, aKling, aConst, aGalaxyStruct, fEquipmentShop, GlobalsV, aTranclucator;

{ @routine $747218 TJournalRecord_Create }
constructor TJournalRecord.Create;
begin
  inherited Create;
  DateTurn := 0;
  Text := '';
end;
{ @end $747218 }

{ @routine $74725C TJournalRecord_Destroy }
destructor TJournalRecord.Destroy;
begin
  inherited Destroy;
end;
{ @end $74725C }

{ @routine $747284 TJournalRecord_SaveToBuffer }
procedure TJournalRecord.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddIntegerValue(DateTurn);
  Buffer.AddWideStringZ(Text);
end;
{ @end $747284 }

{ @routine $7472A4 TJournalRecord_LoadFromBuffer }
procedure TJournalRecord.LoadFromBuffer(Buffer: TBufEC);
begin
  DateTurn := Buffer.GetInt32;
  Text := Buffer.ReadWideString;
end;
{ @end $7472A4 }

{ @routine $747300 GetPlayer }
function GetPlayer: TPlayer;
begin
  Result := TPlayer(EncodedPlayer xor $B1CD15D3);
end;
{ @end $747300 }

{ @routine $74730C SetPlayer }
procedure SetPlayer(Player: TPlayer; Galaxy: TGalaxy);
begin
  if Galaxy <> nil then
  begin
    EncodedPlayer := Cardinal(Player) xor $B1CD15D3;
    if Player = nil then begin
      Galaxy.PlayerRangerIndex := -1;
      Exit;
    end;
    if Galaxy.Rangers = nil then begin
      Galaxy.PlayerRangerIndex := -1;
      Exit;
    end;
    Galaxy.PlayerRangerIndex := Galaxy.Rangers.IndexOf(Player)
  end;
end;
{ @end $74730C }

{ @routine $747350 TPlayer_Create }
constructor TPlayer.Create;
var
  ServiceIndex: TCoalitionProject;
  I, J: Integer;
  RewardIndex: TProgramIndex;
  KillIndex: TDominatorKind; LogicIndex: TDominatorSeries;
begin
  inherited Create;
  StorageEntries := TList.Create;
  TalkLocked := False;
  ScanLocked := False;
  ScriptShipBindings := TList.Create;
  HyperspaceKillCount := 0;
  BlackHoleKillCount := 0;
  for KillIndex := Low(TDominatorKind) to High(TDominatorKind) do DominatorKillsByType[KillIndex] := 0;
  for LogicIndex := Low(TDominatorSeries) to High(TDominatorSeries) do ChameleonLogic[LogicIndex] := 0;
  DebtAmount := 0;
  DebtDueTurn := 0;
  DebtDefaultCount := 0;
  DepositAmount := 0;
  DepositStartTurn := 0;
  DepositDayCount := 0;
  DepositInterestRate := 0;
  // The native constructor really uses the current turn for this duration field.
  if Galaxy <> nil then MedicalPolicyTicks := Galaxy.CurrentTurn;
  PirateLicenseTicks := 0;
  PirateLicenseCash := 0;
  PendingPirateLicenseCash := 0;
  for ServiceIndex := Low(StationServiceLastUseTurns) to High(StationServiceLastUseTurns) do StationServiceLastUseTurns[ServiceIndex] := 150;
  for I := disease_blindness to stimulant_absolute_status do StatusEffectSourceNames[I] := '';
  DiseaseImmunity := 50;
  for RewardIndex := Low(ProgramRewardStocks) to High(ProgramRewardStocks) do ProgramRewardStocks[RewardIndex] := 0;
  LastDominatorProgramRewardTurn := 0;
  DestroyedDominatorHullMass := 0;
  PlanetBattles := 0;
  LastPlanetBattleTurn := 0;
  DeclinePlanetBattleOffers := False;
  Satellites := TObjectList.Create;
  DiseaseContractionCount := 0;
  StimulantPurchaseCount := 0;
  PrisonStaysCompleted := 0;
  SatelliteTilesExplored := 0;
  NationalityChangeCount := 0;
  SideChangeCount := 0;
  ArcadeKellerDefeats := 0;
  ArcadeKellerReward := nil;
  SelectedEquipmentConfiguration := 0;
  for I := 0 to 9 do
  begin
    for J := 0 to 11 do EquipmentConfigurations[I].EquipmentIds[J] := 0;
    for J := 0 to 31 do EquipmentConfigurations[I].ArtefactIds[J] := 0;
  end;
  PiratePartners := TList.Create;
  for I := 0 to 5 do UnresolvedFlagsDA8[I] := True;
  JournalRecords := TObjectList.Create;
  NewsEntries := TList.Create;
  PirateClanReal := False;
  AchievementStats := TAchievementStats.Create;
  RuinsMode := 0;
  RuinsProxy := nil;
  RuinsSavedDockedTo := nil;
  RuinsSavedPlanet := nil;
  AwardedAchievementKeys := TBlockParEC.Create;
  QueuedTravelTarget := nil;
end;
{ @end $747350 }

{ @routine $7475F0 TPlayer_Destroy }
destructor TPlayer.Destroy;
var
  I: Integer;
  Entry: PStorageEntry;
begin
  if ScriptShipBindings <> nil then
  begin
    while ScriptShipBindings.Count > 0 do
      TScriptShip(ScriptShipBindings[0]).Script.UnbindShip(Self);
    ScriptShipBindings.Clear;
    ScriptShipBindings.Free;
    ScriptShipBindings := nil;
  end;
  if CurrentStar <> nil then
  begin
    I := CurrentStar.Ships.IndexOf(Self);
    if I >= 0 then CurrentStar.Ships.Delete(I);
  end;
  if StorageEntries <> nil then
  begin
    for I := 0 to StorageEntries.Count - 1 do
    begin
      Entry := PStorageEntry(StorageEntries[I]);
      if Entry <> nil then
      begin
        if Entry.Item <> nil then
        begin
          Entry.Item.Free;
          Entry.Item := nil;
        end;
        Dispose(Entry);
        StorageEntries[I] := nil;
      end;
    end;
    StorageEntries.Clear;
    StorageEntries.Free;
    StorageEntries := nil;
  end;
  if Satellites <> nil then
  begin
    Satellites.Free;
    Satellites := nil;
  end;
  if PiratePartners <> nil then
  begin
    PiratePartners.Free;
    PiratePartners := nil;
  end;
  if JournalRecords <> nil then
  begin
    JournalRecords.Free;
    JournalRecords := nil;
  end;
  TrimNewsEntries(0);
  NewsEntries.Clear;
  NewsEntries.Free;
  NewsEntries := nil;
  if RuinsProxy <> nil then
  begin
    RuinsProxy.Free;
    RuinsProxy := nil;
  end;
  AwardedAchievementKeys.Free;
  AwardedAchievementKeys := nil;
  inherited Destroy;
end;
{ @end $7475F0 }

{ @routine $747798 TPlayer_SaveToBuffer }
procedure TPlayer.SaveToBuffer(Buffer: TBufEC);
var
  I, J, ConfigurationCount, SlotCount, ListCount, NewsCount: Integer;
  Entry: PStorageEntry;
  ServiceIndex: TCoalitionProject;
  RewardIndex: TProgramIndex;
  News: PPlanetNewsEntry;
  KillIndex: TDominatorKind; LogicIndex: TDominatorSeries;
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddBoolean(InPrison);
  Buffer.AddBoolean(TalkLocked);
  Buffer.AddBoolean(ScanLocked);
  Buffer.AddIntegerValue(HyperspaceKillCount);
  Buffer.AddIntegerValue(BlackHoleKillCount);
  for KillIndex := Low(TDominatorKind) to High(TDominatorKind) do Buffer.AddIntegerValue(DominatorKillsByType[KillIndex]);
  for LogicIndex := Low(TDominatorSeries) to High(TDominatorSeries) do Buffer.AddAnsiChar(AnsiChar(ChameleonLogic[LogicIndex]));
  Buffer.AddIntegerValue(StorageEntries.Count);
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := PStorageEntry(StorageEntries[I]);
    if Entry.LocationOwner is TPlanet then
    begin
      Buffer.AddAnsiChar(#0);
      Buffer.AddDWord((Entry.LocationOwner as TPlanet).Id);
    end
    else
    begin
      Buffer.AddAnsiChar(#1);
      Buffer.AddDWord((Entry.LocationOwner as TShip).Id);
    end;
    Buffer.AddIntegerValue(Entry.SlotIndex);
    Buffer.AddAnsiChar(AnsiChar(Entry.Item.ItemType));
    Entry.Item.SaveToBuffer(Buffer);
  end;
  Buffer.AddIntegerValue(DebtAmount);
  Buffer.AddIntegerValue(DebtDueTurn);
  Buffer.AddIntegerValue(DebtDefaultCount);
  Buffer.AddIntegerValue(DepositAmount);
  Buffer.AddIntegerValue(DepositStartTurn);
  Buffer.AddIntegerValue(DepositDayCount);
  Buffer.AddSingle(DepositInterestRate);
  Buffer.AddIntegerValue(MedicalPolicyTicks);
  Buffer.AddIntegerValue(PirateLicenseTicks);
  Buffer.AddIntegerValue(PirateLicenseCash);
  Buffer.AddIntegerValue(PendingPirateLicenseCash);
  if QueuedTravelTarget = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(QueuedTravelTarget.Id);
  for ServiceIndex := Low(StationServiceLastUseTurns) to High(StationServiceLastUseTurns) do Buffer.AddIntegerValue(StationServiceLastUseTurns[ServiceIndex]);
  for I := disease_blindness to stimulant_absolute_status do Buffer.AddWideStringZ(StatusEffectSourceNames[I]);
  Buffer.AddAnsiChar(AnsiChar(DiseaseImmunity));
  for RewardIndex := Low(ProgramRewardStocks) to High(ProgramRewardStocks) do Buffer.AddIntegerValue(ProgramRewardStocks[RewardIndex]);
  Buffer.AddIntegerValue(LastDominatorProgramRewardTurn);
  Buffer.AddIntegerValue(DestroyedDominatorHullMass);
  Buffer.AddIntegerValue(Satellites.Count);
  for I := 0 to Satellites.Count - 1 do TSatellite(Satellites[I]).SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(High(PlanetBattleHistory) + 1);
  for I := 0 to High(PlanetBattleHistory) do
  begin
    Buffer.AddIntegerValue(PlanetBattleHistory[I].MapId);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics.SignedTimeMs);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics.RobotsBuilt);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics.RobotsDestroyed);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics.TurretsBuilt);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics.TurretsDestroyed);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].Statistics.BuildingsDestroyed);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].ResultCode);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].CompletionMode);
    Buffer.AddIntegerValue(PlanetBattleHistory[I].DateTurn);
  end;
  Buffer.AddIntegerValue(PlanetBattles);
  Buffer.AddIntegerValue(LastPlanetBattleTurn);
  Buffer.AddBoolean(DeclinePlanetBattleOffers);
  Buffer.AddWideChar(WideChar(DiseaseContractionCount));
  Buffer.AddWideChar(WideChar(StimulantPurchaseCount));
  Buffer.AddWideChar(WideChar(PrisonStaysCompleted));
  Buffer.AddIntegerValue(SatelliteTilesExplored);
  Buffer.AddWideChar(WideChar(NationalityChangeCount));
  Buffer.AddWideChar(WideChar(SideChangeCount));
  Buffer.AddAnsiChar(AnsiChar(SelectedEquipmentConfiguration));
  ConfigurationCount := 10;
  Buffer.AddAnsiChar(AnsiChar(ConfigurationCount));
  for I := 0 to ConfigurationCount - 1 do
  begin
    SlotCount := 12;
    Buffer.AddWideChar(WideChar(SlotCount));
    for J := 0 to SlotCount - 1 do Buffer.AddDWord(EquipmentConfigurations[I].EquipmentIds[J]);
    SlotCount := 32;
    Buffer.AddWideChar(WideChar(SlotCount));
    for J := 0 to SlotCount - 1 do Buffer.AddDWord(EquipmentConfigurations[I].ArtefactIds[J]);
  end;
  Buffer.AddAnsiChar(AnsiChar(PiratePartners.Count));
  for I := 0 to PiratePartners.Count - 1 do Buffer.AddDWord(TShip(PiratePartners[I]).Id);
  ListCount := 6;
  Buffer.AddAnsiChar(AnsiChar(ListCount));
  for I := 0 to ListCount - 1 do Buffer.AddBoolean(UnresolvedFlagsDA8[I]);
  ListCount := JournalRecords.Count;
  Buffer.AddDWord(JournalRecords.Count);
  for I := 0 to ListCount - 1 do TJournalRecord(JournalRecords[I]).SaveToBuffer(Buffer);
  NewsCount := NewsEntries.Count;
  Buffer.AddWideChar(WideChar(NewsCount));
  for I := 0 to NewsCount - 1 do
  begin
    News := PPlanetNewsEntry(NewsEntries[I]);
    Buffer.AddDWord(News.Id);
    Buffer.AddDWord(News.Turn);
    Buffer.AddAnsiChar(AnsiChar(News.NewsType));
    Buffer.AddWideStringZ(News.Text);
  end;
  Buffer.AddAnsiChar(AnsiChar(PendingDockDialogue));
  Buffer.AddBoolean(NoJump);
  Buffer.AddBoolean(PirateClanReal);
  AchievementStats.SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(ExperienceByDominators);
  Buffer.AddIntegerValue(ExperienceByPirates);
  Buffer.AddIntegerValue(ExperienceByNormals);
  Buffer.AddIntegerValue(ExperienceByTraderCareer);
  Buffer.AddAnsiChar(AnsiChar(RuinsMode));
  if RuinsProxy = nil then CreateRuinsProxy;
  (RuinsProxy as TRuins).SaveToBuffer(Buffer);
  if RuinsMode > 0 then
  begin
    if RuinsSavedDockedTo = nil then Buffer.AddDWord(0)
    else Buffer.AddDWord(RuinsSavedDockedTo.Id);
    if RuinsSavedPlanet = nil then Buffer.AddDWord(0)
    else Buffer.AddDWord(RuinsSavedPlanet.Id);
  end;
  Buffer.AddWideStringZ(RuinsStatusText);
  Buffer.AddIntegerValue(AwardedAchievementKeys.GetBlockCount);
  for I := 0 to AwardedAchievementKeys.GetBlockCount - 1 do
    Buffer.AddWideStringZ(AwardedAchievementKeys.GetBlockNameByIndex(I));
end;
{ @end $747798 }

{ @routine $747F20 TPlayer_LoadFromBuffer }
procedure TPlayer.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, Count, J, ConfigurationCount, SlotCount, PartnerCount: Integer;
  Entry: PStorageEntry;
  ServiceIndex: TCoalitionProject;
  RewardIndex: TProgramIndex;
  Satellite: TSatellite;
  Journal: TJournalRecord;
  News: PPlanetNewsEntry;
  AchievementIndex: Integer;
  Data: PAchievementData;
  KillIndex: TDominatorKind; LogicIndex: TDominatorSeries;
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion <= 164 then ClearRecentlyDroppedItems;
  InPrison := Buffer.GetBoolean;
  TalkLocked := Buffer.GetBoolean;
  ScanLocked := Buffer.GetBoolean;
  HyperspaceKillCount := Buffer.GetInt32;
  BlackHoleKillCount := Buffer.GetInt32;
  if LoadedSaveVersion >= 89 then
    for KillIndex := Low(TDominatorKind) to High(TDominatorKind) do DominatorKillsByType[KillIndex] := Buffer.GetInt32
  else if LoadedSaveVersion >= 74 then
  begin
    for KillIndex := dominator_boss to dominator_shtip do DominatorKillsByType[KillIndex] := Buffer.GetInt32;
    DominatorKillsByType[dominator_bertor] := 0;
    DominatorKillsByType[dominator_klig] := 0;
  end
  else
    for KillIndex := Low(TDominatorKind) to High(TDominatorKind) do DominatorKillsByType[KillIndex] := 0;
  if LoadedSaveVersion >= 155 then
    for LogicIndex := Low(TDominatorSeries) to High(TDominatorSeries) do ChameleonLogic[LogicIndex] := Buffer.GetByte;
  Count := Buffer.GetInt32;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    New(Entry);
    if Buffer.GetByte = 0 then Entry.LocationOwner := TObject(Buffer.GetUInt32 or stored_item_planet_flag)
    else Entry.LocationOwner := TObject(Buffer.GetUInt32);
    Entry.SlotIndex := Buffer.GetInt32;
    Entry.Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
    StorageEntries.Add(Entry);
    Entry.Item.LoadFromBuffer(Buffer, Galaxy);
  end;
  DebtAmount := Buffer.GetInt32;
  DebtDueTurn := Buffer.GetInt32;
  DebtDefaultCount := Buffer.GetInt32;
  DepositAmount := Buffer.GetInt32;
  DepositStartTurn := Buffer.GetInt32;
  DepositDayCount := Buffer.GetInt32;
  DepositInterestRate := Buffer.GetSingle;
  MedicalPolicyTicks := Buffer.GetInt32;
  if LoadedSaveVersion >= 103 then
  begin
    PirateLicenseTicks := Buffer.GetInt32;
    PirateLicenseCash := Buffer.GetInt32;
    PendingPirateLicenseCash := Buffer.GetInt32;
  end
  else
  begin
    PirateLicenseTicks := 0;
    PirateLicenseCash := 0;
    PendingPirateLicenseCash := 0;
  end;
  if LoadedSaveVersion >= 108 then QueuedTravelTarget := TStar(Buffer.GetUInt32)
  else QueuedTravelTarget := nil;
  for ServiceIndex := Low(StationServiceLastUseTurns) to High(StationServiceLastUseTurns) do StationServiceLastUseTurns[ServiceIndex] := Buffer.GetInt32;
  for I := disease_blindness to stimulant_absolute_status do StatusEffectSourceNames[I] := Buffer.ReadWideString;
  DiseaseImmunity := Buffer.GetByte;
  if LoadedSaveVersion < 49 then
  begin
    ProgramRewardStocks[program_keller_call] := 0;
    for RewardIndex := program_logical_negation to High(ProgramRewardStocks) do ProgramRewardStocks[RewardIndex] := Buffer.GetInt32;
  end
  else
    for RewardIndex := Low(ProgramRewardStocks) to High(ProgramRewardStocks) do ProgramRewardStocks[RewardIndex] := Buffer.GetInt32;
  LastDominatorProgramRewardTurn := Buffer.GetInt32;
  DestroyedDominatorHullMass := Buffer.GetInt32;
  Count := Buffer.GetInt32;
  for I := 0 to Count - 1 do
  begin
    Satellite := TSatellite.Create;
    Satellites.Add(Satellite);
    Satellite.LoadFromBuffer(Buffer, Galaxy);
  end;
  Count := Buffer.GetInt32;
  SetLength(PlanetBattleHistory, Count);
  for I := 0 to Count - 1 do
  begin
    PlanetBattleHistory[I].MapId := Buffer.GetInt32;
    PlanetBattleHistory[I].Statistics.SignedTimeMs := Buffer.GetInt32;
    PlanetBattleHistory[I].Statistics.RobotsBuilt := Buffer.GetInt32;
    PlanetBattleHistory[I].Statistics.RobotsDestroyed := Buffer.GetInt32;
    PlanetBattleHistory[I].Statistics.TurretsBuilt := Buffer.GetInt32;
    PlanetBattleHistory[I].Statistics.TurretsDestroyed := Buffer.GetInt32;
    PlanetBattleHistory[I].Statistics.BuildingsDestroyed := Buffer.GetInt32;
    PlanetBattleHistory[I].ResultCode := Buffer.GetInt32;
    PlanetBattleHistory[I].CompletionMode := Buffer.GetInt32;
    PlanetBattleHistory[I].DateTurn := Buffer.GetInt32;
  end;
  PlanetBattles := Buffer.GetInt32;
  LastPlanetBattleTurn := Buffer.GetInt32;
  if LoadedSaveVersion >= 59 then DeclinePlanetBattleOffers := Buffer.GetBoolean
  else DeclinePlanetBattleOffers := False;
  DiseaseContractionCount := Buffer.GetWord;
  StimulantPurchaseCount := Buffer.GetWord;
  PrisonStaysCompleted := Buffer.GetWord;
  SatelliteTilesExplored := Buffer.GetInt32;
  NationalityChangeCount := Buffer.GetWord;
  SideChangeCount := Buffer.GetWord;
  SelectedEquipmentConfiguration := 0;
  SelectedEquipmentConfiguration := Buffer.GetByte;
  ConfigurationCount := Buffer.GetByte;
  for I := 0 to ConfigurationCount - 1 do
  begin
    SlotCount := Buffer.GetWord;
    for J := 0 to SlotCount - 1 do EquipmentConfigurations[I].EquipmentIds[J] := Buffer.GetUInt32;
    SlotCount := Buffer.GetWord;
    for J := 0 to SlotCount - 1 do EquipmentConfigurations[I].ArtefactIds[J] := Buffer.GetUInt32;
  end;
  PartnerCount := Buffer.GetByte;
  for I := 0 to PartnerCount - 1 do PiratePartners.Add(Pointer(Buffer.GetUInt32));
  Count := Buffer.GetByte;
  for I := 0 to Count - 1 do UnresolvedFlagsDA8[I] := Buffer.GetBoolean;
  Count := Buffer.GetUInt32;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    Journal := TJournalRecord.Create;
    JournalRecords.Add(Journal);
    Journal.LoadFromBuffer(Buffer);
  end;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    New(News);
    NewsEntries.Add(News);
    News.Id := Buffer.GetUInt32;
    News.Turn := Buffer.GetUInt32;
    News.NewsType := TGalaxyNewsKind(Buffer.GetByte);
    News.Text := Buffer.ReadWideString;
  end;
  PendingDockDialogue := Buffer.GetByte;
  NoJump := Buffer.GetBoolean;
  PirateClanReal := Buffer.GetBoolean;
  AchievementStats.LoadFromBuffer(Buffer);
  ExperienceByDominators := Buffer.GetInt32;
  ExperienceByPirates := Buffer.GetInt32;
  if LoadedSaveVersion >= 57 then ExperienceByNormals := Buffer.GetInt32;
  ExperienceByTraderCareer := Buffer.GetInt32;
  if LoadedSaveVersion >= 51 then
  begin
    RuinsMode := Buffer.GetByte;
    RuinsProxy := TRuins.Create;
    (RuinsProxy as TRuins).LoadFromBuffer(Buffer, Galaxy);
  end
  else
  begin
    RuinsMode := 0;
    RuinsProxy := nil;
  end;
  if RuinsMode > 0 then
  begin
    RuinsSavedDockedTo := TShip(Buffer.GetUInt32);
    RuinsSavedPlanet := TPlanet(Buffer.GetUInt32);
  end
  else
  begin
    RuinsSavedDockedTo := nil;
    RuinsSavedPlanet := nil;
  end;
  if LoadedSaveVersion >= 114 then RuinsStatusText := Buffer.ReadWideString
  else RuinsStatusText := '';
  if LoadedSaveVersion >= 120 then
  begin
    Count := Buffer.GetInt32;
    for I := 0 to Count - 1 do AwardedAchievementKeys.AddChildBlock(Buffer.ReadWideString);
  end
  else if LoadedSaveVersion >= 99 then
  begin
    for AchievementIndex := 0 to 82 do
      if Buffer.GetBoolean then AwardedAchievementKeys.AddChildBlock(WideString(AchievementDefinitionTable[AchievementIndex].Key));
  end
  else if LoadedSaveVersion >= 55 then
  begin
    for AchievementIndex := 0 to 61 do
      if Buffer.GetBoolean then AwardedAchievementKeys.AddChildBlock(WideString(AchievementDefinitionTable[AchievementIndex].Key));
  end;
  if GetAvailableAchievementCount > 0 then
  begin
    for AchievementIndex := 1 to 82 do
    begin
      Data := GetAchievementData(WideString(AchievementDefinitionTable[AchievementIndex].Key));
      if Data = nil then Continue;
      if Data.Achieved then
        if AwardedAchievementKeys.CountBlocks(WideString(AchievementDefinitionTable[AchievementIndex].Key)) <= 0 then
          AwardedAchievementKeys.AddChildBlock(WideString(AchievementDefinitionTable[AchievementIndex].Key));
      if not Data.Achieved then
        if AwardedAchievementKeys.CountBlocks(WideString(AchievementDefinitionTable[AchievementIndex].Key)) > 0 then
          AwardedAchievementKeys.DeleteChildBlock(WideString(AchievementDefinitionTable[AchievementIndex].Key));
      FreeAchievementData(Data);
    end;
  end;
  LastLoadedPlayerName := Name;
  RefreshPlayerQuestTargets;
end;
{ @end $747F20 }

{ @routine $748938 TPlayer_ResolveLoadedReferences }
procedure TPlayer.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  I: Integer;
  Found: Boolean;
  Item: TItem;
  Entry: PStorageEntry;
begin
  inherited ResolveLoadedReferences(Galaxy);
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := PStorageEntry(StorageEntries[I]);
    if Cardinal(Entry.LocationOwner) and stored_item_planet_flag <> 0 then
      Entry.LocationOwner := Galaxy.IdToPlanet(Cardinal(Entry.LocationOwner) and TaggedObjectIdMask)
    else Entry.LocationOwner := Galaxy.IdToShip(Cardinal(Entry.LocationOwner), True);
    Entry.Item.ResolveLoadedReferences(Galaxy);
  end;
  for I := 0 to Satellites.Count - 1 do TSatellite(Satellites[I]).ResolveLoadedReferences(Galaxy);
  I := 0;
  while PiratePartners.Count > I do
  begin
    PiratePartners[I] := Galaxy.IdToShip(Cardinal(PiratePartners[I]), False);
    if PiratePartners[I] <> nil then Inc(I)
    else PiratePartners.Delete(I);
  end;
  if QueuedTravelTarget <> nil then QueuedTravelTarget := Galaxy.IdToStar(Cardinal(QueuedTravelTarget));
  if RuinsMode > 0 then RuinsProxy.CurrentStar := CurrentStar;
  if RuinsSavedPlanet <> nil then RuinsSavedPlanet := Galaxy.IdToPlanet(Cardinal(RuinsSavedPlanet)) as TPlanet;
  if RuinsSavedDockedTo <> nil then RuinsSavedDockedTo := Galaxy.IdToShip(Cardinal(RuinsSavedDockedTo), True) as TShip;
  if (LoadedSaveVersion < 146) and (CurrentPlanet = nil) and (DockedTo = nil) then
  begin
    Found := False;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item is TEngine) and (TEngine(Item).TechLevel <= 7) then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then
    begin
      if GetEngine <> nil then UnequipItem(GetEngine);
      CreateAndEquipEngine(EngineBaseSize, 3, OwnerId);
    end;
    Found := False;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item is TFuelTanks) and (TFuelTanks(Item).TechLevel <= 7) then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then
    begin
      if GetFuelTanks <> nil then UnequipItem(GetFuelTanks);
      CreateAndEquipFuelTanks(FuelTanksBaseSize, 3, OwnerId);
    end;
  end;
end;
{ @end $748938 }

{ @routine $748BDC TPlayer_SaveToBlock }
procedure TPlayer.SaveToBlock(Block: TBlockParEC);
var I: TProgramIndex;
begin
  Block.AddParam(DecodeTextW('InChukriSotoanriIndo'), WideString(IntToStr(CurrentStar.Id))); // 'ICurStarId'
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('D5eyb7tn'), WideString(IntToStr(DebtAmount))); // 'Debt'
  Block.AddParam(DecodeTextW('DDe3bgt5Dha6t7ej'), WideString(IntToStr(DebtDueTurn))); // 'DebtDate'
  Block.AddParam(DecodeTextW('Dbe5bht6C7njt8'), WideString(IntToStr(DebtDefaultCount))); // 'DebtCnt'
  Block.AddParam(DecodeTextW('D0ehp7ojsgi4td'), WideString(IntToStr(DepositAmount))); // 'Deposit'
  Block.AddParam(DecodeTextW('Dbe5p7ojsriet4Dga6t7ek'), WideString(IntToStr(DepositStartTurn))); // 'DepositDate'
  Block.AddParam(DecodeTextW('D0ebp5o3sfi3t5Dha7y8'), WideString(IntToStr(DepositDayCount))); // 'DepositDay'
  Block.AddParam(DecodeTextW('Dpeupto5seiwtfPye6rucieon9t'), WideString(FloatToStr(DepositInterestRate))); // 'DepositPercent'
  Block.AddParam(DecodeTextW('Mmejd6Ptoel4i6c7yi'), WideString(IntToStr(MedicalPolicyTicks))); // 'MedPolicy'
  for I := Low(ProgramCounts) to High(ProgramCounts) do Block.AddParam(ProgramNames[I], WideString(IntToStr(ProgramCounts[I])));
  Block.AddParam(DecodeTextW('Emxjp7D8o5m'), WideString(IntToStr(ExperienceByDominators))); // 'ExpDom'
  Block.AddParam(DecodeTextW('E3xrp5P6i7r'), WideString(IntToStr(ExperienceByPirates))); // 'ExpPir'
  Block.AddParam(DecodeTextW('Emx8p7C4oga6'), WideString(IntToStr(ExperienceByNormals))); // 'ExpCoa'
  Block.AddParam(DecodeTextW('Ekx7peTwr3af'), WideString(IntToStr(ExperienceByTraderCareer))); // 'ExpTra'
end;
{ @end $748BDC }

{ @routine $749298 TPlayer_LoadFromBlock }
procedure TPlayer.LoadFromBlock(Block: TBlockParEC);
var I: TProgramIndex;
begin
  inherited LoadFromBlock(Block);
  DebtAmount := StrToInt(AnsiString(Block.GetParam(DecodeTextW('D5eyb7tn')))); // 'Debt'
  DebtDueTurn := StrToInt(AnsiString(Block.GetParam(DecodeTextW('DDe3bgt5Dha6t7ej')))); // 'DebtDate'
  DebtDefaultCount := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Dbe5bht6C7njt8')))); // 'DebtCnt'
  DepositAmount := StrToInt(AnsiString(Block.GetParam(DecodeTextW('D0ehp7ojsgi4td')))); // 'Deposit'
  DepositStartTurn := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Dbe5p7ojsriet4Dga6t7ek')))); // 'DepositDate'
  DepositDayCount := StrToInt(AnsiString(Block.GetParam(DecodeTextW('D0ebp5o3sfi3t5Dha7y8')))); // 'DepositDay'
  DepositInterestRate := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Dpeupto5seiwtfPye6rucieon9t'))); // 'DepositPercent'
  MedicalPolicyTicks := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Mmejd6Ptoel4i6c7yi')))); // 'MedPolicy'
  for I := Low(ProgramCounts) to High(ProgramCounts) do ProgramCounts[I] := StrToInt(AnsiString(Block.GetParam(ProgramNames[I])));
  ExperienceByDominators := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Emxjp7D8o5m')))); // 'ExpDom'
  ExperienceByPirates := StrToInt(AnsiString(Block.GetParam(DecodeTextW('E3xrp5P6i7r')))); // 'ExpPir'
  ExperienceByNormals := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Emx8p7C4oga6')))); // 'ExpCoa'
  ExperienceByTraderCareer := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Ekx7peTwr3af')))); // 'ExpTra'
end;
{ @end $749298 }

{ @routine $749874 TPlayer_InitializePlayerAtPlanet }
procedure TPlayer.InitializePlayerAtPlanet(Planet: TPlanet; InitialMoney, CharacterPreset: Integer);
begin
  inherited InitializeAtPlanet(Planet, InitialMoney);
  BaseNodes := RoundAndTruncateToTens(BaseNodes * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].ArcadeRewardScale);
  PreferredCareer := career_trader;
  CareerStatus[career_trader] := 0;
  CareerStatus[career_warrior] := 0;
  CareerStatus[career_pirate] := 0;
  EminentProgress[career_trader] := 0;
  EminentProgress[career_pirate] := 0;
  EminentProgress[career_warrior] := 0;
  BaseSkills[skill_accuracy] := 0;
  BaseSkills[skill_maneuverability] := 0;
  BaseSkills[skill_technical] := 0;
  BaseSkills[skill_trading] := 0;
  BaseSkills[skill_charisma] := 0;
  BaseSkills[skill_leadership] := 0;
end;
{ @end $749874 }

{ @routine $749918 TPlayer_ApplyCharacterPreset }
procedure TPlayer.ApplyCharacterPreset(Planet: TPlanet; InitialMoney, CharacterPreset: Integer);
var
  I, Quantity: Integer;
  Kind: TItemType;
  Item: TObject;
  Entry: PStorageEntry;
begin
  for I := Inventory.Count - 1 downto 0 do
  begin
    Item := Inventory[I];
    Inventory.Delete(I);
    Item.Free;
  end;
  for Kind := Low(EquipmentCache.Slots) to High(EquipmentCache.Slots) do
    EquipmentCache.Slots[Kind] := nil;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  case Ord(OwnerId) * 5 + CharacterPreset of
    1:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 20, [owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[1]), 3, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
    end;
    2:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.5, 0.9) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 1, [owner_feyan, owner_gaal]);
      ChangePlanetRelations(nil, relation_change_add, 40, [owner_peleng, owner_human]);
      CreateAndEquipHull(NextRandomIntRange(240, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[2]), 3, OwnerId);
      CreateAndEquipWeapon(item_flux, Round(WeaponInfos[item_flux].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
    end;
    3:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.2, 1.4) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 70, [owner_maloc, owner_peleng, owner_human, owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(290, 320, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(20, 80, RandomState);
    end;
    4:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.1) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 5, [owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(item_flux, Round(WeaponInfos[item_flux].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    5:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.9, 2.1) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 5, [owner_peleng, owner_feyan]);
      CreateAndEquipHull(NextRandomIntRange(210, 230, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[4]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 3, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    6:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 2.3, 2.5) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 25, [owner_maloc, owner_feyan]);
      CreateAndEquipHull(NextRandomIntRange(210, 230, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[4]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 3, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    7:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.4, 2.0) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 30, [owner_maloc, owner_human, owner_feyan, owner_gaal]);
      ChangePlanetRelations(nil, relation_change_cap, 60, [owner_peleng]);
      CreateAndEquipHull(NextRandomIntRange(230, 260, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    8:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.1) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 50, [owner_peleng, owner_human, owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(280, 320, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[2]), 3, OwnerId).ConditionPercent := NextRandomIntRange(20, 80, RandomState);
    end;
    9:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.9, 2.0) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 30, [owner_human, owner_feyan]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(7, 17, RandomState);
      (Entry.Item as TGoods).Init(item_luxury, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[Ord(item_luxury)].AveragePrice div 4);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    10:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.1) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, NextRandomIntRange(10, 35, RandomState), [owner_human]);
      ChangePlanetRelations(nil, relation_change_cap, NextRandomIntRange(10, 35, RandomState), [owner_feyan]);
      ChangePlanetRelations(nil, relation_change_cap, NextRandomIntRange(10, 35, RandomState), [owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(item_missile_launcher, Round(WeaponInfos[item_missile_launcher].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId).ConditionPercent := NextRandomIntRange(60, 90, RandomState);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(4, 10, RandomState);
      (Entry.Item as TGoods).Init(item_narcotics, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[Ord(item_narcotics)].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    11:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.3, 0.5) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 15, [owner_peleng]);
      CreateAndEquipHull(NextRandomIntRange(210, 230, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipDefGenerator(Round(DefGeneratorBaseSize * EquipmentSizeFactors[2]), 3, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
    end;
    12:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.5, 2.0) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 90, [owner_maloc, owner_peleng]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId).ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(100, 200, RandomState);
      (Entry.Item as TGoods).Init(item_minerals, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[Ord(item_minerals)].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    13:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.3, 1.5) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 25, [owner_maloc]);
      ChangePlanetRelations(nil, relation_change_add, 30, [owner_peleng, owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(280, 310, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    14:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.1, 1.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 5, [owner_peleng, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(240, 260, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 3, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[4]), 2, OwnerId);
    end;
    15:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, NextRandomIntRange(10, 35, RandomState), [owner_maloc]);
      ChangePlanetRelations(nil, relation_change_cap, NextRandomIntRange(10, 35, RandomState), [owner_feyan]);
      ChangePlanetRelations(nil, relation_change_cap, NextRandomIntRange(10, 35, RandomState), [owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[4]), 2, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 3, OwnerId);
    end;
    16:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 70, [owner_maloc, owner_peleng, owner_human, owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 3, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(item_flux, Round(WeaponInfos[item_flux].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    17:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 70, [owner_maloc, owner_peleng]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_missile_launcher, Round(WeaponInfos[item_missile_launcher].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    18:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.8, 1.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 70, [owner_peleng, owner_human, owner_feyan, owner_gaal]);
      ChangePlanetRelations(nil, relation_change_cap, 25, [owner_maloc]);
      CreateAndEquipHull(NextRandomIntRange(290, 320, RandomState), 1, OwnerId, -1, False).HullPoints := NextRandomIntRange(50, 150, RandomState);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[1]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[4]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
    end;
    19:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 15, [owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(270, 290, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[2]), 3, OwnerId);
      CreateAndEquipWeapon(item_flux, Round(WeaponInfos[item_flux].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    20:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 5, [owner_maloc, owner_human, owner_gaal]);
      ChangePlanetRelations(nil, relation_change_cap, 90, [owner_peleng]);
      ChangePlanetRelations(nil, relation_change_cap, 60, [owner_feyan]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(14, 20, RandomState);
      (Entry.Item as TGoods).Init(item_narcotics, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[Ord(item_narcotics)].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    21:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 70, [owner_maloc, owner_peleng, owner_human, owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 3, OwnerId);
      CreateAndEquipWeapon(item_fragmentation_cannon, Round(WeaponInfos[item_fragmentation_cannon].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    22:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.2, 1.3) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_floor, 60, [owner_maloc, owner_peleng, owner_human, owner_feyan, owner_gaal]);
      CreateAndEquipHull(NextRandomIntRange(220, 230, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[4]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    23:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.8, 1.2) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 5, [owner_maloc]);
      CreateAndEquipHull(NextRandomIntRange(280, 310, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(15, 30, RandomState);
      (Entry.Item as TGoods).Init(item_luxury, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[Ord(item_luxury)].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    24:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.2) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 35, [owner_maloc, owner_peleng, owner_human, owner_feyan]);
      CreateAndEquipHull(NextRandomIntRange(250, 260, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipRepairRobot(Round(RepairRobotBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(10, 20, RandomState);
      (Entry.Item as TGoods).Init(item_alcohol, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[Ord(item_alcohol)].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    25:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.2) * InitialMoney));
      ChangePlanetRelations(nil, relation_change_cap, 15, [owner_maloc, owner_peleng, owner_feyan]);
      CreateAndEquipHull(NextRandomIntRange(280, 300, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipWeapon(item_industrial_laser, Round(WeaponInfos[item_industrial_laser].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
    end;
  end;
  GetHull.Weight := RoundAndTruncateToTens(GetHull.Weight * HullCapacityScale /
    GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor);
  RefreshDerivedStats(True);
  while CargoFreeSpace < 15.0 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor do
  begin
    Inc(GetHull.Weight, 5);
    RefreshDerivedStats(True);
  end;
  case Galaxy.DifficultyLevels[7] of
    0: Inc(GetHull.Weight, 30);
    1: Inc(GetHull.Weight, 10);
    2: Inc(GetHull.Weight, 5);
  end;
  GetHull.HullPoints := GetHull.Weight;
  RefreshDerivedStats(True);
  RefreshGraphicSize;
  RefreshAssignedItemSlots;
  HomePlanet.ChangeRelationToRanger(GetPlayer, 100);
  for I := disease_blindness to stimulant_absolute_status do StatusEffectSourceNames[I] := '';
end;
{ @end $749918 }

{ @routine $74C674 TPlayer_NextDay }
procedure TPlayer.NextDay;
label
  ProgressDiseases;
var
  I, J, LastDisease, FirstDisease, TargetValue: Integer;
  LocationId: Cardinal;
  Found: Integer;
  Ship: TShip;
  Star: TStar;
  Item: TEquipment;
  Text: WideString;
  ResistanceFactor: Single;
  Binding: TScriptShip;
  LocalSeed: Cardinal;
  StimulantExcess, Stage: Integer;
begin
  Stage := 0;
  try
    BeginStorageTurn;
    if (Galaxy.CurrentTurn <= LastProcessedTurn) and (Galaxy.StasisModEnabled <> 1) then Exit;
    begin
      inherited NextDay;
      Stage := 1;
      if ScriptShipBindings <> nil then
      begin
        I := ScriptShipBindings.Count - 1;
        while I >= 0 do
        begin
          if ScriptShipBindings.Count <= I then I := ScriptShipBindings.Count - 1
          else
          begin
            Binding := ScriptShipBindings[I];
            if Binding.Script <> nil then Binding.Script.RunShipState(Binding);
            Dec(I);
          end;
        end;
      end;
      Stage := 2;
      if (Galaxy.CurrentTurn mod (((Integer(Galaxy.GenerationSeed) + Galaxy.CurrentTurn) div 1000) mod 10 + 2) = 0) and
        (DiseaseImmunity > 0) then Dec(DiseaseImmunity);
      { Unreachable lower clamp on the byte field. }
      if DiseaseImmunity < 0 then DiseaseImmunity := 0;
      if DiseaseImmunity > 100 then DiseaseImmunity := 100;
      if not InNormalSpace then AchievementStats.StarFuelCollected := 0;
      if MedicalPolicyTicks > 0 then
      begin
        Dec(MedicalPolicyTicks);
        LastMedicalPolicyTicks := MedicalPolicyTicks;
        if MedicalPolicyTicks = 0 then
          AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, PickLocalizedTextVariant('GalaxyNews.MedPolicy.End', Galaxy.CurrentTurn div 10), '');
      end;
      if PendingPirateLicenseCash > 0 then
      begin
        GainExperience(Round(PendingPirateLicenseCash * CareerStatus[career_pirate] * 0.001), experience_normal_ships);
        Inc(PirateLicenseCash, PendingPirateLicenseCash);
        PendingPirateLicenseCash := 0;
        if PirateLicenseCash > MaxMonetaryValue then PirateLicenseCash := MaxMonetaryValue;
      end;
      if PirateLicenseTicks > 0 then
      begin
        Dec(PirateLicenseTicks);
        if PirateLicenseTicks = 0 then
          AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, PickLocalizedTextVariant('GalaxyNews.PirateLicense.End', Galaxy.CurrentTurn div 10), '')
        else if Galaxy.ShipTypeCounts[station_dominion] <= 0 then
        begin
          Found := 0;
          for I := 0 to Galaxy.Stars.Count - 1 do
          begin
            Star := Galaxy.Stars[I];
            for J := 0 to Star.Ships.Count - 1 do
              if TShip(Star.Ships[J]).TypeId = station_dominion then
              begin
                Inc(Found);
                Break;
              end;
            if Found > 0 then Break;
          end;
          if Found = 0 then
          begin
            PirateLicenseTicks := 0;
            AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, PickLocalizedTextVariant('GalaxyNews.PirateLicense.DeadAllCB', Galaxy.CurrentTurn div 10), '');
          end;
        end;
      end;
      if (PirateLicenseCash > 0) and (PirateLicenseTicks <= 0) then
      begin
        if PirateLicenseCash <= 1000 then PirateLicenseCash := 0
        else if PirateLicenseCash <= 20000 then Dec(PirateLicenseCash, 1000)
        else PirateLicenseCash := Round(PirateLicenseCash * 0.95);
      end;
      if Money < 0 then SetMoney(0)
      else if Money > MaxMonetaryValue then SetMoney(MaxMonetaryValue);
      Stage := 3;
      if InNormalSpace then
        for I := 0 to CurrentStar.Ships.Count - 1 do
        begin
          Ship := CurrentStar.Ships[I];
          if Ship.InNormalSpace then Ship.DaysSincePlayerSeen := 0;
        end;
      Stage := 4;
      for I := 0 to Inventory.Count - 1 do
      begin
        Item := Inventory[I];
        if (Item.ItemType = item_engine) and (Item.EquippedFlag = 0) then
        begin
          if (Item as TEngine).OutputPercent + 10 > 100 then (Item as TEngine).OutputPercent := 100
          else Inc((Item as TEngine).OutputPercent, 10);
        end;
      end;
      Stage := 5;
      RechargeTransmitters;
      ApplyBioArtefactHealthEffects;
      RefreshNewsAtLocation;
      Stage := 6;
      if (CountActiveDiseases >= 3) or not
        (((CurrentPlanet <> nil) and not HasDiseaseFromCurrentPlanet) or
         ((DockedTo <> nil) and not HasDiseaseFromCurrentDockedShip) or InNormalSpace) then goto ProgressDiseases;
      FirstDisease := disease_blindness;
      LastDisease := disease_new_molizone;
      I := NextRandomIntRange(FirstDisease, LastDisease, RandomState);
      for J := FirstDisease to LastDisease do
      begin
        IncrementWrapped(I, FirstDisease, LastDisease);
        with CaptainHealthDefinitions[I] do
        begin
          if Galaxy.CurrentTurn < GalaxyWarmupTurns then Continue;
          if CaptainHealthDefinitions[I].Disabled then Continue;
          if (CurrentPlanet <> nil) and not (health_on_planet in CaptainHealthDefinitions[I].Locations) then Continue;
          if (DockedTo <> nil) and not (health_docked in CaptainHealthDefinitions[I].Locations) then Continue;
          if InNormalSpace and not (health_in_space in CaptainHealthDefinitions[I].Locations) and not (health_in_combat in CaptainHealthDefinitions[I].Locations) then Continue;
          if InNormalSpace and (health_in_combat in CaptainHealthDefinitions[I].Locations) then
            if (EnemyShip = nil) or not EnemyShip.IsAttackingShip(Self) or (GetHullIntegrityPercent > 50) or
              ((I = disease_holy_fanaticism) and (EnemyShip.OwnerId <> owner_dominator)) then Continue;
          if (CurrentPlanet <> nil) and not (CurrentPlanet.OwnerId in CaptainHealthDefinitions[I].AllowedLocationOwners) and
            ((CurrentPlanet.OwnerId = owner_uninhabited) or not (RaceToOwner(CurrentPlanet.RaceId) in CaptainHealthDefinitions[I].AllowedLocationOwners)) then Continue;
          if (DockedTo <> nil) and not (RaceToOwner(DockedTo.PilotRace) in CaptainHealthDefinitions[I].AllowedLocationOwners) and
            not (DockedTo.OwnerId in CaptainHealthDefinitions[I].AllowedLocationOwners) then Continue;
          if not (RaceToOwner(PilotRace) in AllowedOwners) or not (GetRangerRatingBand in AllowedRatingBands) or
            not (Rank in AllowedRanks) or not (GetDominantCareer in AllowedCareers) then Continue;
          if (CaptainHealth[I].Progress <= 0.0) and (CaptainHealth[I].ExpireTurn + TurnsPerYear <= Galaxy.CurrentTurn) then
          begin
            if IsHealthEffectActive(disease_complex_immunocide) then ResistanceFactor := 0.1
            else ResistanceFactor := 1.0;
            if IsHealthEffectActive(stimulant_blood_djogar) then ResistanceFactor := ResistanceFactor * 5.0;
            ResistanceFactor := (CountActiveArtefacts(artefact_health_protection) + 1) * ResistanceFactor;
            if CurrentPlanet <> nil then LocationId := CurrentPlanet.Id
            else if DockedTo <> nil then LocationId := DockedTo.Id
            else LocationId := CurrentStar.Id;
            LocalSeed := Galaxy.GenerationSeed + Cardinal(I) + LocationId + Cardinal(Galaxy.CurrentTurn div 3);
            if NextRandomFloatRange(0.0, 1.0, LocalSeed) * RemapClamped(DiseaseImmunity, 0.0, 100.0, 50.0, 300.0) * ResistanceFactor <=
              InfectionChance * 2.0 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor then
            begin
              CaptainHealth[I].Progress := 0.1;
              if InNormalSpace and (health_in_combat in CaptainHealthDefinitions[I].Locations) then CaptainHealth[I].Progress := 99.9999;
              CaptainHealth[I].AppliedTurn := Galaxy.CurrentTurn;
              CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + I + Galaxy.CurrentTurn), 0.0, 1.0, 0.5, 3.0) * CaptainHealthDefinitions[I].Duration);
              if CurrentPlanet <> nil then StatusEffectSourceNames[I] := CurrentPlanet.GetFullName(' ')
              else if DockedTo <> nil then StatusEffectSourceNames[I] := DockedTo.GetName
              else StatusEffectSourceNames[I] := CurrentStar.Name;
            end;
          end;
        end;
      end;
ProgressDiseases:
      Stage := 7;
      for I := disease_blindness to disease_new_molizone do
      begin
        if CaptainHealth[I].Progress = 0.0 then Continue;
        if CaptainHealth[I].Progress < 100.0 then
        begin
          if I in [disease_blindness..disease_holy_fanaticism] then
          begin
            if (CurrentPlanet <> nil) or (DockedTo <> nil) then CaptainHealth[I].Progress := 100.0;
          end
          else CaptainHealth[I].Progress := SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) - I + Galaxy.CurrentTurn) * CaptainHealthDefinitions[I].DevelopmentRate * 2.0 + CaptainHealth[I].Progress + 0.01;
          if CaptainHealth[I].Progress >= 100.0 then
          begin
            CaptainHealth[I].Progress := 100.0;
            Inc(CaptainHealth[I].ApplicationCount);
            CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + I + Galaxy.CurrentTurn), 0.0, 1.0, 0.9, 2.0) * CaptainHealthDefinitions[I].Duration);
            Text := LocalizedColorText(WideString('Illness.Illness.' + IntToStr(I - 1) + '.Start'));
            AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText2(Text, TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1), '<Name>', CaptainHealthDefinitions[I].Name), '');
            AchievementStats.CheckAllDiseasesAchievement;
            Inc(DiseaseContractionCount);
          end;
        end
        else if CaptainHealth[I].ExpireTurn <= Galaxy.CurrentTurn then
          if not (I in [disease_blindness..disease_holy_fanaticism]) or not CurrentStar.RecordingTurnFilm then
          begin
            CaptainHealth[I].Progress := 0.0;
            StatusEffectSourceNames[I] := '';
            Text := LocalizedColorText(WideString('Illness.Illness.' + IntToStr(I - 1) + '.End'));
            AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText2(Text, TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1), '<Name>', CaptainHealthDefinitions[I].Name), '');
          end;
      end;
      Stage := 8;
      for I := stimulant_maloq_sizha to stimulant_absolute_status do
        if (CaptainHealth[I].Progress = 100.0) and (CaptainHealth[I].ExpireTurn <= Galaxy.CurrentTurn) then
        begin
          Text := LocalizedColorText(WideString('Illness.Stimulant.' + IntToStr(I - 12 - 1) + '.End'));
          AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText1(Text, TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1)), '');
          CaptainHealth[I].Progress := 0.0;
        end;
      Stage := 9;
      for I := Low(RadiationHealth) to High(RadiationHealth) do
        if (RadiationHealth[I].Progress <> 0.0) and (RadiationHealth[I].ExpireTurn <= Galaxy.CurrentTurn) then
        begin
          Text := LocalizedColorText(WideString('Illness.ExtraIllness.' + IntToStr(I) + '.End'));
          AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText1(Text, TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1)), '');
          RadiationHealth[I].Progress := 0.0;
        end;
      Stage := 10;
      StimulantExcess := CountActiveStimulants - GetPlayer.GetTotalStatBonus(bonus_stimulant_capacity);
      { The native one-pass loop retains its dormant footer after Break. }
      while StimulantExcess >= 2 do
      begin
        I := disease_drug_addiction;
        if CaptainHealth[I].Progress <= 0.0 then
        begin
          LocalSeed := Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn);
          if Sqr(Max(0, StimulantExcess - CountActiveArtefacts(artefact_health_protection))) * 0.4 > NextRandomFloatRange(0.0, 1000.0, LocalSeed) then
            if (RaceToOwner(PilotRace) in CaptainHealthDefinitions[I].AllowedOwners) and
              (GetRangerRatingBand in CaptainHealthDefinitions[I].AllowedRatingBands) and
              (Rank in CaptainHealthDefinitions[I].AllowedRanks) and
              (GetDominantCareer in CaptainHealthDefinitions[I].AllowedCareers) then
            begin
              CaptainHealth[I].Progress := 100.0;
              CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + I + Galaxy.CurrentTurn), 0.0, 1.0, 0.5, 3.0) * CaptainHealthDefinitions[I].Duration);
              Inc(CaptainHealth[I].ApplicationCount);
              Text := LocalizedColorText(WideString('Illness.Illness.' + IntToStr(I - 1) + '.Start'));
              AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText2(Text, TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1), '<Name>', CaptainHealthDefinitions[I].Name), '');
              Inc(DiseaseContractionCount);
              AchievementStats.CheckAllDiseasesAchievement;
            end;
        end;
        Break;
      end;
      Stage := 11;
      if IsHealthEffectActive(disease_mysterious_luatanza) and (Galaxy.CurrentTurn > CaptainHealth[disease_mysterious_luatanza].AppliedTurn + 15) and (Galaxy.CurrentTurn mod 14 = 0) then
      begin
        if SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + 1736605 + Galaxy.CurrentTurn) > 0.8 then
        begin
          TargetValue := NextRandomIntRange(Galaxy.ComputeScaledSmallMoney(owner_human), Galaxy.ComputeScaledAverageMoney(owner_human), RandomState);
          SetMoney(TargetValue + Money);
          SoundManager.PlaySound('Sound.Sell');
          AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText2(PickLocalizedTextVariant('GalaxyNews.IllNews.IllLuatan', Seed * Cardinal(Galaxy.CurrentTurn div 10)), TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1), '<Money>', WideString(IntToStr(TargetValue))), '');
        end
        else AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText1(PickLocalizedTextVariant('GalaxyNews.IllNews.IllLuatanNo', Seed * Cardinal(Galaxy.CurrentTurn div 10)), TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1)), '');
      end;
      Stage := 12;
      if IsHealthEffectActive(disease_aka_sezyanka) and InNormalSpace and HasCargoGoods and
        (SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + 135432 + Galaxy.CurrentTurn) > 0.8) and (Galaxy.CurrentTurn mod 21 = 0) then
      begin
        TargetValue := NextRandomIntRange(Galaxy.ComputeScaledMiniMoney(owner_human), Galaxy.ComputeScaledBigMoney(owner_human), RandomState);
        JettisonCargoGoodsTowardTargetValue(TargetValue);
        SoundManager.PlaySound('Sound.Sell');
        AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, FormatText1(PickLocalizedTextVariant('GalaxyNews.IllNews.IllSeciyanka', Seed * Cardinal(Galaxy.CurrentTurn div 10)), TextHighlightColorTag, '<Date>', Galaxy.FormatTurnDate(-1)), '');
      end;
      Stage := 13;
      RefreshDerivedStats(True);
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TPlayer.NextDay, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $74C674 }

{ @routine $74DF58 TPlayer_ComputeDepositAccruedValue }
function TPlayer.ComputeDepositAccruedValue: Integer;
var
  Base, Exponent, LimitRatio: Extended;
begin
  Result := 0;
  if DepositAmount <= 0 then Exit;
  Base := 0.01 * DepositInterestRate / 12 + 1;
  Exponent := DepositDayCount / TurnsPerYear * 12;
  LimitRatio := MaxMonetaryValue / DepositAmount;
  if Ln(Base) * Exponent > Ln(LimitRatio) then Result := MaxMonetaryValue
  else Result := Round(Power(Base, Exponent) * DepositAmount);
end;
{ @end $74DF58 }

{ @routine $74E04C TPlayer_RechargeTransmitters }
procedure TPlayer.RechargeTransmitters;
var
  Item: TItem;
  Transmitter: TArtefactTransmitter;
  I: Integer;
begin
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Item := GetPlayer.Artefacts[I];
    if Item.ItemType = artefact_transmitter then
    begin
      Transmitter := Item as TArtefactTransmitter;
      Inc(Transmitter.Power);
    end;
  end;
end;
{ @end $74E04C }

{ @routine $74E098 TPlayer_ApplyBioArtefactHealthEffects }
procedure TPlayer.ApplyBioArtefactHealthEffects;
var
  Selected: Integer; I: TCaptainHealthEffect; Count, J: Integer;
begin
  for J := 1 to CountActiveArtefacts(artefact_health_protection) do
  begin
    if HasActiveDisease and (NextRandomIntRange(1, 100, RandomState) <= 20) then
    begin
      Selected := NextRandomIntRange(1, CountActiveDiseases, RandomState);
      Count := 0;
      for I := Low(TCaptainDisease) to High(TCaptainDisease) do
        if CaptainHealth[I].Progress = 100.0 then
        begin
          Inc(Count);
          if Count = Selected then
          begin
            Dec(CaptainHealth[I].ExpireTurn);
            Break;
          end;
        end;
    end;
    if HasActiveStimulant and (NextRandomIntRange(1, 100, RandomState) <= 50) then
    begin
      Selected := NextRandomIntRange(1, CountActiveStimulants, RandomState);
      Count := 0;
      for I := Low(TCaptainStimulant) to High(TCaptainStimulant) do
        if CaptainHealth[I].Progress = 100.0 then
        begin
          Inc(Count);
          if Count = Selected then
          begin
            Inc(CaptainHealth[I].ExpireTurn);
            Break;
          end;
        end;
    end;
  end;
end;
{ @end $74E098 }

{ @routine $74E1A4 TPlayer_MayTakeSubCrack }
function TPlayer.MayTakeSubCrack: Boolean;
begin
  Result := Galaxy.IsDominatorSeriesUnresolved(series_terron) and (Galaxy.CurrentTurn > 2000) and
    ((Galaxy.CurrentTurn mod (Galaxy.CurrentTurn mod 11 + 20) = 0) or (Galaxy.CurrentTurn > 4000)) and
    not HasProgram(program_sab_crack);
end;
{ @end $74E1A4 }

{ @routine $74E218 TPlayer_GetSubCrackCost }
function TPlayer.GetSubCrackCost: Integer;
begin
  Result := Round(100000.0 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestMoneyFactor);
end;
{ @end $74E218 }

{ @routine $74E248 TPlayer_GetPirateServiceDiscount }
function TPlayer.GetPirateServiceDiscount: TPercent;
begin
  Result := Round(CareerStatus[career_pirate] / 1.3) + 1;
end;
{ @end $74E248 }

{ @routine $74E278 TPlayer_CountProgramRewardStocks }
function TPlayer.CountProgramRewardStocks: Integer;
var I: TProgramIndex;
begin
  Result := 0;
  for I := Low(ProgramRewardStocks) to High(ProgramRewardStocks) do Inc(Result, ProgramRewardStocks[I]);
end;
{ @end $74E278 }

{ @routine $74E294 TPlayer_TryAwardDominatorPrograms }
function TPlayer.TryAwardDominatorPrograms(Victim: TShip): Boolean;
var
  ProgramIndex: TProgramIndex;
  Count: Integer;
begin
  Inc(DestroyedDominatorHullMass, Victim.GetHull.Weight);
  if ((Victim as TKling).KlingType in [dominator_equantor..dominator_smersh, dominator_bertor]) and
    (DestroyedDominatorHullMass > Galaxy.ScaleIntByTechLevel(500, 3000) *
      GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor) and
    (Galaxy.CurrentTurn > TurnsPerYear * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor + LastDominatorProgramRewardTurn) then
  begin
    LastDominatorProgramRewardTurn := Galaxy.CurrentTurn;
    DestroyedDominatorHullMass := 0;
    ProgramIndex := SelectProgramReward;
    Count := GetProgramRewardCount(ProgramIndex);
    Inc(ProgramRewardStocks[ProgramIndex], Count);
    if Galaxy.CoalitionDefeatedTurn = 0 then
      AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn,
        FormatText2(PickLocalizedTextVariant('GalaxyNews.WB.NewProgramm', Seed * Cardinal(Galaxy.CurrentTurn div 10)),
          TextHighlightColorTag, '<Count>', IntToStr(Count), '<Programm>', GetProgramName(ProgramIndex)), '');
    Result := True;
  end
  else Result := False;
end;
{ @end $74E294 }

{ @routine $74E520 TPlayer_FindProfitableTradeRoute }
function TPlayer.FindProfitableTradeRoute(Nearby: Boolean; Seed: Cardinal; var PurchasePlanet, SalePlanet: TPlanet; var Good: Byte; GoodsMask: TItemTypeMask): Boolean;
var I, J, JumpRange: Integer;
  UnusedRouteLocal1, UnusedRouteLocal2, UnusedRouteLocal3: Integer;
  BuyPlanet, SellPlanet, BestBuyPlanet, BestSellPlanet: TPlanet;
  UnusedGoodsLocal1, UnusedGoodsLocal2: Integer;
  BestGood, Kind: Byte; Score, BestScore: Single;
begin
  if GetEngine <> nil then JumpRange := Max(Galaxy.ScaleIntByTechLevel(8, 20), GetEngine.JumpRange)
  else JumpRange := Galaxy.ScaleIntByTechLevel(8, 30);
  Score := 0;
  BestScore := Score;
  BestBuyPlanet := nil;
  BestSellPlanet := nil;
  BestGood := 0;
  for I := 0 to Galaxy.Planets.Count - 1 do begin
    BuyPlanet := Galaxy.Planets[I];
    if not BuyPlanet.CurrentStar.IsConstellationVisible then Continue;
    if not (BuyPlanet.OwnerId in PlanetOwnerMasks.Coalition) then Continue;
    for J := 0 to Galaxy.Planets.Count - 1 do begin
      SellPlanet := Galaxy.Planets[J];
      if not SellPlanet.CurrentStar.IsConstellationVisible then Continue;
      if not (SellPlanet.OwnerId in PlanetOwnerMasks.Coalition) then Continue;
      if (PurchasePlanet = BuyPlanet) or (SalePlanet = SellPlanet) or (SellPlanet = BuyPlanet) then Continue;
      if Nearby then begin
        if PointDistance(CurrentStar.Position, BuyPlanet.CurrentStar.Position) > Min(JumpRange, 20) then Continue;
        if PointDistance(CurrentStar.Position, SellPlanet.CurrentStar.Position) > Min(2 * JumpRange, 40) then Continue;
      end else begin
        Score := PointDistance(CurrentStar.Position, BuyPlanet.CurrentStar.Position) + PointDistance(BuyPlanet.CurrentStar.Position, SellPlanet.CurrentStar.Position);
        if (Score < 40) or (PointDistance(CurrentStar.Position, BuyPlanet.CurrentStar.Position) < 20) or
          (PointDistance(CurrentStar.Position, SellPlanet.CurrentStar.Position) < 30) then Continue;
        if (Score < 70) and (PointDistance(CurrentStar.Position, BuyPlanet.CurrentStar.Position) < Min(30, JumpRange)) and
          (PointDistance(BuyPlanet.CurrentStar.Position, SellPlanet.CurrentStar.Position) < Min(30, JumpRange)) then Continue;
      end;
      for Kind := 0 to 7 do begin
        if not (Kind in GoodsMask) then Continue;
        if not GoodsLegalOnPlanet[Kind, BuyPlanet.RaceId, BuyPlanet.Government] then Continue;
        if not GoodsLegalOnPlanet[Kind, SellPlanet.RaceId, SellPlanet.Government] then Continue;
        if BuyPlanet.RelationToShip(Self) < 20 then Continue;
        if SellPlanet.RelationToShip(Self) < 20 then Continue;
        if SeededRandomUnitFloat(Kind * Seed * BuyPlanet.GenerationSeed + SellPlanet.GenerationSeed) < 0.2 then Continue;
        Score := ShopGoodsSellPrice(Kind, SellPlanet) / ShopGoodsPurchasePrice(Kind, BuyPlanet);
        if Score < 1.11 then Continue;
        if ShopGoodsSellPrice(Kind, SellPlanet) - 5 < ShopGoodsPurchasePrice(Kind, BuyPlanet) then Continue;
        if GoodsMarket[Kind].BaseStock div 3 > BuyPlanet.Goods[Kind].Count then Continue;
        Score := Score * RemapClamped(BuyPlanet.Goods[Kind].Count, GoodsMarket[Kind].BaseStock div 3, GoodsMarket[Kind].BaseStock * 1.1, 0.7, 1.5);
        Score := Score * RemapClamped(PointDistance(CurrentStar.Position, BuyPlanet.CurrentStar.Position) / JumpRange, 0, 2, 1.3, 1);
        Score := Score * RemapClamped(PointDistance(BuyPlanet.CurrentStar.Position, SellPlanet.CurrentStar.Position) / JumpRange, 0, 3, 1.3, 1);
        Score := Score * SeededRandomFloatRange(Kind * BuyPlanet.GenerationSeed * SellPlanet.GenerationSeed + Seed * J, 1, 2.1);
        if Score > BestScore then begin
          BestScore := Score;
          BestBuyPlanet := BuyPlanet;
          BestSellPlanet := SellPlanet;
          BestGood := Kind;
        end;
      end;
    end;
  end;
  if BestScore > 0 then begin
    PurchasePlanet := BestBuyPlanet;
    SalePlanet := BestSellPlanet;
    Good := BestGood;
    Result := True;
  end else Result := False;
end;
{ @end $74E520 }

{ @routine $74EB60 TPlayer_HasDeployedSatellites }
function TPlayer.HasDeployedSatellites: Boolean;
var I: Integer; Satellite: TSatellite;
begin
  for I := 0 to Satellites.Count - 1 do
  begin
    Satellite := GetPlayer.Satellites[I];
    if Satellite.TargetPlanet <> nil then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{ @end $74EB60 }

{ @routine $74EB9C TPlayer_HasSatelliteOnPlanet }
function TPlayer.HasSatelliteOnPlanet(Planet: TPlanet): Boolean;
var
  I: Integer;
  Satellite: TSatellite;
begin
  for I := 0 to Satellites.Count - 1 do
  begin
    Satellite := GetPlayer.Satellites[I];
    if Satellite.TargetPlanet = Planet then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{ @end $74EB9C }

{ @routine $74EBD8 TPlayer_GetStorageColumnHeaderText }
function TPlayer.GetStorageColumnHeaderText: WideString;
var Text: WideString;
begin
  Text := TextHighlightColorTag;
  Text := Text + '<td=' + IntToStr(StorageHeaderColumns[GiResourceVariant].Size) + '><align=right>' +
    LocalizedText('FormShip.StorageInfo.Size') + '</align>';
  Text := Text + '<td=' + IntToStr(StorageHeaderColumns[GiResourceVariant].Cost) + '><align=right>' +
    LocalizedText('FormShip.StorageInfo.Cost') + '</align>';
  Text := Text + EndColorTag;
  Result := Text;
end;
{ @end $74EBD8 }

{ @routine $74EE08 TPlayer_GetStorageDividerText }
function TPlayer.GetStorageDividerText: WideString;
begin
  Result := WrapTextInColor(StringOfChar('-', StorageDividerLengths[GiResourceVariant]), GrayColorTag);
end;
{ @end $74EE08 }

{ @routine $74EEA8 TPlayer_BuildDeployedSatelliteSummary }
function TPlayer.BuildDeployedSatelliteSummary(var LineCount: Integer): WideString;
var
  I, J, HeaderCount, Condition, ExplorationTurns: Integer;
  Satellite: TSatellite;
  Text, RemainingText, SizeText, ExplorationText, ConditionText, StatusText, TempText, Divider: WideString;
  Planet: TPlanet;
begin
  Divider := GetStorageDividerText;
  Text := '';
  LineCount := 0;
  for I := 0 to Galaxy.Planets.Count - 1 do
  begin
    HeaderCount := 0;
    Planet := Galaxy.Planets[I];
    for J := 0 to Satellites.Count - 1 do
    begin
      Satellite := GetPlayer.Satellites[J];
      if Satellite.TargetPlanet = Planet then
      begin
        if HeaderCount = 0 then
        begin
          TempText := FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
            '', '<Star>', (Satellite.TargetPlanet as TPlanet).CurrentStar.Name);
          TempText := WrapTextInColor(TempText + '. ', TextHighlightColorTag) +
            WrapTextInColor((Satellite.TargetPlanet as TPlanet).GetFullName(' ') + '.', TextHighlightColorTag);
          RemainingText := ' ' + LocalizedText('FormShip.StorageInfo.PlanetNO');
          if Planet.WaterTiles - Planet.WaterExplored > 0 then
            ReplaceTextToken(RemainingText, '<Water>', IntToStr(Planet.WaterTiles - Planet.WaterExplored), AzureColorTag)
          else ReplaceTextToken(RemainingText, '<Water>', '-', GrayColorTag);
          if Planet.LandTiles - Planet.LandExplored > 0 then
            ReplaceTextToken(RemainingText, '<Land>', IntToStr(Planet.LandTiles - Planet.LandExplored), GreenColorTag)
          else ReplaceTextToken(RemainingText, '<Land>', '-', GrayColorTag);
          if Planet.HillTiles - Planet.HillExplored > 0 then
            ReplaceTextToken(RemainingText, '<Hill>', IntToStr(Planet.HillTiles - Planet.HillExplored), GoldColorTag)
          else ReplaceTextToken(RemainingText, '<Hill>', '-', GrayColorTag);
          TempText := TempText + RemainingText;
          Text := Text + #13#10 + Divider + #13#10 + '<td=' + IntToStr(ProbeSummaryColumns[GiResourceVariant].Heading) +
            '><align=center>' + TempText + '</align>' + #13#10 + Divider + #13#10;
          Inc(HeaderCount);
          Inc(LineCount);
        end;
        SizeText := WrapTextInColor(IntToStr(Satellite.Weight), GreenColorTag);
        TempText := '';
        if Satellite.WaterExplorationRate > 0 then
          TempText := TempText + WrapTextInColor(IntToStr(Satellite.WaterExplorationRate), AzureColorTag)
        else TempText := TempText + WrapTextInColor('-', GrayColorTag);
        TempText := TempText + '/';
        if Satellite.LandExplorationRate > 0 then
          TempText := TempText + WrapTextInColor(IntToStr(Satellite.LandExplorationRate), GreenColorTag)
        else TempText := TempText + WrapTextInColor('-', GrayColorTag);
        TempText := TempText + '/';
        if Satellite.HillExplorationRate > 0 then
          TempText := TempText + WrapTextInColor(IntToStr(Satellite.HillExplorationRate), GoldColorTag)
        else TempText := TempText + WrapTextInColor('-', GrayColorTag);
        ExplorationText := TempText;
        Condition := Trunc(Satellite.ConditionPercent);
        if Satellite.ConditionPercent > 0 then
          TempText := IntToStr(Condition) + '.' + IntToStr(Trunc(Satellite.ConditionPercent * 10) mod 10) + '%'
        else TempText := '0.0%';
        if Condition > 75 then TempText := WrapTextInColor(TempText, GreenColorTag)
        else if Condition > 50 then TempText := WrapTextInColor(TempText, TextHighlightColorTag)
        else if Condition > 25 then TempText := WrapTextInColor(TempText, GoldColorTag)
        else TempText := WrapTextInColor(TempText, RedColorTag);
        ConditionText := TempText;
        StatusText := '';
        ExplorationTurns := GetSatelliteExplorationTurns(Satellite);
        if ExplorationTurns = 0 then
          StatusText := ' ' + WrapTextInColor(LocalizedText('Items.Satellite.WorkEnd'), RedColorTag);
        Text := Text + '- ' + Satellite.GetDisplayName;
        Text := Text + '<td=' + IntToStr(ProbeSummaryColumns[GiResourceVariant].Size) + '><align=right>' + SizeText + '</align>';
        Text := Text + '<td=' + IntToStr(ProbeSummaryColumns[GiResourceVariant].Exploration) + '><align=right>' + ExplorationText + '</align>';
        Text := Text + '<td=' + IntToStr(ProbeSummaryColumns[GiResourceVariant].Condition) + '><align=right>' + ConditionText + '</align>';
        Text := Text + '<td=' + IntToStr(ProbeSummaryColumns[GiResourceVariant].Status) + '>' + StatusText + #13#10;
        Inc(LineCount);
      end;
    end;
  end;
  Result := Text;
end;
{ @end $74EEA8 }

{ @routine $74FA98 TPlayer_GetSatelliteExplorationTurns }
function TPlayer.GetSatelliteExplorationTurns(Satellite: TSatellite): Integer;
var
  I, Water, Land, Hill: Integer;
  Probe: TSatellite;
  Planet: TPlanet;
begin
  Result := 0;
  if Satellite.TargetPlanet = nil then Exit;
  if Satellite.BrokenFlag <> 0 then Exit;
  Planet := Satellite.TargetPlanet as TPlanet;
  Water := 0;
  Land := 0;
  Hill := 0;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
  begin
    Probe := GetPlayer.Satellites[I];
    if (Satellite.TargetPlanet <> Probe.TargetPlanet) or (Probe.BrokenFlag <> 0) then Continue;
    Water := Min(Planet.WaterTiles - Planet.WaterExplored, Water + Probe.WaterExplorationRate);
    Land := Min(Planet.LandTiles - Planet.LandExplored, Land + Probe.LandExplorationRate);
    Hill := Min(Planet.HillTiles - Planet.HillExplored, Hill + Probe.HillExplorationRate);
  end;
  if Water > 0 then Water := Min(999, Ceil((Planet.WaterTiles - Planet.WaterExplored) / Water));
  if Land > 0 then Land := Min(999, Ceil((Planet.LandTiles - Planet.LandExplored) / Land));
  if Hill > 0 then Hill := Min(999, Ceil((Planet.HillTiles - Planet.HillExplored) / Hill));
  if (Satellite.WaterExplorationRate > 0) and (Water > 0) then Result := Water;
  if (Satellite.LandExplorationRate > 0) and (Land > 0) then Result := Max(Result, Land);
  if (Satellite.HillExplorationRate > 0) and (Hill > 0) then Result := Max(Result, Hill);
end;
{ @end $74FA98 }

{ @routine $74FCCC TPlayer_CanAccessSurfaceLootItem }
function TPlayer.CanAccessSurfaceLootItem(Item: TItem): Boolean;
begin
  Result := True;
end;
{ @end $74FCCC }

{ @routine $74FCD0 TPlayer_ReportIdleSatellites }
procedure TPlayer.ReportIdleSatellites(Star: TStar);
var
  I, J, Remaining: Integer;
  Satellite: TSatellite;
  Text: WideString;
  Found: Boolean;
  Planets: array[1..3] of TPlanet;
begin
  Found := False;
  Text := '';
  Planets[1] := nil;
  Planets[2] := nil;
  Planets[3] := nil;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
  begin
    Satellite := GetPlayer.Satellites[I];
    if (Satellite.TargetPlanet = nil) or ((Satellite.TargetPlanet as TPlanet).CurrentStar <> Star) then Continue;
    Remaining := GetSatelliteExplorationTurns(Satellite);
    if Remaining > 0 then Continue;
    for J := 1 to 3 do
    begin
      if Planets[J] = Satellite.TargetPlanet then Break;
      if Planets[J] <> nil then Continue;
      Planets[J] := TPlanet(Satellite.TargetPlanet);
      Break;
    end;
    Text := Text + #13#10 + Satellite.GetIdleInfoText;
    Found := True;
  end;
  if Found then
  with AddOrUpdatePlayerBubble(message_galaxy_news, Galaxy.CurrentTurn, Text, '') do
  begin
    if Planets[1] <> nil then Targets[0].PlanetId := Planets[1].Id;
    if Planets[2] <> nil then Targets[1].PlanetId := Planets[2].Id;
    if Planets[3] <> nil then Targets[2].PlanetId := Planets[3].Id;
  end;
end;
{ @end $74FCD0 }

{ @routine $74FE40 TPlayer_BeginStorageTurn }
procedure TPlayer.BeginStorageTurn;
begin
end;
{ @end $74FE40 }

{ @routine $74FE44 TPlayer_CanAccessHoldGoods }
function TPlayer.CanAccessHoldGoods(Good: Byte): Boolean;
begin
  Result := True;
end;
{ @end $74FE44 }

{ @routine $74FE48 TPlayer_CanAccessStoredItem }
function TPlayer.CanAccessStoredItem(Item: TItem): Boolean;
begin
  Result := True;
end;
{ @end $74FE48 }

{ @routine $74FE4C TPlayer_CountStoredItemUnits }
function TPlayer.CountStoredItemUnits(Location: TObject; ItemType: TItemType): Integer;
var
  I: Integer;
  Entry: PStorageEntry;
begin
  Result := 0;
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := StorageEntries[I];
    if CanAccessStoredItem(Entry.Item) and ((Location = nil) or (Entry.LocationOwner = Location)) then
    begin
      if (ItemType in [item_food..item_narcotics]) or
        (ItemType in [item_nodes, item_stackable_misc]) then
      begin
        if Entry.Item.ItemType = ItemType then Inc(Result, Entry.Item.Weight);
      end
      else if Entry.Item.ItemType = ItemType then Inc(Result);
    end;
  end;
end;
{ @end $74FE4C }

{ @routine $74FEEC TPlayer_RepairDuplicateStorageSlots }
procedure TPlayer.RepairDuplicateStorageSlots(Location: TObject);
var I, J, Count: Integer; Entry, Other: PStorageEntry;
begin
  Count := StorageEntries.Count;
  for I := 0 to Count - 1 do begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) then
      for J := I + 1 to Count - 1 do begin
        Other := StorageEntries[J];
        if (Other.LocationOwner <> Location) or not CanAccessStoredItem(Other.Item) then Continue;
        if Entry.SlotIndex <> Other.SlotIndex then Continue;
        Other.SlotIndex := FindNextStorageSlot(Location);
      end;
  end;
end;
{ @end $74FEEC }

{ @routine $74FFB4 TPlayer_FindNextStorageSlot }
function TPlayer.FindNextStorageSlot(Location: TObject): Integer;
var
  I, Count: Integer;
  Entry: PStorageEntry;
begin
  Result := 0;
  Count := StorageEntries.Count;
  while True do
  begin
    I := 0;
    while I < Count do
    begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) and (Entry.SlotIndex = Result) then Break;
      Inc(I);
    end;
    if I < Count then Inc(Result)
    else Break;
  end;
end;
{ @end $74FFB4 }

{ @routine $75001C TPlayer_GetStorageSlotExtent }
function TPlayer.GetStorageSlotExtent(Location: TObject): Integer;
var I: Integer; Entry: PStorageEntry;
begin
  Result := 0;
  for I := 0 to StorageEntries.Count - 1 do begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner <> Location) or not CanAccessStoredItem(Entry.Item) then Continue;
    Result := Max(Result, Entry.SlotIndex + 1);
  end;
end;
{ @end $75001C }

{ @routine $750084 TPlayer_FindStorageIndexByLocationAndSlot }
function TPlayer.FindStorageIndexByLocationAndSlot(Location: TObject; Slot: Integer): Integer;
var
  I: Integer;
  Entry: PStorageEntry;
begin
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) and (Entry.SlotIndex = Slot) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;
{ @end $750084 }

{ @routine $7500E4 TPlayer_FindStorageGoodsByLocationAndType }
function TPlayer.FindStorageGoodsByLocationAndType(Location: TObject; Good: Byte): Integer;
var
  I: Integer;
  Entry: PStorageEntry;
begin
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and (Byte(Entry.Item.ItemType) = Good) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;
{ @end $7500E4 }

{ @routine $750130 TPlayer_FindMergeableStorageItemByLocation }
function TPlayer.FindMergeableStorageItemByLocation(Location: TObject; Item: TCountableItem): Integer;
var
  I: Integer;
  Entry: PStorageEntry;
begin
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner <> Location) or not Item.CanMerge(Entry.Item) then Continue;
    Result := I;
    Exit;
  end;
  Result := -1;
end;
{ @end $750130 }

{ @routine $75018C TPlayer_ShiftStorageSlotsAtOrAfter }
procedure TPlayer.ShiftStorageSlotsAtOrAfter(Location: TObject; Slot: Integer);
var
  I: Integer;
  Entry: PStorageEntry;
begin
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) and (Entry.SlotIndex >= Slot) then Inc(Entry.SlotIndex);
  end;
end;
{ @end $75018C }

{ @routine $7501E8 TPlayer_CloseVacantStorageSlot }
procedure TPlayer.CloseVacantStorageSlot(Location: TObject; Slot: Integer);
var I: Integer; Entry: PStorageEntry;
begin
  if FindStorageIndexByLocationAndSlot(Location, Slot) < 0 then
    for I := 0 to StorageEntries.Count - 1 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) then
        if Entry.SlotIndex >= Slot then Dec(Entry.SlotIndex);
    end;
end;
{ @end $7501E8 }

{ @routine $750258 TPlayer_HasAccessibleStorageAt }
function TPlayer.HasAccessibleStorageAt(Location: TObject): Boolean;
var I: Integer; Entry: PStorageEntry;
begin
  if Location = nil then begin Result := StorageEntries.Count <= 0; Exit; end;
  for I := 0 to StorageEntries.Count - 1 do begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) then begin Result := True; Exit; end;
  end;
  Result := False;
end;
{ @end $750258 }

{ @routine $7502BC TPlayer_CountPartnersInNormalSpace }
function TPlayer.CountPartnersInNormalSpace: Byte;
var I: Integer; Ship: TShip;
begin
  Result := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship.PartnerShip = Self) and Ship.InNormalSpace then Inc(Result);
  end;
end;
{ @end $7502BC }

{ @routine $75030C TPlayer_GetShipRatingComparison }
function TPlayer.GetShipRatingComparison(Ship: TShip): Byte;
var Ranger: TRanger;
begin
  Result := 0;
  if Ship.TypeId <> ship_ranger then Exit;
  Galaxy.RefreshRangerRatingPlaces;
  Ranger := Ship as TRanger;
  case Round(RemapClamped(Ranger.TotalExperience, GetPlayer.PlaceInRating / 3, 3 * GetPlayer.PlaceInRating, 0, 100)) of
    0..20: Result := 1;
    21..40: Result := 2;
    41..60: Result := 3;
    61..80: Result := 4;
    81..100: Result := 5;
  else RaiseWideMessage('Ошибк?? в рейтинге корабля в сравнении с игроком');
  end;
end;
{ @end $75030C }

{ @routine $750460 TPlayer_GetShipRankComparison }
function TPlayer.GetShipRankComparison(Ship: TShip): Byte;
var Normal: TNormalShip;
begin
  Result := 0;
  if not (Ship is TNormalShip) then Exit;
  Normal := Ship as TNormalShip;
  case Normal.Rank - GetPlayer.Rank of
    -7..-2: Result := 1;
    -1: Result := 2;
    0: Result := 3;
    1: Result := 4;
    2..7: Result := 5;
  else RaiseWideMessage('Error in ранк корабля в сравнении с игроком');
  end;
end;
{ @end $750460 }

{ @routine $75056C TPlayer_GetShipPirateRankComparison }
function TPlayer.GetShipPirateRankComparison(Ship: TShip): Byte;
var Normal: TNormalShip;
begin
  Result := 0;
  if not (Ship is TNormalShip) then Exit;
  Normal := Ship as TNormalShip;
  case Normal.PirateRank - GetPlayer.PirateRank of
    -8..-2: Result := 1;
    -1: Result := 2;
    0: Result := 3;
    1: Result := 4;
    2..8: Result := 5;
  else RaiseWideMessage('Error in ранк корабля в сравнении с игроком');
  end;
end;
{ @end $75056C }

{ @routine $750678 TPlayer_GetShipStrengthComparison }
function TPlayer.GetShipStrengthComparison(Ship: TShip): Byte;
begin
  Result := 0;
  case Round(RemapClamped(Ship.Strength, GetPlayer.Strength / 3, GetPlayer.Strength * 3, 0, 100)) of
    0..20: Result := 1;
    21..40: Result := 2;
    41..60: Result := 3;
    61..80: Result := 4;
    81..100: Result := 5;
  else RaiseWideMessage('Error in сила корабля в сравнении с игроком');
  end;
end;
{ @end $750678 }

{ @routine $750778 TPlayer_BuildTranclucatorStorageSummary }
function TPlayer.BuildTranclucatorStorageSummary(var LineCount: Integer): WideString;
var
  I: Integer;
  Star: TStar;
  J, HeaderCount: Integer;
  Ship: TShip;
  Text, Heading, Divider: WideString;
begin
  Divider := GetStorageDividerText;
  Text := '';
  LineCount := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    HeaderCount := 0;
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.TypeId <> ship_tranclucator then Continue;
      if (Ship as TTranclucator).OwnerShip <> GetPlayer then Continue;
      if Ship.IsHullDestroyed then Continue;
      if HeaderCount = 0 then
      begin
        Heading := WrapTextInColor(FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
          '', '<Star>', Star.Name), TextHighlightColorTag);
        Text := Text + #13#10 + Divider + #13#10 + '<td=' + IntToStr(TranclucatorSummaryWidths[GiResourceVariant]) +
          '><align=center>' + Heading + '</align>' + #13#10 + Divider + #13#10;
        Inc(HeaderCount);
        Inc(LineCount);
      end;
      Text := Text + '- ' + Ship.GetName + #13#10;
      Inc(LineCount);
    end;
  end;
  Result := Text;
end;
{ @end $750778 }

{ @routine $750A6C TPlayer_CompareStorageEntries }
function TPlayer.CompareStorageEntries(Left, Right: PStorageEntry): Integer;
var LeftStarId, RightStarId: Cardinal; LeftPriority, RightPriority: Integer;
begin
  if Left.LocationOwner is TPlanet then LeftStarId := (Left.LocationOwner as TPlanet).CurrentStar.Id
  else LeftStarId := (Left.LocationOwner as TShip).CurrentStar.Id;
  if Right.LocationOwner is TPlanet then RightStarId := (Right.LocationOwner as TPlanet).CurrentStar.Id
  else RightStarId := (Right.LocationOwner as TShip).CurrentStar.Id;
  if LeftStarId < RightStarId then begin Result := -1; Exit end
  else if LeftStarId > RightStarId then begin Result := 1; Exit end
  else if (Left.LocationOwner is TPlanet) and (Right.LocationOwner is TShip) then begin Result := -1; Exit end
  else if (Left.LocationOwner is TShip) and (Right.LocationOwner is TPlanet) then begin Result := 1; Exit end;
  if Left.LocationOwner is TPlanet then
  begin
    if (Left.LocationOwner as TPlanet).Id < (Right.LocationOwner as TPlanet).Id then begin Result := -1; Exit end;
    if (Left.LocationOwner as TPlanet).Id > (Right.LocationOwner as TPlanet).Id then begin Result := 1; Exit end;
  end
  else
  begin
    if (Left.LocationOwner as TShip).Id < (Right.LocationOwner as TShip).Id then begin Result := -1; Exit end;
    if (Left.LocationOwner as TShip).Id > (Right.LocationOwner as TShip).Id then begin Result := 1; Exit end;
  end;
  if Integer(Left.Item.ItemType) < Integer(Right.Item.ItemType) then begin Result := -1; Exit end;
  if Integer(Left.Item.ItemType) > Integer(Right.Item.ItemType) then begin Result := 1; Exit end;
  if (Left.Item.ItemType = item_micro_module) and (Right.Item.ItemType = item_micro_module) then
  begin
    LeftPriority := GetMicroModulePriorityColorTier((Left.Item as TMicroModule).MicroModuleIndex - 1);
    RightPriority := GetMicroModulePriorityColorTier((Right.Item as TMicroModule).MicroModuleIndex - 1);
    if LeftPriority > RightPriority then begin Result := -1; Exit end;
    if LeftPriority < RightPriority then begin Result := 1; Exit end;
    if (Left.Item as TMicroModule).MicroModuleIndex < (Right.Item as TMicroModule).MicroModuleIndex then begin Result := -1; Exit end;
    if (Left.Item as TMicroModule).MicroModuleIndex > (Right.Item as TMicroModule).MicroModuleIndex then begin Result := 1; Exit end;
  end;
  if Left.Item.Weight < Right.Item.Weight then begin Result := -1; Exit end
  else if Left.Item.Weight > Right.Item.Weight then begin Result := 1; Exit end;
  if Left.Item.Cost < Right.Item.Cost then begin Result := -1; Exit end
  else if Left.Item.Cost > Right.Item.Cost then begin Result := 1; Exit end;
  Result := 0;
end;
{ @end $750A6C }

{ @routine $750D44 TPlayer_SortStorageEntries }
procedure TPlayer.SortStorageEntries;
var I, J: Integer; Temp: PStorageEntry;
begin
  for I := 0 to StorageEntries.Count - 2 do
    for J := I + 1 to StorageEntries.Count - 1 do
      if CompareStorageEntries(StorageEntries[I], StorageEntries[J]) > 0 then
      begin
        Temp := StorageEntries[I];
        StorageEntries[I] := StorageEntries[J];
        StorageEntries[J] := Temp;
      end;
end;
{ @end $750D44 }

{ @routine $750DF8 TPlayer_RefreshStorageBubbles }
procedure TPlayer.RefreshStorageBubbles;
begin
  BuildStorageBubbles;
end;
{ @end $750DF8 }

{ @routine $750E00 TPlayer_BuildStorageBubbles }
procedure TPlayer.BuildStorageBubbles;
var
  I, LineCount, AddedLines, Page: Integer;
  Text, Heading, ConditionText, Divider: WideString;
  Entry: PStorageEntry;
  PreviousLocation: TObject;
begin
  SortStorageEntries;
  Divider := GetStorageDividerText;
  Page := 1;
  if StorageEntries.Count <= 0 then
  begin
    Heading := BuildTranclucatorStorageSummary(AddedLines);
    if HasDeployedSatellites or (Length(Heading) > 0) then
    begin
      Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main'), GreenColorTag) + #13#10;
      Text := Text + BuildDeployedSatelliteSummary(AddedLines);
      Text := Text + Heading;
      AddOrUpdatePlayerBubble(message_storage, Galaxy.CurrentTurn, Text, 'sys_storage1');
    end
    else RemovePlayerBubblePages('sys_storage', 0);
  end
  else
  begin
    PreviousLocation := nil;
    LineCount := 0;
    Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') +
      'onepage' + GetStorageColumnHeaderText, GreenColorTag) + #13#10;
    for I := 0 to StorageEntries.Count - 1 do
    begin
      Entry := StorageEntries[I];
      if (PreviousLocation <> Entry.LocationOwner) or (LineCount > 40) then
      begin
        if LineCount > 40 then
        begin
          if Page = 1 then
            ReplaceTextToken(Text, 'onepage', ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), MagentaColorTag) + ')', '');
          AddOrUpdatePlayerBubble(message_storage, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
          Inc(Page);
          Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') + ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), MagentaColorTag) + ')',
          GreenColorTag) + GetStorageColumnHeaderText + #13#10;
          LineCount := 0;
        end;
        if Entry.LocationOwner is TPlanet then
        begin
          Heading := FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
            '', '<Star>', (Entry.LocationOwner as TPlanet).CurrentStar.Name);
          Heading := WrapTextInColor(Heading + '. ', TextHighlightColorTag) +
            WrapTextInColor((Entry.LocationOwner as TPlanet).GetFullName(' ') + '.', TextHighlightColorTag);
          Text := Text + Divider + #13#10 + '<td=' + IntToStr(StorageItemColumns[GiResourceVariant].Heading) +
            '><align=center>' + Heading + '</align>' + #13#10 + Divider + #13#10;
          Inc(LineCount, 3);
        end
        else if Entry.LocationOwner is TShip then
        begin
          Heading := FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
            '', '<Star>', (Entry.LocationOwner as TShip).CurrentStar.Name);
          Heading := WrapTextInColor(Heading + '. ', TextHighlightColorTag) +
            WrapTextInColor((Entry.LocationOwner as TShip).GetFullName(' ') + '.', TextHighlightColorTag);
          Text := Text + Divider + #13#10 + '<td=' + IntToStr(StorageItemColumns[GiResourceVariant].Heading) +
            '><align=center>' + Heading + '</align>' + #13#10 + Divider + #13#10;
          Inc(LineCount, 3);
        end;
      end;
      PreviousLocation := Entry.LocationOwner;
      if Entry.Item is TEquipment then ConditionText := ' ' + (Entry.Item as TEquipment).GetConditionText(False)
      else ConditionText := '';
      Text := Text + '- ' + Entry.Item.GetDisplayName + ConditionText;
      Text := Text + '<td=' + IntToStr(StorageItemColumns[GiResourceVariant].Size) + '><align=right>' +
        WrapTextInColor(IntToStr(Entry.Item.Weight), GreenColorTag) + '</align>';
      Text := Text + '<td=' + IntToStr(StorageItemColumns[GiResourceVariant].Cost) + '><align=right>' +
        WrapTextInColor(IntToStr(Entry.Item.Cost), CyanColorTag) + '</align>';
      Text := Text + #13#10;
      Inc(LineCount);
    end;
    if HasDeployedSatellites then
    begin
      // Native computes the probe text once for its line count, then again below.
      BuildDeployedSatelliteSummary(AddedLines);
      if AddedLines + LineCount > 45 then
      begin
        if Page = 1 then
          ReplaceTextToken(Text, 'onepage', ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), MagentaColorTag) + ')', '');
        AddOrUpdatePlayerBubble(message_storage, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
        Inc(Page);
        Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') + ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), MagentaColorTag) + ')',
          GreenColorTag) + #13#10;
      end;
      if HasDeployedSatellites then Text := Text + BuildDeployedSatelliteSummary(AddedLines);
    end;
    Heading := BuildTranclucatorStorageSummary(AddedLines);
    if Length(Heading) > 0 then
    begin
      if AddedLines + LineCount > 45 then
      begin
        if Page = 1 then
          ReplaceTextToken(Text, 'onepage', ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), MagentaColorTag) + ')', '');
        AddOrUpdatePlayerBubble(message_storage, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
        Inc(Page);
        Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') + ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), MagentaColorTag) + ')',
          GreenColorTag) + #13#10;
      end;
      Text := Text + Heading;
    end;
    if Page = 1 then ReplaceTextToken(Text, 'onepage', '', '');
    AddOrUpdatePlayerBubble(message_storage, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
  end;
  RemovePlayerBubblePages('sys_storage', Page + 1);
  RemovePlayerBubbleByKey('sys_storage');
end;
{ @end $750E00 }

{ @routine $751D90 TPlayer_SelectPlanetBattleMap }
function TPlayer.SelectPlanetBattleMap: Integer;
var I, MapIndex, Count: Integer; Candidates: array of Integer;
begin
  Result := -1;
  if ((IsInstallFeatureEnabled('Robot')) and (GetPlayer.IsOnPlanet and ((Galaxy.BlazerSeriesResolvedTurn <= 0) or (Galaxy.KellerSeriesResolvedTurn <= 0) or (Galaxy.TerronSeriesResolvedTurn <= 0)))) and (LastPlanetBattleTurn <= Galaxy.CurrentTurn - RemapClamped(High(PlanetBattleHistory), 0, High(RobotMapDefinitions), 130, 360)) then begin
        for I := 0 to High(RobotMapDefinitions) do RobotMapDefinitions[I].PlayerPlayCount := 0;
        for I := 0 to High(PlanetBattleHistory) do begin
          MapIndex := FindRobotMapById(PlanetBattleHistory[I].MapId);
          if MapIndex >= 0 then Inc(RobotMapDefinitions[MapIndex].PlayerPlayCount);
        end;
        SetLength(Candidates, High(RobotMapDefinitions) + 1);
        Count := 0;
        for I := 0 to High(RobotMapDefinitions) do begin
          if (RobotMapDefinitions[I].PlanetRace <> []) and not (CurrentPlanet.RaceId in RobotMapDefinitions[I].PlanetRace) then Continue;
          if (RobotMapDefinitions[I].PlayerRace <> []) and not (PilotRace in RobotMapDefinitions[I].PlayerRace) then Continue;
          if (RobotMapDefinitions[I].PlayerStatus <> []) and not (GetDominantCareer in RobotMapDefinitions[I].PlayerStatus) then Continue;
          if High(PlanetBattleHistory) = -1 then begin
            if (RobotMapDefinitions[I].MinWins <> 0) or (RobotMapDefinitions[I].MaxWins <> 0) then Continue;
          end else begin
            MapIndex := High(PlanetBattleHistory) + 1;
            if ((RobotMapDefinitions[I].MinWins > MapIndex) and (RobotMapDefinitions[I].MinWins <> 0)) or
              ((RobotMapDefinitions[I].MaxWins < MapIndex) and (RobotMapDefinitions[I].MaxWins <> 0)) then Continue;
            if RobotMapDefinitions[I].AfterLiberation then begin
              if (Galaxy.CurrentTurn - GetPlayer.CurrentStar.LastLiberationRewardsTurn > 40) or
                (GetPlayer.CurrentStar.LastLiberationRewardsTurn > GetPlayer.CurrentStar.LastDominatorPresenceTurn) then Continue;
            end else if not (Galaxy.CurrentTurn - GetPlayer.CurrentStar.LastDominatorPresenceTurn in [30..120]) then Continue;
          end;
          if (RobotMapDefinitions[I].PlayerPlayCount < RobotMapDefinitions[I].Reiteration) and
             not RobotMapDefinitions[I].Terron and not RobotMapDefinitions[I].Demo and
             ((Count <= 0) or (RobotMapDefinitions[I].PlayerPlayCount <= RobotMapDefinitions[Candidates[0]].PlayerPlayCount)) then begin
            if (Count > 0) and (RobotMapDefinitions[I].PlayerPlayCount < RobotMapDefinitions[Candidates[0]].PlayerPlayCount) then Count := 0;
            Candidates[Count] := I;
            Inc(Count);
          end;
        end;
        if Count <= 0 then begin Candidates := nil; Exit; end;
        Result := RobotMapDefinitions[Candidates[SeededRandomIntRange(0, Count - 1, CurrentPlanet.GenerationSeed)]].Id;
        Candidates := nil;
      end;
end;
{ @end $751D90 }

{ @routine $7521FC TPlayer_SaveEquipmentConfiguration }
procedure TPlayer.SaveEquipmentConfiguration(Index: Integer);
var
  I, NextSlot, Slot: Integer;
  Weapon: TWeapon;
  Item: TEquipment;
  Artefact: TArtefact;
begin
  with EquipmentConfigurations[Index] do
  begin
    for I := 0 to 11 do EquipmentIds[I] := 0;
    for I := 0 to 31 do ArtefactIds[I] := 0;
    for I := 1 to 5 do
    begin
      Weapon := Weapons[I];
      if (Weapon = nil) or (Weapon.EquippedFlag = 0) then Continue;
      Slot := Weapon.AssignedSlotData and EquipmentSlotIndexMask;
      if (Slot < 0) or (Slot > 4) then Continue;
      EquipmentIds[Slot] := Weapon.Id;
    end;
    NextSlot := 5;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if (Item is TWeapon) or (Item.EquippedFlag = 0) or (ItemTypeToSlotKind(Item.ItemType) = slot_unsupported) then Continue;
      EquipmentIds[NextSlot] := Item.Id;
      Inc(NextSlot);
      if NextSlot > 11 then Break;
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      if Artefact.EquippedFlag = 0 then Continue;
      Slot := Artefact.AssignedSlotData and EquipmentSlotIndexMask;
      if (Slot < 0) or (DefaultHullSlotCounts[slot_artefact] <= Slot) then Continue;
      ArtefactIds[Slot] := Artefact.Id;
    end;
  end;
end;
{ @end $7521FC }

{ @routine $7527C8 TPlayer_ApplyEquipmentConfiguration }
procedure TPlayer.ApplyEquipmentConfiguration(Index: Integer);
  // @nested $752324 IsEmpty
  function IsEmpty: Boolean; // @addr $752324 @ida "bool __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    I: Integer;
  begin
    Result := True;
    with EquipmentConfigurations[Index] do
    begin
      for I := 0 to 11 do
        if EquipmentIds[I] <> 0 then
        begin
          Result := False;
          Exit;
        end;
      for I := 0 to 31 do
        if ArtefactIds[I] <> 0 then
        begin
          Result := False;
          Exit;
        end;
    end;
  end;
  // @nested $752368 SupportsItem
  function SupportsItem(Item: TItem): Boolean; // @addr $752368 @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  begin
    Result := True;
    if Item is TArtefact then Exit;
    if Item is TWeapon then Exit;
    if Item is TFuelTanks then Exit;
    if Item is TEngine then Exit;
    if Item is TRadar then Exit;
    if Item is TScaner then Exit;
    if Item is TRepairRobot then Exit;
    if Item is TCargoHook then Exit;
    if Item is TDefGenerator then Exit;
    Result := False;
  end;
  // @nested $752414 FindSlot
  function FindSlot(Item: TItem): Integer; // @addr $752414 @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    I: Integer;
  begin
    Result := -1;
    if SupportsItem(Item) then
      with EquipmentConfigurations[Index] do
      begin
        if Item is TArtefact then
        begin
          for I := 0 to 31 do
            if (Item as TArtefact).Id = ArtefactIds[I] then
            begin
              Result := I;
              Exit;
            end;
        end
        else if Item is TEquipment then
          for I := 0 to 11 do
            if (Item as TEquipment).Id = EquipmentIds[I] then
            begin
              Result := I;
              Exit;
            end;
      end;
  end;
  // @nested $7524B8 UnequipAll
  procedure UnequipAll; // @addr $7524B8 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    I: Integer;
    Item: TEquipment;
    Artefact: TArtefact;
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.ItemType in [item_hull..item_custom_weapon] then Item.Unequip;
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      Artefact.Unequip;
    end;
    WeaponCount := 0;
    for I := 1 to 5 do Weapons[I] := nil;
  end;
  // @nested $752560 ReleaseStorageEntry
  procedure ReleaseStorageEntry(Entry: PStorageEntry); // @addr $752560 @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  begin
    Entry.Item := nil;
    GetPlayer.StorageEntries.Delete(GetPlayer.StorageEntries.IndexOf(Entry));
    Dispose(Entry);
  end;
  // @nested $75259C TakeStoredItem
  procedure TakeStoredItem(Entry: PStorageEntry; Slot: Integer); // @addr $75259C @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    Item: TItem;
    Artefact: TArtefact;
    Equipment: TEquipment;
  begin
    Item := Entry.Item;
    if Item is TArtefact then
    begin
      Artefacts.Add(Item);
      ReleaseStorageEntry(Entry);
      Artefact := Item as TArtefact;
      Artefact.Equip;
      Slot := Slot or Integer(Artefact.AssignedSlotData and equipment_secondary_fire);
      Artefact.AssignedSlotData := Slot;
    end
    else if Item is TEquipment then
    begin
      Inventory.Add(Item);
      ReleaseStorageEntry(Entry);
      Equipment := Item as TEquipment;
      Equipment.Equip;
      if Item is TWeapon then begin
        Slot := Slot or Integer(Equipment.AssignedSlotData and equipment_secondary_fire);
        Equipment.AssignedSlotData := Slot;
      end;
    end;
  end;
  // @nested $752660 EquipCarriedItems
  procedure EquipCarriedItems; // @addr $752660 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    I, Slot: Integer;
    Equipment: TEquipment;
    Artefact: TArtefact;
  begin
    for I := 1 to Inventory.Count - 1 do
    begin
      Equipment := Inventory[I];
      Slot := FindSlot(Equipment);
      if Slot >= 0 then
      begin
        Equipment.Equip;
        Slot := Slot or Integer(Equipment.AssignedSlotData and equipment_secondary_fire);
        Equipment.AssignedSlotData := Slot;
      end;
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      Slot := FindSlot(Artefact);
      if Slot >= 0 then
      begin
        Artefact.Equip;
        Slot := Slot or Integer(Artefact.AssignedSlotData and equipment_secondary_fire);
        Artefact.AssignedSlotData := Slot;
      end;
    end;
  end;
  // @nested $752730 EquipStoredItems
  procedure EquipStoredItems; // @addr $752730 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    I, Slot: Integer;
    Entry: PStorageEntry;
  begin
    if (StorageEntries <> nil) and (IsDockedToShip or IsOnPlanet) then
      for I := StorageEntries.Count - 1 downto 0 do
      begin
        Entry := StorageEntries[I];
        if (Entry <> nil) and (Entry.Item <> nil) and ((DockedTo = Entry.LocationOwner) or (CurrentPlanet = Entry.LocationOwner)) then
        begin
          Slot := FindSlot(Entry.Item);
          if Slot >= 0 then TakeStoredItem(Entry, Slot);
        end;
      end;
  end;
begin
  if not IsEmpty then
  begin
    UnequipAll;
    EquipCarriedItems;
    EquipStoredItems;
    RebuildEquipmentCache;
  end;
end;
{ @end $7527C8 }

{ @routine $752800 TPlayer_HasEquipmentConfiguration }
function TPlayer.HasEquipmentConfiguration(Index: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  with EquipmentConfigurations[Index] do
  begin
    for I := 0 to 11 do
      if EquipmentIds[I] <> 0 then
      begin
        Result := True;
        Exit;
      end;
    for I := 0 to 31 do
      if ArtefactIds[I] <> 0 then
      begin
        Result := True;
        Exit;
      end;
  end;
end;
{ @end $752800 }

{ @routine $752838 TPlayer_GetAvailableNodeCount }
function TPlayer.GetAvailableNodeCount(Carrier: TShip): Integer;
var I: Integer; Entry: PStorageEntry;
begin
  if Carrier <> nil then Result := Carrier.GetCarriedNodeCount else Result := GetCarriedNodeCount;
  if IsOnPlanet then
    for I := 0 to StorageEntries.Count - 1 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = CurrentPlanet) and (Entry.Item.ItemType = item_nodes) then Inc(Result, Entry.Item.Weight);
    end;
  if IsDockedToShip then
    for I := 0 to StorageEntries.Count - 1 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = DockedTo) and (Entry.Item.ItemType = item_nodes) then Inc(Result, Entry.Item.Weight);
    end;
end;
{ @end $752838 }

{ @routine $7528E4 TPlayer_ConsumeAvailableNodes }
procedure TPlayer.ConsumeAvailableNodes(Count: Integer; Carrier: TShip);
var I, Remaining: Integer; Item: TItem; Entry: PStorageEntry;
begin
  if Count <= 0 then Exit;
  if Carrier = nil then Carrier := Self;
  for I := Carrier.Inventory.Count - 1 downto 1 do begin
    Item := Carrier.Inventory[I];
    if Item.ItemType = item_nodes then begin
      if Item.Weight > Count then begin
        Remaining := Item.Weight - Count;
        Dec((Item as TProtoplasm).StackCount, Count);
        Item.Cost := Round(Item.Cost / Item.Weight * Remaining);
        Item.Weight := Remaining;
        Count := 0;
      end else begin
        Dec(Count, Item.Weight);
        Carrier.Inventory.Delete(I);
        Item.Free;
      end;
    end;
    if Count = 0 then Break;
  end;
  if IsOnPlanet and (Count > 0) then
    for I := StorageEntries.Count - 1 downto 0 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = CurrentPlanet) and (Entry.Item.ItemType = item_nodes) then begin
        if Entry.Item.Weight > Count then begin
          Remaining := Entry.Item.Weight - Count;
          Dec((Entry.Item as TProtoplasm).StackCount, Count);
          Entry.Item.Cost := Round(Entry.Item.Cost / Entry.Item.Weight * Remaining);
          Entry.Item.Weight := Remaining;
          Count := 0;
        end else begin
          Dec(Count, Entry.Item.Weight);
          StorageEntries.Delete(I);
          Entry.Item.Free;
          Dispose(Entry);
        end;
      end;
      if Count = 0 then Break;
    end;
  if IsDockedToShip and (Count > 0) then
    for I := StorageEntries.Count - 1 downto 0 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = DockedTo) and (Entry.Item.ItemType = item_nodes) then begin
        if Entry.Item.Weight > Count then begin
          Remaining := Entry.Item.Weight - Count;
          Dec((Entry.Item as TProtoplasm).StackCount, Count);
          Entry.Item.Cost := Round(Entry.Item.Cost / Entry.Item.Weight * Remaining);
          Entry.Item.Weight := Remaining;
          Count := 0;
        end else begin
          Dec(Count, Entry.Item.Weight);
          StorageEntries.Delete(I);
          Entry.Item.Free;
          Dispose(Entry);
        end;
      end;
      if Count = 0 then Break;
    end;
  RefreshDerivedStats(True);
end;
{ @end $7528E4 }

{ @routine $752B1C TPlayer_GetMaxPiratePartners }
function TPlayer.GetMaxPiratePartners: Integer;
begin
  Result := 0;
  if CareerStatus[career_pirate] > 60 then Inc(Result);
  if CareerStatus[career_pirate] > 75 then Inc(Result);
  if Galaxy.EminentCareerShips[career_pirate] = Self then Inc(Result);
  if PirateLicenseTicks > 0 then Inc(Result);
end;
{ @end $752B1C }

{ @routine $752B4C TPlayer_GetMaxDominionShips }
function TPlayer.GetMaxDominionShips: Integer;
begin
  Result := 0;
  if CareerStatus[career_pirate] > 50 then Inc(Result);
  if CareerStatus[career_pirate] > 60 then Inc(Result);
  if CareerStatus[career_pirate] > 75 then Inc(Result);
  if Galaxy.EminentCareerShips[career_pirate] = Self then Inc(Result);
  if PirateLicenseTicks > 0 then Inc(Result);
end;
{ @end $752B4C }

{ @routine $752B84 TPlayer_AddJournalRecord }
procedure TPlayer.AddJournalRecord(Text: WideString);
var Entry: TJournalRecord;
begin
  Entry := TJournalRecord.Create;
  JournalRecords.Add(Entry);
  Entry.Text := Text;
  Entry.DateTurn := Galaxy.CurrentTurn;
end;
{ @end $752B84 }

{ @routine $752BFC TPlayer_DeleteJournalRecord }
procedure TPlayer.DeleteJournalRecord(Index: Integer);
begin
  if (Index >= 0) and (JournalRecords.Count >= Index) then
  begin
    TJournalRecord(JournalRecords[Index]).Free;
    JournalRecords.Delete(Index);
  end;
end;
{ @end $752BFC }

{ @routine $752C34 TPlayer_ClearJournal }
procedure TPlayer.ClearJournal;
begin
  while JournalRecords.Count > 0 do DeleteJournalRecord(JournalRecords.Count - 1);
end;
{ @end $752C34 }

{ @routine $752C54 TPlayer_ExportJournal }
function TPlayer.ExportJournal: WideString;
var
  I: Integer;
  Contents, FileName: AnsiString;
  Entry: TJournalRecord;
  Year, Month, Day: Word;
begin
  Contents := '';
  for I := 0 to JournalRecords.Count - 1 do
  begin
    Entry := JournalRecords[I];
    Contents := Contents + Galaxy.FormatTurnDate(Entry.DateTurn) + #13#10;
    Contents := Contents + RemoveTextTagsW(Entry.Text) + #13#10;
    Contents := Contents + #13#10;
  end;
  DecodeDate(Galaxy.TurnToDateTime(-1), Year, Month, Day);
  FileName := GetGameUserDirectory + 'Save\Journal_' + Format('%d_%.2d_%.2d', [Year, Month, Day]) + '.txt';
  WriteTextFileThreadSafe(FileName, Contents);
  Result := FileName;
end;
{ @end $752C54 }

{ @routine $752E84 TPlayer_SortNewsEntries }
procedure TPlayer.SortNewsEntries;
var
  I, J: Integer;
  First, Second: PPlanetNewsEntry;
  Temp: Pointer;
begin
  for I := 0 to NewsEntries.Count - 1 do
    for J := I + 1 to NewsEntries.Count - 1 do
    begin
      First := PPlanetNewsEntry(NewsEntries[I]);
      Second := PPlanetNewsEntry(NewsEntries[J]);
      if First.Id > Second.Id then
      begin
        Temp := NewsEntries[I];
        NewsEntries[I] := NewsEntries[J];
        NewsEntries[J] := Temp;
      end;
    end;
end;
{ @end $752E84 }

{ @routine $752F34 TPlayer_TrimNewsEntries }
procedure TPlayer.TrimNewsEntries(KeepCount: Integer);
var
  I: Integer;
  Entry: PPlanetNewsEntry;
begin
  for I := NewsEntries.Count - KeepCount - 1 downto 0 do
  begin
    Entry := PPlanetNewsEntry(NewsEntries[I]);
    NewsEntries.Delete(I);
    Dispose(Entry);
  end;
end;
{ @end $752F34 }

{ @routine $752F80 TPlayer_ExportNews }
function TPlayer.ExportNews: WideString;
var
  I: Integer;
  Contents, FileName: AnsiString;
  Entry: PPlanetNewsEntry;
  Year, Month, Day: Word;
begin
  Contents := '';
  for I := 0 to NewsEntries.Count - 1 do
  begin
    Entry := NewsEntries[I];
    Contents := Contents + Galaxy.FormatTurnDate(Entry.Turn) + #13#10;
    Contents := Contents + RemoveTextTagsW(Entry.Text) + #13#10;
    Contents := Contents + #13#10;
  end;
  DecodeDate(Galaxy.TurnToDateTime(-1), Year, Month, Day);
  FileName := 'Save\News_' + Format('%d_%.2d_%.2d', [Year, Month, Day]) + '.txt';
  WriteTextFileThreadSafe(FileName, Contents);
  Result := FileName;
end;
{ @end $752F80 }

{ @routine $753198 TPlayer_MergeGalaxyNews }
procedure TPlayer.MergeGalaxyNews;
var
  I, J: Integer;
  Found: Boolean;
  Source, Entry: PPlanetNewsEntry;
begin
  for I := 0 to Galaxy.PlanetNews.Count - 1 do
  begin
    Source := PPlanetNewsEntry(Galaxy.PlanetNews[I]);
    Found := False;
    for J := 0 to NewsEntries.Count - 1 do
    begin
      Entry := PPlanetNewsEntry(NewsEntries[J]);
      if Source.Id = Entry.Id then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then
    begin
      New(Entry);
      Entry.Id := Source.Id;
      Entry.Turn := Source.Turn;
      Entry.NewsType := Source.NewsType;
      Entry.Text := Source.Text;
      NewsEntries.Add(Entry);
    end;
  end;
end;
{ @end $753198 }

{ @routine $75327C TPlayer_RefreshNewsAtLocation }
procedure TPlayer.RefreshNewsAtLocation;
var Planet: TPlanet;
begin
  if (Galaxy.CurrentTurn > GalaxyWarmupTurns) and (IsOnPlanet or IsDockedToShip) then
  begin
    Planet := CurrentPlanet;
    if (Planet = nil) or ((Planet.OwnerId in [owner_maloc..owner_gaal, owner_pirate]) and
      (Planet.GetRelationLevelToShip(Self) > relation_level_bad)) then
    begin
      MergeGalaxyNews;
      SortNewsEntries;
      TrimNewsEntries(100);
    end;
  end;
end;
{ @end $75327C }

{ @routine $7532E4 TPlayer_CalculateSpeed }
function TPlayer.CalculateSpeed: Integer;
begin
  Result := inherited CalculateSpeed;
end;
{ @end $7532E4 }

{ @routine $7532EC TPlayer_CreateRuinsProxy }
procedure TPlayer.CreateRuinsProxy;
begin
  RuinsProxy := TRuins.Create;
  (RuinsProxy as TRuins).Init(station_military_base, GetPlayer.CurrentStar, '');
  CurrentStar.Ships.Delete(CurrentStar.Ships.IndexOf(RuinsProxy));
end;
{ @end $7532EC }

{ @routine $753344 TPlayer_EnterRuinsMode }
procedure TPlayer.EnterRuinsMode(Mode: Integer);
var SelectedMode: Integer;
begin
  if InHyperspace then Exit;
  if Mode > 0 then SelectedMode := Mode
  else SelectedMode := GetHull.CapitalShip;
  if SelectedMode = 0 then Exit;
  if RuinsMode = 0 then
  begin
    if TemporaryShopSlots <> nil then RestoreTemporaryShopStock;
    RuinsSavedPlanet := CurrentPlanet;
    RuinsSavedDockedTo := DockedTo;
    if RuinsProxy = nil then CreateRuinsProxy;
    DockedTo := RuinsProxy;
    CurrentPlanet := nil;
    RuinsProxy.CurrentStar := CurrentStar;
    BuildTemporaryShopSlotGrid;
  end;
  RuinsMode := SelectedMode;
  RequestedScreenId := screen_ruins_talk;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $753344 }

{ @routine $7533F8 TPlayer_CloseRuinsModeScreen }
procedure TPlayer.CloseRuinsModeScreen;
begin
  RuinsStatusText := '';
  if (RuinsSavedPlanet = nil) and (RuinsSavedDockedTo = nil) then
  begin
    RequestedScreenId := screen_star_map;
    if TemporaryShopSlots <> nil then
    begin
      Galaxy.CheckIntegrityChecksum(403);
      CurrentPlanet := nil;
      DockedTo := RuinsProxy;
      RestoreTemporaryShopStock;
      Galaxy.PrimeIntegrityChecksum(404);
    end;
  end
  else
  begin
    if RuinsSavedDockedTo <> nil then RequestedScreenId := screen_ruins_talk
    else if RuinsSavedPlanet.OwnerId <> owner_uninhabited then RequestedScreenId := screen_planet
    else RequestedScreenId := screen_uninhabited_planet;
    ExitRuinsMode;
  end;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $7533F8 }

{ @routine $7534B4 TPlayer_ExitRuinsMode }
procedure TPlayer.ExitRuinsMode;
begin
  Galaxy.CheckIntegrityChecksum(403);
  if TemporaryShopSlots <> nil then
  begin
    CurrentPlanet := nil;
    DockedTo := RuinsProxy;
    RestoreTemporaryShopStock;
  end;
  CurrentPlanet := RuinsSavedPlanet;
  RuinsSavedPlanet := nil;
  DockedTo := RuinsSavedDockedTo;
  RuinsSavedDockedTo := nil;
  RuinsMode := 0;
  BuildTemporaryShopSlotGrid;
  Galaxy.PrimeIntegrityChecksum(404);
end;
{ @end $7534B4 }

{ @routine $753528 TPlayer_RefreshCurrentStanding }
procedure TPlayer.RefreshCurrentStanding;
begin
  if IsInPrison then CurrentStanding := standing_neutral
  else if OwnerId <> owner_pirate then
  begin
    if (CurrentSystemKills.Pirate > 0) or (CurrentStar.ControlFaction = faction_coalition) then CurrentStanding := standing_coalition_active
    else CurrentStanding := standing_coalition_passive;
  end
  else
  begin
    if (CurrentSystemKills.Normal > 0) or (CurrentStar.ControlFaction = faction_pirates) then CurrentStanding := standing_pirate_active
    else CurrentStanding := standing_pirate_passive;
  end;
  if (CurrentStanding = standing_coalition_active) and (MainPiratePlanet <> nil) and (MainPiratePlanet.CurrentStar = CurrentStar) then
    CurrentStanding := standing_coalition_military;
end;
{ @end $753528 }

{ @routine $7535B8 TPlayer_CanSelectShipTarget }
function TPlayer.CanSelectShipTarget(Ship: TShip): Boolean;
var
  Faction: TStarFaction;
begin
  Result := False;
  if (Ship.TargetingRestriction = 1) and (Ship.EnemyShip <> Self) and (EnemyShip <> Ship) then Exit;
  if (Ship is TKling) and (ChameleonLogic[TKling(Ship).DominatorSeries] >= 2) and
    (Ship.EnemyShip <> Self) and (EnemyShip <> Ship) then Exit;
  if Ship.TypeId in [station_ranger_center..station_custom] then
  begin
    for Faction := Low(TStarFaction) to High(TStarFaction) do
      if (OwnerId in PlanetOwnerMasks.ByFaction[Faction]) and
        (Ship.CurrentStanding in NonTargetableStationStandingMasks[Faction]) and
        ((Ship.ScriptShip = nil) or (Ship.OwnerId in PlanetOwnerMasks.ByFaction[Faction])) then Exit;
  end;
  Result := True;
end;
{ @end $7535B8 }

{ @routine $753680 TPlayer_CanScanShip }
function TPlayer.CanScanShip(Ship: TShip): Boolean;
begin
  Result := True;
  if Galaxy.UltraScanModEnabled = 0 then
  begin
    if Ship is TRuins then Result := False
    else if (Ship is TKling) and not Ship.HasIndependentScriptFaction then
    begin
      if (GetPlayer.GetScanner = nil) or (GetPlayer.GetScanner.OwnerId <> owner_dominator) or
        (GetPlayer.GetScanner.DominatorSeries <> TKling(Ship).DominatorSeries) then Result := False;
    end;
    Result := GetPlayer.ScriptItemsAct(event_can_scan, Ship, nil, Ord(Result)) <> 0;
  end;
end;
{ @end $753680 }

end.
