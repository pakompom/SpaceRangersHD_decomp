unit aPlayer;
// Unit bracket (inferred): .text 0x005836F0..0x00591A5F; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

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
    EquipmentIds: array[0..11] of Integer; // @offset 0x00  Weapon slots 0..4, then up to seven other equipped items.
    ArtefactIds: array[0..31] of Integer; // @offset 0x30  Indexed by assigned artifact slot.
  end;

  TJournalRecord = class(TObjectEx) // @size 0x0C
  public
    DateTurn: Integer; // @offset 0x04
    Text: WideString; // @offset 0x08
    constructor Create; // @addr $5838E0
    destructor Destroy; override; // @addr $583934
    procedure SaveToBuffer(Buffer: TBufEC); // @addr $583968
    procedure LoadFromBuffer(Buffer: TBufEC); // @addr $583994
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
    DominatorKillsByType: array[0..7] of Integer; // @offset $56C Indexed by TKlingType. Arcade Keller contributes to the boss slot (zero).
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
    StationServiceLastUseTurns: array[0..11] of Integer; // @offset $5D0 Initialized to 150; last-use turns for investment/service cooldowns. Native reads $5C7072/$5BD5A5 and write $5CA6A5.
    StatusEffectSourceNames: array[1..24] of WideString; // @offset 0x600
    DiseaseImmunity: Byte; // @offset 0x660  Clamped to 0..100.
    ProgramRewardStocks: array[0..11] of Integer; // @offset $664 Programs awarded for destroyed Dominator hull mass.
    LastDominatorProgramRewardTurn: Integer; // @offset $694
    DestroyedDominatorHullMass: Integer; // @offset $698 Accumulated capacity; reset after a program reward.
    Satellites: TObjectList; // @offset 0x69C  Owned deployed TSatellite instances.
    PlanetBattleHistory: array of TPlanetBattleHistoryEntry; // @offset 0x6A0  Includes maps marked used without playing.
    PlanetBattles: Integer; // @offset 0x6A4
    LastPlanetBattleTurn: Integer; // @offset 0x6A8
    DeclinePlanetBattleOffers: Boolean; // @offset 0x6AC  Suppresses planetary-battle offers ($6CDE90); set by DeclineAllPlanetBattles ($6CF3DD), editable key RejectPB.
    DiseaseContractionCount: Word; // @offset 0x6AE
    StimulantPurchaseCount: Word; // @offset 0x6B0
    PrisonStaysCompleted: Word; // @offset $6B2 PRISON: successful return from the prison quest; native increment $6CBC7A.
    SatelliteTilesExplored: Integer; // @offset $6B4 ARCHEOLOGY: accumulated water/land/hill exploration gains; native add $7BD12C.
    NationalityChangeCount: Integer; // @offset $6B8 MANYFACES: accepted nationality changes ($5B7918). Serialized as a word.
    SideChangeCount: Integer; // @offset $6BC SIDECHANGER: switches between Coalition and pirate allegiance ($5B865B). Serialized as a word.
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
    ChameleonLogic: array[0..2] of Byte; // @offset 0xDEC  Script.PlayerLogicChameleon modes, indexed by TDominatorSeries.

    procedure InitializePlayerAtPlanet(Planet: TPlanet; InitialMoney, CharacterPreset: Integer); // @addr $586710 Inherited ranger registration followed by player career/skill defaults; CharacterPreset is unused here.
    procedure ApplyCharacterPreset(Planet: TPlanet; InitialMoney, CharacterPreset: Integer); // @addr $5867F0 Twenty-five race/preset loadouts, stored cargo and initial planet relations. Planet is unused.
    procedure BeginStorageTurn; // @addr $58D794 Native empty turn-start hook.
    procedure RechargeTransmitters; // @addr $58B630 Increments every carried transmitter in the global player's artefact list, including unequipped ones.
    procedure ApplyBioArtefactHealthEffects; // @addr $58B69C Each active Bio artefact may shorten a disease and extend a stimulant by one turn.
    function MayTakeSubCrack: Boolean; // @addr $58B80C Terron unresolved, late-game offer cadence and no program 4 already carried.
    function GetSubCrackCost: Integer; // @addr $58B890 Difficulty-scaled price.
    function GetPirateServiceDiscount: TPercent; // @addr $58B8D0 Rounded pirate career status / 1.3, plus one percentage point.
    function CountProgramRewardStocks: Integer; // @addr $58B910
    function GetMaxPiratePartners: Integer; // @addr $590BF0 Pirate career thresholds, eminent title and active license.
    function GetMaxDominionShips: Integer; // @addr $590C44 As pirate partners, with an additional threshold above career status 50.
    procedure AddJournalRecord(Text: WideString); // @addr $590CA8 Dates the new record with the current turn.
    procedure DeleteJournalRecord(Index: Integer); // @addr $590D2C Native guard accepts Index=Count, leaving the list accessor to raise.
    procedure ClearJournal; // @addr $590D7C
    procedure SortNewsEntries; // @addr $590FEC Ascending ID, using pairwise swaps.
    procedure MergeGalaxyNews; // @addr $591360 Copies galaxy news whose IDs are absent locally.
    procedure RefreshNewsAtLocation; // @addr $591460 Updates eligible docked players after turn 300 and retains the newest 100 entries.
    procedure CloseRuinsModeScreen; // @addr $59165C Returns to the saved location or star screen and requests screen closure.
    procedure RefreshCurrentStanding; override; // @addr $5917D0 @slot $C4 Includes the player's current-system kill counts and main pirate planet exception.
    constructor Create; // @addr $583A74 Native constructor initializes lists/defaults; does not register or generate the player loadout.
    destructor Destroy; override; // @addr $583E00 Requires the inherited ranger registration state for final cleanup.
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr $584054 @slot $00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr $5849C8 @slot $04
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr $585694 @slot $08
    procedure SaveToBlock(Block: TBlockParEC); override; // @addr $5859E8 @slot $10
    procedure LoadFromBlock(Block: TBlockParEC); override; // @addr $5860F0 @slot $14
    function ExportJournal: WideString; // @addr $590DAC
    function ExportNews: WideString; // @addr $591138
    procedure TrimNewsEntries(KeepCount: Integer); // @addr $5910D4 Removes and finalizes the oldest Count-KeepCount entries; unchecked argument.
    function TryAwardDominatorPrograms(Victim: TShip): Boolean; // @addr $58B944 Requires a TKling victim; records its hull capacity even when no reward is due.
    function GetSatelliteExplorationTurns(Satellite: TSatellite): Integer; // @addr $58D2E4 @note "Remaining duration at the current planet using combined operational probe rates; capped at 999 per terrain."
    procedure ReportIdleSatellites(Star: TStar); // @addr $58D5F0 @note "Reports inactive deployed satellites in the entered star; records up to three target planets."
    procedure ExitRuinsMode; // @addr $591738 Restores the real docking target and rebuilds its temporary shop stock.
    procedure CreateRuinsProxy; // @addr $5914F8 Creates a military-base proxy and removes it from the ordinary system ship list.
    procedure EnterRuinsMode(Mode: Integer); // @addr $591568 Nonpositive Mode uses the installed hull's CapitalShip kind.
    function CanSelectShipTarget(Ship: TShip): Boolean; // @addr $591890 Honors scripted targeting restrictions, chameleon logic and friendly station standing masks.
    function CanScanShip(Ship: TShip): Boolean; // @addr $5919A8 Checks station/Dominator restrictions and invokes the player's scan-permission item scripts.
    procedure SaveEquipmentConfiguration(Index: Integer); // @addr 0x58FFB4 @note "Index is zero-based and unchecked; the selected preset is unchanged."
    procedure ApplyEquipmentConfiguration(Index: Integer); // @addr 0x590714 @note "Can draw from storage at the current dock. Index is unchecked; the selected preset is unchanged."
    procedure NextDay; override; // @addr 0x5898EC @slot 0x18 @calls "0x6A8975"
    function HasEquipmentConfiguration(Index: Integer): Boolean; // @addr 0x59074C @note "Does not validate Index."

    function CalculateSpeed: Integer; override; // @addr 0x5914DC @slot 0x4C
    function ComputeDepositAccruedValue: Integer; // @addr 0x58B538 @note "Capped at 100000000; zero for nonpositive principal."
    function CanAccessStoredItem(Item: TItem): Boolean; // @addr $58D7B8 Native always-true permission hook used by storage lookup, counting and slot allocation.
    function CountStoredItemUnits(Location: TObject; ItemType: TItemType): Integer; // @addr 0x58D7D0 @note "Location=nil includes all storage locations. Goods and item types 69/75 count by weight; other matching items count individually."
    function HasSatelliteOnPlanet(Planet: TPlanet): Boolean; // @addr 0x58C334 @note "Requires Self=GetPlayer(): uses Self for the list count but fetches entries from the global player's deployed satellites."
    function CanAccessSurfaceLootItem(Item: TItem): Boolean; // @addr 0x58D5D8 @note "Native stub always returns true; Self and Item are unused. Called by treasure-map selection and planet loot reset."
    function FindNextStorageSlot(Location: TObject): Integer; // @addr 0x58D964 @note "Returns a nonnegative slot local to Location."
    function FindStorageIndexByLocationAndSlot(Location: TObject; Slot: Integer): Integer; // @addr 0x58DA7C @note "Returns a zero-based StorageEntries index, or -1."
    function FindStorageGoodsByLocationAndType(Location: TObject; Good: Byte): Integer; // @addr 0x58DB00 @note "Returns a zero-based StorageEntries index, or -1."
    function FindMergeableStorageItemByLocation(Location: TObject; Item: TCountableItem): Integer; // @addr 0x58DB78 @note "Returns a zero-based StorageEntries index, or -1."
    procedure ShiftStorageSlotsAtOrAfter(Location: TObject; Slot: Integer); // @addr 0x58DBF4
    function FindProfitableTradeRoute(Nearby: Boolean; Seed: Cardinal; var PurchasePlanet, SalePlanet: TPlanet; var Good: Byte; GoodsMask: TItemTypeMask): Boolean; // @addr $58BBF8 @ida "bool __userpurge $name@<al>(TPlayer *Self@<eax>, bool Nearby@<dl>, unsigned int Seed@<ecx>, TPlanet **PurchasePlanet@<^12>, TPlanet **SalePlanet@<^8>, unsigned __int8 *Good@<^4>, TItemTypeMask *GoodsMask@<^0>);" @note "Returns the highest-scoring visible Coalition trade route; retains output arguments on failure and excludes their previous endpoints."
    function SelectPlanetBattleMap: Integer; // @addr $58FA60 Returns a map ID or -1; updates shared map play-count scratch from the player's history.
    function CanAccessHoldGoods(Good: Byte): Boolean; // @addr $58D7A0 Native always-true permission hook; Good is passed in DL.
    procedure RepairDuplicateStorageSlots(Location: TObject); // @addr $58D888 Reassigns later accessible entries with duplicate slot indices.
    function GetStorageSlotExtent(Location: TObject): Integer; // @addr $58D9EC Maximum accessible slot index plus one, or zero.
    procedure CloseVacantStorageSlot(Location: TObject; Slot: Integer); // @addr $58DC6C Shifts later slots down only if Slot is unoccupied.
    function HasAccessibleStorageAt(Location: TObject): Boolean; // @addr $58DCF8 With nil, returns whether the entire storage list is empty.
    function CountPartnersInNormalSpace: Byte; // @addr $58DD84 Counts ships following Self in the current system, wrapping at 256.
    function GetShipRatingComparison(Ship: TShip): Byte; // @addr $58DDF0 Native compares ranger TotalExperience with the global player's PlaceInRating after refreshing rankings.
    function GetShipRankComparison(Ship: TShip): Byte; // @addr $58DF4C Returns 1..5 for relative Coalition rank, zero for non-normal ships.
    function GetShipPirateRankComparison(Ship: TShip): Byte; // @addr $58E064 Returns 1..5 for relative pirate rank, zero for non-normal ships.
    function GetShipStrengthComparison(Ship: TShip): Byte; // @addr $58E17C Returns 1..5 from strength relative to the global player.
    function GetAvailableNodeCount(Carrier: TShip): Integer; // @addr $5907B8 Includes the carrier's hold and the player's current-location storage.
    procedure ConsumeAvailableNodes(Count: Integer; Carrier: TShip); // @addr $5908BC Uses the carrier's hold, then current-location storage; refreshes Self even when Carrier differs.
    procedure RefreshStorageBubbles; // @addr 0x58EA64
    function HasDeployedSatellites: Boolean; // @addr $58C2D4 @note "Uses Self.Satellites.Count but reads the global player's list."
    function GetStorageColumnHeaderText: WideString; // @addr $58C398
    function GetStorageDividerText: WideString; // @addr $58C5D0
    function BuildDeployedSatelliteSummary(var LineCount: Integer): WideString; // @addr $58C678
    function BuildTranclucatorStorageSummary(var LineCount: Integer): WideString; // @addr $58E298
    function CompareStorageEntries(Left, Right: PStorageEntry): Integer; // @addr $58E5A8 @note "Compares star/location IDs, type, module priority/index, weight and cost; ignores slot indices."
    procedure SortStorageEntries; // @addr $58E97C
    procedure BuildStorageBubbles; // @addr 0x58EA78 @note "Publishes paginated storage summaries, including deployed probes; uses the global player's bubble list."
  end;

