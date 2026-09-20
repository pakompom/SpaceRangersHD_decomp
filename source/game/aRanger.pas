unit aRanger;
// Unit bracket (inferred): .text 0x0074FE5C..0x007689FE; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Buf, aConst, aGalaxy, aGalaxyStruct, aItem, aNormalShip, aPlanet, aShip;

type
  TRelationChangeMode = (
    rcmCapAt = 0, rcmRaiseTo = 1, rcmIncrease = 2,
    rcmDecrease = 3, rcmDecreaseWithFloor20 = 4
  ); // @size 0x1

  TRangerCareerValues = array[0..2] of Byte;

  TRangerProgramMask = set of 0..15; // @size 2 Bits 0..11 select program IDs.

  TQuestTextKind = (qtkOffer = 0, qtkCompletion = 1, qtkProtectedShipLost = 2); // @size 0x4

  TQuest = packed record // @size 0x24
    QuestType: TQuestType; // @offset 0x00
    QuestNumber: Word; // @offset 0x02
    Planet: TPlanet; // @offset 0x04
    DeadlineTurn: Integer; // @offset 0x08
    RewardMoney: Integer; // @offset 0x0C
    ObjectiveTarget: TObject; // @offset 0x10  Can also reference an item, as well as a planet, ship or star.
    Successful: Boolean; // @offset 0x14
    Description: WideString; // @offset 0x18
    CompletionText: WideString; // @offset 0x1C
    SpecialCompletionText: WideString; // @offset 0x20  Protected ship lost after success.
  end;
  PQuest = ^TQuest;

  TPlayerOldQuest = packed record // @size 0x10
    Planet: TPlanet; // @offset 0x00
    Description: WideString; // @offset 0x04
    Successful: Boolean; // @offset 0x08
    Declined: Boolean; // @offset 0x09  Permanently declined offer.
    QuestType: TQuestType; // @offset 0x0A
    QuestNumber: Word; // @offset 0x0C
  end;
  PPlayerOldQuest = ^TPlayerOldQuest;
  PQuestHistoryList = ^TList;

  TRanger = class(TNormalShip) // @size 0x560
  public
    PlaceInRating: Word; // @offset 0x510  One-based experience ranking.
    ExcludedFromRating: Boolean; // @offset 0x512  Excludes strength/title eligibility; placement sorting still assigns a position.
    CareerStatus: array[0..2] of Byte; // @offset 0x513  TRangerCareer order.
    EminentProgress: array[0..2] of Byte; // @offset 0x516  TRangerCareer order.
    PendingCareerActivity: array[0..2] of Byte; // @offset 0x519  Trader, pirate, warrior.
    PreferredCareer: TRangerCareer; // @offset 0x51C  AI preference; may differ from GetDominantCareer.
    Aggression: Byte; // @offset 0x51D  Initialized in 0..100.
    Quests: TList; // @offset 0x520  Owned PQuest records.
    PrisonTermRemaining: Integer; // @offset 0x524
    LastDockedNonPlanetLocation: TShip; // @offset 0x528
    BaseNodes: Integer; // @offset 0x52C
    ProgramCounts: array[0..11] of Integer; // @offset 0x530

    destructor Destroy; override; // @addr 0x74FF84 @ida "void __usercall $name(TRanger *Self@<eax>, __int8 DestroyFlags@<dl>);" @note "Requires registered ranger/home-planet state. Removes quests and relation-column entries, adjusts the player index and refreshes galaxy ratings."
    procedure InitializeAtPlanet(Planet: TPlanet; InitialMoney: Integer); virtual; // @addr 0x7504D4 @slot 0xD0 @note "For a fresh inherited TNormalShip instance; creates loadout, career, quests and relation entries and registers it in the galaxy."
    procedure RegisterInGalaxyRelations; // @addr 0x750E4C @note "Appends Self and relation entries; requires an unregistered ranger with initialized lists."
    procedure SaveToBuffer(Buffer: TBufEC); override; // @addr 0x750FF0 @slot 0x00
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override; // @addr 0x75130C @slot 0x04 @note "Creates the quest list and loads IDs for later resolution; rejects quest counts above 10000."
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override; // @addr 0x75168C @slot 0x08 @note "Resolves quest targets by quest type and LastDockedNonPlanetLocation."
    procedure ClearObjectReferences; override; // @addr 0x751810 @slot 0x0C @note "Finalizes and removes quest records and clears LastDockedNonPlanetLocation after inherited reference cleanup."
    function ProcessPendingPlayerFollowTargeting: Boolean; // @addr 0x752A40 @note "True only for the pending auto-equip branch; normal follow/weapon assignment returns false."
    function GetHomeStar: TStar; override; // @addr 0x752BB4 @slot 0x34 @note "Requires HomePlanet."
    function GetGreetingShipCategory: Byte; override; // @addr 0x752DB0 @slot 0x30 @note "Returns the ranger category used by ship-greeting filters."
    function GetStrengthScaledPirateStatus: TPercent; override; // @addr 0x7531AC @slot 0x3C @note "Rounded pirate career status times StrengthInBestRanger, clamped to 0..100."
    function GetDesiredCargoFreeSpace: Integer; override; // @addr 0x753200 @slot 0x40
    function GetObjectInfoText(Instance: TObject): WideString; // @addr 0x7532A4 @ida "void __usercall $name(TRanger *Self@<eax>, TObject *Instance@<edx>, unsigned __int16 **Result@<ecx>);" @note "Dispatches by object class and radar distance; unsupported objects yield unknown object."
    function GetEstimatedMemoryUsage: Integer; override; // @addr 0x7534C0 @slot 0x44 @note "Native estimate omits quest/program allocations."
    procedure RefuelAtLocation; override; // @addr 0x75368C @slot 0x48 @note "Only buys a full refill when its positive cost is affordable."
    procedure SimulateUnseenProgression; // @addr 0x7536F8 @note "Can grant money, experience, equipment, awards and simulated kills; requires the unseen-day threshold, a player and unresolved Dominators."
    function OrderBestQueuedTradePlanet: Boolean; // @addr 0x75512C
    function SelectRandomPlanetFromQueue: TPlanet; // @addr 0x755468 @note "Borrowed result, nil for an empty queue."
    procedure BuildReachablePlanetQueue; override; // @addr 0x7554C0 @slot 0x64 @note "Replaces PlanetQueue; excludes LastDockedPlanet. A scripted system encountered in distance order ends the scan."
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override; // @addr 0x755610 @slot 0x68
    procedure SelectIdleFreeFlightDestination(UnusedMode: Byte); // @addr 0x755650 @note "The native UnusedMode comparison has no branch effect. Chooses travel toward combat opportunities only with no cargo, a gripper and a full hull."
    function TryOrderTravelToShipTypeLocation(ShipType: Byte): Boolean; // @addr 0x755AE4 @note "Native distant-system branch tests ships in the current system (0x755C12), rather than the candidate system."
    procedure SelectNearestReachableDestination; // @addr 0x755C8C @note "Can follow a partner's travel order; otherwise favors short travel to a suitable planet, station or peaceful system."
    procedure SelectAlternateReachableDestination; // @addr 0x75618C @note "Excludes the last docked planet/station and can favor leaving their system."
    procedure RepairBrokenEquipmentAtLocation; override; // @addr 0x756A0C @slot 0x60 @note "Repairs eligible installed items even without sufficient money; subtracts cost only when Money is strictly greater."
    function RelationToNonRanger(Ship: TShip): Byte; override; // @addr 0x756B84 @slot 0x80
    function RelationToRanger(Ranger: Pointer): Byte; override; // @addr 0x756DF0 @slot 0x74 @note "Two female human pilots receive 100; otherwise reads the stored galaxy-indexed relation."
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override; // @addr 0x756E54 @slot 0x78 @note "Applies the target's Charisma to positive changes, clamps to 0..100, and may break partnership or select an enemy."
    procedure ReactToAttack(Attacker: TShip); override; // @addr 0x756FE0 @slot 0x7C @note "Sets EnemyShip and penalizes relations with the attacking ranger or its controlling ranger."
    function RecomputeFearState: Boolean; override; // @addr 0x757188 @slot 0x84 @note "Updates InFear and can replace EnemyShip; special simulation mode clears fear."
    procedure TryOfferRansomToPursuer; // @addr 0x7575F8
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override; // @addr 0x757930 @slot 0x88

    procedure ApplyAttackReputationChanges(Victim: TShip; Severity: Double); // @addr 0x757A08 @ida "void __userpurge $name(TRanger *Self@<eax>, TShip *Victim@<edx>, double Severity@<^0>);" @note "Propagates reactions among nearby ships/planets; can update player achievements. Script-bound victims suppress the relation pass."
    procedure ApplyExtortionReputationPenalty(Victim: TShip); // @addr 0x757FE8 @note "Also adds pirate career activity and improves the main pirate planet's relation."
    procedure TryRecruitWingman; // @addr 0x758210
    procedure CheckForPartnershipBreakup; // @addr 0x7585D0
    function TrustsAttackRequester(Ship: TShip): Boolean; override; // @addr 0x758840 @slot 0x8C @note "Relation of at least 30."
    function EvaluateAllyRelationAndStrength(Ship: TShip): Boolean; override; // @addr 0x758864 @slot 0x90 @note "Tests relation plus a relative-strength score against 120; precise dialogue role remains unresolved."
    function ProcessPrisonAndHostileCheck: Boolean; // @addr 0x758D30 @note "Returns whether imprisonment blocks this turn; may imprison, release or update standing."
    procedure ChangeGlobalRelations(Scope: TObject; Mode: TRelationChangeMode; Amount: Byte; HullTypeMask: THullShipTypeMask; OwnerMask: TOwnerMask); // @addr 0x758E5C
    function GlobalRelationsShips(Scope: TObject; HullTypeMask: Word; OwnerMask: Byte): Byte; // @addr 0x759480 @note "Averages stored relations for matching ships; empty selection returns 50. A single ship uses its virtual RelationToRanger."
    function GlobalRelationsPlanets(Scope: TObject; OwnerMask: Byte): Byte; // @addr 0x759610 @note "Averages Coalition planets in matching stars/sectors; empty selection returns 50. A planet Scope does not narrow this native scan."
    procedure AssignWeaponTargetsInStar; override; // @addr 0x759760 @slot 0x20
    procedure SelectEnemyShipInStar; override; // @addr 0x759EAC @slot 0x6C @note "May attempt extortion and assign weapon targets; preserves a prior enemy when no replacement qualifies."
    procedure EngageEnemyShip; override; // @addr 0x75A3E0 @slot 0x70
    procedure ProcessCombatDialogue; override; // @addr 0x75A5DC @slot 0xA0
    procedure ReactToExtortionDemand(Ranger: Pointer); override; // @addr 0x75A6DC @slot 0xA4 @note "Can reduce ship/home-planet relations and adds pirate career activity to the requester."
    function BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean; override; // @addr 0x75A9E0 @slot 0xA8 @note "May execute payment and truce, or open the player's response dialogue; not a text-only query."
    function BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean; override; // @addr 0x75B280 @slot 0xAC @note "Successful requests jettison cargo and establish a truce."
    function BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean; override; // @addr 0x75B964 @slot 0xB0 @note "Acceptance transfers OfferedAmount from OtherShip to Self and establishes a truce."
    function BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean; override; // @addr 0x75BE84 @slot 0xB4 @note "May change relations/career activity even on refusal; acceptance issues a joint attack."
    function BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr 0x75C4E4 @slot 0xBC @note "Checks eligibility and formats refusal text; OtherShip must be a ranger. Success does not clear preexisting Response."
    function AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean; override; // @addr 0x75C8D0 @slot 0xB8 @note "Calls the eligibility method, then sets PartnerShip/duration and transfers payment. Requires a ranger requester."
    function GetProgramName(ProgramIndex: Byte): WideString; // @addr 0x75CAC0 @ida "void __usercall $name(TRanger *Self@<eax>, unsigned __int8 ProgramIndex@<dl>, unsigned __int16 **Result@<ecx>);"
    function GetProgramInfoText(ProgramIndex: Byte): WideString; // @addr 0x75CB64 @ida "void __usercall $name(TRanger *Self@<eax>, unsigned __int8 ProgramIndex@<dl>, unsigned __int16 **Result@<ecx>);"
    function CountProgramsInFilter(Filter: TRangerProgramMask): Integer; // @addr 0x75CCC4 @note "Sums owned quantities for bits 0..11; higher bits are ignored. Native signed 32-bit additions wrap on overflow."
    function SelectRandomProgramIdFromFilter(Filter: TRangerProgramMask): Byte; // @addr 0x75CD0C @note "Selects an allowed ID regardless of inventory counts; deterministic system/turn seed. Empty filter returns zero after 10000 attempts."
    function SelectProgramReward: Byte; // @addr 0x75CD7C @note "Favors program 5 until enough copies exist; otherwise selects among IDs 6..11."
    function GetProgramRewardCount(ProgramIndex: Byte): Integer; // @addr 0x75CDE8 @note "At least one; uses galaxy seed, turn and difficulty."
    function AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single; override; // @addr 0x75CECC @slot 0x50 @ida "float __userpurge $name@<st0>(TRanger *Self@<eax>, TItem *Item@<edx>, unsigned __int8 PriceMode@<cl>, float Effectiveness@<^0>);"
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override; // @addr 0x75D4EC @slot 0x54
    function EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single; override; // @addr 0x75E494 @slot 0x58 @ida "float __userpurge $name@<st0>(TRanger *Self@<eax>, TWeapon *Weapon@<edx>, bool IncludeAdditiveBonuses@<cl>, float BaseDamage@<^0>);"
    function AcceptPickupItem(Item: TItem): Boolean; override; // @addr 0x75EF40 @slot 0x94 @note "Always true."
    function AcceptPickupDistance(Item: TItem; Distance: Double): Boolean; override; // @addr 0x75EF58 @slot 0x98 @ida "bool __userpurge $name@<al>(TRanger *Self@<eax>, TItem *Item@<edx>, double Distance@<^0>);"
    procedure RefreshCurrentStanding; override; // @addr 0x75F040 @slot 0xC4
    function GrantPlanetQuestReward(Difficulty: Integer; var ExperienceAwarded: Integer): WideString; // @addr 0x762248 @ida "void __userpurge $name(TRanger *Self@<eax>, int Difficulty@<edx>, int *ExperienceAwarded@<ecx>, unsigned __int16 **Result@<^0>);" @note "Requires CurrentPlanet. Grants an award, program, item or module plus experience and relation effects. The hidden WideString result is cleared on entry; NPC result is empty."

    procedure NextDay; override; // @addr 0x751890 @slot 0x18
    procedure NextDayLogic; override; // @addr 0x751B00 @slot 0x1C @calls "0x75197F"
    function GetName: WideString; override; // @addr 0x752BD0 @slot 0x24 @ida "void __usercall $name(TRanger *Self@<eax>, unsigned __int16 **Result@<edx>);"
    function GetFullName(const Separator: WideString): WideString; override; // @addr 0x752BF0 @slot 0x28 @ida "void __usercall $name(TRanger *Self@<eax>, unsigned __int16 *Separator@<edx>, unsigned __int16 **Result@<ecx>);"

    procedure ChangePlanetRelations(Scope: TObject; Mode: TRelationChangeMode; Amount: Byte; OwnerMask: TOwnerMask); // @addr 0x7591B0 @ida "void __userpurge $name(TRanger *Self@<eax>, TObject *Scope@<edx>, TRelationChangeMode Mode@<cl>, unsigned __int8 Amount@<^4>, unsigned __int8 OwnerMask@<^0>);" @note "Scope filters by planet, star or sector; nil selects all. Only coalition planets are affected. OwnerMask uses owner IDs as bits."
    procedure ChangeShipRelations(Scope: TObject; Mode: TRelationChangeMode; Amount: Byte; HullTypeMask: THullShipTypeMask; OwnerMask: TOwnerMask); // @addr 0x758FD4 @note "Scope filters by ship, star or sector; nil selects all. Bulk changes skip scripted ships for which HasScriptControl is true. Masks use ShipToHullType categories and owner IDs, not TShip.TypeId."
    function CountWingmen: Integer; // @addr 0x753514 @note "Counts galaxy star-list ships whose PartnerShip is Self; includes docked ships."

    function GetDominantCareer: TRangerCareer; override; // @addr 0x752DC4 @slot 0x38 @note "Ties favor trader, then pirate."
    function GetCareerSimilarity(Values: TRangerCareerValues): TPercent; // @addr 0x752E60 @ida "unsigned __int8 __userpurge $name@<al>(TRanger *Self@<eax>, unsigned int Values@<^0>);" @note "Values occupies the low three bytes of one stack slot; result is the average of 100 minus each career-distance."
    function GetCharacterName: WideString; // @addr 0x752EE8 @ida "void __usercall $name(TRanger *Self@<eax>, unsigned __int16 **Result@<edx>);" @note "Selects the closest configured ShipCharacter profile; equal similarities retain the earlier profile."
    function HasProgram(ProgramIndex: Byte): Boolean; // @addr 0x75CC9C @note "Does not mask or validate ProgramIndex."
    function NeedsStrengthCatchup: Boolean; // @addr 0x7535A8
    procedure RefreshPlayerQuestTargets; // @addr 0x76891C @note "Does nothing for NPC rangers."
    function GenerateQuestOffer(var Quest: TQuest; var ResponseText: WideString): Boolean; // @addr 0x76332C @note "Requires CurrentPlanet."
    function HasQuestOfType(QuestType: TQuestType): Boolean; // @addr 0x7687D4
    procedure ProcessQuestTimersAndOutcomes; // @addr 0x75F134
    procedure TryTurnInQuests; // @addr 0x75FB24
    function TryTurnInAnyQuest(var ResponseText: WideString): Boolean; // @addr 0x75FC2C
    function TryTurnInQuest(Index: Integer; var ResponseText: WideString): Boolean; // @addr 0x7605DC
    procedure ArchiveQuest(Index: Integer); // @addr 0x75FB6C
    function BuildQuestText(Quest: TQuest; Kind: TQuestTextKind): WideString; // @addr 0x766980 @ida "void __userpurge $name(TRanger *Self@<eax>, TQuest *Quest@<edx>, TQuestTextKind Kind@<ecx>, unsigned __int16 **Result@<^0>);"
    procedure PublishQuestStatus(Quest: PQuest; Outcome: Integer); // @addr 0x76793C @note "Outcome: 0=active, positive=completed, negative=failed."
    procedure ProcessShipDestructionQuests(Ship: TShip); // @addr 0x768000
    function ShouldKeepShipForQuests(Ship: TShip): Boolean; // @addr 0x768834 @note "Player-only; pending history can also preserve unrelated ships."
    function CountFailedQuests(OwnerId: Byte; QuestTypes: TQuestTypes): Integer; // @addr 0x75F834 @ida "int __usercall $name@<eax>(TRanger *Self@<eax>, unsigned __int8 OwnerId@<dl>, TQuestTypes QuestTypes@<cl>);" @note "Uses player history."
    procedure CheckQuestFailureAward(Quest: PQuest; QuestTypes: TQuestTypes); // @addr 0x75FAB4 @ida "void __usercall $name(TRanger *Self@<eax>, TQuest *Quest@<edx>, TQuestTypes QuestTypes@<cl>);"
    function NeedsWealthCatchup: Boolean; // @addr 0x753618 @note "Either the absolute or relative career threshold can trigger catch-up."
    procedure AddTraderCareerActivity(Amount: Byte); // @addr 0x754418 @note "Saturates at 100."
    procedure AddPirateCareerActivity(Amount: Byte); // @addr 0x754458 @note "Saturates at 100."
    procedure AddWarriorCareerActivity(Amount: Byte); // @addr 0x754498 @note "Saturates at 100."
    procedure ClearPendingCareerActivity; // @addr 0x7544D8
    procedure ProcessCareerActivityAndEminentProgress; // @addr 0x7546E0 @note "Clears pending activity even when an NPC already holds a featured title. New titles require a non-excluded ranger in the upper half of the ranking and an undefeated Coalition."
    procedure HalveAllRangerEminentProgress(Career: TRangerCareer); // @addr 0x7550AC @note "Affects every galaxy ranger, including excluded entries."
    procedure SellCargoGoods; // @addr 0x756488
    procedure BuyProfitableGoods; // @addr 0x756530
    procedure ApplyIllegalGoodsTradeRelationsPenalty(TotalTradeValue: Integer); // @addr 0x756934
    function SelectBestTradePlanetFromQueue: TPlanet; // @addr 0x755184
    function FindBestQueuedSellPlanetProfitScore(Good: Byte; var BestPlanet: TPlanet; UnitCost: Double): Byte; // @addr 0x75681C @ida "unsigned __int8 __userpurge $name@<al>(TRanger *Self@<eax>, unsigned __int8 Good@<dl>, TPlanet **BestPlanet@<ecx>, double UnitCost@<^0>);" @note "Skips queue index 0. Leaves BestPlanet unchanged unless a candidate improves the score; UnitCost must be nonzero."
  end;

var
  PendingPlayerFollowTarget: TShip = nil; // @addr 0x87C040
  PlayerAutomaticControl: Boolean = False; // @addr 0x87C044  Auto-equips in the follow helper and uses NPC dialogue branches for the player.
  PlayerEquipmentBrokenThisTurn: Boolean = False; // @addr $87C048 Set by equipped-item breakage; ShouldContinuePlayerTravel checks it.
  RangerSkillBonusEvaluationWeights: array[0..2, 22..27] of Integer = (
    (70, 70, 100, 100, 50, 50),
    (100, 80, 80, 80, 70, 50),
    (80, 100, 100, 80, 50, 80)); // @addr $87C04C Career, then bonSkill1..bonSkill6.
  RangerSlotBonusEvaluationWeights: array[0..2, 13..20] of Integer = (
    (150, 80, 100, 500, 100, 75, 30, 30),
    (100, 150, 150, 500, 150, 150, 30, 50),
    (120, 120, 200, 500, 200, 100, 30, 30)); // @addr $87C094 Career, then bonSlotRadar..bonSlotForsage.
  PlayerOldQuests: TList; // @addr 0x889D00  Owned PPlayerOldQuest records.

implementation

uses TextQuest, EC_Cache, EC_CacheBuf, aTransport, aAsteroid, aMissile, aKling, aRuins, Windows, aWarrior, aTranclucator, aPirate, SysUtils, Math, EC_Str, Achievements, Globals, GlobalsV, aMyFunction, aPlayer, aGalaxyEvent, GR_Main;

{ @routine $74FF84 TRanger_Destroy }
destructor TRanger.Destroy;
var
  I, J, RangerIndex: Integer;
  Planet: TPlanet;
  Quest: PQuest;
  OldQuest: PPlayerOldQuest;
  Star: TStar;
  Ship: TShip;
begin
  Dec(HomePlanet.HomeRangerCount);
  if Quests <> nil then
    for I := Quests.Count - 1 downto 0 do
    begin
      Quest := PQuest(Quests[I]);
      Quests.Delete(I);
      Dispose(Quest);
    end;
  if GetPlayer = Self then
  begin
    for I := PlayerOldQuests.Count - 1 downto 0 do
    begin
      OldQuest := PPlayerOldQuest(PlayerOldQuests[I]);
      PlayerOldQuests.Delete(I);
      Dispose(OldQuest);
    end;
    PlayerOldQuests.Clear;
  end;
  RangerIndex := Galaxy.Rangers.IndexOf(Self);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if (Ship.TypeId in [stRanger..stPirate, Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Ship <> Self) then Ship.RangerRelations.Delete(RangerIndex);
    end;
  end;
  for I := 0 to Galaxy.Planets.Count - 1 do
  begin
    Planet := TPlanet(Galaxy.Planets[I]);
    Planet.RangerRelations.Delete(RangerIndex);
  end;
  if Galaxy.PlayerRangerIndex = RangerIndex then
  begin
    Galaxy.PlayerRangerIndex := -1;
    SetPlayer(nil, Galaxy);
  end
  else if Galaxy.PlayerRangerIndex > RangerIndex then Dec(Galaxy.PlayerRangerIndex);
  Galaxy.Rangers.Delete(RangerIndex);
  if Galaxy.WealthiestRanger = Self then Galaxy.RefreshRangerWealthStats;
  if Galaxy.StrongestRanger = Self then Galaxy.RefreshRangerStrengthStats;
  Galaxy.RefreshRangerRatingPlaces;
  inherited Destroy;
end;
{ @end $74FF84 }

{ @routine $7504D4 TRanger_InitializeAtPlanet }
procedure TRanger.InitializeAtPlanet(Planet: TPlanet; InitialMoney: Integer);
var
  I, J: Integer;
  OtherPlanet: TPlanet;
  ProgramIndex: Byte;
  Star: TStar;
  Ship: TShip;
  Ranger: TRanger;

  // @nested $75020C SelectName
  procedure SelectName(Config: TBlockParEC); // @addr 0x75020C @ida "void __usercall $name(TBlockParEC *Config@<eax>, void *ParentFrame@<^0>);" @note "Caller-popped static link; ranger at -4. Tries unused race/faction names and appends an ID suffix when exhausted."
  var
    Index, I, J, LastIndex, FirstIndex: Integer;
    Used: Boolean;
    Other: TRanger;
    Block: TBlockParEC;
  begin
    if (Config <> nil) and (Config.CountBlocks('Ranger') <> 0) then
    begin
      Block := Config.GetBlock('Ranger');
      if RaceToOwner(PilotRace) = OwnerId then Block := Block.GetBlock(OwnerToSys(OwnerId))
      else
      begin
        if Block.CountBlocks(OwnerToSys(OwnerId)) > 0 then Block := Block.GetBlock(OwnerToSys(OwnerId));
        if Block.CountBlocks(OwnerToSys(RaceToOwner(PilotRace))) > 0 then Block := Block.GetBlock(OwnerToSys(RaceToOwner(PilotRace)));
      end;
      FirstIndex := 0;
      LastIndex := Block.GetParamCount - 1;
      Index := NextRandomIntRange(FirstIndex, LastIndex, RandomState);
      for I := FirstIndex to LastIndex do
      begin
        Name := Block.GetParamValue(Index);
        Used := False;
        for J := 0 to Galaxy.Rangers.Count - 1 do
        begin
          Other := TRanger(Galaxy.Rangers[J]);
          if (Self <> Other) and (Other.Name = Name) then
          begin
            Used := True;
            Break;
          end;
        end;
        if not Used then Break;
        IncrementWrapped(Index, FirstIndex, LastIndex);
        if I = LastIndex then Name := Name + ' ' + '-' + IntToStr(Cardinal(Id) mod 100 + 1) + '-';
      end;
    end;
  end;

begin
  HomePlanet := Planet;
  CurrentPlanet := HomePlanet;
  CurrentStar := CurrentPlanet.CurrentStar;
  CurrentStar.Ships.Add(Self);
  TypeId := stRanger;
  PilotRace := HomePlanet.RaceId;
  OwnerId := RaceToOwner(PilotRace);
  SetMoney(InitialMoney);
  Aggression := SeededRandomIntRange(0, 100, Seed * Cardinal(Galaxy.CurrentTurn));
  LastDockedPlanet := nil;
  LastDockedNonPlanetLocation := nil;
  BaseNodes := 200;
  for ProgramIndex := Low(ProgramCounts) to High(ProgramCounts) do ProgramCounts[ProgramIndex] := 0;
  case NextRandomIntRange(0, 100, RandomState) of
    0..39: PreferredCareer := rcTrader;
    40..49: PreferredCareer := rcPirate;
    50..100: PreferredCareer := rcWarrior;
  end;
  case PreferredCareer of
    rcTrader:
    begin
      CareerStatus[Ord(rcTrader)] := 90;
      CareerStatus[Ord(rcPirate)] := 5;
      CareerStatus[Ord(rcWarrior)] := 5;
      EminentProgress[Ord(rcTrader)] := 90;
      EminentProgress[Ord(rcPirate)] := 0;
      EminentProgress[Ord(rcWarrior)] := 0;
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[1]);
      Inc(BaseSkills[2]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[2]);
      Inc(BaseSkills[3]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[3]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[4]);
    end;
    rcPirate:
    begin
      CareerStatus[Ord(rcTrader)] := 30;
      CareerStatus[Ord(rcPirate)] := 40;
      CareerStatus[Ord(rcWarrior)] := 30;
      EminentProgress[Ord(rcTrader)] := 0;
      EminentProgress[Ord(rcPirate)] := 70;
      EminentProgress[Ord(rcWarrior)] := 0;
      Inc(BaseSkills[0]);
      Inc(BaseSkills[0]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[1]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[1]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[3]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[3]);
      Inc(BaseSkills[4]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[4]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[5]);
    end;
    rcWarrior:
    begin
      CareerStatus[Ord(rcTrader)] := 30;
      CareerStatus[Ord(rcPirate)] := 30;
      CareerStatus[Ord(rcWarrior)] := 40;
      EminentProgress[Ord(rcTrader)] := 0;
      EminentProgress[Ord(rcPirate)] := 0;
      EminentProgress[Ord(rcWarrior)] := 90;
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[1]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[1]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[3]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[0]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[2]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[2]);
      if NextRandomUnitFloat(RandomState) < 0.5 then Inc(BaseSkills[5]);
      if NextRandomUnitFloat(RandomState) < 0.2 then Inc(BaseSkills[5]);
    end;
  end;
  ClearPendingCareerActivity;
  Name := '';
  SelectName(ModShipNameConfig);
  if Length(GetName) = 0 then SelectName(LanguageDataConfig.GetBlock('ShipName'));
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled and not (Self is TPlayer);
  CreateAndEquipHull(Round(HullBaseSize * EquipmentSizeFactors[5]), 1, RaceToOwner(PilotRace), SelectRandomHullSeries, HomePlanet.OwnerId = Byte(oiPirate));
  CreateAndEquipFuelTanks(Round(FuelTanksBaseSize * EquipmentSizeFactors[5]), 1, OwnerId);
  CreateAndEquipEngine(Round(EquipmentSizeFactors[NextRandomIntRange(1, 2, RandomState)] * EngineBaseSize), NextRandomIntRange(1, 2, RandomState), OwnerId);
  if GetSlotCountForItemType(Ord(t_CargoHook)) > 0 then CreateAndEquipCargoHook(CargoHookBaseSize, NextRandomIntRange(1, 2, RandomState), OwnerId);
  if GetSlotCount(sskWeapon) > WeaponCount then CreateAndEquipWeapon(Ord(t_Weapon1), WeaponInfos[Ord(t_Weapon1)].AverageSize, 1, OwnerId);
  if GetSlotCountForItemType(Ord(t_Radar)) > 0 then CreateAndEquipRadar(Round(EquipmentSizeFactors[NextRandomIntRange(2, 4, RandomState)] * RadarBaseSize), 1, OwnerId);
  RefreshDerivedStats(True);
  RefreshCurrentStanding;
  SmoothedSpeed := Speed;
  SmoothedEnemySpeed := Speed;
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  BuyEquipmentAtLocation(True);
  for I := 0 to Galaxy.Planets.Count - 1 do
  begin
    OtherPlanet := TPlanet(Galaxy.Planets[I]);
    OtherPlanet.RangerRelations.Add(Pointer(OwnerRelations[RaceToOwner(OtherPlanet.RaceId), RaceToOwner(PilotRace)]));
  end;
  Galaxy.Rangers.Add(Self);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if (Ship.TypeId in [stRanger..stPirate, Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Ship <> Self) then
        Ship.RangerRelations.Add(Pointer(OwnerRelations[RaceToOwner(Ship.PilotRace), RaceToOwner(PilotRace)]));
    end;
  end;
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(Galaxy.Rangers[I]);
    RangerRelations.Add(Pointer(OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ranger.PilotRace)]));
  end;
  Galaxy.RefreshRangerRatingPlaces;
  Quests := TList.Create;
  PrisonTermRemaining := 0;
