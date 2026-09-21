unit fRuinsTalk;
// Unit bracket (inferred): .text 0x005A5FA8..0x005DC4DA; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses aGalaxy, aPlanet, EC_CacheFont, GI_Label, Types, EC_BlockPar, aItem, aScript, GI_MessageLoop, fPanelMain, fPanelRuins, fPanelLoad;

type
  TDominionTravelQuote = packed record // @size $0C Four seeded draws are merged by destination.
    Star: TStar; // @offset $00
    DrawCount: Integer; // @offset $04
    Cost: Integer; // @offset $08
  end;

  TConstructionEquipment = record // @size $08 Borrowed item selection and source: 0=hold, 1=storage, 2=shop.
    Item: TEquipment; // @offset $00
    Source: Byte; // @offset $04
  end;

  TResearchItemSortKey = record // @size $0C Native sort helpers at $5A7E14..$5A7F9D.
    Priority: Byte; // @offset $00
    Cost: Integer; // @offset $04
    Weight: Integer; // @offset $08
  end;
  TResearchItemVisited = array of Boolean;
  TResearchItemIndexes = array of Integer;

  TfRuinsTalk = class(TMessageLoopGIWithMainPanel) // @size 0x10C
  public
    ResearchItemVisited: array of Boolean; // @offset $F8
    ResearchItemIndexes: array of Integer; // @offset $FC Negative entries terminate the sorted sale list.
    function SortResearchItems(Series: Byte): Integer; // @addr $5A7FA0 Returns inventory count; unused sorted slots are -1.
    function IsResearchItemQuestLetter(Item: TItem): Boolean; // @addr $5A813C
    function CountResearchRemains(Series: Byte; Count: Integer): Integer; // @addr $5A82A0
    function CountResearchEquipment(Count: Integer): Integer; // @addr $5A8354
    procedure BuildResearchItemChoices(Series: Byte; var Text: WideString); // @addr $5A83EC
    StationOwner: Byte; // @offset $EE Copied from the docked ship on entry.
    StationType: Byte; // @offset $EF Copied from the docked ship on entry.
    procedure ContinueDominatorVictoryDialog(Action: Integer); // @addr $5AB3E4
    function ShowDominatorVictoryDialog: Boolean; // @addr $5AABA4
    procedure ShowMilitaryBaseRepairQuote(Action: Integer); // @addr $5BC9FC
    procedure AcceptMilitaryBaseRepair(Action: Integer); // @addr $5BCE50
    procedure AcceptMilitaryBasePrograms(Action: Integer); // @addr $5BD3FC
    procedure AcceptMilitaryBaseWarOperation(Action: Integer); // @addr $5BD94C
    procedure ConfirmMilitaryBaseTravel(Action: Integer); // @addr $5BE104
    procedure DeclineMilitaryBaseTravel(Action: Integer); // @addr $5BE6E0
    procedure ShowMilitaryBaseArrivalInfo(Action: Integer); // @addr $5BE87C
    procedure ShowMilitaryBaseArrivalQuestions(Action: Integer); // @addr $5BECC4
    procedure ShowMilitaryBaseArrivalDialog(Action: Integer); // @addr $5BE484
    procedure RunInjectedDialog(Action: Integer); // @addr $5D1948
    procedure RunInjectedDialogKeepingScroll(Action: Integer); // @addr $5D1B14
    PresentedTextLength: Integer; // @offset $E0
    TextPresentationTimer: PCallbackTimerGI; // @offset $E4
    LargePortraitLayout: Boolean; // @offset $100 Viewport is at least 1280x960; permits HD portraits or the table layout.
    PortraitTableVisible: Boolean; // @offset $101 Large layout with UseTablesForGov; shows the table and standard portrait animations.
    procedure AdvanceTextPresentation(Timer: PCallbackTimerGI; UserData: Integer); // @addr $5A9758
    procedure PortraitCycleComplete(Sender: TObjectGI); // @addr $5A9BE0
    procedure SelectPortraitAnimation(Alternate: Boolean); // @addr $5A9C1C
    procedure ShowDominionWarOperationDialog(Action: Integer); // @addr $5D9DEC
    procedure ShowDominionRelocationDialog(Action: Integer); // @addr $5D7E18
    procedure ShowDominionAmbushDialog(Action: Integer); // @addr $5DACC8
    procedure ShowDominionAssaultDialog(Action: Integer); // @addr $5DBA5C
    procedure ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5A9504
    procedure ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint); // @addr $5A9584
    function CreateChoiceBullet(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI; // @addr $5A9E90
    StationTransientControl: TObjectGI; // @offset $104
    SavedChoiceScroll: Integer; // @offset $108
    NextPortraitCycleAlternate: Boolean; // @offset $EC
    StationPanel: TfPanelRuins; // @offset $D4 Owned.
    LoadPanel: TfPanelLoad; // @offset $D8 Owned.
    constructor Create; // @addr $5A60C0
    destructor Destroy; override; // @addr $5A612C
    ChoiceHeight: Integer; // @offset $E8 Accumulated dialogue-choice row height.
    DialogText: WideString; // @offset 0xDC
    ShowArrivalVideo: Boolean; // @offset $ED Set after docked hyperspace travel; OnOpen tests this together with SkipVideo.
    ScriptVideoStartedAt: Cardinal; // @offset $F0 timeGetTime timestamp used by the queued-video callback.
    ScriptVideoTimer: PCallbackTimerGI; // @offset $F4
    procedure AdvanceScriptVideo(Timer: PCallbackTimerGI; UserData: Integer); // @addr $5AA424 Advances Film over the native 138-second interval.

    procedure OnClose; override; // @addr $5A7D4C
    procedure EndTurnClicked(Sender: TObjectGI); // @addr $5A899C
    procedure ShipClicked(Sender: TObjectGI); // @addr $5A8C24
    procedure ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer); override; // @addr $5A9F74
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal); // @addr $5AA06C
    procedure AddMessageClicked(Sender: TObjectGI); // @addr $5AA2B4
    procedure SelectMusic; override; // @addr $5AA618
    procedure InitializeLayout; override; // @addr $5A63F4
    procedure LayoutStationPortrait(Panel: TObjectGI); // @addr $5A6B84
    procedure OnOpen; override; // @addr 0x5A7100 @note "Native diagnostic name: TfRuinsTalk.BeforeRun."
    procedure DepartWithStation(Action: Integer); // @addr $5BE3E0
    procedure ClearChoices; // @addr $5A8CF8 Native diagnostic name: TfRuinsTalk.A_Start.
    procedure RestartTextPresentation; // @addr $5A96B8 Clears the dialogue panel state and restarts its ten-millisecond presentation timer.
    procedure I_Start; // @addr 0x5AA9D8 Rebuilds the station dialogue root; receiver-only entry verified at native prologue and CheatNextRank.
    procedure M_Main(KeepText: Boolean); // @addr 0x5AB408 Rebuilds choices; KeepText preserves the current greeting and skips rank rewards.
    procedure I_WarWithKlingAndPirates(Action: Integer); // @addr 0x5BB9A0
    procedure I_CBWarWithKlingAndCoalition(Action: Integer); // @addr 0x5D8EB0
    procedure AddChoice(Text: WideString; Value: Integer; Callback: TDialogChoiceEventGI); // @addr 0x5A8EF8 @note "Text filters may disable or suppress the choice. Invokes the method callback with Value in EDX."
    procedure ShowBridgeBlackHoleDialog(Action: Integer); // @addr $5AE59C
    procedure ShowInterceptorDialog(Action: Integer); // @addr $5AE98C
    procedure SelectBridgeBlackHoleDestination(Action: Integer); // @addr $5AE8E8
    procedure RecallInterceptorsFromTarget(Action: Integer); // @addr $5AFCB4
    procedure RecallAllInterceptors(Action: Integer); // @addr $5AFCF0
    procedure IncreaseInterceptorPassCount(Action: Integer); // @addr $5B0288
    procedure DecreaseInterceptorPassCount(Action: Integer); // @addr $5B02C4
    procedure SelectInterceptorTarget(Action: Integer); // @addr $5B073C
    procedure ClearInterceptorTarget(Action: Integer); // @addr $5B0768
    procedure SelectInterceptorStrategy(Action: Integer); // @addr $5B0F94
    procedure ShowBridgeHelpAnswer(Action: Integer); // @addr $5B11B0
    procedure ShowInterceptorTargetDialog(Action: Integer); // @addr $5B0300
    procedure ShowInterceptorStrategyDialog(Action: Integer); // @addr $5B0794
    procedure ShowActiveInterceptors(Action: Integer); // @addr $5AF828
    procedure ShowInterceptorPassDialog(Action: Integer); // @addr $5AFD94
    procedure ShowBridgeHelp(Action: Integer); // @addr $5B0FC4
    procedure BuyRangerCenterMicroModule(Action: Integer); // @addr $5B5734
    procedure ExchangeMicroModuleForNodes(Action: Integer); // @addr $5B66B4
    procedure ShowRangerCenterTakeNodeDialog(Action: Integer); // @addr $5B4ACC
    procedure ShowRangerCenterGiveNodeDialog(Action: Integer); // @addr $5B5B84
    procedure AcceptPirateBaseNationality(Action: Integer); // @addr $5B7604
    procedure BuyPirateBaseNodes(Action: Integer); // @addr $5B903C
    procedure BuyPirateBaseProgram(Action: Integer); // @addr $5B9AF0
    procedure AcceptPirateBaseRepair(Action: Integer); // @addr $5BA464
    procedure BuyPirateBaseChameleon(Action: Integer); // @addr $5BB720
    procedure ShowPirateBaseProgramDialog(Action: Integer); // @addr $5B9348
    procedure ShowPirateBaseNodeDialog(Action: Integer); // @addr $5B8AF4
    procedure ShowPirateBaseRepairDialog(Action: Integer); // @addr $5B9E48
    procedure ShowPirateBaseChameleonDialog(Action: Integer); // @addr $5BB194
    procedure ConfirmPirateBaseSubCrack(Action: Integer); // @addr $5BA9F8
    procedure BuyPirateBaseSubCrack(Action: Integer); // @addr $5BAD34
    procedure BuyPirateBaseSubCrackHalfPrice(Action: Integer); // @addr $5BAED0
    procedure DeclinePirateBaseSubCrack(Action: Integer); // @addr $5BB080
    procedure DeclinePirateBaseNationality(Action: Integer); // @addr $5B7F60
    procedure DeclinePirateBaseSideChange(Action: Integer); // @addr $5B8990
    procedure DeclinePirateBaseProgram(Action: Integer); // @addr $5B9D14
    procedure DeclinePirateBaseRepair(Action: Integer); // @addr $5BA750
    procedure DeclinePirateBaseChameleon(Action: Integer); // @addr $5BB864
    procedure ShowPirateBaseSubCrackDialog(Action: Integer); // @addr $5BA800
    procedure ShowMilitaryBaseRepairDialog(Action: Integer); // @addr $5BC86C
    procedure ShowMilitaryBaseWarOperationDialog(Action: Integer); // @addr $5BD528
    procedure ShowMilitaryBaseTravelDialog(Action: Integer); // @addr $5BDFBC
    procedure ShowMilitaryBaseProgramsDialog(Action: Integer); // @addr $5BD000
    procedure ShowScienceBaseImprovementItems(Action: Integer); // @addr $5BEF50
    procedure ShowScienceBaseImprovementQuote(Action: Integer); // @addr $5BF714
    procedure SelectScienceBaseImprovementKind(Action: Integer); // @addr $5C003C
    procedure AcceptScienceBaseImprovement(Action: Integer); // @addr $5C03C8
    procedure ShowScienceBaseRepairQuote(Action: Integer); // @addr $5C0A80
    procedure AcceptScienceBaseRepair(Action: Integer); // @addr $5C1118
    procedure ShowScienceBaseImprovementDialog(Action: Integer); // @addr $5BEE14
    procedure ShowScienceBaseRepairDialog(Action: Integer); // @addr $5C08F0
    procedure SellResearchRemains(Action: Integer); // @addr $5C2860
    procedure SellResearchEquipment(Action: Integer); // @addr $5C2E6C
    procedure SellResearchItem(Action: Integer); // @addr $5C3464
    procedure SelectScienceBaseResearchSection(Action: Integer); // @addr $5C2494
    procedure DeclineScienceBaseResearch(Action: Integer); // @addr $5C3A1C
    procedure AcceptScienceBaseResearchProgram(Action: Integer); // @addr $5C3FDC
    procedure DeclineScienceBaseResearchProgram(Action: Integer); // @addr $5C41F0
    procedure ShowScienceBaseResearchDialog(Action: Integer); // @addr $5C1DDC
    procedure BuyScienceBaseResearchProgram(Action: Integer); // @addr $5C3C20
    procedure ShowScienceBaseHistoryDialog(Action: Integer); // @addr $5C430C
    procedure AcceptBusinessCenterInvestment(Action: Integer); // @addr $5CA654
    procedure DeclineBusinessCenterInvestment(Action: Integer); // @addr $5CC734
    procedure ShowBusinessCenterInvestmentDialog(Action: Integer); // @addr $5C6FBC
    procedure BuyBusinessCenterTradeAdvice(Action: Integer); // @addr $5CD528
    procedure DeclineBusinessCenterTradeAdvice(Action: Integer); // @addr $5CDA30
    procedure ShowBusinessCenterTradeDialog(Action: Integer); // @addr $5CC850
    procedure ShowDominionImprovementItems(Action: Integer); // @addr $5D4A64
    procedure ShowDominionImprovementQuote(Action: Integer); // @addr $5D5228
    procedure AcceptDominionImprovement(Action: Integer); // @addr $5D57D8
    procedure BuyDominionPirateLicense(Action: Integer); // @addr $5D616C
    procedure DeclineDominionPirateLicense(Action: Integer); // @addr $5D6314
    function CheckDominionServiceStanding(RequiredRank: Byte; Prefix: WideString; CreditCost: Single): Boolean; // @addr $5D64E4
    procedure SpendDominionServiceCredit(CreditCost: Single); // @addr $5D67E8
    function CheckDominionAvailable: Boolean; // @addr $5D6878
    procedure ConfirmDominionTravel(Action: Integer); // @addr $5D7318
    procedure AcceptDominionTravel(Action: Integer); // @addr $5D768C
    procedure DeclineDominionCancelTravel(Action: Integer); // @addr $5D7BE8
    procedure AcceptDominionRelocation(Action: Integer); // @addr $5D8590
    procedure AcceptDominionWarOperation(Action: Integer); // @addr $5DA21C
    procedure AcceptDominionAmbush(Action: Integer); // @addr $5DB720
    procedure AcceptDominionAssault(Action: Integer); // @addr $5DC1A4
    procedure ShowDominionImprovementDialog(Action: Integer); // @addr $5D4928
    procedure BuyStationSpecialShip(Action: Integer); // @addr $5D15E0
    procedure DeclineStationSpecialShip(Action: Integer); // @addr $5D1500
    procedure ShowStationSpecialShipDialog(Action: Integer); // @addr $5D086C
    procedure BuildBuiltinServiceOptions; // @addr 0x5B1494
    procedure OpenStationModernization(QuotedCost: Integer); // @addr 0x5B4234 @note "Zero requests a quote; a nonzero quote is charged and enables sponsorship. Sponsored stations open the equipment-refit screen."
    procedure DeclineStationModernization(Action: Integer); // @addr $5B4710
    procedure ShowRangerCenterNodeInfoContinuation(Action: Integer); // @addr $5B6BFC
    procedure DepositNodesAtRangerCenter(Action: Integer); // @addr 0x5B48E4 @note "Deposits every carried node stack."
    procedure ShowRangerCenterNodeInfo(Action: Integer); // @addr 0x5B6A50
    procedure ShowPirateBaseNationalityDialog(Action: Integer); // @addr 0x5B6F38
    procedure ShowPirateBaseSideChangeDialog(Action: Integer); // @addr 0x5B80BC
    procedure AcceptPirateBaseSideChange(Action: Integer); // @addr 0x5B84FC @note "Recalculates the fee at acceptance time."
    procedure ShowMilitaryBaseNextRankDialog(Action: Integer); // @addr 0x5BC3D8 @note "Does not promote the player."
    procedure ShowScienceBaseSatelliteOfferDialog(Refresh: Integer); // @addr 0x5C13C8
    procedure BuyScienceBaseSatellite(Action: Integer); // @addr 0x5C1B60 @note "Transfers the existing SatelliteOffer into inventory."
    procedure ShowBusinessCenterPolicyDetails(Action: Integer); // @addr $5C6D1C
    procedure DeclineBusinessCenterPolicy(Action: Integer); // @addr $5C6E30
    procedure ShowBusinessCenterDebtDialog(Action: Integer); // @addr 0x5C46B8
    procedure AcceptBusinessCenterDebtQuote(Quote: Integer); // @addr 0x5C5464 @note "Quotes 1/2/3 use the large/medium/small principal, with 20/15/10 percent interest included in DebtAmount."
    procedure DeclineBusinessCenterDebtDialog(Action: Integer); // @addr 0x5C5830
    procedure RepayBusinessCenterDebt(Action: Integer); // @addr 0x5C593C @note "Requires the menu's prior affordability check."
    procedure ShowBusinessCenterDepositDialog(Action: Integer); // @addr 0x5C5A80
    procedure AcceptBusinessCenterDepositQuote(Quote: Integer); // @addr 0x5C615C @note "Quotes 1/2/3 select large/medium/small amounts; a new deposit resets accrued days."
    procedure DeclineBusinessCenterDepositDialog(Action: Integer); // @addr 0x5C6440
    procedure WithdrawBusinessCenterDeposit(Action: Integer); // @addr 0x5C654C
    procedure ShowBusinessCenterMedicalPolicyDialog(Refresh: Integer); // @addr 0x5C6774
    procedure BuyBusinessCenterMedicalPolicy(Action: Integer); // @addr 0x5C6AFC @note "Policy duration is 1825 ticks."
    procedure DeclineMedicalCenterTreatment(Action: Integer); // @addr $5CF0F4
    procedure LeaveMedicalCenterTreatment(Action: Integer); // @addr $5CF204
    procedure DeclineMedicalCenterStimulants(Action: Integer); // @addr $5D06B8
    procedure ShowMedicalCenterIllnessTreatmentDialog(Refresh: Integer); // @addr 0x5CDB38
    procedure TreatSelectedDiseaseAtMedicalCenter(DiseaseIndex: Integer); // @addr 0x5CEA24 @note "Treats disease indexes 1..12; valid insurance halves the fee outside pirate-owned systems."
    procedure TreatAllDiseasesAtMedicalCenter(QuotedCost: Integer); // @addr 0x5CEE5C @note "Trusts QuotedCost from the menu."
    procedure ShowMedicalCenterStimulantDialog(Action: Integer); // @addr 0x5CF3B0
    procedure BuySelectedStimulantAtMedicalCenter(StimulantIndex: Integer); // @addr 0x5D0280 @note "Stimulants use effect indices 13..24; valid insurance halves the fee outside pirate-owned systems."
    function BuildConstructionItemChoices(Kind: Byte): Integer; // @addr $5D230C
    procedure ConfirmDominionConstructionLimit(Action: Integer); // @addr $5D2B6C
    procedure SelectConstructionHeldItem(Action: Integer); // @addr $5D2D7C
    procedure SelectConstructionStoredItem(Action: Integer); // @addr $5D2DF0
    procedure SelectConstructionShopItem(Action: Integer); // @addr $5D2E64
    procedure SkipConstructionItem(Action: Integer); // @addr $5D2ED8
    procedure AppendConstructionItemList; // @addr $5D2EF4
    procedure ContinueDominionConstruction(PreviousItem: WideString); // @addr $5D3444
    procedure PickConstructionWeapon(Action: Integer); // @addr $5D3E28
    procedure PickConstructionRadar(Action: Integer); // @addr $5D3F24
    procedure PickConstructionScanner(Action: Integer); // @addr $5D4020
    procedure PickConstructionRepairRobot(Action: Integer); // @addr $5D411C
    procedure PickConstructionDefGenerator(Action: Integer); // @addr $5D4224
    procedure CompleteDominionConstruction(Action: Integer); // @addr $5D4428
    procedure ShowDominionShipConstructionDialog(Action: Integer); // @addr 0x5D28B0
    procedure ShowDominionPirateLicenseDialog(Action: Integer); // @addr 0x5D5C10
    procedure ShowDominionTravelDialog(Action: Integer); // @addr 0x5D6A30
    procedure ShowDominionCancelTravelDialog(Action: Integer); // @addr 0x5D7924
    procedure CancelDominionTravel(Action: Integer); // @addr 0x5D7B08
    procedure AddScriptTakeoffChoice(Caption: WideString); // @addr $5B3C80
    procedure ContinueScriptDialog; // @addr $5B3C54
    procedure AddScriptNewsExitChoice(Caption: WideString); // @addr $5B3D7C
    procedure AddScriptGameEndChoice(Caption: WideString); // @addr $5B3F14
    procedure AddScriptHangarChoice(Caption: WideString); // @addr $5B3E04
    procedure AddScriptRestartChoice(Caption: WideString); // @addr $5D1B70
    procedure AddScriptGoodsChoice(Caption: WideString); // @addr $5B3E8C
    procedure RunScriptAnswerKeepingScroll(Answer: Integer); // @addr $5B4048
    procedure RunScriptAnswer(Answer: Integer); // @addr $5B3FD4

    procedure RememberChoiceScroll; // @addr $5A8CAC
    procedure HideStationTransientControl; // @addr $5A70D8
    procedure ChoiceMouseEnter(Sender: TObjectGI); // @addr $5A94C4
    procedure ChoiceMouseLeave(Sender: TObjectGI); // @addr $5A94E4
    procedure ResetPortraitCycle; // @addr $5A9BCC
    procedure SelectScriptDialog(ScriptValue: Integer); // @addr $5B3F9C @note "Choice callback value carries a TScript pointer."
    procedure RunScriptNewsExit(Answer: Integer); // @addr $5B4128
    procedure RunScriptHangar(Answer: Integer); // @addr $5B4158
    procedure RunScriptGoods(Answer: Integer); // @addr $5B41A8
    procedure OpenHangar(Action: Integer); // @addr $5B4188
    procedure RunScriptGameEnd(Answer: Integer); // @addr $5B41D8
    procedure ReturnToMain(Action: Integer); // @addr $5B4218
    procedure RunScriptRestart(Answer: Integer); // @addr $5D1B38
    procedure RunScriptTakeoff(Answer: Integer); // @addr $5B406C
    procedure CloseHullMode(Action: Integer); // @addr $5AE508
    procedure CloseRuinsMode(Sender: TObjectGI); // @addr $5D1BF8
    procedure ToggleImpulseShields(Action: Integer); // @addr $5AE524
    function StopScriptVideo(Unused: Boolean): Boolean; // @addr $5AA4E0
    procedure ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer); override; // @addr $5AA5BC
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override; // @addr $5DC468
    procedure DeclineRangerCenterNodeDeposit(Action: Integer); // @addr $5B5ACC
    procedure DeclineRangerCenterNodeReward(Action: Integer); // @addr $5B69A8
    procedure ShowRangerCenterRatingAnswer(Action: Integer); // @addr $5B6D30
    procedure ShowRangerCenterPirateClanAnswer(Action: Integer); // @addr $5B6DD8
    procedure ShowRangerCenterBestRangerAnswer(Action: Integer); // @addr $5B6E88
    procedure DeclinePirateBaseNodes(Action: Integer); // @addr $5B929C
    procedure DeclineMilitaryBaseRepair(Action: Integer); // @addr $5BCF58
    procedure DeclineMilitaryBaseWarOperation(Action: Integer); // @addr $5BDF08
    procedure DeclineScienceBaseImprovement(Action: Integer); // @addr $5BF650
    procedure DeclineScienceBaseRepeatImprovement(Action: Integer); // @addr $5C082C
    procedure DeclineScienceBaseRepair(Action: Integer); // @addr $5C1320
    procedure ShowSatelliteInstructions(Action: Integer); // @addr $5C1AA4
    procedure DeclineScienceBaseSatellite(Action: Integer); // @addr $5C1D2C
    procedure DeclineDominionShipConstruction(Action: Integer); // @addr $5D2C2C
    procedure DeclineDominionImprovement(Action: Integer); // @addr $5D5160
    procedure DeclineDominionRepeatImprovement(Action: Integer); // @addr $5D5B48
    procedure DeclineDominionTravel(Action: Integer); // @addr $5D75C8
    procedure DeclineDominionTravelConfirmation(Action: Integer); // @addr $5D785C
    procedure DeclineDominionRelocation(Action: Integer); // @addr $5D88D4
    procedure ShowDominionCaptureAnswer(Action: Integer); // @addr $5D9A50
    procedure ShowDominionRanksAnswer(Action: Integer); // @addr $5D9B14
    procedure DeclineDominionWarOperation(Action: Integer); // @addr $5DAC00
    procedure DeclineDominionAmbush(Action: Integer); // @addr $5DB998
    procedure DeclineDominionAssault(Action: Integer); // @addr $5DC3A4
    procedure BuildDominionWarOptions; // @addr $5D899C
  end;

function GetDominionRelocationCost(Star: TStar): Integer; // @addr $5D7D1C

function ApplyRecentDominionOrderSurcharge(Cost: Single): Integer; // @addr $5D9C0C @ida "int __stdcall $name(float Cost);"

function GetConstructionShopCost: Integer; // @addr $5D1C14
function GetConstructionFreeSpace: Integer; // @addr $5D1CA0
procedure SelectConstructionItem(Item: TEquipment; Source: Byte); // @addr $5D2CE8

function GetStationBackgroundPath: WideString; // @addr $5A61A8

procedure ResetStationImprovement; // @addr $5A60A8

var
  BusinessQuoteSmallAmount: Integer; // @addr 0x88A878
  BusinessQuoteMediumAmount: Integer; // @addr 0x88A87C
  BusinessQuoteLargeAmount: Integer; // @addr 0x88A880
  BusinessQuoteLargeDueTurn: Integer; // @addr 0x88A884
  BusinessQuoteMediumDueTurn: Integer; // @addr 0x88A888
  BusinessQuoteSmallDueTurn: Integer; // @addr 0x88A88C
  BusinessDepositQuoteInterestRate: Single; // @addr 0x88A890
  NodeExchangeHighPriorityModule: Integer; // @addr $88A894
  NodeExchangeMediumPriorityModule: Integer; // @addr $88A898
  NodeExchangeLowPriorityModule: Integer; // @addr $88A89C
  NodeExchangeHighPriorityCost: Integer; // @addr $88A8A0
  NodeExchangeMediumPriorityCost: Integer; // @addr $88A8A4
  NodeExchangeLowPriorityCost: Integer; // @addr $88A8A8
  StationServiceQuoteCost: Integer; // @addr $88A8AC Shared by allegiance changes and station service quotes.
  MilitaryTravelDistance: Integer; // @addr $88A8B0 Rounded distance to the military base destination.
  InvestmentRangerCenterStar: TStar; // @addr $88A8B4
  InvestmentPirateBaseStar: TStar; // @addr $88A8B8
  InvestmentMilitaryBaseStar: TStar; // @addr $88A8BC
  InvestmentScienceBaseStar: TStar; // @addr $88A8C0
  InvestmentBusinessCenterStar: TStar; // @addr $88A8C4
  InvestmentMedicalBaseStar: TStar; // @addr $88A8C8
  InvestmentDefensePlanet: TPlanet; // @addr $88A8CC
  InvestmentQuoteCosts: array[0..11] of Integer; // @addr $88A8D0
  SelectedResearchSeries: Byte; // @addr $88A900
  NearbyTradeAdviceCost: Integer; // @addr $88A904
  DistantTradeAdviceCost: Integer; // @addr $88A908
  PirateProgramQuoteCosts: array[0..11] of Integer; // @addr $88A90C
  PirateChameleonQuoteCosts: array[0..2] of Integer; // @addr $88A93C
  // Shared quote amounts are replaced when opening either banking dialog.
  StationImprovementItem: TEquipment; // @addr $88A948
  StationImprovementKind: TImprovementKind; // @addr $88A94C
  StationImprovementDetail: Integer; // @addr $88A950
  StationBridgeMode: Byte; // @addr $88A954 0: station services; 1: hull bridge; higher values: custom bridge.
  ConstructionEquipment: array[42..49] of TConstructionEquipment; // @addr $88A958
  ConstructionWeapons: array[1..5] of TConstructionEquipment; // @addr $88A998
  DominionTravelQuotes: array[1..4] of TDominionTravelQuote; // @addr $88A9C0

implementation

uses aPirate, aWarrior, aGroup, aPlanet, fSelectFace, aGalaxyEvent, fShip2, fGalaxy2, aMyFunction, aRanger, EC_Expression, SysUtils, EC_Str, Globals, GlobalsV, GR_Main, fEquipmentShop, aGalaxy, aPlayer, aShip, Math, Windows, MMSystem, GI_XviD, GI_PanelScrollBar, ThreadCalc, aCalc, Messages, Classes, fTalk, GI_Main, GI_Panel, GI_Image, GI_ScrollBar, aSaveLoad, fSaveManager, fHangar, GI_GraphButton, GI_GAI, aConst, aGalaxyStruct, aRuins;

{ @routine $5A60A8 ResetStationImprovement }
procedure ResetStationImprovement;
begin
  StationImprovementItem := nil;
  StationImprovementKind := ikAny;
  StationImprovementDetail := 0;
end;
{ @end $5A60A8 }

{ @routine $5A60C0 TfRuinsTalk_Create }
constructor TfRuinsTalk.Create;
begin
  inherited Create;
  StationPanel := TfPanelRuins.Create;
  LoadPanel := TfPanelLoad.Create;
end;
{ @end $5A60C0 }

{ @routine $5A612C TfRuinsTalk_Destroy }
destructor TfRuinsTalk.Destroy;
begin
  if StationPanel <> nil then
  begin
    StationPanel.Free;
    StationPanel := nil;
  end;
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;
{ @end $5A612C }

{ @routine $5A61A8 GetStationBackgroundPath }
function GetStationBackgroundPath: WideString;
var
  Station: TShip;
begin
  if StationBridgeMode > 0 then
  begin
    Result := GetPlayer.RuinsStatusText;
    if Result = '' then Result := GameDataConfig.GetBlockByPath(WideString('CustomBridges.' + IntToStr(StationBridgeMode))).GetParam('BGI');
  end
  else
  begin
    if GetPlayer <> nil then Station := GetPlayer.DockedTo else Station := nil;
    if Station = nil then Result := 'Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[RuinsTalkScreen.StationType].Name + 'bg'
    else
    begin
      if Station.TypeNameOverrideKey <> '' then Result := 'Bm.FormRuins.' + GiResourceSuffix + Station.TypeNameOverrideKey + 'bg'
      else Result := 'Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[Station.TypeId].Name + OwnerInfo[Station.OwnerId].InternalName + 'bg';
      if not CacheDataRoot.FileExistsByPath(Result) then Result := 'Bm.FormRuins.' + GiResourceSuffix + ShipTypeNames[Station.TypeId].Name + 'bg';
    end;
  end;
end;
{ @end $5A61A8 }

// Native and rebuilt instructions agree; the matcher treats loop label $5DB078 as a separate relocation target.
{ @routine $5A63F4 TfRuinsTalk_InitializeLayout }
procedure TfRuinsTalk.InitializeLayout;
var
  ChoiceExtra, TextExtra: Integer;
  Panel, TalkPanel, Child, AddButton, CloseButton: TObjectGI;
  TextPanel: TPanelScrollBarGI;
  TextLabel: TObjectGI;
  ChoicePanel: TPanelScrollBarGI;
  Border, BottomBorder, Separator, Decoration: TObjectGI;
  Button, CloseFormButton: TGraphButtonGI;
begin
  inherited InitializeLayout;
  MainPanel.InitializeLayout(Self);
  StationPanel.InitializeLayout(Self);
  LoadPanel.InitializeLayout(Self);
  AppendLogTextThreadSafe('fRuinsTalk... ');
  ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
  Panel := GetByName('MainPanel');
  Panel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Panel.FindByNameRecursive('ImageBG2').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  Panel.FindByNameRecursive('ImageBG').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  LargePortraitLayout := False;
  PortraitTableVisible := False;
  if (Cardinal(GameScreenWidth) >= 1280) and (Cardinal(GameScreenHeight) >= 960) then
  begin
    LargePortraitLayout := True;
    PortraitTableVisible := UseTablesForGov;
  end;
  TalkPanel := Panel.FindByNameRecursive('PanelTalk');
  TextExtra := Min(Max(ExtraScreenHeight, 0), 250) div 3;
  ChoiceExtra := TextExtra div 4 * 3;
  TextExtra := TextExtra * 3 - ChoiceExtra;
  if ExtraScreenHeight < 0 then TalkPanel.SetPosition(Classes.Point(TalkPanel.LocalPosition.X + ExtraScreenWidth div 2, TalkPanel.LocalPosition.Y + ExtraScreenHeight div 2))
  else TalkPanel.SetPosition(Classes.Point(TalkPanel.LocalPosition.X + ExtraScreenWidth div 2, TalkPanel.LocalPosition.Y));
  TalkPanel.SetSize(Classes.Point(TalkPanel.ClientSize.X, TalkPanel.ClientSize.Y + TextExtra + ChoiceExtra));
  Child := TalkPanel.FirstChild;
  Child.SetPosition(Classes.Point(Child.LocalPosition.X, Child.LocalPosition.Y + TextExtra));
  Child.SetSize(Classes.Point(Child.ClientSize.X, Child.ClientSize.Y + ChoiceExtra));
  AddButton := TalkPanel.FindByNameRecursive('UserMsgAdd');
  AddButton.SetPosition(Classes.Point(AddButton.LocalPosition.X, AddButton.LocalPosition.Y + TextExtra));
  CloseButton := TalkPanel.FindByNameRecursive('ButFormClose');
  CloseButton.SetPosition(Classes.Point(CloseButton.LocalPosition.X, CloseButton.LocalPosition.Y + TextExtra + ChoiceExtra));
  TextPanel := TalkPanel.FindByNameRecursive('TextScroll') as TPanelScrollBarGI;
  TextPanel.SetSize(Classes.Point(TextPanel.ClientSize.X, TextPanel.ClientSize.Y + TextExtra));
  TextPanel.VerticalScrollBar.SetSize(Classes.Point(TextPanel.VerticalScrollBar.ClientSize.X, TextPanel.VerticalScrollBar.ClientSize.Y + TextExtra));
  TextLabel := TextPanel.FindByNameRecursive('TalkText');
  TextLabel.SetSize(Classes.Point(TextLabel.ClientSize.X, TextLabel.ClientSize.Y + TextExtra));
  ChoicePanel := TalkPanel.FindByNameRecursive('TalkPA') as TPanelScrollBarGI;
  ChoicePanel.SetPosition(Classes.Point(ChoicePanel.LocalPosition.X, ChoicePanel.LocalPosition.Y + TextExtra));
  ChoicePanel.SetSize(Classes.Point(ChoicePanel.ClientSize.X, ChoicePanel.ClientSize.Y + ChoiceExtra));
  TObjectGI(ChoicePanel.VerticalScrollBar).SetPosition(Classes.Point(ChoicePanel.VerticalScrollBar.LocalPosition.X, ChoicePanel.VerticalScrollBar.LocalPosition.Y + TextExtra));
  ChoicePanel.VerticalScrollBar.SetSize(Classes.Point(ChoicePanel.VerticalScrollBar.ClientSize.X, ChoicePanel.VerticalScrollBar.ClientSize.Y + ChoiceExtra));
  Border := ChoicePanel.NextSibling;
  Border.SetSize(Classes.Point(Border.ClientSize.X, Border.ClientSize.Y + TextExtra + ChoiceExtra));
  BottomBorder := Border.NextSibling;
  BottomBorder.SetPosition(Classes.Point(BottomBorder.LocalPosition.X, BottomBorder.LocalPosition.Y + TextExtra + ChoiceExtra));
  Separator := BottomBorder.NextSibling;
  Separator.SetPosition(Classes.Point(Separator.LocalPosition.X, Separator.LocalPosition.Y + TextExtra));
  Decoration := Separator.NextSibling;
  Decoration.SetPosition(Classes.Point(Decoration.LocalPosition.X, Decoration.LocalPosition.Y + TextExtra));
  Panel.FindByNameRecursive('Film').SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  AppendLogLineThreadSafe('ok');
  (GetByName('PM_EndTurn') as TGraphButtonGI).UpCallback := EndTurnClicked;
  (GetByName('PM_Ship') as TGraphButtonGI).UpCallback := ShipClicked;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  Button := GetByName('UserMsgAdd') as TGraphButtonGI;
  Button.UpCallback := AddMessageClicked;
  CloseFormButton := GetByName('ButFormClose') as TGraphButtonGI;
  CloseFormButton.UpCallback := CloseRuinsMode;
end;
{ @end $5A63F4 }

{ @routine $5A6B84 TfRuinsTalk_LayoutStationPortrait }
procedure TfRuinsTalk.LayoutStationPortrait(Panel: TObjectGI);
var
  I, HalfWidth, PortraitX, PortraitY, TableY, Bottom, DeltaX, DeltaY: Integer;
  Table, Table2, Animation, HdAnimation: TObjectGI;
begin
  if Panel = nil then Exit;
  Panel.ReloadFromBlock;
  Panel.SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
  HalfWidth := Cardinal(GameScreenWidth) div 2;
  PortraitY := Cardinal(GameScreenHeight) div 10;
  TableY := PortraitY + Panel.FindByNameRecursive('Panel_Anim0').ClientSize.Y div 10 * 6;
  if Panel.FindByNameRecursive('Table2') <> nil then
    Bottom := TableY + Round(Min(Panel.FindByNameRecursive('Table').ClientSize.Y * 0.95 + Panel.FindByNameRecursive('Table').LocalPosition.Y,
      Panel.FindByNameRecursive('Table2').ClientSize.Y * 0.9 + Panel.FindByNameRecursive('Table2').LocalPosition.Y))
  else Bottom := TableY + Round(Panel.FindByNameRecursive('Table').ClientSize.Y * 0.95 + Panel.FindByNameRecursive('Table').LocalPosition.Y);
  DeltaX := Panel.FindByNameRecursive('Panel_Anim0').LocalPosition.X - Panel.FindByNameRecursive('Panel_Anim1').LocalPosition.X;
  DeltaY := Panel.FindByNameRecursive('Panel_Anim0').ClientSize.Y - Panel.FindByNameRecursive('Panel_Anim1').ClientSize.Y;
  if GameScreenHeight > Bottom then
  begin
    PortraitY := PortraitY + GameScreenHeight - Bottom;
    TableY := TableY + GameScreenHeight - Bottom;
  end;
  Table := Panel.FindByNameRecursive('Table');
  Table.SetPosition(Classes.Point((HalfWidth - Table.ClientSize.X) div 2 + HalfWidth + Table.LocalPosition.X, Table.LocalPosition.Y + TableY));
  Table.SetActive(PortraitTableVisible);
  if Panel.FindByNameRecursive('Table2') <> nil then
  begin
    Table2 := Panel.FindByNameRecursive('Table2');
    Table2.SetPosition(Classes.Point((HalfWidth - Table2.ClientSize.X) div 2 + HalfWidth + Table2.LocalPosition.X, Table2.LocalPosition.Y + TableY));
    Table2.SetActive(False);
  end;
  PortraitX := HalfWidth div 2 * 3 - Panel.FindByNameRecursive('Panel_Anim0').ClientSize.X div 2;
  for I := 0 to 1 do
  begin
    Animation := Panel.FindByNameRecursive(AnsiString('Panel_Anim' + IntToStr(I)));
    if not PortraitTableVisible then Animation.SetPosition(Classes.Point(Animation.LocalPosition.X + ExtraScreenWidth, Animation.LocalPosition.Y + ExtraScreenHeight))
    else Animation.SetPosition(Classes.Point(PortraitX - I * DeltaX, PortraitY + I * DeltaY));
    HdAnimation := Panel.FindByNameRecursive(AnsiString('PanelHD_Anim' + IntToStr(I)));
    HdAnimation.SetPosition(Classes.Point((HalfWidth - HdAnimation.ClientSize.X) div 2 + HdAnimation.LocalPosition.X + HalfWidth, HdAnimation.LocalPosition.Y + ExtraScreenHeight));
  end;
  StationTransientControl := Panel;
  StationTransientControl.SetActive(True);
end;
{ @end $5A6B84 }

{ @routine $5A70D8 TfRuinsTalk_HideStationTransientControl }
procedure TfRuinsTalk.HideStationTransientControl;
begin
  if StationTransientControl <> nil then StationTransientControl.SetActive(False);
end;
{ @end $5A70D8 }

{ @routine $5A7100 TfRuinsTalk_OnOpen }
procedure TfRuinsTalk.OnOpen;
var
  Owner, Kind: Byte;
  Index: Integer;
  Block: TBlockParEC;
  Control: TObjectGI;
  Stage: Integer;
  Background: TImageGI;
  Choices: TPanelScrollBarGI;
  HdNormal, HdAlternate, Normal, Alternate: TgaiGI;
  CloseButton: TGraphButtonGI;
  TextLabel: TLabelGI;
begin
  Stage := 0;
  try
    if not MusicInPlanetEnabled then MusicManager.RequestFadeOut;
    Stage := 1;
    LoadPanel.OnOpen;
    Stage := 2;
    if ShowArrivalVideo and not SkipVideo then
    begin
      LoadPanel.SetShutterOpenFraction(1);
      LoadPanel.Hide;
    end;
    SavedChoiceScroll := -1;
    Stage := 3;
    StationOwner := GetPlayer.DockedTo.OwnerId;
    StationType := GetPlayer.DockedTo.TypeId;
    StationBridgeMode := GetPlayer.RuinsMode;
    if StationBridgeMode > 0 then GetPlayer.CurrentPlanet := nil;
    Stage := 4;
    MainPanel.OnOpen;
    Stage := 5;
    StationPanel.OnOpen;
    Stage := 6;
    if GetPlayer.DockedTo <> TemporaryShopStation then
    begin
      SelectMusic;
      if TemporaryShopSlots <> nil then RestoreTemporaryShopStock;
      RunGlobalScriptsForContext(GetPlayer.CurrentStar, 0);
      PruneExpiredPersistentPlayerMessages;
      BuildTemporaryShopSlotGrid;
    end;
    if GetPlayer.PendingDockDialogue = 1 then GetPlayer.PendingDockDialogue := 0;
    Stage := 7;
    Galaxy.ReleaseItemGraphics;
    Stage := 8;
    Background := GetByName('ImageBG2') as TImageGI;
    Background.SetActive(StationType = Byte(rstMilitaryBase));
    if Background.Active then
    begin
      Background.SetImagePath('GAI,' + GetPlayer.CurrentStar.GetBackgroundImagePath(Index));
      Background.GaiImageControl.LoadFrameSequenceFromText('[50,0-0]');
      Background.SetImageKindX(ikxCenter);
      Background.SetImageKindY(ikyCenter);
    end;
    Stage := 9;
    (GetByName('ImageBG') as TImageGI).SetImagePath('GI,' + GetStationBackgroundPath);
    Stage := 10;
    I_Start;
    Stage := 11;
    RestartTextPresentation;
    Stage := 12;
    Choices := GetByName('TalkPA') as TPanelScrollBarGI;
    Choices.SetVerticalScrollbarEnabled(False);
    Stage := 13;
    for Owner := 0 to 4 do
    begin
      Control := FindControlByPath('Panel' + OwnerInfo[Owner].InternalName);
      if Control <> nil then Control.SetActive(False);
      for Kind := 6 to 12 do
      begin
        Control := FindControlByPath('Panel' + OwnerInfo[Owner].InternalName + ShipTypeNames[Kind].Name);
        if Control <> nil then Control.SetActive(False);
      end;
    end;
    Stage := 14;
    for Index := 1 to 255 do
      if StationBridgeMode <> Index then
      begin
        Block := GameDataConfig.GetBlockByPath('CustomBridges');
        if Block.CountBlocks(IntToStr(Index)) <> 0 then
        begin
          Block := Block.GetBlockByPath(IntToStr(Index));
          Control := FindControlByPath(Block.GetParam('PanelName'));
          if Control <> nil then Control.SetActive(False);
        end;
      end;
    Stage := 15;
    if StationBridgeMode <> 0 then
      Control := GetByName(GameDataConfig.GetBlockByPath(AnsiString('CustomBridges.' + IntToStr(StationBridgeMode))).GetParam('PanelName'))
    else
    begin
      Control := nil;
      if GetPlayer.DockedTo.TypeNameOverrideKey <> '' then
      begin
        Control := FindControlByPath('Panel' + OwnerInfo[StationOwner].InternalName + GetPlayer.DockedTo.TypeNameOverrideKey);
        if Control = nil then Control := FindControlByPath('Panel' + GetPlayer.DockedTo.TypeNameOverrideKey);
      end;
      if Control = nil then Control := FindControlByPath('Panel' + OwnerInfo[StationOwner].InternalName + ShipTypeNames[StationType].Name);
      if Control = nil then Control := FindControlByPath('Panel' + OwnerInfo[StationOwner].InternalName);
      if Control = nil then Control := FindControlByPath('PanelPeoplePB');
    end;
    Stage := 16;
    LayoutStationPortrait(Control);
    Stage := 17;
    if StationTransientControl.FindByNameRecursive('Table2') <> nil then
      StationTransientControl.FindByNameRecursive('Table2').SetActive(False);
    Stage := 18;
    StationTransientControl.FindByNameRecursive('Table').SetActive(LargePortraitLayout and PortraitTableVisible);
    Stage := 19;
    if LargePortraitLayout and not PortraitTableVisible then
    begin
      Stage := 20;
      HdNormal := StationTransientControl.FindByNameRecursive('PanelHD_Anim0') as TgaiGI;
      HdNormal.FirstFrameOnly := AnimGov = 0;
      HdNormal.PrimeImageCaches;
      if AnimGov = 2 then
      begin
        HdAlternate := StationTransientControl.FindByNameRecursive('PanelHD_Anim1') as TgaiGI;
        HdAlternate.FirstFrameOnly := AnimGov = 0;
        HdAlternate.PrimeImageCaches;
      end;
    end
    else
    begin
      Stage := 21;
      Normal := StationTransientControl.FindByNameRecursive('Panel_Anim0') as TgaiGI;
      Normal.FirstFrameOnly := AnimGov = 0;
      Normal.PrimeImageCaches;
      if AnimGov = 2 then
      begin
        Alternate := StationTransientControl.FindByNameRecursive('Panel_Anim1') as TgaiGI;
        Alternate.FirstFrameOnly := AnimGov = 0;
        Alternate.PrimeImageCaches;
      end;
    end;
    Stage := 22;
    CloseButton := GetByName('ButFormClose') as TGraphButtonGI;
    CloseButton.SetDisabled((StationBridgeMode = 0) or ((GetPlayer.GetHull.CapitalShip <> StationBridgeMode) and (GetPlayer.PendingDockDialogue = 2)));
    Stage := 23;
    TextLabel := GetByName('TalkText') as TLabelGI;
    if FontDialog = 0 then TextLabel.SetFontName(NormalFontName)
    else if FontDialog = 1 then TextLabel.SetFontName(SmoothBigFontName)
    else if FontDialog = 2 then TextLabel.SetFontName(SmoothHugeFontName)
    else if FontDialog >= 3 then TextLabel.SetFontName(SmoothIntroFontName);
    Stage := 24;
    if DispatchPendingScriptRequests then
    begin
      Galaxy.PrimeIntegrityChecksum(180);
      Exit;
    end;
    Stage := 25;
    MainPanel.RebuildMessageButtons(False);
    if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnEnteringForm, nil, nil, 0);
    Stage := 26;
    SelectPortraitAnimation(True);
    NextPortraitCycleAlternate := False;
    Galaxy.PrimeIntegrityChecksum(180);
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfRuinsTalk.BeforeRun, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5A7100 }

{ @routine $5A7D4C TfRuinsTalk_OnClose }
procedure TfRuinsTalk.OnClose;
begin
  Galaxy.CheckIntegrityChecksum(181);
  if GetPlayer <> nil then GetPlayer.ScriptItemsAct(satOnLeavingForm, nil, nil, 0);
  StopScriptVideo(False);
  LoadPanel.OnClose;
  HideStationTransientControl;
  StationBridgeMode := 0;
  ScriptDialogIndex := -1;
  ClearChoices;
  MainPanel.OnClose;
  StationPanel.OnClose;
  SetLength(ResearchItemVisited, 0);
  SetLength(ResearchItemIndexes, 0);
end;
{ @end $5A7D4C }

{ @routine $5A7FA0 TfRuinsTalk_SortResearchItems }
function TfRuinsTalk.SortResearchItems(Series: Byte): Integer;
var
  I, Count, BestIndex, SortedCount: Integer;
  Item: TEquipment;
  BestKey, Key: TResearchItemSortKey;

  // @nested $5A7E14 ClearResearchItemSortKey
  procedure ClearResearchItemSortKey(var Key: TResearchItemSortKey); // @addr $5A7E14 @calls "0x5A8049"
  begin
    Key.Cost := 0;
    Key.Priority := 0;
    Key.Weight := 0;
  end;

  // @nested $5A7E34 MakeResearchItemSortKey
  function MakeResearchItemSortKey(Item: TEquipment): TResearchItemSortKey; // @addr $5A7E34 @calls "0x5A8095"
  begin
    Result.Cost := Item.Cost;
    Result.Weight := Item.Weight;
    Result.Priority := 0;
    if (Item.OwnerId = Byte(oiDominator)) and (Item.EquippedFlag = 0) and (Item.NoDropFlag = 0) and (Item.CustomFaction = '') and not (Item is THull) then
    begin
      if Item is TUselessItem then
      begin
        if TDominatorSeries(Series) = Item.DominatorSeries then Result.Priority := 5 else Result.Priority := 4;
      end
      else if Item is TCountableItem then Result.Priority := 2
      else if Item is TMicroModule then Result.Priority := 1
      else Result.Priority := 3;
    end;
  end;

  // @nested $5A7F14 CompareResearchItemSortKeys
  function CompareResearchItemSortKeys(Left, Right: TResearchItemSortKey): Integer; // @addr $5A7F14 @calls "0x5A80CC"
  begin
    Result := 0;
    if Right.Priority > Left.Priority then Result := 1
    else if Right.Priority < Left.Priority then Result := -1
    else if Right.Cost > Left.Cost then Result := 1
    else if Right.Cost < Left.Cost then Result := -1
    else if Right.Weight > Left.Weight then Result := 1
    else if Right.Weight < Left.Weight then Result := -1;
  end;


begin
  Count := GetPlayer.Inventory.Count;
  SetLength(ResearchItemVisited, Count);
  SetLength(ResearchItemIndexes, Count);
  for I := 0 to Count - 1 do
  begin
    ResearchItemVisited[I] := False;
    ResearchItemIndexes[I] := -1;
  end;
  SortedCount := 0;
  repeat
    BestIndex := -1;
    ClearResearchItemSortKey(BestKey);
    for I := 0 to Count - 1 do
      if not ResearchItemVisited[I] then
      begin
        Item := GetPlayer.Inventory[I];
        Key := MakeResearchItemSortKey(Item);
        if Key.Priority = 0 then ResearchItemVisited[I] := True
        else
        begin
          if CompareResearchItemSortKeys(BestKey, Key) >= 0 then
          begin
            BestKey := Key;
            BestIndex := I;
          end;
        end;
      end;
    if BestIndex >= 0 then
    begin
      ResearchItemIndexes[SortedCount] := BestIndex;
      ResearchItemVisited[BestIndex] := True;
      Inc(SortedCount);
    end;
  until BestIndex < 0;
  Result := Count;
end;
{ @end $5A7FA0 }

{ @routine $5A813C TfRuinsTalk_IsResearchItemQuestLetter }
function TfRuinsTalk.IsResearchItemQuestLetter(Item: TItem): Boolean;
var
  I: Integer;
  Quest: PQuest;
begin
  Result := False;
  if (Item is TUselessItem) and (Item.ScriptItem = nil) then
    for I := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[I];
      if Quest.QuestType = qtSendLetter then
        if LocalizedColorText(WideString('Quest.SendLetter.' + IntToStr(Quest.QuestNumber) + '.SysName')) = (Item as TUselessItem).ConfigBlockName then Result := True;
    end;
end;
{ @end $5A813C }

{ @routine $5A82A0 TfRuinsTalk_CountResearchRemains }
function TfRuinsTalk.CountResearchRemains(Series: Byte; Count: Integer): Integer;
var
  Matches, I, Index: Integer;
  Item: TEquipment;
begin
  Matches := 0;
  for I := 0 to Count - 1 do
  begin
    Index := ResearchItemIndexes[I];
    if Index < 0 then Break;
    Item := GetPlayer.Inventory[Index];
    if (Item.DominatorSeries = TDominatorSeries(Series)) and (Item is TUselessItem) then
      if (Item as TUselessItem).IsDominatorRemains and not IsResearchItemQuestLetter(Item) then Inc(Matches);
  end;
  Result := Matches;
end;
{ @end $5A82A0 }

{ @routine $5A8354 TfRuinsTalk_CountResearchEquipment }
function TfRuinsTalk.CountResearchEquipment(Count: Integer): Integer;
var
  Matches, I, Index: Integer;
  Item: TEquipment;
begin
  Matches := 0;
  for I := 0 to Count - 1 do
  begin
    Index := ResearchItemIndexes[I];
    if Index < 0 then Break;
    Item := GetPlayer.Inventory[Index];
    if not (Item is TUselessItem) and (Item.EquippedFlag = 0) and (Item.ItemType <> t_Protoplasm) and (Item.ItemType <> t_MicroModule) then Inc(Matches);
  end;
  Result := Matches;
end;
{ @end $5A8354 }

{ @routine $5A83EC TfRuinsTalk_BuildResearchItemChoices }
procedure TfRuinsTalk.BuildResearchItemChoices(Series: Byte; var Text: WideString);
var
  I, Count, Index, Number: Integer;
  Item: TEquipment;
  Items, Description, Bonus: WideString;
begin
  Bonus := ' ' + WrapTextInColor(LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), '<color=255,240,100>');
  Number := 0;
  Count := SortResearchItems(Series);
  if CountResearchRemains(Series, Count) > 0 then
    case Series of
      0: AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllUselessBlazer'), Count, SellResearchRemains);
      1: AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllUselessKeller'), Count, SellResearchRemains);
      2: AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllUselessTerron'), Count, SellResearchRemains);
    end;
  if CountResearchEquipment(Count) > 1 then
    AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleAllEq'), Count, SellResearchEquipment);
  for I := 0 to Count - 1 do
  begin
    Index := ResearchItemIndexes[I];
    if Index < 0 then Break;
    Item := GetPlayer.Inventory[Index];
    Inc(Number);
    Description := NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)) + ' (' + WrapTextInColor(IntToStr(Item.Cost), '<color=255,240,100>') + ' cr)';
    if (Item.DominatorSeries = TDominatorSeries(Series)) and (Item is TUselessItem) then Description := Description + Bonus;
    Items := Items + #13#10 + IntToStr(Number) + ') ' + Description;
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Scn.PlayerSale'), '', '<ItemName>', Description), Index, SellResearchItem);
  end;
  Text := Items;
end;
{ @end $5A83EC }

{ @routine $5A899C TfRuinsTalk_EndTurnClicked }
procedure TfRuinsTalk.EndTurnClicked(Sender: TObjectGI);
begin
  if (GetPlayer = nil) or (GetPlayer.PendingDockDialogue > 1) or (StationBridgeMode > 0) or (GetPlayer.QueuedTravelTarget <> nil) then Exit;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstDominion)) and (GetPlayer.DockedTo.Order = soTeleport) and
    (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) and not GetPlayer.DockedTo.InHyperspace then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstDominion)) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    RuinsTalkScreen.DepartWithStation(1);
    Exit;
  end;
  if GetPlayer.IsDockedToShip and (GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase)) and ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
    ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and ((GetPlayer.DockedTo as TRuins).FlyDate <= Galaxy.CurrentTurn) then
  begin
    if GetPlayer.Speed <= 0 then RuinsTalkScreen.DepartWithStation(1)
    else StationPanel.TakeOffForStationTravel;
    Exit;
  end;
  if LoadPanel.IsAnimatingShutters then Exit;
  Galaxy.CheckIntegrityChecksum(182);
  RestoreTemporaryShopStock;
  MainPanel.EndTurnClicked(Sender);
  if ExitCode = 0 then
  begin
    BuildTemporaryShopSlotGrid;
    I_Start;
    Galaxy.PrimeIntegrityChecksum(183);
    RestartTextPresentation;
    MainPanel.RebuildMessageButtons(False);
  end;
end;
{ @end $5A899C }

{ @routine $5A8C24 TfRuinsTalk_ShipClicked }
procedure TfRuinsTalk.ShipClicked(Sender: TObjectGI);
begin
  if LoadPanel.IsAnimatingShutters then Exit;
  MainPanel.ShipClicked(Sender);
  if ShipScreen.ShipStateChanged then
  begin
    Galaxy.CheckIntegrityChecksum(300);
    I_Start;
    Galaxy.PrimeIntegrityChecksum(301);
    RestartTextPresentation;
    MainPanel.RebuildMessageButtons(False);
  end;
end;
{ @end $5A8C24 }

{ @routine $5A8CAC TfRuinsTalk_RememberChoiceScroll }
procedure TfRuinsTalk.RememberChoiceScroll;
begin
  SavedChoiceScroll := (GetByName('TalkPA') as TPanelScrollBarGI).VerticalScrollBar.Position;
end;
{ @end $5A8CAC }

{ @routine $5A8CF8 TfRuinsTalk_ClearChoices }
procedure TfRuinsTalk.ClearChoices;
var
  Child: TObjectGI;
  Stage: Integer;
  Panel: TObjectGI;
begin
  Stage := 0;
  try
    ChoiceHeight := 0;
    Panel := GetByName('TalkPA');
    Stage := 1;
    Child := Panel.FirstChild;
    while Child <> nil do
    begin
      Stage := 2;
      TObject(Child.UserValue).Free;
      Stage := 3;
      Child := Child.NextSibling;
      Stage := 4;
    end;
    Stage := 5;
    Panel.FreeOwnedChildren;
    Stage := 6;
    Panel.Invalidate;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfRuinsTalk.A_Start, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5A8CF8 }

{ @routine $5A8EF8 TfRuinsTalk_AddChoice }
procedure TfRuinsTalk.AddChoice(Text: WideString; Value: Integer; Callback: TDialogChoiceEventGI);
var Panel: TPanelScrollBarGI; Choice: TfTalkA; I: Integer; Row: TPanelGI;
  Highlight: TImageGI; BlockMode: Byte;
begin
  BlockMode := 0;
  if ScriptDialogBlocks <> nil then
    for I := 0 to ScriptDialogBlocks.Count - 1 do
      if FindTextOffsetW(Text, PScriptDialogBlock(ScriptDialogBlocks[I]).Text) >= 0 then
        BlockMode := Max(BlockMode, PScriptDialogBlock(ScriptDialogBlocks[I]).Mode);
  if BlockMode >= 2 then Exit;
  Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  I := 0;
  while I < Length(Text) do
  begin
    if (Text[I + 1] <> '-') and (Text[I + 1] <> ' ') then Break;
    Inc(I);
  end;
  if I > 0 then Text := Copy(Text, I + 1, Length(Text) - I);
  Choice := TfTalkA.Create;
  Choice.Callback := Callback;
  Choice.Value := Value;
  if BlockMode > 0 then Choice.Callback := nil;
  Row := TPanelGI.Create(Panel);
  Row.UserValue := Integer(Choice);
  Row.SetPosition(Point(0, ChoiceHeight));
  Row.SetSize(Point(Panel.ClientSize.X, 20));
  Row.SetPositionModeW(True);
  Row.MouseEnterCallback := ChoiceMouseEnter;
  Row.MouseLeaveCallback := ChoiceMouseLeave;
  Row.LeftButtonDownCallback := ChoiceMouseDown;
  Row.LeftButtonUpCallback := ChoiceMouseUp;
  Highlight := TImageGI.Create(Row);
  Highlight.SetDepth(3);
  Highlight.SetPosition(Point(0, 0));
  Highlight.SetSize(Point(Panel.ClientSize.X, 20));
  Highlight.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Line');
  Highlight.SetImageKindX(ikxLeftFill);
  Highlight.SetImageKindY(ikyTopFill);
  Highlight.SetActive(False);
  with TLabelGI.Create(Row) do
  begin
  if FontDialog = 0 then SetFontName(NormalFontName)
  else if FontDialog = 1 then SetFontName(SmoothBigFontName)
  else if FontDialog = 2 then SetFontName(SmoothHugeFontName)
  else if FontDialog >= 3 then SetFontName(SmoothIntroFontName);
  SetSize(Point(Panel.ClientSize.X - GiScalePixels(20), 1));
  SetPosition(Point(GiScalePixels(10), 0));
  SetWordWrapEnabled(True);
  SetTextAlignX(taxLeft);
  SetTextAlignY(tayAuto);
  if not Assigned(Callback) then Text := RemoveTextTagsW(Text);
  SetText('<Object=0,20,14,0>' + ReplaceAllWideString(Text, '<color=255,240,100>', '<color=0,50,200>'));
  SetTextColor(CurrentPixelFormat.PackRgbBytes(0, 0, 0));
  if not Assigned(Choice.Callback) then SetTextColor(CurrentPixelFormat.PackRgbBytes(127, 127, 127));
  CreateEmbeddedControl := CreateChoiceBullet;
  SetTextAlignY(tayCenterEx);
  Row.SetSize(Point(Row.ClientSize.X, ClientSize.Y + 2 * GiScalePixelsEx(2, 2)));
  SetSize(Point(ClientSize.X, Row.ClientSize.Y));
  Highlight.SetSize(Row.ClientSize);
  Inc(ChoiceHeight, ClientSize.Y);
  end;
end;
{ @end $5A8EF8 }

{ @routine $5A94C4 TfRuinsTalk_ChoiceMouseEnter }
procedure TfRuinsTalk.ChoiceMouseEnter(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(True);
end;
{ @end $5A94C4 }

{ @routine $5A94E4 TfRuinsTalk_ChoiceMouseLeave }
procedure TfRuinsTalk.ChoiceMouseLeave(Sender: TObjectGI);
begin
  Sender.FirstChild.SetActive(False);
end;
{ @end $5A94E4 }

{ @routine $5A9504 TfRuinsTalk_ChoiceMouseDown }
procedure TfRuinsTalk.ChoiceMouseDown(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
     (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(2, 0));
end;
{ @end $5A9504 }

{ @routine $5A9584 TfRuinsTalk_ChoiceMouseUp }
procedure TfRuinsTalk.ChoiceMouseUp(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
var Choice: TfTalkA;
begin
  if (Sender.FirstChild <> nil) and (Sender.FirstChild.NextSibling <> nil) and
     (Sender.FirstChild.NextSibling.FirstChild <> nil) and (Sender.FirstChild.NextSibling.FirstChild.FirstChild <> nil) then
    Sender.FirstChild.NextSibling.FirstChild.FirstChild.SetPosition(Classes.Point(0, 0));
  if LoadPanel.IsAnimatingShutters then Exit;
  Galaxy.CheckIntegrityChecksum(184);
  Choice := TfTalkA(Sender.UserValue);
  if Assigned(Choice.Callback) then Choice.Callback(Choice.Value)
  else if Assigned(Choice.FallbackCallback) then Choice.FallbackCallback(Choice.FallbackText)
  else
  begin
    Galaxy.PrimeIntegrityChecksum(186);
    Exit;
  end;
  Galaxy.PrimeIntegrityChecksum(185);
  RestartTextPresentation;
  MainPanel.RefreshMoneyAndCargo;
  MainPanel.RebuildMessageButtons(False);
  BreakUiMessage;
end;
{ @end $5A9584 }

{ @routine $5A96B8 TfRuinsTalk_RestartTextPresentation }
procedure TfRuinsTalk.RestartTextPresentation;
begin
  ResetPortraitCycle;
  (GetByName('TalkPA') as TPanelScrollBarGI).SetActive(False);
  PresentedTextLength := 0;
  if TextPresentationTimer <> nil then
  begin
    CancelCallbackTimer(TextPresentationTimer);
    TextPresentationTimer := nil;
  end;
  TextPresentationTimer := ScheduleCallbackTimer(10, 10, AdvanceTextPresentation);
end;
{ @end $5A96B8 }

{ @routine $5A9758 TfRuinsTalk_AdvanceTextPresentation }
procedure TfRuinsTalk.AdvanceTextPresentation(Timer: PCallbackTimerGI; UserData: Integer);
var Choices, TextPanel: TPanelScrollBarGI;
begin
  if PresentedTextLength >= Length(DialogText) then
  begin
    Choices := GetByName('TalkPA') as TPanelScrollBarGI;
    Choices.SetActive(True);
    Choices.VerticalScrollBar.SetSmallChange((GetByName('TalkText') as TLabelGI).GetLineHeight);
    Choices.VerticalScrollBar.SetLargeChange(Choices.ClientSize.Y);
    Choices.VerticalScrollBar.SetPageSize(Choices.ClientSize.Y);
    Choices.SetScrollOffset(Point(0, 0));
    Choices.VerticalScrollBar.SetActive(ChoiceHeight > Choices.ClientSize.Y);
    Choices.VerticalScrollBar.SetDepth(4);
    Choices.SetDragScrollingEnabled(Choices.VerticalScrollBar.Active);
    Choices.UpdateScrollRanges;
    if TextPresentationTimer <> nil then
    begin
      CancelCallbackTimer(TextPresentationTimer);
      TextPresentationTimer := nil;
    end;
    if SavedChoiceScroll >= 0 then Choices.VerticalScrollBar.SetPosition(SavedChoiceScroll);
    SavedChoiceScroll := -1;
    PostMouseMoveMessage;
  end
  else
  begin
    DialogText := LocalizedTextLinePrefix + TrimWideString(DialogText);
    DialogText := ReplaceAllWideString(DialogText, #13#10 + LocalizedTextLinePrefix, #13#10);
    DialogText := ReplaceAllWideString(DialogText, #13#10, #13#10 + LocalizedTextLinePrefix);
    PresentedTextLength := Length(DialogText);
    DialogText := ReplaceAllWideString(DialogText, '<color=255,240,100>', '<color=0,50,200>');
    (GetByName('TalkText') as TLabelGI).SetText(DialogText);
    TextPanel := GetByName('TextScroll') as TPanelScrollBarGI;
    TextPanel.SetScrollOffset(Point(0, 0));
    TextPanel.UpdateScrollRanges;
    TextPanel.VerticalScrollBar.SetActive((TextPanel.FindByNameRecursive('TalkText') as TLabelGI).ClientSize.Y > TextPanel.ClientSize.Y);
    TextPanel.VerticalScrollBar.SetSmallChange((TextPanel.FindByNameRecursive('TalkText') as TLabelGI).GetLineHeight);
    TextPanel.VerticalScrollBar.SetLargeChange(TextPanel.ClientSize.Y);
    TextPanel.VerticalScrollBar.SetPageSize(TextPanel.ClientSize.Y);
    (GetByName('UserMsgAdd') as TGraphButtonGI).SetDisabled(False);
  end;
end;
{ @end $5A9758 }

{ @routine $5A9BCC TfRuinsTalk_ResetPortraitCycle }
procedure TfRuinsTalk.ResetPortraitCycle;
begin
  NextPortraitCycleAlternate := True;
end;
{ @end $5A9BCC }

{ @routine $5A9BE0 TfRuinsTalk_PortraitCycleComplete }
procedure TfRuinsTalk.PortraitCycleComplete(Sender: TObjectGI);
begin
  if NextPortraitCycleAlternate then
  begin
    SelectPortraitAnimation(True);
    NextPortraitCycleAlternate := False;
  end
  else SelectPortraitAnimation(False);
end;
{ @end $5A9BE0 }

{ @routine $5A9C1C TfRuinsTalk_SelectPortraitAnimation }
procedure TfRuinsTalk.SelectPortraitAnimation(Alternate: Boolean);
var HdNormal, HdAlternate, Normal, AlternateAnimation: TgaiGI;
begin
  if AnimGov <> 2 then Alternate := False;
  if LargePortraitLayout and not PortraitTableVisible then
  begin
    HdNormal := StationTransientControl.FindByNameRecursive('PanelHD_Anim0') as TgaiGI;
    HdNormal.CycleCompleteCallback := PortraitCycleComplete;
    HdNormal.SetSequenceFrame(0);
    HdNormal.StopAutoPlayback;
    if not Alternate then HdNormal.RestartPlayback else HdNormal.StopAutoPlayback;
    HdNormal.SetActive(not Alternate);
    HdAlternate := StationTransientControl.FindByNameRecursive('PanelHD_Anim1') as TgaiGI;
    HdAlternate.CycleCompleteCallback := PortraitCycleComplete;
    HdAlternate.SetSequenceFrame(0);
    HdAlternate.StopAutoPlayback;
    if Alternate then HdAlternate.RestartPlayback else HdAlternate.StopAutoPlayback;
    HdAlternate.SetActive(Alternate);
  end
  else
  begin
    Normal := StationTransientControl.FindByNameRecursive('Panel_Anim0') as TgaiGI;
    Normal.CycleCompleteCallback := PortraitCycleComplete;
    Normal.SetSequenceFrame(0);
    Normal.StopAutoPlayback;
    if not Alternate then Normal.RestartPlayback else Normal.StopAutoPlayback;
    Normal.SetActive(not Alternate);
    AlternateAnimation := StationTransientControl.FindByNameRecursive('Panel_Anim1') as TgaiGI;
    AlternateAnimation.CycleCompleteCallback := PortraitCycleComplete;
    AlternateAnimation.SetSequenceFrame(0);
    AlternateAnimation.StopAutoPlayback;
    if Alternate then AlternateAnimation.RestartPlayback else AlternateAnimation.StopAutoPlayback;
    AlternateAnimation.SetActive(Alternate);
  end;
end;
{ @end $5A9C1C }

{ @routine $5A9E90 TfRuinsTalk_CreateChoiceBullet }
function TfRuinsTalk.CreateChoiceBullet(LabelControl: TLabelGI; Item: PFontObjectEC): TObjectGI;
var Image: TImageGI;
begin
  Result := TImageGI.Create(LabelControl);
  Image := Result as TImageGI;
  Image.SetImagePath('GI,Bm.FormGov2.' + GiResourceSuffix + 'Answer');
  Image.SetImageKindX(ikxLeft);
end;
{ @end $5A9E90 }

{ @routine $5A9F74 TfRuinsTalk_ProcessMouseWheel }
procedure TfRuinsTalk.ProcessMouseWheel(KeyState: Cardinal; Point: TPoint; Delta: Integer);
var
  Panel: TPanelScrollBarGI;
begin
  Panel := GetByName('TalkPA') as TPanelScrollBarGI;
  if not Panel.ContainsPoint(Point) then Panel := GetByName('TextScroll') as TPanelScrollBarGI;
  if Delta = WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
  else if Delta = -WHEEL_DELTA then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange);
end;
{ @end $5A9F74 }

{ @routine $5AA06C TfRuinsTalk_MainPanelKeyDown }
procedure TfRuinsTalk.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
var
  Panel: TPanelScrollBarGI;
  Button: TGraphButtonGI;
begin
  if (ExitCode <> 0) or IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) or LoadPanel.IsAnimatingShutters then Exit;
  Panel := GetByName('TextScroll') as TPanelScrollBarGI;
  if Key = VK_SPACE then
  begin
    if GetByName('PM_EndTurn').Active then EndTurnClicked(nil);
  end
  else if Key = Ord('S') then ShipClicked(nil)
  else if Key = VK_UP then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.SmallChange)
  else if Key = VK_DOWN then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.SmallChange)
  else if Key = VK_PRIOR then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position - Panel.VerticalScrollBar.LargeChange)
  else if Key = VK_NEXT then Panel.VerticalScrollBar.SetPosition(Panel.VerticalScrollBar.Position + Panel.VerticalScrollBar.LargeChange)
  else if Key = VK_INSERT then
  begin
    Button := GetByName('UserMsgAdd') as TGraphButtonGI;
    AddMessageClicked(Button);
  end
  else
  begin
    MainPanel.ProcessKeyDown(Key);
    StationPanel.ProcessKeyDown(Key);
  end;
end;
{ @end $5AA06C }

{ @routine $5AA2B4 TfRuinsTalk_AddMessageClicked }
procedure TfRuinsTalk.AddMessageClicked(Sender: TObjectGI);
var
  Text: WideString;
begin
  Text := (GetByName('TalkText') as TLabelGI).GetText;
  Text := ReplaceAllWideString(Text, '<color=0,50,200>', '<color=255,240,100>');
  (Sender as TGraphButtonGI).SetDisabled(True);
  SoundManager.PlaySound('Sound.UserMsgAdd');
  AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, Text, '');
  MainPanel.RebuildMessageButtons(False);
  BreakUiMessage;
end;
{ @end $5AA2B4 }

{ @routine $5AA424 TfRuinsTalk_AdvanceScriptVideo }
procedure TfRuinsTalk.AdvanceScriptVideo(Timer: PCallbackTimerGI; UserData: Integer);
var Progress: Double; Film: TxvidGI;
begin
  Progress := (timeGetTime - ScriptVideoStartedAt) / 138000;
  if Progress > 1 then Progress := 1;
  Film := GetByName('Film') as TxvidGI;
  Film.SetFramePosition(Round(3449 * Progress));
  if Progress >= 1 then StopScriptVideo(False);
end;
{ @end $5AA424 }

{ @routine $5AA4E0 TfRuinsTalk_StopScriptVideo }
function TfRuinsTalk.StopScriptVideo(Unused: Boolean): Boolean;
var Film: TxvidGI;
begin
  Result := ScriptVideoTimer <> nil;
  if MusicEnabled and Result then
  begin
    MusicManager.StopImmediately;
    while MusicManager.IsPlaying do SysUtils.Sleep(1);
  end;
  if ScriptVideoTimer <> nil then
  begin
    CancelCallbackTimer(ScriptVideoTimer);
    ScriptVideoTimer := nil;
  end;
  Film := GetByName('Film') as TxvidGI;
  Film.ImageClose;
  Film.SetActive(False);
  InvalidateViewport;
  if Result and (QueuedVideos.Count > 0) then CompleteQueuedVideo(2);
end;
{ @end $5AA4E0 }

{ @routine $5AA5BC TfRuinsTalk_ProcessWindowMessage }
procedure TfRuinsTalk.ProcessWindowMessage(Message, WParam: Cardinal; LParam: Integer);
begin
  if ((Message <> WM_LBUTTONDOWN) and (Message <> WM_RBUTTONDOWN) and (Message <> WM_MBUTTONDOWN) and (Message <> WM_KEYDOWN)) or not StopScriptVideo(False) then
    inherited ProcessWindowMessage(Message, WParam, LParam);
end;
{ @end $5AA5BC }

{ @routine $5AA618 TfRuinsTalk_SelectMusic }
procedure TfRuinsTalk.SelectMusic;
var
  Name: WideString;
begin
  if (ActiveLoadPanel <> nil) and (ActiveLoadPanel.GetShutterDirection = -1) then Exit;
  if not MusicInPlanetEnabled then
  begin
    MusicManager.RequestFadeOut;
    Exit;
  end;
  if GetPlayer.DockedTo.TypeId in [Ord(rstRangerCenter)..Ord(rstCustomStation)] then
  begin
    if (GetPlayer.GetHull.CapitalShip = 1) and (RandomIntRange(0, 100) < 40) then
    begin
      StarMapScreen.BattleMusicSelected := True;
      MusicManager.PlayCategory('Destroyer');
    end
    else
    begin
      StarMapScreen.BattleMusicSelected := False;
      Name := GetPlayer.DockedTo.TypeNameOverrideKey;
      if Name <> '' then
      begin
        if MainDataConfig.GetBlock('Music').CountBlocks(Name) > 0 then MusicManager.PlayCategory(Name)
        else if MainDataConfig.GetBlock('Music').CountBlocks(GetPlayer.DockedTo.GetTypeNameKey) > 0 then
          MusicManager.PlayCategory(GetPlayer.DockedTo.GetTypeNameKey)
        else AppendLogLineThreadSafe(AnsiString('No music found for custom ' + Name + ', or for base type ' + GetPlayer.DockedTo.GetTypeNameKey));
      end
      else MusicManager.PlayCategory(GetPlayer.DockedTo.GetTypeNameKey);
    end;
  end
  else
  begin
    if GetPlayer.CurrentPlanet = nil then
    begin
      MusicManager.RequestFadeOut;
      Exit;
    end;
    if GetPlayer.CurrentPlanet.OwnerId = Byte(oiPirate) then
    begin
      if not GetPlayer.CurrentPlanet.IsMainPiratePlanet then MusicManager.PlayCategory('Nation.' + OwnerInfo[RaceToOwner(GetPlayer.CurrentPlanet.RaceId)].InternalName + 'Pirate')
      else MusicManager.PlayCategory('Nation.PiratePlanetMain');
    end
    else MusicManager.PlayCategory('Nation.' + OwnerInfo[GetPlayer.CurrentPlanet.OwnerId].InternalName);
  end;
end;
{ @end $5AA618 }

{ @routine $5AA9D8 TfRuinsTalk_I_Start }
procedure TfRuinsTalk.I_Start;
var
  Stage: Integer;
begin
  Stage := 0;
  try
    if IsTurnCalculationRunningUI then WaitForTurnCalculationUI;
    Stage := 1;
    if ShowArrivalVideo and (StationType = Byte(rstMilitaryBase)) then
    begin
      Stage := 2;
      ShowMilitaryBaseArrivalDialog(0);
    end
    else
    begin
      Stage := 3;
      M_Main(False);
    end;
    Stage := 4;
    ShowArrivalVideo := False;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create('Error in procedure TfRuinsTalk.I_Start, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5AA9D8 }

{ @routine $5AABA4 TfRuinsTalk_ShowDominatorVictoryDialog }
function TfRuinsTalk.ShowDominatorVictoryDialog: Boolean;
var
  MessageEntry: TMessagePlayer;
  Variant: Integer;
begin
  Result := False;
  if (Galaxy.TerronSeriesResolvedTurn <> 0) or (Galaxy.KellerSeriesResolvedTurn <> 0) or (Galaxy.BlazerSeriesResolvedTurn <> 0) then
  begin
    MessageEntry := FindPlayerBubbleByKey('BlazerWin', False);
    if (MessageEntry <> nil) and (MessageEntry.Kind = 3) then
    begin
      MessageEntry.Kind := 4;
      MessageEntry.WasRead := False;
      Result := True;
      if (BlazerShip = nil) and (Galaxy.BlazerSelfDestructTurn <> 0) then Variant := 1
      else if Galaxy.BlazerLandingPlanetId <> 0 then Variant := 2
      else Variant := 3;
      DialogText := ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Blazer' + IntToStr(Variant)), '<Date>', FormatGameTurnDate(Galaxy.BlazerSeriesResolvedTurn), '<color=255,240,100>');
      if (Variant = 2) and (BlazerShip <> nil) and (BlazerShip.CurrentPlanet <> nil) then
        DialogText := ReplaceColoredToken(DialogText, '<Planet>', BlazerShip.CurrentPlanet.Name, '<color=255,240,100>');
      DialogText := DialogText + #13#10 + ' ' + #13#10 + ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Reward'), '<Reward>', GetPlayer.AwardRandomMedal, '<color=255,240,100>');
      ClearChoices;
      AddChoice('- ' + LocalizedColorText('FormRuinsRC.Continue'), 0, ContinueDominatorVictoryDialog);
    end
    else
    begin
      MessageEntry := FindPlayerBubbleByKey('KellerWin', False);
      if (MessageEntry <> nil) and (MessageEntry.Kind = 3) then
      begin
        MessageEntry.Kind := 4;
        MessageEntry.WasRead := False;
        Result := True;
        if KellerShip = nil then Variant := 1 else Variant := 2;
        DialogText := ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Keller' + IntToStr(Variant)), '<Date>', FormatGameTurnDate(Galaxy.KellerSeriesResolvedTurn), '<color=255,240,100>');
        DialogText := DialogText + #13#10 + ' ' + #13#10 + ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Reward'), '<Reward>', GetPlayer.AwardRandomMedal, '<color=255,240,100>');
        ClearChoices;
        AddChoice('- ' + LocalizedColorText('FormRuinsRC.Continue'), 0, ContinueDominatorVictoryDialog);
      end
      else
      begin
        MessageEntry := FindPlayerBubbleByKey('TerronWin', False);
        if (MessageEntry <> nil) and (MessageEntry.Kind = 3) then
        begin
          MessageEntry.Kind := 4;
          MessageEntry.WasRead := False;
          Result := True;
          if Galaxy.TerronToStarTurn <> 0 then Variant := 1
          else if Galaxy.TerronWeaponLockTurn <> 0 then Variant := 2
          else if Galaxy.TerronGrowLockTurn <> 0 then Variant := 3
          else if Galaxy.TerronLandingLockTurn <> 0 then Variant := 4
          else
          begin
            if TerronShip = nil then Variant := 5
            else
            begin
              Variant := 1;
              RaiseWideMessage('Terron status');
            end;
          end;
          DialogText := ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Terron' + IntToStr(Variant)), '<Date>', FormatGameTurnDate(Galaxy.TerronSeriesResolvedTurn), '<color=255,240,100>');
          if (Variant = 1) and (TerronShip <> nil) and (TerronShip.CurrentStar <> nil) then
            DialogText := ReplaceColoredToken(DialogText, '<Star>', TerronShip.CurrentStar.Name, '<color=255,240,100>');
          DialogText := DialogText + #13#10 + ' ' + #13#10 + ReplaceColoredToken(LocalizedColorText('FormRuinsRC.Win.Reward'), '<Reward>', GetPlayer.AwardRandomMedal, '<color=255,240,100>');
          ClearChoices;
          AddChoice('- ' + LocalizedColorText('FormRuinsRC.Continue'), 0, ContinueDominatorVictoryDialog);
        end;
      end;
    end;
  end;
end;
{ @end $5AABA4 }

{ @routine $5AB3E4 TfRuinsTalk_ContinueDominatorVictoryDialog }
procedure TfRuinsTalk.ContinueDominatorVictoryDialog(Action: Integer);
begin
  if not ShowDominatorVictoryDialog then I_Start;
end;
{ @end $5AB3E4 }

{ @routine $5AB408 TfRuinsTalk_M_Main }
procedure TfRuinsTalk.M_Main(KeepText: Boolean);
const AllSeries = [dsBlazer, dsKeller, dsTerron];
var
  Script: TScript;
  Text, Prefix: WideString;
  Item: TItem;
  I, J, SelectedIndex, BestPriority, ModuleIndex, Place, ExcludedBefore, RangerCount, Parts: Integer;
  Ranger: TRanger;
  SwapEntry: TObject;
  Seed: Cardinal;
  ItemType: Byte;
  Weight, Level: Integer;
  Info: PWeaponInfo;
  MinimumSizeFactor, MaximumSizeFactor: Single;
  Stage: Integer;
  UnusedLocal: Integer; // Native frame retains four unreferenced bytes; original type unknown.
begin
  Stage := 0;
  try
    ClearScriptDialogRules;
    Stage := 1;
    ClearChoices;
    ScriptDialogIndex := -1;
    Script := nil;
    Stage := 2;
    if (GetPlayer.DockedTo.TypeId = Byte(rstRangerCenter)) and ShowDominatorVictoryDialog then Exit;
    Stage := 3;
    if GetPlayer.DockedTo.ScriptShip <> nil then
    begin
      Script := TScriptShip(GetPlayer.DockedTo.ScriptShip).Script;
      Text := TScriptShip(GetPlayer.DockedTo.ScriptShip).GetGroup.StationDialogVariable;
      if Text <> '' then
      begin
        Script.PublishShipContext(TScriptShip(GetPlayer.DockedTo.ScriptShip));
        Script.CallDialogByVariable(Text);
      end;
    end;
    Stage := 4;
    if not KeepText then
    begin
      Stage := 5;
      if StationBridgeMode = 1 then
      begin
        Stage := 6;
        DialogText := LocalizedColorText('FormRuins.Bridge.BridgeGreeting');
        ReplaceTextToken(DialogText, '<Energy>', IntToStr(GetPlayer.GetHull.Energy), '<color=255,240,100>');
        ReplaceTextToken(DialogText, '<EnergyMax>', IntToStr(GetPlayer.GetHull.EnergyMax), '<color=255,240,100>');
        if GetPlayer.GetHull.ImpulseShieldsEnabled then
          ReplaceTextToken(DialogText, '<ShieldMode>', LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsStatusOn'), '<color=255,240,100>')
        else ReplaceTextToken(DialogText, '<ShieldMode>', LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsStatusOff'), '<color=255,240,100>');
        ReplaceTextToken(DialogText, '<Count>', IntToStr(GetPlayer.CountActiveInterceptorTargets), '<color=255,240,100>');
        if GetPlayer.InHyperspace or (GetPlayer.RuinsSavedDockedTo <> nil) or (GetPlayer.RuinsSavedPlanet <> nil) then
          ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNotNormalSpace'), '</color>')
        else if GetPlayer.GetHull.Energy < GetPlayer.GetInterceptorEnergyCost then
          ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNoEnergy'), '</color>')
        else if GetPlayer.GetHull.InterceptorTarget <> nil then
          ReplaceTextToken(DialogText, '<Ship>', TShip(GetPlayer.GetHull.InterceptorTarget).GetFullName(' '), '<color=255,240,100>')
        else if GetPlayer.GetHull.InterceptorTargetingStrategy = itsManual then
          ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetOff'), '</color>')
        else if GetPlayer.SelectInterceptorTarget <> nil then
          ReplaceTextToken(DialogText, '<Ship>', GetPlayer.SelectInterceptorTarget.GetFullName(' '), '<color=255,240,100>')
        else ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetMissing'), '</color>');
        case GetPlayer.GetHull.InterceptorTargetingStrategy of
          itsManual: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), '<color=255,240,100>');
          itsMostHullPoints: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMax'), '<color=255,240,100>');
          itsFewestHullPoints: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMin'), '<color=255,240,100>');
          itsGreatestStrength: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyStrMax'), '<color=255,240,100>');
          itsStrongestDefense: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDefMax'), '<color=255,240,100>');
          itsNearest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMin'), '<color=255,240,100>');
          itsFarthest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMax'), '<color=255,240,100>');
        else ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), '<color=255,240,100>');
        end;
        ReplaceTextToken(DialogText, '<Duration>', IntToStr(GetPlayer.GetInterceptorPassCount), '<color=255,240,100>');
        ReplaceTextToken(DialogText, '<DeployCost>', IntToStr(GetPlayer.GetInterceptorEnergyCost), '<color=255,240,100>');
      end
      else if (StationBridgeMode > 1) or (GetPlayer.RuinsMode > 0) then DialogText := 'text missing'
      else
      begin
        Stage := 7;
        case GetPlayer.DockedTo.TypeId of
          Ord(rstRangerCenter):
            begin
              Stage := 8;
              Galaxy.RefreshRangerRatingPlaces;
              DialogText := LocalizedColorText('FormRuins.RC.Greeting');
              Place := GetPlayer.PlaceInRating;
              ExcludedBefore := 0;
              RangerCount := Galaxy.Rangers.Count;
              for I := 0 to Galaxy.Rangers.Count - 1 do
              begin
                Ranger := TRanger(Galaxy.Rangers[I]);
                if (GetPlayer <> Ranger) and Ranger.ExcludedFromRating then
                begin
                  Dec(RangerCount);
                  if Ranger.PlaceInRating < Place then Inc(ExcludedBefore);
                end;
              end;
              Place := Place - ExcludedBefore;
              if Place = 1 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GreetingBest')
              else case 100 * Place div RangerCount of
                0..30: DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GreetingGood');
                31..66: DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GreetingNormal');
              else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GreetingBad');
              end;
              DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GreetingAdd');
              ReplaceTextToken(DialogText, '<RC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
              ReplaceTextToken(DialogText, '<Number>', IntToStr(Place), '<color=255,240,100>');
              ReplaceTextToken(DialogText, '<BaseNod>', IntToStr(GetPlayer.BaseNodes), '<color=255,240,100>');
            end;
          Ord(rstPirateBase):
            begin
              Stage := 9;
              // Native $5ABDB5 retains this flag comparison with an empty body.
              if (GetPlayer.DockedTo as TRuins).SpecialServiceActive then;
              GetPlayer.AchievementStats.CheckBaronAchievement;
              DialogText := LocalizedColorText('FormRuins.PB.GreetingPre');
              DialogText := DialogText + LocalizedColorText('FormRuins.PB.GreetingMod');
              DialogText := DialogText + LocalizedColorText('FormRuins.PB.GreetingAft');
              if GetPlayer.MayTakeSubCrack then
                DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.PB.SabCrack.PBGreetingAdd');
              ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
              ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), '<color=255,240,100>');
            end;
          Ord(rstScienceBase):
            begin
              Stage := 10;
              if Galaxy.IsDominatorResearchComplete(AllSeries) or
                not Galaxy.HasUnresolvedDominatorSeries(AllSeries) then
                DialogText := LocalizedColorText('FormRuins.SB.GreetingAfterScn')
              else DialogText := LocalizedColorText('FormRuins.SB.GreetingBeforeScn');
              DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.SB.GreetingAdd');
              if Galaxy.CurrentTurn - 300 < 120 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuinsSB.History.SB');
              ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
            end;
          Ord(rstMilitaryBase):
            begin
              Stage := 11;
              if GetPlayer.CurrentStar.ControlFaction = sfDominators then
              begin
                DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBAfterQuestions');
                ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
              end
              else
              begin
                if (GetPlayer.OwnerId <> Byte(oiPirate)) and GetPlayer.TryPromoteRank then
                begin
                  Stage := 12;
                  DialogText := LocalizedColorText('FormRuins.WB.' + CoalitionRankNames[GetPlayer.Rank] + '.NewRank');
                  GetPlayer.AchievementStats.CheckCommanderAchievement;
                  ReplaceTextToken(DialogText, '<PredPoints>', IntToStr(CoalitionRankPointThresholds[GetPlayer.Rank - 1]), '<color=255,240,100>');
                  if GetPlayer.Rank = 7 then
                  begin
                    ModuleIndex := FindMicroModuleTemplateByCustomTag('AkrinAmplifier');
                    Item := TMicroModule.Create;
                    if ModuleIndex >= 0 then (Item as TMicroModule).Init(ModuleIndex)
                    else (Item as TMicroModule).Init(Galaxy.SelectMicroModule(1, 15, Galaxy.GenerationSeed + Cardinal(Galaxy.CurrentTurn), GetPlayer.DockedTo));
                    GetPlayer.Inventory.Add(Item);
                    ReplaceTextToken(DialogText, '<MMName>', (Item as TMicroModule).GetPlainName, '<color=255,240,100>');
                  end;
                  Seed := Galaxy.CurrentTurn div 50 * (GetPlayer.DockedTo.Id * (GetPlayer.Rank + 11));
                  MinimumSizeFactor := EquipmentSizeFactors[4];
                  MaximumSizeFactor := EquipmentSizeFactors[2];
                  if NextRandomIntRange(1, 100, Seed) > 70 then
                  begin
                    Info := Galaxy.SelectWeaponInfo(Seed, [0, 1, Ord(OwnerWeaponAvailability[StationOwner])], Min(Galaxy.TechLevel + 2, 8), Galaxy.TechLevel);
                    Seed := Galaxy.CurrentTurn div 33 * (GetPlayer.DockedTo.Id * (GetPlayer.Rank + 17));
                    Weight := NextRandomIntRange(Round(Info.AverageSize * MinimumSizeFactor), Round(Info.AverageSize * MaximumSizeFactor), Seed);
                    Level := Round(RemapClamped(Round(RemapClamped(ShortInt(GetPlayer.Rank * 1), 0, 7, 1, 5)), 1, 5, 3, 8));
                    Item := CreateGeneratedWeapon(Info, Weight, Level, StationOwner);
                  end
                  else
                  begin
                    ItemType := PickRandomItemType([Ord(t_FuelTanks)..Ord(t_DefGenerator)]);
                    Seed := Galaxy.CurrentTurn div 33 * (GetPlayer.DockedTo.Id * (GetPlayer.Rank + 17));
                    Weight := NextRandomIntRange(Round(GetAverageItemSize(ItemType) * MinimumSizeFactor), Round(GetAverageItemSize(ItemType) * MaximumSizeFactor), Seed);
                    Level := Round(RemapClamped(ShortInt(GetPlayer.Rank * 1), 0, 7, 3, 8));
                    Item := CreateGeneratedEquipment(TItemType(ItemType), Weight, Level, StationOwner);
                  end;
                  if Item <> nil then
                    ReplaceTextToken(DialogText, '<ItemName>', Item.GetDisplayName, '<color=255,240,100>')
                  else RaiseWideMessage('eq=nil');
                  GetPlayer.Inventory.Add(Item);
                end
                else DialogText := LocalizedColorText('FormRuins.WB.' + CoalitionRankNames[GetPlayer.Rank] + '.Greeting');
                if ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
                  ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) and (GetPlayer.OwnerId <> Byte(oiPirate)) then
                begin
                  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.FlyToEnemy.GreetingAdd');
                  ReplaceTextToken(DialogText, '<StarEnemy>', (GetPlayer.DockedTo as TRuins).FlyToStar.Name, '<color=255,240,100>');
                  ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate((GetPlayer.DockedTo as TRuins).FlyDate), '<color=255,240,100>');
                  MilitaryTravelDistance := Round(PointDistance((GetPlayer.DockedTo as TRuins).FlyToStar.Position, GetPlayer.CurrentStar.Position));
                end;
                if GetPlayer.CountProgramRewardStocks > 0 then
                  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.Programms.GreetingAdd');
                ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
                ReplaceTextToken(DialogText, '<Rank>', GetPlayer.GetRankName, '<color=255,240,100>');
                ReplaceTextToken(DialogText, '<NeedPoints>', IntToStr(GetPlayer.GetRankPointsToNextRank), '<color=255,240,100>');
              end;
            end;
          Ord(rstBusinessCenter):
            begin
              Stage := 13;
              DialogText := LocalizedColorText('FormRuins.BK.Greeting');
              if GetPlayer.DebtAmount > 0 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.BK.AddDebtYes')
              else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.BK.AddDebtNot');
              if GetPlayer.DebtDefaultCount >= 3 then DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.BK.AddDebtContinue');
              ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
              ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.DebtAmount), '<color=255,240,100>');
              ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(GetPlayer.DebtDueTurn), '<color=255,240,100>');
            end;
          Ord(rstMedicalBase):
            begin
              Stage := 14;
              DialogText := LocalizedColorText('FormRuins.MC.Greeting');
              ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
            end;
          Ord(rstDominion):
            begin
              Stage := 15;
              if GetPlayer.DockedTo.InHyperspace then DialogText := LocalizedColorText('FormRuins.CB.GreetingHyperspace')
              else if GetPlayer.QueuedTravelTarget <> nil then
              begin
                DialogText := LocalizedColorText('FormRuins.CB.GreetingPlayerFlyToStar');
                ReplaceTextToken(DialogText, '<FlyToStar>', GetPlayer.QueuedTravelTarget.Name, '<color=255,240,100>');
              end
              else if (GetPlayer.DockedTo.Order = soTeleport) and (Cardinal(GetPlayer.DockedTo.OrderStateData) > 0) then
              begin
                DialogText := LocalizedColorText('FormRuins.CB.GreetingFlyToStar');
                ReplaceTextToken(DialogText, '<FlyToStar>', TStar(GetPlayer.DockedTo.OrderTarget).Name, '<color=255,240,100>');
              end
              else DialogText := LocalizedColorText('FormRuins.CB.GreetingNormal');
              ReplaceTextToken(DialogText, '<CB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
            end;
        end;
      end;
      Stage := 16;
      if (GetPlayer.DockedTo is TRuins) and (GetPlayer.DockedTo as TRuins).SpecialServiceActive then
        DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Before');
    end;
    Stage := 17;
    if ScriptDialogIndex < 0 then
    begin
      Stage := 18;
      for I := 0 to Galaxy.Scripts.Count - 1 do
      begin
        Script := TScript(Galaxy.Scripts[I]);
        Script.RunDialogCode;
      end;
      Stage := 19;
      if ScriptDialogOverrides.Count > 0 then
      begin
        Stage := 20;
        SelectedIndex := 0;
        BestPriority := PScriptDialogOverride(ScriptDialogOverrides[0]).Priority;
        for I := 0 to ScriptDialogOverrides.Count - 1 do
          if PScriptDialogOverride(ScriptDialogOverrides[I]).Priority > BestPriority then
          begin
            SelectedIndex := I;
            BestPriority := PScriptDialogOverride(ScriptDialogOverrides[I]).Priority;
          end;
        Script := PScriptDialogOverride(ScriptDialogOverrides[SelectedIndex]).Script;
        Script.InitCode.LocalVar.GetVar('GAnswerData').SetDword(PScriptDialogOverride(ScriptDialogOverrides[SelectedIndex]).AnswerData);
        Text := PScriptDialogOverride(ScriptDialogOverrides[SelectedIndex]).DialogName;
        if Text <> '' then
        begin
          Script.PublishCurrentShip(GetPlayer.DockedTo);
          Script.CallDialogByVariable(Text);
          if ScriptDialogIndex < 0 then AppendLogLineThreadSafe(Script.ScriptFileName + ' has overriden dialog with ' + Text + ' but it failed to start');
        end;
        if ScriptDialogIndex < 0 then
        begin
          Stage := 21;
          M_Main(True);
        end
        else
        begin
          Stage := 22;
          SelectScriptDialog(Integer(Script));
        end;
      end
      else
      begin
        Stage := 23;
        SelectedIndex := -1;
        BestPriority := 0;
        if not KeepText then
          for I := 0 to ScriptDialogInjections.Count - 1 do
            if PScriptDialogInjection(ScriptDialogInjections[I]).ReplaceGreeting then
              if (SelectedIndex < 0) or (PScriptDialogInjection(ScriptDialogInjections[I]).Priority > BestPriority) then
              begin
                BestPriority := PScriptDialogInjection(ScriptDialogInjections[I]).Priority;
                SelectedIndex := I;
              end;
        if SelectedIndex >= 0 then DialogText := PScriptDialogInjection(ScriptDialogInjections[SelectedIndex]).Text;
        for I := 1 to ScriptDialogInjections.Count - 1 do
          for J := ScriptDialogInjections.Count - 1 downto I do
            if PScriptDialogInjection(ScriptDialogInjections[J]).Priority > PScriptDialogInjection(ScriptDialogInjections[J - 1]).Priority then
            begin
              SwapEntry := ScriptDialogInjections[J];
              ScriptDialogInjections[J] := ScriptDialogInjections[J - 1];
              ScriptDialogInjections[J - 1] := SwapEntry;
            end;
        for I := 0 to ScriptDialogInjections.Count - 1 do
        begin
          if not PScriptDialogInjection(ScriptDialogInjections[I]).ReplaceGreeting then
          begin
            Text := PScriptDialogInjection(ScriptDialogInjections[I]).Text;
            if (Text <> '') and not KeepText then DialogText := DialogText + #13#10 + Text;
          end;
          Text := PScriptDialogInjection(ScriptDialogInjections[I]).Answer;
          if Text <> '' then
          begin
            Prefix := '';
            Parts := CountDelimitedPartsW(Text, '~');
            if Parts > 1 then
            begin
              Prefix := ExtractDelimitedPartW(Text, 0, '~');
              Text := ExtractDelimitedRangeW(Text, 1, Parts - 1, '~');
            end;
            if Prefix = 'block' then AddChoice(Text, 0, ScriptDialogBlockCallback)
            else if Prefix = 'snap' then AddChoice(Text, Integer(ScriptDialogInjections[I]), RunInjectedDialogKeepingScroll)
            else AddChoice(PScriptDialogInjection(ScriptDialogInjections[I]).Answer, Integer(ScriptDialogInjections[I]), RunInjectedDialog);
          end;
        end;
        Stage := 24;
        BuildBuiltinServiceOptions;
      end;
    end
    else
    begin
      Stage := 25;
      if not Script.SkipGreeting then AddChoice('- ' + LocalizedColorText('FormRuins.I_Continue'), Integer(Script), SelectScriptDialog)
      else
      begin
        Script.SkipGreeting := False;
        SelectScriptDialog(Integer(Script));
      end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      if Galaxy = nil then AppendLogLineThreadSafe('Galaxy=nil')
      else if GetPlayer = nil then AppendLogLineThreadSafe('Player=nil')
      else if GetPlayer.DockedTo = nil then AppendLogLineThreadSafe('CurShip=nil');
      raise Exception.Create('Error in procedure TfRuinsTalk.M_Main, label = ' + IntToStr(Stage));
    end;
  end;
end;
{ @end $5AB408 }

{ @routine $5AE508 TfRuinsTalk_CloseHullMode }
procedure TfRuinsTalk.CloseHullMode(Action: Integer);
begin
  GetPlayer.CloseRuinsModeScreen;
end;
{ @end $5AE508 }

{ @routine $5AE524 TfRuinsTalk_ToggleImpulseShields }
procedure TfRuinsTalk.ToggleImpulseShields(Action: Integer);
begin
  GetPlayer.GetHull.ImpulseShieldsEnabled := not GetPlayer.GetHull.ImpulseShieldsEnabled;
  GetPlayer.GetHull.Energy := Max(0, GetPlayer.GetHull.Energy - 10);
  ClearChoices;
  M_Main(False);
end;
{ @end $5AE524 }

{ @routine $5AE59C TfRuinsTalk_ShowBridgeBlackHoleDialog }
procedure TfRuinsTalk.ShowBridgeBlackHoleDialog(Action: Integer);
begin
  if not GetPlayer.NoJump then
  begin
    DialogText := LocalizedColorText('FormRuins.Bridge.BridgeBHChooseDestination');
    ReplaceTextToken(DialogText, '<Cost>', IntToStr(600), '<color=255,240,100>');
    ClearChoices;
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeBHToStarMap'), 0, SelectBridgeBlackHoleDestination);
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeBHCancel'), 0, ReturnToMain);
  end
  else if GetPlayer.NoJump then
  begin
    DialogText := LocalizedColorText('FormRuins.Bridge.BridgeBHHyperLock');
    ClearChoices;
    AddChoice('- ' + LocalizedColorText('FormRuins.I_Continue'), 0, ReturnToMain);
  end;
end;
{ @end $5AE59C }

{ @routine $5AE8E8 TfRuinsTalk_SelectBridgeBlackHoleDestination }
procedure TfRuinsTalk.SelectBridgeBlackHoleDestination(Action: Integer);
begin
  MainPanel.NavigationLocked := True;
  GetByName('PM_WinMsg').SetActive(False);
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  GalaxyScreen.ViewMode := 3;
  GalaxyReturnScreenId := FormToId(Self);
  RequestedScreenId := screenGalaxy;
  RequestClose(1);
end;
{ @end $5AE8E8 }

{ @routine $5AE98C TfRuinsTalk_ShowInterceptorDialog }
procedure TfRuinsTalk.ShowInterceptorDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsChooseAction');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(GetPlayer.CountActiveInterceptorTargets), '<color=255,240,100>');
  if GetPlayer.InHyperspace or (GetPlayer.RuinsSavedDockedTo <> nil) or (GetPlayer.RuinsSavedPlanet <> nil) then
    ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNotNormalSpace'), '</color>')
  else if GetPlayer.GetHull.Energy < GetPlayer.GetInterceptorEnergyCost then
    ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetNoEnergy'), '</color>')
  else if GetPlayer.GetHull.InterceptorTarget <> nil then
    ReplaceTextToken(DialogText, '<Ship>', TShip(GetPlayer.GetHull.InterceptorTarget).GetFullName(' '), '<color=255,240,100>')
  else if GetPlayer.GetHull.InterceptorTargetingStrategy = itsManual then
    ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetOff'), '</color>')
  else if GetPlayer.SelectInterceptorTarget <> nil then
    ReplaceTextToken(DialogText, '<Ship>', GetPlayer.SelectInterceptorTarget.GetFullName(' '), '<color=255,240,100>')
  else ReplaceTextToken(DialogText, '<Ship>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsNextTargetMissing'), '</color>');
  case GetPlayer.GetHull.InterceptorTargetingStrategy of
    itsManual: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), '<color=255,240,100>');
    itsMostHullPoints: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMax'), '<color=255,240,100>');
    itsFewestHullPoints: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMin'), '<color=255,240,100>');
    itsGreatestStrength: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyStrMax'), '<color=255,240,100>');
    itsStrongestDefense: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDefMax'), '<color=255,240,100>');
    itsNearest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMin'), '<color=255,240,100>');
    itsFarthest: ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMax'), '<color=255,240,100>');
  else ReplaceTextToken(DialogText, '<Strategy>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), '<color=255,240,100>');
  end;
  ReplaceTextToken(DialogText, '<Duration>', IntToStr(GetPlayer.GetInterceptorPassCount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DeployCost>', IntToStr(GetPlayer.GetInterceptorEnergyCost), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.CountActiveInterceptorTargets > 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffAsk'), 0, ShowActiveInterceptors)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffAsk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationChangeAsk'), 0, ShowInterceptorPassDialog);
  if not GetPlayer.InHyperspace and (GetPlayer.RuinsSavedDockedTo = nil) and
    (GetPlayer.RuinsSavedPlanet = nil) and (GetPlayer.GetHull.Energy >= GetPlayer.GetInterceptorEnergyCost) then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetChangeAsk'), 0, ShowInterceptorTargetDialog)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetChangeAsk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargeting'), 0, ShowInterceptorStrategyDialog);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDone'), 0, ReturnToMain);
end;
{ @end $5AE98C }

{ @routine $5AF828 TfRuinsTalk_ShowActiveInterceptors }
procedure TfRuinsTalk.ShowActiveInterceptors(Action: Integer);
var
  ShipList, Text: WideString;
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffChoose');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(GetPlayer.CountActiveInterceptorTargets), '<color=255,240,100>');
  ShipList := '';
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffAll'), 0, RecallAllInterceptors);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := GetPlayer.CurrentStar.StarDistances[I].Star;
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if GetPlayer = Ship.InterceptorSourceShip then
      begin
        ShipList := ShipList + Ship.GetFullName(' ') + #13#10;
        Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffShip');
        ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), '<color=255,240,100>');
        AddChoice('- ' + Text, Integer(Ship), RecallInterceptorsFromTarget);
      end;
    end;
  end;
  ReplaceTextToken(DialogText, '<ShipList>', ShipList, '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsCallOffCancel'), 0, ShowInterceptorDialog);
end;
{ @end $5AF828 }

{ @routine $5AFCB4 TfRuinsTalk_RecallInterceptorsFromTarget }
procedure TfRuinsTalk.RecallInterceptorsFromTarget(Action: Integer);
begin
  TShip(Action).ClearIncomingInterceptors;
  if GetPlayer.CountActiveInterceptorTargets > 0 then ShowActiveInterceptors(0)
  else ShowInterceptorDialog(0);
end;
{ @end $5AFCB4 }

{ @routine $5AFCF0 TfRuinsTalk_RecallAllInterceptors }
procedure TfRuinsTalk.RecallAllInterceptors(Action: Integer);
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
begin
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := GetPlayer.CurrentStar.StarDistances[I].Star;
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[J]);
      if GetPlayer = Ship.InterceptorSourceShip then Ship.ClearIncomingInterceptors;
    end;
  end;
  ShowInterceptorDialog(0);
end;
{ @end $5AFCF0 }

{ @routine $5AFD94 TfRuinsTalk_ShowInterceptorPassDialog }
procedure TfRuinsTalk.ShowInterceptorPassDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationChoose');
  ReplaceTextToken(DialogText, '<Duration>', IntToStr(GetPlayer.GetInterceptorPassCount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DeployCost>', IntToStr(GetPlayer.GetInterceptorEnergyCost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DurationMax>', IntToStr(10), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DurationMin>', IntToStr(2), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.GetInterceptorPassCount < 10 then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationMore'), 0, IncreaseInterceptorPassCount)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationMore'), 0, ScriptDialogBlockCallback);
  if GetPlayer.GetInterceptorPassCount > 2 then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationLess'), 0, DecreaseInterceptorPassCount)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationLess'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsDurationDone'), 0, ShowInterceptorDialog);
end;
{ @end $5AFD94 }

{ @routine $5B0288 TfRuinsTalk_IncreaseInterceptorPassCount }
procedure TfRuinsTalk.IncreaseInterceptorPassCount(Action: Integer);
begin
  GetPlayer.GetHull.InterceptorPassCountOverride := GetPlayer.GetInterceptorPassCount + 1;
  ShowInterceptorPassDialog(0);
end;
{ @end $5B0288 }

{ @routine $5B02C4 TfRuinsTalk_DecreaseInterceptorPassCount }
procedure TfRuinsTalk.DecreaseInterceptorPassCount(Action: Integer);
begin
  GetPlayer.GetHull.InterceptorPassCountOverride := GetPlayer.GetInterceptorPassCount - 1;
  ShowInterceptorPassDialog(0);
end;
{ @end $5B02C4 }

{ @routine $5B0300 TfRuinsTalk_ShowInterceptorTargetDialog }
procedure TfRuinsTalk.ShowInterceptorTargetDialog(Action: Integer);
var
  I: Integer;
  Text: WideString;
  Ship: TShip;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetChangeAsk');
  ClearChoices;
  if GetPlayer.GetHull.InterceptorTarget <> nil then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetCancelManual'), 0, ClearInterceptorTarget)
  else AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetCancelManual'), 0, ScriptDialogBlockCallback);
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(GetPlayer.CurrentStar.Ships[I]);
    if (GetPlayer <> Ship) and (GetPlayer.DockedTo <> Ship) and
      (not (Ship is TRuins) or GetPlayer.CanSelectShipTarget(Ship)) and Ship.InNormalSpace and
      (PointDistanceSquared(GetPlayer.Position, Ship.Position) <= 1000000) and (Ship.InterceptorPassesRemaining <= 0) then
    begin
      Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetShip');
      ReplaceTextToken(Text, '<Ship>', Ship.GetFullName(' '), '<color=255,240,100>');
      AddChoice('- ' + Text, Integer(Ship), SelectInterceptorTarget);
    end;
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetCancel'), 0, ShowInterceptorDialog);
end;
{ @end $5B0300 }

{ @routine $5B073C TfRuinsTalk_SelectInterceptorTarget }
procedure TfRuinsTalk.SelectInterceptorTarget(Action: Integer);
begin
  GetPlayer.GetHull.InterceptorTarget := Pointer(Action);
  ShowInterceptorDialog(0);
end;
{ @end $5B073C }

{ @routine $5B0768 TfRuinsTalk_ClearInterceptorTarget }
procedure TfRuinsTalk.ClearInterceptorTarget(Action: Integer);
begin
  GetPlayer.GetHull.InterceptorTarget := nil;
  ShowInterceptorDialog(0);
end;
{ @end $5B0768 }

{ @routine $5B0794 TfRuinsTalk_ShowInterceptorStrategyDialog }
procedure TfRuinsTalk.ShowInterceptorStrategyDialog(Action: Integer);
var
  Text: WideString;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargeting');
  ClearChoices;
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyManual'), '<color=255,240,100>');
  AddChoice('- ' + Text, 0, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMax'), '<color=255,240,100>');
  AddChoice('- ' + Text, 1, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyHPMin'), '<color=255,240,100>');
  AddChoice('- ' + Text, 2, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyStrMax'), '<color=255,240,100>');
  AddChoice('- ' + Text, 3, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDefMax'), '<color=255,240,100>');
  AddChoice('- ' + Text, 4, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMin'), '<color=255,240,100>');
  AddChoice('- ' + Text, 5, SelectInterceptorStrategy);
  Text := LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingAttack');
  ReplaceTextToken(Text, '<StrategyName>', LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingStrategyDistMax'), '<color=255,240,100>');
  AddChoice('- ' + Text, 6, SelectInterceptorStrategy);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsTargetingCancel'), 0, ShowInterceptorDialog);
end;
{ @end $5B0794 }

{ @routine $5B0F94 TfRuinsTalk_SelectInterceptorStrategy }
procedure TfRuinsTalk.SelectInterceptorStrategy(Action: Integer);
begin
  GetPlayer.GetHull.InterceptorTargetingStrategy := TInterceptorTargetingStrategy(Action);
  ShowInterceptorDialog(0);
end;
{ @end $5B0F94 }

{ @routine $5B0FC4 TfRuinsTalk_ShowBridgeHelp }
procedure TfRuinsTalk.ShowBridgeHelp(Action: Integer);
var
  I: Integer;
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeHelpChoose');
  ClearChoices;
  for I := 1 to 5 do
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpQuestion' + IntToStr(I)), I, ShowBridgeHelpAnswer);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpCancel'), 0, ReturnToMain);
end;
{ @end $5B0FC4 }

{ @routine $5B11B0 TfRuinsTalk_ShowBridgeHelpAnswer }
procedure TfRuinsTalk.ShowBridgeHelpAnswer(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.Bridge.BridgeHelpAnswer' + IntToStr(Cardinal(Action)));
  ClearChoices;
  ReplaceTextToken(DialogText, '<SwitchCost>', IntToStr(10), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<BHCost>', IntToStr(600), '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpMoreQuestions'), 0, ShowBridgeHelp);
  AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpNoQuestions'), 0, ReturnToMain);
end;
{ @end $5B11B0 }

{ @routine $5B1494 TfRuinsTalk_BuildBuiltinServiceOptions }
procedure TfRuinsTalk.BuildBuiltinServiceOptions;
const AllSeries = [dsBlazer, dsKeller, dsTerron];
var
  Text: WideString;
begin
  if StationBridgeMode = 1 then
  begin
    if GetPlayer.GetHull.ImpulseShieldsEnabled then
      Text := LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsOff')
    else Text := LocalizedColorText('FormRuins.Bridge.BridgeImpulseShieldsOn');
    ReplaceTextToken(Text, '<SwitchCost>', IntToStr(10), '<color=255,240,100>');
    if GetPlayer.GetHull.Energy >= 10 then AddChoice('- ' + Text, 0, ToggleImpulseShields)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
    Text := LocalizedColorText('FormRuins.Bridge.BridgeBHAsk');
    ReplaceTextToken(Text, '<Cost>', IntToStr(600), '<color=255,240,100>');
    if not GetPlayer.InHyperspace and (GetPlayer.RuinsSavedDockedTo = nil) and
      (GetPlayer.RuinsSavedPlanet = nil) and (GetPlayer.GetHull.Energy >= 600) then
      AddChoice('- ' + Text, 0, ShowBridgeBlackHoleDialog)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
    if GetPlayer.GetHull.InterceptorsEnabled then
      AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeInterceptorsAsk'), 0, ShowInterceptorDialog);
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeHelpAsk'), 0, ShowBridgeHelp);
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeExit'), 0, CloseHullMode);
  end
  else if StationBridgeMode > 1 then
    AddChoice('- ' + LocalizedColorText('FormRuins.Bridge.BridgeExit'), 0, CloseHullMode)
  else
  begin
    case GetPlayer.DockedTo.TypeId of
      Ord(rstRangerCenter):
        begin
          if GetPlayer.GetCarriedNodeCount > 0 then
            AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.RC.SaleNod.PlayerSend'), '<color=255,240,100>', '<Count>', IntToStr(GetPlayer.GetCarriedNodeCount)), 0, DepositNodesAtRangerCenter);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerSend'), 0, ShowRangerCenterTakeNodeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.GiveNod.PlayerSend'), 0, ShowRangerCenterGiveNodeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.AboutNod.PlayerSend'), 0, ShowRangerCenterNodeInfo);
          if Galaxy.PirateWinTurn = 0 then
            AddChoice('- ' + LocalizedColorText('FormRuins.RC.PirateClan.PlayerSend'), 0, ShowRangerCenterPirateClanAnswer);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.Rating.PlayerSend'), 0, ShowRangerCenterRatingAnswer);
          AddChoice('- ' + LocalizedColorText('FormRuins.RC.BestRanger.PlayerSend'), 0, ShowRangerCenterBestRangerAnswer);
        end;
      Ord(rstPirateBase):
        begin
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeNationality.ChangeNationality'), 0, ShowPirateBaseNationalityDialog);
          if GetPlayer.PirateClanReal and (GetPlayer.OwnerId <> Byte(oiPirate)) and (Galaxy.PirateWinType <> 3) then
            AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.ChangeSideToPirate'), 0, ShowPirateBaseSideChangeDialog);
          if (GetPlayer.OwnerId = Byte(oiPirate)) and (Galaxy.CoalitionDefeatedTurn = 0) then
            AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.ChangeSideToNormal'), 0, ShowPirateBaseSideChangeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.Program.PlayerAsk'), 0, ShowPirateBaseProgramDialog);
          if Galaxy.ArePirateNodesEnabled then
            AddChoice('- ' + LocalizedColorText('FormRuins.PB.Nod.PlayerAsk'), 0, ShowPirateBaseNodeDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.Repair.PlayerSend'), 0, ShowPirateBaseRepairDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.PB.Chameleon.PlayerAsk'), 0, ShowPirateBaseChameleonDialog);
          if GetPlayer.MayTakeSubCrack then
            if GetPlayer.GetSubCrackCost <= GetPlayer.Money then
              AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerInfo'), 0, ShowPirateBaseSubCrackDialog)
            else AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerInfo'), 0, ScriptDialogBlockCallback);
        end;
      Ord(rstMilitaryBase):
        begin
          if GetPlayer.CurrentStar.ControlFaction = sfDominators then
          begin
            ClearChoices;
            AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerHangar'), 0, OpenHangar);
          end
          else
          begin
            if GetPlayer.OwnerId <> Byte(oiPirate) then
            begin
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.WarWithKlingAndPirates.PlayerSend'), 0, I_WarWithKlingAndPirates);
              if GetPlayer.Rank < 6 then
                AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.NextRank.PlayerSend'), '<color=255,240,100>', '<NextRank>', GetPlayer.GetNextRankName), 0, ShowMilitaryBaseNextRankDialog);
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerSend'), 0, ShowMilitaryBaseRepairDialog);
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.WarOperation.PlayerSend'), 0, ShowMilitaryBaseWarOperationDialog);
              if ((GetPlayer.DockedTo as TRuins).FlyToStar <> nil) and
                ((GetPlayer.DockedTo as TRuins).FlyToStar <> GetPlayer.CurrentStar) then
                AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerAsk'), '<color=255,240,100>', '<StarEnemy>', (GetPlayer.DockedTo as TRuins).FlyToStar.Name), 0, ShowMilitaryBaseTravelDialog);
            end
            else AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerSend'), 0, ShowMilitaryBaseRepairDialog);
            if GetPlayer.CountProgramRewardStocks > 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.WB.Programms.PlayerAsk'), 0, ShowMilitaryBaseProgramsDialog);
          end;
        end;
      Ord(rstScienceBase):
        begin
          AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerSend'), 0, ShowScienceBaseImprovementDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerSend'), 0, ShowScienceBaseRepairDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.SB.Satellite.PlayerSend'), 0, ShowScienceBaseSatelliteOfferDialog);
          if Galaxy.HasUnresolvedDominatorSeries(AllSeries) and
            not Galaxy.IsDominatorResearchComplete(AllSeries) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerAsk'), 0, ShowScienceBaseResearchDialog);
          if Galaxy.IsDominatorSeriesUnresolved(dsBlazer) and Galaxy.IsDominatorResearchComplete([dsBlazer]) and not GetPlayer.HasProgram(prgLogicalNegation) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechBlazer'), 1, BuyScienceBaseResearchProgram);
          if Galaxy.IsDominatorSeriesUnresolved(dsKeller) and Galaxy.IsDominatorResearchComplete([dsKeller]) and not GetPlayer.HasProgram(prgDematerial) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechKeller'), 2, BuyScienceBaseResearchProgram);
          if Galaxy.IsDominatorSeriesUnresolved(dsTerron) and Galaxy.IsDominatorResearchComplete([dsTerron]) and not GetPlayer.HasProgram(prgEnergotron) then
            AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechTerron'), 3, BuyScienceBaseResearchProgram);
          if Galaxy.CurrentTurn - 300 < 120 then
            AddChoice('- ' + LocalizedColorText('FormRuinsSB.History.PlayerOk'), 0, ShowScienceBaseHistoryDialog);
        end;
      Ord(rstBusinessCenter):
        begin
          if GetPlayer.DebtAmount = 0 then
            AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerSend'), 0, ShowBusinessCenterDebtDialog)
          else
          begin
            if GetPlayer.Money > GetPlayer.DebtAmount then
              AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDebt.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(GetPlayer.DebtAmount)), 0, RepayBusinessCenterDebt)
            else AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDebt.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(GetPlayer.DebtAmount)), 0, ScriptDialogBlockCallback);
          end;
          if GetPlayer.DebtDefaultCount < 3 then
          begin
            if GetPlayer.DepositAmount = 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.BK.Deposit.PlayerSend'), 0, ShowBusinessCenterDepositDialog)
            else
            begin
              if Galaxy.CurrentTurn - GetPlayer.DepositStartTurn > 30 then
                AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDeposit.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(GetPlayer.ComputeDepositAccruedValue)), 0, WithdrawBusinessCenterDeposit)
              else AddChoice(FormatText1('- ' + LocalizedColorText('FormRuins.BK.RetDeposit.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(GetPlayer.ComputeDepositAccruedValue)), 0, ScriptDialogBlockCallback);
            end;
            AddChoice('- ' + LocalizedColorText('FormRuins.BK.Investment.PlayerSend'), 0, ShowBusinessCenterInvestmentDialog);
            AddChoice('- ' + LocalizedColorText('FormRuins.BK.Trade.PlayerSend'), 0, ShowBusinessCenterTradeDialog);
            if GetPlayer.MedicalPolicyTicks <= 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerSend'), 0, ShowBusinessCenterMedicalPolicyDialog);
          end;
        end;
      Ord(rstMedicalBase):
        begin
          AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerSend'), 0, ShowMedicalCenterIllnessTreatmentDialog);
          AddChoice('- ' + LocalizedColorText('FormRuins.MC.Stimulants.PlayerSend'), 0, ShowMedicalCenterStimulantDialog);
        end;
      Ord(rstDominion):
        begin
          if GetPlayer.QueuedTravelTarget <> nil then
          begin
            AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.ToHangar'), 0, OpenHangar);
            AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.CancelFly'), 0, ShowDominionCancelTravelDialog);
          end
          else
          begin
            if GetPlayer.PirateLicenseTicks = 0 then
              AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerSend'), 0, ShowDominionPirateLicenseDialog)
            else if GetPlayer.PirateLicenseTicks < 305 then
              AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerSendProlongate'), 0, ShowDominionPirateLicenseDialog);
            AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.PlayerSend'), 0, ShowDominionShipConstructionDialog);
            AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerSend'), 0, ShowDominionImprovementDialog);
            if GetPlayer.DockedTo.InNormalSpace and (GetPlayer.DockedTo.CurrentStar.Dominion = GetPlayer.DockedTo) then
            begin
              AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.PlayerSend'), 0, ShowDominionTravelDialog);
              if Galaxy.PirateWinType <> 3 then
                AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.PlayerAsk'), 0, I_CBWarWithKlingAndCoalition);
            end
            else
            begin
              AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.PlayerSend'), 0, ScriptDialogBlockCallback);
              if Galaxy.PirateWinType <> 3 then
                AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.PlayerAsk'), 0, ScriptDialogBlockCallback);
            end;
          end;
        end;
    end;
  end;
  if (GetPlayer.DockedTo is TRuins) and (GetPlayer.DockedTo as TRuins).SpecialServiceActive then
    AddChoice('- ' + LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Ask'), 0, ShowStationSpecialShipDialog);
  if StationBridgeMode = 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.GN.Modern.PlayerAsk'), 0, OpenStationModernization);
end;
{ @end $5B1494 }

{ @routine $5B3C54 TfRuinsTalk_ContinueScriptDialog }
procedure TfRuinsTalk.ContinueScriptDialog;
begin
  CurrentScript.ExecuteDialogAnswer(CurrentScript.CurrentAnswer);
  M_Main(True);
end;
{ @end $5B3C54 }

{ @routine $5B3C80 TfRuinsTalk_AddScriptTakeoffChoice }
procedure TfRuinsTalk.AddScriptTakeoffChoice(Caption: WideString);
begin
  if Caption = '' then AddChoice('- ' + LocalizedColorText('FormRuins.I_TakeOff'), CurrentScript.CurrentAnswer, RunScriptTakeoff)
  else AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptTakeoff);
end;
{ @end $5B3C80 }

{ @routine $5B3D7C TfRuinsTalk_AddScriptNewsExitChoice }
procedure TfRuinsTalk.AddScriptNewsExitChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptNewsExit);
end;
{ @end $5B3D7C }

{ @routine $5B3E04 TfRuinsTalk_AddScriptHangarChoice }
procedure TfRuinsTalk.AddScriptHangarChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptHangar);
end;
{ @end $5B3E04 }

{ @routine $5B3E8C TfRuinsTalk_AddScriptGoodsChoice }
procedure TfRuinsTalk.AddScriptGoodsChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptGoods);
end;
{ @end $5B3E8C }

{ @routine $5B3F14 TfRuinsTalk_AddScriptGameEndChoice }
procedure TfRuinsTalk.AddScriptGameEndChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptGameEnd);
end;
{ @end $5B3F14 }

{ @routine $5B3F9C TfRuinsTalk_SelectScriptDialog }
procedure TfRuinsTalk.SelectScriptDialog(ScriptValue: Integer);
begin
  ClearChoices;
  CurrentScript := TScript(ScriptValue);
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $5B3F9C }

{ @routine $5B3FD4 TfRuinsTalk_RunScriptAnswer }
procedure TfRuinsTalk.RunScriptAnswer(Answer: Integer);
begin
  ClearChoices;
  ScriptDialogIndex := -1;
  CurrentScript.ExecuteDialogAnswer(Answer);
  if ScriptDialogIndex < 0 then RaiseWideMessage('I_Script');
  CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $5B3FD4 }

{ @routine $5B4048 TfRuinsTalk_RunScriptAnswerKeepingScroll }
procedure TfRuinsTalk.RunScriptAnswerKeepingScroll(Answer: Integer);
begin
  RememberChoiceScroll;
  RunScriptAnswer(Answer);
end;
{ @end $5B4048 }

{ @routine $5B406C TfRuinsTalk_RunScriptTakeoff }
procedure TfRuinsTalk.RunScriptTakeoff(Answer: Integer);
begin
  CaptureSavePreview;
  CaptureGalaxyPreview(Self);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveGameToFile(SaveManagerScreen.GetAutoSavePath, 'as');
  CurrentScript.ExecuteDialogAnswer(Answer);
  if not HangarScreen.TryTakeOff then RequestedScreenId := screenHangar;
  RequestClose(1);
end;
{ @end $5B406C }

{ @routine $5B4128 TfRuinsTalk_RunScriptNewsExit }
procedure TfRuinsTalk.RunScriptNewsExit(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  StationPanel.InformationClicked(nil);
end;
{ @end $5B4128 }

{ @routine $5B4158 TfRuinsTalk_RunScriptHangar }
procedure TfRuinsTalk.RunScriptHangar(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  StationPanel.HangarClicked(nil);
end;
{ @end $5B4158 }

{ @routine $5B4188 TfRuinsTalk_OpenHangar }
procedure TfRuinsTalk.OpenHangar(Action: Integer);
begin
  StationPanel.HangarClicked(nil);
end;
{ @end $5B4188 }

{ @routine $5B41A8 TfRuinsTalk_RunScriptGoods }
procedure TfRuinsTalk.RunScriptGoods(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  StationPanel.GoodsShopClicked(nil);
end;
{ @end $5B41A8 }

{ @routine $5B41D8 TfRuinsTalk_RunScriptGameEnd }
procedure TfRuinsTalk.RunScriptGameEnd(Answer: Integer);
begin
  CurrentScript.ExecuteDialogAnswer(Answer);
  GameEndReason := gerDefault;
  RequestedScreenId := screenGameEnd;
  RequestClose(1);
end;
{ @end $5B41D8 }

{ @routine $5B4218 TfRuinsTalk_ReturnToMain }
procedure TfRuinsTalk.ReturnToMain(Action: Integer);
begin
  M_Main(False);
end;
{ @end $5B4218 }

{ @routine $5B4234 TfRuinsTalk_OpenStationModernization }
procedure TfRuinsTalk.OpenStationModernization(QuotedCost: Integer);
var
  Cost: Integer;
  Station: TRuins;
  Text: WideString;
begin
  Cost := 0;
  Station := GetPlayer.DockedTo as TRuins;
  if Cardinal(QuotedCost) > 0 then
  begin
    GetPlayer.SetMoney(Max(0, GetPlayer.Money - Trunc(Cardinal(QuotedCost))));
    SoundManager.PlaySound('Sound.Sell');
    Station.ModernizationSponsor := True;
  end
  else Cost := Station.CalculateEquippedItemCostWithoutHull;
  if Station.ModernizationSponsor then
  begin
    ShipScreen.ShipToInspect := GetPlayer.DockedTo;
    MainPanel.ShipClicked(nil);
    ShipScreen.ShipToInspect := nil;
    MainPanel.RebuildMessageButtons(False);
    MainPanel.RefreshMoneyAndCargo;
    M_Main(False);
  end
  else
  begin
    case GetPlayer.DockedTo.TypeId of
      Ord(rstPirateBase): DialogText := LocalizedColorText('FormRuins.PB.Modern.Answer');
      Ord(rstMilitaryBase): DialogText := LocalizedColorText('FormRuins.WB.Modern.Answer');
      Ord(rstDominion): DialogText := LocalizedColorText('FormRuins.CB.Modern.Answer');
    else DialogText := LocalizedColorText('FormRuins.GN.Modern.Answer');
    end;
    DialogText := FormatText1(DialogText, '<color=255,240,100>', '<Money>', IntToStr(Cost));
    ClearChoices;
    Text := '- ' + LocalizedColorText('FormRuins.GN.Modern.PlayerOk');
    if GetPlayer.Money >= Cost then AddChoice(Text, Cost, OpenStationModernization)
    else AddChoice(Text, 0, ScriptDialogBlockCallback);
    AddChoice('- ' + LocalizedColorText('FormRuins.GN.Modern.PlayerNo'), 0, DeclineStationModernization);
  end;
end;
{ @end $5B4234 }

{ @routine $5B4710 TfRuinsTalk_DeclineStationModernization }
procedure TfRuinsTalk.DeclineStationModernization(Action: Integer);
begin
  case GetPlayer.DockedTo.TypeId of
    Ord(rstPirateBase): DialogText := LocalizedColorText('FormRuins.PB.Modern.AfterNo');
    Ord(rstMilitaryBase): DialogText := LocalizedColorText('FormRuins.WB.Modern.AfterNo');
    Ord(rstDominion): DialogText := LocalizedColorText('FormRuins.CB.Modern.AfterNo');
  else DialogText := LocalizedColorText('FormRuins.GN.Modern.AfterNo');
  end;
  M_Main(True);
end;
{ @end $5B4710 }

{ @routine $5B48E4 TfRuinsTalk_DepositNodesAtRangerCenter }
procedure TfRuinsTalk.DepositNodesAtRangerCenter(Action: Integer);
var
  Count: Integer;
begin
  Count := GetPlayer.GetCarriedNodeCount;
  GetPlayer.DepositCarriedNodes;
  GetPlayer.AchievementStats.CheckNodesAchievement;
  Galaxy.RefreshRangerRatingPlaces;
  SoundManager.PlaySound('Sound.Sell');
  DialogText := LocalizedColorText('FormRuins.RC.SaleNod.RCAnswer');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Count), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<BaseNod>', IntToStr(GetPlayer.BaseNodes), '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5B48E4 }

{ @routine $5B4ACC TfRuinsTalk_ShowRangerCenterTakeNodeDialog }
procedure TfRuinsTalk.ShowRangerCenterTakeNodeDialog(Action: Integer);
var
  I: Integer;
  Text: WideString;
begin
  DialogText := LocalizedColorText('FormRuins.RC.TakeNod.RCAnswer');
  for I := 0 to 50 do
  begin
    NodeExchangeLowPriorityModule := TRuins(GetPlayer.DockedTo).SelectServiceMicroModule(2, I, False);
    if GetPlayer.NeedsMicroModule(NodeExchangeLowPriorityModule + 1) then Break;
  end;
  NodeExchangeLowPriorityCost := Round(RemapClamped(MicroModuleTemplates[NodeExchangeLowPriorityModule].Priority, 0, 100, 2000, 100));
  NodeExchangeLowPriorityCost := SeededRandomIntRange(Round(NodeExchangeLowPriorityCost * 0.8), Round(NodeExchangeLowPriorityCost * 1.2), NodeExchangeLowPriorityCost + GetPlayer.DockedTo.Id);
  NodeExchangeLowPriorityCost := RoundAndTruncateToHundreds(NodeExchangeLowPriorityCost / 1.5);
  Text := LocalizedColorText('FormRuins.RC.TakeNod.RCAnswerBig');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeLowPriorityCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeLowPriorityModule].Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<Text>', GetMicroModuleInfoText(NodeExchangeLowPriorityModule, '<color=255,240,100>'), '');
  DialogText := DialogText + #13#10 + Text;
  for I := 0 to 50 do
  begin
    NodeExchangeMediumPriorityModule := TRuins(GetPlayer.DockedTo).SelectServiceMicroModule(1, I, False);
    if GetPlayer.NeedsMicroModule(NodeExchangeMediumPriorityModule + 1) then Break;
  end;
  NodeExchangeMediumPriorityCost := Round(RemapClamped(MicroModuleTemplates[NodeExchangeMediumPriorityModule].Priority, 0, 100, 2000, 100));
  NodeExchangeMediumPriorityCost := SeededRandomIntRange(Round(NodeExchangeMediumPriorityCost * 0.8), Round(NodeExchangeMediumPriorityCost * 1.2), NodeExchangeMediumPriorityCost + GetPlayer.DockedTo.Id);
  NodeExchangeMediumPriorityCost := RoundAndTruncateToHundreds(Min(NodeExchangeLowPriorityCost div 2, NodeExchangeMediumPriorityCost / 1.5));
  Text := LocalizedColorText('FormRuins.RC.TakeNod.RCAnswerAverage');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeMediumPriorityCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeMediumPriorityModule].Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<Text>', GetMicroModuleInfoText(NodeExchangeMediumPriorityModule, '<color=255,240,100>'), '');
  DialogText := DialogText + #13#10 + Text;
  for I := 0 to 50 do
  begin
    NodeExchangeHighPriorityModule := TRuins(GetPlayer.DockedTo).SelectServiceMicroModule(0, I, False);
    if GetPlayer.NeedsMicroModule(NodeExchangeHighPriorityModule + 1) then Break;
  end;
  NodeExchangeHighPriorityCost := Round(RemapClamped(MicroModuleTemplates[NodeExchangeHighPriorityModule].Priority, 0, 100, 2000, 100));
  NodeExchangeHighPriorityCost := SeededRandomIntRange(Round(NodeExchangeHighPriorityCost * 0.8), Round(NodeExchangeHighPriorityCost * 1.2), NodeExchangeHighPriorityCost + GetPlayer.DockedTo.Id);
  NodeExchangeHighPriorityCost := RoundAndTruncateToTens(Min(NodeExchangeMediumPriorityCost div 2, NodeExchangeHighPriorityCost / 1.5));
  Text := LocalizedColorText('FormRuins.RC.TakeNod.RCAnswerSmall');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeHighPriorityCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeHighPriorityModule].Name, '<color=255,240,100>');
  ReplaceTextToken(Text, '<Text>', GetMicroModuleInfoText(NodeExchangeHighPriorityModule, '<color=255,240,100>'), '');
  DialogText := DialogText + #13#10 + Text;
  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.TakeNod.RCAnswerEnd');
  ReplaceTextToken(DialogText, '<BaseNod>', IntToStr(GetPlayer.BaseNodes), '<color=255,240,100>');
  ClearChoices;
  Text := '- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerOk');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeLowPriorityCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeLowPriorityModule].Name, '<color=255,240,100>');
  if GetPlayer.BaseNodes >= NodeExchangeLowPriorityCost then AddChoice(Text, 3, BuyRangerCenterMicroModule)
  else AddChoice(Text, 0, ScriptDialogBlockCallback);
  Text := '- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerOk');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeMediumPriorityCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeMediumPriorityModule].Name, '<color=255,240,100>');
  if GetPlayer.BaseNodes >= NodeExchangeMediumPriorityCost then AddChoice(Text, 2, BuyRangerCenterMicroModule)
  else AddChoice(Text, 0, ScriptDialogBlockCallback);
  Text := '- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerOk');
  ReplaceTextToken(Text, '<Count>', IntToStr(NodeExchangeHighPriorityCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Name>', MicroModuleTemplates[NodeExchangeHighPriorityModule].Name, '<color=255,240,100>');
  if GetPlayer.BaseNodes >= NodeExchangeHighPriorityCost then AddChoice(Text, 1, BuyRangerCenterMicroModule)
  else AddChoice(Text, 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.RC.TakeNod.PlayerNo'), 0, DeclineRangerCenterNodeDeposit);
end;
{ @end $5B4ACC }

{ @routine $5B5734 TfRuinsTalk_BuyRangerCenterMicroModule }
procedure TfRuinsTalk.BuyRangerCenterMicroModule(Action: Integer);
var
  Cost, ModuleIndex: Integer;
  Item: TMicroModule;
  BaseNodes: Integer;
  Event: TGalaxyEvent;
begin
  case Action of
    1: begin ModuleIndex := NodeExchangeHighPriorityModule; Cost := NodeExchangeHighPriorityCost; end;
    2: begin ModuleIndex := NodeExchangeMediumPriorityModule; Cost := NodeExchangeMediumPriorityCost; end;
    3: begin ModuleIndex := NodeExchangeLowPriorityModule; Cost := NodeExchangeLowPriorityCost; end;
  else
    begin
      RaiseWideMessage('Косяки.TfRuinsTalk.I_TakeNodPlayerOk');
      Exit;
    end;
  end;
  BaseNodes := GetPlayer.BaseNodes;
  Dec(GetPlayer.BaseNodes, Cost);
  if (GetPlayer.BaseNodes <> BaseNodes - Cost) and not GR_Main.CCInterface.GetTamperDetected then
    GR_Main.CCInterface.SetTamperDetected(True);
  BaseNodes := GetPlayer.BaseNodes;
  Item := TMicroModule.Create;
  Item.Init(ModuleIndex);
  GetPlayer.Inventory.Add(Item);
  DialogText := LocalizedColorText('FormRuins.RC.TakeNod.RCAfterPlayerOk');
  ReplaceTextToken(DialogText, '<NodCnt>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Name>', MicroModuleTemplates[ModuleIndex].Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<RC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  SoundManager.PlaySound('Sound.Sell');
  Event := AddGalaxyEvent('PlayerReceivesMM');
  Event.AddData(Item.Id);
  Event.AddData(ModuleIndex);
  Event.AddData(Cost);
  SysUtils.Sleep(1);
  if (GetPlayer.BaseNodes <> BaseNodes) and not GR_Main.CCInterface.GetTamperDetected then
    GR_Main.CCInterface.SetTamperDetected(True);
  M_Main(True);
end;
{ @end $5B5734 }

{ @routine $5B5ACC TfRuinsTalk_DeclineRangerCenterNodeDeposit }
procedure TfRuinsTalk.DeclineRangerCenterNodeDeposit(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.TakeNod.RCAfterPlayerNo');
  M_Main(True);
end;
{ @end $5B5ACC }

{ @routine $5B5B84 TfRuinsTalk_ShowRangerCenterGiveNodeDialog }
procedure TfRuinsTalk.ShowRangerCenterGiveNodeDialog(Action: Integer);
var
  I, Count: Integer;
  Item: TItem;
  Module: TMicroModule;
  Attempts: Integer;
begin
  DialogText := LocalizedColorText('FormRuins.RC.GiveNod.Answer');
  DialogText := DialogText + #13#10 + '----------------------------';
  Attempts := 1;
  repeat
    Inc(Attempts);
    if (Cardinal(Galaxy.CurrentTurn) + GetPlayer.RandomState) mod 33 = 0 then
      NodeExchangeLowPriorityModule := Galaxy.SelectMicroModule(0, 20, 17 * Attempts + (Galaxy.CurrentTurn div 57 + 2938629) + GetPlayer.DockedTo.Id, GetPlayer.DockedTo)
    else NodeExchangeLowPriorityModule := Galaxy.SelectMicroModule(10, 30, 17 * Attempts + (Galaxy.CurrentTurn div 57 + 32465621) + GetPlayer.DockedTo.Id, GetPlayer.DockedTo);
    if Attempts > 50 then Break;
  until GetPlayer.NeedsMicroModule(NodeExchangeLowPriorityModule + 1);
  NodeExchangeLowPriorityCost := Round(RemapClamped(MicroModuleTemplates[NodeExchangeLowPriorityModule].Priority, 0, 100, 2000, 100));
  NodeExchangeLowPriorityCost := SeededRandomIntRange(Round(NodeExchangeLowPriorityCost * 0.8), Round(NodeExchangeLowPriorityCost * 1.2), NodeExchangeLowPriorityCost + GetPlayer.DockedTo.Id);
  NodeExchangeLowPriorityCost := RoundAndTruncateToHundreds(NodeExchangeLowPriorityCost / 1.5);
  Attempts := 1;
  repeat
    Inc(Attempts);
    NodeExchangeMediumPriorityModule := Galaxy.SelectMicroModule(31, 69, 17 * Attempts + (Galaxy.CurrentTurn div 57 + 2351417) + GetPlayer.DockedTo.Id, GetPlayer.DockedTo);
    if Attempts > 50 then Break;
  until GetPlayer.NeedsMicroModule(NodeExchangeMediumPriorityModule + 1);
  NodeExchangeMediumPriorityCost := Round(RemapClamped(MicroModuleTemplates[NodeExchangeMediumPriorityModule].Priority, 0, 100, 2000, 100));
  NodeExchangeMediumPriorityCost := SeededRandomIntRange(Round(NodeExchangeMediumPriorityCost * 0.8), Round(NodeExchangeMediumPriorityCost * 1.2), NodeExchangeMediumPriorityCost + GetPlayer.DockedTo.Id);
  NodeExchangeMediumPriorityCost := RoundAndTruncateToHundreds(Min(NodeExchangeLowPriorityCost div 2, NodeExchangeMediumPriorityCost / 1.5));
  Attempts := 1;
  repeat
    NodeExchangeHighPriorityModule := Galaxy.SelectMicroModule(70, 100, 17 * Attempts + Galaxy.CurrentTurn div 57 + GetPlayer.DockedTo.Id, GetPlayer.DockedTo);
    Inc(Attempts);
    if Attempts > 50 then Break;
  until GetPlayer.NeedsMicroModule(NodeExchangeHighPriorityModule + 1);
  NodeExchangeHighPriorityCost := Round(RemapClamped(MicroModuleTemplates[NodeExchangeHighPriorityModule].Priority, 0, 100, 2000, 100));
  NodeExchangeHighPriorityCost := SeededRandomIntRange(Round(NodeExchangeHighPriorityCost * 0.8), Round(NodeExchangeHighPriorityCost * 1.2), NodeExchangeHighPriorityCost + GetPlayer.DockedTo.Id);
  NodeExchangeHighPriorityCost := RoundAndTruncateToTens(Min(NodeExchangeMediumPriorityCost div 2, NodeExchangeHighPriorityCost / 1.5));
  Count := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := TItem(GetPlayer.Inventory[I]);
    if Item.ItemType = t_MicroModule then
    begin
      Module := Item as TMicroModule;
      DialogText := DialogText + #13#10 + FormatText2(LocalizedColorText('FormRuins.RC.GiveNod.Nod'), '<color=255,240,100>', '<Name>', Module.GetHighlightedName, '<Count>', IntToStr(Module.CalculateNodeExchangeValue(NodeExchangeLowPriorityCost, NodeExchangeMediumPriorityCost)));
      Inc(Count);
    end;
  end;
  if Count > 0 then
  begin
    DialogText := DialogText + #13#10 + '----------------------------';
    DialogText := DialogText + #13#10 + FormatText1(LocalizedColorText('FormRuins.RC.GiveNod.Sum'), '<color=255,240,100>', '<BaseNod>', IntToStr(GetPlayer.BaseNodes));
  end
  else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.RC.GiveNod.Nothing');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.RC.GiveNod.PlayerNo'), 0, DeclineRangerCenterNodeReward);
  if Count > 0 then
    for I := 0 to GetPlayer.Inventory.Count - 1 do
    begin
      Item := TItem(GetPlayer.Inventory[I]);
      if Item.ItemType = t_MicroModule then
      begin
        Module := Item as TMicroModule;
        AddChoice(FormatText2('- ' + LocalizedColorText('FormRuins.RC.GiveNod.PlayerOk'), '<color=255,240,100>', '<Name>', Module.GetHighlightedName, '<Count>', IntToStr(Module.CalculateNodeExchangeValue(NodeExchangeLowPriorityCost, NodeExchangeMediumPriorityCost))), Module.Id, ExchangeMicroModuleForNodes);
      end;
    end;
end;
{ @end $5B5B84 }

{ @routine $5B66B4 TfRuinsTalk_ExchangeMicroModuleForNodes }
procedure TfRuinsTalk.ExchangeMicroModuleForNodes(Action: Integer);
var
  I, Value: Integer;
  Item: TItem;
  Module: TMicroModule;
begin
  Module := nil;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := TItem(GetPlayer.Inventory[I]);
    if Item.ItemType = t_MicroModule then
    begin
      Module := Item as TMicroModule;
      if Module.Id = Action then Break;
      Module := nil;
    end;
  end;
  if Module = nil then RaiseWideMessage('Косяк: TfRuinsTalk.I_GiveNodOk [FId = ' + IntToStr(Cardinal(Action)) + ']');
  Value := Module.CalculateNodeExchangeValue(NodeExchangeLowPriorityCost, NodeExchangeMediumPriorityCost);
  DialogText := FormatText2(LocalizedColorText('FormRuins.RC.GiveNod.AfterOk'), '<color=255,240,100>', '<Name>', Module.GetHighlightedName, '<Count>', IntToStr(Value));
  GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(Module));
  Module.Free;
  Inc(GetPlayer.BaseNodes, Value);
  GetPlayer.AchievementStats.CheckNodesAchievement;
  GetPlayer.RefreshDerivedStats(True);
  SoundManager.PlaySound('Sound.Sell');
  ShowRangerCenterGiveNodeDialog(Action);
end;
{ @end $5B66B4 }

{ @routine $5B69A8 TfRuinsTalk_DeclineRangerCenterNodeReward }
procedure TfRuinsTalk.DeclineRangerCenterNodeReward(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.GiveNod.AfterNo');
  M_Main(True);
end;
{ @end $5B69A8 }

{ @routine $5B6A50 TfRuinsTalk_ShowRangerCenterNodeInfo }
procedure TfRuinsTalk.ShowRangerCenterNodeInfo(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.AboutNod.RCAnswer');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(30), '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.I_Continue'), 0, ShowRangerCenterNodeInfoContinuation);
end;
{ @end $5B6A50 }

{ @routine $5B6BFC TfRuinsTalk_ShowRangerCenterNodeInfoContinuation }
procedure TfRuinsTalk.ShowRangerCenterNodeInfoContinuation(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.AboutNod.RCAnswerAdd');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(30), '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5B6BFC }

{ @routine $5B6D30 TfRuinsTalk_ShowRangerCenterRatingAnswer }
procedure TfRuinsTalk.ShowRangerCenterRatingAnswer(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.Rating.RCAnswer');
  M_Main(True);
end;
{ @end $5B6D30 }

{ @routine $5B6DD8 TfRuinsTalk_ShowRangerCenterPirateClanAnswer }
procedure TfRuinsTalk.ShowRangerCenterPirateClanAnswer(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.PirateClan.RCAnswer');
  M_Main(True);
end;
{ @end $5B6DD8 }

{ @routine $5B6E88 TfRuinsTalk_ShowRangerCenterBestRangerAnswer }
procedure TfRuinsTalk.ShowRangerCenterBestRangerAnswer(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.RC.BestRanger.RCAnswer');
  M_Main(True);
end;
{ @end $5B6E88 }

{ @routine $5B6F38 TfRuinsTalk_ShowPirateBaseNationalityDialog }
procedure TfRuinsTalk.ShowPirateBaseNationalityDialog(Action: Integer);
var
  Text: WideString;
  I: Integer;
  Factor: Double;
  D, E, DE, C, CDE, B, BCDE, A, MinimumCost: Integer;
begin
  DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AnswerChangeNationality');
  Text := LocalizedColorText('FormRuins.PB.ChangeNationality.PBNext');
  Factor := 1;
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + 365 < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesNationality' then Factor := Factor * 1.5;
  end;
  ReplaceTextToken(Text, '<MoneyMaloc>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(0) * Factor)), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyPeleng>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(1) * Factor)), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyPeople>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(2) * Factor)), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyFei>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(3) * Factor)), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyGaal>', IntToStr(Round(Galaxy.ComputeScaledBigMoney(4) * Factor)), '<color=255,240,100>');
  DialogText := DialogText + Text;
  ClearChoices;
  A := Galaxy.ComputeScaledBigMoney(0);
  B := Galaxy.ComputeScaledBigMoney(1);
  C := Galaxy.ComputeScaledBigMoney(2);
  D := Galaxy.ComputeScaledBigMoney(3);
  E := Galaxy.ComputeScaledBigMoney(4);
  if D < E then DE := D else DE := E;
  if C < DE then CDE := C else CDE := DE;
  if B < CDE then BCDE := B else BCDE := CDE;
  if A < BCDE then MinimumCost := A else MinimumCost := BCDE;
  if GetPlayer.Money >= Round(MinimumCost * Factor) then
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeNationality.PlayerOk'), 0, AcceptPirateBaseNationality)
  else
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeNationality.PlayerOk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeNationality.PlayerNo'), 0, DeclinePirateBaseNationality);
end;
{ @end $5B6F38 }

{ @routine $5B7604 TfRuinsTalk_AcceptPirateBaseNationality }
procedure TfRuinsTalk.AcceptPirateBaseNationality(Action: Integer);
const
  RelationShipTypes = [htRanger, htPirate..htDiplomat];
var
  RangerIndex, J: Integer;
  Relation: Byte;
  I: Integer;
  Event: TGalaxyEvent;
  Factor: Double;
begin
  Factor := 1;
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + 365 < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesNationality' then Factor := Factor * 1.5;
  end;
  SelectFaceScreen.PlayerRace := GetPlayer.PilotRace;
  SelectFaceScreen.CaptainPortraitIndex := GetPlayer.PortraitFaceId;
  SelectFaceScreen.PlayerName := GetPlayer.Name;
  SelectFaceScreen.NationalityCosts[0] := Round(Galaxy.ComputeScaledBigMoney(0) * Factor);
  SelectFaceScreen.NationalityCosts[1] := Round(Galaxy.ComputeScaledBigMoney(1) * Factor);
  SelectFaceScreen.NationalityCosts[2] := Round(Galaxy.ComputeScaledBigMoney(2) * Factor);
  SelectFaceScreen.NationalityCosts[3] := Round(Galaxy.ComputeScaledBigMoney(3) * Factor);
  SelectFaceScreen.NationalityCosts[4] := Round(Galaxy.ComputeScaledBigMoney(4) * Factor);
  SelectFaceScreen.AvailableMoney := GetPlayer.Money;
  Galaxy.PrimeIntegrityChecksum(320);
  if RunSelectFaceDialog(Self) then
  begin
    Galaxy.CheckIntegrityChecksum(321);
    GetPlayer.PortraitFaceId := SelectFaceScreen.CaptainPortraitIndex;
    GetPlayer.PilotRace := SelectFaceScreen.PlayerRace;
    if GetPlayer.OwnerId <> Byte(oiPirate) then GetPlayer.OwnerId := RaceToOwner(SelectFaceScreen.PlayerRace);
    GetPlayer.Name := SelectFaceScreen.PlayerName;
    LastLoadedPlayerName := GetPlayer.Name;
    GetPlayer.SetMoney(Max(0, GetPlayer.Money - Max(0, SelectFaceScreen.AcceptedCost)));
    GetPlayer.AddPirateCareerActivity(8);
    Inc(GetPlayer.NationalityChangeCount);
    TryAddAchievementProgress('MANYFACES', 1);
    for J := 1 to 12 do
      if not CaptainHealthDefinitions[J].Disabled then
        if not (RaceToOwner(GetPlayer.PilotRace) in CaptainHealthDefinitions[J].AllowedOwners) and (GetPlayer.CaptainHealth[J].Progress < 100) then
        begin
          GetPlayer.CaptainHealth[J].Progress := 0;
          GetPlayer.StatusEffectSourceNames[J] := '';
        end;
    GetPlayer.ChangePlanetRelations(nil, rcmRaiseTo, 70, PlanetOwnerMasks.Coalition);
    GetPlayer.ChangeShipRelations(nil, rcmRaiseTo, 70, RelationShipTypes, PlanetOwnerMasks.Coalition);
    if MainPiratePlanet <> nil then
    begin
      RangerIndex := Galaxy.Rangers.IndexOf(GetPlayer);
      Relation := Byte(MainPiratePlanet.RangerRelations[RangerIndex]);
      if Relation < 45 then MainPiratePlanet.RangerRelations[RangerIndex] := Pointer(45);
    end;
    GetPlayer.ChangeShipRelations(nil, rcmRaiseTo, 45, RelationShipTypes, PlanetOwnerMasks.PirateClan);
    SoundManager.PlaySound('Sound.Sell');
    Event := AddGalaxyEvent('PlayerChangesNationality');
    Event.AddData(GetPlayer.PilotRace);
    case SelectFaceScreen.PlayerRace of
      0: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationMaloc');
      1: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationPeleng');
      2: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationPeople');
      3: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationFei');
      4: DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.AfterOperationGaal');
    end;
  end
  else
  begin
    Galaxy.CheckIntegrityChecksum(322);
    if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.PBAfterNo')
    else DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.PBAfterNoAlt');
  end;
  ClearChoices;
  M_Main(True);
end;
{ @end $5B7604 }

{ @routine $5B7F60 TfRuinsTalk_DeclinePirateBaseNationality }
procedure TfRuinsTalk.DeclinePirateBaseNationality(Action: Integer);
begin
  if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.PBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.PB.ChangeNationality.PBAfterNoAlt');
  ClearChoices;
  M_Main(True);
end;
{ @end $5B7F60 }

{ @routine $5B80BC TfRuinsTalk_ShowPirateBaseSideChangeDialog }
procedure TfRuinsTalk.ShowPirateBaseSideChangeDialog(Action: Integer);
var
  I: Integer;
begin
  if GetPlayer.OwnerId = Byte(oiPirate) then DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerChangeSideToNormal')
  else DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerChangeSideToPirate');
  StationServiceQuoteCost := Galaxy.ComputeScaledHugeMoney(2);
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + 365 < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesSide' then
      StationServiceQuoteCost := Min(Int64(100000000), Round(StationServiceQuoteCost * 1.5));
  end;
  ReplaceTextToken(DialogText, '<Cost>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.Money >= StationServiceQuoteCost then
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.PlayerOk'), 0, AcceptPirateBaseSideChange)
  else
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.PlayerOk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.ChangeSide.PlayerNo'), 0, DeclinePirateBaseSideChange);
end;
{ @end $5B80BC }

{ @routine $5B84FC TfRuinsTalk_AcceptPirateBaseSideChange }
procedure TfRuinsTalk.AcceptPirateBaseSideChange(Action: Integer);
const
  RelationShipTypes = [htRanger, htPirate..htDiplomat];
var
  Event: TGalaxyEvent;
  I, RangerIndex: Integer;
  Relation: Byte;
begin
  if GetPlayer.OwnerId = Byte(oiPirate) then GetPlayer.OwnerId := RaceToOwner(GetPlayer.PilotRace)
  else GetPlayer.OwnerId := Byte(oiPirate);
  StationServiceQuoteCost := Galaxy.ComputeScaledHugeMoney(2);
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + 365 < Galaxy.CurrentTurn then Break;
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType = 'PlayerChangesSide' then
      StationServiceQuoteCost := Min(Int64(100000000), Round(StationServiceQuoteCost * 1.5));
  end;
  GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
  SoundManager.PlaySound('Sound.Sell');
  Inc(GetPlayer.SideChangeCount);
  TrySetAchievementProgress('SIDECHANGER', GetPlayer.SideChangeCount);
  RangerIndex := Galaxy.Rangers.IndexOf(GetPlayer);
  if MainPiratePlanet <> nil then Relation := Byte(MainPiratePlanet.RangerRelations[RangerIndex])
  else Relation := 0;
  if GetPlayer.OwnerId = Byte(oiPirate) then
  begin
    if (Relation < 45) and (MainPiratePlanet <> nil) then MainPiratePlanet.RangerRelations[RangerIndex] := Pointer(45);
    GetPlayer.ChangeShipRelations(nil, rcmRaiseTo, 45, RelationShipTypes, PlanetOwnerMasks.PirateClan);
    GetPlayer.ChangePlanetRelations(nil, rcmCapAt, 20, PlanetOwnerMasks.Coalition);
    GetPlayer.ChangeShipRelations(nil, rcmCapAt, 20, RelationShipTypes, PlanetOwnerMasks.Coalition);
    DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerOkPirate');
  end
  else
  begin
    GetPlayer.ChangePlanetRelations(nil, rcmRaiseTo, 45, PlanetOwnerMasks.Coalition);
    GetPlayer.ChangeShipRelations(nil, rcmRaiseTo, 45, RelationShipTypes, PlanetOwnerMasks.Coalition);
    if (Relation > 20) and (MainPiratePlanet <> nil) then MainPiratePlanet.RangerRelations[RangerIndex] := Pointer(20);
    GetPlayer.ChangeShipRelations(nil, rcmCapAt, 20, RelationShipTypes, PlanetOwnerMasks.PirateClan);
    DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerOkNormal');
  end;
  Event := AddGalaxyEvent('PlayerChangesSide');
  Event.AddData(Ord(GetPlayer.OwnerId = Byte(oiPirate)));
  ClearChoices;
  M_Main(True);
end;
{ @end $5B84FC }

{ @routine $5B8990 TfRuinsTalk_DeclinePirateBaseSideChange }
procedure TfRuinsTalk.DeclinePirateBaseSideChange(Action: Integer);
begin
  if GetPlayer.OwnerId = Byte(oiPirate) then DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerNoNormal')
  else DialogText := LocalizedColorText('FormRuins.PB.ChangeSide.AnswerPlayerNoPirate');
  ClearChoices;
  M_Main(True);
end;
{ @end $5B8990 }

{ @routine $5B8AF4 TfRuinsTalk_ShowPirateBaseNodeDialog }
procedure TfRuinsTalk.ShowPirateBaseNodeDialog(Action: Integer);
var
  Count, Cost, DiscountedCost: Integer;
  Text: WideString;
  OtherBase: TRuins;
  Discount: Byte;
begin
  if GetPlayer.DockedTo.NodeReserve > 0 then
  begin
    Count := (GetPlayer.DockedTo as TRuins).GetNodeSaleBatchSize;
    Cost := Galaxy.ScaleGoodsPriceByGalaxyAge(Count * 10 * 3);
  Discount := GetPlayer.GetPirateServiceDiscount;
  DiscountedCost := Max(Int64(1), Cost - Round(Cost / 100 * Discount));
    Text := LocalizedColorText('FormRuins.PB.Nod.PBStart');
  ReplaceTextToken(Text, '<Count>', IntToStr(Count), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyAll>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Percent>', IntToStr(Discount), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyDec>', IntToStr(DiscountedCost), '<color=255,240,100>');
    DialogText := Text;
    ClearChoices;
    if GetPlayer.Money >= DiscountedCost then
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.Nod.PlayerOk'), 0, BuyPirateBaseNodes);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.Nod.PlayerNo'), 0, DeclinePirateBaseNodes);
  end
  else
  begin
    Text := LocalizedColorText('FormRuins.PB.Nod.PBEnd');
    OtherBase := (GetPlayer.DockedTo as TRuins).FindPirateBaseWithNodes;
    if OtherBase <> nil then
    begin
      Text := Text + #13#10 + LocalizedColorText('FormRuins.PB.Nod.PBEndPlus');
      ReplaceTextToken(Text, '<ToSector>', OtherBase.CurrentStar.Constellation.GetName, '<color=255,240,100>');
      ReplaceTextToken(Text, '<ToBase>', OtherBase.Name, '<color=255,240,100>');
    end;
    DialogText := Text;
    ClearChoices;
    M_Main(True);
  end;
end;
{ @end $5B8AF4 }

{ @routine $5B903C TfRuinsTalk_BuyPirateBaseNodes }
procedure TfRuinsTalk.BuyPirateBaseNodes(Action: Integer);
var
  Count, Cost, DiscountedCost: Integer;
  Stack: TProtoplasm;
  Item: TItem;
  I: Integer;
  NewStack: Boolean;
  Discount: Byte;
begin
  Count := (GetPlayer.DockedTo as TRuins).GetNodeSaleBatchSize;
  Cost := Galaxy.ScaleGoodsPriceByGalaxyAge(Count * 10 * 3);
  Discount := GetPlayer.GetPirateServiceDiscount;
  DiscountedCost := Max(Int64(1), Cost - Round(Cost / 100 * Discount));
  GetPlayer.SetMoney(GetPlayer.Money - DiscountedCost);
  Dec(GetPlayer.DockedTo.NodeReserve, Count);
  GetPlayer.AddPirateCareerActivity(4);
  NewStack := True;
  for I := 1 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item is TProtoplasm then
    begin
      Stack := Item as TProtoplasm;
      Stack.Init(Stack.StackCount + Count, 1);
      NewStack := False;
      Break;
    end;
  end;
  if NewStack then
  begin
    Stack := TProtoplasm.Create;
    Stack.Init(Count, 1);
    GetPlayer.Inventory.Add(Stack);
  end;
  DialogText := LocalizedColorText('FormRuins.PB.Nod.PBSell');
  SoundManager.PlaySound('Sound.Sell');
  ClearChoices;
  M_Main(True);
end;
{ @end $5B903C }

{ @routine $5B929C TfRuinsTalk_DeclinePirateBaseNodes }
procedure TfRuinsTalk.DeclinePirateBaseNodes(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.PB.Nod.PBAfterNo');
  ClearChoices;
  M_Main(True);
end;
{ @end $5B929C }

{ @routine $5B9348 TfRuinsTalk_ShowPirateBaseProgramDialog }
procedure TfRuinsTalk.ShowPirateBaseProgramDialog(Action: Integer);
var
  I: Byte;
  Text: WideString;
  Discount, Nodes: Integer;
begin
  Text := '';
  for I := Low(PirateProgramQuoteCosts) to High(PirateProgramQuoteCosts) do PirateProgramQuoteCosts[I] := 0;
  Discount := GetPlayer.GetPirateServiceDiscount;
  Text := LocalizedColorText('FormRuins.PB.Program.PBStart');
  Text := FormatText1(Text, '<color=255,240,100>', '<Percent>', WrapTextInColor(IntToStr(Discount), '<color=255,240,100>'));
  Text := FormatText1(Text, '<color=255,240,100>', '<NodTrum>', WrapTextInColor(IntToStr(GetPlayer.GetAvailableNodeCount(nil)), '<color=255,240,100>'));
  Text := FormatText1(Text, '<color=255,240,100>', '<NodAcc>', WrapTextInColor(IntToStr(GetPlayer.BaseNodes), '<color=255,240,100>'));
  Text := Text + #13#10;
  for I := Low(PirateProgramBatchSizes) to High(PirateProgramBatchSizes) do
    if PirateProgramBatchSizes[I] <> 0 then
    begin
      Text := Text + WrapTextInColor(GetPlayer.GetProgramName(I), '<color=255,240,100>') + ' - ';
      Text := Text + FormatText1(LocalizedText('Programms.' + ProgramNames[I] + '.Text'), '<color=255,240,100>', '<Count>', IntToStr(PirateProgramBatchSizes[I])) + #13#10;
      PirateProgramQuoteCosts[I] := Max(Int64(100), PirateProgramBaseCosts[I] - Round(PirateProgramBaseCosts[I] / 100 * Discount));
      Text := Text + FormatText1(LocalizedText('FormRuins.PB.Program.NodCost'), '<color=255,240,100>', '<Cost>', IntToStr(PirateProgramQuoteCosts[I]));
      Text := Text + #13#10 + #13#10;
    end;
  DialogText := Text;
  ClearChoices;
  Nodes := GetPlayer.GetAvailableNodeCount(nil) + GetPlayer.BaseNodes;
  for I := Low(PirateProgramBatchSizes) to High(PirateProgramBatchSizes) do
    if PirateProgramBatchSizes[I] <> 0 then
    begin
      Text := ' - ' + LocalizedColorText('FormRuins.PB.Program.PlayerOk');
      Text := FormatText1(Text, '<color=255,240,100>', '<Nod>', WrapTextInColor(IntToStr(PirateProgramQuoteCosts[I]), '<color=255,240,100>'));
      Text := FormatText1(Text, '<color=255,240,100>', '<Text>', WrapTextInColor(GetPlayer.GetProgramName(I), '<color=255,240,100>'));
      if PirateProgramQuoteCosts[I] <= Nodes then AddChoice(Text, I, BuyPirateBaseProgram)
      else AddChoice(Text, 0, ScriptDialogBlockCallback);
    end;
  AddChoice(LocalizedColorText('FormRuins.PB.Program.PlayerNo'), 0, DeclinePirateBaseProgram);
end;
{ @end $5B9348 }

{ @routine $5B9AF0 TfRuinsTalk_BuyPirateBaseProgram }
procedure TfRuinsTalk.BuyPirateBaseProgram(Action: Integer);
var
  ProgramIndex: Byte;
  Cost, CarriedNodes, BaseNodes: Integer;
begin
  ProgramIndex := Action;
  Cost := PirateProgramQuoteCosts[ProgramIndex];
  CarriedNodes := GetPlayer.GetAvailableNodeCount(nil);
  BaseNodes := GetPlayer.BaseNodes;
  if CarriedNodes + BaseNodes >= Cost then
  begin
    if CarriedNodes > 0 then GetPlayer.ConsumeAvailableNodes(Cost, nil);
    if Cost > CarriedNodes then GetPlayer.BaseNodes := Max(0, GetPlayer.BaseNodes - (Cost - CarriedNodes));
    Inc(GetPlayer.ProgramCounts[ProgramIndex], PirateProgramBatchSizes[ProgramIndex]);
    SoundManager.PlaySound('Sound.Sell');
    GetPlayer.AddPirateCareerActivity(3);
    DialogText := FormatText1(LocalizedColorText('FormRuins.PB.Program.PBAfterOk'), '<color=255,240,100>', '<Text>', GetPlayer.GetProgramName(ProgramIndex));
    ClearChoices;
    M_Main(True);
  end
  else DeclinePirateBaseProgram(0);
end;
{ @end $5B9AF0 }

{ @routine $5B9D14 TfRuinsTalk_DeclinePirateBaseProgram }
procedure TfRuinsTalk.DeclinePirateBaseProgram(Action: Integer);
begin
  if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.Program.PBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.PB.Program.PBAfterNoAlt');
  ClearChoices;
  M_Main(True);
end;
{ @end $5B9D14 }

{ @routine $5B9E48 TfRuinsTalk_ShowPirateBaseRepairDialog }
procedure TfRuinsTalk.ShowPirateBaseRepairDialog(Action: Integer);
var
  Cost, DiscountedCost: Integer;
  Text: WideString;
  Discount: Byte;
  I, NodeCost: Integer;
  Item: TEquipment;
begin
  NodeCost := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag <> 0 then
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) and Item.NeedsRepair then
        if (GetPlayer.DockedTo as TRuins).CanRepairEquipmentTech(Item) then Inc(NodeCost, Item.CalculateRepairCost);
  end;
  if NodeCost > 0 then
  begin
    NodeCost := Round(NodeCost * 0.0025);
    if NodeCost = 0 then NodeCost := 1;
  end;
  Cost := (GetPlayer.DockedTo as TRuins).GetRepairCost(GetPlayer);
  Discount := GetPlayer.GetPirateServiceDiscount;
  DiscountedCost := Max(Int64(1), Cost - Round(Cost / 100 * Discount));
  if Cost = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.PB.Repair.PBYouNotNeedRepair');
    ClearChoices;
    M_Main(True);
  end
  else
  begin
    Text := LocalizedColorText('FormRuins.PB.Repair.PBYouNeedRepair');
  ReplaceTextToken(Text, '<MoneyAll>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Percent>', IntToStr(Discount), '<color=255,240,100>');
  ReplaceTextToken(Text, '<MoneyDec>', IntToStr(DiscountedCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
    DialogText := Text;
    if NodeCost <> 0 then
    begin
      DialogText := DialogText + LocalizedColorText('FormRuins.PB.Repair.PBCostAnswerNeedNode');
      ReplaceTextToken(DialogText, '<NeedNode>', IntToStr(NodeCost), '<color=255,240,100>');
    end;
    ClearChoices;
    if GetPlayer.Money >= DiscountedCost then
      if (NodeCost = 0) or ((NodeCost > 0) and (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost)) then
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.Repair.PlayerOk'), 0, AcceptPirateBaseRepair);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.Repair.PlayerNo'), 0, DeclinePirateBaseRepair);
  end;
end;
{ @end $5B9E48 }

{ @routine $5BA464 TfRuinsTalk_AcceptPirateBaseRepair }
procedure TfRuinsTalk.AcceptPirateBaseRepair(Action: Integer);
var
  Cost, DiscountedCost: Integer;
  Discount: Byte;
  I, NodeCost: Integer;
  Item: TEquipment;
begin
  NodeCost := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag <> 0 then
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) and Item.NeedsRepair then
        if (GetPlayer.DockedTo as TRuins).CanRepairEquipmentTech(Item) then Inc(NodeCost, Item.CalculateRepairCost);
  end;
  if NodeCost > 0 then
  begin
    NodeCost := Round(NodeCost * 0.0025);
    if NodeCost = 0 then NodeCost := 1;
  end;
  Cost := (GetPlayer.DockedTo as TRuins).GetRepairCost(GetPlayer);
  Discount := GetPlayer.GetPirateServiceDiscount;
  DiscountedCost := Max(Int64(1), Cost - Round(Cost / 100 * Discount));
  if (GetPlayer.Money >= DiscountedCost) and (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost) then
  begin
    GetPlayer.ConsumeAvailableNodes(NodeCost, nil);
    GetPlayer.SetMoney(GetPlayer.Money + (Cost - DiscountedCost));
    (GetPlayer.DockedTo as TRuins).RepairShipEquipment(GetPlayer);
    GetPlayer.RefreshDerivedStats(True);
    GetPlayer.AddPirateCareerActivity(4);
    DialogText := LocalizedColorText('FormRuins.PB.Repair.PBAfterOk');
    SoundManager.PlaySound('Sound.Repair');
    ClearChoices;
    M_Main(True);
  end
  else DeclinePirateBaseRepair(0);
end;
{ @end $5BA464 }

{ @routine $5BA750 TfRuinsTalk_DeclinePirateBaseRepair }
procedure TfRuinsTalk.DeclinePirateBaseRepair(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.PB.Repair.PBAfterNo');
  ClearChoices;
  M_Main(True);
end;
{ @end $5BA750 }

{ @routine $5BA800 TfRuinsTalk_ShowPirateBaseSubCrackDialog }
procedure TfRuinsTalk.ShowPirateBaseSubCrackDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBInfo');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerContinue'), 0, ConfirmPirateBaseSubCrack);
end;
{ @end $5BA800 }

{ @routine $5BA9F8 TfRuinsTalk_ConfirmPirateBaseSubCrack }
procedure TfRuinsTalk.ConfirmPirateBaseSubCrack(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBContinue');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.PB.SabCrack.PlayerOk'), '<color=255,240,100>', '<Money>', IntToStr(GetPlayer.GetSubCrackCost)), 0, BuyPirateBaseSubCrack);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerOkHalf'), 0, BuyPirateBaseSubCrackHalfPrice);
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.SabCrack.PlayerNo'), 0, DeclinePirateBaseSubCrack);
end;
{ @end $5BA9F8 }

{ @routine $5BAD34 TfRuinsTalk_BuyPirateBaseSubCrack }
procedure TfRuinsTalk.BuyPirateBaseSubCrack(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBAfterOk');
  GetPlayer.SetMoney(GetPlayer.Money - GetPlayer.GetSubCrackCost);
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(GetPlayer.GetSubCrackCost), '<color=255,240,100>');
  GetPlayer.ProgramCounts[prgSabCrack] := 1;
  ClearChoices;
  M_Main(True);
end;
{ @end $5BAD34 }

{ @routine $5BAED0 TfRuinsTalk_BuyPirateBaseSubCrackHalfPrice }
procedure TfRuinsTalk.BuyPirateBaseSubCrackHalfPrice(Action: Integer);
var
  Cost: Integer;
begin
  Cost := GetPlayer.GetSubCrackCost div 2;
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBAfterOkHalf');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), '<color=255,240,100>');
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  GetPlayer.ProgramCounts[prgSabCrack] := 1;
  ClearChoices;
  M_Main(True);
end;
{ @end $5BAED0 }

{ @routine $5BB080 TfRuinsTalk_DeclinePirateBaseSubCrack }
procedure TfRuinsTalk.DeclinePirateBaseSubCrack(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.PB.SabCrack.PBAfterNo');
  ReplaceTextToken(DialogText, '<PB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ClearChoices;
  M_Main(True);
end;
{ @end $5BB080 }

{ @routine $5BB194 TfRuinsTalk_ShowPirateBaseChameleonDialog }
procedure TfRuinsTalk.ShowPirateBaseChameleonDialog(Action: Integer);
var
  I: Byte;
  Text, SeriesName: WideString;
  Value, Cost: Integer;
  SeriesCost, BaseCost: Single;
begin
  BaseCost := Max(1000, Galaxy.ComputeScaledBigMoney(GetPlayer.DockedTo.OwnerId));
  SeriesCost := 0;
  for I := 0 to 2 do
  begin
    case I of
      1: SeriesCost := BaseCost * 1.1;
      0: SeriesCost := BaseCost * 1.2;
      2: SeriesCost := BaseCost * 1.3;
    end;
    PirateChameleonQuoteCosts[I] := Round(SeriesCost + GetPlayer.ChameleonCharges[I] * SeriesCost * 0.1);
  end;
  Text := '-----------------------' + #13#10;
  for I := 0 to 2 do
  begin
    SeriesName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[I] + '.0');
    Cost := PirateChameleonQuoteCosts[I];
    Text := Text + FormatText2(LocalizedColorText('FormRuins.PB.Chameleon.PlayerOk'), '<color=255,240,100>', '<Series>', SeriesName, '<Cost>', IntToStr(Cost)) + #13#10;
  end;
  Text := Text + '-----------------------';
  DialogText := FormatText1(LocalizedColorText('FormRuins.PB.Chameleon.PBAsk'), '', '<List>', Text);
  ClearChoices;
  for I := 0 to 2 do
  begin
    Value := I;
    SeriesName := LookupLocalizedTextByKey('ShipType.Dominator.' + DominatorSeriesNames[I] + '.0');
    Cost := PirateChameleonQuoteCosts[I];
    Text := FormatText2(LocalizedColorText('FormRuins.PB.Chameleon.PlayerOk'), '<color=255,240,100>', '<Series>', SeriesName, '<Cost>', IntToStr(Cost));
    if GetPlayer.Money >= Cost then AddChoice('- ' + Text, Value, BuyPirateBaseChameleon)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.PB.Chameleon.PlayerNo'), 0, DeclinePirateBaseChameleon);
end;
{ @end $5BB194 }

{ @routine $5BB720 TfRuinsTalk_BuyPirateBaseChameleon }
procedure TfRuinsTalk.BuyPirateBaseChameleon(Action: Integer);
var
  Series: Byte;
  Cost: Integer;
begin
  Series := Action;
  Cost := PirateChameleonQuoteCosts[Series];
  Inc(GetPlayer.ChameleonCharges[Series]);
  GetPlayer.SetMoney(Max(0, GetPlayer.Money - Cost));
  SoundManager.PlaySound('Sound.Sell');
  DialogText := LocalizedColorText('FormRuins.PB.Chameleon.PBAfterOk');
  ClearChoices;
  M_Main(True);
end;
{ @end $5BB720 }

{ @routine $5BB864 TfRuinsTalk_DeclinePirateBaseChameleon }
procedure TfRuinsTalk.DeclinePirateBaseChameleon(Action: Integer);
begin
  if Galaxy.CoalitionDefeatedTurn = 0 then DialogText := LocalizedColorText('FormRuins.PB.Chameleon.PBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.PB.Chameleon.PBAfterNoAlt');
  ClearChoices;
  M_Main(True);
end;
{ @end $5BB864 }

{ @routine $5BB9A0 TfRuinsTalk_I_WarWithKlingAndPirates }
procedure TfRuinsTalk.I_WarWithKlingAndPirates(Action: Integer);
var
  CoalitionPercent, DominatorPercent, PiratePercent: Byte;
  Key: WideString;
  EnemyStar: TStar;
  I: Integer;
begin
  EnemyStar := nil;
  CoalitionPercent := Galaxy.GetFactionControlPercent(Ord(sfCoalition));
  DominatorPercent := Galaxy.GetFactionControlPercent(Ord(sfDominators));
  PiratePercent := Galaxy.GetFactionControlPercent(Ord(sfPirates));
  for I := 0 to Galaxy.Stars.Count - 1 do
    if ((TObject(GetPlayer.CurrentStar.StarDistances[I].Star) as TStar).ControlFaction in [sfDominators, sfPirates]) and
      ((TObject(GetPlayer.CurrentStar.StarDistances[I].Star) as TStar).Constellation.Id <> 20) then
    begin
      EnemyStar := GetPlayer.CurrentStar.StarDistances[I].Star;
      Break;
    end;
  if EnemyStar = nil then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) and (Galaxy.PirateWinType <> 3) then
      Key := 'FormRuins.WB.WarWithKlingAndPirates.PiratesOnly.WBAnswerWeControl100Percent'
    else if Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) and (Galaxy.PirateWinType = 3) then
      Key := 'FormRuins.WB.WarWithKlingAndPirates.KlingOnly.WBAnswerWeControl100Percent'
    else Key := 'FormRuins.WB.WarWithKlingAndPirates.KlingAndPirates.WBAnswerWeControl100Percent';
  end
  else
  begin
    if DominatorPercent > PiratePercent * 3 then Key := 'FormRuins.WB.WarWithKlingAndPirates.KlingOnly.'
    else if DominatorPercent * 3 < PiratePercent then Key := 'FormRuins.WB.WarWithKlingAndPirates.PiratesOnly.'
    else Key := 'FormRuins.WB.WarWithKlingAndPirates.KlingAndPirates.';
    case CoalitionPercent of
      0..9: Key := Key + 'WBAnswerWeControlMore00Percent';
      10..22: Key := Key + 'WBAnswerWeControlMore10Percent';
      23..35: Key := Key + 'WBAnswerWeControlMore30Percent';
      36..59: Key := Key + 'WBAnswerWeControlMore50Percent';
      60..89: Key := Key + 'WBAnswerWeControlMore70Percent';
      90..99: Key := Key + 'WBAnswerWeControlMore90Percent';
      100: Key := Key + 'WBAnswerWeControl100Percent';
    else DialogText := 'Error in procedure TfRuinsTalk.I_WarWithKlingAndPirates';
    end;
  end;
  DialogText := LocalizedColorText(Key);
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(CoalitionPercent), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DominatorsPercent>', IntToStr(DominatorPercent), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<PiratesPercent>', IntToStr(PiratePercent), '<color=255,240,100>');
  if EnemyStar <> nil then
  begin
    ReplaceTextToken(DialogText, '<Star>', EnemyStar.Name, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Sector>', EnemyStar.Constellation.GetName, '<color=255,240,100>');
  end;
  M_Main(True);
end;
{ @end $5BB9A0 }

{ @routine $5BC3D8 TfRuinsTalk_ShowMilitaryBaseNextRankDialog }
procedure TfRuinsTalk.ShowMilitaryBaseNextRankDialog(Action: Integer);
var
  I: Byte;
  Token: WideString;
begin
  DialogText := LocalizedColorText('FormRuins.WB.NextRank.WBAnswer');
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<NextRank>', GetPlayer.GetNextRankName, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<NeedPoints>', IntToStr(GetPlayer.GetRankPointsToNextRank), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<RankPointsForLiberationSystem>', IntToStr(30), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<RankPointsForDeadPirates>', IntToStr(10), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<RankPointsForDeadPiratesInGiperSpace>', IntToStr(2), '<color=255,240,100>');
  for I := 0 to 7 do
    if I <> 0 then
    begin
      Token := '<Name' + IntToStr(I) + '>';
      ReplaceTextToken(DialogText, Token, DominatorShipDefinitions[I].DisplayNames[Ord(dsBlazer)], '');
      Token := '<RankPointsFor' + DominatorShipTypeNames[I] + '>';
      ReplaceTextToken(DialogText, Token, IntToStr(DominatorShipDefinitions[I].RankPoints), '<color=255,240,100>');
    end;
  M_Main(True);
end;
{ @end $5BC3D8 }

{ @routine $5BC86C TfRuinsTalk_ShowMilitaryBaseRepairDialog }
procedure TfRuinsTalk.ShowMilitaryBaseRepairDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.WB.Repair.WBAnswer');
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerCostAsk'), 0, ShowMilitaryBaseRepairQuote);
end;
{ @end $5BC86C }

{ @routine $5BC9FC TfRuinsTalk_ShowMilitaryBaseRepairQuote }
procedure TfRuinsTalk.ShowMilitaryBaseRepairQuote(Action: Integer);
var
  Cost: Integer;
begin
  Cost := (GetPlayer.DockedTo as TRuins).GetRepairCost(GetPlayer);
  if Cost = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.WB.Repair.WBCostAnswerNonEquipmentsForRepair');
    M_Main(True);
  end
  else
  begin
    if Cost < GetPlayer.Wealth div 10 then DialogText := LocalizedColorText('FormRuins.WB.Repair.WBCostAnswerYouHaveGoodEquipments')
    else DialogText := LocalizedColorText('FormRuins.WB.Repair.WBCostAnswerYouHaveBadEquipments');
    ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), '<color=255,240,100>');
    ClearChoices;
    if (Cost > 0) and (GetPlayer.Money >= Cost) then
      AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.Repair.PlayerOk'), '<color=255,240,100>', '<Money>', IntToStr(Cost)), 0, AcceptMilitaryBaseRepair);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.Repair.PlayerNo'), 0, DeclineMilitaryBaseRepair);
  end;
end;
{ @end $5BC9FC }

{ @routine $5BCE50 TfRuinsTalk_AcceptMilitaryBaseRepair }
procedure TfRuinsTalk.AcceptMilitaryBaseRepair(Action: Integer);
begin
  (GetPlayer.DockedTo as TRuins).RepairShipEquipment(GetPlayer);
  GetPlayer.RefreshDerivedStats(True);
  DialogText := LocalizedColorText('FormRuins.WB.Repair.WBAfterOk');
  SoundManager.PlaySound('Sound.Repair');
  M_Main(True);
end;
{ @end $5BCE50 }

{ @routine $5BCF58 TfRuinsTalk_DeclineMilitaryBaseRepair }
procedure TfRuinsTalk.DeclineMilitaryBaseRepair(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.WB.Repair.WBAfterNo');
  M_Main(True);
end;
{ @end $5BCF58 }

{ @routine $5BD000 TfRuinsTalk_ShowMilitaryBaseProgramsDialog }
procedure TfRuinsTalk.ShowMilitaryBaseProgramsDialog(Action: Integer);
var
  Text, Info: WideString;
  I: Byte;
begin
  Text := '';
  for I := Low(ProgramNames) to High(ProgramNames) do
    if GetPlayer.ProgramRewardStocks[I] > 0 then
    begin
      Info := LocalizedColorText('FormRuins.WB.Programms.Info');
      ReplaceTextToken(Info, '<Name>', GetPlayer.GetProgramName(I), '<color=255,240,100>');
      ReplaceTextToken(Info, '<Text>', FormatText1(LocalizedText('Programms.' + ProgramNames[I] + '.Text'), '<color=255,240,100>', '<Count>', IntToStr(GetPlayer.ProgramRewardStocks[I])), '');
      ReplaceTextToken(Info, '<Count>', IntToStr(GetPlayer.ProgramRewardStocks[I]), '<color=255,240,100>');
      if Text = '' then Text := Info
      else Text := Text + #13#10 + Info;
    end;
  DialogText := LocalizedColorText('FormRuins.WB.Programms.WBAnswer');
  ReplaceTextToken(DialogText, '<WB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Programms>', Text, '');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.Programms.PlayerOk'), 0, AcceptMilitaryBasePrograms);
end;
{ @end $5BD000 }

{ @routine $5BD3FC TfRuinsTalk_AcceptMilitaryBasePrograms }
procedure TfRuinsTalk.AcceptMilitaryBasePrograms(Action: Integer);
var
  I: Byte;
begin
  for I := Low(ProgramNames) to High(ProgramNames) do
    if GetPlayer.ProgramRewardStocks[I] > 0 then
    begin
      Inc(GetPlayer.ProgramCounts[I], GetPlayer.ProgramRewardStocks[I]);
      GetPlayer.ProgramRewardStocks[I] := 0;
    end;
  GetPlayer.LastDominatorProgramRewardTurn := Galaxy.CurrentTurn;
  GetPlayer.DestroyedDominatorHullMass := 0;
  DialogText := LocalizedColorText('FormRuins.WB.Programms.WBAfterOk');
  M_Main(True);
end;
{ @end $5BD3FC }

{ @routine $5BD528 TfRuinsTalk_ShowMilitaryBaseWarOperationDialog }
procedure TfRuinsTalk.ShowMilitaryBaseWarOperationDialog(Action: Integer);
begin
  BusinessQuoteSmallAmount := RoundAndTruncateToTens(Galaxy.ComputeScaledSmallMoney(2));
  StationServiceQuoteCost := RoundAndTruncateToHundreds(Galaxy.ComputeScaledHugeMoney(2));
  StationServiceQuoteCost := RoundAndTruncateToHundreds(StationServiceQuoteCost * RemapClamped(Galaxy.CurrentTurn - GetPlayer.StationServiceLastUseTurns[cpWarOperation], 0, StationServiceRepeatPeriods[cpWarOperation], 7.7, 1));
  DialogText := LocalizedColorText('FormRuins.WB.WarOperation.WB');
  ReplaceTextToken(DialogText, '<DecMoney>', IntToStr(BusinessQuoteSmallAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.WarOperation.PlayerOk'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, AcceptMilitaryBaseWarOperation)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.WB.WarOperation.PlayerOk'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.WarOperation.PlayerNo'), 0, DeclineMilitaryBaseWarOperation);
end;
{ @end $5BD528 }

{ @routine $5BD94C TfRuinsTalk_AcceptMilitaryBaseWarOperation }
procedure TfRuinsTalk.AcceptMilitaryBaseWarOperation(Action: Integer);
var
  Names: WideString;
  I: Integer;
  Ship: TShip;
  Group: TGroup;
  FromStar, ToStar: TStar;
begin
  DialogText := LocalizedColorText('FormRuins.WB.WarOperation.WBAfterOk');
  if Galaxy.TryCreateLiberationGroup then
  begin
    Group := Galaxy.LiberationGroups[Galaxy.LiberationGroups.Count - 1];
    GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
    GetPlayer.StationServiceLastUseTurns[cpWarOperation] := Galaxy.CurrentTurn;
    GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 25, [0]);
    GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 15, [2, 3, 4]);
    GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 5, [1]);
    for I := Group.Ships.Count - 1 downto 0 do
    begin
      Ship := Group.Ships[I];
      if Names = '' then Names := Ship.GetFullName(' ')
      else Names := Names + #13#10 + Ship.GetFullName(' ');
    end;
    FromStar := Group.Route[0].Target as TStar;
    ToStar := Group.Route[3].Target as TStar;
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.WarOperation.WBAfterOkGood');
    ReplaceTextToken(DialogText, '<Names>', Names, '');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<StarNormal>', FromStar.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<StarEnemy>', ToStar.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SectorNormal>', FromStar.Constellation.GetName, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SectorEnemy>', ToStar.Constellation.GetName, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(Group.Route[2].WaitUntilTurn), '<color=255,240,100>');
  end
  else
  begin
    GetPlayer.SetMoney(GetPlayer.Money - BusinessQuoteSmallAmount);
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.WB.WarOperation.WBAfterOkBad');
    ReplaceTextToken(DialogText, '<DecMoney>', IntToStr(BusinessQuoteSmallAmount), '<color=255,240,100>');
  end;
  M_Main(True);
end;
{ @end $5BD94C }

{ @routine $5BDF08 TfRuinsTalk_DeclineMilitaryBaseWarOperation }
procedure TfRuinsTalk.DeclineMilitaryBaseWarOperation(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.WB.WarOperation.WBAfterNo');
  M_Main(True);
end;
{ @end $5BDF08 }

{ @routine $5BDFBC TfRuinsTalk_ShowMilitaryBaseTravelDialog }
procedure TfRuinsTalk.ShowMilitaryBaseTravelDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBToChamber');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerToChamber'), 0, ConfirmMilitaryBaseTravel);
end;
{ @end $5BDFBC }

{ @routine $5BE104 TfRuinsTalk_ConfirmMilitaryBaseTravel }
procedure TfRuinsTalk.ConfirmMilitaryBaseTravel(Action: Integer);
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table2').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + 'WBbg2');
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBInChamber');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerFly'), 0, DepartWithStation);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerNotFly'), 0, DeclineMilitaryBaseTravel);
end;
{ @end $5BE104 }

{ @routine $5BE3E0 TfRuinsTalk_DepartWithStation }
procedure TfRuinsTalk.DepartWithStation(Action: Integer);
begin
  if Action = 1 then Galaxy.CheckIntegrityChecksum(200);
  RequestedScreenId := screenJump;
  ClearChoices;
  RestoreTemporaryShopStock;
  if SkipVideo then
  begin
    ActiveLoadPanel.SelectBackgroundStyle(2);
    ActiveLoadPanel.RefreshBackgroundImages;
    ActiveLoadPanel.StartClosingShutters;
  end
  else (TObject(RegisteredScreens[Ord(CurrentScreenId)]) as TMessageLoopGI).RequestClose(1);
  if Action = 0 then BreakUiMessage;
end;
{ @end $5BE3E0 }

{ @routine $5BE484 TfRuinsTalk_ShowMilitaryBaseArrivalDialog }
procedure TfRuinsTalk.ShowMilitaryBaseArrivalDialog(Action: Integer);
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table2').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).SetImagePath('GI,Bm.FormRuins.' + GiResourceSuffix + 'WBbg2');
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBInStarEnemy');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerUp'), 0, ShowMilitaryBaseArrivalInfo);
end;
{ @end $5BE484 }

{ @routine $5BE6E0 TfRuinsTalk_DeclineMilitaryBaseTravel }
procedure TfRuinsTalk.DeclineMilitaryBaseTravel(Action: Integer);
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table2').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).SetImagePath('GI,' + GetStationBackgroundPath);
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBAfterNotFly');
  M_Main(True);
end;
{ @end $5BE6E0 }

{ @routine $5BE87C TfRuinsTalk_ShowMilitaryBaseArrivalInfo }
procedure TfRuinsTalk.ShowMilitaryBaseArrivalInfo(Action: Integer);
var
  I: Integer;
  Ship: TShip;
  Names: WideString;
begin
  if LargePortraitLayout and PortraitTableVisible and (StationTransientControl.FindByNameRecursive('Table2') <> nil) then
  begin
    StationTransientControl.FindByNameRecursive('Table2').SetActive(True);
    StationTransientControl.FindByNameRecursive('Table').SetActive(False);
  end;
  (GetByName('ImageBG') as TImageGI).SetImagePath('GI,' + GetStationBackgroundPath);
  Names := '';
  for I := 0 to GetPlayer.CurrentStar.Ships.Count - 1 do
  begin
    Ship := GetPlayer.CurrentStar.Ships[I];
    if (Ship.TypeId = stKling) and not Ship.InHyperspace then
      if Names = '' then Names := Ship.GetName
      else Names := Names + ', ' + Ship.GetName;
  end;
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBStarEnemyInfo');
  ReplaceTextToken(DialogText, '<N>', IntToStr(MilitaryTravelDistance), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Star>', GetPlayer.CurrentStar.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Ships>', Names, '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerHangar'), 0, OpenHangar);
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerQuestions'), 0, ShowMilitaryBaseArrivalQuestions);
end;
{ @end $5BE87C }

{ @routine $5BECC4 TfRuinsTalk_ShowMilitaryBaseArrivalQuestions }
procedure TfRuinsTalk.ShowMilitaryBaseArrivalQuestions(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.WB.FlyToEnemy.WBAfterQuestions');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.WB.FlyToEnemy.PlayerHangar'), 0, OpenHangar);
end;
{ @end $5BECC4 }

{ @routine $5BEE14 TfRuinsTalk_ShowScienceBaseImprovementDialog }
procedure TfRuinsTalk.ShowScienceBaseImprovementDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAnswer');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerAsk'), 0, ShowScienceBaseImprovementItems);
end;
{ @end $5BEE14 }

{ @routine $5BEF50 TfRuinsTalk_ShowScienceBaseImprovementItems }
procedure TfRuinsTalk.ShowScienceBaseImprovementItems(Action: Integer);
var
  I, Count: Integer;
  Item: TEquipment;
  Artefact: TItem;
  Text: WideString;
begin
  ResetStationImprovement;
  ClearChoices;
  Count := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.ItemType in [t_Hull..t_CustomWeapon] then
    begin
      if Item.CanImprove and GetPlayer.CanUseEquipmentTech(Item) and GetPlayer.CanRepairEquipmentTech(Item) then
      begin
        Inc(Count);
        Text := Text + #13#10 + IntToStr(Count) + ') ' + LocalizedColorText('FormRuins.SB.Improvement.ItemReadyForImprovement');
        AddChoice('- ' + NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), Integer(Item), ShowScienceBaseImprovementQuote);
      end;
      ReplaceTextToken(Text, '<ItemName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), '');
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), '<color=255,240,100>');
    end;
  end;
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Artefact := GetPlayer.Artefacts[I];
    if Artefact is TArtefactTranclucator then
    begin
      Item := TShip((Artefact as TArtefactTranclucator).Ship).GetHull;
      if Item.CanImprove then
      begin
        Inc(Count);
        Text := Text + #13#10 + IntToStr(Count) + ') ' + LocalizedColorText('FormRuins.SB.Improvement.ItemReadyForImprovement');
        AddChoice('- ' + NormalizeTextHighlightColors(RemoveTextTagsW(Artefact.GetDisplayName)), Integer(Item), ShowScienceBaseImprovementQuote);
      end;
      ReplaceTextToken(Text, '<ItemName>', NormalizeTextHighlightColors(RemoveTextTagsW(Artefact.GetDisplayName)), '');
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), '<color=255,240,100>');
    end;
  end;
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBSeeItems');
  ReplaceTextToken(DialogText, '<ListItems>', Text, '');
  if Count > 0 then
  begin
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.SB.Improvement.SBSeeItemsHaveItems');
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerNothing'), 0, DeclineScienceBaseImprovement);
  end
  else
  begin
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.SB.Improvement.SBSeeItemsNotHaveItems');
    M_Main(True);
  end;
end;
{ @end $5BEF50 }

{ @routine $5BF650 TfRuinsTalk_DeclineScienceBaseImprovement }
procedure TfRuinsTalk.DeclineScienceBaseImprovement(Action: Integer);
begin
  ResetStationImprovement;
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAnswerNothing');
  M_Main(True);
end;
{ @end $5BF650 }

{ @routine $5BF714 TfRuinsTalk_ShowScienceBaseImprovementQuote }
procedure TfRuinsTalk.ShowScienceBaseImprovementQuote(Action: Integer);
var
  Item: TEquipment;
  Nodes: Integer;
begin
  Item := TEquipment(Action);
  StationImprovementItem := Item;
  if Item.OwnerId = Byte(oiDominator) then
  begin
    DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBNeedCostImprovementNodes');
  ReplaceTextToken(DialogText, '<MinNode>', IntToStr(Round(Item.CalculateImprovementCost(ikMinor) * 0.01)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<AverageNode>', IntToStr(Round(Item.CalculateImprovementCost(ikMedium) * 0.01)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MaxNode>', IntToStr(Round(Item.CalculateImprovementCost(ikMajor) * 0.01)), '<color=255,240,100>');
  end
  else DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBNeedCostImprovement');
  ReplaceTextToken(DialogText, '<FullName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Item.Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Min>', IntToStr(Item.CalculateImprovementCost(ikMinor)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Average>', IntToStr(Item.CalculateImprovementCost(ikMedium)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Max>', IntToStr(Item.CalculateImprovementCost(ikMajor)), '<color=255,240,100>');
  ClearChoices;
  if Item.OwnerId = Byte(oiDominator) then
  begin
    Nodes := GetPlayer.GetAvailableNodeCount(nil);
    if (Nodes >= Round(Item.CalculateImprovementCost(ikMajor) * 0.01)) and (Item.CalculateImprovementCost(ikMajor) <= GetPlayer.Money) then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMax'), 2, SelectScienceBaseImprovementKind);
    if (Nodes >= Round(Item.CalculateImprovementCost(ikMedium) * 0.01)) and (Item.CalculateImprovementCost(ikMedium) <= GetPlayer.Money) then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkAverage'), 1, SelectScienceBaseImprovementKind);
    if (Nodes >= Round(Item.CalculateImprovementCost(ikMinor) * 0.01)) and (Item.CalculateImprovementCost(ikMinor) <= GetPlayer.Money) then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMin'), 0, SelectScienceBaseImprovementKind);
  end
  else
  begin
    if Item.CalculateImprovementCost(ikMajor) <= GetPlayer.Money then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMax'), 2, SelectScienceBaseImprovementKind);
    if Item.CalculateImprovementCost(ikMedium) <= GetPlayer.Money then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkAverage'), 1, SelectScienceBaseImprovementKind);
    if Item.CalculateImprovementCost(ikMinor) <= GetPlayer.Money then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerOkMin'), 0, SelectScienceBaseImprovementKind);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerNo'), 0, DeclineScienceBaseImprovement);
end;
{ @end $5BF714 }

{ @routine $5C003C TfRuinsTalk_SelectScienceBaseImprovementKind }
procedure TfRuinsTalk.SelectScienceBaseImprovementKind(Action: Integer);
var
  Item: TEquipment;
  Text: WideString;
  Detail, Count: Integer;
begin
  StationImprovementKind := TImprovementKind(Action);
  Item := StationImprovementItem;
  Detail := 1;
  Count := 0;
  while True do
  begin
    if not (Item is TEngine) and not (Item is TWeapon) and not (Item is TCargoHook) then Break;
    if not ((Detail = 2) and (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket])) then
    begin
      Text := LocalizedColorText('Items.' + Item.GetCategoryConfigName + '.Detail.' + IntToStr(Detail));
      if Length(Text) <> 0 then
      begin
        if Detail = 1 then
        begin
          DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBDetailImprovement');
          ClearChoices;
        end;
        AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Improvement.PlayerDetailOk'), '<color=255,240,100>', '<Attr>', Text), Detail, AcceptScienceBaseImprovement);
        Inc(Count);
      end;
    end;
    Inc(Detail);
    if Detail > 100 then Break;
  end;
  if Count > 1 then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerDetailNo'), 0, DeclineScienceBaseImprovement)
  else AcceptScienceBaseImprovement(0);
end;
{ @end $5C003C }

{ @routine $5C03C8 TfRuinsTalk_AcceptScienceBaseImprovement }
procedure TfRuinsTalk.AcceptScienceBaseImprovement(Action: Integer);
var
  Item: TEquipment;
  Kind: TImprovementKind;
  Cost, Nodes: Integer;
begin
  StationImprovementDetail := Action;
  Item := StationImprovementItem;
  Kind := StationImprovementKind;
  Cost := Item.CalculateImprovementCost(Kind);
  if Item.OwnerId = Byte(oiDominator) then Nodes := Round(Cost * 0.01) else Nodes := 0;
  if (GetPlayer.Money >= Cost) and (GetPlayer.GetAvailableNodeCount(nil) >= Nodes) then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    if Item.OwnerId = Byte(oiDominator) then GetPlayer.ConsumeAvailableNodes(Nodes, nil);
    Item.DetailImprovement := StationImprovementDetail;
    Item.Improve(Kind);
    GetPlayer.RefreshDerivedStats(True);
    case Kind of
      ikMinor: DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterOkMin');
      ikMedium: DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterOkAverage');
      ikMajor: DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterOkMax');
    else RaiseWideMessage('SB: Improvement = any');
    end;
    ReplaceTextToken(DialogText, '<ShortName>', WideLowerCase(Item.GetShortName), '');
    SoundManager.PlaySound('Sound.Sell');
    ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerRepeatOk'), 0, ShowScienceBaseImprovementItems);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Improvement.PlayerRepeatNo'), 0, DeclineScienceBaseRepeatImprovement);
    ResetStationImprovement;
  end
  else DeclineScienceBaseRepeatImprovement(0);
end;
{ @end $5C03C8 }

{ @routine $5C082C TfRuinsTalk_DeclineScienceBaseRepeatImprovement }
procedure TfRuinsTalk.DeclineScienceBaseRepeatImprovement(Action: Integer);
begin
  ResetStationImprovement;
  DialogText := LocalizedColorText('FormRuins.SB.Improvement.SBAfterRepeatNo');
  M_Main(True);
end;
{ @end $5C082C }

{ @routine $5C08F0 TfRuinsTalk_ShowScienceBaseRepairDialog }
procedure TfRuinsTalk.ShowScienceBaseRepairDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Repair.SBAnswer');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerCostAsk'), 0, ShowScienceBaseRepairQuote);
end;
{ @end $5C08F0 }

{ @routine $5C0A80 TfRuinsTalk_ShowScienceBaseRepairQuote }
procedure TfRuinsTalk.ShowScienceBaseRepairQuote(Action: Integer);
var
  Cost, EquipmentCost, I, NodeCost: Integer;
  Item: TEquipment;
begin
  NodeCost := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag <> 0 then
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) and Item.NeedsRepair then
        if (GetPlayer.DockedTo as TRuins).CanRepairEquipmentTech(Item) then Inc(NodeCost, Item.CalculateRepairCost);
  end;
  if NodeCost > 0 then
  begin
    NodeCost := Round(NodeCost * 0.0025);
    if NodeCost = 0 then NodeCost := 1;
  end;
  Cost := (GetPlayer.DockedTo as TRuins).CalculateRepairCost(GetPlayer, EquipmentCost);
  if Cost = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerNonEquipmentsForRepair');
    M_Main(True);
  end
  else
  begin
    if Cost < GetPlayer.Wealth div 10 then DialogText := LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerYouHaveGoodEquipments')
    else DialogText := LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerYouHaveBadEquipments');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<EqMoney>', IntToStr(EquipmentCost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<ArtMoney>', IntToStr(Cost - EquipmentCost), '<color=255,240,100>');
    if NodeCost <> 0 then
    begin
      DialogText := DialogText + LocalizedColorText('FormRuins.SB.Repair.SBCostAnswerNeedNode');
      ReplaceTextToken(DialogText, '<NeedNode>', IntToStr(NodeCost), '<color=255,240,100>');
    end;
    ClearChoices;
    if (Cost > 0) and (GetPlayer.Money >= Cost) then
      if (NodeCost = 0) or ((NodeCost > 0) and (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost)) then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerOk'), 0, AcceptScienceBaseRepair);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Repair.PlayerNo'), 0, DeclineScienceBaseRepair);
  end;
end;
{ @end $5C0A80 }

{ @routine $5C1118 TfRuinsTalk_AcceptScienceBaseRepair }
procedure TfRuinsTalk.AcceptScienceBaseRepair(Action: Integer);
var
  I, NodeCost: Integer;
  Item: TEquipment;
begin
  NodeCost := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.EquippedFlag <> 0 then
      if (Item is TWeapon) and (TWeapon(Item).GetWeaponInfo.Availability = waNotSoldAndNodeRepair) and Item.NeedsRepair then
        if (GetPlayer.DockedTo as TRuins).CanRepairEquipmentTech(Item) then Inc(NodeCost, Item.CalculateRepairCost);
  end;
  if NodeCost > 0 then
  begin
    NodeCost := Round(NodeCost * 0.0025);
    if NodeCost = 0 then NodeCost := 1;
  end;
  if GetPlayer.GetAvailableNodeCount(nil) >= NodeCost then
  begin
    GetPlayer.ConsumeAvailableNodes(NodeCost, nil);
    (GetPlayer.DockedTo as TRuins).RepairShipEquipment(GetPlayer);
    GetPlayer.RefreshDerivedStats(True);
    DialogText := LocalizedColorText('FormRuins.SB.Repair.SBAfterOk');
    SoundManager.PlaySound('Sound.Repair');
    M_Main(True);
  end
  else DeclineScienceBaseRepair(0);
end;
{ @end $5C1118 }

{ @routine $5C1320 TfRuinsTalk_DeclineScienceBaseRepair }
procedure TfRuinsTalk.DeclineScienceBaseRepair(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Repair.SBAfterNo');
  M_Main(True);
end;
{ @end $5C1320 }

{ @routine $5C13C8 TfRuinsTalk_ShowScienceBaseSatelliteOfferDialog }
procedure TfRuinsTalk.ShowScienceBaseSatelliteOfferDialog(Refresh: Integer);
var
  Satellite: TSatellite;
  Text: WideString;
begin
  Satellite := (GetPlayer.DockedTo as TRuins).SatelliteOffer;
  if Satellite = nil then RaiseWideMessage('I_SBSatelliteAsk sat=nil');
  if Refresh = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBInfo');
    if Galaxy.CountExistingSatellites < GetPlayer.GetSatelliteLimit then
      DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.SB.Satellite.SBInfoOk')
    else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.SB.Satellite.SBInfoNo');
    ReplaceTextToken(DialogText, '<SatName>', Satellite.GetDisplayName, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<SatText>', Satellite.GetInfoText('', nil), '');
  ReplaceTextToken(DialogText, '<SatSize>', IntToStr(Satellite.Weight), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SatMoney>', IntToStr(Satellite.Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SatCurCount>', IntToStr(Galaxy.CountExistingSatellites), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SatMayCount>', IntToStr(GetPlayer.GetSatelliteLimit), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  end;
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Satellite.PlayerInstruction'), 0, ShowSatelliteInstructions);
  Text := LocalizedColorText('FormRuins.SB.Satellite.PlayerOk');
  ReplaceTextToken(Text, '<SatName>', Satellite.GetDisplayName, '<color=255,240,100>');
  ReplaceTextToken(Text, '<SatMoney>', IntToStr(Satellite.Cost), '<color=255,240,100>');
  if (Galaxy.CountExistingSatellites < GetPlayer.GetSatelliteLimit) and (GetPlayer.Money >= Satellite.Cost) then
    AddChoice('- ' + Text, 0, BuyScienceBaseSatellite)
  else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Satellite.PlayerNo'), 0, DeclineScienceBaseSatellite);
end;
{ @end $5C13C8 }

{ @routine $5C1AA4 TfRuinsTalk_ShowSatelliteInstructions }
procedure TfRuinsTalk.ShowSatelliteInstructions(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBInstruction');
  ShowScienceBaseSatelliteOfferDialog(1);
end;
{ @end $5C1AA4 }

{ @routine $5C1B60 TfRuinsTalk_BuyScienceBaseSatellite }
procedure TfRuinsTalk.BuyScienceBaseSatellite(Action: Integer);
var Satellite: TSatellite;
begin
  Satellite := (GetPlayer.DockedTo as TRuins).SatelliteOffer;
  DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBAfterOk');
  ReplaceTextToken(DialogText, '<SatName>', Satellite.GetDisplayName, '<color=255,240,100>');
  GetPlayer.SetMoney(GetPlayer.Money - Satellite.Cost);
  GetPlayer.Inventory.Add(Satellite);
  (GetPlayer.DockedTo as TRuins).SatelliteOffer := nil;
  (GetPlayer.DockedTo as TRuins).RegenerateSatelliteOffer;
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5C1B60 }

{ @routine $5C1D2C TfRuinsTalk_DeclineScienceBaseSatellite }
procedure TfRuinsTalk.DeclineScienceBaseSatellite(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Satellite.SBAfterNo');
  M_Main(True);
end;
{ @end $5C1D2C }

{ @routine $5C1DDC TfRuinsTalk_ShowScienceBaseResearchDialog }
procedure TfRuinsTalk.ShowScienceBaseResearchDialog(Action: Integer);
var
  Text, Info: WideString;
  Series: TDominatorSeries;
begin
  Text := LocalizedColorText('FormRuins.SB.Scn.SBSectionInfo');
  ClearChoices;
  for Series := dsBlazer to dsTerron do
  begin
    if not Galaxy.IsDominatorResearchComplete([Series]) and Galaxy.IsDominatorSeriesUnresolved(Series) then
    begin
      Info := LocalizedColorText('FormRuins.SB.Scn.SBSectionInfoAdd');
      if GetPlayer.CountUnequippedDominatorEquipment > 0 then
        AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[Ord(Series)]), Ord(Series) + 1, SelectScienceBaseResearchSection)
      else AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[Ord(Series)]), 0, ScriptDialogBlockCallback);
  ReplaceTextToken(Info, '<Count>', IntToStr(Galaxy.DominatorResearch[Ord(Series)].Material), '<color=255,240,100>');
  ReplaceTextToken(Info, '<Speed>', IntToStr(Galaxy.GetDominatorResearchEfficiency(Series)), '<color=255,240,100>');
  ReplaceTextToken(Info, '<Day>', IntToStr(Round(Max(1.0, (100 - Galaxy.DominatorResearch[Ord(Series)].Progress) / Galaxy.GetDominatorResearchRate(Series)))), '<color=255,240,100>');
    end
    else Info := LocalizedColorText('FormRuins.SB.Scn.SBSectionInfoEnd');
    case Series of
      dsBlazer: ReplaceTextToken(Text, '<SBAnswerInfoBlazer>', Info, '');
      dsKeller: ReplaceTextToken(Text, '<SBAnswerInfoKeller>', Info, '');
      dsTerron: ReplaceTextToken(Text, '<SBAnswerInfoTerron>', Info, '');
    end;
  end;
  if Action = 0 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAnswer')
  else DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAnswer2');
  ReplaceTextToken(DialogText, '<SBSectionInfo>', Text, '');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.SectionNone'), 0, SelectScienceBaseResearchSection);
end;
{ @end $5C1DDC }

{ @routine $5C2494 TfRuinsTalk_SelectScienceBaseResearchSection }
procedure TfRuinsTalk.SelectScienceBaseResearchSection(Action: Integer);
var
  Text: WideString;
  Series: Byte;
begin
  ClearChoices;
  if Action = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterSectionNone');
    M_Main(True);
  end
  else
  begin
    Text := '';
    Series := Action - 1;
    SelectedResearchSeries := Series;
    BuildResearchItemChoices(Series, Text);
    DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSection1');
    ReplaceTextToken(DialogText, '<SectionName>', LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[Series]), '');
    ReplaceTextToken(DialogText, '<Items>', Text, '');
    ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 1, DeclineScienceBaseResearch);
  end;
end;
{ @end $5C2494 }

{ @routine $5C2860 TfRuinsTalk_SellResearchRemains }
procedure TfRuinsTalk.SellResearchRemains(Action: Integer);
var
  Text: WideString;
  Money, I: Integer;
  Item: TEquipment;
begin
  Money := 0;
  for I := GetPlayer.Inventory.Count - 1 downto 0 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = Byte(oiDominator)) and (Item.DominatorSeries = TDominatorSeries(SelectedResearchSeries)) and (Item.NoDropFlag = 0) and (Item is TUselessItem) then
      if not IsResearchItemQuestLetter(Item as TUselessItem) and (Item.CustomFaction = '') then
    begin
      Inc(Galaxy.DominatorResearch[SelectedResearchSeries].Material, Item.Weight);
      Inc(Money, 2 * Item.Cost);
      GetPlayer.Inventory.Delete(I);
      Item.Free;
    end;
  end;
  SoundManager.PlaySound('Sound.Sell');
  GetPlayer.SetMoney(GetPlayer.Money + Money);
  GetPlayer.RefreshDerivedStats(True);
  ClearChoices;
  BuildResearchItemChoices(SelectedResearchSeries, Text);
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSection2');
  if Text <> '' then DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.SB.Scn.SBSection2Add');
  ReplaceTextToken(DialogText, '<SectionName>', LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[SelectedResearchSeries]), '');
  ReplaceTextToken(DialogText, '<Items>', Text, '');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Galaxy.DominatorResearch[SelectedResearchSeries].Material), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Money), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  if Text <> '' then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 2, DeclineScienceBaseResearch)
  else
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 3, DeclineScienceBaseResearch);
end;
{ @end $5C2860 }

{ @routine $5C2E6C TfRuinsTalk_SellResearchEquipment }
procedure TfRuinsTalk.SellResearchEquipment(Action: Integer);
var
  Text: WideString;
  Money, I: Integer;
  Item: TEquipment;
begin
  Money := 0;
  for I := GetPlayer.Inventory.Count - 1 downto 0 do
  begin
    Item := GetPlayer.Inventory[I];
    if (Item.OwnerId = Byte(oiDominator)) and not (Item is TUselessItem) and (Item.EquippedFlag = 0) and (Item.NoDropFlag = 0) and (Item.ItemType <> t_Protoplasm) and (Item.ItemType <> t_MicroModule) and (Item.CustomFaction = '') then
    begin
      Inc(Galaxy.DominatorResearch[SelectedResearchSeries].Material, Item.Weight);
      Inc(Money, Item.Cost);
      GetPlayer.Inventory.Delete(I);
      Item.Free;
    end;
  end;
  SoundManager.PlaySound('Sound.Sell');
  GetPlayer.SetMoney(GetPlayer.Money + Money);
  GetPlayer.RefreshDerivedStats(True);
  ClearChoices;
  BuildResearchItemChoices(SelectedResearchSeries, Text);
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSection2');
  if Text <> '' then DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.SB.Scn.SBSection2Add');
  ReplaceTextToken(DialogText, '<SectionName>', LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[SelectedResearchSeries]), '');
  ReplaceTextToken(DialogText, '<Items>', Text, '');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Galaxy.DominatorResearch[SelectedResearchSeries].Material), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Money), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  if Text <> '' then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 2, DeclineScienceBaseResearch)
  else
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 3, DeclineScienceBaseResearch);
end;
{ @end $5C2E6C }

{ @routine $5C3464 TfRuinsTalk_SellResearchItem }
procedure TfRuinsTalk.SellResearchItem(Action: Integer);
var
  Text: WideString;
  Money: Integer;
  Item: TEquipment;
begin
  Item := GetPlayer.Inventory[Action];
  Inc(Galaxy.DominatorResearch[SelectedResearchSeries].Material, Item.Weight);
  if (Item.DominatorSeries = TDominatorSeries(SelectedResearchSeries)) and (Item is TUselessItem) then Money := Item.Cost * 2
  else Money := Item.Cost;
  GetPlayer.SetMoney(GetPlayer.Money + Money);
  SoundManager.PlaySound('Sound.Sell');
  GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(Item));
  GetPlayer.RefreshDerivedStats(True);
  Item.Free;
  ClearChoices;
  BuildResearchItemChoices(SelectedResearchSeries, Text);
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSection2');
  if Text <> '' then DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.SB.Scn.SBSection2Add');
  ReplaceTextToken(DialogText, '<SectionName>', LocalizedColorText('FormRuins.SB.Scn.Section' + DominatorSeriesNames[SelectedResearchSeries]), '');
  ReplaceTextToken(DialogText, '<Items>', Text, '');
  ReplaceTextToken(DialogText, '<Count>', IntToStr(Galaxy.DominatorResearch[SelectedResearchSeries].Material), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Money), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<ItemsCool>', LookupLocalizedTextOrEmpty('FormRuins.SB.Scn.ItemsCool'), '<color=255,240,100>');
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSectionChoose'), 1, ShowScienceBaseResearchDialog);
  if Text <> '' then
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 2, DeclineScienceBaseResearch)
  else
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerSaleNo'), 3, DeclineScienceBaseResearch);
end;
{ @end $5C3464 }

{ @routine $5C3A1C TfRuinsTalk_DeclineScienceBaseResearch }
procedure TfRuinsTalk.DeclineScienceBaseResearch(Action: Integer);
begin
  ClearChoices;
  if Action = 1 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerSaleNo1')
  else if Action = 2 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerSaleNo2')
  else if Action = 3 then DialogText := LocalizedColorText('FormRuins.SB.Scn.SBSectionEnd');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5C3A1C }

{ @routine $5C3C20 TfRuinsTalk_BuyScienceBaseResearchProgram }
procedure TfRuinsTalk.BuyScienceBaseResearchProgram(Action: Integer);
var
  Cost: Integer;
begin
  SelectedResearchSeries := Action - 1;
  Cost := RoundAndTruncateToHundreds(Min(Galaxy.ComputeScaledHugeMoney(2) * 2, GetPlayer.Wealth div 30) * ResearchProgramCostFactors[SelectedResearchSeries]);
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBBuyTech' + DominatorSeriesNames[SelectedResearchSeries]);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.Money >= Cost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechOk'), '<color=255,240,100>', '<Money>', IntToStr(Cost)), Cost, AcceptScienceBaseResearchProgram)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechOk'), '<color=255,240,100>', '<Money>', IntToStr(Cost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.SB.Scn.PlayerBuyTechNo'), 0, DeclineScienceBaseResearchProgram);
end;
{ @end $5C3C20 }

{ @routine $5C3FDC TfRuinsTalk_AcceptScienceBaseResearchProgram }
procedure TfRuinsTalk.AcceptScienceBaseResearchProgram(Action: Integer);
var
  Cost: Integer;
begin
  Cost := Action;
  GetPlayer.SetMoney(GetPlayer.Money - Cost);
  SoundManager.PlaySound('Sound.Sell');
  case SelectedResearchSeries of
    Ord(dsBlazer): GetPlayer.ProgramCounts[prgLogicalNegation] := 1;
    Ord(dsKeller): GetPlayer.ProgramCounts[prgDematerial] := 1;
    Ord(dsTerron): GetPlayer.ProgramCounts[prgEnergotron] := 1;
  end;
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerBuyTech' + DominatorSeriesNames[SelectedResearchSeries]);
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5C3FDC }

{ @routine $5C41F0 TfRuinsTalk_DeclineScienceBaseResearchProgram }
procedure TfRuinsTalk.DeclineScienceBaseResearchProgram(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.SB.Scn.SBAfterPlayerBuyTechNo');
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5C41F0 }

{ @routine $5C430C TfRuinsTalk_ShowScienceBaseHistoryDialog }
procedure TfRuinsTalk.ShowScienceBaseHistoryDialog(Action: Integer);
begin
  ClearChoices;
  case Action of
    0:
    begin
      DialogText := LocalizedColorText('FormRuinsSB.History.SBOk');
      AddChoice('- ' + LocalizedColorText('FormRuinsSB.Continue'), 1, ShowScienceBaseHistoryDialog);
    end;
    1:
    begin
      DialogText := LocalizedColorText('FormRuinsSB.History.SBOk1');
      AddChoice('- ' + LocalizedColorText('FormRuinsSB.Continue'), 2, ShowScienceBaseHistoryDialog);
    end;
    2:
    begin
      DialogText := LocalizedColorText('FormRuinsSB.History.SBOk2');
      AddChoice('- ' + LocalizedColorText('FormRuinsSB.Continue'), 3, ShowScienceBaseHistoryDialog);
    end;
    3:
    begin
      DialogText := LocalizedColorText('FormRuinsSB.History.SBOk3');
      AddChoice('- ' + LocalizedColorText('FormRuinsSB.Continue'), 4, ShowScienceBaseHistoryDialog);
    end;
    4:
    begin
      DialogText := LocalizedColorText('FormRuinsSB.History.SBOk4');
      M_Main(True);
    end;
  end;
  ReplaceTextToken(DialogText, '<SB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
end;
{ @end $5C430C }

{ @routine $5C46B8 TfRuinsTalk_ShowBusinessCenterDebtDialog }
procedure TfRuinsTalk.ShowBusinessCenterDebtDialog(Action: Integer);
var
  Days, I: Integer;
  Event: TGalaxyEvent;
  Factor: Double;
begin
  if GetPlayer.CurrentStar.Battle <> 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.BK.DebtNoWar');
    M_Main(True);
  end
  else
  begin
    for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
    begin
      Event := TGalaxyEvent(Galaxy.GalaxyEvents[I]);
      if Event.Turn + 1825 < Galaxy.CurrentTurn then Break;
      if ((Event.EventType = 'PlayerKillsShip') or (Event.EventType = 'PlayerCompanionKillsShip') or (Event.EventType = 'PlayerTranclucatorKillsShip')) and (Event.GetData(0) = 10) then
      begin
        DialogText := LocalizedColorText('FormRuins.BK.DebtNoPenalty');
        ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(Event.Turn + 1825), '<color=255,240,100>');
        M_Main(True);
        Exit;
      end;
    end;
    Factor := 1;
    for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
    begin
      Event := TGalaxyEvent(Galaxy.GalaxyEvents[I]);
      if Event.Turn + 1095 < Galaxy.CurrentTurn then Break;
      if Event.EventType = 'PlayerDebtNullified' then Factor := Factor * 0.5;
    end;
    BusinessQuoteMediumAmount := RoundAndTruncateToHundreds(Min(Int64(1000000), Galaxy.AverageRangerCapital div Round(RemapClamped(SeededRandomUnitFloat(Galaxy.CurrentTurn div 191 + GetPlayer.DockedTo.Seed), 0, 1, 3, 6))) * Factor);
    BusinessQuoteSmallAmount := RoundAndTruncateToHundreds(BusinessQuoteMediumAmount div 2);
    BusinessQuoteLargeAmount := BusinessQuoteMediumAmount * 2;
    Days := Round(RemapClamped(SeededRandomUnitFloat(Galaxy.CurrentTurn div 377 + GetPlayer.DockedTo.Seed), 0, 1, 1, 3) * 360);
    BusinessQuoteMediumDueTurn := Galaxy.CurrentTurn + Days;
    BusinessQuoteLargeDueTurn := Galaxy.CurrentTurn + Days div 2;
    BusinessQuoteSmallDueTurn := Galaxy.CurrentTurn + Days * 3;
    DialogText := LocalizedColorText('FormRuins.BK.TakeDebt.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MinMoney>', IntToStr(BusinessQuoteSmallAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<AveMoney>', IntToStr(BusinessQuoteMediumAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MaxMoney>', IntToStr(BusinessQuoteLargeAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MinDay>', IntToStr(BusinessQuoteLargeDueTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<AveDay>', IntToStr(BusinessQuoteMediumDueTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MaxDay>', IntToStr(BusinessQuoteSmallDueTurn - Galaxy.CurrentTurn), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MinMoneyAdd>', IntToStr(Round(BusinessQuoteSmallAmount * 1.1) - BusinessQuoteSmallAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<AveMoneyAdd>', IntToStr(Round(BusinessQuoteMediumAmount * 1.15) - BusinessQuoteMediumAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MaxMoneyAdd>', IntToStr(Round(BusinessQuoteLargeAmount * 1.2) - BusinessQuoteLargeAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MinMoneyReturn>', IntToStr(Round(BusinessQuoteSmallAmount * 1.1)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<AveMoneyReturn>', IntToStr(Round(BusinessQuoteMediumAmount * 1.15)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MaxMoneyReturn>', IntToStr(Round(BusinessQuoteLargeAmount * 1.2)), '<color=255,240,100>');
    ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerOkMaxMoney'), 1, AcceptBusinessCenterDebtQuote);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerOkAveMoney'), 2, AcceptBusinessCenterDebtQuote);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerOkMinMoney'), 3, AcceptBusinessCenterDebtQuote);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.TakeDebt.PlayerNo'), 0, DeclineBusinessCenterDebtDialog);
  end;
end;
{ @end $5C46B8 }

{ @routine $5C5464 TfRuinsTalk_AcceptBusinessCenterDebtQuote }
procedure TfRuinsTalk.AcceptBusinessCenterDebtQuote(Quote: Integer);
var Amount: Integer;
begin
  case Quote of
    1:
      begin
        GetPlayer.DebtAmount := Round(BusinessQuoteLargeAmount * 1.2);
        GetPlayer.DebtDueTurn := BusinessQuoteLargeDueTurn;
        Amount := BusinessQuoteLargeAmount;
      end;
    2:
      begin
        GetPlayer.DebtAmount := Round(BusinessQuoteMediumAmount * 1.15);
        GetPlayer.DebtDueTurn := BusinessQuoteMediumDueTurn;
        Amount := BusinessQuoteMediumAmount;
      end;
    3:
      begin
        GetPlayer.DebtAmount := Round(BusinessQuoteSmallAmount * 1.1);
        GetPlayer.DebtDueTurn := BusinessQuoteSmallDueTurn;
        Amount := BusinessQuoteSmallAmount;
      end;
  else
    begin
      DialogText := LocalizedColorText('Error I_TakeDebtOk data<>1,2,3');
      M_Main(True);
      Exit;
    end;
  end;
  GetPlayer.DebtDefaultCount := 0;
  GetPlayer.SetMoney(GetPlayer.Money + Amount);
  DialogText := LocalizedColorText('FormRuins.BK.TakeDebt.BKAfterOk');
  ReplaceTextToken(DialogText, '<SendMoney>', IntToStr(Amount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DebtMoney>', IntToStr(GetPlayer.DebtAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(GetPlayer.DebtDueTurn), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5C5464 }

{ @routine $5C5830 TfRuinsTalk_DeclineBusinessCenterDebtDialog }
procedure TfRuinsTalk.DeclineBusinessCenterDebtDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.TakeDebt.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5C5830 }

{ @routine $5C593C TfRuinsTalk_RepayBusinessCenterDebt }
procedure TfRuinsTalk.RepayBusinessCenterDebt(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.RetDebt.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  GetPlayer.DebtDefaultCount := 0;
  GetPlayer.SetMoney(GetPlayer.Money - GetPlayer.DebtAmount);
  GetPlayer.DebtAmount := 0;
  GetPlayer.DebtDueTurn := 0;
  M_Main(True);
end;
{ @end $5C593C }

{ @routine $5C5A80 TfRuinsTalk_ShowBusinessCenterDepositDialog }
procedure TfRuinsTalk.ShowBusinessCenterDepositDialog(Action: Integer);
var
  Text: WideString;
begin
  BusinessQuoteLargeAmount := Min(10000000, Max(1000, GetPlayer.Money));
  BusinessQuoteMediumAmount := Min(10000000, Max(1000, GetPlayer.Money div 2));
  BusinessQuoteSmallAmount := Min(10000000, Max(1000, GetPlayer.Money div 4));
  BusinessDepositQuoteInterestRate := RoundTo(RemapClamped(Galaxy.GetFactionControlPercent(Ord(sfDominators)), 5, 95, 7, 1), -1);
  DialogText := LocalizedColorText('FormRuins.BK.Deposit.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Percent>', FloatToStrF(BusinessDepositQuoteInterestRate, ffFixed, 1, 1), '<color=255,240,100>');
  ClearChoices;
  Text := FormatText1(LocalizedColorText('FormRuins.BK.Deposit.PlayerOkMaxMoney'), '<color=255,240,100>', '<MaxMoney>', IntToStr(BusinessQuoteLargeAmount));
  if GetPlayer.Money >= BusinessQuoteLargeAmount then AddChoice('- ' + Text, 1, AcceptBusinessCenterDepositQuote)
  else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  if BusinessQuoteMediumAmount <> BusinessQuoteLargeAmount then
  begin
    Text := FormatText1(LocalizedColorText('FormRuins.BK.Deposit.PlayerOkAveMoney'), '<color=255,240,100>', '<AveMoney>', IntToStr(BusinessQuoteMediumAmount));
    if GetPlayer.Money >= BusinessQuoteMediumAmount then AddChoice('- ' + Text, 2, AcceptBusinessCenterDepositQuote)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  end;
  if (BusinessQuoteSmallAmount <> BusinessQuoteLargeAmount) and (BusinessQuoteSmallAmount <> BusinessQuoteMediumAmount) then
  begin
    Text := FormatText1(LocalizedColorText('FormRuins.BK.Deposit.PlayerOkMinMoney'), '<color=255,240,100>', '<MinMoney>', IntToStr(BusinessQuoteSmallAmount));
    if GetPlayer.Money >= BusinessQuoteSmallAmount then AddChoice('- ' + Text, 3, AcceptBusinessCenterDepositQuote)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Deposit.PlayerNo'), 0, DeclineBusinessCenterDepositDialog);
end;
{ @end $5C5A80 }

{ @routine $5C615C TfRuinsTalk_AcceptBusinessCenterDepositQuote }
procedure TfRuinsTalk.AcceptBusinessCenterDepositQuote(Quote: Integer);
begin
  case Quote of
    1: GetPlayer.DepositAmount := Round(BusinessQuoteLargeAmount);
    2: GetPlayer.DepositAmount := Round(BusinessQuoteMediumAmount);
    3: GetPlayer.DepositAmount := Round(BusinessQuoteSmallAmount);
  end;
  GetPlayer.DepositInterestRate := BusinessDepositQuoteInterestRate;
  GetPlayer.DepositDayCount := 0;
  GetPlayer.DepositStartTurn := Galaxy.CurrentTurn;
  GetPlayer.SetMoney(Max(0, GetPlayer.Money - GetPlayer.DepositAmount));
  DialogText := LocalizedColorText('FormRuins.BK.Deposit.BKAfterOk');
  ReplaceTextToken(DialogText, '<SendMoney>', IntToStr(GetPlayer.DepositAmount), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Percent>', FloatToStrF(BusinessDepositQuoteInterestRate, ffFixed, 1, 1), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5C615C }

{ @routine $5C6440 TfRuinsTalk_DeclineBusinessCenterDepositDialog }
procedure TfRuinsTalk.DeclineBusinessCenterDepositDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Deposit.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5C6440 }

{ @routine $5C654C TfRuinsTalk_WithdrawBusinessCenterDeposit }
procedure TfRuinsTalk.WithdrawBusinessCenterDeposit(Action: Integer);
var Profit: Integer;
begin
  if GetPlayer.CurrentStar.Battle <> 0 then
    DialogText := LocalizedColorText('FormRuins.BK.RetDeposit.War')
  else
  begin
    DialogText := LocalizedColorText('FormRuins.BK.RetDeposit.BK');
    ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
    Profit := GetPlayer.ComputeDepositAccruedValue - GetPlayer.DepositAmount;
    GetPlayer.SetMoney(GetPlayer.Money + GetPlayer.ComputeDepositAccruedValue);
    GetPlayer.AchievementStats.CheckInvestorAchievement(Profit);
    GetPlayer.DepositAmount := 0;
    GetPlayer.DepositStartTurn := 0;
    GetPlayer.DepositDayCount := 0;
    GetPlayer.DepositInterestRate := 0;
    SoundManager.PlaySound('Sound.Sell');
  end;
  M_Main(True);
end;
{ @end $5C654C }

{ @routine $5C6774 TfRuinsTalk_ShowBusinessCenterMedicalPolicyDialog }
procedure TfRuinsTalk.ShowBusinessCenterMedicalPolicyDialog(Refresh: Integer);
begin
  if Refresh = 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.BK.Policy.BK');
    ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Money>', IntToStr(Galaxy.ComputeScaledAverageMoney(2)), '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Year>', IntToStr(5), '<color=255,240,100>');
  end;
  ClearChoices;
  if Galaxy.ComputeScaledAverageMoney(2) <= GetPlayer.Money then
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerOk'), 0, BuyBusinessCenterMedicalPolicy)
  else
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerOk'), 0, ScriptDialogBlockCallback);
  if Refresh = 0 then
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerAsk'), 0, ShowBusinessCenterPolicyDetails);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Policy.PlayerNo'), 0, DeclineBusinessCenterPolicy);
end;
{ @end $5C6774 }

{ @routine $5C6AFC TfRuinsTalk_BuyBusinessCenterMedicalPolicy }
procedure TfRuinsTalk.BuyBusinessCenterMedicalPolicy(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Policy.BKAfterOk');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Galaxy.ComputeScaledAverageMoney(2)), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Year>', IntToStr(5), '<color=255,240,100>');
  GetPlayer.SetMoney(GetPlayer.Money - Galaxy.ComputeScaledAverageMoney(2));
  GetPlayer.MedicalPolicyTicks := 1825;
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5C6AFC }

{ @routine $5C6D1C TfRuinsTalk_ShowBusinessCenterPolicyDetails }
procedure TfRuinsTalk.ShowBusinessCenterPolicyDetails(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Policy.BKAfterAsk');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ClearChoices;
  ShowBusinessCenterMedicalPolicyDialog(1);
end;
{ @end $5C6D1C }

{ @routine $5C6E30 TfRuinsTalk_DeclineBusinessCenterPolicy }
procedure TfRuinsTalk.DeclineBusinessCenterPolicy(Action: Integer);
var
  Date: TDateTime;
  YearText: AnsiString;
begin
  DialogText := LocalizedColorText('FormRuins.BK.Policy.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  Date := Galaxy.TurnToDateTime(-1);
  DateTimeToString(YearText, 'yyyy', Date);
  ReplaceTextToken(DialogText, '<CurYear>', YearText, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5C6E30 }

{ @routine $5C6FBC TfRuinsTalk_ShowBusinessCenterInvestmentDialog }
procedure TfRuinsTalk.ShowBusinessCenterInvestmentDialog(Action: Integer);
const
  StationTypes = [Ord(rstRangerCenter)..Ord(rstDominion)];
var
  I, Index, BoundA, BoundB, BestScore, Score: Integer;
  Kind, Choice: Byte;
  Offers, Text, Name: WideString;
  Star, BestStar: TStar;
  Planet, BestPlanet: TPlanet;
begin
  Offers := '';
  ClearChoices;
  for Kind := Low(CoalitionProjectNames) to High(CoalitionProjectNames) do
  begin
    Choice := Kind;
    Text := '';
    BoundA := 1;
    BoundB := Galaxy.Stars.Count - 1;
    Index := SeededRandomIntRange(BoundA, BoundB, GetPlayer.DockedTo.Seed + Galaxy.GenerationSeed + Galaxy.CurrentTurn div 60 + 1743 + 731 * Kind);
    if GetPlayer.StationServiceLastUseTurns[Kind] <= Galaxy.CurrentTurn - StationServiceRepeatPeriods[Kind] then
    begin
      case Kind of
        cpCreateRangerCenter:
        begin
          if Galaxy.ShipTypeCounts[Ord(rstRangerCenter)] > Galaxy.CountFactionStars(Ord(sfCoalition)) * 0.33 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
            if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 7281) >= 0.6) and
               (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstRangerCenter)] <= 0) and
               (Star.Constellation.CountShipsByTypeMask(StationTypes) < Star.Constellation.Stars.Count) and
               (Star.ShipTypeCounts[Ord(rstRangerCenter)] <= 0) and (Star.CountShipsByTypeMask(StationTypes) <= 2) and
               (Star.ShipTypeCounts[stKling] <= 0) and
               (Star.ControlFaction = sfCoalition) and ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) and
               (Star.Status.CustomFaction = '') and (GetPlayer.CurrentStar <> Star) and
               (Star.DaysSincePlayerVisit >= 30) and Star.IsConstellationVisible then
            begin
              Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
                10 * Star.Constellation.ShipTypeCounts[Ord(rstRangerCenter)] - Star.CountShipsByTypeMask(StationTypes) -
                Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestStar := Star;
              end;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentRangerCenterStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1171 * (Kind + 13) + InvestmentRangerCenterStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpCreatePirateBase:
        begin
          if Galaxy.ShipTypeCounts[Ord(rstPirateBase)] > Galaxy.CountFactionStars(Ord(sfCoalition)) * 0.22 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
            if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 113223) >= 0.6) and
               (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstPirateBase)] <= 0) and
               (Star.Constellation.CountShipsByTypeMask(StationTypes) < Star.Constellation.Stars.Count) and
               (Star.ShipTypeCounts[Ord(rstPirateBase)] <= 0) and (Star.CountShipsByTypeMask(StationTypes) <= 1) and
               (Star.ShipTypeCounts[stKling] <= 0) and
               (Star.ControlFaction in [sfCoalition, sfPirates]) and
               (Star.Status.CustomFaction = '') and (GetPlayer.CurrentStar <> Star) and
               (Star.DaysSincePlayerVisit >= 30) and Star.IsConstellationVisible then
            begin
              Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
                10 * Star.Constellation.ShipTypeCounts[Ord(rstPirateBase)] - Star.CountShipsByTypeMask(StationTypes) -
                Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestStar := Star;
              end;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentPirateBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1171 * (Kind + 13) + InvestmentPirateBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpCreateMilitaryBase:
        begin
          if Galaxy.ShipTypeCounts[Ord(rstMilitaryBase)] > Galaxy.CountFactionStars(Ord(sfCoalition)) * 0.22 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
            if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 17823) >= 0.6) and
               (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstMilitaryBase)] <= 0) and
               (Star.Constellation.CountShipsByTypeMask(StationTypes) < Star.Constellation.Stars.Count) and
               (Star.ShipTypeCounts[Ord(rstMilitaryBase)] <= 0) and (Star.CountShipsByTypeMask(StationTypes) <= 1) and
               (Star.ShipTypeCounts[stKling] <= 0) and
               (Star.ControlFaction = sfCoalition) and ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) and
               (Star.Status.CustomFaction = '') and (GetPlayer.CurrentStar <> Star) and
               (Star.DaysSincePlayerVisit >= 30) and Star.IsConstellationVisible then
            begin
              Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
                10 * Star.Constellation.ShipTypeCounts[Ord(rstMilitaryBase)] - Star.CountShipsByTypeMask(StationTypes) -
                Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestStar := Star;
              end;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentMilitaryBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            3 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1171 * (Kind + 13) + InvestmentMilitaryBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpCreateScienceBase:
        begin
          if Galaxy.ShipTypeCounts[Ord(rstScienceBase)] > Galaxy.CountFactionStars(Ord(sfCoalition)) * 0.15 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
            if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 11123) >= 0.6) and
               (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstScienceBase)] <= 0) and
               (Star.Constellation.CountShipsByTypeMask(StationTypes) < Star.Constellation.Stars.Count) and
               (Star.ShipTypeCounts[Ord(rstScienceBase)] <= 0) and (Star.CountShipsByTypeMask(StationTypes) <= 1) and
               (Star.ShipTypeCounts[stKling] <= 0) and
               (Star.ControlFaction = sfCoalition) and ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) and
               (Star.Status.CustomFaction = '') and (GetPlayer.CurrentStar <> Star) and
               (Star.DaysSincePlayerVisit >= 30) and Star.IsConstellationVisible then
            begin
              Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
                10 * Star.Constellation.ShipTypeCounts[Ord(rstScienceBase)] - Star.CountShipsByTypeMask(StationTypes) -
                Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestStar := Star;
              end;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentScienceBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)),
            4 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1172 * (Kind + 13) + InvestmentScienceBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpCreateBusinessCenter:
        begin
          if Galaxy.ShipTypeCounts[Ord(rstBusinessCenter)] > Galaxy.CountFactionStars(Ord(sfCoalition)) * 0.1 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
            if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 9112323) >= 0.6) and
               (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstBusinessCenter)] <= 0) and
               (Star.Constellation.CountShipsByTypeMask(StationTypes) < Star.Constellation.Stars.Count) and
               (Star.ShipTypeCounts[Ord(rstBusinessCenter)] <= 0) and (Star.CountShipsByTypeMask(StationTypes) <= 1) and
               (Star.ShipTypeCounts[stKling] <= 0) and
               (Star.ControlFaction = sfCoalition) and ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) and
               (Star.Status.CustomFaction = '') and (GetPlayer.CurrentStar <> Star) and
               (Star.DaysSincePlayerVisit >= 30) and Star.IsConstellationVisible then
            begin
              Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
                10 * Star.Constellation.ShipTypeCounts[Ord(rstBusinessCenter)] - Star.CountShipsByTypeMask(StationTypes) -
                Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestStar := Star;
              end;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentBusinessCenterStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1173 * (Kind + 13) + InvestmentBusinessCenterStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpCreateMedicalBase:
        begin
          if Galaxy.ShipTypeCounts[Ord(rstMedicalBase)] > Galaxy.CountFactionStars(Ord(sfCoalition)) * 0.15 then Continue;
          BestStar := nil;
          BestScore := 0;
          for I := 1 to Galaxy.Stars.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
            if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 1123087) >= 0.6) and
               (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstMedicalBase)] <= 0) and
               (Star.Constellation.CountShipsByTypeMask(StationTypes) < Star.Constellation.Stars.Count) and
               (Star.ShipTypeCounts[Ord(rstMedicalBase)] <= 0) and (Star.CountShipsByTypeMask(StationTypes) <= 1) and
               (Star.ShipTypeCounts[stKling] <= 0) and
               (Star.ControlFaction = sfCoalition) and ((Star.Battle = 0) or (Star.CountPirateShips(False) <= 0)) and
               (Star.Status.CustomFaction = '') and (GetPlayer.CurrentStar <> Star) and
               (Star.DaysSincePlayerVisit >= 30) and Star.IsConstellationVisible then
            begin
              Score := Min(40, Star.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Star.GenerationSeed) -
                10 * Star.Constellation.ShipTypeCounts[Ord(rstMedicalBase)] - Star.CountShipsByTypeMask(StationTypes) -
                Round(PointDistance(GetPlayer.CurrentStar.Position, Star.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestStar := Star;
              end;
            end;
          end;
          if BestStar = nil then Continue;
          InvestmentMedicalBaseStar := BestStar;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1174 * (Kind + 13) + InvestmentMedicalBaseStar.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Star>', BestStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpRangersSubsidy:
        begin
          if Galaxy.CountEligibleRangers < 20 then Continue;
          if SeededRandomUnitFloat(Galaxy.CurrentTurn div 71 + GetPlayer.DockedTo.Seed + 16689) < 0.5 then Continue;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 4,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1123475 * (Kind + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpPiratesSubsidy:
        begin
          if SeededRandomUnitFloat(Galaxy.CurrentTurn div 71 + GetPlayer.DockedTo.Seed + 5789) < 0.7 then Continue;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 2,
            2 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1175234 * (Kind + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpTransportSubsidy:
        begin
          if SeededRandomUnitFloat(Galaxy.CurrentTurn div 71 + GetPlayer.DockedTo.Seed + 23739) < 0.5 then Continue;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)) div 4,
            Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 117627 * (Kind + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpLostSubsidy:
        begin
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)),
            4 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1177961 * (Kind + 13));
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
        end;
        cpWarSubsidy:
        begin
          BestPlanet := nil;
          BestScore := 0;
          BoundA := 0;
          BoundB := Galaxy.Planets.Count - 1;
          Index := SeededRandomIntRange(BoundA, BoundB, GetPlayer.DockedTo.Seed + Galaxy.GenerationSeed + Galaxy.CurrentTurn div 60 + 174313 + 73163 * Kind);
          for I := 0 to Galaxy.Planets.Count - 1 do
          begin
            IncrementWrapped(Index, BoundA, BoundB);
            Planet := Galaxy.Planets[Index];
            if Planet.IsCoalitionOwned and not Planet.IsMainPiratePlanet and
               (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Planet.GenerationSeed + Galaxy.CurrentTurn div 60 + 5889) >= 0.9) and
               (Planet.CurrentStar.ShipTypeCounts[stKling] <= 0) and (Planet.OwnerId <> Byte(oiPirate)) and
               ((Planet.CurrentStar.Battle = 0) or (Planet.CurrentStar.CountPirateShips(False) <= 0)) and
               (Planet.CurrentStar.DaysSincePlayerVisit >= 30) and Planet.CurrentStar.IsConstellationVisible then
            begin
              Score := Min(40, Planet.CurrentStar.DaysSincePlayerVisit) + 200 - SeededRandomIntRange(1, 50, Planet.GenerationSeed) -
                10 * Planet.Warriors.Count - Round(PointDistance(GetPlayer.CurrentStar.Position, Planet.CurrentStar.Position));
              if BestScore <= Score then
              begin
                BestScore := Score;
                BestPlanet := Planet;
              end;
            end;
          end;
          if BestPlanet = nil then Continue;
          InvestmentDefensePlanet := BestPlanet;
          StationServiceQuoteCost := SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)),
            5 * Galaxy.ComputeScaledHugeMoney(RaceToOwner(GetPlayer.PilotRace)), 1178 * (Kind + 13) + InvestmentDefensePlanet.GenerationSeed);
          Name := LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Name');
          ReplaceTextToken(Name, '<Planet>', BestPlanet.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Star>', BestPlanet.CurrentStar.Name, '<color=255,240,100>');
          ReplaceTextToken(Name, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
          Text := LocalizedColorText('FormRuins.BK.Investment.BKInvestment');
          ReplaceTextToken(Text, '<InvestmentFullName>', Name, '');
          if Offers = '' then Offers := Offers + Text
          else Offers := Offers + #13#10 + Text;
          if GetPlayer.Money >= StationServiceQuoteCost then
            AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Planet>', InvestmentDefensePlanet.Name), Choice, AcceptBusinessCenterInvestment)
          else AddChoice('- ' + FormatText1(LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.PlayerSend'), '<color=255,240,100>', '<Planet>', InvestmentDefensePlanet.Name), 0, ScriptDialogBlockCallback);
        end;
      end;
      InvestmentQuoteCosts[Kind] := StationServiceQuoteCost;
    end;
  end;
  DialogText := LocalizedColorText('FormRuins.BK.Investment.BK');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<BKInvestment>', Offers, '');
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Investment.PlayerNo'), 0, DeclineBusinessCenterInvestment);
end;
{ @end $5C6FBC }

{ @routine $5CA654 TfRuinsTalk_AcceptBusinessCenterInvestment }
procedure TfRuinsTalk.AcceptBusinessCenterInvestment(Action: Integer);
const
  RangerTypes = [htRanger];
  FriendlyTypes = [htRanger, htTransport..htDiplomat];
  PirateTypes = [htPirate];
  TransportTypes = [htRanger..15] - [htRanger..htPirate, htDiplomat..15];
var
  Kind: Byte;
  RangerCenter, PirateBase, MilitaryBase, ScienceBase, BusinessCenter, MedicalBase: TRuins;
  I, J, Experience, RankPoints, Count: Integer;
  Star: TStar;
  Ship: TShip;
  Ranger: TRanger;
  Warrior: TWarrior;
  Text, ShipNames: WideString;
begin
  Kind := Action;
  StationServiceQuoteCost := InvestmentQuoteCosts[Kind];
  GetPlayer.StationServiceLastUseTurns[Kind] := Galaxy.CurrentTurn;
  case Kind of
    cpCreateRangerCenter:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      RangerCenter := TRuins.Create;
      RangerCenter.Init(rstRangerCenter, InvestmentRangerCenterStar, '');
      Galaxy.AddPlanetNewsWithPlayerBubble(41, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.RC', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Name>', RangerCenter.GetName, '<Star>', RangerCenter.CurrentStar.Name, '<Sector>', RangerCenter.CurrentStar.Constellation.GetName));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Name>', RangerCenter.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', RangerCenter.CurrentStar.Name, '<color=255,240,100>');
      Experience := SeededRandomIntRange(1000, 1500, RangerCenter.Seed);
      GetPlayer.GainExperience(Experience, 0);
      ReplaceTextToken(DialogText, '<Point>', IntToStr(Experience), '<color=255,240,100>');
      Galaxy.UpdateConstellationMilitaryStats;
      GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 10, PlanetOwnerMasks.Coalition);
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 40, RangerTypes, PlanetOwnerMasks.Coalition);
      TryAddAchievementProgress('RUINS', 1);
    end;
    cpCreatePirateBase:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      PirateBase := TRuins.Create;
      PirateBase.Init(rstPirateBase, InvestmentPirateBaseStar, '');
      Galaxy.AddPlanetNewsWithPlayerBubble(41, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.PB', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Name>', PirateBase.GetName, '<Star>', PirateBase.CurrentStar.Name, '<Sector>', PirateBase.CurrentStar.Constellation.GetName));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Name>', PirateBase.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', PirateBase.CurrentStar.Name, '<color=255,240,100>');
      Galaxy.UpdateConstellationMilitaryStats;
      GetPlayer.ChangePlanetRelations(nil, rcmDecreaseWithFloor20, 30, [3, 4]);
      GetPlayer.ChangePlanetRelations(nil, rcmDecreaseWithFloor20, 10, [0, 2]);
      GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 20, [1]);
    end;
    cpCreateMilitaryBase:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      MilitaryBase := TRuins.Create;
      MilitaryBase.Init(rstMilitaryBase, InvestmentMilitaryBaseStar, '');
      Galaxy.AddPlanetNewsWithPlayerBubble(41, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.WB', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Name>', MilitaryBase.GetName, '<Star>', MilitaryBase.CurrentStar.Name, '<Sector>', MilitaryBase.CurrentStar.Constellation.GetName));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      if GetPlayer.OwnerId <> Byte(oiPirate) then
        ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '')
      else ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.TextAlt'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Name>', MilitaryBase.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', MilitaryBase.CurrentStar.Name, '<color=255,240,100>');
      if GetPlayer.OwnerId <> Byte(oiPirate) then
      begin
        RankPoints := SeededRandomIntRange(50, 200, MilitaryBase.Seed);
        GetPlayer.AddRankPoints(RankPoints);
        ReplaceTextToken(DialogText, '<Point>', IntToStr(RankPoints), '<color=255,240,100>');
      end;
      Galaxy.UpdateConstellationMilitaryStats;
      GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 30, PlanetOwnerMasks.Coalition);
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 10, FriendlyTypes, PlanetOwnerMasks.Coalition);
      GetPlayer.ChangeShipRelations(nil, rcmDecreaseWithFloor20, 30, PirateTypes, PlanetOwnerMasks.Coalition);
      TryAddAchievementProgress('RUINS', 1);
    end;
    cpCreateScienceBase:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      ScienceBase := TRuins.Create;
      ScienceBase.Init(rstScienceBase, InvestmentScienceBaseStar, '');
      Galaxy.AddPlanetNewsWithPlayerBubble(41, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.SB', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Name>', ScienceBase.GetName, '<Star>', ScienceBase.CurrentStar.Name, '<Sector>', ScienceBase.CurrentStar.Constellation.GetName));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Name>', ScienceBase.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', ScienceBase.CurrentStar.Name, '<color=255,240,100>');
      Galaxy.UpdateConstellationMilitaryStats;
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 25, RangerTypes, PlanetOwnerMasks.Coalition);
      TryAddAchievementProgress('RUINS', 1);
    end;
    cpCreateBusinessCenter:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      BusinessCenter := TRuins.Create;
      BusinessCenter.Init(rstBusinessCenter, InvestmentBusinessCenterStar, '');
      Galaxy.AddPlanetNewsWithPlayerBubble(41, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.BK', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Name>', BusinessCenter.GetName, '<Star>', BusinessCenter.CurrentStar.Name, '<Sector>', BusinessCenter.CurrentStar.Constellation.GetName));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Name>', BusinessCenter.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', BusinessCenter.CurrentStar.Name, '<color=255,240,100>');
      Galaxy.UpdateConstellationMilitaryStats;
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 30, TransportTypes, PlanetOwnerMasks.Coalition);
      TryAddAchievementProgress('RUINS', 1);
    end;
    cpCreateMedicalBase:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      MedicalBase := TRuins.Create;
      MedicalBase.Init(rstMedicalBase, InvestmentMedicalBaseStar, '');
      Galaxy.AddPlanetNewsWithPlayerBubble(41, FormatText3(PickLocalizedTextVariant('GalaxyNews.CreateNewObject.MC', Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Name>', MedicalBase.GetName, '<Star>', MedicalBase.CurrentStar.Name, '<Sector>', MedicalBase.CurrentStar.Constellation.GetName));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Name>', MedicalBase.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', MedicalBase.CurrentStar.Name, '<color=255,240,100>');
      Galaxy.UpdateConstellationMilitaryStats;
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 30, FriendlyTypes, PlanetOwnerMasks.Coalition);
      TryAddAchievementProgress('RUINS', 1);
    end;
    cpRangersSubsidy:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      Count := 0;
      for I := 1 to Galaxy.Rangers.Count - 1 do
      begin
        Ranger := Galaxy.Rangers[I];
        if (GetPlayer <> Ranger) and not Ranger.ExcludedFromRating and (Ranger.Wealth <= Galaxy.AverageRangerCapital) then
          Inc(Count);
      end;
      for I := 1 to Galaxy.Rangers.Count - 1 do
      begin
        Ranger := Galaxy.Rangers[I];
        if (GetPlayer <> Ranger) and not Ranger.ExcludedFromRating and (Ranger.Wealth <= Galaxy.AverageRangerCapital) then
          Ranger.SetMoney(Ranger.Money + Round(StationServiceQuoteCost / Count));
      end;
      Galaxy.AddPlanetNewsWithPlayerBubble(42, FormatText1(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Kind + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Money>', IntToStr(StationServiceQuoteCost)));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
    end;
    cpPiratesSubsidy:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      Count := Max(1, Galaxy.ShipTypeCounts[stPirate]);
      for I := 0 to Galaxy.Stars.Count - 1 do
      begin
        Star := Galaxy.Stars[I];
        for J := 0 to Star.Ships.Count - 1 do
        begin
          Ship := Star.Ships[J];
          if Ship.TypeId = stPirate then Ship.SetMoney(Ship.Money + StationServiceQuoteCost div Count);
        end;
      end;
      Galaxy.AddPlanetNewsWithPlayerBubble(42, FormatText2(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Kind + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Money>', IntToStr(StationServiceQuoteCost), '<BK>', GetPlayer.DockedTo.Name));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
    end;
    cpTransportSubsidy:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      Count := Max(1, Galaxy.ShipTypeCounts[stTransport]);
      for I := 0 to Galaxy.Stars.Count - 1 do
      begin
        Star := Galaxy.Stars[I];
        for J := 0 to Star.Ships.Count - 1 do
        begin
          Ship := Star.Ships[J];
          if Ship.TypeId = stTransport then Ship.SetMoney(Ship.Money + StationServiceQuoteCost div Count);
        end;
      end;
      Galaxy.AddPlanetNewsWithPlayerBubble(42, FormatText2(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Kind + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Money>', IntToStr(StationServiceQuoteCost), '<BK>', GetPlayer.DockedTo.Name));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
    end;
    cpLostSubsidy:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      Galaxy.AddPlanetNewsWithPlayerBubble(42, FormatText2(PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Kind + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed), '<color=255,240,100>',
        '<Money>', IntToStr(StationServiceQuoteCost), '<BK>', GetPlayer.DockedTo.Name));
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
      GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 30, PlanetOwnerMasks.Coalition);
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 20, FriendlyTypes, PlanetOwnerMasks.Coalition);
      GetPlayer.ChangeShipRelations(nil, rcmDecreaseWithFloor20, 20, PirateTypes, PlanetOwnerMasks.Coalition);
    end;
    cpWarSubsidy:
    begin
      GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
      Count := SeededRandomIntRange(4, 7, InvestmentDefensePlanet.GenerationSeed + Galaxy.CurrentTurn div 60);
      ShipNames := #13#10;
      for I := 1 to Count do
      begin
        Warrior := TObject(InvestmentDefensePlanet.BuyWarrior(100)) as TWarrior;
        Warrior.Name := Warrior.Name + ' ' + GetPlayer.Name;
        ShipNames := ShipNames + Warrior.GetName + #13#10;
      end;
      Text := PickLocalizedTextVariant('Investment.' + CoalitionProjectNames[Kind] + '.GalaxyMessage', Kind + Galaxy.CurrentTurn div 10 * GetPlayer.DockedTo.Seed);
      ReplaceTextToken(Text, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Count>', IntToStr(Count), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Planet>', InvestmentDefensePlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Star>', InvestmentDefensePlanet.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
      Galaxy.AddPlanetNewsWithPlayerBubble(42, Text);
      DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterInvestment');
      ReplaceTextToken(DialogText, '<InvestmentText>', LocalizedColorText('Investment.' + CoalitionProjectNames[Kind] + '.Text'), '');
      ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<ShipsName>', ShipNames, '');
      ReplaceTextToken(DialogText, '<Count>', IntToStr(Count), '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Planet>', InvestmentDefensePlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Star>', InvestmentDefensePlanet.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
      InvestmentDefensePlanet.ChangeRelationToRanger(GetPlayer, 100);
      GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 20, PlanetOwnerMasks.Coalition);
      GetPlayer.ChangeShipRelations(nil, rcmDecreaseWithFloor20, 30, PirateTypes, PlanetOwnerMasks.Coalition);
    end;
  end;
  M_Main(True);
end;
{ @end $5CA654 }

{ @routine $5CC734 TfRuinsTalk_DeclineBusinessCenterInvestment }
procedure TfRuinsTalk.DeclineBusinessCenterInvestment(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Investment.BKAfterPlayerNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5CC734 }

{ @routine $5CC850 TfRuinsTalk_ShowBusinessCenterTradeDialog }
procedure TfRuinsTalk.ShowBusinessCenterTradeDialog(Action: Integer);
var
  Discount: Byte;
begin
  DialogText := LocalizedColorText('FormRuins.BK.Trade.BK');
  NearbyTradeAdviceCost := RoundAndTruncateToTens(Min(GetPlayer.Money div 100,
    SeededRandomIntRange(Galaxy.ComputeScaledMiniMoney(2) div 2, 2 * Galaxy.ComputeScaledMiniMoney(2), Galaxy.GenerationSeed + Galaxy.CurrentTurn div 10)) + 30);
  DistantTradeAdviceCost := RoundAndTruncateToTens(SeededRandomIntRange(NearbyTradeAdviceCost div 3, NearbyTradeAdviceCost div 2,
    Galaxy.GenerationSeed + Galaxy.CurrentTurn div 10 + 1231341) + 10);
  Discount := Round(GetPlayer.CareerStatus[Ord(rcTrader)] / 1.3) + 1;
  NearbyTradeAdviceCost := Max(Int64(10), NearbyTradeAdviceCost - Round(NearbyTradeAdviceCost / 100 * Discount));
  DistantTradeAdviceCost := Max(Int64(5), DistantTradeAdviceCost - Round(DistantTradeAdviceCost / 100 * Discount));
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<NeaMoney>', IntToStr(NearbyTradeAdviceCost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<FarMoney>', IntToStr(DistantTradeAdviceCost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(Discount), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.Money >= NearbyTradeAdviceCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerNea'), '<color=255,240,100>', '<NeaMoney>', IntToStr(NearbyTradeAdviceCost)), 1, BuyBusinessCenterTradeAdvice)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerNea'), '<color=255,240,100>', '<NeaMoney>', IntToStr(NearbyTradeAdviceCost)), 0, ScriptDialogBlockCallback);
  if GetPlayer.Money >= DistantTradeAdviceCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerFar'), '<color=255,240,100>', '<FarMoney>', IntToStr(DistantTradeAdviceCost)), 2, BuyBusinessCenterTradeAdvice)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.BK.Trade.PlayerFar'), '<color=255,240,100>', '<FarMoney>', IntToStr(DistantTradeAdviceCost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.BK.Trade.PlayerNo'), 0, DeclineBusinessCenterTradeAdvice);
end;
{ @end $5CC850 }

{ @routine $5CD528 TfRuinsTalk_BuyBusinessCenterTradeAdvice }
procedure TfRuinsTalk.BuyBusinessCenterTradeAdvice(Action: Integer);
var
  Text: WideString;
  Count: Integer;
  Paths: WideString;
  Nearby, Found: Boolean;
  Dialog, Greeting, Panel: WideString;

  // @nested $5CCFE4 FindBusinessCenterTradeRoutes
  procedure FindBusinessCenterTradeRoutes; // @addr $5CCFE4 @ida "void __cdecl $name(void *ParentFrame);" @calls "0x5CD5F9"
  type
    TRoute = record
      FromPlanet, ToPlanet: TPlanet;
      GoodsIndex: Byte;
    end;
  var
    I, Attempts, J: Integer;
    GoodsMask: TItemTypeMask;
    Routes: array[1..3] of TRoute;
  begin
    GoodsMask := [Ord(t_Food)..Ord(t_Narcotics)];
    for I := Low(Routes) to High(Routes) do
    begin
      Routes[I].FromPlanet := nil;
      Routes[I].ToPlanet := nil;
    end;
    for I := Low(Routes) to High(Routes) do
    begin
      Attempts := 0;
      repeat
        Inc(Attempts);
        if Attempts > 100 then
        begin
          if I = Low(Routes) then
          begin
            Count := 0;
            Paths := '';
          end;
          Exit;
        end;
        Found := GetPlayer.FindProfitableTradeRoute(Nearby, AdvanceRandomSeed(Galaxy.RandomState) + Byte(Nearby), Routes[I].FromPlanet,
          Routes[I].ToPlanet, Routes[I].GoodsIndex, GoodsMask);
        for J := Low(Routes) to I - 1 do
          if Routes[I].GoodsIndex = Routes[J].GoodsIndex then Found := False;
      until Found;
      Exclude(GoodsMask, Routes[I].GoodsIndex);
      Inc(Count);
      Text := LocalizedColorText('FormRuins.BK.Trade.BKFindTradePath');
      ReplaceTextToken(Text, '<Num>', IntToStr(I), '');
      ReplaceTextToken(Text, '<Goods>', GoodsMarket[Routes[I].GoodsIndex].DisplayName, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromPlanet>', Routes[I].FromPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<FromStar>', Routes[I].FromPlanet.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Buy>', IntToStr(GetPlayer.ShopGoodsPurchasePrice(Routes[I].GoodsIndex, Routes[I].FromPlanet)), '<color=255,240,100>');
      ReplaceTextToken(Text, '<Cnt>', IntToStr(Routes[I].FromPlanet.Goods[Routes[I].GoodsIndex].Count), '<color=255,240,100>');
      ReplaceTextToken(Text, '<ToPlanet>', Routes[I].ToPlanet.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<ToStar>', Routes[I].ToPlanet.CurrentStar.Name, '<color=255,240,100>');
      ReplaceTextToken(Text, '<Sale>', IntToStr(GetPlayer.ShopGoodsSellPrice(Routes[I].GoodsIndex, Routes[I].ToPlanet)), '<color=255,240,100>');
      if Paths = '' then Paths := Text
      else Paths := Paths + #13#10 + Text;
    end;
  end;
begin
  Paths := '';
  Count := 0;
  if Action = 1 then Nearby := True else Nearby := False;
  if Nearby then Greeting := LocalizedColorText('FormRuins.BK.Trade.BKAfterOkNea')
  else Greeting := LocalizedColorText('FormRuins.BK.Trade.BKAfterOkFar');
  if Nearby then Panel := LocalizedColorText('FormRuins.BK.Trade.BKAfterOkNeaPanel')
  else Panel := LocalizedColorText('FormRuins.BK.Trade.BKAfterOkFarPanel');
  ReplaceTextToken(Panel, '<Date>', Galaxy.FormatTurnDate(Galaxy.CurrentTurn), '<color=0,255,0>');
  ReplaceTextToken(Panel, '<BK>', GetPlayer.DockedTo.Name, '<color=0,255,0>');
  FindBusinessCenterTradeRoutes;
  if Count = 0 then DialogText := Greeting + #13#10 + LocalizedColorText('FormRuins.BK.Trade.BKNotVariant')
  else
  begin
    Dialog := Greeting + #13#10 + LocalizedColorText('FormRuins.BK.Trade.BKAfterOk');
    ReplaceTextToken(Dialog, '<BKFindTradePath>', Paths, '');
    ReplaceTextToken(Dialog, '<Count>', IntToStr(Count), '<color=255,240,100>');
    DialogText := Dialog;
    if Action = 1 then GetPlayer.SetMoney(GetPlayer.Money - NearbyTradeAdviceCost)
    else GetPlayer.SetMoney(GetPlayer.Money - DistantTradeAdviceCost);
    SoundManager.PlaySound('Sound.Sell');
    AddOrUpdatePlayerBubble(7, Galaxy.CurrentTurn, Panel + #13#10 + Paths, '');
    MainPanel.RebuildMessageButtons(False);
  end;
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5CD528 }

{ @routine $5CDA30 TfRuinsTalk_DeclineBusinessCenterTradeAdvice }
procedure TfRuinsTalk.DeclineBusinessCenterTradeAdvice(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.BK.Trade.BKAfterNo');
  ReplaceTextToken(DialogText, '<BK>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5CDA30 }

{ @routine $5CDB38 TfRuinsTalk_ShowMedicalCenterIllnessTreatmentDialog }
procedure TfRuinsTalk.ShowMedicalCenterIllnessTreatmentDialog(Refresh: Integer);
var
  I, Cost, TotalCost, AllCost: Integer;
  Text, IllnessText, Key: WideString;
  HasDisease: Boolean;
begin
  if Refresh = 0 then
  begin
    if GetPlayer.OwnerId <> Byte(oiPirate) then DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSee')
    else DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeePirate');
  end;
  HasDisease := GetPlayer.HasPresentDisease;
  if HasDisease or GetPlayer.HasRadiationSickness then
  begin
    if Refresh = 0 then
    begin
      if HasDisease then
      begin
        if GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates then
          DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllness')
        else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllnessPirate');
      end
      else DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeCureless');
    end;
    ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
    TotalCost := 0;
    IllnessText := '';
    if HasDisease then
      for I := 1 to 12 do
      begin
        Text := '';
        if GetPlayer.CaptainHealth[I].Progress <> 0 then
        begin
          Text := LocalizedColorText('FormRuins.MC.Illnes.MCSeeIll');
          ReplaceTextToken(Text, '<IllName>', CaptainHealthDefinitions[I].Name, '<color=255,240,100>');
          if GetPlayer.CaptainHealth[I].Progress >= 100 then
            ReplaceTextToken(Text, '<MCSeeIllType>', LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllType1'), '')
          else
          begin
            ReplaceTextToken(Text, '<MCSeeIllType>', LocalizedColorText('FormRuins.MC.Illnes.MCSeeIllType2'), '');
            Inc(GetPlayer.CaptainHealth[I].ApplicationCount);
            GetPlayer.AchievementStats.CheckAllDiseasesAchievement;
          end;
          ReplaceTextToken(Text, '<Date>', Galaxy.FormatTurnDate(GetPlayer.CaptainHealth[I].AppliedTurn), '<color=255,240,100>');
          ReplaceTextToken(Text, '<InfectionObjectName>', GetPlayer.StatusEffectSourceNames[I], '<color=255,240,100>');
          Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledMiniMoney(GetPlayer.DockedTo.OwnerId), Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 10) * Galaxy.GenerationSeed * I);
          Inc(TotalCost, Cost);
          ReplaceTextToken(Text, '<Money>', IntToStr(Cost), '<color=255,240,100>');
          if IllnessText = '' then IllnessText := IllnessText + Text
          else IllnessText := IllnessText + #13#10 + Text;
        end;
      end;
    if GetPlayer.HasRadiationSickness then
    begin
      Text := LocalizedColorText('FormRuins.MC.Illnes.MCSeeRadiation');
      if IllnessText = '' then IllnessText := IllnessText + Text
      else IllnessText := IllnessText + #13#10 + Text;
    end;
    if Refresh = 0 then ReplaceTextToken(DialogText, '<MCSeeIll>', IllnessText, '');
    ClearChoices;
    if HasDisease then
    begin
      for I := 1 to 12 do
        if GetPlayer.CaptainHealth[I].Progress <> 0 then
        begin
          Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledMiniMoney(GetPlayer.DockedTo.OwnerId), Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 10) * Galaxy.GenerationSeed * I);
          if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates) then Cost := Cost div 2;
          if GetPlayer.Money >= Cost then
            AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Illnes.PlayerIll'), '<color=255,240,100>', '<IllName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), I, TreatSelectedDiseaseAtMedicalCenter)
          else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Illnes.PlayerIll'), '<color=255,240,100>', '<IllName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), 0, ScriptDialogBlockCallback);
        end;
      AllCost := TotalCost div 3 + Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId);
      if GetPlayer.Money >= AllCost then
        AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.MC.Illnes.PlayerIllAll'), '<color=255,240,100>', '<Money>', IntToStr(AllCost)), AllCost, TreatAllDiseasesAtMedicalCenter)
      else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.MC.Illnes.PlayerIllAll'), '<color=255,240,100>', '<Money>', IntToStr(AllCost)), 0, ScriptDialogBlockCallback);
      AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerNo'), 0, DeclineMedicalCenterTreatment);
    end
    else if GetPlayer.OwnerId <> Byte(oiPirate) then
      AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerExit'), 0, LeaveMedicalCenterTreatment)
    else AddChoice('- ' + LocalizedColorText('FormRuins.MC.Illnes.PlayerExitPirate'), 0, LeaveMedicalCenterTreatment);
  end
  else
  begin
    if Refresh = 0 then
    begin
      Key := 'FormRuins.MC.Illnes.MCSeeGood';
      if GetPlayer.DockedTo.CurrentStar.ControlFaction = sfPirates then Key := Key + 'PirateTo'
      else Key := Key + 'NormalTo';
      if GetPlayer.OwnerId = Byte(oiPirate) then Key := Key + 'Pirate'
      else Key := Key + 'Normal';
      DialogText := DialogText + #13#10 + LocalizedColorText(Key);
    end;
    ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
    M_Main(True);
  end;
end;
{ @end $5CDB38 }

{ @routine $5CEA24 TfRuinsTalk_TreatSelectedDiseaseAtMedicalCenter }
procedure TfRuinsTalk.TreatSelectedDiseaseAtMedicalCenter(DiseaseIndex: Integer);
var
  I, Cost: Integer;
  Name: WideString;
begin
  for I := 1 to 12 do
    if I = DiseaseIndex then
    begin
      if I = 3 then
      begin
        Galaxy.GraphDominatorSurfacesEnabled := True;
        Galaxy.DisableDominatorSurfaces;
      end;
      GetPlayer.CaptainHealth[I].Progress := 0;
      GetPlayer.StatusEffectSourceNames[I] := '';
      Name := CaptainHealthDefinitions[I].Name;
      Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledMiniMoney(GetPlayer.DockedTo.OwnerId), Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 10) * Galaxy.GenerationSeed * I);
      if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates) then Cost := Cost div 2;
      GetPlayer.SetMoney(GetPlayer.Money - Cost);
      GetPlayer.DiseaseImmunity := Min(100, GetPlayer.DiseaseImmunity + 40);
      SoundManager.PlaySound('Sound.Sell');
      Break;
    end;
  if GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates then
    DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIll')
  else DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIllPirate');
  if GetPlayer.HasRadiationSickness and not GetPlayer.HasPresentDisease then
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIllRadiation');
  ReplaceTextToken(DialogText, '<IllName>', Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ClearChoices;
  ShowMedicalCenterIllnessTreatmentDialog(1);
end;
{ @end $5CEA24 }

{ @routine $5CEE5C TfRuinsTalk_TreatAllDiseasesAtMedicalCenter }
procedure TfRuinsTalk.TreatAllDiseasesAtMedicalCenter(QuotedCost: Integer);
var
  I: Integer;
  Date: TDateTime;
  YearText: AnsiString;
begin
  DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterIllAll');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  Date := Now;
  DateTimeToString(YearText, 'yyyy', Date);
  ReplaceTextToken(DialogText, '<CurrentYear>', YearText, '<color=255,240,100>');
  for I := 1 to 12 do
    if GetPlayer.CaptainHealth[I].Progress <> 0 then
    begin
      if I = 3 then
      begin
        Galaxy.GraphDominatorSurfacesEnabled := True;
        Galaxy.DisableDominatorSurfaces;
      end;
      GetPlayer.CaptainHealth[I].Progress := 0;
      GetPlayer.StatusEffectSourceNames[I] := '';
    end;
  GetPlayer.SetMoney(GetPlayer.Money - QuotedCost);
  GetPlayer.DiseaseImmunity := Min(100, GetPlayer.DiseaseImmunity + 80);
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5CEE5C }

{ @routine $5CF0F4 TfRuinsTalk_DeclineMedicalCenterTreatment }
procedure TfRuinsTalk.DeclineMedicalCenterTreatment(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterNo');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5CF0F4 }

{ @routine $5CF204 TfRuinsTalk_LeaveMedicalCenterTreatment }
procedure TfRuinsTalk.LeaveMedicalCenterTreatment(Action: Integer);
begin
  if (GetPlayer.OwnerId = Byte(oiPirate)) and (GetPlayer.DockedTo.CurrentStar.ControlFaction = sfPirates) then DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterExitPirate')
  else DialogText := LocalizedColorText('FormRuins.MC.Illnes.MCSeeAfterExit');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5CF204 }

{ @routine $5CF3B0 TfRuinsTalk_ShowMedicalCenterStimulantDialog }
procedure TfRuinsTalk.ShowMedicalCenterStimulantDialog(Action: Integer);
var
  I, OfferCount, Cost, Duration, MaxStimulants, LawStimulants: Integer;
  Seed: Cardinal;
  Text, StimulantText, Key: WideString;
  Offers: set of 8..39;
  Rank: Byte;
  Bonus: Integer;
begin
  Offers := [];
  OfferCount := 0;
  Seed := Galaxy.GenerationSeed * (Galaxy.CurrentTurn div 13);
  if GetPlayer.DockedTo.CurrentStar.ControlFaction = sfPirates then Rank := GetPlayer.PirateRank
  else Rank := GetPlayer.Rank;
  while True do
  begin
    AdvanceRandomSeed(Seed);
    I := SeededRandomIntRange(13, 24, Seed);
    if not (I in Offers) and (SeededRandomUnitFloat(Seed) <= CaptainHealthDefinitions[I].InfectionChance) then
    begin
      Include(Offers, I);
      Inc(OfferCount);
      if OfferCount > Max(2, (Rank shr 1) + 1) then Break;
    end;
  end;
  Bonus := GetPlayer.GetTotalStatBonus(Ord(bonStimCapacity)) + GetPlayer.CountActiveArtefacts(Ord(t_ArtBio));
  MaxStimulants := Max(GetPlayer.CountActiveStimulants,
    Floor(SeededRandomFloatRange(Galaxy.CurrentTurn div 70 * GetPlayer.DockedTo.Id, 0, 1) *
      (Max(2, Max(2, Integer(Rank)) + Bonus) - 1)) + 2);
  LawStimulants := Max(2, Rank);
  DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MC1');
  if MaxStimulants < LawStimulants then
  begin
    DialogText := DialogText + '.' + #13#10;
    Key := 'FormRuins.MC.Stimulants.MC3';
  end
  else
  begin
    DialogText := DialogText + ' ';
    Key := 'FormRuins.MC.Stimulants.MC2';
  end;
  if GetPlayer.DockedTo.CurrentStar.ControlFaction = sfPirates then
  begin
    Key := Key + 'Pirate';
    if not GetPlayer.PirateClanReal then Key := Key + 'NoRank';
  end;
  DialogText := DialogText + LocalizedColorText(Key);
  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Stimulants.MC4');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<MaxStim>', IntToStr(MaxStimulants), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<CurStim>', IntToStr(GetPlayer.CountActiveStimulants), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<AddStim>', IntToStr(MaxStimulants - GetPlayer.CountActiveStimulants), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<LawStim>', IntToStr(LawStimulants), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Rank>', GetPlayer.GetRankName, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<PirateRank>', GetPlayer.GetPirateRankName, '<color=255,240,100>');
  if GetPlayer.CountActiveStimulants < MaxStimulants then
  begin
    StimulantText := '';
    for I := 13 to 24 do
      if I in Offers then
      begin
        Text := '';
        Text := LocalizedColorText('FormRuins.MC.Stimulants.MCStimInfo');
        ReplaceTextToken(Text, '<StimName>', CaptainHealthDefinitions[I].Name, '<color=255,240,100>');
        ReplaceTextToken(Text, '<StimText>', CaptainHealthDefinitions[I].Text, '');
        Duration := CaptainHealthDefinitions[I].Duration + SeededRandomIntRange(CaptainHealthDefinitions[I].Duration div 10,
    CaptainHealthDefinitions[I].Duration div 3, GetPlayer.DockedTo.Id + I + Galaxy.CurrentTurn div 13);
  Duration := Round(Duration / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
        ReplaceTextToken(Text, '<Month>', IntToStr(Duration div 30), '<color=255,240,100>');
        Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId), 2 * Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 13) * Galaxy.GenerationSeed * I);
        if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates) then Cost := Cost div 2;
        ReplaceTextToken(Text, '<Money>', IntToStr(Cost), '<color=255,240,100>');
        if StimulantText = '' then StimulantText := StimulantText + Text
        else StimulantText := StimulantText + #13#10 + Text;
      end;
    if GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates then
      DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Stimulants.MC5MedPolicy');
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.MC.Stimulants.MC5');
    ReplaceTextToken(DialogText, '<MCStimInfo>', StimulantText, '');
    ClearChoices;
    for I := 13 to 24 do
      if I in Offers then
      begin
        Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId), 2 * Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 13) * Galaxy.GenerationSeed * I);
        if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates) then Cost := Cost div 2;
        if (GetPlayer.Money < Cost) or (GetPlayer.CaptainHealth[I].Progress = 100) then
          AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Stimulants.PlayerStim'), '<color=255,240,100>', '<StimName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), 0, ScriptDialogBlockCallback)
        else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.MC.Stimulants.PlayerStim'), '<color=255,240,100>', '<StimName>', CaptainHealthDefinitions[I].Name, '<Money>', IntToStr(Cost)), I, BuySelectedStimulantAtMedicalCenter);
      end;
    AddChoice('- ' + LocalizedColorText('FormRuins.MC.Stimulants.PlayerNo'), 0, DeclineMedicalCenterStimulants);
  end
  else
  begin
    ClearChoices;
    M_Main(True);
  end;
end;
{ @end $5CF3B0 }

{ @routine $5D0280 TfRuinsTalk_BuySelectedStimulantAtMedicalCenter }
procedure TfRuinsTalk.BuySelectedStimulantAtMedicalCenter(StimulantIndex: Integer);
var
  I, Cost, Duration: Integer;
  Name: WideString;
begin
  for I := 13 to 24 do
    if I = StimulantIndex then
    begin
      GetPlayer.CaptainHealth[I].Progress := 100;
      GetPlayer.StatusEffectSourceNames[I] := '';
      Name := CaptainHealthDefinitions[I].Name;
      Duration := CaptainHealthDefinitions[I].Duration + SeededRandomIntRange(CaptainHealthDefinitions[I].Duration div 10,
    CaptainHealthDefinitions[I].Duration div 3, GetPlayer.DockedTo.Id + I + Galaxy.CurrentTurn div 13);
  Duration := Round(Duration / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor);
      GetPlayer.CaptainHealth[I].AppliedTurn := Galaxy.CurrentTurn;
      GetPlayer.CaptainHealth[I].ExpireTurn := Duration + Galaxy.CurrentTurn;
      Cost := GenerateValueForSizeLevel(CaptainHealthDefinitions[I].MedicalPriceSizeLevel, Galaxy.ComputeScaledSmallMoney(GetPlayer.DockedTo.OwnerId), 2 * Galaxy.ComputeScaledAverageMoney(GetPlayer.DockedTo.OwnerId), 50, (Galaxy.CurrentTurn div 13) * Galaxy.GenerationSeed * I);
      if (GetPlayer.MedicalPolicyTicks > 0) and (GetPlayer.DockedTo.CurrentStar.ControlFaction <> sfPirates) then Cost := Cost div 2;
      GetPlayer.SetMoney(GetPlayer.Money - Cost);
      GetPlayer.DiseaseImmunity := Max(0, GetPlayer.DiseaseImmunity - 20);
      Inc(GetPlayer.StimulantPurchaseCount);
      SoundManager.PlaySound('Sound.Sell');
      DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MCAfterPlayerStim');
      ReplaceTextToken(DialogText, '<StimName>', Name, '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<Date>', Galaxy.FormatTurnDate(GetPlayer.CaptainHealth[I].ExpireTurn), '<color=255,240,100>');
      ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
      Inc(GetPlayer.CaptainHealth[I].ApplicationCount);
      GetPlayer.AchievementStats.CheckAllDrugsAchievement;
      M_Main(True);
      Break;
    end;
end;
{ @end $5D0280 }

{ @routine $5D06B8 TfRuinsTalk_DeclineMedicalCenterStimulants }
procedure TfRuinsTalk.DeclineMedicalCenterStimulants(Action: Integer);
begin
  if GetPlayer.DockedTo.CurrentStar.ControlFaction = sfPirates then DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MCAfterPlayerNoPirate')
  else DialogText := LocalizedColorText('FormRuins.MC.Stimulants.MCAfterPlayerNo');
  ReplaceTextToken(DialogText, '<MC>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5D06B8 }

{ @routine $5D086C TfRuinsTalk_ShowStationSpecialShipDialog }
procedure TfRuinsTalk.ShowStationSpecialShipDialog(Action: Integer);
var
  CanBuy: Boolean;
  Price: Integer;
  Hull: THull;
  I, CompletedQuests: Integer;
  Quest: PPlayerOldQuest;
begin
  CanBuy := True;
  Hull := THull.Create;
  if GetPlayer.DockedTo.TypeId = Byte(rstPirateBase) then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, 9, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullPB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase) then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, 9, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullWB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = Byte(rstScienceBase) then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, 9, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullSB'), Hull);
  end
  else RaiseWideMessage('Ask special ship');
  Price := Hull.GetConditionAdjustedCost;
  Hull.Free;
  DialogText := LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Info');
  if GetPlayer.DockedTo.TypeId = Byte(rstPirateBase) then
  begin
  ReplaceTextToken(DialogText, '<KillCnt>', IntToStr(100), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Price>', IntToStr(Price), '<color=255,240,100>');
  if GetPlayer.CivilianKillCount < 100 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<KillComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<KillComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  if GetPlayer.GetDominantCareer <> rcPirate then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<PirateComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<PirateComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  if GetPlayer.Rank < 5 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<RankComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<RankComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  end
  else if GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase) then
  begin
  ReplaceTextToken(DialogText, '<KillCnt>', IntToStr(50), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Price>', IntToStr(Price), '<color=255,240,100>');
  if GetPlayer.PirateKillCount < 50 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<KillComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<KillComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  if GetPlayer.GetDominantCareer <> rcWarrior then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<WarriorComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<WarriorComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  if GetPlayer.Rank < 5 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<RankComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<RankComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  end
  else if GetPlayer.DockedTo.TypeId = Byte(rstScienceBase) then
  begin
  ReplaceTextToken(DialogText, '<KillCnt>', IntToStr(500), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Price>', IntToStr(Price), '<color=255,240,100>');
  if GetPlayer.DominatorKillCount < 500 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<KillComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<KillComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  if GetPlayer.Rank < 5 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<RankComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<RankComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  CompletedQuests := 0;
  for I := 0 to PlayerOldQuests.Count - 1 do
  begin
    Quest := PlayerOldQuests[I];
    if Quest.Successful then Inc(CompletedQuests);
  end;
  ReplaceTextToken(DialogText, '<QuestCnt>', IntToStr(20), '<color=255,240,100>');
  if CompletedQuests < 20 then
  begin
    CanBuy := False;
    ReplaceTextToken(DialogText, '<QuestComplate>', '', '');
  end
  else ReplaceTextToken(DialogText, '<QuestComplate>', LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.Complate'), '<color=255,240,100>');
  end
  else RaiseWideMessage('Ask special ship 2');
  ClearChoices;
  if CanBuy and (GetPlayer.Money >= Price) then
    AddChoice('- ' + LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.PlayerBuy'), 0, BuyStationSpecialShip);
  AddChoice('- ' + LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.PlayerNo'), 0, DeclineStationSpecialShip);
end;
{ @end $5D086C }

{ @routine $5D1500 TfRuinsTalk_DeclineStationSpecialShip }
procedure TfRuinsTalk.DeclineStationSpecialShip(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.AfterNo');
  M_Main(True);
end;
{ @end $5D1500 }

{ @routine $5D15E0 TfRuinsTalk_BuyStationSpecialShip }
procedure TfRuinsTalk.BuyStationSpecialShip(Action: Integer);
const
  RelationShipTypes = [htRanger, htPirate..htDiplomat];
  PirateOwners = [1];
  CoalitionOwners = [0, 2..4];
var
  Price: Integer;
  Hull: THull;
begin
  (GetPlayer.DockedTo as TRuins).SpecialServiceActive := False;
  Hull := THull.Create;
  if GetPlayer.DockedTo.TypeId = Byte(rstPirateBase) then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, 9, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullPB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = Byte(rstMilitaryBase) then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, 9, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullWB'), Hull);
  end
  else if GetPlayer.DockedTo.TypeId = Byte(rstScienceBase) then
  begin
    Hull.Init(1000, 8, GetPlayer.DockedTo.OwnerId, 9, -1, False);
    ApplySpecialMicroModule(FindMicroModuleTemplateByCustomTag('SuperHullSB'), Hull);
  end
  else RaiseWideMessage('Buy special ship');
  Price := Hull.GetConditionAdjustedCost;
  if GetPlayer.Money >= Price then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Price);
    if GetPlayer.IsOnPlanet then GetPlayer.AddItemToPlayerStorage(Hull, GetPlayer.CurrentPlanet, -1)
    else GetPlayer.AddItemToPlayerStorage(Hull, GetPlayer.DockedTo, -1);
    if GetPlayer.DockedTo.TypeId = Byte(rstPirateBase) then
    begin
      GetPlayer.ChangePlanetRelations(nil, rcmIncrease, 30, [1]);
      GetPlayer.ChangeShipRelations(nil, rcmIncrease, 30, RelationShipTypes, PirateOwners);
      GetPlayer.ChangePlanetRelations(nil, rcmDecreaseWithFloor20, 50, [0, 2, 3, 4]);
      GetPlayer.ChangeShipRelations(nil, rcmDecreaseWithFloor20, 50, RelationShipTypes, CoalitionOwners);
    end;
  end
  else Hull.Free;
  DialogText := LocalizedColorText('FormRuins.' + GetPlayer.DockedTo.GetTypeNameKey + '.SpecialShip.AfterBuy');
  M_Main(True);
end;
{ @end $5D15E0 }

{ @routine $5D1948 TfRuinsTalk_RunInjectedDialog }
procedure TfRuinsTalk.RunInjectedDialog(Action: Integer);
var
  Injection: PScriptDialogInjection;
  Text: WideString;
  Parts: Integer;
begin
  Injection := PScriptDialogInjection(Action);
  if Injection.ActionCode <> '' then
  begin
    CurrentScript := Injection.ActionScript;
    ExecuteScriptText(Injection.ActionCode, CurrentScript.InitCode.LocalVar);
  end;
  Text := Injection.Answer;
  Parts := CountDelimitedPartsW(Text, '~');
  if Parts > 1 then
  begin
    Text := ExtractDelimitedPartW(LowerCase(Text), 0, '~');
    if Text = 'snap' then RememberChoiceScroll;
  end;
  ClearChoices;
  Injection.Script.PublishCurrentShip(GetPlayer.DockedTo);
  CurrentScript.InitCode.LocalVar.GetVar('GAnswerData').SetDword(Injection.AnswerData);
  ScriptDialogIndex := -1;
  CurrentScript.CallDialogByVariable(Injection.DialogName);
  if ScriptDialogIndex < 0 then M_Main(True)
  else CurrentScript.CallDialogMessage(ScriptDialogIndex);
end;
{ @end $5D1948 }

{ @routine $5D1B14 TfRuinsTalk_RunInjectedDialogKeepingScroll }
procedure TfRuinsTalk.RunInjectedDialogKeepingScroll(Action: Integer);
begin
  RememberChoiceScroll;
  RunInjectedDialog(Action);
end;
{ @end $5D1B14 }

{ @routine $5D1B38 TfRuinsTalk_RunScriptRestart }
procedure TfRuinsTalk.RunScriptRestart(Answer: Integer);
begin
  DialogText := '';
  CurrentScript.ExecuteDialogAnswer(Answer);
  M_Main(False);
end;
{ @end $5D1B38 }

{ @routine $5D1B70 TfRuinsTalk_AddScriptRestartChoice }
procedure TfRuinsTalk.AddScriptRestartChoice(Caption: WideString);
begin
  AddChoice('- ' + Caption, CurrentScript.CurrentAnswer, RunScriptRestart);
end;
{ @end $5D1B70 }

{ @routine $5D1BF8 TfRuinsTalk_CloseRuinsMode }
procedure TfRuinsTalk.CloseRuinsMode(Sender: TObjectGI);
begin
  GetPlayer.CloseRuinsModeScreen;
end;
{ @end $5D1BF8 }

{ @routine $5D1C14 GetConstructionShopCost }
function GetConstructionShopCost: Integer;
var
  J: Integer;
  Kind: Byte;
begin
  Result := 0;
  for Kind := 42 to 49 do
    if (ConstructionEquipment[Kind].Item <> nil) and (ConstructionEquipment[Kind].Source = 2) then
      Inc(Result, ConstructionEquipment[Kind].Item.Cost);
  for J := 1 to 5 do
    if (ConstructionWeapons[J].Item <> nil) and (ConstructionWeapons[J].Source = 2) then
      Inc(Result, ConstructionWeapons[J].Item.Cost);
end;
{ @end $5D1C14 }

{ @routine $5D1CA0 GetConstructionFreeSpace }
function GetConstructionFreeSpace: Integer;
var
  J: Integer;
  Kind: Byte;
begin
  Result := 0;
  for Kind := 42 to 49 do
    if ConstructionEquipment[Kind].Item <> nil then
      if Kind = 42 then Inc(Result, ConstructionEquipment[Kind].Item.Weight)
      else Dec(Result, ConstructionEquipment[Kind].Item.Weight);
  for J := 1 to 5 do
    if ConstructionWeapons[J].Item <> nil then Dec(Result, ConstructionWeapons[J].Item.Weight);
end;
{ @end $5D1CA0 }

{ @routine $5D230C TfRuinsTalk_BuildConstructionItemChoices }
function TfRuinsTalk.BuildConstructionItemChoices(Kind: Byte): Integer;
var
  I, Count: Integer;
  Slot: TShopSlot;
  Item: TEquipment;
  Text: WideString;
  Entry: PStorageEntry;

  // @nested $5D1D28 IsConstructionItemEligible
  function IsConstructionItemEligible(Item: TEquipment): Boolean; // @addr $5D1D28 @calls "0x5D2389 0x5D2492 0x5D258B"
  var
    I: Integer;
  begin
    Result := False;
    if (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '') then Exit;
    if (Kind in [Ord(t_Weapon1)..Ord(t_CustomWeapon)]) and not (Byte(Item.ItemType) in [Ord(t_Weapon1)..Ord(t_CustomWeapon)]) then Exit;
    if not (Kind in [Ord(t_Weapon1)..Ord(t_CustomWeapon)]) and (Kind <> Byte(Item.ItemType)) then Exit;
    if Kind = 42 then
    begin
      if not (THull(Item).HullType in [htPirate, htSpecial]) or (THull(Item).GetSlotCount(sskCargoHook) < 1) or (THull(Item).CapitalShip <> 0) then Exit;
      if THull(Item).HullType = htSpecial then
      begin
        if Item.SpecialModuleIndex = 0 then Exit;
        if not (GetPlayer.DockedTo.TypeId in MicroModuleTemplates[Item.SpecialModuleIndex - 1].OfferStationTypes) then Exit;
      end
      else if not (Item.OwnerId in PlanetOwnerMasks.Coalition) then Exit;
    end;
    if Kind in [Ord(t_Weapon1)..Ord(t_CustomWeapon)] then
      for I := 1 to 5 do
        if ConstructionWeapons[I].Item = Item then Exit;
    Result := True;
  end;
  // @nested $5D1E58 FormatConstructionItem
  procedure FormatConstructionItem(var Text: WideString; Item: TEquipment); // @addr $5D1E58 @calls "0x5D23AB 0x5D24B4 0x5D25AD"
  var
    Stats: WideString;
  begin
    ReplaceTextToken(Text, '<ItemName>', RemoveTextTagsW(Item.GetDisplayName), '<color=255,240,100>');
    ReplaceTextToken(Text, '<Size>', IntToStr(Item.Weight), '<color=255,240,100>');
    ReplaceTextToken(Text, '<Cost>', IntToStr(Item.Cost), '<color=255,240,100>');
    if Item is TWeapon then Stats := LocalizedColorText('FormRuins.CB.ConstructPirate.StatsWeapon')
    else Stats := LocalizedColorText('FormRuins.CB.ConstructPirate.Stats' + ItemTypeNames[Byte(Item.ItemType)]);
    Item.ReplaceInfoTokens(Stats, '<color=255,240,100>', nil);
    if (Item is THull) and (THull(Item).HullSeries <> -1) then
    begin
      Stats := Stats + ', ' + LocalizedColorText('FormRuins.CB.ConstructPirate.StatsSeries');
      ReplaceTextToken(Stats, '<SeriesName>', '"' + HullSeriesDefinitions[THull(Item).HullSeries].Name + '"', '<color=255,240,100>');
    end;
    if (Item is TWeapon) and (Item.SpecialModuleIndex > 0) then
    begin
      Stats := Stats + ', ' + LocalizedColorText('FormRuins.CB.ConstructPirate.StatsSeries');
      ReplaceTextToken(Stats, '<SeriesName>', Item.GetSpecialModuleName, '<color=255,240,100>');
    end;
    ReplaceTextToken(Text, '<Stats>', Stats, '');
    Text := ReplaceAllWideString(Text, '<color=255,240,100>', '<color=0,50,200>');
    Text := ReplaceAllWideString(Text, '<color=0,255,0>', '<color=0,130,0>');
  end;

begin
  Count := 0;
  if Kind <> 42 then
    for I := 0 to GetPlayer.Inventory.Count - 1 do
    begin
      Item := GetPlayer.Inventory[I];
      if (Item.EquippedFlag = 0) and IsConstructionItemEligible(Item) then
      begin
        Text := LocalizedColorText('FormRuins.CB.ConstructPirate.InHold');
        FormatConstructionItem(Text, Item);
        if (Kind <> 42) and (GetConstructionFreeSpace - Item.Weight < 0) then
          AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
        else AddChoice('- ' + Text, Integer(Item), SelectConstructionHeldItem);
        Inc(Count);
      end;
    end;
  for I := 0 to GetPlayer.StorageEntries.Count - 1 do
  begin
    Entry := GetPlayer.StorageEntries[I];
    if GetPlayer.DockedTo = Entry.LocationOwner then
      if (Entry <> nil) and (Entry.Item <> nil) then
      begin
        Item := TEquipment(Entry.Item);
        if IsConstructionItemEligible(Item) then
        begin
          Text := LocalizedColorText('FormRuins.CB.ConstructPirate.InStorage');
          FormatConstructionItem(Text, Item);
          if (Kind <> 42) and (GetConstructionFreeSpace - Item.Weight < 0) then
            AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
          else AddChoice('- ' + Text, Integer(Item), SelectConstructionStoredItem);
          Inc(Count);
        end;
      end;
  end;
  if TemporaryShopSlots <> nil then
    for I := 0 to TemporaryShopSlots.Count - 1 do
    begin
      Slot := TemporaryShopSlots[I];
      if Slot <> nil then
      begin
        Item := TEquipment(Slot.Item);
        if (Item <> nil) and IsConstructionItemEligible(Item) then
        begin
          Text := LocalizedColorText('FormRuins.CB.ConstructPirate.InShop');
          FormatConstructionItem(Text, Item);
          if Item.Cost + GetConstructionShopCost > GetPlayer.Money then
            AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
          else if (Kind <> 42) and (GetConstructionFreeSpace - Item.Weight < 0) then
            AddChoice('- ' + Text, 0, ScriptDialogBlockCallback)
          else AddChoice('- ' + Text, Integer(Item), SelectConstructionShopItem);
          Inc(Count);
        end;
      end;
    end;
  if not (Kind in [42..44, 48]) and ((Kind <> 50) or (ConstructionWeapons[1].Item <> nil)) then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.skip'), 0, SkipConstructionItem);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.cancel'), 0, DeclineDominionShipConstruction);
  Result := Count;
end;
{ @end $5D230C }

{ @routine $5D28B0 TfRuinsTalk_ShowDominionShipConstructionDialog }
procedure TfRuinsTalk.ShowDominionShipConstructionDialog(Action: Integer);
var
  J: Integer;
  Kind: Byte;
begin
  ClearChoices;
  for Kind := 42 to 49 do ConstructionEquipment[Kind].Item := nil;
  for J := 1 to 5 do ConstructionWeapons[J].Item := nil;
  if GetPlayer.GetMaxDominionShips <= GetPlayer.PiratePartners.Count then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.WarningPirateCnt');
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.WarningConfirm'), 0, ConfirmDominionConstructionLimit);
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.cancel'), 0, DeclineDominionShipConstruction);
  end
  else
  begin
    BuildConstructionItemChoices(42);
    DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.PickHull');
  end;
end;
{ @end $5D28B0 }

{ @routine $5D2B6C TfRuinsTalk_ConfirmDominionConstructionLimit }
procedure TfRuinsTalk.ConfirmDominionConstructionLimit(Action: Integer);
begin
  ClearChoices;
  BuildConstructionItemChoices(42);
  DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.PickHull');
end;
{ @end $5D2B6C }

{ @routine $5D2C2C TfRuinsTalk_DeclineDominionShipConstruction }
procedure TfRuinsTalk.DeclineDominionShipConstruction(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.Cancelled');
  M_Main(True);
end;
{ @end $5D2C2C }

{ @routine $5D2CE8 SelectConstructionItem }
procedure SelectConstructionItem(Item: TEquipment; Source: Byte);
var
  I: Integer;
begin
  if Item.ItemType in [t_Hull..t_DefGenerator] then
  begin
    ConstructionEquipment[Byte(Item.ItemType)].Item := Item;
    ConstructionEquipment[Byte(Item.ItemType)].Source := Source;
  end
  else if Item is TWeapon then
  begin
    I := 1;
    while (I <= 5) and (ConstructionWeapons[I].Item <> nil) do Inc(I);
    if I <= 5 then
    begin
      ConstructionWeapons[I].Item := Item;
      ConstructionWeapons[I].Source := Source;
    end;
  end;
end;
{ @end $5D2CE8 }

{ @routine $5D2D7C TfRuinsTalk_SelectConstructionHeldItem }
procedure TfRuinsTalk.SelectConstructionHeldItem(Action: Integer);
begin
  SelectConstructionItem(TEquipment(Action), 0);
  ContinueDominionConstruction(RemoveTextTagsW(TEquipment(Action).GetDisplayName));
end;
{ @end $5D2D7C }

{ @routine $5D2DF0 TfRuinsTalk_SelectConstructionStoredItem }
procedure TfRuinsTalk.SelectConstructionStoredItem(Action: Integer);
begin
  SelectConstructionItem(TEquipment(Action), 1);
  ContinueDominionConstruction(RemoveTextTagsW(TEquipment(Action).GetDisplayName));
end;
{ @end $5D2DF0 }

{ @routine $5D2E64 TfRuinsTalk_SelectConstructionShopItem }
procedure TfRuinsTalk.SelectConstructionShopItem(Action: Integer);
begin
  SelectConstructionItem(TEquipment(Action), 2);
  ContinueDominionConstruction(RemoveTextTagsW(TEquipment(Action).GetDisplayName));
end;
{ @end $5D2E64 }

{ @routine $5D2ED8 TfRuinsTalk_SkipConstructionItem }
procedure TfRuinsTalk.SkipConstructionItem(Action: Integer);
begin
  ContinueDominionConstruction('');
end;
{ @end $5D2ED8 }

{ @routine $5D2EF4 TfRuinsTalk_AppendConstructionItemList }
procedure TfRuinsTalk.AppendConstructionItemList;
var
  I: Integer;
  Kind: Byte;
  Item: TEquipment;
  Text: WideString;
begin
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.ItemList');
  Text := '';
  for Kind := 42 to 49 do
  begin
    Item := ConstructionEquipment[Kind].Item;
    if Item <> nil then
      Text := Text + Item.GetShortName + ' - ' + RemoveTextTagsW(Item.GetDisplayName) + #13#10
    else
    begin
      Text := Text + LocalizedText('Items.' + ItemTypeNames[Kind] + '.ShortName') + ' - ';
      if THull(ConstructionEquipment[42].Item).GetSlotCount(ItemTypeToSlotKind(Kind)) > 0 then
        Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotInstalled') + #13#10
      else Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotAvailable') + #13#10;
    end;
  end;
  for I := 1 to 5 do
  begin
    Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.weaponN') + IntToStr(I) + ' - ';
    Item := ConstructionWeapons[I].Item;
    if Item <> nil then Text := Text + RemoveTextTagsW(Item.GetDisplayName) + #13#10
    else if THull(ConstructionEquipment[42].Item).GetSlotCount(sskWeapon) >= I then
      Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotInstalled') + #13#10
    else Text := Text + LocalizedColorText('FormRuins.CB.ConstructPirate.NotAvailable') + #13#10;
  end;
  ReplaceTextToken(DialogText, '<ItemList>', Text, '');
  ReplaceTextToken(DialogText, '<TotalCost>', IntToStr(GetConstructionShopCost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<FreeSpace>', IntToStr(GetConstructionFreeSpace), '<color=255,240,100>');
end;
{ @end $5D2EF4 }

{ @routine $5D3444 TfRuinsTalk_ContinueDominionConstruction }
procedure TfRuinsTalk.ContinueDominionConstruction(PreviousItem: WideString);
var
  CanAdd: Boolean;
  Hull: THull;
begin
  if PreviousItem <> '' then DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.AddedEq')
  else DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.AddedNothing');
  ReplaceTextToken(DialogText, '<PrevItem>', PreviousItem, '<color=255,240,100>');
  AppendConstructionItemList;
  ClearChoices;
  if ConstructionEquipment[44].Item = nil then
  begin
    BuildConstructionItemChoices(44);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickEngine');
  end
  else if ConstructionEquipment[43].Item = nil then
  begin
    BuildConstructionItemChoices(43);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickFuelTanks');
  end
  else if ConstructionEquipment[48].Item = nil then
  begin
    BuildConstructionItemChoices(48);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickCargoHook');
  end
  else if ConstructionWeapons[1].Item = nil then
  begin
    BuildConstructionItemChoices(50);
    DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickWeapon');
  end
  else
  begin
    CanAdd := False;
    Hull := THull(ConstructionEquipment[42].Item);
    if ConstructionWeapons[Hull.GetSlotCount(sskWeapon)].Item = nil then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddWeapon'), 0, PickConstructionWeapon);
    end;
    if (Hull.GetSlotCount(sskRadar) > 0) and (ConstructionEquipment[45].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddRadar'), 0, PickConstructionRadar);
    end;
    if (Hull.GetSlotCount(sskScanner) > 0) and (ConstructionEquipment[46].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddScaner'), 0, PickConstructionScanner);
    end;
    if (Hull.GetSlotCount(sskRepairRobot) > 0) and (ConstructionEquipment[47].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddRepairRobot'), 0, PickConstructionRepairRobot);
    end;
    if (Hull.GetSlotCount(sskDefGenerator) > 0) and (ConstructionEquipment[49].Item = nil) then
    begin
      CanAdd := True;
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.AddDefGenerator'), 0, PickConstructionDefGenerator);
    end;
    if CanAdd then DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.ReadyCanAddMore')
    else DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.ReadyCanNotAddMore');
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.confirm'), 0, CompleteDominionConstruction);
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.ConstructPirate.cancel'), 0, DeclineDominionShipConstruction);
  end;
end;
{ @end $5D3444 }

{ @routine $5D3E28 TfRuinsTalk_PickConstructionWeapon }
procedure TfRuinsTalk.PickConstructionWeapon(Action: Integer);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(50);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickWeapon');
end;
{ @end $5D3E28 }

{ @routine $5D3F24 TfRuinsTalk_PickConstructionRadar }
procedure TfRuinsTalk.PickConstructionRadar(Action: Integer);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(45);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickRadar');
end;
{ @end $5D3F24 }

{ @routine $5D4020 TfRuinsTalk_PickConstructionScanner }
procedure TfRuinsTalk.PickConstructionScanner(Action: Integer);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(46);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickScaner');
end;
{ @end $5D4020 }

{ @routine $5D411C TfRuinsTalk_PickConstructionRepairRobot }
procedure TfRuinsTalk.PickConstructionRepairRobot(Action: Integer);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(47);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickRepairRobot');
end;
{ @end $5D411C }

{ @routine $5D4224 TfRuinsTalk_PickConstructionDefGenerator }
procedure TfRuinsTalk.PickConstructionDefGenerator(Action: Integer);
begin
  DialogText := '';
  AppendConstructionItemList;
  ClearChoices;
  BuildConstructionItemChoices(49);
  DialogText := DialogText + #13#10 + #13#10 + LocalizedColorText('FormRuins.CB.ConstructPirate.PickDefGenerator');
end;
{ @end $5D4224 }

{ @routine $5D4428 TfRuinsTalk_CompleteDominionConstruction }
procedure TfRuinsTalk.CompleteDominionConstruction(Action: Integer);
var
  Ship: TPirate;
  Planet: TPlanet;
  TotalCost, Price: Integer;
  Kind: Byte;
  J, Months: Integer;
  Item: TEquipment;
  // @nested $5D432C RemoveConstructionStoredItem
  procedure RemoveConstructionStoredItem(Item: TEquipment); // @addr $5D432C @calls "0x5D4540 0x5D45F7"
  var
    I: Integer;
    Entry: PStorageEntry;
  begin
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := GetPlayer.StorageEntries[I];
      if (Entry <> nil) and (Entry.Item = Item) then
      begin
        GetPlayer.StorageEntries.Delete(I);
        GetPlayer.RefreshStorageBubbles;
        Dispose(Entry);
        Break;
      end;
    end;
  end;

  // @nested $5D43B4 RemoveConstructionShopItem
  procedure RemoveConstructionShopItem(Item: TEquipment); // @addr $5D43B4 @calls "0x5D454C 0x5D4603"
  var
    Station: TRuins;
  begin
    if TemporaryShopSlots <> nil then
    begin
      RestoreTemporaryShopStock;
      Station := TRuins(GetPlayer.DockedTo);
      Station.EquipmentShop.Delete(Station.EquipmentShop.IndexOf(Item));
      BuildTemporaryShopSlotGrid;
      EquipmentShopScreen.ClearGoodsControls;
      EquipmentShopScreen.BuildGoodsControls;
      EquipmentShopScreen.UpdateScrollButtons;
    end;
  end;

begin
  Price := GetConstructionShopCost;
  if Price > 0 then
  begin
    GetPlayer.SetMoney(Max(0, GetPlayer.Money - Price));
    SoundManager.PlaySound('Sound.Sell');
  end;
  Ship := TPirate.Create;
  Planet := GetPlayer.DockedTo.CurrentStar.SelectRandomInhabitedPlanet;
  TotalCost := 0;
  for Kind := 42 to 49 do
    if ConstructionEquipment[Kind].Item <> nil then
    begin
      Item := ConstructionEquipment[Kind].Item;
      if ConstructionEquipment[Kind].Source = 0 then
        GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(Item))
      else if ConstructionEquipment[Kind].Source = 1 then RemoveConstructionStoredItem(Item)
      else RemoveConstructionShopItem(Item);
      Ship.Inventory.Add(Item);
      Ship.EquipItem(Item);
      Inc(TotalCost, ConstructionEquipment[Kind].Item.Cost);
    end;
  for J := 1 to 5 do
    if ConstructionWeapons[J].Item <> nil then
    begin
      Item := ConstructionWeapons[J].Item;
      if ConstructionWeapons[J].Source = 0 then
        GetPlayer.Inventory.Delete(GetPlayer.Inventory.IndexOf(Item))
      else if ConstructionWeapons[J].Source = 1 then RemoveConstructionStoredItem(Item)
      else RemoveConstructionShopItem(Item);
      Ship.Inventory.Add(Item);
      Ship.EquipItem(Item);
      Inc(TotalCost, ConstructionWeapons[J].Item.Cost);
    end;
  Ship.InitGenerated(Planet, TotalCost div 10 + 1000, 0);
  Ship.DockedTo := GetPlayer.DockedTo;
  Ship.TrainSkillsAutomatically;
  Ship.RefreshEquipmentEvaluationMetrics;
  Ship.ChangeRelationToRanger(GetPlayer, 100);
  if GetPlayer.GetMaxDominionShips > GetPlayer.PiratePartners.Count then
  begin
    Ship.PartnerShip := GetPlayer;
    Months := Ship.CalculatePartnershipMonths(TotalCost, Ship);
    Ship.PartnershipDaysRemaining := 30 * Months;
    GetPlayer.PiratePartners.Add(Ship);
    GetPlayer.AchievementStats.CheckMasterAchievement;
    DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.CompletionText');
  end
  else
  begin
    Months := 0;
    DialogText := LocalizedColorText('FormRuins.CB.ConstructPirate.CompletionTextNotPartner');
  end;
  ReplaceTextToken(DialogText, '<FullName>', Ship.GetFullName(' '), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<CntMonth>', IntToStr(Months), '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5D4428 }

{ @routine $5D4928 TfRuinsTalk_ShowDominionImprovementDialog }
procedure TfRuinsTalk.ShowDominionImprovementDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAnswer');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerAsk'), 0, ShowDominionImprovementItems);
end;
{ @end $5D4928 }

{ @routine $5D4A64 TfRuinsTalk_ShowDominionImprovementItems }
procedure TfRuinsTalk.ShowDominionImprovementItems(Action: Integer);
var
  I, Count: Integer;
  Item: TEquipment;
  Artefact: TItem;
  Text: WideString;
begin
  ClearChoices;
  Count := 0;
  for I := 0 to GetPlayer.Inventory.Count - 1 do
  begin
    Item := GetPlayer.Inventory[I];
    if Item.ItemType in [t_Hull..t_CustomWeapon] then
    begin
      if Item.CanImprove and GetPlayer.CanUseEquipmentTech(Item) and GetPlayer.CanRepairEquipmentTech(Item) then
      begin
        Inc(Count);
        Text := Text + #13#10 + IntToStr(Count) + ') ' + LocalizedColorText('FormRuins.CB.Improvement.ItemReadyForImprovement');
        AddChoice('- ' + NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), Integer(Item), ShowDominionImprovementQuote);
      end;
      ReplaceTextToken(Text, '<ItemName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), '');
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), '<color=255,240,100>');
    end;
  end;
  for I := 0 to GetPlayer.Artefacts.Count - 1 do
  begin
    Artefact := GetPlayer.Artefacts[I];
    if Artefact is TArtefactTranclucator then
    begin
      Item := TShip((Artefact as TArtefactTranclucator).Ship).GetHull;
      if Item.CanImprove then
      begin
        Inc(Count);
        Text := Text + #13#10 + IntToStr(Count) + ') ' + LocalizedColorText('FormRuins.CB.Improvement.ItemReadyForImprovement');
        AddChoice('- ' + NormalizeTextHighlightColors(RemoveTextTagsW(Artefact.GetDisplayName)), Integer(Item), ShowDominionImprovementQuote);
      end;
      ReplaceTextToken(Text, '<ItemName>', NormalizeTextHighlightColors(RemoveTextTagsW(Artefact.GetDisplayName)), '');
      ReplaceTextToken(Text, '<Money>', IntToStr(Item.Cost), '<color=255,240,100>');
    end;
  end;
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBSeeItems');
  ReplaceTextToken(DialogText, '<ListItems>', Text, '');
  if Count > 0 then
  begin
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.CB.Improvement.CBSeeItemsHaveItems');
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerNothing'), 0, DeclineDominionImprovement);
  end
  else
  begin
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.CB.Improvement.CBSeeItemsNotHaveItems');
    M_Main(True);
  end;
end;
{ @end $5D4A64 }

{ @routine $5D5160 TfRuinsTalk_DeclineDominionImprovement }
procedure TfRuinsTalk.DeclineDominionImprovement(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAnswerNothing');
  ClearChoices;
  M_Main(True);
end;
{ @end $5D5160 }

{ @routine $5D5228 TfRuinsTalk_ShowDominionImprovementQuote }
procedure TfRuinsTalk.ShowDominionImprovementQuote(Action: Integer);
var
  Item: TEquipment;
  NodeCost, MoneyCost: Integer;
  Discount: Byte;
  Text: WideString;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  Item := TEquipment(Action);
  NodeCost := 0;
  if Item.OwnerId = Byte(oiDominator) then
  begin
    Text := LocalizedColorText('FormRuins.CB.Improvement.CBNeedCostImprovementNodes');
    ReplaceTextToken(Text, '<Nodes>', IntToStr(Round(Item.CalculateImprovementCost(ikMajor) * 0.01 * 1.5)), '<color=255,240,100>');
    NodeCost := Round(Item.CalculateImprovementCost(ikMajor) * 0.01 * 1.5 * (100 - Discount) / 100);
    ReplaceTextToken(Text, '<NodesDiscount>', IntToStr(NodeCost), '<color=255,240,100>');
  end
  else Text := LocalizedColorText('FormRuins.CB.Improvement.CBNeedCostImprovement');
  ReplaceTextToken(Text, '<Money>', IntToStr(Item.CalculateImprovementCost(ikMajor)), '<color=255,240,100>');
  MoneyCost := Round(Item.CalculateImprovementCost(ikMajor) * (100 - Discount) / 100);
  ReplaceTextToken(Text, '<MoneyDiscount>', IntToStr(MoneyCost), '<color=255,240,100>');
  ReplaceTextToken(Text, '<Discount>', IntToStr(Discount), '<color=255,240,100>');
  ReplaceTextToken(Text, '<FullName>', NormalizeTextHighlightColors(RemoveTextTagsW(Item.GetDisplayName)), '<color=255,240,100>');
  DialogText := Text;
  ClearChoices;
  if (GetPlayer.GetAvailableNodeCount(nil) >= NodeCost) and (GetPlayer.Money >= MoneyCost) then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerOk'), Action, AcceptDominionImprovement)
  else AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerOk'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerNo'), 0, DeclineDominionImprovement);
end;
{ @end $5D5228 }

{ @routine $5D57D8 TfRuinsTalk_AcceptDominionImprovement }
procedure TfRuinsTalk.AcceptDominionImprovement(Action: Integer);
var
  Item: TEquipment;
  Cost, Nodes: Integer;
  Discount: Byte;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  Item := TEquipment(Action);
  Cost := Item.CalculateImprovementCost(ikMajor);
  if Item.OwnerId = Byte(oiDominator) then Nodes := Round(Cost * 0.01 * 1.5 * (100 - Discount) / 100) else Nodes := 0;
  Cost := Round(Cost * (100 - Discount) / 100);
  if (GetPlayer.Money >= Cost) and (GetPlayer.GetAvailableNodeCount(nil) >= Nodes) then
  begin
    GetPlayer.SetMoney(GetPlayer.Money - Cost);
    if Item.OwnerId = Byte(oiDominator) then GetPlayer.ConsumeAvailableNodes(Nodes, nil);
    Item.ImproveAtScientificBase;
    GetPlayer.RefreshDerivedStats(True);
    DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAfterOk');
    ReplaceTextToken(DialogText, '<ShortName>', WideLowerCase(Item.GetShortName), '');
    SoundManager.PlaySound('Sound.Sell');
    ClearChoices;
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerRepeatOk'), 0, ShowDominionImprovementItems);
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.Improvement.PlayerRepeatNo'), 0, DeclineDominionRepeatImprovement);
  end
  else DeclineScienceBaseRepeatImprovement(0); // Native failure branch uses the science-base answer.
end;
{ @end $5D57D8 }

{ @routine $5D5B48 TfRuinsTalk_DeclineDominionRepeatImprovement }
procedure TfRuinsTalk.DeclineDominionRepeatImprovement(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.Improvement.CBAfterRepeatNo');
  ClearChoices;
  M_Main(True);
end;
{ @end $5D5B48 }

{ @routine $5D5C10 TfRuinsTalk_ShowDominionPirateLicenseDialog }
procedure TfRuinsTalk.ShowDominionPirateLicenseDialog(Action: Integer);
var
  Cost: Integer;
  Discount: Byte;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  if GetPlayer.PirateLicenseTicks = 0 then
    DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAnswer')
  else DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAnswerProlongate');
  Cost := RoundAndTruncateToTens(RemapClamped(GetPlayer.PirateLicenseTicks, 0, 365, Galaxy.ComputeScaledAverageMoney(2), 0));
  ReplaceTextToken(DialogText, '<Money>', IntToStr(Cost), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Discount>', IntToStr(Discount), '<color=255,240,100>');
  Cost := Round(Cost * (100 - Discount) / 100);
  ReplaceTextToken(DialogText, '<DiscountMoney>', IntToStr(Cost), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.PirateLicenseTicks = 0 then
  begin
    if GetPlayer.Money >= Cost then
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerOk'), Cost, BuyDominionPirateLicense)
    else AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerOk'), 0, ScriptDialogBlockCallback);
  end
  else
  begin
    if GetPlayer.Money >= Cost then
      AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerOkProlongate'), Cost, BuyDominionPirateLicense)
    else AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerOkProlongate'), 0, ScriptDialogBlockCallback);
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.PirateLicense.PlayerNo'), 0, DeclineDominionPirateLicense);
end;
{ @end $5D5C10 }

{ @routine $5D616C TfRuinsTalk_BuyDominionPirateLicense }
procedure TfRuinsTalk.BuyDominionPirateLicense(Action: Integer);
begin
  if GetPlayer.PirateLicenseTicks = 0 then
    DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterOk')
  else DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterOkProlongate');
  GetPlayer.SetMoney(GetPlayer.Money - Action);
  GetPlayer.PirateLicenseTicks := 365;
  SoundManager.PlaySound('Sound.Sell');
  M_Main(True);
end;
{ @end $5D616C }

{ @routine $5D6314 TfRuinsTalk_DeclineDominionPirateLicense }
procedure TfRuinsTalk.DeclineDominionPirateLicense(Action: Integer);
begin
  if GetPlayer.PirateLicenseTicks = 0 then
    DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterNo')
  else DialogText := LocalizedColorText('FormRuins.CB.PirateLicense.CBAfterNoProlongate');
  ReplaceTextToken(DialogText, '<Days>', IntToStr(GetPlayer.PirateLicenseTicks), '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5D6314 }

{ @routine $5D64E4 TfRuinsTalk_CheckDominionServiceStanding }
function TfRuinsTalk.CheckDominionServiceStanding(RequiredRank: Byte; Prefix: WideString; CreditCost: Single): Boolean;
begin
  Result := False;
  if GetPlayer.PirateRank < RequiredRank then
  begin
    DialogText := Prefix + ' ' + LocalizedColorText('FormRuins.CB.GenericRefuseNeedRank');
    ReplaceTextToken(DialogText, '<PirateRank>', LocalizedText('RankPirate.' + PirateRankNames[RequiredRank] + '.Name'), '<color=255,240,100>');
  end
  else if (Galaxy.AverageRangerCapital * CreditCost / 600 > GetPlayer.PirateLicenseCash) and (GetPlayer.PirateRank < 7) then
  begin
    if GetPlayer.PirateLicenseTicks > 0 then
      DialogText := Prefix + ' ' + LocalizedColorText('FormRuins.CB.GenericRefuseNeedPoints')
    else DialogText := Prefix + ' ' + LocalizedColorText('FormRuins.CB.GenericRefuseNeedLicense');
  end
  else Result := True;
end;
{ @end $5D64E4 }

{ @routine $5D67E8 TfRuinsTalk_SpendDominionServiceCredit }
procedure TfRuinsTalk.SpendDominionServiceCredit(CreditCost: Single);
begin
  GetPlayer.PirateLicenseCash := Max(0, Round((GetPlayer.PirateLicenseCash - Galaxy.AverageRangerCapital * CreditCost / 600) * 0.85));
end;
{ @end $5D67E8 }

{ @routine $5D6878 TfRuinsTalk_CheckDominionAvailable }
function TfRuinsTalk.CheckDominionAvailable: Boolean;
begin
  if (TRuins(GetPlayer.DockedTo).FlyToStar <> nil) or (GetPlayer.DockedTo.Order = soTeleport) or GetPlayer.DockedTo.HasScriptControl then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.GenericRefuseHaveOtherPlans');
    Result := False;
  end
  else Result := True;
end;
{ @end $5D6878 }

{ @routine $5D6A30 TfRuinsTalk_ShowDominionTravelDialog }
procedure TfRuinsTalk.ShowDominionTravelDialog(Action: Integer);
var
  Text: WideString;
  Seed: Cardinal;
  Star: TStar;
  I, J, Count: Integer;
  Duplicate: Boolean;
  Discount: Byte;
  // @nested $5D696C GetDominionTravelQuoteCost
  function GetDominionTravelQuoteCost(Index: Integer): Integer; // @addr $5D696C @calls "0x5D6C4E 0x5D6C97"
  begin
    Result := Min(100000000, Round(Galaxy.ComputeScaledHugeMoney(2) / DominionTravelQuotes[Index].DrawCount * PointDistanceSquared(GetPlayer.CurrentStar.Position, DominionTravelQuotes[Index].Star.Position) / 1600 * (100 - Discount) / 100));
  end;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  if GetPlayer.DockedTo.CurrentStar.Battle <> 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.GenericRefuseBattle');
    M_Main(True);
    Exit;
  end;
  if GetPlayer.DockedTo.InHyperspace then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBNoInHyper');
    M_Main(True);
    Exit;
  end;
  if not CheckDominionServiceStanding(2, LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBRefusePrefix'), 0.5) then
  begin
    M_Main(True);
    Exit;
  end;
  if not CheckDominionAvailable then
  begin
    M_Main(True);
    Exit;
  end;
  if TRuins(GetPlayer.DockedTo).RelocationAge < 45 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBNoEnergy');
    M_Main(True);
    Exit;
  end;
  Seed := GetPlayer.DockedTo.Seed + Galaxy.CurrentTurn div 31 + GetPlayer.CurrentStar.GenerationSeed;
  Count := 0;
  for I := 1 to 4 do
  begin
    Star := Galaxy.Stars[NextRandomIntRange(0, Galaxy.Stars.Count - 1, Seed)];
    if (GetPlayer.CurrentStar <> Star) and Star.IsConstellationVisible and ((Star.Constellation.Id <> 20) or (Galaxy.CoalitionDefeatedTurn <> 0)) then
    begin
      Duplicate := False;
      for J := 1 to Count do
        if DominionTravelQuotes[J].Star = Star then
        begin
          Duplicate := True;
          Inc(DominionTravelQuotes[J].DrawCount);
          DominionTravelQuotes[J].Cost := GetDominionTravelQuoteCost(J);
        end;
      if not Duplicate then
      begin
        Inc(Count);
        DominionTravelQuotes[Count].Star := Star;
        DominionTravelQuotes[Count].DrawCount := 1;
        DominionTravelQuotes[Count].Cost := GetDominionTravelQuoteCost(Count);
      end;
    end;
  end;
  if Count <= 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBNoPath');
    M_Main(True);
    Exit;
  end;
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBChoseDestination');
  ClearChoices;
  for I := 1 to Count do
  begin
    Text := LocalizedColorText('FormRuins.CB.ShuffleTeleport.ToStar');
    ReplaceTextToken(Text, '<ToStar>', DominionTravelQuotes[I].Star.Name, '<color=255,240,100>');
    ReplaceTextToken(Text, '<Cost>', IntToStr(DominionTravelQuotes[I].Cost), '<color=255,240,100>');
    if GetPlayer.Money >= DominionTravelQuotes[I].Cost then
      AddChoice('- ' + Text, I, ConfirmDominionTravel)
    else AddChoice('- ' + Text, 0, ScriptDialogBlockCallback);
    Text := LocalizedColorText('FormRuins.CB.ShuffleTeleport.ToList');
    ReplaceTextToken(Text, '<ToStar>', DominionTravelQuotes[I].Star.Name, '<color=255,240,100>');
    ReplaceTextToken(Text, '<Cost>', IntToStr(DominionTravelQuotes[I].Cost), '<color=255,240,100>');
    ReplaceTextToken(Text, '<Dist>', IntToStr(Round(PointDistance(GetPlayer.CurrentStar.Position, DominionTravelQuotes[I].Star.Position))), '<color=255,240,100>');
    DialogText := DialogText + #13#10 + IntToStr(I) + ') ' + Text;
  end;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.Refuse'), 0, DeclineDominionTravel);
end;
{ @end $5D6A30 }

{ @routine $5D7318 TfRuinsTalk_ConfirmDominionTravel }
procedure TfRuinsTalk.ConfirmDominionTravel(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBConfirmation');
  ReplaceTextToken(DialogText, '<ToStar>', DominionTravelQuotes[Action].Star.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Cost>', IntToStr(DominionTravelQuotes[Action].Cost), '<color=255,240,100>');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.Confirm'), Action, AcceptDominionTravel);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.NoConfirm'), 0, DeclineDominionTravelConfirmation);
end;
{ @end $5D7318 }

{ @routine $5D75C8 TfRuinsTalk_DeclineDominionTravel }
procedure TfRuinsTalk.DeclineDominionTravel(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterRefuse');
  M_Main(True);
end;
{ @end $5D75C8 }

{ @routine $5D768C TfRuinsTalk_AcceptDominionTravel }
procedure TfRuinsTalk.AcceptDominionTravel(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterConfirm');
  GetPlayer.QueuedTravelTarget := DominionTravelQuotes[Action].Star;
  GetPlayer.SetMoney(GetPlayer.Money - DominionTravelQuotes[Action].Cost);
  SpendDominionServiceCredit(0.5);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 45) div 2;
  SoundManager.PlaySound('Sound.Sell');
  ReplaceTextToken(DialogText, '<FlyToStar>', GetPlayer.QueuedTravelTarget.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5D768C }

{ @routine $5D785C TfRuinsTalk_DeclineDominionTravelConfirmation }
procedure TfRuinsTalk.DeclineDominionTravelConfirmation(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterNoConfirm');
  M_Main(True);
end;
{ @end $5D785C }

{ @routine $5D7924 TfRuinsTalk_ShowDominionCancelTravelDialog }
procedure TfRuinsTalk.ShowDominionCancelTravelDialog(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBCancelTeleport');
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.CancelYes'), 0, CancelDominionTravel);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.ShuffleTeleport.CancelNo'), 0, DeclineDominionCancelTravel);
end;
{ @end $5D7924 }

{ @routine $5D7B08 TfRuinsTalk_CancelDominionTravel }
procedure TfRuinsTalk.CancelDominionTravel(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterCancelTeleport');
  GetPlayer.QueuedTravelTarget := nil;
  M_Main(True);
end;
{ @end $5D7B08 }

{ @routine $5D7BE8 TfRuinsTalk_DeclineDominionCancelTravel }
procedure TfRuinsTalk.DeclineDominionCancelTravel(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.ShuffleTeleport.CBAfterNoCancel');
  ReplaceTextToken(DialogText, '<FlyToStar>', GetPlayer.QueuedTravelTarget.Name, '<color=255,240,100>');
  M_Main(True);
end;
{ @end $5D7BE8 }

{ @routine $5D7D1C GetDominionRelocationCost }
function GetDominionRelocationCost(Star: TStar): Integer;
var
  Discount: Byte;
begin
  Discount := GetPlayer.GetPirateServiceDiscount;
  Result := Min(100000000, Round((PointDistanceSquared(GetPlayer.DockedTo.CurrentStar.Position, Star.Position) + 6400) * SeededRandomIntRange(Galaxy.ComputeScaledHugeMoney(2) div 2, Galaxy.ComputeScaledHugeMoney(2) * 2, Star.GenerationSeed + 1171 + GetPlayer.DockedTo.CurrentStar.GenerationSeed) / 6400 * (100 - Discount) / 100));
end;
{ @end $5D7D1C }

{ @routine $5D7E18 TfRuinsTalk_ShowDominionRelocationDialog }
procedure TfRuinsTalk.ShowDominionRelocationDialog(Action: Integer);
const
  StationMask = [6..12];
var
  I, Count, Index, First, Last, Cost: Integer;
  Star: TStar;
  Constellations: TList;
begin
  ClearChoices;
  if not CheckDominionServiceStanding(3, LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBRefusePrefix'), 1) then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  if not CheckDominionAvailable then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  if TRuins(GetPlayer.DockedTo).RelocationAge < 150 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBNoEnergy');
    BuildDominionWarOptions;
    Exit;
  end;
  Count := 0;
  First := 1;
  Last := Galaxy.Stars.Count - 1;
  Index := SeededRandomIntRange(First, Last, GetPlayer.DockedTo.Seed + Galaxy.GenerationSeed + Galaxy.CurrentTurn div 60 + 1141);
  Constellations := TList.Create;
  for I := 1 to Galaxy.Stars.Count - 1 do
    if not GetPlayer.NoJump then
    begin
      IncrementWrapped(Index, First, Last);
      Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
      if not Star.NoComeKling and (Constellations.IndexOf(Star.Constellation) < 0) then
        if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 1387) >= 0.6) and
          (Star.Constellation.Id <> 20) and ((Star.Constellation.ShipTypeCounts[Ord(rstDominion)] <= 0) or (GetPlayer.DockedTo.CurrentStar.Constellation = Star.Constellation)) and
          (Star.Constellation.CountShipsByTypeMask(StationMask) < Star.Constellation.Stars.Count) and
          (Star.Dominion = nil) and (Star.CountShipsByTypeMask(StationMask) <= 2) and
          (Star.ShipTypeCounts[stKling] <= 0) and (Star.ControlFaction = sfPirates) and (Star.Battle = 0) and
          (Star.Status.CustomFaction = '') and (GetPlayer.DockedTo.CurrentStar <> Star) and Star.IsConstellationVisible then
        begin
          Inc(Count);
          Cost := GetDominionRelocationCost(Star);
          if GetPlayer.Money < Cost then
            AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Relocate.ToStar'), '<color=255,240,100>', '<ToStar>', Star.Name, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback)
          else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Relocate.ToStar'), '<color=255,240,100>', '<ToStar>', Star.Name, '<Cost>', IntToStr(Cost)), Integer(Star), AcceptDominionRelocation);
          // Native disabled choice uses the shared quote and <Money>, unlike the enabled choice.
          Constellations.Add(Star.Constellation);
        end;
    end;
  Constellations.Free;
  if Count <= 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBNoPath');
    BuildDominionWarOptions;
  end
  else
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBChoseDestination');
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Relocate.Refuse'), 0, DeclineDominionRelocation);
  end;
end;
{ @end $5D7E18 }

{ @routine $5D8590 TfRuinsTalk_AcceptDominionRelocation }
procedure TfRuinsTalk.AcceptDominionRelocation(Action: Integer);
var
  Star: TStar;
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBAfterConfirm');
  Star := TStar(Action);
  ReplaceTextToken(DialogText, '<ToStar>', Star.Name, '<color=255,240,100>');
  GetPlayer.SetMoney(GetPlayer.Money - GetDominionRelocationCost(Star));
  SpendDominionServiceCredit(1);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 150) div 2;
  SoundManager.PlaySound('Sound.Sell');
  GetPlayer.DockedTo.OrderTeleport(Star, TRuins(GetPlayer.DockedTo).SelectTeleportArrivalPoint(Star), 10, True);
  GetPlayer.DockedTo.CurrentStar.Dominion := nil;
  Star.Dominion := GetPlayer.DockedTo;
  ClearChoices;
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Relocate.ToHangar'), 0, OpenHangar);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Relocate.IgnoreWarning'), 0, ReturnToMain);
end;
{ @end $5D8590 }

{ @routine $5D88D4 TfRuinsTalk_DeclineDominionRelocation }
procedure TfRuinsTalk.DeclineDominionRelocation(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Relocate.CBAfterRefuse');
  BuildDominionWarOptions;
end;
{ @end $5D88D4 }

{ @routine $5D899C TfRuinsTalk_BuildDominionWarOptions }
procedure TfRuinsTalk.BuildDominionWarOptions;
begin
  ClearChoices;
  if Galaxy.CoalitionDefeatedTurn = 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.PlayerAskAboutRanks'), 0, ShowDominionRanksAnswer);
  if Galaxy.CoalitionDefeatedTurn = 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.PlayerAskAboutCapture'), 0, ShowDominionCaptureAnswer);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerSend'), 0, ShowDominionWarOperationDialog);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Relocate.PlayerSend'), 0, ShowDominionRelocationDialog);
  if Galaxy.CoalitionDefeatedTurn = 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.PlayerSend'), 0, ShowDominionAmbushDialog);
  if Galaxy.CoalitionDefeatedTurn = 0 then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Assault.PlayerSend'), 0, ShowDominionAssaultDialog);
  if Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Assault.PlayerSend2'), 1, ShowDominionAssaultDialog);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.PlayerNoQuestions'), 0, ReturnToMain);
end;
{ @end $5D899C }

{ @routine $5D8EB0 TfRuinsTalk_I_CBWarWithKlingAndCoalition }
procedure TfRuinsTalk.I_CBWarWithKlingAndCoalition(Action: Integer);
var
  CoalitionPercent, DominatorPercent, PiratePercent: Byte;
  Path: WideString;
  Star: TStar;
  I: Integer;
begin
  if GetPlayer.DockedTo.CurrentStar.Battle <> 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.GenericRefuseBattle');
    M_Main(True);
    Exit;
  end;
  Star := nil;
  CoalitionPercent := Galaxy.GetFactionControlPercent(Ord(sfCoalition));
  DominatorPercent := Galaxy.GetFactionControlPercent(Ord(sfDominators));
  PiratePercent := Galaxy.GetFactionControlPercent(Ord(sfPirates));
  for I := 0 to Galaxy.Stars.Count - 1 do
    if ((TObject(GetPlayer.CurrentStar.StarDistances[I].Star) as TStar).ControlFaction in [sfCoalition, sfDominators]) and
      ((TObject(GetPlayer.CurrentStar.StarDistances[I].Star) as TStar).Constellation.Id <> 20) then
    begin
      Star := GetPlayer.CurrentStar.StarDistances[I].Star;
      Break;
    end;
  if Star = nil then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) and (Galaxy.CoalitionDefeatedTurn = 0) then
      Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.CoalitionOnly.CBAnswerWeControl100Percent'
    else if Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) and (Galaxy.CoalitionDefeatedTurn <> 0) then
      Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.KlingOnly.CBAnswerWeControl100Percent'
    else Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.KlingAndCoalition.CBAnswerWeControl100Percent';
  end
  else
  begin
    if DominatorPercent > CoalitionPercent * 3 then
      Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.KlingOnly.'
    else if DominatorPercent * 3 < CoalitionPercent then
      Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.CoalitionOnly.'
    else Path := 'FormRuins.CB.WarPlans.WarWithKlingAndCoalition.KlingAndCoalition.';
    case PiratePercent of
      0..9: Path := Path + 'CBAnswerWeControlMore00Percent';
      10..22: Path := Path + 'CBAnswerWeControlMore10Percent';
      23..35: Path := Path + 'CBAnswerWeControlMore30Percent';
      36..59: Path := Path + 'CBAnswerWeControlMore50Percent';
      60..89: Path := Path + 'CBAnswerWeControlMore70Percent';
      90..99: Path := Path + 'CBAnswerWeControlMore90Percent';
      100: Path := Path + 'CBAnswerWeControl100Percent';
    else DialogText := 'Error in procedure TfRuinsTalk.I_CBWarWithKlingAndCoalition';
    end;
  end;
  DialogText := LocalizedColorText(Path);
  ReplaceTextToken(DialogText, '<CB>', GetPlayer.DockedTo.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Percent>', IntToStr(CoalitionPercent), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<DominatorsPercent>', IntToStr(DominatorPercent), '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<PiratesPercent>', IntToStr(PiratePercent), '<color=255,240,100>');
  DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.CB.WarPlans.WarWithKlingAndCoalition.ExtraTextAboutRanks');
  BuildDominionWarOptions;
end;
{ @end $5D8EB0 }

{ @routine $5D9A50 TfRuinsTalk_ShowDominionCaptureAnswer }
procedure TfRuinsTalk.ShowDominionCaptureAnswer(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.CBAnswersAboutCapture');
  BuildDominionWarOptions;
end;
{ @end $5D9A50 }

{ @routine $5D9B14 TfRuinsTalk_ShowDominionRanksAnswer }
procedure TfRuinsTalk.ShowDominionRanksAnswer(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.CBAnswersAboutRanks');
  ReplaceTextToken(DialogText, '<BaseName>', GetPlayer.DockedTo.Name, '');
  BuildDominionWarOptions;
end;
{ @end $5D9B14 }

{ @routine $5D9C0C ApplyRecentDominionOrderSurcharge }
function ApplyRecentDominionOrderSurcharge(Cost: Single): Integer;
var
  I: Integer;
  EventType: WideString;
begin
  for I := Galaxy.GalaxyEvents.Count - 1 downto 0 do
  begin
    if TGalaxyEvent(Galaxy.GalaxyEvents[I]).Turn + 60 < Galaxy.CurrentTurn then Break;
    EventType := TGalaxyEvent(Galaxy.GalaxyEvents[I]).EventType;
    if (EventType = 'PlayerOrdersPirateAmbush') or (EventType = 'PlayerOrdersPirateRaid') or (EventType = 'PlayerOrdersPirateAssault') then
      Cost := Min(100000000.0, Cost * 1.5);
  end;
  Result := RoundAndTruncateToHundreds(Cost);
end;
{ @end $5D9C0C }

{ @routine $5D9DEC TfRuinsTalk_ShowDominionWarOperationDialog }
procedure TfRuinsTalk.ShowDominionWarOperationDialog(Action: Integer);
begin
  if not CheckDominionServiceStanding(1, LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBRefusePrefix'), 0) then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(Galaxy.ComputeScaledHugeMoney(2));
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAboutWarOperation');
  ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
  ClearChoices;
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerOk'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, AcceptDominionWarOperation)
  else AddChoice('- ' + FormatText1(LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerOk'), '<color=255,240,100>', '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.PlayerNo'), 0, DeclineDominionWarOperation);
end;
{ @end $5D9DEC }

{ @routine $5DA21C TfRuinsTalk_AcceptDominionWarOperation }
procedure TfRuinsTalk.AcceptDominionWarOperation(Action: Integer);
var
  Names: WideString;
  I, J, K, Available, BestAvailable, Total, BestTotal: Integer;
  Ship: TShip;
  Strength: Extended;
  Target, Candidate, Origin: TStar;
  Event: TGalaxyEvent;
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAfterOk');
  SoundManager.PlaySound('Sound.Sell');
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(Galaxy.ComputeScaledHugeMoney(2));
  GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
  if MainPiratePlanet <> nil then MainPiratePlanet.ChangeRelationToRanger(GetPlayer, 10);
  Target := nil;
  BestAvailable := 0;
  BestTotal := 0;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Candidate := Galaxy.Stars[I];
    if (Candidate.Constellation.Id <> 20) and Candidate.IsConstellationVisible and not Candidate.NoComeKling and
      not IsStarProtectedByScript(Candidate) and (Candidate.ControlFaction <> sfPirates) then
    begin
      Available := 0;
      Total := 0;
      for J := 0 to Galaxy.Stars.Count - 1 do
      begin
        Origin := Galaxy.Stars[J];
        if (Candidate <> Origin) and (Origin.ControlFaction = sfPirates) and (Origin.Status.CustomFaction = '') and
          (Origin.Battle = 0) and (Origin.CountForcesByOwnerGroups(Strength, True, True, False, False) <= 0) then
          for K := 0 to Origin.Ships.Count - 1 do
          begin
            Ship := Origin.Ships[K];
            if (Ship is TPirate) and (Ship.OwnerId = Byte(oiPirate)) and (Ship.PartnerShip = nil) then
              if not ((Ship.GetFuelTanks = nil) or (Ship.GetEngine = nil) or
                (PointDistance(Origin.Position, Candidate.Position) > Min(Ship.GetFuelTanks.Capacity, Ship.GetEngine.JumpRange) + 10)) then
              begin
                Inc(Total);
                if not Ship.OrderAbsolute and (Ship.AbsoluteScriptOrder = 0) and not Ship.IsOutsideStarSpace and (Ship.ScriptShip = nil) then Inc(Available);
              end;
          end;
      end;
      if Available > BestAvailable then
      begin
        BestAvailable := Available;
        BestTotal := Total;
        Target := Candidate;
      end;
    end;
  end;
  if (Target = nil) or (BestTotal < 10) or (BestAvailable < 7) then
  begin
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAfterOkBad');
    ClearChoices;
    M_Main(True);
  end
  else
  begin
    BestAvailable := Min(GetPlayer.PirateRank + 7, BestAvailable);
    // Native completes each pass even after the requested ship count is reached.
    while BestAvailable > 0 do
      for J := 1 to Galaxy.Stars.Count - 1 do
      begin
        Origin := Target.StarDistances[J].Star;
        if (Origin.ControlFaction = sfPirates) and (Origin.Status.CustomFaction = '') and (Origin.Battle = 0) and
          (Origin.CountForcesByOwnerGroups(Strength, True, True, False, False) <= 0) then
          for K := 0 to Origin.Ships.Count - 1 do
          begin
            Ship := Origin.Ships[K];
            if (Ship is TPirate) and (Ship.OwnerId = Byte(oiPirate)) and (Ship.PartnerShip = nil) then
              if not ((Ship.GetFuelTanks = nil) or (Ship.GetEngine = nil) or
                (PointDistance(Origin.Position, Target.Position) > Min(Ship.GetFuelTanks.Capacity, Ship.GetEngine.JumpRange) + 10)) then
                if not Ship.OrderAbsolute and (Ship.AbsoluteScriptOrder = 0) and not Ship.IsOutsideStarSpace and (Ship.ScriptShip = nil) then
                if NextRandomIntRange(1, 10, GetPlayer.DockedTo.RandomState) < 3 then
                begin
                  Ship.OrderJump(Target, True);
                  TPirate(Ship).RaidPressure := TPirate(Ship).RaidPressure + 10;
                  if Names = '' then Names := Ship.GetFullName(' ')
                  else Names := Names + #13#10 + Ship.GetFullName(' ');
                  Dec(BestAvailable);
                end;
          end;
      end;
    Event := AddGalaxyEvent('PlayerOrdersPirateRaid');
    Event.AddData(Target.Id);
    DialogText := DialogText + #13#10 + LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAfterOkGood');
    ReplaceTextToken(DialogText, '<Names>', Names, '');
    ReplaceTextToken(DialogText, '<Money>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<StarEnemy>', Target.Name, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<SectorEnemy>', Target.Constellation.GetName, '<color=255,240,100>');
    ClearChoices;
    M_Main(True);
  end;
end;
{ @end $5DA21C }

{ @routine $5DAC00 TfRuinsTalk_DeclineDominionWarOperation }
procedure TfRuinsTalk.DeclineDominionWarOperation(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.WarOperation.CBAfterNo');
  BuildDominionWarOptions;
end;
{ @end $5DAC00 }

{ @routine $5DACC8 TfRuinsTalk_ShowDominionAmbushDialog }
procedure TfRuinsTalk.ShowDominionAmbushDialog(Action: Integer);
var
  I, Count, Turn: Integer;
  Star, Target: TStar;
  Group: TGroup;
  Base: TRuins;
  Ship: TShip;
  Entry: TGroupRouteOrder;
begin
  if not CheckDominionServiceStanding(4, LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBRefusePrefix'), 1.5) then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  if not CheckDominionAvailable then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  if TRuins(GetPlayer.DockedTo).RelocationAge < 150 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBNoEnergy');
    BuildDominionWarOptions;
    Exit;
  end;
  Target := nil;
  Turn := 0;
  for I := 0 to Galaxy.LiberationGroups.Count - 1 do
  begin
    Group := Galaxy.LiberationGroups[I];
    if Group <> nil then
      if Group.Ships.Count > 0 then
      begin
        Entry := Group.Route[Length(Group.Route) - 1];
        if Entry.Kind = 3 then
        begin
          Star := TStar(Entry.Target);
          if Star <> nil then
            if Star.IsConstellationVisible and ((Star.ControlFaction <> sfCoalition) or (Star.Status.CustomFaction <> '')) and
              ((Group.Route[2].WaitUntilTurn < Turn) or (Target = nil)) then
            begin
              Target := Star;
              Turn := Group.Route[2].WaitUntilTurn;
            end;
        end;
      end;
  end;
  Base := Galaxy.FindMilitaryBaseInTransit;
  if Base <> nil then
  begin
    Star := Base.FlyToStar;
    // The native fallback is outside the destination eligibility conjunction.
    if ((Star <> nil) and Star.IsConstellationVisible and ((Star.ControlFaction <> sfCoalition) or (Star.Status.CustomFaction <> '')) and
      (Base.FlyDate < Turn)) or (Target = nil) then
    begin
      Target := Star;
      Turn := Base.FlyDate;
    end;
  end;
  if Target = nil then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerNoOperations');
    BuildDominionWarOptions;
    Exit;
  end;
  if Turn - Galaxy.CurrentTurn > 21 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerNoOperationsSoon');
    ReplaceTextToken(DialogText, '<Star>', Target.Name, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), '<color=255,240,100>');
    BuildDominionWarOptions;
    Exit;
  end;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if Star.Dominion <> nil then
      if TRuins(Star.Dominion).FlyToStar = Target then
      begin
        DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerAmbushAlreadyInProgress');
        ReplaceTextToken(DialogText, '<Star>', Target.Name, '<color=255,240,100>');
        ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), '<color=255,240,100>');
        BuildDominionWarOptions;
        Exit;
      end;
  end;
  Count := 0;
  Star := GetPlayer.DockedTo.CurrentStar;
  for I := 0 to Star.Ships.Count - 1 do
  begin
    // Preserve index-before-receiver evaluation under DCC32 O-.
    Ship := Star.Ships[I * 1];
    if not Ship.InHyperspace and (Ship is TPirate) and (Ship.OwnerId = Byte(oiPirate)) and (Ship.PartnerShip = nil) and
      (Ship.ScriptShip = nil) and not Ship.HasScriptControl then Inc(Count);
  end;
  if Count < 8 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerNotEnoughPirates');
    ReplaceTextToken(DialogText, '<Star>', Target.Name, '<color=255,240,100>');
    ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), '<color=255,240,100>');
    BuildDominionWarOptions;
    Exit;
  end;
  ClearChoices;
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAnswerOperationSoon');
  ReplaceTextToken(DialogText, '<Star>', Target.Name, '<color=255,240,100>');
  ReplaceTextToken(DialogText, '<Date>', FormatGameTurnDate(Turn), '<color=255,240,100>');
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Target) * 1.5);
  ReplaceTextToken(DialogText, '<Cost>', IntToStr(StationServiceQuoteCost), '<color=255,240,100>');
  if GetPlayer.Money >= StationServiceQuoteCost then
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.Confirm'), Integer(Target), AcceptDominionAmbush)
  else AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.Confirm'), 0, ScriptDialogBlockCallback);
  AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Ambush.Refuse'), 0, DeclineDominionAmbush);
end;
{ @end $5DACC8 }

{ @routine $5DB720 TfRuinsTalk_AcceptDominionAmbush }
procedure TfRuinsTalk.AcceptDominionAmbush(Action: Integer);
var
  Star: TStar;
  Event: TGalaxyEvent;
begin
  Star := TStar(Action);
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAfterOk');
  ReplaceTextToken(DialogText, '<ToStar>', Star.Name, '<color=255,240,100>');
  StationServiceQuoteCost := ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Star) * 1.5);
  Event := AddGalaxyEvent('PlayerOrdersPirateAmbush');
  Event.AddData(Star.Id);
  SoundManager.PlaySound('Sound.Sell');
  GetPlayer.SetMoney(GetPlayer.Money - StationServiceQuoteCost);
  SpendDominionServiceCredit(1.5);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 150) div 2;
  TRuins(GetPlayer.DockedTo).FlyToStar := Star;
  if Star.ControlFaction = sfPirates then TRuins(GetPlayer.DockedTo).FlyDate := Galaxy.CurrentTurn + 12
  else TRuins(GetPlayer.DockedTo).FlyDate := Galaxy.CurrentTurn + 16;
  M_Main(True);
end;
{ @end $5DB720 }

{ @routine $5DB998 TfRuinsTalk_DeclineDominionAmbush }
procedure TfRuinsTalk.DeclineDominionAmbush(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Ambush.CBAfterRefuse');
  BuildDominionWarOptions;
end;
{ @end $5DB998 }

{ @routine $5DBA5C TfRuinsTalk_ShowDominionAssaultDialog }
procedure TfRuinsTalk.ShowDominionAssaultDialog(Action: Integer);
var
  I, Count, Index, First, Last, Cost: Integer;
  Star: TStar;
  Constellations: TList;
  Faction: TStarFaction;
  Rank: Byte;
  CreditCost: Single;
begin
  ClearChoices;
  if Action = 0 then
  begin
    Faction := sfCoalition;
    Rank := 5;
    CreditCost := 2;
  end
  else
  begin
    Faction := sfDominators;
    Rank := 6;
    CreditCost := 3;
  end;
  if not CheckDominionServiceStanding(Rank, LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBRefusePrefix'), CreditCost) then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  if not CheckDominionAvailable then
  begin
    BuildDominionWarOptions;
    Exit;
  end;
  if TRuins(GetPlayer.DockedTo).RelocationAge < 150 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBNoEnergy');
    BuildDominionWarOptions;
    Exit;
  end;
  Count := 0;
  First := 1;
  Last := Galaxy.Stars.Count - 1;
  Index := SeededRandomIntRange(First, Last, GetPlayer.DockedTo.Seed + Galaxy.GenerationSeed + Galaxy.CurrentTurn div 60 + 1141);
  Constellations := TList.Create;
  for I := 1 to Galaxy.Stars.Count - 1 do
    if not GetPlayer.NoJump then
    begin
      IncrementWrapped(Index, First, Last);
      Star := TObject(GetPlayer.CurrentStar.StarDistances[Index].Star) as TStar;
      if not Star.NoComeKling and (Constellations.IndexOf(Star.Constellation) < 0) then
        if (SeededRandomUnitFloat(GetPlayer.DockedTo.Seed + Star.GenerationSeed + Galaxy.CurrentTurn div 60 + 1387) >= 0.8) and
          (Star.Constellation.Id <> 20) and (Star.Constellation.ShipTypeCounts[Ord(rstDominion)] <= 0) and
          (Star.Dominion = nil) and (Star.ControlFaction = Faction) and
          (Star.Status.CustomFaction = '') and (GetPlayer.DockedTo.CurrentStar <> Star) and Star.IsConstellationVisible then
        begin
          Inc(Count);
          Cost := ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Star) * 2.5);
          if GetPlayer.Money < Cost then
            AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Assault.ToStar'), '<color=255,240,100>', '<ToStar>', Star.Name, '<Money>', IntToStr(StationServiceQuoteCost)), 0, ScriptDialogBlockCallback)
          else AddChoice('- ' + FormatText2(LocalizedColorText('FormRuins.CB.WarPlans.Assault.ToStar'), '<color=255,240,100>', '<ToStar>', Star.Name, '<Cost>', IntToStr(Cost)), Integer(Star), AcceptDominionAssault);
          // Native disabled choice uses the shared quote and <Money>, unlike the enabled choice.
          Constellations.Add(Star.Constellation);
        end;
    end;
  Constellations.Free;
  if Count <= 0 then
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBNoPath');
    BuildDominionWarOptions;
  end
  else
  begin
    DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBChoseDestination');
    AddChoice('- ' + LocalizedColorText('FormRuins.CB.WarPlans.Assault.Refuse'), 0, DeclineDominionAssault);
  end;
end;
{ @end $5DBA5C }

{ @routine $5DC1A4 TfRuinsTalk_AcceptDominionAssault }
procedure TfRuinsTalk.AcceptDominionAssault(Action: Integer);
var
  Star: TStar;
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBAfterConfirm');
  Star := TStar(Action);
  ReplaceTextToken(DialogText, '<ToStar>', Star.Name, '<color=255,240,100>');
  GetPlayer.SetMoney(GetPlayer.Money - ApplyRecentDominionOrderSurcharge(GetDominionRelocationCost(Star) * 2.5));
  SpendDominionServiceCredit(1);
  TRuins(GetPlayer.DockedTo).RelocationAge := (TRuins(GetPlayer.DockedTo).RelocationAge - 150) div 2;
  SoundManager.PlaySound('Sound.Sell');
  TRuins(GetPlayer.DockedTo).FlyToStar := Star;
  TRuins(GetPlayer.DockedTo).FlyDate := Galaxy.CurrentTurn + 12;
  M_Main(True);
end;
{ @end $5DC1A4 }

{ @routine $5DC3A4 TfRuinsTalk_DeclineDominionAssault }
procedure TfRuinsTalk.DeclineDominionAssault(Action: Integer);
begin
  DialogText := LocalizedColorText('FormRuins.CB.WarPlans.Assault.CBAfterRefuse');
  BuildDominionWarOptions;
end;
{ @end $5DC3A4 }

{ @routine $5DC468 TfRuinsTalk_ExecuteUiCode }
procedure TfRuinsTalk.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  if not MainPanel.NavigationLocked and not ExitScreenLoop and
     (TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared]) then
  begin
    Galaxy.CheckIntegrityChecksum(10009);
    ExecuteGameplayUiCode(Block, Key);
    Galaxy.PrimeIntegrityChecksum(20009);
  end;
end;
{ @end $5DC468 }

end.