procedure SetPlayer(Player: TPlayer; Galaxy: TGalaxy); // @addr 0x583A14 @note "Updates Galaxy.PlayerRangerIndex; a nil Galaxy leaves the current player unchanged."
function GetPlayer: TPlayer; // @addr 0x5839FC

var
  ArcadeKellerDefeats: Integer; // @addr $88A868 Native campaign reward guard.
  ArcadeKellerReward: TObject; // @addr $88A86C Owned reward item pending transfer.
  // The native initial DWORD decodes to nil; zero would decode to a non-null pointer.
  EncodedPlayer: Cardinal = $B1CD15D3; // @addr $87B050
  StorageHeaderColumns: TStorageHeaderColumnTable = ((Size: 300; Cost: 380), (Size: 400; Cost: 490)); // @addr $87B054
  StorageDividerLengths: TStorageDividerLengthTable = (76, 98); // @addr $87B064
  ProbeSummaryColumns: TProbeSummaryColumnTable = (
    (Heading: 190; Size: 160; Exploration: 220; Condition: 280; Status: 295),
    (Heading: 250; Size: 200; Exploration: 280; Condition: 370; Status: 390)); // @addr $87B06C
  TranclucatorSummaryWidths: TStorageDividerLengthTable = (180, 240); // @addr $87B094
  StorageItemColumns: TStorageItemColumnTable = ((Heading: 190; Size: 300; Cost: 380), (Heading: 250; Size: 400; Cost: 490)); // @addr $87B09C

implementation

uses SysUtils, GR_Main, EC_Str, Math, Globals, SimpleSteamApi, aScript, aKling, aConst, aGalaxyStruct, fEquipmentShop, GlobalsV, aTranclucator;

{ @routine $5838E0 TJournalRecord_Create }
constructor TJournalRecord.Create;
begin
  inherited Create;
  DateTurn := 0;
  Text := '';
end;
{ @end $5838E0 }

{ @routine $583934 TJournalRecord_Destroy }
destructor TJournalRecord.Destroy;
begin
  inherited Destroy;
end;
{ @end $583934 }

{ @routine $583968 TJournalRecord_SaveToBuffer }
procedure TJournalRecord.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddIntegerValue(DateTurn);
  Buffer.AddWideStringZ(Text);
end;
{ @end $583968 }

{ @routine $583994 TJournalRecord_LoadFromBuffer }
procedure TJournalRecord.LoadFromBuffer(Buffer: TBufEC);
begin
  DateTurn := Buffer.GetInt32;
  Text := Buffer.ReadWideString;
end;
{ @end $583994 }

{ @routine $5839FC GetPlayer }
function GetPlayer: TPlayer;
begin
  Result := TPlayer(EncodedPlayer xor $B1CD15D3);
end;
{ @end $5839FC }

{ @routine $583A14 SetPlayer }
procedure SetPlayer(Player: TPlayer; Galaxy: TGalaxy);
begin
  if Galaxy <> nil then
  begin
    EncodedPlayer := Cardinal(Player) xor $B1CD15D3;
    if Player = nil then Galaxy.PlayerRangerIndex := -1
    else if Galaxy.Rangers = nil then Galaxy.PlayerRangerIndex := -1
    else Galaxy.PlayerRangerIndex := Galaxy.Rangers.IndexOf(Player);
  end;
end;
{ @end $583A14 }

{ @routine $583A74 TPlayer_Create }
constructor TPlayer.Create;
var
  ServiceIndex: Byte;
  I, J: Integer;
  RewardIndex, KillIndex, LogicIndex: Byte;
begin
  inherited Create;
  StorageEntries := TList.Create;
  TalkLocked := False;
  ScanLocked := False;
  ScriptShipBindings := TList.Create;
  HyperspaceKillCount := 0;
  BlackHoleKillCount := 0;
  for KillIndex := 0 to 7 do DominatorKillsByType[KillIndex] := 0;
  for LogicIndex := 0 to 2 do ChameleonLogic[LogicIndex] := 0;
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
  for I := 1 to 24 do StatusEffectSourceNames[I] := '';
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
{ @end $583A74 }

{ @routine $583E00 TPlayer_Destroy }
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
{ @end $583E00 }

{ @routine $584054 TPlayer_SaveToBuffer }
procedure TPlayer.SaveToBuffer(Buffer: TBufEC);
var
  I, J, ConfigurationCount, SlotCount, ListCount, NewsCount: Integer;
  Entry: PStorageEntry;
  ServiceIndex, RewardIndex: Byte;
  News: PPlanetNewsEntry;
  KillIndex, LogicIndex: Byte;
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddBoolean(InPrison);
  Buffer.AddBoolean(TalkLocked);
  Buffer.AddBoolean(ScanLocked);
  Buffer.AddIntegerValue(HyperspaceKillCount);
  Buffer.AddIntegerValue(BlackHoleKillCount);
  for KillIndex := 0 to 7 do Buffer.AddIntegerValue(DominatorKillsByType[KillIndex]);
  for LogicIndex := 0 to 2 do Buffer.AddAnsiChar(AnsiChar(ChameleonLogic[LogicIndex]));
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
  for I := 1 to 24 do Buffer.AddWideStringZ(StatusEffectSourceNames[I]);
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
{ @end $584054 }

{ @routine $5849C8 TPlayer_LoadFromBuffer }
procedure TPlayer.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, Count, J, ConfigurationCount, SlotCount, PartnerCount: Integer;
  Entry: PStorageEntry;
  ServiceIndex, RewardIndex: Byte;
  Satellite: TSatellite;
  Journal: TJournalRecord;
  News: PPlanetNewsEntry;
  AchievementIndex: Integer;
  Data: PAchievementData;
  KillIndex, LogicIndex: Byte;
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion <= 164 then ClearRecentlyDroppedItems;
  InPrison := Buffer.GetBoolean;
  TalkLocked := Buffer.GetBoolean;
  ScanLocked := Buffer.GetBoolean;
  HyperspaceKillCount := Buffer.GetInt32;
  BlackHoleKillCount := Buffer.GetInt32;
  if LoadedSaveVersion >= 89 then
    for KillIndex := 0 to 7 do DominatorKillsByType[KillIndex] := Buffer.GetInt32
  else if LoadedSaveVersion >= 74 then
  begin
    for KillIndex := 0 to 5 do DominatorKillsByType[KillIndex] := Buffer.GetInt32;
    DominatorKillsByType[6] := 0;
    DominatorKillsByType[7] := 0;
  end
  else
    for KillIndex := 0 to 7 do DominatorKillsByType[KillIndex] := 0;
  if LoadedSaveVersion >= 155 then
    for LogicIndex := 0 to 2 do ChameleonLogic[LogicIndex] := Buffer.GetByte;
  Count := Buffer.GetInt32;
  if (Count < 0) or (Count > 10000) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    New(Entry);
    if Buffer.GetByte = 0 then Entry.LocationOwner := TObject(Buffer.GetUInt32 or $80000000)
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
  for I := 1 to 24 do StatusEffectSourceNames[I] := Buffer.ReadWideString;
  DiseaseImmunity := Buffer.GetByte;
  if LoadedSaveVersion < 49 then
  begin
    ProgramRewardStocks[prgKellerCall] := 0;
    for RewardIndex := prgLogicalNegation to High(ProgramRewardStocks) do ProgramRewardStocks[RewardIndex] := Buffer.GetInt32;
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
  if (Count < 0) or (Count > 10000) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    Journal := TJournalRecord.Create;
    JournalRecords.Add(Journal);
    Journal.LoadFromBuffer(Buffer);
  end;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > 10000) then raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    New(News);
    NewsEntries.Add(News);
    News.Id := Buffer.GetUInt32;
    News.Turn := Buffer.GetUInt32;
    News.NewsType := Buffer.GetByte;
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
      if Data <> nil then
      begin
        if Data.Achieved then
          if AwardedAchievementKeys.CountBlocks(WideString(AchievementDefinitionTable[AchievementIndex].Key)) <= 0 then
            AwardedAchievementKeys.AddChildBlock(WideString(AchievementDefinitionTable[AchievementIndex].Key));
        if not Data.Achieved then
          if AwardedAchievementKeys.CountBlocks(WideString(AchievementDefinitionTable[AchievementIndex].Key)) > 0 then
            AwardedAchievementKeys.DeleteChildBlock(WideString(AchievementDefinitionTable[AchievementIndex].Key));
        FreeAchievementData(Data);
      end;
    end;
  end;
  LastLoadedPlayerName := Name;
  RefreshPlayerQuestTargets;
end;
{ @end $5849C8 }