end;
{ @end $7504D4 }

{ @routine $750E4C TRanger_RegisterInGalaxyRelations }
procedure TRanger.RegisterInGalaxyRelations;
var
  Planet: TPlanet;
  I, J: Integer;
  Ranger: TRanger;
  Star: TStar;
  Ship: TShip;
begin
  for I := 0 to Galaxy.Planets.Count - 1 do
  begin
    Planet := TPlanet(Galaxy.Planets[I]);
    Planet.RangerRelations.Add(Pointer(OwnerRelations[RaceToOwner(Planet.RaceId), OwnerId]));
  end;
  Galaxy.Rangers.Add(Self);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if (Ship.TypeId in [stRanger..stPirate, Ord(rstRangerCenter)..Ord(rstCustomStation)]) and (Ship <> Self) then
        Ship.RangerRelations.Add(Pointer(OwnerRelations[Ship.OwnerId, OwnerId]));
    end;
  end;
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(Galaxy.Rangers[I]);
    RangerRelations.Add(Pointer(OwnerRelations[OwnerId, Ranger.OwnerId]));
  end;
end;
{ @end $750E4C }

{ @routine $750FF0 TRanger_SaveToBuffer }
procedure TRanger.SaveToBuffer(Buffer: TBufEC);
var
  I, Count: Integer;
  Quest: PQuest;
  ProgramIndex: Byte;
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(CareerStatus[Ord(rcTrader)]));
  Buffer.AddAnsiChar(AnsiChar(CareerStatus[Ord(rcPirate)]));
  Buffer.AddAnsiChar(AnsiChar(CareerStatus[Ord(rcWarrior)]));
  Buffer.AddAnsiChar(AnsiChar(EminentProgress[Ord(rcTrader)]));
  Buffer.AddAnsiChar(AnsiChar(EminentProgress[Ord(rcPirate)]));
  Buffer.AddAnsiChar(AnsiChar(EminentProgress[Ord(rcWarrior)]));
  Buffer.AddAnsiChar(AnsiChar(PreferredCareer));
  Buffer.AddAnsiChar(AnsiChar(Aggression));
  Count := Quests.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Quest := PQuest(Quests[I]);
    Buffer.AddAnsiChar(AnsiChar(Quest.QuestType));
    Buffer.AddWideChar(WideChar(Quest.QuestNumber));
    Buffer.AddIntegerValue(Quest.DeadlineTurn);
    Buffer.AddIntegerValue(Quest.RewardMoney);
    if Quest.Planet = nil then Buffer.AddDWord(0) else Buffer.AddDWord(Quest.Planet.Id);
    if Quest.ObjectiveTarget is TPlanet then Buffer.AddDWord((Quest.ObjectiveTarget as TPlanet).Id)
    else if Quest.ObjectiveTarget is TShip then Buffer.AddDWord((Quest.ObjectiveTarget as TShip).Id)
    else if Quest.ObjectiveTarget is TArtefact then Buffer.AddDWord((Quest.ObjectiveTarget as TArtefact).Id)
    else if Quest.ObjectiveTarget is TStar then Buffer.AddDWord((Quest.ObjectiveTarget as TStar).Id)
    else Buffer.AddDWord(0);
    Buffer.AddBoolean(Quest.Successful);
    Buffer.AddWideStringZ(Quest.Description);
    Buffer.AddWideStringZ(Quest.CompletionText);
    Buffer.AddWideStringZ(Quest.SpecialCompletionText);
  end;
  Buffer.AddAnsiChar(AnsiChar(PendingCareerActivity[0]));
  Buffer.AddAnsiChar(AnsiChar(PendingCareerActivity[1]));
  Buffer.AddAnsiChar(AnsiChar(PendingCareerActivity[2]));
  Buffer.AddDWord(PrisonTermRemaining);
  if LastDockedNonPlanetLocation = nil then Buffer.AddDWord(0)
  else Buffer.AddDWord(LastDockedNonPlanetLocation.Id);
  Buffer.AddIntegerValue(BaseNodes);
  for ProgramIndex := Low(ProgramCounts) to High(ProgramCounts) do Buffer.AddIntegerValue(ProgramCounts[ProgramIndex]);
  Buffer.AddBoolean(ExcludedFromRating);
end;
{ @end $750FF0 }

{ @routine $75130C TRanger_LoadFromBuffer }
procedure TRanger.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, Count: Integer;
  Quest: PQuest;
  ProgramIndex: Byte;
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if (LoadedSaveVersion < 139) and (CreationTurn < 666) then CreationTurn := 667;
  CareerStatus[Ord(rcTrader)] := Buffer.GetByte;
  CareerStatus[Ord(rcPirate)] := Buffer.GetByte;
  CareerStatus[Ord(rcWarrior)] := Buffer.GetByte;
  EminentProgress[Ord(rcTrader)] := Buffer.GetByte;
  EminentProgress[Ord(rcPirate)] := Buffer.GetByte;
  EminentProgress[Ord(rcWarrior)] := Buffer.GetByte;
  PreferredCareer := TRangerCareer(Buffer.GetByte);
  Aggression := Buffer.GetByte;
  { Native loading uses the custom list; fresh initialization uses TList. }
  Quests := TObjectList.Create;
  Count := Buffer.GetWord;
  { The signed lower bound is retained even though GetWord cannot return it. }
  if (Count < 0) or (Count > 10000) then raise EAbort.Create('Err in FQuests load');
  for I := 0 to Count - 1 do
  begin
    New(Quest);
    Quests.Add(Quest);
    Quest.QuestType := TQuestType(Buffer.GetByte);
    Quest.QuestNumber := Buffer.GetWord;
    Quest.DeadlineTurn := Buffer.GetInt32;
    Quest.RewardMoney := Buffer.GetInt32;
    Quest.Planet := TPlanet(Buffer.GetUInt32);
    Quest.ObjectiveTarget := TObject(Buffer.GetUInt32);
    Quest.Successful := Buffer.GetBoolean;
    Quest.Description := Buffer.ReadWideString;
    Quest.CompletionText := Buffer.ReadWideString;
    Quest.SpecialCompletionText := Buffer.ReadWideString;
    if LoadedSaveVersion <= 141 then Buffer.GetUInt32;
  end;
  PendingCareerActivity[0] := Buffer.GetByte;
  PendingCareerActivity[1] := Buffer.GetByte;
  PendingCareerActivity[2] := Buffer.GetByte;
  if LoadedSaveVersion >= 60 then PrisonTermRemaining := Buffer.GetUInt32
  else PrisonTermRemaining := Buffer.GetByte;
  LastDockedNonPlanetLocation := TShip(Buffer.GetUInt32);
  BaseNodes := Buffer.GetInt32;
  if LoadedSaveVersion < 49 then
  begin
    ProgramCounts[prgKellerCall] := 0;
    for ProgramIndex := prgLogicalNegation to High(ProgramCounts) do ProgramCounts[ProgramIndex] := Buffer.GetInt32;
  end
  else
    for ProgramIndex := Low(ProgramCounts) to High(ProgramCounts) do ProgramCounts[ProgramIndex] := Buffer.GetInt32;
  if LoadedSaveVersion >= 110 then ExcludedFromRating := Buffer.GetBoolean;
end;
{ @end $75130C }

{ @routine $75168C TRanger_ResolveLoadedReferences }
procedure TRanger.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  I, Count: Integer;
  Quest: PQuest;
begin
  inherited ResolveLoadedReferences(Galaxy);
  Count := Quests.Count;
  for I := 0 to Count - 1 do
  begin
    Quest := PQuest(Quests[I]);
    Quest.Planet := TObject(Galaxy.IdToPlanet(Cardinal(Quest.Planet))) as TPlanet;
    case Quest.QuestType of
      qtSendLetter: Quest.ObjectiveTarget := TObject(Galaxy.IdToPlanet(Cardinal(Quest.ObjectiveTarget))) as TPlanet;
      qtKillShip: Quest.ObjectiveTarget := TObject(Galaxy.IdToShip(Cardinal(Quest.ObjectiveTarget), True)) as TShip;
      qtPlanetQuest: Quest.ObjectiveTarget := TObject(Galaxy.IdToPlanet(Cardinal(Quest.ObjectiveTarget))) as TPlanet;
      qtDefendSystem: Quest.ObjectiveTarget := TObject(Galaxy.IdToStar(Cardinal(Quest.ObjectiveTarget))) as TStar;
      qtDefendShip: Quest.ObjectiveTarget := TObject(Galaxy.IdToShip(Cardinal(Quest.ObjectiveTarget), True)) as TShip;
    end;
  end;
  LastDockedNonPlanetLocation := TObject(Galaxy.IdToShip(Cardinal(LastDockedNonPlanetLocation), False)) as TShip;
end;
{ @end $75168C }

{ @routine $751810 TRanger_ClearObjectReferences }
procedure TRanger.ClearObjectReferences;
var
  I: Integer;
  Quest: PQuest;
begin
  inherited ClearObjectReferences;
  for I := Quests.Count - 1 downto 0 do
  begin
    Quest := PQuest(Quests[I]);
    Quests.Delete(I);
    Dispose(Quest);
  end;
  Quests.Clear;
  LastDockedNonPlanetLocation := nil;
end;
{ @end $751810 }

{ @routine $751890 TRanger_NextDay }
procedure TRanger.NextDay;
begin
  inherited NextDay;
  try
    if IsFemaleHumanPilot then PreferredCareer := rcTrader;
    ProcessCareerActivityAndEminentProgress;
    ProcessQuestTimersAndOutcomes;
    if GetPlayer = Self then
    begin
      PlayerEquipmentBrokenThisTurn := False;
      if not ProcessPendingPlayerFollowTargeting then Exit;
    end;
    if (ScriptShip <> nil) and HasScriptControl then
    begin
      ScriptNextDay;
      if ScriptShip <> nil then
      begin
        if Cardinal(PrisonTermRemaining) > 0 then ProcessPrisonAndHostileCheck;
        Exit;
      end;
    end;
    NextDayLogic;
    if (ScriptShip <> nil) and not HasScriptControl then ScriptNextDay;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TRanger.NextDay ' + GetFullName(' '));
    end;
  end;
end;
{ @end $751890 }

{ @routine $751B00 TRanger_NextDayLogic }
procedure TRanger.NextDayLogic;
var
  Location: TPlanet;
  Stage: Integer;
begin
  Stage := 0;
  try
    if CurrentPlanet <> nil then
    begin
      Stage := 1;
      if CurrentPlanet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)] then
      begin
        Stage := 2;
        TryTurnInQuests;
        if ProcessPrisonAndHostileCheck then Exit;
        begin
          RefuelAtLocation;
          RepairBrokenEquipmentAtLocation;
          AutoEquipInventory;
          OptimizeInventory;
          BuildReachablePlanetQueue;
          SellCargoGoods;
          RefuelAtLocation;
          ReloadWeaponAmmo;
          if not RepairHullAtLocation then
          begin
            BuyEquipmentAtLocation(False);
            RestoreEssentialEquipment;
            if not ScanForCollectableItems and NeedsWealthCatchup and (CountWingmen = 0) and (PartnerShip = nil) then BuyProfitableGoods;
            if GetPlayer <> Self then SimulateUnseenProgression;
            TrainSkillsAutomatically;
            OrderTakeoff;
          end;
        end;
      end
      else OrderTakeoff;
      Exit;
    end;
    Stage := 3;
    if DockedTo <> nil then
    begin
      Stage := 4;
      if not (DockedTo.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) then
      begin
        if DockedTo.InNormalSpace then OrderTakeoff else OrderNone(False);
        Exit;
      end;
      SynchronizeDockedLocation;
      case DockedTo.TypeId of
        Ord(rstRangerCenter):
        begin
          DepositCarriedNodes;
          TrainSkillsAutomatically;
        end;
        Ord(rstMilitaryBase): if (Rank < 6) or ((GetPlayer <> nil) and (GetPlayer.Rank >= 7)) then TryPromoteRank;
      end;
      if GetPlayer <> Self then SimulateUnseenProgression;
      RepairBrokenEquipmentAtLocation;
      AutoEquipInventory;
      OptimizeInventory;
      BuildReachablePlanetQueue;
      SellCargoGoods;
      RefuelAtLocation;
      ReloadWeaponAmmo;
      if Galaxy.FindMilitaryBaseInTransit = DockedTo then Exit;
      if not RepairHullAtLocation then
      begin
        BuyEquipmentAtLocation(False);
        RestoreEssentialEquipment;
        RepairBrokenEquipmentAtLocation;
        if DockedTo.InNormalSpace then OrderTakeoff else OrderNone(False);
      end;
      Exit;
    end;
    Stage := 5;
    if not InNormalSpace then Exit;
    Stage := 7;
    if (GetPlayer <> Self) and ((Integer(Seed) + Galaxy.CurrentTurn) mod 53 = 0) then SimulateUnseenProgression;
    AutoApplyMicroModules;
    BuildReachablePlanetQueue;
    if RecomputeFearState then TryOfferRansomToPursuer;
    AssignWeaponTargetsInStar;
    CheckForPartnershipBreakup;
    TryRecruitWingman;
    if PartnerShip <> nil then
    begin
      if not InFear then
      begin
        if ((OrderTarget = PartnerShip) or (OrderTarget = PartnerShip.OrderTarget)) and not OrderAbsolute and
          ((OrderTarget = PartnerShip) or not (Order in [soNone, soMove])) then
        begin
          TryCollectBestFloatingItem(0);
          if TryMirrorPartnerTravelOrders then Exit;
        end;
      end
      else if (Order in [soLand, soJump]) and ((OrderTarget = PartnerShip.OrderTarget) or (EstimateOrderTravelTurns < 4)) then Exit;
    end;
    if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and (EnemyShip.CurrentPlanet <> nil) and
      (NextRandomUnitFloat(RandomState) < 0.2) then OrderNone(False);
    ProcessCombatDialogue;
    AfterburnerActive := False;
    if InFear then
    begin
      Stage := 8;
      if PartnerShip <> nil then
      begin
        if PartnerShip.CurrentStar = CurrentStar then SelectAlternateReachableDestination
        else if (PartnerShip.CurrentStar.ControlFaction = sfCoalition) and (PartnerShip.CurrentStar.Status.CustomFaction = '') then
        begin
          if (PartnerShip.Order = soJump) and (PartnerShip.OrderTarget is TStar) and
            (PartnerShip.OrderTarget <> CurrentStar) and (PartnerShip.OrderTarget <> PartnerShip.CurrentStar) and
            ((PartnerShip.OrderTarget as TStar).ControlFaction = sfCoalition) and
            ((PartnerShip.OrderTarget as TStar).Status.CustomFaction = '') then
          begin
            OrderJump(PartnerShip.OrderTarget as TStar, True);
            Exit;
          end;
          OrderJump(PartnerShip.CurrentStar, True);
          Exit;
        end
        else SelectAlternateReachableDestination;
      end
      else
      begin
        SelectAlternateReachableDestination;
        if GetCarriedNodeCount > 0 then TryOrderTravelToShipTypeLocation(6);
        if (BlazerShip <> nil) and (BlazerShip.CurrentStar = CurrentStar) and BlazerShip.InNormalSpace and (Aggression < 40) then NavigateToEscapePlanet(True);
        if (Order <> soLand) and (Order <> soJump) then EngageEnemyShip
        else
        begin
          if (EstimateOrderTravelTurns > 4) and (EnemyShip <> nil) and (EnemyShip.OrderTarget = Self) and
            (EnemyShip.TypeId in [stRanger, stPirate]) and (EnemyShip.EstimateOrderTravelTurns < 3) and
            (NextRandomUnitFloat(RandomState) < 0.2) and ((Integer(Seed) + Galaxy.CurrentTurn) mod 2 = 0) then
            if JettisonCargoGoodsTowardTargetValue(Max(200, Galaxy.ComputeScaledMiniMoney(OwnerId) div 2)) then NotifyFearCargoDrop(EnemyShip);
        end;
      end;
      if (Order = soLand) or (Order = soJump) then UpdateAfterburnerState;
    end
    else
    begin
      Stage := 9;
      if PartnerShip <> nil then
      begin
        if (PartnerShip.CurrentStar = CurrentStar) and (PartnerShip.Order in [soNone, soMove]) and not OrderAbsolute then TryCollectBestFloatingItem(2)
        else TryCollectBestFloatingItem(0);
        if (PartnerShip.CurrentStar = CurrentStar) and not OrderAbsolute then
        begin
          if (PartnerShip.EnemyShip <> nil) and
            ((PartnerShip.OrderTarget = PartnerShip.EnemyShip) or (PartnerShip.EnemyShip.OrderTarget = PartnerShip)) and
            (not IsFemaleHumanPilot or not PartnerShip.EnemyShip.IsFemaleHumanPilot) then
          begin
            EnemyShip := PartnerShip.EnemyShip;
            EngageEnemyShip;
          end
          else if (EnemyShip <> nil) and EnemyShip.InNormalSpace and (PartnerShip.OrderTarget is TShip) and
            (PartnerShip.GetRelationLevelToShip(PartnerShip.OrderTarget as TShip) = rlHostile) and
            (PartnerShip.GetRelationLevelToShip(EnemyShip) = rlHostile) then EngageEnemyShip;
        end;
        if (Order = soFollowShip) and (OrderTarget <> PartnerShip) and (GetRelationLevelToShip(OrderTarget as TShip) <> rlHostile) then OrderNone(False);
        if (Order = soNone) and HasCargoGoods and (GetDesiredCargoFreeSpace > CargoFreeSpace) then SelectNearestReachableDestination;
        if Order = soNone then
          if (GetHull.Weight - GetDesiredCargoFreeSpace < GetCarriedItemWeight) or
            ((GetHullIntegrityPercent < 70) and HasHullDamageOrBrokenEquippedItems) then SelectNearestReachableDestination;
        if (Order = soNone) and (HasInactiveDirectEquipment <> 0) and (GetDesiredCargoFreeSpace > CargoFreeSpace) then SelectNearestReachableDestination;
        if (Order = soNone) or (OrderTarget = PartnerShip) or ((Order = soJump) and not OrderAbsolute) then TryMirrorPartnerTravelOrders;
        if (Order = soNone) and CanRefuel then SelectNearestReachableDestination;
        if (Order = soNone) and (GetCarriedNodeCount > 0) then TryOrderTravelToShipTypeLocation(6);
        if (Order = soNone) and CanPromoteRank then TryOrderTravelToShipTypeLocation(8);
      end
      else
      begin
        if not TryCollectBestFloatingItem(50) and not OrderAbsolute then
        begin
          SelectEnemyShipInStar;
          EngageEnemyShip;
        end;
        if (Order = soNone) and (GetCarriedNodeCount > 0) then TryOrderTravelToShipTypeLocation(6);
        if (Order = soNone) and CanPromoteRank then TryOrderTravelToShipTypeLocation(8);
        if (Order = soNone) and HasCargoGoods and (GetDesiredCargoFreeSpace > CargoFreeSpace) then
          if NeedsWealthCatchup then OrderBestQueuedTradePlanet
          else SelectNearestReachableDestination;
        if Order = soNone then
          if (GetHull.Weight - GetDesiredCargoFreeSpace < GetCarriedItemWeight) or
            HasHullDamageOrBrokenEquippedItems or CanRefuel then SelectNearestReachableDestination;
        if (Order = soNone) and (HasInactiveDirectEquipment <> 0) and (GetDesiredCargoFreeSpace > CargoFreeSpace) then SelectNearestReachableDestination;
      end;
      if (Order = soNone) and not InFear then SelectIdleFreeFlightDestination(0);
      if Order = soNone then
      begin
        Location := SelectBestTradePlanetFromQueue;
        if (Location = nil) and (GetHull.HullPoints < GetHull.Weight) then Location := SelectRandomPlanetFromQueue;
        if Location <> nil then
          if CurrentStar = Location.CurrentStar then OrderLanding(Location, False)
          else OrderJump(Location.CurrentStar, False);
      end;
    end;
    if Order = soNone then NavigateToEscapePlanet(False);
    if Order = soNone then OrderRandomFreeFlightMove;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TRanger.NextDayLogic ' + GetFullName(' ') + ' label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $751B00 }

{ @routine $752A40 TRanger_ProcessPendingPlayerFollowTargeting }
function TRanger.ProcessPendingPlayerFollowTargeting: Boolean;
var
  I: Integer;
  Weapon: TWeapon;
begin
  if PlayerAutomaticControl then
  begin
    Result := True;
    AutoEquipInventory;
    Exit;
  end;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar <> CurrentStar) then EnemyShip := nil;
  if PendingPlayerFollowTarget <> nil then
  begin
    if PendingPlayerFollowTarget.InNormalSpace and InNormalSpace and (PendingPlayerFollowTarget.CurrentStar = CurrentStar) then
    begin
      OrderFollowShip(PendingPlayerFollowTarget, 1, False);
      for I := 1 to WeaponCount do
      begin
        Weapon := Weapons[I];
        if IsEquipmentUsable(Weapon) and (not (Byte(Weapon.GetWeaponInfo.ShotType) in [Ord(wstTorpedo)..Ord(wstRocket)]) or (Weapon.Ammo > 0)) and
          (GetWeaponRange(Weapon) * GetWeaponRange(Weapon) >= PointDistanceSquared(Position, PendingPlayerFollowTarget.Position)) then
          Weapon.Target := PendingPlayerFollowTarget
        else Weapon.Target := nil;
      end;
    end
    else PendingPlayerFollowTarget := nil;
  end;
  Result := False;
end;
{ @end $752A40 }

{ @routine $752BB4 TRanger_GetHomeStar }
function TRanger.GetHomeStar: TStar;
begin
  Result := HomePlanet.CurrentStar;
end;
{ @end $752BB4 }

{ @routine $752BD0 TRanger_GetName }
function TRanger.GetName: WideString;
begin
  Result := Name;
end;
{ @end $752BD0 }

{ @routine $752BF0 TRanger_GetFullName }
function TRanger.GetFullName(const Separator: WideString): WideString;
var
  Path, Text: WideString;
begin
  if TypeNameOverrideKey = '' then
    Result := LocalizedText('ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + GetTypeNameKey) + Separator + Name
  else
  begin
    Path := 'ShipType.' + OwnerToSys(RaceToOwner(PilotRace)) + '.' + TypeNameOverrideKey;
    if LanguageDataConfig.CountParamsByPath(Path) > 0 then Text := LocalizedText(Path)
    else Text := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Text <> '' then Result := Text + Separator + Name else Result := Name;
  end;
end;
{ @end $752BF0 }

{ @routine $752DB0 TRanger_GetGreetingShipCategory }
function TRanger.GetGreetingShipCategory: Byte;
begin
  Result := gscRanger;
end;
{ @end $752DB0 }

{ @routine $752DC4 TRanger_GetDominantCareer }
function TRanger.GetDominantCareer: TRangerCareer;
var
  Maximum: Integer;
begin
  Maximum := Max(Max(CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcPirate)]), CareerStatus[Ord(rcWarrior)]);
  if CareerStatus[Ord(rcTrader)] = Maximum then Result := rcTrader
  else if CareerStatus[Ord(rcPirate)] = Maximum then Result := rcPirate
  else Result := rcWarrior;
end;
{ @end $752DC4 }

{ @routine $752E60 TRanger_GetCareerSimilarity }
function TRanger.GetCareerSimilarity(Values: TRangerCareerValues): TPercent;
var
  TraderSimilarity, PirateSimilarity, WarriorSimilarity: Integer;
begin
  TraderSimilarity := 100 - Abs(CareerStatus[Ord(rcTrader)] - Values[Ord(rcTrader)]);
  PirateSimilarity := 100 - Abs(CareerStatus[Ord(rcPirate)] - Values[Ord(rcPirate)]);
  WarriorSimilarity := 100 - Abs(CareerStatus[Ord(rcWarrior)] - Values[Ord(rcWarrior)]);
  Result := (TraderSimilarity + PirateSimilarity + WarriorSimilarity) div 3;
end;
{ @end $752E60 }

{ @routine $752EE8 TRanger_GetCharacterName }
function TRanger.GetCharacterName: WideString;
var
  I, Best: Integer;
  Values: TRangerCareerValues;
  Text, Path: WideString;
begin
  Best := 0;
  Result := 'Error in CharacterName';
  Path := 'ShipCharacter';
  if (TypeNameOverrideKey <> '') and (LanguageDataConfig.CountBlocks(Path + TypeNameOverrideKey) > 0) then Path := Path + TypeNameOverrideKey
  else if IsFemaleHumanPilot then Path := Path + 'Female';
  for I := 0 to LanguageDataConfig.GetBlock(Path).GetParamCount - 1 do
  begin
    Text := LanguageDataConfig.GetBlock(Path).GetParamValue(I);
    Values[0] := StrToInt(TrimWideString(ExtractDelimitedPartW(Text, 0, ',')));
    Values[1] := StrToInt(TrimWideString(ExtractDelimitedPartW(Text, 1, ',')));
    Values[2] := StrToInt(TrimWideString(ExtractDelimitedPartW(Text, 2, ',')));
    if GetCareerSimilarity(Values) > Best then
    begin
      Best := GetCareerSimilarity(Values);
      Result := TrimWideString(ExtractDelimitedPartW(Text, 3, ','));
    end;
  end;
end;
{ @end $752EE8 }

{ @routine $7531AC TRanger_GetStrengthScaledPirateStatus }
function TRanger.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := Round(RemapClamped(CareerStatus[Ord(rcPirate)] * StrengthInBestRanger, 0.0, 100.0, 0.0, 100.0));
end;
{ @end $7531AC }

{ @routine $753200 TRanger_GetDesiredCargoFreeSpace }
function TRanger.GetDesiredCargoFreeSpace: Integer;
begin
  case PreferredCareer of
    rcTrader: Result := Trunc(GetHull.Weight * 0.15) + 30;
    rcPirate: Result := Trunc(GetHull.Weight * 0.1) + 40;
    rcWarrior: Result := Trunc(GetHull.Weight * 0.1) + 30;
  else Result := 50;
  end;
end;
{ @end $753200 }

{ @routine $7532A4 TRanger_GetObjectInfoText }
function TRanger.GetObjectInfoText(Instance: TObject): WideString;
begin
  if Instance is TStar then Result := (Instance as TStar).Name
  else if Instance is TPlanet then Result := (Instance as TPlanet).GetInfoText(False)
  else if Instance is TItem then
  begin
    if GetRadarRange < PointDistance(Position, (Instance as TItem).Position) then
      Result := (Instance as TItem).GetSmallInfoText
    else Result := (Instance as TItem).GetDisplayName;
  end
  else if Instance is TShip then
  begin
    if GetRadarRange < PointDistance(Position, (Instance as TShip).Position) then
      Result := (Instance as TShip).GetName
    else Result := (Instance as TShip).GetSpaceInfoText;
  end
  else if Instance is TAsteroid then
  begin
    if GetRadarRange < PointDistance(Position, (Instance as TAsteroid).Position) then
      Result := (Instance as TAsteroid).GetDisplayName
    else Result := (Instance as TAsteroid).GetInfoText;
  end
  else Result := 'unknown object';
end;
{ @end $7532A4 }

{ @routine $7534C0 TRanger_GetEstimatedMemoryUsage }
function TRanger.GetEstimatedMemoryUsage: Integer;
begin
  Result := inherited GetEstimatedMemoryUsage;
  Result := Result + RangerRelations.InstanceSize + RangerRelations.Count * 4;
  Result := Result + Length(Name) * 2;
end;
{ @end $7534C0 }

{ @routine $753514 TRanger_CountWingmen }
function TRanger.CountWingmen: Integer;
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
begin
  Result := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if Ship.PartnerShip = Self then Inc(Result);
    end;
  end;
end;
{ @end $753514 }

{ @routine $7535A8 TRanger_NeedsStrengthCatchup }
function TRanger.NeedsStrengthCatchup: Boolean;
begin
  Result := (Strength / Galaxy.AverageRangerStrength < CareerTuning[Ord(PreferredCareer)].MinimumStrengthToAverageRatio) or
    (StrengthInBestRanger < CareerTuning[Ord(PreferredCareer)].MinimumStrengthToBestRatio);
end;
{ @end $7535A8 }

{ @routine $753618 TRanger_NeedsWealthCatchup }
function TRanger.NeedsWealthCatchup: Boolean;
begin
  Result := (Wealth / Galaxy.AverageRangerCapital < CareerTuning[Ord(PreferredCareer)].MinimumWealthToAverageRatio) or
    (WealthInBestRanger < CareerTuning[Ord(PreferredCareer)].MinimumWealthToBestRatio);
end;
{ @end $753618 }

{ @routine $75368C TRanger_RefuelAtLocation }
procedure TRanger.RefuelAtLocation;
begin
  if (GetFuelTanks <> nil) and (GetFullRefuelCost > 0) and (GetFullRefuelCost <= Money) then
  begin
    SetMoney(Money - GetFullRefuelCost);
    GetFuelTanks.Fuel := GetFuelTanks.Capacity;
  end;
end;
{ @end $75368C }