{ @routine $585694 TPlayer_ResolveLoadedReferences }
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
    if Cardinal(Entry.LocationOwner) and $80000000 <> 0 then
      Entry.LocationOwner := Galaxy.IdToPlanet(Cardinal(Entry.LocationOwner) and $7FFFFFFF)
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
  if RuinsSavedPlanet <> nil then RuinsSavedPlanet := TObject(Galaxy.IdToPlanet(Cardinal(RuinsSavedPlanet))) as TPlanet;
  if RuinsSavedDockedTo <> nil then RuinsSavedDockedTo := TObject(Galaxy.IdToShip(Cardinal(RuinsSavedDockedTo), True)) as TShip;
  if (LoadedSaveVersion < 146) and (CurrentPlanet = nil) and (DockedTo = nil) then
  begin
    Found := False;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := TItem(Inventory[I]);
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
      Item := TItem(Inventory[I]);
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
{ @end $585694 }

{ @routine $5859E8 TPlayer_SaveToBlock }
procedure TPlayer.SaveToBlock(Block: TBlockParEC);
var I: Byte;
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
{ @end $5859E8 }

{ @routine $5860F0 TPlayer_LoadFromBlock }
procedure TPlayer.LoadFromBlock(Block: TBlockParEC);
var I: Byte;
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
{ @end $5860F0 }

{ @routine $586710 TPlayer_InitializePlayerAtPlanet }
procedure TPlayer.InitializePlayerAtPlanet(Planet: TPlanet; InitialMoney, CharacterPreset: Integer);
begin
  inherited InitializeAtPlanet(Planet, InitialMoney);
  BaseNodes := RoundAndTruncateToTens(BaseNodes * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].ArcadeRewardScale);
  PreferredCareer := rcTrader;
  CareerStatus[rcTrader] := 0;
  CareerStatus[rcWarrior] := 0;
  CareerStatus[rcPirate] := 0;
  EminentProgress[rcTrader] := 0;
  EminentProgress[rcPirate] := 0;
  EminentProgress[rcWarrior] := 0;
  BaseSkills[psAccuracy] := 0;
  BaseSkills[psManeuverability] := 0;
  BaseSkills[psTechnical] := 0;
  BaseSkills[psTrading] := 0;
  BaseSkills[psCharisma] := 0;
  BaseSkills[psLeadership] := 0;
end;
{ @end $586710 }

{ @routine $5867F0 TPlayer_ApplyCharacterPreset }
procedure TPlayer.ApplyCharacterPreset(Planet: TPlanet; InitialMoney, CharacterPreset: Integer);
var
  I, Quantity: Integer;
  Kind: TItemType;
  Item: TObject;
  Entry: PStorageEntry;
begin
  for I := Inventory.Count - 1 downto 0 do
  begin
    Item := TObject(Inventory[I]);
    Inventory.Delete(I);
    Item.Free;
  end;
  for Kind := Low(PShipEquipmentCacheView(Self).Slots) to High(PShipEquipmentCacheView(Self).Slots) do
    PShipEquipmentCacheView(Self).Slots[Kind] := nil;
  for I := 1 to 5 do Weapons[I] := nil;
  WeaponCount := 0;
  case Ord(OwnerId) * 5 + CharacterPreset of
    1:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 20, [oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[1]), 3, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
    end;
    2:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.5, 0.9) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 1, [oiFeyan, oiGaal]);
      ChangePlanetRelations(nil, rcmIncrease, 40, [oiPeleng, oiHuman]);
      CreateAndEquipHull(NextRandomIntRange(240, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[2]), 3, OwnerId);
      CreateAndEquipWeapon(t_Weapon3, Round(WeaponInfos[t_Weapon3].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
    end;
    3:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.2, 1.4) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 70, [oiMaloc, oiPeleng, oiHuman, oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(290, 320, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(20, 80, RandomState);
    end;
    4:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.1) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 5, [oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon3, Round(WeaponInfos[t_Weapon3].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    5:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.9, 2.1) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 5, [oiPeleng, oiFeyan]);
      CreateAndEquipHull(NextRandomIntRange(210, 230, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[4]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 3, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    6:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 2.3, 2.5) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 25, [oiMaloc, oiFeyan]);
      CreateAndEquipHull(NextRandomIntRange(210, 230, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[4]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 3, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    7:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.4, 2.0) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 30, [oiMaloc, oiHuman, oiFeyan, oiGaal]);
      ChangePlanetRelations(nil, rcmCapAt, 60, [oiPeleng]);
      CreateAndEquipHull(NextRandomIntRange(230, 260, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    8:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.1) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 50, [oiPeleng, oiHuman, oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(280, 320, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[2]), 3, OwnerId).ConditionPercent := NextRandomIntRange(20, 80, RandomState);
    end;
    9:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.9, 2.0) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 30, [oiHuman, oiFeyan]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(7, 17, RandomState);
      (Entry.Item as TGoods).Init(t_Luxury, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[3].AveragePrice div 4);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    10:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.1) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, NextRandomIntRange(10, 35, RandomState), [oiHuman]);
      ChangePlanetRelations(nil, rcmCapAt, NextRandomIntRange(10, 35, RandomState), [oiFeyan]);
      ChangePlanetRelations(nil, rcmCapAt, NextRandomIntRange(10, 35, RandomState), [oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(t_Weapon4, Round(WeaponInfos[t_Weapon4].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId).ConditionPercent := NextRandomIntRange(60, 90, RandomState);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(4, 10, RandomState);
      (Entry.Item as TGoods).Init(t_Narcotics, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[7].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    11:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.3, 0.5) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 15, [oiPeleng]);
      CreateAndEquipHull(NextRandomIntRange(210, 230, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipDefGenerator(Round(DefGeneratorBaseSize * EquipmentSizeFactors[2]), 3, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[2]), 2, OwnerId);
    end;
    12:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.5, 2.0) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 90, [oiMaloc, oiPeleng]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId).ConditionPercent := NextRandomIntRange(20, 80, RandomState);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(100, 200, RandomState);
      (Entry.Item as TGoods).Init(t_Minerals, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[4].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    13:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.3, 1.5) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 25, [oiMaloc]);
      ChangePlanetRelations(nil, rcmIncrease, 30, [oiPeleng, oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(280, 310, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    14:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.1, 1.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 5, [oiPeleng, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(240, 260, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 3, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[4]), 2, OwnerId);
    end;
    15:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, NextRandomIntRange(10, 35, RandomState), [oiMaloc]);
      ChangePlanetRelations(nil, rcmCapAt, NextRandomIntRange(10, 35, RandomState), [oiFeyan]);
      ChangePlanetRelations(nil, rcmCapAt, NextRandomIntRange(10, 35, RandomState), [oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[4]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 3, OwnerId);
    end;
    16:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 70, [oiMaloc, oiPeleng, oiHuman, oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(250, 270, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 3, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon3, Round(WeaponInfos[t_Weapon3].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    17:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 70, [oiMaloc, oiPeleng]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon4, Round(WeaponInfos[t_Weapon4].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    18:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.8, 1.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 70, [oiPeleng, oiHuman, oiFeyan, oiGaal]);
      ChangePlanetRelations(nil, rcmCapAt, 25, [oiMaloc]);
      CreateAndEquipHull(NextRandomIntRange(290, 320, RandomState), 1, OwnerId, -1, False).HullPoints := NextRandomIntRange(50, 150, RandomState);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[1]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[4]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
    end;
    19:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 15, [oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(270, 290, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 2, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[2]), 3, OwnerId);
      CreateAndEquipWeapon(t_Weapon3, Round(WeaponInfos[t_Weapon3].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    20:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 5, [oiMaloc, oiHuman, oiGaal]);
      ChangePlanetRelations(nil, rcmCapAt, 90, [oiPeleng]);
      ChangePlanetRelations(nil, rcmCapAt, 60, [oiFeyan]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(14, 20, RandomState);
      (Entry.Item as TGoods).Init(t_Narcotics, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[7].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    21:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.2, 0.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 70, [oiMaloc, oiPeleng, oiHuman, oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(230, 250, RandomState), 2, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 3, OwnerId);
      CreateAndEquipWeapon(t_Weapon2, Round(WeaponInfos[t_Weapon2].AverageSize * EquipmentSizeFactors[3]), 2, OwnerId);
    end;
    22:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 1.2, 1.3) * InitialMoney));
      ChangePlanetRelations(nil, rcmRaiseTo, 60, [oiMaloc, oiPeleng, oiHuman, oiFeyan, oiGaal]);
      CreateAndEquipHull(NextRandomIntRange(220, 230, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[4]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
    end;
    23:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.8, 1.2) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 5, [oiMaloc]);
      CreateAndEquipHull(NextRandomIntRange(280, 310, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(15, 30, RandomState);
      (Entry.Item as TGoods).Init(t_Luxury, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[3].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    24:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.2) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 35, [oiMaloc, oiPeleng, oiHuman, oiFeyan]);
      CreateAndEquipHull(NextRandomIntRange(250, 260, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 1, OwnerId);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipScanner(Round(ScannerBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipRepairRobot(Round(RepairRobotBaseSize * EquipmentSizeFactors[3]), 2, OwnerId);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[3]), 1, OwnerId);
      New(Entry);
      GetPlayer.StorageEntries.Add(Entry);
      Entry.Item := TGoods.Create;
      Quantity := NextRandomIntRange(10, 20, RandomState);
      (Entry.Item as TGoods).Init(t_Alcohol, Quantity);
      Entry.Item.Cost := Quantity * (GoodsMarket[5].AveragePrice div 2);
      if GetPlayer.DockedTo <> nil then Entry.LocationOwner := GetPlayer.DockedTo
      else Entry.LocationOwner := GetPlayer.CurrentPlanet;
      Entry.SlotIndex := 0;
    end;
    25:
    begin
      SetMoney(RoundAndTruncateToTens(SeededRandomFloatRange(Galaxy.GenerationSeed, 0.9, 1.2) * InitialMoney));
      ChangePlanetRelations(nil, rcmCapAt, 15, [oiMaloc, oiPeleng, oiFeyan]);
      CreateAndEquipHull(NextRandomIntRange(280, 300, RandomState), 1, OwnerId, -1, False);
      CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[3]), 1, OwnerId);
      GetFuelTanks.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipEngine(Round(EngineBaseSize * EquipmentSizeFactors[1]), 2, OwnerId);
      GetEngine.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipRadar(Round(RadarBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetRadar.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipCargoHook(Round(CargoHookBaseSize * EquipmentSizeFactors[2]), 1, OwnerId);
      GetCargoHook.ConditionPercent := NextRandomIntRange(10, 50, RandomState);
      CreateAndEquipWeapon(t_Weapon1, Round(WeaponInfos[t_Weapon1].AverageSize * EquipmentSizeFactors[2]), 1, OwnerId).ConditionPercent := NextRandomIntRange(10, 50, RandomState);
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
  for I := 1 to 24 do StatusEffectSourceNames[I] := '';
end;
{ @end $5867F0 }

{ @routine $5898EC TPlayer_NextDay }
procedure TPlayer.NextDay;
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
            Binding := TScriptShip(ScriptShipBindings[I]);
            if Binding.Script <> nil then Binding.Script.RunShipState(Binding);
            Dec(I);
          end;
        end;
      end;
      Stage := 2;
      if (Galaxy.CurrentTurn mod (((Integer(Galaxy.GenerationSeed) + Galaxy.CurrentTurn) div 1000) mod 10 + 2) = 0) and
        (DiseaseImmunity > 0) then Dec(DiseaseImmunity);
      { Native O- code retains this unreachable lower clamp on the byte field. }
      if DiseaseImmunity < 0 then DiseaseImmunity := 0;
      if DiseaseImmunity > 100 then DiseaseImmunity := 100;
      if not InNormalSpace then AchievementStats.StarFuelCollected := 0;
      if MedicalPolicyTicks > 0 then
      begin
        Dec(MedicalPolicyTicks);
        LastMedicalPolicyTicks := MedicalPolicyTicks;
        if MedicalPolicyTicks = 0 then
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, PickLocalizedTextVariant('GalaxyNews.MedPolicy.End', Galaxy.CurrentTurn div 10), '');
      end;
      if PendingPirateLicenseCash > 0 then
      begin
        GainExperience(Round(PendingPirateLicenseCash * CareerStatus[rcPirate] * 0.001), 3);
        Inc(PirateLicenseCash, PendingPirateLicenseCash);
        PendingPirateLicenseCash := 0;
        if PirateLicenseCash > 100000000 then PirateLicenseCash := 100000000;
      end;
      if PirateLicenseTicks > 0 then
      begin
        Dec(PirateLicenseTicks);
        if PirateLicenseTicks = 0 then
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, PickLocalizedTextVariant('GalaxyNews.PirateLicense.End', Galaxy.CurrentTurn div 10), '')
        else if Galaxy.ShipTypeCounts[Ord(rstDominion)] <= 0 then
        begin
          Found := 0;
          for I := 0 to Galaxy.Stars.Count - 1 do
          begin
            Star := TStar(Galaxy.Stars[I]);
            for J := 0 to Star.Ships.Count - 1 do
              if TShip(Star.Ships[J]).TypeId = Byte(rstDominion) then
              begin
                Inc(Found);
                Break;
              end;
            if Found > 0 then Break;
          end;
          if Found = 0 then
          begin
            PirateLicenseTicks := 0;
            AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, PickLocalizedTextVariant('GalaxyNews.PirateLicense.DeadAllCB', Galaxy.CurrentTurn div 10), '');
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
      else if Money > 100000000 then SetMoney(100000000);
      Stage := 3;
      if InNormalSpace then
        for I := 0 to CurrentStar.Ships.Count - 1 do
        begin
          Ship := TShip(CurrentStar.Ships[I]);
          if Ship.InNormalSpace then Ship.DaysSincePlayerSeen := 0;
        end;
      Stage := 4;
      for I := 0 to Inventory.Count - 1 do
      begin
        Item := TEquipment(Inventory[I]);
        if (Item.ItemType = t_Engine) and (Item.EquippedFlag = 0) then
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
      if (CountActiveDiseases < 3) and
        (((CurrentPlanet <> nil) and not HasDiseaseFromCurrentPlanet) or
         ((DockedTo <> nil) and not HasDiseaseFromCurrentDockedShip) or InNormalSpace) then
      begin
        FirstDisease := 1;
        LastDisease := 12;
        I := NextRandomIntRange(FirstDisease, LastDisease, RandomState);
        for J := FirstDisease to LastDisease do
        begin
          IncrementWrapped(I, FirstDisease, LastDisease);
          with CaptainHealthDefinitions[I] do
          begin
            if (Galaxy.CurrentTurn < 300) or CaptainHealthDefinitions[I].Disabled then Continue;
            if (CurrentPlanet <> nil) and not (0 in CaptainHealthDefinitions[I].Locations) then Continue;
            if (DockedTo <> nil) and not (1 in CaptainHealthDefinitions[I].Locations) then Continue;
            if InNormalSpace and not (2 in CaptainHealthDefinitions[I].Locations) and not (3 in CaptainHealthDefinitions[I].Locations) then Continue;
            if InNormalSpace and (3 in CaptainHealthDefinitions[I].Locations) then
              if (EnemyShip = nil) or not EnemyShip.IsAttackingShip(Self) or (GetHullIntegrityPercent > 50) or
                ((I = 3) and (EnemyShip.OwnerId <> oiDominator)) then Continue;
            if (CurrentPlanet <> nil) and not (CurrentPlanet.OwnerId in CaptainHealthDefinitions[I].AllowedLocationOwners) then
              if (CurrentPlanet.OwnerId = oiUninhabited) or not (RaceToOwner(CurrentPlanet.RaceId) in CaptainHealthDefinitions[I].AllowedLocationOwners) then Continue;
            if (DockedTo <> nil) and not (RaceToOwner(DockedTo.PilotRace) in CaptainHealthDefinitions[I].AllowedLocationOwners) and
              not (DockedTo.OwnerId in CaptainHealthDefinitions[I].AllowedLocationOwners) then Continue;
            if (RaceToOwner(PilotRace) in AllowedOwners) and (GetRangerRatingBand in AllowedRatingBands) and
              (Rank in AllowedRanks) and (GetDominantCareer in AllowedCareers) and
              (CaptainHealth[I].Progress <= 0.0) and (CaptainHealth[I].ExpireTurn + 365 <= Galaxy.CurrentTurn) then
            begin
              if IsHealthEffectActive(4) then ResistanceFactor := 0.1
              else ResistanceFactor := 1.0;
              if IsHealthEffectActive(18) then ResistanceFactor := ResistanceFactor * 5.0;
              ResistanceFactor := (CountActiveArtefacts(t_ArtBio) + 1) * ResistanceFactor;
              if CurrentPlanet <> nil then LocationId := CurrentPlanet.Id
              else if DockedTo <> nil then LocationId := DockedTo.Id
              else LocationId := CurrentStar.Id;
              LocalSeed := Galaxy.GenerationSeed + Cardinal(I) + LocationId + Cardinal(Galaxy.CurrentTurn div 3);
              if NextRandomFloatRange(0.0, 1.0, LocalSeed) * RemapClamped(DiseaseImmunity, 0.0, 100.0, 50.0, 300.0) * ResistanceFactor <=
                InfectionChance * 2.0 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor then
              begin
                CaptainHealth[I].Progress := 0.1;
                if InNormalSpace and (3 in CaptainHealthDefinitions[I].Locations) then CaptainHealth[I].Progress := 99.9999;
                CaptainHealth[I].AppliedTurn := Galaxy.CurrentTurn;
                CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + I + Galaxy.CurrentTurn), 0.0, 1.0, 0.5, 3.0) * CaptainHealthDefinitions[I].Duration);
                if CurrentPlanet <> nil then StatusEffectSourceNames[I] := CurrentPlanet.GetFullName(' ')
                else if DockedTo <> nil then StatusEffectSourceNames[I] := DockedTo.GetName
                else StatusEffectSourceNames[I] := CurrentStar.Name;
              end;
            end;
          end;
        end;
      end;
      Stage := 7;
      for I := 1 to 12 do
        if CaptainHealth[I].Progress <> 0.0 then
        begin
          if CaptainHealth[I].Progress < 100.0 then
          begin
            if I in [1..3] then
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
              AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText2(Text, '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1), '<Name>', CaptainHealthDefinitions[I].Name), '');
              AchievementStats.CheckAllDiseasesAchievement;
              Inc(DiseaseContractionCount);
            end;
          end
          else if (CaptainHealth[I].ExpireTurn <= Galaxy.CurrentTurn) and (not (I in [1..3]) or not CurrentStar.RecordingTurnFilm) then
          begin
            CaptainHealth[I].Progress := 0.0;
            StatusEffectSourceNames[I] := '';
            Text := LocalizedColorText(WideString('Illness.Illness.' + IntToStr(I - 1) + '.End'));
            AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText2(Text, '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1), '<Name>', CaptainHealthDefinitions[I].Name), '');
          end;
        end;
      Stage := 8;
      for I := 13 to 24 do
        if (CaptainHealth[I].Progress = 100.0) and (CaptainHealth[I].ExpireTurn <= Galaxy.CurrentTurn) then
        begin
          Text := LocalizedColorText(WideString('Illness.Stimulant.' + IntToStr(I - 12 - 1) + '.End'));
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText1(Text, '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1)), '');
          CaptainHealth[I].Progress := 0.0;
        end;
      Stage := 9;
      for I := 1 to 1 do
        if (RadiationHealth[I].Progress <> 0.0) and (RadiationHealth[I].ExpireTurn <= Galaxy.CurrentTurn) then
        begin
          Text := LocalizedColorText(WideString('Illness.ExtraIllness.' + IntToStr(I) + '.End'));
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText1(Text, '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1)), '');
          RadiationHealth[I].Progress := 0.0;
        end;
      Stage := 10;
      StimulantExcess := CountActiveStimulants - GetPlayer.GetTotalStatBonus(bonStimCapacity);
      { The native one-pass loop retains its dormant footer after Break. }
      while StimulantExcess >= 2 do
      begin
        I := 6;
        if CaptainHealth[I].Progress <= 0.0 then
        begin
          LocalSeed := Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn);
          if Sqr(Max(0, StimulantExcess - CountActiveArtefacts(t_ArtBio))) * 0.4 > NextRandomFloatRange(0.0, 1000.0, LocalSeed) then
            if (RaceToOwner(PilotRace) in CaptainHealthDefinitions[I].AllowedOwners) and
              (GetRangerRatingBand in CaptainHealthDefinitions[I].AllowedRatingBands) and
              (Rank in CaptainHealthDefinitions[I].AllowedRanks) and
              (GetDominantCareer in CaptainHealthDefinitions[I].AllowedCareers) then
            begin
              CaptainHealth[I].Progress := 100.0;
              CaptainHealth[I].ExpireTurn := Galaxy.CurrentTurn + Round(RemapClamped(SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + I + Galaxy.CurrentTurn), 0.0, 1.0, 0.5, 3.0) * CaptainHealthDefinitions[I].Duration);
              Inc(CaptainHealth[I].ApplicationCount);
              Text := LocalizedColorText(WideString('Illness.Illness.' + IntToStr(I - 1) + '.Start'));
              AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText2(Text, '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1), '<Name>', CaptainHealthDefinitions[I].Name), '');
              Inc(DiseaseContractionCount);
              AchievementStats.CheckAllDiseasesAchievement;
            end;
        end;
        Break;
      end;
      Stage := 11;
      if IsHealthEffectActive(5) and (Galaxy.CurrentTurn > CaptainHealth[5].AppliedTurn + 15) and (Galaxy.CurrentTurn mod 14 = 0) then
      begin
        if SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + 1736605 + Galaxy.CurrentTurn) > 0.8 then
        begin
          TargetValue := NextRandomIntRange(Galaxy.ComputeScaledSmallMoney(oiHuman), Galaxy.ComputeScaledAverageMoney(oiHuman), RandomState);
          SetMoney(TargetValue + Money);
          SoundManager.PlaySound('Sound.Sell');
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText2(PickLocalizedTextVariant('GalaxyNews.IllNews.IllLuatan', Seed * Cardinal(Galaxy.CurrentTurn div 10)), '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1), '<Money>', WideString(IntToStr(TargetValue))), '');
        end
        else AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText1(PickLocalizedTextVariant('GalaxyNews.IllNews.IllLuatanNo', Seed * Cardinal(Galaxy.CurrentTurn div 10)), '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1)), '');
      end;
      Stage := 12;
      if IsHealthEffectActive(11) and InNormalSpace and HasCargoGoods and
        (SeededRandomUnitFloat(Integer(Galaxy.GenerationSeed) + 135432 + Galaxy.CurrentTurn) > 0.8) and (Galaxy.CurrentTurn mod 21 = 0) then
      begin
        TargetValue := NextRandomIntRange(Galaxy.ComputeScaledMiniMoney(oiHuman), Galaxy.ComputeScaledBigMoney(oiHuman), RandomState);
        JettisonCargoGoodsTowardTargetValue(TargetValue);
        SoundManager.PlaySound('Sound.Sell');
        AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, FormatText1(PickLocalizedTextVariant('GalaxyNews.IllNews.IllSeciyanka', Seed * Cardinal(Galaxy.CurrentTurn div 10)), '<color=255,240,100>', '<Date>', Galaxy.FormatTurnDate(-1)), '');
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
{ @end $5898EC }

{ @routine $58B538 TPlayer_ComputeDepositAccruedValue }
function TPlayer.ComputeDepositAccruedValue: Integer;
var
  Base, Exponent, LimitRatio: Extended;
begin
  Result := 0;
  if DepositAmount > 0 then
  begin
    Base := 0.01 * DepositInterestRate / 12 + 1;
    Exponent := DepositDayCount / 365 * 12;
    LimitRatio := 100000000 / DepositAmount;
    if Ln(Base) * Exponent > Ln(LimitRatio) then Result := 100000000
    else Result := Round(Power(Base, Exponent) * DepositAmount);
  end;
end;
{ @end $58B538 }

{ @routine $58B630 TPlayer_RechargeTransmitters }
procedure TPlayer.RechargeTransmitters;
var
  Item: TItem;
  Transmitter: TArtefactTransmitter;
  I: Integer;
begin
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Item := TItem(GetPlayer.Artefacts[I]);
    if Item.ItemType = t_ArtefactTransmitter then
    begin
      Transmitter := Item as TArtefactTransmitter;
      Inc(Transmitter.Power);
    end;
  end;
end;
{ @end $58B630 }

{ @routine $58B69C TPlayer_ApplyBioArtefactHealthEffects }
procedure TPlayer.ApplyBioArtefactHealthEffects;
var
  Selected, I, Count, J: Integer;
begin
  for J := 1 to CountActiveArtefacts(t_ArtBio) do
  begin
    if HasActiveDisease and (NextRandomIntRange(1, 100, RandomState) <= 20) then
    begin
      Selected := NextRandomIntRange(1, CountActiveDiseases, RandomState);
      Count := 0;
      for I := 1 to 12 do
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
      for I := 13 to 24 do
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
{ @end $58B69C }

{ @routine $58B80C TPlayer_MayTakeSubCrack }
function TPlayer.MayTakeSubCrack: Boolean;
begin
  Result := Galaxy.IsDominatorSeriesUnresolved(dsTerron) and (Galaxy.CurrentTurn > 2000) and
    ((Galaxy.CurrentTurn mod (Galaxy.CurrentTurn mod 11 + 20) = 0) or (Galaxy.CurrentTurn > 4000)) and
    not HasProgram(prgSabCrack);
end;
{ @end $58B80C }

{ @routine $58B890 TPlayer_GetSubCrackCost }
function TPlayer.GetSubCrackCost: Integer;
begin
  Result := Round(100000.0 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestMoneyFactor);
end;
{ @end $58B890 }

{ @routine $58B8D0 TPlayer_GetPirateServiceDiscount }
function TPlayer.GetPirateServiceDiscount: TPercent;
begin
  Result := Round(CareerStatus[rcPirate] / 1.3) + 1;
end;
{ @end $58B8D0 }

{ @routine $58B910 TPlayer_CountProgramRewardStocks }
function TPlayer.CountProgramRewardStocks: Integer;
var I: Byte;
begin
  Result := 0;
  for I := Low(ProgramRewardStocks) to High(ProgramRewardStocks) do Inc(Result, ProgramRewardStocks[I]);
end;
{ @end $58B910 }

{ @routine $58B944 TPlayer_TryAwardDominatorPrograms }
function TPlayer.TryAwardDominatorPrograms(Victim: TShip): Boolean;
var
  ProgramIndex: Byte;
  Count: Integer;
begin
  Inc(DestroyedDominatorHullMass, Victim.GetHull.Weight);
  if ((Victim as TKling).KlingType in [ktEquentor..ktSmersh, ktBertor]) and
    (DestroyedDominatorHullMass > Galaxy.ScaleIntByTechLevel(500, 3000) *
      GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor) and
    (Galaxy.CurrentTurn > 365 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor + LastDominatorProgramRewardTurn) then
  begin
    LastDominatorProgramRewardTurn := Galaxy.CurrentTurn;
    DestroyedDominatorHullMass := 0;
    ProgramIndex := SelectProgramReward;
    Count := GetProgramRewardCount(ProgramIndex);
    Inc(ProgramRewardStocks[ProgramIndex], Count);
    if Galaxy.CoalitionDefeatedTurn = 0 then
      AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn,
        FormatText2(PickLocalizedTextVariant('GalaxyNews.WB.NewProgramm', Seed * Cardinal(Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Count>', IntToStr(Count), '<Programm>', GetProgramName(ProgramIndex)), '');
    Result := True;
  end
  else Result := False;
end;
{ @end $58B944 }

{ @routine $58BBF8 TPlayer_FindProfitableTradeRoute }
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
      for Kind := 0 to 7 do
        if Kind in GoodsMask then
          if GoodsLegalOnPlanet[Kind, BuyPlanet.RaceId, BuyPlanet.Government] then
            if GoodsLegalOnPlanet[Kind, SellPlanet.RaceId, SellPlanet.Government] then
              if (BuyPlanet.RelationToShip(Self) >= 20) and (SellPlanet.RelationToShip(Self) >= 20) and
                (SeededRandomUnitFloat(Kind * Seed * BuyPlanet.GenerationSeed + SellPlanet.GenerationSeed) >= 0.2) then begin
                Score := ShopGoodsSellPrice(Kind, SellPlanet) / ShopGoodsPurchasePrice(Kind, BuyPlanet);
                if Score >= 1.11 then
                  if (ShopGoodsSellPrice(Kind, SellPlanet) - 5 >= ShopGoodsPurchasePrice(Kind, BuyPlanet)) and
                    (GoodsMarket[Kind].BaseStock div 3 <= BuyPlanet.Goods[Kind].Count) then begin
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
  end;
  if BestScore > 0 then begin
    PurchasePlanet := BestBuyPlanet;
    SalePlanet := BestSellPlanet;
    Good := BestGood;
    Result := True;
  end else Result := False;
end;
{ @end $58BBF8 }

{ @routine $58C2D4 TPlayer_HasDeployedSatellites }
function TPlayer.HasDeployedSatellites: Boolean;
var I: Integer; Satellite: TSatellite;
begin
  for I := 0 to Satellites.Count - 1 do
  begin
    Satellite := TSatellite(GetPlayer.Satellites[I]);
    if Satellite.TargetPlanet <> nil then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{ @end $58C2D4 }

{ @routine $58C334 TPlayer_HasSatelliteOnPlanet }
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
{ @end $58C334 }

{ @routine $58C398 TPlayer_GetStorageColumnHeaderText }
function TPlayer.GetStorageColumnHeaderText: WideString;
var Text: WideString;
begin
  Text := '<color=255,240,100>';
  Text := Text + '<td=' + IntToStr(StorageHeaderColumns[GiResourceVariant].Size) + '><align=right>' +
    LocalizedText('FormShip.StorageInfo.Size') + '</align>';
  Text := Text + '<td=' + IntToStr(StorageHeaderColumns[GiResourceVariant].Cost) + '><align=right>' +
    LocalizedText('FormShip.StorageInfo.Cost') + '</align>';
  Text := Text + '</color>';
  Result := Text;
end;
{ @end $58C398 }

{ @routine $58C5D0 TPlayer_GetStorageDividerText }
function TPlayer.GetStorageDividerText: WideString;
begin
  Result := WrapTextInColor(StringOfChar('-', StorageDividerLengths[GiResourceVariant]), '<color=127,127,127>');
end;
{ @end $58C5D0 }

{ @routine $58C678 TPlayer_BuildDeployedSatelliteSummary }
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
    Planet := TPlanet(Galaxy.Planets[I]);
    for J := 0 to Satellites.Count - 1 do
    begin
      Satellite := TSatellite(GetPlayer.Satellites[J]);
      if Satellite.TargetPlanet = Planet then
      begin
        if HeaderCount = 0 then
        begin
          TempText := FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
            '', '<Star>', (TObject(Satellite.TargetPlanet) as TPlanet).CurrentStar.Name);
          TempText := WrapTextInColor(TempText + '. ', '<color=255,240,100>') +
            WrapTextInColor((TObject(Satellite.TargetPlanet) as TPlanet).GetFullName(' ') + '.', '<color=255,240,100>');
          RemainingText := ' ' + LocalizedText('FormShip.StorageInfo.PlanetNO');
          if Planet.WaterTiles - Planet.WaterExplored > 0 then
            ReplaceTextToken(RemainingText, '<Water>', IntToStr(Planet.WaterTiles - Planet.WaterExplored), '<color=0,128,255>')
          else ReplaceTextToken(RemainingText, '<Water>', '-', '<color=127,127,127>');
          if Planet.LandTiles - Planet.LandExplored > 0 then
            ReplaceTextToken(RemainingText, '<Land>', IntToStr(Planet.LandTiles - Planet.LandExplored), '<color=0,255,0>')
          else ReplaceTextToken(RemainingText, '<Land>', '-', '<color=127,127,127>');
          if Planet.HillTiles - Planet.HillExplored > 0 then
            ReplaceTextToken(RemainingText, '<Hill>', IntToStr(Planet.HillTiles - Planet.HillExplored), '<color=254,217,7>')
          else ReplaceTextToken(RemainingText, '<Hill>', '-', '<color=127,127,127>');
          TempText := TempText + RemainingText;
          Text := Text + #13#10 + Divider + #13#10 + '<td=' + IntToStr(ProbeSummaryColumns[GiResourceVariant].Heading) +
            '><align=center>' + TempText + '</align>' + #13#10 + Divider + #13#10;
          Inc(HeaderCount);
          Inc(LineCount);
        end;
        SizeText := WrapTextInColor(IntToStr(Satellite.Weight), '<color=0,255,0>');
        TempText := '';
        if Satellite.WaterExplorationRate > 0 then
          TempText := TempText + WrapTextInColor(IntToStr(Satellite.WaterExplorationRate), '<color=0,128,255>')
        else TempText := TempText + WrapTextInColor('-', '<color=127,127,127>');
        TempText := TempText + '/';
        if Satellite.LandExplorationRate > 0 then
          TempText := TempText + WrapTextInColor(IntToStr(Satellite.LandExplorationRate), '<color=0,255,0>')
        else TempText := TempText + WrapTextInColor('-', '<color=127,127,127>');
        TempText := TempText + '/';
        if Satellite.HillExplorationRate > 0 then
          TempText := TempText + WrapTextInColor(IntToStr(Satellite.HillExplorationRate), '<color=254,217,7>')
        else TempText := TempText + WrapTextInColor('-', '<color=127,127,127>');
        ExplorationText := TempText;
        Condition := Trunc(Satellite.ConditionPercent);
        if Satellite.ConditionPercent > 0 then
          TempText := IntToStr(Condition) + '.' + IntToStr(Trunc(Satellite.ConditionPercent * 10) mod 10) + '%'
        else TempText := '0.0%';
        if Condition > 75 then TempText := WrapTextInColor(TempText, '<color=0,255,0>')
        else if Condition > 50 then TempText := WrapTextInColor(TempText, '<color=255,240,100>')
        else if Condition > 25 then TempText := WrapTextInColor(TempText, '<color=254,217,7>')
        else TempText := WrapTextInColor(TempText, '<color=255,0,0>');
        ConditionText := TempText;
        StatusText := '';
        ExplorationTurns := GetSatelliteExplorationTurns(Satellite);
        if ExplorationTurns = 0 then
          StatusText := ' ' + WrapTextInColor(LocalizedText('Items.Satellite.WorkEnd'), '<color=255,0,0>');
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
{ @end $58C678 }

{ @routine $58D2E4 TPlayer_GetSatelliteExplorationTurns }
function TPlayer.GetSatelliteExplorationTurns(Satellite: TSatellite): Integer;
var
  I, Water, Land, Hill: Integer;
  Probe: TSatellite;
  Planet: TPlanet;
begin
  Result := 0;
  if Satellite.TargetPlanet = nil then Exit;
  if Satellite.BrokenFlag <> 0 then Exit;
  Planet := TObject(Satellite.TargetPlanet) as TPlanet;
  Water := 0;
  Land := 0;
  Hill := 0;
  for I := 0 to GetPlayer.Satellites.Count - 1 do
  begin
    Probe := TSatellite(GetPlayer.Satellites[I]);
    if (Satellite.TargetPlanet = Probe.TargetPlanet) and (Probe.BrokenFlag = 0) then
    begin
      Water := Min(Planet.WaterTiles - Planet.WaterExplored, Water + Probe.WaterExplorationRate);
      Land := Min(Planet.LandTiles - Planet.LandExplored, Land + Probe.LandExplorationRate);
      Hill := Min(Planet.HillTiles - Planet.HillExplored, Hill + Probe.HillExplorationRate);
    end;
  end;
  if Water > 0 then Water := Min(999, Ceil((Planet.WaterTiles - Planet.WaterExplored) / Water));
  if Land > 0 then Land := Min(999, Ceil((Planet.LandTiles - Planet.LandExplored) / Land));
  if Hill > 0 then Hill := Min(999, Ceil((Planet.HillTiles - Planet.HillExplored) / Hill));
  if (Satellite.WaterExplorationRate > 0) and (Water > 0) then Result := Water;
  if (Satellite.LandExplorationRate > 0) and (Land > 0) then Result := Max(Result, Land);
  if (Satellite.HillExplorationRate > 0) and (Hill > 0) then Result := Max(Result, Hill);
end;
{ @end $58D2E4 }

{ @routine $58D5D8 TPlayer_CanAccessSurfaceLootItem }
function TPlayer.CanAccessSurfaceLootItem(Item: TItem): Boolean;
begin
  Result := True;
end;
{ @end $58D5D8 }

{ @routine $58D5F0 TPlayer_ReportIdleSatellites }
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
    Satellite := TSatellite(GetPlayer.Satellites[I]);
    if (Satellite.TargetPlanet <> nil) and ((TObject(Satellite.TargetPlanet) as TPlanet).CurrentStar = Star) then
    begin
      Remaining := GetSatelliteExplorationTurns(Satellite);
      if Remaining <= 0 then
      begin
        for J := 1 to 3 do
        begin
          if Planets[J] = Satellite.TargetPlanet then Break;
          if Planets[J] = nil then
          begin
            Planets[J] := TPlanet(Satellite.TargetPlanet);
            Break;
          end;
        end;
        Text := Text + #13#10 + Satellite.GetIdleInfoText;
        Found := True;
      end;
    end;
  end;
  if Found then
  with AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '') do
  begin
    if Planets[1] <> nil then Targets[0].PlanetId := Planets[1].Id;
    if Planets[2] <> nil then Targets[1].PlanetId := Planets[2].Id;
    if Planets[3] <> nil then Targets[2].PlanetId := Planets[3].Id;
  end;
end;
{ @end $58D5F0 }

{ @routine $58D794 TPlayer_BeginStorageTurn }
procedure TPlayer.BeginStorageTurn;
begin
end;
{ @end $58D794 }

{ @routine $58D7A0 TPlayer_CanAccessHoldGoods }
function TPlayer.CanAccessHoldGoods(Good: Byte): Boolean;
begin
  Result := True;
end;
{ @end $58D7A0 }

{ @routine $58D7B8 TPlayer_CanAccessStoredItem }
function TPlayer.CanAccessStoredItem(Item: TItem): Boolean;
begin
  Result := True;
end;
{ @end $58D7B8 }

{ @routine $58D7D0 TPlayer_CountStoredItemUnits }
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
      if (ItemType in [t_Food..t_Narcotics]) or
        (ItemType in [t_Protoplasm, t_UselessCountableItem]) then
      begin
        if Entry.Item.ItemType = ItemType then Inc(Result, Entry.Item.Weight);
      end
      else if Entry.Item.ItemType = ItemType then Inc(Result);
    end;
  end;
end;
{ @end $58D7D0 }

{ @routine $58D888 TPlayer_RepairDuplicateStorageSlots }
procedure TPlayer.RepairDuplicateStorageSlots(Location: TObject);
var I, J, Count: Integer; Entry, Other: PStorageEntry;
begin
  Count := StorageEntries.Count;
  for I := 0 to Count - 1 do begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) then
      for J := I + 1 to Count - 1 do begin
        Other := StorageEntries[J];
        if (Other.LocationOwner = Location) and CanAccessStoredItem(Other.Item) then
          if Entry.SlotIndex = Other.SlotIndex then Other.SlotIndex := FindNextStorageSlot(Location);
      end;
  end;
end;
{ @end $58D888 }

{ @routine $58D964 TPlayer_FindNextStorageSlot }
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
    if I >= Count then Break;
    Inc(Result);
  end;
end;
{ @end $58D964 }

{ @routine $58D9EC TPlayer_GetStorageSlotExtent }
function TPlayer.GetStorageSlotExtent(Location: TObject): Integer;
var I: Integer; Entry: PStorageEntry;
begin
  Result := 0;
  for I := 0 to StorageEntries.Count - 1 do begin
    Entry := TList(Integer(StorageEntries) + 0)[I];
    if (Entry.LocationOwner = Location) and CanAccessStoredItem(Entry.Item) then Result := Max(Result, Entry.SlotIndex + 1);
  end;
end;
{ @end $58D9EC }

{ @routine $58DA7C TPlayer_FindStorageIndexByLocationAndSlot }
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
{ @end $58DA7C }

{ @routine $58DB00 TPlayer_FindStorageGoodsByLocationAndType }
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
{ @end $58DB00 }

{ @routine $58DB78 TPlayer_FindMergeableStorageItemByLocation }
function TPlayer.FindMergeableStorageItemByLocation(Location: TObject; Item: TCountableItem): Integer;
var
  I: Integer;
  Entry: PStorageEntry;
begin
  for I := 0 to StorageEntries.Count - 1 do
  begin
    Entry := StorageEntries[I];
    if (Entry.LocationOwner = Location) and Item.CanMerge(Entry.Item) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;
{ @end $58DB78 }

{ @routine $58DBF4 TPlayer_ShiftStorageSlotsAtOrAfter }
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
{ @end $58DBF4 }

{ @routine $58DC6C TPlayer_CloseVacantStorageSlot }
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
{ @end $58DC6C }

{ @routine $58DCF8 TPlayer_HasAccessibleStorageAt }
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
{ @end $58DCF8 }

{ @routine $58DD84 TPlayer_CountPartnersInNormalSpace }
function TPlayer.CountPartnersInNormalSpace: Byte;
var I: Integer; Ship: TShip;
begin
  Result := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do begin
    Ship := CurrentStar.Ships[I];
    if (Ship.PartnerShip = Self) and Ship.InNormalSpace then Inc(Result);
  end;
end;
{ @end $58DD84 }

{ @routine $58DDF0 TPlayer_GetShipRatingComparison }
function TPlayer.GetShipRatingComparison(Ship: TShip): Byte;
var Ranger: TRanger;
begin
  Result := 0;
  if Ship.TypeId = stRanger then begin
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
end;
{ @end $58DDF0 }

{ @routine $58DF4C TPlayer_GetShipRankComparison }
function TPlayer.GetShipRankComparison(Ship: TShip): Byte;
var Normal: TNormalShip;
begin
  Result := 0;
  if Ship is TNormalShip then begin
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
end;
{ @end $58DF4C }

{ @routine $58E064 TPlayer_GetShipPirateRankComparison }
function TPlayer.GetShipPirateRankComparison(Ship: TShip): Byte;
var Normal: TNormalShip;
begin
  Result := 0;
  if Ship is TNormalShip then begin
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
end;
{ @end $58E064 }

{ @routine $58E17C TPlayer_GetShipStrengthComparison }
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
{ @end $58E17C }

{ @routine $58E298 TPlayer_BuildTranclucatorStorageSummary }
function TPlayer.BuildTranclucatorStorageSummary(var LineCount: Integer): WideString;
var
  I, J, HeaderCount: Integer;
  Ship: TShip;
  Text, Heading, Divider: WideString;
  Star: TStar;
begin
  Divider := GetStorageDividerText;
  Text := '';
  LineCount := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    HeaderCount := 0;
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if Ship.TypeId = stTranclucator then
        if ((Ship as TTranclucator).OwnerShip = GetPlayer) and not Ship.IsHullDestroyed then
        begin
          if HeaderCount = 0 then
          begin
            Heading := WrapTextInColor(FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
              '', '<Star>', Star.Name), '<color=255,240,100>');
            Text := Text + #13#10 + Divider + #13#10 + '<td=' + IntToStr(TranclucatorSummaryWidths[GiResourceVariant]) +
              '><align=center>' + Heading + '</align>' + #13#10 + Divider + #13#10;
            Inc(HeaderCount);
            Inc(LineCount);
          end;
          Text := Text + '- ' + Ship.GetName + #13#10;
          Inc(LineCount);
        end;
    end;
  end;
  Result := Text;
end;
{ @end $58E298 }

{ @routine $58E5A8 TPlayer_CompareStorageEntries }
function TPlayer.CompareStorageEntries(Left, Right: PStorageEntry): Integer;
var LeftStarId, RightStarId: Cardinal; LeftPriority, RightPriority: Integer;
begin
  if Left.LocationOwner is TPlanet then LeftStarId := (Left.LocationOwner as TPlanet).CurrentStar.Id
  else LeftStarId := (Left.LocationOwner as TShip).CurrentStar.Id;
  if Right.LocationOwner is TPlanet then RightStarId := (Right.LocationOwner as TPlanet).CurrentStar.Id
  else RightStarId := (Right.LocationOwner as TShip).CurrentStar.Id;
  if LeftStarId < RightStarId then begin Result := -1; Exit end;
  if LeftStarId > RightStarId then begin Result := 1; Exit end;
  if (Left.LocationOwner is TPlanet) and (Right.LocationOwner is TShip) then begin Result := -1; Exit end;
  if (Left.LocationOwner is TShip) and (Right.LocationOwner is TPlanet) then begin Result := 1; Exit end;
  if Left.LocationOwner is TPlanet then
  begin
    if Cardinal((Left.LocationOwner as TPlanet).Id) < Cardinal((Right.LocationOwner as TPlanet).Id) then begin Result := -1; Exit end;
    if Cardinal((Left.LocationOwner as TPlanet).Id) > Cardinal((Right.LocationOwner as TPlanet).Id) then begin Result := 1; Exit end;
  end
  else
  begin
    if Cardinal((Left.LocationOwner as TShip).Id) < Cardinal((Right.LocationOwner as TShip).Id) then begin Result := -1; Exit end;
    if Cardinal((Left.LocationOwner as TShip).Id) > Cardinal((Right.LocationOwner as TShip).Id) then begin Result := 1; Exit end;
  end;
  if Integer(Left.Item.ItemType) < Integer(Right.Item.ItemType) then begin Result := -1; Exit end;
  if Integer(Left.Item.ItemType) > Integer(Right.Item.ItemType) then begin Result := 1; Exit end;
  if (Left.Item.ItemType = t_MicroModule) and (Right.Item.ItemType = t_MicroModule) then
  begin
    LeftPriority := GetMicroModulePriorityColorTier((Left.Item as TMicroModule).MicroModuleIndex - 1);
    RightPriority := GetMicroModulePriorityColorTier((Right.Item as TMicroModule).MicroModuleIndex - 1);
    if LeftPriority > RightPriority then begin Result := -1; Exit end;
    if LeftPriority < RightPriority then begin Result := 1; Exit end;
    if (Left.Item as TMicroModule).MicroModuleIndex < (Right.Item as TMicroModule).MicroModuleIndex then begin Result := -1; Exit end;
    if (Left.Item as TMicroModule).MicroModuleIndex > (Right.Item as TMicroModule).MicroModuleIndex then begin Result := 1; Exit end;
  end;
  if Left.Item.Weight < Right.Item.Weight then begin Result := -1; Exit end;
  if Left.Item.Weight > Right.Item.Weight then begin Result := 1; Exit end;
  if Left.Item.Cost < Right.Item.Cost then begin Result := -1; Exit end;
  if Left.Item.Cost > Right.Item.Cost then begin Result := 1; Exit end;
  Result := 0;
end;
{ @end $58E5A8 }

{ @routine $58E97C TPlayer_SortStorageEntries }
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
{ @end $58E97C }

{ @routine $58EA64 TPlayer_RefreshStorageBubbles }
procedure TPlayer.RefreshStorageBubbles;
begin
  BuildStorageBubbles;
end;
{ @end $58EA64 }

{ @routine $58EA78 TPlayer_BuildStorageBubbles }
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
      Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main'), '<color=0,255,0>') + #13#10;
      Text := Text + BuildDeployedSatelliteSummary(AddedLines);
      Text := Text + Heading;
      AddOrUpdatePlayerBubble(9, Galaxy.CurrentTurn, Text, 'sys_storage1');
    end
    else RemovePlayerBubblePages('sys_storage', 0);
  end
  else
  begin
    PreviousLocation := nil;
    LineCount := 0;
    Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') +
      'onepage' + GetStorageColumnHeaderText, '<color=0,255,0>') + #13#10;
    for I := 0 to StorageEntries.Count - 1 do
    begin
      Entry := StorageEntries[I];
      if (PreviousLocation <> Entry.LocationOwner) or (LineCount > 40) then
      begin
        if LineCount > 40 then
        begin
          if Page = 1 then
            ReplaceTextToken(Text, 'onepage', ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), '<color=255,0,255>') + ')', '');
          AddOrUpdatePlayerBubble(9, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
          Inc(Page);
          Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') + ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), '<color=255,0,255>') + ')',
          '<color=0,255,0>') + GetStorageColumnHeaderText + #13#10;
          LineCount := 0;
        end;
        if Entry.LocationOwner is TPlanet then
        begin
          Heading := FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
            '', '<Star>', (Entry.LocationOwner as TPlanet).CurrentStar.Name);
          Heading := WrapTextInColor(Heading + '. ', '<color=255,240,100>') +
            WrapTextInColor((Entry.LocationOwner as TPlanet).GetFullName(' ') + '.', '<color=255,240,100>');
          Text := Text + Divider + #13#10 + '<td=' + IntToStr(StorageItemColumns[GiResourceVariant].Heading) +
            '><align=center>' + Heading + '</align>' + #13#10 + Divider + #13#10;
          Inc(LineCount, 3);
        end
        else if Entry.LocationOwner is TShip then
        begin
          Heading := FormatText1(LocalizedText('FormShip.StorageInfo.Star'),
            '', '<Star>', (Entry.LocationOwner as TShip).CurrentStar.Name);
          Heading := WrapTextInColor(Heading + '. ', '<color=255,240,100>') +
            WrapTextInColor((Entry.LocationOwner as TShip).GetFullName(' ') + '.', '<color=255,240,100>');
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
        WrapTextInColor(IntToStr(Entry.Item.Weight), '<color=0,255,0>') + '</align>';
      Text := Text + '<td=' + IntToStr(StorageItemColumns[GiResourceVariant].Cost) + '><align=right>' +
        WrapTextInColor(IntToStr(Entry.Item.Cost), '<color=0,255,255>') + '</align>';
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
              WrapTextInColor(IntToStr(Page), '<color=255,0,255>') + ')', '');
        AddOrUpdatePlayerBubble(9, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
        Inc(Page);
        Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') + ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), '<color=255,0,255>') + ')',
          '<color=0,255,0>') + #13#10;
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
              WrapTextInColor(IntToStr(Page), '<color=255,0,255>') + ')', '');
        AddOrUpdatePlayerBubble(9, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
        Inc(Page);
        Text := WrapTextInColor(LocalizedText('FormShip.StorageInfo.Main') + ' (' + LocalizedText('FormShip.StorageInfo.Page') + ' ' +
              WrapTextInColor(IntToStr(Page), '<color=255,0,255>') + ')',
          '<color=0,255,0>') + #13#10;
      end;
      Text := Text + Heading;
    end;
    if Page = 1 then ReplaceTextToken(Text, 'onepage', '', '');
    AddOrUpdatePlayerBubble(9, Galaxy.CurrentTurn, Text, 'sys_storage' + IntToStr(Page));
  end;
  RemovePlayerBubblePages('sys_storage', Page + 1);
  RemovePlayerBubbleByKey('sys_storage');
end;
{ @end $58EA78 }

{ @routine $58FA60 TPlayer_SelectPlanetBattleMap }
function TPlayer.SelectPlanetBattleMap: Integer;
var I, MapIndex, Count: Integer; Candidates: array of Integer;
begin
  Result := -1;
  if IsInstallFeatureEnabled('Robot') then
    if GetPlayer.IsOnPlanet and ((Galaxy.BlazerSeriesResolvedTurn <= 0) or (Galaxy.KellerSeriesResolvedTurn <= 0) or (Galaxy.TerronSeriesResolvedTurn <= 0)) then
      if LastPlanetBattleTurn <= Galaxy.CurrentTurn - RemapClamped(High(PlanetBattleHistory), 0, High(RobotMapDefinitions), 130, 360) then begin
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
            if not (((RobotMapDefinitions[I].MinWins <= MapIndex) or (RobotMapDefinitions[I].MinWins = 0)) and
              ((RobotMapDefinitions[I].MaxWins >= MapIndex) or (RobotMapDefinitions[I].MaxWins = 0))) then Continue;
            if RobotMapDefinitions[I].AfterLiberation then begin
              if not ((Galaxy.CurrentTurn - GetPlayer.CurrentStar.LastLiberationRewardsTurn <= 40) and
                (GetPlayer.CurrentStar.LastLiberationRewardsTurn <= GetPlayer.CurrentStar.LastDominatorPresenceTurn)) then Continue;
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
{ @end $58FA60 }

{ @routine $58FFB4 TPlayer_SaveEquipmentConfiguration }
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
      if (Slot >= 0) and (Slot <= 4) then EquipmentIds[Slot] := Weapon.Id;
    end;
    NextSlot := 5;
    for I := 1 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if not (Item is TWeapon) and (Item.EquippedFlag <> 0) and (ItemTypeToSlotKind(Item.ItemType) <> sskUnsupported) then
      begin
        EquipmentIds[NextSlot] := Item.Id;
        Inc(NextSlot);
        if NextSlot > 11 then Break;
      end;
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      if Artefact.EquippedFlag = 0 then Continue;
      Slot := Artefact.AssignedSlotData and EquipmentSlotIndexMask;
      if (Slot >= 0) and (DefaultHullSlotCounts[sskArtefact] > Slot) then ArtefactIds[Slot] := Artefact.Id;
    end;
  end;
end;
{ @end $58FFB4 }

{ @routine $590714 TPlayer_ApplyEquipmentConfiguration }
procedure TPlayer.ApplyEquipmentConfiguration(Index: Integer);
  // @nested $590150 IsEmpty
  function IsEmpty: Boolean; // @addr $590150 @ida "bool __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
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
  // @nested $5901BC SupportsItem
  function SupportsItem(Item: TItem): Boolean; // @addr $5901BC @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
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
  // @nested $590280 FindSlot
  function FindSlot(Item: TItem): Integer; // @addr $590280 @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
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
  // @nested $590350 UnequipAll
  procedure UnequipAll; // @addr $590350 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  var
    I: Integer;
    Item: TEquipment;
    Artefact: TArtefact;
  begin
    for I := 0 to Inventory.Count - 1 do
    begin
      Item := Inventory[I];
      if Item.ItemType in [t_Hull..t_CustomWeapon] then Item.Unequip;
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      Artefact.Unequip;
    end;
    WeaponCount := 0;
    for I := 1 to 5 do Weapons[I] := nil;
  end;
  // @nested $590424 ReleaseStorageEntry
  procedure ReleaseStorageEntry(Entry: PStorageEntry); // @addr $590424 @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
  begin
    Entry.Item := nil;
    GetPlayer.StorageEntries.Delete(GetPlayer.StorageEntries.IndexOf(Entry));
    Dispose(Entry);
  end;
  // @nested $590468 TakeStoredItem
  procedure TakeStoredItem(Entry: PStorageEntry; Slot: Integer); // @addr $590468 @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
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
      Artefact.AssignedSlotData := (Artefact.AssignedSlotData and EquipmentSecondaryFireFlag) or Cardinal(Slot);
    end
    else if Item is TEquipment then
    begin
      Inventory.Add(Item);
      ReleaseStorageEntry(Entry);
      Equipment := Item as TEquipment;
      Equipment.Equip;
      if Item is TWeapon then Equipment.AssignedSlotData := (Equipment.AssignedSlotData and EquipmentSecondaryFireFlag) or Cardinal(Slot);
    end;
  end;
  // @nested $590558 EquipCarriedItems
  procedure EquipCarriedItems; // @addr $590558 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
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
        Equipment.AssignedSlotData := (Equipment.AssignedSlotData and EquipmentSecondaryFireFlag) or Cardinal(Slot);
      end;
    end;
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := Artefacts[I];
      Slot := FindSlot(Artefact);
      if Slot >= 0 then
      begin
        Artefact.Equip;
        Artefact.AssignedSlotData := (Artefact.AssignedSlotData and EquipmentSecondaryFireFlag) or Cardinal(Slot);
      end;
    end;
  end;
  // @nested $590644 EquipStoredItems
  procedure EquipStoredItems; // @addr $590644 @ida "void __cdecl $name(void *ParentFrame);" @note "Nested in ApplyEquipmentConfiguration; caller-popped static link, player -4 and preset index -8."
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
{ @end $590714 }

{ @routine $59074C TPlayer_HasEquipmentConfiguration }
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
{ @end $59074C }

{ @routine $5907B8 TPlayer_GetAvailableNodeCount }
function TPlayer.GetAvailableNodeCount(Carrier: TShip): Integer;
var I: Integer; Entry: PStorageEntry;
begin
  if Carrier <> nil then Result := Carrier.GetCarriedNodeCount else Result := GetCarriedNodeCount;
  if IsOnPlanet then
    for I := 0 to StorageEntries.Count - 1 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = CurrentPlanet) and (Entry.Item.ItemType = t_Protoplasm) then Inc(Result, Entry.Item.Weight);
    end;
  if IsDockedToShip then
    for I := 0 to StorageEntries.Count - 1 do begin
      Entry := StorageEntries[I];
      if (Entry.LocationOwner = DockedTo) and (Entry.Item.ItemType = t_Protoplasm) then Inc(Result, Entry.Item.Weight);
    end;