{ @routine $7536F8 TRanger_SimulateUnseenProgression }
procedure TRanger.SimulateUnseenProgression;
var Award: Byte;
begin
  if DaysSincePlayerSeen < 50 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor then Exit;
  if GetPlayer = nil then Exit;
  if not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) then Exit;
  if NextRandomUnitFloat(RandomState) < 0.05 then TryPromoteRank;
  if (Money < 50000) and (NextRandomUnitFloat(RandomState) < 0.6) and
    (NextRandomFloatRange(0, 1, RandomState) > WealthInBestRanger) then
    case Round(GetPlayer.WealthInBestRanger * 100) of
      0..20: SetMoney(Money + Galaxy.ComputeScaledAverageMoney(2));
      21..40: SetMoney(Money + Galaxy.ComputeScaledAverageMoney(2));
      41..60: SetMoney(Money + Galaxy.ComputeScaledAverageMoney(2));
      61..90: SetMoney(Money + Galaxy.ComputeScaledBigMoney(2));
      91..100: SetMoney(Money + Galaxy.ComputeScaledHugeMoney(2));
    end;
  if ((NextRandomUnitFloat(RandomState) < 0.05) and (NeedsStrengthCatchup or (NextRandomUnitFloat(RandomState) < 0.3))) or
    (NextRandomUnitFloat(RandomState) < 0.01) then begin
    if (NextRandomFloatRange(0, 0.7, RandomState) > WealthInBestRanger) and (Money < 25000) then
      SetMoney(Money + Galaxy.ComputeScaledBigMoney(2))
    else if (NeedsStrengthCatchup and (NextRandomUnitFloat(RandomState) < 0.5)) or (NextRandomUnitFloat(RandomState) < 0.05) then
      ImproveRandomEquipment(True);
  end;
  if (NextRandomUnitFloat(RandomState) < 0.02) and (NeedsStrengthCatchup or (NextRandomUnitFloat(RandomState) < 0.001)) then GenerateExtraWeapon;
  if ((CurrentStar.ShipTypeCounts[stKling] > 0) and (NextRandomUnitFloat(RandomState) < 0.2)) or
    ((CurrentStar.ShipTypeCounts[stKling] > 0) and (GetPlayer <> nil) and
      (GetPlayer.PlaceInRating < Galaxy.Rangers.Count div 3) and (NextRandomUnitFloat(RandomState) < 0.5)) or
    ((Galaxy.CurrentTurn < 300) and ((NextRandomUnitFloat(RandomState) < 0.4) or
      ((Integer(Seed) mod 5 = 0) and (NextRandomUnitFloat(RandomState) < 0.8)))) then begin
    Inc(TotalShipKillCount);
    Inc(DominatorKillCount);
    Inc(CurrentSystemKills.Dominator);
    AddRankPoints(NextRandomIntRange(DominatorShipDefinitions[Ord(ktShtip)].RankPoints, DominatorShipDefinitions[Ord(ktEquentor)].RankPoints, RandomState));
    GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), 0);
    AddWarriorCareerActivity(4);
    if (Galaxy.CurrentTurn < 300) and (((DominatorKillCount mod 13 = 0) and (NextRandomUnitFloat(RandomState) < 0.3)) or
      (DominatorKillCount mod 20 = 0)) then begin
      Inc(LiberatedSystemCount);
      AddRankPoints(30);
      GainExperience(NextRandomIntRange(500, 1000, Galaxy.RandomState), 0);
      AddAward(SelectAward(PickRandomEquipmentOwner(RandomState), [atLiberation], [stKling..Ord(rstCustomStation)]));
    end;
  end
  else if (NextRandomUnitFloat(RandomState) < 0.1) and ((GetDominantCareer <> rcPirate) or (NextRandomUnitFloat(RandomState) < 0.1)) then begin
    Inc(TotalShipKillCount);
    Inc(PirateKillCount);
    AddRankPoints(10);
    if NextRandomUnitFloat(RandomState) < 0.1 then begin
      Inc(TotalShipKillCount);
      Inc(PirateKillCount);
      AddRankPoints(10);
    end;
    AddWarriorCareerActivity(2);
  end
  else if (NextRandomUnitFloat(RandomState) < 0.2) and ((GetDominantCareer = rcPirate) or (NextRandomUnitFloat(RandomState) < 0.2)) then begin
    Inc(TotalShipKillCount);
    if PreferredCareer = rcPirate then AddPirateCareerActivity(2) else AddPirateCareerActivity(1);
  end;
  if (NextRandomUnitFloat(RandomState) < 0.09) or
    ((GetPlayer <> nil) and (GetPlayer.PlaceInRating < Galaxy.Rangers.Count div 3) and
      ((GetPlayer.PlaceInRating < PlaceInRating) or (NextRandomUnitFloat(RandomState) < 0.4)) and (NextRandomUnitFloat(RandomState) < 0.3)) or
    ((Galaxy.CurrentTurn < 300) and (NextRandomUnitFloat(RandomState) < 0.3)) then begin
    case Round(RemapClamped(GetPlayer.PlaceInRating, 1, Galaxy.Rangers.Count, 0, 100)) of
      0..20: GainExperience(NextRandomIntRange(100, 1000, RandomState), 0);
      21..40: GainExperience(NextRandomIntRange(100, 500, RandomState), 0);
      41..60: GainExperience(NextRandomIntRange(100, 500, RandomState), 0);
      61..80: GainExperience(NextRandomIntRange(100, 500, RandomState), 0);
      81..100: GainExperience(NextRandomIntRange(100, 500, RandomState), 0);
    end;
    if CurrentStar.ShipTypeCounts[stKling] > 0 then GainExperience(NextRandomIntRange(100, 500, RandomState), 0);
  end;
  if (Rank < 5) and (GetPlayer.Rank > Byte(Rank + 1)) and (NextRandomUnitFloat(RandomState) < 0.05) then begin
    AddRankPoints(NextRandomIntRange(2, 20, RandomState));
    Inc(TotalShipKillCount);
    Inc(PirateKillCount);
    Inc(TotalShipKillCount);
    Inc(PirateKillCount);
  end;
  if CurrentPlanet <> nil then begin
    if ((GetPlayer.AwardIds <> nil) and ((AwardIds = nil) or (AwardIds.Count < Min(5, GetPlayer.AwardIds.Count))) and
        (NextRandomUnitFloat(RandomState) < 0.1)) or
      ((GetPlayer.AwardIds <> nil) and ((AwardIds = nil) or (GetPlayer.AwardIds.Count + 5 > AwardIds.Count)) and
        (NextRandomUnitFloat(RandomState) < 0.004)) or
      ((GetPlayer.AwardIds = nil) and ((AwardIds = nil) or (AwardIds.Count < 4)) and (NextRandomUnitFloat(RandomState) < 0.006)) or
      (((AwardIds = nil) or (DominatorKillCount div 10 > AwardIds.Count)) and (NextRandomUnitFloat(RandomState) < 0.004)) then begin
      case GetDominantCareer of
        rcTrader: Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment, atSecretMission, atCowardice, atPlanetBattle], [stKling..Ord(rstCustomStation)]);
        rcPirate: Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment, atSecretMission, atCowardice, atPerfidy, atPlanetBattle], [stKling..Ord(rstCustomStation)]);
        rcWarrior: Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment, atSecretMission, atPlanetBattle], [stKling..Ord(rstCustomStation)]);
        else Award := 255;
      end;
      if Award <> AwardNotFound then AddAward(Award);
    end;
    if (Galaxy.TechLevel > 3) and (NextRandomUnitFloat(RandomState) < 0.1) and
      ((Galaxy.TechLevel > 5) or (NextRandomUnitFloat(RandomState) < 0.2)) and
      (((GetPlayer.StrengthInBestRanger > 0.9) and (StrengthInBestRanger < 0.7)) or (StrengthInBestRanger < 0.3)) then GenerateExtraWeapon;
  end;
end;
{ @end $7536F8 }

{ @routine $754418 TRanger_AddTraderCareerActivity }
procedure TRanger.AddTraderCareerActivity(Amount: Byte);
begin
  if Cardinal(PendingCareerActivity[0]) + Amount < 100 then Inc(PendingCareerActivity[0], Amount)
  else PendingCareerActivity[0] := 100;
end;
{ @end $754418 }

{ @routine $754458 TRanger_AddPirateCareerActivity }
procedure TRanger.AddPirateCareerActivity(Amount: Byte);
begin
  if Cardinal(PendingCareerActivity[1]) + Amount < 100 then Inc(PendingCareerActivity[1], Amount)
  else PendingCareerActivity[1] := 100;
end;
{ @end $754458 }

{ @routine $754498 TRanger_AddWarriorCareerActivity }
procedure TRanger.AddWarriorCareerActivity(Amount: Byte);
begin
  if Cardinal(PendingCareerActivity[2]) + Amount < 100 then Inc(PendingCareerActivity[2], Amount)
  else PendingCareerActivity[2] := 100;
end;
{ @end $754498 }

{ @routine $7544D8 TRanger_ClearPendingCareerActivity }
procedure TRanger.ClearPendingCareerActivity;
begin
  PendingCareerActivity[0] := 0;
  PendingCareerActivity[1] := 0;
  PendingCareerActivity[2] := 0;
end;
{ @end $7544D8 }

{ @routine $7546E0 TRanger_ProcessCareerActivityAndEminentProgress }
procedure TRanger.ProcessCareerActivityAndEminentProgress;
var
  Delta: Integer;
  Text: WideString;
  Amount: Integer;
  // @nested $754500 IncreaseRangerCareerAxis
  procedure IncreaseRangerCareerAxis(var Selected, OtherA, OtherB: Byte; Amount: Integer); // @addr 0x754500 @ida "void __usercall $name(unsigned __int8 *Selected@<eax>, unsigned __int8 *OtherA@<edx>, unsigned __int8 *OtherB@<ecx>, int Amount@<^0>, void *ParentFrame@<^4>);" @stackpop 0x4 @calls "0x754848 0x754907 0x754AA3 0x754B62 0x754CFC 0x754DBE" @note "Raises Selected up to 100 and proportionally reduces the other axes when needed."
  var
    Smaller, Larger: PByte;
    Reduction, SmallReduction, LargeReduction: Integer;
  begin
    Reduction := Amount;
    if Cardinal(Selected) + OtherA + OtherB < 100 then Reduction := Max(0, Selected + OtherA + OtherB + (Reduction - 100));
    if OtherA + OtherB < Reduction then Reduction := OtherA + OtherB;
    Selected := Max(Selected, Min(100, Selected + Amount));
    if Reduction > 0 then
    begin
      if OtherA >= OtherB then
      begin
        Smaller := @OtherB;
        Larger := @OtherA;
      end
      else
      begin
        Smaller := @OtherA;
        Larger := @OtherB;
      end;
      SmallReduction := Round(Reduction / (OtherA + OtherB) * Smaller^);
      LargeReduction := Round(Reduction / (OtherA + OtherB) * Larger^);
      if SmallReduction + LargeReduction > Reduction then Dec(LargeReduction);
      if SmallReduction + LargeReduction < Reduction then Inc(SmallReduction);
      if Smaller^ < SmallReduction then
      begin
        Larger^ := OtherA + OtherB - Reduction;
        Smaller^ := 0;
      end
      else if Larger^ < LargeReduction then
      begin
        Smaller^ := OtherA + OtherB - Reduction;
        Larger^ := 0;
      end
      else
      begin
        Dec(Smaller^, SmallReduction);
        Dec(Larger^, LargeReduction);
      end;
    end;
  end;

begin
  if (GetPlayer <> Self) and ((Galaxy.EminentCareerShips[Ord(rcTrader)] = Self) or (Galaxy.EminentCareerShips[Ord(rcPirate)] = Self) or (Galaxy.EminentCareerShips[Ord(rcWarrior)] = Self)) then
  begin
    ClearPendingCareerActivity;
    Exit;
  end;
  if PendingCareerActivity[0] > 0 then
  begin
    Delta := PendingCareerActivity[0];
    if GetPlayer = Self then
    begin
      Amount := TradeExperience;
      TradeExperience := 0;
    end
    else Amount := Round(RemapClamped(Delta, 1.0, 100.0, 10.0, 100.0));
    if IsHealthEffectActive(22) then Amount := Round(Amount * 1.5);
    GainExperience(Amount, 4);
    if Delta mod 2 <> 0 then Inc(Delta);
    Delta := Min(8, Delta);
    Delta := Delta div 2;
    IncreaseRangerCareerAxis(CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcPirate)], CareerStatus[Ord(rcWarrior)], Delta);
    if (Galaxy.EminentCareerShips[Ord(rcTrader)] <> Self) and (PlaceInRating < Galaxy.Rangers.Count div 2) and
      (Galaxy.CoalitionDefeatedTurn = 0) and not ExcludedFromRating then
    begin
      if EminentProgress[Ord(rcTrader)] + Delta * 2 >= 100 then
      begin
        if CareerStatus[Ord(rcTrader)] < 60 then IncreaseRangerCareerAxis(CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcPirate)], CareerStatus[Ord(rcWarrior)], (60 - CareerStatus[Ord(rcTrader)]) div 2 + 1);
        Amount := RoundAndTruncateToTens(NextRandomIntRange(100, 250, RandomState) / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
        Text := FormatText2(PickLocalizedTextVariant('GalaxyNews.EminentRangers.EminentTrader', Seed * Cardinal(Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Name>', Name, '<Points>', IntToStr(Amount));
        if GetPlayer = Self then Galaxy.AddPlanetNewsWithPlayerBubble(38, Text)
        else Galaxy.AddPlanetNews(38, Text);
        EminentProgress[Ord(rcTrader)] := 0;
        HalveAllRangerEminentProgress(rcTrader);
        GainExperience(Amount, 0);
        Galaxy.EminentCareerShips[Ord(rcTrader)] := Self;
      end
      else Inc(EminentProgress[Ord(rcTrader)], Delta * 2);
    end;
  end;
  if PendingCareerActivity[1] > 0 then
  begin
    Delta := PendingCareerActivity[1];
    if Delta mod 2 <> 0 then Inc(Delta);
    Delta := Min(8, Delta);
    Delta := Delta div 2;
    IncreaseRangerCareerAxis(CareerStatus[Ord(rcPirate)], CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcWarrior)], Delta);
    if (Galaxy.EminentCareerShips[Ord(rcPirate)] <> Self) and (PlaceInRating < Galaxy.Rangers.Count div 2) and
      (Galaxy.CoalitionDefeatedTurn = 0) and not ExcludedFromRating then
    begin
      if EminentProgress[Ord(rcPirate)] + Delta * 2 >= 100 then
      begin
        if CareerStatus[Ord(rcPirate)] < 60 then IncreaseRangerCareerAxis(CareerStatus[Ord(rcPirate)], CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcWarrior)], (60 - CareerStatus[Ord(rcPirate)]) div 2 + 1);
        Amount := RoundAndTruncateToTens(NextRandomIntRange(250, 1000, RandomState) * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
        Text := FormatText2(PickLocalizedTextVariant('GalaxyNews.EminentRangers.EminentPirate', Seed * Cardinal(Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Name>', Name, '<Points>', IntToStr(Amount));
        if GetPlayer = Self then Galaxy.AddPlanetNewsWithPlayerBubble(39, Text)
        else Galaxy.AddPlanetNews(39, Text);
        EminentProgress[Ord(rcPirate)] := 0;
        HalveAllRangerEminentProgress(rcPirate);
        RemoveExperience(Amount);
        Galaxy.EminentCareerShips[Ord(rcPirate)] := Self;
      end
      else Inc(EminentProgress[Ord(rcPirate)], Delta * 2);
    end;
  end;
  if PendingCareerActivity[2] > 0 then
  begin
    Delta := PendingCareerActivity[2];
    if Delta mod 2 <> 0 then Inc(Delta);
    Delta := Min(8, Delta);
    Delta := Delta div 2;
    IncreaseRangerCareerAxis(CareerStatus[Ord(rcWarrior)], CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcPirate)], Delta);
    if (Galaxy.EminentCareerShips[Ord(rcWarrior)] <> Self) and (PlaceInRating < Galaxy.Rangers.Count div 2) and
      (Galaxy.CoalitionDefeatedTurn = 0) and not ExcludedFromRating then
    begin
      if EminentProgress[Ord(rcWarrior)] + Delta * 2 >= 100 then
      begin
        if CareerStatus[Ord(rcWarrior)] < 60 then IncreaseRangerCareerAxis(CareerStatus[Ord(rcWarrior)], CareerStatus[Ord(rcTrader)], CareerStatus[Ord(rcPirate)], (60 - CareerStatus[Ord(rcWarrior)]) div 2 + 1);
        Amount := RoundAndTruncateToTens(NextRandomIntRange(250, 1000, RandomState) / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
        Text := FormatText2(PickLocalizedTextVariant('GalaxyNews.EminentRangers.EminentWarrior', Seed * Cardinal(Galaxy.CurrentTurn div 10)),
          '<color=255,240,100>', '<Name>', Name, '<Points>', IntToStr(Amount));
        if GetPlayer = Self then Galaxy.AddPlanetNewsWithPlayerBubble(37, Text)
        else Galaxy.AddPlanetNews(37, Text);
        EminentProgress[Ord(rcWarrior)] := 0;
        HalveAllRangerEminentProgress(rcWarrior);
        GainExperience(Amount, 0);
        Galaxy.EminentCareerShips[Ord(rcWarrior)] := Self;
      end
      else Inc(EminentProgress[Ord(rcWarrior)], Delta * 2);
    end;
  end;
  ClearPendingCareerActivity;
end;
{ @end $7546E0 }

{ @routine $7550AC TRanger_HalveAllRangerEminentProgress }
procedure TRanger.HalveAllRangerEminentProgress(Career: TRangerCareer);
var
  I: Integer;
  Ranger: TRanger;
begin
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(Galaxy.Rangers[I]);
    Ranger.EminentProgress[Ord(Career)] := Round(Ranger.EminentProgress[Ord(Career)] * 0.5);
  end;
end;
{ @end $7550AC }

{ @routine $75512C TRanger_OrderBestQueuedTradePlanet }
function TRanger.OrderBestQueuedTradePlanet: Boolean;
var
  Planet: TPlanet;
begin
  Planet := SelectBestTradePlanetFromQueue;
  if Planet <> nil then
  begin
    if CurrentStar = Planet.CurrentStar then OrderLanding(Planet, False)
    else OrderJump(Planet.CurrentStar, False);
    Result := True;
  end
  else Result := False;
end;
{ @end $75512C }

{ @routine $755184 TRanger_SelectBestTradePlanetFromQueue }
function TRanger.SelectBestTradePlanetFromQueue: TPlanet;
var
  Good: Byte;
  BestScore, Profit, PurchaseProfit: Single;
  I: Integer;
  BestPlanet, Planet: TPlanet;
begin
  BestScore := 0;
  BestPlanet := nil;
  for I := 0 to PlanetQueue.Count - 1 do
  begin
    Planet := TPlanet(PlanetQueue[I]);
    if Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)] then
    begin
      Profit := 0;
      PurchaseProfit := 1;
      for Good := 0 to 7 do
      begin
        if CargoGoods[Good].Count > 0 then
        begin
          if ShopGoodsSellPrice(Good, Planet) > GetAverageCargoCost(Good) then
            Profit := Profit + (ShopGoodsSellPrice(Good, Planet) - GetAverageCargoCost(Good)) * CargoGoods[Good].Count;
        end
        else if GoodsMarket[Good].AveragePrice * 0.7 > ShopGoodsPurchasePrice(Good, Planet) then
          PurchaseProfit := PurchaseProfit + Min(Money div ShopGoodsPurchasePrice(Good, Planet), Min(CargoFreeSpace, Planet.Goods[Good].Count)) *
            (GoodsMarket[Good].AveragePrice - ShopGoodsPurchasePrice(Good, Planet));
      end;
      Profit := Profit + Min(Profit, PurchaseProfit);
      Profit := Profit - RemapClamped(CurrentStar.ThreatLevel, 0, 100, 0, 0.5) * Profit;
      Profit := Profit - RemapClamped(CurrentStar.TrafficLevel, 50, 100, 0, 0.8) * Profit;
      if Planet.CurrentStar = CurrentStar then Profit := 1.6 * Profit;
      if Profit > BestScore then
      begin
        BestScore := Profit;
        BestPlanet := Planet;
      end;
    end;
  end;
  Result := BestPlanet;
end;
{ @end $755184 }

{ @routine $755468 TRanger_SelectRandomPlanetFromQueue }
function TRanger.SelectRandomPlanetFromQueue: TPlanet;
begin
  if PlanetQueue.Count > 0 then Result := TPlanet(PlanetQueue[NextRandomIntRange(0, PlanetQueue.Count - 1, RandomState)])
  else Result := nil;
end;
{ @end $755468 }

{ @routine $7554C0 TRanger_BuildReachablePlanetQueue }
procedure TRanger.BuildReachablePlanetQueue;
var
  I, J: Integer;
  Star: TStar;
  Planet: TPlanet;
begin
  ClearPlanetQueue;
  PlanetQueue := TList.Create;
  if Speed = 0 then Exit;
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (I > 0) and (CurrentStar.StarDistances[I].Distance > JumpRange) then Break;
    if Star.Constellation.Id = 20 then Continue;
    if Star.Status.CustomFaction <> '' then Exit;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      if (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and CanQueueReachablePlanet(Planet) and (Planet <> LastDockedPlanet) then
        PlanetQueue.Add(Planet);
    end;
  end;
end;
{ @end $7554C0 }

{ @routine $755610 TRanger_CanQueueReachablePlanet }
function TRanger.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := (Planet.OwnerId <> Byte(oiDominator)) and (InFear or (Planet.GetRelationLevelToShip(Self) > rlHostile));
end;
{ @end $755610 }

{ @routine $755650 TRanger_SelectIdleFreeFlightDestination }
procedure TRanger.SelectIdleFreeFlightDestination(UnusedMode: Byte);
const
  CoalitionShipTypes = [1..5];
  DominatorShipType = [0];
var
  I, CareerThreshold, ShipCount: Integer;
  Star, NextStar: TStar;
  Good: Byte;
  EnemyStrength, FriendlyStrength: Single;
begin
  for Good := 0 to 7 do
    if CargoGoods[Good].Count > 0 then Exit;
  if GetCargoHook = nil then Exit;
  if GetHull.Weight > GetHull.HullPoints then Exit;
  case PreferredCareer of
    rcTrader: CareerThreshold := 3;
    rcPirate: CareerThreshold := 1;
    rcWarrior: CareerThreshold := 0;
  else CareerThreshold := 0;
  end;
  { Native retains this comparison although neither branch does anything. }
  if UnusedMode = 0 then;
  NextStar := nil;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if Star.Constellation.Id = 20 then Continue;
    if CurrentStar.StarDistances[I].Distance > JumpRange then Break;
    if (BlazerShip = nil) or (BlazerShip.CurrentStar <> Star) or
      ((Aggression >= 20) and ((Star.CountShipsByTypeMask(CoalitionShipTypes) <= 6) or (NextRandomUnitFloat(RandomState) >= 0.95)) and
      not AcceptsRansomDemandFrom(BlazerShip) and ((Star.ControlFaction = sfCoalition) or (GetFuelTanks.Fuel div 2 >= CurrentStar.StarDistances[I].Distance))) then
      if Star.Ships.Count <= 20 then
      begin
        ShipCount := Star.CountShipsByTypeMask(CoalitionShipTypes);
        FriendlyStrength := Star.SumBestRangerRelativeStrength(CoalitionShipTypes);
        EnemyStrength := Star.SumBestRangerRelativeStrength(DominatorShipType);
        if (Star.ControlFaction = sfDominators) and
          (((GetFuelTanks.Fuel div 2 > CurrentStar.StarDistances[I].Distance) and (ShipCount > 0)) or
          ((ShipCount > 4) and (ShipCount > Star.ShipTypeCounts[stKling]) and (FriendlyStrength > EnemyStrength))) then
        begin
          if Star.Battle <> 0 then
          begin
            OrderJump(Star, False);
            Exit;
          end;
          if NextStar = nil then NextStar := Star;
        end;
        if (Star.ControlFaction = sfDominators) and (FriendlyStrength + StrengthInBestRanger + 2 > EnemyStrength) and
          (GetFuelTanks.Fuel div 2 > CurrentStar.StarDistances[I].Distance) then
        begin
          if FriendlyStrength + StrengthInBestRanger > EnemyStrength then
          begin
            OrderJump(Star, False);
            Exit;
          end;
          if NextStar = nil then NextStar := Star;
        end;
        if (Star.Battle <> 0) and (Star.ControlFaction = sfCoalition) and
          ((Star.Ships.Count div 2 > Star.ShipTypeCounts[stKling]) or (CareerThreshold + 4 < ShipCount) or
          (GetFuelTanks.Fuel div 2 > CurrentStar.StarDistances[I].Distance) or (FriendlyStrength + StrengthInBestRanger > EnemyStrength)) then
        begin
          OrderJump(Star, False);
          Exit;
        end;
      end;
  end;
  if NextStar = nil then
    for I := 1 to Galaxy.Stars.Count - 1 do
    begin
      Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
      if (Star.Constellation.Id <> 20) and (Star.ControlFaction <> sfCoalition) and (Star.CountShipsByTypeMask(CoalitionShipTypes) <= 12) and
        ((BlazerShip = nil) or (BlazerShip.CurrentStar <> Star) or ((Aggression >= 30) and (Star.CountShipsByTypeMask(CoalitionShipTypes) <= 6))) then
      begin
        NextStar := FindNextStarTowardDestination(Star, True);
        if NextStar <> nil then Break;
      end;
    end;
  if NextStar <> nil then OrderJump(NextStar, False);
end;
{ @end $755650 }

{ @routine $755AE4 TRanger_TryOrderTravelToShipTypeLocation }
function TRanger.TryOrderTravelToShipTypeLocation(ShipType: Byte): Boolean;
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
begin
  if CurrentStar.ShipTypeCounts[ShipType] > 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if (Ship.TypeId = ShipType) and Ship.InNormalSpace and Ship.CanDock(Self) then
      begin
        OrderLanding(Ship, True);
        Result := True;
        Exit;
      end;
    end;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (Star.ShipTypeCounts[ShipType] <> 0) and (Star.ShipTypeCounts[stRanger] <= 13) then
    begin
      if GetEngine.JumpRange < CurrentStar.StarDistances[I].Distance then Break;
      if Star.Constellation.Id = 20 then Continue;
      { Native scans the current system here, even though Star is a remote candidate. }
      for J := 0 to CurrentStar.Ships.Count - 1 do
      begin
        Ship := TShip(CurrentStar.Ships[J]);
        if (Ship.TypeId = ShipType) and Ship.InNormalSpace then
        begin
          OrderJump(Star, True);
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;
{ @end $755AE4 }

{ @routine $755C8C TRanger_SelectNearestReachableDestination }
procedure TRanger.SelectNearestReachableDestination;
var
  I: Integer;
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;
  CurrentTurns, Turns: Integer;
  BestTarget: TObject;
  BestTurns: Integer;
begin
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  if PartnerShip <> nil then
  begin
    if PartnerShip.CurrentStar = CurrentStar then
    begin
      if (Order = soLand) and (PartnerShip.OrderTarget = OrderTarget) then Exit;
      if PartnerShip.Order = soLand then
      begin
        if CanRefuel or (HasCargoGoods and (GetDesiredCargoFreeSpace > CargoFreeSpace)) or
          (PartnerShip.OrderTarget is TRuins) or (GetHull.Weight - GetDesiredCargoFreeSpace < GetCarriedItemWeight) or
          (GetHullIntegrityPercent < 70) or HasHullDamageOrBrokenEquippedItems then
        begin
          if not (PartnerShip.OrderTarget is TRuins) or (PartnerShip.OrderTarget as TRuins).CanDock(Self) then
            OrderLanding(PartnerShip.OrderTarget, True);
          Exit;
        end;
      end
      else if PartnerShip.Order = soJump then
      begin
        Star := PartnerShip.OrderTarget as TStar;
        if (Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '') then
        begin
          OrderJump(Star, False);
          Exit;
        end;
      end;
    end
    else
    begin
      if (PartnerShip.Order = soJump) and (PartnerShip.OrderTarget is TStar) and (PartnerShip.OrderTarget <> CurrentStar) then
        OrderJump(PartnerShip.OrderTarget as TStar, True)
      else OrderJump(PartnerShip.CurrentStar, True);
      Exit;
    end;
  end;
  if Order in [soLand, soJump, soJumpHole] then
  begin
    CurrentTurns := EstimateOrderTravelTurns;
    BestTarget := OrderTarget;
    BestTurns := CurrentTurns;
  end
  else
  begin
    CurrentTurns := 1000;
    BestTarget := nil;
    BestTurns := CurrentTurns;
  end;
  for I := 0 to CurrentStar.Planets.Count - 1 do
  begin
    Planet := TPlanet(CurrentStar.Planets[I]);
    if CanQueueReachablePlanet(Planet) and (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then
    begin
      Turns := EstimateTravelTurnsToObject(Planet);
      if BestTurns > Turns then
      begin
        BestTurns := Turns;
        BestTarget := Planet;
      end;
    end;
  end;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and Ship.CanDock(Self) then
    begin
      Turns := EstimateTravelTurnsToObject(Ship);
      if BestTurns > Turns then
      begin
        BestTurns := Turns;
        BestTarget := Ship;
      end;
    end;
  end;
  if not (BestTarget is TPlanet) and not (BestTarget is TShip) then
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    if CurrentStar.StarDistances[I].Distance > JumpRange then Break;
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (Star.ControlFaction <> sfDominators) and (Star.Constellation.Id <> 20) and (Star.Status.CustomFaction = '') then
    begin
      Turns := EstimateTravelTurnsToObject(Star);
      if BestTurns > Turns then
      begin
        BestTurns := Turns;
        BestTarget := Star;
      end;
    end;
  end;
  if (BestTarget <> nil) and (BestTarget <> OrderTarget) then
    if BestTarget is TPlanet then OrderLanding(BestTarget, False)
    else if BestTarget is TShip then OrderLanding(BestTarget, False)
    else if BestTarget is TStar then OrderJump(BestTarget as TStar, False);
end;
{ @end $755C8C }

{ @routine $75618C TRanger_SelectAlternateReachableDestination }
procedure TRanger.SelectAlternateReachableDestination;
var
  I: Integer;
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;
  CurrentTurns, Turns: Integer;
  BestTarget: TObject;
  BestTurns, LeavingBonus: Integer;
begin
  if Galaxy.SpecialSimulationMode <> 0 then Exit;
  if Order in [soLand, soJump, soJumpHole] then
  begin
    CurrentTurns := EstimateOrderTravelTurns;
    BestTarget := OrderTarget;
    BestTurns := CurrentTurns;
  end
  else
  begin
    CurrentTurns := 1000;
    BestTarget := nil;
    BestTurns := CurrentTurns;
  end;
  for I := 0 to CurrentStar.Planets.Count - 1 do
  begin
    Planet := TPlanet(CurrentStar.Planets[I]);
    if (Planet <> LastDockedPlanet) and CanQueueReachablePlanet(Planet) and (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) then
    begin
      Turns := EstimateTravelTurnsToObject(Planet);
      if BestTurns > Turns then
      begin
        BestTurns := Turns;
        BestTarget := Planet;
      end;
    end;
  end;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if (Ship <> LastDockedNonPlanetLocation) and (Ship.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)]) and Ship.CanDock(Self) then
    begin
      Turns := EstimateTravelTurnsToObject(Ship);
      if BestTurns > Turns then
      begin
        BestTurns := Turns;
        BestTarget := Ship;
      end;
    end;
  end;
  LeavingBonus := 0;
  if (GetHullIntegrityPercent > 70) and (((LastDockedNonPlanetLocation <> nil) and (LastDockedNonPlanetLocation.CurrentStar = CurrentStar)) or
    ((LastDockedPlanet <> nil) and (LastDockedPlanet.CurrentStar = CurrentStar))) then Inc(LeavingBonus, 10);
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    if CurrentStar.StarDistances[I].Distance > JumpRange then Break;
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (Star.ControlFaction <> sfDominators) and (Star.Constellation.Id <> 20) and (Star.Status.CustomFaction = '') then
    begin
      Turns := EstimateTravelTurnsToObject(Star) - LeavingBonus;
      if BestTurns > Turns then
      begin
        BestTurns := Turns;
        BestTarget := Star;
      end;
    end;
  end;
  if (BestTarget <> nil) and (BestTarget <> OrderTarget) then
    if BestTarget is TPlanet then OrderLanding(BestTarget, False)
    else if BestTarget is TShip then OrderLanding(BestTarget, False)
    else if BestTarget is TStar then OrderJump(BestTarget as TStar, False);
end;
{ @end $75618C }

{ @routine $756488 TRanger_SellCargoGoods }
procedure TRanger.SellCargoGoods;
var
  Good: Byte;
  Cost: Single;
  BestPlanet: TPlanet;
begin
  for Good := 0 to 7 do
    if CargoGoods[Good].Count <> 0 then
    begin
      Cost := GetAverageCargoCost(Good);
      if (ShopGoodsSellPrice(Good, nil) > Cost) or (FindBestQueuedSellPlanetProfitScore(Good, BestPlanet, Cost) < 80) or not NeedsWealthCatchup then
        SellGoodsToLocation(Good, CargoGoods[Good].Count);
    end;
  RefreshDerivedStats(True);
end;
{ @end $756488 }

{ @routine $756530 TRanger_BuyProfitableGoods }
procedure TRanger.BuyProfitableGoods;
var
  Good, BestGood: Byte;
  Count: Integer;
  KeepBuying: Boolean;
  BestRatio: Double;
  BestPlanet: TPlanet;
begin
  KeepBuying := True;
  while (Money > 0) and KeepBuying do
  begin
    BestRatio := 0;
    BestGood := 0;
    for Good := 0 to 7 do
      if CurrentPlanet.Goods[Good].Count > 0 then
        if (GoodsMarket[Good].AveragePrice * 1.1 > ShopGoodsPurchasePrice(Good, nil)) and
          (GoodsMarket[Good].AveragePrice / ShopGoodsPurchasePrice(Good, nil) > BestRatio) and
          (FindBestQueuedSellPlanetProfitScore(Good, BestPlanet, ShopGoodsPurchasePrice(Good, nil)) > 50) then
              if Min(CargoFreeSpace, CurrentPlanet.Goods[Good].Count) * ShopGoodsPurchasePrice(Good, nil) > Min(Money * 0.2, Wealth * 0.05) then
              begin
                BestRatio := GoodsMarket[Good].AveragePrice / ShopGoodsPurchasePrice(Good, nil);
                BestGood := Good;
              end;
    if BestRatio > 0 then
    begin
      Count := Min(Trunc(Money / ShopGoodsPurchasePrice(BestGood, nil)), CargoFreeSpace);
      if Count > 0 then
      begin
        Count := Min(CurrentPlanet.Goods[BestGood].Count, Count);
        BuyGoodsFromLocation(BestGood, Count);
      end
      else KeepBuying := False;
    end
    else KeepBuying := False;
    RefreshDerivedStats(True);
  end;
end;
{ @end $756530 }

{ @routine $75681C TRanger_FindBestQueuedSellPlanetProfitScore }
function TRanger.FindBestQueuedSellPlanetProfitScore(Good: Byte; var BestPlanet: TPlanet; UnitCost: Double): Byte;
var
  I: Integer;
  Planet: TPlanet;
  Score: Double;
begin
  Result := 0;
  for I := 1 to PlanetQueue.Count - 1 do
  begin
    Planet := TPlanet(PlanetQueue[I]);
    if Planet.CurrentStar = CurrentStar then
      Score := RemapClamped(ShopGoodsSellPrice(Good, Planet) / UnitCost, 1, 1.4, 0, 100)
    else
      Score := RemapClamped(ShopGoodsSellPrice(Good, Planet) / UnitCost, 1, 2, 0, 100);
    if Result < Score then
    begin
      BestPlanet := Planet;
      Result := Round(Score);
    end;
  end;
end;
{ @end $75681C }

{ @routine $756934 TRanger_ApplyIllegalGoodsTradeRelationsPenalty }
procedure TRanger.ApplyIllegalGoodsTradeRelationsPenalty(TotalTradeValue: Integer);
begin
  if CurrentPlanet <> nil then
  begin
    CurrentPlanet.ChangeRelationToRanger(Self, -Round(RemapClamped(TotalTradeValue,
      Galaxy.AverageRangerCapital div 30, Galaxy.AverageRangerCapital div 7, 20, 70)));
    if GetPlayer = Self then AddPirateCareerActivity(4)
    else if NextRandomUnitFloat(RandomState) < 0.2 then AddPirateCareerActivity(4);
  end;
end;
{ @end $756934 }

{ @routine $756A0C TRanger_RepairBrokenEquipmentAtLocation }
procedure TRanger.RepairBrokenEquipmentAtLocation;
var
  I, Cost: Integer;
  Equipment, Artefact: TEquipment;
begin
  for I := Inventory.Count - 1 downto 0 do
  begin
    Equipment := TEquipment(Inventory[I]);
    if (not (Equipment is TWeapon) or (TWeapon(Equipment).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)) and
      CanRepairEquipmentTech(Equipment) and ((Equipment.BrokenFlag <> 0) or (Equipment.ConditionPercent < 50)) and
      (Equipment.EquippedFlag <> 0) then
    begin
      Cost := Equipment.CalculateRepairCost;
      { Native repair proceeds even when there is not enough money. }
      if Money > Cost then SetMoney(Money - Cost);
      Equipment.Repair;
    end;
  end;
  if CanRepairArtefactsAtLocation then
    for I := 0 to Artefacts.Count - 1 do
    begin
      Artefact := TEquipment(Artefacts[I]);
      if ((Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 50)) and (Artefact.EquippedFlag <> 0) then
      begin
        Cost := Artefact.CalculateRepairCost;
        if Money > Cost then SetMoney(Money - Cost);
        Artefact.Repair;
      end;
    end;
end;
{ @end $756A0C }

{ @routine $756B84 TRanger_RelationToNonRanger }
function TRanger.RelationToNonRanger(Ship: TShip): Byte;
begin
  if (CurrentStanding = ssCoalitionActive) and (Ship.CurrentStanding = ssPirateMilitary) then
  begin
    Result := 0;
    Exit;
  end;
  if (CurrentStanding = ssPirateActive) and (Ship.CurrentStanding = ssCoalitionMilitary) then
  begin
    Result := 0;
    Exit;
  end;
  case Ship.TypeId of
    stTransport:
      if PreferredCareer = rcTrader then Result := 90
      else if PreferredCareer = rcWarrior then
        Result := OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)]
      else
        Result := OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)] shr 1;
    stPirate:
      begin
        if PreferredCareer = rcPirate then
          Result := OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)]
        else
          Result := OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ship.PilotRace)] shr 1;
        if (Ship.OwnerId = Byte(oiPirate)) and (Galaxy.CoalitionDefeatedTurn = 0) then
          if (Cardinal(Galaxy.GetFactionControlPercent(Ord(sfPirates))) * 2 > Cardinal(Galaxy.GetFactionControlPercent(Ord(sfCoalition))) * 3) and
            (Galaxy.GetFactionControlPercent(Ord(sfPirates)) > 7) then Result := 10;
      end;
    stWarrior: Result := Byte((Ship as TWarrior).HomePlanet.RangerRelations[Galaxy.Rangers.IndexOf(Self)]);
    Ord(rstDominion):
      if PreferredCareer = rcTrader then Result := 40
      else if PreferredCareer = rcWarrior then Result := 45
      else Result := 50;
  else
    if Ship.TypeId in [stKling, stTranclucator] then Result := 50
    else Result := 100;
  end;