end;
{ @end $5907B8 }

{ @routine $5908BC TPlayer_ConsumeAvailableNodes }
procedure TPlayer.ConsumeAvailableNodes(Count: Integer; Carrier: TShip);
var I, Remaining: Integer; Item: TItem; Entry: PStorageEntry;
begin
  if Count <= 0 then Exit;
  if Carrier = nil then Carrier := Self;
  for I := Carrier.Inventory.Count - 1 downto 1 do begin
    Item := Carrier.Inventory[I];
    if Item.ItemType = t_Protoplasm then begin
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
      if (Entry.LocationOwner = CurrentPlanet) and (Entry.Item.ItemType = t_Protoplasm) then begin
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
      if (Entry.LocationOwner = DockedTo) and (Entry.Item.ItemType = t_Protoplasm) then begin
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
{ @end $5908BC }

{ @routine $590BF0 TPlayer_GetMaxPiratePartners }
function TPlayer.GetMaxPiratePartners: Integer;
begin
  Result := 0;
  if CareerStatus[rcPirate] > 60 then Inc(Result);
  if CareerStatus[rcPirate] > 75 then Inc(Result);
  if Galaxy.EminentCareerShips[rcPirate] = Self then Inc(Result);
  if PirateLicenseTicks > 0 then Inc(Result);
end;
{ @end $590BF0 }

{ @routine $590C44 TPlayer_GetMaxDominionShips }
function TPlayer.GetMaxDominionShips: Integer;
begin
  Result := 0;
  if CareerStatus[rcPirate] > 50 then Inc(Result);
  if CareerStatus[rcPirate] > 60 then Inc(Result);
  if CareerStatus[rcPirate] > 75 then Inc(Result);
  if Galaxy.EminentCareerShips[rcPirate] = Self then Inc(Result);
  if PirateLicenseTicks > 0 then Inc(Result);
end;
{ @end $590C44 }

{ @routine $590CA8 TPlayer_AddJournalRecord }
procedure TPlayer.AddJournalRecord(Text: WideString);
var Entry: TJournalRecord;
begin
  Entry := TJournalRecord.Create;
  JournalRecords.Add(Entry);
  Entry.Text := Text;
  Entry.DateTurn := Galaxy.CurrentTurn;
end;
{ @end $590CA8 }

{ @routine $590D2C TPlayer_DeleteJournalRecord }
procedure TPlayer.DeleteJournalRecord(Index: Integer);
begin
  if (Index >= 0) and (JournalRecords.Count >= Index) then
  begin
    TJournalRecord(JournalRecords[Index]).Free;
    JournalRecords.Delete(Index);
  end;