end;
{ @end $756B84 }

{ @routine $756DF0 TRanger_RelationToRanger }
function TRanger.RelationToRanger(Ranger: Pointer): Byte;
begin
  if IsFemaleHumanPilot and TShip(Ranger).IsFemaleHumanPilot then Result := 100
  else Result := Byte(RangerRelations[Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)]);
end;
{ @end $756DF0 }

{ @routine $756E54 TRanger_ChangeRelationToRanger }
procedure TRanger.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var
  Relation: Byte;
  NewRelation, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(RangerRelations[Index]);
  if (TShip(Ranger).GetEffectiveSkillLevel(psCharisma) > 0) and (Amount > 0) then
    Inc(Amount, Round(Amount * (TShip(Ranger).GetEffectiveSkillLevel(psCharisma)) * 0.2));
  NewRelation := Relation + Amount;
  if NewRelation < 0 then Relation := 0
  else if NewRelation > 100 then Relation := 100
  else Relation := NewRelation;
  RangerRelations[Index] := Pointer(Relation);
  if (PartnerShip = Ranger) and (Relation <= 30) then
  begin
    CheckForPartnershipBreakup;
    Relation := Byte(RangerRelations[Index]);
  end;
  if (Relation < 10) and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then
  begin
    if RandomIntRange(0, 100) = 0 then SysUtils.Sleep(1);
    if (Byte(RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then
      GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;
{ @end $756E54 }

{ @routine $756FE0 TRanger_ReactToAttack }
procedure TRanger.ReactToAttack(Attacker: TShip);
begin
  EnemyShip := Attacker;
  if Attacker.TypeId = stRanger then
    ChangeRelationToRanger(Attacker, Round(RemapClamped(GetHull.HullPoints, GetHull.Weight * 0.5, GetHull.Weight, -80, -20)));
  if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = stRanger) then
    ChangeRelationToRanger(Attacker.PartnerShip, Round(RemapClamped(GetHull.HullPoints, GetHull.Weight * 0.5, GetHull.Weight, -80, -20)));
  if (Attacker is TTranclucator) and (TTranclucator(Attacker).OwnerShip <> nil) and (TTranclucator(Attacker).OwnerShip.TypeId = stRanger) then
    ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, Round(RemapClamped(GetHull.HullPoints, GetHull.Weight * 0.5, GetHull.Weight, -80, -20)));
end;
{ @end $756FE0 }

{ @routine $757188 TRanger_RecomputeFearState }
function TRanger.RecomputeFearState: Boolean;
var
  I, AttackerCount: Integer;
  Ship: TShip;
  HullThreshold, Threat: Double;
begin
  if Galaxy.SpecialSimulationMode <> 0 then
  begin
    Result := False;
    InFear := Result;
    Exit;
  end;
  if (CurrentPlanet <> nil) or (DockedTo <> nil) then
  begin
    Result := (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and (EnemyShip.Strength > Strength);
    InFear := Result;
    Exit;
  end;
  if HasNoUsableWeapons and (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then
  begin
    Result := True;
    InFear := True;
    Exit;
  end;
  Result := (GetHull.Weight * (1 - RemapClamped(Aggression, 0, 100, 0.7, 0.9)) > GetHull.HullPoints) or
    ((EnemyShip <> nil) and ((EnemyShip.OrderTarget = Self) or (GetPlayer = EnemyShip)) and AcceptsRansomDemandFrom(EnemyShip));
  if not Result then
  begin
    Threat := 0;
    AttackerCount := 0;
    HullThreshold := RemapClamped(GetHull.HullPoints, 50, GetHull.Weight, 0, 3);
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if Ship.InNormalSpace and (Ship <> Self) then
      begin
        if Ship = EnemyShip then
        begin
          Threat := Threat + Ship.ChanceToWin(Self);
          Inc(AttackerCount);
        end
        else if ((((Ship.EnemyShip = Self) and (Ship.OrderTarget = Self)) or (Ship.OwnerId = Byte(oiDominator))) and
          (PointDistanceSquared(Position, Ship.Position) < 1440000)) or
          ((Ship.RelationToShip(Self) < 10) and (PointDistanceSquared(Position, Ship.Position) < 360000)) then
        begin
          Inc(AttackerCount);
          Threat := Threat + Ship.ChanceToWin(Self);
          if (EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar) or EnemyShip.IsOutsideStarSpace then EnemyShip := Ship
          else if (EnemyShip <> Ship) and (OrderTarget <> EnemyShip) then
            if PointDistanceSquared(EnemyShip.Position, Position) > PointDistanceSquared(Ship.Position, Position) then EnemyShip := Ship;
        end;
      end;
    end;
    if Threat + (AttackerCount - 1) * Threat * 0.3 > HullThreshold + RemapClamped(Aggression, 0, 100, 0, 1) then Result := True;
  end;
  if (GetPlayer = PartnerShip) and (GetHullIntegrityPercent > 35) and (GetPlayer.CurrentStar = CurrentStar) and
    GetPlayer.InNormalSpace and OrderAbsolute then Result := False;
  InFear := Result;
end;
{ @end $757188 }

{ @routine $7575F8 TRanger_TryOfferRansomToPursuer }
procedure TRanger.TryOfferRansomToPursuer;
var
  Text: WideString;
  Amount: Integer;
  MaximumOffer, MinimumOffer: Single;
  Accepted: Boolean;
  OtherShip: TShip;
begin
  if InNormalSpace and (EnemyShip <> nil) and (EnemyShip.OrderTarget = Self) and (EnemyShip.TruceShip <> Self) and
    (Money > 100) and not CanEscapePursuer(EnemyShip) and not (EnemyShip.TypeId in NonNegotiatingShipTypes) then
    if (PointDistanceSquared(Position, EnemyShip.Position) <= EnemyShip.GetMaxWeaponRange * EnemyShip.GetMaxWeaponRange) and
      (((Galaxy.CurrentTurn * EnemyShip.Id mod 3 = 0) and (NextRandomUnitFloat(RandomState) > 0.2)) or
      (GetHullIntegrityPercent < 20)) and not NoTalk and not EnemyShip.NoTalk then
    begin
      MaximumOffer := Min(Money, GetWealthScaledAmount(1));
      MinimumOffer := Min(Money, (GetWealthScaledAmount(4) + EnemyShip.GetWealthScaledAmount(4)) * 0.5);
      Amount := Round(Max(100, RemapClamped(GetHull.HullPoints, 0, GetHull.Weight, MinimumOffer, MaximumOffer)));
      OtherShip := EnemyShip;
      Accepted := OtherShip.BuildTrucePaymentResponse(Self, Text, Amount);
      if (GetPlayer <> OtherShip) and (GetPlayer.CurrentStar = CurrentStar) then NotifyTruceOffer(OtherShip, Text, Amount);
      if Accepted and RecomputeFearState then TryOfferRansomToPursuer;
    end;
end;
{ @end $7575F8 }

{ @routine $757930 TRanger_AcceptsRansomDemandFrom }
function TRanger.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
var
  LicenseFactor: Single;
begin
  if (GetPlayer = Ship) and (GetPlayer.PirateLicenseTicks > 0) then LicenseFactor := 1.15
  else LicenseFactor := 1;
  Result := ((80 * LicenseFactor > GetHullIntegrityPercent) and
    (1 * LicenseFactor > ChanceToWin(Ship) + Aggression * 0.005)) or (0.2 * LicenseFactor > ChanceToWin(Ship));
end;
{ @end $757930 }

{ @routine $757A08 TRanger_ApplyAttackReputationChanges }
procedure TRanger.ApplyAttackReputationChanges(Victim: TShip; Severity: Double);
var
  I, J, LastStar: Integer;
  Effect: Single;
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;
begin
  if (GetPlayer = Self) and (Victim.CurrentStanding <> ssCustom) then
  begin
    if Victim is TKling then
    begin
      if (Victim as TKling).KlingType = ktBertor then TrySetAchievementProgress('BERTORSLAYER', GetPlayer.DominatorKillsByType[6]);
      case (Victim as TKling).DominatorSeries of
        dsBlazer: TryAddAchievementProgress('REDKILLS', 1);
        dsTerron: TryAddAchievementProgress('GREENKILLS', 1);
        dsKeller: TryAddAchievementProgress('BLUEKILLS', 1);
      end;
    end;
    if Victim.TypeId = stWarrior then TryAddAchievementProgress('WARRIORKILLS', 1);
    if Victim.TypeId = Byte(rstPirateBase) then TryAddAchievementProgress('COUNTERTERRORIST', 1)
    else if (Victim.TypeId = Byte(rstMedicalBase)) and (CurrentStar.ControlFaction <> sfPirates) then TryAddAchievementProgress('TERRORIST', 1)
    else if Victim.TypeId in [Ord(rstRangerCenter), Ord(rstMilitaryBase)..Ord(rstBusinessCenter)] then TryAddAchievementProgress('TERRORIST', 1);
  end;
  if Self = Victim then Exit;
  if Victim.HasScriptBindings then Exit;
  if GetPlayer = Self then LastStar := Galaxy.Stars.Count - 1
  else LastStar := Galaxy.Stars.Count div 3;
  for I := 0 to LastStar do
  begin
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if (Star.ControlFaction <> sfDominators) or (Star.Battle <> 0) then
    begin
      Effect := RemapClamped(I, 0, LastStar, 0.5, 0.05) * Severity;
      if (Victim.OwnerId = Byte(oiDominator)) or (Victim.OwnerId = Byte(oiPirate)) then Effect := 0.05 * Effect
      else if GetPlayer <> Self then Effect := 0.1 * Effect;
      if Victim is TRuins then Effect := Effect * 3;
      if (Victim is TWarrior) and ((Victim as TWarrior).WarriorType = wtFlagship) then Effect := Effect * 2;
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[J]);
        if (Ship <> Victim) and not Ship.IsHullDestroyed and (Ship.TypeId in [stRanger..stPirate]) then
          Ship.ChangeRelationToRanger(Self, Round((50 - Ship.RelationToShip(Victim)) * Effect));
      end;
      if Star.Status.CustomFaction = '' then
        for J := 0 to Star.Planets.Count - 1 do
        begin
          Planet := TPlanet(Star.Planets[J]);
          if Planet.IsCoalitionOwned then
            Planet.ChangeRelationToRanger(Self, Round((50 - Planet.RelationToShip(Victim)) * Effect));
        end;
    end;
  end;
  Effect := Severity * 0.5;
  if Victim.CurrentStar.ControlFaction <> sfPirates then Effect := Effect * 0.5;
  if Victim is TRuins then Effect := Effect * 3
  else if Victim.OwnerId <> Byte(oiPirate) then Effect := 0.05 * Effect;
  if GetPlayer <> Self then Effect := 0.1 * Effect;
  if (Galaxy.CoalitionDefeatedTurn <> 0) and (CurrentStar.Battle = 0) then Effect := 0.2 * Effect;
  if MainPiratePlanet <> nil then
    MainPiratePlanet.ChangeRelationToRanger(Self, Round((50 - MainPiratePlanet.RelationToShip(Victim)) * Effect));
  if (Victim.HomePlanet <> nil) and Victim.HomePlanet.IsCoalitionOwned and (Victim.HomePlanet.CurrentStar.Status.CustomFaction = '') then
    Victim.HomePlanet.ChangeRelationToRanger(Self, Round((50 - Victim.HomePlanet.RelationToShip(Victim)) / 2));
end;
{ @end $757A08 }

{ @routine $757FE8 TRanger_ApplyExtortionReputationPenalty }
procedure TRanger.ApplyExtortionReputationPenalty(Victim: TShip);
var
  I, J, LastStar, Activity: Integer;
  Effect: Single;
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;
begin
  if GetPlayer = Self then Activity := 8 else Activity := 1;
  AddPirateCareerActivity(Activity);
  LastStar := Galaxy.Stars.Count div 3;
  for I := 0 to LastStar do
  begin
    Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
    if ((Star.ControlFaction = sfCoalition) or (Star.Battle <> 0)) and ((Star.Status.CustomFaction = '') or (Star.Battle <> 0)) then
    begin
      Effect := RemapClamped(I, 0, LastStar, 0.3, 0.05);
      if GetPlayer <> Self then Effect := 0.1 * Effect;
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[J]);
        if (Ship.TypeId in [stRanger..stPirate]) and ((I <> 0) or ((Ship <> Self) and (Ship <> Victim))) then
          Ship.ChangeRelationToRanger(Self, Round((50 - Ship.RelationToShip(Victim)) * Effect));
      end;
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := TPlanet(Star.Planets[J]);
        if Planet.IsCoalitionOwned then
          Planet.ChangeRelationToRanger(Self, Round((50 - Planet.RelationToShip(Victim)) * Effect));
      end;
    end;
  end;
  if MainPiratePlanet <> nil then MainPiratePlanet.ChangeRelationToRanger(Self, 1);
end;
{ @end $757FE8 }

{ @routine $758210 TRanger_TryRecruitWingman }
procedure TRanger.TryRecruitWingman;
var
  I, Offers, MaxDistance, Amount: Integer;
  Ship: TShip;
  Ranger: TRanger;
  Text: WideString;
begin
  if (Integer(GetEffectiveSkillLevel(psLeadership)) > CountWingmen) and (PartnerShip = nil) and
    (Wealth div 20 <= Money) and (Wealth >= Galaxy.AverageRangerCapital * 1.1) and
    (Strength >= 1.1 * Galaxy.AverageRangerStrength) and not HasScriptControl then
  begin
    MaxDistance := Max(GetRadarRange * GetRadarRange, 250000);
    Offers := 0;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if (Ship.TypeId = stRanger) and Ship.InNormalSpace and ((Ship.OwnerId = Byte(oiPirate)) = (OwnerId = Byte(oiPirate))) and not Ship.HasScriptControl then
      begin
        Ranger := Ship as TRanger;
        if (Ranger <> Self) and (Ranger.PartnerShip <> Self) and (Ranger <> EnemyShip) and (Ranger.EnemyShip <> Self) and
          (GetPlayer <> Ranger) and (MaxDistance >= PointDistanceSquared(Position, Ranger.Position)) and
          (Ranger.RelationToShip(Self) >= 30) and ((NextRandomUnitFloat(RandomState) >= 0.7) or (Rank >= Ranger.Rank)) and
          (PlaceInRating <= Ranger.PlaceInRating) then
        begin
          Amount := Min(Round(Money * 0.7), Ranger.Wealth div 8);
          if not Ranger.BuildPartnershipOfferResponse(Self, Text, Amount) and (NextRandomUnitFloat(RandomState) > 0.1) then Continue;
          if (Ranger.AcceptPartnershipOffer(Self, Text, Amount) or (NextRandomUnitFloat(RandomState) > 0.8)) and
            (GetPlayer.CurrentStar = CurrentStar) then
          begin
            NotifyPartnershipOffer(Ship, Text, Amount);
            Break;
          end;
          Inc(Offers);
          if Offers = 3 then Break;
        end;
      end;
    end;
  end;
end;
{ @end $758210 }

{ @routine $7585D0 TRanger_CheckForPartnershipBreakup }
procedure TRanger.CheckForPartnershipBreakup;
var
  Leader: TShip;
begin
  if PartnerShip = nil then Exit;
  if PartnershipDaysRemaining < 1 then
  begin
    if (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then
    begin
      Leader := PartnerShip;
      if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
      PartnerShip := nil;
      NotifyPartnershipExpired(Leader);
    end;
  end
  else if RelationToShip(PartnerShip) < 30 then
  begin
    if (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then
    begin
      Leader := PartnerShip;
      if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
      PartnerShip := nil;
      NotifyPartnerBreak(Leader);
    end;
  end
  else if (EnemyShip <> nil) and (EnemyShip.PartnerShip <> nil) and (EnemyShip.PartnerShip = PartnerShip) and
    (PartnerShip.CurrentStar = CurrentStar) and InNormalSpace and PartnerShip.InNormalSpace and CanContactShip(PartnerShip) then
  begin
    Leader := PartnerShip;
    if (Order = soFollowShip) and (OrderTarget = PartnerShip) then OrderNone(False);
    PartnerShip := nil;
    NotifyPartnerRebellion(Leader);
  end;
end;
{ @end $7585D0 }

{ @routine $758840 TRanger_TrustsAttackRequester }
function TRanger.TrustsAttackRequester(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) >= 30;
end;
{ @end $758840 }

{ @routine $758864 TRanger_EvaluateAllyRelationAndStrength }
function TRanger.EvaluateAllyRelationAndStrength(Ship: TShip): Boolean;
begin
  Result := RelationToShip(Ship) +
    RemapClamped(Ship.Strength, 0.9 * Strength, Strength * 3.0, 0.0, 100.0) > 120.0;
end;
{ @end $758864 }

{ @routine $758D30 TRanger_ProcessPrisonAndHostileCheck }
function TRanger.ProcessPrisonAndHostileCheck: Boolean;
var
  I: Integer;
  Warrior: TShip;

  // @nested $758900 Imprison
  procedure Imprison; // @addr 0x758900 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ranger -4, blocked-turn output -5. Female human pilots have their resulting prison term cleared."
  var
    I: Integer;
    Ship: TShip;
    Text: WideString;
  begin
    PrisonTermRemaining := Round(RemapClamped(CareerStatus[Ord(rcPirate)], 0.0, 100.0, 61.0, 140.0));
    CurrentSystemKills.Normal := 0;
    CurrentSystemKills.Pirate := 0;
    if CurrentPlanet.OwnerId = Byte(oiPirate) then
    begin
      if MainPiratePlanet <> nil then MainPiratePlanet.ChangeRelationToRanger(Self, 80)
      else CurrentPlanet.ChangeRelationToRanger(Self, 80);
    end
    else
    begin
      CurrentPlanet.ChangeRelationToRanger(Self, 80);
      ChangePlanetRelations(nil, rcmRaiseTo, 45, TOwnerMask(PlanetOwnerMasks.Coalition));
    end;
    Result := True;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if (Ship.TypeId = stWarrior) and (Self = Ship.EnemyShip) then
      begin
        Ship.EnemyShip := nil;
        if Self = Ship.OrderTarget then Ship.OrderNone(False);
      end;
    end;
    if IsFemaleHumanPilot then PrisonTermRemaining := 0
    else
    begin
      Text := PickLocalizedTextVariant('GalaxyNews.GoToPrison.' + GetTypeNameKey, Seed + Cardinal(Galaxy.CurrentTurn div 10));
      ReplaceTextToken(Text, '<Star>', CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Planet>', CurrentPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Month>', IntToStr(Cardinal(PrisonTermRemaining) div 30), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Name>', GetName, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FullName>', GetFullName(' '), '<color=255,240,100>');
      if (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and (Galaxy.CoalitionDefeatedTurn = 0) then
        Galaxy.AddPlanetNewsWithPlayerBubble(40, Text)
      else Galaxy.AddPlanetNews(40, Text);
    end;
  end;

begin
  Result := False;
  if CurrentPlanet <> nil then
  begin
    if Cardinal(PrisonTermRemaining) > 0 then
    begin
      if (CurrentStar.Battle <> 0) and (Galaxy.CurrentTurn - CurrentStar.LastDominatorPresenceTurn <= 1) then
      begin
        PrisonTermRemaining := 0;
        Result := False;
        RefreshCurrentStanding;
      end
      else
      begin
        Dec(PrisonTermRemaining);
        if PrisonTermRemaining = 0 then
        begin
          Result := False;
          RefreshCurrentStanding;
        end
        else Result := True;
      end;
    end
    else if CurrentPlanet.GetRelationLevelToShip(Self) = rlHostile then
    begin
      Imprison;
      RefreshCurrentStanding;
    end
    else
      for I := 0 to CurrentPlanet.Warriors.Count - 1 do
      begin
        Warrior := TShip(CurrentPlanet.Warriors[I]);
        if Warrior.EnemyShip = Self then
        begin
          Imprison;
          RefreshCurrentStanding;
          Break;
        end;
      end;
  end;
end;
{ @end $758D30 }

{ @routine $758E5C TRanger_ChangeGlobalRelations }
procedure TRanger.ChangeGlobalRelations(Scope: TObject; Mode: TRelationChangeMode; Amount: Byte; HullTypeMask: THullShipTypeMask; OwnerMask: TOwnerMask);
begin
  ChangeShipRelations(Scope, Mode, Amount, HullTypeMask, OwnerMask);
  ChangePlanetRelations(Scope, Mode, Amount, OwnerMask);
end;
{ @end $758E5C }

{ @routine $758FD4 TRanger_ChangeShipRelations }
procedure TRanger.ChangeShipRelations(Scope: TObject; Mode: TRelationChangeMode; Amount: Byte; HullTypeMask: THullShipTypeMask; OwnerMask: TOwnerMask);
var Previous: Byte; Ship: TShip; RangerIndex, I, J: Integer; Star: TStar;
  // @nested $758EA4 ApplyToShip
  procedure ApplyToShip; // @addr 0x758EA4 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; mode -1, previous relation -2, target ship -8, ranger index -12, ranger -16, amount +16."
  begin
    case Mode of
      rcmCapAt: if Previous > Amount then Ship.RangerRelations[RangerIndex] := Pointer(Amount);
      rcmRaiseTo: if Previous < Amount then Ship.RangerRelations[RangerIndex] := Pointer(Amount);
      rcmIncrease: Ship.ChangeRelationToRanger(Self, Amount);
      rcmDecrease: Ship.ChangeRelationToRanger(Self, -Amount);
      rcmDecreaseWithFloor20: if Previous > 20 then
        if Previous - Amount < 20 then Ship.RangerRelations[RangerIndex] := Pointer(20)
        else Ship.ChangeRelationToRanger(Self, -Amount);
    end;
    Exit;
  end;
begin
  RangerIndex := Galaxy.Rangers.IndexOf(Self);
  if Scope is TShip then begin
    Ship := Scope as TShip;
    if (ShipToHullType(Ship) in HullTypeMask) and (Ship.OwnerId in OwnerMask) then begin
      Previous := Byte(Ship.RangerRelations[RangerIndex]);
      ApplyToShip;
    end;
  end
  else for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if Scope is TConstellation then
      if (Scope as TConstellation) <> Star.Constellation then Continue;
    if Scope is TStar then
      if (Scope as TStar) <> Star then Continue;
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := Star.Ships[J];
      if (Ship.ScriptShip <> nil) and Ship.HasScriptControl then Continue;
      if (ShipToHullType(Ship) in HullTypeMask) and (Ship.OwnerId in OwnerMask) and
        (Ship.RangerRelations.Count >= 1) then begin
        Previous := Byte(Ship.RangerRelations[RangerIndex]);
        ApplyToShip;
      end;
    end;
  end;
end;
{ @end $758FD4 }

{ @routine $7591B0 TRanger_ChangePlanetRelations }
procedure TRanger.ChangePlanetRelations(Scope: TObject; Mode: TRelationChangeMode; Amount: Byte; OwnerMask: TOwnerMask);
var
  I, J, RangerIndex: Integer;
  Star: TStar;
  Planet: TPlanet;
  Previous: Byte;
  Event: TGalaxyEvent;
begin
  RangerIndex := Galaxy.Rangers.IndexOf(Self);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    if Scope is TConstellation then
      if (Scope as TConstellation) <> Star.Constellation then Continue;
    if Scope is TStar then
      if (Scope as TStar) <> Star then Continue;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := TPlanet(Star.Planets[J]);
      if (Planet.OwnerId in OwnerMask) and Planet.IsCoalitionOwned then
      begin
        if Scope is TPlanet then
          if (Scope as TPlanet) <> Planet then Continue;
        Previous := Byte(Planet.RangerRelations[RangerIndex]);
        case Mode of
          rcmCapAt: if Previous > Amount then Planet.RangerRelations[RangerIndex] := Pointer(Amount);
          rcmRaiseTo: if Previous < Amount then Planet.RangerRelations[RangerIndex] := Pointer(Amount);
          rcmIncrease: Planet.ChangeRelationToRanger(Self, Amount);
          rcmDecrease: Planet.ChangeRelationToRanger(Self, -Amount);
          rcmDecreaseWithFloor20:
            if Previous > 20 then
              if Previous - Amount < 20 then Planet.RangerRelations[RangerIndex] := Pointer(20)
              else Planet.ChangeRelationToRanger(Self, -Amount);
        end;
      end;
    end;
  end;
  if GetPlayer = Self then
  begin
    GetPlayer.AchievementStats.CheckHaterAchievement;
    if Scope = nil then
    begin
      Event := AddGalaxyEvent('GlobalChangeToPlayerReputation');
      Event.AddData(Ord(Mode));
      Event.AddData(Amount);
      Event.AddData(Byte(OwnerMask));
    end;
  end;
end;
{ @end $7591B0 }

{ @routine $759480 TRanger_GlobalRelationsShips }
function TRanger.GlobalRelationsShips(Scope: TObject; HullTypeMask: Word; OwnerMask: Byte): Byte;
var I, J, RangerIndex, Total, Count: Integer; Star: TStar; Ship: TShip; Previous: Byte;
begin
  if Scope is TShip then begin
    Result := (Scope as TShip).RelationToRanger(Self);
    Exit;
  end;
  RangerIndex := Galaxy.Rangers.IndexOf(Self);
  Total := 0;
  Count := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if Scope is TConstellation then
      if (Scope as TConstellation) <> Star.Constellation then Continue;
    if Scope is TStar then
      if (Scope as TStar) <> Star then Continue;
    for J := 0 to Star.Ships.Count - 1 do begin
      Ship := Star.Ships[J];
      if (ShipToHullType(Ship) in THullShipTypeMask(HullTypeMask)) and (Ship.OwnerId in TOwnerMask(OwnerMask)) then begin
        Inc(Count);
        Previous := Byte(Ship.RangerRelations[RangerIndex]);
        Inc(Total, Previous);
      end;
    end;
  end;
  if Count <> 0 then Result := Total div Count else Result := 50;
end;
{ @end $759480 }

{ @routine $759610 TRanger_GlobalRelationsPlanets }
function TRanger.GlobalRelationsPlanets(Scope: TObject; OwnerMask: Byte): Byte;
var I, J, RangerIndex, Total, Count: Integer; Star: TStar; Planet: TPlanet; Previous: Byte;
begin
  RangerIndex := Galaxy.Rangers.IndexOf(Self);
  Total := 0;
  Count := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do begin
    Star := Galaxy.Stars[I];
    if Scope is TConstellation then
      if (Scope as TConstellation) <> Star.Constellation then Continue;
    if Scope is TStar then
      if (Scope as TStar) <> Star then Continue;
    for J := 0 to Star.Planets.Count - 1 do begin
      Planet := Star.Planets[J];
      if (Planet.OwnerId in TOwnerMask(OwnerMask)) and Planet.IsCoalitionOwned then begin
        Inc(Count);
        Previous := Byte(Planet.RangerRelations[RangerIndex]);
        Inc(Total, Previous);
      end;
    end;
  end;
  if Count <> 0 then Result := Total div Count else Result := 50;
end;
{ @end $759610 }

{ @routine $759760 TRanger_AssignWeaponTargetsInStar }
procedure TRanger.AssignWeaponTargetsInStar;
var
  I, J, AssignedCount: Integer;
  Ship: TShip;
  Weapon: TWeapon;
  Asteroid: TAsteroid;
  Distance: Single;
  Missile: TMissile;
begin
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    Weapon.Target := nil;
  end;
  AssignedCount := 0;
  if CurrentStar.Battle <> 0 then
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if (Ship.OwnerId = Byte(oiDominator)) and Ship.InNormalSpace then
      begin
    for J := 1 to WeaponCount do
    begin
      Weapon := Weapons[J];
      if ((not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or (Weapon.Ammo <> 0)) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)) then
        begin
          Weapon.Target := Ship;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
        end;
    end;
      end;
    end;
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) and EnemyShip.InNormalSpace then
  begin
    for J := 1 to WeaponCount do
    begin
      Weapon := Weapons[J];
      if ((not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or (Weapon.Ammo <> 0)) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, EnemyShip.Position) <= Sqr(GetWeaponRange(Weapon)) then
        begin
          Weapon.Target := EnemyShip;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
        end;
    end;
  end;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if not Ship.IsOutsideStarSpace and (Ship <> Self) and ((RelationToShip(Ship) < 10) or (Ship = EnemyShip) or (Ship.EnemyShip = Self)) and
      (Ship.LiberationGroup = nil) and (TruceShip <> Ship) and ((GetPlayer <> Ship) or (GetPlayer.TruceShip <> Self)) then
    begin
      { Native can replace an existing weapon target in this pass. }
    for J := 1 to WeaponCount do
    begin
      Weapon := Weapons[J];
      if ((not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or (Weapon.Ammo <> 0)) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, Ship.Position) <= Sqr(GetWeaponRange(Weapon)) then
        begin
          Weapon.Target := Ship;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
        end;
    end;
    end;
  end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do
  begin
    Missile := TMissile(CurrentStar.Missiles[I]);
    if (Missile.Target = Self) and (Missile.OwnerShip <> Self) then
    begin
    for J := 1 to WeaponCount do
    begin
      Weapon := Weapons[J];
      if not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket]) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, Missile.Position) <= Sqr(GetWeaponRange(Weapon)) then
        begin
          Weapon.Target := Missile;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
          Break;
        end;
    end;
    end;
  end;
  if IsEquipmentUsable(GetCargoHook) and not OrderAbsolute then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do
    begin
      Asteroid := TAsteroid(CurrentStar.Asteroids[I]);
      if Asteroid.MineralCount <= CargoFreeSpace then
      begin
        Distance := PointDistanceSquared(Position, Asteroid.Position);
        if Distance <= 1000000 then
        begin
    for J := 1 to WeaponCount do
    begin
      Weapon := Weapons[J];
      if not (Weapon.GetWeaponInfo.ShotType in [wstAreaDamage..wstRocket]) and IsEquipmentUsable(Weapon) then
        if Distance <= Sqr(GetWeaponRange(Weapon)) then
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
  if (GetPlayer <> nil) and (GetPlayer.CurrentStar = CurrentStar) and GetPlayer.InNormalSpace and GetPlayer.ChameleonActive and
    IsPlayerChameleonEffectiveAgainstSelf then
  begin
    for J := 1 to WeaponCount do
    begin
      Weapon := Weapons[J];
      if ((not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo, wstMissile, wstRocket])) or (Weapon.Ammo <> 0)) and (Weapon.Target = nil) and IsEquipmentUsable(Weapon) then
        if PointDistanceSquared(Position, GetPlayer.Position) <= Sqr(GetWeaponRange(Weapon)) then
        begin
          Weapon.Target := GetPlayer;
          Inc(AssignedCount);
          if WeaponCount = AssignedCount then Exit;
        end;
    end;
  end;