end;
{ @end $590D2C }

{ @routine $590D7C TPlayer_ClearJournal }
procedure TPlayer.ClearJournal;
begin
  while JournalRecords.Count > 0 do DeleteJournalRecord(JournalRecords.Count - 1);
end;
{ @end $590D7C }

{ @routine $590DAC TPlayer_ExportJournal }
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
{ @end $590DAC }

{ @routine $590FEC TPlayer_SortNewsEntries }
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
{ @end $590FEC }

{ @routine $5910D4 TPlayer_TrimNewsEntries }
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
{ @end $5910D4 }

{ @routine $591138 TPlayer_ExportNews }
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
{ @end $591138 }

{ @routine $591360 TPlayer_MergeGalaxyNews }
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
{ @end $591360 }

{ @routine $591460 TPlayer_RefreshNewsAtLocation }
procedure TPlayer.RefreshNewsAtLocation;
begin
  if (Galaxy.CurrentTurn > 300) and (IsOnPlanet or IsDockedToShip) then
    if (CurrentPlanet = nil) or ((CurrentPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) and
      (CurrentPlanet.GetRelationLevelToShip(Self) > rlBad)) then
    begin
      MergeGalaxyNews;
      SortNewsEntries;
      TrimNewsEntries(100);
    end;
end;
{ @end $591460 }

{ @routine $5914DC TPlayer_CalculateSpeed }
function TPlayer.CalculateSpeed: Integer;
begin
  Result := inherited CalculateSpeed;
end;
{ @end $5914DC }

{ @routine $5914F8 TPlayer_CreateRuinsProxy }
procedure TPlayer.CreateRuinsProxy;
begin
  RuinsProxy := TRuins.Create;
  (RuinsProxy as TRuins).Init(rstMilitaryBase, GetPlayer.CurrentStar, '');
  CurrentStar.Ships.Delete(CurrentStar.Ships.IndexOf(RuinsProxy));
end;
{ @end $5914F8 }

{ @routine $591568 TPlayer_EnterRuinsMode }
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
  RequestedScreenId := screenRuinsTalk;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $591568 }

{ @routine $59165C TPlayer_CloseRuinsModeScreen }
procedure TPlayer.CloseRuinsModeScreen;
begin
  RuinsStatusText := '';
  if (RuinsSavedPlanet = nil) and (RuinsSavedDockedTo = nil) then
  begin
    RequestedScreenId := screenStarMap;
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
    if RuinsSavedDockedTo <> nil then RequestedScreenId := screenRuinsTalk
    else if RuinsSavedPlanet.OwnerId <> oiUninhabited then RequestedScreenId := screenPlanet
    else RequestedScreenId := screenPlanetNO;
    ExitRuinsMode;
  end;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;
{ @end $59165C }

{ @routine $591738 TPlayer_ExitRuinsMode }
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
{ @end $591738 }

{ @routine $5917D0 TPlayer_RefreshCurrentStanding }
procedure TPlayer.RefreshCurrentStanding;
begin
  if IsInPrison then CurrentStanding := ssNeutral
  else if OwnerId <> oiPirate then
  begin
    if (CurrentSystemKills.Pirate > 0) or (CurrentStar.ControlFaction = sfCoalition) then CurrentStanding := ssCoalitionActive
    else CurrentStanding := ssCoalitionPassive;
  end
  else
  begin
    if (CurrentSystemKills.Normal > 0) or (CurrentStar.ControlFaction = sfPirates) then CurrentStanding := ssPirateActive
    else CurrentStanding := ssPiratePassive;
  end;
  if (CurrentStanding = ssCoalitionActive) and (MainPiratePlanet <> nil) and (MainPiratePlanet.CurrentStar = CurrentStar) then
    CurrentStanding := ssCoalitionMilitary;
end;
{ @end $5917D0 }

{ @routine $591890 TPlayer_CanSelectShipTarget }
function TPlayer.CanSelectShipTarget(Ship: TShip): Boolean;
type
  TOwnerMasks = array[TStarFaction] of TOwnerMask;

var
  Faction: TStarFaction;
begin
  Result := False;
  if (Ship.TargetingRestriction = 1) and (Ship.EnemyShip <> Self) and (EnemyShip <> Ship) then Exit;
  if (Ship is TKling) and (ChameleonLogic[Ord(TKling(Ship).DominatorSeries)] >= 2) and
    (Ship.EnemyShip <> Self) and (EnemyShip <> Ship) then Exit;
  if Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)] then
  begin
    for Faction := Low(TStarFaction) to High(TStarFaction) do
      if (OwnerId in TOwnerMasks(PlanetOwnerMasks)[Faction]) and
        (Ship.CurrentStanding in NonTargetableStationStandingMasks[Faction]) and
        ((Ship.ScriptShip = nil) or (Ship.OwnerId in TOwnerMasks(PlanetOwnerMasks)[Faction])) then Exit;
  end;
  Result := True;
end;
{ @end $591890 }

{ @routine $5919A8 TPlayer_CanScanShip }
function TPlayer.CanScanShip(Ship: TShip): Boolean;
begin
  Result := True;
  if Galaxy.UltraScanModEnabled = 0 then
  begin
    if Ship is TRuins then Result := False
    else if (Ship is TKling) and not Ship.HasIndependentScriptFaction then
    begin
      if (GetPlayer.GetScanner = nil) or (GetPlayer.GetScanner.OwnerId <> oiDominator) or
        (GetPlayer.GetScanner.DominatorSeries <> TKling(Ship).DominatorSeries) then Result := False;
    end;
    Result := GetPlayer.ScriptItemsAct($12, Ship, nil, Ord(Result)) <> 0;
  end;
end;
{ @end $5919A8 }

end.