end;
{ @end $759760 }

{ @routine $759EAC TRanger_SelectEnemyShipInStar }
procedure TRanger.SelectEnemyShipInStar;
var
  I: Integer;
  Ship, PreviousEnemy: TShip;
  Chance, BestChance: Double;
  HasPriorityTarget: Boolean;
begin
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then Exit;
  if UsableWeaponCount = 0 then Exit;
  if (PartnerShip <> nil) and (PartnerShip.EnemyShip <> nil) and
    ((PartnerShip.OrderTarget = PartnerShip.EnemyShip) or (PartnerShip.EnemyShip.OrderTarget = PartnerShip)) and
    (not IsFemaleHumanPilot or not PartnerShip.EnemyShip.IsFemaleHumanPilot) then
  begin
    EnemyShip := PartnerShip.EnemyShip;
    Exit;
  end;
  if PreferredCareer = rcPirate then
    if (GetPlayer.QuestTargetDefendShip <> nil) and (GetPlayer.QuestTargetDefendShip.CurrentStar = CurrentStar) and
      (GetPlayer.QuestTargetDefendShip <> Self) and GetPlayer.QuestTargetDefendShip.InNormalSpace and
      (GetPlayer.QuestTargetDefendShip <> TruceShip) and (GetPlayer.QuestTargetDefendShip.ScriptShip = nil) then
    begin
      EnemyShip := GetPlayer.QuestTargetDefendShip;
      AssignWeaponTargetsInStar;
      Exit;
    end;
  PreviousEnemy := EnemyShip;
  EnemyShip := nil;
  BestChance := 0;
  HasPriorityTarget := False;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if HasPriorityTarget and (Ship.TargetingRestriction <> 6) then Continue;
    if (Ship = Self) or Ship.IsOutsideStarSpace or (TruceShip = Ship) or (Ship.TargetingRestriction in [1..4]) or
      (IsFemaleHumanPilot and Ship.IsFemaleHumanPilot) or ((Ship.PartnerShip <> nil) and (Ship.PartnerShip.CurrentStar = CurrentStar)) or
      (Ship.LiberationGroup <> nil) then Continue;
    Chance := ChanceToWin(Ship);
    if (Ship.TargetingRestriction = 6) and (PreferredCareer = rcPirate) and not HasPriorityTarget then
    begin
      BestChance := Chance;
      HasPriorityTarget := True;
      EnemyShip := Ship;
      Continue;
    end;
    if Ship.OwnerId = Byte(oiDominator) then
    begin
      if (Chance < BestChance) and (NextRandomUnitFloat(RandomState) > 0.5) then Continue;
    end
    else
    begin
      if (Chance < BestChance) or ((Chance < 0.3) and (StrengthInBestRanger < 0.8)) then Continue;
      if (PreferredCareer = rcPirate) and (GetDesiredCargoFreeSpace <= CargoFreeSpace) and (GetCargoHook <> nil) then
      begin
        if NextRandomIntRange(0, 30, RandomState) + 60 < RelationToShip(Ship) then Continue;
        if (RelationToShip(Ship) >= 60) and ((Aggression * 0.01 + Chance < 2) or (NextRandomUnitFloat(RandomState) > 0.2)) then Continue;
      end
      else if (CurrentStar.Battle <> 0) or (RelationToShip(Ship) >= 10) then Continue;
      if ((Chance < 1) and not IsTargetStillPursuable(Ship)) or
        ((Ship.TypeId = stRanger) and (Chance < 0.9) and (GetPlayer <> Ship)) then Continue;
    end;
    EnemyShip := Ship;
    BestChance := Chance;
  end;
  if EnemyShip <> nil then
  begin
    if EnemyShip.TargetingRestriction = 6 then Exit;
    if not CanContactShip(EnemyShip) then Exit;
    if not TryExtortShip(EnemyShip) then
    begin
      AssignWeaponTargetsInStar;
      Exit;
    end;
  end;
  EnemyShip := PreviousEnemy;
end;
{ @end $759EAC }

{ @routine $75A3E0 TRanger_EngageEnemyShip }
procedure TRanger.EngageEnemyShip;
begin
  if Order = soFollowShip then OrderNone(False);
  if (EnemyShip <> nil) and (EnemyShip.CurrentStar = CurrentStar) then
    if EnemyShip.InNormalSpace then
    begin
      OrderFollowShip(EnemyShip, 1, False);
      if ChanceToWin(EnemyShip) < 0.8 then RequestAlliesAttackShip(EnemyShip);
    end
    else if (ChanceToWin(EnemyShip) > 3) and (GetHullIntegrityPercent > 70) and (EnemyShip.GetHullIntegrityPercent > 70) then
    begin
      if EnemyShip.CurrentPlanet <> nil then
      begin
        if (EnemyShip is TRanger) and (Cardinal((EnemyShip as TRanger).PrisonTermRemaining) > 0) then
        begin
          EnemyShip := nil;
          OrderNone(False);
          Exit;
        end;
        if (EnemyShip is TPirate) and (Cardinal((EnemyShip as TPirate).PrisonTermRemaining) > 0) then
        begin
          EnemyShip := nil;
          OrderNone(False);
          Exit;
        end;
        OrderMove(EnemyShip.CurrentPlanet.GetPosition, False);
      end
      else if EnemyShip.DockedTo <> nil then OrderMove(EnemyShip.DockedTo.Position, False);
    end;
end;
{ @end $75A3E0 }

{ @routine $75A5DC TRanger_ProcessCombatDialogue }
procedure TRanger.ProcessCombatDialogue;
begin
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and ((Integer(Seed) + Galaxy.CurrentTurn) mod 4 = 0) and
    not AcceptsRansomDemandFrom(EnemyShip) then TryExtortShip(EnemyShip);
  if (EnemyShip <> nil) and (OrderTarget = EnemyShip) and ((Integer(Seed) + Galaxy.CurrentTurn) mod 6 = 0) and
    (ChanceToWin(EnemyShip) < 1.1) and (GetHullIntegrityPercent > 30) then RequestAlliesAttackShip(EnemyShip);
end;
{ @end $75A5DC }

{ @routine $75A6DC TRanger_ReactToExtortionDemand }
procedure TRanger.ReactToExtortionDemand(Ranger: Pointer);
begin
  if (GetPlayer = Ranger) or (NextRandomUnitFloat(RandomState) < 0.05) then
  begin
    ChangeRelationToRanger(Ranger, -15);
    HomePlanet.ChangeRelationToRanger(Ranger, -5);
    (TObject(Ranger) as TRanger).AddPirateCareerActivity(2);
  end;
end;
{ @end $75A6DC }

{ @routine $75A9E0 TRanger_BuildMoneyExtortionResponse }
function TRanger.BuildMoneyExtortionResponse(OtherShip: TShip; var Response: WideString; DemandedAmount: Integer): Boolean;
var NextDemandTurn: Integer; LicenseFactor: Single;
  // @nested $75A758 AcceptMoneyDemand
  procedure AcceptMoneyDemand; // @addr 0x75A758 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; paying ranger -4, requester -8, amount +8."
  var Event: TGalaxyEvent;
  begin
    AddTraderCareerActivity(4);
    AbductedByPirateClan := False;
    if GetPlayer = OtherShip then begin
      LastPlayerExtortionTurn := Galaxy.CurrentTurn;
      Event := AddGalaxyEvent('PlayerExtortsMoney');
      Event.AddData(DemandedAmount);
      Event.AddData(TypeId);
      Event.AddData(CurrentStar.Id);
      Event.AddData(Id);
      Event.AddData(OwnerId);
      Event.AddTextData(GetName);
      Event.AddTextData(TypeNameOverrideKey);
      if GetPlayer.PirateLicenseTicks > 0 then begin
        GetPlayer.SetMoney(GetPlayer.Money + Round(DemandedAmount * 0.9));
        Inc(GetPlayer.PendingPirateLicenseCash, Round(DemandedAmount * 0.1));
        if GetPlayer.PendingPirateLicenseCash > 100000000 then GetPlayer.PendingPirateLicenseCash := 100000000;
      end else GetPlayer.SetMoney(GetPlayer.Money + DemandedAmount);
    end else OtherShip.SetMoney(OtherShip.Money + DemandedAmount);
    SetMoney(Money - DemandedAmount);
    OtherShip.TruceWithShip(Self);
    if OtherShip is TRanger then (OtherShip as TRanger).ApplyExtortionReputationPenalty(Self);
    if OtherShip.OwnerId = Byte(oiPirate) then TNormalShip(OtherShip).AddPirateRankPoints(2);
  end;
begin
  Result := False;
  if (GetPlayer = OtherShip) and (GetPlayer.PirateLicenseTicks > 0) then LicenseFactor := 1.15 else LicenseFactor := 1;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if ((GetPlayer <> OtherShip) or (PlayerAutomaticControl <> False)) and ((EnemyShip = nil) or (CurrentStar <> EnemyShip.CurrentStar)) then EnemyShip := OtherShip;
  if (GetPlayer = Self) and not PlayerAutomaticControl then begin
    if OtherShip.ShowPlayerDialogue(tkMoneyDemand, FormatText1(OtherShip.LookupTalkText('Talk.Money.Send'), '<color=255,240,100>', '<Money>', IntToStr(DemandedAmount)), DemandedAmount) <> 0 then begin
      AcceptMoneyDemand;
      Result := True;
      PlayerStar.InterruptLongTravel := True;
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, OtherShip, nil, 0);
    end;
  end
  else if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if not AcceptsRansomDemandFrom(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) then Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if DemandedAmount > RemapClamped(GetWinChancePercent(OtherShip) * LicenseFactor, 0, 100, GetWealthScaledAmount(4), GetWealthScaledAmount(2)) then
    Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'SumIsVeryBig', OtherShip)
  else if Money < DemandedAmount then Response := LookupVisibleTalkText('Talk.Money.AnswerNotMoney', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Money.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptMoneyDemand;
    Result := True;
  end;
end;
{ @end $75A9E0 }

{ @routine $75B280 TRanger_BuildCargoExtortionResponse }
function TRanger.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
var Forced: Boolean; NextDemandTurn: Integer;
  // @nested $75AF68 AcceptCargoDemand
  procedure AcceptCargoDemand; // @addr 0x75AF68 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; paying ranger -4, requester -8. Drops goods and can set the player pact flag."
  var Good: Byte; Pass, Count, TotalValue, LowValue, HighValue: Integer; Enough: Boolean; Divisor: Single; Event: TGalaxyEvent;
  begin
    AddTraderCareerActivity(4);
    AbductedByPirateClan := False;
    TotalValue := 0;
    Enough := False;
    LowValue := GetWealthScaledAmount(1);
    HighValue := GetWealthScaledAmount(4);
    for Pass := 1 to 3 do begin
      for Good := 0 to 7 do
        if CargoGoods[Good].Count > 0 then begin
          Divisor := RemapClamped(CargoGoods[Good].Count * GoodsMarket[Good].AveragePrice, LowValue, HighValue, 2, 8);
          Count := Max(Int64(1), Round(CargoGoods[Good].Count / Divisor));
          Inc(TotalValue, Count * GoodsMarket[Good].AveragePrice);
          DropGoodsIntoSpace(Good, Count);
          if TotalValue > HighValue then begin Enough := True; Break; end;
        end;
      if Enough then Break;
    end;
    OtherShip.TruceWithShip(Self);
    if GetPlayer = OtherShip then begin
      LastPlayerExtortionTurn := Galaxy.CurrentTurn;
      Event := AddGalaxyEvent('PlayerExtortsGoods');
      Event.AddData(TotalValue);
      Event.AddData(TypeId);
      Event.AddData(CurrentStar.Id);
      Event.AddData(Id);
      Event.AddData(OwnerId);
      Event.AddTextData(GetName);
      Event.AddTextData(TypeNameOverrideKey);
    end;
    if GetPlayer = OtherShip then PlayerExtortionPactActive := True;
    OtherShip.OrderMove(Position, True);
    if OtherShip is TRanger then (OtherShip as TRanger).ApplyExtortionReputationPenalty(Self);
    if OtherShip.OwnerId = Byte(oiPirate) then TNormalShip(OtherShip).AddPirateRankPoints(2);
  end;
begin
  Result := False;
  if OtherShip is TRanger then ReactToExtortionDemand(OtherShip);
  if ((GetPlayer <> OtherShip) or (PlayerAutomaticControl <> False)) and ((EnemyShip = nil) or (CurrentStar <> EnemyShip.CurrentStar)) then EnemyShip := OtherShip;
  if (GetPlayer = Self) and not PlayerAutomaticControl then begin
    if OtherShip.ShowPlayerDialogue(tkGoodsDemand, OtherShip.LookupTalkText('Talk.Goods.Send'), 0) <> 0 then begin
      AcceptCargoDemand;
      Result := True;
      PlayerStar.InterruptLongTravel := True;
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, OtherShip, nil, 0);
    end;
  end else begin
    Forced := (GetPlayer = OtherShip) and OtherShip.IsHealthEffectActive(14);
    NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Goods.WeAlreadyHavePact', OtherShip)
  else if not AcceptsRansomDemandFrom(OtherShip) and not Forced then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'No', OtherShip)
  else if CanEscapePursuer(OtherShip) and not Forced then Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'LongDistance', OtherShip)
  else if not HasCargoGoods then Response := LookupVisibleTalkText('Talk.Goods.AnswerNotGoods', OtherShip)
  else begin
    Response := LookupVisibleTalkText('Talk.Goods.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptCargoDemand;
    if GetPlayer = OtherShip then PlayerExtortionPactActive := True;
    Result := True;
  end;
  end;
end;
{ @end $75B280 }

{ @routine $75B964 TRanger_BuildTrucePaymentResponse }
function TRanger.BuildTrucePaymentResponse(OtherShip: TShip; var Response: WideString; OfferedAmount: Integer): Boolean;
var Text: WideString; NextDemandTurn: Integer;
  // @nested $75B6B8 AcceptTrucePayment
  procedure AcceptTrucePayment; // @addr 0x75B6B8 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; payer -4, receiving ranger -8, amount +8."
  var Event: TGalaxyEvent;
  begin
    OtherShip.SetMoney(OtherShip.Money - OfferedAmount);
    if GetPlayer = Self then begin
      Event := AddGalaxyEvent('PlayerAcceptsMoneyForTruce');
      Event.AddData(OfferedAmount);
      Event.AddData(OtherShip.TypeId);
      Event.AddData(OtherShip.CurrentStar.Id);
      Event.AddData(OtherShip.Id);
      Event.AddData(OtherShip.OwnerId);
      Event.AddTextData(OtherShip.GetName);
      Event.AddTextData(OtherShip.TypeNameOverrideKey);
      if (GetPlayer.PirateLicenseTicks > 0) and (OtherShip.TypeId <> stPirate) and
        ((OtherShip.TypeId <> stRanger) or (OtherShip.GetDominantCareer <> rcPirate)) then begin
        SetMoney(Money + Round(OfferedAmount * 0.9));
        Inc(GetPlayer.PendingPirateLicenseCash, Round(OfferedAmount * 0.1));
        if GetPlayer.PendingPirateLicenseCash > 100000000 then GetPlayer.PendingPirateLicenseCash := 100000000;
      end else SetMoney(Money + OfferedAmount);
    end else SetMoney(Money + OfferedAmount);
    if (OwnerId = Byte(oiPirate)) and (OtherShip is TRanger) then AddPirateRankPoints(2);
    if (OwnerId = Byte(oiPirate)) and (OtherShip is TTransport) then AddPirateRankPoints(1);
    TruceWithShip(OtherShip);
  end;
begin
  Result := False;
  NextDemandTurn := LastPlayerExtortionTurn + 30;
  if OtherShip is TRanger then (OtherShip as TRanger).AddTraderCareerActivity(1);
  if (GetPlayer = Self) and not PlayerAutomaticControl then begin
    if Cardinal(ReservedMessageCounter) < 7 then Exit;
    Text := OtherShip.LookupTalkText('Talk.Truce.' + OtherShip.GetTypeNameKey + 'Send');
    if OtherShip.ShowPlayerDialogue(tkTruceOffer, FormatText1(Text, '<color=255,240,100>', '<Money>', IntToStr(OfferedAmount)), 0) <> 0 then begin
      AcceptTrucePayment;
      Result := True;
      PlayerStar.InterruptLongTravel := True;
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, OtherShip, nil, 0);
    end;
  end
  else if OtherShip.TruceShip = Self then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and PlayerExtortionPactActive then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if (GetPlayer = OtherShip) and (Galaxy.CurrentTurn < NextDemandTurn) then Response := LookupVisibleTalkText('Talk.Truce.WeAlreadyHavePact', OtherShip)
  else if RecomputeFearState or ((ChanceToWin(OtherShip) < 1) and (GetHullIntegrityPercent < 40)) or (ChanceToWin(OtherShip) < 0.25) or
    (OfferedAmount > RemapClamped(GetWinChancePercent(OtherShip), 0, 100, GetWealthScaledAmount(1), GetWealthScaledAmount(3))) then begin
    Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'Ok', OtherShip);
    AcceptTrucePayment;
    Result := True;
  end else Response := LookupVisibleTalkText('Talk.Truce.' + GetTypeNameKey + 'No', OtherShip);
end;
{ @end $75B964 }

{ @routine $75BE84 TRanger_BuildAttackRequestResponse }
function TRanger.BuildAttackRequestResponse(Requester: TShip; var Response: WideString; Target: TShip): Boolean;
  // @nested $75BDAC AcceptAttackRequest
  procedure AcceptAttackRequest; // @addr 0x75BDAC @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ranger -4, requester -8, text output -12, Boolean output -13, target +8."
  begin
    Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Ok', Requester);
    SetJointAttackTarget(Requester, Target);
    Result := True;
  end;
begin
  Result := False;
  if Requester is TRanger then begin
    if Target.TypeId in [stRanger..stPirate] then Target.ChangeRelationToRanger(Requester, -20);
    if (Target.OwnerId = Byte(oiDominator)) or (Target.TypeId = stPirate) then (Requester as TRanger).AddWarriorCareerActivity(1)
    else (Requester as TRanger).AddPirateCareerActivity(8);
  end;
  if (GetPlayer = Self) and not PlayerAutomaticControl then begin
    if Requester.ShowPlayerDialogue(tkAttack, FormatText1(Requester.LookupTalkText('Talk.Attack.' + Requester.GetTypeNameKey + 'Send'),
      '<color=255,240,100>', '<Target>', Target.GetName + GetLocalObjectLink(Target, False)), 0) <> 0 then begin
      SetJointAttackTarget(Requester, Target);
      Result := True;
      PlayerStar.InterruptLongTravel := True;
      GetPlayer.ScriptItemsAct(satOnShipTalkedWithPlayer, Requester, nil, 0);
    end;
  end
  else if (PartnerShip = Requester) or ((OrderTarget = Target) and (GetRelationLevelToShip(Target) = rlHostile)) then AcceptAttackRequest
  else if TruceShip = Target then Response := FormatText1(LookupVisibleTalkText('Talk.Attack.WeAlreadyHavePact', Requester), '<color=255,240,100>', '<Target>', Target.GetName)
  else if ((RelationToShip(Target) >= 80) or ((RelationToShip(Target) >= 30) and (PreferredCareer <> rcPirate))) and (PartnerShip <> Requester) then begin
    if not (Target is TTranclucator) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriends', Requester)
    else if TTranclucator(Target).OwnerShip = Self then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsMyTranc', Requester)
    else if TTranclucator(Target).OwnerShip = Requester then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'ItsYourTranc', Requester)
    else Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'WeFriendsTranc', Requester);
  end else if AcceptsRansomDemandFrom(Target) or InFear then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Fear', Requester)
  else if not TrustsAttackRequester(Requester) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'Suspect', Requester)
  else if HasLockedOrFollowOrder and (PartnerShip <> Requester) then Response := LookupVisibleTalkText('Talk.Attack.' + GetTypeNameKey + 'HaveBusiness', Requester)
  else AcceptAttackRequest;
end;
{ @end $75BE84 }

{ @routine $75C4E4 TRanger_BuildPartnershipOfferResponse }
function TRanger.BuildPartnershipOfferResponse(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  Result := False;
  if RelationToShip(OtherShip) < 45 then Response := LookupVisibleTalkText('Talk.Partner.Suspect', OtherShip)
  else if PartnerShip <> nil then
    Response := FormatText1(LookupVisibleTalkText('Talk.Partner.AlreadyHavePartner', OtherShip), '<color=255,240,100>', '<Partner>', (PartnerShip as TRanger).Name)
  else if CountWingmen > 0 then Response := LookupVisibleTalkText('Talk.Partner.ILeader', OtherShip)
  else if (OtherShip is TRanger) and (Integer(OtherShip.GetEffectiveSkillLevel(psLeadership)) <= (OtherShip as TRanger).CountWingmen) then
    Response := LookupVisibleTalkText('Talk.Partner.NeedLeadership', OtherShip)
  else if (OtherShip is TNormalShip) and ((OtherShip as TNormalShip).Rank < Rank) then
    Response := LookupVisibleTalkText('Talk.Partner.YouNeedInMoreRank', OtherShip)
  else if CalculatePartnershipMonths(PaymentAmount, OtherShip) = 0 then Response := LookupVisibleTalkText('Talk.Partner.SmallMoney', OtherShip)
  else Result := True;
  Response := FormatText1(Response, '<color=255,240,100>', '<Ranger>', (OtherShip as TRanger).Name);
end;
{ @end $75C4E4 }

{ @routine $75C8D0 TRanger_AcceptPartnershipOffer }
function TRanger.AcceptPartnershipOffer(OtherShip: TShip; var Response: WideString; PaymentAmount: Integer): Boolean;
begin
  if BuildPartnershipOfferResponse(OtherShip, Response, PaymentAmount) then
  begin
    PartnershipDaysRemaining := 30 * CalculatePartnershipMonths(PaymentAmount, OtherShip);
    Response := FormatText2(LookupVisibleTalkText('Talk.Partner.Ok', OtherShip), '<color=255,240,100>',
      '<Month>', IntToStr(CalculatePartnershipMonths(PaymentAmount, OtherShip)), '<Ranger>', (OtherShip as TRanger).Name);
    PartnerShip := OtherShip;
    OrderAbsolute := False;
    Result := True;
    SetMoney(Money + PaymentAmount);
    OtherShip.SetMoney(OtherShip.Money - PaymentAmount);
    if GetPlayer = OtherShip then GetPlayer.AchievementStats.CheckMasterAchievement;
  end
  else Result := False;
end;
{ @end $75C8D0 }

{ @routine $75CAC0 TRanger_GetProgramName }
function TRanger.GetProgramName(ProgramIndex: Byte): WideString;
begin
  Result := LocalizedText('Programms.' + ProgramNames[ProgramIndex] + '.Name');
end;
{ @end $75CAC0 }

{ @routine $75CB64 TRanger_GetProgramInfoText }
function TRanger.GetProgramInfoText(ProgramIndex: Byte): WideString;
begin
  Result := FormatText1(LocalizedText('Programms.' + ProgramNames[ProgramIndex] + '.Text'),
    '<color=255,240,100>', '<Count>', IntToStr(ProgramCounts[ProgramIndex]));
end;
{ @end $75CB64 }

{ @routine $75CC9C TRanger_HasProgram }
function TRanger.HasProgram(ProgramIndex: Byte): Boolean;
begin
  Result := ProgramCounts[ProgramIndex] > 0;
end;
{ @end $75CC9C }

{ @routine $75CCC4 TRanger_CountProgramsInFilter }
function TRanger.CountProgramsInFilter(Filter: TRangerProgramMask): Integer;
var
  I: Byte;
begin
  Result := 0;
  for I := Low(ProgramCounts) to High(ProgramCounts) do
    if I in Filter then Inc(Result, ProgramCounts[I]);
end;
{ @end $75CCC4 }

{ @routine $75CD0C TRanger_SelectRandomProgramIdFromFilter }
function TRanger.SelectRandomProgramIdFromFilter(Filter: TRangerProgramMask): Byte;
var
  ProgramId: Byte;
  Attempt: Integer;
begin
  Attempt := 0;
  Result := 0;
  while True do
  begin
    Inc(Attempt);
    if Attempt > 10000 then Break;
    ProgramId := SeededRandomIntRange(Low(ProgramCounts), High(ProgramCounts), CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 65) + Attempt);
    if ProgramId in Filter then
    begin
      Result := ProgramId;
      Break;
    end;
  end;
end;
{ @end $75CD0C }

{ @routine $75CD7C TRanger_SelectProgramReward }
function TRanger.SelectProgramReward: Byte;
const
  BasicProgram = [prgIntercom];
  OtherPrograms = [prgShipwreck..prgDisconnection];
begin
  if (CountProgramsInFilter(BasicProgram) = 0) or (CountProgramsInFilter(BasicProgram) < RandomIntRange(3, 10)) then Result := prgIntercom
  else Result := SelectRandomProgramIdFromFilter(OtherPrograms);
end;
{ @end $75CD7C }

{ @routine $75CDE8 TRanger_GetProgramRewardCount }
function TRanger.GetProgramRewardCount(ProgramIndex: Byte): Integer;
begin
  if ProgramIndex = prgIntercom then
    Result := Round(SeededRandomIntRange(12, 20, Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn div 35)) /
      GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor)
  else
    Result := Round(SeededRandomIntRange(1, 3, Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn div 35)) /
      GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
  Result := Max(1, Result);
end;
{ @end $75CDE8 }

{ @routine $75CECC TRanger_AdjustItemEvaluation }
function TRanger.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
const
  NoFlags = [];
var
  MoneyPenalty, EffectivenessScale, WeightPenalty, FragilityScale: Single;
  Price: Integer;
  DesiredFreeFraction, DesiredMoneyFraction, HullValueScale: Single;
begin
  case PreferredCareer of
    rcWarrior: begin DesiredMoneyFraction := 0.05; FragilityScale := 1.2; HullValueScale := 1.5 end;
    rcPirate: begin DesiredMoneyFraction := 0.07; FragilityScale := 1; HullValueScale := 1 end;
    rcTrader: begin DesiredMoneyFraction := 0.1; FragilityScale := 0.8; HullValueScale := 0.5 end;
  else
    DesiredMoneyFraction := 0.1;
    FragilityScale := 1;
    HullValueScale := 1;
  end;
  if Item.ItemType in [t_FuelTanks, t_Radar, t_Scaner] then
    FragilityScale := FragilityScale * 0.5;
  DesiredFreeFraction := Max(0.01, Min(0.99, GetDesiredCargoFreeSpace / Max(100, GetHull.Weight)));
  MoneyPenalty := Sqr((1 / Max(0.01, SmoothedMoneyFraction) - 1) / (1 / DesiredMoneyFraction - 1)) /
    Max(SmoothedWealth * 0.05, 1000);
  EffectivenessScale := 2 / Max(10, SmoothedEquipmentEffectiveness);
  WeightPenalty := Sqr((1 / Max(0.01, SmoothedFreeCapacityFraction) - 1) / (1 / DesiredFreeFraction - 1)) /
    Max(10, GetHull.Weight * 0.1);
  MoneyPenalty := MoneyPenalty * 0.01 * (100 + SeededRandomIntRange(-20, 20, Id + Seed));
  EffectivenessScale := EffectivenessScale * 0.01 * (100 + SeededRandomIntRange(-20, 20, Id * 3 + Seed));
  WeightPenalty := WeightPenalty * 0.01 * (100 + SeededRandomIntRange(-20, 20, Id * 5 + Seed));
  case PriceMode of
    4: begin
      Price := Item.Cost;
      MoneyPenalty := MoneyPenalty * RemapClamped(EquipmentPriceSensitivity, 0, 1, 0.2, 1);
    end;
    3: begin
      Price := Item.CalculateResaleValue(GetEffectiveSkillLevel(psTrading));
      MoneyPenalty := MoneyPenalty * RemapClamped(EquipmentPriceSensitivity, 0, 1, 0.2, 1);
    end;
    1: Price := -Item.Cost;
    2: Price := 0;
    0: begin
      Price := 0;
      WeightPenalty := 0;
      FragilityScale := 0;
    end;
  else
    Price := 0;
    WeightPenalty := 0;
  end;
  if Item.ItemType <> t_Hull then
    Result := Effectiveness * EffectivenessScale * (1 + (2 - TEquipment(Item).GetFragilityFactor(NoFlags)) * FragilityScale) -
      Item.Weight * WeightPenalty - Price * MoneyPenalty
  else
    Result := (Item.Weight * HullValueScale / Max(0.01, TEquipment(Item).GetFragilityFactor(NoFlags)) + Effectiveness) * EffectivenessScale +
      Item.Weight * WeightPenalty - Price * 0.25 * MoneyPenalty;
end;
{ @end $75CECC }

{ @routine $75D4EC TRanger_EvaluateStatBonus }
function TRanger.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then Exit;
  case BonusKind of
    bonHull: Result := Value * 200;
    bonFuel: Result := Value * 2.5;
    bonSpeed: Result := Value;
    bonJump: Result := Value * 25;
    bonRadar: Result := Value * 0.063;
    bonScan: Result := Value * 5 + Value * 20 * CountWeaponsByDamageFlags(ScannerFlags);
    bonDroid: Result := Value * 10 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonHook: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.5;
    bonDef: Result := Value * 5 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonWEnergy: Result := Value * 10;
    bonWSplinter: Result := Value * 10;
    bonWMissile: Result := Value * 10 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonWRadius: Result := Value * Sqr(Max(100, SmoothedEnemySpeed) / Max(100, SmoothedSpeed));
    bonHookRadius: Result := Value * 0.15;
    bonMass: Result := RemapClamped(Value + GetHull.Weight * 0.1, HullMassEvaluationStart, HullMassEvaluationEnd, 1, 0.333) * 5000;
    bonSlotRadar:
      if (GetSlotCount(sskRadar) = 0) and (Value > 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.3
      else if (GetRadar <> nil) and (Value < 0) then Result := -RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] - RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), 18] * CountMissileWeapons
      else if (GetSlotCount(sskRadar) = 1) and (Value < 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * -0.3;
    bonSlotScaner:
      if (GetSlotCount(sskScanner) = 0) and (Value > 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.3
      else if (GetScanner <> nil) and (Value < 0) then Result := -RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] - CountWeaponsByDamageFlags(ScannerFlags) * 0.1 * RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), 18]
      else if (GetSlotCount(sskScanner) = 1) and (Value < 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * -0.3;
    bonSlotDroid:
      if (GetSlotCount(sskRepairRobot) = 0) and (Value > 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.3
      else if (GetRepairRobot <> nil) and (Value < 0) then Result := -RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)]
      else if (GetSlotCount(sskRepairRobot) = 1) and (Value < 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * -0.3;
    bonSlotHook:
      if (GetSlotCount(sskCargoHook) = 0) and (Value > 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.3
      else if (GetCargoHook <> nil) and (Value < 0) then Result := -RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)]
      else if (GetSlotCount(sskCargoHook) = 1) and (Value < 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * -0.3;
    bonSlotDef:
      if (GetSlotCount(sskDefGenerator) = 0) and (Value > 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.3
      else if (GetDefGenerator <> nil) and (Value < 0) then Result := -RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)]
      else if (GetSlotCount(sskDefGenerator) = 1) and (Value < 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * -0.3;
    bonSlotWeapon:
      begin
        if (GetSlotCount(sskWeapon) < 5) and (Value > 0) then
          Result := Min(Value, 5 - GetSlotCount(sskWeapon)) * RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskWeapon)) * RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
        if CountEquippedWeapons > Max(Value + GetSlotCount(sskWeapon), 1) then
          Result := Result - (RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.6) * (CountEquippedWeapons - Max(1, Value + GetSlotCount(sskWeapon)));
      end;
    bonSlotArt:
      begin
        if (GetSlotCount(sskArtefact) < DefaultHullSlotCounts[8]) and (Value > 0) then
          Result := Min(Value, DefaultHullSlotCounts[8] - GetSlotCount(sskArtefact)) * RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
        if Value < 0 then Result := Max(Value, -GetSlotCount(sskArtefact)) * RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
        if Artefacts <> nil then
          if Artefacts.Count > Max(Value + GetSlotCount(sskArtefact), 0) then Result := -1000;
      end;
    bonSlotForsage:
      if (GetSlotCount(sskAfterburner) = 0) and (Value > 0) then Result := RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)]
      else if (GetSlotCount(sskAfterburner) = 1) and (Value < 0) then Result := -RangerSlotBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
    bonSkill1..bonSkill6:
      begin
        if Value > 0 then
          Result := Min(6 - GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])), Value) * RangerSkillBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
        if (Value > 0) and (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])) > 6) then
          Result := Result + (RangerSkillBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.05) * (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])) - 6);
        if Value < 0 then
          Result := Min(GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])), -Value) * -RangerSkillBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)];
        if (Value < 0) and (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])) < 0) then
          Result := Result + (RangerSkillBonusEvaluationWeights[Ord(PreferredCareer), Ord(BonusKind)] * 0.03) * (Value + GetEffectiveSkillLevel(TPilotSkill(EquipmentBonusSkills[Ord(BonusKind) - 22])));
      end;
  else Result := 0;
  end;
  if (PreferredCareer = rcWarrior) and
    (BonusKind in [bonHull, bonRadar, bonDroid, bonDef, bonWRadius]) then Result := Result * 1.3;
  if (PreferredCareer = rcPirate) and
    (BonusKind in [bonSpeed, bonWEnergy, bonWSplinter, bonMass]) then Result := Result * 1.3;
  if (PreferredCareer = rcTrader) and
    (BonusKind in [bonFuel, bonJump]) then Result := Result * 1.3;
  if BonusKind in [bonSkill1..bonSkill6] then
    Result := Result * 0.01 * (100 + SeededRandomIntRange(-60, 60, Ord(BonusKind) * 131 + Seed)) *
      RaceSkillEvaluationFactors[PilotRace, EquipmentBonusSkills[Ord(BonusKind) - 22]]
  else
    Result := Result * 0.01 * (100 + SeededRandomIntRange(-15, 15, Ord(BonusKind) * 131 + Seed));
end;
{ @end $75D4EC }

{ @routine $75E494 TRanger_EvaluateWeaponDamage }
function TRanger.EvaluateWeaponDamage(Weapon: TWeapon; IncludeAdditiveBonuses: Boolean; BaseDamage: Single): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  ShockFlags = [dkShock];
  AcidFlags = [dkAcid];
var
  ScannerFactor, StatusFactor: Single;
  Flags: TDamageFlagSet;
  SpeedFactor: Single;
  I, ShotTotal: Integer;
begin
  Flags := Weapon.GetDamageFlags;
  if (Flags * ScannerFlags <> []) and (GetScanner <> nil) and (GetRadar <> nil) then
    ScannerFactor := RemapClamped(GetScannerPower - DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(Galaxy.TechLevel)) + 1, -5, 10, 0.1, 2)
  else ScannerFactor := 0;
  Result := BaseDamage * GetWeaponArtefactDamageFactor(Weapon);
  if dkDrain in Flags then Result := Result * 1.5;
  if dkShock in Flags then Result := Result * (1.15 + CountWeaponsByDamageFlags(ShockFlags) * 0.07 - ShortInt(PreferredCareer = rcWarrior) * 0.05);
  if dkAcid in Flags then Result := Result * (1.25 - ShortInt(PreferredCareer = rcWarrior) * 0.05);
  if dkMagnetic in Flags then Result := Result * (1.25 - ShortInt(PreferredCareer = rcWarrior) * 0.05);
  if (PreferredCareer = rcTrader) and (dkDestruct in Flags) then Result := Result * 1.05;
  StatusFactor := 1;
  if dkScanBonus in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkBonusToDamaged in Flags then StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkReduceEngine in Flags then Result := Result * (1 + ScannerFactor * (0.1 + ShortInt(PreferredCareer = rcTrader) * 0.1));
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if (PreferredCareer = rcPirate) and (CountActiveArtefacts(Ord(t_ArtDecelerate)) > 0) and (dkSplinter in Flags) then
      Result := Result + (2 + 2 * Ord(CanBoostArtefact(Ord(t_ArtDecelerate), Weapon, False))) * CountActiveArtefacts(Ord(t_ArtDecelerate));
    if (PreferredCareer = rcPirate) and (dkDecelerate in Flags) then Result := Result + 2;
    if (PreferredCareer = rcTrader) and (dkDestruct in Flags) then Result := Result + 1;
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if dkAcid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 3;
    end;
    if dkMoreDrop in Flags then Result := Result + ScannerFactor * (5 + 5 * Ord(PreferredCareer = rcPirate));
    if dkDropCargo in Flags then Result := Result + ScannerFactor * (5 + 5 * Ord(PreferredCareer = rcPirate));
    if dkReduceEngine in Flags then Result := Result + ScannerFactor * (1 + Ord(PreferredCareer = rcTrader));
    if dkBlockWeapon in Flags then Result := Result + ScannerFactor * (5 + 5 * Ord(PreferredCareer = rcTrader));
    if dkDroidBlock in Flags then Result := Result + ScannerFactor * 5;
  end;
  SpeedFactor := Max(100, SmoothedEnemySpeed) * GetHull.Weight / (HullBaseSize * Max(100, SmoothedSpeed * EquipmentSizeFactors[1]));
  case PreferredCareer of
    rcWarrior:
      case Byte(Weapon.GetWeaponInfo.ShotType) of
        Ord(wstRocket): Result := Result * 0.8 * Weapon.GetShotCount * (1 + StatusFactor);
        Ord(wstMissile): Result := Result * (0.8 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor) * Weapon.GetShotCount;
        Ord(wstTorpedo): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor);
        Ord(wstChain): Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
        Ord(wstSplash): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 * SpeedFactor + StatusFactor);
        Ord(wstExploder): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.1 * 0.01 * SpeedFactor + StatusFactor);
        Ord(wstAreaDamage): Result := Result * (1 + Weapon.Range * 1.3 * 0.01 * SpeedFactor + StatusFactor);
      else Result := Result * (1 + StatusFactor);
      end;
    rcPirate:
      case Byte(Weapon.GetWeaponInfo.ShotType) of
        Ord(wstRocket): Result := Result * 0.6 * Weapon.GetShotCount * (1 + StatusFactor);
        Ord(wstMissile): Result := Result * (0.6 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.1 * 0.01 + StatusFactor) * Weapon.GetShotCount;
        Ord(wstTorpedo): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.1 * 0.01 + StatusFactor);
        Ord(wstChain): Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
        Ord(wstSplash): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 * SpeedFactor + StatusFactor);
        Ord(wstAreaDamage): Result := Result * (1 + Weapon.Range * 0.16 * 0.01 * SpeedFactor + StatusFactor);
      else Result := Result * (1 + StatusFactor);
      end;
    rcTrader:
      case Byte(Weapon.GetWeaponInfo.ShotType) of
        Ord(wstRocket): Result := Result * 1.2 * Weapon.GetShotCount * (1 + StatusFactor);
        Ord(wstMissile): Result := Result * (1.2 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor) * Weapon.GetShotCount;
        Ord(wstTorpedo): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.2 * 0.01 + StatusFactor);
        Ord(wstChain): Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
        Ord(wstSplash): Result := Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.1 * 0.01 * SpeedFactor + StatusFactor);
        Ord(wstAreaDamage): Result := Result * (1 + Weapon.Range * 0.16 * 0.01 * SpeedFactor + StatusFactor);
      else Result := Result * (1 + StatusFactor);
      end;
  end;
  Result := Result * Weapon.GetAttackCount;
  Result := Result * 0.01 * (100 + SeededRandomIntRange(-20, 20, Seed + Weapon.GetWeaponInfo.TypeHash));
end;
{ @end $75E494 }

{ @routine $75EF40 TRanger_AcceptPickupItem }
function TRanger.AcceptPickupItem(Item: TItem): Boolean;
begin
  Result := True;
end;
{ @end $75EF40 }

{ @routine $75EF58 TRanger_AcceptPickupDistance }
function TRanger.AcceptPickupDistance(Item: TItem; Distance: Double): Boolean;
begin
  if Speed < 1 then
  begin
    Result := False;
    Exit;
  end;
  if Item.ItemType = t_Protoplasm then
    Result := (Item.Weight >= 30) or (Distance / Speed <= 3.0)
  else Result := (Speed * 1.2 >= Distance) or (Item.Cost >= RemapClamped(Distance / Speed, 1.0, 10.0, 0.01, 0.05) * Wealth);
end;
{ @end $75EF58 }

{ @routine $75F040 TRanger_RefreshCurrentStanding }
procedure TRanger.RefreshCurrentStanding;
var
  Owner: Byte;
  StandingMode: Integer;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then
  begin
    CurrentStanding := ssCustom;
    Exit;
  end;
  if StandingMode = ssmFixed then Exit;
  if (GetPlayer <> nil) and (GetPlayer = PartnerShip) then Owner := GetPlayer.OwnerId
  else Owner := OwnerId;
  if IsInPrison then CurrentStanding := ssNeutral
  else if (Owner <> 7) or (Galaxy.PirateWinType = 3) then
  begin
    if (CurrentSystemKills.Pirate > 0) or (CurrentStar.ControlFaction = sfCoalition) then CurrentStanding := ssCoalitionActive
    else CurrentStanding := ssCoalitionPassive;
  end
  else if (CurrentSystemKills.Normal > 0) or (CurrentStar.ControlFaction = sfPirates) then CurrentStanding := ssPirateActive
  else CurrentStanding := ssPiratePassive;
end;
{ @end $75F040 }

{ @routine $75F134 TRanger_ProcessQuestTimersAndOutcomes }
procedure TRanger.ProcessQuestTimersAndOutcomes;
var
  I: Integer;
  Quest: PQuest;
  Text: WideString;
begin
  for I := Quests.Count - 1 downto 0 do
  begin
    { The neutral index expression preserves DCC32's native argument evaluation order. }
    Quest := PQuest(Quests[I + 0]);
    if Galaxy.CurrentTurn >= Quest.DeadlineTurn then
    begin
      if (Quest.QuestType in [qtSendLetter, qtKillShip, qtPlanetQuest]) and not Quest.Successful then
      begin
        if (Quest.QuestType <> qtPlanetQuest) or (CurrentScreenId <> screenPlanetQuest) or
          not (Quest.ObjectiveTarget is TPlanet) or (GetPlayer.CurrentPlanet <> (Quest.ObjectiveTarget as TPlanet)) then
        begin
          PublishQuestStatus(Quest, -1);
          if (Quest.Planet.OwnerId = Byte(oiPirate)) and (MainPiratePlanet <> nil) and (MainPiratePlanet.GetRelationLevelToShip(Self) > rlBad) then
          begin
            if MainPiratePlanet.GetRelationLevelToShip(Self) = rlNormal then MainPiratePlanet.SetRelationLevelToRanger(Self, rlBad);
            if MainPiratePlanet.GetRelationLevelToShip(Self) = rlGood then MainPiratePlanet.SetRelationLevelToRanger(Self, rlNormal);
            if MainPiratePlanet.GetRelationLevelToShip(Self) >= rlExcellent then MainPiratePlanet.SetRelationLevelToRanger(Self, rlGood);
          end;
          if Quest.Planet.GetRelationLevelToShip(Self) > rlBad then Quest.Planet.SetRelationLevelToRanger(Self, rlBad);
          Text := PickLocalizedTextVariant('GalaxyNews.Quest.Failure.Time', Seed * Cardinal(Galaxy.CurrentTurn div 10));
          ReplaceTextToken(Text, '<Quest>', Quest.Description, '<color=255,240,100>');
          ReplaceTextToken(Text, '<Planet>', Quest.Planet.Name, '<color=255,240,100>');
          ReplaceTextToken(Text, '<Star>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Text, '<Relation>', Quest.Planet.GetRelationLevelTextToShip(Self), '<color=255,240,100>');
          if Quest.QuestType = qtSendLetter then TryAddAchievementProgress('POSTMAN', 1);
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
          CheckQuestFailureAward(Quest, [qtSendLetter, qtKillShip, qtPlanetQuest]);
          ArchiveQuest(I);
        end;
      end
      else if (Quest.QuestType in [qtDefendSystem, qtDefendShip]) and not Quest.Successful then
      begin
        case Quest.QuestType of
        qtDefendSystem:
        begin
          if Quest.Planet <> nil then
          begin
            Text := PickLocalizedTextVariant('GalaxyNews.Quest.Successful.DefSystem', Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Star>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
          end
          else
          begin
            Text := PickLocalizedTextVariant('GalaxyNews.Quest.Successful.DefSystemRuins', Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Star>', (Quest.ObjectiveTarget as TStar).Name, '<color=255,240,100>');
          end;
        end;
        qtDefendShip:
        begin
          if Quest.Planet <> nil then Text := PickLocalizedTextVariant('GalaxyNews.Quest.Successful.DefShip', Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn div 10))
          else Text := PickLocalizedTextVariant('GalaxyNews.Quest.Successful.DefShipRuins', Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn div 10));
          ReplaceTextToken(Text, '<Ship>', (Quest.ObjectiveTarget as TShip).GetName, '<color=255,240,100>');
        end;
        end;
        ReplaceTextToken(Text, '<Player>', GetPlayer.Name, '<color=255,240,100>');
        { Native code still dereferences Planet after the nil-planet text branches. }
        ReplaceTextToken(Text, '<Planet>', Quest.Planet.Name, '<color=255,240,100>');
        AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
        Quest.Successful := True;
        PublishQuestStatus(Quest, 0);
      end
      else PublishQuestStatus(Quest, 0);
    end
    else PublishQuestStatus(Quest, 0);
  end;
end;
{ @end $75F134 }

{ @routine $75F834 TRanger_CountFailedQuests }
function TRanger.CountFailedQuests(OwnerId: Byte; QuestTypes: TQuestTypes): Integer;
var
  I: Integer;
  Quest: PPlayerOldQuest;
begin
  Result := 0;
  for I := 0 to PlayerOldQuests.Count - 1 do
  begin
    Quest := PPlayerOldQuest(PlayerOldQuests[I]);
    if not Quest.Successful and not Quest.Declined and (Quest.Planet.OwnerId = OwnerId) and (Quest.QuestType in QuestTypes) then Inc(Result);
  end;
end;
{ @end $75F834 }

{ @routine $75FAB4 TRanger_CheckQuestFailureAward }
procedure TRanger.CheckQuestFailureAward(Quest: PQuest; QuestTypes: TQuestTypes);
var
  FailureCount: Integer;

  // @nested $75F8B4 GrantQuestFailureMilestoneAward
  procedure GrantQuestFailureMilestoneAward(InitialThreshold, Multiplier, FailureCount: Integer; OwnerId: Byte); // @addr 0x75F8B4 @ida "void __usercall $name(int InitialThreshold@<eax>, int Multiplier@<edx>, int FailureCount@<ecx>, unsigned __int8 OwnerId@<^0>, void *ParentFrame@<^4>);" @stackpop 0x4 @calls "0x75FB17" @note "Caller-popped static link; ranger -4. Awards only at an exact geometric milestone, checking at most ten thresholds."
  var
    I, Threshold, Award: Integer;
    Text: WideString;
  begin
    Threshold := InitialThreshold;
    for I := 1 to 10 do
    begin
      if FailureCount < Threshold then Break;
      if FailureCount = Threshold then
      begin
        Award := Integer(SelectAward(OwnerId, [atCowardice], [stKling..Ord(rstCustomStation)])) and $FF;
        if Award <> AwardNotFound then
        begin
          AddAward(Award);
          if GetPlayer = Self then
          begin
            Text := PickLocalizedTextVariant('GalaxyNews.BadReward.FailQuest', Seed + Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Reward>', GetAwardInfo(Award).Name, '<color=255,240,100>');
            AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
          end;
        end;
        Break;
      end;
      Threshold := Min(Threshold * Multiplier, 10000000);
    end;
  end;

begin
  if (Galaxy.CoalitionDefeatedTurn = 0) and (Quest.Planet <> nil) then
  begin
    FailureCount := CountFailedQuests(Quest.Planet.OwnerId, QuestTypes) + 1;
    if FailureCount > 0 then GrantQuestFailureMilestoneAward(3, 2, FailureCount, RaceToOwner(Quest.Planet.RaceId));
  end;
end;
{ @end $75FAB4 }

{ @routine $75FB24 TRanger_TryTurnInQuests }
procedure TRanger.TryTurnInQuests;
var
  Text: WideString;
begin
  TryTurnInAnyQuest(Text);
end;
{ @end $75FB24 }

{ @routine $75FB6C TRanger_ArchiveQuest }
procedure TRanger.ArchiveQuest(Index: Integer);
var
  OldQuest: PPlayerOldQuest;
  Quest: PQuest;
begin
  Quest := PQuest(Quests[Index]);
  if GetPlayer = Self then
  begin
    New(OldQuest);
    OldQuest.QuestType := Quest.QuestType;
    OldQuest.QuestNumber := Quest.QuestNumber;
    OldQuest.Planet := Quest.Planet;
    OldQuest.Description := Quest.Description;
    OldQuest.Successful := Quest.Successful;
    OldQuest.Declined := False;
    PlayerOldQuests.Add(OldQuest);
  end;
  Quests.Delete(Index);
  Dispose(Quest);
  RefreshPlayerQuestTargets;
end;
{ @end $75FB6C }

{ @routine $75FC2C TRanger_TryTurnInAnyQuest }
function TRanger.TryTurnInAnyQuest(var ResponseText: WideString): Boolean;
var
  I: Integer;
begin
  Result := False;
  ResponseText := '';
  for I := 0 to Quests.Count - 1 do
    if TryTurnInQuest(I, ResponseText) then
    begin
      Result := True;
      Exit;
    end;
end;
{ @end $75FC2C }

{ @routine $7605DC TRanger_TryTurnInQuest }
function TRanger.TryTurnInQuest(Index: Integer; var ResponseText: WideString): Boolean;
const RewardPrograms = [prgShipwreck..prgDisconnection];
var
  Quest: PQuest;
  GenerationSeed, Experience: Integer;
  Event: TGalaxyEvent;
  MinimumPriority, RewardKind, Quantity, ModuleIndex: Integer;
  Award: Byte;
  AwardWeight, ProgramWeight, ArtefactWeight, ModuleWeight: Single;
  RewardItem: TItem;
  RewardText: WideString;
  ProgramIndex: Byte;
  ModuleItem: TMicroModule;
  Factions: WideString;
  // @nested $75FC88 ConsumeQuestDeliveryItem
  function ConsumeQuestDeliveryItem: Boolean; // @addr 0x75FC88 @ida "bool __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ranger -4, quest -8. Removes/frees matching delivery cargo; true also when this planet quest requires no item."
  var I: Integer; Item: TItem;
  begin
    for I := 1 to Inventory.Count - 1 do begin
      Item := Inventory[I];
      if Item.ItemType = t_UselessItem then begin
        if ((Quest.QuestType = qtSendLetter) and
          (LocalizedColorText('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.SysName') = (Item as TUselessItem).ConfigBlockName)) or
          ((Quest.QuestType = qtPlanetQuest) and
          (LocalizedColorText('PlanetQuest.ItemForPlanetQuest.' + IntToStr(Quest.QuestNumber)) = (Item as TUselessItem).ConfigBlockName)) then begin
          Inventory.Delete(I);
          Item.Free;
          RefreshDerivedStats(True);
          Result := True;
          Exit;
        end;
      end;
    end;
    if (Quest.QuestType = qtPlanetQuest) and
      ((LookupLocalizedTextByKey('PlanetQuest.ItemForPlanetQuest.' + IntToStr(Quest.QuestNumber)) = 'None') or
       (LookupLocalizedTextByKey('PlanetQuest.ItemForPlanetQuest.' + IntToStr(Quest.QuestNumber)) = '')) then Result := True else Result := False;
  end;
  // @nested $75FF88 FinalizeSuccessfulQuestTurnIn
  procedure FinalizeSuccessfulQuestTurnIn; // @addr 0x75FF88 @ida "void __cdecl $name(void *ParentFrame);" @note "Caller-popped static link; ranger -4, quest -8, seed input -12, experience -16, response output -20, event -24, quest index -28. Grants experience, archives the quest and updates relations."
  begin
    Experience := RoundAndTruncateToTens(SeededRandomFloatRange((GenerationSeed + Galaxy.CurrentTurn) div 100 + 123, 0.7, 1.5) *
      (Galaxy.ScaleIntByTechLevel(QuestExperience[Ord(Quest.QuestType)], 2 * QuestExperience[Ord(Quest.QuestType)]) /
        GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor));
    GainExperience(Experience, 0);
    if GetPlayer = Self then begin
      ResponseText := ResponseText + #13#10 + ' ' + #13#10 + WrapTextInColor(LocalizedColorText('PlanetCongratulations.Quest.AddPoints'), '<color=45,105,45>');
      ReplaceTextToken(ResponseText, '<Points>', IntToStr(Experience), '');
    end else ResponseText := '';
    if GetPlayer = Self then begin
      Event := AddGalaxyEvent('PlayerFinishesQuest');
      Event.AddData(Ord(Quest.QuestType));
      Event.AddData(Quest.QuestNumber);
      Event.AddData(Quest.RewardMoney);
      Event.AddData(Experience);
    end;
    if (GetPlayer = Self) and (CurrentPlanet <> nil) then begin
      ReplaceTextToken(ResponseText, '<Star>', CurrentPlanet.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(ResponseText, '<Planet>', CurrentPlanet.Name, '<color=255,240,100>');
    end;
    PublishQuestStatus(Quest, 1);
    if GetPlayer = Self then begin
      ReplaceTextToken(ResponseText, '<Ranger>', Name, '<color=255,240,100>');
      ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
    end;
    if Quest.QuestType = qtDefendSystem then TryAddAchievementProgress('GUARD', 1);
    if Quest.QuestType = qtSendLetter then TryAddAchievementProgress('DELIVERY', 1);
    ArchiveQuest(Index);
    RefreshPlayerQuestTargets;
  if CurrentPlanet <> nil then CurrentPlanet.ChangeRelationToRanger(Self, Max(0, 70 - CurrentPlanet.RelationToShip(Self)));
  if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (MainPiratePlanet <> nil) then begin
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlHostile then MainPiratePlanet.SetRelationLevelToRanger(Self, rlBad);
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlBad then MainPiratePlanet.SetRelationLevelToRanger(Self, rlNormal);
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlNormal then MainPiratePlanet.SetRelationLevelToRanger(Self, rlGood);
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlGood then MainPiratePlanet.SetRelationLevelToRanger(Self, rlExcellent);
    // Native calls the ranger's own virtual method here, after upgrading the planet relation.
    if MainPiratePlanet.GetRelationLevelToShip(Self) >= rlExcellent then
      ChangeRelationToRanger(Self, Max(0, 100 - MainPiratePlanet.RelationToShip(Self)));
  end;
    TryAddAchievementProgress('AGENT', 1);
  end;
begin
  GenerationSeed := 0;
  if CurrentPlanet <> nil then GenerationSeed := CurrentPlanet.GenerationSeed;
  if DockedTo <> nil then GenerationSeed := DockedTo.Seed;
  Result := False;
  Quest := Quests[Index];
  case Quest.QuestType of
    qtSendLetter:
      if ((Quest.ObjectiveTarget as TPlanet) = CurrentPlanet) and ConsumeQuestDeliveryItem then begin
        Result := True;
        Quest.Successful := True;
        SetMoney(Money + Quest.RewardMoney);
        ResponseText := Quest.CompletionText;
        Factions := LookupLocalizedTextByKey('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.ToRace');
        if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (Pos('OnlyNonPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratPirate');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        if (CurrentPlanet.OwnerId <> Byte(oiPirate)) and (Pos('OnlyPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratCoal');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        RewardText := LookupLocalizedTextOrEmpty('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.GovernmentAward');
      end;
    qtKillShip:
      if (Quest.Planet <> nil) and (Quest.Planet = CurrentPlanet) and Quest.Successful then begin
        Result := True;
        SetMoney(Money + Quest.RewardMoney);
        ResponseText := Quest.CompletionText;
        Factions := LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(Quest.QuestNumber) + '.PlanetRace');
        if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (Pos('OnlyNonPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratPirate');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        if (CurrentPlanet.OwnerId <> Byte(oiPirate)) and (Pos('OnlyPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratCoal');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        RewardText := LookupLocalizedTextOrEmpty('Quest.KillShip.' + IntToStr(Quest.QuestNumber) + '.GovernmentAward');
      end;
    qtPlanetQuest:
      if (Quest.Planet = CurrentPlanet) and (Quest.Successful or ConsumeQuestDeliveryItem) then begin
        Result := True;
        Quest.Successful := True;
        SetMoney(Money + Quest.RewardMoney);
        ResponseText := Quest.CompletionText;
        RewardText := 'Reward,Programms,Artefact';
      end;
    qtDefendSystem:
      if (Quest.Planet <> nil) and (Quest.Planet = CurrentPlanet) and Quest.Successful then begin
        Result := True;
        SetMoney(Money + Quest.RewardMoney);
        ResponseText := Quest.CompletionText;
        Factions := LookupLocalizedTextByKey('Quest.DefSystem.' + IntToStr(Quest.QuestNumber) + '.PlanetRace');
        if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (Pos('OnlyNonPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratPirate');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        if (CurrentPlanet.OwnerId <> Byte(oiPirate)) and (Pos('OnlyPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratCoal');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        RewardText := LookupLocalizedTextOrEmpty('Quest.DefSystem.' + IntToStr(Quest.QuestNumber) + '.GovernmentAward');
      end;
    qtDefendShip:
      if (Quest.Planet <> nil) and (Quest.Planet = CurrentPlanet) and Quest.Successful then begin
        Result := True;
        SetMoney(Money + Quest.RewardMoney);
        if Quest.ObjectiveTarget = nil then ResponseText := Quest.SpecialCompletionText else ResponseText := Quest.CompletionText;
        Factions := LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(Quest.QuestNumber) + '.PlanetRace');
        if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (Pos('OnlyNonPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratPirate');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        if (CurrentPlanet.OwnerId <> Byte(oiPirate)) and (Pos('OnlyPirate', Factions) > 0) then begin
          ResponseText := LookupLocalizedTextByKey('Quest.GenericCongratCoal');
          ReplaceTextToken(ResponseText, '<Player>', Name, '<color=255,240,100>');
          ReplaceTextToken(ResponseText, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
        end;
        RewardText := LookupLocalizedTextOrEmpty('Quest.DefShip.' + IntToStr(Quest.QuestNumber) + '.GovernmentAward');
      end;
  end;
  if not Result then Exit;
  if SeededRandomUnitFloat((GenerationSeed + Galaxy.CurrentTurn) div 51 + 1767) < RemapClamped(Galaxy.TechLevel, 3, 8, 0.1, 0.5) then begin
    FinalizeSuccessfulQuestTurnIn;
    Exit;
  end;
  AwardWeight := FindTextPosW('Reward', RewardText);
  ProgramWeight := FindTextPosW('Programms', RewardText);
  ArtefactWeight := FindTextPosW('Artefact', RewardText);
  ModuleWeight := FindTextPosW('Nod', RewardText);
  if AwardWeight > 0 then
    if AwardIds = nil then AwardWeight := 80
    else AwardWeight := RemapClamped(AwardIds.Count, 0, 15, 80, 10);
  if HasProgram(prgIntercom) and (ProgramWeight > 0) then ProgramWeight := RemapClamped(CountProgramsInFilter(RewardPrograms), 0, 10, 80, 10)
  else ProgramWeight := 0;
  if ArtefactWeight > 0 then ArtefactWeight := RemapClamped(Artefacts.Count, 1, 5, 80, 10);
  if ModuleWeight > 0 then ModuleWeight := RandomIntRange(10, 90);
  if (AwardWeight = 0) and (ProgramWeight = 0) and (ArtefactWeight = 0) and (ModuleWeight = 0) then begin
    FinalizeSuccessfulQuestTurnIn;
    Exit;
  end;
  if AwardWeight > 0 then AwardWeight := AwardWeight * SeededRandomIntRange(5, 25, GenerationSeed + Galaxy.CurrentTurn div 33 + 667);
  if ProgramWeight > 0 then ProgramWeight := ProgramWeight * SeededRandomIntRange(5, 25, GenerationSeed + Galaxy.CurrentTurn div 41 + 767);
  if ArtefactWeight > 0 then ArtefactWeight := ArtefactWeight * SeededRandomIntRange(5, 25, GenerationSeed + Galaxy.CurrentTurn div 57 + 967);
  if ModuleWeight > 0 then ModuleWeight := ModuleWeight * SeededRandomIntRange(5, 25, GenerationSeed + Galaxy.CurrentTurn div 77 + 1967);
  if (AwardWeight > 0) and (AwardWeight >= Max(ModuleWeight, Max(ProgramWeight, ArtefactWeight))) then RewardKind := 1
  else if (ProgramWeight > 0) and (ProgramWeight >= Max(ModuleWeight, Max(AwardWeight, ArtefactWeight))) then RewardKind := 2
  else if (ArtefactWeight > 0) and (ArtefactWeight >= Max(ModuleWeight, Max(AwardWeight, ProgramWeight))) then RewardKind := 3
  else if (ModuleWeight > 0) and (ModuleWeight >= Max(ArtefactWeight, Max(AwardWeight, ProgramWeight))) then RewardKind := 4
  else begin
    FinalizeSuccessfulQuestTurnIn;
    Exit;
  end;
  case RewardKind of
    1: begin
      if CurrentPlanet <> nil then Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atAccomplishment, atSecretMission], [stKling..Ord(rstCustomStation)])
      else Award := SelectAward(DockedTo.OwnerId, [atAccomplishment, atSecretMission], [stKling..Ord(rstCustomStation)]);
      if Award <> AwardNotFound then begin
        AddAward(Award);
        if GetPlayer = Self then begin
          ResponseText := ResponseText + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddReward');
          ReplaceTextToken(ResponseText, '<Reward>', GetAwardInfo(Award).Name, '<color=255,240,100>');
        end else ResponseText := '';
      end;
    end;
    2: begin
      ProgramIndex := SelectRandomProgramIdFromFilter(RewardPrograms);
      Quantity := SeededRandomIntRange(1,
        Round(RemapClamped(CountProgramsInFilter(RewardPrograms), 2, 10, GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].MaximumQuestProgramRewardCount, 1)),
        ProgramIndex + CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 25));
      Inc(ProgramCounts[ProgramIndex], Quantity);
      if GetPlayer = Self then begin
        ResponseText := ResponseText + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddProgramms');
        ReplaceTextToken(ResponseText, '<Programm>', GetProgramName(ProgramIndex), '<color=255,240,100>');
        ReplaceTextToken(ResponseText, '<Count>', IntToStr(Quantity), '<color=255,240,100>');
      end else ResponseText := '';
    end;
    3: begin
      if CurrentPlanet <> nil then RewardItem := CreateRandomLootItem(ilpReward, CurrentPlanet.OwnerId, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 50 + 172334671)
      else RewardItem := CreateRandomLootItem(ilpReward, DockedTo.OwnerId, (Integer(DockedTo.Seed) + Galaxy.CurrentTurn) div 50 + 172334671);
      if RewardItem is TArtefactTranclucator then TTranclucator(TArtefactTranclucator(RewardItem).Ship).OwnerShip := Self;
      if RewardItem is TArtefact then Artefacts.Add(RewardItem) else Inventory.Add(RewardItem);
      if GetPlayer = Self then begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, RewardItem, nil, 0);
        ResponseText := ResponseText + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddArtefact') + #13#10 + RewardItem.GetDescriptionText;
        ReplaceTextToken(ResponseText, '<Artefact>', RewardItem.GetDisplayName, '<color=255,240,100>');
      end else ResponseText := '';
    end;
    4: begin
      Experience := 0;
      repeat
        MinimumPriority := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 70, 20));
        if CurrentPlanet <> nil then ModuleIndex := Galaxy.SelectMicroModule(MinimumPriority, Min(MinimumPriority + 30, 100), Galaxy.CurrentTurn div 77 + 17 * Experience + CurrentPlanet.Id, CurrentPlanet)
        else ModuleIndex := Galaxy.SelectMicroModule(MinimumPriority, Min(MinimumPriority + 30, 100), Galaxy.CurrentTurn div 77 + 17 * Experience + DockedTo.Id, DockedTo);
        Inc(Experience);
        if Experience > 50 then Break;
      until GetPlayer.NeedsMicroModule(ModuleIndex + 1);
      ModuleItem := TMicroModule.Create;
      ModuleItem.Init(ModuleIndex);
      if GetPlayer = Self then begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, ModuleItem, nil, 0);
        Event := AddGalaxyEvent('PlayerReceivesMMAsReward');
        Event.AddData(ModuleItem.Id);
        Event.AddData(ModuleItem.MicroModuleIndex - 1);
      end;
      Inventory.Add(ModuleItem);
      if GetPlayer = Self then begin
        if CurrentPlanet.OwnerId = Byte(oiPirate) then
          ResponseText := ResponseText + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddNodPirate') + #13#10 + ModuleItem.GetInfoText('<color=255,240,100>', nil)
        else ResponseText := ResponseText + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddNod') + #13#10 + ModuleItem.GetInfoText('<color=255,240,100>', nil);
        ReplaceTextToken(ResponseText, '<Nod>', MicroModuleTemplates[ModuleIndex].Name, '<color=255,240,100>');
      end else ResponseText := '';
    end;
  end;
  FinalizeSuccessfulQuestTurnIn;
end;
{ @end $7605DC }

{ @routine $762248 TRanger_GrantPlanetQuestReward }
function TRanger.GrantPlanetQuestReward(Difficulty: Integer; var ExperienceAwarded: Integer): WideString;
const RewardPrograms = [prgShipwreck..prgDisconnection];
var
  Amount, MinimumPriority, RewardKind, Quantity, ModuleIndex: Integer;
  Award: Byte;
  AwardWeight, ProgramWeight, ArtefactWeight, ModuleWeight: Single;
  RewardItem: TItem;
  ProgramIndex: Byte;
  ModuleItem: TMicroModule;
  Event: TGalaxyEvent;
begin
  Result := '';
  AwardWeight := 1;
  ProgramWeight := 1;
  ArtefactWeight := 1;
  ModuleWeight := 1;
  if AwardWeight > 0 then
    if AwardIds = nil then AwardWeight := 80
    else AwardWeight := RemapClamped(AwardIds.Count, 0, 25, 80, 10);
  if HasProgram(prgIntercom) and (ProgramWeight > 0) then ProgramWeight := RemapClamped(CountProgramsInFilter(RewardPrograms), 0, 10, 80, 10);
  if ArtefactWeight > 0 then ArtefactWeight := RemapClamped(Artefacts.Count, 0, 5, 40, 5);
  if ModuleWeight > 0 then ModuleWeight := RandomIntRange(40, 95);
  if (AwardWeight = 0) and (ProgramWeight = 0) and (ArtefactWeight = 0) and (ModuleWeight = 0) then Exit;
  if AwardWeight > 0 then AwardWeight := AwardWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 33 + 667);
  if ProgramWeight > 0 then ProgramWeight := ProgramWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 41 + 767);
  if ArtefactWeight > 0 then ArtefactWeight := ArtefactWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 57 + 149671);
  if ModuleWeight > 0 then ModuleWeight := ModuleWeight * SeededRandomIntRange(5, 25, CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 77 + 1967);
  if (AwardWeight > 0) and (AwardWeight >= Max(ModuleWeight, Max(ProgramWeight, ArtefactWeight))) then RewardKind := 1
  else if (ProgramWeight > 0) and (ProgramWeight >= Max(ModuleWeight, Max(AwardWeight, ArtefactWeight))) then RewardKind := 2
  else if (ArtefactWeight > 0) and (ArtefactWeight >= Max(ModuleWeight, Max(AwardWeight, ProgramWeight))) then RewardKind := 3
  else if (ModuleWeight > 0) and (ModuleWeight >= Max(ArtefactWeight, Max(AwardWeight, ProgramWeight))) then RewardKind := 4
  else Exit;
  case RewardKind of
    1: begin
      Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), [atPlanetBattle], [stKling..Ord(rstCustomStation)]);
      if Award <> AwardNotFound then begin
        AddAward(Award);
        if GetPlayer = Self then begin
          Result := Result + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddReward');
          ReplaceTextToken(Result, '<Reward>', GetAwardInfo(Award).Name, '<color=255,240,100>');
        end else Result := '';
      end;
    end;
    2: begin
      ProgramIndex := SelectRandomProgramIdFromFilter(RewardPrograms);
      Quantity := SeededRandomIntRange(1,
        Round(RemapClamped(CountProgramsInFilter(RewardPrograms), 2, 10, GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].MaximumQuestProgramRewardCount, 1)),
        ProgramIndex + CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 25));
      Inc(ProgramCounts[ProgramIndex], Quantity);
      if GetPlayer = Self then begin
        Result := Result + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddProgramms');
        ReplaceTextToken(Result, '<Programm>', GetProgramName(ProgramIndex), '<color=255,240,100>');
        ReplaceTextToken(Result, '<Count>', IntToStr(Quantity), '<color=255,240,100>');
      end else Result := '';
    end;
    3: begin
      RewardItem := CreateRandomLootItem(ilpReward, CurrentPlanet.OwnerId, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 50 + 172334671);
      if RewardItem is TArtefactTranclucator then TTranclucator(TArtefactTranclucator(RewardItem).Ship).OwnerShip := Self;
      if RewardItem is TArtefact then Artefacts.Add(RewardItem) else Inventory.Add(RewardItem);
      if GetPlayer = Self then begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, RewardItem, nil, 0);
        Result := Result + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddArtefact') + #13#10 + RewardItem.GetDescriptionText;
        ReplaceTextToken(Result, '<Artefact>', RewardItem.GetDisplayName, '<color=255,240,100>');
      end else Result := '';
    end;
    4: begin
      Amount := 0;
      MinimumPriority := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 70, 0));
      repeat
        ModuleIndex := Galaxy.SelectMicroModule(MinimumPriority, Min(MinimumPriority + 30, 100), Galaxy.CurrentTurn div 77 + 17 * Amount + CurrentPlanet.Id, CurrentPlanet);
        Inc(Amount);
        if Amount > 50 then Break;
      until GetPlayer.NeedsMicroModule(ModuleIndex + 1);
      ModuleItem := TMicroModule.Create;
      ModuleItem.Init(ModuleIndex);
      if GetPlayer = Self then begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, ModuleItem, nil, 0);
        Event := AddGalaxyEvent('PlayerReceivesMMAsReward');
        Event.AddData(ModuleItem.Id);
        Event.AddData(ModuleItem.MicroModuleIndex - 1);
      end;
      Inventory.Add(ModuleItem);
      if GetPlayer = Self then begin
        if CurrentPlanet.OwnerId = Byte(oiPirate) then
          Result := Result + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddNodPirate') + #13#10 + ModuleItem.GetInfoText('<color=255,240,100>', nil)
        else Result := Result + #13#10 + LocalizedColorText('PlanetCongratulations.Quest.AddNod') + #13#10 + ModuleItem.GetInfoText('<color=255,240,100>', nil);
        ReplaceTextToken(Result, '<Nod>', MicroModuleTemplates[ModuleIndex].Name, '<color=255,240,100>');
      end else Result := '';
    end;
  end;
  Amount := RoundAndTruncateToTens(SeededRandomFloatRange((Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 100 + $707D5B, 0.7, 1.5) *
    (Galaxy.ScaleIntByTechLevel(QuestExperience[2], 2 * QuestExperience[2]) / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestTimeAndExperienceFactor));
  case Difficulty of
    1: Amount := Amount * 2;
    2: Amount := Round(Amount * 0.9);
    3: Amount := Round(Amount * 0.6);
  end;
  GainExperience(Amount, 0);
  ExperienceAwarded := Amount;
  if GetPlayer = Self then begin
    Result := Result + #13#10 + ' ' + #13#10 + WrapTextInColor(LocalizedColorText('PlanetCongratulations.Quest.AddPoints'), '<color=45,105,45>');
    ReplaceTextToken(Result, '<Points>', IntToStr(Amount), '');
  end else Result := '';
  if CurrentPlanet <> nil then CurrentPlanet.ChangeRelationToRanger(Self, Max(0, 70 - CurrentPlanet.RelationToShip(Self)));
  if (CurrentPlanet.OwnerId = Byte(oiPirate)) and (MainPiratePlanet <> nil) then begin
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlHostile then MainPiratePlanet.SetRelationLevelToRanger(Self, rlBad);
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlBad then MainPiratePlanet.SetRelationLevelToRanger(Self, rlNormal);
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlNormal then MainPiratePlanet.SetRelationLevelToRanger(Self, rlGood);
    if MainPiratePlanet.GetRelationLevelToShip(Self) = rlGood then MainPiratePlanet.SetRelationLevelToRanger(Self, rlExcellent);
    // Native calls the ranger's own virtual method here, after upgrading the planet relation.
    if MainPiratePlanet.GetRelationLevelToShip(Self) >= rlExcellent then
      ChangeRelationToRanger(Self, Max(0, 100 - MainPiratePlanet.RelationToShip(Self)));
  end;
end;
{ @end $762248 }

{ @routine $76332C TRanger_GenerateQuestOffer }
function TRanger.GenerateQuestOffer(var Quest: TQuest; var ResponseText: WideString): Boolean;
label OfferPlanetQuest;
var
  I, J, K, Attempts, Interval, QuestNumber, MaximumQuest, FirstStar: Integer;
  Star: TStar;
  Planet: TPlanet;
  ExistingQuest: PQuest;
  Target, DefendedShip: TShip;
  TextQuest: TTextQuest;
  Control: TCacheControlEC;
  Buffer: TCBufEC;
  Found: Boolean;
  ShipTypes, UnusedText, FromFactions, ToFactions: WideString;
begin
  Result := False;
  ResponseText := '';
  for I := 0 to Quests.Count - 1 do begin
    ExistingQuest := Quests[I];
    if ExistingQuest.Planet = CurrentPlanet then begin
      ResponseText := PickLocalizedTextVariant('FormGov.DontQuest.YouHaveQuest', CurrentPlanet.GenerationSeed * (Galaxy.CurrentTurn div 5) + 165856);
      Exit;
    end;
  end;
  if CurrentPlanet.GetRelationLevelToShip(Self) < rlGood then begin
    ResponseText := PickLocalizedTextVariant('FormGov.DontQuest.Distrust', CurrentPlanet.GenerationSeed * (Galaxy.CurrentTurn div 5) + 23236);
    Exit;
  end;
  if (CurrentPlanet.CurrentStar.Battle <> 0) and (CurrentPlanet.OwnerId = Byte(oiPirate)) then begin
    ResponseText := PickLocalizedTextVariant('FormGov.DontQuest.WarInSystemPirate', CurrentPlanet.GenerationSeed * (Galaxy.CurrentTurn div 5) + 118123);
    Exit;
  end;
  if CurrentPlanet.CurrentStar.Battle <> 0 then begin
    ResponseText := PickLocalizedTextVariant('FormGov.DontQuest.WarInSystem', CurrentPlanet.GenerationSeed * (Galaxy.CurrentTurn div 5) + 118123);
    Exit;
  end;
  Interval := 10;
  if not ((FractionalQuotient(CurrentPlanet.GenerationSeed, Galaxy.CurrentTurn + 100) >= 1.5) and (ForcedPlanetQuestId < 0)) then
  begin
    if not HasQuestOfType(qtSendLetter) and (ForcedPlanetQuestId < 0) then
      if FractionalQuotient(CurrentPlanet.GenerationSeed, (Galaxy.CurrentTurn + 111) div Interval) < PlanetGovernmentMarket[Ord(CurrentPlanet.Government)].QuestOfferProbabilities[0] then begin
        Attempts := 0;
        repeat
          Inc(Attempts);
          I := SeededRandomIntRange(Galaxy.Stars.Count div 6, Galaxy.Stars.Count div 3, (Attempts + Galaxy.CurrentTurn) div Interval);
          Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
          if (Star.ShipTypeCounts[stKling] <= 0) and (Star.Constellation.Id <> 20) and Star.IsConstellationVisible then
            for J := 0 to Star.Planets.Count - 1 do begin
              Planet := Star.Planets[J];
              if (Planet.OwnerId in [Ord(oiMaloc)..Ord(oiGaal), Ord(oiPirate)]) and not Planet.NoLanding and (Planet.GetRelationLevelToShip(Self) > rlHostile) then begin
                MaximumQuest := StrToInt(AnsiString(LanguageDataConfig.GetParamByPathOrMarker('Quest.SendLetter.Count'))) - 1;
                QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval);
                Found := False;
                UnusedText := '';
                for K := 0 to MaximumQuest do begin
                  FromFactions := LookupLocalizedTextByKey('Quest.SendLetter.' + IntToStr(QuestNumber) + '.FromRace');
                  ToFactions := LookupLocalizedTextByKey('Quest.SendLetter.' + IntToStr(QuestNumber) + '.ToRace');
                  if (Pos(OwnerToSys(RaceToOwner(CurrentPlanet.RaceId)), FromFactions) > 0) and
                    ((CurrentPlanet.OwnerId = Byte(oiPirate)) or (Pos('OnlyPirate', FromFactions) <= 0)) and
                    ((CurrentPlanet.OwnerId <> Byte(oiPirate)) or (Pos('OnlyNonPirate', FromFactions) <= 0)) and
                    (Pos(OwnerToSys(RaceToOwner(Planet.RaceId)), ToFactions) > 0) and
                    ((Planet.OwnerId = Byte(oiPirate)) or (Pos('OnlyPirate', ToFactions) <= 0)) and
                    ((Planet.OwnerId <> Byte(oiPirate)) or (Pos('OnlyNonPirate', ToFactions) <= 0)) and
                    ((LanguageDataConfig.CountParamsByPath('Quest.SendLetter.' + IntToStr(QuestNumber) + '.PlayerRace') = 0) or
                    (Pos(OwnerToSys(RaceToOwner(GetPlayer.PilotRace)), LookupLocalizedTextByKey('Quest.SendLetter.' + IntToStr(QuestNumber) + '.PlayerRace')) > 0)) and (not Galaxy.HasPlayerQuestHistory(qtSendLetter, QuestNumber)) and MatchesCareerName(Ord(GetDominantCareer), LookupLocalizedTextByKey('Quest.SendLetter.' + IntToStr(QuestNumber) + '.Status')) then begin
                    Found := True;
                    Break;
                  end;
                  QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval + 37 * K);
                end;
                if Found then begin
                  Quest.QuestType := qtSendLetter;
                  Quest.Planet := CurrentPlanet;
                  Quest.Successful := False;
                  Quest.DeadlineTurn := QuestTuning[Ord(Quest.QuestType)].BaseDuration + 15 * (CurrentStar.StarDistances[I].Distance div 20 + 1);
                  if IsHealthEffectActive(24) then Quest.DeadlineTurn := Round(Quest.DeadlineTurn * 1.5);
                  Quest.DeadlineTurn := Galaxy.CurrentTurn + Round(Quest.DeadlineTurn / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestTimeAndExperienceFactor);
                  Quest.RewardMoney := QuestTuning[Ord(Quest.QuestType)].BaseRewardMoney + Round(QuestTuning[Ord(Quest.QuestType)].RewardCapitalPercent * Min(Galaxy.AverageRangerCapital * 0.01, GetPlayer.Wealth * 0.01));
                  Quest.RewardMoney := Round(Quest.RewardMoney * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestMoneyFactor);
                  if IsHealthEffectActive(23) then Quest.RewardMoney := Round(Quest.RewardMoney * SeededRandomFloatRange((Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval, 1.3, 2.3));
                  Quest.RewardMoney := Quest.RewardMoney + Round(Quest.RewardMoney * GetEffectiveSkillLevel(psCharisma) * 0.1);
                  Quest.RewardMoney := RoundAndTruncateToHundreds(Quest.RewardMoney);
                  Quest.ObjectiveTarget := Planet;
                  Quest.QuestNumber := QuestNumber;
                  Quest.CompletionText := LocalizedColorText('Quest.SendLetter.' + IntToStr(QuestNumber) + '.Status');
                  RefreshPlayerQuestTargets;
                  Result := True;
                  Exit;
                end;
              end;
            end;
        until Attempts > 20;
      end;
    if not HasQuestOfType(qtKillShip) and (Galaxy.CurrentTurn > 665) and (ForcedPlanetQuestId < 0) then
      if FractionalQuotient(CurrentPlanet.GenerationSeed, (Galaxy.CurrentTurn + 222) div Interval) < PlanetGovernmentMarket[Ord(CurrentPlanet.Government)].QuestOfferProbabilities[1] then
        for I := Min(20, Galaxy.Stars.Count - 1) downto 1 do begin
          Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
          if (Star.Constellation.Id <> 20) and Star.IsConstellationVisible and (Star.ControlFaction <> sfDominators) and (Star.Status.CustomFaction = '') then
            for J := 0 to Star.Ships.Count - 1 do begin
              Target := Star.Ships[J];
              if (Target.TypeId in [stRanger..stPirate]) and (Target <> Self) and (Target.ScriptShip = nil) and not Target.DestroyQueued and
                (Target.GetHull.HullPoints >= Target.GetHull.Weight / 1.5) then begin
                case Target.TypeId of
                  stRanger: begin
                    if (CurrentPlanet.GetRelationLevelToShip(Target) > rlBad) or Target.IsInPrison then Continue;
                  end;
                  stTransport: begin
                    case (Target as TTransport).TransportType of
                      ttTransport: if (CurrentPlanet.GetRelationLevelToShip(Target) > rlNormal) and (Target.GetTurnSeedFraction(10) < 0.99) then Continue;
                      ttLiner: if (CurrentPlanet.GetRelationLevelToShip(Target) > rlNormal) and (Target.GetTurnSeedFraction(10) < 0.99) then Continue;
                      ttDiplomat: if (CurrentPlanet.GetRelationLevelToShip(Target) > rlNormal) and (Target.GetTurnSeedFraction(10) < 0.99) then Continue;
                    end;
                  end;
                  stPirate: begin
                    if ((CurrentPlanet.GetRelationLevelToShip(Target) > rlNormal) and (Target.GetTurnSeedFraction(10) < 0.99)) or Target.IsInPrison then Continue;
                  end;
                end;
                MaximumQuest := StrToInt(AnsiString(LanguageDataConfig.GetParamByPathOrMarker('Quest.KillShip.Count'))) - 1;
                QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval);
                Found := False;
                for K := 0 to MaximumQuest do begin
                  FromFactions := LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(QuestNumber) + '.PlanetRace');
                  if (Pos(OwnerToSys(RaceToOwner(CurrentPlanet.RaceId)), FromFactions) > 0) and
                    ((CurrentPlanet.OwnerId = Byte(oiPirate)) or (Pos('OnlyPirate', FromFactions) <= 0)) and
                    ((CurrentPlanet.OwnerId <> Byte(oiPirate)) or (Pos('OnlyNonPirate', FromFactions) <= 0)) and
                    ((Pos(OwnerToSys(Target.OwnerId), LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(QuestNumber) + '.ShipRace')) > 0) or
                      ((Target is TPirate) and ((Target as TPirate).PirateType = 0) and (Target.OwnerId = Byte(oiPirate)) and
                       (Pos(OwnerToSys(RaceToOwner(Target.PilotRace)), LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(QuestNumber) + '.ShipRace')) > 0))) and
                    ((LanguageDataConfig.CountParamsByPath('Quest.KillShip.' + IntToStr(QuestNumber) + '.PlayerRace') = 0) or
                    (Pos(OwnerToSys(RaceToOwner(GetPlayer.PilotRace)), LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(QuestNumber) + '.PlayerRace')) > 0)) and (not Galaxy.HasPlayerQuestHistory(qtKillShip, QuestNumber)) and MatchesCareerName(Ord(GetDominantCareer), LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(QuestNumber) + '.Status')) then begin
                    ShipTypes := LookupLocalizedTextByKey('Quest.KillShip.' + IntToStr(QuestNumber) + '.ShipType');
                    case Target.TypeId of
                      stRanger: begin
                        if Pos('Ranger', ShipTypes) > 0 then Found := True;
                      end;
                      stTransport: begin
                        case (Target as TTransport).TransportType of
                          ttTransport: if Pos('Transport', ShipTypes) > 0 then Found := True;
                          ttLiner: if Pos('Liner', ShipTypes) > 0 then Found := True;
                          ttDiplomat: if Pos('Diplomat', ShipTypes) > 0 then Found := True;
                        end;
                      end;
                      stPirate: begin
                        if Pos('Pirate', ShipTypes) > 0 then Found := True;
                      end;
                    end;
                    if ShipTypes = 'Any' then Found := True;
                    if Found then Break;
                  end;
                  QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval + 47 * K);
                end;
                if Found then begin
                  Quest.QuestType := qtKillShip;
                  Quest.Planet := CurrentPlanet;
                  Quest.Successful := False;
                  Quest.DeadlineTurn := QuestTuning[Ord(Quest.QuestType)].BaseDuration + Round(RemapClamped(Target.Wealth, GetPlayer.Wealth div 2, 2 * GetPlayer.Wealth, 0, 30) + PointDistance(CurrentStar.Position, Target.CurrentStar.Position));
                  if IsHealthEffectActive(24) then Quest.DeadlineTurn := Round(Quest.DeadlineTurn * 1.5);
                  Quest.DeadlineTurn := Galaxy.CurrentTurn + Round(Quest.DeadlineTurn / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestTimeAndExperienceFactor);
                  Quest.RewardMoney := QuestTuning[Ord(Quest.QuestType)].BaseRewardMoney + Round((QuestTuning[Ord(Quest.QuestType)].RewardCapitalPercent * Min(Galaxy.AverageRangerCapital * 0.01, GetPlayer.Wealth * 0.01)) * RemapClamped(Target.Wealth, GetPlayer.Wealth div 2, 2 * GetPlayer.Wealth, 0.8, 1.2));
                  Quest.RewardMoney := Round(Quest.RewardMoney * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestMoneyFactor);
                  if IsHealthEffectActive(23) then Quest.RewardMoney := Round(Quest.RewardMoney * SeededRandomFloatRange((Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval, 1.3, 2.3));
                  Quest.RewardMoney := Quest.RewardMoney + Round(Quest.RewardMoney * GetEffectiveSkillLevel(psCharisma) * 0.1);
                  Quest.RewardMoney := RoundAndTruncateToHundreds(Quest.RewardMoney);
                  Quest.ObjectiveTarget := Target;
                  Quest.QuestNumber := QuestNumber;
                  Result := True;
                  RefreshPlayerQuestTargets;
                  Exit;
                end;
              end;
            end;
        end;
    FirstStar := 10;
    if ForcedPlanetQuestId >= 0 then FirstStar := 0;
    if not HasQuestOfType(qtPlanetQuest) then
      if (ForcedPlanetQuestId >= 0) or (FractionalQuotient(CurrentPlanet.GenerationSeed, (Galaxy.CurrentTurn + 333) div Interval) < PlanetGovernmentMarket[Ord(CurrentPlanet.Government)].QuestOfferProbabilities[2]) then
        for I := FirstStar to Galaxy.Stars.Count - 1 do begin
          Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
          if (Star.ShipTypeCounts[stKling] <= 0) and (Star.Battle = 0) and (Star.ControlFaction <> sfDominators) and (Star.Status.CustomFaction = '') and
            (Star.Constellation.Id <> 20) and Star.IsConstellationVisible then
            for J := 0 to Star.Planets.Count - 1 do begin
              Planet := Star.Planets[J];
              if not Planet.NoLanding and (Planet.OwnerId <> Byte(oiDominator)) and (Planet.TextQuestId <> -1) then
                if Planet.GetRelationLevelToShip(Self) > rlHostile then
                  if (LanguageDataConfig.GetBlockByPath('PlanetQuest.PlanetQuest').CountParams(IntToStr(Planet.TextQuestId)) > 0) and
                    ((ForcedPlanetQuestId < 0) or (Planet.TextQuestId = ForcedPlanetQuestId)) then begin
                    TextQuest := TTextQuest.Create;
                    Control := nil;
                    try
                      Control := TCBufControlEC.Create;
                      GlobalCache.ResetControl(Control);
                      Control.SetCacheKey('PlanetQuest.' + IntToStr(Planet.TextQuestId));
                      Buffer := AcquireOrCreateBuffer(Control);
                      TextQuest.LoadFromReader(Buffer.Buffer, True);
                    finally
                      if Control <> nil then begin Control.Release; Control.Free; end;
                    end;
                    // Native $764BB2 jumps directly to $764E16; a combined Boolean
                    // expression introduces temporaries in this DCC32 build.
                    if ForcedPlanetQuestId >= 0 then goto OfferPlanetQuest;
                    if (
                      (((CurrentPlanet.RaceId = Byte(oiMaloc)) and ((TextQuest.IssuerRaceMask and 1) <> 0)) or
                      ((CurrentPlanet.RaceId = Byte(oiPeleng)) and ((TextQuest.IssuerRaceMask and 2) <> 0)) or
                      ((CurrentPlanet.RaceId = Byte(oiHuman)) and ((TextQuest.IssuerRaceMask and 4) <> 0)) or
                      ((CurrentPlanet.RaceId = Byte(oiFeyan)) and ((TextQuest.IssuerRaceMask and 8) <> 0)) or
                      ((CurrentPlanet.RaceId = Byte(oiGaal)) and ((TextQuest.IssuerRaceMask and 16) <> 0))) and
                      (((Planet.OwnerId = Byte(oiUninhabited)) and ((TextQuest.TargetOwnerMask and $40) <> 0)) or
                      (((TextQuest.TargetOwnerMask and 1) <> 0) and (Planet.OwnerId = Byte(oiMaloc))) or
                      (((TextQuest.TargetOwnerMask and 2) <> 0) and (Planet.OwnerId = Byte(oiPeleng))) or
                      (((TextQuest.TargetOwnerMask and 4) <> 0) and (Planet.OwnerId = Byte(oiHuman))) or
                      (((TextQuest.TargetOwnerMask and 8) <> 0) and (Planet.OwnerId = Byte(oiFeyan))) or
                      (((TextQuest.TargetOwnerMask and 16) <> 0) and (Planet.OwnerId = Byte(oiGaal))) or ((TOwnerMask(TextQuest.TargetOwnerMask) = []) and (CurrentPlanet.OwnerId = Planet.OwnerId))) and
                      not Galaxy.HasPlayerQuestHistory(qtPlanetQuest, Planet.TextQuestId) and
                      ((((TextQuest.PlayerCareerMask and 1) <> 0) and (GetDominantCareer = rcTrader)) or
                      (((TextQuest.PlayerCareerMask and 2) <> 0) and (GetDominantCareer = rcPirate)) or
                      (((TextQuest.PlayerCareerMask and 4) <> 0) and (GetDominantCareer = rcWarrior))) and
                      ((((TextQuest.PlayerRaceMask and 1) <> 0) and (PilotRace = Byte(oiMaloc))) or
                      (((TextQuest.PlayerRaceMask and 2) <> 0) and (PilotRace = Byte(oiPeleng))) or
                      (((TextQuest.PlayerRaceMask and 4) <> 0) and (PilotRace = Byte(oiHuman))) or
                      (((TextQuest.PlayerRaceMask and 8) <> 0) and (PilotRace = Byte(oiFeyan))) or
                      (((TextQuest.PlayerRaceMask and 16) <> 0) and (PilotRace = Byte(oiGaal)))) and
                      (TextQuest.Difficulty < Galaxy.InterpolateSingleByTechLevel(0, 71) + 30 * Max(1, GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].GoodsEventDurationFactor))) then begin
                    OfferPlanetQuest:
                      Quest.QuestType := qtPlanetQuest;
                      Quest.Planet := CurrentPlanet;
                      Quest.Successful := False;
                      Quest.DeadlineTurn := 15 * (CurrentStar.StarDistances[I].Distance div 20 + 1);
                      if not TextQuest.CompleteOnFinish then Quest.DeadlineTurn := Quest.DeadlineTurn * 2;
                      Quest.DeadlineTurn := Quest.DeadlineTurn + QuestTuning[Ord(Quest.QuestType)].BaseDuration;
                      if IsHealthEffectActive(24) then Quest.DeadlineTurn := Round(Quest.DeadlineTurn * 1.5);
                      Quest.DeadlineTurn := Galaxy.CurrentTurn + Round(Quest.DeadlineTurn / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestTimeAndExperienceFactor);
                      Quest.RewardMoney := QuestTuning[Ord(Quest.QuestType)].BaseRewardMoney + Round((QuestTuning[Ord(Quest.QuestType)].RewardCapitalPercent * Min(Galaxy.AverageRangerCapital * 0.01, GetPlayer.Wealth * 0.01)) * RemapClamped(TextQuest.Difficulty, 50, 100, 1, 2.1));
                      Quest.RewardMoney := Round(Quest.RewardMoney * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestMoneyFactor);
                      if IsHealthEffectActive(23) then Quest.RewardMoney := Round(Quest.RewardMoney * SeededRandomFloatRange((Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval, 1.3, 2.3));
                      Quest.RewardMoney := Quest.RewardMoney + Round(Quest.RewardMoney * GetEffectiveSkillLevel(psCharisma) * 0.1);
                      Quest.RewardMoney := RoundAndTruncateToHundreds(Quest.RewardMoney);
                      Quest.ObjectiveTarget := Planet;
                      Quest.QuestNumber := Planet.TextQuestId;
                      Result := True;
                      RefreshPlayerQuestTargets;
                      TextQuest.Free;
                      Exit;
                    end;
                    TextQuest.Free;
                  end;
            end;
        end;
    if not HasQuestOfType(qtDefendSystem) and (ForcedPlanetQuestId < 0) and (CurrentStar.ShipTypeCounts[stKling] = 0) then
      if FractionalQuotient(CurrentPlanet.GenerationSeed, (Galaxy.CurrentTurn + 444) div Interval) < PlanetGovernmentMarket[Ord(CurrentPlanet.Government)].QuestOfferProbabilities[3] then
        for I := 0 to CurrentStar.Ships.Count - 1 do begin
          if CurrentStar.ShipTypeCounts[stPirate] < 2 then Break;
          Target := CurrentStar.Ships[I];
          if (CurrentStar.ShipTypeCounts[stPirate] >= 3) or ((Target.TypeId = stPirate) and (Target.OrderTarget is TTransport)) then begin
            MaximumQuest := StrToInt(AnsiString(LanguageDataConfig.GetParamByPathOrMarker('Quest.DefSystem.Count'))) - 1;
            QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval);
            Found := False;
            for K := 0 to MaximumQuest do begin
              FromFactions := LookupLocalizedTextByKey('Quest.DefSystem.' + IntToStr(QuestNumber) + '.PlanetRace');
              if (Pos(OwnerToSys(RaceToOwner(CurrentPlanet.RaceId)), FromFactions) > 0) and
                ((CurrentPlanet.OwnerId = Byte(oiPirate)) or (Pos('OnlyPirate', FromFactions) <= 0)) and
                ((CurrentPlanet.OwnerId <> Byte(oiPirate)) or (Pos('OnlyNonPirate', FromFactions) <= 0)) and ((LanguageDataConfig.CountParamsByPath('Quest.DefSystem.' + IntToStr(QuestNumber) + '.PlayerRace') = 0) or
                (Pos(OwnerToSys(RaceToOwner(GetPlayer.PilotRace)), LookupLocalizedTextByKey('Quest.DefSystem.' + IntToStr(QuestNumber) + '.PlayerRace')) > 0)) and (not Galaxy.HasPlayerQuestHistory(qtDefendSystem, QuestNumber)) and MatchesCareerName(Ord(GetDominantCareer), LookupLocalizedTextByKey('Quest.DefSystem.' + IntToStr(QuestNumber) + '.Status')) then begin
                Found := True;
                Break;
              end;
              QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval + 57 * K);
            end;
            if Found then begin
              Quest.QuestType := qtDefendSystem;
              Quest.Planet := CurrentPlanet;
              Quest.Successful := False;
              Quest.DeadlineTurn := QuestTuning[Ord(Quest.QuestType)].BaseDuration + SeededRandomIntRange(-10, 10, CurrentPlanet.GenerationSeed);
              if IsHealthEffectActive(24) then Quest.DeadlineTurn := Round(Quest.DeadlineTurn / 1.5);
              Quest.DeadlineTurn := Galaxy.CurrentTurn + Round(Quest.DeadlineTurn * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestTimeAndExperienceFactor);
              Quest.RewardMoney := QuestTuning[Ord(Quest.QuestType)].BaseRewardMoney + Round(QuestTuning[Ord(Quest.QuestType)].RewardCapitalPercent * Min(Galaxy.AverageRangerCapital * 0.01, GetPlayer.Wealth * 0.01));
              Quest.RewardMoney := Round(Quest.RewardMoney * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestMoneyFactor);
              if IsHealthEffectActive(23) then Quest.RewardMoney := Round(Quest.RewardMoney * SeededRandomFloatRange((Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval, 1.3, 2.3));
              Quest.RewardMoney := Quest.RewardMoney + Round(Quest.RewardMoney * GetEffectiveSkillLevel(psCharisma) * 0.1);
              Quest.RewardMoney := RoundAndTruncateToHundreds(Quest.RewardMoney);
              Quest.ObjectiveTarget := CurrentPlanet.CurrentStar;
              Quest.QuestNumber := QuestNumber;
              Result := True;
              RefreshPlayerQuestTargets;
              Exit;
            end;
          end;
        end;
    if not HasQuestOfType(qtDefendShip) and (ForcedPlanetQuestId < 0) then
      if FractionalQuotient(CurrentPlanet.GenerationSeed, (Galaxy.CurrentTurn + 555) div Interval) < PlanetGovernmentMarket[Ord(CurrentPlanet.Government)].QuestOfferProbabilities[4] then
        for I := 0 to Min(20, Galaxy.Stars.Count - 1) do begin
          Star := TObject(CurrentStar.StarDistances[I].Star) as TStar;
          if (Star.ShipTypeCounts[stKling] <= 0) and (Star.ShipTypeCounts[stPirate] >= 1) and (Star.Constellation.Id <> 20) and Star.IsConstellationVisible then
            for J := 0 to Star.Ships.Count - 1 do begin
              Target := Star.Ships[J];
              if GetPlayer <> Target then begin
                DefendedShip := Target;
                if (Target.TypeId in [stRanger..stPirate]) and (Target <> Self) and (Target.ScriptShip = nil) and
                  (((Target.TypeId <> stPirate) and (Star.ShipTypeCounts[stPirate] >= 2)) or
                   ((Target.EnemyShip <> nil) and (Target.EnemyShip.OrderTarget = Target) and (Target.EnemyShip.TypeId = stPirate))) and
                  ((I <= 0) or (CurrentPlanet = DefendedShip.HomePlanet)) and (CurrentPlanet.OwnerId = DefendedShip.OwnerId) and
                  (CurrentPlanet.GetRelationLevelToShip(DefendedShip) >= rlBad) and
                  ((DefendedShip.Order <> soJump) or (DefendedShip.EstimateOrderTravelTurns >= 6)) then
                  if (DefendedShip.GetHull.HullPoints >= DefendedShip.GetHull.Weight * 0.6) and not DefendedShip.DestroyQueued then begin
                    MaximumQuest := StrToInt(AnsiString(LanguageDataConfig.GetParamByPathOrMarker('Quest.DefShip.Count'))) - 1;
                    QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval);
                    Found := False;
                    for K := 0 to MaximumQuest do begin
                      FromFactions := LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(QuestNumber) + '.PlanetRace');
                      if (Pos(OwnerToSys(RaceToOwner(CurrentPlanet.RaceId)), FromFactions) > 0) and
                        ((CurrentPlanet.OwnerId = Byte(oiPirate)) or (Pos('OnlyPirate', FromFactions) <= 0)) and
                        ((CurrentPlanet.OwnerId <> Byte(oiPirate)) or (Pos('OnlyNonPirate', FromFactions) <= 0)) and (not Galaxy.HasPlayerQuestHistory(qtDefendShip, QuestNumber)) and ((LanguageDataConfig.CountParamsByPath('Quest.DefShip.' + IntToStr(QuestNumber) + '.PlayerRace') = 0) or
                        (Pos(OwnerToSys(RaceToOwner(GetPlayer.PilotRace)), LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(QuestNumber) + '.PlayerRace')) > 0)) and MatchesCareerName(Ord(GetDominantCareer), LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(QuestNumber) + '.Status')) then
                        if ((I = 0) and (LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(QuestNumber) + '.InThisSystem') = 'Yes')) or
                          ((I > 0) and (LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(QuestNumber) + '.InThisSystem') = 'No')) then begin
                          ShipTypes := LookupLocalizedTextByKey('Quest.DefShip.' + IntToStr(QuestNumber) + '.ShipType');
                          case DefendedShip.TypeId of
                            stRanger: begin
                              if Pos('Ranger', ShipTypes) > 0 then Found := True;
                            end;
                            stTransport: begin
                              case (DefendedShip as TTransport).TransportType of
                                ttTransport: if Pos('Transport', ShipTypes) > 0 then Found := True;
                                ttLiner: if Pos('Liner', ShipTypes) > 0 then Found := True;
                                ttDiplomat: if Pos('Diplomat', ShipTypes) > 0 then Found := True;
                              end;
                            end;
                            stPirate: begin
                              if Pos('Pirate', ShipTypes) > 0 then Found := True;
                            end;
                          end;
                          if ShipTypes = 'Any' then Found := True;
                          if Found then Break;
                        end;
                      QuestNumber := SeededRandomIntRange(0, MaximumQuest, (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval + 67 * K);
                    end;
                    if Found then begin
                      Quest.QuestType := qtDefendShip;
                      Quest.Planet := CurrentPlanet;
                      Quest.Successful := False;
                      Quest.DeadlineTurn := QuestTuning[Ord(Quest.QuestType)].BaseDuration + SeededRandomIntRange(-10, 10, CurrentPlanet.GenerationSeed);
                      if IsHealthEffectActive(24) then Quest.DeadlineTurn := Round(Quest.DeadlineTurn / 1.5);
                      Quest.DeadlineTurn := Galaxy.CurrentTurn + Round(Quest.DeadlineTurn * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestTimeAndExperienceFactor);
                      Quest.RewardMoney := QuestTuning[Ord(Quest.QuestType)].BaseRewardMoney + Round(QuestTuning[Ord(Quest.QuestType)].RewardCapitalPercent * Min(Galaxy.AverageRangerCapital * 0.01, GetPlayer.Wealth * 0.01));
                      Quest.RewardMoney := Round(Quest.RewardMoney * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[5]].QuestMoneyFactor);
                      if IsHealthEffectActive(23) then Quest.RewardMoney := Round(Quest.RewardMoney * SeededRandomFloatRange((Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div Interval, 1.3, 2.3));
                      Quest.RewardMoney := Quest.RewardMoney + Round(Quest.RewardMoney * GetEffectiveSkillLevel(psCharisma) * 0.1);
                      Quest.RewardMoney := RoundAndTruncateToHundreds(Quest.RewardMoney);
                      Quest.ObjectiveTarget := DefendedShip;
                      Quest.QuestNumber := QuestNumber;
                      Result := True;
                      RefreshPlayerQuestTargets;
                      Exit;
                    end;
                  end;
              end;
            end;
        end;
  end;
  ResponseText := PickLocalizedTextVariant('FormGov.DontQuest.WeDontHaveQuest', CurrentPlanet.GenerationSeed * (Galaxy.CurrentTurn div 5) + 1895643);
end;
{ @end $76332C }

{ @routine $766980 TRanger_BuildQuestText }
function TRanger.BuildQuestText(Quest: TQuest; Kind: TQuestTextKind): WideString;
var Text, Suffix: WideString; TextQuest: TTextQuest; Control: TCacheControlEC; Buffer: TCBufEC;
begin
  case Quest.QuestType of
    qtSendLetter: begin
      if Kind = qtkCompletion then Suffix := '.End'
      else Suffix := '.Start';
      Text := LocalizedColorText('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + Suffix);
      ReplaceTextToken(Text, '<ToPlanet>', (Quest.ObjectiveTarget as TPlanet).Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<ToStar>', (Quest.ObjectiveTarget as TPlanet).CurrentStar.Name, '<color=255,240,100>');
      if CurrentPlanet <> nil then
      ReplaceTextToken(Text, '<Parsec>', IntToStr(Round(PointDistance((Quest.ObjectiveTarget as TPlanet).CurrentStar.Position, CurrentPlanet.CurrentStar.Position))), '<color=255,240,100>')
      else
      ReplaceTextToken(Text, '<Parsec>', IntToStr(Round(PointDistance((Quest.ObjectiveTarget as TPlanet).CurrentStar.Position, CurrentStar.Position))), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Quest.DeadlineTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Day>', IntToStr(Quest.DeadlineTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
      if Quest.Planet <> nil then begin
      ReplaceTextToken(Text, '<FromPlanet>', Quest.Planet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromStar>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
      end
      else
      ReplaceTextToken(Text, '<FromPlanet>', '*** Какая еще планета? Это база!!! ***', '<color=255,0,0>');
      Result := Text;
    end;
    qtKillShip: begin
      if Kind = qtkCompletion then Suffix := '.End'
      else Suffix := '.Start';
      Text := LocalizedColorText('Quest.KillShip.' + IntToStr(Quest.QuestNumber) + Suffix);
      ReplaceTextToken(Text, '<InStar>', (Quest.ObjectiveTarget as TShip).CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Quest.DeadlineTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Day>', IntToStr(Quest.DeadlineTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
      if Quest.Planet <> nil then begin
      ReplaceTextToken(Text, '<FromPlanet>', Quest.Planet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromStar>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
      end;
      ReplaceTextToken(Text, '<Ship>', (Quest.ObjectiveTarget as TShip).GetName, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FullShip>', (Quest.ObjectiveTarget as TShip).GetFullName(' '), '<color=255,240,100>');
      Result := Text;
    end;
    qtPlanetQuest: begin
      TextQuest := TTextQuest.Create;
      Control := nil;
      try
        Control := TCBufControlEC.Create;
        GlobalCache.ResetControl(Control);
        Control.SetCacheKey('PlanetQuest.' + IntToStr(Quest.QuestNumber));
        Buffer := AcquireOrCreateBuffer(Control);
        TextQuest.LoadFromReader(Buffer.Buffer, True);
      finally
        if Control <> nil then begin
          Control.Release;
          Control.Free;
        end;
      end;
      if Kind = qtkCompletion then Text := TextQuest.QuestSuccessGovMessageText.Text
      else Text := TextQuest.QuestDescriptionText.Text;
      ReplaceTextToken(Text, '<Ranger>', GetPlayer.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<ToPlanet>', (Quest.ObjectiveTarget as TPlanet).Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<ToStar>', (Quest.ObjectiveTarget as TPlanet).CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Parsec>', IntToStr(Round(PointDistance(Quest.Planet.CurrentStar.Position, (Quest.ObjectiveTarget as TPlanet).CurrentStar.Position))), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Quest.DeadlineTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Day>', IntToStr(Quest.DeadlineTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromPlanet>', Quest.Planet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromStar>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
      ExpandLocalizedTextMarkup(Text);
      TextQuest.Free;
      Result := Text;
    end;
    qtDefendSystem: begin
      if Kind = qtkCompletion then Suffix := '.End'
      else Suffix := '.Start';
      Text := LocalizedColorText('Quest.DefSystem.' + IntToStr(Quest.QuestNumber) + Suffix);
      ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Quest.DeadlineTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Day>', IntToStr(Quest.DeadlineTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
      if Quest.Planet <> nil then begin
      ReplaceTextToken(Text, '<FromPlanet>', Quest.Planet.Name, '<color=255,240,100>');
      end
      else
      ReplaceTextToken(Text, '<FromPlanet>', '*** Какая еще планета? Это база!!! ***', '<color=255,0,0>');
      ReplaceTextToken(Text, '<FromStar>', (Quest.ObjectiveTarget as TStar).Name, '<color=255,240,100>');
      Result := Text;
    end;
    qtDefendShip: begin
      if Kind = qtkCompletion then Suffix := '.End'
      else if Kind = qtkProtectedShipLost then Suffix := '.Special'
      else Suffix := '.Start';
      Text := LocalizedColorText('Quest.DefShip.' + IntToStr(Quest.QuestNumber) + Suffix);
      ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(Quest.DeadlineTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Day>', IntToStr(Quest.DeadlineTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Money>', IntToStr(Quest.RewardMoney), '<color=255,240,100>');
      if Quest.Planet <> nil then begin
      ReplaceTextToken(Text, '<FromPlanet>', Quest.Planet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromStar>', Quest.Planet.CurrentStar.Name, '<color=255,240,100>');
      end;
      ReplaceTextToken(Text, '<InStar>', (Quest.ObjectiveTarget as TShip).CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Ship>', (Quest.ObjectiveTarget as TShip).GetName, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FullShip>', (Quest.ObjectiveTarget as TShip).GetFullName(' '), '<color=255,240,100>');
      if (Galaxy.TechLevel < 7) and (Suffix = '.Start') then Text := Text + #13#10 + LocalizedColorText('Quest.DefShip.AddText');
      Result := Text;
    end;
  end;
end;
{ @end $766980 }

{ @routine $76793C TRanger_PublishQuestStatus }
procedure TRanger.PublishQuestStatus(Quest: PQuest; Outcome: Integer);
var Text: WideString; Message: TMessagePlayer;
begin
  Text := '';
  if Outcome = 0 then begin
    if Quest.Successful then
      Text := Text + WrapTextInColor(LocalizedColorText('Quest.Info.CurQuests.Accepted'), '<color=255,240,100>') + #13#10
    else begin
      Text := Text + WrapTextInColor(LocalizedColorText('Quest.Info.CurQuests.NotAccepted'), '<color=255,240,100>') + #13#10;
      Text := Text + FormatText1(LocalizedColorText('Quest.Info.CountDay'), '<color=255,240,100>', '<Day>', IntToStr(Quest.DeadlineTurn - Galaxy.CurrentTurn)) + #13#10;
    end;
  end
  else if Outcome > 0 then
    Text := Text + WrapTextInColor(LocalizedColorText('Quest.Info.OldQuests.Accepted'), '<color=0,255,0>') + #13#10
  else Text := Text + WrapTextInColor(LocalizedColorText('Quest.Info.OldQuests.NotAccepted'), '<color=255,0,0>') + #13#10;
  Text := Text + FormatText2(LocalizedColorText('Quest.Info.FromPlanet'), '<color=255,240,100>', '<Planet>', Quest.Planet.Name,
    '<System>', Quest.Planet.CurrentStar.Name) + #13#10;
  Text := Text + #13#10 + ' ' + #13#10 + Quest.Description;
  if Outcome = 0 then begin
    if Quest.Planet <> nil then begin
      Message := AddOrUpdatePlayerBubble(3, Galaxy.CurrentTurn, Text, 'ZP_' + IntToStr(Cardinal(Quest.Planet.Id)) + '_' + IntToStr(Quest.QuestNumber));
      if Quest.ObjectiveTarget <> nil then
        if Quest.ObjectiveTarget is TShip then Message.Targets[0].ShipId := TShip(Quest.ObjectiveTarget).Id
        else if Quest.ObjectiveTarget is TPlanet then Message.Targets[0].PlanetId := TPlanet(Quest.ObjectiveTarget).Id
        else if Quest.ObjectiveTarget is TStar then Message.Targets[0].PlanetId := Quest.Planet.Id;
    end;
  end
  else if Outcome > 0 then begin
    if Quest.Planet <> nil then AddOrUpdatePlayerBubble(4, Galaxy.CurrentTurn, Text, 'ZP_' + IntToStr(Cardinal(Quest.Planet.Id)) + '_' + IntToStr(Quest.QuestNumber));
  end
  else if Quest.Planet <> nil then AddOrUpdatePlayerBubble(5, Galaxy.CurrentTurn, Text, 'ZP_' + IntToStr(Cardinal(Quest.Planet.Id)) + '_' + IntToStr(Quest.QuestNumber));
end;
{ @end $76793C }

{ @routine $768000 TRanger_ProcessShipDestructionQuests }
procedure TRanger.ProcessShipDestructionQuests(Ship: TShip);
var
  I, J: Integer;
  Ranger: TRanger;
  Quest: PQuest;
  Text: WideString;
begin
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(Galaxy.Rangers[I]);
    for J := Ranger.Quests.Count - 1 downto 0 do
    begin
      Quest := PQuest(Ranger.Quests[J]);
      if (Ship is TTransport) and Ship.InNormalSpace and not Ship.DestroyQueued and not Quest.Successful and
        (Quest.QuestType = qtDefendSystem) and ((Quest.ObjectiveTarget as TStar) = Ship.CurrentStar) then
      begin
          if (Quest.Planet <> nil) and (Quest.Planet.GetRelationLevelToShip(Self) > rlBad) then
            Quest.Planet.SetRelationLevelToRanger(Ranger, rlBad);
          { Native assumes Planet is present after the guarded update above. }
          if (Quest.Planet.OwnerId = Byte(oiPirate)) and (MainPiratePlanet <> nil) and (MainPiratePlanet.GetRelationLevelToShip(Self) > rlBad) then
          begin
            if MainPiratePlanet.GetRelationLevelToShip(Self) = rlNormal then MainPiratePlanet.SetRelationLevelToRanger(Self, rlBad);
            if MainPiratePlanet.GetRelationLevelToShip(Self) = rlGood then MainPiratePlanet.SetRelationLevelToRanger(Self, rlNormal);
            if MainPiratePlanet.GetRelationLevelToShip(Self) >= rlExcellent then MainPiratePlanet.SetRelationLevelToRanger(Self, rlGood);
          end;
          if GetPlayer = Ranger then
          begin
            Text := PickLocalizedTextVariant('GalaxyNews.Quest.Failure.DeadShipInDefSystem', Seed * Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Planet>', Quest.Planet.Name, '<color=255,240,100>');
            ReplaceTextToken(Text, '<Relation>', Quest.Planet.GetRelationLevelTextToShip(Ranger), '<color=255,240,100>');
            ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), '<color=255,240,100>');
            ReplaceTextToken(Text, '<Star>', (Quest.ObjectiveTarget as TStar).Name, '<color=255,240,100>');
            AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
          end;
        { The original calls these on Self, even while iterating another ranger's quests. }
        PublishQuestStatus(Quest, -1);
        ArchiveQuest(J);
      end;
      { Native continues reading Quest after that archive; retain the original ordering. }
      if (Ship.TypeId in [stRanger..stPirate]) and (Quest.QuestType = qtDefendShip) and (Ship = Quest.ObjectiveTarget) then
      begin
        if not Quest.Successful then
        begin
          if (Quest.Planet <> nil) and (Quest.Planet.GetRelationLevelToShip(Self) > rlBad) then
            Quest.Planet.SetRelationLevelToRanger(Ranger, rlBad);
          { Native assumes Planet is present after the guarded update above. }
          if (Quest.Planet.OwnerId = Byte(oiPirate)) and (MainPiratePlanet <> nil) and (MainPiratePlanet.GetRelationLevelToShip(Self) > rlBad) then
          begin
            if MainPiratePlanet.GetRelationLevelToShip(Self) = rlNormal then MainPiratePlanet.SetRelationLevelToRanger(Self, rlBad);
            if MainPiratePlanet.GetRelationLevelToShip(Self) = rlGood then MainPiratePlanet.SetRelationLevelToRanger(Self, rlNormal);
            if MainPiratePlanet.GetRelationLevelToShip(Self) >= rlExcellent then MainPiratePlanet.SetRelationLevelToRanger(Self, rlGood);
          end;
          if GetPlayer = Ranger then
          begin
            Text := PickLocalizedTextVariant('GalaxyNews.Quest.Failure.DeadDefShip', Seed * Cardinal(Galaxy.CurrentTurn div 10));
            ReplaceTextToken(Text, '<Planet>', Quest.Planet.Name, '<color=255,240,100>');
            ReplaceTextToken(Text, '<Relation>', Quest.Planet.GetRelationLevelTextToShip(Ranger), '<color=255,240,100>');
            ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), '<color=255,240,100>');
            ReplaceTextToken(Text, '<Star>', Ship.CurrentStar.Name, '<color=255,240,100>');
            AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
          end;
          PublishQuestStatus(Quest, -1);
          ArchiveQuest(J);
        end
        else
        begin
          Quest.SpecialCompletionText := GetPlayer.BuildQuestText(Quest^, qtkProtectedShipLost);
          Quest.ObjectiveTarget := nil;
          RefreshPlayerQuestTargets;
        end;
      end;
    end;
    for J := 0 to Ranger.Quests.Count - 1 do
    begin
      Quest := PQuest(Ranger.Quests[J]);
      if not Quest.Successful and (Quest.QuestType = qtKillShip) and (Ship = Quest.ObjectiveTarget) then
      begin
        if GetPlayer = Ranger then
        begin
          Text := PickLocalizedTextVariant('GalaxyNews.Quest.Successful.KillShip', Galaxy.GenerationSeed * Cardinal(Galaxy.CurrentTurn div 10));
          ReplaceTextToken(Text, '<Planet>', Quest.Planet.Name, '<color=255,240,100>');
          ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), '<color=255,240,100>');
          AddOrUpdatePlayerBubble(0, Galaxy.CurrentTurn, Text, '');
        end;
        Quest.Successful := True;
        PublishQuestStatus(Quest, 0);
        Quest.ObjectiveTarget := nil;
        Ship.DestroyQueued := True;
        RefreshPlayerQuestTargets;
      end;
    end;
  end;
end;
{ @end $768000 }

{ @routine $7687D4 TRanger_HasQuestOfType }
function TRanger.HasQuestOfType(QuestType: TQuestType): Boolean;
var
  I: Integer;
  Quest: PQuest;
begin
  for I := 0 to Quests.Count - 1 do
  begin
    Quest := PQuest(Quests[I]);
    if Quest.QuestType = QuestType then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{ @end $7687D4 }

{ @routine $768834 TRanger_ShouldKeepShipForQuests }
function TRanger.ShouldKeepShipForQuests(Ship: TShip): Boolean;
var
  I: Integer;
  Quest: PQuest;
  OldQuest: PPlayerOldQuest;
  Player: TPlayer;
begin
  Result := False;
  if GetPlayer <> Self then Exit;
  Player := GetPlayer;
  for I := 0 to Player.Quests.Count - 1 do
  begin
    Quest := PQuest(Player.Quests[I]);
    case Quest.QuestType of
      qtKillShip: Result := (Quest.ObjectiveTarget as TShip) = Ship;
      qtDefendShip: Result := (Quest.ObjectiveTarget as TShip) = Ship;
    end;
    if Result then Exit;
  end;
  if PlayerOldQuests.Count > 0 then
  begin
    OldQuest := PPlayerOldQuest(PlayerOldQuests[PlayerOldQuests.Count - 1]);
    if Pos(Ship.Name, OldQuest.Description) > 0 then Result := True;
  end;
end;
{ @end $768834 }

{ @routine $76891C TRanger_RefreshPlayerQuestTargets }
procedure TRanger.RefreshPlayerQuestTargets;
var
  I: Integer;
  Quest: PQuest;
  Player: TPlayer;
begin
  if GetPlayer <> Self then Exit;
  Player := GetPlayer;
  Player.QuestTargetKillShip := nil;
  Player.QuestTargetDefendShip := nil;
  Player.QuestTargetDefendStar := nil;
  for I := 0 to Player.Quests.Count - 1 do
  begin
    Quest := PQuest(Player.Quests[I]);
    if not Quest.Successful then
      case Quest.QuestType of
        qtKillShip: Player.QuestTargetKillShip := Quest.ObjectiveTarget as TShip;
        qtDefendShip: Player.QuestTargetDefendShip := Quest.ObjectiveTarget as TShip;
        qtDefendSystem: Player.QuestTargetDefendStar := TStar(Quest.ObjectiveTarget);
      end;
  end;
end;
{ @end $76891C }

end.
